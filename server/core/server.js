import socketIo from 'socket.io'
import socketStream from 'socket.io-stream'
import config from '../config'
import cookieParser from 'cookie'
import Encoder from './encoder'
import Params from './params'
import User from '../models/user'


export default new class Server {


	constructor() {
		this.methods = []
		this.connections = []
		this.io = socketIo(config.port)
		this.io.on('connection', socket => {
			return this.onConnect(socketStream(socket))
		})
	}


	async onConnect(socket) {
		let cookies = cookieParser.parse(socket.sio.handshake.headers.cookie)
		console.log(User)
		let user = await User.getBySessionKey(cookies['session-key'])
		let connection = new Connection(this, socket, user)
		this.connections.push(connection)
		socket.on('disconnect', () => this.onDisconnect(connection))
	}


	async onDisconnect(connection) {
		let index = this.connections.indexOf(connection)
		if (index === -1) return
		this.connections.splice(index, 1)
	}


	async callMethod(name, params, connection) {
		if (!this.hasMethod(name)) {
			throw new ApiError(name, 1)
		}

		try {
			let method = this.getMethod(name)
			params = new Params(params, connection)
			return await method.func(params, connection)
		} catch (error) {
			if (!(error instanceof ApiError))
				console.error(error)
			throw error
		}
	}


	addMethod(name, func) {
		if (this.hasMethod(name)) {
			debugger
			throw Error(`Метод ${name} уже существует`)
		}

		this.methods.push({name, func})
	}


	getMethod(name) {
		for (let method of this.methods)
			if (method.name === name) return method
		return null
	}


	hasMethod(name) {
		for (let method of this.methods)
			if (method.name === name) return true
		return false
	}


}


class Connection {

	constructor(server, socket, user) {
		this.server = server
		this.socket = socket
		this.user = user

		this.isAdmin = user && user.isAdmin
		this.isClient = user && user.isClient

		this.socket.on('request', data => this.onRequest(data))
		this.socket.on('disconnect', () => this.onDisconnect())

		this.tasks = []
		this.tasksIsRunned = false

		return this.checkOnline()
	}


	async onDisconnect() {
		this.tasks.splice(0, this.tasks.length) // clear queue
		await this.checkOffline()
	}


	async setSession(session) {
		await this.closeSession()
		this.session = session
		this.user = await session.user
		this.isAdmin = this.user && this.user.isAdmin
		this.isClient = this.user && this.user.isClient

		await this.checkOnline()
	}


	async closeSession() {
		if (this.session) {
			await this.checkOffline()
			await this.session.close()
		}
		this.session = null
		this.user = null

		this.isAdmin = false
		this.isClient = false
	}


	async checkOnline() {
		if (this.user) {
			await this.user.toOnline()
		}
	}


	async checkOffline() {
		if (!this.user) return
		for (let connection of this.server.connections) {
			if (connection === this) continue
			if (connection.user === this.user) return
		}
		await this.user.toOffline()
	}


	error(message, code = 2) {
		throw new ApiError(message, code)
	}


	mustBeAuthorized() {
		if (!this.user) {
			throw new ApiError('Метод доступен только авторизованным пользователям', 3)
		}
	}


	mustBeAdmin() {
		if (!this.isAdmin) {
			throw new ApiError('Метод доступен только администратору', 3)
		}
	}


	mustBeClient() {
		if (!this.isClient) {
			throw new ApiError('Метод доступен только клиентам', 3)
		}
	}


	callMethod(name, params) {
		return this.server.callMethod(name, params, this)
	}


	async onRequest(taskDatas) {
		try {
			taskDatas = Encoder.decode(taskDatas)
			let tasks = taskDatas.map(data => new Task(data, this))
			this.tasks.push(...tasks)
			await this.runTasks()
		} catch (error) {
			console.error(error)
		}
	}


	sendResponse(data) {
		this.socket.emit('response', Encoder.encode(data))
	}


	async runTasks() {
		if (this.tasksIsRunned) return
		this.tasksIsRunned = true

		while (this.tasks.length) {
			let task = this.tasks.shift()
			await task.run()
			this.sendResponse([task])
		}

		this.tasksIsRunned = false
	}

}


class Task {

	constructor(data, connection) {
		this.id = data.id
		this.name = data.name
		this.params = data.params
		this.connection = connection
		this.result = null
		this.error = null
	}


	toJSON() {
		return {
			id: this.id,
			name: this.name,
			error: this.error,
			result: this.result,
		}
	}


	async run() {
		try {
			this.result = await this.connection.callMethod(this.name, this.params)
		} catch (error) {
			if (!(error instanceof ApiError)) {
				error = new ApiError('', 0)
			}
			this.error = error
		}
	}


}


class ApiError {

	static TEXT_CODES = {
		0: 'Внутренняя ошибка сервера',
		1: 'Метод не найден',
		2: 'Неверные параметры',
		3: 'Недостаточно привелегий',
	}

	constructor(message, code = 0) {
		this.message = message
		this.code = code
		this.textCode = ApiError.TEXT_CODES[code] || ''
	}

}

