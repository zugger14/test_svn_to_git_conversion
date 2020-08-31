<?php
/**
* Setup alerts screen
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
    $application_function_id = 10122500; //view
    $rights_alerts_iu = 10122510; // add/save

    $rights_alerts_condition_iu = 10122503; // condition- add/save
    $rights_alerts_condition_delete = 10122502; // condition- delete
    
    $rights_alerts_delete = 10122511; // delete

	$rights_alerts_relation = 10122500; // 10122512 changed to 10122500 to use the parent menu view for relation also
	$rights_alerts_relation_iu = 10122513; // relations - add/save/delete
	$rights_alerts_relation_delete = 10122514;

	$rights_alerts_action = 10122515;
	$rights_alerts_manage_privilege = 10122516; /////  shd b disbld 
		
             
    list (
			$has_rights_alerts_delete ,
			$has_rights_alerts_iu,
			$has_rights_alerts_condition_delete,
			$has_rights_alerts_condition_iu,
			$has_rights_alerts_relation,
			$has_rights_alerts_relation_iu,
			$has_rights_alerts_relation_delete,
			$has_rights_alerts_action,
			$has_rights_alerts_manage_privilege
		
    ) = build_security_rights(
			$rights_alerts_delete ,
			$rights_alerts_iu,
			$rights_alerts_condition_delete,
			$rights_alerts_condition_iu,
			$rights_alerts_relation,
			$rights_alerts_relation_iu,
			$rights_alerts_relation_delete,
			$rights_alerts_action,
			$rights_alerts_manage_privilege                
    );
    
    if($has_rights_alerts_iu){
		$has_rights_alerts_condition_iu_function = 'false';
	}else{
		$has_rights_alerts_condition_iu_function = 'true';
	}
		
	if($has_rights_alerts_delete) {
        $has_rights_alerts_delete = 'false';
    } else {
        $has_rights_alerts_delete = 'true';
    }
	
	if($has_rights_alerts_condition_delete) {
        $has_rights_alerts_condition_delete = 'false';
    } else {
        $has_rights_alerts_condition_delete = 'true';
    }
    
	if($rights_alerts_manage_privilege) {
        $has_rights_alerts_relation_delete = 'false';
    } else {
        $has_rights_alerts_relation_delete = 'true';
    }
      
        
    $form_namespace = 'setup_alert';
    $form_obj = new AdihaStandardForm($form_namespace, $application_function_id);
    $form_obj->define_grid("SetupAlerts", "", "g");
    $form_obj->define_layout_width(400);
    $form_obj->define_custom_functions('save_alerts', '', '', 'post_form_load');
    
    $menu_json_array = array(
                           array(
                                'json' => '{id:"t1", text:"Edit", img:"edit.gif", imgdis:"edit_dis.gif", items:[
                                            {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add", enabled: "' . $has_rights_alerts_iu . '"},
                                            {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete", disabled: true}
                                            ]},
                                        {id: "t2", text: "Export", img: "export.gif", imgdis: "export_dis.gif", items: [
                                            {id:"excel",img:"excel.gif", imgdis:"excel_dis.gif", text:"Excel", title:"Excel"},
                                            {id:"pdf", img:"pdf.gif", text:"PDF", title:"PDF"}]},
                                        //{id:"actions",img:"action.gif", text:"Action", title:"Action"},
                                        {id:"relations", img:"manual_adj.gif", imgdis:"manual_adj_dis.gif", text:"Relation", title:"Relation", enabled: "' . $has_rights_alerts_relation . '"},
                                        //{id:"conditions",img:"tick.gif", text:"Condition", title:"Condition"}',
                                'on_click' => 'setup_alert.alert_detail_toolbar_click',
                                'on_select' => "delete|$has_rights_alerts_condition_iu_function"
                            ),
                           array(
                                'json' => '{id:"t1", text:"Edit", img:"edit.gif", imgdis:"edit_dis.gif", items:[
                                            {id:"add_condition", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add", enabled: "' . $has_rights_alerts_condition_iu . '"},
                                            {id:"delete_condition", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete", disabled: true}
                                            ]},
                                        {id: "t2", text: "Export", img: "export.gif", imgdis: "export_dis.gif", items: [
                                            {id:"excel",img:"excel.gif", imgdis:"excel_dis.gif", text:"Excel", title:"Excel"},
                                            {id:"pdf", img:"pdf.gif", text:"PDF", title:"PDF"}]}',
                                'on_click' => 'setup_alert.alert_detail_toolbar_click',
                                'on_select' => "delete_condition|$has_rights_alerts_condition_delete"
                            ),
                            array(
                                'json' => '{id:"save", text:"Save", img:"save.gif", imgdis:"save_dis.gif", title: "Save", disabled:true},
                                        {id: "switch", text: "Mode", img: "action.gif", imgdis: "action_dis.gif", disabled:true, items:[
                                            {id:"sql", type:"checkbox", text:"SQL Mode", img:"database.gif", imgdis:"database_dis.gif", title: "SQL"}
                                            ]},
                                        {id:"t1", text:"Edit", img:"edit.gif", imgdis:"edit_dis.gif", disabled:true, items:[
                                            {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add", enabled: "' . $has_rights_alerts_manage_privilege . '"},
                                            {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete", disabled: true}
                                            ]},
                                        {id: "t2", text: "Export", img: "export.gif", imgdis: "export_dis.gif", disabled:true, items: [
                                            {id:"excel",img:"excel.gif", imgdis:"excel_dis.gif", text:"Excel", title:"Excel"},
                                            {id:"pdf", img:"pdf.gif", text:"PDF", title:"PDF"}]}
                                        ',
                                'on_click' => 'setup_alert.alert_detail_toolbar_click',
                                'on_select' => "delete|$has_rights_alerts_relation_delete"
                            )
                         );
                         
    echo $form_obj->set_grid_menu_json($menu_json_array, true);
    echo $form_obj->init_form('Alerts', 'Alert Details');
    
    echo $form_obj->close_form();
    ?>
<body>
</body>
<script type="text/javascript">
    var has_rights_alerts_iu = <?php echo (($has_rights_alerts_iu) ? $has_rights_alerts_iu : '0'); ?>;
	
    var has_rights_alerts_delete = <?php echo (($has_rights_alerts_delete) ? $has_rights_alerts_delete : '0'); ?>;
	var	has_rights_alerts_condition_delete = <?php echo (($has_rights_alerts_condition_delete) ? $has_rights_alerts_condition_delete : '0'); ?>;
	var	has_rights_alerts_condition_iu = <?php echo (($has_rights_alerts_condition_iu) ? $has_rights_alerts_condition_iu : '0'); ?>;
	var	has_rights_alerts_relation = <?php echo (($has_rights_alerts_relation) ? $has_rights_alerts_relation : '0'); ?>;
	var	has_rights_alerts_relation_iu = <?php echo (($has_rights_alerts_relation_iu) ? $has_rights_alerts_relation_iu : '0'); ?>;
	var	has_rights_alerts_relation_delete = <?php echo (($has_rights_alerts_relation_delete) ? $has_rights_alerts_relation_delete : '0'); ?>;
	var	has_rights_alerts_action = <?php echo (($has_rights_alerts_action) ? $has_rights_alerts_action : '0'); ?>;
	var	has_rights_alerts_manage_privilege = <?php echo (($has_rights_alerts_manage_privilege) ? $has_rights_alerts_manage_privilege : '0'); ?>;
	
	
    var cell_change_event = '';
    setup_alert.myForm = {};
	var theme_selected = 'dhtmlx_' + default_theme;
    
    var report_window;
    /**
     * [unload_report_window Unload Report window.]
     */
    function unload_report_window() {        
        if (report_window != null && report_window.unload != null) {
            report_window.unload();
            report_window = w1 = null;
        }
    }
    
    var relations_window;
    /**
     * [unload_relations_window Unload Relations window.]
     */
    function unload_relations_window() {        
        if (relations_window != null && relations_window.unload != null) {
            relations_window.unload();
            relations_window = w1 = null;
        }
    }
    
    var conditions_window;
    /**
     * [unload_conditions_window Unload Conditions window.]
     */
    function unload_conditions_window() {        
        if (conditions_window != null && conditions_window.unload != null) {
            conditions_window.unload();
            conditions_window = w1 = null;
        }
    }
    
    setup_alert.post_form_load = function(win, tab_id) {
        var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        var tab_obj = win.tabbar[object_id];
        var detail_tabs = tab_obj.getAllTabs();
        var tab_name = win.tabbar.tabs(tab_id).getText();

        if (tab_name == 'New') {
            $.each(detail_tabs, function(index,value) {
                if (index > 0)
                    tab_obj.tabs(value).hide();
                
                var tab_name = tab_obj.tabs(value).getText();
                layout_obj = tab_obj.cells(value).getAttachedObject();    
                if (tab_name == 'Rule') {
                    layout_obj.cells("a").setHeight(160);
                    
                    layout_obj.forEachItem(function(cell){
                        attached_obj = cell.getAttachedObject();
                        
                        if(attached_obj instanceof dhtmlXForm) {
                            //var rule_type = unescapeXML(attached_obj.getItemValue('alert_type'));
                            var rule_type = 's'; // Assigned rule type to sql based
                            if (rule_type == 's') {
                                hide_show_rule_detail_cell('s');
                            } else if (rule_type == 'r') {
                                hide_show_rule_detail_cell('r');
                            }
                            
                            attached_obj.attachEvent("onChange", function (name, value, state){
                                if (name == 'alert_type' && value == 's') {
                                    hide_show_rule_detail_cell(value);
                                } else if (name == 'alert_type' && value == 'r') {
                                    hide_show_rule_detail_cell(value);
                                }
                            });
                        } else if (attached_obj instanceof dhtmlXGridObject) {
                            var grid_id = attached_obj.getUserData("", "grid_id");
                            if(grid_id == 'alert_rule_table') {
                                var attached_menu_obj = cell.getAttachedMenu();
						        attached_menu_obj.setItemDisabled('relations');
                            }
                        }
                    });
                }
            });    
        } else {
            $.each(detail_tabs, function(index,value) {
                var tab_name = tab_obj.tabs(value).getText();
                layout_obj = tab_obj.cells(value).getAttachedObject();
                layout_obj.forEachItem(function(cell){
                    attached_obj = cell.getAttachedObject();
                    if(attached_obj instanceof dhtmlXForm) {
                        //var workflow_only = attached_obj.getItemValue('workflow_only');
//                        if (workflow_only == 'y') {
//                            enable_report_menu(false);
//                        }

                        //var rule_type = attached_obj.getItemValue('alert_type');
                        var rule_type = 's'; // Assigned rule type to sql based
                        if (rule_type == 's') {
                            hide_show_rule_detail_cell('s');
                        } else if (rule_type == 'r') {
                            hide_show_rule_detail_cell('r');
                        }

                        attached_obj.attachEvent("onChange", function (name, value, state){
                            //if(name == 'workflow_only' && state == true) {
//                                enable_report_menu(false);
//                            } else if (name == 'workflow_only' && state == false){
//                                enable_report_menu(true);
//                            } else 
                            if (name == 'alert_type' && value == 's') {
                                hide_show_rule_detail_cell(value);
                            } else if (name == 'alert_type' && value == 'r') {
                                hide_show_rule_detail_cell(value);
                            }
                        });
                    } else if (attached_obj instanceof dhtmlXGridObject) {
                        if (tab_name == 'Rule')
                            attached_obj.enableMultiselect(true);
                        else
                            attached_obj.enableMultiselect(false);

                        var grid_id = attached_obj.getUserData("", "grid_id");
                        if (tab_name == 'Rule Detail' && grid_id == 'AlertCondition') {
                            layout_obj.cells("a").setWidth(320);
                            //attached_obj.attachEvent("onXLE", function(grid_obj,count){
//                                var row_count = grid_obj.getRowsNum();
//                                if (row_count > 0)
//                                    grid_obj.selectRow(0);
//                            });
                            attached_obj.attachEvent("onRowDblClicked", function(id,ind){
                                open_condition_details("u");
                            });
                            attached_obj.attachEvent("onSelectStateChanged", function(id){
                                refresh_actions_grid();
                            });
                        } else if (tab_name == 'Rule Detail' && grid_id == 'AlertActions') {
                            attached_obj.enableMultiselect(true);
                            var attached_menu_obj = cell.getAttachedMenu();
                            attached_menu_obj.attachEvent("onCheckboxClick", function(id, state, zoneId, cas){
                                if (id == 'sql') {
                                    if (state)
                                        var rule_type = 'def';
                                    else
                                        var rule_type = 's';
                                    
                                    hide_show_sql_box(rule_type);
                                    var grid_menu_obj = layout_obj.cells("b").getAttachedMenu();
                                    grid_menu_obj.setCheckboxState('sql', true);
                                
                                    var condition_grid_obj = layout_obj.cells("a").getAttachedObject();
                                    var selected_row = condition_grid_obj.getSelectedRowId();
                                    
                                    if(selected_row != null) {
                                        var col_index = condition_grid_obj.getColIndexById("alert_conditions_id");
                                        var condition_id = condition_grid_obj.cells(selected_row, col_index).getValue();   
                                    }
                                    
                                    data = {"action": "spa_alert_actions", "flag":"a", "alert_id": object_id, "condition_id": condition_id};
                                    result = adiha_post_data("return_json", data, "", "", "hide_show_sql_callback");
                                    return true;
                                }
                            });
                            ////Conditions List
//                            var cm_param = {
//                                                "action": "[spa_generic_mapping_header]", 
//                                                "flag": "n",
//                                                "combo_sql_stmt": "SELECT ac.alert_conditions_id, " +
//                                                                       "ac.alert_conditions_name " +
//                                                                "FROM alert_conditions ac " +
//                                                                "WHERE ac.rules_id = " + object_id,
//                                                "call_from": "grid"
//                                            };
//                    
//                            cm_param = $.param(cm_param);
//                            var url = js_dropdown_connector_url + '&' + cm_param;
//                            var combo_obj = attached_obj.getColumnCombo(0);                
//                            combo_obj.load(url);
                            
                            //Table List
                            var col_index = attached_obj.getColIndexById("table_id");
                            var cm_param = {
                                                "action": "[spa_generic_mapping_header]", 
                                                "flag": "n",
                                                "combo_sql_stmt": "SELECT art.alert_rule_table_id [table_id]," +
                                                                    " art.table_alias + '.' + atd.logical_table_name [table_name]" +
                                                                    " FROM alert_rule_table art" +
                                                                    " INNER JOIN alert_table_definition atd ON  atd.alert_table_definition_id = art.table_id" +
                                                                    " WHERE art.alert_id = " + object_id,
                                                "call_from": "grid"
                                            };
                    
                            cm_param = $.param(cm_param);
                            var url = js_dropdown_connector_url + '&' + cm_param;
                            var combo_obj = attached_obj.getColumnCombo(col_index);                
                            combo_obj.enableFilteringMode("between", null, false);
                            combo_obj.load(url);
                        }
                    }
                    if (tab_name == 'Rule') {
                        layout_obj.cells("a").setHeight(160);
                    }
                });
            });    
        }
    }
    
    function load_column_combo(nValue, row_index) {
        var tab_id = setup_alert.tabbar.getActiveTab();
        var alert_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        
        var win = setup_alert.tabbar.cells(tab_id);
        var tab_obj = win.tabbar[alert_id];
        var detail_tabs = tab_obj.getAllTabs();
        
        $.each(detail_tabs, function(index,value) {
            var tab_name = tab_obj.tabs(value).getText();
                
            if (tab_name == 'Rule Detail') {
                var layout_obj = tab_obj.cells(value).getAttachedObject();
                var grid_obj = layout_obj.cells("b").getAttachedObject();
                
                var cm_param = {
                            "action": "[spa_generic_mapping_header]", 
                            "flag": "n",
                            "combo_sql_stmt": "SELECT acd.alert_columns_definition_id [column_id], " +
                                            	       "acd.column_name [column_name] " +
                                            	"FROM alert_rule_table art " +
                                                "INNER JOIN alert_table_definition atd ON atd.alert_table_definition_id = art.table_id " +
                                                "INNER JOIN alert_columns_definition acd ON acd.alert_table_id = atd.alert_table_definition_id " +
                                            	"WHERE art.alert_id = " + alert_id + " AND art.alert_rule_table_id = '" + nValue + "'",
                            "call_from": "grid"
                        };

                cm_param = $.param(cm_param);
                var url = js_dropdown_connector_url + '&' + cm_param;
                var col_index = grid_obj.getColIndexById("column_id");
                //var combo_obj = grid_obj.cells(row_index, col_index).getCellCombo();

                var combo_obj =  grid_obj.getColumnCombo(col_index);
                
                combo_obj.attachEvent("onXLE", function() {
                    var column_id = grid_obj.cells(row_index,col_index).getValue();
                    var is_exist = combo_obj.getIndexByValue(column_id);
                    
                    if (is_exist != -1)
                        grid_obj.cells(row_index,col_index).setValue(column_id);
                    else
                        grid_obj.cells(row_index,col_index).setValue('');
                });
                combo_obj.enableFilteringMode("between", null, false);
                combo_obj.load(url);
            }             
        });
    }
    
    function refresh_actions_grid() {
        var tab_id = setup_alert.tabbar.getActiveTab();
        var alert_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        
        var win = setup_alert.tabbar.cells(tab_id);
        var tab_obj = win.tabbar[alert_id];
        var detail_tabs = tab_obj.getAllTabs();
        
        $.each(detail_tabs, function(index,value) {
            var tab_name = tab_obj.tabs(value).getText();
                
            if (tab_name == 'Rule Detail') {
                var layout_obj = tab_obj.cells(value).getAttachedObject();
                layout_obj.cells('b').progressOn();
                var grid_obj = layout_obj.cells("a").getAttachedObject();
                var selected_row = grid_obj.getSelectedRowId();
                
                if(selected_row != null) {
                    var col_index = grid_obj.getColIndexById("alert_conditions_id");
                    var condition_id = grid_obj.cells(selected_row, col_index).getValue();
                    var col_index = grid_obj.getColIndexById("is_sql");
                    var is_sql = grid_obj.cells(selected_row, col_index).getValue();    
                } else {
                    var condition_id = '';
                    var is_sql = 'n';
                }
                                                                              
                if (is_sql == 'n') {
                    hide_show_sql_box("def");
                    
                    var grid_menu_obj = layout_obj.cells("b").getAttachedMenu();
                    
                    // if (has_rights_alerts_iu) {
                    //     grid_menu_obj.setItemEnabled('switch');
                    //     grid_menu_obj.setItemEnabled('save');
                    //     grid_menu_obj.setItemEnabled('t1');
                    //     grid_menu_obj.setItemEnabled('t2'); 
                    // }
                    
                    if (has_rights_alerts_manage_privilege) {
                        grid_menu_obj.setItemEnabled('switch');
                        grid_menu_obj.setItemEnabled('save');
                        grid_menu_obj.setItemEnabled('t1');
                        grid_menu_obj.setItemEnabled('t2');  
                    }
                                                            
                    grid_menu_obj.setCheckboxState('sql', false);
                    var action_grid_obj = layout_obj.cells("b").getAttachedObject();
                    
                    var sql_param = {
                            "flag": "s",
                            "action":"spa_alert_actions",
                            "grid_type":"g",
                            "alert_id": alert_id,
                            "condition_id": condition_id
                        };
                    sql_param = $.param(sql_param);
                    var sql_url = js_data_collector_url + "&" + sql_param;
                    
                    action_grid_obj.detachEvent(cell_change_event);
                    action_grid_obj.clearAll();
                    action_grid_obj.load(sql_url, function(){
                        action_grid_obj.filterByAll();
                        var col_index = action_grid_obj.getColIndexById("table_id");
                        action_grid_obj.forEachRow(function(id) {
                            var nValue = action_grid_obj.cells(id, col_index).getValue();
                            load_column_combo(nValue, id)
                        });
                        cell_change_event = action_grid_obj.attachEvent("onCellChanged", setup_alert.cell_change);
                        layout_obj.cells('b').progressOff();
                    });
                } else if (is_sql == 'y') {
                    hide_show_sql_box('s');
                    var grid_menu_obj = layout_obj.cells("b").getAttachedMenu();
                    grid_menu_obj.setCheckboxState('sql', true);
                    
                    var condition_grid_obj = layout_obj.cells("a").getAttachedObject();
                    var selected_row = condition_grid_obj.getSelectedRowId();
                
                    if(selected_row != null) {
                        var col_index = condition_grid_obj.getColIndexById("alert_conditions_id");
                        var condition_id = condition_grid_obj.cells(selected_row, col_index).getValue();   
                    }
                    
                    data = {"action": "spa_alert_actions", "flag":"a", "alert_id": alert_id, "condition_id": condition_id};
                    result = adiha_post_data("return_json", data, "", "", "hide_show_sql_callback");
                }
            }             
        });
    }
    
    function open_condition_details(mode) {
        var tab_id = setup_alert.tabbar.getActiveTab();
        var alert_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        var win = setup_alert.tabbar.cells(tab_id);
        var tab_obj = win.tabbar[alert_id];
        var detail_tabs = tab_obj.getAllTabs();
        
        $.each(detail_tabs, function(index,value) {
                var tab_name = tab_obj.tabs(value).getText();
                
                if (tab_name == 'Rule Detail') {
                    if (mode == 'u') {
                        var layout_obj = tab_obj.cells(value).getAttachedObject();
                        var grid_obj = layout_obj.cells("a").getAttachedObject();
                        var selected_row = grid_obj.getSelectedRowId();
                        var col_index = grid_obj.getColIndexById("alert_conditions_id");
                        var condition_id = grid_obj.cells(selected_row, col_index).getValue();
                    } else {
                        var condition_id = '';
                    }
                    
                    unload_conditions_window();
                    if (!conditions_window) {
                        conditions_window = new dhtmlXWindows();
                    }
                    
                    var win = conditions_window.createWindow('w1', 0, 0, 415, 400);
                    win.setText("Conditions");
                    win.centerOnScreen();
                    win.maximize();
                    win.setModal(true);
                    win.attachURL('setup.alerts.conditions.php?mode=' + mode + '&condition_id=' + condition_id + '&alert_id=' + alert_id + '&right_id=' + has_rights_alerts_iu, false, true);
            		win.attachEvent("onClose", function(win){
            			refresh_condition_grid();
                        return true;
            		});
              }
        });
    }
    
    //function open_report_update_mode() {
