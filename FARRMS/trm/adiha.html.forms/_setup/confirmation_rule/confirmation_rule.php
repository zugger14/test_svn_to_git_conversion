<?php

/**
 * Confirmation_rule screen
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
$application_function_id = 10101161;

$form_namespace = "confirm_rule";
$form_obj = new AdihaStandardForm($form_namespace, $application_function_id);
$form_sql = "EXEC spa_adiha_grid 's', 'DealConfirmationRule'";
$form_data = readXMLURL2($form_sql);

$grid_definition_json = json_encode($form_data);

$form_obj->define_grid("setup_confirm_rule");
$form_obj->define_custom_functions('save_confirm_rule', 'load_confirm_rule', 'delete_confirm_rule');
echo $form_obj->init_form("Confirm Rule", "Setup Confirm Rule");
echo $form_obj->close_form();
?>
<script type="text/javascript">
    var grid_definition_json = <?php echo $grid_definition_json; ?>;
    confirm_rule.grid_dropdowns = {};
    confirm_rule.grid_menu = {};
    var php_script_loc_ajax = "<?php echo $app_php_script_loc; ?>";

    $(function() {
        confirm_rule.menu.removeItem('t1');
        confirm_rule.grid.enableMultiselect(false);
    });
    //save grid data
    confirm_rule.save_confirm_rule = function(tab_id) {

        var active_tab_id = confirm_rule.tabbar.getActiveTab();
        var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;

        var layout = confirm_rule.layout["inner_tab_layout_" + object_id];
        layout.cells('a').progressOn();

        var grid_obj = confirm_rule["contract_component_grid_" + object_id];

        var grid_status = confirm_rule.validate_form_grid(grid_obj, 'Deal Confirmation Details');


        var ids = grid_obj.getChangedRows();
        var changed_ids = ids.split(',');
        var xml_grid = '<gridXml>';

        for (var i = 0; i < changed_ids.length; i++) {
            if (changed_ids.length > 0 && changed_ids != '') xml_grid = xml_grid + '<GridRow counterparty_id="' + object_id + '" ';

            grid_obj.forEachCell(changed_ids[i], function(cellObj, ind) {
                var grid_index = grid_obj.getColumnId(ind);
                var value = cellObj.getValue(ind);
                xml_grid = xml_grid + grid_index + '="' + value + '" ';
            });
            if (changed_ids.length > 0 && changed_ids != '') xml_grid = xml_grid + '></GridRow>';
        }
        xml_grid = xml_grid + '</gridXml>';

        //ns_match.deal_layout.cells('b').progressOn();

        var data = {
            'action': 'spa_deal_confirmation_rule',
            'flag': 'c',
            'xml_value': xml_grid
        };
        adiha_post_data('return_array', data, '', '', 'confirm_rule.save_confirm_rule_call_back');
    }

    //grid refresh after save
    confirm_rule.save_confirm_rule_call_back = function(return_value) {
        var active_tab_id = confirm_rule.tabbar.getActiveTab();
        var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        var layout = confirm_rule.layout["inner_tab_layout_" + object_id];
        layout.cells('a').progressOff();
        var grid_obj = confirm_rule["contract_component_grid_" + object_id];
        var sql_stmt = grid_definition_json[0]["sql_stmt"];
        var grid_type = grid_definition_json[0]["grid_type"];

        if (return_value[0][0] == 'Error') {
            success_call(return_value[0][4], 'error');
            return;
        } else {
            success_call(return_value[0][4]);
        }

        confirm_rule.refresh_grid(sql_stmt, grid_obj, grid_type, object_id);
    }

    //load right grid
    confirm_rule.load_confirm_rule = function(win, tab_id, grid_obj) {
        win.progressOn();
        var is_new = win.getText();
        var confirm_rule_data_tab_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        confirm_rule_data_tab_id = ($.isNumeric(confirm_rule_data_tab_id)) ? confirm_rule_data_tab_id : ord(confirm_rule_data_tab_id.replace(" ", ""));

        var header_allignment;
        var counter = 0;
        $.each(grid_definition_json[0]["column_alignment"].split(','), function(index, value) {
            if (counter == 0)
                header_allignment = 'text-align:' + value;
            else
                header_allignment += ',text-align:' + value;
            counter++
        });

        //attach layout                      
        confirm_rule.layout["inner_tab_layout_" + confirm_rule_data_tab_id] = win.attachLayout({
            pattern: "1C",
            cells: [{
                id: "a",
                text: "Deal Confirmation Details"
            }]
        });

        var menu_index = "grid_menu_" + confirm_rule_data_tab_id + "_" + tab_id;

        // attach menubar for each tab/grid
        confirm_rule.grid_menu[menu_index] = confirm_rule.layout["inner_tab_layout_" + confirm_rule_data_tab_id].cells('a').attachMenu({
            icons_path: js_image_path + "dhxmenu_web/",
            items: [{
                    id: "refresh",
                    text: "Refresh",
                    img: "refresh.gif",
                    img_disabled: "refresh_dis.gif"
                },
                {
                    id: "edit",
                    text: "Edit",
                    img: "edit.gif",
                    img_disabled: "edit_dis.gif",
                    items: [{
                            id: "add",
                            text: "Add",
                            img: "add.gif",
                            img_disabled: "add_dis.gif"
                        },
                        {
                            id: "delete",
                            text: "Delete",
                            disabled: true,
                            img: "delete.gif",
                            img_disabled: "delete_dis.gif"
                        }
                    ]
                },
                {
                    id: "t2",
                    text: "Export",
                    img: "export.gif",
                    items: [{
                            id: "excel",
                            text: "Excel",
                            img: "excel.gif",
                            imgdis: "excel_dis.gif",
                            title: "Excel"
                        },
                        {
                            id: "pdf",
                            text: "PDF",
                            img: "pdf.gif",
                            imgdis: "pdf_dis.gif",
                            title: "PDF"
                        }
                    ]
                }
            ]
        });

        if (is_new == 'New') {
            confirm_rule.grid_menu[menu_index].setItemDisabled("edit");
            confirm_rule.grid_menu[menu_index].setItemDisabled("refresh");
        }
        var grid_name = grid_definition_json[0]["grid_name"];
        var grid_cookies = "grid_" + grid_name;
        //attach grid
        confirm_rule["contract_component_grid_" + confirm_rule_data_tab_id] = confirm_rule.layout["inner_tab_layout_" + confirm_rule_data_tab_id].cells('a').attachGrid();

        var grid_obj = confirm_rule["contract_component_grid_" + confirm_rule_data_tab_id];
        grid_obj.setImagePath(js_image_path + "dhxgrid_web/");
        grid_obj.setHeader(grid_definition_json[0]["column_label_list"], null, header_allignment.split(","));
        grid_obj.setColumnIds(grid_definition_json[0]["column_name_list"]);
        grid_obj.setInitWidths(grid_definition_json[0]["column_width"]);
        grid_obj.setColTypes(grid_definition_json[0]["column_type_list"]);
        grid_obj.setColAlign(grid_definition_json[0]["column_alignment"]);
        grid_obj.setColumnsVisibility(grid_definition_json[0]["set_visibility"]);
        grid_obj.setColSorting(grid_definition_json[0]["sorting_preference"]);
        grid_obj.setDateFormat(user_date_format, '%Y-%m-%d');
        grid_obj.splitAt(grid_definition_json[0]["split_at"]);
        grid_obj.enableMultiselect(true);
        grid_obj.enableColumnMove(true);
        grid_obj.setUserData("", "grid_id", grid_name);

        //confirm_rule["contract_component_grid_" + confirm_rule_data_tab_id].setColValidators(grid_definition_json[0]["validation_rule"]);
        //        confirm_rule["contract_component_grid_" + confirm_rule_data_tab_id].enableValidation(true);
        //        
        //        confirm_rule["contract_component_grid_" + confirm_rule_data_tab_id].attachEvent("onValidationError",function(id,ind,value){
        //            alert('asd')
        //            var message = "Invalid Data";
        //            confirm_rule["contract_component_grid_" + confirm_rule_data_tab_id].cells(id,ind).setAttribute("validation", message);
        //            return true;
        //        });
        //        
        //        confirm_rule["contract_component_grid_" + confirm_rule_data_tab_id].attachEvent("onValidationCorrect",function(id,ind,value){
        //            alert('sad')
        //            confirm_rule["contract_component_grid_" + confirm_rule_data_tab_id].cells(id,ind).setAttribute("validation", "");
        //            return true;
        //        });

        var filter = '#numeric_filter,';
        var counter = 0;
        $.each(grid_definition_json[0]["column_type_list"].split(','), function(index, value) {
            filter += (counter == 0) ? '' : ',';
            filter += '#text_filter';
            counter++;
        });

        grid_obj.attachHeader(filter);
        grid_obj.init();
        grid_obj.loadOrderFromCookie(grid_cookies);
        grid_obj.loadHiddenColumnsFromCookie(grid_cookies);
        grid_obj.enableOrderSaving(grid_cookies);
        grid_obj.enableAutoHiddenColumnsSaving(grid_cookies);
        grid_obj.enableHeaderMenu();

        var sql_stmt = grid_definition_json[0]["sql_stmt"];
        var grid_type = grid_definition_json[0]["grid_type"];

        // populate the dropdowns fields in grids.
        if (grid_definition_json[0]["dropdown_columns"] != null && grid_definition_json[0]["dropdown_columns"] != '') {
            var dropdown_columns = grid_definition_json[0]["dropdown_columns"].split(',');
            var check_req = grid_definition_json[0]["validation_rule"].split(',');

            _.each(dropdown_columns, function(item) {
                var has_blank_option = '';
                var col_index = confirm_rule["contract_component_grid_" + confirm_rule_data_tab_id].getColIndexById(item);

                if (check_req[col_index] == '') {
                    has_blank_option = 'true';
                } else {
                    has_blank_option = 'false';
                }

                confirm_rule.grid_dropdowns[item + '_' + confirm_rule_data_tab_id] = confirm_rule["contract_component_grid_" + confirm_rule_data_tab_id].getColumnCombo(col_index);
                confirm_rule.grid_dropdowns[item + '_' + confirm_rule_data_tab_id].enableFilteringMode(true);

                var cm_param = {
                    "action": "spa_adiha_grid",
                    "flag": "t",
                    "grid_name": grid_definition_json[0]["grid_name"],
                    "column_name": item,
                    "call_from": "grid"
                };
                cm_param = $.param(cm_param);
                // Commented below logic because, currently dropdown connector auto checks blank option.
                // var url = js_php_path + 'dropdown.connector.php?' + cm_param + '&has_blank_option=' + has_blank_option;
                var url = js_dropdown_connector_url + '&' + cm_param;
                confirm_rule.grid_dropdowns[item + '_' + confirm_rule_data_tab_id].load(url);
            });
        }

        //refresh grid
        confirm_rule.refresh_grid(sql_stmt, confirm_rule["contract_component_grid_" + confirm_rule_data_tab_id], grid_type, confirm_rule_data_tab_id);


        //attach menu function 
        confirm_rule.grid_menu[menu_index].attachEvent("onClick", function(id) {
            switch (id) {
                case "add":
                    var newId = (new Date()).valueOf();
                    grid_obj.addRow(newId, "");
                    grid_obj.selectRowById(newId);
                    break;
                case "delete":
                    msg = "Are you sure you want to delete?";
                    confirm_messagebox(msg, function() {
                        var selected_row = grid_obj.getSelectedRowId();
                        var count = selected_row.indexOf(",") > -1 ? selected_row.split(",").length : 1;
                        selected_row = selected_row.indexOf(",") > -1 ? selected_row.split(",") : [selected_row];
                        var get_rule_id;
                        var rule_id = '';
                        for (var i = 0; i < count; i++) {
                            var get_rule_id = grid_obj.cells(selected_row[i], grid_obj.getColIndexById('rule_id')).getValue();
                            rule_id += get_rule_id + ',';
                        }
                        rule_id = rule_id.slice(0, -1);

                        if (rule_id == '') {
                            grid_obj.deleteRow(selected_row);
                        } else {
                            var data = {
                                'action': 'spa_deal_confirmation_rule',
                                'flag': 'd',
                                'rule_id': rule_id
                            };
                            adiha_post_data('return_array', data, '', '', 'confirm_rule.delete_rule_call_back');
                        }
                    });
                    break;
                case "refresh":
                    if (sql_stmt != '' && sql_stmt != null) {
                        confirm_rule.refresh_grid(sql_stmt, grid_obj, grid_type, confirm_rule_data_tab_id);
                    }
                    break;
                case "excel":
                    grid_obj.toExcel(php_script_loc_ajax + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                    break;
                case "pdf":
                    grid_obj.toPDF(php_script_loc_ajax + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                    break;
            }
        });

        //enable delete button
        grid_obj.attachEvent("onRowSelect", function(row_id, col_id) {
            confirm_rule.grid_menu[menu_index].setItemEnabled("delete");
        });

        //enable  
        confirm_rule["contract_component_grid_" + confirm_rule_data_tab_id].attachEvent("onCellChanged", function(rId, cInd, nValue) {
            return;
            var column_name = grid_obj.getColumnId(cInd);
            var platform = grid_obj.getColIndexById('platform');
            var confirm_template_id = grid_obj.getColIndexById('confirm_template_id');
            var revision_confirm_template_id = grid_obj.getColIndexById('revision_confirm_template_id');
            var sdr_submission = grid_obj.getColIndexById('sdr_submission');

            if (column_name == 'confirmation_type' && nValue == 46601) { // paper confrim
                grid_obj.cells(rId, platform).setDisabled(true);
                grid_obj.cells(rId, sdr_submission).setDisabled(true);
            }

            if (column_name == 'confirmation_type' && nValue == 46600) { // Econfirm
                grid_obj.cells(rId, platform).setEnabled(true);
                grid_obj.cells(rId, sdr_submission).setEnabled(true);
            }

            if (column_name == 'confirmation_type' && nValue == 46602) { // SDR
                grid_obj.cells(rId, sdr_submission).setDisabled(true);
            }
        });



        //delete callback
        confirm_rule.delete_rule_call_back = function(return_value) {

            if (return_value[0][0] == 'Error') {
                success_call(return_value[0][4], 'error');
                return;
            } else {
                success_call(return_value[0][4]);
            }
            confirm_rule.refresh_grid(sql_stmt, grid_obj, grid_type, confirm_rule_data_tab_id);
        }
        win.progressOff();
    }

    //refresh grid
    confirm_rule.refresh_grid = function(sql_stmt, grid_obj, grid_type, counterparty_id) {
        confirm_rule.layout.cells('b').progressOn();
        if (sql_stmt.indexOf('<ID>') != -1) {
            var stmt = sql_stmt.replace('<ID>', counterparty_id);
        } else {
            var stmt = sql_stmt;
        }
        // load grid data
        var sql_param = {
            "sql": stmt,
            "grid_type": grid_type
        };

        sql_param = $.param(sql_param);
        var sql_url = js_data_collector_url + "&" + sql_param;

        grid_obj.clearAll();
        grid_obj.load(sql_url, function() {
            // grid_obj.filterByAll();
            confirm_rule.layout.cells('b').progressOff();
        });
    }

    confirm_rule.validate_form_grid = function(attached_obj, grid_label) {
        ;
        var status = true;

        for (var i = 0; i < attached_obj.getRowsNum(); i++) {
            var row_id = attached_obj.getRowId(i);
            for (var j = 0; j < attached_obj.getColumnsNum(); j++) {
                var validation_message = attached_obj.cells(row_id, j).getAttribute("validation");
                //alert(validation_message)
                if (validation_message != "" && validation_message != undefined) {
                    var column_text = attached_obj.getColLabel(j);
                    error_message = "Data Error in <b>" + grid_label + "</b> grid. Please check the data in column <b>" + column_text + "</b> and re-run.";
                    dhtmlx.alert({
                        title: "Error",
                        type: "alert-error",
                        text: error_message
                    });
                    status = false;
                    break;
                }
            }
            if (validation_message != "" && validation_message != undefined) {
                break;
            };
        }
        return status;
    }
</script>

<body>