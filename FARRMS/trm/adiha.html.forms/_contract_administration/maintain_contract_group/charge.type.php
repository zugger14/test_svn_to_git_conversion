<!--DOCTYPE transitional.dtd-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<meta http-equiv="X-UA-Compatible" content="IE=Edge">
    <html>
        <?php
        include '../../../adiha.php.scripts/components/include.file.v3.php';
        ?>
        <style type="text/css">
            html, body {
                width: 100%;
                height: 100%;
                margin: 0px;
                overflow: hidden;
            }
            .dhx_item_editor{
                width:210px;
                height:113px;
            }

            img.book_icon {
                float: left;
                margin-right: 10px;
            }


            div.select_button {
                width: 50px;
                height: 17px;
                float: left;
                background-image: url('../../../adiha.php.scripts/adiha_pm_html/process_controls/button_img/edit.jpg');
                padding-left: 30px;
                padding-top: 4px;
            }
        </style>
        <?php
//         $sp_url = "EXEC spa_staticDataValues 's',@type_id=10019";
//        $c_dropdown = adiha_form_dropdown($sp_url, 1, 2);
//        $sp_url1 = "EXEC spa_contract_component_mapping 'b'";
//        $not_c_dropdown = adiha_form_dropdown($sp_url1, 1, 2);
//        
//       // echo '<pre>';
//        print_r($c_dropdown);
//        print_r($not_c_dropdown);
//        die();
        $php_script_loc = $app_php_script_loc;
        $app_user_loc = $app_user_name;
        $contract_detail_id = isset($_GET['contract_detail_id']) ? $_GET['contract_detail_id'] : 'NULL';
        $lock_status = isset($_GET['lock_status']) ? $_GET['lock_status'] : 'NULL';
        $mode = isset($_GET['mode']) ? $_GET['mode'] : 'NULL';
        $type = isset($_GET['type']) ? $_GET['type'] : 'NULL';
        $count = isset($_GET['count']) ? $_GET['count'] : '0';
        if ($type != 'NULL') {
            if ($type == 'Charge Map')
                $charge_type = 'c';
            else if ($type == 'Formula')
                $charge_type = 'f';
            else if ($type == 'Template')
                $charge_type = 't';
        } else
            $charge_type = '0';
        if ($contract_detail_id != 'NULL') {
            $xml_file = "EXEC ('select invoice_line_item_id from contract_group_detail where ID=" . $contract_detail_id . "')";
            $return_value1 = readXMLURL($xml_file);
            $invoice_line_item_id = $return_value1[0][0];
        } else
            $invoice_line_item_id = "0";
        // die();
        $contract_id = isset($_GET['contract_id']) ? $_GET['contract_id'] : 'NULL';
        $tab_json = '';
        $rights_contract_charge_type_ui = 10211416;
        list (
                $has_rights_contract_charge_type_ui
                ) = build_security_rights(
                $rights_contract_charge_type_ui
        );
        //Loads data for form from backend.
        /* start */
        $xml_file = "EXEC spa_create_application_ui_json 'j','10211415','contract_detail','<Root><PSRecordset ID=" . '"' . $contract_detail_id . '"' . "></PSRecordset></Root>'";
        $return_value1 = readXMLURL($xml_file);
  
        $i = 0;
        foreach ($return_value1 as $temp) {
            if ($i > 0)
                $tab_json = $tab_json . ',';
            $tab_json = $tab_json . $temp[1];
            $i++;
        }
        $tab_json = '[' . $tab_json . ']';
        /* END */

        //creating main layout for the form
        /* start of main layout */
        $form_namespace = 'charge_type';
        $layout = new AdihaLayout();

        //json for main layout.
        /* start */
        $json = '[
            {
                id:             "a",
                text:           "Gl Code",
                header:         true,
                collapse:       false,
                width:          200,
                fix_size:       [true,null]
            }
            
           
        ]';
        /* end */

        //attach main layout to gl code screen
        echo $layout->init_layout('new_layout', '', '1C', $json, $form_namespace);

        //json for toolbar.
        /* start */
        $save_contract_json = '[
                        {id:"save", type:"button", img:"save.gif", imgdis:"save_dis.gif", text:"Save", title:"Save"}
                    ]';
        /* end */

        //Attaching a toolbar to save contract details
        /* start */
        $toolbar_contract = 'save_glcode_toolbar';
        echo $layout->attach_toolbar_cell($toolbar_contract, 'a');
        $toolbar_contract_obj = new AdihaToolbar();
        echo $toolbar_contract_obj->init_by_attach($toolbar_contract, $form_namespace);
        echo $toolbar_contract_obj->load_toolbar($save_contract_json);
        if ((!$has_rights_contract_charge_type_ui) || ($lock_status == 'true'))
            echo $toolbar_contract_obj->disable_item('save');
        echo $toolbar_contract_obj->attach_event('', 'onClick', 'charge_type.charge_toolbar_click');
        /* end */

        //attach tab to the main layout.
        /* start */
        $tab_name = 'tab_glcode';
        // $form_tab=parse_tab_json_id($tab_json);
        echo $layout->attach_tab_cell($tab_name, 'a', $tab_json);

        //Attaching tabbar.
        /* START */
        $tab_obj = new AdihaTab();
        echo $tab_obj->init_by_attach($tab_name, $form_namespace);
        $yy = 0;
        foreach ($return_value1 as $temp1) {
            $form_json = $temp1[2];
            $tab_id = 'detail_tab_' . $temp1[0];
            $form_name = 'form_' . $temp1[0];
            if ($form_json) {
                echo $tab_obj->attach_form($form_name, $tab_id, $form_json, $form_namespace);
                if ($yy == 0) {
                    $first_form = $form_namespace . "." . $form_name;
                    echo $first_form . ".attachEvent('onChange', charge_type.form_click);";
                } else if ($yy == 1) {
                    $second_form = $form_namespace . "." . $form_name;
                } else if ($yy == 2) {
                    $third_form = $form_namespace . "." . $form_name;
                }
                $last_form = $form_namespace . "." . $form_name;
            }
            $yy++;
        }
        if ($last_form)
            echo $last_form . ".attachEvent('onChange', charge_type.last_form_click);";
        /* END */
        echo $layout->close_layout();

        /* end of main layout */
        $sp_url = "EXEC spa_staticDataValues 'h',@type_id=10019";
        $c_dropdown = adiha_form_dropdown($sp_url, 0, 1, false, 2);
        $sp_url1 = "EXEC spa_contract_component_mapping 'b'";
        $not_c_dropdown = adiha_form_dropdown($sp_url1, 0, 1);
        $sp_url2 = "EXEC spa_contract_group_detail @flag='y',@contract_id=" . $contract_id . ",@prod_type='p' , @contract_detail_id = " . $contract_detail_id;
        $true_up_charge_dropdown = adiha_form_dropdown($sp_url2, 0, 1, true);
        $true_up_charge_type_id = '';
        $contract_component_template = '';

        //$xml = "EXEC('select true_up_charge_type_id from contract_group_detail where ID=" . $contract_detail_id . " order by true_up_charge_type_id')";
        //$return_value = readXMLURL($xml);
        //$true_up_charge_type_id = $return_value[0][0];


        if ($mode == 'u') {
            $xml_file = "EXEC('select contract_component_template, true_up_charge_type_id from contract_group_detail where ID=" . $contract_detail_id . "')";
            $return_value = readXMLURL($xml_file);
            $contract_component_template = ($return_value[0][0]);
            $true_up_charge_type_id = ($return_value[0][1]);
        }
        ?>
        <style>
            /*div#layoutObj {
                position: relative;
                width: 640px;
                height: 350px;
                display: inline-block;
            }*/
        </style>
        <form name="<?php echo $form_name; ?>">
            <textarea id='xml_ids' name="xml_ids" style="display:none;"></textarea>
            <input type="hidden" id="dropdown" name="dropdown">
                <div id="layoutObj"></div>
        </form>

        <script>
            var old_copy_contract_id = '';
            var contract_detail_id = <?php echo isset($_GET['contract_detail_id']) ? $_GET['contract_detail_id'] : 0; ?>;
            if (contract_detail_id == 0) {
                contract_detail_id = "NULL";
            }
            var session = "<?php echo $session_id; ?>";
            var c_dropdown =<?php echo $c_dropdown; ?>;
            var mode = "<?php echo $mode; ?>";
            var charge_type_flag = "<?php echo $charge_type ?? ''; ?>";
            var php_script_loc = "<?php echo $php_script_loc; ?>";
            /**
             * charge_type.glcode_toolbar_click() [this function is triggered when glocode toolbar is triggered.]
             * @param [int] id id of the button.[add,save and delete]
             */
            $(function() {
                form_component =<?php echo $first_form; ?>;
                second_form_component =<?php echo $second_form; ?>;
                third_form_component =<?php echo $third_form; ?>;
                last_form_component =<?php echo $last_form; ?>;
                var dhxCombo_true_up_charge_type_id = last_form_component.getCombo("true_up_charge_type_id");
                last_form_component.reloadOptions("true_up_charge_type_id", <?php echo $true_up_charge_dropdown; ?>);

                if (mode == 'i') {
                    dhxCombo_true_up_charge_type_id.selectOption('0');
                }
                else {
                   last_form_component.setItemValue('true_up_charge_type_id', '<?php echo $true_up_charge_type_id; ?>');
                }
                if (mode == 'i') {
                    form_component.setItemValue('Prod_type', 'p');
                    form_component.setItemValue('sequence_order', '<?php echo $count; ?>');

                }
                form_component.setItemValue('contract_id', <?php echo $contract_id; ?>);

				if ( last_form_component.isItemChecked('is_true_up') == false){
					last_form_component.enableItem('is_true_up');
					makeTrueUpChargeTtypeEmpty();
					last_form_component.disableItem('true_up_charge_type_id');
				}
				
                last_form_component.attachEvent("onChange", function (name, value){
					if (name == 'is_true_up') {
						makeTrueUpChargeTtypeEmpty();   
						changeChangeType();
					}
                });

                true_up_value = last_form_component.getCheckedValue("true_up_applies_to");
                if (true_up_value == 'y')
                    last_form_component.disableItem("true_up_no_month");
                else
                    last_form_component.enableItem("true_up_no_month");
                var dhxCombo = form_component.getCombo("invoice_line_item_id");
                var dhxCombo_contract_template = form_component.getCombo("contract_template");
                var dhxCombo_contract_component_template = form_component.getCombo("contract_component_template");

                if (form_component.getItemValue('radio_automatic_manual') == 'c') {
                    form_component.reloadOptions("invoice_line_item_id", <?php echo $not_c_dropdown; ?>);
                    
                    if (mode == 'u') {
                        dhxCombo.unSelectOption();
                        form_component.setItemValue("invoice_line_item_id", <?php echo $invoice_line_item_id; ?>);
                    }
                    form_component.disableItem("contract_template");
                    form_component.disableItem("contract_component_template");
                    third_form_component.disableItem("deal_type");
                    third_form_component.disableItem("timeofuse");
                    form_component.disableItem("price");
                    third_form_component.disableItem("eqr_product_name");
                    third_form_component.disableItem("group_by");


                }
                else if (form_component.getItemValue('radio_automatic_manual') == 'f') {
                    //  dhxCombo.addOption(c_dropdown);
                    form_component.reloadOptions("invoice_line_item_id", <?php echo $c_dropdown; ?>);
                    
                    if (mode == 'u') {
                        dhxCombo.unSelectOption();
                        form_component.setItemValue("invoice_line_item_id", <?php echo $invoice_line_item_id; ?>);
                    }
                    form_component.disableItem("contract_template");
                    form_component.disableItem("contract_component_template");
                    third_form_component.enableItem("deal_type");
                    third_form_component.enableItem("timeofuse");
                    form_component.enableItem("price");
                    third_form_component.enableItem("eqr_product_name");
                    third_form_component.enableItem("group_by");

                } else if (form_component.getItemValue('radio_automatic_manual') == 'e') {
                    //  dhxCombo.addOption(c_dropdown);
                    form_component.reloadOptions("invoice_line_item_id", <?php echo $c_dropdown; ?>);

                    if (mode == 'u') {
                        dhxCombo.unSelectOption();
                        form_component.setItemValue("invoice_line_item_id", <?php echo $invoice_line_item_id; ?>);
                    }
                    form_component.disableItem("contract_template");
                    form_component.disableItem("contract_component_template");
                    third_form_component.enableItem("deal_type");
                    third_form_component.enableItem("timeofuse");
                    form_component.enableItem("price");
                    third_form_component.enableItem("eqr_product_name");
                    third_form_component.enableItem("group_by");

                }
                else {
                    form_component.reloadOptions("invoice_line_item_id", <?php echo $c_dropdown; ?>);
                    
                    if (mode == 'u') {
                        dhxCombo.unSelectOption();
                        form_component.setItemValue("invoice_line_item_id", <?php echo $invoice_line_item_id; ?>);
                    }
                    form_component.enableItem("contract_template");
                    form_component.enableItem("contract_component_template");
                    third_form_component.disableItem("deal_type");
                    third_form_component.disableItem("timeofuse");
                    form_component.disableItem("price");
                    third_form_component.disableItem("eqr_product_name");
                    third_form_component.disableItem("group_by");
                }
                dhxCombo_contract_template = form_component.getCombo("contract_template");
                dhxCombo_contract_component_template = form_component.getCombo("contract_component_template");
                dhxCombo_contract_template.attachEvent("onChange", function(value) {
                    dhxCombo_contract_component_template.clearAll();
                    dhxCombo_contract_component_template.setComboValue(null);
                    dhxCombo_contract_component_template.setComboText(null);
                    application_field_id = form_component.getUserData("contract_template", "application_field_id");
                    url = js_dropdown_connector_url + "&call_from=dependent&value=" + value + "&application_field_id=" + application_field_id + "&parent_column=contract_template";
                    dhxCombo_contract_component_template.load(url);
                });

                if (mode == 'u') {
                    var value = form_component.getItemValue('contract_template');  
                    if(value){ dhxCombo_contract_template = form_component.getCombo("contract_template");
                        dhxCombo_contract_component_template = form_component.getCombo("contract_component_template");
                        dhxCombo_contract_component_template.clearAll();
                        application_field_id = form_component.getUserData("contract_template", "application_field_id");
                        url = js_dropdown_connector_url + "&call_from=dependent&value=" + value + "&application_field_id=" + application_field_id + "&parent_column=contract_template";
                        dhxCombo_contract_component_template.load(url, set_contract_component_template);}
                }

            });
            
            function changeChangeType(){
                 var is_true_up_checkbox = last_form_component.isItemChecked('is_true_up');
				 if (is_true_up_checkbox == false) {
                      last_form_component.disableItem('true_up_charge_type_id');
                  } else {
                    last_form_component.enableItem('true_up_charge_type_id');
                  }

            }
			
			function makeTrueUpChargeTtypeEmpty(){
				var combo = last_form_component.getCombo("true_up_charge_type_id");
				combo.setComboValue('0');
			}

            function set_contract_component_template() {
                var contract_component_template = '<?php echo  ($contract_component_template) ? $contract_component_template : '0'; ?>';
                dhxCombo_contract_component_template = form_component.getCombo("contract_component_template");
                dhxCombo_contract_component_template.setComboValue(contract_component_template);
            }
            function isNumber(n) {
                return !isNaN(parseFloat(n)) && isFinite(n);
            }
            charge_type.last_form_click = function(name, value) {
                if (name == 'true_up_applies_to') {
                    true_up_value = last_form_component.getCheckedValue("true_up_applies_to");
                    if (true_up_value == 'y')
                        last_form_component.disableItem("true_up_no_month");
                    else
                        last_form_component.enableItem("true_up_no_month");
                }
            }

            charge_type.form_click = function(name, value) {

                if (name == 'radio_automatic_manual') {
                    form_component =<?php echo $first_form; ?>;
                    var dhxCombo = form_component.getCombo("invoice_line_item_id");
                    var dhxCombo_contract_template = form_component.getCombo("contract_template");
                    var dhxCombo_contract_component_template = form_component.getCombo("contract_component_template");
                    if (form_component.getItemValue('radio_automatic_manual') == 'c') {
                        form_component.reloadOptions("invoice_line_item_id", <?php echo $not_c_dropdown; ?>);
                        if (mode == 'u' && charge_type_flag == 'c')
                            form_component.setItemValue("invoice_line_item_id", <?php echo $invoice_line_item_id; ?>);
                        form_component.disableItem("contract_template");
                        form_component.disableItem("contract_component_template");
                        third_form_component.disableItem("deal_type");
                        third_form_component.disableItem("timeofuse");
                        form_component.disableItem("price");
                        third_form_component.disableItem("eqr_product_name");
                        third_form_component.disableItem("group_by");

                    }
                    else if (form_component.getItemValue('radio_automatic_manual') == 'f') {
                        form_component.reloadOptions("invoice_line_item_id", <?php echo $c_dropdown; ?>);
                        if (mode == 'u' && charge_type_flag == 'f')
                            form_component.setItemValue("invoice_line_item_id", <?php echo $invoice_line_item_id; ?>);
                        form_component.disableItem("contract_template");
                        form_component.disableItem("contract_component_template");
                        third_form_component.enableItem("deal_type");
                        third_form_component.enableItem("timeofuse");
                        form_component.enableItem("price");
                        third_form_component.enableItem("eqr_product_name");
                        third_form_component.enableItem("group_by");

                    } else if (form_component.getItemValue('radio_automatic_manual') == 'e') {
                        form_component.reloadOptions("invoice_line_item_id", <?php echo $c_dropdown; ?>);
                        if (mode == 'u' && charge_type_flag == 'c')
                            form_component.setItemValue("invoice_line_item_id", <?php echo $invoice_line_item_id; ?>);
                        form_component.disableItem("contract_template");
                        form_component.disableItem("contract_component_template");
                        third_form_component.disableItem("deal_type");
                        third_form_component.disableItem("timeofuse");
                        form_component.disableItem("price");
                        third_form_component.disableItem("eqr_product_name");
                        third_form_component.disableItem("group_by");

                    }
                    else {
                        form_component.reloadOptions("invoice_line_item_id", <?php echo $c_dropdown; ?>);
                        if (mode == 'u' && charge_type_flag == 't')
                            form_component.setItemValue("invoice_line_item_id", <?php echo $invoice_line_item_id; ?>);
                        form_component.enableItem("contract_template");
                        form_component.enableItem("contract_component_template");
                        third_form_component.disableItem("deal_type");
                        third_form_component.disableItem("timeofuse");
                        form_component.disableItem("price");
                        third_form_component.disableItem("eqr_product_name");
                        third_form_component.disableItem("group_by");
                    }
                }
            }
            charge_type.charge_toolbar_click = function(id) {
                if (id == 'save') {
                    charge_type.form_validation_status = 0;
                    if (mode == 'c') {
                        if(old_copy_contract_id == '') {
                            charge_type['old_value'] = form_component.getItemValue('ID');
                            old_copy_contract_id = form_component.getItemValue('ID');
                        }
                        form_component.setItemValue('ID', '');

                    }
                    var detail_tabs = charge_type.tab_glcode.getAllTabs();
                    var form_xml = '<Root function_id="10211415"><FormXML ';
                    $.each(detail_tabs, function(index, value) {
                        layout_obj = charge_type.tab_glcode.cells(value).getAttachedObject();
                        attached_obj = layout_obj;
                        var status = validate_form(attached_obj);
                        if (!status) {
                            charge_type.form_validation_status = 1;
                        }
                        if (layout_obj instanceof dhtmlXForm) {
                            data = layout_obj.getFormData();
                            for (var a in data) {
                                field_label = a;
                                if (layout_obj.getItemType(a) == "calendar") {
                                    field_value = layout_obj.getItemValue(a, true);
                                }
                                else {
                                    field_value = data[a];
                                }
                                form_xml += " " + field_label + "=\"" + field_value + "\"";
                            }
                        }
                    });
                    form_xml += "></FormXML></Root>";

                    if (charge_type.form_validation_status)
                        return false;
                    data = {"action": "spa_process_form_data", flag: "u", "xml": form_xml};
                    if (mode == 'c') {
                        result = adiha_post_data("return_array", data, "", "", "charge_type.copy_charge_type_post_callback");
                    }
                    else {
                        result = adiha_post_data("alert", data, "", "", "charge_type.callback_function");
                    }
                }
            }
           charge_type.copy_charge_type_post_callback = function(result) {
                form_component =<?php echo $first_form; ?>;
                if (result[0][0] == 'Success') {
                    new_copy_contract_id = result[0][5];
                    form_component.setItemValue('ID', result[0][5]);
                    mode = 'u';
                    data = {"action": "spa_contract_group_detail", flag: "c", "contract_detail_id": new_copy_contract_id, "contract_id": old_copy_contract_id};
                    result = adiha_post_data("alert", data, "", "", "parent.contract_group.charge_type_post_callback");
                    setTimeout(function() { 
                        window.parent.dhxWins.window('w3').close();
                    }, 1000);
                }
                else {
                    error_message = result[0][4];
                    dhtmlx.alert({
                        title: "Error",
                        type: "alert-error",
                        text: error_message
                    });
                }

            }
            charge_type.callback_function = function(result) {
                form_component =<?php echo $first_form; ?>;
                if (result[0].errorcode == 'Success') {
                    if (mode == 'i') {
                        form_component.setItemValue('ID', result[0].recommendation);
                        mode = 'u';
                        setTimeout(function() { 
                            window.parent.dhxWins.window('w3').close();
                        }, 1000);
                    } else {
                        setTimeout(function() { 
                            window.parent.dhxWins.window('w5').close();
                        }, 1000);
                    }
                    
                }
                parent.contract_group.charge_type_post_callback(result);
            }

        </script>
        <div id="myToolbar1"></div>