//        var tab_id = setup_alert.tabbar.getActiveTab();
//        var win = setup_alert.tabbar.cells(tab_id);
//        var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
//        var tab_obj = win.tabbar[object_id];
//        var detail_tabs = tab_obj.getAllTabs();
//        
//        $.each(detail_tabs, function(index,value) {
//            var tab_name = tab_obj.tabs(value).getText();
//            var main_table_id = 'NULL';
//            
//            if (tab_name == 'Rule Detail') {
//                var layout_obj = tab_obj.cells(value).getAttachedObject();
//                var grid_obj = layout_obj.cells("a").getAttachedObject();
//                
//                var selected_row = grid_obj.getSelectedRowId();
//                var report_id = grid_obj.cells(selected_row,0).getValue();
//                
//                unload_report_window();
//                if (!report_window) {
//                    report_window = new dhtmlXWindows();
//                }
//                
//                var win = report_window.createWindow('w1', 0, 0, 380, 300);
//                win.setText("Reports");
//                win.centerOnScreen();
//                win.setModal(true);
//                win.attachURL('setup.alerts.report.php?alert_report_id=' + report_id + '&alert_sql_id=' + object_id + '&main_table_id=' + main_table_id + '&mode=u' + '&right_id=' + has_rights_reports_iu, false, true);
//            }
//        });   
//    }
    
    //function enable_report_menu(state) {
