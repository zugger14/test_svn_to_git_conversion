<?php
/**
* Compliance jurisdiction screen
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
$jurisdiction_id = get_sanitized_value($_GET['jurisdiction_id'] ?? '');
$application_function_id = 14100100;

$rights_compliance_jurisdiction_iu = 14100101;
$rights_compliance_jurisdiction_delete = 14100102;

list(
    $has_rights_compliance_jurisdiction_iu,
    $has_rights_compliance_jurisdiction_delete
) = build_security_rights(
    $rights_compliance_jurisdiction_iu,
    $rights_compliance_jurisdiction_delete
);

$form_namespace = 'compliance_jurisdiction';
$form_obj = new AdihaStandardForm($form_namespace, $application_function_id);

$form_obj->define_grid('compliance_jurisdiction', '', 'g');
$form_obj->define_layout_width(355);
$form_obj->define_custom_functions('save_jurisdiction', '', 'delete_jurisdicition', 'form_load_complete');
echo $form_obj->init_form('Jurisdiction/Market', 'Compliance Jurisdiction Details', $jurisdiction_id);
echo $form_obj->close_form();

?>

<body>
</body>
<script type="text/javascript">
    var has_rights_compliance_jurisdiction_iu = Boolean('<?php echo $has_rights_compliance_jurisdiction_iu; ?>');
    var has_rights_compliance_jurisdiction_delete = Boolean('<?php echo $has_rights_compliance_jurisdiction_delete ?>')


    /**
     * [Function to save Jurisdiction]
     */
    compliance_jurisdiction.save_jurisdiction = function(tab_id) {
                            var win = compliance_jurisdiction.tabbar.cells(tab_id);
        var valid_status = 1;
                            var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        var flag = (tab_id.indexOf("tab_") != -1) ? 'u' : 'i';
                            var tab_obj = win.tabbar[object_id];
        var detail_tabs = tab_obj.getAllTabs();
        var grid_xml = "<Root><GridGroup>";
        var form_xml = "<Root><FormXML ";
        var del_xml = "<Root>"
        var form_status = true;
        var tier_grid_obj;
        var requirement_grid_obj;

        $.each(detail_tabs, function(index, value) {
                    layout_obj = tab_obj.cells(value).getAttachedObject();
            layout_obj.forEachItem(function(cell) {
                        attached_obj = cell.getAttachedObject();

                        if (attached_obj instanceof dhtmlXForm) {
                    var status = validate_form(attached_obj);

                    if (status) {
                        data = attached_obj.getFormData();

                        for (var a in data) {
                            field_label = a;
                            field_value = data[a];

                            if (attached_obj.getItemType(field_label) == 'calendar') {
                                var field_value = attached_obj.getItemValue(field_label, true);
                        }

                            if (field_label == 'description') {

                                if (data[a] == '') {
                                    field_value = data['code'];
                }
            }
                            form_xml += " " + field_label + "=\"" + field_value + "\"";
        }
                    } else {
                        generate_error_message();
                        tab_obj.cells(value).setActive();
                        valid_status = 0;
    }
                } else if (attached_obj instanceof dhtmlXGridObject) {
                    attached_obj.clearSelection();
                    grid_label = attached_obj.getUserData("", "grid_label");
                    var ids = attached_obj.getChangedRows(true);
                    grid_id = attached_obj.getUserData("", "grid_id");
                    deleted_xml = attached_obj.getUserData("", "deleted_xml");

                    if (grid_label == 'Tier Mapping ') {
                        tier_grid_obj = attached_obj;
                    } else if (grid_label == 'Requirement') {
                        requirement_grid_obj = attached_obj;
                    }

                    if (deleted_xml != null && deleted_xml != "") {
                        del_xml += "<GridDelete grid_id=\"" + grid_id + "\" grid_label=\"" + grid_label + "\">";
                        del_xml += deleted_xml;
                        del_xml += "</GridDelete>";

                        if (delete_grid_name == "") {
                            delete_grid_name = grid_label
                        } else {
                            delete_grid_name += "," + grid_label
                        }
                    }

                    if (ids != "") {
                        attached_obj.setSerializationLevel(false, false, true, true, true, true);
                        var grid_status = compliance_jurisdiction.validate_form_grid(attached_obj, grid_label);


                        grid_xml += "<Grid grid_id=\"" + grid_id + "\">";
                        var changed_ids = new Array();
                        changed_ids = ids.split(",");

                        if (grid_status) {
                            $.each(changed_ids, function(index, value) {
                                grid_xml += "<GridRow ";
                                for (var cellIndex = 0; cellIndex < attached_obj.getColumnsNum(); cellIndex++) {
                                    grid_xml += " " + attached_obj.getColumnId(cellIndex) + '="' + attached_obj.cells(value, cellIndex).getValue() + '"';
                                    }
                                grid_xml += " ></GridRow> ";
                            });
                            grid_xml += "</Grid>";
                        } else {
                            tab_obj.cells(value).setActive();
                            valid_status = 0;
                        }
                    }
                    }
                                    });
        });
        form_xml += ' type_id = "10002"></FormXML></Root>';
        grid_xml += "</GridGroup></Root>";
        del_xml += "</Root>";

        if (valid_status == 1) {
            compliance_jurisdiction.tabbar.cells(tab_id).getAttachedToolbar().disableItem("save");
            data = {
                "action": "spa_ComplianceJurisdiction",
                "flag": flag,
                "form_xml": form_xml,
                "grid_xml": grid_xml,
                "del_xml": del_xml
                                }

            if (flag == 'u' && delete_grid_name != "") {
                dhtmlx.message({
                    type: "confirm",
                    title: "Confirmation",
                    ok: "Confirm",
                    text: "Some data has been deleted from <b>" + delete_grid_name + " grid</b>.Are you sure you want to delete?",
                    callback: function(result) {
                        if (result) {
                            result = adiha_post_data("alert", data, "", "", "compliance_jurisdiction.post_callback", false);
                if (has_rights_compliance_jurisdiction_iu) {
                    var tab_id = compliance_jurisdiction.tabbar.getActiveTab();
                    compliance_jurisdiction.tabbar.cells(tab_id).getAttachedToolbar().enableItem("save");
                                delete_grid_name = "";
                                tier_grid_obj.setUserData("", "deleted_xml", "");
                                requirement_grid_obj.setUserData("", "deleted_xml", "");
                        }
                    } else {
                            var grid_names = delete_grid_name.split(/[,\s]+/)
                            refresh_cell_grid(grid_names);
                            var tab_id = compliance_jurisdiction.tabbar.getActiveTab();
                            compliance_jurisdiction.tabbar.cells(tab_id).getAttachedToolbar().enableItem("save");
                            delete_grid_name = "";
                            tier_grid_obj.setUserData("", "deleted_xml", "");
                            requirement_grid_obj.setUserData("", "deleted_xml", "");
                            return;
                        }
                    }
                });
            } else {
                result = adiha_post_data("alert", data, "", "", "compliance_jurisdiction.post_callback");
                        }
            }
        }

    compliance_jurisdiction.post_callback = function(result) {
        var tab_id = compliance_jurisdiction.tabbar.getActiveTab();
        compliance_jurisdiction.tabbar.cells(tab_id).getAttachedToolbar().enableItem('save');
        if (result[0].errorcode == "Success") {
            compliance_jurisdiction.clear_delete_xml();
            var col_type = compliance_jurisdiction.grid.getColType(0);
            if (col_type == "tree") {
                compliance_jurisdiction.grid.saveOpenStates();
            }
            if (result[0].recommendation != null) {
                var tab_id = compliance_jurisdiction.tabbar.getActiveTab();
                var previous_text = compliance_jurisdiction.tabbar.tabs(tab_id).getText();
                if (previous_text == get_locale_value("New")) {
                    var tab_text = new Array();
                    if (result[0].recommendation.indexOf(",") != -1) {
                        tab_text = result[0].recommendation.split(",")
                    } else {
                        tab_text.push(0, result[0].recommendation);
                    }
                    compliance_jurisdiction.tabbar.tabs(tab_id).setText(tab_text[1]);
                    compliance_jurisdiction.refresh_grid("", compliance_jurisdiction.open_tab);
                } else {
                    compliance_jurisdiction.refresh_grid("", compliance_jurisdiction.refresh_tab_properties);
                }
            }
            compliance_jurisdiction.menu.setItemDisabled("delete");
        } else if (result[0].errorcode == "Error") {
            var grid_names = delete_grid_name.split(/[,\s]+/);
            refresh_cell_grid(grid_names);
        }
    }
    /**
     * [Function to delete Locations]
     */
    compliance_jurisdiction.delete_jurisdicition = function() {
        var selected_row = compliance_jurisdiction.grid.getSelectedRowId();
        var value_id_index = compliance_jurisdiction.grid.getColIndexById('value_id');
        selected_row = selected_row.split(',');
        var value_ids = [];
        selected_row.forEach(function(rid) {
            var value_id = compliance_jurisdiction.grid.cells(rid, value_id_index).getValue();
            value_ids.push(value_id);
        });
        value_ids = value_ids.toString();
        var sql = {
            "action": "spa_ComplianceJurisdiction",
            "flag": "d",
            "value_id": value_ids
        }

        if (value_ids != '') {
            dhtmlx.message({
                type: "confirm",
                title: "Confirmation",
                text: "Are you sure you want to delete?",
                callback: function(result) {
                    if (result) {
                        grid_del = true;
                        result = adiha_post_data("return_array", sql, "", "", "compliance_jurisdiction.post_delete_callback");
                    }
                }
            });
        }

    }

    compliance_jurisdiction.form_load_complete = function() {
        var tab_id = compliance_jurisdiction.tabbar.getActiveTab();
        var win = compliance_jurisdiction.tabbar.cells(tab_id);
        var flag = (tab_id.indexOf("tab_") != -1) ? 'u' : 'i';
        var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(" ", ""));
        var tab_obj = win.tabbar[object_id];
        var detail_tabs = tab_obj.getAllTabs();
        var requirement_tab;
        var form_obj;
        if (flag == 'i') {
            tab_obj.forEachTab(function(tab) {
                if (tab.getText() != "General") {
                    tab.disable();
                }
            });
        }
        $.each(detail_tabs, function(index, value) {
            tab_text = tab_obj.cells(value).getText();
            layout_obj = tab_obj.cells(value).getAttachedObject();
            if (tab_text == 'General') {
            var myMenu = layout_obj.cells('b').getAttachedMenu();

            if (flag == 'i') {
                myMenu.setItemDisabled('add');
            }
                layout_obj.forEachItem(function(cell) {
                    attached_obj = cell.getAttachedObject();
                    if (attached_obj instanceof dhtmlXForm) {
                        form_obj = attached_obj;
                    }
            });
            } else if (tab_text == 'Requirement') {
                requirement_tab = tab_obj.cells(value);
                var myMenu = layout_obj.cells('a').getAttachedMenu();

                if (flag == 'i') {
                    myMenu.setItemDisabled('add');
                            }
                myMenu.attachEvent("OnClick", function(id, zoneId, cas) {

                    if (id == 'add') {
                        layout_obj.forEachItem(function(cell) {
                            attached_obj = cell.getAttachedObject();

                            if (attached_obj instanceof dhtmlXGridObject) {
                                var row_no = attached_obj.getRowsNum();
                                var row_id = attached_obj.getRowId(row_no - 1);
                                attached_obj.deleteRow(row_id);
                            }
                        });
                        param = 'compliance.jurisdiction.requirement.php?flag=i&state_value_id=' + object_id;
                        dhxWins = new dhtmlXWindows();
                        var is_win = dhxWins.isWindow('w1');

                        if (is_win == true) {
                            w1.close();
                        }
                        w1 = dhxWins.createWindow("w1", 0, 0, 900, 600);
                        w1.setText("Requirement Data");
                        w1.maximize();
                        w1.setModal(true);
                        w1.attachURL(param, false, true);
                    }
                });
                var requirement_tab_grid = layout_obj.cells('a').getAttachedObject();
                if (requirement_tab_grid instanceof dhtmlXGridObject) {
                    requirement_tab_grid.attachEvent("onRowDblClicked", function(rId, cInd) {
                        var grid_row_value = get_grid_rows(requirement_tab_grid, rId);
                        param = 'compliance.jurisdiction.requirement.php?flag=u&state_value_id=' + object_id + '&state_rec_requirement_data_id=' + grid_row_value['state_rec_requirement_data_id'];
                        dhxWins = new dhtmlXWindows();
                        var is_win = dhxWins.isWindow('w1');

                        if (is_win == true) {
                            w1.close();
                        }
                        w1 = dhxWins.createWindow("w1", 0, 0, 900, 600);
                        w1.setText("Requirement Data");
                        w1.setModal(true);
                        w1.maximize();
                        w1.attachURL(param, false, true);
                    });
                }
            }
        });

        function detail_changed() {
            var detail_value = form_obj.isItemChecked('detail');

            if (detail_value) {
                requirement_tab.show();
            } else {
                requirement_tab.hide();
            }
        }

        detail_changed();

        form_obj.attachEvent('onChange', function(id) {
            if (id == 'detail') {
                detail_changed();
            }
        });
    }

    function get_grid_rows(gridObject, ind) {
        var row_values = new Object();
        var col_num = gridObject.getColumnsNum();
        if (ind !== '') {
            for (var i = 0; i < col_num; i++) {
                var col_id = gridObject.getColumnId(i);
                var col_value = gridObject.cells(ind, i).getValue();
                row_values[col_id] = col_value;
            }
        }

        return row_values;
    }

    function load_grid(state_value_id) { // called from a child page to clear and load the value of requirement grid.
        var tab_id = compliance_jurisdiction.tabbar.getActiveTab();
        var win = compliance_jurisdiction.tabbar.cells(tab_id);
        var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(" ", ""));
        var tab_obj = win.tabbar[object_id];
        var detail_tabs = tab_obj.getAllTabs();

        $.each(detail_tabs, function(index, value) {
            tab_text = tab_obj.cells(value).getText();
            layout_obj = tab_obj.cells(value).getAttachedObject();

            if (tab_text == 'Requirement') {
                var requirement_tab_grid = layout_obj.cells('a').getAttachedObject();

                var sql = {
                    "action": "spa_state_rec_requirement_data",
                    "flag": "s",
                    "state_value_id": state_value_id
                }
                var data = $.param(sql);
                var data_url = js_data_collector_url + "&" + data;
                requirement_tab_grid.clearAndLoad(data_url);
            }
        });

    }

    function refresh_cell_grid(grid_names) {
        var tab_id = compliance_jurisdiction.tabbar.getActiveTab();
        var win = compliance_jurisdiction.tabbar.cells(tab_id);
        var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(" ", ""));
        var tab_obj = win.tabbar[object_id];
        var detail_tabs = tab_obj.getAllTabs();
        var state_value_id;
        var form_obj;
        var tier_grid_obj;
        var requirement_grid_obj;
        $.each(detail_tabs, function(index, value) {
            tab_text = tab_obj.cells(value).getText();
            layout_obj = tab_obj.cells(value).getAttachedObject();
            layout_obj.forEachItem(function(cell) {
                attached_obj = cell.getAttachedObject();
                if (attached_obj instanceof dhtmlXForm) {
                    state_value_id = attached_obj.getItemValue('state_value_id');
                } else if (attached_obj instanceof dhtmlXGridObject) {
                    if (tab_text == 'General') {
                        tier_grid_obj = attached_obj;
                    } else {
                        requirement_grid_obj = attached_obj
                    }
                }
            });
        });
        grid_names.forEach(function(grid_name) {
            if (grid_name == 'Tier') {
                var sql = {
                    "action": "spa_save_custom_form_data",
                    "flag": "l",
                    "state_value_id": state_value_id
                }
                var data = $.param(sql);
                var data_url = js_data_collector_url + "&" + data;
                tier_grid_obj.clearAndLoad(data_url);
            }
            if (grid_name == 'Requirement') {
                var sql = {
                    "action": "spa_state_rec_requirement_data",
                    "flag": "s",
                    "state_value_id": state_value_id
                }
                var data = $.param(sql);
                var data_url = js_data_collector_url + "&" + data;
                requirement_grid_obj.clearAndLoad(data_url);
            }
        });
    }
</script>