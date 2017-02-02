{SourceMapConsumer, SourceNode} = require 'source-map'


module.exports = (source, map)->
	@cacheable?()

	exceptRegExp = /[\\/]webpack[\\/]buildin[\\/]module\.js|[\\/]ui-js-loader[\\/]/

	if exceptRegExp.test(@resourcePath)
		return @callback(null, source, map)

	separator = '\n\n'
	appendText = "if(module.hot){
		require(#{JSON.stringify(require.resolve('./hot-loader')) }).patch(module)
	};"


	if @sourceMap is false
		code = [source, appendText].join(separator)
		return @callback(null, code)


	node = new SourceNode(null, null, null, [
		SourceNode.fromStringWithSourceMap(source, new SourceMapConsumer(map))
		new SourceNode(null, null, @resourcePath, appendText)
	]).join(separator)


	result = node.toStringWithSourceMap()
	codeMap = result.map.toString()
	code = result.code

	@callback(null, code, codeMap)



