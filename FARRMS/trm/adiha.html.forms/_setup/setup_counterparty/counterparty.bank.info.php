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

        $function_id = 10105845;
        $rights_conterparty_bank_iu = 10105846;
        list (
            $has_rights_conterparty_bank_iu
        ) = build_security_rights(
            $rights_conterparty_bank_iu            
        );
        $form_namespace = 'counterpartyBankInfo';
        echo $form_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='" . $function_id . "', @template_name='counterparty_bank_info', @group_name='General', @parse_xml = '<Root><PSRecordSet bank_id=\"" . $counterparty_contact_id . "\"></PSRecordSet></Root>'";
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

        if(!$has_rights_conterparty_bank_iu) {
            echo $toolbar_obj->disable_item('save');
        }

        echo $toolbar_obj->attach_event('', 'onClick', $form_namespace . '.save_click');

        // attach filter form
        $form_name = 'form_counterparty_bank_info';
        echo $layout_obj->attach_form($form_name, 'a');
        $form_obj->init_by_attach($form_name, $form_namespace);
        echo $form_obj->load_form($form_json);

        echo $layout_obj->close_layout();
        ?>
    </body>
    <script type="text/javascript">
    has_rights_conterparty_bank_iu = '<?php echo $has_rights_conterparty_bank_iu; ?>';
        counterpartyBankInfo.counterparty_contact_id = '<?php echo $counterparty_contact_id; ?>';
        counterpartyBankInfo.save_click = function(id) {
            switch (id) {
                case 'save':
                    var object_id = (counterpartyBankInfo.counterparty_contact_id  == -1) ? '' : counterpartyBankInfo.counterparty_contact_id ;
                    var counterparty_id = '<?php echo $counterparty_id; ?>';
                    //var status = counterpartyBankInfo.form_counterparty_bank_info.validate();
                    var status = validate_form(counterpartyBankInfo.form_counterparty_bank_info);
                    if (status) {
                        counterpartyBankInfo.toolbar.disableItem('save');
                        form_data = counterpartyBankInfo.form_counterparty_bank_info.getFormData();
                        var xml = '<Root function_id="10105845" object_id="' + object_id + '"><FormXML ';

                        for (var a in form_data) {
                            if (form_data[a] != '' && form_data[a] != null&&a!='bank_id'&&a!='counterparty_id') {
                                if (counterpartyBankInfo.form_counterparty_bank_info.getItemType(a) == 'calendar') {
                                    value = counterpartyBankInfo.form_counterparty_bank_info.getItemValue(a, true);
                                } else {
                                    value = form_data[a];
                                }
                                xml += ' ' + a + '="' + value + '"';
                            }
                        }

                        // for New
                        if (!object_id) {
                            xml += ' bank_id="" counterparty_id="' + counterparty_id + '"';
                        }
                        else
                            xml += ' bank_id="'+counterpartyBankInfo.counterparty_contact_id+'" counterparty_id="' + counterparty_id + '"';
                        xml += ' ></FormXML></Root>';

                        //alert(xml);
                        //return;
                        var param = {
                            "flag": "b",
                            "action": "spa_setup_counterparty_UI",
                            "xml": xml
                        };

                        var return_val = adiha_post_data('return_array', param, '', '', 'counterpartyBankInfo.save_callback', '');
                    } else {
                        generate_error_message();
                        return;
                    }
            }
        }

        counterpartyBankInfo.save_callback = function(result) {
            if (has_rights_conterparty_bank_iu) {
                counterpartyBankInfo.toolbar.enableItem('save');
            };
            if (result[0][0] == 'Success') {
                if(result[0][5]) {
                    counterpartyBankInfo.counterparty_contact_id =(result[0][5]).replace(/\,/g,"");
                    counterpartyBankInfo.form_counterparty_bank_info.setItemValue('bank_id',((result[0][5]).replace(/\,/g,"")));
                }
                dhtmlx.message({
                    text: result[0][4],
                    expire: 1000
                });
                setTimeout ( function() { 
                    window.parent.popup_window.window('w1').close(); 
                }, 1000);
            } else {
                dhtmlx.message({
                    title: "Error",
                    type: "alert-error",
                    text: result[0][4]
                });
            }
        }
    </script>

</html>