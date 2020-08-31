<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge, chrome=1"/>
    <?php require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
<?php
    $function_id = 20006200; //function id for configuration manager
    $form_namespace = 'configuration_manager';

    $form_obj = new AdihaStandardForm($form_namespace, $function_id);
    $form_obj->define_grid("ConfigurationManager");
    $form_obj->define_layout_width(330);
    $form_obj->define_custom_functions('save_function', '', '', 'form_load_complete_function');
    echo $form_obj->init_form('Default Codes');

    echo $form_obj->close_form();
?>
<body>
    <script type = 'text/javascript'>
        var grid_obj = []; //made array of grid object

        $(function() {
            configuration_manager.menu.hideItem('t1'); //hidden edit menu on main grid
        });

        configuration_manager.save_function = function(tab_id) {
            var ins_status = 0;
            var del_status = 0;
            var grid_xml = '<GridGroup>';
            var win = configuration_manager.tabbar.cells(tab_id);
            var object_id = (tab_id.indexOf('tab_') != -1) ? tab_id.replace('tab_', '') : tab_id;
            object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(' ', ''));
            var tab_obj = win.tabbar[object_id];
            var detail_tabs = tab_obj.getAllTabs();
            $.each(detail_tabs, function(index, value) {
                layout_obj = tab_obj.cells(value).getAttachedObject();
                layout_obj.forEachItem(function(cell) {
                    attached_obj = cell.getAttachedObject();
                    grid_id = attached_obj.getUserData('', 'grid_id');
                    grid_label = attached_obj.getUserData('', 'grid_label');

                    if (attached_obj instanceof dhtmlXGridObject) {
                        //check if rows are deleted or not at first while saving
                        attached_obj.clearSelection();

                        var ids = attached_obj.getChangedRows();
                        if (ids != '') {
                            attached_obj.clearSelection();
                            attached_obj.setSerializationLevel(false,false,true,true,true,true);
                            var grid_status = configuration_manager.validate_form_grid(attached_obj, grid_label);
                            grid_xml += '<Grid grid_id="' + grid_id + '">';
                            var changed_ids = [];
                            changed_ids = ids.split(',');
                            if (grid_status) {
                                $.each(changed_ids, function(index, value) {
                                    grid_xml += '<GridRow ';

                                    var pk_index = attached_obj.getColIndexById('adiha_default_codes_values_id');
                                    var desc_index = attached_obj.getColIndexById('description');
                                    var seq_index = attached_obj.getColIndexById('seq_no');
                                    var var_index = attached_obj.getColIndexById('var_value');
                                    var config_index = attached_obj.getColIndexById('default_code_id');
                                    var seq_desc_index = attached_obj.getColIndexById('sequence_desc');
  
                                    var pk_id = attached_obj.cells(value, pk_index).getValue();
                                    var code_id = attached_obj.cells(value, config_index).getValue();
                                    var seq_no = attached_obj.cells(value, seq_index).getValue();
                                    var var_value = attached_obj.cells(value, var_index).getValue();
                                    var desc = attached_obj.cells(value, desc_index).getValue();
                                    var seq_desc = attached_obj.cells(value, seq_desc_index).getValue();

                                    if (var_value == '') {
                                        ins_status = 0;
                                        // attached_obj.setCellTextStyle(changed_ids, var_index, "border-bottom:2px solid red;");
                                        dhtmlx.message({
                                            title: 'Alert',
                                            type: 'alert',
                                            ok: 'OK',
                                            text: 'Data Error in <b>Detail</b> grid. Please check the data in column <b>Value</b> and resave.'
                                        });
                                    } else {
                                        //update mode
                                        grid_xml += ' adiha_default_codes_values_id = "' + pk_id +'"';
                                        grid_xml += ' default_code_id = "' + object_id +'"';
                                        grid_xml += ' seq_no = "' + seq_no +'"';
                                        grid_xml += ' description = "' + desc +'"';
                                        grid_xml += ' var_value = "' + var_value + '"';
                                        grid_xml += ' sequence_desc = "' + seq_desc + '"';
                                        grid_xml += " ></GridRow> ";
                                        ins_status = 1;
                                    }
                                });
                                grid_xml += '</Grid>';
                            }
                        }
                    }
                });
            });

            grid_xml += '</GridGroup>';
            var xml = '<Root function_id = "20006200" object_id = "' + object_id + '">';
            xml += grid_xml;
            xml += '</Root>';
            xml = xml.replace(/'/g, "\"");

            if (ins_status == 1) {
                data_update = { 'action': 'spa_adiha_default_codes_values', 'flag': 'modify', 'xml': xml };
                result = adiha_post_data('alert', data_update, '', '', 'configuration_manager.post_callback');
            } else {
                configuration_manager.tabbar.cells(tab_id).getAttachedToolbar().disableItem('save');
            }
        }

        configuration_manager.post_callback = function (result) {
            if (result[0].errorcode == "Success") {
                configuration_manager.clear_delete_xml();
                var tab_id = configuration_manager.tabbar.getActiveTab();                
                if (result[0].recommendation != null) {                    
                    var win = configuration_manager.tabbar.cells(tab_id);
                    var object_id = (tab_id.indexOf('tab_') != -1) ? tab_id.replace('tab_', '') : tab_id;
                    object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(' ', ''));
                    var tab_obj = win.tabbar[object_id];
                    var detail_tabs = tab_obj.getAllTabs();
                    $.each(detail_tabs, function(index, value) {
                        layout_obj = tab_obj.cells(value).getAttachedObject();
                        layout_obj.forEachItem(function(cell) {
                            attached_obj = cell.getAttachedObject();

                            if (attached_obj instanceof dhtmlXGridObject) {
                                var desc_index = attached_obj.getColIndexById('description');
                                var var_index = attached_obj.getColIndexById('var_value');
                                var combo_obj = attached_obj.getColumnCombo(desc_index);
                                var combo_or_text_index = configuration_manager.grid.getColIndexById('combo_or_text');
                                var row_id_index = configuration_manager.grid.getColIndexById('default_code_id');
                                var row_index = configuration_manager.grid.findCell(object_id, row_id_index, true);

                                var combo_or_text = configuration_manager.grid.cells(row_index[0][0], combo_or_text_index).getValue();

                                if (combo_or_text == 'combo') {
                                    var load_grid_sql_combo = "EXEC spa_adiha_default_codes_values @flag = 'combo_grid', @default_code_id = " + object_id + " ";
                                    var sql_param_combo = { 'sql' : load_grid_sql_combo };
                                    sql_param_combo = $.param(sql_param_combo);
                                    var sql_url_combo = js_data_collector_url + "&" + sql_param_combo;
                                    attached_obj.clearAll();
                                    attached_obj.load(sql_url_combo);
                                } else if (combo_or_text == 'text') {
                                    var load_grid_sql_text = "EXEC spa_adiha_default_codes_values @flag = 'text_grid', @default_code_id = " + object_id + " ";
                                    var sql_param_text = { 'sql' : load_grid_sql_text };
                                    sql_param_text = $.param(sql_param_text);
                                    var sql_url_text = js_data_collector_url + "&" + sql_param_text;
                                    attached_obj.clearAll();
                                    attached_obj.load(sql_url_text);
                                }
                            }
                        });
                    });
                    configuration_manager.refresh_grid("", configuration_manager.open_tab);
                    configuration_manager.tabbar.cells(tab_id).getAttachedToolbar().disableItem('save');
                } else {
                    configuration_manager.refresh_grid();
                }
            }
        }

        configuration_manager.form_load_complete_function = function(win, id) {
            win.progressOn();
            var object_id = (id.indexOf('tab_') != -1) ? id.replace('tab_', '') : id;
            object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(' ', ''));
            configuration_manager.tabbar.cells(id).getAttachedToolbar().disableItem('save');
            var tab_obj = win.tabbar[object_id];
            var detail_tabs = tab_obj.getAllTabs();

            var seq_ind = configuration_manager.grid.getColIndexById('sequence');
            var count = configuration_manager.grid.cells(configuration_manager.grid.getSelectedRowId(), seq_ind).getValue();
            var is_equal = 'true';
            var get_count_sql = { 'action': 'spa_adiha_default_codes_values', 'flag': 'get_count', 'default_code_id': object_id };
            adiha_post_data('return_array', get_count_sql, '', '', function(return_array) {
                if (return_array[0][0] < count) {
                    is_equal = 'false';
                }
                $.each(detail_tabs, function(index, value) {
                    layout_obj = tab_obj.cells(value).getAttachedObject();
                    layout_obj.cells('a').getAttachedMenu().hideItem('delete');
                    if (is_equal == 'true') {
                        layout_obj.cells('a').getAttachedMenu().hideItem('t1');
                    } else if (is_equal == 'false') {
                        layout_obj.cells('a').getAttachedMenu().showItem('t1');
                    }

                    layout_obj.forEachItem(function(cell) {
                        attached_obj = cell.getAttachedObject();
                        if (attached_obj instanceof dhtmlXGridObject) {
                            grid_obj[id] = attached_obj;

                            attached_obj.attachEvent("onRowAdded", function(rId) {
                                var seq_no_c_index = grid_obj[id].getColIndexById('seq_no');
                                grid_obj[id].cells(rId, seq_no_c_index).setValue(grid_obj[id].getStateOfView()[3]);

                                if (grid_obj[id].getStateOfView()[3] > count) {
                                    grid_obj[id].deleteRow(rId);
                                    show_messagebox('You are exceeding the limit.');
                                    return false;
                                }
                            });

                            attached_obj.attachEvent("onSelectStateChanged", function(id) {
                                var tab_id = configuration_manager.tabbar.getActiveTab();
                                configuration_manager.tabbar.cells(tab_id).getAttachedToolbar().enableItem('save');
                            });

                            var grid_xml = '';
                            grid_xml = '<GridGroup>';
                            grid_id = attached_obj.getUserData('', 'grid_id');
                            var ids = attached_obj.getSelectedRowId();
                            var desc_index = attached_obj.getColIndexById('description');
                            var var_index = attached_obj.getColIndexById('var_value');
                            var instance_index = attached_obj.getColIndexById('sequence_desc');
                            grid_obj[id].setColumnHidden(instance_index, true);

                            var combo_obj = attached_obj.getColumnCombo(desc_index);

                            /* modified logic here to get combo mode or text mode value from main grid */
                            var combo_or_text_index = configuration_manager.grid.getColIndexById('combo_or_text');
                            var row_id_index = configuration_manager.grid.getColIndexById('default_code_id');
                            var row_index = configuration_manager.grid.findCell(object_id, row_id_index, true);
                            var combo_or_text = configuration_manager.grid.cells(row_index[0][0], combo_or_text_index).getValue();

                            if (combo_or_text == 'combo') {
                                //if the table contain possible values
                                var cm_params = {
                                                'action' : 'spa_adiha_default_codes_values',
                                                'flag' : 'load_combo',
                                                'default_code_id' : object_id,
                                                'has_blank_option' : 'false'
                                            };
                                cm_params = $.param(cm_params);
                                var urls = js_dropdown_connector_url + '&' + cm_params;
                                if (count <= 1) {
                                    grid_obj[id].setColumnHidden(instance_index, true);
                                } else {
                                    grid_obj[id].setColumnHidden(instance_index, false);
                                }
                                
                                combo_obj.load(urls, function() {
                                    // added logic to load value on grid after the dropdown is completely loaded.
                                    var load_grid_sql_combo = "EXEC spa_adiha_default_codes_values @flag = 'combo_grid', @default_code_id = " + object_id + " ";
                                    var sql_param_combo = { 'sql' : load_grid_sql_combo };
                                    sql_param_combo = $.param(sql_param_combo);
                                    var sql_url_combo = js_data_collector_url + "&" + sql_param_combo;
                                    grid_obj[id].clearAll();
                                    grid_obj[id].load(sql_url_combo, function() {
                                        win.progressOff();
                                    });
                                });

                                combo_obj.attachEvent('onChange', function(value, text) {
                                    var tab_id = configuration_manager.tabbar.getActiveTab();
                                    var selected_id = grid_obj[tab_id].getSelectedRowId();
                                    var var_value_index = grid_obj[tab_id].getColIndexById('var_value');
                                    grid_obj[tab_id].cells(selected_id, var_value_index).setAttribute('validation', '');
                                    /*previously value column data was populated by sending request on backend, changed the method
                                    by setting the var_value of selected value from description column
                                    */
                                    //set the value of description dropdown on var_value
                                    grid_obj[tab_id].cells(selected_id, var_value_index).setValue(value);
                                });
                            } else if (combo_or_text == 'text') {
                                //when no possible values
                                grid_obj[id].editStop();
                                //change the type of column "value" to editable because it needs to be manually added
                                //changed the type of column "description" to editable from combo as it needs to be manually added
                                grid_obj[id].setColumnExcellType(desc_index, 'ed');
                                grid_obj[id].setColumnExcellType(var_index, 'ed');

                                //loading the value which has no possible value (text mode)
                                var load_grid_sql_text = "EXEC spa_adiha_default_codes_values @flag = 'text_grid', @default_code_id = " + object_id + " ";
                                var sql_param_text = { 'sql' : load_grid_sql_text };
                                sql_param_text = $.param(sql_param_text);
                                var sql_url_text = js_data_collector_url + "&" + sql_param_text;
                                grid_obj[id].clearAll();
                                grid_obj[id].load(sql_url_text);

                                //change the validation of value column to NotEmpty on text mode as it needs to be filled by user manually
                                grid_obj[id].setColValidators(",,ValidInteger,NotEmpty,NotEmpty,NotEmpty");
                                win.progressOff();
                            }
                        }
                    });
                });
            });
        }
    </script>
</body>
</html>