<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
    <style type="text/css">
    html, body {
        width: 100%;
        height: 100%;
        margin: 0px;
        padding: 0px;
        background-color: #ebebeb;
        overflow: hidden;
    }      
     
    </style>
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
                                text:           "Hedge Ineffectiveness Report",
                                header:         false
                            }
                        ]';

        $layout_name = 'run_hedge_ineffectiveness_report_layout';
        $name_space = 'run_hedge_ineffectiveness_report';
        $layout_obj = new AdihaLayout();
        echo $layout_obj->init_layout($layout_name, '', '1C', $layout_json, $name_space);
        echo $layout_obj->close_layout();
    ?> 
</body> 
      
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
            
            report_ui["report_tabs_" + active_object_id] = run_hedge_ineffectiveness_report.run_hedge_ineffectiveness_report_layout.cells("a").attachTabbar();
            report_ui["report_tabs_" + active_object_id].loadStruct(tab_json);
             
            for (j = 0; j < result_length; j++) {
                tab_id = 'detail_tab_' + result[j][0];
                report_ui["form_" + j] = report_ui["report_tabs_" + active_object_id].cells(tab_id).attachForm();
                
                if (result[j][2]) {
                    report_ui["form_" + j].loadStruct(result[j][2]);
                    var form_name = 'report_ui["form_" + ' + j + ']';
                    // set_default_value(); //set 'as_of_date' from setup menu 'Setup As of Date'
                    attach_browse_event(form_name, report_id, '', 'n');
                }
            }
            
            report_ui["report_tabs_" + active_object_id].forEachTab(function(tab) {
                form_obj = tab.getAttachedObject();
                as_of_date =  new Date();
                form_obj.attachEvent("onChange", function (name, value) {

                    if (name == 'accounting_type') {
                        for (j = 0; j < result_length; j++) {
                            var combo_object = report_ui["form_" + j].getCombo('accounting_type');
                            var combo_option = combo_object.getComboText();
                            
                            if (combo_option == 'MTM') {
                                form_obj.disableItem('link_id_from');
                                form_obj.disableItem('link_id_to');
                                form_obj.disableItem('link_description');
                            } else {
                                form_obj.enableItem('link_id_from');
                                form_obj.enableItem('link_id_to');
                                form_obj.enableItem('link_description');                                
                            }
                        }
                    }   
                });
            });
            
            var att_obj = run_hedge_ineffectiveness_report.run_hedge_ineffectiveness_report_layout.cells('a');
            parent.set_apply_filter(att_obj);
        }
                
        function return_as_of_date() {
            var inner_tab_obj = run_hedge_ineffectiveness_report.run_hedge_ineffectiveness_report_layout.cells("a").getAttachedObject();
            inner_tab_obj.forEachTab(function(tab){
                var tab_name = tab.getText();
                form_obj = tab.getAttachedObject();
                
                if (tab_name == 'General') {
                    var as_of_date = form_obj.getItemValue('as_of_date', true);
                }
            })
                
            return as_of_date;
        }
        
        function report_parameter(is_batch) {
            var inner_tab_obj = run_hedge_ineffectiveness_report.run_hedge_ineffectiveness_report_layout.cells("a").getAttachedObject();
            var validate_flag = 0;
            
            var param_list = new Array();
            var filter_list = new Array();
            
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
                            filter_list.push(form_obj.getItemLabel(name) + '="' + value + '"');
                        }
                    } else if (item_type == 'radio') {
                        value = form_obj.getCheckedValue(name);

                        if (form_obj.isItemChecked(name, value) && radio_flag != name){
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
                        if (name == 'enable_paging') {
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
                                    && name != 'subbook_id') {
                            filter_list.push(form_obj.getItemLabel(name) + '="' + filter_value + '"');
                        }
                    }
                });
                             
                if (tab_name == 'General') {
                    subsidiary_id = form_obj.getItemValue('subsidiary_id');
                    strategy_id = form_obj.getItemValue('strategy_id');
                    book_entity_id = form_obj.getItemValue('book_id');
                    as_of_date = form_obj.getItemValue('as_of_date', true);
                    report_type = form_obj.getItemValue('report_type');
                    accouting_type = form_obj.getItemValue('accounting_type');
                    present_future_value = form_obj.getItemValue('present_future_value');
                    link_id_from = form_obj.getItemValue('link_id_from');
                    link_id_to = form_obj.getItemValue('link_id_to');
                    deal_id = form_obj.getItemValue('deal_id');
                    ref_id = form_obj.getItemValue('ref_id');
                    link_description = form_obj.getItemValue('link_description');
                    round_value = form_obj.getItemValue('round_value');
                    enable_paging = form_obj.isItemChecked('enable_paging');
                    enable_paging = (enable_paging == true) ? '1' : '0';
                }
            });
            
            if (report_type == 's') {
                param_list.push("'" + subsidiary_id + "'");
                param_list.push("'" + strategy_id + "'");
                param_list.push("'" + book_entity_id + "'");
                //(is_batch == true) ? param_list.push("'$AS_OF_DATE$'") : 
                param_list.push("'" + as_of_date + "'");
                param_list.push("'%" + link_id_from + "%'");
                param_list.push("'%" + link_id_to + "%'");
                param_list.push("'" + link_description + "'");
                param_list.push("'" + accouting_type + "'");
                param_list.push("'" + present_future_value + "'");
                param_list.push("'" + round_value + "'");
                param_list.push("'" + report_type + "'");
                param_list.push("'%" + deal_id + "%'");
                param_list.push("'" + ref_id + "'");
                
                var param_string = param_list.toString();
                param_string = param_string.replace(/''/g, 'NULL');
                param_string = param_string.replace(/'%%'/g, 'NULL');
                param_string = param_string.replace(/'%/g, '');
                param_string = param_string.replace(/%'/g, '');
    			var exec_call = "EXEC spa_create_hedge_effectiveness_report " + param_string;
            } else {
    		  	if (accouting_type != 'm') {
                    //(is_batch == true) ? param_list.push("'$AS_OF_DATE$'") : 
                    param_list.push("'" + as_of_date + "'");
                    param_list.push("'" + subsidiary_id + "'");
                    param_list.push("'" + strategy_id + "'");
                    param_list.push("'" + book_entity_id + "'");
                    param_list.push("'d'");
                    param_list.push("'a'");
                    param_list.push("'c'");
                    param_list.push("'m'");
                    param_list.push("'%" + link_id_from + "%'");
                    param_list.push("'" + round_value + "'");
                    param_list.push("NULL");
                    param_list.push("NULL");
                    param_list.push("'%" + deal_id + "%'");
                    param_list.push("'" + ref_id + "'");
                    param_list.push("NULL");
                    param_list.push("NULL");
                    param_list.push("'%" + link_id_to + "%'");
                    param_list.push("'" + link_description + "'");
                    
                    var param_string = param_list.toString();
                    param_string = param_string.replace(/''/g, 'NULL');
                    param_string = param_string.replace(/'%%'/g, 'NULL');
                    param_string = param_string.replace(/'%/g, '');
                    param_string = param_string.replace(/%'/g, '');
                    var exec_call = "EXEC spa_Create_Hedges_Measurement_Report " + param_string;
                } else {
                    //(is_batch == true) ? param_list.push("'$AS_OF_DATE$'") : 
                    param_list.push("'" + as_of_date + "'");
                    param_list.push("'" + subsidiary_id + "'");
                    param_list.push("'" + strategy_id + "'");
                    param_list.push("'" + book_entity_id + "'");
                    param_list.push("'d'");
                    param_list.push("'a'");
                    param_list.push("'a'");
                    param_list.push("'m'");
                    param_list.push("'%" + link_id_from + "%'");
                    param_list.push("'" + round_value + "'");
                    param_list.push("NULL");
                    param_list.push("NULL");
                    param_list.push("'%" + deal_id + "%'");
                    param_list.push("'" + ref_id + "'");
                    param_list.push("NULL");
                    param_list.push("NULL");
                    
                    var param_string = param_list.toString();
                    param_string = param_string.replace(/''/g, 'NULL');
                    param_string = param_string.replace(/'%%'/g, 'NULL');
                    param_string = param_string.replace(/'%/g, '');
                    param_string = param_string.replace(/%'/g, '');
        		  	var exec_call = " EXEC spa_Create_MTM_Measurement_Report " + param_string;                
                }
            }
             
            filter_list = filter_list.join(' | '); 
             
            if(is_batch) {
                if (enable_paging == 1) {
                    var exec_call = exec_call + '&enable_paging=true&np=1&applied_filters=' + filter_list + '&gen_as_of_date=0';
                } else {
                    var exec_call = exec_call + '&applied_filters=' + filter_list + '&gen_as_of_date=0';
                }
            } else {
                if (enable_paging == 1) {
                    var exec_call = exec_call + '&enable_paging=true&np=1&applied_filters=' + filter_list;
                } else {
                    var exec_call = exec_call + '&applied_filters=' + filter_list;
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
            var inner_tab_obj = run_hedge_ineffectiveness_report.run_hedge_ineffectiveness_report_layout.cells("a").getAttachedObject();
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
            
            var inner_tab_obj = run_hedge_ineffectiveness_report.run_hedge_ineffectiveness_report_layout.cells("a").getAttachedObject();
            inner_tab_obj.forEachTab( function(tab) {
                var tab_name = tab.getText();
                form_obj = tab.getAttachedObject();
                if (tab_name == 'General') {
                    form_obj.setItemValue('as_of_date', business_day);                              
                }
            })
        }
    </script>