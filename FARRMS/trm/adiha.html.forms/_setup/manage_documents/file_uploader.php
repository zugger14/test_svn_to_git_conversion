<?php
/**
* File_uploader screen
* @copyright Pioneer Solutions
*/
?>
<?php
ob_start();
include '../../../adiha.php.scripts/components/include.file.v3.php';

// to clean the html content from the include file include.file.v3.php
ob_clean();

/*
HTML5/FLASH MODE
(MODE will detected on client side automatically. Working mode will passed to server as GET param "mode")

response format
if upload was good, you need to specify state=true and name - will passed in form.send() as serverName param
{state: 'true', name: 'filename'}
*/
$call_from = get_sanitized_value($_GET['call_from'] ?? '');
$category_id = get_sanitized_value($_REQUEST["category_id"] ?? '');
$mode = get_sanitized_value(@$_REQUEST["mode"]);
$action = get_sanitized_value(@$_REQUEST["action"]);

$xml_url = "EXEC spa_manage_document_search 'x'";
$arr_category = readXMLURL2($xml_url);


$arr_category_filtered = array_values(array_filter($arr_category, function($el) use ($category_id) {
    if($category_id == $el['category_id']) return true;
    else return false;
}));
//print_r($arr_category_filtered);
if($call_from == 'manage_document') {
    $category_folder = $arr_category_filtered[0]['category_name'];
} else {
    $category_folder = '';
}

$attach_docs_url_path = '../../../adiha.php.scripts/dev/shared_docs/attach_docs/' . $category_folder;

if ($call_from == 'direct_upload') {
	$attach_docs_url_path = '../../../adiha.php.scripts/dev/shared_docs/temp_Note';
}

if ($mode == "html5" || $mode == "flash") {
	$state = 'false';
	$filename = str_replace(" ", "_", $_FILES["file"]["name"]);
	$filetype = $_FILES["file"]["type"];
    if(!is_dir($attach_docs_url_path) && !mkdir($attach_docs_url_path)) {
        $state = 'false';
    } else {
    	if (is_valid_file_type($filetype) && is_valid_file_extension(get_file_extension($filename))) {
    		$state = 'true';
            move_uploaded_file($_FILES["file"]["tmp_name"], $attach_docs_url_path . "/" . $filename);
    	}
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
        
    	if (is_valid_file_type($filetype) && is_valid_file_extension(get_file_extension($filename))) {
    		$state = 'true';
            move_uploaded_file($_FILES["file"]["tmp_name"], $attach_docs_url_path . "/" . $filename);
    	}
		print_r("{state: " . $state . ", name:'" . str_replace("'", "\\'", $filename) . "', size:" . $_FILES["file"]["size"] . "}");
	}
}
?>
