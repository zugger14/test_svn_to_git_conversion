<?php
$client_dir = get_request_value('call_from');
include_once '../../'.$client_dir.'/farrms.client.config.ini.php';
include '../adiha.php.scripts/components/file_path.php';
include_once '../../'.$client_dir.'/license.php';
include_once('../adiha.php.scripts/components/security.ini.php');

$user_session_disable = true;
$url = $app_adiha_loc;
$user_email_address = get_request_value('user_email', 'email');
$app_user_name = $user_email_address;

## Default Error Message and Actions in case of user 
## Not found in cloud database and email address is not valid
$message = 'Please enter a valid email address.';
$action = 'ERROR';

if (!empty($app_user_name)) {
    if ($CLOUD_MODE == 1) {
        $_GET['call_from'] = 'recovery';
        include '../main.menu/scripts/db_reference.php';
        $database_name = isset($new_db_name) ? $new_db_name : $database_name;
        $db_servername = isset($new_db_server_name) ? $new_db_server_name : $db_servername;
    }

    $connection_info = array(
        "Database" => $database_name,
        "UID" => $db_user,
        "PWD" => $db_pwd,
        "CharacterSet" => "UTF-8",
        "ReturnDatesAsStrings" => true
    );

    $new_pwd_txt = get_request_value('new_password');
    $request_action = get_request_value('action');
    $recovery_id = get_request_value('confirmID');
    ## This code block is triggered when the users confirm the account recovery from email.
    if ($recovery_id != '' && $database_name != '') {
        ## Get User Login ID to generate random encrypted password
        $sp_param = "EXEC spa_user_account_recovery @flag = 'l', @recovery_id = '" . $recovery_id . "'";
        $results = get_recordset($sp_param, $db_servername, $connection_info);
        
        if (count($results) > 0) {
            $user_login_id = $results[0][0];
            $random_password = generate_random_password();
            $encrypted_password = get_encrypted_password($user_login_id, $random_password);
            if ($CLOUD_MODE == 1) {
                $request_protocol = get_request_protocol();
                $trmclient_url = $request_protocol . '://' . $_SERVER['SERVER_NAME'];
            } else {
                $trmclient_url = str_replace('trm', $client_dir, $url);
            }
            ## Reset password
            $is_cloud_mode = (isset($CLOUD_MODE) && $CLOUD_MODE == 1) ? 'y' : 'n';
            $sp_param = "EXEC spa_user_account_recovery @flag = 'c', @recovery_id = '" . $recovery_id . "', @password_suggested = '" . $random_password . "', @phpEncPwd = '" . $encrypted_password . "', @url = '" . $trmclient_url . "', @is_cloud_mode = '" . $is_cloud_mode . "'";


            $results = get_recordset($sp_param, $db_servername, $connection_info);
            
            if ($results[0][0] == 'Success') 
                $action = 'YES';
            else if ($results[0][0] == 'Duplicate')
                $action = 'NO';
            else
                $action = 'ERROR';
        } else {
            $action = 'ERROR';
        }
    } else if ($request_action == 'reset_password') {
        $recovery_token = get_request_value('recovery_token');
        // Get user_login_id
        $user_login_sp = "EXEC spa_application_users @flag='n', @user_emal_add='" . $user_email_address . "'";
        $user_login_results = get_recordset($user_login_sp, $db_servername, $connection_info);
        $user_login_id = $user_login_results[0][0];
        $first_name = $user_login_results[0][1];
        $last_name = $user_login_results[0][2];
        
        $new_pwd_encrypt = get_encrypted_password($user_login_id, $new_pwd_txt);
    	
    	$password_reset_sp = "EXEC spa_user_account_recovery @flag = 'p', @user_email = '" . $user_email_address . "', @phpEncPwd = '" . $new_pwd_encrypt . "', @recovery_id = '" . $recovery_token . "', @pwd_expiry_days = " . $expire_date;
    	$results = get_recordset($password_reset_sp, $db_servername, $connection_info);
        
        $return_data['status'] = $results[0][0];
        $return_data['msg'] = $results[0][1];
        $return_data['policy'] = build_password_policy($user_email_address, $new_pwd_txt, $first_name, $last_name);
        ob_clean();
        echo header('Content-Type: application/json');
        echo json_encode($return_data);
        die();
    } else if ($request_action == 'change_password') {
        $current_pwd_txt = get_request_value('current_password');

        // Get user_login_id
        $user_login_sp = "EXEC spa_application_users @flag='n', @user_emal_add='" . $user_email_address . "'";
        $user_login_results = get_recordset($user_login_sp, $db_servername, $connection_info);
        $user_login_id = $user_login_results[0][0];
        $first_name = $user_login_results[0][1];
        $last_name = $user_login_results[0][2];
        
        $current_pwd_encrypt = get_encrypted_password($user_login_id, $current_pwd_txt);
        $new_pwd_encrypt = get_encrypted_password($user_login_id, $new_pwd_txt);
        
        $change_password_sp = "EXEC spa_application_users @flag = 'r', @user_emal_add = '" . $user_email_address . "', @new_pwd = '" . $new_pwd_encrypt . "', @user_pwd = '" . $current_pwd_encrypt . "', @pwd_expiry_days = " . $expire_date;
        $results = get_recordset($change_password_sp, $db_servername, $connection_info);
        
        $return_data['status'] = $results[0][0];
        $return_data['msg'] = $results[0][1];
        $return_data['policy'] = build_password_policy($user_email_address, $new_pwd_txt, $first_name, $last_name);
        ob_clean();
        echo header('Content-Type: application/json');
        echo json_encode($return_data);
        die();
    } else if ($request_action == 'update_system_access_log') {
        $client_ip = get_request_value('client_ip', 'ip');
        $client_machine = get_request_value('client_machine');

        // Set Cookie to skip OTP Verification on next login
        $encrypt_cookie = md5(strtolower($app_user_name . $client_dir));
        $cookie_hash = password_hash($encrypt_cookie, PASSWORD_DEFAULT);

        $system_access_sp = "EXEC spa_system_access_log @flag='i',@user_login_id_var='" . $app_user_name . "', @system_address='" . $client_ip . "', @system_name='" . $client_machine . "', @status='Success', @cookie_hash='" . $cookie_hash . "'";
        $results = get_recordset($system_access_sp, $db_servername, $connection_info);

        $return_data['status'] = 'Success';
        $return_data['cookie_hash'] = $cookie_hash;

        ob_clean();
        echo json_encode($return_data);
        die();
    } else if (isset($user_email_address) && $database_name != '') { ## This will process for account recovery action
        ## Check user existance and process for password reset
        $confirmation_id = generate_confirmation_id();
        $password_reset_sp = "EXEC spa_user_account_recovery @flag = 'r', @user_email = '" . $user_email_address . "', @url = '" . $url . "', @recovery_id = '" . $confirmation_id . "', @call_from = '" . $client_dir . "'";

        $results = get_recordset($password_reset_sp, $db_servername, $connection_info);

        $action = $results[0][0];
        $message = $results[0][4];
    }
}

