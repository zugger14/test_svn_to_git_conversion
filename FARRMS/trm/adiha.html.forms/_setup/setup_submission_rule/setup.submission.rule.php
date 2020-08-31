<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
        <?php require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
    </head>
    <?php
        $application_function_id = 20015200;
        $form_namespace = 'submission_rule';
        $form_obj = new AdihaStandardForm($form_namespace, 20015200);
        $form_obj->define_grid("SubmissionRulemain", "","g");
        
        $form_obj->define_custom_functions('save_submission_rule', 'load_submission_rule');
        echo $form_obj->init_form('Submission Rule', 'Submission Rule');
        echo $form_obj->close_form();

        $form_sql = "EXEC spa_adiha_grid 's', 'SubmissionRule'";
        $form_data = readXMLURL2($form_sql);
        $grid_definition_json = json_encode($form_data);
    ?>
        
    <script type="text/javascript">
        var grid_definition_json = <?php echo $grid_definition_json; ?>;
        submission_rule.grid_menu = {};
        submission_rule.grid_dropdowns = {};
        var deleted_rule_ids = new Array();
        var php_script_loc = "<?php echo $app_php_script_loc; ?>";

        $(function() {
            submission_rule.layout.cells("a").setWidth(250);
            submission_rule.menu.hideItem('t1');
            submission_rule.menu.hideItem('t2');
        });
        
        submission_rule.save_submission_rule = function(tab_id) {            
            var submission_type_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
            var layout = submission_rule.layout["inner_tab_layout_" + submission_type_id];
            layout.cells('a').progressOn(); 
            var grid_obj = submission_rule["submission_rule_grid_" + submission_type_id];
            var xml_grid = '<GridSubmissionRule>';
            var validate_flag = 0;

            grid_obj.forEachRow(function(ids) {
                xml_grid = xml_grid + '<GridRow ';
                 
                grid_obj.forEachCell(ids, function(cellObj, ind) {
                    var grid_index = grid_obj.getColumnId(ind);
                    var value = cellObj.getValue(ind);                    
                    xml_grid = xml_grid + grid_index + '="' + value  + '" ';

                    var counterparty_idx = grid_obj.getColIndexById('counterparty_id');

                    if (counterparty_idx == ind && value == '') {
                        validate_flag = 1;
                    }
                });
                
                xml_grid = xml_grid + '></GridRow>'; 
            });

            xml_grid = xml_grid + '</GridSubmissionRule>';
            
            var deleted_rule_id = deleted_rule_ids.toString();

            if (submission_type_id == 44705 && validate_flag == 1) {
                var error_message = "Data Error in <b>Submission Rules</b> grid. Please check the data in column <b>Counterparty</b> and save. Value in <b>Counterparty</b> field is required for <b>ECM</b>";
                show_messagebox(error_message);
                layout.cells('a').progressOff();
                return;
            }

            if (deleted_rule_id != '') {
                dhtmlx.message({
                    type: "confirm",
                    title: "Confirmation",
                    ok: "Confirm",
                    text: "There are some rows deleted in the grid. Are you sure to continue?",
                    callback: function(result) {
                        if (result)
                            confirm_save_data(deleted_rule_id, xml_grid);
                        else {
                            layout.cells('a').progressOff();
                            return;
                        }
                    }
                });
            } else {
                confirm_save_data(deleted_rule_id, xml_grid);
            }
        }
        
        function confirm_save_data(deleted_rule_id, xml_grid) {
            var data = {
                'action' : 'spa_submission_rule',
                'flag' : 'save_data',
                'delete_rule_ids': deleted_rule_id,
                'grid_xml' : xml_grid 
            };

            adiha_post_data('return_array', data, '', '', 'submission_rule.save_submission_rule_call_back');
        } 
            
        submission_rule.save_submission_rule_call_back = function (return_value) {
            var active_tab_id = submission_rule.tabbar.getActiveTab();
            var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            var layout = submission_rule.layout["inner_tab_layout_" + object_id];
            layout.cells('a').progressOff();
            var grid_obj = submission_rule["submission_rule_grid_" + object_id];
            var sql_stmt  = grid_definition_json[0]["sql_stmt"];
            var grid_type  = grid_definition_json[0]["grid_type"];
            
            if (return_value[0][0] == 'Error') {
                dhtmlx.message({
                            title:'Error',
                            type:"alert-error",
                            text:return_value[0][4] 
                        });
                return;
            } else {
                dhtmlx.message({
                            text:return_value[0][4],
                            expire: 1000
                        });
            }
            submission_rule.layout.cells('b').progressOn();
            submission_rule.refresh_grid(sql_stmt, grid_obj, grid_type, object_id);
        }

        submission_rule.load_submission_rule = function(win, tab_id, grid_obj) {
            win.progressOn();
            var is_new = win.getText();
            win.getAttachedToolbar().enableItem("save");
            
            var submission_rule_data_tab_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
            submission_rule_data_tab_id = ($.isNumeric(submission_rule_data_tab_id)) ? submission_rule_data_tab_id : ord(submission_rule_data_tab_id.replace(" ", ""));  
            
            var header_allignment;
            var counter = 0;
            
            $.each(grid_definition_json[0]["column_alignment"].split(','), function(index, value) {
                if (counter == 0)
                    header_allignment = 'text-align:' + value ;
                else
                    header_allignment += ',text-align:' + value ;
                counter ++
            });

            submission_rule.layout["inner_tab_layout_" + submission_rule_data_tab_id] = win.attachLayout({
                pattern: "1C",
                cells: [{id: "a", text: "Submission Rules"}]
            });
             
            var menu_index = "grid_menu_" + submission_rule_data_tab_id + "_" + tab_id;

            submission_rule.grid_menu[menu_index] = submission_rule.layout["inner_tab_layout_" + submission_rule_data_tab_id].cells('a').attachMenu({
            icons_path: js_image_path + "dhxmenu_web/",
            items: [
                {id: "refresh", text: "Refresh", img: "refresh.gif", img_disabled: "refresh_dis.gif"},
                {id: "edit", text: "Edit", img: "edit.gif", img_disabled: "edit_dis.gif", items: [
                        {id: "add", text: "Add", img: "add.gif", img_disabled: "add_dis.gif"},
                        {id: "delete", text: "Delete", disabled: true, img: "delete.gif", img_disabled: "delete_dis.gif"}
                    ]},
                {id: "t2", text: "Export", img: "export.gif", items: [
                        {id: "excel", text: "Excel", img: "excel.gif", imgdis: "excel_dis.gif", title: "Excel"},
                        {id: "pdf", text: "PDF", img: "pdf.gif", imgdis: "pdf_dis.gif", title: "PDF"}
                    ]}
                ]
            });

            var grid_name = grid_definition_json[0]["grid_name"];
            var grid_cookies = "grid_" + grid_name;

            submission_rule["submission_rule_grid_" + submission_rule_data_tab_id] = submission_rule.layout["inner_tab_layout_" + submission_rule_data_tab_id].cells('a').attachGrid();
        
            var grid_obj = submission_rule["submission_rule_grid_" + submission_rule_data_tab_id];
            grid_obj.setImagePath(js_image_path + "dhxgrid_web/");                
            grid_obj.setHeader(grid_definition_json[0]["column_label_list"],null,header_allignment.split(","));                
            grid_obj.setColumnIds(grid_definition_json[0]["column_name_list"]);
            grid_obj.setInitWidths(grid_definition_json[0]["column_width"]);
            grid_obj.setColTypes(grid_definition_json[0]["column_type_list"]);
            grid_obj.setColAlign(grid_definition_json[0]["column_alignment"]);
            grid_obj.setColumnsVisibility(grid_definition_json[0]["set_visibility"]);
            grid_obj.setColSorting(grid_definition_json[0]["sorting_preference"]);
            grid_obj.setDateFormat(user_date_format,'%Y-%m-%d');
            grid_obj.splitAt(grid_definition_json[0]["split_at"]);
            grid_obj.enableMultiselect(true);
            grid_obj.enableColumnMove(true);
            grid_obj.setUserData("", "grid_id", grid_name);

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

            var sql_stmt  = grid_definition_json[0]["sql_stmt"];
            var grid_type = grid_definition_json[0]["grid_type"];

            if (grid_definition_json[0]["dropdown_columns"] != null && grid_definition_json[0]["dropdown_columns"] != '') {
            var dropdown_columns = grid_definition_json[0]["dropdown_columns"].split(',');
            var check_req = grid_definition_json[0]["validation_rule"].split(',');
            submission_rule.layout.cells('b').progressOn();
            _.each(dropdown_columns, function(item) {
                var has_blank_option = '';
                var col_index = submission_rule["submission_rule_grid_" + submission_rule_data_tab_id].getColIndexById(item);
                
                if (check_req[col_index] == '') {
                    has_blank_option = 'true';
                } else {
                    has_blank_option = 'false';
                }                

                submission_rule.grid_dropdowns[item + '_' + submission_rule_data_tab_id] = submission_rule["submission_rule_grid_" + submission_rule_data_tab_id].getColumnCombo(col_index);
                submission_rule.grid_dropdowns[item + '_' + submission_rule_data_tab_id].enableFilteringMode(true);

                var cm_param = {"action": "spa_adiha_grid", "flag": "t", "grid_name": grid_definition_json[0]["grid_name"], "column_name": item, "call_from": "grid"};
                cm_param = $.param(cm_param);
                var url = js_dropdown_connector_url + '&' + cm_param + '&has_blank_option=' + has_blank_option;
                submission_rule.grid_dropdowns[item + '_' + submission_rule_data_tab_id].load(url, function() {
                    if (item == 'physical_financial_flag') { // Grid refreshed when last dropdown has been loaded
                        submission_rule.refresh_grid(sql_stmt, submission_rule["submission_rule_grid_" + submission_rule_data_tab_id], grid_type, submission_rule_data_tab_id);
                    }
                });
            });
        }
        
        submission_rule["submission_rule_grid_" + submission_rule_data_tab_id].attachEvent("onEditCell", function(stage, r_id, c_ind, n_value, o_value) {
                var submission_type_idx = grid_obj.getColIndexById('submission_type_id');

                if (submission_type_idx == c_ind) {
                    return false;
                } else {
                    return true;
                }
        });
        
        submission_rule.grid_menu[menu_index].attachEvent("onClick", function(id) {
            switch (id) {
                case "add":
                    var new_id = (new Date()).valueOf();
                    grid_obj.addRow(new_id, "");
                    grid_obj.selectRowById(new_id);
                    var submission_type_idx = grid_obj.getColIndexById('submission_type_id');
                    submission_rule["submission_rule_grid_" + submission_rule_data_tab_id].cells(new_id, submission_type_idx).setValue(submission_rule_data_tab_id);
                    break;
                case "delete":
                    var selected_row = grid_obj.getSelectedRowId();
                    var rule_id_index = grid_obj.getColIndexById('rule_id');
                    selected_row = selected_row.split(',');
                    selected_row.forEach(function(val) {
                        var rule_id = grid_obj.cells(val, rule_id_index).getValue();
                        deleted_rule_ids.push(rule_id);
                        grid_obj.deleteRow(val);
                    });
                    break;
                case "refresh":
                    if (sql_stmt != '' && sql_stmt != null) {
                        submission_rule.layout.cells('b').progressOn();
                        submission_rule.refresh_grid(sql_stmt, grid_obj, grid_type, submission_rule_data_tab_id);
                    }
                    break;
                case "excel":
                    grid_obj.toExcel(php_script_loc + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                    break;
                case "pdf":
                    grid_obj.toPDF(php_script_loc + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                    break;
            }
        });

        grid_obj.attachEvent("onRowSelect", function(row_id, col_id) {            
            submission_rule.grid_menu[menu_index].setItemEnabled("delete");
        });

        win.progressOff();
    }

    submission_rule.refresh_grid = function(sql_stmt, grid_obj, grid_type, submission_type) {
        if (sql_stmt.indexOf('<ID>') != -1) {
            var stmt = sql_stmt.replace('<ID>', submission_type);
        } else {
            var stmt = sql_stmt;
        }
        
        var sql_param = {
            "sql": stmt,
            "grid_type": grid_type
        };

        sql_param = $.param(sql_param);
        var sql_url = js_data_collector_url + "&" + sql_param;

        grid_obj.clearAll();
        grid_obj.load(sql_url, function(){
            submission_rule.layout.cells('b').progressOff();
        });
    }    
    </script>
</html>