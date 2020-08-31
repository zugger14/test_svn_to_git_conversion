<?php

/**
 * Setup price curves screen
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
$form_namespace = 'source_price_curve_def';
$right_price_curve_IU = 10102610;
$right_price_curve_delete = 10102611;
$right_manage_privilege = 10102612;
$source_price_curve_def_id = get_sanitized_value($_GET['source_price_curve_def_id'] ?? '');
$call_from_combo = get_sanitized_value($_GET['call_from_combo'] ?? '');

list(
    $has_right_price_curve_IU,
    $has_rights_price_curve_delete,
    $has_right_manage_privilege
) = build_security_rights(
    $right_price_curve_IU,
    $right_price_curve_delete,
    $right_manage_privilege
);

$form_obj = new AdihaStandardForm($form_namespace, 10102600);
$form_obj->define_grid("setup_price_curve", "EXEC spa_source_price_curve_def_maintain @flag='t', @show_hyperlink= 'n'");
$form_obj->define_layout_width(400);
$form_obj->define_custom_functions('save_data', '', '', 'post_form_load');
$form_obj->add_privilege_menu($has_right_manage_privilege, '', 1);
$form_obj->enable_grid_pivot();
echo $form_obj->init_form('Price Curves', 'Setup Price Curve Detail', $source_price_curve_def_id);
echo $form_obj->close_form();
?>

<body>
    <script type="text/javascript">
        var has_rights_price_curve_delete = Boolean(<?php echo $has_rights_price_curve_delete ?? 0; ?>);
        var has_right_price_curve_IU = <?php echo (($has_right_price_curve_IU) ? $has_right_price_curve_IU : '0'); ?>;
        var hyper_link_id = '<?php echo $source_price_curve_def_id; ?>';
        var has_right_manage_privilege = Boolean(<?php echo $has_right_manage_privilege ?? 0; ?>);
        var call_from_combo = '<?php echo $call_from_combo; ?>';
        source_price_curve_def.field_values = {};

        $(function() {
            source_price_curve_def.grid.attachEvent('onRowSelect', function() {
                var row_id = source_price_curve_def.grid.getSelectedRowId();
                var is_parent_node = source_price_curve_def.grid.hasChildren(row_id);
                if (is_parent_node > 0) {
                    source_price_curve_def.menu.setItemDisabled("delete");
                }
            })

            load_workflow_status();
        });

        load_workflow_status = function() {
            source_price_curve_def.menu.addNewSibling('process', 'reports', 'Reports', false, 'report.gif', 'report_dis.gif');
            source_price_curve_def.menu.addNewChild('reports', '0', 'report_manager', 'Report Manager', true, 'report.gif', 'report_dis.gif');

            source_price_curve_def.grid.attachEvent("onRowSelect", function() {
                var row_id = source_price_curve_def.grid.getSelectedRowId();
                var is_parent_node = source_price_curve_def.grid.hasChildren(row_id);
                if (is_parent_node == 0) {
                    source_price_curve_def.menu.setItemEnabled('report_manager');
                }
            });

            load_report_menu('source_price_curve_def.menu', 'report_manager', 2, -104702)

            source_price_curve_def.menu.attachEvent("onClick", function(id, zoneId, cas) {
                if (id.indexOf("report_manager_") != -1 && id != 'report_manager') {
                    var str_len = id.length;
                    var report_param_id = id.substring(15, str_len);
                    var selected_curve_ids = source_price_curve_def.grid.getColumnValues(1);
                    var param_filter_xml = '<Root><FormXML param_name="source_id" param_value="' + selected_curve_ids + '"></FormXML></Root>';

                    show_view_report(report_param_id, param_filter_xml, -104702)
                }
            });

        }

        source_price_curve_def.post_form_load = function() {
            var tab_id = source_price_curve_def.tabbar.getActiveTab();
            var win = source_price_curve_def.tabbar.cells(tab_id);
            var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
            object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(" ", ""));
            var tab_obj = win.tabbar[object_id];
            var general_tab = tab_obj.tabs(get_tab_id(tab_obj, 1)).getAttachedObject();
            var general_tab_layout = general_tab.cells('a');
            var general_tab_layout_object = general_tab_layout.getAttachedObject();
            if (general_tab_layout_object instanceof dhtmlXForm) {
                var pre_granularity_id = general_tab_layout_object.getItemValue('granularity');
                general_tab_layout_object.attachEvent("onChange", change_combo_state);
            }

            change_combo_state();

            source_price_curve_def.field_values = source_price_curve_def.get_form_values();
        }

        function change_combo_state() {
            var tab_id = source_price_curve_def.tabbar.getActiveTab();
            var win = source_price_curve_def.tabbar.cells(tab_id);
            var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
            object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(" ", ""));
            var tab_obj = win.tabbar[object_id];
            var general_tab = tab_obj.tabs(get_tab_id(tab_obj, 1)).getAttachedObject();
            var general_tab_layout = general_tab.cells('a');
            var general_tab_layout_object = general_tab_layout.getAttachedObject();
            if (general_tab_layout_object instanceof dhtmlXForm) {
                var curve_val = general_tab_layout_object.getItemValue('source_curve_type_value_id')
                if (curve_val == 576) {
                    general_tab_layout_object.enableItem('source_currency_to_id');
                } else {
                    general_tab_layout_object.disableItem('source_currency_to_id');
                }
            }
        }

        source_price_curve_def.save_data = function(tab_id) {
            var win = source_price_curve_def.tabbar.cells(tab_id);
            var valid_status = 1;
            var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
            object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(" ", ""));
            var tab_obj = win.tabbar[object_id];
            var general_tab = tab_obj.tabs(get_tab_id(tab_obj, 1)).getAttachedObject();
            var general_tab_layout = general_tab.cells('a');
            var general_tab_layout_object = general_tab_layout.getAttachedObject();
            if (general_tab_layout_object instanceof dhtmlXForm) {
                var pre_granularity_id = general_tab_layout_object.getItemValue('granularity');
                var market_value_desc = general_tab_layout_object.getItemValue('market_value_desc');
                var market_value_id = general_tab_layout_object.getItemValue('market_value_id');
            }

            var additional_tab = tab_obj.tabs(get_tab_id(tab_obj, 2)).getAttachedObject();
            var additional_tab_layout = additional_tab.cells('a');
            var additional_tab_layout_object = additional_tab_layout.getAttachedObject();
            if (additional_tab_layout_object instanceof dhtmlXForm) {
                var curve_tou = additional_tab_layout_object.getItemValue('curve_tou');
            }

            var data = {
                "action": "spa_CurveReferenceHierarchy",
                "flag": "c",
                "curve_id": object_id,
                "market_value_desc": market_value_desc,
                "market_value_id": market_value_id,
                "pre_granularity_id": pre_granularity_id,
                "curve_tou": curve_tou
            }

            var callback_fn = '(function (result) {check_data_mapped("' + tab_id + '", result); })';
            adiha_post_data('return_array', data, '', '', callback_fn);
        }

        function check_data_mapped(tab_id, result) {
            if (result[0][0] == 'false') {
                show_messagebox(result[0][1]);
            } else {
                var win = source_price_curve_def.tabbar.cells(tab_id);
                var valid_status = 1;
                var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
                object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(" ", ""));
                var tab_obj = win.tabbar[object_id];
                var detail_tabs = tab_obj.getAllTabs();
                var grid_xml = "<GridGroup>";
                var form_xml = "<FormXML ";
                var tabsCount = tab_obj.getNumberOfTabs();
                var form_status = true;
                var first_err_tab;
                var rtc_grid_obj;
                $.each(detail_tabs, function(index, value) {
                    layout_obj = tab_obj.cells(value).getAttachedObject();
                    layout_obj.forEachItem(function(cell) {
                        attached_obj = cell.getAttachedObject();

                        if (attached_obj instanceof dhtmlXGridObject) {
                            attached_obj.clearSelection();
                            var ids = attached_obj.getChangedRows(true);
                            grid_id = attached_obj.getUserData("", "grid_id");
                            grid_label = attached_obj.getUserData("", "grid_label");
                            deleted_xml = attached_obj.getUserData("", "deleted_xml");

                            if (grid_id == 'rtc_source_price_curve') {
                                rtc_grid_obj = attached_obj;
                            }

                            if (deleted_xml != null && deleted_xml != "") {
                                grid_xml += "<GridDelete grid_id=\"" + grid_id + "\" grid_label=\"" + grid_label + "\">";
                                grid_xml += deleted_xml;
                                grid_xml += "</GridDelete>";
                                if (delete_grid_name == "") {
                                    delete_grid_name = grid_label
                                } else {
                                    delete_grid_name += "," + grid_label
                                };
                            };

                            if (ids != "") {
                                attached_obj.setSerializationLevel(false, false, true, true, true, true);
                                if (valid_status != 0) {
                                    var grid_status = source_price_curve_def.validate_form_grid(attached_obj, grid_label);
                                }

                                grid_xml += "<Grid grid_id=\"" + grid_id + "\">";
                                var changed_ids = new Array();
                                changed_ids = ids.split(",");
                                if (grid_status) {
                                    $.each(changed_ids, function(index, value) {
                                        attached_obj.setUserData(value, "row_status", "new row");
                                        grid_xml += "<GridRow ";
                                        for (var cellIndex = 0; cellIndex < attached_obj.getColumnsNum(); cellIndex++) {
                                            if (attached_obj.cells(value, cellIndex).getValue() == 'undefined') { //Cannot use typeof because it returns string

                                                grid_xml += " " + attached_obj.getColumnId(cellIndex) + '= "NULL"';
                                                continue;
                                            }

                                            if (attached_obj.getColumnId(cellIndex) == 'from_no_of_months') {
                                                var from_month = attached_obj.cells(value, cellIndex).getValue();
                                                var from_month_value = parseInt(from_month);
                                            }

                                            if (attached_obj.getColumnId(cellIndex) == 'to_no_of_months') {
                                                var to_month = attached_obj.cells(value, cellIndex).getValue();
                                                var to_month_value = parseInt(to_month);
                                            }

                                            if (from_month_value > to_month_value) {
                                                dhtmlx.message({
                                                    type: "alert-error",
                                                    title: "Error",
                                                    text: '<b>Month To</b> should be greater than <b>Month From</b> in <b>Fair Value Reporting</b> grid.'
                                                });
                                                return;
                                            }
                                            grid_xml += " " + attached_obj.getColumnId(cellIndex) + '="' + attached_obj.cells(value, cellIndex).getValue() + '"';
                                        }
                                        grid_xml += " ></GridRow> ";
                                    });
                                    grid_xml += "</Grid>";
                                } else {
                                    tab_obj.cells(value).setActive();
                                    valid_status = 0;
                                };
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
                                        if (field_label == 'curve_des' || field_label == 'curve_id') {
                                            if (data[a] == '') {
                                                field_value = data['curve_name'];
                                            }
                                        }
                                    }
                                    form_xml += " " + field_label + "=\"" + field_value + "\"";
                                }
                            } else {
                                valid_status = 0;
                                /*tab_obj.cells(value).setActive();
                                generate_error_message();*/
                            }
                        }
                    });
                });
                form_xml += "></FormXML>";
                grid_xml += "</GridGroup>";
                var xml = "<Root function_id=\"10102600\" object_id=\"" + object_id + "\">";
                xml += form_xml;
                xml += grid_xml;
                xml += "</Root>";
                xml = xml.replace(/'/g, "\"");

                var rtc_grid_all_curve_ids = [];

                rtc_grid_obj.forEachRow(function(row_id) {
                    var row_data = rtc_grid_obj.getRowData(row_id);
                    var rtc_curve = row_data.rtc_curve;
                    rtc_grid_all_curve_ids.push(rtc_curve);
                });

                if (valid_status == 1) {
                    win.getAttachedToolbar().disableItem('save');
                    data = {
                        "action": "spa_process_form_data",
                        "xml": xml
                    }
                    rtc_grid_all_curve_ids = rtc_grid_all_curve_ids.toString();
                    var check_data = {
                        'action': 'spa_rtc_price_curve',
                        'flag': 'c',
                        'curve_ids': rtc_grid_all_curve_ids
                    }

                    adiha_post_data('return_json', check_data, '', '', function(return_json) {
                        return_json = JSON.parse(return_json);
                        if (return_json[0].is_valid == 1) {
                            if (delete_grid_name != "") {
                                del_msg = "Some data has been deleted from " + delete_grid_name + " grid. Are you sure you want to save?";
                                result = adiha_post_data("confirm-warning", data, "", "", "source_price_curve_def.post_callback", "", del_msg);
                                if (has_right_price_curve_IU) {
                                    win.getAttachedToolbar().enableItem('save');
                                }
                            } else {
                                result = adiha_post_data("alert", data, "", "", "source_price_curve_def.post_callback");
                            }
                            delete_grid_name = "";
                            deleted_xml = attached_obj.setUserData("", "deleted_xml", "");
                        } else {
                            var final_sum = return_json[0].final_sum;
                            var final_msg = 'The Hours mapped in <b>RTC Price Curve</b> does not match <b>RTC Hours (7 X 24).</b>';
                            show_messagebox(final_msg);
                            win.getAttachedToolbar().enableItem('save');
                            return false;
                        }
                    });
                }

                if (!form_status) {
                    generate_error_message(first_err_tab);
                    win.getAttachedToolbar().enableItem('save');
                }
            }
        }

        source_price_curve_def.post_callback = function(result) {
            var active_tab = source_price_curve_def.tabbar.getActiveTab();
            var toolbar = source_price_curve_def.tabbar.cells(active_tab).getAttachedToolbar();
            if (has_right_price_curve_IU) {
                toolbar.enableItem('save');
            }

            if (result[0].errorcode == "Success") {
                source_price_curve_def.clear_delete_xml();

                if (result[0].recommendation != null) {
                    var tab_id = source_price_curve_def.tabbar.getActiveTab();
                    var tab_text = new Array();
                    if (result[0].recommendation.indexOf(",") != -1) {
                        tab_text = result[0].recommendation.split(",")
                    } else {
                        tab_text.push(0, result[0].recommendation);
                    }
                    if (call_from_combo == 'combo_add') {
                        parent.combo_data_add_win.callEvent("onWindowSaveCloseEvent", ["onSave", tab_text[1]]);
                        return;
                    }
                    source_price_curve_def.tabbar.tabs(tab_id).setText(tab_text[1]);
                    source_price_curve_def.refresh_grid("", source_price_curve_def.open_tab);
                } else {
                    toolbar.enableItem('save');
                    source_price_curve_def.refresh_grid();
                }
                source_price_curve_def.menu.setItemDisabled("delete");
                var new_field_values = source_price_curve_def.get_form_values();
                var is_updated = source_price_curve_def.are_form_values_changed(source_price_curve_def.field_values, new_field_values);
                if (is_updated && new_field_values.source_curve_def_id !== "") {
                    var data = {
                        'action': 'spa_source_price_curve_def_maintain',
                        'flag': 'post_insert',
                        'source_curve_def_id': new_field_values.source_curve_def_id
                    }
                    adiha_post_data("return_json", data, "", "", function(){

                    });
                }
            } else {
                toolbar.enableItem('save');
            }
        }

        // Override the enable_menu_item method to support multiple deletion.
        source_price_curve_def.enable_menu_item = function(id, ind) {
            var selected_rows = source_price_curve_def.grid.getSelectedRowId();

            if (has_rights_price_curve_delete == true && id != null) {
                source_price_curve_def.menu.setItemEnabled("delete");
            } else {
                source_price_curve_def.menu.setItemDisabled("delete");
            }

            if (id != null && id.indexOf(",") == -1) {
                var c_row = null;
                var col_type = source_price_curve_def.grid.getColType(0);
                if (col_type == "tree") {
                    var c_row = source_price_curve_def.grid.getChildItemIdByIndex(id, 0);
                }
                if (col_type == "tree" && c_row != null) {
                    var is_active = -1;
                } else {
                    var is_active = source_price_curve_def.grid.cells(id, source_price_curve_def.grid.getColIndexById("is_privilege_active")).getValue();
                }
            } else {
                if (id.indexOf(",") != -1) {
                    var splitted_id = id.split(',');
                    var is_active = source_price_curve_def.grid.cells(splitted_id[0], source_price_curve_def.grid.getColIndexById("is_privilege_active")).getValue();
                } else {
                    var is_active = -1
                }
            }

            if (is_active == 0) {
                if (has_right_manage_privilege) {
                    source_price_curve_def.menu.setItemEnabled("activate");
                    source_price_curve_def.menu.setItemDisabled("deactivate");
                    source_price_curve_def.menu.setItemDisabled("privilege");
                }
            } else if (is_active == 1) {
                if (has_right_manage_privilege) {
                    if (id.indexOf(",") != -1) {
                        source_price_curve_def.menu.setItemDisabled("activate");
                        source_price_curve_def.menu.setItemDisabled("deactivate");
                        source_price_curve_def.menu.setItemEnabled("privilege");
                    } else {
                        source_price_curve_def.menu.setItemDisabled("activate");
                        source_price_curve_def.menu.setItemEnabled("deactivate");
                        source_price_curve_def.menu.setItemEnabled("privilege");
                    }
                }
            } else {
                source_price_curve_def.menu.setItemDisabled("activate");
                source_price_curve_def.menu.setItemDisabled("deactivate");
                source_price_curve_def.menu.setItemDisabled("privilege");
            }
        }

        source_price_curve_def.get_form_values = function() {
            tab_id = source_price_curve_def.tabbar.getActiveTab()
            var win = source_price_curve_def.tabbar.cells(tab_id);
            var tab_obj = win.getAttachedObject();
            var form_obj;
            var field_names = ['source_curve_def_id', 'commodity_id', 'uom_id', 'block_define_id', 'display_uom_id', 'proxy_curve_id', 'hourly_volume_allocation', 'exp_calendar_id', 'time_zone', 'curve_id'];
            var field_values = {};
            tab_obj.forEachTab(function(tab) {
                layout_obj = tab.getAttachedObject();
                layout_obj.forEachItem(function(cell) {
                    attached_obj = cell.getAttachedObject();
                    if (attached_obj instanceof dhtmlXForm) {
                        form_obj = attached_obj;

                        field_names.forEach(function(field_name) {
                            if (form_obj.isItem(field_name)) {
                                var field_value = form_obj.getItemValue(field_name);
                                field_values[field_name] = field_value
                            }
                        })
                    }
                });
            });
            return field_values;
        }

        source_price_curve_def.are_form_values_changed = function(old_value, new_value) {
            for (const key in old_value) {
                if (new_value.hasOwnProperty(key) && old_value[key] !== new_value[key]) {
                    return true
                }
            }
            return false
        }
    </script>

</body>

</html>