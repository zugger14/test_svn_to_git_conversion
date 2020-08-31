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
	$rights_meter_mapping = 10105894;
	
   list ($has_rights_meter_mapping)= 
   build_security_rights($rights_meter_mapping);
	
    $counterparty_id = get_sanitized_value($_GET["counterparty_id"] ?? '');
    $counterparty_contact_id = get_sanitized_value($_GET["counterparty_contact_id"] ?? '');
    $privilege = (isset($_GET["privilege"])) ? get_sanitized_value($_GET["privilege"]) : $has_rights_meter_mapping;
    
    if ($privilege == 0) {
        $has_rights_meter_mapping = 0;
    }
    
    $sql = "EXEC spa_source_counterparty_maintain @flag='b', @counterparty_id = $counterparty_id";
    $return_value = readXMLURL2($sql);
    $counterparty_type = $return_value[0]['int_ext_flag'];
    
    $form_namespace = 'meter_mapping';

    $layout_json = '[
                        {
                            id: "a", 
                            header:true, 
                            text:"Contract Allocation", 
                            width:300
                        },
                        {
                            id: "b", 
                            header:true, 
                            text:"Meter Allocation"
                        }
                    ]';
    $menu_json = '[
                    {id:"t1", text:"Edit", img:"edit.gif", imgdis:"edit_dis.gif", items:[
                    {id:"add", text:"Add", img:"add.gif", imgdis:"add_dis.gif",enabled:"' . $has_rights_meter_mapping . '"},
                    {id:"delete", text:"Delete", img:"delete.gif", imgdis:"delete_dis.gif", disabled:true}
                    ]},
                    {id:"t2", text:"Export", img:"export.gif", imgdis:"export_dis.gif", items:[
                    {id:"excel", text:"Excel", img:"excel.gif"},
                    {id:"pdf", text:"PDF", img:"pdf.gif"}
                    ]},
                    {id: "save", img: "save.gif", imgdis: "save_dis.gif",text:"Save", title: "Save",enabled:"' . $has_rights_meter_mapping . '"}
                  ]';
    
    $layout_obj = new AdihaLayout();

    echo $layout_obj->init_layout('meter_mapping', '', '2E', $layout_json, $form_namespace);
    echo $layout_obj->attach_menu_layout_cell('contract_menu', 'a', $menu_json, $form_namespace.'.contract_menu_click');
    
    $grid_name = 'ContractAllocation';
    echo $layout_obj->attach_grid_cell($grid_name, 'a');
    
    echo $layout_obj->attach_status_bar("a", true);
    $grid_obj = new GridTable($grid_name);
    echo $grid_obj->init_grid_table($grid_name, $form_namespace); 
    echo $grid_obj->return_init();
    echo $grid_obj->load_grid_data('', $counterparty_id, '', $form_namespace.'.contract_grid_callback');
    echo $grid_obj->enable_multi_select();
    echo $grid_obj->enable_paging(10, 'pagingArea_a', 'true');
    echo $grid_obj->attach_event("","onSelectStateChanged", $form_namespace.'.contract_grid_select');
    
    //Meter Allocation
    $detail_menu_json = '[{id:"t1", text:"Edit", img:"edit.gif", imgdis:"edit_dis.gif", disabled:true, items:[
                    {id:"add", text:"Add", img:"add.gif", imgdis:"add_dis.gif", enabled:"' . $has_rights_meter_mapping . '"},
                    {id:"delete", text:"Delete", img:"delete.gif", imgdis:"delete_dis.gif", disabled:true}
                ]},{id:"t2", text:"Export", img:"export.gif", imgdis:"export_dis.gif", items:[
                    {id:"excel", text:"Excel", img:"excel.gif"},
                    {id:"pdf", text:"PDF", img:"pdf.gif"}
                ]},
                { id: "save", img: "save.gif", imgdis: "save_dis.gif",text:"Save", title: "Save", disabled: "true",enabled:"' . $has_rights_meter_mapping . '"}]';
    echo $layout_obj->attach_menu_layout_cell('meter_menu', 'b', $detail_menu_json, $form_namespace.'.meter_menu_click');
    
    $grid_name = 'MeterAllocation';
    echo $layout_obj->attach_grid_cell($grid_name, 'b');
    echo $layout_obj->attach_status_bar("b", true);
    $grid_obj = new GridTable($grid_name);
    echo $grid_obj->init_grid_table($grid_name, $form_namespace);
    echo $grid_obj->return_init();
    echo $grid_obj->load_grid_data('', '', '', $form_namespace.'.meter_grid_callback');
    echo $grid_obj->enable_multi_select();
    echo $grid_obj->enable_paging(10, 'pagingArea_b', 'true');
    echo $grid_obj->attach_event("","onSelectStateChanged", $form_namespace.'.meter_grid_select');
                    
    echo $layout_obj->close_layout();
