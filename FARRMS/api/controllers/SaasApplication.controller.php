<?php

require_once('../trm/adiha.php.scripts/components/security.ini.php');

/**
 *  @brief Query application database
 *
 *  @par Description
 *  This class is used to query into application database and return output
 *  @copyright Pioneer Solutions
 */
class SaasApplicationController extends REST {
    /**
     * Change user password
     *
     * @param   object  $body  JSON object containing user information like user email address, current password and new password
     */
    public function changePassword($body) {
    	global $app_user_name, $expire_date;
        
        $user_info = SaasApplication::getUserInfo($body->username);
        $user_login_id = $app_user_name;
        $first_name = $user_info['user_f_name'];
        $last_name = $user_info['user_l_name'];

        $current_pwd_encrypt = Auth::get_encrypted_password($user_login_id, $body->current_password);
        $new_pwd_encrypt = Auth::get_encrypted_password($user_login_id, $body->new_password);

        $verify_password_policy = $this->verifyPasswordPolicy($body->username, $body->new_password, $first_name, $last_name);

        if ($verify_password_policy['valid']) {
	        $change_password = SaasApplication::changeUserPassword($body->username, $new_pwd_encrypt, $current_pwd_encrypt, $expire_date);

	        $return_data['status'] = $change_password['ErrorMessage'];
	        $return_data['message'] = $change_password['Message'];
		} else {
			$return_data['status'] = 'Error';
	        $return_data['message'] = $verify_password_policy['message'];
		}
		
		$return_data['policy'] = $this->buildPasswordPolicy($body->username, $body->new_password, $first_name, $last_name);

        $this->response(json_encode($return_data), 200);
    }

    /**
     * Create password policy rules
     *
     * @param   string  $user_email_id  User email address
     * @param   string  $new_pwd        New password
     * @param   string  $first_name     First name
     * @param   string  $last_name      Last name
     *
     * @return  string                  Return html
     */
    public static function buildPasswordPolicy($user_email_id, $new_pwd, $first_name, $last_name) {
	    global $pwd_min_char, $pwd_max_char, $allow_space, $character_can_repeat, $character_repeat_number, $alphabets_must_contain, $number_must_contain, $no_of_must_contain_char, $allow_login_name, $allow_first_name, $allow_last_name;

	    $new_pwd_len = strlen($new_pwd);
	    $user_login_id = $user_email_id;
	    $policy = "<ul>";

	    // Password Policy
	    $policy .= "<li>" . "Password should contain minimum " . $pwd_min_char . " characters.";
	    $policy .= "<li>" . "Password should not contain more than " . $pwd_max_char . " characters.";

	    if ($allow_space == false) {
	        $policy .= "<li>" . "Password should not contain spaces.";
	    }

	    if ($character_can_repeat == false) {
	        $policy .= "<li>" . "A character may not be repeated more than " . $character_repeat_number . " times.";
	    }

	    if ($alphabets_must_contain > 0) {
	        $policy .= "<li>" . "Password must consist of at least " . $alphabets_must_contain . " letter (A-Z or a-z) and " . $number_must_contain . " number (0-9).";
	    }

	    if ($no_of_must_contain_char > 0) {
	        $policy .= "<li>" . "Password should contain at least " . $no_of_must_contain_char . " special characters.";
	    }

	    if ($allow_login_name == false) {
	        $policy .= "<li>" . "Password must not contain the login name.";
	    }

	    if ($allow_first_name == false) {
	        $policy .= "<li>" . "Password must not contain user's first name.";
	    }

	    if ($allow_last_name == false) {
	        $policy .= "<li>" . "Password must not contain user's last name.";
	    }

	    $policy .= "</ul>";
	    return $policy;
	}

