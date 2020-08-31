<?php

use \OTPHP\TOTP;

class OtpController extends REST {
	protected $period = 10;
	protected $window = 12;
	protected $timecode;
	protected $start_time;
	protected $elapsed_time_since_otp_creation;

	public function __construct() {
		$this->timecode = (int) floor(time() / $this->period);
		$this->start_time = $this->timecode * $this->period;
		$this->elapsed_time_since_otp_creation = time() - $this->start_time;
	}

    public function generate() {
        global $app_user_name;
		$totp = TOTP::create(null, $this->period, 'sha1', 6);
		$otp_key = $totp->now();
		$totp_arr = (array) $totp;
        $json = array('otp' => $otp_key, 'secret_key' => array_values($totp_arr)[0]['secret']);
        //echo $this->elapsed_time_since_otp_creation;
		$this->response(json_encode($json), 200);
    }
    
    public function validOtp($body) {
		$otp = $body->otp;
		$secret = $body->secret;

		if (defined('OTP_EXPIRY_TIME') && is_int(OTP_EXPIRY_TIME)) {
			$this->window = ((OTP_EXPIRY_TIME * 60) / 10); // Since period is defined as 10
		}

		$totp = TOTP::create($secret, $this->period, 'sha1', 6);
        $otp_status = $totp->verify($otp, null, $this->window);

        // Update session data 'otp_verified' to 'true' to allow access to application
        if ($otp_status && property_exists($body, 'session_id')) {
	        $system_access_log = Otp::system_access_log($body->user_email, $body->cookie_hash);
	        $allow_application_access = Otp::allow_application_access($body->session_id);
        }

		$json = array('otp_status' => $otp_status);
		//echo $this->window;
		$this->response($this->json($json), 200);
    }
}