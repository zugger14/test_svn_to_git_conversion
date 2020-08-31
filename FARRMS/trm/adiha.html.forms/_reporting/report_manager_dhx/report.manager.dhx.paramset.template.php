<?php
/**
* Report manager paramset template screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<html>    
    <?php
        require_once('../../../adiha.php.scripts/components/include.file.v3.php');
        require_once('../../../adiha.php.scripts/components/include.ssrs.reporting.files.php');
        $report_paramset_theme_css = $app_php_script_loc . '/components/lib/adiha_dhtmlx/report.manager.dhx.paramset.template.css';
        //$report_paramset_theme_css = $app_php_script_loc . '/components/lib/adiha_dhtmlx/themes/dhtmlx_' . $theme. '/report.manager.dhx.paramset.template.css';
        
        $php_script_loc = $app_php_script_loc;
        $rights_page_paramset_iu = 10201622;
        $form_name = "report_paramset_iu";

        $mode = get_sanitized_value($_POST['mode'] ?? '');
        $process_id = get_sanitized_value($_POST['process_id'] ?? 'NULL');
        //$session_id = $_POST['session_id'];
        $page_id = get_sanitized_value($_POST['page_id'] ?? 'NULL');
        $report_id = get_sanitized_value($_POST['report_id'] ?? '');
        $report_paramset_id = get_sanitized_value($_POST['report_paramset_id'] ?? 'NULL');
        $paramset_name = '';
        $where_clause = '';
        $report_status = 2;
        $data_report_paramset = array();
        $data_report_param = array();
        $required_column_ids = array();

        /* As of Date Selection Map */
        $as_of_date['DATE.C'] = 'Custom As of Date';
        $as_of_date['DATE.F'] = 'First Day of the Month';
        $as_of_date['DATE.L'] = 'Last Day of the Month';
        $as_of_date['DATE.1'] = 'Day Before Run Date';   $as_of_date['DATE.X'] = 'Custom Days Before Run Date';

    $xml_url_udfs = "EXEC spa_rfx_report_dhx @flag='f', @process_id='null'";
    $scalar_functions_list = readXMLURL2($xml_url_udfs);  
        $delimiter = ',';
        $compress_file = '';
        $xml_format = '';
        $export_report_name = '';
        $export_location = '';
        $category_id = '';

        if ($mode == 'u') {
            $xml_url_report_paramset = "EXEC spa_rfx_report_paramset_dhx @flag='a', @process_id='$process_id', @report_paramset_id='$report_paramset_id'";
            $data_report_param_db = readXMLURL2($xml_url_report_paramset);
            $paramset_name = $data_report_param_db[0]['name'];
            $report_status = $data_report_param_db[0]['report_status'];

            $export_report_name = $data_report_param_db[0]['export_report_name'];
            $export_location = str_replace("\\","\\\\", $data_report_param_db[0]['export_location']);
            $export_report_format = $data_report_param_db[0]['output_file_format'];
            $delimiter = $data_report_param_db[0]['delimiter'];
            $xml_format = $data_report_param_db[0]['xml_format'];
            $display_header = $data_report_param_db[0]['report_header'];
            $compress_file = $data_report_param_db[0]['compress_file'];
            $category_id = $data_report_param_db[0]['category_id'];
            if($xml_format == '') {
                $xml_format = '-100000';
            }

        } else if ($mode == 'i') {
            $xml_url_report_paramset = "EXEC spa_rfx_report_paramset_dhx @flag='x', @process_id='$process_id', @report_id='$report_id'";
            $data_report_param_db = readXMLURL2($xml_url_report_paramset);
            //print("<pre>".print_r($data_report_param_db,true));die();
        }
        
        //assemble report param data to ease processes later 
        function sortby_param_order($a, $b) {
            return ($a['param_order'] ?? 0) > ($b['param_order'] ?? 0);
        }

        if (is_array($data_report_param_db) && sizeof($data_report_param_db) > 0 ) {
            foreach ($data_report_param_db as $k => $param) {
                if (!array_key_exists($param['root_dataset_id'], $data_report_param))
                    $data_report_param[$param['root_dataset_id']] = array();
                array_push($data_report_param[$param['root_dataset_id']], $param);
                
                if (!array_key_exists($param['root_dataset_id'], $required_column_ids))
                    $required_column_ids[$param['root_dataset_id']] = array();
                array_push($required_column_ids[$param['root_dataset_id']], $param['column_id']);
            }

            foreach ($data_report_param as $key => $item) {
                usort($data_report_param[$key], 'sortby_param_order');
            }
        }
        //print '<pre>';print_r($data_report_param);print '</pre>';die();

        $dataset_id = 'NULL';
        $column_url = 'NULL';
        $xml_get_ds = "EXEC spa_rfx_report_paramset_dhx @flag='h', @process_id='$process_id', @page_id='$page_id'";
        $datasets = readXMLURL($xml_get_ds);
    //$datasets_list = array();
        #trace the datasets involved
        $dataset_id_collection = array();

        if (is_array($datasets) && sizeof($datasets) > 0) {
        foreach ($datasets as $key => $dataset) {
                array_push($dataset_id_collection, md5($dataset[1]));
            array_push($datasets[$key], md5($dataset[1]));

            // if(!is_array($datasets_list[$dataset[0]]))
            //     $datasets_list[$dataset[0]] = array();
            // array_push($datasets_list[$dataset[0]], $dataset);
            }
        }

        $xml_get_dsc = "EXEC spa_rfx_report_paramset_dhx @flag='c', @process_id='$process_id', @page_id='$page_id'";
        $dataset_columns_linear = readXMLURL($xml_get_dsc);
        $dataset_columns = array();
        $column_datatype_map = array();
        $default_param_array = array();

        if (is_array($dataset_columns_linear) && sizeof($dataset_columns_linear) > 0) {
            // Added logic to pass blank value on new columns addition... 
        //array_push($dataset_columns[$dataset_columns_linear[0]], array('','','','','','','',''));
            $inc = 0;
            foreach ($dataset_columns_linear as $column) {            
                if (!array_key_exists($column[0], $dataset_columns))
                    $dataset_columns[$column[0]] = array();
            //if ($inc == 0)
                //array_push($dataset_columns[$column[0]], array('','','','','','','',''));
                $inc++;
                array_push($dataset_columns[$column[0]], array($column[1], $column[2], $column[3], $column[4], $column[5], $column[6], $column[7], $column[8]));
                $column_datatype_map[$column[1] . '_' . $column[3]] = $column[5];
                $default_param_array[$column[1]] = array();

                array_push($default_param_array[$column[1]], array($column[7], $column[8], array()));
            }

        }

        $dataset_columns_jsoned = json_encode($dataset_columns);
        $column_datatype_map_jsoned = json_encode($column_datatype_map);
        $dataset_id_collection_jsoned = json_encode($dataset_id_collection);
        $default_param_array_jsoned = json_encode($default_param_array);
        $required_column_ids_jsoned = json_encode($required_column_ids);
        
        $relation_url = "EXEC spa_rfx_report_param_operator_dhx @flag='s'";
        $report_operator = readXMLURL2($relation_url);

        function add_default_parameters($btn_name, $btn_function_call, $btn_tips, $btn_class, $show_hide) {
            global $app_php_script_loc;
            $img_path = $app_php_script_loc . "adiha_pm_html/process_controls/toolbar";
            $img_path_onclick = $app_php_script_loc . "adiha_pm_html/process_controls/toolbar_onclick";
            $img_path_onover = $app_php_script_loc . "adiha_pm_html/process_controls/toolbar_onover";
            $html_str = " <img height='18px' align='middle' id='" . $btn_name . "' 
                                style='display:" . $show_hide . "' 
                                name='" . $btn_name . "' 
                            src=" . $img_path . "/" . $btn_name . ".png 
                                onClick=" . $btn_function_call . "  
                                class='widget-btn " . $btn_class . "'  
                            onMouseOver=change_btn_image(this,'" . $img_path_onover . "/" . $btn_name . ".png') 
                            onMouseDown=change_btn_image(this,'" . $img_path_onclick . "/" . $btn_name . ".png') 
                            onmouseout=change_btn_image(this,'" . $img_path . "/" . $btn_name . ".png') 
                                alt=" . $btn_tips . "> ";
            return $html_str;
        }
        
        $form_namespace = 'rm_paramset';
        $json = "[
                    {
                        id:         'a',
                    header:     true,
                    height:     150,
                    text:       'General',
                    collapse:   true
                    },
                    {
                        id:         'b',
                    header:     true,
                    text:       'Parameter Columns'
                    }
                ]";
              
        $layout = new AdihaLayout();
        echo $layout->init_layout('layout', '', '2E', $json, $form_namespace);
        $json_report_status_opt = '
        [
            {text: "Draft"   , value: "1", selected: ' . ($report_status == 1 ? '1' : '0') . '},
            {text: "Public"  , value: "2", selected: ' . ($report_status == 2 ? '1' : '0') . '},
            {text: "Private" , value: "3", selected: ' . ($report_status == 3 ? '1' : '0') . '},
            {text: "Hidden"  , value: "4", selected: ' . ($report_status == 4 ? '1' : '0') . '},
        ]
        ';

        if ($mode == 'i') {
            $json_export_report_format_opt = '
            [
                {text: "Excel"   , value: ".xlsx", selected: 0},
                {text: "CSV"  , value: ".csv", selected: 1},
                {text: "Text" , value: ".txt", selected: 0},
                {text: "XML"  , value: ".xml", selected: 0},
            ]
            ';
            $display_header = "true";
        } else {
            $json_export_report_format_opt = '
            [
                {text: "Excel"   , value: ".xlsx", selected: ' . ($export_report_format == '.xlsx' ? '1' : '0') . '},
                {text: "CSV"  , value: ".csv", selected: ' . ($export_report_format == '.csv' ? '1' : '0') . '},
                {text: "Text" , value: ".txt", selected: ' . ($export_report_format == '.txt' ? '1' : '0') . '},
                {text: "XML"  , value: ".xml", selected: ' . ($export_report_format == '.xml' ? '1' : '0') . '},
            ]
            ';
            $display_header = ($display_header == 'y') ? "true" : "false";
        }

        $json_delimiter_opt = '
        [
            {text: "Comma"   , value: ",", selected: ' . ($delimiter == ',' ? '1' : '0') . '},
            {text: "Semi Colon"  , value: ";", selected: ' . ($delimiter == ';' ? '1' : '0') . '},
            {text: "Colon" , value: ":", selected: ' . ($delimiter == ':' ? '1' : '0') . '},
            {text: "Tab"  , value: "\t", selected: ' . ($delimiter == '\t' ? '1' : '0') . '},
            {text: "Vertical Bar(Pipe)"  , value: "|", selected: ' . ($delimiter == '|' ? '1' : '0') . '},
        ]
        ';

        $compress_file = ($compress_file == 'y') ? "true" : "false";

        $form = new AdihaForm();
        $sp_url_xml_format = "EXEC spa_staticDataValues @flag='h', @type_id=100000";
        echo "json_xml_format_opt = ".  $form->adiha_form_dropdown($sp_url_xml_format, 0, 1, false, $xml_format) . ";"."\n";

        $sp_url_category = "EXEC spa_staticDataValues @flag='h', @type_id=104700";
        echo "json_category = ".  $form->adiha_form_dropdown($sp_url_category, 0, 1, true, $category_id) . ";"."\n";
 
        $local_file_path = addslashes('(E.g. \\\\File Server\\reports)');
        //$network_file_path = addslashes('(Network File Path: E.g. \\\\File Server\\bcp\\)');

        $paramset_form_json = '
        [
            {type:"input", name: "ip_name", label:"Name", value:"' . $paramset_name . '", offsetLeft: "' . $ui_settings['offset_left'] . '",  required:true, "inputWidth":"' . $ui_settings['field_size'] . '", "position":"label-top", userdata:{validation_message:"Required Field"}}, 
            
            {type: "combo", name: "cmb_category", label: "Category", options: json_category, position: "label-top", width: "' . $ui_settings['field_size'] . '", offsetLeft:  "' . $ui_settings['offset_left'] . '"},
            {type:"newcolumn"},

            {type:"combo", name: "cmb_status", label:"Report Status", offsetLeft: "' . $ui_settings['offset_left'] . '", required:false, filtering:true, filtering_mode: "between", "inputWidth":"' . $ui_settings['field_size'] . '", "position":"label-top", "options": ' . $json_report_status_opt . '},
            {type:"newcolumn"},

            {type:"input", name: "export_report_name", value:"' . $export_report_name . '", label:"Export Report Name", offsetLeft: "' . $ui_settings['offset_left'] . '", required:false, "inputWidth":"' . $ui_settings['field_size'] . '", "position":"label-top"},
            {type:"newcolumn"},

            {type:"input", name: "export_location", value:"' . $export_location . '", label:"Export Location", offsetLeft: "' . $ui_settings['offset_left'] . '", required:false, "inputWidth":"' . $ui_settings['field_size'] . '", "position":"label-top"},
            {type: "label", labelWidth: 300, label: "' . $local_file_path . '", position: "absolute", labelTop: 42, offsetLeft: "' . $ui_settings['offset_left'] . '"},
            {type:"newcolumn"},

                {type: "combo", name: "cmb_export_report_format", label: "Export Format", options: ' . $json_export_report_format_opt . ', position: "label-top", width: "' . $ui_settings['field_size'] . '", offsetLeft:  "' . $ui_settings['offset_left'] . '"},
                {type: "newcolumn"},

                {type: "combo", name: "cmb_delimiter", label: "Delimiter", options: ' . $json_delimiter_opt . ', position: "label-top", width: "' . $ui_settings['field_size'] . '", offsetLeft:  "' . $ui_settings['offset_left'] . '"},
                {type: "newcolumn"},

                {type: "combo", name: "cmb_xml_format", label: "XML Format", options: json_xml_format_opt, position: "label-top", width: "' . $ui_settings['field_size'] . '", offsetLeft:  "' . $ui_settings['offset_left'] . '"},
                {type: "newcolumn"},

                {type: "checkbox", name: "chk_display_header", label: "Display Header", position: "label-right",  checked: "' . $display_header . '", inputWidth: "' . $ui_settings['field_size'] . '", labelWidth: 120, "offsetLeft": 20, "offsetTop" : 26},
                {type: "newcolumn"},

                {type: "checkbox", name: "chk_compress_file", label: "Compress File", position: "label-right", checked: "' . $compress_file . '", inputWidth: "' . $ui_settings['field_size'] . '", offsetLeft: 20, label_width :180, offsetTop : 26}
                


        ]
        ';

        $form_name = 'form_paramset';
        echo $form->init_by_attach($form_name, $form_namespace);
        echo $layout->attach_form($form_name, 'a');
        echo $form->load_form($paramset_form_json);

    $toolbar_receipt_json = '[
                                    {id: "select_all", text:"", img: "select_all.png", title:""},
                                    {id: "add_parameter", text:"", img: "add.gif", title:""},
                                    {id: "rearrange", text:"", img: "reclassify.gif", title:""},
                                    {id: "optional_all", text:"", img: "optional_all.png", title:""},
                                    {id: "hidden_all", text:"", img: "hidden_all.png", title:""},
                                    {id: "delete_parameter", text:"", img: "delete.gif", title:""}
                                    
                             ]';
    $toolbar_receipt_obj = new AdihaMenu();
    echo $toolbar_receipt_obj->attach_menu_layout_header($form_namespace, 'layout', 'b', 'toolbar_param_column', $toolbar_receipt_json, 'rm_paramset.fx_click_toolbar');
    
        // attach menu
    // $menu_json = '[{id: "save", img:"save.gif", img_disabled:"save.gif", text:"Save", title:"Save"}]';
    // $menu_obj = new AdihaMenu();
    // echo $layout->attach_menu_cell("paramset_menu", "a");  
    // echo $menu_obj->init_by_attach("paramset_menu", $form_namespace);
    // echo $menu_obj->load_menu($menu_json);
    // echo $menu_obj->attach_event('', 'onClick', $form_namespace . '.menu_click');   

        echo "
        rm_paramset.toolbar_param_column.setTooltip('add_parameter', 'Add New');
        rm_paramset.toolbar_param_column.setTooltip('delete_parameter', 'Delete');
        rm_paramset.toolbar_param_column.setTooltip('rearrange', 'Rearrange');
        rm_paramset.toolbar_param_column.setTooltip('select_all', 'Select All');
        rm_paramset.toolbar_param_column.setTooltip('optional_all', 'Optional All');
        rm_paramset.toolbar_param_column.setTooltip('hidden_all', 'Hide All');

            var export_report_format_obj = rm_paramset.form_paramset.getCombo('cmb_export_report_format');

            var export_report_format_value = rm_paramset.form_paramset.getItemValue('cmb_export_report_format');
            if (export_report_format_value == '.xlsx') {
                rm_paramset.form_paramset.hideItem('cmb_delimiter');
                rm_paramset.form_paramset.hideItem('cmb_xml_format');
                rm_paramset.form_paramset.hideItem('chk_display_header');
            } else if (export_report_format_value == '.xml') {
                rm_paramset.form_paramset.hideItem('cmb_delimiter');
                rm_paramset.form_paramset.showItem('cmb_xml_format');
                rm_paramset.form_paramset.hideItem('chk_display_header');
            } else {            
                rm_paramset.form_paramset.hideItem('cmb_xml_format');
                rm_paramset.form_paramset.showItem('cmb_delimiter');
                rm_paramset.form_paramset.showItem('chk_display_header');
            }

            export_report_format_obj.attachEvent('onChange', function() {
                var export_report_format_value = rm_paramset.form_paramset.getItemValue('cmb_export_report_format');
                if (export_report_format_value == '.xlsx') {
                    rm_paramset.form_paramset.hideItem('cmb_delimiter');
                    rm_paramset.form_paramset.hideItem('cmb_xml_format');
                    rm_paramset.form_paramset.hideItem('chk_display_header');
                } else if (export_report_format_value == '.xml') {
                    rm_paramset.form_paramset.hideItem('cmb_delimiter');
                    rm_paramset.form_paramset.showItem('cmb_xml_format');
                    rm_paramset.form_paramset.hideItem('chk_display_header');
                } else {            
                    rm_paramset.form_paramset.hideItem('cmb_xml_format');
                    rm_paramset.form_paramset.showItem('cmb_delimiter');
                    rm_paramset.form_paramset.showItem('chk_display_header');
                }
            });
             
        ";     
        
        echo $layout->close_layout();
        
        /** datasource view privilege logic **/
        $xml_file = "EXEC spa_rfx_report_record_dhx @flag=a, @process_id='$process_id', @report_paramset_id='$report_paramset_id'";
        $paramsets = readXMLURL2($xml_file);
        //data_source_type
        $datasource_id = $paramsets[0]['source_id'] ?? 0;
        
        
        /** taking datasource UI form application ID and sending it making -ve to spa_getportfoliohierarchy, so that when
         * report is to be run from report manager that has the data source as sql, all portfolio structure is now displayed.
         * Previously no portfolio was displayed while trying to run report that has sql datasource from report manager with non-admin users,
         * Because the we only had a feature to give privilege to views but no sql data sources.
         * 
         * **/
        $data_source_sql_function_id = -10201625;
        $is_data_source_sql = (($paramsets[0]['data_source_type'] ?? '') == 2) ? 1 : 0; //DATA SOURCE TYPE SQL => 2
        

    //if (empty($report_table_id))
