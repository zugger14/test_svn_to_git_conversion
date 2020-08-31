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
    $rights_tranfer_recs = 20016300;
    $rights_export_recs = 20016301;
    
    list (
        $has_rights_tranfer_recs,
        $has_rights_export_recs
    ) = build_security_rights(
        $rights_tranfer_recs,
        $rights_export_recs
    );
        
    $namespace = 'transfer_recs_ui';
    $layout_obj = new AdihaLayout();
        
    $layout_json = '[
                        {id: "a", width:380, text: "Filter Criteria",header: true, collapse: false, fix_size: [false,null]},
                        {id: "b", text: "Form",header: false, collapse: false, hidden:true, fix_size: [false,null]},                      
                    ]';
    
    $patterns = '2U';
    $layout_name = 'layout_link_ui';
    echo $layout_obj->init_layout($layout_name, '', $patterns, $layout_json, $namespace);

    $left_layout_json_inner = '[
                    {id: "a", text: "Filter", header: true, collapse: false, height: 100},
                    {id: "b", height:255, text: "Filter Criteria",header: true, collapse: false, fix_size: [false,null]},
                    {id: "c", text: "Matches",header: true, collapse: false, fix_size: [false,null]}
                ]';
    
    $patterns_inner = '3E';
    $grid_cell = 'c';

    $left_layout_name_inner = 'left_layout_link_ui_inner';
    $left_inner_layout_obj = new AdihaLayout();
    echo $layout_obj->attach_layout_cell($left_layout_name_inner, 'a', $patterns_inner, $left_layout_json_inner);
    echo $left_inner_layout_obj->init_by_attach($left_layout_name_inner, $namespace);

    $right_layout_json_inner = '[
                    {id: "a", text: "Filter", header: true, collapse: false, height: 100},
                    {id: "b", height:255, text: "Transfer Status",header: true, collapse: false, fix_size: [false,null]},
                    {id: "c", text: "Transfer Status Detail",header: true, collapse: false, fix_size: [false,null]}
                ]';
    
    $right_layout_name_inner = 'right_layout_detail_inner';
    $right_inner_layout_obj = new AdihaLayout();
    echo $layout_obj->attach_layout_cell($right_layout_name_inner, 'b', $patterns_inner, $right_layout_json_inner);
    echo $right_inner_layout_obj->init_by_attach($right_layout_name_inner, $namespace);
   
    $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id=". $rights_tranfer_recs . ", @template_name='transfer_recs', @group_name='Filter'";
    $return_value = readXMLURL($xml_file);
    $form_json = $return_value[0][2];
    
    $filter_name = 'filter_form';
    echo $left_inner_layout_obj->attach_form($filter_name, 'b');
    $filter_obj = new AdihaForm();
    echo $filter_obj->init_by_attach($filter_name, $namespace);
    echo $filter_obj->load_form($form_json);

    $filter_name = 'apply_filter';
    $filter_obj = new AdihaForm();
    echo $left_inner_layout_obj->attach_form($filter_name, 'a');        
    echo $filter_obj->init_by_attach($filter_name, $namespace);
    echo $filter_obj->load_form_filter($namespace, $filter_name, $left_layout_name_inner, 'b', $rights_tranfer_recs, 2);
    
    $menu_obj = new AdihaMenu();
    $menu_name = 'link_menu';
    $menu_json = '[{ id: "refresh", img: "refresh.gif", text: "Refresh", title: "Refresh"},
                    {id: "transfer", text: "Transfer", img:"transfer.gif", imgdis:"transfer_dis.gif", enabled:"false"},
                    {id: "export", enabled: true, img:"export.gif", imgdis: "export_dis.gif", text: "Export", items:[
                        {id: "excel", text: "Excel", img:"excel.gif", imgdis:"excel_dis.gif", enabled:true},
                        {id: "pdf", text: "PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", enabled:true}
                        ]
                    }                   
                ]';

    echo $menu_obj->attach_menu_layout_header($namespace, $left_layout_name_inner, 'c', $menu_name, $menu_json, $namespace . '.onclick_menu');
    echo $left_inner_layout_obj->attach_status_bar($grid_cell, true);
    //Attaching grid in cell 'c'
    $grid_obj = new AdihaGrid();
    $grid_name = 'link_grid';
    echo $left_inner_layout_obj->attach_grid_cell($grid_name, $grid_cell);
    
    $xml_file = "EXEC spa_adiha_grid 's','rec_transfer'";
    $resultset = readXMLURL2($xml_file);
    echo $grid_obj->init_by_attach($grid_name, $namespace);
    echo $grid_obj->set_header($resultset[0]['column_label_list']);
    echo $grid_obj->set_columns_ids($resultset[0]['column_name_list']);
    echo $grid_obj->set_widths($resultset[0]['column_width']);
    echo $grid_obj->set_column_types($resultset[0]['column_type_list']);
    echo $grid_obj->set_sorting_preference($resultset[0]['sorting_preference']);
    echo $grid_obj->set_column_auto_size(true);
    echo $grid_obj->set_column_visibility($resultset[0]['set_visibility']);
    echo $grid_obj->enable_multi_select(true);
    echo $grid_obj->enable_paging(100, 'pagingArea_c', 'true');    
    echo $grid_obj->set_search_filter(true);
    echo $grid_obj->return_init();  
	echo $grid_obj->enable_filter_auto_hide();	
    
    //Status filter Form
    $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id=". $rights_tranfer_recs . ", @template_name='transfer_recs', @group_name='Transfer Details'";
    $return_value = readXMLURL($xml_file);
    $form_json = $return_value[0][2];
    
    $transfer_status_filter_name = 'transfer_status_filter_form';
    echo $right_inner_layout_obj->attach_form($transfer_status_filter_name, 'a');
    $transfer_status_filter_obj = new AdihaForm();
    echo $transfer_status_filter_obj->init_by_attach($transfer_status_filter_name, $namespace);
    echo $transfer_status_filter_obj->load_form($form_json);

    //Attaching grid in cell 'b'
    $transfer_status_menu_obj = new AdihaMenu();
    $transfer_status_menu_name = 'transfer_status_menu';
    $transfer_status_menu_json = '[{ id: "refresh", img: "refresh.gif", text: "Refresh", title: "Refresh"},
                                    {id: "export", enabled: true, img:"export.gif", imgdis: "export_dis.gif", text: "Export", items:[
                                        {id: "excel", text: "Excel", img:"excel.gif", imgdis:"excel_dis.gif", enabled:true},
                                        {id: "pdf", text: "PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", enabled:true}
                                        ]
                                    }]';

    echo $right_inner_layout_obj->attach_menu_cell($transfer_status_menu_name, 'b');
    echo $transfer_status_menu_obj->init_by_attach($transfer_status_menu_name, $namespace);
    echo $transfer_status_menu_obj->load_menu($transfer_status_menu_json);
    echo $transfer_status_menu_obj->attach_event('', 'onClick', $namespace . '.refresh_transfer_status_grid');
    
    $transfer_status_grid_obj = new AdihaGrid();
    $transfer_status_grid_name = 'transfer_status_grid';
    echo $right_inner_layout_obj->attach_grid_cell($transfer_status_grid_name, 'b');
    
    $xml_file = "EXEC spa_adiha_grid 's','rec_transfer_status'";
    $resultset = readXMLURL2($xml_file);
    echo $transfer_status_grid_obj->init_by_attach($transfer_status_grid_name, $namespace);
    echo $transfer_status_grid_obj->set_header($resultset[0]['column_label_list']);
    echo $transfer_status_grid_obj->set_columns_ids($resultset[0]['column_name_list']);
    echo $transfer_status_grid_obj->set_widths($resultset[0]['column_width']);
    echo $transfer_status_grid_obj->set_column_types($resultset[0]['column_type_list']);
    echo $transfer_status_grid_obj->set_sorting_preference($resultset[0]['sorting_preference']);
    echo $transfer_status_grid_obj->set_column_auto_size(true);
    echo $transfer_status_grid_obj->set_column_visibility($resultset[0]['set_visibility']);
    echo $transfer_status_grid_obj->enable_multi_select(true);
    echo $transfer_status_grid_obj->enable_filter_auto_hide();
    echo $transfer_status_grid_obj->set_search_filter(true);
    echo $transfer_status_grid_obj->return_init();

    //Attaching grid in cell 'c'
    $transfer_status_detail_menu_obj = new AdihaMenu();
    $transfer_status_detail_menu_name = 'transfer_status_detail_menu';
    $transfer_status_detail_menu_json = '[{ id: "refresh", img: "refresh.gif", text: "Refresh", title: "Refresh"},
                                        {id: "export", enabled: true, img:"export.gif", imgdis: "export_dis.gif", text: "Export", items:[
                                            {id: "excel", text: "Excel", img:"excel.gif", imgdis:"excel_dis.gif", enabled:true},
                                            {id: "pdf", text: "PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", enabled:true}
                                            ]
                                        }]';

    echo $right_inner_layout_obj->attach_menu_cell($transfer_status_detail_menu_name, 'c');
    echo $transfer_status_detail_menu_obj->init_by_attach($transfer_status_detail_menu_name, $namespace);
    echo $transfer_status_detail_menu_obj->load_menu($transfer_status_detail_menu_json);
    echo $transfer_status_detail_menu_obj->attach_event('', 'onClick', $namespace . '.refresh_transfer_status_detail_grid');

    $transfer_status_detail_grid_obj = new AdihaGrid();
    $transfer_status_detail_grid_name = 'transfer_status_detail_grid';
    echo $right_inner_layout_obj->attach_grid_cell($transfer_status_detail_grid_name, 'c');
    
    $xml_file = "EXEC spa_adiha_grid 's','rec_trasfer_status_detail'";
    $resultset = readXMLURL2($xml_file);
    echo $transfer_status_detail_grid_obj->init_by_attach($transfer_status_detail_grid_name, $namespace);
    echo $transfer_status_detail_grid_obj->set_header($resultset[0]['column_label_list']);
    echo $transfer_status_detail_grid_obj->set_columns_ids($resultset[0]['column_name_list']);
    echo $transfer_status_detail_grid_obj->set_widths($resultset[0]['column_width']);
    echo $transfer_status_detail_grid_obj->set_column_types($resultset[0]['column_type_list']);
    echo $transfer_status_detail_grid_obj->set_sorting_preference($resultset[0]['sorting_preference']);
    echo $transfer_status_detail_grid_obj->set_column_auto_size(true);
    echo $transfer_status_detail_grid_obj->set_column_visibility($resultset[0]['set_visibility']);
    echo $transfer_status_detail_grid_obj->enable_multi_select(true);
    echo $transfer_status_detail_grid_obj->set_search_filter(true);
    echo $transfer_status_detail_grid_obj->enable_filter_auto_hide();
    echo $transfer_status_detail_grid_obj->return_init();
    echo $layout_obj->close_layout();    
    ?>
