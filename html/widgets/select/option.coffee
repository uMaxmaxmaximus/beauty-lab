module.exports = class Option

	@tag = 'option'
	@style = require './option.styl'

	@template = "
		<content></content> 
	"

	constructor: ->
		@self = @
		@select = @require('select')

		@select.addOption(@)
		@bindClass('__focus', 'select.focus')
		@bindClass('__active', 'self is select.activeOption')
		@initHandlers()
		return


	destructor: =>
		@select.removeOption(@)
		return


	initHandlers: =>
		@on('click', @onClick)
		return


	onClick: =>
		@select.userClick(@)
		return


