<?php
/**
* Setup location screen
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
    $application_function_id = 10102500;
    $right_location_IU = 10102510;
	$right_location_delete = 10102511;
	$right_manage_privilege = 10102512;
	list (
        $has_rights_location_IU,
		$has_rights_location_delete,
		$has_rights_manage_privilege 
	) = build_security_rights(
        $right_location_IU,
		$right_location_delete,
		$right_manage_privilege);
	
    $source_minor_location_id = get_sanitized_value($_GET['location_id'] ?? '');
    $call_from_combo = get_sanitized_value($_GET['call_from_combo'] ?? '');
	
    $form_namespace = 'location_data';
    $form_obj = new AdihaStandardForm($form_namespace, $application_function_id);
    $form_obj->define_grid("SourceMinorLocation", "EXEC spa_source_minor_location 'l'", "g");
    $form_obj->define_layout_width(400);
    $form_obj->enable_multiple_select();
    $form_obj->add_privilege_menu($has_rights_manage_privilege);
    $form_obj->define_custom_functions('save_locations', '', 'delete_location','form_load_complete','before_save_validation');
    $form_obj->enable_grid_pivot();
    echo $form_obj->init_form('Location', 'Location Details', $source_minor_location_id);
    
    if ($source_minor_location_id != '') {
        echo "location_data.layout.cells('a').collapse();";
    }
    
    echo $form_obj->close_form();
    
    $todays_date = date('m/d/Y');
    ?>
<body>
</body>
<script type="text/javascript">
    var todays_date = '<?php echo $todays_date; ?>';
    var has_rights_location_delete =<?php echo (($has_rights_location_delete) ? $has_rights_location_delete : '0'); ?>;
	var has_rights_manage_privilege =<?php echo (($has_rights_manage_privilege) ? $has_rights_manage_privilege : '0'); ?>;
    var has_rights_location_IU = <?php echo (($has_rights_location_IU) ? $has_rights_location_IU : '0'); ?>;
	var call_from_combo = '<?php echo $call_from_combo; ?>';

    $(function () {
        location_data.grid.attachEvent("onRowSelect",function(rowId,cellIndex){
			if(has_rights_location_delete){
				location_data.menu.setItemEnabled("delete");
			}
        });

        load_workflow_status();
    });

    load_workflow_status = function() {
        location_data.menu.addNewSibling('process', 'reports', 'Reports', false, 'report.gif', 'report_dis.gif');
        location_data.menu.addNewChild('reports', '0', 'report_manager', 'Report Manager', true, 'report.gif', 'report_dis.gif');
        
        location_data.grid.attachEvent("onSelectStateChanged",function(rowId,cellIndex){
            if (rowId != null) {			
                if (rowId.indexOf(",") == -1) location_data.menu.setItemEnabled('report_manager');
            }
        });

        load_report_menu('location_data.menu', 'report_manager', 2, -104703)

        location_data.menu.attachEvent("onClick", function(id, zoneId, cas) {
            if (id.indexOf("report_manager_") != -1 && id != 'report_manager') {
                var str_len = id.length;
                var report_param_id = id.substring(15, str_len);
                var selected_loc_ids = location_data.grid.getColumnValues(0);
                var param_filter_xml = '<Root><FormXML param_name="source_id" param_value="' + selected_loc_ids + '"></FormXML></Root>';
                
                show_view_report(report_param_id, param_filter_xml, -104703)
            }
        });
    }
    
    function set_info_type(grid_obj, info_type) {
        if (grid_obj.getRowsNum() > 0) {
            grid_obj.forEachRow(function (row) {
                grid_obj.cells(row, 4).setValue(info_type);
            });
        }
    }
    
    /**
     * [Function to save Locations]
     */
    location_data.save_locations = function(tab_id) {
        var win = location_data.tabbar.cells(tab_id);
        var valid_status = 1;
        var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(" ", ""));
        var tab_obj = win.tabbar[object_id];
        var detail_tabs = tab_obj.getAllTabs();
        var grid_xml = "<GridGroup>";
        var form_xml = "<FormXML ";
        var form_status = true;
        var first_err_tab;
        var tabsCount = tab_obj.getNumberOfTabs();

        $.each(detail_tabs, function(index,value) {
            layout_obj = tab_obj.cells(value).getAttachedObject();
            layout_obj.forEachItem(function(cell){
                attached_obj = cell.getAttachedObject();
                if (attached_obj instanceof dhtmlXGridObject) {
                    attached_obj.clearSelection();
                    grid_label = attached_obj.getUserData("","grid_label");
                    if (grid_label == "Route") {
                        set_info_type(attached_obj, 'r');
                    }
                    
                    if (grid_label == "Nomination Group") {
                        set_info_type(attached_obj, 'n');
                    }                                
                                                                    
                    var ids = attached_obj.getChangedRows(true);
                    grid_id = attached_obj.getUserData("","grid_id");
                     
                    deleted_xml = attached_obj.getUserData("","deleted_xml");
                    info_type = attached_obj.getUserData("","info_type");
                     
                    if(deleted_xml != null && deleted_xml != "") {
        				grid_xml += "<GridDelete grid_id=\""+ grid_id + "\" grid_label=\"" + grid_label + "\">";
        				grid_xml += deleted_xml;
        				grid_xml += "</GridDelete>";
                        if (delete_grid_name == "") {
                            delete_grid_name = grid_label
                        } else {
                            delete_grid_name += "," + grid_label
                        }
        			};
                    if(ids != "") {
                        attached_obj.setSerializationLevel(false,false,true,true,true,true);
                        var grid_status = location_data.validate_form_grid(attached_obj,grid_label);

                         
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
                            tab_obj.cells(value).setActive();
                            valid_status = 0;
                        }
                    }
                } else if(attached_obj instanceof dhtmlXForm) {
                    var status = validate_form(attached_obj);
                    form_status = form_status && status; 
                        if (tabsCount == 1 && !status) {
                            first_err_tab = "";
                        } else if ((!first_err_tab) && !status) {
                            first_err_tab = tab_obj.cells(value);
                        }
                    if(status) {
                        data = attached_obj.getFormData();
                        for (var a in data) {
                            field_label = a;
                            field_value = data[a];
                            if (field_label == 'location_id' || field_label == 'location_description') {
                                if(data[a] == '') {
                                    field_value = data['location_name'];
                                }
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
        var xml = "<Root function_id=\"<?php echo $application_function_id;?>\" object_id=\"" + object_id + "\">";
        xml += form_xml;
        xml += grid_xml;
        xml += "</Root>";
        xml = xml.replace(/'/g, "\"");
        
        if(valid_status == 1){
             // console.log(location_data.tabbar.cells(tab_id).getAttachedToolbar());
            location_data.tabbar.cells(tab_id).getAttachedToolbar().disableItem("save");
            data = {"action": "spa_process_form_data", "xml":xml}
            
    		if(delete_grid_name != ""){
    			del_msg =  "Some data has been deleted from " + delete_grid_name + " grid. Are you sure you want to save?";
    			result = adiha_post_data("confirm", data, "", "", "location_data.post_callback","",del_msg);
                if (has_rights_location_IU) {
                    var tab_id = location_data.tabbar.getActiveTab();
                    location_data.tabbar.cells(tab_id).getAttachedToolbar().enableItem("save");

                };
    		} else {
    			result = adiha_post_data("alert", data, "", "", "location_data.post_callback");
    		}
    		delete_grid_name = "";
			deleted_xml = attached_obj.setUserData("","deleted_xml", "");
   	    }

        if (!form_status) {
                generate_error_message(first_err_tab);
            }
    }
    
    location_data.post_callback = function(result) {
        // location_data.tabbar.cells(tab_id).getAttachedToolbar().enableItem("save");
        if (has_rights_location_IU) {
            var tab_id = location_data.tabbar.getActiveTab();
            location_data.tabbar.cells(tab_id).getAttachedToolbar().enableItem("save");

        };
       
        if (result[0].errorcode == "Success") {
    		location_data.clear_delete_xml();
    		
    		if (result[0].recommendation != null) {             
    			var tab_id = location_data.tabbar.getActiveTab();
                var tab_text = new Array();
                if (result[0].recommendation.indexOf(",") != -1) { 
    				tab_text = result[0].recommendation.split(",") 
    			} else { 
    				tab_text.push(0, result[0].recommendation); 
    			}
    			location_data.tabbar.tabs(tab_id).setText(tab_text[1]);
                if (call_from_combo == 'combo_add') {
                    parent.combo_data_add_win.callEvent("onWindowSaveCloseEvent", ["onSave", tab_text[1]]);
                    return;
                }
    			location_data.refresh_grid("", location_data.open_tab);
    		} else {
    			location_data.refresh_grid();
    		}
    		location_data.menu.setItemDisabled("delete");

           var data = {
                "action" : "spa_source_minor_location",
                "flag" : "post_insert",
                "source_minor_location_ID" : tab_text[1]
            }
            adiha_post_data('return_array', data, '', '', '');  
			
    	}
    }
    
    /**
     * [Function to delete Locations]
     */
    location_data.delete_location = function() {
        var select_id = location_data.grid.getSelectedRowId();
        if (select_id != null) {
            dhtmlx.message({
                type: (select_id == '') ? "alert" : "confirm",
                title:(select_id == '') ? "Alert" : "Confirmation",
                ok: (select_id == '') ? "Ok" : "Confirm",
                text: "Are you sure you want to delete?",
                callback: function(result) {
                    if (result) {
                        if (select_id.indexOf(",") > -1 ) {
                            count_ids = select_id.split(",").length;
                            var get_id_only = '';

                            for (var i = 0; i < count_ids ; i++) {
                                id = select_id.split(",")[i];
                                var full_id = location_data.get_id(location_data.grid, id);
                                var full_id_split = full_id.split("_");
                                get_id_only += full_id_split[1] + ',';
                            }
                        get_id_only = get_id_only.slice(0, -1);
                        } else {
                            var full_id = location_data.get_id(location_data.grid, select_id);
                            var full_id_split = full_id.split("_");
                            var get_id_only = full_id_split[1];
                        }
                                              
                        data = {
                            "action": "spa_source_minor_location", 
                            "source_minor_location_id": get_id_only, 
                            "flag": "d"
                        }
                        result = adiha_post_data("return_array", data, "", "","location_data.post_delete_callback");
                    }
                }
            });
        }
    }
	    
    location_data.form_load_complete = function(win, full_id) {
        var tab_id = location_data.tabbar.getActiveTab();
		var win = location_data.tabbar.cells(tab_id);
        var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(" ", ""));
        var tab_obj = win.tabbar[object_id];
        var detail_tabs = tab_obj.getAllTabs();
		
        var tabsCount = tab_obj.getNumberOfTabs();
        var general_obj = '';
        $.each(detail_tabs, function(index,value) {
            layout_obj = tab_obj.cells(value).getAttachedObject();
            layout_obj.forEachItem(function(cell){
                attached_obj = cell.getAttachedObject();
                if(attached_obj instanceof dhtmlXForm && index == 0) {
                    general_obj = attached_obj;
                    var proxy_location_id = attached_obj.getItemValue('proxy_location_id');
                    if (!proxy_location_id || proxy_location_id == '' || proxy_location_id == undefined) {
                        //attached_obj.setItemValue('is_active',0);
                        //attached_obj.disableItem('is_active');
						attached_obj.setItemValue('proxy_position_type','');
                        attached_obj.disableItem('proxy_position_type');						
                    }
	                
                    if (attached_obj.getCombo('source_major_location_id').getSelectedText() == 'Pipeline') {
                        attached_obj.setRequired('pipeline', true);
                    }

                    general_obj.attachEvent("onChange", function (name, value, state){
                        if (name == 'proxy_location_id') {
                            if (value && value != '' && value != undefined) {
                                general_obj.enableItem('is_active');
								general_obj.enableItem('proxy_position_type');
                            } else {
                                //general_obj.setItemValue('is_active',0);
                                //general_obj.disableItem('is_active');
								general_obj.setItemValue('proxy_position_type','');
                                general_obj.disableItem('proxy_position_type');
                            }
                        }
                        if(name == 'source_major_location_id') {
                            if (general_obj.getCombo(name).getSelectedText() == 'Pipeline') {
                                general_obj.setRequired('pipeline', true);
                            } else {
                                general_obj.setRequired('pipeline', false);
                            }
                        }
                    });
                }
            });
        });
    }
	
	location_data.before_save_validation = function() {
		var is_valid = 1;
		
		var tab_id = location_data.tabbar.getActiveTab();
		var win = location_data.tabbar.cells(tab_id);
        var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(" ", ""));
        var tab_obj = win.tabbar[object_id];
        var detail_tabs = tab_obj.getAllTabs();
		
        $.each(detail_tabs, function(index,value) {
			
			if(tab_obj.tabs(value).getText() == 'General') {
				layout_obj = tab_obj.cells(value).getAttachedObject();
				layout_obj.forEachItem(function(cell){
					attached_obj = cell.getAttachedObject();
					if(attached_obj instanceof dhtmlXForm && index == 0) {
						var proxy_location_id = attached_obj.getItemValue('proxy_location_id');
						var proxy_position_type = attached_obj.getItemValue('proxy_position_type');
						console.log(proxy_position_type);
						if (proxy_position_type != '' && proxy_position_type != undefined) {
							
							var sp_string = "EXEC spa_source_minor_location @flag='e', @proxy_location_id='" + proxy_location_id + "'"; 
							post_data = { sp_string: sp_string };
							$.ajax({
								url: js_form_process_url,
								data: post_data,
								async: false
							}).done(function(data) {
								console.log(data);
								var json_data = data['json'][0];
								console.log(json_data);
								if(json_data.is_valid_to_proceed == 0) {
									dhtmlx.message({
										title:"Error",
										type:"alert-error",
										text:json_data.msg
									});
									is_valid = 0;
								}
								
							});
												
						}
					}
				});
			}
		});
		return is_valid;
		
	}

    location_data.post_delete_callback = function(result) {
        if (result[0][0] == "Success") {
            dhtmlx.message({
                text:result[0][4],
                expire:1000
            });
            location_data.refresh_grid();
            if (result[0][5].indexOf(",") > -1) {
                var ids = result[0][5].split(",");
                var count_ids = ids.length;
                for (var i = 0; i < count_ids; i++ ) {
                    full_id = 'tab_' + ids[i];
                    if (location_data.pages[full_id]) {
                        location_data.tabbar.cells(full_id).close();
                    }
                }
            } else {
                full_id = 'tab_' + result[0][5];
                if (location_data.pages[full_id]) {
                    location_data.tabbar.cells(full_id).close();
                }
            }
        } else {
            location_data.refresh_grid();
            dhtmlx.message({
                title:"Alert",
                type:"alert",
                text:result[0][4]
            });
        }
    }   
	
	//ajax setup for default values
    $.ajaxSetup({
        method: 'POST',
        dataType: 'json',
        error: function(jqXHR, text_status, error_thrown) {
            console.log('*** Error on ajax: ' + text_status + ', ' + error_thrown);
        }
    });

    // Override the enable_menu_item method to support multiple deletion.
    location_data.enable_menu_item = function(id,ind) {
        var selected_rows = location_data.grid.getSelectedRowId();

        if(has_rights_location_delete == true && id != null){
            location_data.menu.setItemEnabled("delete");
        } else {
            location_data.menu.setItemDisabled("delete");
        }
        
        if(id != null && id.indexOf(",") == -1) {
            var c_row = null;
            var col_type = location_data.grid.getColType(0);
            if(col_type == "tree") {
                var c_row = location_data.grid.getChildItemIdByIndex(id, 0);
            }
            if(col_type == "tree" && c_row != null) {
                var is_active = -1;
            } else { 
                var is_active = location_data.grid.cells(id, location_data.grid.getColIndexById("is_privilege_active")).getValue();
            }
        } else {
            if (id.indexOf(",") != -1) {
                var splitted_id = id.split(',');
                var is_active = location_data.grid.cells(splitted_id[0], location_data.grid.getColIndexById("is_privilege_active")).getValue();
            } else {
                var is_active = -1
            }
        }
        
        if (is_active == 0) {
            if (has_rights_manage_privilege){
                location_data.menu.setItemEnabled("activate");
                location_data.menu.setItemDisabled("deactivate");
                location_data.menu.setItemDisabled("privilege");
            }
        } else if (is_active == 1){
            if (has_rights_manage_privilege) {
                if (id.indexOf(",") != -1) {
                    location_data.menu.setItemDisabled("activate");
                    location_data.menu.setItemDisabled("deactivate");
                    location_data.menu.setItemEnabled("privilege");
                } else {
                    location_data.menu.setItemDisabled("activate");
                    location_data.menu.setItemEnabled("deactivate");
                    location_data.menu.setItemEnabled("privilege");
                }
            }
        } else {
            location_data.menu.setItemDisabled("activate");
            location_data.menu.setItemDisabled("deactivate");
            location_data.menu.setItemDisabled("privilege");
        }
    }
</script>
</html>