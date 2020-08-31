<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
<?php
$php_script_loc = $app_php_script_loc;
$application_function_id =  20015100;
$right_exchange_api_configuration_add = 20015101;
$right_exchange_api_configuration_delete = 20015102;
$form_namespace = 'exchange_api_configuration';
list (
    $has_right_exchange_api_configuration_add,
    $has_right_exchange_api_configuration_delete
    ) = build_security_rights(
    $right_exchange_api_configuration_add,
    $right_exchange_api_configuration_delete
);
$form_obj = new AdihaStandardForm($form_namespace, 20015100);
$form_obj->define_grid("ExchangeAPIConfiguration", "EXEC spa_exchange_api_configuration 'g'", "g");
$form_obj->define_layout_width(300);
$form_obj->define_custom_functions('save_form', 'load_form', '','','');
echo $form_obj->init_form('Exchange');
echo $form_obj->close_form();

$grid_name = ['InterfaceConfiguration','InterfaceConfigurationDetail'];
$grid_definition = array();
foreach ($grid_name as $grid_id) {
    // Grid data collection
    $grid_json = array();
    $grid_def = "EXEC spa_adiha_grid 's', '" . $grid_id . "'";
    $def = readXMLURL2($grid_def);
    if ($grid_id == 'InterfaceConfiguration')
        $def['grid_label'] = 'API Configuration';
    else if ($grid_id == 'InterfaceConfigurationDetail')
        $def['grid_label'] = 'API Configuration Detail';

    $it = new RecursiveIteratorIterator(new RecursiveArrayIterator($def));
    $l = iterator_to_array($it, true);

    array_push($grid_definition, $l);
}
$grid_definition_json = json_encode($grid_definition);

