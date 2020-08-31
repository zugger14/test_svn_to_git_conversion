<?php
/**
* Update actual screen
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
		$form_namespace = 'updateActual';
		
		$deal_id = (isset($_POST["deal_id"]) && $_POST["deal_id"] != '') ? get_sanitized_value($_POST["deal_id"]) : 'NULL';
		$detail_id = (isset($_POST["detail_id"]) && $_POST["detail_id"] != '') ? get_sanitized_value($_POST["detail_id"]) : 'NULL';
		$granularity = (isset($_POST["granularity"]) && $_POST["granularity"] != '') ? get_sanitized_value($_POST["granularity"]) : 'NULL';
		$sp_grid = "EXEC spa_update_actual @flag='s', @source_deal_detail_id=" . $detail_id . ", @source_deal_header_id=" . $deal_id . ", @granularity = " . $granularity;
		$data = readXMLURL2($sp_grid);
		
		//$granularity = $data[0][granularity];
		$max_leg = $data[0]['max_leg'];
		$term_start = $data[0]['term_start'];
		$term_end = $data[0]['term_end'];
		$process_id = $data[0]['process_id'];
		$min_term_start = $data[0]['min_term_start'];
		$max_term_end = $data[0]['max_term_end'];
		$is_locked = $data[0]['is_locked'];
		$dst_term = $data[0]['dst_term'];
		
		$term_start = get_sanitized_value($_POST["term_start"] ?? $term_start);
		$term_end = get_sanitized_value($_POST["term_end"] ?? $term_end);
		$leg = get_sanitized_value($_POST["leg"] ?? '');

		//982, 989, 987, 994
		if ($granularity == 982 || $granularity == 989 || $granularity == 987 || $granularity == 994) {
			$show_hour = true;
		} else {
			$show_hour = false;
		}
		
		
		$layout_json = '[{id: "a", text:"Filter",header:true,height:100},{id: "b", header:false}]';
						  
		$layout_obj = new AdihaLayout();
		$form_obj = new AdihaForm();
		
		$sp_url = "EXEC('Select n id, n name from seq WHERE n <= " . $max_leg . "')";
		$leg_json = $form_obj->adiha_form_dropdown($sp_url, 0, 1, true, $leg);
		if($granularity == 982) 
			$sp_url = "EXEC('Select n id, n name from seq WHERE n <= 24')";
		else
			$sp_url = "EXEC('Select n-1 id, n-1 name from seq WHERE n <= 25')";

		$hr_json = $form_obj->adiha_form_dropdown($sp_url, 0, 1, true);

		$form_json = '[ 
						{"type": "settings", "position": "label-top", "offsetLeft": 10, inputWidth:150},
						{"type": "calendar", "validate":"NotEmptywithSpace", required:true, "userdata":{"validation_message":"Required Field"}, "dateFormat":"' . $date_format . '", "serverDateFormat": "%Y-%m-%d", "name": "term_start", "label": "Term Start", "enableTime": false, "calendarPosition": "bottom", "value":"' . $term_start . '"},
					    {"type":"newcolumn"},
					    {"type": "calendar", "validate":"NotEmptywithSpace", required:true, "userdata":{"validation_message":"Required Field"}, "dateFormat":"' . $date_format . '", "serverDateFormat": "%Y-%m-%d", "name": "term_end", "label": "Term End", "enableTime": false, "calendarPosition": "bottom", "value":"' . $term_end . '"},
						{"type":"newcolumn"},
						{type:"combo", name:"leg", "options": ' . $leg_json . ' ,label:"Leg", required:false, "offsetLeft":"10"},
						{type: "hidden", name:"process_id", value:"' . $process_id . '"}
						';
			if ($show_hour) {
				$form_json .= ',{"type":"newcolumn"},						
								{type:"combo", name:"hr_from", "options": ' . $hr_json . ' ,label:"Interval Start", required:false, "offsetLeft":"10"},
								{"type":"newcolumn"},
								{type:"combo", name:"hr_to", "options": ' . $hr_json . ' ,label:"Interval End", required:false, "offsetLeft":"10"}
								';
			}
			
			$form_json .= ']';

		echo $layout_obj->init_layout('layout', '', '2E', $layout_json, $form_namespace);
		echo $layout_obj->attach_form('form', 'a');
		
		echo $form_obj->init_by_attach('form', $form_namespace);
		echo $form_obj->load_form($form_json);
		echo $form_obj->attach_event('', 'onChange', $form_namespace . '.form_change');
		
		$menu_json = '[
						{id:"refresh", text:"Refresh", img:"refresh.gif", title:"Refresh", enabled:true},
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
<script type="text/javascript">
	var save_flag = 'n';
	var granularity = '<?php echo $granularity;?>';
	var dst_term = '<?php echo $dst_term;?>';
	$(function() {
		var is_locked = '<?php echo $is_locked;?>';
		if (is_locked == 'y') {
			updateActual.menu.setItemDisabled('save');
		}
		
		if (granularity == '') {
			show_messagebox("Actualize granularity is not defined in template.", function() {
				var win_obj = window.parent.update_actual_window.window("w1");
				win_obj.close();
			});
			return;
		}
		var min_term = '<?php echo $min_term_start;?>';
		var max_term = '<?php echo $max_term_end;?>';
		var from_cal = updateActual.form.getCalendar('term_start');
		var to_cal = updateActual.form.getCalendar('term_end');
		from_cal.setSensitiveRange(min_term, max_term);
		to_cal.setSensitiveRange(min_term, max_term);
		
		updateActual.load_grid();
	});
	
	/**
     * [menu_click Form Menu click function]
     * @param  {[type]} id [menu id]
     */
	updateActual.menu_click = function(id) {
		switch(id) {
			case 'refresh':
				updateActual.save_changes('refresh');
				break;
			case "pdf":
				updateActual.grid.toPDF(js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
				break;
			case "excel":
				updateActual.grid.toPDF(js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
				break;
			case 'save':
				updateActual.save_changes('save');
				break;				
		}
	}
	
	/**
     * [save_changes Save changed data]
     * @param  {[type]} call_from [call from flag]
     */
	updateActual.save_changes = function(call_from) {
		updateActual.grid.clearSelection();
		var changed_rows = updateActual.grid.getChangedRows(true);
		
		if (changed_rows != '') {
			var grid_xml = '<GridXML>';
            var changed_ids = new Array();
            changed_ids = changed_rows.split(",");
            $.each(changed_ids, function(index, value) {
                grid_xml += '<GridRow ';
                for(var cellIndex = 0; cellIndex < updateActual.grid.getColumnsNum(); cellIndex++){
                    var column_id = updateActual.grid.getColumnId(cellIndex);
                    var cell_value = updateActual.grid.cells(value, cellIndex).getValue();
					if (column_id == 'term_date') {
						cell_value = dates.convert_to_sql(cell_value);
					}
                    grid_xml += ' col_' + column_id + '="' + cell_value + '"';
                }
                grid_xml += '></GridRow>';
            });
            grid_xml += '</GridXML>';
			
			var deal_id = '<?php echo $deal_id;?>';
			var detail_id = '<?php echo $detail_id;?>';		
			var process_id = (updateActual.form.getItemValue('process_id') == '') ? 'NULL' : updateActual.form.getItemValue('process_id');
			
			data = {'action' : 'spa_update_actual', 
					'flag' : 'u', 
					'xml' : grid_xml,
					'source_deal_header_id' : deal_id,
					'source_deal_detail_id' : detail_id,
					'process_id':process_id,
					'granularity': granularity
			};
			
			if (call_from == 'save')
				save_flag = 'y';
			else 
				save_flag = 'n';
			
            adiha_post_data("return", data, '', '', 'updateActual.save_temp_callback');
		} else {
			if (call_from == 'refresh')
				updateActual.load_grid();
			else 
				updateActual.save_data();
		}
	}
	
	/**
     * [save_temp_callback Save callback for temporary table]
     * @param  {[type]} result [returned array]
     */
	updateActual.save_temp_callback = function(result) {
		if (result[0].errorcode == 'Success') {
			if (save_flag == 'y') {
				updateActual.save_data();
				save_flag = 'n';
			} else {
				updateActual.load_grid();
			}
        }
	}
	
	/**
     * [save_data Save data]
     */
	updateActual.save_data = function() {
		var deal_id = '<?php echo $deal_id;?>';
		var detail_id = '<?php echo $detail_id;?>';		
		var process_id = (updateActual.form.getItemValue('process_id') == '') ? 'NULL' : updateActual.form.getItemValue('process_id');
		
		data = {'action' : 'spa_update_actual', 
				'flag' : 'v', 
				'source_deal_header_id' : deal_id,
				'source_deal_detail_id' : detail_id,
				'process_id':process_id,
				'granularity': granularity
		};
		updateActual.layout.cells('b').progressOn();
		adiha_post_data("alert", data, '', '', 'updateActual.save_callback');
	}
	
	/**
     * [save_callback Save callback]
	 * @param  {[type]} result [returned array]
	 */
	updateActual.save_callback = function(result) {
		updateActual.layout.cells('b').progressOff();
		if (result[0].errorcode == 'Success') {
			updateActual.load_grid();
        }
	}
	
	/**
     * [form_change Form Change callback]
     * @param  {[type]} name [item name]
     */
    updateActual.form_change = function(name, value) {
        var term_start = updateActual.form.getItemValue("term_start", true);
        var term_end = updateActual.form.getItemValue("term_end", true);
		var min_max_val = (name == 'term_start') ? term_end : term_start;
		
        if (dates.compare(term_end, term_start) == -1) {
            if (name == 'term_start') {
                updateActual.form.setItemValue('term_end', term_start);
				return;
            } else {
                var message = 'Term End cannot be greater than Term Start.';
            }
            updateActual.show_error(message, name, min_max_val);
            return;
        }
    }
	
	/**
     * [show_error Show Error]
     * @param  {[string]} message     [Message]
     * @param  {[string]} name        [Item name]
     * @param  {[date]} min_max_val   [Date]
     */
    updateActual.show_error = function(message, name, min_max_val) {
        show_messagebox(message, function() {
			updateActual.form.setItemValue(name, min_max_val);
		});
    }
	
	/**
     * [load_grid Load Grid]
     */
	updateActual.load_grid = function() {
		updateActual.layout.cells('b').progressOn();
		var term_start = updateActual.form.getItemValue("term_start", true);
        var term_end = updateActual.form.getItemValue("term_end", true);
		var leg = updateActual.form.getItemValue("leg");
		var show_hour = Boolean('<?php echo $show_hour; ?>');
		var process_id = (updateActual.form.getItemValue('process_id') == '') ? 'NULL' : updateActual.form.getItemValue('process_id');
		
		var hr_from = 'NULL';
		var hr_to = 'NULL';
		
		var deal_id = '<?php echo $deal_id;?>';
		var detail_id = '<?php echo $detail_id;?>';
		
		if (show_hour) {
			var hr_from = (updateActual.form.getItemValue('hr_from') == '') ? 'NULL' : updateActual.form.getItemValue('hr_from');
			var hr_to = (updateActual.form.getItemValue('hr_to') == '') ? 'NULL' : updateActual.form.getItemValue('hr_to');
		}
		
		data = {'action' : 'spa_update_actual', 
				'flag' : 't', 
				'source_deal_header_id' : deal_id,
				'source_deal_detail_id' : detail_id,
				'term_start' : term_start,
				'term_end' : term_end,
				'hour_from':hr_from,
				'hour_to':hr_to,
				'process_id':process_id,
				'granularity':granularity
			};
	   adiha_post_data('return', data, '', '', 'updateActual.load_grid_callback');
		
		
	}
	
	/**
     * [load_grid_callback Load Grid Callback - create grid]
     */
	updateActual.load_grid_callback = function(result) {		
		var show_hour = Boolean('<?php echo $show_hour; ?>');
		if (updateActual.grid) {
			updateActual.grid.destructor();
		}
		updateActual.grid = updateActual.layout.cells('b').attachGrid();
		updateActual.grid.setImagePath(js_image_path + "dhxgrid_web/");
        updateActual.grid.setPagingWTMode(true,true,true,true);
        updateActual.grid.enablePaging(true, 50, 0, 'pagingArea_b'); 
        updateActual.grid.setPagingSkin('toolbar');
		
		updateActual.grid.setHeader(result[0].column_label);
		updateActual.grid.setColumnIds(result[0].column_list);
		updateActual.grid.setColTypes(result[0].column_type);
		updateActual.grid.setInitWidths(result[0].column_width);
		updateActual.grid.setDateFormat(user_date_format,'%Y-%m-%d');
		
		var split_at;
        if (show_hour) {
            split_at = 5;
        } else {
            split_at = 4;
        }
		updateActual.grid.splitAt(split_at);

		updateActual.grid.init();		
		updateActual.grid.setColumnsVisibility(result[0].visibility);
		updateActual.grid.enableEditEvents(true,false,true);
		
		updateActual.grid.attachEvent("onEditCell", function(stage,rId,cInd,nValue,oValue){
			
	/*		if (stage == 0) {
				var type_index = updateActual.grid.getColIndexById('type');
				var type = updateActual.grid.cells(rId, type_index).getValue();
				var column_id = updateActual.grid.getColumnId(cInd);
				if (type == 'v') return false;
			} else return true*/

			var column_id = updateActual.grid.getColumnId(cInd);
			var type_index = updateActual.grid.getColIndexById('type');
			var type = updateActual.grid.cells(rId, type_index).getValue();
			if (column_id.indexOf('DST') != -1) {
				if (dst_term != '') {
               		var term_index = updateActual.grid.getColIndexById('term_date');
	               	var term_date = updateActual.grid.cells(rId, term_index).getValue();
	               	if (dates.compare(term_date, dst_term) != 0) {
                   		return false;
	               	}
		 		}
			}

			return true;
		});
		
		updateActual.grid.attachEvent("onBeforeContextMenu", function(id, ind, obj) {
            updateActual.grid.selectRowById(id);
            return !(ind < split_at);
        });
		
		var term_start = updateActual.form.getItemValue("term_start", true);
        var term_end = updateActual.form.getItemValue("term_end", true);
		var leg = updateActual.form.getItemValue("leg");
		var process_id = (updateActual.form.getItemValue('process_id') == '') ? 'NULL' : updateActual.form.getItemValue('process_id');
		
		var hr_from = 'NULL';
		var hr_to = 'NULL';
		
		var deal_id = '<?php echo $deal_id;?>';
		var detail_id = '<?php echo $detail_id;?>';
		
		if (show_hour) {
			var hr_from = (updateActual.form.getItemValue('hr_from') == '') ? 'NULL' : updateActual.form.getItemValue('hr_from');
			var hr_to = (updateActual.form.getItemValue('hr_to') == '') ? 'NULL' : updateActual.form.getItemValue('hr_to');
		}
		
		param = {
			'action' : 'spa_update_actual', 
			'flag' : 'a',
			'source_deal_header_id' : deal_id,
			'source_deal_detail_id' : detail_id,
			'term_start' : term_start,
			'term_end' : term_end,
			'hour_from':hr_from,
			'hour_to':hr_to,
			'process_id':process_id,
			'granularity': granularity,
			'leg': (leg == '') ? 'NULL' : leg
		};

		param = $.param(param);
		var refresh_url = js_data_collector_url + '&' + param;
		updateActual.grid.loadXML(refresh_url);
        updateActual.layout.cells('b').progressOff();		
		save_flag = 'y';

		var context_menu = new dhtmlXMenuObject();
        context_menu.renderAsContextMenu();
        var menu_obj = [
            {id: "apply_to_all", text: "Apply To All"}
        ];
        context_menu.loadStruct(menu_obj);
        updateActual.grid.enableContextMenu(context_menu);

        context_menu.attachEvent("onClick", function(menu_item_id) {
            switch(menu_item_id) {
                case "apply_to_all":
                    // Grid contextID provides row id and column index in array
                    var data = updateActual.grid.contextID.split("_");
                    var col_ind = data[data.length -1];
                    var row_id = updateActual.grid.getSelectedRowId();

                    var cell_value = updateActual.grid.cells(row_id, col_ind).getValue();
                    updateActual.grid.forEachCell(row_id, function(cell_obj, ind) {
                        if (ind > split_at - 1 && ind != col_ind) {
                            cell_obj.setValue(cell_value);
                        }
                    });
                    break;
                default:
                    break;
            }
        });
	}
</script>
</html>