function generate_confirmation_id() {
    $random = "";
    srand((double) microtime() * 1000000);

    $data = "AbcDE12-3IJKLMN6-7QRSTUVWXYZ-snkt65309nh-thy-lkns-119-sgthwl637-yht6";
    $data .= "aBCdefghi-jklmn123opq-45rs67tuv89wxyz-198ghst-8jhyst-0sg4j7sh-thpth";
    $data .= "0FGH45O-P89-THY356SM-KJSY736SN-9SNH-TYSH6-4JHSY-5YTHSKI-TYHD698NDBX";

    for ($i = 0; $i < 50; $i++) {
        $random .= substr($data, (rand() % (strlen($data))), 1);
    }
    return $random;
}

function generate_random_password() {
    $passwd = '';
    srand((double) microtime() * 1000000);

    $data = 'abcdefghijklmnopqrstuvwxyz';
    $data .= '0123456789';
    $data .= 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

    for ($i = 0; $i < 5; $i++) {
        $passwd .= substr($data, (rand() % (strlen($data))), 1);
    }
    return $passwd;
}

function get_recordset($sql, $db_servername, $connection_info) {
    $db_server_name = $db_servername;
    $link = sqlsrv_connect($db_server_name, $connection_info);

    $result = sqlsrv_query($link, $sql);
  
    if (!$result) {
        sqlsrv_errors();
    }
    
    $y_index = 0;
    while ($row = sqlsrv_fetch_array($result, SQLSRV_FETCH_NUMERIC)) {
        for ($y = 0; $y < count($row); $y++) {
            $recordset[$y_index][$y] = $row[$y];
        }
        $y_index++;
    }

    sqlsrv_free_stmt($result);
    sqlsrv_close($link);
    
    return $recordset;
}

