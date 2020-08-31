<?php
/**
* Setup user defined table screen
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
$form_namespace = 'setup_user_defined_table';
$function_id = 20003300;
$rights_setup_user_defined_table_iu = 20003301;
$rights_setup_user_defined_table_delete = 20003302;
$rights_setup_user_defined_table_apply_changes = 20003303;
$rights_setup_user_defined_table_import_rule = 20003304;

list (
    $has_rights_setup_user_defined_table_iu,
    $has_rights_setup_user_defined_table_delete,
    $has_rights_setup_user_defined_table_apply_changes,
    $has_rights_setup_user_defined_table_import_rule
    ) = build_security_rights(
    $rights_setup_user_defined_table_iu,
    $rights_setup_user_defined_table_delete,
    $rights_setup_user_defined_table_apply_changes,
    $rights_setup_user_defined_table_import_rule
);

$form_obj = new AdihaStandardForm($form_namespace, $function_id);
$form_obj->define_grid("user_defined_tables", "EXEC spa_user_defined_tables @flag='x', @system=0");
echo $form_obj->init_form('User Defined Tables', 'Detail');
echo $form_obj->define_custom_functions("", "", "udt_delete", "form_load_complete_function", "before_save_action");
echo "setup_user_defined_table.menu.addNewChild('t1', 3, 'create_table', 'Generate Table Script'," . 'true' . ",'import_table_definition.png', 'import_table_definition_dis.png');";
// echo "setup_user_defined_table.menu.addNewChild('t1', 4, 'import_table_definition', 'Import Table Definition'," . 'true' . ",'import_table_definition.png', 'import_table_definition_dis.png');";
echo "setup_user_defined_table.menu.addNewChild('t1', 5, 'import_rule', 'Create/Update Import Rule'," . 'true' . ",'update_import_rule.png', 'update_import_rule_dis.png');";
echo "setup_user_defined_table.menu.addNewChild('t1', 6, 'create_view', 'Create/Update View'," . 'true' . ",'gen_sample_data.gif', 'gen_sample_data_dis.gif');";
echo "setup_user_defined_table.menu.addNewChild('t1', 7, 'create_workflow_mapping', 'Create/Update Workflow Mapping'," . 'true' . ",'gen_sample_data.gif', 'gen_sample_data_dis.gif');";
echo "setup_user_defined_table.menu.addNewSibling('t2', 'process', 'Process', 'process.gif', 'process_dis.gif');";
echo "setup_user_defined_table.menu.addNewChild('process', 1, 'add_to_menu', 'Add to Menu'," . 'true' . ",'add.gif', 'add_dis.gif');";
echo $form_obj->close_form();
?>

<script type="text/javascript">
    var module_type = "<?php echo $module_type; ?>";
    var is_authorized = 0;

    $(function() {
        setup_user_defined_table.menu.addNewSibling('process', 'filter', 'Filter', false, 'filter.gif', 'filter_dis.gif');
        setup_user_defined_table.menu.addCheckbox('child', 'filter', 1, 'show_system_defined', 'Show System Defined', false, false);
        setup_user_defined_table.menu.hideItem('process');
        setup_user_defined_table.menu.hideItem('filter');

        setup_user_defined_table.grid.attachEvent("onRowSelect", function(id,ind) {
            var row_ids = setup_user_defined_table.grid.getSelectedRowId();
            if (row_ids.indexOf(',') == -1) {
                setup_user_defined_table.menu.setItemEnabled('create_table');
                setup_user_defined_table.menu.setItemEnabled('import_rule');
                setup_user_defined_table.menu.setItemEnabled('create_view');
                setup_user_defined_table.menu.setItemEnabled('create_workflow_mapping');
                // setup_user_defined_table.menu.setItemEnabled('import_table_definition');
                setup_user_defined_table.menu.setItemEnabled('add_to_menu');
            } else {
                setup_user_defined_table.menu.setItemDisabled('create_table');
                setup_user_defined_table.menu.setItemDisabled('import_rule');
                setup_user_defined_table.menu.setItemDisabled('create_view');
                setup_user_defined_table.menu.setItemDisabled('create_workflow_mapping');
                // setup_user_defined_table.menu.setItemDisabled('import_table_definition');
                setup_user_defined_table.menu.setItemDisabled('add_to_menu');
            }
        });

        // Disable 'Add to Menu' when no row is selected or more than one row is selected
        setup_user_defined_table.menu.attachEvent("onShow", function(id){
            if (id == 'process') {
                selected_id = setup_user_defined_table.grid.getSelectedRowId();
                system_defined = setup_user_defined_table.menu.getCheckboxState('show_system_defined');
                
                if (selected_id == null || selected_id.indexOf(",") > -1 || !system_defined) {
                    setup_user_defined_table.menu.setItemDisabled('add_to_menu');
                }
            }
        });

        setup_user_defined_table.menu.attachEvent("onClick", function(id, zoneId, cas){
            if (id == 'create_table') {
                setup_user_defined_table.create_table();
            } else if (id == 'import_rule') {
                setup_user_defined_table.import_rule();
            } else if (id == 'create_view') {
                setup_user_defined_table.create_view();
            } else if (id == 'create_workflow_mapping') {
                setup_user_defined_table.create_workflow_mapping();
            } else if (id == 'import_table_definition') {
                setup_user_defined_table.import_table_definition();
            } else if (id == 'add_to_menu') {
                setup_user_defined_table.open_popup_window();
            } else if (id == 'show_system_defined') {
                if (setup_user_defined_table.menu.getCheckboxState(id)) {
                    setup_user_defined_table.show_grid_data(1);
                } else {
                    setup_user_defined_table.show_grid_data(0);
                } 
            }

        });

        // Opens Password window which if correct gives enables additional menus
        if (window.addEventListener) {
            function KeyPress(e) {
                var evtobj = window.event ? event : e;
                if (evtobj.keyCode == 80 && evtobj.ctrlKey && evtobj.altKey && is_authorized == 0) {
                    is_user_authorized('enable_system_menu');
                }
            }
            document.onkeydown = KeyPress;
        }        
    });

    function enable_system_menu() {
        setup_user_defined_table.menu.showItem('process');
        setup_user_defined_table.menu.showItem('filter');
        is_authorized = 1;
    }

    setup_user_defined_table.create_table = function() {
        var selected_row = setup_user_defined_table.grid.getSelectedRowId();
        var udt_id = setup_user_defined_table.grid.cells(selected_row, setup_user_defined_table.grid.getColIndexById('udt_id')).getValue();

        data = {"action": "spa_user_defined_tables",
            "flag": "c",
            "udt_id": udt_id
        };

        adiha_post_data('return_array', data, '', '', 'download_script', '', '');
    }

    setup_user_defined_table.import_table_definition = function() {
        var selected_row = setup_user_defined_table.grid.getSelectedRowId();
        var udt_id = setup_user_defined_table.grid.cells(selected_row, setup_user_defined_table.grid.getColIndexById('udt_id')).getValue();

        data = {"action": "spa_user_defined_tables",
            "flag": "l",
            "udt_id": udt_id
        };

        adiha_post_data('return_array', data, '', '', 'download_script', '', '');
    }

    setup_user_defined_table.form_load_complete_function = function(win, full_id){
        var tab_id = setup_user_defined_table.tabbar.getActiveTab();
        var win = setup_user_defined_table.tabbar.cells(tab_id);
        var object_id = (tab_id.indexOf('tab_') != -1) ? tab_id.replace('tab_', '') : tab_id;
        var tab_obj = win.tabbar[object_id];
        var detail_tabs = tab_obj.getAllTabs();
        var lay_obj = tab_obj.cells(detail_tabs[0]).getAttachedObject();
        var grid_obj = lay_obj.cells('b').getAttachedObject();
        var col_column_nullable = grid_obj.getColIndexById("column_nullable");
        var col_is_primary = grid_obj.getColIndexById("is_primary");
        var col_is_identity = grid_obj.getColIndexById("is_identity");
        var col_column_length = grid_obj.getColIndexById("column_length");
        var col_use_as_filter = grid_obj.getColIndexById("use_as_filter");
        var col_column_type = grid_obj.getColIndexById("column_type");
        var col_rounding = grid_obj.getColIndexById("rounding");
        var col_unique_combination = grid_obj.getColIndexById("unique_combination");
        var col_sequence_no = grid_obj.getColIndexById("sequence_no");
        var col_static_data_type_id = grid_obj.getColIndexById("static_data_type_id");
        var col_custom_validation = grid_obj.getColIndexById("custom_validation");
        var col_effective_date_filter = grid_obj.getColIndexById('effective_date_filter');
        var col_required_filter = grid_obj.getColIndexById('required_filter');
        var col_custom_sql = grid_obj.getColIndexById('custom_sql');
        var col_reference_column = grid_obj.getColIndexById('reference_column');

        // Hide System Defined checkbox by default
        var form_obj = lay_obj.cells('a').getAttachedObject();
        if (is_authorized == 0) {
            form_obj.hideItem('is_system');
        }

        grid_obj.attachEvent("onRowAdded", function(rId){
            grid_obj.cells(rId,col_column_nullable).setValue(0);
            grid_obj.cells(rId,col_is_primary).setValue(0);
            grid_obj.cells(rId,col_is_identity).setValue(0);
            grid_obj.cells(rId,col_use_as_filter).setValue(0);
            grid_obj.cells(rId, col_reference_column).setValue(0);
        });

        grid_obj.attachEvent("onRowCreated", function(rId,rObj,rXml){
            if (grid_obj.cells(rId,col_is_primary).getValue() == 1 || grid_obj.cells(rId,col_is_identity).getValue() == 1) {
                grid_obj.cells(rId,col_column_nullable).setValue(0);
                grid_obj.cells(rId,col_column_nullable).setDisabled(true);
                grid_obj.cells(rId,col_unique_combination).setDisabled(true);
                grid_obj.cells(rId,col_use_as_filter).setDisabled(true);
                grid_obj.cells(rId,col_rounding).setDisabled(true);
                grid_obj.cells(rId,col_sequence_no).setDisabled(true);
                grid_obj.cells(rId,col_static_data_type_id).setDisabled(true);
                grid_obj.cells(rId,col_custom_validation).setDisabled(true);
                grid_obj.cells(rId,col_custom_sql).setDisabled(true);
            } else { /* Enabled either Static Data type Combo or Custom Sql Text Box */
                var val_static_data_type = grid_obj.cells(rId,col_static_data_type_id).getValue();
                var val_static_data_type = val_static_data_type.replace(/&nbsp;/g,"");
                if(val_static_data_type !== "") {
                    grid_obj.cells(rId,col_custom_sql).setDisabled(true);
                } else {
                    grid_obj.cells(rId,col_custom_sql).setDisabled(false);
                }

                if(grid_obj.cells(rId,col_custom_sql).getValue() !== "") {
                    grid_obj.cells(rId,col_static_data_type_id).setDisabled(true);
                } else {
                    grid_obj.cells(rId,col_static_data_type_id).setDisabled(false);
                }
            }

            if (grid_obj.cells(rId,col_column_type).getValue() !== '104303') {
                grid_obj.cells(rId,col_rounding).setDisabled(true);
            }
        });

        grid_obj.attachEvent("onCheck", function(rId,cInd,state){
            if (!state && ((cInd == col_is_primary && grid_obj.cells(rId,col_is_identity).getValue() == 0) || (cInd == col_is_identity && grid_obj.cells(rId,col_is_primary).getValue() == 0))) {
                grid_obj.cells(rId,col_column_nullable).setDisabled(false);
            } else if (cInd == col_is_primary ||cInd == col_is_identity) {
                grid_obj.cells(rId,col_column_nullable).setValue(0);
                grid_obj.cells(rId,col_column_nullable).setDisabled(true);
            }

            column_id = grid_obj.getColumnId(cInd);
            if (column_id == 'effective_date_filter') {
                grid_obj.cells(rId,col_effective_date_filter).setDisabled(false);
            }
        });

        grid_obj.attachEvent("onCellChanged", function(rId,cInd,nValue){
            if (cInd == col_column_length && nValue == 0) {
                grid_obj.cells(rId,col_column_length).setValue('');
            }

            // Restrict User to only uncheck use as filter while effective date filter is checked
            if (grid_obj.getColumnId(cInd) == 'use_as_filter' && nValue == 0) {
                grid_obj.cells(rId,col_effective_date_filter).setValue(0);
                grid_obj.cells(rId,col_required_filter).setValue(0);
            }

            if (grid_obj.getColumnId(cInd) == 'effective_date_filter' && nValue == 1) {
                grid_obj.cells(rId, col_use_as_filter).setValue(1);
                grid_obj.cells(rId, col_required_filter).setValue(1);
            }

            if (grid_obj.getColumnId(cInd) == 'required_filter' && nValue == 1) {
                grid_obj.cells(rId, col_use_as_filter).setValue(1);
            }
            
            /* Start : Enabled either Static Data type Combo or Custom Sql Text Box */
            if (grid_obj.getColumnId(cInd) == 'static_data_type_id' && nValue !== null) {
                var nValue = nValue.replace(/&nbsp;/g,"");
                if(nValue !== "") {
                    grid_obj.cells(rId, col_custom_sql).setValue('');
                    grid_obj.cells(rId,col_custom_sql).setDisabled(true);
                } else {
                    grid_obj.cells(rId,col_custom_sql).setDisabled(false);
                }
            }

            if (grid_obj.getColumnId(cInd) == 'custom_sql') {
                if(nValue !== "") {
                    grid_obj.cells(rId,col_static_data_type_id).setDisabled(true);
                } else {
                    grid_obj.cells(rId,col_static_data_type_id).setDisabled(false);
                }
            }
            /* End : Enabled either Static Data type Combo or Custom Sql Text Box */
        });

        // Set sequence order to avoid showing data in alphabetical order of column name in View User Defined Table
        grid_obj.attachEvent("onRowAdded", function(rId){
            row_index = grid_obj.getRowIndex(rId);

            if (row_index != 0) {
                grid_obj.cells(rId,col_sequence_no).setValue(row_index);
            }
        }); 
    }

    setup_user_defined_table.before_save_action = function() {
        var tab_id = setup_user_defined_table.tabbar.getActiveTab();
        var win = setup_user_defined_table.tabbar.cells(tab_id);
        var object_id = (tab_id.indexOf('tab_') != -1) ? tab_id.replace('tab_', '') : tab_id;
        var tab_obj = win.tabbar[object_id];
        var detail_tabs = tab_obj.getAllTabs();
        var lay_obj = tab_obj.cells(detail_tabs[0]).getAttachedObject();
        var form_obj = lay_obj.cells('a').getAttachedObject();
        var grid_obj = lay_obj.cells('b').getAttachedObject();
        var col_is_primary = grid_obj.getColIndexById("is_primary");
        var col_column_name = grid_obj.getColIndexById("column_name");
        var col_is_identity = grid_obj.getColIndexById("is_identity");
        var count_is_primary = 0;
        var count_is_identity = 0;
        var valid_status = 1;
        var valid_column = true;

        if(!(/^[a-z0-9_]+$/i.test(form_obj.getItemValue('udt_name'))) && form_obj.getItemValue('udt_name')) {
            show_messagebox("Space between words is not allowed for table name");
            return 0;
        }

        if (!form_obj.getItemValue('udt_descriptions')) {
            form_obj.setItemValue('udt_descriptions',form_obj.getItemValue('udt_name'));
        }

        grid_label = grid_obj.getUserData("","grid_label");
        grid_obj.setSerializationLevel(false,false,true,true,true,true);
        grid_obj.clearSelection();
        var grid_status = setup_user_defined_table.validate_form_grid(grid_obj,grid_label);
        if (!grid_status) {
            return 0;
        }
        grid_obj.forEachRow(function(rId){
            if (grid_obj.cells(rId,col_is_primary).getValue() == 1) {
                count_is_primary += 1;
            }

            if (grid_obj.cells(rId,col_is_identity).getValue() == 1) {
                count_is_identity += 1;
            }

            if (grid_obj.cells(rId,col_column_name)) {
                var aaa = grid_obj.cells(rId,col_column_name).getValue();
                if(!(/^[a-z0-9_]+$/i.test(aaa))) {
                    valid_column = false;
                }
            }

        });

        if (!valid_column) {
            show_messagebox("Invalid Column Name.");
            valid_status = 0;
            return 0;
        }

        var count = grid_obj.getRowsNum();
        if (count > 0) {
            if (count_is_primary > 1) {
                show_messagebox("Only one column allowed as primary column.");
                valid_status = 0;
            }

            if (count_is_identity > 1) {
                show_messagebox("Only one column allowed as identity column.");
                valid_status = 0;
            } else if (count_is_identity == 0) {
                show_messagebox("Choose one column as identity column.");
                valid_status = 0;
            }
        }
        if (valid_status == 0) {
            return 0;
        }

    }

    download_script = function(result) {
//		uriContent = "data:application/octet-stream," + encodeURIComponent(result[0][0]);
//		newWindow = window.open(uriContent, 'neuesDokument');
        var ua = window.navigator.userAgent;
        var msie = ua.indexOf("MSIE ");
        var blob = null;
        var file_name = result[0].hasOwnProperty(1) ? result[0][1] : 'table.txt';

        if (msie > 0|| !!navigator.userAgent.match(/Trident.*rv\:11\./)) { // Code to download file for IE
            if ( window.navigator.msSaveOrOpenBlob && window.Blob ) {
                blob = new Blob( [result[0][0]], { type: "text/csv;charset=utf-8;" } );
                navigator.msSaveOrOpenBlob(blob, file_name);
            }
        }
        else { // Code to download file for other browser
            blob = new Blob([result[0][0]],{type: "text/csv;charset=utf-8;"});
            var link = document.createElement("a");
            if (link.download !== undefined) {
                var url = URL.createObjectURL(blob);
                link.setAttribute("href", url);
                link.setAttribute("download", file_name);
                link.style = "visibility:hidden";
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);
            }
        }
    }

    setup_user_defined_table.import_rule = function() {
        var selected_row = setup_user_defined_table.grid.getSelectedRowId();
        var udt_id = setup_user_defined_table.grid.cells(selected_row, setup_user_defined_table.grid.getColIndexById('udt_id')).getValue();

        data = {"action": "spa_user_defined_tables",
            "flag": "i",
            "udt_id": udt_id
        };

        adiha_post_data('alert', data, '', '', '', '', '');
    }

    setup_user_defined_table.create_view = function() {
        var selected_row = setup_user_defined_table.grid.getSelectedRowId();
        var udt_id = setup_user_defined_table.grid.cells(selected_row, setup_user_defined_table.grid.getColIndexById('udt_id')).getValue();

        data = {
            "action": "spa_user_defined_tables",
            "flag": "v",
            "udt_id": udt_id
        };

        adiha_post_data('alert', data, '', '', '', '', '');
    }
    
    setup_user_defined_table.create_workflow_mapping = function() {
        var selected_row = setup_user_defined_table.grid.getSelectedRowId();
        var udt_id = setup_user_defined_table.grid.cells(selected_row, setup_user_defined_table.grid.getColIndexById('udt_id')).getValue();
        udt_id =  udt_id * -1;
		
        data = {
            "action": "spa_workflow_module_event_mapping",
            "flag": "z",
            "module_id": udt_id
        };

        adiha_post_data('alert', data, '', '', '', '', '');
    }

    setup_user_defined_table.create_view_callback = function(result) {
        if (result[0].errorcode == "Success") {
            /*dhtmlx.message({
                text:result[0].message,
                expire:1000
            });*/
            location.reload();
        }/* else {
            dhtmlx.message({
                title:"Alert",
                type:"alert",
                text:result[0].message
            });
        }*/
    }  

    setup_user_defined_table.udt_delete = function() {
        var udt_id_index = setup_user_defined_table.grid.getColIndexById('udt_id');
        var udt_ids = [];
        var selected_row = setup_user_defined_table.grid.getSelectedRowId();
        selected_row = selected_row.split(',');

        selected_row.forEach(function(val) {
            var udt_id = setup_user_defined_table.grid.cells(val, udt_id_index).getValue();
            udt_ids.push(udt_id);
        });

        udt_ids = udt_ids.toString();

        var delete_sp_string = "EXEC spa_user_defined_tables @flag='r', @udt_id='" + udt_ids + "'";
        var data = {"sp_string": delete_sp_string};
        adiha_post_data('confirm', data, '', '', 'setup_user_defined_table.create_view_callback', '', '');
    }
     
    setup_user_defined_table.open_popup_window = function() {
        dhxWins = new dhtmlXWindows();
        var is_win = dhxWins.isWindow('w1');
        selected_id = setup_user_defined_table.grid.getSelectedRowId();
        udt_id = setup_user_defined_table.grid.cells(selected_id, 0).getValue();
        udt_name = setup_user_defined_table.grid.cells(selected_id, 2).getValue();
        var product_category;

        if (module_type == 'trm')
            product_category = 10000000;
        else if (module_type == 'fas')
            product_category = 13000000;
        else if (module_type == 'rec')
            product_category = 14000000;
        else if (module_type == 'sec')
            product_category = 15000000;
        param = js_php_path + 'arrange.menu.template.php?is_pop=true' + '&call_from=user_defined_table' + '&product_category=' + product_category + '&menu_id=' + udt_id + '&menu_name=' + udt_name + '&app_function_id=' + 20003400;
        text = 'Manage Menu (' + udt_name + ')';
        if (is_win == true) {
            w1.close();
        }
        w1 = dhxWins.createWindow("w1", 0, 0, 700, 500);
        w1.centerOnScreen();
        w1.setText(text);
        w1.setModal(true);
        w1.denyMove();
        w1.denyResize();
        w1.button('minmax').hide();
        w1.button('park').hide();
        w1.attachURL(param, false, true);
    }  

    setup_user_defined_table.show_grid_data = function(system_defined) {
        if (system_defined == 1) {
            // Send any thing as string for xml_data except is should not be null
            var sql_param = {
                "sql": "EXEC spa_user_defined_tables @flag='x', @system=1"
            };
        } else {
            var sql_param = {
                "sql": "EXEC spa_user_defined_tables @flag='x', @system=0"
            };
        }
        sql_param = $.param(sql_param);
        var sql_url = js_data_collector_url + "&" + sql_param;
        var grid_id = setup_user_defined_table.grid.getUserData("", "grid_id");
        var grid_obj = setup_user_defined_table.grid.getUserData("", "grid_obj");
        var grid_label = setup_user_defined_table.grid.getUserData("", "grid_label");
        
        setup_user_defined_table.grid.clearAll();

        if (grid_id != null) {
            setup_user_defined_table.grid.setUserData("", "grid_id", grid_id);
            setup_user_defined_table.grid.setUserData("", "grid_obj", grid_obj);
            setup_user_defined_table.grid.setUserData("", "grid_label", grid_label);
        }

        setup_user_defined_table.grid.load(sql_url, function(){
            setup_user_defined_table.grid.filterByAll();
        });
    }

</script>