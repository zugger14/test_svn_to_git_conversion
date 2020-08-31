<?php
/** 
 * All required include file included
 * All configuration setting loaded to session
 * @copyright Pioneer Solutions
 */

include 'lib/adiha_dhtmlx/adiha_php_functions.3.0.php';
include 'file_path.php';
include 'lib/adiha.xml.parser.1.0.php';
include_once 'security.ini.php';

sqlsrv_configure("WarningsReturnAsErrors", 0); //Added to resolve the issue of not grabbing the result set becasue of print statement in SQL.
sqlsrv_configure("ReturnDatesAsStrings", 1); //Added to resolve the issue that SQLSRV by default returns sql date data as php date object, but not as string. Adding this property date is returned as string.
$session_expired = false;

## Marked if the application is login with windows authentication or normal username checking the SERVER Variable
$is_win_auth_login = ($_SERVER['AUTH_USER'] != '' && $_SERVER['AUTH_TYPE'] == 'Negotiate') ? 1 : 0;

if (($app_user_name ?? '') == '') {
    $token = isset($_COOKIE["_token"]) ? $_COOKIE["_token"] : '';
    if ($token != '') {
        ## Get the app user name by validating the token
        $token_data = verify_token($token);
        if ($token_data['response_code'] == 200) {
            $app_user_name = $token_data["username"];
            ## These new databse server name and database name will be used in database connection
            $new_db_server_name = $token_data["db_servername"];
            $new_db_name = $token_data["database_name"];
            $new_db_user = $token_data["db_user"];
            $new_db_pwd = $token_data["db_pwd"];
        } else {
            $session_expired = true;
        }
    } else {
        $session_expired = true;
    }
}

if ($session_expired) {
    close_inactive_window();
}

if (isset($is_auth_route)) {
    $session_id = session_id();
    return;
}

if ($session_expired == false) {
    require_once $config_file;
}

 
if (isset($display_error)) {
    ini_set('display_errors',$display_error);
}

if (isset($error_reporting)) {
    ini_set('error_reporting',$error_reporting);
}

## Prevent sqlsrv connect errors in TRMSession.php and adiha xml parser where user cannot be found hence db cannot be resolved during cloud login
if (isset($CLOUD_MODE) && $CLOUD_MODE && !@sqlsrv_connect($db_servername, $connection_info)) {
    $msg = 'The username does not exist either in application or in database.';
    echo "<Script>window.location.href='../../index_login_farrms.php?loaded_from=$farrms_client_dir&flag=login&message=".$msg."'</script>";
    die;
}

include( $farrms_root_dir . "/" . $farrms_root . "/adiha.php.scripts/autoloader.php");

# Autoloader will autoload the class file with the name 
# same as the class name by resolving path with 
# the base path directory and the lib path
autoloader(array(array(
    'basepath' => $farrms_root_dir . "\\" . $farrms_root . "\adiha.php.scripts\components"
)));

autoloader(array(
    'lib\adiha_dhtmlx\AdihaClasses',
    ''
));

/*
New change requires session.auto_start to be On in php.ini, which takes default FILE handler.
Need to close it before changing the handler to USER (DB based).
*/
if (ini_get('session.auto_start') == 1) {
    session_write_close();
}

require_once 'TRMSession.php';

/*TODO: No effect of it has been set except a cookie will be set with db name and session id as value. 
But session_id() is returning value of PHPSESSID instead of this cookie with db name.
Normally both cookie will have same value and above statement was tested by altering PHPSESSID cookie value manually.
*/
session_name($database_name);

/*
Sesssion id is initially created by server on first unique request and set as browser cookie (PHPSESSID).
We noticed this cookie wasn't destroyed even when calling session_write_close allowing us to re-use
same session id even when switching session handler from file to user (db based). Otherwise, it would
generate new session_id every time upon starting session, causing to break the application.
*/
session_start();
if (!isset($_COOKIE['session_id'])) {
    $session_id = session_id();
}
$session_true = 1;

