<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    </head>
    <?php
    require('../../adiha.php.scripts/components/include.file.v3.php');
    include('../../adiha.php.scripts/components/security.ini.php');
    echo '<script type="text/javascript" src="../js/jquery.countdownTimer.min.js"></script>';

    $form_name = 'form_auth_otp';
    $user_login_id = (isset($_REQUEST['user_login_id'])) ? $_REQUEST['user_login_id'] : '';
    $call_from = (isset($_GET['call_from'])) ? $_GET['call_from'] : '';
    $msg = (isset($_GET['msg'])) ? $_GET['msg'] : '';
    $flag_pwd = (isset($_GET['flag_pwd'])) ? $_GET['flag_pwd'] : '';
    $old_password_status = true;
    $user_admin = false;
    $php_script_loc = $app_php_script_loc;
    $password_field_disabled = 'false';

    $_SESSION['otp_verified'] = "false";

    function curl_func($url, $headers, $fields, $is_post) {
        // Open connection
        $ch = curl_init();

        // Set the URL, number of POST vars, POST data
        curl_setopt( $ch, CURLOPT_URL, $url);
        if ($is_post)
            curl_setopt( $ch, CURLOPT_POST, true);
        curl_setopt( $ch, CURLOPT_HTTPHEADER, $headers);
        curl_setopt( $ch, CURLOPT_RETURNTRANSFER, true);
        if ($is_post)
            curl_setopt( $ch, CURLOPT_POSTFIELDS, $fields);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
         if ($is_post)
            curl_setopt($ch, CURLOPT_POST, true);
         curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

        // Execute post
        $result = curl_exec($ch);

        // Close connection
        curl_close($ch);
        return json_decode($result);

    }

