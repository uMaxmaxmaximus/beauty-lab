Text = require '../text/text'


module.exports = class Email extends Text

	@tag: 'email'
	test: /^.+@.+$/im




