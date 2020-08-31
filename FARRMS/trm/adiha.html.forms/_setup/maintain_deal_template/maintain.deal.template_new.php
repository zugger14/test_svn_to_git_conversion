<?php
/**
* Maintain deal template_new screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
        <?php require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
    </head>    
	<body>
		<?php
			$form_namespace = 'maintain_udf_template_new';
			$function_id = 20008300;

			$form_obj = new AdihaStandardForm($form_namespace, 20008300);
			$form_obj->define_grid("setupUDFTemplate");		
			$form_obj->define_layout_width(375);
			$form_obj->define_custom_functions('custom_save_function', '', '', 'form_load_complete');						
			echo $form_obj->init_form( 'User Defined Fields');
			echo $form_obj->close_form();
		?>
	</body>
	<script type="text/javascript">
		var template_name = "SetupUDFTemplatenew";
		var function_id = <?php echo $function_id;?>;		
		var xml= '';	
		
		maintain_udf_template_new.form_load_complete = function() {
			var tab_id = maintain_udf_template_new.tabbar.getActiveTab();    		        
	        var win = maintain_udf_template_new.tabbar.cells(tab_id);
	        var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
	        object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(" ", ""));
	        var tab_obj = win.tabbar[object_id];
	        var general_tab = tab_obj.tabs(get_tab_id(tab_obj, 1)).getAttachedObject();
	        var general_tab_layout = general_tab.cells('a');
	        var general_tab_layout_object = general_tab_layout.getAttachedObject();

	        /* Code block added to set value for combo field data type. Combo value 'numeric(38,20)' was not being set from load method of dhtmlx using json.*/
            var data = {"action": "spa_populate_udf", "flag": "l", "udf_template_id": object_id};
            data = $.param(data);
            $.ajax({
                type: "POST",
                dataType: "json",
                url: js_form_process_url,
                async: true,
                data: data,
                success: function(result) {
                    var return_data = result['json'];
                    var data_type_value = return_data[0].data_type;
                    if (data_type_value) {
                        general_tab_layout_object.setItemValue('data_type',data_type_value);
                    }
                }
            });
            /*End of block to set combo field data type value*/
            if (general_tab_layout_object instanceof dhtmlXForm) {
	            var field_type = general_tab_layout_object.getItemValue('field_type');
	            var sql_string = general_tab_layout_object.getItemValue('sql_string');
				var combo_d_s = general_tab_layout_object.getCombo('data_source_type_id');
	            var data_source_type_id;
	            var check_update = general_tab_layout_object.getItemValue('udf_template_id');

				var field_name_combo = general_tab_layout_object.getCombo('field_name')
				field_name_combo.addOption("-999999999", "Add New", 200);
				field_name_combo.setOptionIndex(-999999999, 1);

	            if (check_update != '') {
	            	general_tab_layout_object.disableItem('field_name');
	            }

	            if (sql_string != '') {
	            	data_source_type_id = combo_d_s.getOptionByLabel('Custom').value;
	            	general_tab_layout_object.setItemValue('data_source_type_id', data_source_type_id);
					data_source_type =  combo_d_s.getComboText();
	            }

	            //load data_source_type, window or formula .
				if (field_type == 'd') {
					general_tab_layout_object.hideItem('test');
					general_tab_layout_object.showItem('data_source_type_id');
					general_tab_layout_object.hideItem('label_formula_id');
					general_tab_layout_object.hideItem('clear_formula_id');
					general_tab_layout_object.hideItem('sql_string');
					general_tab_layout_object.hideItem('default_value_date');
					general_tab_layout_object.showItem('default_value');
				} else if (field_type == 'w') {
					general_tab_layout_object.showItem('label_formula_id');
					general_tab_layout_object.showItem('clear_formula_id');
					general_tab_layout_object.hideItem('test');
					general_tab_layout_object.hideItem('data_source_type_id');
					general_tab_layout_object.hideItem('sql_string');
					general_tab_layout_object.hideItem('default_value_date');
					general_tab_layout_object.showItem('default_value');
				} else if (field_type == 'a') {
					general_tab_layout_object.hideItem('label_formula_id');
					general_tab_layout_object.hideItem('clear_formula_id');
					general_tab_layout_object.hideItem('data_source_type_id');
					general_tab_layout_object.hideItem('test');
					general_tab_layout_object.hideItem('sql_string');
					general_tab_layout_object.showItem('default_value_date');
					general_tab_layout_object.hideItem('default_value');
				}
				else {
					general_tab_layout_object.hideItem('label_formula_id');
					general_tab_layout_object.hideItem('clear_formula_id');
					general_tab_layout_object.hideItem('data_source_type_id');
					general_tab_layout_object.hideItem('test');
					general_tab_layout_object.hideItem('sql_string');
					general_tab_layout_object.hideItem('default_value_date');
					general_tab_layout_object.showItem('default_value');
				}

				if (combo_d_s.getComboText() == 'Custom') {
					general_tab_layout_object.showItem('sql_string');
					general_tab_layout_object.showItem('test');

					if (general_tab_layout_object.getItemValue('sql_string') == '') {
                        general_tab_layout_object.setItemValue('sql_string', '[<ID_1>,<NAME_1>],[<ID_2>,<NAME_2>],[<ID_3>,<NAME_3>]');
                    }
				} else {
					general_tab_layout_object.hideItem('sql_string');
					general_tab_layout_object.hideItem('test');
				}

	            general_tab_layout_object.attachEvent("onChange", function(name,value) {
	            	if (name == 'field_name') {

	            		var field_name_text = general_tab_layout_object.getCombo('field_name').getComboText();
	            		general_tab_layout_object.setItemValue("field_label", field_name_text);

	            		if (value == '-999999999') {
	            			var sdv_window;
			            	if (!sdv_window) {
			                    sdv_window = new dhtmlXWindows();
			                }
			                new_win = sdv_window.createWindow('w1', 0, 0, 295, 170);

			                var text = "Static Data Value";

			                new_win.setText(text);
			                new_win.centerOnScreen();
			                new_win.setModal(true);

			                var sdv_form_data = [
							        {type: "settings", labelWidth: 'auto', inputWidth: ui_settings['field_size'], position: "label-top", offsetLeft:ui_settings['offset_left']},
							        {type: 'newcolumn'},
							        {type: "input", name: "code", label: "Name", value : "", inputTop: 10, labelLeft:  20, labelTop: 90, "required":true, "validation_message":"Required Field"},
							        {type: "button", value: "Ok", img: "tick.png", inputTop: 10, inputLeft: 80}
							    ];

							sdv_form = new_win.attachForm(sdv_form_data, true);

	            			sdv_form.attachEvent("onButtonClick", function(name) {
	            				var static_data = sdv_form.getItemValue('code')
	            				var status = sdv_form.validate();

	            				if (status) {
	            					data = {"action": "spa_staticdatavalues", "flag":'i', "type_id" : 5500 , "code" : static_data, "description" : static_data}
									result = adiha_post_data("return_array", data, "", "", "sdv_callback");
	            				}
	            			})

	            			new_win.attachEvent("onClose", function(win) {
	            				general_tab_layout_object.getCombo('field_name').selectOption(0);
	            				return true;
	            			})
	            		}

	            	}

					if (name == 'field_type') {
						if (value == 'd') { //dropdown
							general_tab_layout_object.showItem('data_source_type_id');
							general_tab_layout_object.hideItem('label_formula_id');
							general_tab_layout_object.hideItem('clear_formula_id');
							general_tab_layout_object.hideItem('sql_string');
							general_tab_layout_object.hideItem('default_value_date');
							general_tab_layout_object.showItem('default_value');
							if (data_source_type == 'Custom') {
								general_tab_layout_object.showItem('sql_string');
								general_tab_layout_object.showItem('test');
							} else {
								general_tab_layout_object.hideItem('sql_string');
								general_tab_layout_object.hideItem('test');
							}
						} else if (value == 'w') { //formula
							general_tab_layout_object.showItem('label_formula_id');
							general_tab_layout_object.showItem('clear_formula_id');
							general_tab_layout_object.hideItem('test');
							general_tab_layout_object.hideItem('data_source_type_id');
							general_tab_layout_object.hideItem('sql_string');
							general_tab_layout_object.hideItem('default_value_date');
							general_tab_layout_object.showItem('default_value');
						} else if (value == 'a') {
							general_tab_layout_object.hideItem('label_formula_id');
							general_tab_layout_object.hideItem('clear_formula_id');
							general_tab_layout_object.hideItem('data_source_type_id');
							general_tab_layout_object.hideItem('test');
							general_tab_layout_object.hideItem('sql_string');
							general_tab_layout_object.showItem('default_value_date');
							general_tab_layout_object.hideItem('default_value');
						}
						else {
							general_tab_layout_object.hideItem('label_formula_id');
							general_tab_layout_object.hideItem('clear_formula_id');
							general_tab_layout_object.hideItem('data_source_type_id');
							general_tab_layout_object.hideItem('test');
							general_tab_layout_object.hideItem('sql_string');
							general_tab_layout_object.hideItem('default_value_date');
							general_tab_layout_object.showItem('default_value');
						}
					}
					if (name == 'data_source_type_id') {
						data_source_type_id = combo_d_s.getOptionByLabel('Custom').value;
						data_source_type =  combo_d_s.getComboText();

						if (value == data_source_type_id) {
							general_tab_layout_object.showItem('sql_string');
							general_tab_layout_object.showItem('test');
							general_tab_layout_object.setItemValue('sql_string', '[<ID_1>,<NAME_1>],[<ID_2>,<NAME_2>],[<ID_3>,<NAME_3>]');
						} else {
							general_tab_layout_object.hideItem('sql_string');
							general_tab_layout_object.hideItem('test');
						}
					}
				})

				general_tab_layout_object.attachEvent("onButtonClick", function(name){
					if (name == 'test') {
						var tsql = unescapeXML(general_tab_layout_object.getItemValue('sql_string'));
						var tsql = tsql.replace(/'/g, "\'\'");
						data = {"action": 'spa_run_sql_check', "sql_stmt":tsql}
						result = adiha_post_data('return_array',data,'','','callback_test');
					}
				})
	        }

	        // $('.dhxform_btn[title~=Validate]').closest('.dhxform_item_label_left').css('paddingLeft', '0');
	        // $('.dhxform_btn[title~=Validate]').closest('.dhxform_item_label_left').css('paddingTop', '08px');
	        $('.dhxform_btn[title~=Validate]').find('.dhxform_btn_txt').text('Validate');
		}

		function callback_test(result) {
			if (result[0][0] == 'Error') {
				dhtmlx.message({
	                text: 'Invalid Syntax, Please check the Syntax.'
	            });
			} else {
				dhtmlx.message({
	                text: 'Valid Syntax.'
	            });
			}
		}


		maintain_udf_template_new.custom_save_function = function() {
			var tab_id = maintain_udf_template_new.tabbar.getActiveTab();
            var win = maintain_udf_template_new.tabbar.cells(tab_id);
            var valid_status = 1;
			var object_id = '';
            var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
            object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(" ", ""));
			var tab_obj = maintain_udf_template_new.tabbar.cells(tab_id).getAttachedObject();

			var detail_tabs = tab_obj.getAllTabs();
            var grid_xml = "<GridGroup>";
            var form_xml = "<FormXML ";
            var field_name = ''; //to check if the sdv exists
            var field_label_value = ''; //to set the default label
            xml= '';
            var udf_template_id = '';

            $.each(detail_tabs, function(index,value) {
                layout_obj = tab_obj.cells(value).getAttachedObject();
                layout_obj.forEachItem(function(cell) {
                    attached_obj = cell.getAttachedObject();
                    if (attached_obj instanceof dhtmlXForm) {

						var status = validate_form(attached_obj);

                        if(status) {
                            data = attached_obj.getFormData();

                            for (var a in data) {
                                field_label = a;
                                field_value = data[a];

								if (field_label == 'udf_template_id') {
									udf_template_id = field_value;
                                }

                                if (field_label == 'default_value_date') {
                                	if (field_value != null)
                                		field_value = dates.convert_to_sql(field_value);
                                	else
                                		field_value = '';

	                            }

                                if (field_label == 'field_name') {
                                	var combo_field_name = attached_obj.getCombo('field_name');

                                	if (combo_field_name.getSelectedIndex() == -1){
                                		field_name = combo_field_name.getComboText();
                                	}
                                }

								form_xml += " " + field_label + "=\"" + field_value + "\"";
                            }
                        } else {
                            valid_status = 0;
                        }
                    }
                });
			});
			form_xml += "></FormXML>";
			grid_xml += "</GridGroup>";

			xml = "<Root function_id=\"" + function_id + "\" object_id=\"" + object_id + "\">";
			xml += form_xml;
			xml += grid_xml;
			xml += "</Root>";
			xml = xml.replace(/'/g, "\'\'");

			if (udf_template_id != '') {
				flag = 'u';
					object_id = udf_template_id;
			} else {
				flag = 'i';
				object_id = '';
			}

			if (valid_status == 1 && field_name == '') {
				data = {"action": "spa_populate_udf", "flag":flag, "xml":xml}
				result = adiha_post_data("alert", data, "", "", "maintain_udf_template_new.post_callback");
			}
		}

		function sdv_callback(result) {
			if (result[0][0] == 'Success') {
				new_win.close();

				var tab_id = maintain_udf_template_new.tabbar.getActiveTab();
		        var win = maintain_udf_template_new.tabbar.cells(tab_id);
		        var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
		        object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(" ", ""));
		        var tab_obj = win.tabbar[object_id];
		        var general_tab = tab_obj.tabs(get_tab_id(tab_obj, 1)).getAttachedObject();
		        var general_tab_layout = general_tab.cells('a');
		        var general_tab_layout_object = general_tab_layout.getAttachedObject();

		        if (general_tab_layout_object instanceof dhtmlXForm) {
	            	var combo_obj = general_tab_layout_object.getCombo('field_name');
	            	var cm_param = {
										"action": "[spa_StaticDataValues]",
										"flag": "h",
										"type_id": 5500
									};

					cm_param = $.param(cm_param);

					var url = js_dropdown_connector_url + '&' + cm_param;
					combo_obj.clearAll();
					combo_obj.unSelectOption();
					combo_obj.enableFilteringMode("between", null, false);
					combo_obj.load(url, function() {
						combo_obj.addOption("-999999999", "Add New");
						combo_obj.setComboValue(result[0][5]);
					});
	            }

			} else {
				dhtmlx.message({
                    type: "alert",
                    title: "Alert",
                    text: result[0][4],
                    expire:500
                });
			}
		}

	</script>>
<style type="text/css">
    [title~=Validate] {
	    top: 17px;
	    left: -15px;
	    /*border: 0.02px solid black; */
	    background-color: red!important;
	}
	[title~=Validate] .dhxform_btn_txt {
		background-color: #94D8B7;
		padding:2px 7px!important;
		border-radius: 2px;
	}
	.dhxform_btn_filler{
		padding-left:0!important;
	}
</style>

</html>