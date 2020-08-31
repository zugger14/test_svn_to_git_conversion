<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
</head>
<?php
    include '../../../adiha.php.scripts/components/include.file.v3.php';
    
    $mode = get_sanitized_value($_GET["mode"] ?? '');
    $alert_id = get_sanitized_value($_GET["alert_id"] ?? '');
    $has_rights = get_sanitized_value($_REQUEST["right_id"] ?? '');
    $sql_statement = '';
    
    if ($has_rights != 0) {
        $rights = true;
    } else {
        $rights = false;
    }
    
    $sql = "EXEC spa_alert_actions @flag='r', @alert_id = $alert_id";
    $return_value = readXMLURL2($sql);
    $sql_statement = $return_value[0]['sql_statement'];
    
    $form_namespace = 'alert_actions';
    
    $layout_json = '[{id: "a", header:false, height:30},{id: "b", header:true, text:"Actions"},{id: "c", header:true, text:"Registered Events"}]';
    $layout_obj = new AdihaLayout();
    
    echo $layout_obj->init_layout('action', '', '3T', $layout_json, $form_namespace);
    
    $toolbar_obj = new AdihaToolbar();
    $toolbar_name = 'save_toolbar';
    $toolbar_json = '[{id:"save", type:"button", text:"Save", img:"save.gif", imgdis:"save_dis.gif"}]';
    echo $layout_obj->attach_toolbar($toolbar_name);
    echo $toolbar_obj->init_by_attach($toolbar_name, $form_namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', "onClick", $form_namespace. ".save_click");
    
    $form_name = "action_form";
    $form_json = '[{
                        "type": "settings",
                        "position": "label-top"
                    }, {
                        type: "block",
                        blockOffset: 10,
                        list: [{
                            "type": "checkbox",
                            "name": "sql",
                            "label": "SQL",
                            "validate": "NotEmptywithSpace",
                            "hidden": "false",
                            "disabled": "false",
                            "position": "label-right",
                            "offsetTop": "20",
                            "labelWidth": "auto",
                            "tooltip": "SQL"
                        }]
                    }]';
    $form_obj = new AdihaForm();
    echo $layout_obj->attach_form($form_name, 'a');
    echo $form_obj->init_by_attach($form_name, $form_namespace);
    echo $form_obj->load_form($form_json);
    echo $form_obj->attach_event('', "onChange", $form_namespace.'.form_change');
    
    $detail_menu_json = '[{id:"t1", text:"Edit", img:"edit.gif", imgdis:"edit_dis.gif", items:[
                    {id:"add", text:"Add", img:"add.gif", imgdis:"add_dis.gif"},
                    {id:"delete", text:"Delete", img:"delete.gif", imgdis:"delete_dis.gif", disabled:true}
                ]},{id:"t2", text:"Export", img:"export.gif", imgdis:"export_dis.gif", items:[
                    {id:"excel", text:"Excel", img:"excel.gif"},
                    {id:"pdf", text:"PDF", img:"pdf.gif"}
                ]}]';
    echo $layout_obj->attach_menu_layout_cell('conditions_detail_menu', 'b', $detail_menu_json, $form_namespace.'.action_menu_click');
    
    $grid_name = 'AlertActions';
    echo $layout_obj->attach_grid_cell($grid_name, 'b');
    $detail_grid_obj = new GridTable($grid_name);
    echo $layout_obj->attach_status_bar("b", true);
    echo $detail_grid_obj->init_grid_table($grid_name, $form_namespace);
    echo $detail_grid_obj->return_init();
    echo $detail_grid_obj->enable_multi_select();
    echo $detail_grid_obj->enable_paging(25, 'pagingArea_b', 'true');
    echo $detail_grid_obj->attach_event('', 'onSelectStateChanged', $form_namespace.'.action_grid_select');
    //echo $detail_grid_obj->attach_event('', 'onCellChanged', $form_namespace.'.cell_change');
    
    //Detail
    $menu_json = '[{id:"t1", text:"Edit", img:"edit.gif", imgdis:"edit_dis.gif", items:[
                    {id:"add", text:"Add", img:"add.gif", imgdis:"add_dis.gif"},
                    {id:"delete", text:"Delete", img:"delete.gif", imgdis:"delete_dis.gif", disabled:true}
                ]},{id:"t2", text:"Export", img:"export.gif", imgdis:"export_dis.gif", items:[
                    {id:"excel", text:"Excel", img:"excel.gif"},
                    {id:"pdf", text:"PDF", img:"pdf.gif"}
                ]}]';
    echo $layout_obj->attach_menu_layout_cell('conditions_menu', 'c', $menu_json, $form_namespace.'.event_menu_click');
    
    $event_grid_name = 'ActionEvents';
    echo $layout_obj->attach_grid_cell($event_grid_name, 'c');
    $grid_obj = new GridTable($event_grid_name);
    echo $layout_obj->attach_status_bar("c", true);
    echo $grid_obj->init_grid_table($event_grid_name, $form_namespace);
    echo $grid_obj->return_init();
    echo $grid_obj->enable_multi_select();
    echo $grid_obj->enable_paging(25, 'pagingArea_c', 'true');
    echo $grid_obj->attach_event('', 'onSelectStateChanged', $form_namespace.'.event_grid_select');
                        
    echo $layout_obj->close_layout();
