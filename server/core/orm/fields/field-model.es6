import Field from './field'
import Model from '../model'


export default class FieldModel extends Field {


	constructor(options, path, basePath) {
		super(options, path, basePath)
		this.null = !!options.null
		this.PROP = path[path.length - 1]
		this.ID = `${this.PROP}Id`
		this.HAS_ACCESSORS = Symbol(`Has '${this.PROP}' accessors`)
	}


	capitalize(str) {
		return str.slice(0, 1).toUpperCase() + str.slice(1)
	}


	validate(data, basePath = []) {
		if (data instanceof Model) {
			// TODO сделать валидацию по id
		}
		else {
			let subModel = this.getByPath(data)
			if (this.null && subModel === null) return
			if (!this.validateValue(subModel)) {
				this.typeError(this.type, subModel, basePath)
			}
		}
	}


	validateValue(value) {
		if (value === null && this.null) {
			return true
		}
		return value instanceof this.type
	}


	documentToModel(model, document) {
		let field = this
		let context = this.getContextByPath(model)
		context[this.ID] = this.getByPath(document)

		if (context[this.HAS_ACCESSORS]) return
		context[this.HAS_ACCESSORS] = true

		Object.defineProperty(context, this.PROP, {
			get: function () {
				return field.type.getById(context[field.ID])
			},

			set: function (subModel) {
				if (!field.validateValue(subModel)) {
					field.typeError(field.type, subModel)
				} else {
					if (subModel === null) {
						context[field.ID] = null
					}
					else {
						context[field.ID] = subModel._id
					}
				}
			},
		})

	}


	modelToDocument(model, document) {
		if (model instanceof Model) {
			let context = this.getContextByPath(model)
			this.setByPath(document, context[this.ID])
		}
		else {
			// user defined object like model
			let subModel = this.getByPath(model)
			if (this.null && subModel === null) {
				this.setByPath(document, null)
			} else {
				this.setByPath(document, subModel._id)
			}
		}
	}


	getContextByPath(context) {
		for (let prop of this.path.slice(0, -1)) {
			if (!context[prop]) context[prop] = {}
			context = context[prop]
		}
		return context
	}

}




