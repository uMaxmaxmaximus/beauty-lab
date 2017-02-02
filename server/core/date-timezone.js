Date.prototype.timezoneOffset = new Date().getTimezoneOffset();

Date.setTimezoneOffset = function(timezoneOffset) {
	return this.prototype.timezoneOffset = timezoneOffset;
};

Date.getTimezoneOffset = function(timezoneOffset) {
	return this.prototype.timezoneOffset;
};

Date.prototype.getTimezoneOffset = function() {
	return this.timezoneOffset;
};

Date.prototype.setTimezoneOffset = function(timezoneOffset) {
	return this.timezoneOffset = timezoneOffset;
};

Date.prototype.toString = function() {
	var offsetDate, offsetTime;
	offsetTime = this.timezoneOffset * 60 * 1000;
	offsetDate = new Date(this.getTime() - offsetTime);
	return offsetDate.toUTCString();
};

['Milliseconds', 'Seconds', 'Minutes', 'Hours', 'Date', 'Month', 'FullYear', 'Year', 'Day'].forEach((function(_this) {
	return function(key) {
		Date.prototype["get" + key] = function() {
			var offsetDate, offsetTime;
			offsetTime = this.timezoneOffset * 60 * 1000;
			offsetDate = new Date(this.getTime() - offsetTime);
			return offsetDate["getUTC" + key]();
		};
		return Date.prototype["set" + key] = function(value) {
			var offsetDate, offsetTime, time;
			offsetTime = this.timezoneOffset * 60 * 1000;
			offsetDate = new Date(this.getTime() - offsetTime);
			offsetDate["setUTC" + key](value);
			time = offsetDate.getTime() + offsetTime;
			this.setTime(time);
			return time;
		};
	};
})(this));

