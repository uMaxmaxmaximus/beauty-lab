module.exports = class HTMLRenderer


	@render: (node)->
		return new @().render(node)


	@renderInnerHTML: (node)->
		return new @().renderInnerHTML(node)


	constructor: (@root)->
		@excludeNodes = []
		return


	render: (node = @root)=>
		@excludeNodes = [] #reset excludes
		return @renderNode(node)


	renderNode: (node, needsExclude = off)=>
		if @excludeNodes.indexOf(node) isnt -1 then return ''
		if needsExclude then @excludeNodes.push(node)

		switch node.nodeType
			when 'element'
				if node.tag is 'content'
					html = @renderContent(node)
				else
					html = @renderElement(node)
			when 'comment'
				html = @renderComment(node)
			when 'text'
				html = @renderText(node)
		return html


	renderElement: (element)=>
		tag = element.tag
		attrs = @renderAttrs(element)

		if element.shadowRoot
			tag = "ui-#{tag}"
			innerHTML = @renderChildren(element.shadowRoot)
		else
			innerHTML = @renderChildren(element)

		return "<#{tag}#{attrs}>#{innerHTML}</#{tag}>"



	renderContent: (content)=>
		host = @getHost(content)
		selector = content.attrs.select

		if selector
			innerHTML = ''
			nodes = host.select(">#{selector}")
			for node in nodes
				innerHTML += @renderNode(node, yes)
			return innerHTML

		return @renderChildren(host, yes)


	getHost: (node)=>
		while node
			if node.host
				return node.host
			node = node.parent
		return null


	renderChildren: (element, needsExclude)=>
		innerHTML = ''
		for child in element.children
			innerHTML += @renderNode(child, needsExclude)
		return innerHTML


	renderInnerHTML: (element, needsExclude)=>
		return @renderChildren(element.shadowRoot or element)


	renderAttrs: (element)=>
		attrs = ''
		for name in element.attrNames
			unless /^\w/.test(name) then continue
			value = element.attrs[name]
			attrs += " #{name}='#{value}'"

		if element.shadowRoot
			shadowId = element.shadowRoot.shadowId
			attrs += " h#{shadowId}"

		host = @getHost(element)
		if host
			shadowId = host.shadowRoot.shadowId
			attrs += " c#{shadowId}"

		attrs += " id='#{element.nodeId}'"

		return attrs


	renderComment: (comment)=>
		return ''


	renderText: (text)=>
		return text.value


