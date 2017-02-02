module.exports = class LocalStorage


	@set: (key, value)->
		try localStorage.setItem(key, JSON.stringify(value))
		catch then return false
		return false


	@get: (key)->
		try return JSON.parse(localStorage.getItem(key))
		catch then return undefined


	@remove: (key)->
		return delete localStorage[key]


