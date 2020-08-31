(function() {
  var callWithJQuery,
    __indexOf = [].indexOf || function(item) {
    	for (var i = 0, l = this.length; i < l; i++) {
				if (i in this && this[i] === item) return i;
			}
			return -1;
		},
		__slice = [].slice,
		__bind = function(fn, me) {
			return function() {
				return fn.apply(me, arguments);
			};
		},
		__hasProp = {}.hasOwnProperty;

	callWithJQuery = function(pivotModule) {
		if (typeof exports === "object" && typeof module === "object") {
			return pivotModule(require("jquery"));
		} else if (typeof define === "function" && define.amd) {
			return define(["jquery"], pivotModule);
		} else {
			return pivotModule(jQuery);
		}
	};

	callWithJQuery(function($) {
		/*
		Utilities
		 */
		var PivotData, addSeparators, aggregatorTemplates, aggregators, dayNamesEn, derivers, getSort, locales, mthNamesEn, naturalSort, numberFormat, pivotTableRenderer, renderers, sortAs, usFmt, usFmtInt, usFmtPct, zeroPad;
		addSeparators = function(nStr, thousandsSep, decimalSep) {
			var rgx, x, x1, x2;
			nStr += '';
			x = nStr.split('.');
			x1 = x[0];
			x2 = x.length > 1 ? decimalSep + x[1] : '';
			rgx = /(\d+)(\d{3})/;
			while (rgx.test(x1)) {
				x1 = x1.replace(rgx, '$1' + thousandsSep + '$2');
			}
			return x1 + x2;
		};
		numberFormat = function(opts) {
			var defaults;
			defaults = {
				digitsAfterDecimal: 2,
				scaler: 1,
				thousandsSep: ",",
				decimalSep: ".",
				prefix: "",
				suffix: "",
				showZero: false
			};
			opts = $.extend(defaults, opts);
			return function(x) {
				var result;
				if (isNaN(x) || !isFinite(x)) {
					return "";
				}
				if (x === 0 && !opts.showZero) {
					return "";
				}
				result = addSeparators((opts.scaler * x).toFixed(opts.digitsAfterDecimal), opts.thousandsSep, opts.decimalSep);
				return "" + opts.prefix + result + opts.suffix;
			};
		};
		usFmt = numberFormat();
		usFmtInt = numberFormat({
			digitsAfterDecimal: 0
		});
		usFmtPct = numberFormat({
			digitsAfterDecimal: 1,
			scaler: 100,
			suffix: "%"
		});
		aggregatorTemplates = {
			count: function(formatter) {
				if (formatter == null) {
					formatter = usFmtInt;
				}
				return function() {
					return function(data, rowKey, colKey) {
						return {
							count: 0,
							push: function() {
								return this.count++;
							},
							value: function() {
								return this.count;
							},
							format: formatter
						};
					};
				};
			},
			countUnique: function(formatter) {
				if (formatter == null) {
					formatter = usFmtInt;
				}
				return function(_arg) {
					var attr;
					attr = _arg[0];
					return function(data, rowKey, colKey) {
						return {
							uniq: [],
							push: function(record) {
								var _ref;
								if (_ref = record[attr], __indexOf.call(this.uniq, _ref) < 0) {
									return this.uniq.push(record[attr]);
								}
							},
							value: function() {
								return this.uniq.length;
							},
							format: formatter,
							numInputs: attr != null ? 0 : 1
						};
					};
				};
			},
			listUnique: function(sep) {
				return function(_arg) {
					var attr;
					attr = _arg[0];
					return function(data, rowKey, colKey) {
						return {
							uniq: [],
							push: function(record) {
								var _ref;
								if (_ref = record[attr], __indexOf.call(this.uniq, _ref) < 0) {
									return this.uniq.push(record[attr]);
								}
							},
							value: function() {
								return this.uniq.join(sep);
							},
							format: function(x) {
								return x;
							},
							numInputs: attr != null ? 0 : 1
						};
					};
				};
			},
			sum: function(formatter) {
				if (formatter == null) {
					formatter = usFmt;
				}
				return function(_arg) {
					var attr;
					attr = _arg[0];
					return function(data, rowKey, colKey) {
						return {
							sum: 0,
							push: function(record) {
								if (!isNaN(parseFloat(record[attr]))) {
									return this.sum += parseFloat(record[attr]);
								}
							},
							value: function() {
								return this.sum;
							},
							format: formatter,
							numInputs: attr != null ? 0 : 1
						};
					};
				};
			},
			min: function(formatter) {
				if (formatter == null) {
					formatter = usFmt;
				}
				return function(_arg) {
					var attr;
					attr = _arg[0];
					return function(data, rowKey, colKey) {
						return {
							val: null,
							push: function(record) {
								var x, _ref;
								x = parseFloat(record[attr]);
								if (!isNaN(x)) {
									return this.val = Math.min(x, (_ref = this.val) != null ? _ref : x);
								}
							},
							value: function() {
								return this.val;
							},
							format: formatter,
							numInputs: attr != null ? 0 : 1
						};
					};
				};
			},
			max: function(formatter) {
				if (formatter == null) {
					formatter = usFmt;
				}
				return function(_arg) {
					var attr;
					attr = _arg[0];
					return function(data, rowKey, colKey) {
						return {
							val: null,
							push: function(record) {
								var x, _ref;
								x = parseFloat(record[attr]);
								if (!isNaN(x)) {
									return this.val = Math.max(x, (_ref = this.val) != null ? _ref : x);
								}
							},
							value: function() {
								return this.val;
							},
							format: formatter,
							numInputs: attr != null ? 0 : 1
						};
					};
				};
			},
			average: function(formatter) {
				if (formatter == null) {
					formatter = usFmt;
				}
				return function(_arg) {
					var attr;
					attr = _arg[0];
					return function(data, rowKey, colKey) {
						return {
							sum: 0,
							len: 0,
							push: function(record) {
								if (!isNaN(parseFloat(record[attr]))) {
									this.sum += parseFloat(record[attr]);
									return this.len++;
								}
							},
							value: function() {
								return this.sum / this.len;
							},
							format: formatter,
							numInputs: attr != null ? 0 : 1
						};
					};
				};
			},
			sumOverSum: function(formatter) {
				if (formatter == null) {
					formatter = usFmt;
				}
				return function(_arg) {
					var denom, num;
					num = _arg[0], denom = _arg[1];
					return function(data, rowKey, colKey) {
						return {
							sumNum: 0,
							sumDenom: 0,
							push: function(record) {
								if (!isNaN(parseFloat(record[num]))) {
									this.sumNum += parseFloat(record[num]);
								}
								if (!isNaN(parseFloat(record[denom]))) {
									return this.sumDenom += parseFloat(record[denom]);
								}
							},
							value: function() {
								return this.sumNum / this.sumDenom;
							},
							format: formatter,
							numInputs: (num != null) && (denom != null) ? 0 : 2
						};
					};
				};
			},
			sumOverSumBound80: function(upper, formatter) {
				if (upper == null) {
					upper = true;
				}
				if (formatter == null) {
					formatter = usFmt;
				}
				return function(_arg) {
					var denom, num;
					num = _arg[0], denom = _arg[1];
					return function(data, rowKey, colKey) {
						return {
							sumNum: 0,
							sumDenom: 0,
							push: function(record) {
								if (!isNaN(parseFloat(record[num]))) {
									this.sumNum += parseFloat(record[num]);
								}
								if (!isNaN(parseFloat(record[denom]))) {
									return this.sumDenom += parseFloat(record[denom]);
								}
							},
							value: function() {
								var sign;
								sign = upper ? 1 : -1;
								return (0.821187207574908 / this.sumDenom + this.sumNum / this.sumDenom + 1.2815515655446004 * sign * Math.sqrt(0.410593603787454 / (this.sumDenom * this.sumDenom) + (this.sumNum * (1 - this.sumNum / this.sumDenom)) / (this.sumDenom * this.sumDenom))) / (1 + 1.642374415149816 / this.sumDenom);
							},
							format: formatter,
							numInputs: (num != null) && (denom != null) ? 0 : 2
						};
					};
				};
			},
			fractionOf: function(wrapped, type, formatter) {
				if (type == null) {
					type = "total";
				}
				if (formatter == null) {
					formatter = usFmtPct;
				}
				return function() {
					var x;
					x = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
					return function(data, rowKey, colKey) {
						return {
							selector: {
								total: [
									[],
									[]
								],
								row: [rowKey, []],
								col: [
									[], colKey
								]
							}[type],
							inner: wrapped.apply(null, x)(data, rowKey, colKey),
							push: function(record) {
								return this.inner.push(record);
							},
							format: formatter,
							value: function() {
								return this.inner.value() / data.getAggregator.apply(data, this.selector).inner.value();
							},
							numInputs: wrapped.apply(null, x)().numInputs
						};
					};
				};
			}
		};
		aggregators = (function(tpl) {
			return {
				"Sum": tpl.sum(usFmt),
				"Average": tpl.average(usFmt),
				"Minimum": tpl.min(usFmt),
				"Maximum": tpl.max(usFmt)
			};
		})(aggregatorTemplates);
		renderers = {
			"Table": function(pvtData, opts) {
				$('.pvtAggregator').hide();
				$('.pvtAttrDropdown').hide();
				$('.agg-span').hide();
				return TableRenderer(pvtData, opts);
			},
			"CrossTab Table": function(pvtData, opts) {
				$('.pvtAggregator').show();
				$('.pvtAttrDropdown').show();
				$('.agg-span').show();
				$('#toolbar').show();
				return pivotTableRenderer(pvtData, opts);
			}
		};
		locales = {
			en: {
				aggregators: aggregators,
				renderers: renderers,
				localeStrings: {
					renderError: "An error occurred rendering the PivotTable results.",
					computeError: "An error occurred computing the PivotTable results.",
					uiRenderError: "An error occurred rendering the PivotTable UI.",
					selectAll: "Select All",
					selectNone: "Select None",
					tooMany: "(too many to list)",
					filterResults: "Filter results",
					totals: "Totals",
					vs: "vs",
					by: "by"
				}
			}
		};
		mthNamesEn = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
		dayNamesEn = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
		zeroPad = function(number) {
			return ("0" + number).substr(-2, 2);
		};
		derivers = {
			bin: function(col, binWidth) {
				return function(record) {
					return record[col] - record[col] % binWidth;
				};
			},
			dateFormat: function(col, formatString, utcOutput, mthNames, dayNames) {
				var utc;
				if (utcOutput == null) {
					utcOutput = false;
				}
				if (mthNames == null) {
					mthNames = mthNamesEn;
				}
				if (dayNames == null) {
					dayNames = dayNamesEn;
				}
				utc = utcOutput ? "UTC" : "";
				return function(record) {
					var date;
					date = new Date(Date.parse(record[col]));
					if (isNaN(date)) {
						return "";
					}
					return formatString.replace(/%(.)/g, function(m, p) {
						switch (p) {
							case "y":
								return date["get" + utc + "FullYear"]();
							case "m":
								return zeroPad(date["get" + utc + "Month"]() + 1);
							case "n":
								return mthNames[date["get" + utc + "Month"]()];
							case "d":
								return zeroPad(date["get" + utc + "Date"]());
							case "w":
								return dayNames[date["get" + utc + "Day"]()];
							case "x":
								return date["get" + utc + "Day"]();
							case "H":
								return zeroPad(date["get" + utc + "Hours"]());
							case "M":
								return zeroPad(date["get" + utc + "Minutes"]());
							case "S":
								return zeroPad(date["get" + utc + "Seconds"]());
							default:
								return "%" + p;
						}
					});
				};
			}
		};
		naturalSort = (function(_this) {
			return function(as, bs) {
				var a, a1, b, b1, rd, rx, rz;
				rx = /(\d+)|(\D+)/g;
				rd = /\d/;
				rz = /^0/;
				if (typeof as === "number" || typeof bs === "number") {
					if (isNaN(as)) {
						return 1;
					}
					if (isNaN(bs)) {
						return -1;
					}
					return as - bs;
				}
				a = String(as).toLowerCase();
				b = String(bs).toLowerCase();
				if (a === b) {
					return 0;
				}
				if (!(rd.test(a) && rd.test(b))) {
					return (a > b ? 1 : -1);
				}
				a = a.match(rx);
				b = b.match(rx);
				while (a.length && b.length) {
					a1 = a.shift();
					b1 = b.shift();
					if (a1 !== b1) {
						if (rd.test(a1) && rd.test(b1)) {
							return a1.replace(rz, ".0") - b1.replace(rz, ".0");
						} else {
							return (a1 > b1 ? 1 : -1);
						}
					}
				}
				return a.length - b.length;
			};
		})(this);
		sortAs = function(order) {
			var i, mapping, x;
			mapping = {};
			for (i in order) {
				x = order[i];
				mapping[x] = i;
			}
			return function(a, b) {
				if ((mapping[a] != null) && (mapping[b] != null)) {
					return mapping[a] - mapping[b];
				} else if (mapping[a] != null) {
					return -1;
				} else if (mapping[b] != null) {
					return 1;
				} else {
					return naturalSort(a, b);
				}
			};
		};
		getSort = function(sorters, attr) {
			var sort;
			sort = sorters(attr);
			if ($.isFunction(sort)) {
				return sort;
			} else {
				return naturalSort;
			}
		};
		$.pivotUtilities = {
			aggregatorTemplates: aggregatorTemplates,
			aggregators: aggregators,
			renderers: renderers,
			derivers: derivers,
			locales: locales,
			naturalSort: naturalSort,
			numberFormat: numberFormat,
			sortAs: sortAs
		};

		/*
		Data Model class
		 */
		PivotData = (function() {
			function PivotData(input, opts) {
				this.getAggregator = __bind(this.getAggregator, this);
				this.getRowKeys = __bind(this.getRowKeys, this);
				this.getColKeys = __bind(this.getColKeys, this);
				this.getAggregatorLength = __bind(this.getAggregatorLength, this);
				this.getAggregatorAttr = __bind(this.getAggregatorAttr, this);
				this.getAggs = __bind(this.getAggs, this);
				this.sortKeys = __bind(this.sortKeys, this);
				this.arrSort = __bind(this.arrSort, this);
				this.tree = {};
				this.rowKeys = [];
				this.colKeys = [];
				this.allKeys = [];
				this.rowTotals = {};
				this.colTotals = {};
				this.aggregator = opts.aggregator;
				this.aggregatorName = opts.aggregatorName;
				this.colAttrs = opts.cols;
				this.rowAttrs = opts.rows;
				this.valAttrs = opts.vals;
				this.sorters = opts.sorters;
				this.allAttrs = opts.rows.concat(opts.cols);
				this.graphType = opts.graphType;

				var allTotal = {};

				// console.log('here2');
				// console.log(this.aggregator);

				$.each(this.aggregator, function(index, value) {
					allTotal[index] = value(this, [], []);
				});

				this.allTotal = allTotal;
				this.sorted = false;
				PivotData.forEachRecord(input, opts.derivedAttributes, (function(_this) {
					return function(record) {
						if (opts.filter(record)) {
							return _this.processRecord(record);
						}
					};
				})(this));
			}

			PivotData.forEachRecord = function(input, derivedAttributes, f) {
				var addRecord, compactRecord, i, j, k, record, tblCols, _i, _len, _ref, _results, _results1;
				if ($.isEmptyObject(derivedAttributes)) {
					addRecord = f;
				} else {
					addRecord = function(record) {
						var k, v, _ref;
						for (k in derivedAttributes) {
							v = derivedAttributes[k];
							record[k] = (_ref = v(record)) != null ? _ref : record[k];
						}
						return f(record);
					};
				}
				if ($.isFunction(input)) {
					return input(addRecord);
				} else if ($.isArray(input)) {
					if ($.isArray(input[0])) {
						_results = [];
						for (i in input) {
							if (!__hasProp.call(input, i)) continue;
							compactRecord = input[i];
							if (!(i > 0)) {
								continue;
							}
							record = {};
							_ref = input[0];
							for (j in _ref) {
								if (!__hasProp.call(_ref, j)) continue;
								k = _ref[j];
								record[k] = compactRecord[j];
							}
							_results.push(addRecord(record));
						}
						return _results;
					} else {
						_results1 = [];
						for (_i = 0, _len = input.length; _i < _len; _i++) {
							record = input[_i];
							_results1.push(addRecord(record));
						}
						return _results1;
					}
				} else if (input instanceof jQuery) {
					tblCols = [];
					$("thead > tr > th", input).each(function(i) {
						return tblCols.push($(this).text());
					});
					return $("tbody > tr", input).each(function(i) {
						record = {};
						$("td", this).each(function(j) {
							return record[tblCols[j]] = $(this).html();
						});
						return addRecord(record);
					});
				} else {
					throw new Error("unknown input format");
				}
			};

			PivotData.convertToArray = function(input) {
				var result;
				result = [];
				PivotData.forEachRecord(input, {}, function(record) {
					return result.push(record);
				});
				return result;
			};

			PivotData.prototype.arrSort = function(attrs) {
				var a, sortersArr;
				sortersArr = (function() {
					var _i, _len, _results;
					_results = [];
					for (_i = 0, _len = attrs.length; _i < _len; _i++) {
						a = attrs[_i];
						_results.push(getSort(this.sorters, a));
					}
					return _results;
				}).call(this);
				return function(a, b) {
					var comparison, i, sorter;
					for (i in sortersArr) {
						sorter = sortersArr[i];
						comparison = sorter(a[i], b[i]);
						if (comparison !== 0) {
							return comparison;
						}
					}
					return 0;
				};
			};

			PivotData.prototype.sortKeys = function() {
				if (!this.sorted) {
					this.sorted = true;
					//console.log(this.allAttrs);
					this.rowKeys.sort(this.arrSort(this.rowAttrs));
					this.allKeys.sort(this.arrSort(this.allAttrs));
					return this.colKeys.sort(this.arrSort(this.colAttrs));
				}
			};

			PivotData.prototype.getGraphType = function() {
				return this.graphType;
			}

			PivotData.prototype.getAggs = function() {
				return this.aggregatorName;
			}

			PivotData.prototype.getAggregatorLength = function() {
				return this.aggregator.length;
			};

			PivotData.prototype.getAggregatorAttr = function() {
				return this.valAttrs;
			};

			PivotData.prototype.getColKeys = function() {
				this.sortKeys();
				return this.colKeys;
			};

			PivotData.prototype.getRowKeys = function() {
				this.sortKeys();
				return this.rowKeys;
			};
			PivotData.prototype.getAllKeys = function() {
				this.sortKeys();
				return this.allKeys;
			};

			PivotData.prototype.getID = function(val_attr, val) {
				var return_id = '';

				if (val == 'v') {
					var container = $("th.pvtAxisContainer.pvtAggs");					
				} else if (val == 'r') {
					var container = $("td.pvtAxisContainer.pvtRows");					
				} else if (val == 'c') {
					var container = $("th.pvtAxisContainer.pvtCols");
				}

				$(container).children("li").each(function() { 
					$this = $(this);
					var id = $(this).attr('class').replace('ui-sortable-handle', '').replace('pvtVals', '');
					var label = $('span.pvtAttr', $this).contents().get(0).nodeValue;

					if (label == val_attr) {
						return_id = id;
						return false;
					}
				});

				return return_id;
			}

			PivotData.prototype.getAggregatorArray = function(_this, rowKey, colKey) {
				var agg_array = new Array();
				$.each(this.aggregator, function(index, value) {
					agg_array[index] = value(_this, rowKey, colKey);
				});
				return agg_array;
			};

			PivotData.prototype.processRecord = function(record) {
				var colKey, flatColKey, flatRowKey, rowKey, x, _i, _j, _len, _len1, _ref, _ref1, _ref2, _ref3;
				colKey = [];
				rowKey = [];
				_ref = this.colAttrs;
				for (_i = 0, _len = _ref.length; _i < _len; _i++) {
					x = _ref[_i];
					colKey.push((_ref1 = record[x]) != null ? _ref1 : "null");
				}
				_ref2 = this.rowAttrs;
				for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
					x = _ref2[_j];
					rowKey.push((_ref3 = record[x]) != null ? _ref3 : "null");
				}

				var allKey, _len3, _ref4, _ref5, _r, y;
				allKey = [];
				_r = 0;
				for (_k = 0, _len3 = _ref2.length + _ref.length; _k < _len3; _k++) {
					if (_k < _ref2.length) {
						y = _ref2[_r];
						allKey.push((_ref4 = record[y]) != null ? _ref4 : "null");
					} else {
						if (_k == _ref2.length) _r = 0;

						y = _ref[_r];
						allKey.push((_ref5 = record[y]) != null ? _ref5 : "null");
					}
					_r++;
				}

				if (allKey.length !== 0) {
					this.allKeys.push(allKey);
				}

				flatRowKey = rowKey.join(String.fromCharCode(0));
				flatColKey = colKey.join(String.fromCharCode(0));
				//this.allTotal.push(record);
				var agg_len = this.aggregator.length;
				for (var i = 0; i < agg_len; i++) {
					this.allTotal[i].push(record);
					if (rowKey.length !== 0) {
						if (!this.rowTotals[flatRowKey]) {
							this.rowTotals[flatRowKey] = {};
						}
						if (!this.rowTotals[flatRowKey][i]) {
							if (i == 0) this.rowKeys.push(rowKey);
							this.rowTotals[flatRowKey][i] = this.aggregator[i](this, rowKey, []);
						}
						this.rowTotals[flatRowKey][i].push(record);
					}

					if (colKey.length !== 0) {
						if (!this.colTotals[flatColKey]) {
							this.colTotals[flatColKey] = {};
						}
						if (!this.colTotals[flatColKey][i]) {
							if (i == 0) this.colKeys.push(colKey);
							this.colTotals[flatColKey][i] = this.aggregator[i](this, [], colKey);
						}
						this.colTotals[flatColKey][i].push(record);
					}
				}
				/*
				if (rowKey.length !== 0) {
				if (!this.rowTotals[flatRowKey]) {
					this.rowKeys.push(rowKey);
					this.rowTotals[flatRowKey] = this.aggregator(this, rowKey, []);
				}
				this.rowTotals[flatRowKey].push(record);
				}
				if (colKey.length !== 0) {
				if (!this.colTotals[flatColKey]) {
					this.colKeys.push(colKey);
					this.colTotals[flatColKey] = this.aggregator(this, [], colKey);
				}
				this.colTotals[flatColKey].push(record);
				}
				*/
				if (colKey.length !== 0 && rowKey.length !== 0) {
					if (!this.tree[flatRowKey]) {
						this.tree[flatRowKey] = {};
					}

					if (!this.tree[flatRowKey][flatColKey]) {
						this.tree[flatRowKey][flatColKey] = {};
					}

					for (var i = 0; i < agg_len; i++) {
						if (!this.tree[flatRowKey][flatColKey][i]) {
							this.tree[flatRowKey][flatColKey][i] = this.aggregator[i](this, rowKey, colKey);
						}
						this.tree[flatRowKey][flatColKey][i].push(record);
					}
					return this.tree[flatRowKey][flatColKey];
				}
			};

			PivotData.prototype.getAggregator = function(rowKey, colKey) {
				var agg, flatColKey, flatRowKey;
				flatRowKey = rowKey.join(String.fromCharCode(0));
				flatColKey = colKey.join(String.fromCharCode(0));
				if (rowKey.length === 0 && colKey.length === 0) {
					agg = this.allTotal;
				} else if (rowKey.length === 0) {
					agg = this.colTotals[flatColKey];
				} else if (colKey.length === 0) {
					agg = this.rowTotals[flatRowKey];
				} else {
					agg = this.tree[flatRowKey][flatColKey];
				}

				/*var null_agg = {
				value: (function() {
					return null;
				}),
				format: function() {
					return "";
				}
				}

				if (agg == null) {
				agg = null_agg;
				}*/

				return agg;
			};

			return PivotData;

		})();

		/*
		Default Renderer for hierarchical table layout
		*/

		TableRenderer = function(pivotData, opts) {
			var aggregator, c, colAttrs, colKey, colKeys, defaults, i, j, r, result, rowAttrs, rowKey, rowKeys, spanSize, td, th, totalAggregator, tr, txt, val, x;
			defaults = {
				localeStrings: {
					totals: "Totals"
				}
			};
			
			opts = $.extend(defaults, opts);
			colAttrs = pivotData.colAttrs;
			rowAttrs = pivotData.rowAttrs;
			rowKeys = pivotData.getRowKeys();
			colKeys = pivotData.getColKeys();
			result = document.createElement("table");
			result.className = "table table-bordered table-condensed";

			if ($('.hidden-refresh-btn').text() != '' || get_report_name() != '') {
				var table_caption = result.createCaption();
				table_caption.innerHTML = $('.hidden-refresh-btn').text() || get_report_name();
			}

			allKeys = pivotData.getAllKeys();

			spanSize = function(arr, i, j) {
				var len, noDraw, stop, x, _i, _j;
				if (i !== 0) {
					noDraw = true;
					for (x = _i = 0; 0 <= j ? _i <= j : _i >= j; x = 0 <= j ? ++_i : --_i) {
						if (arr[i - 1][x] !== arr[i][x]) {
							noDraw = false;
						}
					}
					if (noDraw) {
						return -1;
					}
				}
				len = 0;
				while (i + len < arr.length) {
					stop = false;
					for (x = _j = 0; 0 <= j ? _j <= j : _j >= j; x = 0 <= j ? ++_j : --_j) {
						if (arr[i][x] !== arr[i + len][x]) {
							stop = true;
						}
					}
					if (stop) {
						break;
					}
					len++;
				}
				return len;
			};

			thead = document.createElement("thead");
			thead.className = "thead-default";
			result.appendChild(thead);
			trh = document.createElement("tr");

			if (rowAttrs.length !== 0) {
				for (i in rowAttrs) {
					if (!__hasProp.call(rowAttrs, i)) continue;
					r = rowAttrs[i];
					th = document.createElement("th");
					th.className = "pvtAxisLabel";
					//th.textContent = r;
					var row_attr_id = pivotData.getID(r, 'r');
					var custom_label = get_label(row_attr_id, r);
					var label = fx_get_col_alias(r);
					if (custom_label != '') label = custom_label;

					th.textContent = label; //convert col_name to alias
					trh.appendChild(th);
				}
			}

			for (j in colAttrs) {
				if (!__hasProp.call(colAttrs, j)) continue;
				c = colAttrs[j];
				th = document.createElement("th");
				th.className = "pvtAxisLabel";
				
				var col_attr_id = pivotData.getID(c, 'c');
				var custom_label = get_label(col_attr_id, c);
				var label = fx_get_col_alias(c);
				if (custom_label != '') label = custom_label;

				th.textContent = label; //convert col_name to alias
				trh.appendChild(th);
			}
			thead.appendChild(trh);

			tbody = document.createElement("tbody");
			result.appendChild(tbody);
			if (allKeys.length !== 0 && rowKeys.length !== 0) {
				for (i in allKeys) {
					if (!__hasProp.call(allKeys, i)) continue;
					nK = allKeys[i];
					tr = document.createElement("tr");

					for (j in nK) {
						if (!__hasProp.call(nK, j)) continue;
						txt = nK[j];

						var attr = (!__hasProp.call(rowAttrs, j)) ? colAttrs[j-rowAttrs.length] : rowAttrs[j];
						var search_on = (!__hasProp.call(rowAttrs, j)) ? 'c' : 'r';

						var row_attr_id = pivotData.getID(attr, search_on);
						//console.log(attr)
						var fmt_val = format_val(row_attr_id, txt, attr);
						x = 0;
						x = spanSize(allKeys, parseInt(i), parseInt(j));
						if (x !== -1) {
							td = document.createElement("td");
							td.className = "pvtRowLabel";
							td.innerHTML = fmt_val;
							td.setAttribute("rowspan", x);
							tr.appendChild(td);
							//align table header according to standard
							$(td).addClass((isNaN(txt) ? '' : 'data-align-right')).css('text-align', (isNaN(txt) ? 'left' : 'right'));
						}
					}
					tbody.appendChild(tr);
				}
			} else if (colKeys.length !== 0) {
				for (i in colKeys) {
					if (!__hasProp.call(colKeys, i)) continue;
					colKey = colKeys[i];
					tr = document.createElement("tr");
					for (j in colKey) {
						if (!__hasProp.call(colKey, j)) continue;
						var col_attr_id = pivotData.getID(colAttrs[j], 'c');
						txt = colKey[j];

						var fmt_val = format_val(col_attr_id, txt, colAttrs[j]);
						// x = spanSize(colKeys, parseInt(i), parseInt(j));
						// if (x !== -1) {
						td = document.createElement("td");
						td.className = "pvtRowLabel";
						td.innerHTML = fmt_val;
						//td.setAttribute("rowspan", x);
						tr.appendChild(td);
						//align table header according to standard
						$(td).addClass((isNaN(txt) ? '' : 'data-align-right')).css('text-align', (isNaN(txt) ? 'left' : 'right'));

						//}
					}
					tbody.appendChild(tr);
				}
			}
			//align table header according to standard
			$('.data-align-right', $(result)).each(function(i) {
				$('th:nth-child(' + ($(this).index() + 1) + ')', $(result)).not('.header-align-right').addClass('header-align-right').css('text-align', 'right');
			});
			return result;
		};

		/*
		Default Renderer for hierarchical table layout
		 */
		pivotTableRenderer = function(pivotData, opts) {
			var aggregator, c, colAttrs, colKey, colKeys, defaults, i, j, r, result, rowAttrs, rowKey, rowKeys, spanSize, td, th, totalAggregator, tr, txt, val, x;
			defaults = {
				localeStrings: {
					totals: "Totals"
				}
			};
			opts = $.extend(defaults, opts);

			colAttrs = pivotData.colAttrs;
			rowAttrs = pivotData.rowAttrs;
			rowKeys = pivotData.getRowKeys();
			colKeys = pivotData.getColKeys();
			result = document.createElement("table");
			result.className = "pvtTable";			
			
			if ($('.hidden-refresh-btn').text() != '' || get_report_name() != '') {
				var table_caption = result.createCaption();
				table_caption.innerHTML = $('.hidden-refresh-btn').text() || get_report_name();
			}

			spanSize = function(arr, i, j) {
				var len, noDraw, stop, x, _i, _j;
				if (i !== 0) {
					noDraw = true;
					for (x = _i = 0; 0 <= j ? _i <= j : _i >= j; x = 0 <= j ? ++_i : --_i) {
						if (arr[i - 1][x] !== arr[i][x]) {
							noDraw = false;
						}
					}
					if (noDraw) {
						return -1;
					}
				}
				len = 0;
				while (i + len < arr.length) {
					stop = false;
					for (x = _j = 0; 0 <= j ? _j <= j : _j >= j; x = 0 <= j ? ++_j : --_j) {
						if (arr[i][x] !== arr[i + len][x]) {
							stop = true;
						}
					}
					if (stop) {
						break;
					}
					len++;
				}
				return len;
			};
			var agg_len = pivotData.getAggregatorLength();

			detail_header_tr = document.createElement("tr");
			var details_total_tr = document.createElement("tr");

			var attr_name = pivotData.getAggregatorAttr();

			if (rowAttrs.length !== 0) {
				for (i in rowAttrs) {
					if (!__hasProp.call(rowAttrs, i)) continue;
					r = rowAttrs[i];
					th = document.createElement("th");
					th.className = "pvtAxisLabel";

					var row_attr_id = pivotData.getID(r, 'r');
					var custom_label = get_label(row_attr_id, r);
					var label = fx_get_col_alias(r);
					if (custom_label != '') label = custom_label;

					th.textContent = label; //convert col_name to alias fx_get_col_alias
					if (colAttrs.length === 0 && agg_len > 1) th.setAttribute("rowspan", 2);
					detail_header_tr.appendChild(th);
				}

				th = document.createElement("th");
				if (colAttrs.length === 0) {
					th.className = "pvtTotalLabel";
					th.innerHTML = opts.localeStrings.totals;
					th.setAttribute("colspan", agg_len);

					if (agg_len > 1) {
						for (var ag_cnt = 0; ag_cnt < agg_len; ag_cnt++) {
							th_th = document.createElement("th");
							th_th.innerHTML = attr_name[ag_cnt];
							details_total_tr.appendChild(th_th);
						}
					}
				} else {
					th.className = "pvtAxisLabel";
				}

				detail_header_tr.appendChild(th);
			}

			for (j in colAttrs) {
				if (!__hasProp.call(colAttrs, j)) continue;
				c = colAttrs[j];
				tr = document.createElement("tr");
				if (parseInt(j) === 0 && rowAttrs.length !== 0) {
					th = document.createElement("th");
					th.setAttribute("colspan", rowAttrs.length);
					th.setAttribute("rowspan", colAttrs.length);
					tr.appendChild(th);
				}
				th = document.createElement("th");
				th.className = "pvtAxisLabel";
				if (parseInt(j) === colAttrs.length - 1 && rowAttrs.length === 0) {
					th.setAttribute("rowspan", 2);
				}

				var col_attr_id = pivotData.getID(c, 'c');
				var custom_label = get_label(col_attr_id, c);
				var label = fx_get_col_alias(c);
				if (custom_label != '') label = custom_label;

				th.innerHTML = label;
				tr.appendChild(th);

				for (i in colKeys) {
					if (!__hasProp.call(colKeys, i)) continue;
					colKey = colKeys[i];
					x = spanSize(colKeys, parseInt(i), parseInt(j));

					if (agg_len > 0) {
						x = x * agg_len;
					}

					if (x > 0) {
						th = document.createElement("th");
						th.className = "pvtColLabel";

						var col_attr_id = pivotData.getID(c, 'c');
						var fmt_val = format_val(col_attr_id, colKey[j], c);

						th.innerHTML = fmt_val;
						th.setAttribute("colspan", x);

						if (agg_len == 1 && parseInt(j) === colAttrs.length - 1 && rowAttrs.length !== 0) {
							th.setAttribute("rowspan", 2);
						}

						if (parseInt(j) == colAttrs.length - 1) {
							if (agg_len > 1) {
								for (var ag_cnt = 0; ag_cnt < agg_len; ag_cnt++) {
									th_th = document.createElement("th");
									th_th.className = "pvtColLabel";
									// console.log(attr_name[ag_cnt]);
									// console.log(fx_get_col_alias(attr_name[ag_cnt]));
									
									var row_attr_id = pivotData.getID(attr_name[ag_cnt], 'v');
									var custom_label = get_label(row_attr_id, attr_name[ag_cnt]);
									var label = fx_get_col_alias(attr_name[ag_cnt]);
									if (custom_label != '') label = custom_label;

									th_th.innerHTML = label;
									detail_header_tr.appendChild(th_th);
								}
							}
						}
						tr.appendChild(th);
					}
				}

				if (parseInt(j) === 0) {
					th = document.createElement("th");
					th.className = "pvtTotalLabel pvtTotalTop";
					th.innerHTML = opts.localeStrings.totals;
					if (agg_len > 1) {
						th.setAttribute("rowspan", colAttrs.length);
					} else {
						th.setAttribute("rowspan", colAttrs.length + (rowAttrs.length === 0 ? 0 : 1));
					}
					th.setAttribute("colspan", agg_len);
					if (agg_len > 1) {
						for (var ag_cnt = 0; ag_cnt < agg_len; ag_cnt++) {
							th_th = document.createElement("th");

							var row_attr_id = pivotData.getID(attr_name[ag_cnt], 'v');
							var custom_label = get_label(row_attr_id, attr_name[ag_cnt]);
							var label = fx_get_col_alias(attr_name[ag_cnt]);
							if (custom_label != '') label = custom_label;

							th_th.innerHTML = label;
							detail_header_tr.appendChild(th_th);
						}
					}
					tr.appendChild(th);
				}
				result.appendChild(tr);
			}
			result.appendChild(detail_header_tr);

			if (agg_len > 1 && colAttrs.length === 0) {
				result.appendChild(details_total_tr);
			}

			var details_value_tr = document.createElement("tr");

			for (i in rowKeys) {
				if (!__hasProp.call(rowKeys, i)) continue;
				rowKey = rowKeys[i];
				tr = document.createElement("tr");
				for (j in rowKey) {
					if (!__hasProp.call(rowKey, j)) continue;
					txt = rowKey[j];
					var row_attr_id = pivotData.getID(rowAttrs[j], 'r');
					var fmt_val = format_val(row_attr_id, txt, rowAttrs[j]);

					x = spanSize(rowKeys, parseInt(i), parseInt(j));
					if (x !== -1) {
						th = document.createElement("th");
						th.className = "pvtRowLabel";
						th.innerHTML = fmt_val;
						th.setAttribute("rowspan", x);
						if (parseInt(j) === rowAttrs.length - 1 && colAttrs.length !== 0) {
							th.setAttribute("colspan", 2);
						}
						tr.appendChild(th);
					}
				}

				for (j in colKeys) {
					if (!__hasProp.call(colKeys, j)) continue;
					colKey = colKeys[j];
					aggregator = pivotData.getAggregator(rowKey, colKey);

					for (var ag_cnt = 0; ag_cnt < agg_len; ag_cnt++) {
						td = document.createElement("td");
						td.className = "row" + i + " col" + j;
						var attr_id = pivotData.getID(attr_name[ag_cnt], 'v');

						if (aggregator != null) {
							if (aggregator[ag_cnt]) {
								val = aggregator[ag_cnt].value();
								// here1
								var fmt_val = format_val(attr_id, aggregator[ag_cnt].format(val), attr_name[ag_cnt]);
								td.innerHTML = fmt_val;
								td.setAttribute("data-value", val);
							}
						}
						tr.appendChild(td);
					}
				}

				totalAggregator = pivotData.getAggregator(rowKey, []);
				for (var ag_cnt = 0; ag_cnt < agg_len; ag_cnt++) {
					td = document.createElement("td");
					td.className = "pvtTotal rowTotal";
					var attr_id = pivotData.getID(attr_name[ag_cnt], 'v');

					if (totalAggregator != null) {
						if (totalAggregator[ag_cnt]) {
							val = totalAggregator[ag_cnt].value();
							var fmt_val = format_val(attr_id, totalAggregator[ag_cnt].format(val), attr_name[ag_cnt]);
							td.innerHTML = fmt_val;
							td.setAttribute("data-value", val);
						}
					}
					tr.appendChild(td);
				}

				td.setAttribute("data-for", "row" + i);
				tr.appendChild(td);
				result.appendChild(tr);
			}

			tr = document.createElement("tr");
			th = document.createElement("th");
			th.className = "pvtTotalLabel";
			th.innerHTML = opts.localeStrings.totals;
			th.setAttribute("colspan", rowAttrs.length + (colAttrs.length === 0 ? 0 : 1));
			tr.appendChild(th);
			for (j in colKeys) {
				if (!__hasProp.call(colKeys, j)) continue;
				colKey = colKeys[j];
				totalAggregator = pivotData.getAggregator([], colKey);

				for (var ag_cnt = 0; ag_cnt < agg_len; ag_cnt++) {
					td = document.createElement("td");
					td.className = "pvtTotal colTotal";
					var attr_id = pivotData.getID(attr_name[ag_cnt], 'v');
					if (totalAggregator != null) {
						if (totalAggregator[ag_cnt]) {
							val = totalAggregator[ag_cnt].value();
							var fmt_val = format_val(attr_id, totalAggregator[ag_cnt].format(val), attr_name[ag_cnt]);
							td.innerHTML = fmt_val;
							td.setAttribute("data-value", val);
						}
					}
					td.setAttribute("data-for", "col" + j);
					tr.appendChild(td);
				}
			}
			totalAggregator = pivotData.getAggregator([], []);
			for (var ag_cnt = 0; ag_cnt < agg_len; ag_cnt++) {
				td = document.createElement("td");
				td.className = "pvtGrandTotal";
				var attr_id = pivotData.getID(attr_name[ag_cnt], 'v');
				if (totalAggregator != null) {
					if (totalAggregator[ag_cnt]) {
						val = totalAggregator[ag_cnt].value();
						var fmt_val = format_val(attr_id, totalAggregator[ag_cnt].format(val), attr_name[ag_cnt]);
						td.innerHTML = fmt_val;
						td.setAttribute("data-value", val);
					}
				}
				tr.appendChild(td);
			}
			result.appendChild(tr);
			result.setAttribute("data-numrows", rowKeys.length);
			result.setAttribute("data-numcols", colKeys.length);

			return result;
		};

		/*
		Pivot Table core: create PivotData object and call Renderer on it
		 */
		$.fn.pivot = function(input, opts) {
			var defaults, e, pivotData, result, x;
			defaults = {
				cols: [],
				rows: [],
				vals: [],
				filter: function() {
					return true;
				},
				aggregator: aggregatorTemplates.count()(),
				aggregatorName: ["Count"],
				sorters: function() {},
				derivedAttributes: {},
				renderer: pivotTableRenderer,
				rendererOptions: null,
				localeStrings: locales.en.localeStrings
			};
			
			
			opts = $.extend(defaults, opts);
			result = null;
			try {
				pivotData = new PivotData(input, opts);
				//console.log(pivotData);
				try {
					result = opts.renderer(pivotData, opts.rendererOptions);
				} catch (_error) {
					e = _error;
					if (typeof console !== "undefined" && console !== null) {
						console.error(e.stack);
					}
					result = $("<span>").html(opts.localeStrings.renderError);
				}
			} catch (_error) {
				e = _error;
				if (typeof console !== "undefined" && console !== null) {
					console.error(e.stack);
				}
				result = $("<span>").html(opts.localeStrings.computeError);
			}
			x = this[0];
			while (x.hasChildNodes()) {
				x.removeChild(x.lastChild);
			}
			return this.append(result);
		};

		/* search function for message and alert popup */
		/* new filter selector - case insensitive contains filter*/

		$.expr[':'].ci_contains = function(a, i, m) {
			return $(a).text().toLowerCase().indexOf(m[3].toLowerCase()) >= 0;
		};

		/*
		Pivot Table UI: calls Pivot Table core above with options set by user
		 */
		$.fn.pivotUI = function(input, inputOpts, overwrite, locale) {
			var a, aggregator, attrLength, axisValues, c, colList, defaults, e, existingOpts, i, initialRender, k, opts, pivotTable, refresh, refreshDelayed, renderer, rendererControl, shownAttributes, tblCols, tr1, tr2, uiTable, unusedAttrsVerticalAutoOverride, x, _fn, _i, _j, _k, _l, _len, _len1, _len2, _len3, _ref, _ref1, _ref2, _ref3, _ref4;
			if (overwrite == null) {
				overwrite = false;
			}
			if (locale == null) {
				locale = "en";
			}

			defaults = {
				derivedAttributes: {},
				aggregators: locales[locale].aggregators,
				renderers: locales[locale].renderers,
				hiddenAttributes: [],
				menuLimit: 200,
				cols: [],
				rows: [],
				vals: [],
				exclusions: {},
				unusedAttrsVertical: true,
				autoSortUnusedAttrs: false,
				rendererOptions: {
					localeStrings: locales[locale].localeStrings
				},
				onRefresh: null,
				filter: function() {
					return true;
				},
				sorters: function() {},
				localeStrings: locales[locale].localeStrings
			};
			
			existingOpts = this.data("pivotUIOptions");
			
			
			
			if ((existingOpts == null) || overwrite) {

				opts = $.extend(defaults, inputOpts);


			} else {
				opts = existingOpts;
			}
			try {
				input = PivotData.convertToArray(input);
				tblCols = (function() {
					var _ref, _results;
					_ref = input[0];
					_results = [];
					for (k in _ref) {
						if (!__hasProp.call(_ref, k)) continue;
						_results.push(k);
					}
					return _results;
				})();
				_ref = opts.derivedAttributes;
				for (c in _ref) {
					if (!__hasProp.call(_ref, c)) continue;
					if ((__indexOf.call(tblCols, c) < 0)) {
						tblCols.push(c);
					}
				}
				axisValues = {};
				for (_i = 0, _len = tblCols.length; _i < _len; _i++) {
					x = tblCols[_i];
					axisValues[x] = {};
				}
				PivotData.forEachRecord(input, opts.derivedAttributes, function(record) {
					var v, _base, _results;
					_results = [];
					for (k in record) {
						if (!__hasProp.call(record, k)) continue;
						v = record[k];
						if (!(opts.filter(record))) {
							continue;
						}
						if (v == null) {
							v = "null";
						}
						if ((_base = axisValues[k])[v] == null) {
							_base[v] = 0;
						}
						_results.push(axisValues[k][v]++);
					}
					return _results;
				});
				uiTable = $("<table>").attr({
					"id": "pvtMainTable"
				});
				rendererControl = $("<th>");
				renderer = $("<select>").addClass('pvtRenderer form-control input-sm').appendTo(rendererControl).bind("change", function() {
					update_watermark();
					return refresh();
				});
				_ref1 = opts.renderers;

				var dhx_rend_options = [];
				
				for (x in _ref1) {
					if (!__hasProp.call(_ref1, x)) continue;
					$("<option>").val(x).html(x).appendTo(renderer);
					dhx_rend_options.push({
				        "text": x,
				        "value": x
				    });
				}
				colList = $("<td>").addClass('pvtAxisContainer pvtUnused');
				shownAttributes = (function() {
					var _j, _len1, _results;
					_results = [];
					for (_j = 0, _len1 = tblCols.length; _j < _len1; _j++) {
						c = tblCols[_j];
						if (__indexOf.call(opts.hiddenAttributes, c) < 0) {
							_results.push(c);
						}
					}
					return _results;
				})();
				unusedAttrsVerticalAutoOverride = false;
				if (opts.unusedAttrsVertical === "auto") {
					attrLength = 0;
					for (_j = 0, _len1 = shownAttributes.length; _j < _len1; _j++) {
						a = shownAttributes[_j];
						attrLength += a.length;
					}
					unusedAttrsVerticalAutoOverride = attrLength > 120;
				}
				if (opts.unusedAttrsVertical === true || unusedAttrsVerticalAutoOverride) {
					colList.addClass('pvtVertList');
				} else {
					colList.addClass('pvtHorizList');
				}

				/* search textbox */
				columnSearch = $("<input type='text' id='column_search' class='search-text form-control input-sm' placeholder='Search...'>").appendTo(rendererControl).bind("keyup", function(event, handler) {
					var context_box = $(this);
					var context_block = $('.pvtUnused li');
					var value = context_box.val();
					
					if (value == "") {
						context_block.show('', '', function() {
							//custom code added to remove style (display:list-item) causing improper behaviour on drag columns(on detail) and not placed back - sangam (modified:2017-03-16)
							context_block.removeAttr('style');
						});
						return;
					} else {
						context_block.hide();
					}

					try {
						//split the current value of searchInput
						var data = value.split(" ");
						//Recusively filter the jquery object to get results.
						$.each(data, function(i, v) {
							v = v.toLowerCase();
							context_block = context_block.filter("*:ci_contains(" + v + ")");
						});
					} catch (exp) {}
					//show the rows that match.
					context_block.show('', '', function() {
						//custom code added to remove style (display:list-item) causing improper behaviour on drag columns(on detail) and not placed back - sangam (modified:2017-03-16)
						context_block.removeAttr('style');
					});
				});

				_fn = function(c) {
					var attrElem, btns, checkContainer, filterItem, filterItemExcluded, hasExcludedItem, keys, showFilterList, triangleLink, updateFilter, v, valueList, _k, _len2, _ref2;
					keys = (function() {
						var _results;
						_results = [];
						for (k in axisValues[c]) {
							_results.push(k);
						}
						return _results;
					})();
					hasExcludedItem = false;
					valueList = $("<div>").addClass('pvtFilterBox').hide();
					valueList.append($("<h4>").text("" + c + " (" + keys.length + ")"));
					if (keys.length > opts.menuLimit) {
						valueList.append($("<p>").html(opts.localeStrings.tooMany));
					} else {
						btns = $("<p>").appendTo(valueList);
						btns.append($("<button>", {
							type: "button"
						}).html(opts.localeStrings.selectAll).bind("click", function() {
							return valueList.find("input:visible").prop("checked", true);
						}));
						btns.append($("<button>", {
							type: "button"
						}).html(opts.localeStrings.selectNone).bind("click", function() {
							return valueList.find("input:visible").prop("checked", false);
						}));
						btns.append($("<input>", {
							type: "text",
							placeholder: opts.localeStrings.filterResults,
							"class": "pvtSearch"
						}).bind("keyup", function() {
							var filter;
							filter = $(this).val().toLowerCase();
							return valueList.find('.pvtCheckContainer p').each(function() {
								var testString;
								testString = $(this).text().toLowerCase().indexOf(filter);
								if (testString !== -1) {
									return $(this).show();
								} else {
									return $(this).hide();
								}
							});
						}));
						checkContainer = $("<div>").addClass("pvtCheckContainer").appendTo(valueList);
						_ref2 = keys.sort(getSort(opts.sorters, c));
						for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
							k = _ref2[_k];
							v = axisValues[c][k];
							filterItem = $("<label>");
							filterItemExcluded = opts.exclusions[c] ? (__indexOf.call(opts.exclusions[c], k) >= 0) : false;
							hasExcludedItem || (hasExcludedItem = filterItemExcluded);
							$("<input>").attr("type", "checkbox").addClass('pvtFilter').attr("checked", !filterItemExcluded).data("filter", [c, k]).appendTo(filterItem);
							filterItem.append($("<span>").html(k));
							filterItem.append($("<span>").text(" (" + v + ")"));
							checkContainer.append($("<p>").append(filterItem));
						}
					}
					updateFilter = function() {
						var unselectedCount;
						unselectedCount = valueList.find("[type='checkbox']").length - valueList.find("[type='checkbox']:checked").length;

						if (unselectedCount > 0) {
							attrElem.addClass("pvtFilteredAttribute");
						} else {
							attrElem.removeClass("pvtFilteredAttribute");
						}
						if (keys.length > opts.menuLimit) {
							return valueList.toggle();
						} else {
							return valueList.toggle(0, refresh);
						}
					};
					$("<p>").appendTo(valueList).append($("<button>", {
						type: "button"
					}).text("OK").bind("click", updateFilter));
					showFilterList = function(e) {
						valueList.css({
							left: e.pageX,
							top: e.pageY
						}).toggle();
						valueList.find('.pvtSearch').val('');
						return valueList.find('.pvtCheckContainer p').show();
					};
					triangleLink = $("<span>").addClass('pvtTriangle').html(" &#x25BE;").bind("click", showFilterList);
					attrElem = $("<li>").addClass("axis_" + i).append($("<span>").addClass('pvtAttr').text(c).data("attrName", c).append(triangleLink));
					if (hasExcludedItem) {
						attrElem.addClass('pvtFilteredAttribute');
					}
					colList.append(attrElem).append(valueList);
					return attrElem.bind("dblclick", showFilterList);
				};
				for (i in shownAttributes) {
					if (!__hasProp.call(shownAttributes, i)) continue;
					c = shownAttributes[i];
					_fn(c);
				}
				main_thead = $("<thead>").appendTo(uiTable);
				tr1 = $("<tr>").appendTo(main_thead);

				/** changes from here */
				agd_td = $("<th class='agg_td pvtAggs pvtAxisContainer'>").appendTo(tr1);
				
				$("<th>").addClass('pvtAxisContainer pvtHorizList pvtCols').appendTo(tr1);
				main_tbody = $("<tbody>").appendTo(uiTable);
				tr2 = $("<tr>").appendTo(main_tbody);

				tr2.append($("<td>").addClass('pvtAxisContainer pvtRows').attr("valign", "top"));
				pivotTable = $("<td>").attr("valign", "top").addClass('pvtRendererArea').appendTo(tr2);

				if (opts.unusedAttrsVertical === true || unusedAttrsVerticalAutoOverride) {
					main_thead.find('tr:nth-child(1)').prepend(rendererControl);
					main_tbody.find('tr:nth-child(1)').prepend(colList);
				} else {
					main_thead.prepend($("<tr>").append(rendererControl).append(colList));
				}

				show_hide_block = $("<div class='pivot-menu-tool'>");
				hidden_refresh_btn = $("<a class='btn hidden-refresh-btn' title='Refresh' style='display:none;'></a>").appendTo(show_hide_block).bind("click", function() {
					return refresh();
				});
				hidden_x_axis_label = $('<input class="hidden-x-axis" type="hidden" name="hidden-x-axis" value=""/>').appendTo(show_hide_block);
				hidden_y_axis_label = $('<input class="hidden-y-axis" type="hidden" name="hidden-y-axis" value=""/>').appendTo(show_hide_block);
				
				show_hide_image = $("<a class='btn' id='expand_collapse' title='Expand/Collapse'><i class='fa fa-bars'></i></a>").appendTo(show_hide_block).bind("click", function() {
					var current_context = $(this).closest('#output');
					renderer_area = $(".pvtRendererArea", current_context);
					renderer_area.parent().parent().siblings().toggle();
					renderer_area.siblings().toggle();
					hide_view_panel();
				});

				var configure_window, configureLayout, configureForm, availableGrid, configInnerLayout, rowsGrid, columnsGrid, dataGrid, configMenu;
				$that = this;
				config_image = $("<a class='btn' title='Configure'><i class='fa fa-cogs'></i></a>").appendTo(show_hide_block).bind("click", function() {
					// if not done, items which were filtered out before will not be shown if moved to rows/cols/data grid after closing the config box.
					$('#column_search').val("").keyup();

					var current_context = $(this).closest('#output');

					if (configure_window != null && configure_window.unload != null) {
			            configure_window.unload();
			            configure_window = w1 = null;
			        }

					if (!configure_window) {
			            configure_window = new dhtmlXWindows();
			        }

			        var configWin = configure_window.createWindow('w1', 0, 0, 800, 600);
			        configWin.setText('Pivot Configuration');
			        configWin.centerOnScreen();
			        configWin.setModal(true);

			        if (configureLayout) {
						configureLayout = null;
			        }

			        if (configInnerLayout) {
						configInnerLayout = null;
			        }			        

			        configureLayout = configWin.attachLayout({
			        	pattern: "3T",
						cells: [
							{id: "a", height: 100, header: false},
							{id: "b", header: false, width: 250},
							{id: "c", text: "Used Fields"}
						]
			        });

			        var configFormJSON = [
			        					  {"type": "settings", "position": "label-top", "offsetLeft": 10, "inputWidth":200},
			        					  {"type": "block", "blockOffset":0, "list": [
			        					  	{"type":"combo","name":"dhx_renderer","label":"Renderer", "validate":"NotEmptywithSpace", "filtering":"true","options":dhx_rend_options}
			        					  ]},
			        					  {"type":"label", "offsetLeft": 20, "label":"* Drag and Drop fields within grids to configure report"},
			        					  {"type":"newcolumn"},
			        					  {"type": "block", "width":"auto", "blockOffset": 0, "class":"pull-right", "list": [
						                        {type: "button", name: "apply", "offsetTop":20, value: "Apply Changes", width:"auto", tooltip: "Next", className: "form-button1"},
						                        {"type":"newcolumn"},
						                        {type: "button", name: "cancel", "offsetTop":20, value: "Cancel", width:"70", "offsetLeft":20, tooltip: "Cancel", className: "form-button2"}
						                  ]}
			        					 ];			        						

			        configureForm = configureLayout.cells('a').attachForm();
			        configureForm.load(configFormJSON);

			        var main_div = $('.dhxwin_active');
			        var rend_val = $('.pvtRenderer', current_context).val();
			        configureForm.setItemValue("dhx_renderer", rend_val);
			        
					var item1 = $("div.dhxform_btn_txt");
			        var item2 = $("div.dhxform_item_label_left.form-button1").find(item1);
			        var item3 = $("div.dhxform_item_label_left.form-button2").find(item1);

			        $("div.dhxform_btn", $(main_div)).parents(".dhxform_base").last().addClass('pull-right');
			        $(item2).addClass('btn btn-default');
			        $(item2).removeClass('dhxform_btn_txt');
			        $(item3).addClass('btn btn-default');
			        $(item3).removeClass('dhxform_btn_txt');

					var aval_cols = {
					    rows: []
					};
					var columns_cols = {
					    rows: []
					};
					var rows_cols = {
					    rows: []
					};

					var data_cols = {
					    rows: []
					};

					colsAttrsContainer = $("th.pvtAxisContainer.pvtCols", current_context);
					$(colsAttrsContainer).children("li").each(function() { 
						$this = $(this);
						var id = $(this).attr('class').replace('ui-sortable-handle', '');						
						var label = $('span.pvtAttr', $this).contents().get(0).nodeValue;

						columns_cols.rows.push({
							 id:id,
							 data:[label, id] 
						});
					});

					rowsAttrsContainer = $("td.pvtAxisContainer.pvtRows", current_context);
					$(rowsAttrsContainer).children("li").each(function() { 
						$this = $(this);
						var id = $(this).attr('class').replace('ui-sortable-handle', '');
						var label = $('span.pvtAttr', $this).contents().get(0).nodeValue;

						rows_cols.rows.push({
							 id:id,
							 data:[label, id] 
						});
					});

					if (rend_val != 'Table') {
						dataAttrsContainer = $("th.pvtAxisContainer.pvtAggs", current_context);
						$(dataAttrsContainer).children("li").each(function() { 
							$this = $(this);
							var id = $(this).attr('class').replace('ui-sortable-handle', '').replace('pvtVals', '');
							var label = $('span.pvtAttr', $this).contents().get(0).nodeValue;
							var agg_val = $("select.pvtAggregator", $this).val();
							var graph_type = $("input.graph_type", $this).val();

							data_cols.rows.push({
								 id:id,
								 data:[label, id, agg_val, graph_type]
							});
						});
					}

					unusedAttrsContainer = $("td.pvtUnused.pvtAxisContainer", current_context);
					$(unusedAttrsContainer).children("li").each(function() { 
						$this = $(this);
						var id = $(this).attr('class').replace('ui-sortable-handle', '');
						var label = $('span.pvtAttr', $this).contents().get(0).nodeValue;		

						aval_cols.rows.push({
							 id:id,
							 data:[label, id] 
						});						
					});

					availableGrid = configureLayout.cells('b').attachGrid();
					availableGrid.setImagePath(js_image_path + "dhxgrid_web/"); 
					availableGrid.setHeader('Available Fields,ID'); 
	                availableGrid.setColumnIds('available_fields,fid');
	                availableGrid.setInitWidths('*,100');
	                availableGrid.setColTypes('ro,ro');
	                availableGrid.setColAlign('left,left');
	                availableGrid.setColSorting('str,str');
	                availableGrid.attachHeader('#text_filter,');
	                availableGrid.enableDragAndDrop(true);
	                availableGrid.setColumnsVisibility('false,true');
	                availableGrid.enableMultiselect(true)
	                availableGrid.init();
	                availableGrid.enableHeaderMenu();
	                availableGrid.parse(aval_cols, "json");
	                availableGrid.setStyle(
					    "", "cursor:move !important;","", ""
					);

                	var a_label = (rend_val == 'Table') ? 'Grouping Columns' : 'Rows';
                	var b_label = (rend_val == 'Table') ? 'Table Columns' : 'Columns';
                	var c_label = (rend_val == 'Table') ? ' ' : 'Data';

	                configInnerLayout = configureLayout.cells('c').attachLayout({
								        	pattern: "3U",
											cells: [
												{id: "a", text:a_label},
												{id: "b", text:b_label},
												{id: "c", text:c_label, height:200}
											]
								        });

			        rowsGrid = configInnerLayout.cells('a').attachGrid();
					rowsGrid.setImagePath(js_image_path + "dhxgrid_web/"); 
					rowsGrid.setHeader('Rows,ID');  
					rowsGrid.setNoHeader(true);              
	                rowsGrid.setColumnIds('rows,fid');
	                rowsGrid.setInitWidths('*,100');
	                rowsGrid.setColTypes('ro,ro');
	                rowsGrid.setColAlign('left,left');
	                rowsGrid.setColSorting('str,str');
	                rowsGrid.attachHeader('#text_filter,');
	                rowsGrid.enableDragAndDrop(true);
	                rowsGrid.setColumnsVisibility('false,true');
	                rowsGrid.enableMultiselect(true)
	                rowsGrid.init();
	                rowsGrid.enableHeaderMenu();
	                rowsGrid.parse(rows_cols, "json");
	                rowsGrid.setStyle(
					    "", "cursor:move !important;","", ""
					);
	                
	                columnsGrid = configInnerLayout.cells('b').attachGrid();
					columnsGrid.setImagePath(js_image_path + "dhxgrid_web/"); 
					columnsGrid.setHeader('Columns,ID');
					columnsGrid.setNoHeader(true);                   
	                columnsGrid.setColumnIds('columns,fid');
	                columnsGrid.setInitWidths('*,100');
	                columnsGrid.setColTypes('ro,ro');
	                columnsGrid.setColAlign('left,left');
	                columnsGrid.setColSorting('str,str');
	                columnsGrid.attachHeader('#text_filter,');
	                columnsGrid.enableDragAndDrop(true);
	                columnsGrid.setColumnsVisibility('false,true');
	                columnsGrid.enableMultiselect(true)
	                columnsGrid.init();
	                columnsGrid.enableHeaderMenu();
	                columnsGrid.parse(columns_cols, "json");	
	                columnsGrid.setStyle(
					    "", "cursor:move !important;","", ""
					);                


	                dataGrid = configInnerLayout.cells('c').attachGrid();
					dataGrid.setImagePath(js_image_path + "dhxgrid_web/"); 
					dataGrid.setHeader('Data,ID,Aggregator,Type');   
					dataGrid.setNoHeader(true);             
	                dataGrid.setColumnIds('data_fields,fid,data_agg,graph_type');
	                dataGrid.setInitWidths('200,100,150,150');
	                dataGrid.setColTypes('ro,ro,combo,combo');
	                dataGrid.setColAlign('left,left,left,left');
	                dataGrid.setColSorting('str,,str,str,left');
	                dataGrid.attachHeader('#text_filter,,#text_filter,#text_filter');
	                dataGrid.enableDragAndDrop(true);
	                dataGrid.setColumnsVisibility('false,true,false,true');
	                dataGrid.enableMultiselect(true)
	                dataGrid.init();
	                dataGrid.enableHeaderMenu();
	                dataGrid.enableEditEvents(true,false,true);
	                dataGrid.setStyle(
					    "", "cursor:move !important;","", ""
					);

	                var agg_index = dataGrid.getColIndexById('data_agg');
                	var config_agg_combo = dataGrid.getColumnCombo(agg_index);
                	config_agg_combo.load('{options:['+
						'{value: "Sum", text: "Sum", selected:true},'+
						'{value: "Average", text: "Average"},'+
						'{value: "Minimum", text: "Minimum"},'+
						'{value: "Maximum", text: "Maximum"}'+
					']}');

					var graph_type_index = dataGrid.getColIndexById('graph_type');
                	var graph_type_combo = dataGrid.getColumnCombo(graph_type_index);
                	graph_type_combo.load('{options:['+
						'{value: "line", text: "Line"},'+
						'{value: "area", text: "Area"},'+
						'{value: "bars", text: "Bars"},'+
						'{value: "steppedArea", text: "Stepped Area"}'+
					']}');

					if (rend_val != 'Table') {
		                dataGrid.parse(data_cols, "json");		                						
					}

					dataGrid.attachEvent("onDrop", function(sId,tId,dId,sObj,tObj,sCol,tCol){
					    if (tObj != sObj) {					    	
					    	_.each(dId.split(','), function(id) {
					    		var agg_index = dataGrid.getColIndexById('data_agg');
					    		var graph_type_index = dataGrid.getColIndexById('graph_type');

					    		dataGrid.cells(id, agg_index).setValue('Sum');
					    		dataGrid.cells(id, graph_type_index).setValue('line');
				    		});
					    } 

					    return true;
					});

					configureForm.attachEvent("onChange", function(name, value){
						if (name == 'dhx_renderer') {
							var a_label = (value == 'Table') ? 'Grouping Columns' : (value == 'CrossTab Table') ? 'Rows' : 'Series (Z)';
		                	var b_label = (value == 'Table') ? 'Table Columns' : (value == 'CrossTab Table') ? 'Columns' : 'Category (X)';
		                	var c_label = (value == 'Table') ? ' ' : (value == 'CrossTab Table') ? 'Data' : 'Data (Y)';

							configInnerLayout.cells('a').setText(a_label);
							configInnerLayout.cells('b').setText(b_label);
							configInnerLayout.cells('c').setText(c_label);

							if (value == 'Table') {
								dataGrid.forEachRow(function(row_id){
									dataGrid.moveRow(row_id,"row_sibling",0,availableGrid);
								})
								configInnerLayout.cells('c').setText(' ');
								configInnerLayout.cells('c').collapse();
								configInnerLayout.cells('c').hideArrow();
							} else {
								configInnerLayout.cells('c').expand();
								configInnerLayout.cells('c').showArrow();
							}

							var graph_type_index = dataGrid.getColIndexById('graph_type');

							if (value == 'Combo') {
								dataGrid.setColumnHidden(graph_type_index,false);
							} else {
								dataGrid.setColumnHidden(graph_type_index,true);
							}

							return true;
						}
					});
					configureForm.callEvent("onChange",["dhx_renderer",rend_val]);

					configureForm.attachEvent("onButtonClick", function(name){
						if (name == 'cancel') {
							configWin.close();
							return;
						}

						if (name == 'apply') {
							var unused = $("td.pvtUnused.pvtAxisContainer", current_context);
							var colsatt = $("th.pvtAxisContainer.pvtCols", current_context);
							var rowsatt = $("td.pvtAxisContainer.pvtRows", current_context);
							var aggsatt = $("th.pvtAxisContainer.pvtAggs", current_context);

							for (var i=0; i<availableGrid.getRowsNum(); i++){	
								var row_id = availableGrid.getRowId(i);							
								var class_id = availableGrid.cells(row_id,1).getValue();

								//$(unused).append($('body').find("." + class_id));
								$(unused).append(current_context.find("." + class_id));
								$li = $("." + class_id, $(unused));

								var li_content = $li.html();
		                    	var li_content_chk = li_content.toLowerCase();

		                    	if (li_content_chk.search('pvtattrdropdown') !== -1) {
						    		$li.removeClass("pvtVals");
						    		$li.children("span").removeClass("pvtAttrDropdown");
						    		$li.children("select").remove();
					    		}
							}

							for (var i=0; i<columnsGrid.getRowsNum(); i++){	
								var row_id = columnsGrid.getRowId(i);						
								var class_id = columnsGrid.cells(row_id,1).getValue();
								//remove extra class for custom column
								if (class_id.indexOf(' ') > -1) {
									class_id = class_id.split(' ')[0];
								}
								//$(colsatt).append($('body').find("." + class_id));
								$(colsatt).append(current_context.find("." + class_id));
							}

							for (var i=0; i<rowsGrid.getRowsNum(); i++){
								var row_id = rowsGrid.getRowId(i);
							    var class_id = rowsGrid.cells(row_id,1).getValue();
							    //remove extra class for custom column
								if (class_id.indexOf(' ') > -1) {
									class_id = class_id.split(' ')[0];
								}
								//$(rowsatt).append($('body').find("." + class_id));
								$(rowsatt).append(current_context.find("." + class_id));
							}

							var rend_val = configureForm.getItemValue('dhx_renderer');

							if (rend_val != '') {
								for (var i=0; i<dataGrid.getRowsNum(); i++){
									var row_id = dataGrid.getRowId(i);
									//console.log(row_id)
								    var class_id = dataGrid.cells(row_id,1).getValue();
								    var agg_index = dataGrid.getColIndexById('data_agg');
					    			var agg_val = dataGrid.cells(row_id, agg_index).getValue();

					    			var graph_type_index = dataGrid.getColIndexById('graph_type');
					    			var graph_type = dataGrid.cells(row_id, graph_type_index).getValue();


									//$(aggsatt).append($('body').find("." + class_id));
									$(aggsatt).append(current_context.find("." + class_id));	
									$li = $("." + class_id, $(aggsatt));

									var li_content = $li.html();
			                    	var li_content_chk = li_content.toLowerCase();
			                    	if (li_content_chk.search('</select>') === -1) {
			                    		var agg = $("<select>").addClass('pvtAggregator');
										_ref2 = opts.aggregators;
										for (x in _ref2) {
											if (!__hasProp.call(_ref2, x)) continue;

											if (agg_val == x) {
												agg.append($("<option selected>").val(x).html(x));
											} else {
												agg.append($("<option>").val(x).html(x));
											}
										}
										$li.addClass("pvtVals");
								        $li.children("span").addClass("pvtAttrDropdown");
								        $li.append(agg);								        
			                    	} else {
			                    		$("select.pvtAggregator", $li).val(agg_val);
			                    	}
									
									if (li_content_chk.search('<input type') === -1) {
										var gt = $('<input type="hidden" class="graph_type" value="' + graph_type + '">');
										$li.append(gt);
									} else {
										$("input.graph_type", $li).val(graph_type);
									}
								}
							}

							configWin.close();
							$(".pvtRenderer", current_context).val(rend_val);
							$('.pvtRenderer', current_context).trigger('change');
							return refresh();
							
						}
					});
				});
				
				var main_div = $("<div>");
				main_div.append(show_hide_block);
				main_div.append(uiTable);

				this.html(main_div);

				_ref3 = opts.cols;
				for (_k = 0, _len2 = _ref3.length; _k < _len2; _k++) {
					x = _ref3[_k];
					this.find(".pvtCols").append(this.find(".axis_" + ($.inArray(x, shownAttributes))));
				}
				_ref4 = opts.rows;
				for (_l = 0, _len3 = _ref4.length; _l < _len3; _l++) {
					x = _ref4[_l];
					this.find(".pvtRows").append(this.find(".axis_" + ($.inArray(x, shownAttributes))));
				}

				vals = opts.vals;
				agg_vals = opts.aggregatorName;

				graph_type_array = new Array();

				if (opts.graphType)
					graph_type_array = opts.graphType;

				for (_k = 0, _len2 = vals.length; _k < _len2; _k++) {
					x = vals[_k];
					this.find(".pvtAggs").append(this.find(".axis_" + ($.inArray(x, shownAttributes))));

					var aggsatt = $("th.pvtAxisContainer.pvtAggs");
					$li = $(".axis_" + ($.inArray(x, shownAttributes)), $(aggsatt));

					var agg = $("<select>").addClass('pvtAggregator');
					_ref2 = opts.aggregators;
					for (x in _ref2) {
						if (!__hasProp.call(_ref2, x)) continue;

						if (agg_vals[_k] == x) {
							agg.append($("<option selected>").val(x).html(x));
						} else {
							agg.append($("<option>").val(x).html(x));
						}
					}
					$li.addClass("pvtVals");
			        $li.children("span").addClass("pvtAttrDropdown");
			        $li.append(agg);

			        var gt_val = (graph_type_array.length == 0) ? 'line' : graph_type_array[_k];
			        var gt = $('<input type="hidden" class="graph_type" value="' + gt_val + '">');
					$li.append(gt);
				}


				/*if (opts.aggregatorName != null) {
					for (cnt = 1; cnt < opts.aggregatorName.length; cnt++) {
						add_remove('');
					}
					agg_vals = opts.aggregatorName;
					i = 0;
					this.find(".pvtAggregator").each(function() {
						$(this).val(agg_vals[i]);
						i++;
					});
				}
				*/
			
				if (opts.rendererName != null) {
					this.find(".pvtRenderer").val(opts.rendererName);
				}
				initialRender = true;
				refreshDelayed = (function(_this) {
					return function() {
						var attr, exclusions, inclusions, newDropdown, numInputsToProcess, pivotUIOptions, pvtVals, subopts, unusedAttrsContainer, vals, _len4, _m, _n, _ref5;
						subopts = {
							derivedAttributes: opts.derivedAttributes,
							localeStrings: opts.localeStrings,
							rendererOptions: opts.rendererOptions,
							sorters: opts.sorters,
							cols: [],
							rows: [],
							aggregatorName: [],
							vals: [],
							aggregator: [],
							graphType: []
						};

						vals = [];
						//_this.find(".pvtRows li span.pvtAttr").not('.custom-column').each(function() {
						_this.find(".pvtRows li span.pvtAttr").each(function() {
							return subopts.rows.push($(this).data("attrName"));
						});
						//_this.find(".pvtCols li span.pvtAttr").not('.custom-column').each(function() {
						_this.find(".pvtCols li span.pvtAttr").each(function() {

							return subopts.cols.push($(this).data("attrName"));
						});

						subopts.renderer = opts.renderers[renderer.val()];

						//remove all other aggregators if not crosstab table
						// if (renderer.val() != 'CrossTab Table') {
						// 	$('.pvtVals').remove();
						// }

						var rend_val = renderer.val();
				    	if (rend_val == 'Table') {
				    		$( ".pvtAggs" ).droppable( "option", "disabled", true );
				    		$( ".pvtAggs" ).sortable( "option", "disabled", true );
				    	} else {
				    		$( ".pvtAggs" ).droppable( "option", "disabled", false );
				    		$( ".pvtAggs" ).sortable( "option", "disabled", false );
				    	}

						var i = 0;
						var agg_val = new Array();
						var graph_type_arr = new Array();

							
						$(".pvtVals").each(function() {
							var __this = $(this);
							var agg = $("select.pvtAggregator", $(this));
							var current_val = '';
							agg_val.push(agg.val());

							var gt = $("input.graph_type", $(this));
							graph_type_arr.push(gt.val());

							numInputsToProcess = (_ref5 = opts.aggregators[agg.val()]([])().numInputs) != null ? _ref5 : 0;
							
							$(".pvtAttrDropdown", __this).each(function() {
								if (numInputsToProcess === 0) {
									return $(this).remove();
								} else {
									numInputsToProcess--;
									var csv_attr = $(this).attr('csv_col_name');

									if (typeof csv_attr !== typeof undefined && csv_attr !== false) {
										//console.log('first')
									    if (csv_attr !== "") {
											current_val = $(this).attr('csv_col_name');
											return vals.push($(this).attr('csv_col_name'));
										}
									} else {
										//console.log('second')
										if ($(this).contents().get(0).nodeValue != '') {
											current_val = $(this).contents().get(0).nodeValue;
											return vals.push($(this).contents().get(0).nodeValue);
										}
									}									
								}
							});
							if (initialRender) {
								initialRender = false;
							}


							subopts.aggregatorName.push(agg.val());
							subopts.vals.push(current_val);
							var current_value = new Array();
							current_value.push(current_val);
							subopts.aggregator.push(opts.aggregators[agg.val()](current_value));
							subopts.graphType.push(gt.val());
						});
							exclusions = {};
							_this.find('input.pvtFilter').not(':checked').each(function() {
								var filter;
								filter = $(this).data("filter");
								if (exclusions[filter[0]] != null) {
									return exclusions[filter[0]].push(filter[1]);
								} else {
									return exclusions[filter[0]] = [filter[1]];
								}
							});
						//console.log(exclusions);
							inclusions = {};
							_this.find('input.pvtFilter:checked').each(function() {
								var filter;
								filter = $(this).data("filter");
								if (exclusions[filter[0]] != null) {
									if (inclusions[filter[0]] != null) {
										return inclusions[filter[0]].push(filter[1]);
									} else {
										return inclusions[filter[0]] = [filter[1]];
									}
								}
							});

							subopts.filter = function(record) {
								var excludedItems, _ref6;
								if (!opts.filter(record)) {
									return false;
								}
								for (k in exclusions) {
									excludedItems = exclusions[k];
									if (_ref6 = "" + record[k], __indexOf.call(excludedItems, _ref6) >= 0) {
										return false;
									}
								}
								return true;
							};
												
						if (agg_val.length == 0){
							agg_val.push('Sum');
							subopts.aggregator.push(opts.aggregators['Sum'](agg_val));
						}

						if (graph_type_arr.length == 0) {
							graph_type_arr.push('line');
						}

						pivotTable.pivot(input, subopts);
						pivotUIOptions = $.extend(opts, {
							cols: subopts.cols,
							rows: subopts.rows,
							vals: vals,
							exclusions: exclusions,
							inclusionsInfo: inclusions,
							aggregatorName: agg_val,
							rendererName: renderer.val(),
							graphType:graph_type_arr
						});

						//console.log(pivotUIOptions);
						_this.data("pivotUIOptions", pivotUIOptions);

						/*******Adjust custom columns on re-ordering ***************/
						//update_detail_custom_cols();
						

						if (opts.autoSortUnusedAttrs) {
							unusedAttrsContainer = _this.find("td.pvtUnused.pvtAxisContainer");
							$(unusedAttrsContainer).children("li").sort(function(a, b) {
								return naturalSort($(a).text(), $(b).text());
							}).appendTo(unusedAttrsContainer);
						}

						pivotTable.css("opacity", 1);
						if (opts.onRefresh != null) {
							return opts.onRefresh(pivotUIOptions);
						}
					};
				})(this);
				refresh = (function(_this) {
					return function() {
						pivotTable.css("opacity", 0.5);
						return setTimeout(refreshDelayed, 10);
					};
				})(this);
				refresh();

				this.find(".pvtAxisContainer").sortable({
					update: function(e, ui) {
						if (ui.sender == null) {
							return refresh();
						}
					},
					connectWith: this.find(".pvtAxisContainer"),
					items: 'li',
					placeholder: 'pvtPlaceholder'
				});

				this.find(".pvtAggs").droppable({
			    	drop: function( event, ui ) {
			    		var li_content = ui.draggable.html();
                    	var li_content_chk = li_content.toLowerCase();
                    	if (li_content_chk.search('</select>') === -1) {
                    		var agg = $("<select>").addClass('pvtAggregator');
							_ref2 = opts.aggregators;
							for (x in _ref2) {
								if (!__hasProp.call(_ref2, x)) continue;
								agg.append($("<option>").val(x).html(x));
							}
							ui.draggable.addClass("pvtVals");
					        ui.draggable.children("span").addClass("pvtAttrDropdown");//.append(agg);
					        ui.draggable.append(agg);
                    	}

                    	if (li_content_chk.search('<input type') === -1) {
							var gt = $('<input type="hidden" class="graph_type" value="line">');
							ui.draggable.append(gt);
						}				      	
			    	}
			    });

			    this.find(".pvtCols").droppable({
			    	drop: function( event, ui ) {
			    		var li_content = ui.draggable.html();
                    	var li_content_chk = li_content.toLowerCase();

                    	if (li_content_chk.search('pvtattrdropdown') !== -1) {
				    		ui.draggable.removeClass("pvtVals");
				    		ui.draggable.children("span").removeClass("pvtAttrDropdown");
				    		ui.draggable.children("select").remove();
				    		ui.draggable.children("input").remove();
			    		}

		    		}

		    	});	

		    	this.find(".pvtRows, .pvtUnused").droppable({
			    	drop: function( event, ui ) {
			    		var li_content = ui.draggable.html();
                    	var li_content_chk = li_content.toLowerCase();

                    	if (li_content_chk.search('pvtattrdropdown') !== -1) {
				    		ui.draggable.removeClass("pvtVals");
				    		ui.draggable.children("span").removeClass("pvtAttrDropdown");
				    		ui.draggable.children("select").remove();
			    		}

		    		}

		    	});		
			} catch (_error) {
				e = _error;
				if (typeof console !== "undefined" && console !== null) {
					console.error(e.stack);
				}
				this.html(opts.localeStrings.uiRenderError);
			}
			return this;
		};

		/*
		Heatmap post-processing
		 */
		$.fn.heatmap = function(scope) {
			var colorGen, heatmapper, i, j, numCols, numRows, _i, _j;
			if (scope == null) {
				scope = "heatmap";
			}
			numRows = this.data("numrows");
			numCols = this.data("numcols");
			colorGen = function(color, min, max) {
				var hexGen;
				hexGen = (function() {
					switch (color) {
						case "red":
							return function(hex) {
								return "ff" + hex + hex;
							};
						case "green":
							return function(hex) {
								return "" + hex + "ff" + hex;
							};
						case "blue":
							return function(hex) {
								return "" + hex + hex + "ff";
							};
					}
				})();
				return function(x) {
					var hex, intensity;
					intensity = 255 - Math.round(255 * (x - min) / (max - min));
					hex = intensity.toString(16).split(".")[0];
					if (hex.length === 1) {
						hex = 0 + hex;
					}
					return hexGen(hex);
				};
			};
			heatmapper = (function(_this) {
				return function(scope, color) {
					var colorFor, forEachCell, values;
					forEachCell = function(f) {
						return _this.find(scope).each(function() {
							var x;
							x = $(this).data("value");
							if ((x != null) && isFinite(x)) {
								return f(x, $(this));
							}
						});
					};
					values = [];
					forEachCell(function(x) {
						return values.push(x);
					});
					colorFor = colorGen(color, Math.min.apply(Math, values), Math.max.apply(Math, values));
					return forEachCell(function(x, elem) {
						return elem.css("background-color", "#" + colorFor(x));
					});
				};
			})(this);
			switch (scope) {
				case "heatmap":
					heatmapper(".pvtVal", "red");
					break;
				case "rowheatmap":
					for (i = _i = 0; 0 <= numRows ? _i < numRows : _i > numRows; i = 0 <= numRows ? ++_i : --_i) {
						heatmapper(".pvtVal.row" + i, "red");
					}
					break;
				case "colheatmap":
					for (j = _j = 0; 0 <= numCols ? _j < numCols : _j > numCols; j = 0 <= numCols ? ++_j : --_j) {
						heatmapper(".pvtVal.col" + j, "red");
					}
			}
			heatmapper(".pvtTotal.rowTotal", "red");
			heatmapper(".pvtTotal.colTotal", "red");
			return this;
		};

		/*
		Barchart post-processing
		 */
		return $.fn.barchart = function() {
			var barcharter, i, numCols, numRows, _i;
			numRows = this.data("numrows");
			numCols = this.data("numcols");
			barcharter = (function(_this) {
				return function(scope) {
					var forEachCell, max, scaler, values;
					forEachCell = function(f) {
						return _this.find(scope).each(function() {
							var x;
							x = $(this).data("value");
							if ((x != null) && isFinite(x)) {
								return f(x, $(this));
							}
						});
					};
					values = [];
					forEachCell(function(x) {
						return values.push(x);
					});
					max = Math.max.apply(Math, values);
					scaler = function(x) {
						return 100 * x / (1.4 * max);
					};
					return forEachCell(function(x, elem) {
						var text, wrapper;
						text = elem.text();
						wrapper = $("<div>").css({
							"position": "relative",
							"height": "55px"
						});
						wrapper.append($("<div>").css({
							"position": "absolute",
							"bottom": 0,
							"left": 0,
							"right": 0,
							"height": scaler(x) + "%",
							"background-color": "gray"
						}));
						wrapper.append($("<div>").text(text).css({
							"position": "relative",
							"padding-left": "5px",
							"padding-right": "5px"
						}));
						return elem.css({
							"padding": 0,
							"padding-top": "5px",
							"text-align": "center"
						}).html(wrapper);
					});
				};
			})(this);
			for (i = _i = 0; 0 <= numRows ? _i < numRows : _i > numRows; i = 0 <= numRows ? ++_i : --_i) {
				barcharter(".pvtVal.row" + i);
			}
			barcharter(".pvtTotal.colTotal");
			return this;
		};
	});

}).call(this);

function update_detail_custom_cols() {

	var custom_col_tr = $('.pvtCols li');
	var custom_row_tr = $('.pvtRows li');
	

	if(custom_col_tr.length > 0) {
	    var custom_col_info = [];
	    var t = 0;
	    $.each(custom_col_tr, function(k, tr) {	    	
	    	var v = $(tr).text();
	    	if (v != '') {
	        	if (v.indexOf('(CC)') > -1) {
                 custom_col_info.push(
                    {
                        'item_id' : v.replace('(CC)','').replace(/ /g,''),
                        'column_alias' : v.replace('(CC)',''),
                        'column_order' : k + custom_row_tr.length
                    });
               }
               t++;
           }
	    })
	    if (custom_col_info.length > 0) {
                window.fx_adjust_custom_columns(custom_col_info,'drag');
    	}
	}
}

//# sourceMappingURL=pivot.js.map