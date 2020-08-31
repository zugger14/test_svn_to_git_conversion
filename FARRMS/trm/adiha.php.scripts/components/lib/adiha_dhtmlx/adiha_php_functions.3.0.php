<?php

/**
 * Get Security state.
 * @return Array of boolean value.
 */
function build_security_rights() {
    $arr_func_id = func_get_args();
    $list = implode(',', $arr_func_id);
    $sp_permission = "EXEC spa_get_permissions @function_ids='" . $list . "'";
    $permissions = readXMLURL2($sp_permission);

    $arr_permission = explode(',', $permissions[0]['permission_string']);
    $arr_return_rights = array();

    if (is_array($arr_permission)) {
        foreach ($arr_permission as $value) {
            $bool = ($value == 'y') ? true : false;
            array_push($arr_return_rights, $bool);
        }
    }

    return $arr_return_rights;
}

/**
 * Executes the given url and returns json to be used for grid combo.
 * @param  Mixed   $sp_url        Url to be executed
 * @param  Integer $value_index   Index of the value
 * @param  Integer $text_index    Index of the text
 * @return dropdown options with value in json format to be used in combo attached to grid.
 */
function adiha_grid_dropdown($sp_url, $value_index, $text_index) {
    $arr = readXMLURL($sp_url);
    $_dropdown = array();
    $option = '';
    for ($i = 0; $i < sizeof($arr); $i++) {
        $_dropdown[$i][0] = $arr[$i][$value_index];
        $_dropdown[$i][1] = $arr[$i][$text_index];
    }
    return json_encode($_dropdown);
}

/**
 * [adiha_form_dropdown description]
 * @param  Mixed    $sp_url       Url to be executed
 * @param  Integer  $value_index  Index of the value
 * @param  Integer  $text_index   Index of the text
 * @param  Boolean  $blank_status True/False if true add blank
 * @param  Integer  $state_index  Index
 * @return Dropdown options with value in object format to be used in combo attached to grid.
 */
function adiha_form_dropdown($sp_url, $value_index = 0, $text_index = 1, $blank_status = false, $state_index = '') {
    $arr = readXMLURL($sp_url);
    $_dropdown = array();
    $option = '';
    if($blank_status==true)
        $option.='{value:"0",text:" "},';
    for ($i = 0; $i < sizeof($arr); $i++) {
        if ($i > 0)
            $option.=',';
                    
        $option.='{value:"' . $arr[$i][$value_index] . '",text:"' . $arr[$i][$text_index] . '"';
        
        if ($state_index != '')
            $option .= ' ,state:"' . $arr[$i][$state_index] . '"';        
        
        if($i>0)
            $option.='}';
        else
             $option.=',selected: true}';
    }
    $_dropdown_string = "[" . $option . "]";
    return ($_dropdown_string);
}

/**
 * Parse the unnecessary text from the tab json to prepare tab in dhtmlx tab.
 * @param  Mixed $tab_json Json of the tab returned by spa
 * @return Parsed json of the tab without any unnecessary text in each tab text.
 */
function parse_tab_json_id($tab_json) {
    $temp_array = array();
    $temp_array1 = array();
    $temp_array2 = array();
    $temp_array = (explode(",", $tab_json));
    $i = 0;
    foreach ($temp_array as $temp) {
        $temp_array1 = (explode(":", $temp));
        $j = 0;
        foreach ($temp_array1 as $temp1) {
            $temp1 = str_replace(' ', '', $temp1);
            $temp1 = str_replace("]", "", $temp1);
            $temp1 = str_replace("}", "", $temp1);
            $temp1 = str_replace("{", "", $temp1);
            $temp1 = str_replace('"', '', $temp1);
            $temp1 = preg_replace('/\s+/', '', $temp1);
            $temp_array2[$i][$j] = $temp1;
            $j++;
        }
        $i++;
    }
    $html_string = '[';
    $i = 0;
    foreach ($temp_array2 as $value) {
        if ($value[0] == 'id') {
            if ($i > 0)
                $html_string.=',';
            $html_string.= '{id:"' . $value[1] . '",';
        }
        else if ($value[0] == 'text') {
            $text = substr($value[1], 0, -8);
            $html_string.= 'text:"' . $text . '",';
        } else if ($value[0] == 'active') {
            $html_string.= 'active:"' . $value[1] . '"}';
        }
        $i++;
    }
    $html_string.=']';
    return $html_string;
}

/**
 * Executes the given url and returns json to be used for form combo.
 * @param  Mixed   $sp_url      Url to be executed
 * @param  Integer $value_index Index of the value
 * @param  Integer $text_index  Index of the text
 * @return Dropdown options with value in object format to be used in combo attached to grid.
 */
function json_form_dropdown($sp_url, $value_index, $text_index) {
    $arr = readXMLURL($sp_url);
    $_dropdown = array();
    $option = '{options:[';
    for ($i = 0; $i < sizeof($arr); $i++) {
        $_dropdown[$i][0] = $arr[$i][$value_index];
        $_dropdown[$i][1] = $arr[$i][$text_index];
        if ($i != 0)
            $option .=',';
        $option .= '{text:"' . $_dropdown[$i][1] . '",value:"' . $_dropdown[$i][0] . '"}';
    }
    $option .=']}';
    return ($option);
}

/**
 * Converts user date format to DHTMLX date format to feed to calendar (normally in custom form).
 * Logic is similar to SQL UDF FNAChangeDateFormat.
 * @return DHTMLX formatted date format (e.g. %Y/%m%d)
 */
function get_dhtmlx_date_format() {   
    //take client date format from global variable
    global $date_format;
    return $date_format;
}

/**
 * [explode_key_val_array description]
 */

function explode_key_val_array(&$item1, $key, $prefix) {
        $item1 = "$key$prefix$item1";
    }

/**
 * Description  : Function assumes that the date passed is in user's date format as set in region in maintain users module.
 * 
 * Purpose      : Convert Date Time from client date format to standard date.
 *              E.g.
 *              + dd/mm/yyyy to yyyy-mm-dd
 *              + mm/dd/yyyy to yyyy-mm-dd
 *              + dd-mm-yyyy to yyyy-mm-dd
 *              + mm-dd-yyyy to yyyy-mm-dd
 *              + dd.mm.yyyy to yyyy-mm-dd
 *              + mm.dd.yyyy to yyyy-mm-dd
 * @param Mixed $dateTime Datetime to be converted
 * @return Date in standard format.
 */
