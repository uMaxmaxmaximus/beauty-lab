module.exports = class File

	@tag = 'file'
	@style = require './file.styl'

	@template = "
		<button .button>

			<input #input .input type='file'
				(change)='onChange()'
				[multiple]='multiple'
				[value]='value'>
			</input>

			<div .label *if='not fileInfo'>
				<content></content>
			</div>

			<div .info *if='fileInfo'>
				<div .controls>
					<span .reset (!mousedown) (click)='reset()'></span>
				</div>
			  <span .name>{{ fileInfo.name }}</span>
			</div>
		
		</button>
	"

	constructor: ->
		@multiple = @host.hasAttr('multiple')
		@fileInfo = null
		@name = @host.attr('name')
		@form = @require('form?')
		@form?.addInput(@)
		return


	destructor: =>
		@form?.removeInput(@)
		return


	onChange: =>
		unless @value.length
			@fileInfo = null
		else
			firstFile = @value[0]
			@fileInfo = {name: firstFile.name}
		return


	reset: =>
		@scope.input.reset()
		return


