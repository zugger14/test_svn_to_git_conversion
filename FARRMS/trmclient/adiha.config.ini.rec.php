<?php
include 'farrms.client.config.ini.php';
include 'product.global.vars.php';
include 'license.php';


$database_process = 'adiha_process'; //!< Temporarily Database, which is used for FARRMS Processing, should reside on the same server where $database_name is created.
//!< This value shouldn't be changed.

$temp_path = $rootdir . '\\' . "$farrms_root\\adiha.php.scripts\\dev\\shared_docs\\temp_Note"; //!< Specifies file path to the loation of temp_note.


$relative_temp_path = 'adiha.php.scripts/dev/shared_docs/temp_Note'; //!< Use relative path only; absolute not supported in report.viewer file.


$attach_docs_path = $rootdir . '\\' . "$farrms_root\\adiha.php.scripts\\dev\\shared_docs\\attach_docs"; //!< Local_path for attach_docs.


$attach_docs_url_path = $app_php_script_loc . 'dev/shared_docs/attach_docs'; //!<URL path for attach_docs


$BATCH_FILE_EXPORT_PATH = $SHARED_DOC_PATH . '\\temp_Note'; //!< Maintain Temp_Note Directory Path for batch process.
$SHARED_ATTACH_DOCS_PATH = $SHARED_DOC_PATH . '\\attach_docs';


$ssrs_config['RDL_DIR_LOCAL'] = $temp_path; //!< Directory where custom RDLs are uploaded by php (e.g. Invoice, Deal Confirmation/Replacement, Trade Ticket etc.).
//!< Make sure this is a local path.


$ssrs_config["EXPORTED_REPORT_DIR_INITIAL"] = $BATCH_FILE_EXPORT_PATH; //!< Directory where RDLs are generated temporarily by report manager - specifically temp_Note.
//!< Make sure this path is accessible by DB (i.e. should be a network path if DB server is diff than app server).


$ssrs_config['RS_TIMEOUT'] = 2700; //!< RS commandline execution timeout (SSRS).

                                            
$ssrs_config['REPORT_REGION'] = "en-US"; //!< Report Region.
//!< Culture Name Options:- Chinese(Traditional):zh-tw | German:de-de | English:en-us | English(UK):en-gb | French:fr-fr | Italian:it-it
//!< Japanese:ja-jp | Korean:ko-kr | Russian:ru-ru | Chinese(Simplified):zh-cn | Spanish:es-es | Czech:cs-cz | Danish:da-dk
//!< Greek:el-gr | Finnish:fi-fi | Hungarian:hu-hu | Dutch:nl-nl | Norwegian(Bokmal):nb-no | Polish:pl-pl | Portuguese(Brazil):pt-br
//!< Swedish:sv-se | Turkish:tr-tr | Portuguese(European):pt-pt

$COOKIE_EXPIRE_DATE = 'expires=Sat, 31-Dec-2050 23:59:59 GMT'; //!< Specify cookie expiry date used for grid column visibility/order

$auth_type = $_SERVER['AUTH_USER']; //!< Specifies the authentication type (E.g Windows authentication or SQL authentication).

// Only include at the time of login if cloud mode is enabled, After that cookie will handle it.
// $check_cloud_mode_login is set 1 in verify.php while loggin in the user
# Only include at the time of login if cloud mode is enabled, After that token will handle it.
if ($CLOUD_MODE == 1) {
    if (isset($check_cloud_mode_login) == 1 && $check_cloud_mode_login == 1)
        require $rootdir . "/trm/main.menu/scripts/db_reference.php";
    
    $database_name = (isset($new_db_name) && $new_db_name != '') ? $new_db_name : $database_name;
    $db_servername = (isset($new_db_server_name) && $new_db_server_name != '') ? $new_db_server_name : $db_servername;
    $db_user = (isset($new_db_user) && $new_db_user != '') ? $new_db_user : '';
    $db_pwd = (isset($new_db_pwd) && $new_db_pwd != '') ? $new_db_pwd : '';
}

$connection_info = array(
    "Database" => $database_name,
    "UID" => $db_user,
    "PWD" => $db_pwd,
	"CharacterSet" => "UTF-8",
    'ReturnDatesAsStrings'=>true);

if (isset($SUPPORT_MULTI_SUBNET_FAILOVER) && $SUPPORT_MULTI_SUBNET_FAILOVER == 'y')
	$connection_info['MultiSubnetFailover'] = 'Yes';

$SQLSRV_QUERY_TIME_OUT = array("QueryTimeout" => 6000); //!< Specify sqlsrv_query query execution timeout to fix 500 internal server error reported after 2mins. 

$companylogo = $app_php_script_loc . "adiha_pm_html/process_controls/company.png"; //!< Specifies the image location for company logo. Should be assigned as '$app_php_script_loc'.
//!< Example: adiha_pm_html/process_controls/company.png.

# Specifies the Product version.
$prod_ver = 'Version Label';

$hide_ps_logo_in_report = true; //!< Hides/Shows the Pioneer Solutions Logo in the report.
//!< Possible Values: true - Hides the logo. | false - Shows the logo.

$NOS_OF_RECENT_LOG = 10; //!< Specifies the Number of Recent Logs.
//!< Possible Values: 0+ as per the requirement.

$SPLIT_AFTER_COLUMNS = 5;
$SHOW_SUBBOOK_IN_BS = !empty($SHOW_SUBBOOK_IN_BS) ? $SHOW_SUBBOOK_IN_BS : 1;

$report_views_url_path = $app_php_script_loc . 'dev/shared_docs/report_manager_views'; //!<URL path for report_manager_views.

?>