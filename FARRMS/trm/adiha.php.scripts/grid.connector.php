<?php
	ob_start();
	require_once('components/include.file.v3.php');
	$_REQUEST = array_merge($_GET, $_POST);
    $process_table = (isset($_REQUEST["process_table"])) ? $_REQUEST["process_table"] : '';
    $id_field = (isset($_REQUEST["id_field"])) ? $_REQUEST["id_field"] : '';
    $text_field = (isset($_REQUEST["text_field"])) ? $_REQUEST["text_field"] : '';
    $extra_field = (isset($_REQUEST["extra_field"])) ? $_REQUEST["extra_field"] : '';
    $grouping_column = (isset($_REQUEST["grouping_column"])) ? $_REQUEST["grouping_column"] : '';
    $grid_type = (isset($_REQUEST["grid_type"])) ? $_REQUEST["grid_type"] : 'g';
    $action = (isset($_REQUEST["action"])) ? $_REQUEST["action"] : '';
    $date_fields = (isset($_REQUEST["date_fields"])) ? $_REQUEST["date_fields"] : '';
    $numeric_fields = (isset($_REQUEST["numeric_fields"])) ? $_REQUEST["numeric_fields"] : '';
	$sorting_fields = (isset($_REQUEST["sorting_fields"])) ? $_REQUEST["sorting_fields"] : ''; //expects the list of comma separated list of sorting column in field_name::sorting_direction eg: source_deal_header_id::ASC,deal_id::DESC

    $numeric_field_array = array();
    $date_field_array = array();

    if ($numeric_fields != '')
		$numeric_field_array = explode(',', $numeric_fields);
	if ($date_fields != '')
		$date_field_array = explode(',', $date_fields);

    ob_clean();
    // Prevent usage without process table
    if ($process_table == '') die();

	require("components/lib/adiha_dhtmlx/adiha_connectors_3.0/grid_connector.php");
	require("components/lib/adiha_dhtmlx/adiha_connectors_3.0/db_sqlsrv.php");

	$res = @sqlsrv_connect($db_servername, $connection_info);
	$grid = new GridConnector($res,"SQLSrv");

	function custom_sort($sorted_by){
		global $date_field_array, $numeric_field_array, $sorting_fields;
		if (sizeof($date_field_array) > 0 && in_array($sorted_by->rules[0]['name'], $date_field_array)) {
			$sorted_by->rules[0]['name'] = "CONVERT(DATETIME, " . $sorted_by->rules[0]['name'] . ", 120)";
	  	}	

	  	if (sizeof($numeric_field_array) > 0 && in_array($sorted_by->rules[0]['name'], $numeric_field_array)) {
			$sorted_by->rules[0]['name'] = "CONVERT(NUMERIC(38,20), " . $sorted_by->rules[0]['name'] . ")";
	  	}
		
		if (!sizeof($sorted_by->rules)) {
			if ($sorting_fields != '') {
				$sorting_array = array();
				$sorting_array = explode(',', $sorting_fields);
				foreach ($sorting_array as $key => $value) {
					$name_dir = array();
					$name_dir = explode('::', $value);
					$sorted_by->add($name_dir[0], $name_dir[1]);
				}
			}
		}
	}
	$grid->event->attach("beforeSort","custom_sort");

	function custom_filter($filter_by){
		global $numeric_field_array;

		if (sizeof($numeric_field_array) > 0){
			for ($i = 0; $i < sizeof($filter_by->rules); $i++) {
				if (in_array($filter_by->rules[$i]['name'], $numeric_field_array)) {
					$value = $filter_by->rules[$i]['value'];
					preg_match('/>=|<=|>|</', $value, $matches, PREG_OFFSET_CAPTURE);
					if ($matches[0][0]) {
						$filter_by->rules[$i]['name'] = "CAST(" . $filter_by->rules[$i]['name'] . " AS FLOAT)";
						$filter_by->rules[$i]['operation'] = $matches[0][0];
						$filter_by->rules[$i]['value'] = str_replace($matches[0][0], '', $value);
					}
			  	}
		  	}
	  	}	
	}
	$grid->event->attach("beforeFilter","custom_filter");

	$grid->dynamic_loading(100);
	/*
		$grid->render_complex_sql($sql, $id_field, $text_field, $extra_field, $grouping_column);
		Parameters:
		$sql - any sql code, which will be used as a base for data selection or the name of a stored procedure.
		$id_field - the name of the id field.
		$text_field - a comma separated list of data fields.
		$extra_field - a comma separated list of extra fields, optional.
		$grouping_column - used for building hierarchy in case of Tree and TreeGrid.

	 */
	//$def = readXMLURL2($sql);
	$select_statement = 'SELECT * FROM ' . $process_table;
	if ($grid_type == 'g') {
        $grid->render_sql($select_statement, $id_field, $text_field);
    } else if ($grid_type == 't' || $grid_type == 'tg') {
        $grid->render_sql($select_statement, $id_field, $text_field, $extra_field, $grouping_column);
    } 
?>