<!DOCTYPE html>
<html> 
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
    
<body>
    <?php 
    $php_script_loc = $app_php_script_loc;
    $app_user_loc = $app_user_name;
    $module_type = '';//"15500"; //Fas (module type)
    list($default_as_of_date_to, $default_as_of_date_from) = getDefaultAsOfDate($module_type);
    
    $active_object_id = get_sanitized_value($_POST['active_object_id'] ?? 'NULL');
    $function_id = get_sanitized_value($_POST['function_id'] ?? 'NULL');
    
    $link_name = get_sanitized_value($_POST['link_name'] ?? 'NULL');
    
    $rights_pnl_series = 10237300;
    $rights_pnl_series_iu = 10237310;
    $rights_pnl_series_delete = 10237311;
    
    list (
        $has_rights_pnl_series,
        $has_rights_pnl_series_iu,
        $has_rights_pnl_series_delete
     ) = build_security_rights(
        $rights_pnl_series,
        $rights_pnl_series_iu,
        $rights_pnl_series_delete
    );
    
    $namespace = 'ns_pnl_series';
    //Attaching main layout
    $layout_obj = new AdihaLayout();
    $layout_json = '[
                        {id: "a", width: 400, height:90, text: "Apply Filters",header: true, collapse: false, fix_size: [false,null]},
                        {id: "b", height:30, text: "Criteria",header: true, collapse: false, fix_size: [false,null]},
                        {id: "c", text: "Cum PNL Series",header: true, collapse: false, fix_size: [false,null]}                        
                    ]';
    $patterns = '3E';
                    
    $layout_name = 'layout_pnl_series';
    echo $layout_obj->init_layout($layout_name,'', $patterns,$layout_json, $namespace);
    
    //Attaching objects in cell c
    $toolbar_obj = new AdihaToolbar();
    $toolbar_name = 'toolbar_pnl_series';
    $toolbar_json = "[
                    { id: 'run', type: 'button', img: 'run.gif', imgdis:'run_dis.gif', text: 'Run', title: 'Run'}
                ]";
    echo $layout_obj->attach_toolbar($toolbar_name, 'a');
    echo $toolbar_obj->init_by_attach($toolbar_name, $namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', $namespace . '.tab_toolbar_click');
    
    //Attaching Filter form on cell b
    $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id=". $rights_pnl_series . ", @template_name='ViewCumPNLSeries', @group_name='Filter'";
    $return_value = readXMLURL($xml_file);
    $form_json = $return_value[0][2];
    
    $filter_name = 'filter_form';
    echo $layout_obj->attach_form($filter_name, 'b');
    $filter_obj = new AdihaForm();
    echo $filter_obj->init_by_attach($filter_name, $namespace);
    echo $filter_obj->load_form($form_json);
    
    //Attaching objects in cell c
    $menu_obj = new AdihaMenu();
    $menu_name = 'menu_pnl_series';
    $menu_json = '[
                    {id: "save", img: "save.gif", imgdis:"save_dis.gif", enabled:' . $has_rights_pnl_series_iu .', text: "Save"},
                    {id: "refresh", img: "refresh.gif", text: "Refresh"},
                    {id: "edit", img:"edit.gif", text: "Edit", items:[
                            {id:"add", text:"Add", img:"add.gif", imgdis:"add_dis.gif", enabled:' . $has_rights_pnl_series_iu .'},
                            {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", enabled:false}
                        ]
                    },
                    {id: "export", img:"export.gif", text: "Export", items:[
                            {id: "excel", text: "Excel", img:"excel.gif", imgdis:"excel_dis.gif", enabled:true},
                            {id: "pdf", text: "PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", enabled:true},
                            {id: "batch", img: "batch.gif", imgdis: "batch_dis.gif", text: "Batch", enabled:true},
                        ]
                    }
                ]';
    echo $layout_obj->attach_menu_cell($menu_name, 'c');
    echo $menu_obj->init_by_attach($menu_name, $namespace);
    echo $menu_obj->load_menu($menu_json);
    echo $menu_obj->attach_event('', 'onClick', $namespace . '.onclick_menu');
    
    //Attaching grid in cell 'c'
    $grid_obj = new AdihaGrid();
    $grid_name = 'grd_pnl_series';
    echo $layout_obj->attach_grid_cell($grid_name, 'c');
    
    $xml_file = "EXEC spa_adiha_grid 's','ViewCumPNLSeries'";
    $resultset = readXMLURL2($xml_file);
    echo $grid_obj->init_by_attach($grid_name, $namespace);
    echo $grid_obj->set_header($resultset[0]['column_label_list']);
    echo $grid_obj->set_columns_ids($resultset[0]['column_name_list']);
    echo $grid_obj->set_widths($resultset[0]['column_width']);
    echo $grid_obj->set_column_types($resultset[0]['column_type_list']);
    echo $grid_obj->set_sorting_preference($resultset[0]['sorting_preference']);
    echo $grid_obj->set_column_auto_size(true);
    echo $grid_obj->set_column_visibility($resultset[0]['set_visibility']);
    echo $grid_obj->enable_multi_select(false);
    echo $grid_obj->set_search_filter(false,"#text_filter,#text_filter,#text_filter,#numeric_filter,#numeric_filter,#numeric_filter,#numeric_filter,#text_filter,#text_filter,#text_filter");
    echo $grid_obj->set_date_format($date_format, "%Y-%m-%d");
    //echo $grid_obj->enable_paging(25, 'pagingArea_a'); 
    echo $grid_obj->return_init('','false,true,false,true,true,true,true,true,true,true');
    echo $grid_obj->attach_event('', 'onRowSelect', 'set_privileges');
    echo $grid_obj->load_grid_functions();
    
    //Unload main layout
    echo $layout_obj->close_layout();
        
    ?>
</body>
<script>
    var active_object_id = '<?php echo $active_object_id; ?>';    
    var link_id = (active_object_id.indexOf("tab_") != -1) ? active_object_id.replace("tab_", "") : active_object_id;
    var function_id = '<?php echo $rights_pnl_series; ?>';
    var has_rights_pnl_series_iu = Boolean(<?php echo $has_rights_pnl_series_iu; ?>);
    var has_rights_pnl_series_delete = Boolean(<?php echo $has_rights_pnl_series_delete; ?>);
    var session_id = '<?php echo $session_id; ?>';
             
    $(function() {
        filter_obj = ns_pnl_series.layout_pnl_series.cells('a').attachForm();
        var layout_cell_obj = ns_pnl_series.layout_pnl_series.cells('b');
        load_form_filter(filter_obj,layout_cell_obj,function_id,2);
        form_obj = layout_cell_obj.getAttachedObject();
        form_obj.setItemValue('as_of_date_from', '<?php echo $default_as_of_date_from; ?>');
        form_obj.setItemValue('as_of_date_to', '<?php echo $default_as_of_date_to; ?>');
        ns_pnl_series.layout_pnl_series.cells('a').collapse();
        //load month from to dropdown
        var cm_param = {
                    "action": "spa_execute_query",
                    "query": "[1,''Sunday''],[2,''Monday''],[3,''Tuesday''],[4,''Wednesday''],[5,''Thursday''],[6,''Friday''],[7,''Saturday'']",
                    "has_blank_option": "false"
                };

        cm_param = $.param(cm_param);
        var url = js_dropdown_connector_url + '&' + cm_param
        
        combo_obj = ns_pnl_series.filter_form.getCombo('week_days');
        combo_obj.load(url);
//            
        
        
    });
 
    ns_pnl_series.onclick_menu = function(id) {
        switch (id) {
            case 'refresh':
                ns_pnl_series.refresh_pnl_grid();
                break;
            case 'save':
                ns_pnl_series.save_data();
                break;
            case 'add':
                var new_id = (new Date()).valueOf();
                ns_pnl_series.grd_pnl_series.addRow(new_id, ['','',link_id,'','','','','',js_user_name,dates.convert_to_user_format('<?php echo $default_as_of_date_to; ?>')]);
                break;
                break;
            case 'delete':
                ns_pnl_series.delete_pnl_series();
                break;
            case 'excel':
                ns_pnl_series.grd_pnl_series.toExcel(js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                break;
            case 'pdf':
                ns_pnl_series.grd_pnl_series.toPDF(js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                break;
            case 'batch':
                ns_pnl_series.batch_pnl_series();
                break;
            default:
                dhtmlx.alert({
                    title:'Sorry! <font size="5">&#x2639 </font>',
                    type:"alert-error",
                    text:"Event not defined."
                });
                break;
        }
    }
    
    ns_pnl_series.save_data = function() {
        var grid_obj = ns_pnl_series.grd_pnl_series;
        ns_pnl_series.menu_pnl_series.setItemDisabled('save');
        var r_count = grid_obj.getRowsNum();
        if (r_count == 0) {
            if (has_rights_pnl_series_iu) {
                ns_pnl_series.menu_pnl_series.setItemEnabled('save');
            };
            return;
        }
        var grid_xml = "<Grid>";
        for (var row_index = 0; row_index < r_count; row_index++) {
            grid_xml += "<GridRow ";
            for (var cell_index = 0, c_count = grid_obj.getColumnsNum(); cell_index < c_count; cell_index++) {
                if (grid_obj.getColType(cell_index) == 'dhxCalendarA') {                    
                    //alert(dates.convert_to_sql(grid_obj.cells2(row_index,cell_index).getValue()));    //dates.convert_to_sql()
                    grid_xml += " " + grid_obj.getColumnId(cell_index) + '="' + grid_obj.cells2(row_index,cell_index).getValue() + '"';
                } else {
                    grid_xml += " " + grid_obj.getColumnId(cell_index) + '="' + grid_obj.cells2(row_index,cell_index).getValue() + '"';
                }                
            }
            grid_xml += " ></GridRow> ";
        }
        grid_xml += "</Grid>";
        
        var data = {
                            "action": "spa_cum_pnl_series",
                            "flag": 'm',
                            "xml_value": grid_xml
                        };
        
        adiha_post_data('return_json', data, '', '', 'save_callback', '');
    }
    
    function save_callback(result) {
        if (has_rights_pnl_series_iu) {        
            ns_pnl_series.menu_pnl_series.setItemEnabled('save');
}       ;
        var return_data = JSON.parse(result);
        
        if ((return_data[0].status).toLowerCase() == 'success') {             
            dhtmlx.message(return_data[0].message); 
            ns_pnl_series.refresh_pnl_grid(); 
            
        } else {
            dhtmlx.alert({
                   title: 'Error',
                   type: "alert-error",
                   text: return_data[0].message
                });
        }
    }
    
    ns_pnl_series.refresh_pnl_grid = function() {
        form_obj = ns_pnl_series.filter_form;
        form_data = form_obj.getFormData();
        var filter_param = '';
        var status = validate_form(form_obj);
        
        if (status) {
            ns_pnl_series.layout_pnl_series.cells('a').collapse();
            filter_param = new Array();
            filter_param.push("@link_id"+ '=' + link_id);
            for (var a in form_data) {
                if (form_data[a] != '' && form_data[a] != null) {
                    if (ns_pnl_series.filter_form.getItemType(a) == 'calendar') {
                        value = ns_pnl_series.filter_form.getItemValue(a, true);
                    } else {
                        value = form_data[a];
                    }
                    
                    if (a == 'as_of_date_from') {
                        filter_param.push("@date_from"+ '=' + singleQuote(value));
                    }
                                        
                    if (a == 'as_of_date_to') {
                        filter_param.push("@date_to"+ '=' + singleQuote(value));
                    }
                }
            }
            
            filter_param = filter_param.toString();
            var sql_stmt = "EXEC spa_cum_pnl_series @flag='s', " + filter_param;
            // load grid data
            var sql_param = {
                "sql": sql_stmt,
                "grid_type": 'g'
            };
    
            sql_param = $.param(sql_param);
            var sql_url = js_data_collector_url + "&" + sql_param;
            
            ns_pnl_series.grd_pnl_series.clearAll();
            ns_pnl_series.grd_pnl_series.load(sql_url);
            ns_pnl_series.grd_pnl_series.load(sql_url, function() {
                ns_pnl_series.menu_pnl_series.setItemDisabled('delete');
                //ns_pnl_series.menu_pnl_series.setItemDisabled('batch');
            });
            
        }
    }
    
    
    ns_pnl_series.tab_toolbar_click = function(id) {
        switch(id) {
            case 'run':
                ns_pnl_series.run_pnl();
                break;
            default:
                dhtmlx.alert({
                    title:'Sorry! <font size="5">&#x2639 </font>',
                    type:"alert-error",
                    text:"Event not defined."
                });
                break;
        }
    }

    ns_pnl_series.run_pnl = function() {
        var form_obj = ns_pnl_series.filter_form;
        var date_from = form_obj.getItemValue('as_of_date_from', true);
        var date_to = form_obj.getItemValue('as_of_date_to', true);
        var calc_mtm = (form_obj.isItemChecked('calc_chk')) ? 1 : 0;
        var days = form_obj.getItemValue('week_days');
        days = (days == '') ? 0 : days;
        var exec_call = "EXEC spa_create_mtm_series_for_link " 
	                + singleQuote(link_id) + ", " 
	                + singleQuote(date_from) + ", " 
	                + singleQuote(date_to) + ", " 
	                + days + ", " 
                + calc_mtm;
       
        //open_spa_html_window('Calc MTM PNL Data', exec_call, 800,700);
        var url = js_php_path + 'dev/spa_html.php?spa=' + exec_call + '&session_id=' +  session_id + '&' +  getAppUserName();
        open_window_with_post(url);
        
    }
  
    ns_pnl_series.delete_pnl_series = function() {
        var cum_pnl_series_id = get_selected_ids(ns_pnl_series.grd_pnl_series, 'cum_pnl_series_id');
        
        dhtmlx.confirm({
			title:"Confirmation",
			ok: "Confirm",
			text: 'Are you sure you want to delete data from the grid?',
			callback:function(result){	
			    if (result) {                            
                    data = {
                        "action": "spa_cum_pnl_series",
                        "flag": "d",
                        "cum_pnl_series_id": cum_pnl_series_id
                    }
                    result = adiha_post_data("return_array", data, "", "","post_delete_pnl_series"); 
                }                           
                
			}
		});
    }  
    
    function post_delete_pnl_series() {
        ns_pnl_series.grd_pnl_series.deleteSelectedRows();
        ns_pnl_series.menu_pnl_series.setItemDisabled('delete');
    }    
    
    function get_selected_ids(grid_obj, column_name) {
        var rid = grid_obj.getSelectedRowId();
        if (rid == '' || rid == null) {
            return false;
        }
        var rid_array = new Array();
        if (rid.indexOf(",") != -1) {
            rid_array = rid.split(',');
        } else {
            rid_array.push(rid);
        }
        
        var cid = grid_obj.getColIndexById(column_name);
        var selected_ids = new Array();
        $.each(rid_array, function( index, value ) {
          selected_ids.push(grid_obj.cells(value,cid).getValue());
        });
        selected_ids = selected_ids.toString();
        return selected_ids;
    }
    
    ns_pnl_series.batch_pnl_series = function() {
        as_of_date = ns_pnl_series.filter_form.getItemValue('as_of_date_from', true);
        as_of_date = (as_of_date == '') ? '<?php echo $default_as_of_date_to; ?>' : as_of_date;
        var sql_stmt = "EXEC spa_get_mtm_series_for_link " + link_id + ", " + singleQuote(as_of_date);  
        var arg = "call_from=View Update Cum Pnl Series Data Batch Job&gen_as_of_date=1&batch_type=r&as_of_date=" + as_of_date;
        var title = 'View Update Cum Pnl Series Data Batch';       
        adiha_run_batch_process(sql_stmt, arg, title);
        
    }
    //----------------- functions--------------------------
        
    function set_privileges () {
        if (has_rights_pnl_series_delete) {
            ns_pnl_series.menu_pnl_series.setItemEnabled('delete');
        } else {
            ns_pnl_series.menu_pnl_series.setItemDisabled('delete');
        }
        //ns_pnl_series.menu_pnl_series.setItemEnabled('batch');
    }
    
</script>
</html>