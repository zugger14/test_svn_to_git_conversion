<?php
/**
* View user defined table screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../adiha.php.scripts/components/include.file.v3.php');?>
</head>
<?php
    $form_namespace = 'view_user_defined_table';
    $func_id = strtolower(get_sanitized_value($_GET['function_id'] ?? null));
    $udt_name = get_sanitized_value($_GET['udt_name'] ?? null);
    $udt_name = str_replace(' ', '', $udt_name);
    $udt_id = '';
    if ($udt_name && $udt_name != '') {
        $sql = "SELECT udt_id FROM user_defined_tables WHERE udt_name = '$udt_name'";
        $data = readXMLURL2($sql);
        $udt_id = $data[0]['udt_id'];
    }
    $active_tab = null;

    if ($func_id != null) {
        $function_id = $func_id;
        $privilege_sql = "EXEC spa_arrange_setup_menu @flag='a', @xml='<Root><Data function_id=\"" . $function_id . "\" call_from=\"user_defined_table\"></Data></Root>'";
        $result = readXMLURL2($privilege_sql);

        foreach ($result as $row) {
            // Get active tab id
            if (is_int($row["active_tab_id"]) && $active_tab == null) {
                $active_tab = $row["active_tab_id"];
            }
            // Get Privilege
            if (strpos(strtolower($row["function_name"]), 'add') !== false) {
                $rights_view_user_defined_table_iu = $row["function_id"];
            }
            else if (strpos(strtolower($row["function_name"]), 'delete') !== false) {
                $rights_view_user_defined_table_delete = $row["function_id"];
            }
        }
    } else {
        $function_id = 20003400;
        $rights_view_user_defined_table_iu = 20003401;
        $rights_view_user_defined_table_delete = 20003402;
        $active_tab = $udt_id;
    }

    list (
        $has_rights_view_user_defined_table_iu,
        $has_rights_view_user_defined_table_delete
        ) = build_security_rights(
        $rights_view_user_defined_table_iu,
        $rights_view_user_defined_table_delete
    );

    $form_obj = new AdihaStandardForm($form_namespace, $function_id);
    if ($active_tab != null) {
        $form_obj->define_grid("user_defined_tables", "EXEC spa_user_defined_tables @flag='x', @udt_id=" . $active_tab);
        echo $form_obj->init_form('System Defined Tables', 'Detail', $active_tab);
    } else {
        $form_obj->define_grid("user_defined_tables", "EXEC spa_user_defined_tables @flag='x', @system=0");
        echo $form_obj->init_form('User Defined Tables', 'Detail');
    }
    $form_obj->define_custom_functions('save_function', 'load_function', '', 'after_form_load');
    $form_obj->hide_edit_menu();

    if ($active_tab != null) {
        echo "view_user_defined_table.layout.cells('a').collapse();";
    }

    echo $form_obj->close_form();
?>
<script type="text/javascript">
    var php_script_loc = '<?php echo $app_php_script_loc; ?>';
    var image_path = '<?php echo $image_path; ?>';
    var date_format = '<?php echo $date_format; ?>';
    var field_size = ui_settings['field_size'];
    var offset_left = ui_settings['offset_left'];
    var active_tab = "<?php echo $active_tab; ?>";
    var client_date_format = '<?php echo $date_format; ?>';
    var has_rights_view_user_defined_table_iu = Boolean('<?php echo $has_rights_view_user_defined_table_iu; ?>');
    var has_rights_view_user_defined_table_delete = Boolean('<?php echo $has_rights_view_user_defined_table_delete;?>');
        
    $(function() {
        view_user_defined_table.menu.hideItem('t1');
    });

    view_user_defined_table.load_function = function(win, tab_id, grid_obj,acc_id) {
        win.progressOff();
        var active_object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        view_user_defined_table["layout_" + active_object_id] = win.attachLayout("2E");
        //view_user_defined_table["layout_" + active_object_id].cells('a').hideHeader();
        // view_user_defined_table["layout_" + active_object_id].cells('b').hideHeader();
        view_user_defined_table["layout_" + active_object_id].cells('a').setText("Filter");
        view_user_defined_table["layout_" + active_object_id].cells('b').setText("Data");

        view_user_defined_table["layout_" + active_object_id].cells('a').setHeight(100);
        var save_toolbar = view_user_defined_table.tabbar.cells(full_id).getAttachedToolbar();
        save_toolbar.hideItem('save');

        menu_load_function();

        data = {"action": "spa_user_defined_tables",
            "flag": "g",
            "udt_id": active_object_id
        };

        adiha_post_data('return_array', data, '', '', 'grid_load_function', '');
    }

    menu_load_function = function() {
        var active_tab = view_user_defined_table.tabbar.getActiveTab();
        var active_object_id = get_active_object_id();

        var menu_json =   [
            {id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif", title: "Refresh"},
            {id:"save", text:"Save", img:"save.gif", imgdis:"save_dis.gif", title: "Save", enabled: has_rights_view_user_defined_table_iu},
            {id:"t1", text:"Edit", img:"edit.gif", items:[
                {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add", enabled: has_rights_view_user_defined_table_iu},
                {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete", enabled: 0}
            ]},
            {id:"t2", text:"Export", img:"export.gif", items:[
                {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
            ]},
            {id:"pivot", text:"Pivot", img:"pivot.gif", imgdis:"pivot_dis.gif", title: "Pivot"}
        ];

        view_user_defined_table["menu_" + active_object_id] = view_user_defined_table["layout_" + active_object_id].cells('b').attachMenu();
        view_user_defined_table["menu_" + active_object_id].setIconsPath(image_path + 'dhxmenu_web/');
        view_user_defined_table["menu_" + active_object_id].loadStruct(menu_json);
        view_user_defined_table["menu_" + active_object_id].attachEvent('onClick', function(id){
            switch(id) {
                case "add":
                    var new_id = (new Date()).valueOf();
                    view_user_defined_table["grid_" + active_object_id].addRow(new_id,['','','','','','']);
                    break;
                case "delete":
                    view_user_defined_table.delete_data();
                    break;
                case "excel":
                    view_user_defined_table["grid_" + active_object_id].toExcel(php_script_loc + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                    break;
                case "pdf":
                    view_user_defined_table["grid_" + active_object_id].toPDF(php_script_loc +'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                    break;
                case "refresh":
                    if (typeof(view_user_defined_table["form_" + active_object_id]) != 'undefined') {
                        form_obj = view_user_defined_table["form_" + active_object_id].getForm();
                        if (form_obj.validate()) {
                            view_user_defined_table["layout_" + active_object_id].cells('b').progressOn();
                            view_user_defined_table.refresh_grid();
                        }
                    } else {
                        view_user_defined_table["layout_" + active_object_id].cells('b').progressOn();
                        view_user_defined_table.refresh_grid();
                    }
                    break;
                case "save":
                    view_user_defined_table.save_function();
                    break;
                case "pivot":
                    grid_sql_param = view_user_defined_table.refresh_grid('', 0);
                    grid_sql_param = decodeURIComponent(grid_sql_param);
                    grid_sql_param = grid_sql_param.split("xml_filter_data=")[1];
                    grid_sql_param = grid_sql_param.split("+").join(" ");
                    grid_sql = "EXEC spa_user_defined_tables @flag='p', @udt_id='" + active_object_id + "', @xml_filter_data='" + grid_sql_param + "'";
                    open_grid_pivot('', 'view_udt', 0, grid_sql, 'Power Rate Schedule');
                    break;
            }
        });

    }

    grid_load_function = function(result) {
        var active_tab = view_user_defined_table.tabbar.getActiveTab();
        var active_object_id = get_active_object_id();
        var data_type_int = ['104302','104303'];  // column_type = INT, FLOAT
        var data_type_char = ['104302','104303'];
        
        // Change tab name
        var selected_id = view_user_defined_table.grid.getSelectedRowId();
        var col_desc = view_user_defined_table.grid.getColIndexById('udt_descriptions');
        var tab_name = view_user_defined_table.grid.cells(selected_id, col_desc).getValue();
        view_user_defined_table.tabbar.tabs(active_tab).setText(tab_name);

        view_user_defined_table["layout_" + active_object_id].cells('b').progressOn();

        var grid_header = new Array();
        var grid_attached_header = new Array();
        var grid_col_ids = new Array();
        var grid_col_types = new Array();
        var grid_col_width = new Array();
        var grid_col_sorting = new Array();
        var grid_col_visibility = new Array();
        var set_col_validators = new Array();
        var combo_data = new Array();
        var filter_combo_data = new Array();
        var filter_form_json = new Array();
        var grid_col_rounding = new Array();
        var float_round_value = '';

        for (cnt = 0; cnt < result.length; cnt++) {
            var validation = [];
            float_round_value = result[cnt][14]; 
            grid_header.push(result[cnt][3]);
            grid_col_ids.push(result[cnt][2]);
            newcolumn_string = '{"type":"newcolumn"}';

            if (result[cnt][12] == null && result[cnt][19] == null) {
                if (result[cnt][4] == '104304') {  // column_type = DATETIME
                    grid_col_types.push('dhxCalendarA');
                    grid_col_rounding.push('');
                    
                    if (result[cnt][11] == '1') { // filters
                        input_string = '{"type": "calendar", "name": "' + result[cnt][2] + '_from", "value": "", "label": "' + result[cnt][3] + ' From", "disabled": "false","dateFormat":"' + date_format + '", "inputWidth": '+ field_size + ', "position": "label-top", "offsetLeft":' + offset_left + ', "required":' + result[cnt][18] + '}';
                        input_string1 = '{"type": "calendar", "name": "' + result[cnt][2] + '_to", "value": "", "label": "' + result[cnt][3] + ' To", "disabled": "false","dateFormat":"' + date_format + '", "inputWidth": '+ field_size + ', "position": "label-top", "offsetLeft":' + offset_left + ', "required":' + result[cnt][18] + '}';
                        filter_form_json.push(JSON.parse(input_string));
                        filter_form_json.push(JSON.parse(newcolumn_string));
                        filter_form_json.push(JSON.parse(input_string1));
                        filter_form_json.push(JSON.parse(newcolumn_string));
                    }
                    grid_col_rounding.push('');
                } else {
                    if ( result[cnt][4] == '104302' ) {
                        grid_col_types.push('ed_int');
                        grid_col_rounding.push('');
                    } else if ( result[cnt][4] == '104303' ) {
                        grid_col_types.push('ed_no');
                        grid_col_rounding.push(float_round_value);
                    } else {
                        grid_col_types.push('ed');
                        grid_col_rounding.push('');
                    }
                    if (result[cnt][11] == '1') { // filters
                        input_string = '{"type": "input", "name": "' + result[cnt][2] + '", "value": "", "label": "' + result[cnt][3] + '", "disabled": "false", "inputWidth": '+ field_size + ', "position": "label-top", "offsetLeft":' + offset_left + ', "required":' + result[cnt][18] + '}';
                        filter_form_json.push(JSON.parse(input_string));
                        filter_form_json.push(JSON.parse(newcolumn_string));
                    }
                }
            } else {
                if(result[cnt][12] == null) {
                    combo_data.push([result[cnt][2],result[cnt][19], "sql"]);  // custom sql combo.
                }else {
                    combo_data.push([result[cnt][2],result[cnt][12], "static"]);
                }
                grid_col_types.push('combo');
                grid_col_rounding.push('');

                if (result[cnt][11] == '1') { // filters
                    if(result[cnt][12] == null) {
                        filter_combo_data.push([result[cnt][2],result[cnt][19], "sql"]);  // custom sql combo.
                    }else {
                        filter_combo_data.push([result[cnt][2],result[cnt][12], "static"]);
                    }
                    input_string = '{"type": "combo", "name": "' + result[cnt][2] + '", "value": "", "label": "' + result[cnt][3] + '", "disabled": "false", "inputWidth": '+ field_size + ', "position": "label-top", "offsetLeft":' + offset_left + ', "required":' + result[cnt][18] + '}';
                    filter_form_json.push(JSON.parse(input_string));
                    filter_form_json.push(JSON.parse(newcolumn_string));
                }
            }
            grid_col_width.push('120');

            if ($.inArray(result[cnt][4], data_type_int) != -1) { // For int and float
                grid_col_sorting.push('int');
                // validation.push('ValidNumericWithEmpty');
                grid_attached_header.push('#numeric_filter');
            } else if (result[cnt][4] == '104304') {
                grid_col_sorting.push('date');
                grid_attached_header.push('#text_filter');
            } else {
                grid_col_sorting.push('str');
                grid_attached_header.push('#text_filter');
            }

            if (result[cnt][8] == 0) {  // Column nullable
                validation.push('NotEmpty');
            }

            if(result[cnt][16] !== '') { // Custom validation
                validation.push(result[cnt][16]);
            }

            if (result[cnt][10] == 0) {  // Is not identity
                grid_col_visibility.push(false);
                set_col_validators.push(validation.toString());
            } else {
                grid_col_visibility.push(true);
                set_col_validators.push('');
                view_user_defined_table["primary_column_" + active_object_id] = result[cnt][2];
            }
        }

        // For filter form in cell 'a'
        if(filter_form_json == 0) {
            view_user_defined_table["form_is_filter_" + active_object_id] = false;
            //view_user_defined_table["layout_" + active_object_id].cells("a").hideHeader();
            view_user_defined_table["layout_" + active_object_id].cells("a").setHeight(0);
        } else {
            view_user_defined_table["form_is_filter_" + active_object_id] = true;
            view_user_defined_table["form_" + active_object_id] = view_user_defined_table["layout_" + active_object_id].cells('a').attachForm(filter_form_json);
        }

        /*Attaching status bar for grid pagination*/
        var paging_div_id = "pagingAreaGrid_" + active_object_id;
        view_user_defined_table["layout_" + active_object_id].cells('b').attachStatusBar({
            height: 30,
            text: '<div id="' + paging_div_id + '"></div>'
        });

        // For Grid in cell 'b'
        view_user_defined_table["grid_" + active_object_id] = view_user_defined_table["layout_" + active_object_id].cells('b').attachGrid();
        view_user_defined_table["grid_" + active_object_id].setHeader(grid_header.toString());
        view_user_defined_table["grid_" + active_object_id].setColumnIds(grid_col_ids.toString());
        view_user_defined_table["grid_" + active_object_id].setColTypes(grid_col_types.toString());
        view_user_defined_table["grid_" + active_object_id].setInitWidths(grid_col_width.toString());
        view_user_defined_table["grid_" + active_object_id].attachHeader(grid_attached_header.toString());
        view_user_defined_table["grid_" + active_object_id].setColSorting(grid_col_sorting.toString());
        view_user_defined_table["grid_" + active_object_id].setDateFormat(date_format,'%Y-%m-%d');
        view_user_defined_table["grid_" + active_object_id].setPagingWTMode(true, true, true, true);
        view_user_defined_table["grid_" + active_object_id].enablePaging(true, 25, 0, paging_div_id);
        view_user_defined_table["grid_" + active_object_id].setPagingSkin('toolbar');
        view_user_defined_table["grid_" + active_object_id].init();
        view_user_defined_table["grid_" + active_object_id].setColumnsVisibility(grid_col_visibility.toString());
        view_user_defined_table["grid_" + active_object_id].enableMultiselect(true);
        view_user_defined_table["grid_" + active_object_id].setColValidators(set_col_validators);
        view_user_defined_table["grid_" + active_object_id].attachEvent("onRowSelect", function(id,ind){
            if(has_rights_view_user_defined_table_delete) {
                view_user_defined_table["menu_" + active_object_id].setItemEnabled('delete');
            }
        });

        view_user_defined_table["grid_" + active_object_id].attachEvent("onValidationError",function(id, ind, value) {
            var message = "Invalid Data";
            view_user_defined_table["grid_" + active_object_id].cells(id,ind).setAttribute("validation", message);
            return true;
        });

        view_user_defined_table["grid_" + active_object_id].attachEvent("onValidationCorrect",function(id,ind,value){
            view_user_defined_table["grid_" + active_object_id].cells(id,ind).setAttribute("validation", "");
            return true;
        });

        view_user_defined_table["grid_" + active_object_id].enableRounding(grid_col_rounding.toString());
        var udt_param = {
            "flag": "s",
            "action": "spa_user_defined_tables",
            "udt_id": active_object_id
        };

        // Display context menu to show/hide columns
        var enable_header_menu_list = '';
        grid_col_ids.forEach(function(value) {
            enable_header_menu_list += 'true,'
        });
        enable_header_menu_list = enable_header_menu_list.substring(0, enable_header_menu_list.length - 1);
        view_user_defined_table["grid_" + active_object_id].enableHeaderMenu();

        //Set Combo Value
        for (i = 0; i < combo_data.length; i++) {
            if(combo_data[i][2] !== "sql") {
                if (combo_data[i][1] == -1 || combo_data[i][1] == -2 || combo_data[i][1] == -3 || combo_data[i][1] == -4 || combo_data[i][1] == -5 || combo_data[i][1] == -7 || combo_data[i][1] == -8) {
                    switch (combo_data[i][1]) {
                        case -1:
                            var cm_param = {"action": "spa_source_counterparty_maintain",
                                                "flag": "c"
                                            };
                            break;
                        case -2:
                            cm_param = {"action": "spa_source_minor_location",
                                            "flag": "o"
                            };
                            break;
                        case -3:
                            cm_param = {"action": "spa_source_currency_maintain",
                                "flag": "p"
                            };
                            break;
                        case -4:
                            cm_param = {"action": "spa_getsourceuom",
                                "flag": "s"
                            };
                            break;
                        case -5:
                            cm_param = {"action": "spa_source_book_maintain",
                                "flag": "c"
                            };
                            break;
                        case -7:
                            cm_param = {"action": "spa_source_contract_detail",
                                "flag": "r"
                            };
                            break;
                        case -8:
                            cm_param = {"action": "spa_get_combo_value",
                                "flag": "y"
                            };
                            break;
                    }
                } else {
                    var cm_param = {"action": "[spa_StaticDataValues]", 
                            "flag": "h",
                            "type_id" : combo_data[i][1]
                    };
                }
            } else {
                var cm_param = {"action": "('" + combo_data[i][1].replace(/'/g, "''") + "')"};
                // var cm_param = {"action": "('" + unescapeXML(combo_data[i][1]).replace(/'/g, "''") + "')"};
            }

            // var query = "select value_id, code, 'enable' enabled from static_data_value where type_id = " + combo_data[i][1] + " order by value_id";
            //     var cm_param = {"action": query};
            //     console.log(cm_param)

            var combo_obj = view_user_defined_table["grid_" + active_object_id].getColumnCombo(view_user_defined_table["grid_" + active_object_id].getColIndexById(combo_data[i][0]));                
            combo_obj.enableFilteringMode('between');
            var data = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + data;
            combo_obj.load(url, function() {

                var data = $.param(cm_param);
                var url = js_dropdown_connector_url + '&' + data;
                combo_obj.load(url);

            });
        }
        //End combo 

        //FORM Feed
        var grid_obj = view_user_defined_table["grid_" + active_object_id];
        create_grid_row_popup(grid_obj);
        //FORM Feed END
       

        //Set Filter Combo Value
        for (i = 0; i < filter_combo_data.length; i++) {
            if(filter_combo_data[i][2] !== "sql") {
                if (filter_combo_data[i][1] == -1 || filter_combo_data[i][1] == -2 || filter_combo_data[i][1] == -3 || filter_combo_data[i][1] == -4 || filter_combo_data[i][1] == -5 || filter_combo_data[i][1] == -7 || filter_combo_data[i][1] == -8) {
                    switch (filter_combo_data[i][1]) {
                        case -1:
                            var cm_param = {"action": "spa_source_counterparty_maintain",
                                                "flag": "c"
                                            };
                            break;
                        case -2:
                            cm_param = {"action": "spa_source_minor_location",
                                            "flag": "o"
                            };
                            break;
                        case -3:
                            cm_param = {"action": "spa_source_currency_maintain",
                                "flag": "p"
                            };
                            break;
                        case -4:
                            cm_param = {"action": "spa_getsourceuom",
                                "flag": "s"
                            };
                            break;
                        case -5:
                            cm_param = {"action": "spa_source_book_maintain",
                                "flag": "c"
                            };
                            break;
                        case -7:
                            cm_param = {"action": "spa_source_contract_detail",
                                "flag": "r"
                            };
                            break;
                        case -8:
                            cm_param = {"action": "spa_get_combo_value",
                                "flag": "y"
                            };
                            break;
                    }
                } else {
                    var cm_param = {"action": "[spa_StaticDataValues]", 
                            "flag": "h",
                            "type_id" : filter_combo_data[i][1]
                    };
                }
            } else {
                var cm_param = {"action": "('" + filter_combo_data[i][1].replace(/'/g, "''") + "')"};
                // var cm_param = {"action": "('" + unescapeXML(combo_data[i][1]).replace(/'/g, "''") + "')"};
            }

            var combo_obj = view_user_defined_table["form_" + active_object_id].getCombo(filter_combo_data[i][0]);                
            combo_obj.enableFilteringMode('between');
            var data = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + data;
            combo_obj.load(url, function() {

                var data = $.param(cm_param);
                var url = js_dropdown_connector_url + '&' + data;
                combo_obj.load(url);

            });
        }
        //End combo
        view_user_defined_table["layout_" + active_object_id].cells('b').progressOff();
    }

    view_user_defined_table.refresh = function(result) {
        if (result[0][0] == 'Success') {
            success_call(result[0][4]);
            view_user_defined_table["layout_" + active_object_id].cells('b').progressOn();
            view_user_defined_table.refresh_grid(result);
        } else if (result[0][0] == 'Error') {
            dhtmlx.message({
                title:'Error',
                type:'alert-error',
                text:result[0][4]
            });
            return;
        }
    }

    view_user_defined_table.refresh_grid = function(result, reload) {
        var xml_data = "<FormXML";
        var active_object_id = get_active_object_id();

        if(view_user_defined_table["form_is_filter_" + active_object_id]) { // If filter exists.
            data = view_user_defined_table["form_" + active_object_id].getFormData();

            for (var a in data) {
                field_label = a;
                field_value = data[a];
                if (field_value) {
                    field_value = data[a];    
                }

                if (view_user_defined_table["form_" + active_object_id].getItemType(a) == "calendar") {
                    field_value = view_user_defined_table["form_" + active_object_id].getItemValue(a, true);
                }

                lbl = view_user_defined_table["form_" + active_object_id].getItemLabel(a);
                lbl_value = view_user_defined_table["form_" + active_object_id].getItemValue(a);
                
                if (!field_value)
                    field_value = '';
                    xml_data += " " + field_label + "=\"" + field_value + "\"";
            }
        }

        xml_data += "></FormXML>";

        var sql_param = {
            "flag": "s",
            "action": "spa_user_defined_tables",
            "udt_id": active_object_id,
            "xml_filter_data": xml_data
        };

        sql_param = $.param(sql_param);
        var sql_url = js_data_collector_url + "&" + sql_param;

        if (reload != 0)  {
            view_user_defined_table["grid_" + active_object_id].clearAll();
            view_user_defined_table["grid_" + active_object_id].load(sql_url);
            view_user_defined_table["layout_" + active_object_id].cells('b').progressOff();
        } else {
            return sql_param;
        }
    }

    view_user_defined_table.save_function = function() {
        var grid_status = null;
        var active_object_id = get_active_object_id();
        var valid = cell_validation();

        if (valid['status'] == false) {
            dhtmlx.message({
                title:'Error',
                type:'alert-error',
                text:valid['msg']
            });
            return false;
        }

        grid_label = view_user_defined_table["grid_" + active_object_id].getUserData("", "grid_label");
        grid_status = valid['status'];

        view_user_defined_table["grid_" + active_object_id].clearSelection();
        var ids = view_user_defined_table["grid_" + active_object_id].getChangedRows();

        if (ids == '' || ids == null) {
            dhtmlx.message({
                text:'Data saved without any changes.',
                expire:1000
            });
            return false;
        }
        
        var changed_ids = ids.split(',');

        if (grid_status) {
            var grid_xml = '<Grid>';
            changed_ids.forEach(function(i) {
                view_user_defined_table["grid_" + active_object_id].forEachCell(i,function(cellObj,ind){
                    var col_data = '<GridData row_id = "' + i + '" '
                    col_data += 'column_name="' + view_user_defined_table["grid_" + active_object_id].getColumnId(ind) + '" ';
                    col_data += 'column_value="' + view_user_defined_table["grid_" + active_object_id].cells(i,ind).getValue() + '" />';
                    grid_xml += col_data;
                });
            });
            grid_xml += '</Grid>';
    
            var data = {
                "action": "spa_user_defined_tables",
                "flag": "t",
                "udt_id": active_object_id,
                "xml_data": grid_xml
            };
            adiha_post_data('return_array', data, '', '', 'view_user_defined_table.save_callback', '');

        } else {
            return;
        }
    }

    view_user_defined_table.save_callback = function(result) {
        if (result[0][0] == 'Success') {
            success_call(result[0][4]);
            view_user_defined_table.refresh_grid();
        } else {
            success_call(result[0][4], 'error');
            return;
        }
    }

    view_user_defined_table.delete_data = function() {
        var active_object_id = get_active_object_id();
        var row_id = view_user_defined_table["grid_" + active_object_id].getSelectedRowId();
        var udt_deleted_id = '';
        var count_ids = row_id.split(",").length;
        var primary_col_ind = view_user_defined_table["grid_" + active_object_id].getColIndexById(view_user_defined_table["primary_column_" + active_object_id]);
        var unsaved_items = [];


        for ( var i = 0; i < count_ids; i++) {
            udt_id = view_user_defined_table["grid_" + active_object_id].cells(row_id.split(",")[i], primary_col_ind).getValue();
            if (udt_id == '') {
                unsaved_items[i] = row_id.split(",")[i];
            } else {
                udt_deleted_id += udt_id + ',';
            }
        }

        if (udt_deleted_id.indexOf(',') > -1) {
            udt_deleted_id = udt_deleted_id.slice(0, -1);
        }

        var data = {
            "action": "spa_user_defined_tables",
            "flag": "d",
            "udt_id": active_object_id,
            "udt_deleted_id": udt_deleted_id
        };

        del_msg =  "Some data has been deleted from grid. Are you sure you want to save?";
        dhtmlx.message({
            type: "confirm-warning",
            text: del_msg,
            title: "Warning",
            callback: function(result) {                         
                if (result) {
                    unsaved_items.forEach(function(unsaved_row_id) {
                        view_user_defined_table["grid_" + active_object_id].deleteRow(unsaved_row_id);
                    });

                    if (udt_deleted_id != "") {
                        adiha_post_data('return_array', data, '', '', 'view_user_defined_table.refresh_grid', '');
                    }
                }                           
            } 
        });
    }

    cell_validation = function() {
        var validation = [];
        validation['status'] = true;
        validation['msg'] = 'Valid';
        var active_object_id = get_active_object_id();
        var grid_obj = view_user_defined_table["grid_" + active_object_id];
        grid_obj.forEachRow(function(row){
            grid_obj.forEachCell(row,function(cellObj,ind){
                validate_cell = grid_obj.validateCell(row,ind);
                if (validate_cell == false) {
                    validation['status'] = false;
                    validation['msg'] = 'Data Error in grid. Please check the data in column <b>' + grid_obj.getColLabel(ind) + '</b> and resave.';
                    return validation;
                }
            });
        });
        return validation;
    }

    // view_user_defined_table.validate_form_grid = function(attached_obj,grid_label) {
    //     var status = true;
    //     for (var i = 0;i < attached_obj.getRowsNum();i++){
    //         var row_id = attached_obj.getRowId(i);

    //         for (var j = 0;j < attached_obj.getColumnsNum();j++){
    //             var validation_message = attached_obj.cells(row_id,j).getAttribute("validation");

    //             var val_1 = attached_obj.cells(row_id,j).getValue();

    //             if(validation_message != "" && validation_message != undefined){
    //                 var column_text = attached_obj.getColLabel(j);
    //                 error_message = "Data Error in <b>"+''+"</b> grid. Please check the data in column <b>"+column_text+"</b> and save.";
    //                 dhtmlx.alert({title:"Alert",type:"alert",text: error_message});
    //                 status = false; break;
    //             }
    //         }
    //         if(validation_message != "" && validation_message != undefined){ break;};
    //     }
    //     return status;
    // }

    get_active_object_id = function() {
        var active_tab_id = view_user_defined_table.tabbar.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        return active_object_id;
    }


</script>