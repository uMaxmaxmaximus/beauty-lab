EventEmitter = require 'ui-js/core/event-emitter'
Encoder = require('server/core/encoder').default
io = require 'socket.io-client'


module.exports = new class Server extends EventEmitter

	constructor: ->
		super
		@tasks = []
		@queue = []
		@connected = true

		if location.href.indexOf('file:///') is -1
			@io = io.connect("#{location.hostname}:8081")
		else
			@io = io.connect("http://mind-transrus.ru:8081")

		@io.on('connect_error', @onDisconnect)
		@io.on('response', @onResponse)
		@io.on('connect', @onConnect)

		setInterval(@sendQueue, 17)
		return


	addToQueue: (task)=>
		@tasks.push(task)
		@queue.push(task)
		return


	sendQueue: =>
		unless @queue.length then return
		@sendRequest(@queue)
		@queue.splice(0, @queue.length) #clear queue
		return


	onConnect: =>
		@connected = true
		return


	onDisconnect: =>
		@connected = false
		@tasks = []
		@queue = []
		return


	sendRequest: (data)=>
		@io.emit('request', Encoder.encode(data))
		return


	onResponse: (responses)=>
		for response in Encoder.decode(responses)
			task = @getTaskById(response.id)
			task.complete(response)
			@removeTask(task)
		return


	removeTask: (task)=>
		index = @tasks.indexOf(task)
		if index is -1 then return
		@tasks.splice(index, 1)
		return


	getTaskById: (id)=>
		for task in @tasks
			if task.id is id then return task
		return null


	call: (name, params)=>
		task = new Task(name, params)
		@addToQueue(task)

		task.on 'reject', (apiError)=>
			@emit('error', apiError)

		return new Promise (resolve, reject)=>
			task.on('resolve', resolve)
			task.on('reject', reject)
			return


class Task extends EventEmitter


	Task.lastId = 0


	constructor: (@name, @params)->
		super
		@id = Task.lastId++
		return


	complete: (response)=>
		if response.error
			@emit('reject', new ApiError(response.error))
		else
			@emit('resolve', response.result)
		return


	toJSON: =>
		return {
			id: @id
			name: @name
			params: @params
		}


class ApiError

	constructor: (errorData)->
		@code = errorData.code
		if errorData.textCode and errorData.message
			@message = "#{errorData.textCode}: #{errorData.message}"
		else
			@message = errorData.textCode or errorData.message
		return




