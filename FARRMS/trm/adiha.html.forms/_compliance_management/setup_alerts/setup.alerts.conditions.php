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
    $condition_id = get_sanitized_value($_GET["condition_id"] ?? '');
    
    $has_rights = get_sanitized_value($_REQUEST["right_id"] ?? '');

    if ($has_rights != 0) {
        $rights = 'true';
    } else {
        $rights = 'false';
    }
    
    if ($mode == 'u') {
        $sql = "EXEC spa_alert_conditions @flag='a', @rules_id=$alert_id, @alert_conditions_id=$condition_id";
        $return_value = readXMLURL2($sql);
        $name = $return_value[0]['alert_conditions_name'];
        $description = $return_value[0]['alert_conditions_description'];
    } else {
        $name = '';
        $description = '';
    }
    
    $form_namespace = 'alert_conditions';

    $layout_json = '[{id: "a", header:false, text:"Conditions", height:70},{id: "b", header:true, text:"Details"}]';
    
    $layout_obj = new AdihaLayout();

    echo $layout_obj->init_layout('report', '', '2E', $layout_json, $form_namespace);
    
    $toolbar_obj = new AdihaToolbar();
    $toolbar_name = 'save_toolbar';
    $toolbar_json = '[{id:"save", type:"button", text:"Save", img:"save.gif", imgdis:"save_dis.gif", enabled:'.$rights.'}]';
    echo $layout_obj->attach_toolbar($toolbar_name);
    echo $toolbar_obj->init_by_attach($toolbar_name, $form_namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', "onClick", $form_namespace. ".save_click");
    
    //Detail
    $detail_menu_json = '[{id:"t1", text:"Edit", img:"edit.gif", imgdis:"edit_dis.gif", disabled:false, items:[
                    {id:"add", text:"Add", img:"add.gif", imgdis:"add_dis.gif", enabled:'.$rights.'},
                    {id:"delete", text:"Delete", img:"delete.gif", imgdis:"delete_dis.gif", disabled:true}
                ]},{id:"t2", text:"Export", img:"export.gif", imgdis:"export_dis.gif", items:[
                    {id:"excel", text:"Excel", img:"excel.gif"},
                    {id:"pdf", text:"PDF", img:"pdf.gif"}
                ]},
                //{ id: "save", img: "save.gif", imgdis: "save_dis.gif",text:"Save", title: "Save", disabled: "true"}
                ]';
    echo $layout_obj->attach_menu_layout_cell('conditions_detail_menu', 'b', $detail_menu_json, $form_namespace.'.detail_menu_click');
    
    $form_name = "condition_form";
    $form_json = '[{
                        "type": "settings",
                        "position": "label-top"
                    }, {
                        type: "block",
                        blockOffset: '.$ui_settings['block_offset'].',
                        list: [{
                            "type": "input",
                            "name": "alert_conditions_name",
                            "label": "Name",
                            "validate": "NotEmptywithSpace",
                            "hidden": "false",
                            "disabled": "false",
                            "position": "label-top",
                            "offsetLeft": '.$ui_settings['offset_left'].',
                            "labelWidth": "auto",
                            "inputWidth": '.$ui_settings['field_size'].',
                            "required": true,
                            "tooltip": "Name",
                            "value": "'.$name.'",
                            "userdata": {
                                "validation_message": "Required Field "
                            },
                        }, , {
                            "type": "newcolumn"
                        },
                        {
                            "type": "input",
                            "name": "alert_conditions_description",
                            "label": "Description",
                            "validate": "NotEmptywithSpace",
                            "hidden": "false",
                            "disabled": "false",
                            "position": "label-top",                           
                            "offsetLeft": '.$ui_settings['offset_left'].',
                            "labelWidth": "auto",
                            "inputWidth": '.$ui_settings['field_size'].',
                            "required": false,
                            "tooltip": "Description",
                            "value": "'.$description.'"
                        }]
                    }]';
    $form_obj = new AdihaForm();
    echo $layout_obj->attach_form($form_name, 'a');
    echo $form_obj->init_by_attach($form_name, $form_namespace);
    echo $form_obj->load_form($form_json);
    
    $grid_name = 'AlertConditionDetail';
    echo $layout_obj->attach_grid_cell($grid_name, 'b');
    $detail_grid_obj = new GridTable($grid_name);
    echo $layout_obj->attach_status_bar("b", true);
    echo $detail_grid_obj->init_grid_table($grid_name, $form_namespace);
    echo $detail_grid_obj->return_init();
    echo $detail_grid_obj->load_grid_data('', '', '', '');
    echo $detail_grid_obj->enable_multi_select();
    echo $detail_grid_obj->enable_paging(25, 'pagingArea_b', 'true');
    echo $detail_grid_obj->attach_event('', 'onSelectStateChanged', $form_namespace.'.AlertConditionDetail_select');
                    
    echo $layout_obj->close_layout();
