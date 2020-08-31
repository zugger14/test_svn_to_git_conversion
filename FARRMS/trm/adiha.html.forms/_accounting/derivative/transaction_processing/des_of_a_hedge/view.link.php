<?php
/**
* View link screen
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
        require('../../../../../adiha.php.scripts/components/include.file.v3.php');
        require('../../../../../adiha.html.forms/_setup/manage_documents/manage.documents.button.php'); 
    ?>
</head>
    
<body>
    <?php 
    $php_script_loc = $app_php_script_loc;
    $app_user_loc = $app_user_name;
    $mode = get_sanitized_value($_GET['mode'] ?? 'rw');
    $application_function_id = get_sanitized_value($_GET['function_id'] ?? 10233700);
    $link_id = get_sanitized_value($_GET['link_id'] ?? 0);
    $deal_match_param = get_sanitized_value($_GET['deal_match_param'] ?? 'New');
    
    if ($application_function_id == 10233700) {
        $title = 'Designation of Hedge';
    } else if ($application_function_id == 10237300) {
        $title = 'View/Update Cum PNL Series';
    } else if ($application_function_id == 10232300) {
      $title = 'Hedge Effectiveness Assessment';  
    }
    
    $rights_designation_of_hedge = 10233700;
    $rights_designation_of_hedge_iu = 10233710;
    $rights_designation_of_hedge_delete = 10233718;
    $rights_designation_of_hedge_copy = 10233720;
    $rights_update_delete_closed_hedge = 10233721;
    $rights_de_designation = 10233719;  //Dedesignate
    $rights_run_assessement = 10232300; //run assessment
    $rights_run_measurement = 10233400; //Run Measurement Process
    
    $module_type = 15500;//Fas module type 15500
    list($default_as_of_date_to, $default_as_of_date_from) = getDefaultAsOfDate($module_type);

    list (
        $has_rights_designation_of_hedge,
        $has_rights_designation_of_hedge_iu,
        $has_rights_designation_of_hedge_copy,
        $has_rights_designation_of_hedge_delete,
        $has_rights_update_delete_closed_hedge,
        $has_rights_de_designation,
        $has_rights_run_assessement,
        $has_rights_run_measurement
    ) = build_security_rights(
        $rights_designation_of_hedge,
        $rights_designation_of_hedge_iu,
        $rights_designation_of_hedge_copy,
        $rights_designation_of_hedge_delete,
        $rights_update_delete_closed_hedge,
        $rights_de_designation,
        $rights_run_assessement,
        $rights_run_measurement
    );
        
    $namespace = 'link_ui';
    $layout_obj = new AdihaLayout();
    
   if($application_function_id == 10232300){
        $enable = 'false';

        $layout_json = '[
                            {id: "a", height:300, text: "Filter Criteria",header: true, collapse: false, fix_size: [false,null]}
                        ]';
        $grid_cell = 'b';
        $patterns = '1C';
    } else {
        $enable = 'true';

        $layout_json = '[
                           {id: "a", height:300, width:400, text: "Filter Criteria",header: true, collapse: false},                            
                           {id: "b", text: "Form",header: false, collapse: false, hidden:false}                  
                        ]';
       
        $patterns = '2U';            
    }

    $layout_name = 'layout_link_ui';
    echo $layout_obj->init_layout($layout_name, '', $patterns, $layout_json, $namespace);

    $child_layout = 'layout_link_ui_child';
    $child_layout_json = '[
                            {id: "a", height:300, width:400, text: "Filter Criteria",true: false, collapse: false},                           
                            {id: "b", text: "Links",header: true, collapse: false}                        
                        ]';
    $grid_cell = 'b';
    $child_layout_obj = new AdihaLayout();
    echo $layout_obj->attach_layout_cell($child_layout, 'a', '2E', $child_layout_json);
    echo $child_layout_obj->init_by_attach($child_layout, $namespace);   

    $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id=". $rights_designation_of_hedge . ", @template_name='DesignationOfHedge', @group_name='Filter',@template_type='filter'";
    $return_value = readXMLURL($xml_file);
    $form_json = $return_value[0][2];
    
    $filter_name = 'filter_form';
    echo $child_layout_obj->attach_form($filter_name, 'a');
    $child_form = new AdihaForm();
    echo $child_form->init_by_attach($filter_name, $namespace);
    echo $child_form->load_form_filter($namespace, $filter_name, $child_layout, 'a', 10233700, 2);
    echo $child_form->load_form($form_json);
    
    $menu_obj = new AdihaMenu();
    $menu_name = 'left_menu';
    $menu_json = '[{ id: "refresh", img: "refresh.gif", text: "Refresh"},
                    {id: "edit", enabled:'. $enable . ', img:"edit.gif", imgdis: "edit_dis.gif", text: "Edit", items:[
                            {id:"add", text:"Add", img:"add.gif", imgdis:"add_dis.gif", enabled:"' . $has_rights_designation_of_hedge_iu. '"},
                            {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", enabled:false},
                            {id:"copy", text:"Copy Link", img:"copy.gif", imgdis:"copy_dis.gif", enabled:false}
                        ]
                    },
                    {id: "export", enabled:'. $enable . ', img:"export.gif", imgdis: "export_dis.gif", text: "Export", items:[
                            {id: "excel", text: "Excel", img:"excel.gif", imgdis:"excel_dis.gif", enabled:true},
                            {id: "pdf", text: "PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", enabled:true},
                            {id: "batch", img: "batch.gif", imgdis: "batch_dis.gif", text: "Batch", enabled:false},
                        ]
                    },
                    {id: "process", enabled:'. $enable . ', img:"process.gif", imgdis: "process_dis.gif", text: "Process", items:[
                            {id:"dedesignate", text:"Dedesignate", img:"dedesignate.gif", imgdis:"dedesignate_dis.gif", enabled:false},
                            {id:"run_assessment", text:"Run Assessment", img:"run_assessment.gif", imgdis:"run_assessment_dis.gif", enabled:"' . $has_rights_run_assessement. '"},
                            {id:"run_measurement", text:"Run Measurement", img:"run_measurement.gif", imgdis:"run_measurement_dis.gif", enabled:false}
                        ]
                    },
                    {id: "report", enabled:'. $enable . ', img:"report.gif", text: "Report", imgdis: "report_dis.gif", items:[
                            {id:"r1", text:"Hedge Documentation", img:"hedge_doc.gif", imgdis:"hedge_doc_dis.gif", enabled:true},
                            {id:"r2", text:"Run Measurement Report", img:"measurement_report.gif", imgdis:"measurement_report_dis.gif", enabled:true},
                            {id:"r3", text:"Run Journal Entry Report", img:"journal_report.gif", imgdis:"journal_report_dis.gif", enabled:true},
                            {id:"r4", text:"Run Hedge Position Report", img:"finalize.gif", imgdis:"finalize_dis.gif", enabled:true}
                        ]
                    }
                ]';
    echo $child_layout_obj->attach_menu_cell($menu_name, $grid_cell);
    echo $menu_obj->init_by_attach($menu_name, $namespace);
    echo $menu_obj->load_menu($menu_json);
    echo $menu_obj->attach_event('', 'onClick', $namespace . '.onclick_menu');
    
    //Attaching grid in cell 'b' in Child Layout
    $grid_obj = new AdihaGrid();
    $grid_name = 'left_grid';
    echo $child_layout_obj->attach_grid_cell($grid_name, $grid_cell);
    
    $xml_file = "EXEC spa_adiha_grid 's','DesignationOfHedge'";
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
    echo $grid_obj->set_search_filter(true);
    //echo $grid_obj->enable_paging(25, 'pagingArea_a'); 
    echo $grid_obj->return_init('','Link ID,Description,Subsidiary,Strategy,Book,Effective Date,Perfect Hedge,Fully Dedesignated,Link Active,Allow Change');
    
    if($application_function_id != 10232300){
        echo $grid_obj->attach_event('', 'onRowDblClicked', $namespace . '.load_template_detail');
    }
    echo $grid_obj->attach_event('', 'onRowSelect', 'set_privileges');
    echo $grid_obj->load_grid_functions();
    
    
    if($application_function_id != 10232300) {   
        $url = $app_adiha_loc . 'adiha.html.forms/_accounting/derivative/transaction_processing/des_of_a_hedge/view.link.template.php';
        echo $layout_obj->attach_url('b', $url);
    }
    
    //Unload main layout
    echo $layout_obj->close_layout();    
    $rfx_custom_report_filter = '';
    $rfx_custom_report_param = array();
    $rfx_custom_report_param['link_id'] = 'NULL';

    $rpc_url  = $app_php_script_loc . '../adiha.html.forms/_reporting/report_manager_dhx/report.viewer.custom.php';
    $rpc_arg  = '?__user_name__=' . $app_user_name . '&session_id=' . $session_id;
    $rpc_arg .= '&windowTitle=Report%20viewer&export_type=HTML4.0&link_id=NULL';
    $rpc_arg .= '&disable_header=2&report_name=NULL'; // disable_header=2 is for multiple Invoice view.
    $rpc_arg .= '&param_list=' . implode(',', array_keys($rfx_custom_report_param));
    array_walk($rfx_custom_report_param, 'explode_key_val_array', '=');
    $rfx_custom_report_filter = implode('&', $rfx_custom_report_param);
    $rpc_arg .= "&" . $rfx_custom_report_filter;
    $iframe_src = $rpc_url . $rpc_arg;
    $iframe_src .= '&batch_call=y&batch_call_from=hedge';
    $rfx_js_url_call = $iframe_src;
    
     //Fetched Hedge Position Report details
    $xml_file = "EXEC spa_view_report @flag='a', @report_name='Hedge Position Report'";
    $return_value = readXMLURL($xml_file);
    $hedge_position_report_id = $return_value[0][0];
    $hedge_position_paramset_id = $return_value[0][1];
    ?>
</body>
<script>
    var status_window;
    var dice_window;
    var lock_link = false;
    var lock_link_enabled = true;
    var template_name = 'DesignationOfHedgeUI';
    var rights_designation_of_hedge = '<?php echo $application_function_id; ?>';
    var function_id = '<?php echo $application_function_id; ?>';
    var has_rights_designation_of_hedge_delete = Boolean(<?php echo $has_rights_designation_of_hedge_delete; ?>);
    var has_rights_designation_of_hedge_copy = Boolean(<?php echo $has_rights_designation_of_hedge_copy; ?>);
    var has_rights_designation_of_hedge_iu = Boolean(<?php echo $has_rights_designation_of_hedge_iu; ?>);
    var has_rights_de_designation = Boolean(<?php echo $has_rights_de_designation; ?>);
    var has_rights_run_assessement = Boolean(<?php echo $has_rights_run_assessement; ?>);
    var has_rights_run_measurement = Boolean(<?php echo $has_rights_run_measurement; ?>);
    var has_rights_update_delete_closed_hedge = Boolean(<?php echo $has_rights_update_delete_closed_hedge; ?>);
    var category_id = 42; //Note type Designation of Hedge
    var has_document_rights = '<?php echo (int)($has_document_rights ?? '');?>';
    var mode = '<?php echo $mode; ?>';
    var client_date_format = '<?php echo $date_format; ?>';
    var filter_function_id = '10233700';//<?php echo $application_function_id;?>;
    var hedge_run_status_window;
    var win_obj = '';
    var measurement_report_id = 10234900; //Report ID for Measurement Report
    var journal_report_id = 10235400;//Report ID for Journal Entry Report
    var grid_cell = '<?php echo $grid_cell;?>';
    var hyper_link_id = <?php echo $link_id;?>; //Link ID obtained from Hyperlinks
    var deal_match_param = '<?php echo $deal_match_param; ?>';
    
    
    $(function() {
        link_ui.layout_link_ui_child.cells('a').collapse();
        filter_form_obj = 'link_ui.filter_form';
        attach_browse_event(filter_form_obj, filter_function_id, '', 'n'); 
        if (mode == 'r') {
            read_only_mode();
        }
        
        link_ui.layout_link_ui_child.cells(grid_cell).attachStatusBar({
                                height: 30,
                                text: '<div id="pagingArea_c"></div>'
                            });
        link_ui.left_grid.setPagingWTMode(true,true,true,[10,20,30,40,50,60,70,80,90,100]);
        link_ui.left_grid.enablePaging(true, 25, 0, 'pagingArea_c'); 
        link_ui.left_grid.setPagingSkin('toolbar');
        
        link_ui.filter_form.setItemValue('effective_date_from', '<?php echo $default_as_of_date_from; ?>');
        link_ui.filter_form.setItemValue('effective_date_to', '<?php echo $default_as_of_date_to; ?>');
        link_ui.layout_link_ui_child.attachEvent("onCollapse", function(name){
            if (run_assessment_popup.isVisible()) {
                adjustpopupHeight('assessment', 80);
            } else if (run_measurement_popup.isVisible()) {
                adjustpopupHeight('measurement', 80);
            }
        });
        link_ui.layout_link_ui_child.attachEvent("onExpand", function(name){
            if (run_assessment_popup.isVisible()) {
                adjustpopupHeight('assessment', 80);
            } else if (run_measurement_popup.isVisible()) {
                adjustpopupHeight('measurement', 80);
            }
        });
        
        setTimeout(function(){
                if (hyper_link_id) {
                    link_ui.open_template_detail(hyper_link_id, deal_match_param);
                }
            }, 2500);
    });

    /*
    *[Function to convert date into client date format]
    */
    function client_date_format_converter(input_date) {        
        var dd = input_date.getDate();        
        var mm = input_date.getMonth() + 1;
        var y = input_date.getFullYear();
        mm = ((mm.toString()).split('').length == 1) ? ('0' + mm) : mm;
        dd = ((dd.toString()).split('').length == 1) ? ('0' + dd) : dd;
        
        if (client_date_format == '%n/%j/%Y' || client_date_format == '%m/%d/%Y') {
            return (mm + '/'+ dd + '/'+ y);
        } else if (client_date_format == '%j-%n-%Y' || client_date_format == '%d-%m-%Y') {
            return (dd + '-'+ mm + '-'+ y);
        } else if (client_date_format == '%j.%n.%Y' || client_date_format == '%d.%m.%Y') {
            return (dd + '.'+ mm + '.'+ y);
        } else if (client_date_format == '%j/%n/%Y' || client_date_format == '%d/%m/%Y') {
            return (dd + '/'+ mm + '/'+ y);
        } else if (client_date_format == '%n-%j-%Y' || client_date_format == '%m-%d-%Y') {
            return (mm + '-'+ dd + '-'+ y);
        }
    }

    /**
     * [Function to open measurement report in view report interface]
     */
    link_ui.open_measurement_report = function(id) {
        var link_id = get_selected_ids(link_ui.left_grid, 'lnk_id');
        if (link_id.indexOf(',') > 0) {
            dhtmlx.alert({type:"alert", title:'Information', text:"Please select single <b>Link ID</b>"});
            return;
        }
        var strategy_id = link_ui.filter_form.getItemValue('strategy_id');
        var subsidiary_id = link_ui.filter_form.getItemValue('subsidiary_id');
        var book_id = link_ui.filter_form.getItemValue('book_id');
        var book_structure_text = link_ui.filter_form.getItemValue('book_structure');
        var effective_date_to = link_ui.filter_form.getItemValue('effective_date_to');
        effective_date_to = dates.convert_to_sql(client_date_format_converter(effective_date_to));

        var url = '../../../../_reporting/view_report/view.report.php';
        var params = {flag:1, 
                     active_object_id:measurement_report_id,
                     report_type:2,
                     report_id:measurement_report_id,
                     report_name:'Measurement Report', 
                     link_id:link_id, 
                     strategy_id:strategy_id, 
                     subsidiary_id:subsidiary_id, 
                     book_id:book_id, 
                     book_structure_text:book_structure_text,
                     effective_date_to:effective_date_to
                 };

        //open_window_with_post(url,'measurement_report',params, '_self');
        report_win_obj = new dhtmlXWindows();
        w3 = report_win_obj.createWindow("w3", 0, 0, 1200, 500);
        w3.centerOnScreen();
        w3.maximize();
        w3.setText('View Report');
        w3.attachURL(url, false, params);
        w3.attachEvent("onClose", function(win) {
            return true;
        });
    }


    /**
     * [Function to open journal entry report in view report interface]
     */
    link_ui.open_journal_report = function() {
        var link_id = get_selected_ids(link_ui.left_grid, 'lnk_id');
        if (link_id.indexOf(',') > 0) {
            dhtmlx.alert({type:"alert", title:'Information', text:"Please select single <b>Link ID</b>"});
            return;
        }
        var strategy_id = link_ui.filter_form.getItemValue('strategy_id');
        var subsidiary_id = link_ui.filter_form.getItemValue('subsidiary_id');
        var book_id = link_ui.filter_form.getItemValue('book_id');
        var book_structure_text = link_ui.filter_form.getItemValue('book_structure');
        var effective_date_to = link_ui.filter_form.getItemValue('effective_date_to');
        effective_date_to = dates.convert_to_sql(client_date_format_converter(effective_date_to));
        
        var url = '../../../../_reporting/view_report/view.report.php';
        var params = {flag:1, 
                     active_object_id:journal_report_id,
                     report_type:2,
                     report_id:journal_report_id,
                     report_name:'Journal Entry Report',
                     link_id:link_id, 
                     strategy_id:strategy_id, 
                     subsidiary_id:subsidiary_id, 
                     book_id:book_id, 
                     book_structure_text:book_structure_text,
                     effective_date_to:effective_date_to
                 };

        report_win_obj = new dhtmlXWindows();
        w3 = report_win_obj.createWindow("w3", 0, 0, 1200, 500);
        w3.centerOnScreen();
        w3.maximize();
        w3.setText('View Report');
        w3.attachURL(url, false, params);
        w3.attachEvent("onClose", function(win) {
            return true;
        });
    }
    /**
     * [Function to open view report in view report interface]
     */
    link_ui.open_view_report = function() {
        var link_id = get_selected_ids(link_ui.left_grid, 'lnk_id');
        if (link_id.indexOf(',') > 0) {
            dhtmlx.alert({type:"alert", title:'Alert', text:"Please select single <b>Link ID</b>"});
            return;
        }

        var strategy_id = link_ui.filter_form.getItemValue('strategy_id');
        var subsidiary_id = link_ui.filter_form.getItemValue('subsidiary_id');
        var book_id = link_ui.filter_form.getItemValue('book_id');
        var book_structure_text = link_ui.filter_form.getItemValue('book_structure');
        var effective_date_to = link_ui.filter_form.getItemValue('effective_date_to');
        effective_date_to = dates.convert_to_sql(client_date_format_converter(effective_date_to));
        
        var url = '../../../../_reporting/view_report/view.report.php';
        
        var params = {flag:1, 
                     active_object_id:'<?php echo $hedge_position_report_id;?>',
                     report_type:1,
                     report_id:'<?php echo $hedge_position_report_id;?>',
                     report_param_id:'<?php echo $hedge_position_paramset_id;?>',
                     report_name:'Hedge Position Report',
                     link_id:link_id, 
                     strategy_id:strategy_id, 
                     subsidiary_id:subsidiary_id, 
                     book_id:book_id, 
                     book_structure_text:book_structure_text,
                     effective_date_to:effective_date_to,
                     call_from:'view_from_grid'
                 };

        report_win_obj = new dhtmlXWindows();
        w3 = report_win_obj.createWindow("w3", 0, 0, 1200, 500);
        w3.centerOnScreen();
        w3.maximize();
        w3.setText('View Report');
        w3.attachURL(url, false, params);
        w3.attachEvent("onClose", function(win) {
            return true;
        });
    }
    /**
     *
     */
    link_ui.onclick_menu = function(id) {
        switch (id) {
            case 'refresh':
                link_ui.refresh_summary_grid();
                break;
            case 'add':
                link_ui.load_template_detail('add');
                break;
            case 'delete':
                link_ui.delete_designation_hedge();
                break;
            case 'copy':
                link_ui.copy_designation_hedge();
                break;
            case 'excel':
                link_ui.left_grid.toExcel(js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                break;
            case 'pdf':
                link_ui.left_grid.toPDF(js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                break;
            case 'batch':
                link_ui.batch_designation();
                break;
            case 'dedesignate':
                link_ui.dedesignation_hedge();
                break;
            case 'run_assessment':
                link_ui.run_assessment();
                break;
            case 'run_measurement':
                link_ui.run_measurement();
                break;
            case 'r1':
                link_ui.open_hedge_documentation();
                break;
            case 'r2':
                link_ui.open_measurement_report('r2');
                break;
            case 'r3':
                link_ui.open_journal_report();
                break;
            case 'r4':
                link_ui.open_view_report();
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
    /**
     *
     */
    link_ui.refresh_summary_grid = function() {
        form_obj = link_ui.filter_form;
        form_data = form_obj.getFormData();
        var filter_param = '';
        form_obj.setValidation("apply_filters", "");
        var status = validate_form(form_obj);

        var e_date_from = form_obj.getItemValue('effective_date_from', true);
        var e_date_to = form_obj.getItemValue('effective_date_to', true);

        if (e_date_to >= e_date_from) {
            if (status) {
                link_ui.layout_link_ui_child.cells(grid_cell).progressOn();
                link_ui.layout_link_ui_child.cells('a').collapse();
                //link_ui.layout_link_ui.cells('b').collapse();
                filter_param = new Array();
                
                for (var a in form_data) {
                    if (form_data[a] != '' && form_data[a] != null) {
                        if (link_ui.filter_form.getItemType(a) == 'calendar') {
                            value = link_ui.filter_form.getItemValue(a, true);
                        } else {
                            value = form_data[a];
                        }
                        
                        
                        if (a != 'subbook_id' && a != 'book_structure' && a != 'apply_filters') {
                                filter_param.push("@" + a + '=' + singleQuote(value))   
                        }
                    }
                }
                
                filter_param = filter_param.toString();
                var flag = (function_id == '10232300') ? 'h' : 's';
                var sql_stmt = "EXEC spa_faslinkheader @flag=" + flag + ", " + filter_param;
                
                // load grid data
                var sql_param = {
                    "sql": sql_stmt,
                    "grid_type": 'g'
                };
        
                sql_param = $.param(sql_param);
                var sql_url = js_data_collector_url + "&" + sql_param;
                
                link_ui.left_grid.clearAll();
                link_ui.left_grid.load(sql_url, function() {
                    set_privileges();
                    link_ui.left_grid.filterByAll();
                    if (link_ui.left_grid.getRowsNum() > 0) {
                        link_ui.left_menu.setItemEnabled('batch');
                        if(function_id == 10232300){
                            link_ui.left_menu.setItemEnabled('export');
                            link_ui.left_menu.setItemEnabled('process');
                            link_ui.left_menu.setItemDisabled('add');
                            link_ui.left_menu.setItemEnabled('run_assessment');
                            link_ui.left_menu.setItemDisabled('dedesignate');
                        }
                    } else {
                        link_ui.left_menu.setItemDisabled('batch');                    
                        if(function_id == 10232300){
                            link_ui.left_menu.setItemDisabled('edit');
                            link_ui.left_menu.setItemDisabled('export');
                            link_ui.left_menu.setItemDisabled('process');
                            link_ui.left_menu.setItemDisabled('report');
                        }
                    }
                    link_ui.layout_link_ui_child.cells(grid_cell).progressOff();
                });                
            }
        } else {
            show_messagebox('<b>Effective Date To</b> must be Greater than <b>Effective Date From</b>.');
            return;
        }
    }
    /**
     *
     */
    link_ui.load_template_detail = function(id, param1) {
        link_ui.layout_link_ui.cells('a').collapse();
        var grid_obj = link_ui.left_grid;
        var link_id = -1;
        var link_name = 'New';
        var allow_change = true;   
        var assessment_result = 0; 
        param1 = (param1 == undefined) ? 'New' : param1;
 
        if (id != 'add') {
            selected_row = link_ui.left_grid.getSelectedRowId();
            link_id = link_ui.left_grid.cells(selected_row, 13).getValue();
            //alert(link_id)
            link_name = link_ui.left_grid.cells(selected_row, 1).getValue();
            allow_change = get_allow_change(link_ui.left_grid, 'allow_change');  
            assessment_result = get_selected_ids(link_ui.left_grid, 'assessment_result');   
        }
         
        var frame_obj = link_ui.layout_link_ui.cells("b").getFrame();
        frame_obj.contentWindow.link_ui_template.load_link_detail(link_id,link_name,function_id,allow_change,assessment_result,param1);
        
    }      
    /**
     *
     */
    link_ui.open_template_detail = function(id, param1) {
        //var grid_obj = link_ui.left_grid;
        link_ui.layout_link_ui.cells('a').collapse();
        var link_id = -1;
        var link_name = 'New';
        var allow_change = true;   
        var assessment_result = 0;  
        if (id != 'add') {
            link_id = id;
            link_name = id;
            allow_change = true;//get_allow_change(grid_obj, 'allow_change');  
            assessment_result = id;//get_selected_ids(link_ui.left_grid, 'assessment_result');   
        }
         
        var frame_obj = link_ui.layout_link_ui.cells("b").getFrame();
        frame_obj.contentWindow.link_ui_template.load_link_detail(link_id,link_name,10233700,allow_change,assessment_result,param1);
        
    }      
    /**
     *
     */
    link_ui.delete_designation_hedge = function() {
        var allow_change = get_allow_change(link_ui.left_grid, 'allow_change');
        var confirm_msg = 'Please confirm  to delete the selected hedging relationship';
        
        if (has_rights_update_delete_closed_hedge == true && allow_change == "No"){
            var confirm_msg = 'The link is locked. Do you wish to continue?';
        }
        
        dhtmlx.confirm({
                title:"Confirmation",
                ok: "Confirm",
                text: confirm_msg,
                callback:function(result){
                    if (result) {
                        dhtmlx.confirm({
                            type:"confirm-warning",
                            title:"Confirmation",
                            ok:"Yes",
                            cancel:"No",
                            text:"Do you want to delete Forecasted Transactions as well?",
                            callback:function(result){
								link_ui.layout_link_ui_child.cells('b').progressOn();
                                var link_id = get_selected_ids(link_ui.left_grid, 'lnk_id');
                                if (result) {
                                    data = {
                                        "action": "spa_reject_finalized_link",
                                        "link_id": link_id
                                    }
                                } else {
                                    data = {
                                        "action": "spa_faslinkheader", 
                                        "flag": "d", 
                                        "link_id": link_id
                                    }
                                }
                                result = adiha_post_data("return_array", data, "", "","post_delete_designation_hedge");
                            }
                        });
                    }
                }
            });
                 
    }  

    link_ui.get_id = function(grid, r_id) {
        var col_type = grid.getColType(0);
        if (col_type == "tree") {
            var id = "tab_" + grid.cells(r_id, 1).getTitle();
        } else {
            var id = "tab_" + grid.cells(r_id, 0).getTitle();
        }
        return id;
    }

    /**
     *
     */
    function post_delete_designation_hedge(result) {
		link_ui.layout_link_ui_child.cells('b').progressOff();
        var content_window = link_ui.layout_link_ui.cells('b').getAttachedObject().contentWindow.link_ui_template;
        var tab_cell_obj = content_window.template_layout.cells('a').getAttachedObject();
        if (result[0][0] == "Success") {
            var select_id = link_ui.left_grid.getSelectedRowId();
            select_id = select_id.split(',');
            select_id.forEach(function(val) {
                var full_id = link_ui.get_id(link_ui.left_grid, val);
                if (tab_cell_obj.tabs(full_id)) {
                    tab_cell_obj.tabs(full_id).close();
                }
            });
            link_ui.left_menu.setItemDisabled("delete");
            link_ui.left_grid.deleteSelectedRows();
            dhtmlx.message({
                text:result[0][4],
                expire:1000
            });
        } else {
            dhtmlx.message({
                type: "alert-error",
                title: "Error",
                text: result[0][4]
            });
        }
    }
    /**
     *
     */    
    link_ui.copy_designation_hedge = function() {
        var transfer_book_name = '';
        var transfer_book_id = '';
        
        link_ui.unload_window();
        if (!status_window) {
            status_window = new dhtmlXWindows();
        }
        var selected_ids = get_selected_ids(link_ui.left_grid, 'lnk_id');
        var width = 450;
        var height = 600;
        var win_title = 'Book Structure';
        var win_url = 'open.book.structure.php';
        var win = status_window.createWindow('w1', 0, 0, width, height);
        win.setText(win_title);
        win.centerOnScreen();
        win.setModal(true);
        //win.button('minmax').hide();
        win.button('park').hide();
        
        win.attachURL(win_url, false, {function_id:function_id});

        win.attachEvent('onClose', function(w) {
            var ifr = w.getFrame();
            var ifrWindow = ifr.contentWindow;
            var ifrDocument = ifrWindow.document;
            var close_status = $('textarea[name="close_status"]', ifrDocument).val();
            transfer_book_id = $('input[name="book_id"]', ifrDocument).val();
            transfer_book_name = $('input[name="book_name"]', ifrDocument).val();
            
            if (close_status == 'btnOk') {
                if (transfer_book_name == '') {
                    dhtmlx.alert({
                        title:"Alert",
                        type:"alert-error",
                        text:"Please select transfer book."
                    });
                    return;
                }
                
                var selected_ids = get_selected_ids(link_ui.left_grid, 'lnk_id');
                
                if (selected_ids == '' || selected_ids == null) {
                    dhtmlx.alert({
                        title:"Alert",
                        type:"alert-error",
                        text:"Please select link to copy."
                    });
                    return;
                }
                
                var confirm_msg = 'Please confirm to copy to Book ' + transfer_book_name;
                dhtmlx.message({
                            type: "confirm",
                            title: "Confirmation",
                            ok: "Confirm",
                            text: confirm_msg,
                            callback: function(result) {
                                if (result) {                                        
                                    data = {
                                        "action": "spa_copy_link",
                                        "flag": "c",
                                        "link_id": selected_ids,
                                        "book_id": transfer_book_id, 
                                    }
                                    adiha_post_data("return_array", data, "", "", "link_ui.refresh_summary_grid");
                                }
                            }
                        });
            }
            return true;
        });
    }
    /**
     *
     */
    link_ui.unload_window = function() {        
        if (status_window != null && status_window.unload != null) {
            status_window.unload();
            status_window = w1 = null;
        }
    }
    /**
     *
     */
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
    /**
     *
     */    
    link_ui.dedesignation_hedge = function() {
        var link_id = get_selected_ids(link_ui.left_grid, 'lnk_id');
        var new_win = new dhtmlXWindows();
        var win_id = 'w1';
        win_obj = new_win.createWindow(win_id, 0, 0, 480, 500);
        win_obj.setModal(true);
        
        var win_title = 'Dedesignate Multiple Hedges';
        var win_url = './dedes.of.a.hedge.iu.php';  
        var params = {selected_link_id:link_id,disable:0,call_from:'hedges',post_dedesignate:'link_ui.post_dedesignation_hedge'};
        
        win_obj.setText(win_title);
        win_obj.centerOnScreen();
        win_obj.attachURL(win_url, false, params);        
               
        
    }
    /**
     *
     */
    link_ui.post_dedesignation_hedge = function() {
        win_obj.close();
        link_ui.refresh_summary_grid();
        disabled_all_btn(); 
        
        
    }     
    /**
     *
     */
    link_ui.open_hedge_documentation = function() {
        var link_id = get_selected_ids(link_ui.left_grid, 'lnk_id');

        if (link_id.indexOf(',') > 0) {
            dhtmlx.alert({type:"alert", title:'Information', text:"Please select single <b>Link ID</b>"});
            return;
        }
        link_ui.layout_link_ui_child.cells('b').progressOn();
        generate_document_for_view(link_id, '48', '', 'open_hedge_documentation_callback');
    }
    
    open_hedge_documentation_callback = function(status, file_path) {
		link_ui.layout_link_ui_child.cells('b').progressOff();
    }  
    
    /**
     *
     */
    function open_hedge_documentation_report(url) {
        hedge_doc_window = new dhtmlXWindows();
        var new_win = hedge_doc_window.createWindow('w1', 0, 0, 1200, 520);
        new_win.setText("Hedging Documentation");
        new_win.centerOnScreen();
        new_win.setModal(true);
        new_win.attachURL(url, false, true);
    }

    /**
     *
     */
    function disabled_all_btn () {
        link_ui.left_menu.setItemDisabled('copy');
        link_ui.left_menu.setItemDisabled('dedesignate');
        link_ui.left_menu.setItemDisabled('delete');
        link_ui.left_menu.setItemDisabled('run_assessment');
        link_ui.left_menu.setItemDisabled('run_measurement');
         
    }
    /**
     *
     */
    link_ui.batch_designation = function() {
        form_obj = link_ui.filter_form;
        var link_id_from = form_obj.getItemValue('link_id_from');
        var link_id_to = form_obj.getItemValue('link_id_to');
        var effective_date_from = form_obj.getItemValue('effective_date_from', true);
        var effective_date_to = form_obj.getItemValue('effective_date_to', true);
        var deal_id = form_obj.getItemValue('deal_id');
        var ref_id = form_obj.getItemValue('ref_id');
        var sort_order = form_obj.getItemValue('sort_order');
        var fully_dedesignated = form_obj.getItemValue('fully_dedesignated');
        var link_active = form_obj.getItemValue('link_active');
        var subsidiary_id = form_obj.getItemValue('subsidiary_id');
        var strategy_id = form_obj.getItemValue('strategy_id');
        var book_id = form_obj.getItemValue('book_id');
        var link_id_from = form_obj.getItemValue('link_id_from');
        var link_id_to = form_obj.getItemValue('link_id_to');
        var param_list = new Array();

        param_list.push("'" + book_id + "'");
        param_list.push("'" + fully_dedesignated + "'");
        param_list.push("'" + link_active + "'");
        param_list.push("'" + effective_date_from + "'");
        param_list.push("'" + effective_date_to + "'");
        param_list.push("NULL");
        param_list.push("NULL");
        param_list.push("NULL");
        param_list.push("NULL");
        param_list.push("NULL");
        param_list.push("'" + link_id_from + "'");
        param_list.push("'" + link_id_to + "'");
        param_list.push("'" + sort_order + "'");
        param_list.push("'" + deal_id + "'");
        param_list.push("'" + ref_id + "'");
        param_list.push("NULL");
        param_list.push("'" + subsidiary_id + "'");
        param_list.push("'" + strategy_id + "'");
        
        var param_string = param_list.toString();
        param_string = param_string.replace(/""/g, 'NULL');
        param_string = param_string.replace(/''/g, 'NULL');
        
        var sql_stmt = "EXEC spa_faslinkheader 's', NULL, " + param_string;
        
        var arg = 'call_from=batch_report&gen_as_of_date=0&batch_type=r';
        var title = '<?php echo $title; ?>';       
        adiha_run_batch_process(sql_stmt, arg, title);
        
    }
    /**
     *
     */
    function unload_hedge_run_status_window() {        
        if (hedge_run_status_window != null && hedge_run_status_window.unload != null) {
            hedge_run_status_window.unload();
            hedge_run_status_window = w1 = null;
        }
    }
    var as_date_of_run_assessment = dates.convert_to_user_format('<?php echo $default_as_of_date_to; ?>');
    var run_assessment_form_data =   [  
                    {  
                      "type":"settings",
                      "position":"label-top"
                    },
                    {  
                      type:"block",
                      blockOffset:10,      
                      
                      list:[  
                         {  
                            "type":"calendar",
                            "name":"as_date_of",
                            "label":"As of Date",
                            "validate": "NotEmptywithSpace",
                            "position":"label-top",
                            "offsetLeft":"5",
                            "labelWidth":"130",
                            "inputWidth":"120",
                            "value": '<?php echo $default_as_of_date_to; ?>',
                            "tooltip":"",
                            "required": "true",
                            "dateFormat": '<?php echo $date_format; ?>',
                            "serverDateFormat": "%Y-%m-%d",
                            "calendarPosition": "bottom"
                         },
                         
                         {  "type":"combo",
                            "name":"inception",
                            "label":"Assessment Type","validate":"",
                            "hidden":"false",
                            "disabled":"false", 
                             "offsetLeft":"5",
                            "options":[{"value":"o","text":"Ongoing"},{"value":"i","text":"Inception"} ],
                            "inputWidth":"120",
                        },
                        {type: "button", value: "Ok", img: "tick.png"}
                 
                         
                      ]
                    }
                ];
                
    
    var run_assessment_popup = new dhtmlXPopup();
    var run_assessment_form_data = run_assessment_popup.attachForm(run_assessment_form_data);
    //run_assessment_form_data.setCalendarDateFormat('as_date_of', as_date_of_run_assessment);
    //run_assessment_form_data.setItemValue("as_date_of", as_date_of_run_assessment);
    var inception_combo_obj = run_assessment_form_data.getCombo('inception');
    inception_combo_obj.enableFilteringMode(true);
    
    run_assessment_form_data.attachEvent("onButtonClick", function(){        
        var validate_return = validate_form(run_assessment_form_data);
    
        if (validate_return === false) {
            return;
        }
        
        call_run_assessment();
        toggle_run_assessment_popup();
    });    
    /**
     *
     */
    link_ui.run_assessment = function() {
      toggle_run_assessment_popup();
    }    
    /**
     *
     */
    function adjustpopupHeight(type,width){
        var a = link_ui.layout_link_ui_child.cells('a').getHeight();
        var height = a + 65; 
        
        if(type == 'assessment') {
            run_assessment_popup.show(240, height, width, 5); 
        } else if (type == 'measurement' ) {
            run_measurement_popup.show(240, height, width, 5); 
        }
    }
    /**
     *
     */
    function toggle_run_assessment_popup () {
        
        if (run_assessment_popup.isVisible()) {
            run_assessment_popup.hide();
        } else {
            adjustpopupHeight('assessment', 80);           
        }
    }
    /**
     *
     */
    function hide_run_assessment_popup() {
        run_assessment_popup.hide();
    }
    /**
     *
     */
    link_ui.run_measurement = function() {
        var link_id = get_selected_ids(link_ui.left_grid, 'link_id');
        if (link_id == null || link_id == '') {
            dhtmlx.alert({
                   title: 'Error',
                   type: "alert-error",
                   text: 'Please select link to run measurement'
                });
        }
        toggle_run_mesaurment_popup();
        
    }
    
    var run_measurement_form_data =   [  
                    {  
                      "type":"settings",
                      "position":"label-top"
                    },
                    {  
                      type:"block",
                      blockOffset:10,
                      list:[  
                         {  
                            "type":"calendar",
                            "name":"as_date_of",
                            "label":"As of Date",
                            "validate": "NotEmptywithSpace",
                            "position":"label-top",
                            "offsetLeft":"5",
                            "labelWidth":"130",
                            "inputWidth":"120",
                            "value": '<?php echo $default_as_of_date_to; ?>',
                            "tooltip":"",
                            "required": "true",
                            "dateFormat": '<?php echo $date_format; ?>',
                            "serverDateFormat": "%Y-%m-%d",
                            "calendarPosition": "bottom"
                         },
                        {type: "button", value: "Ok", img: "tick.png"}
                 
                         
                      ]
                    }
                ];
    
    var run_measurement_popup = new dhtmlXPopup();
    var run_measurement_form_data = run_measurement_popup.attachForm(run_measurement_form_data);    
    run_measurement_form_data.attachEvent("onButtonClick", function(){        
        call_run_measurement();
        toggle_run_mesaurment_popup();
    });  
    /**
     *
     */
    function toggle_run_mesaurment_popup () {
        if (run_measurement_popup.isVisible()) {
            run_measurement_popup.hide();
        } else {
            adjustpopupHeight('measurement', 80);
            
        }
    }
    /**
     *
     */
    function get_active_tab_id() {
        var active_tab_id = link_ui.tabbar.getActiveTab(); 
        active_tab_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        return active_tab_id;
    } 
    /**
     *
     */
    function set_privileges () {
        if (mode == 'r') {
            read_only_mode();
            return;
        }
        var row_id = link_ui.left_grid.getSelectedRowId();
        if (row_id == null) {
            disabled_all_btn();
            return;
        }
        var allow_change = get_allow_change(link_ui.left_grid, 'allow_change');
        row_id_arr = row_id.split(',');
        var link_ids = [];
        row_id_arr.forEach(function(val) {
            var link_id = link_ui.left_grid.cells(val, 0).getValue();
            link_ids.push(link_id);
        });
        
        //Disabled button is enabled only if designation is not closed and has delete rights.
        if (has_rights_designation_of_hedge_delete == true && allow_change == true){
            link_ui.left_menu.setItemEnabled('delete');
        } else {
            link_ui.left_menu.setItemDisabled('delete');
        }

        link_ids = link_ids.toString();
        
        //Allow to process for single id only
        if (row_id.indexOf(",") != -1 || row_id == null){
            link_ui.left_menu.setItemDisabled('copy');
            link_ui.left_menu.setItemDisabled('dedesignate');
            link_ui.left_menu.setItemDisabled('run_assessment');
            link_ui.left_menu.setItemDisabled('run_measurement');            
        } else if (link_ids.indexOf("-") != -1) {
            link_ui.left_menu.setItemDisabled('copy');
            link_ui.left_menu.setItemDisabled('dedesignate');
            link_ui.left_menu.setItemDisabled('r1');
            
            if (function_id != 10232300) {
                if (has_rights_run_assessement) {
                    link_ui.left_menu.setItemEnabled('run_assessment'); 
                }
                
                if (has_rights_run_measurement) {
                    link_ui.left_menu.setItemEnabled('run_measurement');  
                }
            }    
        } else {
            link_ui.left_menu.setItemEnabled('r1');
            
            if (function_id != 10232300) { 
                if (has_rights_designation_of_hedge_copy) {
                    link_ui.left_menu.setItemEnabled('copy');
                } 

                if (has_rights_de_designation) {
                    link_ui.left_menu.setItemEnabled('dedesignate');
                }

                if (has_rights_run_assessement) {
                    link_ui.left_menu.setItemEnabled('run_assessment'); 
                }
                if (has_rights_run_measurement) {
                    link_ui.left_menu.setItemEnabled('run_measurement');  
                }
            
            }
        }

        row_id_arr.forEach(function(val) {
            var link_desc = link_ui.left_grid.cells(val, 1).getValue();
            if (link_desc.indexOf('DeDesignation1') >= 0) {
                link_ui.left_menu.setItemDisabled('dedesignate');
            }
        });
    }
    /**
     *
     */
    function get_allow_change(grid_obj, column_name) {
        var rid = grid_obj.getSelectedRowId();
        if (!rid) return false;
        var rid_array = new Array();
        if (rid.indexOf(",") != -1) {
            rid_array = rid.split(',');
        } else {
            rid_array.push(rid);
        }
        
        var cid = grid_obj.getColIndexById(column_name);
        var allow_change = true;
        $.each(rid_array, function( index, value ) {
            
            if (grid_obj.cells(value,cid).getValue() != 'Yes')
                allow_change = false;          
        });
        
        return allow_change;
    }
    /**
     *
     */
    function lock_link_checked() {
        var active_tab_id = get_active_tab_id();
        var is_locked = link_ui.details_form["details_form_" + active_tab_id + "_0"].isItemChecked('lock');
        var attached_toolbar = link_ui.tabbar.cells('tab_' + active_tab_id).getAttachedToolbar();
        
        if (is_locked) {
           attached_toolbar.disableItem('save'); 
           link_ui.details_menu["details_menu_dedesignation_" + active_tab_id].setItemDisabled('edit');
           link_ui.details_menu["details_menu_assessment_result_" + active_tab_id].setItemDisabled('edit');
           
        } else {
           attached_toolbar.enableItem('save');  
           link_ui.details_menu["details_menu_dedesignation_" + active_tab_id].setItemEnabled('edit');
           link_ui.details_menu["details_menu_assessment_result_" + active_tab_id].setItemEnabled('edit');
        }
            
    }
    /**
     *
     */
    function call_run_assessment(){        
        unload_hedge_run_status_window();
        var as_of_date_assessment = run_assessment_form_data.getItemValue('as_date_of',true);       
        var inception = run_assessment_form_data.getItemValue('inception')
        var param = 'call_from=Run Assessment&gen_as_of_date=1&batch_type=c&as_of_date=' + as_of_date_assessment ;
        var title = 'Run Assessment';
        var assessment_id = get_selected_ids(link_ui.left_grid, 'assessment_id');        
        var form_obj = link_ui.filter_form;
        var subsidiary_id = form_obj.getItemValue('subsidiary_id');
        var strategy_id = form_obj.getItemValue('strategy_id');
        var book_id = form_obj.getItemValue('book_id');
        var exec_call = "EXEC runAssessment_main " +
                        singleQuote(subsidiary_id) + ", " + 
                        singleQuote(strategy_id) + ", " + 
                        singleQuote(book_id) + ", " +
                        singleQuote(assessment_id) + ", " +
                        singleQuote(inception) + ", " +
                        singleQuote(as_of_date_assessment) + ", " +
                        singleQuote(js_user_name) + ", " +
                        "null, null"; 
                      
        adiha_run_batch_process(exec_call, param, title);       
    }
    /**
     *
     */
    function call_run_measurement(){
        unload_hedge_run_status_window();
        var as_of_date_measurement = run_measurement_form_data.getItemValue('as_date_of',true);       
        var param = 'call_from=hedge_effectiveness_assessment&gen_as_of_date=1&batch_type=r&as_of_date=' + as_of_date_measurement;
        var title = 'Run Measurement';
        
        if (!as_of_date_measurement) {
            show_messagebox("To As Of Date Cannot be empty.")
            return;
        }      
        
        var link_id = get_selected_ids(link_ui.left_grid, 'lnk_id');
        var subsidiary_id = form_obj.getItemValue('subsidiary_id');
        var strategy_id = form_obj.getItemValue('strategy_id');
        var book_id = form_obj.getItemValue('book_id');
        var exec_call = "EXEC spa_run_measurement_process_job " +
                        singleQuote('NULL') + ", " +
                        singleQuote('NULL') + ", " + 
                        singleQuote('NULL') + ", " + 
                        singleQuote(as_of_date_measurement) + ", " + 
                        singleQuote('NULL') + ", " +
                        singleQuote('NULL') + ", " + 
                        singleQuote('NULL') + ", " +                        
                        singleQuote('farrms_user') + ", " + 
                        singleQuote('0') + ", " +
                        singleQuote('n') + ", " +
                        singleQuote(link_id) + ", " +
                        singleQuote('NULL') + ", " +
                        singleQuote('NULL') + ", " + 
                        singleQuote('NULL') + ", " + 
                        singleQuote('NULL');
        adiha_run_batch_process(exec_call, param, title);
        
    }
    /**
     *
     */
    function read_only_mode () {
        var row_id = link_ui.left_grid.getSelectedRowId();
        if (row_id == null) {
           link_ui.left_menu.setItemDisabled('run_assessment');
        } else {
            link_ui.left_menu.setItemEnabled('run_assessment');
        }

        link_ui.left_menu.setItemDisabled('add');
        link_ui.left_menu.setItemDisabled('delete');
        link_ui.left_menu.setItemDisabled('copy');
        link_ui.left_menu.setItemDisabled('dedesignate');
        //
        link_ui.left_menu.setItemDisabled('run_measurement');
        link_ui.left_menu.setItemDisabled('r1');
        link_ui.left_menu.setItemDisabled('r2');
        link_ui.left_menu.setItemDisabled('r3');
         
    }
    /**
     *
     */
    function post_link_update() {
       if (link_ui.filter_form.getItemValue('book_id') != '') {
           link_ui.refresh_summary_grid(); 
        }  
    }

    link_ui.custom_load = function(func_id, arg1) {
        var grid_obj = link_ui.left_grid;
        var allow_change = true;   
        var assessment_result = 0;  
        allow_change = get_allow_change(grid_obj, 'allow_change');  

        assessment_result = get_selected_ids(link_ui.left_grid, 'assessment_result');   
        var frame_obj1 = link_ui.layout_link_ui.cells('b').getFrame();
        frame_obj1.contentWindow.link_ui_template.load_link_detail(arg1,'',func_id,allow_change,assessment_result);
      
     }
     
</script>
</html>