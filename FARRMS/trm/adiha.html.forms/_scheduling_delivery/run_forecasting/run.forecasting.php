<!DOCTYPE html>
<html> 
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
    
<body class = "bfix">
    <?php 
    $php_script_loc = $app_php_script_loc;
    $app_user_loc = $app_user_name;
    
    $rights_forecasting = 10167400;
    $rights_forecasting_run = 10167410;

    list (
        $has_rights_forecasting,
        $has_rights_forecasting_run
    ) = build_security_rights(
        $rights_forecasting,
        $rights_forecasting_run
    );

    $json = '[
                {
                    id:             "a",
                    text:           "Forecast Mapping",
                    header:         true,
                    width:          350
                },{
                    id:             "b",
                    text:           "Filter",
                    header:         true,
                    collapse:       false,
                    height:         90
                },{
                    id:             "c",
                    text:           "View",
                    header:         true,
                    collapse:       false
                }
            ]';
    
    $namespace = 'run_forecasting';
    $run_forecasting_layout_obj = new AdihaLayout();
    echo $run_forecasting_layout_obj->init_layout('run_forecasting_layout', '', '3L', $json, $namespace);
 
	$layout_json = '[
                {
                    id:             "a",
                    text:           "Apply Filter",
                    header:         true,
                    width:          350,
                    height:         90
                },{
                    id:             "b",
                    text:           "Forecast Mapping",
                    header:         true,
                    collapse:       false
                }]';
	
	$inner_layout_obj = new AdihaLayout();
	echo $run_forecasting_layout_obj->attach_layout_cell('inner_layout', 'a', '2E', $layout_json);
	$inner_layout_obj->init_by_attach('inner_layout', $namespace);
 
    $menu_json = '[{id:"run", text:"Run", img:"run.gif", imgdis:"run_dis.gif"}]';
	echo $inner_layout_obj->attach_menu_layout_cell('run_forecasting_menu', 'b', $menu_json, 'run_forecasting_menu_onlick');
	
    $grid_name = 'run_forecasting_grid';
    echo $inner_layout_obj->attach_grid_cell($grid_name, 'b');
	$forecasting_grid_obj = new GridTable('forecast_parameters_mapping');
	echo $forecasting_grid_obj->init_grid_table($grid_name, $namespace);
	echo $forecasting_grid_obj->set_search_filter(true);
	echo $forecasting_grid_obj->enable_multi_select();
	echo $forecasting_grid_obj->return_init();
	echo $forecasting_grid_obj->attach_event('', 'onRowDblClicked', 'run_forecasting_grid_dbclick');
	
    $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10167400', @template_name='Run Forecasting', @group_name='General'";
    $return_value1 = readXMLURL($xml_file);
    $form_json = $return_value1[0][2];
    echo $run_forecasting_layout_obj->attach_form('run_forecasting_form', 'b');
    $run_forecasting_form = new AdihaForm();
    echo $run_forecasting_form->init_by_attach('run_forecasting_form', $namespace);
    echo $run_forecasting_form->load_form($form_json);
    
    $status_menu_json = '[{id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif"},
						  {id:"delete", text:"Delete", img:"delete.gif", imgdis:"delete_dis.gif", enabled:0}]';
	echo $run_forecasting_layout_obj->attach_menu_layout_cell('forecast_status_menu', 'c', $status_menu_json, 'forecast_status_menu_onlick');
	
    $status_grid_name = 'forecast_status_grid';
    echo $run_forecasting_layout_obj->attach_grid_cell($status_grid_name, 'c');
    $status_grid_obj = new AdihaGrid();
    echo $status_grid_obj->init_by_attach($status_grid_name, $namespace);
    echo $status_grid_obj->set_header("Date Time,User,Status,process_id,Process ID");
    echo $status_grid_obj->set_columns_ids("datetime,user,status,process_id,process_id_link");
    echo $status_grid_obj->set_widths("220,180,180,0,320");
    echo $status_grid_obj->set_column_types("ro,ro,ro,ro,link");
    echo $status_grid_obj->set_column_visibility("false,false,false,true,false");
    echo $status_grid_obj->set_search_filter(false, '#daterange_filter,#text_filter,#text_filter, , ,#text_filter');
    echo $status_grid_obj->return_init();
    
    echo $run_forecasting_layout_obj->close_layout();
    ?> 
    