//        var tab_id = setup_alert.tabbar.getActiveTab();
//        var win = setup_alert.tabbar.cells(tab_id);
//        var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
//        var tab_obj = win.tabbar[object_id];
//        var detail_tabs = tab_obj.getAllTabs();
//        
//        $.each(detail_tabs, function(index,value) {
//            var tab_name = tab_obj.tabs(value).getText();
//            if (tab_name == 'Reports') {
//                layout_obj = tab_obj.cells(value).getAttachedObject();
//                layout_obj.forEachItem(function(cell){
//                    attached_menu = cell.getAttachedMenu();
//                    if (state)
//                        attached_menu.setItemEnabled('t1');
//                    else
//                        attached_menu.setItemDisabled('t1');
//                });
//            }
//        });
//    }
    
    function hide_show_rule_detail_cell(rule_type) {
        var tab_id = setup_alert.tabbar.getActiveTab();
        var win = setup_alert.tabbar.cells(tab_id);
        var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        var tab_obj = win.tabbar[object_id];
        var detail_tabs = tab_obj.getAllTabs();
        
        $.each(detail_tabs, function(index,value) {
            var tab_name = tab_obj.tabs(value).getText();
            
            if (index > 0 && rule_type == 's')
                tab_obj.tabs(value).hide();
            else
                tab_obj.tabs(value).show();
            
            if (tab_name == 'Rule') {
                var layout_obj = tab_obj.cells(value).getAttachedObject();
                var form_obj = layout_obj.cells("a").getAttachedObject();
                sql_statement = unescapeXML(form_obj.getItemValue("sql_statement"));
            
                var layout_obj = tab_obj.cells(value).getAttachedObject();
                if(rule_type == 's') {
                    var view = "sql";
                    var firstShow = layout_obj.cells("b").showView(view);
                    layout_obj.cells("b").hideHeader();
                } else {
                    var view = "def";
                    var firstShow = layout_obj.cells("b").showView(view);
                }
                
                if (firstShow) {
                    if (view == "sql") {
                        var toolbar = layout_obj.cells("b").attachToolbar();
                        toolbar.setIconsPath(js_php_path + "components/lib/adiha_dhtmlx/themes/" + theme_selected + "/imgs/dhxtoolbar_web/");
                        toolbar.attachEvent("onClick", setup_alert.test_sql);
                        toolbar.loadStruct([{id:"verify", type: "button", img: "verify.gif", imgdis: "verify_dis.gif", text:"Verify", title: "Verify"}]);
                        
        				setup_alert.myForm[tab_id] = layout_obj.cells("b").attachForm();
        				var formData = [{
                                            "type": "settings",
                                            "position": "label-top"
                                        }, {
                                            type: "block",
                                            blockOffset: 10,
                                            list: [{
                                                "type": "input",
                                                "name": "sql_query",
                                                "label": "SQL",
                                                "validate": "NotEmptywithSpace",
                                                "hidden": "false",
                                                "disabled": "false",
                                                "userdata": {
                                                    "application_field_id": 29942,
                                                    "validation_message": "Required Field "
                                                },
                                                "position": "label-top",
                                                "offsetLeft": "10",
                                                "labelWidth": "auto",
                                                "inputWidth": "750",
                                                "inputHeight": "auto",
                                                "tooltip": "SQL",
                                                "required": "true",
                                                "rows": "12"
                                            },{
                                                "type": "newcolumn"
                                            }]
                                        }];
                        setup_alert.myForm[tab_id].loadStruct(formData, "json");
                        setup_alert.myForm[tab_id].setItemValue("sql_query", sql_statement);
        			}
        		}
            }
        });
    }
    
    setup_alert.test_sql = function() {
        var tab_id = setup_alert.tabbar.getActiveTab();
        var win = setup_alert.tabbar.cells(tab_id);
        var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        
        var sql_query = unescapeXML(setup_alert.myForm[tab_id].getItemValue("sql_query"));
        
        data = {
                    "action": "spa_alert_sql",
                    "flag": "x",
                    "tsql": unescape(sql_query)
                };

        adiha_post_data('alert', data, '', '', '', '');
    }
    
    setup_alert.alert_detail_toolbar_click = function(id, grid_obj, selected_id, menu_obj) {
        var tab_id = setup_alert.tabbar.getActiveTab();
        var alert_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        
        switch(id) {
            case "add":
                var newId = (new Date()).valueOf();
                grid_obj.addRow(newId,"");
                grid_obj.selectRowById(newId);
                grid_obj.forEachRow(function(row){
                    grid_obj.forEachCell(row,function(cellObj,ind){
                        grid_obj.validateCell(row,ind)
        			});
        		});
                if (has_rights_alerts_iu) {                                
                    menu_obj.setItemEnabled("delete");
                }                                        
                break;
            //case "add_report":
//                unload_report_window();
//                if (!report_window) {
//                    report_window = new dhtmlXWindows();
//                }
//                
//                var main_table_id = 'NULL';
//                var win = report_window.createWindow('w1', 0, 0, 380, 300);
//                win.setText("Reports");
//                win.centerOnScreen();
//                win.setModal(true);
//                win.attachURL('setup.alerts.report.php?alert_sql_id=' + alert_id + '&main_table_id=' + main_table_id + '&mode=i' + '&right_id=' + has_rights_reports_iu, false, true);
//				win.attachEvent("onClose", function(win){
//					return true;
//				});
//                break;
            case "add_condition":
                open_condition_details("i");
                break;
            case "delete_condition":
                var row_id = grid_obj.getSelectedRowId();
                var alert_conditions_id = grid_obj.cells(row_id,0).getValue();
                
                data = {
                            "action": "spa_alert_conditions", 
                            "flag":"d", 
                            "rules_id": alert_id,
                            "alert_conditions_id": alert_conditions_id
                            };
                
                del_msg =  "Are you sure you want to delete?";
    			dhtmlx.message({
                    type: "confirm",
                    title: "Confirmation",
                    ok: "Confirm",
                    text: del_msg,
                    callback: function(result) {
                        if (result)
                            result = adiha_post_data("alert", data, "", "", "refresh_condition_grid");
                    }
                });
                break;
            case "delete":
                var del_ids = grid_obj.getSelectedRowId();
                var previously_xml = grid_obj.getUserData("", "deleted_xml");
                var grid_xml = "";
                if (previously_xml != null) {
                    grid_xml += previously_xml
                }             
                var del_array = new Array();             
                del_array = (del_ids.indexOf(",") != -1) ? del_ids.split(",") : del_ids.split();             
                $.each(del_array, function(index, value) {
                    if((grid_obj.cells(value,0).getValue() != "") || (grid_obj.getUserData(value,"row_status") != "")){             			
                        grid_xml += "<GridRow ";                 		
                        for(var cellIndex = 0; cellIndex < grid_obj.getColumnsNum(); cellIndex++){
                            grid_xml += " " + grid_obj.getColumnId(cellIndex) + '="' + grid_obj.cells(value,cellIndex).getValue() + '"';                     	
                        }                 	
                        grid_xml += " ></GridRow> ";                 
                    }             
                });
                grid_obj.setUserData("", "deleted_xml", grid_xml);
                grid_obj.deleteSelectedRows();
                menu_obj.setItemDisabled("delete");
                break;
            case "excel":
                grid_obj.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                break;
            case "pdf":
                grid_obj.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                break;
            case "relations":
                unload_relations_window();
                if (!relations_window) {
                    relations_window = new dhtmlXWindows();
                }
                
                var win = relations_window.createWindow('w1', 0, 0, 800, 400);
                win.setText("Export Relationship");
                win.centerOnScreen();
                win.maximize();
                win.setModal(true);
                win.attachURL('setup.alerts.relations.php?alert_id=' + alert_id + '&right_id=' + has_rights_alerts_iu, false, true);
				win.attachEvent("onClose", function(win){
					return true;
				});
                break;
            //case "conditions":
//                unload_conditions_window();
//                if (!conditions_window) {
//                    conditions_window = new dhtmlXWindows();
//                }
//                
//                var win = conditions_window.createWindow('w1', 0, 0, 415, 400);
//                win.setText("Alert Conditions");
//                win.centerOnScreen();
//                win.maximize();
//                win.setModal(true);
//                win.attachURL('setup.alerts.conditions.php?alert_id=' + alert_id + '&right_id=' + has_rights_reports_iu, false, true);
//				win.attachEvent("onClose", function(win){
//					return true;
//				});
//                break;
//            case "actions":
//                unload_actions_window();
//                if (!actions_window) {
//                    actions_window = new dhtmlXWindows();
//                }
//                
//                var win = actions_window.createWindow('w1', 0, 0, 415, 400);
//                win.setText("Alert Actions");
//                win.centerOnScreen();
//                win.maximize();
//                win.setModal(true);
//                win.attachURL('setup.alerts.actions.php?alert_id=' + alert_id + '&right_id=' + has_rights_reports_iu, false, true);
//				win.attachEvent("onClose", function(win){
//					return true;
//				});
//                break;
            case "save":
                save_actions();
                break;
        }
    }
    
    /**
     * [Function to save Alerts]
     */
    setup_alert.save_alerts = function(tab_id) {
        var win = setup_alert.tabbar.cells(tab_id);
        var valid_status = 1;
        var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(" ", ""));
        var tab_obj = win.tabbar[object_id];
        var detail_tabs = tab_obj.getAllTabs();
        
        var grid_xml = "<GridGroup>";
        var form_xml = "<FormXML ";
        $.each(detail_tabs, function(index,value) {

            if (index == 0) {
                layout_obj = tab_obj.cells(value).getAttachedObject();
                layout_obj.forEachItem(function(cell){
                     if (valid_status == 0) {
                        return;
                    };
                    attached_obj = cell.getAttachedObject();
                    if (attached_obj instanceof dhtmlXGridObject) {
                        attached_obj.clearSelection();
                        grid_label = attached_obj.getUserData("","grid_label");
                                                                        
                        var ids = attached_obj.getChangedRows(true);
                        grid_id = attached_obj.getUserData("","grid_id");
                         
                        deleted_xml = attached_obj.getUserData("","deleted_xml");
                        if(deleted_xml != null && deleted_xml != "") {
            				grid_xml += "<GridDelete grid_id=\""+ grid_id + "\" grid_label=\"" + grid_label + "\">";
            				grid_xml += deleted_xml;
            				grid_xml += "</GridDelete>";
                            if (delete_grid_name == "") {
                                delete_grid_name = grid_label
                            } else {
                                delete_grid_name += "," + grid_label
                            }
            			}
                        
                        if(ids != "") {
                            attached_obj.setSerializationLevel(false,false,true,true,true,true);
                            var grid_status = setup_alert.validate_form_grid(attached_obj,grid_label);
                             
                            grid_xml += "<Grid grid_id=\""+ grid_id + "\">";
                            var changed_ids = new Array();
                            changed_ids = ids.split(",");
                            if(grid_status){
                                $.each(changed_ids, function(index, value) {
                                    grid_xml += "<GridRow ";
                                    for(var cellIndex = 0; cellIndex < attached_obj.getColumnsNum(); cellIndex++){
                                        grid_xml += " " + attached_obj.getColumnId(cellIndex) + '="' + attached_obj.cells(value,cellIndex).getValue() + '"';
                                    }
                                    grid_xml += " ></GridRow> ";
                                });
                                grid_xml += "</Grid>";
                            } else {
                                valid_status = 0;
                                return;
                            }
                        }
                    } else if(attached_obj instanceof dhtmlXForm) {
                        var status = validate_form(attached_obj);
                        if(status) {
                            data = attached_obj.getFormData();
                            for (var a in data) {
                                field_label = a;
                                field_value = data[a];
                                if (field_label == 'sql_query')
                                    form_xml += " sql_statement=\"" + field_value + "\"";
                                else if(field_label != 'sql_statement')
                                    form_xml += " " + field_label + "=\"" + field_value + "\"";
                            }
                        } else {
                            valid_status = 0;
                        }                   
                    }                 
                });
            }
        });
        form_xml += "></FormXML>";
        grid_xml += "</GridGroup>";
        var xml = "<Root function_id=\"<?php echo $application_function_id;?>\" object_id=\"" + object_id + "\">";
        xml += form_xml;
        xml += grid_xml;
        xml += "</Root>";
        xml = xml.replace(/'/g, "\"");
        if (!valid_status) {
            generate_error_message();
            return;
        };
        if(valid_status == 1){
            data = {"action": "spa_setup_rule_workflow", "flag": "z", "xml":xml}
    		if(delete_grid_name != ""){
    			del_msg =  "Some data has been deleted from " + delete_grid_name + " grid. Are you sure you want to save?";
    			// result = adiha_post_data("confirm-warning", data, "", "", "location_data.post_callback","",del_msg);
                dhtmlx.message({
                    type: "confirm-warning",
                    title: "Warning",
                    ok: "Confirm",
                    text: del_msg,
                    callback: function(result) {
                        if (result)
                            result = adiha_post_data('alert', data, "", "", "setup_alert.save_alert_post_callback","",del_msg)
                    }
                });
    		} else {
    			result = adiha_post_data("alert", data, "", "", "setup_alert.save_alert_post_callback");
    		}
    		delete_grid_name = "";
			deleted_xml = attached_obj.setUserData("","deleted_xml", "");
   	    }
    }
    
    setup_alert.save_alert_post_callback = function(result) {
        if (result[0].errorcode == "Success") {
    		setup_alert.clear_delete_xml();
    		
    		if (result[0].recommendation != null) {             
    			var tab_id = setup_alert.tabbar.getActiveTab();
                var tab_text = new Array();
                if (result[0].recommendation.indexOf(",") != -1) { 
    				tab_text = result[0].recommendation.split(",") 
    			} else { 
    				tab_text.push(0, result[0].recommendation); 
    			}
    			setup_alert.tabbar.tabs(tab_id).setText(tab_text[1]);
    			setup_alert.refresh_grid("", setup_alert.open_tab);
    		} else {
    			setup_alert.refresh_grid();
    		}
    		setup_alert.menu.setItemDisabled("delete");
    	}
    }
    
    function refresh_condition_grid() {
        var tab_id = setup_alert.tabbar.getActiveTab();
        var win = setup_alert.tabbar.cells(tab_id);
        var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        var tab_obj = win.tabbar[object_id];
        var detail_tabs = tab_obj.getAllTabs();
        
        $.each(detail_tabs, function(index,value) {
            var tab_name = tab_obj.tabs(value).getText();
            
            if (tab_name == 'Rule Detail') {
                var layout_obj = tab_obj.cells(value).getAttachedObject();
                var grid_obj = layout_obj.cells("a").getAttachedObject();
                var selected_id = grid_obj.getSelectedRowId();
                var sql_param = {
                    "flag": "s",
                    "action":"spa_alert_conditions",
                    "grid_type":"g",
                    "rules_id": object_id
                };
                sql_param = $.param(sql_param);
                var sql_url = js_data_collector_url + "&" + sql_param;
                grid_obj.clearAll();
                grid_obj.load(sql_url, function() {
                    grid_obj.selectRow(selected_id);
                    grid_obj.filterByAll();
                    var condition_id = grid_obj.getSelectedRowId();
                    if(condition_id == null)
                        refresh_actions_grid();
                });
            }
        });    
    }
    
    setup_alert.cell_change = function(rId,cInd,nValue) {
        if (cInd == 0) {
            load_column_combo(nValue, rId)
        }
    }
    
    function hide_show_sql_box(rule_type) {
        var tab_id = setup_alert.tabbar.getActiveTab();
        var win = setup_alert.tabbar.cells(tab_id);
        var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        var tab_obj = win.tabbar[object_id];
        var detail_tabs = tab_obj.getAllTabs();
        
        $.each(detail_tabs, function(index,value) {
            var tab_name = tab_obj.tabs(value).getText();
            
            if (tab_name == 'Rule Detail') {
                var layout_obj = tab_obj.cells(value).getAttachedObject();
                //var form_obj = layout_obj.cells("a").getAttachedObject();
                //sql_statement = '';//form_obj.getItemValue("sql_statement");
            
                var layout_obj = tab_obj.cells(value).getAttachedObject();
                if(rule_type == 's') {
                    var view = "sql";
                    var firstShow = layout_obj.cells("b").showView(view);
                } else {
                    var view = "def";
                    var firstShow = layout_obj.cells("b").showView(view);
                }
                
                if (firstShow) {
                    if (view == "sql") {
                        var menu_json = [   {id:"save", text:"Save", img:"save.gif", imgdis:"save_dis.gif", title: "Save", enabled: has_rights_alerts_iu},
                                            {id: "switch", text: "Mode", img: "action.gif", imgdis: "action_dis.gif", enabled: has_rights_alerts_iu, items:[
                                                {id:"sql", checked:true, type:"checkbox", text:"SQL Mode", img:"database.gif", imgdis:"database_dis.gif", title: "SQL"}
                                            ]},
                                            {id:"verify", text:"Verify", img:"verify.gif", imgdis:"verify_dis.gif", title: "Verify"}
                                        ];
                        var menu = layout_obj.cells("b").attachMenu();
                        menu.setIconsPath(js_php_path + "components/lib/adiha_dhtmlx/themes/" + theme_selected + "/imgs/dhxtoolbar_web/");
                        menu.attachEvent("onClick", setup_alert.sql_box_toolbar_click);
                        menu.attachEvent("onCheckboxClick", function(id, state, zoneId, cas){
                            if (id == 'sql') {
                                if (state)
                                    var rule_type = 'def';
                                else
                                    var rule_type = 's';
                                
                                hide_show_sql_box(rule_type);
                                return true;
                            }
                        });
                        menu.loadStruct(menu_json);
                        
                        setup_alert.myForm[tab_id] = layout_obj.cells("b").attachForm();
                		var formData = [{
                                            "type": "settings",
                                            "position": "label-top"
                                        }, {
                                            type: "block",
                                            blockOffset: 10,
                                            list: [{
                                                "type": "input",
                                                "name": "sql_query",
                                                "label": "SQL",
                                                "validate": "NotEmptywithSpace",
                                                "hidden": "false",
                                                "disabled": "false",
                                                "userdata": {
                                                    "application_field_id": 29942,
                                                    "validation_message": "Required Field "
                                                },
                                                "position": "label-top",
                                                "offsetLeft": "10",
                                                "labelWidth": "auto",
                                                "inputWidth": "350",
                                                "tooltip": "SQL",
                                                "required": "true",
                                                "rows": "10"
                                            },{
                                                "type": "newcolumn"
                                            }]
                                        }];
                        setup_alert.myForm[tab_id].loadStruct(formData, "json");
        			}
        		}
            }
        });
    }
    
    function hide_show_sql_callback(result) {
        var return_data = JSON.parse(result);
        if(return_data.length > 0)
            var sql_statement = return_data[0].sql_statement;
        else
            var sql_statement = '';
        
        var tab_id = setup_alert.tabbar.getActiveTab();
        
        setup_alert.myForm[tab_id].setItemValue("sql_query", sql_statement);
        layout_obj.cells('b').progressOff();
    }
    
    setup_alert.sql_box_toolbar_click = function(id) {
        switch(id) {
            case "verify":
                setup_alert.test_sql();
                break;
            case "save":
                save_actions();
        }
    }
    
    function save_actions() {
        var tab_id = setup_alert.tabbar.getActiveTab();
        var win = setup_alert.tabbar.cells(tab_id);
        var valid_status = 1;
        var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        var alert_id = object_id;
        object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(" ", ""));
        var tab_obj = win.tabbar[object_id];
        var detail_tabs = tab_obj.getAllTabs();
        var tsql = '';
        var is_checked = false;
        var condition_id = '';
        var xml = '';
        
        $.each(detail_tabs, function(index,value) {
            if (index == 1) {
                layout_obj = tab_obj.cells(value).getAttachedObject();
                //layout_obj.forEachItem(function(cell){
                    var condition_grid_obj = layout_obj.cells("a").getAttachedObject();
                    var selected_row = condition_grid_obj.getSelectedRowId();
                
                    if(selected_row != null) {
                        var col_index = condition_grid_obj.getColIndexById("alert_conditions_id");
                        condition_id = condition_grid_obj.cells(selected_row, col_index).getValue();   
                    }
                                                                                
                    attached_menu_obj = layout_obj.cells("b").getAttachedMenu();
                    is_checked = attached_menu_obj.getCheckboxState('sql');
                    attached_obj = layout_obj.cells("b").getAttachedObject();
                    if(is_checked) {
                        var status = validate_form(attached_obj);
                        if (status)
                            tsql = unescapeXML(attached_obj.getItemValue('sql_query'));
                        else
                            valid_status = 0;
                    } else {
                        xml = "<Root>";
                        if (attached_obj instanceof dhtmlXGridObject) {
                            attached_obj.clearSelection();
                            grid_label = attached_obj.getUserData("","grid_label");
                                                                            
                            //var ids = attached_obj.getChangedRows(true);
                            //grid_id = attached_obj.getUserData("","grid_id");
                             
                            deleted_xml = attached_obj.getUserData("","deleted_xml");
                            if(deleted_xml != null && deleted_xml != "") {
                				//grid_xml += "<GridDelete grid_id=\""+ grid_id + "\" grid_label=\"" + grid_label + "\">";
    //            				grid_xml += deleted_xml;
    //            				grid_xml += "</GridDelete>";
                                if (delete_grid_name == "") {
                                    delete_grid_name = grid_label
                                } else {
                                    delete_grid_name += "," + grid_label
                                }
                			}
                            
                            //if(ids != "") {
                                attached_obj.setSerializationLevel(false,false,true,true,true,true);
                                var grid_status = setup_alert.validate_form_grid(attached_obj,grid_label);
                                 
                                //grid_xml += "<Grid grid_id=\""+ grid_id + "\">";
    //                            var changed_ids = new Array();
    //                            changed_ids = ids.split(",");
                                if(grid_status){
                                    //$.each(changed_ids, function(index, value) {
                                    attached_obj.forEachRow(function(id) {
                                        //grid_xml += "<GridRow ";
                                        xml += "<PSRecordset ";
                                        for(var cellIndex = 0; cellIndex < attached_obj.getColumnsNum(); cellIndex++){
                                            xml += " " + attached_obj.getColumnId(cellIndex) + '="' + attached_obj.cells(id,cellIndex).getValue() + '"';
                                        }
                                        //grid_xml += " ></GridRow> ";
                                        xml += " ></PSRecordset> ";
                                    });
                                    //grid_xml += "</Grid>";
                                } else {
                                    valid_status = 0;
                                }
                            //}
                        }
                        xml += "</Root>";
                    //});
                    }
            }
            //grid_xml += "</GridGroup>";
    //        var xml = "<Root function_id=\"<?php echo $application_function_id;?>\" object_id=\"" + object_id + "\">";
    //        xml += grid_xml;
            
        });
        //xml = xml.replace(/'/g, "\"");
        
        if(valid_status == 1){
            //data = {"action": "spa_process_form_data", "xml":xml}
            if (!is_checked)
                data = {"action": "spa_alert_actions", "flag":"i", "xml":xml, "alert_id": alert_id, "condition_id": condition_id};
            else
                data = {"action": "spa_alert_actions", "flag":"i", "alert_id": alert_id, "tsql": unescape(tsql.replace(/'/g,"''")), "condition_id": condition_id};
                                                        
    		if(delete_grid_name != ""){
    			del_msg =  "Some data has been deleted from " + delete_grid_name + " grid. Are you sure you want to save?";
    			// result = adiha_post_data("confirm-warning", data, "", "", "location_data.post_callback","",del_msg);
                dhtmlx.message({
                    type: "confirm-warning",
                    title: "Warning",
                    ok: "Confirm",
                    text: del_msg,
                    callback: function(result) {
                        if (result)
                            result = adiha_post_data('alert', data, "", "", "refresh_condition_grid","",del_msg)
                    }
                });
    		} else {
    			result = adiha_post_data("alert", data, "", "", "refresh_condition_grid");
    		}
    		delete_grid_name = "";
			deleted_xml = attached_obj.setUserData("","deleted_xml", "");
   	    }
    }
</script>
</html>