function getStdDateFormat($dateTime) {
    global $client_date_format;
    $dateformatString = $client_date_format;
    //$dateformatString = str_replace('%j', 'dd', str_replace('%n', 'mm', str_replace('%Y', 'yyyy', '%n/%j/%Y')));

    if (strpos($dateformatString, ' ')) {
        list($date, $time) = explode(' ', $dateTime);
    } else {
        $date = $dateTime;

    }

    if (strpos($dateformatString, '/')) {
        $dateFormat = explode('/', $dateformatString);
        $date = explode('/', $date);
    } elseif (strpos($dateformatString, '.')) {
        $dateFormat = explode('.', $dateformatString);
        $date = explode('.', $date);
    } else {
        $dateFormat = explode('-', $dateformatString);
        $date = explode('-', $date);
    }
    
    for ($i = 0; $i < count($dateFormat); $i++) {
        if ($dateFormat[$i] == 'mm') {
            $mm = $date[$i];
            $mm = strlen($mm) < 2 ? '0' . $mm : $mm;
        } elseif ($dateFormat[$i] == 'dd') {
            $dd = $date[$i];
            $dd = strlen($dd) < 2 ? '0' . $dd : $dd;
        } elseif ($dateFormat[$i] == 'yyyy') {
            $yyyy = $date[$i];
        }
    }

    return $yyyy . '-' . $mm . '-' . $dd;
}

/**
 * Adds Date.
 * @param Datetime  $date Given Date
 * @param Integer   $day  Additional day
 * @param Integer   $mth  Additional month
 * @param Integer   $yr   Additional year
 */
function add_date($date = NULL, $day = 0, $mth = 0, $yr = 0) {
    $cd = strtotime($date);
    $newdate = date('Y-m-d', mktime(date('m',$cd)+$mth,
                                    date('d',$cd)+$day, 
                                    date('Y',$cd)+$yr
                                    )
                );
    return $newdate;
}

/**
 * Builds the Parameter XML for excel addin filter [Equivalent function build_excel_parameters in adiha_js_functions.3.0.js].
 * @param  Array $data Filters information
 * @return String Parameters XML.
 */
function build_excel_parameters($data) {
    $filter_in_xml = '<Parameters>';

    foreach ($data as $record) {
        $dyn_cal_val = explode('|', $record['filter_value']);

        if (sizeof($dyn_cal_val) > 1 && $record['widget_id'] == '6') { // case for type dynamic date and dynamic date selected
             /* added as the new formate doesnot contain static date as first i.e 45606|0|106400|n*/
            array_unshift($dyn_cal_val, "");
        } else if ($record['widget_id'] == '6' && sizeof($dyn_cal_val) == 1) {  // case for type static date and static date selected
            /*added as the new formate doesnot contains dynamic date part when static date is selected */
            array_push($dyn_cal_val, 0, 0, "", "n");
        }
        /*
            # Modified to not build XML for those fields which have null values ...
        */
        //if (($dyn_cal_val[0] != '' || $dyn_cal_val[0] != null) || (sizeof($dyn_cal_val) > 1 && ($dyn_cal_val[1] != '' || $dyn_cal_val[1] != null ))) {
            $filter_in_xml .='
            <Parameter>
                <Name>' . $record['filter_name'] . '</Name>
                <Value>' . ($record['widget_id'] == '6' ? $dyn_cal_val[0] : str_replace(',', '!', ($record['filter_value']))) . '</Value>
                <DisplayLabel>' . $record['filter_display_label'] . '</DisplayLabel>
                <DisplayValue>' . ($record['widget_id'] == '6' ? $dyn_cal_val[0] : $record['filter_display_value']) . '</DisplayValue>'
                .
                ($record['widget_id'] == '6' ?
                '
                <OverwriteType>' . $dyn_cal_val[1] . '</OverwriteType>
                <AdjustmentDays>' . $dyn_cal_val[2] . '</AdjustmentDays>
                <AdjustmentType>' . $dyn_cal_val[3] . '</AdjustmentType>
                <BusinessDay>' . $dyn_cal_val[4] . '</BusinessDay>
                '
                : ''
                )
                .
            '
            </Parameter>';
        //}
    }

    $filter_in_xml .= '</Parameters>';

    return $filter_in_xml;
}


/* Moved from adiha_php_function.php */

/**
 * Authenticates application user. Also supports authenticating with LDAP protocol.
 *
 * @param mixed $username Application user
 * @param mixed $password Application user password
 * @param mixed $ip IP of application user computer
 * @param mixed $host Host
 * @param mixed $domain_name Domain name
 * @return Status of the user
 *
 */
function checkUser($username, $password, $ip, $host, $domain_name) {
    global $app_php_script_loc, $status, $enable_ldap_authentication, $db_pwd, $pwd_expire_not_apply_to_user, $farrms_client_dir;
    $new_pwd = urlencode($password);
    $ldap_valid = 1;

    //TODO: $pwd_expire_not_apply_to_user always holds farrms_admin and in case of win auth, this check may be by passed.
    if ($enable_ldap_authentication == true && $pwd_expire_not_apply_to_user != $username) {
        $ldap_valid = checkLDAPUser($username, $new_pwd, $domain_name);

        if ($ldap_valid == 1) {
            $msg = 'Your LDAP verification is invalid, Please check your username and password.';
            echo "<Script>window.location.href='../index_login_farrms.php?loaded_from=$farrms_client_dir&message=" . $msg .
            "'</script>";
            die();
        }
    }

    $xmlFile = $app_php_script_loc . "spa_is_valid_user.php?user_login_id=$username&user_pwd=$new_pwd&system_address=$ip&system_name=$host&__user_name__=$username&ldap_valid=$ldap_valid";
    $parser = new ADIHAXMLParser();
    $recordset = $parser->readXML($xmlFile);
    return $recordset;
}

/**
 * Authenticates an LDAP User(Lightweight Directory Access Protocol).
 *
 * @param mixed $username Application user name
 * @param mixed $password Application user password
 * @param mixed $domain_name Domain name
 * @return 1 if success or 0 if fail to login
 */
function checkLDAPUser($username, $password, $domain_name) {
    global $ldapconfig;
    $ldapServer = $domain_name;
    $ds = ldap_connect($ldapServer) or die('Could not connect to LDAP server.');
    $ldapBind = @ldap_bind($ds, $username . "@$ldapServer", $password);

    if (!$ldapBind) {
        return 1;
    } else {
        return 0;
    }
}

function delete_key_by_prefix($prefix, $encode_key=false) {
    global $ENABLE_DATA_CACHING;
    $data_cache = new DataCache();
    if ($ENABLE_DATA_CACHING && $data_cache->is_cache_server_exists()) {
        $prefixes = explode(',',$prefix);
        //$prefixes = preg_filter('/$/', '_', $prefixes);
        $deleted_status = $data_cache->delete_key_by_prefix($prefixes,$encode_key);
        
        //Close connection.
        $data_cache->close_conn();
        return $deleted_status;
   } else {
        return 'Cache server connection failed.';
   }
}

/**
 * Returns HTTP request protocol (http or https)
 */
