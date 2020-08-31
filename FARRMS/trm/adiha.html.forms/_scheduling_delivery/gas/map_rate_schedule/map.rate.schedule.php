<?php
/**
* Map rate schedule screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html> 
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
    
 <body>
    <?php     
    global $image_path;
    $php_script_loc = $app_php_script_loc;
    $app_user_loc = $app_user_name;
    
    
    $rights_map_rate_schedule = 10163300;
    $rights_map_rate_schedule_add_save = 10163310;
    $rights_map_rate_schedule_delete = 10163311;
    
    list (
        $has_rights_map_rate_schedule,
        $has_rights_map_rate_schedule_add_save,
        $has_rights_map_rate_schedule_delete
    ) = build_security_rights(
        $rights_map_rate_schedule,
        $rights_map_rate_schedule_add_save,
        $rights_map_rate_schedule_delete
    );
    

    $form_namespace = 'map_rate_schedules';
    $form_obj = new AdihaStandardForm($form_namespace, 10163300);
    $form_obj->define_grid("location_loss_factor", "", 't');
    $form_obj->define_layout_width("510");
    $form_obj->define_custom_functions('save_map_rate_schedules', 'load_map_rate_schedules', 'delete_map_rate_schedules');
    echo $form_obj->init_form('Map Rate Schedule', 'Details');
    echo $form_obj->close_form();
    ?>
</body>   
    
<script>
    var has_right_map_rate_schedule_add_save = <?php echo (($has_rights_map_rate_schedule_add_save) ? $has_rights_map_rate_schedule_add_save : '0'); ?>;;
    var has_right_map_rate_schedule_delete = <?php echo (($has_rights_map_rate_schedule_delete) ? $has_rights_map_rate_schedule_delete : '0'); ?>;;
    var image_path = '<?php echo $image_path; ?>';
    var date_format = '<?php echo $date_format; ?>';
    var php_script_loc = '<?php echo $php_script_loc; ?>'
    
    /*
     * load_map_rate_schedules [Load function]
     */
    map_rate_schedules.load_map_rate_schedules = function(win, tab_id, grid_obj) {
        var active_object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        var map_rate_schedule_name = map_rate_schedules.tabbar.tabs(tab_id).getText();
        
        map_rate_schedules["inner_tab_layout_" + active_object_id] = win.attachLayout("2E");
        map_rate_schedules["inner_tab_layout_" + active_object_id].cells('a').setHeight(150);
        map_rate_schedules["inner_tab_layout_" + active_object_id].cells('a').hideHeader();
        map_rate_schedules["inner_tab_layout_" + active_object_id].cells('b').setText('Fuel/Loss Factor');

        data = {"action": "spa_create_application_ui_json",
                    "flag": "j",
                    "application_function_id": 10163300,
                    "template_name": "map rate schedules",
                    "parse_xml": "<Root><PSRecordSet location_loss_factor_id=\"" + active_object_id + "\"></PSRecordSet></Root>"
                 };

        adiha_post_data('return_array', data, '', '', 'load_map_rate_schedules_callback', '');
        
        var map_rate_schedule_toolbar =   [
                                    {id:"t1", text:"Edit", img:"edit.gif", items:[
                                        {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add", enabled: has_right_map_rate_schedule_add_save},
                                        {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete", enabled: 0}
                                    ]},
                                    {id:"t2", text:"Export", img:"export.gif", items:[
                                        {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                                        {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                                    ]}
                                    ];
        
        map_rate_schedules["toolbar_" + active_object_id] = map_rate_schedules["inner_tab_layout_" + active_object_id].cells('b').attachMenu();
        map_rate_schedules["toolbar_" + active_object_id].setIconsPath(image_path + 'dhxmenu_web/');
        map_rate_schedules["toolbar_" + active_object_id].loadStruct(map_rate_schedule_toolbar);
        map_rate_schedules["toolbar_" + active_object_id].attachEvent('onClick', function(id){
            switch(id) {
                case "add":
                    var new_id = (new Date()).valueOf();
                    map_rate_schedules["grid_" + active_object_id].addRow(new_id,'');
                    break;
                case "delete":
                    var delete_xml = '';
                    var row_id = map_rate_schedules["grid_" + active_object_id].getSelectedRowId();
                    var row_id_array = row_id.split(",");
                    for (count = 0; count < row_id_array.length; count++) {
                        if (map_rate_schedules["grid_" + active_object_id].cells(row_id_array[count],0).getValue() != '') {
                            delete_xml += '<GridRow map_rate_schedule_id = \"' + map_rate_schedules["grid_" + active_object_id].cells(row_id_array[count],0).getValue() + '\"></GridRow>'
                        }
                        map_rate_schedules["grid_" + active_object_id].deleteRow(row_id_array[count]);
                    }
                    
                    map_rate_schedules["grid_" + active_object_id].setUserData("","deleted_xml", delete_xml);
                    break;
                case "excel":
                    map_rate_schedules["grid_" + active_object_id].toExcel(php_script_loc + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                    break;
                case "pdf":
                    map_rate_schedules["grid_" + active_object_id].toPDF(php_script_loc +'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                    break;
            }
        });
        
        map_rate_schedules["grid_" + active_object_id] = map_rate_schedules["inner_tab_layout_" + active_object_id].cells('b').attachGrid();
        map_rate_schedules["grid_" + active_object_id].setHeader(get_locale_value('System ID, Location Loss, Effective Date, Fuel Loss, Fuel Loss Group',true)); 
        map_rate_schedules["grid_" + active_object_id].setColumnIds("map_rate_schedule_id, location_loss_factor_id, effective_date, fuel_loss, fuel_loss_group");
        map_rate_schedules["grid_" + active_object_id].setColTypes("ro,ro,dhxCalendarA,ed,combo"); 
        map_rate_schedules["grid_" + active_object_id].setColumnMinWidth("0,0,200,150,150");
        map_rate_schedules["grid_" + active_object_id].setInitWidths('0,0,250,150,150');
        map_rate_schedules["grid_" + active_object_id].setColSorting('int,str,date,int,str'); 
        map_rate_schedules["grid_" + active_object_id].init(); 
        map_rate_schedules["grid_" + active_object_id].setColumnsVisibility('true,true,false,false,false'); 
        map_rate_schedules["grid_" + active_object_id].setDateFormat(date_format);
        map_rate_schedules["grid_" + active_object_id].enableMultiselect(true);
        
        map_rate_schedules["grid_" + active_object_id].attachEvent("onRowSelect", function(id,ind){
            if (has_right_map_rate_schedule_add_save) {
                map_rate_schedules["toolbar_" + active_object_id].setItemEnabled('delete');
            }
        });
        
        //Loading dropdown for Fuel Loss Group
        var cm_param = {
                            "action": "('SELECT time_series_definition_id, time_series_name FROM time_series_definition WHERE time_series_type_value_id = 39003')"            
                        };

        cm_param = $.param(cm_param);
        var url = js_dropdown_connector_url + '&' + cm_param;
        var combo_obj = map_rate_schedules["grid_" + active_object_id].getColumnCombo(4);
        combo_obj.enableFilteringMode(true);               
        combo_obj.load(url, function() {
            var sql_param = {
                "flag": "s",
                "action":"spa_map_rate_schedules",
                "grid_type":"g",
                "location_loss_factor_id": active_object_id
            };
            sql_param = $.param(sql_param);
            var sql_url = js_data_collector_url + "&" + sql_param;
            map_rate_schedules["grid_" + active_object_id].clearAll();
            map_rate_schedules["grid_" + active_object_id].load(sql_url); 
        });
        
        win.progressOff();    
    }
    
    /*
     * load_map_rate_schedules_callback [Callback of Load function]
     */
    load_map_rate_schedules_callback = function(result) {
        var active_tab_id = map_rate_schedules.tabbar.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        var form_json = result[0][2];
        
        map_rate_schedules["form" + active_object_id] = map_rate_schedules["inner_tab_layout_" + active_object_id].cells('a').attachForm();
        if (form_json) {
            map_rate_schedules["form" + active_object_id].loadStruct(form_json, function(){
                var value = map_rate_schedules["form" + active_object_id].getItemValue('rate_schedule_type');
                var from_loc =  map_rate_schedules["form" + active_object_id].getItemValue('from_location_id');
                var to_loc = map_rate_schedules["form" + active_object_id].getItemValue('to_location_id');
                var from_zone =  map_rate_schedules["form" + active_object_id].getItemValue('from_zone');
                var to_zone = map_rate_schedules["form" + active_object_id].getItemValue('to_zone');
                reload_location_zone(value, from_loc, to_loc, from_zone, to_zone);
            });
        }
        
        map_rate_schedules["form" + active_object_id].attachEvent("onChange", function (name, value){
             if(name == 'rate_schedule_type') {
                reload_location_zone(value, '', '', '', '');
             }
        });
    }
    
    /*
     * save_map_rate_schedules [Save Function]
     */
    map_rate_schedules.save_map_rate_schedules = function(tab_id) {
        var active_tab_id = map_rate_schedules.tabbar.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        map_rate_schedules["grid_" + active_object_id].clearSelection();
        var rate_schedule_type = map_rate_schedules["form" + active_object_id].getItemValue('rate_schedule_type');
        
        var status = validate_form(map_rate_schedules["form" + active_object_id]);
        if (!status) {
            generate_error_message();
            return;
        };
        map_rate_schedules.tabbar.tabs(active_tab_id).getAttachedToolbar().disableItem('save');
        var form_xml = "<FormXML ";
        data = map_rate_schedules["form" + active_object_id].getFormData();
        for (var a in data) {
            field_label = a;
            field_value = data[a];
            if (field_label == 'from_location_id') {
                if (rate_schedule_type == 39101 || rate_schedule_type == 39102) {
                    form_xml += " from_location_id=\"" + field_value + "\"";
                } else {
                    form_xml += " from_zone=\"" + field_value + "\"";
                }
            } else if (field_label == 'to_location_id') {
                if (rate_schedule_type == 39101 || rate_schedule_type == 39103) {
                    form_xml += " to_location_id=\"" + field_value + "\"";
                } else {
                    form_xml += " to_zone=\"" + field_value + "\"";
                }
            } else if (field_label == 'from_zone' || field_label == 'to_zone') {
                form_xml += ""
            } else {
                form_xml += " " + field_label + "=\"" + field_value + "\"";
            }
            
        }
        form_xml += "></FormXML>";
        
        var grid_xml = '<GridGroup><Grid grid_id=\"map_rate_schedule\">';
        var changed_rows = map_rate_schedules["grid_" + active_object_id].getChangedRows(true);
        if(changed_rows != '') {
            changed_rows = changed_rows.split(',');
            for (i = 0; i < changed_rows.length; i++) {
                grid_xml += '<GridRow ';
                
                for (j = 0; j < map_rate_schedules["grid_" + active_object_id].getColumnsNum(); j++) {
                    if(j == 2) {
                        var effective_date = map_rate_schedules["grid_" + active_object_id].cells(changed_rows[i],j).getValue();
                        grid_xml += ' ' + map_rate_schedules["grid_" + active_object_id].getColumnId(j) + '="' + dates.convert_to_sql(effective_date) + '"'; 
                    } else {
                        grid_xml += ' ' + map_rate_schedules["grid_" + active_object_id].getColumnId(j) + '="' + map_rate_schedules["grid_" + active_object_id].cells(changed_rows[i],j).getValue() + '"'; 
                    }
                }
                
                grid_xml += ' />'
            }
        }
        grid_xml += '</Grid>';
        
        var deleted_xml = map_rate_schedules["grid_" + active_object_id].getUserData("", "deleted_xml");
        if (deleted_xml != null && deleted_xml != "") {
            grid_xml += "<GridDelete grid_id=\"map_rate_schedule\">";
            grid_xml += deleted_xml;
            grid_xml += "</GridDelete>";
        }
        
        grid_xml += '</GridGroup>';
        var final_xml = '<Root function_id="10163300">' + form_xml + grid_xml + '</Root>';
        
        if (deleted_xml != null && deleted_xml != "") {
            del_msg =  "Some data has been deleted from Rate Schedule grid. Are you sure you want to save?";
            dhtmlx.message({
                type: "confirm-warning",
                title: "Warning",
                text: del_msg,
                ok: "Confirm",
                callback: function(result) {
                    if (result) {
                        data = {"action": "spa_process_form_data", "xml": final_xml};
                        result = adiha_post_data("alert", data, "", "", "save_callback"); 
                    } else {
                        var active_tab_id = map_rate_schedules.tabbar.getActiveTab();
                        if (has_right_map_rate_schedule_add_save) {
                            map_rate_schedules.tabbar.tabs(active_tab_id).getAttachedToolbar().enableItem('save');
 
                        };
                    }               
                }
            });
        } else {
            data = {"action": "spa_process_form_data", "xml": final_xml};
            result = adiha_post_data("return_json", data, "", "", "save_callback");            
        }
    }
    
    /*
     * save_callback [Callback of Save Function]
     */
    save_callback = function(result) {
        var active_tab_id = map_rate_schedules.tabbar.getActiveTab();
        if (has_right_map_rate_schedule_add_save) {
            map_rate_schedules.tabbar.tabs(active_tab_id).getAttachedToolbar().enableItem('save');
 
        };

        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        var return_data = JSON.parse(result);
        
        if (return_data[0].errorcode == 'Error') {
            dhtmlx.message({
                title:"Alert",
                type:"alert",
                text:return_data[0].message
            });
            return;
        }
        
        var tab_name = map_rate_schedules.tabbar.tabs(active_tab_id).getText();
        var logical_name = map_rate_schedules["form" + active_object_id].getItemValue('logical_name');
        
        if (tab_name == 'New') {
            var new_id = return_data[0].recommendation;
            map_rate_schedules["form" + active_object_id].setItemValue('location_loss_factor_id', new_id);
            map_rate_schedules.tabbar.tabs(active_object_id).setText(logical_name);
        } else {
            map_rate_schedules.tabbar.tabs(active_tab_id).setText(logical_name);
        }
        
        refresh_map_rate_schedule_grid();
        map_rate_schedules["toolbar_" + active_object_id].setItemDisabled('delete');
        map_rate_schedules["grid_" + active_object_id].setUserData("","deleted_xml", "");
        
        
        dhtmlx.message({
            text:return_data[0].message,
            expire:1000
        });
        
        refresh_grid();
    }
    
    /*
     * delete_map_rate_schedules [Delete Function]
     */
    map_rate_schedules.delete_map_rate_schedules = function() {
        var selected_id = map_rate_schedules.grid.getSelectedId();
        
        if(selected_id == null) {
            show_messagebox('Please select the data you want to delete.');
            return;
        }
        
        var selected_array = new Array();
        var selected_id_array = new Array();
        selected_array = selected_id.split(",");
        var tree_level_flag = 0
        
        for (count = 0; count < selected_array.length; count++) {
            var tree_level = map_rate_schedules.grid.getLevel(selected_array[count]);
            if (tree_level == 0) {
                tree_level_flag = 1;
            }
            
            temp_id = map_rate_schedules.grid.cells(selected_array[count], 1).getValue();
            selected_id_array.push(temp_id);
        }
        
        if (tree_level_flag == 1) {
            show_messagebox('Please select the logical name.');
            return;
        }
        
        location_loss_factor_id = selected_id_array.toString();
        var data = {
                    "action": "spa_map_rate_schedules",
                    "flag": "d",
                    "location_loss_factor_id": location_loss_factor_id
                };
        
        adiha_post_data('confirm', data, '', '', 'map_rate_schedules.delete_callback', '');
    }
    
    map_rate_schedules.delete_callback = function(result) {
        if (result[0].recommendation.indexOf(",") > -1) {
            var ids = result[0].recommendation.split(",");
            var count_ids = ids.length;
            for (var i = 0; i < count_ids; i++ ) {
                full_id = 'tab_' + ids[i];
                if (map_rate_schedules.pages[full_id]) {
                    map_rate_schedules.tabbar.cells(full_id).close();
                }
            }
        } else {
            full_id = 'tab_' + result[0].recommendation;
            if (map_rate_schedules.pages[full_id]) {
                map_rate_schedules.tabbar.cells(full_id).close();
            }
        }
        refresh_grid();
    }
    
    /*
     * reload_location_zone [To populate the from location/zone and to location/zone according to rate schedule type]
     */
    reload_location_zone = function(rate_schedule_type, from_loc, to_loc, from_zone, to_zone) {
        var active_tab_id = map_rate_schedules.tabbar.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        var from_flag, to_flag;
        
        if (rate_schedule_type == 39101) {
            from_flag = 'l';
            to_flag = 'l';
        } else if (rate_schedule_type == 39102) {
            from_flag = 'l';
            to_flag = 'z';
        } else if (rate_schedule_type == 39103) {
            from_flag = 'z';
            to_flag = 'l';
        } else if (rate_schedule_type == 39104) {
            from_flag = 'z';
            to_flag = 'z';
        }
        
        var cm_param = {
                            "action": "spa_map_rate_schedules",
                            "flag": from_flag
                        };

        cm_param = $.param(cm_param);
        var url = js_dropdown_connector_url + '&has_blank_option=false&' + cm_param;
        var from_combo = map_rate_schedules["form" + active_object_id].getCombo('from_location_id'); 
        from_combo.setComboText('');
        from_combo.clearAll();
        from_combo.load(url)
        
        var cm_param1= {
                            "action": "spa_map_rate_schedules",
                            "flag": to_flag
                        };

        cm_param1 = $.param(cm_param1);
        var url1 = js_dropdown_connector_url + '&has_blank_option=false&' + cm_param1;
        var to_combo = map_rate_schedules["form" + active_object_id].getCombo('to_location_id'); 
        to_combo.setComboText('');
        to_combo.clearAll();
        to_combo.load(url1, function(){
            if (rate_schedule_type == 39101) {
                from_combo.setComboValue(from_loc);
                to_combo.setComboValue(to_loc);
            } else if (rate_schedule_type == 39102) {
                from_combo.setComboValue(from_loc);
                to_combo.setComboValue(to_zone);
            } else if (rate_schedule_type == 39103) {
                from_combo.setComboValue(from_zone);
                to_combo.setComboValue(to_loc);
            } else if (rate_schedule_type == 39104) {
                from_combo.setComboValue(from_zone);
                to_combo.setComboValue(to_zone);
            }
        });
    }
    
    /*
     * Refresh the grid
     */
    function refresh_grid() {
        var param = {
                        "action": "spa_map_rate_schedules",
                        "flag": "g",
                        "grid_type": "tg",
                        "grouping_column": "rate_schedule_type,logical_name",            
                 };

        param = $.param(param);
        var param_url = js_data_collector_url + "&" + param;
        map_rate_schedules.grid.clearAll();
        map_rate_schedules.grid.loadXML(param_url,function(){
            map_rate_schedules.grid.filterByAll();
        });
    }
    
    function refresh_map_rate_schedule_grid() {
        var active_tab_id = map_rate_schedules.tabbar.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        
        var sql_param = {
                "flag": "s",
                "action":"spa_map_rate_schedules",
                "grid_type":"g",
                "location_loss_factor_id": active_object_id
        };
        sql_param = $.param(sql_param);
        var sql_url = js_data_collector_url + "&" + sql_param;
        map_rate_schedules["grid_" + active_object_id].clearAll();
        map_rate_schedules["grid_" + active_object_id].load(sql_url,function(){
            map_rate_schedules["grid_" + active_object_id].filterByAll();
        });
    }
</script>