Text = require '../text/text'


module.exports = class Phone extends Text

	@tag = 'phone'

	test: (value)=>
		numbers = value.match(/\d/img)
		unless numbers then return false
		return numbers.length >= 10

