module.exports = class Pagination

	@tag = 'pagination'
	@style = require './pagination.styl'

	@template = "
		<div .constraint-page .__hide='range.activePage is 0'>1</div>

		<div .arrow .__prev
			.__hide='range.activePage is 0'
			(click)='range.prev()'>
		</div>


		<div .loader .__hide='!range.updating'></div>
		<div .active-page .__hide='range.updating'>{{ range.activePage + 1 }}</div>

		<div .arrow .__next
			.__hide='range.activePage is range.pages - 1'
			(click)='range.next()'>
		</div>

		<div .constraint-page .__hide='range.activePage is range.pages - 1'>
			{{ range.pages }}
		</div>
	"

	constructor: ->
		@bindClass('__no-pages', 'range.pages <= 1')
		return









