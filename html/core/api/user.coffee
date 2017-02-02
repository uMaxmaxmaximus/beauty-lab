localStorage = require 'ui-js/core/local-storage'
Cookies = require 'ui-js/core/cookies'
Model = require '../model'

SESSION_TIME = 60 * 60 * 24 * 360


unless Cookies.get('session-key')
	Cookies.set('session-key', localStorage.get('session-key'), {expires: SESSION_TIME})


module.exports = class User extends Model

	@api('User')

	@current = localStorage.get('User.current')
	@ADMIN = 'admin'
	@CLIENT = 'client'


	@logIn: (form)->
		return @call('login', form).then (loginData)=>
			@_setLoginData(loginData)
			return loginData


	@logOut: ->
		return ui.app.confirm('Выйти?', yes)
			.then => @call('logout')
			.then => @_clearLoginData()


	@register: (form)->
		return @call('register', form).then (loginData)=>
			@_setLoginData(loginData)
			return loginData


	@_setLoginData: (loginData)->
		Cookies.set('session-key', loginData.session.key, {expires: SESSION_TIME})
		localStorage.set('session-key', loginData.session.key)
		@_setCurrentUser(loginData.user)
		return


	@_clearLoginData: ->
		Cookies.remove('session-key')
		localStorage.remove('session-key')
		@_clearCurrentUser()
		return


	@_setCurrentUser: (user)->
		localStorage.set('User.current', user)
		@current = user
		return


	@_clearCurrentUser: ->
		localStorage.remove('User.current')
		@current = null
		return


	@init: ->
		@call('current').then (user)=>
			@_setCurrentUser(user)
			return


	@addDriver: (params)->
		params.type = @DRIVER
		return @add(params)


	@addDispatcher: (params)->
		params.type = @DISPATCHER
		return @add(params)


	@resetPass: (user)->
		return @call('resetPass', {_id: user._id})


	@changeAdminPass: (params)->
		return @call('changeAdminPass', params)


	@changeAdminName: (params)->
		return @call('changeAdminName', params)


	resetPass: =>
		return @constructor.resetPass(@)


class Session extends Model

	@api('Session')


User.init()

