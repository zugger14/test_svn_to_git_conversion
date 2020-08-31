<?php 
	/** 
	 *  Generic file to generate the script to prepare the data view forms. Script is generated according to the definition defiend in application_ui.. table
	 *  @copyright Pioneer Solutions.
	 */

	include 'components/include.file.v3.php';

	if (isset($_POST["function_id"]) && !empty($_POST["function_id"])) {
		$function_id = $_POST["function_id"];
	} else {
		die('Authorization failed.');
	}

	/* Feature not support list start */
	$tab_add_disable_function_id = ['10105800', '10105815', '10105830', '10101125', '10181313'];
	$tab_add_disable = in_array($function_id, $tab_add_disable_function_id) ? 'true' : 'false';
	/* Feature not support list end */

	$template_name = (isset($_POST["template_name"]) && !empty($_POST["template_name"])) ? $_POST["template_name"] : '';
	$primary_field = (isset($_POST["primary_field"]) && !empty($_POST["primary_field"])) ? $_POST["primary_field"] : '';
	$object_id_with_dot = (isset($_POST["object_id"]) && !empty($_POST["object_id"])) ? $_POST["object_id"] : 0;
	$parent_object = (isset($_POST["parent_object"]) && !empty($_POST["parent_object"])) ? $_POST["parent_object"] : '';
	$builder_mode = (isset($_POST["builder_mode"]) && !empty($_POST["builder_mode"])) ? $_POST["builder_mode"] : '';

	//to create a object name 
	//do not remove dot (.) to pass in db as login name can contain dots.
	$object_id_with_dot = preg_replace('/[^a-zA-Z0-9_.-]/', '', $object_id_with_dot);
	//but dot(.) gives issues in creating new tab, so remove it for further processing
	$object_id = preg_replace('/[.-]/', '', $object_id_with_dot);

	$array_object_id = (is_numeric($object_id_with_dot)) ? $object_id : ord($object_id_with_dot);
	
	//Collecting Template definitions
	$xml_obj = '<Root><PSRecordset ' . $primary_field . '="' . $object_id_with_dot . '"></PSRecordset></Root>';
	$form_sp = "EXEC spa_create_application_ui_json 'f', '" . $function_id . "', '" . $template_name . "', '" . $xml_obj . "'";
	if ($builder_mode > 0) $form_sp .= ", @audit_id=" . $builder_mode;
	$form_data = readXMLURL2($form_sp);
	$return_string = '';
	
	if (is_array($form_data) && sizeof($form_data) > 0) {
		$return_string .= 'win = ' . $parent_object . ";\n";
		$return_string .= 'tabbar_' . $object_id . ' = win.tabbar[' . $array_object_id  . '] = win.attachTabbar({mode:"bottom",arrows_mode:"auto"});' . "\n";

		$flattened_form_data = array();
		$tab_data = array();
		$tab_fields_data = array();
		$tab_menu_json = '';
		$dependent_combo_data = array();
		// Attach Tabbar
		foreach ($form_data as $data) {
			$fields_datas = json_decode($data['form_json'], true);
			if ($data['dependent_combo'] != "") {
				$dependent_fields = explode("~", $data['dependent_combo']);
				$g_parent_id = explode("->", $dependent_fields[0]);
				foreach ($dependent_fields as $value) {
					$ind_dep_fields = explode("->", $value);
					$key = array_filter($fields_datas, function ($var) use ($ind_dep_fields) {
					    return ($var['name'] == $ind_dep_fields[0]);
					});
					$key1 = array_filter($fields_datas, function ($var) use ($ind_dep_fields) {
					    return ($var['name'] == $ind_dep_fields[1]);
					});
					foreach ($key as $k) {
						$parent_id = $k['id'];
					}
					foreach ($key1 as $k1) {
						$child_id = $k1['id'];
					}
					$dependent_combo_data[$parent_id] = $child_id;
				}
				$p = array_filter($fields_datas, function ($var) use ($g_parent_id) {
				    return ($var['name'] == $g_parent_id[0]);
				});
				foreach ($p as $p1) {
					$p_id = $p1['id'];
				}
				$dependent_combo_data[$child_id] = $p_id;

			}

			if (!array_key_exists($data['tab_id'], $flattened_form_data)) {
                $flattened_form_data[$data['tab_id']] = array();
			}
			
            $tab_id = 'detail_tab_' . $data['tab_id'];
			array_push($flattened_form_data[$data['tab_id']], array($tab_id, $data['tab_id'], $data['layout_pattern'], $data['form_json'], $data['grid_json'], $data['seq'], $data['dependent_combo']));
			array_push($tab_data, $data['tab_json']);
			
			if ($data['form_json'] != '') {
				$tab_menu_json .= ',' . $data['tab_json'];
			}
			// Create Tab Fields Data
			if (!array_key_exists($data['tab_id'], $tab_fields_data)) {
				$tab_fields_data[$data['tab_id']] = array();
			}

			if ($fields_datas) {
				foreach ($fields_datas as $key => $fields) {
					if ($fields['group_id'] == $data['tab_id']){
						if (!array_key_exists('general', $tab_fields_data[$data['tab_id']])) {
							$tab_fields_data[$data['tab_id']] = array("general" => array()) + $tab_fields_data[$data['tab_id']];
						}

						if (!array_key_exists('fieldset_id', $fields)) {
							$tab_fields_data[$data['tab_id']]['general'][] = $fields;
						} else {
							$tab_fields_data[$data['tab_id']][$fields['fieldset_id']][] = $fields;
						}
					}
				}
			}
		}
		
		$return_string .= ' var dependent_combo_data = $.parseJSON(\''.json_encode($dependent_combo_data).'\')' . "\n";
		$tab_menu_json = ltrim($tab_menu_json, ',');
		$combined_tab_data = '{tabs: [' . implode(",", $tab_data) . ']};';
		$return_string .= 'var context_menu_array = [];'. "\n";
		$return_string .= 'var new_tab_array = [];'. "\n";
		$return_string .= 'tabbar_data = ' . $combined_tab_data . "\n";
		$return_string .= 'tabbar_' . $object_id . '.loadStruct(tabbar_data);' . "\n";
		$return_string .= 'var inner_tab_context_menu = new dhtmlXMenuObject();' . "\n";
        $return_string .= 'inner_tab_context_menu.setIconsPath("' . $image_path . 'dhxtoolbar_web/");' . "\n";
        $return_string .= 'inner_tab_context_menu.renderAsContextMenu();' . "\n";
        $return_string .= 'inner_tab_context_menu.loadStruct([' . "\n";
        $return_string .= '		{id:"add", text:"Add Tab", title: "Add Tab"},' . "\n";
        $return_string .= '		{id:"rename", text:"Rename Tab", title: "Rename Tab"},' . "\n";
        $return_string .= '		{id:"delete", text:"Delete Tab", title: "Delete Tab"}' . "\n";
        $return_string .= '	]);' . "\n";
        $return_string .= 'tabbar_' . $object_id . '.forEachTab(function(tab){' . "\n";
		$return_string .= '		var id = tab.getId();' . "\n";
		$return_string .= '		var text = tab.getText();' . "\n";
		$return_string .= '		tabbar_'. $object_id . '.t[id].tab.id=id;' . "\n";
		$return_string .= '		inner_tab_context_menu.addContextZone(id);' . "\n";
		$return_string .= '		if (text == "UDF") tabbar_'. $object_id . '.tabs(id).setText("<span style=\'color:red;\'>"+text+"</span>");' . "\n";
		$return_string .= '});' . "\n";
		$return_string .= 'inner_tab_context_menu.attachEvent("onBeforeContextMenu", function(zoneId, ev){' . "\n";
        $return_string .= '		tabbar_' . $object_id . '.tabs(zoneId).setActive();' . "\n";
        $return_string .= '		var tab_id = tabbar_' . $object_id . '.tabs(zoneId).getId();' . "\n";
        $return_string .= '		var tab_split_array = tab_id.split("_");' . "\n";
        $return_string .= '		var is_new_tab = tab_split_array[3];' . "\n";
        $return_string .= '		var tab_add_disable = "' . $tab_add_disable . '"' .  "\n";
        $return_string .= '		if (is_new_tab == "n") {' . "\n";
        $return_string .= '			inner_tab_context_menu.hideItem("rename");' . "\n";
		$return_string .= '			inner_tab_context_menu.hideItem("delete");' . "\n";
		$return_string .= '		} else {' . "\n";
		$return_string .= '			inner_tab_context_menu.showItem("rename");' . "\n";
		$return_string .= '			inner_tab_context_menu.showItem("delete");' . "\n";
		$return_string .= '		}' . "\n";
		$return_string .= '		if (tab_add_disable == "true") {' . "\n";
		$return_string .= '			inner_tab_context_menu.hideItem("add");' . "\n";
		$return_string .= '		}' . "\n";
        $return_string .= '		return true;' . "\n";
        $return_string .= '});' . "\n";
        $return_string .= 'inner_tab_context_menu.attachEvent("onClick", function(id, zoneId){' . "\n";
        $return_string .= '    	switch(id) {' . "\n";
        $return_string .= '        case "add":' . "\n";
        $return_string .= '				var new_tab_name = "New Tab";' . "\n";
        $return_string .= '		      	var new_id = (new Date()).valueOf();' . "\n";
        $return_string .= '		      	var new_id = new_id + "_y";' . "\n";
        $return_string .= '		      	var tab_id = "detail_tab_" + new_id' . "\n";
        $return_string .= '            	break;' . "\n";
        $return_string .= '        case "rename":' . "\n";
        $return_string .= '				var tab_id = tabbar_' . $object_id . '.getActiveTab();' . "\n";
        $return_string .= '				var new_tab_name = tabbar_' . $object_id . '.tabs(tab_id).getText();' . "\n";
        $return_string .= '            	break;' . "\n";
		$return_string .= '        case "delete":' . "\n";
    	$return_string .= '				var state = form_builder.tabbar' . "\n";
		$return_string .= '					                 .cells(form_builder.tabbar.getActiveTab())' . "\n";
		$return_string .= '					                 .getAttachedToolbar()' . "\n";
		$return_string .= '					                 .getItemState("show_hide");' . "\n";
		$return_string .= '				var tab_field_count = 0;' . "\n";
        $return_string .= '				var tab_id = tabbar_' . $object_id . '.getActiveTab();' . "\n";
        $return_string .= '				var lay_obj = tabbar_' . $object_id . '.cells(tab_id).getAttachedObject();' . "\n";
        $return_string .= '				var grid_id = "";' . "\n";
        $return_string .= '				lay_obj.forEachItem(function(cell){' . "\n";
		$return_string .= '				    var attached_obj = cell.getAttachedObject();' . "\n";
		$return_string .= '				    if (attached_obj instanceof dhtmlXGridObject) {' . "\n";
		$return_string .= '				    	grid_id = attached_obj.getUserData("", "grid_id");' . "\n";
		$return_string .= '						var udf_tab_layout_obj = tabbar_' . $object_id . '.tabs("detail_tab_' . $function_id . '_n").getAttachedObject();' . "\n";
		$return_string .= '						var udf_tab_dv_obj = udf_tab_layout_obj.cells("a").getAttachedObject();' . "\n";
		$return_string .= '				    	$.each($(udf_tab_dv_obj).children("span").children("div"), function(){' . "\n";
		$return_string .= '				            var id = $(this).attr("id").split("_");' . "\n";
		$return_string .= '				            var attached_obj = eval("details_form_" + id[2] + "_" + id[3]);' . "\n";
		$return_string .= '							attached_obj.filter();' . "\n";
		$return_string .= '				            var data = attached_obj.serialize();' . "\n";
		$return_string .= '				            var dv_item = data.filter(function(id) { return id.name == grid_id});' . "\n";
		$return_string .= '							var data = attached_obj.get(dv_item[0].id);' . "\n";
		$return_string .= '							data.is_hidden = "n";' . "\n";
		$return_string .= '							attached_obj.filter("#is_hidden#", "n");' . "\n";
		$return_string .= '				    	});' . "\n";
		$return_string .= '				    } else {' . "\n";
		$return_string .= '				    	$.each($(attached_obj).children("span").children("div"), function(){' . "\n";
		$return_string .= '				            var id = $(this).attr("id").split("_");' . "\n";
		$return_string .= '				            var attached_obj = eval("details_form_" + id[2] + "_" + id[3]);' . "\n";
		$return_string .= '							if (!state) { attached_obj.filter(); }' . "\n";
		$return_string .= '				            var count = attached_obj.dataCount();' . "\n";
		$return_string .= '							if (!state) { attached_obj.filter("#is_hidden#", "n"); }' . "\n";
		$return_string .= '				            if (count > 0) {tab_field_count += count;}' . "\n";
		$return_string .= '				    	});' . "\n";
		$return_string .= '				    }' . "\n";
		$return_string .= '				});' . "\n";
		$return_string .= '				if (tab_field_count > 0) {' . "\n";
		$return_string .= '					show_messagebox("Non empty tabs cannot be deleted.");' . "\n";
		$return_string .= '				} else {' . "\n";
		$return_string .= '					confirm_messagebox("Are you sure you want to delete?", function() {' . "\n";
		$return_string .= '						tabbar_' . $object_id . '.tabs(tab_id).close();' . "\n";
		$return_string .= '						context_menu_array.forEach(function(item, index){' . "\n";
		$return_string .= '							eval(item).removeItem(tab_id);' . "\n";
		$return_string .= '						});' . "\n";
		$return_string .= '					}, function() {});' . "\n";
		$return_string .= '				}' . "\n";
		$return_string .= '            	return;' . "\n";
        $return_string .= '            	break;' . "\n";
		$return_string .= '        default:' . "\n";
        $return_string .= '            	break;' . "\n";
        $return_string .= '    	}' . "\n";
        $return_string .= '		var myForm;' . "\n";
        $return_string .= '		var myPop = new dhtmlXPopup();' . "\n";
        $return_string .= '		var formData = [' . "\n";
		$return_string .= '			{type: "settings", position: "label-top", labelWidth: ui_settings["fields_size"], inputWidth: ui_settings["fields_size"]},' . "\n";
		$return_string .= '			{type: "input", label: "Tab Name", name: "tab_name", value: new_tab_name, required: true, userdata:{"validation_message":"Required Field"}},' . "\n";
		$return_string .= '			{type: "button", value: "Ok"}' . "\n";
		$return_string .= '		];' . "\n";
		$return_string .= '		myPop.attachEvent("onShow", function(){' . "\n";
		$return_string .= '			if (myForm == null) {' . "\n";
		$return_string .= '				myForm = myPop.attachForm(get_form_json_locale(formData));' . "\n";
		$return_string .= '				myForm.attachEvent("onButtonClick", function(){' . "\n";
		$return_string .= '		      		var status = validate_form(myForm);' . "\n";
		$return_string .= '					if (!status) return;' . "\n";
		$return_string .= '		      		var tab_text = myForm.getItemValue("tab_name");' . "\n";
        $return_string .= '					var dup_check = "true";' . "\n";
        $return_string .= '					tabbar_' . $object_id . '.forEachTab(function(tab){' . "\n";
		$return_string .= '					    if (strip(tab.getText()) == tab_text && tab.getId() != tab_id) {' . "\n";
		$return_string .= '					    	dup_check = "false";' . "\n";
		$return_string .= '					    	show_messagebox("Tab Name <b>" + tab_text + "</b> already exists");' . "\n";
		$return_string .= '					    	return false;' . "\n";
		$return_string .= '					    }' . "\n";
		$return_string .= '					});' . "\n";
		$return_string .= '					if (dup_check == "false") return;' . "\n";
		$return_string .= '					if (id == "rename") {' . "\n";
		$return_string .= '						tabbar_' . $object_id . '.tabs(tab_id).setText(tab_text);' . "\n";
		$return_string .= '						myPop.hide();' . "\n";
		$return_string .= '						context_menu_array.forEach(function(item, index){' . "\n";
		$return_string .= '							eval(item).setItemText(tab_id, tab_text);' . "\n";
		$return_string .= '						});' . "\n";
		$return_string .= '						return;' . "\n";
		$return_string .= '					}' . "\n";
		$return_string .= '					var tab_ids = tabbar_' . $object_id . '.getAllTabs();' . "\n";
        $return_string .= '					tabbar_' . $object_id . '.addTab(tab_id,tab_text, null, tab_ids.length-1, true, false);' . "\n";
        $return_string .= '					new_tab_array.push(tab_id);' . "\n";
        $return_string .= '					tabbar_' . $object_id . '.t[tab_id].tab.id=tab_id;' . "\n";
		$return_string .= '					inner_tab_context_menu.addContextZone(tab_id);' . "\n";
		$return_string .= '					eval(tab_id).details_layout = {};' . "\n";
		$return_string .= '					eval(tab_id).details_layout = tabbar_' . $object_id . '.cells(tab_id).attachLayout("1C");' . "\n";
		$return_string .= '					eval(tab_id).details_layout.cells("a").hideHeader();' . "\n";
		$return_string .= '					var append_html = \'<div id="data_container_\'+new_id+\'" style="width: 100%;height: 100%; overflow: auto;"><span><div id="data_container_\'+new_id+\'general_'.$function_id.'" style="width:100%;min-height:10px;"></div></span></div>\';' . "\n";
		$return_string .= '					$("#data_view_obj").append(append_html);' . "\n";
		$return_string .= '					eval(tab_id).details_layout.cells("a").attachObject("data_container_"+new_id);' . "\n";
		$return_string .= '					create_context_menu(new_id, "general", \''.$tab_menu_json.'\');' . "\n";
		$return_string .= '					attach_data_view_events(new_id, "general", \'\');' ."\n";
		$return_string .= '					context_menu_array.forEach(function(item, index){' . "\n";
		$return_string .= '						eval(item).addNewChild("move_to", null, tab_id, tab_text, false, "", "");' . "\n";
		$return_string .= '					});' . "\n";											
		$return_string .= '					myPop.hide();' . "\n";
		$return_string .= '				});' . "\n";
		$return_string .= '			}' . "\n";
		$return_string .= '			myForm.setFocusOnFirstActive();' . "\n";
		$return_string .= '		});' . "\n";
		$return_string .= '		myPop.attachEvent("onBeforeHide", function(type, ev, id){' . "\n";
        $return_string .= '        	if (type == "click" || type == "esc") {' . "\n";
        $return_string .= '            	myPop.hide();' . "\n";
        $return_string .= '            	return true;' . "\n";
        $return_string .= '     	}' . "\n";
        $return_string .= '    	});' . "\n";
		$return_string .= '		var x = $(".dhxtabbar_tabs_cont_left").offset();' . "\n";
		$return_string .= '		var y = $(".dhx_cell_tabbar").height();' . "\n";
		$return_string .= '		myPop.show(x.left + 80, y, 0, 0);' . "\n";
        $return_string .= '});' . "\n";
		
		// Attach Layout
		foreach ($flattened_form_data as $key => $value) {
			$layout_namespace = $value[0][0] .  '_' . $object_id;
			$return_string .= $layout_namespace . '= {};' . "\n";
			$return_string .= $layout_namespace . '.details_layout = tabbar_' . $object_id . '.cells("' . $value[0][0] . '").attachLayout("' . $value[0][2] . '");' . "\n";

			$grid_json = array();
			$pre = strpos($value[0][4], '[');
			if ($pre === false) {
				$value[0][4] = '[' .  $value[0][4] . ']';
			}

			$grid_json = json_decode($value[0][4], true); 
			$grid_json[0]['layout_pattern'] = $value[0][2];

			foreach($grid_json as $obj) {
				if ($obj['grid_id'] == '' || $obj['grid_id'] == null) { continue; }
				// if form
				if ($obj['grid_id'] == 'FORM') {
					$return_string .= $layout_namespace . '.details_layout.cells("' . $obj['layout_cell'] . '").hideHeader();' . "\n";
					if (array_key_exists('layout_cell_height', $obj)) {
						$return_string .= $layout_namespace . '.details_layout.cells("' . $obj['layout_cell'] . '").setHeight("' . $obj['layout_cell_height'] . '");' . "\n";
					}
					$append_html = '<div id="data_container_' . $key . '" class="data_container_class">';
					foreach ($tab_fields_data[$key] as $f_key => $f_value) {
						if (array_key_exists('fieldset_name', $f_value[0])) {
							$append_html .= '<span class="fieldset"><label style = "font-size:13px" id=' . $f_value[0]['fieldset_id'] . '>' . trim($f_value[0]['fieldset_label']) . '</label><input onfocus="this.value = this.value;" style="height: 18px; display: none;" class="" size="10" type="" value="' . trim($f_value[0]['fieldset_label']) . '"/>';
							$append_html .= '<div id="data_container_'.$key.$f_key.'_'.$function_id.'" class="data_container_inner_class" style="width:97%;min-height:10px;border:1.3px solid darkgray;"></div>';
						} else {
							$append_html .= '<span>';
							$append_html .= '<div id="data_container_'.$key.$f_key.'_'.$function_id.'" class="data_container_inner_class"></div>';
						}
						$append_html .= '</span>';
						$return_string .= 'create_context_menu("'.$key.'", "'.$f_key.'", \''.$tab_menu_json.'\');' . "\n";
					}
					$append_html .= '</div>';
					$return_string .= '$("#data_view_obj").append(\'' . $append_html . '\');' . "\n";
					
					$return_string .= 'function create_context_menu(key, f_key, tab_menu_json) {' ."\n";
					$return_string .= ' context_menu_array.push("dataview_context_menu_" + key + f_key + '.$function_id.');' . "\n";
					// Create Context Menu
					$return_string .= ' var context_menu_obj = "dataview_context_menu_" + key + f_key + '.$function_id.';' ."\n";
					$return_string .= ' var data_view_obj = "details_form_" + key + f_key;' ."\n";
					$return_string .= '	eval(context_menu_obj + " = new dhtmlXMenuObject()");' . "\n";
					$return_string .= '	eval(context_menu_obj).renderAsContextMenu();' . "\n";
					$return_string .= '	var menu_obj = \'[{id:"hide_show", text:"Hide"},{id:"enable_disable", text:"Disable"},{id:"toogle_required", text:"Toggle Required"},{id:"rename", text:"Rename"},{id:"remove", text:"Remove"},{id:"add", text:"Add"},{id:"move_to", text:"Move To ...", items:[\'+tab_menu_json+\']}]\';' . "\n";
					$return_string .= ' eval(context_menu_obj).loadStruct(menu_obj);' . "\n";
					$return_string .= ' eval(context_menu_obj).attachEvent("onClick", function(menu_id, view_item_id) {' . "\n";
					$return_string .= '		var selected_array = eval(data_view_obj).getSelected(true);' . "\n";
					$return_string .= '		var req_item = selected_array.filter(function(id) {' ."\n";
					$return_string .= '			var data = eval(data_view_obj).get(id);' ."\n";
					$return_string .= '			return (data.insert_required == "y" && data.value == "");' ."\n";
					$return_string .= '		});' ."\n";
					$return_string .= '		switch (menu_id) {' . "\n";
					$return_string .= '			case "rename":' . "\n";
					$return_string .= '				eval(data_view_obj).edit(view_item_id);' . "\n";
					$return_string .= '				break;' . "\n";
					$return_string .= '			case "hide_show":' . "\n";
					$return_string .= '				var hide_or_show_text = eval(context_menu_obj).getItemText("hide_show"); ' ."\n";
					$return_string .= '				if (hide_or_show_text != "Show") {' . "\n";
					$return_string .= '					if (req_item.length > 0 ) {' ."\n";
					$return_string .= '						show_messagebox("Required field with no default value cannot be hidden.");' . "\n";
					$return_string .= '						return;' ."\n";
					$return_string .= '					}' ."\n";
					$return_string .= '				}' . "\n";
					$return_string .= '				for (var i = 0; i < selected_array.length; i++) {' . "\n";
					$return_string .= '					var data = eval(data_view_obj).get(selected_array[i]);' . "\n";
					$return_string .= '					data.is_hidden = (data.is_hidden == "y") ? "n" : "y";' . "\n";
					$return_string .= '					eval(data_view_obj).refresh(selected_array[i]);' . "\n";
					$return_string .= '				}' . "\n";
					$return_string .= '				auto_hide_show_items();' . "\n";
					$return_string .= '				break;' . "\n";
					$return_string .= '			case "toogle_required":' . "\n";
					$return_string .= '				for (var i = 0; i < selected_array.length; i++) {' . "\n";
					$return_string .= '					var data = eval(data_view_obj).get(selected_array[i]);' . "\n";
					$return_string .= '					data.insert_required = (data.insert_required == "y") ? "n" : "y";' . "\n";
					$return_string .= '					eval(data_view_obj).refresh(selected_array[i]);' . "\n";
					$return_string .= '				}' . "\n";
					$return_string .= '				break;' . "\n";
					$return_string .= '			case "enable_disable":' . "\n";
					$return_string .= '				var enable_or_disable_text = eval(context_menu_obj).getItemText("enable_disable"); ' ."\n";
					$return_string .= '				if (enable_or_disable_text != get_locale_value("Enable")) {' . "\n";
					$return_string .= '					if (req_item.length > 0 ) {' ."\n";
					$return_string .= '						show_messagebox("Required field with no default value cannot be disabled.");' . "\n";
					$return_string .= '						return;' ."\n";
					$return_string .= '					}' ."\n";
					$return_string .= '				}' ."\n";
					$return_string .= '				for(var i = 0; i < selected_array.length; i++) {' . "\n";
					$return_string .= '					var data = eval(data_view_obj).get(selected_array[i]);' . "\n";
					$return_string .= '					if (data.disabled == "y") {' . "\n";
					$return_string .= '						data.disabled = "n";' . "\n";
					$return_string .= '					} else {' . "\n";
					$return_string .= '						data.disabled = "y";' . "\n";
					$return_string .= '					}' . "\n";
					$return_string .= '					eval(data_view_obj).refresh(selected_array[i]);' . "\n";
					$return_string .= '				}' . "\n";
					$return_string .= '				break;' . "\n";
					$return_string .= '			case "move_to":' . "\n";
					$return_string .= '				break;' . "\n";
					$return_string .= '			case "add":' . "\n";
					$return_string .= '		      	var new_id = (new Date()).valueOf();' . "\n";
        			$return_string .= '		      	var new_id = new_id + "_y";' . "\n";
        			$return_string .= '		      	var tab_id = "detail_tab_" + new_id' . "\n";
        			$return_string .= '				var data = eval(data_view_obj).get(view_item_id);' . "\n";
        			$return_string .= '		      	var tab_text = data.label' . "\n";
        			$return_string .= '				var tab_ids = tabbar_' . $object_id . '.getAllTabs();' . "\n";
        			$return_string .= '				tabbar_' . $object_id . '.addTab(tab_id, tab_text, null, tab_ids.length-1, true, false);' . "\n";
        			$return_string .= '				tabbar_' . $object_id . '.t[tab_id].tab.id = tab_id;' . "\n";
					$return_string .= '				inner_tab_context_menu.addContextZone(tab_id);' . "\n";
					$return_string .= '				eval(tab_id).details_layout = {};' . "\n";
					$return_string .= '				eval(tab_id).details_layout = tabbar_' . $object_id . '.cells(tab_id).attachLayout("1C");' . "\n";
					$return_string .= '				eval(tab_id).details_layout.cells("a").setText(tab_text);' . "\n";
					$return_string .= '				var grid_obj = eval(tab_id).details_layout.cells("a").attachGrid();' . "\n";
        			$return_string .= '				get_udt_grid_data(data.application_field_id, grid_obj, data.name);' . "\n";
					$return_string .= '				data.is_hidden = "y";' . "\n";
					$return_string .= '				eval(data_view_obj).filter("#is_hidden#", "n");' . "\n";
					$return_string .= '				break;' . "\n";
					$return_string .= '			default:' . "\n";
					$return_string .= '				var is_remove = "n";' . "\n";
					$return_string .= '				if (menu_id == "remove") {' . "\n";
					$return_string .= '					var is_remove = "y";' . "\n";
					$return_string .= '					menu_id = "detail_tab_' . $function_id . '_n";' . "\n";
					$return_string .= '				}' . "\n";
					$return_string .= '				var tab_id_array = menu_id.split("_");' . "\n";
					$return_string .= '				var target_view = "details_form_" + tab_id_array[2] + "_" + tab_id_array[3] + "general";' . "\n";
					$return_string .= '				eval(target_view).unselectAll();' . "\n";
					$return_string .= '				var selected_count = selected_array.length;' . "\n";
					$return_string .= '				var state = form_builder.tabbar' . "\n";
					$return_string .= '					                    .cells(form_builder.tabbar.getActiveTab())' . "\n";
					$return_string .= '					                    .getAttachedToolbar()' . "\n";
					$return_string .= '					                    .getItemState("show_hide");' . "\n";
					$return_string .= '				if (!state) {' . "\n";
                    $return_string .= '            		eval(data_view_obj).filter();' . "\n";
                    $return_string .= '            	}' . "\n";
                    $return_string .= '				var tab_field_count = 0;' . "\n";
                    $return_string .= '				var tab_id = tabbar_' . $object_id . '.getActiveTab();' . "\n";
                    $return_string .= '				var lay_obj = tabbar_' . $object_id . '.cells(tab_id).getAttachedObject();' . "\n";
                    $return_string .= '				lay_obj.forEachItem(function(cell){' . "\n";
					$return_string .= '				    var attached_obj = cell.getAttachedObject();' . "\n";
					$return_string .= '				    if (attached_obj instanceof dhtmlXGridObject) {}' . "\n";
					$return_string .= '				    else {' . "\n";
					$return_string .= '				    	$.each($(attached_obj).children("span").children("div"), function(){' . "\n";
					$return_string .= '				            var id = $(this).attr("id").split("_");' . "\n";
					$return_string .= '				            var attached_obj = eval("details_form_" + id[2] + "_" + id[3]);' . "\n";
					$return_string .= '				            var count = attached_obj.dataCount();' . "\n";
					$return_string .= '				            if (count > 0) {tab_field_count += count;}' . "\n";
					$return_string .= '				    	});' . "\n";
					$return_string .= '				    }' . "\n";
					$return_string .= '				});' . "\n";
					$return_string .= '				var active_tab_id = tabbar_' . $object_id . '.getActiveTab();' . "\n";
					$return_string .= '				var active_tab_text = tabbar_' . $object_id . '.cells(active_tab_id).getText();' . "\n";
			        $return_string .= '				var tab_split_array = active_tab_id.split("_");' . "\n";
			        $return_string .= '				var is_new_tab = tab_split_array[3];' . "\n";
					$return_string .= '				if (is_new_tab == "n" && tab_field_count == selected_count && strip(active_tab_text) != "UDF") {' . "\n";
					$return_string .= '					show_messagebox("Default tabs cannot be empty.");' . "\n";
					$return_string .= '					if (!state) eval(data_view_obj).filter("#is_hidden#", "n");' . "\n";
					$return_string .= '					break;' . "\n";
					$return_string .= '				}' . "\n";
					$return_string .= '				if (!state) eval(data_view_obj).filter("#is_hidden#", "n");' . "\n";
					//## Sort the selected list of fields
					$return_string .= '				if(selected_array.length > 1) {' . "\n";
					$return_string .= '					selected_array.sort(function(a,b) {' . "\n";
					$return_string .= '						return a - b;' . "\n";
					$return_string .= '					});' . "\n";
					$return_string .= '				}' . "\n";
					$return_string .= '				for(var i = 0; i < selected_count; i++) {' . "\n";
					$return_string .= '					var data = eval(data_view_obj).get(selected_array[i]);' . "\n";
					$return_string .= '					data.group_id = tab_id_array[2] + "_" + tab_id_array[3];' . "\n";
					$return_string .= '					data.fieldset_id = "";' . "\n";
					$return_string .= '					if (tabbar_' . $object_id . '.tabs(tabbar_' . $object_id . '.getActiveTab()).getText() == "UDF") {' . "\n";
					$return_string .= '						data.application_field_id = (new Date()).valueOf();' . "\n";
					$return_string .= '					}' . "\n";
					$return_string .= '					var id = eval(target_view).last();' . "\n";
					$return_string .= '					var last_data = eval(target_view).get(id);' . "\n";
					$return_string .= '					eval(data_view_obj).move(selected_array[i], null, eval(target_view), selected_array[i]);' . "\n";
					$return_string .= '					var moved_item = eval(target_view).get(selected_array[i]);' . "\n";
					$return_string .= '					moved_item.field_seq = (last_data == undefined) ? 1 : last_data.field_seq + 1;' . "\n";
					$return_string .= '					if(is_remove == "n") {' . "\n";
					$return_string .= '						eval(target_view).select(selected_array[i], true);' . "\n";
					$return_string .= '					}' . "\n";
					$return_string .= '				}' . "\n";
					$return_string .= '				if(is_remove == "n") {tabbar_' . $object_id . '.tabs(menu_id).setActive();}' . "\n";
					$return_string .= '				break;' . "\n";
					$return_string .= '		}' . "\n";
					$return_string .= '	});' . "\n";
					$return_string .= '}' . "\n";

					foreach ($tab_fields_data[$key] as $f_key => $f_value) {
						$return_string .= $layout_namespace. '.details_layout.cells("' . $obj['layout_cell'] . '").attachObject("data_container_'.$key.'");' . "\n";
						// Attach DataView Events 
						$a = json_encode($tab_fields_data[$key][$f_key], JSON_HEX_APOS);
						$is_udf_tab = ($tab_fields_data[$key][$f_key][0]['tab_name'] == "UDF" ? "y" : "n");
		                $return_string .= ' attach_data_view_events("'.$key.'", "'.$f_key.'", \''.$a.'\', "'.$is_udf_tab.'");' ."\n";
	            	}

	            	$return_string .= 'function attach_data_view_events(key, f_key, dv_json, is_udf_tab) {' ."\n";
	            	$return_string .= ' var context_menu_obj = "dataview_context_menu_" + key + f_key + '.$function_id.';' ."\n";
					$return_string .= ' var data_view_obj = "details_form_" + key + f_key;' ."\n";
					$return_string .= ' var template_edit = \'<textarea class=\\\"dhx_item_editor\\\" bind=\\\"obj.label\\\">\';' ."\n";

					// Attach DataView
					$return_string .= '	eval(data_view_obj + \' = new dhtmlXDataView({';
	                $return_string .= '        edit: true,';
	                $return_string .= '        container: eval("data_container_" + key + f_key +"_"+'.$function_id.'),';
	                $return_string .= '        type: {';
	                $return_string .= '            template: function(item){';
					$return_string .= '				var html = "<div><div><label> "+item.label+ (item.type=="grid" ? " (T)" : "") + "<span style=\\\"color:red;\\\">"+(item.insert_required == "y" ? "&nbsp;*" : "") + "</span></label></div><div class=\\\"dhxform_control\\\">";';
					$return_string .= '				';
					$return_string .= '				if (item.type == "input" || item.type == "calendar" || item.type == "phone")';
					$return_string .= '					html += "<input style=\\\"width:166px;\\\" class=\\\"field_click\\\" type=\\\"text\\\" value=\\\""+item.value+"\\\" />";';
					$return_string .= '				else if (item.type == "combo" || item.type == "combo_v2") {';
					$return_string .= '					html += "<select class=\\\"field_click\\\" style=\\\"width:170px;\\\">";';
					$return_string .= '					html += "<option value=\\\"\\\"></option>";';
					$return_string .= '					if (item.options != undefined) {';
					$return_string .= '						item.options.forEach(function (data) {';
					$return_string .= '							html += "<option value=\\\""+data.value+"\\\""+ (item.value == data.value ? "selected" : "" ) + ">"+data.text+"</option>";';
					$return_string .= '						});';
                    $return_string .= '					}';
                    $return_string .= '					html += "</select>";';
					$return_string .= '				}';
					$return_string .= '				else if (item.type == "radio") {';
					$return_string .= '					if (item.list != undefined) {';
					$return_string .= '						item.list.forEach(function (data) {';
					$return_string .= '							html += "<input class=\\\"field_click\\\" type=\\\"radio\\\" name=\\\""+data.name+"\\\" value=\\\""+data.value+"\\\" "+ (item.value == data.value ? "checked" : "" ) + ">"+data.label+"<br>"';
					$return_string .= '						});';
					$return_string .= '					}';
					$return_string .= '				}';
					$return_string .= '			 	else if (item.type == "browser" || item.type == "template" || item.type == "multiselect")';
					$return_string .= '			 		html += "<input disabled style=\\\"width:166px;\\\" type=\\\"text\\\" value=\\\""+item.value+"\\\"/>";';
					$return_string .= '			 	else if (item.type == "grid")';
					$return_string .= '			 		html += "<input disabled style=\\\"width:166px;\\\" type=\\\"text\\\"/>";';
					$return_string .= '			 	else if (item.type == "checkbox")';
					$return_string .= '			 		html += "<input class=\\\"field_click\\\" type=\\\"checkbox\\\"" + (item.value == "y" ? "checked" : "") + " />";';
                    $return_string .= '				html += "</div><div>";';
					$return_string .= '				html += "<span style=\\\"color:grey;\\\"> "+(item.is_hidden == "y" ? "(" + get_locale_value("Hidden") + ")" : "" )+"</span>";';
					$return_string .= '				html += "<span style=\\\"color:grey;\\\"> "+(item.disabled == "y" ? "(" + get_locale_value("Disabled") + ")" : "" )+" </span>";';
					$return_string .= '				if (is_udf_tab == "n") html += "<span style=\\\"color:grey;\\\"> "+(item.udf_template_id != "" ? "(UDF)" : "" )+" </span>";';
					$return_string .= '				html += "</div></div>";';
					$return_string .= '				return html;';
	                $return_string .= '            },';
	                $return_string .= '            template_edit: template_edit,';
	                $return_string .= '            padding: 10,';
	                $return_string .= '            height: 40,';
	                $return_string .= '            width : 170,';
	                $return_string .= '        },';
	                $return_string .= '        tooltip: {';
	                $return_string .= '            template: "<b>" + get_locale_value("Original Label") + ": #original_label#</b>"';
	                $return_string .= '        },';
	                $return_string .= '        drag: true,';
	                $return_string .= '        select: "multiselect",';
	                $return_string .= '        height: "auto",';
	                $return_string .= '    });\')' . "\n";
	            	$return_string .= ' eval(data_view_obj).attachEvent("onSelectChange", function(sel_arr) {' . "\n";
	            	$return_string .= '		if (sel_arr != undefined) {' . "\n";
	                $return_string .= '			for (var i = 0; i < sel_arr.length; i++) {' . "\n";
	                $return_string .= '				var child_id = dependent_combo_data[sel_arr[i]];' . "\n";
	                $return_string .= '				if (child_id != undefined && child_id != sel_arr[i]) {' . "\n";
	                $return_string .= '					if (eval(data_view_obj).isSelected(sel_arr[i])) {' . "\n";
					$return_string .= '						if (sel_arr[sel_arr.length-1] == child_id)' . "\n";
					$return_string .= '							eval(data_view_obj).select(child_id, true);' . "\n";
					$return_string .= '						if (!eval(data_view_obj).isSelected(child_id) || sel_arr[sel_arr.length-1] == child_id)' . "\n";
					$return_string .= '						 	eval(data_view_obj).select(child_id, true);' . "\n";
	                $return_string .= '					} else {' . "\n";
	                $return_string .= '						if (eval(data_view_obj).isSelected(child_id)) {' . "\n";
	                $return_string .= '						 	eval(data_view_obj).unselect(child_id);' . "\n";
	                $return_string .= '						}' . "\n";
	                $return_string .= '					}' . "\n";
	                $return_string .= '				}' . "\n";
					$return_string .= '			}' . "\n";
					$return_string .= '		}' . "\n";
	                $return_string .= '	});' . "\n";
                	$return_string .= ' eval(data_view_obj).attachEvent("onItemDblClick", function(id, ev, html) {' . "\n";
	                $return_string .= '		return false;' . "\n";
					$return_string .= '	});' . "\n";
	            	$return_string .= ' eval(data_view_obj).attachEvent("onBeforeEditStop", function(id) {' . "\n";
	                $return_string .= '		var data = eval(data_view_obj).get(id);' . "\n";
	                $return_string .= '		old_label = data.label;' . "\n";
					$return_string .= '	});' . "\n";
	                $return_string .= ' eval(data_view_obj).attachEvent("onAfterEditStop", function(id) {' . "\n";
	                $return_string .= '		var data = eval(data_view_obj).get(id);' . "\n";
	                $return_string .= '		var status = check_label_existance(id, data.label, "");' . "\n";
	                $return_string .= '		if (status) {' . "\n";
	                $return_string .= '			data.label = old_label;' . "\n";
	                $return_string .= '			eval(data_view_obj).refresh(id);' . "\n";
	                $return_string .= '		}' . "\n";
					$return_string .= '	});' . "\n";
					$return_string .= ' eval(data_view_obj).attachEvent("onBeforeDrag", function(context,ev) {' . "\n";
					$return_string .= '		if (!eval(data_view_obj).isSelected(context.start)) return false;' . "\n";
					$return_string .= '		if (eval(data_view_obj).isEdit() != null || strip(tabbar_' . $object_id . '.tabs(tabbar_' . $object_id . '.getActiveTab()).getText()) == "UDF") {' . "\n";
					$return_string .= '			return false;' . "\n";
					$return_string .= '		}' . "\n";
					$return_string .= '		if(context.source.length > 1) {' . "\n";
					$return_string .= '			context.source.sort(function(a,b) {' . "\n";
					$return_string .= '				return a - b;' . "\n";
					$return_string .= '			});' . "\n";
					$return_string .= '		}' . "\n";
					$return_string .= '	});' . "\n";
	                $return_string .= '	eval(data_view_obj).attachEvent("onAfterDrop", function (context,ev){' . "\n";
					$return_string .= '	    var find_obj = "data_container_" + key;' . "\n";
					$return_string .= '	    var find_length = find_obj.length;' . "\n";
					$return_string .= '	    var target_fieldset_id = context.to.$view.id.substring(find_length).split("_");' . "\n";
					$return_string .= '	    var target_fieldset_id = target_fieldset_id[0];' . "\n";
					$return_string .= '		var view_obj = "details_form_" + key + target_fieldset_id;' . "\n";
					$return_string .= '		var count = eval(data_view_obj).dataCount();' . "\n";
				    $return_string .= '     for (i = 0; i < count; i++) {' . "\n";
				    $return_string .= '         var id = eval(data_view_obj).idByIndex(i);' . "\n";
				    $return_string .= '         var data = eval(data_view_obj).get(id);' . "\n";
				    $return_string .= '         data.field_seq = i + 1;' . "\n";
				    $return_string .= '	    	if (target_fieldset_id == "general")' . "\n";
					$return_string .= '	    		data.fieldset_id = "";' . "\n";
					$return_string .= '	    	else' . "\n";
					$return_string .= '	        	data.fieldset_id = target_fieldset_id;' . "\n";
				    $return_string .= '     }' . "\n";
					$return_string .= '		return true;' . "\n";
					$return_string .= '	});' . "\n";
					$return_string .= '	eval(data_view_obj).attachEvent("onXLE", function (){' . "\n";
					$return_string .= '		var count = eval(data_view_obj).dataCount();' . "\n";
					$return_string .= '		for (i = 0; i < count; i++) {' . "\n";
				    $return_string .= '         var id = eval(data_view_obj).idByIndex(i);' . "\n";
				    $return_string .= '         var data = eval(data_view_obj).get(id);' . "\n";
				    $return_string .= '         data.field_seq = i + 1;' . "\n";
				    $return_string .= '     }' . "\n";
				    $return_string .= '     $("#data_container_" + key + f_key).css("height","100%");' . "\n";
					$return_string .= '	});' . "\n";
					$return_string .= '	eval(data_view_obj).attachEvent("onBeforeEditStart", function (id){' . "\n";
					$return_string .= '		if (tabbar_' . $object_id . '.tabs(tabbar_' . $object_id . '.getActiveTab()).getText() == "UDF") {' . "\n";
					$return_string .= '			return false;' . "\n";
					$return_string .= '		}' . "\n";
					$return_string .= '	});' . "\n";
	                // Attach Context Menu
	                $return_string .= '	eval(data_view_obj).attachEvent("onBeforeContextMenu",function(id,e){' . "\n";
					$return_string .= '		eval(context_menu_obj).hideItem("detail_tab_'.$function_id.'_n");' . "\n";
					$return_string .= '		var active_tab_id = tabbar_' . $object_id . '.getActiveTab();' . "\n";
					$return_string .= '		var active_tab_text = tabbar_' . $object_id . '.cells(active_tab_id).getText();' . "\n";
					$return_string .= '		eval(context_menu_obj).hideItem(active_tab_id);' . "\n";
					$return_string .= '		eval(context_menu_obj).hideItem("add");' . "\n";
					$return_string .= '		if (strip(active_tab_text) == "UDF") {' . "\n";
					$return_string .= '			eval(context_menu_obj).hideItem("remove");' . "\n";
					$return_string .= '			eval(context_menu_obj).hideItem("toogle_required");' . "\n";
					$return_string .= '			eval(context_menu_obj).hideItem("enable_disable");' . "\n";
					$return_string .= '			eval(context_menu_obj).hideItem("hide_show");' . "\n";
					$return_string .= '			eval(context_menu_obj).hideItem("rename");' . "\n";
					$return_string .= '			var data = eval(data_view_obj).get(id);' . "\n";
					$return_string .= '			if (data.type == "grid") {' . "\n";
					$return_string .= '				eval(context_menu_obj).hideItem("move_to");' . "\n";
					$return_string .= '				var tab_add_disable = "' . $tab_add_disable . '"' .  "\n";
					$return_string .= '				if (tab_add_disable == "false") {' . "\n";
					$return_string .= '				eval(context_menu_obj).showItem("add");' . "\n";
					$return_string .= '		}' . "\n";
					$return_string .= '			} else {' . "\n";
					$return_string .= '				eval(context_menu_obj).showItem("move_to");' . "\n";
					$return_string .= '		}' . "\n";
					$return_string .= '		}' . "\n";
                    $return_string .= '		var selected_array = eval(data_view_obj).getSelected(true);' . "\n";
                    $return_string .= '		if (selected_array.length == 0 || selected_array.indexOf(id) == -1) return false;' . "\n";
                    $return_string .= '		var a = 0, b = 0, c = 0, d = 0, f = 0, g = 0;' . "\n";
                    $return_string .= '		for(var i = 0; i < selected_array.length; i++) {' . "\n";
                    $return_string .= '			var data = eval(data_view_obj).get(selected_array[i]);' . "\n";
                    $return_string .= '			if (a == 0 || b == 0) {' . "\n";
	                $return_string .= '    			if (data.disabled == "y") ' . "\n";
	                $return_string .= '    				var a = 1;' . "\n";
	                $return_string .= '    			else' . "\n";
	                $return_string .= '    				var b = 1;' . "\n";
	                $return_string .= '    		}' . "\n";
	                $return_string .= '    		if (c == 0 || d == 0) {' . "\n";
	                $return_string .= '    			if (data.is_hidden == "y") ' . "\n";
	                $return_string .= '    				var c = 1;' . "\n";
	                $return_string .= '    			else' . "\n";
	                $return_string .= '    				var d = 1;' . "\n";
	                $return_string .= '    		}' . "\n";
	                $return_string .= '    		if (f == 0 || g == 0) {' . "\n";
	                $return_string .= '    			if (data.udf_template_id == "") ' . "\n";
	                $return_string .= '    				var f = 1;' . "\n";
	                $return_string .= '    			else' . "\n";
	                $return_string .= '    				var g = 1;' . "\n";
	                $return_string .= '    		}' . "\n";
	                $return_string .= '    		if (a == 1 && b == 1 && c == 1 && d == 1 && f == 1 && g == 1) return;' . "\n";
                    $return_string .= '		}' . "\n";
					$return_string .= '		if (a != b || c != d) var data = eval(data_view_obj).get(selected_array[0]);' . "\n";
					$return_string .= '		if (a != b) { if (data.disabled == "y") {' . "\n";
					$return_string .= '			eval(context_menu_obj).setItemText("enable_disable", get_locale_value("Enable"));' . "\n";
					$return_string .= '		} else if (data.disabled == "n") {' . "\n";
					$return_string .= '			eval(context_menu_obj).setItemText("enable_disable", get_locale_value("Disable"));' . "\n";
					$return_string .= '		}eval(context_menu_obj).setItemEnabled("enable_disable");} else { eval(context_menu_obj).setItemDisabled("enable_disable");}' . "\n";
                    $return_string .= '		if (c != d) { if (data.is_hidden == "y") {' . "\n";
					$return_string .= '			eval(context_menu_obj).setItemText("hide_show", "Show");' . "\n";
					$return_string .= '		} else if (data.is_hidden == "n") {' . "\n";
					$return_string .= '			eval(context_menu_obj).setItemText("hide_show", "Hide");' . "\n";
					$return_string .= '		}eval(context_menu_obj).setItemEnabled("hide_show");} else { eval(context_menu_obj).setItemDisabled("hide_show");}' . "\n";
					$return_string .= '		if (f != g) { if (data.udf_template_id == "") {' . "\n";
					$return_string .= '			eval(context_menu_obj).setItemDisabled("remove");' . "\n";
					$return_string .= '			eval(context_menu_obj).setItemDisabled("toogle_required");' . "\n";
					$return_string .= '		} else {' . "\n";
					$return_string .= '			eval(context_menu_obj).setItemEnabled("remove");' . "\n";
					$return_string .= '			eval(context_menu_obj).setItemEnabled("toogle_required");' . "\n";
					$return_string .= '		}} else {' . "\n";
					$return_string .= '			 eval(context_menu_obj).setItemDisabled("remove");' . "\n";
					$return_string .= '			 eval(context_menu_obj).setItemDisabled("toogle_required");' . "\n";
					$return_string .= '		}' . "\n";
					$return_string .= '		eval(context_menu_obj)._doOnContextBeforeCall(e,{id:id});' . "\n";
                    $return_string .= '		return 	false;' . "\n";
					$return_string .= '	});' . "\n";
					$return_string .= '	eval(data_view_obj).on_click.field_click = function(e){' . "\n";
					$return_string .= '		var itemId = this.locate(e);' . "\n";
					$return_string .= '		var a = this;' . "\n";
					$return_string .= '		var node_name = e.target.nodeName.toLowerCase();' . "\n";
					$return_string .= '		if (node_name == "input") {' . "\n";
					$return_string .= '			var type = $(e.target).attr("type").toLowerCase();' . "\n";
					$return_string .= '			if (type == "text" || type == "date") {' . "\n";
					$return_string .= '				$(e.target).change(function () {' . "\n";
					$return_string .= '					a.get(itemId).value = (e.target||e.srcElement).value;' . "\n";
					$return_string .= '				});' . "\n";
					$return_string .= '			} else if (type == "checkbox") {' . "\n";
					$return_string .= '				a.get(itemId).value = ((e.target||e.srcElement).checked == true ? "y" : "n");' . "\n";
					$return_string .= '			} else if (type == "radio") {' . "\n";
					$return_string .= '				a.get(itemId).value = (e.target||e.srcElement).value;' . "\n";
					$return_string .= '			}' . "\n";
					$return_string .= '		} else if (node_name == "select") {' . "\n";
					$return_string .= '			$(e.target).change(function () {' . "\n";
					$return_string .= '				a.get(itemId).value = (e.target||e.srcElement).value;' . "\n";
					$return_string .= '			});' . "\n";
					$return_string .= '		}' . "\n";
					$return_string .= '	};' . "\n";
					$return_string .= ' eval(data_view_obj).parse(dv_json, "json");' . "\n";
	                $return_string .= ' eval(data_view_obj).sort(function(a,b) {return parseInt(a.field_seq) > parseInt(b.field_seq) ? 1 : -1;}, "asc");' . "\n";
	                $return_string .= ' eval(data_view_obj).filter("#is_hidden#", "n");' . "\n";
					$return_string .= '}' . "\n";
				} else {
					//if Grid					
					$paging_div = 'detail_' . $obj['layout_cell'] .'_' . $key .'_' . $object_id;
					$return_string .= $layout_namespace . ".details_layout.cells('" . $obj['layout_cell'] . "').attachStatusBar({" . "\n";
                    $return_string .= "     height: 30," . "\n";
                    $return_string .= "     text: '<div id=\'" . $paging_div . "\'></div>'" . "\n";
                    $return_string .= "  });" . "\n";
					$return_string .= $layout_namespace . '.details_layout.cells("' . $obj['layout_cell'] . '").setText("' . $obj['grid_label'] . '");' . "\n";

					$grid_obj = 'grid_' . $key;
					$menu_obj = 'menu_' . $key;
					$return_string .= $obj['grid_id'] .  '_' . $object_id . '= {};' . "\n";
					$grid_obj_withnamespace = $obj['grid_id'] .  '_' . $object_id . '.' . $grid_obj;
					$menu_obj_withnamespace = $obj['grid_id'] .  '_' . $object_id . '.' . $menu_obj;
					
					$return_string .= $grid_obj_withnamespace . '= ' . $layout_namespace. '.details_layout.cells("' . $obj['layout_cell'] . '").attachGrid();' . "\n";
					
					// create grid using definition in adiha_grid_definition
					$$grid_obj = new GridTable($obj['grid_id'], true, ($builder_mode != 0 ? $builder_mode : ""));
    				$return_string .= $$grid_obj->init_grid_table($grid_obj, $obj['grid_id'] .  '_' . $object_id, 'n');
    				$return_string .= $$grid_obj->set_search_filter(true, ""); //for inline filter.
    				$return_string .= $$grid_obj->enable_paging(5, $paging_div, 'true');
    				$return_string .= $$grid_obj->set_user_data("", "grid_id", $obj['grid_id']);
    				$return_string .= $$grid_obj->set_user_data("", "grid_obj", $obj['grid_id'] .  '_' . $object_id);
					$return_string .= $$grid_obj->set_user_data("", "grid_label", $obj['grid_label']);
    				$return_string .= $$grid_obj->return_init();
    				$return_string .= $$grid_obj->load_grid_data('', $object_id_with_dot,false,'',$farrms_product_id);
				}
			}
		}
	}
?>

<script type="text/javascript" class="form_script">
	<?php echo $return_string; ?>
	add_reset_button();
	// en_dis_toolbar('disable', 'reset')

	$(".fieldset").dblclick(function(event){
        if (event.target.nodeName.toLowerCase() == 'label') {
            $(".fieldset").children('input[type=""]').css("display", "none");
            $(".fieldset").children('label').css("display", "block");
            $(this).children('label').css("display", "none");
            $(this).children('input[type=""]').css("display", "block");
            $(this).children('input[type=""]').focus();
        }
    });

    $(".fieldset").children('input[type=""]').on('keyup', function (e) {
		var label = $(this).parent().children('input[type=""]').val();
	    $(this).parent().children('label').html(label);
	    // keyCode 13 == Enter
	    if (e.keyCode == 13) {
	        $(this).parent().children('input[type=""]').css("display", "none");
		    $(this).parent().children('label').css("display", "block");
	        return false;
	    }
	});

    enter_edit_grid_header();

	// $('div[id^="data_container_"]').css("height","100%");
</script>