module.exports = class Gallery

	@tag = 'gallery'
	@style = require './gallery.styl'

	@template = "
		<popup .popup #popup (close)='onPopupClose()'>

			<div .photo .__dragging='dragging' 
			[style.transform]='translate({{x}}px, {{y}}px)'>
	
				<div .photo-zoom
				[style.transform]='scale({{zoom}})'>
	
					<img .img #img *draggable
					(wheel)='onWheel($event)'
					(drag)='drag($event)'
					(drag-start)='dragStart()'
					(drag-end)='dragEnd()'
					(mousedown)='onMouseDown($event)'
					(mouseup)='onMouseUp($event)'
					[src]='activeUrl'>
					</img>
	
				</div>
			</div>
			
		</popup>


		<div .panel *if='morOne' (wheel)='onPanelWheel($event)'>
			<ul .previews [style.transform]='translateX({{ -previewsX }}em)'>

				<li .preview
					*for='url, index in urls'
					[style.backgroundImage]='url({{ url }})'
					(click)='activateByIndex(index)'>
				</li>

			</ul>
		</div>
	"

	constructor: ->
		@urls = []
		@morOne = false
		@previewsX = 0

		@x = 0
		@y = 0
		@zoom = 1
		@activeUrl = ''

		@minZoom = 0.5
		@maxZoom = 20
		@zoomStep = 0.25
		@dragging = false

		@active = false
		@bind('active', 'scope.popup.active')
		@bindClass('__active', 'scope.popup.active')

		@initHandlers()
		@activateByIndex(0)
		return


	initHandlers: =>
		ui.keyboard.on('left', @prev)
		ui.keyboard.on('right', @next)
		ui.keyboard.on('up', => @active && @zoomIn())
		ui.keyboard.on('down', => @active && @zoomOut())
		ui.keyboard.on('space', => @active && @reset())
		return


	onMouseDown: (event)=>
		@clientX = event.clientX
		@clientY = event.clientY
		return


	onMouseUp: (event)=>
		if @clientX isnt event.clientX then return
		if @clientY isnt event.clientY then return
		@reset()
		return


	dragStart: =>
		@dragging = true
		return


	dragEnd: =>
		@dragging = false
		return


	drag: (event)=>
		@x += event.moveX
		@y += event.moveY
		return


	onWheel: (event)=>
		toUp = event.realEvent.deltaY < 0
		if toUp then @zoomIn(event)
		else @zoomOut(event)
		return


	zoomIn: (event)=>
		@setZoom(@zoom + @zoom * @zoomStep, event)
		return


	zoomOut: (event)=>
		@setZoom(@zoom - @zoom * @zoomStep, event)
		return


	setZoom: (zoom, event)=>
		oldZoom = @zoom
		newZoom = Math.max(Math.min(zoom, @maxZoom), @minZoom)

		rect = @host.rect()
		width = rect.width
		height = rect.height

		if event
			point = event.relative(@host)
			x = (point.x - @x) / (width * oldZoom)
			y = (point.y - @y) / (height * oldZoom)
		else
			x = ((width / 2) - @x) / (width * oldZoom)
			y = ((height / 2) - @y) / (height * oldZoom)

		x = Math.max(Math.min(x, 1), 0)
		y = Math.max(Math.min(y, 1), 0)

		widthDiff = (width * newZoom) - (width * oldZoom)
		heightDiff = (height * newZoom) - (height * oldZoom)
		@x -= widthDiff * x
		@y -= heightDiff * y

		@zoom = newZoom
		return


	setPosition: (point)=>
		@x = point.x
		@y = point.y
		return


	open: (urls = [])=>
		@scope.popup.open()
		@urls = urls
		@morOne = urls.length > 0
		@activateByIndex(0)
		return


	close: =>
		@scope.popup.close()
		@reset()
		return


	onPopupClose: =>
		@reset()
		return


	onPanelWheel: (event)=>
		if event.realEvent.deltaY > 0 then @next()
		else @prev()
		return


	next: =>
		index = @getActiveIndex()
		@activateByIndex(index + 1)
		return


	prev: =>
		index = @getActiveIndex()
		@activateByIndex(index - 1)
		return


	getActiveIndex: =>
		return @urls.indexOf(@activeUrl)


	activateByIndex: (index)=>
		index = Math.max(Math.min(index, @urls.length - 1), 0)
		@activeUrl = @urls[index]
		@previewsX = index * 3.2
		@reset()
		return


	reset: =>
		# @setZoom(1)
		@zoom = 1
		@x = 0
		@y = 0
		return


