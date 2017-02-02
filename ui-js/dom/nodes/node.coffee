EventEmitter = require('../../core/event-emitter')
MutationObserver = require('../core/mutation-observer')


module.exports = class Node extends EventEmitter

	Node.lastId = 0
	Node.createdNodes = {}


	constructor: ->
		super
		@destroyed = false
		@inited = false
		@nodeId = Node.lastId++
		@observer = null
		@parent = null
		@children = []
		Node.createdNodes[@nodeId] = @
		return


	observe: =>
		return @observer = new MutationObserver()


	init: ->
		if @inited then return
		@inited = true
		@emit('init')
		return


	destroy: =>
		if @destroyed then return
		@destroyed = true
		for child in @children then child.destroy()
		@shadowRoot?.destroy()
		@emit('destroy')
		return


	mutate: (type)->
		observer = @getObserver()
		observer?.mutate(@, type)
		return


	getObserver: ->
		node = @
		while node
			if node.observer
				return node.observer
			node = node.parent or node.host
		return null


	clone: ->
		throw Error 'Node clone is a pure virtual method'
		return


	remove: (needsDestroy = false)->
		if needsDestroy then @destroy()
		@parent?.removeChild(@)
		return


	getIndex: ->
		return @parent.getChildIndex(@)


	append: (node)->
		node.remove()
		node.parent = @
		@children.push(node)
		@mutate('changeChildren')
		return


	appendTo: (node)->
		node.append(@)
		return


	prepend: (node)->
		node.remove()
		node.parent = @
		@children.unshift(node)
		@mutate('changeChildren')
		return


	prependTo: (node)->
		node.append(@)
		return


	insertBefore: (relChild, node)->
		node.remove()
		node.parent = @
		index = relChild.getIndex()
		@children.splice(index, 0, node)
		@mutate('changeChildren')
		return


	before: (node)->
		@parent.insertBefore(@, node)
		return


	insertAfter: (relChild, node)->
		if node instanceof Array
			arr = node
			index = relChild.getIndex()
			@children.splice(index + 1, 0, arr...)
			for node in arr
				node.remove()
				node.parent = @
		else
			node.remove()
			node.parent = @
			index = relChild.getIndex()
			@children.splice(index + 1, 0, node)
		@mutate('changeChildren')
		return


	after: (node)->
		@parent.insertAfter(@, node)
		return


	replaceChild: (child, newChild)->
		index = child.getIndex()
		@children[index] = newChild
		child.parent = null
		newChild.parent = @
		@mutate('changeChildren')
		return


	replace: (newNode)->
		@parent.replaceChild(@, newNode)
		return


	empty: ->
		for child in @children.slice()
			@removeChild(child)
		return


	removeChild: (child)->
		index = child.getIndex()
		@children.splice(index, 1)
		child.parent = null
		@mutate('changeChildren')
		return


	getChildIndex: (node)->
		return @children.indexOf(node)


	hasChild: (node)->
		return node.parent is @


