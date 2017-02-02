ui = require 'ui-js'
Map = require 'ui-js/polyfill/map'
File = require '../file/file'


module.exports = class Form

	@tag = 'form'
	@style = require './form.styl'

	@template = "
		<content></content>
	"

	constructor: ->
		@value = {}
		@inputs = new Map()
		@inputsByName = {}
		return


	focus: =>
		# TODO сделать нормальный фокус через виртуал дом
		input = @host.realNode.querySelector('input')
		input?.focus()
		return


	has: (name, errorMessage)=>
		if @inputIsEmpty(name)
			if errorMessage
				@app.error(errorMessage)
				throw new Error(errorMessage)
			return false
		return true


	inputIsEmpty: (name)=>
		input = @inputsByName[name]
		value = input.value
		if input instanceof File
			return value.length is 0
		return value == null


	addInput: (input)=>
		name = input.name
		unless name then throw new Error 'input without "name" attribute'
		dataBind = ui.bind(@value, name, input, 'value')
		@inputsByName[name] = input
		@inputs.set(input, dataBind)
		return


	removeInput: (input)=>
		dataBind = @inputs.get(input)
		name = input.name
		dataBind.destroy()
		@inputs.delete(input)
		delete @inputsByName[name]
		delete @value[name]
		return


	reset: =>
		@inputs.forEach (dataBind, input)=> input.reset()
		@emit('reset', @value)
		return


	set: (data)=>
		@inputs.forEach (dataBind, input)=>
			input.value = data[input.name]
		return


	submit: =>
		@emit('submit', @value)
		return


	toJSON: =>
		return @value



		