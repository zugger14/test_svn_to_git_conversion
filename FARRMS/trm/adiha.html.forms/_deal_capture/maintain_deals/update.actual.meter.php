<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <style type="text/css">
        html, body {
            width: 100%;
            height: 100%;
            margin: 0px;
            padding: 0px;
            background-color: #ebebeb;
            overflow: hidden;
        }
    </style>
</head>
<body>
	<?php 
		include '../../../adiha.php.scripts/components/include.file.v3.php';
		$form_namespace = 'updateActualMeter';
		
		$deal_id = (isset($_POST["deal_id"]) && $_POST["deal_id"] != '') ? get_sanitized_value($_POST["deal_id"]) : 'NULL';
		$detail_id = (isset($_POST["detail_id"]) && $_POST["detail_id"] != '') ? get_sanitized_value($_POST["detail_id"]) : 'NULL';
		$meter_id = (isset($_POST["meter_id"]) && $_POST["meter_id"] != '') ? get_sanitized_value($_POST["meter_id"]) : 'NULL';
		$term_start = (isset($_POST["term_start"]) && $_POST["term_start"] != '') ? get_sanitized_value($_POST["term_start"]) : 'NULL';
		$term_end = (isset($_POST["term_end"]) && $_POST["term_end"] != '') ? get_sanitized_value($_POST["term_end"]) : 'NULL';
		$location_id = (isset($_POST["location_id"]) && $_POST["location_id"] != '') ? get_sanitized_value($_POST["location_id"]) : 'NULL';
		$call_from = (isset($_POST["call_from"]) && $_POST["call_from"] != '') ? get_sanitized_value($_POST["call_from"]) : 'NULL';

		$sp_grid = "EXEC spa_update_actual_meter @flag='s', @source_deal_detail_id=" . $detail_id . ", @source_deal_header_id=" . $deal_id . ",@channel=1, @location_id=" . $location_id . ", @term_start='" . $term_start . "', @term_end='" . $term_end . "', @meter_ids=" . $meter_id;

		$data = readXMLURL2($sp_grid);
		
		$granularity = $data[0]['granularity'];
		$max_channel = $data[0]['max_channel'];
		$term_start = $data[0]['term_start'];
		$term_end = $data[0]['term_end'];
		$process_id = $data[0]['process_id'];
		$min_term_start = $data[0]['min_term_start'];
		$max_term_end = $data[0]['max_term_end'];
		$is_locked = $data[0]['is_locked'];
		$dst_term = $data[0]['dst_term'];
		// $meter_id = ($meter_id == 'NULL') ? $data[0][meter_id] : $meter_id;
		$meter_id_final = $data[0]['meter_id'];

		//982, 989, 987, 994
		if ($granularity == 982 || $granularity == 989 || $granularity == 987 || $granularity == 994 || $granularity == 995) {
			$show_hour = true;
		} else {
			$show_hour = false;
		}
		
		
		$layout_json = '[{id: "a", text:"Filter",header:true,height:100},{id: "b", header:false}]';
						  
		$layout_obj = new AdihaLayout();
		$form_obj = new AdihaForm();

		$sp_url1 = "EXEC spa_update_actual_meter @flag='x', @source_deal_detail_id=" . $detail_id . ", @source_deal_header_id=" . $deal_id . ",@channel=1";
		$meter_json = $form_obj->adiha_form_dropdown($sp_url1, 0, 1, true, $meter_id);
	
		$sp_url = "EXEC('Select n id, n name from seq WHERE n <= " . $max_channel . "')";
		$channel_json = $form_obj->adiha_form_dropdown($sp_url, 0, 1, false, 1);

		
		if($granularity == 982 ) {
			$sp_url = "EXEC('Select n id, n name from seq WHERE n <= 24')";
		} else {
			$sp_url = "EXEC('Select n-1 id, n-1 name from seq WHERE n <= 25')";
		}
		$hr_json = $form_obj->adiha_form_dropdown($sp_url, 0, 1, true);

		$form_json = '[ 
						{"type": "settings", "position": "label-top", "offsetLeft": 10, inputWidth:150},
						{type:"combo", name:"meter", "options": ' . $meter_json . ' ,label:"Meter", required:false, "comboType": "combo", "value":"' . $meter_id . '"},
						{"type":"newcolumn"},
						{"type": "calendar", "validate":"NotEmptywithSpace", required:true, "userdata":{"validation_message":"Required Field"}, "dateFormat":"' . $date_format . '", "serverDateFormat": "%Y-%m-%d", "name": "term_start", "label": "Term Start", "enableTime": false, "calendarPosition": "bottom", "value":"' . $term_start . '"},
					    {"type":"newcolumn"},
					    {"type": "calendar", "validate":"NotEmptywithSpace", required:true, "userdata":{"validation_message":"Required Field"}, "dateFormat":"' . $date_format . '", "serverDateFormat": "%Y-%m-%d", "name": "term_end", "label": "Term End", "enableTime": false, "calendarPosition": "bottom", "value":"' . $term_end . '"},
						{"type":"newcolumn"},
						{type:"combo", name:"channel", "options": ' . $channel_json . ' ,label:"Channel", required:false, "offsetLeft":"10"},
						{type: "hidden", name:"process_id", value:"' . $process_id . '"}
						';
			if ($show_hour) {
				$form_json .= ',{"type":"newcolumn"},						
								{type:"combo", name:"hr_from", "options": ' . $hr_json . ' ,label:"Interval Start", required:false, "offsetLeft":"10"},
								{"type":"newcolumn"},
								{type:"combo", name:"hr_to", "options": ' . $hr_json . ' ,label:"Intervale End", required:false, "offsetLeft":"10"}
								';
			}
			
			$form_json .= ']';

		echo $layout_obj->init_layout('layout', '', '2E', $layout_json, $form_namespace);
		echo $layout_obj->attach_form('form', 'a');
		
		echo $form_obj->init_by_attach('form', $form_namespace);
		echo $form_obj->load_form($form_json);
		echo $form_obj->attach_event('', 'onChange', $form_namespace . '.form_change');
		
		$menu_json = '[
						{id:"refresh", text:"refresh", img:"refresh.gif", title:"Refresh", enabled:true},
						{id:"t2", text:"Export", img:"export.gif", items:[
							{id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
							{id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
						]},
						{id:"save", text:"Save", img: "save.gif", imgdis: "save_dis.gif", title: "Save"} 		
					  ]';
		$menu_object = new AdihaMenu();
		echo $layout_obj->attach_menu_cell('menu', 'b');
		echo $menu_object->init_by_attach('menu', $form_namespace);
		echo $menu_object->load_menu($menu_json);
		echo $menu_object->attach_event('', 'onClick', $form_namespace . '.menu_click');
		
		echo $layout_obj->attach_status_bar("b", true);
		echo $layout_obj->close_layout();
	?>
</body>
<textarea style="display:none" name="txt_vol" id="txt_vol"><?php echo $volume;?></textarea>
<textarea style="display:none" name="txt_price" id="txt_price"><?php echo $price;?></textarea>
<textarea style="display:none" name="txt_process" id="txt_process"><?php echo $process_id;?></textarea>
<script type="text/javascript">
	var save_flag = 'n';
	var granularity = '<?php echo $granularity;?>';
	var dst_term = '<?php echo $dst_term;?>';
	var process_id_start = '<?php echo $process_id; ?>';
	var meter_id = '<?php echo $meter_id; ?>';
	var meter_id_final = '<?php echo $meter_id_final; ?>';
	var location_id = '<?php echo $location_id; ?>';
	var call_from = '<?php echo $call_from; ?>';
	var source_deal_header_id = '<?php echo $deal_id; ?>';
	var detail_id = '<?php echo $detail_id; ?>';
	var term_start = '<?php echo $term_start; ?>';
	var term_end = '<?php echo $term_end; ?>';

	$(function() {
		var is_locked = '<?php echo $is_locked;?>';

		if (call_from = 'deal_detail') {
			data = {"action": "spa_update_actual_meter", "flag":"c", "meter_id": meter_id, "source_deal_header_id": source_deal_header_id, "location_id": location_id};
        	adiha_post_data("return_array", data, '', '', function(return_array) {
        		if (return_array.length == 0) {
        			dhtmlx.alert({
						title:"Error",
						type:"alert-error",
						text:"Meter is not defined in location.",
						callback: function(result){
							var win_obj = window.parent.update_actual_window.window("w1");
							win_obj.close();
						}
					});
					return;
        		} else if (return_array[0][1] == '' || return_array[0][1] == undefined || return_array[0][1] == null) {
        			dhtmlx.alert({
						title:"Error",
						type:"alert-error",
						text:"Actualize granularity is not defined in template.",
						callback: function(result){
							var win_obj = window.parent.update_actual_window.window("w1");
							win_obj.close();
						}
					});
					return;
        		}

        		var combo_object = updateActualMeter.form.getCombo('meter');
				var combo_param = {"action": "spa_update_actual_meter", "flag":'b', "has_blank_option": false, "meter_id": meter_id, "source_deal_header_id": source_deal_header_id, "location_id": location_id};
	            combo_param = $.param(combo_param);
	            var url = js_dropdown_connector_url + '&' + combo_param;
	            combo_object.clearAll();
	            combo_object.load(url, function() {
	            	// if (meter_id == '' || meter_id == 'NULL') {
	            		combo_object.selectOption(0);
	            		combo_object.setChecked(0, true);
	            	// }
	            	updateActualMeter.load_grid();
					updateActualMeter.menu.setItemDisabled('save');
	            });
        	});
		} else {
			updateActualMeter.load_grid();
		}

		if (is_locked == 'y') {
			updateActualMeter.menu.setItemDisabled('save');
		}

		var min_term = '<?php echo $min_term_start;?>';
		var max_term = '<?php echo $max_term_end;?>';
		var from_cal = updateActualMeter.form.getCalendar('term_start');
		var to_cal = updateActualMeter.form.getCalendar('term_end');
		from_cal.setSensitiveRange(min_term, max_term);
		to_cal.setSensitiveRange(min_term, max_term);
	});
	
	/**
     * [menu_click Form Menu click function]
     * @param  {[type]} id [menu id]
     */
	updateActualMeter.menu_click = function(id) {
		switch(id) {
			case 'refresh':
				updateActualMeter.save_changes('refresh');
				break;
			case "pdf":
				updateActualMeter.grid.toPDF(js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
				break;
			case "excel":
				updateActualMeter.grid.toPDF(js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
				break;
			case 'save':
				updateActualMeter.save_changes('save');
				break;				
		}
	}
	
	/**
     * [save_changes Save changed data]
     * @param  {[type]} call_from [call from flag]
     */
	updateActualMeter.save_changes = function(call_from) {
		updateActualMeter.layout.cells('b').progressOn();
		updateActualMeter.grid.clearSelection();
		var meter_combo = updateActualMeter.form.getCombo('meter');
		var meter_ids = meter_combo.getSelectedValue();
		var sp_grid = {
						'action' : 'spa_update_actual_meter', 
						'flag' : 's', 
						'source_deal_header_id' : source_deal_header_id,
						'source_deal_detail_id' : detail_id,
						'term_start' : term_start,
						'term_end' : term_end,
						'location_id': location_id,
						'meter_ids': meter_ids,
						'channel': 1
					};
		adiha_post_data('return_json', sp_grid, '', '', function(return_json) {
			return_json = JSON.parse(return_json);
			var process_id = return_json[0].process_id;

			var changed_rows = updateActualMeter.grid.getChangedRows(true);
		
			if (changed_rows != '' && call_from == 'save') {
				var grid_xml = '<GridXML>';
	            var changed_ids = new Array();
	            changed_ids = changed_rows.split(",");
	            $.each(changed_ids, function(index, value) {
	                grid_xml += '<GridRow ';
	                for(var cellIndex = 0; cellIndex < updateActualMeter.grid.getColumnsNum(); cellIndex++){
	                    var column_id = updateActualMeter.grid.getColumnId(cellIndex);
	                    var cell_value = updateActualMeter.grid.cells(value, cellIndex).getValue();
						if (column_id == 'prod_date') {
							cell_value = dates.convert_to_sql(cell_value);
						}
	                    grid_xml += ' col_' + column_id + '="' + cell_value + '"';
	                }
	                grid_xml += '></GridRow>';
	            });
	            grid_xml += '</GridXML>';

				if (process_id == undefined || process_id == '' || process_id == null) {
					process_id = (updateActualMeter.form.getItemValue('process_id') == '') ? 'NULL' : updateActualMeter.form.getItemValue('process_id');
				} else {
					updateActualMeter.form.setItemValue('process_id', process_id);
				}
				
				data = {
						'action' : 'spa_update_actual_meter', 
						'flag' : 'u', 
						'xml' : grid_xml,
						'source_deal_header_id' : source_deal_header_id,
						'source_deal_detail_id' : detail_id,
						'process_id': process_id
					};
				
				if (call_from == 'save')
					save_flag = 'y';
				else 
					save_flag = 'n';
				
	            adiha_post_data("return", data, '', '', 'updateActualMeter.save_temp_callback');
			} else {
				if (call_from == 'refresh')
					updateActualMeter.load_grid(process_id);
				else 
					updateActualMeter.save_data();
			}
		});
	}
	
	/**
     * [save_temp_callback Save callback for temporary table]
     * @param  {[type]} result [returned array]
     */
	updateActualMeter.save_temp_callback = function(result) {
		if (result[0].errorcode == 'Success') {
			if (save_flag == 'y') {
				updateActualMeter.save_data();
				save_flag = 'n';
			} else {
				updateActualMeter.load_grid();
			}
        }
	}
	
	/**
     * [save_data Save data]
     */
	updateActualMeter.save_data = function() {
		var deal_id = '<?php echo $deal_id;?>';
		var detail_id = '<?php echo $detail_id;?>';		
		var process_id = (updateActualMeter.form.getItemValue('process_id') == '') ? 'NULL' : updateActualMeter.form.getItemValue('process_id');
		
		data = {'action' : 'spa_update_actual_meter', 
				'flag' : 'v', 
				'source_deal_header_id' : deal_id,
				'source_deal_detail_id' : detail_id,
				'process_id':process_id
		};
		adiha_post_data("alert", data, '', '', 'updateActualMeter.save_callback');
	}
	
	/**
     * [save_callback Save callback]
	 * @param  {[type]} result [returned array]
	 */
	updateActualMeter.save_callback = function(result) {
		updateActualMeter.layout.cells('b').progressOff();
		if (result[0].errorcode == 'Success') {
			if (result[0].recommendation != '' && result[0].recommendation != null) {
                var ret_val = result[0].recommendation;
                var vol = '';
                var price = '';

                if (ret_val.indexOf("::") !== -1) {
                    var ret_arr = new Array();
                    ret_arr = ret_val.split("::");
                    vol = ret_arr[0];
                    price = ret_arr[1];
                } else {
                    vol = ret_val;
                }
                document.getElementById("txt_vol").value = vol;
                document.getElementById("txt_price").value = price;
            }
			updateActualMeter.load_grid();
        }
	}
	
	/**
     * [form_change Form Change callback]
     * @param  {[type]} name [item name]
     */
    updateActualMeter.form_change = function(name, value) {
        var term_start = updateActualMeter.form.getItemValue("term_start", true);
        var term_end = updateActualMeter.form.getItemValue("term_end", true);
		var min_max_val = (name == 'term_start') ? term_end : term_start;
		
        if (dates.compare(term_end, term_start) == -1) {
            if (name == 'term_start') {
                updateActualMeter.form.setItemValue('term_end', term_start);
				return;
            } else {
                var message = 'Term End cannot be greater than Term Start.';
            }
            updateActualMeter.show_error(message, name, min_max_val);
            return;
        }
    }
	
	/**
     * [show_error Show Error]
     * @param  {[string]} message     [Message]
     * @param  {[string]} name        [Item name]
     * @param  {[date]} min_max_val   [Date]
     */
    updateActualMeter.show_error = function(message, name, min_max_val) {
        dhtmlx.alert({
            title:"Error",
            type:"alert-error",
            text:message,
            callback: function(result){
                updateActualMeter.form.setItemValue(name, min_max_val);
            }
        });
    }
	
	/**
     * [load_grid Load Grid]
     */
	updateActualMeter.load_grid = function(process_id) {
		updateActualMeter.layout.cells('b').progressOn();
		var term_start = updateActualMeter.form.getItemValue("term_start", true);
        var term_end = updateActualMeter.form.getItemValue("term_end", true);
        var meter_combo = updateActualMeter.form.getCombo('meter');
		var meter_ids = meter_combo.getSelectedValue();
		var channel = updateActualMeter.form.getItemValue("channel");
		var show_hour = Boolean('<?php echo $show_hour; ?>');
		if (process_id == undefined || process_id == '' || process_id == null)
			process_id = (updateActualMeter.form.getItemValue('process_id') == '') ? 'NULL' : updateActualMeter.form.getItemValue('process_id');
		var hr_from = 'NULL';
		var hr_to = 'NULL';
		
		if (show_hour) {
			var hr_from = (updateActualMeter.form.getItemValue('hr_from') == '') ? 'NULL' : updateActualMeter.form.getItemValue('hr_from');
			var hr_to = (updateActualMeter.form.getItemValue('hr_to') == '') ? 'NULL' : updateActualMeter.form.getItemValue('hr_to');
		}
		
		data = {'action' : 'spa_update_actual_meter', 
				'flag' : 't', 
				'source_deal_header_id' : source_deal_header_id,
				'source_deal_detail_id' : detail_id,
				'term_start' : term_start,
				'term_end' : term_end,
				'hour_from':hr_from,
				'hour_to':hr_to,
				'meter_ids':meter_ids,
				'process_id':process_id,
				'channel':channel
			};
	   adiha_post_data('return', data, '', '', 'updateActualMeter.load_grid_callback');
		
		
	}
	
	/**
     * [load_grid_callback Load Grid Callback - create grid]
     */
	updateActualMeter.load_grid_callback = function(result) {		
		var show_hour = Boolean('<?php echo $show_hour; ?>');
		if (updateActualMeter.grid) {
			updateActualMeter.grid.destructor();
		}
		updateActualMeter.grid = updateActualMeter.layout.cells('b').attachGrid();
		updateActualMeter.grid.setImagePath(js_image_path + "dhxgrid_web/");
        updateActualMeter.grid.setPagingWTMode(true,true,true,true);
        updateActualMeter.grid.enablePaging(true, 50, 0, 'pagingArea_b'); 
        updateActualMeter.grid.setPagingSkin('toolbar');
		
		updateActualMeter.grid.setHeader(result[0].column_label);
		updateActualMeter.grid.setColumnIds(result[0].column_list);
		updateActualMeter.grid.setColTypes(result[0].column_type);
		updateActualMeter.grid.setInitWidths(result[0].column_width);
		updateActualMeter.grid.setDateFormat(user_date_format,'%Y-%m-%d');
		if (show_hour) {
			updateActualMeter.grid.splitAt(5);
		} else {
			updateActualMeter.grid.splitAt(4);
		}
		updateActualMeter.grid.init();		
		updateActualMeter.grid.setColumnsVisibility(result[0].visibility);
		updateActualMeter.grid.enableEditEvents(true,false,true);
		updateActualMeter.grid.attachEvent("onEditCell", function(stage,rId,cInd,nValue,oValue){
			var column_id = updateActualMeter.grid.getColumnId(cInd);
			if (column_id.indexOf('25') == 0) {
				if (dst_term != '') {
			    	var term_index = updateActualMeter.grid.getColIndexById('prod_date');
				    var term_date = updateActualMeter.grid.cells(rId, term_index).getValue();
					
					if (dates.compare(term_date, dst_term) != 0) {
			        	return false;
				    }
				}
			}
			return true;
		});
		var meter_combo = updateActualMeter.form.getCombo('meter');
		var meter_ids = meter_combo.getSelectedValue();
		var term_start = updateActualMeter.form.getItemValue("term_start", true);
        var term_end = updateActualMeter.form.getItemValue("term_end", true);
		var channel = updateActualMeter.form.getItemValue("channel");

		var process_id_final = result[0].process_id;

		if (process_id_final == '' || process_id_final == undefined || process_id_final == null) {
			process_id_final = (updateActualMeter.form.getItemValue('process_id') == '') ? 'NULL' : updateActualMeter.form.getItemValue('process_id');
		}
		
		var hr_from = 'NULL';
		var hr_to = 'NULL';
		
		if (show_hour) {
			var hr_from = (updateActualMeter.form.getItemValue('hr_from') == '') ? 'NULL' : updateActualMeter.form.getItemValue('hr_from');
			var hr_to = (updateActualMeter.form.getItemValue('hr_to') == '') ? 'NULL' : updateActualMeter.form.getItemValue('hr_to');
		}

		param = {
				'action' : 'spa_update_actual_meter', 
				'flag' : 'a', 
				'source_deal_header_id' : source_deal_header_id,
				'source_deal_detail_id' : detail_id,
				'meter_ids': meter_ids,
				'term_start' : term_start,
				'term_end' : term_end,
				'hour_from' : hr_from,
				'hour_to' : hr_to,
				'process_id' : process_id_final,
				'channel' : channel
			};

		param = $.param(param);

		var refresh_url = js_data_collector_url + '&' + param;
		updateActualMeter.grid.loadXML(refresh_url, function() {
        	if (updateActualMeter.grid.getRowsNum() < 1) {
        		updateActualMeter.save_changes('refresh');
        	} else {
        		updateActualMeter.layout.cells('b').progressOff();
        	}
		});	
		save_flag = 'y';
	}
</script>
</html>