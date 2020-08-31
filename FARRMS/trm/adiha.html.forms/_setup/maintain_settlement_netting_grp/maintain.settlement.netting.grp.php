<?php
/**
* Maintain settlement netting grp screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta http-equiv="X-UA-Compatible" content="IE=edge" />
        <?php  include '../../../adiha.php.scripts/components/include.file.v3.php'; ?>
    </head>
	
<?php
    $php_script_loc = $app_php_script_loc;
    
    $rights_setup_netting_group = 10104600;    
    $rights_setup_netting_group_UI = 10104610;
    $rights_setup_netting_group_delete = 10104611;
   
    list (
        $has_rights_setup_netting_group, 
        $has_rights_setup_netting_group_UI,
        $has_rights_setup_netting_group_delete
    ) = build_security_rights(
        $rights_setup_netting_group, 
        $rights_setup_netting_group_UI,
        $rights_setup_netting_group_delete
       
    );
    $form_namespace = 'settlement_netting';
	
    $form_obj = new AdihaStandardForm($form_namespace, '10104600');
    $form_obj->define_grid("settlement_netting", "EXEC spa_settlement_netting_group 'g'");
    $form_obj->define_layout_width(300);
    $form_obj->define_custom_functions('save_settlement_netting', 'load_settlement_netting', 'delete_settlement_netting', '');
    echo $form_obj->init_form('Setup Netting Group', 'Setup Netting Group Details');
    echo $form_obj->close_form();
?>
<body>
    <script type="text/javascript">
		settlement_netting.delete_contract_flag = {};
        var has_rights_setup_netting_group_UI = '<?php echo $has_rights_setup_netting_group_UI;?>';
        var has_rights_setup_netting_group_delete = '<?php echo $has_rights_setup_netting_group_delete;?>';
                
		$(function() {
		  
            enabled_disabled_menu(settlement_netting.menu, 'add', has_rights_setup_netting_group_UI);
            
			settlement_netting.grid.attachEvent("onXLE", function(grid_obj,count){
				settlement_netting.grid.expandAll();
			});
            
            settlement_netting.grid.attachEvent("onRowSelect", function(row_id,row_index){
                
                var row_level = settlement_netting.grid.getLevel(row_id);
                
                if (row_level < 2) {
                    enabled_disabled_menu(settlement_netting.menu, 'delete', false);                    
                } else {
                    enabled_disabled_menu(settlement_netting.menu, 'delete', has_rights_setup_netting_group_delete);        
                }
				
			});
		})
		
		/*
		 * Create the new tab.
		 * Called when double clicked on left side grid or clicked on Add button.
		 */
		settlement_netting.load_settlement_netting = function(win, tab_id, grid_obj) {
			win.progressOff();
			var active_object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
            var tab_name = settlement_netting.tabbar.tabs(tab_id).getText();
            
            settlement_netting["inner_layout_" + active_object_id] = win.attachLayout({
				pattern: "2E",
				cells: [
					{id: "a", text: "General", height: 200},
					{id: "b", text: "Contracts"}
				]
			});
            var xml_value =  '<Root><PSRecordset blank_field ="NULL"></PSRecordset></Root>';
            data = {"action": "spa_create_application_ui_json",
						"flag": "j",
						"application_function_id": 10104600,
						"template_name": "settlement_netting",
						"parse_xml": xml_value
					 };

            adiha_post_data('return_array', data, '', '', 'load_settlement_netting_callback', '');
		}
		
		/*
		 * Load the content of the tab.
		 */
		load_settlement_netting_callback = function(result) {
			var active_tab_id = settlement_netting.tabbar.getActiveTab();
            var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            
			var form_json = result[0][2];
			load_settlement_netting_form(active_object_id, form_json);
			load_settlement_netting_detail_menu(active_object_id);
			load_settlement_netting_detail_grid(active_object_id,active_tab_id);
            
            enabled_disabled_toolbar(settlement_netting.tabbar.cells(active_tab_id).getAttachedToolbar(), 'save', has_rights_setup_netting_group_UI);
		}
		
		/*
		 * Populate the general form
		 */
		load_settlement_netting_form = function(active_object_id, form_json) {
			var active_tab_id = settlement_netting.tabbar.getActiveTab();
			settlement_netting["general_form_" + active_object_id] = settlement_netting["inner_layout_" + active_object_id].cells('a').attachForm();
            if (form_json) {
                settlement_netting["general_form_" + active_object_id].loadStruct(form_json);
            }
			
			var check_new = (active_tab_id.indexOf("tab_") != -1) ? true : false;
			if (check_new == true) {
				var netting_group_id = active_object_id;
				var sp_string = "EXEC spa_settlement_netting_group @flag='a',@netting_group_id=" + netting_group_id;
				var data_for_post = {"sp_string": sp_string};     
				var return_json = adiha_post_data('return_json', data_for_post, '', '', 'load_settlement_netting_form_data');
			} else {
				settlement_netting['general_form_' + active_object_id].setItemValue('netting_parent_group_id', -1);        
			}
		}
		
		/*
		 * Load data on the general form
		 */
		load_settlement_netting_form_data = function(result) {
			var active_tab_id = settlement_netting.tabbar.getActiveTab();
            var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            
			var return_data = JSON.parse(result);
			settlement_netting['general_form_' + active_object_id].setItemValue('netting_parent_group_id', return_data[0].netting_parent_group_id);        
			settlement_netting['general_form_' + active_object_id].setItemValue('netting_group_id', return_data[0].netting_group_id);
			settlement_netting['general_form_' + active_object_id].setItemValue('netting_group_name', return_data[0].netting_group_name);
			settlement_netting['general_form_' + active_object_id].setItemValue('effective_date', return_data[0].effective_date);
			settlement_netting['general_form_' + active_object_id].setItemValue('invoice_template', return_data[0].invoice_template);
			settlement_netting['general_form_' + active_object_id].setItemValue('counterparty_id', return_data[0].counterparty_id);
			if (return_data[0].create_individual_invoice == 'y')
				settlement_netting['general_form_'+active_object_id].checkItem('create_individual_invoice');
		}
		
		/*
		 * Load menu and its event for the detail grid (contract grid)
		 */
		load_settlement_netting_detail_menu = function(active_object_id) {
			var active_tab_id = settlement_netting.tabbar.getActiveTab();
			var detail_grid_menu_json = [
				{id:"child_menu", text:"Edit", img:"edit.gif", items:[
					{id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add",enabled: has_rights_setup_netting_group_UI},
					{id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete", disabled: true}
				]},
				{id:"child_export", text:"Export", img:"export.gif",items:[
					{id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
					{id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
				]}
			];
			
			settlement_netting["detail_grid_menu_" + active_object_id] = settlement_netting["inner_layout_" + active_object_id].cells('b').attachMenu({
                icons_path : js_image_path + "dhxmenu_web/",
                json       : detail_grid_menu_json
            }); 

			settlement_netting["detail_grid_menu_" + active_object_id].attachEvent("onClick", function(id, zoneId, cas){
                switch(id) {
                    case 'add':
						var new_id = (new Date()).valueOf();
						settlement_netting["detail_grid_" + active_object_id].addRow(new_id,'');
						break;
                    case 'delete':
						var selected_row = settlement_netting["detail_grid_" + active_object_id].getSelectedRowId();
						var selected_row_arr = selected_row.split(',');
						
						for (cnt = 0; cnt < selected_row_arr.length; cnt++) {
							var id = settlement_netting["detail_grid_" + active_object_id].cells(selected_row_arr[cnt], 0).getValue();
							settlement_netting["detail_grid_" + active_object_id].deleteRow(selected_row_arr[cnt]);
							//settlement_netting["detail_grid_menu_" + active_object_id].setItemDisabled('delete');
                            enabled_disabled_menu(settlement_netting["detail_grid_menu_" + active_object_id], 'delete', false);
						}

						if (settlement_netting["detail_grid_" + active_object_id].getSelectedRowId() != '') {                
		                    settlement_netting["detail_grid_" + active_object_id].deleteSelectedRows();
		                    settlement_netting.delete_contract_flag["grid_" + active_tab_id] = 1;
		                }
						break;
					case 'pdf':
						settlement_netting["detail_grid_" + active_object_id].toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
						break;
					case 'excel':
						settlement_netting["detail_grid_" + active_object_id].toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
						break;
				}
            });
		}
		
		/*
		 * Load the detail grid (contract grid)
		 */
		load_settlement_netting_detail_grid = function(active_object_id, active_tab_id) {
			settlement_netting["detail_grid_" + active_object_id] = settlement_netting["inner_layout_" + active_object_id].cells('b').attachGrid();
			settlement_netting["detail_grid_" + active_object_id].setImagePath(js_php_path + "components/lib/adiha_dhtmlx/adiha_grid_3.0/adiha_dhtmlxGrid/codebase/imgs/");
			settlement_netting["detail_grid_" + active_object_id].setHeader(get_locale_value("ID,Contract,Description",true));
			settlement_netting["detail_grid_" + active_object_id].setColumnIds("netting_contract_id,contract_id,contract_description");
			settlement_netting["detail_grid_" + active_object_id].setColTypes("ro,combo,ed");
			settlement_netting["detail_grid_" + active_object_id].setColSorting("str,str,str");
			settlement_netting["detail_grid_" + active_object_id].setColumnsVisibility("true,false,true");
			settlement_netting["detail_grid_" + active_object_id].setInitWidths('0,200,300');
			settlement_netting["detail_grid_" + active_object_id].enableMultiselect(true);
			settlement_netting["detail_grid_" + active_object_id].init();
			
			settlement_netting["detail_grid_" + active_object_id].attachEvent("onRowSelect", function(id,ind){
				if(has_rights_setup_netting_group_UI){
                enabled_disabled_menu(settlement_netting["detail_grid_menu_" + active_object_id], 'delete', true);
				}
            });
			
			var combo_obj = settlement_netting["detail_grid_" + active_object_id].getColumnCombo(settlement_netting["detail_grid_" + active_object_id].getColIndexById('contract_id'));                
            var netting_group_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : 'NULL';
                        
            var cm_param = {
                            "action": "spa_contract_group",
                            "flag": "r",
                            //"netting_group_id": netting_group_id,
                            "has_blank_option": false
                        };
            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;
            combo_obj.load(url, function() {
                combo_obj.enableFilteringMode(true);
				refresh_settlement_netting_detail_grid();
			});
            
		}
		
		/*
		 * Load data on the detail grid (contract grid)
		 */
		refresh_settlement_netting_detail_grid = function() {
			var active_tab_id = settlement_netting.tabbar.getActiveTab();
            var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;            
            
			var netting_group_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : 'NULL';
            
			var param = {
                            "action": "spa_settlement_netting_group",
                            "flag": "z",
                            "netting_group_id": netting_group_id
                        };

            param = $.param(param);
            var param_url = js_data_collector_url + "&" + param;
            settlement_netting["detail_grid_" + active_object_id].clearAll();
            settlement_netting["detail_grid_" + active_object_id].loadXML(param_url, function() {
                enabled_disabled_menu(settlement_netting["detail_grid_menu_" + active_object_id], 'delete', false);
            });
		}
		
		/*
		 * Save function
		 */
		settlement_netting.save_settlement_netting = function(tab_id) {
			var active_tab_id = settlement_netting.tabbar.getActiveTab();
            var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            
			var general_form_status = validate_form(settlement_netting["general_form_" + active_object_id]);
			if (general_form_status == false) {
				generate_error_message();
				return;
			}
			
			//var counteparty_combo = settlement_netting["general_form_" + active_object_id].getCombo('counterparty_id');            
            //var  netting_group_name = counteparty_combo.getComboText();
            var netting_group_name = settlement_netting["general_form_" + active_object_id].getItemValue('netting_group_name');
            
			settlement_netting["general_form_" + active_object_id].setUserData("", "tab_name", netting_group_name);
							
			var form_xml = '<Root function_id="10104600"><FormXML ';
			form_data_a = settlement_netting["general_form_" + active_object_id].getFormData();
			for (var a in form_data_a) {
				field_label = a;
				field_value = (field_label == 'effective_date') ? dates.convert_to_sql(form_data_a[a]) : form_data_a[a];
				form_xml += " " + field_label + "=\"" + field_value + "\"";    
			}
			form_xml += "></FormXML></Root>";
			
			validation_grid_status =  validate_form_grid(settlement_netting["detail_grid_" + active_object_id]); 
			
			if (validation_grid_status ==  false) {
				return false;
			}
			
			var grid_xml = '<Root>';   
			settlement_netting["detail_grid_" + active_object_id].forEachRow(function(id){
				grid_xml = grid_xml + "<PSRecordset ";   
				settlement_netting["detail_grid_" + active_object_id].forEachCell(id,function(cellObj,ind){
					var column_id = settlement_netting["detail_grid_" + active_object_id].getColumnId(ind);
					var cell_values = settlement_netting["detail_grid_" + active_object_id].cells(id, ind).getValue();
					grid_xml = grid_xml + " " + column_id + '="' + cell_values + '"';       
				});	
				grid_xml = grid_xml + " ></PSRecordset> ";    				
			});
			grid_xml += "</Root>";
			settlement_netting.tabbar.tabs(active_tab_id).getAttachedToolbar().disableItem('save');

			mode = 'u';
			var netting_group_id = settlement_netting["general_form_" + active_object_id].getItemValue('netting_group_id');
			if (netting_group_id == '') { 
				mode = 'i';
			}
			
			data = {"action": "spa_settlement_netting_group", 
					"flag": "" + mode + "",
					"netting_group_id": netting_group_id,
					"form_xml": form_xml,
					"grid_xml": grid_xml
			};

			if (settlement_netting.delete_contract_flag["grid_" + active_tab_id] == 1) {
			    var del_msg =  "Some data has been deleted from Contract grid. Are you sure you want to save?";
			    
			    dhtmlx.message({
			        type: "confirm-warning",
			        text: del_msg,
			        title: "Warning",
			        callback: function(result) {                    	 
			            if (result) {
			            	settlement_netting.delete_contract_flag["grid_" + active_tab_id] = 0;
			                var return_json = adiha_post_data('return_array', data, 'Changes have been saved successfully.', '', 'save_settlement_netting_callback', '', del_msg);
			            }   
			            if (has_rights_setup_netting_group_UI) {
            				settlement_netting.tabbar.tabs(settlement_netting.tabbar.getActiveTab()).getAttachedToolbar().enableItem('save');
						};                    
			        } 
			    }); 
			} else {
				var return_json = adiha_post_data('return_array', data, 'Changes have been saved successfully.', '', 'save_settlement_netting_callback', '', del_msg);
			}
		}
		
		/*
		 * Refresh left grid after save and update tab_name.
		 */
		save_settlement_netting_callback = function(result) {
			var active_tab_id = settlement_netting.tabbar.getActiveTab();
            var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            if (has_rights_setup_netting_group_UI) {
            	settlement_netting.tabbar.tabs(active_tab_id).getAttachedToolbar().enableItem('save');
			};
            if (result[0][0] == 'Success') {
			    var netting_group_name = settlement_netting["general_form_" + active_object_id].getUserData("", "tab_name")
				if (mode == 'i') {
					var new_id = result[0][5];
					settlement_netting["general_form_" + active_object_id].setItemValue('netting_group_id', new_id);
                    tab_id = 'tab_' + new_id;
                    settlement_netting.create_tab_custom(tab_id, netting_group_name);
                    settlement_netting.tabbar.tabs(active_tab_id).close(true);
			} 
				
			settlement_netting.tabbar.tabs(active_tab_id).setText(netting_group_name);
				
				dhtmlx.message({
					text:result[0][4],
					expire:1000
				});
				refresh_settlement_netting_grid();
			} else {
				dhtmlx.alert({
					title:"Alert",
					type:"alert",
					text:result[0][4]
				}); 
			}
        }
        
         /**
         * Custom tab creation function
         */
        settlement_netting.create_tab_custom = function(full_id, text) {
            var theme_selected = 'dhtmlx_' + default_theme;
            if (!settlement_netting.pages[full_id]) {
                settlement_netting.tabbar.addTab(full_id, text, null, null, true, true);
                var win = settlement_netting.tabbar.cells(full_id);
                win.progressOn();
                //using window instead of tab 
                var toolbar = win.attachToolbar();
                toolbar.setIconsPath("<?php echo $app_php_script_loc; ?>components/lib/adiha_dhtmlx/themes/"+theme_selected+"/imgs/dhxtoolbar_web/");
                toolbar.attachEvent("onClick", settlement_netting.tab_toolbar_click);
                toolbar.loadStruct([{id: "save", type: "button", img: "save.gif", text: "Save", title: "Save"}]);
                settlement_netting.tabbar.cells(full_id).setText(text);
                settlement_netting.tabbar.cells(full_id).setActive();           
                settlement_netting.load_settlement_netting(win,full_id);
                settlement_netting.pages[full_id] = win;
            }
            else {
                settlement_netting.tabbar.cells("'" + full_id + "'").setActive();
            }
        }
        
		
		/*
		 * Delete function
		 */
		settlement_netting.delete_settlement_netting = function() {
			var selected_id = settlement_netting.grid.getSelectedId();
            if (selected_id == null) {
                show_messagebox('Please select the data you want to delete.');
                return;
            }
            
            // Handle Tree node selection
            netting_group_id = '';
            if (selected_id.indexOf(",") != -1) {
            	var sel_id_arr = selected_id.split(",");
            	for (var i = 0; i < sel_id_arr.length; i++) {
		            var row_level = settlement_netting.grid.getLevel(sel_id_arr[i]);
		            if (row_level == 2) {
		            	netting_group_id += "," + settlement_netting.grid.cells(sel_id_arr[i], 1).getValue();
		            }
		        }
	        } else {
	        	netting_group_id = settlement_netting.grid.cells(selected_id, 1).getValue();
	        }
			netting_group_id = netting_group_id.replace(/^,/, '');
			// netting_name = settlement_netting.grid.cells(selected_id, 0).getValue();

			var confirm_msg = 'Are you sure you want to delete?';
            dhtmlx.message({
                type: "confirm",
                title: "Confirmation",
                text: confirm_msg,
                ok:"Confirm",
                callback: function(result) {
                    if (result) {
						var sp_string = "EXEC spa_settlement_netting_group @flag='d',@netting_group_id='" + netting_group_id + "'";
                        var data_for_post = {"sp_string": sp_string};
						var return_json = adiha_post_data('alert', data_for_post, '', '', 'delete_settlement_netting_callback'); 
					}        
                }
            });
		}
		
		/*
		 * Close the active tab if it is deleted and reload the left side grid.
		 */
		delete_settlement_netting_callback = function() {
			refresh_settlement_netting_grid();
			netting_group_id_arr = netting_group_id.split(',');
			settlement_netting.tabbar.forEachTab(function(tab){
				if (netting_group_id_arr.indexOf(tab.getId()) > -1) {
					tab.close();
				}
			});
		}
		
		/*
		 * Refresh the left side grid.
		 */
		refresh_settlement_netting_grid = function() {
			var sql_param = {
                "action": "spa_settlement_netting_group",
                "flag": "g",
                "grouping_column":"netting_parent_group_name,counterparty_name,netting_group_name",
                "grid_type": "tg"
            };
			sql_param = $.param(sql_param);
			var sql_url = js_data_collector_url + "&" + sql_param;
			settlement_netting.grid.clearAll();
			settlement_netting.grid.load(sql_url, function() {
				settlement_netting.grid.expandAll();
                enabled_disabled_menu(settlement_netting.menu, 'delete', false);
			});
		}
		
		/*
		 * Validation function for detail grid (Contract Grid)
		 */
		validate_form_grid = function(grid_obj) {			
			var check_data = '';
			var comma = '';
			for (var row_index = 0; row_index < grid_obj.getRowsNum(); row_index++) {  
				check_data = check_data + comma + grid_obj.cells2(row_index, 1).getValue();
				comma = ',';                        
			}
			
			var check_data_array = check_data.split(',');
			
			if (grid_obj.getRowsNum() < 1) {
				show_messagebox('There is no data in Contracts grid.');
				return false;
			}
			
			if (check_data == '') {
				show_messagebox('There is no data selected in Contracts grid.');
				return false;
				}
			
			var check_data_array_sorted = check_data_array.sort();
		   
			for (index = 1; index < check_data_array_sorted.length; index++) {
				
				if (check_data_array_sorted[index - 1] == '') {
					show_messagebox('There is no data in Contracts grid.');
					return false;
				}
				
				if (check_data_array_sorted[index - 1] == check_data_array_sorted[index]) {
					show_messagebox('There is duplicate data in Contract grid.');
					return false;
				}
			}
			return true;
		}
        
        /*
		 * Enabled menus
		 */
		enabled_disabled_menu = function(menu_obj, name, is_enable) {
            if (is_enable == true) {
                menu_obj.setItemEnabled(name);
            } else {
                menu_obj.setItemDisabled(name);
            }
        }
        
        /*
		 * Enabled toolbar
		 */
		enabled_disabled_toolbar = function(toolbar_obj, name, is_enable) {
            if (is_enable == true) {
                toolbar_obj.enableItem(name);
            } else {
                toolbar_obj.disableItem(name);
            }
        }
	</script>
	
</body>
</html>