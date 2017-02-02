Button = require '../button/button'


module.exports = class Submit extends Button

	@tag = 'submit'

	constructor: ->
		super()
		@form = @require('form')
		@on 'click', => @form.submit()
		return






