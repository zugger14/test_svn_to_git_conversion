/**
 *  @brief PS Enhancement on DHTMLX
 *  @note This file should always be included after the dhtmlx.js
 *  
 *  @par Description
 *  This file will be used to include all the enhancement done on DHTMLX library for TRMTracker.
 *  This file is used instead of changing the dhtmlx file directly, which means on every upgrade of DHTMLX library, this file might need some review.
 *  
 *  </pre>
 *  @author    Rajiv Basnet <rajiv@pioneersolutionsglobal.com>
 *  @version   3.0
 *  @date      2015-07-08
 *  @copyright Pioneer Solutions.
 */


/* Custom columns types for grid */

/**
 * Column type for checkbox combo
 * @param   {Object}  cell  Cell object
 */
function eXcell_multi_combo(cell) {
    if (!cell) {
        return
    }
 
    this.cell = cell;
    this.grid = cell.parentNode.grid;
    this.base = eXcell_combo;
    this.base(cell);

    this.edit = function() {
        if (!window.dhx_globalImgPath) {
            window.dhx_globalImgPath = this.grid.imgURL
        }
        this.val = this.getValue();
        var c = this.getText();
        if (this.cell._clearCell) {
            c = ""
        }
        this.cell.innerHTML = "";
    
        if (!this.cell._brval) {
            this.combo = (this.grid._realfake ? this.grid._fake : this.grid)._col_combos[this.cell._cellIndex]
            this.cell._brval = this.combo
        } else {
            this.combo = this.cell._brval
        }
        this.cell.appendChild(this.combo.DOMParent);

        /* Added to check options right after combo is added */
        /* ------------------------------------------------- */
        this.combo.forEachOption(function(optId) {
            if(c.indexOf(optId.text) >= 0){
                this.combo.setChecked(optId.index, true);
            } else {
                this.combo.setChecked(optId.index, false);
            }
        }.bind(this));
        /* ------------------------------------------------- */

        this.combo.DOMParent.style.margin = "0";
        this.combo.DOMelem_input.focus();
        this.combo.setSize(this.cell.offsetWidth - 2);
        if (!this.combo._xml) {
            if (this.combo.getIndexByValue(this.cell.combo_value) != -1) {
                this.combo.selectOption(this.combo.getIndexByValue(this.cell.combo_value))
            } else {
                if (this.combo.getOptionByLabel(c)) {
                    this.combo.selectOption(this.combo.getIndexByValue(this.combo.getOptionByLabel(c).value))
                } else {
                    this.combo.setComboText(c)
                }
            }
        } else {
            this.combo.setComboText(c)
        }
        this.combo.openSelect()
    };

    this.getValue = function(c) {
        return this.grid.getColumnCombo(this.grid.cell.cellIndex).getChecked().join(',') || ""
    };

    this.setValue = function(l) {
        if (typeof(l) == "object") {
            this.cell._brval = this.initCombo();
            var g = this.cell._cellIndex;
            var h = this.cell.parentNode.idd;
            if (!l.firstChild) {    
                this.cell.combo_value = "&nbsp;";
                this.cell._clearCell = true
            } else {
                this.cell.combo_value = l.firstChild.data
            }
            this.setComboOptions(this.cell._brval, l, this.grid, g, h)
        } else {
            this.cell.combo_value = l;
            var c = null;
            if ((c = this.cell._brval) && (typeof(this.cell._brval) == "object")) {
                l = (c.getOption(l) || {}).text || l
            } else {
                if (c = this.grid._col_combos[this.cell._cellIndex] || ((this.grid._fake) && (c = this.grid._fake._col_combos[this.cell._cellIndex]))) {
                    l = (c.getOption(l) || {}).text || l;
                }
            }

            if ((l || "").toString()._dhx_trim() == "") {
                l = null
            }

            if (l !== null) {

                /* Added to generate coma-separated labels from coma-separated ids */
                /* --------------------------------------------------------------- */
                var new_text = l.split(',').map(function(e) {
                    return c.getOption(e).text;
                })
                l = new_text;
                /* --------------------------------------------------------------- */

                this.setComboCValue(l);
                this.cell._clearCell = false
            } else {
                this.setComboCValue("&nbsp;", "");
                this.cell._clearCell = true
            }
        }
    };
}

eXcell_multi_combo.prototype = new eXcell_combo;

/**
 * Initialize Multi combo
 * @param   {Integer}  c  Cell Index
 * @return  {Object}      Combo
 */
eXcell_multi_combo.prototype.initCombo = function(c) {
    var a = document.createElement("DIV");
    a.className = "dhxcombo_in_grid_parent";
    var h = this.grid.defVal[arguments.length ? c : this.cell._cellIndex];
    var l = new dhtmlXCombo(a, "combo", 0, "custom_checkbox");
    this.grid.defVal[arguments.length ? c : this.cell._cellIndex] = "";
    var g = this.grid;
    l.DOMelem.onmousedown = l.DOMelem.onclick = function(m) {
        m = m || event;
        m.cancelBubble = true
    };
    l.DOMelem.onselectstart = function(m) {
        m = m || event;
        m.cancelBubble = true;
        return true
    };
    l.attachEvent("onKeyPressed", function(m) {
        if (m == 13 || m == 27) {
            g.editStop();
            if (g._fake) {
                g._fake.editStop()
            }
        }
    });
    return l
};



/* Added to support different number format in grid*/
function eXcell_edn(cell) {
    if (cell) {
        this.cell = cell;
        this.grid = this.cell.parentNode.grid
    }
    this.getValue = function() {
        if ((this.cell.firstChild) && (this.cell.firstChild.tagName == "TEXTAREA")) {
            return this.cell.firstChild.value
        }
        if (this.cell._clearCell) {
            return ""
        }
        return this.cell._orig_value || this.grid._aplNFb(this.cell.innerHTML.toString()._dhx_trim(), this.cell._cellIndex)
    };

    this.edit = function() {
        this.cell.atag = (!this.grid.multiLine) ? "INPUT" : "TEXTAREA";
        this.val = this.getValue();
        this.obj = document.createElement(this.cell.atag);
        this.obj.setAttribute("autocomplete", "off");
        this.obj.style.height = (this.cell.offsetHeight - (_isIE ? 4 : 4)) + "px";
        this.obj.className = "dhx_combo_edit";
        this.obj.wrap = "soft";
        this.obj.style.textAlign = this.cell.style.textAlign;
        this.obj.onclick = function(c) {
            (c || event).cancelBubble = true
        };
        this.obj.onmousedown = function(c) {
            (c || event).cancelBubble = true
        };

        if (this.cell._orig_value && this.val) {
            var display_value = this.cell._orig_value;
            display_value = display_value.replace('.',global_decimal_separator);
            this.obj.value = display_value;
        } else {
            this.obj.value = this.val;
        }
        this.cell.innerHTML = "";
        this.cell.appendChild(this.obj);
        this.obj.onselectstart = function(c) {
            if (!c) {
                c = event
            }
            c.cancelBubble = true;
            return true
        };
        if (_isIE) {
            this.obj.focus();
            this.obj.blur()
        }
        this.obj.focus()
    };

    this.setValue = function(val) {
        if (val) {
            var decimal_seperator = global_decimal_separator;
            val = val.toString().replace(decimal_seperator,'.');
        }
        if (!val || val.toString()._dhx_trim() == "") {
            this.cell._clearCell = true;
            return this.setCValue("&nbsp;", 0)
        } else {
            this.cell._clearCell = false;
            this.cell._orig_value = val
        }

        this.setCValue(this.grid._aplNF(val, this.cell._cellIndex), val)
    }

    this.detach = function() {
        var c = this.obj.value;
        this.setValue(c);
        return this.val != this.getValue()
    }
    if (this.grid) {
        var column_data_type = '';
        var column_data_type_fake = '';
        if (this.grid.hasOwnProperty('_column_data_type')) {
            column_data_type = this.grid._column_data_type[this.cell._cellIndex];
        }
        if (this.grid.hasOwnProperty('_fake')) {
            this.grid._fake._noFormatArr[this.cell._cellIndex] = '0';
            if (this.grid._fake.hasOwnProperty('_column_data_type')) {
                column_data_type_fake = this.grid._fake._column_data_type[this.cell._cellIndex];
            }
        }
        column_data_type = (column_data_type)?column_data_type:column_data_type_fake;

        if (this.grid._noFormatArr[this.cell._cellIndex]) {
            this.grid.setNumberFormat(this.grid._noFormatArr[this.cell._cellIndex],this.cell._cellIndex);
        } else {
            if (this.grid.hasOwnProperty('_cell_number_format')) {
                var cell_number_format = __global_number_format__;
                cell_number_format = (this.grid._cell_number_format[this.cell._cellIndex] && this.grid._cell_number_format[this.cell._cellIndex] != '') ? this.grid._cell_number_format[this.cell._cellIndex] : __global_number_format__;
                this.grid.setNumberFormat(cell_number_format,this.cell._cellIndex, global_decimal_separator, '');
            } else {
                this.grid.setNumberFormat(__global_number_format__,this.cell._cellIndex, global_decimal_separator, '');
            }
        }
    }
}

eXcell_edn.prototype = new eXcell_ed;

function eXcell_ron(a) {
    this.cell = a;
    this.grid = this.cell.parentNode.grid;
    this.edit = function() {};
    this.isDisabled = function() {
        return true
    };
    this.getValue = function() {
        return this.cell._clearCell ? "" : this.cell._orig_value || this.grid._aplNFb(this.cell.innerHTML.toString()._dhx_trim(), this.cell._cellIndex).toString()
    }
    this.setValue = function(val) {
        if (val) {
            var decimal_seperator = global_decimal_separator;
            val = val.toString().replace(decimal_seperator,'.');
        }

        if (val === 0) {} else {
            if (!val || val.toString()._dhx_trim() == "") {
                this.setCValue("&nbsp;");
                return this.cell._clearCell = true
            }
        }
        this.cell._orig_value = val;
        this.cell._clearCell = false;
        this.setCValue(val ? this.grid._aplNF(val, this.cell._cellIndex) : "0");

    };
    if (this.grid) {
        var column_data_type = '';
        var column_data_type_fake = '';
        if (this.grid.hasOwnProperty('_column_data_type')) {
            column_data_type = this.grid._column_data_type[this.cell._cellIndex];
        }
        if (this.grid.hasOwnProperty('_fake')) {
            this.grid._fake._noFormatArr[this.cell._cellIndex] = '0';
            if (this.grid._fake.hasOwnProperty('_column_data_type')) {
                column_data_type_fake = this.grid._fake._column_data_type[this.cell._cellIndex];
            }
        }
        column_data_type = (column_data_type)?column_data_type:column_data_type_fake;

        if (this.grid._noFormatArr[this.cell._cellIndex]) {
            this.grid.setNumberFormat(this.grid._noFormatArr[this.cell._cellIndex], this.cell._cellIndex);
        } else {
            if (this.grid.hasOwnProperty('_cell_number_format')) {
                var cell_number_format = __global_number_format__;
                cell_number_format = (this.grid._cell_number_format[this.cell._cellIndex] && this.grid._cell_number_format[this.cell._cellIndex] != '') ? this.grid._cell_number_format[this.cell._cellIndex] : __global_number_format__;
                this.grid.setNumberFormat(cell_number_format, this.cell._cellIndex, global_decimal_separator, '');
            } else {
                this.grid.setNumberFormat(__global_number_format__, this.cell._cellIndex, global_decimal_separator, '');
            }
        }

    }
}
eXcell_ron.prototype = new eXcell;


/**
 * Column type for editable Numbers.
 * @param  {Object} cell Cell object
 */
function eXcell_ed_no(cell) {
    if (cell) {
        this.cell = cell;
        this.grid = this.cell.parentNode.grid;
        eXcell_edn.call(this);
    }

    this.detach = function() {
        var c = this.obj.value;
        c = c.toString().replace(global_decimal_separator, ".")
        this.setValue(c);
        return this.val != this.getValue()
    }

    var column_data_type = '';
    var column_data_type_fake = '';
    if (this.grid.hasOwnProperty('_column_data_type')) {
        column_data_type = this.grid._column_data_type[this.cell._cellIndex];
    }
    if (this.grid.hasOwnProperty('_fake')) {
        this.grid._fake._noFormatArr[this.cell._cellIndex] = '0';
        if (this.grid._fake.hasOwnProperty('_column_data_type')) {
            column_data_type_fake = this.grid._fake._column_data_type[this.cell._cellIndex];
        }
    }
    column_data_type = (column_data_type)?column_data_type:column_data_type_fake;

    if (this.grid._noFormatArr[this.cell._cellIndex] != '' && this.grid._noFormatArr[this.cell._cellIndex] !== undefined) {
        this.grid.setNumberFormat(this.grid._noFormatArr[this.cell._cellIndex], this.cell._cellIndex);
    } else {
        if (this.grid.hasOwnProperty('_cell_number_format')) {
            var cell_number_format = __global_number_format__;
            cell_number_format = (this.grid._cell_number_format[this.cell._cellIndex] && this.grid._cell_number_format[this.cell._cellIndex] != '') ? this.grid._cell_number_format[this.cell._cellIndex] : __global_number_format__;
            this.grid.setNumberFormat(cell_number_format, this.cell._cellIndex, global_decimal_separator, global_group_separator);
        } else {
            this.grid.setNumberFormat(__global_number_format__, this.cell._cellIndex, global_decimal_separator, global_group_separator);
        }
    }
}
eXcell_ed_no.prototype = new eXcell_edn;// nests all other methods from the base class

/**
 * Column type for editable price.
 * @param  {Object} cell Cell Object
 */
function eXcell_ed_p(cell) {
    if (cell) {
        this.cell = cell;
        this.grid = this.cell.parentNode.grid;
        eXcell_edn.call(this);
    }

    this.detach = function() {
        var c = this.obj.value;
        c = c.toString().replace(global_decimal_separator, ".")
        this.setValue(c);
        return this.val != this.getValue()
    }

    var column_data_type = '';
    var column_data_type_fake = '';
    if (this.grid.hasOwnProperty('_column_data_type')) {
        column_data_type = this.grid._column_data_type[this.cell._cellIndex];
    }
    if (this.grid.hasOwnProperty('_fake')) {
        this.grid._fake._noFormatArr[this.cell._cellIndex] = '0';
        if (this.grid._fake.hasOwnProperty('_column_data_type')) {
            column_data_type_fake = this.grid._fake._column_data_type[this.cell._cellIndex];
        }
    }
    column_data_type = (column_data_type)?column_data_type:column_data_type_fake;

    if (this.grid._noFormatArr[this.cell._cellIndex]) {
        this.grid.setNumberFormat(this.grid._noFormatArr[this.cell._cellIndex], this.cell._cellIndex);
    } else {
        if (this.grid.hasOwnProperty('_cell_number_format')) {
            var cell_number_format = __global_price_format__;
            cell_number_format = (this.grid._cell_number_format[this.cell._cellIndex] && this.grid._cell_number_format[this.cell._cellIndex] != '') ? this.grid._cell_number_format[this.cell._cellIndex] : __global_number_format__;
            this.grid.setNumberFormat(cell_number_format, this.cell._cellIndex, global_decimal_separator, global_group_separator);
        } else {
            this.grid.setNumberFormat(__global_price_format__, this.cell._cellIndex, global_decimal_separator, global_group_separator);
        }
    }
}
eXcell_ed_p.prototype = new eXcell_edn;

/**
 * Column type for read only number.
 * @param  {Object} cell Cell object
 */
function eXcell_ro_no(cell) {
    if (cell) {
        this.cell = cell;
        this.grid = this.cell.parentNode.grid;
        eXcell_edn.call(this);
    }
    this.edit = function() {};
    this.isDisabled = function() {
        return true
    };

    var column_data_type = '';
    var column_data_type_fake = '';
    if (this.grid.hasOwnProperty('_column_data_type')) {
        column_data_type = this.grid._column_data_type[this.cell._cellIndex];
    }
    if (this.grid.hasOwnProperty('_fake')) {
        this.grid._fake._noFormatArr[this.cell._cellIndex] = '0';
        if (this.grid._fake.hasOwnProperty('_column_data_type')) {
            column_data_type_fake = this.grid._fake._column_data_type[this.cell._cellIndex];
        }
    }
    column_data_type = (column_data_type)?column_data_type:column_data_type_fake;

    if (this.grid._noFormatArr[this.cell._cellIndex]) {
        this.grid.setNumberFormat(this.grid._noFormatArr[this.cell._cellIndex], this.cell._cellIndex);
    } else {
        if (this.grid.hasOwnProperty('_cell_number_format')) {
            var cell_number_format = __global_number_format__;
            cell_number_format = (this.grid._cell_number_format[this.cell._cellIndex] && this.grid._cell_number_format[this.cell._cellIndex] != '') ? this.grid._cell_number_format[this.cell._cellIndex] : __global_number_format__;
            this.grid.setNumberFormat(cell_number_format, this.cell._cellIndex, global_decimal_separator, global_group_separator);
        } else {
            this.grid.setNumberFormat(__global_number_format__, this.cell._cellIndex, global_decimal_separator, global_group_separator);
        }
    }
}
eXcell_ro_no.prototype = new eXcell_edn;

/**
 * Column type for read only price.
 * @param  {Object} cell Cell Object
 */
function eXcell_ro_p(cell) {
    if (cell) {
        this.cell = cell;
        this.grid = this.cell.parentNode.grid;
        eXcell_edn.call(this);
    }
    this.edit = function() {};
    this.isDisabled = function() {
        return true
    };

    var column_data_type = '';
    var column_data_type_fake = '';
    if (this.grid.hasOwnProperty('_column_data_type')) {
        column_data_type = this.grid._column_data_type[this.cell._cellIndex];
    }
    if (this.grid.hasOwnProperty('_fake')) {
        this.grid._fake._noFormatArr[this.cell._cellIndex] = '0';
        if (this.grid._fake.hasOwnProperty('_column_data_type')) {
            column_data_type_fake = this.grid._fake._column_data_type[this.cell._cellIndex];
        }
    }
    column_data_type = (column_data_type)?column_data_type:column_data_type_fake;

    if (this.grid._noFormatArr[this.cell._cellIndex]) {
        this.grid.setNumberFormat(this.grid._noFormatArr[this.cell._cellIndex], this.cell._cellIndex);
    } else {
        if (this.grid.hasOwnProperty('_cell_number_format')) {
            var cell_number_format = __global_price_format__;
            cell_number_format = (this.grid._cell_number_format[this.cell._cellIndex] && this.grid._cell_number_format[this.cell._cellIndex] != '') ? this.grid._cell_number_format[this.cell._cellIndex] : __global_number_format__;
            this.grid.setNumberFormat(cell_number_format, this.cell._cellIndex, global_decimal_separator, global_group_separator);
        } else {
            this.grid.setNumberFormat(__global_price_format__, this.cell._cellIndex, global_decimal_separator, global_group_separator);
        }
    }
}
eXcell_ro_p.prototype = new eXcell_edn;

/**
 * Column type for editable amount.
 * @param  {Object} cell Cell Object
 */
