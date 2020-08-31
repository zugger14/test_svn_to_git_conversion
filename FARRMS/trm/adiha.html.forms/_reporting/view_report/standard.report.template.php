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
        $report_unique_identifier = get_sanitized_value($_POST['report_unique_identifier'] ?? '');

        $layout_json = '[
                            {
                                id:             "a",
                                text:           "Report Template",
                                header:         false,
                                collapse:       false,
                                fix_size:       [true,true]
                            },

                        ]';

        $layout_name = 'report_template_layout';
        $name_space = 'report_template';
        $layout_obj = new AdihaLayout();
        echo $layout_obj->init_layout($layout_name, '', '1C', $layout_json, $name_space);
        
        echo $layout_obj->close_layout();
    ?> 

    <body class = "bfix"></body>
    
    <script>
        var active_object_id = '<?php echo $active_object_id; ?>';
        var report_type = '<?php echo $report_type; ?>';
        var report_id = '<?php echo $report_id; ?>';
        var report_name = '<?php echo $report_name; ?>';
        var date_from = new Date();
        var date_to = new Date();
        report_ui = {};
        var as_of_date;
        var report_unique_identifier = '<?php echo $report_unique_identifier; ?>';
        /*
        key_prefix,key_suffix,append_user_name  are used for unique key generation.
        Rpt is the identifier for reports. It is used as keyprefix while generating unique cache key.
        */
        $(function(){
            data = {"action": "spa_create_application_ui_json",
                        "flag": "j",
                        "application_function_id": report_id,
                        "template_name": report_name,
                        "parse_xml": "",
                        "key_prefix": (report_unique_identifier != '') ? 'RptStd_' + report_unique_identifier : '',
                        "key_suffix": '',
                        "append_user_name":1
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
            
            report_ui["report_tabs_" + active_object_id] = report_template.report_template_layout.cells("a").attachTabbar();
            report_ui["report_tabs_" + active_object_id].loadStruct(tab_json);
            
            for (j = 0; j < result_length; j++) {
                tab_id = 'detail_tab_' + result[j][0];
                report_ui["form_" + j] = report_ui["report_tabs_" + active_object_id].cells(tab_id).attachForm();
                
                if (result[j][2]) {
                    report_ui["form_" + j].loadStruct(result[j][2]);
                    var form_name = 'report_ui["form_" + ' + j + ']';
                    // set_default_value(); //set 'as_of_date' from setup menu 'Setup As of Date'                    
                    attach_browse_event(form_name, active_object_id, '', 'n');
                }

                report_ui["form_" + j].forEachItem(function (name) {
                    if (name == 'date_from') {                        
                        as_of_date = 'date_from';
                        // set_default_value(); //set 'date_from' from setup menu 'Setup As of Date' 
                    } else if (name == 'date_to') {
                            report_ui["form_" + j].setItemValue('date_to', dates.convert_to_sql(date_to));
                        
                    } else if (name == 'as_of_date_from') {
                        as_of_date = 'as_of_date_from';
                        // set_default_value(); //set 'as_of_date_from' from setup menu 'Setup As of Date' 
                    } else if (name == 'start_date') {
                        as_of_date = 'start_date';
                        // set_default_value(); //set 'start_date' from setup menu 'Setup As of Date' 
                    }
                });
            }
            
            /*privilege report only*/
            if (report_id == '10111300') {
                var enable_paging = false; 
                report_ui["form_" + 0].attachEvent("onChange", function (name, value) {   
                    if (name == 'enable_paging')
                        enable_paging = true; // To set in checkbox as per saved value in filter table when user use filter combo.
                    if (name == 'flag') {
                        if (!enable_paging)
                            report_ui["form_" + 0].uncheckItem('enable_paging');
                        report_ui["form_" + 0].enableItem('enable_paging');
                        enable_paging = false;
                        if ((value == 'f') || (value == 'e')) {
                            report_ui["form_" + 0].checkItem('enable_paging'); 
                            report_ui["form_" + 0].disableItem('enable_paging');                             
                        }
                    }
                });
            } else if (report_id == '20004100') { //Curve Value Report
                var inner_tab_obj_curve = report_template.report_template_layout.cells("a").getAttachedObject();
                var current_date = new Date().toJSON().slice(0,10);
                inner_tab_obj_curve.forEachTab(function(tab){
                    var tab_name = tab.getText();
                    var form_obj_curve = tab.getAttachedObject();
                    if (form_obj_curve instanceof dhtmlXForm) {
                       form_obj_curve.setItemValue('from_date', current_date);
                       form_obj_curve.setItemValue('to_date', current_date);
                        // form_obj_curve.attachEvent("onInputChange", function(name, value, form) {
                        //     if (name == 'from_date' || name == 'to_date') {
                        //         var from_date = form_obj_curve.getItemValue('from_date',true);
                        //         var to_date = form_obj_curve.getItemValue('to_date',true);
                        //         if (from_date && to_date && from_date > to_date) {
                        //             show_messagebox("As of Date To must be greater than As of Date From");
                        //             form_obj_curve.setItemValue(name,null);
                        //         }
                        //     }
                        //     return false;
                        // });
                    }
                });
            } else if (report_id == '20004000') { //Accrual Journal Entry Report
                var inner_tab_obj_curve = report_template.report_template_layout.cells("a").getAttachedObject();
                var current_date = new Date().toJSON().slice(0,10);
                inner_tab_obj_curve.forEachTab(function(tab){
                    var tab_name = tab.getText();
                    var form_obj_curve = tab.getAttachedObject();
                    if (form_obj_curve instanceof dhtmlXForm) {
                       //form_obj_curve.setItemValue('as_of_date', current_date);
                       form_obj_curve.setItemValue('as_of_date', current_date);
                    }

                    // report_ui["form_" + 0].attachEvent("onInputChange", function (name, value, form) {  
                    //     var as_of_date_to = form_obj_curve.getItemValue('as_of_date_to');               
                    //     var as_of_date = form_obj_curve.getItemValue('as_of_date'); 
                    //     if (value && name == 'as_of_date_to' || name == 'as_of_date') {
                    //         if(as_of_date_to && as_of_date_to <= as_of_date) {
                    //             show_messagebox("As of date To is less than As of Date From");
                    //             form_obj_curve.setItemValue(name, null); 
                    //         } 
                    //     }
                    //     return false;
                    // });  
 
                });
            } else if (report_id == '20004300') { // Revenue report.
                var inner_tab_obj_curve = report_template.report_template_layout.cells("a").getAttachedObject();
                var current_date = new Date().toJSON().slice(0,10);
                inner_tab_obj_curve.forEachTab(function(tab){
                    var tab_name = tab.getText();
                    var form_obj_curve = tab.getAttachedObject();
                    if (form_obj_curve instanceof dhtmlXForm) {
                        form_obj_curve.setItemValue('as_of_date_from', current_date);
                        form_obj_curve.setItemValue('as_of_date_to', current_date);
                        //form_obj_curve.setItemValue('as_of_date_from',current_date);
                        //form_obj_curve.setItemValue('as_of_date_to',current_date);

                        // form_obj_curve.attachEvent("onInputChange", function(name, value, form) {
                        //     if (name == 'as_of_date_from' || name == 'as_of_date_to') {
                        //         var from_date = form_obj_curve.getItemValue('as_of_date_from',true);
                        //         var to_date = form_obj_curve.getItemValue('as_of_date_to',true);
                        //         if (from_date && to_date && from_date > to_date) {
                        //             show_messagebox("As of Date To must be greater than As of Date From");
                        //             form_obj_curve.setItemValue(name,null);
                        //         }
                        //     }
                        //     if (name == 'prod_date_from' || name == 'prod_date_to') {
                        //         var prod_date_from = form_obj_curve.getItemValue('prod_date_from',true);
                        //         var prod_date_to = form_obj_curve.getItemValue('prod_date_to',true);
                        //         if (prod_date_from && prod_date_to && prod_date_from > prod_date_to) {
                        //             show_messagebox("Prod Month To must be greater than Prod Month From");
                        //             form_obj_curve.setItemValue(name,null);
                        //         }
                        //     }

                        //     return false;
                        // });
                    }
                });
            }
            
            var att_obj = report_template.report_template_layout.cells('a');
            parent.set_apply_filter(att_obj);

        }
        
        /* Returns as_of_date for costume date in batch page */
        function return_as_of_date() {
            var inner_tab_obj = report_template.report_template_layout.cells("a").getAttachedObject();                    
            var as_of_date;
            
            inner_tab_obj.forEachTab(function(tab){
                var tab_name = tab.getText();
                 form_obj = tab.getAttachedObject();
                 
                 if(form_obj.isItem('custom_as_of_date_field')) {
                    as_of_date_field_name = form_obj.getItemValue('custom_as_of_date_field', true);                 
                    as_of_date = form_obj.getItemValue(as_of_date_field_name, true);
                 } else {
                    as_of_date = '';
                 }                
             });
            
           return as_of_date; 
        }
            
        
        function report_parameter(is_batch) {
            var inner_tab_obj = report_template.report_template_layout.cells("a").getAttachedObject();
            var validation_flag = 0;
            
            var param_list = new Array();
            var filter_list = new Array(); // to display filter in report header for standard report
            var spa_name = '';
            var radio_flag = '';
            var paging_flag = 0;
            var as_of_date_from_value;
            var as_of_date_to_value;
            var entire_term_start_value;
            var entire_term_end_value;
            var start_date_value;
            var end_date_value;
            var filter_value;
            var filter_name;
            var gen_as_of_date = 0;
            var as_of_date_field_name;
                       
            inner_tab_obj.forEachTab(function(tab) {
                form_obj = tab.getAttachedObject();
                
                var status = validate_form(form_obj);
                
                if (status == false) {
                    validation_flag = 1;
                }

                form_obj.forEachItem(function(name) {

                    var item_type = form_obj.getItemType(name);          
                    if (name == 'spa_name') {
                        spa_name = form_obj.getItemValue(name);
                    } else if (name == 'custom_as_of_date_field') {
                        gen_as_of_date = 1;                                              
                    }  else if (name == 'product_id') {
                        param_list.push("@" + name + "='" + product_id + "'");                                               
                    } else if (item_type == 'calendar') {
                        value = form_obj.getItemValue(name, true);                       
                        value_disp = dates.convert_to_user_format(value);

                        if (value != '') {                            
                            as_of_date_field_name = form_obj.getItemValue('custom_as_of_date_field', true);  //this will be field_name for as of date
                            
                            if (is_batch && name == as_of_date_field_name) {
                                param_list.push("@" + name + "='$AS_OF_DATE$'");  
                            } else {
                                param_list.push("@" + name + "='" + value + "'");
                                filter_list.push(form_obj.getItemLabel(name) + "='" + value_disp + "'");
                            }
                        }
                    }  else if (item_type == 'radio') {
                        value = form_obj.getCheckedValue(name);

                        if(form_obj.isItemChecked(name, value) && radio_flag != name) {
                            radio_flag = name;
                            param_list.push("@" + name + "='" + value  + "'");
                            filter_list.push(name + "='" + value + "'");
                        }
                    } else if (item_type == 'combo') {
                        var combo_obj = form_obj.getCombo(name);
                        value = combo_obj.getChecked();

                        if (value == '') {
                            value = combo_obj.getSelectedValue();
                            filter_value = combo_obj.getSelectedText();
                        }
                        if (value) {
                            param_list.push("@" + name + "='" + value  + "'");
                            filter_list.push(form_obj.getItemLabel(name) + "='" + filter_value + "'");                                              
                        } 
                    } else if (item_type == 'checkbox') { 
                        if (name == 'enable_paging') {
                            var paging = form_obj.isItemChecked(name);
                            if (paging == true) { paging_flag = 1; }
                        } else {
                            var value = (form_obj.isItemChecked(name)) ? 'y' : 'n';
                            param_list.push("@" + name + '=' + singleQuote(value));   
                        }   

                    } else if (item_type!= 'block' && item_type!= 'fieldset' && name!= 'report_id' && item_type!= 'button' && name!= 'book_structure') {
                        value = form_obj.getItemValue(name);
                        filter_value = form_obj.getItemValue(name);
                        
                        if (value != '') { 
                            /*TODO: 
                            Temporary solution only. sub book is not processed in SP so sub book parameter is bypassed for report id in exclude_sub_book_param.
                            Instead of bypassing this parameter it should be disabled in book structure browser.
                            */
                            var exclude_sub_book_param = [10232000]; 
                            if (name == 'subbook_id' && exclude_sub_book_param.indexOf(report_id) == -1 ) {
                                //do nothing
                            } else {
                                param_list.push("@" + name + "=" + singleQuote(value));
                            }
                            
                            if (name != 'spa_name' 
                                    && name != 'subsidiary_id'
                                    && name != 'strategy_id'
                                    && name != 'book_id'
                                    && name != 'subbook_id'
                                    && name != 'counterparty_id'
                                    && name != 'deal_status'
                                    && name != 'contract_ids'
                                    && name != 'flag') {
                                filter_list.push(form_obj.getItemLabel(name) + "='" + filter_value + "'");
                            }
                        }
                    } 
                    
                    entire_term_start_value = form_obj.getItemValue('entire_term_start', true);
                   
                    
                    entire_term_end_value = form_obj.getItemValue('entire_term_end', true);  
                    

                    as_of_date_from_value = form_obj.getItemValue('deal_date_from', true);
                    

                   
                    as_of_date_to_value = form_obj.getItemValue('deal_date_to', true);
                    

                    start_date_value = form_obj.getItemValue('start_date', true); 
                    

                    
                    end_date_value = form_obj.getItemValue('end_date', true);
                    

                    
                    if (report_id == '10111300') { // privilege report only
                        
                        as_of_date_from_value = form_obj.getItemValue('as_of_date_from', true);
                        

                        
                        as_of_date_to_value = form_obj.getItemValue('as_of_date_to', true);
                        

                    } else if (report_id == '10202000') {

                        
                        as_of_date_from_value = form_obj.getItemValue('date_from', true);
                        

                        
                        as_of_date_to_value = form_obj.getItemValue('date_to', true);  
                        
                        
                                          
                    }
                });
                
            });

            /*Validation for the Date*/
            if(validation_flag == '0') {
                as_of_date_from_value = get_static_date_value(as_of_date_from_value);
                as_of_date_to_value = get_static_date_value(as_of_date_to_value);
                entire_term_start_value = (entire_term_start_value == null) ? entire_term_start_value : get_static_date_value(entire_term_start_value);
                entire_term_end_value = (entire_term_end_value == null) ? entire_term_end_value : get_static_date_value(entire_term_end_value);
                start_date_value = get_static_date_value(start_date_value);
                end_date_value = get_static_date_value(end_date_value);


                if (as_of_date_from_value !='' && as_of_date_to_value !='' && as_of_date_from_value > as_of_date_to_value) {
                    show_messagebox('<b>As of Date From</b> should be less than <b>As of Date To</b>.');
                    validation_flag = 1;
                }
                else if ((entire_term_start_value !== null) && (entire_term_end_value !== null) && (entire_term_start_value > entire_term_end_value)) {
                    show_messagebox('<b>Term Start</b> should be less than <b>Term End</b>.');
                    validation_flag = 1;
                } else if (((entire_term_start_value == null) && (entire_term_end_value !== null)) || ((entire_term_start_value !== null) && (entire_term_end_value == null))) {
                    show_messagebox('Please enter the both Term Date');
                    validation_flag = 1;
                }

                if (start_date_value !='' && end_date_value != '' && start_date_value > end_date_value) {
                    show_messagebox('<b>As of Date From</b> should be less than <b>As of Date To</b>.');
                    validation_flag = 1;
                }  

            }
            var exec_call  = "EXEC " +  spa_name + " " + param_list;
            
            if (paging_flag == 1) {
                exec_call = exec_call + '&enable_paging=true&np=1';
            }   
                                                      
            if (validation_flag == 1) {
                return false;
            }
             
            filter_list = filter_list.join(' | ') ;                  
            
            if (is_batch) { 
                exec_call = exec_call + '&applied_filters=' + filter_list + '&gen_as_of_date=' + gen_as_of_date;            
            } else {
                exec_call = exec_call + '&applied_filters=' + filter_list ;
            }
            
            if (exec_call == null) {
                return false;
            } else {
                return exec_call;
            }
        }
        
        function set_default_value() {        
            var sp_string =  "EXEC spa_as_of_date @flag = 'a', @screen_id = " + report_id;
            var data_for_post = {"sp_string": sp_string};          
            var return_json = adiha_post_data('return_json', data_for_post, '', '', 'set_default_value_call_back');                  
        }

        function set_default_value_call_back(return_json) { 
            return_json = JSON.parse(return_json);
            as_of_dates = return_json[0].as_of_date;
            no_of_days = return_json[0].no_of_days;
            var date = new Date();
            var custom_as_of_date;
            // to get the latest update of the as of date
            if (as_of_dates == 1) {   
            custom_as_of_date = return_json[0].custom_as_of_date;         
            } else if (as_of_dates == 2) {
                var custom_as_of_date = new Date(date.getFullYear(), date.getMonth(), 1);                   
            } else if (as_of_dates == 3) {
                var custom_as_of_date = new Date(date.getFullYear(), date.getMonth() + 1, 0);                                               
            } else if (as_of_dates == 4) {
                var custom_as_of_date = new Date(date.getFullYear(), date.getMonth(), date.getDate() - 1);            
            } else if (as_of_dates == 5) {
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
            var inner_tab_obj = report_template.report_template_layout.cells("a").getAttachedObject();
            inner_tab_obj.forEachTab(function(tab) {
                var tab_name = tab.getText();
                form_obj = tab.getAttachedObject();
                if (tab_name == 'General') {
                    if (as_of_date == 'date_from')
                        form_obj.setItemValue('date_from', custom_as_of_date); 
                    else if (as_of_date == 'as_of_date_from')
                        form_obj.setItemValue('as_of_date_from', custom_as_of_date);                              
                    else if (as_of_date == 'start_date')
                        form_obj.setItemValue('start_date', custom_as_of_date);                              
                    else
                        form_obj.setItemValue('as_of_date', custom_as_of_date);                              
                }
            })
        }
        }

        function load_business_day(return_json) { 
            var return_json = JSON.parse(return_json);
            var business_day = return_json[0].business_day;             
            
            var inner_tab_obj = report_template.report_template_layout.cells("a").getAttachedObject();
            inner_tab_obj.forEachTab( function(tab) {
                var tab_name = tab.getText();
                form_obj = tab.getAttachedObject();
                if (tab_name == 'General') {
                    if (as_of_date == 'date_from')
                        form_obj.setItemValue('date_from', business_day); 
                    else if (as_of_date == 'as_of_date_from')
                        form_obj.setItemValue('as_of_date_from', business_day);                              
                    else if (as_of_date == 'start_date')
                        form_obj.setItemValue('start_date', business_day);                              
                    else
                        form_obj.setItemValue('as_of_date', business_day);                              
                }
            })
        }
    </script>