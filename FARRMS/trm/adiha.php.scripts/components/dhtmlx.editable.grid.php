<?php /*
 * Created - 2014-04-17
 * rajiv@pioneersolutionsglobal.com
 * V 1.0
 * [adiha_dhtmlx_grid Create a DHTMLX grid Instance]
 * @param  string  $grid_name          [Grid Name - should not contain spaces, recommended to use underscore seperated meaningful name]
 * @param  URL     $grid_sp            [Grid SP - PHP function of stored procedure with required parameters.]
 * @param  string  $width              [Grid Body Width - If not provided, calculated automatically.]
 * @param  string  $height             [Grid Body Height - 400px by default]
 * @param  string  $column_type_list   [Column Type -
 *                                     Options -> ro - read only,
 *                                     			  ed - single line editor
 *                                     			  txt - multi-line editor
 *                                     			  ch - Checkbox . Treats “1” as checked, “0” as not checked.
 *                                     			  ra - Radio button (column oriented)
 *                                     			  ra_str - row oriented radio button
 *                                     			  co - Combo box
 *                                     			  coco - Select box
 *                                      - Needs to pass comma seperated list for each columns. If not provied ro is set as default for all columns.
 *                                      ]
 * @param  string  $column_width_list  [Column Widths - Needs to pass comma seperated list for each columns. If not provied 120px is set as default for all columns.]
 * @param  boolean $enable_multiselect [Enable Multi selection in grid - false by default]
 * @param  string  $row_add_button     [Option to include Insert button - will add the insert button with required on click function. Adds row to grid.]
 * @param  string  $row_delete_button  [Option to include Delete button - will add the delete button with required on click function. Delete selected row from grid.]
 * @param  boolean $enable_paging      [Option to enable paging- false by default]
 * @param  integer $paging_size        [Page Size. 25 by default.]
 * @param  string  $hidden_col_index   [Hidde Columns Index. Comma seperated list of hidden indexes. 0 based index.]
 * @param  string  $filter_list        [Add filter to the grid. Comma seperated value.
 *                                     Options -
 *                                     #text_filter - input box, which value is used as a filtering mask;
 *                                     #select_filter - select box, which value is used as a filtering mask;
 *                                     #combo_filter- dhtmlxcombo, which value is used as a filtering mask;
 *                                     #text_search - input box; the nearest row that contains inputed text, becomes selected;
 *                                     #numeric_filter - input box, which value is used as a filtering mask; allows to use comparison operators in it, such as:
 *                                     		equal to = N;
 *                                        	greater than > N;
 *                                          lesser than < N;
 *                                          lesser or equal ⇐ N;
 *                                          greater or equal >= N;
 *                                          range of values N1 .. N2
 *                                     - Need to pass comma seperated list for each columns. If not passed default to text_filter]
 * @param  string  $onload_function   	[Function Name - Function is called after the grid is loaded]
 * @param  boolean $enable_math      	[True/False option to enable the mathematical calculation of the grid data - By default false]
 * @param  boolean $enable_multiline_header       [True/False option to enable the multiline header with group header - By default false]
 * @param  string  $non_group_col_index [List of columns which dont need multiline header]
 * @param  string  $grouping_header_list [List of grouping headers]
 * @param  boolean $enable_drag_drop 	[Enable drag and drop on grid]
 * @param  boolean $enable_mercy_drag	[Enable drag and drop on grid without removing the original rows.]
 * @param  boolean $group_by 			[Group By Column Index]
 *                              		Also support multiple param - comma seperated.
 *                                SYNTAX - 'ind,mask'
 *                              		ind - {number} column index to group by
 *										mask - {array} optional, array, each value of which is mapped to the related column. The possible values are:
 *											title - will be used for group-key;
 *											cspan - organize colspan with a sibling cell (the same as in cspan in header);
 *											stat_total - calculates total of values for the group;
 *											stat_max - calculates maximum value in the group;
 *											stat_min - calculates minimum value in the group;
 *											stat_average - calculates average value in the group;
 *											stat_count - calculates count of records in the group.
 * @param  boolean $disable_search_boxes	[Disable Search boxes at the top of table.]
 * Sample Usage -
   <?php
   $static_data = $app_php_script_loc . 'spa_alert_sql.php?flag=s';
   echo adiha_dhtmlx_grid('mygrid_container', $static_data, '900px', '400px', 'ed,ed,ed,ed,ed,ed,ed,ed,ed,ed', '', true, 'Insert', 'Delete', true, 50);
   ?>
 * @return [HTML]                      [Grid]
 */
