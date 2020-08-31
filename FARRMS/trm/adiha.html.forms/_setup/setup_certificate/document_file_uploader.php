<?php
ob_start();
include '../../../adiha.php.scripts/components/include.file.v3.php';

// to clean the html content from the include file include.file.v3.php
ob_clean();


$attach_docs_url_path1 = '../../../adiha.php.scripts/dev/shared_docs/temp_Note/certification_key';

if (@$_REQUEST["mode"] == "html5" || @$_REQUEST["mode"] == "flash") {
    $state = 'false';
    $filename = $_FILES["file"]["name"];
    $filetype = $_FILES["file"]["type"];
    
    if (!is_dir($attach_docs_url_path1)){
        $login_dir = mkdir($attach_docs_url_path1);
    }
    

    if (!is_dir($attach_docs_url_path1) && !mkdir($attach_docs_url_path1) && !$login_dir) {
        $state = 'false';
    } else {
        if (validate_file_extension($filetype)) {
            $state = 'true';
            move_uploaded_file($_FILES["file"]["tmp_name"], $attach_docs_url_path1 . "/" . $filename);
        }
    }
    header("Content-Type: text/json");
    print_r("{state: " . $state . ", name:'" . str_replace("'", "\\'", $filename) . "'}");
}



function validate_file_extension($filetype)
{
    if (
        $filetype == 'application/octet-stream'
    ) {
        return true;
    } else {
        return false;
    }
}
