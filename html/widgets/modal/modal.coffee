Popup = require '../popup/popup'


module.exports = class Modal extends Popup

	@tag = 'modal'


	getTransformFrom: (args...)=>
		to = super(args...)
		#		to.scaleY = 0
		to.scaleX = 0
		return to


	getTransformTo: (content, target, contentRect, targetRect)=>
		targetX = targetRect.left
		targetY = targetRect.top
		contentX = contentRect.left
		contentY = contentRect.top

		# TODO если справа сбоку то не влазит или если снизу не влазит

		x = -(contentX - targetX) + 20
		y = -(contentY - targetY) + targetRect.height + 20

		documentHeight = document.documentElement.clientHeight
		documentWidth = document.documentElement.clientWidth

		SCREEN_PADDING = 20

		if (documentWidth / 2) + x + contentRect.width >= documentWidth
			x = (documentWidth / 2) - (contentRect.width / 2) - SCREEN_PADDING

		return {x: x, y: y, scaleX: 1, scaleY: 1}



