import LoginForm from './LoginForm/LoginForm'
import AdminPage from './AdminPage/AdminPage'
import ClientPage from './ClientPage/ClientPage'


export default class Interface {

	static style = require('./Interface.styl')
	static components = [LoginForm, ClientPage, AdminPage]

	static template = `
		<LoginForm *if="!User.current"></LoginForm>
		<AdminPage *if="User.current.type is User.ADMIN"></AdminPage>
		<ClientPage *if="User.current.type is User.CLIENT"></ClientPage>
	`

}

