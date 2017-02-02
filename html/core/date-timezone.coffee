# tmp date
offsetDate = new Date()

# default timezone
Date.prototype.timezoneOffset = offsetDate.getTimezoneOffset()


Date.setTimezoneOffset = (timezoneOffset)->
	return @prototype.timezoneOffset = timezoneOffset


Date.getTimezoneOffset = (timezoneOffset)->
	return @prototype.timezoneOffset


Date.prototype.setTimezoneOffset = (timezoneOffset)->
	return @timezoneOffset = timezoneOffset


Date.prototype.getTimezoneOffset = ->
	return @timezoneOffset


Date.prototype.toString = ->
	offsetTime = @timezoneOffset * 60 * 1000
	offsetDate.setTime(@getTime() - offsetTime)
	return offsetDate.toUTCString()


[
	'Milliseconds', 'Seconds', 'Minutes', 'Hours',
	'Date', 'Month', 'FullYear', 'Year', 'Day'
]
.forEach (key)=>
	Date.prototype["get#{key}"] = ->
		offsetTime = @timezoneOffset * 60 * 1000
		offsetDate.setTime(@getTime() - offsetTime)
		return offsetDate["getUTC#{key}"]()

	Date.prototype["set#{key}"] = (value)->
		offsetTime = @timezoneOffset * 60 * 1000
		offsetDate.setTime(@getTime() - offsetTime)
		offsetDate["setUTC#{key}"](value)
		time = offsetDate.getTime() + offsetTime
		@setTime(time)
		return time


