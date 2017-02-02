import ValidationError from './orm/validation-error'


export default class Params {


	constructor(data = {}, connection) {
		this.connection = connection
		this.data = data
	}


	get(options = {}) {
		if (typeof options === 'function') {
			try {
				return options(this)
			} catch (error) {
				if (error instanceof ValidationError) {
					this.error(error.message)
				} else {
					throw error
				}
			}
		} else {
			let name = options.name
			let value = this.data[name]
			this.validateValue(name, value, options)
			return value
		}
	}


	getSkip() {
		return this.get({name: 'skip', type: Number, min: 0})
	}


	getLimit() {
		return this.get({name: 'limit', type: Number, min: 0, max: 200})
	}


	error(message) {
		this.connection.error(message, 2)
	}


	validateValue(name, value, options) {
		let type = options.type


		if (type && value === undefined) {
			if (options.optional) return
			this.error(`Не задано обязательное поле ${name}`)
		}

		switch (type) {

			case  Set: {
				if (!(value instanceof Set)) {
					this.error(`Поле ${name} должно быть сетом`)
				}

				let min = options.min
				if (min != null && value.size < min) {
					this.error(`Длина поля ${name} должна быть больше или равна ${min}`)
				}

				let max = options.max
				if (max != null && value.size > max) {
					this.error(`Длина поля ${name} должна быть меньше или равна ${max}`)
				}
				break
			}

			case  Array: {
				if (!(value instanceof Array)) {
					this.error(`Поле ${name} должно быть массивом`)
				}

				let min = options.min
				if (min != null && value.length < min) {
					this.error(`Длина поля ${name} должна быть больше или равна ${min}`)
				}

				let max = options.max
				if (max != null && value.length > max) {
					this.error(`Длина поля ${name} должна быть меньше или равна ${max}`)
				}
				break
			}

			case  Number: {
				if (typeof value !== 'number') {
					this.error(`Поле ${name} должно быть числом`)
				}

				let min = options.min
				if (min != null && value < min) {
					this.error(`Поле ${name} должно быть больше или равно ${min}`)
				}

				let max = options.max
				if (max != null && value > max) {
					this.error(`Поле ${name} должно быть меньше или равно ${max}`)
				}
				break
			}

			case  String: {
				if (typeof value !== 'string') {
					this.error(`Поле ${name} должно быть строкой`)
				}

				let min = options.min
				if (min != null && value.length < min) {
					this.error(`Длина поля ${name} должна быть больше или равна ${min}`)
				}

				let max = options.max
				if (max != null && value.length > max) {
					this.error(`Длина поля ${name} должна быть меньше или равна ${max}`)
				}

				let test = options.test
				if (test != null && !test.test(value)) {
					this.error(`Поле ${name} не корректно`)
				}
				break
			}
		}

		if (options.enum && options.enum.indexOf(value) === -1) {
			this.error(`Для поля ${name} возможны следующие значения [${options.enum.join(', ')}]`)
		}

	}


}


