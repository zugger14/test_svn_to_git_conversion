<?php

class Otp {
	public static function system_access_log($user_email, $cookie_hash) {
		if (!empty($_SERVER['HTTP_CLIENT_IP'])) {
			$client_ip = $_SERVER['HTTP_CLIENT_IP'];
		} else if (!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) {
			$client_ip = $_SERVER['HTTP_X_FORWARDED_FOR'];
		} else {
			$client_ip = $_SERVER['REMOTE_ADDR'];
		}
		$host = $client_ip;
		$query = "EXEC spa_system_access_log @flag='i',@user_login_id_var='" . $user_email . "', @system_address='" . $client_ip . "', @system_name='" . $host . "', @status='Success', @cookie_hash='" . $cookie_hash . "'";
		return DB::query($query);
	}

	public static function allow_application_access($session_id) {
		$query = "EXEC spa_trm_session @flag='z', @trm_session_id='$session_id'";
		return DB::query($query);
	}
}