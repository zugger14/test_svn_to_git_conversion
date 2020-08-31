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
        $active_object_id = get_sanitized_value($_POST['active_object_id'] ?? 'NULL');
        $report_type = get_sanitized_value($_POST['report_type'] ?? 'NULL');
        $report_id = get_sanitized_value($_POST['report_id'] ?? 'NULL');
        $report_name = get_sanitized_value($_POST['report_name'] ?? 'NULL');

        $layout_json = '[
                            {
                                id:             "a",
                                text:           "Message Board Log Report",
                                header:         false
                            }
                        ]';
        
        $layout_name = 'message_board_log_report_layout';
        $name_space = 'message_board_log_report_template';
        $layout_obj = new AdihaLayout();
        echo $layout_obj->init_layout($layout_name, '', '1C', $layout_json, $name_space);
        
        echo $layout_obj->close_layout();
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
    <script>
        var active_object_id = '<?php echo $active_object_id; ?>';
        var report_type = '<?php echo $report_type; ?>';
        var report_id = '<?php echo $report_id; ?>';
        var report_name = '<?php echo $report_name; ?>';
        var date_from = new Date();
        var date_to = new Date();
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
            
            report_ui["report_tabs_" + active_object_id] = message_board_log_report_template.message_board_log_report_layout.cells("a").attachTabbar();
            
            report_ui["report_tabs_" + active_object_id].loadStruct(tab_json);
            
            tab_id = 'detail_tab_' + result[0][0];

            report_ui["form_" + active_object_id] = report_ui["report_tabs_" + active_object_id].cells(tab_id).attachForm();
            report_ui["form_" + active_object_id].loadStruct(result[0][2]);
            
            report_ui["form_" + active_object_id].setItemValue('as_of_date_to', dates.convert_to_sql(date_to));
            // set_default_value(); //set 'as_of_date_from' from setup menu 'Setup As of Date'

            report_ui["form_" + active_object_id].checkItem('enable_paging');
            report_ui["form_" + active_object_id].disableItem('enable_paging');

            var enable_filter = false; 
            var filter_value;
            report_ui["form_" + active_object_id].attachEvent("onChange", function(name,value,is_checked) {

                if (name == 'source') {
                    enable_filter = true;
                    filter_value = value;
                    var cm_data = report_ui["form_" + active_object_id].getCombo('source');
                    //filter_value = cm_data.getSelectedValue(value_save);
                }
                var flag;
                if (name == 'detail') {
                    if (is_checked == true) {
                        flag = 'q';
                        var cm_param = {"action": "[spa_message_board]", 
                                        "flag": flag,
                                        "call_from": "form",
                                        "has_blank_option": false
                                    };
                                    
                        cm_param = $.param(cm_param);
                        var url = js_dropdown_connector_url + '&' + cm_param;
                        
                        var cm_data = report_ui["form_" + active_object_id].getCombo('source');
                        
                        cm_data.clearAll();
                        cm_data.load(url, function() {
                            cm_data.selectOption(0, false, true);
                            filter_value = null;
                        });

                        report_ui["form_" + active_object_id].uncheckItem('enable_paging');
                        report_ui["form_" + active_object_id].enableItem('enable_paging');
                    } else {
                        flag = 'm';
                        var cm_param = {"action": "[spa_message_board]", 
                                        "flag": flag,
                                        "call_from": "form"
                                    };
                                    
                        cm_param = $.param(cm_param);
                        var url = js_dropdown_connector_url + '&' + cm_param;
                        
                        var cm_data = report_ui["form_" + active_object_id].getCombo('source');
                        
                        cm_data.clearAll();
                        // cm_data.setComboText('');
                        cm_data.load(url, function() {
                            cm_data.setComboText('');
                        });

                        report_ui["form_" + active_object_id].checkItem('enable_paging');
                        report_ui["form_" + active_object_id].disableItem('enable_paging');

                    } 
                }
                            
            });

            
            var form_name = 'report_ui["form_" + ' + active_object_id + ']';
            attach_browse_event(form_name);
            
            var att_obj = message_board_log_report_template.message_board_log_report_layout.cells('a');
            parent.set_apply_filter(att_obj);
        }
        
        function return_as_of_date() {
            var inner_tab_obj = message_board_log_report_template.message_board_log_report_layout.cells("a").getAttachedObject();
            var as_of_date;
            inner_tab_obj.forEachTab(function(tab){
                var tab_name = tab.getText();
                 form_obj = tab.getAttachedObject();
               if (tab_name == 'General') {
                    as_of_date = form_obj.getItemValue('as_of_date_to', true);
               }
   
            })
            return as_of_date; 
        }
     
        function report_parameter(is_batch) {
            var inner_tab_obj = message_board_log_report_template.message_board_log_report_layout.cells("a").getAttachedObject();
            
            var filter_list = new Array();
            
            inner_tab_obj.forEachTab(function(tab) {
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
                    if (value != '') {
                            if (value!= null) {
                            filter_list.push(form_obj.getItemLabel(name) + '="' + filter_value + '"');
                        }
                        }
                    } else if (item_type == 'checkbox') {
                        if (name == 'enable_paging') {
                            var paging = form_obj.isItemChecked(name);
                            if (paging == true) { paging_flag = 1; }
                        }
                    }
                 });
            });

            var flag = attached_obj.getItemValue('flag');
            var user = attached_obj.getItemValue('user');
            var as_of_date_from = attached_obj.getItemValue('as_of_date_from', true);
            var as_of_date_to = attached_obj.getItemValue('as_of_date_to', true);
            var type = attached_obj.getItemValue('type');
            var source = attached_obj.getItemValue('source');
            var is_detail = (attached_obj.isItemChecked('detail') ? 'y' : 'n');
            var enable_paging = (attached_obj.isItemChecked('enable_paging') ? '1' : '0');

            /**Validation**/
             if (attached_obj instanceof dhtmlXForm) {                
                data = attached_obj.getFormData();
                var status = validate_form(attached_obj);
                if (status){
                    var validation_status = true;
                    for (var a in data) {
                        field_label = a;
                        field_value = data[a];
                        
                        if (field_label == "as_of_date_from") {
                            var date_from_val = field_value;
                        } else if (field_label == "as_of_date_to") {
                            var date_to_val = field_value;
                        } else if (field_label == 'source'){
                            var source_val = field_value;
                        } else if(field_label == 'detail') {
                            var detail_val = field_value;
                        }
                        
                    } 
                    
                    //To bypass validation if the date is dynamic type
                    date_from_val = get_static_date_value(date_from_val);
                    date_to_val = get_static_date_value(date_to_val);

                    if ((date_from_val > date_to_val || date_from_val == date_to_val) && date_from_val != '' && date_to_val != ''){
                        validation_status = false;
                        show_messagebox('<b>As of Date From</b> should be less than <b>As of Date To</b>.');
                    }
                    
                    if (detail_val == 'y' && source_val == '' ) {
                            validation_status = false;
                            var message = "Invalid Selection"; 
                            attached_obj.setNote("source", {text:message,width:100});
                            attached_obj.attachEvent("onChange", function(a, value) {
                                   attached_obj.setNote("source", {text:""});
                                }
                            );  
                        
                    }
                    
                } else {
                    validation_status = false;    
                }
            }
            /**end **/   
                     
            var param_list = new Array();
            
           flag = attached_obj.getItemValue('flag');
           user = attached_obj.getItemValue('user');
           as_of_date_from = attached_obj.getItemValue('as_of_date_from', true);
           as_of_date_to = attached_obj.getItemValue('as_of_date_to', true);
           type = attached_obj.getItemValue('type');
           source = attached_obj.getItemValue('source');
           is_detail = (attached_obj.isItemChecked('detail') ? 'y' : 'n');
            
             param_list.push("'" + flag + "'");
             param_list.push("'" + user + "'");
             param_list.push("'" + as_of_date_from + "'");
             
              //if (is_batch == true)
              //   param_list.push("'$AS_OF_DATE$'");
              // else
             param_list.push("'" + as_of_date_to + "'");
                
             param_list.push("'" + source + "'");
             param_list.push("'" + type + "'");
             param_list.push("'" + is_detail + "'");
             
            var enable_paging = attached_obj.isItemChecked('enable_paging');
            enable_paging = (enable_paging == true) ? '1' : '0';
          
            
            var param_string = param_list.toString();
            param_string = param_string.replace(/""/g, 'NULL');
            param_string = param_string.replace(/''/g, 'NULL');
            
            filter_list = filter_list.join(' | ') 
            
            if (validation_status == true ) {
                if (is_batch) {                
                    if (enable_paging == 1) {
                        var exec_call  = "EXEC spa_message_board_log_report " + param_string + '&enable_paging=true&np=1' + '&applied_filters='+ filter_list + '&gen_as_of_date=1';
                    } else {
                        var exec_call  = "EXEC spa_message_board_log_report " + param_string + '&applied_filters='+ filter_list + '&gen_as_of_date=1';
                    }
                } else {
                    if (enable_paging == 1) {
                        var exec_call  = "EXEC spa_message_board_log_report " + param_string + '&enable_paging=true&np=1' + '&applied_filters='+ filter_list ;
                    } else {
                        var exec_call  = "EXEC spa_message_board_log_report " + param_string + '&applied_filters='+ filter_list ;
                    }
                }
                
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
            var inner_tab_obj = message_board_log_report_template.message_board_log_report_layout.cells("a").getAttachedObject();           
            inner_tab_obj.forEachTab(function(tab) {
                var tab_name = tab.getText();
                form_obj = tab.getAttachedObject();
                if (tab_name == 'General') {
                    form_obj.setItemValue('as_of_date_from', custom_as_of_date);                              
                }
            })
        }
        }
        
        function load_business_day(return_json) { 
            var return_json = JSON.parse(return_json);
            var business_day = return_json[0].business_day;             
            
            var inner_tab_obj = message_board_log_report_template.message_board_log_report_layout.cells("a").getAttachedObject();
            inner_tab_obj.forEachTab( function(tab) {
                var tab_name = tab.getText();
                form_obj = tab.getAttachedObject();
                if (tab_name == 'General') {
                    form_obj.setItemValue('as_of_date_from', business_day);                              
                }
            })
        }
        
    </script>
