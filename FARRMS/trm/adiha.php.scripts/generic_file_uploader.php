<?php
ob_start();
include 'components/include.file.v3.php';
## Verify CSRF Token
verify_csrf_token();
ob_end_clean();

/*

HTML5/FLASH MODE

(MODE will detected on client side automatically. Working mode will passed to server as GET param "mode")

response format

if upload was good, you need to specify state=true and name - will passed in form.send() as serverName param
{state: 'true', name: 'filename'}

*/
$call_form = get_sanitized_value($_GET['call_form'] ?? '');
$template_folder = get_sanitized_value($_GET['template_folder'] ?? '');

if ($call_form == 'data_import_export' || $call_form == 'edi_file_upload' || $call_form == 'workflow_word_template' || $call_form == 'alert_workflow_import') {
    $attach_docs_url_path = 'dev/shared_docs/temp_Note';
    if ($call_form == 'edi_file_upload') {
        $attach_docs_url_path = 'dev/shared_docs/temp_Note/EDI/Processed';
    } else if ($call_form == 'workflow_word_template') {
		$filetype = $_FILES["file"]["type"];
		if ($filetype == 'application/xml') {
			$attach_docs_url_path = 'dev/shared_docs/attach_docs/' . $template_folder . '/xmls';
		} else {
			$attach_docs_url_path = 'dev/shared_docs/attach_docs/' . $template_folder . '/Template';
		}
	}
}

if (@$_REQUEST["mode"] == "html5" || @$_REQUEST["mode"] == "flash") {
	$state = 'false';
	$filename = $_FILES["file"]["name"];
    if($call_form == 'edi_file_upload') {
        $filename = str_replace(" ", "_", $_FILES["file"]["name"]);
    }
	$filetype = $_FILES["file"]["type"];

	if (is_valid_file_type($filetype) && is_valid_file_extension(get_file_extension($filename))) {
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

if (@$_REQUEST["mode"] == "html4") {
	header("Content-Type: text/html");
    
	if (@$_REQUEST["action"] == "cancel") {
		print_r("{state:'cancelled'}");
	} else {
		$state = 'false';
        $filename = $_FILES["file"]["name"];
        $filetype = $_FILES["file"]["type"];
        
    	if (is_valid_file_type($filetype) && is_valid_file_extension(get_file_extension($filename))) {
    		$state = 'true';
            move_uploaded_file($_FILES["file"]["tmp_name"], $attach_docs_url_path . "/" . $filename);
    	}
		print_r("{state: " . $state . ", name:'" . str_replace("'", "\\'", $filename) . "', size:" . $_FILES["file"]["size"] . "}");
	}
}
?>
