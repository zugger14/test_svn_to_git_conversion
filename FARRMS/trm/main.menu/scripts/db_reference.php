<?php
	## This file will connect with the cloud database with the default username and password
	## To check whether the email address login exists in database or not
	## And returns the corresponding user login id and db name
	
	## call_from recovery is Account Password Reset
	$call_from = isset($_GET['call_from']) ? $_GET['call_from'] : '';

	## Connection Info to connect Adiha_Cloud Database
	$connection_info_cloud = array(
				"Database" => $database_name,
				"UID" => $cloud_db_user,
				"PWD" => $cloud_db_pwd,
				"CharacterSet" => "UTF-8",
				'ReturnDatesAsStrings'=> true);
	## Cloud Database Connection Link
	$DB_CONNECT = @sqlsrv_connect($db_servername, $connection_info_cloud);
	# Required for establishing connection to adiha_cloud db for resolving application path
	$cloud_db_servername = $db_servername;

	# Avoid unnecessary code execution below for specific api requests
	if (isset($is_bypass_auth_route) && $is_bypass_auth_route) {
		return;
	}

	## Get the real database details and user details from the cloud database
	$host = $client_ip;
	$sql = "EXEC spa_cloud_users @flag='s', @user_email_address='" . $app_user_name . "', @user_password='', @system_name='" . $host . "', @system_address='" . $client_ip . "', @cookie_hash='" . $cookie_hash . "', @database_name='" . PRIMARY_CLOUD_DB . "'";

	# Add SP param to check if tenant ID exists for authentication using Azure AD
	if (!empty($aad_tenant_id)) {
		$sql .= ", @aad_tenant_id='$aad_tenant_id'";
	}
	$result = sqlsrv_query($DB_CONNECT, $sql);

	if ($result) {
		$check_user_credentials = true;
	} else {
		$check_user_credentials = false;
	}

	while ($row = sqlsrv_fetch_array($result, SQLSRV_FETCH_NUMERIC)) {
		$cloud_user_type = strtolower($row[2]);
		# Check if tenant is valid if not break and throw error
		if (!empty($aad_tenant_id) && strtolower($row[9]) == 'unauthorized') {
			$cloud_login_error_msg = 'Unauthorized directory (tenant) ID.';
		} else {
		$new_db_name = $row[0];
		$dot_index = strrpos($new_db_name, '.');
		$dot_index = $dot_index ? $dot_index + 1 : 0;
		$new_db_name = substr($new_db_name, $dot_index);
	    if ($cloud_user_type == 'prospect' || $cloud_user_type == 'other') {
	    	$cloud_user_name = $row[3];
	    	$cloud_login_status = $row[4];
	    	$cloud_license_agreement = $row[5];
	    	$cloud_enable_otp = $row[6];
	    } else {
	    	$new_db_server_name = $row[3];
	    	$new_db_server_name = ($new_db_server_name) ? $new_db_server_name : $db_servername;
	    	$cloud_license_agreement = $row[4];
	    	$cloud_license_expiration = strtolower($row[5]);
	    	$new_db_user = $row[6];
	    	$new_db_pwd = $row[7];
				$saas_application_name = $row[8];
	    }

	    ## Set the real user login id from the real database as app_user_name
	    if ($call_from != 'recovery')
	    	$app_user_name = $row[1];
	    break;
	}
	}

	## If user is not found in cloud datbase
	## If demo user and if database connection is not successfull 
	if (!isset($cloud_user_type)) {
		$cloud_login_error_msg = $app_user_name . " is not valid login id.";
    } else if ($cloud_user_type == 'saas' || $cloud_user_type == 'demo') {
        if (isset($cloud_license_expiration) && $cloud_license_expiration == 'y') {
            $cloud_login_error_msg = 'Your account has been expired. Please contact us to renew your account.';
        }
    }

    if (isset($cloud_login_error_msg) && $cloud_login_error_msg != "") {
        if (isset($check_user_credentials) && !$check_user_credentials) {
            $cloud_login_error_msg = "User verification failed.";
        }
    }
?>