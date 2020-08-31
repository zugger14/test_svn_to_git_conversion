<?php

class Auth {
    public static function login($app_user_name, $password, $ip, $host, $win_auth, $login_attempts, $login_attempt_time, $cloud_mode, $farrms_client_dir, $cookie_hash) {
        $encrypted_password = self::get_encrypted_password($app_user_name, $password);
        $query = "EXEC spa_is_valid_user '$app_user_name', '$encrypted_password', '$ip', '$host', 1, $win_auth, $login_attempts, $login_attempt_time, $cloud_mode, '$farrms_client_dir', '$cookie_hash'";
        return DB::query($query);
    }
    
    public static function addDevice($app_user_name, $password, $device_token, $os) {
        $encrypted_password = self::get_encrypted_password($app_user_name, $password);
        $query = "EXEC spa_mobile_login 'l', '$app_user_name', '$encrypted_password', '$device_token', '$os'";
        return DB::query($query);
    }
    
    public static function listDevice() {
        $query = "EXEC spa_mobile_login 's'";
        return DB::query($query);
    }
    
    public static function logout() {
        return DB::logout();
    }
    
    public static function getSSRSLogin() {
        $query = "EXEC spa_connection_string 'r'";
        return DB::query($query);
    }
    
    public static function dateFormat() {
        global $app_user_name;
        $query = "EXEC spa_mobile_login 'f', @user_login_id = '$app_user_name'";
        return DB::query($query);
    }
    
    public static function dateWithFormat($date) {
        global $app_user_name;
        $query = "EXEC spa_mobile_login 'f', @user_login_id = '$app_user_name', @date = '$date'";
        return DB::query($query);
    }
	
	public static function tokenExpireDays() {
        $query = "EXEC spa_connection_string 't'";
        return DB::query($query);
    }

    public static function initializeSession($app_user_name, $session_id, $session_data, $machine_name, $machine_address) {
        $query = "EXEC sys.sp_set_session_context @key = N'DB_USER', @value = '$app_user_name'; EXEC spa_trm_session @flag='i', @trm_session_id='$session_id', @session_data='$session_data', @machine_name='$machine_name', @machine_address='$machine_address'";
        return DB::query($query);
    }

    /**
     * Encrypt Password
     * @param  string $login    User Login ID
     * @param  string $password User chosen password
     * @return string           Encrypted password
     */
    public static function get_encrypted_password($login, $password) {
        return crypt(md5($password), strtolower($login));
    }
}
