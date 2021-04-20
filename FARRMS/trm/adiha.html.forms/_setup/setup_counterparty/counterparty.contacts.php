<?php
/**
* Counterparty contacts screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
        <?php require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>

        <style type="text/css">
            html, body {
                width: 100%;
                height: 100%;
                margin: 0px;
                padding: 0px;
                background-color: #ebebeb;
                overflow: hidden;
            }
        </style>
    </head>
    <body>
        <?php
        $counterparty_id = get_sanitized_value($_GET['counterparty_id']);
        $counterparty_contact_id = ($_GET['counterparty_contact_id']) ? get_sanitized_value($_GET['counterparty_contact_id']) : -1;

        $function_id = 10105815;
        $rights_conterparty_contact_iu = 10105816;
        list (
            $has_rights_conterparty_contact_iu
        ) = build_security_rights(
            $rights_conterparty_contact_iu            
        );
        
        $form_namespace = 'counterpartyContacts';
        $form_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='" . $function_id . "', @template_name='Contacts', @group_name='General', @parse_xml = '<Root><PSRecordSet counterparty_contact_id=\"" . $counterparty_contact_id . "\"></PSRecordSet></Root>'";
        $form_arr = readXMLURL2($form_sql);
        $form_json = $form_arr[0]['form_json'];

        $layout_obj = new AdihaLayout();
        $toolbar_obj = new AdihaToolbar();
        $form_obj = new AdihaForm();
        $layout_json = '[{id: "a", header:false}]';
        $toolbar_json = '[{ id: "save", type: "button", img: "save.gif", imgdis: "save_dis.gif", text:"Save", title: "Save"}]';

        echo $layout_obj->init_layout('layout', '', '1C', $layout_json, $form_namespace);
        echo $layout_obj->attach_toolbar_cell("toolbar", "a");
        echo $toolbar_obj->init_by_attach("toolbar", $form_namespace);
        echo $toolbar_obj->load_toolbar($toolbar_json);
        if(!$has_rights_conterparty_contact_iu || $counterparty_id == '') {
            echo $toolbar_obj->disable_item('save');
        }
        echo $toolbar_obj->attach_event('', 'onClick', $form_namespace . '.save_click');

        // attach filter form
        $form_name = 'form_counterparty_contacts';
        echo $layout_obj->attach_form($form_name, 'a');
        $form_obj->init_by_attach($form_name, $form_namespace);
        echo $form_obj->load_form($form_json);

        echo $layout_obj->close_layout();
        ?>
    </body>
    <script type="text/javascript">
        counterpartyContacts.counterparty_contact_id = '<?php echo $counterparty_contact_id; ?>';
        has_rights_conterparty_contact_iu = '<?php echo $has_rights_conterparty_contact_iu; ?>';
        
        counterpartyContacts.save_click = function(id) {
            switch (id) {
                case 'save':
                    var object_id = (counterpartyContacts.counterparty_contact_id == -1) ? '' : counterpartyContacts.counterparty_contact_id;
                    var counterparty_id = '<?php echo $counterparty_id; ?>';
                    //var status = counterpartyContacts.form_counterparty_contacts.validate();

                    var valid = 1;
                    var email = counterpartyContacts.form_counterparty_contacts.getItemValue('email', true);  
                    var valid_email = validateMultipleEmails(email, ' ', 'email');   
                    if (valid_email == 'invalid') {
                        valid = 0;
                    }

                    var email_cc = counterpartyContacts.form_counterparty_contacts.getItemValue('email_cc', true); 
                    var valid_email_cc = validateMultipleEmails(email_cc, ' ', 'email_cc');   
                    if (valid_email_cc == 'invalid') {
                        valid = 0;
                    }

                    var email_bcc = counterpartyContacts.form_counterparty_contacts.getItemValue('email_bcc', true);
                    var valid_email_bcc = validateMultipleEmails(email_bcc, ' ', 'email_bcc');   
                    if (valid_email_bcc == 'invalid') {
                        valid = 0;
                    }

                    if (valid == 0) {
                        return;
                    }
                    
                    var status = validate_form(counterpartyContacts.form_counterparty_contacts);
                    if (status) {
                        counterpartyContacts.toolbar.disableItem('save');
                        form_data = counterpartyContacts.form_counterparty_contacts.getFormData();
                        var xml = '<Root function_id="10105815" object_id="' + object_id + '"><FormXML ';

                        for (var a in form_data) {
                            if (a!='counterparty_contact_id'&&a!='counterparty_id') {
                                if (counterpartyContacts.form_counterparty_contacts.getItemType(a) == 'calendar') {
                                    value = counterpartyContacts.form_counterparty_contacts.getItemValue(a, true);
                                } else {
                                    value = form_data[a];
                                }
                                xml += ' ' + a + '="' + value + '"';
                            }
                        }

                        // for New
                        if (!object_id) {
                            xml += ' counterparty_contact_id="" counterparty_id="' + counterparty_id + '"';
                        } else {
                            xml += ' counterparty_contact_id="' + counterpartyContacts.counterparty_contact_id + '" counterparty_id="' + counterparty_id + '"';
                        }

                        xml += ' ></FormXML></Root>';
                        
                        var param = {
                            "action": "spa_process_form_data",
                            "xml": xml
                        };

                        adiha_post_data('return_array', param, '', '', 'counterpartyContacts.save_callback', '');
                    } else {
                        generate_error_message();
                        return;
                    }
                break;
            }
        }

        counterpartyContacts.save_callback = function(result) {
            if (has_rights_conterparty_contact_iu) {
                counterpartyContacts.toolbar.enableItem('save');
            }

            if (result[0][0] == 'Success') {
                if(result[0][5]) {
                    counterpartyContacts.counterparty_contact_id=result[0][5];
                }
                
                success_call(result[0][4]);

                setTimeout(function() { 
                    window.parent.popup_window.window('w1').close();
                }, 1000);
            } else {
                show_messagebox(result[0][4]);
            }
        }

        function validateEmail(field) {
            var regex = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,5}$/;
            return (regex.test(field)) ? true : false;
        }

        function validateMultipleEmails(emailcntl, seperator, field_name) {  
            if (emailcntl != '') {  
                var result = emailcntl.split(seperator);  
                for (var i = 0; i < result.length; i++) {
                    if (result[i] != '') {
                        if (!validateEmail(result[i])) {
                           //  emailcntl.focus();
                            counterpartyContacts.form_counterparty_contacts.setValidateCss(field_name, true,'validate_error');
                            counterpartyContacts.form_counterparty_contacts.setNote(field_name,{text:'Invalid Email',width:100});   
                            return 'invalid';
                        } else {
                            counterpartyContacts.form_counterparty_contacts.resetValidateCss(field_name);
                            counterpartyContacts.form_counterparty_contacts.clearNote(field_name);
                        }
                    }
                }
            }
            return result;
        }
    </script>

</html>