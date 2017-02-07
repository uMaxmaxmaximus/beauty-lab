import arangojs, {aql} from 'arangojs'
import FieldModel from './fields/field-model'
import Range from './range'
import Schema from './schema'
import qb from 'aqb'


export default class Model {


	static options = null // connection options
	static schema = null // user schema

	static _normalSchema = null
	static _collection = null
	static _database = null


	static getSchema() {
		if (!this._normalSchema) {
			this._normalSchema = new Schema(this.schema)
		}
		return this._normalSchema
	}


	static async _getDatabase() {
		if (Model._database) {
			return Model._database
		}

		let dbName = this.options.database
		let host = this.options.host || 'localhost'
		let port = this.options.port || 8529
		let username = this.options.username || 'root'
		let password = this.options.password || ''

		let db = arangojs({
			url: `http://${username}:${password}@${host}:${port}`,
		})

		try {
			await db.createDatabase(dbName)
		} catch (e) {
		}

		db.useDatabase(dbName)

		Model._database = db
		return db
	}


	static async _getCollection() {
		if (this._collection) {
			return this._collection
		}

		let db = await this._getDatabase()
		let collection = db.collection(this.name)

		try {
			await collection.create()
			await this._setIndexes(collection)
		} catch (e) {
		}

		return this._collection = collection
	}


	static async _setIndexes(collection) {
		let schema = this.getSchema()
		for (let field of schema) {
			if (!field.options.index) continue

			let path = field.path.join('.')
			let unique = field.options.unique
			await collection.createHashIndex(path, {unique})
		}
	}


	static async _call(method, ...args) {
		try {
			let collection = await this._getCollection()
			if (!collection[method]) {
				throw Error(`Collection has not method '${method}'`)
			}
			return await collection[method](...args)

		} catch (error) {
			console.error(error)
		}
	}


	static _validate(data) {
		let schema = this.getSchema()
		schema.validate(data)
	}


	static _getDocument(documentHandle) {
		return this._call('document', documentHandle)
	}


	static _getDocuments(documentHandles) {
		return this._call('lookupByKeys', documentHandles)
	}


	static createModelByDocument(document) {
		let model = Object.create(this.prototype)
		this._documentToModel(model, document)
		model.constructor()
		return model
	}


	static _documentToModel(model, document) {
		let schema = this.getSchema()
		schema.documentToModel(model, document)
		return model
	}


	static _modelToDocument(model) {
		let schema = this.getSchema()
		let document = {}
		schema.modelToDocument(model, document)
		return document
	}


	static _toQueryValue(value) {
		switch (typeof value) {
			case 'string':
				return qb.str(value)
			case 'number':
				return qb.num(value)
			case 'boolean':
				return qb.bool(value)
		}

		if (value instanceof Set) {
			value = Array.from(value)
		}

		if (value instanceof Array) {
			value = value.map(item => this._toQueryValue(item))
			return qb.list(value)
		}

		if (value instanceof Model) {
			return qb.str(value._id)
		}

		if (value instanceof Date) {
			return value.getTime()
		}

		return value
	}


	static _QB_METHODS = {
		'is': 'eq',
		'isnt': 'neq',
		'lt': 'lt',
		'gt': 'gt',
		'in': 'in',
		'notIn': 'notIn',
	}


	static _parseFilterRules(filter) {
		if (typeof filter !== 'object' || filter.constructor !== Object) {
			filter = {is: filter}
		}

		let rules = []
		Object.getOwnPropertyNames(filter).forEach(method => {
			rules.push({method, value: filter[method]})
		})

		rules = rules.map(rule => {
			let method = this._QB_METHODS[rule.method]
			let value = this._toQueryValue(rule.value)

			if (!method) {
				throw Error(`Неизвестный метод сравнения ${method}`)
			}
			return {method, value}
		})

		return rules
	}


