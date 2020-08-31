<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  
        require_once('../../../adiha.php.scripts/components/include.file.v3.php');
        require_once('../../../adiha.php.scripts/components/include.ssrs.reporting.files.php'); 
        require_once '../report_manager_dhx/report.global.vars.php'; 
    ?>
</head>
<body>
    <?php     

    //print '<pre>';print_r($_REQUEST);print '</pre>';die();
    $form_name = 'form_maintain_static_data';
    $php_script_loc = $app_php_script_loc;
    $app_user_loc = $app_user_name;
    
    $process_id = get_sanitized_value($_POST['process_id'] ?? '');
    $item_flag = get_sanitized_value($_POST['item_flag'] ?? '');
    $report_id = get_sanitized_value($_POST['report_id'] ?? '');
    $ri_info_obj = isset($_POST['ri_info_obj']) ? json_decode($_POST['ri_info_obj']) : '';
    $item_name = $ri_info_obj->{'page_name'} . '_chart';
    $item_id = $ri_info_obj->{'item_id'};
    $dataset_id = '';
    $data_source_id = '';
    $dataset_alias = '';
    $page_break = '';
    $chart_type_id = 3;


    $sp_url = "EXEC spa_rfx_report_dataset_dhx @flag = 'g', @process_id='$process_id'";
    $csv_file_name = readXMLURL2($sp_url);

    
    $existing_columns = array();
    $arr_x = array();
    $arr_y = array();
    $arr_z = array();
    $arr_x_pivot = array();
    $arr_y_pivot = array();
    $arr_z_pivot = array();
    
    if ($item_flag == 'u') {
        $chart_info_url = "EXEC spa_rfx_chart_dhx @flag='s', @process_id='$process_id', @report_page_chart_id='$item_id'";
        $chart_info = readXMLURL2($chart_info_url);
        if (is_array($chart_info) && sizeof($chart_info) > 0) {
            $dataset_id = $chart_info[0]['root_dataset_id'];
            $item_name = $chart_info[0]['name'];
            $dataset_alias = $chart_info[0]['dataset_alias'];
            $data_source_id = $chart_info[0]['data_source_id'];
            $y_axis_caption = $chart_info[0]['y_axis_caption'];
            $x_axis_caption = $chart_info[0]['x_axis_caption'];
            $page_break = $chart_info[0]['page_break'];
            $chart_properties_jsoned = ($chart_info[0]['chart_properties']); //will be used later, don't delete
            $chart_properties = json_decode($chart_properties_jsoned);
            $chart_type_id = $chart_info[0]['type_id'];
        }
        
        $updated_values_url = "EXEC spa_rfx_chart_dhx @flag='a', @process_id='$process_id', @report_page_chart_id='$item_id'";
        $updated_values = readXMLURL2($updated_values_url);
        //echo '<pre>'.print_r($updated_values);exit;

        if (is_array($updated_values) && sizeof($updated_values) > 0) {
            foreach ($updated_values as $data) {
                $data['chart_properties'] = '';
                array_push($existing_columns, $data);
                if($data['placement'] == 3) {
                    array_push($arr_x, $data['column_name_real']);
                    array_push($arr_x_pivot, $data['column_name_real_pivot']);
                } else if($data['placement'] == 1) {
                    array_push($arr_y, $data['column_name_real']);
                    array_push($arr_y_pivot, $data['column_name_real_pivot']);
                } else if($data['placement'] == 2) {
                    array_push($arr_z, $data['column_name_real']);
                    array_push($arr_z_pivot, $data['column_name_real_pivot']);
                }
            }
        }
        $existing_columns_jsoned = json_encode($existing_columns);
        
        $pivot_col_list['xaxis'] = implode(',', $arr_x_pivot);
        $pivot_col_list['yaxis'] = implode(',', $arr_y_pivot);
        $pivot_col_list['series'] = implode(',', $arr_z_pivot);
        
        $arr_x_json = json_encode($arr_x);
        $arr_y_json = json_encode($arr_y);
        $arr_z_json = json_encode($arr_z);
        //echo '<pre>'.print_r($pivot_col_list);exit();
        
    }
    
    
    $form_namespace = 'rm_chart';
    $layout_obj = new AdihaLayout();
    $layout_json = '[
        {id: "a", header:false, height:120}, 
        {id: "b", header:false}
    ]';      
    echo $layout_obj->init_layout('layout', '', '2E', $layout_json, $form_namespace);
    echo $layout_obj->attach_event('', 'onDock', $form_namespace . '.on_dock_report_event');
    echo $layout_obj->attach_event('', 'onUnDock', $form_namespace . '.on_undock_report_event');

    // attach menu
    $menu_json = '[{id: "save", img:"save.gif", img_disabled:"save.gif", text:"Save", title:"Save"}]';
    $menu_obj = new AdihaMenu();
    echo $layout_obj->attach_menu_cell("menu_chart", "a");  
    echo $menu_obj->init_by_attach("menu_chart", $form_namespace);
    echo $menu_obj->load_menu($menu_json);
    echo $menu_obj->attach_event('', 'onClick', $form_namespace . '.menu_click');

    // attach filter form
    $form_chart = new AdihaForm();
    $form_chart_name = 'datasource_form';
    echo $layout_obj->attach_form($form_chart_name, 'a');
    
    $sp_url = "EXEC spa_rfx_report_dataset_dhx @flag = 's', @process_id='$process_id'";
    $dataset_dropdown_json = $form_chart->adiha_form_dropdown($sp_url, 0, 2, true, $dataset_id);
    //echo print_r($dataset_dropdown_json);
    $dataset_array = readXMLURL2($sp_url);
    
    $sp_url = "EXEC spa_rfx_report_dataset_dhx @flag = 'h', @process_id='$process_id'";
    $ds_col_info = readXMLURL2($sp_url);
    
    $json_page_break_opt = '
    [
        {value: "0", label: "None"},
        {value: "1", label: "Before Chart"},
        {value: "2", label: "After Chart"},
        {value: "3", label: "Before and After Chart"}
    ]
    ';
    
    $form_json = '
    [ 
        {"type": "settings", "position": "label-top", "offsetLeft": 10},
        {type:"combo", name: "dataset_id", label:"Dataset", "labelWidth":150, required:true, filtering:true, "inputWidth":180, "options": ' . $dataset_dropdown_json . '}, {type:"newcolumn"},
        {type:"input", name: "ds_alias", hidden: true, value: "' . $dataset_alias. '", label:"Data Source Alias", "labelWidth":150, required:false, "inputWidth":150}, {type:"newcolumn"},
        {type:"input", name: "ri_name", value: "' . $item_name . '", label:"Report Item Name", "labelWidth":150, required:true, "inputWidth":150}, {type:"newcolumn"},
        {type:"combo", name: "page_break", label:"Page Break", "labelWidth":90, required:false, "inputWidth":95, options: ' . $json_page_break_opt . ' }, {type:"newcolumn"},
    ]
    ';

    $form_chart->init_by_attach($form_chart_name, $form_namespace);
    echo $form_chart->load_form($form_json);    
    echo $form_chart->attach_event('', 'onChange', $form_namespace . '.form_change');

    //Attach Tabbar
    $tab_json =   '[ 
                    {id:"general", text:"General", active:  true}, 
                    {id:"advance", text:"Advance"}
                    ]';  
    echo $layout_obj->attach_tab_cell('chart_tab','b',$tab_json);
    echo $layout_obj->close_layout();
    
    
    //var_dump($_POST);
    ?> 
