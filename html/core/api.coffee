module.exports = class API

	@server = require('./server')
	@apiName = ''

	@call: (method, params = {})->
		return @server.call("#{@apiName}.#{method}", params)



