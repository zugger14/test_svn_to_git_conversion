<?php
/**
* Map gl codes screen
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
</head>
<?php
    $application_function_id = 10101300;
    $rights_setup_gl_codes_IU = 10101310;
    list (            
            $has_rights_setup_gl_codes_IU 
        ) = build_security_rights(
            $rights_setup_gl_codes_IU
        );
    $enable_setup_gl_codes_insert = ($has_rights_setup_gl_codes_IU) ? 'true' : 'false';
    
    $template_name = 'gl_system_mapping';
    $form_namespace = 'map_gl_codes';
    $form_name = 'gl_map_form';
    $read_only =  get_sanitized_value($_POST['read_only'] ?? false , 'boolean');
    $gl_code_id = get_sanitized_value($_GET['gl_code_id'] ?? '');
    $form_obj = new AdihaStandardForm($form_namespace, $application_function_id);
    $form_obj->define_grid("gl_system_mapping", "EXEC spa_gl_system_mapping @flag = 'n'", 'g', false, '');
    $form_obj->define_custom_functions('save_map_gl_codes', 'load_form_map_gl_codes', 'delete_map_gl_codes');
   echo $form_obj->init_form('GL Codes', 'GL Codes', $gl_code_id);

    echo $form_obj->close_form();
?>
<body>
<textarea style="display:none" name="close_status" id="close_status">Cancel</textarea>
<textarea style="display:none" name="gl_number_id" id="gl_number_id"></textarea>
<textarea style="display:none" name="gl_account_name" id="gl_account_name"></textarea>
<textarea style="display:none" name="gl_account_number" id="gl_account_number"></textarea>
</body>
</html>
<script type="text/javascript">
    var  php_script_loc = "<?php echo $app_php_script_loc; ?>";
    var has_rights_setup_gl_codes_IU = '<?php echo $enable_setup_gl_codes_insert;?>';
    var read_only = Boolean(<?php echo $read_only; ?>);
    /**
     *
     */
     $(function() {
        if (read_only) {
            map_gl_codes.undock_cell_a_standard_form('a');
            map_gl_codes.grid.detachEvent('onRowDblClicked');
            map_gl_codes.layout.cells('b').detachObject();
            map_gl_codes.menu.addNewSibling(null, "ok", 'Ok', false, "tick.gif", "tick_dis.gif");
            map_gl_codes.menu.hideItem('t1');
            map_gl_codes.menu.hideItem('t2');
            map_gl_codes.menu.attachEvent('onClick', map_gl_codes.left_menu_click);
           
        }
    });
    
    map_gl_codes.left_menu_click = function(id) {
            switch (id) {
                case "ok":
                    var row_id = map_gl_codes.grid.getSelectedRowId();
                    var col_idx = map_gl_codes.grid.getColIndexById("gl_account_name");
                    var gl_account_name = map_gl_codes.grid.cells(row_id,col_idx).getValue();
                    var col_idx = map_gl_codes.grid.getColIndexById("gl_account_number");                    
                    var gl_account_number = map_gl_codes.grid.cells(row_id,col_idx).getValue();
                    var col_idx = map_gl_codes.grid.getColIndexById("gl_number_id");                    
                    var gl_number_id = map_gl_codes.grid.cells(row_id,col_idx).getValue();
                    document.getElementById("close_status").value = 'ok';
                    document.getElementById("gl_account_name").value = gl_account_name; 
                    document.getElementById("gl_account_number").value = gl_account_number;
                    document.getElementById("gl_number_id").value = gl_number_id; 
                    var win_obj = window.parent.popup_window.window("w1");
                    win_obj.close();
                    break;
                default:
                    dhtmlx.alert({title: "Information!", type: "alert-error", text: "Not implemented"});
                    break;
            }
        };
        
    map_gl_codes.load_form_map_gl_codes = function(win, tab_id) {  
        var is_new = win.getText();
        var tab_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        map_gl_codes["inner_tab_layout_" + tab_id] = win.attachLayout("1C");
        
        win.progressOff();
        
        var gl_number_id;
        if (is_new == 'New') {
            gl_number_id = 'NULL';
        } else {
            gl_number_id = tab_id;
        }
        
        var template_name = 'gl_system_mapping';
        
        var function_id = <?php echo $application_function_id;?>;
        
        var xml_value =  '<Root><PSRecordset gl_number_id ="' + gl_number_id + '"></PSRecordset></Root>';
        
        data = {"action": "spa_create_application_ui_json",
                "flag": "j",
                "application_function_id": function_id,
                "template_name": template_name,
                "parse_xml": xml_value
             };
        result = adiha_post_data('return_array', data, '', '', 'load_form_data', '');
    }
    
    function load_form_data(result) {
        if (read_only) return;
        var active_tab_id = map_gl_codes.tabbar.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        var result_length = result.length;
        var tab_json = '';

        for (i = 0; i < result_length; i++) {
            if (i > 0)
                tab_json = tab_json + ",";
            tab_json = tab_json + (result[i][1]);
        }

        tab_json = '{tabs: [' + tab_json + ']}';
        map_gl_codes["map_gl_codes_tabs" + active_object_id] = map_gl_codes["inner_tab_layout_" + active_object_id].cells("a").attachTabbar();
        map_gl_codes["map_gl_codes_tabs" + active_object_id].loadStruct(tab_json);
        map_gl_codes["map_gl_codes_tabs" + active_object_id].setTabsMode("bottom");

        for (j = 0; j < result_length; j++) {
            tab_id = 'detail_tab_' + result[j][0];
            map_gl_codes["form" + j] = map_gl_codes["map_gl_codes_tabs" + active_object_id].cells(tab_id).attachForm();
            var gl_code = new Array();
            
            if (result[j][2]) {
                map_gl_codes["form" + j].loadStruct(result[j][2]);
                if (j == 0) {
                    var form_object = map_gl_codes["form" + j].getForm();
                    
                    map_gl_codes["form" + j].attachEvent("onChange", function(name, value){
                        if (name == 'gl_code_1' || name == 'gl_code_2' || name == 'gl_code_3' || name == 'gl_code_4' || name == 'gl_code_5' || name == 'gl_code_6' || name == 'gl_code_7' || name == 'gl_code_8' || name == 'gl_code_9' || name == 'gl_code_10') {
                        
                            gl_code[0] = form_object.getCombo('gl_code_1').getComboText();
                            gl_code[1] = form_object.getCombo('gl_code_2').getComboText();
                            gl_code[2] = form_object.getCombo('gl_code_3').getComboText();
                            gl_code[3] = form_object.getCombo('gl_code_4').getComboText();
                            gl_code[4] = form_object.getCombo('gl_code_5').getComboText();
                            gl_code[5] = form_object.getCombo('gl_code_6').getComboText();
                            gl_code[6] = form_object.getCombo('gl_code_7').getComboText();
                            gl_code[7] = form_object.getCombo('gl_code_8').getComboText();
                            gl_code[8] = form_object.getCombo('gl_code_9').getComboText();
                            gl_code[9] = form_object.getCombo('gl_code_10').getComboText();
                            
                            var account_name_coll = '';
                                                 
                            for (var x = 0; x < 10; x++) {
                                if (account_name_coll == '') {
                                    account_name_coll = gl_code[x]; 
                                } else {
                                    if (gl_code[x] == '') {
                                        //do nothing
                                    } else {
                                        account_name_coll = account_name_coll + '.' + gl_code[x];    
                                    }
                                }
                            }
                           
                            //var p_value = form_object.getItemValue('gl_account_number');
//                            
//                            if (p_value != '') {
//                                p_value += '.';
//                            }
//                            var combo_obj = form_object.getCombo(name);
                            //p_value += combo_obj.getComboText();
                            form_object.setItemValue('gl_account_number', account_name_coll);
                        }
                    });
                    if(result[j][6]) {
                        dhxCombo_acc_type = form_object.getCombo("chart_of_account_type");
                        dhxCombo_acc_name = form_object.getCombo("chart_of_account_name");
                        dhxCombo_acc_type.attachEvent("onChange", function(value) {
                            dhxCombo_acc_name.clearAll();
                            dhxCombo_acc_name.setComboValue(null);
                            dhxCombo_acc_name.setComboText(null);
                            application_field_id = form_object.getUserData("chart_of_account_name", "application_field_id");
                            url = js_dropdown_connector_url + "&call_from=dependent&value=" + value + "&application_field_id=" + application_field_id + "&parent_column=chart_of_account_type";
                            dhxCombo_acc_name.load(url, '');
                        });
                        /****/
                    }
                }
            }
        }
    }
    
    /**
     *
     */
     map_gl_codes.save_map_gl_codes = function(tab_id) {
        var tab_obj = map_gl_codes.tabbar.cells(tab_id).getAttachedObject();
        var inner_tab_obj = tab_obj.cells("a").getAttachedObject();
        var form_xml = '<Root function_id="<?php echo $application_function_id;?>"><FormXML ';
        var validation_status = 1;
        var form_status = true;
        var first_err_tab;
        inner_tab_obj.forEachTab(function(tab){
            layout_obj = tab.getAttachedObject();

            if (layout_obj instanceof dhtmlXForm) {
                attached_obj=layout_obj;
                var status = validate_form(attached_obj,tab);
                form_status = form_status && status; 
                if ((!first_err_tab) && !status) {
                    first_err_tab = tab;
                }
                if (status == false) {
                    validation_status = 0;
                    // show_messagebox("One or more data are missing. Please Check.");
                    /*generate_error_message();
                    tab.setActive();*/

                }

                data = layout_obj.getFormData();
                for (var a in data) {
                    field_label = a;
                    field_value = data[a];
                    
                    if (a == 'gl_account_name') {
                        map_gl_codes["form" + 0].setUserData("", "gl_account_name", field_value);
                    }
                    if ((a == 'gl_account_number') && (data[a] == '')) {
                        show_messagebox('Account Number can not be blank.');
                        validation_status = false;
                        return;
                    }

                    form_xml += " " + field_label + "=\"" + field_value + "\"";
                }
            }
        });
        form_xml += "></FormXML></Root>";
        
        if(validation_status) {
            //added by me
            //console.log(map_gl_codes.tabbar.cells(tab_id).getAttachedToolbar());
            map_gl_codes.tabbar.cells(tab_id).getAttachedToolbar().disableItem('save');
            /////////////
            data = {"action": "spa_process_form_data", "xml": form_xml};
            result = adiha_post_data("alert", data, "", "", "map_gl_codes.post_callback");
        }
        if (!form_status) {
            generate_error_message(first_err_tab);
        }
    }
    map_gl_codes.post_callback = function(result) {
        var tab_id = '';
        var active_tab_id = map_gl_codes.tabbar.getActiveTab();
        if (has_rights_setup_gl_codes_IU) {
            map_gl_codes.tabbar.cells(active_tab_id).getAttachedToolbar().enableItem('save');
        };

        // setTimeout(function() {
        //     map_gl_codes.tabbar.cells(active_tab_id).getAttachedToolbar().enableItem('save');
        // },1000);
        /////////////
        var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        
        if (result[0].errorcode == 'Success') {
            var tab_index = map_gl_codes.tabbar.tabs(active_tab_id).getIndex();
            var coa_name = map_gl_codes["form" + 0].getUserData("", "gl_account_name");
            
            if(result[0].recommendation == null){
                map_gl_codes.tabbar.tabs(active_tab_id).setText(coa_name);
            } else {
                tab_id = 'tab_' + result[0].recommendation;
                map_gl_codes.create_tab_custom(tab_id, coa_name, tab_index);
                map_gl_codes.tabbar.tabs(active_tab_id).close(true);
            }
        }
        map_gl_codes.refresh_grid();
    }
    map_gl_codes.create_tab_custom = function(full_id,text, tab_index) {
        var param = {"action": "spa_gl_system_mapping",
                     "flag": "n",
                     "grid_type": "g"
        };

        param = $.param(param);
        var param_url = js_data_collector_url + "&" + param;
        map_gl_codes.grid.clearAll();
        map_gl_codes.grid.loadXML(param_url);

        if (!map_gl_codes.pages[full_id]) {
            map_gl_codes.tabbar.addTab(full_id, text, null, tab_index, true, true);
            var win = map_gl_codes.tabbar.cells(full_id);
            win.progressOn();
            //using window instead of tab
            var toolbar = win.attachToolbar();
            toolbar.setIconsPath("<?php echo $app_php_script_loc; ?>components/lib/adiha_dhtmlx/adiha_toolbar_3.0/adiha_dhtmlxToolbar/common/icons_web/");
            toolbar.attachEvent("onClick", map_gl_codes.tab_toolbar_click);
            toolbar.loadStruct([{id: "save", type: "button", img: "save.gif", text: "Save", title: "Save"}]);
            map_gl_codes.tabbar.cells(full_id).setActive();
            map_gl_codes.tabbar.cells(full_id).setText(text);
            map_gl_codes.load_form_map_gl_codes(win, full_id);
            map_gl_codes.pages[full_id] = win;
        }
        else {
            map_gl_codes.tabbar.cells(full_id).setActive();
        }
    }
    map_gl_codes.delete_map_gl_codes = function() {
        var selectedId = map_gl_codes.grid.getSelectedRowId();
        var count = selectedId.indexOf(",") > -1 ? selectedId.split(",").length : 1;
        selectedId = selectedId.indexOf(",") > -1 ? selectedId.split(",") : [selectedId];
        var gl_number_id = '';
        //map_gl_codes.grid.cells(selectedId, 0).getValue();

        for (var i = 0; i < selectedId.length; i++) {
            gl_number_id += map_gl_codes.grid.cells(selectedId[i], 0).getValue() + ',';
        }

        gl_number_id = gl_number_id.slice(0, -1);

        if (gl_number_id != '') {
			confirm_messagebox("Are you sure you want to delete?", function() {
                data = {"action": "spa_gl_system_mapping",
                        "flag": "d",
                        "del_gl_number_id": gl_number_id
                        };
                adiha_post_data('alert', data, '', '', 'map_gl_codes.delete_callback');
            });
        } else {
			show_messagebox("Please select a row from grid!");
		}
	}
    /**
     * [map_gl_codes.delete_callback]
     */
    map_gl_codes.delete_callback = function(result) {
        if (result[0].recommendation.indexOf(",") > -1) {
            var ids = result[0].recommendation.split(",");
            var count_ids = ids.length;
            for (var i = 0; i < count_ids; i++ ) {
                full_id = 'tab_' + ids[i];
                if (map_gl_codes.pages[full_id]) {
                    map_gl_codes.tabbar.cells(full_id).close();
                }
            }
        } else {
            full_id = 'tab_' + result[0].recommendation;
            if (map_gl_codes.pages[full_id]) {
                map_gl_codes.tabbar.cells(full_id).close();
            }
        }
        map_gl_codes.refresh_grid();
        map_gl_codes.menu.setItemDisabled("delete");
    }
    
</script>