function eXcell_ed_a(cell) {
    if (cell) {
        this.cell = cell;
        this.grid = this.cell.parentNode.grid;
        eXcell_edn.call(this);
    }

    this.detach = function() {
        var c = this.obj.value;
        c = c.toString().replace(global_decimal_separator, ".")
        this.setValue(c);
        return this.val != this.getValue()
    }

    var column_data_type = '';
    var column_data_type_fake = '';
    if (this.grid.hasOwnProperty('_column_data_type')) {
        column_data_type = this.grid._column_data_type[this.cell._cellIndex];
    }
    if (this.grid.hasOwnProperty('_fake')) {
        this.grid._fake._noFormatArr[this.cell._cellIndex] = '0';
        if (this.grid._fake.hasOwnProperty('_column_data_type')) {
            column_data_type_fake = this.grid._fake._column_data_type[this.cell._cellIndex];
        }
    }
    column_data_type = (column_data_type)?column_data_type:column_data_type_fake;

    if (this.grid._noFormatArr[this.cell._cellIndex]) {
        this.grid.setNumberFormat(this.grid._noFormatArr[this.cell._cellIndex], this.cell._cellIndex);
    } else {
        if (this.grid.hasOwnProperty('_cell_number_format')) {
            var cell_number_format = __global_amount_format__;
            cell_number_format = (this.grid._cell_number_format[this.cell._cellIndex] && this.grid._cell_number_format[this.cell._cellIndex] != '') ? this.grid._cell_number_format[this.cell._cellIndex] : __global_number_format__;
            this.grid.setNumberFormat(cell_number_format, this.cell._cellIndex, global_decimal_separator, global_group_separator);
        } else {
            this.grid.setNumberFormat(__global_amount_format__, this.cell._cellIndex, global_decimal_separator, global_group_separator);
        }
    }
}
eXcell_ed_a.prototype = new eXcell_edn;

/**
 * Column type for read only amount.
 * @param  {Object} cell Cell Object
 */
function eXcell_ro_a(cell) {
    if (cell) {
        this.cell = cell;
        this.grid = this.cell.parentNode.grid;
        eXcell_edn.call(this);
    }
    this.edit = function() {};
    this.isDisabled = function() {
        return true
    };

    var column_data_type = '';
    var column_data_type_fake = '';
    if (this.grid.hasOwnProperty('_column_data_type')) {
        column_data_type = this.grid._column_data_type[this.cell._cellIndex];
    }
    if (this.grid.hasOwnProperty('_fake')) {
        this.grid._fake._noFormatArr[this.cell._cellIndex] = '0';
        if (this.grid._fake.hasOwnProperty('_column_data_type')) {
            column_data_type_fake = this.grid._fake._column_data_type[this.cell._cellIndex];
        }
    }
    column_data_type = (column_data_type)?column_data_type:column_data_type_fake;

    if (this.grid._noFormatArr[this.cell._cellIndex]) {
        this.grid.setNumberFormat(this.grid._noFormatArr[this.cell._cellIndex], this.cell._cellIndex);
    } else {
        if (this.grid.hasOwnProperty('_cell_number_format')) {
            var cell_number_format = __global_amount_format__;
            cell_number_format = (this.grid._cell_number_format[this.cell._cellIndex] && this.grid._cell_number_format[this.cell._cellIndex] != '') ? this.grid._cell_number_format[this.cell._cellIndex] : __global_number_format__;
            this.grid.setNumberFormat(cell_number_format, this.cell._cellIndex, global_decimal_separator, global_group_separator);
        } else {
            this.grid.setNumberFormat(__global_amount_format__, this.cell._cellIndex, global_decimal_separator, global_group_separator);
        }
    }
}
eXcell_ro_a.prototype = new eXcell_edn;

/**
 * Column type for editable volume.
 * @param  {Object} cell Cell Object
 */
function eXcell_ed_v(cell) {
    if (cell) {
        this.cell = cell;
        this.grid = this.cell.parentNode.grid;
        eXcell_edn.call(this);
    }

    this.detach = function() {
        var c = this.obj.value;
        c = c.toString().replace(global_decimal_separator, ".")
        this.setValue(c);
        return this.val != this.getValue()
    }

    var column_data_type = '';
    var column_data_type_fake = '';
    if (this.grid.hasOwnProperty('_column_data_type')) {
        column_data_type = this.grid._column_data_type[this.cell._cellIndex];
    }
    if (this.grid.hasOwnProperty('_fake')) {
        this.grid._fake._noFormatArr[this.cell._cellIndex] = '0';
        if (this.grid._fake.hasOwnProperty('_column_data_type')) {
            column_data_type_fake = this.grid._fake._column_data_type[this.cell._cellIndex];
        }
    }
    column_data_type = (column_data_type)?column_data_type:column_data_type_fake;

    if (this.grid._noFormatArr[this.cell._cellIndex]) {
        this.grid.setNumberFormat(this.grid._noFormatArr[this.cell._cellIndex], this.cell._cellIndex);
    } else {
        if (this.grid.hasOwnProperty('_cell_number_format')) {
            var cell_number_format = __global_volume_format__;
            cell_number_format = (this.grid._cell_number_format[this.cell._cellIndex] && this.grid._cell_number_format[this.cell._cellIndex] != '') ? this.grid._cell_number_format[this.cell._cellIndex] : __global_number_format__;
            this.grid.setNumberFormat(cell_number_format, this.cell._cellIndex, global_decimal_separator, global_group_separator);
        } else {
            this.grid.setNumberFormat(__global_volume_format__, this.cell._cellIndex, global_decimal_separator, global_group_separator);
        }
    }
}
eXcell_ed_v.prototype = new eXcell_edn;

/**
 * Column type for read only volume.
 * @param  {Object} cell Cell Object
 */
function eXcell_ro_v(cell) {
    if (cell) {
        this.cell = cell;
        this.grid = this.cell.parentNode.grid;
        eXcell_edn.call(this);
    }
    this.edit = function() {};
    this.isDisabled = function() {
        return true
    };

    var column_data_type = '';
    var column_data_type_fake = '';
    if (this.grid.hasOwnProperty('_column_data_type')) {
        column_data_type = this.grid._column_data_type[this.cell._cellIndex];
    }
    if (this.grid.hasOwnProperty('_fake')) {
        this.grid._fake._noFormatArr[this.cell._cellIndex] = '0';
        if (this.grid._fake.hasOwnProperty('_column_data_type')) {
            column_data_type_fake = this.grid._fake._column_data_type[this.cell._cellIndex];
        }
    }
    column_data_type = (column_data_type)?column_data_type:column_data_type_fake;

    if (this.grid._noFormatArr[this.cell._cellIndex]) {
        this.grid.setNumberFormat(this.grid._noFormatArr[this.cell._cellIndex], this.cell._cellIndex);
    } else {
        if (this.grid.hasOwnProperty('_cell_number_format')) {
            var cell_number_format = __global_volume_format__;
            cell_number_format = (this.grid._cell_number_format[this.cell._cellIndex] && this.grid._cell_number_format[this.cell._cellIndex] != '') ? this.grid._cell_number_format[this.cell._cellIndex] : __global_number_format__;
            this.grid.setNumberFormat(cell_number_format, this.cell._cellIndex, global_decimal_separator, global_group_separator);
        } else {
            this.grid.setNumberFormat(__global_volume_format__, this.cell._cellIndex, global_decimal_separator, global_group_separator);
        }
    }
}
eXcell_ro_v.prototype = new eXcell_edn;

/**
 * Column type for editable int column.
 * @param  {Object} cell Cell Object
 */
function eXcell_ed_int(cell) {
    if (cell) {
        this.cell = cell;
        this.grid = this.cell.parentNode.grid
    }
    this.getValue = function() {
        if ((this.cell.firstChild) && (this.cell.firstChild.tagName == "TEXTAREA")) {
            return this.cell.firstChild.value
        }
        if (this.cell._clearCell) {
            return ""
        }
        return this.cell._orig_value || this.grid._aplNFb(this.cell.innerHTML.toString()._dhx_trim(), this.cell._cellIndex)
    };

    this.edit = function() {
        this.cell.atag = (!this.grid.multiLine) ? "INPUT" : "TEXTAREA";
        this.val = this.getValue();
        this.obj = document.createElement(this.cell.atag);
        this.obj.setAttribute("autocomplete", "off");
        this.obj.style.height = (this.cell.offsetHeight - (_isIE ? 4 : 4)) + "px";
        this.obj.className = "dhx_combo_edit";
        this.obj.wrap = "soft";
        this.obj.style.textAlign = this.cell.style.textAlign;
        this.obj.onclick = function(c) {
            (c || event).cancelBubble = true
        };
        this.obj.onmousedown = function(c) {
            (c || event).cancelBubble = true
        };

        if (this.cell._orig_value && this.val) {
            var display_value = this.cell._orig_value;
            this.obj.value = display_value;
        } else {
            this.obj.value = this.val;
        }
        this.cell.innerHTML = "";
        this.cell.appendChild(this.obj);
        this.obj.onselectstart = function(c) {
            if (!c) {
                c = event
            }
            c.cancelBubble = true;
            return true
        };
        if (_isIE) {
            this.obj.focus();
            this.obj.blur()
        }
        this.obj.focus()
    };

    this.setValue = function(val) {
        if (val) {
            val = parseInt(val);
            val = val.toString();
        }
        if (!val || val.toString()._dhx_trim() == "") {
            this.cell._clearCell = true;
            return this.setCValue("&nbsp;", 0)
        } else {
            this.cell._clearCell = false;
            this.cell._orig_value = val
        }
        this.setCValue(this.grid._aplNF(val, this.cell._cellIndex), val)
    }

    this.detach = function() {
        var c = this.obj.value;
        this.setValue(c);
        return this.val != this.getValue()
    }
}
eXcell_ed_int.prototype = new eXcell_edn;


/**
 * Column type for read only int column.
 * @param  {Object} cell Cell Object
 */
function eXcell_ro_int(a) {
    this.cell = a;
    this.grid = this.cell.parentNode.grid;
    this.edit = function() {};
    this.isDisabled = function() {
        return true
    };
    this.getValue = function() {
        return this.cell._clearCell ? "" : this.cell._orig_value || this.grid._aplNFb(this.cell.innerHTML.toString()._dhx_trim(), this.cell._cellIndex).toString()
    }
    this.setValue = function(val) {
        if (val) {
            val = parseInt(val);
            val = val.toString();
        }

        if (val === 0) {} else {
            if (!val || val.toString()._dhx_trim() == "") {
                this.setCValue("&nbsp;");
                return this.cell._clearCell = true
            }
        }
        this.cell._orig_value = val;
        this.cell._clearCell = false;
        this.setCValue(val ? this.grid._aplNF(val, this.cell._cellIndex) : "0");

    };
}
eXcell_ro_int.prototype = new eXcell_edn;
/* END of number format logic*/

/**
 * Column type for read only combo.
 * @param  {Object} a Cell object
 */
function eXcell_ro_combo(a) {
    if (!a) {
        return
    }

    this.cell = a;
    this.grid = a.parentNode.grid;
    this.base = eXcell_combo;
    this.base(a);
    this.edit = function() {};
    this.isDisabled = function() {
        return true
    };
    
}
eXcell_ro_combo.prototype = new eXcell_combo;

/**
 * [eXcell_ro_dhxCalendarA Column type for read only calendar.]
 * @param  {Object} a Cell object
 */
function eXcell_ro_dhxCalendarA(a) {
    if (!a) {
        return
    }

    this.cell = a;
    this.grid = a.parentNode.grid;
    this.base = eXcell_dhxCalendarA;
    this.base(a);
    this.edit = function() {};
    this.isDisabled = function() {
        return true
    };
    
}
eXcell_ro_dhxCalendarA.prototype = new eXcell_dhxCalendarA;

/**
 * [eXcell_dhxCalendarDT Column type for date time calendar.]
 * @param  {Object} a  Object
 */
function eXcell_dhxCalendarDT(a) {
    if (!a) {
        return
    }

    this.cell = a; 
    this.grid = a.parentNode.grid;    
    var o = this.grid._dtmask;
    if(o.indexOf("%H") == -1) {    
        this.grid._dtmask_org = this.grid._dtmask;
        this.grid._dtmask_inc_org = this.grid._dtmask_inc;
    }
    
    this.base = eXcell_dhxCalendarA;
    this.base(a);
    
    var c = this.grid;
    this.grid._grid_calendarA.attachEvent("onTimeChange", function(d){
        if (this.getDate() != null) {
            this._last_operation_calendar = true;
        }
    });

    this.edit = function() {
        this.grid.attachEvent("onCalendarShow", function(g, rId, colInd){
            g.showTime();
        });

        var c = this.grid.getPosition(this.cell);
        this.grid._grid_calendarA._show(false, false);
        var q = (navigator.appVersion.indexOf("MSIE") != -1);
        var x = Math.max((q ? document.documentElement : document.getElementsByTagName("html")[0]).scrollTop, document.body.scrollTop);
        var v = x + (q ? Math.max(document.documentElement.clientHeight || 0, document.documentElement.offsetHeight || 0, document.body.clientHeight || 0) : window.innerHeight);
        var A = c[1];
        if (A + this.grid._grid_calendarA.base.offsetHeight > v) {
            var y = c[1] - this.grid._grid_calendarA.base.offsetHeight;
            if (y >= -20) {
                A = y
            }
        } else {
            A = A +  30;
        }
        this.grid._grid_calendarA.setPosition(c[0], A);

        this.grid.callEvent("onCalendarShow", [this.grid._grid_calendarA, this.cell.parentNode.idd, this.cell._cellIndex]);
        
        this.cell._cediton = true;
        this.val = this.cell.val;
        this._val = this.cell.innerHTML;
  
        var ct = this.grid._dtmask_org;
        var st = this.grid._dtmask_inc_org

        if(ct.indexOf("%H") == -1) {
            ct = ct + " %H:%i";
            st = st + " %H:%i";
            this.grid.setDateFormat(ct, st);
        }

        var a = this.grid._grid_calendarA.draw;
        
        this.grid._grid_calendarA.draw = function() {};
        this.grid._grid_calendarA.setDateFormat((this.grid._dtmask  || "%d/%m/%Y"));
        this.grid._grid_calendarA.setDate(this.val);
        this.grid._grid_calendarA.draw = a;
        this.cell.atag = ((!this.grid.multiLine) && (_isKHTML || _isMacOS || _isFF)) ? "INPUT" : "TEXTAREA";
        this.obj = document.createElement(this.cell.atag);
        this.obj.style.height = (this.cell.offsetHeight - 4) + "px";
        this.obj.className = "dhx_combo_edit";
        this.obj.wrap = "soft";
        this.obj.style.textAlign = this.cell.align;
        this.obj.onclick = function(g) {
            (g || event).cancelBubble = true
        };
       
        
        this.obj.onmousedown = function(g) {
            (g || event).cancelBubble = true
        };
        this.obj.value = this.getFormattedValue();
        this.cell.innerHTML = "";
        this.cell.appendChild(this.obj);
        if (window.dhx4.isIE) {
            this.obj.style.overflow = "visible";
            if ((this.grid.multiLine) && (this.obj.offsetHeight >= 18) && (this.obj.offsetHeight < 40)) {
                this.obj.style.height = "36px";
                this.obj.style.overflow = "scroll"
            }
        }
        this.obj.onselectstart = function(g) {
            if (!g) {
                g = event
            }
            g.cancelBubble = true;
            return true
        };
        this.obj.focus();

    };
    this.isDisabled = function() {
        return false;
    };

    this.setValue = function(a) {        
        var ct = this.grid._dtmask_org ; 
        var st = this.grid._dtmask_inc_org
        
        if(ct.indexOf("%H") == -1) {
            ct = ct +" %H:%i";
            st = st + " %H:%i";
            this.grid.setDateFormat(ct, st);
        }
        
        if (a && typeof a == "object") {
            this.cell.val = a;
            this.cell._clearCell = false;
            this.setCValue(this.grid._grid_calendarA.getFormatedDate((this.grid._dtmask || "%d/%m/%Y"), a).toString(), this.cell.val);
            return
        }
        if (!a || a.toString()._dhx_trim() == "") {
            a = "&nbsp";
            this.cell._clearCell = true;
            this.cell.val = ""
        } else {
            this.cell._clearCell = false;
            this.cell.val = new Date(this.grid._grid_calendarA.setFormatedDate((this.grid._dtmask_inc || this.grid._dtmask || "%d/%m/%Y"), a.toString(), null, true));
            
            if (this.grid._dtmask_inc) {
                a = this.grid._grid_calendarA.getFormatedDate((this.grid._dtmask || "%d/%m/%Y"), this.cell.val)
             
            }
        } if ((this.cell.val == "NaN") || (this.cell.val == "Invalid Date")) {
            this.cell.val = new Date();
            this.cell._clearCell = true;
            this.setCValue("&nbsp;", 0)
        } else {
            this.setCValue((a || "").toString(), this.cell.val)
        }
        this.grid.setDateFormat(this.grid._dtmask_org , this.grid._dtmask_inc_org);
        
    }

    this.getValue = function() {
        if (this.cell._clearCell) {
            return ""
        }

        var ct = this.grid._dtmask_org ; 
        var st = this.grid._dtmask_inc_org
        
        if(ct.indexOf("%H") == -1) {
            ct = ct +" %H:%i";
            st = st + " %H:%i";
            this.grid.setDateFormat(ct, st);
        }

        if (this.grid._dtmask_inc && this.cell.val) {
            var dt = this.grid._grid_calendarA.getFormatedDate(this.grid._dtmask_inc, this.cell.val);  
            this.grid.setDateFormat(this.grid._dtmask_org , this.grid._dtmask_inc_org);
            return dt.toString();
        
        }

        this.grid.setDateFormat(this.grid._dtmask_org , this.grid._dtmask_inc_org);
        return this.cell.innerHTML.toString()._dhx_trim();
        
    };

    this.detach = function() {
        if (!this.grid._grid_calendarA) {
            return
        }
        this.grid._grid_calendarA.hide();
        if (this.cell._cediton) {
            this.cell._cediton = false
        } else {
            this.grid.setDateFormat(this.grid._dtmask_org , this.grid._dtmask_inc_org);        
            return
        } 

        if (this.grid._grid_calendarA._last_operation_calendar) {
            this.grid._grid_calendarA._last_operation_calendar = false;
            var g = this.grid._grid_calendarA.getFormatedDate(this.grid._dtmask || "%d/%m/%Y");
            var c = this.grid._grid_calendarA.getDate();
            this.cell.val = new Date(c);
            this.setCValue(g, c);
            this.cell._clearCell = !g;
            var a = this.val;
            this.val = this._val;
            this.grid.setDateFormat(this.grid._dtmask_org , this.grid._dtmask_inc_org);
            
            return (this.cell.val.valueOf() != (a | "").valueOf());
        }

        this.setFormattedValue(this.obj.value);
        var a = this.val;
        this.val = this._val;
        this.grid.setDateFormat(this.grid._dtmask_org , this.grid._dtmask_inc_org);
        
        return (this.cell.val.valueOf() != (a || "").valueOf());
    }
}
eXcell_dhxCalendarDT.prototype = new eXcell_dhxCalendarA;

/**
 * DHTMLX prototype
 * Override to hide time by default
 */
