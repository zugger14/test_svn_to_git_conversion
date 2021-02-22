<?php
/**
* Report manager tablix screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  
        require_once('../../../adiha.php.scripts/components/include.file.v3.php');
        require('../../../adiha.php.scripts/components/include.ssrs.reporting.files.php');
    ?>
    <style type="text/css">
        .class-trm-tablix-advance-tab-table { background: #fff!important; }
        .class-trm-tablix-advance-table { background: #fff!important; }
        .data-table th.base, .data-table th.main: { height:32px;}     
        .class-trm-tablix-advance-tab-table .column { font-size: 13px; color:#666; font-weight: 100; } 
        .class-trm-tablix-advance-table .column { font-size: 13px; color:#666; font-weight: 100;}
        .dhxform_obj_dhx_web input.dhxform_textarea {box-sizing: content-box!important; }

    </style>
</head>
<body>
    <?php     
    $php_script_loc = $app_php_script_loc;
    $app_user_loc = $app_user_name;
    
    $process_id = get_sanitized_value($_POST['process_id'] ?? '');
    $item_flag = get_sanitized_value($_POST['item_flag'] ?? '');
    $report_id = get_sanitized_value($_POST['report_id'] ?? '');
    $ri_info_obj = isset($_POST['ri_info_obj']) ? json_decode($_POST['ri_info_obj']) : '';
    
    $item_name = $ri_info_obj->{'page_name'} . '_tablix';
    $item_id = $ri_info_obj->{'item_id'};
	$item_id = isset($item_id) ? $item_id: "NULL";
    $dataset_id = '';
    $dataset_alias = '';
    $group_mode = '2';
    $border_style = '';
    $page_break = '';
    $tablix_type_id = 1;
    $cross_summary = '';
    $no_header = '';
    $export_table_name = '';
    $is_global = '';
    $detail_columns = array();
    $grouping_columns = array();
    $cols_columns = array();
    $rows_columns = array();
    $existing_columns = array();
    
    if($item_flag == 'u') {
        $column_list_url = "EXEC spa_rfx_report_page_tablix_dhx @flag='c',@process_id='$process_id',@report_page_tablix_id=$item_id";
        $column_list = readXMLURL2($column_list_url);
        //echo '<pre>';print_r($column_list);exit;
        if (is_array($column_list) && sizeof($column_list) > 0) {
            foreach ($column_list as $column) {
                $column_variable = '';

                switch ($column['placement']) {
                    case '1': $column_variable = 'detail_columns';
                        break;
                    case '2': $column_variable = 'grouping_columns';
                        break;
                    case '3': $column_variable = 'cols_columns';
                        break;
                    case '4': $column_variable = 'rows_columns';
                        break;
                }                
                
                $column_alias_cc = ($column['column_real_name_pivot'] == '') ? $column['alias'].'(CC)': $column['column_real_name_pivot'];
                

                $font_style_array = explode(',', $column['font_style']);
                $h_font_style_array = explode(',', $column['h_font_style']);
                $data_type = ($column['datatype_id'] == '3' || $column['datatype_id'] == '4') ? 1 : 2;
                array_push($$column_variable, array(
                            'report_tablix_column_id' => $column['report_tablix_column_id'],
                            'group_entity' => $column['group_entity'],
                            'data_source_column_id' => $column['data_source_column_id'],
                            'column_id' => $column['column_id'],
                            'column_name' => ($column['column_name'] == '') ? $column_alias_cc : $column['column_name'],
                            'column_name_real' => array_key_exists('column_name_real', $column) ? (empty($column['column_name_real']) ? $column_alias_cc : $column['column_name_real']) : $column_alias_cc,
                            'column_real_name_pivot' => ($column['column_real_name_pivot'] == '') ? $column_alias_cc : $column['column_real_name_pivot'],
                            'alias' => ($column['column_real_name_pivot'] == '') ? $column_alias_cc : $column['alias'],
                            'functions' => $column['functions'],
                            'aggregation' => $column['aggregation'],
                            'sortable' => $column['sortable'],
                            'rounding' => $column['rounding'],
                            'thousand_seperation' => $column['thousand_seperation'],
                            'default_sort_order' => $column['default_sort_order'],
                            'default_sort_direction' => $column['default_sort_direction'],
                            'font' => $column['font'],
                            'font_size' => $column['font_size'],
                            'font_style' => $column['font_style'],
                            'text_align' => $column['text_align'],
                            'text_color' => $column['text_color'],
                            'background' => $column['background'],
                            'h_font' => $column['h_font'],
                            'h_font_size' => $column['h_font_size'],
                            'h_font_style' => $column['h_font_style'],
                            'h_text_align' => $column['h_text_align'],
                            'h_text_color' => $column['h_text_color'],
                            'h_background' => $column['h_background'],
                            'placement' => $column['placement'],
                            'datatype' => $data_type,
                            'column_order' => $column['column_order'],
                            'bold_style' => $font_style_array[0],
                            'italic_style' => $font_style_array[1],
                            'underline_style' => $font_style_array[2],
                            'h_bold_style' => $h_font_style_array[0],
                            'h_italic_style' => $h_font_style_array[1],
                            'h_underline_style' => $h_font_style_array[2],
                            'render_as' => $column['render_as'],
                            'tooltip' => $column['tooltip'],
                            'column_template' => $column['column_template'],
                            'master_column_template' => $column['master_column_template'],
                            'negative_mark' => $column['negative_mark'],
                            'currency' => $column['currency'],
                            'date_format' => $column['date_format'],
                            'cross_summary_aggregation' => $column['cross_summary_aggregation'],
                            'mark_for_total' => $column['mark_for_total'],
                            'sql_aggregation' => $column['sql_aggregation'],
                            'subtotal' => $column['subtotal']
                ));
                array_push($existing_columns, $column['group_entity'] . '-' . $column['data_source_column_id']);
                //echo '<pre>';print_r('1');
            }
        }
        
        
        
        $item_header_url = "EXEC spa_rfx_report_page_tablix_dhx @flag='a', @process_id='$process_id', @report_page_tablix_id=$item_id";
        $item_header_values = readXMLURL2($item_header_url);
        //var_dump($item_header_values);
        if (is_array($item_header_values) && sizeof($item_header_values) > 0) {
            //echo '^^^^here^^^^';
            $item_name = $item_header_values[0]['name'];
            $dataset_id = $item_header_values[0]['root_dataset_id'];
            $dataset_alias = $item_header_values[0]['dataset_alias'];
            $group_mode = $item_header_values[0]['group_mode'];
            $border_style = $item_header_values[0]['border_style'];
            $page_break = $item_header_values[0]['page_break'];
            $tablix_type_id = ($item_header_values[0]['type_id'] == '') ? 1 : $item_header_values[0]['type_id'];
            $cross_summary = $item_header_values[0]['cross_summary'];
            $no_header = $item_header_values[0]['no_header'];
            $export_table_name = $item_header_values[0]['export_table_name'];
            $is_global = ($item_header_values[0]['is_global'] == '1') ? TRUE : FALSE;
        }
        //echo '<pre>';print_r($detail_columns);
        $pivot_col_list['detail_columns'] = implode(',', array_map(function($item) {
            return $item['column_real_name_pivot'];
            //return substr(strchr($item['column_name_real'], '.'), 1);
            //return $item['alias'];
        }, $detail_columns));
        $pivot_col_list['grouping_columns'] = implode(',', array_map(function($item) {
            return $item['column_real_name_pivot'];
            //return substr(strchr($item['column_name_real'], '.'), 1);
            //return $item['alias'];
        }, $grouping_columns));
        $pivot_col_list['cols_columns'] = implode(',', array_map(function($item) {
            return $item['column_real_name_pivot'];
            //return substr(strchr($item['column_name_real'], '.'), 1);
            //return $item['alias'];
        }, $cols_columns));
        $pivot_col_list['rows_columns'] = implode(',', array_map(function($item) {
            return $item['column_real_name_pivot'];
            //return substr(strchr($item['column_name_real'], '.'), 1);
            //return $item['alias'];
        }, $rows_columns));
        if($tablix_type_id == 1) {
            $aggregators = '';
        } else {
            $aggregators = implode(',', array_map(function($item) {
    			return $item['aggregation'];
            }, $detail_columns));
        }
		
		//echo '<pre>';print_r($pivot_col_list);exit;
        
    }
    
    $detail_columns = json_encode($detail_columns, JSON_HEX_APOS);
    $grouping_columns = json_encode($grouping_columns, JSON_HEX_APOS);
    $rows_columns = json_encode($rows_columns, JSON_HEX_APOS);
    $cols_columns = json_encode($cols_columns, JSON_HEX_APOS);
    
    
    /** get csv file names of generated datasets **/
    // $path_config_file = explode('\\', str_replace('\\\\','\\',$_SESSION['config_file']));
    // array_splice($path_config_file, -2, 2, array('trm', 'adiha.php.scripts', 'dev', 'report_manager_views'));
    // $csv_write_path = implode('\\', $path_config_file);die(print_r($csv_write_path));
    //$sp_url = "EXEC spa_rfx_report_dataset_dhx @flag = 'g', @process_id='$process_id', @csv_write_path='$csv_write_path'";
    $sp_url = "EXEC spa_rfx_report_dataset_dhx @flag = 'g', @process_id='$process_id'";
    $csv_file_name = readXMLURL2($sp_url);
    
    
    $form_namespace = 'rm_tablix';
    $layout_obj = new AdihaLayout();
    $layout_json = '[
        {id: "a", header:false, height:150}, 
        {id: "b", header:false}
    ]';
    
    echo $layout_obj->init_layout('pivot_template', '', '2E', $layout_json, $form_namespace);
    echo $layout_obj->attach_event('', 'onDock', $form_namespace . '.on_dock_report_event');
    echo $layout_obj->attach_event('', 'onUnDock', $form_namespace . '.on_undock_report_event');
    
    // attach menu
    $menu_json = '[{id: "save", img:"save.gif", img_disabled:"save.gif", text:"Save", title:"Save"}]';
    $menu_obj = new AdihaMenu();
    echo $layout_obj->attach_menu_cell("pivot_menu", "a");  
    echo $menu_obj->init_by_attach("pivot_menu", $form_namespace);
    echo $menu_obj->load_menu($menu_json);
    echo $menu_obj->attach_event('', 'onClick', $form_namespace . '.menu_click');
    
    // attach filter form
    $form_tablix = new AdihaForm();
    $form_tablix_name = 'datasource_form';
    echo $layout_obj->attach_form($form_tablix_name, 'a');

    $sp_url = "EXEC spa_rfx_report_dataset_dhx @flag = 's', @process_id='$process_id'";
    $dataset_dropdown_json = $form_tablix->adiha_form_dropdown($sp_url, 0, 2, true, $dataset_id);
    $dataset_array = readXMLURL2($sp_url);
    //echo '<pre>'.print_r($dataset_array);exit();
    
    $sp_url = "EXEC spa_rfx_report_dataset_dhx @flag = 'h', @process_id='$process_id'";
    $ds_col_info = readXMLURL2($sp_url);
    //echo '<pre>'.print_r($ds_col_info);exit();
     
    $json_page_break_opt = '
    [
        {value: "0", label: "None"},
        {value: "1", label: "Before Tablix"},
        {value: "2", label: "After Tablix"},
        {value: "3", label: "Before and After Tablix"}
    ]
    ';
    $json_tablix_type_opt = '
    [
        {value: "1", label: "Default"},
        {value: "2", label: "Crosstab"}
    ]
    ';
    $json_summary_on_opt = '
    [
        {value: "1", label: "None"},
        {value: "2", label: "Bottom"},
        {value: "3", label: "Right"},
        {value: "4", label: "Bottom + Right"}
    ]
    ';
    $json_grouping_mode_opt = '
    [
        {value: "2", label: "Drilldown expanded (-)"},
        {value: "1", label: "Drilldown collapsed (+)"},
        {value: "3", label: "Block (with repeats)"},
        {value: "4", label: "Block (no repeats)"}
    ]
    ';
 
    $json_table_border_opt = '
    [
        {value: "1", label: "All"},
        {value: "2", label: "Box"},
        {value: "3", label: "Horizontal Lines"},
        {value: "4", label: "Vertical Lines"},
        {value: "5", label: "None"},
        {value: "6", label: "Bill"}
    ]
    ';
    $form_json = '
    [ 
        {"type": "settings", "position": "label-top", "offsetLeft": '.$ui_settings['offset_left'].'},
        {type:"combo", name: "dataset_id", label:"Dataset", "labelWidth":"auto", required:true, filtering:true, "inputWidth":'.$ui_settings['field_size'].', "options": ' . $dataset_dropdown_json . '}, {type:"newcolumn"},
        {type:"input", name: "ds_alias", hidden: true, value: "' . $dataset_alias. '", label:"Data Source Alias", "labelWidth":"auto", required:false, "inputWidth":'.$ui_settings['field_size'].'}, {type:"newcolumn"},
        {type:"input", name: "ri_name", value: "' . $item_name . '", label:"Report Item Name", "labelWidth":"auto", required:true, "inputWidth":'.$ui_settings['field_size'].'}, {type:"newcolumn"},
        {type:"combo", name: "page_break", label:"Page Break", "labelWidth":"auto", required:false, filtering:true, filtering_mode: "between", "inputWidth":'.$ui_settings['field_size'].', options: ' . $json_page_break_opt . ' }, {type:"newcolumn"},
        {type:"combo", name: "summary_on", label:"Summary On", "labelWidth":"auto", required:false, filtering:true, filtering_mode: "between", "inputWidth":'.$ui_settings['field_size'].', options: ' . $json_summary_on_opt . ' }, {type:"newcolumn"},
        {type:"combo", name: "grouping_mode", label:"Grouping Mode", "labelWidth":"auto", required:false, filtering:true, filtering_mode: "between", "inputWidth":'.$ui_settings['field_size'].', options: ' . $json_grouping_mode_opt . ' }, {type:"newcolumn"},
        {type:"combo", name: "table_border", label:"Table Border", "labelWidth":"auto", required:false, filtering:true, filtering_mode: "between", "inputWidth":'.$ui_settings['field_size'].', options: ' . $json_table_border_opt . ' }, {type:"newcolumn"},
        {type:"input", name: "export_table_name", value: "' . $export_table_name. '", label:"Export Table Name", "labelWidth":"auto", required:0, "inputWidth":'.$ui_settings['field_size'].'}, {type:"newcolumn"},
        {type:"checkbox", name: "is_global", checked: "' . $is_global . '", label:"Is Global", "labelWidth":100, required:0, "inputWidth": '.$ui_settings['field_size'].', position: "label-right", offsetTop: '.$ui_settings['checkbox_offset_top'].'}, {type:"newcolumn"},
        {type:"checkbox", name: "hide_header", checked: "' . $no_header . '", label:"Hide Header", "labelWidth":100, required:false, "inputWidth": '.$ui_settings['field_size'].', position: "absolute", offsetTop: '.$ui_settings['checkbox_offset_top'].', "offsetLeft": 10, labelLeft: 32, labelTop: 27}
    ]
    ';

    $form_tablix->init_by_attach($form_tablix_name, $form_namespace);
    echo $form_tablix->load_form($form_json);    
    echo $form_tablix->attach_event('', 'onChange', $form_namespace . '.form_change');

    //Attach Tabbar
    $tab_json =   '[ 
                    {id:"general", text:"General", active:  true}, 
                    {id:"advance", text:"Advance"}
                    ]';  
    echo $layout_obj->attach_tab_cell('pivot_template_tab','b',$tab_json);
    echo $layout_obj->close_layout();
    
    
    //var_dump($_POST);
    ?> 
