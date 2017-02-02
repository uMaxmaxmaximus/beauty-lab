EventEmitter = require 'ui-js/core/event-emitter'


module.exports = class Range extends Array


	constructor: (@Model, @params = {}, @options = {})->
		@eventEmitter = new EventEmitter
		@count = 0
		@pages = 0
		@activePage = 0

		@updating = false
		@limit = @options.limit ? 30
		@skip = @options.skip ? 0

		if @options.update then @startAutoUpdate()

		@update()
		return


	startAutoUpdate: =>
		# TODO нужна очистка мусора
		setInterval(@update, @options.update)
		return


	on: (args...)=>
		return @eventEmitter.on(args...)


	off: (args...)=>
		return @eventEmitter.off(args...)


	emit: (args...)=>
		return @eventEmitter.emit(args...)


	call: (args...)=>
		return @Model.call(args...)


	update: =>
		@params.skip = @skip
		@params.limit = @limit
		@updating = true

		return @call('get', @params).then (modelList)=>
			@updating = false

			@count = modelList.count
			@pages = Math.ceil(@count / @limit)
			@splice(0, @length, modelList...)

			@emit('update', @)
			return modelList


	add: (data)=>
		return @Model.add(data)


	prev: =>
		if @activePage is 0 then return
		return @toPage(@activePage - 1)


	next: =>
		if @activePage is @pages - 1 then return
		return @toPage(@activePage + 1)


	toPage: (page)=>
		if page is @activePage then return
		if page > @pages - 1 then return
		if page < 0 then return
		@activePage = page
		@skip = @activePage * @limit
		return @update()


