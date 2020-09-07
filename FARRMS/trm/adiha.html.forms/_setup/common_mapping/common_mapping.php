<?php
/**
* Common_mapping screen
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
    $function_ids = get_sanitized_value($_GET['function_ids'] ?? '');
    $primary_column_value = get_sanitized_value($_GET['primary_column_value'] ?? '');
    $active_tab = null;

    $func_id = isset($_GET['function_id']) ? strtolower($_GET['function_id']) : null;

    if ($func_id != null) {
        // To do resolve privilege
        $privilege_sql = "EXEC spa_arrange_setup_menu @flag='a', @xml='<Root><Data function_id=\"" . $func_id . "\" call_from=\"generic_mapping\"></Data></Root>'";
        $result = readXMLURL2($privilege_sql);
        foreach ($result as $row) {
            // Get active tab id
            if (is_int($row["active_tab_id"]) && $active_tab == null) {
                $active_tab = $row["active_tab_id"];
            }
            // Get Privilege
            if (strpos(strtolower($row["function_name"]), 'add') !== false) {
                $rights_generic_mapping_iu = $row["function_id"];
            }
        }
    } else {
        $rights_generic_mapping_iu = 13102010;
    }   

    list (
       $has_rights_generic_mapping_iu
    ) = build_security_rights (
       $rights_generic_mapping_iu
    ); 
    
    $layout = new AdihaLayout();
    $json = '[
            {
                id:             "a",
                    text:           "Mapping Tables",
                header:         true,
                width:          350,
                height:         500,
                collapse:       false,
                    fix_size:       [false,null],
                    undock:         true
            },
            {
                id:             "b",
                text:           "Generic Mapping Detail",
                height:         450,
                header:         true,
                collapse:       false,
                fix_size:       [false,null]
            }
        ]';
    $layout_name = 'generic_mapping';
    $form_name = 'Generic_Mapping';
    echo $layout->init_layout($layout_name, '', '2U', $json, $form_name);
    
    //attaching menu
    $menu_name = 'generic_map';
    $menu_namespace = 'toolbar_generic_map';

    $menu_json = '[
                    {id:"t1", text:"Export", img:"export.gif", items:[
                    {id:"excel", img:"excel.gif", imgdis:"excel_dis.gif", text:"Excel", title:"Excel"},
                    {id:"pdf", img:"pdf.gif", text:"PDF", title:"PDF"}
                    ]},
                  {id:"import_export", text:"Import/Export Mapping", img:"export.gif", items:[
                    {id:"import_generic_mapping", text:"Import", img:"import.gif", imgdis:"import_dis.gif" },
                    {id:"import_generic_mapping_as", text:"Import As", img:"import.gif", imgdis:"import_dis.gif" },
                    {id:"export_generic_mapping", text:"Export", img:"export.gif", imgdis:"export_dis.gif", enabled :0}
                    ]}
              ]';
              //{id:"export_generic_mapping_copy_as", text:"Export As", img:"export.gif", imgdis:"export_dis.gif", enabled :0}
    echo $layout->attach_menu_layout_cell($menu_name, 'a', $menu_json, $form_name.'.grid_export');
    echo $layout->attach_status_bar("a", true);

    //Attaching Grid 
    $generic_mapping_grid = new AdihaGrid();
    $grid_name = 'grd_general_mapping';
    echo $layout->attach_grid_cell($grid_name, 'a');

    if ($func_id != null) {
        $sp_url = "EXEC spa_generic_mapping_header @flag='s', @mapping_table_id='" . $active_tab . "'";
    } else {
        $sp_url = "EXEC spa_generic_mapping_header @flag='s', @function_ids='" . $function_ids . "'";
    }

    //$layout->attach_search_textbox('layout', 'a');
    echo $generic_mapping_grid->init_by_attach($grid_name, $form_name);
    echo $generic_mapping_grid->set_header('ID, Mapping Table, System Defined');
        echo $generic_mapping_grid->set_widths('150,200,150');
    echo $generic_mapping_grid->set_search_filter(false, "#numeric_filter,#text_filter,#text_filter");
    echo $generic_mapping_grid->set_column_types('ro_int,ro,ro');
    echo $generic_mapping_grid->set_sorting_preference('int,str,str');
    echo $generic_mapping_grid->set_columns_ids('mapping_table_id,mapping_table,system_defined');
    echo $generic_mapping_grid->hide_column(0);
    echo $generic_mapping_grid->attach_event('', 'onRowDblClicked', 'create_tab');
    echo $generic_mapping_grid->attach_event('', 'onRowSelect', 'enabled_button');
    echo $generic_mapping_grid->enable_paging(50, 'pagingArea_a', 'true');
    echo $generic_mapping_grid->return_init();
    echo $generic_mapping_grid->load_grid_data($sp_url);

    $tab_name1 = 'cell_a_tab';
    $json_tab1 = '[]';
    
    echo $layout->attach_tab_cell($tab_name1, 'b', $json_tab1);
    echo $layout->close_layout();
    ?>
    <script type="text/javascript">
        var has_rights_generic_mapping_iu = Boolean('<?php echo $has_rights_generic_mapping_iu; ?>');
        var delete_row = [];
        var data_deleted = 0; 
        var is_authorized = 0;
        var module_type = "<?php echo $module_type; ?>";
        var func_id = "<?php echo $func_id; ?>";
        var active_tab = "<?php echo $active_tab; ?>";

        $(function() {
            Generic_Mapping.generic_map.addNewSibling('t1', 'process', 'Process', false, 'process.gif', 'process_dis.gif');
            Generic_Mapping.generic_map.addNewChild('process', 1, 'add_to_menu', 'Add to Menu', true, 'add.gif', 'add_dis.gif');
            Generic_Mapping.generic_map.addNewSibling('process', 'filter', 'Filter', false, 'filter.gif', 'filter_dis.gif');
            Generic_Mapping.generic_map.addCheckbox('child', 'filter', 1, 'show_system_defined', 'Show System Defined', false, false);
            Generic_Mapping.generic_map.hideItem('process');
            Generic_Mapping.generic_map.hideItem('filter');

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

            Generic_Mapping.generic_map.attachEvent("onClick", function(id, zoneId, cas){ 
                switch (id) {
                    case 'add_to_menu':
                        Generic_Mapping.manage_menu_items();
                        break;
                    case 'show_system_defined':
                        var is_checked = Generic_Mapping.generic_map.getCheckboxState('show_system_defined');
                        
                        if (is_checked) {
                            var sql_param = {
                                "flag": "s",
                                "action": "spa_generic_mapping_header",
                                "is_system": '1'
                            };
                        } else {
                            var sql_param = {
                                "flag": "s",
                                "action": "spa_generic_mapping_header"
                            };
                        }

                        sql_param = $.param(sql_param);
                        var sql_url = js_data_collector_url + "&" + sql_param;

                        Generic_Mapping.grd_general_mapping.clearAll();
                        Generic_Mapping.grd_general_mapping.load(sql_url);
                        break;
                }
            });

            Generic_Mapping.generic_map.attachEvent("onShow", function(id){
                if (id == 'process') {
                    selected_id = Generic_Mapping.grd_general_mapping.getSelectedRowId();
                    col_ind_system_defined = Generic_Mapping.grd_general_mapping.getColIndexById("system_defined");
                    system_defined = Generic_Mapping.grd_general_mapping.cells(selected_id, col_ind_system_defined).getValue() == 'Yes' ? true : false;

                    if (selected_id != null && system_defined && selected_id.indexOf(",") == -1) {
                        Generic_Mapping.generic_map.setItemEnabled('add_to_menu');
                    } else {
                        Generic_Mapping.generic_map.setItemDisabled('add_to_menu');
                    }
                }
            });

            if (func_id != '') {
                Generic_Mapping.generic_mapping.cells("a").collapse();
                Generic_Mapping.grd_general_mapping.attachEvent("onXLE", function(grid_obj,count){
                    var primary_value = grid_obj.findCell(active_tab, 0, true);
                    var r_id = primary_value.toString().substring(0, primary_value.toString().indexOf(","));
                    grid_obj.selectRowById(r_id,false,true,true);
                    create_tab(r_id, 0, 0, 0, 0);
                });
            }
        });

        function enable_system_menu() {
            Generic_Mapping.generic_map.showItem('process');
            Generic_Mapping.generic_map.showItem('filter');
            is_authorized = 1;
        }

        function get_message(code) {
            var active_tab_id = Generic_Mapping.cell_a_tab.getActiveTab();
            var grid_name = Generic_Mapping.cell_a_tab.cells(active_tab_id).getText();
            switch (code) {
                case 'SAVE_CONFIRM':
                    var return_msg = get_locale_value('Some data has been deleted from ' + grid_name + ' grid. Are you sure you want to save?');
                    return return_msg;
                break;
            }
        }
        
        function create_tab() {
            var selected_row_id = Generic_Mapping.grd_general_mapping.getSelectedRowId();
            selected_item_id = Generic_Mapping.grd_general_mapping.cells(selected_row_id,0).getValue();
            var selected_item = Generic_Mapping.grd_general_mapping.cells(selected_row_id,1).getValue();
            var tab_id_array = Generic_Mapping.cell_a_tab.getAllTabs();
                                    
            delete_row[selected_item_id] = new Array();
            
            if ($.inArray(selected_item_id, tab_id_array) == -1) {
                Generic_Mapping.cell_a_tab.addTab(selected_item_id, selected_item, null, null, true, true);
                var win = Generic_Mapping.cell_a_tab.cells(selected_item_id);
                        
                // attach toolbar
                Generic_Mapping.toolbar = win.attachMenu();
                Generic_Mapping.toolbar.setIconsPath(js_image_path+"dhxmenu_web/");
                Generic_Mapping.toolbar.loadStruct([
                                        {id:"save", text:"Save", img: "save.gif", imgdis:"save_dis.gif", title: "Save", enabled: has_rights_generic_mapping_iu},
                                        {id:"t1", text:"Edit", img:"edit.gif", items:[
                                                {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add", enabled: has_rights_generic_mapping_iu},
                                                {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete", enabled: false}
                                        ]},
                                        {id:"t2", text:"Export", img:"export.gif", items:[
                                            {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                                            {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                                        ]}                                        
                                        ]);
                                        
                Generic_Mapping.toolbar.attachEvent("onClick", Generic_Mapping.menu_onClick);
                                                     
                //loading grid header
                var sp_string = "EXEC spa_generic_mapping_header 'm', " + selected_item_id;
                
                var data_for_post = { "sp_string": sp_string };  
                
                adiha_post_data('return_json', data_for_post, 's', 'e', 'ajx_call_back_grid_header', '', '');
            } else {
                Generic_Mapping.cell_a_tab.tabs(selected_item_id).setActive();
            }

            Generic_Mapping.generic_mapping.cells("b").attachStatusBar({
                        height : 30,
                        text : '<div id="pagingArea_b"></div>'
                    });
            
            var active_tab_id = Generic_Mapping.cell_a_tab.getActiveTab(); 
            var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;

            Generic_Mapping["grd_inner_obj_" + active_tab_id].setPagingWTMode(true,true,true,[10,20,30,40,50,60,70,80,90,100]);
            Generic_Mapping["grd_inner_obj_" + active_tab_id].enablePaging(true, 50, 0, 'pagingArea_b');
            Generic_Mapping["grd_inner_obj_" + active_tab_id].setPagingSkin('toolbar');            
        }

        Generic_Mapping.menu_onClick = function(id) {      
            var active_tab_id = Generic_Mapping.cell_a_tab.getActiveTab();           
            switch(id) {
                case "add":
                    var selected_row_id = Generic_Mapping.grd_general_mapping.getSelectedRowId();
                    var tab_name = Generic_Mapping.cell_a_tab.cells(active_tab_id).getText();
                    var get_grid_obj = Generic_Mapping.cell_a_tab.cells(active_tab_id).getAttachedObject();
                    var count = get_grid_obj.getRowsNum();

                    if (tab_name == "Flow Optimization Mapping") {
                        if (count > 0 && 1==2) {
                          show_messagebox("Only one sub book can be mapped at once.");
                          break;
                        }
                    }                         
                     
                    var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
                    var newId = (new Date()).valueOf();
                    var system_defined = Generic_Mapping.grd_general_mapping.cells(selected_row_id,2).getValue(); 
                                        
                    Generic_Mapping["grd_inner_obj_" + active_tab_id].addRow(newId,"");
                    Generic_Mapping["grd_inner_obj_" + active_tab_id].selectRowById(newId);     
                    
                    Generic_Mapping["grd_inner_obj_" + active_tab_id].forEachRow(function(row){
                        Generic_Mapping["grd_inner_obj_" + active_tab_id].forEachCell(row,function(cellObj,ind){
                            Generic_Mapping["grd_inner_obj_" + active_tab_id].validateCell(row,ind)
                        });
                    });
                    
                    Generic_Mapping["grd_inner_obj_" + active_tab_id].forEachCell(newId,function(cellObj,ind){
                        if(Generic_Mapping["grd_inner_obj_" + active_tab_id].getColType(ind) === 'time') {
                                  Generic_Mapping["grd_inner_obj_" + active_tab_id].cells(newId,ind).setValue('0');  
                        }                                
                    }); 
                    break;
                case "delete":
                    var value_ids = [];
                    var grid_object = Generic_Mapping["grd_inner_obj_" + active_tab_id];

                    var del_ids = grid_object.getSelectedRowId();
                    del_ids = del_ids.split(',');
                    del_ids.forEach(function(val) {
                        var value_id = grid_object.cells(val, '0').getValue();
                        value_ids.push(value_id);
                    });
                    value_ids = value_ids.toString();

                    if (value_ids == '') {
                        grid_object.deleteSelectedRows();
                        return;    
                    }
                    
                    var delete_row_len = delete_row[active_tab_id].length; 
                    //alert(delete_row_len);
                    delete_row[active_tab_id][delete_row_len] = value_ids;
                    
                    data_for_post = { "action": "spa_generic_mapping_header", 
                                     "flag": "d", 
                                     "values_id": value_ids}
                                     
                    grid_object.deleteSelectedRows();
                    data_deleted = 1;
                    set_custom_report_template_menu_disabled('delete', false);
                    break;
                case "save":
                    var tab_id_array = Generic_Mapping.cell_a_tab.getActiveTab();

                    var ps_xml = '<Root>'
                    grid_obj = Generic_Mapping.cell_a_tab.cells(active_tab_id).getAttachedObject();
                    grid_obj.clearSelection();
                                        
                    // var ids = grid_obj.getChangedRows(true);
                    var ids = grid_obj.getAllRowIds();
                    var status = true;
                                          
                    var deleting_ids = delete_row[tab_id_array].toString();                         
                    
                    if (ids != "") {
                        grid_obj.setSerializationLevel(false, false, true, true, true, true);
                        var grid_status=true;
                        var changed_ids = new Array();
                        changed_ids = ids.split(",");
                        
                        if (grid_status) {
                            $.each(changed_ids, function(index, value) {
                                grid_obj.setUserData(value, "row_status", "new row");
                                ps_xml = ps_xml + "<PSRecordset ";
                                ps_xml += 'mapping_table_id="' + active_tab_id + '"';
                                
                                for (var cellIndex = 0; cellIndex < grid_obj.getColumnsNum(); cellIndex++) {
                                    if(grid_obj.getColType(cellIndex) == 'combo') {
                                        if(grid_obj.cells(value,cellIndex).getValue() != '') {
                                            var dhxCombo = grid_obj.getColumnCombo(cellIndex);
                                            var selected_option = dhxCombo.getOption(grid_obj.cells(value,cellIndex).getValue());
                                            
                                            if(selected_option == null) {
                                                var column_text = grid_obj.getColLabel(cellIndex);
                                                error_message = "Data Error in <b>Generic Mapping</b> grid. Please check the data in column <b>" + column_text + "</b> and resave.";
                                                show_messagebox(error_message);
                                                status = false;
                                            }
                                        }                                                                   
                                    }

                                    // Changes date to sql format
                                    if (grid_obj.getColType(cellIndex) == 'dhxCalendarA') {
                                        var selected_date = grid_obj.cells(value, cellIndex).getValue();
                                        var data = {"action" : "(\'select dbo.FNAClientToSqlDate(''" + selected_date + "'') AS sql_date\')"};
                                        data = $.param(data) + "&" + $.param({"type": "return_json"});

                                        $.ajax({
                                            type: "POST",
                                            dataType: "json",
                                            url: js_form_process_url,
                                            async: false,
                                            data: data,
                                            success: function(data) {
                                                var response_data = data["json"];
                                                new_date = response_data[0].sql_date; 
                                                
                                                (function() {
                                                    ps_xml = ps_xml + " " + 'clm' + cellIndex + '_value' + '="' + new_date + '"';
                                                }) ();
                                            }
                                        });
                                        continue;
                                    }
                                    
                                    if (grid_obj.cells(value, cellIndex).getValue() == 'undefined') {
                                        ps_xml = ps_xml + " " + 'clm' + cellIndex + '_value' + '="NULL"';
                                        continue;
                                    }
                                    var cell_values = grid_obj.cells(value,cellIndex).getValue();
                                    //cell_values = cell_values.replace(/'/g, "''");
                                    
                                    ps_xml = ps_xml + " " + 'clm' + cellIndex + '_value' + '="' + cell_values + '"';
                                }
                                ps_xml = ps_xml + " ></PSRecordset> ";
                            });                            

                            set_custom_report_template_menu_disabled('delete', false);
                            
                        } else {
                            status = false;
                        };
                    }
                       
                    ps_xml += "</Root>";

                    set_custom_report_template_menu_disabled('delete', false);
                    Generic_Mapping.cell_a_tab.cells(active_tab_id).getAttachedMenu().setItemDisabled('save');
                    data_for_post = { "action": "spa_generic_mapping_header", 
                                     "flag": "i", 
                                     "mapping_table_id": active_tab_id,
                                     "xml_value_insert_update": ps_xml,
                                     "deleting_ids": deleting_ids
                                 }
                                  if(data_for_post) {
                                    if(has_rights_generic_mapping_iu) {
                                        Generic_Mapping.cell_a_tab.cells(active_tab_id).getAttachedMenu().setItemEnabled('save');
                                    }
                                 }
                                
                      if (status) {
                        if (data_deleted == 0) {
                            adiha_post_data('alert', data_for_post, '', '', 'Generic_Mapping.refresh_grid_detail');    
                        } else {
                            adiha_post_data('confirm-warning', data_for_post, '', '', 'Generic_Mapping.refresh_grid_detail', '', get_message('SAVE_CONFIRM'));
                            
                        }
                    }               
                    break;
                case "excel":
                    Generic_Mapping["grd_inner_obj_" + active_tab_id].toExcel('<?php echo $app_php_script_loc; ?>' + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                    break;
                case "pdf":
                    Generic_Mapping["grd_inner_obj_" + active_tab_id].toPDF('<?php echo $app_php_script_loc; ?>' + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                    break;
            }
        }

        Generic_Mapping.refresh_grid_detail = function() {
            var primary_column_value = '<?php echo $primary_column_value; ?>';
            data_deleted = 0; 
            var active_tab_id = Generic_Mapping.cell_a_tab.getActiveTab();
            if(has_rights_generic_mapping_iu) {
                Generic_Mapping.cell_a_tab.cells(active_tab_id).getAttachedMenu().setItemEnabled('save');
            }
            if (response_data[0].errorcode == 'Error') return;//response_data[0] is defined in function adiha_post_data
            
            var sp_url = {
                "action": "spa_generic_mapping_header",
                "flag": "a",
                "mapping_table_id": active_tab_id,
				"primary_column_value": primary_column_value
            };
         
            sp_url = $.param(sp_url);
            var data_url = js_data_collector_url + "&" + sp_url;       
            Generic_Mapping["grd_inner_obj_" + active_tab_id].clearAll();
            Generic_Mapping["grd_inner_obj_" + active_tab_id].loadXML(data_url);             
        } 
               
        Generic_Mapping.grid_export = function(id) {
             switch(id) {
                case "excel":
                    Generic_Mapping.grd_general_mapping.toExcel('<?php echo $app_php_script_loc; ?>' + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                    break;
                case "pdf":
                    Generic_Mapping.grd_general_mapping.toPDF('<?php echo $app_php_script_loc; ?>' + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php'); 
                    break;
                case "import_generic_mapping":
                    if (Generic_Mapping.import_window != null && Generic_Mapping.import_window.unload != null) {
                        Generic_Mapping.import_window.unload();
                        Generic_Mapping.import_window = w2 = null;
                    }
                    if (!Generic_Mapping.import_window) {
                        Generic_Mapping.import_window = new dhtmlXWindows();
                    }

                    Generic_Mapping.new_win = Generic_Mapping.import_window.createWindow('w2', 0, 0, 670, 325);

                    var text = "Import Generic Mapping";

                    Generic_Mapping.new_win.setText(text);
                    Generic_Mapping.new_win.setModal(true);

                    var url = app_form_path + '_compliance_management/setup_rule_workflow/manage.alert.workflow.import.export.php';
                    url = url + '?flag=import_mapping&call_from=generic_mapping';
                    Generic_Mapping.new_win.attachURL(url, false, true);
                    break;      
                case 'import_generic_mapping_as' :
                    if (Generic_Mapping.import_window != null && Generic_Mapping.import_window.unload != null) {
                            Generic_Mapping.import_window.unload();
                            Generic_Mapping.import_window = w2 = null;
                        }
                        if (!Generic_Mapping.import_window) {
                            Generic_Mapping.import_window = new dhtmlXWindows();
                        }

                        Generic_Mapping.new_win = Generic_Mapping.import_window.createWindow('w2', 0, 0, 670, 325);

                        var text = "Import Generic Mapping";

                        Generic_Mapping.new_win.setText(text);
                        Generic_Mapping.new_win.setModal(true);

                        var url = app_form_path + '_compliance_management/setup_rule_workflow/manage.alert.workflow.import.export.php';
                        url = url + '?flag=import_mapping&call_from=generic_mapping&copy_field_req=1';
                        Generic_Mapping.new_win.attachURL(url, false, true);
                        break;      

                    break;         
                case "export_generic_mapping":
                    var selected_row_id = Generic_Mapping.grd_general_mapping.getSelectedRowId();
                    var generic_mapping_ids = Generic_Mapping.grd_general_mapping.cells(selected_row_id,0).getValue();
                    var selected_item = Generic_Mapping.grd_general_mapping.cells(selected_row_id,1).getValue();                        
                    
                    var data = '';
                    data = {"action": "spa_generic_mapping_export_import",
                            "flag": "export_rule",
                            "generic_mapping_ids": generic_mapping_ids
                    };
                    adiha_post_data('return_array', data, '', '', 'Generic_Mapping.download_script', '', '');
                    break;
                case "export_generic_mapping_copy_as":
                    open_copy_as_param_popup();
                    break;
                    
            }
        }   

        function open_copy_as_param_popup() {
            var label_width = parseInt(ui_settings['field_size']) + parseInt(ui_settings['offset_left']);
            var copy_as_form_data = [
                {type: "settings", labelWidth: label_width, inputWidth: ui_settings['field_size'], position: "label-top", offsetLeft: ui_settings['offset_left']},
                {type: "input", name: "copy_as", label: "Copy As", 'required':true, id: "copy_as"},                     
                {type: "button", value: "Ok", img: "tick.png"}
            ];

            copy_as_charges_popup = new dhtmlXPopup({ toolbar: Generic_Mapping.generic_map, id: "export_generic_mapping_copy_as" });

            var copy_as_att_form = copy_as_charges_popup.attachForm(copy_as_form_data);

            copy_as_charges_popup.attachEvent("onBeforeHide", function(type, ev, id){
                if (type == 'click' || type == 'esc') {
                    copy_as_charges_popup.hide();
                }  
            });
            
            var height = 50;
            copy_as_charges_popup.show(200,height+20,45,45);

            copy_as_att_form.attachEvent("onButtonClick", function() {
                var copy_as = copy_as_att_form.getItemValue('copy_as');
                if (!copy_as) {
                    show_messagebox("Copy As field cannot be null.");
                } else {
                    copy_as_charges_popup.hide();
                  
                    var selected_row_id = Generic_Mapping.grd_general_mapping.getSelectedRowId();
                    var generic_mapping_ids = Generic_Mapping.grd_general_mapping.cells(selected_row_id,0).getValue();
                    var data = '';

                    data = {"action": "spa_generic_mapping_export_import",
                            "flag": "export_rule_copy_as",
                            "generic_mapping_ids": generic_mapping_ids,
                            "copy_as" : copy_as
                    };
                    adiha_post_data('return_array', data, '', '', 'Generic_Mapping.download_script', '', '');                      
                }                
            });
        } 

        function import_from_file(file_name, copy_as) {        
            var data = {"action": "spa_generic_mapping_export_import",
                        "flag": "confirm_override",
                        "import_file_name": file_name,
                        "copy_as" : copy_as
                    };
           
            adiha_post_data('return_array', data, '', '', 'Generic_Mapping.import_from_confirmation', '', '');                 
        }

        Generic_Mapping.import_from_confirmation = function(return_value) {              
            var confirm_type = return_value[0][0];
            var adiha_type = '';
            var validation = '';
            var file_name = return_value[0][1];
            var copy_as = return_value[0][2];

            if (confirm_type == 'r') {
                validation = 'Data already exist. Are you sure you want to replace data? ';
                adiha_type = 'confirm';
            } else {
                adiha_type = 'return_array';
            }

            Generic_Mapping.new_win.close();

            data = {"action": "spa_generic_mapping_export_import",
                    "flag": "import_generic_data_mapping",
                    "import_file_name": file_name,
                    "copy_as" : copy_as == '' ? "NULL" : copy_as
                };
            
            adiha_post_data(adiha_type, data, '', '', 'Generic_Mapping.import_export_call_back', '', validation);                 
        }

        Generic_Mapping.import_export_call_back = function(result) {        
            var is_success = result[0][0];
            var msg_req = 'n';
            var is_missing_values = '';

            if (is_success === undefined) {
                is_success = result[0].errorcode;
             
                message = result[0].message;
                is_missing_values = result[0].recommendation;
                 
                if (is_missing_values != null) {
                    message = is_missing_values; 
                    msg_req = 'y';
                }
            } else {
                message = result[0][4];
                is_missing_values = result[0][5];
                msg_req = 'y';
            }
             
            if (is_success == "Success") {
                if (msg_req == 'y') {
                    if (is_missing_values != null) {
                            dhtmlx.message({
                            title:"Alert",
                            type:"alert",
                            text:is_missing_values
                        });  
                    } else {
                        dhtmlx.message({
                        text:message,
                        expire:1000
                        });  
                    }
                }   
                refresh_main_grid();             
            } else {
                if (msg_req == 'y') {
                    dhtmlx.message({
                        title:"Alert",
                        type:"alert",
                        text:message
                    });    
                }                
            }
        }

        function refresh_main_grid() {
            var sql_param = {
                        "flag": "s",
                        "action": "spa_generic_mapping_header"
                    };


            sql_param = $.param(sql_param);
            var sql_url = js_data_collector_url + "&" + sql_param;

            Generic_Mapping.grd_general_mapping.clearAll();
            Generic_Mapping.grd_general_mapping.load(sql_url);
        }
        
        enabled_button = function() { 
            Generic_Mapping.generic_map.setItemEnabled('export_generic_mapping');
            Generic_Mapping.generic_map.setItemEnabled('export_generic_mapping_copy_as');
        }
        
        Generic_Mapping.download_script = function(result) {                       
            var export_rule_name = result[0][1]; //data_ixp.ixp_grid.cells2(row_index, 0).getValue();
            var getdate = new Date().toJSON().slice(0, 10).replace(/-/g, '_');
            export_rule_name = export_rule_name + '_' + getdate;
           
            var ua = window.navigator.userAgent;
            var msie = ua.indexOf("MSIE ");
            var blob = null;
            if (msie > 0|| !!navigator.userAgent.match(/Trident.*rv\:11\./)) { // Code to download file for IE
                if ( window.navigator.msSaveOrOpenBlob && window.Blob ) {
                    blob = new Blob( [result[0][0]], { type: "text/csv;charset=utf-8;" } );
                    navigator.msSaveOrOpenBlob( blob, export_rule_name + "_import.txt" );
                }
            } else { // Code to download file for other browser
                blob = new Blob([result[0][0]],{type: "text/csv;charset=utf-8;"});
                var link = document.createElement("a");
                if (link.download !== undefined) {
                    var url = URL.createObjectURL(blob);
                    link.setAttribute("href", url);
                    link.setAttribute("download", export_rule_name + "_import.txt");
                    link.style = "visibility:hidden";
                    document.body.appendChild(link);
                    link.click();
                    document.body.removeChild(link);
                }
            }
        }

        function ajx_call_back_grid_header(result) {          
            var json_obj = $.parseJSON(result);            
            var header = json_obj[0].name_list;
            var column_ids = json_obj[0].column_id;
            var field_type = json_obj[0].field_type;
            var width = json_obj[0].width;
            var combo_column = json_obj[0].combo_columns;
            var validation_rule = json_obj[0].validation_rule;
            var array_combo_column = {};
            var array_combo_sql = {};
            var array_field_type = {};
            
            if (combo_column != null) {                
                array_combo_column = combo_column.split(",");
                var combo_sql = json_obj[0].combo_sql;
                array_combo_sql = combo_sql.split(":");
            }

            //this is for the filter_string for making the numeric operator applicable
            if (field_type != null) {                
                array_field_type = field_type.split(",");                
            }
                        
            var selected_row_id = Generic_Mapping.grd_general_mapping.getSelectedRowId();
            var selected_item_id = Generic_Mapping.grd_general_mapping.cells(selected_row_id,0).getValue();
            var selected_item = Generic_Mapping.grd_general_mapping.cells(selected_row_id,1).getValue();        
            

            if (array_field_type[0] == 'ron' || array_field_type[0] == 'ro_no'){
                var filter_string = '#numeric_filter';
                var col_sort_string = 'int';
            } else {
                var filter_string = '#text_filter';
                var col_sort_string = 'str';
            }
            
            
            var header_array = header.split(",");
            for (var i = 1; i < header_array.length; i++) {
                for (var i = 1; i < array_field_type.length; i++) {
                    if (array_field_type[i] == 'ron' || array_field_type[i] == 'ro_no') {
                        filter_string += ',#numeric_filter';
                        col_sort_string += ',int';
                    } else {
                        filter_string += ',#text_filter';
                        col_sort_string += ',str';
                    }  
                }              
            }

            Generic_Mapping["grd_inner_obj_" + selected_item_id] = Generic_Mapping.cell_a_tab.tabs(selected_item_id).attachGrid();
            Generic_Mapping["grd_inner_obj_" + selected_item_id].setColumnIds(column_ids);
            Generic_Mapping["grd_inner_obj_" + selected_item_id].setHeader(get_locale_value(header, true));
            Generic_Mapping["grd_inner_obj_" + selected_item_id].enableValidation(true);
            Generic_Mapping["grd_inner_obj_" + selected_item_id].setColValidators(validation_rule);

            if (selected_item == 'Flow Optimization Mapping') {
                Generic_Mapping["grd_inner_obj_" + selected_item_id].setInitWidths("180,750");                
            } else if (selected_item == 'Nomination Mapping') {
                Generic_Mapping["grd_inner_obj_" + selected_item_id].setInitWidths("0,150,750");
            } else {
                Generic_Mapping["grd_inner_obj_" + selected_item_id].setInitWidths("180,150,150,150,150,150,150,150,150,150,150,150,150,150,150,150,150,150,150,150,150");              
            }
            Generic_Mapping["grd_inner_obj_" + selected_item_id].setDateFormat(user_date_format, "%Y-%m-%d");
            Generic_Mapping["grd_inner_obj_" + selected_item_id].attachHeader(filter_string);
            Generic_Mapping["grd_inner_obj_" + selected_item_id].setColSorting(col_sort_string);
            Generic_Mapping["grd_inner_obj_" + selected_item_id].setColTypes(field_type);
            Generic_Mapping["grd_inner_obj_" + selected_item_id].init();            
            Generic_Mapping["grd_inner_obj_" + selected_item_id].setColumnHidden(0, true);// to hide id column 
            Generic_Mapping["grd_inner_obj_" + selected_item_id].enableHeaderMenu();
            Generic_Mapping["grd_inner_obj_" + selected_item_id].enableMultiselect(true);
            Generic_Mapping["grd_inner_obj_" + selected_item_id].loadHiddenColumnsFromCookie("grd_generic_mapping_" + selected_item_id);
            Generic_Mapping["grd_inner_obj_" + selected_item_id].enableAutoHiddenColumnsSaving("grd_generic_mapping_" + selected_item_id,cookie_expire_date);

            combo_load_state = {};
            combo_events_array = [];

            var has_combo_mapping = (array_combo_column.length > 0) ? 1 : 0;
            //for dropdown
            for (var i = 0; i < array_combo_column.length; i++) {
                var col_index = Generic_Mapping["grd_inner_obj_" + selected_item_id].getColIndexById(array_combo_column[i]);
                var combo_obj = Generic_Mapping["grd_inner_obj_" + selected_item_id].getColumnCombo(col_index);
                combo_obj.enableFilteringMode(true);
                var sql_stmt = array_combo_sql[i]; 

                var data = {"action":"spa_generic_mapping_header", "flag":"n", "combo_sql_stmt":sql_stmt, "call_from":"grid"};
                
                data = $.param(data);
                var url = js_dropdown_connector_url + '&' + data;
                
                // New approach to load grid only after all combo is loaded
                var combo_column_id = array_combo_column[i];
                combo_load_state[combo_column_id] = false;
                combo_obj.conf.combo_column_id = combo_column_id;
                combo_events_array[combo_column_id] = combo_obj.attachEvent("onXLE", function() {
                    mark_combo_load(this, combo_load_state, combo_events_array);
                });
                combo_obj.load(url);
            }
            
            if (has_combo_mapping == 0) {
                refresh_child_grid();
            }
        }

        /**
         * Mark the combo as loaded and load grid data if all combo is loaded
         * @param  {Object} combo_obj          Grid Column Combo Object
         * @param  {Object} combo_load_state   Object to hold combo load state
         * @param  {Array} combo_events_array  Array to hold comob onXLE event
         */
        function mark_combo_load(combo_obj, combo_load_state, combo_events_array) {
            combo_load_state[combo_obj.conf.combo_column_id] = true;
            var is_load_remaining = Object.keys(combo_load_state).filter(function(e) {
                return !combo_load_state[e];
            }).length > 0;

            combo_obj.detachEvent(combo_events_array[combo_obj.conf.combo_column_id]);
            if (!is_load_remaining) {
                delete combo_load_state;
                delete combo_events_array;

                refresh_child_grid();
            }
        }
        
        function refresh_child_grid() {
            //grid refresh
            var primary_column_value = '<?php echo $primary_column_value; ?>';
            
            var selected_row_id = Generic_Mapping.grd_general_mapping.getSelectedRowId();
            var selected_item_id = Generic_Mapping.grd_general_mapping.cells(selected_row_id,0).getValue();
            var invoice_param = { "flag": "a",
                                    "mapping_table_id": selected_item_id,
                                    "action": "spa_generic_mapping_header",
                                    "primary_column_value": primary_column_value
                                };

            invoice_param = $.param(invoice_param);
            var data_url = js_data_collector_url + "&" + invoice_param;       
            Generic_Mapping["grd_inner_obj_" + selected_item_id].loadXML(data_url);
            //to enable the delete button only on selection of row in grid
            Generic_Mapping["grd_inner_obj_" + selected_item_id].attachEvent("onRowSelect", function(id,ind){
                set_custom_report_template_menu_disabled('delete', has_rights_generic_mapping_iu);
            });
        }

        /**
        * Function enable/disable menu.
        */
        function set_custom_report_template_menu_disabled(item_id, bool) {
            var active_tab_id = Generic_Mapping.cell_a_tab.getActiveTab();
            var win = Generic_Mapping.cell_a_tab.cells(active_tab_id);
            var toolbar_menu = win.getAttachedMenu();

            if (bool == false) {
                toolbar_menu.setItemDisabled(item_id);                   
            } else {
               toolbar_menu.setItemEnabled(item_id);
            }
        }

        Generic_Mapping.manage_menu_items = function() {
            dhxWins = new dhtmlXWindows();
            var is_win = dhxWins.isWindow('w1');
            selected_id = Generic_Mapping.grd_general_mapping.getSelectedRowId();
            mapping_table_id = Generic_Mapping.grd_general_mapping.cells(selected_id, 0).getValue();
            mapping_table_name = Generic_Mapping.grd_general_mapping.cells(selected_id, 1).getValue();
            var product_category;

            if (module_type == 'trm')
                product_category = 10000000;
            else if (module_type == 'fas')
                product_category = 13000000;
            else if (module_type == 'rec')
                product_category = 14000000;
            else if (module_type == 'sec')
                product_category = 15000000;
            param = js_php_path + 'arrange.menu.template.php?is_pop=true' + '&call_from=generic_mapping' + '&product_category=' + product_category + '&menu_id=' + mapping_table_id + '&menu_name=' + mapping_table_name + '&app_function_id=' + 13102000;
            text = 'Manage Menu (' + mapping_table_name + ')';
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
     </script>
</html>