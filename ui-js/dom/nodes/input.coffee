Element = require('./element')


module.exports = class Input extends Element


	Object.defineProperty @prototype, 'type',
		set: (type)-> @setType(type)
		get: -> @type_
		configurable: on


	Object.defineProperty @prototype, 'value',
		set: (value)-> @setValue(value)
		get: -> @value_
		configurable: on


	Object.defineProperty @prototype, 'multiple',
		set: (value)-> @setMultiple(value)
		get: -> @multiple_
		configurable: on


	constructor: ->
		super
		@value = ''
		@type = @attr('type')
		@multiple_ = @attr('multiple')
		return


	setMultiple: (value)->
		@multiple_ = Boolean(value)
		if @multiple_ then @attr('multiple', 'true')
		else @removeAttr('multiple')
		return


	reset: ->
		@setDefaultValue_()
		@mutate('changeInput')
		return


	setDefaultValue_: ->
		switch @type_
			when 'text' then @value = ''
			when 'password' then @value = ''
			when 'checkbox' then @value = false
			when 'file'
				if @value_ instanceof Array
					@value_.splice(0, @value_.length)
				else
					@value_ = []
				@value = @value_

		return


	normalizeType_: (type)->
		unless type in ['text', 'password', 'checkbox', 'file']
			type = 'text'
		return type


	setType: (type)->
		@type_ = @normalizeType_(type)
		@setDefaultValue_()
		@attr('type', @type_)
		return


	setValueFromRealNode: (realNode)->
		if realNode.type is 'file'
			@value_.splice(0, @value_.length, realNode.files...)
		else if realNode.type is 'checkbox'
			@value = realNode.checked
		else
			@value = realNode.value
		return


	setValue: (value)->
		switch @type_
			when 'checkbox' then @value_ = Boolean(value)
			when 'file' then return
			else
				@value_ = String(value)
		@mutate('changeInput')
		return


	append: ->
		throw Error '<input> element cannot have child nodes'
		return


	prepend: ->
		throw Error 'input element cannot have children'
		return

		