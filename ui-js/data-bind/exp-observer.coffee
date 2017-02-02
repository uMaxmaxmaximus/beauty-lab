PathObserver = require('./path-observer')
Exp = require('./exp')


equals = (a, b)->
	if (a isnt a) and (b isnt b) # NaN
		return true
	return a is b


module.exports = class ExpObserver

	constructor: (@context, @exp, @handler, @scope = null, @needsInit = off)->
		@exp = new Exp(@exp)
		@value = undefined
		@destroyed = false
		@subExps = @getSubExps()
		@subExpObservers = @createSubExpObservers()
#		@watchPromisesInSubExps()

		if @needsInit
			@value = @evalExp()
			@handler(@value)
		return


	destroy: ->
		if @destroyed then return
		for subExpObserver in @subExpObservers
			subExpObserver.destroy()
		@destroyed = true
		return


	getSubExps: ->
		return [@exp]
	#		if @exp.isStringExp
	#			return @exp.codeParts.map (codePart)=> new Exp(codePart)
	#		else
	#			return [@exp]


	createSubExpObservers: ->
		return @subExps.map (subExp)=>
			return @createSubExpObserver(subExp)


	createSubExpObserver: (subExp)->
		return new SubExpObserver @context, @scope, subExp, (value)=>
#			@initPromiseObserver(value)
			@trigger()
			return


	#	watchPromisesInSubExps: ->
	#		for subExp in @subExps
	#			value = subExp(@context, @scope)
	#			@initPromiseObserver(value)
	#		return
	#
	#
	#	initPromiseObserver: (value)->
	#		if value instanceof Promise
	#			console.log 'watch observer'
	#			value.then (promiseValue)=>
	#				value.$$value = promiseValue
	#				console.log 'observer can', value.$$value
	#				console.log 'new value', @evalExp()
	#
	#				@trigger()
	#		return


	evalExp: ->
		return @exp(@context, @scope)


	trigger: ->
		newValue = @evalExp()
		#		unless equals newValue, @value
		@value = newValue
		@handler(@value)
		return


# обсервер обычных выражений, а не только строковых
class SubExpObserver

	constructor: (@context, @scope, @exp, @handler)->
		@exp = new Exp(@exp)
		@destroyed = false
		@observers = []

		for path in @exp.paths
			@observers.push(@createObserver(@context, path))
			if @scope then @observers.push(@createObserver(@scope, path))
		return


	evalExp: ->
		return @exp(@context, @scope)


	createObserver: (context, path)->
		return new PathObserver context, path, =>
			newValue = @evalExp()
			unless equals newValue, @value
				@value = newValue
				@handler(@value)
			return


	destroy: ->
		if @destroyed then return
		for observer in @observers
			observer.destroy()
		@destroyed = true
		return

