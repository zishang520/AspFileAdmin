/**
 * DateQuery JavaScript Library 0.1.4
 * http://levi.cg.am
 *
 * autor: levi
 */
;(function(w) {
	var version = '0.1.4', 
		DateQuery = function(time) {
			return new DateQuery.fn.init(time);
		};

	DateQuery.version = version;
	DateQuery.keys = {y: 31556926000, m: 2629744000, w: 604800000, d: 86400000, h: 3600000, i: 60000, s: 1000};

	DateQuery.strTotime = function(str) {
		var time;
		if (str instanceof Date) {
			return str;
		}

		if (str instanceof Array) {
			str = str.concat([0, 0, 0, 0, 0, 0]);
			str = str.slice(0, 3).join('-') + ' ' + str.slice(3, 6).join(':');
		}

		time = new Date(str);
		isNaN(time) && str.replace && str.replace(/(\d+)([-|\/|\s])(\d+)\2(\d+)(\s(\d+):(\d+)(:(\d+))?)?/g, function(name) {
			var i, l, a = arguments;
			for (i = 0, l = a.length; i < l; i++) {
				a[i] |= 0;
			}

			time = new Date(a[1], Math.max(a[3]-1, 0), a[4], a[6], a[7], a[9]);
		});

		return isNaN(time) ? null : time;
	};

	DateQuery.isDate = function(time) {
		return !!DateQuery.strTotime(time);
	};

	DateQuery.format = function(n) {
		return n < 10 ? '0' + n : n;
	};

	var fn = DateQuery.fn = DateQuery.prototype;
	fn.init = function(num) {
		this.data = {time: new Date()};
		this.data.between = this.set(num).data.time;

		return this;
	};

	fn.set = function(num, between) {
		var key = between ? 'between' : 'time', pot;

		num && (pot = num instanceof DateQuery ? num.data.time : DateQuery.strTotime(num));
		if (!pot && typeof num == 'object') {
			for (var i in num) {
				pot = 'set' + i;
				this.data[key][pot] && this.data[key][pot](num[i]);
			}

			return this;
		}

		this.data[key] = pot||new Date();
		return this;
	};

	fn.between = function(num) {
		return this.set(num, true);
	};

	fn.get = function(type, between) {
		if (between) {
			return this.getBetween(type);
		}

		if (!type) {
			return this.data.time;
		}

		// N, W, u, T, e, c
		var time = this.data.time, self = this;
		return type.replace(/\/?(A|B|D|F|G|H|I|L|M|N|O|P|S|T|U|W|Y|Z|a|d|c|e|g|h|i|j|l|m|n|o|r|s|t|u|w|y|z)/g, function(name, index) {
			var day;
			if (name.length == 2 && name.indexOf('/') > -1) {
				return name.substring(1);
			}

			switch (name) {
				case 'A': case 'a': 
					// ie6 can't used
					// day = time.toLocaleTimeString().substring(0, 2);
					// return day.indexOf('m') && name == 'A' ? day.toUpperCase() : day;

					day = time.getHours() < 12 ? 'am' : 'pm';
					return name == 'A' ? day.toUpperCase(): day;
				case 'B':
					var h = time.getHours(), i = time.getMinutes(), s = time.getSeconds(),
						tzoff = 60 + time.getTimezoneOffset();

					return ('000'+Math.floor((h * 3600 + (i + tzoff) * 60 + s) / 86.4) % 1000).slice(-3);
				case 'D': case 'F': case 'M': case 'O': case 'P': case 'l':
					day = time.toString().split(' ');
					if (name == 'O') {
						return '+' + (day[5].split('+')[1] || day[4].split('+')[1]);
					} else if (name == 'P') {
						day = day[5].indexOf('+') > 0 ? day[5] : day[4];
						return day.slice(3, 6) + ':' + day.slice(6);
					} else {
						return day[name == 'M' || name == 'F' ? 1 : 0]
					}
				case 'G': case 'Y': case 'o': case 'u': case 'w': 
					day = {G: 'Hours', Y: 'FullYear', o: 'UTCFullYear', u: 'Milliseconds', w: 'Day'};
					return time['get' + day[name]]();
				case 'H': case 'i': case 's':
					day = {H: 'getHours', i: 'getMinutes', s: 'getSeconds'};
					return ('0' + time[day[name]]()).slice(-2);
				case 'I': return (new Date(2009, 0, 1).getTimezoneOffset() != new Date(2009, 6, 1).getTimezoneOffset())|0;
				case 'L': return (new Date(time.getFullYear(), 2, 0).getDate() === 29)|0;
				case 'N': return !(day = time.getUTCDay()) ? 7 : day;
				case 'T': case 'e': 
					day = time.toString().split(' ')[6];
					return day ? day.substring(1, day.length - 1) : time.getTimezoneOffset() / -60;
				case 'S':
					day = time.getDate();
					((day < 4 && day > 0) || (day < 24 && day > 20)) && (day = (day + '' + day).substring(1, 2));

					return ['st', 'nd', 'rd'][(day|0) - 1]||'th';
				case 'U': return +time;
				case 'W': case 'z': 
					day = Math.floor((time - new Date(time.getFullYear(), 0, 1)) / 86400000);
					return name === 'z' ? day : Math.ceil(day/7);
				case 'Z': return time.getTimezoneOffset() * -60;
				case 'c': 
					if (time.toISOString) {
						return time.toISOString();
					}

					self.temp(function() {
						day = this.add(time.getTimezoneOffset(), 'i').get('Y-m-d/TH:i:s/Z');
					});

					return day;
				case 'd': case 'j': 
					day = time.getDate();
					return name === 'd' && day < 10 ? ('0' + day) : day;
				case 'g': case 'h': return !(day = time.getHours() % 12) ? 12 : (day < 10 && name == 'h' ? '0' + day : day);
				case 'm': case 'n':
					day = time.getMonth() + 1;
					return name === 'm' && day < 10 ? ('0' + day) : day;
				case 'r': return time.toUTCString();
				case 't': return new Date(time.getFullYear(), time.getMonth() + 1, 0).getDate();
				case 'y': return (time.getFullYear()+'').substring(2);
				default: return name;
			}
		});
	};

	fn.add = function(num, type, between) {
		var time = this.data[between ? 'between' : 'time'];

		type && (type = type.toLowerCase());
		switch (type) {
			case 'y': return this.set({FullYear: time.getFullYear()|0 + num}, between);
			case 'm': return this.set({Month: time.getMonth() + num}, between);
			default: return this.set(+time + num * (DateQuery.keys[type]||1), between);
		}
	};

	fn.getBetween = function(name) {
		name = name||'ms';
		name == 'g' && (name = ['ms', 's', 'i', 'h', 'd', 'm', 'y']);

		var data = this.data, 
			isobj = typeof name == 'object', 
			time = Math.abs(+data.time - +data.between),
			act = function(str, end) {
				str = str.toLowerCase();
				var num = DateQuery.keys[str], df = {ms: 1000, s: 60, i: 60, h: 24, d: 30, w: 7, m: 12};

				num = num ? Math.floor(time / num) : time;
				return (!end && df[str]) ? num % df[str] : num;
			}, 
			group, i, l;

		if (!time) {
			return isobj ? [0] : 0;
		}

		if (isobj) {
			group = [(data.between > data.time)|0];
			for (i = 0, l = name.length; i < l; i++) {
				group.push(act(name[i], l == (i + 1)));
			}

			return group;
		}

		name = name.toLowerCase();
		switch (name) {
			case 'y': case 'm': 
				var year = data.time.getYear() - data.between.getYear(), mtime, mbetween;
				if (name == 'y') {
					return Math.abs(year);
				} else {
					mtime = data.time.getMonth();
					mbetween = data.between.getMonth();
					return year ? (year > 0 ? (mtime - mbetween + year * 12) : (mbetween - mtime - year * 12)) : Math.abs(mtime - mbetween);
				}
			default: return DateQuery.keys[name] ? Math.floor(time / DateQuery.keys[name]) : time;
		}
	};

	fn.getPot = function(name, end) {
		var def = end ? [12, 31, 23, 59, 59] : [1, 1, 0, 0, 0],
			now = this.get('Y,n,j,G,i,s').split(','),
			mat = {y:1, m: 2, d: 3, h: 4, i: 5},
			m = now[1], d = now[2], i, l;

		name = name ? name.toLowerCase() : 'm';
		for(i = mat[name]||2, l = def.length; i <= l; i++) {
			now[i] = def[i-1];
		}

		if (name == 'q') {
			now[1] = Math[end ? 'ceil' : 'floor'](m / 3) * 3;
			end && now[1] != 12 && (now[2] = 0);
		}

		end && name == 'm' && (now[2] = this.get('t'));
		return DateQuery.strTotime(now) || new Date();
	};

	fn.temp = function(emt) {
		var time = +this.data.time, between = +this.data.between;
		emt.call(this);

		return this.set(time).set(between, true);
	};

	fn.diff = function(name, tem) {
		var data, num = 0;
		if (tem) {
			this.temp(function() {
				data = this.set(tem, true).getBetween(name);
				num = +this.data.between;
			});
		} else {
			data = this.getBetween(name);
			num = +this.data.between;
		}

		return typeof data == 'object' ? data : (data *= (+this.data.time > num ? -1 : 1));
	};

	fn.walk = function(time, limit, emit) {
		return this.temp(function() {
			var isDate = DateQuery.isDate(time), num = 0;
			limit = limit|0||DateQuery.keys[limit]||6000;

			if (time) {
				time.stat ? this.set(time.stat) : (!isDate && this.set(this.getPot(time)));
				time.end ? this.set(time.end, true) : this.set(isDate ? time : this.getPot(time, true), true);
			}

			do {
				this.diff() < limit ? (num = 0) : num++;
				emit.call(this, num, limit);
			} while(num && this.add(limit));
		});
	};

	fn.toData = function(data, met) {
		var value = met ? {} : [], i, l, key;

		!data && (data = ['Y', 'm', 'd', 'H', 'i', 's']);
		for (i = 0, l = data.length; i < l; i++) {
			key = data[i];
			met ? (value[key] = this.get(key)) : value.push(this.get(key));
		}

		return value;
	};

	fn.init.prototype = DateQuery.fn;

	!w.lv && (w.lv = {});
	w.lv.date = w.lvDate = DateQuery;
	module.exports = w.lv;
})({});