## Merge old session data created during Azure AD authentication
if (isset($AZURE_AD)) {
    $_SESSION = array_merge($_SESSION, $AZURE_AD);
}

/* 
Do not allow application access when user has logged in using Azure AD authentication and token data "uti" does not match 
with session variable "uti" which is set after validating access token during login. This step is done to add a security layer.
*/
if (isset($_SESSION['uti']) && (!isset($token_data["uti"]) || ($_SESSION['uti'] !== $token_data["uti"]))) {
    $session_expired = true;
}

## Application Default Theme
if (!isset($_SESSION['client_date_format']) || $_SESSION['client_date_format'] == '') {
    $xml_default_theme = "EXEC spa_application_version @flag = 'k'";
    $def = readXMLURL2($xml_default_theme);
    $default_theme = $def[0]['default_theme'] ?? '';
    $version_theme_name = $def[0]['version_theme_name'] ?? '';
    $_SESSION['default_theme_name'] = $default_theme;
    $_SESSION['version_theme_name'] = $version_theme_name;
} else {
    $default_theme = $_SESSION['default_theme_name'];
    $version_theme_name = $_SESSION['version_theme_name'];
}

## Added to avoid querying the db if user doesn't exists in Database
if (!@sqlsrv_connect($db_servername, $connection_info)) {
    $msg = 'The username does not exist either in application or in database.';
    echo "<Script>window.location.href='../../index_login_farrms.php?loaded_from=$farrms_client_dir&flag=login&message=".$msg."'</script>";
    if (isset($check_cloud_mode_login) == 1) return; else die();
} else if (isset($check_cloud_mode_login) == 1 && (!empty($AZURE_AD) || $is_win_auth_login == 1)) {
    ## In case of AZURE/Windows login no need of configurations from database.
    ## Not blocked in SQL Authentication login because change password form requires locales from database.
    return;
}

# Restrict user to access application if temp_pwd is set to true and user tries to access application without changing password and directly entering main menu url
# Exception in windows authentication mode
if (isset($_SESSION['temp_pwd']) && $_SESSION['temp_pwd'] == 'y' && $pwd_expire_not_apply_to_user != $app_user_name && !$is_win_auth_login) {
    $redirect = true;
    # Allow accessing whitelisted pages like change pwd page, form process page, session destroy pages only.
    $white_listed_pages = array(
        strtolower($app_adiha_loc . 'adiha.html.forms/_users_roles/maintain_users/maintain.pwd.php'),
        strtolower($app_adiha_loc . 'adiha.html.forms/_users_roles/maintain_users/pwd_user_roles.php'),
        strtolower($app_adiha_loc . 'adiha.php.scripts/form_process.php?_csrf_token=' . $_COOKIE['_csrf_token']),
        strtolower($app_adiha_loc . 'main.menu/scripts/auth.otp.php'),
        strtolower($app_adiha_loc . 'adiha.php.scripts/spa_session_destroy.php'),
    );
    
    foreach($white_listed_pages as $page) {
        if (strpos($page, strtolower($_SERVER['PHP_SELF']))) {
            $redirect = false;
            break;
        }
    }

    if ($redirect) {
        ob_clean();
        if($CLOUD_MODE == 0) {
            $redirect_url = substr($app_php_script_loc, 0, strpos($app_php_script_loc, 'trm')) . $farrms_client_dir;
        } else {
            $redirect_url = '/';
        }
        header("Location: $redirect_url");
        die;
    }
}

if (!isset($_SESSION['session_id'])) {
    $_SESSION['session_id'] = $session_id;
} else {
	if (($_SESSION['session_id']) != $session_id) {
		$session_true = 0;
        $session_expired = true;
    }
}

