<?php
	ob_start();
	$catch_session_expire = 1;
	include 'components/include.main.files.php';
	unset($catch_session_expire);
	## Verify CSRF Token
	verify_csrf_token();
	ob_end_clean();

	// Commented sanitization function because it can contain sql query
    // $action = get_sanitized_value($_POST['action'] ?? '');
	$action = $_POST['action'] ?? '';
	$flag = get_sanitized_value($_POST['flag'] ?? '');
	$function_id = get_sanitized_value($_POST['function_id'] ?? '');
	$build_XML = get_sanitized_value($_GET['build_XML'] ?? '');
	$sp_string = $_POST["sp_string"] ?? '';
	
	if ($action != "" || $sp_string != "") {
		function_data_post($action, $function_id, $build_XML, $sp_string);
	}

	function function_data_post($action = '', $function_id = '', $build_XML = '', $sp_string = '') {
		$flag_param = "";
		$param = "";
		$param_values = array();
		
		if ($sp_string == '') {
			if ($build_XML) {
				if ($function_id) {
					$flag_param .= "@function_id=?,";
					array_push($param_values, $function_id);
				}
				$xml_string = build_XML();
				$xmlFile = "EXEC " . $action . " " . $flag_param . " @xml=?";
				array_push($param_values, $xml_string);
			} else {
				$i = 0;
				$names_to_avoid = array('session_id', '__user_name__', 'action', 'type', 'key_prefix', 'key_suffix', 'append_user_name', '_csrf_token');
				foreach ($_POST as $name => $value) {
					if (!in_array($name, $names_to_avoid)) {
						if ($i != 0) {
							$param .= ",";
						}
						$param .= "@" . $name . "=?";
						array_push($param_values, ($value == 'NULL') ? NULL : $value);
						$i++;
					}
				}
				$xmlFile = "EXEC " . $action . " " . $flag_param . " " . $param;
			}
		} else {
			$xmlFile = $sp_string;
		}	
		
		$key_prefix = get_sanitized_value($_POST['key_prefix'] ?? '');
		$key_suffix = get_sanitized_value($_POST['key_suffix'] ?? '');
		$append_user_name = (isset($_POST["append_user_name"]) && $_POST["append_user_name"] == 0) ? false : true;
		
		if ($build_XML != '') {
			$recordsets = readXMLURL($xmlFile, 1, $param_values);
			$return = $recordsets[0][4];
		} else {
			if (($_POST["type"] ?? '') == 'return_array') {
				$recordsets = ($key_prefix == '') ? readXMLURL($xmlFile, 1, $param_values) : readXMLURLCached($xmlFile, true, $key_prefix, $key_suffix, $append_user_name, 0, 'readXMLURL', $param_values);
			} else {
				$recordsets = ($key_prefix == '') ? readXMLURL2($xmlFile, false, $param_values) : readXMLURLCached($xmlFile, false, $key_prefix, $key_suffix, $append_user_name, 0, 'general', $param_values);
			}

			$return["json"] = $recordsets;
		}
		
		echo json_encode($return);
	}

	function build_XML() {
		$xml_string = '<Root>';
		$xml_string .= '<PSRecordset ';
		
		foreach ($_POST as $name => $value) {
			 $xml_string .= $name . '="' . $value . '" ';
		}
		
		$xml_string .= ' ></PSRecordset>';
		$xml_string .= '</Root>';
		return $xml_string;
	}
?>