function adiha_dhtmlx_grid($grid_name, $grid_sp, $width = 'auto', $height = '400px', $column_type_list = '', $column_width_list = '', $enable_multiselect = false, $row_add_button = '', $row_delete_button = '', $enable_paging = false, $paging_size = 25, $hidden_col_index = '', $filter_list = '', $onload_function = '', $enable_math = false, $enable_multiline_header = false, $non_group_col_index = '', $grouping_header_list = '', $enable_drag_drop = false, $enable_mercy_drag = false, $group_by = '', $disable_search_boxes = false, $sorting_preference = '') {
	global $app_php_script_loc, $app_adiha_loc ;

	$grid_array = array();

	if ($grid_sp != '') {
		$grid_array = readXMLURL2($grid_sp);
		$total_count = sizeof($grid_array);

		$json_data = '';
        $json_data = '{"total_count":"' . $total_count . '", "pos":"0", "data":[';
        $string_array = array();
        if (is_array($grid_array) && sizeof($grid_array) > 0) {
            foreach ($grid_array as $js_array) {
                $string = '{ ';
                $i = 0;
                foreach ($js_array as $key => $value) {
                	if ($i == 0) {
                		$string .= '"' . $key . '":' . '"' . $value . '"';

                	} else {
	                    $string .= ',"' . $key . '":' . '"' . $value . '"';
	                }
	                $i++;
                }
                $string .= '}';
                array_push($string_array, $string);
            }
        }
        $json_data .= implode(", \n",$string_array) . ']}';
	    $linked_datasource_jsoned = $json_data;
	} else {
		$linked_datasource_jsoned = '{ rows:[]}';
	}

	//$linked_datasource_jsoned = json_encode($grid_array);

	$headers = join(',', array_keys($grid_array[0]));

	if ($width == 'auto' && $column_width_list != '') {
		$total_width_list = $column_width_list;
		$hidden_width = 0;

		if ($hidden_col_index != '') {
			$hidden_width_array = explode(",", $hidden_col_index);
			$count = count($hidden_width_array);
			$hidden_width = 120 * $count;
		}

		if ($total_width_list != '') {
			$total_width_array = explode(",", $total_width_list);
			$count_all = count($total_width_array);
			$width = 120 * $count_all;
		}
		$width = $width - $hidden_width;
	}

	$html_str = '<script type="text/javascript" src="'. $app_php_script_loc .'components/dhtmlxSuite/codebase/dhtmlxgrid_pro.js"></script>';
    $html_str = '<link rel="stylesheet" type="text/css" href="'. $app_php_script_loc .'components/dhtmlxSuite/codebase/adiha_dhtmlx.css"">';

	//$html_str .=  '<div id="my_menu_here" style="width: 500px;"> </div>';
	$html_str .= '<div id="'. $grid_name . '" style="width:' . $width . ';height:'. $height .';scroll:auto;font-weight:normal;"></div>';

	if ($enable_paging) {
		$html_str .= '<div id="paging_area'. $grid_name . '" style="float:right;"></div>';
		$html_str .= '<div id="paging_state'. $grid_name . '" style="height:20px; padding:5px;"></div>';
	}


	$btn_array = array();
	$function_array = array();
	$tips_array = array();

	if ($row_add_button != '') {
		array_push($btn_array, 'add');
		array_push($function_array, 'btn_insert_' . $row_add_button . '_' . $grid_name . '_click');
		array_push($tips_array, 'Add new column');
		//$html_str .= '<button onclick="add_row_' .$grid_name . '()">' . $row_add_button . '</button>';
	}

	if ($row_delete_button != '') {
		array_push($btn_array, 'delete');
		array_push($function_array, 'btn_delete_' . $row_delete_button . '_' . $grid_name . '_click');
		array_push($tips_array, 'Delete selected column');
		//$html_str .= '<button onclick="remove_row_' .$grid_name . '()">' . $row_delete_button . '</button>';
	}

	//if ($row_add_button != '' || $row_delete_button != '') {
//		$html_str .= '<div id="add_btn_paramset" style="width: 25px;">' . adiha_custom_export($btn_array, $function_array, $tips_array) . '</div>';
//	}

	$html_str .= '<style>';
	$html_str .= '   	.dhx_header_cmenu{';
	$html_str .= '			background-color:#ffffff;';
	$html_str .= '			border:2px outset silver;';
	$html_str .= '			z-index:2;';
	$html_str .= '			max-height:250px;';
	$html_str .= '			overflow-y:auto;';
	$html_str .= '		}';
	$html_str .= '	.dhx_header_cmenu_item{';
	$html_str .= '		white-space:nowrap;';
	$html_str .= '	}		';
	$html_str .= '</style>';

	$html_str .= '<script type="text/javascript">';

	//load grid on page load
	$html_str .= '	$(function(){';
	$html_str .= '	 	create_grid_'. $grid_name . '();';
	$html_str .= '	});';

	// creates a grid instance
	$html_str .= '	 function create_grid_'. $grid_name . '() {';
	$html_str .= '		var jsoned_data = '. $linked_datasource_jsoned .';';
	$html_str .= '		var headers = get_headers_dhtmlx("'. $headers . '");';

	if ($filter_list == '') {
		$html_str .= '	    var filter_list = get_filter_list("'. $headers . '");';
	} else {
		$html_str .= '	    var filter_list = "'. $filter_list .'";';
	}

	$html_str .= '      var non_group_col = "'. $non_group_col_index .'";';
	$html_str .= '      var grouping_header = "'. $grouping_header_list .'";';

	if ($enable_multiline_header) {
	    $html_str .= '	var multiline_header = get_multiline_header(headers, non_group_col, grouping_header);';
	    $html_str .= '	var multiline_attach_header = get_multiline_attach_header(headers, non_group_col, grouping_header);';
	}

	if ($sorting_preference == '') {
		$html_str .= '		var sorting_pref = get_sorting_preference("'. $headers . '");';
	} else {
		$html_str .= '      var sorting_pref = "'. $sorting_preference .'";';
	}

	if ($column_type_list != "") {
		$html_str .= '	var column_type = "'. $column_type_list .'";';
	} else {
	    if ($enable_math) {
	        $html_str .= '	var column_type = get_column_type("'. $headers . '",' . $enable_math . ');';
	    } else {
	        $html_str .= '	var column_type = get_column_type("'. $headers . '");';
	    }
	}

	if ($column_width_list != "") {
		$html_str .= '		var column_width = "'. $column_width_list .'";';
	} else {
		$html_str .= '		var column_width = get_widths("'. $headers . '");';
	}

	$html_str .= '		grid_'. $grid_name . ' = new dhtmlXGridObject("'. $grid_name .'");';
	$html_str .= '		grid_'. $grid_name . '.setImagePath("' . $app_php_script_loc . 'components/dhtmlxSuite/codebase/imgs/");';
	$html_str .= '		grid_'. $grid_name . '.setInitWidths(column_width);';
	$html_str .= '		grid_'. $grid_name . '.setColAlign("left");';
	$html_str .= '		grid_'. $grid_name . '.setSkin("dhx_skyblue");';


	$html_str .= '		if (headers != "") {';
	    if ($enable_multiline_header) {
		   $html_str .= '	grid_'. $grid_name . '.setHeader(multiline_header);';
	    } else {
	       $html_str .= '	grid_'. $grid_name . '.setHeader(headers);';
	    }

	    $html_str .= '		grid_'. $grid_name . '.setColumnIds("' . $headers . '");';
		$html_str .= '		grid_'. $grid_name . '.setColTypes(column_type);';
		$html_str .= '		grid_'. $grid_name . '.setColSorting(sorting_pref);';
	$html_str .= '		}';

	$html_str .= '		grid_'. $grid_name . '.enableColumnAutoSize(true);';

	if ($enable_multiline_header) {
	   $html_str .= '		grid_'. $grid_name . '.attachHeader(multiline_attach_header);';
	}

	if (!$disable_search_boxes) {
			$html_str .= '		grid_'. $grid_name . '.attachHeader(filter_list);';
	}

	$html_str .= '		grid_'. $grid_name . '.enableMathEditing(true);';

	if ($enable_multiselect) {
		$html_str .= '	grid_'. $grid_name . '.enableMultiselect(true);';
	}

	if ($enable_drag_drop) {
		$html_str .= '	grid_'. $grid_name . '.enableDragAndDrop(true);';

		// disable column auto resize for drag drop grid.
		$html_str .= '	grid_'. $grid_name . '.enableColumnAutoSize(false);';
	}

	if ($enable_mercy_drag) {
		$html_str .= '	grid_'. $grid_name . '.enableMercyDrag(true);';
	}

	$html_str .= '		grid_'. $grid_name . '.init();';
	$html_str .= '		grid_'. $grid_name . '.enableHeaderMenu();';

	if ($group_by != '') {
		$html_str .= '		grid_'. $grid_name . '.groupBy('. $group_by . ');';
		//$html_str .= '		grid_'. $grid_name . '.setColumnHidden('. $group_by . ', true);';
	}

	if ($hidden_col_index != '') {
		$html_str .= '		var hidden_list = get_hidden_cols("' . $hidden_col_index . '", "'. $headers . '");';
		$html_str .= '		grid_'. $grid_name . '.setColumnsVisibility(hidden_list);';
	}

	// Group By is incompatible with paging, so paging and smart rendering is disabled when grouping is used.
	if ($enable_paging && $group_by == '') {
		$html_str .= '	grid_'. $grid_name . '.enablePaging(true, '. $paging_size . ', 4, "paging_area'. $grid_name . '", true, "paging_state'. $grid_name . '");';
	} else if ($group_by == '') {
		$html_str .= '	grid_'. $grid_name . '.enableSmartRendering(true);';
	}

	$html_str .= '		try {';
	$html_str .= '			grid_'. $grid_name . '.parse(jsoned_data, "js");';
	$html_str .= '			setTimeout("colorize_' .$grid_name . '()", 700);';
	$html_str .= '			attach_events_' .$grid_name . '();';
	$html_str .= '		} catch (exception) {';
	$html_str .= '			alert("parse json exception.");';
	$html_str .= '		}';

	if ($onload_function != "") {
		$html_str .= '          '. $onload_function . '();';
	}

	$html_str .= '	}';

	// adds a new row to the grid
	$html_str .= '	function btn_insert_' . $row_add_button . '_' . $grid_name . '_click() {';
	$html_str .= '		var new_id = (new Date()).valueOf();';
	$html_str .= '		grid_'. $grid_name . '.addRow(new_id, "", grid_'. $grid_name . '.getRowsNum());';
	$html_str .= '		grid_'. $grid_name . '.selectRow(grid_'. $grid_name . '.getRowIndex(new_id), false, false, true);';
	$html_str .= '	}';

	//remove the selected row from the grid
	$html_str .= '	function btn_delete_' . $row_delete_button . '_' . $grid_name . '_click() {';
	$html_str .= '		var select_id = grid_'. $grid_name . '.getSelectedId();';
	$html_str .= '		if (select_id == null) {';
	$html_str .= '			show_messagebox("Please select item to delete.");';
	$html_str .= '		} else {';
	$html_str .= '			grid_'. $grid_name . '.deleteSelectedRows();';
	$html_str .= '		}';
	$html_str .= '	}';

	// get data from dhtmlx grid in FARRMS standard XML format
	$html_str .= '	function get_' .$grid_name . '_data() { ';
	$html_str .= '		var ps_xml = "<Root>";';
	$html_str .= '		for (var row_index=0; row_index < grid_'. $grid_name . '.getRowsNum(); row_index++) {';
	$html_str .= '			ps_xml = ps_xml + "<PSRecordset ";';
	$html_str .= '			for(var cellIndex = 0; cellIndex < grid_'. $grid_name . '.getColumnsNum(); cellIndex++){';
	$html_str .= '				ps_xml = ps_xml + " " + grid_'. $grid_name .'.getColumnId(cellIndex) + \'="\' + grid_'. $grid_name . '.cells2(row_index,cellIndex).getValue() + \'"\';';
	$html_str .= '			}';
	$html_str .= '			ps_xml = ps_xml + " ></PSRecordset> ";';
	$html_str .= '		}';
	$html_str .= '		ps_xml = ps_xml + "</Root>";';
	$html_str .= '		return ps_xml;';
	$html_str .= '	}';

	// get data from dhtmlx grid in FARRMS standard XML format
	$html_str .= 'function colorize_' . $grid_name . '() {';
	$html_str .= '	grid_'. $grid_name . '.forEachRow(function(id) {';
	$html_str .= '		for(var cell_index = 0; cell_index < grid_'. $grid_name . '.getColumnsNum(); cell_index++){';
	$html_str .= '			var grid_value = grid_'. $grid_name . '.cells(id,cell_index).getValue();';
	$html_str .= '			if(grid_value == "") {';
	$html_str .= '				grid_'. $grid_name . '.setCellTextStyle(id, cell_index, "background-color:#FFFFC2;");';
	$html_str .= '			} else if(grid_value == "-") {';
	$html_str .= '				grid_'. $grid_name . '.setCellTextStyle(id, cell_index, "background-color:#F05672;");';
	$html_str .= '			}';
	$html_str .= '		}';
	$html_str .= '	});';
	$html_str .= '}';

	$html_str .= 'function attach_events_' .$grid_name . '() {';
	$html_str .= '	grid_'. $grid_name . '.attachEvent("onEditCell", function(stage,row_id,col_id,new_value,old_value){';
	$html_str .= '		if (new_value != old_value){';
	$html_str .= '			grid_'. $grid_name . '.setCellTextStyle(row_id, col_id, "background-color:#C3F5BA;");';
	//$html_str .= '		if (new_value == "&nbsp;" || new_value == ""){';
	//$html_str .= '			grid_'. $grid_name . '.setCellTextStyle(row_id, col_id, "background-color:#FFFFC2;");';
	//$html_str .= '		} else {';
	//$html_str .= '			grid_'. $grid_name . '.setCellTextStyle(row_id, col_id, "background-color:#DCF2D8;");';
	//$html_str .= '		}';
	$html_str .= '		}';
	$html_str .= '		return true;';
	$html_str .= '	});';
	$html_str .= '}';

	//get value of choosen cell of selected rows
	$html_str .= '	function get_' .$grid_name . '_cell_value(cell_id) {';
	$html_str .= '		var selected_row = get_' .$grid_name . '_selected_row();';
	$html_str .= '		var cell_value = "";';
	$html_str .= '		if (selected_row == null) {';
	$html_str .= '			adiha_CreateMessageBox("alert", "Please select a row from a grid.", "", "");';
	$html_str .= '		} else if (selected_row.indexOf(",") != -1) {';
	$html_str .= '			var selected_row_array = new Array();';
	$html_str .= '			var cell_value_array = new Array();';
	$html_str .= '			selected_row_array = selected_row.split(",");';
	$html_str .= '			$.each(selected_row_array, function(index, value){';
	$html_str .= '				cell_value_array.push(grid_'. $grid_name . '.cells(value, cell_id).getValue());';
	$html_str .= '			});';
	$html_str .= '			cell_value = cell_value_array.join(",");';
	$html_str .= '		} else {';
	$html_str .= '			cell_value = grid_'. $grid_name . '.cells(selected_row, cell_id).getValue();';
	$html_str .= '		}';
	$html_str .= '		return cell_value;';
	$html_str .= '	}';

	//get selected rows.
	$html_str .= '	function get_' .$grid_name . '_selected_row() {';
	$html_str .= '		var selected_row = grid_'. $grid_name . '.getSelectedRowId();';
	$html_str .= '		return selected_row;';
	$html_str .= '	}';

	$html_str .= '	var	destroy_grid_' .$grid_name . ' = false;';
	$html_str .= '	var	hidden_columns_' .$grid_name . ' = "";';
	$html_str .= '	var	math_enable_' .$grid_name . ' = false;';
	$html_str .= '  var enable_multiline_header_' .$grid_name . ' = false;';
	$html_str .= '  var grouping_header_' .$grid_name . ' = "";';
	$html_str .= '  var col_length_' .$grid_name . ' = "";';
	$html_str .= '  var non_group_col_' .$grid_name . ' = "";';

	/**
	 * Grid Refresh function
	 * @sp_url - sp url to refresh grid
	 * @destroy - if true rebuild the header
	 * @hidden_columns_index - Hide the columns listed
	 * @Column_length - List of the column length
	 * @math_enable_glag - If true, calculate the value as defined in the formula is enabled
	 * @multiline_header_flag - If true, group header and sub header is enablesd
	 * @non_group_col_index - List of columns which dont need multiline header
	 * @grouping_header_list - List of grouping headers
	 */

	$html_str .= '	function grid_' .$grid_name . '_refresh(sp_url, destroy, hidden_columns_index, col_length_list, math_enable_flag, multiline_header_flag, non_group_col_index, grouping_header_list) {';
	$html_str .= '		destroy_grid = destroy;';

	$html_str .= '		if (hidden_columns_index) {';
	$html_str .= '			hidden_columns_' .$grid_name . ' = hidden_columns_index;';
	$html_str .= '		};';

	$html_str .= '		if (math_enable_flag) {';
	$html_str .= '			math_enable_' .$grid_name . ' = math_enable_flag;';
	$html_str .= '		};';

	$html_str .= '		if (multiline_header_flag) {';
	$html_str .= '			enable_multiline_header_' .$grid_name . ' = multiline_header_flag;';
	$html_str .= '		};';

	$html_str .= '		if (non_group_col_index) {';
	$html_str .= '      	non_group_col_' .$grid_name . ' = non_group_col_index;';
	$html_str .= '		};';

	$html_str .= '		if (col_length_list) {';
	$html_str .= '      	col_length_' .$grid_name . ' = col_length_list;';
	$html_str .= '		};';

	$html_str .= '		var php_path = "' . $app_php_script_loc . '";';
	$html_str .= '		var php_path = "' . $app_php_script_loc . '";';
	$html_str .= '		var url = php_path + "dev/spa_xml.php?spa=" + sp_url + "&include_html=y";';
	$html_str .= '		var result = "";';
	//$html_str .= '		result = get_ajax_recordset(url, "callback_' .$grid_name . '", "json");';
    $html_str .= '		result = adiha_post_data("return_json", sp_url, "", "", "callback_' .$grid_name . '", "", "");';
	$html_str .= '	}';

	// callback for refresh function
	$html_str .= '	function callback_' .$grid_name . '(result) {';
	$html_str .= '		if (!destroy_grid) {';
	$html_str .= '			grid_'. $grid_name . '.clearAll();';
	$html_str .= '			grid_'. $grid_name . '.parse(result, "js");';
	$html_str .= '		} else if (destroy_grid) {';
	$html_str .= '			var json_object = $.parseJSON(result);';
	$html_str .= '			if (json_object != undefined && json_object != null && json_object.length != 0) {';
	$html_str .= '				var new_headers = Object.keys(json_object[0]);';
	$html_str .= '				new_headers = new_headers.toString();';
	$html_str .= '				var head = get_headers_dhtmlx(new_headers); ';

	$html_str .= '              if (enable_multiline_header_' .$grid_name . ') {';
	$html_str .= '                  var multiline_header = get_multiline_header(head, non_group_col_' .$grid_name . ', grouping_header_' .$grid_name . ');';
	$html_str .= '                  var multiline_attach_header = get_multiline_attach_header(head, non_group_col_' .$grid_name . ', grouping_header_' .$grid_name . ');';
	$html_str .= '              }';

	$html_str .= '				grid_'. $grid_name . '.destructor();';
	$html_str .= '				$("#paging_area'. $grid_name . '").text("");';
	$html_str .= '				$("#paging_state'. $grid_name . '").text("");';

	$html_str .= '				grid_'. $grid_name . ' = new dhtmlXGridObject("'. $grid_name .'");';
	$html_str .= '				grid_'. $grid_name . '.setImagePath("' . $app_php_script_loc . 'components/dhtmlxSuite/codebase/imgs/");';

	if ($column_width_list != '') {
		$html_str .= '			var col_widths = "'. $column_width_list .'";';
	} else {
		$html_str .= '			var col_widths = get_widths(head);';
	}

	$html_str .= '          	if (col_length_' .$grid_name . ' != "") {';
	$html_str .= '					var col_widths = col_length_' . $grid_name . ';';
	$html_str .= '          	}';

	if ($sorting_preference == '') {
		$html_str .= '			var sorting_pref = get_sorting_preference(head);';
	} else {
		$html_str .= '      	var sorting_pref = "'. $sorting_preference .'";';
	}

	if ($column_type_list != "") {
		$html_str .= '	var col_types = "'. $column_type_list .'";';
	} else {
	    if ($enable_math) {
	        $html_str .= '	var col_types = get_column_type(head, math_enable_' .$grid_name . ');';
	    } else {
	        $html_str .= '	var col_types = get_column_type(head);';
	    }
	}

	if ($filter_list == '') {
		$html_str .= '			var filter_list = get_filter_list(head);';
	} else {
		$html_str .= '	    	var filter_list = "'. $filter_list .'";';
	}

	$html_str .= '				grid_'. $grid_name . '.setInitWidths(col_widths);';
	$html_str .= '				grid_'. $grid_name . '.setColAlign("left");';
	$html_str .= '				grid_'. $grid_name . '.setSkin("dhx_skyblue");';

	$html_str .= '              if (enable_multiline_header_' .$grid_name . ') {';
	$html_str .= '				     grid_'. $grid_name . '.attachHeader(multiline_attach_header);';
	$html_str .= '				     grid_'. $grid_name . '.setHeader(multiline_header);';
	$html_str .= '              } else {';
	$html_str .= '				     grid_'. $grid_name . '.setHeader(head);';
	$html_str .= '              }';

	if (!$disable_search_boxes) {
			$html_str .= '				grid_'. $grid_name . '.attachHeader(filter_list);';
	}

	$html_str .= '				grid_'. $grid_name . '.setColumnIds(new_headers);';
	$html_str .= '				grid_'. $grid_name . '.setColTypes(col_types);';
	//$html_str .= '				grid_'. $grid_name . '.setColSorting(sorting_pref);';

	$html_str .= '				grid_'. $grid_name . '.enableColumnAutoSize(true);';
	$html_str .= '		        grid_'. $grid_name . '.enableMathEditing(true);';
    $html_str .= '		        grid_'. $grid_name . '.setMathRound(2);';

	if ($enable_multiselect) {
		$html_str .= '			grid_'. $grid_name . '.enableMultiselect(true);';
	}

	if ($enable_drag_drop) {
		$html_str .= '			grid_'. $grid_name . '.enableDragAndDrop(true);';
	}

	if ($enable_mercy_drag) {
		$html_str .= '			grid_'. $grid_name . '.enableMercyDrag(true);';
	}

	$html_str .= '				grid_'. $grid_name . '.init();';
	$html_str .= '				grid_'. $grid_name . '.enableHeaderMenu();';

	if ($group_by != '') {
		$html_str .= '		grid_'. $grid_name . '.groupBy('. $group_by . ');';
	}

	$html_str .= '				if (hidden_columns_' .$grid_name . ' != "") {';
	$html_str .= '					var hidden_index = get_hidden_cols(hidden_columns_' .$grid_name . ', head);';
	$html_str .= '					grid_'. $grid_name . '.setColumnsVisibility(hidden_index);';
	$html_str .= '				}';

	// Group By is incompatible with paging, so paging and smart rendering is disabled when grouping is used.
	if ($enable_paging && $group_by == '') {
		$html_str .= '			grid_'. $grid_name . '.enablePaging(true, '. $paging_size . ', 4, "paging_area'. $grid_name . '", true, "paging_state'. $grid_name . '");';
	} else if ($group_by == '') {
		//$html_str .= '			grid_'. $grid_name . '.enableSmartRendering(true);';
	}

	$html_str .= '				try {';
	$html_str .= '					grid_'. $grid_name . '.parse(result, "js");';
	$html_str .= '					setTimeout("colorize_' .$grid_name . '()", 700);';
	$html_str .= '					attach_events_' .$grid_name . '();';
	$html_str .= '				} catch (exception) {';
	$html_str .= '					alert("parse json exception.");';
	$html_str .= '				}';
	$html_str .= '			} else {';
	$html_str .= '				grid_'. $grid_name . '.clearAll();';
	$html_str .= '			}';
	$html_str .= '		}';

	if ($onload_function != "") {
		$html_str .= '          '. $onload_function . '();';
	}

	$html_str .= '	}';

	/**
	 * Function to calculate the subtotal
	 * @row_list - List of row to be calculated for subtotal
	 * @col_list - List of columns to be calculated for subtotal
	 * @row_no - Row in which the subtotal is to be displayed
	 */
	$html_str .= '  function grid_' . $grid_name . '_subtotal(row_list, col_list, row_no) {';
	$html_str .= '      var subtotal_formula = new Array();';
	$html_str .= '      for(var i = 0; i < col_list.length; i++) {';
	$html_str .= '        if (row_list.length > 0) {';
    $html_str .= '             subtotal_formula[i] = "=";';
    $html_str .= '        }';
    $html_str .= '        for (var j = 0 ; j < row_list.length; j++) {';
    $html_str .= '             var value =  grid_' . $grid_name . '.cells(row_list[j],col_list[i]).getValue();';
    $html_str .= '             if (value != "" && value != "-") {';
    $html_str .= '                  subtotal_formula[i] += "[[" + row_list[j] + "," + col_list[i] + "]]";';
    $html_str .= '                  if(j+1 != row_list.length) {';
    $html_str .= '                      subtotal_formula[i] += "+";';
    $html_str .= '                  }';
    $html_str .= '             }';
    $html_str .= '        }';
    $html_str .= '        grid_' . $grid_name . '.cells(row_no,col_list[i]).setValue(subtotal_formula[i]);';
    $html_str .= '    }';
    $html_str .= '  }';

	$html_str .= '</script>';

	return $html_str;
}

