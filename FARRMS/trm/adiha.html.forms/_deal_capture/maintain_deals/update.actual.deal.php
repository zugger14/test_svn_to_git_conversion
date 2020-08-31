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
		$form_namespace = 'updateActualDeal';
		
		$deal_id = (isset($_POST["deal_id"]) && $_POST["deal_id"] != '') ? get_sanitized_value($_POST["deal_id"]) : 'NULL';
		$detail_id = (isset($_POST["detail_id"]) && $_POST["detail_id"] != '') ? get_sanitized_value($_POST["detail_id"]) : 'NULL';
		
		$sp_grid = "EXEC spa_update_actual_deal @flag='s', @source_deal_detail_id=" . $detail_id . ", @source_deal_header_id=" . $deal_id;
		$data = readXMLURL2($sp_grid);
		
		$granularity = $data[0]['granularity'];
		$max_leg = $data[0]['max_leg'];
		$term_start = $data[0]['term_start'];
		$term_end = $data[0]['term_end'];
		$process_id = $data[0]['process_id'];
		$min_term_start = $data[0]['min_term_start'];
		$max_term_end = $data[0]['max_term_end'];
		$is_locked = $data[0]['is_locked'];
		
		$layout_json = '[{id: "a", text:"Filter",header:true,height:100},{id: "b", header:false}]';
						  
		$layout_obj = new AdihaLayout();
		$form_obj = new AdihaForm();
		
		$sp_url = "EXEC('Select n id, n name from seq WHERE n <= " . $max_leg . "')";
		$leg_json = $form_obj->adiha_form_dropdown($sp_url, 0, 1, true);

		$sp_url = "EXEC('Select n-1 id, n-1 name from seq WHERE n <= 24')";
		$hr_json = $form_obj->adiha_form_dropdown($sp_url, 0, 1, true);

		$form_json = '[ 
						{"type": "settings", "position": "label-top", "offsetLeft": 10},
						{"type": "calendar", "validate":"NotEmptywithSpace", required:true, "userdata":{"validation_message":"Required Field"}, "dateFormat":"' . $date_format . '", "serverDateFormat": "%Y-%m-%d", "name": "term_start", "label": "Term Start", "enableTime": false, "calendarPosition": "bottom", "value":"' . $term_start . '"},
					    {"type":"newcolumn"},
					    {"type": "calendar", "validate":"NotEmptywithSpace", required:true, "userdata":{"validation_message":"Required Field"}, "dateFormat":"' . $date_format . '", "serverDateFormat": "%Y-%m-%d", "name": "term_end", "label": "Term End", "enableTime": false, "calendarPosition": "bottom", "value":"' . $term_end . '"},
						{"type":"newcolumn"},
						{type:"combo", name:"leg", "options": ' . $leg_json . ' ,label:"Leg", rows:10, required:false, inputWidth:75,"offsetLeft":"10"},
						{type: "hidden", name:"process_id", value:"' . $process_id . '"}
						]';

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
<script type="text/javascript">
	var save_flag = 'n';
	var granularity = '<?php echo $granularity;?>';
	$(function() {
		var is_locked = '<?php echo $is_locked;?>';
		if (is_locked == 'y') {
			updateActualDeal.menu.setItemDisabled('save');
		}
		
		
		if (granularity == '') {
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
		
		var min_term = '<?php echo $min_term_start;?>';
		var max_term = '<?php echo $max_term_end;?>';
		var from_cal = updateActualDeal.form.getCalendar('term_start');
		var to_cal = updateActualDeal.form.getCalendar('term_end');
		from_cal.setSensitiveRange(min_term, max_term);
		to_cal.setSensitiveRange(min_term, max_term);
		
		updateActualDeal.load_grid();
	});
	
	/**
     * [menu_click Form Menu click function]
     * @param  {[type]} id [menu id]
     */
	updateActualDeal.menu_click = function(id) {
		switch(id) {
			case 'refresh':
				updateActualDeal.save_changes('refresh');
				break;
			case "pdf":
				updateActualDeal.grid.toPDF(js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
				break;
			case "excel":
				updateActualDeal.grid.toPDF(js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
				break;
			case 'save':
				updateActualDeal.save_changes('save');
				break;				
		}
	}
	
	/**
     * [save_changes Save changed data]
     * @param  {[type]} call_from [call from flag]
     */
	updateActualDeal.save_changes = function(call_from) {
		updateActualDeal.grid.clearSelection();
		var changed_rows = updateActualDeal.grid.getChangedRows(true);
		
		if (changed_rows != '') {
			var grid_xml = '<GridXML>';
            var changed_ids = new Array();
            changed_ids = changed_rows.split(",");
            $.each(changed_ids, function(index, value) {
                grid_xml += '<GridRow ';
                for(var cellIndex = 0; cellIndex < updateActualDeal.grid.getColumnsNum(); cellIndex++){
                    var column_id = updateActualDeal.grid.getColumnId(cellIndex);
                    var cell_value = updateActualDeal.grid.cells(value, cellIndex).getValue();
					if (column_id == 'term_date') {
						cell_value = dates.convert_to_sql(cell_value);
					}
                    grid_xml += ' col_' + column_id + '="' + cell_value + '"';
                }
                grid_xml += '></GridRow>';
            });
            grid_xml += '</GridXML>';
			
			var deal_id = '<?php echo $deal_id;?>';	
			var process_id = (updateActualDeal.form.getItemValue('process_id') == '') ? 'NULL' : updateActualDeal.form.getItemValue('process_id');
			
			data = {'action' : 'spa_update_actual_deal', 
					'flag' : 'u', 
					'xml' : grid_xml,
					'source_deal_header_id' : deal_id,
					'process_id':process_id
			};
			
			if (call_from == 'save')
				save_flag = 'y';
			else 
				save_flag = 'n';
			
            adiha_post_data("return", data, '', '', 'updateActualDeal.save_temp_callback');
		} else {
			if (call_from == 'refresh')
				updateActualDeal.load_grid();
			else 
				updateActualDeal.save_data();
		}
	}
	
	/**
     * [save_temp_callback Save callback for temporary table]
     * @param  {[type]} result [returned array]
     */
	updateActualDeal.save_temp_callback = function(result) {
		if (result[0].errorcode == 'Success') {
			if (save_flag == 'y') {
				updateActualDeal.save_data();
				save_flag = 'n';
			} else {
				updateActualDeal.load_grid();
			}
        }
	}
	
	/**
     * [save_data Save data]
     */
	updateActualDeal.save_data = function() {
		var deal_id = '<?php echo $deal_id;?>';	
		var process_id = (updateActualDeal.form.getItemValue('process_id') == '') ? 'NULL' : updateActualDeal.form.getItemValue('process_id');
		
		data = {'action' : 'spa_update_actual_deal', 
				'flag' : 'v', 
				'source_deal_header_id' : deal_id,
				'process_id':process_id
		};
		updateActualDeal.layout.cells('b').progressOn();
		adiha_post_data("alert", data, '', '', 'updateActualDeal.save_callback');
	}
	
	/**
     * [save_callback Save callback]
	 * @param  {[type]} result [returned array]
	 */
	updateActualDeal.save_callback = function(result) {
		updateActualDeal.layout.cells('b').progressOff();
		if (result[0].errorcode == 'Success') {
			updateActualDeal.load_grid();
        }
	}
	
	/**
     * [form_change Form Change callback]
     * @param  {[type]} name [item name]
     */
    updateActualDeal.form_change = function(name, value) {
        var term_start = updateActualDeal.form.getItemValue("term_start", true);
        var term_end = updateActualDeal.form.getItemValue("term_end", true);
		var min_max_val = (name == 'term_start') ? term_end : term_start;
		
        if (dates.compare(term_end, term_start) == -1) {
            if (name == 'term_start') {
                updateActualDeal.form.setItemValue('term_end', term_start);
				return;
            } else {
                var message = 'Term End cannot be greater than Term Start.';
            }
            updateActualDeal.show_error(message, name, min_max_val);
            return;
        }
    }
	
	/**
     * [show_error Show Error]
     * @param  {[string]} message     [Message]
     * @param  {[string]} name        [Item name]
     * @param  {[date]} min_max_val   [Date]
     */
    updateActualDeal.show_error = function(message, name, min_max_val) {
        dhtmlx.alert({
            title:"Error",
            type:"alert-error",
            text:message,
            callback: function(result){
                updateActualDeal.form.setItemValue(name, min_max_val);
            }
        });
    }
	
	/**
     * [load_grid Load Grid]
     */
	updateActualDeal.load_grid = function() {
		updateActualDeal.layout.cells('b').progressOn();
		var term_start = updateActualDeal.form.getItemValue("term_start", true);
        var term_end = updateActualDeal.form.getItemValue("term_end", true);
		var leg = updateActualDeal.form.getItemValue("leg");
		var process_id = (updateActualDeal.form.getItemValue('process_id') == '') ? 'NULL' : updateActualDeal.form.getItemValue('process_id');
				
		var deal_id = '<?php echo $deal_id;?>';
		
		data = {'action' : 'spa_update_actual_deal', 
				'flag' : 't', 
				'source_deal_header_id' : deal_id,
				'term_start' : term_start,
				'term_end' : term_end,
				'process_id':process_id
			};
	   adiha_post_data('return', data, '', '', 'updateActualDeal.load_grid_callback');
	}
	
	/**
     * [load_grid_callback Load Grid Callback - create grid]
     */
	updateActualDeal.load_grid_callback = function(result) {	
		if (updateActualDeal.grid) {
			updateActualDeal.grid.destructor();
		}
		updateActualDeal.grid = updateActualDeal.layout.cells('b').attachGrid();
		updateActualDeal.grid.setImagePath(js_image_path + "dhxgrid_web/");
        updateActualDeal.grid.setPagingWTMode(true,true,true,true);
        updateActualDeal.grid.enablePaging(true, 50, 0, 'pagingArea_b'); 
        updateActualDeal.grid.setPagingSkin('toolbar');
		
		updateActualDeal.grid.setHeader(result[0].column_label);
		updateActualDeal.grid.setColumnIds(result[0].column_list);
		updateActualDeal.grid.setColTypes(result[0].column_type);
		updateActualDeal.grid.setInitWidths(result[0].column_width);
		updateActualDeal.grid.setDateFormat(user_date_format,'%Y-%m-%d');
		/*if (show_hour) {
			updateActualDeal.grid.splitAt(5);
		} else {
			updateActualDeal.grid.splitAt(4);
		}*/
		updateActualDeal.grid.init();		
		updateActualDeal.grid.setColumnsVisibility(result[0].visibility);
		updateActualDeal.grid.enableEditEvents(true,false,true);
		
		updateActualDeal.grid.attachEvent("onEditCell", function(stage,rId,cInd,nValue,oValue){
			if (stage == 0) {
				var type_index = updateActualDeal.grid.getColIndexById('type');
				var type = updateActualDeal.grid.cells(rId, type_index).getValue();
				if (type == 'v') return false;
				else return true;
			} else {
				return true;
			}
		});
		
		
		var term_start = updateActualDeal.form.getItemValue("term_start", true);
        var term_end = updateActualDeal.form.getItemValue("term_end", true);
		var leg = updateActualDeal.form.getItemValue("leg");
		var process_id = (updateActualDeal.form.getItemValue('process_id') == '') ? 'NULL' : updateActualDeal.form.getItemValue('process_id');
		
		
		var deal_id = '<?php echo $deal_id;?>';
		
		param = {'action' : 'spa_update_actual_deal', 
			'flag' : 'a', 
			'source_deal_header_id' : deal_id,
			'term_start' : term_start,
			'term_end' : term_end,
			'process_id':process_id
		}; 

		param = $.param(param);
		var refresh_url = js_data_collector_url + '&' + param;
		updateActualDeal.grid.loadXML(refresh_url);
        updateActualDeal.layout.cells('b').progressOff();		
		save_flag = 'y';
	}
</script>
</html>