<!DOCTYPE html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
</head>
<html>
<?php
include '../../../adiha.php.scripts/components/include.file.v3.php';
$form_cell_json = '[
        {
            id:             "a",
            text:           "Portfolio Hierarchy",
            width:          300,
            height:         500,
            collapse:       false
        },
        {
            id:             "b",
            text:           " ",
            height:         270,
            collapse:       false
        }
    ]';
 
$rights_run_measurement = 10233400;
$rights_run_measurement_del = 10233411;

list (
   $has_rights_run_measurement,
   $has_rights_run_measurement_del
) = build_security_rights (
   $rights_run_measurement,
   $rights_run_measurement_del
); 

$form_layout = new AdihaLayout();
$layout_name = 'layout_run_measurement';
$form_name_space = 'run_measurement';
echo $form_layout->init_layout($layout_name, '', '2U', $form_cell_json, $form_name_space);
//Attaching tree in cell a
$tree_structure = new AdihaBookStructure($rights_run_measurement);
$tree_name = 'tree_run_measurement';
echo $form_layout->attach_tree_cell($tree_name, 'a');
echo $tree_structure->init_by_attach($tree_name, $form_name_space);
echo $tree_structure->set_portfolio_option(2);
echo $tree_structure->set_subsidiary_option(2);
echo $tree_structure->set_strategy_option(2);
echo $tree_structure->set_book_option(2);
echo $tree_structure->set_subbook_option(0);
echo $tree_structure->load_book_structure_data();
echo $tree_structure->load_bookstructure_events();
echo $tree_structure->expand_level('all');
echo $tree_structure->enable_three_state_checkbox();
echo $tree_structure->load_tree_functons();  
echo $tree_structure->attach_search_filter('run_measurement.layout_run_measurement', 'a');  

//Attaching tab in cell b
$tab_name = 'run_measurement_tabs';
$json_tab = "[ {id: 'a1', text: 'Run', active: true},
               {id: 'a2', text: 'History'}]";  
echo $form_layout->attach_tab_cell($tab_name, 'b', $json_tab);
$date = date('Y-m-d');

$dt_as_of_date_from = date('Y-m-d', strtotime('first day of -3 month'));
$dt_as_of_date_to = date('Y-m-d', strtotime('last day of previous month'));        
$tab_obj = new AdihaTab();

$xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10233400', @template_name='RunMeasurement', @group_name='General'";
$return_value1 = readXMLURL($xml_file);
$form_structure_general = $return_value1[0][2];    
echo $form_layout->close_layout(); 
?>
<script type="text/javascript">
    var function_id = '<?php echo $rights_run_measurement; ?>';
    var has_rights_run_measurement_del = Boolean('<?php echo $has_rights_run_measurement_del; ?>');
    $(function() { //start form loading
        var date = '<?php echo $date; ?>';
        var as_of_date_from = '<?php echo $dt_as_of_date_from; ?>';
        var as_of_date_to = '<?php echo $dt_as_of_date_to; ?>';
        var date_format = '<?php echo $date_format; ?>';// defined in include.file.v3.php
        
        var today = new Date();
        var set_as_of_date = new Date(today.getFullYear(), today.getMonth() , today.getDate());
       // as_of_date_from = dates.convert_to_user_format(as_of_date_from);
       // as_of_date_to = dates.convert_to_user_format(as_of_date_to);
        
        //Attaching layout in General Tab
        general_tab = run_measurement.run_measurement_tabs.tabs('a1').attachLayout({
                            pattern: '3E',
                            cells: [
                                {id:'a', header:'false', height:50},
                                {id:'b', header:'true', text:'Apply Filters', height:100, collapse:true},
                                {id:'c', header:'true', text:'Run', height:730, collapse:false}
                                ] 
                            });
        
        //Attaching Toolbar and Form in General Tab in b cell
        run_measurement_toolbar = general_tab.cells('a').attachToolbar();
        run_measurement_toolbar.setIconsPath(js_image_path + 'dhxtoolbar_web/');
        run_measurement_toolbar.loadStruct([{ id: 'run', type: 'button', img: 'run.gif', text: 'Run', title: 'Run'}]);
        run_measurement_toolbar.attachEvent('onClick', function() {
            run_measurement.btn_run_click();
        });
        
        general_form_structure = <?php echo $form_structure_general; ?>;
        general_form = general_tab.cells('c').attachForm(general_form_structure);
        general_form.setNote('link_id', {
            text: '<b style="color:black">Use comma (,) as a seperator for multiple Link ID</b>'
        });

        //Attaching Filter in General Tab in a cell
        var filter_obj = general_tab.cells('b').attachForm();
        var layout_cell_obj = general_tab.cells('c');
        load_form_filter(filter_obj, layout_cell_obj, function_id, 2, '', run_measurement);
        
        //general_form.setItemValue('dt_as_of_date', as_of_date_to);
        set_default_value();
        general_form.setItemValue('dt_assessment_date', date);
        
        general_form.attachEvent('onChange', function(name, value) {
            if (name == 'cmb_assessment') {
                var assessment = general_form.getItemValue('cmb_assessment');  
                
                if (assessment == 'r') {
                    general_form.disableItem('dt_assessment_date');
                } else {
                    general_form.enableItem('dt_assessment_date');
                }
            }   
        });
        
        //Attaching layout in History tab
        var history_tab = run_measurement.run_measurement_tabs.tabs('a2').attachLayout({
                            pattern: '2E',
                            cells: [
                                {id:'a', header:'true', text:'Filters', height:100, collapse:false},
                                {id:'b', header:'true', text:'History', collapse:false}
                                ] 
                            });
                            
        //Attaching Filter Form in Cell a of History tab            
        var filter_form_structure = [ {type: 'calendar', name: 'dt_as_of_date_from', required: false, validate:'', value: as_of_date_from, label: 'As of Date From', dateFormat: date_format, serverDateFormat:'%Y-%m-%d', width: ui_settings['field_size'], position: 'label-top', labelWidth: 'auto', offsetLeft : ui_settings['offset_left']},
                                    {type: 'newcolumn'},
                                      {type: 'calendar', name: 'dt_as_of_date_to', required: false, validate:'', value: as_of_date_to, label: 'As of Date To', dateFormat: date_format, serverDateFormat:'%Y-%m-%d', width: ui_settings['field_size'], position: 'label-top', labelWidth: 'auto', offsetLeft : ui_settings['offset_left']}
                                    ];
            
        history_form = history_tab.cells("a").attachForm(filter_form_structure);
       
        //Attaching Menu in History tab cell b
        var menu_json = [{id:'refresh', img:'refresh.gif', text:'Refresh', title:'Refresh'},
                        {id:'t1', text:'Edit', img:'edit.gif', items:[
                            {id:'delete', text:'Delete', img:'trash.gif', imgdis:'trash_dis.gif', title: 'Delete', enabled: false}
                        ]},                                
                        {id:'t2', text:'Export', img:'export.gif', items:[
                            {id:'excel', text:'Excel', img:'excel.gif', imgdis:'excel_dis.gif', title: 'Excel'},
                            {id:'pdf', text:'PDF', img:'pdf.gif', imgdis:'pdf_dis.gif', title: 'PDF'}
                        ]}
                        ];
                        
        history_menu = history_tab.cells('b').attachMenu({
                                    icons_path: js_image_path + 'dhxtoolbar_web/',
                                    json: menu_json
                                });
                                
        history_menu.attachEvent('onClick', function(args) {
            switch(args) {
                case 'refresh':
                    run_measurement.refresh_export_toolbar_click();                 
                    break;
                case 'excel':
                    path = js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php';
                    run_measurement.grd_history.toExcel(path);                
                    break;
                case 'pdf':
                    path = js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php';
                    run_measurement.grd_history.toPDF(path);                
                    break;
                case 'delete':
                    var selected_row_id = run_measurement.grd_history.getSelectedRowId();
                    var as_of_date = run_measurement.grd_history.cells(selected_row_id,0).getValue(); 
                    data_for_post = { 'action': 'spa_run_measurement_process_history', 
                                     'flag': 'd', 
                                     'from_date': as_of_date} 
                    adiha_post_data('confirm', data_for_post, '', '', 'run_measurement.refresh_export_toolbar_click', '');
                    break;
            }
        });
                                                            
        //Attach grid                    
        run_measurement.grd_history = history_tab.cells('b').attachGrid();
        run_measurement.grd_history.setHeader('As of Date');
        run_measurement.grd_history.setColTypes("ro");
        run_measurement.grd_history.setColSorting("date");
        run_measurement.grd_history.init();
        run_measurement.grd_history.attachEvent('onRowSelect', function() {
            var selected_row_id = run_measurement.grd_history.getSelectedRowId();
            
            if (selected_row_id != 'NULL' && has_rights_run_measurement_del) {
                history_menu.setItemEnabled('delete');    
            } else {
                history_menu.setItemDisabled('delete');
            }
                    
        }); 
        general_form.setItemValue('dt_as_of_date', set_as_of_date);            
    }); //end form loading
    
    function get_message(message_code) {
        switch (message_code) {
            case 'AS_OF_DATE_NULL':
                return 'Please select As of Date first.';
            case 'SELECT_ASSMT_DATE':
                return 'Please select Assessment Date first or select Use Most Recent Assessment Values.';
            case 'SUB_VALIDATE':
                return 'Please select at least one subsidiary or Book';
            case 'VALIDATE_DATE':
                return "'As of Date To' must be greater than 'As of Date From'.";
        }
    }
    
    // Run button function
    run_measurement.btn_run_click = function() {
        var sub_entity_id = run_measurement.get_subsidiary('browser');
        var strategy_entity_id = run_measurement.get_strategy('browser');
        var book_entity_id = run_measurement.get_book('browser');
        var as_of_date = general_form.getItemValue('dt_as_of_date', true);
        var assessment_date = general_form.getItemValue('dt_assessment_date', true);
        var asstment = general_form.getItemValue('cmb_assessment');
        var link_id = general_form.getItemValue('link_id');                     
        var delete_prior_values = (general_form.isItemChecked('chk_purge_measurement') == true) ? 'y' : 'NULL';
        var mtm_prior_eff = (general_form.isItemChecked('chk_process_mtm') == true) ? 'y' : 'NULL';
        
        as_of_date = (as_of_date == '') ? 'NULL' : as_of_date;
        assessment_date = (assessment_date == '') ? 'NULL' : assessment_date;
        link_id = (link_id == '') ? 'NULL' : link_id;
                
        var form_validate = validate_form(general_form);
        if (form_validate == 0) return;
        
        if (asstment == 'r') {
            assessment_date = 'NULL';
        }
 
        if (sub_entity_id == '' && book_entity_id == '') {
            var text_message = get_message('SUB_VALIDATE');
            show_messagebox(text_message);
            return;
        } else {
            var exec_call = 'EXEC spa_run_measurement_process_job ' +
                            singleQuote(sub_entity_id) + ', ' +
                            singleQuote(strategy_entity_id) + ', ' +
                            singleQuote(book_entity_id) + ', ' + "'$AS_OF_DATE$', " +
                            singleQuote(assessment_date) + ', ' + 'NULL, NULL, ' +
                            singleQuote('<?php echo $app_user_name; ?>') + ', 0, ' + "'n', " + singleQuote(link_id) + ', NULL, NULL, ' +
                            singleQuote(delete_prior_values) + ', ' +
                            singleQuote(mtm_prior_eff);

            var param = 'call_from=run_deal_settlement&gen_as_of_date=1&batch_type=c&job_name=Measurement&as_of_date=' + as_of_date;
            var title = 'Run Measurement Batch Job';       
            adiha_run_batch_process(exec_call, param, title);     
        }        
    }
    
    //refresh function
    run_measurement.refresh_export_toolbar_click = function() {
        history_menu.setItemDisabled('delete');
        var as_of_date_from = history_form.getItemValue('dt_as_of_date_from', true);
        var as_of_date_to = history_form.getItemValue('dt_as_of_date_to',true);
        
        as_of_date_from = (as_of_date_from == '') ? 'NULL' : as_of_date_from;
        as_of_date_to = (as_of_date_to == '') ? 'NULL' : as_of_date_to;
        
        if ((as_of_date_from != 'NULL' && as_of_date_to != 'NULL') && (as_of_date_from > as_of_date_to)) {
            var text_message = get_message('VALIDATE_DATE');
            show_messagebox(text_message);
            return;
        }
        
        var sp_url_param = {                    
            'from_date': as_of_date_from,
            'to_date': as_of_date_to,
            'flag': 's',
            'action': 'spa_run_measurement_process_history'
        };

        sp_url_param = $.param(sp_url_param);
        var sp_url = js_data_collector_url + '&' + sp_url_param;
        run_measurement.grd_history.clearAll();
        run_measurement.grd_history.loadXML(sp_url);   
    }

    function set_default_value() {        
        var sp_string =  "EXEC spa_as_of_date @flag = 'a', @screen_id = " + function_id; 
        var data_for_post = {"sp_string": sp_string};          
        var return_json = adiha_post_data('return_json', data_for_post, '', '', 'set_default_value_call_back');                  
    }

    function set_default_value_call_back(return_json) { 
        return_json = JSON.parse(return_json);  
        as_of_date = return_json[0].as_of_date;
        no_of_days = return_json[0].no_of_days;
        var date = new Date();
        var custom_as_of_date;
        // to get the latest update of the as of date
        if (as_of_date == 1) {   
        custom_as_of_date = return_json[0].custom_as_of_date;         
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
        general_form.setItemValue('dt_as_of_date', custom_as_of_date);          
    }
    }

    function load_business_day(return_json) { 
        var return_json = JSON.parse(return_json);
        var business_day = return_json[0].business_day;             
        
        general_form.setItemValue('dt_as_of_date', business_day); 
    }
</script>

</html>