?>
<script type="text/javascript">
    var has_rights_conditions_iu = <?php echo (($rights) ? $rights : '0'); ?>;
    var mode = '<?php echo $mode; ?>';
    var alert_id = '<?php echo $alert_id; ?>';
    var alert_conditions_id = '<?php echo $condition_id; ?>';
    
    var delete_grid_name = "";
    var cell_change_event = '';
    
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
    
    $(function(){
        //Table List
        var cm_param = {
                            "action": "[spa_generic_mapping_header]", 
                            "flag": "n",
                            "combo_sql_stmt": "SELECT art.alert_rule_table_id [table_id]," +
                                                " art.table_alias + '.' + atd.logical_table_name [table_name]" +
                                                " FROM alert_rule_table art" +
                                                " INNER JOIN alert_table_definition atd ON  atd.alert_table_definition_id = art.table_id" +
                                                " WHERE art.alert_id = " + alert_id,
                            "call_from": "grid"
                        };

        cm_param = $.param(cm_param);
        var url = js_dropdown_connector_url + '&' + cm_param;
        var combo_obj = alert_conditions.AlertConditionDetail.getColumnCombo(2);                
        combo_obj.enableFilteringMode("between", null, false);
        combo_obj.load(url);
        
        refresh_detail_conditions_grid();
    });
    
    alert_conditions.cell_change = function(rId,cInd,nValue) {
        if(cInd == 5) {            
            if(nValue == 8)
                alert_conditions.AlertConditionDetail.setCellExcellType(rId,7,"ed");
            else
                alert_conditions.AlertConditionDetail.setCellExcellType(rId,7,"ro");
        } else if (cInd == 2) {                                 
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
        var combo_obj = alert_conditions.AlertConditionDetail.cells(row_index, 3).getCellCombo();
        
        combo_obj.attachEvent("onXLE", function() {
            var column_id = alert_conditions.AlertConditionDetail.cells(row_index,3).getValue();
            var is_exist = combo_obj.getIndexByValue(column_id);
            
            if (is_exist != -1)
                alert_conditions.AlertConditionDetail.cells(row_index,3).setValue(column_id);
            else
                alert_conditions.AlertConditionDetail.cells(row_index,3).setValue('');
        });
        combo_obj.enableFilteringMode("between", null, false);
        combo_obj.load(url);
    }
    
    function refresh_detail_conditions_grid() {
        alert_conditions.AlertConditionDetail.detachEvent(cell_change_event);
        
        var sql_param = {
                "flag": "s",
                "action":"spa_alert_table_where_clause",
                "grid_type":"g",
                "condition_id": alert_conditions_id,
                "alert_id": alert_id
            };
        sql_param = $.param(sql_param);
        var sql_url = js_data_collector_url + "&" + sql_param;
        alert_conditions.AlertConditionDetail.clearAll();
        alert_conditions.AlertConditionDetail.load(sql_url, function(){
            alert_conditions.AlertConditionDetail.forEachRow(function(id) {
                var nValue = alert_conditions.AlertConditionDetail.cells(id,2).getValue();
                load_column_combo(nValue, id);
                var operator_id = alert_conditions.AlertConditionDetail.cells(id,5).getValue();
                if (operator_id == 8) {
                    alert_conditions.AlertConditionDetail.setCellExcellType(id,7,"ed");
                }
            });
            cell_change_event = alert_conditions.AlertConditionDetail.attachEvent("onCellChanged", alert_conditions.cell_change);
        });
    }
    
    alert_conditions.menu_click = function(id) {
        switch(id) {
            case "add_condition":
                unload_conditions_window();
                if (!conditions_window) {
                    conditions_window = new dhtmlXWindows();
                }
                
                var win = conditions_window.createWindow('w1', 0, 0, 315, 300);
                win.setText("Conditions");
                win.centerOnScreen();
                win.setModal(true);
                win.attachURL('setup.alerts.conditions.iu.php?flag=i&alert_id=' + alert_id, false, true);
                break;
            case "delete_condition":
                var row_id = alert_conditions.conditions_grid.getSelectedRowId();
                var alert_conditions_id = alert_conditions.conditions_grid.cells(row_id,0).getValue();
                
                data = {
                            "action": "spa_alert_conditions", 
                            "flag":"d", 
                            "rules_id": alert_id,
                            "alert_conditions_id": alert_conditions_id
                            };
                adiha_post_data("alert", data, "", "", "delete_callback");
                break;
            case "add":
                var newId = (new Date()).valueOf();
                alert_conditions.conditions_grid.addRow(newId,"");
                alert_conditions.conditions_grid.selectRowById(newId);
                alert_conditions.conditions_menu.setItemEnabled("delete");
                break;
            case "excel":
                alert_conditions.conditions_grid.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                break;
            case "pdf":
                alert_conditions.conditions_grid.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                break;
        }
    }
    
    alert_conditions.detail_menu_click = function(id) {
        switch(id) {
            case "add":
                var newId = (new Date()).valueOf();
                alert_conditions.AlertConditionDetail.addRow(newId,"");
                alert_conditions.AlertConditionDetail.selectRowById(newId);
                alert_conditions.conditions_detail_menu.setItemEnabled("delete");
                break;
            case "delete":
                var del_ids = alert_conditions.AlertConditionDetail.getSelectedRowId();
                var previously_xml = alert_conditions.AlertConditionDetail.getUserData("", "deleted_xml");
                var grid_xml = "";
                if (previously_xml != null) {
                    grid_xml += previously_xml
                }             
                var del_array = new Array();             
                del_array = (del_ids.indexOf(",") != -1) ? del_ids.split(",") : del_ids.split();             
                $.each(del_array, function(index, value) {
                    if((alert_conditions.AlertConditionDetail.cells(value,0).getValue() != "") || (alert_conditions.AlertConditionDetail.getUserData(value,"row_status") != "")){             			
                        grid_xml += "<GridRow ";                 		
                        for(var cellIndex = 0; cellIndex < alert_conditions.AlertConditionDetail.getColumnsNum(); cellIndex++){
                            grid_xml += " " + alert_conditions.AlertConditionDetail.getColumnId(cellIndex) + '="' + alert_conditions.AlertConditionDetail.cells(value,cellIndex).getValue() + '"';                     	
                        }                 	
                        grid_xml += " ></GridRow> ";                 
                    }             
                });
                alert_conditions.AlertConditionDetail.setUserData("", "deleted_xml", grid_xml);
                alert_conditions.AlertConditionDetail.deleteSelectedRows();
                alert_conditions.conditions_detail_menu.setItemDisabled("delete");
                break;
            case "excel":
                alert_conditions.AlertConditionDetail.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                break;
            case "pdf":
                alert_conditions.AlertConditionDetail.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                break;
            case "save":
                save_alert_condtions_details();
                break;
        }
    }
    
    alert_conditions.AlertConditionDetail_select = function(row_id,ind) {
        if (alert_conditions.AlertConditionDetail.getSelectedRowId() == null) {
            alert_conditions.conditions_detail_menu.setItemDisabled("delete");
        } else {
            if (has_rights_conditions_iu)
                alert_conditions.conditions_detail_menu.setItemEnabled("delete");
        }
    }
    
    function save_alert_condtions_details() {
        alert_conditions.AlertConditionDetail.clearSelection();
        var grid_label = "Condition Details"; 
        
        var deleted_xml = alert_conditions.AlertConditionDetail.getUserData("","deleted_xml");
        
        if(deleted_xml != null && deleted_xml != "") {
            if (delete_grid_name == "") {
                delete_grid_name = grid_label
            } else {
                delete_grid_name += "," + grid_label
            }
		}
    
        alert_conditions.AlertConditionDetail.setSerializationLevel(false,false,true,true,true,true);
        attached_obj = alert_conditions.AlertConditionDetail;
        var grid_status = alert_conditions.validate_form_grid(attached_obj,grid_label);
            
        //alert(grid_xml);return;
        if(grid_status) {
            var attached_obj = alert_conditions.condition_form;
            var status = validate_form(attached_obj);
            if (!status) {
                generate_error_message();
            };
            
            if (status) {
                var alert_conditions_name = alert_conditions.condition_form.getItemValue('alert_conditions_name');
                var alert_conditions_description = alert_conditions.condition_form.getItemValue('alert_conditions_description');
                
                if(mode == 'i') {
                    data = {
                            "action": "spa_alert_conditions", 
                            "flag":"i", 
                            "rules_id": alert_id,
                            "alert_conditions_name": alert_conditions_name,
                            "alert_conditions_description": alert_conditions_description
                            };
                } else {
                    data = {
                            "action": "spa_alert_conditions", 
                            "flag":"u", 
                            "rules_id": alert_id,
                            "alert_conditions_id": alert_conditions_id,
                            "alert_conditions_name": alert_conditions_name,
                            "alert_conditions_description": alert_conditions_description
                            };
                }
                
                if(delete_grid_name != ""){
        			del_msg =  "Some data has been deleted from " + delete_grid_name + " grid. Are you sure you want to save?";
                    dhtmlx.message({
                        type: "confirm-warning",
                        title: "Warning",
                        ok: "Confirm",
                        text: del_msg,
                        callback: function(result) {
                            if (result)
                                result = adiha_post_data('return_array', data, "", "", "save_details","",del_msg)
                        }
                    });
        		} else {
                    adiha_post_data("return_array", data, "", "", "save_details");
                }
                
                delete_grid_name = "";
        		deleted_xml = alert_conditions.AlertConditionDetail.setUserData("","deleted_xml", "");
            } 
            enable_save();
        } 
    }
    
    alert_conditions.validate_form_grid = function(attached_obj,grid_label) {;
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
    
    alert_conditions.save_click = function(id) {
        switch(id) {
            case "save":
                alert_conditions.save_toolbar.disableItem('save');
                save_alert_condtions_details();
                break;
        }
    }
    
    function save_details(result) {
        if (result[0][0] == 'Success') {
            mode = 'u';
            alert_conditions_id = result[0][5];
            
            var grid_xml = "<Root>"; 
            var num_rows = alert_conditions.AlertConditionDetail.getRowsNum();
                
            alert_conditions.AlertConditionDetail.forEachRow(function(id) {
                grid_xml += "<PSRecordset ";
                for(var cellIndex = 0; cellIndex < alert_conditions.AlertConditionDetail.getColumnsNum(); cellIndex++){
                    grid_xml += " " + alert_conditions.AlertConditionDetail.getColumnId(cellIndex) + '="' + alert_conditions.AlertConditionDetail.cells(id,cellIndex).getValue() + '"';
                }
                grid_xml += " ></PSRecordset> ";
            });
            grid_xml += "</Root>";
            data = {"action": "spa_alert_table_where_clause", "flag":"i", "xml":grid_xml, "alert_id": alert_id, "condition_id": alert_conditions_id};
            adiha_post_data("alert", data, "", "", "enable_save");
            setTimeout(function() { 
                window.parent.conditions_window.window('w1').close();
            }, 1000);
        } else {
            error_message = result[0][4];
            dhtmlx.alert({
                            title:"Alert",
                            type:"alert",
                            text:error_message
                        });
        }
    }
    
    function enable_save() {
        alert_conditions.save_toolbar.enableItem('save');
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