?>
<script type="text/javascript">
    var mode = '<?php echo $mode; ?>';
    var alert_id = '<?php echo $alert_id; ?>';
    var sql_statement = '<?php echo $sql_statement; ?>';
    alert_actions.myForm = {};
    var cell_change_event = '';
    var delete_grid_name = "";
	var theme_selected = 'dhtmlx_' + default_theme;
    
    $(function(){
        if(sql_statement != '') {
            alert_actions.action_form.checkItem("sql");
            hide_show_sql_box("s");
        }
        //Conditions List
        var cm_param = {
                            "action": "[spa_generic_mapping_header]", 
                            "flag": "n",
                            "combo_sql_stmt": "SELECT ac.alert_conditions_id, " +
                                                   "ac.alert_conditions_name " +
                                            "FROM alert_conditions ac " +
                                            "WHERE ac.rules_id = " + alert_id,
                            "call_from": "grid"
                        };

        cm_param = $.param(cm_param);
        var url = js_dropdown_connector_url + '&' + cm_param;
        var combo_obj = alert_actions.AlertActions.getColumnCombo(0);                
        combo_obj.load(url);
        
        //Table List
        var cm_param = {
                            "action": "[spa_generic_mapping_header]", 
                            "flag": "n",
                            "combo_sql_stmt": "SELECT art.alert_rule_table_id [table_id]," +
                                                " art.table_alias + ''.'' + atd.logical_table_name [table_name]" +
                                                " FROM alert_rule_table art" +
                                                " INNER JOIN alert_table_definition atd ON  atd.alert_table_definition_id = art.table_id" +
                                                " WHERE art.alert_id = " + alert_id,
                            "call_from": "grid"
                        };

        cm_param = $.param(cm_param);
        var url = js_dropdown_connector_url + '&' + cm_param;
        var combo_obj = alert_actions.AlertActions.getColumnCombo(1);                
        combo_obj.load(url, refresh_action_events);
        
        var combo_obj = alert_actions.ActionEvents.getColumnCombo(0);                
        combo_obj.load(url, refresh_events_rules);
    });
    
    alert_actions.cell_change = function(rId,cInd,nValue) {
        if (cInd == 1) {                                 
            load_column_combo(nValue, rId)
        }
    }
    
    function load_column_combo(nValue, row_index) {
        var cm_param = {
                            "action": "[spa_generic_mapping_header]", 
                            "flag": "n",
                            "combo_sql_stmt": "SELECT acd.alert_columns_definition_id [column_id], " +
                                            	       "acd.column_name [column_name] " +
                                            	"FROM alert_rule_table art " +
                                                "INNER JOIN alert_table_definition atd ON atd.alert_table_definition_id = art.table_id " +
                                                "INNER JOIN alert_columns_definition acd ON acd.alert_table_id = atd.alert_table_definition_id " +
                                            	"WHERE art.alert_id = " + alert_id + "AND art.alert_rule_table_id = " + nValue,
                            "call_from": "grid"
                        };

        cm_param = $.param(cm_param);
        var url = js_dropdown_connector_url + '&' + cm_param;
        var combo_obj = alert_actions.AlertActions.cells(row_index, 2).getCellCombo();
        
        combo_obj.attachEvent("onXLE", function() {
            var column_id = alert_actions.AlertActions.cells(row_index,2).getValue();
            var is_exist = combo_obj.getIndexByValue(column_id);
            
            if (is_exist != -1)
                alert_actions.AlertActions.cells(row_index,2).setValue(column_id);
            else
                alert_actions.AlertActions.cells(row_index,2).setValue('');
        });
        
        combo_obj.load(url);
    }
    
    function refresh_action_events() {
        alert_actions.AlertActions.detachEvent(cell_change_event);
        var sql_param = {
                "flag": "s",
                "action":"spa_alert_actions",
                "grid_type":"g",
                "alert_id": alert_id
            };
        sql_param = $.param(sql_param);
        var sql_url = js_data_collector_url + "&" + sql_param;
        alert_actions.AlertActions.clearAll();
        alert_actions.AlertActions.load(sql_url, function(){
            alert_actions.AlertActions.forEachRow(function(id) {
                var nValue = alert_actions.AlertActions.cells(id,1).getValue();
                load_column_combo(nValue, id)
            });
            cell_change_event = alert_actions.AlertActions.attachEvent("onCellChanged", alert_actions.cell_change);
        });
    }
    
    function refresh_events_rules() {
        //Load Event Rule Grid
        var sql_param = {
                "flag": "t",
                "action":"spa_alert_actions",
                "grid_type":"g",
                "alert_id": alert_id
            };
        sql_param = $.param(sql_param);
        var sql_url = js_data_collector_url + "&" + sql_param;
        alert_actions.ActionEvents.clearAll();
        alert_actions.ActionEvents.load(sql_url);
    }
    
    alert_actions.event_menu_click = function(id) {
        switch(id) {
            case "add":
                var newId = (new Date()).valueOf();
                alert_actions.ActionEvents.addRow(newId,"");
                alert_actions.ActionEvents.selectRowById(newId);
                alert_actions.conditions_menu.setItemEnabled("delete");
                break;
            case "delete":
                var del_ids = alert_actions.ActionEvents.getSelectedRowId();
                var previously_xml = alert_actions.ActionEvents.getUserData("", "deleted_xml_events");
                var grid_xml = "";
                if (previously_xml != null) {
                    grid_xml += previously_xml
                }             
                var del_array = new Array();             
                del_array = (del_ids.indexOf(",") != -1) ? del_ids.split(",") : del_ids.split();             
                $.each(del_array, function(index, value) {
                    if((alert_actions.ActionEvents.cells(value,0).getValue() != "") || (alert_actions.ActionEvents.getUserData(value,"row_status") != "")){             			
                        grid_xml += "<GridRow ";                 		
                        for(var cellIndex = 0; cellIndex < alert_actions.ActionEvents.getColumnsNum(); cellIndex++){
                            grid_xml += " " + alert_actions.ActionEvents.getColumnId(cellIndex) + '="' + alert_actions.ActionEvents.cells(value,cellIndex).getValue() + '"';                     	
                        }                 	
                        grid_xml += " ></GridRow> ";                 
                    }             
                });
                alert_actions.ActionEvents.setUserData("", "deleted_xml_events", grid_xml);
                alert_actions.ActionEvents.deleteSelectedRows();
                alert_actions.conditions_menu.setItemDisabled("delete");
                break;
            case "excel":
                alert_actions.ActionEvents.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                break;
            case "pdf":
                alert_actions.ActionEvents.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                break;
        }
    }
    
    alert_actions.action_menu_click = function(id) {
        switch(id) {
            case "add":
                var newId = (new Date()).valueOf();
                alert_actions.AlertActions.addRow(newId,"");
                alert_actions.AlertActions.selectRowById(newId);
                alert_actions.conditions_detail_menu.setItemEnabled("delete");
                break;
            case "delete":
                var del_ids = alert_actions.AlertActions.getSelectedRowId();
                var previously_xml = alert_actions.AlertActions.getUserData("", "deleted_xml");
                var grid_xml = "";
                if (previously_xml != null) {
                    grid_xml += previously_xml
                }             
                var del_array = new Array();             
                del_array = (del_ids.indexOf(",") != -1) ? del_ids.split(",") : del_ids.split();             
                $.each(del_array, function(index, value) {
                    if((alert_actions.AlertActions.cells(value,0).getValue() != "") || (alert_actions.AlertActions.getUserData(value,"row_status") != "")){             			
                        grid_xml += "<GridRow ";                 		
                        for(var cellIndex = 0; cellIndex < alert_actions.AlertActions.getColumnsNum(); cellIndex++){
                            grid_xml += " " + alert_actions.AlertActions.getColumnId(cellIndex) + '="' + alert_actions.AlertActions.cells(value,cellIndex).getValue() + '"';                     	
                        }                 	
                        grid_xml += " ></GridRow> ";                 
                    }             
                });
                alert_actions.AlertActions.setUserData("", "deleted_xml", grid_xml);
                alert_actions.AlertActions.deleteSelectedRows();
                alert_actions.conditions_detail_menu.setItemDisabled("delete");
                break;
            case "excel":
                alert_actions.AlertActions.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                break;
            case "pdf":
                alert_actions.AlertActions.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                break;
        }
    }
    
    alert_actions.action_grid_select = function(row_id,ind) {
        if (alert_actions.AlertActions.getSelectedRowId() == null) {
            alert_actions.conditions_detail_menu.setItemDisabled("delete");
        } else {
            alert_actions.conditions_detail_menu.setItemEnabled("delete");
        }
    }
    
    alert_actions.event_grid_select = function(row_id,ind) {
        var selected = alert_actions.ActionEvents.getSelectedRowId();
        if (selected == null) {
            alert_actions.conditions_menu.setItemDisabled("delete");
        } else {
            alert_actions.conditions_menu.setItemEnabled("delete");
        }
    }
    
    alert_actions.save_click = function(id) {
        switch(id) {
            case "save":
                save_actions();
                break;
            default:
                break;
        }
    }
    
    alert_actions.form_change = function(name, value, state) {
        if(name == 'sql') {
            if(state) {
                hide_show_sql_box("s");
            } else {
                hide_show_sql_box("def");
            }
        }
    }
    
    function hide_show_sql_box(rule_type) {
        var layout_obj = alert_actions.action;
        if(rule_type == 's') {
            var view = "sql";
            var firstShow = layout_obj.cells("b").showView(view);
        } else {
            var view = "def";
            var firstShow = layout_obj.cells("b").showView(view);
        }
        
        if (firstShow) {
            if (view == "sql") {
                var toolbar = layout_obj.cells("b").attachToolbar();
                toolbar.setIconsPath(js_php_path + "components/lib/adiha_dhtmlx/themes/" + theme_selected + "/imgs/dhxtoolbar_web/");
                toolbar.attachEvent("onClick", alert_actions.test_sql);
                toolbar.loadStruct([{id:"verify", type: "button", img: "verify.gif", imgdis: "verify_dis.gif", text:"Verify", title: "Verify"}]);
                
				alert_actions.myForm["tab_id"] = layout_obj.cells("b").attachForm();
				var formData = [{
                                    "type": "settings",
                                    "position": "label-top"
                                }, {
                                    type: "block",
                                    blockOffset: 10,
                                    list: [{
                                        "type": "input",
                                        "name": "sql_query",
                                        "label": "Actions",
                                        "validate": "NotEmptywithSpace",
                                        "hidden": "false",
                                        "disabled": "false",
                                        "position": "label-top",
                                        "offsetLeft": "10",
                                        "labelWidth": "auto",
                                        "inputWidth": "550",
                                        "tooltip": "Actions",
                                        "rows": "15",
                                        "value": sql_statement
                                    }]
                                }];
                alert_actions.myForm["tab_id"].loadStruct(formData, "json");
                alert_actions.myForm["tab_id"].setItemValue("sql_query", sql_statement);
			}
		}
    }
    
    alert_actions.test_sql = function() {        
        var sql_query = alert_actions.myForm["tab_id"].getItemValue("sql_query");
        sql_query = unescape(sql_query);
        
        data = {
                    "action": "spa_alert_sql",
                    "flag": "x",
                    "tsql": unescape(sql_query.replace(/'/g,"''"))
                };

        adiha_post_data('alert', data, '', '', '', '');
    }
    
    function save_actions() {
        var is_checked = alert_actions.action_form.isItemChecked('sql');
        if(is_checked) {
            var tsql = alert_actions.myForm["tab_id"].getItemValue('sql_query');
        } else {    
            //Manipulate Actions Grid
            alert_actions.AlertActions.clearSelection();
            var xml = "<Root>";
            var grid_label = "Actions";
            
            var deleted_xml = alert_actions.AlertActions.getUserData("","deleted_xml");
        
            if(deleted_xml != null && deleted_xml != "") {
                if (delete_grid_name == "") {
                    delete_grid_name += grid_label
                } else {
                    delete_grid_name += "," + grid_label
                }
    		}
            
            alert_actions.AlertActions.setSerializationLevel(false,false,true,true,true,true);
            attached_obj = alert_actions.AlertActions;
            var grid_status = alert_actions.validate_form_grid(attached_obj,grid_label);
            
            if(grid_status){
                var num_rows = alert_actions.AlertActions.getRowsNum();
                
                alert_actions.AlertActions.forEachRow(function(id) {
                    xml += "<PSRecordset ";
                    for(var cellIndex = 0; cellIndex < alert_actions.AlertActions.getColumnsNum(); cellIndex++){
                        xml += " " + alert_actions.AlertActions.getColumnId(cellIndex) + '="' + alert_actions.AlertActions.cells(id,cellIndex).getValue() + '"';
                    }
                    xml += " ></PSRecordset> ";
                });
            }
                
            xml += "</Root>";
        }    
        
        //Manipulate Events Grid
        alert_actions.ActionEvents.clearSelection();
        var xml_events = "<Root>";
        var grid_label = "Events";
        
        var deleted_xml_events = alert_actions.ActionEvents.getUserData("","deleted_xml_events");
        
        if(deleted_xml_events != null && deleted_xml_events != "") {
            if (delete_grid_name == "") {
                delete_grid_name += grid_label
            } else {
                delete_grid_name += "," + grid_label
            }
		}
        
        alert_actions.ActionEvents.setSerializationLevel(false,false,true,true,true,true);
        attached_obj = alert_actions.ActionEvents;
        var grid_status = alert_actions.validate_form_grid(attached_obj,grid_label);
        
        if(grid_status){
            var num_rows = alert_actions.ActionEvents.getRowsNum();
            
            alert_actions.ActionEvents.forEachRow(function(id) {
                xml_events += "<PSRecordset ";
                for(var cellIndex = 0; cellIndex < alert_actions.ActionEvents.getColumnsNum(); cellIndex++){
                    xml_events += " " + alert_actions.ActionEvents.getColumnId(cellIndex) + '="' + alert_actions.ActionEvents.cells(id,cellIndex).getValue() + '"';
                }
                xml_events += " ></PSRecordset> ";
            });
        }
            
        xml_events += "</Root>";
        
        if(grid_status) {
            if (is_checked)
                data = {"action": "spa_alert_actions", "flag":"i", "xml_events":xml_events, "alert_id": alert_id, "tsql": tsql};
            else
                data = {"action": "spa_alert_actions", "flag":"i", "xml":xml, "xml_events":xml_events, "alert_id": alert_id};
            
            if(delete_grid_name != ""){
    			del_msg =  "Some data has been deleted from " + delete_grid_name + " grid. Are you sure you want to save?";
                dhtmlx.message({
                    type: "confirm-warning",
                    title: "Warning",
                    ok: "Confirm",
                    text: del_msg,
                    callback: function(result) {
                        if (result)
                            result = adiha_post_data('alert', data, "", "", "","",del_msg)
                    }
                });
    		} else {
                adiha_post_data("alert", data, "", "", "");
            }
        }
        delete_grid_name = "";
    }
    
    alert_actions.validate_form_grid = function(attached_obj,grid_label) {;
    	var status = true;
    	for (var i = 0;i < attached_obj.getRowsNum();i++){
    		var row_id = attached_obj.getRowId(i);
    		for (var j = 0;j < attached_obj.getColumnsNum();j++){ 
    			var validation_message = attached_obj.cells(row_id,j).getAttribute("validation");
    			if(validation_message != "" && validation_message != undefined){
    				var column_text = attached_obj.getColLabel(j);
    				error_message = "Data Error in <b>"+grid_label+"</b> grid. Please check the data in column <b>"+column_text+"</b> and resave.";
    				dhtmlx.alert({title:"Alert",type:"alert",text: error_message});
    				status = false; break;
    			}
    		}
    		if(validation_message != "" && validation_message != undefined){ break;};
    	} 
    	return status;
    }
</script>
<style type="text/css">
    html, body {
        width: 100%;
        height: 100%;
        margin: 0px;
        padding: 0px;
        background-color: #ebebeb;
        overflow: hidden;
    }
</style>