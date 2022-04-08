<?php
/**
 * Included to use JSON Web Tokens (JWT) Library
 */
use \Firebase\JWT\JWT;

/**
*  @brief AuthController Authorization Controller extends REST Class
*  @par Description
*  This class is used to authenticate device and user authorization 
*  @copyright Pioneer Solutions.
*/
class AuthController extends REST {
    private $need_dateformat = 1;
    private $need_token_expiry = 0;
    private $app_user_name;
    public $application_validation = 0;
    
    /**
     * Constructor
     *
     * @param   String  $app_user_name  User Login
     */
    public function __construct($app_user_name = null) {
        parent::__construct();
        if ($app_user_name) {
            $this->app_user_name = $app_user_name; 
        }
    }

    /**
     * It handles the login authentication
     * 
     * @param  Object $body Request Payload
     * 
     * @return Object       Token and Validation Data
     */
    public function postLogin($body) {
        global $farrms_client_dir, $win_auth, $db_servername, $database_name, $CLOUD_MODE, $db_user, $db_pwd, $session_id, $ENABLE_DATA_CACHING;
        global $account_lockout_number_attempts, $account_lockout_time_range, $cloud_user_type, $cloud_license_agreement, $cloud_license_expiration, $threshold_date, $saas_application_name, $uti;

        $password = $body->password;
        $ip = $_SERVER['REMOTE_ADDR'];
        $ip = (property_exists($body, 'ip')) ? $body->ip : $ip;
        $host = (property_exists($body, 'host')) ? $body->host : $ip;
        $cookie_hash = (property_exists($body, 'cookie_hash')) ? $body->cookie_hash : "NULL";
        ## Check if api is called from windows authentication, this value is passed while login from verify page
        $win_auth = (property_exists($body, 'win_auth')) ? $body->win_auth : $win_auth;
        $results = Auth::login($this->app_user_name, $password, $ip, $host, $win_auth, $account_lockout_number_attempts, $account_lockout_time_range, $CLOUD_MODE, $farrms_client_dir, $cookie_hash);
        if (isset($results[0]['ErrorCode']) && $results[0]['ErrorCode'] == 'Success') {
            $body_token = (property_exists($body, 'token')) ? $body->token : '';
            $body_os = (property_exists($body, 'os')) ? $body->os : '';
            
            if ($body_os != '')
                Auth::addDevice($this->app_user_name, $password, $body_token, $body_os);
            
            $key = "Bearer";
            $time = time();
            
            $token["iss"] = "http://" . $_SERVER['HTTP_HOST'];
            $token["aud"] = "http://" . $_SERVER['HTTP_HOST'];
            $token["iat"] = $time;
            $token["nbf"] = 0;
            $token["username"] = $this->app_user_name;
            $token["db_servername"] = $db_servername;
            $token["database_name"] = $database_name;
            $token["db_user"] = $db_user;
            $token["db_pwd"] = $db_pwd;
            $token["farrms_client_dir"] = $farrms_client_dir;

            ## This will be used to verify user logging in using Azure Active Directory
            if (!empty($uti)) {
                $token["uti"] = $uti;
            }

            if ($this->need_token_expiry == 1) {
                $token_result = Auth::tokenExpireDays();
                $tokenExpireDays = $token_result[0]['tokenExpiryDays'];
                $exp_time = $time + (86400 * $tokenExpireDays);
                
                $token["exp"] = $exp_time;
            }
            
            $jwt = JWT::encode($token, $key);
            
            $date_format = Auth::dateFormat();
            
            if ($this->need_dateformat == 1) {
                $json = array('token' => $jwt, 'date_format' => $date_format[0]['date_format']);
            } else {
                $json = array('token' => $jwt);
            }

            # Execute script below only if request is from cloud website. Script below sets session in main database which is not required for other callers (Eg; Excel Add-In, Mobile Apps etc)
            $call_from_wp = (property_exists($body, 'call_from_wp')) ? strtolower($body->call_from_wp) : '';
            if ($CLOUD_MODE && $call_from_wp == 'wp') {
                $application_access = true;
                $msg_arr = explode('|', $results[0]['Message']);
                $results[0]['Message'] = $msg_arr[0];
                $results[0]['enable_otp'] = isset($msg_arr[1]) ? $msg_arr[1] : 0;
                $results[0]['user_login_id'] = $this->app_user_name;
                $results[0]['otp_expiry_time'] = OTP_EXPIRY_TIME;
                $results[0]['cloud_user_type'] = $cloud_user_type;
                $results[0]['cloud_license_agreement'] = $cloud_license_agreement;
                $results[0]['cloud_license_expiration'] = $cloud_license_expiration;
                $results[0]['db_name'] = $database_name;
                $results[0]['application_name'] = $saas_application_name;

                # Logic to start showing password expiration warning before password actually expires
                if (!$win_auth) {
                $todays_date = date('Y/m/d');
                $expire_date = $results[0]['expire_date'];
                $expire_mm = date('m', strtotime($expire_date));
                $expire_dd = date('d', strtotime($expire_date));
                $expire_yy = date('Y', strtotime($expire_date));
                $pwd_expire_threshold = date('Y/m/d', mktime(0, 0, 0, $expire_mm, $expire_dd - $threshold_date, $expire_yy));
                $expire_date = date('Y/m/d', strtotime($expire_date));

                if ($todays_date > $expire_date) {
                    $results[0]['Message'] = 'Your password has expired. Please change your password.';
                    $application_access = false;
                    # This will make sure user is forced to change password in website.
                    $results[0]['TemporaryPassword'] = 'y';
                } else if ($todays_date >= $pwd_expire_threshold) {
                    #'a' indicates password is about to expire
                    $results[0]['TemporaryPassword'] = 'a';
                    $results[0]['Message'] = 'Your password will expire on ' . $expire_date . '. Please change your password.';
                } else if ($results[0]['TemporaryPassword'] == 'y') {
                    $results[0]['Message'] = 'Your password is temporarily activated and will expire on ' . $expire_date . '. Please change your password.';
                    $application_access = false;
                }
                } else {
                    # For sign in using Azure AD
                    $results[0]['TemporaryPassword'] = 'n';
                }

                if (!empty($uti) && $win_auth) {
                    # For sign in using Azure AD
                    $session_data = 'app_user_name|' . serialize($this->app_user_name) . 'uti|' .serialize($uti);
                } else if ($results[0]['enable_otp'] && !$win_auth) {
                    # When user needs to enter OTP
                    $session_data = 'app_user_name|' . serialize($this->app_user_name) . 'otp_verified|' . serialize('false');
                } else {
                    # Normal login where OTP is not asked 
                    $session_data = 'app_user_name|' . serialize($this->app_user_name);
                }

                if (!$application_access) {
                    $session_data .= 'temp_pwd|' . serialize('y');
                }

                $session_data .= 'farrms_client_dir|' . serialize($farrms_client_dir);
                $enable_cache = isset($ENABLE_DATA_CACHING) ? $ENABLE_DATA_CACHING : 0;
                $session_data .= 'enable_data_caching|' . serialize($enable_cache);                

                // Initialize session
                Auth::initializeSession($this->app_user_name, $session_id, $session_data, $ip, $host);
            }

            if ($this->application_validation == 1)
                $json = array_merge($results, $json);          

            $this->response($this->json($json), 200);
        } else {
            if ($this->application_validation == 1) {
                $this->response($this->json($results), 200);
            } else if (is_array($results[0]) && !empty($results[0]['Message'])) {
                $return_data['message'] = $results[0]['Message'];
                $this->response($this->json($return_data), 200);
            } else {
                $this->sendError(401, 'Bad login');
            }
        }
    }
    