eXcell_dhxCalendarA.prototype.edit = function() {
    var c = this.grid.getPosition(this.cell);
    this.grid._grid_calendarA._show(false, false);
    var cIdx = this.cell._cellIndex;
    var coltype = this.grid.getColType(cIdx);
    
    if (coltype == 'dhxCalendarA') {
        this.grid.attachEvent("onCalendarShow", function(g, rId, colInd) {        
            g.hideTime();
        }); 
    }
    
    var q = (navigator.appVersion.indexOf("MSIE") != -1);
    var x = Math.max((q ? document.documentElement : document.getElementsByTagName("html")[0]).scrollTop, document.body.scrollTop);
    var v = x + (q ? Math.max(document.documentElement.clientHeight || 0, document.documentElement.offsetHeight || 0, document.body.clientHeight || 0) : window.innerHeight);
    var A = c[1];
    if (A + this.grid._grid_calendarA.base.offsetHeight > v) {
        var y = c[1] - this.grid._grid_calendarA.base.offsetHeight;
        if (y >= -20) {
            A = y
        }
    } else {
        A = A +  30;
    }
    this.grid._grid_calendarA.setPosition(c[0], A);

    this.grid.callEvent("onCalendarShow", [this.grid._grid_calendarA, this.cell.parentNode.idd, this.cell._cellIndex]);
    this.grid._grid_calendarA._last_operation_calendar = false;
    this.cell._cediton = true;
    this.val = this.cell.val;
    this._val = this.cell.innerHTML;
    var a = this.grid._grid_calendarA.draw;
    this.grid._grid_calendarA.draw = function() {};
    this.grid._grid_calendarA.setDateFormat((this.grid._dtmask || "%d/%m/%Y"));
    this.grid._grid_calendarA.setDate(this.val);
    this.grid._grid_calendarA.draw = a;
    this.cell.atag = ((!this.grid.multiLine) && (_isKHTML || _isMacOS || _isFF)) ? "INPUT" : "TEXTAREA";
    this.obj = document.createElement(this.cell.atag);
    this.obj.style.height = (this.cell.offsetHeight - 4) + "px";
    this.obj.className = "dhx_combo_edit";
    this.obj.wrap = "soft";
    this.obj.style.textAlign = this.cell.align;
    this.obj.onclick = function(g) {
        (g || event).cancelBubble = true
    };
    this.obj.onmousedown = function(g) {
        (g || event).cancelBubble = true
    };
    this.obj.value = this.getFormattedValue();
    this.cell.innerHTML = "";
    this.cell.appendChild(this.obj);
    if (window.dhx4.isIE) {
        this.obj.style.overflow = "visible";
        if ((this.grid.multiLine) && (this.obj.offsetHeight >= 18) && (this.obj.offsetHeight < 40)) {
            this.obj.style.height = "36px";
            this.obj.style.overflow = "scroll"
        }
    }
    this.obj.onselectstart = function(g) {
        if (!g) {
            g = event
        }
        g.cancelBubble = true;
        return true
    };
    this.obj.focus();
    this.obj.focus()
};

/**
 * DHTMLX prototype
 * Override to hide time by default
 */
eXcell_dhxCalendar.prototype.edit = function() {
    var c = this.grid.getPosition(this.cell);
    this.grid._grid_calendarA._show(false, false);
    this.grid._grid_calendarA.setPosition(c[0], c[1] + this.cell.offsetHeight);
    this.grid._grid_calendarA._last_operation_calendar = false;
    var cIdx = this.cell._cellIndex;
    var coltype = this.grid.getColType(cIdx);
    
    if (coltype == 'dhxCalendar') {
        this.grid.attachEvent("onCalendarShow", function(g, rId, colInd) {        
            g.hideTime();
        }); 
    }

    this.grid.callEvent("onCalendarShow", [this.grid._grid_calendarA, this.cell.parentNode.idd, this.cell._cellIndex]);
    this.cell._cediton = true;
    this.val = this.cell.val;
    this._val = this.cell.innerHTML;
    var a = this.grid._grid_calendarA.draw;
    this.grid._grid_calendarA.draw = function() {};
    this.grid._grid_calendarA.setDateFormat((this.grid._dtmask || "%d/%m/%Y"));
    this.grid._grid_calendarA.setDate(this.val || (new Date()));
    this.grid._grid_calendarA.draw = a
};



/**
 * eXcell_time, Excell time. 
 * @param  {Object} cell Cell object
 */
function eXcell_time(cell){                  // excell name is defined here
    var time_pick = '';
    if (cell){                                 // default pattern, just copy it
        this.cell = cell;
        this.grid = this.cell.parentNode.grid;
    }
    that = this;
    var col_idx = this.cell._cellIndex;        
    var default_width=this.grid.getColWidth(col_idx);

    this.setValue=function(val){
        //this.setCValue(val);
        val = (val == '') ? current_time() : val; 
        var ft_time =  get_formatted_time(val);
        this.setCValue("<span dt_val=" + val + "></span>" + ft_time,val);                                    
    }
    this.getValue=function(){
        var element = this.cell.outerHTML;
        var ee = ($.parseHTML(element.toString()));

        if(ee[0].firstChild.getAttribute) {
            t = ee[0].firstChild.getAttribute('dt_val');// this.cell.innerHTML; // get value
        } else {
            t = '';
            
        }
        return t;
    }
    this.edit=function(){
        this.val = this.getValue(); // save current value
        var input_id = 'timepicker' + col_idx;
        
        if (default_width < 100){
           this.grid.setColWidth(col_idx,"100"); 
        }    

        time_pick = this.val;
        if (time_pick != '') ft_time = get_formatted_time(time_pick);
        else ft_time = '';
        
        this.span_obj = document.createElement("SPAN");
        this.span_obj.setAttribute("dt_val", time_pick);
        
        this.obj = document.createElement("DIV");
        this.timepicker_obj = document.createElement("INPUT");
        this.timepicker_span = document.createElement("SPAN");
        this.obj.className = "input-group bootstrap-timepicker timepicker pull-left";
        this.obj.id = input_id + '_div';
        this.timepicker_obj.id = input_id;
        this.timepicker_obj.type = 'text';
        this.timepicker_obj.setAttribute("data-provide", "timepicker");
        this.timepicker_obj.setAttribute("data-template", "dropdown");
        this.timepicker_obj.setAttribute("data-minute-step", "1");
        
        this.timepicker_obj.style.width = "60%";
        this.timepicker_obj.className = "form-control input-small";
        this.timepicker_obj.value = ft_time;
        
        this.timepicker_span.className = "input-group-addon";
        this.timepicker_icon = document.createElement("I");
        this.timepicker_icon.className = "glyphicon glyphicon-time";
        this.timepicker_span.appendChild(this.timepicker_icon);
        
        this.obj.appendChild(this.timepicker_obj);
        this.obj.appendChild(this.timepicker_span);
        this.cell.innerHTML = "";
        
        this.cell.appendChild(this.span_obj);
        this.cell.appendChild(this.obj);
        
        this.obj.onclick = function(c) {
            (c || event).cancelBubble = true
        };
        this.obj.onmousedown = function(c) {
            (c || event).cancelBubble = true
        };
        
        this.obj.onselectstart = function(c) {
            if (!c) {
                c = event
            }
            c.cancelBubble = true;
            return true
        };
        if (_isIE) {
            this.obj.focus();
            this.obj.blur()
            
            this.timepicker_obj.focus();
            this.timepicker_obj.blur();
        }
        this.obj.focus();
        this.timepicker_obj.focus();
        
        $('#' + input_id).timepicker().on('changeTime.timepicker', function(e) {
            var hr = e.time.hours;
            if (e.time.meridian == 'PM' && hr != '12') {
                hr += 12;
            } else if (e.time.meridian == 'AM' && hr == '12') {
                hr = 0;
            }
            
            min = (1 === e.time.minutes.toString().length ? "0" + e.time.minutes : e.time.minutes);
            time_pick = hr + ':' + min;
            $('#'+e.target.id).val(e.time.value);
            that.val = time_pick;
            $('#' + input_id + '_div').parent('td').attr('default_val', time_pick);
        });        

    }

    this.detach=function(e){
        var input_id = 'timepicker' + col_idx;      
        var hour = $('#' + input_id).data('timepicker').hour;
        var min = $('#' + input_id).data('timepicker').minute;
        var mer = $('#' + input_id).data('timepicker').meridian;
        
        if (mer == 'PM' && hour != '12') {
            hour += 12;
        } else if (mer == 'AM' && hour == '12') {
            hour = 0;
        }
        
        min = (1 === min.toString().length ? "0" + min : min);
        vl = (hour != '' && min != '') ? hour + ':' + min : '';
        
        var tv = (vl != '') ? get_formatted_time(vl) : '';
        this.cell.innerHTML = '<span dt_val='+ vl + '></span>' + tv;
        return this.val!=this.getValue(); // compares the new and the old values
    }
    
}
eXcell_time.prototype = new eXcell;    // nests all other methods from base class

/*
function eXcell_time(a) {

    if (!a) {
        return
    }

    this.cell = a;
    this.grid = a.parentNode.grid;
    this.base = eXcell_dhxCalendarA;
    this.base(a);
    eXcell_time.call(this);
    grid_obj = this.grid;

    this.grid.attachEvent("onCalendarShow", function(a, b, c) { 
        var col_type = grid_obj.getColType(c); // this will return column type
        if(col_type == 'time') {
        a.contDates.style.display="none";
        a.contDays.style.display="none";
        a.contMonth.style.display="none";
        a.setMinutesInterval(1);
        } else {
            a.contDates.style.display="block";
            a.contDays.style.display="block";
            a.contMonth.style.display="block";
        }
    });

    that_cell = this.cell;
    if (!this.grid._grid_time) {
        this.grid._grid_time = this.grid._grid_calendarA;
        this.grid._grid_time.setDateFormat('%h:%i %A');
        this.grid._grid_time.attachEvent("onTimeChange", function(d) {
            var h1 = d.getHours()< 10 ? '0' + d.getHours() : d.getHours();
            var m1 = d.getMinutes()< 10 ? '0' + d.getMinutes() : d.getMinutes();
            that_cell.innerHTML = h1 + ':' + m1;
        });
    }

}

eXcell_time.prototype = new eXcell_dhxCalendarA;

eXcell_time.prototype.setValue = function(d) {
    this.cell.innerHTML = d;
}

eXcell_time.prototype.getValue = function(d) {
    var val = this.cell.innerHTML;
    return val;
}

eXcell_time.prototype.detach = function() {
    if (!this.grid._grid_time) {
        return
    }
    this.grid._grid_time.hide();
    if (this.cell._cediton) {
        this.cell._cediton = false
    } else {
        return
    }
}

eXcell_time.prototype.edit = function() {
    var c = this.grid.getPosition(this.cell);
    this.grid._grid_calendarA._show(false, false);
    var q = (navigator.appVersion.indexOf("MSIE") != -1);
    var x = Math.max((q ? document.documentElement : document.getElementsByTagName("html")[0]).scrollTop, document.body.scrollTop);
    var v = x + (q ? Math.max(document.documentElement.clientHeight || 0, document.documentElement.offsetHeight || 0, document.body.clientHeight || 0) : window.innerHeight);
    var A = c[1];
    if (A + this.grid._grid_calendarA.base.offsetHeight > v) {
        var y = c[1] - this.grid._grid_calendarA.base.offsetHeight;
        if (y >= -20) {
            A = y
        }
    } else {
        A = A +  30;
    }
    this.grid._grid_calendarA.setPosition(c[0], A);
    this.grid._grid_time._show(false, false);
    this.grid._grid_time._last_operation_calendar = false;
    this.grid.callEvent("onCalendarShow", [this.grid._grid_time, this.cell.parentNode.idd, this.cell._cellIndex]);
    this.cell._cediton = true;
    this.val = this.cell.val;
    this._val = this.cell.innerHTML;
    var a = this.grid._grid_time.draw;
    this.grid._grid_time.draw = function() {};
    this.grid._grid_time.setDateFormat('%h:%i %A');
    if (this._val !== '') {
        var time_array = this._val.split(':');
        var new_date = new Date();
        new_date.setHours(time_array[0]);
        new_date.setMinutes(time_array[1]);
        this.grid._grid_time.setDate(new_date);
    } else {
        this.grid._grid_time.setDate('');
    }
    this.grid._grid_time.draw = a
};
*/
/**
 * Column type for editable phone number.
 * @param  {Object} cell Cell object
 */
function eXcell_ed_phone(cell) {
    if (cell) {
        this.cell = cell;
        this.grid = this.cell.parentNode.grid;
        eXcell_ed.call(this);
    } 
    this.setValue = function(g) {
        // unformatted
        var g_unf = g;

        g = (g.replace(/[^\d]/g, ''));
        if (!g || g.toString()._dhx_trim() == "") {
            this.setCValue("&nbsp;", g);
            return (this.cell._clearCell = true)
        } else {
            this.cell._clearCell = false;
            this.cell._orig_value = g
        }

        if (__phone_format__ == 0) {
            var val = formatLocal(__country__, g);
        } else if(__phone_format__ == 1) {
            var val = formatNumberForMobileDialing(__country__, g); 
        } else{
            // No formatting case
            var val = g_unf;
        }        
        this.setCValue(val, g);       
    }
}
eXcell_ed_phone.prototype = new eXcell_ed;

/**
 * Column type for read only phone number.
 * @param  {Object} cell Cell object
 */
function eXcell_ro_phone(cell) {
    if (cell) {
        this.cell = cell;
        this.grid = this.cell.parentNode.grid;
        eXcell_ed.call(this);
    }
    this.edit = function() {};
    this.isDisabled = function() {
        return true;
    };

    this.setValue = function(g) {
        // unformatted
        var g_unf = g;

        g = (g.replace(/[^\d]/g, ''));
        if (!g || g.toString()._dhx_trim() == "") {
            this.setCValue("&nbsp;", g);
            return (this.cell._clearCell = true)
        }
        if (__phone_format__ == 0) {
            var val = formatLocal(__country__, g);
        } else if(__phone_format__ == 1) {
            var val = formatNumberForMobileDialing(__country__, g); 
        } else{
            // No formatting case
            var val = g_unf;
        }
        this.setCValue(val, g);        
    }
}
eXcell_ro_phone.prototype = new eXcell_ed;


var ___browse_win_link_window;
/**
 * Column type for window link.
 * @param  {Object} cell Cell Object
 */
function eXcell_win_link(cell) {
    if (cell) {
        this.cell = cell;
        this.grid = this.cell.parentNode.grid;
        eXcell_ed.call(this);
    }

    this.getValue = function() {
        if (this.cell.firstChild.getAttribute) {
            var c = this.cell.firstChild.getAttribute("data-id");
            return c;
        } else {
            return "";
        }
    };

    this.setValue = function(g) {
        if (!g || g.toString()._dhx_trim() == "") {
            this.setCValue("&nbsp;", c);
            return (this.cell._clearCell = true)
        }
        var c = g.split("^");
        if (c.length == 0) {
            c[0] = "";
            c[1] = "";
        }

        this.setCValue("<span data-id='" + c[0] + "'>" + c[1] + "</span>", c)
        //this.attachEvent("onEditCell", g);
        
    }

    this.edit = function() {
        this.val = this.getValue();
        CELL = this.cell;
        GRID = this.cell.parentNode.grid;
        ROW = this.cell.parentNode.idd;
        var c_id = this.grid.getColumnId(this.cell._cellIndex);
        var function_id = this.grid.getUserData("", c_id);
        var return_val = new Array();
        set_value = this.setValue;
        
        if (function_id == 10211093) {
            ___unload_browse_win_link_window_window();

            if (!___browse_win_link_window) {
                ___browse_win_link_window = new dhtmlXWindows();
            }
            var new_win = ___browse_win_link_window.createWindow('w1', 0, 0, 800, 600);
            new_win.setText("Formula Editor");
            new_win.centerOnScreen();
            new_win.setModal(true);
            new_win.maximize();
            var param = app_form_path + '_setup/formula_builder/formula.editor.php?formula_id=' + this.val + '&call_from=browser&is_pop=true';
            new_win.attachURL(param);

            new_win.attachEvent('onClose', function(win) {
                var ifr = win.getFrame();
                var ifrWindow = ifr.contentWindow;
                var ifrDocument = ifrWindow.document;
                var formula_id = $('textarea[name="___browse_formula_id___"]', ifrDocument).val();
                var formula_text = $('textarea[name="___browse_formula_text___"]', ifrDocument).val();
                if(formula_id != 'NULL') {
                    var old_value = GRID.cells(ROW, CELL._cellIndex).getValue();
                    GRID.setUserData("", "cell_loader", 'y');
                    GRID.cells(ROW, CELL._cellIndex).setValue(formula_id + '^' + formula_text);
                    GRID.cells(ROW, CELL._cellIndex).cell.wasChanged=true;
                    GRID.callEvent("onEditCell", [2, ROW, CELL._cellIndex, formula_id, old_value]);
                }                
                return true;
            });
        }

        var c = GRID.editStop;
        GRID.editStop = function() {};
        GRID.editStop = c
    }
    this.detach = function() {};
}
eXcell_win_link.prototype = new eXcell_ed;

/**
 * Column type for read only window link.
 * @param  {Object} a Cell object
 */
function eXcell_ro_win_link(a) {
    if (!a) {
        return
    }

    this.cell = a;
    this.grid = a.parentNode.grid;
    this.base = eXcell_win_link;
    this.base(a);
    this.edit = function() {};
    this.isDisabled = function() {
        return true
    };
    
}
eXcell_ro_win_link.prototype = new eXcell_win_link;



/* Custom columns types for grid */

/**
 * [___unload_browse_win_link_window_window Unload function for browse win link window.]
 */
function ___unload_browse_win_link_window_window() {        
    if (___browse_win_link_window != null && ___browse_win_link_window.unload != null) {
        ___browse_win_link_window.unload();
        ___browse_win_link_window = w1 = null;
    }
}

/**
 * Column type for window link.
 * @param  {Object} cell Cell Object
 */
function eXcell_win_link_custom(cell) {
    if (cell) {
        this.cell = cell;
        this.grid = this.cell.parentNode.grid;
        eXcell_ed.call(this);
    }

    this.getValue = function() {
        if (this.cell.firstChild.getAttribute) {
            var c = this.cell.firstChild.getAttribute("data-id");
            return c;
        } else {
            return "";
        }
    };

    this.setValue = function(g) {
        if (!g || g.toString()._dhx_trim() == "") {
            this.setCValue("&nbsp;", c);
            return (this.cell._clearCell = true)
        }
        var c = g.split("^");
        if (c.length == 0) {
            c[0] = "";
            c[1] = "";
        }

        this.setCValue("<span data-id='" + c[0] + "'>" + c[1] + "</span>", c)
        //this.attachEvent("onEditCell", g);
        //
    }
    
    this.detach = function() {};
}
eXcell_win_link_custom.prototype = new eXcell_ed;

/**
 * Column type for read only window link.
 * @param  {Object} a Cell object
 */
function eXcell_ro_win_link_custom(a) {
    if (!a) {
        return
    }

    this.cell = a;
    this.grid = a.parentNode.grid;
    this.base = eXcell_win_link;
    this.base(a);
    this.edit = function() {};
    this.isDisabled = function() {
        return true
    };
    
}
eXcell_ro_win_link_custom.prototype = new eXcell_win_link_custom;

/**
 * Column type for password column.
 * @param  {Object} cell Cell object
 */