try {

    //Generate OTP Passcode
    $actual_link = (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? "https" : "http") . "://$_SERVER[HTTP_HOST]$_SERVER[REQUEST_URI]";
    $actual_link_arr = explode('/trm/', $actual_link);
    //echo '<pre>'; var_dump($actual_link_arr[0]); echo '</pre>'; die();
    //$url1 = 'https://trmdev.farrms.us/TRMTracker_DEV/api/index.php?route=otp/generate';

    $url1 = $actual_link_arr[0] . '/api/index.php?route=otp/generate';
    //$url2 = 'https://trmdev.farrms.us/TRMTracker_DEV/api/index.php?route=otp/verify';
    $url2 = $actual_link_arr[0] . '/api/index.php?route=otp/verify';
    $menu_url = 'main.menu.trm.php';
    $headers = array(
                'Content-Type: application/json'
            );

    if (isset($_REQUEST['call_from']) && $_REQUEST['call_from'] == 'otp_verification') {
        $fields_len = '{"secret":"' . $_REQUEST['secret_key'] . '","otp":"' . $_REQUEST['otp'] . '"}';
        $results = curl_func($url2, $headers, $fields_len, true);
        $otp_status = $results->otp_status;
        ob_clean();
        if ($otp_status) {
          $_SESSION['otp_verified'] = "true";
        }
        $_SESSION['otp_verified'] = "true";
        $otp_status = ($otp_status) ? 'true' : 'false';
        if ($otp_status == 'true') {
            $ip = $_SERVER['REMOTE_ADDR'];
            $host = $ip;
            
            // Set Cookie to skip OTP Verification on next login
            $cookie_hash = md5(strtolower($app_user_name . $_COOKIE["client_folder"]));
            set_cookie('MFAID', $cookie_hash, time() + (86400 * 30));

            $xml_url = "EXEC spa_system_access_log @flag='i',@user_login_id_var='" . $user_login_id . "', @system_address='" . $ip . "', @system_name='" . $host . "', @status='Success', @cookie_hash='" . $cookie_hash . "'";
            $result_set = readXMLURL($xml_url);
        }
        echo '{"status":"'. $otp_status .'"}'; die();
    }

    $fields_len = '{}';
    $results = curl_func($url1, $headers, $fields_len, false);
    $otp_val = $results->otp;
    $secret_val = $results->secret_key;

    //Generate OTP Passcode END

    // Send Email to user with OTP code
    $xml_url = "EXEC spa_otp_auth @flag = 's', @user_login_id = '" . $user_login_id . "', @otp_code = '" . $otp_val . "'";
    $result_set = readXMLURL($xml_url);
    $status = $result_set[0][0];
    if ($status == 'Success') {
        $user_emal_add = $result_set[0][5];
        $a = explode('.', $user_emal_add);
        $msg_str = substr($user_emal_add, 0, 3) .'***@' . substr(explode('@', $user_emal_add)[1], 0, 3) . '***.' . $a[count($a)-1];
        $msg = 'OTP send to ' . $msg_str . '. Please check your junk emails if you have not received the OTP yet.';
        if (isset($_POST['call_from']) && $_POST['call_from'] == 'resend_otp') {
            ob_clean();
            echo '{"status": "true", "secret_val":"'. $secret_val .'"}'; 
            die();
        }

    }

    // Send Email to user with OTP code END
    $layout_json = '[{
                            id:             "a",
                            text:           "Change Password",
                            width:          330,
                            header:         false,
                            collapse:       false,
                            fix_size:       [true,null]
                        }
                    ]';
    $deal_toolbar_json = '[
                        {id:"save", type:"button", img:"save.gif", imgdis:"save_dis.gif", text:"OK", title:"Ok"},
                        {id:"resend", type:"button", img:"save.gif", imgdis:"save_dis.gif", text:"Resend", title:"Resend", disabled:true, hidden:true}
                    ]';
    $name_space = 'otp_user_passcode';
    $layout_obj = new AdihaLayout();
    echo $layout_obj->init_layout('otp_user_layout', '', '1C', $layout_json, $name_space);

    $toolbar_user = 'otp_user_toolbar';
    echo $layout_obj->attach_toolbar_cell($toolbar_user, 'a');
    $toolbar_obj = new AdihaToolbar();
    echo $toolbar_obj->init_by_attach($toolbar_user, $name_space);
    echo $toolbar_obj->load_toolbar($deal_toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', 'otp_user_toolbar');

    $form_obj = new AdihaForm();
    echo $layout_obj->attach_form($form_name, 'a');
    $user_login_id = $user_login_id;
    $msg = '<div id="otp_msg_label" style="font-size:10px;"><span id="otp_msg_box">' . $msg . '</span>';
    $msg .= ' <span id="otp_msg_expire_box">Your OTP expires in <span id="reverse_countdown_otp"></span></span></div>';

    $general_form_structure = "[
        {type: 'label', label: '$msg', labelLeft: 20, className:'otp_label'},
        {type: 'input', name: 'OTP_passcode', label: 'Please enter the OTP:', validate:'NotEmpty',userdata:{validation_message:'Required Field'}, value: '', disabled: false, width: 250, position: 'absolute', inputLeft: 20, inputTop: 70, labelLeft: 20, labelTop: 50, labelWidth: 180, className: 'combo_source_system_css'},
        {type: 'input', name: 'secret_key', label: 'Secret Key:', validate:'NotEmpty',userdata:{validation_message:'Required Field'}, value: '$secret_val', width: 200, position: 'absolute', inputLeft: 20, inputTop: 120, labelLeft:  20, labelTop: 100, labelWidth: 120, className: 'combo_source_system_css', disabled: 'true', hidden:'true', required: 'True'},
        ]";

    echo $form_obj->init_by_attach($form_name, $name_space);
    echo $form_obj->load_form($general_form_structure);
    echo $layout_obj->close_layout();

} catch(Exception $e) {
    echo 'Caught exception: ',  $e->getMessage(), "\n";
    die();
}
    
    ?>
    <script type="text/javascript">

        var user_login_id = '<?php echo $user_login_id; ?>';
        var call_from = '<?php echo $call_from; ?>';
        var cloud_mode = '<?php echo $CLOUD_MODE; ?>';  
        var url2 = '<?php echo $_SERVER['PHP_SELF'];?>';
        var msg = '<?php echo $msg; ?>';
        var otp_expire_min = '<?php echo (defined("OTP_EXPIRY_TIME") && is_int(OTP_EXPIRY_TIME)) ? OTP_EXPIRY_TIME : 2; ?>';
        var otp_expire_sec = 0;
        count_otp_wront_attempts = 0; 
        count_otp_timeup_attempts = 0;
        count_otp_resend_timeup_enable = 0;
        var request_protocol = '<?php echo get_request_protocol(); ?>';

        $(function(){
			$('div.dhxlayout_cont').width(320);
			$('div.dhx_cell_layout').width(320);
			$('div.dhx_cell_cont_layout').width(320);
			$('div.otp_label').css('padding-left','15px');
			
			$("#reverse_countdown_otp").countdowntimer({"minutes" : otp_expire_min,"seconds" : otp_expire_sec, "timeUp" : time_is_up});
        });

        function time_is_up() {
          count_otp_timeup_attempts++;
            if (count_otp_timeup_attempts > 1) {
                var parent_url = window.parent.parent.location.href;                                    
                window.parent.parent.location.href = parent_url;
            }
            $("#reverse_countdown_otp").countdowntimer("destroy");
            count_otp_resend_timeup_enable = 1;         
          $('#otp_msg_label').html('<span style="color:red">Your OTP has been expired. Please resend a request within <span id="reverse_countdown_otp_resend"></span>.</span>')
          $("#reverse_countdown_otp_resend").countdowntimer({"minutes" : otp_expire_min,"seconds" : otp_expire_sec, "timeUp" : time_is_up_resend});
          otp_user_passcode.otp_user_toolbar.showItem('resend');
          otp_user_passcode.otp_user_toolbar.enableItem('resend');
          otp_user_passcode.otp_user_toolbar.disableItem('save');
          otp_user_passcode.form_auth_otp.setItemValue("OTP_passcode", "");
          otp_user_passcode.form_auth_otp.disableItem("OTP_passcode");
        }

        function time_is_up_resend() {
            var parent_url = window.parent.parent.location.href;     
            if (count_otp_resend_timeup_enable == 1)                               
            window.parent.parent.location.href = parent_url;
        }
        
        otp_user_toolbar = function(id) {
            switch (id) {
                case 'save': 
                        // code verify otp and redirect to application
                        var form_valid = otp_user_passcode.form_auth_otp.validate();
                        if(!form_valid) {
                            return false;
                        }
                        otp_user_passcode.otp_user_layout.cells('a').progressOn();
                        var asynchonous_status =  false;
                        var secret_key = otp_user_passcode.form_auth_otp.getItemValue("secret_key");
                        var otp_code = otp_user_passcode.form_auth_otp.getItemValue("OTP_passcode");

                        var data = {"user_login_id": user_login_id, "secret_key":secret_key,"otp":otp_code, "call_from":"otp_verification"};
                        $.ajax({
                            type: "POST",
                            contentType: "application/x-www-form-urlencoded",
                            url: url2,
                            async: asynchonous_status,
                            data: data,
                            success: function(data) {
                                var data_json = JSON.parse(data);
                                console.log(data_json);
                                if (data_json.status == 'true') {
                                    w = screen.availWidth;
                                    h = screen.availHeight - 30;
                                    
                                    //var used_skin = '".$result_set[0][31]."';
                                    var used_skin = 'theme-jomsomGreen';
                                    used_skin = (used_skin == null) ? 'theme-jomsomGreen' : used_skin;

                                    var flag_pwd = "<?php echo $flag_pwd;?>";
                                    if (flag_pwd == 1) {
                                        parent.show_change_password();
                                    } else {
                                        var parent_url = window.parent.parent.location.href; 
                                        var ua = window.navigator.userAgent;
                                        var msie = ua.indexOf("MSIE ");
                                        if (msie > 0 || !!navigator.userAgent.match(/Trident.*rv\:11\./)) // If Internet Explorer, return version number
                                        {
                                            window.parent.open('', '_parent', 'menubar=0, width=' + w + ', left=0, top=0, height=' + h);
                                            window.parent.parent.close();
                                        }
                                        else  // If another browser, return 0
                                        {
                                            window.parent.parent.location.href = parent_url;
                                        }
                                        window.open('<?php echo $menu_url;?>', '_blank', 'menubar=0,resizable=yes, width=' + w + ', left=0, top=0, height=' + h);    
                                    }                                    
                                } else {//console.log('test');
                                    if (count_otp_wront_attempts > 2) {
                                        var parent_url = window.parent.parent.location.href;                                    
                                        window.parent.parent.location.href = parent_url;
                                    }
                                    count_otp_wront_attempts++;
                                    otp_user_passcode.form_auth_otp.setItemValue("OTP_passcode", "");
                                    $('#otp_msg_label').children('span#otp_msg_box').html('<span style="color:red">Wrong OTP. ' + count_otp_wront_attempts + ' attempt(s) out of 4.</span>')
                                    $('#otp_msg_label').children('span#otp_msg_expire_box').css('color','red');    
                                    otp_user_passcode.otp_user_layout.cells('a').progressOff();                             
                                }
                            }

                        });
                    break;

                case 'resend':                    
                    otp_user_passcode.otp_user_layout.cells('a').progressOn();   
                    count_otp_wront_attempts = 0;                 
                      var url3 = "auth.otp.php?user_login_id=" + user_login_id;
                      var data = {"call_from":"resend_otp"};
                      $.ajax({
                            type: "POST",
                            contentType: "application/x-www-form-urlencoded",
                            url: url3,
                            async: false,
                            data: data,
                            success: function(data) {
                                console.log(data);
                                otp_user_passcode.otp_user_layout.cells('a').progressOff();
                                var data_json = JSON.parse(data);

                                if (data_json.status == 'true') {
                                    count_otp_resend_timeup_enable = 0;
                                     $("#reverse_countdown_otp_resend").countdowntimer("destroy");
                                    otp_user_passcode.form_auth_otp.enableItem("OTP_passcode");
                                    otp_user_passcode.form_auth_otp.setItemValue("secret_key", data_json.secret_val);
                                    $('.otp_label').children('div').html(msg)
                                      otp_user_passcode.otp_user_toolbar.enableItem('save');
                                      otp_user_passcode.otp_user_toolbar.disableItem('resend');
                                      otp_user_passcode.otp_user_toolbar.hideItem('resend');                                      
                                      $("#reverse_countdown_otp").countdowntimer({"minutes" : otp_expire_min,"seconds" : otp_expire_sec, "timeUp" : time_is_up});
                                    console.log(1);
                                } else {  
                                    console.log(2);                              
                                }
                            }

                        });
                    break;

                case 'default':
                    break;

            }

        }

        otp_user_passcode.success_callback = function(result) {
            var call_from = '<?php echo $call_from; ?>';
            if(result[0].errorcode == 'Success'){       
                if (call_from == 'login') {
                    // setTimeout("parent.user_pwd_win.close()", 2000);
                    parent.onPassChanged(true);
                } else if (call_from == 'maintain_user') {
                    setTimeout("parent.new_win.close()", 1000);
                } else if (call_from == 'rp') {
                    logout();
                } else if (call_from == 'wp') { 
                	
                	// created request _protocal js varable 
                    parent.window.location =  request_protocol + '://' + '<?php echo $_SERVER['SERVER_NAME']; ?>';
                }
            }   
        }

        //## Logouts from both application and wordpress site if temp pwd reset
        function logout() {
            $.ajax({
                type: "POST",
                url: js_php_path + 'spa_session_destroy.php',
                success:function(data) {
                    parent.window.location = request_protocol + '://' + '<?php echo $_SERVER['SERVER_NAME']; ?>' + '/wp-login.php?action=logout';
                }
            })
        }

    </script>
</html>