if ($enable_session === true) {
    if ($session_expired === false && !isset($check_cloud_mode_login)) {
    	$sess = "EXEC spa_trm_session @flag='p', @trm_session_id='". $session_id . "'";
		$session_arr = readXMLURL2($sess);

		$session_time = $session_arr[0]['session_time'] ?? '';

		if ($session_time == 99999999) {
			$session_true = 0;
        	$session_expired = true;
			
            // unset all cookies
            if (isset($_SERVER['HTTP_COOKIE'])) {
                $cookies = explode(';', $_SERVER['HTTP_COOKIE']);
                foreach($cookies as $cookie) {
                    $parts = explode('=', $cookie);
                    $name = trim($parts[0]);
                    // unset all cookies except MFAID else OTP popup will appear on every login
                    if (strpos($name, 'MFAID') === false) {
                        set_cookie($name, '', time()-42000, true, '');
                        set_cookie($name, '', time()-42000, true, '/');
                    }
                }
            }

			session_destroy();
		}
    }
    
    if ($session_expired === true) {
        $app_user_name = '';
    }

    if ($app_user_name == "") {
        if ($CLOUD_MODE == 1) {
            $session_expired_url = get_request_protocol() . '://' . $_SERVER['SERVER_NAME'] . "?action=session_timeout";
        } else {
            $session_expired_url = $app_adiha_loc . "index_login_farrms.php?loaded_from=" . $farrms_client_dir . "&flag=login&session_state=timeout&message=Session timeout , Please login again";
        }
        $session_expired_message = 'FARRMS\\n_____________________________________________________\\n\\nSession has expired, please re-login, At this time all inactive windows will be closed. \\n\\n_____________________________________________________';

        if (isset($catch_session_expire)) {
            ## $catch_session_expire is set from form_process.php
            ## Added this to catch session expire when doing network request using js function adiha_post_data
            ob_end_clean();
            $return["session_expired_url"] = $session_expired_url;
            $return["session_expired_message"] = $session_expired_message;
            echo json_encode($return);
        } else {
            // Normal page load
            echo "<script>
                    if (!top.JS_SESSION_EXPIRE) {
                        top.JS_SESSION_EXPIRE = true;
                        alert('" . $session_expired_message . "');
                        top.location.href='" . $session_expired_url . "';
                    }
              </script>";
        }
        die();
    }
}

if (isset($_SESSION['userTimeZone']) && $_SESSION['userTimeZone'] != '') {
    date_default_timezone_set($_SESSION['userTimeZone']);
    $default_time_zone = $_SESSION['userTimeZone'];
} else {
    $default_time_zone = date_default_timezone_get();
    date_default_timezone_set($default_time_zone);
}
		
if (!isset($_SESSION['clientImageFile']) || $_SESSION['clientImageFile'] == '') {
    $client_image = "clientImageFile.jpg";
    $_SESSION["clientImageFile"] = $client_image;
}     

$url_config = str_replace("\\", "\\\\", $config_file);

## GO BACK if current directory is lib
$cur_dir = getcwd();

if (strstr($cur_dir, '\lib') != false || strstr($cur_dir, '/lib') != false) {
	chdir('../');
}

$product_name = $farrms_product_name;

$english_language_id = 101600;
/*
 * Loads resources for the language selected by the user.
 */
function load_i18n() {
    // $LANGUAGE holds old language value
    global $LANGUAGE, $english_language_id;

    $lang_map_index = 'lang_map';
    $new_lang_id = $_SESSION['lang'] ?? $english_language_id;

    // Load language locales if language selection is changed
    if (!empty($new_lang_id) && $new_lang_id != $LANGUAGE) {
        // Fetch new language locales if language other than english is selected
        if ($new_lang_id != $english_language_id || !isset($_SESSION[$lang_map_index])) {
            $locales_spa = "EXEC spa_locales @language_id = " . $new_lang_id;
            $locales_array = readXMLURL2($locales_spa);

            $lang_map = $locales_array[0][$lang_map_index];
            $_SESSION[$lang_map_index] = $lang_map;
        } else {
            // Unset language locales, no locales in case of English
            if (isset($_SESSION[$lang_map_index])) {
                unset($_SESSION[$lang_map_index]);
            }
        }
    }
}