</body>
<script>
    var filter_application_function_id = '<?php echo $rights_tranfer_recs;?>';
    var has_rights_export_recs = Boolean(<?php echo $has_rights_export_recs; ?>);
        
    $(function() {
        attach_browse_event('transfer_recs_ui.filter_form',filter_application_function_id);
        transfer_recs_ui.refresh_link_grid_clicked();

        var status_combo_obj = transfer_recs_ui.filter_form.getCombo('status');
        
        status_combo_obj.attachEvent('onChange', function(value, text) {
            if (value == '112102' || value == '112103') {
                transfer_recs_ui.link_menu.setItemDisabled('transfer');
            } else {
                var count = transfer_recs_ui.link_grid.getRowsNum();
                if (has_rights_export_recs && count != 0) 
                    transfer_recs_ui.link_menu.setItemEnabled('transfer');
            }                
        })     
    })   
    
    transfer_recs_ui.onclick_menu = function(id) {
        switch (id) {
            case 'refresh':
                transfer_recs_ui.left_layout_link_ui_inner.cells('b').collapse();
                transfer_recs_ui.left_layout_link_ui_inner.cells('a').collapse();
            
                transfer_recs_ui.refresh_link_grid_clicked();
                break;
            case 'transfer':
                var interface_id = transfer_recs_ui.filter_form.getItemValue('destination_registry');
                var filter_xml;
                var link_ids = get_selected_ids(transfer_recs_ui.link_grid, 'link_id');
                var job_name = 'transfer_recs_job_' + js_user_name + '_' + $.now();
                var run_query;
                var query;
                
                if (link_ids == false) {
                    var confirm_msg = 'All the links in the Matches grid will be transferred. Do you want to proceed?';
                    dhtmlx.confirm({
                            title:"Confirmation",
                            ok: "Confirm",
                            text: confirm_msg,
                            callback:function(result){
                                if (result) {
                                    transfer_recs_ui.left_layout_link_ui_inner.progressOn();                
                                    link_ids = get_selected_ids(transfer_recs_ui.link_grid, 'link_id', 'y');
                                    filter_xml = "<Root><FormXML link_ids=\"" + link_ids + "\" interface_id=\"" + interface_id + "\"  ></FormXML></Root>";                                    
                                    query = "EXEC spa_process_rec_api_info @operation_type = 'export_recs', @filter_xml = '" + filter_xml.replace(/"/g, '\\"') + "'";  
                                    var param = 'batch_type=e';
                                    adiha_run_batch_process(query, param, 'Transfer Batch');
                                    post_recs_transfer();                                     
                                }
                            }
                    });
                } else {
                    transfer_recs_ui.left_layout_link_ui_inner.progressOn(); 
                    filter_xml = "<Root><FormXML link_ids=\"" + link_ids + "\" interface_id=\"" + interface_id + "\"  ></FormXML></Root>";
                    query = "EXEC spa_process_rec_api_info @operation_type = 'export_recs', @filter_xml = '" + filter_xml.replace(/"/g, '\\"') + "'"; 
                    var param = 'batch_type=e';
                    adiha_run_batch_process(query, param, 'Transfer Batch'); 
                    post_recs_transfer(); 
                }   
                
                break; 
            case "excel":
                transfer_recs_ui.link_grid.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                break;                
            case "pdf":
                transfer_recs_ui.link_grid.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
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
    
    function post_recs_transfer() {
        transfer_recs_ui.left_layout_link_ui_inner.progressOff();       
        transfer_recs_ui.refresh_link_grid_clicked();
    }

    transfer_recs_ui.refresh_link_grid_clicked = function() {
        transfer_recs_ui.left_layout_link_ui_inner.progressOn();
        var status = validate_form(transfer_recs_ui.filter_form);

        var eff_date_from = transfer_recs_ui.filter_form.getItemValue('effective_date_from', true);
        var eff_date_to = transfer_recs_ui.filter_form.getItemValue('effective_date_to', true);
        var link_id_from = transfer_recs_ui.filter_form.getItemValue('link_id_from');
        var link_id_to = transfer_recs_ui.filter_form.getItemValue('link_id_to');

        if (eff_date_from > eff_date_to) {
            transfer_recs_ui.filter_form.setValidateCss('effective_date_from', false);
            transfer_recs_ui.filter_form.setValidateCss('effective_date_to', false);
            show_messagebox('<b>Effective Date To</b> should be greater than <b>Effective Date From</b> on <b>Filter Criteria</b>.');
            transfer_recs_ui.left_layout_link_ui_inner.progressOff();
            return false;
        } else if(parseInt(link_id_to) < parseInt(link_id_from)) {
            show_messagebox("<b>Match ID To</b> should be greater than <b>Match ID From</b> on Filter Criteria.");
            transfer_recs_ui.left_layout_link_ui_inner.progressOff();            
            return false;
        }
        
        if (!status) {
            transfer_recs_ui.left_layout_link_ui_inner.progressOff();
            return false;
        }

        transfer_recs_ui.refresh_link_grid();

    }

    transfer_recs_ui.refresh_link_grid = function() {
        var filter_xml = "<Root><FormXML ";

        var filter_data = transfer_recs_ui.filter_form.getFormData();

        for (var a in filter_data) {
            field_label = a;
            if (field_label == 'apply_filters') {
                continue;
             }
                field_value = filter_data[a];
                if (transfer_recs_ui.filter_form.getItemType(a) == 'calendar') {
                    field_value = transfer_recs_ui.filter_form.getItemValue(a, true);
                }
                filter_xml += " " + field_label + "=\"" + field_value + "\"";
            
        }
        filter_xml += "></FormXML></Root>";

        var sql_param = {
                "sql":"EXEC spa_process_rec_api_info @operation_type = 'link_grid', @filter_xml = ' " + filter_xml + "'",
                "grid_type":"g"
            };
        sql_param = $.param(sql_param);
        var sql_url = js_data_collector_url + "&" + sql_param;
        transfer_recs_ui.link_grid.clearAndLoad(sql_url, function() {
            transfer_recs_ui.left_layout_link_ui_inner.progressOff();            
            var status = transfer_recs_ui.filter_form.getItemValue('status');    
            if (status == '112102' || status == '112103') {
                transfer_recs_ui.link_menu.setItemDisabled('transfer');
            } else {
                var count = transfer_recs_ui.link_grid.getRowsNum();
                if (has_rights_export_recs && count != 0) 
                    transfer_recs_ui.link_menu.setItemEnabled('transfer');
            }    
        });
    }

    transfer_recs_ui.refresh_transfer_status_grid = function(id) {
        switch (id) {
            case 'refresh':
                var date_from = transfer_recs_ui.transfer_status_filter_form.getItemValue('date_from', true);
                var date_to = transfer_recs_ui.transfer_status_filter_form.getItemValue('date_to', true);
                var link_ids = get_selected_ids(transfer_recs_ui.link_grid, 'link_id');
                link_ids = (link_ids == false) ? '' : link_ids;
                var interface_id = transfer_recs_ui.filter_form.getItemValue('destination_registry');
                        
                transfer_recs_ui.right_layout_detail_inner.cells('b').progressOn();
                
                if ((date_from == '' && date_to == '' && link_ids == '') || (date_from != '' && date_to != '' && link_ids != '')) {
                    show_messagebox('Please enter either <b>Date From</b> and <b>Date To</b> or <b>Link ID</b>.');
                    transfer_recs_ui.right_layout_detail_inner.cells('b').progressOff();
                    return false;
                }

                if (date_from > date_to) {
                    transfer_recs_ui.transfer_status_filter_form.setValidateCss('date_from', false);
                    transfer_recs_ui.transfer_status_filter_form.setValidateCss('date_to', false);
                    show_messagebox('<b>Date To</b> should be greater than <b>Date From</b> on <b>Filter Criteria</b>.');
                    transfer_recs_ui.right_layout_detail_inner.cells('b').progressOff();
                    return false;
                }

                var filter_xml = "<Root><FormXML ";
                filter_xml += " date_from=\"" + date_from + "\"";       
                filter_xml += " date_to=\"" + date_to + "\"";
                filter_xml += " link_ids=\"" + link_ids + "\"";   
                filter_xml += " interface_id=\"" + interface_id + "\"";   
                filter_xml += "></FormXML></Root>";
                
                var sql_param = {
                    "sql":"EXEC spa_process_rec_api_info @operation_type = 'status_grid', @filter_xml = ' " + filter_xml + "'",
                    "grid_type":"g"
                };

                sql_param = $.param(sql_param);
                var sql_url = js_data_collector_url + "&" + sql_param;
                transfer_recs_ui.transfer_status_grid.clearAndLoad(sql_url, function() {
                    transfer_recs_ui.right_layout_detail_inner.cells('b').progressOff();
                });
                break;
            case "excel":
                transfer_recs_ui.transfer_status_grid.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                break;                
            case "pdf":
                transfer_recs_ui.transfer_status_grid.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                break;    
        }
    }

    transfer_recs_ui.refresh_transfer_status_detail_grid = function(id) {
        switch (id) {
            case 'refresh':
                var process_ids = get_selected_ids(transfer_recs_ui.transfer_status_grid, 'process_id');
                process_ids = (process_ids == false) ? '' : process_ids;
                transfer_recs_ui.right_layout_detail_inner.cells('c').progressOn(); 

                var filter_xml = "<Root><FormXML filter_process_id=\"" + process_ids + "\"></FormXML></Root>";
                
                var sql_param = {
                    "sql":"EXEC spa_process_rec_api_info @operation_type = 'status_detail_grid', @filter_xml = '" + filter_xml + "'",
                    "grid_type":"g"
                };

                sql_param = $.param(sql_param);
                var sql_url = js_data_collector_url + "&" + sql_param;
                transfer_recs_ui.transfer_status_detail_grid.clearAndLoad(sql_url, function() {
                    transfer_recs_ui.right_layout_detail_inner.cells('c').progressOff();
                });
                break;
            case "excel":
                transfer_recs_ui.transfer_status_detail_grid.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                break;                
            case "pdf":
                transfer_recs_ui.transfer_status_detail_grid.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                break;
        }
    }   

    function get_selected_ids(grid_obj, column_name, select_all) {
        if (select_all == '' || select_all == undefined) select_all = 'n';

        var rid = grid_obj.getSelectedRowId();
        
        if ((rid == '' || rid == null) && select_all == 'y') {
            rid = grid_obj.getAllRowIds();
        } else if (rid == '' || rid == null) {
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
</script>
</html>