module.exports = class Cookies


	@get: (name)->
		matches = document.cookie.match(new RegExp('(?:^|; )' + name.replace(/([.$?*|{}()\[\]\\\/+^])/g, '\\$1') + '=([^;]*)'))
		if matches then decodeURIComponent(matches[1]) else undefined


	@set: (name, value, options = {})->
		options.path or= '/'

		expires = options.expires
		if expires and typeof expires is 'number'
			date = new Date()
			date.setTime(date.getTime() + expires * 1000)
			expires = options.expires = date
		if expires instanceof Date
			options.expires = expires.toUTCString()

		updatedCookie = "#{name}=#{encodeURIComponent(value)}"

		for propName of options
			updatedCookie += "; #{propName}"
			propValue = options[propName]
			if propValue != true
				updatedCookie += "=#{propValue}"

		document.cookie = updatedCookie
		return


	@remove: deleteCookie = (name)->
		@set(name, '', {expires: -1})
		return



