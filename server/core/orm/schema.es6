import Model from './model'
import FieldType from './fields/field-type'
import FieldTypes from './fields/field-types'
import FieldModel from './fields/field-model'
import FieldModels from './fields/field-models'
import FieldSchemas from './fields/field-schemas'


export default class Schema {


	constructor(userSchema, basePath = [], addInternalFields = true) {
		this.basePath = basePath
		this.fields = this._parse(userSchema)

		if (addInternalFields) {
			this.fields.push(new FieldType({type: String, min: 4, internal: true}, ['_id'], basePath))
			this.fields.push(new FieldType({type: String, internal: true}, ['_key'], basePath))
			this.fields.push(new FieldType({type: String, internal: true}, ['_rev'], basePath))
			this.fields.push(new FieldType({type: Boolean, internal: true}, ['_removed'], basePath))
		}

	}


	_parse(value, path = [], fields = []) {
		if (typeof value != 'object') return fields

		if (typeof value.type === 'function') {
			if (value.type.prototype instanceof Model) {
				fields.push(new FieldModel(value, path, this.basePath))
			}
			else {
				fields.push(new FieldType(value, path, this.basePath))
			}
		}
		else if (Array.isArray(value)) {
			value = value[0]

			if (typeof value.type === 'function') {
				if (value.type.prototype instanceof Model) {
					fields.push(new FieldModels(value, path, this.basePath))
				}
				else {
					fields.push(new FieldTypes(value, path, this.basePath))
				}
			}
			else {
				fields.push(new FieldSchemas(value, path, this.basePath))
			}

		} else {
			for (let key in value) if (value.hasOwnProperty(key)) {
				this._parse(value[key], [...path, key], fields)
			}
		}

		return fields
	}


	validate(data, basePath = []) {
		this.fields.forEach(field =>
			field.validate(data, basePath)
		)
	}


	getFieldByName(name) {
		for (let i = 0; i < this.fields.length; i++) {
			let field = this.fields[i]
			if (field.name === name) {
				return field
			}
		}
		return null
	}


	documentToModel(model, document) {
		this.fields.forEach(field => {
			field.documentToModel(model, document)
		})
		return model
	}


	modelToDocument(model, document) {
		this.fields.forEach(field => {
			field.modelToDocument(model, document)
		})
		return document
	}


	[Symbol.iterator]() {
		return this.fields.values()
	}


}

