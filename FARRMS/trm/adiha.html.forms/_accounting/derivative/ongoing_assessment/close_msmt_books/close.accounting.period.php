<?php
/**
* Close accounting period screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<head>
    <meta charset='UTF-8' />
    <meta name='viewport' content='width=device-width, initial-scale=1.0' />
    <meta http-equiv='X-UA-Compatible' content='IE=edge,chrome=1' />
</head>
<html>
<?php
    include '../../../../../adiha.php.scripts/components/include.file.v3.php';
    $form_cell_json = "[
            {
                id:     'a',
                width:  240,
                height: 500,
                header: false
            },
            {
                id:     'b',
                width:  240,
                height: 420,
                text: 'Closed Date',
                header: true
            },
            
        ]";
     
    $rights_closing_account = 10237500; 
    $rights_run = 10237510;
    $rights_delete = 10237511;
    
    list (
            $has_rights_run,
            $has_rights_delete
    ) = build_security_rights(
            $rights_run,
            $rights_delete
    );
    
    $form_layout = new AdihaLayout();
    $layout_name = 'layout_closing_account';
    $form_name_space = 'form_closing_account';
    echo $form_layout->init_layout($layout_name, '', '2E', $form_cell_json, $form_name_space); 
    
    //Attaching Run Toolbar
    $toolbar_run_json = "[ {id:'run', img:'run.gif', imgdis:'run_dis.gif', text:'Run', title:'Run', enabled:'" . $has_rights_run . "'} ]";
    
    $toolbar_run = new AdihaMenu();
    echo $form_layout->attach_menu_cell('toolbar_run', 'a'); 
    echo $toolbar_run->init_by_attach('toolbar_run', $form_name_space);
    echo $toolbar_run->load_menu($toolbar_run_json);
    echo $toolbar_run->attach_event('', 'onClick', 'btn_run_click');
   
    $form_json = "[
        {type: 'calendar', name: 'dt_closing_date', label: 'Closing Date', required: true, validate: 'NotEmpty', position: 'absolute', labelLeft: 2, labelTop: 5, labelWidth: 160, inputTop:27, value:'', 'userdata':{'validation_message':'Required Field'} }
    ]";    
    
    $form_object = new AdihaForm();
    echo $form_layout->attach_form('closing_account', 'a');    
    echo $form_object->init_by_attach('closing_account', $form_name_space);
    echo $form_object->load_form($form_json);
    
    //Attaching Grid Toolbar
    $toolbar_closing_date = new AdihaMenu();
    
    $toolbar_closing_date_json = '[ {id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif", title: "Refresh"},
                                    {id:"t2", text:"Edit", img:"edit.gif", items:[
                                        {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete", enabled: 0}
                                    ]},
                                    {id:"t1", text:"Export", img:"export.gif", items:[
                                        {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                                        {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                                    ]}
                                ]';
    echo $form_layout->attach_menu_cell('toolbar_closing_account', 'b'); 
    echo $toolbar_closing_date->init_by_attach('toolbar_closing_account', $form_name_space);
    echo $toolbar_closing_date->load_menu($toolbar_closing_date_json);
    echo $toolbar_closing_date->attach_event('', 'onClick', 'toolbar_closing_date_click');
    
     //Attaching Grid 
    $grid_closing_account = new AdihaGrid();
    $grid_name = 'grd_closing_account';

    echo $form_layout->attach_grid_cell($grid_name, 'b');
    echo $grid_closing_account->init_by_attach($grid_name, $form_name_space);
    echo $grid_closing_account->set_header('Closed Date,Closed By,Closed On');
    echo $grid_closing_account->set_widths('150,150,150');
    echo $grid_closing_account->set_column_types('ro,ro,ro');
    echo $grid_closing_account->set_columns_ids('close_date,closed_by,closed_on');
    echo $grid_closing_account->set_search_filter(true);
    echo $grid_closing_account->attach_event('', 'onRowSelect', 'grd_closing_account_click');
    echo $grid_closing_account->return_init();
    
    echo $form_layout->close_layout();     
?>
</html>
<script type="text/javascript">
    var has_rights_run = Boolean('<?php echo $has_rights_run; ?>'); 
    var has_rights_delete = Boolean('<?php echo $has_rights_delete; ?>'); 
    var rights_closing_account = '<?php echo $rights_closing_account; ?>';     
    
    $(function() {
        grid_refresh();
        set_latest_measurement_date();
    });
    
    function set_latest_measurement_date() {
        var param = { 'action': 'spa_as_of_date',
                      'flag': 'a',
                      'screen_id': rights_closing_account
                    };
        adiha_post_data('return_array', param, '', '', 'call_back_set_latest_measurement_date', '');                    
    }
    
    function call_back_set_latest_measurement_date(result) {
        var date = new Date();
        var custom_as_of_date;
        as_of_date = result[0][0];
        no_of_days = result[0][1];
        // to get the latest update of the as of date
        if (as_of_date == 1) {   
            custom_as_of_date = result[0][2];            
        } else if (as_of_date == 2) {
            var custom_as_of_date = new Date(date.getFullYear(), date.getMonth(), 1);                   
        } else if (as_of_date == 3) {
            var custom_as_of_date = new Date(date.getFullYear(), date.getMonth() + 1, 0);                                                
        } else if (as_of_date == 4) {
            var custom_as_of_date = new Date(date.getFullYear(), date.getMonth(), date.getDate() - 1);            
        } else if (as_of_date == 5) {
            var calculated_date = date.setDate(date.getDate() - no_of_days);                
            calculated_date = new Date(calculated_date).toUTCString();
            custom_as_of_date = new Date(calculated_date);                             
        } else if (as_of_date == 6) {
            var first_day_next_mth = new Date(date.getFullYear(), date.getMonth() + 1, 1);                     
            first_day_next_mth = dates.convert_to_sql(first_day_next_mth);
            data = {
                        "action": "spa_get_business_day", 
                        "flag": "p",
                        "date": first_day_next_mth 
                    }
            return_json = adiha_post_data('return_json', data, '', '', 'load_business_day'); 
        } else if (as_of_date == 7) {
            var last_day_prev_mth = new Date(date.getFullYear(), date.getMonth(), 0);   
            last_day_prev_mth = dates.convert_to_sql(last_day_prev_mth);                                        
            data = {
                        "action": "spa_get_business_day", 
                        "flag": "n",
                        "date": last_day_prev_mth 
                    }
            return_json = adiha_post_data('return_json', data, '', '', 'load_business_day');
        } else if (as_of_date == 8) {            
            var first_day_of_mth = new Date(date.getFullYear(), date.getMonth(), 1);    
            first_day_of_mth = dates.convert_to_sql(first_day_of_mth);                      
            data = {
                        "action": "spa_get_business_day", 
                        "flag": "p",
                        "date": first_day_of_mth 
                    }
            return_json = adiha_post_data('return_json', data, '', '', 'load_business_day'); 
        }

        if (as_of_date < 6) { //6,7,8 are called from call back function load_business_day
            form_closing_account.closing_account.setItemValue('dt_closing_date', custom_as_of_date);
        }
    }
    
    function grid_refresh() {
        form_closing_account.toolbar_closing_account.setItemDisabled('delete');
        var param = {   
                        'action': 'spa_close_measurement_books',
                        'flag': 's'
                    };
        adiha_post_data('return_data', param, '', '', 'call_back_refresh_click', '');                    
    }
    
    function call_back_refresh_click(result) {
        form_closing_account.grd_closing_account.clearAll();
        form_closing_account.grd_closing_account.parse(result, "js");
    }

    function btn_run_click() {
        var closing_date_form = form_closing_account.closing_account;
        var form_validate = validate_form(closing_date_form);
        if (form_validate == 0) return;
        
        var closing_date = form_closing_account.closing_account.getItemValue('dt_closing_date', true);
        var exec_call = "EXEC spa_close_measurement_books 'v', " + singleQuote(closing_date);
        var sp_url_param = {'as_of_date': closing_date,
                            'flag': 'v',
                            'action': 'spa_close_measurement_books'
                            };
        adiha_post_data('return_data', sp_url_param, '', '', 'call_back_btn_run_click', '');
    }
    
    function call_back_btn_run_click(return_value) {
        if (return_value != '') {
            if (return_value[0].errorcode == 'Error') {
                show_messagebox(return_value[0].message);
                return;
            }    
        } else {
            var closing_date = form_closing_account.closing_account.getItemValue('dt_closing_date', true);
            var exec_call = "EXEC spa_close_measurement_books 'i', " + singleQuote(closing_date);
            var arg = 'call_from=Closing Accounting Peroid&gen_as_of_date=1&batch_type=c&as_of_date=' + closing_date;
            var title = 'Closing Accounting Peroid'; 
            adiha_run_batch_process(exec_call, arg, title);
        } 
    }
        
    function toolbar_closing_date_click(args) {
        switch(args) {
            case 'refresh':
                grid_refresh();
                break;
            case 'excel':
                path = js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php';
                form_closing_account.grd_closing_account.toExcel(path);
                break;
            case 'pdf':
                path = js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php';
                form_closing_account.grd_closing_account.toPDF(path);
                break;
            case 'delete':
                var closing_date = form_closing_account.grd_closing_account.getColumnValues(0);
                closing_date = dates.convert_to_sql(closing_date);
                
                data_for_post = { 'action': 'spa_close_measurement_books', 
                                  'flag': 'd',
                                  'as_of_date': closing_date
                                };
                adiha_post_data('confirm', data_for_post, '', '', 'grid_refresh', '');
                break;
        }        
    }
    
    function grd_closing_account_click() {
        var selected_id = form_closing_account.grd_closing_account.getSelectedRowId(); 
        if (selected_id != '' && has_rights_delete == true) form_closing_account.toolbar_closing_account.setItemEnabled('delete');
        else form_closing_account.toolbar_closing_account.setItemDisabled('delete');
    }

    function load_business_day(return_json) { 
        var return_json = JSON.parse(return_json);
        var business_day = return_json[0].business_day;             
        
        form_closing_account.closing_account.setItemValue('dt_closing_date', business_day);
    }
</script>