	static _createQueryFilter(selector) {
		let conditions = []

		Object.keys(selector).forEach((key) => {
			let rules = this._parseFilterRules(selector[key])
			rules.forEach(rule => {
				conditions.push(qb[rule.method](`this.${key}`, rule.value))
			})
		})

		if (!conditions.length) return null
		return qb.and(...conditions)
	}


	static async _query(query, options) {
		let db = await this._getDatabase()
		return await db.query(query, {}, {options: {fullCount: !!options.count}})
	}


	static async selectCursor(selector = {}, options = {}) {
		// TODO selector can be filter string
		// TODO контролировать лимит

		let {
			skip = 0,
			limit = 50,
			count = true,
			removed = false,
			noLimit = false,
			sortReverse = '', sort = ''
		} = options

		// for in collection
		let query = qb.for('this').in(this.name)

		// filter
		if (!removed) selector._removed = false
		let filter = this._createQueryFilter(selector)
		if (filter) query = query.filter(filter)

		// sort
		let sortOrder = sortReverse ? 'DESC' : 'ASC'
		let sortProp = sort || sortReverse
		if (sortProp) query = query.sort(`this.${sortProp}`, sortOrder)

		// limit
		if (!noLimit) {
			skip = Math.max(skip, 0)
			query = query.limit(skip, limit)
		}

		// return doc
		query = query.return('this')

		await this._getCollection() // create collection, if not created
		return await this._query(query, {count})
	}


	/******************* public static methods *******************/


	static async add(data) {
		this._validate(data)
		let document = this._modelToDocument(data)
		document._removed = false
		let documentHandle = await this._call('save', document)
		document = await this._call('document', documentHandle)
		return this.createModelByDocument(document)
	}


	static async getById(_id) {
		if (!_id) return null
		return this.selectOne({_id}, {removed: true})
	}


	static async getByIds(ids) {
		let models = await this.select({_id: {in: ids}}, {noLimit: true})
		return ids.map(_id => models.getById(_id))
	}


	static async save(model) {
		this._validate(model)
		let document = this._modelToDocument(model)
		let newHandle = await this._call('update', model._id, document)
		model._rev = newHandle._rev
		return model
	}


	static async update(model) {
		let document = await this._getDocument(model)
		this._documentToModel(model, document)
		return model
	}


	static async remove(model) {
		let handle = {_id: model._id}
		let newValue = {_removed: true}
		let newHandle = await this._call('updateByExample', handle, newValue)
		model._removed = true
		return true
	}


	static async restore(model) {
		let handle = {_id: model._id}
		let newValue = {_removed: false}
		let newHandle = await this._call('updateByExample', handle, newValue)
		model._removed = false
		return true
	}


	static async select(selector = {}, options = {}) {
		let cursor = await this.selectCursor(selector, options)
		let documents = await cursor.all()
		let models = documents.map(document => this.createModelByDocument(document))
		return new Range(this, models, cursor.extra.stats.fullCount)
	}


	static async selectOne(selector = {}, options = {}) {
		options.limit = 1
		options.count = false
		let models = await this.select(selector, options)
		let model = models[0]
		return model || null
	}


	static async count(selector = {}, options) {
		let cursor = await this.selectCursor(selector, options)
		return cursor.extra.stats.fullCount
	}


	static async have(selector = {}, options) {
		let cnt = await this.count(selector, options)
		return cnt > 0
	}


	/******************* instance methods *******************/

	async save() {
		return this.constructor.save(this)
	}


	async update() {
		return this.constructor.update(this)
	}


	async remove() {
		return this.constructor.remove(this)
	}


	async restore() {
		return this.constructor.restore(this)
	}


	toJSON() {
		let obj = {}
		let schema = this.constructor.getSchema()

		for (let field of schema) {
			if (field instanceof FieldModel) {
				obj[field.name] = this[field.ID]
			} else {
				obj[field.name] = this[field.name]
			}
		}

		return obj
	}

}

