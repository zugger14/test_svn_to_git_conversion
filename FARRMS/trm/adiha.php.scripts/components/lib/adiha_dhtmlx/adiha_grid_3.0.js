function mb_convert_case(str) {
    str = str.replace(/_/g, ' ');
    str = str.toLowerCase().replace(/\b[a-z](?=[a-z])/g, function(letter) {
        return letter.toUpperCase();
    });

    return str;
}

/**
 * [get_headers_dhtmlx Get Header for grid]
 * @param  [type] $string     []
 * @param  array  $delimiters [description]
 * @param  array  $exceptions [description]
 * @return [type]             [description]
 */
function get_headers_dhtmlx(string) {
    var delimiters = new Array(" ", "-", ".", "'", "O'", "Mc", ",");
    var exceptions = new Array("and", "to", "of", "das", "dos", "I", "II", "III", "IV", "V", "VI");

    string = mb_convert_case(string);

    jQuery.each(delimiters, function(i, val_deli) {
        words = string.split(val_deli);
        new_word = new Array();

        jQuery.each(words, function(i, val_word) {
            if (jQuery.inArray(val_word.toUpperCase(), exceptions) != -1) {
                val_word = val_word.toUpperCase();
            } else if (jQuery.inArray(val_word.toLowerCase(), exceptions) != -1) {
                val_word = val_word.toLowerCase();
            } else if (jQuery.inArray(val_word, exceptions) == -1) {
                val_word = mb_convert_case(val_word);
            }

            new_word.push(val_word);
        });
        string = new_word.join(val_deli);
    });
    return string;
}

/**
 * [get_multiline_header Get column name for the group header]
 * @string          [type]     headers [description]
 * @non_group_col   [type]     List of column having no multiline header [description]
 * @grouping_header [type]     List of the group headings
 * @return          [type]
 */
function get_multiline_header(string, non_group_col, grouping_header) {
    var spilited_header = new Array();
    spilited_header = string.split(',');
    var spilited_group_header = new Array();
    spilited_group_header = grouping_header.split(',');
    var spilited_non_group_col = new Array();
    spilited_non_group_col = non_group_col.split(',');

    var header = new Array();
    var prev_col = '';
    var now_col;

    for (i = 0; i < spilited_header.length; i++) {
        if ($.inArray(i.toString(), spilited_non_group_col) == -1) {

            for (j = 0; j < spilited_group_header.length; j++) {
                if (spilited_header[i].search(spilited_group_header[j]) > -1)
                    now_col = spilited_group_header[j];
            }

            if (prev_col == now_col) {
                header.push('#cspan');
            } else {
                header.push($.trim(now_col));
            }
            prev_col = now_col;
        }
        else {
            header.push($.trim(spilited_header[i]));
        }
    }
    return header;
}

/**
 * [get_multiline_attach_header Get column name for the sub header]
 * @string          [type]     headers [description]
 * @non_group_col   [type]     List of column having no multiline header [description]
 * @grouping_header [type]     List of the group headings
 * @return          [type]
 */
function get_multiline_attach_header(string, non_group_col, grouping_header) {
    var spilited_header = new Array();
    spilited_header = string.split(',');
    var spilited_group_header = new Array();
    spilited_group_header = grouping_header.split(',');
    var spilited_non_group_col = new Array();
    spilited_non_group_col = non_group_col.split(',');

    var attach_header = new Array();
    var attach_header_item = '';

    for (i = 0; i < spilited_header.length; i++) {
        if ($.inArray(i.toString(), spilited_non_group_col) == -1) {

            for (j = 0; j < spilited_group_header.length; j++) {
                if (spilited_header[i].search(spilited_group_header[j]) > -1)
                    attach_header_item = $.trim(spilited_group_header[j]);

            }
            attach_header.push($.trim(spilited_header[i]).substr(attach_header_item.length, $.trim(spilited_header[i]).length));
        }
        else {
            attach_header.push("#rspan");
        }
    }
    return attach_header;
}

