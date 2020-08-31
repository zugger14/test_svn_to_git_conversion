<?php
    /**
     * Destroy the session
     * @copyright Pioneer Solutions
     */
	ob_start();
	
    // Removed isset check for client_folder before requiring v3 file as it caused error whenever calling spa_session_destroy twice. spa_session_destroy might be called twice when user has logged in from website and two tabs are opened where user clicks logs out from website first and then tries to logout from application as well.
    require_once('components/include.file.v3.php');

	if (ini_get("session.use_cookies")) {
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
	}

    session_destroy();

    if (!function_exists('get_request_protocol')) {
        function get_request_protocol() {
            $isSecure = false;
            if (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on') {
                $isSecure = true;
            } elseif (!empty($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https' || !empty($_SERVER['HTTP_X_FORWARDED_SSL']) && $_SERVER['HTTP_X_FORWARDED_SSL'] == 'on') {
                $isSecure = true;
            }
            return $isSecure ? 'https' : 'http';
        }
    }

 	if (isset($_GET['call_from']) && $_GET['call_from'] == 'wp' && isset($_GET['inactivity']) && $_GET['inactivity'] == 'true') {
 		header('Location: ' . get_request_protocol() . '://' . $_SERVER['SERVER_NAME'] . '?action=session_timeout');
    } else if (isset($_GET['call_from']) && $_GET['call_from'] == 'wp') {
        $action = '';
        if (isset($_GET['action']) && $_GET['action'] != '') {
            $action = '?action=' . $_GET['action'];
        }
		header('Location: ' . get_request_protocol() . '://' . $_SERVER['SERVER_NAME'] . $action);
    }

    ob_flush();
?>