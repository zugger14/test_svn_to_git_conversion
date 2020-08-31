<?php
	ob_start();
	require_once('components/include.file.v3.php');
	$_REQUEST = array_merge($_GET, $_POST);
    $process_table = (isset($_REQUEST["process_table"])) ? $_REQUEST["process_table"] : '';

    ob_clean();

	require("components/lib/adiha_dhtmlx/adiha_connectors_3.0/tree_connector.php");
	require("components/lib/adiha_dhtmlx/adiha_connectors_3.0/db_sqlsrv.php");

	$res = @sqlsrv_connect($db_servername, $connection_info);	
	$tree = new TreeConnector($res,"SQLSrv");

	// for book structure
	$select_statement = "SELECT entity_id, entity_name, im0,im1,im2,privilege FROM " . $process_table . " ORDER BY entity_name ASC";
	$tree->render_sql($select_statement, 'entity_id', 'entity_name,im0,im1,im2', 'privilege', 'parent_entity_id');
	@sqlsrv_close($res);
?>