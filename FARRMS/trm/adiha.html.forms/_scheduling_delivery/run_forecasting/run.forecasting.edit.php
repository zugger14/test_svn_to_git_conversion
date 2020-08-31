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
    $process_id = get_sanitized_value($_GET['process_id'] ?? '');
    $granularity = get_sanitized_value($_GET['granularity'] ?? '');
    
    $json = '[
                {
                    id:             "a",
                    text:           "Edit Forecast",
                    header:         true,
                    width:          350
                }
            ]';
    
	$exec_sql = "EXEC spa_forecast_parameters_mapping @flag='e',@process_id='" . $process_id . "'";
	$sql_data = readXMLURL2($exec_sql);
	$min_date = $sql_data[0]['min_date'];
	$max_date = $sql_data[0]['max_date'];
	$run_date = $sql_data[0]['run_date'];
	$forecast_type = $sql_data[0]['forecast_type'];
	$output = $sql_data[0]['output'];
	
    $namespace = 'edit_forecasting';
    $edit_forecasting_layout_obj = new AdihaLayout();
    echo $edit_forecasting_layout_obj->init_layout('edit_forecasting_layout', '', '1C', $json, $namespace);
    
    $tab_json = '[{"id":"d","text":"Plot","active":"true"},{"id":"a","text":"Data"},{"id":"b","text":"Error"},{"id":"c","text":"Forecast Comparasion"}]';
    echo $edit_forecasting_layout_obj->attach_tab_cell('edit_forecasting_tab', 'a', $tab_json);
    
    // Attaching Layout in Tab
    $tab_obj = new AdihaTab();
    echo $tab_obj->init_by_attach('edit_forecasting_tab',$namespace);
    $data_tab_json = '[
                        {
                            id:             "a",
                            text:           "Filter",
                            header:         true,
                            height:         100,
							collapse:		true
                        },
                        {
                            id:             "b",
                            text:           "Graph",
                            header:         true
                        }
                    ]';
    echo $tab_obj->attach_layout_cell($namespace, 'plot_tab_layout', $namespace . '.edit_forecasting_tab', 'd', '2E', $data_tab_json);
    $plot_tab_layout_obj = new AdihaLayout();
    echo $plot_tab_layout_obj->init_by_attach('plot_tab_layout', $namespace);
    
    echo $tab_obj->attach_layout_cell($namespace, 'comp_data_tab_layout', $namespace . '.edit_forecasting_tab', 'c', '2E', $data_tab_json);
    $comp_tab_layout_obj = new AdihaLayout();
    echo $comp_tab_layout_obj->init_by_attach('comp_data_tab_layout', $namespace);
	
	echo $tab_obj->attach_layout_cell($namespace, 'data_tab_layout', $namespace . '.edit_forecasting_tab', 'a', '2E', $data_tab_json);
    $data_layout_obj = new AdihaLayout();
    echo $data_layout_obj->init_by_attach('data_tab_layout', $namespace);
    
    //Filter form JSON
    $form_json = '[
                        {type: "settings", position: "label-left", inputWidth: 150, offsetLeft: 15, offsetTop: 5, position: "label-top"},
                        {type: "calendar", dateFormat: "' . $date_format . '","serverDateFormat":"%Y-%m-%d", name: "start_date", label: "Start Date", value:"' . $min_date . '", calendarPosition: "bottom"},
                        {type: "newcolumn"},
                        {type: "calendar", dateFormat: "' . $date_format . '","serverDateFormat":"%Y-%m-%d", name: "end_date", label: "End Date", value: "' . $max_date . '", calendarPosition: "bottom"},
                    ]';
    
    
    //Attaching filter form for graph/chart
    echo $plot_tab_layout_obj->attach_form('predicted_data_filter', 'a');
    $predicted_data_filter = new AdihaForm();
    echo $predicted_data_filter->init_by_attach('predicted_data_filter', $namespace);
    echo $predicted_data_filter->load_form($form_json);
    echo $predicted_data_filter->attach_event('','onChange', 'function() { load_forecast_data_chart(); }');
    
    //Attaching Graph/Chart
    $predicted_data_chart_obj = new AdihaChart('predicted_data_chart', $namespace);
    echo $predicted_data_chart_obj->attach_to_layout('plot_tab_layout','b');
    echo $predicted_data_chart_obj->init_chart('line','maturity','Maturity','predicition_data', 'Prediction Data');
    echo $predicted_data_chart_obj->load_legends();
    
    //Attaching filter form for graph/chart
    echo $comp_tab_layout_obj->attach_form('comp_data_filter', 'a');
    $comp_data_filter = new AdihaForm();
    echo $comp_data_filter->init_by_attach('comp_data_filter', $namespace);
    echo $comp_data_filter->load_form($form_json);
    echo $comp_data_filter->attach_event('','onChange', 'function() { load_forecast_comp_data_chart(); }');
    
    //Attaching Graph/Chart
    $comp_data_chart_obj = new AdihaChart('comp_data_chart', $namespace);
    echo $comp_data_chart_obj->attach_to_layout('comp_data_tab_layout','b');
    echo $comp_data_chart_obj->init_chart('line','maturity','Maturity','predicition_data', 'Data', 'Prediction Data');
    echo $comp_data_chart_obj->add_series('test_data', 'Test Data',3);
    echo $comp_data_chart_obj->load_legends();
    
	//Attaching filter form for Data tab
    echo $data_layout_obj->attach_form('data_filter_form', 'a');
    $data_filter_form = new AdihaForm();
    echo $data_filter_form->init_by_attach('data_filter_form', $namespace);
    echo $data_filter_form->load_form($form_json);
    echo $data_filter_form->attach_event('','onChange', 'function() { refresh_edit_forecast_grid(); }');
    
    $menu_json = '[{id:"approve", text:"Approve", img:"finalize.gif", imgdis:"finalize_dis.gif"}]';
	echo $edit_forecasting_layout_obj->attach_menu_layout_cell('edit_forecasting_menu', 'a', $menu_json, 'edit_forecasting_menu_onlick');
	
	$print_menu_json = '[{id:"print", text:"Print", img:"print.gif", imgdis:"print_dis.gif"}]';
	echo $plot_tab_layout_obj->attach_menu_layout_cell('print_plot_menu', 'b', $print_menu_json, 'print_plot_menu_onlick');
	echo $comp_tab_layout_obj->attach_menu_layout_cell('print_comp_menu', 'b', $print_menu_json, 'print_comp_menu_onlick');
	
    echo $edit_forecasting_layout_obj->close_layout();
    ?> 