$toolbar_json_interface_configuration = '[
                                {id:"t1", text:"Edit", img:"edit.gif", items:[
                                    {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add"},
                                    {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete",enabled:0}
                                ]},
                                {id:"t2", text:"Export", img:"export.gif", items:[
                                    {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                                    {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                                ]}  
                                ]';
?>
<script type="text/javascript">
    var has_right_exchange_api_configuration_add =<?php echo (($has_right_exchange_api_configuration_add) ? $has_right_exchange_api_configuration_add : '0'); ?>;
    var has_right_exchange_api_configuration_delete =<?php echo (($has_right_exchange_api_configuration_delete) ? $has_right_exchange_api_configuration_delete : '0'); ?>;
    var application_function_id = '<?php echo $application_function_id;?>';

    var grid_definition_json = <?php echo $grid_definition_json; ?>;
    var toolbar_json_interface_configuration = <?php echo $toolbar_json_interface_configuration; ?>;
    $(function () {
        exchange_api_configuration.layout.cells('a').hideMenu();
    })

    exchange_api_configuration.load_form = function(win, tab_id) {
        var is_new = win.getText();
        win.progressOff();
        var tab_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        exchange_api_configuration["inner_tab_layout_" + tab_id] = win.attachLayout("1C");
        if (is_new == 'New') {
            id = '';
        } else {
            id = tab_id;
        }
        load_form_data(id);
    }

    function load_form_data(module_id) {
        load_url_configuration = [];
        load_url_configuration_detail = [];
        var active_tab_id = exchange_api_configuration.tabbar.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        if (has_right_exchange_api_configuration_add) {
            exchange_api_configuration.tabbar.cells(active_tab_id).getAttachedToolbar().enableItem('save')
        }
        exchange_api_configuration.tabbar.cells(full_id)
        var tab_json = '';

        tab_json_string = '[{"id":"tab_general","text":"General","active":"true"},' +
                    '{"id":"tab_detail","text":"Detail","active":"false"}]' +
                    ''
        json_object = JSON.parse(tab_json_string);
        tab_json = '{tabs: ' + tab_json_string + '}';
        exchange_api_configuration["tabs_" + active_object_id] = exchange_api_configuration["inner_tab_layout_" + active_object_id].cells("a").attachTabbar();
        exchange_api_configuration["tabs_" + active_object_id].loadStruct(tab_json);
        exchange_api_configuration["tabs_" + active_object_id].setTabsMode("bottom");

        for (i = 0; i < json_object.length; i++) {
            grid_no = i;
            var grid_label = grid_definition_json[i]["grid_label"];
            var inner_tab_layout_jsob = [
                {
                    id: "a",
                    text: grid_label,
                    header: true,
                    collapse: false,
                    fix_size: [true, null]
                }
            ];
            tab_id = json_object[i].id;
            exchange_api_configuration["inner_tab_layout_" + active_object_id] = exchange_api_configuration["tabs_" + active_object_id].cells(tab_id).attachLayout({pattern: "1C", cells: inner_tab_layout_jsob});
            var grid_name = grid_definition_json[grid_no]["grid_name"];
            cell_name = 'a';
            toolbar_json = toolbar_json_interface_configuration;
            if (i == 0) {
                toolbar_name = 'toolbar_grid_interface_configuration';
                grid_name = 'grid_interface_configuration';
            } else if (i == 1){
                toolbar_name = 'toolbar_grid_interface_configuration_detail';
                grid_name = 'grid_interface_configuration_detail';
            }

            exchange_api_configuration[toolbar_name + active_object_id] = exchange_api_configuration["inner_tab_layout_" + active_object_id].cells('a').attachMenu();
            exchange_api_configuration["inner_tab_layout_" + active_object_id].cells('a').attachStatusBar({
                height: 30,
                text: '<div id="pagingAreaGrid_' +  grid_name + '_' + active_object_id + '"></div>'
            });
            var pagination_div_name = 'pagingAreaGrid_' + grid_name + '_' + active_object_id;
            exchange_api_configuration[toolbar_name + active_object_id].setIconsPath(js_image_path + "dhxmenu_web/");
            exchange_api_configuration[toolbar_name + active_object_id].loadStruct(toolbar_json);
            exchange_api_configuration[toolbar_name + active_object_id].attachEvent('onClick', exchange_api_configuration.grd_toolbar_click);
            if (!has_right_exchange_api_configuration_add) {
                exchange_api_configuration[toolbar_name + active_object_id].setItemDisabled('add');
                exchange_api_configuration[toolbar_name + active_object_id].setItemDisabled('delete');
            }

            exchange_api_configuration[grid_name + active_object_id] = exchange_api_configuration["inner_tab_layout_" + active_object_id].cells(cell_name).attachGrid();
            exchange_api_configuration[grid_name + active_object_id].setImagePath("<?php echo $image_path; ?>dhxtoolbar_web/");
            exchange_api_configuration[grid_name + active_object_id].setHeader(grid_definition_json[grid_no]["column_label_list"]);
            exchange_api_configuration[grid_name + active_object_id].setColumnIds(grid_definition_json[grid_no]["column_name_list"]);
            exchange_api_configuration[grid_name + active_object_id].setColTypes(grid_definition_json[grid_no]["column_type_list"]);
            if (grid_name == 'grid_interface_configuration') {
                exchange_api_configuration[grid_name + active_object_id].attachHeader('#text_filter,#text_filter,#text_filter,#text_filter,#text_filter');
            } else if (grid_name == 'grid_interface_configuration_detail'){
                exchange_api_configuration[grid_name + active_object_id].attachHeader('#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter');
            }
            exchange_api_configuration[grid_name + active_object_id].setInitWidths(grid_definition_json[grid_no]["column_width"]);
            exchange_api_configuration[grid_name + active_object_id].setColSorting(grid_definition_json[grid_no]["sorting_preference"]);
            exchange_api_configuration[grid_name + active_object_id].setColumnsVisibility(grid_definition_json[grid_no]["set_visibility"]);
            exchange_api_configuration[grid_name + active_object_id].setPagingWTMode(true, true, true, true);
            exchange_api_configuration[grid_name + active_object_id].enablePaging(true, 25, 0, pagination_div_name);
            exchange_api_configuration[grid_name + active_object_id].setPagingSkin('toolbar');
            exchange_api_configuration[grid_name + active_object_id].setDateFormat(user_date_format, "%Y-%m-%d");
            exchange_api_configuration[grid_name + active_object_id].enableMultiselect(true);
            exchange_api_configuration[grid_name + active_object_id].enableColumnMove(true);
            exchange_api_configuration[grid_name + active_object_id].enableValidation(true);
            exchange_api_configuration[grid_name + active_object_id].setColValidators(grid_definition_json[grid_no]["validation_rule"]);
            exchange_api_configuration[grid_name + active_object_id].setUserData("", "grid_id", grid_name);
            exchange_api_configuration[grid_name + active_object_id].setUserData("", "grid_label", grid_label);
            exchange_api_configuration[grid_name + active_object_id].init();
            exchange_api_configuration[grid_name + active_object_id].enableHeaderMenu();
            exchange_api_configuration[grid_name + active_object_id].enableColumnAutoSize(true);
            exchange_api_configuration[grid_name + active_object_id].loadOrderFromCookie(grid_name);
            exchange_api_configuration[grid_name + active_object_id].loadHiddenColumnsFromCookie(grid_name);
            exchange_api_configuration[grid_name + active_object_id].enableOrderSaving(grid_name);
            exchange_api_configuration[grid_name + active_object_id].enableAutoHiddenColumnsSaving(grid_name);


            exchange_api_configuration[grid_name + active_object_id].attachEvent("onValidationError",function(id,ind,value){
                var active_tab_id = exchange_api_configuration.tabbar.getActiveTab();
                var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
                var active_tab = exchange_api_configuration["tabs_" + active_object_id].getActiveTab();
                var layout_obj = exchange_api_configuration["tabs_" + active_object_id].cells(active_tab).getAttachedObject();
                var grid_obj = layout_obj.cells(cell_name).getAttachedObject();
                var message = "Invalid Data";
                grid_obj.cells(id,ind).setAttribute("validation", message);
                return true;
            });
            exchange_api_configuration[grid_name + active_object_id].attachEvent("onValidationCorrect",function(id,ind,value){
                var active_tab_id = exchange_api_configuration.tabbar.getActiveTab();
                var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
                var active_tab = exchange_api_configuration["tabs_" + active_object_id].getActiveTab();
                var layout_obj = exchange_api_configuration["tabs_" + active_object_id].cells(active_tab).getAttachedObject();
                var grid_obj = layout_obj.cells(cell_name).getAttachedObject();
                grid_obj.cells(id,ind).setAttribute("validation", "");
                return true;
            });

            exchange_api_configuration[grid_name + active_object_id].attachEvent("onRowSelect", function(id,ind ) {
                var active_tab_id = exchange_api_configuration.tabbar.getActiveTab();
                var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
                var active_tab = exchange_api_configuration["tabs_" + active_object_id].getActiveTab();
                var layout_obj = exchange_api_configuration["tabs_" + active_object_id].cells(active_tab).getAttachedObject();
                var menu_obj = layout_obj.cells(cell_name).getAttachedMenu();
                if (has_right_exchange_api_configuration_delete){
                    menu_obj.setItemEnabled('delete');
                }
            });

            var sql_stmt = grid_definition_json[grid_no]["sql_stmt"];
            var spa_url = sql_stmt.replace("<ID>", active_object_id);
            var param = {
				"sql": spa_url
            };
            param = $.param(param);
            var param_url = js_data_collector_url + "&" + param;


            if (grid_name == 'grid_interface_configuration') {
                var col_configuration_type = exchange_api_configuration[grid_name + active_object_id].getColIndexById('configuration_type');
                var cmb_configuration_type = exchange_api_configuration[grid_name + active_object_id].getColumnCombo(col_configuration_type);
                var combo_configuration_type_sql = {"action":"spa_exchange_api_configuration", "flag":"m"};
                var data = $.param(combo_configuration_type_sql);
                var url = js_dropdown_connector_url + '&' + data;
                cmb_configuration_type.load(url);
				cmb_configuration_type.enableFilteringMode('between');

                col_variable_name = exchange_api_configuration[grid_name + active_object_id].getColIndexById('variable_name');
                cmb_variable_name = exchange_api_configuration[grid_name + active_object_id].getColumnCombo(col_variable_name);
                combo_variable_name_sql = {"action":"spa_exchange_api_configuration", "flag":"l"};
                data = $.param(combo_variable_name_sql);
                url = js_dropdown_connector_url + '&' + data;
                cmb_variable_name.load(url);
				cmb_variable_name.enableFilteringMode('between');
                load_url_configuration[active_object_id] = param_url;

            } else if (grid_name == 'grid_interface_configuration_detail') {
                var col_interface_type = exchange_api_configuration[grid_name + active_object_id].getColIndexById('interface_type');
                var cmb_interface_type = exchange_api_configuration[grid_name + active_object_id].getColumnCombo(col_interface_type);
                var combo_interface_type_sql = {"action":"spa_exchange_api_configuration", "flag":"n"};
                var data = $.param(combo_interface_type_sql);
                var url = js_dropdown_connector_url + '&' + data;
                cmb_interface_type.load(url);
				cmb_interface_type.enableFilteringMode('between');

                var col_import_rule_hash = exchange_api_configuration[grid_name + active_object_id].getColIndexById('import_rule_hash');
                var cmb_import_rule_hash = exchange_api_configuration[grid_name + active_object_id].getColumnCombo(col_import_rule_hash);
                var combo_import_rule_hash_sql = {"action":"spa_exchange_api_configuration", "flag":"o"};
                var data = $.param(combo_import_rule_hash_sql);
                var url = js_dropdown_connector_url + '&' + data;
                cmb_import_rule_hash.load(url);
				cmb_import_rule_hash.enableFilteringMode('between');
				
                var col_security_import_rule_hash = exchange_api_configuration[grid_name + active_object_id].getColIndexById('security_import_rule_hash');
                var cmb_security_import_rule_hash = exchange_api_configuration[grid_name + active_object_id].getColumnCombo(col_security_import_rule_hash);
                cmb_security_import_rule_hash.load(url);
				cmb_security_import_rule_hash.enableFilteringMode('between');
				
				var col_user_role_id = exchange_api_configuration[grid_name + active_object_id].getColIndexById('user_role_ids');
                var cmb_user_role_id = exchange_api_configuration[grid_name + active_object_id].getColumnCombo(col_user_role_id);
                var combo_user_role_id_sql = {"action":"spa_exchange_api_configuration", "flag":"r"};
                var data = $.param(combo_user_role_id_sql);
                var url = js_dropdown_connector_url + '&' + data;
                cmb_user_role_id.load(url);
				cmb_user_role_id.enableFilteringMode('between');

                load_url_configuration_detail[active_object_id] = param_url;

            }
        }
        setTimeout(function () { // To insert data after combo has been loaded in grid
            for (index in load_url_configuration) {
                if (index === 'length' || !load_url_configuration.hasOwnProperty(index)) continue;
                exchange_api_configuration["grid_interface_configuration" + index].loadXML(load_url_configuration[index]);
            }

            for (index in load_url_configuration_detail) {
                if (index === 'length' || !load_url_configuration_detail.hasOwnProperty(index)) continue;
                exchange_api_configuration["grid_interface_configuration_detail" + index].loadXML(load_url_configuration_detail[index]);
            }
        }, 1000);

    }

    exchange_api_configuration.grd_toolbar_click = function(id,zone) {
        var cell_name = 'a';
        var active_tab_id = exchange_api_configuration.tabbar.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        var active_tab = exchange_api_configuration["tabs_" + active_object_id].getActiveTab();
        var active_tab_array = active_tab.split("_");
        var layout_obj = exchange_api_configuration["tabs_" + active_object_id].cells(active_tab).getAttachedObject();
        var grid_obj = layout_obj.cells(cell_name).getAttachedObject();
        var menu_obj = layout_obj.cells(cell_name).getAttachedMenu();
        if (id == 'add') { //when add is clicked.
            var new_id = (new Date()).valueOf();
            new_id = new_id + '_grid';
            if (active_tab_array[1] == 'general')
                grid_obj.addRow(new_id, ["",active_object_id,"","",""]);
            else if (active_tab_array[1] == 'detail')
                grid_obj.addRow(new_id, ["",active_object_id,"","",0,"","","","","","","","","","","",0,0,0]);

            grid_obj.selectRow(grid_obj.getRowIndex(new_id), false, false, true);
            if (has_right_exchange_api_configuration_delete) {
                menu_obj.setItemEnabled('delete');
            }
            grid_obj.forEachRow(function(row){
                grid_obj.forEachCell(row,function(cellObj,ind){
                    grid_obj.validateCell(row,ind)
                });
            });
        }
        else if (id == 'delete') {//when is delete is clicked
            var selectedId = grid_obj.getSelectedRowId();
            if (!selectedId) {
                var message = get_message('VALIDATE_DATA');
                show_messagebox(message);
                return false;
            } else {
                var grid_xml = '';
                var deleted_xml = grid_obj.getUserData("", "delete_xml");
                var del_array = new Array();
                del_array = (selectedId.indexOf(",") != -1) ? selectedId.split(",") : selectedId.split();
                $.each(del_array, function(index, value) {
                    if ((grid_obj.cells(value, 0).getValue() != "") || (grid_obj.getUserData(value, "row_status") != "")) {
                        grid_xml += '<GridRow ';
                        for (var cellIndex = 0; cellIndex < grid_obj.getColumnsNum(); cellIndex++) {
                            grid_xml += grid_obj.getColumnId(cellIndex) + '= "' + grid_obj.cells(value, cellIndex).getValue() + '" ';
                        }

                        grid_xml += '></GridRow>';
                    }
                    grid_obj.deleteRow(value);
                });
                if (deleted_xml)
                    grid_xml = grid_xml + deleted_xml;

                grid_obj.setUserData("", "delete_xml", grid_xml);
                menu_obj.setItemDisabled('delete');
            }
        } else if (id == 'excel') {
            grid_obj.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
        } else if (id == 'pdf') {
            grid_obj.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
        }
    }


    exchange_api_configuration.save_form = function() {
        var active_tab_id = exchange_api_configuration.tabbar.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        // var active_tab = exchange_api_configuration["tabs_" + active_object_id].getActiveTab();
        var layout_obj = exchange_api_configuration["tabs_" + active_object_id].cells('tab_general').getAttachedObject();
        var grid_obj = layout_obj.cells('a').getAttachedObject();
        layout_obj = exchange_api_configuration["tabs_" + active_object_id].cells('tab_detail').getAttachedObject();
        grid_obj_detail = layout_obj.cells('a').getAttachedObject();

        var grid_delete_xml = '<GridXMLDel>' + grid_obj.getUserData("", "delete_xml") + '</GridXMLDel>';
        var grid_delete_xml_detail = '<GridXMLDelDetail>' + grid_obj_detail.getUserData("", "delete_xml") + '</GridXMLDelDetail>';


        var grid_xml = '<GridXML>';
        var grid_xml_detail = '<GridXMLDetail>';
        grid_obj.editStop();
        grid_obj_detail.editStop();
        /*XML for Interface Configuration grid*/
        grid_obj.forEachRow(function(rid) {
            grid_xml += '<GridRow ';
            grid_obj.forEachCell(rid,function(cellObj,ind){
                var column_type = grid_obj.getColType(ind);
                var column_id = grid_obj.getColumnId(ind);
                if (column_type == 'ed' || column_type =='ed_password') {
                    var cell_value = grid_obj.cells(rid, ind).getValue();
                    cell_value = encode_html_entity(cell_value);
                } else {
                    var cell_value = grid_obj.cells(rid, ind).getValue();
                }
                grid_xml += ' ' + column_id + '="' + cell_value + '"';
            });
            grid_xml += '></GridRow>';
        });
        grid_xml += '</GridXML>';

        /*XML for Interface Configuration Detail grid*/
        grid_obj_detail.forEachRow(function(rid) {
            grid_xml_detail += '<GridRow ';
            grid_obj_detail.forEachCell(rid,function(cellObj,ind){
                var column_type = grid_obj_detail.getColType(ind);
                var column_id = grid_obj_detail.getColumnId(ind);
                if (column_type == 'ed' || column_type =='ed_password') {
                    var cell_value = grid_obj_detail.cells(rid, ind).getValue();
                    cell_value = encode_html_entity(cell_value);
                } else {
                    var cell_value = grid_obj_detail.cells(rid, ind).getValue();
                }
                grid_xml_detail += ' ' + column_id + '="' + cell_value + '"';
            });
            grid_xml_detail += '></GridRow>';
        });
        grid_xml_detail += '</GridXMLDetail>';

        grid_xml = '<Root>'
            + grid_xml
            + grid_xml_detail
            + grid_delete_xml
            + grid_delete_xml_detail
            + '</Root>';
        data = {"action": "spa_exchange_api_configuration",
            "flag": "i",
            "interface_id" : active_object_id,
            "xml": grid_xml
        };

        if (grid_obj.getUserData("", "delete_xml") || grid_obj_detail.getUserData("", "delete_xml")) {
            del_msg =  "Some data has been deleted from grid. Are you sure you want to save ?";
            result = adiha_post_data("confirm", data, "", "", "exchange_api_configuration.refresh_grids","",del_msg);
        } else {
            adiha_post_data("return_array", data, "", "", "exchange_api_configuration.save_callback");
        }

    }

    exchange_api_configuration.save_callback = function(result) {
        if (result[0][0] == "Success") {
            dhtmlx.message({
                text:result[0][4],
                expire:1000
            });
        } else {
            dhtmlx.message({
                title:"Alert",
                type:"alert",
                text:result[0][4]
            });
        }
        exchange_api_configuration.refresh_grids();
    }

    exchange_api_configuration.refresh_grids = function() {
        var active_tab_id = exchange_api_configuration.tabbar.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        // var active_tab = exchange_api_configuration["tabs_" + active_object_id].getActiveTab();
        var layout_obj = exchange_api_configuration["tabs_" + active_object_id].cells('tab_general').getAttachedObject();
        var grid_obj = layout_obj.cells('a').getAttachedObject();
        layout_obj = exchange_api_configuration["tabs_" + active_object_id].cells('tab_detail').getAttachedObject();
        grid_obj_detail = layout_obj.cells('a').getAttachedObject();

        var param = {"action": "spa_exchange_api_configuration",
            "flag": "p",
            "interface_id":active_object_id,
            "grid_type": "g"
        };
        param = $.param(param);
        var param_url = js_data_collector_url + "&" + param;
        grid_obj.clearAndLoad(param_url);

        param = {"action": "spa_exchange_api_configuration",
            "flag": "q",
            "interface_id":active_object_id,
            "grid_type": "g"
        };
        param = $.param(param);
        param_url = js_data_collector_url + "&" + param;
        grid_obj_detail.clearAndLoad(param_url);


        grid_obj.setUserData("", "delete_xml", "");
        grid_obj_detail.setUserData("", "delete_xml", "");

    }

    encode_html_entity = function(str) {
        if (!str || str == '')
            return '';
        str = unescape(str.replace(/'/g,"''"));
        str = str.replace(/</g, '&lt;');
        str = str.replace(/>/g, '&gt;');
        str = str.replace(/&/g,"&amp;");
        str = str.replace(/"/g,"&quot;");
        return str;
    }

</script>