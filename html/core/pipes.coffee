ui = require 'ui-js'

MONTHS = [
	'Января'
	'Февраля'
	'Марта'
	'Апреля'
	'Мая'
	'Июня'
	'Июля'
	'Августа'
	'Сентября'
	'Октября'
	'Ноября'
	'Декабря'
]

CAR_CATEGORIES = {
	'standart': 'Стандарт'
	'business': 'Бизнес'
	'minivan': 'Минивэн'
	'bus': 'Автобус'
	'freight': 'Грузовое'
}

REQUEST_FORMATS = {
	'byPhone': 'По телефону'
	'byEmail': 'По Email'
}

BOOLEAN = {
	'true': 'Да'
	'false': 'Нет'
}


ui.pipe 'date', (value, mask = 'dd.mm.yyyy HH:MM')->
	unless value instanceof Date
		if typeof value is 'number'
			value = new Date(value)
		else return ''
	return value.format(mask)


ui.pipe 'toArray', (value)->
	unless value then return []
	return Array.from(value)


ui.pipe 'carCategory', (value)->
	return CAR_CATEGORIES[value]


ui.pipe 'requestFormat', (value)->
	return REQUEST_FORMATS[value]


ui.pipe 'bool', (value)->
	return BOOLEAN[!!value]


ui.pipe 'filter', (arr, value, prop)->
	unless arr then return []
	unless value? then return arr
	if value is '' then return arr

	return arr.filter (item)=>
		return item[prop].indexOf(value) != -1


ui.pipe 'future', (value)->
	return value > Date.now()


ui.pipe 'past', (value)->
	return value < Date.now()