//            $function_or_view_id = $sf_report_writer;
//        else
        /* for SQL based reports, view id is not available, use function id of 'Report Writer' application function.
         * Same parameter @function_id is used to pass both Application Function ID
         * or Report Writer View ID. So to differentiate between the two, a base no.
         * of 100000000 is added in every Report Writer View ID
         */
            $function_or_view_id = $datasource_id + 100000000;
            
        /** Pass negative value (f10 datasource UI function ID) so that the handling on spa_getportfolioheierarchy
         * for this will allow to display all portfolio structure. While running report with sql data source from report manager
         * , with non-admin users, portfolio structure should be full displayed.
         * 
         */
         
        if ($is_data_source_sql == 1) {
            $function_or_view_id =  $data_source_sql_function_id;//<FUNCTION ID OF F10 Funtion SQL data source>    
        }

        $verify_img_path = $php_script_loc . "/components/lib/adiha_dhtmlx/themes/dhtmlx_" . $default_theme . "/imgs/dhxtoolbar_web/verify.gif";
        $verify_dis_img_path = $php_script_loc . "/components/lib/adiha_dhtmlx/themes/dhtmlx_" . $default_theme . "/imgs/dhxtoolbar_web/verify_dis.gif";

    ?>
    <!--<script type="text/javascript" src="<?php echo $app_php_script_loc; ?>components/ui/jquery.tab.min.js"></script>-->
    <script type="text/javascript" src="<?php echo $app_php_script_loc; ?>components/ui/jquery-ui.min.js"></script>
    <!--<script type="text/javascript" src="<?php echo $app_php_script_loc; ?>components/ui/jquery.nestedSortable.js"></script>-->
    <link rel="stylesheet" type="text/css" href="<?php echo $appBaseURL; ?>css/adiha_style.css" />
    <link type="text/css" rel="stylesheet" href="<?php echo $report_paramset_theme_css; ?>"/>
    
    <!-- load ace -->
    <script src="../../../adiha.php.scripts/components/lib/ace/ace.js"></script>
    <!-- load ace language tools -->
    <script src="../../../adiha.php.scripts/components/lib/ace/ext-language_tools.js"></script>

    <script type="text/javascript">

        var dataset_list =  <?php echo $dataset_id_collection_jsoned; ?> ;
        //console.log(dataset_list);
        var datasets_info = <?php echo json_encode($datasets); ?>;
        //console.log(datasets_info);
        var dataset_columns =  <?php echo $dataset_columns_jsoned; ?> ;
        //console.log(dataset_columns);
        var column_datatype_map =  <?php echo $column_datatype_map_jsoned; ?> ;
        var default_parm_values =  <?php echo $default_param_array_jsoned; ?> ;
        var required_column_ids =  <?php echo $required_column_ids_jsoned; ?> ;
        //console.log(required_column_ids);

        var scalar_functions_list = _.pluck(<?php echo json_encode($scalar_functions_list); ?>,'function_name');
        ace.require("ace/ext/language_tools");
        
        editor_gbl = []; 

        var as_of_date =  <?php echo json_encode($as_of_date); ?> ;
		var iu_mode = '<?php echo $mode; ?>';

        var report_operator_arr = <?php echo json_encode($report_operator);?>;
        //console.log(report_operator_arr)

        var portfolio_map = Array();
        portfolio_map['BSTREE-Subsidiary'] = 1;
        portfolio_map['BSTREE-Strategy'] = 2;
        portfolio_map['BSTREE-Book'] = 3;
		portfolio_map['BSTREE-SubBook'] = 8;
        
        var param = {
            process_id: '<?php echo $process_id; ?>',
            report_id: '<?php echo $report_id; ?>',
            page_id: '<?php echo $page_id; ?>',
            mode: '<?php echo $mode; ?>',
            report_paramset_id: '<?php echo $report_paramset_id; ?>'
        }

        function init() {
            //hideHourGlass();
            php_path = '<?php echo $php_script_loc; ?>';
        }
        
        rm_paramset.fx_click_toolbar =function(id) {
                var active_tab_id = tabbar_obj.getActiveTab();
            
            //console.log(active_tab_obj);
            switch(id) {
                case 'add_parameter':
                    rm_paramset.fx_add_parameter(active_tab_id);
                    break;
                case 'delete_parameter':
                    rm_paramset.fx_delete_parameter(active_tab_id);
                    break;
                case 'rearrange':
                    rm_paramset.fx_rearrange_parameter(active_tab_id);
                    break;
                case 'select_all':
                    rm_paramset.fx_select_all(active_tab_id);
                    break;
                case 'optional_all':
                    rm_paramset.fx_optional_all(active_tab_id);
                    break;
                case 'hidden_all':
                    rm_paramset.fx_hidden_all(active_tab_id);
                    break;
                
            }
        }



        //init toolbar on window level for top location
        rm_paramset.fx_init_toolbars = function() {
            parent.dhx_wins.window('window_rp').attachToolbar({
                icons_path: js_image_path + 'dhxtoolbar_web/',
                items: [
                    {id: "save", type: "button", text: "Save", img: "save.gif", 
                        img_disabled: "save_dis.gif"}
                ],
                onClick: function(id) {
                    rm_paramset.menu_click(id);
                }
            });
        }
        
        rm_paramset.menu_click = function(id) {
            var form_obj = rm_paramset.form_paramset;
            var paramset_name = form_obj.getItemValue('ip_name');
            var report_status = form_obj.getItemValue('cmb_status');
            var return_obj = fx_build_paramset_xml();

            var export_report_name = form_obj.getItemValue('export_report_name');
            var export_location = form_obj.getItemValue('export_location');
            var output_file_format = form_obj.getItemValue('cmb_export_report_format');
            var delimiter = form_obj.getItemValue('cmb_delimiter');
            var xml_format = form_obj.getItemValue('cmb_xml_format');
            var category_id = form_obj.getItemValue('cmb_category');
            var report_header = form_obj.isItemChecked('chk_display_header');
            report_header = (report_header == true) ? "y" : "n";

            var compress_file = form_obj.isItemChecked('chk_compress_file');
            compress_file = (compress_file == true) ? "y" : "n";

            var err_arr = return_obj.err_arr;

            if(err_arr.length > 0) {
                dhtmlx.message({
                    title:"Alert",
                    type:"alert",
                    text:err_arr[0]
                });
                return;
            }

            var xml_ps_columns = return_obj.xml_ps_columns;
                        
            if (!validate_form(form_obj)) {
                generate_error_message();
                return;
            };
            if(id == 'save' && validate_form(form_obj)) {
                var post_data = {
                    'action': 'spa_rfx_report_paramset_dhx',
                    'flag': param.mode,
                    'page_id': param.page_id,
                    'report_paramset_id': param.report_paramset_id,
                    'process_id': param.process_id,
                    'name': paramset_name,
                    'report_status': report_status,
                    'export_report_name': export_report_name, 
                    'export_location': export_location,
                    'output_file_format': output_file_format,
                    'delimiter': delimiter,
                    'xml_format': xml_format,
                    'report_header': report_header,
                    'compress_file': compress_file,
                    'xml': xml_ps_columns,
                    'category_id': category_id
                }
                //console.log(post_data);
                adiha_post_data('return_json', post_data, '', '', 'rm_paramset.fx_save_paramset_cb');
            }
                    
        }    
        //call back fx after paramset save
        rm_paramset.fx_save_paramset_cb = function(result) {
            var json_obj = $.parseJSON(result);
            if(json_obj[0].errorcode == 'Success') {
                success_call('Changes have been saved successfully.');

                //remove class name after save so that UNSAVED note-label is hidden
                $('.new-from-ds').removeClass('new-from-ds');
                parent.ifr_dhx.ifr_tab[param.process_id].fx_refresh_grid('grid_pm');
            } else {
                dhtmlx.message({
                    title: 'Error',
                    type: 'alert-error',
                    text: json_obj[0].message
                });
            }
        };
        
        //build paramset xml
        function fx_build_paramset_xml() {
            var xml_ps_columns = '<Root>';
            var save_it = true;
            var err_arr = [];
	
            $(datasets_info).each(function(index, obj) {
                //console.log(obj);
                var dataset_id_current = obj[0].toString();
                var current_ds_id = obj[3];
                if($.inArray(dataset_id_current, Object.keys(dataset_columns)) == -1) {
                    return;
                }
                var current_ds_object = $('#' + current_ds_id + '_Parameters');
                var current_ds_object_adv = $('#' + current_ds_id + '_Advanced');
                var adv_mode = $('.advance_check', current_ds_object_adv).is(':checked');
                
                if (!adv_mode) { //for using advance mode              
                    if (!set_where_part(current_ds_id, editor_gbl[current_ds_id])) {
                        err_arr.push(get_message('VALIDATE_COLUMN'));
                        //save_it = false;
                    }
                } 
                
		
                var paramsets = $('li.clone', current_ds_object);
                //var where_part = $('.txt-where-part', current_ds_object_adv).val();
                var where_part = editor_gbl[current_ds_id].getValue();
                //console.log(where_part);
                
                if(adv_mode && where_part == '') {
                    err_arr.push('Blank WHERE clause on advance mode.');
                }
                
                var root_element_id = $('.paramset-region', current_ds_object).attr('id');
                var advance_mode = ($('.advance_check', current_ds_object_adv).is(':checked')) ? 1 : 0; 
                var counter = 0;
                
                if (paramsets.length > 0) {
                    paramsets.each(function () {
                        //here while extracting values .eq(0) expression function is required as we have to deal with hierarchical DOM and first value found for given class is our value
                        var current_obj_instance = $(this);
                        var id = current_obj_instance.attr('id');
                        var param_order = counter++;
                        var param_expression = $('.param-title', current_obj_instance).eq(0).val();
                        var param_operator = (param_order == '1') ? '' : $('.param-relation', current_obj_instance).eq(0).val();
                        param_operator = (param_operator === undefined || param_operator === null) ? '' : param_operator;
                        // var param_depth = $('#' + id).parentsUntil('#' + root_element_id, 'ul').length;
                        var param_depth = $(this).attr('depth-level');
				
                        if (param_expression == '(new)')
                            return false;
				
                        var root_dataset_id = $('.root-datasets-id', current_ds_object).eq(0).val();
                        var column_value = $('.datasets-column', current_obj_instance).eq(0).val();

                        var label = $('.label', current_obj_instance).eq(0).val();
                        var value_array = column_value.split('_');
                        var operator_id = $('.datasets-relation', current_obj_instance).eq(0).val();

                        if (column_datatype_map[column_value] == 'DATETIME' || column_datatype_map[column_value] == 'DROPDOWN' 
                            || column_datatype_map[column_value] == 'BSTREE-Subsidiary' || column_datatype_map[column_value] == 'BSTREE-Book' 
                            || column_datatype_map[column_value] == 'BSTREE-Strategy' || column_datatype_map[column_value] == 'BSTREE-SubBook' 
                            || column_datatype_map[column_value] == 'DataBrowser' || column_datatype_map[column_value] == 'Multiselect Dropdown') {
                            var first_value = $('.first-value-index', current_obj_instance).eq(0).val();
                            var second_value = (operator_id == '8') ? $('.second-value-index', current_obj_instance).eq(0).val() : '';
                        } else {
                            var first_value = $('.first-value', current_obj_instance).eq(0).val();
                            var second_value = (operator_id == '8') ? $('.second-value', current_obj_instance).eq(0).val() : '';
                        }
				        
                        //console.log($('.param-relation', current_obj_instance).eq(0).val());
                        //alert('****: '+param_operator);
                        var optional = ($('.param-optional:checked', current_obj_instance).eq(0).val() == undefined) ? 0 : 1;
                        var hidden = ($('.param-hidden:checked', current_obj_instance).eq(0).val() == undefined) ? 0 : 1;
                        xml_ps_columns += '<PSRecordset RootDataset="' + root_dataset_id + '" Dataset="' + value_array[1] + '" Column="' + value_array[0] + '" Operator="' + operator_id + '" InitialValue="' + escapeXML(first_value) + '" InitialValue2="' + escapeXML(second_value) + '" Optional="' + optional + '" Hidden="' + hidden + '" WherePart="' + escapeXML(where_part) + '" LogicalOperator="' + param_operator + '" ParamOrder="' + param_order + '" ParamDepth="' + param_depth + '" Label="' + label + '" AdvanceMode="' + advance_mode + '" ></PSRecordset>';
                    });
                }
            });
            xml_ps_columns += '</Root>';
            var return_obj = {
                xml_ps_columns: xml_ps_columns,
                err_arr: err_arr
            }
            return return_obj;
        }            
        
        function get_message(arg) {
            switch(arg) {
                case 'VALIDATE_NAME':
                    return 'Please enter paramset Name.';
                case 'VALIDATE_COLUMN':
                    return 'Please select column on parameter.'
                case 'VALIDATE_PARAMETER_NUMBER':
                    return 'Please select one or more parameter.';
                case 'VALIDATE_DEPENDENCY':
                    return 'Dependent data exists! Please delete the dependent data first.';
                case 'INVALID_NAME':
                    return 'Invalid Name! Only letters, numbers, underscore and space are allowed.';
            }
        }
        
        function btn_close_click() {
            close_var = true;
            window.returnValue = 'Success';
            window.close();
        }

        function saved() {
            close_var = true;
            window.returnValue = 'Success';
            window.close();
        }

        function resolve_open_window_param(window_function_id) {
            switch (window_function_id) {
                case '10102600':
                    return 'windowSetupPriceCurves';
                case '10102500':
                    return 'windowSetupLocation';
                case '10103000':
                    return 'windowDefineMeterID';
                case '10191000':
                    return 'windowMaintainDefinationArg';
                case '10211299': //contract
                    return 'windowMaintainDefination';
                case '10101199': // trader
                    return 'windowMaintainDefination';
            }
        }

        function get_default_param_values(element, initial_value) {
            var context_object_current = $(element).parents('li.clone').eq(0);
            g_context_object_current = context_object_current;
            var operator_id = $('.datasets-relation', context_object_current).eq(0).val();
            var column_id = $('.datasets-column', context_object_current).eq(0).val();
            var column_label = $('.datasets-column option:selected', context_object_current).eq(0).text();
            var datasets_id =  <?php echo json_encode($datasets); ?> ;
            var process_id = '<?php echo $process_id; ?>';
            var page_id = '<?php echo $page_id; ?>';
	
            var args = (initial_value == 1) ? 'initial_value=' + $('.first-value-index', context_object_current).eq(0).val()
                                            : 'initial_value=' + $('.second-value-index', context_object_current).eq(0).val();
	
            var set_value = '';
            var set_text = '';
            var ret_var;
	
            if (column_datatype_map[column_id] == 'DROPDOWN') {
                var class_name = (initial_value == 1) ? '.first-value' : '.second-value';
                g_class_name = class_name;
                var col_id = column_id.split('_');
                var default_selected_value = $(class_name + '-index', context_object_current).val();
                var position = $('#add', context_object_current).position();
                var top_pos = position.top;
                // Disabling Add event after a Popup is appeared.
                $('#add', context_object_current).each(function(){this.style.pointerEvents = 'none'});
                
                var dropdown_value = $('.first-value-index', context_object_current).eq(0).val();
                var dropdown_form_data = [
                                    {type: "settings", position: "label-left", labelWidth: 220, inputWidth: 200, position: "label-top", offsetLeft: 20},
                                    {type: "combo", name: "dropdown_ind", label: column_label, "options":[], disabled: true},
                                    {type: "button", name: "btn_ok", value: "Ok", img: "tick.png", disabled: true}
                                ];
            
                var dropdown_popup = new dhtmlXPopup();
                var dropdown_form = dropdown_popup.attachForm(dropdown_form_data);
                dropdown_popup.show(position.left - 100, top_pos + 255, 1, 1);
                
                //Loading dropdown for Frequency in grid
                var cm_param = {
                                    "action": "spa_rfx_data_source_column_dhx",
                                    "flag": "o",
                                    "column_id": col_id[0]
                                };

                cm_param = $.param(cm_param);
                var url2 = js_dropdown_connector_url + '&' + cm_param;
                var dropdown_obj = dropdown_form.getCombo('dropdown_ind');
				//Changed logic here to get all checked values
                dropdown_obj.load(url2, function() {
                    dropdown_obj.setComboValue(dropdown_value);
                    dropdown_form.enableItem('dropdown_ind');
                    dropdown_form.enableItem('btn_ok');
                });
                
                dropdown_form.attachEvent("onButtonClick", function() {
                    var cmb_obj = dropdown_form.getCombo('dropdown_ind');
                    var val = cmb_obj.getSelectedValue();
                    var txt = cmb_obj.getComboText();

                    if (val == "") {
                        $(class_name, context_object_current).val('');
                        $(class_name + '-index', context_object_current).val('');
                        $(class_name, context_object_current).prop("disabled", true);
                    } else {
                        $(class_name, context_object_current).val(txt);
                        $(class_name + '-index', context_object_current).val(val);
                        $(class_name, context_object_current).prop("disabled", true);
                    }

                    dropdown_popup.unload();
                    // Enabling Add event after a Popup is Destroyed.
                    $('#add', context_object_current).each(function(){this.style.pointerEvents = 'auto'});
                });
            } else if (column_datatype_map[column_id] == 'Multiselect Dropdown') {
                var class_name = (initial_value == 1) ? '.first-value' : '.second-value';
                g_class_name = class_name;
                var col_id = column_id.split('_');
                var default_selected_value = $(class_name + '-index', context_object_current).val();
                var position = $('#add', context_object_current).position();
                var top_pos = position.top;
                // Disabling Add event after a Popup is appeared.
                $('#add', context_object_current).each(function(){this.style.pointerEvents = 'none'});
                
                var dropdown_value = $('.first-value-index', context_object_current).eq(0).val();
                // changed logic to make dropdown as multiselect dropdown...
                var dropdown_form_data = [
                                    {type: "settings", position: "label-left", labelWidth: 220, inputWidth: 200, position: "label-top", offsetLeft: 20},
                                    {type: "combo", label: column_label, disabled: true, name: "dropdown_ind_multi", comboType: "custom_checkbox",  "options":[]},
                                    {type: "button", value: "Ok", disabled: true, name: "btn_ok", img: "tick.png"}
                                ];
            
                var dropdown_popup = new dhtmlXPopup();
                var dropdown_form = dropdown_popup.attachForm(dropdown_form_data);
                dropdown_popup.show(position.left - 100, top_pos + 255, 1, 1);
                
                //Loading dropdown for Frequency in grid
                var cm_param = {
                                    "action": "spa_rfx_data_source_column_dhx",
                                    "flag": "o",
                                    "column_id": col_id[0]
                                };

                cm_param = $.param(cm_param);
                var url2 = js_dropdown_connector_url + '&' + cm_param;
                var dropdown_obj = dropdown_form.getCombo('dropdown_ind_multi');
                //Changed logic here to get all checked values
                dropdown_obj.load(url2, function() {
                    dropdown_form.enableItem('dropdown_ind_multi');
                    dropdown_form.enableItem('btn_ok');

                    dropdown_value = dropdown_value.split(',');
                    $.each(dropdown_value, function(id, value) {
                        var ids = dropdown_obj.getIndexByValue(value);
                        dropdown_obj.setChecked(ids, true);
                    });
                });
                
                dropdown_form.attachEvent("onButtonClick", function() {
                    var cmb_obj = dropdown_form.getCombo('dropdown_ind_multi');
                    var ind = cmb_obj.getChecked();
                    var txt = cmb_obj.getComboText();
                    /* Added logic to remove first blank value */
                    if(ind[0] == '')
                        ind = ind.slice(1);
                    /* Added logic to remove first blank value */
                    if(txt[0] == ',')
                        txt = txt.slice(1);

                    if (ind == null) {
                        $(class_name, context_object_current).val('');
                        $(class_name + '-index', context_object_current).val('');
                        $(class_name, context_object_current).prop("disabled", true);
                    } else {
                        $(class_name, context_object_current).val(txt);
                        $(class_name + '-index', context_object_current).val(ind);
                        $(class_name, context_object_current).prop("disabled", true);
                    }

                    dropdown_popup.unload();
                    // Enabling Add event after a Popup is Destroyed.
                    $('#add', context_object_current).each(function(){this.style.pointerEvents = 'auto'});
                });
            } else if (column_datatype_map[column_id] == 'DATETIME') {
                var position = $('#add', context_object_current).position();
                var top_pos = position.top;
                $('#add', context_object_current).each(function(){this.style.pointerEvents = 'none'});
                var class_name = (initial_value == 1) ? '.first-value' : '.second-value';
                g_class_name = class_name;
                
                var calendar_value = $(class_name, context_object_current).eq(0).val();
                var calendar_form_data = [
                                    {type: "settings", labelWidth: 230, inputWidth: 220, position: "label-top", offsetLeft: 15},
                                    {type: "calendar", name: "calendar", label: column_label, value: calendar_value, dateFormat: user_date_format},
                                    {type: "button", value: "Ok", img: "tick.png"}
                                ];
            
                var calendar_popup = new dhtmlXPopup();
                var calendar_form = calendar_popup.attachForm(calendar_form_data);
                calendar_popup.show(position.left - 100, top_pos + 255, 1, 1);
                
                calendar_form.attachEvent("onButtonClick", function(){
                    var calendar_obj = calendar_form.getCalendar('calendar');
                    var date = calendar_obj.getFormatedDate();
                    var sql_date = calendar_obj.getFormatedDate("%Y-%m-%d");
                    
                    if (date == null) {
                        $(class_name, context_object_current).val('');
                        $(class_name + '-index', context_object_current).val('');
                        $(class_name, context_object_current).prop("disabled", false);
                    } else {
                        $(class_name, context_object_current).val(date);
                        $(class_name + '-index', context_object_current).val(sql_date);
                        $(class_name, context_object_current).prop("disabled", false);
                    }
                    
                    calendar_popup.unload();
                    // Enabling Add event after a Popup is Destroyed.
                    $('#add', context_object_current).each(function (){this.style.pointerEvents = 'auto'});
                });
            } else if (column_datatype_map[column_id] == 'DataBrowser') {
                var class_name = (initial_value == 1) ? '.first-value' : '.second-value';
                g_class_name = class_name;
                var col_id = column_id.split('_');
                
                var browser_value = $('.first-value-index', context_object_current).eq(0).val();
                var browser_text = $('.first-value', context_object_current).eq(0).val();
                
                var browser_data = {
                    'selected_id': browser_value,
                    'selected_label': browser_text,
                }
                
                var form = '';
                var id = 'Test';
                var grid_name = default_parm_values[col_id[0]][0][0];
                var grid_label = column_label;
                var function_id = 'NULL';
                var callback_function = 'set_shipment_value';
                browse_window = new dhtmlXWindows();

                if (grid_name == 'browse_view_shipment') {
                    browser_data = {
                        read_only : true,
                        select_completed : callback_function,
                        call_from : 'actualize_schedule',
                        trans_type : 'NULL',
                        form_obj : form,
                        browse_id : id
                    }
                    var src = js_php_path + 'adiha.html.forms/_scheduling_delivery/scheduling_workbench/view.scheduling.workbench.php?form_name=' + form + '&parent_function_id=' + function_id;
                    var src = src.replace("adiha.php.scripts/", "");
                } else {
                    var src = js_php_path + 'components/lib/adiha_dhtmlx/generic.browser.php?form_name=' + form + '&browse_name=' + id + '&grid_name=' + grid_name + '&grid_label=' + grid_label + '&function_id=' + function_id + '&callback_function=' + callback_function + '&call_from=report_manager';
                }

                new_browse = browse_window.createWindow('w1', 0, 0, 500, 400);
                new_browse.setText("Browse");
                if(grid_name == 'browse_view_shipment') {
                    new_browse.maximize();
                } else {
                new_browse.centerOnScreen();
                }
                new_browse.setModal(true);
                new_browse.attachURL(src, false, browser_data);
            } else if (column_datatype_map[column_id] != 'DATETIME' && column_datatype_map[column_id] != 'DROPDOWN' && column_datatype_map[column_id] != 'TEXTBOX') {
                var class_name = (initial_value == 1) ? '.first-value' : '.second-value';
                g_class_name = class_name;
                
                var portfolio = portfolio_map[column_datatype_map[column_id]];
                var browser_value = $('.first-value-index', context_object_current).eq(0).val();
                var browser_data = {
                    'selected_id': browser_value,
                }
                var form = '';
                var id = 'Test';
                var grid_label = column_label;
                var function_id = '<?php echo $function_or_view_id; ?>';
                var callback_function = '';
                browse_window = new dhtmlXWindows();
                var src = js_php_path + 'components/lib/adiha_dhtmlx/generic.browser.php?form_name=' + form + '&browse_name=' + id + '&grid_name=book&grid_label=' + grid_label + '&function_id=' + function_id + '&callback_function=' + callback_function + '&call_from=report_manager&portfolio=' + portfolio; 
                new_browse = browse_window.createWindow('w1', 0, 0, 500, 400);
                new_browse.setText("Browse");
                new_browse.centerOnScreen();
                new_browse.setModal(true);
                new_browse.attachURL(src, false, browser_data);
            }	
        }

        function set_shipment_value(return_val) {
            set_browser_value(return_val, return_val);
        }
        
        function clear_param_values(element, initial_value) {
            var context_object_current = $(element).parents('li.clone').eq(0);
            var column_id = $('.datasets-column', context_object_current).eq(0).val();
            var class_name = (initial_value == 1) ? '.first-value' : '.second-value';
            g_context_object_current = context_object_current;
            g_class_name = class_name;
                        
            if (column_datatype_map[column_id] == 'DROPDOWN' || column_datatype_map[column_id] == 'Multiselect Dropdown') {
                $(class_name, context_object_current).val('');
                $(class_name + '-index', context_object_current).val('');
                $(class_name, context_object_current).prop("disabled", true);
            } else if (column_datatype_map[column_id] == 'DATETIME') {
                $(class_name, context_object_current).val('');
                $(class_name + '-index', context_object_current).val('');
                $(class_name, context_object_current).prop("disabled", false);
            } else if (column_datatype_map[column_id] == 'DataBrowser') {
                set_browser_value('', '');
            } else if (column_datatype_map[column_id] == 'BSTREE-Subsidiary'
                            || column_datatype_map[column_id] == 'BSTREE-Strategy' || column_datatype_map[column_id] == 'BSTREE-Book'
                            || column_datatype_map[column_id] == 'BSTREE-SubBook') {
                set_browser_tree_value('', '');
            }
        }
        
        var g_class_name ='';
        var g_context_object_current='';
        
        function set_browser_value(set_ind, set_text) {
            if (set_ind != '') {
                $(g_class_name, g_context_object_current).val(set_text);
                $(g_class_name + '-index', g_context_object_current).val(set_ind);
                $(g_class_name, g_context_object_current).prop("disabled", true);
            } else {
                $(g_class_name, g_context_object_current).val('');
                $(g_class_name + '-index', g_context_object_current).val('');
                $(g_class_name, g_context_object_current).prop("disabled", false);
            }    
        }
        
        function set_browser_tree_value(set_ind, set_text) {
            if (set_text != 'NULL') {
                $(g_class_name, g_context_object_current).val(set_text);
                $(g_class_name + '-index', g_context_object_current).val(set_ind);
                $(g_class_name, g_context_object_current).prop("disabled", true);
            } else {
                $(g_class_name, g_context_object_current).val('');
                $(g_class_name + '-index', g_context_object_current).val('');
                //$(g_class_name, g_context_object_current).prop("disabled", false);
            }
        }
        
        /* this function runs before saving.. cant do all the time*/
        function set_where_part(context_ds_id, ace_editor_instance) {
            //console.log(ace_editor_instance);
            var current_obj_parameter = $('#' + context_ds_id + '_Parameters');
            var current_obj_adv = $('#' + context_ds_id + '_Advanced');

            var parameters = Array();
            var root_element_id = $('.paramset-region', current_obj_parameter).attr('id');
            var return_empty = false;
            var counter = 0;
            var current_object, id, depth, expression, operator, selected_column;
	
	
	
            $('.paramset-region li', current_obj_parameter).each(function (index, item) {
                current_object = $(this);
                id = current_object.attr('id');
                depth = parseInt($(this).attr('depth-level'));
                expression = $('.param-title', current_object).eq(0).val();
                operator = $('.param-relation', current_object).eq(0).val();
                operator = (operator == 1) ? 'AND' : 'OR';
                
                if (!(current_object.hasClass('no-nest') && current_object.hasClass('no-append'))) {
                    selected_column = $('.datasets-column', current_object).eq(0).val();
                    if (selected_column == '_')
                        return_empty = true;
                    parameters[counter] = [depth, expression, operator];
                    counter++;
                }
                
            });
            //console.log(parameters);
            if (return_empty) {
                return false;
            }
            //start to extract where
            var count_items = parameters.length;
            var result_where = '';
            var current_depth = -1;
	
            for (var x = 0; x < count_items; x++) {
                var operator_sign = (x == 0) ? '' : parameters[x][2];
                
                if (parameters[x][0] > current_depth) {
                    result_where += '(';
                }
		
                if (parameters[x][0] < current_depth) {
                    result_where += str_repeat(')', (current_depth - parameters[x][0]));
                }
		
                result_where += ' ' + operator_sign + ' ' + parameters[x][1];
                //adjust depth now
                current_depth = parameters[x][0];
                if ((x + 1) == count_items) {
                    result_where += str_repeat(')', (current_depth + 1));
                }
            }
            result_where = result_where.toString();
            result_where = result_where.replace(/\( AND\b/gi, ' AND (');
            result_where = result_where.replace(/\( OR\b/gi, ' OR (');
            result_where = result_where.replace(/\ AND\b/gi, ' \nAND');
            result_where = result_where.replace(/\ OR\b/gi, ' \nOR');
            
            //$('.txt-where-part', current_obj_adv).val(result_where);
            ace_editor_instance.setValue(result_where);
            return true;
        }

        function str_repeat(s, n) {
            var ret = "";
            for (var i = 0; i < n; i++) {
                ret += s;
            }
            return ret;
        }

        //settle available options on dataset columns
        /*
        var all_ds_opt = '';
        rm_paramset.fx_settle_ds_options = function() {
            
            $('.data-table .datasets-column').each(function(index, obj) {
                var selected_val = obj.value;
                if(all_ds_opt.length == 0) {
                    all_ds_opt = $(obj).html().replace(' selected=""', '');
                }
                
                $(obj).html(all_ds_opt);
                $(obj).val(selected_val);

                $('.data-table .datasets-column').each(function(index1, obj1) {
                    if(selected_val != obj1.value && obj1.value.length > 0) {
                        $('[value="' + obj1.value + '"]', obj).remove();
                    }
                });
                
            });
        }
        */
        parameter_tabs_gbl = [];
        rm_paramset.fx_init_parameter_tabs = function() {
            $(datasets_info).each(function(index, obj) {
        
                var dataset_id_current = obj[0].toString();

                if($.inArray(dataset_id_current, Object.keys(dataset_columns)) > -1) {
                    tabbar_obj.addTab(obj[3],obj[1]);
                    //if(index == 0) tabbar_obj.tabs(obj[3]).setActive();
                    
                    rm_paramset.fx_init_parameter_bottom_tabs(obj[3]);

                    tabbar_obj.attachEvent("onTabClick", function (id, lastId) {
                        if(tabbar_bottom_obj[id].getActiveTab() == "advance") {
                            $('.menu_open_button').parent().hide();
                        } else {
                            $('.menu_open_button').parent().show();
                        }
                    });
                }
                
            });
            tabbar_obj.tabs(tabbar_obj.getAllTabs()[0]).setActive();
            rm_paramset.layout.cells('b').showHeader();
        }
        tabbar_bottom_obj = [];
        rm_paramset.fx_init_parameter_bottom_tabs = function(tab_id) {
            tabbar_bottom_obj[tab_id] = tabbar_obj.tabs(tab_id).attachTabbar({mode: "bottom"});
            tabbar_bottom_obj[tab_id].addTab("general","General",null,null,true);
            tabbar_bottom_obj[tab_id].addTab("advance","Advance");

            tabbar_bottom_obj[tab_id].tabs("general").attachObject(tab_id+'_Parameters');
            tabbar_bottom_obj[tab_id].tabs("advance").attachObject(tab_id+'_Advanced');

            tabbar_bottom_obj[tab_id].attachEvent("onTabClick", function (id, lastId) {
                if(id == "advance") {
                    $('.menu_open_button').parent().hide();
                } else {
                    $('.menu_open_button').parent().show();
                }
            });
        }


        $(function () {
            init();
            $('#container-param-block').css("overflow-x", "scroll"); 
            $(".sortable").sortable();

            rm_paramset.fx_init_toolbars(); 

                tabbar_obj = rm_paramset.layout.cells('b').attachTabbar();
                rm_paramset.fx_init_parameter_tabs();
            
            //create template function paramset_block
            var paramset_block = _.template($('#paramset-form-block').html());
           
            function prep_option(dataset_id) {
                if (dataset_id != undefined || dataset_id != '') {

                    //filter options
                    var already_added_col_ids = [];
                    already_added_col_ids = $('.data-table .datasets-column').map(function() {
                        if(this.value.length > 0) return parseInt(this.value.split('_')[0]);

                    }).get();
                    
                    var html_prepd = '';
			
                    _.each(dataset_columns[dataset_id], function (item) {
                        
                        if($.inArray(item[0], already_added_col_ids) == -1) {
                            html_prepd += '<option afilter="' + item[5] + '" value="' + item[0] + '_' + item[2] + '" rel="' + item[3] + '">' + item[1] + '</option>';
                        }
                        
                    });
			         //console.log(dataset_id);
                    return html_prepd;
                } else {
                    return '';
                }
            }
            
            //Onchange event when the size of layout is changed.
            rm_paramset.layout.attachEvent("onPanelResizeFinish", function(){
                set_param_block_height_width();
            });
            
            rm_paramset.layout.attachEvent("onResizeFinish", function(){
                set_param_block_height_width();
            });
            //Set the height and width of the formula editor according to size of layout cell.
            function set_param_block_height_width() {
                var height = rm_paramset.layout.cells('b').getHeight();
                var width = rm_paramset.layout.cells('b').getWidth();
                
                $('.pm_tabs').css("width", width-12);
                $('.pm_tabs').css("height", height-50);
            }
	
            function adjust_param_operator(context) {
                var current_ds_id = $(context).attr('id').split('_')[0];
                var context_par = $('#' + current_ds_id + '_Parameters');
                var context_adv = $('#' + current_ds_id + '_Advanced');
                if ($('.advance_check',context_adv).is(':checked')) {
                    $('.param-relation', context_par).hide();    
                    return;
                }
                
                $('.paramset-region .normal-sort .param-relation', context_par).show();
                $('.paramset-region .normal-sort .param-relation', context_par).val('1');
                $('.paramset-region .normal-sort .param-relation:first', context_par).hide();
                $('.paramset-region .normal-sort .param-relation:first', context_par).val('');
            }
	
            function get_where_literal(operator_id, variable, operator_sign, column_name) {
                var at_var = variable.split('.');
                var label = at_var[0] + '.[' + column_name + '] ';
		
                switch (operator_id) {
                    case '6':
                    case '7':
                        label += operator_sign;
                        break;
                    case '8':
                        label += operator_sign + ' \'@' + column_name + '\' AND \'@2_' + column_name + '\'';
                        break;
                    case '9':
                    case '10':
                        label += operator_sign + ' ( @' + column_name + ' )';
                        break;
                    default:
                        label += operator_sign + ' \'@' + column_name + '\'';
                }

                return label;
            }
	
            function set_param_widget_label(current_context_reln) {
                var variable = $('.datasets-column :selected', current_context_reln).eq(0).text();
                var column_id = $('.datasets-column', current_context_reln).eq(0).val();
                var column_name = $('.datasets-column :selected', current_context_reln).eq(0).attr('rel');
                var operator_sign = $('.datasets-relation :selected', current_context_reln).eq(0).attr('rel');
                var operator_id = $('.datasets-relation', current_context_reln).eq(0).val();
		
                if (column_id != '' && operator_id != '') {
                    var label = get_where_literal(operator_id, variable, operator_sign, column_name);
                    $('.param-title', current_context_reln).eq(0).val(label);
                }
            }
	
			if (iu_mode == 'i') { // code to set the '.param-title' for the insert mode for required parameters
				_.each(dataset_list, function (current_ds) {
					var current_ds_object = $('#' + current_ds + '_Parameters');
					$('.datasets-relation', current_ds_object).each(function () {
							var current_context_reln = $(this).parents('li.clone').eq(0);
							set_param_widget_label(current_context_reln);
					});
				});
			}			
	
		

            /*Function for retriving the default selecte combo label */
            function get_default_dropdown_value(default_label_group, default_value, current_column) {
                if (default_value == '' || default_value == 'NULL') {
                    return
                }

                var drop_down_options = default_parm_values[current_column][0][2].length;
                    
                for (var i = 0; i < drop_down_options; i++) {
                    var array_value = default_parm_values[current_column][0][2][i][0];
			
                    if (array_value == default_value) {
                        return default_parm_values[current_column][0][2][i][1];
                    }
                }		
            }

            <?php
            if ($mode == 'u') {
                #if update mode - START 
                ?>
                $(datasets_info).each(function (index, obj) {
                    var dataset_id_current = obj[0].toString();
                    var current_ds_id = obj[3];
                    
                    if($.inArray(dataset_id_current, Object.keys(dataset_columns)) == -1) {
                        return;
                    }
                    var current_ds_object = $('#' + current_ds_id + '_Parameters');
                    //factory script relations
                    $('.first-value', current_ds_object).change(function () {
                        var context_current = $(this);
                        context_current.next('.first-value-index').val(context_current.val());
                    });

                    $('.second-value', current_ds_object).change(function () {
                        var context_current = $(this);
                        context_current.next('.second-value-index').val(context_current.val());
                    });
                                                                                                    
                    $('.datasets-relation', current_ds_object).change(function () {
                        var current_value = $(this).val();
                        var current_context_reln = $(this).parents('li.clone').eq(0);
                        set_param_widget_label(current_context_reln);
				
                        if (current_value == '8') {
                            $('.between', current_context_reln).eq(0).show();
                        } else {
                            $(this).parents('li.clone').eq(0).find('.between').hide();
                        }
				
                        if (current_value == '6' || current_value == '7') {
                            $('.param-optional', current_context_reln).eq(0).prop("checked", false);
                            $('.param-hidden', current_context_reln).eq(0).prop("checked", true);
                            $('.param-optional', current_context_reln).eq(0).attr("disabled", true);
                            $('.param-hidden', current_context_reln).eq(0).attr("disabled", true);
                            //$('.first-value', current_context_reln).eq(0).attr("disabled", true);
                            //$('.second-value', current_context_reln).eq(0).attr("disabled", true);
                        } else {
                            if(current_context_reln.attr('required_filter') == 1) {
                                $('.required-filter', current_context_reln).eq(0).attr("disabled", false);    
                            }
                            
                            $('.param-hidden', current_context_reln).eq(0).attr("disabled", false);
                        }
                    });
                    
                    $('.datasets-column', current_ds_object).change(function () {
                        var text_val = $(this).val();
                        var current_context_reln = $(this).parents('li.clone').eq(0);
                        set_param_widget_label(current_context_reln);
                        var column_id = text_val.split('_');
                        var current_column = column_id[0];
				
                        /*changing the value of the value(s) text box during update)*/
                        if (column_datatype_map[text_val] == 'DROPDOWN' || column_datatype_map[text_val] == 'Multiselect Dropdown') {
                            var default_value = default_parm_values[current_column][0][1];
                            var default_label_group = default_parm_values[current_column][0][0];
                            var default_label = get_default_dropdown_value(default_label_group, default_value, current_column);
                            $('.first-value:last', current_context_reln).eq(0).val(default_label);
                            $('.first-value-index:last', current_context_reln).eq(0).val(default_value);
                        } else {
                             
                            var set_default_parameter = default_parm_values[current_column][0][1];
                            $('.first-value:last', current_context_reln).eq(0).val(set_default_parameter);
                            $('.first-value-index:last', current_context_reln).eq(0).val(set_default_parameter);
                        }
				
                        /*manage init btn*/
                        if (column_datatype_map[text_val] == 'DATETIME'
                            || column_datatype_map[text_val] == 'BSTREE-Subsidiary'
                            || column_datatype_map[text_val] == 'BSTREE-Strategy'
                            || column_datatype_map[text_val] == 'BSTREE-Book'
							|| column_datatype_map[text_val] == 'BSTREE-SubBook'
                            || column_datatype_map[text_val] == 'DROPDOWN'
                            || column_datatype_map[text_val] == 'DataBrowser' || column_datatype_map[text_val] == 'Multiselect Dropdown') {
                            $('.init-value-window-1', current_context_reln).eq(0).show();
                            $('.init-value-window-2', current_context_reln).eq(0).show();
                            $('.init-value-window-1', current_context_reln).eq(1).show();
                            $('.init-value-window-2', current_context_reln).eq(1).show();
                            
                            if (column_datatype_map[text_val] != 'DATETIME' || column_datatype_map[text_val] != 'DROPDOWN' || column_datatype_map[text_val] != 'Multiselect Dropdown') {
                                $('.datasets-relation', current_context_reln).eq(0).val('9');
                                set_param_widget_label(current_context_reln);
                            }
                            
                            //$('.first-value:last', current_context_reln).eq(0).attr("disabled", true);
                        } else {
                            $('.init-value-window-1', current_context_reln).eq(0).hide();
                            $('.init-value-window-2', current_context_reln).eq(0).hide();
                            $('.init-value-window-1', current_context_reln).eq(1).hide();
                            $('.init-value-window-2', current_context_reln).eq(1).hide();
                            $('.first-value:last', current_context_reln).eq(0).attr("disabled", false);
                        }
                    });
                    adjust_param_operator(current_ds_object);
                    });
                $('.datasets-relation').trigger('change');
        <?php }#if update mode - END                     ?>
        
        //function to fire events when user checks/unchecks hidden checkbox.
        rm_paramset.fx_hidden_check = function(obj) {
            var default_value = $('.first-value-index', $(obj).closest('.data-table')).val();
            var required_filter = $(obj).closest('li').attr('required_filter');

            if(obj.checked && (default_value == '' || default_value == undefined) && required_filter == 1) {
                
                dhtmlx.message({
                    title: "Alert",
                    type: "alert",
                    text: 'Please set default value to hide required column.',
                });
                obj.checked = false;
            }
        };
		
        rm_paramset.fx_add_parameter = function(active_tab_id) {
            //console.log(active_tab_obj);
            var current_ds_object = $('#'+active_tab_id+'_Parameters');
            
            var dataset_id = $('.root-datasets-id', current_ds_object).val();
            
            // console.log(dataset_id);
            var all_col_ids = [];
            all_col_ids = $(dataset_columns[dataset_id]).map(function() {
                return (this[0] + '_' + this[2]);
		
            }).get();
            //console.log(all_col_ids);
			
	
            var already_added_col_ids = [];
            already_added_col_ids = $('.data-table .datasets-column', current_ds_object).map(function() {
                if(this.value.length > 0 ) return this.value;
                                                                                                    
            }).get();
            //console.log(already_added_col_ids);
            
            //alert when all available columns are already used
            if(all_col_ids.length == already_added_col_ids.length) {
                dhtmlx.message({
                    title:"Alert",
                    type:"alert",
                    text:'All available columns used.'
                    });
                return;
            }
                                                                                                    

            var odd_even_color = 'even_color';
            if ($('.paramset-region li:last-child',current_ds_object).hasClass('even_color')) {
               odd_even_color = 'odd_color';
            }
            var new_item_id = _.uniqueId('new-param-');
            $('.paramset-region', current_ds_object).append(paramset_block({
                new_id : new_item_id,
                odd_even_color : odd_even_color
            }));
            //show two text box incase we have "between" selected in relations
            $('.paramset-region .datasets-relation:last', current_ds_object).change(function () {
                        var current_value = $(this).val();
                        var current_context_reln = $(this).parents('li.clone').eq(0);
                        set_param_widget_label(current_context_reln);
                                                                                                        
                        if (current_value == '8') {
                    //$(this).parents('li.clone').eq(0).find('.between').parent().find('span').eq(0).text('Value(s) [From - To]');
                            $('.between', current_context_reln).eq(0).show();
                        } else {
                    //$(this).parents('li.clone').eq(0).find('.between').parent().find('span').eq(0).text('Value(s)');
                    $('.between', current_context_reln).eq(0).hide();
                        }
                                                                                                        
                        if (current_value == '6' || current_value == '7') {
                            $('.param-optional', current_context_reln).eq(0).prop("checked", false);
                            $('.param-hidden', current_context_reln).eq(0).prop("checked", true);
                            $('.param-optional', current_context_reln).eq(0).attr("disabled", true);
                            $('.param-hidden', current_context_reln).eq(0).attr("disabled", true);
                            //$('.first-value', current_context_reln).eq(0).attr("disabled", true);
                            //$('.second-value', current_context_reln).eq(0).attr("disabled", true);
                        } else {
                    $('.param-optional', current_context_reln).eq(0).attr("disabled", false);
                            $('.param-hidden', current_context_reln).eq(0).attr("disabled", false);
                    $('.first-value', current_context_reln).eq(0).attr("disabled", false);
                    $('.second-value', current_context_reln).eq(0).attr("disabled", false);
                        }
                    });
            //related combo logic
                                                                                                                			
            $('.datasets-column:last', current_ds_object).html(prep_option(dataset_id));
            
            $('.datasets-column:last', current_ds_object).change(function () {
                        var text_val = $(this).val();
                        var current_context_reln = $(this).parents('li.clone').eq(0);
                        set_param_widget_label(current_context_reln);
                var dataset_id = $('.root-datasets-id', current_ds_object).val();
                        var column_id = text_val.split('_');
                        var current_column = column_id[0];
                                                                                                                				
                /*changing the value of the value(s) text box during new parameter insert)*/
                        if (column_datatype_map[text_val] == 'DROPDOWN' || column_datatype_map[text_val] == 'Multiselect Dropdown') {
                            var default_value = default_parm_values[current_column][0][1];
                            var default_label_group = default_parm_values[current_column][0][0];
                            var default_label = get_default_dropdown_value(default_label_group, default_value, current_column);
            
                            $('.first-value:last', current_context_reln).eq(0).val(default_label);
                            $('.first-value-index:last', current_context_reln).eq(0).val(default_value);
                        } else {
                            var set_default_parameter = default_parm_values[current_column][0][1];
                            $('.first-value:last', current_context_reln).eq(0).val(set_default_parameter);
                            $('.first-value-index:last', current_context_reln).eq(0).val(set_default_parameter);
                        }
                                                                                                                				
                        /*manage init btn*/
                if (column_datatype_map[text_val] == 'DATETIME' || column_datatype_map[text_val] == 'BSTREE-Subsidiary'
                    || column_datatype_map[text_val] == 'BSTREE-Strategy' || column_datatype_map[text_val] == 'BSTREE-Book'
                    || column_datatype_map[text_val] == 'BSTREE-SubBook' || column_datatype_map[text_val] == 'DROPDOWN'
                            || column_datatype_map[text_val] == 'Multiselect Dropdown'
                            || column_datatype_map[text_val] == 'DataBrowser') {
                            $('.init-value-window-1', current_context_reln).eq(0).show();
                            $('.init-value-window-2', current_context_reln).eq(0).show();
                            $('.init-value-window-1', current_context_reln).eq(1).show();
                            $('.init-value-window-2', current_context_reln).eq(1).show();
                    
                    if (column_datatype_map[text_val] != 'DATETIME' || column_datatype_map[text_val] != 'DROPDOWN') {
                        $('.datasets-relation', current_context_reln).eq(0).val('9');
                        set_param_widget_label(current_context_reln);
                    }
                    
                            //$('.first-value:last', current_context_reln).eq(0).attr("disabled", true);
                        } else {
                            $('.init-value-window-1', current_context_reln).eq(0).hide();
                            $('.init-value-window-2', current_context_reln).eq(0).hide();
                            $('.init-value-window-1', current_context_reln).eq(1).hide();
                            $('.init-value-window-2', current_context_reln).eq(1).hide();
                            $('.first-value:last', current_context_reln).eq(0).attr("disabled", false);
                        }
                    });
    
                    adjust_param_operator(current_ds_object);
            //create event for new item to copy value to index
            $('.first-value:last', current_ds_object).change(function () {
                var context_current = $(this);
                context_current.next('.first-value-index').val(context_current.val());
                });
            $('.second-value:last', current_ds_object).change(function () {
                var context_current = $(this);
                context_current.next('.second-value-index').val(context_current.val());
        });
        
            //$("#" + new_item_id)[0].scrollIntoView({ behavior: 'smooth', block: 'end', inline: 'nearest' });
            var objParamBlockDiv = document.getElementById("container-param-block");
            objParamBlockDiv.scrollTop = objParamBlockDiv.scrollHeight;
            $('.datasets-column:last', current_ds_object).trigger('change');
        }
            
        rm_paramset.fx_delete_parameter = function(active_tab_id) {
            var current_ds_object = $('#'+active_tab_id+'_Parameters');
            var selected_params_2del = $('.remove-param:checked', current_ds_object).length;
                
            if (selected_params_2del == 0) {
                adiha_CreateMessageBox('alert', get_message('VALIDATE_PARAMETER_NUMBER'));
                return false;
            }
        
            $('li.clone', current_ds_object).each(function () {
                var current_object = $(this);

                if ($('.remove-param', current_object).eq(0).is(':checked')) {
                    //if (current_object.find('li.clone').length > 0) {
                    if (current_object.next().attr('depth-level') > 0) {
                        dhtmlx.alert({
                            title:"Alert",
                            type:"alert",
                            text: get_message('VALIDATE_DEPENDENCY')
                        });
                        //alert(get_message('VALIDATE_DEPENDENCY'));
                        return false;
            } else {
                        current_object.remove();
                    }
                }
                
            });
            }
        var gbl_state = {
            select_all: true,
            optional_all: true,
            hidden_all: true
        };
        rm_paramset.fx_select_all = function (active_tab_id) {
            var current_ds_object = $('#'+active_tab_id+'_Parameters');
            $('.remove-param', current_ds_object).each(function( index ) {
                if(!$(this).is(':disabled')){ 
                    $(this).prop( "checked", gbl_state.select_all);
                }
            });
            gbl_state.select_all = !gbl_state.select_all;
        }
        rm_paramset.fx_optional_all = function (active_tab_id) {
            var current_ds_object = $('#'+active_tab_id+'_Parameters');
            $('.param-optional', current_ds_object).each(function( index ) {
                if(!$(this).is(':disabled')){ 
                    $(this).prop( "checked", gbl_state.optional_all);
                }
            });
            gbl_state.optional_all = !gbl_state.optional_all;
        }
        rm_paramset.fx_hidden_all = function (active_tab_id) {
            var current_ds_object = $('#'+active_tab_id+'_Parameters');
            $('.param-hidden', current_ds_object).each(function( index ) {
                if(!$(this).is(':disabled')){ 
                    $(this).prop( "checked", gbl_state.hidden_all);
                }
    });
            gbl_state.hidden_all = !gbl_state.hidden_all;
        }
    
        rm_paramset.fx_rearrange_parameter = function (active_tab_id) {      
            var current_ds_object = $('#'+active_tab_id+'_Parameters');
            dhxWinParamset = new dhtmlXWindows();
            win_rearrange = dhxWinParamset.createWindow('win_rearrange', 0, 0, 450, 450);
            win_rearrange.setText("Rearrange Columns");
            win_rearrange.setModal(true);
            win_rearrange.maximize(); // Maximize is done to avoid filters being hidden due to mismatched height for different devices. Maximizing window will auto adjust height and then set Dimension will adjust its width only.
            win_rearrange.setDimension(450);
            win_rearrange.centerOnScreen();
            var pm_toolbar_obj = parent.dhx_wins.window('window_rp').getAttachedToolbar();
            pm_toolbar_obj.disableItem('save');
            win_rearrange.attachEvent('onClose', function() {
                pm_toolbar_obj.enableItem('save');
                win_rearrange.detachObject();
                return true;
            });
            win_rearrange.attachToolbar({
                icons_path: js_image_path + 'dhxtoolbar_web/',
                items: [
                    {id: "save", type: "button", text: "Ok", img: "tick.gif", 
                        img_disabled: "tick_dis.gif"},
                    {id: "help", type: "button", text: "Help", img: "help.gif", 
                        img_disabled: "help_dis.gif"}
                ],
                onClick: function(id) {
                    switch (id) {
                        case 'save':
                    rm_paramset.fx_save_rearrange(current_ds_object, dhxParamsetTree);
                            break;
                        case 'help':
                            help_popup.show();
                            break;
                }
                }
            });

            var help_popup = new dhtmlXPopup({ 
                toolbar: win_rearrange.getAttachedToolbar(),
                id: "help",
                mode: "right"
            });
            help_content = '<ul><li><a>Use this form to re-arrange or group/ungroup filters.</a></li><li><a>Group/Ungroup filters by dropping an item over the other.</a></li><li><a>Rearrange filters by dropping an item underneath a placement line.</a></li><li><a>View level filters are grayed out as grouping is not supported.</a></li><li><a>Grouping level is supported up to fifth level.</a></li></ul>';
            help_popup.attachHTML(help_content);
            help_popup.hide();

            help_popup.attachEvent("onBeforeHide", function(type, ev, id){
                if (type == 'click') {
                    help_popup.hide();
                }
            });

            // Intialize dhtmlx tree
            dhxParamsetTree = win_rearrange.attachTree(0);
            dhxParamsetTree.setImagePath(js_image_path + 'dhxtree_web/');
            dhxParamsetTree.setStdImages('filter_open.png', 'filter_open.png', 'filter_open.png');
            dhxParamsetTree.enableTreeLines(true);            
            dhxParamsetTree.enableDragAndDrop(true);
            dhxParamsetTree.setDragBehavior('complex');

            // Change tree node style for certain items
            dhxParamsetTree.attachEvent("onXLE", function() {
                var tree_node = dhxParamsetTree.getAllSubItems(0).split(',');
                tree_node.forEach(function(node, index) {
                    src_is_required = $(".paramset-region .clone", current_ds_object).filter('#' + node).attr('required_filter') >= 0;
                    if (src_is_required) {
                        dhxParamsetTree.setItemStyle(node,"color:#808080;");
                    }
                });
            });
            
            // Build and load XML 
            rm_paramset.fx_build_and_load_paramset_xml(current_ds_object, dhxParamsetTree, win_rearrange);
        }

        rm_paramset.fx_save_rearrange = function (current_ds_object) {
            // console.log($('.sortable').html());
            var tree_node = dhxParamsetTree.getAllSubItems(0).split(',');
            tree_node.forEach(function(node, index) {
                $(".paramset-region .clone", current_ds_object).filter('#' + node).attr('data-sort-id', index);
                $(".paramset-region .clone", current_ds_object).filter('#' + node).attr('depth-level', dhxParamsetTree.getLevel(node) - 1);

                // Remove background color
                class_list = $(".paramset-region .clone", current_ds_object).filter('#' + node).attr('class').split(/\s+/);
                class_list.forEach(function(name){
                    if (/color$/g.test(name)) {
                        $(".paramset-region .clone", current_ds_object).filter('#' + node).removeClass(name);
                    }
            });

                // Add new background color
                if (index % 2 == 0) {
                    $(".paramset-region .clone", current_ds_object).filter('#' + node).addClass('even_color');
                } else {
                    $(".paramset-region .clone", current_ds_object).filter('#' + node).addClass('odd_color');
                }

                // Remove nesting depth for paramset
                $(".depth-info-level", $(".paramset-region .clone", current_ds_object).filter('#' + node)).removeClass('nesting_level0' + (dhxParamsetTree.getLevel(node) - 1));
                class_list = $(".depth-info-level", $(".paramset-region .clone", current_ds_object).filter('#' + node)).attr('class').split(/\s+/);
                class_list.forEach(function(name){
                    if (/^nesting_level/g.test(name)) {
                        $(".depth-info-level", $(".paramset-region .clone", current_ds_object).filter('#' + node)).removeClass(name);
                    }
            });

                // Change nesting depth for paramset
                if ((dhxParamsetTree.getLevel(node) - 1) > 0) {
                    $(".depth-info-level", $(".paramset-region .clone", current_ds_object).filter('#' + node)).addClass('nesting_level0' + (dhxParamsetTree.getLevel(node) - 1));
                }

                // Remove nesting width for paramset
                $(".depth-info-width", $(".depth-info-level", $(".paramset-region .clone", current_ds_object).filter('#' + node))).removeClass('nesting_width0' + (dhxParamsetTree.getLevel(node) - 1));
                class_list = $(".depth-info-width", $(".depth-info-level", $(".paramset-region .clone", current_ds_object).filter('#' + node))).attr('class').split(/\s+/);
                class_list.forEach(function(name){
                    if (/^nesting_width/g.test(name)) {
                        $(".depth-info-width", $(".depth-info-level", $(".paramset-region .clone", current_ds_object).filter('#' + node))).removeClass(name);
                    }
                });

                // Change nesting width for paramset
                if ((dhxParamsetTree.getLevel(node) - 1) > 0) {
                    $(".depth-info-width", $(".depth-info-level", $(".paramset-region .clone", current_ds_object).filter('#' + node))).addClass('nesting_width0' + (dhxParamsetTree.getLevel(node) - 1));
                }

            });

            $(".backdrop").fadeOut(200);

            // $('.clist div').sort(function(a,b) {
            //      return a.dataset.sid > b.dataset.sid;
            // }).appendTo('.clist');

            var param_array = $(".paramset-region .clone ", current_ds_object);

            $('.sortable').empty();
            param_array.sort(function (a, b) {
                // convert to integers from strings
                a = parseInt($(a).attr("data-sort-id"), 10);
                b = parseInt($(b).attr("data-sort-id"), 10);
                //return a-b;
                // compare
                if(a > b) {
                    return 1;
                } else if(a < b) {
                    return -1;
                } else {
                    return 0;
        }
            });


           $(".paramset-region", current_ds_object).append(param_array); 
           adjust_param_operator(current_ds_object);

           win_rearrange.close();
           
        }
        
        rm_paramset.fx_build_and_load_paramset_xml = function (current_ds_object, dhxParamsetTree) {
            var tree_xml = '<\?xml version="1.0" encoding="UTF-8"?><tree id=\'0\'>';

            $('.datasets-column', current_ds_object).each(function(index) {
                var current_name = $(this).closest('.clone').attr('id');
                var current_text = ($(this).children("option:selected").text() == ''?  'New' : $(this).children("option:selected").text());
                var current_level = $(this).closest('.clone').attr('depth-level') == 'undefined' ? 0 : $(this).closest('.clone').attr('depth-level');
                var previous_level = $(this).closest('.clone').prev().attr('depth-level');
                var next_level = $(this).closest('.clone').next().attr('depth-level');

                for (i = 0; i < previous_level - current_level; i++) {
                    tree_xml += '</item>';
                }

                tree_xml += '<item id=\'' + current_name + '\' text=\'' + current_text + '\'>';

                if (next_level <= current_level) {
                    tree_xml += '</item>';
                } else if (typeof next_level === 'undefined') {
                    for (i = 0; i <= current_level; i++) {
                        tree_xml += '</item>';
                    }
                }
            });
            tree_xml += '</tree>';

            // Load XML
            dhxParamsetTree.parse(tree_xml);
            dhxParamsetTree.openAllItems(0);

            // Attach Drag Events to restrict moving items from one position to another
            dhxParamsetTree.attachEvent("onDrag", function(sId, tId, id, sObject, tObject) {
                src_is_required = $(".paramset-region .clone", current_ds_object).filter('#' + sId).attr('required_filter') >= 0;
                tar_is_required = $(".paramset-region .clone", current_ds_object).filter('#' + tId).attr('required_filter') >= 0;
                source_level = dhxParamsetTree.getLevel(sId);
                target_level = dhxParamsetTree.getLevel(tId);
                sibling_level = dhxParamsetTree.getLevel(id);
                source_has_child = dhxParamsetTree.hasChildren(sId) > 0 ? 1 : 0;

                // Allow drag when source is required and being dragged to root level
                if (src_is_required && sibling_level == 0 && target_level == 0 ) {
                    return true;
                } else if ((src_is_required && sibling_level != source_level) || (src_is_required && target_level >= 1) || ((!src_is_required) && tar_is_required) || target_level > 5 || source_has_child && target_level >= 5) {
                    // Disallow drag when source is required and being dragged inside another filter
                    // OR when source is not required and being dragged inside a required filter
                    // OR when tree depth is trying to exceed level 5
                    // OR when source has child and is being dragged to level 5
                    
                    if (target_level >= 5) {
                        msg = 'Filter can be nested upto 5 levels only.';
                    } else {
                        msg = 'View level filter cannot be nested with another filter.'
                    }

                    dhtmlx.alert({
                        title:"Alert",
                        type:"alert",
                        text: msg
                    });
                    return false;
                } else {
                    return true;
        }
            });
        }
        rm_paramset.layout.cells('a').expand();
    });
    </script>

    <div id="paramset-form-block" type="text/template">
   
        <li class="clone new-from-ds normal-sort <%=odd_even_color%>" id="<%=new_id%>" required_filter="-1" depth-level="0"  >
            <div class="depth-info-level">
                <table class="data-table" style="width: 100%; ">
                    <tr valign="top">

                        <td width="80">
                            <div class="push-up check_operator">
                                <input type="checkbox" value="1" class="remove-param" alt="Mark to Delete Parameter" title="Mark to Delete Parameter" />
                                <select class="param-relation adiha_control ctrlbox" >
                                    <option value="1" selected="1">AND</option>
                                    <option value="2">OR</option>
                                </select>
                            </div>
                            <input type="hidden" class="param-title" value=""/>
                        </td>
                        <td width="320" class="depth-info-width">  
                            <select class="adiha_control datasets-column depth-info-width" onchange="" >
                            </select>
                        </td>
                        <td width="160">
                            <select class="adiha_control datasets-relation" style="width: 140px; margin-left: 10px;">
                                <?php foreach ($report_operator as $data): ?>
                                    <option rel="<?php echo $data['sql_code']; ?>" value="<?php echo $data['report_param_operator_id']; ?>"><?php echo $data['description']; ?></option>
                                <?php endforeach; ?>
                            </select>
                        </td>

                        <td width="180" class="adiha_label">                           
                            <input type="text" class="adiha_control label" />
                        </td>

                        <td width="240" valign="top">
                        <div class="not-saved-msg note-label unsaved_img" title="Unsaved Parameter" >&nbsp;</div> 
                            
                            <input type="text" class="adiha_control first-value" />
                            <input type="hidden" class="first-value-index" />  
                            <?php echo add_default_parameters('add', 'get_default_param_values(this,1);', '', 'init-value-window-1', 'none'); ?>
                            <?php echo add_default_parameters('delete', 'clear_param_values(this,1);', '', 'init-value-window-1', 'none'); ?>                    
                            <span class="between" style="display:none;">
                                <input type="text" class="adiha_control second-value" style="margin:2px 0px;"   /> 
                                <input type="hidden" class="second-value-index" />                        
                                <?php echo add_default_parameters('add', 'get_default_param_values(this,2);', '', 'init-value-window-2', 'none'); ?>
                                <?php echo add_default_parameters('delete', 'clear_param_values(this,2);', '', 'init-value-window-2', 'none'); ?>
                            </span>
						    <!-- <div class="not-saved-msg note-label">Unsaved</div> -->
                        </td>

                        <td>
                            <div class="push-up">
                                <label>
                                    <input type="checkbox" value="1" class="param-optional" /> 
                                </label>
                                <label>
                                    <input type="checkbox" value="1" class="param-hidden param02" onclick="rm_paramset.fx_hidden_check(this)" /> 
                                </label>
                            </div>
                        </td>
                    </tr> 
                </table>
            </div>
        </li>
    </div>
    <div id="tabbar_pm" class="dhtmlxTabBar" style="width:inherit; height:inherit; position: relative; xborder: solid 1px red; display: none;">
    <?php
        
        $i = 1;
        foreach ($datasets as $dataset):
            $id_md5ed = md5($dataset[1]);
            //var_dump($dataset[0]);
            //var_dump($dataset_columns_linear);

            $dataset_exists = 0;
            //if dataset not in use skip the tab
            foreach ($dataset_columns_linear as $key => $value) {
                if($value[0] == $dataset[0]) {
                    $dataset_exists = 1;
                }
            }

            if($dataset_exists == 0)
                continue;
    ?>

            <div id="<?php echo $id_md5ed; ?>" class="pm_tabs" name="<?php echo $dataset[1] ?>" style="width: 100%; height: 100%; xborder: solid 1px green;">
                
                <div style="top:auto; width: 100%; height: 100%; xborder: solid 1px green;">
                <div id="tabbar_pm_<?php echo $id_md5ed; ?>parameters" class="dhtmlxTabBar" mode="bottom"  style="top:auto; width: 100%; height: 100%; xborder: solid 1px green;">
                    <div id="<?php echo md5($dataset[1]); ?>_Parameters" class="" name="Parameters" style="width: 100%; height: 100%; xborder: solid 1px green;">
                     
                        <input class="root-datasets-id" type="hidden" value="<?php echo $dataset[0] ?>"/>
                        <div>
                            <!-- <img class="add-button add-parameter" id="add-parameter-<?php echo $id_md5ed; ?>" src="<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/toolbar/add.png" alt="Add Parameter" title="Add Parameter"/>
                            <img class="remove-button delete-parameter" id="delete-parameter-<?php echo $id_md5ed; ?>" src="<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/toolbar/delete.png" alt="Delete Parameter" title="Delete Parameter"/>
                            <img  id="rearrange-<?php echo $id_md5ed; ?>" src="<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/toolbar/rearrange.png" alt="Rearrange Parameter" title="Rearrange Parameter" onclick="rm_paramset.arrange(this)"/>

                            <img  id="select_all" class="sel_all" src="<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/un_select.jpg" alt="Select All" title="Select All" onclick="rm_paramset.select_all_check(this)"/>

                            <img  id="optional_all" class="opt_all" src="<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/un_select.jpg" alt="All Optional" title="Optional All" onclick="rm_paramset.optional_all_check(this)"/>

                            <img  id="hide_all" class="hid_all" src="<?php echo $app_php_script_loc; ?>adiha_pm_html/process_controls/select_all.jpg" alt="Select All" title="All Hidden" onclick="rm_paramset.hide_all_check(this)"/>   
                         
                            <label>
                                <input id='select_all' type="checkbox"  onclick="rm_paramset.select_all_check(this)" /> Select All
                            </label>
                            <label>
                                <input id='optional_all'  type="checkbox" onclick="rm_paramset.optional_all_check(this)" /> All Optional
                            </label>
                            <label>
                                <input id='hide_all' type="checkbox" onclick="rm_paramset.hide_all_check(this)" /> All Hidden
                            </label>
                        -->
                        </div>
                           
                        <div class="paramset_columns_header">
                            <div class="paramset_columns_header_detail div_first">
                            </div>
                               
                            <div class="paramset_columns_header_detail div_columns">
                                Columns
                            </div>

                            <div class="paramset_columns_header_detail div_operator">
                                Operator
                            </div>

                            <div class="paramset_columns_header_detail div_label">
                                Label
                            </div>

                            <div class="paramset_columns_header_detail div_value1">
                                Value(s)
                            </div>

                            <div class="paramset_columns_header_detail div_optional">
                                Optional
                            </div>

                            <div class="paramset_columns_header_detail div_hidden">
                                Hidden
                            </div>
                        </div>
                  
                  
                            <div id="container-param-block" class="class-trm-paramset-detail" style="xborder: solid 1px black;">
                            <ul id="paramset-region-<?php echo $id_md5ed; ?>" class="data-table paramset-region">
                                <?php
                                if (isset($data_report_param[$dataset[0]]) && sizeof($data_report_param[$dataset[0]]) > 0) {
                                    $count_items = sizeof($data_report_param[$dataset[0]]);
                                    $current_depth = -1;  // -1 to get the outer <ul>
                                    $sort_id =0;
                                    foreach ($data_report_param[$dataset[0]] as $key_major => $param) {
                                        $sort_id++;
                                        $id_md5ed_second = md5($id_md5ed . $key_major);
                                        $param_depth = (($param['param_depth'] ?? NULL) != NULL) ? $param['param_depth'] : 0;
                                        $unsaved_param = $param['unsaved_param'] ?? 0;
                                        $param_order = $param['param_order'] ?? '';
                                        $param_depth = $param['param_depth'] ?? 0;
                                        $logical_operator = $param['logical_operator'] ?? '';
                                        $operator = $param['operator'] ?? '';
                                        $initial_value = $param['initial_value'] ?? '';
                                        $initial_value2 = $param['initial_value2'] ?? '';
                                        $optional = $param['optional'] ?? '';
                                        $hidden = $param['hidden'] ?? '';
                                        ?>

                                        <li class="clone <?php echo ($unsaved_param == '1' ) ? 'new-from-ds' : ''; ?> <?php echo ($param['required_filter'] == 1 || $param['required_filter'] == 0) ? 'no-nest no-append' : 'normal-sort'; ?> <?php echo ($key_major % 2 == 0) ? ' even_color' : ' odd_color'; ?>" id="old-item-<?php echo $id_md5ed_second; ?>" rel="<?php echo $param_order; ?>"
                                        required_filter="<?php echo $param['required_filter']; ?>" 
                                        data-sort-id = "<?php echo $sort_id ?> "
                                        depth-level = "<?php echo $param_depth; ?>"
                                        >
                                            <div class="depth-info-level <?php echo ($param_depth > 0 ? 'nesting_level0'.$param_depth : '' ); ?>">
                                                <table class="data-table" style="width: 100%;">
                                                    <tr valign="top">
                                                        
                                                        <td class="check_opt">
                                                            <div class="push-up check_operator">
                                                                <input type="checkbox" value="1" class="remove-param" alt="Mark to Delete Parameter" title="Mark to Delete Parameter" <?php if ($param['required_filter'] == 1 || $param['required_filter'] == 0) { ?> disabled="1" <?php } ?> />
                                                                <select class="param-relation adiha_control">
                                                                    <option value="1" <?php echo (($logical_operator == 1) ? 'selected' : ''); ?>>AND</option>
                                                                    <option value="2" <?php echo (($logical_operator == 2) ? 'selected' : ''); ?>>OR</option>
                                                                </select>
                                                            </div>
                                                            <input type="hidden" class="param-title" value=""/>
                                                        </td>
                                                        <td width="320" class="depth-info-width <?php echo ($param_depth > 0 ? 'nesting_width0'.$param_depth : '' ); ?>">

                                                            <select onchange="" class="adiha_control datasets-column depth-info-width <?php echo ($param_depth > 0 ? 'nesting_width0'.$param_depth : '' ); ?>" s6tyle="width: 300px; "

                                                            <?php if ($param['required_filter'] == 1 || $param['required_filter'] == 0) { ?> disabled="1" style="opacity: 0.6;" <?php } ?> >
                                                                <?php foreach ($dataset_columns[$param['root_dataset_id']] as $dataset_column): ?>
                                                                    <option <?php echo ($dataset_column[0] == $param['column_id'] && $dataset_column[2] == $param['dataset_id']) ? 'selected' : ''; ?> value="<?php echo $dataset_column[0] . '_' . $dataset_column[2]; ?>" rel="<?php echo $dataset_column[3] ?>" afilter="<?php echo $dataset_column[5] ?>" ><?php echo $dataset_column[1] ?></option>
                                                                <?php endforeach; ?>
                                                                
                                                            </select>
                                                        </td>
                                                        <td width="160">
                                                          
                                                            <select class="sel-operator adiha_control datasets-relation" style="width: 140px; margin-left: 10px; <?php echo ($param['required_filter'] == 1 || $param['required_filter'] == 0) ? 'opacity: 0.6;" disabled' : ''; ?> onchange="">
                                                                <?php foreach ($report_operator as $data): ?>
                                                                    <option rel="<?php echo $data['sql_code']; ?>" value="<?php echo $data['report_param_operator_id']; ?>" 
                                                                        <?php 
                                                                        if ($data['report_param_operator_id'] == $operator) {
                                                                            echo 'selected';                                                               
                                                                        } else {                                                                                                                                                                               
                                                                            echo (($param['widget_type'] == 'DROPDOWN' ||$param['widget_type'] == 'BSTREE-Strategy' || $param['widget_type'] == 'BSTREE-Book' || $param['widget_type'] == 'BSTREE-Subsidiary' || $param['widget_type'] == 'BSTREE-SubBook' || $param['widget_type'] == 'DataBrowser' || $param['widget_type'] == 'Multiselect Dropdown') && $data['report_param_operator_id'] == 9 && $param['operator'] == '')? 'selected' : '';
                                                                        }
                                                                        ?>
                                                                    >
                                                                    <?php echo $data['description'];?></option>
                                                                <?php endforeach; ?>
                                                            </select>
                                                        </td>
                                                        <td width="180" class="adiha_label">
                                                            
                                                            <input type="text" class="adiha_control label" value="<?php echo $param['label'] ?>" />
                                                        </td>
                                                        <td width="240" >
                                                            
                                                            <?php
                                                            $init_val = (array_key_exists($initial_value, $as_of_date)) ? $as_of_date[$param['initial_value']] : $initial_value;
                                                            $disabled = (array_key_exists($initial_value, $as_of_date)) ? 'disabled="disabled"' : '';
                                                            $parameter_value = $default_param_array[$param['column_id']][0][0][1];
                                                            $hidden_text_value = $param['initial_value'] ?? '';
                                                            $current_column = $param['column_id'];
                                                            $display_name = $param['bcn'] ?? '';

                                                            $check_if_custom_as_of_date_run_before = explode('.', $init_val);
                                                            if (array_key_exists(1, $check_if_custom_as_of_date_run_before)) {
                                                                if (ctype_digit($check_if_custom_as_of_date_run_before[1]) && $check_if_custom_as_of_date_run_before[1] != 1) {
                                                                    $init_val = $as_of_date['DATE.X'];
                                                                    $disabled = 'disabled="disabled"';
                                                                }
                                                            }

                                                            /* to set value and label when dropdown is selected */                                                        
                                                            if ($param['widget_type'] == 'DROPDOWN' || $param['widget_type'] == 'Multiselect Dropdown') {
                                                                $drop_down_options = count($default_param_array[$current_column][0][2]);
                                                                for ($i = 0; $i < $drop_down_options; $i++) {
                                                                    $array_value = $default_param_array[$current_column][0][2][$i][0];
                                                                    if ($array_value == $param['initial_value']) {
                                                                        $hidden_text_value = $default_param_array[$current_column][0][2][$i][0];
                                                                        $init_val = $default_param_array[$current_column][0][2][$i][1];
                                                                    }
                                                                }
                                                                $disabled = 'disabled="disabled"';
                                                            }
                                                            
                                                            //disable any other fields except DATETIME and TEXTBOX
                                                            if ($param['widget_type'] != 'DATETIME' && $param['widget_type'] != 'TEXTBOX') {
                                                                $disabled = 'disabled="disabled"';
                                                            }
                                                            
                                                            if ($param['widget_type'] == 'DATETIME') {
                                                                $display_name = ($display_name != '') ?convert_to_client_date_format(date_create($display_name)->format('Y-m-d H:i:s')) : $display_name;
                                                            }
                                                            ?>
                                                            <input value="<?php echo $display_name; ?>" type="text" class="first-value adiha_control" <?php echo $disabled; ?> /> 
                                                            <input value="<?php echo $hidden_text_value ?>" type="hidden" class="first-value-index" />
                                                            <?php
                                                                $show_hide = ($param['widget_type'] == 'DATETIME' || $param['widget_type'] == 'BSTREE-Subsidiary'
                                                                        || $param['widget_type'] == 'BSTREE-Strategy' || $param['widget_type'] == 'BSTREE-Book'
                                                                        || $param['widget_type'] == 'BSTREE-SubBook'|| $param['widget_type'] == 'DROPDOWN'
                                                                        || $param['widget_type'] == 'DataBrowser' || $param['widget_type'] == 'Multiselect Dropdown') ? '' : 'none';
                                                                echo add_default_parameters('add', 'get_default_param_values(this,1);', '', 'init-value-window-1', $show_hide);
                                                                echo add_default_parameters('delete', 'clear_param_values(this,1);', '', 'init-value-window-1', $show_hide);
                                                            ?>
                                                            <span class="between" style="display:none;"> 
                                                                <?php
                                                                $init_val2 = (array_key_exists($initial_value2, $as_of_date)) ? $as_of_date[$initial_value2] : $initial_value2;
                                                                $disabled = (array_key_exists($initial_value2, $as_of_date)) ? 'disabled="disabled"' : '';
                                                                $hidden_text_value2 = $initial_value2;

                                                                $check_if_custom_as_of_date_run_before2 = explode('.', $init_val2);
                                                                if (array_key_exists(1, $check_if_custom_as_of_date_run_before2)) {
                                                                    if (ctype_digit($check_if_custom_as_of_date_run_before2[1]) && $check_if_custom_as_of_date_run_before2[1] != 1) {
                                                                        $init_val2 = $as_of_date['DATE.X'];
                                                                        $disabled = 'disabled="disabled"';
                                                                    }
                                                                }

                                                                if ($param['widget_type'] == 'DROPDOWN' || $param['widget_type'] == 'Multiselect Dropdown') {
                                                                    $drop_down_options = count($default_param_array[$current_column][0][2]);

                                                                    for ($i = 0; $i < $drop_down_options; $i++) {
                                                                        $array_value = $default_param_array[$current_column][0][2][$i][0];
                                                                        if ($array_value == $param['initial_value2']) {
                                                                            $hidden_text_value2 = $default_param_array[$current_column][0][2][$i][0];
                                                                            $init_val2 = $default_param_array[$current_column][0][2][$i][1];
                                                                        }
                                                                    }

                                                                    $disabled = 'disabled="disabled"';
                                                                }
                                                                
                                                                //disable any other fields except DATETIME and TEXTBOX
                                                                if ($param['widget_type'] != 'DATETIME' && $param['widget_type'] != 'TEXTBOX') {
                                                                    $disabled = 'disabled="disabled"';
                                                                }
                                                                
                                                                if ($param['widget_type'] == 'DATETIME') {
                                                                    $init_val2 = ($init_val2 != '') ?convert_to_client_date_format(date_create($init_val2)->format('Y-m-d H:i:s')) : $init_val2;
                                                                }
                                                                ?>
                                                                <input value="<?php echo $init_val2; ?>" type="text" class="second-value adiha_control" <?php echo $disabled; ?> /> 
                                                                <input value="<?php echo $hidden_text_value2; ?>" type="hidden" class="second-value-index" />
                                                                <?php echo add_default_parameters('add', 'get_default_param_values(this,2);', '', 'init-value-window-2', $show_hide); ?>
                                                                <?php echo add_default_parameters('delete', 'clear_param_values(this,2);', '', 'init-value-window-2', $show_hide); ?>
                                                            </span>
                                                             <div class="not-saved-msg note-label unsaved_img1" title="Unsaved Parameter" >&nbsp;</div> 
                                                            <!-- <div class="not-saved-msg note-label">
                                                                Unsaved
                                                            </div> -->
                                                        </td>
                                                        <td>
                                                            <div class="push-up">
                                                                <label>
                                                                    <input <?php echo ($optional == 1 && $param['required_filter'] != 1) ? 'checked' : ''; ?> type="checkbox" class="param-optional"
                                                                    <?php echo $param['required_filter'] == 1 ? 'disabled="true"' : ''; ?>
                                                                     /> 
                                                                </label>
                                                                <label>
                                                                    <input <?php echo ($hidden == 1) ? 'checked' : ''; ?> type="checkbox" class="param-hidden param01"  onclick="rm_paramset.fx_hidden_check(this)" />
                                                                </label>
                                                            </div>
                                                        </td>
                                                    </tr>    
                                                </table>
                                            </div>
                                            <?php
                                            // Adjust current depth
                                            $current_depth = $param_depth;

                                            // if (($key_major + 1) == $count_items) {
                                            //     echo str_repeat('</ul>', $current_depth + 1);
                                            // }
                                            }
                                        }
                                    //else {
                                        //echo '<ul id="paramset-region-' . $id_md5ed . '" class="data-table paramset-region"></ul>';
                                    //}
                                    ?>
                            </ul>
                            </div>
                            
                            </div>
                    <div id="<?php echo md5($dataset[1]); ?>_Advanced" class="" name="Advanced" style="width: 100%; height: 100%; xborder: solid 1px green;">

                        <div id="sql-tab-<?php echo $id_md5ed ?>" style="display: block;height: 100%">  
                                <div class="checkbox-single" style="float:right;">  
                                    <?php $check_advance_value = (($data_report_param[$dataset[0]][1]['advance_mode'] ?? '') == 0) ? '' : 'Checked'; ?>
                                    <input type="checkbox" id="chk_advance_mode_<?php echo $id_md5ed; ?>" class="advance_check" <?php echo $check_advance_value; ?>/>                                                    
                                    <span class="dhxform_label dhxform_label_align_left"><label>Enable Advanced Mode</label></span>
                                    <script type="text/javascript">          
                                        $(function(){
                                            var dataset_context = $('#' + '<?php echo $id_md5ed; ?>');
                                            var dataset_context = $('#' + '<?php echo $id_md5ed; ?>');

                                            $('#chk_advance_mode_'+ '<?php echo $id_md5ed; ?>').on('click', function() {
                                                var dataset_context_gen = $('#' + '<?php echo $id_md5ed; ?>' + '_Parameters');
                                                var dataset_context_adv = $('#' + '<?php echo $id_md5ed; ?>' + '_Advanced');

                                                if ($(this).is(':checked')) {  
                                                    //$('.txt-where-part', dataset_context_adv).attr('disabled', false);
                                                    //$('.txt-where-part', dataset_context_adv).removeClass('disabled');
                                                    editor_gbl['<?php echo $id_md5ed; ?>'].setReadOnly(false);

                                                    $('.param-relation', dataset_context_gen).hide();           
                                                    /////$('.paramset-region',dataset_context).nestedSortable({maxLevels: 1});//disable the nesting of the parameters.  
                                                    $('#btn_accept_' + '<?php echo $id_md5ed; ?>').addClass('dhtmlxMenu_dhx_web_TopLevel_Item_Normal');
                                                    $('#btn_accept_' + '<?php echo $id_md5ed; ?>').removeClass('dhtmlxMenu_dhx_web_TopLevel_Item_Disabled');
                                                    $('#btn_accept_' + '<?php echo $id_md5ed; ?>').find('img').attr('src','<?php echo $verify_img_path;?>');

                                                    //uncheck optional and hidden checkbox when advance mode is checked
                                                    $('.clone .param-hidden', dataset_context_gen).prop('checked', false);
                                                    $('.clone .param-optional', dataset_context_gen).prop('checked', false);
                                                    dhtmlx.message({
                                                        title:"Warning",
                                                        type:"alert-warning",
                                                        text: 'Optional and Hidden feature of report level parameter columns are unchecked while advance mode is on.'
                                                    });

                                                } else {                
                                                    //$('.txt-where-part', dataset_context_adv).attr('disabled', true);
                                                    //$('.txt-where-part', dataset_context_adv).addClass('disabled');
                                                    editor_gbl['<?php echo $id_md5ed; ?>'].setReadOnly(true);

                                                    $('.paramset-region .normal-sort .param-relation', dataset_context_gen).show();
                                                    $('.paramset-region .normal-sort .param-relation', dataset_context_gen).eq(0).hide(); 
                                                    /////$('.paramset-region',dataset_context).nestedSortable({maxLevels: 0});
                                                    $('#btn_accept_' + '<?php echo $id_md5ed; ?>').removeClass('dhtmlxMenu_dhx_web_TopLevel_Item_Normal');
                                                    $('#btn_accept_' + '<?php echo $id_md5ed; ?>').addClass('dhtmlxMenu_dhx_web_TopLevel_Item_Disabled');
                                                    $('#btn_accept_' + '<?php echo $id_md5ed; ?>').find('img').attr('src','<?php echo $verify_dis_img_path;?>');
                                                }
                                            });
                                        });
                                                                                                                            
                                    </script>
                                </div>
                                 <div class="dhx_cell_menu_def">
                                        <div class=" dir_left dhtmlxMenu_dhx_web_Middle">
                                        <?php
                                        $btn_id = 'btn_accept_' . $id_md5ed;
                                        //echo adiha_button($btn_id, 'Accept', true, '');
                                        ?>     
                                        <!--<input type="button" id="<?php echo $btn_id; ?>" value="Accept" /> -->
                                        <div id="<?php echo $btn_id; ?>" class="dhtmlxMenu_dhx_web_TopLevel_Item_Normal ">
                                        <img border="0" src="<?php echo $verify_img_path;?>" class="dhtmlxMenu_TopLevel_Item_Icon "> 
                                        <span>Accept</span>
                                        </div>
                                        <script type="text/javascript">

                                            $(function(){

                                            //get view columns in single dimensional array
                                            fx_get_paramset_columns = function(root_dataset_id) {
                                                var return_arr = [];
                                                return_arr = $.map(dataset_columns[root_dataset_id], function(obj) {
                                                    return (obj[1].split('.')[0] + '.' + obj[3]);
                                                });
                                                return return_arr;
                                            }
                                            
                                            //add custom set of ace editor completers for autocomplete list
                                            fx_add_ace_completers = function(editor_obj, root_dataset_id) {
                                                //add extra completers for ace editor
                                                var datasetColsCompleter = {
                                                    getCompletions: function(editor, session, pos, prefix, callback) {
                                                        var wordList = fx_get_paramset_columns(root_dataset_id);
                                                        callback(null, wordList.map(function(word) {
                                                            return {
                                                                caption: word,
                                                                value: word,
                                                                meta: "Paramset Columns"
                                                            };
                                                        }));
                                                    }
                                                }
                                                var scalarSQLFunctionsCompleter = {
                                                    getCompletions: function(editor, session, pos, prefix, callback) {
                                                        var wordList = scalar_functions_list;
                                                        callback(null, wordList.map(function(word) {
                                                            return {
                                                                caption: word,
                                                                value: word,
                                                                meta: "Scalar SQL Functions"
                                                            };
                                                        }));
                                                    }
                                                }
                                                editor_obj.completers.push(datasetColsCompleter);
                                                editor_obj.completers.push(scalarSQLFunctionsCompleter);
                                            }

                                            editor_gbl['<?php echo $id_md5ed; ?>'] = ace.edit("editor_<?php echo $id_md5ed; ?>");
                                            editor_gbl['<?php echo $id_md5ed; ?>'].session.setMode("ace/mode/sqlserver");
                                            editor_gbl['<?php echo $id_md5ed; ?>'].setTheme("ace/theme/sqlserver");
                                            editor_gbl['<?php echo $id_md5ed; ?>'].setValue("<?php echo str_replace('"','\\"', str_replace("\r","\\n", str_replace("\n","\\n", (($data_report_param[$dataset[0]][1]['advance_mode'] ?? 0) == 0) ? '' : $data_report_param[$dataset[0]][1]['where_part']))); ?>", -1);
                                            // enable autocompletion and snippets
                                            editor_gbl['<?php echo $id_md5ed; ?>'].setOptions({
                                                enableBasicAutocompletion: true,
                                                enableSnippets: true,
                                                enableLiveAutocompletion: false
                                            });

                                            fx_add_ace_completers(editor_gbl['<?php echo $id_md5ed; ?>'], '<?php echo ($param['root_dataset_id'] ?? ''); ?>');

                                                if ($('#chk_advance_mode_'+ '<?php echo $id_md5ed; ?>').is(':checked')) {
                                                    $('#btn_accept_' + '<?php echo $id_md5ed; ?>').removeClass('dhtmlxMenu_dhx_web_TopLevel_Item_Disabled');
                                                    $('#btn_accept_' + '<?php echo $id_md5ed; ?>').addClass('dhtmlxMenu_dhx_web_TopLevel_Item_Normal'); 
                                                //('.txt-where-part',$('#sql-tab-' + '<?php echo $id_md5ed; ?>')).prop('disabled', false);
                                                //$('.txt-where-part',$('#sql-tab-' + '<?php echo $id_md5ed; ?>')).removeClass('disabled');
                                                editor_gbl['<?php echo $id_md5ed; ?>'].setReadOnly(false);
                                                } else {
                                                     $('#btn_accept_' + '<?php echo $id_md5ed; ?>').removeClass('dhtmlxMenu_dhx_web_TopLevel_Item_Normal');
                                                    $('#btn_accept_' + '<?php echo $id_md5ed; ?>').addClass('dhtmlxMenu_dhx_web_TopLevel_Item_Disabled'); 
                                                    $('#btn_accept_' + '<?php echo $id_md5ed; ?>').find('img').attr('src','<?php echo $verify_dis_img_path;?>');

                                                editor_gbl['<?php echo $id_md5ed; ?>'].setReadOnly(true);
                                                }

                                            
                                            
                                            
                                            });

                                            $('#btn_accept_' + '<?php echo $id_md5ed; ?>').mouseover(function() {
                                                if ($('#chk_advance_mode_'+ '<?php echo $id_md5ed; ?>').is(':checked')) {
                                                    $(this).removeClass('dhtmlxMenu_dhx_web_TopLevel_Item_Normal');
                                                    $(this).addClass('dhtmlxMenu_dhx_web_TopLevel_Item_Selected');
                                                }
                                            });

                                            $('#btn_accept_' + '<?php echo $id_md5ed; ?>').mouseout(function() {
                                                if ($('#chk_advance_mode_'+ '<?php echo $id_md5ed; ?>').is(':checked')) {
                                                    $(this).addClass('dhtmlxMenu_dhx_web_TopLevel_Item_Normal');
                                                    $(this).removeClass('dhtmlxMenu_dhx_web_TopLevel_Item_Selected');
                                                }
                                            });

                                            $('#btn_accept_' + '<?php echo $id_md5ed; ?>').click(function() {
                                                if (!$('#chk_advance_mode_'+ '<?php echo $id_md5ed; ?>').is(':checked')) {
                                                    return false;
                                                }   
                                                var current_ds_id = '<?php echo $id_md5ed; ?>';
                                            //console.log(editor_gbl['<?php echo $id_md5ed; ?>']);                                                              
                                            if (!set_where_part(current_ds_id, editor_gbl['<?php echo $id_md5ed; ?>'])) {
                                                    save_it =  false;
                                                }

                                            });
                                        </script>
                                    </div>
                                    </div>
                                <div class="advance_sql_portion code-editor" id="editor_<?php echo $id_md5ed; ?>" style="top: 40px!important;">
                                    <?php $sql_where_part = (($data_report_param[$dataset[0]][1]['advance_mode'] ?? 0) == 0) ? '' : $data_report_param[$dataset[0]][1]['where_part']; ?>
                                    <!--<textarea class="adiha_control txt-where-part disabled" style="xmargin-top:10px;width: 100%; height: 80%;" disabled><?php echo $sql_where_part; ?></textarea>-->
                                   
                                </div>
                            </div> 
                    </div>
                </div>   
                </div>
            </div>
            <?php
            $i++;
        endforeach;
        ?>
    </div> 
     }
    .dhxcombo_dhx_web {
        width: 200px !important;
    }
    .dhxcombo_input {
        width: 190px !important;
    }
    
    .sortable {        
      overflow-y: scroll;
    }

    #popdiv {     
      padding: 0 20px 20px 20px;
      width: 80%;
      background-color: #f9f9f9;
      position: fixed;
      top: 50%;
      left: 50%;
      transform: translateX(-50%) translateY(-50%);
      border: 2px solid #81e0d3;
      box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.2), 0 6px 20px 0 rgba(0, 0, 0, 0.19);

    }

    .backdrop {
      position: fixed;
      top: 0px;
      left: 0px;
      z-index: 999;
      height: 100%;
      width: 100%;
      background: rgba(0, 0, 0, 0.2);
      display: none;

    }


    .backdrop li {
        width: 23%;
        padding-bottom: 5px;
        padding-top: 5px;
        padding-left: 5px;
        text-align: left;
        margin: 3px;
        cursor: move;
        background-color: #f9f9f9;
        border: 1px solid #d5d5d5;
        font-size: 12px;
        float: left;
    }
    #param-save  { 
            background:#81e0d3; 
            padding:8px 16px; 
            border:0!important; 
            margin-top: 0 0 0 3px  
        }
        #param-save:hover { 
            background:#62cdbe; 
            cursor: pointer; 
        }
        #param-close { 
            background:#81e0d3; 
            padding:8px 16px; 
            border:0!important;  
        }
        #param-close:hover { 
            background:#62cdbe; 
            cursor: pointer; 
        }
        .title {
            text-align: center; 
            text-transform: capitalize; 
            padding: 20px 0 10px 0;
            border-bottom: 1px solid #ccc;
            margin-bottom: 20px;  
        }
	.check_opt {position: relative; left: 10px;}


    input[type="text"]:disabled { padding:0!important; }
}
</style>

<script>
    $(document).ready(function() {
        $('.sel-operator').on('change', function(){
            if ($(this).val() == 8) {
                $(this).parent().parent().find('.val-label').text('Values [From - To]');
            } else {
                $(this).parent().parent().find('.val-label').text('Value(s)');
            }
        });
    }); 
</script>

<div class="backdrop" id="rearrange_div">
   <div id="popdiv">
        <ui style="list-style: none;" class= 'sortable '> </ui>
    </div>
</div>
