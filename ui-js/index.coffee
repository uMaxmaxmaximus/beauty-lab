# polyfills
animationFrame = require('./polyfill/animation-frame')
immediate = require('./polyfill/immediate')

# core modules
Component = require('./core/component')
Directive = require('./core/directive')
keyboard = require('./core/keyboard')
Promise = require('./core/promise')
EventEmitter = require('./core/event-emitter')

# data bind
ArrayObserver = require('./data-bind/array-observer')
ExpObserver = require('./data-bind/exp-observer')
DataBind = require('./data-bind/data-bind')
Exp = require('./data-bind/exp')

# directives
Draggable = require('./directives/draggable')
Html = require('./directives/html')
Pre = require('./directives/pre')
For = require('./directives/for')
If = require('./directives/if')

# virtual dom
DOM = require('./dom')

# renderers
DOMRenderer = require('./renderers/dom-renderer')


# main module
module.exports = window['ui'] = class UI

	@EventEmitter = EventEmitter
	@Promise = Promise
	@directives = [Pre, For, If, Html, Draggable]
	@components = []
	@pipes = {}
	@dom = DOM
	@keyboard = keyboard
	@systemGlobals = Object.create(null)
	@globals = Object.create(@systemGlobals)

	@renderer = null
	@app = null


	@bootstrap: (MainComponent, Renderer = DOMRenderer, renderOptions)->
		@components = @components.map (Class)-> Component.create(Class)
		@directives = @directives.map (Class)-> Directive.create(Class)
		MainComponent = Component.create(MainComponent)
		host = DOM.createElement(MainComponent.tag or 'app')
		@renderer = new Renderer(host, renderOptions)
		MainComponent.init(host)
		@app = host.component
		@renderer.init()
		return @app


	@getRealNode: (node)->
		unless @renderer then return null
		return @renderer.getRealNode(node)


	@getVirtualNode: (realNode)->
		unless @renderer then return null
		return @renderer.getVirtualNode(realNode)


	@directive: (directive)->
		@directives.push(directive)
		return


	@component: (component)->
		@components.push(component)
		return


	@pipe: (name, pipe)->
		return Exp.addPipe(name, pipe)


	@global: (name, value)->
		return @globals[name] = value


	@watch: (context, exp, handler, scope, firstCall = on)->
		return new ExpObserver(context, exp, handler, scope, firstCall)


	@watchArray: (arr, handler)->
		return  new ArrayObserver(arr, handler)


	@diff: (arr, oldArr)->
		return ArrayObserver.diff(arr, oldArr)


	@bind: (objL, expL, objR, expR, scope)->
		return new DataBind(objL, expL, objR, expR, scope)


	@eval: (context, exp, scope)->
		exp = new Exp(exp)
		return exp(context, scope)


	@set: (context, exp, value, scope)->
		exp = new Exp(exp)
		return exp.set(context, value, scope)


	@frame: (handler, element)->
		return animationFrame(handler, element)


	@stopFrame: (id)->
		return animationFrame.stop(id)


	@immediate: (handler)->
		return immediate(handler)


	@timeout: (handler, time)->
		if typeof time is 'function'
			[handler, time] = [handler, time]
		return setTimeout(handler, time)


	@on: (event, handler)->
		return @dom.on(event, handler)


	@init: (handler)->
		@dom.on('DOMContentLoaded', handler)
		return


	@inited: new Promise (resolve)=>
		@init(resolve)


	@resize: (handler)->
		return @dom.on('resize', handler)


	@isAndroid: ->
		return Boolean navigator.userAgent.match /Android/i


	@isBlackBerry: ->
		return Boolean navigator.userAgent.match /BlackBerry/i


	@isIOS: ->
		return Boolean navigator.userAgent.match /iPhone|iPad|iPod/i


	@isOperaMini: ->
		return Boolean navigator.userAgent.match /Opera Mini/i


	@isWindowsPhone: ->
		return Boolean navigator.userAgent.match /IEMobile/i


	@isMobile: ->
		return Boolean @isAndroid() or @isBlackBerry() or @isIOS() or @isOperaMini() or @isWindowsPhone()



