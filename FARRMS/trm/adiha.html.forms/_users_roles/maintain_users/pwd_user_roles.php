<?php
	ob_start();
	## To exclude unnecessary db hits and components includes
	$check_cloud_mode_login = 1;
	include '../../../adiha.php.scripts/components/include.main.files.php';
	unset($check_cloud_mode_login);
	
	## Verify CSRF Token
	verify_csrf_token();

    $user_login_id = get_sanitized_value($_POST['user_login_id'] ?? '');
    $old_password = get_sanitized_value($_POST['old_password'] ?? '');
    $new_password = get_sanitized_value($_POST['user_pwd'] ?? '');
	
	$is_valid_password = validate_password_rules($user_login_id, $new_password);

    if ($is_valid_password) {
    	$enc_old_password = $old_password;
	    $enc_new_password = get_encrypted_password($user_login_id, $new_password);
	    $temp_pwd = 'y';
    	$user_admin = 1;
    	
	    if (strtolower($user_login_id) == strtolower($app_user_name)) {
	    	$enc_old_password = get_encrypted_password($user_login_id, $old_password);
	    	$temp_pwd = 'n';
	    	$user_admin = 0;
	    }

	    $pwd_expire_date = date("m/d/Y", mktime(0, 0, 0, date("m"), date("d") + $expire_date, date("Y")));
	    // Change Password
	    $change_password_sp = "EXEC spa_changedPassword @user_login_id = '$user_login_id', @user_pwd = '$enc_new_password', @temp_pwd = '$temp_pwd', @expire_date = '$pwd_expire_date', @reuse_count = $dont_allow_password_reuse_count, @old_password = '$enc_old_password', @user_admin = $user_admin, @pwd_raw = '$new_password', @cloud_mode = $CLOUD_MODE";
	    
	    $results = readXMLURL2($change_password_sp);
	} else {
		$results[0]['errorcode'] = 'validation';
	}

	$return["json"] = $results;
    ob_end_clean();
	echo json_encode($return);
?>