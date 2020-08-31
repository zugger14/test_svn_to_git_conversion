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
                                text:           "Deal Settlement Report",
                                header:         false
                            }
                        ]';

        $layout_name = 'deal_settlement_report_layout';
        $name_space = 'deal_settlement_report';
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
            
            report_ui["report_tabs_" + active_object_id] = deal_settlement_report.deal_settlement_report_layout.cells("a").attachTabbar();
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
            
            report_ui["report_tabs_" + active_object_id].forEachTab(function(tab){
                form_obj = tab.getAttachedObject();
                form_obj.disableItem('deal_status');
                form_obj.attachEvent("onChange", function (name, value){
                    if (name == 'official_status') {
                        var offical_status = form_obj.isItemChecked('official_status');   
                        
                        if (offical_status == true) {
                            form_obj.disableItem('deal_status');
                        } else {
                            form_obj.enableItem('deal_status');
                        }
                    }   
                    
                    if (name == 'summary_option') {
                        for (j = 0; j < result_length; j++) {
                            var combo_object = report_ui["form_" + j].getCombo('summary_option');
                            if (combo_object != null) {
                                var combo_option = combo_object.getComboText();
                            
                                if (combo_option == 'Detail') {
                                    report_ui["form_" + j].checkItem('enable_paging');
                                } else {
                                    report_ui["form_" + j].uncheckItem('enable_paging');
                                }
                            }                            
                        }
                    }   
                });
            });
            
            var att_obj = deal_settlement_report.deal_settlement_report_layout.cells('a');
            parent.set_apply_filter(att_obj);
        }
        
        function get_message(code) {
            switch (code) {
                case 'SETTLEMENT_DATE_VALIDATION':
                    return '<b>Settlement Date From</b> cannot be greater than <b>Settlement Date To</b>.';
                case 'TERM_DATE_VALIDATION':
                    return '<b>Term Start</b> cannot be greater than <b>Term End</b>.';
                case 'DEAL_DATE_VALIDATION':
                    return '<b>Deal Date From</b> cannot be greater than <b>Deal Date To</b>.';
            }
        }
        
        function return_as_of_date() {
            var inner_tab_obj = deal_settlement_report.deal_settlement_report_layout.cells("a").getAttachedObject();
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
            var inner_tab_obj = deal_settlement_report.deal_settlement_report_layout.cells("a").getAttachedObject();
            var validate_flag = 0;
            
            var param_list = new Array();
            var filter_list = new Array();
            
            inner_tab_obj.forEachTab(function(tab){
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
                        value = dates.convert_to_user_format(value);

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
                        filter_value = unescapeXML(form_obj.getItemValue(name));
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
                                    && name != 'contract_ids') { // for other report 
                            filter_list.push(form_obj.getItemLabel(name) + '="' + filter_value + '"');
                        }
                    }
                });
                           
                if (tab_name == 'General') {
                    subsidiary_id = form_obj.getItemValue('subsidiary_id');
                    strategy_id = form_obj.getItemValue('strategy_id');
                    book_entity_id = form_obj.getItemValue('book_id');
                    settlement_date_from = form_obj.getItemValue('settlement_date_from', true);
                    settlement_date_to = form_obj.getItemValue('settlement_date_to', true);
                    as_of_date = form_obj.getItemValue('as_of_date', true);
                    term_start = form_obj.getItemValue('term_start', true);
                    term_end = form_obj.getItemValue('term_end', true);
                    summary_option = form_obj.getItemValue('summary_option');
                    detail_option = form_obj.getItemValue('detail_option');
                    deal_id_from = form_obj.getItemValue('deal_id_from');
                    deal_id = form_obj.getItemValue('deal_id');
                    deal_filter = form_obj.getItemValue('deal_filter');
                    round_value = form_obj.getItemValue('round_value');
                    convert_uom = form_obj.getItemValue('convert_uom');
                    counterparty_id = form_obj.getItemValue('counterparty_id');
                    contract_ids = form_obj.getItemValue('contract_ids');
                    enable_paging = form_obj.isItemChecked('enable_paging');
                    enable_paging = (enable_paging == true) ? '1' : '0';
                } else if (tab_name == 'Additional') {
                    deal_date_from = form_obj.getItemValue('deal_date_from', true);
                    deal_date_to = form_obj.getItemValue('deal_date_to', true);
                    deal_type_id = form_obj.getItemValue('deal_type_id', true);
                    trader_id = form_obj.getItemValue('trader_id', true);
                    phy_fin = form_obj.getItemValue('phy_fin', true);
                    source_system_book_id1 = form_obj.getItemValue('source_system_book_id1', true);
                    source_system_book_id2 = form_obj.getItemValue('source_system_book_id2', true);
                    source_system_book_id3 = form_obj.getItemValue('source_system_book_id3', true);
                    source_system_book_id4 = form_obj.getItemValue('source_system_book_id4', true);
                    parent_counterparty = form_obj.getItemValue('parent_counterparty', true);
                    counterparty = form_obj.getItemValue('counterparty', true);
                    curve_source_id = form_obj.getItemValue('curve_source_id', true);
                    entity_type = form_obj.getItemValue('entity_type', true);
                    offical_status = form_obj.isItemChecked('official_status');
                    deal_status = form_obj.getItemValue('deal_status');
                    
                    if (offical_status == true) {
                        deal_status = 'NULL'
                    }                   
                }
            });
            
            //To bypass validation if the date is dynamic type
            res_settlement_date_from = get_static_date_value(settlement_date_from);
            res_settlement_date_to = get_static_date_value(settlement_date_to);
            res_term_start = get_static_date_value(term_start);
            res_term_end = get_static_date_value(term_end);
            res_deal_date_from = get_static_date_value(deal_date_from);
            res_deal_date_to = get_static_date_value(deal_date_to);

            if ((res_settlement_date_from !== "") && (res_settlement_date_to !== "") && (res_settlement_date_from > res_settlement_date_to)) {
                validate_flag = 1;
                show_messagebox(get_message('SETTLEMENT_DATE_VALIDATION'));
            } 
            
            if ((res_term_start !== "") && (res_term_end !== "") && (res_term_start > res_term_end)) {
                validate_flag = 1;
                show_messagebox(get_message('TERM_DATE_VALIDATION')); 
            }
            
            if ((res_deal_date_from !== "") && (res_deal_date_to !== "") && (res_deal_date_from > res_deal_date_to)) {
                validate_flag = 1;
                show_messagebox(get_message('DEAL_DATE_VALIDATION')); 
            }
            
            if (is_batch == true)
                param_list.push("'$AS_OF_DATE$'");
            else
                param_list.push("'" + as_of_date + "'");
            
            param_list.push("'" + subsidiary_id + "'");
            param_list.push("'" + strategy_id + "'");
            param_list.push("'" + book_entity_id + "'");
            param_list.push("'u'");//discount_option
            param_list.push("'s'");//settlement_option
            param_list.push("'a'");//report_type
            param_list.push("'" + summary_option + "'");
            param_list.push("'" + counterparty_id + "'");
            param_list.push("NULL");//tenor_from
            param_list.push("NULL");//tenor_to
            param_list.push("NULL");//previous_as_of_date
            param_list.push("'%" + trader_id + "%'");
            param_list.push("NULL");//include_item
            param_list.push("'%" + source_system_book_id1 + "%'");
            param_list.push("'%" + source_system_book_id2 + "%'");
            param_list.push("'%" + source_system_book_id3 + "%'");
            param_list.push("'%" + source_system_book_id4 + "%'");
            param_list.push("NULL");//show_firstday_gain_loss
            param_list.push("NULL");//transaction_type
            param_list.push("'%" + deal_id_from + "%'");
            param_list.push("'%" + deal_id_from + "%'");//deal_id_to
            param_list.push("'" + deal_id + "'");
            param_list.push("NULL");//threshold_values
            param_list.push("NULL");//show_prior_processed_values
            param_list.push("NULL");//exceed_threshold_value
            param_list.push("NULL");//show_only_for_deal_date
            param_list.push("NULL");//use_create_date
            param_list.push("'" + round_value + "'");
            param_list.push("'" + counterparty + "'");
            param_list.push("NULL");//mapped
            param_list.push("NULL");//match_id
            param_list.push("'%" + entity_type + "%'");
            param_list.push("'%" + curve_source_id + "%'");
            param_list.push("NULL");//deal_sub_type
            param_list.push("'" + deal_date_from + "'");
            param_list.push("'" + deal_date_to + "'");
            param_list.push("'" + phy_fin + "'");
            param_list.push("'%" + deal_type_id + "%'");
            param_list.push("NULL");//period_report
            param_list.push("'" + term_start + "'");
            param_list.push("'" + term_end + "'");
            param_list.push("'" + settlement_date_from + "'");
            param_list.push("'" + settlement_date_to + "'");
            param_list.push("'y'");//settlement_only
            param_list.push("NULL");//drill1
            param_list.push("NULL");//drill2
            param_list.push("NULL");//drill3
            param_list.push("NULL");//drill4
            param_list.push("NULL");//drill5
            param_list.push("NULL");//drill6
            param_list.push("NULL");//risk_bucket_header_id
            param_list.push("NULL");//risk_bucket_detail_id 
            param_list.push("NULL");//commodity_id
            param_list.push("'%" + deal_status + "%'");
            param_list.push("'%" + convert_uom + "%'");
            param_list.push("NULL");//show_by
            param_list.push("'%" + parent_counterparty + "%'");
            param_list.push("NULL");//graph
            param_list.push("'" + deal_filter + "'");
            param_list.push("'" + detail_option + "'");
            param_list.push("'" + contract_ids + "'"); 
                  
          //  param_list.push('@discount_option="u"');
