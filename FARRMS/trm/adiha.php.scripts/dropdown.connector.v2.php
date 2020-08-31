<?php	
	ob_start();
	require_once('components/include.file.v3.php');
	## Verify CSRF Token
	verify_csrf_token();
	
	$process_table = (isset($_GET["process_table"])) ? $_GET["process_table"] : '';
	$application_field_id = (isset($_GET["application_field_id"])) ? $_GET["application_field_id"] : '';
	$default_value = (isset($_GET["default_value"])) ? $_GET["default_value"] : '';
	$call_from = (isset($_GET["call_from"])) ? $_GET["call_from"] : '';
	$farrms_field_id = (isset($_GET["farrms_field_id"])) ? $_GET["farrms_field_id"] : '';
	$is_udf = (isset($_GET["is_udf"])) ? $_GET["is_udf"] : '';
	$deal_id = (isset($_GET["deal_id"])) ? $_GET["deal_id"] : '';
	$template_id = (isset($_GET["template_id"])) ? $_GET["template_id"] : '';
	$deal_type_id = (isset($_GET["deal_type_id"]) && $_GET["deal_type_id"] != '') ? $_GET["deal_type_id"] : 'NULL';
	$commodity_id = (isset($_GET["commodity_id"])) ? $_GET["commodity_id"] : '';

	$is_report = (isset($_GET["is_report"])) ? $_GET["is_report"] : 'n';
	$deal_id = (isset($_GET["deal_id"])) ? $_GET["deal_id"] : '';
	$parent_value = (isset($_GET["parent_value"])) ? $_GET["parent_value"] : '';
    $required = (isset($_GET["required"]) && $_GET["required"] != '') ? (($_GET["required"] == 'true' || $_GET["required"] == 'y') ? 'y' : 'n') : 'n';
    $key_id = strtolower(isset($_GET["unique_id"]) ? $_GET["unique_id"] : '');

	ob_clean();
	require("components/lib/adiha_dhtmlx/adiha_connectors_3.0/combo_connector.php");
	require("components/lib/adiha_dhtmlx/adiha_connectors_3.0/db_sqlsrv.php");

	$res = @sqlsrv_connect($db_servername, $connection_info);
	$combo = new ComboConnector($res,"SQLSrv");

	$default_value = ($default_value == '') ? 'NULL' : "'" . $default_value . "'";
	$parent_value = ($parent_value == '') ? 'NULL' : "'" . $parent_value . "'";
	$deal_id = ($deal_id == '') ? 'NULL' : $deal_id;
	$template_id = ($template_id == '') ? 'NULL' : $template_id;
	$commodity_id = ($commodity_id == '') ? 'NULL' : $commodity_id;

	// Set session context
    $session_context_sql = "EXEC sys.sp_set_session_context @key = N'DB_USER', @value = '" . $app_user_name . "';";

	if ($call_from == 'deal') {
		$sql = $session_context_sql . "EXEC spa_deal_update_new @flag='g', @source_deal_header_id=" . $deal_id . ", @template_id=" . $template_id . ", @farrms_field_id='" . $farrms_field_id . "', @selected_value=" . $default_value . ", @is_udf='" . $is_udf . "', @deal_type_id=" . $deal_type_id. ", @required='" . $required . "', @commodity_id=" . $commodity_id;
		
		/* Prevented dropdown options loading for dependent child dropdown 
		 * initially for the items defined in $hay_stack array (Product Grading)
		*/
		$hay_stack = array("origin", "form", "attribute1", "attribute2", "attribute3", "attribute4", "attribute5");
		if (in_array($farrms_field_id, $hay_stack) == false)
			$combo->render_complex_sql($sql, 'value', 'text,state,selected');
	} else {
		if ($application_field_id == '') {
			$select_statement = $session_context_sql . "SELECT value,text,state, ISNULL(selected, 'false') selected FROM " . $process_table . " ORDER BY [id] ASC";
		    $combo->render_sql($select_statement, 'value', 'text,state,selected');
		} else {
			$sql = $session_context_sql . "EXEC spa_create_application_ui_json @flag='x', @application_field_id=" . $application_field_id . ", 	@selected_value=" . $default_value . ", @is_report='" . $is_report . "', @parent_value=" . $parent_value;
			$combo->render_complex_sql($sql, 'value', 'text,state,selected,checked',false,false,$key_id);
		}
	}
	@sqlsrv_close($res);
?>