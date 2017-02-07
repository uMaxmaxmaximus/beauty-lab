export default class ClientPage {

	static style = require('./ClientPage.styl')
	static template = `
    <button (click)="User.logOut()">Выход</button>
    
    <form (submit)="onSubmit(this)">
      <file name="image" multiple="">Картинка</file>
      <submit>Отправить</submit>
		</form>
  `

	onSubmit(form) {
		console.log(form.value.image)
	}

}

