<?php
/**
* Compose email screen
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
		$form_namespace = 'compose_email';
        $form_obj = new AdihaStandardForm($form_namespace, 10104900);
		$form_obj->define_grid('email_configuration', '', 'a');
		$form_obj->define_layout_width(260);
        $form_obj->define_custom_functions('save_data', 'load_form', 'delete_data');
        echo $form_obj->init_form('Compose Email', 'Compose Email');
        echo $form_obj->close_form();

        $rights_compose_email_iu = 10104910;
        $rights_compose_email_del = 10104911;

        list (
        	$has_rights_compose_email_iu,
        	$has_rights_compose_email_del
        ) = build_security_rights(
        	$rights_compose_email_iu,
        	$rights_compose_email_del
		);
		
		$template_type_options = str_replace(",selected: true", "", adiha_form_dropdown("EXEC spa_email_setup @flag=t", 0, 1));
    ?>
</body>

<script type="text/javascript">
	var has_rights_compose_email_iu = Boolean('<?php echo $has_rights_compose_email_iu ?>');
	var has_rights_compose_email_del = Boolean('<?php echo $has_rights_compose_email_del ?>');

	var active_according_id = "";
	var template_name_global = "";
	var template_id_global = "";
	var form_name = [];	

	$(function() {
		compose_email.menu.removeItem("t2");
		
		compose_email.acc_grid.forEachItem(function(cell) {
			var id = cell.getId();
			if (compose_email.acc_grid.cells(id).isOpened()) {				
				active_according_id = id;
			}    		
		});

		compose_email.acc_grid.attachEvent("onActive", function(id) {
			active_according_id = id
		});

		compose_email.Invoice_Mail.enableMultiselect(true);
		compose_email.Login_Credentials.enableMultiselect(true);
		compose_email.Login_Credentials_Update.enableMultiselect(true);
		compose_email.Workflow.enableMultiselect(true);
		compose_email.OTP_Notification.enableMultiselect(true);
	});
	
	var opened_tab_win_obj_arr = [];
	compose_email.load_form = function(win,tab_id, grid_obj, acc_id) {
		opened_tab_win_obj_arr[tab_id] = win;
		var is_new = win.getText();
		var compose_email_tab_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
		
		var template_id, flag;
		
		if (is_new == get_locale_value('New')) {
			template_id = "";
			template_name = acc_id;
			flag = "n";
		} else {
			template_id = compose_email_tab_id;
			if(template_id == ""){
				template_id = template_id_global;
				template_id_global = '';
			}

			template_name = "";
			flag = "a"; 
		}

		var getToolbar = compose_email.tabbar.cells(tab_id).getAttachedToolbar();
		
		if (has_rights_compose_email_iu) {
			getToolbar.enableItem('save');
		} else {
			getToolbar.disableItem('save');
		}
		
		var data = {"action": "spa_email_setup", "flag": flag, "template_id": template_id, "template_name": template_name};
		adiha_post_data('return_array', data, '', '', 'compose_email.load_forms_value');
	}
	
	compose_email.load_forms_value = function(result) {
		var new_add;
		
		var template_type_options = '<?php echo $template_type_options;?>';	
		
		if(result[0][0] == get_locale_value("New")) {
			new_add = 1;
			template_type = result[0][1].replace(/_/g, " ");
			template_type_options = template_type_options.replace('text:"' + template_type + '"', 'text:"' + template_type + '",selected: true'); 
		}
		
		var active_tab_id = compose_email.tabbar.getActiveTab();
		var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
		
		var template_id = "", tempalte_type = "", template_name = "", default_email = "", email_subject = "", email_body = "", default_check = "";
		
		if(new_add != 1) {
			template_id = result[0][0];
			template_type = result[0][1];
			template_name = result[0][2];
			default_email = result[0][3];
			email_subject= result[0][4];
			email_body =result[0][5];
		
			template_type_options = template_type_options.replace('value:"' + template_type + '"', 'value:"' + template_type + '",selected: true'); 
			
			if(result[0][3] == "y") {
				default_check = ", checked: true, disabled: true,";
			}
		}

		var form_structure = '[';
		form_structure += ',{type: "block", blockoffset: ' + ui_settings['block_offset'] + ', list:['
		form_structure += '{type:"input", name: "template_id", label:get_locale_value("Template ID"), inputWidth:1,  value:"' + template_id + '", hidden:"true", position: "label-top"}';
		form_structure += ',{type: "newcolumn"}';
		form_structure += ',{type:"combo", disabled: true, name: "module_type", label:get_locale_value("Template Type"),  inputWidth: ' + ui_settings['field_size'] +', options:' + template_type_options + ', position: "label-top", labelWidth: "auto" }';		
		form_structure += ',{type: "newcolumn"}';
		form_structure += ',{type:"input", name:"template_name", label:get_locale_value("Template Name"), inputWidth:' + ui_settings['field_size'] +', value:"' + template_name + '",validate:"NotEmpty", userdata:{validation_message:"Required Field"}, required: "true", position: "label-top", offsetLeft: ' + ui_settings['offset_left'] + ' }';
		form_structure += ',{type: "newcolumn"}';			
		form_structure += ',{type:"checkbox", name:"default_email",  label:get_locale_value("Default"), inputWidth:' + ui_settings['field_size'] +', position:"label-right", offsetLeft: ' + ui_settings['offset_left'] + ', offsetTop:' + ui_settings['checkbox_offset_top'] + ', value:"' + default_email + '"' + default_check + ' }';
		form_structure += ']}';
		form_structure += ',{type: "block", list:['	
		form_structure += ',{type:"input", name:"email_subject", label:get_locale_value("Subject"), required: "true", inputWidth:637, labelWidth: "auto", value:"' + email_subject + '",validate:"NotEmpty", userdata:{validation_message:"Required Field"},position: "label-top"}';
		form_structure += ']}';
		form_structure += ']';

		compose_email["inner_tab_layout_" + active_object_id] = opened_tab_win_obj_arr[active_tab_id].attachLayout({
			pattern: "2E",
			cells: [
				{id: "a", text: "a", height: 120, header: false},
				{id: "b", text: "<span id='label_email_body_title'>" + get_locale_value('Body') + "</span> <span style='font-weight:normal;color:red;'>*</span>"},
			]
		});
		form_name[active_object_id] = compose_email["inner_tab_layout_" + active_object_id].cells("a").attachForm();
		form_name[active_object_id].loadStruct(form_structure);
		
		compose_email["inner_tab_layout_" + active_object_id].cells("b").attachEditor({
			toolbar: true,
			iconsPath: js_image_path,
			content: email_body,
		});

		opened_tab_win_obj_arr[active_tab_id].progressOff();
		delete opened_tab_win_obj_arr[active_tab_id];
	};

	compose_email.save_data = function(tab_id) {
		var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
		layout_obj = compose_email["inner_tab_layout_" + object_id].cells('a').getAttachedObject();

		var editor_obj = compose_email["inner_tab_layout_" + object_id].cells('b').getAttachedObject();
		var editor_content = editor_obj.getContent();
		
		var email_subject = layout_obj.getItemValue("email_subject");
		var template_name = layout_obj.getItemValue("template_name");
		
		template_name_global = template_name;
		
		var validate_return = validate_form(form_name[object_id]);
		if (!validate_return) {
			generate_error_message();
			return;
		};
		
		var stripped_text = strip_tags(editor_content);
		if (stripped_text == '' || stripped_text == null) {
			$('#label_email_body_title + span').css('color', 'red').text(' * ' + get_locale_value('Required Field'));
			
			/*show_messagebox(message);
			dhtmlx.message({
        		text:"<span style=\"color:red; \">" + message + "</span>",
        		expire:1000,
        		type:"customCss"
    		});*/
			return false;
		} else {
			$('#label_email_body_title + span').css('color', 'red').text(' *');
		}
		
	 	compose_email.tabbar.cells(tab_id).getAttachedToolbar().disableItem("save");

		var form_xml = return_form_xml(layout_obj.getFormData(), editor_content);
		var default_email = layout_obj.getItemValue('default_email');
		var flag = return_flag(default_email);

		data = {"action": "spa_email_setup", "flag": flag,  "xml": form_xml};
		adiha_post_data("return_array", data, "", "", "save_response");
	};
		
	function save_response(result)	{
		if (has_rights_compose_email_iu) {
			compose_email.tabbar.cells(compose_email.tabbar.getActiveTab()).getAttachedToolbar().enableItem("save");
		};
		if(result[0][0] == "Success") {
			success_call(result[0][4]);

			var active_tab_id = compose_email.tabbar.getActiveTab();
			var tab_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
			var tab_index = compose_email.tabbar.tabs(active_tab_id).getIndex();		
			var grid_obj = compose_email.acc_grid.cells(active_according_id).getAttachedObject();		
			compose_email.refresh_grid();
			var form_index = "inner_tab_layout_" + tab_id
			form_index = form_index.replace(/\s/g, '');
			var form_obj = compose_email[form_index].cells("a").getAttachedObject();
			var editor_obj = compose_email[form_index].cells('b').getAttachedObject();
			var editor_content = editor_obj.getContent();
			
			if(result[0][3] == "Success")  {	
				/* 	
					1. 	From backend if the return ID is more than one seperated by 
						comma (,) then update condition no need to new create tab 
						Else if only one ID is return then it is newly created data
						Need to create new tab.
					2.	Check return ID contain comma ro not
					
				*/

				if ( result[0][5].indexOf(",") != -1 ) {
					
				compose_email.tabbar.tabs(active_tab_id).setText(form_obj.getItemValue("template_name"));
				
				} else {					
					var tab_id = "tab_"+result[0][5];
					tab_id = tab_id.replace(/\s/g, '');
					compose_email.create_tab_custom(tab_id, form_obj.getItemValue("template_name"), grid_obj, active_according_id, tab_index, result[0][5]);
					compose_email.tabbar.cells(active_tab_id).close(true);
				}

			} else {				
				var form_xml = return_form_xml(form_obj.getFormData(), editor_content);
				var default_email = form_obj.getItemValue('default_email');
				var flag = return_flag(default_email);
				
				if (flag == 'k') {
					flag = 'j';
				} else if (flag == 'v') {
					flag = 'u';
				}
				data = {"action": "spa_email_setup", "flag": flag,  "xml": form_xml};
				
				adiha_post_data("confirm-warning", data, "", "", "delete_response", "", result[0][4]);
			}
		} else if (result[0][3] == "Error") {
			show_messagebox(result[0][4]);
		}
	}
	
	compose_email.delete_data = function(grid_obj) {
		var template_id = get_template_id(grid_obj);		 
		 if (template_id == 'NULL' || template_id == null || template_id == '') {
			var message = 'Please select template.';
			
			success_call('<span style="color:red;">' + get_locale_value(message) + '</span>', 'error');

			return false;
		 }

		 var delete_xml = '<GridDelete template_id="' + template_id + '"></GridDelete>';
		 var final_xml = '<Root>' + delete_xml + '</Root>';		 
		 var data = {"action": "spa_email_setup","flag": "d", "xml": final_xml};
		 result = adiha_post_data("confirm", data, "", "", "delete_callback", "", "Are you sure you want to delete?");
	};

	function delete_callback(result){
		if (result[0].status == "Success") {
            var get_all_open_tab = compose_email.tabbar.getAllTabs();
			// tab_id = tab_id.replace(/\s/g, '');
            if (result[0].recommendation.indexOf(",") > -1) {
                var ids = result[0].recommendation.split(",");
                var count_ids = ids.length;
                for (var i = 0; i < count_ids; i++ ) {
                    full_id = 'tab_' + ids[i];
                    if( $.inArray(full_id, get_all_open_tab) != -1){
			     		compose_email.tabbar.cells(full_id).close(true);
 					}
                }
            } else {
                full_id = 'tab_' + result[0].recommendation;
                if( $.inArray(full_id, get_all_open_tab) != -1){
		     		compose_email.tabbar.cells(full_id).close(true);
		 		}
            }
            compose_email.refresh_grid();
        } else {
			compose_email.refresh_grid();
            show_messagebox(result[0].errorcode);
		}
	}

	function delete_response(result) {		
		if(result != "") {
			return_ids = result[0].recommendation.split(',');
			var tab_id = compose_email.get_tab_id(return_ids[0]);
			var form_index = "inner_tab_layout_"+return_ids[0]
			form_index = form_index.replace(/\s/g, '');

			var pre_form_index = "inner_tab_layout_"+return_ids[1];
			pre_form_index = pre_form_index.replace(/\s/g, '');

			var get_all_open_tab = compose_email.tabbar.getAllTabs();

			if( $.inArray(("tab_"+return_ids[1]).replace(/\s/g,''), get_all_open_tab) != -1){
     			var pre_form_obj = compose_email[pre_form_index].cells("a").getAttachedObject();
				pre_form_obj.enableItem("default_email");
				pre_form_obj.setItemValue("default_email",0);
 			}
			
			if(return_ids[2] != 0 ) {
				
				if(result[0].recommendation != ""){							
					
					var grid_obj = compose_email.acc_grid.cells(active_according_id).getAttachedObject();
					var selected_row = return_ids[0];
					template_id_global = return_ids[0];
					var active_tab_id = compose_email.tabbar.getActiveTab();
					var tab_name = template_name_global;
					var tab_index = compose_email.tabbar.tabs(active_tab_id).getIndex();
					compose_email.create_tab_custom(tab_id, tab_name, grid_obj, active_according_id, tab_index, return_ids[0]);
					compose_email.tabbar.cells(active_tab_id).close(true);
				}

			} else {
				var form_obj = compose_email[form_index].cells("a").getAttachedObject();
				compose_email.tabbar.tabs(tab_id).setText(form_obj.getItemValue("template_name"));
				form_obj.disableItem("default_email");
			}
		}
		compose_email.refresh_grid();
	}

	compose_email.create_tab_custom = function(full_id, text, grid_obj, acc_id, tab_index, selected_row) {
        //selected_row = false
        if (!compose_email.pages[full_id]) {
            compose_email.tabbar.addTab(full_id, text, null, tab_index, true, true);
            var win = compose_email.tabbar.cells(full_id);
            win.progressOn();
            //using window instead of tab
            var toolbar = win.attachToolbar();
            toolbar.setIconsPath(js_image_path + '/dhxtoolbar_web/');
            toolbar.loadStruct([{id: "save", type: "button", img: "save.gif", text: "Save", title: "Save"}]);
            toolbar.attachEvent("onClick", compose_email.tab_toolbar_click);
            
            compose_email.tabbar.cells(full_id).setActive();
            compose_email.tabbar.cells(full_id).setText(text);
            compose_email.load_form(win, full_id, grid_obj, acc_id);
            compose_email.pages[full_id] = win;            
         }       
    }

	function return_form_xml(form_data, editor_data) {
		var form_xml = '<FormXML ';
		
		for (var a in form_data) {
			field_name = a;
			field_value = form_data[a];
			
			form_xml += " " + field_name + "=\"" + field_value + "\"";
		}
		form_xml += ' email_body="' + escapeXML(editor_data) + '"';
		
		form_xml += "></FormXML>";
		form_xml = '<Root function_id="10104900">' + form_xml + '</Root>';		
		return form_xml;
	}

	function return_flag(default_email) {
		var flag;
		var active_tab_id = compose_email.tabbar.getActiveTab();
		
		/*
			Only New --> j
			New With defult email --> k
			Only update --> u
			Only defult --> v

		*/		
		if (active_tab_id.substr(0, 4) == 'tab_') {
			if (default_email == "y") {
				flag = 'v';
			} else {
				flag = 'u';
			}
		} else {
			if (default_email == "y") {
				flag = 'k';
			} else {
				flag = 'j';
			}
		}
		
		return flag;
	}

	function strip_tags(text) {
		var regex = /(<([^>]+)>)/ig
		var stripped_text = text.replace(regex, "");
		stripped_text =  stripped_text.replace(/&nbsp;/ig, '');
		stripped_text =  stripped_text.trim();
		return stripped_text;
	}

	function get_template_id(grid_obj) {
		var selected_row = grid_obj.getSelectedRowId();
	
		if (selected_row == '' || selected_row == null) {		
			return false;
		} else {
			var count = selected_row.indexOf(",") > -1 ? selected_row.split(",").length : 1;
			selected_row = selected_row.indexOf(",") > -1 ? selected_row.split(",") : [selected_row];
			var template_id = '';
			for (var i = 0; i < count; i++) {
				template_id += grid_obj.cells(selected_row[i], 0).getValue();
				template_id += ','
			}
			template_id = template_id.slice(0, -1);
			return template_id;
		}
	}
    
    /**
     * [Enable menu items]
     */
    compose_email.enable_menu_item = function(id, name, grid_obj) {
        var selected_row = grid_obj.getSelectedRowId();

        compose_email.menu.setItemDisabled("delete");

        if (selected_row != '') {
            if (has_rights_compose_email_del) {
                compose_email.menu.setItemEnabled("delete");
            }
        }
    }

    compose_email.refresh_grid = function(){
    	var grd_obj = compose_email.acc_grid.cells(active_according_id).getAttachedObject();
    	var grd_obj_name = 'compose_email.acc_grid.cells(' + active_according_id + ').getAttachedObject();';
    
    	grd_obj.clearAll();
    	var module_name = active_according_id.replace(/\_/g, " ");
		
        var param = {
                "action": "spa_email_setup",
                "flag": "o",
                "module_name": module_name               
                };
        param = $.param(param);
        compose_email_url = js_data_collector_url + "&" + param;
        grd_obj.loadXML(compose_email_url);
    }
	
    compose_email.get_tab_id = function(id) {
    	var tab_id = 'tab_' + id;
    	tab_id = tab_id.replace(/\s/g, '');
    	return tab_id;
    }

</script>
</html>