    /**
     * Verify password according to password policy
     *
     * @param   string  $user_email  User email address
     * @param   string  $new_pwd     New password
     * @param   string  $first_name  First name
     * @param   string  $last_name   Last name
     *
     * @return  array                Return validation status
     */
	public static function verifyPasswordPolicy($user_email, $new_pwd, $first_name, $last_name) {
        global $new_pwd_len, $pwd_min_char, $pwd_max_char, $allow_space, $character_can_repeat, $character_repeat_number, $alphabets_must_contain, $number_must_contain, $no_of_must_contain_char, $allow_login_name, $allow_first_name, $allow_last_name;

        $new_pwd_len = strlen($new_pwd);
        $user_login_id = $user_email;
        $valid = true;
        $message = "Password has been changed successfully.";

        /*=========================================================================================================================================================
         If the user enters a password that is less than 8 characters, the following message should be displayed: "Password should contain minimum 8 characters."
         ==========================================================================================================================================================*/

        if ($new_pwd_len < $pwd_min_char) {
            $message = "Password should contain minimum " . $pwd_min_char . " characters.";
            $valid = false;
        }

        /*=========================================================================================================================================================
         If the user enters a password more than 32 characters, the following message should be displayed: "Password should not contain more than 32 characters."
         =========================================================================================================================================================*/

        if ($new_pwd_len > $pwd_max_char) {
            $message = "Password should not contain more than " . $pwd_max_char . " characters.";
            $valid = false;
        }

        /*===============================================================================================================================
         If password contains spaces in any position, following error message should be displayed:"Password should not contain spaces."
         ===============================================================================================================================*/

        if ($allow_space == false) {
            $invalid_space = " ";

            if (strpos($new_pwd, $invalid_space)) {
                $message = "Password should not contain spaces.";
                $valid = false;
            }
        }


        /*=========================================================================================================================================================
         If a character is repeated more than 5 times in the password, it should display the following error message: "A character may not be 
         repeated more than five times."
         ===========================================================================================================================================================*/

        if ($character_can_repeat == false) {
            $char_count = count_chars($new_pwd);

            foreach ($char_count as $char) {
                if ($char > $character_repeat_number) {
                    $message = "A character may not be repeated more than " . $character_repeat_number . " times.";
                    $valid = false;
                }
            }
        }
        /*=========================================================================================================================================================
         If the password does not contain at least one alphabet (A-Z or a-z) and one number (0-9), following message should be displayed: 
         "Password must consist of at least one letter (A-Z or a-z) and one number (0-9)."
         ===========================================================================================================================================================*/

        if ($alphabets_must_contain > 0) {
            if(!preg_match("/[a-zA-Z]/i", $new_pwd) || !preg_match("/[0-9]/i", $new_pwd)) {
                $message = "Password must consist of at least " . $alphabets_must_contain . " letter (A-Z or a-z) and " . $number_must_contain . " number (0-9).";
                $valid = false;
            }
        }

        /*=========================================================================================================================================================
         If the password does not contain specified special character, following message should be displayed: 
         "Password must consist of at least (0-9) special character."
         ===========================================================================================================================================================*/

        if ($no_of_must_contain_char > 0) {
            if (preg_match_all('![^A-z0-9]!i', $new_pwd) < $no_of_must_contain_char) {
                $message = "Password should contain at least " . $no_of_must_contain_char . " special character.";
                $valid = false;
            }
        }

        /*=========================================================================================================================================================
         If password  is same as login name or if password contains the login name, it should display an error message "Password must not contain the login name."
         =========================================================================================================================================================*/
        if ($allow_login_name == false) {
            if (strpos(strtolower($new_pwd), $user_login_id) > -1) {
                $message = "Password must not contain the login name.";
                $valid = false;
            }
        }

        /*=========================================================================================================================================================
         If password  is same as the user's first name or if password contains the first name, it should display an error message "Password must not contain user's first name."
         =========================================================================================================================================================*/
        if ($allow_first_name == false) {
            if (strpos(strtolower($new_pwd), strtolower($first_name)) > -1) {
                $message = "Password must not contain user's first name.";
                $valid = false;
            }
        }


        /*=========================================================================================================================================================
         If password  is same as the user's last name or if password contains the last name, it should display an error message "Password must not contain user's last name." 
         ===========================================================================================================================================================*/
        if ($allow_last_name == false) {
            if (strpos(strtolower($new_pwd), strtolower($last_name)) > -1) {
                $message = "Password must not contain user's last name.";
                $valid = false;
            }
        }

        $return_data = array("valid" => $valid, "message" => $message);
        return $return_data;
    }
}
