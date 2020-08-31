<?php ob_start(); ?>
<html>
    <body leftmargin=0 topmargin=0>
        <?php
        ## Created to make it reusable.
        ## $msg Message to display is passed and it will
        ## $script_text returns the script to redirect to login page with the message
        function redirect_to_login($msg) {
            global $farrms_client_dir, $windows_auth;
            $script_text =  "<Script>window.location.href='../../index_login_farrms.php?loaded_from=$farrms_client_dir&message=" . urlencode($msg);
            
            if ($windows_auth == 1)
                $script_text .= "&flag=login";

            $script_text .= "'</script>";

            return $script_text;
        }

        ## Capture session data stored after Azure Active Directory authentication and set win_auth = 1 to allow login without password
        if (ini_get('session.auto_start') != '1') {
        session_start();
        }
        if (session_status() && isset($_SESSION['AZURE_AD'])) {
            $AZURE_AD = $_SESSION['AZURE_AD'];
            $user_email = $AZURE_AD['email'];
        }
        session_write_close();

        $call_from_wp = isset($_POST['txt_call_from']) ? $_POST['txt_call_from'] : '';
        $username = strtolower(filter_var(trim($_POST['txt_user_name'] ?? ''), FILTER_SANITIZE_STRING));
        $password = $_POST['txt_password'] ?? '';
        $client_ip = filter_var(isset($_POST['client_ip']) ? $_POST['client_ip'] : $_SERVER['REMOTE_ADDR'], FILTER_VALIDATE_IP);
        $cookie_hash = filter_var(isset($_POST['cookie_hash']) ? $_POST['cookie_hash'] : '', FILTER_SANITIZE_STRING);

        ## Made client directory dynamic in php.scripts config
        ## loaded_from parameter is set from login page
        $current_client_dir = isset($_POST['client_folder']) ? $_POST['client_folder'] : '';
        $current_client_dir = filter_var(trim($current_client_dir), FILTER_SANITIZE_STRING);        
        $_COOKIE['client_folder'] = $current_client_dir;

        ## Check if its windows authentication
        $authPass = isset($_SERVER['AUTH_USER']) ? $_SERVER['AUTH_USER'] : '';
        $authType = isset($_SERVER['AUTH_TYPE']) ? $_SERVER['AUTH_TYPE'] : '';
        $windows_auth = (($authPass != '' && $authType == 'Negotiate') || isset($AZURE_AD)) ? 1 : 0;

        ## Set user passed username as application user name
		$app_user_name = $username;
        
        ## This will be checked in adiha.config.ini.rec.php to include db_reference.php (Cloud Login)
        ## And in include.main.files to exclude unnecessary db hits during login
        $check_cloud_mode_login = 1;
        require '../../adiha.php.scripts/components/include.file.v3.php';
        unset($check_cloud_mode_login);

        ## Perform additional check if azure access token is valid then only resolve user_login_id to provide access to application
        if (!empty($AZURE_AD)) {
            $verify_access_token = send_curl_request($MICROSOFT_GRAPH_URI, '', $AZURE_AD['access_token']);
            # Resolve user_login_id only when token is valid else proceed with email address as $user_name so that it will be invalid and user login will be rejected.
            if (isset($verify_access_token['id']) && $verify_access_token['id'] == $AZURE_AD['oid']) {
                ## Get user_login_id using current azure email address
                $xmlFile = "EXEC spa_application_users @flag='n', @user_emal_add='$username'";
                $result = readXMLURL2($xmlFile);
                ## Set user_login_id for application to work properly
                if (!empty($result) && isset($result[0])) {
                    $username = $result[0]['user_login_id'];
                    $app_user_name = $username;
                }
            }
        }

        ## Verify CSRF Token
        verify_csrf_token();
        ## Set client_folder cookie
        set_cookie("client_folder", $current_client_dir);
        ## Made module type dynamic in php.scripts config
        set_cookie("module_type", $module_type);
        
        ## Since cURL request is made to this page when logging in from SaaS website,$_SERVER['REMOTE_ADDR'] won't give correct client remote address
        if ($CLOUD_MODE == 0) {
            $cookie_hash = get_sanitized_value($_COOKIE['MFAID'] ?? '');
        }
        $host = $client_ip;
     
        ## Check the validation with API Authenticator
        if (!empty($AZURE_AD)) {
            $login_data = '{"username":"' . $username . '","password":"'. $password . '","ip":"' . $client_ip . '","host":"' . $host . '","cookie_hash":"' . $cookie_hash . '","farrms_client_dir":"' . $current_client_dir . '","session_id":"' . $session_id . '","win_auth":"' . $windows_auth . '","uti":"' . $AZURE_AD['uti'] . '"}';
        } else {
            $login_data = '{"username":"' . $username . '","password":"'. $password . '","ip":"' . $client_ip . '","host":"' . $host . '","cookie_hash":"' . $cookie_hash . '","farrms_client_dir":"' . $current_client_dir . '","session_id":"' . $session_id . '","win_auth":"' . $windows_auth . '"}';
        }
        $status = request_api('verify', $login_data);
	  
        $msg_arr = explode('|', $status[0]['Message']);
        $msg = $msg_arr[0];
        $enable_otp = $msg_arr[1] ?? 'n';
        $exceed_concurrent_login = strtolower($status[0]['ExceededLogins'] ?? 'n');
        $temp_pwd = isset($status[0]['TemporaryPassword']) ? $status[0]['TemporaryPassword'] : 'n';
        ## This temp_pwd Session is checked in include.main.files.php to check 
        ## if application is directly opened when password change popup is displayed
        if ($windows_auth == 0) {
            $_SESSION['temp_pwd'] = $temp_pwd;
        }
        if (!isset($_SESSION['farrms_client_dir'])) $_SESSION["farrms_client_dir"] = $current_client_dir;
        if (!isset($_SESSION['enable_data_caching'])) $_SESSION["enable_data_caching"] = isset($ENABLE_DATA_CACHING) ? $ENABLE_DATA_CACHING : 0;

        $recommendation = $status[0]['Recommendation'] ?? '';
        ## Checked if user is inactive or locked (Access not Given)
        if ($recommendation == 'y' || $recommendation == 'inactive' || $status[0]['ErrorCode'] == 'Error') {
            if ($windows_auth) {
                $msg = 'Windows authentication failed for current user. Please contact System Administrator.';
            }
            echo redirect_to_login($msg);          
        } else if ($status[0]['ErrorCode'] == 'Success') {
            ## Set the token to cookie to use it later for authorization
            set_cookie("_token", $status['token']);

            if (!isset($_SESSION['app_user_name'])) $_SESSION['app_user_name'] = $app_user_name;
            if (!isset($_SESSION['ui_settings'])) $_SESSION['ui_settings'] = '';
            if (!isset($_SESSION['dynamic_date_options'])) $_SESSION['dynamic_date_options'] = '';
            if (!isset($_SESSION['dynamic_date_adj_type_options'])) $_SESSION['dynamic_date_adj_type_options'] = '';
            if (!isset($_SESSION['client_date_format'])) $_SESSION['client_date_format'] = '';

            $_SESSION['login_success'] = true;
            $dateformat = setDateformat($_SESSION['date_format'] ?? '');
            
            if (isset($_SESSION['farrms_module'])) {
                $module_type = $_SESSION['farrms_module'];
            }
            
            ## Collect date informations
            $user_timezone = $status[0]['user_time_zone'];
            $expire_date = $status[0]['expire_date'];
            $user_date_format = $status[0]['user_date_format'];

            $_SESSION['userTimeZone'] = $user_timezone;

            if ($user_timezone != '')
                date_default_timezone_set($user_timezone);

            ## Mark the users in pwd_expire_not_apply_to_user as admin user so that password will not expire
            $user_list = explode(',', $pwd_expire_not_apply_to_user);
            $admin_user = (int) in_array($app_user_name, $user_list);
            $flag_pwd = false;
            ## If User password expiration is enabled check if expired and show the expiration message
            if ($expire_date != '' && $check_expire_function == 1 && $admin_user == 0 && $windows_auth == 0) {
                $expire_mm = date('m', strtotime($expire_date));
                $expire_dd = date('d', strtotime($expire_date));
                $expire_yy = date('Y', strtotime($expire_date));

                // $_SESSION['date_format'] should be set for convert_to_client_date_format function to work
                if (($_SESSION['date_format'] ?? '') == '') {
                    $_SESSION['date_format'] = $user_date_format;
                }
                $client_expire_date = convert_to_client_date_format($expire_date);
                $expire_date = date('Y/m/d', strtotime($expire_date));
                ## Date to start showing password expiration warning before password actually expires
                $pwd_expire_threshold = date('Y/m/d', mktime(0, 0, 0, $expire_mm, $expire_dd - $threshold_date, $expire_yy));
                $todays_date = date('Y/m/d');

                ## flag_pwd determines whether to show change password popup
                $user_mode = 2;
                if ($todays_date > $expire_date) {
                   $flag_pwd = true;
                   $msg = 'Your password has expired. Please change your password.';
                } else if ($todays_date >= $pwd_expire_threshold) {
                   $flag_pwd = true;
                   $user_mode = 1;
                   $msg = 'Your password will expire on ' . $client_expire_date . '. Please change your password.';
                } else if ($temp_pwd == 'y') {
                    $flag_pwd = true;
                    $msg = 'Your password is temporarily activated and will expire on ' . $client_expire_date . '. Please change your password.';
                }
                ## Show password change popup if password is expiring for non windows authentication users and if OTP is not enabled
                if ($flag_pwd == true && $windows_auth == 0 && $enable_otp == 0) {
                    echo "<script>
                            document.addEventListener('DOMContentLoaded', function() {
                               show_change_password();
                            }, false);
                        </script>";
                }
            }

            ## Change Password functions
            if ($flag_pwd == true && $windows_auth == 0 || $enable_otp == 1) {
                echo "<script>
                            function onPassChanged (is_pass_changed) {
                                if (is_pass_changed) {
                                    window.location.replace('../../../../" . $farrms_client_dir . "');
                                }
                            }

                            function show_change_password() {                                   
                                var user_pwd_window = new dhtmlXWindows();
                                var user_pwd_win = user_pwd_window.createWindow('w1', 0, 0, 370, 350);
                                user_pwd_win.setText(\"Change Password\");
                                user_pwd_win.centerOnScreen();
                                user_pwd_win.denyMove();
                                user_pwd_win.setModal(true);
                                if (\"$user_mode\" != 1) {
                                    user_pwd_win.button('close').hide();
                                }
                                user_pwd_win.button('minmax').hide();
                                user_pwd_win.button('park').hide();
                                user_pwd_win.attachURL(\"../../adiha.html.forms/_users_roles/maintain_users/maintain.pwd.php?call_from=login&user_login_id=" . $app_user_name . "&msg=" . $msg . "\", false, true);
                                
                                user_pwd_win.attachEvent(\"onClose\", function(win) {
                                    if (\"$user_mode\" == 2) { 
                                       window.location.replace('../../../../" . $farrms_client_dir . "');
                                    } else if (\"$user_mode\" == 1) {                  
                                        var menu_url = 'main.menu.trm.php';
                                        //console.log(menu_url);
                                        var w = screen.availWidth;
                                        var h = screen.availHeight - 30;
                                        
                                        window.open('', '_parent', 'menubar=0, width=' + w + ', left=0, top=0, height=' + h);
                                        // window.parent.close();
                                        
                                        winObj = window.open(menu_url, '_blank', 'menubar=0,resizable=yes, width=' + w + ', left=0, top=0, height=' + h);
                                        return true;
                                    }
                                });
                            }
                        </script>";
                if ($call_from_wp != 'wp' && $enable_otp != 1) exit();
            }
            
            // Two factor authentication (OTP)
            // Show OTP popup for non cloud mode if OTP is enabled
            // Set OTP as failed for CLOUD MODE
            if ($enable_otp == 1 && $CLOUD_MODE != 1) {
                $otp_message = 'Please enter the OTP.';
                $otp_url = "auth.otp.php?call_from=login&user_login_id=" . $app_user_name . "&msg=" . $otp_message . "&flag_pwd=" . (int) $flag_pwd;
                
                echo "<script> 
                           var otp_pwd_window = new dhtmlXWindows();
                            var otp_pwd_win = otp_pwd_window.createWindow('w2', 0, 0, 350, 200);
                            otp_pwd_win.setText(\"One Time Password (OTP)\");
                            otp_pwd_win.centerOnScreen();
                            otp_pwd_win.denyMove();
                            otp_pwd_win.setModal(true);
                            otp_pwd_win.button('close').hide();
                            otp_pwd_win.button('minmax').hide();
                            otp_pwd_win.button('park').hide();
                            otp_pwd_win.attachURL(\"" . $otp_url . "\", false, true);
                        </script>";
                die();
            }  else if ($enable_otp == 1 && $CLOUD_MODE == 1) {
                $_SESSION['otp_verified'] = "false";
            }
            // Two factor authentication (OTP) END
            
            ## Open Main Menu Window
            $menu_url = 'main.menu.trm.php';

            echo "<script>
                    var w = screen.availWidth;
                    var h = screen.availHeight - 30;

                    window.open('', '_parent', 'menubar=0, width=' + w + ', left=0, top=0, height=' + h);
                    window.parent.close();
                    window.open('$menu_url', '_blank', 'menubar=0,resizable=yes, width=' + w + ', left=0, top=0, height=' + h);
                 </script>";

            $clean_temp_file_url = $app_php_script_loc . '/dev/clean_temp_file.php?session_id=' . $session_id . '&__user_name__=' . $app_user_name;
        } else {
            $status[0]['ErrorCode'] = 'Error';
            $msg = 'Something went wrong. Please contact system administrator.';
            echo redirect_to_login($msg);
        }
    ?>
    <!-- Added missing jquery script which got lost during cloud integration -->
    <script language="JavaScript" src="../../adiha.php.scripts/components/jQuery/jquery-1.11.1.js"></script>
    <script type="text/javascript">
        $.ajax({
            url: '<?php echo $clean_temp_file_url; ?>',
            data: {},
            type: 'post',
            success: function(output) {}
        });
    </script>
    </body>
</html>
<?php
    ## Dump json object for wordpress login
    if ($call_from_wp == 'wp') {
        ob_clean();
        $data['status'] = $status[0]['ErrorCode']; $data['message'] = $msg; $data['name'] = ($status[0]['ErrorCode'] == 'Success' ? $status[0]['Recommendation'] : '');
        $data['type'] = $status[0]['cloud_user_type'];
        if ($user_mode == 1) {
            $data['temp_pwd'] = 'a'; // 'a' indicates its about to expire.
        } else {
            $data['temp_pwd'] = isset($flag_pwd) && $flag_pwd ? 'y' : 'n';
        }
        $data['user_login_id'] = $app_user_name;
        $data['license_agreement'] = isset($status[0]['cloud_license_agreement']) ? $status[0]['cloud_license_agreement'] : 'd';
        $data['enable_otp'] = isset($enable_otp) && $enable_otp == 1 ? 1 : 0;
        if (defined('OTP_EXPIRY_TIME') && is_int(OTP_EXPIRY_TIME)) {
            $data['otp_expiry_time'] = OTP_EXPIRY_TIME;
        }
        echo json_encode($data);
    }
?>