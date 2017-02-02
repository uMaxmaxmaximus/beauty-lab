Node = require('./node')


module.exports = class Comment extends Node


	Object.defineProperty @prototype, 'value',
		get: -> @value_
		set: (value)-> @setValue(value)


	constructor: (@value_ = '')->
		super
		@nodeType = 'comment'
		return


	setValue: (value)->
		@value_ = value + ''
		return


	clone: ->
		return new @constructor(@value)