function get_request_protocol() {
    $isSecure = false;
    if (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on') {
        $isSecure = true;
    } elseif (!empty($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https' || !empty($_SERVER['HTTP_X_FORWARDED_SSL']) && $_SERVER['HTTP_X_FORWARDED_SSL'] == 'on') {
        $isSecure = true;
    }
    return $isSecure ? 'https' : 'http';
}

function build_password_policy($user_email_id, $new_pwd, $first_name, $last_name) {
    include('../adiha.php.scripts/components/security.ini.php');
    $new_pwd_len = strlen($new_pwd);
    $user_login_id = $user_email_id;
    $policy = "<ul>";

    // Password Policy
    $policy .= "<li>" . "Password should contain minimum " . $pwd_min_char . " characters.";
    $policy .= "<li>" . "Password should not contain more than " . $pwd_max_char . " characters.";

    if ($allow_space == false) {
        $policy .= "<li>" . "Password should not contain spaces.";
    }

    if ($character_can_repeat == false) {
        $policy .= "<li>" . "A character may not be repeated more than " . $character_repeat_number . " times.";
    }

    if ($alphabets_must_contain > 0) {
        $policy .= "<li>" . "Password must consist of at least " . $alphabets_must_contain . " letter (A-Z or a-z) and " . $number_must_contain . " number (0-9).";
    }

    if ($no_of_must_contain_char > 0) {
        $policy .= "<li>" . "Password should contain at least " . $no_of_must_contain_char . " special characters.";
    }

    if ($allow_login_name == false) {
        $policy .= "<li>" . "Password must not contain the login name.";
    }

    if ($allow_first_name == false) {
        $policy .= "<li>" . "Password must not contain user's first name.";
    }

    if ($allow_last_name == false) {
        $policy .= "<li>" . "Password must not contain user's last name.";
    }

    $policy .= "</ul>";
    return $policy;
}

/**
 * Returns the request value after sanitization
 * @param  String $name Name of request
 * @param  String $type Type of request
 * @return String       Value of request
 */
function get_request_value($name, $type = 'string') {
    $request_value = isset($_REQUEST[$name]) ? $_REQUEST[$name] : '';

    if ($type == 'ip') {
        $filter_id = FILTER_VALIDATE_IP;
    } else if ($type == 'email') {
        $filter_id = FILTER_VALIDATE_EMAIL;
    } else {
        $filter_id = FILTER_SANITIZE_STRING;
    }

    return filter_var(trim($request_value), $filter_id);
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

if (isset($_GET['confirmID'])) {
    if ($CLOUD_MODE == 1) {
        $request_protocol = get_request_protocol();
        $to = $request_protocol . '://' . $_SERVER['SERVER_NAME'] . '?reset_status=' . strtolower($action);
    } else {
        $to = 'user.account.recovery.confirmation.php?message=' . $action;
    }
    header('Location: ' . $to);
    exit;
    die();
} else {
    $data['msg'] = $message;
    $data['action'] = $action;
    echo header('Content-Type: application/json');
    echo json_encode($data);
}
?>