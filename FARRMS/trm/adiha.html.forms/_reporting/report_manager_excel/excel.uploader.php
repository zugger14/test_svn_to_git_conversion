<?php
ob_start();
include '../../../adiha.php.scripts/components/include.file.v3.php';
include 'components/include.main.files.php';

// to clean the html content from the include file include.file.v3.php

ob_clean();

/*
HTML5/FLASH MODE
(MODE will detected on client side automaticaly. Working mode will passed to server as GET param "mode")

response format
if upload was good, you need to specify state=true and name - will passed in form.send() as serverName param
{state: 'true', name: 'filename'}
*/

$call_from = get_sanitized_value($_REQUEST['call_from'] ?? '');
$mode = get_sanitized_value($_REQUEST['mode'] ?? '');
$action = get_sanitized_value($_REQUEST['action'] ?? '');

// $_SESSION['Error'] = "Another file with same name already exists.";

$attach_docs_url_path = '../../../adiha.php.scripts/dev/shared_docs/temp_Note';
$uploads_dir = '../../../adiha.php.scripts/dev/shared_docs/Excel_Reports';
// $filename = '../../../adiha.php.scripts/dev/shared_docs/Excel_Reports/filename';
$files = scandir($uploads_dir);
$files = array_diff(scandir($uploads_dir), array('.', '..'));

// $flag_param = "";
// $param = "";
$file_name = get_sanitized_value($_POST['filename'] ?? '');

if ($call_from == 'save') {
	$move_file = rename($attach_docs_url_path.'/'.$file_name, $uploads_dir.'/'.$file_name);

	if ($move_file){
		header("Content-Type: text/html");
		echo "Success";
		die();
	}
	header("Content-Type: text/html");
		echo "Fail";
	die();
}

if ($call_from == 'direct_upload') {
	$attach_docs_url_path = '../../../adiha.php.scripts/dev/shared_docs/temp_Note';
}

if ($mode == "html5" || @$mode == "flash") {
	$state = 'false';
	$filename = str_replace(" ", "_", $_FILES["file"]["name"]);
	$filetype = $_FILES["file"]["type"];
    
	if (validate_file_extension($filetype)) {
		$state = 'true';
        move_uploaded_file($_FILES["file"]["tmp_name"], $attach_docs_url_path . "/" . $filename);
	}
    
	header("Content-Type: text/json");
	print_r("{state: " . $state . ", name:'" . str_replace("'", "\\'", $filename) . "'}");
}

/*
HTML4 MODE

response format:
to cancel uploading
{state: 'cancelled'}

if upload was good, you need to specify state=true, name - will passed in form.send() as serverName param, size - filesize to update in list
{state: 'true', name: 'filename', size: 1234}
*/

if ($mode == "html4") {
	header("Content-Type: text/html");
    
	if ($action == "cancel") {
		print_r("{state:'cancelled'}");
	} else {
		$state = 'false';
        $filename = str_replace(" ", "_", $_FILES["file"]["name"]);
        $filetype = $_FILES["file"]["type"];
        $ext = pathinfo($filename, PATHINFO_EXTENSION);

        // Remove file if exists in temp_Note and remove inorder to upload updated file.
    	$replace_file = false; 
    	if (!validate_file($files, $filename)) {
        	unlink($attach_docs_url_path . "/" . $filename);
        	// Remove filename from array as well since file is deleted.
        	if (($key = array_search($filename, $files)) !== false) {
			    unset($files[$key]);
			}
			$replace_file = true;
        }

    	if (validate_file_extension($ext) && (validate_file($files,$filename) || $replace_file)) {
    		$state = 'true';
    		$value = 'true';
   //  		$xml_string = build_XML();
			// $xmlFile = "EXEC " . $action . " " . $flag_param ." @xml='". $xml_string."'";
            move_uploaded_file($_FILES["file"]["tmp_name"], $attach_docs_url_path . "/" . $filename);
    	} 
		print_r("{state: " . $state . ", name:'" . str_replace("'", "\\'", $filename) . "', size:" . $_FILES["file"]["size"] . "}");
	}
}



function validate_file_extension($ext) {
	$allowed =  array('xls','xlsx');
	if(!in_array($ext,$allowed) ) {
		return false;			
	} else {
	   return true;
	}
}

function validate_file($files,$filename){	
	if (in_array($filename, $files)) {
		return false;
	} else {
		return true;
	}
}
?>