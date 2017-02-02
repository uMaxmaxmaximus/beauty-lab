Checkbox = require '../checkbox/checkbox'

module.exports = class SetOption extends Checkbox

	@tag: 'set-option'

	@template = "
		<label .container .__active='state'>
			<div .checkbox></div>
			<div .label> <content></content> </div>
		</label>
	"

	constructor: ->
		@host.on('mousedown', @onMousedown)
		if @host.attrs.value
			@value = @host.attrs.value
		@state = false
		@set = @require('set')
		#TODO watch value
		@set.addOption(@)

		@on 'init', =>
			if @host.hasAttr('active')
				@activate()
		return


	destructor: =>
		@set.removeOption(@)
		return


	onMousedown: =>
		@toggle()
		return


	toggle: =>
		if @state
			@deactivate()
		else
			@activate()
		return


	activate: =>
		@state = true
		@set.add(@value)
		@host.addClass('__active')
		return


	deactivate: =>
		@state = false
		@set.delete(@value)
		@host.removeClass('__active')
		return
