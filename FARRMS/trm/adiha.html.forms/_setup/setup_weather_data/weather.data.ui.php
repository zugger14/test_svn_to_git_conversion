<!DOCTYPE html>
<html> 
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
<body>    
    <?php
    $php_script_loc = $app_php_script_loc;
    $app_user_loc = $app_user_name;
    $time_series_definition_id = get_sanitized_value($_GET["time_series_definition_id"] ?? '');
    $series_type = get_sanitized_value($_GET["series_type"] ?? '');
    $save_permission = get_sanitized_value($_GET["save_permission"] ?? '');

    $xml_file = "EXEC spa_weather_data @flag='c', @series_type='" . $series_type . "'";
    $return_value = readXMLURL($xml_file);
    
    $data_check = $return_value[0][0];
    if ($data_check == 0) {
        $granularity_value = '';
        $group_value = '';
        $effective_date_applicable = '';
        $maturity_applicable = '';
        
    } else {
        $granularity_value = $return_value[0][1];
        $group_value = $return_value[0][2];
        $effective_date_applicable = $return_value[0][3];
        $maturity_applicable = $return_value[0][4];
    }

    $rights_weather_data_delete = 10166210;
    list (
        $has_rights_weather_data_delete
    ) = build_security_rights(
        $rights_weather_data_delete
    );

    $json = '[
                {
                    id:             "a",
                    text:           "Series Definition",
                    header:         false,
                    collapse:       false,
                    height:         150
                },
                {
                    id:             "b",
                    text:           "Series Definition Grid",
                    header:         false,
                    collapse:       false
                }
            ]';
    
    $namespace = 'time_series_ui';
    $time_series_ui_layout_obj = new AdihaLayout();
    echo $time_series_ui_layout_obj->init_layout('time_series_ui_layout', '', '2E', $json, $namespace);
    
    $menu_name = 'time_series_ui_menu';
    $menu_json = '[
                    {id:"save", text:"Save", img:"save.gif", imgdis:"save_dis.gif", enabled:' . $save_permission . '}
                ]';

    echo $time_series_ui_layout_obj->attach_menu_layout_cell($menu_name, 'a', $menu_json, $namespace.'.save_click');

    $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10166210', @template_name='weather data', @parse_xml = '<Root><PSRecordSet time_series_definition_id=\"" . $time_series_definition_id . "\"></PSRecordSet></Root>'";    
    $return_value1 = readXMLURL($xml_file);
    $form_json = $return_value1[0][2];
    echo $time_series_ui_layout_obj->attach_form('time_series_form', 'a');
    $time_series_form = new AdihaForm();
    echo $time_series_form->init_by_attach('time_series_form', $namespace);
    echo $time_series_form->load_form($form_json);
    
    $menu_name = 'weather_data_detail_menu';
    $menu_json = '[
                    {id:"edit", text:"Edit", img:"edit.gif", imgdis:"edit_dis.gif", items:[
                        {id:"add", text:"Add", img:"add.gif", imgdis:"add_dis.gif", enabled: true},
                        {id:"delete", text:"Delete", img:"delete.gif", imgdis:"delete_dis.gif",enabled:0}
                    ]},
                    {id:"t2", text:"Export", img:"export.gif", imgdis:"export_dis.gif", items:[    
                        {id:"excel", text:"Excel", img:"excel.gif"},
                        {id:"pdf", text:"PDF", img:"pdf.gif"}
                    ]}
                ]';

    echo $time_series_ui_layout_obj->attach_menu_layout_cell($menu_name, 'b', $menu_json, $namespace.'.weather_data_detail_menu_click');
    
    $grid_name = 'weather_data_detail';
    echo $time_series_ui_layout_obj->attach_grid_cell('weather_data_detail_grid', 'b');
    $weather_data_grid = new GridTable($grid_name);
    echo $weather_data_grid->init_grid_table('weather_data_detail_grid', $namespace);    
    echo $weather_data_grid->return_init();
    echo $weather_data_grid->attach_event('', 'onRowSelect', $namespace.'.row_select');
    
    echo $time_series_ui_layout_obj->close_layout();
    ?>

</body>
</html>

