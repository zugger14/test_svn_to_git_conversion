<?php
/**
* Forecast parameters mapping screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../adiha.php.scripts/components/include.file.v3.php');?>
</head>
    <?php
        $form_namespace = 'forecast_parameters_mapping';
        
        $rights_forecast_parameters_mapping_iu = 10167210;
        $rights_forecast_parameters_mapping_delete = 10167211;
        
        list (
            $has_rights_forecast_parameters_mapping_iu,
            $has_rights_forecast_parameters_mapping_delete
            ) = build_security_rights(
            $rights_forecast_parameters_mapping_iu, 
            $rights_forecast_parameters_mapping_delete
        );
        
        $form_obj = new AdihaStandardForm($form_namespace, 10167200);
        $form_obj->define_grid("forecast_parameters_mapping", "");
        $form_obj->define_custom_functions('save_forecast', 'load_forecast', 'delete_forecast');
        echo $form_obj->init_form('Forecast Parameters Mapping', 'Forecast Parameters Mapping Detail');
        echo $form_obj->close_form();
    ?>
<body>
    <script type="text/javascript">
        var rights_forecast_parameters_mapping_iu = '<?php echo (($has_rights_forecast_parameters_mapping_iu) ? $has_rights_forecast_parameters_mapping_iu : '0'); ?>';
        var rights_forecast_parameters_mapping_delete = '<?php echo (($has_rights_forecast_parameters_mapping_delete) ? $has_rights_forecast_parameters_mapping_delete : '0'); ?>';
       
        $(function() {
            refresh_forecast_mapping_grid();
            // var gran_combo = setup_forecast_model["forecast_model_form_" + tab_id].getCombo('forecast_granularity');
        })
        
        /*
         * Function to save the scenario and scenario detail.
         */
        forecast_parameters_mapping.save_forecast = function(tab_id) {
            var forecast_tab_id = forecast_parameters_mapping.tabbar.getActiveTab();
            var active_object_id = (forecast_tab_id.indexOf("tab_") != -1) ? forecast_tab_id.replace("tab_", "") : forecast_tab_id;
			forecast_parameters_mapping["parameter_grid_" + active_object_id].clearSelection();
            var status = validate_form(forecast_parameters_mapping["forecast_form_" + active_object_id]);
            if (status == false) {
                return;
            }
			var input_flag = 0; 
			
			var forecast_mapping_id = forecast_parameters_mapping["forecast_form_" + active_object_id].getItemValue('forecast_mapping_id');
            var forecast_model_id = forecast_parameters_mapping["forecast_form_" + active_object_id].getItemValue('forecast_model_id');
            var output_id = forecast_parameters_mapping["forecast_form_" + active_object_id].getItemValue('output_id');

            var approval_required = forecast_parameters_mapping["forecast_form_" + active_object_id].isItemChecked('approval_required');
            if (approval_required == true) { approval_required = 'y'; } else { approval_required = 'n'; }

            var active = forecast_parameters_mapping["forecast_form_" + active_object_id].isItemChecked('active');
            if (active == true) { active = 'y'; } else { active = 'n'; }

            var source_id = forecast_parameters_mapping["forecast_form_" + active_object_id].getItemValue('source_id');
            
            var form_xml = '<ForecastMapping ';
            form_xml += ' forecast_mapping_id="' + forecast_mapping_id + '"';
            form_xml += ' forecast_model_id="' + forecast_model_id + '"';
            form_xml += ' output_id="' + output_id + '"';
            form_xml += ' approval_required="' + approval_required + '"';
            form_xml += ' active="' + active + '"';
            form_xml += ' source_id="' + source_id + '"' + '/>';
            
			var parameter_grid_xml = '';
            forecast_parameters_mapping["parameter_grid_" + active_object_id].forEachRow(function(id){
                parameter_grid_xml += '<ParameterGrid ';
                forecast_parameters_mapping["parameter_grid_" + active_object_id].forEachCell(id,function(cellObj,ind){
					if (ind == 1) {
						var chk_id = forecast_parameters_mapping["parameter_grid_" + active_object_id].cells(id,ind).getValue();
						var chk_val = forecast_parameters_mapping["parameter_grid_" + active_object_id].cells(id,3).getValue();
						
						if (chk_val == '' && chk_id != 44101)
							input_flag = 1;
					}
                    parameter_grid_xml += ' ' + forecast_parameters_mapping["parameter_grid_" + active_object_id].getColumnId(ind) + '="' + forecast_parameters_mapping["parameter_grid_" + active_object_id].cells(id,ind).getValue() + '"';
                });
                parameter_grid_xml += '/>';
            });
			
			if (input_flag == 1) {
				show_messagebox('Please select the input value in parameter grid.');
				return;
			}
			
            var grid_status = forecast_parameters_mapping.validate_form_grid(forecast_parameters_mapping["date_range_grid_" + active_object_id],'data');

            if (!grid_status) {
                forecast_parameters_mapping["date_range_grid_" + active_object_id].cells(value).setActive();
                valid_status = 0;
            };

            var datarange_grid_xml = '';
            forecast_parameters_mapping["date_range_grid_" + active_object_id].forEachRow(function(id){
                datarange_grid_xml += '<DataRangeGrid ';
                forecast_parameters_mapping["date_range_grid_" + active_object_id].forEachCell(id,function(cellObj,ind){
                    datarange_grid_xml += ' ' + forecast_parameters_mapping["date_range_grid_" + active_object_id].getColumnId(ind) + '="' + forecast_parameters_mapping["date_range_grid_" + active_object_id].cells(id,ind).getValue() + '"';
                });
                datarange_grid_xml += '/>';
            });
            
            
            var flag = 'i'; 
            var final_xml = '<Root>' + form_xml + parameter_grid_xml + datarange_grid_xml + '</Root>';
            
            var data = {
                            "action": "spa_forecast_parameters_mapping",
                            "flag": flag,
                            "forecast_mapping_id": forecast_mapping_id, 
                            "xml_data": final_xml
                        };
            
            adiha_post_data('return_array', data, '', '', 'save_forecast_callback', '');
        }
        
        /*
         * Call back function of save_scenario. Changes the tab id and tab name and reload the grids.
         */
        save_forecast_callback = function(result) {
            if (result[0][0] == 'Error') {
                dhtmlx.alert({
                    title: "Alert",
                    type: "alert",
                    text: result[0][4]
                });
            } else {

                var forecast_tab_id = forecast_parameters_mapping.tabbar.getActiveTab();
                var active_object_id = (forecast_tab_id.indexOf("tab_") != -1) ? forecast_tab_id.replace("tab_", "") : forecast_tab_id;

                var new_id = result[0][5];
                forecast_parameters_mapping["forecast_form_" + active_object_id].setItemValue('forecast_mapping_id', new_id);
                
                var forecast_model_cmb = forecast_parameters_mapping["forecast_form_" + active_object_id].getCombo('forecast_model_id');
                var output_cmb = forecast_parameters_mapping["forecast_form_" + active_object_id].getCombo('output_id');
                var forecast_model = forecast_model_cmb.getComboText();
                var output = output_cmb.getComboText();
                forecast_parameters_mapping.tabbar.tabs(forecast_tab_id).setText(forecast_model + ' - ' + output);
                
                dhtmlx.message({
                        text: result[0][4],
                        expire: 1000
                });
                
                refresh_forecast_mapping_grid();
                refresh_parameter_grid();
                refresh_datarange_grid();
            }
       }
        
        /*
         * delete Function.
         */    
       forecast_parameters_mapping.delete_forecast = function() {
            var selected_id = forecast_parameters_mapping.grid.getSelectedId();
            var tree_level = forecast_parameters_mapping.grid.getLevel(selected_id);
            var count = selected_id.indexOf(",") > -1 ? selected_id.split(",").length : 1;
            selected_id = selected_id.indexOf(",") > -1 ? selected_id.split(",") : [selected_id];
            if (tree_level == 1 || tree_level == -1) {
                var tmp_id = '';
                for (var i = 0; i < count; i++) {
                    tmp_id += forecast_parameters_mapping.grid.cells(selected_id[i], 1).getValue() + ',';
                }
                tmp_id = tmp_id.slice(0, -1);
                var data = {
                            "action": "spa_forecast_parameters_mapping",
                            "flag": "d",
                            "del_forecast_mapping_id": tmp_id
                        };

                var confirm_msg = 'Are you sure you want to delete?';

                dhtmlx.message({
                    type: "confirm",
                    text: confirm_msg,
                    callback: function(result) {
                        if (result)
                        adiha_post_data('alert', data, '', '', 'forecast_parameters_mapping.delete_callback', '');
                    }
                });
            }
        }
       
        forecast_parameters_mapping.delete_callback = function(result) {
            if (result[0].recommendation.indexOf(",") > -1) {
                var ids = result[0].recommendation.split(",");
                var count_ids = ids.length;
                for (var i = 0; i < count_ids; i++ ) {
                    full_id = 'tab_' + ids[i];
                    if (forecast_parameters_mapping.pages[full_id]) {
                        forecast_parameters_mapping.tabbar.cells(full_id).close();
                    }
                }
            } else {
                full_id = 'tab_' + result[0].recommendation;
                if (forecast_parameters_mapping.pages[full_id]) {
                    forecast_parameters_mapping.tabbar.cells(full_id).close();
                }
            }
            refresh_forecast_mapping_grid();
       }
       
        /*
         * Load Function - Called when double clicked on forecast main grid.
         */
        forecast_parameters_mapping.load_forecast = function(win, tab_id, grid_obj) {
            win.progressOff();
            var forecast_tab_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
            
            forecast_parameters_mapping["forecast_layout_" + forecast_tab_id] = win.attachLayout({
                pattern:'2E',
                cells: [{id: "a",text: "Form", header: false, height: 120}, {id: "b",text: "<a class=\"undock_a undock-btn undock_custom\" style=\"float: right; cursor:pointer\" title=\"Undock\"  onClick=\"undock_forecast_detail_grid();\"></a>Forecast"}]
            });
            forecast_parameters_mapping["forecast_layout_" + forecast_tab_id].cells('b').attachEvent("onUnDock", function(name) {
				$('.undock-a').hide();
			});
			
			forecast_parameters_mapping["forecast_layout_" + forecast_tab_id].cells('b').attachEvent("onDock", function(name) {
				$('.undock-a').show();
			});
            
            data = {"action": "spa_create_application_ui_json",
                    "flag": "j",
                    "application_function_id": 10167200,
                    "template_name": "forecast_parameters_mapping",
                    "parse_xml": "<Root><PSRecordSet forecast_mapping_id=\"" + forecast_tab_id + "\"></PSRecordSet></Root>"
                 };

            adiha_post_data('return_array', data, '', '', 'load_forecast_callback', '');
        }
        
        /*
         * Callback function of load_forecast. Create the tab and load tab contents.
         */
        load_forecast_callback = function(result) {
            var forecast_tab_id = forecast_parameters_mapping.tabbar.getActiveTab();
            var active_object_id = (forecast_tab_id.indexOf("tab_") != -1) ? forecast_tab_id.replace("tab_", "") : forecast_tab_id;
            
            load_general_tab(active_object_id, result[0][2]);
            load_parameter_date_range(active_object_id);
        }
        
        
        /*
         * load the general form.
         */
        load_general_tab = function(tab_id, form_json) {
            forecast_parameters_mapping["forecast_form_" + tab_id] = forecast_parameters_mapping["forecast_layout_" + tab_id].cells('a').attachForm();

            if (form_json) {
                forecast_parameters_mapping["forecast_form_" + tab_id].loadStruct(form_json);
                setTimeout(function() {
                    load_output_combo(tab_id); // Load dependent combo

                }, 500);  

                forecast_parameters_mapping["forecast_form_" + tab_id].attachEvent("onChange", function (name, value){
                     if (name == 'forecast_model_id') {              
                        load_output_combo(tab_id); // Load dependent combo
                        refresh_parameter_grid();
                     }
                });
                // refresh_parameter_grid();
            }    
        }
        
        load_output_combo = function(tab_id) {
            forecast_mapping_id = forecast_parameters_mapping["forecast_form_" + tab_id].getItemValue('forecast_mapping_id');
            var output_id = forecast_parameters_mapping["forecast_form_" + tab_id].getCombo('output_id');
            var forecast_combo = forecast_parameters_mapping["forecast_form_" + tab_id].getCombo('forecast_model_id');
            var forecast_model_id_val = forecast_combo.getSelectedValue();

            var cm_param = { 
                       "action": "spa_forecast_parameters_mapping", 
                        "flag": "c",
                        "forecast_model_id_val": forecast_model_id_val,
                        "has_blank_option": "false"
                    };  
            output_id.enableFilteringMode('between');

            var data = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + data;
            output_id.setComboText('');
            output_id.clearAll();
            // output_id.load(url);

            output_id.load(url, function(){        
                if(forecast_mapping_id !== '') {
                    //Get the value of combo to set it.
                    data = {"action": "spa_forecast_parameters_mapping",
                            "flag": "c",
                            "forecast_mapping_id": forecast_mapping_id
                         };
                    var callback_fn = (function (result) {load_output_combo_callback(output_id , result); });
                    adiha_post_data('return_array', data, '', '', callback_fn, ''); 
                } else {
                    output_id.selectOption(0);
                }
            });

        }
        
        load_output_combo_callback = function(output_id, result) {
            output_id.setComboValue(result[0][0]);
        }

        /*
         * Load parameter and data range Tab
         */
        load_parameter_date_range = function(tab_id) {
            var tab_json = '{tabs: [{"id":"parameter_tab_a","text":"Parameters","active":"true"}, {"id":"parameter_tab_b","text":"Data Range"}]}';
            
            forecast_parameters_mapping["parameters_tab_" + tab_id] = forecast_parameters_mapping["forecast_layout_" + tab_id].cells("b").attachTabbar({mode:"bottom",arrows_mode:"auto"});
            forecast_parameters_mapping["parameters_tab_" + tab_id].loadStruct(tab_json);

            // load_parameter_menu(tab_id);
            load_parameter_grid(tab_id);
            load_date_range_menu(tab_id);
            load_date_range_grid(tab_id);
        }
        
        /*
         * Load menu in Parameter Tab
         */
        load_parameter_menu = function(tab_id) {
            var parameter_menu_json = [
                {id:"t1", text:"Edit", img:"edit.gif", items:[
                    {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add", enabled:true},
                    {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete", enabled:false}
                ]},
				{id:"t2", text:"Export", img:"export.gif", items:[
                    {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "Pdf", enabled:true},
                    {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel", enabled:true}
                ]}
            ];
            
            forecast_parameters_mapping["parameter_menu_" + tab_id] = forecast_parameters_mapping["parameters_tab_" + tab_id].cells('parameter_tab_a').attachMenu({
                icons_path : js_image_path + "dhxmenu_web/",
                json       : parameter_menu_json
            });   
            
            forecast_parameters_mapping["parameter_menu_" + tab_id].attachEvent("onClick", function(id, zoneId, cas){
                switch(id) {
                    case 'add':
                        var new_id = (new Date()).valueOf();
						forecast_parameters_mapping["parameter_grid_" + tab_id].addRow(new_id,'');
                        refresh_parameter_grid();
                        break;
                    case 'delete':
                        var selected_row = forecast_parameters_mapping["parameter_grid_" + tab_id].getSelectedRowId();
						var selected_row_arr = selected_row.split(',');
						for (cnt = 0; cnt < selected_row_arr.length; cnt++) {
							forecast_parameters_mapping["parameter_grid_" + tab_id].deleteRow(selected_row_arr[cnt]);
						}
                        forecast_parameters_mapping["parameter_menu_" + tab_id].setItemDisabled('delete');
						break;
					case 'pdf':
						forecast_parameters_mapping["parameter_grid_" + tab_id].toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
						break;
					case 'excel':
						forecast_parameters_mapping["parameter_grid_" + tab_id].toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
						break;
				}
            });
        }
        
        /*
         * Load grid in Parameter Tab
         */
        load_parameter_grid = function(tab_id) {
            forecast_parameters_mapping["parameter_grid_" + tab_id] = forecast_parameters_mapping["parameters_tab_" + tab_id].cells('parameter_tab_a').attachGrid();
            forecast_parameters_mapping["parameter_grid_" + tab_id].setImagePath(js_php_path + "components/lib/adiha_dhtmlx/adiha_grid_3.0/adiha_dhtmlxGrid/codebase/imgs/");    
            forecast_parameters_mapping["parameter_grid_" + tab_id].setHeader(get_locale_value("ID,Input Series,Forecast Series,Input,Forecast,Input Function, Forecast Function",true));
            forecast_parameters_mapping["parameter_grid_" + tab_id].attachHeader('#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter'); 
            forecast_parameters_mapping["parameter_grid_" + tab_id].setColumnIds("id,series,output_series,input,forecast,input_function,forecast_function");
            forecast_parameters_mapping["parameter_grid_" + tab_id].setColTypes("ro,combo,combo,combo,combo,combo,combo");
            forecast_parameters_mapping["parameter_grid_" + tab_id].setColumnsVisibility("true,false,false,false,false,false,false");
            forecast_parameters_mapping["parameter_grid_" + tab_id].setInitWidths('100,200,200,200,200,200,200');
            forecast_parameters_mapping["parameter_grid_" + tab_id].init();
            
            refresh_parameter_grid();
        }
        
        /*
         * Load menu in Data Range Tab
         */
        load_date_range_menu = function(tab_id) {
            var parameter_menu_json = [
                {id:"t1", text:"Edit", img:"edit.gif", items:[
                    {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add", enabled:true},
                    {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete", enabled:false}
                ]},
				{id:"t2", text:"Export", img:"export.gif", items:[
                    {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "Pdf", enabled:true},
                    {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel", enabled:true}
                ]}
            ];
            
            forecast_parameters_mapping["date_range_menu_" + tab_id] = forecast_parameters_mapping["parameters_tab_" + tab_id].cells('parameter_tab_b').attachMenu({
                icons_path : js_image_path + "dhxmenu_web/",
                json       : parameter_menu_json
            });   
            
            forecast_parameters_mapping["date_range_menu_" + tab_id].attachEvent("onClick", function(id, zoneId, cas){
                switch(id) {
                    case 'add':
                        var new_id = (new Date()).valueOf();
						forecast_parameters_mapping["date_range_grid_" + tab_id].addRow(new_id,'');
                        forecast_parameters_mapping["date_range_grid_" + tab_id].forEachRow(function(row){
                            forecast_parameters_mapping["date_range_grid_" + tab_id].forEachCell(row,function(cellObj,ind){
                                forecast_parameters_mapping["date_range_grid_" + tab_id].validateCell(row,ind)
                            });
                        });
                        break;
                    case 'delete':
                        var selected_row = forecast_parameters_mapping["date_range_grid_" + tab_id].getSelectedRowId();
						var selected_row_arr = selected_row.split(',');
						for (cnt = 0; cnt < selected_row_arr.length; cnt++) {
							forecast_parameters_mapping["date_range_grid_" + tab_id].deleteRow(selected_row_arr[cnt]);
						}
                        forecast_parameters_mapping["date_range_menu_" + tab_id].setItemDisabled('delete');
						break;
					case 'pdf':
						forecast_parameters_mapping["date_range_grid_" + tab_id].toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
						break;
					case 'excel':
						forecast_parameters_mapping["date_range_grid_" + tab_id].toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
						break;
				}
            });
        }
        
        /*
         * Load data range grid in Data Range Tab
         */
        load_date_range_grid = function(tab_id) {
            forecast_parameters_mapping["date_range_grid_" + tab_id] = forecast_parameters_mapping["parameters_tab_" + tab_id].cells('parameter_tab_b').attachGrid();
            forecast_parameters_mapping["date_range_grid_" + tab_id].setImagePath(js_php_path + "components/lib/adiha_dhtmlx/adiha_grid_3.0/adiha_dhtmlxGrid/codebase/imgs/");    
            forecast_parameters_mapping["date_range_grid_" + tab_id].setHeader(get_locale_value("ID,Data Type,Value,Granularity",true));
            forecast_parameters_mapping["date_range_grid_" + tab_id].attachHeader('#text_filter,#text_filter,#text_filter,#text_filter'); 
            forecast_parameters_mapping["date_range_grid_" + tab_id].setColumnIds("id,data_type,value,granularity");
            forecast_parameters_mapping["date_range_grid_" + tab_id].setColTypes("ro,combo,ed,combo");
            forecast_parameters_mapping["date_range_grid_" + tab_id].setColumnsVisibility("true,false,false,false");
            forecast_parameters_mapping["date_range_grid_" + tab_id].setInitWidths('100,200,200,200');
            forecast_parameters_mapping["date_range_grid_" + tab_id].enableValidation(true);
            forecast_parameters_mapping["date_range_grid_" + tab_id].setColValidators(["","NotEmpty" ,"ValidInteger" , "ValidInteger"]);
            forecast_parameters_mapping["date_range_grid_" + tab_id].init();

            forecast_parameters_mapping["date_range_grid_" + tab_id].attachEvent("onValidationError",function(id,ind,value){
                var message = "Invalid Data";
                forecast_parameters_mapping["date_range_grid_" + tab_id].cells(id,ind).setAttribute("validation", message);
                return true;
            });
            forecast_parameters_mapping["date_range_grid_" + tab_id].attachEvent("onValidationCorrect",function(id,ind,value){
                forecast_parameters_mapping["date_range_grid_" + tab_id].cells(id,ind).setAttribute("validation", "");
                return true;
            });

            var combo_obj = forecast_parameters_mapping["date_range_grid_" + tab_id].getColumnCombo(forecast_parameters_mapping["date_range_grid_" + tab_id].getColIndexById('data_type'));                
            var cm_param = {"action": "('SELECT value_id,code FROM static_data_value WHERE type_id = 44200')", "has_blank_option":false};
            combo_obj.enableFilteringMode('between');
            var data = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + data;
            combo_obj.load(url, function() {
                var combo_obj = forecast_parameters_mapping["date_range_grid_" + tab_id].getColumnCombo(forecast_parameters_mapping["date_range_grid_" + tab_id].getColIndexById('granularity'));                
                var cm_param = {"action": "('SELECT value_id,code FROM static_data_value WHERE type_id = 978 AND value_id IN (993,980,981)')", "has_blank_option":false};
                combo_obj.enableFilteringMode('between');

                var data = $.param(cm_param);
                var url = js_dropdown_connector_url + '&' + data;
                combo_obj.load(url, function() {
                    refresh_datarange_grid();
                });
            });
            
            forecast_parameters_mapping["date_range_grid_" + tab_id].attachEvent("onRowSelect", function(id,ind){
                forecast_parameters_mapping["date_range_menu_" + tab_id].setItemEnabled('delete');
            });
        }
        
        /*
         * Function to refresh forecast parameter grid
         */
        refresh_forecast_mapping_grid = function() {
            var param = {
                            "action": "spa_forecast_parameters_mapping",
                            "flag": "s",
                            "grouping_column": "forecast_type,output,forecast_category,name",
                            "grid_type":"tg"
                
                     };

            param = $.param(param);
            var param_url = js_data_collector_url + "&" + param;
            forecast_parameters_mapping.grid.clearAll();
            forecast_parameters_mapping.grid.loadXML(param_url, function() {
                forecast_parameters_mapping.grid.expandAll()
            });
        }
        
        /*
         * Function to refresh grid in parameter tab
         */
        refresh_parameter_grid = function() {
            var forecast_tab_id = forecast_parameters_mapping.tabbar.getActiveTab();
            var active_object_id = (forecast_tab_id.indexOf("tab_") != -1) ? forecast_tab_id.replace("tab_", "") : forecast_tab_id;

            setTimeout(function() {
                var forecast_mapping_id = forecast_parameters_mapping["forecast_form_" + active_object_id].getItemValue('forecast_mapping_id');
                var forecast_model_id = forecast_parameters_mapping["forecast_form_" + active_object_id].getItemValue('forecast_model_id');
                
                var combo_obj = forecast_parameters_mapping["parameter_grid_" + active_object_id].getColumnCombo(forecast_parameters_mapping["parameter_grid_" + active_object_id].getColIndexById('series'));    
                var combo_obj_output_series = forecast_parameters_mapping["parameter_grid_" + active_object_id].getColumnCombo(forecast_parameters_mapping["parameter_grid_" + active_object_id].getColIndexById('output_series'));              
                var cm_param = {"action": "spa_forecast_parameters_mapping", "flag": "m", "forecast_model_id": forecast_model_id};
                combo_obj.enableFilteringMode('between');
                load_combo(combo_obj, cm_param); // For series
                load_combo(combo_obj_output_series, cm_param); // For output series

                var forecast_combo = forecast_parameters_mapping["forecast_form_" + active_object_id].getCombo('forecast_model_id');
                var forecast_model_id_val = forecast_combo.getSelectedValue();
                load_grid_combo(active_object_id); // input and forecast dependent combo.

                var param = {
                            "action": "spa_forecast_parameters_mapping",
                            "flag": "m",
                            "status": "g",
                            "forecast_model_id": forecast_model_id,
                            "forecast_mapping_id": forecast_mapping_id
                     };

                param = $.param(param);
                var param_url = js_data_collector_url + "&" + param;
                forecast_parameters_mapping["parameter_grid_" + active_object_id].clearAll();
                setTimeout(function() {
                    forecast_parameters_mapping["parameter_grid_" + active_object_id].loadXML(param_url, function() {
                        load_combo_data();
                    });
                }, 400);

            }, 700); 
        }

        load_grid_combo = function(active_object_id) {
            //Dependent combo in grid.
            forecast_parameters_mapping["parameter_grid_" + active_object_id].attachEvent("onEditCell", function(stage,rId,cInd,nValue,oValue){
                if (cInd == 3 && stage == 2 && nValue !== oValue) { // For input combo - > input function combo
                    var forecast_model_id = forecast_parameters_mapping["forecast_form_" + active_object_id].getItemValue('forecast_model_id');
                    var combo_obj_input_fun = forecast_parameters_mapping["parameter_grid_" + active_object_id].cells(rId, 5).getCellCombo();

                    var series_val = forecast_parameters_mapping["parameter_grid_" + active_object_id].cells(rId,forecast_parameters_mapping["parameter_grid_" + active_object_id].getColIndexById('id')).getValue();

                    var cm_param = {"action": "spa_forecast_parameters_mapping", "flag": "m", "status": "m", "forecast_model_id": forecast_model_id, "model_id": series_val, "forecast_model_id_val": nValue};
                    forecast_parameters_mapping["parameter_grid_" + active_object_id].cells(rId,5).setValue("");
                    combo_obj_input_fun.enableFilteringMode('between');
                    var data = $.param(cm_param);
                    var url = js_dropdown_connector_url + '&' + data;
                    combo_obj_input_fun.clearAll();
                    combo_obj_input_fun.load(url);  
                                       
                }

                if (cInd == 4 && stage == 2 && nValue !== oValue) { // For forecast combo -> forecast function combo
                    var forecast_model_id = forecast_parameters_mapping["forecast_form_" + active_object_id].getItemValue('forecast_model_id');
                    var combo_obj_forecast_fun = forecast_parameters_mapping["parameter_grid_" + active_object_id].cells(rId, 6).getCellCombo();

                    var forecast_val = forecast_parameters_mapping["parameter_grid_" + active_object_id].cells(rId,forecast_parameters_mapping["parameter_grid_" + active_object_id].getColIndexById('id')).getValue();

                    var cm_param = {"action": "spa_forecast_parameters_mapping", "flag": "m", "status": "m", "forecast_model_id": forecast_model_id, "model_id": forecast_val, "series_typ" : "f", "forecast_model_id_val": nValue};
                    forecast_parameters_mapping["parameter_grid_" + active_object_id].cells(rId,6).setValue("");
                    combo_obj_forecast_fun.enableFilteringMode('between');
                    var data = $.param(cm_param);
                    var url = js_dropdown_connector_url + '&' + data;
                    combo_obj_forecast_fun.clearAll();
                    combo_obj_forecast_fun.load(url);  
                                       
                }
                return true;
            });
        }


        load_combo_data = function() { // For input and forecast.... input & forecast function.
            var forecast_tab_id = forecast_parameters_mapping.tabbar.getActiveTab();
            var active_object_id = (forecast_tab_id.indexOf("tab_") != -1) ? forecast_tab_id.replace("tab_", "") : forecast_tab_id;
            forecast_parameters_mapping["parameter_grid_" + active_object_id].forEachRow(function(id) {
                var series_col_ind = forecast_parameters_mapping["parameter_grid_" + active_object_id].getColIndexById('series');
                var output_series_col_ind = forecast_parameters_mapping["parameter_grid_" + active_object_id].getColIndexById('output_series');

                var input_val = forecast_parameters_mapping["parameter_grid_" + active_object_id].cells(id,forecast_parameters_mapping["parameter_grid_" + active_object_id].getColIndexById('input')).getValue();
                var forecast_val = forecast_parameters_mapping["parameter_grid_" + active_object_id].cells(id,forecast_parameters_mapping["parameter_grid_" + active_object_id].getColIndexById('forecast')).getValue();

                var input_fun_val = forecast_parameters_mapping["parameter_grid_" + active_object_id].cells(id,forecast_parameters_mapping["parameter_grid_" + active_object_id].getColIndexById('input_function')).getValue();
                var forecast_fun_val = forecast_parameters_mapping["parameter_grid_" + active_object_id].cells(id,forecast_parameters_mapping["parameter_grid_" + active_object_id].getColIndexById('forecast_function')).getValue();
                forecast_parameters_mapping["parameter_grid_" + active_object_id].cells(id,series_col_ind).setDisabled(true);
                forecast_parameters_mapping["parameter_grid_" + active_object_id].cells(id,output_series_col_ind).setDisabled(true);

                series_onchange(2, id, series_col_ind, input_val, input_fun_val); // For input combo 
                series_onchange1(2, id, series_col_ind, forecast_val, forecast_fun_val); // For forecast combo
            });
        }

        series_onchange = function(stage,rId,cInd,set_val, input_fun_val) { // Load the dependent input combo and set data.
            var parameter_tab_id = forecast_parameters_mapping.tabbar.getActiveTab();
            var active_object_id = (parameter_tab_id.indexOf("tab_") != -1) ? parameter_tab_id.replace("tab_", "") : parameter_tab_id;

            var series_col_ind = forecast_parameters_mapping["parameter_grid_" + active_object_id].getColIndexById('series');
            var series_col_val = forecast_parameters_mapping["parameter_grid_" + active_object_id].cells(rId,series_col_ind).getValue();
            var use_existing_col_ind = forecast_parameters_mapping["parameter_grid_" + active_object_id].getColIndexById('series');
            if (stage == 2 && series_col_ind == cInd) {
                var input_row_cmb = forecast_parameters_mapping["parameter_grid_" + active_object_id].cells(rId,forecast_parameters_mapping["parameter_grid_" + active_object_id].getColIndexById('input')).getCellCombo();
                var input_fun_row_cmb = forecast_parameters_mapping["parameter_grid_" + active_object_id].cells(rId,forecast_parameters_mapping["parameter_grid_" + active_object_id].getColIndexById('input_function')).getCellCombo();
                 var cm_param = {"action": "spa_forecast_parameters_mapping", 
                                    "flag": "m",
                                    "status": "z",
                                    "forecast_model_id": series_col_val
                                };           
                input_row_cmb.enableFilteringMode('between');

                var data = $.param(cm_param);
                var url = js_dropdown_connector_url + '&' + data;
                forecast_parameters_mapping["parameter_grid_" + active_object_id].cells(rId,forecast_parameters_mapping["parameter_grid_" + active_object_id].getColIndexById('input')).setValue('');

                // input_row_cmb.enableFilteringMode(true);
                input_row_cmb.load(url, function() {
                    if (set_val != '') {
                         forecast_parameters_mapping["parameter_grid_" + active_object_id].cells(rId,forecast_parameters_mapping["parameter_grid_" + active_object_id].getColIndexById('input')).setValue(set_val);
                    }
                });

                // ***********************For input function***************************.
                var forecast_model_id = forecast_parameters_mapping["forecast_form_" + active_object_id].getItemValue('forecast_model_id');
                var series_val = forecast_parameters_mapping["parameter_grid_" + active_object_id].cells(rId,forecast_parameters_mapping["parameter_grid_" + active_object_id].getColIndexById('id')).getValue();
                var cm_param = {"action": "spa_forecast_parameters_mapping", 
                                    "flag": "m",
                                    "status": "m",
                                    "forecast_model_id": forecast_model_id,
                                    "forecast_model_id_val" : set_val,
                                    "model_id": series_val
                                }; 
                input_fun_row_cmb.enableFilteringMode('between');
      
                var data = $.param(cm_param);
                var url = js_dropdown_connector_url + '&' + data;
                forecast_parameters_mapping["parameter_grid_" + active_object_id].cells(rId,forecast_parameters_mapping["parameter_grid_" + active_object_id].getColIndexById('input_function')).setValue('');
                // input_fun_row_cmb.enableFilteringMode(true);
                input_fun_row_cmb.load(url, function() {
                    if (input_fun_val != '') {
                         forecast_parameters_mapping["parameter_grid_" + active_object_id].cells(rId,forecast_parameters_mapping["parameter_grid_" + active_object_id].getColIndexById('input_function')).setValue(input_fun_val);
                    }
                });
            }

        }

        series_onchange1 = function(stage,rId,cInd,set_val, forecast_fun_val) {
            var parameter_tab_id = forecast_parameters_mapping.tabbar.getActiveTab();
            var active_object_id = (parameter_tab_id.indexOf("tab_") != -1) ? parameter_tab_id.replace("tab_", "") : parameter_tab_id;

            var series_col_ind = forecast_parameters_mapping["parameter_grid_" + active_object_id].getColIndexById('series');
            var series_col_val = forecast_parameters_mapping["parameter_grid_" + active_object_id].cells(rId,series_col_ind).getValue();
            var use_existing_col_ind = forecast_parameters_mapping["parameter_grid_" + active_object_id].getColIndexById('series');
            if (stage == 2 && series_col_ind == cInd) {
                var forecast_row_cmb = forecast_parameters_mapping["parameter_grid_" + active_object_id].cells(rId,forecast_parameters_mapping["parameter_grid_" + active_object_id].getColIndexById('forecast')).getCellCombo();
                var forecast_fun_row_cmb = forecast_parameters_mapping["parameter_grid_" + active_object_id].cells(rId,forecast_parameters_mapping["parameter_grid_" + active_object_id].getColIndexById('forecast_function')).getCellCombo();

                if(series_col_val == '44004') { // Load
                    var status = 'x';
                } else if (series_col_val == '44003') { // Price
                    var status = 'w';
                } else if (series_col_val == '44105') {
                    var status = 'n';
                } else {
                    var status = 'z';
                }

                var cm_param = {"action": "spa_forecast_parameters_mapping", 
                                "flag": "m",
                                "status": status,
                                "forecast_model_id": series_col_val
                            };    
                forecast_row_cmb.enableFilteringMode('between');
              
                var data = $.param(cm_param);
                var url = js_dropdown_connector_url + '&' + data;
                forecast_parameters_mapping["parameter_grid_" + active_object_id].cells(rId,forecast_parameters_mapping["parameter_grid_" + active_object_id].getColIndexById('forecast')).setValue('');
                // forecast_row_cmb.enableFilteringMode(true);
                forecast_row_cmb.load(url, function() {
                    if (set_val != '') {
                         forecast_parameters_mapping["parameter_grid_" + active_object_id].cells(rId,forecast_parameters_mapping["parameter_grid_" + active_object_id].getColIndexById('forecast')).setValue(set_val);
                    }
                });


                // ***********************For forecast function***************************.
                var forecast_model_id = forecast_parameters_mapping["forecast_form_" + active_object_id].getItemValue('forecast_model_id');
                var forecast_val = forecast_parameters_mapping["parameter_grid_" + active_object_id].cells(rId,forecast_parameters_mapping["parameter_grid_" + active_object_id].getColIndexById('id')).getValue();

                var cm_param = {"action": "spa_forecast_parameters_mapping", 
                                    "flag": "m",
                                    "status": "m",
                                    "forecast_model_id": forecast_model_id,
                                    "forecast_model_id_val" : set_val,
                                    "model_id": forecast_val,
                                    "series_typ" : "f"
                                };  
                forecast_fun_row_cmb.enableFilteringMode('between');       

                var data = $.param(cm_param);
                var url = js_dropdown_connector_url + '&' + data;
                forecast_parameters_mapping["parameter_grid_" + active_object_id].cells(rId,forecast_parameters_mapping["parameter_grid_" + active_object_id].getColIndexById('forecast_function')).setValue('');
                // forecast_fun_row_cmb.enableFilteringMode(true);
                forecast_fun_row_cmb.load(url, function() {
                    if (forecast_fun_val != '') {
                         forecast_parameters_mapping["parameter_grid_" + active_object_id].cells(rId,forecast_parameters_mapping["parameter_grid_" + active_object_id].getColIndexById('forecast_function')).setValue(forecast_fun_val);
                    }
                });

            }
        }
        
        /*
         * Function to refresh grid in data range tab
         */
        refresh_datarange_grid = function() {
            var forecast_tab_id = forecast_parameters_mapping.tabbar.getActiveTab();
            var active_object_id = (forecast_tab_id.indexOf("tab_") != -1) ? forecast_tab_id.replace("tab_", "") : forecast_tab_id;
            
            var forecast_mapping_id = forecast_parameters_mapping["forecast_form_" + active_object_id].getItemValue('forecast_mapping_id');
            
            var param = {
                            "action": "spa_forecast_parameters_mapping",
                            "flag": "r",
                            "forecast_mapping_id": forecast_mapping_id
                     };

            param = $.param(param);
            var param_url = js_data_collector_url + "&" + param;
            forecast_parameters_mapping["date_range_grid_" + active_object_id].clearAll();
            forecast_parameters_mapping["date_range_grid_" + active_object_id].loadXML(param_url);
        
        }
        
        
        function undock_forecast_detail_grid() {
			var forecast_tab_id = forecast_parameters_mapping.tabbar.getActiveTab();
            var active_object_id = (forecast_tab_id.indexOf("tab_") != -1) ? forecast_tab_id.replace("tab_", "") : forecast_tab_id;
            
			forecast_parameters_mapping["forecast_layout_" + active_object_id].cells('b').undock(300, 300, 900, 700);
			forecast_parameters_mapping["forecast_layout_" + active_object_id].dhxWins.window('b').maximize();
			forecast_parameters_mapping["forecast_layout_" + active_object_id].dhxWins.window("b").button("park").hide();
		}
        
        
        /*
         * Function the load data in the combo
         */
        function load_combo(combo_obj, combo_sql) {
            var data = $.param(combo_sql);
            var url = js_dropdown_connector_url + '&' + data;
            combo_obj.load(url);
        }

    forecast_parameters_mapping.validate_form_grid = function(attached_obj,grid_label) {
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

</body>
</html>