?>
<script type="text/javascript">
	function mb_convert_case(str) {
		str = str.replace(/_/g, ' ');
	    str = str.toLowerCase().replace(/\b[a-z](?=[a-z])/g, function(letter) {
	    return letter.toUpperCase(); } );

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

	    jQuery.each(delimiters, function( i, val_deli) {
			words = string.split(val_deli);
			new_word = new Array();

			jQuery.each(words, function( i, val_word) {
				if (jQuery.inArray(val_word.toUpperCase(), exceptions) !=  -1) {
					val_word = val_word.toUpperCase();
				} else if (jQuery.inArray(val_word.toLowerCase(), exceptions)  !=  -1) {
					val_word = val_word.toLowerCase();
				} else if (jQuery.inArray(val_word, exceptions)  ==  -1) {
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
            if ($.inArray(i.toString(),spilited_non_group_col) == -1) {

                for (j = 0; j < spilited_group_header.length; j++) {
                    if(spilited_header[i].search(spilited_group_header[j]) > -1)
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
            if ($.inArray(i.toString(),spilited_non_group_col) == -1) {

                for (j = 0; j < spilited_group_header.length; j++) {
                    if(spilited_header[i].search(spilited_group_header[j]) > -1)
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
	  Object.keys = (function () {
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

	    return function (obj) {
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

		jQuery.each(hidden_array, function( i, val ) {
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
</script>