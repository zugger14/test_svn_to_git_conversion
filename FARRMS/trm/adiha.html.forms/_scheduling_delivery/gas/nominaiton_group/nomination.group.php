<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
	 <?php  require('../../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
<?php
	$form_namespace = 'assign_priority_to_nomination';
	$form_obj = new AdihaStandardForm($form_namespace, 10165000);
	$form_obj->define_grid("assign_priority_to_nomination_group", "", "g", '');
	$form_obj->hide_edit_menu();
	echo $form_obj->init_form("Nomination Groups","Nomination Groups");
	echo $form_obj->close_form();
?>

<script type="text/javascript">
	assign_priority_to_nomination.tab_toolbar_click = function(id) {
 		var validation_status = 0;
 		switch(id) {
        	case "close":
        		var tab_id = assign_priority_to_nomination.tabbar.getActiveTab();
             	delete assign_priority_to_nomination.pages[tab_id];
             	assign_priority_to_nomination.tabbar.tabs(tab_id).close(true);
             	break;
        	case "save":
				var tab_id = assign_priority_to_nomination.tabbar.getActiveTab();
				var win = assign_priority_to_nomination.tabbar.cells(tab_id);
				var valid_status = 1;
				var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
				object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(" ", ""));
				var tab_obj = win.tabbar[object_id];
				var detail_tabs = tab_obj.getAllTabs();
                var tabsCount = tab_obj.getNumberOfTabs();
				var grid_xml = "<GridGroup>";
				var form_xml = "<FormXML ";
                var form_status = true;
                var first_err_tab;
             	$.each(detail_tabs, function(index,value) {
                 	layout_obj = tab_obj.cells(value).getAttachedObject();
                 	layout_obj.forEachItem(function(cell){
                     	attached_obj = cell.getAttachedObject();
                     		if (attached_obj instanceof dhtmlXGridObject) {
                         		attached_obj.clearSelection();
                         		var ids = attached_obj.getChangedRows(true);
                         		grid_id = attached_obj.getUserData("","grid_id");
                         		grid_label = attached_obj.getUserData("","grid_label");
                         		deleted_xml = attached_obj.getUserData("","deleted_xml");
                         		if(deleted_xml != null && deleted_xml != "") {
                             		grid_xml += "<GridDelete grid_id=\""+ grid_id + "\" grid_label=\"" + grid_label + "\">";
                             		grid_xml += deleted_xml;
                             		grid_xml += "</GridDelete>";
                             		if(delete_grid_name == "") {
                             			delete_grid_name = grid_label;
                             		} else { 
                             			delete_grid_name += "," + grid_label
                             		};
                         		};
                         		if(ids != "") {
                             		attached_obj.setSerializationLevel(false,false,true,true,true,true);
                              		if(valid_status != 0){
                            			var grid_status = assign_priority_to_nomination.validate_form_grid(attached_obj,grid_label);
                            		}
                             		grid_xml += "<Grid grid_id=\""+ grid_id + "\">";
                             		var changed_ids = new Array();
                             		changed_ids = ids.split(",");
                             		if(grid_status){
                             			$.each(changed_ids, function(index, value) {
                                 			attached_obj.setUserData(value,"row_status","new row");
                                 			grid_xml += "<GridRow ";
                                 			for(var cellIndex = 0; cellIndex < attached_obj.getColumnsNum(); cellIndex++){
                                     			if (attached_obj.cells(value, cellIndex).getValue() == 'undefined') { //Cannot use typeof because it returns string
                                         			grid_xml += " " + attached_obj.getColumnId(cellIndex) + '= "NULL"';
                                         			continue;
                                     			}
                                     			// nomination group string value replaced by nomination group id 
                                     			if (cellIndex  == 1) {
                                     				grid_xml += " " + attached_obj.getColumnId(cellIndex) + '="' + object_id + '"';
                                     			} else {
                                     				grid_xml += " " + attached_obj.getColumnId(cellIndex) + '="' + attached_obj.cells(value,cellIndex).getValue() + '"';
                                     			}
                                 			}
                                 			grid_xml += " ></GridRow> ";
                             			});
                             			grid_xml += "</Grid>";
                             		} else { valid_status = 0; };
                         		}
                     		} else if(attached_obj instanceof dhtmlXForm) {
                                if (detail_tabs.length > 1) {
                                           active_tab_object =  tab_obj.cells(value);
                                        } else {
                                            active_tab_object = '';
                                        }
                          		var status = validate_form(attached_obj);
                                form_status = form_status && status; 
                                if (tabsCount == 1 && !status) {
                                     first_err_tab = "";
                                } else if ((!first_err_tab) && !status) {
                                    first_err_tab = active_tab_object;
                                }
								if(validation_status == 0){
							     	if (!status) {
							         	validation_status = 1;
							     	};
								};
         						if(status) { 
                                    win.getAttachedToolbar().disableItem('save');
            
                         			data = attached_obj.getFormData();
		                         	for (var a in data) {
		                             	field_label = a;
		                             	if(attached_obj.getItemType(field_label) == "calendar") {
		                                 	field_value = attached_obj.getItemValue(field_label,true);
		                             	} else {
		                             		field_value = data[a];
		                             	}
		                             	form_xml += " " + field_label + "=\"" + field_value + "\"";
	                             	}
	                            } else { 
	                            	valid_status = 0;
	                            }
	                        }
	                    });
             		});
             		form_xml += "></FormXML>";
             		grid_xml += "</GridGroup>";
             		var xml = "<Root function_id=\"10165000\" object_id=\"" + object_id + "\">";
	             	xml += form_xml;
	             	xml += grid_xml;
	             	xml += "</Root>";
	             	xml = xml.replace(/'/g, "\"");
	             	if(valid_status == 1){
             			data = {"action": "spa_process_form_data", "xml":xml}
                 		if(delete_grid_name != ""){
                     		del_msg =  "Some data has been deleted from " + delete_grid_name + " grid. Are you sure you want to save?";
                     		result = adiha_post_data("confirm-warning", data, "", "", "assign_priority_to_nomination.post_callback","",del_msg);
                 		} else {
                     		result = adiha_post_data("alert", data, "", "", "assign_priority_to_nomination.post_callback");
                 		}
                 		delete_grid_name = "";
                 		deleted_xml = attached_obj.setUserData("","deleted_xml", "");
             		}

                    if (!form_status) {
                        generate_error_message(first_err_tab);
                    }
         		break;
        	default:
        		break;
        }
    };
</script>

<body>
</body>

</html>