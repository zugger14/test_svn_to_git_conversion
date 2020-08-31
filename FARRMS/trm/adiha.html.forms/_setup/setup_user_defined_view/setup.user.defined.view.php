<?php
/**
* Setup user defined view screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
<body>
<?php

$form_namespace = 'setup_user_defined_view';
$function_id = 20009600;

$rights_setup_user_defined_view_id = 20009601;
$rights_setup_user_defined_view_del = 20009602;

list (
    $has_rights_setup_user_defined_view_id,
    $has_rights_setup_user_defined_view_del
    ) = build_security_rights(
    $rights_setup_user_defined_view_id,
    $rights_setup_user_defined_view_del
);

$json = "[
                {
                    id:         'a',
                    text:       ' ',
                    header:     true,
                    collapse:   false,
                    height:     400,
                    width:      325,
                    text: 'Views'
                },
                {
                    id:         'b',
                    text:       'Tabs',
                    header:     false,
                    collapse:   false
                    
                    
                }

            ]";

$menu_json = '[  
                    {id:"t1", text:"Edit", img:"edit.gif", imgdis:"new_dis.gif" ,items:[
                        {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add", enabled:' . $has_rights_setup_user_defined_view_id .'},
                        {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title:"Delete", enabled:false},
                    ]},
                    {id:"t2", text:"Export", img:"export.gif", items:[
                        {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                        {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                    ]},
                    {id: "import_export_item", text: "Import/Export", img: "import.gif", img_disabled: "imp_dis.gif", enabled: 1,
                        items: [
                            {id: "import_item", text: "Import", img: "import.gif", img_disabled: "import_dis.gif", enabled:' . $has_rights_setup_user_defined_view_id .'},
                            {id: "import_as_item", text: "Import As", img: "import.gif", img_disabled: "import_dis.gif", enabled:' . $has_rights_setup_user_defined_view_id .'},
                            {id: "export_item", text: "Export", img: "export.gif", img_disabled: "export_dis.gif", enabled: 0}
                        ]
                    }                     
                    ]';


$view_layout = new AdihaLayout();
echo $view_layout->init_layout('layout', '', '2U', $json, $form_namespace);

$menu_obj = new AdihaMenu();
echo $view_layout->attach_menu_cell('view_menu', 'a');
echo $menu_obj->init_by_attach('view_menu', $form_namespace);
echo $menu_obj->load_menu($menu_json);
echo $menu_obj->attach_event('', 'onClick', $form_namespace . '.menu_click');

$grid_name = 'view_grid';
echo $view_layout->attach_grid_cell($grid_name, 'a');
$grid_view_grid = new GridTable('setup_user_defined_view');
echo $grid_view_grid->init_grid_table($grid_name, $form_namespace);
echo $grid_view_grid->enable_multi_select(true);
echo $grid_view_grid->set_search_filter(true, "");
echo $grid_view_grid->return_init();
echo $grid_view_grid->load_grid_data("EXEC spa_rfx_data_source_dhx @flag='g'");
echo $grid_view_grid->load_grid_functions();
echo $grid_view_grid->attach_event('', 'onRowDblClicked', $form_namespace . '.view_db_clicked');
echo $grid_view_grid->attach_event('', 'onRowSelect', $form_namespace . '.view_row_select');


//$url = $app_form_path . '_reporting/report_manager_dhx/report.manager.dhx.template.php';
//echo $view_layout->attach_url('b', $url);
echo $view_layout->attach_tab_cell('view_tabbar', 'b', '');

echo $view_layout->close_layout();


?>
</body>

<script type="text/javascript">
    var session = "<?php echo $session_id; ?>";
    var php_script_loc_ajax = "<?php echo $app_php_script_loc; ?>";
    var active_tabs = [];

    var has_rights_setup_user_defined_view_id = Boolean('<?php echo $has_rights_setup_user_defined_view_id ?>');
    var has_rights_setup_user_defined_view_del = Boolean('<?php echo $has_rights_setup_user_defined_view_del ?>');
    var has_rights_setup_user_defined_view_export_JSON = true;
    
    
    $(function() {
        setup_user_defined_view.view_tabbar.attachEvent("onTabClose", function(id){
            active_tabs.pop(id);
            return true;
        });

        setup_user_defined_view.view_grid.attachEvent("onSelectStateChanged", function(id){      
            //Enable Disable export item menu for only single selection
            setup_user_defined_view.view_menu.setItemDisabled('export_item');
            if (has_rights_setup_user_defined_view_export_JSON && id != null) {
                if (id.indexOf(',') < 0) {                
                    setup_user_defined_view.view_menu.setItemEnabled('export_item');
                }
            }
        })

        dhxWins = new dhtmlXWindows();
    });
    
    /**
     * Function for Grid Row Double Clicked
     * @param  Integer id   row ID
     */
    setup_user_defined_view.view_db_clicked = function (id) {
        var is_lock = setup_user_defined_view.view_grid.getUserData(id,'is_lock');
        if (is_lock != undefined && is_lock == 1) {
            var param_obj = {
                "param1"  :  id,
                "param2"  :  'u',
                "param3"  :  '1'
            };
            is_user_authorized('setup_user_defined_view.add_tab',param_obj);
        } else
            setup_user_defined_view.add_tab(id,'u','0');
    }

    /**
     * Function for Menu Click
     * @param  Integer id   Menu ID
     */
    setup_user_defined_view.menu_click = function(id) {
        switch(id) {
            case "add":
                setup_user_defined_view.add_tab('','i','0');
                break;
            case "delete":
                var selected_id = setup_user_defined_view.view_grid.getSelectedRowId();
                if (selected_id != null) {
                    var locked_ids = [];

                    var selected_ids_arr = selected_id.split(',');
                    selected_ids_arr.forEach(function(val) {
                        var is_lock = setup_user_defined_view.view_grid.getUserData(val, 'is_lock');
                        is_lock = (is_lock == '') ? '0' : is_lock;
                        locked_ids.push(is_lock);
                    });

                    // If user has selected at least one locked data.
                    if (locked_ids.find('1')) {
                        var param_obj = {
                            "param1"  :  selected_id,
                            "param2"  :  'd',
                            "param3"  :  '1'
                        };
                        is_user_authorized('setup_user_defined_view.remove_view',param_obj);
                    } else {
                        setup_user_defined_view.remove_view(selected_id,'d','0');
                    }
                }
                break;
            case "pdf":
                setup_user_defined_view.view_grid.toPDF(js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                break;
            case "excel":
                setup_user_defined_view.view_grid.toPDF(js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                break;
            
            case "import_item": case "import_as_item":
                if (setup_user_defined_view.import_window != null && setup_user_defined_view.import_window.unload != null) {
                    setup_user_defined_view.import_window.unload();
                    setup_user_defined_view.import_window = w2 = null;
                }
                if (!setup_user_defined_view.import_window) {
                    setup_user_defined_view.import_window = new dhtmlXWindows();
                }

                setup_user_defined_view.new_win = setup_user_defined_view.import_window.createWindow('w2', 0, 0, 670, 325);

                var text = "Import User Defined View";

                setup_user_defined_view.new_win.setText(text);
                setup_user_defined_view.new_win.setModal(true);
                
                var url = app_form_path + '_setup/setup_user_defined_view/setup.user.defined.view.import.ui.php';
                url = url + '?call_from=UserDefinedView&import_type=' + id;
                setup_user_defined_view.new_win.attachURL(url, false, true);
                
                break;

            case "export_item":
                var selected_id = setup_user_defined_view.view_grid.getSelectedRowId();
                var col_id = setup_user_defined_view.view_grid.getColIndexById('id');

                if (selected_id != null) {
                    var selected_ids_arr = selected_id.split(',');
                    selected_ids_arr.forEach(function(val) {
                        var view_id = setup_user_defined_view.view_grid.cells(val, col_id).getValue();
                        var data = {
                            "action"                : "spa_rfx_migrate_data_source_as_json",
                            "flag"                  : "u",
                            "data_source_id"        : view_id,
                            "call_from"             : "UserDefinedView"
                        };
                        var additional_data = {
                            "type": 'return_array'
                        };

                        data = $.param(data) + "&" + $.param(additional_data);
                        $.ajax({
                            type: "POST",
                            dataType: "json",
                            url: js_form_process_url,
                            async: true,
                            data: data,
                            success: function(data) {
                                var status =  data.json[0][0];
                                var file_name = data.json[0][5];
                                if (status == 'Success') {
                                    window.location = php_script_loc_ajax + 'force_download.php?path=dev/shared_docs/temp_Note/'+ file_name;
                                } else {
                                    show_messagebox('Issue while downloading file.');
                                }
                            }
                        }); // End of ajax
                    });
                }
                break;

        }
    }

    /**
     * Delete User Defined View
     * @param  Integer  id               row ID
     * @param  String   flag             Flag
     * @param  Boolean  is_validate      Validated or Not
     */
    setup_user_defined_view.remove_view = function (id, flag, is_validated) {
        var col_id = setup_user_defined_view.view_grid.getColIndexById('id');
        var view_ids = [];
        id = id.split(',');
        id.forEach(function(val) {
            var view_id = setup_user_defined_view.view_grid.cells(val, col_id).getValue();
            view_ids.push(view_id);
        });
        
        confirm_messagebox("Are you sure you want to delete selected datasource?", function() {
            view_ids = view_ids.toString();
            var data = {
                "action": "spa_rfx_data_source_dhx",
                "flag": "d",
                "source_id": view_ids
            };
            adiha_post_data("alert", data, "", "", "setup_user_defined_view.refresh_all_grids", "", "");
        }, function() {});
    }

    /**
     * Add User Defined View Tab
     * @param  Integer  id               row ID
     * @param  String   flag             Flag
     * @param  Boolean  is_validate      Validated or Not
     */
    setup_user_defined_view.add_tab = function (id,flag,is_validated) {
        var view_name = '';
        var view_id = '';
        if (flag == 'u') {
            let myGrid = setup_user_defined_view.view_grid;
            let selected_id = myGrid.getSelectedRowId();
            let col_id = myGrid.getColIndexById('id');
            view_id = myGrid.cells(selected_id, col_id).getValue();
            let name_col = myGrid.getColIndexById('category');
            view_name = myGrid.cells(selected_id, name_col).getValue();
        } else if (flag == 'i') {
            view_id = (new Date()).valueOf();
            view_id = view_id.toString();
            view_name = get_locale_value("New");
        }

        let full_id = "tab_" + view_id;
        let report_name = view_name;
        
        if (full_id == "tab_") {
            setup_user_defined_view.view_tabbar.tabs(full_id).hide();
         }

        if ($.inArray(full_id, active_tabs) == -1) {
            setup_user_defined_view.view_tabbar.addTab(full_id,report_name, null, null, true, true);
            var param_obj_ds ={
                ds_flag: flag,
                data_source_id: view_id
            };
            setup_user_defined_view.view_tabbar.cells(full_id).attachURL("../../_reporting/report_manager_dhx/report.manager.dhx.datasource.php", null, {ds_info_obj: JSON.stringify(param_obj_ds), call_from: "setup_user_defined_view",is_validated:is_validated})
            active_tabs.push(full_id);
        } else {
            setup_user_defined_view.view_tabbar.tabs(full_id).setActive();
        }
    }

    /**
     * Call Back function for User Defined View Save
     * @param  Integer  id               row ID
     * @param  String   mode_value       Mode
     */
    setup_user_defined_view.save_call_back = function (id,mode_value) {
        var sql_param = {
            "sql":"EXEC spa_rfx_data_source_dhx @flag='g'",
            "grid_type":"tg"
            ,"grouping_column":"category,name"
        };
        sql_param = $.param(sql_param);
        var sql_url = js_data_collector_url + "&" + sql_param;
        setup_user_defined_view.view_grid.clearAll();
        setup_user_defined_view.view_grid.load(sql_url, function() {
            let col_id = setup_user_defined_view.view_grid.getColIndexById('id');
            setup_user_defined_view.view_grid.forEachRow(function(row_id) {
                let report_id = setup_user_defined_view.view_grid.cells(row_id, col_id).getValue();
                if (report_id == id) {
                    setup_user_defined_view.view_grid.selectRowById(row_id);
                    if (has_rights_setup_user_defined_view_del)
                        setup_user_defined_view.view_menu.setItemEnabled('delete');
                    setup_user_defined_view.view_grid.openItem(row_id);
                    if (mode_value == 'i') {
                        var active_tab = setup_user_defined_view.view_tabbar.getActiveTab();
                        setup_user_defined_view.view_tabbar.tabs(active_tab).close();
                        setup_user_defined_view.add_tab(id,'u');
                    }
                }
            });

        });
    }

    /**
     * Row select function
     * @param  Integer  id  row ID
     * @param  Integer  Ind Index
     */
    setup_user_defined_view.view_row_select = function (id,ind) {
        if (has_rights_setup_user_defined_view_del)
            setup_user_defined_view.view_menu.setItemEnabled('delete');
    }

    /**
     * Refresh all Grids
     * @param  Array result Return Data Values
     */
    setup_user_defined_view.refresh_all_grids = function(result){
        var recommendation = result[0].recommendation;
        recommendation = recommendation.split(',');
        
        if (result[0].errorcode == 'Success') {
            recommendation.forEach(function(val) {
                if (setup_user_defined_view.view_tabbar.tabs("tab_" + val)) {
                    setup_user_defined_view.view_tabbar.tabs("tab_" + val).close();
                }
            });
            setup_user_defined_view.refresh_grid();
        }
    }

    /**
     * Import from file function to be called from child UI
     * @param  String   file_name File Name
     * @param  String   cpoy_as   Import As Name
     */
    function import_from_file(file_name, copy_as) {                
        var data = {"action": "spa_rfx_migrate_data_source_as_json",
            "flag": "z",
            "json_file_name": file_name,
            "import_as_name" : copy_as,
            "call_from" : "UserDefinedView"
        };
        
        adiha_post_data('return_array', data, '', '', 'setup_user_defined_view.import_from_confirmation', '', '');                 
    }

    /**
     * Call back confirmation function for import_from_file
     * @param  Array return_value Return Data Values
     */
    setup_user_defined_view.import_from_confirmation = function(return_value) {  
        var confirm_type = return_value[0][0];
        var message = return_value[0][4];
        if (confirm_type == 'Error') {
            show_messagebox(message);
            return
        }
        var adiha_type = '';
        var validation = '';
        var file_name = return_value[0][1];
        var copy_as = return_value[0][2];

        if (confirm_type == 'r') {
            validation = message;
            adiha_type = 'confirm';
        } else {
            adiha_type = 'return_array';
        }
        
        setup_user_defined_view.new_win.close();
        data = {"action": "spa_rfx_migrate_data_source_as_json",
                "flag": "y",
                "json_file_name": file_name,
                "import_as_name" : copy_as,
                "call_from" : "UserDefinedView"
            };
        
        adiha_post_data(adiha_type, data, '', '', 'setup_user_defined_view.import_export_call_back', '', validation);                 
    }

    /**
     * Call back confirmation function for import_from_confirmation
     * @param  Array return_value Return Data Values
     */
    setup_user_defined_view.import_export_call_back = function(result) {
        var is_success = result[0][0];
        var msg_req = 'n';

        if (is_success === undefined) {
            is_success = result[0].errorcode;
            message = result[0].message
        } else {
            message = result[0][4];
            msg_req = 'y';
        }

        if (is_success == "Success") {
            if (msg_req == 'y') {
                success_call(message);   
            }
            
            setup_user_defined_view.refresh_grid();
        } else {
            show_messagebox(message);                 
        }
    }
    

</script>
</html> 