<?php
/**
* Setup forecast model screen
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
        $form_namespace = 'setup_forecast_model';
        $form_obj = new AdihaStandardForm($form_namespace, 10167300);
        $form_obj->define_grid("setup_forecast_model", "EXEC spa_setup_forecast_model @flag = 's'");
        $form_obj->define_custom_functions('save_forecast_model', 'load_forecast_model', '');
        echo $form_obj->init_form('Setup Forcast Model', 'Setup Forcast Model Detail');
        //echo $form_obj->attach_event('', 'onChange', 'fx_form_onChange()');
        echo "setup_forecast_model.menu.addNewChild('t1', 3, 'copy', 'Copy', false, 'copy.gif', 'copy_dis.gif');";
        echo "setup_forecast_model.menu.setItemDisabled('copy');";
        if (true) {
            echo "setup_forecast_model.grid.attachEvent('onRowSelect', function(){";
            echo      "setup_forecast_model.menu.setItemEnabled('copy');";
            echo      "setup_forecast_model.menu.attachEvent('onClick', setup_forecast_model.copy_function);";
            echo "});";
        }
        echo $form_obj->close_form();
    ?>
<body>
    <script type="text/javascript">   
    status_delete = false;
        /*
         * Save function
         */
        setup_forecast_model.save_forecast_model = function(tab_id) {
            if (status_delete) {
                del_msg =  "Some data has been deleted from grid. Are you sure you want to save?";
                dhtmlx.message({
                    type: "confirm",
                    title: "Warning",
                    text: del_msg,
                    callback: function(result) {
                        if (!result) {
                            status_delete = false;
                            refresh_forecast_model_grid();
                            refresh_parameter_grid();
                            return
                        } else {
                            setup_forecast_model.saving_forecast_model(tab_id);
                            status_delete = false;
                        }
                    }
                });
            } else {
                setup_forecast_model.saving_forecast_model(tab_id);
                status_delete = false;
            }
        }

        setup_forecast_model.saving_forecast_model = function(tab_id) {
            var forecast_model_tab_id = setup_forecast_model.tabbar.getActiveTab();
            var active_object_id = (forecast_model_tab_id.indexOf("tab_") != -1) ? forecast_model_tab_id.replace("tab_", "") : forecast_model_tab_id;
            
            setup_forecast_model["parameter_grid_" + active_object_id].clearSelection();
            var status = validate_form(setup_forecast_model["forecast_model_form_" + active_object_id]);
            var status1 = validate_form(setup_forecast_model["neural_network_form_" + active_object_id]);
            if (!status || !status1) {
                return;
            }
            
            var forecast_model_id = setup_forecast_model["forecast_model_form_" + active_object_id].getItemValue('forecast_model_id');
            forecast_model_name = setup_forecast_model["forecast_model_form_" + active_object_id].getItemValue('forecast_model_name');
            var forecast_type = setup_forecast_model["forecast_model_form_" + active_object_id].getItemValue('forecast_type');
            var time_series = setup_forecast_model["forecast_model_form_" + active_object_id].getItemValue('time_series');
            var forecast_category = setup_forecast_model["forecast_model_form_" + active_object_id].getItemValue('forecast_category');
            var forecast_granularity = setup_forecast_model["forecast_model_form_" + active_object_id].getItemValue('forecast_granularity');
            var threshold = setup_forecast_model["neural_network_form_" + active_object_id].getItemValue('threshold');
            var maximum_step = setup_forecast_model["neural_network_form_" + active_object_id].getItemValue('maximum_step');
            var learning_rate = setup_forecast_model["neural_network_form_" + active_object_id].getItemValue('learning_rate');
            var repetition = setup_forecast_model["neural_network_form_" + active_object_id].getItemValue('repetition');
            var hidden_layer = setup_forecast_model["neural_network_form_" + active_object_id].getItemValue('hidden_layer');
            var algorithm = setup_forecast_model["neural_network_form_" + active_object_id].getItemValue('algorithm');
            var error_function = setup_forecast_model["neural_network_form_" + active_object_id].getItemValue('error_function');
            
            var active = setup_forecast_model["forecast_model_form_" + active_object_id].isItemChecked('active');
            if (active == true) { active = 'y'; } else { active = 'n'; }

            var sequential_forecast = setup_forecast_model["neural_network_form_" + active_object_id].isItemChecked('sequential_forecast');
            if (sequential_forecast == true) { sequential_forecast = 'y'; } else { sequential_forecast = 'n'; }

            var form_xml = '<ForecastModel ';
            form_xml += ' forecast_model_id="' + forecast_model_id + '"';
            form_xml += ' forecast_model_name="' + forecast_model_name + '"';
            form_xml += ' forecast_type="' + forecast_type + '"';
            if(forecast_type == '43803')
                form_xml += ' time_series="' + time_series + '"';
            else
                form_xml += ' time_series= ""';
            form_xml += ' forecast_category="' + forecast_category + '"' 
            form_xml += ' forecast_granularity="' + forecast_granularity + '"'
            form_xml += ' threshold="' + threshold + '"'
            form_xml += ' maximum_step="' + maximum_step + '"'
            form_xml += ' learning_rate="' + learning_rate + '"'
            form_xml += ' repetition="' + repetition + '"'
            form_xml += ' hidden_layer="' + hidden_layer + '"'
            form_xml += ' algorithm="' + algorithm + '"'
            form_xml += ' active="' + active + '"',
            form_xml += ' sequential_forecast="' + sequential_forecast + '"',
            form_xml += ' error_function="' + error_function + '"/>';
            
            var gran_validity = true;
            var grid_xml = '';
            setup_forecast_model["parameter_grid_" + active_object_id].forEachRow(function(id) {
                grid_xml += '<ParameterGrid ';
                setup_forecast_model["parameter_grid_" + active_object_id].forEachCell(id,function(cellObj,ind){
                    var col_id = setup_forecast_model["parameter_grid_" + active_object_id].getColumnId(ind);
                    var col_val = setup_forecast_model["parameter_grid_" + active_object_id].cells(id,ind).getValue();
                    if(col_id == 'series_type') {
                        if (col_val == '44001' || col_val == 'Calendar Attributes') {
                            gran_validity = false;
                        }
                    }
                    if(col_id == 's_order'){
                        var row_index = setup_forecast_model["parameter_grid_" + active_object_id].getRowIndex(id);
                        col_val = row_index + 1;
                    }
                    grid_xml += ' ' + col_id + '="' + col_val + '"';
                        
                });
                grid_xml += '/>';
            });
            var flag = 'i';
            var final_xml = '<Root>' + form_xml + grid_xml + '</Root>';
            var data = {
                            "action": "spa_setup_forecast_model",
                            "flag": flag,
                            "forecast_model_id": forecast_model_id, 
                            "xml_data": final_xml
                        };
                        
            if((forecast_granularity == '993' || forecast_granularity == '980') && gran_validity == false) {
                var gran_combo = setup_forecast_model["forecast_model_form_" + active_object_id].getCombo('forecast_granularity');
                var msg = gran_combo.getSelectedText();
                dhtmlx.message({
                    title: "Alert", type: "alert", text:"Calendar Attribute not required for <strong> "+msg+" </strong>granularity."
                });
                return
            }

            var status = setup_forecast_model.validate_form_grid(setup_forecast_model["parameter_grid_" + active_object_id], 'parameter');
            if (status == false) {
                setup_forecast_model["parameter_grid_" + active_object_id].tabs(arr[0]).setActive();
                return;
            }

            adiha_post_data('return_json', data, '', '', 'save_forecast_model_callback', '');
        }
        
        /*
         * Save callback function
         */
        save_forecast_model_callback = function(result) {
            var forecast_model_tab_id = setup_forecast_model.tabbar.getActiveTab();
            var active_object_id = (forecast_model_tab_id.indexOf("tab_") != -1) ? forecast_model_tab_id.replace("tab_", "") : forecast_model_tab_id;
            
            var return_data = JSON.parse(result);
            var new_id = return_data[0].recommendation;
            setup_forecast_model["forecast_model_form_" + active_object_id].setItemValue('forecast_model_id', new_id);
            setup_forecast_model.tabbar.tabs(forecast_model_tab_id).setText(forecast_model_name);
            
            if (return_data[0].status == "Success") {     
                dhtmlx.message({
                    text:return_data[0].message,
                    expire:1000
                });
            } else {
                dhtmlx.message({
                    title:"Error",
                    type:"alert-error",
                    text:return_data[0].message
                });
            }
            
            refresh_forecast_model_grid();
            refresh_parameter_grid();
        }
        
        /*
         * Load Function - Called when double clicked on forecast model main grid.
         */
        setup_forecast_model.load_forecast_model = function(win, tab_id, grid_obj) {
            win.progressOff();
            var forecast_model_tab_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
            
            setup_forecast_model["forecast_model_layout_" + forecast_model_tab_id] = win.attachLayout({
                pattern:'2E',
                cells: [{id: "a",text: "Form", header: false, height: 120}, 
                        {id: "b",text: "<a class=\"undock_a undock-btn undock_custom\" style=\"float: right; cursor:pointer\" title=\"Undock\"  onClick=\"undock_forecast_detail_grid();\"></a>Input Parameters"}]
            });
            setup_forecast_model["forecast_model_layout_" + forecast_model_tab_id].cells('b').attachEvent("onUnDock", function(name) {
                $('.undock-a').hide();
            });
            
            setup_forecast_model["forecast_model_layout_" + forecast_model_tab_id].cells('b').attachEvent("onDock", function(name) {
                $('.undock-a').show();
            });
            
            data = {"action": "spa_create_application_ui_json",
                    "flag": "j",
                    "application_function_id": 10167300,
                    "template_name": "setup_forecast_model",
                    "parse_xml": "<Root><PSRecordSet forecast_model_id=\"" + forecast_model_tab_id + "\"></PSRecordSet></Root>"
                 };

            adiha_post_data('return_array', data, '', '', 'load_forecast_model_callback', '');
        }
        /*
         * Callback function of load_forecast_model. Create the tab and load tab contents.
         */
        load_forecast_model_callback = function(result) {
            var forecast_model_tab_id = setup_forecast_model.tabbar.getActiveTab();
            var active_object_id = (forecast_model_tab_id.indexOf("tab_") != -1) ? forecast_model_tab_id.replace("tab_", "") : forecast_model_tab_id;
        
            load_general_form(active_object_id, result[0][2]);
            load_input_parameters(active_object_id, result[1][2]);
        }
        
        /*
         * load the form of the general tab.
         */
        load_general_form = function(tab_id, form_json) {
            setup_forecast_model["forecast_model_form_" + tab_id] = setup_forecast_model["forecast_model_layout_" + tab_id].cells('a').attachForm();
            if (form_json) {
                setup_forecast_model["forecast_model_form_" + tab_id].loadStruct(form_json, function(){
                    var forecast_model_tab_id = setup_forecast_model.tabbar.getActiveTab();
                    var active_object_id = (forecast_model_tab_id.indexOf("tab_") != -1) ? forecast_model_tab_id.replace("tab_", "") : forecast_model_tab_id;
                    var forecast_model_id = setup_forecast_model["forecast_model_form_" + active_object_id].getItemValue('forecast_model_id');

                    setup_forecast_model["forecast_model_form_" + active_object_id].attachEvent("onChange", function (name, value){
                         if (name == 'forecast_type') {    
                            if(value == '43803')    
                                setup_forecast_model["forecast_model_form_" + active_object_id].showItem('time_series');
                            else 
                                setup_forecast_model["forecast_model_form_" + active_object_id].hideItem('time_series');
                         }
                    });

                    var param = {
                                    "action": '[spa_setup_forecast_model]',
                                    "flag": 'z',
                                    "forecast_model_id": forecast_model_id
                                };
                    adiha_post_data('return_array', param, '', '', 'check_granualiy_callback'); 
                            

                });
            }
        }

        check_granualiy_callback = function(result) {
            var forecast_model_tab_id = setup_forecast_model.tabbar.getActiveTab();
            var active_object_id = (forecast_model_tab_id.indexOf("tab_") != -1) ? forecast_model_tab_id.replace("tab_", "") : forecast_model_tab_id;
            if (result == 'true') {
                setup_forecast_model["forecast_model_form_" + active_object_id].disableItem("forecast_granularity");
            }

            var forecast_type = setup_forecast_model["forecast_model_form_" + active_object_id].getItemValue('forecast_type');
            if(forecast_type == '43803')    
                setup_forecast_model["forecast_model_form_" + active_object_id].showItem('time_series');
            else 
                setup_forecast_model["forecast_model_form_" + active_object_id].hideItem('time_series');

        }
        
        /*
         * Load the parameter and neural network tab
         */
        load_input_parameters = function(tab_id, form_json) {
            var tab_json = '{tabs: [{"id":"parameter_tab_a","text":"Parameters","active":"true"}, {"id":"parameter_tab_b","text":"Neural Network"}]}';
            
            setup_forecast_model["parameters_tab_" + tab_id] = setup_forecast_model["forecast_model_layout_" + tab_id].cells("b").attachTabbar({mode:"bottom",arrows_mode:"auto"});
            setup_forecast_model["parameters_tab_" + tab_id].loadStruct(tab_json);

            load_parameter_menu(tab_id);
            load_parameter_grid(tab_id);
            load_neural_network(tab_id, form_json);
            combo_grid_event(tab_id);
        }
        
        /*
         * Load the menu in parameter tab
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
            
            setup_forecast_model["parameter_menu_" + tab_id] = setup_forecast_model["parameters_tab_" + tab_id].cells('parameter_tab_a').attachMenu({
                icons_path : js_image_path + "dhxmenu_web/",
                json       : parameter_menu_json
            });   
            
            setup_forecast_model["parameter_menu_" + tab_id].attachEvent("onClick", function(id, zoneId, cas){
                switch(id) {
                    case 'add':
                        var new_id = (new Date()).valueOf();
                        setup_forecast_model["parameter_grid_" + tab_id].addRow(new_id,['','','','','','1']);
                        setup_forecast_model["parameter_grid_" + tab_id].forEachRow(function(row){
                            setup_forecast_model["parameter_grid_" + tab_id].forEachCell(row,function(cellObj,ind){
                                setup_forecast_model["parameter_grid_" + tab_id].validateCell(row,ind)
                            });
                        });
                        break;
                    case 'delete':
                        var selected_row = setup_forecast_model["parameter_grid_" + tab_id].getSelectedRowId();
                        var selected_row_arr = selected_row.split(',');
                        for (cnt = 0; cnt < selected_row_arr.length; cnt++) {
                            setup_forecast_model["parameter_grid_" + tab_id].deleteRow(selected_row_arr[cnt]);
                        }
                        setup_forecast_model["parameter_menu_" + tab_id].setItemDisabled('delete');
                        status_delete = true;
                        break;
                    case 'pdf':
                        setup_forecast_model["parameter_grid_" + tab_id].toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                        break;
                    case 'excel':
                        setup_forecast_model["parameter_grid_" + tab_id].toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                        break;
                    
                }
            });
        }
        
        /*
         * Load the grid in parameter tab
         */
        load_parameter_grid = function(tab_id) {
            setup_forecast_model["parameter_grid_" + tab_id] = setup_forecast_model["parameters_tab_" + tab_id].cells('parameter_tab_a').attachGrid();
            setup_forecast_model["parameter_grid_" + tab_id].setImagePath(js_php_path + "components/lib/adiha_dhtmlx/adiha_grid_3.0/adiha_dhtmlxGrid/codebase/imgs/");    
            setup_forecast_model["parameter_grid_" + tab_id].setHeader(get_locale_value("ID,Series Type,Input Series,Forecast Series,Relative,Use in Model,Order",true));
            setup_forecast_model["parameter_grid_" + tab_id].attachHeader('#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter'); 
            setup_forecast_model["parameter_grid_" + tab_id].setColumnIds("id,series_type,series,output_series,formula,use_in_model,s_order");
            setup_forecast_model["parameter_grid_" + tab_id].setColTypes("ro,combo,combo,combo,ed,ch,ro");
            setup_forecast_model["parameter_grid_" + tab_id].setColumnsVisibility("true,false,false,false,false,false,true");
            setup_forecast_model["parameter_grid_" + tab_id].enableMultiselect(true);
            setup_forecast_model["parameter_grid_" + tab_id].setInitWidths('100,200,250,250,200,200,200');
            // setup_forecast_model["parameter_grid_" + tab_id].enableColumnMove(true);
            setup_forecast_model["parameter_grid_" + tab_id].enableDragAndDrop(true);
            setup_forecast_model["parameter_grid_" + tab_id].init();

            // setup_forecast_model["parameter_grid_" + tab_id].loadOrderFromCookie("grid_cookies");
            // setup_forecast_model["parameter_grid_" + tab_id].loadHiddenColumnsFromCookie("grid_cookies");
            // setup_forecast_model["parameter_grid_" + tab_id].enableOrderSaving("grid_cookies");
            // setup_forecast_model["parameter_grid_" + tab_id].enableAutoHiddenColumnsSaving("grid_cookies");
            setup_forecast_model["parameter_grid_" + tab_id].enableValidation(true);
            setup_forecast_model["parameter_grid_" + tab_id].setColValidators(["" ,"NotEmpty" , "", "","EmptyOrNumeric"]);

            setup_forecast_model["parameter_grid_" + tab_id].attachEvent("onValidationError",function(id,ind,value){
                var message = "Invalid Data";
                setup_forecast_model["parameter_grid_" + tab_id].cells(id,ind).setAttribute("validation", message);
                return true;
            });
            setup_forecast_model["parameter_grid_" + tab_id].attachEvent("onValidationCorrect",function(id,ind,value){
                setup_forecast_model["parameter_grid_" + tab_id].cells(id,ind).setAttribute("validation", "");
                return true;
            });

            //Start: Display specific combo value when forecast_granularity is above the daily.
            var gran_combo = setup_forecast_model["forecast_model_form_" + tab_id].getCombo('forecast_granularity');
            setTimeout(function() {
            var gran_id = gran_combo.getSelectedValue();
            var cm_param = {"action": "[spa_time_series]", 
                            "flag": "m",
                            "has_blank_option":false};

            if(gran_id == '980' || gran_id == '993') {  
                var cm_param = {"action": "[spa_time_series]", 
                            "flag": "m",
                            "filter" : "y",
                            "has_blank_option":false};
            }
            //End.
  
            var combo_obj = setup_forecast_model["parameter_grid_" + tab_id].getColumnCombo(setup_forecast_model["parameter_grid_" + tab_id].getColIndexById('series_type'));                
            // var cm_param = {"action": "[spa_time_series]", 
            //                 "flag": "m",
            //                 "has_blank_option":false};
            combo_obj.enableFilteringMode('between');
            var data = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + data;
            combo_obj.load(url, function() {
                // var combo_obj = setup_forecast_model["parameter_grid_" + tab_id].getColumnCombo(setup_forecast_model["parameter_grid_" + tab_id].getColIndexById('series'));                 
                // var cm_param = {"action": "[spa_time_series]", 
                //                 "flag": "o", 
                //                 "has_blank_option":false };
                // combo_obj.enableFilteringMode('between');

                var data = $.param(cm_param);
                var url = js_dropdown_connector_url + '&' + data;
                combo_obj.load(url, function() {
                    refresh_parameter_grid();
                });

            });
            }, 500);        
            //Dependent combo Series Type -> Series
            setup_forecast_model["parameter_grid_" + tab_id].attachEvent("onEditCell", function(stage,rId,cInd,nValue,oValue){
               if (cInd == 1 && stage == 2 && nValue !== oValue) {
                    var cm_param = {"action": "spa_time_series", 
                                    "flag": "p",
                                     "series_type": nValue
                                    };             
                    var combo_obj_series = setup_forecast_model["parameter_grid_" + tab_id].cells(rId, 2).getCellCombo();
                    setup_forecast_model["parameter_grid_" + tab_id].cells(rId,2).setValue("");
                    var data = $.param(cm_param);
                    var url = js_dropdown_connector_url + '&' + data;
                    combo_obj_series.clearAll();
                    combo_obj_series.enableFilteringMode('between');
                    combo_obj_series.load(url); 

                    var combo_obj_output_series = setup_forecast_model["parameter_grid_" + tab_id].cells(rId, 3).getCellCombo();
                    setup_forecast_model["parameter_grid_" + tab_id].cells(rId,3).setValue("");
                    if(nValue == '44002'){
                        combo_obj_output_series.clearAll();
                        combo_obj_output_series.enableFilteringMode('between');
                        combo_obj_output_series.load(url); 
                        setup_forecast_model["parameter_grid_" + tab_id].cells(rId,3).setDisabled(false);
                    } else {
                        combo_obj_output_series.clearAll();
                        combo_obj_output_series.enableFilteringMode('between');
                        combo_obj_output_series.disable();
                        setup_forecast_model["parameter_grid_" + tab_id].cells(rId,3).setDisabled(true);
                    }
                    
                }
                return true;
            });
            
            setup_forecast_model["parameter_grid_" + tab_id].attachEvent("onRowSelect", function(id,ind){
                setup_forecast_model["parameter_menu_" + tab_id].setItemEnabled('delete');
            });

        }

        load_combo_data = function() {
            var parameters_tab_id = setup_forecast_model.tabbar.getActiveTab();
            var active_object_id = (parameters_tab_id.indexOf("tab_") != -1) ? parameters_tab_id.replace("tab_", "") : parameters_tab_id;
            
            setup_forecast_model["parameter_grid_" + active_object_id].forEachRow(function(id) {
                var series_type_col_ind = setup_forecast_model["parameter_grid_" + active_object_id].getColIndexById('series_type');
                var series_val = setup_forecast_model["parameter_grid_" + active_object_id].cells(id,setup_forecast_model["parameter_grid_" + active_object_id].getColIndexById('series')).getValue();

                var output_series_val = setup_forecast_model["parameter_grid_" + active_object_id].cells(id,setup_forecast_model["parameter_grid_" + active_object_id].getColIndexById('output_series')).getValue();

                series_onchange(2, id, series_type_col_ind, series_val);
                series_onchange1(2, id, series_type_col_ind, output_series_val);
            });
        }

        /*
         * Function to load the series item according to the selected series type.
         */
        series_onchange = function(stage,rId,cInd,set_val) {
            var parameter_tab_id = setup_forecast_model.tabbar.getActiveTab();
            var active_object_id = (parameter_tab_id.indexOf("tab_") != -1) ? parameter_tab_id.replace("tab_", "") : parameter_tab_id;

            var series_type_col_ind = setup_forecast_model["parameter_grid_" + active_object_id].getColIndexById('series_type');
            var series_type_col_val = setup_forecast_model["parameter_grid_" + active_object_id].cells(rId,series_type_col_ind).getValue();
            var use_existing_col_ind = setup_forecast_model["parameter_grid_" + active_object_id].getColIndexById('series_type');
            if (stage == 2 && series_type_col_ind == cInd) {
                var series_row_cmb = setup_forecast_model["parameter_grid_" + active_object_id].cells(rId,setup_forecast_model["parameter_grid_" + active_object_id].getColIndexById('series')).getCellCombo();

                 var cm_param = {"action": "spa_time_series", 
                                    "flag": "p",
                                    "series_type": series_type_col_val
                                };           
                series_row_cmb.enableFilteringMode('between');
                var data = $.param(cm_param);
                var url = js_dropdown_connector_url + '&' + data;
                setup_forecast_model["parameter_grid_" + active_object_id].cells(rId,setup_forecast_model["parameter_grid_" + active_object_id].getColIndexById('series')).setValue('');
                // series_row_cmb.enableFilteringMode(true);

                series_row_cmb.load(url, function() {
                    if (set_val != '') {
                         setup_forecast_model["parameter_grid_" + active_object_id].cells(rId,setup_forecast_model["parameter_grid_" + active_object_id].getColIndexById('series')).setValue(set_val);
                    }
                });
            }
        }

        series_onchange1 = function(stage,rId,cInd,set_val) {
            var parameter_tab_id = setup_forecast_model.tabbar.getActiveTab();
            var active_object_id = (parameter_tab_id.indexOf("tab_") != -1) ? parameter_tab_id.replace("tab_", "") : parameter_tab_id;

            var series_type_col_ind = setup_forecast_model["parameter_grid_" + active_object_id].getColIndexById('series_type');
            var series_type_col_val = setup_forecast_model["parameter_grid_" + active_object_id].cells(rId,series_type_col_ind).getValue();
            if (stage == 2 && series_type_col_ind == cInd) {
                var output_series_row_cmb = setup_forecast_model["parameter_grid_" + active_object_id].cells(rId,setup_forecast_model["parameter_grid_" + active_object_id].getColIndexById('output_series')).getCellCombo();

                var cm_param = {"action": "[spa_time_series]", 
                        "flag": "p", 
                        "series_type" : "44002",
                        "has_blank_option":false };
                output_series_row_cmb.enableFilteringMode('between');

                var data = $.param(cm_param);
                var url = js_dropdown_connector_url + '&' + data;
                setup_forecast_model["parameter_grid_" + active_object_id].cells(rId,setup_forecast_model["parameter_grid_" + active_object_id].getColIndexById('output_series')).setValue('');
                // output_series_row_cmb.enableFilteringMode(true);

                if(series_type_col_val !== '44002'){
                    output_series_row_cmb.clearAll();
                    output_series_row_cmb.disable();
                    var output_series_col_ind = setup_forecast_model["parameter_grid_" + active_object_id].getColIndexById('output_series');
                    setup_forecast_model["parameter_grid_" + active_object_id].cells(rId,output_series_col_ind).setDisabled(true);
                    return
                }
                output_series_row_cmb.load(url, function() {
                    if (set_val != '') {
                         setup_forecast_model["parameter_grid_" + active_object_id].cells(rId,setup_forecast_model["parameter_grid_" + active_object_id].getColIndexById('output_series')).setValue(set_val);
                    }
                });
            }
        }
     
        /*
         * Load the form in neural network tab
         */
        load_neural_network = function(tab_id, form_json) {
            setup_forecast_model["neural_network_form_" + tab_id] = setup_forecast_model["parameters_tab_" + tab_id].cells('parameter_tab_b').attachForm();
            if (form_json) {
                setup_forecast_model["neural_network_form_" + tab_id].loadStruct(form_json);
            }
        }

        combo_grid_event = function(tab_id) {
            var gran_combo = setup_forecast_model["forecast_model_form_" + tab_id].getCombo('forecast_granularity');
            gran_combo.attachEvent("onChange", function(value, text){
                    var combo_obj = setup_forecast_model["parameter_grid_" + tab_id].getColumnCombo(setup_forecast_model["parameter_grid_" + tab_id].getColIndexById('series_type')); 
                    if(value == '980' || value == '993') {  
                        var cm_param = {"action": "[spa_time_series]", 
                                        "flag": "m",
                                        "filter": "y",
                                        "has_blank_option":false};
                    } else {
                        var cm_param = {"action": "[spa_time_series]", 
                                        "flag": "m",
                                        "has_blank_option":false};
                    }
                    combo_obj.enableFilteringMode('between');
                    var data = $.param(cm_param);
                    var url = js_dropdown_connector_url + '&' + data;
                    combo_obj.load(url, function() {    
                            // refresh_parameter_grid();
                    });
            });
        }
        
        /*
         * Function the refresh forecast model grid
         */
        refresh_forecast_model_grid = function() {
            var forecast_model_tab_id = setup_forecast_model.tabbar.getActiveTab();
            var active_object_id = (forecast_model_tab_id.indexOf("tab_") != -1) ? forecast_model_tab_id.replace("tab_", "") : forecast_model_tab_id;
            
            var param = {
                            "action": "spa_setup_forecast_model",
                            "flag": "s",
                            "grouping_column": "forecast_type,model_name",
                            "grid_type":"tg"
                
                        };

            param = $.param(param);
            var param_url = js_data_collector_url + "&" + param;
            setup_forecast_model.grid.clearAll();
            setup_forecast_model.grid.loadXML(param_url);
        }
        
        /*
         * Function the refresh parameter grid
         */
        refresh_parameter_grid = function() {
            var forecast_model_tab_id = setup_forecast_model.tabbar.getActiveTab();
            var active_object_id = (forecast_model_tab_id.indexOf("tab_") != -1) ? forecast_model_tab_id.replace("tab_", "") : forecast_model_tab_id;
            
            var forecast_model_id = setup_forecast_model["forecast_model_form_" + active_object_id].getItemValue('forecast_model_id');
            var param = {
                            "action": "spa_setup_forecast_model",
                            "flag": "p",
                            "forecast_model_id": forecast_model_id
                        };

            param = $.param(param);
            var param_url = js_data_collector_url + "&" + param;
            setup_forecast_model["parameter_grid_" + active_object_id].clearAll();
            // setup_forecast_model["parameter_grid_" + active_object_id].loadXML(param_url);
            setup_forecast_model["parameter_grid_" + active_object_id].loadXML(param_url, function() {
                load_combo_data(); //Load child combo data from dependent parent combo.
            });

        }
        
        
        /*
         * Function the load data in the combo
         */
        function load_combo(combo_obj, combo_sql) {
            var data = $.param(combo_sql);
            var url = js_dropdown_connector_url + '&' + data;
            combo_obj.load(url);
        }

        setup_forecast_model.copy_function = function(id){
            if (id == 'copy') {
                var selectedId = setup_forecast_model.grid.getSelectedRowId();
                var id = setup_forecast_model.grid.cells(selectedId, 1).getValue();

                if (id == null) {
                    dhtmlx.message({
                        title: "Alert", type: "alert", text:"Please select data before copying."
                    });
                    return;
                } else {
                    /*dhtmlx.message({type: 'confirm', title: 'Confirmation', ok: 'Confirm', text: 'Are you sure you copy contract template?',
                        callback: function(result) {
                            if (result) {      */
                                data = {"action": "spa_setup_forecast_model", "flag": "c", "forecast_model_id": id};
                                adiha_post_data("alert", data, "", "", "setup_forecast_model.callback_copy_contract", "", "");
                            /*}
                        }
                    });*/
                }
            }
        }

        setup_forecast_model.callback_copy_contract = function(result) {
            setup_forecast_model.grid.clearAll();
            setup_forecast_model.refresh_grid();
            setup_forecast_model.menu.setItemDisabled('copy');
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

        setup_forecast_model.validate_form_grid = function(attached_obj,grid_label) {
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