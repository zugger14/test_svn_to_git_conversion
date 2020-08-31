<!--DOCTYPE transitional.dtd-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<meta http-equiv="X-UA-Compatible" content="IE=Edge"> 
<html> 
    <?php 
    include '../../../adiha.php.scripts/components/include.file.v3.php'; 

    $call_from = get_sanitized_value($_GET['call_from'] ?? '');
    $subsidiary_id = get_sanitized_value($_GET['subsidiary_id'] ?? '');
    $strategy_id = get_sanitized_value($_GET['strategy_id'] ?? '');
    $book_id = get_sanitized_value($_GET['book_id'] ?? '');
    $subbook_id = get_sanitized_value($_GET['subbook_id'] ?? '');
    $delivery_month = get_sanitized_value($_GET['delivery_month'] ?? '');
    $date_from = get_sanitized_value($_GET['date_from'] ?? '');
    $date_to = get_sanitized_value($_GET['date_to'] ?? '');
    $counterparty_id = get_sanitized_value($_GET['counterparty_id'] ?? '');
    $contract_id = get_sanitized_value($_GET['contract_id'] ?? '');
    $term_start = get_sanitized_value($_GET['term_start'] ?? '');
    $deal_id = get_sanitized_value($_GET['deal_id'] ?? '');
     
    if ($call_from == 'submitted_accrual') { 
        $grid_name = 'SubmittedAccrualReportGrid';
    }  

    $json = '[
                        {id: "a", text: "Filters", header: "true", height: 140},  
                        {id: "b", text: "Submitted Accrual GL"}
                    ]';

    $namespace = 'SubmittedAccrualReport';
    $SubmittedAccrualReport_layout_obj = new AdihaLayout();
    echo $SubmittedAccrualReport_layout_obj->init_layout('SubmittedAccrualReport_layout', '', '2E', $json, $namespace); 

    // Attaching Filter Form
    $filter_form_layout = '[
                        {type: "settings", position: "label-top"},
                        {type: "block", list: [
                            {type: "calendar", name: "term_start", required: false, label: "Date From", "position": "label-top", "dateFormat":"' . $date_format . '", "serverDateFormat": "%Y-%m-%d", width: ' . $ui_settings['field_size'] . ', "offsetLeft": ' . $ui_settings['offset_left'] .'},
                            {type: "newcolumn"},
                            {type: "calendar", name: "term_end", required: false, label: "Date To", "dateFormat":"' . $date_format . '", "serverDateFormat": "%Y-%m-%d", "position": "label-top", width: ' . $ui_settings['field_size'] . ', "offsetLeft": ' . $ui_settings['offset_left'] .'},                            
                            {type: "newcolumn"},
                            {type: "combo", name: "counterparty", required: false, filtering:"true", filtering_mode:"between", label: "Counterparty", "value":"' . $counterparty_id . '", options: counterparty_dropdown, "position": "label-top", width: ' . $ui_settings['field_size'] . ', "offsetLeft": ' . $ui_settings['offset_left'] .'},
                            {type: "newcolumn"},
                            {type: "combo", name: "contract", required: false, filtering:"true", filtering_mode:"between", label: "Contract", "value":"' . $contract_id . '", options: contract_dropdown, "position": "label-top", width: ' . $ui_settings['field_size'] . ', "offsetLeft": ' . $ui_settings['offset_left'] .'},  
                            {type: "newcolumn"},    
                            {type: "calendar", name: "accounting_date", "value":"' . $term_start . '", required: false, label: "Accounting Month", "position": "label-top", "dateFormat":"' . $date_format . '", "serverDateFormat": "%Y-%m-%d", width: ' . $ui_settings['field_size'] . ', "offsetLeft": ' . $ui_settings['offset_left'] .'},
                            {type: "newcolumn"},    
                            {type: "input", name: "deal_id", "value":"' . $deal_id . '", required: false, label: "Deal ID", "position": "label-top",  width: ' . $ui_settings['field_size'] . ', "offsetLeft": ' . $ui_settings['offset_left'] .'},
                          
                        ]}
                    ]';

    $filter_form_name = 'SubmittedAccrualReport_filer_form';
    $filter_form_object = new AdihaForm();
    
    $sp_url_counterparty = "EXEC spa_source_counterparty_maintain 'c'";
    echo "counterparty_dropdown = ".  $filter_form_object->adiha_form_dropdown($sp_url_counterparty, 0, 1,true,$counterparty_id) . ";"."\n";

    $sp_url_contract = "EXEC spa_contract_group 'r'";
    echo "contract_dropdown = ".  $filter_form_object->adiha_form_dropdown($sp_url_contract, 0, 1,true,$contract_id) . ";"."\n";

    echo $SubmittedAccrualReport_layout_obj->attach_form($filter_form_name, 'a');    
    echo $filter_form_object->init_by_attach($filter_form_name, $namespace);
    echo $filter_form_object->load_form($filter_form_layout);




    //Attaching Toolbar  
    $grid_toolbar_json = '[
                        {id:"refresh", type: "button", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif", title: "Refresh"},
                        { type: "separator" },
                        {id:"excel", type: "button", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                        { type: "separator" },
                        {id:"pdf", type: "button", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"},
                        { type: "separator" },
                        {id:"revert", type: "button", text:"Revert", img:"unlock.gif", imgdis:"unlock_dis.gif",title: "Revert", enabled:"false"}
                     ]';

    //Attaching  grid     
    echo $SubmittedAccrualReport_layout_obj->attach_toolbar_cell('SubmittedAccrualReport_grid_toolbar', 'b');
    $SubmittedAccrualReport_grid_toolbar_obj = new AdihaToolbar();
    echo $SubmittedAccrualReport_grid_toolbar_obj->init_by_attach('SubmittedAccrualReport_grid_toolbar', $namespace);
    echo $SubmittedAccrualReport_grid_toolbar_obj->load_toolbar($grid_toolbar_json); 
    echo $SubmittedAccrualReport_grid_toolbar_obj->attach_event('', 'onClick', 'SubmittedAccrualReport_grid_toolbar_onclick');

    echo $SubmittedAccrualReport_grid_toolbar_obj->disable_item('revert');
    echo $SubmittedAccrualReport_layout_obj->attach_grid_cell('SubmittedAccrualReport_grid', 'b');
    $SubmittedAccrualReport_grid_obj = new GridTable($grid_name);   
    echo $SubmittedAccrualReport_grid_obj->init_grid_table('SubmittedAccrualReport_grid', $namespace); 
    echo $SubmittedAccrualReport_grid_obj->set_search_filter(true); 
    echo $SubmittedAccrualReport_grid_obj->enable_multi_select(true);
    echo $SubmittedAccrualReport_grid_obj->return_init(); 
    echo $SubmittedAccrualReport_grid_obj->attach_event('', 'onRowSelect', 'grid_row_select');
    echo $SubmittedAccrualReport_grid_obj->load_grid_functions();
    
    echo $SubmittedAccrualReport_layout_obj->close_layout();
    ?>
    
    <script type="text/javascript">   
        var php_script_loc_ajax = "<?php echo $app_php_script_loc; ?>";  
        var subsidiary_id = "<?php echo $subsidiary_id; ?>";
        var strategy_id = "<?php echo $strategy_id; ?>";
        var book_id = "<?php echo $book_id; ?>";
        var subbook_id = "<?php echo $subbook_id; ?>";    
        var delivery_month = "<?php echo $delivery_month; ?>";    

        $(function() {
            SubmittedAccrualReport_grid_toolbar_onclick('refresh', '')
        });

        function grid_row_select() {
            SubmittedAccrualReport.SubmittedAccrualReport_grid_toolbar.enableItem('revert');
        }
        
        function SubmittedAccrualReport_grid_toolbar_onclick(name, value) {      
            if (name == 'excel') {
                SubmittedAccrualReport.SubmittedAccrualReport_grid.toExcel(php_script_loc_ajax + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
            } else if (name == 'pdf'){
                SubmittedAccrualReport.SubmittedAccrualReport_grid.toPDF(php_script_loc_ajax + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
            } if (name == 'revert') {
                var selected_row_array = new Array();
                var selectedId = SubmittedAccrualReport.SubmittedAccrualReport_grid.getSelectedRowId();
                var selected_row_array = selectedId.split(',');
                var  stmt_checkout_ids = '';
                for(var i = 0; i < selected_row_array.length; i++) {
                    if (i == 0) {
                        stmt_checkout_ids =  SubmittedAccrualReport.SubmittedAccrualReport_grid.cells(selected_row_array[i], 0).getValue();
                    } else {
                        stmt_checkout_ids = stmt_checkout_ids + ',' + SubmittedAccrualReport.SubmittedAccrualReport_grid.cells(selected_row_array[i], 0).getValue();
                    }
                }   

                data = {"action": "spa_stmt_checkout",
                    "flag": "submitted_accrual_revert",  
                    "stmt_checkout_ids": stmt_checkout_ids
                };

                adiha_post_data('alert', data, '', '', 'SubmittedAccrualReport_grid_toolbar_onclick("refresh", "")', '', '');
                
            } else if (name == 'refresh') { 
                SubmittedAccrualReport.SubmittedAccrualReport_layout.cells('b').progressOn();
                if(validate_form(SubmittedAccrualReport.SubmittedAccrualReport_filer_form)) {
                    var term_start = SubmittedAccrualReport.SubmittedAccrualReport_filer_form.getItemValue('term_start', true);
                    var term_end = SubmittedAccrualReport.SubmittedAccrualReport_filer_form.getItemValue('term_end', true);
                    var accounting_date = SubmittedAccrualReport.SubmittedAccrualReport_filer_form.getItemValue('accounting_date', true);
                    var counterparty_id = SubmittedAccrualReport.SubmittedAccrualReport_filer_form.getItemValue('counterparty');
                    var contract_id = SubmittedAccrualReport.SubmittedAccrualReport_filer_form.getItemValue('contract');
                    var deal_id = SubmittedAccrualReport.SubmittedAccrualReport_filer_form.getItemValue('deal_id');

                    if(Date.parse(term_end) < Date.parse(term_start)) {
                        show_messagebox('<strong>Date From</strong> cannot be greater than <strong>Date To</strong>.');
                        SubmittedAccrualReport.SubmittedAccrualReport_layout.cells('b').progressOff();
                        return;
                    }

                    //loading grid             
                    var param = {
                        "flag": "submitted_accrual",
                        "action":"spa_stmt_checkout", 
                        "date_from": (term_start)?dates.convert_to_sql(term_start):null, 
                        "date_to": (term_end)?dates.convert_to_sql(term_end):null, 
                        "accounting_date": (accounting_date)?dates.convert_to_sql(accounting_date):null, 
                        "counterparty_id": counterparty_id,
                        "contract_id": contract_id,
                        "deal_id": deal_id,
                        "grid_type":"g"
                    };

                    param = $.param(param);
                    var param_url = js_data_collector_url + "&" + param;    
                    SubmittedAccrualReport.SubmittedAccrualReport_grid.clearAndLoad(param_url, function(){
                        SubmittedAccrualReport.SubmittedAccrualReport_layout.cells('b').progressOff();
                        SubmittedAccrualReport.SubmittedAccrualReport_grid_toolbar.disableItem('revert');
                    });
                    //end
                }
            } 
        }                 
        
    </script>