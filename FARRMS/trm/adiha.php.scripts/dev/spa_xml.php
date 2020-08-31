<?php
ob_start();
//require_once 'spa_xml_combo.php';
header('Pragma:'); //this is required to make view price flex application work on HTTPS environment

$sql = urldecode($_REQUEST['spa']);
$sql = stripslashes($sql);
$call_from = isset($_REQUEST['call_from']) ? $_REQUEST['call_from'] : '';

// use file session if SESSION is not working when Opening in New Window ,
$use_file_session = true;

include '../PHP_CLASS_EXTENSIONS/PS.Recordset.1.0.php';

$sql = str_replace('_format1', '', $sql);
$sql = str_replace('_format2', '', $sql);
$sql = str_replace('_format3', '', $sql);

$recordset_object = new PSRecordSet(false);
$recordset_object->connectToDatabase('','','');
$recordset_object->setStripHyperlink(true);

ob_clean();

if ($call_from != '') {
    echo $recordset_object->runSQLStmt($sql, 'xml', $call_from);
} else {
    echo $recordset_object->runSQLStmt($sql, 'xml');
}
?>