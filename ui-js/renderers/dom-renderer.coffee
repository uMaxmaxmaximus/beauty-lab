frame = require('../polyfill/animation-frame')
Event = require('../dom/core/event')
HTMLRenderer = require('./html-renderer')
Selection = require('../core/selection')
ArrayObserver = require('../data-bind/array-observer')
DOM = require('../dom')


mouseEventNames = ['mousedown', 'mousemove', 'mouseup', 'click']
touchEventNames = ['touchstart', 'touchmove', 'touchend']

allEventNames = [mouseEventNames..., touchEventNames...]

Object.getOwnPropertyNames(Document.prototype).forEach (key)=>
	if key.indexOf('on') isnt 0 then return
	eventName = key.slice(2)
	if eventName in allEventNames then return
	allEventNames.push(eventName)
	return


module.exports = class DOMRenderer


	constructor: (@root, @targetRoot = document.body)->
		@selection = new Selection()
		@observer = @root.observe()
		@isMobile = !!ui.isMobile()
		@lastTouchRealNode = null
		@startTouchRealNode = null
		return


	init: =>
		@targetRoot.innerHTML = HTMLRenderer.render(@root)
		@initEventHandlers()
		@initNode(@root)
		@frame()
		return


	frame: =>
		ui.frame(@frame)
		if @observer.hasMutations()
			@selection.save()
			#			console.time 'mutations'
			@onMutations(@observer.getMutations())
			#			console.timeEnd 'mutations'
			@selection.restore()
		return


	onMutations: (mutations)=>
		for node in @needsToUpdateHTML(mutations)
			@updateInnerHTML(node)
			@initNode(node)

		mutations.forEach (mutation, node)=>
			if mutation.changeAttrs
				@updateAttrs(node)
			if mutation.changeInput
				@updateInput(node)
		return


	needsToUpdateHTML: (mutations)=>
		nodes = []

		mutations.forEach (mutation, node)=>
			if not mutation.changeChildren and node.nodeType isnt 'text'
				return
			if node.nodeType is 'text'
				node = node.parent
			if node.tag is '[[shadow-root]]'
				node = node.host
			nodes.push(node)
			return

		nodes = nodes.filter (node)=>
			context = node.parent or node.host
			while context
				if context in nodes
					return false
				context = context.parent or context.host
			return true

		unique = []
		nodes.forEach (node)=>
			if unique.indexOf(node) is -1
				unique.push(node)
			return

		return unique


	updateInnerHTML: (node)=>
		realNode = @getRealNode(node)
		unless realNode then return

		newNode = document.createElement('div')
		newNode.innerHTML = HTMLRenderer.renderInnerHTML(node)
		@syncChildren(realNode, newNode)
		return


	syncChildren: (oldNode, newNode)=>
		newChildNodes = [].slice.call(newNode.childNodes)

		splices = @getSplices(oldNode, newNode)
		for splice in splices
			@renderSplice(splice, oldNode, newNode)

		for child, index in oldNode.childNodes
			if child in newChildNodes then continue
			@syncChildren(child, newChildNodes[index])
		return



	renderSplice: (splice, oldNode, newNode)=>
		newChildNodes = [].slice.call(newNode.childNodes)
		oldChildNodes = [].slice.call(oldNode.childNodes)

		for index in [splice.index...splice.index + splice.removed.length]
			oldNode.removeChild(oldChildNodes[index])

		fragment = document.createDocumentFragment()
		for index in [splice.index...splice.index + splice.addedCount]
			fragment.appendChild(newChildNodes[index])
		oldNode.insertBefore(fragment, oldNode.childNodes[splice.index])
		return


	getSplices: (oldNode, newNode)=>
		oldChildren = [].slice.call(oldNode.childNodes).map(@_toUniqueString)
		newChildren = [].slice.call(newNode.childNodes).map(@_toUniqueString)
		return ArrayObserver.diff(newChildren, oldChildren)


	_toUniqueString: (realNode)=>
		prefix = String(realNode.nodeType)
		if realNode.nodeType is 1
			return prefix + realNode.id
		else
			return prefix + realNode.nodeValue


	updateAttrs: (node)=>
		realNode = @getRealNode(node)
		unless realNode then return

		#add attrs
		node.eachAttrs (name, value)=>
			unless /^\w/.test(name) then return
			realNode.setAttribute(name, value)

		# remove attrs
		for attribute in [].slice.call(realNode.attributes)
			attrName = attribute.name
			unless node.hasAttr(attrName)
				unless /^((c|h)\d+)|id$/.test(attrName)
					realNode.removeAttribute(attrName)
		return


	updateInput: (node)=>
		realNode = @getRealNode(node)
		if realNode.type is 'file'
			if node.value.length is 0
				realNode.type = ''
				realNode.type = 'file'
		else if realNode.type is 'checkbox'
			realNode.checked = node.value
		else
			realNode.value = node.value
		return


	initEventHandlers: =>
		['input', 'change'].forEach (eventName)=>
			@targetRoot.addEventListener eventName, (event)=>
				@updateVirtualInput(eventName, event.target)
			, true

		allEventNames.forEach (eventName)=>
			@targetRoot.addEventListener eventName, (realEvent)=>
				@onDOMEvent(eventName, realEvent)
			, true
		return


	onDOMEvent: (eventName, realEvent)=>
		if eventName in touchEventNames
			@isMobile = true #force enable mobile mode

		unless @isMobile
			@emitVirtualEvent(eventName, realEvent, realEvent.target)
			return

		# заглушим эмулируемые мобилой события мышки
		if eventName in mouseEventNames then return

		if eventName not in touchEventNames
			@emitVirtualEvent(eventName, realEvent, realEvent.target)
			return

		switch eventName
			when 'touchstart'
				touch = realEvent.touches[0]
				realNode = touch.target
				@lastTouchRealNode = realNode
				@lastTouchRealEvent = realEvent
				@startTouchRealNode = realNode
				emulatedEvent = @touchToMouseEvent(touch, 'mousedown')
				@emitVirtualEvent('mousedown', emulatedEvent, realNode)
				if emulatedEvent.defaultPrevented
					realEvent.preventDefault()

			when 'touchmove'
				touch = realEvent.touches[0]
				realNode = document.elementFromPoint(touch.clientX, touch.clientY)
				unless realNode then return
				@lastTouchRealNode = realNode
				@lastTouchRealEvent = realEvent
				emulatedEvent = @touchToMouseEvent(touch, 'mousemove')
				@emitVirtualEvent('mousemove', emulatedEvent, realNode)
				if emulatedEvent.defaultPrevented
					realEvent.preventDefault()

			when 'touchend'
				realNode = @lastTouchRealNode
				lastTouch = @lastTouchRealEvent.touches[0]
				emulatedEvent = @touchToMouseEvent(lastTouch, 'mouseup')
				@emitVirtualEvent('mouseup', emulatedEvent, realNode)
				if emulatedEvent.defaultPrevented
					realEvent.preventDefault()

				# if click
				if @touchEndOnTheSameNode()
					emulatedEvent = @touchToMouseEvent(lastTouch, 'click')
					@emitVirtualEvent('click', emulatedEvent, realNode)
					if emulatedEvent.defaultPrevented
						realEvent.preventDefault()
		return


	touchToMouseEvent: (touch, eventName)=>
		mouseEvent = document.createEvent('MouseEvent')
		mouseEvent.initMouseEvent(eventName, true, true, window,
			0, touch.screenX, touch.screenY, touch.clientX, touch.clientY,
			false, false, false, false,
			0, null)
		return mouseEvent


	touchEndOnTheSameNode: =>
		context = @lastTouchRealNode
		while context
			if @startTouchRealNode is context
				return true
			context = context.parentNode
		return false


	emitVirtualEvent: (eventName, realEvent, realNode)=>
		srcNode = @getVirtualNode(realNode)

		while realNode and node = @getVirtualNode(realNode)
			if node.hasEventHandlers(eventName)
				event = Event.emit(eventName, srcNode, node, realEvent)
				if event.prevented
					realEvent.preventDefault()
				if event.stopped
					realEvent.stopPropagation()
					break
			realNode = realNode.parentNode
		return


	updateVirtualInput: (eventName, realNode)=>
		if eventName is 'change' and realNode.type not in ['file', 'checkbox']
			return
		node = @getVirtualNode(realNode)
		node.setValueFromRealNode?(realNode)
		return


	initNode: (node)=>
		unless @getRealNode(node) then return
		node.init()
		if node.shadowRoot
			for child in node.shadowRoot.children
				@initNode(child)
		for child in node.children
			@initNode(child)
		return


	getRealNode: (virtualNode)=>
		return document.getElementById(virtualNode.nodeId)


	getVirtualNode: (realNode)=>
		return DOM.getById(realNode.id)




