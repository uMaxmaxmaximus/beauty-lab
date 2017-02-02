Event = require 'ui-js/dom/core/event'
keyboard = require 'ui-js/core/keyboard'


module.exports = class Popup

	@tag = 'popup'
	@style = require './popup.styl'

	@template = "
		<div .content #content>
			<content></content>
		</div>
	"

	constructor: ->
		@active = false
		@bindClass('__active', 'active')
		@bindClass('__non-active', '!active')
		@initHandlers()
		return


	initHandlers: =>
		#		keyboard.on('esc', @close)
		@on('mousedown', @onMouseDown)
		return


	onMouseDown: (event)=>
		targets = [
			@scope.content
			@scope.scale
			@host
		]

		if event.src in targets
			event.prevent()
			@close()
		return


	openEffect: (content, target)=>
		contentRect = @getContentRect(content)
		targetRect = @getTargetRect(target)

		from = @getTransformFrom(content, target, contentRect, targetRect)
		to = @getTransformTo(content, target, contentRect, targetRect)

		# start point
		@scope.content.renderCss
			transition: 'none'
			transform: "translate(#{from.x}px, #{from.y}px) scale(#{from.scaleX}, #{from.scaleY})"

		# play animation
		@scope.content.renderCss
			transition: ''
			transform: "translate(#{to.x}px, #{to.y}px) scale(#{to.scaleX}, #{to.scaleY})"
		return


	closeEffect: =>
		# play animation
		@scope.content.renderCss
			transition: ''
			transform: ''
		return


	getTransformTo: (content, target)=>
		return {x: 0, y: 0, scaleX: 1, scaleY: 1}


	getTransformFrom: (content, target, contentRect, targetRect)=>
		unless target
			return {x: 0, y: 0, scaleX: 0.5, scaleY: 0.5}

		targetX = targetRect.left + (targetRect.width / 2)
		targetY = targetRect.top + (targetRect.height / 2)
		contentX = contentRect.left + (contentRect.width / 2)
		contentY = contentRect.top + (contentRect.height / 2)
		x = targetX - contentX
		y = targetY - contentY
		scaleX = targetRect.width / contentRect.width
		scaleY = targetRect.height / contentRect.height

		return {x, y, scaleX, scaleY}


	getContentRect: (element)=>
		element.style.transform = 'none'
		element.style.transition = 'none'
		element.renderStyle()
		return element.rect()


	getTargetRect: (element)=>
		unless element then return {
			width: 0
			height: 0
			left: 0
			right: 0
			top: 0
			bottom: 0
		}
		return element.rect()


	open: =>
		if @active then return
		@active = on
		@target = Event.target
		@openEffect(@scope.content, @target)
		@emit('open')
		return


	close: =>
		unless @active then return
		@active = off
		@closeEffect()
		@emit('close')
		return


	toggle: =>
		if @active then @close()
		else @open()
		return


		