</body>
<!--<script type="text/javascript" src="<?php echo $app_php_script_loc; ?>components/ui/jquery-ui.min.js"></script>-->
<script src="https://code.jquery.com/ui/1.11.4/jquery-ui.js"></script>
<link rel="stylesheet" href="https://code.jquery.com/ui/1.11.4/themes/smoothness/jquery-ui.css"/>

<!-- load ace -->
<script src="../../../adiha.php.scripts/components/lib/ace/ace.js"></script>
<!-- load ace language tools -->
<script src="../../../adiha.php.scripts/components/lib/ace/ext-language_tools.js"></script>
<script type="text/javascript"> 
    parent.dhx_wins.window('window_ri').maximize();
    
    var ri_info_obj = $.parseJSON('<?php echo json_encode($ri_info_obj, JSON_HEX_APOS); ?>');
    var process_id = '<?php echo $process_id; ?>';
    var report_id = '<?php echo $report_id; ?>';
    var item_flag = '<?php echo $item_flag; ?>';
    var dataset_array = $.parseJSON('<?php echo json_encode($dataset_array, JSON_HEX_APOS); ?>');
    var csv_file_array = $.parseJSON('<?php echo json_encode($csv_file_name, JSON_HEX_APOS); ?>');
    var ds_col_info_gbl = $.parseJSON('<?php echo json_encode($ds_col_info, JSON_HEX_APOS); ?>');
    //console.log(csv_file_array);
    var update_detail_ri = '';
    var form_ri = {};
    var pivot_col_list = {
        detail_columns: '',
        grouping_columns: '',
        row_columns: '',
        col_columns: ''
    };
    var post_data = '';
    var ajax_url = '';
    
    //console.log(pivot_col_list);
    $(function() {
         layout_b = rm_tablix.pivot_template.cells('b');
         if(item_flag == 'u') {
            update_detail_ri = $.parseJSON('<?php echo json_encode($item_header_values ?? '', JSON_HEX_APOS); ?>');
            form_ri = rm_tablix.datasource_form;
            //console.log(update_detail_ri);
            
            form_ri.getCombo('page_break').setComboValue(update_detail_ri[0].page_break);
            form_ri.getCombo('summary_on').setComboValue(update_detail_ri[0].cross_summary);
            form_ri.getCombo('table_border').setComboValue(update_detail_ri[0].border_style);
            form_ri.getCombo('grouping_mode').setComboValue(update_detail_ri[0].group_mode);
            pivot_col_list['detail_columns'] = '<?php echo $pivot_col_list['detail_columns'] ?? ''; ?>';
            pivot_col_list['grouping_columns'] = '<?php echo $pivot_col_list['grouping_columns'] ?? ''; ?>';
            pivot_col_list['cols_columns'] = '<?php echo $pivot_col_list['cols_columns'] ?? ''; ?>';
            pivot_col_list['rows_columns'] = '<?php echo $pivot_col_list['rows_columns'] ?? ''; ?>';
            form_ri.getCombo('dataset_id').setComboValue('<?php echo $dataset_id; ?>');
            fx_renderer_type_change('<?php echo ($tablix_type_id == 1 ? 'Table' : 'CrossTab Table') ; ?>');
         }
         rm_tablix.form_change('dataset_id');
        
        var tabbar_obj = rm_tablix.pivot_template.cells('b').getAttachedObject();
        tabbar_obj.attachEvent("onTabClick", function(id, lastId){
            rm_tablix.fx_tablix_advance_click(id, lastId);
        });
        
        
    });
	
	rm_tablix.map_aggregators = function(aggregators_id) {
		switch(aggregators_id) {
			case '1':
				return 'Average';
				break;
			case '13':
				return 'Sum';
				break;
            case '9':
				return 'Minimum';
				break;
            case '8':
				return 'Maximum';
				break;
		}
	}

    rm_tablix.form_change = function(name, value, state) {
        var tabbar_obj = rm_tablix.pivot_template.cells('b').getAttachedObject();

        if (name == 'dataset_id') {
            var cmb_obj = rm_tablix.datasource_form.getCombo('dataset_id');
            
            if(cmb_obj.getSelectedValue() == '') {
                // console.log('***blank dataset selection ***');
                tabbar_obj.cells('general').detachObject(true);
                tabbar_obj.cells('advance').detachObject(true);
                tabbar_obj.tabs('advance').disable();
                return;
                
            } else {
                tabbar_obj.tabs('advance').enable();
            }
            
            /** get csv file info **/
            var selected_file_info = csv_file_array.filter(function(data) {
                return (cmb_obj.getSelectedValue() == data.report_dataset_id);
            });
            
            if(selected_file_info[0]['file_exists'] != 1) {
                dhtmlx.message({
                    title: 'Error',
                    type: 'alert-warning',
                    text: 'Dataset CSV file not found.'
                });
                return;
            }
            
            
            //var file_name = cmb_obj.getSelectedText().split(' (')[0];
            
			var aggregators_list = '<?php echo $aggregators ?? ''; ?>';
			aggregators_list = aggregators_list.split(',');
			var aggregators_arr = new Array();
			for (cnt = 0; cnt < aggregators_list.length; cnt++) {
				//if(aggregators_list[cnt] != '') {
				    aggregators_arr.push(rm_tablix.map_aggregators(aggregators_list[cnt]));
				//}
			}
			var aggregators = aggregators_arr.toString();
			//var aggregators = '<?php echo ($tablix_type_id == 1 ? '' : 'Sum') ; ?>';
            
            
            
            tabbar_obj.tabs("general").setActive();
            layout_b.progressOn();
            //var file_path = '<?php echo str_replace("\\", "/", $report_views_url_path); ?>';
            var file_path = js_php_path + 'dev/shared_docs/report_manager_views/';
            //console.log(file_path);
            
            //var tabbar_obj = rm_tablix.pivot_template.cells('b').getAttachedObject();
            
            tabbar_obj.forEachTab(function(tab){
                var tab_name = tab.getText();
                if (tab_name == get_locale_value('General')) {
                    var full_file_name = file_path + selected_file_info[0]['csv_file_name'];
                    var post_param = {
                        file_path: full_file_name,
                        report_type: 'tablix',
                        renderer_type: '<?php echo ($tablix_type_id == 1 ? 'Table' : 'CrossTab Table') ; ?>',
                        aggregators: aggregators,
                        col_list: JSON.stringify(pivot_col_list),
                        call_from: 'report_manager_dhx',
                        dataset_id: rm_tablix.datasource_form.getItemValue('dataset_id'),
                        dataset_array: JSON.stringify(dataset_array),
                        process_id: process_id
                    };
                    //console.log(pivot_col_list);
                    
                    var url = js_php_path + 'pivot.template.dhx.php';
                    //dhx.ajax.cache = false;
                    tab.attachURL(url, true, post_param);
                } else if (tab_name == get_locale_value('Advance')) {
                    var summary_on = rm_tablix.datasource_form.getItemValue('summary_on');
                    var post_param = {
                        mode: item_flag,
                        report_resultset_id: '',
                        report_id: report_id,
                        item_id: ri_info_obj.item_id,
                        process_id: process_id,
                        page_id: '',
                        left: '',
                        top: '',
                        width: '',
                        height: '',
                        summary_on: summary_on,
                        renderer_type:'<?php echo $tablix_type_id; ?>',
                        dataset_id: rm_tablix.datasource_form.getItemValue('dataset_id'),
                        dataset_array: JSON.stringify(dataset_array)
                    };
                    //var url = js_php_path + 'pivot.template.advance.php';
                    dhx.ajax.cache = false;
                    var url = app_form_path  + '_reporting/report_manager_dhx/report.manager.dhx.tablix.advance.php';
                    
                    tab.attachURL(url, true, post_param);
                    //window.fx_dataset_change();
                }
            });
        } else if(name == 'summary_on') {
            if(window.fx_summary_on_change !== undefined) {
                window.fx_summary_on_change(value);
            }
        }
    }

    /**
     * Function to get formatted value for numeric values on pivot data
     *
     * @param   id       id
     * @param   name     name of column
     * @param   value    actual value of column
     *
     * @return  text   returns formatted value
     */
    function fx_get_formatted_value (id, name, value) {
        var return_val = value;
        //pick render as from advance tab
        var context_row = $('.data-table .clone').filter(function(){
                return ($('.column-real-name', $(this)).text() == name);
            });
        var render_as = $('.renderas-list option:selected', context_row).val();
        var thousand_sep = $('.thousand-list option:selected', context_row).val();
        var rounding = $('.rounding-list option:selected', context_row).val();
        
        //if not available from advance tab (happens for first load case), then refer to column datatype and gt corresponding render as
        if (render_as == undefined || render_as == '') {
            var id = ds_col_info_gbl.filter(function(e) {
                return (e.column_name_real.split('.')[1].toLowerCase() == name.split('.')[1].toLowerCase());
            });
            
            if (id.length > 0) {
                render_as = fx_data_render_mapping(id[0].datatype_id);
            }
        }
        

        if (thousand_sep == 2) {
            group_sep = '';
        } else {
            group_sep = global_group_separator;
        }
        
        if (rounding == undefined || rounding == '' || rounding == -1) {
            switch (render_as) {
                case 2: 
                    rounding = global_number_rounding;
                    break;
                case 3: 
                    rounding = global_amount_rounding;
                    break;
                case 13: 
                    rounding = global_price_rounding;
                    break;
                case 14: 
                    rounding = global_volume_rounding;
                    break;
                default:
                    rounding = global_number_rounding;
            }
        }
        //console.log('render_as:'+render_as+'|group_sep:'+group_sep+'|rounding:'+rounding);
        //render_as values: 2=number, 3=amount, 13=price, 14=volume
        if (render_as == '2' || render_as == '3' || render_as == '13' || render_as == '14') {
            //console.log('value:'+value+'|rounding:'+rounding+'|global_decimal_separator:'+global_decimal_separator+'|group_sep:' +group_sep);
            return_val = $.number(value, rounding, global_decimal_separator, group_sep);
        }
        return return_val;
    }
    /**
     * [undock_details Undock detail layout]
     */
    rm_tablix.undock_reports = function() {
        var layout_obj = rm_tablix.pivot_template;
        layout_obj.cells("b").undock(300, 300, 900, 700);
        layout_obj.dhxWins.window("b").button("park").hide();
        layout_obj.dhxWins.window("b").maximize();
        layout_obj.dhxWins.window("b").centerOnScreen();
    }

    /**
     * [on_dock_report_event On dock event]
     * @param  {[type]} id [Cell id]
     */
    rm_tablix.on_dock_report_event = function(id) {
        if (id == 'b') {            
            $(".undock_report").show();
        }
    }
    /**
     * [on_undock_report_event On undock event]
     * @param  {[type]} id [Cell id]
     */
    rm_tablix.on_undock_report_event = function(id) {
        if (id == 'b') {
            $(".undock_report").hide();            
        }            
    }

    /**
     * [menu_click Menu click]
     * @param  {[type]} id [id of menu]
     */
    rm_tablix.menu_click = function(id) {
        switch (id) {
            case "save":
                var form_obj = rm_tablix.datasource_form;
                if(validate_form(form_obj)) {
                    columns_array_gbl = window.get_columns();
                    //console.log(columns_array_gbl['grouping_columns']);return;
                    if(columns_array_gbl['detail_columns'] == '' || columns_array_gbl['detail_columns'] === undefined) {
                        dhtmlx.message({
                            title: 'Error',
                            type: 'alert-warning',
                            text: 'Please select detail column.'
                        });
                    } else if(columns_array_gbl['renderer_type'] == 'CrossTab Table' && (columns_array_gbl['columns'] == '' || columns_array_gbl['rows'] == '')) {
                        dhtmlx.message({
                            title: 'Error',
                            type: 'alert-warning',
                            text: 'Please select items on rows/columns.'
                        });
                    } else if(columns_array_gbl['renderer_type'] == 'CrossTab Table' && columns_array_gbl['detail_columns'].split('||||')[1] == '') {
                        dhtmlx.message({
                            title: 'Error',
                            type: 'alert-warning',
                            text: 'Please select items on detail column.'
                        });
                    } else {
                        //call to general click so that CC deletion also propagates to general tab
                        rm_tablix.fx_tablix_advance_click('general');
                        rm_tablix.fx_tablix_advance_click('advance');
                        var form_obj = rm_tablix.datasource_form;
                        rm_tablix.fx_save_tablix_info(form_obj.getItemValue('dataset_id'));
                        //rm_tablix.fx_save_dataset_info(form_obj);
                    }
                }
                
                
                break;
        }
    }
    
   
    //function to save tablix info
    rm_tablix.fx_save_tablix_info = function(dataset_id) {
        
        var filtered_ds = dataset_array.filter(function(e) {
            return e.report_datasets_id == dataset_id;
        });
        //console.log(filtered_ds[0].source_id);return;
        var source_id = filtered_ds[0].source_id;
        post_data = {
            'action': 'spa_rfx_data_source_column_dhx',
            'flag': 'z',
            'source_id': source_id
        };
        //console.dir(post_data);
        adiha_post_data('return_json', post_data, '', '', 'rm_tablix.fx_extract_ds_col_id_cb', false);
        //console.log(columns_array_gbl['detail_columns']);
        
        var item_name = rm_tablix.datasource_form.getItemValue('ri_name').replace(/-/g,'_');
        /*
        if(/^[a-zA-Z0-9_]*$/.test(item_name) == false) {
            dhtmlx.message({
                title: 'Error',
                type: 'alert-error',
                text: 'Invalid character on item name.'
            });
            return;
        }
        */
        
        var cmb_border_style = rm_tablix.datasource_form.getItemValue('table_border');
        var cmb_page_break = rm_tablix.datasource_form.getItemValue('page_break');
        var type_id = (columns_array_gbl['renderer_type'] == 'Table' ? 1 : 2); //rm_tablix.datasource_form.getItemValue('tablix_type');
        var cross_summary = rm_tablix.datasource_form.getItemValue('summary_on');
        var no_header = (rm_tablix.datasource_form.getItemValue('hide_header') ? 1 : 2);
        
        var cmb_group_mode = rm_tablix.datasource_form.getItemValue('grouping_mode');
        var export_table_name = rm_tablix.datasource_form.getItemValue('export_table_name');
        var is_global = (rm_tablix.datasource_form.isItemChecked('is_global') ? 1 : 0);
        
        var tablix_xml_obj = window.save_tablix();
		
		if (tablix_xml_obj.valiation_status != '') {
			show_messagebox(tablix_xml_obj.valiation_status);
			return;
		}
        
        //console.log(xml_rs_headers);
//        console.log(xml_rs_columns);
//        return;
        post_data = {
            'action': 'spa_rfx_report_page_tablix_dhx',
            'flag': 'u',
            'report_page_tablix_id': ri_info_obj.item_id,
            'root_dataset_id': dataset_id,
            'page_id': ri_info_obj.page_id,
            'process_id': process_id,
            'tablix_name': item_name,
            'width': ri_info_obj.width,
            'height': ri_info_obj.height,
            'left': ri_info_obj.left,
            'top': ri_info_obj.top,            
            'border_style': cmb_border_style,
            'page_break': cmb_page_break,
            'type_id': type_id,
            'cross_summary': cross_summary,
            'no_header': no_header,
            
            'group_mode': cmb_group_mode,
            'export_table_name': export_table_name,
            'is_global': is_global,
            
            'xml_column': tablix_xml_obj.xml_rs_columns,
            'xml_header': tablix_xml_obj.xml_rs_headers
            
        };

        
        adiha_post_data('return_json', post_data, '', '', 'rm_tablix.fx_save_tablix_info_cb');
        
    };
    rm_tablix.fx_save_tablix_info_cb = function(result) {
        
        json_obj = $.parseJSON(result);
        if(json_obj[0].errorcode == 'Success') {
            parent.success_call('Tablix info saved.', 'error');
            var item_arr = new Array();
            var item_id = json_obj[0].recommendation;
            var item_name = rm_tablix.datasource_form.getItemValue('ri_name');
            item_arr.push(item_id, '2', item_name);
            
            if(item_flag == 'i') {
                parent.ifr_dhx.ifr_tab[process_id].ifr_page.fx_add_report_item(ri_info_obj.item_type, item_arr);
                parent.ifr_dhx.ifr_tab[process_id].div_obj.attr('item_id', item_id);//to do (set item id on comma seperated)
            } else {
                parent.ifr_dhx.ifr_tab[process_id].ifr_page.fx_set_item_name(ri_info_obj.report_item_id, item_arr[2]);
            }
            
            try {
                parent.dhx_wins.window('window_ri').close();
            } catch (e) {
                alert('Exception: ' + e);
            }
            
        } else {
            // console.log('***error on saving tablix ***');
            dhtmlx.message({
                title: "Error",
                type: "alert-error",
                text: json_obj[0].message,
            });
			
			//' + json_obj[0].recommendation + '
			
			 $('.function').each(function( index ) {
				//alert($(this).val() + ' ' + json_obj[0].recommendation)
                if($(this).val() == json_obj[0].recommendation){ 
                    $(this).css('background-color',  '#FE7582');
        }
            });
		
        }
    };
    var json_ds_col_id_gbl;
    rm_tablix.fx_extract_ds_col_id_cb = function(result) {
        json_obj = $.parseJSON(result);
        //console.dir(json_obj);
        json_ds_col_id_gbl = json_obj;
          
    };
    
    fx_renderer_type_change = function(value) {
        var form_obj = rm_tablix.datasource_form;
        var cmb_obj = form_obj.getCombo('summary_on');
        if(value == 'CrossTab Table') {
            
            //filter summary on combo list
            cmb_obj.filter(function(opt) {
                return true;
            }, false);
            
            //disable grouping mode
            form_obj.disableItem('grouping_mode');
        } else {
            //unfilter summary on combo list
            cmb_obj.filter(function(opt) {
                return (opt.value == 1 || opt.value == 2);
            }, false);
            
            //enable grouping mode
            form_obj.enableItem('grouping_mode');
        }
        
    };
    
    
    var detail_item_arr = new Array();
    var detail_columns = '<?php echo $detail_columns; ?>';
    detail_columns = JSON.parse(detail_columns);
    for (ck_cnt = 0; ck_cnt < detail_columns.length; ck_cnt++) {
        detail_item_arr.push(detail_columns[ck_cnt].column_id);
    }
    
    var grouping_item_arr = new Array();
    var grouping_columns = '<?php echo $grouping_columns; ?>';
    grouping_columns = JSON.parse(grouping_columns);
    for (ck_cnt = 0; ck_cnt < grouping_columns.length; ck_cnt++) {
        grouping_item_arr.push(grouping_columns[ck_cnt].column_id);
    }
    
    var rows_item_arr = new Array();
    var rows_columns = '<?php echo $rows_columns; ?>';
    rows_columns = JSON.parse(rows_columns);
    for (ck_cnt = 0; ck_cnt < rows_columns.length; ck_cnt++) {
        rows_item_arr.push(rows_columns[ck_cnt].column_id);
    }
    
    var cols_item_arr = new Array();
    var cols_columns = '<?php echo $cols_columns; ?>';
    cols_columns = JSON.parse(cols_columns);
    for (ck_cnt = 0; ck_cnt < cols_columns.length; ck_cnt++) {
        cols_item_arr.push(cols_columns[ck_cnt].column_id);
    }
    
    fx_data_render_mapping = function(id) {
        switch(id) {
            case 1 :
                return 0;
                break;
            case 2:
                return 4;
                break;
            case 3:
                return 2;
                break;
            case 4:
                return 2;
                break;
            case 5:
                return 0;
                break;
            default:
                return 0;
        }
    }
    
    fx_column_aggregation_mapping = function(name) {
        switch(name) {
            case 'Count' :
                return 2;
                break;
            case 'Sum' :
                return 13;
                break;
            case 'Average' :
                return 1;
                break;
            case 'Minimum' :
                return 9;
                break;
            case 'Maximum' :
                return 8;
                break;
            default:
                return 13;
       }
    }
    
    rm_tablix.fx_tablix_advance_click = function(id, last_id) {
        //console.log(ds_col_info_gbl);
        var tabbar_obj = rm_tablix.pivot_template.cells('b').getAttachedObject();
        if(id == tabbar_obj.getActiveTab()) { //do nothing when click on same active tab
            return false;
        } else if (id == 'advance' && rm_tablix.datasource_form.getCombo('dataset_id').getSelectedValue() != '') {
            var dataset_id = rm_tablix.datasource_form.getItemValue('dataset_id');
            var summary_on = rm_tablix.datasource_form.getItemValue('summary_on');
            var tabbar_obj = rm_tablix.pivot_template.cells('b').getAttachedObject();
            tabbar_obj.forEachTab(function(tab){
                var tab_name = tab.getText();
                if (tab_name == 'Advance') {
                    column_arr = window.get_columns();
                    
                    var renderer_type = column_arr['renderer_type'];
                    var detail_columns = column_arr['detail_columns'];
                    var grouping_columns = column_arr['grouping_columns'];
                    var rows_columns = column_arr['rows'];
                    var cols_columns = column_arr['columns'];
                    
                    var detail_columns_arr = (detail_columns == "" ? [] : detail_columns.split(','));
                    //var detail_columns_arr = detail_columns.split(',');
                    var detail_columns_arr_ct = detail_columns_arr;
                    //var detail_columns_arr_ct = column_arr['detail_columns'].split(',');
                    var grouping_columns_arr = grouping_columns.split(',');
                    var rows_columns_arr = rows_columns.split(',');
                    var cols_columns_arr = cols_columns.split(',');
                    
                    var form_obj = rm_tablix.datasource_form;
                    var dataset_id = form_obj.getItemValue('dataset_id');
                    var filtered_ds = dataset_array.filter(function(e) {
                        return e.report_datasets_id == dataset_id;
                    });
                    var data_alias = filtered_ds[0].alias;
                    
                    if (renderer_type == 'Table') {
                        window.tablix_type_change(1);                                         

                        //List pre-existed custom columns
                        var custom_col_grp_remove_arr = [];
                        var custom_col_detail_remove_arr = [];
                        var custom_col_tr = $('#detail-column-region').find('.custom-column'); 
                        var custom_col_info = [];
                        if(custom_col_tr.length > 0) {
                            $.each(custom_col_tr, function(k, tr) {                    
                                custom_col_info.push($(tr).find('span.column').text());                                    
                            })
                        }

                        //Adding Dragged Detail Columns
                        var detail_arr = new Array();

                        for (cnt = 0; cnt < detail_columns_arr.length; cnt++) {
                            var id = ds_col_info_gbl.filter(function(e) {
                                return e.column_name_real == detail_columns_arr[cnt];
                                //return e.alias == detail_columns_arr[cnt];
                            });

                            if (id != '') {
                                var existance_flag = 0;
                                for (ck_cnt = 0; ck_cnt < detail_item_arr.length; ck_cnt++) {
                                    if (detail_item_arr[ck_cnt] == id[0].data_source_column_id) {
                                        existance_flag = 1;
                                    }
                                }

                                if (existance_flag == 0) {
                                    var item_id = id[0].report_dataset_id + '-' + id[0].data_source_column_id;
                                    var item_position =  0 + cnt;
                                    //var item_label = data_alias + '.' + detail_columns_arr[cnt];
                                    var item_label = id[0].alias;
                                    var item_nature = fx_data_render_mapping(id[0].datatype_id);
                                    var item_real_name = id[0].column_name_real;
                                    window.register_column(1, item_position, item_id, item_label, item_nature, item_real_name);  
                                }
                                detail_arr.push(id[0].data_source_column_id);       
                            }

                            //For custom columns
                            if (detail_columns_arr[cnt].indexOf('.') == -1 && custom_col_info.indexOf(detail_columns_arr[cnt]) == -1) {
                                var col_name = detail_columns_arr[cnt];
                                custom_col_grp_remove_arr.push(col_name);
                                var item_position =  0 + cnt;
                                var item_id = col_name;
                                var item_label = col_name;
                                var item_nature = 1;
                                var item_real_name = 'Custom Column';
                                window.register_column(1, item_position, item_id, item_label, item_nature, item_real_name);
                            }
                            
                        }
                        


                        //Delete the removed detail columns
                        for (cnt = 0; cnt < detail_item_arr.length; cnt++) {
                            var id = detail_arr.filter(function(e) {
                                return e == detail_item_arr[cnt];
                            });
                            if (id == '') {
                                window.delete_column_dragged($('#detail-column-region'),detail_item_arr[cnt]);
                            }
                        }
                        detail_item_arr = detail_arr;


                        //Adding Dragged Grouping Columns
                        var grouping_arr = new Array();
                        for (cnt = 0; cnt < grouping_columns_arr.length; cnt++) {
                            var id = ds_col_info_gbl.filter(function(e) {
                                return e.column_name_real == grouping_columns_arr[cnt];
                                //return e.alias == grouping_columns_arr[cnt];
                            });
                            //console.log(id);
                            if (id != '') {
                                var existance_flag = 0;
                                for (ck_cnt = 0; ck_cnt < grouping_item_arr.length; ck_cnt++) {
                                    if (grouping_item_arr[ck_cnt] == id[0].data_source_column_id) {
                                        existance_flag = 1;
                                    }
                                }

                                if (existance_flag == 0) {
                                    var item_id = id[0].report_dataset_id + '-' + id[0].data_source_column_id;
                                    var item_position =  0 + cnt;
                                    //var item_label = data_alias + '.' + grouping_columns_arr[cnt];
                                    var item_label = id[0].alias;
                                    var item_nature = fx_data_render_mapping(id[0].datatype_id);
                                    var item_real_name = id[0].column_name_real;
                                    window.register_column(2, item_position, item_id, item_label, item_nature, item_real_name);  
                                }
                                grouping_arr.push(id[0].data_source_column_id); 
                            }

                            //For custom columns
                            if (grouping_columns_arr[cnt].indexOf('.') == -1 && custom_col_info.indexOf(grouping_columns_arr[cnt]) > -1) {
                                var col_name = grouping_columns_arr[cnt];
                                custom_col_detail_remove_arr.push(col_name);
                                var item_position =  0 + cnt;
                                var item_id = col_name;
                                var item_label = col_name;
                                var item_nature = 1;
                                var item_real_name = 'Custom Column';
                                window.register_column(2, item_position, item_id, item_label, item_nature, item_real_name);
                            }
                        }
                        //Delete the removed grouping columns
                        for (cnt = 0; cnt < grouping_item_arr.length; cnt++) {
                            var id = grouping_arr.filter(function(e) {
                                return e == grouping_item_arr[cnt];
                            });
                            if (id == '') {
                                window.delete_column_dragged($('#group-column-region'),grouping_item_arr[cnt]);
                            }
                        }

                        grouping_item_arr = grouping_arr;

                        //For detail custom columns removal
                        //console.log(custom_col_detail_remove_arr)
                        //console.log(custom_col_grp_remove_arr)
                        for (cnt = 0; cnt < custom_col_detail_remove_arr.length; cnt++) {
                            var col_name = custom_col_detail_remove_arr[cnt];
                            window.delete_column_dragged($('#detail-column-region'),col_name);
                        }

                        //For grouping custom columns removal
                        for (cnt = 0; cnt < custom_col_grp_remove_arr.length; cnt++) {
                            var col_name = custom_col_grp_remove_arr[cnt];
                            window.delete_column_dragged($('#group-column-region'),col_name);
                        }

                        
                    } else {
                        window.tablix_type_change(2);

                        //Adding Dragged Detail Columns
                        var detail_arr = new Array();
                        for (cnt = 0; cnt < detail_columns_arr_ct.length; cnt++) {
                            var agg_detail = detail_columns_arr_ct[cnt].split('||||');
                            var id = ds_col_info_gbl.filter(function(e) {
                                //console.log(e.column_name_real +'=='+ agg_detail[1]);
                                return e.column_name_real == agg_detail[1];
                            });
                            if (id != '') {
                                var existance_flag = 0;
                                for (ck_cnt = 0; ck_cnt < detail_item_arr.length; ck_cnt++) {
                                    if (detail_item_arr[ck_cnt] == id[0].data_source_column_id) {
                                        existance_flag = 1;
                                        window.fx_update_sub_aggr(id[0].data_source_column_id, agg_detail);
                                    }
                                }
                                
                                if (existance_flag == 0) {
                                    var item_id = id[0].report_dataset_id + '-' + id[0].data_source_column_id;
                                    var item_position =  0 + cnt;
                                    //var item_label = data_alias + '.' + agg_detail[1];
                                    var item_label = id[0].alias;
                                    var item_nature = fx_data_render_mapping(id[0].datatype_id);
                                    var item_real_name = id[0].column_name_real;
                                    var sub_sec_agg = fx_column_aggregation_mapping(agg_detail[0]);
                                    var sub_sec_agg_label = agg_detail[0];
                                    window.register_column(1, item_position, item_id, item_label, item_nature, item_real_name, sub_sec_agg, sub_sec_agg_label);  
                                }
                                detail_arr.push(id[0].data_source_column_id);    
                            }

                            if (agg_detail[1].indexOf('.') == -1) {
                                var col_name = agg_detail[1];
                                window.fx_update_sub_aggr(col_name, agg_detail);
                            }
                        }
                        
                        //Delete the removed detail columns
                        for (cnt = 0; cnt < detail_item_arr.length; cnt++) {
                            var id = detail_arr.filter(function(e) {
                                return e == detail_item_arr[cnt];
                            });
                            if (id == '') {
                                window.delete_column_dragged($('#detail-column-region'),detail_item_arr[cnt]);
                            }
                        }
                        detail_item_arr = detail_arr;
                       
                        
                        //Adding Dragged Rows Columns
                        var rows_arr = new Array();
                        for (cnt = 0; cnt < rows_columns_arr.length; cnt++) {
                            var id = ds_col_info_gbl.filter(function(e) {
                                return e.column_name_real == rows_columns_arr[cnt];
                            });
                            if (id != '') {
                                var existance_flag = 0;
                                for (ck_cnt = 0; ck_cnt < rows_item_arr.length; ck_cnt++) {
                                    if (rows_item_arr[ck_cnt] == id[0].data_source_column_id) {
                                        existance_flag = 1;
                                    }
                                }

                                if (existance_flag == 0) {
                                    var item_id = id[0].report_dataset_id + '-' + id[0].data_source_column_id;
                                    var item_position =  0 + cnt;
                                    //var item_label = data_alias + '.' + rows_columns_arr[cnt];
                                    var item_label = id[0].alias;
                                    var item_nature = fx_data_render_mapping(id[0].datatype_id);
                                    var item_real_name = id[0].column_name_real;
                                    window.register_column(4, item_position, item_id, item_label, item_nature, item_real_name);  
                                }
                                rows_arr.push(id[0].data_source_column_id); 
                            }
                        }
                        //Delete the removed Rows columns
                        for (cnt = 0; cnt < rows_item_arr.length; cnt++) {
                            var id = rows_arr.filter(function(e) {
                                return e == rows_item_arr[cnt];
                            });
                            if (id == '') {
                                window.delete_column_dragged($('#rows-column-region'),rows_item_arr[cnt]);
                            }
                        }
                        rows_item_arr = rows_arr;
                        
                        
                        //Adding Dragged Cols Columns
                        var cols_arr = new Array();
                        for (cnt = 0; cnt < cols_columns_arr.length; cnt++) {
                            var id = ds_col_info_gbl.filter(function(e) {
                                return e.column_name_real == cols_columns_arr[cnt];
                            });

                            if (id != '') {
                                var existance_flag = 0;
                                for (ck_cnt = 0; ck_cnt < cols_item_arr.length; ck_cnt++) {
                                    if (cols_item_arr[ck_cnt] == id[0].data_source_column_id) {
                                        existance_flag = 1;
                                    }
                                }

                                if (existance_flag == 0) {
                                    var item_id = id[0].report_dataset_id + '-' + id[0].data_source_column_id;
                                    var item_position =  0 + cnt;
                                    //var item_label = data_alias + '.' + cols_columns_arr[cnt];
                                    var item_label = id[0].alias;
                                    var item_nature = fx_data_render_mapping(id[0].datatype_id);
                                    var item_real_name = id[0].column_name_real;
                                    window.register_column(3, item_position, item_id, item_label, item_nature, item_real_name);  
                                }
                                cols_arr.push(id[0].data_source_column_id); 
                            }
                        }
                        //Delete the removed Cols columns
                        for (cnt = 0; cnt < cols_item_arr.length; cnt++) {
                            var id = cols_arr.filter(function(e) {
                                return e == cols_item_arr[cnt];
                            });
                            if (id == '') {
                                window.delete_column_dragged($('#cols-column-region'),cols_item_arr[cnt]);
                            }
                        }
                        cols_item_arr = cols_arr;
                    }
                    window.fx_align_header_column_text_align();
                    window.fx_summary_on_change(summary_on);
                    window.fx_order_columns(column_arr);
                }
            });
        } else if(id == 'general') {
             column_arr = window.get_columns();
                    
            var renderer_type = column_arr['renderer_type'];
            if (renderer_type == 'Table') {
                var custom_col_tr = $('.custom-column', '.data-table');
                
                //console.log(custom_col_tr.html());
                $("[class^=axis_cc").remove();
                var custom_col_info = [];
                if(custom_col_tr.length > 0) {                
                    $.each(custom_col_tr, function(k, tr) {                    
                        custom_col_info.push(
                            {
                                'item_id' : $('.column-alias', $(tr)).val().replace(/ /g,''),
                                'column_alias' : $('.column-alias', $(tr)).val()
                            }
                        );
                        
                    })
                    }
                    var col_tr = $('#detail-column-region').find('.clone'); 
                    var col_info = [];
                    $.each(col_tr, function(k, tr) {    
                        if ($(tr).hasClass('custom-column')) {
                            col_info.push($(tr).find('span.column').text()+'(CC)');
                        } else {
                            col_info.push($(tr).find('span.column-real-name').text());
                        }
                        
                    })

                    var group_tr = $('#group-column-region').find('.clone');
                    var group_info = [];
                    $.each(group_tr, function(k, tr) {    
                        if ($(tr).hasClass('custom-column')) {
                            group_info.push($(tr).find('span.column').text()+'(CC)');
                        } else {
                            group_info.push($(tr).find('span.column-real-name').text());
                        }
                    })
                    
                    window.fx_adjust_custom_columns(custom_col_info,col_info,group_info);
                
            } else {
                // Cross tab
                var custom_col_tr = $('.custom-column', '.data-table');
                
                //console.log(custom_col_tr.html());
                $("[class^=axis_cc").remove();
                var custom_col_info = [];
                var col_info = [];
                var col_info_agg = [];
                if(custom_col_tr.length > 0) {                
                    $.each(custom_col_tr, function(k, tr) {                    
                        custom_col_info.push(
                            {
                                'item_id' : $('.column-alias', $(tr)).val().replace(/ /g,''),
                                'column_alias' : $('.column-alias', $(tr)).val()
                            }
                        );
                        
                    })
                }
                    var col_tr = $('#detail-column-region').find('.clone'); 
                    
                    $.each(col_tr, function(k, tr) {    
                        if ($(tr).hasClass('custom-column')) {
                            col_info.push($(tr).find('span.column').text()+'(CC)');
                        } else {
                            col_info.push($(tr).find('span.column-real-name').text());
                        }  
                            col_info_agg.push(get_aggregation_label($(tr).find('select.aggregations-list').val()));                      
                            //col_info_agg.push('Maximum');                      
                    })


                    var group_tr = $('#rows-column-region').find('.clone');
                    var group_info = [];
                    $.each(group_tr, function(k, tr) {    
                        if ($(tr).hasClass('custom-column')) {
                            group_info.push($(tr).find('span.column').text()+'(CC)');
                        } else {
                            group_info.push($(tr).find('span.column-real-name').text());
                        }
                    })

                    var ver_tr = $('#cols-column-region').find('.clone');
                    var ver_info = [];
                    $.each(ver_tr, function(k, tr) {    
                        if ($(tr).hasClass('custom-column')) {
                            ver_info.push($(tr).find('span.column').text()+'(CC)');
                        } else {
                            ver_info.push($(tr).find('span.column-real-name').text());
                        }
                    })

                window.fx_adjust_custom_columns_crosstab(custom_col_info,col_info,col_info_agg,ver_info,group_info);
            }
            //End of Cross tab for General
        }     
    }


    function get_aggregation_label(agg_id) {
        var agg_label = '';
        switch(agg_id) {
            case '1':
                agg_label = 'Average';
                break;
            case '8':
                agg_label = 'Maximum';
                break;
            case '9':
                agg_label = 'Minimum';
                break;
            default:
                agg_label = 'Sum';
                break;

        }
        return agg_label;
    }
    
</script>
</html>