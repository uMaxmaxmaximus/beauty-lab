import orm from './orm'
import config from '../config'
import FieldModel from './orm/fields/field-model'
import ValidationError from './orm/validation-error'
import server from '../core/server'


let OrmModel = orm.connect({
	database: config.dbName,
	username: config.dbUser,
	password: config.dbPass,
})


export default class Model extends OrmModel {


	static api(methods) {
		for (let key of Object.getOwnPropertyNames(methods)) {
			let name = `${this.name}.${key}`
			let func = methods[key]
			server.addMethod(name, func)
		}
	}


	static filter(params, name, optional = false) {
		if (name === '_id') {
			let self = this
			return (async function () {
				let _id = params.data['_id']
				if (!_id && optional) return null
				if (_id == null) params.error(`Не задано поле ${name}`)
				let model = await self.getById(_id)
				if (!model) params.error(`Нет ${self.name} с айди ${_id}`)
				return model
			})()
		}

		let schema = this.getSchema()
		let field = schema.getFieldByName(name)

		if (!field) {
			throw new Error(`Не существует поле ${name}, не могу создать фильтр`)
		}

		if (field instanceof FieldModel) {
			return (async function () {
				let _id = params.data[field.name]
				if (Object(_id) === _id) _id = _id._id
				if (!_id && optional) return null
				if (_id == null) params.error(`Не задано поле ${name}`)
				let model = await field.type.getById(_id)
				if (!model) params.error(`Нет ${name} с айди ${_id}`)
				return model
			})()
		}

		try {
			if (!optional) field.validate(params.data)
			return field.getByPath(params.data, false)
		} catch (error) {
			if (error instanceof ValidationError) {
				params.error(error.message)
			} else {
				throw error
			}
		}
	}


}


