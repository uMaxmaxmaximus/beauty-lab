module.exports = class Text

	@tag = 'text'
	@style = require './text.styl'

	@template = "
		<label .container
		.__active='focused or value'
		.__error='activity and error'>

			<input #input .input .__focused='focused'
			[type]='type'
			[value]='value'
			(focus)='onFocus()'
			(blur)='onBlur()'>

			<div .label>
				<content></content>
			</div>

		</label>
	"

	constructor: ->
		@value = ''
		@type = 'text'
		@focused = false
		@error = false
		@activity = false
		@name = @host.attr('name')
		@form = @require('form?')
		@form?.addInput(@)
		@on('keydown', @onKeyDown)
		ui.watch(@, 'value', @valueChange)
		return


	destructor: =>
		@form?.removeInput(@)
		return


	onKeyDown: (event)=>
		if event.realEvent.keyCode == 13
			event.prevent()
			@form?.submit()
		return


	reset: =>
		input = @scope.input
		input.reset()
		@value = input.value
		return


	valueChange: (value)=>
		@value = value + ''
		@testValue(value)
		return


	testValue: (value)=>
		unless @test
			@error = false
		else if typeof @test is 'function'
			@error = not @test(value)
		else
			# regExp
			@error = not @test.test(value)
		return


	errorOn: =>
		@error = true
		return


	errorOff: =>
		@error = false
		return


	onFocus: =>
		@focused = true
		return


	onBlur: =>
		@activity = true
		@focused = false
		return



