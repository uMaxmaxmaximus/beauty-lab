Date.prototype.getDaysInMonth = ->
	return 32 - new Date(@getFullYear(), @getMonth(), 32).getDate()

