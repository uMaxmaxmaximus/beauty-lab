Text = require '../text/text'


module.exports = class Textarea extends Text

	@tag = 'textarea'
	@style = require './textarea.styl'

	@template = "
		<label .container
			.__active='focused or value'
			.__error='activity and error'>

			<div .label>
				<content></content>
			</div>

			<textarea .textarea
				[type]='type'
				[value]='value'
				(focus)='onFocus()'
				(blur)='onBlur()'>
			</textarea>

		</label>
	"

	onKeyDown: (event)=>
		if event.realEvent.ctrlKey and event.realEvent.keyCode == 13
			this.form.submit()
		return




