<!--DOCTYPE transitional.dtd-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<meta http-equiv="X-UA-Compatible" content="IE=Edge">
<html>
<?php include '../../../adiha.php.scripts/components/include.file.v3.php';?>

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
        $php_script_loc = $app_php_script_loc;
        $app_user_loc = $app_user_name;
        $contract_detail_id = get_sanitized_value($_GET['contract_detail_id'] ?? 'NULL');
        $mode = get_sanitized_value($_GET['mode'] ?? 'NULL');
        $type = get_sanitized_value($_GET['type'] ?? 'NULL');
        $count = get_sanitized_value($_GET['count'] ?? '0');
        $right = get_sanitized_value($_GET['right'] ?? '0');
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
            $invoice_line_item_id = $return_value1[0][0]  ?? '';
        } else 
            $invoice_line_item_id = "0";
        
        
        $contract_id = get_sanitized_value($_GET['contract_id'] ?? 'NULL');
        $tab_json = '';

        $has_rights_contract_ui = (isset($_GET['right'])&&($_GET['right'] == 1)) ? true : false;

        //Loads data for form from backend.
        $xml_file = "EXEC spa_create_application_ui_json 'j','10211115','contract_charge_type_detail','<Root><PSRecordset ID=" . '"' . $contract_detail_id . '"' . "></PSRecordset></Root>'";
        $return_value1 = readXMLURL($xml_file);
        
        $i = 0;
        foreach ($return_value1 as $temp) {
        if ($i > 0) {
                $tab_json = $tab_json . ',';
        }

            $tab_json = $tab_json . $temp[1];
            $i++;
        }
        $tab_json = '[' . $tab_json . ']';
       
        //creating main layout for the form
        $form_namespace = 'charge_type';
        $layout = new AdihaLayout();

        //json for main layout.
        $json = '[
            {
                id:             "a",
                text:           "Charge Type Details",
                header:         true,
                collapse:       false,
                width:          200,
                fix_size:       [true,null]
            }
        ]';
        
        //attach main layout to gl code screen
        echo $layout->init_layout('new_layout', '', '1C', $json, $form_namespace);

        //json for toolbar.
        $save_contract_json = '[
                        {id:"save", type:"button", img:"save.gif", imgdis:"save_dis.gif", text:"Save", title:"Save"}
                    ]';
        
        //Attaching a toolbar to save contract details
        $toolbar_contract = 'toolbar_contract_name';
        echo $layout->attach_toolbar_cell($toolbar_contract, 'a');
        $toolbar_contract_obj = new AdihaToolbar();
        echo $toolbar_contract_obj->init_by_attach($toolbar_contract, $form_namespace);
        echo $toolbar_contract_obj->load_toolbar($save_contract_json);
        if (!$has_rights_contract_ui) {
            echo "charge_type.toolbar_contract_name.disableItem('save');";
        }
        echo $toolbar_contract_obj->attach_event('', 'onClick', 'charge_type.save_charge_type_detail');
        
        //attach tab to the main layout.
        $tab_name = 'tab_charge_type';
        echo $layout->attach_tab_cell($tab_name, 'a', $tab_json);

        //Attaching tabbar.
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
                }
                else if ($yy == 1) {
                    $second_form = $form_namespace . "." . $form_name;
                }
                else if ($yy == 2) {
                    $third_form = $form_namespace . "." . $form_name;
                }
                $last_form = $form_namespace . "." . $form_name;
            }
            $yy++;
        }

    if ($last_form) {
            echo $last_form . ".attachEvent('onChange', charge_type.last_form_click);";
    }
    $sp_url = "EXEC spa_staticDataValues 'h',@type_id=10019";
    $c_dropdown = adiha_form_dropdown($sp_url, 0, 1, false, 2);
    $sp_url1 = "EXEC spa_contract_component_mapping 'b'";
    $not_c_dropdown = adiha_form_dropdown($sp_url1, 0, 1);
        echo $layout->close_layout();
?>

<form name="<?php echo $form_name; ?>">
            <textarea id='xml_ids' name="xml_ids" style="display:none;"></textarea>
            <input type="hidden" id="dropdown" name="dropdown">
                <div id="layoutObj"></div>
</form>