</body>
<!--<script type="text/javascript" src="<?php echo $app_php_script_loc; ?>components/ui/jquery-ui.min.js"></script>-->
<script type="text/javascript"> 
    parent.dhx_wins.window('window_ri').maximize();
    google.load("visualization", "1", {packages:["corechart", "charteditor"]});
    var ri_info_obj = $.parseJSON('<?php echo json_encode($ri_info_obj); ?>');
    var process_id = '<?php echo $process_id; ?>';
    var report_id = '<?php echo $report_id; ?>';
    var item_flag = '<?php echo $item_flag; ?>';
    var dataset_array = $.parseJSON('<?php echo json_encode($dataset_array); ?>');
    var ds_col_info_gbl = $.parseJSON('<?php echo json_encode($ds_col_info, JSON_HEX_APOS); ?>');
    var csv_file_array = $.parseJSON('<?php echo json_encode($csv_file_name, JSON_HEX_APOS); ?>');
    var update_detail_ri = '';
    var form_ri = {};
    var pivot_col_list = {
        series: '',
        xaxis: '',
        yaxis: '',
        detail_columns: '',
        grouping_columns: ''
    };
    var chart_types_arr = [<?php echo json_encode($rfx_chart_type); ?>];
    var chart_type_id = '<?php echo $chart_type_id; ?>';
    var item_name = '<?php echo $item_name; ?>';
    var post_data = '';
    var ajax_url = '';
    
    
    //console.log(chart_type_id);
    $(function() {
        layout_b = rm_chart.layout.cells('b');
        if(item_flag == 'u') {
            form_ri = rm_chart.datasource_form;
            //console.log(update_detail_ri);
            
            form_ri.getCombo('page_break').setComboValue(<?php echo $page_break; ?>);
            pivot_col_list['xaxis'] = '<?php echo $pivot_col_list['xaxis'] ?? ''; ?>';
            pivot_col_list['yaxis'] = '<?php echo $pivot_col_list['yaxis'] ?? ''; ?>';
            pivot_col_list['series'] = '<?php echo $pivot_col_list['series'] ?? ''; ?>';
            
        }
        rm_chart.form_change('dataset_id');
        
        var tabbar_obj = rm_chart.layout.cells('b').getAttachedObject();
        tabbar_obj.attachEvent("onTabClick", function(id, lastId){
            rm_chart.fx_chart_advance_click(id, lastId);
        });
    });

    rm_chart.form_change = function(name, value, state) {
        var tabbar_obj = rm_chart.layout.cells('b').getAttachedObject();
        //layout_b.progressOn();
        //var file_path = '<?php echo $report_views_url_path;?>';
        var file_path = js_php_path + 'dev/shared_docs/report_manager_views/';

        var cmb_obj = rm_chart.datasource_form.getCombo('dataset_id');
        
        if(cmb_obj.getSelectedValue() == '') {
            console.log('***blank dataset selection ***');
            tabbar_obj.cells('general').detachObject(true);
            tabbar_obj.cells('advance').detachObject(true);
            return;
            
        }
        
        if (name == 'dataset_id') {

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
            var renderer_type = rm_chart.fx_get_chart_type(chart_type_id, 'get_label');
            
            var full_file_name = file_path + '/' + selected_file_info[0]['csv_file_name'];
            var aggregators = 'Sum';
            
            tabbar_obj.forEachTab(function(tab){
                var tab_name = tab.getText();
                if (tab_name == 'General') {
                    var post_param = {
                        file_path: full_file_name,
                        report_type: 'chart',
                        renderer_type: renderer_type,
                        aggregators: aggregators,
                        col_list: JSON.stringify(pivot_col_list),
                        call_from: 'report_manager_dhx',
                        dataset_id: rm_chart.datasource_form.getItemValue('dataset_id'),
                        dataset_array: JSON.stringify(dataset_array),
                        process_id: process_id
                    };
                    //console.log(post_param);

                    var url = js_php_path + 'pivot.template.php';
                    tab.attachURL(url, true, post_param);
                } else if (tab_name == 'Advance') {
                    var dataset_alias = '<?php echo $dataset_alias; ?>';
                    var post_param = {
                        mode: item_flag,
                        report_resultset_id: '',
                        report_id: report_id,
                        item_id: ri_info_obj.item_id,
                        process_id: process_id,
                        renderer_type: renderer_type,
                        page_id: '',
                        left: '',
                        top: '',
                        width: '',
                        height: '',
                        dataset_alias:dataset_alias,
                        dataset_id: rm_chart.datasource_form.getItemValue('dataset_id'),
                        dataset_array: JSON.stringify(dataset_array)
                    };
                    var url = app_form_path  + '_reporting/report_manager_dhx/report.manager.dhx.chart.advance.php';
                    tab.attachURL(url, true, post_param);
                }
            });
        }
    }

    /**
     * [undock_details Undock detail layout]
     */
    rm_chart.undock_reports = function() {
        var layout_obj = rm_chart.layout;
        layout_obj.cells("b").undock(300, 300, 900, 700);
        layout_obj.dhxWins.window("b").button("park").hide();
        layout_obj.dhxWins.window("b").maximize();
        layout_obj.dhxWins.window("b").centerOnScreen();
    }

    /**
     * [on_dock_report_event On dock event]
     * @param  {[type]} id [Cell id]
     */
    rm_chart.on_dock_report_event = function(id) {
        if (id == 'b') {            
            $(".undock_report").show();
        }
    }
    /**
     * [on_undock_report_event On undock event]
     * @param  {[type]} id [Cell id]
     */
    rm_chart.on_undock_report_event = function(id) {
        if (id == 'b') {
            $(".undock_report").hide();            
        }            
    }

    /**
     * [menu_click Menu click]
     * @param  {[type]} id [id of menu]
     */
    rm_chart.menu_click = function(id) {
        switch (id) {
            case "save":
                var form_obj = rm_chart.datasource_form;
                if(validate_form(form_obj)) {
                    columns_array_gbl = window.get_columns();
                    //console.log(columns_array_gbl['renderer_type']);
                    chart_type_id = rm_chart.fx_get_chart_type(columns_array_gbl['renderer_type'], 'get_id');
                                        
                    if(columns_array_gbl['xaxis'] == '') {
                        dhtmlx.message({
                            title: 'Error',
                            type: 'alert-warning',
                            text: 'Please select columns on x-axis.'
                        });
                    } else if(columns_array_gbl['yaxis'].split('||||')[1] == '') {
                        dhtmlx.message({
                            title: 'Error',
                            type: 'alert-warning',
                            text: 'Please select columns on for aggregation.'
                        });
                    } else {
                        rm_chart.fx_chart_advance_click('advance');
                        var form_obj = rm_chart.datasource_form;
                        rm_chart.fx_save_chart_info(form_obj.getItemValue('dataset_id'));
                        //rm_chart.fx_save_dataset_info(form_obj);
                    }
                }
                
                
                break;
        }
    }
    //function to get chart type
    rm_chart.fx_get_chart_type = function(input_value, get_what) {
        var return_value;
        if(get_what == 'get_id') {
            switch(input_value) {
                case 'Line':
                    return_value = 3; //to do 
                    break;
                case 'Bar':
                    return_value = 2; //to do 
                    break;
                case 'Column':
                    return_value = 19; //to do 
                    break;
                case 'Stacked Column':
                    return_value = 28; //to do 
                    break;
                case 'Pie':
                    return_value = 1; //to do 
                    break;
                case 'Pie 3D':
                    return_value = 43; //to do 
                    break;
                case 'Donut':
                    return_value = 39; //to do 
                    break;
                case 'Area':
                    return_value = 4; //to do 
                    break;
                case 'Scatter':
                    return_value = 37; //to do 
                    break;
                default: return_value = 3;
            }
        } else {
            switch(input_value) {
                case 3:case '3':
                    return_value = 'Line'; //to do 
                    break;
                case 2:case '2':
                    return_value = 'Bar'; //to do 
                    break;
                case 19:case '19':
                    return_value = 'Column'; //to do 
                    break;
                case 28:case '28':
                    return_value = 'Stacked Column'; //to do 
                    break;
                case 1:case '1':
                    return_value = 'Pie'; //to do 
                    break;
                case 43:case '43':
                    return_value = 'Pie 3D'; //to do 
                    break;
                case 39:case '39':
                    return_value = 'Donut'; //to do 
                    break;
                case 4:case '4':
                    return_value = 'Area'; //to do 
                    break;
                case 37:case '37':
                    return_value = 'Scatter'; //to do 
                    break;
                default: return_value = 'Line';
            }
        }
        
        return return_value;
    };
    
    //function to save chart info
    rm_chart.fx_save_chart_info = function(dataset_id) {
        
        var item_name = rm_chart.datasource_form.getItemValue('ri_name');
        var cmb_page_break = rm_chart.datasource_form.getItemValue('page_break');
        
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
        adiha_post_data('return_json', post_data, '', '', 'rm_chart.fx_extract_ds_col_id_cb', false);
        
        var chart_xml_obj = save_chart_xml();
        //console.log(chart_xml_obj);return;
        
        post_data = {
            'action': 'spa_rfx_chart_dhx',
            'flag': 'u',
            'process_id': process_id,
            'page_id': ri_info_obj.page_id,
            'root_dataset_id': dataset_id,
            'chart_name': item_name,
            'chart_type_id': chart_type_id,
            'top': ri_info_obj.top,
            'width': ri_info_obj.width,
            'height': ri_info_obj.height,
            'xml': chart_xml_obj.xml_rs_columns,
            'left': ri_info_obj.left,
            'report_page_chart_id': ri_info_obj.item_id,
            'y_axis_caption': (chart_type_id == 1 ? '' : chart_xml_obj.chart_properties['axes_caption']['y'].caption),
            'x_axis_caption': (chart_type_id == 1 ? '' : chart_xml_obj.chart_properties['axes_caption']['x'].caption),
            'page_break': cmb_page_break,
            'chart_properties': JSON.stringify(chart_xml_obj.chart_properties)
        };
        //console.log(post_data);return;
        
        adiha_post_data('return_json', post_data, '', '', 'rm_chart.fx_save_chart_info_cb');
        
        /*
        $.each(columns_array_gbl['xaxis'].split(','), function(index, value) {
            
            var dsc_obj = $(json_ds_col_id_gbl).filter(function(i,n) {
                //console.log((n.name +':' +compare_value ));
                return (n.name == value);
            });
            set_save_axes_params('', 'x');
        });
        $.each(columns_array_gbl['yaxis'].split(','), function(index, value) {
            
            var dsc_obj = $(json_ds_col_id_gbl).filter(function(i,n) {
                //console.log((n.name +':' +compare_value ));
                return (n.name == value);
            });
            set_save_axes_params('', 'y');
        });
        $.each(columns_array_gbl['zaxis'].split(','), function(index, value) {
            
            var dsc_obj = $(json_ds_col_id_gbl).filter(function(i,n) {
                //console.log((n.name +':' +compare_value ));
                return (n.name == value);
            });
            set_save_axes_params('', 'z');
        });
        */
        
        
        /* HARDCODED VALUES FOR CHART ADVANCE PROPERTIES */
        /*
        set_save_axes_params('', 'x');
        set_save_axes_params('', 'y');
        set_save_axes_params('', 'z');
        set_save_axes_caption_params('', 'x');
        set_save_axes_caption_params('', 'y');
        set_save_axes_caption_params('', 'z');
        
        $.each(columns_array_gbl['xaxis'].split(','), function(index, value) {
            if(columns_array_gbl['xaxis'] == '')
                return false;
            var dsc_obj = $(json_ds_col_id_gbl).filter(function(i,n) {
                //console.log((n.name +':' +compare_value ));
                return (n.name == value);
            });
            var param_obj = {
                column_id: dsc_obj[0].column_id,
                dataset_id: dataset_id,
                column_alias: dsc_obj[0].name
            }
            set_save_params(3, '', (index+1), param_obj);
        });
        $.each(columns_array_gbl['series'].split(','), function(index, value) {
            if(columns_array_gbl['series'] == '')
                return false;
            var dsc_obj = $(json_ds_col_id_gbl).filter(function(i,n) {
                //console.log((n.name +':' +compare_value ));
                return (n.name == value);
            });
            var param_obj = {
                column_id: dsc_obj[0].column_id,
                dataset_id: dataset_id,
                column_alias: dsc_obj[0].name
            }
            set_save_params(2, '', (index+1), param_obj);
        });
        $.each(columns_array_gbl['yaxis'].split(','), function(index, value) {
            var detail_col_name = '';
            var detail_col_agg = '';
            var compare_value = value;
            if(columns_array_gbl['yaxis'] == '') {
                return false;
            } else {
                detail_col_name = columns_array_gbl['yaxis'].split('||||')[1];
                detail_col_agg = columns_array_gbl['yaxis'].split('||||')[0];
                compare_value = detail_col_name;
            }
            var dsc_obj = $(json_ds_col_id_gbl).filter(function(i,n) {
                //console.log((n.name +':' +compare_value ));
                return (n.name == compare_value);
            });
            var param_obj = {
                column_id: dsc_obj[0].column_id,
                dataset_id: dataset_id,
                column_alias: dsc_obj[0].name
            }
            set_save_params(1, '', (index+1), param_obj);
        });
        
        xml_rs_columns += '</Root>';
        */
        
        /* HARDCODED VALUES FOR CHART ADVANCE PROPERTIES */
        
    };
    var set_save_axes_params = function(current_context,axes) {
        
        stack = {};
        stack.render_as = (axes == 'y' ? '2' : '1');//$('.renderas-list', current_context).val();
        stack.column_template = '-1';//$('.current-template-option', current_context).val();

        switch (stack.render_as) {
            case '0':
            case '1'://Text, HTML
                stack.currency = '';
                stack.thousand_list = '';
                stack.rounding = '';
                stack.date_format = '';
                break;
            case '2'://Number
                stack.currency = '';
                stack.thousand_list = $('.thousand-list', current_context).val();
                stack.rounding = $('.rounding-list', current_context).val();
                stack.date_format = '';
                break;
            case '3'://Currency
                stack.currency = $('.currency-list', current_context).val();
                stack.thousand_list = $('.thousand-list', current_context).val();
                stack.rounding = $('.rounding-list', current_context).val();
                stack.date_format = '';
                break;
            case '4'://Date
                stack.currency = '';
                stack.thousand_list = '';
                stack.rounding = '';
                stack.date_format = $('.date-format-list', current_context).val();
                break;

            case '5':
            case '6'://Percentage, Scientific
                stack.currency = '';
                stack.thousand_list = '';
                stack.rounding = $('.rounding-list', current_context).val();
                stack.date_format = ''
                break;
        }
            
        stack.font = 'Tahoma'; //$('.font-list', current_context).val();
        stack.font_size = '8';//$('.font-size-list', current_context).val();
        stack.bold_style = 0;//$('.bold-checkbox', current_context).is(':checked') ? 1 : 0;
        stack.italic_style = 0;//$('.italic-checkbox', current_context).is(':checked') ? 1 : 0;
        stack.underline_style = 0;//$('.underline-checkbox', current_context).is(':checked') ? 1 : 0;
        stack.text_align = 'Left';//$('.text-align-list', current_context).val();
        stack.text_color = '#000000';//$('.text-color-list', current_context).val();

        chart_properties['axes'][axes] = stack;
    }
    var set_save_axes_caption_params = function(current_context,axes) {
        stack = {};
        stack.font = 'Tahoma';//$('.font-list', current_context).val();
        stack.font_size = '8';//$('.font-size-list', current_context).val();
        stack.bold_style = 0;//$('.bold-checkbox', current_context).is(':checked') ? 1 : 0;
        stack.italic_style = 0;//$('.italic-checkbox', current_context).is(':checked') ? 1 : 0;
        stack.underline_style = 0;//$('.underline-checkbox', current_context).is(':checked') ? 1 : 0;
        stack.text_align = 'Left';//$('.text-align-list', current_context).val();
        stack.text_color = '#000000';//$('.text-color-list', current_context).val();
        chart_properties['axes_caption'][axes] = stack;
    }
    /*prepare data for save logic*/
    var set_save_params = function(placement, current_context, item_order, param_obj) {
        stack = {};
        stack.placement = placement;
        stack.column_id = param_obj.column_id;//$('.column-id', current_context).val();
        stack.dataset_id = param_obj.dataset_id;//$('.column-dataset-id', current_context).val();
        stack.column_alias = param_obj.column_alias;//$('.column-alias', current_context).val();

        if (stack.column_alias == 'NULL' || stack.column_alias == '') {
            error = 1;
            return;
        }

        stack.function_name = '';//$('.column-function', current_context).val();
        //stack.function_name = stack.function_name.replace(/'/g, "''");

        //stack.aggregation = (stack.placement == '1') ? $('.aggregations-list', current_context).val() : '';
        stack.aggregation = (stack.placement == '1') ? '13' : '';
        
        //if(stack.placement == '1' && $('#chart-type :selected').data('category')== '8')
//            stack.render_as_line = ( $('.render-as-line', current_context).is(':checked')) ? 1 : 0;
//        else
//            stack.render_as_line = 0;
        stack.render_as_line = 0;

        //if (stack.placement == '3') {
//            stack.sort_priority = $('.sort-priority', current_context).val();
//            stack.sort_to = $('.sort-to-list', current_context).val();
//        } else {
//            stack.sort_priority = '';
//            stack.sort_to = '';
//        }
        stack.sort_priority = '';
        stack.sort_to = '';

        //stack.custom_field = (current_context.hasClass('custom-column')) ? '1' : '0';
        stack.custom_field = '0';
        if (stack.custom_field == '1')
            stack.column_id = '';
        
        

        xml_rs_columns += '<PSRecordset DataSetID="' + stack.dataset_id
                        + '" ColumnID="' + stack.column_id
                        + '" ColumnAlias="' + escapeXML(stack.column_alias)
                        + '" FunctionName="' + escapeXML(stack.function_name)
                        + '" Aggregation="' + stack.aggregation
                        + '" SortPriority="' + stack.sort_priority
                        + '" SortTo="' + stack.sort_to
                        + '" CustomField="' + stack.custom_field
                        + '" ColumnOrder="' + item_order
                        + '" Placement="' + stack.placement
                        + '" RenderAsLine="' + stack.render_as_line
                        + '"></PSRecordset>';
    }
        
    rm_chart.fx_save_chart_info_cb = function(result) {
        
        json_obj = $.parseJSON(result);
        if(json_obj[0].errorcode == 'Success') {
            parent.success_call('Chart info saved.', 'error');
            var item_arr = new Array();
            var item_id = json_obj[0].recommendation;
            var item_name = rm_chart.datasource_form.getItemValue('ri_name');
            item_arr.push(item_id, '1', item_name);
            
            if(item_flag == 'i') {
                parent.ifr_dhx.ifr_tab[process_id].ifr_page.fx_add_report_item(ri_info_obj.item_type, item_arr);
                parent.ifr_dhx.ifr_tab[process_id].div_obj.attr('item_id', item_id);
            } else {
                parent.ifr_dhx.ifr_tab[process_id].ifr_page.fx_set_item_name(ri_info_obj.report_item_id, item_arr[2]);
            }
            
            try {
                parent.dhx_wins.window('window_ri').close();
            } catch (e) {
                alert('Exception: ' + e);
            }
            
            
            
        } else {
            console.log('***error on saving chart ***');
            dhtmlx.message({
                title: "Error",
                type: "alert-error",
                text: json_obj[0].message,
            });
        }
    };
    var json_ds_col_id_gbl;
    rm_chart.fx_extract_ds_col_id_cb = function(result) {
        json_obj = $.parseJSON(result);
        //console.dir(json_obj);
        json_ds_col_id_gbl = json_obj;
          
    };
    
    fx_renderer_type_change = function() {
        
    }
    
    var xaxis_item_arr = new Array();
    var x_cols = '<?php echo $arr_x_json ?? ''; ?>';
    if (x_cols != '') {
        x_cols = JSON.parse(x_cols);
        for (ck_cnt = 0; ck_cnt < x_cols.length; ck_cnt++) {
            xaxis_item_arr.push(x_cols[ck_cnt]);
        }
    }
    
    var yaxis_item_arr = new Array();
    var y_cols = '<?php echo $arr_y_json ?? ''; ?>';
    if (y_cols != '') {
        y_cols = JSON.parse(y_cols);
        for (ck_cnt = 0; ck_cnt < y_cols.length; ck_cnt++) {
            yaxis_item_arr.push(y_cols[ck_cnt]);
        }
    }
    
    var series_item_arr = new Array();
    var z_cols = '<?php echo $arr_z_json ?? ''; ?>';
    if (z_cols != '') {
        z_cols = JSON.parse(z_cols);
        for (ck_cnt = 0; ck_cnt < z_cols.length; ck_cnt++) {
            series_item_arr.push(z_cols[ck_cnt]);
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
            default:
                return 13;
       }
    }
    
    var adv_click_cnt = 0;
    rm_chart.fx_chart_advance_click = function(id, lastId) {
        if (id == 'advance' && rm_chart.datasource_form.getCombo('dataset_id').getSelectedValue() != '') {
            column_arr = window.get_columns();
            var renderer_type = column_arr['renderer_type'];
            var xaxis = column_arr['xaxis'];
            var yaxis = column_arr['yaxis'];
            var series = column_arr['series'];
            
            var xaxis_columns_arr = xaxis.split(',');
            var yaxis_columns_arr = yaxis.split(',');
            var series_columns_arr = series.split(',');
            
            //Getting the json of column_id and column_name
            var form_obj = rm_chart.datasource_form;
            var dataset_id = form_obj.getItemValue('dataset_id');
            var filtered_ds = dataset_array.filter(function(e) {
                return e.report_datasets_id == dataset_id;
            });
            var data_alias = filtered_ds[0].alias;
            
            window.fx_chart_type_change(rm_chart.fx_get_chart_type(renderer_type, 'get_id'));
            window.fx_set_dataset_id(dataset_id);
            
            //Adding Dragged xaxis
            var xaxis_arr = new Array();
            for (cnt = 0; cnt < xaxis_columns_arr.length; cnt++) {
                var id = ds_col_info_gbl.filter(function(e) {
                    //console.log(e.column_name_real +'=='+ xaxis_columns_arr[cnt]);
                    return e.column_name_real == xaxis_columns_arr[cnt];
                });
                
                if (id != '') {
                    var existance_flag = 0;
                    for (ck_cnt = 0; ck_cnt < xaxis_item_arr.length; ck_cnt++) {
                        if (xaxis_item_arr[ck_cnt] == xaxis_columns_arr[cnt] || xaxis_item_arr[ck_cnt] == id[0].data_source_column_id) {
                            existance_flag = 1;
                        }
                    }
                    
                    if (existance_flag == 0) {
                        var location = 2;
                        var item_id = id[0].report_dataset_id + '-' + id[0].data_source_column_id;
                        var item_real_name = id[0].column_name_real;
                        //var item_label = data_alias + '.' + xaxis_columns_arr[cnt];
                        var item_label = id[0].alias;
                        //var alias = xaxis_columns_arr[cnt];
                        var alias = id[0].alias.split('.')[1];
                        window.register_column_dragged(location, item_id, item_real_name, item_label, alias, '', '');  
                    }
                    xaxis_arr.push(id[0].data_source_column_id);       
                }
            }
            //Delete the removed xaxis columns
            for (cnt = 0; cnt < xaxis_item_arr.length; cnt++) {
                var id = xaxis_arr.filter(function(e) {
                    if (adv_click_cnt == 0) {
                        var iid = ds_col_info_gbl.filter(function(e) {
                            return e.column_name_real == xaxis_item_arr[cnt];
                        });
                        if(iid.length == 0) return false;
                        else return e == iid[0].data_source_column_id;
                    } else {
                        return e == xaxis_item_arr[cnt];
                    }
                });


                if (id == '') {
                    if (adv_click_cnt == 0) {
                        var iid = ds_col_info_gbl.filter(function(e) {
                            //console.log(e.column_name_real +'=='+ xaxis_item_arr[cnt]);
                            return e.column_name_real == xaxis_item_arr[cnt];
                        });
                        
                        //var item_id = id[0].report_dataset_id + '-' + iid[0].data_source_column_id;
                        var item_id = dataset_id + '-' + iid[0].data_source_column_id;
                    } else {
                        //var item_id = id[0].report_dataset_id + '-' + xaxis_item_arr[cnt];
                        var item_id = dataset_id + '-' + xaxis_item_arr[cnt];
                    }
                    window.delete_column_dragged($('#category-columns-rs-table'),item_id);
                }
            }
            xaxis_item_arr = xaxis_arr;
            
            //Adding Dragged yaxis
            var yaxis_arr = new Array();
            for (cnt = 0; cnt < yaxis_columns_arr.length; cnt++) {
                var agg_detail = yaxis_columns_arr[cnt].split('||||');
                var agg_label = agg_detail[0];
                var agg_id = fx_column_aggregation_mapping(agg_detail[0]);
                
                var id = ds_col_info_gbl.filter(function(e) {
                    return e.column_name_real == agg_detail[1];
                });
                if (id != '') {
                    var existance_flag = 0;
                    for (ck_cnt = 0; ck_cnt < yaxis_item_arr.length; ck_cnt++) {
                        if (yaxis_item_arr[ck_cnt] == agg_detail[1] || yaxis_item_arr[ck_cnt] == id[0].data_source_column_id) {
                            existance_flag = 1;
                        }
                    }
                    if (existance_flag == 0) {
                        var location = 1;
                        var item_id = id[0].report_dataset_id + '-' + id[0].data_source_column_id;
                        var item_real_name = id[0].column_name_real;
                        //var item_label = data_alias + '.' + agg_detail[1];
                        var item_label = id[0].alias;
                        //var alias = agg_detail[1];
                        var alias = id[0].alias.split('.')[1];
                        window.register_column_dragged(location, item_id, item_real_name, item_label, alias, agg_id, agg_label);  
                    }
                    yaxis_arr.push(id[0].data_source_column_id);       
                }
            }
            //Delete the removed yaxis columns
            for (cnt = 0; cnt < yaxis_item_arr.length; cnt++) {
                var id = yaxis_arr.filter(function(e) {
                    if (adv_click_cnt == 0) {
                        var iid = ds_col_info_gbl.filter(function(e) {
                            return e.column_name_real == yaxis_item_arr[cnt];
                        });
                        if(iid.length == 0) return false;
                        else return e == iid[0].data_source_column_id;
                    } else {
                        return e == yaxis_item_arr[cnt];
                    }
                });
                if (id == '') {
                    if (adv_click_cnt == 0) {
                        var iid = ds_col_info_gbl.filter(function(e) {
                            return e.column_name_real == yaxis_item_arr[cnt];
                        });
                        //var item_id = id[0].report_dataset_id + '-' + iid[0].data_source_column_id;
                        var item_id = dataset_id + '-' + iid[0].data_source_column_id;
                    } else {
                        //var item_id = id[0].report_dataset_id + '-' + yaxis_item_arr[cnt];
                        var item_id = dataset_id + '-' + yaxis_item_arr[cnt];
                    }
                    window.delete_column_dragged($('#data-columns-rs-table'),item_id);
                }
            }
            yaxis_item_arr = yaxis_arr;
            
            //Adding Dragged series
            var series_arr = new Array();
            for (cnt = 0; cnt < series_columns_arr.length; cnt++) {
                var id = ds_col_info_gbl.filter(function(e) {
                    return e.column_name_real == series_columns_arr[cnt];
                });
                if (id != '') {
                    var existance_flag = 0;
                    for (ck_cnt = 0; ck_cnt < series_item_arr.length; ck_cnt++) {
                        if (series_item_arr[ck_cnt] == series_columns_arr[cnt] || series_item_arr[ck_cnt] == id[0].data_source_column_id) {
                            existance_flag = 1;
                        }
                    }
                    if (existance_flag == 0) {
                        var location = 3;
                        var item_id = id[0].report_dataset_id + '-' + id[0].data_source_column_id;
                        var item_real_name = id[0].column_name_real;
                        //var item_label = data_alias + '.' + series_columns_arr[cnt];
                        var item_label = id[0].alias;
                        //var alias = series_columns_arr[cnt];
                        var alias = id[0].alias.split('.')[1];
                        window.register_column_dragged(location, item_id, item_real_name, item_label, alias, '', '');  
                    }
                    series_arr.push(id[0].data_source_column_id);       
                }
            }
            //Delete the removed series columns
            for (cnt = 0; cnt < series_item_arr.length; cnt++) {
                var id = series_arr.filter(function(e) {
                    if (adv_click_cnt == 0) {
                        var iid = ds_col_info_gbl.filter(function(e) {
                            return e.column_name_real == series_item_arr[cnt];
                        });
                        if(iid.length == 0) return false;
                        else return e == iid[0].data_source_column_id;
                    } else {
                        return e == series_item_arr[cnt];
                    }
                });
                if (id == '') {
                   if (adv_click_cnt == 0) {
                        var iid = ds_col_info_gbl.filter(function(e) {
                            return e.column_name_real == series_item_arr[cnt];
                        });
                        //var item_id = id[0].report_dataset_id + '-' + iid[0].data_source_column_id;
                        var item_id = dataset_id + '-' + iid[0].data_source_column_id;
                    } else {
                        //var item_id = id[0].report_dataset_id + '-' + series_item_arr[cnt];
                        var item_id = dataset_id + '-' + series_item_arr[cnt];
                    }
                    window.delete_column_dragged($('#series-columns-rs-table'),item_id);
                }
            }
            series_item_arr = series_arr;
        } 
        adv_click_cnt++;
    }    
</script>
</html>