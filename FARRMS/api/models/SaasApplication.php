<?php

class SaasApplication {
	public static function getUserInfo($user_email) {
		$query = "EXEC spa_application_users @flag='n', @user_emal_add='$user_email'";
        $results = DB::query($query);
        return $results[0];
	}

	public static function changeUserPassword($user_email, $new_pwd_encrypt, $current_pwd_encrypt, $pwd_expiry_days) {
		$query = "EXEC spa_application_users @flag='r', @user_emal_add='$user_email', @new_pwd='$new_pwd_encrypt', @user_pwd='$current_pwd_encrypt', @pwd_expiry_days=$pwd_expiry_days";
        $results = DB::query($query);
        return $results[0];
	}

}