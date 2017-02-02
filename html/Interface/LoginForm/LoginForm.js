import User from '../../core/api/user'


export default class LoginForm {

	static style = require('./LoginForm.styl')
	static template = `
		<form #form (submit)="onSubmit(this)">
			<text name="login">Логин</text>
			<text name="pass">Пароль</text>
			<submit>Войти</submit>
		</form>
	`

	async onSubmit(form) {
		await User.logIn(form.value)
	}


}

