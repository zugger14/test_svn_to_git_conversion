<?php
$farrms_dir_current = filter_var(trim($_GET['loaded_from'] ?? ''), FILTER_SANITIZE_STRING);
if ($farrms_dir_current == '') die();

require_once '../' . $farrms_dir_current . '/farrms.client.config.ini.php';
require_once '../' . $farrms_dir_current . '/product.global.vars.php';

$flag = isset($_GET['flag']) ? $_GET['flag'] : '';
$report_id = isset($_GET['report_id']) ? $_GET['report_id'] : 'NULL';
$authType = isset($_SERVER['AUTH_TYPE']) ? $_SERVER['AUTH_TYPE'] : '' ;
$azure_user_email =  isset($_GET['azure_user_email']) ? $_GET['azure_user_email'] : '';
$action = $_GET['action'] ?? '';

## If Windows Authentication build data and submit
## If not display the login form
$username = isset($_SERVER['AUTH_USER']) ? $_SERVER['AUTH_USER'] : '' ;
if(!empty($azure_user_email)) {
	$authType = 'Azure';
	$username = isset($azure_user_email) ? $azure_user_email : $username ;
}

# Delete existing cookies to avoid expiring session immediately. This should be done to prevent application from using old session for cases when user does not logout properly and tries to re-login later after session expiry.
if (isset($_SERVER['HTTP_COOKIE']) && $authType != 'Azure' && $action != 'skip_session_clear') {
    $cookies = explode(';', $_SERVER['HTTP_COOKIE']);
    foreach ($cookies as $cookie) {
        $parts = explode('=', $cookie);
        $name = trim($parts[0]);
        // unset all cookies except MFAID else OTP popup will appear on every login
        if (strpos($name, 'MFAID') === false && $name !== '_csrf_token') {
            $expires = time() - 42000;
            setcookie($name, '', ['expires' => $expires, 'path' => '', 'domain' => '', 'secure' => false, 'httponly' => true, 'samesite' => 'Lax']);
            setcookie($name, '', ['expires' => $expires, 'path' => '/', 'domain' => '', 'secure' => false, 'httponly' => true, 'samesite' => 'Lax']);
        }
    }
    if (session_status() !== PHP_SESSION_NONE) {
		session_destroy();
	}
}

## CSRF TOKEN generation
if (empty($_COOKIE['_csrf_token'])) {
    $_COOKIE['_csrf_token'] = bin2hex(random_bytes(32));
}
$_csrf_token = $_COOKIE['_csrf_token'];
setcookie('_csrf_token', $_csrf_token, ['expires' => 0, 'path' => '/', 'samesite' => 'Lax']);

