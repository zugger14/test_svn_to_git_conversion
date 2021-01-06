<?php
/**
* Data relations screen
* @copyright Pioneer Solutions
*/
?>
<!--DOCTYPE transitional.dtd-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<meta http-equiv="X-UA-Compatible" content="IE=Edge">
    <html>
        <?php
        include '../../../adiha.php.scripts/components/include.file.v3.php';
        ?>
        <?php

        $rights_form_import_customized = 10104800;
        $rules_id = isset($_GET['rules_id']) ? get_sanitized_value($_GET['rules_id']) : 'NULL';
        $relation_id = isset($_GET['relation_id']) ? get_sanitized_value($_GET['relation_id']) : 'NULL';
        $process_id = isset($_GET['process_id']) ? get_sanitized_value($_GET['process_id']) : 'NULL';
        $mode = get_sanitized_value($_GET['mode']);
        $call_from_org = isset($_GET['call_from']) ? get_sanitized_value($_GET['call_from']) : 'NULL';
        $from_custom_form = isset($_GET['from_custom_form']) ? get_sanitized_value($_GET['from_custom_form']) : 'n';
        $parent_alias = isset($_GET['parent_alias']) ? get_sanitized_value($_GET['parent_alias']) : 'AL';
        $parent_source_type = isset($_GET['parent_source_type']) ? get_sanitized_value($_GET['parent_source_type']) : 21405;

		$server_path = urlencode($BATCH_FILE_EXPORT_PATH);

		$ssis_xml_file = "EXEC spa_ixp_parameters @flag='p',@rules_id='" . $rules_id . "'";
        $return_value = readXMLURL($ssis_xml_file);
        $param_present = $return_value[0][5];
        $parent_source_type = 21405;
        $excel_sheet = '';
        $location_path = '';
        $no_of_columns = '';
        $is_customized = '';
        $is_header_less = '';
        $ssis_package = '';
        $clr_function_value = '';

        $call_from = ($call_from_org == 'immediate_run' ? 'run' : $call_from_org);

		//If called from run rule.
        if ($call_from == 'run') {
			$xml_file = "EXEC spa_ixp_init @flag='x'";
            $report_info = readXMLURL($xml_file);
            $process_id = $report_info[0][5];
            if ($mode == 'r') {
                $xml_file = "EXEC spa_ixp_import_data_source @flag='s',@rules_id='" . $rules_id . "'";
                $return_value = readXMLURL2($xml_file);
                $relation_alias = $return_value[0]['data_source_alias'] ?? '';
                $source_type = $return_value[0]['data_source_type'] ?? '';
                $source_type = 21405;
				$delim = $return_value[0]['delimiter'] ?? '';
                $no_of_columns = $return_value[0]['no_of_columns'] ?? '';
                $is_customized = $return_value[0]['custom_import'] ?? '';
                $is_header_less = $return_value[0]['is_header_less'] ?? '';
				$connection_string = $return_value[0]['connection_string'] ?? '';
                $ssis_package = $return_value[0]['ssis_package'] ?? '';
                $clr_function_value = $return_value[0]['clr_function_id'] ?? '';
            }
        } else {
            if ($mode == 'i') {
                $relation_id = 'NULL';
                $relation_name = '';
                $relation_alias = $parent_alias . "_rs1";
                $source_type = 21405;
				$connection_string = '';
                $location_path = 0;
                $delim = ',';
				$excel_sheet = '';
            } else if ($mode == 'u') {
                $xml_file = 'EXEC spa_ixp_import_relation @flag=a,@relation_id=' . $relation_id . ', @rules_id=' . $rules_id . ", @process_id='" . $process_id . "'";
                $return_value = readXMLURL($xml_file);
                $relation_id = $return_value[0][0];
                $relation_alias = $return_value[0][1];
                $source_type = $return_value[0][3];
                $delim = $return_value[0][4];
                $connection_string = '';
                $location_path = '';
                if ($source_type == 21401) {
                    $connection_string = $return_value[0][2];
                } else {
                    $location_path = $return_value[0][2];
                }
				$excel_sheet = $return_value[0][5];
            }
        }
        /*         * ************************************Combo json preparation************************************* */
        /*
         * Function to create combo json
         * @param: $array: array of the combo with value and text
         * @param: $combo_id: selected value [optional]
         * @param: $value_index: index of the value
         * @param: $text_index: index of the text
         * 
         */


        function create_template_combo_json($array, $combo_id, $value_index, $text_index, $state_index = '') {

            $option = '';
            for ($i = 0; $i < sizeof($array); $i++) {
                if ($i > 0)
                    $option.=',';
                $option .= '{"text":"' . $array[$i][$text_index] . '", "value":"' . $array[$i][$value_index] . '"';
                
                if ($state_index != '')
                    $option .= ', "state":"' . $array[$i][$state_index] . '"';
                                                
                if ($combo_id == $array[$i][$value_index]) {
                    $option .= ', "selected":"true"}';
                } else {
                    $option .= '}';
                }
            }
            return ($option);
        }

        // $category
        $ixp_category = "EXEC spa_StaticDataValues @flag='h', @type_id=23500";
        $ixp_category_array = readXMLURL($ixp_category);
        $ixp_category_json = create_template_combo_json($ixp_category_array, $ixp_category, 0, 1, 2);

        //data_source_type
        $ixp_data_source_type = "EXEC spa_StaticDataValues @flag='h', @type_id=21400";
        $ixp_data_source_type_array = readXMLURL($ixp_data_source_type);
        $ixp_data_source_type_json = create_template_combo_json($ixp_data_source_type_array, $source_type, 0, 1, 2);

        //ssis_package
        $ixp_ssis_package = "EXEC spa_ixp_ssis_configurations 's'";
        $ixp_ssis_package_array = readXMLURL($ixp_ssis_package);
        $ixp_ssis_package_json = create_template_combo_json($ixp_ssis_package_array, $ssis_package ?? '', 0, 1);

        //soap_function
        $ixp_soap_function = "EXEC spa_ixp_soap_functions 's'";
        $ixp_soap_function_array = readXMLURL($ixp_soap_function);
        // $CLR Function
        $ixp_clr_function = "EXEC spa_ixp_clr_functions @flag='s'"; 
        $ixp_clr_function_array = readXMLURL($ixp_clr_function);
        $ixp_clr_function_json = create_template_combo_json($ixp_clr_function_array, $clr_function_value ?? '', 0, 1);

        $ixp_soap_function_json = create_template_combo_json($ixp_soap_function_array, $ixp_soap_function, 0, 1);
		
		//configued_data_source
        $configued_data_source = "EXEC spa_ixp_rules @flag='3', @ixp_rules_id='" . $rules_id . "'";
        $configued_data_source_array = readXMLURL($configued_data_source);
        $configued_data_source_json = create_template_combo_json($configued_data_source_array, '', 0, 1);
        /*         * ************************************END of Combo json preparation************************************* */

        $php_script_loc = $app_php_script_loc;
        $app_user_loc = $app_user_name;
        /* start of main layout */
        $form_namespace = 'data_relation_ixp';
        $layout = new AdihaLayout();
        //json for main layout.
        /* start */
        $json = '[
            {
                id:             "a",
                text:           "Data Relation",
                header:         false,
                collapse:       false
            }
            
           
        ]';
        $save_json = '[
                        {id:"ok", type:"button", img:"tick.png", text:"OK", title:"ok"}
                    ]';
        /* end */
        //attach main layout of the screen
        echo $layout->init_layout('new_layout', '', '1C', $json, $form_namespace);
        echo $layout->attach_toolbar_cell('toolbar_save', 'a');
        $toolbar_obj = new AdihaToolbar();
        echo $toolbar_obj->init_by_attach('toolbar_save', $form_namespace);
        echo $toolbar_obj->load_toolbar($save_json);
        echo $toolbar_obj->attach_event('', 'onClick', 'data_relation_ixp.toolbar_click');

        $form_name = 'data_relation';
        echo $layout->attach_form($form_name, "a");
        echo $layout->close_layout();
        /* end of main layout */
        ?>
        <script>
