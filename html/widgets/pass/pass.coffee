Text = require '../text/text'


module.exports = class Pass extends Text

	@tag = 'pass'

	constructor: ->
		super()
		@type = 'password'
		@min = 3
		return


	test: (value)=>
		return value.length >= @min