if ($username != '' && $flag != 'login' && ($authType == 'Negotiate' || $authType == 'Azure')) {
    if (strpos($username, "\\") !== false) {
        $user_login_id_array = explode("\\", $username);
        $username = $user_login_id_array[1];
    }

	$action = 'main.menu/scripts/verify.php';
?>
    <!-- Form to post in case of Windows Authentication -->
    <form name="loginform" action="<?php echo $action; ?>" method="POST">
        <input type="hidden" name="_csrf_token" value="<?php echo $_csrf_token; ?>">
        <input type="hidden" name="txt_user_name" value="<?php echo $username; ?>">
        <input type="hidden" name="module_type" value="<?php echo $module_type; ?>">
        <input type="hidden" name="report_id" value="<?php echo $report_id; ?>">
        <input type="hidden" name="client_folder" value="<?php echo $farrms_dir_current; ?>">
    </form>
    <script>
        // Submit the form automatically
        document.loginform.submit();
    </script>
<?php
} else { 
    $message = isset($_GET['message']) ? $_GET['message'] : '';
    $message = filter_var(urldecode($message), FILTER_SANITIZE_STRING);
    $action_url = 'main.menu/scripts/verify.php';
    
    if ($report_id != '' && $report_id != 'NULL') {
        $action_url .= '?report_id=' . $report_id;
    }
?>
    <head>
        <title><?php echo $farrms_product_name; ?>: Login</title>
        <link href="main.menu/bootstrap-3.3.1/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="css/signin.css" rel="stylesheet">
        <!--[if lt IE 9]><script src="../../assets/js/ie8-responsive-file-warning.js"></script><![endif]-->
        <script src="adiha.login.screen/Scripts/ie-emulation-modes-warning.js"></script>
        <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
        <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
        <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
        <![endif]-->
        <style type="text/css">
            .error-message {
                /* color: red; */
                width: 400px;
                margin-top: 10px;
                /* font-style: italic; */
                font-family: "Open Sans", sans-serif!important;
            }
            
        </style>
    </head>
    <body oncontextmenu="return false;">
        <!-- Login Form -->
        <div class="container">
            <form name="loginform" class="form-signin" id="loginform" action="<?php echo $action_url; ?>" method="post">
                <input type="hidden" name="_csrf_token" value="<?php echo $_csrf_token; ?>">
                <div class="title"><?php echo $farrms_product_name; ?></div>
                <div class="form_container">
                    <span class="form_title">User Name</span>
                    <input type="textbox" id="inputEmail" name="txt_user_name" class="form-control us_img" placeholder="Username" required autofocus>
                    <span class="form_title">Password</span>
                    <input type="password" id="inputPassword" name="txt_password" class="form-control pw_img" placeholder="Password" required>
                    <input type="hidden" name="client_folder" value="<?php echo $farrms_dir_current; ?>">
                    <div class="checkbox">
                        <span class="alert_access">
                            <a data-toggle="modal" href="#" data-target="#myModal">Forgot Password?</a>
                        </span>
                        <div style="clear:both"></div>
                    </div>
                    <button class="btn btn-lg btn-login btn-block" type="submit" onclick="return check_validation();">Login</button>
                    <span id="error_msg" class="alert_access" style="width: 100%; padding-top: 5px; color: red;"><?php echo $message; ?></span>
                    <div class="footer">
                        <img src="adiha.login.screen/img/pioneer_logo.png" class="logo"/>
                    </div>
                </div>
            </form>
        </div>
        <!-- Account Recovery Modal -->
        <div class="modal fade" id="myModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
            <div id="setting-modal" class="modal-dialog" style="width: 400px!important">
                <div id="settings-modal-content" class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                        <h4 class="modal-title">Account Recovery</h4>
                    </div>  
                    <div id="config-tool" class="modal-body">
                        <div id="config-tool-options" >
                            <span class="form_title">* Email Address:</span>
                            <input class="form-control" type="text" name="email_address" id="email_address" />
                        </div>
                        <div id="errorMsg" class="error-message"></div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-default" onclick="submit_click()">Submit</button>
                    </div>
                </div>
            </div>
        </div>
    </body>
    <!-- IE10 viewport hack for Surface/desktop Windows 8 bug --> 
    <script src="adiha.login.screen/Scripts/ie10-viewport-bug-workaround.js"></script>
    <script src="main.menu/js/farrms_scripts/jquery-1.11.1.js"></script>
    <script src="main.menu/bootstrap-3.3.1/dist/js/bootstrap.js" type="text/javascript"></script>
    <script type="text/javascript">
        // Validate username and password
        function check_validation() {
            var username = document.loginform.txt_user_name.value;
            var password = document.loginform.txt_password.value;
            var error_msgObj = document.getElementById('error_msg');

            if (username != '' && password == '') {
                error_msgObj.innerHTML = 'The password is invalid.';
                return false;
            } else if (username == '' || password == '') {
                error_msgObj.innerHTML = 'The username or password is invalid.';
                return false;
            }
            return true;
        }
        
        // Validate Email and Proceed to Account Recovery 
        function submit_click() {
            var email_address = document.getElementById('email_address').value;
            var error_msg_obj = document.getElementById('errorMsg');

            if (email_address == '') {
                error_msg_obj.innerHTML = '<span>Please enter email address.</span>';
            } else if (email_address !='' && unescape(email_address).length > 150) {
                error_msg_obj.innerHTML = '<span>Email address should not exceed 150 characters.</span>';
            } else if (email_address != '' && !isEmail(email_address)) {
                error_msg_obj.innerHTML = '<span>Please enter a valid email address.</span>';
            } else {
                $.post("adiha.login.screen/user.account.recovery.php", {
                    user_email : email_address,
                    call_from : '<?php echo $farrms_dir_current; ?>'
                }, function(data) {
                    if (data.action == 'success') {
                        document.getElementById('errorMsg').innerHTML = '';
                        $('#myModal').find('.modal-body #config-tool-options').html(data.msg);
                        $('#myModal').find('.modal-footer').remove();
                    } else {
                        document.getElementById('errorMsg').innerHTML = data.msg;
                    }
                }, 'json');
            }
        }
        
        /**
         * Validates Email.
         * @param string str String to be validated.
         * @return True if satisfy else false.
         */
        function isEmail(str) {
            var regex = /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
            return regex.test(unescape(str));
        }
    </script>
<?php } ?>