//            param_list.push('@settlement_option="s"');
//            param_list.push('@report_type="a"');
//            param_list.push('@settlement_only="y"');       
            
            var param_string = param_list.toString();
            param_string = param_string.replace(/''/g, 'NULL');
            param_string = param_string.replace(/'%%'/g, 'NULL');
            param_string = param_string.replace(/'%/g, '');
            param_string = param_string.replace(/%'/g, '');
            
            
            filter_list = filter_list.join(' | ');
            
            if (is_batch) {
                if (enable_paging == 1) {
                    var exec_call = 'EXEC spa_Create_MTM_Period_Report_TRM ' + param_string + '&enable_paging=true&np=1&applied_filters=' + filter_list + '&gen_as_of_date=1';
                } else {
                    var exec_call = 'EXEC spa_Create_MTM_Period_Report_TRM ' + param_string + '&applied_filters=' + filter_list + '&gen_as_of_date=1';
                }
            } else {
                if (enable_paging == 1) {
                    var exec_call = 'EXEC spa_Create_MTM_Period_Report_TRM ' + param_string + '&enable_paging=true&np=1&applied_filters=' + filter_list;
                } else {
                    var exec_call = 'EXEC spa_Create_MTM_Period_Report_TRM ' + param_string + '&applied_filters=' + filter_list;
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
        
    </script>