import ui from 'ui-js'
import Server from './core/server'
import User from './core/api/user'
import Interface from './Interface/Interface'
import Background from './Background/Background'

import './widgets/widgets'
import './core/encoder-formats'


ui.global('User', User)


ui.bootstrap(class App {

	static style = require('./index.styl')
	static components = [Background, Interface]

	static template = `
		<div .container .__mobile-mode="isMobile">
	    <Background></Background>
	    <Interface></Interface>
	    <Notificator #notificator></Notificator>
	    <Confirm #confirm></Confirm>
		</div>
  `

	constructor() {
		this.isMobile = ui.isMobile()
		this.host.addClass('__mobile')
		Server.on('error', error => {
			this.scope.notificator.error(error.message)
		})
	}


	confirm(text) {
		return this.scope.confirm.confirm(text)
	}


	alert(text) {
		this.scope.notificator.alert(text)
	}


	error(text) {
		this.scope.notificator.error(text)
	}


	warning(text) {
		this.scope.notificator.warning(text)
	}


})

