import Field from './field'


export default class FieldType extends Field {


	constructor(options, path, basePath) {
		super(options, path, basePath)
		this.null = !!options.null
		this.test = options.test
		this.enum = options.enum
		this.set = options.set
		this.min = options.min
		this.max = options.max
		this.checkType(this.type)
	}


	checkType(type) {
		if (type === Boolean) return
		if (type === String) return
		if (type === Number) return
		if (type === Date) return
		if (type === Set) return

		if (!type.prototype.toJSON) {
			throw Error(`Custom type '${type.name}' must have method 'toJSON'`)
		}
		if (!type.fromJSON) {
			throw Error(`Custom type '${type.name}' must have static method 'fromJSON'`)
		}
	}


	validate(data, basePath = []) {
		if (this.internal) return

		let value = this.getByPath(data)
		if (this.null && value === null) return

		if (!this.validateValue(value, basePath)) {
			this.typeError(this.type, value, basePath)
		}
	}


	validateValue(value, basePath) {
		if (this.null && value === null) {
			return
		}

		if (this.enum) {
			this.validateEnum(value, basePath)
		}

		switch (this.type) {
			case String:
				return this.validateString(value, basePath)
			case Number:
				return this.validateNumber(value, basePath)
			case Boolean:
				return this.validateBoolean(value, basePath)
			case Set:
				return this.validateSet(value, basePath)
			default:
				return value instanceof this.type
		}

	}


	validateNumber(value, basePath) {
		if (typeof value !== 'number') return false

		if (!Number.isFinite(value)) {
			this.throwError(`дожлно быть конечным числом, а имеем ${value}`, basePath)
		}
		if (this.min != null && value < this.min) {
			this.throwError(`должно быть больше или равно ${this.min}, а имеем ${value}`, basePath)
		}
		if (this.max != null && value > this.max) {
			this.throwError(`должно быть меньше или равно ${this.max}, а имеем ${value}`, basePath)
		}
		return true
	}


	validateBoolean(value, basePath) {
		return typeof value === 'boolean'
	}


	validateString(value, basePath) {
		if (typeof value !== 'string') return false

		if (this.test != null && !this.test.test(value)) {
			this.throwError(`должно подходить под выражение ${this.test}, а имеем '${value}'`, basePath)
		}
		if (this.min != null && value.length < this.min) {
			this.throwError(`должно содержать ${this.min} или больше символов, а имеем '${value}'`, basePath)
		}
		if (this.max != null && value.length > this.max) {
			this.throwError(`должно содержать ${this.max} или меньше символов, а имеем '${value}'`, basePath)
		}
		return true
	}


	validateEnum(value, basePath) {
		if (this.enum.indexOf(value) === -1) {
			let enumText = JSON.stringify(this.enum)
			let valueText = this.valueToString(value)
			let message = `должно быть одним из перечисленного ${enumText}, а имеем ${valueText}`
			this.throwError(message, basePath)
		}
	}


	validateSet(value, basePath) {
		if (!(value instanceof Set)) return false

		if (this.min != null && value.size < this.min) {
			this.throwError(`должно содержать ${this.min} или больше пунктов, а имеем ${value.size}`, basePath)
		}

		if (this.max != null && value.size > this.max) {
			this.throwError(`должно содержать ${this.max} или меньше пунктов, а имеем ${value.size}`, basePath)
		}

		value.forEach(item => {
			if (this.set.indexOf(item) === -1) {
				let setText = JSON.stringify(this.set)
				let itemValue = this.valueToString(item)
				let message = `должно содержать элементы только из этих ${setText}, а имеем ${itemValue}`
				this.throwError(message, basePath)
			}
		})
		return true
	}


	convertToModelValue(value) {

		// Если в базе данных undefined или null,
		// то видимо целостность базы нарушена,
		// но чтобы все не ломать вернем null
		// а не будем конвертировать в тип
		if (value == null) {
			return null
		}

		switch (this.type) {
			case String:
				return String(value)
			case Number:
				return Number(value)
			case Boolean:
				return Boolean(value)
			case Date:
				return new Date(value)
			case Set:
				return new Set(value)
		}

		return this.type.fromJSON(value)
	}


	convertToDocumentValue(value) {
		if (this.null && value === null) {
			return null
		}

		switch (this.type) {
			case String:
				return value
			case Number:
				return value
			case Boolean:
				return value
			case Date:
				return value.getTime()
			case Set:
				return Array.from(value)
		}

		// for custom types
		return value.toJSON()
	}


}



