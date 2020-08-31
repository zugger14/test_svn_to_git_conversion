<!--DOCTYPE transitional.dtd-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<meta http-equiv="X-UA-Compatible" content="IE=Edge"> 
<html>  
    <?php 
        include '../../../adiha.php.scripts/components/include.file.v3.php';
        $module_type = '15500'; //Fas (module type)
        list($default_as_of_date_to, $default_as_of_date_from) = getDefaultAsOfDate($module_type);
        
        $active_object_id = get_sanitized_value($_POST['active_object_id'] ?? 'NULL');
        $report_type = get_sanitized_value($_POST['report_type'] ?? 'NULL');
        $report_id = get_sanitized_value($_POST['report_id'] ?? 'NULL');
        $report_name = get_sanitized_value($_POST['report_name'] ?? 'NULL');

        /********************/
        $link_id = get_sanitized_value($_POST['link_id'] ?? '');
        $strategy_id = get_sanitized_value($_POST['strategy_id'] ?? '0');
        $subsidiary_id = get_sanitized_value($_POST['subsidiary_id'] ?? '0');
        $book_id = get_sanitized_value($_POST['book_id'] ?? '0');
        $book_structure_text = get_sanitized_value($_POST['book_structure_text'] ?? '0');
        $effective_date_to = get_sanitized_value($_POST['effective_date_to'] ?? '0');
        /********************/

        $layout_json = '[
                            {
                                id:             "a",
                                text:           "Report Template",
                                header:         false,
                                collapse:       false,
                                fix_size:       [true,true]
                            },

                        ]';

        $layout_name = 'journal_layout';
        $name_space = 'journal';
        $layout_obj = new AdihaLayout();
        echo $layout_obj->init_layout($layout_name, '', '1C', $layout_json, $name_space);
        
        echo $layout_obj->close_layout();

        // get most recent measurement report date for as of date
        $recent_as_of_date_sql = "SELECT CONVERT(varchar(10), MAX(rmv.as_of_date),126) as_of_date FROM report_measurement_values AS rmv where link_id = '" . $link_id . "'";
        $recent_as_of_date_data = readXMLURL2($recent_as_of_date_sql);

        // get most recent measurement report date from archive 1 for as of date id measurement report date
        // could not be found
        if (($recent_as_of_date_data[0]['as_of_date'] ?? null) == null) {
            $recent_as_of_date_sql = "SELECT CONVERT(varchar(10), MAX(rmva1.as_of_date),126) as_of_date FROM report_measurement_values_arch1 AS rmva1 where link_id = '" . $link_id . "'";
            $recent_as_of_date_data = readXMLURL2($recent_as_of_date_sql);
//            die($recent_as_of_date_sql);
        }
        // get most recent measurement report date from archive 1 for as of date id measurement report date
        // from archive 1 could not be found
        if (($recent_as_of_date_data[0]['as_of_date'] ?? null) == null) {
            $recent_as_of_date_sql = "SELECT CONVERT(varchar(10), MAX(rmva2.as_of_date),126) as_of_date FROM report_measurement_values_arch2 AS rmva2 where link_id = '" . $link_id . "'";
            $recent_as_of_date_data = readXMLURL2($recent_as_of_date_sql);
        }
        //
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
        
        var link_id = '<?php echo $link_id;?>';
        var strategy_id = '<?php echo $strategy_id;?>';
        var subsidiary_id = '<?php echo $subsidiary_id;?>';
        var book_id = '<?php echo $book_id;?>';
        var book_structure_text = '<?php echo $book_structure_text;?>';
        var effective_date_to = '<?php echo $effective_date_to; ?>';

        // alert('<?php echo $recent_as_of_date_data[0]['as_of_date']==null?'null':'val';?>');

        if(link_id == 'undefined') {
            link_id = 0;
        }

        if(strategy_id == 'undefined') {
            strategy_id = 0;
        }

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
            
            report_ui["report_tabs_" + active_object_id] = journal.journal_layout.cells("a").attachTabbar();
            report_ui["report_tabs_" + active_object_id].loadStruct(tab_json);
            
            for (j = 0; j < result_length; j++) {
                tab_id = 'detail_tab_' + result[j][0];
                report_ui["form_" + j] = report_ui["report_tabs_" + active_object_id].cells(tab_id).attachForm();
                
                if (result[j][2]) {
                    report_ui["form_" + j].loadStruct(result[j][2]);
                    var form_name = 'report_ui["form_' + j + '"]';
                    // attach_browse_event(form_name, active_object_id);
                    attach_browse_event(form_name, active_object_id, '', 'n');
                    set_default_value(); //set 'as_of_date' from setup menu 'Setup As of Date'

                    if (link_id != 0) {
                        report_ui["form_" + j].setItemValue('link_id', link_id);
                    }

                    // attach_browse_event(form_name, active_object_id, '', 'n');

                    if (strategy_id != 0) {
                        report_ui["form_" + j].setItemValue('strategy_id', strategy_id);
                        report_ui["form_" + j].setItemValue('subsidiary_id', subsidiary_id);
                        report_ui["form_" + j].setItemValue('book_id', book_id);
                        report_ui["form_" + j].setItemValue('book_structure', book_structure_text);
                    }

                    if(link_id > 0) {
                        var recent_as_of_date = '<?php echo $recent_as_of_date_data[0]['as_of_date'];?>';
                        report_ui["form_" + j].setItemValue('as_of_date', recent_as_of_date);

                        var combo_object_summary_option = report_ui["form_" + j].getCombo('summary_option');
                        combo_object_summary_option.attachEvent("onXLE", function(){
                            combo_object_summary_option.forEachOption(function(optId){
                            if (optId.text == 'Detail') {
                                    combo_object_summary_option.selectOption(optId.index);
                            }
                        });
                        });

                        var combo_object_discount_option = report_ui["form_" + j].getCombo('discount_option');
                        combo_object_discount_option.attachEvent("onXLE", function(){
                            combo_object_discount_option.forEachOption(function(optId){
                            if (optId.text == 'Present Value') {
                                    combo_object_discount_option.selectOption(optId.index);
                            }
                        });
                        });   
                    }
                }
                    // });
            // }

            // }
            }
            if(link_id <= 0) {
                report_ui["form_0"].setItemValue('as_of_date', '<?php echo $default_as_of_date_to; ?>');
            }
            report_ui["form_" + 0].setNote('drill_gl_number', {
                text: "<span style='color:black'>Use comma (,) as a seperator for multiple GL Number.</span>", width:300
            });  
            var att_obj = journal.journal_layout.cells('a');
            parent.set_apply_filter(att_obj);
            if(link_id != 0 ) {
                parent.show_report(report_id, 'html', false, false);
            }
        }
        
        /* Returns as_of_date for custom date in batch page */
        function return_as_of_date() {
            var inner_tab_obj = journal.journal_layout.cells("a").getAttachedObject();
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
            var inner_tab_obj = journal.journal_layout.cells("a").getAttachedObject();
            var validation_flag = 0;
            
            var param_list = new Array();
            var filter_list = new Array(); // to display filter in report header for standard report
            var spa_name = '';
            var radio_flag = '';
            var paging_flag = 0;
            var as_of_date_from_value;
            var as_of_date_to_value;
            var tenor_from_value;
            var tenor_to_value;
            var filter_value;
            var filter_name;
            var gen_as_of_date = 0;
            var as_of_date_field_name;
            var is_sap_report = 0;           
            var drill_gl_number;            
            inner_tab_obj.forEachTab(function(tab){
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
                    } else if (item_type == 'calendar') {
                        value = form_obj.getItemValue(name, true);                       
                        
                        if (value != '') {                            
                            as_of_date_field_name = form_obj.getItemValue('custom_as_of_date_field', true);  //this will be field_name for as of date
                            
                            if (is_batch && name == as_of_date_field_name) {
                                param_list.push('@' + name + '=\'$AS_OF_DATE$\'');  
                            } else {
                                filter_val = value;

                                if (item_type == 'calendar') {
                                    filter_val = (filter_val != '') ? dates.convert_to_user_format(filter_val) : '';
                                 }

                                param_list.push('@' + name + '=\'' + value + '\'');
                                filter_list.push(form_obj.getItemLabel(name) + '="' + filter_val + '"');
                            }
                        }
                    } else if (item_type == 'radio') {
                        value = form_obj.getCheckedValue(name);

                        if(form_obj.isItemChecked(name, value) && radio_flag != name){
                            radio_flag = name;
                            param_list.push('@' + name + '=' + value);
                            filter_list.push(name + '="' + value + '"');
                        }
                    } else if (item_type == 'combo') {
                        var combo_obj = form_obj.getCombo(name);
                        value = combo_obj.getChecked();
                        
                        if (value == '') {
                            value = combo_obj.getSelectedValue();
                            filter_value = combo_obj.getSelectedText();
                            
                            if (name == 'sap_export') {
                                is_sap_report = value;
                            } 
                        }

                        if (value != '' && value != null) { 
                            param_list.push('@' + name + '=\'' + value + '\'');
                            filter_list.push(form_obj.getItemLabel(name) + '="' + filter_value + '"');                                               
                        } 
                    } else if (item_type == 'checkbox') { 
                        if (name == 'enable_paging') {
                            var paging = form_obj.isItemChecked(name);
                            if (paging == true) { paging_flag = 1; }
                        } else {
                            var value = (form_obj.isItemChecked(name)) ? 'y' : 'n';
                            param_list.push('@' + name + '=' + singleQuote(value));   
                        }   

                    } else if (item_type!= 'block' && item_type!= 'fieldset' && name!= 'report_id' && item_type!= 'button' && name!= 'book_structure' && item_type!= 'browser_label') {
                        value = form_obj.getItemValue(name);
                        filter_value = form_obj.getItemValue(name);
                        if (name == 'drill_gl_number') drill_gl_number = value;
                        
                        if (value != '') { 
                            /*TODO: 
                            Temporary solution only. sub book is not processed in SP so sub book parameter is bypassed.
                            Instead of bypassing this parameter it should be disabled in book structure browser.
                            */
                                                        
                            if (name != 'subbook_id' && name.indexOf('label') != 0) {
                                param_list.push('@' + name + '=' + singleQuote(value));
                            }
                            
                            if (name != 'spa_name' 
                                    && name != 'subsidiary_id'
                                    && name != 'strategy_id'
                                    && name != 'book_id'
                                    && name != 'subbook_id'
                                    && name != 'flag'
                                    
                                    ) {
                                filter_list.push(form_obj.getItemLabel(name) + '="' + filter_value + '"');
                            }
                        }                        
                    } 
                                        
                });
                
            });
            
            if (drill_gl_number.length != 0 && is_batch == false) {                
                dhtmlx.alert({
                   title: 'Error',
                   type: 'alert-error',
                   text: 'When Drill GL Number is provided, this report must be run in Batch mode. Please press Batch button.'
                });       

                validation_flag = 1
            }

             if (validation_flag == 1) {
                return false;
            }
            
            var exec_call  = "EXEC " +  spa_name + " " + param_list;
                                          
            if (paging_flag == 1) {
                exec_call = exec_call + '&enable_paging=true&np=1';
            }
                        
            filter_list = filter_list.join(' | ') ;                  
            
            exec_call = exec_call + '&is_sap_report=' + is_sap_report + '&applied_filters=' + filter_list + '&gen_as_of_date=' + gen_as_of_date;
            
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
            var inner_tab_obj = journal.journal_layout.cells("a").getAttachedObject();
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
            
            var inner_tab_obj = journal.journal_layout.cells("a").getAttachedObject();
            inner_tab_obj.forEachTab( function(tab) {
                var tab_name = tab.getText();
                form_obj = tab.getAttachedObject();
                if (tab_name == 'General') {
                    form_obj.setItemValue('as_of_date', business_day);                              
                }
            })
        }
    </script>