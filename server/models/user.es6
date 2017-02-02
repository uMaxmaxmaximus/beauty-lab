import passwordHash from 'password-hash'
import Model from '../core/model'
import Utils from '../core/utils'


export default class User extends Model {


	static schema = {
		login: {type: String, min: 3, max: 100, test: /^\S+/},
		pass: {type: String, min: 3, max: 100, test: /^\S+/},
		type: {type: String, enum: ['admin', 'client']},
		online: {type: Boolean, default: false},

		fullName: {type: String, min: 1, max: 100, default: ''},
		pasport: {type: String, max: 2000, default: ''},
		addressDistrict: {type: String, max: 100, default: ''},
		address: {type: String, max: 1000, default: ''},
		phones: {type: String, max: 200, default: ''},

		email: {type: String, max: 50, default: ''},
		employmentDate: {type: Date, default: () => new Date},

		comment: {type: String, max: 5000, default: ''},
	}


	toJSON() {
		let data = super.toJSON()
		delete data['pass']
		return data
	}


	static ADMIN = 'admin'
	static CLIENT = 'client'


	constructor(...args) {
		super(...args)
		this.isAdmin = this.type === User.ADMIN
		this.isClient = this.type === User.CLIENT
	}


	async toOnline() {
		this.online = true
		await this.save()
	}


	async toOffline() {
		this.online = false
		await this.save()
	}


	async sendEmail(title, message) {
		return await Utils.sendmail({
			to: this.email,
			subject: title,
			message: message,
		})
	}


	checkPass(pass) {
		return passwordHash.verify(pass, this.pass)
	}


	getTypeText() {
		switch (this.type) {
			case this.constructor.ADMIN:
				return 'администратор';
			case this.constructor.CLIENT:
				return 'водитель';
		}
	}


	async setPass(pass) {
		this.pass = passwordHash.generate(pass)
		return await this.save()
	}


	async startSession() {
		let key = Utils.createRandomString(64)
		return await Session.add({key: key, user: this})
	}


	static async getBySessionKey(sessionKey) {
		if (!sessionKey) return null
		let session = await Session.getByKey(sessionKey)
		if (!session) return null
		return await session.user
	}


	static add(data) {
		if (data.pass) { // хэшируем пароль
			data.pass = passwordHash.generate(data.pass)
		}
		return super.add(data)
	}

}


class Session extends Model {


	static schema = {
		key: {type: String, unique: true},
		user: {type: User},
	}


	static async getByKey(key) {
		if (!key) return null
		return await this.selectOne({key})
	}


	async close() {
		await this.remove()
	}

}


User.api({


	async login(params, connection) {
		let login = User.filter(params, 'login')
		let pass = User.filter(params, 'pass')

		if (await User.count() === 0) {
			var user = await User.add({
				login, pass,
				fullName: 'Admin',
				type: 'admin'
			})
		}
		else {
			var user = await User.selectOne({login: login})
			if (!user || !user.checkPass(pass)) {
				connection.error('Не верный логин или пароль')
			}
		}

		let session = await user.startSession()
		await connection.setSession(session)
		return {session, user}
	},


	async logout(params, connection) {
		await connection.closeSession()
		return true
	},


	async current(params, connection) {
		if (!connection.user) return null
		return connection.user
	},


	async get(params, connection) {
		let skip = params.getSkip()
		let limit = params.getLimit()
		let type = User.filter(params, 'type')

		return await User.select({type}, {skip, limit, sort: 'fullName'})
	},


	async getById(params, connection) {
		return await User.filter(params, '_id')
	},


	async add(params, connection) {
		connection.mustBeAdmin()

		let type = User.filter(params, 'type')
		let fullName = User.filter(params, 'fullName')
		let email = User.filter(params, 'email')

		if (type === 'admin') {
			connection.error(`Тип должен не может быть admin`)
		}

		let usersCount = await User.count({}, {removed: true})
		let login = `${type}${usersCount + 1}`

		if (await User.have({login})) {
			connection.error(`Пользователь с логином '${login}' уже существует`)
		}

		let pass = Utils.createRandomString(8)
		let user = await User.add({type, login, pass, fullName, email})

		try {
			await user.sendEmail(
				'Регистрация в системе транспортной компании "Удача"',
				`Вы зарегистрированы в системе как <b>${user.getTypeText()}</b> ${fullName}.
        Ваш логин: <b>${login}</b>, Ваш пароль: <b>${pass}</b>(на английском)`
			)
		}
		catch (error) {
		}

		return user
	},


	async save(params, connection) {
		connection.mustBeAdmin()

		let user = await User.filter(params, '_id')
		user.fullName = User.filter(params, 'fullName')
		user.pasport = User.filter(params, 'pasport')
		user.addressDistrict = User.filter(params, 'addressDistrict')
		user.address = User.filter(params, 'address')
		user.phones = User.filter(params, 'phones')
		user.email = User.filter(params, 'email')
		user.employmentDate = User.filter(params, 'employmentDate')
		user.comment = User.filter(params, 'comment')

		return await user.save()
	},


	async remove(params, connection) {
		connection.mustBeAdmin()

		let user = await User.filter(params, '_id')

		if (user.isAdmin) {
			connection.error('Нельзя удалить администратора')
		}

		return await user.remove()
	},


	async resetPass(params, connection) {
		connection.mustBeAdmin()

		let user = await User.filter(params, '_id')
		let pass = Utils.createRandomString(8)

		await user.setPass(pass)
		await user.sendEmail(
			'Сброс пароля в системе транспортной компании "Удача"',
			`Вы зарегистрированы в системе как <b>${user.getTypeText()}</b> ${user.fullName}.
       Ваш логин: <b>${user.login}</b>, Ваш новый пароль: <b>${pass}</b>(на английском)`
		)

		return true
	},


	async changeAdminPass(params, connection) {
		connection.mustBeAdmin()

		let oldPass = params.get({name: 'oldPass', type: String, max: 100})
		let newPass = params.get({name: 'newPass', type: String, min: 3, max: 100})

		let newPassRepeat = params.get({
			name: 'newPassRepeat', type: String,
			min: 3, max: 100
		})

		let admin = connection.user

		if (!admin.checkPass(oldPass)) {
			connection.error('Не верный старый пароль')
		}

		if (newPass !== newPassRepeat) {
			connection.error('Пароли не совпадают')
		}

		await admin.setPass(newPass)
		return true
	},


	async changeAdminName(params, connection) {
		connection.mustBeAdmin()

		let fullName = User.filter(params, 'fullName')
		let admin = connection.user

		admin.fullName = fullName

		await admin.save()
		return fullName
	},


})




