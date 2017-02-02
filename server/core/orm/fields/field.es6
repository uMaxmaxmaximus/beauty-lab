import ValidationError from "../validation-error"


/** @abstract class */
export default class Field {


	constructor(options, path, basePath = []) {
		this.internal = options.internal || false
		this.default = options.default
		this.type = options.type

		this.path = path
		this.name = path[0]
		this.basePath = basePath

		if (!this.internal) {
			this.checkPath(this.path, this.basePath)
		}
	}


	checkPath(path, basePath) {
		for (let prop of path) {
			let match = prop.match(/^([_$])/)
			if (match) {
				let stringPath = this.pathsToString([basePath, path])
				throw Error(`Field names can not begin with a '${match[1]}' symbol, but have '${stringPath}'`)
			}
		}
	}


	pathsToString(subPaths = []) {
		let props = [].concat(...subPaths)

		let prettyPath = props.map((prop, index) => {
			if (!/^[A-Za-z$_]+$/.test(prop)) return `[${prop}]`
			if (index === 0) return prop
			return `.${prop}`
		}).join('')

		return prettyPath
	}


	valueToString(value) {
		if (Object(value) === value) return value.constructor.name
		if (typeof value === 'string') return `'${value}'`
		return value
	}


	typeError(type, value, basePath, subPath) {
		var valueText = this.valueToString(value)
		let message = `должно быть ${type.name}, а имеем ${valueText}`
		this.throwError(message, basePath, subPath)
	}


	throwError(message, basePath = this.basePath, subPath = []) {
		let subPaths = [basePath, this.path, subPath]
		let pathString = this.pathsToString(subPaths)
		throw new ValidationError(`Поле '${pathString}' ${message}`)
	}


	documentToModel(model, document) {
		let value = this.getByPath(document)
		value = this.convertToModelValue(value)
		this.setByPath(model, value)
	}


	modelToDocument(mode, document) {
		let value = this.getByPath(mode)
		value = this.convertToDocumentValue(value)
		this.setByPath(document, value)
	}


	validate(data, basePath) {
		throw 'validate is virtual method'
	}


	convertToModelValue(value) {
		throw 'convertToModelValue is virtual method'
	}


	convertToDocumentValue(value) {
		throw 'convertToDocumentValue is virtual method'
	}


	getDefaultValue() {
		let _default = this.default

		if (typeof _default === 'function') {
			return _default()
		}
		return _default
	}


	getByPath(context, needsDefault = true) {
		for (let prop of this.path) {
			context = context[prop]
		}

		if (context === undefined && needsDefault) {
			return this.getDefaultValue()
		}

		return context
	}


	setByPath(context, value) {
		let path = this.path.slice()
		let lastProp = path.pop()

		for (let prop of path) {
			if (!context[prop]) context[prop] = {}
			context = context[prop]
		}

		return context[lastProp] = value
	}

}



