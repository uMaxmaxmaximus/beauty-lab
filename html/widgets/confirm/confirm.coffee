Promise = require 'ui-js/core/promise'
keyboard = require 'ui-js/core/keyboard'


module.exports = class Confirm

	@tag = 'confirm'
	@style = require './confirm.styl'

	@template = "
		<popup #popup (exit)='reject()'>
			<div .wrapper>
				<div .text> {{ text }} </div>
				<div>
					<button (click)='resolve()'>Да</button>
					<button (click)='reject()'>Нет</button>
				</div>
			</div>
		</popup>
	"

	constructor: ->
		@text = ''
		@activePromise = null
		@active = @bind('active', 'popup.active')
		keyboard.on('esc', @onEsc)
		keyboard.on('enter', @onEnter)
		return


	onEnter: =>
		if @active then @resolve()
		return


	onEsc: =>
		if @active then @reject()
		return


	resolve: =>
		@close()
		@activePromise?.resolve()
		@activePromise = null
		return


	reject: =>
		@close()
		@activePromise?.reject()
		@activePromise = null
		return


	open: =>
		@scope.popup.open()
		return


	close: =>
		@scope.popup.close()
		return


	confirm: (text)=>
		@text = text
		@open()
		@activePromise?.reject()
		@activePromise = new Promise()
		return @activePromise


