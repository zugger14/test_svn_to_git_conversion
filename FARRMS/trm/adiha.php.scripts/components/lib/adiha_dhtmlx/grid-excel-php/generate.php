<?php
/**
 * Grid data export
 * Gets data from the grid and passes to the generator
 * Also logs data if any error occurs or the script is run on debug mode
 * 
 * @copyright Pioneer Solutions
 */

require_once 'gridExcelGenerator.php';
require_once 'gridExcelWrapper.php';

$debug = false;
$error_handler = set_error_handler("ExcelErrorHandler");

$xmlString = urldecode($_POST['grid_xml']);

if ($debug) {
	error_log($xmlString, 3, 'debug_' . date("Y_m_d__H_i_s") . '.xml');
}

$filename = isset($_GET['filename']) ? $_GET['filename'] : '';
$xml = simplexml_load_string($xmlString);

$excel = new GridExcelGenerator();

if ($filename != '' || $filename != 'NULL') {
	$excel->printGrid($xml, $filename);
} else {
	$excel->printGrid($xml, '');
}

/**
 * Excel error handler, writes the error log on the file
 */
function ExcelErrorHandler ($errno, $errstr, $errfile, $errline) {
	$error_message = 'Error: ' . $errstr . ' occured in file ' . $errfile . ' on Line no ' . $errline;

	if ($errno < 1024) {
		error_log($error_message, 3, 'error_report_' . date("Y_m_d__H_i_s") . '.xml');
		exit(1);
	}
}
?>