<script>
            var contract_detail_id = <?php echo get_sanitized_value($_GET['contract_detail_id'] ?? 0)?>;
            if (contract_detail_id == 0) {
                contract_detail_id = "NULL";
            }
            var session = "<?php echo $session_id; ?>";
            var mode = "<?php echo $mode; ?>";
            var charge_type_flag = "<?php echo $charge_type; ?>";
            var php_script_loc = "<?php echo $php_script_loc; ?>";
            var has_right = "<?php echo $right; ?>";

        $(function() {
            var first_form = <?php echo $first_form;?>;
            var contract_component_type_combo = first_form.getCombo('contract_component_type');
            
            contract_component_type_combo.attachEvent('onChange', function(id) {
                if (id == 'c') {
                   first_form.reloadOptions("invoice_line_item_id", <?php echo $not_c_dropdown; ?>);
                } else {
                    first_form.reloadOptions("invoice_line_item_id", <?php echo $c_dropdown; ?>);
                }
            });

            charge_type.tab_charge_type.setTabsMode("bottom");
		last_form_component = <?php echo $last_form; ?>;
			
			var true_up_charge_id = last_form_component.getItemValue('true_up_charge_type_id');
			var contract_id = <?php echo $contract_id;?>;
			var cm_param = {
                            "action": "('SELECT cctd.invoice_line_item_id,sdv.code FROM contract_charge_type_detail cctd LEFT JOIN static_data_value sdv ON sdv.value_id = cctd.invoice_line_item_id WHERE cctd.contract_charge_type_id=" + contract_id + "')"
                        };

			cm_param = $.param(cm_param);
			var url = js_dropdown_connector_url + '&' + cm_param;
			var combo_obj = last_form_component.getCombo('true_up_charge_type_id');                
		combo_obj.load(url, function() {
			if (mode == 'i') {
				last_form_component.setItemValue('true_up_charge_type_id', '');
			} else {
   	            last_form_component.setItemValue('true_up_charge_type_id', true_up_charge_id);
			}
			});
			
			charge_type.last_form_click('is_true_up', false);
        });

		charge_type.last_form_click = function(name, value) {
			if (name == 'true_up_applies_to') {
				true_up_value = last_form_component.getCheckedValue("true_up_applies_to");
				if (true_up_value == 'y') {
					last_form_component.disableItem("true_up_no_month");
				} else {
					last_form_component.enableItem("true_up_no_month");
				}
			} else if (name == 'is_true_up') {
				var is_true_up_checkbox = last_form_component.isItemChecked('is_true_up');
				if (is_true_up_checkbox == false) {
					last_form_component.enableItem('is_true_up');
					//var combo = last_form_component.getCombo("true_up_charge_type_id");
					//combo.setComboValue('0');
					last_form_component.disableItem('true_up_charge_type_id');
				} else {
					last_form_component.enableItem('true_up_charge_type_id');
				}
			}
		}
        
        charge_type.save_charge_type_detail = function(id) {
            if(parent.contract_group.ID > 0){
                        charge_type.ID = parent.contract_group.ID;   
            } 

            var mode = "<?php echo $mode; ?>";
            var contract_id = <?php echo $contract_id;?>;
            var count = <?php echo $count; ?>;
            if (id == 'save') {
                var detail_tabs = charge_type.tab_charge_type.getAllTabs();
                var tabsCount = charge_type.tab_charge_type.getNumberOfTabs();
                var form_xml = '<Root function_id="10211115"><FormXML ';
                var validation_status = true;
                var form_status = true;
                var first_err_tab;
                $.each(detail_tabs, function(index, value) {
                    layout_obj = charge_type.tab_charge_type.tabs(value).getAttachedObject();
                    attached_obj=layout_obj;
                        var status = validate_form(attached_obj);
                        form_status = form_status && status; 
                        if (tabsCount == 1 && !status) {
                            first_err_tab = "";
                        } else if ((!first_err_tab) && !status) {
                            first_err_tab = charge_type.tab_charge_type.tabs(value);
                        }
                        if (status == false) {
                            /*show_messagebox("One or more data are missing. Please Check.");*/
                            validation_status = false;
                        }
                    if (layout_obj instanceof dhtmlXForm) {
                        data = layout_obj.getFormData(); 
                        for (var a in data) {
                            field_label = a;
                            if (a == 'template_id') {
                                field_value = '';
                            } else if (a == 'contract_charge_type_id') {
                                field_value = contract_id;
                            } else if (layout_obj.getItemType(a) == "calendar") {
                                field_value = layout_obj.getItemValue(a, true);
                            }  else {
                                field_value = data[a];
                            }

                        // for copying case
                        // The id should be empty in the case of mode = 'c'
                        // Since copy requires new insert not update
                            if (mode == 'c' && field_label == 'ID') {
                                    field_value = '';
                                }
                            
                            if (mode == 'i' && field_label == 'ID' && charge_type.ID > 0) {
                                field_value = '';
                            }

                                form_xml += " " + field_label + "=\"" + field_value + "\"";
                        }
                    }
                });
                form_xml += "></FormXML></Root>";
                if(validation_status == false) {
                    if (!form_status) {
                        generate_error_message(first_err_tab);
                    }
                     return false;
                } 
                   
                    
                charge_type.toolbar_contract_name.disableItem('save');

                data = {"action": "spa_process_form_data", flag: "u", "xml": form_xml};
                
                if (mode == 'c') {
                    adiha_post_data("return_array", data, "", "", "charge_type.copy_charge_type_post_callback");
                } else {
                    adiha_post_data("alert", data, "", "", "charge_type.enable_save_button");
                }
            }
        }
        
        charge_type.enable_save_button = function(result) {
            if (has_right) {
               charge_type.toolbar_contract_name.enableItem('save'); 
            };
            if (mode == 'i') {
                var win_close = 'w3';
            } else {
                var win_close = 'w5';
            }
            setTimeout(function(){
                parent.window.dhxWins.window(win_close).close()
            }, 1000);
            parent.contract_group.charge_type_post_callback(result);
        }

        charge_type.copy_charge_type_post_callback = function(result) {
            form_component =<?php echo $first_form; ?>;
            if (has_right) {
               charge_type.toolbar_contract_name.enableItem('save'); 
            };
            if (result[0][0] == 'Success') {
                new_copy_contract_id = result[0][5];
                form_component.setItemValue('ID', result[0][5]);
                mode = 'u';
                old_copy_contract_id = <?php echo $contract_detail_id;?>;
                data = {"action": "spa_contract_charge_type_detail",
                        "flag": "c",
                        "contract_detail_id": new_copy_contract_id,
                        "contract_id": old_copy_contract_id
                        };
                adiha_post_data("alert", data, "", "", "parent.contract_group.charge_type_post_callback");
                setTimeout(function(){
                    parent.w5.close();
                }, 1000);
            } else {
                error_message = result[0][4];
                dhtmlx.alert({
                    title: "Error",
                    type: "alert-error",
                    text: error_message
                });
            }
            parent.contract_group.delete_charge_callback();
        }
</script>
<div id="myToolbar1"></div>