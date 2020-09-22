<?php
/**
* Setup weather data screen
* @copyright Pioneer Solutions
*/
?>
get_sanitized_valueYPE html>
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
    $function_id = get_sanitized_value($_GET["function_parameter"] ?? '10106100');
    $weather_data_id = get_sanitized_value($_GET["weather_data_id"] ?? '');
    $term_start = get_sanitized_value($_GET["term_start"] ?? '');
    $term_end = get_sanitized_value($_GET["term_end"] ?? '');

    $exec_sql = "EXEC spa_weather_data @flag='f', @function_id='" . $function_id . "'";
    $return_arr = readXMLURL($exec_sql);

    $series_type = $return_arr[0][0];
    $rights_weather_data = $function_id;
    $rights_weather_data_ui = $return_arr[0][1];
    $rights_weather_data_delete = $return_arr[0][2];
    $rights_series_value_ui = $return_arr[0][3];
    $layout_header = $return_arr[0][4];

    $hyperlink_e_applicable = '' ;
    $hyperlink_m_applicable = '' ;
    $hyperlink_granularity = '' ;
    $hyperlink_series_name = '' ;

    if ($weather_data_id != '') {
        $exec_sql = "EXEC ('SELECT effective_date_applicable, maturity_applicable, sdv.code [granulalrity], weather_data_name 
						FROM weather_data_definition tsd
						left join static_data_value sdv on tsd.granulalrity = sdv.value_id
						WHERE weather_data_definition_id = " . $weather_data_id . "')";
        $return_arr = readXMLURL($exec_sql);  
        $hyperlink_e_applicable = $return_arr[0][0];
        $hyperlink_m_applicable = $return_arr[0][1];
        $hyperlink_granularity = $return_arr[0][2];
        $hyperlink_series_name = $return_arr[0][3];
    }

    
    list (
        $has_rights_weather_data,
        $has_rights_weather_data_ui,
        $has_rights_weather_data_delete,
        $has_rights_series_value_ui
    ) = build_security_rights(
        $rights_weather_data,
        $rights_weather_data_ui,
        $rights_weather_data_delete,
        $rights_series_value_ui
    );
    
    $first_day_of_month = date('Y-m-01');
    $date =date('Y-m-d');
    $json = '[
                {
                    id:             "a",
                    text:           "' . $layout_header . '",
                    header:         true,
                    collapse:       false,
                    width:          350,
                    undock:         true
                },
                {
                    id:             "b",
                    text:           "Filters",
                    header:         true,
                    collapse:       false,
                    height:          145
                },
                {
                    id:             "c",
                    text:           "Series Values",
                    header:         true,
                    collapse:       false,
                    undock:         true
                }    
            ]';
    
    $namespace = 'weather_data';
    $weather_data_layout_obj = new AdihaLayout();
    echo $weather_data_layout_obj->init_layout('weather_data_layout', '', '3L', $json, $namespace);
  
    $menu_name = 'weather_data_menu';
    $menu_json = '[
                    {id:"edit", text:"Edit", img:"edit.gif", imgdis:"edit_dis.gif", items:[
                        {id:"add", text:"Add/Edit Definition", img:"add.gif", imgdis:"add_dis.gif", enabled: "'.$has_rights_weather_data_ui.'"},                        
                    ]},
                    {id:"t2", text:"Export", img:"export.gif", imgdis:"export_dis.gif", items:[    
                        {id:"excel", text:"Excel", img:"excel.gif"},
                        {id:"pdf", text:"PDF", img:"pdf.gif"}
                    ]},
                    {id:"expand_collapse", text:"Expand/Collapse", img:"exp_col.gif", imgdis:"exp_col_dis.gif"}
                ]';

    echo $weather_data_layout_obj->attach_menu_layout_cell($menu_name, 'a', $menu_json, $namespace.'.weather_data_menu_click');

    $grid_name = 'weather_data';
    echo $weather_data_layout_obj->attach_grid_cell('weather_data_grid', 'a');
    $weather_data_grid = new GridTable($grid_name);
    echo $weather_data_grid->init_grid_table('weather_data_grid', $namespace);
    echo $weather_data_grid->set_search_filter(true); 
    echo $weather_data_grid->return_init();
    echo $weather_data_grid->attach_event('', 'onRowDblClicked', $namespace.'.dbclick_weather_data');
    echo $weather_data_grid->attach_event('', 'onRowSelect', $namespace.'.row_select');
    
    $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10106100', @template_name='setup time series'";
    $return_value1 = readXMLURL($xml_file);
    $form_json = $return_value1[0][2];
    echo $weather_data_layout_obj->attach_form('weather_data_filter_form', 'b');
    $weather_data_filter_form = new AdihaForm();
    echo $weather_data_filter_form->init_by_attach('weather_data_filter_form', $namespace);
    echo $weather_data_filter_form->load_form($form_json);

    $menu_name = 'series_values_menu';
    $menu_json = '[ 
                    {id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif"},
                    {id:"save", text:"Save", img:"save.gif", imgdis:"save_dis.gif", enabled:0},
                    {id:"edit", text:"Edit", img:"edit.gif", imgdis:"edit_dis.gif", items:[
                        {id:"add", text:"Add", img:"add.gif", imgdis:"add_dis.gif", enabled:0},
                        {id:"delete", text:"Delete", img:"delete.gif", imgdis:"delete_dis.gif",enabled:0}
                    ]},
                    {id:"export", text:"Export", img:"export.gif", imgdis:"export_dis.gif", items:[    
                        {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", enabled:0},
                        {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", enabled:0},
                        {id:"batch", text:"Batch", img:"batch.gif", imgdis:"batch_dis.gif"}
                    ]},
                    {id:"pivot", text:"Pivot", img:"pivot.gif", imgdis:"pivot_dis.gif",enabled:"false"}
                ]';

    echo $weather_data_layout_obj->attach_menu_layout_cell($menu_name, 'c', $menu_json, $namespace.'.series_values_menu_click');

    echo $weather_data_layout_obj->close_layout();
    ?>

</body>
</html>

<script>
    var expand_state = 0;
    var delete_xml = '';
    var delete_flag = '';
    var client_date_format = '<?php echo $date_format; ?>';
    
    var hyperlink_weather_data_id = '<?php echo $weather_data_id; ?>';
    var hyperlink_term_start = '<?php echo $term_start; ?>';
    var hyperlink_term_end = '<?php echo $term_end; ?>';
    var hyperlink_e_applicable = '<?php echo $hyperlink_e_applicable; ?>';
    var hyperlink_m_applicable = '<?php echo $hyperlink_m_applicable; ?>';
    var hyperlink_granularity = '<?php echo $hyperlink_granularity; ?>'
    var hyperlink_series_name = '<?php echo $hyperlink_series_name; ?>'
    
    var has_rights_weather_data_ui = <?php echo (($has_rights_weather_data_ui) ? $has_rights_weather_data_ui : '0'); ?>;
    var has_rights_weather_data_delete = <?php echo (($has_rights_weather_data_ui) ? $has_rights_weather_data_ui : '0'); ?>;
    var has_rights_series_value_ui = <?php echo (($has_rights_series_value_ui) ? $has_rights_series_value_ui : '0'); ?>;
    
    $(function() {
        var first_day_of_month = '<?php echo $first_day_of_month; ?>';
        var date = '<?php echo $date;?>';
        var effective_from = dates.convert_to_sql(date);
        weather_data.refresh_weather_data_grid();
        weather_data.weather_data_filter_form.setItemValue("effetive_date", effective_from);
        weather_data.weather_data_filter_form.setItemValue("tenor_from", first_day_of_month);
        weather_data.weather_data_filter_form.setItemValue("tenor_to", first_day_of_month);
        
        if (hyperlink_weather_data_id != '') {
            weather_data.refresh_series_values_grid();
        }
    })
    
    /*
     * tweather_data.dbclick_weather_data    [Row double click function]
     */
    weather_data.dbclick_weather_data = function(rId,cInd) {
        var tree_level = weather_data.weather_data_grid.getLevel(rId);
        if (tree_level == 0 && has_rights_weather_data_ui) {
            open_weather_data_ui('');
        }
    }
    
    /*
     * weather_data.row_select    [Row select function]
     */
    weather_data.row_select = function(id,ind) {
        if (weather_data.weather_data_grid.getLevel(id) == 0) {
            //weather_data.weather_data_menu.setItemDisabled("delete");
        } else {
            var effective_applicable = weather_data.weather_data_grid.cells(id, weather_data.weather_data_grid.getColIndexById('effective_date_applicable')).getValue();
            var maturity_applicable = weather_data.weather_data_grid.cells(id, weather_data.weather_data_grid.getColIndexById('maturity_applicable')).getValue();
            
            if (effective_applicable == 'n') {
                weather_data.weather_data_filter_form.disableItem('effetive_date');
                weather_data.weather_data_filter_form.disableItem('show_effective');
            } else {
                weather_data.weather_data_filter_form.enableItem('effetive_date');
                weather_data.weather_data_filter_form.enableItem('show_effective');
            }
            
            if (maturity_applicable == 'n') {
                weather_data.weather_data_filter_form.disableItem('tenor_from');
                weather_data.weather_data_filter_form.disableItem('tenor_to');
            } else {
                weather_data.weather_data_filter_form.enableItem('tenor_from');
                weather_data.weather_data_filter_form.enableItem('tenor_to');
            }
        }
    }
    
    /*
     * weather_data.refresh_weather_data_grid    [Refresh the left side grid]
     */
    weather_data.refresh_weather_data_grid = function() {
        var series_type = '<?php echo $series_type; ?>';
        var param = {
            "flag": "g",
            "action":"spa_weather_data",
            "grid_type":"tg",
            "grouping_column":"series_type,weather_data_name",
            "series_type":series_type
        };

        param = $.param(param);
        var param_url = js_data_collector_url + "&" + param;
        weather_data.weather_data_grid.clearAndLoad(param_url, function() {
            weather_data.weather_data_grid.loadOpenStates();
            //if (series_type != '') {
                weather_data.weather_data_grid.expandAll();
            //}
            
            system_id = '<?php echo $weather_data_id; ?>';
            if (system_id != '' && system_id != undefined) {
                var primary_value = weather_data.weather_data_grid.findCell(system_id, 1, true, true);
                weather_data.weather_data_grid.filterBy(1,system_id);
                var r_id = primary_value.toString().substring(0, primary_value.toString().indexOf(","));
                weather_data.weather_data_grid.selectRowById(r_id,false,true,true);
                weather_data.refresh_series_values_grid();
            }
        });
        //weather_data.weather_data_menu.setItemDisabled("delete");
        weather_data.weather_data_layout.cells('c').detachObject();
        weather_data.series_values_menu.setItemDisabled("add");
        weather_data.series_values_menu.setItemDisabled("delete");
        weather_data.series_values_menu.setItemDisabled("save");
        weather_data.series_values_menu.setItemDisabled("pdf");
        weather_data.series_values_menu.setItemDisabled("excel");
    }
    
    /*
     * weather_data.weather_data_menu_click    [Menu click function for time series]
     */
    weather_data.weather_data_menu_click = function(id, zoneId, cas) {
        switch(id) {
            case 'add':
                open_weather_data_ui('');
                break;
            case 'delete':
                delete_weather_data();
                break;
            case 'excel':
                weather_data.weather_data_grid.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                break;
            case 'pdf':
                weather_data.weather_data_grid.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                break;    
            case 'expand_collapse':
                if (expand_state == 0) {
                    weather_data.weather_data_grid.expandAll();
                    expand_state = 1;
                } else {
                    weather_data.weather_data_grid.collapseAll();
                    expand_state = 0;
                }
                break;
        }
    }
    
    /*
     * open_weather_data_ui    [open the time series definition window for insert and update]
     */
    open_weather_data_ui = function(weather_data_definition_id) {
        var series_type = '<?php echo $series_type; ?>';
        weather_data.weather_data_grid.saveOpenStates();
        weather_data_window = new dhtmlXWindows();
        var win = weather_data_window.createWindow('w1', 0, 0, 800, 500);
        win.setText("Add Definition");
        win.centerOnScreen();
        win.setModal(true);
        win.attachURL('weather.data.ui.php?flag=i&weather_data_definition_id=' + weather_data_definition_id + '&series_type=' + series_type + '&save_permission=' + has_rights_weather_data_ui);
        win.attachEvent("onClose", function(win){
            weather_data.refresh_weather_data_grid();
            return true;
        });
    }
    
    
    /*
     * weather_data.series_values_menu_click    [Menu Click function of series values]
     */
    weather_data.series_values_menu_click = function(id, zoneId, cas) {
        switch(id) {
            case 'refresh':
                weather_data.refresh_series_values_grid();
                break;
            case 'save':
                if (delete_flag == 1) {
                    del_msg =  "Some data has been deleted from Series Values grid. Are you sure you want to save?";
                    dhtmlx.message({
                        type: "confirm-warning",
                        title: "Warning",
                        ok: "Confirm",
                        text: del_msg,
                        callback: function(result) {
                            if (result)
                                weather_data.save_series_values();                
                        }
                    });
                } else {
                    weather_data.save_series_values();
                }
                break;
            case "add":
                var new_id = (new Date()).valueOf();
                weather_data.series_values_grid.addRow(new_id,'');
                weather_data.series_values_grid.forEachCell(new_id,function(cellObj,ind){
                    weather_data.series_values_grid.validateCell(new_id,ind);
                });
                break;
            case "delete":
                var row_id = weather_data.series_values_grid.getSelectedRowId();
                var row_id_array = row_id.split(",");
                for (count = 0; count < row_id_array.length; count++) {
                    if (weather_data.series_values_grid.cells(row_id_array[count],0).getValue() != '') {
                        var column_id = weather_data.series_values_grid.getColumnId(0);
                        var column_val = weather_data.series_values_grid.cells(row_id_array[count],0).getValue();
                        column_val = (column_id == 'time_series_data_id') ? column_val.replace(/[.]/gi,',') : column_val;
                        delete_xml += '<GridRow ' + column_id + '="' + column_val + '" />'; 
                        delete_flag = 1;
                    }
                    weather_data.series_values_grid.deleteRow(row_id_array[count]);
                }
                break;
            case 'excel':
                weather_data.series_values_grid.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                break;
            case 'pdf':
                weather_data.series_values_grid.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                break; 
            case 'batch':
                weather_data.series_values_batch();
                break;
            case 'pivot':
                var grid_obj = weather_data.series_values_grid;
                open_grid_pivot(grid_obj, 'series_values_grid', 1, pivot_exec_spa, 'Weather data');
                break;
        }
    }
    
    /*
     * weather_data.refresh_series_values_grid    
     */
    weather_data.refresh_series_values_grid = function() {
        if (hyperlink_weather_data_id != '') {
            var series_name = hyperlink_series_name;
            var weather_data_value_id = hyperlink_weather_data_id;
        } else {
            var selected_row = weather_data.weather_data_grid.getSelectedRowId();
        	if (selected_row == null) {
                show_messagebox('Please select a series.');
                return;
            }
            
            var tree_level =  weather_data.weather_data_grid.getLevel(selected_row);
            
            if (tree_level == 0) {
                show_messagebox('Please select a series.');
                return;
            }
            var series_name = weather_data.weather_data_grid.cells(selected_row, weather_data.weather_data_grid.getColIndexById('name')).getValue();            
            var weather_data_value_id = weather_data.weather_data_grid.cells(selected_row, weather_data.weather_data_grid.getColIndexById('weather_data_id')).getValue();
            
            //loading grid header
                var sp_string = "EXEC spa_weather_data 'm', @time_series_definition_id=" + weather_data_value_id;
                
                var data_for_post = { "sp_string": sp_string };  
                
                adiha_post_data('return_json', data_for_post, 's', 'e', 'weather_data.refresh_series_values_grid_ajax_callback', '', '');
        }
    }
        
    /*
     * weather_data.refresh_series_values_grid  ajax callback  [Create the series value grid and load data]
     */
    weather_data.refresh_series_values_grid_ajax_callback = function(result) { 
        var json_obj = $.parseJSON(result); 

        grid_properties_gbl = json_obj;        
        var header = json_obj[0].name_list;
        var column_align = json_obj[0].column_align;
        var column_ids = json_obj[0].column_id;
        var field_type = json_obj[0].field_type;
        var width = json_obj[0].width;
        var column_visibility = json_obj[0].column_visibility;
        var header_styles = json_obj[0].header_styles;
        var column_validator = json_obj[0].column_validator;
        var combo_column = json_obj[0].combo_columns;
        var array_combo_column = {};
        if (combo_column != null)
            array_combo_column = (combo_column.length > 0) ? combo_column.split(",") : combo_column;
        var combo_sql = json_obj[0].combo_sql;
        var array_combo_sql = {};
        if (combo_column != null)
            array_combo_sql = (combo_sql.length > 0) ? combo_sql.split(":") : combo_sql; 
        
        /******************start*******************/
       
        delete_xml = '';
        delete_flag = '';
        var effective_date = weather_data.weather_data_filter_form.getItemValue('effetive_date', true);
        var tenor_from = weather_data.weather_data_filter_form.getItemValue('tenor_from', true);
        var tenor_to = weather_data.weather_data_filter_form.getItemValue('tenor_to', true);
        
        if (hyperlink_term_start != '' && hyperlink_term_end != '') {
            tenor_from = hyperlink_term_start;
            tenor_to = hyperlink_term_end;
        }
        
        if (tenor_to == '') {
            tenor_to = tenor_from;
        }
        var curve_source = weather_data.weather_data_filter_form.getItemValue('curve_source');
        var show_effective_data = weather_data.weather_data_filter_form.isItemChecked('show_effective');
        if (show_effective_data == true) { show_effective_data = 'y'; } else { show_effective_data = 'n'; }
        var round_value = weather_data.weather_data_filter_form.getItemValue('round_value');
        
        if (hyperlink_weather_data_id != '') {
            var effective_date_applicable = hyperlink_e_applicable;
            var maturity_applicable = hyperlink_m_applicable;
            var granularity = hyperlink_granularity;
            var weather_data_value_id = hyperlink_weather_data_id;
        } else {
            var selected_row = weather_data.weather_data_grid.getSelectedRowId();
            var effective_date_applicable = json_obj[0].effective_date_applicable;
            var maturity_applicable = json_obj[0].maturity_applicable;
            var granularity = json_obj[0].granularity;
            var weather_data_value_id = weather_data.weather_data_grid.cells(selected_row, weather_data.weather_data_grid.getColIndexById('weather_data_id')).getValue();
        }
         
        if (show_effective_data == 'y' && effective_date == '') {
            show_messagebox('Please select Effective Date.');
            return;
        }
        
        
        /***************end**********************/
        
        weather_data.series_values_grid = weather_data.weather_data_layout.cells('c').attachGrid();
        weather_data.series_values_grid.setImagePath(js_php_path + "components/lib/adiha_dhtmlx/adiha_grid_3.0/adiha_dhtmlxGrid/codebase/imgs/");
        weather_data.series_values_grid.setHeader(get_locale_value(header,true), null, $.parseJSON(header_styles));
        weather_data.series_values_grid.setColumnIds(column_ids);
                
        //weather_data.series_values_grid.setDateFormat(client_date_format.replace("n", "m").replace("j", "d"));
        weather_data.series_values_grid.setDateFormat(client_date_format);
        weather_data.series_values_grid.setColTypes(field_type);
        weather_data.series_values_grid.setColumnsVisibility(column_visibility);
        weather_data.series_values_grid.setColAlign(column_align);
        weather_data.series_values_grid.setInitWidths(width);
        weather_data.series_values_grid.enableEditEvents(true,false,true);
        
        weather_data.series_values_grid.enableValidation(true);
        weather_data.series_values_grid.setColValidators(column_validator); 
        weather_data.series_values_grid.enableMultiselect(true);
        
        weather_data.series_values_grid.init();        
        weather_data.series_values_grid.setColumnHidden(0, true);// to hide id column 
        weather_data.series_values_grid.enableHeaderMenu();
        
        if( round_value && '' != round_value ){
            var rounding_array = field_type.split(",");
            rounding_array.forEach(function(type,i) {
                ( type == 'ed_no' ) ? rounding_array[i] = round_value : rounding_array[i] = '';
            });
           weather_data.series_values_grid.enableRounding(rounding_array.toString());
        }
        /***************start************/
        if (effective_date_applicable == 'n')
            weather_data.series_values_grid.setColumnHidden(1, true);
        if (maturity_applicable == 'y') {
            weather_data.series_values_grid.setColumnHidden(2, false);
            if (granularity == '15Min' || granularity == '30Min' || granularity == 'Hourly')
                weather_data.series_values_grid.setColumnHidden(3, false);
        }
        
        weather_data.series_values_grid.attachEvent("onValidationError",function(id,ind,value){
    		var message = "Invalid Data";
            weather_data.series_values_grid.cells(id,ind).setAttribute("validation", message);
    		return true;
        });
        weather_data.series_values_grid.attachEvent("onValidationCorrect",function(id,ind,value){
            weather_data.series_values_grid.cells(id,ind).setAttribute("validation", "");
        	return true;
        });
        
        if (has_rights_series_value_ui) {
            weather_data.series_values_menu.setItemEnabled('save');
            weather_data.series_values_menu.setItemEnabled('add');
        }
        
        weather_data.series_values_menu.setItemDisabled('delete');
        weather_data.series_values_menu.setItemEnabled('pdf');
        weather_data.series_values_menu.setItemEnabled('excel');
        weather_data.series_values_menu.setItemEnabled('pivot');
        
        
        weather_data.series_values_grid.attachEvent("onRowSelect", function(rId,cInd){
            if (has_rights_series_value_ui) {
                weather_data.series_values_menu.setItemEnabled('delete'); 
            }
        });
        //var definition_ids = weather_data.series_values_grid.getUserData("", "definition_ids");
        //alert(definition_ids);
        weather_data.series_values_grid.attachEvent("onEditCell", function(stage,rId,cInd,nValue,oValue){
            if (stage == 2 && cInd == 3 && nValue != '') {
                var time_arr = nValue.split(':');
                var hour, minutes;
                
                if (time_arr.length == 1) {
                    minutes = '00';
                    hour = '0' + time_arr[0];
                } else {
                    minutes = '0' + time_arr[1];
                    hour = '0' + time_arr[0];
                }
                
                hour = hour[hour.length-2] + hour[hour.length-1];
                minutes = minutes[minutes.length-2] + minutes[minutes.length-1];
                var new_hour =  hour + ':' + minutes;
                weather_data.series_values_grid.cells(rId,cInd).setValue(new_hour);
            } 
            return true;
        });
        
        weather_data.weather_data_layout.cells('c').progressOn();
        var series_type = '<?php echo $series_type; ?>';
        var param = {
            "flag": "s",
            "action":"spa_weather_data",
            "grid_type":"g",
            "effective_date":effective_date,
            "tenor_from":tenor_from,
            "tenor_to":tenor_to,
            "curve_source":curve_source,
            "show_effective_data":show_effective_data,
            "time_series_definition_id":weather_data_value_id,
            "round_value":round_value,
            "effective_date_applicable":effective_date_applicable,
            "maturity_applicable":maturity_applicable,
            "series_type":series_type
        };

        pivot_exec_spa = "EXEC spa_weather_data @flag='s', @effective_date='" +  effective_date 
                + "', @tenor_from='" +  tenor_from
                + "', @tenor_to='" +  tenor_to
                + "', @curve_source='" +  curve_source
                + "', @show_effective_data='" +  show_effective_data
                + "', @time_series_definition_id='" +  weather_data_value_id
                + "', @round_value='" +  round_value
                + "', @effective_date_applicable='" +  effective_date_applicable
                + "', @series_type='" +  series_type
                + "', @maturity_applicable='" +  maturity_applicable + "'";

        param = $.param(param);
        var param_url = js_data_collector_url + "&" + param;
            
            //for dropdown
        if (combo_column != null) {
            for (var i = 0; i < array_combo_column.length; i++) {
                var col_index = weather_data.series_values_grid.getColIndexById(array_combo_column[i]);
                var combo_obj = weather_data.series_values_grid.getColumnCombo(col_index);
                combo_obj.enableFilteringMode(true);
                var sql_stmt = array_combo_sql[i];
    
                var data = {"action":"spa_generic_mapping_header", "flag":"n", "combo_sql_stmt":sql_stmt, "call_from":"grid"};
                
                data = $.param(data);
                var url = js_dropdown_connector_url + '&' + data;
                if (i == array_combo_column.length - 1) {
                    combo_obj.load(url,function() {
                        weather_data.series_values_grid.clearAndLoad(param_url, function() {
                            weather_data.weather_data_layout.cells('c').progressOff();
                        });
                    });
                } else {
                    combo_obj.load(url);
                }
            }
        } else {        
            weather_data.series_values_grid.clearAndLoad(param_url, function() {
                weather_data.weather_data_layout.cells('c').progressOff();
            });  
            
        }
        /*****************end**********/
    }
    
    /*
     * weather_data.save_series_values    [Save the series values]
     */
    weather_data.save_series_values = function() {        
        weather_data.series_values_grid.clearSelection();
        var status = true;
        for (var i = 0; i < weather_data.series_values_grid.getRowsNum(); i++){
 			var row_id = weather_data.series_values_grid.getRowId(i);
 			for (var j = 0; j < weather_data.series_values_grid.getColumnsNum(); j++){ 
 				var is_hidden = weather_data.series_values_grid.isColumnHidden(j);
                
                if (!is_hidden) {
                    var validation_message = weather_data.series_values_grid.cells(row_id,j).getAttribute("validation");                                        
     				if(validation_message != "" && validation_message != undefined){
     					var column_text = weather_data.series_values_grid.getColLabel(j);
    					error_message = "Data Error in <b>Series Values</b> grid. Please check the data in column <b>"+column_text+"</b> and resave.";
    					dhtmlx.alert({title:"Alert",type:"alert",text: error_message});
     					status = false; 
                        break;
     				}
                    /***combo validation*****/
                    if(weather_data.series_values_grid.getColType(j) == 'combo') {
                        
                        if(weather_data.series_values_grid.cells(row_id,j).getValue() != '') {
                            var dhxCombo = weather_data.series_values_grid.getColumnCombo(j);
                            var selected_option = dhxCombo.getOption(weather_data.series_values_grid.cells(row_id,j).getValue());
                            
                            if(selected_option == null) {
                                var column_text = weather_data.series_values_grid.getColLabel(j);
                                
                                error_message = "Data Error in <b>Series Values</b> grid. Please check the data in column <b>" + column_text + "</b> and resave.";
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
        
        var selected_row = weather_data.weather_data_grid.getSelectedRowId();
        var weather_data_value_id = weather_data.weather_data_grid.cells(selected_row, weather_data.weather_data_grid.getColIndexById('weather_data_id')).getValue();
        var curve_source = weather_data.weather_data_filter_form.getItemValue('curve_source');
        var effective_date_empty = 0;
        var maturity_empty = 0;
        var hour_empty = 0;
        var curve_value_float = 0;
        
        var definition_ids = grid_properties_gbl[0].definition_ids;
        definition_ids = definition_ids.split(',');
        
        var grid_xml = '<Root><Grid>';
        var changed_rows = weather_data.series_values_grid.getChangedRows(true);
        if(changed_rows != '') {
            changed_rows = changed_rows.split(',');
            for (i = 0; i < changed_rows.length; i++) {
                /*****row level 1*****/
                for (z = 0; z < definition_ids.length; z++) {
                    var definition_id = definition_ids[z].split(':')[0];
                    var definition_val = definition_ids[z].split(':')[1];
                    
                    /****level 2 END*******/
                    grid_xml += '<GridRow ';
    
                    for (j = 0; j < weather_data.series_values_grid.getColumnsNum(); j++) {
                        if (weather_data.series_values_grid.getColumnId(j) == 'hour') {
                            var hour = weather_data.series_values_grid.cells(changed_rows[i],j).getValue();
                            if (hour != '') {
                                var hour_arr = hour.split(':');
                                var minutes = parseInt(hour_arr[0] * 60) + parseInt(hour_arr[1]);
                            } else {
                                hour_empty = 1;
                                var minutes = 0;
                            }
                            grid_xml += ' ' + weather_data.series_values_grid.getColumnId(j) + '="' + minutes + '"';    
                        } else {
                            var colm_id = weather_data.series_values_grid.getColumnId(j);
                            var colm_val = weather_data.series_values_grid.cells(changed_rows[i],j).getValue();
                            if (colm_id == definition_val) {
                                var curve_val = weather_data.series_values_grid.cells(changed_rows[i],j).getValue();
                                if (curve_val != '') {
                                    if (curve_val != parseFloat(curve_val)) {
                                        curve_value_float = 1;   
                                    }
                                }
                                colm_id = 'curve_value';
                                
                            } else if (colm_id == 'time_series_data_id' ) {
                                colm_val = colm_val.replace(/[.]/gi, ',');
                                if (colm_val != '') {
                                    colm_val = colm_val.split(',');
                                    if (colm_val[z] == undefined) {
                                        colm_val = 0;
                                    } else {
                                        colm_val = colm_val[z];
                                    }
                                }                                
                            } else {
                                if (weather_data.series_values_grid.cells(changed_rows[i],j).getValue() == '') {
                                    if (colm_id == 'effective_from') {
                                        effective_date_empty = 1;
                                    } else if (colm_id == 'date') {
                                        maturity_empty = 1;
                                    }
                                }
                            }
                            
                            colm_id = ($.isNumeric(colm_id)) ? 'numeric_col_name_' + colm_id : colm_id;
                            grid_xml += ' ' + colm_id + '="' + colm_val + '"';    
                        }
                    }
    
                    grid_xml += ' time_series_definition_id="' + definition_id + '"';
                    grid_xml += ' time_series_group="' + weather_data_value_id + '"';
                    grid_xml += ' curve_source="' + curve_source + '"';
                    grid_xml += ' />'
                    /****level 2 END*******/
                }
                
                /*****row level 1 END*****/
            }
        } else {
            if (delete_xml == '') {
                show_messagebox('No change in the grid.');
                return;
            }
        }
        grid_xml += '</Grid><GridDelete>';
       
        if (delete_xml != '') {
            grid_xml += delete_xml;
        }
        
        grid_xml += '</GridDelete></Root>';
        if (curve_value_float == 1) {
            var curve_value_header = weather_data.weather_data_grid.cells(selected_row, weather_data.weather_data_grid.getColIndexById('name')).getValue();
            
            dhtmlx.alert({
                title:"Alert",
                type:"alert",
                text:"Data Error in <strong>Series Values</strong> grid.Please check the data in column <strong>" + curve_value_header + "</strong> and resave"
            });
            return;
        }
        
        
        var effective_date_applicable = grid_properties_gbl[0].effective_date_applicable;
        var maturity_applicable = grid_properties_gbl[0].maturity_applicable;
        if (effective_date_applicable == 'y' && effective_date_empty == 1) {
            dhtmlx.alert({
                title:"Alert",
                type:"alert",
                text:"Data Error in <strong>Series Values</strong> grid.Please check the data in column <strong>Effective Date</strong> and resave"
            });
            return;
        }
        
        if (maturity_applicable == 'y' && maturity_empty == 1) {
            dhtmlx.alert({
                title:"Alert",
                type:"alert",
                text:"Data Error in <strong>Series Values</strong> grid.Please check the data in column <strong>Date</strong> and resave"
            });
            return;
        }
        
        var granularity = grid_properties_gbl[0].granularity;
        if (maturity_applicable == 'y' && hour_empty == 1 && (granularity == '15Min' || granularity == '30Min' || granularity == 'Hourly')) {
            dhtmlx.alert({
                title:"Alert",
                type:"alert",
                text:"Data Error in <strong>Series Values</strong> grid.Please check the data in column <strong>Hour</strong> and resave"
            });
            return;
        }

        var data = {
                        "action": "spa_weather_data",
                        "flag": "t",
                        "time_series_definition_id": weather_data_value_id,
                        "xml": grid_xml
                    };
        adiha_post_data('return_json', data, '', '', 'weather_data.refresh_series_values_grid_callback', '');
    }
    
    weather_data.refresh_series_values_grid_callback = function(result) {
        var return_data = JSON.parse(result);
        var status = return_data[0].status;
        
        if (status == 'Success') {
            dhtmlx.message({
                text:return_data[0].message,
                expire:1000
            });
            
            weather_data.refresh_series_values_grid();
        } else if (status == 'Error') {
            dhtmlx.message({
                title:"Alert",
                type:"alert",
                text:return_data[0].message
            }); 
        }
    }
    
    /*
     * weather_data.series_values_batch    [Batch function]
     */
    weather_data.series_values_batch = function() {
        var effective_date = weather_data.weather_data_filter_form.getItemValue('effetive_date', true);
        var tenor_from = weather_data.weather_data_filter_form.getItemValue('tenor_from', true);
        var tenor_to = weather_data.weather_data_filter_form.getItemValue('tenor_to', true);
        var curve_source = weather_data.weather_data_filter_form.getItemValue('curve_source');
        var show_effective_data = weather_data.weather_data_filter_form.isItemChecked('show_effective');
        if (show_effective_data == true) { show_effective_data = 'y'; } else { show_effective_data = 'n'; }
        var round_value = weather_data.weather_data_filter_form.getItemValue('round_value');
        
        var selected_row = weather_data.weather_data_grid.getSelectedRowId();
        var tree_level =  weather_data.weather_data_grid.getLevel(selected_row);
 
        if (selected_row == null || tree_level == 0) {
            show_messagebox('Please select a series.');
            return;
        }
        
        if (show_effective_data == 'y' && effective_date == '') {
            show_messagebox('Please select Effective Date.');
            return;
        }             
       
        var effective_date_applicable = weather_data.weather_data_grid.cells(selected_row, weather_data.weather_data_grid.getColIndexById('effective_date_applicable')).getValue();
        var maturity_applicable = weather_data.weather_data_grid.cells(selected_row, weather_data.weather_data_grid.getColIndexById('maturity_applicable')).getValue();
        var granularity = weather_data.weather_data_grid.cells(selected_row, weather_data.weather_data_grid.getColIndexById('granulalrity')).getValue();
        var weather_data_definition_id = weather_data.weather_data_grid.cells(selected_row, weather_data.weather_data_grid.getColIndexById('weather_data_id')).getValue();                
        var series = '<?php echo $layout_header; ?>';        
        var series_type = '<?php echo $series_type; ?>';
        
        var exec_call = "EXEC spa_weather_data " 
                            + " @flag='s'"
                            + ", @effective_date=" + singleQuote(effective_date)
                            + ", @tenor_from=" + singleQuote(tenor_from)
                            + ", @tenor_to=" + singleQuote(tenor_to)
                            + ", @curve_source=" + singleQuote(curve_source)
                            + ", @show_effective_data=" + singleQuote(show_effective_data)
                            + ", @time_series_definition_id=" + singleQuote(weather_data_definition_id)
                            + ", @round_value=" + singleQuote(round_value)
                            + ", @effective_date_applicable=" + singleQuote(effective_date_applicable)
                            + ", @maturity_applicable=" + singleQuote(maturity_applicable)
                            + ", @granularity=" + singleQuote(granularity)
                            + ", @report_name=" + singleQuote(series)
                            + ", @for_batch='y'"
                            + ", @series_type=" + series_type
        
        var param = 'gen_as_of_date=1&batch_type=c'; 
        
        if (effective_date != '') {
            param += '&as_of_date=' + effective_date;
        }
        adiha_run_batch_process(exec_call, param, series);
    }
       
</script>