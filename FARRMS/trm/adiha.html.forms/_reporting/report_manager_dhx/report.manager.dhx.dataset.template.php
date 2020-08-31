<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  
        require('../../../adiha.php.scripts/components/include.file.v3.php');
        require_once('../../../adiha.php.scripts/components/include.ssrs.reporting.files.php'); 
    ?>
</head>
<body>
    <?php     
    $php_script_loc = $app_php_script_loc;
    $app_user_loc = $app_user_name;
    $dataset_info_obj = isset($_POST['dataset_info_obj']) ? json_decode($_POST['dataset_info_obj']) : '';

    $form_namespace = 'rm_dataset';
    $layout_obj = new AdihaLayout();
    $layout_json = '[
        {id: "a", text: "dataset header", header:true, height:120}, 
        {id: "b", text: "dataset detail, header:true}
    ]';
    
    echo $layout_obj->init_layout('layout', '', '2E', $layout_json, $form_namespace);
    echo $layout_obj->attach_event('', 'onDock', $form_namespace . '.on_dock_report_event');
    echo $layout_obj->attach_event('', 'onUnDock', $form_namespace . '.on_undock_report_event');
    
    // attach menu
    $menu_json = '[
        {id: "accept", img:"accept.gif", img_disabled:"accept_dis.gif", text:"Accept", title:"Accept"},
        {id: "save", img:"save.gif", img_disabled:"save_dis.gif", text:"Save", title:"Save"}
    ]';
    $menu_obj = new AdihaMenu();
    echo $layout_obj->attach_menu_cell("menu_ds", "a");  
    echo $menu_obj->init_by_attach("menu_ds", $form_namespace);
    echo $menu_obj->load_menu($menu_json);
    echo $menu_obj->attach_event('', 'onClick', $form_namespace . '.menu_click');
    
    // attach filter form
    $form_dataset = new AdihaForm();
    $form_dataset_name = 'form_ds';
    echo $layout_obj->attach_form($form_dataset_name, 'a');

    $sp_url = "EXEC spa_rfx_data_source_dhx @flag = 'y'";
    $data_source_dropdown_json = $form_dataset->adiha_form_dropdown($sp_url, 0, 2, true, $dataset_id);
    $dataset_array = readXMLURL2($sp_url);
     
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
        {value: "0", label: "None"},
        {value: "1", label: "Bottom"},
        {value: "2", label: "Right"},
        {value: "3", label: "Bottom + Right"}
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
        {"type": "settings", "position": "label-top", "offsetLeft": 10},
        {type:"combo", name: "data_source", label:"Dataset", "labelWidth":150, required:true, filtering:true, "inputWidth":180, "options": ' . $data_source_dropdown_json . '}, {type:"newcolumn"},
        {type:"input", name: "ds_alias", hidden: true, value: "' . $dataset_alias. '", label:"Data Source Alias", "labelWidth":150, required:false, "inputWidth":150}, {type:"newcolumn"},
        {type:"input", name: "ri_name", value: "' . $item_name . '", label:"Report Item Name", "labelWidth":150, required:true, "inputWidth":150}, {type:"newcolumn"},
        {type:"combo", name: "page_break", label:"Page Break", "labelWidth":90, required:false, "inputWidth":95, options: ' . $json_page_break_opt . ' }, {type:"newcolumn"},
        {type:"combo", name: "summary_on", label:"Summary On", "labelWidth":90, required:false, "inputWidth":95, options: ' . $json_summary_on_opt . ' }, {type:"newcolumn"},
        {type:"combo", name: "grouping_mode", label:"Grouping Mode", "labelWidth":90, required:false, "inputWidth":95, options: ' . $json_grouping_mode_opt . ' }, {type:"newcolumn"},
        {type:"combo", name: "table_border", label:"Table Border", "labelWidth":90, required:false, "inputWidth":95, options: ' . $json_table_border_opt . ' }, {type:"newcolumn"},
        {type:"checkbox", name: "hide_header", checked: "' . $no_header . '", label:"Hide Header", "labelWidth":90, required:false, "inputWidth":95, position: "label-right", offsetTop: 33}
        
        
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
<script type="text/javascript"> 
    parent.dhx_wins.window('window_ri').maximize();
    var ri_info_obj = $.parseJSON('<?php echo json_encode($ri_info_obj); ?>');
    var process_id = '<?php echo $process_id; ?>';
    var report_id = '<?php echo $report_id; ?>';
    var item_flag = '<?php echo $item_flag; ?>';
    var dataset_array = $.parseJSON('<?php echo json_encode($dataset_array); ?>');
    console.log(dataset_array);
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
         
         if(item_flag == 'u') {
            update_detail_ri = $.parseJSON('<?php echo json_encode($item_header_values); ?>');
            form_ri = rm_tablix.datasource_form;
            //console.log(update_detail_ri);
            
            form_ri.getCombo('page_break').setComboValue(update_detail_ri[0].page_break);
            form_ri.getCombo('summary_on').setComboValue(update_detail_ri[0].cross_summary);
            form_ri.getCombo('table_border').setComboValue(update_detail_ri[0].border_style);
            pivot_col_list['detail_columns'] = '<?php echo $pivot_col_list['detail_columns']; ?>';
            pivot_col_list['grouping_columns'] = '<?php echo $pivot_col_list['grouping_columns']; ?>';
            pivot_col_list['cols_columns'] = '<?php echo $pivot_col_list['cols_columns']; ?>';
            pivot_col_list['rows_columns'] = '<?php echo $pivot_col_list['rows_columns']; ?>';
            form_ri.getCombo('dataset_id').setComboValue('<?php echo $item_id; ?>');
            
         }
         rm_tablix.form_change('dataset_id');
    });

    rm_tablix.form_change = function(name, value, state) {
        var file_path = '<?php echo $report_views_url_path;?>';

        if (name == 'dataset_id') {
            var cmb_obj = rm_tablix.datasource_form.getCombo('dataset_id');
            var file_name = cmb_obj.getSelectedText().split(' (')[0];
            var aggregators = '<?php echo ($tablix_type_id == 1 ? '' : 'Sum') ; ?>';

            var layout_cell_obj = rm_tablix.pivot_template.cells('b');
            var tabbar_obj = rm_tablix.pivot_template.cells('b').getAttachedObject();
            
            tabbar_obj.forEachTab(function(tab){
                var tab_name = tab.getText();
                if (tab_name == 'General') {
                    var full_file_name = file_path + '/' + file_name + '.csv';
                    var post_param = {
                        file_path: full_file_name,
                        report_type: 'tablix',
                        renderer_type: '<?php echo ($tablix_type_id == 1 ? 'Table' : 'CrossTab Table') ; ?>',
                        aggregators: aggregators,
                        col_list: JSON.stringify(pivot_col_list)
                    };
                    console.log(pivot_col_list);
                    //layout_cell_obj.progressOn();
                    layout_cell_obj.attachEvent('onContentLoaded', function(id) {
                        layout_cell_obj.progressOff(); //does not work
                    });
                    var url = js_php_path + 'pivot.template.php';
                    tab.attachURL(url, true, post_param);
                } else if (tab_name == 'Advance') {
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
                        height: ''
                    };
                    //var url = js_php_path + 'pivot.template.advance.php';
                    var url = app_form_path  + '_reporting/report_manager_dhx/report.manager.dhx.tablix.advance.php';
                    tab.attachURL(url, true, post_param);
                }
            });
        }
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
        
        var item_name = rm_tablix.datasource_form.getItemValue('ri_name');
        var cmb_border_style = rm_tablix.datasource_form.getItemValue('table_border');
        var cmb_page_break = rm_tablix.datasource_form.getItemValue('page_break');
        var type_id = (columns_array_gbl['renderer_type'] == 'Table' ? 1 : 2); //rm_tablix.datasource_form.getItemValue('tablix_type');
        var cross_summary = rm_tablix.datasource_form.getItemValue('summary_on');
        var no_header = (rm_tablix.datasource_form.getItemValue('hide_header') ? 1 : 2);
        
        var cmb_group_mode = rm_tablix.datasource_form.getItemValue('grouping_mode');
        var export_table_name = '';
        var is_global = '';
        
        var stack = {};
        stack.report_tablix_column_id = 'NULL';
        stack.h_font = 'Tahoma';
        stack.h_font_size = '8';
        stack.h_text_align = 'Left';
        stack.h_text_color = '#ffffff';
        stack.h_background = '#458bc1';
        stack.h_bold_check = '1';
        stack.h_italic_check = '0';
        stack.h_underline_check = '0';
        var xml_rs_headers = '<Root>';
        var xml_rs_columns = '<Root>';
        
        $.each(columns_array_gbl['detail_columns'].split(','), function(index, value) {
            //alert(type_id);
            var detail_col_ct = '';
            var detail_col_agg_ct = '';
            var compare_value = value;
            if(columns_array_gbl['detail_columns'] == '') {
                return false;
            } else if(type_id == 2) {
                detail_col_ct = columns_array_gbl['detail_columns'].split('||||')[1];
                detail_col_agg_ct = columns_array_gbl['detail_columns'].split('||||')[0];
                compare_value = detail_col_ct;
            }
            var dsc_obj = $(json_ds_col_id_gbl).filter(function(i,n) {
                //console.log((n.name +':' +compare_value ));
                return (n.name == compare_value);
            });
            console.log(dsc_obj);
            
            xml_rs_headers += '<PSRecordset TabColID="' + stack.report_tablix_column_id
                        + '" TabLixID="' + ri_info_obj.item_id
                        + '" ColumnID="' + dsc_obj[0].column_id
                        + '" Font="' + stack.h_font
                        + '" FontSize="' + stack.h_font_size
                        + '" TextAlign="' + stack.h_text_align
                        + '" TextColor="' + stack.h_text_color
                        + '" Background="' + stack.h_background
                        + '" FontStyle="' + stack.h_bold_check + ',' + stack.h_italic_check
                        + ',' + stack.h_underline_check
                        + '" MarkIndex="' + '1' + index
                        + '"></PSRecordset>';
                        
            xml_rs_columns += '<PSRecordset TabColID="' + stack.report_tablix_column_id
                        + '" DataSetID="' + dataset_id
                        + '" TabLixID="' + ri_info_obj.item_id
                        + '" ColumnID="' + dsc_obj[0].column_id
                        + '" ColumnAlias="' + escapeXML(compare_value)
                        + '" FunctionName="' + escapeXML('')
                        + '" Aggregation="' + (type_id == 2 ? 13 : '')
                        + '" SQLAggregation="' + ''
                        + '" Subtotal="' + ''
                        + '" CrossSummaryAggregation="' + ''
                        + '" SortLinkHeader="' + '1'
                        + '" Rounding="' + ''
                        + '" ThousandSeperator="' + ''
                        + '" SortPriority="' + ''
                        + '" SortTo="' + ''
                        + '" Font="' + 'Tahoma'
                        + '" FontSize="' + '8'
                        + '" TextAlign="' + 'Left'
                        + '" TextColor="' + '#000000'
                        + '" Background="' + '#ffffff'
                        + '" FontStyle="' + '0' + ',' + '0' + ',' + '0'
                        + '" CustomField="' + '0'
                        + '" ColumnOrder="' + index
                        + '" RenderAs="' + ('0')
                        + '" ColumnTemplate="' + ('-1')
                        + '" NegativeMark="' + ('')
                        + '" Currency="' + ('')
                        + '" FormatDate="' + ('')
                        + '" Placement="' + '1'
                        + '" MarkForTotal="' + '0'
                        + '" MarkIndex="'  + '1' + index
                        + '"></PSRecordset>';
        });
        if(type_id == 1 && columns_array_gbl['grouping_columns'] != '') {
            $.each(columns_array_gbl['grouping_columns'].split(','), function(index, value) {
                if(columns_array_gbl['grouping_columns'] == '') {
                    return false;
                }
                var dsc_obj = $(json_ds_col_id_gbl).filter(function(i,n) {
                    return (n.name == value);
                });
                xml_rs_headers += '<PSRecordset TabColID="' + stack.report_tablix_column_id
                        + '" TabLixID="' + ri_info_obj.item_id
                        + '" ColumnID="' + dsc_obj[0].column_id
                        + '" Font="' + stack.h_font
                        + '" FontSize="' + stack.h_font_size
                        + '" TextAlign="' + stack.h_text_align
                        + '" TextColor="' + stack.h_text_color
                        + '" Background="' + stack.h_background
                        + '" FontStyle="' + stack.h_bold_check + ',' + stack.h_italic_check
                        + ',' + stack.h_underline_check
                        + '" MarkIndex="' + '2' + index
                        + '"></PSRecordset>';
                xml_rs_columns += '<PSRecordset TabColID="' + stack.report_tablix_column_id
                            + '" DataSetID="' + dataset_id
                            + '" TabLixID="' + ri_info_obj.item_id
                            + '" ColumnID="' + dsc_obj[0].column_id
                            + '" ColumnAlias="' + escapeXML(value)
                            + '" FunctionName="' + escapeXML('')
                            + '" Aggregation="' + ''
                            + '" SQLAggregation="' + ''
                            + '" Subtotal="' + ''
                            + '" CrossSummaryAggregation="' + ''
                            + '" SortLinkHeader="' + '1'
                            + '" Rounding="' + ''
                            + '" ThousandSeperator="' + ''
                            + '" SortPriority="' + ''
                            + '" SortTo="' + ''
                            + '" Font="' + 'Tahoma'
                            + '" FontSize="' + '8'
                            + '" TextAlign="' + 'Left'
                            + '" TextColor="' + '#000000'
                            + '" Background="' + '#ffffff'
                            + '" FontStyle="' + '0' + ',' + '0' + ',' + '0'
                            + '" CustomField="' + '0'
                            + '" ColumnOrder="' + index
                            + '" RenderAs="' + ('0')
                            + '" ColumnTemplate="' + ('-1')
                            + '" NegativeMark="' + ('')
                            + '" Currency="' + ('')
                            + '" FormatDate="' + ('')
                            + '" Placement="' + '2'
                            + '" MarkForTotal="' + '0'
                            + '" MarkIndex="' + '2' + index
                            + '"></PSRecordset>';
            });
        } else {//crosstab report
            $.each(columns_array_gbl['columns'].split(','), function(index, value) {
                if(columns_array_gbl['columns'] == '') {
                    return false;
                }
                var dsc_obj = $(json_ds_col_id_gbl).filter(function(i,n) {
                    return (n.name == value);
                });
                xml_rs_headers += '<PSRecordset TabColID="' + stack.report_tablix_column_id
                        + '" TabLixID="' + ri_info_obj.item_id
                        + '" ColumnID="' + dsc_obj[0].column_id
                        + '" Font="' + stack.h_font
                        + '" FontSize="' + stack.h_font_size
                        + '" TextAlign="' + stack.h_text_align
                        + '" TextColor="' + '#ffffff'
                        + '" Background="' + '#458bc1'
                        + '" FontStyle="' + stack.h_bold_check + ',' + stack.h_italic_check
                        + ',' + stack.h_underline_check
                        + '" MarkIndex="' + '3' + index
                        + '"></PSRecordset>';
                xml_rs_columns += '<PSRecordset TabColID="' + stack.report_tablix_column_id
                            + '" DataSetID="' + dataset_id
                            + '" TabLixID="' + ri_info_obj.item_id
                            + '" ColumnID="' + dsc_obj[0].column_id
                            + '" ColumnAlias="' + escapeXML(value)
                            + '" FunctionName="' + escapeXML('')
                            + '" Aggregation="' + ''
                            + '" SQLAggregation="' + ''
                            + '" Subtotal="' + ''
                            + '" CrossSummaryAggregation="' + ''
                            + '" SortLinkHeader="' + '1'
                            + '" Rounding="' + ''
                            + '" ThousandSeperator="' + ''
                            + '" SortPriority="' + ''
                            + '" SortTo="' + ''
                            + '" Font="' + 'Tahoma'
                            + '" FontSize="' + '8'
                            + '" TextAlign="' + 'Left'
                            + '" TextColor="' + '#ffffff'
                            + '" Background="' + '#458bc1'
                            + '" FontStyle="' + '0' + ',' + '0' + ',' + '0'
                            + '" CustomField="' + '0'
                            + '" ColumnOrder="' + (index)
                            + '" RenderAs="' + ('0')
                            + '" ColumnTemplate="' + ('-1')
                            + '" NegativeMark="' + ('')
                            + '" Currency="' + ('')
                            + '" FormatDate="' + ('')
                            + '" Placement="' + '3'
                            + '" MarkForTotal="' + '0'
                            + '" MarkIndex="' + '3' + index
                            + '"></PSRecordset>';
            });
            $.each(columns_array_gbl['rows'].split(','), function(index, value) {
                if(columns_array_gbl['rows'] == '') {
                    return false;
                }
                var dsc_obj = $(json_ds_col_id_gbl).filter(function(i,n) {
                    return (n.name == value);
                });
                xml_rs_headers += '<PSRecordset TabColID="' + stack.report_tablix_column_id
                        + '" TabLixID="' + ri_info_obj.item_id
                        + '" ColumnID="' + dsc_obj[0].column_id
                        + '" Font="' + stack.h_font
                        + '" FontSize="' + stack.h_font_size
                        + '" TextAlign="' + stack.h_text_align
                        + '" TextColor="' + '#ffffff'
                        + '" Background="' + '#458bc1'
                        + '" FontStyle="' + stack.h_bold_check + ',' + stack.h_italic_check
                        + ',' + stack.h_underline_check
                        + '" MarkIndex="' + '4' + index
                        + '"></PSRecordset>';
                xml_rs_columns += '<PSRecordset TabColID="' + stack.report_tablix_column_id
                            + '" DataSetID="' + dataset_id
                            + '" TabLixID="' + ri_info_obj.item_id
                            + '" ColumnID="' + dsc_obj[0].column_id
                            + '" ColumnAlias="' + escapeXML(value)
                            + '" FunctionName="' + escapeXML('')
                            + '" Aggregation="' + ''
                            + '" SQLAggregation="' + ''
                            + '" Subtotal="' + ''
                            + '" CrossSummaryAggregation="' + ''
                            + '" SortLinkHeader="' + '1'
                            + '" Rounding="' + ''
                            + '" ThousandSeperator="' + ''
                            + '" SortPriority="' + ''
                            + '" SortTo="' + ''
                            + '" Font="' + 'Tahoma'
                            + '" FontSize="' + '8'
                            + '" TextAlign="' + 'Left'
                            + '" TextColor="' + '#ffffff'
                            + '" Background="' + '#458bc1'
                            + '" FontStyle="' + '0' + ',' + '0' + ',' + '0'
                            + '" CustomField="' + '0'
                            + '" ColumnOrder="' + (index)
                            + '" RenderAs="' + ('0')
                            + '" ColumnTemplate="' + ('-1')
                            + '" NegativeMark="' + ('')
                            + '" Currency="' + ('')
                            + '" FormatDate="' + ('')
                            + '" Placement="' + '4'
                            + '" MarkForTotal="' + '0'
                            + '" MarkIndex="' + '4' + index
                            + '"></PSRecordset>';
            });
        }
        
        xml_rs_headers += '</Root>';
        xml_rs_columns += '</Root>';
        
       
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
            
            'xml_column': xml_rs_columns,
            'xml_header': xml_rs_headers
            
        };
        
        adiha_post_data('return_json', post_data, '', '', 'rm_tablix.fx_save_tablix_info_cb');
    };
    rm_tablix.fx_save_tablix_info_cb = function(result) {
        
        json_obj = $.parseJSON(result);
        if(json_obj[0].errorcode == 'Success') {
            success_call('Tablix info saved.', 'error');
            var item_arr = new Array();
            var item_id = json_obj[0].recommendation;
            var item_name = rm_tablix.datasource_form.getItemValue('ri_name');
            item_arr.push(item_id, item_name);
            
            if(item_flag == 'i') {
                parent.ifr_dhx.ifr_tab[process_id].ifr_page.fx_add_report_item(ri_info_obj.item_type, item_arr);
                parent.ifr_dhx.ifr_tab[process_id].div_obj.attr('item_id', item_id);
            } else {
                
            }
            
            try {
                parent.dhx_wins.window('window_ri').close();
            } catch (e) {
                alert('Exception: ' + e);
            }
            
            
            
        } else {
            console.log('***error on saving tablix ***');
            dhtmlx.message({
                title: "Error",
                type: "alert-error",
                text: json_obj[0].message,
            });
        }
    };
    var json_ds_col_id_gbl;
    rm_tablix.fx_extract_ds_col_id_cb = function(result) {
        json_obj = $.parseJSON(result);
        //console.dir(json_obj);
        json_ds_col_id_gbl = json_obj;
          
    };
    
</script>
</html>