function get_request_protocol() {
    $isSecure = false;
    if (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on') {
        $isSecure = true;
    }
    elseif (!empty($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https' || !empty($_SERVER['HTTP_X_FORWARDED_SSL']) && $_SERVER['HTTP_X_FORWARDED_SSL'] == 'on') {
        $isSecure = true;
    }
    
    return ($isSecure ? 'https' : 'http');
}

/**
 * Close window cookies not found due to session destroy. It can be due to user logout or inactive.
 */
function close_inactive_window() {
    $session_expired_message = 'FARRMS\\n_____________________________________________________\\n\\nSession has expired. You need to logon again. At this time all inactive windows will be closed. \\n\\n_____________________________________________________';
   
    echo "<script>
            alert('" . $session_expired_message ."');
            window.top.close();
            /* if window does not close it means application is not opened in popup window which means it is running in SaaS mode so script below makes sure user is redirected back to login page 
            */
            if (window.opener == null) {
                window.top.location.href = '/?action=session_timeout';
            }
            
      </script>";
    die;
}

/**
 * Executes the given url or xml.
 * @param mixed $xmlFile Url or xml to be executed
 * @param integer $stripSlashes condition for slashes strip or not(1 refers stripes slashes).
 * @param array $param_values Parameters value to bind
 * @return array set[index array] generated from the executed url or xml
 */
function readXMLURL($xmlFile, $stripSlashes = 1, $param_values = array()) {
    $parser = new ADIHAXMLParser();
    $recordset = $parser->readXML($xmlFile, 0, $stripSlashes, $param_values);
    return $recordset;
}

/**
 * Executes the given url or xml.
 * @param mixed $xmlFile Url or xml to be executed
 * @param boolean $preserve_col_name show column name
 * @param array $param_values Parameters value to bind
 * @return array set[associative array] generated from the executed url or xml
 */
function readXMLURL2($xmlFile, $preserve_col_name = false, $param_values = array()) {
    $parser = new ADIHAXMLParser();
    $recordset = $parser->readXMLFunction($xmlFile, $preserve_col_name, $param_values);
    return $recordset;
}

/**
 * This is similar to readXMLURL2. This function provides option to cache data.
 */
function readXMLURLCached($xmlFile, $preserve_col_name = false, $key_prefix = '', $key_suffix = '', $append_user_name = true, $expiry_time=0, $data_source = 'general', $param_values = array()) {
    $parser = new ADIHAXMLParser();
    $recordset = $parser->readXMLFunctionCached($xmlFile, $preserve_col_name, $key_prefix, $key_suffix, $append_user_name, $expiry_time, $data_source, $param_values);
    return $recordset;
}

//TODO check if this needed or not


/**
 * Escapes single quote (ie replace "'" with "/'").
 *
 * @param string $x string which need escaping single code
 */
function trace_php($x) {
    $x = str_replace("'", "/'", $x);
    echo "<script>trace('" . $x . "');</script>";
}

/**
 * Converts sql formate date into php formate date.
 * Example:
 *          - converts yyyy-mm-dd to Y-d-m<br>
 *          - converts yy-MM-DD to y-d-m<br>
 *          - converts YY-M-d to y-d-m<br>
 *          - e.t.c     *
 * @param string $dateformat Date Formate to be converted
 * @return Date either in (y-m-d) format or (Y-m-d) formate
 */
function setDateformat($dateformat) {
    //$dateformat=$dateformatString;
    $stmp = str_replace('mm', 'm', $dateformat);
    $stmp = str_replace('MM', 'm', $stmp);
    $stmp = str_replace('M', 'm', $stmp);
    $stmp = str_replace('dd', 'd', $stmp);
    $stmp = str_replace('DD', 'd', $stmp);
    $stmp = str_replace('D', 'd', $stmp);
    $stmp = str_replace('yyyy', 'Y', $stmp);
    $stmp = str_replace('yy', 'y', $stmp);
    return $stmp;
}


/**
 * Maintains the log of system accesses in table system_access_log.
 *
 * @todo The return from this function is not used
 * @todo return of the function is not clear
 *
 * @param mixed $username Application user
 * @param mixed $password Application user password
 * @param mixed $ip IP of application user computer
 * @param mixed $host Host Computer of the application user computer
 * @return Record set from executing the xmlfile
 */
function reporterror($username, $password, $ip, $host) {
    global $app_php_script_loc, $status;
    $sql = "EXEC spa_system_access_log 'i', '$username', '$ip', '$host', 'Invalid User Name'";
    $recordset = readXMLURL($sql);
    return $recordset;
}

/**
 * Replaces "." of date with "/".
 *
 * @param date $varDate Date of which "." should be replace by "/"
 * @return Date with "/"
 */
function convertDateDotToSlash($varDate) {
    $x = str_replace('.', '/', $varDate);
    return $x;
}


/**
 * Places string inside single quote if input string is not null.
 *
 * @param mixed $x Value which might need single quote
 * @return Single quoted value if input is not null or returns Null if input is empty
 */
function singleQuote($x) {
    if ($x == '') {
        $y = 'NULL';
    } elseif ($x != 'NULL') {
        $y = "'$x'";
    } else {
        $y = $x;
    }
    return $y;
}

/**
 * Not in used
 *
 * @todo Not in used
 *
 * @param mixed $dateformatString
 * @return
 */
function get_current_date($dateformatString) {
    $fromDate = adodb_date('m/d/Y');
    $dateformat = setDateformat($dateformatString);
    if ($fromDate != '') {
        $fromDate = adodb_date($dateformat, strtotime($fromDate));
    }
    return $fromDate;
}


/**
 * Gets the name of the file from the given url.
 *
 * @param mixed $url URL OR XLM File
 * @return File name
 */
function getFunctionName($url) {
    global $rootdir, $farrms_root;
    $sp_url = parse_url($url);
    $last_pos = strrpos($sp_url['path'], '/');

    /*
      if $url doesn't contain path (/), $last_pos will be false, which will be treated as 0.
      And substring operation adds 1 to this value, means the string will be chopped from index 1 but not 0
      Hence first character will be lost in such case. Using this change, it is possible to pass filename without
      passing the path for grid refresh as follows:
      var sp_url = 'spa_term_map_detail.php?flag=s'
      + '&term_code=' + term_code
      + '&term_start=' + term_start
      + '&term_end=' + term_end
      + '&use_grid_labels=true&' + getAppUserName();
     */
    if ($last_pos === false)
        $last_pos = -1;
    $file_name = substr($sp_url['path'], $last_pos + 1, -4);
    include_once $rootdir . '\\' . $farrms_root . '\\adiha.php.scripts\\components\\function_files\\' .
            $file_name . '.php';
    return $file_name;
}

/**
 * Shows the argument passed inside textarea with cols = 10 and rows = 15.
 *
 * @param mixed $var string to be shown in textarea with cols = 10 and rows = 15
 *
 */
function echo_text($var) {
    echo "<textarea cols=10 rows=15>$var</textarea>";
}

/**
 * Gets last day of previous month.
 *
 * @return Last day of previous month.
 */
function getLastOfPrevMonth() {
    $lastdate = mktime(0, 0, 0, date('m'), 0, date('Y'));
    $lastday = strftime('%d', $lastdate);
    $to_date = date('m/d/Y', mktime(0, 0, 0, date('m') - 1, $lastday, date('Y')));
    return $to_date;
}

/**
 * Gets current executing directory of scripts.
 *
 * Example: "http://server/FasTracker/adiha.php.scripts/components/farrms.config.ini.php" <br>
 *          will return "http://server/FasTracker/adiha.php.scripts/components/"
 * @return Current executing directory of scripts.
 */
function getCurrentDir() {
    $script_path = $_SERVER['SCRIPT_NAME'];
    return substr_replace($script_path, '', strripos($script_path, '/') + 1);
}


/**
 * Converts PHP Array to JSArray.
 *
 * @param mixed $js_arr_name Name of JSArray
 * @param mixed $arr_data Data of the array
 * @param string $array_index Array index with value
 * @return JS Array
 */
function php_array2js($js_arr_name, $arr_data, $array_index = '') {
    //$js_arr_name = 't_data_tmp_' . $index;
    if ($array_index == '') {
        $js_html = '<script>';
        $js_html .= ' var ' . $js_arr_name . ' = new Array();';

        for ($i = 0; $i < count($arr_data); $i++) {
            if (!is_array($arr_data[0])) {
                $js_html .= $js_arr_name . '[' . $i . "] = '" . $arr_data[$i] . "';";
            } else {
                $js_html .= $js_arr_name . '[' . $i . '] = new Array();';
                for ($j = 0; $j < count($arr_data[$i]); $j++) {
                    $js_html .= $js_arr_name . '[' . $i . '][' . $j . "] = '" . $arr_data[$i][$j] .
                            "';";
                }
            }
        }
        $js_html .= '</script>';
    } else {
        $js_html = '<script>';
        $js_html .= ' var ' . $js_arr_name . ' = new Array();';

        for ($i = 0; $i < count($arr_data); $i++) {
            $js_html .= $js_arr_name . '[' . $array_index[$i] . '] = new Array();';
            for ($j = 0; $j < count($arr_data[$array_index[$i]]); $j++) {
                $js_html .= $js_arr_name . '[' . $array_index[$i] . '][' . $j . "] = '" . $arr_data[$array_index[$i]][$j] .
                        "';";
            }
        }
        $js_html .= '</script>';
    }

    return $js_html;
}

/**
 * Converts PHP Array to JSArray using recursive function.
 *
 * @param mixed $array Php array
 * @param string $baseName JS array name
 * @return JS array
 */
function php_array2JS_recursive($array, $baseName) {
    //Write out the initial array definition
    echo ($baseName . " = new Array(); \r\n ");
    //Reset the array loop pointer
    reset($array);
    //Use list() and each() to loop over each key/value
    //pair of the array
    while (list($key, $value) = each($array)) {
        if (is_numeric($key)) {
            //A numeric key, so output as usual
            $outKey = '[' . $key . ']';
        } else {
            //A string key, so output as a string
            $outKey = "['" . $key . "']";
        }

        if (is_array($value)) {
            //The value is another array, so simply call
            //another instance of this function to handle it
            php_array2JS_recursive($value, $baseName . $outKey);
        } else {
            //Output the key declaration
            echo ($baseName . $outKey . ' = ');

            //Now output the value
            if (is_string($value)) {
                //Output as a string, as we did before
                echo ("'" . $value . "'; \r\n ");
            } else if ($value === false) {
                //Explicitly output false
                echo ("false; \r\n");
            } else if ($value === NULL) {
                //Explicitly output null
                echo ("null; \r\n");
            } else if ($value === true) {
                //Explicitly output true
                echo ("true; \r\n");
            } else {
                //Output the value directly otherwise
                echo ($value . "; \r\n");
            }
        }
    }
}



/**
 * Echos the array passed inside textarea in easily readable form (i.e. using print_r).
 *
 * @param mixed $arr Easily formated array
 *
 */
function echoTextarea($arr) {
    echo '<textarea>';
    print_r($arr);
    echo '</textarea>';
}

/**
 * Coverts date to array.
 *
 * @param date $x Date separated by '/' or '-' or '.'
 * @return Array having day, month and year as elements
 */
function getDateInArray($x) {
    global $dateformatString;
    if (strpos($dateformatString, '/') > 1) {
        $sp_arrayDate = explode('/', $x);
    } else if (strpos($dateformatString, '-') > 1) {
        $sp_arrayDate = explode('-', $x);
    } else if (strpos($dateformatString, '.') > 1) {
        $sp_arrayDate = explode('.', $x);
    }

    return $sp_arrayDate;
}

/**
 * Checks whether the object array passed is date or not.
 * @param mixed array $x
 * @return bool true/false
 */
function is_date($x) {
    $arr = getDateInArray($x);
    if (count($arr) == 3) {
        return true;
    } else {
        return false;
    }
}

/**
 * Converts SQL standard date format (yyyy-mm-dd) to US date format (mm/dd/yyyy)
 * @param    $date: date string SQL Standard date format
 * @returns string representing date in US format
 */

function convert_sql_date_to_US_format($date) {
    return date_format(date_create($date), "'" . $_SESSION['date_format'] . "'");
}

/**
 * Gets array[asofdateto, asofdatefrom].ss
 *
 * @param mixed $module_type Module type
 * @return Array[asofdateto, asofdatefrom]
 */
function getDefaultAsOfDate($module_type) { //returns array [asofdateto,asofdatefrom]
    $date = date('Y-m-d');
    $to_date = date('Y-m-d', strtotime(date('Y') . '-' . intval(date('m') - 1) . '-' . date('d')));

    if ($module_type == null || $module_type == '') {
        return array($date, $to_date);
    }

    $sql = "EXEC spa_default_asofdate 'f', '" . $module_type . "', NULL";
    $results = readXMLURL($sql);

    $as_of_date = $results[0][1];
    $as_of_date_from = $results[0][2];

    //if null asofdate.. return default one..
    if ($as_of_date == '') {
        return array($date, $to_date);
    }

    return array($as_of_date, $as_of_date_from);
}

/**
 * Gets current date according to user's timezone.
 *
 * @param string $flag Flag
 * @return Current date according to user's timezone
 */
function getCurrentDate($flag = 'c') {
    return date(clientDateFormat() . ($flag == 't' ? ' H:i:s' : ''));
}

/**
 * Removes trailing zeros of a number.
 *
 * @param mixed $x Number
 * @return Number without trailing zeroes
 */
function removetrailingzeroes($x) {
    if (is_numeric($x)) {
        $xval = explode('.', $x);
        if (sizeof($xval) > 1 && $xval[1] == '0') {
            $x2 = number_format($x, 2);
            $x2 = str_replace(',', '', $x2);
        } else if (sizeof($xval) > 1) {
            $xvar = rtrim(rtrim($xval[1], '0'), '.');
            $x2 = $xval[0] . '.' . $xvar;
        } else
            $x2 = $x;
        return $x2;
    } else {
        return $x;
    }
}

/**
 * Rounds up and formate the number.
 *
 * Example: 11304.42 to 11304.00
 *
 * @param mixed $x Number to be round and formate
 * @return Rounded and formated number
 */
function roundDecimalValues($x) {
    $xval = number_format(round($x, 2), 2, '.', '');
    return $xval;
}

/**
 * Added by Narendra to get date of first day or last day of next month
 * Date : 21th April 2010
 * $arg = f : date of first day of month
 * $arg = l : date of last day of month
 */
function get_first_or_last_day_of_next_month($arg = 'f') { // f = date of first day of month, l = date of last day of month
    list($yr, $mn, $dt) = explode('-', date('Y-m-d')); // separate year, month and date
    $timeStamp = mktime(0, 0, 0, $mn + 1, 1, $yr); //Create time stamp of the first day of next month.
    $firstDay = date('m/d/Y', $timeStamp); //get first day date of next month
    if (strtoupper($arg) == 'F') {
        return $firstDay;
    } else {
        list($y, $m, $t) = explode('-', date('Y-m-t', $timeStamp)); //Find the last date of the month and separating it
        $lastDayTimeStamp = mktime(0, 0, 0, $m, $t, $y); //create time stamp of the last date of next month.
        $lastDay = date('m/d/Y', $lastDayTimeStamp); // Find last day of the month
        return $lastDay;
    }
}

//================================================================
/** *********************************************************************
 * function isSQLDate
 *
 * boolean isSQLDate(string)
 * Summary: checks if a date is formatted correctly: yyyy-mm-dd (sql date)
 * ********************************************************************* */
function isSQLDate($i_sDate) {
    $blnValid = true;
    // check the format first (may not be necessary as we use checkdate() below)
    //if (!ereg("^[0-9]{4}-[0-9]{2}-[0-9]{2}$", $i_sDate)) {
    if (!preg_match('/^[0-9]{4}-[0-9]{2}-[0-9]{2}$/', $i_sDate)) {
        $blnValid = false;
    } else { //format is okay, check that days, months, years are okay
        $arrDate = explode('-', $i_sDate); // break up date by dash
        $intYear = $arrDate[0];
        $intMonth = $arrDate[1];
        $intDay = $arrDate[2];

        $intIsDate = checkdate($intMonth, $intDay, $intYear);

        if (!$intIsDate) {
            $blnValid = false;
        }
    } //end else

    return ($blnValid);
}

//end function isSQLDate


/** *********************************************************************
 * function getClientDateFormat
 *
 * getClientDateFormat(string)
 * PHP function to Convert given date to Client Date format
 * @param mixed $date Date to be converted
 * @return Date in client date format
 * ********************************************************************* */

function getClientDateFormat($date) {
    /*
    global $dateformatString;

    $adodbDate = new Date();
    $dateformat = setDateformat($dateformatString);
    $clientDate = $adodbDate->format($dateformat, $date);

    return $clientDate;
    */

    return $date;
}

/**
     * Created By   : Narendra Shrestha
     * Purpose      : Get date format used by client in php.
     *                e.g.
     *                d/m/Y, d-m-Y, m-d-Y e.tc.
     * Description  : Returns php date format used by client.
     */
function clientDateFormat() {
    global $client_date_format;
    $dateformatString = $client_date_format;

    if (strpos($dateformatString, '/')) {
        $dateFormat = explode('/', $dateformatString);
        $seperater = '/';
    } elseif (strpos($dateformatString, '.')) {
        $dateFormat = explode('.', $dateformatString);
        $seperater = '.';
    } else {
        $dateFormat = explode('-', $dateformatString);
        $seperater = '-';
    }
    if ($dateFormat[0] == 'mm') {
        $dateFormat[0] = 'm';
    } elseif ($dateFormat[0] == 'dd') {
        $dateFormat[0] = 'd';
    } elseif ($dateFormat[0] == 'yyyy') {
        $dateFormat[0] = 'Y';
    }

    if ($dateFormat[1] == 'mm') {
        $dateFormat[1] = 'm';
    } elseif ($dateFormat[1] == 'dd') {
        $dateFormat[1] = 'd';
    } elseif ($dateFormat[1] == 'yyyy') {
        $dateFormat[1] = 'Y';
    }

    if ($dateFormat[2] == 'mm') {
        $dateFormat[2] = 'm';
    } elseif ($dateFormat[2] == 'dd') {
        $dateFormat[2] = 'd';
    } elseif ($dateFormat[2] == 'yyyy') {
        $dateFormat[2] = 'Y';
    }

    return $dateFormat[0] . $seperater . $dateFormat[1] . $seperater . $dateFormat[2];
}




/**
 * convert_special_character()
 * Coverts special character of a string into its unicode
 *
 * @param mixed $string_to_convert
 * @return $string_to_convert
 */

function convert_special_character($string_to_convert) {
    $string_to_convert = str_replace(" ", "_u0020_", $string_to_convert);
    $string_to_convert = str_replace("!", "_u0021_", $string_to_convert);
    $string_to_convert = str_replace("\"", "_u0022_", $string_to_convert);
    $string_to_convert = str_replace("#", "_u0023_", $string_to_convert);
    $string_to_convert = str_replace("$", "_u0024_", $string_to_convert);
    $string_to_convert = str_replace("%", "_u0025_", $string_to_convert);
    $string_to_convert = str_replace("&", "_u0026_", $string_to_convert);
    $string_to_convert = str_replace("'", "_u0027_", $string_to_convert);
    $string_to_convert = str_replace("(", "_u0028_", $string_to_convert);
    $string_to_convert = str_replace(")", "_u0029_", $string_to_convert);
    $string_to_convert = str_replace("*", "_u002a_", $string_to_convert);
    $string_to_convert = str_replace("+", "_u002b_", $string_to_convert);
    $string_to_convert = str_replace(",", "_u002c_", $string_to_convert);
    $string_to_convert = str_replace("/", "_u002f_", $string_to_convert);
    $string_to_convert = str_replace(";", "_u003b_", $string_to_convert);
    $string_to_convert = str_replace("<", "_u003c_", $string_to_convert);
    $string_to_convert = str_replace("=", "_u003d_", $string_to_convert);
    $string_to_convert = str_replace(">", "_u003e_", $string_to_convert);
    $string_to_convert = str_replace("?", "_u003f_", $string_to_convert);
    $string_to_convert = str_replace("@", "_u0040_", $string_to_convert);
    $string_to_convert = str_replace("[", "_u005b_", $string_to_convert);
    $string_to_convert = str_replace("\\", "_u005c_", $string_to_convert);
    $string_to_convert = str_replace("]", "_u005d_", $string_to_convert);
    $string_to_convert = str_replace("^", "_u005e_", $string_to_convert);
    $string_to_convert = str_replace("`", "_u0060 _", $string_to_convert);
    $string_to_convert = str_replace("{", "_u007b_", $string_to_convert);
    $string_to_convert = str_replace("|", "_u007c_", $string_to_convert);
    $string_to_convert = str_replace("}", "_u007d_", $string_to_convert);
    $string_to_convert = str_replace("~", "_u007e_", $string_to_convert);
    $string_to_convert = str_replace(":", "_u003a_", $string_to_convert);
    $string_to_convert = str_replace("-", "_u002d_", $string_to_convert);
    $string_to_convert = str_replace(".", "_u002e_", $string_to_convert);

    return $string_to_convert;
}


/**
 * modify_url()
 * Modify URL by adding and modifing URL query(parameter)
 *
 * @param mixed $mod Array of the parameter to modify or add in the url modify_url(array('flag' => 'i'), $sp_url)
 *                   if the parameter exists in URL then it is modified.
 *                   but if the parameter does not exists in URL then it is added in the URL
 * @param mixed $url URL to be modified
 * @return modified URL
 * @example $url = 'test.php?flag=a';
 *          $url = modify_url(array('flag' => 'd', 'added_parameter' => 'added_value'), $url)
 *          the return value will be 'test.php?flag=d&added_parameter=added_value'
 */
function modify_url($mod, $url){
    // Parse the url into pieces
    $url_array = parse_url($url);
    // if the original URL had a query string, modify it.
    if (!empty($url_array['query'])) {
        parse_str($url_array['query'], $query_array);
        foreach ($mod as $key => $value) {
            if(!empty($query_array[$key])){
                $query_array[$key] = $value;
            } else{     // if the original URL didn't have a query string, add it.
                $second_array = array($key=>$value);
                $query_array = array_merge((array)$query_array, (array)$second_array);
            }
        }
    }


    return $url_array['scheme'].'://'.$url_array['host'].'/'.$url_array['path'].'?'.http_build_query($query_array);
}


/* added for export tool bar end */

/**
 * [html_to_txt Strip HTML, javascript, styles and Strip multi-line comments including CDATA.]
 * @param  [type] $document [description]
 * @return [type]           [description]
 */
function html_to_txt($document){
    $search = array('@<script[^>]*?>.*?</script>@si',  // Strip out javascript
                   '@<[\/\!]*?[^<>]*?>@si',            // Strip out HTML tags
                   '@<style[^>]*?>.*?</style>@siU',    // Strip style tags properly
                   '@<![\s\S]*?--[ \t\n\r]*>@'         // Strip multi-line comments including CDATA
    );
    $text = preg_replace($search, '', $document);
    return $text;
}

function convert_to_client_date_format($input_date) {
    $output_date = str_replace("'", '', $input_date);
    $date_format = $_SESSION['date_format'];
    $d = date_parse_from_format("Y-m-d", $input_date);
    $month = (count(str_split($d["month"])) == 1) ? '0'.$d["month"] : $d["month"];
    $day = (count(str_split($d["day"])) == 1) ? '0'.$d["day"] : $d["day"];
    
    if ($date_format == '%n/%j/%Y' || $date_format == '%m/%d/%Y' || $date_format == 'mm/dd/yyyy') {
        return ($month . '/' . $day . '/' . $d["year"]);
    } else if ($date_format == '%j-%n-%Y' || $date_format == '%d-%m-%Y' || $date_format == 'dd-mm-yyyy') {
        return ($day . '/' . $month . '/' . $d["year"]);
    } else if ($date_format == '%j.%n.%Y' || $date_format == '%d.%m.%Y' || $date_format == 'dd.mm.yyyy') {
        return ($day . '.'. $month . '.' . $d["year"]);
    } else if ($date_format == '%j/%n/%Y' || $date_format == '%d/%m/%Y' || $date_format == 'dd/mm/yyyy') {
        return ($day . '/'. $month . '/' . $d["year"]);
    } else if ($date_format == '%n-%j-%Y' || $date_format == '%m-%d-%Y' || $date_format == 'mm-dd-yyyy') {
        return ($month . '-'. $day . '-' . $d["year"]);
    }
}

/**
 * Returns translated text for given text
 *
 * @param   String      $text_string    Text to translate
 * @param   Boolean     $include_colon  Whether to include colon (:) in the returned text
 *
 * @return  String                      Translated text
 */
function get_locale_value($text_string, $include_colon = false) {
    if (empty($text_string)) {
        return '';
    }
    
    $lang_map_name = 'lang_map';
    if (isset($_SESSION[$lang_map_name])) {
        $lang_locales = (array) json_decode($_SESSION[$lang_map_name]);
        
        $find_string = strtolower($text_string);
        $find_string = str_replace("'", '_u0027_', $find_string);
        $find_string = str_replace("\\", '_u005c_', $find_string);
        $find_string = str_replace('"', '_u0022_', $find_string);

        if (array_key_exists($find_string, $lang_locales)) {
            $text_string = $lang_locales[$find_string];
            $text_string = str_replace('_u0027_', "'", $text_string);
            $text_string = str_replace('_u005c_', "\\", $text_string);
            $text_string = str_replace('_u0022_', '"', $text_string);
        }
    }
    
    return ($include_colon) ? $text_string . ':' : $text_string;
}

/**
 * Send data and request the api URL
 * @param  String $route    API route
 * @param  String $data   URL params
 * @param  String $auth_code Authentication code
 * @param  Boolean $is_post Is request POST
 * @return array             API Response
 */
function request_api($route, $data, $auth_code = '', $is_post = false) {
    global $webserver, $farrms_virtual_domain;
    $win_auth_req = (isset($_SERVER['AUTH_USER']) && $_SERVER['AUTH_USER'] != '') ? 1 : 0;
    ## Modify verify and verify-token route adding auth/ infront
    if ($route == 'verify' || $route == 'verify-token') {
        $is_post = true;
        ## Added win_auth post data to notify api it's windows authentication
        if ($route == 'verify-token') $data = '{"win_auth":"' . $win_auth_req . '"}';
        $route = 'auth/' . $route;
    }
    ## API URL
    $url = $webserver . $farrms_virtual_domain . "api/index.php?route=" . $route;
    // Open connection
    $curl_handle = curl_init();
    // Set the URL, number of POST vars, POST data
    $options = array();
    if ($is_post) {
        $options[CURLOPT_POST] = true;
        $options[CURLOPT_POSTFIELDS] = $data;
    }

    $headers = array();
    $headers[] = 'Content-Type: application/json';

    $http_authorization_name = ($win_auth_req == 1) ? 'CUSTOM_AUTHORIZATION' : 'AUTHORIZATION';

    if ($auth_code != '')
        $headers[] = $http_authorization_name . ': Bearer ' . $auth_code;

    $options[CURLOPT_URL] = $url;
    $options[CURLOPT_HTTPHEADER] = $headers;
    $options[CURLOPT_RETURNTRANSFER] = true;
    ## Bypass SSL Verification
    $options[CURLOPT_SSL_VERIFYPEER] = false;
    $options[CURLOPT_SSL_VERIFYHOST] = false;
    ## Add SSL Verification
    /*## Uncomment this if needs SSL Verification
    global $farrms_root_dir;
    if (ini_get("session.cookie_secure")) {
        $options[CURLOPT_SSL_VERIFYPEER] = true;
        $options[CURLOPT_SSL_VERIFYHOST] = '2';
        $options[CURLOPT_CAINFO] = $farrms_root_dir . 'CA.crt';
        $options[CURLOPT_CAPATH] = $farrms_root_dir . 'CA.crt';
    }
    */

    $options[CURLOPT_RETURNTRANSFER] = true;
    curl_setopt_array($curl_handle, $options);

    // Execute post
    $result = curl_exec($curl_handle);
    // Add Response code and curl error message if any in the final response data
    $http_response_code['response_code'] = curl_getinfo($curl_handle, CURLINFO_HTTP_CODE);
    $http_response_code['curl_error_message'] = (curl_error($curl_handle)) ? curl_error($curl_handle) : '';
    // Close connection
    curl_close($curl_handle);

    ## If curl failed add default error message
    if (!$result) {
        $result = '[{"ErrorCode":"Error","Message":"Please contact administrator."}]';
    }

    return array_merge(json_decode($result, true), $http_response_code);
}

/**
 * Returns the request value after sanitization
 * @param  String $value Value to sanitize
 * @param  String $type Type of value
 * @return String       Sanitized Value
 */
function get_sanitized_value($value, $type = 'string') {
    if ($type == 'ip') {
        $filter_id = FILTER_VALIDATE_IP;
    } else if ($type == 'email') {
        $filter_id = FILTER_VALIDATE_EMAIL;
    } else if ($type == 'boolean') {
        $filter_id = FILTER_VALIDATE_BOOLEAN;
    } else {
        $filter_id = FILTER_SANITIZE_STRING;
    }

    return filter_var(trim($value), $filter_id);
}

/**
 * Verify CSRF Token
 */
function verify_csrf_token() {
    ## Validates the CSRF Token
    $_csrf_token = isset($_REQUEST['_csrf_token']) ? $_REQUEST['_csrf_token'] : '';
    $_csrf_token = get_sanitized_value($_csrf_token);

    if (!hash_equals($_csrf_token, $_COOKIE['_csrf_token'])) {
        ob_end_clean();
        header("HTTP/1.1 401 Page Expired");
        die();
    }
}

/**
 * Set the cookie value
 * @param string  $name       Name
 * @param string  $value      Value
 * @param integer $expires    Is Expired, possible values (-1:expired, 0:lifetime & other in seconds)
 * @param boolean $http_only  Access cookie through http protocol
 * @param string  $path       Path to which cookie will be available
 * @param boolean $secure     Is cookie transmitted over HTTPS
 */
function set_cookie($name, $value = '', $expires = 0, $http_only = true, $path = '/', $secure = true) {
    if ($expires == -1)
        $expires = time() - 3600;

    if (!ini_get("session.cookie_secure")) $secure = false;
    setcookie($name, $value, ['expires' => $expires, 'path' => $path, 'domain' => '', 'secure' => $secure, 'httponly' => $http_only, 'samesite' => 'Lax']);
    $_COOKIE[$name] = $value;
}

/**
 * Encrypt Password
 * @param  string $login    User Login ID
 * @param  string $password User chosen password
 * @return string           Encrypted password
 */
function get_encrypted_password($login, $password) {
    return crypt(md5($password), strtolower($login));
}

/**
 * Verifies password rules specified in security.ini
 * @param  string $user_login_id User login ID
 * @param  string $password User chosen password
 * @return boolean          If rules are verified returns true otherwise returns false
 */
function validate_password_rules($user_login_id, $password) {
    ## These global variables are from security.ini.php
    global $pwd_min_char, $pwd_max_char, $allow_space;
    global $alphabets_must_contain, $must_contain_alphabets, $number_must_contain, $character_can_repeat, $character_repeat_number;
    global $allow_login_name, $allow_first_name, $allow_last_name;

    $password_length = strlen($password);
    ## Length
    if ($pwd_min_char > $password_length || $pwd_max_char < $password_length) {
        return false;
    }
    ## Allow Space
    if (!$allow_space && strpos($password, ' ') !== false) {
        return false;
    }
    ## Minimum count of alphabets
    if ($alphabets_must_contain > 0) {
        $password_without_numbers = preg_replace("!\d+!", "", $password);
        $characters_array = str_split($password_without_numbers);
        $must_contain_alphabets_array = explode(',', $must_contain_alphabets);
        $alphabets_count = 0;
        foreach ($characters_array as $char) {
            if (in_array($char, $must_contain_alphabets_array)) {
                $alphabets_count++;
            }
        }
        if ($alphabets_count < $alphabets_must_contain) {
            return false;
        }
    }
    ## Minimum count of numbers [0-9]
    if ($number_must_contain > 0) {
        preg_match_all('!\d+!', $password, $numbers);
        if (strlen(join('', $numbers[0])) < $number_must_contain) {
            return false;
        }
    }
    ## Characters repeat count
    if (!$character_can_repeat) {
        foreach (count_chars($password, 1) as $val) {
            if ($val > $character_repeat_number) {
                return false;
            }
        }
    }
    ## Allow login name
    if (!$allow_login_name && strpos($password, $user_login_id) !== false) {
        return false;
    }

    if (!$allow_first_name || !$allow_last_name) {
        $user_detail_sp = "EXEC spa_application_users @flag = 'w', @user_login_id = '" . $user_login_id . "'";
        $results = readXMLURL($user_detail_sp);
        $first_name = strtolower($results[0][2]);
        $last_name = strtolower($results[0][3]);
        ## Allow first name
        if (!$allow_first_name && strpos($password, $first_name) !== false) {
            return false;
        }
        ## Allow last name
        if (!$allow_last_name && strpos($password, $last_name) !== false) {
            return false;
        }
    }

    return true;
}

/**
 * Returns sanitized/valid path only
 * @param  string $path Path of the file
 * @return string       Valid path
 */
function get_sanitized_download_path($path) {
    ## Remove parent folder access
    $path = str_replace('../', '', $path);
    $path = str_replace('./', '', $path);
    ## Check if provided path contains dev/shared_docs/ to ensure valid path
    ## Commented bacause didn't work for the shared folder path(shared_docs_TRMTracker_Release) e.g.(import)
    // if (strpos($path, 'dev/shared_docs/') === FALSE) return '';

    $path = get_sanitized_value($path);
    $ext = get_file_extension($path);
    ## Check if file is downloadable by filtering file extension
    $is_ext_valid = false;
    if (!empty($ext)) {
        $is_ext_valid = is_valid_file_extension($ext);
    }
    return ($is_ext_valid) ? $path : '';
}

/**
 * Returns validity of the extension from the predefined lists
 * @param  string  $ext Extension to check
 * @return boolean      Valid or not
 */
function is_valid_file_extension($ext) {
    $ext = strtolower($ext); // Case-sensitive while matching values
    $valid_extensions = array('pdf', 'jpeg', 'jpg', 'png', 'xls', 'xlsx', 'doc', 'docx', 'txt', 'csv', 'xml', 'sql', 'rdl', 'zip', 'json');

    return in_array($ext, $valid_extensions);
}

/**
 * Returns the validity of the file content type from the predefined lists
 * @param string $file_type File Type
 * @return bool Valid or not
 */
function is_valid_file_type($file_type) {
    $valid_file_types = array('image/jpeg', 'image/png', 'application/json', 'text/plain', 'application/octet-stream',
        'application/mssheet', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 'application/vnd.ms-excel',
        'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'||
        'text/xml', 'application/xml');

    return in_array($file_type, $valid_file_types);
}

/**
 * Returns the file extension name
 * @param string $file_name Name of the file
 * @return mixed extension of the file
 */
function get_file_extension($file_name) {
    return pathinfo($file_name, PATHINFO_EXTENSION);
}

/**
 * Returns JWT decoded data
 * @param string $token JWT encoded data
 * @return json JWT decoded data
 */
function verify_token($token, $key = 'Bearer') {
    global $farrms_root_path;
    $jwt_lib_path = $farrms_root_path . 'adiha.php.scripts\\components\\lib\\php-jwt\\src\\';

    require_once $jwt_lib_path . 'BeforeValidException.php';
    require_once $jwt_lib_path . 'ExpiredException.php';
    require_once $jwt_lib_path . 'SignatureInvalidException.php';
    require_once $jwt_lib_path . 'JWT.php';

    try {
        $decoded = JWT::decode($token, $key, array('HS256'));
        if ($decoded) {
            $decoded_array = (array) $decoded;
            return array_merge($decoded_array, array('response_code' => 200));
        } else {  
            return '';
        }
    } catch(Exception $e) {
        return '';
    }
}

/**
 * Returns '403 Forbidden' HTTP response to prevent further access to application
 */
function forbidden_access_http_response() {
    header('HTTP/1.0 403 Forbidden');
    die('Access Forbidden!');
}


/**
 * Sends cURL request to a webpage or API.
 * @param  String  $url       API route
 * @param  String  $data      URL params
 * @param  String  $auth_code Authentication Code
 * @param  Boolean $is_post   Is request POST
 * @return array              API Response
 */
function send_curl_request($url, $data = '', $auth_code = '', $is_post = false) {
    # Open connection
    $curl_handle = curl_init();
    # Set the URL, number of POST vars, POST data
    $options = array();
    if ($is_post) {
        $options[CURLOPT_POST] = true;
        $options[CURLOPT_POSTFIELDS] = $data;
    }

    $headers = array();
    $headers[] = 'Content-Type: application/json';

    if ($auth_code != '') {
        $headers[] = 'AUTHORIZATION: Bearer ' . $auth_code;
    }

    $options[CURLOPT_URL] = $url;
    $options[CURLOPT_HTTPHEADER] = $headers;
    $options[CURLOPT_RETURNTRANSFER] = true;
    ## Bypass SSL Verification
    $options[CURLOPT_SSL_VERIFYPEER] = false;
    $options[CURLOPT_SSL_VERIFYHOST] = false;
    ## Add SSL Verification
    /*## Uncomment this if needs SSL Verification
    if (ini_get("session.cookie_secure")) {
        $options[CURLOPT_SSL_VERIFYPEER] = true;
        $options[CURLOPT_SSL_VERIFYHOST] = '2';
        $options[CURLOPT_CAINFO] = $farrms_root_dir . 'CA.crt';
        $options[CURLOPT_CAPATH] = $farrms_root_dir . 'CA.crt';
    }
    */
    $options[CURLOPT_RETURNTRANSFER] = true;
    curl_setopt_array($curl_handle, $options);

    # Execute post
    $result = curl_exec($curl_handle);

    # Add Response code and curl error message if any in the final response data
    $http_response_code['response_code'] = curl_getinfo($curl_handle, CURLINFO_HTTP_CODE);
    $http_response_code['curl_error_message'] = (curl_error($curl_handle)) ? curl_error($curl_handle) : '';
    # Close connection
    curl_close($curl_handle);

    # If curl failed add default error message
    if (!$result) {
        $result = '[{"ErrorCode":"Error","Message":"Could not sent request to ' . $url . '"}]';
    }

    if (is_array(json_decode($result, true))) {
        $response = array_merge(json_decode($result, true), $http_response_code);
    } else {
        $response = $http_response_code;
    }

    return $response;
}


/**
 * Convert HTML table string to XML string
 * 
 * @param   string  $html_string  HTML Table String
 * 
 * @return  string                Equivalent XML String
 */
function generate_xml_from_table_html($html_string, $columns_count) {
    // Page Orientation and Format
    $orientation = 'portrait';
    $l_orientation = 'landscape';
    $format = 'A4';
    
    if ($columns_count > 6 && $columns_count <= 10) {
        $orientation = $l_orientation;
    } else if ($columns_count > 10 && $columns_count <= 15) {
        $orientation = $l_orientation;
        $format = 'A3';
    } else if ($columns_count > 15 && $columns_count <= 20) {
        $orientation = $l_orientation;
        $format = 'A2';
    } else if ($columns_count > 20) {
        $orientation = $l_orientation;
        $format = 'A1';
    }
    
    // Strips unwanted tags
    $html_string = strip_tags($html_string, '<table><tr><td><th>');
    // Split by tags
    $html_array = preg_split('/<(.*)>/U', $html_string, -1, PREG_SPLIT_DELIM_CAPTURE);
    
    $table_start = false;
    $is_header = true;
    $header_start = true;
    $new_row = true;
    
    $xml = "<rows profile='color' orientation='" . $orientation . "' pagewidth='" . $format . "'>";
    
    foreach($html_array as $key => $value) {
        $arr = explode(' ', $value);
        $tag = $arr[0];
        
        // Check Table start/end Data row start
        if ($tag == 'table') {
            $table_start = true;
        }
        
        if (!$table_start) {
            continue;
        } else if ($tag == '/table') {
            break;
        } else if ($tag == 'tr') {
            $new_row = true;
        }
        
        // Header/Data Rows Start XML Tag
        if ($new_row && !$is_header && !$header_start) {
            $xml .= '<row level="0">';
            $new_row = false;
        } else if ($new_row && $is_header) {
            $xml .= '<head><columns>';
            $is_header = false;
        }
        
        // Header/Data Rows End XML Tag
        if ($new_row && $header_start && $tag == 'tr') {
            $new_row = false;
        } else if ($tag == '/tr') {
            if ($header_start && !$is_header) {
                $xml .= '</columns></head>';
                $is_header = false;
            } else {
                $xml .= '</row>';
            }
            
            $header_start = false;
        }

        // Data Cell XML
        $next_tag_value = $html_array[$key + 1];
        if ($next_tag_value == '/td' || $next_tag_value == '/th') {
            if ($key % 2 == 0 && !$header_start) {
                $xml .= '<cell>';
                $xml .= '<![CDATA[' . trim(str_replace('&nbsp;', ' ', $value)) . ']]>';
                $xml .= '</cell>';
            } else {
                $xml .= "<column width='200' align='left' type='ro' hidden='false' sort='str'>";
                $xml .= '<![CDATA[' . trim(str_replace('&nbsp;', ' ', $value)) . ']]>';
                $xml .= '</column>';
            }
        }
    }
    return $xml .= "\n" . '</rows>';
}

/**
 * Gets random file name using current time and random characters
 *
 * @return  String  Random file name
 */
function get_random_file_name() {
    $file_name = time();
    
    for ($i = 0; $i < 5; $i++) {
        $file_name .= chr(rand(65, 90));
    }
    
    return $file_name;
}
?>