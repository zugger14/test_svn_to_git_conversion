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
	
	$rights_relation_add_save = 10122513;
	$rights_relation_delete = 10122514;
	
	
	list (
		$has_rights_relation_add_save,
		$has_rights_relation_delete
	) = build_security_rights(
		$rights_relation_add_save,
		$rights_relation_delete
	);

    
    $form_namespace = 'alert_relations';

    $layout_json = '[{id: "a", header:true, text:"Relationship"}]';
    $menu_json = '[{id:"t1", text:"Edit", img:"edit.gif", imgdis:"edit_dis.gif", items:[
                    {id:"add", text:"Add", img:"add.gif", imgdis:"add_dis.gif", enabled: "' . $has_rights_relation_add_save . '"},
                    {id:"delete", text:"Delete", img:"delete.gif", imgdis:"delete_dis.gif", disabled:true}
                ]},{id:"t2", text:"Export", img:"export.gif", imgdis:"export_dis.gif", items:[
                    {id:"excel", text:"Excel", img:"excel.gif"},
                    {id:"pdf", text:"PDF", img:"pdf.gif"}
                ]}]';
    
    $layout_obj = new AdihaLayout();

    echo $layout_obj->init_layout('report', '', '1C', $layout_json, $form_namespace);
    echo $layout_obj->attach_menu_layout_cell('relationship_menu', 'a', $menu_json, $form_namespace.'.menu_click');
    
    $toolbar_obj = new AdihaToolbar();
    $toolbar_name = 'save_toolbar';
    $toolbar_json = '[{id:"save", type:"button", text:"Save", img:"save.gif", imgdis:"save_dis.gif", enabled: "' . $has_rights_relation_add_save . '" }]';
    echo $layout_obj->attach_toolbar($toolbar_name);
    echo $toolbar_obj->init_by_attach($toolbar_name, $form_namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', "onClick", $form_namespace. ".save_click");
    
    $grid_name = 'relationship_grid';
    echo $layout_obj->attach_grid_cell($grid_name, 'a');
    $grid_obj = new AdihaGrid();
    echo $layout_obj->attach_status_bar("a", true);
    echo $grid_obj->init_by_attach($grid_name, $form_namespace);
    echo $grid_obj->set_header("ID,From Table,From Column,To Table,To Column");
    echo $grid_obj->set_columns_ids("alert_table_relation_id,from_table,from_column,to_table,to_column");
    echo $grid_obj->set_column_visibility("true,false,false,false,false");
    echo $grid_obj->set_widths("100,190,190,190,190");
    echo $grid_obj->set_column_types("ro,combo,combo,combo,combo");
    echo $grid_obj->enable_multi_select();
    echo $grid_obj->enable_paging(100, 'pagingArea_a', 'true');
    echo $grid_obj->return_init();
    echo $grid_obj->attach_event('', 'onSelectStateChanged', $form_namespace.'.grid_select');
    
    echo $layout_obj->close_layout();
?>
<script type="text/javascript">
    var mode = '<?php echo $mode; ?>';
    var alert_id = '<?php echo $alert_id; ?>';
    var delete_grid_name = '';
	var	has_rights_relation_add_save = <?php echo (($has_rights_relation_add_save) ? $has_rights_relation_add_save : '0'); ?>;
	var	has_rights_relation_delete = <?php echo (($has_rights_relation_add_save) ? $has_rights_relation_add_save : '0'); ?>;
    
    $(function(){
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
        var combo_obj = alert_relations.relationship_grid.getColumnCombo(3);
        combo_obj.enableFilteringMode("between", null, false);
        combo_obj.load(url);
        
        var cm_param = {
                            "action": "[spa_generic_mapping_header]", 
                            "flag": "n",
                            "combo_sql_stmt": "SELECT art.alert_rule_table_id [table_id]," +
                                                " art.table_alias + '.' + atd.logical_table_name [table_name]" +
                                                " FROM alert_rule_table art" +
                                                " INNER JOIN alert_table_definition atd ON  atd.alert_table_definition_id = art.table_id" +
                                                " WHERE art.alert_id = " + alert_id + " AND art.root_table_id IS NOT NULL",
                            "call_from": "grid"
                        };

        cm_param = $.param(cm_param);
        var url = js_dropdown_connector_url + '&' + cm_param;
        var combo_obj = alert_relations.relationship_grid.getColumnCombo(1);
        combo_obj.enableFilteringMode("between", null, false);
        combo_obj.load(url, function() {
            //Load Relation Grid Data
            var sql_param = {
                "flag": "s",
                "action":"spa_alert_table_relation",
                "grid_type":"g",
                "alert_id": alert_id
            };
            sql_param = $.param(sql_param);
            var sql_url = js_data_collector_url + "&" + sql_param;
            alert_relations.relationship_grid.clearAll();
            alert_relations.relationship_grid.load(sql_url, function(){
                alert_relations.relationship_grid.forEachRow(function(id) {
                    var from_value = alert_relations.relationship_grid.cells(id,1).getValue();
                    var to_value = alert_relations.relationship_grid.cells(id,3).getValue();
                    load_column_combo(from_value, id, 2);
                    load_column_combo(to_value, id, 4);
                });
                alert_relations.relationship_grid.attachEvent("onCellChanged", alert_relations.cell_change);
            });
        });
    });
    
    function load_column_combo(nValue, row_index, col_index) {
        var cm_param = {
                            "action": "[spa_generic_mapping_header]", 
                            "flag": "n",
                            "combo_sql_stmt": "SELECT acd.alert_columns_definition_id [column_id], " +
                                            	       "acd.column_name [column_name] " +
                                            	"FROM alert_rule_table art " +
                                                "INNER JOIN alert_table_definition atd ON atd.alert_table_definition_id = art.table_id " +
                                                "INNER JOIN alert_columns_definition acd ON acd.alert_table_id = atd.alert_table_definition_id " +
                                            	"WHERE art.alert_id = " + alert_id + " AND art.alert_rule_table_id = " + nValue,
                            "call_from": "grid"
                        };

        cm_param = $.param(cm_param);
        var url = js_dropdown_connector_url + '&' + cm_param;
        var combo_obj = alert_relations.relationship_grid.cells(row_index,col_index).getCellCombo();                
        combo_obj.attachEvent("onXLE", function() {
            var column_id = alert_relations.relationship_grid.cells(row_index,col_index).getValue();
            var is_exist = combo_obj.getIndexByValue(column_id);
            
            if (is_exist != -1)
                alert_relations.relationship_grid.cells(row_index,col_index).setValue(column_id);
            else
                alert_relations.relationship_grid.cells(row_index,col_index).setValue('');
        });
        combo_obj.enableFilteringMode("between", null, false);
        combo_obj.load(url);
    }
    
    alert_relations.cell_change = function(rId,cInd,nValue) {
        if(cInd == 1) {            
            load_column_combo(nValue, rId, 2);
        } else if (cInd == 3) {
            load_column_combo(nValue, rId, 4);
        }
    }
    
    alert_relations.grid_select = function(row_id,ind) {
        if (alert_relations.relationship_grid.getSelectedRowId() == null)
            alert_relations.relationship_menu.setItemDisabled("delete");
        else
		if (has_rights_relation_delete) {
            alert_relations.relationship_menu.setItemEnabled("delete");
			}
    }
    
    alert_relations.menu_click = function(id) {
        switch(id) {
            case "add":
                var newId = (new Date()).valueOf();
                alert_relations.relationship_grid.addRow(newId,"");
                alert_relations.relationship_grid.selectRowById(newId);
				if (has_rights_relation_delete) {
                alert_relations.relationship_menu.setItemEnabled("delete");
				}
                break;
            case "delete":
                var del_ids = alert_relations.relationship_grid.getSelectedRowId();
                var previously_xml = alert_relations.relationship_grid.getUserData("", "deleted_xml");
                var grid_xml = "";
                if (previously_xml != null) {
                    grid_xml += previously_xml
                }             
                var del_array = new Array();             
                del_array = (del_ids.indexOf(",") != -1) ? del_ids.split(",") : del_ids.split();             
                $.each(del_array, function(index, value) {
                    if((alert_relations.relationship_grid.cells(value,0).getValue() != "") || (alert_relations.relationship_grid.getUserData(value,"row_status") != "")){             			
                        grid_xml += "<GridRow ";                 		
                        for(var cellIndex = 0; cellIndex < alert_relations.relationship_grid.getColumnsNum(); cellIndex++){
                            grid_xml += " " + alert_relations.relationship_grid.getColumnId(cellIndex) + '="' + alert_relations.relationship_grid.cells(value,cellIndex).getValue() + '"';                     	
                        }                 	
                        grid_xml += " ></GridRow> ";                 
                    }             
                });
                alert_relations.relationship_grid.setUserData("", "deleted_xml", grid_xml);
                alert_relations.relationship_grid.deleteSelectedRows();
                alert_relations.relationship_menu.setItemDisabled("delete");
                break;
            case "excel":
                alert_relations.relationship_grid.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                break;
            case "pdf":
                alert_relations.relationship_grid.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                break;
        }
    }
    
    alert_relations.save_click = function(id) {
        switch(id) {
            case "save":
                save_alert_relation();
                break;
            default:
                break;
        }
    }
    
    function save_alert_relation() {
        alert_relations.relationship_grid.clearSelection();
        var deleted_xml = alert_relations.relationship_grid.getUserData("","deleted_xml");
        
        var grid_xml = "<Root>";
        var grid_label = "Alert Relations"; 
        if(deleted_xml != null && deleted_xml != "") {
            if (delete_grid_name == "") {
                delete_grid_name = grid_label
            } else {
                delete_grid_name += "," + grid_label
            }
		}
        
        alert_relations.relationship_grid.setSerializationLevel(false,false,true,true,true,true);
        attached_obj = alert_relations.relationship_grid;
        var grid_status = alert_relations.validate_form_grid(attached_obj,grid_label);
        
        if(grid_status){
            var num_rows = alert_relations.relationship_grid.getRowsNum();
            
            alert_relations.relationship_grid.forEachRow(function(id) {
                grid_xml += "<PSRecordset ";
                for(var cellIndex = 0; cellIndex < alert_relations.relationship_grid.getColumnsNum(); cellIndex++){
                    grid_xml += " " + alert_relations.relationship_grid.getColumnId(cellIndex) + '="' + alert_relations.relationship_grid.cells(id,cellIndex).getValue() + '"';
                }
                grid_xml += " ></PSRecordset> ";
            });
        }
        
        grid_xml += "</Root>";
        //alert(grid_xml);return;
        if(grid_status) {
            data = {"action": "spa_alert_table_relation", "flag":"i", "xml":grid_xml, "alert_id": alert_id};
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
		deleted_xml = alert_relations.relationship_grid.setUserData("","deleted_xml", "");
    }
    
    alert_relations.validate_form_grid = function(attached_obj,grid_label) {;
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