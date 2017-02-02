DOM = require 'ui-js/dom'


module.exports = class Button

	@tag = 'button'
	@style = require './button.styl'

	@template = "
		<div .content
		.__left='state is LEFT'
		.__right='state is RIGHT'
		.__bottom='state is BOTTOM'
		.__top='state is TOP'>
			<div .shadow .__shadow-left></div>
			<div .shadow .__shadow-right></div>
			<div .shadow .__shadow-bottom></div>
			<div .shadow .__shadow-top></div>

			<content></content>
		</div>
	"

	NONE: 0
	LEFT: 1
	RIGHT: 2
	BOTTOM: 3
	TOP: 4


	constructor: ->
		@state = @NONE
		@on('mousedown', @onMouseDown)
		@on('mousemove', @onMouseMove)
		@on('click', @onClick)
		@active = false
		return


	onClick: (event)=>
		event.stop()
		return


	onMouseDown: (event)=>
		event.prevent()
		document.activeElement.blur()

		@active = true
		@tiltEffect(event.layerX, event.layerY)

		ui.app.one 'mouseup', =>
			@active = false
			@offTiltEffect()
		return


	onMouseMove: (event)=>
		unless @active then return
		@tiltEffect(event.layerX, event.layerY)
		return


	tiltEffect: (x, y)=>
		width = @host.width()
		height = @host.height()

		states = []
		states.push({state: @TOP, distance: y / height})
		states.push({state: @BOTTOM, distance: (height - y) / height})
		states.push({state: @LEFT, distance: x / width})
		states.push({state: @RIGHT, distance: (width - x) / width})

		minState = states[0]
		for state in states
			if state.distance < minState.distance
				minState = state

		@state = minState.state
		return


	offTiltEffect: =>
		@state = @NONE
		return

