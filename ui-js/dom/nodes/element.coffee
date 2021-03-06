Node = require('./node')
Selector = require('../core/selector')
ExpObserver = require('../../data-bind/exp-observer')
Style = require('../core/style')


module.exports = class Element extends Node


	constructor: (tag, attrs)->
		super
		@tag = tag.toLowerCase()
		@nodeType = 'element'
		@style = new Style(@)
		@attrs = {}
		@attrNames = []
		@classes = []
		@shadowRoot = null
		if attrs then @attr(attrs)
		return


	Object.defineProperty @prototype, 'realNode',
		get: -> ui.getRealNode(@)


	calcStyle: ->
		unless @realNode then return null
		return getComputedStyle(@realNode)


	toEm: (px)->
		style = @calcStyle()
		unless style then return 0
		fontSize = parseFloat(style.fontSize)
		return px / fontSize


	toPx: (em)->
		style = @calcStyle()
		unless style then return 0
		fontSize = parseFloat(style.fontSize)
		return em * fontSize


	renderStyle: ->
		unless @realNode then return null
		style = @style.toString()
		@realNode.setAttribute('style', style)
		@realNode.offsetHeight
		return


	own: (eventName, handler)->
		@on eventName, (event)->
			if event.own then handler(event)
			return
		return


	width: (toEm = off)->
		unless @realNode then return 0
		width = @realNode.offsetWidth
		width = @toEm(width) if toEm
		return width


	height: (toEm = off)->
		unless @realNode then return 0
		height = @realNode.offsetHeight
		height = @toEm(height) if toEm
		return height


	rect: ->
		unless @realNode
			return {
				width: 0
				height: 0
				left: 0
				right: 0
				top: 0
				bottom: 0
			}

		rect = @realNode.getBoundingClientRect()
		return {
			width: rect.width
			height: rect.height
			left: rect.left
			right: rect.right
			top: rect.top
			bottom: rect.bottom
		}



	bindClass: (className, exp, context, scope)->
		return new ExpObserver context, exp, (value)=>
			if value then @addClass(className)
			else @removeClass(className)
		, scope, yes


	addClass: (className)->
		unless className in @classes
			@classes.push(className)
			@attr 'class', @classes.join(' ')
		return


	removeClass: (className)->
		index = @classes.indexOf(className)
		if index isnt -1
			@classes.splice(index, 1)
			if @classes.length
				@attr 'class', @classes.join(' ')
			else
				@removeAttr('class')
		return


	hasClass: (className)->
		return @classes.indexOf(className) isnt -1


	toggleClass: (className)->
		if @hasClass(className)
			@removeClass(className)
		else
			@addClass(className)
		return


	css: (rules)->
		if arguments.length is 2
			@style[arguments[0]] = arguments[1]
			return
		for own prop, value of rules
			@style[prop] = value
		return


	renderCss: (args...)->
		@css(args...)
		@renderStyle()
		return


	attr: (name, value)->
		if arguments.length is 1
			if typeof name isnt 'object'
				return @attrs[name]
			for key, value of name
				@attr(key, value)
			return

		@attrs[name] = value

		index = @attrNames.indexOf(name)
		if index is -1 then @attrNames.push(name)
		if name is 'class' then @classes = (value + '').split(/\s+/)
		@mutate('changeAttrs')
		return value


	hasAttr: (name)->
		return @attrs.hasOwnProperty(name)


	removeAttr: (name)->
		delete @attrs[name]
		index = @attrNames.indexOf(name)
		if index isnt -1 then @attrNames.splice(index, 1)
		if name is 'class' then @classes = []
		@mutate('changeAttrs')
		return


	eachAttrs: (handler)->
		for attrName in @attrNames
			handler(attrName, @attrs[attrName])
		return


	clone: ->
		element = new @constructor(@tag, @attrs)
		for child in @children
			element.append(child.clone())
		if @shadowRoot
			element.shadowRoot = @shadowRoot.clone(element)
		return element


	html: (html)->
		if html instanceof Array
			newChildren = html
		else
			Dom = require('../index')
			newChildren = Dom.parse(html)

		@empty()
		for child in newChildren.slice()
			@append(child)
		return


	createShadowRoot: (shadowId)->
		@shadowRoot?.destroy()
		@shadowRoot = new ShadowRoot(@, shadowId)
		return @shadowRoot


	select: (selector)->
		return new Selector(selector).select(@)


	selectOne: (selector)->
		return @select(selector)[0]


class ShadowRoot extends Element

	constructor: (@host, @shadowId = Math.random().toString().slice(2))->
		super '[[shadow-root]]'
		return


	clone: (host)->
		shadowRoot = new ShadowRoot(host, @shadowId)
		for child in @children
			shadowRoot.append(child.clone())
		return shadowRoot


		