module.exports = class TabTitle

	@tag = 'tab-title'
	@style = require './tab-title.styl'

	@template = "
		<content></content>
	"

	constructor: ->
		@tab = @require('tab')
		@on 'mousedown', (event) => event.prevent()
		@on 'click', => @tab.activate()
		@bindClass('__active', 'tab.status is tab.ACTIVE')
		return


