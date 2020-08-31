<?php
/**
* Update meter data screen
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
		$form_namespace = 'updateMeterData';

		$layout_json = '[{id: "a", text:"Filter",header:true, height:100,collapse:true},{id: "b", text:"Filter Criterian",header:true,height:180},{id: "c", header:false}]';
						  
		$layout_obj = new AdihaLayout();
		$form_obj = new AdihaForm();

		/*$sp_url = "EXEC spa_update_meter_data @flag='x'";
		$meter_json = $form_obj->adiha_form_dropdown($sp_url, 0, 1, true);
*/
		//$sp_url = "EXEC('Select n-1 id, n-1 name from seq WHERE n <= 24')";
		//$hr_json = $form_obj->adiha_form_dropdown($sp_url, 0, 1, true);
		$term_start = date('Y-m-01');
		$application_function_id = 20001700;
	/*	$form_json = '[ 
						{"type": "settings", "position": "label-top", "offsetLeft": 10, inputWidth:150},
						{type:"combo", name:"meter", required:true, "options": ' . $meter_json . ' ,label:"Meter", rows:10, filtering:"between", "userdata":{"validation_message":"Required Field"}},	
						{"type":"newcolumn"},					
						{type:"combo", name:"channel", label:"Channel", required:true, "userdata":{"validation_message":"Required Field"}, "comboType": "custom_checkbox"},
						{"type":"newcolumn"},
						{"type": "calendar", "validate":"NotEmptywithSpace", required:true, "userdata":{"validation_message":"Required Field"}, "dateFormat":"' . $date_format . '", "serverDateFormat": "%Y-%m-%d", "name": "term_start", "label": "Term Start", "userdata":{"validation_message":"Required Field"}, "enableTime": false, "calendarPosition": "bottom", "value":"' . $term_start . '"},
					    {"type":"newcolumn"},
					    {"type": "calendar", "validate":"NotEmptywithSpace", required:true, "userdata":{"validation_message":"Required Field"}, "dateFormat":"' . $date_format . '", "serverDateFormat": "%Y-%m-%d", "name": "term_end", "label": "Term End", "userdata":{"validation_message":"Required Field"}, "enableTime": false, "calendarPosition": "bottom", "value":"' . $term_start . '"},
						{"type":"newcolumn"},
						{type: "hidden", name:"process_id"},
						{"type":"newcolumn"},						
						{type:"combo", name:"hr_from", "options": "" ,label:"Interval Start", required:false, hidden:true},
						{"type":"newcolumn"},
						{type:"combo", name:"hr_to", "options": "" ,label:"Interval End", required:false, hidden:true}
						]
						';*/





		$xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='".$application_function_id."', @template_name='ViewEditMeterDataFilter', @group_name='General'";
		$return_value = readXMLURL($xml_file);
		$form_json = $return_value[0][2];
		

		echo $layout_obj->init_layout('layout', '', '3E', $layout_json, $form_namespace);
		echo $layout_obj->attach_form('form', 'b');
		
		echo $form_obj->init_by_attach('form', $form_namespace);
		echo $form_obj->load_form($form_json);
		echo $form_obj->attach_event('', 'onChange', $form_namespace . '.form_change');

		$rights_meter_data_edit = 20001701;

		list (
	         $has_rights_meter_data_edit
	    ) = build_security_rights(
	         $rights_meter_data_edit
	    );

		$menu_json = '[
						{id:"refresh", text:"Refresh", img:"refresh.gif", title:"Refresh", enabled:true},
						{id:"t2", text:"Export", img:"export.gif", imgdis:"export_dis.gif", enabled:false, items:[
							{id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
							{id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
						]},
						{id:"save", text:"Save", img: "save.gif", imgdis: "save_dis.gif", title: "Save", enabled:'. (int)$has_rights_meter_data_edit . '} 		
					  ]';
		$menu_object = new AdihaMenu();
		echo $layout_obj->attach_menu_cell('menu', 'c');
		echo $menu_object->init_by_attach('menu', $form_namespace);
		echo $menu_object->load_menu($menu_json);
		echo $menu_object->attach_event('', 'onClick', $form_namespace . '.menu_click');
		echo $layout_obj->attach_status_bar("c", true);
		echo $layout_obj->close_layout();
	?>
</body>
<script type="text/javascript">
	var save_flag = 'n';
	var has_rights_meter_data_edit = Boolean('<?php echo $has_rights_meter_data_edit; ?>');
	
	$(function() {
		var combo_object = updateMeterData.form.getCombo('meter');
		combo_object.selectOption(1);
		combo_object.deleteOption('');

		filter_obj = updateMeterData.layout.cells('a').attachForm();
        var layout_cell_obj = updateMeterData.layout.cells('b');
        load_form_filter(filter_obj, layout_cell_obj, '<?php echo $application_function_id;?>', 2);
        updateMeterData.form.setItemValue('term_start','<?php echo $term_start; ?>');
        updateMeterData.form.setItemValue('term_end','<?php echo $term_start; ?>');
	});


	/**
     * [menu_click Form Menu click function]
     * @param  {[type]} id [menu id]
     */

	updateMeterData.menu_click = function(id) {
		switch(id) {
			case 'refresh':
				updateMeterData.menu.setItemDisabled('t2');
				updateMeterData.refresh_definition('refresh');
				break;
			case "pdf":
				updateMeterData.grid.toPDF(js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
				break;
			case "excel":
				updateMeterData.grid.toPDF(js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
				break;
			case 'save':
				updateMeterData.refresh_definition('save');
				break;				
		}
	}
	
	/**
     * [refresh_definition Refresh/Save changed data]
     * @param  {[type]} call_from [call from flag]
     */
	updateMeterData.refresh_definition = function(call_from) {
		updateMeterData.layout.cells('c').progressOn();

		if (updateMeterData.grid && has_rights_meter_data_edit) {
			updateMeterData.grid.clearSelection();
			var changed_rows = updateMeterData.grid.getChangedRows(true);
			
			if (changed_rows != '') {
				if (call_from == 'refresh') {
					confirm_messagebox("There are unsaved changes. Do you want to save changes?.", function() {
						updateMeterData.save_changed_data();
					}, function() {
						updateMeterData.load_grid();
					});
				} else {
					updateMeterData.save_changed_data();
				}
			} else {
				updateMeterData.load_grid();
			}
		} else {
			updateMeterData.load_grid();
		}
		return;
	}

	/**
	 * [save_changed_data Save changed data]
	 */
	updateMeterData.save_changed_data = function() {
		var process_id = (updateMeterData.form.getItemValue('process_id') == '') ? 'NULL' : updateMeterData.form.getItemValue('process_id');
		var changed_rows = updateMeterData.grid.getChangedRows(true);
		var grid_xml = '<GridXML>';
        var changed_ids = new Array();
        changed_ids = changed_rows.split(",");
        $.each(changed_ids, function(index, value) {
            grid_xml += '<GridRow ';
            for(var cellIndex = 0; cellIndex < updateMeterData.grid.getColumnsNum(); cellIndex++){
                var column_id = updateMeterData.grid.getColumnId(cellIndex);
                var cell_value = updateMeterData.grid.cells(value, cellIndex).getValue();
				
				if (column_id == 'prod_date') {
					cell_value = dates.convert_to_sql(cell_value);
				}
                grid_xml += ' col_' + column_id + '="' + cell_value + '"';
            }
            grid_xml += '></GridRow>';
        });
        grid_xml += '</GridXML>';

		data = {'action' : 'spa_update_meter_data', 
				'flag' : 'u', 
				'xml' : grid_xml,
				'process_id':process_id
		};

		adiha_post_data("alert", data, '', '', 'updateMeterData.save_callback');
	}
	
	/**
     * [save_temp_callback Save callback for temporary table]
     * @param  {[type]} result [returned array]
     */
	updateMeterData.save_callback = function(result) {
		if (result[0].errorcode == 'Success') {
			updateMeterData.load_grid();
        }
	}
		
	/**
     * [form_change Form Change callback]
     * @param  {[type]} name [item name]
     */
    updateMeterData.form_change = function(name, value) {
    	if (name == 'term_start' || name == 'term_end') {
    		var term_start = updateMeterData.form.getItemValue("term_start", true);
	        var term_end = updateMeterData.form.getItemValue("term_end", true);
			var min_max_val = (name == 'term_start') ? term_end : term_start;
			
	        if (dates.compare(term_end, term_start) == -1) {
	            if (name == 'term_start') {
	                updateMeterData.form.setItemValue('term_end', term_start);
					return;
	            } else {
	                var message = 'Term Start cannot be greater than Term End.';
	            }
	            updateMeterData.show_error(message, name, min_max_val);
	            return;
	        }
    	} else if (name == 'meter') {
    		var channel_combo = updateMeterData.form.getCombo('channel');            
            if (channel_combo) {
                channel_combo.enableFilteringMode('between');
                var cm_param = {"action": "spa_update_meter_data", "flag": "y", "meter_id": value, "has_blank_option":"false"};
                cm_param = $.param(cm_param);
                var url = js_dropdown_connector_url + '&' + cm_param;
                channel_combo.load(url, function(){
                	channel_combo.setChecked(0, true);
                });
            }
            var data = {
	            			'action' : 'spa_update_meter_data', 
							'flag' : 'z', 
							"meter_id": value
						};
			adiha_post_data("return", data, '', '', 'updateMeterData.show_hide_hours');
    	} else if (name == 'hr_from' || name == 'hr_to') {
			var hr_from = (updateMeterData.form.getItemValue('hr_from') == '') ? 'NULL' : updateMeterData.form.getItemValue('hr_from');
			var hr_to = (updateMeterData.form.getItemValue('hr_to') == '') ? 'NULL' : updateMeterData.form.getItemValue('hr_to');
			var min_max_val = (name == 'hr_from') ? hr_to : hr_from;
			if (hr_from != 'NULL' && hr_to != 'NULL' && Number(hr_from) > Number(hr_to)) {
				var message = 'Hour From cannot be greater than Hour To.';
				updateMeterData.show_error(message, name, min_max_val);
	            return;
			}
		}
    }

    /**
     * [show_hide_hours Show hide hours columns according to meter granularity]
     * @param  {[type]} result [Result object]
     */
    updateMeterData.show_hide_hours = function(result) {
    	var show_hours = (result[0].show_hours == 'y') ? true : false;

    	if (show_hours) {
    		updateMeterData.form.showItem('hr_from');
    		updateMeterData.form.showItem('hr_to');
			if(result[0].granularity == 982) {
    			var cm_param = {"action":"('select n id, n name from seq WHERE n <= 24')"};
       
    		} else {
    			var cm_param = {"action":"('select n-1 id, n-1 name from seq WHERE n <= 25')"};
    		}

	   		cm_param = $.param(cm_param);
        	var url = js_dropdown_connector_url + '&' + cm_param;
        	updateMeterData.form.getCombo('hr_from').load(url, function() {
        		this.selectOption(0);
        	});
        	updateMeterData.form.getCombo('hr_to').load(url, function() {
        		this.selectOption(0);
        	});
    	} else {
    		updateMeterData.form.setItemValue('hr_from', '');
    		updateMeterData.form.setItemValue('hr_to', '');
    		updateMeterData.form.hideItem('hr_from');
    		updateMeterData.form.hideItem('hr_to');
    	}
    }

	
	/**
     * [show_error Show Error]
     * @param  {[string]} message     [Message]
     * @param  {[string]} name        [Item name]
     * @param  {[date]} min_max_val   [Date]
     */
    updateMeterData.show_error = function(message, name, min_max_val) {
    	updateMeterData.layout.cells('c').progressOff();
		
		show_messagebox(message, function() {
			updateMeterData.form.setItemValue(name, min_max_val);
		});
    }
	
	/**
     * [load_grid Load Grid]
     */
	updateMeterData.load_grid = function() {
		updateMeterData.layout.cells('c').progressOn();
		var meter_id = updateMeterData.form.getItemValue("meter");
		var term_start = updateMeterData.form.getItemValue("term_start", true);
        var term_end = updateMeterData.form.getItemValue("term_end", true);
		//var show_hour = Boolean('<?php //echo $show_hour; ?>');
		var process_id = (updateMeterData.form.getItemValue('process_id') == '') ? 'NULL' : updateMeterData.form.getItemValue('process_id');
		var hr_from = (updateMeterData.form.getItemValue('hr_from') == '') ? 'NULL' : updateMeterData.form.getItemValue('hr_from');
		var hr_to = (updateMeterData.form.getItemValue('hr_to') == '') ? 'NULL' : updateMeterData.form.getItemValue('hr_to');

		var channel_combo = updateMeterData.form.getCombo('channel');
		var channel = (channel_combo.getChecked() == '' || channel_combo.getChecked().length === 0) ? 'NULL' : channel_combo.getChecked().join(',');

		var status = validate_form(updateMeterData.form);
		if (!status) {
			updateMeterData.layout.cells('c').progressOff();
			return;
		}

		
		data = {'action' : 'spa_update_meter_data', 
				'flag' : 't', 
				'meter_id' : meter_id,
				'term_start' : term_start,
				'term_end' : term_end,
				'channel':channel,
				'hour_from':hr_from,
				'hour_to':hr_to,
			};
	   	adiha_post_data('return', data, '', '', 'updateMeterData.load_grid_callback');
	}
	
	/**
     * [load_grid_callback Load Grid Callback - create grid]
     */
	updateMeterData.load_grid_callback = function(result) {
		var round_value = updateMeterData.form.getItemValue('rounding');
		if (updateMeterData.grid) {
			updateMeterData.grid.destructor();
		}
		updateMeterData.grid = updateMeterData.layout.cells('c').attachGrid();
		updateMeterData.grid.setImagePath(js_image_path + "dhxgrid_web/");
        updateMeterData.grid.setPagingWTMode(true,true,true,true);
        updateMeterData.grid.enablePaging(true, 50, 0, 'pagingArea_c'); 
        updateMeterData.grid.setPagingSkin('toolbar');
		
		updateMeterData.grid.setHeader(get_locale_value(result[0].column_label, true));
		updateMeterData.grid.setColumnIds(result[0].column_list);
		updateMeterData.grid.setColTypes(result[0].column_type);
		updateMeterData.grid.setInitWidths(result[0].column_width);
		updateMeterData.grid.setDateFormat(user_date_format,'%Y-%m-%d');
		var show_hour = updateMeterData.form.isItemHidden('hr_from');
		
		if (show_hour) {
			updateMeterData.grid.splitAt(3);
		} else {
			updateMeterData.grid.splitAt(4);
		}
		updateMeterData.grid.init();		
		updateMeterData.grid.setColumnsVisibility(result[0].visibility);
		updateMeterData.grid.enableEditEvents(true,false,true);
		updateMeterData.grid.copyFromExcel(false);
		// to replace all strings that matches keyword.
		var set_round_values = (result[0].data_type).replace(/float/g,round_value);

		if (round_value && round_value != '') {
			updateMeterData.grid.enableRounding(set_round_values);
		}
		
		// Setting round value from dropdown which is used by eXcell_ed_no component to change value according to round value
		updateMeterData.grid.roundValue = round_value;

		updateMeterData.form.setItemValue('process_id', result[0].process_id);
		
		var meter_id = updateMeterData.form.getItemValue("meter");
		var term_start = updateMeterData.form.getItemValue("term_start", true);
        var term_end = updateMeterData.form.getItemValue("term_end", true);
		var channel_combo = updateMeterData.form.getCombo('channel');
		var channel = (channel_combo.getChecked() == '' || channel_combo.getChecked().length === 0) ? 'NULL' : channel_combo.getChecked().join(',');
		var process_id = result[0].process_id;
		
		var hr_from = (updateMeterData.form.getItemValue('hr_from') == '') ? 'NULL' : updateMeterData.form.getItemValue('hr_from');
		var hr_to = (updateMeterData.form.getItemValue('hr_to') == '') ? 'NULL' : updateMeterData.form.getItemValue('hr_to');
		
		var param = {'action' : 'spa_update_meter_data', 
						'flag' : 'a', 
						'meter_id' : meter_id,
						'term_start' : term_start,
						'term_end' : term_end,
						'hour_from':hr_from,
						'hour_to':hr_to,
						'channel':channel,
						'process_id':process_id
					};

		param = $.param(param);

		var refresh_url = js_data_collector_url + '&' + param;
		updateMeterData.grid.loadXML(refresh_url, function() {
        	updateMeterData.layout.cells('c').progressOff();	
        	updateMeterData.menu.setItemEnabled('t2');
		});	
	}
</script>
</html>