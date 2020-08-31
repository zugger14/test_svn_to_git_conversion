<!--DOCTYPE transitional.dtd-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<meta http-equiv="X-UA-Compatible" content="IE=Edge"> 
<html>  
    <?php 
        include '../../../adiha.php.scripts/components/include.file.v3.php';
        
        $active_object_id = get_sanitized_value($_POST['active_object_id'] ?? 'NULL');
        $report_type = get_sanitized_value($_POST['report_type'] ?? 'NULL');
        $report_id = get_sanitized_value($_POST['report_id'] ?? 'NULL');
        $report_name = get_sanitized_value($_POST['report_name'] ?? 'NULL');

        $layout_json = '[
                            {
                                id:             "a",
                                text:           "Transaction Audit Log Report",
                                header:         false,
                                collapse:       false,
                                fix_size:       [true,true]
                            },

                        ]';

        $layout_name = 'transcation_audit_log_report_layout';
        $name_space = 'transcation_audit_log_report';
        $layout_obj = new AdihaLayout();
        echo $layout_obj->init_layout($layout_name, '', '1C', $layout_json, $name_space);
        
        echo $layout_obj->close_layout();
    ?> 
    
    <script>
        var active_object_id = '<?php echo $active_object_id; ?>';
        var report_type = '<?php echo $report_type; ?>';
        var report_id = '<?php echo $report_id; ?>';
        var report_name = '<?php echo $report_name; ?>';
        report_ui = {};
        
        $(function(){
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
            
            report_ui["report_tabs_" + active_object_id] = transcation_audit_log_report.transcation_audit_log_report_layout.cells("a").attachTabbar();
            report_ui["report_tabs_" + active_object_id].loadStruct(tab_json);
            
            for (j = 0; j < result_length; j++) {
                tab_id = 'detail_tab_' + result[j][0];
                report_ui["form_" + j] = report_ui["report_tabs_" + active_object_id].cells(tab_id).attachForm();
                
                if (result[j][2]) {
                    report_ui["form_" + j].loadStruct(result[j][2]);
                    var form_name = 'report_ui["form_" + ' + j + ']';
                    attach_browse_event(form_name, report_id);
                }
            }

            report_ui["form_" + 0].checkItem('enable_paging');
            report_ui["form_" + 0].attachEvent('onChange', function(name, value) {
                
                if (name == "report_option") {
                    report_ui["form_" + 0].enableItem('update_by');
                    report_ui["form_" + 0].enableItem('user_action');                    
                    report_ui["form_" + 0].enableItem('deal_date_from');
                    report_ui["form_" + 0].enableItem('deal_date_to');
                    report_ui["form_" + 0].enableItem('update_date_from');
                    report_ui["form_" + 0].enableItem('update_date_to');

                    if (value == 'c') {
                        report_ui["form_" + 0].disableItem('update_by');
                        report_ui["form_" + 0].disableItem('user_action');
                    } else if (value == 'r' ) {
                        report_ui["form_" + 0].disableItem('update_date_to');
                        report_ui["form_" + 0].disableItem('update_date_from');                        
                    } else if (value == 'a') {
                        report_ui["form_" + 0].disableItem('update_date_to');                        
                    }
                }
            });
            
            report_ui["report_tabs_" + active_object_id].forEachTab(function(tab){                
                var update_date_to = new Date();
                
                var update_date_from = new Date();
                
                update_date_from.setDate(update_date_from.getDate() - 5);
                
                form_obj = tab.getAttachedObject();
                // set_default_value(); //set 'update_date_from' from setup menu 'Setup As of Date'                
                form_obj.setItemValue('update_date_to', update_date_to.toISOString().substring(0, 10));
          
            });

            var att_obj = transcation_audit_log_report.transcation_audit_log_report_layout.cells('a');
            parent.set_apply_filter(att_obj);
        }
        
        function report_parameter() {
            var inner_tab_obj = transcation_audit_log_report.transcation_audit_log_report_layout.cells("a").getAttachedObject();
            var validation_flag = 0;
            
            var param_list = new Array();
            var spa_name = '';
            var radio_flag = '';
            var paging_flag = 0;
            
            inner_tab_obj.forEachTab(function(tab){
                form_obj = tab.getAttachedObject();
                
                var status = validate_form(form_obj);
                
                if (status == false) {
                    validation_flag = 1;
                }
                
                deal_date_from_value = ("" + form_obj.getItemValue("deal_date_from", true) + ""); 
                deal_date_to_value = ("" + form_obj.getItemValue("deal_date_to", true) + ""); 
                
                update_date_from_value = ("" + form_obj.getItemValue("update_date_from", true) + ""); 
                update_date_to_value = ("" + form_obj.getItemValue("update_date_to", true) + "");
                
                month_from_value = ("" + form_obj.getItemValue("entire_term_start", true) + ""); 
                month_to_value = ("" + form_obj.getItemValue("entire_term_end", true) + ""); 
                
                deal_id_from_value = ("" + form_obj.getItemValue("deal_id_from", true) + ""); 
                deal_id_to_value = ("" + form_obj.getItemValue("deal_id_to", true) + ""); 
                
                //To bypass validation if the date is dynamic type
                var static_deal_date_from_value = get_static_date_value(deal_date_from_value);
                var static_deal_date_to_value = get_static_date_value(deal_date_to_value);
                var static_update_date_from_value = get_static_date_value(update_date_from_value);
                var static_update_date_to_value = get_static_date_value(update_date_to_value);
                var static_month_from_value = get_static_date_value(month_from_value);
                var static_month_to_value = get_static_date_value(month_to_value);
                /*Parse date*/
                var deal_date_from_value_parse = (static_deal_date_from_value == '') ? '' : Date.parse(deal_date_from_value);
                var deal_date_to_value_parse = (static_deal_date_to_value == '') ? '' : Date.parse(deal_date_to_value);
                
                var update_date_from_value_parse = (static_update_date_from_value == '') ? '' : Date.parse(update_date_from_value);
                var update_date_to_value_parse = (static_update_date_to_value == '') ? '' : Date.parse(update_date_to_value);
                
                var month_from_value_parse = (static_month_from_value == '') ? '' : Date.parse(month_from_value);
                var month_to_value_parse = (static_month_to_value == '') ? '' : Date.parse(month_to_value);
               
               
                if (deal_date_from_value_parse > deal_date_to_value_parse && deal_date_from_value != '' && deal_date_to_value != '') {
                            validation_flag = 1;
                            show_messagebox('<strong>Deal Date From</strong> should be less than <strong>Deal Date To</strong>.');
                } else if(update_date_from_value_parse > update_date_to_value_parse && update_date_from_value != '' && update_date_to_value != '') {
                            validation_flag = 1;
                            show_messagebox('<strong>Update Date From</strong> should be less than <strong>Update Date To</strong>.');
                } else if(month_from_value_parse > month_to_value_parse && month_from_value != '' && month_to_value != '') {
                            validation_flag = 1;
                            show_messagebox('<strong>Month From</strong> should be less than <strong>Month To</strong>.');
                } else if(deal_id_to_value != '' && deal_id_from_value > deal_id_to_value) {
                            validation_flag = 1;
                            show_messagebox('<strong>Deal ID From</strong> should be less than <strong>Deal ID To</strong>.');
                }

                form_obj.forEachItem(function(name){
                    var item_type = form_obj.getItemType(name);

                    if (name == 'spa_name') {
                        spa_name = form_obj.getItemValue(name);

                    } else if (item_type == 'calendar') {
                            
                        value = form_obj.getItemValue(name, true);
                        if(name == 'entire_term_start'){
                                name = 'tenor_from';
                            }
                        if(name == 'entire_term_end'){
                            name = 'tenor_to';
                        }
                        if (value != '') { 
                            param_list.push('@' + name + '="' + value + '"');
                        }
                    } else if (item_type == 'dyn_calendar') {
                        value = form_obj.getItemValue(name, true);
                        if (value != '') {
                            param_list.push('@' + name + '="' + value + '"'); 
                        }
                    } else if (item_type == 'radio') {
                        value = form_obj.getCheckedValue(name);

                        if(form_obj.isItemChecked(name, value) && radio_flag != name){
                            radio_flag = name;
                            param_list.push('@' + name + '=' + value);
                        }
                    } else if (item_type == 'combo') {
                        var combo_obj = form_obj.getCombo(name);
                        value = combo_obj.getChecked();

                        if (value == '') {
                            value = combo_obj.getSelectedValue();
                        }

                        if (value != '' && value != null) { 
                            param_list.push('@' + name + '="' + value + '"');
                        }
                    } else if (item_type == 'checkbox') { 
                        if (name == 'enable_paging') {
                            var paging = form_obj.isItemChecked(name);
                            if (paging == true) { paging_flag = 1; }
                        }
                    
                    } else if (item_type!= 'block' && item_type!= 'fieldset' && name!= 'report_id' && item_type!= 'button' && name!= 'book_structure') {
                        value = form_obj.getItemValue(name);
                    
                        if (value != '') { 
                            if (name == 'subsidiary_id') {;
                                param_list.push('@sub_id' + '="' + value + '"');
                            } else if (name == 'strategy_id') {
                                param_list.push('@stra_id' + '="' + value + '"');
                            } else if (name == 'book_id') {
                                param_list.push('@book_id' + '="' + value + '"');
                            } else if (name == 'subbook_id' || name == 'label_location_id') {
                                
                            } else {
                               param_list.push('@' + name + '=' + value); 
                           }                            
                        }
                    } 
                });
                
            });
            
            var filter_list = new Array();
             inner_tab_obj.forEachTab(function(tab){
                var tab_name = tab.getText();
                attached_obj = tab.getAttachedObject();
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
                            filter_list.push(form_obj.getItemLabel(name) + '="' + value + '"');
                        }
                    } else if (item_type == 'combo') {
                        var combo_obj = form_obj.getCombo(name);
                        value = combo_obj.getChecked();

                        if (value == '') {
                            value = combo_obj.getSelectedValue();
                            filter_value = combo_obj.getSelectedText();
                        }
                    if (value != '' && value != null) { 
                            filter_list.push(form_obj.getItemLabel(name) + '="' + filter_value + '"');
                        }
                    } else if (item_type == 'checkbox') { 
                        if (name == 'enable_paging') {
                            var paging = form_obj.isItemChecked(name);
                            if (paging == true) { paging_flag = 1; }
                        }
                    }
                 });
            });
            
            filter_list = filter_list.join(' | ') 
            
            var exec_call  = "EXEC " +  spa_name + " " + param_list
            
            if (paging_flag == 1) {
                exec_call = exec_call + '&enable_paging=true&np=1'+ '&applied_filters='+ filter_list;
            } else{
                exec_call = exec_call + '&applied_filters='+ filter_list;
            }
            
            if (validation_flag == 1) {
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
            var inner_tab_obj = transcation_audit_log_report.transcation_audit_log_report_layout.cells("a").getAttachedObject();           
            inner_tab_obj.forEachTab(function(tab) {
                var tab_name = tab.getText();
                form_obj = tab.getAttachedObject();
                if (tab_name == 'General') {
                    form_obj.setItemValue('update_date_from', custom_as_of_date);                              
                }
            })
        }
        }

        function load_business_day(return_json) { 
            var return_json = JSON.parse(return_json);
            var business_day = return_json[0].business_day;             
            
            var inner_tab_obj = transcation_audit_log_report.transcation_audit_log_report_layout.cells("a").getAttachedObject(); 
            inner_tab_obj.forEachTab( function(tab) {
                var tab_name = tab.getText();
                form_obj = tab.getAttachedObject();
                if (tab_name == 'General') {
                    form_obj.setItemValue('update_date_from', business_day);                              
                }
            })
        }
    </script>