    /**
     * Validate Login
     *
     * @param   String  $token  Token to be validated
     *
     * @return  Array          Success with Decoded User Information
     */
    public function validLogin($token) {
        $token_arr = explode(' ', $token);
        $key = $token_arr[0];
        try {
            $decoded = JWT::decode($token_arr[1], $key, array('HS256'));
            if ($decoded) {
                $decoded_array = (array) $decoded;
                return $decoded_array;
            } else {
                $this->sendError(401, 'Bad login');  
            }
        } catch(Exception $e) {
            $this->sendError(401, 'Bad login');
        }        
        
    }
    
    /**
     * Get Reporting Service Information
     *
     * @return  Array  SRRS Connection Detail
     */
    public function getSSRSLogin() {
        $results = Auth::getSSRSLogin();
    }
    
    /**
     * List of All Devices
     *
     * @return  JSON  List of Devices Information
     */
    public function getLoginDevice() {
        $results = Auth::listDevice();
        $this->response($this->json($results), 200);
    }
    
    /**
     * get User Date Format
     *
     * @return  JSON  Date Format
     */
    public function getDateFormat() {
        $results = Auth::dateFormat();
        $this->response($this->json($results[0]), 200);
    }
    
    /**
     * Format provided Date based on User Format
     *
     * @param   String  $date  Date String
     *
     * @return  JSON          Formatted Date String
     */
    public function getDateWithFormat($date) {
        $results = Auth::dateWithFormat($date);
        $this->response($this->json($results[0]), 200);
    }
        
    /**
     * Logged Out
     *
     * @return  Array  Success or Failure
     */
    public function logout() {
        $results = Auth::logout();
    }
    
    /**
     * Request Token
     * 
     * @param  Object $body Request Payload
     * 
     * @return Object       Token and Validation Data
     */
    public function requesttoken($body) {
        $this->need_dateformat = 0;
        $this->need_token_expiry = 1;
        $response = $this->postLogin($body);
    }

    /**
     * Verify Login Details
     * 
     * @param  Object $body Request Payload
     * 
     * @return Object       Token and Validation Data
     */
    public function verifyLoginDetails($body) {
        $this->application_validation = 1;
        $response = $this->postLogin($body);
    }
}
