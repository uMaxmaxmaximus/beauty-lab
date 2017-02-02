import LoginForm from './LoginForm/LoginForm'
import ClientPage from './ClientPage/ClientPage'
import AdminPage from './AdminPage/AdminPage'
import User from '../core/api/user'


export default class Interface {

	static style = require('./Interface.styl')
	static components = [LoginForm, ClientPage, AdminPage]

	static template = `
		<LoginForm *if="!User.current"></LoginForm>
		<ClientPage *if="User.current.type is User.CLIENT"></ClientPage>
		<AdminPage *if="User.current.type is User.ADMIN"></AdminPage>
	`

	constructor() {
		window.User = User
	}

}

