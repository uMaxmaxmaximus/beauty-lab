Tree = require('../core/tree')
DOM = require('../dom')


module.exports = class If


	@attribute: 'if'
	@priority: 600
	@terminal: on


	@compile: (template, tree)->
		comment = DOM.createComment(' *if ')
		tree.replace(comment)
		exp = template.attr('*if')
		template.removeAttr('*if')
		subTree = tree.create(template)
		return [subTree, exp]


	constructor: (@label, @component, @scope, @subThree, exp)->
		@node = null
		@watcher = ui.watch(@component, exp, @changeState, @scope)
		return


	destructor: ->
		@watcher.destroy()
		return


	changeState: (state)=>
		if state then @create()
		else @destroy()
		return


	create: ->
		if @node then return
		@node = @subThree.template.clone()
		@label.after(@node)
		@subThree.init(@node, @component, @scope)
		return


	destroy: ->
		unless @node then return
		@node.remove(yes)
		@node = null
		return