//           / dhxWins11 = new dhtmlXWindows();
            var mode = "<?php echo $mode; ?>";
            var delim = "<?php echo $delim; ?>";
            var php_script_loc_ajax = "<?php echo $app_php_script_loc; ?>";
            var call_from = "<?php echo $call_from; ?>";
            var call_from_org = "<?php echo $call_from_org; ?>";
            var from_custom_form = "<?php echo $from_custom_form; ?>";
            var source_type = "<?php echo $source_type; ?>";
            var rules_id = "<?php echo $rules_id; ?>";
            var param_present = "<?php echo $param_present; ?>";
            var formData;
            var datasource_json = '';
            var param_window;
			var new_proccess_id = "<?php echo $process_id; ?>";
			var server_path = decodeURIComponent('<?php echo $server_path;?>');
            var parent_alias = "<?php echo $parent_alias; ?>";
            var new_alias_value = '';
            var parent_source_type = "<?php echo $parent_source_type ?>";
            var run_connection_string = "<?php echo $connection_string ?>";
            var data_source_type_param = "";
            var param_value = "";

            $(function() {
                if (call_from == 'run') {
					source_type = parent_source_type;
                    formData = data_relation_ixp.get_form_json('2_run');
                } else {
                    formData = data_relation_ixp.get_form_json('2');
                    source_type = parent_source_type;
                    
                    if(mode == 'i'){
                        var alias_values = parent.ixp_wizard.grid.grid_step_3.collectValues(parent.ixp_wizard.grid.grid_step_3.getColIndexById('alias'));

                        if (alias_values.length > 0){
                                new_alias_value = parent_alias + '_rs' + (parseInt(alias_values.map(function (e) {
                                  return (e.indexOf('_rs') != -1 ) ? e.split('_rs')[1] : 0;
                                }).reduce(function (a, b) {
                                  return Math.max(a, b);
                                })) + 1);
                }
                    }
                }

                data_relation_ixp.data_relation.loadStruct(formData);
                if (new_alias_value != ''){
                    data_relation_ixp.data_relation.setItemValue('data_source_alias', new_alias_value);
                }

                if (source_type == '21400' || source_type == '21405')
                    datasource_json = data_relation_ixp.get_form_json('2_file_based');
                else if (source_type == '21402')
                    datasource_json = data_relation_ixp.get_form_json('2_xml_based');
                else if (source_type == '21401')
                    datasource_json = data_relation_ixp.get_form_json('2_linked_server');
                else if (source_type == '21403')
                    datasource_json = data_relation_ixp.get_form_json('2_ssis');
                else if (source_type == '21404')
                    datasource_json = data_relation_ixp.get_form_json('2_web_server');
				else if (source_type =='21406')
					 datasource_json = data_relation_ixp.get_form_json('2_lse_file_based');
                    else if (source_type =='21407')
                     datasource_json = data_relation_ixp.get_form_json('2_CLR_FUNCTION');

                for (var q = 0; q < datasource_json.length; q++) {
                    data_relation_ixp.data_relation.removeItem('child_block');
                    data_relation_ixp.data_relation.addItem("data_source_block", {type: "newcolumn"}, q);
                    data_relation_ixp.data_relation.addItem('data_source_block', datasource_json[q], q + 1, true);
                }
                //setting the value of delimiter.
                var delim_isExist = data_relation_ixp.data_relation.isItem('delimiter');
                if (delim_isExist) {
                    var delim_combo = data_relation_ixp.data_relation.getCombo('delimiter');
                    delim_combo.setComboValue(delim);
                }
                var state = data_relation_ixp.data_relation.isItemChecked('is_header_less');
                if (state) {
                    data_relation_ixp.data_relation.showItem('num_of_columns');
                    data_relation_ixp.data_relation.setValidation('num_of_columns', 'NotEmpty,ValidNumeric');
                } else {
                    data_relation_ixp.data_relation.hideItem('num_of_columns');
                    data_relation_ixp.data_relation.clearValidation('num_of_columns');
                }

				if(call_from == 'run') {
					data_relation_ixp.data_relation.hideItem('excel_sheets');
                    data_relation_ixp.data_relation.hideItem('delimiter');
                    data_relation_ixp.data_relation.hideItem('is_header_less');
                    data_relation_ixp.data_relation.hideItem('num_of_columns');
                    data_relation_ixp.data_relation.showItem('note');
				} else {
                    var source_combo = data_relation_ixp.data_relation.getCombo('data_source_type');
                    source_combo.setComboValue(source_type);
                    data_relation_ixp.data_relation.disableItem('data_source_type');

                    if (source_type == 21405) {
                        data_relation_ixp.data_relation.showItem('excel_sheets');
                    } else if (source_type == 21400 || source_type == 20102) {
                        if(source_type == 21400) {
                            data_relation_ixp.data_relation.showItem('delimiter');
				}
                    }
                }

                /*
                 * Event for onchage of the items in the forms.
                 * @returns {undefined}                 
                 */
                data_relation_ixp.data_relation.attachEvent("onChange", function(name, value) {
                    if (name == "data_source_type") {
                        var location_isExist = data_relation_ixp.data_relation.isItem('data_source_location');
                        if (location_isExist) {
                            var myUploader = data_relation_ixp.data_relation.getUploader("data_source_location");
                            myUploader.clear();
                            data_relation_ixp.data_relation.setItemValue("file_upload_status", 0);
                        }
                        if (value == 21400 || value == 21405) {
                            var datasource_json = data_relation_ixp.get_form_json('2_file_based');
                        } else if (value == 21402) {
                            var datasource_json = data_relation_ixp.get_form_json('2_xml_based');
                        } else if (value == 21403) {
                            var datasource_json = data_relation_ixp.get_form_json('2_ssis');
                        } else if (value == 21401) {
                            var datasource_json = data_relation_ixp.get_form_json('2_linked_server');
                        } else if (value == 21404) {
                            var datasource_json = data_relation_ixp.get_form_json('2_web_server');
                        } else if (value == 21407){
                            var datasource_json = data_relation_ixp.get_form_json('2_CLR_FUNCTION');
                        }

                        for (var q = 0; q < datasource_json.length; q++) {
                            data_relation_ixp.data_relation.removeItem('child_block');
                            data_relation_ixp.data_relation.addItem("data_source_block", {type: "newcolumn"}, q);
                            data_relation_ixp.data_relation.addItem('data_source_block', datasource_json[q], q + 1, true);
                        }
                    } else if (name == 'is_header_less') {
                        if(call_from != 'run'){
                            var state = data_relation_ixp.data_relation.isItemChecked('is_header_less');
                            if (state) {
                                data_relation_ixp.data_relation.showItem('num_of_columns');
                                data_relation_ixp.data_relation.setValidation('num_of_columns', 'NotEmpty,ValidNumeric');
                            } else {
                                data_relation_ixp.data_relation.hideItem('num_of_columns');
                                data_relation_ixp.data_relation.clearValidation('num_of_columns');
                            }
                        }
                    } /*else if(name == 'configued_data_source'){
                           if(value == 21403){
                                data_source_type_param = value;
                           } else if(value == 21407) {
                                data_source_type_param = value;
                           }
                    }*/
                    
                    if (value == 21405) {
                        data_relation_ixp.data_relation.showItem('excel_sheets');
                    } else if (value == 21400 || value == 20102) {
                        if(value == 21400 && call_from != 'run') {
							data_relation_ixp.data_relation.showItem('delimiter');
                        }
                        data_relation_ixp.data_relation.hideItem('excel_sheets');
                    }
					
					if (call_from == 'run') {
						data_relation_ixp.data_relation.hideItem('excel_sheets');
                    
					} else {
                    var state = data_relation_ixp.data_relation.isItemChecked('is_header_less');
                    if (state) {
                            data_relation_ixp.data_relation.showItem('num_of_columns');
                            data_relation_ixp.data_relation.setValidation('num_of_columns', 'NotEmpty,ValidNumeric');
                        } else {
                            data_relation_ixp.data_relation.hideItem('num_of_columns');
                            data_relation_ixp.data_relation.clearValidation('num_of_columns');
                        }
                    }
                    
                });

                /*Events for file upload.*/
                data_relation_ixp.data_relation.attachEvent("onUploadFile", function(realName, serverName) {
                    var f_name = data_relation_ixp.data_relation.getItemValue("file_upload_status");
                    if (f_name == '' || f_name == '0') {
                        f_name = serverName;
                    } else {
                        f_name = f_name + ',' + serverName;
                    }
                    
                    data_relation_ixp.data_relation.setItemValue("file_upload_status", f_name);

                    if(f_name.substring(f_name.lastIndexOf('.')+1, f_name.length) == 'csv' && call_from == 'run'){
                        data_relation_ixp.data_relation.showItem('delimiter');
                        data_relation_ixp.data_relation.showItem('is_header_less');
						var configued_data_source_cmb = data_relation_ixp.data_relation.getCombo('configued_data_source');
						configued_data_source_cmb.selectOption(0);
						data_relation_ixp.data_relation.hideItem('configued_data_source');
                    } else if (call_from == 'run'){
                        data_relation_ixp.data_relation.hideItem('delimiter');
                        data_relation_ixp.data_relation.hideItem('is_header_less');
						data_relation_ixp.data_relation.hideItem('advance_option');
                   }
				});

                data_relation_ixp.data_relation.attachEvent("onClear", function() {
                    data_relation_ixp.data_relation.setItemValue("file_upload_status", 0);
                    data_relation_ixp.data_relation.hideItem('delimiter');
                    data_relation_ixp.data_relation.hideItem('is_header_less');
					data_relation_ixp.data_relation.showItem('advance_option');
                    data_relation_ixp.data_relation.showItem('configued_data_source');
                });
                data_relation_ixp.data_relation.attachEvent("onFileRemove",function(realName,serverName){
                    data_relation_ixp.data_relation.setItemValue("file_upload_status", 0);
					data_relation_ixp.data_relation.hideItem('delimiter');
                    data_relation_ixp.data_relation.hideItem('is_header_less');
					data_relation_ixp.data_relation.showItem('advance_option');
                    data_relation_ixp.data_relation.showItem('configued_data_source');
               });
                data_relation_ixp.data_relation.attachEvent("onUploadFail", function(realName) {
                    show_messagebox("Could not upload the file. Please check the format."); 
                });

                data_relation_ixp.data_relation.attachEvent("onUploadComplete", function(count) {
                    var myUploader = data_relation_ixp.data_relation.getUploader("data_source_location");
                    if (count > 1) {
                        myUploader.clear();
                        data_relation_ixp.data_relation.setItemValue("file_upload_status", 0);
                        show_messagebox("Please upload only one file.");
                    } else {
                        var data_source_type = data_relation_ixp.data_relation.getItemValue('data_source_type');
                        if (data_source_type == 21405 && call_from != 'run') {
                            var server_path_file = server_path + '\\' + data_relation_ixp.data_relation.getItemValue("file_upload_status");
                            var cm_param = {
                                                "action": "spa_ixp_rules", 
                                                "flag": "z",
                                                "server_path": server_path_file
                                            };

                            cm_param = $.param(cm_param);
                            var url = js_dropdown_connector_url + '&' + cm_param;
							var excel_sheets_cmb = data_relation_ixp.data_relation.getCombo('excel_sheets');
                            excel_sheets_cmb.load(url);
                        }
                    }
                });
                
                /*
                data_relation_ixp.data_relation.attachEvent("onFileAdd", function(realName) {
                    var upload_status = data_relation_ixp.data_relation.getItemValue('file_upload_status');
                    var myUploader = data_relation_ixp.data_relation.getUploader("data_source_location");
                    if (upload_status != 0) {
                        myUploader.clear();
                        data_relation_ixp.data_relation.setItemValue("file_upload_status", 0);
                        dhtmlx.alert({
                            title:"Error",
                            type:"alert-error",
                            text:"Please upload only one file."
                        }); 
                    }
                });
                /*END of Events for file upload.*/


            });
            data_relation_ixp.toolbar_click = function(id) {
                var customized_query = data_relation_ixp.data_relation.getItemValue('customized_query');
                var process_id = new_proccess_id;
                var rules_id = "<?php echo $rules_id; ?>";
                if (id == 'ok') {
                    data_relation_ixp.toolbar_save.disableItem('ok');
					var configued_data_source = data_relation_ixp.data_relation.getItemValue('configued_data_source');
					if (configued_data_source == -1) {
						var enable_ftp = 1;
						configued_data_source = 21400;
					} else {
						var enable_ftp = 0;
					}
					var location_isExist = data_relation_ixp.data_relation.isItem('data_source_location');
                    var data_source_type = data_relation_ixp.data_relation.getItemValue('data_source_type');
					if (configued_data_source == null) { configued_data_source = ''; }
					if (configued_data_source != '') {
						data_source_type = 	configued_data_source
					}
                    
                    data = {
                        "action": "spa_ixp_parameters",
                        "flag": "p",
                        "rules_id": rules_id,
                        "data_source_type": data_source_type
                    };

                    data = $.param(data) ;

                    $.ajax({
                        type: "POST",
                        dataType: "json",
                        url: js_form_process_url,
                        async: false,
                        data: data,
                        success: function(data) {
                            response_data = data["json"];
                            response_data = JSON.stringify(response_data);
                            result = JSON.parse(response_data);
                            param_value = result[0].recommendation;
                        }
                     });
                    param_present = param_value

					if (enable_ftp == 1 || data_source_type == 21401) {
						parent.data_ixp.run_batch(data_source_type, enable_ftp);
						parent.data_ixp.new_run_win.close();
						return;
					}

                    if (location_isExist && data_source_type != 21401) {
                        var upload_status = data_relation_ixp.data_relation.getUploaderStatus('data_source_location');
                        var folder_location = data_relation_ixp.data_relation.getItemValue('file_upload_status');

                        //to check if the file is uploaded or not.
                        if (folder_location == 0 && call_from == 'run' && data_source_type != 21404 && param_present != 'y') {
                            parent.data_ixp.run_batch(data_source_type);
                            parent.data_ixp.new_run_win.close();
                            return;
                        } else if (folder_location == 0 && param_present != 'y') {
                            show_messagebox("The file has not been uploaded.");
                            return;
                        }
							
						if (folder_location.indexOf('.xls') >= 0 || folder_location.indexOf('.xlsx') >= 0) {
							source_type = 21405;
						} else if (folder_location.indexOf('.csv') > 0 && folder_location.indexOf('.txt') >= 0) {
							source_type = 21400;
						} else if (folder_location.indexOf('.xml') > 0) {
							source_type = 21402;
						} else if (folder_location.indexOf('.json') > 0) {
                            source_type = 21408;
                        }   
							
                        // File Extension validation
                        if (source_type == 21405 &&  param_present != 'y'){
                            if((folder_location.indexOf('.xls') == -1) && (folder_location.indexOf('.xlsx') == -1) && (folder_location.indexOf('.csv') == -1)){
                                show_messagebox("The file extension is invalid. Please upload file with extension 'xls' or 'xlsx' or 'csv'.");
                                return; 
                            }
                        } else if (source_type == 21400 && param_present != 'y') {
                            if((folder_location.indexOf('.xls') == -1) && (folder_location.indexOf('.xlsx') == -1) &&
                                (folder_location.indexOf('.csv') == -1) && (folder_location.indexOf('.txt') == -1)){
                                show_messagebox("The file extension is invalid. Please upload file with extension 'csv' or 'xlsx' or 'txt'.");
                                return; 
                            }
                        } else if (source_type == 21408 && param_present != 'y') {
                            if(folder_location.indexOf('.json') == -1) {
                                show_messagebox("The file extension is invalid. Please upload file with extension 'json'.");
                                return; 
                            }
                        }
                        
                        //to check if the file is still uploading.
                        if (upload_status == -1) {
                            show_messagebox("The file has not been uploaded.");
                            return;
                        }
                    } else if (data_source_type == 21401 && param_present != 'y'){
                        var folder_location = data_relation_ixp.data_relation.getItemValue('file_upload_status');
                        var connection_string = data_relation_ixp.data_relation.getItemValue('connection_string');
                        connection_string = (connection_string == '') ? run_connection_string : connection_string;
                         if (folder_location == 0 && connection_string == ''){
                            show_messagebox("Either upload Source File or provide Remote Data Source."); 
                            return;
                         }
                    }

                    var upload_status = data_relation_ixp.data_relation.getUploaderStatus('data_source_location');
                    //to check if the file is still uploading.
                    if (upload_status == -1 &&  param_present != 'y') {
                        location = 0;
                        show_messagebox("The file has not finished uploading.");
                        return;
                    }
                    var status = data_relation_ixp.data_relation.validate();
					if (call_from == 'run') {
						var relation_source_type = data_source_type;
					} else {
						var relation_source_type = data_relation_ixp.data_relation.getItemValue('data_source_type');
                    }
					
                    if (!status) {
                       data_relation_ixp.data_relation.setNote('data_source_alias', {
                            text: "Required Field", width:300
                        }); 
                       return false;                      
                    }
                    if (status) {

                        var value_data_source_alias = data_relation_ixp.data_relation.getItemValue('data_source_alias');
                        if (!value_data_source_alias.match(/^[a-zA-Z0-9\-\_]{1,}$/)) {  
                            data_relation_ixp.data_relation.setNote('data_source_alias', {
                                text: "", width:300
                            });         
                            show_messagebox("Space is not allowed.");
                            return false;
                        }

                        data_relation_ixp.new_layout.progressOn();
                        if (call_from != 'run') {
                            var connection_string = data_relation_ixp.data_relation.getItemValue('connection_string');
                            var delimiter = data_relation_ixp.data_relation.getItemValue('delimiter');
                            var folder_location = data_relation_ixp.data_relation.getItemValue('file_upload_status');
							var relation_alias = data_relation_ixp.data_relation.getItemValue('data_source_alias');
							var excel_sheet = data_relation_ixp.data_relation.getItemValue('excel_sheets');
                            if (!connection_string)
                                connection_string = 'NULL';
                            data = {"action": "spa_ixp_import_relation",
                                "flag": mode,
                                "process_id": new_proccess_id,
                                "rules_id": "<?php echo $rules_id; ?>",
                                "relation_id": "<?php echo $relation_id; ?>",
                                "relation_source_type": relation_source_type,
                                "connection_string": connection_string,
                                "relation_location": folder_location,
                                "delimiter": delimiter,
                                "relation_alias": relation_alias,
								"excel_sheet":excel_sheet

                            };
                            result = adiha_post_data("alert", data, "", "", "data_relation_ixp.callback_saving_relations");
                        }
                        //when it is called from run.
                        else {
                            //IF SSIS and called from run. Also checks if the param is present or not.
                            if ((relation_source_type == '21403'|| (relation_source_type == '21407')) && (param_present == 'y')) {
                                data_relation_ixp.open_parameter_window(relation_source_type);
                            }
                            else {
                                //as there is a new item custom query when called from run.
                                var custom_enabled = data_relation_ixp.data_relation.getItemValue('custom_query');
                                
                                if (custom_enabled == 0 || custom_enabled == 'n')
                                    custom_enabled = 'n';
                                else
                                    custom_enabled = 'y';
                                data = {"custom_enabled": custom_enabled,
										"enable_ftp": enable_ftp,
                                    "call_from": call_from_org
                                };
                                data_relation_ixp.run_generic_import(data);
                            }
                        }
                    }
                }

            }
              data_relation_ixp.callback_saving_relations = function(result) {
                if (result[0].errorcode == 'Success') {
                    var relation_source_type = data_relation_ixp.data_relation.getItemValue('data_source_type');
					var configued_data_source = data_relation_ixp.data_relation.getItemValue('configued_data_source');
					if (configued_data_source == null) { configued_data_source = ''; }
					if (configued_data_source != '') {
						relation_source_type = 	configued_data_source
					}
                    //To run only in flat file.
                    if (relation_source_type == 21400 || relation_source_type == 21405) {
                        data_relation_ixp.run_generic_import();
                    }
                    data_relation_ixp.new_layout.progressOff();
                }
                else{
                    data_relation_ixp.new_layout.progressOff();
                }
                
            }
            //To run only in flat file.
            data_relation_ixp.run_generic_import = function(additional_data) {
				var process_id = new_proccess_id;
				var relation_source_type = data_relation_ixp.data_relation.getItemValue('data_source_type');
				var configued_data_source = data_relation_ixp.data_relation.getItemValue('configued_data_source');
				if (configued_data_source == null) { configued_data_source = ''; }
				if (configued_data_source != '') {
					relation_source_type = 	configued_data_source
				}
                var connection_string = data_relation_ixp.data_relation.getItemValue('connection_string');
                var delimiter = data_relation_ixp.data_relation.getItemValue('delimiter');
                var folder_location = data_relation_ixp.data_relation.getItemValue('file_upload_status');
                var relation_alias = data_relation_ixp.data_relation.getItemValue('data_source_alias');
                var num_of_columns = data_relation_ixp.data_relation.getItemValue('num_of_columns');
                var is_header_less = data_relation_ixp.data_relation.getItemValue('is_header_less');
				var excel_sheet = data_relation_ixp.data_relation.getItemValue('excel_sheets');
                if (is_header_less == 0 || is_header_less == 'n')
                    is_header_less = 'n';
                else
                    is_header_less = 'y';
                
                if (folder_location == '' || folder_location == null) {
                    var file_name = '';
                } else {
					var file_arr = folder_location.split(',');
                    var file_name = file_arr[0].toString();
                }

                if(source_type == 21408)
                    relation_source_type = 21408;

                data = {    
                            "file_name": (file_name == '') ? "NULL" : file_name,
                            "m_file_name": (folder_location == null) ? "NULL" : folder_location,
                            "relation_source": relation_source_type,
                            "process_id": process_id,
                            "rules_id": rules_id,
                            "delim": (delimiter == null) ? "NULL" : delimiter,
                            "is_header_less": (is_header_less == null) ? "NULL" : is_header_less,
                            "no_of_columns": (num_of_columns == null) ? "NULL" : num_of_columns,
                            "alias": relation_alias,
							"connection_string": (connection_string == '') ? run_connection_string : connection_string,
                            "alias":relation_alias,
							"excel_sheet": (excel_sheet == null) ? "NULL" : excel_sheet
                        };

                url = php_script_loc_ajax + "spa_generic_import.php";
                if (additional_data)
                    data = $.param(data) + '&' + $.param(additional_data);
                else
                    data = $.param(data);

                $.ajax({
                    type: "POST",
                    dataType: "json",
                    url: url,
                    data: data,
                    success: function(data) {
                       if (call_from != 'run') {
                            data_relation_ixp.new_layout.progressOff();
                            if(data['status']!='Success'){
                                show_messagebox(data['message']);
                            } else {
                                parent.refresh_data_relation_grid();
                                parent.close_data_relation_window();
                            }
                        }
                        else {
                            data_relation_ixp.new_layout.progressOff();
                            data_relation_ixp.toolbar_save.enableItem('ok');
                            if(data['status']=='Success'){
                                success_call(data['message']);
                                data_relation_ixp.data_relation.disableItem('data_source_location');
                                setTimeout(function(){
                                    parent.data_ixp.new_run_win.close();
                                }, 1000);
                            } else {
                                show_messagebox(data['message']);    
                            }
							if(from_custom_form == 'y'){
								//alert(process_id)
								parent.refresh_relation_grid(process_id,relation_alias)
								parent.run_volatility_calucalation.new_run_win.close();
								
							}

							
							if (relation_source_type == 21403) {
								ssis_param_win.progressOff();
							}
                    }
                    },
                    error: function(xht) {
                        data_relation_ixp.new_layout.progressOff();
                        show_messagebox('Alert');
                    }

                });
				set_new_process_id();
            }

            /**
             * [get_form_json Get Form Json]
             * @param  {[varchar]} step [Step Id]
             */
            data_relation_ixp.get_form_json = function(step) {
                var form_template = _.template($('#template_step' + step).text());
                formData = form_template();
                formData = get_form_json_locale($.parseJSON(formData));
                return formData;
            }
            data_relation_ixp.save_callback = function(result) {
                alert(result);
                // parent.close_data_relation_window();
            }
            /*
             * Opens the parameter window.
             * @returns {undefined}             
             */
            data_relation_ixp.open_parameter_window = function(data_source_type) {
                data_relation_ixp.new_layout.progressOff();
                var process_id = new_proccess_id;
                unload_parameter_window();
                ssis_param = new dhtmlXWindows();
				ssis_param_win = ssis_param.createWindow('w2', 0, 0, 700, 450);
                var text = "Parameters";
                ssis_param_win.setText(text);
                var url = 'data.import.export.parameters.php?rules_id=' + rules_id + '&data_source_type=' + data_source_type + '&process_id=' + process_id;
                ssis_param_win.attachURL(url, false, true);
                //parent.close_run_wizard();
            }
			
			/*
             * 
             */
            function  close_ssis_run_window(){
				setTimeout("ssis_param.window('w2').close()",1000);
            }
            /*
             * Closes the parameter window.
             * @returns {undefined}             
             */
            function close_parameter_window() {
                data_relation_ixp.new_run_win.close();
                //as there is a new item custom query when called from run.
                var custom_enabled = data_relation_ixp.data_relation.getItemValue('custom_query');
                if (custom_enabled == 0 || custom_enabled == 'n')
                    custom_enabled = 'n';
                else
                    custom_enabled = 'y';
                data = {"custom_enabled": custom_enabled,
                        "call_from": call_from
                    };
                data_relation_ixp.run_generic_import(data);
            }

            /*
             * Unloads the parameter window. 
             */
            function unload_parameter_window() {
                if (data_relation_ixp.param_window != null && data_relation_ixp.param_window.unload != null) {
                    data_relation_ixp.param_window.unload();
                    data_relation_ixp.param_window = w2 = null;
                }
            }
			
			function set_new_process_id() {
				data = {"action": "spa_ixp_init",
                                "flag": "x"
						};
				result = adiha_post_data("return_json", data, "", "", "set_new_process_id_callback");
			}
			
			function set_new_process_id_callback(result) {
				var return_data = JSON.parse(result);
				new_proccess_id = return_data[0].recommendation;
			}
        </script>
        <script id="template_step2" type="text/template">
            [{"type": "settings", "position": "label-top"},
            {"type": "block", "name":"data_source_block" ,"blockOffset": 10, "list": [
            {"type": "block", "name":"datasource_header" ,"blockOffset": 0, "list": [
            {"type": "input", "name": "ixp_import_data_source_id", "label": "ixp_import_data_source_id", "validate": "", "hidden": "true", "disabled": "false", "value": "", "offsetLeft": "10", "labelWidth": "210", "inputWidth": "200", "tooltip": "ixp_import_data_source_id"},
            {"type": "combo", "name": "data_source_type", "label": "Date Source", "validate": "NotEmpty",  "value": "", "labelWidth": "210", "inputWidth": "200", "tooltip": "Source System", "filtering": "true", "options": [<?php echo $ixp_data_source_type_json; ?>]},
            {"type": "newcolumn"},
            {"type": "input", "name": "data_source_alias", "label": "Alias(Without Space)","disabled": "true" , "inputWidth": "220", "validate": "NotEmpty", "tooltip": "Alias(Without Space)","offsetLeft": "28","required":true,"value":"<?php echo $relation_alias; ?>"},
            {"type": "newcolumn"}
            ]}
            ]}
            ]
        </script>
        <script id="template_step2_run" type="text/template">
            [
                {"type": "settings", "position": "label-top"},
            {"type": "input", "name": "ixp_import_data_source_id", "label": "ixp_import_data_source_id", "validate": "", "hidden": "true", "disabled": "false", "value": "", "offsetLeft": "10", "labelWidth": "210", "inputWidth": "200", "tooltip": "ixp_import_data_source_id"},
                {"type": "combo", "name": "data_source_type", "label": "Data Source", "offsetLeft": "30", "hidden": "true", "disabled":"true", "validate": "NotEmpty",  "value": "", "labelWidth": "230", "inputWidth": "200", "tooltip": "Source System", "filtering": "true", "options": [<?php echo $ixp_data_source_type_json; ?>],"required":true},
                {"type": "input", "name": "data_source_alias", "hidden": "true", "label": "Alias (Without Space)", "validate": "NotEmpty", "labelWidth": "210", "inputWidth": "200", "tooltip": "Alias (Without Space)","value":"<?php echo $relation_alias; ?>","required":true,"offsetLeft":30},
                {"type": "checkbox", "name": "custom_query", "hidden": "true", "label": "Use Custom Query", "position": "label-right", "tooltip": "Use Custom Query", "checked": "<?php echo $is_customized; ?>", "offsetTop":"25","offsetLeft":30}
            ]
        </script>
        <!-- File Based Import -->
        <script id="template_step2_file_based" type="text/template">
            [
            {"type": "block", "name":"child_block","blockOffset":0,
            "list": [                
            <?php echo ($call_from != 'run' ? ('{"type": "combo", "name": "delimiter", "label": "Delimiter", "validate": "", "value": "", "offsetLeft": "0", "inputWidth": "200","tooltip": "Delimiter", "filtering": "true", "options": [{"value": ",", "text": "Comma"}, {"value": ":", "text": "Colon"}, {"value": ";", "text": "Semi Colon"}, {"value": "\\\\t", "text": "Tab"}, {"value": "|", "text": "Vertical Bar(Pipe)"}],"required":true},
                        {"type": "checkbox", "name": "is_header_less", "label": "Source File Without Header", "position": "label-right", "labelWidth": "210", "inputWidth": "200", "checked": "' . ($is_header_less == 'y' ? 1 : 0) . '", "offsetLeft": "0","offsetTop":"20"},') : ''); ?>
            {"type": "input", "name": "num_of_columns", "label": "Number of Columns","validate": "NotEmpty,ValidNumeric", "labelWidth": "210", "inputWidth": "200", "offsetTop":"10", "value": "<?php echo $no_of_columns; ?>"},
            {"type": "combo", "name": "excel_sheets", "label": "Excel Sheet", "validate": "", "value": "", "labelWidth": "210", "inputWidth": "200", "tooltip": "Excel Sheet", "filtering": "true", "hidden": "true", "options": [{"value":"<?php echo $excel_sheet; ?>", "text":"<?php echo $excel_sheet; ?>"}]},
            {"type": "newcolumn"},
            {"type": "fieldset", "label": "Data Source Location","offsetLeft":"30", "offsetTop":"15", "width":"500","list": [
				{"type": "upload", "name": "data_source_location", "autoStart":true, "inputWidth": "475", "url": "<%= js_file_uploader_url %>&call_form=data_import_export", "mode": "html5"}
            ]},
            {"type": "input", "name": "file_upload_status", "label": "file_upload_status", "validate": "", "hidden": "true", "value": "<?php echo $location_path; ?>"},
			
			<?php echo ($call_from == 'run' ? ('{"type": "block", "name":"child_block","blockOffset":0,
            "list": [{"type": "fieldset", "label": "Advance Option", "name":"advance_option","offsetLeft":"30", "offsetTop":"15", "width":"500","list": [
						{"type": "combo", "name": "configued_data_source", "label": "Import Option",  "value": "", "labelWidth": "200", "inputWidth": "200", "offsetLeft":"30", "tooltip": "Import Option", "filtering": "true", "options": [' . $configued_data_source_json . ']},
						{"type": "combo", "name": "delimiter", "label": "Delimiter", "validate": "", "value": "", "offsetLeft": "29", "inputWidth": "200","tooltip": "Delimiter", "filtering": "true", "options": [{"value": ",", "text": "Comma"}, {"value": ":", "text": "Colon"}, {"value": ";", "text": "Semi Colon"}, {"value": "\\\\t", "text": "Tab"}, {"value": "|", "text": "Vertical Bar(Pipe)"}],"required":true}, {"type": "newcolumn"},
                        {"type": "checkbox", "name": "is_header_less", "label": "Source File Without Header", "position": "label-right", "labelWidth": "210", "inputWidth": "200", "checked": "' . ($is_header_less == 'y' ? 1 : 0) . '", "offsetLeft": "29","offsetTop":"20"}
					]}
				]},') : ''); ?>
            {  
                                                    "type": "label",
                                                    "name": "note",
                                                    "hidden": "true",
                                                    "label": "<h5>&#128712; Note</br>- If import data source file is not uploaded then system will auto import data from folder location defined</br>&nbsp;&nbsp;in this import rule.</br>- Supported File Format - Excel, CSV. </br>- Date Format in the file must be same as User's Profile Date Format.</h5>",
                                                    "offsetLeft": "10",
                                                    "inputTop": "0",
                                                    "offsetTop":"0",
                                                    "labelWidth": "auto",
                                                    "inputWidth": "auto"
                                                }
            ]}
            ]
        </script> 
        <!-- File Based Import -->
        <!-- LSE File Based Import -->
        <script id="template_step2_lse_file_based" type="text/template">
            [
            {"type": "block", "name":"child_block","blockOffset":0,
            "list": [                
            {"type": "combo", "name": "delimiter", "label": "Delimiter", "validate": "", "value": "", "labelWidth": "210", "inputWidth": "200", "tooltip": "Delimiter", "filtering": "true", "hidden": "true" , "options": [{"value": ",", "text": "Comma"}, {"value": ":", "text": "Colon"}, {"value": ";", "text": "Semi Colon"}, {"value": "\\\\t", "text": "Tab"}, {"value": "|", "text": "Vertical Bar(Pipe)"}],"required":true},
            {"type": "checkbox", "name": "is_header_less", "label": "Source File Without Header", "position": "label-right", "labelWidth": "210", "inputWidth": "200", "checked": "<?php echo ($is_header_less == 'y')?1:0; ?>", "offsetTop":"20"},
            {"type": "input", "name": "num_of_columns", "label": "Number of Columns","validate": "NotEmpty,ValidNumeric", "labelWidth": "210", "inputWidth": "200", "offsetTop":"10", "value": "<?php echo $no_of_columns; ?>"},
            {"type": "combo", "name": "excel_sheets", "label": "Excel Sheet", "validate": "", "value": "", "labelWidth": "210", "inputWidth": "200", "tooltip": "Excel Sheet", "filtering": "true", "hidden": "true", "options": [{"value":"<?php echo $excel_sheet; ?>", "text":"<?php echo $excel_sheet; ?>"}]},
            {"type": "newcolumn"},
            {"type": "fieldset", "label": "Data Source Location","offsetLeft":"30", "offsetTop":"15","list": [
            {"type": "upload", "name": "data_source_location", "autoStart":true, "inputWidth": "440", "url": "<%= js_file_uploader_url %>&call_form=data_import_export", "mode": "html5"}
            ]},
            {"type": "input", "name": "file_upload_status", "label": "file_upload_status", "validate": "", "hidden": "true", "value": "<?php echo $location_path; ?>"},
            {  
                                                    "type": "label",
                                                    "name": "note",
                                                    "hidden": "true",
                                                    "label": "<h5>&#128712; Note</br>- If import data source file is not uploaded then system will auto import data from folder location defined</br>&nbsp;&nbsp;in this import rule.</h5>",
                                                    "offsetLeft": "10",
                                                    "inputTop": "0",
                                                    "labelWidth": "auto",
                                                    "inputWidth": "auto"
                                                }
            ]}
            ]
        </script> 
        <!-- XML Based Import -->
        <!-- XML File Based Import -->
        <script id="template_step2_xml_based" type="text/template">
            [
            {"type": "block", "name":"child_block","blockOffset":0,
            "list": [
                {"type": "fieldset", "label": "Data Source Location","offsetLeft":"29", "offsetTop":"15","list": [
                    {"type": "upload", "name": "data_source_location", "autoStart":true, "inputWidth": "440", "url": "<%= js_file_uploader_url %>&call_form=data_import_export", "mode": "html5"}
                ]},
                {"type": "input", "name": "file_upload_status", "label": "file_upload_status", "validate": "", "hidden": "true", "value": "<?php echo $location_path; ?>"},
                {"type": "input", "name": "file_upload_status", "label": "file_upload_status", "validate": "", "hidden": "true", "value": "<?php echo $location_path; ?>"},
                <?php echo ($call_from == 'run' ? ('{"type": "block", "name":"child_block","blockOffset":0,
            "list": [{"type": "combo", "name": "delimiter", "label": "Delimiter", "validate": "", "value": "", "offsetLeft": "29", "inputWidth": "200","tooltip": "Delimiter", "filtering": "true", "options": [{"value": ",", "text": "Comma"}, {"value": ":", "text": "Colon"}, {"value": ";", "text": "Semi Colon"}, {"value": "\\\\t", "text": "Tab"}, {"value": "|", "text": "Vertical Bar(Pipe)"}],"required":true}, {"type": "newcolumn"},
                        {"type": "checkbox", "name": "is_header_less", "label": "Source File Without Header", "position": "label-right", "labelWidth": "210", "inputWidth": "200", "checked": "' . ($is_header_less == 'y' ? 1 : 0) . '", "offsetLeft": "29","offsetTop":"10"}]},') : ''); ?>
                {  
                                                    "type": "label",
                                                    "name": "note",
                                                    "hidden": "true",
                                                    "label": "<h5>&#128712; Note</br>- If import data source file is not uploaded then system will auto import data from folder location defined</br>&nbsp;&nbsp;in this import rule.</br>- Supported File Format - XML, Excel, CSV </h5>",
                                                    "offsetLeft": "10",
                                                    "inputTop": "0",
                                                    "labelWidth": "auto",
                                                    "inputWidth": "auto"
                                                }
                ]
            }]
        </script>
        <!-- LSE File Based Import -->
        <!-- Linked Server Import -->
        <script id="template_step2_linked_server" type="text/template">
            [
            {"type": "block",  "name":"child_block","blockOffset":0,
            "list": [
            <?php echo ($call_from == 'run' ? ('{"type": "fieldset", "label": "Data Source Location","offsetLeft":"30", "offsetTop":"15","list": [
            {"type": "upload", "name": "data_source_location", "autoStart":true, "inputWidth": "440", "url": "<%= js_file_uploader_url %>&call_form=data_import_export", "mode": "html5", "required": "true"}
            ]},
            {"type": "input", "name": "file_upload_status", "label": "file_upload_status", "validate": "", "hidden": "true", "value": "'. ($location_path) . '"},{"type": "input", "name": "connection_string", "label": "Remote Data Source", "offsetLeft":"30", "inputWidth": "455", "rows":"1","value":"'. ($connection_string) .'"},' ) 
                : '{"type": "input", "name": "connection_string", "label": "Remote Data Source", "validate": "NotEmpty", "offsetLeft":"30", "inputWidth": "455", "rows":"1","value":"'. ($connection_string) .'","required":true},' ); ?>
            {  
                                                    "type": "label",
                                                    "name": "note",
                                                    "hidden": "true",
                                                    "label": "<h5>&#128712; Note</br>- If import data source file is not uploaded then system will auto import data from defined remote source.</br>- Either upload Source File or provide Remote Data Source. Supported File Format - Excel, CSV, XML.</br>- Date Format in the file must be same as User's Profile Date Format.</h5>",
                                                    "offsetLeft": "10",
                                                    "inputTop": "0",
                                                    "offsetTop":"0",
                                                    "labelWidth": "auto",
                                                    "inputWidth": "auto"
                                                }
            ]}
            ]
        </script> 
        <!-- File Based Import -->

        <!-- SSIS Import -->
        <script id="template_step2_ssis" type="text/template">
            [
            {"type": "block", "name":"child_block","blockOffset":0,
            "list": [
            {"type": "combo", "name": "ssis_package", "label": "Package", "labelWidth": "210", "validate": "NotEmpty", "inputWidth": "200", "filtering": "true", "options":[<?php echo $ixp_ssis_package_json; ?>],"required":true},
            {"type": "newcolumn"},
            {"type": "checkbox", "name": "use_parameter", "label": "Use Parameters", "position": "label-right", "tooltip": "Use Parameters", "checked": "<?php echo $param_present; ?>", "offsetTop":"30","offsetLeft":30}
            ]}
            ]
        </script> 
        <!-- SSIS Import -->
         <!-- CLR function based Import -->
        <script id="template_step2_CLR_FUNCTION" type="text/template">
            [
            {"type": "block", "name":"child_block","blockOffset":0,
            "list": [
            {"type": "combo", "name": "clr_function_id", "label": "CLR Function", "labelWidth": "210", "validate": "NotEmpty", "inputWidth": "200", "filtering": "true", "options":[<?php echo $ixp_clr_function_json; ?>],"required":true},
            {"type": "newcolumn"},
            {"type": "checkbox", "name": "use_parameter", "label": "Use Parameters", "position": "label-right", "tooltip": "Use Parameters", "checked": "<?php echo $param_present; ?>", "offsetTop":"30","offsetLeft":30}
            ]}
            ]

        </script> 
        <!-- CLR function based Import -->


        <!-- Web Server based Import -->
        <script id="template_step2_web_server" type="text/template">
            [
            {"type": "block", "name":"child_block", "blockOffset": 0,
            "list": [

            <?php echo ($call_from == 'run' ? ('{"type": "fieldset", "label": "Data Source Location","offsetLeft":"30", "offsetTop":"15","list": [
            {"type": "upload", "name": "data_source_location", "autoStart":true, "inputWidth": "440", "url": "<%= js_file_uploader_url %>&call_form=data_import_export", "mode": "html5", "required": "true"}
            ]},
            {"type": "input", "name": "file_upload_status", "label": "file_upload_status", "validate": "", "hidden": "true", "value": "'. ($location_path) . '"}' ) 
                : '{"type": "combo", "name": "soap_function_id", "label": "Import Function", "validate": "NotEmpty", "value": "", "labelWidth": "210", "inputWidth": "200", "tooltip": "Import Function", "filtering": "true", "options":['. ($ixp_soap_function_json) .'],"required":true}'); ?>
            ,
            {  
                                                    "type": "label",
                                                    "name": "note",
                                                    "hidden": "true",
                                                    "label": "<h5>&#128712; Note</br>- Supported File Format - Excel, CSV. </br>- Date Format in the file must be same as User's Profile Date Format.</h5>",
                                                    "offsetLeft": "10",
                                                    "inputTop": "30",
                                                    "offsetTop":"0",
                                                    "labelWidth": "auto",
                                                    "inputWidth": "auto"
                                                }
            
            ]}
            ]


        </script>