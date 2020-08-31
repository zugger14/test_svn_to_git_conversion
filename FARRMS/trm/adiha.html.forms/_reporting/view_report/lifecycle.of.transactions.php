<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
<body class = "bfix"> 
    <?php 
        $active_object_id = get_sanitized_value($_POST['active_object_id'] ?? 'NULL');
        $report_type = get_sanitized_value($_POST['report_type'] ?? 'NULL');
        $report_id = get_sanitized_value($_POST['report_id'] ?? 'NULL');
        $report_name = get_sanitized_value($_POST['report_name'] ?? 'NULL');

        $layout_json = '[
                            {
                                id:             "a",
                                text:           "Lifecycle of Transactions Report",
                                header:         false
                            }
                        ]';

        $layout_name = 'lifecycle_of_transactions_report_layout';
        $name_space = 'lifecycle_of_transactions_report';
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
            
            report_ui["report_tabs_" + active_object_id] = lifecycle_of_transactions_report.lifecycle_of_transactions_report_layout.cells("a").attachTabbar();
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
            
            var att_obj = lifecycle_of_transactions_report.lifecycle_of_transactions_report_layout.cells('a');
            parent.set_apply_filter(att_obj);

            var today = new Date();
            var inner_tab_obj = lifecycle_of_transactions_report.lifecycle_of_transactions_report_layout.cells("a").getAttachedObject();
            inner_tab_obj.forEachTab(function(tab) { 
                form_obj = tab.getAttachedObject();  
                form_obj.setItemValue('as_of_date',today);
            });
        }
                    
        function report_parameter(is_batch) {
            var inner_tab_obj = lifecycle_of_transactions_report.lifecycle_of_transactions_report_layout.cells("a").getAttachedObject();
            var validate_flag = 0;
            
            var param_list = new Array();
            var filter_list = new Array();
            
            inner_tab_obj.forEachTab(function(tab) {
                var tab_name = tab.getText();
                form_obj = tab.getAttachedObject();
                
                var status = validate_form(form_obj);
                
                if (status == false) {
                    validate_flag = 1;
                    return
                }
                
                form_obj.forEachItem(function(name) {
                    var item_type = form_obj.getItemType(name);
    
                    if (item_type == 'calendar') {
                        value = form_obj.getItemValue(name, true);

                        if (value != '') { 
                            filter_list.push(form_obj.getItemLabel(name) + '="' + value + '"');
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
                        if (name == 'enable_paging') {
                            var paging = form_obj.isItemChecked(name);
                            if (paging == true) { paging_flag = 1; }
                        }

                    } else if (item_type!= 'block' && item_type!= 'fieldset' && name!= 'report_id' && item_type!= 'button') {
                        value = form_obj.getItemValue(name);
                        filter_value = form_obj.getItemValue(name);
                        if (report_id == '10171300') { // for Deal confirm report only.
                            if (value != '') { 
                                if (name == 'book_structure') {
                                    filter_list.push('Book Structure="' + filter_value + '"');
                                } else {
                                    
                                }
                            }
                        } else if (value != '' 
                                    && name != 'spa_name' 
                                    && name != 'subsidiary_id'
                                    && name != 'strategy_id'
                                    && name != 'book_id'
                                    && name != 'subbook_id'
                                    && name != 'counterparty_id'
                                    && name != 'deal_status'
                                    && name != 'contract_ids') { 
                            filter_list.push(form_obj.getItemLabel(name) + '="' + filter_value + '"');
                        }
                    }
                });
                           
                if (tab_name == 'General') {
                    subsidiary_id = form_obj.getItemValue('subsidiary_id');
                    strategy_id = form_obj.getItemValue('strategy_id');
                    book_entity_id = form_obj.getItemValue('book_id');
                    subbook_id = form_obj.getItemValue('subbook_id');

                    deal_id_from = form_obj.getItemValue('deal_id_from');
                    deal_cert_from = form_obj.getItemValue('deal_cert_from');
                    deal_id_to = form_obj.getItemValue('deal_id_to');
                    deal_cert_to = form_obj.getItemValue('deal_cert_to');

                    deal_date_from = form_obj.getItemValue('deal_date_from', true);
                    deal_date_to = form_obj.getItemValue('deal_date_to', true);
                    as_of_date = form_obj.getItemValue('as_of_date', true);
                    enable_paging = form_obj.isItemChecked('enable_paging');
                    enable_paging = (enable_paging == true) ? '1' : '0';
                } else if (tab_name == 'Other') {
                    physical_financial = form_obj.getItemValue('physical_financial');
                    ref_id = form_obj.getItemValue('ref_id');
                    counterparty_id = form_obj.getItemValue('counterparty_id');
                    deal_type_id = form_obj.getItemValue('deal_type_id');

                    deal_sub_type_id = form_obj.getItemValue('deal_sub_type_id');
                    deal_category_id = form_obj.getItemValue('deal_category_id');
                    trader = form_obj.getItemValue('trader');

                    term_start = form_obj.getItemValue('term_start', true);
                    term_end = form_obj.getItemValue('term_end', true);
                    description_1 = form_obj.getItemValue('description_1');
                    description_2 = form_obj.getItemValue('description_2');
                    description_3 = form_obj.getItemValue('description_3');                  
                } else if (tab_name == 'Compliance') {
                    generator_credit_source = form_obj.getItemValue('generator_credit_source');
                    certificate_entity = form_obj.getItemValue('certificate_entity');
                    certificate_date = form_obj.getItemValue('certificate_date', true);
                    status1 = form_obj.getItemValue('status');

                    assignment_type = form_obj.getItemValue('assignment_type');
                    assigned_jurisdiction = form_obj.getItemValue('assigned_jurisdiction');
                    assigned_date = form_obj.getItemValue('assigned_date', true);
                    assigned_by = form_obj.getItemValue('assigned_by');

                    status_date = form_obj.getItemValue('status_date', true);
                    compliance_year = form_obj.getItemValue('compliance_year');
                    buy_sell = form_obj.getItemValue('buy_sell');      
                    g_certificate_no = form_obj.getItemValue('g_certificate_no');
                    g_certificate_date = form_obj.getItemValue('g_certificate_date', true);             
                }
            });
            
            if ((deal_id_from !== "") && (deal_id_to !== "") && (deal_id_from >= deal_id_to)) {
                validate_flag = 1;
                show_messagebox('<b>ID From</b> should be less than <b>ID To</b>.');
                return
            }

            if ((deal_date_from !== "") && (deal_date_to !== "") && (Date.parse(deal_date_from) >= Date.parse(deal_date_to))) {
                validate_flag = 1;
                show_messagebox('<b>Deal Date From</b> should be less than <b>Deal Date To</b>.');
                return
            }

            if ((term_start !== "") && (term_end !== "") && (Date.parse(term_start) > Date.parse(term_end))) {
                validate_flag = 1;
                show_messagebox('<b>Term Start</b> cannot be greater than <b>Term End</b>.');
                return
            } 

            var n = subbook_id.search(",");
            if(n > 0) {
                validate_flag = 1;
                show_messagebox('Please select only one sub book.');
            }
            
            if (is_batch == true)
                param_list.push("'$AS_OF_DATE$'");
            else
                param_list.push("'" + as_of_date + "'");
            
            // param_list.push("'" + subsidiary_id + "'");
            // param_list.push("'" + strategy_id + "'");
            param_list.push("'" + subbook_id + "'");
            param_list.push("NULL");
            param_list.push("'" + deal_cert_from + "'");
            param_list.push("'" + deal_cert_to + "'");

            param_list.push("'" + deal_date_from + "'");
            param_list.push("'" + deal_date_to + "'");
            param_list.push("'" + deal_id_from + "'");
            param_list.push("'" + deal_id_to + "'");
            param_list.push("'" + counterparty_id + "'");

            param_list.push("'" + deal_type_id + "'");
            param_list.push("'" + deal_sub_type_id + "'");
            param_list.push("'" + deal_category_id + "'");
            param_list.push("'" + physical_financial + "'");
            param_list.push("'" + trader + "'");

            param_list.push("'" + term_start + "'");
            param_list.push("'" + term_end + "'");
            param_list.push("'" + description_1 + "'");
            param_list.push("'" + description_2 + "'");
            param_list.push("'" + description_3 + "'");

            param_list.push("'" + generator_credit_source + "'");
            param_list.push("'" + compliance_year + "'");
            param_list.push("'" + certificate_entity + "'");
            param_list.push("'" + certificate_date + "'");
            param_list.push("'" + g_certificate_no + "'");

            param_list.push("'" + g_certificate_date + "'");
            param_list.push("'" + assignment_type + "'");
            param_list.push("'" + assigned_jurisdiction + "'");
            param_list.push("'" + assigned_date + "'");
            param_list.push("'" + assigned_by + "'");

            param_list.push("'" + status1 + "'");
            param_list.push("'" + status_date + "'");
            param_list.push("'" + buy_sell + "'");
            param_list.push("'" + ref_id + "'");     
            
            var param_string = param_list.toString();
            param_string = param_string.replace(/''/g, 'NULL');
            param_string = param_string.replace(/""/g, 'NULL');
            
            
            filter_list = filter_list.join(' | ') 
             
            if (enable_paging == 1) {
                var exec_call = 'EXEC spa_create_lifecycle_of_recs ' + param_string + '&enable_paging=true&np=1&applied_filters=' + filter_list + '&gen_as_of_date=1';
            } else {
                var exec_call = 'EXEC spa_create_lifecycle_of_recs ' + param_string + '&applied_filters=' + filter_list + '&gen_as_of_date=1';
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
        
    </script>