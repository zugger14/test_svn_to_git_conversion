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
                                text:           "Counterparty MTM Report",
                                header:         false
                            }
                        ]';

        $layout_name = 'mtm_report_layout';
        $name_space = 'mtm_report';
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
        var period_report;
        
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
            
            report_ui["report_tabs_" + active_object_id] = mtm_report.mtm_report_layout.cells("a").attachTabbar();
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
           
            var att_obj = mtm_report.mtm_report_layout.cells('a');
            parent.set_apply_filter(att_obj);
            
            report_ui["form_0"].checkItem('enable_paging');  
            var cmb_obj = report_ui["form_1"].getCombo('transaction_type');
            var cindex = cmb_obj.getIndexByValue('406');
            cmb_obj.setChecked(cindex, true);
            var cindex = cmb_obj.getIndexByValue('401');
            cmb_obj.setChecked(cindex, true);
            var cindex = cmb_obj.getIndexByValue('400');
            cmb_obj.setChecked(cindex, true);
        }

        function return_as_of_date() {
            var inner_tab_obj = mtm_report.mtm_report_layout.cells("a").getAttachedObject();
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
            var inner_tab_obj = mtm_report.mtm_report_layout.cells("a").getAttachedObject();
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
                                    && name != 'subbook_id') { // for other report 
                            filter_list.push(form_obj.getItemLabel(name) + '="' + filter_value + '"');
                        }
                    }
                });



                           
                if (tab_name == 'General') {
                    subsidiary_id = form_obj.getItemValue('subsidiary_id');
                    strategy_id = form_obj.getItemValue('strategy_id');
                    book_entity_id = form_obj.getItemValue('book_id');
                    as_of_date = form_obj.getItemValue('as_of_date', true);
                    previous_as_of_date = form_obj.getItemValue('previous_as_of_date', true);
                  //  report_type  = form_obj.getItemValue('report_type');
                    settlement_option = form_obj.getItemValue('settlement_option');
                    summary_option = form_obj.getItemValue('summary_option');
                  //  discount_option = form_obj.getItemValue('discount_option');
                    deal_type_id = form_obj.getItemValue('deal_type_id');
                    deal_sub_type = form_obj.getItemValue('deal_sub_type');
                    phy_fin = form_obj.getItemValue('phy_fin');
                    deal_id_from = form_obj.getItemValue('deal_id_from');
                    deal_id = form_obj.getItemValue('deal_id');
                    round_value = form_obj.getItemValue('round_value');
					grouping = form_obj.getItemValue('grouping');
                    enable_paging = form_obj.isItemChecked('enable_paging');
                    enable_paging = (enable_paging == true) ? '1' : '0';             
                     
                    if (previous_as_of_date==''|| previous_as_of_date=='NULL'){
                        period_report = 'n';
                    } else {
                        period_report = 'y';
					}
					
					if (deal_id_from == ''){
                        deal_id_from = 'NULL';
					} 
					

                } else if (tab_name == 'Additional') {
                    deal_date_from = form_obj.getItemValue('deal_date_from', true);
                    deal_date_to  = form_obj.getItemValue('deal_date_to', true);
                    trader_id  = form_obj.getItemValue('trader_id');
                    term_start = form_obj.getItemValue('term_start', true);
                    term_end = form_obj.getItemValue('term_end', true);
                    counterparty_id = form_obj.getItemValue('counterparty_id');
				    curve_source_id = form_obj.getItemValue('curve_source_id');
                    var transaction_type_obj = form_obj.getCombo('transaction_type');
                    var transaction_type_combo_val = transaction_type_obj.getChecked();
                    transaction_type = transaction_type_combo_val.toString();                             
                    source_system_book_id1 = form_obj.getItemValue('source_system_book_id1');
                    source_system_book_id2 = form_obj.getItemValue('source_system_book_id2');
                    source_system_book_id3 = form_obj.getItemValue('source_system_book_id3');
					cpty_type_id = form_obj.getItemValue('entity_type');
                   //source_system_book_id4 = form_obj.getItemValue('source_system_book_id4');
                   //show_firstday_gain_loss = form_obj.isItemChecked('show_firstday_gain_loss');
                   //show_firstday_gain_loss = (show_firstday_gain_loss == true) ? 'y' : 'n';
                   //show_only_for_deal_date = form_obj.isItemChecked('show_only_for_deal_date');
                   //show_only_for_deal_date = (show_only_for_deal_date == true) ? 'y' : 'n';
                   //mapped = form_obj.isItemChecked('mapped');
                   //mapped = (mapped == true) ? 'n' : 'm';
                    match_id = form_obj.isItemChecked('match_id');
                    match_id = (match_id == true) ? 'y' : 'n';
                }
            });       

			
            if (is_batch == true)
                param_list.push("'$AS_OF_DATE$'");
            else
            param_list.push("'" + as_of_date + "'");  
			param_list.push("'" + previous_as_of_date + "'");		
            param_list.push("'" + subsidiary_id + "'");
            param_list.push("'" + strategy_id + "'");
            param_list.push("'" + book_entity_id + "'");           
            param_list.push("'" + settlement_option + "'");
            param_list.push("'" + summary_option + "'");
            param_list.push("'" + counterparty_id + "'");
            param_list.push(" NULL ");
            param_list.push(" NULL ");
			param_list.push("'" + trader_id + "'");			
            param_list.push(" NULL ");
            param_list.push("'" + source_system_book_id1 + "'");
            param_list.push("'" + source_system_book_id2 + "'");
            param_list.push("'" + source_system_book_id3 + "'");
            param_list.push(" NULL ");
			param_list.push("'" + transaction_type + "'");
			param_list.push("" + deal_id_from + "" );
            param_list.push("" + deal_id_from + "");
			param_list.push("'" + deal_id + "'");
            param_list.push(" NULL ");			
            param_list.push("'n'");			
            param_list.push("'n'");
			param_list.push("'n'");
			param_list.push("'" + round_value + "'");
			param_list.push(" 'a' ");	
			param_list.push("'" + match_id + "'");
        	param_list.push("'" + cpty_type_id + "'");
			param_list.push("'" + curve_source_id + "'");
			param_list.push("'" + deal_type_id + "'");
			param_list.push("'" + deal_date_from + "'");
            param_list.push("'" + deal_date_to + "'");
			param_list.push("'" + phy_fin + "'");
            param_list.push("'" + deal_sub_type + "'");
			param_list.push("'" + period_report + "'");
			param_list.push("'" + term_start + "'");
            param_list.push("'" + term_end + "'");
			param_list.push(" NULL ");
			param_list.push(" NULL ");
            param_list.push("'n'");
			param_list.push("'" + grouping + "'");
			param_list.push(" NULL ");
			
            var param_string = param_list.toString();
		
            param_string = param_string.replace(/''/g, 'NULL');
            param_string = param_string.replace(/'%%'/g, 'NULL');
            param_string = param_string.replace(/'%/g, '');
            param_string = param_string.replace(/%'/g, '');

		            
            filter_list = filter_list.join(' | ');
                   
            if (is_batch) {                
                if (enable_paging == 1) {
                    var exec_call  = "EXEC spa_Counterparty_MTM_Report " + param_string + '&enable_paging=true&np=1' + '&applied_filters='+ filter_list + '&gen_as_of_date=1';
                } else {
                    var exec_call  = "EXEC spa_Counterparty_MTM_Report " + param_string + '&applied_filters='+ filter_list + '&gen_as_of_date=1';
                }
            } else {
                if (enable_paging == 1) {
                    var exec_call  = "EXEC spa_Counterparty_MTM_Report " + param_string + '&enable_paging=true&np=1' + '&applied_filters='+ filter_list ;
                } else {
                    var exec_call  = "EXEC spa_Counterparty_MTM_Report " + param_string + '&applied_filters='+ filter_list ;
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