## Load the configurations needed in run time from db (UI Settings, SSRS Settings, Dynamic Calendar Dropdown and Date Format)
if (!isset($_SESSION['client_date_format']) || $_SESSION['client_date_format'] == '') {
    $run_time_configs_spa = "EXEC spa_company_info @flag = 'a', @app_user_name = '". $app_user_name . "'";
    $config = readXMLURL2($run_time_configs_spa);
    
    $_dropdown = array();
    $_day_adjustment_dropdown = array();
    $option = '{text:"", value:""}';
    array_push($_dropdown, $option);
    array_push($_day_adjustment_dropdown, $option);

    foreach ($config as $value) {
        if ($value['category'] == 'farrms_client_configs') {
            $config_array[$value['category_code']] = $value['category_value'];
        } else if ($value['category'] == 'ui_settings') {
            $template_settings_array[$value['category_code']] = $value['category_value'];
        } else if ($value['category'] == 'dynamic_date_options') {
            $option = '{text:"' . addslashes($value['category_code']) . '", value:"' . addslashes($value['category_value']) . '"}';
            array_push($_dropdown, $option);
        }
    }

    ##Added dropdown option for Date day_adjustment Dropdown Options by adding for loop as to fix sorting issue when loaded from database
    for ($i = -60; $i <= 60; $i++) {
        if ($i != 0) {
            $day_adjustment_option = '{text:"' . $i . '", value:"' . $i . '"}';
            array_push($_day_adjustment_dropdown, $day_adjustment_option);
        }
    }
    ##SaaS module type
	if ($config_array['saas_module_type'] != '' && $CLOUD_MODE == 1) {
		$_SESSION["farrms_module"] = $config_array['saas_module_type'];
	}
    
    ## Date Format
    if (!empty($config_array['date_format'])) {
        $_SESSION['client_date_format'] = $_SESSION['date_format'] = $config_array['date_format'];
        $client_date_format = $config_array['date_format'];
    }

    if (!empty($config_array['dhtmlx_date_format'])) {
        $_SESSION['dhtmlx_date_format'] = $config_array['dhtmlx_date_format'];
        $date_format = $config_array['dhtmlx_date_format'];
    }

    ## SSRS Configs
    $ssrs_config['UID'] = $config_array['report_server_domain'] . '\\' . $config_array['report_server_user_name'];
    //$ssrs_config['PASWD'] = $config_array['report_server_password'];
    $ssrs_config['SERVICE_URL'] = $config_array['report_server_url'];
    $ssrs_config['DATA_SOURCE'] = $config_array['report_server_datasource_name'];
    $ssrs_config['REPORT_TARGET_FOLDER'] = $config_array['report_server_target_folder'];
    
    $_SESSION['SSRS_CONFIG'] = $ssrs_config;

    ## UI Settings
    $_SESSION['ui_settings'] = $template_settings_array;
    $ui_settings = $_SESSION['ui_settings'];

    ## Dynamic Date Dropdown Options
    $_dropdown_string = "[" . implode(',', $_dropdown) . "]";
    $_SESSION['dynamic_date_options'] = $_dropdown_string;
    $dynamic_date_options = $_SESSION['dynamic_date_options'];


    ## Dynamic Date day_adjustment Dropdown Options
    $_day_adjustment_dropdown_string = "[" . implode(',', $_day_adjustment_dropdown) . "]";
    $_SESSION['day_adjustment'] = $_day_adjustment_dropdown_string;
    $day_adjustment = $_SESSION['day_adjustment'];

    ## Farrms Client Configs
    $farrms_client_configs['global_number_format'] = $config_array['global_number_format'];
    $farrms_client_configs['global_price_format'] = $config_array['global_price_format'];
    $farrms_client_configs['country'] = $config_array['country'];
    $farrms_client_configs['phone_format'] = $config_array['phone_format'];
    $farrms_client_configs['global_decimal_separator'] = $config_array['global_decimal_separator'];
    $farrms_client_configs['global_group_separator'] = $config_array['global_group_separator'];
    $farrms_client_configs['company_code'] = $config_array['company_code'];
    $farrms_client_configs['global_number_rounding'] = $config_array['global_number_rounding'];
    $farrms_client_configs['global_price_rounding'] = $config_array['global_price_rounding'];
    $farrms_client_configs['global_amount_rounding'] = $config_array['global_amount_rounding'];
    $farrms_client_configs['global_volume_rounding'] = $config_array['global_volume_rounding'];
    $farrms_client_configs['global_amount_format'] = $config_array['global_amount_format'];
    $farrms_client_configs['global_volume_format'] = $config_array['global_volume_format'];
    $_SESSION['farrms_client_configs'] = $farrms_client_configs;

    ## User Language
    $LANGUAGE = $_SESSION['lang'] ?? $english_language_id;
    $user_selected_lang = $config_array['language'] ?? $english_language_id;
    $_SESSION['lang'] = $user_selected_lang;
} else {
    ## Date Format
    if (isset($_SESSION['client_date_format'])) {
        $client_date_format = $_SESSION['client_date_format'];
    } else {
        //set US date format as default
        $client_date_format = 'mm/dd/yyyy';
    }
    
    if (isset($_SESSION['dhtmlx_date_format'])) {
        $date_format = $_SESSION['dhtmlx_date_format'];
    } else {
        $date_format = '%Y-%m-%d';
    }
    ## SSRS
    $ssrs_config = $_SESSION['SSRS_CONFIG'];
    ## UI Settings
    $ui_settings = $_SESSION['ui_settings'];
    ## Dynamic Date Dropdown Options
    $dynamic_date_options = $_SESSION['dynamic_date_options'];

    ## Dynamic Date day_adjustment Dropdown Options
    $day_adjustment = $_SESSION['day_adjustment'];

    ## Farrms Client Configs
    $farrms_client_configs = $_SESSION['farrms_client_configs'];

    ## Application Language
    $LANGUAGE = $_SESSION['lang'];
}

