<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
<body> 
    <?php 
    $active_object_id = get_sanitized_value($_POST['active_object_id'] ?? 'NULL');
    $report_type = get_sanitized_value($_POST['report_type'] ?? 'NULL');
    $report_id = get_sanitized_value($_POST['report_id'] ?? 'NULL');
    $report_name = get_sanitized_value($_POST['report_name'] ?? 'NULL');
    
    /********************/
    $link_id = get_sanitized_value($_POST['link_id'] ?? '0');
    $strategy_id = get_sanitized_value($_POST['strategy_id'] ?? '0');
    $subsidiary_id = get_sanitized_value($_POST['subsidiary_id'] ?? '0');
    $book_id = get_sanitized_value($_POST['book_id'] ?? '0');
    $book_structure_text = get_sanitized_value($_POST['book_structure_text'] ?? '');
    $effective_date_to = get_sanitized_value($_POST['effective_date_to'] ?? '0');
    /********************/

    $layout_json = '[
                        {
                            id:             "a",
                            text:           "Measurement Report",
                            header:         false
                        }
                    ]';

    $layout_name = 'measurement_report_layout';
    $name_space = 'measurement_report';
    $layout_obj = new AdihaLayout();
    echo $layout_obj->init_layout($layout_name, '', '1C', $layout_json, $name_space);
    echo $layout_obj->close_layout();
    
    $date = date('Y-m-d', strtotime('last day of previous month'));

    // get most recent measurement report date for as of date
    $recent_as_of_date_sql = "SELECT CONVERT(varchar(10), MAX(rmv.as_of_date),126) as_of_date FROM report_measurement_values AS rmv where link_id = '" . $link_id . "'";
    $recent_as_of_date_data = readXMLURL2($recent_as_of_date_sql);

    // get most recent measurement report date from archive 1 for as of date id measurement report date
    // could not be found
    if ($recent_as_of_date_data[0]['as_of_date'] == null) {
        $recent_as_of_date_sql = "SELECT CONVERT(varchar(10), MAX(rmva1.as_of_date),126) as_of_date FROM report_measurement_values_arch1 AS rmva1 where link_id = '" . $link_id . "'";
        $recent_as_of_date_data = readXMLURL2($recent_as_of_date_sql);
    }
    // get most recent measurement report date from archive 1 for as of date id measurement report date
    // from archive 1 could not be found
    if ($recent_as_of_date_data[0]['as_of_date'] == null) {
        $recent_as_of_date_sql = "SELECT CONVERT(varchar(10), MAX(rmva2.as_of_date),126) as_of_date FROM report_measurement_values_arch2 AS rmva2 where link_id = '" . $link_id . "'";
        $recent_as_of_date_data = readXMLURL2($recent_as_of_date_sql);
    }
    //

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
    var link_id = '<?php echo $link_id;?>';

    var strategy_id = '<?php echo $strategy_id;?>';
    var subsidiary_id = '<?php echo $subsidiary_id;?>';
    var book_id = '<?php echo $book_id;?>';
    var book_structure_text = '<?php echo $book_structure_text;?>';
    var effective_date_to = '<?php echo $effective_date_to; ?>';

    if(link_id == 'undefined') {
        link_id = 0;
    }

    if(effective_date_to == 'undefined') {
        effective_date_to = 0;
    }
	
	  if(subsidiary_id == 'undefined') {
        subsidiary_id = 0;
    }

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
        
        report_ui["report_tabs_" + active_object_id] = measurement_report.measurement_report_layout.cells("a").attachTabbar();
        report_ui["report_tabs_" + active_object_id].loadStruct(tab_json);
        
        
        for (j = 0; j < result_length; j++) {
            tab_id = 'detail_tab_' + result[j][0];
            report_ui["form_" + j] = report_ui["report_tabs_" + active_object_id].cells(tab_id).attachForm();
            
            if (result[j][2]) {
                report_ui["form_" + j].loadStruct(result[j][2]);
                var form_name = 'report_ui["form_" + ' + j + ']';
                attach_browse_event(form_name, report_id, '', 'n');
                set_default_value(); //set 'as_of_date' from setup menu 'Setup As of Date'
                
               if (link_id != 0) {
                    report_ui["form_" + j].setItemValue('linkid_to', link_id);
                }
                if (strategy_id != 'undefined') {
                    report_ui["form_" + j].setItemValue('strategy_id', strategy_id);
                    report_ui["form_" + j].setItemValue('subsidiary_id', subsidiary_id);
                    report_ui["form_" + j].setItemValue('book_id', book_id);
                    report_ui["form_" + j].setItemValue('book_structure', book_structure_text);
                }
                
                if(link_id > 0) {
                    var recent_as_of_date = '<?php echo $recent_as_of_date_data[0]['as_of_date'];?>';
                    report_ui["form_" + j].setItemValue('as_of_date', recent_as_of_date);

                    var combo_object_report_type = report_ui["form_" + j].getCombo('report_type');
                    combo_object_report_type.attachEvent("onXLE", function(){
                        combo_object_report_type.forEachOption(function(optId){
                    if (optId.text == 'Detail') {
                                combo_object_report_type.selectOption(optId.index);
            }
                });
                    });

                    var combo_object_tenor_options = report_ui["form_" + j].getCombo('tenor_options');
                    combo_object_tenor_options.attachEvent("onXLE", function(){
                        combo_object_tenor_options.forEachOption(function(optId){
                    if (optId.text == 'Forward Months') {
                                combo_object_tenor_options.selectOption(optId.index);
        }
                });
                    });
                }
        
            }
        }
        
        report_ui["report_tabs_" + active_object_id].forEachTab(function(tab){
            form_obj = tab.getAttachedObject();
            form_obj.checkItem('apply_paging');
            form_obj.disableItem('mtm_type');
            form_obj.attachEvent("onChange", function (name, value){
                if (name == 'hedge_type') {
                    var hedge_type = form_obj.getItemValue('hedge_type');   
                    
                    if (hedge_type == 'm') {
                        form_obj.enableItem('mtm_type');
                    } else {
                        form_obj.disableItem('mtm_type');
                    }
                }   
            });
        });
        
        var att_obj = measurement_report.measurement_report_layout.cells('a');
        parent.set_apply_filter(att_obj);
        if(link_id != 0 ) {
            parent.show_report(report_id, 'html', false, false);
        }
    }
    
    function get_message(code) {
        switch (code) {
            case 'TERM_DATE_VALIDATION':
                return '<b>Term Start</b> cannot be greater than <b>Term End</b>.';
            case 'REPORT_TYPE_VALIDATE':
                return 'Summary by Relationship can be view only for Cash Flow and Fair value.';  
        }
    }
    
    function return_as_of_date() {
        var inner_tab_obj = measurement_report.measurement_report_layout.cells("a").getAttachedObject();
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
        var inner_tab_obj = measurement_report.measurement_report_layout.cells("a").getAttachedObject();
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

                    if (value != '') { 
                        filter_list.push(form_obj.getItemLabel(name) + '="' + value + '"');
                        value = dates.convert_to_user_format(value);
                    }
                } else if (item_type == 'radio') {
                    value = form_obj.getCheckedValue(name);

                    if(form_obj.isItemChecked(name, value) && radio_flag != name){
                        radio_flag = name;
                        filter_list.push(name + '="' + value + '"');
                    }
                } else if (item_type == 'combo') {
                    var combo_obj = form_obj.getCombo(name);
                    value = combo_obj.getChecked();

                    if (value == '') {
                        value = combo_obj.getSelectedValue();
                        filter_value = combo_obj.getSelectedText();
                    }

                    if (value != '') { 
                        filter_list.push(form_obj.getItemLabel(name) + '="' + filter_value + '"');
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
                        filter_list.push(form_obj.getItemLabel(name) + '="' + filter_value + '"');
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
                mtm_type = form_obj.getItemValue('mtm_type');
                what_if = form_obj.getItemValue('what_if');
                tenor_options = form_obj.getItemValue('tenor_options');
                discount_options = form_obj.getItemValue('discount_options');
                linkid_from = form_obj.getItemValue('linkid_from');
                linkid_to = form_obj.getItemValue('linkid_to');
                link_desc = form_obj.getItemValue('link_desc');
                deal_id = form_obj.getItemValue('deal_id');
                reference_id = form_obj.getItemValue('reference_id');
                legal_entity = form_obj.getItemValue('legal_entity');
                round_value = form_obj.getItemValue('round_value');
                apply_paging = form_obj.isItemChecked('apply_paging');
                apply_paging = (apply_paging == true) ? '1' : '0';   
            } 
        });
        
        //To bypass validation if the date is dynamic type
        res_term_start = get_static_date_value(term_start);
        res_term_end = get_static_date_value(term_end);

        if ((res_term_start !== "") && (res_term_end !== "") && (res_term_start > res_term_end)) {
            validate_flag = 1;
            show_messagebox(get_message('TERM_DATE_VALIDATION')); 
        }
        
        if (hedge_type != 'm' ) {
            // if (is_batch == true)
            //     param_list.push("'$AS_OF_DATE$'");
            // else
                param_list.push("'" + as_of_date + "'");
                
            param_list.push("'" + subsidiary_id + "'");
            param_list.push("'" + strategy_id + "'");
            param_list.push("'" + book_entity_id + "'");
            param_list.push("'" + discount_options + "'");
            param_list.push("'" + tenor_options + "'");
            param_list.push("'" + hedge_type + "'");
            param_list.push("'" + report_type + "'");
            param_list.push("'" + linkid_from + "'");
            param_list.push("'" + round_value + "'");
            param_list.push("'" + legal_entity + "'");
            param_list.push("'" + what_if + "'");
            param_list.push("'" + deal_id + "'");
            param_list.push("'" + reference_id + "'");
            param_list.push("'" + term_start + "'");
            param_list.push("'" + term_end + "'");
            param_list.push("'" + linkid_to + "'");
            param_list.push("'" + link_desc + "'");
            
            param_string = param_list.toString();
            param_string = param_string.replace(/''/g, 'NULL');
            
            var exec_call = 'EXEC spa_Create_Hedges_Measurement_Report ' + param_string;
               
        } else {
            if (report_type == 'l') {
                var message = get_message('REPORT_TYPE_VALIDATE');
                show_messagebox(message);
                return;
            }
            
            if (is_batch == true)
                param_list.push("'$AS_OF_DATE$'");
            else
                param_list.push("'" + as_of_date + "'");
                
            param_list.push("'" + subsidiary_id + "'");
            param_list.push("'" + strategy_id + "'");
            param_list.push("'" + book_entity_id + "'");
            param_list.push("'" + discount_options + "'");
            param_list.push("'" + tenor_options + "'");
            param_list.push("'" + mtm_type + "'");
            param_list.push("'" + report_type + "'");
            param_list.push("'" + linkid_from + "'");
            param_list.push("'" + round_value + "'");
            param_list.push("'" + legal_entity + "'");
            param_list.push("NULL");
            param_list.push("'" + deal_id + "'");
            param_list.push("'" + reference_id + "'");
            param_list.push("'" + term_start + "'");
            param_list.push("'" + term_end + "'");
            
            param_string = param_list.toString();
            param_string = param_string.replace(/''/g, 'NULL');
            
            var exec_call = 'EXEC spa_Create_MTM_Measurement_Report ' + param_string;
               
        }
        
        filter_list = filter_list.join(' | '); 
        
        if (is_batch) {
            if (apply_paging == 1) {
                exec_call = exec_call + '&enable_paging=true&np=1&applied_filters=' + filter_list + '&gen_as_of_date=0';
            } else {
                exec_call = exec_call + '&applied_filters=' + filter_list + '&gen_as_of_date=0';
            }
        } else {
            if (apply_paging == 1) {
                exec_call = exec_call + '&enable_paging=true&np=1&applied_filters=' + filter_list;
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
        var inner_tab_obj = measurement_report.measurement_report_layout.cells("a").getAttachedObject();
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
        
        var inner_tab_obj = measurement_report.measurement_report_layout.cells("a").getAttachedObject();
        inner_tab_obj.forEachTab( function(tab) {
            var tab_name = tab.getText();
            form_obj = tab.getAttachedObject();
            if (tab_name == 'General') {
                form_obj.setItemValue('as_of_date', business_day);                              
            }
        })
    }
</script>