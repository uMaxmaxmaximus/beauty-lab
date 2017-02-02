Component = require 'ui-js/core/component'


module.exports = class ComponentPatcher

	@allWrappers = []


	@test: (target)->
		if typeof target isnt 'function' then return false
		return ('selector' of target) or ('template' of target)


	@patch: (Class, module)->
		#		try
		if module.hot.data
			Wrapper = module.hot.data.wrapper
			Wrapper.__setClass(Class)
		else
			Wrapper = @createWrapper(Class)

		module.hot.dispose (data)=> data.wrapper = Wrapper
		module.hot.accept()
		#		catch e
		#			console.error(e)
		return Wrapper



	@createWrapper: (Class)->
		# to save original name
		Wrapper = eval("(function #{Class.name} () {
			return Wrapper.__activeClass.apply(this, arguments)
		})")

		@allWrappers.push(Wrapper)

		Wrapper.__oldStyle = null
		Wrapper.__oldTemplate = null
		Wrapper.__oldLogic = null
		Wrapper.__oldComponents = null
		Wrapper.__oldTag = null
		Wrapper.__activeClass = null
		Wrapper.__oldActiveClass = null


		Wrapper.toString = ->
			return @__activeClass?.toString() or ''


		Wrapper.__setClass = (Class)->
			@__oldActiveClass = @__activeClass
			@__activeClass = Class

			templateHasDiff = @__checkTemplate(Class)
			componentsHasDiff = @__checkComponents(Class)
			styleHasDiff = @__checkStyle(Class)
			logicHasDiff = @__checkLogic(Class)
			tagHasDiff = @__checkTag(Class)

			inherits = @__getInherits()
			@__copyPropsFrom(Class)

			if tagHasDiff
				throw new Error('Component tag changed, reloading page...')
			if logicHasDiff or componentsHasDiff
				@__reload(inherits)
			else
				if styleHasDiff then @__reloadStyle(inherits)
				if templateHasDiff then @__reloadTemplate(inherits)
			return


		Wrapper.__reload = (inherits)->
			@reload()
			for inherit in inherits then inherit.reload()
			return


		Wrapper.__reloadTemplate = (inherits)->
			@reloadTemplate()
			for inherit in inherits then inherit.reloadTemplate()
			return


		Wrapper.__reloadStyle = (inherits)->
			@reloadStyle()
			for inherit in inherits then inherit.reloadStyle()
			return


		Wrapper.__getInherits = (SuperWrapper = @, inherits = [])->
			for Wrap in ComponentPatcher.allWrappers
				if @__isInherit(Wrap, SuperWrapper)
					unless Wrap in inherits then inherits.push(Wrap)
					@__getInherits(Wrap, inherits)
			return inherits


		Wrapper.__isInherit = (Wrapper, SuperWrapper)->
			prototype = Object.getPrototypeOf(Wrapper.prototype)
			while prototype
				if prototype.constructor is SuperWrapper
					return true
				prototype = Object.getPrototypeOf(prototype)
			return false


		Wrapper.__copyPropsFrom = (Class)->
			inherits = @__getInherits()

			oldStyle = @style
			oldTemplate = @template
			oldPrototype = @prototype
			prototype = Object.getPrototypeOf(Class)

			if Object.setPrototypeOf
				Object.setPrototypeOf(@, prototype)
			else
				@__proto__ = prototype

			newProps = Object.getOwnPropertyNames(Class)
			for prop in newProps when @__isCorrectProp(prop)
				descriptor = Object.getOwnPropertyDescriptor(Class, prop)
				Object.defineProperty(@, prop, descriptor)

			@prototype.constructor = @
			Component.extend(@)

			removedProps = @__getRemovedProps(newProps)
			for removedProp in removedProps
				delete @[removedProp]

			@__copyPropsToInherits(inherits, oldTemplate, oldStyle, oldPrototype)
			return


		Wrapper.__isCorrectProp = (prop)->
			if prop.indexOf('__') is 0 then return false
			if prop in ['id', 'tree', 'initedComponents', 'compiledTemplate']
				return false
			return true


		Wrapper.__getRemovedProps = (newProps)->
			currentProps = Object.getOwnPropertyNames(@__oldActiveClass or {})
			return currentProps.filter (prop)=> !(prop in newProps)


		Wrapper.__copyPropsToInherits = (inherits, oldTemplate, oldStyle, oldPrototype)->
			for inherit in inherits
				# copy template
				if inherit.template is oldTemplate
					inherit.template = @template

				# copy style
				if inherit.style is oldStyle
					inherit.style = @style

				# copy logic
				context = inherit.prototype
				while context
					chainPrototype = Object.getPrototypeOf(context)
					if chainPrototype is oldPrototype
						if Object.setPrototypeOf
							Object.setPrototypeOf(context, @prototype)
						else
							context.__proto__ = @prototype
						break
					context = chainPrototype
			return


		Wrapper.__checkTemplate = (Class)->
			template = @__getTemplate(Class)
			hasDiff = @__oldTemplate isnt template
			@__oldTemplate = template
			return hasDiff


		Wrapper.__getTemplate = (Class)->
			return Class.template + ''


		Wrapper.__checkStyle = (Class)->
			style = @__getStyle(Class)
			hasDiff = @__oldStyle isnt style
			@__oldStyle = style
			return hasDiff


		Wrapper.__getStyle = (Class)->
			return Class.style + ''


		Wrapper.__checkLogic = (Class)->
			logic = @__getLogic(Class)
			hasDiff = @__oldLogic isnt logic
			@__oldLogic = logic
			return hasDiff


		Wrapper.__getLogic = (Class)->
			code = ''
			for prop in Object.getOwnPropertyNames(Class)
				if prop is 'template' or prop is 'style' then continue
				descriptor = Object.getOwnPropertyDescriptor(Class, prop)
				code += @__getDescriptorCode(descriptor)

			for prop in Object.getOwnPropertyNames(Class.prototype)
				descriptor = Object.getOwnPropertyDescriptor(Class.prototype, prop)
				code += @__getDescriptorCode(descriptor)
			return code


		Wrapper.__checkComponents = (Class)->
			components = @__getComponents(Class)
			oldComponents = @__oldComponents or []
			hasDiff = @__componentsHasDiff(components, oldComponents)
			@__oldComponents = components.slice()
			return hasDiff


		Wrapper.__getComponents = (Class)->
			return Class.components or []


		Wrapper.__componentsHasDiff = (components, oldComponents)->
			if components.length isnt oldComponents.length
				return true
			return components.some (component, index)=>
				return oldComponents[index] isnt component


		Wrapper.__checkTag = (Class)->
			tag = @__getTag(Class)
			hasDiff = @__oldTag isnt tag
			@__oldTag = tag
			return hasDiff


		Wrapper.__getTag = (Class)->
			return Class.tag


		Wrapper.__getDescriptorCode = (descriptor)->
			if descriptor.hasOwnProperty('value')
				value = descriptor.value

				if typeof value is 'function'
					return "#{descriptor.value}"
				else
					try return JSON.stringify(value)
					catch e then return "#{Math.random()}"

			return "#{descriptor.get + descriptor.set}"


		Wrapper.__initClass = (Class)->
			@__activeClass = Class
			@__copyPropsFrom(Class)

			@__checkComponents(Class)
			@__checkTemplate(Class)
			@__checkStyle(Class)
			@__checkLogic(Class)
			@__checkTag(Class)
			return


		Wrapper.__initClass(Class)
		return Wrapper







