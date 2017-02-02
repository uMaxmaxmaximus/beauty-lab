import LoginForm from './LoginForm/LoginForm'
import UserPage from './UserPage/UserPage'
import AdminPage from './AdminPage/AdminPage'
import User from '../core/api/user'


export default class Interface {

	static style = require('./Interface.styl')
	static components = [LoginForm, UserPage, AdminPage]

	static template = `
		<LoginForm *if="!User.current"></LoginForm>
		<UserPage *if="User.current.type is User.USER"></UserPage>
		<AdminPage *if="User.current.type is User.ADMIN">AdminPage</AdminPage>
	`

	constructor() {
		window.User = User
	}

}