<script>
    
    var delete_xml = '';
    var delete_flag = '';
    var series_type = '';
    var group_value = '';
    var granularity_value = '';
    var effective_date_applicable = '';
    var maturity_applicable = '';
    var has_rights_weather_data_delete = <?php echo (($has_rights_weather_data_delete) ? $has_rights_weather_data_delete : '0'); ?>;

    $(function() {
        
        var data_check = '<?php echo $data_check; ?>';
        series_type = '<?php echo $series_type; ?>';
        group_value = '<?php echo $group_value; ?>';
        granularity_value = '<?php echo $granularity_value; ?>';
        effective_date_applicable = '<?php echo $effective_date_applicable; ?>';
        maturity_applicable = '<?php echo $maturity_applicable; ?>';
             
         if (data_check == '0') {
            //time_series_ui.time_series_form.disableItem('maturity_applicable');
            //time_series_ui.time_series_form.disableItem('effective_date_applicable');
            time_series_ui.time_series_form.disableItem('granulalrity');
        } else {            
            time_series_ui.time_series_form.setItemValue('granulalrity', granularity_value);
            time_series_ui.time_series_form.setItemValue('group_id', group_value);
            if (effective_date_applicable == 'y') {
                time_series_ui.time_series_form.checkItem('effective_date_applicable'); 
            } else {
                time_series_ui.time_series_form.uncheckItem('effective_date_applicable'); 
            }
            
            if (maturity_applicable == 'y') {
                time_series_ui.time_series_form.checkItem('maturity_applicable'); 
            } else {
                time_series_ui.time_series_form.uncheckItem('maturity_applicable');
            }
        }
        
        if (series_type != '') {
            time_series_ui.time_series_form.setItemValue('time_series_type_value_id', series_type);
            time_series_ui.time_series_form.disableItem('time_series_type_value_id');
        }    
        
        var is_checked = time_series_ui.time_series_form.isItemChecked('maturity_applicable');           
        if (is_checked == true) {
            time_series_ui.time_series_form.enableItem('granulalrity');
        } 
        
        time_series_ui.time_series_form.attachEvent("onChange", function (name, value){
             if (name == 'maturity_applicable') {
                var is_checked = time_series_ui.time_series_form.isItemChecked(name);
                if (is_checked == false) {
                    time_series_ui.time_series_form.setItemValue('granulalrity', '');
                    time_series_ui.time_series_form.disableItem('granulalrity');
                } else {
                    time_series_ui.time_series_form.enableItem('granulalrity');
                }
             }
        });
        
        if (data_check == '2') { // data exists in time series data then it required to disable to change maturity date and granularity                
            time_series_ui.time_series_form.disableItem('granulalrity');
            time_series_ui.time_series_form.disableItem('maturity_applicable');
            time_series_ui.time_series_form.disableItem('group_id');    
        }          
        
        time_series_ui.refresh_weather_data_detail_grid();  
        
    })
    
    /*
     * time_series_ui.refresh_weather_data_detail_grid    [Refresh the grid]
     */
    time_series_ui.refresh_weather_data_detail_grid = function() {
        time_series_ui.time_series_ui_layout.cells('b').progressOn();
        var series_type = '<?php echo $series_type; ?>';
        var param = {
            "flag": "h",
            "action":"spa_weather_data",
            "grid_type":"g",
            "series_type":series_type
        };

        param = $.param(param);
        var param_url = js_data_collector_url + "&" + param;
        time_series_ui.weather_data_detail_grid.clearAndLoad(param_url, function() {
            time_series_ui.time_series_ui_layout.cells('b').progressOff();
        });
    }
    
    /*
     * time_series_ui.series_values_menu_click    [Menu Click function of series values]
     */
    time_series_ui.weather_data_detail_menu_click = function(id, zoneId, cas) {
        switch(id) {
            case 'refresh':
                time_series_ui.refresh_weather_data_detail_grid();
                break;
            case "add":
                var new_id = (new Date()).valueOf();
                time_series_ui.weather_data_detail_grid.addRow(new_id,'');
                myCombo = time_series_ui.weather_data_detail_grid.cells(new_id, 7);
                myCombo.setValue('0');
                time_series_ui.weather_data_detail_grid.forEachCell(new_id,function(cellObj,ind){
                    time_series_ui.weather_data_detail_grid.validateCell(new_id,ind);
                });
                break;
            case "delete":
                var row_id = time_series_ui.weather_data_detail_grid.getSelectedRowId();
                var row_id_array = row_id.split(",");
                for (count = 0; count < row_id_array.length; count++) {
                    if (time_series_ui.weather_data_detail_grid.cells(row_id_array[count],0).getValue() != '') {
                        delete_xml += '<GridRow ' + time_series_ui.weather_data_detail_grid.getColumnId(0) + '="' + time_series_ui.weather_data_detail_grid.cells(row_id_array[count],0).getValue() + '" />'; 
                        delete_flag = 1;
                    }
                    time_series_ui.weather_data_detail_grid.deleteRow(row_id_array[count]);
                }
                time_series_ui.weather_data_detail_menu.setItemDisabled("delete");
                break;
            case 'excel':
                time_series_ui.weather_data_detail_grid.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                break;
            case 'pdf':
                time_series_ui.weather_data_detail_grid.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                break; 
        }
    }
    
     /*
     * time_series_ui.save_click    [Save the time series definition]
     */
    time_series_ui.save_click = function() {   
         if (delete_flag == 1) {
                    del_msg =  "Some data has been deleted from Series Definition grid. Are you sure you want to save?";
                    dhtmlx.message({
                        type: "confirm-warning",
                        title: "Warning",
                        ok: "Confirm",
                        text: del_msg,
                        
                        callback: function(result) {
                            if (result)
                                time_series_ui.definition_save_click();                
                        }
                    });
                } else {
                    time_series_ui.definition_save_click();
                }
    }
        
    /*
     * time_series_ui.definition_save_click    [Save the time series definition]
     */
    time_series_ui.definition_save_click = function() {        
        time_series_ui.weather_data_detail_grid.clearSelection();
        var status = true;
        for (var i = 0; i < time_series_ui.weather_data_detail_grid.getRowsNum(); i++){
 			var row_id = time_series_ui.weather_data_detail_grid.getRowId(i);
 			for (var j = 0; j < time_series_ui.weather_data_detail_grid.getColumnsNum(); j++){ 
 				var is_hidden = time_series_ui.weather_data_detail_grid.isColumnHidden(j);
                
                if (!is_hidden) {
                    var validation_message = time_series_ui.weather_data_detail_grid.cells(row_id,j).getAttribute("validation");
     				if(validation_message != "" && validation_message != undefined){
     					var column_text = time_series_ui.weather_data_detail_grid.getColLabel(j);
    					error_message = "Data Error in <b>Series Definition</b> grid. Please check the data in column <b>"+column_text+"</b> and resave.";
    					dhtmlx.alert({title:"Alert",type:"alert",text: error_message});
     					status = false; 
                        break;
     				}
                    
                    /***combo validation*****/
                    if(time_series_ui.weather_data_detail_grid.getColType(j) == 'combo') {
                        
                        if(time_series_ui.weather_data_detail_grid.cells(row_id,j).getValue() != '') {
                            var dhxCombo = time_series_ui.weather_data_detail_grid.getColumnCombo(j);
                            var selected_option = dhxCombo.getOption(time_series_ui.weather_data_detail_grid.cells(row_id,j).getValue());
                            
                            if(selected_option == null) {
                                var column_text = time_series_ui.weather_data_detail_grid.getColLabel(j);
                                
                                error_message = "Data Error in <b>Series Definition</b> grid. Please check the data in column <b>" + column_text + "</b> and resave.";
                                dhtmlx.alert({
                                    title : "Alert!",
                                    type : "alert",
                                    text : error_message
                                });

                                status = false;
                                break;
                            }
                        }                                                                   
                    }
                    /*****combo validation END*******/ 
                    
                }
            }
    		if(validation_message != "" && validation_message != undefined){ break;};
     	}
        
        if(!status)
            return;
        
        var status = validate_form(time_series_ui.time_series_form);
        var name;
        if (status) {
            var series_type = time_series_ui.time_series_form.getItemValue('time_series_type_value_id');
            var granularity_update = time_series_ui.time_series_form.getItemValue('granulalrity');
            var group_id_update = time_series_ui.time_series_form.getItemValue('group_id');
            var maturity_checked = time_series_ui.time_series_form.isItemChecked('maturity_applicable');
            var effective_date_checked = time_series_ui.time_series_form.isItemChecked('effective_date_applicable');
            
            var maturity_applicable_update = (maturity_checked == true) ? 'y' : 'n';
            var effective_date_applicable_update = (effective_date_checked == true) ? 'y' : 'n';
            
            if (maturity_checked == true && granularity_update == '') {
                show_messagebox('Please select the granularity.');
                return;
            }
            
            if (group_id_update == '') {
                show_messagebox('Please select Time Series Group.');
                return;
            }
            
            var row_ids = time_series_ui.weather_data_detail_grid.getAllRowIds();
            if (row_ids == '') {
                show_messagebox('No Data in <b>Series Definition</b> grid.');
                return;
            }
           
            
            form_data = time_series_ui.time_series_form.getFormData();
            var form_xml = '';
            for (var a in form_data) {
                //if (form_data[a] != '' && form_data[a] != null) {
                    if (time_series_ui.time_series_form.getItemType(a) == 'calendar') {
                        value = time_series_ui.time_series_form.getItemValue(a, true);
                    } else {
                        value = form_data[a];
                    }
                    form_xml += ' ' + a + '="' + value + '"';
                //}
            }
            form_xml += '';
            
            /*** grid xml*****/
            var grid_xml = '<Root><Grid>';
            var changed_rows = time_series_ui.weather_data_detail_grid.getChangedRows(true);
            if(changed_rows != '') {
                changed_rows = changed_rows.split(',');
                for (i = 0; i < changed_rows.length; i++) {
                    grid_xml += '<GridRow ';
    
                    for (j = 0; j < time_series_ui.weather_data_detail_grid.getColumnsNum(); j++) {
                        var colm_id = time_series_ui.weather_data_detail_grid.getColumnId(j);
                        var colm_val = time_series_ui.weather_data_detail_grid.cells(changed_rows[i],j).getValue();
                        if (colm_id == 'value_required') {
                            var colm_val = (colm_val == 1) ? 'y' : 'n';                            
                        }
                        grid_xml += ' ' + colm_id + '="' + colm_val + '"';   
                        
                    }
    
                    grid_xml += ' ' + form_xml + '';
                    grid_xml += ' />'
                }
            } else {
                if (delete_xml == '') {
                    if (granularity_update == granularity_value && group_id_update == group_value && maturity_applicable_update == maturity_applicable && effective_date_applicable_update ==  effective_date_applicable) {
                       
                        show_messagebox('No change in the grid.');
                        return;
                    }
                }
            }
            grid_xml += '</Grid><GridDelete>';
           
            if (delete_xml != '') {
                grid_xml += delete_xml;
            }
            
            grid_xml += '</GridDelete></Root>';
            form_xml = '<Root><FormXML ' + form_xml + ' ></FormXML></Root>';
            /*** grid xml END*****/
            
            var param = {
                "flag": "i",
                "action": "spa_weather_data",
                "series_type": series_type,
                "xml": grid_xml,
                "granularity": granularity_update,
                "effective_date_applicable": effective_date_applicable_update,
                "maturity_applicable": maturity_applicable_update,
                "group_id": group_id_update
            };
            adiha_post_data('return_json', param, '', '', 'time_series_ui.save_click_callback', '');
         }
    }
    
    time_series_ui.save_click_callback = function(result) {
        var return_data = JSON.parse(result);
        var status = return_data[0].status;
        
        if (status == 'Error') {
            show_messagebox(return_data[0].message);
        } else {      
            time_series_ui.refresh_weather_data_detail_grid();
            dhtmlx.message({
                text:return_data[0].message,
                expire:1000
            });
            setTimeout ( function() { 
                window.parent.weather_data_window.window('w1').close(); 
            }, 1000);
        }
    }
    
    /*
     * time_series.row_select    [Row select function]
     */
    time_series_ui.row_select = function(id,ind) {
        if (has_rights_weather_data_delete) {
            time_series_ui.weather_data_detail_menu.setItemEnabled("delete");
        }
    }
    
    
    
</script>