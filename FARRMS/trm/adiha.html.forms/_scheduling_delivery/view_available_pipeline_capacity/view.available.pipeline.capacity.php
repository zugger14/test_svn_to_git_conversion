<?php
/**
* View available pipeline capacity screen
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
<style>
   html, body {
       width : 100%;
       height : 100%;
       margin : 0px;
       overflow : hidden;
   }
</style>  
<body class = "bfix">
    <?php
	$term_start = get_sanitized_value($_GET['flow_date'] ?? '');
	$term_end = get_sanitized_value($_GET['flow_date_end'] ?? '');
	$path_ids = get_sanitized_value($_GET['path_ids'] ?? '');
	$call_from = get_sanitized_value($_GET['call_from'] ?? '');
	
    $rights_view_available_pipeline_capacity = 10167500;
    
    list (
        $has_rights_view_available_pipeline_capacity
    ) = build_security_rights(
        $rights_view_available_pipeline_capacity
    );

    $json = '[
                {
                    id:             "a",
                    text:           "Filter Criteria",
                    header:         true,
                    collapse:       false,
                    height:         130
                },
                {
                    id:             "b",
                    text:           "Available Pipeline Capacity",
                    header:         true,
                    collapse:       false
                }  
            ]';
    
    $namespace = 'available_pipeline_capacity';
    $available_pipeline_capacity_layout_obj = new AdihaLayout();
    echo $available_pipeline_capacity_layout_obj->init_layout('available_pipeline_capacity_layout', '', '2E', $json, $namespace);
 
    //Attaching Filter form
    $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10167500', @template_name='available pipeline capacity', @group_name='General'";
    $return_value1 = readXMLURL($xml_file);
    $form_json = $return_value1[0][2];
    echo $available_pipeline_capacity_layout_obj->attach_form('available_pipeline_capacity_form', 'a');
    $available_pipeline_capacity_form = new AdihaForm();
    echo $available_pipeline_capacity_form->init_by_attach('available_pipeline_capacity_form', $namespace);
    echo $available_pipeline_capacity_form->load_form($form_json, $namespace . '.set_default_values()');
    
    //Attaching Toolbar
	$toolbar_json = '[
						{id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif"},
						{id:"pivot", text:"Pivot", img:"pivot.gif", imgdis:"pivot_dis.gif"}
					]';
	echo $available_pipeline_capacity_layout_obj->attach_menu_layout_cell('available_pipeline_capacity_toolbar', 'b', $toolbar_json, 'available_pipeline_capacity_toolbar_onclick');
	
	echo $available_pipeline_capacity_layout_obj->close_layout();
	
	$xml_file = "EXEC [spa_adiha_default_codes_values] @flag = 'combo_grid', @default_code_id = 206";
    $return_data = readXMLURL($xml_file);
    $granularity = $return_data[0][4];
    ?> 
    
</body>
    
<script type="text/javascript">  
	var client_date_format = '<?php echo $date_format; ?>';
	var granularity = <?php echo $granularity; ?>;
	var grid_cell_id = 'b';

	var default_date_from  = '<?php echo $term_start ?>';
	var default_date_to  = '<?php echo $term_end ?>';
	var default_path_ids  = '<?php echo $path_ids ?>';
	var call_from = '<?php echo $call_from; ?>';
	
    $(function() {
        filter_obj = available_pipeline_capacity.available_pipeline_capacity_layout.cells('a');
        var layout_cell_obj = available_pipeline_capacity.available_pipeline_capacity_layout.cells('a');
        load_form_filter(filter_obj, layout_cell_obj, '10167500', 2, '', '', '', 'layout');
	});
	
	available_pipeline_capacity.set_default_values = function() {
		if (call_from == 'flow_optimization') {
			if (default_date_from != '')
				available_pipeline_capacity.available_pipeline_capacity_form.setItemValue('date_from', default_date_from);
			if (default_date_to != '')
				available_pipeline_capacity.available_pipeline_capacity_form.setItemValue('date_to', default_date_to);

			if (default_path_ids != '') {
				var path_ids_splitted = default_path_ids.split(",");
				var path_combo_obj = available_pipeline_capacity.available_pipeline_capacity_form.getCombo('delivery_path');
				for (var i = 0; i < path_ids_splitted.length; i++) {
					path_combo_obj.setChecked(path_combo_obj.getIndexByValue(path_ids_splitted[i]), true);
				}
			}
			
			available_pipeline_capacity_refresh();
		}
	}
   
    /*
	 * [Menu Click Function]
	 */
    function available_pipeline_capacity_toolbar_onclick(name) {
        if (name == 'refresh') {
            available_pipeline_capacity_refresh();
		} else if (name == 'pivot') {
			available_pipeline_capacity_pivot();
        }  
	}
	
	/*
	 * [Refresh Function]
	 */
	available_pipeline_capacity_refresh = function() {
		if (!validate_form(available_pipeline_capacity.available_pipeline_capacity_form)) {
			return false;
		}

		turn_on_progress(true);

		var date_from = available_pipeline_capacity.available_pipeline_capacity_form.getItemValue('date_from', true);
		var date_to = available_pipeline_capacity.available_pipeline_capacity_form.getItemValue('date_to', true);
		var diff_days = dates.diff_days(date_from, date_to);
		// Validate Date Range
		if (diff_days < 0) {
			show_messagebox('Date From cannot be greater than Date To.');
			turn_on_progress(false);
			return;
		} else if (diff_days > 0 && granularity == 982) {
			show_messagebox('Date range cannot be multiple days.');
			turn_on_progress(false);
			return;
		}

		var contract_obj = available_pipeline_capacity.available_pipeline_capacity_form.getCombo('contract_id');
        var contract_id = contract_obj.getChecked('contract_id');
        contract_id = contract_id.toString();
		var uom_id = available_pipeline_capacity.available_pipeline_capacity_form.getItemValue('uom_id');
		var pipeline_obj = available_pipeline_capacity.available_pipeline_capacity_form.getCombo('pipeline');
        var pipeline = pipeline_obj.getChecked('pipeline');
		pipeline = pipeline.toString();
		var delivery_path_obj = available_pipeline_capacity.available_pipeline_capacity_form.getCombo('delivery_path');
        var delivery_path = delivery_path_obj.getChecked('delivery_path');
        delivery_path = delivery_path.toString();
		
		var col_header1 = "Contract/Path,UOM";
		var col_header2 = "#rspan,#rspan";
		var col_header3 = "#rspan,#rspan";
		var col_type = "tree,ro";
		var col_sorting = "str,str";
		var col_visibility = "false,false";
		var init_width = "250,100";
		var align = "left,left";
		var col_align = '"text-align:left;","text-align:left;"';
		
		var hr_start = 7;
		for (var i = 0; i <= diff_days; i++) {
			var c_date = dates.convert_to_user_format(dates.convert_to_sql(dates.addDays(date_from, i)));
			
			col_header1 += ',' + c_date + ',#cspan';
			col_header2 += ',MDQ Vol, MDQ Avail';
			col_type += ',ro_v,ro_no';
			col_sorting += ',str,str';
			col_visibility += ',false,false';
			init_width += ',80,80';
			align += ',center,center';
			col_align += ',"text-align:center;","text-align:center;"';
			
			if (granularity == 982) {
				col_header3 += ',' + ('0' + (hr_start) + ':00').slice(-5) + ',#cspan';
				for (var j = 1; j < 24; j++) {
					col_header1 += ',#cspan,#cspan';
					col_header2 += ',MDQ Vol, MDQ Avail';
					col_header3 += ',' + ('0' + (j + (j < 18 ? hr_start : -17)) + ':00').slice(-5) + ',#cspan';
					col_type += ',ro_v,ro_no';
					col_sorting += ',str,str';
					col_visibility += ',false,false';
					init_width += ',80,80';
					align += ',center,center';
					col_align += ',"text-align:center;","text-align:center;"';
				}
			}
		}

		col_align = jQuery.parseJSON('[' + col_align + ']');
		
		var flag = 's';

		available_pipeline_capacity.available_pipeline_capacity_grid = available_pipeline_capacity.available_pipeline_capacity_layout.cells(grid_cell_id).attachGrid();
        available_pipeline_capacity.available_pipeline_capacity_grid.setImagePath(js_image_path + 'dhxgrid_web/');
		            
		available_pipeline_capacity.available_pipeline_capacity_grid.setHeader(col_header1,null,col_align);
		if (granularity == 982) {
			available_pipeline_capacity.available_pipeline_capacity_grid.attachHeader(col_header3);
			flag = 'h';
		}
		available_pipeline_capacity.available_pipeline_capacity_grid.attachHeader(col_header2);
        available_pipeline_capacity.available_pipeline_capacity_grid.setColTypes(col_type);
        available_pipeline_capacity.available_pipeline_capacity_grid.setColSorting(col_sorting);
        available_pipeline_capacity.available_pipeline_capacity_grid.setColumnsVisibility(col_visibility);
		available_pipeline_capacity.available_pipeline_capacity_grid.setColAlign(align);
		available_pipeline_capacity.available_pipeline_capacity_grid.setInitWidths(init_width);
        available_pipeline_capacity.available_pipeline_capacity_grid.init();
		available_pipeline_capacity.available_pipeline_capacity_grid.attachEvent("onRowDblClicked", grid_db_click);
		
		var param_url = {
                'flag': flag,
                'action': 'spa_mdq_available',
                'contract_ids': contract_id,
                'flow_date_start': date_from,
                'flow_date_end': date_to,
                'uom_id': uom_id,
				'pipeline': pipeline,
				'path_ids': delivery_path,
				'grid_type': 'tg',
                'grouping_column': 'contract_name,path'
            };
		
		param_url = $.param(param_url);
        var param_url = js_data_collector_url + "&" + param_url;
        available_pipeline_capacity.available_pipeline_capacity_grid.loadXML(param_url, function(){
			available_pipeline_capacity.available_pipeline_capacity_grid.expandAll();
			available_pipeline_capacity_refresh_callback();
			turn_on_progress(false);
        });
	}
	
	/*
	 * [Refresh Callback Function]
	 */
	available_pipeline_capacity_refresh_callback = function() {
		available_pipeline_capacity.available_pipeline_capacity_grid.forEachRow(function(id){
			var tree_level = available_pipeline_capacity.available_pipeline_capacity_grid.getLevel(id);
			
			if (tree_level == 0) {
				var all_paths = available_pipeline_capacity.available_pipeline_capacity_grid.getAllSubItems(id);
				if (all_paths == '' || all_paths == null) var all_paths_arr = new Array();
				else var all_paths_arr = all_paths.split(',');
				
				for (cnt = 0; cnt < all_paths_arr.length; cnt++) {
					var chk_path = available_pipeline_capacity.available_pipeline_capacity_grid.cells(all_paths_arr[cnt],0).getValue();      
					if(chk_path == 'aa_contract_level') {
						available_pipeline_capacity.available_pipeline_capacity_grid.forEachCell(all_paths_arr[cnt],function(cellObj,ind){
							if (ind > 0) {
								var value = available_pipeline_capacity.available_pipeline_capacity_grid.cells(all_paths_arr[cnt],ind).getValue();
								available_pipeline_capacity.available_pipeline_capacity_grid.cells(id,ind).setValue(value);
							}
						}); 
						available_pipeline_capacity.available_pipeline_capacity_grid.setRowHidden(all_paths_arr[cnt],true);
					}
				}
			}
		});
	}
	
	/*
	 * [Grid Pivot Function]
	 */
	available_pipeline_capacity_pivot = function() {
		var date_from = available_pipeline_capacity.available_pipeline_capacity_form.getItemValue('date_from', true);
		var date_to = available_pipeline_capacity.available_pipeline_capacity_form.getItemValue('date_to', true);
		var contract_obj = available_pipeline_capacity.available_pipeline_capacity_form.getCombo('contract_id');
		var contract_id = contract_obj.getChecked('contract_id');
		contract_id = contract_id.toString();
		var uom_id = available_pipeline_capacity.available_pipeline_capacity_form.getItemValue('uom_id');
		var pipeline_obj = available_pipeline_capacity.available_pipeline_capacity_form.getCombo('pipeline');
        var pipeline = pipeline_obj.getChecked('pipeline');
        pipeline = pipeline.toString();
		
		 var pivot_exec_spa = "EXEC spa_mdq_available @flag='s', @contract_ids='" + contract_id 
												+ "',@flow_date_start='" + date_from 
												+ "',@flow_date_end='" + date_to 
												+ "',@uom_id='" + uom_id 
												+ "',@for_pivot='y', @pipeline='" + pipeline + "'";
		
		open_grid_pivot('', 'available_pipeline_capacity_grid', 1, pivot_exec_spa, 'Available Pipeline Capacity');
	}
	
	open_nom_schedule_window = function(flow_date_start, flow_date_end, from_location, to_location, path_ids) {
		from_location = from_location + ',' + to_location
		
		var args = '?flow_date=' + flow_date_start + '&flow_date_end=' + flow_date_end + '&from_to_location=' + from_location + '&path_ids=' + path_ids;
		parent.parent.open_menu_window("_scheduling_delivery/gas/view_nom_schedules/view.nom.schedules.php" + args, "windowSchedulesView", "View Nomination Schedules");
	}
	
	grid_db_click = function(rId,cInd) {
		var selected_row = available_pipeline_capacity.available_pipeline_capacity_grid.getSelectedRowId();
        var state = available_pipeline_capacity.available_pipeline_capacity_grid.getOpenState(selected_row);
        
        if (state)
            available_pipeline_capacity.available_pipeline_capacity_grid.closeItem(selected_row);
        else
            available_pipeline_capacity.available_pipeline_capacity_grid.openItem(selected_row);
	}

	function turn_on_progress(mode) {
		if (mode) {
			available_pipeline_capacity.available_pipeline_capacity_layout.cells(grid_cell_id).progressOn();
		} else {
			available_pipeline_capacity.available_pipeline_capacity_layout.cells(grid_cell_id).progressOff();
		}
	}
            
</script> 