if (!isset($_SESSION['dynamic_date_adj_type_options'])  || $_SESSION['dynamic_date_adj_type_options'] == '') {
    $sp_date_options = "EXEC spa_StaticDataValues @flag = 'h', @type_id = 106400";
    $date_options = readXMLURL($sp_date_options);
    $_dropdown = array();
   // $option = '{text:"", value:"", state:""}';
    //array_push($_dropdown, $option);

    for ($i = 0; $i < sizeof($date_options); $i++) {
        $option ='{text:"' . addslashes($date_options[$i][1]) . '",value:"' . addslashes($date_options[$i][0]) . '"';
        
        $option .= '}';
        array_push($_dropdown, $option);
    }

    $_dropdown_string = "[" . implode(',', $_dropdown) . "]";

    $_SESSION['dynamic_date_adj_type_options'] = $_dropdown_string;
    $dynamic_date_adj_type_options = $_SESSION['dynamic_date_adj_type_options'];
} else {
    if (isset($_SESSION['dynamic_date_adj_type_options'])) {
        $dynamic_date_adj_type_options = $_SESSION['dynamic_date_adj_type_options'];
    }
}

if (!isset($_SESSION['farrms_module'])) $_SESSION["farrms_module"] = $module_type;
if (!isset($_SESSION['config_file'])) $_SESSION["config_file"] = $config_file;
if (!isset($_SESSION['farrms_client_dir'])) $_SESSION["farrms_client_dir"] = $farrms_client_dir;

# Load i18n
load_i18n();

//If saas module type is defined in connecton_string then reset php variable $module_type with it.
$module_type = $_SESSION["farrms_module"];

