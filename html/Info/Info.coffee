server = require '../core/server'
style = require './Info.styl'


module.exports = class Info

	@style = style

	@template = "
			<div .server-tasks .__show='server.tasks.length'></div>

			<div .server-connection-error *if='!server.connected'>
				Соединение с сервером разорвано, пробуем восстановить...
			</div>
	"

	constructor: ->
		@server = server
		return


