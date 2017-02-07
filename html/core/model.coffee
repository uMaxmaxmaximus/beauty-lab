EventEmitter = require 'ui-js/core/event-emitter'
Range = require './range'
API = require './api'


module.exports = class Model extends API


	registeredTypes = {}
	modelsCache = {}


	@api: (apiName)->
		@apiName = apiName
		registeredTypes[apiName] = @
		return


	@getType: (type)=>
		return registeredTypes[type]


	@models: (props)->
		for prop, type of props then do (prop, type)=>
			propId = "#{prop}Id"

			Object.defineProperty @prototype, prop,
				enumerable: on
				configurable: on

				set: (value)->
					if typeof value is 'string'
						return @[propId] = value

					if value is null
						return @[propId] = null

					if value instanceof Model
						@[propId] = value._id
					return

				get: ->
					if @[propId] is null then return null
					Type = Model.getType(type)
					return Type.getById(@[propId])

		return


	@create: (type, data)->
		Type = @getType(type)
		model = modelsCache[data._id] or= Object.create(Type.prototype)
		model.constructor(data)
		return model


	constructor: (data)->
		for own key, value of data
			@[key] = value
		return


	@_eventEmitter = null


	@getById: (_id)->
		unless _id then return null

		unless modelsCache[_id]
			modelsCache[_id] = new @({_id})
			@call('getById', {_id})
		return modelsCache[_id]


	@_getEventEmitter: ->
		return @_eventEmitter ?= new EventEmitter


	@_getRanges: ->
		return @_ranges ?= []


	@updateRanges: ->
		ranges = @_getRanges()
		promises = for range in ranges then range.update()
		return Promise.all(promises).then =>
			@emit('update', ranges)


	@on: (type, handler)->
		@_getEventEmitter().on(type, handler)
		return


	@off: (type, handler)->
		@_getEventEmitter().off(type, handler)
		return


	@emit: (type, handler)->
		@_getEventEmitter().off(type, handler)
		return


	@range: (params, options)->
		ranges = @_getRanges()
		range = new Range(@, params, options)
		ranges.push(range)
		return range


	@add: (params)->
		return @call('add', params).then (model)=>
			@updateRanges()
			return model



	call: (method, params)=>
		return @constructor.call(method, params)


	updateRanges: =>
		@constructor.updateRanges()
		return


	remove: (needsConfirm = true)->
		if needsConfirm
			promise = ui.app.confirm('Удалить?')
		else
			promise = Promise.resolve()

		return promise.then =>
			return @call('remove', {_id: @_id}).then (res)=>
				@updateRanges()
				return res


	save: =>
		return @call('save', @)
			.then (model)=>
		@updateRanges()
		return model
			.catch (error)=>
		@updateRanges()
		throw error


	set: (data)=>
		for key in Object.getOwnPropertyNames(data)
			@[key] = data[key]
		return @


	update: =>
		@call('getById', {@_id})
		return

