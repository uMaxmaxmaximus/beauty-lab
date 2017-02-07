export default class Range {


	constructor(Model, modelsArr, count = null) {
		this.Model = Model
		this.length = 0
		this.count = count
		Array.prototype.push.apply(this, modelsArr)
	}


	toJSON() {
		let obj = {}
		for (let key in this) {
			if (key === 'Model') continue
			obj[key] = this[key]
		}
		return obj
	}


	forEach(handler) {
		for (var i = 0; i < this.length; i++) {
			handler.call(this, this[i], i)
		}
	}


	map(handler) {
		var modelList = new Range(this.Model, [], this.count)
		this.forEach(function (model, i) {
			modelList.push(handler.call(this, model, i))
		})
		return modelList
	}


	push(value) {
		return Array.prototype.push.call(this, value)
	}


	pop(value) {
		return Array.prototype.pop.call(this, value)
	}


	getById(_id) {
		for (var i = 0; i < this.length; i++) {
			let model = this[i]
			if (model._id === _id) {
				return model
			}
		}
		null
	}


}