?>
<script type="text/javascript">
    var counterparty_id = '<?php echo $counterparty_id; ?>';
    var counterparty_type = '<?php echo $counterparty_type; ?>';
    var counterparty_contact_id = '<?php echo $counterparty_contact_id; ?>';
	var has_rights_meter_mapping =<?php echo (($has_rights_meter_mapping) ? $has_rights_meter_mapping : '0'); ?>;
    var delete_grid_name = "";
    
    $(function(){
        if (!has_rights_meter_mapping){
     meter_mapping.contract_menu.setItemDisabled("add");
    }
    });
	
	
    
    meter_mapping.contract_grid_callback = function() {
        if(counterparty_contact_id == -1) {
            select_row = 0;
        } else {
            select_row = meter_mapping.ContractAllocation.findCell(counterparty_contact_id,0,true);
        }
        
        meter_mapping.ContractAllocation.selectRow(select_row[0][0]);
		if(!has_rights_meter_mapping){
            meter_mapping.contract_menu.setItemDisabled("t1");
		}
    }
    
    meter_mapping.contract_grid_select = function(row_id,ind) {
        if (meter_mapping.ContractAllocation.getSelectedRowId() == null) {
            meter_mapping.contract_menu.setItemDisabled("delete");
			meter_mapping.contract_menu.setItemDisabled("add");
		    meter_mapping.meter_menu.setItemDisabled("save");
            meter_mapping.meter_menu.setItemDisabled("t1");
        } else {
			if(has_rights_meter_mapping){
            meter_mapping.meter_menu.setItemEnabled("t1");
            meter_mapping.meter_menu.setItemEnabled("save");            
            meter_mapping.contract_menu.setItemEnabled("delete");
			}
        }
        refresh_meter_allocation_grid();
    }
    
    function refresh_contract_allocation_grid() {
        var sql_param = {
                "action":"spa_counterparty_contract",
                "flag": "s",
                "grid_type":"g",
                "ppa_counterparty_id": counterparty_id
            };
        sql_param = $.param(sql_param);
        var sql_url = js_data_collector_url + "&" + sql_param;
        meter_mapping.ContractAllocation.clearAll();
        meter_mapping.ContractAllocation.load(sql_url, meter_mapping.contract_grid_callback);
    }
    
    function refresh_meter_allocation_grid() {
        var selected_row_id = meter_mapping.ContractAllocation.getSelectedRowId();
        if (selected_row_id != null)
            var generator_id = meter_mapping.ContractAllocation.cells(selected_row_id,0).getValue();
        else 
            var generator_id = '';
        
        var sql_param = {
                "action":"spa_recorder_generator_map",
                "flag": "s",
                "grid_type":"g",
                "generator_id": generator_id
            };
        sql_param = $.param(sql_param);
        var sql_url = js_data_collector_url + "&" + sql_param;
        meter_mapping.MeterAllocation.clearAll();
        meter_mapping.MeterAllocation.load(sql_url);
    }
    
    meter_mapping.contract_menu_click = function(id) {
        switch(id) {
            case "add":
                var newId = (new Date()).valueOf();
                meter_mapping.ContractAllocation.addRow(newId,"");
                meter_mapping.ContractAllocation.selectRowById(newId);
                meter_mapping.ContractAllocation.forEachRow(function(row){
                    meter_mapping.ContractAllocation.forEachCell(row,function(cellObj,ind){
                        meter_mapping.ContractAllocation.validateCell(row,ind)
        			});
        		});
				if(has_rights_meter_mapping){
                meter_mapping.contract_menu.setItemEnabled("delete");
				}
                break;
            case "delete":
                var del_ids = meter_mapping.ContractAllocation.getSelectedRowId();
                var previously_xml = meter_mapping.ContractAllocation.getUserData("", "deleted_xml");
                var grid_xml = "";
                if (previously_xml != null) {
                    grid_xml += previously_xml
                }             
                var del_array = new Array();             
                del_array = (del_ids.indexOf(",") != -1) ? del_ids.split(",") : del_ids.split();             
                $.each(del_array, function(index, value) {
                    if((meter_mapping.ContractAllocation.cells(value,0).getValue() != "") || (meter_mapping.ContractAllocation.getUserData(value,"row_status") != "")){             			
                        grid_xml += "<GridRow ";                 		
                        for(var cellIndex = 0; cellIndex < meter_mapping.ContractAllocation.getColumnsNum(); cellIndex++){
                            grid_xml += " " + meter_mapping.ContractAllocation.getColumnId(cellIndex) + '="' + meter_mapping.ContractAllocation.cells(value,cellIndex).getValue() + '"';                     	
                        }                 	
                        grid_xml += " ></GridRow> ";                 
                    }             
                });
                meter_mapping.ContractAllocation.setUserData("", "deleted_xml", grid_xml);
                meter_mapping.ContractAllocation.deleteSelectedRows();
                meter_mapping.contract_menu.setItemDisabled("delete");
                break;
            case "excel":
                meter_mapping.ContractAllocation.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                break;
            case "pdf":
                meter_mapping.ContractAllocation.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                break;
            case "save":
                save_contract_allocation();
        }
    }
    
    meter_mapping.meter_menu_click = function(id) {
        switch(id) {
            case "add":
                var newId = (new Date()).valueOf();
                meter_mapping.MeterAllocation.addRow(newId,"");
                meter_mapping.MeterAllocation.selectRowById(newId);
                meter_mapping.MeterAllocation.forEachRow(function(row){
                    meter_mapping.MeterAllocation.forEachCell(row,function(cellObj,ind){
                        meter_mapping.MeterAllocation.validateCell(row,ind)
        			});
        		});
				if(has_rights_meter_mapping){
                    meter_mapping.meter_menu.setItemEnabled("delete");
				}
                break;
            case "delete":
                var del_ids = meter_mapping.MeterAllocation.getSelectedRowId();
                var previously_xml = meter_mapping.MeterAllocation.getUserData("", "deleted_xml");
                var grid_xml = "";
                if (previously_xml != null) {
                    grid_xml += previously_xml
                }             
                var del_array = new Array();             
                del_array = (del_ids.indexOf(",") != -1) ? del_ids.split(",") : del_ids.split();             
                $.each(del_array, function(index, value) {
                    if((meter_mapping.MeterAllocation.cells(value,0).getValue() != "") || (meter_mapping.MeterAllocation.getUserData(value,"row_status") != "")){             			
                        grid_xml += "<GridRow ";                 		
                        for(var cellIndex = 0; cellIndex < meter_mapping.MeterAllocation.getColumnsNum(); cellIndex++){
                            grid_xml += " " + meter_mapping.MeterAllocation.getColumnId(cellIndex) + '="' + meter_mapping.MeterAllocation.cells(value,cellIndex).getValue() + '"';                     	
                        }                 	
                        grid_xml += " ></GridRow> ";                 
                    }             
                });
                meter_mapping.MeterAllocation.setUserData("", "deleted_xml", grid_xml);
                meter_mapping.MeterAllocation.deleteSelectedRows();
                meter_mapping.meter_menu.setItemDisabled("delete");
                break;
            case "excel":
                meter_mapping.MeterAllocation.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                break;
            case "pdf":
                meter_mapping.MeterAllocation.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                break;
            case "save":
                save_meter_allocation();
        }
    }
    
    meter_mapping.meter_grid_callback = function(row_id,ind) {
        refresh_meter_allocation_grid();
        meter_mapping.meter_menu.setItemDisabled("delete");
    }
    
    meter_mapping.meter_grid_select = function(row_id,ind) {
        if (meter_mapping.MeterAllocation.getSelectedRowId() == null) {
            meter_mapping.meter_menu.setItemDisabled("delete");
        } else {
			if(has_rights_meter_mapping){
            meter_mapping.meter_menu.setItemEnabled("delete");
			}
        }
    }
    
    function save_meter_allocation() {
        //alert("save");
        var selected_row = meter_mapping.ContractAllocation.getSelectedRowId();
        //alert("sr"+selected_row);
        var generator_id = meter_mapping.ContractAllocation.cells(selected_row,0).getValue();
        meter_mapping.MeterAllocation.clearSelection();
        var ids = meter_mapping.MeterAllocation.getChangedRows(true);
        var grid_status = true;
        var deleted_xml = meter_mapping.MeterAllocation.getUserData("","deleted_xml");
        var grid_xml = "<GridGroup>";
        var grid_label = "Meter Allocation";  
        if(deleted_xml != null && deleted_xml != "") {
			grid_xml += "<GridDelete grid_id=\"recorder_generator_map\" grid_label=\""+ grid_label +"\">";
			grid_xml += deleted_xml;
			grid_xml += "</GridDelete>";
            if (delete_grid_name == "") {
                delete_grid_name = grid_label
            } else {
                delete_grid_name += "," + grid_label
            }
		};       
        if(ids != "") {
            meter_mapping.MeterAllocation.setSerializationLevel(true,true,true,true);
            var attached_obj = meter_mapping.MeterAllocation;
            var grid_status = meter_mapping.validate_form_grid(attached_obj,grid_label);
             
            grid_xml += "<Grid grid_id=\"recorder_generator_map\">";
            var changed_ids = new Array();
            changed_ids = ids.split(",");
            if(grid_status){
                $.each(changed_ids, function(index, value) {
                    grid_xml += "<GridRow ";
                    for(var cellIndex = 0; cellIndex < meter_mapping.MeterAllocation.getColumnsNum(); cellIndex++){
                        if(cellIndex == 0)
                            grid_xml += ' generator_id="' + generator_id + '"';
                        
                        grid_xml += " " + meter_mapping.MeterAllocation.getColumnId(cellIndex) + '="' + meter_mapping.MeterAllocation.cells(value,cellIndex).getValue() + '"';
                    }
                    grid_xml += " ></GridRow> ";
                });
                grid_xml += "</Grid>";
            }
        }
        grid_xml += "</GridGroup>";
        
        if((grid_status) && (grid_xml.indexOf('grid_id') != -1)) {
            meter_mapping.meter_menu.setItemDisabled('save');
            data = {"action": "spa_recorder_generator_map", "flag":"m", "grid_xml":grid_xml};
            if(delete_grid_name != "") {
    			del_msg =  "Some data has been deleted from " + delete_grid_name + " grid. Are you sure you want to save?";
                dhtmlx.message({
                    type: "confirm-warning",
                    title: "Warning",
                    ok: "Confirm",
                    text: del_msg,
                    callback: function(result) {
                        if (result) {
                            result = adiha_post_data('alert', data, "", "", "","",del_msg)
                        } 
                        if (has_rights_meter_mapping) {
                                    meter_mapping.meter_menu.setItemEnabled('save');
                        };
                    }
                });
    		} else {
                adiha_post_data("alert", data, "", "", "");
                if (has_rights_meter_mapping) {
                    meter_mapping.meter_menu.setItemEnabled('save');
                };
                
            }
        }
        delete_grid_name = "";
		deleted_xml = meter_mapping.MeterAllocation.setUserData("","deleted_xml", "");
    }
    
    function save_contract_allocation() {
        var selected_row = meter_mapping.ContractAllocation.getSelectedRowId();
        meter_mapping.ContractAllocation.clearSelection();
        meter_mapping.ContractAllocation.selectRow(selected_row);
        
       /* if (counterparty_type == 'b') {
            var num_row = meter_mapping.ContractAllocation.getRowsNum();
            if(num_row > 1) {
                dhtmlx.message({
                    type: "alert",
                    title: "Alert",
                    text: "Multiple contract cannot be inserted."
                });
                return;    
            }
        }*/
        
        var ids = meter_mapping.ContractAllocation.getChangedRows(true);
        var deleted_xml = meter_mapping.ContractAllocation.getUserData("","deleted_xml");
        var grid_status = true;
        var grid_xml = "<GridGroup>";
        var grid_label = "Contract Allocation"; 
        if(deleted_xml != null && deleted_xml != "") {
			grid_xml += "<GridDelete grid_id=\"rec_generator\" grid_label=\""+ grid_label + "\">";
			grid_xml += deleted_xml;
			grid_xml += "</GridDelete>";
            if (delete_grid_name == "") {
                delete_grid_name = grid_label
            } else {
                delete_grid_name += "," + grid_label
            }
		};
       
        if(ids != "") {
            meter_mapping.ContractAllocation.setSerializationLevel(false,false,true,true,true,true);
            attached_obj = meter_mapping.ContractAllocation;
            var grid_status = meter_mapping.validate_form_grid(attached_obj,grid_label);
             
            grid_xml += "<Grid grid_id=\"rec_generator\">";
            var changed_ids = new Array();
            changed_ids = ids.split(",");
            if(grid_status){
                $.each(changed_ids, function(index, value) {
                    grid_xml += "<GridRow ";
                    for(var cellIndex = 0; cellIndex < meter_mapping.ContractAllocation.getColumnsNum(); cellIndex++){
                        if(cellIndex == 0)
                            grid_xml += ' ppa_counterparty_id="' + counterparty_id + '"';
                        
                        grid_xml += " " + meter_mapping.ContractAllocation.getColumnId(cellIndex) + '="' + meter_mapping.ContractAllocation.cells(value,cellIndex).getValue() + '"';
                    }
                    grid_xml += " ></GridRow> ";
                });
                grid_xml += "</Grid>";
            }
        }
        grid_xml += "</GridGroup>";
        if(grid_status) {
            meter_mapping.contract_menu.setItemDisabled('save');
            data = {"action": "spa_counterparty_contract", "flag":"n", "grid_xml":grid_xml};
            if(delete_grid_name != ""){
    			del_msg =  "Some data has been deleted from " + delete_grid_name + " grid. Are you sure you want to save?";
                dhtmlx.message({
                    type: "confirm-warning",
                    title: "Warning",
                    ok: "Confirm",
                    text: del_msg,
                    callback: function(result) {
                        if (result) {
                            result = adiha_post_data('alert', data, "", "", "contract_allocation_save_callback","",del_msg)
                        } else {
                            meter_mapping.contract_menu.setItemEnabled('save');
                        }
                    } 
                });
    		} else {
                adiha_post_data("alert", data, "", "", "contract_allocation_save_callback");
            }
        }
        delete_grid_name = "";
		deleted_xml = meter_mapping.ContractAllocation.setUserData("","deleted_xml", "");
    }
    
    function contract_allocation_save_callback(result) {
        meter_mapping.contract_menu.setItemEnabled('save');
        if (result[0].errorcode == 'Success') {
            refresh_contract_allocation_grid();
            setTimeout ( function() { 
                window.parent.popup_window.window('w1').close(); 
            }, 1000);
        }
    }
    
    meter_mapping.validate_form_grid = function(attached_obj,grid_label) {;
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