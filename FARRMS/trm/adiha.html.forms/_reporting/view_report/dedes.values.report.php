<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
<body class = "bfix"> 
    <?php 
    $active_object_id = get_sanitized_value($_POST['active_object_id'] ?? 'NULL');//function_id = 10235300
    $report_type = get_sanitized_value($_POST['report_type'] ?? 'NULL');
    $report_id = get_sanitized_value($_POST['report_id'] ?? 'NULL');
    $report_name = get_sanitized_value($_POST['report_name'] ?? 'NULL');

    $layout_json = '[
                        {
                            id:             "a",
                            text:           "De-designation Values Report",
                            header:         false
                        }
                    ]';

    $layout_name = 'de_designation_values_layout';
    $name_space = 'de_designation_values';
    $layout_obj = new AdihaLayout();
    echo $layout_obj->init_layout($layout_name, '', '1C', $layout_json, $name_space);
    
    echo $layout_obj->close_layout();
    $date = date('Y-m-d');
    ?> 
</body> 
      
<style>
    html, body {
        width: 100%;
        height: 100%;
        margin: 0px;
        padding: 0px;
        background-color: #ebebeb;
        overflow: hidden;
    }
    
</style>
<script type="text/javascript">
    var active_object_id = '<?php echo $active_object_id; ?>';
    var report_type = '<?php echo $report_type; ?>';
    var report_id = '<?php echo $report_id; ?>';
    var report_name = '<?php echo $report_name; ?>';
    report_ui = {};
    var date = '<?php echo $date; ?>';
    
    $(function() {
        data = {"action": "spa_create_application_ui_json",
                    "flag": "j",
                    "application_function_id": report_id,
                    "template_name": report_name,
                    "parse_xml": ""
                 };
        
        adiha_post_data('return_array', data, '', '', 'load_report_detail', '');
    });
    
    function load_report_detail(result) {
        var result_length = result.length;
        var tab_json = '';
        for (i = 0; i < result_length; i++) {
            if (i > 0)
                tab_json = tab_json + ",";
            tab_json = tab_json + (result[i][1]);
        }
        tab_json = '{tabs: [' + tab_json + ']}';
        
        report_ui["report_tabs_" + active_object_id] = de_designation_values.de_designation_values_layout.cells("a").attachTabbar();
        report_ui["report_tabs_" + active_object_id].loadStruct(tab_json);
        
        
        for (j = 0; j < result_length; j++) {
            tab_id = 'detail_tab_' + result[j][0];
            report_ui["form_" + j] = report_ui["report_tabs_" + active_object_id].cells(tab_id).attachForm();
            
            if (result[j][2]) {
                report_ui["form_" + j].loadStruct(result[j][2]);
                var form_name = 'report_ui["form_" + ' + j + ']';
                attach_browse_event(form_name, report_id, '', 'n');
                // set_default_value(); //set 'as_of_date' from setup menu 'Setup As of Date'
            }
        }
        
        report_ui["report_tabs_" + active_object_id].forEachTab(function(tab){
            form_obj = tab.getAttachedObject();
            form_obj.disableItem('mtm_type');
            form_obj.checkItem('apply_paging');
        });
        
        var att_obj = de_designation_values.de_designation_values_layout.cells('a');
        parent.set_apply_filter(att_obj);
    }
    
    function get_message(code) {
        switch (code) {
            case 'TERM_DATE_VALIDATION':
                return '<b>Term Start</b> cannot be greater than <b>Term End</b>.';
            case 'SELECT_SUBSIDIARY':
                return 'Please select either Book Structure or Link ID.';    
                
        }
    }
    
    function return_as_of_date() {
        var inner_tab_obj = de_designation_values.de_designation_values_layout.cells("a").getAttachedObject();
        inner_tab_obj.forEachTab(function(tab){
            var tab_name = tab.getText();
            form_obj = tab.getAttachedObject();
            
            if (tab_name == 'General') {
                as_of_date = form_obj.getItemValue('as_of_date', true);
            }
        })
           
        return as_of_date;
    }
    
    function report_parameter(is_batch) {
        var inner_tab_obj = de_designation_values.de_designation_values_layout.cells("a").getAttachedObject();
        var validate_flag = 0;
        
        var param_list = new Array();
        var filter_list = new Array();
        var param_string;
        
        inner_tab_obj.forEachTab(function(tab) {
            var tab_name = tab.getText();
            form_obj = tab.getAttachedObject();
            
            var status = validate_form(form_obj);
            
            if (status == false) {
                validate_flag = 1;
            }
            
            form_obj.forEachItem(function(name) {
                var item_type = form_obj.getItemType(name);

                if (item_type == 'calendar') {
                    value = form_obj.getItemValue(name, true);
                    value = (value != '') ? dates.convert_to_user_format(value) : '';

                    if (value != '') { 
                        filter_list.push(form_obj.getItemLabel(name) + "='" + value + "'");
                    }
                } else if (item_type == 'radio') {
                    value = form_obj.getCheckedValue(name);

                    if(form_obj.isItemChecked(name, value) && radio_flag != name){
                        radio_flag = name;
                        filter_list.push(name + "='" + value + "'");
                    }
                } else if (item_type == 'combo') {
                    var combo_obj = form_obj.getCombo(name);
                    value = combo_obj.getChecked();

                    if (value == '') {
                        value = combo_obj.getSelectedValue();
                        filter_value = combo_obj.getSelectedText();
                    }

                    if (value != '') { 
                        filter_list.push(form_obj.getItemLabel(name) + "='" + filter_value + "'");
                    }
                } else if (item_type == 'checkbox') { 
                    if (name == 'apply_paging') {
                        var paging = form_obj.isItemChecked(name);
                        if (paging == true) { paging_flag = 1; }
                    }

                } else if (item_type!= 'block' && item_type!= 'fieldset' && name!= 'report_id' && item_type!= 'button') {
                    value = form_obj.getItemValue(name);
                    filter_value = form_obj.getItemValue(name);
                    
                    if (value != '' 
                        && name != 'spa_name' 
                        && name != 'subsidiary_id'
                        && name != 'strategy_id'
                        && name != 'book_id'
                        && name != 'subbook_id'
                        ) {
                        filter_list.push(form_obj.getItemLabel(name) + "='" + filter_value + "'");
                    }
                }
            });
                    
            if (tab_name == 'General') {
                subsidiary_id = form_obj.getItemValue('subsidiary_id');
                strategy_id = form_obj.getItemValue('strategy_id');
                book_entity_id = form_obj.getItemValue('book_id');
                as_of_date = form_obj.getItemValue('as_of_date', true);
                term_start = form_obj.getItemValue('term_start', true);
                term_end = form_obj.getItemValue('term_end', true);
                hedge_type = form_obj.getItemValue('hedge_type');
                report_type = form_obj.getItemValue('report_type');
                discount_options = form_obj.getItemValue('discount_option');
                link_id = form_obj.getItemValue('link_id');
                round_value = form_obj.getItemValue('round_value');
                apply_paging = form_obj.isItemChecked('apply_paging');
                apply_paging = (apply_paging == true) ? '1' : '0';   
            } 
        });
        
        //To bypass validation if the date is dynamic type
        res_term_start = get_static_date_value(term_start);
        res_term_end = get_static_date_value(term_end);

        if ((res_term_start != "") && (res_term_end != "") && (res_term_start > res_term_end)) {
            validate_flag = 1;
            show_messagebox(get_message('TERM_DATE_VALIDATION')); 
        }
        
        if (link_id == '') {
            if (subsidiary_id == '') {
                validate_flag = 1;
                show_messagebox(get_message('SELECT_SUBSIDIARY'));
                return ;
            }
        }
           
        // if (is_batch == true)
        //     param_list.push("'$AS_OF_DATE$'");
        // else
        param_list.push("'" + as_of_date + "'");                    
        param_list.push("'" + subsidiary_id + "'");
        param_list.push("'" + strategy_id + "'");
        param_list.push("'" + book_entity_id + "'");
        param_list.push("'" + discount_options + "'");
        param_list.push("'" + hedge_type + "'");
        param_list.push("'" + report_type + "'");
        param_list.push("'" + link_id + "'");
        param_list.push(round_value);
        param_list.push("'" + term_start + "'");
        param_list.push("'" + term_end + "'");
        
        param_string = param_list.toString();
        param_string = param_string.replace(/''/g, 'NULL');
        
        var exec_call = 'EXEC spa_Create_Dedesignation_Values_Report ' + param_string;
                
        filter_list = filter_list.join(' | '); 
         
        if (is_batch) {
            if (apply_paging == 1) {
                exec_call = exec_call + '&applied_filters=' + filter_list + '&gen_as_of_date=0&enable_paging=true&np=1';
            } else {
                exec_call = exec_call + '&applied_filters=' + filter_list + '&gen_as_of_date=0';
            }
        } else {
            if (apply_paging == 1) {
                exec_call = exec_call + '&applied_filters=' + filter_list + '&enable_paging=true&np=1';
            } else {
                exec_call = exec_call + '&applied_filters=' + filter_list;
            }
        }        
        
        if (validate_flag == 1) {
            return false;
        }
        
        if (exec_call == null) {
            return false;
        } else {
            return exec_call
        }
    }

    function set_default_value() {        
        var sp_string =  "EXEC spa_as_of_date @flag = 'a', @screen_id = " + report_id;
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
        }  else if (as_of_date == 8) {            
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
        var inner_tab_obj = de_designation_values.de_designation_values_layout.cells("a").getAttachedObject();
        inner_tab_obj.forEachTab(function(tab) {
            var tab_name = tab.getText();
            form_obj = tab.getAttachedObject();
            if (tab_name == 'General') {
                form_obj.setItemValue('as_of_date', custom_as_of_date);                              
            }
        })
    }
    }

    function load_business_day(return_json) { 
        var return_json = JSON.parse(return_json);
        var business_day = return_json[0].business_day;             
        
        var inner_tab_obj = de_designation_values.de_designation_values_layout.cells("a").getAttachedObject();
        inner_tab_obj.forEachTab( function(tab) {
            var tab_name = tab.getText();
            form_obj = tab.getAttachedObject();
            if (tab_name == 'General') {
                form_obj.setItemValue('as_of_date', business_day);                              
            }
        })
    }
</script>