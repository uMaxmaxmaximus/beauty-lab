module.exports = class DateTimeInput

	@style: require './datetime.styl'
	@tag: 'datetime'

	@template: "
		<text .date #input (change)='fromInput()'>
			<span><content></content></span>
		</text>
	"

	constructor: ->
		@value = new Date()
		@name = @host.attr('name')
		@form = @require('form?')
		@form?.addInput(@)

		@inited = false
		@on('init', @onInit)
		@on('keydown', @onKeyDown)

		@disableValueWatcher = false
		@watch('value', @onValueChange)
		return


	destructor: =>
		@form?.removeInput(@)
		return


	reset: =>
		@value = new Date()
		return


	onKeyDown: (event)=>
		if event.realEvent.keyCode == 13
			@fromInput()
			@form?.submit()
			event.prevent()
		return


	onInit: =>
		@inited = true
		@fixDate()
		@toInput()
		return


	onValueChange: (value)=>
		if @disableValueWatcher then return
		@disableValueWatcher = true
		@value = new Date(value)
		@disableValueWatcher = false
		@fixDate()
		@toInput()
		return


	fixDate: =>
		if isNaN(@value.getTime())
			@value = new Date()
		return


	toInput: =>
		unless @inited then return
		@scope.input.value = @value.format('dd.mm.yyyy  HH:MM')
		return


	fromInput: =>
		inputValue = @scope.input.value
		matches = inputValue.match(/\d+/img)

		switch matches?.length
			when 5
				day = matches[0]
				month = matches[1]
				year = matches[2]
				hours = matches[3]
				minutes = matches[4]
				@setValuesFromInput(day, month, year, hours, minutes)
			when 4
				day = matches[0]
				month = matches[1]
				year = new Date().getFullYear()
				hours = matches[2]
				minutes = matches[3]
				@setValuesFromInput(day, month, year, hours, minutes)
			when 3
				day = matches[0]
				month = matches[1]
				year = matches[2]
				hours = 0
				minutes = 0
				@setValuesFromInput(day, month, year, hours, minutes)
			when 2
				day = matches[0]
				month = matches[1]
				year = new Date().getFullYear()
				hours = 0
				minutes = 0
				@setValuesFromInput(day, month, year, hours, minutes)

		@toInput()
		return


	setValuesFromInput: (day, month, year, hours, minutes)=>
		year = @parseYear(year)
		month = @parseMonth(month)
		day = @parseDay(day, month, year)
		hours = @parseHours(hours)
		minutes = @parseMinutes(minutes)

		@value.setDate(day)
		@value.setMonth(month)
		@value.setFullYear(year)
		@value.setHours(hours)
		@value.setMinutes(minutes)
		return


	parseDay: (dayString, month, year)=>
		daysInMonth = new Date(year, month).getDaysInMonth()
		return Math.max(1, Math.min(Number(dayString), daysInMonth))


	parseMonth: (monthString)=>
		return Math.max(0, Math.min(Number(monthString) - 1, 11))


	parseYear: (yearString)=>
		yearString = switch yearString.length
			when 1 then "200#{yearString}"
			when 2
				if yearString > 50 then "19#{yearString}"
				else "20#{yearString}"
			when 3 then "1#{yearString}"
			else
				yearString

		return Math.max(1950, Math.min(Number(yearString), 2050))


	parseHours: (hoursString)=>
		return Math.max(0, Math.min(Number(hoursString), 23))


	parseMinutes: (minutesString)=>
		return Math.max(0, Math.min(Number(minutesString), 59))

