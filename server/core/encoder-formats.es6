import Encoder from './encoder'
import Model from './model'


Encoder.add({
	type: Model,

	encode(model){
		return {
			type: model.constructor.name,
			data: model.toJSON()
		}
	},

	decode(model){
		return model
	}

})

