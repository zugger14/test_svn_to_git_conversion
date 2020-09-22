<?php
/**
* Setup time series screen
* @copyright Pioneer Solutions
*/
?>
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
    $function_id = get_sanitized_value($_GET["function_parameter"] ?? '10106100');
    $time_series_id = get_sanitized_value($_GET["time_series_id"] ?? '');
    $term_start = get_sanitized_value($_GET["term_start"] ?? '');
    $term_end = get_sanitized_value($_GET["term_end"] ?? '');

    $exec_sql = "EXEC spa_time_series @flag='f', @function_id='" . $function_id . "'";

    $return_arr = readXMLURL($exec_sql);


    $series_type = $return_arr[0][0] ?? '';
    $rights_time_series = $function_id;
    $rights_time_series_ui = 10106110;
    $rights_time_series_delete = 10106111;
    $rights_series_value_ui = 10106116;
	$rights_value_series = 10106115;
	$layout_header = $return_arr[0][4] ?? '';

    $hyperlink_e_applicable='';
    $hyperlink_m_applicable='';
    $hyperlink_granularity='';
    $hyperlink_series_name='';

    if ($time_series_id != '') {
        $exec_sql = "EXEC ('SELECT effective_date_applicable, maturity_applicable, sdv.code [granulalrity], time_series_name 
						FROM time_series_definition tsd
						left join static_data_value sdv on tsd.granulalrity = sdv.value_id
						WHERE time_series_definition_id = " . $time_series_id . "')";
        $return_arr = readXMLURL($exec_sql);  
        $hyperlink_e_applicable = $return_arr[0][0];
        $hyperlink_m_applicable = $return_arr[0][1];
        $hyperlink_granularity = $return_arr[0][2];
        $hyperlink_series_name = $return_arr[0][3];
    }
    
    list (
        $has_rights_time_series,
        $has_rights_time_series_ui,
        $has_rights_time_series_delete,
        $has_rights_series_value_ui,
		$has_rights_value_series
    ) = build_security_rights(
        $rights_time_series,
        $rights_time_series_ui,
        $rights_time_series_delete,
        $rights_series_value_ui,
		$rights_value_series
    );
    
    $first_day_of_month = date('Y-m-01');
    $date =date('Y-m-d');
    $json = '[
                {
                    id:             "a",
                    text:           " '.$layout_header.'  ",
                    header:         true,
                    collapse:       false,
                    width:          450,
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
    
    $namespace = 'time_series';
    $time_series_layout_obj = new AdihaLayout();
    echo $time_series_layout_obj->init_layout('time_series_layout', '', '3L', $json, $namespace);
    echo $time_series_layout_obj->attach_event('', 'onDock', 'time_series.on_dock_event');
    echo $time_series_layout_obj->attach_event('', 'onUnDock', 'time_series.on_undock_event');
    
    $menu_name = 'time_series_menu';
    $menu_json = '[
                    {id:"edit", text:"Edit", img:"edit.gif", imgdis:"edit_dis.gif", items:[
                        {id:"add", text:"Add", img:"add.gif", imgdis:"add_dis.gif", enabled: "'.$has_rights_time_series_ui.'"},
                        {id:"delete", text:"Delete", img:"delete.gif", imgdis:"delete_dis.gif",enabled:0}
                    ]},
                    {id:"t2", text:"Export", img:"export.gif", imgdis:"export_dis.gif", items:[    
                        {id:"excel", text:"Excel", img:"excel.gif"},
                        {id:"pdf", text:"PDF", img:"pdf.gif"}
                    ]},
                    {id:"expand_collapse", text:"Expand/Collapse", img:"exp_col.gif", imgdis:"exp_col_dis.gif"}
                ]';

    echo $time_series_layout_obj->attach_menu_layout_cell($menu_name, 'a', $menu_json, $namespace.'.time_series_menu_click');

    $grid_name = 'time_series';
    echo $time_series_layout_obj->attach_grid_cell('time_series_grid', 'a');
    $time_series_grid = new GridTable($grid_name);
    echo $time_series_grid->init_grid_table('time_series_grid', $namespace);
    echo $time_series_grid->set_search_filter(true); 
    echo $time_series_grid->return_init();
    echo $time_series_grid->enable_multi_select(true);
    echo $time_series_grid->attach_event('', 'onRowDblClicked', $namespace.'.dbclick_time_series');
    echo $time_series_grid->attach_event('', 'onRowSelect', $namespace.'.row_select');
    
    $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10106100', @template_name='setup time series'";
    $return_value1 = readXMLURL($xml_file);
    $form_json = $return_value1[0][2];
    echo $time_series_layout_obj->attach_form('time_series_filter_form', 'b');
    $time_series_filter_form = new AdihaForm();
    echo $time_series_filter_form->init_by_attach('time_series_filter_form', $namespace);
    echo $time_series_filter_form->load_form($form_json);

    $menu_name = 'series_values_menu';
    $menu_json = '[ 
                    {id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif"},
                    {id:"save", text:"Save", img:"save.gif", imgdis:"save_dis.gif", enabled:0},
                    {id:"edit", text:"Edit", img:"edit.gif", imgdis:"edit_dis.gif", items:[
                        {id:"add", text:"Add", img:"add.gif", imgdis:"add_dis.gif", enabled: "'.$has_rights_series_value_ui.'"},
                        {id:"delete", text:"Delete", img:"delete.gif", imgdis:"delete_dis.gif",enabled:0}
                    ]},
                    {id:"export", text:"Export", img:"export.gif", imgdis:"export_dis.gif", items:[    
                        {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", enabled:0},
                        {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", enabled:0},
                        {id:"batch", text:"Batch", img:"batch.gif", imgdis:"batch_dis.gif"}
                    ]},
                    {id:"pivot", text:"Pivot", img:"pivot.gif", imgdis:"pivot_dis.gif",enabled:"false"}
                ]';

    echo $time_series_layout_obj->attach_menu_layout_cell($menu_name, 'c', $menu_json, $namespace.'.series_values_menu_click');

    echo $time_series_layout_obj->close_layout();
    ?>

</body>
</html>

<script>
    var expand_state = 0;
    var delete_xml = '';
    var delete_flag = '';
    var client_date_format = '<?php echo $date_format; ?>';
    
    var hyperlink_time_series_id = '<?php echo $time_series_id; ?>';
    var hyperlink_term_start = '<?php echo $term_start; ?>';
    var hyperlink_term_end = '<?php echo $term_end; ?>';
    var hyperlink_e_applicable = '<?php echo $hyperlink_e_applicable; ?>';
    var hyperlink_m_applicable = '<?php echo $hyperlink_m_applicable; ?>';
    var hyperlink_granularity = '<?php echo $hyperlink_granularity; ?>'
    var hyperlink_series_name = '<?php echo $hyperlink_series_name; ?>'
    
    var has_rights_time_series_ui = <?php echo (($has_rights_time_series_ui) ? $has_rights_time_series_ui : '0'); ?>;
    var has_rights_time_series_delete = <?php echo (($has_rights_time_series_delete) ? $has_rights_time_series_delete : '0'); ?>;
    var has_rights_series_value_ui = <?php echo (($has_rights_series_value_ui) ? $has_rights_series_value_ui : '0'); ?>;
	var has_rights_value_series =  <?php echo (($has_rights_value_series) ? $has_rights_value_series : '0'); ?>;
    
    $(function() {
        var first_day_of_month = '<?php echo $first_day_of_month; ?>';
        var date = '<?php echo $date;?>';
        var effective_from = dates.convert_to_sql(date);
        time_series.refresh_time_series_grid();
        time_series.time_series_filter_form.setItemValue("effetive_date", effective_from);
        time_series.time_series_filter_form.setItemValue("tenor_from", first_day_of_month);
        time_series.time_series_filter_form.setItemValue("tenor_to", first_day_of_month);
        
        if (hyperlink_time_series_id != '') {
            time_series.refresh_series_values_grid();
        }
    })

    
    /*
     * ttime_series.dbclick_time_series    [Row double click function]
     */
    time_series.dbclick_time_series = function(rId,cInd) {
        var tree_level = time_series.time_series_grid.getLevel(rId);
        if (tree_level == 1) {
            var time_series_definition_id = time_series.time_series_grid.cells(rId, time_series.time_series_grid.getColIndexById('time_series_definition_id')).getValue();
            open_time_series_ui(time_series_definition_id);
        } else {
            var selected_row = time_series.time_series_grid.getSelectedRowId();
            var state = time_series.time_series_grid.getOpenState(selected_row);
            
            if (state)
                time_series.time_series_grid.closeItem(selected_row);
            else
                time_series.time_series_grid.openItem(selected_row);
        }
    }
    
    /*
     * time_series.row_select    [Row select function]
     */
    time_series.row_select = function(id,ind) {
        if (time_series.time_series_grid.getLevel(id) == 0) {
            time_series.time_series_menu.setItemDisabled("delete");
        } else {
            if (has_rights_time_series_delete) {
                time_series.time_series_menu.setItemEnabled("delete");
            }
            var effective_applicable = time_series.time_series_grid.cells(id, time_series.time_series_grid.getColIndexById('effective_date_applicable')).getValue();
            var maturity_applicable = time_series.time_series_grid.cells(id, time_series.time_series_grid.getColIndexById('maturity_applicable')).getValue();
            
            if (effective_applicable == 'n') {
                time_series.time_series_filter_form.disableItem('effetive_date');
                time_series.time_series_filter_form.disableItem('show_effective');
            } else {
                time_series.time_series_filter_form.enableItem('effetive_date');
                time_series.time_series_filter_form.enableItem('show_effective');
            }
            
            if (maturity_applicable == 'n') {
                time_series.time_series_filter_form.disableItem('tenor_from');
                time_series.time_series_filter_form.disableItem('tenor_to');
            } else {
                time_series.time_series_filter_form.enableItem('tenor_from');
                time_series.time_series_filter_form.enableItem('tenor_to');
            }
        }
    }
    
    /*
     * time_series.refresh_time_series_grid    [Refresh the left side grid]
     */
    time_series.refresh_time_series_grid = function() {
        var series_type = '<?php echo $series_type; ?>';
        
        var param = {
            "flag": "g",
            "action":"spa_time_series",
            "grid_type":"tg",
            "grouping_column":"series_type,time_series_name",
            "series_type":series_type
        };

        param = $.param(param);
        var param_url = js_data_collector_url + "&" + param;
        time_series.time_series_grid.clearAndLoad(param_url, function() {
            time_series.time_series_grid.loadOpenStates();
            //if (series_type != '') {
                time_series.time_series_grid.expandAll();
                time_series.time_series_grid.filterByAll();
            //}
            
            system_id = '<?php echo $time_series_id; ?>';
            if (system_id != '' && system_id != undefined) {
                var primary_value = time_series.time_series_grid.findCell(system_id, 1, true, true);
                time_series.time_series_grid.filterBy(1,system_id);
                var r_id = primary_value.toString().substring(0, primary_value.toString().indexOf(","));
                time_series.time_series_grid.selectRowById(r_id,false,true,true);
                time_series.refresh_series_values_grid();
            }
        });
        time_series.time_series_menu.setItemDisabled("delete");
        time_series.time_series_layout.cells('c').detachObject();
        time_series.series_values_menu.setItemDisabled("add");
        time_series.series_values_menu.setItemDisabled("delete");
        time_series.series_values_menu.setItemDisabled("save");
        time_series.series_values_menu.setItemDisabled("pdf");
        time_series.series_values_menu.setItemDisabled("excel");
    }
    
    /*
     * time_series.time_series_menu_click    [Menu click function for time series]
     */
    time_series.time_series_menu_click = function(id, zoneId, cas) {
        switch(id) {
            case 'add':
                open_time_series_ui('');
                break;
            case 'delete':
                delete_time_series();
                break;
            case 'excel':
                time_series.time_series_grid.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                break;
            case 'pdf':
                time_series.time_series_grid.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                break;    
            case 'expand_collapse':
                if (expand_state == 0) {
                    time_series.time_series_grid.expandAll();
                    expand_state = 1;
                } else {
                    time_series.time_series_grid.collapseAll();
                    expand_state = 0;
                }
                break;
        }
    }
    
    /*
     * open_time_series_ui    [open the time series definition window for insert and update]
     */
    open_time_series_ui = function(time_series_definition_id) {
        var series_type = '<?php echo $series_type; ?>';
        time_series.time_series_grid.saveOpenStates();
        time_series_window = new dhtmlXWindows();
        var win = time_series_window.createWindow('w1', 0, 0, 540, 440);
        win.setText("Add Definition");
        win.centerOnScreen();
        win.setModal(true);
        win.attachURL('time.series.ui.php?flag=i&time_series_definition_id=' + time_series_definition_id + '&series_type=' + series_type + '&save_permission=' + has_rights_time_series_ui);
        win.attachEvent("onClose", function(win){
            time_series.refresh_time_series_grid();
            return true;
        });
    }
    
    /*
     * delete_time_series    [Delete the time series definition]
     */
    delete_time_series = function() {
        time_series.time_series_grid.saveOpenStates();
        var selected_id = time_series.time_series_grid.getSelectedRowId();
        var count = selected_id.indexOf(",") > -1 ? selected_id.split(",").length : 1;
        selected_id = selected_id.indexOf(",") > -1 ? selected_id.split(",") : [selected_id];
        var time_series_definition_id = '';

        for ( var i = 1; i <= count; i++) {
            time_series_definition_id += time_series.time_series_grid.cells(selected_id[i-1],time_series.time_series_grid.getColIndexById('time_series_definition_id')).getValue() + ',';
        }

        time_series_definition_id = time_series_definition_id.substring(0, time_series_definition_id.length-1);

        data = {
                "action": "spa_time_series",
                "flag": "d",
                "time_series_definition_id": time_series_definition_id
            };

        adiha_post_data('confirm', data, '', '', 'time_series.refresh_time_series_grid', '');
    }
    
    /*
     * time_series.series_values_menu_click    [Menu Click function of series values]
     */
    time_series.series_values_menu_click = function(id, zoneId, cas) {
		if (has_rights_series_value_ui) {
			time_series.series_values_menu.setItemEnabled("add");
			time_series.series_values_menu.setItemEnabled("delete");
			time_series.series_values_menu.setItemEnabled("save");
		}
		
		switch(id) {
            case 'refresh':
                time_series.refresh_series_values_grid();
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
                                time_series.save_series_values();                
                        }
                    });
                } else {
                    time_series.save_series_values();
                }
                break;
            case "add":
                var new_id = (new Date()).valueOf();
                time_series.series_values_grid.addRow(new_id,'');
                time_series.series_values_grid.forEachCell(new_id,function(cellObj,ind){
                    time_series.series_values_grid.validateCell(new_id,ind);
                });
                break;
            case "delete":
                var row_id = time_series.series_values_grid.getSelectedRowId();
                var row_id_array = row_id.split(",");
                for (count = 0; count < row_id_array.length; count++) {
                    if (time_series.series_values_grid.cells(row_id_array[count],0).getValue() != '') {
                        delete_xml += '<GridRow ' + time_series.series_values_grid.getColumnId(0) + '="' + time_series.series_values_grid.cells(row_id_array[count],0).getValue() + '" />'; 
                        delete_flag = 1;
                    }
                    time_series.series_values_grid.deleteRow(row_id_array[count]);
                }
                break;
            case 'excel':
                time_series.series_values_grid.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                break;
            case 'pdf':
                time_series.series_values_grid.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                break; 
            case 'batch':
                time_series.series_values_batch();
                break;
            case 'pivot':
                var grid_obj = time_series.series_values_grid;
                open_grid_pivot(grid_obj, 'time_series_grid', 1, pivot_exec_spa, 'Time Series');
                break;
        }
    }
    
    /*
     * time_series.refresh_series_values_grid    [Create the series value grid and load data]
     */
    time_series.refresh_series_values_grid = function() {
        if (hyperlink_time_series_id != '') {
            var series_name = hyperlink_series_name;
            var time_series_definition_id = hyperlink_time_series_id;
        } else {
            var selected_row = time_series.time_series_grid.getSelectedRowId();
        	if (selected_row == null) {
                show_messagebox('Please select a series.');
                return;
            }
            var tree_level =  time_series.time_series_grid.getLevel(selected_row);
            if (tree_level == 0) {
                show_messagebox('Please select a series.');
                return;
            }
            var series_name = time_series.time_series_grid.cells(selected_row, time_series.time_series_grid.getColIndexById('name')).getValue();
            var time_series_definition_id = time_series.time_series_grid.cells(selected_row, time_series.time_series_grid.getColIndexById('time_series_definition_id')).getValue();
        }
        
        time_series.series_values_grid = time_series.time_series_layout.cells('c').attachGrid();
        time_series.series_values_grid.setImagePath(js_php_path + "components/lib/adiha_dhtmlx/adiha_grid_3.0/adiha_dhtmlxGrid/codebase/imgs/");
        
        var header = "Time Series Data ID, Effective From, Date, Hour," + series_name + ",DST";
        var header_align = jQuery.parseJSON('["text-align:center;","text-align:center;","text-align:center;","text-align:center;","text-align:center;","text-align:center;"]');
        time_series.series_values_grid.setHeader(get_locale_value(header,true), null, header_align);
        time_series.series_values_grid.setColumnIds("time_series_data_id,effective_from,date,hour,curve_value,is_dst");
        time_series.series_values_grid.setColSorting('int,date,date,int,int,str');
        
        var data = {
                        "action": "spa_time_series",
                        "flag": "b",
                        "time_series_definition_id": time_series_definition_id
                    };

        adiha_post_data('return_array', data, '', '', 'series_value_grid_create_callback', '');
    }
    
    function series_value_grid_create_callback(result) {
        delete_xml = '';
        delete_flag = '';
        var effective_date = time_series.time_series_filter_form.getItemValue('effetive_date', true);
        var tenor_from = time_series.time_series_filter_form.getItemValue('tenor_from', true);
        var tenor_to = time_series.time_series_filter_form.getItemValue('tenor_to', true);
        
        if (tenor_to == '') {
            tenor_to = tenor_from;
        }
        var curve_source = time_series.time_series_filter_form.getItemValue('curve_source');
        var show_effective_data = time_series.time_series_filter_form.isItemChecked('show_effective');
        if (show_effective_data == true) { show_effective_data = 'y'; } else { show_effective_data = 'n'; }
        var round_value = time_series.time_series_filter_form.getItemValue('round_value');
        
        if (hyperlink_time_series_id != '') {
            var effective_date_applicable = hyperlink_e_applicable;
            var maturity_applicable = hyperlink_m_applicable;
            var granularity = hyperlink_granularity;
            var time_series_definition_id = hyperlink_time_series_id;
        } else {
            var selected_row = time_series.time_series_grid.getSelectedRowId();
            var effective_date_applicable = time_series.time_series_grid.cells(selected_row, time_series.time_series_grid.getColIndexById('effective_date_applicable')).getValue();
            var maturity_applicable = time_series.time_series_grid.cells(selected_row, time_series.time_series_grid.getColIndexById('maturity_applicable')).getValue();
            var granularity = time_series.time_series_grid.cells(selected_row, time_series.time_series_grid.getColIndexById('granularity')).getValue();
            var time_series_definition_id = time_series.time_series_grid.cells(selected_row, time_series.time_series_grid.getColIndexById('time_series_definition_id')).getValue();
        }
        
        if (show_effective_data == 'y' && effective_date == '') {
            show_messagebox('Please select Effective Date.');
            return;
        }

        var field_type = 'ed_no';
        if (result[0][0] != '') {
            var static_data_type_id = result[0][0];
            field_type = 'combo';
        }
        
        time_series.series_values_grid.setColTypes("ro,dhxCalendarA,dhxCalendarA,ed," + field_type + ",ed");
        time_series.series_values_grid.setColumnsVisibility("true,false,true,true,false,true");
        time_series.series_values_grid.setColAlign("right,left,left,left,right,left");
        time_series.series_values_grid.enableEditEvents(true,false,true);

        if( round_value && round_value != '' && field_type == 'ed_no'){
            var round_string = ',,,,'+round_value+',';
            time_series.series_values_grid.enableRounding(round_string);
        }
        
        if (effective_date_applicable == 'n')
            time_series.series_values_grid.setColumnHidden(1, true);
        if (maturity_applicable == 'y') {
            time_series.series_values_grid.setColumnHidden(2, false);
            if (granularity == '15Min' || granularity == '30Min' || granularity == 'Hourly')
                time_series.series_values_grid.setColumnHidden(3, false);
        }
        
        time_series.series_values_grid.setInitWidths('150,150,150,150,150,150');
        time_series.series_values_grid.enableValidation(true);
        time_series.series_values_grid.setColValidators("NotEmpty,NotEmpty,NotEmpty,NotEmpty,NotEmpty,ValidNumeric,"); 
        time_series.series_values_grid.enableMultiselect(true);
                        
        time_series.series_values_grid.attachEvent("onValidationError",function(id,ind,value){
    		var message = "Invalid Data";
            time_series.series_values_grid.cells(id,ind).setAttribute("validation", message);
    		return true;
        });
        time_series.series_values_grid.attachEvent("onValidationCorrect",function(id,ind,value){
            time_series.series_values_grid.cells(id,ind).setAttribute("validation", "");
        	return true;
        });
                        
        time_series.series_values_grid.init();
        //time_series.series_values_grid.setDateFormat(client_date_format.replace("n", "m").replace("j", "d"));
        time_series.series_values_grid.setDateFormat(client_date_format);
        
        if (has_rights_series_value_ui) {
            time_series.series_values_menu.setItemEnabled('save');
            time_series.series_values_menu.setItemEnabled('add');
        }
        
        time_series.series_values_menu.setItemDisabled('delete');
        time_series.series_values_menu.setItemEnabled('pdf');
        time_series.series_values_menu.setItemEnabled('excel');
        time_series.series_values_menu.setItemEnabled('pivot');
        
        time_series.series_values_grid.attachEvent("onRowSelect", function(rId,cInd){
		    if (has_rights_series_value_ui) {
				time_series.series_values_menu.setItemEnabled('delete'); 
            }
        });
			
        time_series.series_values_grid.attachEvent("onEditCell", function(stage,rId,cInd,nValue,oValue){
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
                time_series.series_values_grid.cells(rId,cInd).setValue(new_hour);
            } 
            return true;
        });
        time_series.time_series_layout.cells('c').progressOn();
		
		if(typeof(static_data_type_id) == "undefined") {
			static_data_type_id = 0;
		}
        var cm_param = {
                            "action": "[spa_generic_mapping_header]", 
                            "flag": "n",
                            "combo_sql_stmt": "EXEC spa_StaticDataValues @flag = 'h', @type_id = " + static_data_type_id,
                            "call_from": "grid"
                        };

        cm_param = $.param(cm_param);
        var url = js_dropdown_connector_url + '&' + cm_param;
		var combo_obj = time_series.series_values_grid.getColumnCombo(4);                
		combo_obj.load(url, function () {
					var param = {
						"flag": "s",
						"action":"spa_time_series",
						"grid_type":"g",
						"effective_date":effective_date,
						"tenor_from":tenor_from,
						"tenor_to":tenor_to,
						"curve_source":curve_source,
						"show_effective_data":show_effective_data,
						"time_series_definition_id":time_series_definition_id,
                        // "round_value":round_value,
						"effective_date_applicable":effective_date_applicable,
						"maturity_applicable":maturity_applicable
					};
					
					pivot_exec_spa = "EXEC spa_time_series @flag='s', @effective_date='" +  effective_date 
										+ "', @tenor_from='" +  tenor_from
										+ "', @tenor_to='" +  tenor_to
										+ "', @curve_source='" +  curve_source
										+ "', @show_effective_data='" +  show_effective_data
										+ "', @time_series_definition_id='" +  time_series_definition_id
										+ "', @round_value='" +  round_value
										+ "', @effective_date_applicable='" +  effective_date_applicable
										+ "', @maturity_applicable='" +  maturity_applicable + "'";
					
					param = $.param(param);					
					var param_url = js_data_collector_url + "&" + param;
					time_series.series_values_grid.clearAndLoad(param_url, function() {
						time_series.time_series_layout.cells('c').progressOff();
					});    
				});
    }
    
    /*
     * time_series.save_series_values    [Save the series values]
     */
    time_series.save_series_values = function() {
        time_series.series_values_grid.clearSelection();
        var status = true;
        for (var i = 0; i < time_series.series_values_grid.getRowsNum(); i++){
 			var row_id = time_series.series_values_grid.getRowId(i);
 			for (var j = 0; j < time_series.series_values_grid.getColumnsNum(); j++){ 
 				var is_hidden = time_series.series_values_grid.isColumnHidden(j);
                
                if (!is_hidden) {
                    var validation_message = time_series.series_values_grid.cells(row_id,j).getAttribute("validation");
     				if(validation_message != "" && validation_message != undefined){
     					var column_text = time_series.series_values_grid.getColLabel(j);
    					error_message = "Data Error in <b>Series Values</b> grid. Please check the data in column <b>"+column_text+"</b> and resave.";
    					dhtmlx.alert({title:"Alert",type:"alert",text: error_message});
     					status = false; 
                        break;
     				}
                }
            }
    		if(validation_message != "" && validation_message != undefined){ break;};
     	}
        
        if(!status) 
            return;                        
        var selected_row = time_series.time_series_grid.getSelectedRowId();
        var time_series_definition_id = time_series.time_series_grid.cells(selected_row, time_series.time_series_grid.getColIndexById('time_series_definition_id')).getValue();
        var curve_source = time_series.time_series_filter_form.getItemValue('curve_source');
        var effective_date_empty = 0;
        var maturity_empty = 0;
        var hour_empty = 0;
        var curve_value_float = 0;
        time_series.series_values_grid.setDateFormat(user_date_format, "%Y-%m-%d");
        var grid_xml = '<Root><Grid>';
        var changed_rows = time_series.series_values_grid.getChangedRows(true);
        if(changed_rows != '') {
            changed_rows = changed_rows.split(',');
            for (i = 0; i < changed_rows.length; i++) {
                grid_xml += '<GridRow ';

                for (j = 0; j < time_series.series_values_grid.getColumnsNum(); j++) {
                    if (time_series.series_values_grid.getColumnId(j) == 'hour') {
                        var hour = time_series.series_values_grid.cells(changed_rows[i],j).getValue();
                        if (hour != '') {
                            var hour_arr = hour.split(':');
                            var minutes = parseInt(hour_arr[0] * 60) + parseInt(hour_arr[1]);
                        } else {
                            hour_empty = 1;
                            var minutes = 0;
                        }
                        grid_xml += ' ' + time_series.series_values_grid.getColumnId(j) + '="' + minutes + '"';    
                    } else {
                        if (time_series.series_values_grid.cells(changed_rows[i],j).getValue() == '') {
                            var col_id = time_series.series_values_grid.getColumnId(j);
                            if (col_id == 'effective_from') {
                                effective_date_empty = 1;
                            } else if (col_id == 'date') {
                                maturity_empty = 1;
                            } 
                        }
                        var colm_id = time_series.series_values_grid.getColumnId(j);
                        if (colm_id == 'curve_value') {
                            var curve_val = time_series.series_values_grid.cells(changed_rows[i],j).getValue();
                            if (curve_val != '') {
                                if (curve_val != parseFloat(curve_val)) {
                                    curve_value_float = 1;   
                                }
                            }
                            
                        }
        
                        grid_xml += ' ' + time_series.series_values_grid.getColumnId(j) + '="' + time_series.series_values_grid.cells(changed_rows[i],j).getValue() + '"';    
                    }
                }

                grid_xml += ' time_series_definition_id="' + time_series_definition_id + '"';
                grid_xml += ' curve_source="' + curve_source + '"';
                grid_xml += ' />'
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
            var curve_value_header = time_series.time_series_grid.cells(selected_row, time_series.time_series_grid.getColIndexById('name')).getValue();
            
            dhtmlx.alert({
                title:"Alert",
                type:"alert",
                text:"Data Error in <strong>Series Values</strong> grid.Please check the data in column <strong>" + curve_value_header + "</strong> and resave"
            });
            return;
        }
        
        var effective_date_applicable = time_series.time_series_grid.cells(selected_row, time_series.time_series_grid.getColIndexById('effective_date_applicable')).getValue();
        var maturity_applicable = time_series.time_series_grid.cells(selected_row, time_series.time_series_grid.getColIndexById('maturity_applicable')).getValue();
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
        
        var granularity = time_series.time_series_grid.cells(selected_row, time_series.time_series_grid.getColIndexById('granularity')).getValue();
        if (maturity_applicable == 'y' && hour_empty == 1 && (granularity == '15Min' || granularity == '30Min' || granularity == 'Hourly')) {
            dhtmlx.alert({
                title:"Alert",
                type:"alert",
                text:"Data Error in <strong>Series Values</strong> grid.Please check the data in column <strong>Hour</strong> and resave"
            });
            return;
        }
        time_series.series_values_menu.setItemDisabled('save');
        var data = {
                        "action": "spa_time_series",
                        "flag": "t",
                        "xml": grid_xml
                    };

        adiha_post_data('return_json', data, '', '', 'time_series.refresh_series_values_grid_callback', '');
    }
    
    time_series.refresh_series_values_grid_callback = function(result) {
        if (has_rights_series_value_ui) {
            time_series.series_values_menu.setItemEnabled('save');
        };
        var return_data = JSON.parse(result);
        var status = return_data[0].status;
        
        if (status == 'Success') {
            success_call(return_data[0].message);
            
            time_series.refresh_series_values_grid();
            setTimeout(function(){
                time_series_window.close();
            }, 1000);
        } else if (status == 'Error') {
            show_messagebox(return_data[0].message);
        }
    }
    
    /*
     * time_series.series_values_batch    [Batch function]
     */
    time_series.series_values_batch = function() {
        var effective_date = time_series.time_series_filter_form.getItemValue('effetive_date', true);
        var tenor_from = time_series.time_series_filter_form.getItemValue('tenor_from', true);
        var tenor_to = time_series.time_series_filter_form.getItemValue('tenor_to', true);
        var curve_source = time_series.time_series_filter_form.getItemValue('curve_source');
        var show_effective_data = time_series.time_series_filter_form.isItemChecked('show_effective');
        if (show_effective_data == true) { show_effective_data = 'y'; } else { show_effective_data = 'n'; }
        var round_value = time_series.time_series_filter_form.getItemValue('round_value');
        
        var selected_row = time_series.time_series_grid.getSelectedRowId();
        var tree_level =  time_series.time_series_grid.getLevel(selected_row);
        
        if (selected_row == null || tree_level == 0) {
            show_messagebox('Please select a series.');
            return;
        }
        
        if (show_effective_data == 'y' && effective_date == '') {
            show_messagebox('Please select Effective Date.');
            return;
        }
        
        var effective_date_applicable = time_series.time_series_grid.cells(selected_row, time_series.time_series_grid.getColIndexById('effective_date_applicable')).getValue();
        var maturity_applicable = time_series.time_series_grid.cells(selected_row, time_series.time_series_grid.getColIndexById('maturity_applicable')).getValue();
        var granularity = time_series.time_series_grid.cells(selected_row, time_series.time_series_grid.getColIndexById('granularity')).getValue();
        var time_series_definition_id = time_series.time_series_grid.cells(selected_row, time_series.time_series_grid.getColIndexById('time_series_definition_id')).getValue();
        var series = '<?php echo $layout_header; ?>';
        
        var exec_call = "EXEC spa_time_series " 
                            + " @flag='s'"
                            + ", @effective_date=" + singleQuote(effective_date)
                            + ", @tenor_from=" + singleQuote(tenor_from)
                            + ", @tenor_to=" + singleQuote(tenor_to)
                            + ", @curve_source=" + singleQuote(curve_source)
                            + ", @show_effective_data=" + singleQuote(show_effective_data)
                            + ", @time_series_definition_id=" + singleQuote(time_series_definition_id)
                            + ", @round_value=" + singleQuote(round_value)
                            + ", @effective_date_applicable=" + singleQuote(effective_date_applicable)
                            + ", @maturity_applicable=" + singleQuote(maturity_applicable)
                            + ", @granularity=" + singleQuote(granularity)
                            + ", @report_name=" + singleQuote(series)
                            + ", @for_batch='y'";
        
        var param = 'gen_as_of_date=1&batch_type=c'; 
        
        if (effective_date != '') {
            param += '&as_of_date=' + effective_date;
        }
        adiha_run_batch_process(exec_call, param, series);
    }
    
    
    /*
     * undock_time_series    [Undock function for the time series grid layout cell]
     */
    undock_time_series = function() {
        w1 = time_series.time_series_layout.cells('a').undock(300, 300, 900, 700);
        time_series.time_series_layout.dhxWins.window('a').button('park').hide();
        time_series.time_series_layout.dhxWins.window('a').maximize();
        time_series.time_series_layout.dhxWins.window('a').centerOnScreen();
    }
    
    /*
     * undock_series_values    [Undock function for the series values grid layout cell]
     */
    undock_series_values = function() {
        w1 = time_series.time_series_layout.cells('c').undock(300, 300, 900, 700);
        time_series.time_series_layout.dhxWins.window('c').button('park').hide();
        time_series.time_series_layout.dhxWins.window('c').maximize();
        time_series.time_series_layout.dhxWins.window('c').centerOnScreen();
    }
    
    /*
     * time_series.on_dock_event    [Shows the undock button]
     */
    time_series.on_dock_event = function() {
        $(".undock_cell_a").show();
    }
    
    /*
     * time_series.on_undock_event    [Hides the undock button]
     */
    time_series.on_undock_event = function() {
        $(".undock_cell_a").hide();
    }
    
</script>