function eXcell_ed_password(cell) {
    if (cell) {
        this.cell = cell;
        this.grid = this.cell.parentNode.grid;
        eXcell_ed.call(this);
    }

    this.getValue = function() {
        if (this.cell.firstChild.getAttribute) {
            var c = this.cell.firstChild.getAttribute("data-id");
            c = c.replace(/&apos;/g,"'");
            c = c.replace(/&quot;/g,'"');
            return c;
        } else {
            return "";
        }
    };

    this.setValue = function(g) {
        var c_label = ''
        if (g == '' || !g || g == null)
            c_label = '';
        else
            c_label = '*******';
        g = g.replace(/'/g,"&apos;");
        g = g.replace(/"/g,"&quot;");
        this.setCValue("<span data-id='" + g + "'>" + c_label + "</span>", g);
    }

    this.edit = function() {
        this.cell.atag = (!this.grid.multiLine) ? "INPUT" : "TEXTAREA";
        this.val = this.getValue();
        this.obj = document.createElement(this.cell.atag);
        this.obj.setAttribute("autocomplete", "off");
        this.obj.style.height = (this.cell.offsetHeight - (_isIE ? 4 : 4)) + "px";
        this.obj.className = "dhx_combo_edit";
        this.obj.wrap = "soft";
        this.obj.style.textAlign = this.cell.style.textAlign;
        this.obj.onclick = function(c) {
            (c || event).cancelBubble = true
        };
        this.obj.onmousedown = function(c) {
            (c || event).cancelBubble = true
        };
        this.obj.onfocus = function(){
            $('.dhx_combo_edit', this.obj).select();
        }
        this.obj.value = this.val;
        this.cell.innerHTML = "";
        this.cell.appendChild(this.obj);
        this.obj.onselectstart = function(c) {
            if (!c) {
                c = event
            }
            c.cancelBubble = true;
            return true
        };
        if (_isIE) {
            this.obj.focus();
            this.obj.blur()
        }
        this.obj.focus()
    };


}
eXcell_ed_password.prototype = new eXcell_ed;

/**
 * Created Filter type daterange for date field
 * @param  {Object} a Cell object
 * @param  {Object} b Column object
 */
dhtmlXGridObject.prototype._in_header_daterange_filter = function(a, b) {
    a.innerHTML="<div style='width:100%;text-decoration:none;margin:0px !important;padding:0px !important'><input type='text' id='datefrom' placeholder='From' style='margin:0px !important;padding:0px !important;width:48.5%!important;line-height:15px;'>  <input type='text' id='dateto' placeholder='To' style='margin:0px !important;padding:0px !important;width:48.5%!important;line-height:15px;'></div>";
    a.onclick = a.onmousedown = function(a) {
        return (a || event).cancelBubble = !0
    };

    a.onselectstart = function() {
        return event.cancelBubble = !0
    };

    datefrom = getChildElement(a.firstChild, "datefrom");
    dateto = getChildElement(a.firstChild, "dateto");

    myCalendar = new dhtmlXCalendarObject([datefrom, dateto])
    myCalendar.setDateFormat(user_date_format); //Date format MM/DD/YYY
    
    that = this.hdr.grid;
    myCalendar.attachEvent("onClick", function(date) {
        that.filterByAll();
    })

    a.onmouseup = function(a) {
       myCalendar.hide();
    };

    this.makeFilter(datefrom, b);
    this.makeFilter(dateto, b);

    datefrom._filter = function() {
        var a = this.value;
        return a == "" ? "" : function(b) {
            aDate = parseDate(a)
            bDate = parseDate(b)
            return aDate <= bDate;

        }
    }

    dateto._filter = function() {
        var a = this.value;
        return a == "" ? "" : function(b) {
            aDate = parseDate(a)
            bDate = parseDate(b)
            return aDate >= bDate
        }
    }

    this._filters_ready()

};

/**
 * Parse a date in mm/dd/yyyy format.
 * @param  {Object} input Input data
 * @return New date.
 */
function parseDate(input) {
    input = dates.convert(input);
    // new Date(year, month [, day [, hours[, minutes[, seconds[, ms]]]]])    
    return new Date(input).getTime(); // Date format MM/DD/YYY
}

/**
 * [getChildElement Get child element of selected element]
 * @param  {Object} element     Element
 * @param  {Integer} id         Id of child element
 */
function getChildElement(element, id) {
    for (i = 0; i < element.childNodes.length; i++) {
        if (element.childNodes[i].id == id)
            return element.childNodes[i];
    }
    return null
}



/**
 * Get values of selected rows for supplied column.
 * @param  {Integer} cInd Column Index
 */
dhtmlXGridObject.prototype.getColumnValues = function(cInd){
    var selAr = new Array(0);
    var uni = {};
    for (var i = 0; i < this.selectedRows.length; i++) {
        var id = this.selectedRows[i].idd;
        var value = this.cells(id, cInd).getValue();
        if (uni[id]) {
            continue
        }
        selAr[selAr.length] = value;
        uni[id] = true
    }
    if (selAr.length == 0) {
        return null
    } else {
        return selAr.join(this.delim)
    }
}

/**
 * Enables Auto Hide in grid inline filter
 */
dhtmlXGridObject.prototype.enableFilterAutoHide = function() {
    $(this.hdr).find("tr").eq(2).css("display", "none");
    $(this.hdr).hover(hoverin.bind(this), hoverout.bind(this));
    
    if (this._fake != undefined) {
        $(this._fake.hdr).find("tr").eq(2).css("display", "none");
        $(this._fake.hdr).hover(hoverin.bind(this), hoverout.bind(this));
    }

    function hoverin() {
        timeout_const = setTimeout(function() {
            $(this.hdr).find("tr").eq(2).css('display', 'table-row');
            if (this._fake != undefined)
                $(this._fake.hdr).find("tr").eq(2).css('display', 'table-row');
        }.bind(this), 300);
    }

    function hoverout() {
        clearTimeout(timeout_const);
        $(this.hdr).find("tr").eq(2).css("display", "none");
        if (this._fake != undefined)
            $(this._fake.hdr).find("tr").eq(2).css("display", "none");
        this.setSizes();
    }
}

/**
 * Validate numeric column with empty support.
 * @param  {String}  a Value 
 */
dhtmlxValidation.isValidNumericWithEmpty = function(a) {
    if (a == "") return true;
    return ($.isNumeric(a));
}


/**
 * Phone Field type for phone number.
 * @type {Object}
 */
dhtmlXForm.prototype.items.phone = {
    updateValue: function(l, a) {
        var m = l.childNodes[l._ll ? 1 : 0].childNodes[0].value;
        var h = l.getForm();
        var c = (h._ccActive == true && h._formLS != null && h._formLS[l._idd] != null);
        h = null;

        var g = this;
        if (l._value != m) {            
            if (l.checkEvent("onBeforeChange")) {
                if (l.callEvent("onBeforeChange", [l._idd, l._value, m]) !== true) {
                    g.setValue(l, l._value)
                    return
                }
            }
            g.setValue(l, m)
            l._value = m
            l.callEvent("onChange", [l._idd, m]);
            return
        }
        this.setValue(l, l._value);
    },
    setValue: function(g, h) {
        g._value = (typeof(h) != "undefined" && h != null ? h : "");
        g._value = (g._value.replace(/[^\d]/g, ''));
        var c = (String(g._value) || "");

        if (__phone_format__ == 0) {
            c = formatLocal(__country__, c);
        } else if(__phone_format__ == 1) {
            c = formatNumberForMobileDialing(__country__, c); 
        } else{
            // Not formatted
            c = (typeof(h) != "undefined" && h != null ? h : "");
        }

        var a = g.childNodes[g._ll ? 1 : 0].childNodes[0];
        if (a.value != c) {
            a.value = c;
            g.getForm()._ccReload(g._idd, c)
        }
        a = null
    }
};

(function() {
    for (var a in {
        render: 1,
        doAddLabel: 1,
        doAddInput: 1,
        doAttachEvents: 1,
        destruct: 1,
        doUnloadNestedLists: 1,
        setText: 1,
        getText: 1,
        getValue: 1,
        //updateValue: 1,
        enable: 1,
        disable: 1,
        setWidth: 1,
        setReadonly: 1,
        isReadonly: 1,
        setFocus: 1,
        getInput: 1
    })
    dhtmlXForm.prototype.items.phone[a] = dhtmlXForm.prototype.items.input[a];
})();

    
        /**
         * Time form field type
         */
        dhtmlXForm.prototype.items.time = {
            // methods will added automaticaly:
            // show, hide, isHidden, isExist, getType
            
            // 1st param should be item
            
            // constructor, required
            render: function(item, data) {
                // item - div of parent container
                // data - init json
                item._type = "time";
                item._enabled = false;
                var default_val = (typeof(data.value)=="undefined"?'':String(data.value));

                this.doAddLabel(item, data);
                div_element = item;
                /*
                var div_element = document.createElement('DIV');
                div_element._idd = data.name;

                $(div_element).css('width', data.labelWidth);
                item.appendChild(div_element);
                
                var input_element = document.createElement('input');
                input_element.id = data.name;
                input_element.name = data.name;
                input_element.type = "text";
                input_element.value = data.value;               
                input_element.className = "form-control input-small";
                div_element.appendChild(input_element);
                item._value = input_element.value; 
                */

                this.doAddInput(div_element, data, "INPUT", "TEXT", true, true, "dhxform_textarea form-control input-small");
                $(div_element).css('width', data.labelWidth);
                /****span***/
                var span_element = document.createElement('span');
                span_element.innerHTML = "";
                span_element.className = "input-group-addon";
                span_element.id = 'span_' + data.name;

                var time_picker_div = $(div_element).find('div.dhxform_control');

                time_picker_div.addClass('input-group bootstrap-timepicker timepicker');
                time_picker_div.find('input').css('width', data.inputWidth - 25);
                time_picker_div.append(span_element);
                
                var ft_val = get_formatted_time(default_val);
                time_picker_div.find('input[name="' + data.name + '"]').val(ft_val);
                time_picker_div.find('input[name="' + data.name + '"]').prop('readonly', data.disabled);
                item._value = default_val; 

                var span_i = document.createElement('i');
                span_i.className = "glyphicon glyphicon-time";
                span_element.appendChild(span_i);
                
                if (!data.disabled) {
                time_picker_div.find('input[name="' + data.name + '"]').timepicker({
                                    showInputs: true,
                                    minuteStep: 1,
                                    showMeridian: show_meridian

                              }).on('changeTime.timepicker', function(e) {
                                var hr = e.time.hours;
                                if (e.time.meridian == 'PM' && hr != '12') {
                                    hr += 12;
                                } else if (e.time.meridian == 'AM' && hr == '12') {
                                    hr = 0;
                                }

                                min = (1 === e.time.minutes.toString().length ? "0" + e.time.minutes : e.time.minutes);
                                
                                item._value = hr + ':' + min;
                             });
                } else {
                    this._custom_inner_func(item);
                }
                
                return this;
            },

            // destructor, required (if you will use unload)
            destruct: function(item) {                
                item.innerHTML = "";
            },
            
            // enable item, mandatory
            enable: function(item) {                
                item.lastChild.style.color = "red";
                item._enabled = true;
            },
            
            // disable item, mandatory
            disable: function(item) {                
                item.lastChild.style.color = "red";
                item._enabled = false;
                
            },
            
            // your custom functionality
            _custom_inner_func: function(e) {                  
                $(e).find('input').timepicker({
                    template: false
                });
                          
            },

           
            // you need validation and you need set/get value for you form, you need:
            // setValue and getValue, below basic code, you can add yout custom code also
            setValue: function(item, val) {
        var time_picker_div = $(item).find('div.dhxform_control');                
        if (val == '') {
            time_picker_div.find('input[name="' + item._idd + '"]').val('');
        } else {
            var ft_val = get_formatted_time(val);
            time_picker_div.find('input[name="' + item._idd + '"]').val(ft_val);
        }
                item._value = val;                
            },
            
            getValue: function(item) {
                $('.timepicker input').blur();
        var time_picker_div = $(item).find('div.dhxform_control');
        return time_picker_div.find('input[name="' + item._idd + '"]').val();
            }
            
        };

        /**
         * Set data in time field using setFormData
         * @param   {String}  name   Name
         * @param   {String}  value  Value
         */
        dhtmlXForm.prototype.setFormData_time = function(name, value) {
            return this.doWithItem(name, "setValue", value);
        };
        
        /**
         * Get data in time field using getFormData
         * @param   {String}  name   Name
         */
        dhtmlXForm.prototype.getFormData_time = function(name) {
            return this.doWithItem(name, "getValue");
        };
        //time field type ends test purpose only

(function() {
    for (var c in {
        doAddLabel: 1,
        doAddInput: 1,
        doUnloadNestedLists: 1,
        setText: 1,
        getText: 1,
        enable: 1,
        disable: 1,
        isEnabled: 1,
        setWidth: 1,
        setReadonly: 1,
        isReadonly: 1,
        setFocus: 1,
        showTime: 1,
        getInput: 1,
        destruct: 1
    }) {
        dhtmlXForm.prototype.items.time[c] = dhtmlXForm.prototype.items.input[c]
    }
})();
dhtmlXForm.prototype.items.time.doAttachChangeLS = dhtmlXForm.prototype.items.select.doAttachChangeLS;
dhtmlXForm.prototype.items.time.d2 = dhtmlXForm.prototype.items.input.destruct;


/**
 * [time Field type for showing time]
 * 
 */
 /*
dhtmlXForm.prototype.items.time = {
    render: function(g, l) {
        var c = this;
        g._type = "time";
        g._enabled = true;
        var m = navigator.userAgent;
        var a = (m.indexOf("MSIE 6.0") >= 0 || m.indexOf("MSIE 7.0") >= 0 || m.indexOf("MSIE 8.0") >= 0);
        this.doAddLabel(g, l);
        this.doAddInput(g, l, "INPUT", "TEXT", true, true, "dhxform_textarea");
        this.doAttachChangeLS(g);
        if (a) {
            g.childNodes[g._ll ? 1 : 0].childNodes[0].onfocus2 = g.childNodes[g._ll ? 1 : 0].childNodes[0].onfocus;
            g.childNodes[g._ll ? 1 : 0].childNodes[0].onfocus = function() {
                if (this._skipOnFocus == true) {
                    this._skipOnFocus = false;
                    return
                }
                this.onfocus2.apply(this, arguments)
            }
        }
        g.childNodes[g._ll ? 1 : 0].childNodes[0]._idd = g._idd;
        g.childNodes[g._ll ? 1 : 0].childNodes[0].onblur = function() {
            var n = this.parentNode.parentNode;
            if (n._c.base._formMouseDown) {
                n._c.base._formMouseDown = false;
                this._skipOnFocus = true;
                this.focus();
                this.value = this.value;
                n = null;
                return true
            }
            var o = n.getForm();
            o._ccDeactivate(n._idd);
            c.checkEnteredValue(this.parentNode.parentNode);
            if (o.live_validate) {
                c._validate(n)
            }
            o.callEvent("onBlur", [n._idd]);
            o = n = null
        };
        g._f = '%H:%i';
        g._f0 = '%H:%i';
        var h = g.getForm();
        g._c = new dhtmlXCalendarObject(g.childNodes[g._ll ? 1 : 0].childNodes[0], l.skin || h.skin || "dhx_skyblue");
        g._c._nullInInput = true;
        g._c.enableListener(g.childNodes[g._ll ? 1 : 0].childNodes[0]);

        g._c.setDateFormat('%H:%i');
        g._c.showTime();
        
        g._c._itemIdd = g._idd;

        g._c.attachEvent("onShow", function(){
            this.contDates.style.display="none";
            this.contDays.style.display="none";
            this.contMonth.style.display="none";
            this.setMinutesInterval(1);

        });
        g._c.attachEvent("onTimeChange", function(d){
            h1 = d.getHours()< 10 ? '0' + d.getHours() : d.getHours();
            m1 = d.getMinutes()< 10 ? '0' + d.getMinutes() : d.getMinutes();
            this.i[this._activeInp].input.value=h1+":"+m1;
            g._tempValue = (d instanceof Date ? d : g._c._strToDate(d, g._f0 || g._c._dateFormat));
        });

        g._c.attachEvent("onBeforeChange", function(n) {
            if (g._value != n) {
                if (g.checkEvent("onBeforeChange")) {
                    if (g.callEvent("onBeforeChange", [g._idd, g._value, n]) !== true) {
                        return false
                    }
                }
                g._tempValue = g._value = n;
                c.setValue(g, n, false);
                g.callEvent("onChange", [this._itemIdd, g._value])
            }
            return true
        });

        g._c.attachEvent("onClick", function() {
            g._tempValue = null;
        });

        if (a) {
            g._c.base.onmousedown = function() {
                this._formMouseDown = true;
                return false
            }
        }
        this.setValue(g, l.value);

        h = null;
        return this
    },
    getValue: function(c, a) {
        var g = c._tempValue || c._value;
        if (a === true && g == null) {
            return ""
        }

        var hour = g.getHours();
        var minutes = g.getMinutes();

        hour = hour < 10 ? '0' + hour : hour;
        minutes = minutes < 10 ? '0' + minutes : minutes;

        return hour +':'+ minutes;
    },
    setValue: function(c, g, a) {
        if (!g || g == null || typeof(g) == "undefined" || g == "") {
            c._value = c._tempValue = null;
            c.childNodes[c._ll ? 1 : 0].childNodes[0].value = ""
        } else {
            c._value = c._tempValue = (g instanceof Date ? g : c._c._strToDate(g, c._f0 || c._c._dateFormat));
            c.childNodes[c._ll ? 1 : 0].childNodes[0].value = c._c._dateToStr(c._value, c._f || c._c._dateFormat)
        } if (a !== false) {
            c._c.setDate(c._value)
        }
    },
    checkEnteredValue: function(a) {
        this.setValue(a, a._c.getDate())
    }
};
(function() {
    for (var c in {
        doAddLabel: 1,
        doAddInput: 1,
        doUnloadNestedLists: 1,
        setText: 1,
        getText: 1,
        enable: 1,
        disable: 1,
        isEnabled: 1,
        setWidth: 1,
        setReadonly: 1,
        isReadonly: 1,
        setFocus: 1,
        showTime: 1,
        getInput: 1,
        destruct: 1
    }) {
        dhtmlXForm.prototype.items.time[c] = dhtmlXForm.prototype.items.input[c]
    }
})();
dhtmlXForm.prototype.items.time.doAttachChangeLS = dhtmlXForm.prototype.items.select.doAttachChangeLS;
dhtmlXForm.prototype.items.time.d2 = dhtmlXForm.prototype.items.input.destruct;

// dhtmlx time
*/


/**
 * Set Tooltip for window cell
 * @param {String} a tooltip text
 */
dhtmlXWindowsCell.prototype.setTitle = function(a) {
    this.wins.w[this._idd].hdr.title = a;    
};

/**
 * Set user data for tab cell.
 * @param {string} g cell id
 * @param {string} a user data name
 * @param {string} c user data value
 */
dhtmlXTabBar.prototype._setUserData = function(g, a, c) {
    this.userData[g] = {
        a : c
    }
};

/**
 * getUserData Get userdata for tab cell.
 * @param {string} c cell id
 * @param {string} a user data name
 * @return {mixed}    description
 */
dhtmlXTabBar.prototype._getUserData = function(c, a) {
    return (this.userData[c] != null ? this.userData[c].a : null)
};

/**
 * Returns formatted time in 24hr/12hr format to show in grid.
 * @param  {Object} input 24 hr time format eg. 23:30
 * @return {String} Formatted output eg. 11:30 PM
 */
function get_formatted_time(input) {
    var h,m;
    if (input == '') {
        var d = new Date(),
        h = (d.getHours()<10?'0':'') + d.getHours(),
        m = (d.getMinutes()<10?'0':'') + d.getMinutes();
        input = h + ':' + m;
    } 

    var time_array = input.split(':');
    var ext = '';
    h = time_array[0];
    var mer = time_array[1].split(' ');
    m = (1 === mer[0].length ? '0' + mer[0] : mer[0]);
    
    if (show_meridian && mer.length == 1) {
        if(h+m <= 1159){
            ext = 'AM';
            
        } else {
            ext = 'PM';
        } 
        h = (h > 12) ? h-12 : h;

    } else {
        ext = mer[1];
    }
    h = (h == 0) ? 12 : h;
    return  h + ":" + m + ' ' + ext; 
}

/**
 * Returns 24 hour format current time 
 * @return {String} Time
 */
function current_time() {
  var d = new Date(),
      h = (d.getHours()<10?'0':'') + d.getHours(),
      m = (d.getMinutes()<10?'0':'') + d.getMinutes();
      
  return h + ':' + m;
}

/**
 * [enableHeaderMenu Enables Header Menu ] Override to add Overflow Height.
 * @param {Boolean} a Enable header mneu
 */
dhtmlXGridObject.prototype.enableHeaderMenu = function(a) {
    if (!window.dhtmlXMenuObject) {
        return dhtmlx.message("You need to include DHTMLX Menu")
    }
    if (!this._header_menu) {
        var g = this._header_menu = new dhtmlXMenuObject();
        g.renderAsContextMenu();
        var c = this;
        g.attachEvent("onBeforeContextMenu", function() {
            c._showHContext(a);
            // Added scrollbar in grid header menu
            $("div[id$='_dhxWebMenuTopId']").css({overflow: "auto", maxHeight: "390px"});
            return true
        });
        g.attachEvent("onClick", function(r) {
            var n = this.getCheckboxState(r);
            var o = c.hdr.rows[1];
            for (var l = 0; l < o.cells.length; l++) {
                var q = o.cells[l];
                if (q._cellIndexS == r) {
                    var h = q.colSpan || 1;
                    for (var m = 0; m < h; m++) {
                        c.setColumnHidden(r * 1 + m, !n)
                    }
                }
            }
        });
        this.attachEvent("onInit", function() {
            g.addContextZone(this.hdr)
        });
        if (this.hdr.rows.length) {
            this.callEvent("onInit", [])
        }
    }
};

/**
 * Form Validation function for BetweenZeroOne. Returns false if the validation fails.
 * @param  {String} data Value
 * @return {Boolean}     Validation status
 */
dhtmlxValidation.isBetweenZeroOne = function(data) {
    data = data.toString();
    data = data.replace(/^\s+|\s+$/gm,'');
    
    if (data == "" || data > 1 || data <= 0)
        return false;
    else
        return true;
};

/**
 * Escape XML of form input fields.
 * @param {String} a String to escape special characters
 * @return {String}  Escaped string
 */
dhtmlXForm.prototype._escapeSpecialCharacters = function(a) {
    if (a != null) {
        // console.log(a)
        a = a.toString();
        return a.replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/'/g, "&#039;")
            .replace(/"/g, "&quot;");
    } else {
        return a;
    }
}

/**
 * Creates custom combo mode "custom_checkbox"
 */
dhtmlXCombo.prototype.modes.custom_checkbox = {
    top_image_css: "dhxcombo_image",
    items: {},
    last_checked: {},
    render: function(item, data) {
        if (typeof(item.parentNode._optRbGroup) == "undefined") {
            item.parentNode._optRbGroup = window.dhx4.newId();
            this.items[item.parentNode._optRbGroup] = {};
        }
        this.items[item.parentNode._optRbGroup][item._optId] = item;
        
        item._conf = {
            value: data.value,
            css: "",
            checked: window.dhx4.s2b( (data.value == '' || data.value == '-99999999999') ? false : data.checked),
            state: data.state
        };
        
        // main item class, make sure if you will change it - you need to add corresponding css
        item.className = "dhxcombo_option";
        if (data.text == '' || data.value == '-99999999999') {
            item.innerHTML = "<div class='" + this.option_css + "'>&nbsp;</div>";
            if (data.css != null) {
                item.lastChild.style.cssText = data.css;
                item._conf.css = data.css
            }
        } else { 
            item.innerHTML = "<div class='" + String(this.image_css).replace("#state#", (item._conf.checked ? "1" : "0")) + "'></div>" +
                    "<div class='" + this.option_css + " " + (String(data.state).toLowerCase() == "disable" ? "disable_option":"enable_option") + "'>&nbsp;</div>";
        }
        // add custom attr to radio-button image, to separate what element was clicked
        // item._optId - inner option uniq id (different than value), assigned by combo
        // can help you to identify your option
        item.firstChild._optRbId = item._optId;
        
        if (data.css != null) {
            item.lastChild.style.cssText += data.css;
            item._conf.css = data.css;
        }
        this.setText(item, data.text);
        return this;
    },
    destruct: function(item) {
        this.items[item.parentNode._optRbGroup][item._optId] = null;
        item._conf = null;
    },
    setChecked: function(item, state, combo, call_event) {
        if (call_event === undefined) call_event = true;
        item._conf.checked = window.dhx4.s2b(state);
        
        if (item._conf.value != '') {
            item.firstChild.className = String(this.image_css).replace("#state#", (item._conf.checked ? "1" : "0"));
            if (call_event) {
                combo.callEvent("onCheck", [item._conf.value, state]);
                combo.callEvent("onChange", [item._conf.value, state]);
            }
        }
    },
    isChecked: function(item) {
        return (item._conf.checked == true);
    },
    optionClick: function(item, ev, combo) {
        if (item._conf.value == '-99999999999') {
            combo.callEvent("onChange", [item._conf.value]);
        } else if (item._conf.value != '' && String(item._conf.state).toLowerCase() != 'disable') {
            this.setChecked(item, !this.isChecked(item), combo);
        }
        
        this._setCustomComboChecked(combo);
        return false;
    },
    topImageClick: function(item, combo, state) {
        var check_state;
        var trigger_check_event = false;
        if (typeof(state) != 'undefined') {
            check_state = state;
        } else {
            check_state = this.items[combo.list._optRbGroup].check_state;
            if (typeof(check_state) == 'undefined') check_state = true;
            else if (check_state == true) check_state = false;
            else check_state = true;
        }
        this.items[combo.list._optRbGroup].check_state = check_state;
        
        var c_text = new Array();
        for (var a in this.items[combo.list._optRbGroup]) {
            if (a != 'check_state') {
                //Excluded Blank Option to Checked
                if (this.items[combo.list._optRbGroup][a] != null) {
                    var c_value = this.items[combo.list._optRbGroup][a]._conf.value;
                    var c_state = this.items[combo.list._optRbGroup][a]._conf.state;
                    var c_check = this.items[combo.list._optRbGroup][a]._conf.checked;
                    if (c_value != '') {
                        if (String(c_state).toLowerCase() != 'disable') {
                            this.setChecked(this.items[combo.list._optRbGroup][a], check_state, combo, false);
                            trigger_check_event = true;
                        }
                        
                        if ((check_state && (String(c_state).toLowerCase() != 'disable' || c_check)) || (!check_state && String(c_state).toLowerCase() == 'disable' && c_check)) {
                            c_text.push(this.items[combo.list._optRbGroup][a]._conf.text);
                        }
                    }
                }
            }
        }

        if (check_state || c_text.length > 0) {
            this._setCustomComboText(combo, c_text.join(','));
        } else {
            this._setCustomComboText(combo, '');
        }
        
        if (trigger_check_event) {
            combo.callEvent("onCheck", [item ? item._conf.value : '', check_state]);
        }

        return false;
    },
    _setCustomComboText: function(c, a) {
        c.conf.last_text = c.base.firstChild.value = a;
        c.conf.f_server_last = c.base.firstChild.value.toLowerCase();
        // Set Tooltip as Input Title
        c.base.firstChild.title = a;
        // Change class name when check/uncheck
        if (trim(c.base.lastChild.className) == 'dhxcombo_top_image' && a != '') {
            c.base.lastChild.className = ' dhxcombo_top_image dhxcombo_top_image_checked';
        } else if (trim(c.base.lastChild.className) == 'dhxcombo_top_image dhxcombo_top_image_checked' && a == '') {
            c.base.lastChild.className = ' dhxcombo_top_image';
        }
    },
    _setCustomComboChecked: function(combo) {
        var checked_items = combo.getChecked();
        var c_text = new Array();
        for (var i = 0; i < checked_items.length; i++) {
            if (checked_items[i] != '') {
                var opt_obj = combo.getOption(checked_items[i])
                c_text.push(opt_obj.text);
            }
        }
        if (c_text.length > 0) {
            this._setCustomComboText(combo, c_text.join(','));
        } else {
            this._setCustomComboText(combo, '');
        }
    }
};
dhtmlXComboExtend("custom_checkbox", "checkbox");

/**
 * Set custom combo items checked
 * @param   {Object}  a  Item object
 * @param   {Boolean}  c  Item state
 * @param   {Boolean}  d  Call event
 */
dhtmlXCombo.prototype.setChecked = function(a, c, d) {
    this.doWithItem(a, "setChecked", c, this, d)
    if (this.conf.opts_type == 'custom_checkbox') {
        if (this.conf.last_hover != null) {
            this.t[this.conf.last_hover].obj.setSelected(this.t[this.conf.last_hover].item, false);
            this.conf.last_hover = null
        }
        dhtmlXCombo.prototype.modes.custom_checkbox._setCustomComboChecked(this);
    }
};

/**
 * This is the dhtmlx own function
 * And is override for custom_checkbox
 *      - To change combo select/unselect all checkbox on combo text change
 * @param {String} a Text to show in combo input
 */
dhtmlXCombo.prototype.setComboText = function(a) {
    if (this.conf.allow_free_text != true) {
        return
    }
    this.unSelectOption();
    this.conf.last_text = this.base.firstChild.value = a;
    this.conf.f_server_last = this.base.firstChild.value.toLowerCase()
    
    // Change class name when combo text set
    if (trim(this.base.lastChild.className) == 'dhxcombo_top_image' && a != '') {
        this.base.lastChild.className = ' dhxcombo_top_image dhxcombo_top_image_checked';
    } else if (trim(this.base.lastChild.className) == 'dhxcombo_top_image dhxcombo_top_image_checked' && a == '') {
        this.base.lastChild.className = ' dhxcombo_top_image';
    }
};

/**
 * This is the dhtmlx own function
 * And is override for custom_checkbox
 *      - To hide combo select/unselect all checkbox on combo list hide
 *      - To set combo text with all options checked separated with comma
 */
dhtmlXCombo.prototype._hideList = function() {    
    if (trim(this.base.lastChild.className) == 'dhxcombo_top_image' || trim(this.base.lastChild.className) == 'dhxcombo_top_image dhxcombo_top_image_checked') {
        this.base.firstChild.style.marginLeft = "4px";
        this.base.lastChild.style.display = "none";
    }
    
    if (!this._isListVisible()) {
        return
    }
    window.dhx4.zim.clear(this.conf.list_zi_id);
    this.list.style.display = "none";
    if (this.hdr != null) {
        this.hdr.style.display = "none"
    }
    this.conf.clear_click = false;
    if (this.conf.opts_type == 'custom_checkbox') {
        var checked_items = this.getChecked();
        var c_text = new Array();
        for (var i = 0; i < checked_items.length; i++) {
            if (checked_items[i] != '') {
                var opt_obj = this.getOption(checked_items[i])
                c_text.push(opt_obj.text);
            }
        }
        if (c_text.length > 0)
            this.setComboText(c_text.join(','));
        else
            this.setComboText('');
    }
    
    this.callEvent("onClose", [])
};

/**
 * This is the dhtmlx own function
 * And is override to
 *      - To show combo select/unselect all checkbox on combo list shown
 */
dhtmlXCombo.prototype._showList = function(a) {
    if (trim(this.base.lastChild.className) == 'dhxcombo_top_image' || trim(this.base.lastChild.className) == 'dhxcombo_top_image dhxcombo_top_image_checked') {
        this.base.firstChild.style.marginLeft = "23px";
        this.base.lastChild.style.display = "block";
    }
        
    if (this._getListVisibleCount() == 0) {
        if (a && this._isListVisible()) {
            this._hideList()
        }
        return
    }
    if (this._isListVisible()) {
        this._checkListHeight();
        return
    }
    this.list.style.zIndex = window.dhx4.zim.reserve(this.conf.list_zi_id);
    if (this.hdr != null) {
        this.hdr.style.zIndex = Number(this.list.style.zIndex) + 1
    }
    this.list.style.visibility = "hidden";
    this.list.style.display = "";
    if (this.hdr != null) {
        this.hdr.style.visibility = this.list.style.visibility;
        this.hdr.style.display = this.list.style.display
    }
    var c = (this.hdr != null ? this.hdr.offsetHeight : 0);
    this.list.style.width = (Math.max(this.list.offsetWidth || 0, 0) < (this.conf.combo_width + 10)) ? this.conf.combo_width + "px" : this.list.scrollWidth + 20 + "px";
    this.list.style.top = window.dhx4.absTop(this.base) + c + this.base.offsetHeight - 1 + "px";
    this.list.style.left = window.dhx4.absLeft(this.base) + "px";
    if (this.hdr != null) {
        this.hdr.style.width = this.list.style.width;
        this.hdr.style.left = this.list.style.left;
        this.hdr.style.top = parseInt(this.list.style.top) - c + "px"
    }
    this._checkListHeight();
    this.list.style.visibility = "visible";
    if (this.hdr != null) {
        this.hdr.style.visibility = "visible"
    }
    this.callEvent("onOpen", [])
};

/**
 * eXcell_dhxCalendar.prototype.getClientDateValue returns the dhxCalendar cell value in client format
 * Added to fix the issue in grid inline filter of dhxCalendar type column
 *
 * @return date
 */
eXcell_dhxCalendar.prototype.getClientDateValue = function() {
    if (this.cell._clearCell) {
        return ""
    }
    if (this.grid._dtmask && this.cell.val) {
        return this.grid._grid_calendarA.getFormatedDate(this.grid._dtmask, this.cell.val).toString()
    }
    return this.cell.innerHTML.toString()._dhx_trim()
};

/**
 * eXcell_dhxCalendarA.prototype.getClientDateValue returns the dhxCalendarA cell value in client format
 * Added to fix the issue in grid inline filter of dhxCalendarA type column
 * 
 * @return date
 */
eXcell_dhxCalendarA.prototype.getClientDateValue = function() {
    if (this.cell._clearCell) {
        return ""
    }
    if (this.grid._dtmask && this.cell.val) {
        return this.grid._grid_calendarA.getFormatedDate(this.grid._dtmask, this.cell.val).toString()
    }
    return this.cell.innerHTML.toString()._dhx_trim()
};

/**
 * This is the dhtmlx own function
 * And is override to
 *      - Make Date inline filter work for user format (Added getClientDateValue for calendar field)
 *      - Strip html tags from cell value to make filter work if cell value has html tags like in text highlighting
 */
dhtmlXGridObject.prototype._filterA = function(c, g) {
    var l = this.cellType[c];
    var n = "getValue";
    if (l == "link") {
        n = "getContent"
    }
    if (l == "combo" || l == "win_link" || l == 'win_link_custom' || l == "browser") {
        n = "getTitle";
    }
    if (l == "dhxCalendar" || l == "dhxCalendarA") {
        n = "getClientDateValue"
    }
    if (g == "") {
        return
    }
    var h = true;
    if (typeof(g) == "function") {
        h = false
    } else {
        g = (g || "").toString().toLowerCase()
    } if (!this.rowsBuffer.length) {
        return
    }
    for (var a = this.rowsBuffer.length - 1; a >= 0; a--) {
        var wrapped = $("<div>" + this._get_cell_value(this.rowsBuffer[a], c,n).toString().toLowerCase() + "</div>");
        var text = wrapped.text();        
        if (h ? (text.indexOf(g.toLowerCase()) == -1) : (!g.call(this, this._get_cell_value(this.rowsBuffer[a], c,n), this.rowsBuffer[a].idd))) {
            this.rowsBuffer.splice(a, 1)
        }
    }
};

/**
 * This is the dhtmlx own function
 * And is override to
 *      - Make text inline filter work for combo field
 *      (Prevented filter text to be replaced with actual combo value if filter text matched exactly with combo option)
 */
dhtmlXGridObject.prototype.filterByAll = function() {
    var g = [];
    var c = [];
    this._build_m_order();
    for (var h = 0; h < this.filters.length; h++) {
        var m = this._m_order ? this._m_order[this.filters[h][1]] : this.filters[h][1];
        if (m >= this._cCount) {
            continue
        }
        c.push(m);
        var n = this.filters[h][0].old_value = this.filters[h][0].value;
        if (this.filters[h][0]._filter) {
            n = this.filters[h][0]._filter()
        }
        var l;
        if (typeof n != "function" && (l = (this.combos[m] || (this._col_combos ? this._col_combos[m] : false)))) {
            if (l.values && l.values != "undefined") {
                m = l.values._dhx_find(n);
                n = (m == -1) ? n : l.keys[m]
            } else {
                if (l.getOptionByLabel) {
                    //n = (l.getOptionByLabel(n) ? l.getOptionByLabel(n).value : n)
                }
            }
        }
        
        // Added filter icon in grid header if column is filtered
        var $element = $(this.hdr.childNodes[0].childNodes[1].childNodes[m])
        if (n != "") {
            if ($element.has('.filter_icon').length == 0)
                $element.append('<div class="filter_icon"></div>')
        } else {
            $element.find('.filter_icon').remove();
        }

        g.push(n)
    }
    if (!this.callEvent("onFilterStart", [c, g])) {
        return
    }
    this.filterBy(c, g);
    if (this._cssEven) {
        this._fixAlterCss()
    }
    this.callEvent("onFilterEnd", [this.filters]);
    if (this._f_rowsBuffer && this.rowsBuffer.length == this._f_rowsBuffer.length) {
        this._f_rowsBuffer = null
    }
};

/**
 * Export Grid Data.
 * @param {String}    type          Type of export - supports only Excel for now.
 * @param {String}    process_table Process table name
 * @param {String}    grid_name     Gridbox name
 * @param {String}    header        Header
 * @param {String}    order_by      Order By
 */
dhtmlXGridObject.prototype.PSExport = function(type, process_table, grid_name, header, order_by) {
    var that = this;

    // take only visible columns (leave hidden ones)
    var columns_ids = that.columnIds.filter(function(column_id, column_index){
        return !that.isColumnHidden(column_index)
    });

	// Generate where clause from column inline filter
    var col_order = that._c_order
        || columns_ids.map(function (e, i) {
            return i
        });
    var where = col_order.map(function (col_index, index) {  // get all inline filters
        return {
            column: that.getColumnId(index),
            value: that.filters[col_index][0].value
        }
    }).filter(function (filter) { // take only those filters that has a value
        return filter.value != ''
    }).reduce(function (where_clause, filter) { // generate where clause
        return where_clause + (" AND " + filter.column + " LIKE '%" + filter.value + "%'");
    }, ' WHERE 1=1');

    if (header) {
        var headers = header;
    } else {
        var headers = columns_ids.map(function(column_id) {
            return that.getColLabel(that.getColIndexById(column_id))
        }).join(',')
    }

    var number_coumns = ['ed_p','ro_p','ed_v','ro_v','ed_a','ro_a','ed_no','ed_ro'];
    var columns_ids_formatted = columns_ids.map(function(col_id) {
        var column_id = setupDeals.setup_deals.getColTypeById(col_id);
        if ($.inArray(column_id, number_coumns) != -1) {
            var col_type = 'n';
            switch (column_id) {
                case 'ro_v':
                case 'ed_v':
                    col_type = 'v';
                    break;
                case 'ed_p':
                case 'ro_p':
                    col_type = 'p';
                    break;
                case 'ed_a':
                case 'ro_a':
                    col_type = 'a';
                    break;
                default:
                    col_type = 'b';
                    break;
            }
            return 'dbo.FNANumberFormat(' + col_id + ',\'' + col_type + '\') [' + col_id + ']';
        } else {
            return col_id;
        }
    });

    var url = js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/export_sql_to_excel.php';

    var y = document.createElement("div");
    y.style.display = "none";
    document.body.appendChild(y);
    var m = "form_" + (new Date()).valueOf();

    var sorting_info = this.getSortingState();
    if (sorting_info.length > 0) {
        var column_id = this.getColumnId(sorting_info[0]);
        var sort_pref = (sorting_info[1] == 'des') ? 'DESC' : 'ASC';
        order_by = ' ORDER BY ' + column_id + ' ' + sort_pref;
    } else if (order_by == undefined) {
        order_by = '';
    } else {
        order_by = ' ORDER BY ' + order_by;
    }

    var sql = 'SELECT ' + columns_ids_formatted.join(',') + ' FROM ' + process_table + where + order_by;
    // console.log(sql);
    var filename = grid_name + '_' + (new Date()).valueOf();
    y.innerHTML = '<form id="' + m + '" method="post" action="' + url + '" accept-charset="utf-8"  enctype="application/x-www-form-urlencoded" target="_blank">' +
        '<textarea style="display:none" name="type" id="type">' + type + '</textarea>' +
        '<textarea style="display:none" name="sql" id="sql">' + sql + '</textarea>' +
        '<textarea style="display:none" name="headers" id="headers">' + headers + '</textarea>' +
        '<textarea style="display:none" name="columns_ids" id="columns_ids">' + columns_ids + '</textarea>' +
        '<textarea style="display:none" name="filename" id="filename">' + filename + '</textarea>' +
        '</form>';
    document.getElementById(m).submit();
    y.parentNode.removeChild(y);
}

/*
    Added to fix problem of disapearing grid after window resize
*/
var global_box_style = '';
var fixed_grid_style = '';
var fixed_grid_objbox_style = '';
var mobile_grid_style = '';
var mobile_grid_xhdr_style = '';
var mobile_grid_objbox_style = '';

/**
 * This is the dhtmlx own function
 * And is override to
 *      - fix problem of disapearing grid after window resize
 */
dhtmlXLayoutCell.prototype.expand = function(n) {
    if (!this.conf.collapsed) {
        return true
    }
    var g = this.layout;
    if (this.conf.mode == "v") {
        var m = (n ? g.conf.hh : g.cdata[g.conf.nextCell[this._idd]]._getMinWidth(this._idd));
        var h = g.cont.offsetWidth - g.conf.sw;
        if (m + this.conf.size.w_avl > h) {
            g = null;
            return false
        }
    } else {
        if (g.cdata[g.conf.nextCell[this._idd]]) {          
            var l = (n ? g.conf.hh : g.cdata[g.conf.nextCell[this._idd]]._getMinHeight(this._idd) + g.cdata[g.conf.nextCell[this._idd]]._getHdrHeight());
            var c = g.cont.offsetHeight - g.conf.sw;
            if (l + this.conf.size.h_avl > c) {
                g = null;
                return false
            }
        }
    } if (this.conf.docked == false) {
        this.dock();
        return
    }
    this.cell.className = String(this.cell.className).replace(/\s{0,}dhxlayout_collapsed_[hv]/gi, "");
    this.conf.collapsed = false;
    if (this.conf.mode == "v") {
        this.conf.size.w = Math.min(h - m, this.conf.size.w_saved);
        this.conf.size.w_saved = this.conf.size.w_avl = null
    } else {
        this.conf.size.h = Math.min(c - l, this.conf.size.h_saved);
        this.conf.size.h_saved = this.conf.size.h_avl = null
    } if (this.conf.mode == "v") {
        this._fitHdr()
    }
    g.setSizes(g.conf.nextCell[this._idd], g.conf.nextCell[this._idd], n == true, "expand");
    if (typeof g.sep !== 'undefined') g.sep._blockSep();
    g = null;
    
    if (this.getText().indexOf("__custom_header__") != -1) {
        $(".__filter__").show();
        //$("#__filter__").hide(); 
     } else {
    this._hdrUpdText();
    }

    var a = this.layout._getMainInst();
    a._callMainEvent("onExpand", [this.conf.name]);
    a = null;

    
    // Set style of affected elements.
    // The width of these elements are set to 0 after the grid is collapsed
    // Reset width back to normal
    
    // attached object is not found in case of view report page
    if(typeof(this.getAttachedObject()) != 'undefined' && this.getAttachedObject() != null) {
        $(this.getAttachedObject().globalBox).attr('style',global_box_style);
        $(this.getAttachedObject().globalBox).find('.gridbox').attr('style', fixed_grid_style);
        $(this.getAttachedObject().globalBox).find('.gridbox').find('.objbox').attr('style', fixed_grid_objbox_style);
        $(this.getAttachedObject().globalBox).find('.gridbox').next().attr('style', mobile_grid_style);

        // For Internet Explorer, width of these elements are also set to 0.
        // The width of these elements should also be reset back to normal.
        $(this.getAttachedObject().globalBox).find('.gridbox').next().find('.xhdr').attr('style', mobile_grid_xhdr_style);
        $(this.getAttachedObject().globalBox).find('.gridbox').next().find('.objbox').attr('style', mobile_grid_objbox_style);
    }

    return true
};

/**
 * This is the dhtmlx own function
 * And is override to
 *      - fix problem of disapearing grid after window resize
 */
dhtmlXLayoutCell.prototype.collapse = function() {
    if (this.conf.collapsed) {
        return false
    }
    
    // Get style of affected elements.

    // attached object is not found in case of view report page
    if(typeof(this.getAttachedObject()) != 'undefined' && this.getAttachedObject() != null) {
        global_box_style = $(this.getAttachedObject().globalBox).attr('style');
        fixed_grid_style = $(this.getAttachedObject().globalBox).find('.gridbox').attr('style');
        fixed_grid_objbox_style = $(this.getAttachedObject().globalBox).find('.gridbox').find('.objbox').attr('style');
        mobile_grid_style = $(this.getAttachedObject().globalBox).find('.gridbox').next().attr('style');
        
        // For Internet Explorer
        mobile_grid_xhdr_style = $(this.getAttachedObject().globalBox).find('.gridbox').next().find('.xhdr').attr('style');
        mobile_grid_objbox_style = $(this.getAttachedObject().globalBox).find('.gridbox').next().find('.objbox').attr('style');
    }

    var c = this.layout;
    if (c.cdata[c.conf.nextCell[this._idd]] && c.cdata[c.conf.nextCell[this._idd]].expand(true) == false) {
        return false
    }
    if (this.conf.mode == "v") {
        this.conf.size.w_saved = this.conf.size.w;
        this.conf.size.w_avl = this._getMinWidth(this._idd)
    } else { 
        this.conf.size.h_saved = this.conf.size.h;
        this.conf.size.h_avl = this._getMinHeight(this._idd) + this._getHdrHeight()
    }
    this.cell.className += " dhxlayout_collapsed_" + this.conf.mode;
    this.conf.collapsed = true;
    if (this.conf.mode == "v") {
        this.conf.size.w = c.conf.hh
    } else {
        this.conf.size.h = this._getHdrHeight()
    }
    c.setSizes(c.conf.nextCell[this._idd], c.conf.nextCell[this._idd], false, "collapse");
    if (typeof c.sep !== 'undefined') c.sep._blockSep();
    c = null;
    
    if (this.getText().indexOf("__custom_header__") != -1) {
        $(".__form_div__").hide();
        $(".__filter__").show(); 
        $(".__filter_label__").show(); 

        var cell = this._cell_uid;
        var menu_uid = this._menu_uid;
        var menu_id = '__menu_' + menu_uid + '__';
        var menu_min_id = '__menu_min_' + cell + '__';

        $('#' + menu_id).hide();
        $('#' + menu_min_id).show();
    } else {
    this._hdrUpdText();
    }
    
    var a = this.layout._getMainInst();
    a._callMainEvent("onCollapse", [this.conf.name]);
    a = null;
    return true
};
/**/

/* 
 *  DHTMLX library function
 *  Override to show child nodes while searching parent node in tree grid inline filter
 */
dhtmlXGridObject.prototype._filterTreeA = function(g, q) {
    if (q == "") {
        return
    }
    // added to fix issue caused by '&'
    q = escapeXML(q);
    
    var n = true;
    if (typeof(q) == "function") {
        n = false
    } else {
        q = (q || "").toString().toLowerCase()
    }
    var c = function(w, v, u) {
        var x = u.get[w.parent.id];
        if (!x) {
            x = c(w.parent, v, u)
        }
        var u = r.get[w.id];
        if (!u) {
            u = {
                id: w.id,
                childs: [],
                level: w.level,
                parent: x,
                index: x.childs.length,
                image: w.image,
                state: w.state,
                buff: w.buff,
                has_kids: w.has_kids,
                _xml_await: w._xml_await
            };
            x.childs.push(u);
            r.get[u.id] = u
        }
        return u
    };
    var o = this._fbf;
    var r = this._createHierarchy();
    var a;
    var l = this._tr_strfltr;
    var m = this;
    var h = function(u) {
        for (var s = 0; s < u.childs.length; s++) {
            m.temp(u.childs[s])
        }
    };
    switch (l.toString()) {
        /* 
         *  Reversed case -1 & -2 to make child nodes visible while searching parent node.
         *  And to make -2 as default mode so that we do not need to add settings while creating grid
         *  Default mode was -1 previously
        */
        case "-1":
            a = function(s) {
                if (o[s.id]) {
                    return false
                }
                h(s);
                return true
            };
            break;
        case "-2":
            a = function(s) {
                return !s.childs.length
            };
            break;
        default:
            a = function(s) {
                return l == s.level
            };
            break
    }
    this.temp = function(s) {
        if (s.id != 0 && a(s)) {
            if (n ? (this._get_cell_value(s.buff, g).toString().toLowerCase().indexOf(q) == -1) : (!q(this._get_cell_value(s.buff, g), s.id))) {
                o[s.id] = true;
                if (this._tr_fltr_c) {
                    c(s.parent, this._h2, r)
                }
                return false
            } else {
                c(s, this._h2, r);
                if (s.childs && l != -2) {
                    this._h2.forEachChild(s.id, function(u) {
                        c(u, this._h2, r)
                    }, this)
                }
                return true
            }
        } else {
            if (this._tr_fltr_d && this._tr_strfltr > s.level && s.id != 0) {
                c(s, this._h2, r)
            }
            h(s)
        }
    };
    this.temp(this._h2.get[0]);
    this._h2 = r;
    if (this._fake) {
        this._fake._h2 = this._h2
    }
};

/* 
 *  DHTMLX library function
 *  Override to add custom_checkbox combo option check logic.
 */
dhtmlXForm.prototype.setFormData = function(g) {
    for (var c in g) {
        var h = this.getItemType(c);
        
        if (h == 'combo') {
            var combo = this.getCombo(c);
            var combo_opts_type = combo.conf.opts_type;
            h = (combo_opts_type == 'custom_checkbox' ? combo_opts_type : h);
        }

        switch (h) {
            case "checkbox":
                this[g[c] == true || parseInt(g[c]) == 1 || g[c] == "true" || g[c] == this.getItemValue(c, "realvalue") ? "checkItem" : "uncheckItem"](c);
                break;
            case "radio":
                this.checkItem(c, g[c]);
                break;
            case "custom_checkbox":
                var checked_value = '';
                checked_value = combo.getChecked();
                if (checked_value != '' ) {
                    $.each(checked_value, function(index, value) {        
                        combo.setChecked(combo.getIndexByValue(value), false); 
                    });
                }
                for (var j = 0, fcnt = g[c].length; j < fcnt; j++) {
                    combo.setChecked(combo.getIndexByValue(g[c][j]), true);
                }
                break;
            case "input":
            case "textarea":
            case "password":
            case "select":
            case "multiselect":
            case "hidden":
            case "template":
            case "combo":
            case "calendar":
            case "colorpicker":
            case "editor":
                this.setItemValue(c, g[c]);
                break;
            default:
                if (this["setFormData_" + h]) {
                    this["setFormData_" + h](c, g[c])
                } else {
                    if (!this.hId) {
                        this.hId = this._genStr(12)
                    }
                    this.setUserData(this.hId, c, g[c])
                }
                break
        }
    }
};

/* 
 *  DHTMLX library function
 */
eXcell_dhxCalendarA.prototype.setFormattedValue = function(a) {
    if (!a || a.toString()._dhx_trim() == "") {
        a = "&nbsp";
        this.cell._clearCell = true;
        this.cell.val = "";
    } else if (this.grid._dtmask) {
        var formatted_date = this.grid._grid_calendarA.setFormatedDate(this.grid._dtmask, a.toString(), null, true);
        if (formatted_date == "Invalid Date") {
            a = "&nbsp";
            this.cell._clearCell = true;
            this.cell.val = "";
        } else {
            this.cell.val = a;
            this.cell._clearCell = false;
            this.setValue(new Date(formatted_date));
            return;
        }
    } 

    if ((this.cell.val == "NaN") || (this.cell.val == "Invalid Date")) {
        this.cell.val = new Date();
        this.cell._clearCell = true;
        this.setCValue("&nbsp;", 0)
    } else {
        this.setCValue((a || "").toString(), this.cell.val)
    }
};

/**
 * Dynamic calendar form conrol
 */
dhtmlXForm.prototype.items.dyn_calendar = {
    render: function(g, l) {
        g._type = "dyn_calendar";
        g._enabled = true;
        g._dynamicValue = (typeof(l.dynamicValue) == undefined ? 0 :  l.dynamicValue);
        g._dayAdjustment = (typeof(l.dayAdjustment) == undefined ? 0 :  l.dayAdjustment);
        g._adjustmentType = (typeof(l.adjustmentType) == undefined ? "" :  l.adjustmentType);
        g._isBusinessDay = (typeof(l.isBusinessDay) == undefined ? "n" :  l.isBusinessDay);
        g._f1 = (l.dateFormat || null);
        g._f0 = (l.serverDateFormat || g._f1);
        
        //## Define fields name
        g._dynamicValueName = 'dynamic_value';
        g._isBusinessDayName = 'is_business_day';
        g._adjustmentTypeName = 'adjustment_type';
        g._dayAdjustmentName = 'day_adjustment';

        this.doAddLabel(g, l);
        this.doAddInput(g, l, "INPUT", "TEXT", true, true, "dhxform_textarea calendar");
        $('input.calendar').attr('autocomplete', 'off');
        var h = g.getForm();
        g._c = new dhtmlXCalendarObject(g.childNodes[g._ll ? 1 : 0].childNodes[0], l.skin || h.skin || "dhx_skyblue");
        g._c.hideTime();
        g._c._nullInInput = true;
        g._c._itemIdd = g._idd;
        g._c._t = true;
        g._c._adjustpopup = true;
        g._c.attachEvent("onBeforeChange", function(n) {
            if (g._value != n) {
                if (g.checkEvent("onBeforeChange")) {
                    if (g.callEvent("onBeforeChange", [g._idd, g._value, n]) !== true) {
                        return false
                    }
                }
                g._tempValue = g._value = n;
                
                if (!n || n == null || typeof(n) == "undefined" || n == "")
                    g.childNodes[g._ll ? 1 : 0].childNodes[0].value = "";
                else
                    g.childNodes[g._ll ? 1 : 0].childNodes[0].value = g._c._dateToStr(g._value, g._f1 || g._c._dateFormat)
                g.childNodes[g._ll ? 1 : 0].childNodes[0].title = ""
                g.callEvent("onChange", [this._itemIdd, g._value])
            }
            return true
        });

        if (g._f1 != null) {
            g._c.setDateFormat(g._f1)
        }

        g._c.base.onmousedown = function() {
            return true;
        };
        
        g._c._updateFromInput = function(a) {
            if ((g.childNodes[g._ll ? 1 : 0].childNodes[0].value == "") || (g._c._strToDate(a.value) instanceof Date)) {
                g._dynamicValue = 0;
                g._dayAdjustment = 0;
                g._adjustmentType = "";
                g._isBusinessDay = "n";
            } else if (!(g._c._strToDate(a.value) instanceof Date)) {
                g._c.setDate(null);
            }
            g._c._t = false;
            g._f.setItemValue(g._dynamicValueName, g._dynamicValue);
            g._f.setItemValue(g._dayAdjustmentName, g._dayAdjustment);
            g._f.setItemValue(g._adjustmentTypeName, g._adjustmentType);

            /*Added to call onChangeEvent as it was raising the isse when 
            clickinh on text field after selecting the dynamic date value.  */          
            g._c._t = true;
            if (g._isBusinessDay == "y") 
                g._f.checkItem(g._isBusinessDayName);

            if (g._c._nullInInput && ((a.value).replace(/\s/g, "")).length == 0) {
                if (g._c.checkEvent("onBeforeChange")) {
                    if (!g._c.callEvent("onBeforeChange", [null])) {
                        if (g._c.i != null && g._c._activeInp != null && g._c.i[g._c._activeInp] != null && g._c.i[g._c._activeInp].input != null) {
                            g._c.i[g._c._activeInp].input.value = g._c.getFormatedDate()
                        }
                        return
                    }
                }
                g._c.setDate(null);

            } else {
                if(g._c._strToDate(a.value) instanceof Date){
                    g._c._updateDateStr(a.value);
            }
              
            }
            a = null
        };
        var j = [
                {type:"settings", position:"label-top"},
                {type:"block", blockOffset: 10, className:"dyn-fields-container", list:[
                    {type:"combo", label:"Dynamic Date", name:g._dynamicValueName, inputWidth:90, options: dynamic_date_options},
                    {type:"combo", label:"Adjust Type", name:g._adjustmentTypeName, inputWidth:90, options: dynamic_date_adj_type_options},
                    {type:"newcolumn"},
                    {type:"combo", label:"Adjust Value", name:g._dayAdjustmentName, inputWidth:90, offsetLeft:10, options: day_adjustment},
                    {type:"checkbox", label:"Business Day", name:g._isBusinessDayName, offsetLeft:10},
                    {type: 'button', name: 'ok', value: '<img src="' + js_image_path  + 'dhxmenu_web/tick_18.png">', tooltip:"Ok", className: "dynamic_ok_btn_adjust" },
                    {type: 'button', name: 'clear',value: '<img src="' + js_image_path + 'dhxmenu_web/close_18.png">', tooltip:"Clear", className: "dynamic_clear_btn_adjust" }
                ]}
            ];
        
        var dyn_id = "dhxform_item_dyn_calendar_" + l.name + "_" + window.dhx.uid();
        $(g._c.base.firstChild).attr("id", dyn_id);

        /*
        DTHMLX is setting combo width to 118px rejecting given width
        when container (normally form) is hidden. Might be a bug.
        Since we need to resize combo for dynamic calendar, 
        a workaround is made to first show the calendar, 
        load the form json and finally hiding the calendar.
        The opacity was set to remove flickering effect during slow loading.
        TODO: Check if newer version of DHTMLX fixes this issue.
         */
        g._c.base.style.opacity = "0";
        g._c.show();
        g._f = new dhtmlXForm(dyn_id, j);
        //setTimeout(function() {
            g._c.hide();
            g._c.base.style.opacity = "100";
        //}, 1000);


        var d = g._f.getCombo(g._dynamicValueName);
        d.base.firstChild.readOnly = true;
         k = this

        g._f.attachEvent("onButtonClick", function(name) {
            if (name == 'clear' || name == 'ok') {
                if(name == 'clear') {
                g._c.setDate(null);
                k.setValue(g, "");
                g._f.setItemValue(g._dynamicValueName, "");
                g._f.setItemValue(g._adjustmentTypeName, 106400);
                g._f.setItemLabel(g._isBusinessDayName, "Business Day");
                g._f.setItemValue(g._dayAdjustmentName, "");
                g._f.uncheckItem(g._isBusinessDayName);
            }
                g._c.hide();
            }
        });
        g._f.attachEvent("onChange", function(a, b) {
            if (g._f.getItemType(a) == 'combo' && b != 0 && a == g._dynamicValueName) {
                g._c.setDate(null);
                g._dynamicValue = b;
            } else if (g._f.getItemType(a) == 'combo' && a == g._adjustmentTypeName && b != 0) {
                g._adjustmentType = b;
                g._isBusinessDay = "n";
                g._f.uncheckItem(g._isBusinessDayName);
                if (b == 106400)
                    g._f.setItemLabel(g._isBusinessDayName, "Business Day");
                else
                    g._f.setItemLabel(g._isBusinessDayName, "Next Business Day");
                
            } else if (g._f.getItemType(a) == "checkbox" && a == g._isBusinessDayName) {
                var is_checked = g._f.isItemChecked(a);
                g._isBusinessDay = (is_checked == true) ? "y" : "n";
            } else if(g._f.getItemType(a) == 'combo' && a == g._dayAdjustmentName) {
                g._dayAdjustment = (b == "" ? 0 : b);

            } else if(g._f.getItemType(a) == 'combo' && a == g._dynamicValueName && b=="") {
                    k.setValue(g, "");
                    g._f.setItemValue(g._adjustmentTypeName, 106400);
                    g._f.setItemLabel(g._isBusinessDayName, "Business Day");
                    g._f.setItemValue(g._dayAdjustmentName, "");
                    g._f.uncheckItem(g._isBusinessDayName);
            }
            if (g._dynamicValue != "" && g._dynamicValue != 0) {
                //g._adjustmentType = (g._adjustmentType == '' || null) ? 106400 : g._adjustmentType;
            k.setValue(g, ["", g._dynamicValue, g._dayAdjustment, g._adjustmentType, g._isBusinessDay]);
                g._c._t = true;
            }
        });

        // g._f.attachEvent("onInputChange", function(a, b, f) {
        //     console.log(f)
        //     g._dayAdjustment = (b == "" ? 0 : b);
        //     if (f.getItemValue(g._dynamicValueName) != 0 || f.getItemValue(g._dynamicValueName) != "") {
        //         k.setValue(g, ["", g._dynamicValue, g._dayAdjustment, g._adjustmentType, g._isBusinessDay]);
        //         g._c._t = true;
        //     }
        // });
        
        this.setValue(g, [(l.value == undefined ? "" :  l.value), l.dynamicValue, l.dayAdjustment, g._adjustmentType, g._isBusinessDay]);
        return this;
    },

    destruct: function(g) {                
        g.innerHTML = "";
    },
    
    enable: function(g) {
        g._enabled = true;
    },
    
    disable: function(g) {
        g._enabled = false;
    },
    //Sets Array Value [,45600,3,106400,'y'] or ['2017-10-30,0,0,'','n']
    setValue: function(g, v) {
            if (v == '') v = ['', 0, 0, "", "n"];
            else if (!Array.isArray(v) && (typeof v == "object")) {
                var a = [v.actualValue, v.dynamicValue, v.dayAdjustment, v.adjustmentType, v.isBusinessDay]; var v = a;
            } else if (v.indexOf('|') > -1) {
                v = v.split("|");
                /* added as the new formate doesnot contain static date as first i.e 45606|0|106400|n*/
                v.unshift("");
            } else if(typeof v == 'string' && v.indexOf('|') == -1) {
                /*added as the new formate doesnot contains dynamic date part when static date is selected */
                v = [v, 0, 0, "", "n"];
            }
            
            if (!(g._c._strToDate(v[0], g._f0 || g._c._dateFormat) instanceof Date)) {
                g._dynamicValue = v[1];
                g._dayAdjustment = (v[2] == "" ? "0" : v[2]);
                /* set the _adjustmentType to 
                    106400 to select the first option i.e day as it ho no blank option
                    and added condition v[3] == "" && v[1] != "" && v[2] != "" 
                    to return blank value if all other fields are blank
                */
                g._adjustmentType = ((v[3] == "" && v[1] != "" && v[2] != "" )? 106400 : v[3]);
                g._isBusinessDay = (v[3] == "" && (v[4] == "" || v[4] == "n")) ? "n" : v[4];
                var b = "";
                if (g._dynamicValue != "" && g._dynamicValue != 0) {
                    var d = g._f.getCombo(g._dynamicValueName);
                    var e = d.getOptionByIndex(d.getIndexByValue(g._dynamicValue));

                    var dt = g._f.getCombo(g._adjustmentTypeName);
                    var et = dt.getOptionByIndex(dt.getIndexByValue(g._adjustmentType));
                    if (g._dayAdjustment > 1 || g._dayAdjustment < -1) {
                        et.text = et.text + 's';
                    }
                    if (e != null) {
                        b = ((g._adjustmentType != 106400 && g._isBusinessDay == "y") ? 'Business Day' : '') + 
                            '[' + e.text + ((g._dayAdjustment != 0) ? ((g._dayAdjustment > -1) ? ' +' : '') + ' ' + g._dayAdjustment.replace('-', '- ') + ' ' : '') + 
                            ((g._adjustmentType == 106400 && g._isBusinessDay == "y" && g._dayAdjustment != 0) ? 'Business ' : '') + ((g._dayAdjustment != 0) ? et.text : '') + ']';                    
                    }
                }
                g._value = b
                g.childNodes[g._ll ? 1 : 0].childNodes[0].value = b;
                g.childNodes[g._ll ? 1 : 0].childNodes[0].title = g._value;
            } else {
                g._value = (v[0] instanceof Date ? v[0] : g._c._strToDate(v[0], g._f0 || g._c._dateFormat));
                g.childNodes[g._ll ? 1 : 0].childNodes[0].value = g._c._dateToStr(g._value, g._f1 || g._c._dateFormat);
                g._dynamicValue = g._dayAdjustment = 0;
                g._adjustmentType = "";
                g._isBusinessDay = "n";
                g.childNodes[g._ll ? 1 : 0].childNodes[0].title = "";
            }
        },
        
        getValue: function(g, o) {
            var a = [];
            var j = {};
            var b = g.childNodes[g._ll ? 1 : 0].childNodes[0].value;
            
            if (!(g._c._strToDate(b) instanceof Date) && (g._c._t || b == '')) {
                a[0] = j.actualValue = ""; a[1] = j.dynamicValue = g._dynamicValue; a[2] = j.dayAdjustment = g._dayAdjustment;
                a[3] = j.adjustmentType = g._adjustmentType; a[4] = j.isBusinessDay = g._isBusinessDay;
            } else {
                var c = (b instanceof Date ? b : g._c._strToDate(b, g._f1 || g._c._dateFormat));
                a[0] = j.actualValue = g._c._dateToStr(c, g._f0 || g._c._dateFormat);
                a[1] = j.dynamicValue = a[2] = j.dayAdjustment = a[3] = j.adjustmentType = a[4] = j.isBusinessDay = null;
            }
            /*
                To find the value is selected or not
             */
            var len = a.filter(function (e) {
              return e !== 0 && e !== '0' && e !== 'n' && e !== 'y' && e !== '' && e !== null && e !== undefined;
            }).length;

            if(len > 1 || (len == 1 && a[0] != '' && a[0] != null)) {
                if (o == 'json') {
                    return j;
                } else if (o == 'array') {
                    return a;
                } else {
                    if(a[0] != '' && a[0] != null) {
                        return a[0]; //static date case (2017-01-01)
                    } else{
                        a.splice(0, 1); // added to get value in the formate 45606|0|106400|n (Dynamic DAte|Adjust Value|AdjustType|BizDay)
                        return a.join("|"); // dynamic date case 
                    }
                    
                }
            } else {
                return '';
            }
        },
    // getDynamicValue: function(g) {
    //     var a = [], j = {};
    //     var b = g.childNodes[g._ll ? 1 : 0].childNodes[0].value;

    //     if (!(g._c._strToDate(b) instanceof Date) && (g._c._t || b == '')) {
    //         a[0] = ""; a[1] = g._dynamicValue; a[2] = g._dayAdjustment; a[3] = g._adjustmentType; a[4] = g._isBusinessDay;
    //     } else {
    //         var c = (b instanceof Date ? b : g._c._strToDate(b, g._f1 || g._c._dateFormat));
    //         a[0] = g._c._dateToStr(c, g._f0 || g._c._dateFormat); a[1] = null; a[2] = null; a[3] = null; a[4] = null;
    //     }
    //     var len = a.filter(function (e) {
    //       return e !== 0 && e !== '0' && e !== 'n' && e !== 'y' && e !== '';
    //     }).length;
        
    //     return ((len > 0) ? ('DYNDATE[' + a.join("|") + ']') : '');
    // },

    getCalendar: function(a) {
        var b = {};
        b.calendar = a._c;
        b.form = a._f;
        return b;
    },

    setDateFormat: function(c, a, g) {
        c._f1 = a;
        c._f0 = (g || c._f1);
        c._c.setDateFormat(c._f1);
        this.setValue(c, this.getValue(c))
    },

    _getItemNode: function (a) {
        return a
    }
};

(function() {
    for (var c in {
        doAddLabel: 1,
        doAddInput: 1,
        doUnloadNestedLists: 1,
        setText: 1,
        getText: 1,
        enable: 1,
        disable: 1,
        isEnabled: 1,
        setWidth: 1,
        setReadonly: 1,
        isReadonly: 1,
        setFocus: 1,
        getInput: 1,
        destruct: 1,
    }) {
        dhtmlXForm.prototype.items.dyn_calendar[c] = dhtmlXForm.prototype.items.input[c]
    }
})();
dhtmlXForm.prototype.items.dyn_calendar.doAttachChangeLS = dhtmlXForm.prototype.items.select.doAttachChangeLS;
dhtmlXForm.prototype.items.dyn_calendar.d2 = dhtmlXForm.prototype.items.input.destruct;

dhtmlXForm.prototype.setFormData_dyn_calendar = function(name, value) {
    return this.doWithItem(name, "setValue", value);
};

dhtmlXForm.prototype.getFormData_dyn_calendar = function(name) {
    return this.doWithItem(name, "getValue");
};

dhtmlXForm.prototype.setCalendarDateFormat = function(c, a, g) {
    this.doWithItem(c, "setDateFormat", a, g)
};

// dhtmlXForm.prototype.getDynamicValue = function (name) {
//     return this.doWithItem(name, "getDynamicValue");
// };

// dhtmlXForm.prototype.setDynamicValue = function (name, value) {
//     if (value.indexOf('DYNDATE') == 0 && value.indexOf('|') > -1) {
//         value = value.replace('DYNDATE', '').replace('[', '').replace(']', '').split('|');
//         var a = ['', value[0], value[1], value[2], value[3]];
//     } else {
//         var a = [value, 0, 0,'', 'n'];
//     }
    
//     return this.doWithItem(name, "setValue", a);
// };

/**
 * Validate Dynamic Calendar Field.
 * @param  {string}  a value
 */
dhtmlxValidation.isValidDynamicDate = function(a) {
    if (a[0] != "" && a[0] != null && a.length == 1) return dhtmlxValidation.isValidDate(a[0]);
    return true;
}

/**
 * Copy data from excel
 * @param {Boolean} row_add Row to add automatically
 */
dhtmlXGridObject.prototype.copyFromExcel = function (row_add) {
    this.enableBlockSelection();
    var validation_enabled = false;
    /* Check if validaton has been enabled */
    if(this.hasOwnProperty('_validators')){
        validation_enabled = true;
    }
    this.csvParser.unblock = function (m, a, l) {
        var h = (m || "").split(l);
        for (var c = 0; c < h.length; c++) {
            h[c] = (h[c] || "").split(a);
        }
        var g = h.length - 1;
        if (h[g].length == 1 && h[g][0] == "") {
            h.splice(g, 1)
        }
        return h.map(function(e){
            return e.map(function(f){
                return (dates.convert_to_sql(f) == "NaN-NaN-NaN") ? f : dates.convert_to_sql(f);
            })
        });
    };

    this.attachEvent("onKeyPress", function(code,ctrl,shift) {
        if(code==86&&ctrl){
            this.setCSVDelimiter("\t");
            this.pasteBlockFromClipboard();
        } else if (code == 27) {
            this._HideSelection();
        }
        return true;
    });

    this.attachEvent("onRowPaste", function(rId) {
        /*
            Can be used to process data after paste has been completed for a row
         */
        // Added for case when  this event has been attached to grid enable menu items
        this.callEvent("onRowSelect", [rId]);
    });

    /* Hides block selection */
    this.attachEvent("onEmptyClick", function(ev){
        this._HideSelection();
    });

    this._pasteBlockFromClipboard = function() {
        var o = this._clip_area.value;
        var copy_value = '';
        if (!o) {
            return
        }
        if (this._selectionArea != null) {
            var w = this._selectionArea.LeftTopRow;
            var a = this._selectionArea.LeftTopCol
        } else {
            if (this.cell != null && !this.editor) {
                var w = this.getRowIndex(this.cell.parentNode.idd);
                var a = this.cell._cellIndex
            } else {
                return false
            }
        }
        o = this.csvParser.unblock(o, this.csv.cell, this.csv.row);
        var q = w + o.length;
        var u = a + o[0].length;
        if (u > this._cCount) {
            u = this._cCount
        }
        var h = 0;

        /*
        * Add new rows in the grid if needed
        * */
        // Added to check if automatic row addition is required or not
        if (row_add) {
            var copy_row_count = o.length;
            var current_row_count = this.getRowsNum();
            var current_selected_row_num = this.getSelectedBlock().LeftTopRow;
            if (this._selectionArea != null) {
                new_rows_to_added = copy_row_count - (current_row_count - current_selected_row_num);
            } else {
                new_rows_to_added = copy_row_count - current_row_count;
            }
            for (var i = 0; i < new_rows_to_added; i++) {
                // var test_date = (new Date()).valueOf();
                this.addRow((new Date()).valueOf() + i,'');
            }
        }
        for (var r = w; r < q; r++) {
            var x = this.render_row(r);
            if (x == -1) {
                continue
            }
            var g = 0;
            for (var m = a; m < u; m++) {
                if (this._hrrar[m] && !this._fake) {
                    u = Math.min(u + 1, this._cCount);
                    continue
                }
                var s = this.cells3(x, m);
                if (s.isDisabled()) {
                    g++;
                    continue
                }
                if (this._onEditUndoRedo) {
                    this._onEditUndoRedo(2, x.idd, m, o[h][g], s.getValue())
                }

                if (this.getColType(m) == 'combo') {
                    var combo = this.getColumnCombo(m);
                    copy_value = o[h][g++];
                    if (combo.getOptionByLabel(copy_value)) {
                        s.setValue(combo.getOptionByLabel(copy_value).value);
                    }
                } else {
                    copy_value = o[h][g++];
                    s[s.setImage ? "setLabel" : "setValue"](copy_value)
                }

                if (validation_enabled && this._validators.data[m] != "") {
                    this.validateCell(x.idd,m);
                }
                s.cell.wasChanged = true;
                // Added for case when  this event has been attached to grid
                this.callEvent("onEditCell", [2,x.idd,m,'',copy_value]);
            }
            this.callEvent("onRowPaste", [x.idd]);
            h++
        }
        this._HideSelection();
    };
}

/**
 * Gets row data array
 * Can be removed after upgrading dhtmlX to 5.1
 * @param {String} h Row id
 * @return {Array}   Row data
 */
dhtmlXGridObject.prototype.getRowData = function(h) {
    var c = {};
    var a = this.getColumnsNum();
    for (var e = 0; e < a; e++) {
        var g = this.getColumnId(e);
        if (g) {
            c[g] = this.cells(h, e).getValue()
        }
    }
    return c
};

/**
 * Sets row data array
 * Can be removed after upgrading dhtmlX to 5.1
 * @param {String} h Row id
 * @param {Array}  e Row data
 */
dhtmlXGridObject.prototype.setRowData = function(h, e) {
    var a = this.getColumnsNum();
    for (var c = 0; c < a; c++) {
        var g = this.getColumnId(c);
        if (g && e.hasOwnProperty(g)) {
            this.cells(h, c).setValue(e[g])
        }
    }
};


/**
 * Custom Layout pattern 5T
 */
dhtmlXLayoutObject.prototype.tplData["5T"] = {
    mode: "h",
        cells: {
            a: {
                name: "a",
                fsize: {
                    v: 1
                }
            },
            b: {
                layout: {
                    mode: "v",
                    cells: {
                        a: {
                            name: "b",
                            width: 1 / 3,
                            fsize: {
                                h: 2,
                                v: 1
                            }
                        },
                        b: {
                            layout: {
                                mode: "v",
                                cells: {
                                    a: {
                                        layout: {
                                            mode: "h",
                                            cells: {
                                                a: {
                                                    name: "c",
                                                    fsize: {
                                                        h: [2, 3],
                                                        v: 1
                                                    }
                                                },
                                                b: {
                                                    name: "d",
                                                    fsize: {
                                                        h: [2, 3],
                                                        v: 4
                                                    }
                                                }
                                            }
                                        }
                                        

                                    },
                                    b: {
                                        name: "e",
                                        fsize: {
                                            h: 3,
                                            v: 1
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
}

/**
 * Custom layout patter 5T auto size properties
 */
dhtmlXLayoutObject.prototype._availAutoSize["5T"] = {
    h: ["a;c;d"],
    v: ["b;d;e"]
}

/**
 * Column type for browser.
 * @param  {object} cell Cell object
 */
function eXcell_browser(cell) {
    if (cell) {
        this.cell = cell;
        // $(this.cell).mouseenter(function(e) {
        //     $(e.target).find('input').show();
        // }).mouseleave(function(e) {
        //     $(e.target).find('input').hide();
        // })
        this.grid = this.cell.parentNode.grid;
    }
    
    this.clearValue = function() {
        this.setValue("^");
        // Added this logic to mark the cell as changed so that the grid would know something has been changed.
        this.grid.cells(this.cell.parentNode.idd, this.cell._cellIndex).cell.wasChanged = true;
        this.grid.validateCell(this.cell.parentNode.idd, cell.cellIndex);
        this.grid.callEvent("onEditCell", [2, this.cell.parentNode.idd, cell._cellIndex, '', old_val]);
    }
    
    this.showClearButton = function(id) {
        var span_id = '#' + id;
        $(span_id).css("display", "block");
    }

    this.hideClearButton = function(id) {
        var span_id = '#' + id;
        $(span_id).css("display", "none");
    }

    this.setValue = function(g) {
        var c = g.split("^");
        if (g == "") {
            c[0] = "";
            c[1] = "";
        }

        this.cell.style.position = 'relative';
        // (event||window.event).cancelBubble used to not allow event propagation
        var dyn_span_id = 'brs_' + Math.random().toString(36).replace(/[^a-z]+/g, '').substr(2, 10);
        var mouse_over_out_func = "onmouseover='new eXcell_browser(this.parentNode).showClearButton(&quot;" + dyn_span_id + "&quot;);' onmouseout='new eXcell_browser(this.parentNode).hideClearButton(&quot;"+ dyn_span_id +"&quot;);'";
        this.setCValue("<span " + mouse_over_out_func + " style='overflow:hidden;display:block;' data-id='" + c[0] + "'>" + c[1] + "</span>"+ 
            (c[1] != "" ? 
                " <input id='" + dyn_span_id + "' " + mouse_over_out_func + 
                " style='position:absolute;right:5px;top:5px;display:none;' \
                  onclick='(event||window.event).cancelBubble=true; new eXcell_browser(this.parentNode).clearValue();'\
                  src='"+ js_image_path + "dhxmenu_web/dismiss.gif'\
                  type='image'>"
                : ""),
            g);
    }

    this.getValue = function() {
        if (this.cell.firstChild) {
            if (this.cell.firstChild.getAttribute) {
                var c = this.cell.firstChild.getAttribute("data-id");
                return c;
            } else {
                return "";
            }
        } else {
            return "";
        }
    };
    this.edit = function() {
        this.val = this.getValue();
        CELL = this.cell;
        GRID = this.cell.parentNode.grid;
        ROW = this.cell.parentNode.idd;
        
        var browser_name = GRID.getColLabel(CELL._cellIndex);
        var browser_grid_name = GRID.getUserData("", 'browse_' + GRID.getColumnId(CELL._cellIndex));
        var browser_grid_multi_select = GRID.getUserData("", 'browse_' + GRID.getColumnId(CELL._cellIndex) + "_multi_select");
        var browser_grid_sql = GRID.getUserData("", 'browse_' + GRID.getColumnId(CELL._cellIndex) + "_sql");

        ___unload_browse_win_link_window_window();

        if (!___browse_win_link_window) {
            ___browse_win_link_window = new dhtmlXWindows();
        }

        var win_len = 550;
        var win_width = 400;

        if (browser_grid_name == 'formula_form') { 
            win_len = 900;
            win_width = 600;
            browser_name = 'Formula';
        } 

        new_browse = ___browse_win_link_window.createWindow('w1', 0, 0, win_len, win_width);
        new_browse.setText("Browse " + browser_name);
        new_browse.centerOnScreen();
        new_browse.setModal(true);
        var params = {}

        if (browser_grid_name == 'formula_form') { 
            var formula_id = this.val;
            var src = js_php_path + 'adiha.html.forms/_setup/formula_builder/formula.editor.php?formula_id=' + formula_id + '&call_from=grid_browser&is_browse=y'; 
            src = src.replace("adiha.php.scripts/", ""); 
        } else {            
            var src = js_php_path + 'components/lib/adiha_dhtmlx/generic.browser.php?call_from=grid_browser&enable_grid_multi_select=' + browser_grid_multi_select + '&';
            src += 'browse_name=' + browser_grid_name + '&grid_name=' + browser_grid_name + '&grid_label=' + browser_name + '&grid_sql=' + browser_grid_sql;
            params = {
                "selected_id": this.val,
                "selected_label": this.cell.innerText.trim()
            }
        }
       
        new_browse.attachURL(src, false, params);

        new_browse.attachEvent('onClose', function(win) {
            if (typeof new_browse.new_browse_value != 'undefined') {
                var browser_id = new_browse.new_browse_value.value;
                var browser_text = new_browse.new_browse_value.text;
                var old_value = GRID.cells(ROW, CELL._cellIndex).getValue();
                GRID.cells(ROW, CELL._cellIndex).setValue(browser_id + '^' + browser_text);
                GRID.cells(ROW, CELL._cellIndex).cell.wasChanged = true;
                /*
                onEditCell event call is commented as we noticed editStop also fires this same event. 
                Uncommenting it showed the confirmation message twice in deal detail grid
                when data browser value was changed in group level as onEditCell was fired twice
                , calling dealDetail.deal_detail_edit twice.
                TODO: Need to test its impacts.
                */
                // GRID.callEvent("onEditCell", [2, ROW, CELL._cellIndex, browser_id, old_value]);
            }
            GRID.editStop();
            return true;
        });
    }
}
eXcell_browser.prototype = new eXcell;

/**
 * Attach browser to cell
 * @param   {Array}  h  Browser information
 */
dhtmlXGridObject.prototype.attachBrowser = function(h) {
    for (var k in h) {
        var a = h[k].split("->");
        this.setUserData("", "browse_" + k, a[0]);
        this.setUserData("", "browse_" + k + "_multi_select", (a[1] || 0));
        this.setUserData("", "browse_" + k + "_sql", (a[2] || ''));
    }
};

/**
 * Set windows cell position to bottom in viewport
 */
dhtmlXWindowsCell.prototype.bottom = function() {
    var g = this.wins.vp;
    var c = this.wins.w[this._idd];
    var a = Math.round((g.clientWidth - c.conf.w) / 2);
    var h = Math.round((g.clientHeight - c.conf.h));
    this.wins._winSetPosition(this._idd, a, h);
    g = c = null
};

// *** dhtmlX functions override to support i18n starts *** //
// Calendar langdata
dhtmlXCalendarObject.prototype.lang = "custom";
dhtmlXCalendarObject.prototype.langData.custom = {
    dateformat: dhtmlXCalendarObject.prototype.langData.en.dateformat,
    hdrformat: dhtmlXCalendarObject.prototype.langData.en.hdrformat,
    monthesFNames: dhtmlXCalendarObject.prototype.langData.en.monthesFNames.map(get_locale_value),
    monthesSNames: dhtmlXCalendarObject.prototype.langData.en.monthesSNames.map(get_locale_value),
    daysFNames: dhtmlXCalendarObject.prototype.langData.en.daysFNames.map(get_locale_value),
    daysSNames: dhtmlXCalendarObject.prototype.langData.en.daysSNames.map(get_locale_value),
    weekstart: dhtmlXCalendarObject.prototype.langData.en.weekstart,
    weekname: dhtmlXCalendarObject.prototype.langData.en.weekname
};
// Grid paging texts
dhtmlXGridObject.prototype.i18n.paging = {
    results: get_locale_value("Results"),
    records: get_locale_value("Records from") + ' ',
    to: ' ' + get_locale_value("to") + ' ',
    page: get_locale_value("Page") + ' ',
    perpage: get_locale_value("rows per page"),
    first: get_locale_value("To first Page"),
    previous: get_locale_value("Previous Page"),
    found: get_locale_value("Found records"),
    next: get_locale_value("Next Page"),
    last: get_locale_value("To last Page"),
    of: ' ' + get_locale_value("of") + ' ',
    notfound: get_locale_value("No Records Found")
};
// Menu initialization
dhtmlXMenuObject.prototype._initObj = function(u, v, n) {
    if (!(u instanceof Array)) {
        n = u.parentId;
        if (n != null && String(n).indexOf(this.idPrefix) !== 0) {
            n = this.idPrefix + String(n)
        }
        u = u.items
    }
    for (var g = 0; g < u.length; g++) {
        if (typeof(u[g].id) == "undefined" || u[g].id == null) {
            u[g].id = this._genStr(24)
        }
        if (u[g].text == null) {
            u[g].text = ""
        } else {
            var locale_text = get_locale_value(u[g].text);
            u[g].text = locale_text;
            u[g].title = locale_text;
        }
        if (String(u[g].id).indexOf(this.idPrefix) !== 0) {
            u[g].id = this.idPrefix + String(u[g].id)
        }
        var h = {
            type: "item",
            tip: "",
            hotkey: "",
            state: "enabled",
            imgen: "",
            imgdis: ""
        };
        for (var w in h) {
            if (typeof(u[g][w]) == "undefined") {
                u[g][w] = h[w]
            }
        }
        if (u[g].imgen == "" && u[g].img != null) {
            u[g].imgen = u[g].img
        }
        if (u[g].imgdis == "" && u[g].img_disabled != null) {
            u[g].imgdis = u[g].img_disabled
        }
        if (u[g].title == null && u[g].text != null) {
            u[g].title = u[g].text
        }
        if (u[g].href != null) {
            if (u[g].href.link != null) {
                u[g].href_link = u[g].href.link
            }
            if (u[g].href.target != null) {
                u[g].href_target = u[g].href.target
            }
        }
        if (u[g].userdata != null) {
            for (var w in u[g].userdata) {
                this.userData[u[g].id + "_" + w] = u[g].userdata[w]
            }
        }
        if (typeof(u[g].enabled) != "undefined" && window.dhx4.s2b(u[g].enabled) == false) {
            u[g].state = "disabled"
        } else {
            if (typeof(u[g].disabled) != "undefined" && window.dhx4.s2b(u[g].disabled) == true) {
                u[g].state = "disabled"
            }
        } if (typeof(u[g].parent) == "undefined") {
            u[g].parent = (n != null ? n : this.idPrefix + this.topId)
        }
        if (u[g].type == "checkbox") {
            u[g].checked = window.dhx4.s2b(u[g].checked);
            u[g].imgen = u[g].imgdis = "chbx_" + (u[g].checked ? "1" : "0")
        }
        if (u[g].type == "radio") {
            u[g].checked = window.dhx4.s2b(u[g].checked);
            u[g].imgen = u[g].imgdis = "rdbt_" + (u[g].checked ? "1" : "0");
            if (typeof(u[g].group) == "undefined" || u[g].group == null) {
                u[g].group = this._genStr(24)
            }
            if (this.radio[u[g].group] == null) {
                this.radio[u[g].group] = []
            }
            this.radio[u[g].group].push(u[g].id)
        }
        this.itemPull[u[g].id] = u[g];
        if (u[g].items != null && u[g].items.length > 0) {
            this.itemPull[u[g].id].complex = true;
            this._initObj(u[g].items, true, u[g].id)
        } else {
            if (this.conf.dload && u[g].complex == true) {
                this.itemPull[u[g].id].loaded = "no"
            }
        }
        this.itemPull[u[g].id].items = null
    }
    if (v !== true) {
        if (this.conf.dload == true) {
            if (n == null) {
                this._initTopLevelMenu()
            } else {
                this._addSubMenuPolygon(n, n);
                if (this.conf.selected == n) {
                    var s = (this.itemPull[n].parent == this.idPrefix + this.topId);
                    var c = (s && !this.conf.context ? this.conf.dir_toplv : this.conf.dir_sublv);
                    var l = false;
                    if (s && this.conf.top_mode && this.conf.mode == "web" && !this.conf.context) {
                        var x = this.idPull[n];
                        if (x._mouseOver == true) {
                            var m = this.conf.top_tmtime - (new Date().getTime() - x._dynLoadTM);
                            if (m > 1) {
                                var r = n;
                                var o = this;
                                x._menuOpenTM = window.setTimeout(function() {
                                    o._showPolygon(r, c);
                                    o = r = null
                                }, m);
                                l = true
                            }
                        }
                    }
                    if (!l) {
                        this._showPolygon(n, c)
                    }
                }
                this.itemPull[n].loaded = "yes";
                if (this.conf.dload_icon == true) {
                    this._updateLoaderIcon(n, false)
                }
            }
        } else {
            this._init()
        }
    }
};
// Menu siblings/childs addition
dhtmlXMenuObject.prototype._addItemIntoGlobalStrorage = function(o, a, g, n, h, c, m) {
    var l = {
        id: o,
        title: get_locale_value(g),
        imgen: (c != null ? c : ""),
        imgdis: (m != null ? m : ""),
        type: n,
        state: (h == true ? "disabled" : "enabled"),
        parent: a,
        complex: false,
        hotkey: "",
        tip: ""
    };
    this.itemPull[l.id] = l
};
// Toolbar button
dhtmlXToolbarObject.prototype._addItemToStorage = function(m, o) {
    if (m.text != null && m.text != '') {
        m.text = get_locale_value(m.text);
    }
    
    if (m.title != null && m.title != '') {
        m.title = get_locale_value(m.title);
    }
    
    var n = (m.id || this._genStr(24));
    var h = (m.type || "");
    if (h == "spacer") {
        this.addSpacer(this._lastId)
    } else {
        this._lastId = n
    } if (h != "" && this["_" + h + "Object"] != null) {
        if (h == "buttonSelect") {
            if (m.options != null) {
                for (var l = 0; l < m.options.length; l++) {
                    if (m.options[l].type == "obj") {
                        m.options[l].type = "button"
                    }
                    if (m.options[l].type == "sep") {
                        m.options[l].type = "separator"
                    }
                }
            }
        }
        if (h == "slider") {
            var g = {
                tip_template: "toolTip",
                value_min: "valueMin",
                value_max: "valueMax",
                value_now: "valueNow",
                text_min: "textMin",
                text_max: "textMax"
            };
            for (var c in g) {
                if (m[g[c]] == null && m[c] != null) {
                    m[g[c]] = m[c]
                }
            }
        }
        if (h == "buttonInput") {
            if (m.value == null && m.text != null) {
                m.value = m.text
            }
        }
        if (h == "buttonTwoState") {
            if (typeof(m.selected) == "undefined" && typeof(m.pressed) != "undefined" && window.dhx4.s2b(m.pressed)) {
                m.selected = true
            }
        }
        if (typeof(m.enabled) == "undefined" && typeof(m.disabled) != "undefined" && window.dhx4.s2b(m.disabled)) {
            m.enabled = false
        }
        if (m.imgDis == null && m.img_disabled != null) {
            m.imgdis = m.img_disabled
        }
        if ((typeof(m.openAll) == "undefined" || m.openAll == null) && this.conf.skin == "dhx_terrace") {
            m.openAll = true
        }
        this.objPull[this.idPrefix + n] = new this["_" + h + "Object"](this, n, m);
        this.objPull[this.idPrefix + n]["type"] = h;
        this.setPosition(n, o)
    }
    if (m.userdata != null) {
        for (var c in m.userdata) {
            this.setUserData(n, c, m.userdata[c])
        }
    }
    if (m.options != null) {
        for (var l = 0; l < m.options.length; l++) {
            if (m.options[l].userdata != null) {
                for (var c in m.options[l].userdata) {
                    this.setListOptionUserData(m.id, m.options[l].id, c, m.options[l].userdata[c])
                }
            }
        }
    }
};
// Form fields note
dhtmlXForm.prototype.setNote = function(l, g, a) {
    if (typeof(a) == "undefined") {
        a = g
    } else {
        l = [l, g]
    }
    var c = this._getItemNode(l);
    if (!c) {
        return
    }
    var h = this._getNoteNode(c);
    if (!h) {
        if (!a.width) {
            a.width = c.childNodes[c._ll ? 1 : 0].childNodes[0].offsetWidth
        }
        h = document.createElement("DIV");
        h.className = "dhxform_note";
        if ({
            ch: 1,
            ra: 1
        }[c._type]) {
            c.childNodes[c._ll ? 1 : 0].insertBefore(h, c.childNodes[c._ll ? 1 : 0].lastChild)
        } else {
            c.childNodes[c._ll ? 1 : 0].appendChild(h)
        }
    }
    h.innerHTML = get_locale_value(a.text);
    if (a.width != null) {
        h.style.width = a.width + "px";
        h._w = a.width
    }
    h = null
};
// Window Title
dhtmlXWindowsCell.prototype.setText = function(title) {
    var locale_title = get_locale_value(title);
    this.wins.w[this._idd].conf.text = locale_title;
    this.wins.w[this._idd].hdr.childNodes[1].firstChild.innerHTML = locale_title;
};
// *** dhtmlX functions override to support i18n ends *** //

/**
 * [numeric custom input field with the number format, decimal and group separator applied]
 * @type {Object}
 */
dhtmlXForm.prototype.items.numeric = {
    render: function(m, n) {
        var l = (!isNaN(n.rows));
        m._type = "ta";
        m._enabled = true;
        this.doAddLabel(m, n);
        this.doAddInput(m, n, (l ? "TEXTAREA" : "INPUT"), (l ? null : "TEXT"), true, true, "dhxform_textarea");
        this.doAttachEvents(m);
        if (l) {
            m.childNodes[m._ll ? 1 : 0].childNodes[0].rows = Number(n.rows) + (window.dhx4.isIE6 ? 1 : 0)
        }
        if (typeof(n.numberFormat) != "undefined") {
            var h, g = null,
                o = null;
            if (typeof(n.numberFormat) != "string") {
                h = n.numberFormat[0];
                g = n.numberFormat[1] || null;
                o = n.numberFormat[2] || null
            } else {
                h = n.numberFormat;
                if (typeof(n.groupSep) == "string") {
                    g = n.groupSep
                }
                if (typeof(n.decSep) == "string") {
                    o = n.decSep
                }
            }
            this.setNumberFormat(m, h, g, o, false)
        } else {
            this.setNumberFormat(m, __global_number_format__, global_group_separator, global_decimal_separator, false)
        }
        this.setValue(m, n.value);
        return this
    },
    doAttachEvents: function(c) {
        var a = this;
        if (c._type == "ta" || c._type == "se" || c._type == "pw") {
            c.childNodes[c._ll ? 1 : 0].childNodes[0].onfocus = function() {
                var g = this.parentNode.parentNode;
                if (g._df != null) {
                    this.value = g._value.toString().replace(".", global_decimal_separator) || ""
                }
                g.getForm()._ccActivate(g._idd, this, this.value);
                g.getForm().callEvent("onFocus", [g._idd]);
                g = null
            }
        }
        c.childNodes[c._ll ? 1 : 0].childNodes[0].onblur = function() {
            var g = this.parentNode.parentNode;
            g.getForm()._ccDeactivate(g._idd);
            a.updateValue(g, true);
            if (g.getForm().live_validate) {
                a._validate(g)
            }
            g.getForm().callEvent("onBlur", [g._idd]);
            g = null
        }
    },
    updateValue: function(l, a) {
        var m = l.childNodes[l._ll ? 1 : 0].childNodes[0].value;
        m = m.toString().replace(global_decimal_separator, ".")
        var h = l.getForm();
        var c = (h._ccActive == true && h._formLS != null && h._formLS[l._idd] != null);
        h = null;
        if (!c && l._df != null && m == window.dhx4.template._getFmtValue(l._value, l._df)) {
            return
        }
        if (!a && l._df != null && l._value == m && m == window.dhx4.template._getFmtValue(m, l._df)) {
            return
        }
        var g = this;
        if (l._value != m) {
            if (l.checkEvent("onBeforeChange")) {
                if (l.callEvent("onBeforeChange", [l._idd, l._value, m]) !== true) {
                    if (l._df != null) {
                        g.setValue(l, l._value)
                    } else {
                        l.childNodes[l._ll ? 1 : 0].childNodes[0].value = l._value
                    }
                    return
                }
            }
            if (l._df != null && a) {
                g.setValue(l, m)
            } else {
                l._value = m
            }
            l.callEvent("onChange", [l._idd, m]);
            return
        }
        if (l._df != null && a) {
            this.setValue(l, l._value)
        }
    },
    _getItemNode: function (a) {
        return a
    }
};

(function() {
    for (var a in {
        doAddLabel: 1,
        doAddInput: 1,
        destruct: 1,
        doUnloadNestedLists: 1,
        setText: 1,
        getText: 1,
        getValue: 1,
        setValue: 1,
        enable: 1,
        disable: 1,
        setWidth: 1,
        setReadonly: 1,
        isReadonly: 1,
        setFocus: 1,
        getInput: 1,
        setNumberFormat: 1
    })
    dhtmlXForm.prototype.items.numeric[a] = dhtmlXForm.prototype.items.input[a];
})();
/**
 * Enable rounding in grid column_level
 * @param {rounding_values} Rounding values for grid
 */
dhtmlXGridObject.prototype.enableRounding = function (rounding_values) {
    if (rounding_values && rounding_values != '') {
        var array_rounding = rounding_values.split(',');
        var number_format_array = __global_number_format__.split('.');
        var numeric_part = number_format_array[0];
        var default_rounding = number_format_array[1].length;
        var array_rounding_format = [];
        for (var i = 0; i < array_rounding.length; i++) {
            var col_type = this.getColType(i);
            var column_rounding = '';
            if (array_rounding[i] && array_rounding[i] != '') {
                column_rounding = Number(array_rounding[i]);
            }
            if (col_type == 'ro_no' || col_type == 'ed_no' || col_type == 'ron' || col_type == 'edn' || col_type == 'ro_p' || col_type == 'ed_p'
                || col_type == 'ro_v' || col_type == 'ed_v' || col_type == 'ro_a' || col_type == 'ed_a') {
                switch (col_type) {
                    case 'ro_p':
                    case 'ed_p':
                        default_rounding = Number(global_price_rounding);
                        break;
                    case 'ro_v':
                    case 'ed_v':
                        default_rounding = Number(global_volume_rounding);
                        break;
                    case 'ro_a':
                    case 'ed_a':
                        default_rounding = Number(global_amount_rounding);
                        break;
                    default:
                        default_rounding = Number(global_number_rounding);
                }

                column_rounding = ((column_rounding || column_rounding === 0)? column_rounding: default_rounding) + 1;
                var decimal_part = Array(column_rounding).join('0');
                if (!decimal_part || decimal_part == '' || column_rounding == 1) {
                    array_rounding_format.push(numeric_part);
                } else {
                    array_rounding_format.push(numeric_part + '.' + decimal_part);
                }

            } else {
                array_rounding_format.push('');
            }
        }
        this._cell_number_format = array_rounding_format;
    }
}

// Changed the ajax method to post to request dropdown load connector with POST method
// To fix URL length issue in dependent dropdown if parent values selected is maximum in the case of checkbox dropdown
dhx4.ajax.method = 'post';