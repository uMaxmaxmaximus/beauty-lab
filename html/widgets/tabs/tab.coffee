module.exports = class Tab

	@tag = 'tab'
	@style = require './tab.styl'
	@template = "
		<content></content>
	"

	PREV: 1
	NEXT: 2
	ACTIVE: 3

	constructor: ->
		@status = @NEXT
		@active = false
		@tabs = @require('tabs')
		@bindClass('__prev', 'status is PREV')
		@bindClass('__next', 'status is NEXT')
		@bindClass('__active', 'status is ACTIVE')
		@tabs.add(@)
		return


	toPrev: =>
		@status = @PREV
		@active = false
		@emit('deactivate')
		return


	toNext: =>
		@status = @NEXT
		@active = false
		@emit('deactivate')
		return


	toActive: =>
		@status = @ACTIVE
		@active = true
		@emit('activate')
		return


	destructor: =>
		@tabs.remove(@)
		return


	activate: =>
		@tabs.activate(@)
		return


