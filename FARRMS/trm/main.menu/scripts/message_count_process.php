<?php
ob_start();
require_once("../../adiha.php.scripts/components/lib/adiha_dhtmlx/AdihaClasses/DataCache.php");    
include '../../adiha.php.scripts/components/file_path.php';
include '../../adiha.php.scripts/components/lib/adiha_dhtmlx/adiha_php_functions.3.0.php';
include '../../adiha.php.scripts/components/lib/adiha.xml.parser.1.0.php';

## Get the app user name by validating the token
$app_user_name = NULL;
$token = $_COOKIE["_token"];
if (isset($token)) {
    $token_data = verify_token($token);
    if (isset($token_data['response_code']) && $token_data['response_code'] == 200) {
        $app_user_name = $token_data["username"];
        ## These new databse server name and database name will be used in database connection
        $new_db_server_name = $token_data["db_servername"];
        $new_db_name = $token_data["database_name"];
        $new_db_user = $token_data["db_user"];
        $new_db_pwd = $token_data["db_pwd"];
    } else {
        forbidden_access_http_response();
    }
}

if (empty($app_user_name)) {
    forbidden_access_http_response();
}

# Above db connection info should be resolved before including the config file below
include $config_file;
/*
# Autoloader will autoload the class file with the name 
# same as the class name by resolving path with 
# the base path directory and the lib path
include( $farrms_root_dir . "/" . $farrms_root . "/adiha.php.scripts/autoloader.php");
autoloader(array(array(
    'basepath' => $farrms_root_dir . "\\" . $farrms_root . "\adiha.php.scripts\components"
)));

autoloader(array(
    'lib\adiha_dhtmlx\AdihaClasses',
    ''
));
## Above autoloader is needed to load MemCached Class
*/

$sql = "EXEC spa_message_board 'c', '" . $app_user_name . "'";
$key_prefix = 'MB';  //MB short form for message board. Identifier.
$key_suffix = 'c';

$recordsets = readXMLURLCached($sql, false, $key_prefix, $key_suffix, true);

ob_end_clean(); //Donot comment this code. This page should return only $arr for message count.
$arr = array(
            'alert_count' => $recordsets[0]['alert_count'],
            'message_count' => $recordsets[0]['message_count'],
            'reminder_count' => $recordsets[0]['reminder_count']
        );
echo json_encode($arr);
?>