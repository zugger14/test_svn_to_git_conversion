<?php
ob_start();
$check_cloud_mode_login = 1;
require 'components/include.main.files.php';
unset($check_cloud_mode_login);

$path = $_GET['path'];
$path = str_replace("<<PLUS>>", "+", $path);
$path = str_replace("<<HASH>>", "#", $path);
$path = str_replace("<<AMP>>", "&", $path);
$path = get_sanitized_download_path($path);

ob_end_clean();

if (!empty($path) && file_exists($path)) {
	$name = get_sanitized_value($_GET['name'] ?? '');
	//get explicitly provided download filename if available
	$download_filename = ($name == '' ? basename($path) : $name);

	header('Content-Type: application/octet-stream');
	header("Content-Transfer-Encoding: Binary");
	header("Content-disposition: attachment; filename=\"" . $download_filename . "\"");

	readfile($path);
} else {
	die("You're not authorized to access this file or file doesn't exists.");
}
?>