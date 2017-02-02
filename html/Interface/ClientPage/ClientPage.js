export default class ClientPage {

	static style = require('./ClientPage.styl')
	static template = `
    <button (click)="User.logOut()">Выход</button>
  `

}