module.exports = class Event


	Event.target = null

	@emit: (name, src, target, realEvent)->
		event = new Event(name, src, target, realEvent)
		event.emit()
		return event


	constructor: (@name, @src, @target, @realEvent)->
		@clientX = @realEvent.clientX
		@clientY = @realEvent.clientY

		@_layerX = 0
		@_layerY = 0
		@_layerUpdated = false

		@own = @src is @target
		@prevented = off
		@stopped = off
		return


	Object.defineProperty @prototype, 'layerX',
		get: ->
			@updateLayer()
			return @_layerX


	Object.defineProperty @prototype, 'layerY',
		get: ->
			@updateLayer()
			return @_layerY


	updateLayer: (type)=>
		if @_layerUpdated then return
		rect = @target.rect()
		@_layerX = @clientX - rect.left
		@_layerY = @clientY - rect.top
		@_layerUpdated = true
		return


	emit: ->
		Event.target = @target
		@target.emit(@name, @)
		Event.target = null
		return @


	prevent: ->
		@prevented = yes
		return


	stop: ->
		@stopped = yes
		return

		
