module.exports = class Select

	@tag = 'select'
	@style = require './select.styl'

	@template = "
		<select .select .__selected='index != 0' #select (change)='onChange()'>
			<option disabled selected>- {{ host.attrs.label or 'Выберите' }} -</option>
			<content></content>
		</select>
	"

	constructor: ->
		@value = undefined
		@option = undefined
		@index = 0

		@name = @host.attr('name')
		@form = @require('form?')
		@form?.addInput(@)

		@inited = false
		@on('init', @onInit)
		@watch('value', @setOptionByValue)

		@interval = setInterval(@setOptionByValue, 100)
		return


	destructor: =>
		@form?.removeInput(@)
		clearInterval(@interval)
		return


	onInit: =>
		@inited = true
		@setOptionByValue()
		return


	reset: =>
		realSelect = @scope.select.realNode
		realSelect.selectedIndex = 0
		@index = 0
		@option = undefined
		@value = undefined
		return


	onChange: =>
		realNode = @scope.select.realNode
		selectedIndex = realNode.selectedIndex
		realOption = realNode.children[selectedIndex]
		option = ui.getVirtualNode(realOption)
		@index = selectedIndex
		@value = option.value
		@option = option.option
		return


	setOptionByValue: =>
		console.log 'setOptionByValue'
		unless @inited then return
		index = @getIndexByValue(@value)
		realSelect = @scope.select.realNode
		realSelect.selectedIndex = index
		@index = index
		return


	getIndexByValue: (value)=>
		realSelect = @scope.select.realNode
		realOptions = realSelect.children
		for realOption, index in realOptions
			option = ui.getVirtualNode(realOption)
			if option.value is value then return index
		return 0


