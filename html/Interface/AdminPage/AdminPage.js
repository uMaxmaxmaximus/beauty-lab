import User from '../../core/api/user'


export default class AdminPage {

	static style = require('./AdminPage.styl')
	static template = `
    <div .panel>
      <button (click)="#createUserPopup.open()">Добавить юзера</button>
      <button (click)="User.logOut()">Выход</button>
		</div>
		
		<ul .users>
			<li .user *for="user in users">
				{{ user.fullName }}	
			</li>	
		</ul>
		
		<popup #createUserPopup>
			Создать пользователя
			<form (submit)="createUser(this)">
				<text name="fullName">Ф.И.О.</text>	
				<email name="email">Email</email>	
				<submit>Создать</submit>
			</form>
		</popup>
  `

	constructor() {
		this.users = User.range({type: 'client'})
		console.log(this.users)
	}


	async createUser(form) {
		form.value.type = 'client'
		await User.add(form.value)
		this.scope.createUserPopup.close()
	}


}