if (!Object.keys) {
    Object.keys = (function() {
        'use strict';
        var hasOwnProperty = Object.prototype.hasOwnProperty,
                hasDontEnumBug = !({toString: null}).propertyIsEnumerable('toString'),
                dontEnums = [
                    'toString',
                    'toLocaleString',
                    'valueOf',
                    'hasOwnProperty',
                    'isPrototypeOf',
                    'propertyIsEnumerable',
                    'constructor'
                ],
                dontEnumsLength = dontEnums.length;

        return function(obj) {
            if (typeof obj !== 'object' && (typeof obj !== 'function' || obj === null)) {
                throw new TypeError('Object.keys called on non-object');
            }

            var result = [], prop, i;

            for (prop in obj) {
                if (hasOwnProperty.call(obj, prop)) {
                    result.push(prop);
                }
            }

            if (hasDontEnumBug) {
                for (i = 0; i < dontEnumsLength; i++) {
                    if (hasOwnProperty.call(obj, dontEnums[i])) {
                        result.push(dontEnums[i]);
                    }
                }
            }
            return result.toString();
        };
    }());
}

/**
 * [get_widths Get column width for grid.]
 * @param  [type] headers [description]
 * @return [type]          [description]
 */
function get_widths(headers) {
    string = headers.replace(/[^,]+/g, "120");
    return string;
}

function get_sorting_preference(headers) {
    string = headers.replace(/[^,]+/g, "str");
    return string;
}

/**
 * [get_column_type Get Column type for grid column]
 * @param  [type] headers [description]
 * @return [type]         [description]
 */
function get_column_type(headers, enable_math) {
    string = headers.replace(/[^,]+/g, "ed");

    if (enable_math) {
        main_array = string.split(',');

        jQuery.each(main_array, function(i) {
            main_array[i] = 'ed[=0]';
        });
        string = main_array.join(',');
    }

    return string;
}

/**
 * [get_hidden_cols Resolve hidden columns.]
 * @param  [type] hidden_columns [description]
 * @param  [type] headers          [description]
 * @return [type]                   [description]
 */
function get_hidden_cols(hidden_columns, headers) {
    var hidden_string = headers.replace(/[^,]+/g, "false");
    main_array = hidden_string.split(',');
    hidden_array = hidden_columns.split(',');

    jQuery.each(hidden_array, function(i, val) {
        main_array[val] = 'true';
    });

    hidden_string = main_array.join(',');
    return hidden_string;
}

/**
 * [get_filter_list Resolve filter type.]
 * @param  [type] headers [description]
 * @return [type]          [description]
 */
function get_filter_list(headers) {
    string = headers.replace(/[^,]+/g, "#text_filter");
    return string;
}
/**
 * [Enables/disables the multiselect property in grid.]
 * @param {type} gridName
 * @param {type} isenabled
 * @returns {undefined}
 */
function enableMultiSelectD(gridName, isenabled) {
    try {
        if (isenabled == true) {
            y = "grid_" + gridName + ".enableMultiselect(true);";
        } else {
            y = "grid_" + gridName + ".enableMultiselect(false);";
        }
        x = eval(y);
    } catch (exceptions) {
        return;
    }
}
/**
 * Get value from a cell of selected grid.
 * @param string gridname Name of a grid.
 * @param integer clms Column number.
 * @return  Value from a cell of selected grid.
 */
function getFirstrowDataD(gridname, clms) {

    try {
        y = "grid_" + gridname + ".cells(1," + clms + ").getValue();";
        x = eval(y);

        if (x == "" || x == undefined) {
            x = "NULL";
        }

        return x;
    } catch (exceptions) {
        return "NULL";
    }
}
/**
 * Get number of rows from grid.
 * @param string gridname Name of a grid.
 * @return  Number of rows from grid.
 */
function getGridnumrowsD(gridname) {
    try {
        y = "grid_" + gridname + ".getRowsNum();";
        x = eval(y);

        if (x == "" || x == undefined || x == -1 || x == "NULL") {
            x = 0;
        }

        return x;
    } catch (exceptions) {
        return 0;
    }
}
/**
 * Get row number of selected row from grid.
 * @param string gridname Name of a grid.
 * @return Row number of selected row from grid.
 */
function getSelectedRowNumD(gridname) {
    try {
        var y = "get_" + gridname + "_selected_row();";
        var x = eval(y);
        if (x == "" || x == undefined || x == -1 || x == "NULL") {
            x = 0;
        }
        return x;
    } catch (exceptions) {
        return 0;
    }
}

/**
 * Select and unselect all rows in grid.
 * @param string gridname Name of a grid.
 * @param boolean isenabled Either True or false.
 */
function checkGridDAll(gridname, isChecked) {
    try {
        if (isChecked)
            y = "grid_" + gridname + ".selectAll();";
        else
            y = "grid_" + gridname + ".clearSelection();";
        x = eval(y);
    } catch (exceptions) {
        return;
    }
}

