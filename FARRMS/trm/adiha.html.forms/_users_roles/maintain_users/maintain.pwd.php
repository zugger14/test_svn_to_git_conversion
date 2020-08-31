<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    </head>
    <?php
    require('../../../adiha.php.scripts/components/include.file.v3.php');
    
    $form_name = 'form_user_password';
    $user_login_id = strtolower(get_sanitized_value($_GET['user_login_id'] ?? ''));
    $call_from = get_sanitized_value($_GET['call_from'] ?? '');
    $msg = get_sanitized_value($_GET['msg'] ?? '');

    $rights_change_password = 10111013;
    
    list (
        $has_rights_change_password
    ) = build_security_rights(
        $rights_change_password
    );

    $form_obj = new AdihaForm();
    $xml_url = "EXEC spa_application_users @flag = 'w', @user_login_id = '" . $user_login_id . "'";
    $result_set = readXMLURL($xml_url);
    $old_pwd = $result_set[0][0];
    $user_email = $result_set[0][4];
    
    $old_pwd_display = $old_pwd;
    $password_field_disabled = 'true';
    $enable_change_password = ($has_rights_change_password || $app_user_name == $user_login_id) ? 'false' : 'true';

    if ($app_user_name == $user_login_id) {
        $old_pwd_display = '';
        $password_field_disabled = 'false';
    }

    $layout_json = '[{
                            id:             "a",
                            text:           "Change Password",
                            width:          720,
                            header:         false,
                            collapse:       false,
                            fix_size:       [false,null]
                        }
                    ]';
    $deal_toolbar_json = '[
                        {id:"save", type:"button", img:"save.gif", imgdis:"save_dis.gif", text:"Save", title:"Save", disabled:' . $enable_change_password . '}
                    ]';
    $name_space = 'change_user_pwd';
    $layout_obj = new AdihaLayout();
    echo $layout_obj->init_layout('user_password_layout', '', '1C', $layout_json, $name_space);

    $toolbar_user = 'user_password_toolbar';
    echo $layout_obj->attach_toolbar_cell($toolbar_user, 'a');
    $toolbar_obj = new AdihaToolbar();
    echo $toolbar_obj->init_by_attach($toolbar_user, $name_space);
    echo $toolbar_obj->load_toolbar($deal_toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', 'user_password_toolbar');

    $form_obj = new AdihaForm();
    echo $layout_obj->attach_form($form_name, 'a');

    if (isset($CLOUD_MODE) && $CLOUD_MODE == 1)  {
        $general_form_structure = "[
            {type: 'label', label: '$msg', labelLeft: 20},
            {type: 'input', name: 'User Email', label: 'User Email:', value: '$user_email', disabled: true, width: 300, position: 'absolute', inputLeft: 20, inputTop: 60, labelLeft: 20, labelTop: 40, labelWidth: 200, className: 'combo_source_system_css'},
            {type: 'password', name: 'Old_Password', label: 'Old Password:', validate:'NotEmpty',userdata:{validation_message:'Required Field'}, value: '$old_pwd_display', width: 300, position: 'absolute', inputLeft: 20, inputTop: 110, labelLeft:  20, labelTop: 90, labelWidth: 200, className: 'combo_source_system_css', disabled: $password_field_disabled,required: 'True'},
            {type: 'password', name: 'New_Password', label: 'New Password:', validate:'NotEmpty',userdata:{validation_message:'Required Field'}, width: 300, position: 'absolute', inputLeft: 20, inputTop: 165, labelLeft: 20, labelTop: 145, labelWidth: 200, className: 'combo_source_system_css', required: 'True'},
            {type: 'password', name: 'Confirm_Password', label: 'Confirm Password:',  validate:'NotEmpty',userdata:{validation_message:'Required Field'}, width: 300, position: 'absolute', inputLeft: 20, inputTop: 220, labelLeft:  20, labelTop: 200, labelWidth: 200, className: 'combo_source_system_css', required: 'True'},
            ]";
    } else {
        $general_form_structure = "[
            {type: 'label', label: '$msg', labelLeft: 20},
            {type: 'input', name: 'User Name', label: 'User Name:', value: '$user_login_id', disabled: true, width: 300, position: 'absolute', inputLeft: 20, inputTop: 60, labelLeft: 20, labelTop: 40, labelWidth: 200, className: 'combo_source_system_css'},
            {type: 'password', name: 'Old_Password', label: 'Old Password:', validate:'NotEmpty',userdata:{validation_message:'Required Field'}, value: '$old_pwd_display', width: 300, position: 'absolute', inputLeft: 20, inputTop: 110, labelLeft:  20, labelTop: 90, labelWidth: 200, className: 'combo_source_system_css', disabled: $password_field_disabled,required: 'True'},
            {type: 'password', name: 'New_Password', label: 'New Password:', validate:'NotEmpty',userdata:{validation_message:'Required Field'}, width: 300, position: 'absolute', inputLeft: 20, inputTop: 165, labelLeft: 20, labelTop: 145, labelWidth: 200, className: 'combo_source_system_css', required: 'True'},
            {type: 'password', name: 'Confirm_Password', label: 'Confirm Password:',  validate:'NotEmpty',userdata:{validation_message:'Required Field'}, width: 300, position: 'absolute', inputLeft: 20, inputTop: 220, labelLeft:  20, labelTop: 200, labelWidth: 200, className: 'combo_source_system_css', required: 'True'},
            ]";
    }  

    echo $form_obj->init_by_attach($form_name, $name_space);
    echo $form_obj->load_form($general_form_structure);
    echo $layout_obj->close_layout();
    ?>
    <script type="text/javascript">
        var user_login_id = '<?php echo $user_login_id; ?>';
        var call_from = '<?php echo $call_from; ?>';
                
        user_password_toolbar = function(id) {
            if (id == 'save') {
                var new_pwd = change_user_pwd.form_user_password.getItemValue('New_Password');
                var confirm_pwd = change_user_pwd.form_user_password.getItemValue('Confirm_Password');
				var old_pwd = change_user_pwd.form_user_password.getItemValue('Old_Password');
                
                if (!validate_form(change_user_pwd.form_user_password)) {
                    return;
                }

                if (new_pwd != confirm_pwd) {
                    show_messagebox('Passwords do not match.');
                    return;
                }
                
                var data = {
                                'user_login_id': user_login_id,
                                'user_pwd': new_pwd,
                                'old_password': old_pwd,
                                '_csrf_token': _csrf_token
                            }
                
                if (call_from == 'maintain_user' || call_from == 'wp') {
                    var message = 'Are you sure you want to change the password?';
                    dhtmlx.message({
                        type: "confirm",
                        title: "Confirmation",
                        ok: "Confirm",
                        text: message,
                        callback: function(result) {
                            if (result) {
                                change_password(data);
                            }
                        }
                    });
                } else {
                    change_password(data);
                }
            }
        }

        function change_password(data) {
            $.post("pwd_user_roles.php", data, function(data, status) {
                if (status == 'success') {
                    var result = JSON.parse(data);
                    var response_data = result["json"];
                    var error_code = response_data[0]['errorcode'];
                    if (error_code == 'Success') {
                        if (call_from == 'maintain_user' || call_from == 'wp') {
                            var success_msg = 'Changes have been saved successfully.';
                        } else {
                            var success_msg = 'Password has been changed successfully. Please login with your new password.';
                        }
                        success_call(success_msg);
                        change_user_pwd.success_callback();
                    } else {
                        if (error_code == 'validation') {
                            var error_msg = " <div align='left' style='font-size:85%' ><b><u>Password Rules:</u></b><br />"
                                +"- Password should contain minimum of 8 and <br />"
                                +'\xa0\xa0'+"maximum of 32 characters.<br />"
                                +"- Password should contain at least one alphabet and <br />"
                                +'\xa0\xa0'+"one numeric character.<br />"
                                +"- Password should not contain \"Login Name\", \"First<br />"
                                +'\xa0\xa0\xa0'+"Name\" or \"Last Name\". <br />"
                                +"- Password should not contain spaces.<br />"
                                +"- Any character in password should not repeat more "
                                +'\xa0\xa0'+"than 4 times.<br />"
                                +"- New password should not match with previous four "
                                +'\xa0\xa0'+"passwords.</div>" ;
                        } else {
                            var error_msg = response_data[0]['message'];
                        }

                        show_messagebox(error_msg);
                    }
                }
            });
        }

        change_user_pwd.success_callback = function() {
			if (call_from == 'login') {
                parent.onPassChanged(true);
			} else if (call_from == 'maintain_user') {
				setTimeout("parent.new_win.close()", 1000);
			} else if (call_from == 'rp') {
                logout();
            } else if (call_from == 'wp') {
                redirect_to_home();
            }
        }

        //## Logouts from both application and wordpress site if temp pwd reset
        function logout() {
            $.ajax({
                type: "POST",
                url: js_php_path + 'spa_session_destroy.php',
                success:function(data) {
                    redirect_to_home();
                }
            })
        }

        function redirect_to_home() {
            parent.window.location = '<?php echo $webserver; ?>' + '/?action=change_password_success';
        }
    </script>
</html>