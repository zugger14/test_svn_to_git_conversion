<?php

/**
 *  @brief Application Connection
 *
 *  @par Description
 *  This class is used to establish connection to adiha_cloud db mainly and also establish connection to respective application database if necessary
 *  @copyright Pioneer Solutions
 */
class ResolveApplicationPathController extends REST {
    private $connect_adiha_db;

    /**
     * Initialize class
     */
    public function __construct() {
        $this->connect_adiha_db = new ResolveApplicationPath();
    }

    /**
     * Resolve application name
     *
     * @param   object  $body  JSON object containing user email address
     */
    public function resolveApplicationPath($body) {
        if ($this->connect_adiha_db) {
	        $app_path = $this->connect_adiha_db->resolveApplicationPath($body->username);
            if (is_array($app_path) && sizeof($app_path)) {
    	        $return_data['status'] = 'Success';
    	        $return_data['app_name'] = $app_path['app_name'];
    	        $return_data['company_catalog_id'] = $app_path['company_catalog_id'];
                $return_data['user_type'] = $app_path['user_type'];
                $return_data['user_login_id'] = $app_path['user_login_id'];
    	        $this->response($this->json($return_data), 200);
            } else {
                $this->sendError(200, 'Could not resolve application');
            }
        } else {
            $this->sendError(200, 'Could not establish connection to cloud database');
        }
    }

    /**
     * Generate recovery token
     *
     * @param   object  $body  JSON object containing user email address and recovery token
     */
    public function generateRecoveryToken($body) {
        if ($this->connect_adiha_db) {
            $recovery_token = $this->connect_adiha_db->generateRecoveryToken($body->username, $body->recovery_token);
            $return_data['status'] = $recovery_token['ErrorCode'];
            $return_data['user_type'] = $recovery_token['user_type'];
            $return_data['app_name'] = $recovery_token['app_name'];
            $this->response($this->json($return_data), 200);
        } else {
            $this->sendError(200, 'Could not generate recovery token');
        }
    }

    /**
     * Verify recovery token
     *
     * @param   object  $body  JSON object containing user email address and recovery token
     */
    public function verifyRecoveryToken($body) {
        if ($this->connect_adiha_db) {
            $recovery_token = $this->connect_adiha_db->verifyRecoveryToken($body->username, $body->recovery_token);
            $return_data['status'] = $recovery_token['ErrorCode'];
            $this->response($this->json($return_data), 200);
        } else {
            $this->sendError(200, 'Could not verify recovery token');
        }
    }

    /**
     * Reset user password
     *
     * @param   object  $body  JSON object containing user email address, recovery token and new password
     */
    public function resetPassword($body) {
        global $db_servername, $expire_date;

        if ($this->connect_adiha_db) {
            $verify_recovery_token = $this->connect_adiha_db->verifyRecoveryToken($body->username, $body->recovery_token);
            if (strtolower($verify_recovery_token['ErrorCode']) == 'valid') {
                $resolve_main_app_db = $this->connect_adiha_db->resolveMainAppDb($body->username);
            } else {
                $this->sendError(200, 'Password recovery token is not valid');
            }
        } else {
            $this->sendError(200, 'Could not reset password');
        }

        if ($resolve_main_app_db['db_server_name'] == NULL) {
            $resolve_main_app_db['db_server_name'] = $db_servername;
        }

        if ($resolve_main_app_db['db_user'] == NULL || $resolve_main_app_db['db_pwd'] == NULL) {
            $this->sendError(200, 'Invalid configuration in cloud. Could not establish connection to application\'s database.');
        }

        $connect_main_db = $this->connect_adiha_db->connectMainAppDb($resolve_main_app_db['db_server_name'], $resolve_main_app_db['company_db_name'], $resolve_main_app_db['db_user'], $resolve_main_app_db['db_pwd']);

        if ($connect_main_db) {
            $user_info = $this->connect_adiha_db->getUserInfo($body->username);
            $user_login_id = $user_info['user_login_id'];
            $first_name = $user_info['user_f_name'];
            $last_name = $user_info['user_l_name'];
            $new_pwd_encrypt = Auth::get_encrypted_password($user_login_id, $body->new_password);

            $verify_password_policy = SaasApplicationController::verifyPasswordPolicy($body->username, $body->new_password, $first_name, $last_name);

            if ($verify_password_policy['valid']) {
                $reset_password = $this->connect_adiha_db->resetUserPassword($body->username, $new_pwd_encrypt, $body->recovery_token, $expire_date);
                $return_data['status'] = $reset_password['ErrorCode'];
                $return_data['message'] = $reset_password['Message'];
            } else {
                $return_data['status'] = 'Error';
                $return_data['message'] = $verify_password_policy['message'];
            }

            # Expire recovery token to make it unusable
            if (strtolower($return_data['status']) == 'success') {
                $expire_recovery_token = $this->connect_adiha_db->verifyRecoveryToken($body->username, $body->recovery_token, true);
            }

            $return_data['policy'] = SaasApplicationController::buildPasswordPolicy($body->username, $body->new_password, $first_name, $last_name);
            $this->response($this->json($return_data), 200);
        } else {
            $this->sendError(200, 'Could not reset password');
        }
    }

    /**
     * Update license agreement
     *
     * @param   object  $body  JSON object containing user email address and approval status
     */
    public function updateLicenseAgreement($body) {
        if ($this->connect_adiha_db) {
            $license_agreement = $this->connect_adiha_db->updateLicenseAgreement($body->username, $body->agreement);
            $return_data['status'] = $license_agreement['ErrorCode'];
            $this->response($this->json($return_data), 200);
        } else {
            $this->sendError(200, 'Could not update license agreement');
        }
    }

    public function checkIfEmailIsAvailable($body) {
        if ($this->connect_adiha_db) {
            $user_email_check = $this->connect_adiha_db->checkIfEmailIsAvailable($body->user_email_address, $body->user_login_id);
            $return_data['message'] = $user_email_check['ErrorCode'];
            $this->response($this->json($return_data), 200);
        } else {
            $this->sendError(200, 'Could not check email address');
        }
    }

    public function createUser($body) {
        if ($this->connect_adiha_db) {
            $create_user = $this->connect_adiha_db->createUser($body->user_login_id, $body->user_f_name, $body->user_l_name, $body->user_email_address, $body->database_name, $body->db_server_name);
            $return_data['message'] = $create_user['ErrorCode'];
            $this->response($this->json($return_data), 200);
        } else {
            $this->sendError(200, 'Could not create user');
        }
    }

    public function updateUser($body) {
        if ($this->connect_adiha_db) {
            $update_user = $this->connect_adiha_db->updateUser($body->user_login_id, $body->user_f_name, $body->user_l_name, $body->user_email_address, $body->database_name);
            $return_data['message'] = $update_user['ErrorCode'];
            $this->response($this->json($return_data), 200);
        } else {
            $this->sendError(200, 'Could not update user');
        }
    }

    public function deleteUser($body) {
        if ($this->connect_adiha_db) {
            $delete_user = $this->connect_adiha_db->deleteUser($body->user_data);
            $return_data['message'] = $delete_user['ErrorCode'];
            $this->response($this->json($return_data), 200);
        } else {
            $this->sendError(200, 'Could not delete user');
        }
    }
}