</body>
    
    <style>
       html, body {
           width: 100%;
           height: 100%;
           margin: 0px;
           overflow: hidden;
       }
    </style>
    
    <script type="text/javascript">  
		var client_date_format = '<?php echo $date_format; ?>';
        var has_rights_forecasting_run = "<?php echo ($has_rights_view_invoice ?? '0'); ?>";
        
        $(function(){
			refresh_forecast_mapping_grid();
			
			filter_obj = run_forecasting.inner_layout.cells('a').attachForm();
            var layout_cell_obj = run_forecasting.run_forecasting_layout.cells('b');
            load_form_filter(filter_obj, layout_cell_obj, '10167400', 2);
			
			run_forecasting.forecast_status_grid.attachEvent("onRowSelect", function(id,ind){
				run_forecasting.forecast_status_menu.setItemEnabled('delete');
			});
        });
		
		run_forecasting_menu_onlick = function() {
			show_run_popup();
        }
        
        forecast_status_menu_onlick = function(name) {
			if (name == 'refresh')
				refresh_forecast_status_grid();
			else if (name == 'delete')
				delete_forecast_status_grid();
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
            run_forecasting.run_forecasting_grid.clearAll();
            run_forecasting.run_forecasting_grid.loadXML(param_url, function() {
                run_forecasting.run_forecasting_grid.expandAll()
            });
        }
        
        
        refresh_forecast_status_grid = function() {
            var date_from = run_forecasting.run_forecasting_form.getItemValue('date_from', true);
            var date_to = run_forecasting.run_forecasting_form.getItemValue('date_to', true);
            var status = run_forecasting.run_forecasting_form.getItemValue('status');

            if (Date.parse(date_from) > Date.parse(date_to)) {
                show_messagebox('<strong>Date From</strong> should be less than <strong>Date To</strong>.');
                return
            }
			
			var row_id = run_forecasting.run_forecasting_grid.getSelectedRowId();
			if (row_id == null) {
				var forecast_mapping_id = '';
			} else {
				var forecast_mapping_id = run_forecasting.run_forecasting_grid.cells(row_id,1).getValue();
			}
            
			var param = {
                            "action": "spa_forecast_parameters_mapping",
                            "flag": "z",
                            "date_from": date_from,
                            "date_to":date_to,
                            "status": status,
							"forecast_mapping_id":forecast_mapping_id
                
                     };

            param = $.param(param);
            var param_url = js_data_collector_url + "&" + param;
            run_forecasting.forecast_status_grid.clearAll();
            run_forecasting.forecast_status_grid.loadXML(param_url);
			run_forecasting.forecast_status_menu.setItemDisabled('delete');
        }
        
        run_forecasting.grid_link_click = function(process_id,granularity) {
            var forecast_edit_win = new dhtmlXWindows();
            m_win = forecast_edit_win.createWindow('w1', 0, 0, 600, 520);
            m_win.setText("View Forecast");
            m_win.centerOnScreen();
            m_win.setModal(true);
            m_win.maximize();
            m_win.attachURL("run.forecasting.edit.php?process_id=" + process_id + '&granularity=' + granularity);
            
            forecast_edit_win.attachEvent("onClose", function(win){
                refresh_forecast_status_grid();
                return true;
            });
        }
		
		
		show_run_popup = function() {
			var selected_id = run_forecasting.run_forecasting_grid.getSelectedRowId();
			var selected_row_arr = new Array();
			var forecasting_arr = new Array();
			
			if (selected_id != null) {
				selected_row_arr = selected_id.split(',');
			}
			
			for (i = 0; i < selected_row_arr.length; i++) {
				var tree_level = run_forecasting.run_forecasting_grid.getLevel(selected_row_arr[i]);
				if (tree_level == 1) {
					var forecast_mapping_id = run_forecasting.run_forecasting_grid.cells(selected_row_arr[i],1).getValue();
					forecasting_arr.push(forecast_mapping_id);
				}
			}
			
			if (forecasting_arr.length == 0) {
				show_messagebox('Please Select Forecast');
				return;
			}
			
			var new_date = new Date();
			var date = new Date(new_date.getFullYear(), new_date.getMonth() , new_date.getDate());
			
			var run_form_data = [
                                    {type: "settings", position: "label-left", labelWidth: 150, inputWidth: 130, position: "label-top", offsetLeft: 20},
                                    {type: "calendar", name: "as_of_date", label: "As of Date", "dateFormat": client_date_format,"serverDateFormat":"%Y-%m-%d"},
                                    {type: "checkbox", name: "retrain", label: "Re-train", position: "label-right"},
									{type: "checkbox", name: "export_file", label: "Export Input Data", position: "label-right"},
                                    {type: "button", value: "Ok", img: "tick.png"}
                                ];
            
			var run_popup = new dhtmlXPopup();
			var run_form = run_popup.attachForm(run_form_data);
			run_form.setItemValue('as_of_date', date);
			run_popup.show(5,120,45,45);
			
			run_form.attachEvent("onButtonClick", function() {
				var forecast_mapping = forecasting_arr.toString();
				var as_of_date = run_form.getItemValue('as_of_date', true);
				var retrain = run_form.isItemChecked('retrain');
				var export_file = run_form.isItemChecked('export_file');
				if (retrain == true) { retrain = 'y'; } else {retrain = 'n';}
				if (export_file == true) { export_file = 'y'; } else {export_file = 'n';}
				
				var exec_call = "EXEC spa_run_forecast " 
                            + "'r'"
                            + "," + singleQuote(as_of_date)
							+ "," + singleQuote(forecast_mapping)
                            + "," + singleQuote(retrain)
							+ "," + singleQuote(export_file);
				var param = 'call_from=Run_Forecast&gen_as_of_date=1&as_of_date=' + as_of_date; 
				adiha_run_batch_process(exec_call, param, 'Run Forecast');
			});
        }
		
		
		run_forecasting_grid_dbclick = function(rId,cInd) {
			var selected_row = run_forecasting.run_forecasting_grid.getSelectedRowId();
            var state = run_forecasting.run_forecasting_grid.getOpenState(selected_row);
            
            if (state)
                run_forecasting.run_forecasting_grid.closeItem(selected_row);
            else
                run_forecasting.run_forecasting_grid.openItem(selected_row);
		}
		
		delete_forecast_status_grid = function() {
			var selected_row = run_forecasting.forecast_status_grid.getSelectedRowId();
			var process_id = run_forecasting.forecast_status_grid.cells(selected_row, run_forecasting.forecast_status_grid.getColIndexById('process_id')).getValue();
			
			
			data = {"action": "spa_forecast_parameters_mapping",
						"flag": "b",
						"process_id": process_id
					};

			adiha_post_data('alert', data, '', '', 'refresh_forecast_status_grid', '', '');
		}
		
    </script> 