</body>


<script type="application/javascript">
    var theme_selected = 'dhtmlx_' + default_theme;
    var process_id = '<?php echo $process_id; ?>';
	var granularity = '<?php echo $granularity; ?>';
    var changed_cell_value = new Array();
	var php_script_loc = '<?php echo $app_php_script_loc; ?>';
	    
    $(function() {
        load_edit_forecast_grid();  
		load_edit_forecast_menu();
        load_error_status_grid();  
        load_forecast_data_chart();
        load_forecast_comp_data_chart();
		
		var run_date = '<?php echo $run_date; ?>';
		var forecast_type = '<?php echo $forecast_type; ?>';
		var output = '<?php echo $output; ?>';
		var title = forecast_type + ' - ' + output + ' (Run Date : ' + run_date + ')';
		
		edit_forecasting.plot_tab_layout.cells('b').setText("<a class=\"undock_a undock-btn undock_custom\" style=\"float: right; cursor:pointer\" title=\"Undock\"  onClick=\" undock_window(1);\"></a>" + title);
		edit_forecasting.data_tab_layout.cells('b').setText("<a class=\"undock_a undock-btn undock_custom\" style=\"float: right; cursor:pointer\" title=\"Undock\"  onClick=\" undock_window(2);\"></a>" + title);
		edit_forecasting.comp_data_tab_layout.cells('b').setText("<a class=\"undock_a undock-btn undock_custom\" style=\"float: right; cursor:pointer\" title=\"Undock\"  onClick=\" undock_window(3);\"></a>" + title);
    });
    
    
    load_forecast_data_chart = function() {
        var date_from = edit_forecasting.predicted_data_filter.getItemValue('start_date',true); 
        var date_to = edit_forecasting.predicted_data_filter.getItemValue('end_date',true); 
        
        var param = {
                "action": "spa_forecast_parameters_mapping",
                "flag": "n",
                "xaxis_col": "maturity",
				"yaxis_col":"predicition_data",
                "grid_type":"l",
				"chart_data":"d",
                "process_id":process_id,
                "date_from": date_from,
                "date_to": date_to
         };

        param = $.param(param);
        var param_url = js_data_collector_url + "&" + param;
		edit_forecasting.predicted_data_chart.clearAll();
        edit_forecasting.predicted_data_chart.load(param_url);
    }
    
    load_forecast_comp_data_chart = function() {
        var date_from = edit_forecasting.comp_data_filter.getItemValue('start_date',true); 
        var date_to = edit_forecasting.comp_data_filter.getItemValue('end_date',true); 
        
        var param = {
                "action": "spa_forecast_parameters_mapping",
                "flag": "o",
                "xaxis_col": "maturity",
				"yaxis_col":"predicition_data,test_data",
                "grid_type":"l",
				"chart_data":"d",
                "process_id":process_id,
                "date_from": date_from,
                "date_to": date_to
         };

        param = $.param(param);
        var param_url = js_data_collector_url + "&" + param;
        edit_forecasting.comp_data_chart.clearAll();
        edit_forecasting.comp_data_chart.load(param_url);
    }
    
    load_edit_forecast_grid = function() {
		var column_header = new Array();
		var colum_type = new Array();
		var column_string = new Array();
		var column_visibility = new Array();
		var column_width = new Array();
		
		column_header.push('Date');
		colum_type.push('ro');
		column_string.push('str');
		column_visibility.push('false');
		column_width.push('150');
		
		var loop_end = 1; // 993 Annually, 980 Daily, 981 Monthly
		var minutes_increment = 0;
		if (granularity == 982) { //Hourly
			loop_end = 25;
			minutes_increment = 60;
		} else if (granularity == 989) { //30 Minutes
			loop_end = 48;
			minutes_increment = 30;
		} else if (granularity == 987) { //15 Minutes
			loop_end = 96;
			minutes_increment = 15;
		} else if (granularity == 994) { //10 Minutes
			loop_end = 144;
			minutes_increment = 10;
		} else if (granularity == 995) { //5 Minutes
			loop_end = 288;
			minutes_increment = 5;
		} else if (granularity == 981) {
            loop_end = 31;
			minutes_increment = 60;
        }
		
		var minutes = 0;
		var hour = 0;
		
		for (cnt = 1; cnt <= loop_end; cnt++) {
			if (loop_end == 1) {
                column_header.push('Value');
			} else if (loop_end == 31) {
                column_header.push(cnt);
            } else {
				minutes_display = '0' + minutes;
				minutes_display = minutes_display.slice(-2);
				hour_display = '0' + hour;
				hour_display = hour_display.slice(-2);
				
				column_header.push(hour_display + ':' + minutes_display);
			}
			colum_type.push('ro');
			column_string.push('str');
			column_visibility.push('false');
			column_width.push('65');
			
			minutes +=  minutes_increment;
			if (minutes >= 60) {
				minutes = 0;
				hour++;
			}
		}
		
		
		edit_forecasting.edit_forecasting_grid = edit_forecasting.data_tab_layout.cells('b').attachGrid();
        edit_forecasting.edit_forecasting_grid.setImagePath(js_php_path + 'components/lib/adiha_dhtmlx/themes/' + theme_selected + '/imgs/dhxgrid_web/');

        edit_forecasting.edit_forecasting_grid.setHeader(column_header.toString());
        
        edit_forecasting.edit_forecasting_grid.setColTypes(colum_type.toString());
        edit_forecasting.edit_forecasting_grid.setColSorting(column_string.toString());

        edit_forecasting.edit_forecasting_grid.setColumnsVisibility(column_visibility.toString());
        edit_forecasting.edit_forecasting_grid.setInitWidths(column_width.toString());
        edit_forecasting.edit_forecasting_grid.init();
        
        refresh_edit_forecast_grid();
        
        edit_forecasting.edit_forecasting_grid.attachEvent("onEditCell", function(stage,rId,cInd,nValue,oValue){
            if (stage == 2) {
                if(oValue.toLowerCase() != nValue.toLowerCase()) {
                    if (jQuery.inArray([rId, cInd], changed_cell_value) == -1) {
                        changed_cell_value.push([rId, cInd]);
                    }
                }
            }
            return true
        });
    }
	
	load_edit_forecast_menu = function() {
		
		
		edit_forecasting.edit_forecasting_menu = edit_forecasting.data_tab_layout.cells('b').attachMenu({
			icons_path: js_image_path + "dhxmenu_web/",
			items:[{id:"export", text:"Export", img:"export.gif", items:[
						{id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
						{id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
					]}
				]
		});
		
		edit_forecasting.edit_forecasting_menu.attachEvent("onClick", function(id) {
			switch (id) {
				case "excel":
					edit_forecasting.edit_forecasting_grid.toExcel(php_script_loc + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
					break;
				case "pdf":
					edit_forecasting.edit_forecasting_grid.toPDF(php_script_loc +'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
					break;
			}
		});
	}
    
    load_error_status_grid = function() {
        edit_forecasting.error_status_grid = edit_forecasting.edit_forecasting_tab.tabs('b').attachGrid();
        edit_forecasting.error_status_grid.setImagePath(js_php_path + 'components/lib/adiha_dhtmlx/themes/' + theme_selected + '/imgs/dhxgrid_web/');

        edit_forecasting.error_status_grid.setHeader("RMSE,MAPE");
        
        edit_forecasting.error_status_grid.setColTypes("ro,ro");
        edit_forecasting.error_status_grid.setColSorting("str,str");

        edit_forecasting.error_status_grid.setColumnsVisibility("false,false");
        edit_forecasting.error_status_grid.setInitWidths('350,350');
        edit_forecasting.error_status_grid.init();
        
        refresh_error_status_grid();
    }
    
    refresh_edit_forecast_grid = function() {
		var date_from = edit_forecasting.data_filter_form.getItemValue('start_date', true);
		var date_to = edit_forecasting.data_filter_form.getItemValue('end_date', true);
		
        var param = {
                        "action": "spa_forecast_parameters_mapping",
                        "flag": "t",
                        "process_id": process_id,
						"date_from":date_from,
						"date_to":date_to
                    };

        param = $.param(param);
        var param_url = js_data_collector_url + "&" + param;
        edit_forecasting.edit_forecasting_grid.clearAll();
        edit_forecasting.edit_forecasting_grid.loadXML(param_url);
    }
    
    refresh_error_status_grid = function() {
        var param = {"action": "('SELECT RMSE,MAPE FROM forecast_error_list WHERE process_id = ''" + process_id + "''')"};

        param = $.param(param);
        var param_url = js_data_collector_url + "&" + param;
        edit_forecasting.error_status_grid.clearAll();
        edit_forecasting.error_status_grid.loadXML(param_url);
    }
    
    edit_forecasting_menu_onlick = function(id, zoneId, cas) {
        if(id == 'approve') {
            approve_edit_forecast();
        }
    }
    
    approve_edit_forecast = function() {
        data = {"action": "spa_forecast_parameters_mapping",
                    "flag": "v",
                    "process_id": process_id
                 };

        adiha_post_data('alert', data, '', '', '', '');
    }
	
	undock_window = function(ind) {
		if (ind == 1) {
			edit_forecasting.plot_tab_layout.cells('b').undock(300, 300, 900, 700);
			edit_forecasting.plot_tab_layout.dhxWins.window('b').maximize();
			edit_forecasting.plot_tab_layout.dhxWins.window("b").button("park").hide();
		} else if (ind == 2) {
			edit_forecasting.data_tab_layout.cells('b').undock(300, 300, 900, 700);
			edit_forecasting.data_tab_layout.dhxWins.window('b').maximize();
			edit_forecasting.data_tab_layout.dhxWins.window("b").button("park").hide();
		} else {
			edit_forecasting.comp_data_tab_layout.cells('b').undock(300, 300, 900, 700);
			edit_forecasting.comp_data_tab_layout.dhxWins.window('b').maximize();
			edit_forecasting.comp_data_tab_layout.dhxWins.window("b").button("park").hide();
		}
	}
	
	print_plot_menu_onlick = function() {
		undock_window(1);
		edit_forecasting.print_plot_menu.hideItem('print');
		window.print(); 
		edit_forecasting.print_plot_menu.showItem('print');
	}
	
	print_comp_menu_onlick = function() {
		undock_window(3);
		edit_forecasting.print_comp_menu.hideItem('print');
		window.print(); 
		edit_forecasting.print_comp_menu.showItem('print');
	}
	
</script>