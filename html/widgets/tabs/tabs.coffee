module.exports = class Tabs

	@tag = 'tabs'
	@style = require './tabs.styl'

	@template = "
		<div .header>
			<div .titles>
				<content select='tab > tab-title'></content>
			</div>

			<content select='tab-tray'></content>
		</div>

		<div .content>
			<content></content>
		</div>
	"

	constructor: ->
		@tabs = []
		return


	add: (tab)=>
		@tabs.push(tab)
		if @tabs.length is 1
			@activateByIndex(0)
		return


	remove: (tab)=>
		index = @tabs.indexOf(tab)
		if index isnt -1
			@tabs.splice(index, 1)
		@activateByIndex(index - 1)
		return


	activate: (targetTab)=>
		targetIndex = @tabs.indexOf(targetTab)
		@activateByIndex(targetIndex)
		return


	activateByIndex: (targetIndex)=>
		targetIndex = Math.max(targetIndex, 0)
		targetIndex = Math.min(targetIndex, @tabs.length - 1)

		for tab, index in @tabs
			if index < targetIndex
				tab.toPrev()
			else if index > targetIndex
				tab.toNext()
			else
				tab.toActive()
		return



