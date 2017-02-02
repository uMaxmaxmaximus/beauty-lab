module.exports = class SetInput

	@style: require './set.styl'
	@tag: 'set'

	@template: "
		<content></content>
	"

	constructor: ->
		@value = new Set()
		@options = []
		@name = @host.attr('name')
		@form = @require('form?')
		@form?.addInput(@)
		@watch('value', @onValueChange)
		return


	destructor: =>
		@form?.removeInput(@)
		return


	addOption: (option)=>
		@options.push(option)
		return


	removeOption: (option)=>
		index = @options.indexOf(option)
		if index isnt -1
			@options.splice(index, 1)
		return


	onValueChange: =>
		for option in @options
			if @value.has(option.value)
				option.activate()
			else
				option.deactivate()
		return


	reset: =>
		for option in @options
			option.deactivate()
		return


	add: (val)=>
		return @value.add(val)


	delete: (val)=>
		return @value.delete(val)


	has: (val)=>
		return @value.has(val)


