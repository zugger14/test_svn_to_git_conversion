<!--DOCTYPE transitional.dtd-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<meta http-equiv="X-UA-Compatible" content="IE=Edge">
    <html>
        <?php
        include '../../../adiha.php.scripts/components/include.file.v3.php';
        
        $php_script_loc = $app_php_script_loc;
        $app_user_loc = $app_user_name;
        $function = 10181313;
        $rights_add_save = 10101130;

        list($has_right_add_save) = build_security_rights($rights_add_save);
        $has_right_add_save = ($has_right_add_save != '') ? "true" : "false";

        $counterparty_id = get_sanitized_value($_GET['counterparty_id'] ?? 'NULL');
        $counterparty_credit_limit_id = get_sanitized_value($_GET['limit_id'] ?? 'NULL');
        $tab_json = '';

        //Loads data for form from backend.
        $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10181313', @template_name='CounterpartyCreditInfoLimit', @parse_xml='<Root><PSRecordset counterparty_credit_limit_id=" . '"' . $counterparty_credit_limit_id . '"' . "></PSRecordset></Root>'";
        $return_value1 = readXMLURL($xml_file);
        
        //creating main layout for the form
        $form_namespace = 'cci_limit';
        $layout = new AdihaLayout();

        //json for main layout.
        $json = '[
            {
                id:             "a",
                text:           "Counterparty Credit Info - Limit",
                header:         false,
                collapse:       false,
                width:          200,
                fix_size:       [true,null]
            }
        ]';
        
        echo $layout->init_layout('new_layout', '', '1C', $json, $form_namespace);

        //json for toolbar.
        $save_button_json = "[
                        {id:'save', type:'button', img:'save.gif', imgdis:'save_dis.gif', text:'Save', title:'Save', enabled: $has_right_add_save}
                    ]";
        
        //Attaching a toolbar for save button
        $toolbar_name = 'toolbar';
        echo $layout->attach_toolbar_cell($toolbar_name, 'a');
        $toolbar_obj = new AdihaToolbar();
        echo $toolbar_obj->init_by_attach($toolbar_name, $form_namespace);
        echo $toolbar_obj->load_toolbar($save_button_json);
        echo $toolbar_obj->attach_event('', 'onClick', 'cci_limit.save_cci_limit_detail');
        
        //attach form to the main layout.
        foreach ($return_value1 as $temp1) {
            $form_json = $temp1[2];
            $form_name = 'cci_limit_form';
            if ($form_json) {
                echo $layout->attach_form($form_name, 'a');
                $form_obj = new AdihaForm();
                echo $form_obj->init_by_attach($form_name, $form_namespace);
                echo $form_obj->load_form($form_json);
            }
        }
        echo $layout->close_layout();
        ?>
    <form name="<?php echo $form_name; ?>">
        <textarea id='xml_ids' name="xml_ids" style="display:none;"></textarea>
        <input type="hidden" id="dropdown" name="dropdown">
        <div id="layoutObj"></div>
    </form>
    <script>
        var session = "<?php echo $session_id; ?>";
        var php_script_loc = "<?php echo $php_script_loc; ?>";
        var function_id = 10181313;
        var mode = "<?php echo get_sanitized_value($_GET['mode']);?>";
        var counterparty_id = <?php echo $counterparty_id; ?>;

        dhxWins = new dhtmlXWindows();

        $(function() {
            var combo_counterparty = cci_limit.cci_limit_form.getCombo('internal_counterparty_id');
            var combo_contract = cci_limit.cci_limit_form.getCombo('contract_id');
            var default_format = cci_limit.cci_limit_form.getUserData("internal_counterparty_id", "default_format");

            var counterparty_combo_value, counterparty_index, contract_combo_value = '', contract_index;
            if (mode == 'u') {
                contract_combo_value = combo_contract.getSelectedValue();
                counterparty_combo_value = combo_counterparty.getSelectedValue();
                //set item value to threshold provided and received
                if (cci_limit.cci_limit_form.getItemValue('threshold_provided') == 0) {
                    cci_limit.cci_limit_form.setItemValue('threshold_provided', '');    
                }
                if (cci_limit.cci_limit_form.getItemValue('threshold_received') == 0) {
                    cci_limit.cci_limit_form.setItemValue('threshold_received', '');
                }
                
                
            }
            
            // //Initial internal_counterparty_id combo option
            // var ici_sql = {
            //     "action"            : "spa_source_counterparty_maintain",
            //     "flag"              : "o",
            //     "counterparty_type" : "i",
            //     "counterparty_id"   : counterparty_id
            // };
            // combo_counterparty.clearAll();
            // cci_limit.load_combo(combo_counterparty, ici_sql);

            // // Initial contract_id combo option
            // var combo_sql = {
            //     "action" : "spa_source_contract_detail",
            //     "flag"   : "r",
            //     "counterparty_id" : counterparty_id
            // };
            // combo_contract.clearAll();
            // cci_limit.load_combo(combo_contract, combo_sql);

            // setTimeout(function() {
            //     counterparty_index = combo_counterparty.getIndexByValue(counterparty_combo_value);
            //     combo_counterparty.selectOption(counterparty_index);
            // }, 500);
            
            // if (default_format == 't') {
            //     combo_counterparty.attachEvent('onChange', function(value) {
            //         parent_value_ids = combo_counterparty.getSelectedValue();
            //         combo_contract.clearAll();
            //         combo_contract.setComboValue(null);
            //         combo_contract.setComboText(null);
            //         var combo_sql = {
            //             "action" : "spa_source_contract_detail",
            //             "flag"   : "o",
            //             "counterparty_id" : counterparty_id,
            //             "internal_counterparty_id" : parent_value_ids
            //         }
            //         cci_limit.load_combo(combo_contract, combo_sql);

            //         if(contract_combo_value != 'undefined' || contract_combo_value != '') {
            //             setTimeout(function() {
            //                 contract_index = combo_contract.getIndexByValue(contract_combo_value);
            //                 combo_contract.selectOption(contract_index);
            //             }, 500);
            //         }
            //     });
            // }
        });

        cci_limit.load_combo = function(combo_obj, combo_sql) {
            var data = $.param(combo_sql);
            var url = js_dropdown_connector_url + '&' + data;
            combo_obj.load(url);
        }

        cci_limit.save_cci_limit_detail = function(id) {
            if (id == 'save') {
                var form_xml = '<Root function_id="' + function_id + '"><FormXML ';
                data = cci_limit.cci_limit_form.getFormData();
                var validation_status = true;
                var status = validate_form(cci_limit.cci_limit_form);
                if (!status) {
                    generate_error_message();
                    validation_status = false;
                    return false;
                }
			
                for (var a in data) {
                    // alert(data[a]);
                    field_label = a;
                    field_value = data[a];
                    if (field_label == 'counterparty_id') {
                        var counterparty = <?php echo $counterparty_id;?>;
                        field_value = counterparty;
                    } 
                    if (cci_limit.cci_limit_form.getItemType(a) == "calendar") {
                        field_value = cci_limit.cci_limit_form.getItemValue(a, true);
                    }
                    if (field_label == 'credit_limit') {
                        credit_limit = data[a];
                    } 
                    if (field_label == 'credit_limit_to_us') {
                        credit_limit_to_us = data[a];
                    }
                    //
                    if (field_label == 'max_threshold') {
                        max_threshold = data[a];
                    } 
                    if (field_label == 'min_threshold') {
                        min_threshold = data[a];
                    }

                    form_xml += " " + field_label + "=\"" + field_value + "\"";    
                }
                if (credit_limit == '') {
					status = false;
                    dhtmlx.alert({
                        title:"Alert",
                        type:"alert",
                        text:"Please enter <b>Credit Limit</b>."
                    });
                    return;
                }

                if (max_threshold != '' && min_threshold != '' && parseFloat(max_threshold) < parseFloat(min_threshold)) {
                    dhtmlx.alert({
                        title:"Alert",
                        type:"alert",
                        text:"<b>Minimum Threshold(%)</b> should be lesser than <b>Maximum Threshold(%)</b>."
                    });
                    return;
                }

                if (status == true) {
                     cci_limit.new_layout.cells("a").progressOn(); 
                     adiha_post_data('alert', data, '', '', 'parent.cci_namespace.callback_limit_grid_refresh');
                }

                form_xml += "></FormXML></Root>";
                
                if(validation_status){  
                    cci_limit.toolbar.disableItem('save');
                    //data = {"action": "spa_process_form_data", flag: "u", "xml": form_xml};
                    data = {"action": "spa_counterparty_credit_limits", "flag": mode, "xml": form_xml};
                    adiha_post_data("alert", data, "", "", function(result) {
                        if(result[0]['errorcode'] == "Error") {
                            cci_limit.new_layout.cells("a").progressOff(); 
                            cci_limit.toolbar.enableItem('save');

                        } else {
                            parent.cci_namespace.callback_limit_grid_refresh();
                        }
                    });
                }
            }
        }
    </script>
    <div id="myToolbar1"></div>


        
        


