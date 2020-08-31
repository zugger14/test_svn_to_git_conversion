<?php
include 'farrms.config.ini.php';

$enable_session = true;

//## Make sure your version name is correct
$farrms_root_path = $farrms_root_dir . "\\" . $farrms_root . "\\";
$session_path = $farrms_root_path . "adiha.php.scripts\\dev\\session";
$config_file = $farrms_root_dir . "\\$farrms_client_dir\\adiha.config.ini.rec.php";
$hedge_doc_path = $farrms_root_path . "adiha.php.scripts\\dev\\template_hedge_document";
$language_xml_path = $farrms_root_path . "adiha.php.scripts\\languages";

## Add Leading and Trailing slash (/) if missing in $farrms_virtual_domain
$farrms_virtual_domain = (strpos($farrms_virtual_domain, '/') === 0) ? $farrms_virtual_domain : '/' . $farrms_virtual_domain;
$farrms_virtual_domain = (strrpos($farrms_virtual_domain, '/') === strlen($farrms_virtual_domain) - 1) ? $farrms_virtual_domain : $farrms_virtual_domain . '/';

$appBaseURL = $farrms_virtual_domain . "$farrms_root/";
$app_adiha_loc = $webserver . $appBaseURL;
$app_php_script_loc = $app_adiha_loc . "adiha.php.scripts/";
$app_form_path = $app_adiha_loc . "adiha.html.forms/";
$main_menu_path = $app_adiha_loc . "main.menu/";

//Max rows to display in row
$max_row_for_html = 100;
$max_row_for_grid = 27;
?>