<?php
require_once 'gridPdfGenerator.php';
require_once 'tcpdf/tcpdf.php';
require_once 'gridPdfWrapper.php';

$debug = false;
$error_handler = set_error_handler("PDFErrorHandler");

$xmlString = $_POST['grid_xml'];
$xmlString = urldecode($xmlString);

if ($debug) {
	error_log($xmlString, 3, 'debug_'.date("Y_m_d__H_i_s").'.xml');
}

$filename = isset($_GET['filename']) ? $_GET['filename'] : '';
$xml = simplexml_load_string($xmlString);
$pdf = new gridPdfGenerator();

if ($filename != '' || $filename != 'NULL') {
	$pdf->printGrid($xml, $filename);
} else {
	$pdf->printGrid($xml, '');
}

/**
 * PDF error handler, writes the error log on the file
 */
function PDFErrorHandler ($errno, $errstr, $errfile, $errline) {
	$error_message = 'Error: ' . $errstr . ' occured in file ' . $errfile . ' on Line no ' . $errline;

	if ($errno < 1024) {
		error_log($error_message, 3, 'error_report_' . date("Y_m_d__H_i_s") . '.xml');
		exit(1);
	}
}
?>