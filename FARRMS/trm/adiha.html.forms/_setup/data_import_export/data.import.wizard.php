<?php
/**
* Data import wizard screen
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
        
        <link href="../../../main.menu/bootstrap-3.3.1/dist/css/bootstrap.min.css" rel="stylesheet" type="text/css" />        
        <link rel="stylesheet" type="text/css" href="../../../main.menu/css/compiled/theme_styles.css">
        <link rel="stylesheet" type="text/css" href="../../../main.menu/css/compiled/wizard.css">

        <!-- load ace -->
        <script src="../../../adiha.php.scripts/components/lib/ace/ace.js"></script>
        <!-- load ace language tools -->
        <script src="../../../adiha.php.scripts/components/lib/ace/ext-language_tools.js"></script>
    </head>

    <body>
        <?php
            $ixp_id = get_sanitized_value($_GET['ixp_id'] ?? -1);
            $system_rule_status = get_sanitized_value($_GET['system_rule_status'] ?? -1);
            $mode = ($ixp_id == -1) ? 'i' : 'u';
            $import_export_id = get_sanitized_value($_GET['ixp_id'] ?? 'NULL');
            $import_export_name = get_sanitized_value($_GET['ixp_name'] ?? '');
            $server_path = urlencode($BATCH_FILE_EXPORT_PATH);
            $setting_offset_left = $ui_settings['offset_left'];
            $xml_file = "EXEC spa_ixp_init @flag=c";
            $report_info = readXMLURL($xml_file);
            $process_id = $report_info[0][5];
            $end_point_label = "( FTP/(SFTP) Endpoint detail. )";

            if ($mode == 'u') {
                //Step 1
                $rules_data = "EXEC spa_ixp_rules @flag='a', @ixp_rules_id=" . $ixp_id;
                $rules_data_array = readXMLURL2($rules_data);
                $ixp_rules_id = $rules_data_array[0]['rules_id'];
                $ixp_rules_name = $rules_data_array[0]['rules_name'];
                $individuals_script_per_ojbect = $rules_data_array[0]['individuals_script_per_ojbect'];
                $limit_enabled = $rules_data_array[0]['limit_enabled'];
                $limit_rows_to = $rules_data_array[0]['limit_rows_to'];
                $before_insert_trigger = parse($rules_data_array[0]['before_insert_trigger']);
                $after_insert_trigger = parse($rules_data_array[0]['after_insert_trigger']);
                $ixp_owner = $rules_data_array[0]['ixp_owner'];
                $ixp_category1 = $rules_data_array[0]['ixp_category'];
                $is_system_import = ($rules_data_array[0]['is_system_import'] == 'y' || $rules_data_array[0]['is_system_import'] == 1) ? 'true' : 'false';
                $is_active = $rules_data_array[0]['is_active'];
                
                if ($is_active == NULL) $is_active = 0;

                //Step 2
                $data_source_array = array();
                $xml_data_source = "EXEC spa_ixp_import_data_source @flag='s', @rules_id=" . $import_export_id;
                $data_source = readXMLURL2($xml_data_source);

                $ixp_import_data_source_id = $data_source[0]['ixp_import_data_source_id'];
                $data_source_type = $data_source[0]['data_source_type'];
                $connection_string = $data_source[0]['connection_string'];
                $data_source_location = $data_source[0]['data_source_location'];
                $delimiter = $data_source[0]['delimiter'];
                $data_source_alias = $data_source[0]['data_source_alias'];
                $is_header_less = $data_source[0]['is_header_less'];
                $no_of_columns = $data_source[0]['no_of_columns'];
                $folder_location = $data_source[0]['folder_location'];
                $custom_import = $data_source[0]['custom_import'];
                $ssis_package = $data_source[0]['ssis_package'];
                $use_parameter = $data_source[0]['use_parameter'];
                $ws_function_name = $data_source[0]['ws_function_name'];
                $excel_sheet = $data_source[0]['excel_sheet'];
                $customizing_query = parse($data_source[0]['customizing_query']);
                $clr_function_id = $data_source[0]['clr_function_id'];
                $file_transfer_endpoint_id = $data_source[0]['file_transfer_endpoint_id'];
                $ftp_remote_directory = $data_source[0]['remote_directory'];
                $enable_email_import = $data_source[0]['enable_email_import'];
                $send_email_import_reply = $data_source[0]['send_email_import_reply'];
                
                	
				$load_filter_data = "EXEC spa_ixp_import_filter @flag='load_process_table', @rules_id=" . $ixp_id . ",@process_id='" . $process_id . "'";
                $load_filter_data_array = readXMLURL2($load_filter_data);
            } else {
                $ixp_rules_id = -1;
                $ixp_rules_name = '';
                $individuals_script_per_ojbect = 'i';
                $limit_enabled = '';
                $limit_rows_to = '';
                $before_insert_trigger = '';
                $after_insert_trigger = '';
                $ixp_owner = $app_user_name;
                $ixp_category1 = 23500;
                $is_system_import = 'false';
                $is_active = 1;

                $custom_import = '';
                $ixp_import_data_source_id = '';
                $data_source_type = '';
                $connection_string = '';
                $data_source_location = '';
                $delimiter = '';
                $data_source_alias = '';
                $is_header_less = '';
                $no_of_columns = '';
                $folder_location = '';
                $custom_import = '';
                $ssis_package = '';
                $use_parameter = '';
                $ws_function_name = '';
                $excel_sheet = '';
                $customizing_query = '';
                $clr_function_id  = '';
                $file_transfer_endpoint_id  = '';
                $ftp_remote_directory = '';
                $enable_email_import = '';
                $send_email_import_reply = '';
            }

            $name_space = 'ixp_wizard';

            /* Combo JSON preparation */
            /*
             * Function to create combo json
             * @param: $array: array of the combo with value and text
             * @param: $combo_id: selected value [optional]
             * @param: $value_index: index of the value
             * @param: $text_index: index of the text
             */
            function create_template_combo_json($array, $combo_id, $value_index, $text_index, $state_index = '', $has_blank_option = false) {
                $option = '';
                                
                for ($i = 0; $i < sizeof($array); $i++) {
                    if ($i == 0 && ($has_blank_option)) {
                        $option .= '{
                            "text":"", 
                            "value":""
                        },
                        ';
                    }                    
                    if ($i > 0 ) $option.=',';

                    $option .= '{
                        "text":"' . str_replace('"', '\"', $array[$i][$text_index]) . '", 
                        "value":"' . str_replace('"', '\"', $array[$i][$value_index]) . '"
                    ';
                    
                    if ($state_index != '') {
                        $option .= ', "state":"' . $array[$i][$state_index] . '"';
                    }
                    
                    if ($combo_id == $array[$i][$value_index]) {
                        $option .= ', "selected":"true"}';
                    }
                    $option .= '}';                   
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
            $ixp_data_source_type_json = create_template_combo_json($ixp_data_source_type_array, $ixp_data_source_type, 0, 1, 2);

            //ssis_package
            $ixp_ssis_package = "EXEC spa_ixp_ssis_configurations 's'";
            $ixp_ssis_package_array = readXMLURL($ixp_ssis_package);
            $ixp_ssis_package_json = create_template_combo_json($ixp_ssis_package_array, $ixp_ssis_package, 0, 1);

            // $CLR Function
            $ixp_clr_function = "EXEC spa_ixp_clr_functions @flag='s'";
            $ixp_clr_function_array = readXMLURL($ixp_clr_function);
            $ixp_clr_function_json = create_template_combo_json($ixp_clr_function_array, $ixp_clr_function, 0, 1);
            
            // File transfer endpoint
            $file_transfer_endpoint_sql = "EXEC spa_file_transfer_endpoint @flag= 'endpoint with url', @endpoint_type = '1'";
            $file_transfer_endpoint_id_array = readXMLURL($file_transfer_endpoint_sql);
            $file_transfer_endpoint_id_json = create_template_combo_json($file_transfer_endpoint_id_array, $file_transfer_endpoint_sql, 0, 1, '', true);
            
            /* End of Combo JSON preparation */
        
            function parse($text) {
                // Damn pesky carriage returns...
                $text = str_replace("\r\n", "\n", $text);
                $text = str_replace("\r", "\n", $text);

                // JSON requires new line characters be escaped
                $text = str_replace("\n", "\\n", $text);
                return $text;
            }
			
			$xml_file = "EXEC spa_ixp_import_filter @flag = 'number_of_filters', @rules_id = " . $ixp_id . ", @process_id = '" . $process_id . "'";
            $import_filters_number = readXMLURL2($xml_file);
			$filter_flag_array = array();

			for ($i = 0; $i < sizeof($import_filters_number); $i++) {
				$index = $import_filters_number[$i]['value_id'];
				$value = $import_filters_number[$i]['number_of_filter'];
				$filter_flag_array[$index] = $value;	
			}
        ?>

        <div class="row">
            <div class="col-lg-12">
                <div class="main-box clearfix" style="min-height: 800px;">
                    <div class="main-box-body clearfix">
                        <div id="ixp_wizarddd" class="wizard">
                            <div class="wizard-inner">
                                <ul class="steps">
                                    <li data-step="1" class="active"><span class="badge badge-primary">1</span> <?php echo get_locale_value('Step 1') ?> <span class="chevron"></span></li>
                                    <li data-step="2"><span class="badge">2</span> <?php echo get_locale_value('Step 2') ?> <span class="chevron"></span></li>
                                    <li data-step="3"><span class="badge">3</span> <?php echo get_locale_value('Step 3') ?> <span class="chevron"></span></li>
                                    <li data-step="4"><span class="badge">4</span> <?php echo get_locale_value('Step 4') ?> <span class="chevron"></span></li>
                                    <li data-step="5"><span class="badge">5</span> <?php echo get_locale_value('Step 5') ?> <span class="chevron"></span></li>
                                    <li data-step="6"><span class="badge">6</span> <?php echo get_locale_value('Step 6') ?> <span class="chevron"></span></li>
                                    <li data-step="7"><span class="badge">7</span> <?php echo get_locale_value('Step 7') ?> <span class="chevron"></span></li>
                                </ul>
                                <div class="actions"  style="z-index:1;">
                                    <button type="button" class="btn btn-default btn-mini btn-prev"> <i class="icon-arrow-left"></i>Previous</button>
                                    <button type="button" class="btn btn-default btn-mini btn-next" data-last="Save" id="next_btn">Next<i class="icon-arrow-right"></i></button>
                                </div>
                            </div>
                            <div class="step-content">
                                <div id="step1" class="step-pane active">
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <script src="../../../main.menu/bootstrap-3.3.1/dist/js/bootstrap.js" type="text/javascript"></script>
        <script type="text/javascript"> var num_steps = [0, 1, 2, 3, 4, 5, 6, 7, 8]; </script>
        <script src="../../../main.menu/js/ixp_wizard.js"></script>
        
        <style>
            div#step1 {
                position: relative;
                width: 100%;
                height: 465px;
            }

            .dhxform_label_nav_link {
                font-size: 1em;
                font-weight: 400;
            }

            label {
                font-size: 13px !important;
                font-weight: 100 !important;
            }
            
			.editor-label { 
                margin: 0;
                position: absolute;
                top: 5px;
                left: 0;
            }

            .ace_editor { 
                margin: 0;
                position: absolute;
                top: 30px;
                bottom: 0;
                left: 0;
                right: 0;
            }
            
            .ace_editor :not(i) {
                font-family: 'PT Mono', monospace!important;
            }

            u > l > img:hover {
                background-color: #82E1D4;
            }
        </style>

        <script type="text/javascript">
            /* 
                For Step 2 UI: -- TO DO: to hide/show fields add or remove @ var field_config
                To ADD new Field then add JSON template & configure @ var field_config
            */
            var step_header_title = [
                "Step Header Title",
                "Defines Rule Property",
                "Define Data Source Type or Method",
                "Add Connected Data Source",
                "Source-Destination Mapping",
                "Pre-Import Trigger",
                "Post-Import Trigger",
                "Summary",
                "",
                "Data Customization"
            ];

            var step_info = [
                "Step Info",
                "Define unique import Rule Name and Category",
                "Define Data Source to specify type/method to import data. System supports different Data Source like Flat File, SSIS, Link Server, LSE etc. <br/> For Flat File or Excel Data Source, data location can be network accessible folder path or FTP path. File is uploaded for mapping to be done in Step 4. <br/> Date Format in the file must be same as User's Profile Date Format.",
                "An optional step to support import using multiple Data Source. Add other source file to import if required.",
                "Add destination import table. Map source column(s) of data source file uploaded to respective destination column(s).",
                "An optional step to define custom script to execute before proceeding import. Contact technical team for custom script.",
                "An optional step to define custom script to execute after data is imported. Contact technical team for custom script.",
                "Verify summary and proceed to save changes.",
                "",
                "Define custom query to customize data."
            ].map(get_locale_value);

            var field_config = {};
            ixp_wizard = {};
            var mode = "<?php echo $mode; ?>";
            var process_id = "<?php echo $process_id; ?>";
            var php_script_loc_ajax = "<?php echo $app_php_script_loc; ?>";
            ixp_wizard.layout = {};
            ixp_wizard.form = {};
            ixp_wizard.grid = {};
            ixp_wizard.menu = {};
            ixp_wizard.rule_name = '';
            ixp_wizard.before_trigger = '';
            ixp_wizard.after_trigger = '';
            ixp_wizard.customized_query = '';
            var ixp_id = '<?php echo $ixp_id; ?>';
            var system_rule_status = '<?php echo $system_rule_status; ?>';
            import_export_id = '<?php echo $import_export_id; ?>';
            var server_path = decodeURIComponent('<?php echo $server_path;?>');
            var ixp_category = <?php echo (($ixp_category1) ? $ixp_category1 : ''); ?>;
            
            //step2
            var ixp_import_data_source_id = <?php echo (($ixp_import_data_source_id) ? $ixp_import_data_source_id : '0'); ?>;
            var data_source_type = "<?php echo (($data_source_type) ? $data_source_type : ''); ?>";
            var connection_string = "<?php echo (($connection_string) ? $connection_string : ''); ?>";
            var data_source_location = "<?php echo (($data_source_location) ? $data_source_location : '0'); ?>";
            var delimiter = "<?php echo (($delimiter) ? $delimiter : '0'); ?>";
            var data_source_alias = "<?php echo (($data_source_alias) ? $data_source_alias : '0'); ?>";
            var is_header_less =<?php echo (($is_header_less == 'y') ? '1' : '0'); ?>;
            var no_of_columns =<?php echo (($no_of_columns) ? $no_of_columns : '0'); ?>;
            var folder_location = "<?php echo (($folder_location) ? $folder_location : $folder_location); ?>";
            var custom_import =<?php echo (($custom_import == 'y') ? '1' : '0'); ?>;
            var ssis_package =<?php echo (($ssis_package) ? $ssis_package : '0'); ?>;
            var use_parameter =<?php echo (($use_parameter == 'y') ? '1' : '0'); ?>;
            var ws_function_name = "<?php echo (($ws_function_name) ? $ws_function_name : ''); ?>";
            var clr_function_id = "<?php echo (($clr_function_id) ? $clr_function_id : ''); ?>";
            var excel_sheet = "<?php echo (($excel_sheet) ? $excel_sheet : ''); ?>";
            var file_transfer_endpoint_id = "<?php echo (($file_transfer_endpoint_id) ? $file_transfer_endpoint_id : ''); ?>";
            var ftp_remote_directory = "<?php echo (($ftp_remote_directory) ? $ftp_remote_directory : ''); ?>";
            var customizing_query = "<?php echo $customizing_query?>";

            dhxWins = new dhtmlXWindows();
            var first_custom_import = '<?php echo $custom_import; ?>';
            var radio_id;

            $(function() {
                $('#ixp_wizarddd').wizard();

                this.$element = $('#ixp_wizarddd');
                ixp_wizard.layout["layout_step"] = new dhtmlXLayoutObject({
                    parent: "step1",
                    pattern: "1C",
                    cells: [{id: "a", header: false, width: 800, fix_size: [true, true]}]
                })
                // load first form
                ixp_wizard.load_form(1);
            });

            /**
             * [load_form Save Data and Load Form]
             * @param  {[int]} step [Step number]
             */
            ixp_wizard.load_form = function(step) {
                
                // if not one
                // Save form from step-1, ixp_wizard.form["form_step_" + step-1].getFromData()
                // if step = 7 { spa_ixp_rule 'p' == either run or save or both}
                if (ixp_wizard.layout["layout_step"]) {
                    var firstShow = ixp_wizard.layout["layout_step"].cells('a').showView(step);
                    
                    if (firstShow) {
                        var cell_object = ixp_wizard.layout["layout_step"].cells('a');
                        
                        //saving logic
                        if (step > 1) {
                            ixp_wizard.save_form(step);
                        }

                        // if Step 3 - attach grid
                        // if step 4 - attach tree
                        if (step == 3 || step == 4) {
                            ixp_wizard.menu["menu_" + step] = cell_object.attachMenu({
                                icons_path: js_image_path + "dhxmenu_web/",
                                items: [
                                    {id: "edit", text: "Edit",  img:"edit.gif", items: [
                                        {id: "add", text: "Add", img: "new.gif"},
                                        {id: "remove", text: "Delete", img: "remove.gif"}
                                    ]}
                                ]
                            });

                            if (step == 3) {
                                var info_layout_json = [
                                    {
                                        id: "a",
                                        text: "Grid",
                                        header: false,
                                        collapse: false
                                    },
                                    {
                                        id: "b",
                                        text: "Note : " + step_header_title[3],
                                        header: true,
                                        collapse: false,
                                        height: 120
                                    }
                                ];

                                ixp_wizard.layout["inner_grid_layout_" + step] = cell_object.attachLayout({pattern: "2E", cells: info_layout_json});
                                cell_object_a = ixp_wizard.layout["inner_grid_layout_" + step].cells('a');
                                cell_object_b = ixp_wizard.layout["inner_grid_layout_" + step].cells('b');
                                cell_object_b.setText("<i class='glyphicon glyphicon-info-sign'></i> " + cell_object_b.getText());
                                
                                ixp_wizard.grid["grid_step_" + step] = cell_object_a.attachGrid();
                                ixp_wizard.grid["grid_step_" + step].setImagePath("<?php echo $image_path; ?>dhxtoolbar_web/");
                                ixp_wizard.grid["grid_step_" + step].setColumnIds("ixp_import_relation_id,relation,alias,type");
                                ixp_wizard.grid["grid_step_" + step].setHeader(get_locale_value("ixp import relation id,Connected Data,Alias,type", true));
                                ixp_wizard.grid["grid_step_" + step].setInitWidths("100,250 ,250,200");
                                ixp_wizard.grid["grid_step_" + step].setColumnsVisibility("true,flase,false,true");
                                ixp_wizard.grid["grid_step_" + step].setColTypes("ro,ro,ro,ro");
                                ixp_wizard.grid["grid_step_" + step].setColSorting("str,str,str,str");
                                ixp_wizard.grid["grid_step_" + step].init();
                                ixp_wizard.grid["grid_step_" + step].enableHeaderMenu();

                                /* Load relation grid */
                                var grid_param = {
                                    "flag": "s",
                                    "process_id": ixp_wizard.process_id,
                                    "rules_id": ixp_wizard.rules_id,
                                    "action": "spa_ixp_import_relation"
                                };
                                grid_param = $.param(grid_param);
                                var data_url = js_data_collector_url + "&" + grid_param;
                                ixp_wizard.grid["grid_step_" + step].loadXML(data_url);

                                ixp_wizard.grid["grid_step_" + step].attachEvent("onRowDblClicked", function(rId, cInd) {
                                    ixp_import_relation_id = ixp_wizard.grid["grid_step_" + step].cells(rId, 0).getValue();
                                    ixp_wizard.open_relation_popup('u', ixp_import_relation_id);
                                });

                                var step_info_json = [  
                                    {"type":"settings", "position":""},
                                    {
                                        "type": "block",
                                        "offsetTop": 0,
                                        "blockOffset": 5,
                                        "list":[{  
                                            "type": "label",
                                            "label": "<h5>"  + step_info[step] + "</h5>",
                                            "position": "label-top",
                                            "offsetLeft": "10",
                                            "inputTop": "0",
                                            "labelWidth": "auto",
                                            "inputWidth": "250"
                                        }]
                                    }
                                ];

                                ixp_wizard.form["info_form" + step] = cell_object_b.attachForm();
                                ixp_wizard.form["info_form" + step].load(step_info_json);
                                /* End of Load relation grid */
                            } else if (step == 4) {
                                
                                inner_layout_json = [
                                    {
                                        id: "a",
                                        text: "Data Relation",
                                        header: false,
                                        collapse: false
                                    },
                                    {
                                        id: "b",
                                        text: "Repeat Tables",
                                        header: false,
                                        collapse: false
                                    },
                                    {
                                        id: "c",
                                        text: "Note : " + step_header_title[4],
                                        header: true,
                                        collapse: false,
                                        height: 120
                                    }
                                ];

                                ixp_wizard.layout["inner_grid_layout_" + step] = cell_object.attachLayout({pattern: "3E", cells: inner_layout_json});
                                inner_cell_object_b = ixp_wizard.layout["inner_grid_layout_" + step].cells('b');
                                ixp_wizard.radio_form_name = inner_cell_object_b.attachForm();
                                
                                ixp_wizard.radio_form_name.load([
                                    {type: "fieldset", name: "data", label: "Repeat Tables",offsetBottom: 0, inputWidth: "auto", position: "label-right", width: 800, hidden:"true", list: [
                                        {type: "radio", name: "repeat_tables", value: "n", offsetLeft: 15, label: "None", position: "label-right", checked: "1", labelWidth : 230},
                                        {type: "newcolumn"},
                                        {type: "radio", name: "repeat_tables", value: "t", offsetLeft: 15, position: "label-right", label: "Table", labelWidth : 230},
                                        {type: "newcolumn"},
                                        {type: "radio", name: "repeat_tables", value: "d", offsetLeft: 15, position: "label-right", label: "Dependent Table", labelWidth : 230}
                                    ]}
                                ]);

                                ixp_wizard.radio_form_name.setUserData("", "table_mapping_xml", "");
                                ixp_wizard.radio_form_name.setUserData("", "table_mapping_ids", "");
                                ixp_wizard.radio_form_name.setUserData("", "actual_table_mapping_ids", "");
                                ixp_wizard.radio_form_name.setUserData("", "dep_table_mapping_ids", "");

								var b_height = ixp_wizard.layout["inner_grid_layout_" + step].cells('b').getHeight();
								var a_height = ixp_wizard.layout["inner_grid_layout_" + step].cells('a').getHeight();
								a_height = a_height + (b_height-20);
								
								ixp_wizard.layout["inner_grid_layout_" + step].cells('a').setHeight(a_height);
								ixp_wizard.layout["inner_grid_layout_" + step].cells('b').fixSize(true, true);
                                
                                inner_cell_object_c = ixp_wizard.layout["inner_grid_layout_" + step].cells('c');
                                ixp_wizard.tooltip_form = inner_cell_object_c.attachForm();
                                
                                ixp_wizard.tooltip_form.load([  
                                    {"type":"settings", "position":""},
                                    {
                                        "type": "block",
                                        "offsetTop": 0,
                                        "blockOffset": 0,
                                        "list":[{  
                                            "type": "label",
                                            "label": "<h5>" + step_info[step] + "</h5>",
                                            "value": "this is test sample",
                                            "position": "label-top",
                                            "offsetLeft": "10",
                                            "inputTop": "0",
                                            "labelWidth": "auto",
                                            "inputWidth": "250"
                                        }]
                                    }
                                ]);
                                
                                inner_cell_object_c.setText("<i class='glyphicon glyphicon-info-sign'></i> " + inner_cell_object_c.getText());
                            }

                            // Menu click
                            ixp_wizard.menu["menu_" + step].attachEvent("onClick", function(id) {
                                switch (id) {
                                    case "add":
                                        if (step == 3) {
                                            ixp_wizard.open_relation_popup('i', 'NULL');
                                        } else {
                                            ixp_wizard.open_table_popup();
                                        }
                                        break;
                                    case 'remove':
                                        if (step == 3) {
                                            ixp_wizard.delete_relation();
                                        } else {
                                            ixp_wizard.delete_table();
                                        }
                                }
                            });
                            // else attach form  
                        } else {

                            inner_layout_json = [
                                {
                                    id: "a",
                                    text: "Form",
                                    header: false,
                                    collapse: false
                                },
                                {
                                    id: "b",
                                    text: "Note : " + step_header_title[step],
                                    header: true,
                                    collapse: false,
                                    height: 120
                                }
                            ];

                            if(step == 2) {           
                                form_json = ixp_wizard.get_form_json('2_two');
                            }
                            else {
                                form_json = ixp_wizard.get_form_json(step);
                            }
                            

                            ixp_wizard.layout["step_layout_" + step] = cell_object.attachLayout({pattern: "2E", cells: inner_layout_json});
                            inner_cell_object_a = ixp_wizard.layout["step_layout_" + step].cells('a');
                            ixp_wizard.form["form_step_" + step] = inner_cell_object_a.attachForm();
                            ixp_wizard.form["form_step_" + step].loadStruct(form_json);

                            var info_form_json = [  
                                {"type":"settings", "position":""},
                                {
                                    "type": "block",
                                    "offsetTop": 0,
                                    "blockOffset": 0,
                                    "list":[{  
                                        "type": "label",
                                        "label": "<h5>" + step_info[step] + "</h5>",
                                        "position": "label-top",
                                        "offsetLeft": "10",
                                        "inputTop": "0",
                                        "labelWidth": "auto",
                                        "inputWidth": "auto"
                                    }]
                                }
                            ];

                            inner_cell_object_b = ixp_wizard.layout["step_layout_" + step].cells('b');
                            inner_cell_object_b.setText("<i class='glyphicon glyphicon-info-sign'></i> " + inner_cell_object_b.getText());
                            if (step == 5 || step == 6 || step == 9) {
                                
								if (step == 5) {
                                    var label = 'Pre-Import Trigger';
                                } else if(step == 6) {
                                    var label = 'Post-Import Trigger';
                                } else if(step == 9) {
                                    var label = 'Customizing Query';
                                }

                                html_string = '<div class="editor-label">' + label + '</div>';
                                html_string += '<div class="ace_editor" id="editor_' + step + '"></div>';

                                inner_cell_object_a.attachHTMLString(html_string);
                                
								ace.require("ace/ext/language_tools");
                                var editor = ace.edit("editor_" + step);
                                editor.session.setMode("ace/mode/sqlserver");
                                editor.setTheme("ace/theme/sqlserver");

                                editor.setOptions({
                                    enableBasicAutocompletion: true,
                                    enableSnippets: true,
                                    enableLiveAutocompletion: false
                                });
                                
                                add_ace_context_menu(editor, [
                                    {text:'[temp_process_table]', title:'First Staging Table'},
                                    {text:'[final_process_table]', title:'Second Staging Table'}
                                ]);

                                editor.getSession().on('change', function() {
                                    if (step == 5) {
                                        ixp_wizard.before_trigger = editor.getValue();
                                    } else if (step == 6) {
                                        ixp_wizard.after_trigger = editor.getValue();
                                    } else if (step == 9) {
                                        ixp_wizard.customized_query = editor.getValue();
                                    }
                                });

                            } else {
                                ixp_wizard.form["step_layout_" + step] = inner_cell_object_b.attachForm();
                                ixp_wizard.form["step_layout_" + step].loadStruct(info_form_json);
                            }
                        }
                       
                        if (step == 7) {
                            ixp_wizard.form["form_step_" + step].setItemValue("summary", "");
                            var text_summary = 'Rule Name: ' + ixp_wizard.rule_name + '\n' + 'Before Trigger: ' + unescapeXML(ixp_wizard.before_trigger).replace(/\"/g, "'") + '\n' + 'After Trigger: ' + unescapeXML(ixp_wizard.after_trigger).replace(/\"/g, "'");
                            ixp_wizard.form["form_step_" + step].setItemValue("summary", text_summary);
                            
                            if (mode == 'u') {
                                ixp_wizard.form["form_step_7"].hideItem('run_rule');
                            }

                            ixp_wizard.form["form_step_7"].setItemValue('run_rule', false);
                        }
                        
                        // initial view for additional step
                        if (step == 1) {
                            if(first_custom_import == '1'){
                                $('#ixp_wizarddd').wizard('addSteps', 3 , [
                                    {
                                        badge: '3',
                                        label: 'Step 3',
                                        pane: '<div>Content</div>'

                                    }
                                ]);

                                for(var i = 4; i <= 8; i++) {
                                    var $li = $("li[data-step='" + i + "']");
                                    $li.html($li.html().replace(/\d/g, (i)));
                                }    
                            }
                        }

                        // attach events for step 2
                        if (step == 2) {
                            var form_object = ixp_wizard.form["form_step_" + step];
                            ixp_wizard.second_form_events(form_object, "", "", true);

                            var is_header_less = form_object.isItemChecked('is_header_less');
                            ixp_wizard.second_form_events(form_object, 'is_header_less', is_header_less, is_header_less);

                            
                            form_object.attachEvent("onChange", function(name, value, state) {
                                ixp_wizard.second_form_events(form_object, name, value, state);
                                
                                if (name == 'custom_import'){
                                    var custom_import_checked = form_object.isItemChecked('custom_import');

                                    if (custom_import_checked) {
                                        $('#ixp_wizarddd').wizard('addSteps', 3 , [
                                            {
                                                badge: '3',
                                                label: 'Step 3',
                                                pane: '<div>Content</div>'
                                            }
                                        ]);
                                        
                                        for (var i = 4; i <= 8; i++) {
                                            var $li = $("li[data-step='" + i + "']");
                                            $li.html($li.html().replace(/\d/g, (i)));
                                        }
                                    } else {

                                        $('#ixp_wizarddd').wizard('removeSteps', 3);

                                        for (var i = 3; i <= 7; i++) {
                                            var $li = $("li[data-step='" + i + "']");
                                            $li.html($li.html().replace(/\d/g, (i)));
                                        }
                                    }
                                } else if (name == 'cmb_file_transfer_endpoint_id' || name == 'txt_ftp_remote_directory') {            
                                        var endpoint = '';
                                        var remote_directory = '';
                                        var cmb_endpoint_obj = '';                                    
                                        cmb_endpoint_obj = form_object.getCombo('cmb_file_transfer_endpoint_id'); 
                                        endpoint = cmb_endpoint_obj.getSelectedValue();
                                        endpoint = endpoint.substr(endpoint.indexOf('|')+1);

                                        if (endpoint == '') {
                                            endpoint = '<?php echo $end_point_label; ?>';
                                            form_object.setItemLabel('endpoint_label',endpoint);
                                            if (name == 'cmb_file_transfer_endpoint_id') {
                                                form_object.setItemValue('txt_ftp_remote_directory', '');
                                                form_object.disableItem('txt_ftp_remote_directory');
                                            }
                                        } else { 
                                            form_object.enableItem('txt_ftp_remote_directory');
                                            remote_directory = form_object.getItemValue('txt_ftp_remote_directory');               
                                            remote_directory = '( ' + endpoint + '/' + remote_directory + ' )';
                                            form_object.setItemLabel('endpoint_label',remote_directory);
                                        }            
                                    }
                                
                            });

                            form_object.attachEvent("onUploadFile", function(realName, serverName) {
                                form_object.setItemValue("file_upload_status", serverName);
                            });

                            form_object.attachEvent("onClear", function() {
                                form_object.setItemValue("file_upload_status", 0);
                            });
                            form_object.attachEvent("onFileRemove",function(realName,serverName){
                                form_object.setItemValue("file_upload_status", 0);
                            });
                            
                            form_object.disableItem('data_source_alias');
                            
                            form_object.attachEvent("onUploadFail", function(realName) {
                                show_messagebox("Could not upload the file. Please check the format.");
                                });

                            form_object.attachEvent("onUploadComplete", function(count) {
                                var myUploader = form_object.getUploader("data_source_location");
                                
                                if (count > 1) {
                                    myUploader.clear();
                                    form_object.setItemValue("file_upload_status", 0);
                                    show_messagebox("Please upload only one file.");
                                } else {
                                    var server_path_file = server_path + '\\' + form_object.getItemValue("file_upload_status");
                                    var cm_param = {
                                        "action": "spa_ixp_rules", 
                                        "flag": "z",
                                        "server_path": server_path_file
                                    };

                                    cm_param = $.param(cm_param);
                                    var url = js_dropdown_connector_url + '&' + cm_param;
                                    var excel_sheets_cmb = form_object.getCombo('excel_sheets');
                                    excel_sheets_cmb.load(url);
                                }
                            });
                            
                            form_object.attachEvent("onFileAdd", function(realName) {
                                var upload_status = form_object.getItemValue('file_upload_status');
                                var myUploader = form_object.getUploader("data_source_location");
                                if (upload_status != 0) {
                                    myUploader.clear();
                                    form_object.setItemValue("file_upload_status", 0);
                                    show_messagebox("Please upload only one file.");
                                }
                            });
                        }
                    }

                    //update logic
                    if (mode == 'u') {
                        ixp_wizard.update_form(step);
                    }
                    
                    if (mode == 'i'){
                        ixp_wizard.generate_alias(step);
                    }
                }
            }

            /**
             * [validation_form Validate Form]
             * @param  {[int]} step [Step number]
             */
            ixp_wizard.validation_form = function(step) {
                
                if (step == 2) {
                    var form_object = ixp_wizard.form["form_step_" + 1];
                    var value_ixp_rules_name = ixp_wizard.form["form_step_" + 1].getItemValue('ixp_rules_name');
                    var value_is_system_import = ixp_wizard.form["form_step_" + 1].getItemValue('is_system_import');
                    var value_ixp_rules_id = ixp_wizard.form["form_step_" + 1].getItemValue('ixp_rules_id');
                    
                    if (value_ixp_rules_name == ""){
                        ixp_wizard.form["form_step_" + 1].setNote('ixp_rules_name', {
                            text: "Required Field", width:300
                        }); 
                    }

                    var status = form_object.validate();
                    
                    if (!status) {
                        return false;
                    } else {
                        if (value_is_system_import == 1 && (value_ixp_rules_id == -1 || system_rule_status != '1')) { //Open password window when rule is created as System
                            is_user_authorized('ixp_wizard.user_authorized','');
                        } else {
                            return true;
                        }
                    }
                } else if (step == 3) {
                    var form_object = ixp_wizard.form["form_step_" + 2];
                    var location = 1;
                    location = form_object.getItemValue("file_upload_status");
                    
                    var upload_status = form_object.getUploaderStatus('data_source_location');
                    //to check if the file is still uploading.
                    var folder_location = form_object.getItemValue('folder_location');
                    
                    if (upload_status == -1) {
                        location = 0;
                        show_messagebox("The file has not finished uploading.");
                        return;
                    } else {
                        form_object.setRequired("folder_location", false);
                    }

                    var status = form_object.validate();
                    var value_data_source_alias = ixp_wizard.form["form_step_" + 2].getItemValue('data_source_alias');
					
					var ws_function_name = ixp_wizard.form["form_step_" + 2].getItemValue('ws_function_name');
					var value_ixp_rules_id = ixp_wizard.form["form_step_" + 1].getItemValue('ixp_rules_id');
					var v_status = validate_import_function(ws_function_name, mode, value_ixp_rules_id);
                   
					if ((!status)) {
                        ixp_wizard.form["form_step_" + 2].setNote('data_source_alias', {
                            text: "Required Field", width:300
                        }); 
                       return false;
                    } else if (!value_data_source_alias.match(/^[a-zA-Z0-9\-\_]{1,}$/)) {  
                        ixp_wizard.form["form_step_" + 2].setNote('data_source_alias', {
                            text: "", width:300
                        });         
                        show_messagebox("Invalid Rule Name. Space and special character is not allowed in Import Rule name.");
                        return false;
                    } else if (v_status == 'false') {
						show_messagebox('Import Function is already in use. Please use different Import Function.');
						return false;
					} else {
                        ixp_wizard.form["form_step_" + 2].setNote('data_source_alias', {
                            text: "", width:300
                        }); 
                        return true;
                    }
                } else if (step == 4) {
                    return true;
                } else if (step == 5) {
                    tree_ids = ixp_wizard.grid["grid_step_4"].getAllSubItems(0);
                    
                    if(tree_ids)
                        return true;
                    else {
                        show_messagebox("Cannot proceed without importing tables.");
                        return false;
                    }
                } else if (step == 6) {
                    return true;
                } else if (step == 7) {
                    return true;
                } else if (step == 10) {
                    
                    // SQL Verify
                    var value_ixp_rules_id = ixp_wizard.form["form_step_" + 1].getItemValue('ixp_rules_id');
                    var customized_query = ixp_wizard.customized_query;
                                        
                    if (customized_query == '') {
                        show_messagebox("Please enter Customizing Query.");
                        return false;
                    }

                    data = {
                        "action": "spa_ixp_import_data_source",
                        "flag": "q",
                        "import_data_source_id": data_source_id,
                        "process_id": process_id,
                        "rules_id": value_ixp_rules_id,
                        "customizing_query": customized_query
                    };
                    result = adiha_post_data('return_array', data, '', '', "ixp_wizard.query_callback");   
                } else if (step == 8) {
                    ixp_wizard.save_form('8');
                }
            }

            ixp_wizard.query_callback = function(result) {
                
                if (result[0][0] == 'Success'){
                    $("#next_btn").trigger("click",true);
                } else if (result[0][0] == 'Error') {
                    show_messagebox(result[0][4]);
                }
            }

            ixp_wizard.user_authorized = function(){
                $("#next_btn").trigger("click",true);
            }
            
            ixp_wizard.generate_alias = function(step) {
                if (step == 2) {
                    var alias_name = '';
                    var form_object1 = ixp_wizard.form["form_step_" + 1];
                    var rules_name_split = form_object1.getItemValue('ixp_rules_name').trim().split(" ");
            
                    if (rules_name_split.length > 0) {
                        
                        for(var i=0; i < rules_name_split.length; i++){
							
                            if (rules_name_split[i].substring(0, 1).toLowerCase().match(/^[a-zA-Z0-9\-\_]{1,}$/)) {
								alias_name += rules_name_split[i].substring(0, 1).toLowerCase();
							}
                        }
                    }
                    var form_object2 = ixp_wizard.form["form_step_" + 2];
                    form_object2.setItemValue("data_source_alias", alias_name);
                }
            }

            ixp_wizard.update_form = function(step) {
                
                if (step == 1) {
                    var form_object = ixp_wizard.form["form_step_" + 1];
                    form_object.setItemValue("ixp_category", ixp_category);
                } else if (step == 2) {
                    var form_object = ixp_wizard.form["form_step_" + 2];
                    ixp_wizard.second_form_events(form_object, "", "", 1);
              
                    form_object.setItemValue("delimiter", delimiter);
                    form_object.setItemValue("data_source_alias", data_source_alias);
                    
                    if (custom_import) {
                        form_object.checkItem("custom_import");
                    }

                    form_object.setItemValue("folder_location", folder_location);
                    
                    if (is_header_less) {
                        form_object.checkItem("is_header_less");
                        form_object.setItemValue("no_of_columns", no_of_columns);
                    }

                    data_source_location = data_source_location.replace(/%20/g, " ");
               
                    form_object.setItemValue("connection_string", connection_string);
             
                    form_object.setItemValue("clr_function_id", "<?php echo (($clr_function_id) ? $clr_function_id : ''); ?>");
                    form_object.setItemValue("cmb_file_transfer_endpoint_id", file_transfer_endpoint_id);
                    form_object.setItemValue("txt_ftp_remote_directory", ftp_remote_directory);
                    form_object.setItemValue("ssis_package", "<?php echo (($ssis_package) ? $ssis_package : ''); ?>");
                    form_object.setItemValue("data_source_alias", data_source_alias);
                                         
                    cmb_endpoint_obj = form_object.getCombo('cmb_file_transfer_endpoint_id'); 
                    endpoint = cmb_endpoint_obj.getSelectedValue();
                    endpoint = endpoint.substr(endpoint.indexOf('|')+1);

                    if (endpoint == '') {
                        endpoint = '<?php echo $end_point_label; ?>';
                        form_object.setItemLabel('endpoint_label',endpoint);
                        if (name == 'cmb_file_transfer_endpoint_id') {
                            form_object.setItemValue('txt_ftp_remote_directory', '');
                            form_object.disableItem('txt_ftp_remote_directory');
                        }
                    } else { 
                        form_object.enableItem('txt_ftp_remote_directory');
                        remote_directory = form_object.getItemValue('txt_ftp_remote_directory');               
                        remote_directory = '( ' + endpoint + '/' + remote_directory + ' )';
                        form_object.setItemLabel('endpoint_label',remote_directory);
                    }       
                   

                    var state = form_object.isItemChecked('is_header_less');
                    
                    if (state) {
                        form_object.showItem('num_of_columns');
                    } else {
                        form_object.hideItem('num_of_columns');
                    }
                } else if (step == 3) {
                    refresh_data_relation_grid();
                } else if (step == 4) {
                    table_id = (ixp_wizard.update_table_ids);
                    dependent_table_id = (ixp_wizard.update_dependent_table_ids);
                    
                    if (table_id.length > 0) {
                        var myarray = table_id.split(',');
                        
                        if(dependent_table_id.length>0)
                            myarray_dep = dependent_table_id.split(',');
                        else {
                            myarray_dep = '';
                        }

                        grid_ids = [];

                        for (var i = 0; i < myarray.length; i++) {
                            var myarray_inner = myarray[i].split('/');
                            grid_ids[i] = [];
                            grid_ids[i][0] = myarray_inner[0];
                            grid_ids[i][1] = myarray_inner[1];
                            sub_grid_ids = [];
                            
                            if (myarray_dep) {
                                
                                for (var i = 0; i < myarray_dep.length; i++) {
                                    var myarray_dep_inner = myarray_dep[i].split('/');
                                    
                                    if (myarray_dep_inner[2] == myarray_inner[0]) {
                                        sub_grid_ids[i] = [];
                                        sub_grid_ids[i][0] = myarray_dep_inner[0];
                                        sub_grid_ids[i][1] = myarray_dep_inner[1];
                                    }
                                }
                            }
                        }

                        create_table_grid(grid_ids, sub_grid_ids, 'n');
                    }
                } else if (step == 5) {
                    var editor = ace.edit("editor_" + step);
                    before_insert_trigger = "<?php echo str_replace('"', "&quot;", $before_insert_trigger);?>";
                    editor.setValue(unescapeXML(before_insert_trigger), -1);
                } else if (step == 6) {
                    var editor = ace.edit("editor_" + step);
                    after_insert_trigger = "<?php echo $after_insert_trigger;?>";
                    editor.setValue(unescapeXML(after_insert_trigger), -1);
                } else if (step == 9) {
                    var editor = ace.edit("editor_" + step);
                    customizing_query = "<?php echo $customizing_query;?>";
                    editor.setValue(unescapeXML(customizing_query), -1);
                }
            }
            
            /**
             * [save_form save Form]
             * @param  {[int]} step [Step number]
             */
            ixp_wizard.save_form = function(step) {
                
                if (step == 2) { //saving logic for first form.
                    
                    if(mode == 'u') {
                        $("#next_btn").attr("disabled", true);
                    }

                    var form_object = ixp_wizard.form["form_step_" + 1];
                    var ixp_rules_name = form_object.getItemValue('ixp_rules_name');
                    var ixp_category = form_object.getItemValue('ixp_category');
                    var is_system_import = form_object.getItemValue('is_system_import');
                    var ixp_owner = form_object.getItemValue('ixp_owner');
                    var is_active = form_object.getItemValue('is_active');
                    
                    if (is_active == false) is_active = 0;
                    
                    var flag = (mode == 'u') ? 'y' : 'i';
                    
                    if (mode == 'u') {
                        data = {
                            "action": "spa_ixp_init",
                            "flag": "u",
                            "process_id": process_id,
                            "rules_id": import_export_id
                        };
                        result = adiha_post_data("return_json", data, "", "", "ixp_wizard.save_ixp_rule_callback"); //Call back function added to handle casae of timing issue
                    } else {
                        data = {
                            "action": "spa_ixp_rules", 
                            "flag": flag,
                            "process_id": process_id,
                            "ixp_rules_name": ixp_rules_name,
                            "import_export_flag": "i",
                            "ixp_category": ixp_category,
                            "is_system_import": (is_system_import == '1') ? 'y' : 'n',
                            "ixp_owner": ixp_owner,
                            "ixp_rules_id": ixp_id,
                            "active_flag": is_active
                        };

                        ixp_wizard.rule_name = ixp_rules_name;
                        result = adiha_post_data("return_json", data, "", "", "ixp_wizard.save_first_form_callback");
                    }
                } else if (step == num_steps[3]) { //saving logic for second form.
                    parent.wizard_window.window('w1').progressOn();
                    var form_object = ixp_wizard.form["form_step_" + 2];
                    var data_source_location = form_object.getItemValue('file_upload_status');
                    var connection_string = form_object.getItemValue('connection_string');
                    var delimiter = form_object.getItemValue('delimiter');
                    var data_source_alias = form_object.getItemValue('data_source_alias');
                    var is_header_less = form_object.getItemValue('is_header_less');
                    var num_of_columns = form_object.getItemValue('num_of_columns');
                    var custom_import = form_object.getItemValue('custom_import');
                    
                    if (mode == 'u' && custom_import == 0) {
                        parent.wizard_window.window('w1').progressOff();
                    }

                    var ssis_package = form_object.getItemValue('ssis_package');
                    var use_parameter = 0;
                    var clr_function_id = form_object.getItemValue('clr_function_id');
                    var file_transfer_endpoint_id = form_object.getItemValue('cmb_file_transfer_endpoint_id');
                    file_transfer_endpoint_id = file_transfer_endpoint_id.substr(0,file_transfer_endpoint_id.indexOf('|'));

                    var ftp_remote_directory = form_object.getItemValue('txt_ftp_remote_directory');
                    var ws_function_name = form_object.getItemValue('ws_function_name');
                    var excel_sheet = form_object.getItemValue('excel_sheets');
                    
                    var folder_location = form_object.getItemValue('folder_location');
                    
                    var enable_email_import = form_object.getItemValue('enable_email_import');
                    var send_email_import_reply = form_object.getItemValue('send_email_import_reply');
                    
					if (is_header_less == 0 || is_header_less == 'n') {
                        is_header_less = 'n';
                    } else {
                        is_header_less = 'y';
                    }

                    if (ixp_import_data_source_id > 0) {
                        data_source_id = ixp_import_data_source_id;
                    } else {
                        data_source_id = null;
                    }
                
                    data = {
                        "action": "spa_ixp_import_data_source", 
                        "flag": mode,
                        "import_data_source_id": data_source_id,
                        "process_id": process_id,
                        "rules_id": ixp_wizard.rules_id,
                        "data_source_type": null,
                        "data_source_location": decodeURIComponent('<?php echo $server_path;?>')+'\\'+data_source_location,
                        "connection_string": connection_string,
                        "delimiter": delimiter,
                        "data_source_alias": data_source_alias,
                        "is_header_less": is_header_less,
                        "no_of_columns": num_of_columns,
                        "folder_location": folder_location,
                        "custom_import": custom_import,
                        "package": ssis_package,
                        "use_parameter": use_parameter,
                        "ws_function_name": ws_function_name,
                        "clr_function_id": clr_function_id,
                        "excel_sheet": excel_sheet,                        
                        "enable_email_import": enable_email_import,
                        "send_email_import_reply": send_email_import_reply,
                        "file_transfer_endpoint_id": file_transfer_endpoint_id,
                        "ftp_remote_directory": ftp_remote_directory
                    };
					
					result = adiha_post_data("return_array", data, "", "", " ixp_wizard.save_second_form_callback");
                } else if (step == 3 && num_steps[4] == 3) {
                    data_source_id = ixp_wizard.data_source_id;
                    rules_id = ixp_wizard.rules_id;
                    var form_object9 = ixp_wizard.form["form_step_9"];
                    
                    var customized_query = ixp_wizard.customized_query.replace(/['"]/g, "''");
                    
                    data = {
                        "action": "spa_ixp_import_data_source",
                        "flag": "p", 
                        "import_data_source_id": data_source_id,
                        "process_id": process_id,
                        "rules_id": rules_id,
                        "customizing_query": customized_query
                    };
                    result = adiha_post_data("return_array", data, "", "", "");
                } else if (step == 5) {
                    data_source_id = ixp_wizard.data_source_id;
                    connection_string = ixp_wizard.connection_string;
                    customized_import_table = ixp_wizard.customized_import_table;
                    import_process_table = ixp_wizard.import_process_table;
                    rules_id = ixp_wizard.rules_id;
                    tree_ids = ixp_wizard.grid["grid_step_4"].getAllSubItems(0);
                    tree_xml = '<Root>';
                    var changed_ids = new Array();
                    changed_ids = tree_ids.split(",");
                    repeat_table_id_check = '';
                    table_sort_id = 0;
                    
                    $.each(changed_ids, function(index1, value) {
                        
                        if (value.indexOf("a_") != -1) {
                            id = value.replace('a_', '');
                            tables_id_arr = id.split('_');
                            table_id = tables_id_arr[0];

                            subtree_ids = ixp_wizard.grid["grid_step_4"].getSubItems(value);
                            
                            if (subtree_ids) {
                                var sub_changed_ids = new Array();
                                sub_changed_ids = subtree_ids.split(",");
                                
                                $.each(sub_changed_ids, function(index2, value) {
                                    idd = value.replace('b_', '');
                                    dep_tables_id_arr = idd.split('_');
                                    dep_table_id = dep_tables_id_arr[0];
                                    repeat_number = (repeat_table_id_check.match(new RegExp(table_id, "g")) || []).length;

                                    tree_xml += '<PSRecordset RulesId="' + rules_id + '" TablesId="' + table_id + '" TablesOrder="' + table_sort_id + '"';
                                    tree_xml += ' DepTableId="' + dep_table_id + '" DepTableOrder="' + index2 + '" RepeatNumber="' + repeat_number + '"></PSRecordset>';
                                });
                            } else {
                                repeat_number=0;
                                tree_xml += '<PSRecordset RulesId="' + rules_id + '" TablesId="' + table_id + '" TablesOrder="' + table_sort_id + '"';
                                tree_xml += ' DepTableId="" DepTableOrder="0" RepeatNumber="' + repeat_number + '"></PSRecordset>';
                            }

                            repeat_table_id_check += table_id + ',';
                            table_sort_id++;
                        }
                    });

                    tree_xml += '</Root>';
                    
                    data = {
                        "action": "spa_ixp_export_tables",
                        "flag": "i",
                        "process_id": process_id,
                        "xml": tree_xml
                    };
                    result = adiha_post_data("return_array", data, "", "", "");
                } else if (step == 7) {
                    //commented as this gave issue for doubling of single quote on saving.
                    // var after_trigger = ixp_wizard.after_trigger.replace(/['"]/g, "''");

                    // var before_trigger = ixp_wizard.before_trigger.replace(/['"]/g, "''");

                    data = {
                        "action": "spa_ixp_rules",
                        "flag": "u",
                        "ixp_rules_id": rules_id,
                        "before_insert_triger": (ixp_wizard.before_trigger == '') ? 'NULL': ixp_wizard.before_trigger.replace('"', '&quot;'),
                        "after_insert_triger": (ixp_wizard.after_trigger == '') ? 'NULL': ixp_wizard.after_trigger,
                        "process_id": process_id
                    };
                    result = adiha_post_data("return_array", data, "", "", "");
                } else if (step == 8) {
                    $("#next_btn").attr("disabled", true);
                    var run_rule = ixp_wizard.form["form_step_7"].getItemValue('run_rule');
                    var server_path = <?php echo "'" . addslashes(addslashes($server_path)) . "'"; ?>;
                    
                    run_rule = run_rule ? 'y' : 'n';

                    // calls flag 'p' save data from process table and proceed. 
                    data = {
                        "action": "spa_ixp_rules",
                        "flag": "p",
                        "ixp_rules_id": rules_id,
                        "run_rules": run_rule,
                        "server_path": decodeURIComponent('<?php echo $server_path;?>'),
                        "import_export_flag": "i",
                        "process_id": process_id
                    };
                    result = adiha_post_data("alert", data, "", "", "ixp_wizard.final_callback");
                }
            }
            
            ixp_wizard.final_callback = function(result) {
                
                if (result[0].errorcode == 'Success') {
                    parent.data_ixp.refresh_grid();
                    var delay = 500;
                    
                    setTimeout(function() {  
                        parent.unload_window();
                    }, delay);
                } else {
                    $("#next_btn").attr("disabled", false);
                }
            }

            ixp_wizard.save_ixp_rule_callback = function (result) {
                var return_data = JSON.parse(result);
                
                if (return_data[0].status == 'Success') {
                    var form_object = ixp_wizard.form["form_step_" + 1];
                    var ixp_rules_name = form_object.getItemValue('ixp_rules_name');
                    var ixp_category = form_object.getItemValue('ixp_category');
                    var is_system_import = form_object.getItemValue('is_system_import');
                    var ixp_owner = form_object.getItemValue('ixp_owner');
                    var is_active = form_object.getItemValue('is_active');
                    
                    if (is_active == false) is_active = 0;
                    
                    var flag = (mode == 'u') ? 'y' : 'i';

                    data = {
                        "action": "spa_ixp_rules", 
                        "flag": flag,
                        "process_id": process_id,
                        "ixp_rules_name": ixp_rules_name,
                        "import_export_flag": "i",
                        "ixp_category": ixp_category,
                        "is_system_import": (is_system_import == '1') ? 'y' : 'n',
                        "ixp_owner": ixp_owner,
                        "ixp_rules_id": ixp_id,
                        "active_flag": is_active
                    };

                    ixp_wizard.rule_name = ixp_rules_name;
                    result = adiha_post_data("return_json", data, "", "", "ixp_wizard.save_first_form_callback");
                } else {
                    show_messagebox(return_data[0].message, function() {
                            var delay = 2000;
                            setTimeout(function() {
                                parent.data_ixp.open_wizard(-1, '', 'Import');
                            }, delay);
                    });
                }
            }

            ixp_wizard.save_first_form_callback = function (result) {
                var return_data = JSON.parse(result);

                if (return_data[0].status == 'Success') {
                    
                    if (mode == 'i') {
                        ixp_wizard.rules_id = return_data[0].recommendation;
                    } else {
                        ixp_wizard.rules_id = <?php echo $import_export_id; ?>;
                    }

                    //get tables and dependent tables
                    if (mode == 'u') {
                        //tables
                        data = {
                            "action": "spa_ixp_export_tables",
                            "flag": "m",
                            "ipx_rules_id": ixp_wizard.rules_id,
                            "process_id": process_id
                        };

                        result = adiha_post_data("return_array", data, "", "", "ixp_wizard.get_tables");
                        
                        //dependent tables
                        data = {
                            "action": "spa_ixp_export_tables",
                            "flag": "n",
                            "ipx_rules_id": ixp_wizard.rules_id,
                            "process_id": process_id
                        };
                        result = adiha_post_data("return_array", data, "", "", "ixp_wizard.get_dependent_tables");
                    }
                } else {
                    show_messagebox(return_data[0].message, function() {
                            var delay = 2000;
                            
                            setTimeout(function() {
                                parent.data_ixp.open_wizard(-1, '', 'Import');
                            }, delay);
                    });
                }
            }

            ixp_wizard.get_tables = function(result) {
                ixp_wizard.update_table_ids = '';
                
                for (index = 0; index < result.length; ++index) {
                    
                    if (index != 0) {
                        ixp_wizard.update_table_ids += ',';
                    }

                    ixp_wizard.update_table_ids += result[index][0];
                    ixp_wizard.update_table_ids += '/' + result[index][2];
                }
            }
            
            ixp_wizard.get_dependent_tables = function(result) {
                ixp_wizard.update_dependent_table_ids = '';
                
                for (index = 0; index < result.length; ++index) {
                    
                    if (index != 0) {
                        ixp_wizard.update_dependent_table_ids += ',';
                    }

                    ixp_wizard.update_dependent_table_ids += result[index][0];
                    ixp_wizard.update_dependent_table_ids += '/' + result[index][2];
                    ixp_wizard.update_dependent_table_ids += '/' + result[index][1];
                }

                $("#next_btn").attr("disabled", false);   
            }

            /* Second Form */
            // Callback to save data of first step form.
            ixp_wizard.save_second_form_callback = function(result) {
                var form_object = ixp_wizard.form["form_step_" + 2];
                var data_source_location = form_object.getItemValue('file_upload_status');
                var connection_string = form_object.getItemValue('connection_string');
                var delimiter = form_object.getItemValue('delimiter');
                var data_source_alias = form_object.getItemValue('data_source_alias');
                var is_header_less = form_object.getItemValue('is_header_less');
                var num_of_columns = form_object.getItemValue('num_of_columns');
                var custom_import = form_object.getItemValue('custom_import');
                var ssis_package = form_object.getItemValue('ssis_package');
                var use_parameter = 0;
                var ws_function_name = form_object.getItemValue('ws_function_name');
                var clr_function_id = form_object.getItemValue('clr_function_id');
                var file_transfer_endpoint_id = form_object.getItemValue('cmb_file_transfer_endpoint_id');
                if(typeof endpoint !== 'undefined') {
                    file_transfer_endpoint_id = file_transfer_endpoint_id.substr(0,endpoint.indexOf('|'));
                }
                var ftp_remote_directory = form_object.getItemValue('txt_ftp_remote_directory');
                var file_upload_status = form_object.getItemValue('file_upload_status');
                var excel_sheet = form_object.getItemValue('excel_sheets');
                var folder_location = form_object.getItemValue('folder_location');
                  
                if (is_header_less == 0 || is_header_less == 'n') {
                    is_header_less = 'n';
                } else {
                    is_header_less = 'y';
                }

                if (mode == 'i') {
                    var rules_id = 'NULL';
                }

                //setting connection string value in namespace variable so that we can use for future.
                if (connection_string) {
                    ixp_wizard.connection_string = connection_string;
                } else {
                    ixp_wizard.connection_string = 'NULL';
                }

                //setting custom_import value in namespace variable so that we can use for future.
                if (custom_import) {
                    ixp_wizard.customized_import_table = custom_import;
                } else {
                    ixp_wizard.customized_import_table = 0;
                }

                if (data_source_alias) {
                    ixp_wizard.data_source_alias = data_source_alias;
                } else {
                    ixp_wizard.data_source_alias ='NULL';
                }
                  
                if (file_upload_status != 0) {   			
                    
                    if (data_source_location) {
                        data = {
                            "file_name": file_upload_status,
                            "m_file_name": file_upload_status,
                            "relation_source": 'NULL',
                            "process_id": process_id,
                            "delim": delimiter,
                            "is_header_less": is_header_less,
                            "no_of_columns": num_of_columns,
                            "alias": data_source_alias,
                            "excel_sheet": excel_sheet
                        };
                    
                        url = php_script_loc_ajax + "spa_generic_import.php"
                        data = $.param(data);
                        
                        $.ajax({
                            type: "POST",
                            dataType: "json",
                            url: url,
                            data: data,
                            success: function(data) {
                                ixp_wizard.save_second_form_second_callback('NULL');
                            },
                            error: function(xht) {
                                parent.wizard_window.window('w1').progressOff();
                                show_messagebox(JSON.stringify(xht));
                            }
                        });
                    } else if (ssis_package) {
                        data = {
                            "action": "spa_ixp_run_ssis_package", 
                            "flag": "r",
                            "process_id": process_id,
                            "rules_id": ixp_wizard.rules_id,
                            "package_id": ssis_package,
                            "use_parameter": use_parameter
                        };
                        result = adiha_post_data("return_array", data, "", "", "ixp_wizard.save_second_form_second_callback");
                    } else if (ws_function_name) {
                        data = {
                            "action": "spa_ixp_soap_functions", 
                            "flag": "r",
                            "process_id": process_id,
                            "ws_function_name": ws_function_name
                        };
                        result = adiha_post_data("return_array", data, "", "", "ixp_wizard.save_second_form_second_callback");
                    }  else if (clr_function_id) {
                        ixp_wizard.save_second_form_second_callback('NULL');
                    }  else if (clr_function_id) {
                        ixp_wizard.save_second_form_second_callback('NULL');
                    } 
                } else if (file_upload_status == 0) {
                    ixp_wizard.save_second_form_second_callback('NULL');
                }
            }

            //Second Callback to save data of second step form.
            ixp_wizard.save_second_form_second_callback = function(result) {
                parent.wizard_window.window('w1').progressOff();
            }
            
            function close_data_customized_window() {
                ixp_wizard.w1.close();
            }
            /* END of Second Form */

            /* Third Form */
            /*
             * Function to open relation popup form
             * @param {type} mode: insert/update
             * @param {type} id: id of the relation for update
             * @returns {undefined}
             */
            ixp_wizard.open_relation_popup = function(mode, id) {
                var data_source_alias = ixp_wizard.form["form_step_" + 2].getItemValue('data_source_alias');
                var data_source_type = ixp_wizard.form["form_step_" + 2].getItemValue('data_source_type');
                param = 'data.relations.php?rules_id=' + ixp_wizard.rules_id + '&process_id=' + process_id + '&mode=' + mode + '&relation_id=' + id + '&parent_alias=' + data_source_alias + '&parent_source_type=' + data_source_type;
                var is_win = dhxWins.isWindow('ixp_wizard.w2');
                
                if (is_win == true) {
                    ixp_wizard.w2.close();
                }

                ixp_wizard.w2 = dhxWins.createWindow("w1", 50, 50, 800, 340);
                ixp_wizard.w2.setText("Connected Data");
                ixp_wizard.w2.attachURL(param, false, true);
            }
            
            /*
             * Function to delete a relation in the grid.
             * @returns {undefined}
             */
            ixp_wizard.delete_relation = function() {
                var selectedId = ixp_wizard.grid["grid_step_3"].getSelectedRowId();
                ixp_import_relation_id = ixp_wizard.grid["grid_step_3"].cells(selectedId, 0).getValue();
                
                data = {
                    "action": "spa_ixp_import_relation",
                    "flag": "d",
                    "process_id": "<?php echo $process_id; ?>",
                    "rules_id": "<?php echo $rules_id ?? 'NULL'; ?>",
                    "relation_id": ixp_import_relation_id
                };
                result = adiha_post_data("alert", data, "", "", "");
                refresh_data_relation_grid();
            }

            /*
             * Function to refresh the grid.
             * @returns {undefined}             
             */
            function refresh_data_relation_grid() {
                
                /* Load relation grid*/
                var grid_param = {
                    "flag": "s",
                    "process_id": process_id,
                    "rules_id": ixp_wizard.rules_id,
                    "action": "spa_ixp_import_relation"
                };
                var row_count = ixp_wizard.grid["grid_step_3"].getRowsNum();

                if (row_count > 0) {
                    ixp_wizard.grid["grid_step_3"].clearAll();
                }

                grid_param = $.param(grid_param);
                var data_url = js_data_collector_url + "&" + grid_param;
                ixp_wizard.grid["grid_step_3"].loadXML(data_url);
                return;
                /* END of Load relation grid */
            }
            
            /*
             * Funciton to close the relation popup
             * @returns {undefined}             */
            function close_data_relation_window() {
                ixp_wizard.w2.close();
            }
            /* END of Third Form */

            /* Fourth Form */
            /*
             * Creates the grid to load the tables in the grid 
             * @param {int} step: Step which is 4.
             * @param {int} grid_ids: IDs of the table
             * @param {type} subgrid_ids: IDs of the dependent table.
             * @returns {undefined}             
             */
            function create_table_grid(grid_ids, subgrid_ids, repeat_flag) {
                
                //getting user set value
                dep_table_ids = ixp_wizard.radio_form_name.getUserData("", "dep_table_mapping_ids");
                table_ids = ixp_wizard.radio_form_name.getUserData("", "table_mapping_ids");
                xml_tree = ixp_wizard.radio_form_name.getUserData("", "table_mapping_xml");
                
                // If the tree is loaded for the first time. I.e. there is no nodes in the tree.
                /* First Time Node Creation */
                if (table_ids == '') {
                    
                    // Creating of tree object.
                    inner_cell_object_a = ixp_wizard.layout["inner_grid_layout_4"].cells('a');
                    ixp_wizard.grid["grid_step_4"] = inner_cell_object_a.attachTree();
                    ixp_wizard.grid["grid_step_4"].setImagePath("<?php echo $image_path; ?>dhxtoolbar_web/");

                    // Attaching event of the tree when double clicked opens the column mapping window.
                    ixp_wizard.grid["grid_step_4"].attachEvent("onDblClick", function(id) {
                        ixp_wizard.grid["grid_step_4"].openAllItems(id);
                        idd = ixp_wizard.get_tree_table_id(id);
                        index = ixp_wizard.grid["grid_step_4"].getIndexById(id);
                        ixp_wizard.edit_table(idd, index);
                    });

                    /* WHEN THERE IS DEPENDENT TABLE SELECTED. */
                    // if there is dependent table to be created when the tree is loaded for the first time.
                    if (subgrid_ids.length > 0) {
                        var table_ids_split = JSON.stringify(table_ids).split(',');
                        
                        if ((repeat_flag == 'n') || (repeat_flag == 'd')) {
                            a_id = 'a_' + grid_ids[0][0] + '_0';
                            
                            //checking if there is already such table in the tree.
                            if (table_ids.indexOf(grid_ids[0][0]) == -1) {
                                xml_tree += '<item text="' + grid_ids[0][1] + '" id="' + a_id + '">';
                                if (table_ids) {
                                    table_ids += ',' + grid_ids[0][0];
                                } else {
                                    table_ids = grid_ids[0][0];
                                }
                            }
                        } else if (repeat_flag == 't') {
                            repeat_number = (new Date()).valueOf();
                            
                            //adding repeat number to make table node's item id unique.
                            a_id = 'a_' + grid_ids[0][0] + '_' + repeat_number;
                            
                            xml_tree += '<item text="' + grid_ids[0][1] + '" id="' + a_id + '">';
                            
                            if (table_ids) {
                                table_ids += ',' + grid_ids[0][0];
                            } else {
                                table_ids = grid_ids[0][0];
                            }

                        }
                        //adding comma to dependent table ids list.
                        if (dep_table_ids) dep_table_ids += ',';

                        //filtering existing dependent table ids of the table id.
                        inner_item_ids = ixp_wizard.grid["grid_step_4"].getAllSubItems(a_id);
                        if (inner_item_ids) {
                            
                            //decoding the dependent child id to get the actual dependent table ids.
                            var find = 'b_';
                            var re = new RegExp(find, 'g');
                            inner_item_ids = inner_item_ids.replace(re, '');
                            var find1 = '_' + grid_ids[0][0];
                            var re1 = new RegExp(find1, 'g');
                            inner_item_ids = inner_item_ids.replace(re1, '');
                        } else {
                            inner_item_ids = '0';
                        }

                        //setting the table ids in userdata variable.
                        ixp_wizard.radio_form_name.setUserData("", "table_mapping_ids", table_ids);

                        //Looping to add dependent tables.
                        for (var i = 0; i < subgrid_ids.length; i++) {
                            
                            if (i != 0) dep_table_ids += ',';

                            if (repeat_flag != 'd') {
                                
                                if (inner_item_ids.indexOf(subgrid_ids[i][0]) == -1) {
                                    xml_tree += '<item text="' + subgrid_ids[i][1] + '" id="b_' + subgrid_ids[i][0] + '_' + grid_ids[0][0] + '"/>';
                                    dep_table_ids += subgrid_ids[i][0];
                                }
                            } else {
                                xml_tree += '<item text="' + subgrid_ids[i][1] + '" id="b_' + subgrid_ids[i][0] + '_' + grid_ids[0][0] + '"/>';
                                dep_table_ids += subgrid_ids[i][0];
                            }
                        }

                        xml_tree += '</item>';
                        
                        //setting the table ids in userdata variable.
                        ixp_wizard.radio_form_name.setUserData("", "table_mapping_xml", " ");
                        
                        //setting the dependent table ids in userdata variable.
                        ixp_wizard.radio_form_name.setUserData("", "dep_table_mapping_ids", dep_table_ids);
                    }
                    /* END OF WHEN THERE IS DEPENDENT TABLE SELECTED. */
                    
                    /* WHEN THERE IS NO DEPENDENT TABLE SELECTED. */
                    else if (grid_ids.length > 0) {
                        table_ids = ixp_wizard.radio_form_name.getUserData("", "table_mapping_ids");
                        
                        if (table_ids) table_ids += ',';

                        for (var i = 0; i < grid_ids.length; i++) {
                            
                            if (i != 0) table_ids += ',';

                            a_id = 'a_' + grid_ids[i][0] + '_0';
                            xml_tree += '<item text="' + grid_ids[i][1] + '" id="' + a_id + '"></item>';
                            table_ids += grid_ids[i][0];
                        }

                        ixp_wizard.radio_form_name.setUserData("", "table_mapping_xml", xml_tree);
                        ixp_wizard.radio_form_name.setUserData("", "table_mapping_ids", table_ids);
                    }

                    xml = '<tree id="0">' + xml_tree + '</tree>';
                    ixp_wizard.grid["grid_step_4"].loadXMLString(xml);
                    ixp_wizard.grid["grid_step_4"].openAllItems(0);
                }
                
                /* WHEN THERE IS NO DEPENDENT TABLE SELECTED. */
                /* END of First Time Node Creation */

                // If there exists already a tree loaded up.
                else {
                    
                    //spliting the table ids.
                    var table_ids_split = JSON.stringify(table_ids).split(',');
                    
                    //count: Getting the last index of the existing node in the tree.
                    if (table_ids_split.length > 0) {
                        count = table_ids_split.length - 1;
                    } else {
                        count = 0;
                    }

                    /* WHEN THERE IS DEPENDENT TABLE SELECTED. */
                    if (subgrid_ids.length > 0) {
                        
                        if (repeat_flag != 't') {
                            
                            // If table not exists then create one.
                            a_id = 'a_' + grid_ids[0][0] + '_0'; //id of the table.
                            
                            //checking if there already exists such table in the grid.
                            if (table_ids.indexOf(grid_ids[0][0]) == -1) {
                                ixp_wizard.grid["grid_step_4"].insertNewNext(ixp_wizard.grid["grid_step_4"].getItemIdByIndex(0, count), a_id, grid_ids[0][1], 0, 0, 0, 0, 'SELECT');

                                if (table_ids) {
                                    table_ids += ',' + grid_ids[0][0];
                                } else {
                                    table_ids = grid_ids[0][0];
                                }
                            } else {
                                if (repeat_flag == 'n') return false;
                            }
                        } else if (repeat_flag == 't') {
                            
                            //adding repeat number to id to make it unique for the table.    
                            repeat_number = (new Date()).valueOf();
                            
                            a_id = 'a_' + grid_ids[0][0] + '_' + repeat_number;
                            ixp_wizard.grid["grid_step_4"].insertNewNext(ixp_wizard.grid["grid_step_4"].getItemIdByIndex(0, count), a_id, grid_ids[0][1], 0, 0, 0, 0, 'SELECT');

                            if (table_ids) {
                                table_ids += ',' + grid_ids[0][0];
                            } else {
                                table_ids = grid_ids[0][0];
                            }
                        }

                        if (dep_table_ids) dep_table_ids += ',';

                        //filtering existing dependent table ids of the table id.
                        inner_item_ids = ixp_wizard.grid["grid_step_4"].getAllSubItems(a_id);
                        
                        if (inner_item_ids) {
                            var find = 'b_';
                            var re = new RegExp(find, 'g');
                            inner_item_ids = inner_item_ids.replace(re, '');
                            var find1 = '_' + grid_ids[0][0];
                            var re1 = new RegExp(find1, 'g');
                            inner_item_ids = inner_item_ids.replace(re1, '');
                        } else {
                            inner_item_ids = '0';
                        }

                        ixp_wizard.radio_form_name.setUserData("", "table_mapping_ids", table_ids);
                        
                        //actual_table_id: this is userdata is set when repeat dependent table mode is active. this helps to identify which table node was selected to add duplicate dependent table.
                        actual_table_ids = ixp_wizard.radio_form_name.getUserData("", "actual_table_mapping_ids");
                        
                        if (actual_table_ids) {
                            a_id = actual_table_ids;//assign the set id in the table id variable.
                            actual_table_ids = ixp_wizard.radio_form_name.setUserData("", "actual_table_mapping_ids", "");
                        }

                        for (var i = 0; i < subgrid_ids.length; i++) {
                            if (i != 0) dep_table_ids += ',';
                            
                            b_id = 'b_' + subgrid_ids[i][0] + '_' + grid_ids[0][0];
                            
                            if (repeat_flag != 'd') {
                                
                                if (inner_item_ids.indexOf(subgrid_ids[i][0]) == -1) {
                                    ixp_wizard.grid["grid_step_4"].insertNewItem(a_id, b_id, subgrid_ids[i][1], 0, 0, 0, 0, 'SELECT');
                                    dep_table_ids += subgrid_ids[i][0];
                                }
                            } else { //for d flag. that is repeat dependent tables.
                                ixp_wizard.grid["grid_step_4"].insertNewItem(a_id, b_id, subgrid_ids[i][1], 0, 0, 0, 0, 'SELECT');
                                dep_table_ids += subgrid_ids[i][0];
                            }
                        }

                        ixp_wizard.radio_form_name.setUserData("", "dep_table_mapping_ids", dep_table_ids);
                    }
                    /* END OF WHEN THERE IS DEPENDENT TABLE SELECTED. */

                    /* WHEN THERE IS NO DEPENDENT TABLE SELECTED. */
                    // When tables are only mapped and send it over tree to be loaded up.
                    else if (grid_ids.length > 0) {
                        table_ids = ixp_wizard.radio_form_name.getUserData("", "table_mapping_ids");
                        var table_ids_split = JSON.stringify(table_ids).split(',');
                        
                        if (table_ids_split.length > 0) {
                            count = table_ids_split.length - 1;
                        } else {
                            count = 0;
                        }

                        for (var i = 0; i < grid_ids.length; i++) {
                            
                            if (i != 0) table_ids += ',';

                            a_id = 'a_' + grid_ids[i][0];

                            // When flag n and d.
                            if (repeat_flag != 't') {
                                
                                // only created if there is no such tables in the tree.
                                if (table_ids.indexOf(grid_ids[i][0]) == -1) {

                                    if ((table_ids) && (i == 0)) table_ids += ',';

                                    ixp_wizard.grid["grid_step_4"].insertNewNext(ixp_wizard.grid["grid_step_4"].getItemIdByIndex(0, count), a_id, grid_ids[i][1], 0, 0, 0, 0, 'SELECT');
                                    table_ids += grid_ids[i][0];
                                }
                            }
                            else {
                                if ((table_ids) && (i == 0)) table_ids += ',';
                                
                                ixp_wizard.grid["grid_step_4"].insertNewNext(ixp_wizard.grid["grid_step_4"].getItemIdByIndex(0, count), a_id, grid_ids[i][1], 0, 0, 0, 0, 'SELECT');
                                table_ids += grid_ids[i][0];
                            }
                        }

                        ixp_wizard.radio_form_name.setUserData("", "table_mapping_ids", table_ids);
                    }
                    /* END OF WHEN THERE IS NO DEPENDENT TABLE SELECTED. */
                }
            }
            
            /*
             * Returns the table ids of either table or dependent ta
             * @param {type} id ID of the table or dependent grid.
             * @returns {INT} ID of the table.
             *  
             */
            ixp_wizard.get_tree_table_id = function(id) {
                
                if (id.indexOf("a_") != -1) {
                    id = id.replace('a_', '');
                    tables_id_arr = id.split('_');
                    id = tables_id_arr[0];
                }
                else {
                    id = id.replace('b_', '');
                    tables_id_arr = id.split('_');
                    id = tables_id_arr[0];
                }
                return id;
            }
            
            /**
             * Create JSON object for grid.
             * @param  {[type]} grid_array [JSON]
             * @return {[type]}      [JSON object]
             */
            function get_grid_json(grid_array) {
                var total_count = grid_array.length;
                var grid_data = JSON.stringify(grid_array);
                var json_data = '{"total_count":"' + total_count + '", "pos":"0", "data":' + grid_data + '}';
                return json_data;
            }
            
            /*
             * To open popup for table mapping
             * @param {type} step
             * @returns {formData|Object}
             */
            ixp_wizard.open_table_popup = function() {
                var repeat_flag = ixp_wizard.radio_form_name.getItemValue('repeat_tables');
                var tables_id = '';
                var dependent_tables_id = '';
                
                if (repeat_flag == 'd') {
                    var tables_id = ixp_wizard.grid["grid_step_4"].getSelectedItemId();
                    
                    if ((!tables_id) || tables_id.indexOf("a_")) {
                        show_messagebox('Please select table.');
                        return false;
                    } else {
                        actual_table_ids = ixp_wizard.radio_form_name.setUserData("", "actual_table_mapping_ids", tables_id);
                        tables_id = tables_id.replace('a_', '');
                        tables_id_arr = tables_id.split('_');
                        tables_id = tables_id_arr[0];
                    }
                } else {
                    tables_id = tables_id.replace('a_', '');
                }

                param = 'data.table.column.php?repeat_flag=' + repeat_flag + '&process_id=' + process_id + '&import_export_flag=i&tables_id=' + tables_id + '&dependent_tables_id=' + dependent_tables_id;
                var is_win = dhxWins.isWindow('ixp_wizard.w3');
                
                if (is_win == true) {
                    ixp_wizard.w3.close();
                }

                ixp_wizard.w3 = dhxWins.createWindow("w3", 50, 50, 850, 450);
                ixp_wizard.w3.setText("Import Tables");
                ixp_wizard.w3.attachURL(param, false, true);
            }
            
            /*
             * Funciton to close the import table popup
             * @returns {undefined}             */
            function close_data_data_table_column_window() {
                ixp_wizard.w3.close();
            }
            
            /*
             * Opens the column mapping for the selected table. 
             * @param {int} tables_id: Id of the table.
             * @returns {undefined}             */
            ixp_wizard.edit_table = function(tables_id, row_index) {
                data_source_id = ixp_wizard.data_source_id;
                connection_string = ixp_wizard.connection_string;
                data_source_type = ixp_wizard.data_source_type;
                customized_import_table = ixp_wizard.customized_import_table;
                var data_source_alias = ixp_wizard.data_source_alias;
                 
                if (customized_import_table == 'undefined') {
                    customized_import_table = 0;
                }

                import_process_table = ixp_wizard.import_process_table;
                rules_id = ixp_wizard.rules_id;
                args = 'data.table.column.mapping.php?process_id=' + process_id + '&import_export_flag=i&tables_id=' + tables_id + '&rules_id=' + rules_id + '&row_index=' + row_index;

                if (data_source_type == 21401) {
                    args = args + '&data_source=link_server&connection_string=' + connection_string + '&customized_import_table=' + customized_import_table + '&data_source_id=' + data_source_id;
                } else if (data_source_type == 21403) {
                    args = args + '&data_source=ssis&import_process_table=' + import_process_table + '&customized_import_table=' + customized_import_table + '&data_source_id=' + data_source_id;
                } else if (data_source_type == 21404) {
                    args = args + '&data_source=web&import_process_table=' + import_process_table + '&customized_import_table=' + customized_import_table + '&data_source_id=' + data_source_id;
                } else if (data_source_type == 21406) {
                    args = args + '&data_source=lse&alias='+data_source_alias+'&import_process_table=' + import_process_table + '&customized_import_table=' + customized_import_table + '&data_source_id=' + data_source_id;
                } else {
                    args = args + '&data_source=file&customized_import_table=' + customized_import_table + '&data_source_id=' + data_source_id;
                }

                var is_win = dhxWins.isWindow('ixp_wizard.w4');
                
                if (is_win == true) {
                    ixp_wizard.w4.close();
                }

                ixp_wizard.w4 = dhxWins.createWindow("w4", 50, 50, 900, 480);
                ixp_wizard.w4.setText("Column Mapping");
                ixp_wizard.w4.attachURL(args, false, true);
                ixp_wizard.w4.maximize();
            }
            
            /*
             * Funciton to close the import table popup
             * @returns {undefined}             */
            function close_column_table_window() {
                ixp_wizard.w4.close();
            }
            
            /*
             * Delete the selected table in the grid
             * @param {int} dependent_table_id: ids of the table
             * @returns {undefined}             
             */
            ixp_wizard.delete_table = function(table_id) {
                var tables_id = ixp_wizard.grid["grid_step_4"].getSelectedItemId();
                dep_table_ids = ixp_wizard.grid["grid_step_4"].getAllSubItems(tables_id);
                
                //validation to check if table has been selected or not.
                if ((!tables_id)) {
                    show_messagebox('Please select table.');
                    return false;
                } else {
                    
                    // To check if it is the table
                    if (tables_id.indexOf("a_") != -1) {
                        tables_id = tables_id.replace('a_', '');
                        tables_id_arr = tables_id.split('_');
                        tables_id = tables_id_arr[0];

                        xml_table_ids = ixp_wizard.radio_form_name.getUserData("", "table_mapping_ids");
                        xml_dep_table_ids = ixp_wizard.radio_form_name.getUserData("", "dep_table_mapping_ids");

                        if (xml_table_ids.indexOf(tables_id + ",") != -1) {
                            xml_table_ids = xml_table_ids.replace(tables_id + ",", '');
                        } else if (xml_table_ids.indexOf("," + tables_id) != -1) {
                            xml_table_ids = xml_table_ids.replace("," + tables_id, '');
                        } else {
                            xml_table_ids = xml_table_ids.replace(tables_id, '');
                        }

                        //Deletes the dependent tables if there is any.    
                        if (dep_table_ids) {
                            var find = 'b_';
                            var re = new RegExp(find, 'g');
                            dep_table_ids = dep_table_ids.replace(re, '');

                            dep_table_split_arr = dep_table_ids.split(',');
                            
                            for (var i = 0; i < dep_table_split_arr.length; i++) {
                                dep_tableid = dep_table_split_arr[i].split('_');
                                id = dep_tableid[0];

                                if (xml_dep_table_ids.indexOf(id + ",") != -1) {
                                    xml_dep_table_ids = xml_dep_table_ids.replace(id + ",", '');
                                } else if (xml_dep_table_ids.indexOf("," + id) != -1) {
                                    xml_dep_table_ids = xml_dep_table_ids.replace("," + id, '');
                                } else {
                                    xml_dep_table_ids = xml_dep_table_ids.replace(id, '');
                                }
                            }

                            ixp_wizard.radio_form_name.setUserData("", "dep_table_mapping_ids", xml_dep_table_ids);
                        }

                        ixp_wizard.radio_form_name.setUserData("", "table_mapping_ids", xml_table_ids);
                    }

                    // To check if it is the dependent table
                    else {
                        tables_id = tables_id.replace('b_', '');
                        tables_id_arr = tables_id.split('_');
                        tables_id = tables_id_arr[0];
                        xml_dep_table_ids = ixp_wizard.radio_form_name.getUserData("", "dep_table_mapping_ids");
                        
                        if (xml_dep_table_ids.indexOf(tables_id + ",") != -1) {
                            xml_dep_table_ids = xml_dep_table_ids.replace(tables_id + ",", '');
                        } else if (xml_dep_table_ids.indexOf("," + tables_id) != -1) {
                            xml_dep_table_ids = xml_dep_table_ids.replace("," + tables_id, '');
                        } else {
                            xml_dep_table_ids = xml_dep_table_ids.replace(tables_id, '');
                        }

                        ixp_wizard.radio_form_name.setUserData("", "dep_table_mapping_ids", xml_dep_table_ids);
                    }

                    ixp_wizard.grid["grid_step_4"].deleteItem(ixp_wizard.grid["grid_step_4"].getSelectedItemId(), true);
                }
            }
            
            /*
             * Delete the selected dependent table in the grid
             * @param {int} dependent_table_id: ids of the dependent table
             * @returns {undefined}             
             */
            function delete_dep_table(dependent_table_id) {
                ixp_wizard.grid["grid_step_4"].forEachRow(function(id) {
                    var sub_grid_object = ixp_wizard.grid["grid_step_4"].cells(id, 1).getSubGrid();
                    
                    if (sub_grid_object) {
                        i = 0;
                        sub_grid_object.forEachRow(function(sid) {
                            dep_table_value = sub_grid_object.cells(sid, 0).getValue();
                            
                            if (dep_table_value == dependent_table_id) {
                                sub_grid_object.deleteRow(sid);
                            }
                            i++;
                        });
                    }
                });
            }
			
			/*
  			 * Validate Duplicate Import Function Name
			 */
			validate_import_function = function(import_function, mode, rules_id) {
				if (mode == 'i') {
					rules_id = ''
				}
				
				var data = {
					"action": "spa_ixp_import_data_source", 
					"flag": 'v',
					"ws_function_name": import_function,
					"rules_id": rules_id
				}
				
				var return_status;
				data = $.param(data)
				
				$.ajax({
					type: "POST",
					dataType: "json",
					url: js_form_process_url,
					async: false,
					data: data,
					success: function(data) {
						response_data = data["json"];
						return_status = response_data[0].status;
					}
				});
				
				return return_status;
			}

            /***************************************************End of Fourth Form***********************************************************/
            /**
             * [get_form_json Get Form Json]
             * @param  {[varchar]} step [Step Id]
             */
            ixp_wizard.get_form_json = function(step) {
                var form_template = _.template($('#template_step' + step).text());
                formData = form_template();
                formData = get_form_json_locale($.parseJSON(formData));
                return formData;
            }


            /**
             * [second_form_events Differents Events for Second Form]
             * @param  {[type]} form_object [Form Object]
             * @param  {[type]} name        [Field Name]
             * @param  {[type]} value       [Field Value]
             * @param  {[type]} state       [State - in case of checkbox]
             */
            ixp_wizard.second_form_events = function(form_object, name, value, state) {
                var is_header_less = form_object.isItemChecked('is_header_less');
                
                if (is_header_less) {
                    form_object.showItem('num_of_columns');
                } else {
                    form_object.hideItem('num_of_columns');
                }       
            }
			
			ixp_wizard.open_import_filter = function(data_source, email_filter_clicked) {
				var rules_id = '<?php echo $ixp_rules_id; ?>';
				var param = 'data.import.filter.php?data_source=' + data_source + '&process_id=' + process_id + '&rules_id=' + rules_id;
                
                param += email_filter_clicked ? ('&email_filter_clicked=1') : '';
                
                var is_win = dhxWins.isWindow('ixp_wizard.flt');
                
                if (is_win == true) {
                    ixp_wizard.flt.close();
                }

                ixp_wizard.flt = dhxWins.createWindow("w1", 100, 10, 900, 500);
                ixp_wizard.flt.setText("Import Filter");
                ixp_wizard.flt.attachURL(param, false, true);
			}
        </script>

        <!-- First Step Template -->
        <script id="template_step1" type="text/template">
            [
            {"type": "settings", "position": "label-top"}, 
            {"type":"input", "name":"ixp_rules_id", "label":"ixp_rules_id", "value":"<?php echo $ixp_rules_id; ?>", "hidden":"true"},
            {"type":"input", "name":"rule_type", "label":"rule_type", "value":"i", "hidden":"true"},
                {"type":"input", "name":"ixp_rules_name", "label":"Name", "value": "<?php echo $ixp_rules_name; ?>", "validate":"NotEmpty", "inputWidth":400, "labelWidth":"auto", "validation_message":"Required Field", "required":true , "offsetLeft": "<?php echo $setting_offset_left; ?>" },
                {"type":"combo", "name":"ixp_category", "label":"Category", "validate":"NotEmpty", "filtering":"true",  "inputWidth":400, "labelWidth":"auto", "options": [
            <?php echo $ixp_category_json; ?>
                ], "offsetLeft": "<?php echo $setting_offset_left; ?>"},
            {"type":"newcolumn"},        
                {"type":"input", "name":"ixp_owner", "label":"Owner", "value":"<?php echo $ixp_owner; ?>", "disabled":true, "inputWidth":400, "labelWidth":"auto", "offsetLeft": "<?php echo $setting_offset_left; ?>"},
                {"type":"checkbox", "offsetTop":28, "position": "label-right", "name":"is_system_import", "label":"System Rule", "checked":"<?php echo $is_system_import; ?>", "offsetLeft": "<?php echo $setting_offset_left; ?>"},
            {"type":"newcolumn"},
                {"type":"checkbox", "offsetTop":28, "position": "label-right", "name":"is_active", "label":"Active", "checked":<?php echo $is_active; ?>, "offsetLeft": "<?php echo $setting_offset_left; ?>"}
            ]
        </script>   
        <!-- First Step Template -->
        
        <!-- Second Step Template -->
        <script id="template_step2_two" type="text/template">
            [  
             
                {"type":"settings", "position":"label-top"},
                {"type":"block", "name":"data_source_block", "blockOffset":0, "list":[{"type":"block", "name":"datasource_header", "blockOffset":0, "list":[{"type":"input", "name":"data_source_alias", "label":"Alias(Without Space)", "validate":"NotEmpty", "labelWidth":"auto", "hidden":"true", "inputWidth":"<?php echo $ui_settings['field_size'] ?>", "tooltip":"Alias(Without Space)", "required":true, "validation_message":"Required Field", "value":"<?php echo $data_source_alias; ?>", "offsetLeft":"<?php echo $setting_offset_left; ?>" },
                { "type":"input", "name":"folder_location", "label":"Folder Location  <span style='cursor:pointer' onClick= 'ixp_wizard.open_import_filter(21400)'><font color=#0000ff><u><l><img src='../../../adiha.php.scripts/adiha_pm_html/process_controls/import_icons/Import_Filter_Icon<?php echo $filter_flag_array[21400]; ?>.png' alt='Filter' style='width:20px;height:20px;' ></img><l></u></font></span>", "value":"", "labelWidth":"auto", "inputWidth":"<?php echo $ui_settings['field_size']+80 ?>", "tooltip":"Folder Location", "offsetLeft":"<?php echo $setting_offset_left; ?>"},
                { "type":"newcolumn"},
                {"type": "checkbox", "name": "custom_import", "label": "Custom Import", "position": "label-right", "labelWidth": 140, "checked": "<?php echo $custom_import; ?>", "offsetLeft": "<?php echo $setting_offset_left; ?>", "offsetTop": "<?php echo $ui_settings['checkbox_offset_top'] ?>"} ]},
                { "type":"fieldset", "label":"Data Source Location", "width":"400", "list":[{ "type":"upload", "name":"data_source_location", "autoStart":true, "inputWidth":"320", "url":"<%= js_file_uploader_url %>&call_form=data_import_export", "mode":"html5"} ], "offsetLeft":"<?php echo $setting_offset_left; ?>"},{ "type":"input", "name":"file_upload_status", "label":"file_upload_status", "validate":"", "hidden":"true", "value":"0", "offsetLeft":"<?php echo $setting_offset_left; ?>"} ]
                },
                { "type":"fieldset", "label":"Email Import <span title='Email Import' style='cursor:pointer' onClick= 'ixp_wizard.open_import_filter(21409, true)'><font color=#0000ff><u><l><img src='../../../adiha.php.scripts/adiha_pm_html/process_controls/import_icons/Import_Filter_Icon<?php echo $filter_flag_array[21409]; ?>.png' alt='Filter' style='width:20px;height:20px;' ></img><l></u></font></span>", "width":"auto", "list":[
        				{ "type":"checkbox", "name":"enable_email_import", "label":"Enable Email Import", "position":"label-right", "labelWidth":"210", "checked":"<?php echo $enable_email_import; ?>", "offsetLeft":"<?php echo $setting_offset_left; ?>"},
						{ "type":"checkbox", "name":"send_email_import_reply", "hidden":"true", "label":"Send Email Import Reply", "position":"label-right", "labelWidth":"210", "checked":"<?php echo $send_email_import_reply; ?>", "offsetLeft":"<?php echo $setting_offset_left; ?>", "offsetTop":"<?php echo $ui_settings['checkbox_offset_top'] ?>"}
        			], "offsetLeft":"<?php echo $setting_offset_left; ?>"
        		},
                { "type":"newcolumn"},
                { "type":"fieldset", "label":"Excel & Flat File", "width":"auto", "list":[
        				{ "type":"checkbox", "name":"is_header_less", "label":"Source File without Header", "position":"label-right", "labelWidth":"210", "checked":"false", "offsetLeft":"<?php echo $setting_offset_left; ?>", "offsetTop":"<?php echo $ui_settings['checkbox_offset_top'] ?>"},
        				{ "type":"input", "name":"num_of_columns", "label":"Number of Columns", "labelWidth":"auto","inputWidth":"<?php echo $ui_settings['field_size']-30 ?>", "value":"<?php echo $no_of_columns; ?>", "offsetLeft":"<?php echo $setting_offset_left; ?>","offsetTop": "10"},
        				{ "type":"newcolumn"},
        				{ "type":"combo", "name":"excel_sheets", "label":"Excel Sheet", "validate":"", "value":"", "labelWidth":"auto", "inputWidth":"<?php echo $ui_settings['field_size']-30 ?>", "tooltip":"Excel Sheet", "filtering":"true", "options":[{ "value":"<?php echo $excel_sheet; ?>", "text":"<?php echo $excel_sheet; ?>"} ], "offsetLeft":"<?php echo $setting_offset_left; ?>"},
        				{ "type":"combo", "name":"delimiter", "label":"Delimiter", "validate":"", "value":"", "labelWidth":"auto", "inputWidth":"<?php echo $ui_settings['field_size']-30 ?>", "tooltip":"Delimiter", "filtering":"true", "options":[{ "value":",", "text":"Comma"},
        				{ "value":":", "text":"Colon"},{ "value":";", "text":"Semi Colon"},{ "value":"\\\\t", "text":"Tab"},{ "value":"|", "text":"Vertical Bar(Pipe)"} ], "offsetLeft":"<?php echo $setting_offset_left; ?>"} 
        			], "offsetLeft":"<?php echo $setting_offset_left; ?>"
                },
        		{ "type":"fieldset", "label":"FTP Detail <span title='FTP Detail' style='cursor:pointer' onClick= 'ixp_wizard.open_import_filter(-1)'><font color=#0000ff><u><l><img src='../../../adiha.php.scripts/adiha_pm_html/process_controls/import_icons/Import_Filter_Icon<?php echo $filter_flag_array[-1]; ?>.png' alt='Filter' style='width:20px;height:20px;' ></img><l></u></font></span>", "width":"auto", "list":[
                    { "type":"combo", "name":"cmb_file_transfer_endpoint_id", "label":"File Transfer Endpoint", "validate":"", "value":"", "labelWidth":"auto", "inputWidth":"<?php echo $ui_settings['field_size']-30 ?>", "tooltip":"File Transfer Endpoint", "filtering":"true", "options":[<?php echo $file_transfer_endpoint_id_json; ?>], "offsetLeft":"<?php echo $setting_offset_left; ?>"},
                    { "type": "label", "labelWidth": "150", "name": "endpoint_label", "label": "<?php echo $end_point_label; ?>","offsetLeft": "10","inputTop": "0", "position":"label-left", "disabled": "false"},                        
                    { "type":"newcolumn"},
                    { "type":"input", "name":"txt_ftp_remote_directory", "label":"FTP Folder", "inputWidth":"<?php echo $ui_settings["field_size"] ?>", "required":false, "offsetLeft":"<?php echo $setting_offset_left; ?>"}
                    ], "offsetLeft":"<?php echo $setting_offset_left; ?>"
        		},
                { "type":"newcolumn"},
                { "type":"fieldset", "label":"Web Service and Link Server", "width":"auto", "list":[
        				{ "type":"input", "name":"connection_string", "label":"Remote Data Source (Link Server)", "inputWidth":"<?php echo $ui_settings['field_size'] ?>", "required":false, "offsetLeft":"<?php echo $setting_offset_left; ?>"}, 
        				{ "type":"input", "name":"ws_function_name", "label":"Import Function (Web Service)", "labelWidth":"auto", "inputWidth":"<?php echo $ui_settings['field_size'] ?>", "tooltip":"Import Function", "value":"<?php echo $ws_function_name; ?>", "offsetLeft":"<?php echo $setting_offset_left; ?>"}
        			], "offsetLeft":"<?php echo $setting_offset_left; ?>"
        		},
        		{ "type":"fieldset", "label":"SSIS & CLR Function", "width":"auto", "list":[
        				{ "type":"combo", "name":"ssis_package", "label":"Package", "value":"", "labelWidth":"auto", "inputWidth":"<?php echo $ui_settings['field_size'] ?>", "tooltip":"SSIS Package", "filtering":"true", "options":[<?php echo $ixp_ssis_package_json; ?> ], "offsetLeft":"<?php echo $setting_offset_left; ?>"},
        				{ "type":"combo", "name":"clr_function_id", "label":"CLR Function", "value":"", "labelWidth":"auto", "inputWidth":"<?php echo $ui_settings['field_size'] ?>", "tooltip":"CLR Function", "filtering":"true", "options":[<?php echo $ixp_clr_function_json; ?> ], "offsetLeft":"<?php echo $setting_offset_left; ?>"}
        			], "offsetLeft":"<?php echo $setting_offset_left; ?>"
                }
            ]
        </script>
        <!-- Second Step Template -->

        <!-- Before Insert Trigger -->
        <script id="template_step5" type="text/template">
            [{"type": "settings", "position": "label-top"},
            {"type": "block", "blockOffset":0,
            "list": [
                    {"type": "input", "name": "before_insert_trigger", "label": "Pre-Import Trigger", "inputWidth": "1000", "rows":"20", "value":"", "offsetLeft": "<?php echo $setting_offset_left; ?>"}
            ]}
            ]
        </script> 
        <!-- Before Insert Trigger -->

        <!-- After Insert Trigger -->
        <script id="template_step6" type="text/template">
            [{"type": "settings", "position": "label-top"},
            {"type": "block", "blockOffset":0,
            "list": [
                    {"type": "input", "name": "after_insert_trigger", "label": "Post-Import Trigger", "inputWidth": "1000", "rows":"20", "value":"", "offsetLeft": "<?php echo $setting_offset_left; ?>"}
            ]}
            ]
        </script> 
        <!-- After Insert Trigger -->

        <!-- Summary TODO: Change this JSON-->
        <script id="template_step7" type="text/template">
            [{"type": "settings", "position": "label-top"},
            {"type": "block", "blockOffset":0,
            "list": [
                    {"type": "input", "name": "summary", "label": "Summary", "inputWidth": "1000", "rows":"20","value":"","readonly":"true", "offsetLeft": "15"},
                    {"type": "checkbox", "name": "run_rule", "label": "Run Rule", "position": "label-right", "tooltip": "Run Rules", "checked": "true", "offsetTop":"10", "offsetLeft": "<?php echo $setting_offset_left; ?>"}
            ]}
            ]
        </script> 
        <!-- Summary -->

        <script id="template_step9" type="text/template">
            [{"type": "settings", "position": "label-top"},
            {"type": "block", "blockOffset":0,
            "list": [
                    {"type": "input", "name": "customized_query", "label": "Customizing Query", "inputWidth": "1000", "rows":"20","value":"", "offsetLeft": "15"}
            ]}
            ]
        </script> 
    </body>
</html>