module.exports = class Checkbox

	@tag = 'checkbox'
	@style = require './checkbox.styl'

	@template = "
		<label .container .__active='value'>
			<div .checkbox></div>
			<div .label> <content></content> </div>
		</label>
	"

	constructor: ->
		@value = false
		@host.on('mousedown', @onMousedown)
		@name = @host.attr('name')
		@form = @require('form?')
		@form?.addInput(@)
		return


	destructor: =>
		@form?.removeInput(@)
		return


	onMousedown: (event)=>
		event.prevent()
		@toggle()
		return

	reset: =>
		@value = false
		return


	toggle: =>
		@value = !@value
		return


