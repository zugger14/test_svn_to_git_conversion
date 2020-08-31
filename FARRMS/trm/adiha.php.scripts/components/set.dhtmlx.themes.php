<?php
/** 
* Setting theme and start the session.
* @copyright Pioneer Solutions
*/

$farrms_client_dir = filter_var($_COOKIE['client_folder'], FILTER_SANITIZE_STRING);
require_once 'lib/adiha_dhtmlx/adiha_php_functions.3.0.php';
require_once 'file_path.php';
require_once '../../../' . $farrms_client_dir. '/adiha.config.ini.rec.php';

$token = $_COOKIE["_token"];
if (isset($token)) {
	## Get the app user name by validating the token
	$token_data = verify_token($token);
	if (isset($token_data['response_code']) && $token_data['response_code'] == 200) {
		$app_user_name = $token_data["username"];
	}
}
require_once 'TRMSession.php';
session_name($database_name);
session_start();

$theme_name = filter_var($_POST['dhtmlx_theme'] ?? '', FILTER_SANITIZE_STRING);
if (!empty($theme_name)) {
    $default_theme = str_replace('theme-', '', $theme_name);
}

// used for setup application default theme to clear old session data and load new data.
unset($_SESSION['client_date_format']); 
$_SESSION['client_date_format'] = "";
?>