# Global Number format for numeric fields
$GLOBAL_NUMBER_FORMAT = $global_number_format = $farrms_client_configs['global_number_format'];

# Global Currency format for price fields
$GLOBAL_PRICE_FORMAT = $global_price_format = $farrms_client_configs['global_price_format'];

# Global amount format for numeric fields
$GLOBAL_AMOUNT_FORMAT = $global_amount_format = $farrms_client_configs['global_amount_format'];

# Global volume format for price fields
$GLOBAL_VOLUME_FORMAT = $global_volume_format = $farrms_client_configs['global_volume_format'];

# Country - Used to localized the phone number format
$COUNTRY = $country = $farrms_client_configs['country'];

# Phone Format - Phone format for the country defined above - 0 - local format - 1 - international format
$PHONE_FORMAT = $phone_format = $farrms_client_configs['phone_format'];

# Decimal separator for formatting number
$DECIMAL_SEPARATOR = $global_decimal_separator = $farrms_client_configs['global_decimal_separator'];

# Thousand separator for formatting number
$GROUP_SEPARATOR = $global_group_separator = $farrms_client_configs['global_group_separator'];

# Company code used for user login name
$COMPANY_CODE = $farrms_client_configs['company_code'];

# Default rounding for grid columns
$GLOBAL_NUMBER_ROUNDING = $global_number_rounding = $farrms_client_configs['global_number_rounding'];

# Default rounding for grid columns of type price
$GLOBAL_PRICE_ROUNDING = $global_price_rounding = $farrms_client_configs['global_price_rounding'];

# Default rounding for grid columns of type volume
$GLOBAL_VOLUME_ROUNDING = $global_volume_rounding = $farrms_client_configs['global_volume_rounding'];

# Default rounding for grid columns of type amount
$GLOBAL_AMOUNT_ROUNDING = $global_amount_rounding = $farrms_client_configs['global_amount_rounding'];

global $farrms_module;
?>
<script language="JavaScript" src="<?php echo $app_php_script_loc; ?>components/jQuery/jquery-1.11.1.js"></script>

<script type="text/javascript">
    js_session_id = '<?php echo $session_id; ?>';
    js_config_file = '<?php echo $url_config; ?>';    
    cookie_expire_date = '<?php echo $COOKIE_EXPIRE_DATE; ?>';
    js_user_name = '<?php echo $app_user_name; ?>';
    js_farrms_module = '<?php echo $farrms_module; ?>';
    js_php_path= '<?php echo $app_php_script_loc; ?>';
    var farrms_client_dir = '<?php echo $farrms_client_dir;?>';
    var cloud_mode = '<?php echo $CLOUD_MODE;?>';
    var user_date_format = '<?php echo $date_format;?>';
    var default_theme = '<?php echo $default_theme; ?>';
    var version_theme_name = '<?php echo $version_theme_name; ?>';

    //Dynamic Date Options
    var dynamic_date_options = <?php echo $dynamic_date_options; ?>;

    //Dynamic Date day adjusment Options
    var day_adjustment = <?php echo $day_adjustment; ?>;
    
    var dynamic_date_adj_type_options = <?php echo $dynamic_date_adj_type_options; ?>;
    //UI Settings
    var ui_settings = $.parseJSON('<?php echo json_encode($ui_settings); ?>');
    // Language resources
    var lang = '<?php echo $_SESSION['lang']; ?>';
    var lang_locales = '';
    
    if (lang != 101600 && lang != '') {
        lang_locales = $.parseJSON('<?php echo $_SESSION['lang_map'] ?? '{}'; ?>');
    }
    
    if (typeof dhx_wins == 'undefined') {
        var dhx_wins;
    }

    if (typeof helpfile_window == 'undefined') {
        var helpfile_window;
    }
</script>
<script language="JavaScript" src="<?php echo $app_php_script_loc; ?>components/lib/adiha_dhtmlx/adiha_js_functions.3.0.js"></script>