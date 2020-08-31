<?php

class ResolveApplicationPath extends CloudDb {
    public function __construct() {
        parent::__construct();
    }

    public function resolveApplicationPath($user_email_address) {
    	$sql = "EXEC spa_cloud_users @flag='e', @user_email_address='$user_email_address'";
	    $result = $this->adihaDbQuery($sql);
	    return $result;
    }

    public function generateRecoveryToken($user_email_address, $recovery_token) {
    	$sql = "EXEC spa_cloud_users @flag='f', @user_email_address='$user_email_address', @token='$recovery_token'";
    	$result = $this->adihaDbQuery($sql);
    	return $result;
    }

    public function verifyRecoveryToken($user_email_address, $recovery_token, $expire_token = false) {
		if ($expire_token) {
			$sql = "EXEC spa_cloud_users @flag='o', @user_email_address='$user_email_address', @token='$recovery_token'";
		} else {
			$sql = "EXEC spa_cloud_users @flag='t', @user_email_address='$user_email_address', @token='$recovery_token'";
		}
    	$result = $this->adihaDbQuery($sql);
    	return $result;
    }

    public function resolveMainAppDb($user_email_address) {
    	$sql = "EXEC spa_cloud_users @flag='s', @user_email_address='$user_email_address'";
	    $result = $this->adihaDbQuery($sql);
	    return $result;
    }

    public function getUserInfo($user_email_address) {
		$query = "EXEC spa_application_users @flag='n', @user_emal_add='$user_email_address'";
		$results = $this->mainDbQuery($query);
		# Check for user_login_id in adiha_cloud db incase email address is somehow empty or deleted in main application database
		if (empty($results)) {
			$query = "EXEC spa_cloud_users @flag='q', @user_email_address='$user_email_address'";
			$results = $this->adihaDbQuery($query);
		}
        return $results;
	}

	public function resetUserPassword($user_email_address, $new_pwd_encrypt, $recovery_token, $pwd_expiry_days) {
		$query = "EXEC spa_user_account_recovery @flag='p', @user_email='$user_email_address', @phpEncPwd='$new_pwd_encrypt', @recovery_id='$recovery_token', @pwd_expiry_days=$pwd_expiry_days";
        $results = $this->mainDbQuery($query);
        return $results;
	}

	public function updateLicenseAgreement($user_email_address, $agreement) {
		$sql = "EXEC spa_cloud_users @flag='l', @user_email_address='$user_email_address', @agreement_status='$agreement'";
	    $result = $this->adihaDbQuery($sql);
	    return $result;
	}

	public function checkIfEmailIsAvailable($user_email_address, $user_login_id) {
		$sql = "EXEC spa_cloud_users @flag='m', @user_email_address='$user_email_address', @user_login_id='$user_login_id'";
	    $result = $this->adihaDbQuery($sql);
	    return $result;
	}

	public function createUser($user_login_id, $user_f_name, $user_l_name, $user_email_address, $database_name, $db_server_name) {
		$sql = "EXEC spa_cloud_users @flag='i', @user_login_id='$user_login_id', @user_f_name='$user_f_name', @user_l_name='$user_l_name', @user_email_address='$user_email_address', @database_name='$database_name', @db_server_name='$db_server_name'";
	    $result = $this->adihaDbQuery($sql);
	    return $result;
	}

	public function deleteUser($user_data) {
		$sql = "EXEC spa_cloud_users @flag='d', @user_data_json='$user_data'";
	    $result = $this->adihaDbQuery($sql);
	    return $result;
	}
}