<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
        <?php require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
    </head>
    <?php
    $right_manage_privilege = 10103012;
    $right_delete = 10103011;
	list (
		$has_rights_manage_privilege,
        $has_rights_delete
	) = build_security_rights(
		$right_manage_privilege,
        $right_delete
    );
    
    $form_namespace = 'meter_data';
    $rights_setup_meter_iu = 10103010;
    list (
        $has_rights_setup_meter_iu
    ) = build_security_rights(
        $rights_setup_meter_iu
    );    
    $form_obj = new AdihaStandardForm($form_namespace, 10103000);
    $form_obj->define_grid("meter_id", "EXEC spa_meter_id 'g'");
    $form_obj->define_custom_functions('save_meter', '');
    //$form_obj->enable_multiple_select();
    $form_obj->add_privilege_menu($has_rights_manage_privilege);
    $form_obj->enable_grid_pivot();
    echo $form_obj->init_form('Meters', 'Meter Details');
    echo $form_obj->close_form();
    ?>
    <body>
    </body>
    <script>
        var has_rights_setup_meter_iu = Boolean('<?php echo $has_rights_setup_meter_iu;?>');
        var has_rights_delete = Boolean('<?php echo $has_rights_delete; ?>');
        var has_rights_manage_privilege = Boolean('<?php echo $has_rights_manage_privilege; ?>');

        var default_uom_id = '6'; // Set default KWh UOM to insert in channel if channel is not defined
        var delete_grid_name = "";

        meter_data.save_meter = function (tab_id) {
            var validation_status = 1;
            var win = meter_data.tabbar.cells(tab_id);
            var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
            var m = object_id;
            object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(" ", ""));

            var tab_obj = win.tabbar[object_id];
            var detail_tabs = tab_obj.getAllTabs();
            var grid_xml = "<GridGroup>";
            var form_xml = "<FormXML ";
            var form_status = true;
            var first_err_tab;
            var tabsCount = tab_obj.getNumberOfTabs();
            $.each(detail_tabs, function (index, value) {
                layout_obj = tab_obj.cells(value).getAttachedObject();
                layout_obj.forEachItem(function (cell) {
                    attached_obj = cell.getAttachedObject();
                    if (attached_obj instanceof dhtmlXGridObject) {
                        attached_obj.clearSelection();
                        grid_label = attached_obj.getUserData("", "grid_label");
                        //check if the there is any row in the recorder properties. Grid name hard coded
                        if (grid_label == "Meter Channel") {
                            check_meter_channel(attached_obj, object_id);
                        }
                        var ids = attached_obj.getChangedRows(true);
                        grid_id = attached_obj.getUserData("", "grid_id");
                        deleted_xml = attached_obj.getUserData("", "deleted_xml");
                        if (deleted_xml != null && deleted_xml != "") {
                            grid_xml += "<GridDelete grid_id=\"" + grid_id + "\">";
                            grid_xml += deleted_xml;
                            grid_xml += "</GridDelete>";
                            if (delete_grid_name == "") {
                                delete_grid_name = grid_label
                            } else {
                                delete_grid_name += "," + grid_label
                            }
                            ;
                        };
                        if (ids != "") {
                            attached_obj.setSerializationLevel(false, false, true, true, true, true);
                            if (validation_status != 0) {
                                var grid_status = meter_data.validate_form_grid(attached_obj, grid_label);
                            }
                            grid_xml += "<Grid grid_id=\"" + grid_id + "\">";
                            var changed_ids = new Array();
                            changed_ids = ids.split(",");
                            if (grid_status) {
                                $.each(changed_ids, function (index, value) {
                                    attached_obj.setUserData(value, "row_status", "new row");
                                    grid_xml += "<GridRow ";
                                    for (var cellIndex = 0; cellIndex < attached_obj.getColumnsNum(); cellIndex++) {
                                        grid_xml += " " + attached_obj.getColumnId(cellIndex) + '="' + attached_obj.cells(value, cellIndex).getValue() + '"';
                                    }
                                    grid_xml += " ></GridRow> ";
                                });
                            } else {
                                validation_status = 0;
                            }
                            ;
                            grid_xml += "</Grid>";
                        }
                    } else if (attached_obj instanceof dhtmlXForm) {
                        var status = validate_form(attached_obj);
                        form_status = form_status && status; 
                        if (tabsCount == 1 && !status) {
                            first_err_tab = "";
                        } else if ((!first_err_tab) && !status) {
                             first_err_tab = tab_obj.cells(value);
                        }
                        if (status) {
                            data = attached_obj.getFormData();
                            for (var a in data) {
                                field_label = a;

                                if (attached_obj.getItemType(field_label) == "calendar") {
                                    field_value = attached_obj.getItemValue(field_label, true);
                                } else {
                                    field_value = data[a];
                                }

                                if (field_label == 'description') {
                                    if (data[a] == '') {
                                        field_value = data['recorderid'];
                                    }
                                }
                                
                                if (field_label == 'source_uom_id') {
                                    default_uom_id = data['source_uom_id']
                                    
                                }


                                form_xml += " " + field_label + "=\"" + field_value + "\"";
                            }
                        }  else {
                            /*show_messagebox("One or more data are missing. Please Check.");*/
                            //generate_error_message();
                            //tab_obj.cells(value).setActive();
                            validation_status = 0;
                        }
                    }
                });
            });
            form_xml += "></FormXML>";
            grid_xml += "</GridGroup>";
            var xml = "<Root function_id=\"10103000\" object_id=\"" + object_id + "\">";
            xml += form_xml;
            xml += grid_xml;
            xml += "</Root>";
            xml = xml.replace(/'/g, "\"");

            if (validation_status == 1) {
                meter_data.tabbar.tabs(tab_id).getAttachedToolbar().disableItem('save');
                var del_msg = "";
                data = {"action": "spa_process_form_data", "xml": xml};
                if (delete_grid_name != "") {
                    del_msg = "Some data has been deleted from " + delete_grid_name + " grid. Are you sure you want to save?";
                    result = adiha_post_data("confirm-warning", data, "", "", "meter_data.call_back", "", del_msg);
                    if (has_rights_setup_meter_iu) {
                        meter_data.tabbar.tabs(meter_data.tabbar.getActiveTab()).getAttachedToolbar().enableItem('save');
                    };

                } else {
                    result = adiha_post_data("alert", data, "", "", "meter_data.call_back");
                }
                delete_grid_name = "";
            }

            if (!form_status) {
                generate_error_message(first_err_tab);
            }
        }


        /**
         Close the tab and open again for new data insert.
         */

        meter_data.call_back = function (result) {
            if (has_rights_setup_meter_iu) {
                meter_data.tabbar.tabs(meter_data.tabbar.getActiveTab()).getAttachedToolbar().enableItem('save');
            };
            if (result[0].errorcode == "Success") {
                meter_data.clear_delete_xml();
                if (result[0].recommendation != null) {
                    var tab_id = meter_data.tabbar.getActiveTab();
                    var tab_text = new Array();
                    if (result[0].recommendation.indexOf(",") != -1) { tab_text = result[0].recommendation.split(",") } else { tab_text.push(0, result[0].recommendation); }
                    meter_data.tabbar.tabs(tab_id).setText(tab_text[1]);
                    meter_data.refresh_grid("", meter_data.open_tab);
                } else {
                    meter_data.refresh_grid();
                }
            }
        }


        /**
         if channel is not defined, then insert a default channel
         */
        function check_meter_channel(grid_obj, object_id) {
            if (grid_obj.getRowsNum() < 1) {
                var newId = (new Date()).valueOf();
                grid_obj.addRow(newId, "");
                grid_obj.forEachRow(function (row) {
                    grid_obj.cells(row, 1).setValue("");
                    grid_obj.cells(row, 2).setValue(1);
                    grid_obj.cells(row, 3).setValue(1);
                    grid_obj.cells(row, 4).setValue(1);
                    grid_obj.cells(row, 5).setValue(default_uom_id);
                });

            }
        }

        // Override the enable_menu_item method to support multiple deletion.
        meter_data.enable_menu_item = function(id, ind) {
            var selected_rows = meter_data.grid.getSelectedRowId();

            if(has_rights_delete == true && id != null) {
                meter_data.menu.setItemEnabled("delete");
            } else {
                meter_data.menu.setItemDisabled("delete");
            }

            if(id != null && id.indexOf(",") == -1) {
                var is_active = meter_data.grid.cells(id, meter_data.grid.getColIndexById("is_privilege_active")).getValue();
            } else {
                if (id.indexOf(",") != -1) {
                    var splitted_id = id.split(',');
                    var is_active = meter_data.grid.cells(splitted_id[0], meter_data.grid.getColIndexById("is_privilege_active")).getValue();
                } else {
                    var is_active = -1
                }
            }

            if (is_active == 0) {
                if (has_rights_manage_privilege){
                    meter_data.menu.setItemEnabled("activate");
                    meter_data.menu.setItemDisabled("deactivate");
                    meter_data.menu.setItemDisabled("privilege");
                }
            } else if (is_active == 1){
                if (has_rights_manage_privilege){
                    if (id.indexOf(",") != -1) {
                        meter_data.menu.setItemDisabled("activate");
                        meter_data.menu.setItemDisabled("deactivate");
                        meter_data.menu.setItemEnabled("privilege");
                    } else {
                        meter_data.menu.setItemDisabled("activate");
                        meter_data.menu.setItemEnabled("deactivate");
                        meter_data.menu.setItemEnabled("privilege");
                    }
                }
            } else {
                meter_data.menu.setItemDisabled("activate");
                meter_data.menu.setItemDisabled("deactivate");
                meter_data.menu.setItemDisabled("privilege");
            }
        }
    </script>
</html>