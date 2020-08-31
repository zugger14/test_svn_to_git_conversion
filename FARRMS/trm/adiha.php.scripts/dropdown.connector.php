<?php
    /**
     * Prepare the XML from the dataset and JS function use this to load the dropdown options in the combo.
     * @copyright Pioneer Solutions
     */
	
    ob_start();
	require_once('components/include.file.v3.php');
	## Verify CSRF Token
	verify_csrf_token();
	
	$call_from = get_sanitized_value($_GET['call_from'] ?? '');
	
	/*
	 * Used for dependent combos
	 * Generates the XML depending upon the parent_column
	 * Required parameters - application_field_id, parent_column, value(parent_column value)
	 */
	if ($call_from == 'dependent') {
		$application_field_id = get_sanitized_value($_GET['application_field_id'] ?? '');
		$parent_column = get_sanitized_value($_GET['parent_column'] ?? '');
		$value = get_sanitized_value($_GET['value'] ?? ($_POST['value'] ?? ''));

		$load_child_without_selecting_parent = (isset($_GET["load_child_without_selecting_parent"])) ? $_GET["load_child_without_selecting_parent"] : '';

		if ($value == '') {
			$value = 'NULL';
		}

		if ($application_field_id != '' && $application_field_id != null) {
			$dropdown_sql = '';
			if (($load_child_without_selecting_parent == 1 || $load_child_without_selecting_parent === true)  && $value == 'NULL') {
				$sql = "EXEC spa_create_application_ui_json @flag='l', @application_field_id=?";
				$param_values = array($application_field_id);
				$sql_def = readXMLURL2($sql, false, $param_values);
				$dropdown_sql = $sql_def[0]['dropdown_sql'];
			} else if ($value != 'NULL') {
				$sql = "EXEC spa_create_application_ui_json @flag='b', @application_field_id=?";
				$param_values = array($application_field_id);
				$sql_def = readXMLURL2($sql, false, $param_values);
				$dropdown_sql = $sql_def[0]['dropdown_sql'];
				$dropdown_sql = str_replace('<' . $parent_column . '>', $value, $dropdown_sql);
			}

			$has_blank_option = $sql_def[0]['has_blank_option'];
			generate_dropdown($dropdown_sql, $has_blank_option);
		}
	} else if ($call_from == 'report_filters') {
		$action = (isset($_GET["action"])) ? $_GET["action"] : '';
		$flag = (isset($_GET["flag"])) ? $_GET["flag"] : NULL;
		$xml_string = (isset($_GET["xml_string"])) ? $_GET["xml_string"] : NULL;

		if ($action != '') {
			$sql = "EXEC " . $action .  " @flag=?, @xml_string=?";
			$param_values = array($flag, $xml_string);
			generate_toolbar_options($sql, $param_values);
		}
	} else {
		$return_array = get_statement();
		$sql = $return_array[0];
		$param_values = $return_array[1];

		if ($sql != '') {
			if ($call_from == 'grid') {
				generate_grid_dropdown($sql, $param_values);
			} else if ($call_from == 'multiselect') {
				generate_multiselect($sql, $param_values);
			} else {
				generate_dropdown($sql, true, $param_values);
			}
		}
	}

	/**
	 * Generates XML for toolbar
	 *
	 * @param   String  $sql           SQL query
	 * @param   Array  	$param_values  Parameters value
	 *
	 * @return  String                 XML for toolbar
	 */
	function generate_toolbar_options($sql, $param_values = array()) {
		if ($sql != '') {
			$def = readXMLURL($sql, 1, $param_values);

			ob_end_clean();
			header("Content-type:text/xml");

			$xml = '<?xml version="1.0" encoding="UTF-8"?>';
			$xml .= '<toolbar>';
			$xml .= '	<item type="button" id="new" text="Add new.."></item>';
			$xml .= '	<item type="separator"	id="new_s1"/>';

			foreach ($def as $row_val) {
				$xml .= '	<item type="button" id="' . $row_val[0] . '" text="<![CDATA[' . $row_val[1] . ']]>"/>';
			}

			$xml .= '</toolbar>';

			print_r($xml);
		}
	}

	/**
	 * Generates XML for dropdown
	 *
	 * @param   String  $sql               SQL query
	 * @param   String  $has_blank_option  Has blank option in dropdown
	 * @param   Array  	$param_values      Parameters values
	 *
	 * @return  String                     Dropdown XML
	 */
	function generate_dropdown($sql, $has_blank_option = 'true', $param_values = array()) {
		if ($sql != '') {
			$def = readXMLURL($sql, 1, $param_values);

			ob_end_clean();
			header("Content-type:text/xml");
            $has_blank_option = (isset($_GET["has_blank_option"])) ? $_GET["has_blank_option"] : $has_blank_option;
			$selected_value = (isset($_GET["SELECTED_VALUE"])) ? $_GET["SELECTED_VALUE"] : 0;
			$xml = '<?xml version="1.0" encoding="UTF-8"?>';
			$xml .= '<complete>';
            
            if ($has_blank_option == 'true') {
			     $xml .= '	<option value=""></option>';
            }

            $selected_value_array = explode(',', $selected_value);
			foreach ($def as $row_val) {
			    $should_check_option = in_array($row_val[0], $selected_value_array);
                if ($should_check_option) {
                    $checked_option_index = array_search($row_val[0], $selected_value_array);
                    array_splice($selected_value_array, $checked_option_index, 1);
					$xml .= '	<option value="' . $row_val[0] . '"  state="' . ($row_val[2] ?? 'enable') . '" selected="1" checked="1"><![CDATA[' . $row_val[1] . ']]></option>';
				} else {
					$xml .= '	<option value="' . $row_val[0] . '"  state="' . ($row_val[2] ?? 'enable') . '"><![CDATA[' . $row_val[1] . ']]></option>';
				}
			}

			$xml .= '</complete>';

			print_r($xml);
		}
	}
	
	/**
	 * Generates XML for multiselect
	 *
	 * @param   String  $sql           SQL query
	 * @param   Array  	$param_values  Parameter values
	 *
	 * @return  String                    XML for multiselect
	 */
    function generate_multiselect($sql, $param_values = array()) {
		if ($sql != '') {
			$def = readXMLURL($sql, 1, $param_values);

			ob_end_clean();
			header("Content-type:text/xml");
            $has_blank_option = (isset($_GET["has_blank_option"])) ? $_GET["has_blank_option"] : 'true';
			$xml = '<?xml version="1.0" encoding="UTF-8"?>';
			$xml .= '<data>';
            
            if ($has_blank_option == 'true') {
			     $xml .= '	<item value=""></item>';
            }
            
			foreach ($def as $row_val) {
				$xml .= '	<item value="' . $row_val[0] . '" label="' . $row_val[1] . '"';
                if ($row_val[2] == 'true') {
                    $xml .= ' selected="' . $row_val[2] . '" ';
                }
                $xml .= '></item>';
			}

			$xml .= '</data>';

			print_r($xml);
		}
	}

	/**
	 * Generates JSON for grid dropdown options
	 *
	 * @param   String  $sql           SQL Query
	 * @param   Array  	$param_values  Parameter values
	 *
	 * @return  String                 Dropdown JSON
	 */
	function generate_grid_dropdown($sql, $param_values = array()) {
		if ($sql != '') {
			$def = readXMLURL2($sql, false, $param_values);
			ob_end_clean();
            $has_blank_option = (isset($_GET["has_blank_option"])) ? $_GET["has_blank_option"] : 'false';
            
            if ($has_blank_option == 'true') {
                echo str_replace('{options:[','{options:[{"value":"","text":""},', $def[0]['json_string']);
            } else {
				echo $def[0]['json_string'];
			}
		}
	}

	/**
	 * Get SQL statements with param values
	 *
	 * @return  Array  SQL statements with param values
	 */
	function get_statement() {
		$action = $_GET["action"] ?? '';
		$param_values = array();
		$sql = '';

		if ($action != '') {
			$i = 0;
			$param = '';
			
			foreach ($_GET as $name => $value) {
				$pos = strpos($name, 'dhx');
				$names_to_avoid = array('_csrf_token', 'action', 'connector', 'call_from', 'has_blank_option', 'SELECTED_VALUE');
				if ($pos === false && !in_array($name, $names_to_avoid)) {
					$param .= ($i == 0) ? "" : ",";
					$param .= "@" . $name . "=?";
					array_push($param_values, ($value == 'NULL') ? NULL : $value);
					$i++;
			    }    		
			}

			$sql = "EXEC " . $action . " " . $param;
		}
		
		return array($sql, $param_values);
	}	
?>