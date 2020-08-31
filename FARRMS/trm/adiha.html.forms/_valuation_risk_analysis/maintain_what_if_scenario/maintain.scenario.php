<?php
/**
* Maintain scenario screen
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
    $form_namespace = 'Setup_What_If_scenario';
    $rights_maintain_whatif_criteria_iu = 10182510;
    $rights_maintain_whatif_criteria_del = 10182511;
    $application_function_id = 10182500; 
     
    $has_right_maintain_whatif_criteria_iu = false;
    $has_right_maintain_whatif_criteria_del = false;
      
    list(
        $has_right_maintain_whatif_criteria_iu,
        $has_right_maintain_whatif_criteria_del
    ) = build_security_rights (
        $rights_maintain_whatif_criteria_iu,
        $rights_maintain_whatif_criteria_del
    );
    
    $is_public = 'n';
    $is_active = 'y';
    $scenario_group_id = get_sanitized_value($_GET['scenario_group_id'] ?? '');
    
         
    $form_obj = new AdihaStandardForm($form_namespace, $application_function_id);
    $form_obj->define_grid("maintain_scenario_grid", "EXEC spa_maintain_scenario_dhx @flag = 'm'");
    $form_obj->define_layout_width(300);
    $form_obj->define_custom_functions('pre_save_scenario', 'load_scenario', 'delete_scenario', '');
    echo $form_obj->init_form('What If Scenario', 'What If Scenario Details', $scenario_group_id);
    echo $form_obj->close_form();
?>
<body>
    <script type="text/javascript">
        var has_right_maintain_whatif_criteria_iu =<?php echo (($has_right_maintain_whatif_criteria_iu) ? $has_right_maintain_whatif_criteria_iu : '0'); ?>;
        var has_right_maintain_whatif_criteria_del =<?php echo (($has_right_maintain_whatif_criteria_del) ? $has_right_maintain_whatif_criteria_del : '0'); ?>;
        var theme_selected = 'dhtmlx_' + '<?php echo $default_theme; ?>';
        
        /*
         * Load Function - Called when double clicked on scenario group.
         */
        Setup_What_If_scenario.load_scenario = function(win, tab_id, grid_obj) {
            win.progressOff();
            var scenario_tab_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
            var scenario_tab_name = Setup_What_If_scenario.tabbar.tabs(tab_id).getText();
            
            Setup_What_If_scenario["inner_layout_" + scenario_tab_id] = win.attachLayout('1C');
            
            data = {"action": "spa_create_application_ui_json",
                    "flag": "j",
                    "application_function_id": 10182500,
                    "template_name": "Setup_What_If_scenario",
                    "parse_xml": "<Root><PSRecordSet scenario_group_id=\"" + scenario_tab_id + "\"></PSRecordSet></Root>"
                 };

            adiha_post_data('return_array', data, '', '', 'load_scenario_callback', '');
        }
        
        /*
         * Callback function of load_scenario. Create the tab and load tab contents.
         */
        load_scenario_callback = function(result) {
            var scenario_tab_id = Setup_What_If_scenario.tabbar.getActiveTab();
            var active_object_id = (scenario_tab_id.indexOf("tab_") != -1) ? scenario_tab_id.replace("tab_", "") : scenario_tab_id;
            
            var result_length = result.length;
            var tab_json = '';
            for (i = 0; i < result_length; i++) {
                if (i > 0)
                    tab_json = tab_json + ",";
                tab_json = tab_json + (result[i][1]);
            }
            tab_json = '{tabs: [' + tab_json + ']}';
            
            Setup_What_If_scenario["scenario_tab_" + active_object_id] = Setup_What_If_scenario["inner_layout_" + active_object_id].cells('a').attachTabbar({mode:"bottom",arrows_mode:"auto"});
            Setup_What_If_scenario["scenario_tab_" + active_object_id].loadStruct(tab_json);
            
            var cnt = 0;
            Setup_What_If_scenario["scenario_tab_" + active_object_id].forEachTab(function(tab){
                var tab_name = tab.getText();
                switch(tab_name) {
                    case get_locale_value("General"):
                        load_general_tab(tab, active_object_id, result[cnt][2]);
                        break;
                    case get_locale_value("Scenario"):
                        load_scenario_tab(tab, active_object_id, result[cnt][2]);
                        break;
                }
                cnt++;
            });
        }
        
        /*
         * load the form of the general tab
         */
        load_general_tab = function(tab_obj, tab_id, form_json) {
            Setup_What_If_scenario["general_form" + tab_id] = tab_obj.attachForm();
            if (form_json) {
                Setup_What_If_scenario["general_form" + tab_id].loadStruct(form_json);
            }
        }
        
        /*
         * load the content of the scenario tab.
         */
        load_scenario_tab = function(tab_obj, tab_id, form_json) {
            Setup_What_If_scenario["scenario_layout_" + tab_id] = tab_obj.attachLayout({
                pattern:'2E',
                cells: [{id: "a",text: "Form", header: false, height: 120}, {id: "b",text: "<a class=\"undock_a undock-btn undock_custom\" style=\"float: right; cursor:pointer\" title=\"Undock\"  onClick=\"undock_scenario_grid();\"></a>Scenario"}]
            });
			
			Setup_What_If_scenario["scenario_layout_" + tab_id].cells('b').attachEvent("onUnDock", function(name) {
				$('.undock-a').hide();
			});
			
			Setup_What_If_scenario["scenario_layout_" + tab_id].cells('b').attachEvent("onDock", function(name) {
				$('.undock-a').show();
			});
            
            load_scenario_tab_form(tab_id, form_json);
            load_scenario_tab_menu(tab_id);
            load_scenario_tab_grid(tab_id);
        }
        
        /*
         * load the form of the scenario tab.
         */
        load_scenario_tab_form = function(tab_id, form_json) {
            Setup_What_If_scenario["scenario_form_" + tab_id] = Setup_What_If_scenario["scenario_layout_" + tab_id].cells('a').attachForm();
            if (form_json) {
                Setup_What_If_scenario["scenario_form_" + tab_id].loadStruct(form_json);
            }
            
            Setup_What_If_scenario["scenario_form_" + tab_id].attachEvent('onChange', function (name, value) {
                if (name == 'scenario_type') {
                    switch_scenario_grid();
                } 
            });
        }
        
        /*
         * load the menu of the scenario tab.
         */
        load_scenario_tab_menu = function(tab_id) {
            if(has_right_maintain_whatif_criteria_iu)
                has_right_maintain_whatif_criteria_iu = true;
            else 
                has_right_maintain_whatif_criteria_iu = false

            var scenario_menu_json = [
                {id:"t1", text:"Edit", img:"edit.gif", items:[
                    {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add", enabled:has_right_maintain_whatif_criteria_iu},
                    {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete", enabled:false}
                ]},
				{id:"t2", text:"Export", img:"export.gif", items:[
                    {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF", enabled:true},
                    {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel", enabled:true}
                ]}
            ];
            Setup_What_If_scenario["scenario_menu_" + tab_id] = Setup_What_If_scenario["scenario_layout_" + tab_id].cells('b').attachMenu({
                icons_path : js_image_path + "dhxmenu_web/",
                json       : scenario_menu_json
            });   
            
            Setup_What_If_scenario["scenario_menu_" + tab_id].attachEvent("onClick", function(id, zoneId, cas){
                switch(id) {
                    case 'add':
                        var new_id = (new Date()).valueOf();
						var scenario_type = Setup_What_If_scenario["scenario_form_" + tab_id].getItemValue('scenario_type');
						if (scenario_type == 'i') {
							Setup_What_If_scenario["scenario_grid_" + tab_id].addRow(new_id,['','p','','','','','','','1','','','','','','','','','','']);
							use_existing_oncheck(new_id, true);
						} else {
							Setup_What_If_scenario["scenario_grid_" + tab_id].addRow(new_id,['','p','','','','','','','0','','','','','','','','','','']);
							use_existing_oncheck(new_id, false);
						}
						Setup_What_If_scenario["scenario_grid_" + tab_id].forEachRow(function(row){
							Setup_What_If_scenario["scenario_grid_" + tab_id].forEachCell(row,function(cellObj,ind){
								Setup_What_If_scenario["scenario_grid_" + tab_id].validateCell(row,ind)
							});
						});
                        break;
                    case 'delete':
                        var selected_row = Setup_What_If_scenario["scenario_grid_" + tab_id].getSelectedRowId();
						var selected_row_arr = selected_row.split(',');
						for (cnt = 0; cnt < selected_row_arr.length; cnt++) {
							var scenario_id = Setup_What_If_scenario["scenario_grid_" + tab_id].cells(selected_row_arr[cnt], 0).getValue();
							Setup_What_If_scenario["scenario_grid_" + tab_id].deleteRow(selected_row_arr[cnt]);
							Setup_What_If_scenario["scenario_menu_" + tab_id].setItemDisabled('delete');
							if (scenario_id != '') {
								Setup_What_If_scenario["scenario_grid_" + tab_id].setUserData("","deleted_xml", "deleted");
							}
						}
						break;
					case 'pdf':
						Setup_What_If_scenario["scenario_grid_" + tab_id].toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
						break;
					case 'excel':
						Setup_What_If_scenario["scenario_grid_" + tab_id].toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
						break;
					
                }
            });
        }
        
        /*
         * load the grid of the scenario tab.
         */
        load_scenario_tab_grid = function(tab_id) {
			Setup_What_If_scenario["scenario_grid_" + tab_id] = Setup_What_If_scenario["scenario_layout_" + tab_id].cells('b').attachGrid();   
            Setup_What_If_scenario["scenario_grid_" + tab_id].setImagePath(js_image_path + "dhxgrid_web/"); 
            Setup_What_If_scenario["scenario_grid_" + tab_id].setHeader(get_locale_value("ID,Risk Factor,Shift,Shift Item,Shift By, Shift Value, Months From, Months To, Use Existing,Shifts - 1,2,3,4,5,6,7,8,9,10", true));
            Setup_What_If_scenario["scenario_grid_" + tab_id].attachHeader('#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter'); 
            Setup_What_If_scenario["scenario_grid_" + tab_id].setColumnIds("id,risk_factor,shift,shift_item,shift_by,shift_value,month_from,month_to,use_existing,shift1,shift2,shift3,shift4,shift5,shift6,shift7,shift8,shift9,shift10");
            Setup_What_If_scenario["scenario_grid_" + tab_id].setColTypes("ro,combo,combo,combo,combo,combo,ed,ed,ch,ed,ed,ed,ed,ed,ed,ed,ed,ed,ed");
            Setup_What_If_scenario["scenario_grid_" + tab_id].setColSorting("str,str,str,str,str,str,str,str,str,str,str,str,str,str,str,str,str,str,str");
            Setup_What_If_scenario["scenario_grid_" + tab_id].setColumnsVisibility("true,false,false,false,false,false,true,true,false,false,false,false,false,false,false,false,false,false,false");
            Setup_What_If_scenario["scenario_grid_" + tab_id].setInitWidths('0,120,120,120,120,120,120,120,120,60,60,60,60,60,60,60,60,60,60');
            Setup_What_If_scenario["scenario_grid_" + tab_id].enableMultiselect(true);
            Setup_What_If_scenario["scenario_grid_" + tab_id].setPagingWTMode(true,true,true,[5,10,20,30,40,50,60,70,80,90,100,200]);
            Setup_What_If_scenario["scenario_grid_" + tab_id].init();
			Setup_What_If_scenario["scenario_grid_" + tab_id].enableValidation(true);
			Setup_What_If_scenario["scenario_grid_" + tab_id].setColValidators(",NotEmpty,NotEmpty,NotEmpty,,EmptyOrNumeric,EmptyOrNumeric,EmptyOrNumeric,,EmptyOrNumeric,EmptyOrNumeric,EmptyOrNumeric,EmptyOrNumeric,EmptyOrNumeric,EmptyOrNumeric,EmptyOrNumeric,EmptyOrNumeric,EmptyOrNumeric,EmptyOrNumeric"); 
            
			Setup_What_If_scenario["scenario_grid_" + tab_id].attachEvent("onValidationError",function(id,ind,value){
				var message = "Invalid Data";
				Setup_What_If_scenario["scenario_grid_" + tab_id].cells(id,ind).setAttribute("validation", message);
				return true;
			});
			Setup_What_If_scenario["scenario_grid_" + tab_id].attachEvent("onValidationCorrect",function(id,ind,value){
				Setup_What_If_scenario["scenario_grid_" + tab_id].cells(id,ind).setAttribute("validation", "");
				return true;
			});
			
            Setup_What_If_scenario["scenario_grid_" + tab_id].attachEvent("onEditCell", function(stage,rId,cInd,nValue,oValue){
                shift_onchange(stage,rId,cInd,'');
                return true;
            });
            
            Setup_What_If_scenario["scenario_grid_" + tab_id].attachEvent("onCheck", function(rId,cInd,state){
                use_existing_oncheck(rId, state)
            });

            Setup_What_If_scenario["scenario_grid_" + tab_id].attachEvent("onRowSelect", function(id,ind){
                if (has_right_maintain_whatif_criteria_iu)
                    Setup_What_If_scenario["scenario_menu_" + tab_id].setItemEnabled('delete');
            });
            Setup_What_If_scenario["scenario_grid_" + tab_id].enableHeaderMenu();
            //Loading dropdown for grid
            var combo_obj = Setup_What_If_scenario["scenario_grid_" + tab_id].getColumnCombo(Setup_What_If_scenario["scenario_grid_" + tab_id].getColIndexById('risk_factor'));                
            var cm_param = {"action": "('SELECT ''p'' [id], ''Price Curve'' [value]')", "has_blank_option": false};
            combo_obj.enableFilteringMode(true);
            load_combo(combo_obj, cm_param);
            
            var combo_obj = Setup_What_If_scenario["scenario_grid_" + tab_id].getColumnCombo(Setup_What_If_scenario["scenario_grid_" + tab_id].getColIndexById('shift'));                
            var cm_param = {"action": "('EXEC spa_StaticDataValues @flag = ''h'', @type_id = 24000')", "has_blank_option": false};
            combo_obj.enableFilteringMode(true);
            load_combo(combo_obj, cm_param);
            
            var combo_obj = Setup_What_If_scenario["scenario_grid_" + tab_id].getColumnCombo(Setup_What_If_scenario["scenario_grid_" + tab_id].getColIndexById('shift_by'));                
            var cm_param = {"action": "('SELECT ''p'' [id], ''Percentage'' [value] UNION ALL SELECT ''c'' [id], ''Percentage Index'' [value] UNION ALL SELECT ''v'' [id], ''Value'' [value] UNION ALL SELECT ''u'' [id], ''Value Index'' [value]')"};
            combo_obj.enableFilteringMode(true);
            
            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;
            combo_obj.load(url, function() {
				switch_scenario_grid();
			});
        }
        
        /*
         * Change the columns according to scenario type and load the grid data.
         */
        switch_scenario_grid = function() {
            var scenario_tab_id = Setup_What_If_scenario.tabbar.getActiveTab();
            scenario_tab_id = (scenario_tab_id.indexOf("tab_") != -1) ? scenario_tab_id.replace("tab_", "") : scenario_tab_id;
            var scenario_group_id = Setup_What_If_scenario["general_form" + scenario_tab_id].getItemValue('scenario_group_id');
            
            Setup_What_If_scenario["scenario_menu_" + scenario_tab_id].setItemDisabled('delete');
            var scenario_type = Setup_What_If_scenario["scenario_form_" + scenario_tab_id].getItemValue('scenario_type');
            
            if (scenario_type == 'i') {
                Setup_What_If_scenario["scenario_grid_" + scenario_tab_id].setColumnHidden(Setup_What_If_scenario["scenario_grid_" + scenario_tab_id].getColIndexById('shift1'),true);
                Setup_What_If_scenario["scenario_grid_" + scenario_tab_id].setColumnHidden(Setup_What_If_scenario["scenario_grid_" + scenario_tab_id].getColIndexById('shift2'),true);
                Setup_What_If_scenario["scenario_grid_" + scenario_tab_id].setColumnHidden(Setup_What_If_scenario["scenario_grid_" + scenario_tab_id].getColIndexById('shift3'),true);
                Setup_What_If_scenario["scenario_grid_" + scenario_tab_id].setColumnHidden(Setup_What_If_scenario["scenario_grid_" + scenario_tab_id].getColIndexById('shift4'),true);
                Setup_What_If_scenario["scenario_grid_" + scenario_tab_id].setColumnHidden(Setup_What_If_scenario["scenario_grid_" + scenario_tab_id].getColIndexById('shift5'),true);
                Setup_What_If_scenario["scenario_grid_" + scenario_tab_id].setColumnHidden(Setup_What_If_scenario["scenario_grid_" + scenario_tab_id].getColIndexById('shift6'),true);
                Setup_What_If_scenario["scenario_grid_" + scenario_tab_id].setColumnHidden(Setup_What_If_scenario["scenario_grid_" + scenario_tab_id].getColIndexById('shift7'),true);
                Setup_What_If_scenario["scenario_grid_" + scenario_tab_id].setColumnHidden(Setup_What_If_scenario["scenario_grid_" + scenario_tab_id].getColIndexById('shift8'),true);
                Setup_What_If_scenario["scenario_grid_" + scenario_tab_id].setColumnHidden(Setup_What_If_scenario["scenario_grid_" + scenario_tab_id].getColIndexById('shift9'),true);
                Setup_What_If_scenario["scenario_grid_" + scenario_tab_id].setColumnHidden(Setup_What_If_scenario["scenario_grid_" + scenario_tab_id].getColIndexById('shift10'),true);
                Setup_What_If_scenario["scenario_grid_" + scenario_tab_id].setColumnHidden(Setup_What_If_scenario["scenario_grid_" + scenario_tab_id].getColIndexById('use_existing'),false);
				Setup_What_If_scenario["scenario_grid_" + scenario_tab_id].setColumnHidden(Setup_What_If_scenario["scenario_grid_" + scenario_tab_id].getColIndexById('shift_value'),false);
            } else {
                Setup_What_If_scenario["scenario_grid_" + scenario_tab_id].setColumnHidden(Setup_What_If_scenario["scenario_grid_" + scenario_tab_id].getColIndexById('shift1'),false);
                Setup_What_If_scenario["scenario_grid_" + scenario_tab_id].setColumnHidden(Setup_What_If_scenario["scenario_grid_" + scenario_tab_id].getColIndexById('shift2'),false);
                Setup_What_If_scenario["scenario_grid_" + scenario_tab_id].setColumnHidden(Setup_What_If_scenario["scenario_grid_" + scenario_tab_id].getColIndexById('shift3'),false);
                Setup_What_If_scenario["scenario_grid_" + scenario_tab_id].setColumnHidden(Setup_What_If_scenario["scenario_grid_" + scenario_tab_id].getColIndexById('shift4'),false);
                Setup_What_If_scenario["scenario_grid_" + scenario_tab_id].setColumnHidden(Setup_What_If_scenario["scenario_grid_" + scenario_tab_id].getColIndexById('shift5'),false);
                Setup_What_If_scenario["scenario_grid_" + scenario_tab_id].setColumnHidden(Setup_What_If_scenario["scenario_grid_" + scenario_tab_id].getColIndexById('shift6'),false);
                Setup_What_If_scenario["scenario_grid_" + scenario_tab_id].setColumnHidden(Setup_What_If_scenario["scenario_grid_" + scenario_tab_id].getColIndexById('shift7'),false);
                Setup_What_If_scenario["scenario_grid_" + scenario_tab_id].setColumnHidden(Setup_What_If_scenario["scenario_grid_" + scenario_tab_id].getColIndexById('shift8'),false);
                Setup_What_If_scenario["scenario_grid_" + scenario_tab_id].setColumnHidden(Setup_What_If_scenario["scenario_grid_" + scenario_tab_id].getColIndexById('shift9'),false);
                Setup_What_If_scenario["scenario_grid_" + scenario_tab_id].setColumnHidden(Setup_What_If_scenario["scenario_grid_" + scenario_tab_id].getColIndexById('shift10'),false);
                Setup_What_If_scenario["scenario_grid_" + scenario_tab_id].setColumnHidden(Setup_What_If_scenario["scenario_grid_" + scenario_tab_id].getColIndexById('use_existing'),true);
				Setup_What_If_scenario["scenario_grid_" + scenario_tab_id].setColumnHidden(Setup_What_If_scenario["scenario_grid_" + scenario_tab_id].getColIndexById('shift_value'),true);
            }
            
            var param = {
                            "action": "spa_maintain_scenario_dhx",
                            "flag": "g",
                            "scenario_group_id": scenario_group_id,
							"scenario_type": scenario_type
                        };

            param = $.param(param);
            var param_url = js_data_collector_url + "&" + param;
            Setup_What_If_scenario["scenario_grid_" + scenario_tab_id].clearAll();
            Setup_What_If_scenario["scenario_grid_" + scenario_tab_id].loadXML(param_url, function() {
                check_shift_use_existing();
            });
        }
        
        /*
         * function to load combos in update mode
         */
        check_shift_use_existing = function() {
            var scenario_tab_id = Setup_What_If_scenario.tabbar.getActiveTab();
            var tab_id = (scenario_tab_id.indexOf("tab_") != -1) ? scenario_tab_id.replace("tab_", "") : scenario_tab_id;
            var scenario_type = Setup_What_If_scenario["scenario_form_" + tab_id].getItemValue('scenario_type');
            
            Setup_What_If_scenario["scenario_grid_" + tab_id].forEachRow(function(id){
                var shift_col_ind = Setup_What_If_scenario["scenario_grid_" + tab_id].getColIndexById('shift');
                var shift_item_val = Setup_What_If_scenario["scenario_grid_" + tab_id].cells(id,Setup_What_If_scenario["scenario_grid_" + tab_id].getColIndexById('shift_item')).getValue();
                var shift_by_ind = Setup_What_If_scenario["scenario_grid_" + tab_id].getColIndexById('shift_by');
                var shift_value_val = Setup_What_If_scenario["scenario_grid_" + tab_id].cells(id,Setup_What_If_scenario["scenario_grid_" + tab_id].getColIndexById('shift_value')).getValue();
                shift_onchange(2, id, shift_col_ind, shift_item_val);
                shift_onchange(2, id, shift_by_ind, shift_value_val);
                var use_existance_val = Setup_What_If_scenario["scenario_grid_" + tab_id].cells(id,Setup_What_If_scenario["scenario_grid_" + tab_id].getColIndexById('use_existing')).getValue();
                use_existing_oncheck(id, use_existance_val);
            });
        }
        
        /*
         * Function to disble shift by and shift value when use existing is checked.
         */
        use_existing_oncheck = function(rId, state) {
            var scenario_tab_id = Setup_What_If_scenario.tabbar.getActiveTab();
            var tab_id = (scenario_tab_id.indexOf("tab_") != -1) ? scenario_tab_id.replace("tab_", "") : scenario_tab_id;
            
            if (state == true) {
				Setup_What_If_scenario["scenario_grid_" + tab_id].cells(rId,Setup_What_If_scenario["scenario_grid_" + tab_id].getColIndexById('shift_by')).setValue('');
				Setup_What_If_scenario["scenario_grid_" + tab_id].cells(rId,Setup_What_If_scenario["scenario_grid_" + tab_id].getColIndexById('shift_value')).setValue('');
                Setup_What_If_scenario["scenario_grid_" + tab_id].cells(rId,Setup_What_If_scenario["scenario_grid_" + tab_id].getColIndexById('shift_by')).setDisabled(true);
                Setup_What_If_scenario["scenario_grid_" + tab_id].cells(rId,Setup_What_If_scenario["scenario_grid_" + tab_id].getColIndexById('shift_value')).setDisabled(true);
            } else {
                Setup_What_If_scenario["scenario_grid_" + tab_id].cells(rId,Setup_What_If_scenario["scenario_grid_" + tab_id].getColIndexById('shift_by')).setDisabled(false);
                Setup_What_If_scenario["scenario_grid_" + tab_id].cells(rId,Setup_What_If_scenario["scenario_grid_" + tab_id].getColIndexById('shift_value')).setDisabled(false);
            }
        }
        
        /*
         * Function to load the shift item according to the selected shift.
         */
        shift_onchange = function(stage,rId,cInd,set_val) {
            var scenario_tab_id = Setup_What_If_scenario.tabbar.getActiveTab();
            var tab_id = (scenario_tab_id.indexOf("tab_") != -1) ? scenario_tab_id.replace("tab_", "") : scenario_tab_id;
            
            var shift_col_ind = Setup_What_If_scenario["scenario_grid_" + tab_id].getColIndexById('shift');
            var shift_col_val = Setup_What_If_scenario["scenario_grid_" + tab_id].cells(rId,shift_col_ind).getValue();
			var shift_by_ind = Setup_What_If_scenario["scenario_grid_" + tab_id].getColIndexById('shift_by');
            var shift_by_val = Setup_What_If_scenario["scenario_grid_" + tab_id].cells(rId,shift_by_ind).getValue();
            var shift_value_ind = Setup_What_If_scenario["scenario_grid_" + tab_id].getColIndexById('shift_value');

            var use_existing_col_ind = Setup_What_If_scenario["scenario_grid_" + tab_id].getColIndexById('shift');
            if (stage == 2 && shift_col_ind == cInd) {
                var shift_item_row_cmb = Setup_What_If_scenario["scenario_grid_" + tab_id].cells(rId,Setup_What_If_scenario["scenario_grid_" + tab_id].getColIndexById('shift_item')).getCellCombo();
                shift_item_row_cmb.enableFilteringMode(true);

                var cm_param = '';
                if (shift_col_val == 24001) {
                    cm_param = {"action": "spa_source_price_curve_def_maintain", "flag":"l"};
                } else if (shift_col_val == 24002) {
                    cm_param = {"action": "('EXEC spa_StaticDataValues @flag = ''h'', @type_id = 15100')"};
                } else if (shift_col_val == 24003) {
                    cm_param = {"action": "spa_source_commodity_maintain", "flag":"a", "has_blank_option": false};
                }

                var data = $.param(cm_param);
                var url = js_dropdown_connector_url + '&' + data;
                Setup_What_If_scenario["scenario_grid_" + tab_id].cells(rId,Setup_What_If_scenario["scenario_grid_" + tab_id].getColIndexById('shift_item')).setValue('');
                shift_item_row_cmb.load(url, function() {
                    if (set_val != '') {
                         Setup_What_If_scenario["scenario_grid_" + tab_id].cells(rId,Setup_What_If_scenario["scenario_grid_" + tab_id].getColIndexById('shift_item')).setValue(set_val);
                    }
                });
            } else if (stage == 2 && shift_by_ind == cInd) {
				var shift_by_row_cmb = Setup_What_If_scenario["scenario_grid_" + tab_id].cells(rId,Setup_What_If_scenario["scenario_grid_" + tab_id].getColIndexById('shift_value')).getCellCombo();
				shift_by_row_cmb.enableFilteringMode(true);
                
				if (shift_by_val == 'p' || shift_by_val == 'v') {
					shift_by_row_cmb.clearAll();
                    Setup_What_If_scenario["scenario_grid_" + tab_id].setCellExcellType(rId, shift_value_ind, 'ed_no');

					if (set_val != '') {
						Setup_What_If_scenario["scenario_grid_" + tab_id].cells(rId,Setup_What_If_scenario["scenario_grid_" + tab_id].getColIndexById('shift_value')).setValue(set_val);
					} else {
						Setup_What_If_scenario["scenario_grid_" + tab_id].cells(rId,Setup_What_If_scenario["scenario_grid_" + tab_id].getColIndexById('shift_value')).setValue('');
					}
				} else if (shift_by_val == 'c' || shift_by_val == 'u') {
					shift_by_row_cmb.clearAll();
					var cm_param = {"action": "('EXEC spa_source_price_curve_def_maintain @flag = ''l'', @source_curve_type_value_id = 578')"};
					var data = $.param(cm_param);
					var url = js_dropdown_connector_url + '&' + data;
					Setup_What_If_scenario["scenario_grid_" + tab_id].cells(rId,Setup_What_If_scenario["scenario_grid_" + tab_id].getColIndexById('shift_value')).setValue('');
					shift_by_row_cmb.load(url, function() {
						if (set_val != '') {
							 Setup_What_If_scenario["scenario_grid_" + tab_id].cells(rId,Setup_What_If_scenario["scenario_grid_" + tab_id].getColIndexById('shift_value')).setValue(set_val);
						}
					});
				}
			}
        }
            
        /*
         * Function the load data in the combo
         */
        function load_combo(combo_obj, combo_sql) {
            var data = $.param(combo_sql);
            var url = js_dropdown_connector_url + '&' + data;
            combo_obj.load(url);
        }
        
		Setup_What_If_scenario.pre_save_scenario = function(tab_id) {
			var active_tab_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
            
			var del_flag = Setup_What_If_scenario["scenario_grid_" + active_tab_id].getUserData("", "deleted_xml");
			
			if (del_flag == 'deleted') {
                del_msg = get_locale_value("Some data has been deleted from Scenario grid. Are you sure you want to save?");
				dhtmlx.message({
					type: "confirm-warning",
                    title: get_locale_value("Warning"),
                    text: del_msg,
                    ok: get_locale_value("Ok"),
                    cancel: get_locale_value("Cancel"),
					callback: function(result) {
						if (result)
							Setup_What_If_scenario.save_scenario(active_tab_id);                
					}
				});
			} else {
				Setup_What_If_scenario.save_scenario(active_tab_id);                     
			}
		}
		
        /*
         * Function to save the scenario and scenario detail.
         */
        Setup_What_If_scenario.save_scenario = function(tab_id) {
            var scenario_tab_id = Setup_What_If_scenario.tabbar.getActiveTab();
            var active_object_id = (scenario_tab_id.indexOf("tab_") != -1) ? scenario_tab_id.replace("tab_", "") : scenario_tab_id;
			Setup_What_If_scenario["scenario_grid_" + active_object_id].clearSelection();
              Setup_What_If_scenario.tabbar.forEachTab(function(tab){
                var att_lay_obj = tab.getAttachedObject();
                att_tabbar_obj = att_lay_obj.cells('a').getAttachedObject();
                detail_tabs = att_tabbar_obj.getAllTabs();
          
        });
            var check_array_size = detail_tabs.toString().indexOf(",");
                    if(check_array_size != -1){
                        var arr = detail_tabs.toString().split(",");
                    } else {
                        arr [0] = detail_tabs;
                    }
            var status = validate_form(Setup_What_If_scenario["general_form" + active_object_id]);
             var status1 = validate_form(Setup_What_If_scenario["scenario_form_" + active_object_id]);
            if (status == false) {
               generate_error_message();
                Setup_What_If_scenario["scenario_tab_" + active_object_id].tabs(arr[0]).setActive();
                return;
            }
            
           
            if (status1 == false) {
                Setup_What_If_scenario["scenario_tab_" + active_object_id].tabs(arr[1])
                return;
            }
			
			var grid_status = Setup_What_If_scenario.validate_form_grid(Setup_What_If_scenario["scenario_grid_" + active_object_id], 'Scenario');
			if (grid_status == false) {
                Setup_What_If_scenario["scenario_tab_" + active_object_id].tabs(arr[1]).setActive();
                return;
			}
            
            var scenario_group_id = Setup_What_If_scenario["general_form" + active_object_id].getItemValue('scenario_group_id');
            
            scenario_group_name = Setup_What_If_scenario["general_form" + active_object_id].getItemValue('scenario_group_name');
            Setup_What_If_scenario["general_form" + active_object_id].setUserData("", "scenario_group_name", scenario_group_name);
            
            var scenario_group_description = Setup_What_If_scenario["general_form" + active_object_id].getItemValue('scenario_group_description');
            var role = Setup_What_If_scenario["general_form" + active_object_id].getItemValue('role');
            var user = Setup_What_If_scenario["general_form" + active_object_id].getItemValue('user');
            var active = Setup_What_If_scenario["general_form" + active_object_id].isItemChecked('active');
            var public = Setup_What_If_scenario["general_form" + active_object_id].isItemChecked('public');
            var source = Setup_What_If_scenario["scenario_form_" + active_object_id].getItemValue('source');
            var Volatility_source = Setup_What_If_scenario["scenario_form_" + active_object_id].getItemValue('Volatility_source');
            var scenario_type = Setup_What_If_scenario["scenario_form_" + active_object_id].getCheckedValue('scenario_type');
			var revaluation = Setup_What_If_scenario["scenario_form_" + active_object_id].isItemChecked('revaluation');
            
            var definition_xml = '<ScenarioDefinition ';
            definition_xml += ' scenario_group_id="' + scenario_group_id + '"';
            definition_xml += ' scenario_group_name="' + scenario_group_name + '"';
            definition_xml += ' scenario_group_description="' + scenario_group_description + '"';
            definition_xml += ' role="' + role + '"';
            definition_xml += ' user="' + user + '"';
            
            active = (active == 1) ? 'y' : 'n';
            definition_xml += ' active="' + active + '"';
            public = (public == 1) ? 'y' : 'n';
            definition_xml += ' public="' + public + '"';
            definition_xml += ' scenario_type="' + scenario_type + '"';
            definition_xml += ' source="' + source + '"';
			revaluation = (revaluation == 1) ? 'y' : 'n';
			definition_xml += ' revaluation="' + revaluation + '"';
            definition_xml += ' Volatility_source="' + Volatility_source + '"/>';
            
			var detail_xml = '';
            Setup_What_If_scenario["scenario_grid_" + active_object_id].forEachRow(function(id){
                detail_xml += '<ScenarioDetail ';
                Setup_What_If_scenario["scenario_grid_" + active_object_id].forEachCell(id,function(cellObj,ind){
                    detail_xml += ' ' + Setup_What_If_scenario["scenario_grid_" + active_object_id].getColumnId(ind) + '="' + Setup_What_If_scenario["scenario_grid_" + active_object_id].cells(id,ind).getValue() + '"';
                });
                detail_xml += ' scenario_type="' + scenario_type + '"'; 
                detail_xml += '/>';
            });
            //console.log(Setup_What_If_scenario.tabbar.cells(Setup_What_If_scenario.tabbar.getActiveTab()).getAttachedToolbar());
            Setup_What_If_scenario.tabbar.cells(Setup_What_If_scenario.tabbar.getActiveTab()).getAttachedToolbar().disableItem('save')

            //Setup_What_If_scenario.tabbar.tabs(tab_id).getAttachedToolbar().disableItem('save');
            flag = 'u';
            if (scenario_group_id == '') {
                flag = 'i'; 
            }
            var final_xml = '<Root>' + definition_xml + detail_xml + '</Root>';

            var data = {
                            "action": "spa_maintain_scenario_dhx",
                            "flag": flag,
                            "scenario_group_id": scenario_group_id, 
                            "save_xml": final_xml,
							"scenario_type": scenario_type
                        };

            adiha_post_data('alert', data, '', '', 'save_scenario_callback', '');
        }
        
        /*
         * Call back function of save_scenario. Changes the tab id and tab name and reload the grids.
         */
        save_scenario_callback = function(result) {
            var active_tab_id = Setup_What_If_scenario.tabbar.getActiveTab();
            var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            var tab_index = Setup_What_If_scenario.tabbar.tabs(active_tab_id).getIndex();
            var scenario_group_name = Setup_What_If_scenario["general_form" + active_object_id].getUserData("", "scenario_group_name");
            if (has_right_maintain_whatif_criteria_iu) {
                Setup_What_If_scenario.tabbar.cells(Setup_What_If_scenario.tabbar.getActiveTab()).getAttachedToolbar().enableItem('save');
            };


            if(result[0].errorcode == 'Success'){
                if (result[0].recommendation == '') {
                    Setup_What_If_scenario.refresh_grid("", Setup_What_If_scenario.refresh_tab_properties);
                } else {
                    tab_id = 'tab_' + result[0].recommendation;
                    Setup_What_If_scenario.create_tab_custom(tab_id, scenario_group_name, tab_index);
                    Setup_What_If_scenario.tabbar.tabs(active_tab_id).close(true);
                }
                Setup_What_If_scenario.refresh_grid();
                Setup_What_If_scenario.menu.setItemDisabled("delete");
                switch_scenario_grid();
            }
        } 
        /**
         *
         */
        Setup_What_If_scenario.create_tab_custom = function(full_id,text, tab_index) {
            var win = Setup_What_If_scenario.pages[full_id];//tabbar.cells(full_id);
            if (!Setup_What_If_scenario.pages[full_id]) {
                Setup_What_If_scenario.tabbar.addTab(full_id, text, null, tab_index, true, true);
                var win = Setup_What_If_scenario.tabbar.cells(full_id);
                win.progressOn();

                var toolbar = win.attachToolbar();
                toolbar.setIconsPath("<?php echo $app_php_script_loc; ?>components/lib/adiha_dhtmlx/themes/"+theme_selected+"/imgs/dhxtoolbar_web/");
                toolbar.loadStruct([{id: "save", type: "button", img: "save.gif", text: "Save", title: "Save"}]);
                toolbar.attachEvent("onClick", function(){
                    Setup_What_If_scenario.pre_save_scenario(full_id);
                });

                Setup_What_If_scenario.tabbar.cells(full_id).setActive();
                Setup_What_If_scenario.tabbar.cells(full_id).setText(text);
                Setup_What_If_scenario.load_scenario(win, full_id);
                Setup_What_If_scenario.pages[full_id] = win;
            } else {
                Setup_What_If_scenario.tabbar.cells("'" + full_id + "'").setActive();
            }
        }
        /**
         *
         */
        Setup_What_If_scenario.refresh_tab_properties = function() {
            var primary_value;
            var col_type = Setup_What_If_scenario.grid.getColType(0);
            var prev_id = Setup_What_If_scenario.tabbar.getActiveTab();
            var system_id = (prev_id.indexOf("tab_") != -1) ? prev_id.replace("tab_", "") : prev_id;
            
            if (col_type == "tree") {
                primary_value = Setup_What_If_scenario.grid.findCell(system_id, 1, true, true);
            } else {
                primary_value = Setup_What_If_scenario.grid.findCell(system_id, 0, true, true);
            } 
            if (primary_value != "") {
                var r_id = primary_value.toString().substring(0, primary_value.toString().indexOf(","));
                var tab_text = Setup_What_If_scenario.get_text(Setup_What_If_scenario.grid, r_id);
                Setup_What_If_scenario.tabbar.tabs(prev_id).setText(tab_text);
                Setup_What_If_scenario.grid.selectRowById(r_id,false,true,true);
            } 
            var win = Setup_What_If_scenario.tabbar.cells(prev_id);
            var tab_obj = win.tabbar[system_id];
            var detail_tabs = tab_obj.getAllTabs();
            
            $.each(detail_tabs, function(index,value) {
                layout_obj = tab_obj.cells(value).getAttachedObject();
                layout_obj.forEachItem(function(cell){
                    attached_obj = cell.getAttachedObject();
                    if (attached_obj instanceof dhtmlXGridObject) {
                        attached_obj.clearSelection();
                        var grid_obj = attached_obj.getUserData("","grid_obj");
                        eval(grid_obj + ".refresh_grid()");
                    }
                });
            });
        }   
        
        /*
         * Refresh the scenario group grid.
         */
        refresh_scenario_group_grid = function() {
            var param = {
                            "action": "spa_maintain_scenario_dhx",
                            "flag": "m",
                            "active": "y",
                            "public": "n",
                     };

            param = $.param(param);
            var param_url = js_data_collector_url + "&" + param;
            Setup_What_If_scenario.grid.clearAll();
            Setup_What_If_scenario.grid.loadXML(param_url);
			Setup_What_If_scenario.menu.setItemDisabled('delete');
        }
        
        /*
         * Delete the scenario group and scenario
         */
        Setup_What_If_scenario.delete_scenario = function() {
            var selected_id = Setup_What_If_scenario.grid.getSelectedId();
            var count = selected_id.indexOf(",") > -1 ? selected_id.split(",").length : 1;
            selected_id = selected_id.indexOf(",") > -1 ? selected_id.split(",") : [selected_id];

            if(selected_id == null) {
                show_messagebox('Please select the data you want to delete.');
                return;
            }
            var scenario_group_id = '';
            for (var i = 0; i < count; i++) {
                scenario_group_id += Setup_What_If_scenario.grid.cells(selected_id[i], 0).getValue() + ',';
            }
            scenario_group_id = scenario_group_id.slice(0, -1);
            // scenario_group_id = Setup_What_If_scenario.grid.cells(selected_id, 0).getValue();
			// scenario_group_name = Setup_What_If_scenario.grid.cells(selected_id, 1).getValue();
            var data = {
                        "action": "spa_maintain_scenario_dhx",
                        "flag": "d",
                        "del_scenario_group_id": scenario_group_id
                    };

            var confirm_msg = get_locale_value('Are you sure you want to delete?');

            dhtmlx.message({
                type: "confirm",
                title: get_locale_value("Confirmation"),
                text: confirm_msg,
                ok: get_locale_value("Ok"),
                cancel: get_locale_value("Cancel"),
                callback: function(result) {
                    if (result)
                        adiha_post_data('alert', data, '', '', 'Setup_What_If_scenario.delete_callback', '');
                }
            });
        }
        
        /*
         * Delete callback function. Close the delete tab if it is in open state.
         */
        Setup_What_If_scenario.delete_callback = function(result) {
            if (result[0].recommendation.indexOf(",") > -1) {
                var ids = result[0].recommendation.split(",");
                var count_ids = ids.length;
                for (var i = 0; i < count_ids; i++ ) {
                    full_id = 'tab_' + ids[i];
                    if (Setup_What_If_scenario.pages[full_id]) {
                        Setup_What_If_scenario.tabbar.cells(full_id).close();
                    }
                }
            } else {
                full_id = 'tab_' + result[0].recommendation;
                if (Setup_What_If_scenario.pages[full_id]) {
                    Setup_What_If_scenario.tabbar.cells(full_id).close();
                }
            }
            refresh_scenario_group_grid();
				}
		
		function undock_scenario_grid() {
			var scenario_tab_id = Setup_What_If_scenario.tabbar.getActiveTab();
            var active_object_id = (scenario_tab_id.indexOf("tab_") != -1) ? scenario_tab_id.replace("tab_", "") : scenario_tab_id;
            
			Setup_What_If_scenario["scenario_layout_" + active_object_id].cells('b').undock(300, 300, 900, 700);
			Setup_What_If_scenario["scenario_layout_" + active_object_id].dhxWins.window('b').maximize();
			Setup_What_If_scenario["scenario_layout_" + active_object_id].dhxWins.window("b").button("park").hide();
            $('.undock_a').hide();
		} 

        Setup_What_If_scenario.validate_form_grid = function(attached_obj,grid_label) {;
            var status = true;
            
            for (var i = 0;i < attached_obj.getRowsNum();i++){
                var row_id = attached_obj.getRowId(i);
                for (var j = 0;j < attached_obj.getColumnsNum();j++){ 
                    var validation_message = attached_obj.cells(row_id,j).getAttribute("validation");
                    
                    if(validation_message != "" && validation_message != undefined){
                        var column_text = attached_obj.getColLabel(j);
                        error_message = "Data Error in <b>"+grid_label+"</b> grid. Please check the data in column <b>"+column_text+"</b> and save.";
                        dhtmlx.alert({title:"Alert",type:"alert",text: error_message});
                        status = false; break;
                    }
                }
                if(validation_message != "" && validation_message != undefined){ break;};
             }
            return status;
        }

                
            
		
		dhtmlxValidation.isEmptyOrNumeric=function(data){
			if (data=="") {
				return true;
			} else if (isNaN(data) == false) {
				return true;
			} else {
				return false;
			}
		}
         
    </script>
</body>
</html>