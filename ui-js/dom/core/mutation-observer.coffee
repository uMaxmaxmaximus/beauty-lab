Map = require('../../polyfill/map')


module.exports = class MutationObserver

	constructor: ->
		@mutations = new Map()
		return


	clearMutations: =>
		@mutations = new Map()
		return


	hasMutations: =>
		return !!@mutations.size


	getMutations: =>
		mutations = @mutations
		@clearMutations()
		return mutations


	mutate: (node, type)=>
		unless @mutations.has(node)
			@mutations.set(node, {})
		nodeMutations = @mutations.get(node)
		nodeMutations[type] = true
		return



