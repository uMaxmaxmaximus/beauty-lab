Encoder = require('server/core/encoder').default
Model = require('./model')


Encoder.add
	type: Model,

	decode: (value)=>
		return Model.create(value.type, value.data, value.submodelFields)

	encode: (model)=>
		data = {}
		for key in Object.getOwnPropertyNames(model)
			value = model[key]

			if value instanceof Model
				data[key] = value._id
			else
				data[key] = value
		return data


