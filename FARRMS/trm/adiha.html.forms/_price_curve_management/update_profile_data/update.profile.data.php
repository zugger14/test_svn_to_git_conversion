<?php
/**
* Update profile data screen
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
		$form_namespace = 'updateProfileData';
        
		$deal_id = (isset($_POST["deal_id"]) && $_POST["deal_id"] != '') ? $_POST["deal_id"] : 'NULL';
		$detail_id = (isset($_POST["detail_id"]) && $_POST["detail_id"] != '') ? $_POST["detail_id"] : 'NULL';
		$term_start = (isset($_REQUEST["term_start"]) && $_REQUEST["term_start"] != '') ? $_REQUEST["term_start"] : date('Y-m-01');
		$term_end = (isset($_REQUEST["term_end"]) && $_REQUEST["term_end"] != '') ? $_REQUEST["term_end"] : date('Y-m-01');
		$call_from = (isset($_REQUEST["call_from"]) && $_REQUEST["call_from"] != '') ? $_REQUEST["call_from"] : 'NULL';
		$profile_id = (isset($_REQUEST["profile_id"]) && $_REQUEST["profile_id"] != '') ? $_REQUEST["profile_id"] : 'NULL';
		$location_id = (isset($_POST["location_id"]) && $_POST["location_id"] != '') ? $_POST["location_id"] : 'NULL';

		$deal_id = get_sanitized_value($deal_id);
		$detail_id = get_sanitized_value($detail_id);
		$term_start = get_sanitized_value($term_start);
		$term_end = get_sanitized_value($term_end);
		$call_from = get_sanitized_value($call_from);
		$profile_id = get_sanitized_value($profile_id);
		$location_id = get_sanitized_value($location_id);
		
		$sp_grid = "EXEC spa_update_profile_data @flag='p', @source_deal_detail_id=" . $detail_id . ", @location_id=" . $location_id. ", @profile_id=" . $profile_id;
		$data = readXMLURL2($sp_grid);
		// $profile_id = ($profile_id == 'NULL') ? $data[0][profile_id] : $profile_id;
		$final_profile_id = $data[0]['profile_id'] ?? '';

		$layout_json = '[{id: "a", text:"Filter",header:true, height:120,collapse:true},{id: "b", text:"Filter Criteria",header:true,height:200},{id: "c", header:false}]';
						  
		$layout_obj = new AdihaLayout();
		$form_obj = new AdihaForm();
		$application_function_id = 20002200;

		/*$sp_url = "EXEC spa_update_profile_data @flag='x'";
		$profile_json = $form_obj->adiha_form_dropdown($sp_url, 0, 1, true);*/

		//$sp_url = "EXEC('Select n-1 id, n-1 name from seq WHERE n <= 24')";
		//$hr_json = $form_obj->adiha_form_dropdown($sp_url, 0, 1, true);
		//$term_start = date('Y-m-01');
		/*$form_json = '[ 
						{"type": "settings", "position": "label-top", "offsetLeft": 10, inputWidth:150},
						{type:"combo", name:"profile", required:true, "options": ' . $profile_json . ' ,label:"Profile", rows:10, filtering:"between", "userdata":{"validation_message":"Required Field"}},	
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
		$xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='".$application_function_id."', @template_name='UpdateProfileData', @group_name='General'";
		$return_value = readXMLURL($xml_file);
		$form_json = $return_value[0][2];				
		echo $layout_obj->init_layout('layout', '', '3E', $layout_json, $form_namespace);
		echo $layout_obj->attach_form('form', 'b');
		
		echo $form_obj->init_by_attach('form', $form_namespace);
		echo $form_obj->load_form($form_json);
		echo $form_obj->attach_event('', 'onChange', $form_namespace . '.form_change');

		$rights_profile_data_edit = 20002201;

		list (
	         $has_rights_profile_data_edit
	    ) = build_security_rights(
	         $rights_profile_data_edit
	    );

	    $has_rights_profile_data_edit = ($call_from == 'deal_detail') ? 0 : 1;
	    
		$menu_json = '[
						{id:"refresh", text:"Refresh", img:"refresh.gif", title:"Refresh", enabled:true},
						{id:"t2", text:"Export", img:"export.gif", imgdis:"export_dis.gif", enabled:false, items:[
							{id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
							{id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
						]},
						{id:"save", text:"Save", img: "save.gif", imgdis: "save_dis.gif", title: "Save", enabled:'. (int)$has_rights_profile_data_edit . '} 		
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
<textarea style="display:none" name="txt_vol" id="txt_vol"><?php echo $volume;?></textarea>
<textarea style="display:none" name="txt_price" id="txt_price"><?php echo $price;?></textarea>
<textarea style="display:none" name="txt_process" id="txt_process"><?php echo $process_id;?></textarea>
<script type="text/javascript">
	var save_flag = 'n';
	var deal_id = '<?php echo $deal_id; ?>';
	var profile_id = '<?php echo $profile_id; ?>';
	var final_profile_id = '<?php echo $final_profile_id; ?>';
	var location_id = '<?php echo $location_id; ?>';
	var call_from = '<?php echo $call_from; ?>';
	var has_rights_profile_data_edit = Boolean('<?php echo $has_rights_profile_data_edit; ?>');
	
	$(function() {
		var combo_object = updateProfileData.form.getCombo('profile');
		combo_object.selectOption(1);
		combo_object.deleteOption('');
		filter_obj = updateProfileData.layout.cells('a').attachForm();
        var layout_cell_obj = updateProfileData.layout.cells('b');
        load_form_filter(filter_obj, layout_cell_obj, '<?php echo $application_function_id;?>', 2);
        updateProfileData.form.setItemValue('term_start','<?php echo $term_start; ?>');
        updateProfileData.form.setItemValue('term_end','<?php echo $term_end; ?>');

        if (call_from == 'deal_detail') {
        	var combo_param = {"action": "spa_update_profile_data", "flag":'b', "has_blank_option": false, "profile_id": profile_id, "location_id": location_id};
            combo_param = $.param(combo_param);
            var url = js_dropdown_connector_url + '&' + combo_param;
            combo_object.clearAll();
            combo_object.load(url, function() {
            	if (final_profile_id == '' || final_profile_id == 'NULL') {
					show_messagebox("Profile is not defined in deal.", function() {
						var win_obj = window.parent.update_actual_window.window("w1");
						win_obj.close();
	});
				} else {
					if (profile_id == '' || profile_id == 'NULL') {
						combo_object.selectOption(0);
					} else {
						updateProfileData.form.setItemValue('profile', profile_id);
					}
				}
				updateProfileData.menu_click('refresh');
            });
		}
	});
	/**
     * [menu_click Form Menu click function]
     * @param  {[type]} id [menu id]
     */
	updateProfileData.menu_click = function(id) {
		switch(id) {
			case 'refresh':
				updateProfileData.menu.setItemDisabled('t2');
				updateProfileData.refresh_definition('refresh');
				break;
			case "pdf":
				updateProfileData.grid.toPDF(js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
				break;
			case "excel":
				updateProfileData.grid.toPDF(js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
				break;
			case 'save':
				updateProfileData.refresh_definition('save');
				break;				
		}
	}
	
	/**
     * [refresh_definition Refresh/Save changed data]
     * @param  {[type]} f_call_from [call from flag]
     */
	updateProfileData.refresh_definition = function(f_call_from) {
		updateProfileData.layout.cells('c').progressOn();

		if (updateProfileData.grid && has_rights_profile_data_edit) {
			updateProfileData.grid.clearSelection();
			var changed_rows = updateProfileData.grid.getChangedRows(true);
			
			if (changed_rows != '') {
				if (f_call_from == 'refresh') {
					confirm_messagbox("There are unsaved changes. Do you want to save changes?.", function() {
						if (call_from != 'deal_detail')
							updateProfileData.save_changed_data();
					}, function() {
						updateProfileData.load_grid();
					});
				} else {
					updateProfileData.save_changed_data();
				}
			} else {
				updateProfileData.load_grid();
			}
		} else {
			updateProfileData.load_grid();
		}
		return;
	}

	/**
	 * [save_changed_data Save changed data]
	 */
	updateProfileData.save_changed_data = function() {		
		var process_id = (updateProfileData.form.getItemValue('process_id') == '') ? 'NULL' : updateProfileData.form.getItemValue('process_id');
		var changed_rows = updateProfileData.grid.getChangedRows(true);
		var source_deal_detail_id = '<?php echo $detail_id; ?>';
		var grid_xml = '<GridXML>';
        var changed_ids = new Array();
        changed_ids = changed_rows.split(",");
        $.each(changed_ids, function(index, value) {
            grid_xml += '<GridRow ';
            for(var cellIndex = 0; cellIndex < updateProfileData.grid.getColumnsNum(); cellIndex++){
                var column_id = updateProfileData.grid.getColumnId(cellIndex);
                var cell_value = updateProfileData.grid.cells(value, cellIndex).getValue();
				if (column_id == 'term_date') {
					cell_value = dates.convert_to_sql(cell_value);
				}
                grid_xml += ' col_' + column_id + '="' + cell_value + '"';
            }
            grid_xml += '></GridRow>';
        });
        grid_xml += '</GridXML>';

		data = {'action' : 'spa_update_profile_data', 
				'flag' : 'u', 
				'xml' : grid_xml,
				'process_id':process_id,
				'source_deal_detail_id': source_deal_detail_id
		};

		adiha_post_data("alert", data, '', '', 'updateProfileData.save_callback');
	}
	
	/**
     * [save_temp_callback Save callback for temporary table]
     * @param  {[type]} result [returned array]
     */
	updateProfileData.save_callback = function(result) {
		updateProfileData.layout.cells('c').progressOff();
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
			updateProfileData.load_grid();
        }
	}
		
	/**
     * [form_change Form Change callback]
     * @param  {[type]} name [item name]
     */
    updateProfileData.form_change = function(name, value) {
    	if (name == 'term_start' || name == 'term_end') {
    		var term_start = updateProfileData.form.getItemValue("term_start", true);
	        var term_end = updateProfileData.form.getItemValue("term_end", true);
			var min_max_val = (name == 'term_start') ? term_end : term_start;
	        if (dates.compare(term_end, term_start) == -1) {
	            if (name == 'term_start') {
	                updateProfileData.form.setItemValue('term_end', term_start);
					return;
	            } else {
	                var message = 'Term Start cannot be greater than Term End.';
	            }
	            updateProfileData.show_error(message, name, min_max_val);
	            return;
	        }
    	} else if (name == 'profile') {
    		var data = {
	            			'action' : 'spa_update_profile_data', 
							'flag' : 'z', 
							"profile_id": value
						};
			adiha_post_data("return", data, '', '', 'updateProfileData.show_hide_hours');
    	} else if (name == 'hr_from' || name == 'hr_to') {
			var hr_from = (updateProfileData.form.getItemValue('hr_from') == '') ? 'NULL' : updateProfileData.form.getItemValue('hr_from');
			var hr_to = (updateProfileData.form.getItemValue('hr_to') == '') ? 'NULL' : updateProfileData.form.getItemValue('hr_to');
			var min_max_val = (name == 'hr_from') ? hr_to : hr_from;
			if (hr_from != 'NULL' && hr_to != 'NULL' && Number(hr_from) > Number(hr_to)) {
				var message = 'Hour From cannot be greater than Hour To.';
				updateProfileData.show_error(message, name, min_max_val);
	            return;
			}
		}       
    }

    /**
     * [show_hide_hours Show hide hours columns according to profile granularity]
     * @param  {[type]} result [Result object]
     */
    updateProfileData.show_hide_hours = function(result) {
    	var show_hours = (result[0].show_hours == 'y') ? true : false;

    	if (show_hours && call_from != 'deal_detail') {
    		updateProfileData.form.showItem('hr_from');
    		updateProfileData.form.showItem('hr_to');
    		if(result[0].granularity == 982) {
    			var cm_param = {"action":"('select n id, n name from seq WHERE n <= 24')"};
       
    		} else {
    			var cm_param = {"action":"('select n-1 id, n-1 name from seq WHERE n <= 25')"};
    		}
    		cm_param = $.param(cm_param);
        	var url = js_dropdown_connector_url + '&' + cm_param;
        	updateProfileData.form.getCombo('hr_from').load(url, function() {
        		this.selectOption(0);
        	});
        	updateProfileData.form.getCombo('hr_to').load(url, function() {
        		this.selectOption(0);
        	});
    	} else {
    		updateProfileData.form.setItemValue('hr_from', '');
    		updateProfileData.form.setItemValue('hr_to', '');
    		updateProfileData.form.hideItem('hr_from');
    		updateProfileData.form.hideItem('hr_to');
    		updateProfileData.layout.cells('b').setHeight(115);
    	}
    }

	
	/**
     * [show_error Show Error]
     * @param  {[string]} message     [Message]
     * @param  {[string]} name        [Item name]
     * @param  {[date]} min_max_val   [Date]
     */
    updateProfileData.show_error = function(message, name, min_max_val) {
    	updateProfileData.layout.cells('c').progressOff();
		
		show_messagebox(message, function() {
			updateProfileData.form.setItemValue(name, min_max_val);
        });
    }
	
	/**
     * [load_grid Load Grid]
     */
	updateProfileData.load_grid = function() {
		updateProfileData.layout.cells('c').progressOn();
		var profile_id = updateProfileData.form.getItemValue("profile");
		var term_start = updateProfileData.form.getItemValue("term_start", true);
        var term_end = updateProfileData.form.getItemValue("term_end", true);
		//var show_hour = Boolean('<?php //echo $show_hour; ?>');
		var process_id = (updateProfileData.form.getItemValue('process_id') == '') ? 'NULL' : updateProfileData.form.getItemValue('process_id');
		var hr_from = (updateProfileData.form.getItemValue('hr_from') == '') ? 'NULL' : updateProfileData.form.getItemValue('hr_from');
		var hr_to = (updateProfileData.form.getItemValue('hr_to') == '') ? 'NULL' : updateProfileData.form.getItemValue('hr_to');

		var status = validate_form(updateProfileData.form);
		if (!status) {
			updateProfileData.layout.cells('c').progressOff();
			return;
		}

		
		data = {'action' : 'spa_update_profile_data', 
				'flag' : 't', 
				'profile_id' : profile_id,
				'term_start' : term_start,
				'term_end' : term_end,
				'hour_from':hr_from,
				'hour_to':hr_to,
			};
	   	adiha_post_data('return', data, '', '', 'updateProfileData.load_grid_callback');
	}
	
	/**
     * [load_grid_callback Load Grid Callback - create grid]
     */
	updateProfileData.load_grid_callback = function(result) {	
		var round_value = updateProfileData.form.getItemValue('rounding');
		if (updateProfileData.grid) {
			updateProfileData.grid.destructor();
		}
		updateProfileData.grid = updateProfileData.layout.cells('c').attachGrid();
		updateProfileData.grid.setImagePath(js_image_path + "dhxgrid_web/");
        updateProfileData.grid.setPagingWTMode(true,true,true,true);
        updateProfileData.grid.enablePaging(true, 50, 0, 'pagingArea_c'); 
        updateProfileData.grid.setPagingSkin('toolbar');
		
		updateProfileData.grid.setHeader(get_locale_value(result[0].column_label, true));
		updateProfileData.grid.setColumnIds(result[0].column_list);
		updateProfileData.grid.setColTypes(result[0].column_type);
		updateProfileData.grid.setInitWidths(result[0].column_width);
		updateProfileData.grid.setDateFormat(user_date_format,'%Y-%m-%d');
		var show_hour = updateProfileData.form.isItemHidden('hr_from');
		if (show_hour) {
			updateProfileData.grid.splitAt(2);
		} else {
			updateProfileData.grid.splitAt(3);
		}
		updateProfileData.grid.init();		
		updateProfileData.grid.setColumnsVisibility(result[0].visibility);
		updateProfileData.grid.enableEditEvents(true,false,true);
		var set_round_values = (result[0].data_type).replace(/float/g,round_value);
		if (round_value && round_value != '') {
            updateProfileData.grid.enableRounding(set_round_values);
        }
		
		// Setting round value from dropdown which is used by eXcell_ed_no component to change value according to round value
		updateProfileData.grid.roundValue = round_value;

		updateProfileData.form.setItemValue('process_id', result[0].process_id);
		
		var profile_id = updateProfileData.form.getItemValue("profile");
		var term_start = updateProfileData.form.getItemValue("term_start", true);
        var term_end = updateProfileData.form.getItemValue("term_end", true);
		var process_id = result[0].process_id;
		
		var hr_from = (updateProfileData.form.getItemValue('hr_from') == '') ? 'NULL' : updateProfileData.form.getItemValue('hr_from');
		var hr_to = (updateProfileData.form.getItemValue('hr_to') == '') ? 'NULL' : updateProfileData.form.getItemValue('hr_to');
		var param = {'action' : 'spa_update_profile_data', 
						'flag' : 'a', 
						'profile_id' : profile_id,
						'term_start' : term_start,
						'term_end' : term_end,
						'hour_from':hr_from,
						'hour_to':hr_to,
						'process_id':process_id
					};

		param = $.param(param);

		var refresh_url = js_data_collector_url + '&' + param;
		updateProfileData.grid.loadXML(refresh_url, function() {
			updateProfileData.layout.cells('c').progressOff();	
        	updateProfileData.menu.setItemEnabled('t2');
		});	
	}
</script>
</html>