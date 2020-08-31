<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
</head>
    <?php
    include '../../../../adiha.php.scripts/components/include.file.v3.php';
    $php_script_loc = $app_php_script_loc;
    $img_rel_loc = $app_php_script_loc;
    $img_rel_loc .= 'adiha_pm_html/process_controls/radio_img/';
    
    $callfrom = get_sanitized_value($_GET['callfrom'] ?? '');
    $dashboard_template_detail_id = get_sanitized_value($_GET['dashboard_template_detail_id'] ?? 'NULL');
    
    /*
    27301 - Deal Based Position
    27302 - Actual
    27303 - Forecast
    27304 - Time Series Data
    27305 - What-If
    27306 - Custom
    27307 - Sub Total
    */
    
    if ($callfrom == '27301') {
        $group_name = 'General'; 
    } else if ($callfrom == '27302') {
        $group_name = 'Meter Filter';
    } else if ($callfrom == '27303') {
        $group_name = 'Forecast Filter'; 
    }  else {
        $group_name = 'Generator Filter'; 
    }
    
    $rights_dashboard_template_detail_filters = 10163013;
    
    list (
        $has_rights_dashboard_template_detail_filters
    ) = build_security_rights(
        $rights_dashboard_template_detail_filters
    );
    
    $layout_json = '[
                        {id: "a", text: "Options", header: false}
                    ]';
    $layout_obj = new AdihaLayout();
    $toolbar_obj = new AdihaToolbar();
    $filter_form_obj = new AdihaForm();
    
    $form_namespace = 'filters';
    $toolbar_json = '[{ id: "save", type: "button", img: "save.gif", text:"Save", title: "Save"}]';
    
    echo $layout_obj->init_layout('options_layout', '', '1C', $layout_json, $form_namespace);
    echo $layout_obj->attach_toolbar_cell("toolbar", "a");  
    echo $toolbar_obj->init_by_attach("toolbar", $form_namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', $form_namespace . '.save_click');
    
    if ($callfrom == '27301') {
        $filter_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10163013', @template_name='DashboardTemplateFilter'";
        $filter_arr = readXMLURL2($filter_sql);
        $tab_json = '';
        $tab_id = $filter_arr[0]['tab_id'];
        
        $i = 0;
        
        for($k = 0; $k < 3; $k++) {
            if ($i > 0)
                $tab_json = $tab_json . ',';
            $tab_json = $tab_json . $filter_arr[$k]['tab_json'];
            $i++;
        }
        
        $tab_json = '[' . $tab_json . ']';
        
        //attach tab to the main layout.
        $tab_name = 'tab_deal_filter';
        echo $layout_obj->attach_tab_cell($tab_name, 'a', $tab_json);

        //Attaching tabbar.
        $tab_obj = new AdihaTab();
        echo $tab_obj->init_by_attach($tab_name, $form_namespace);
        echo $tab_obj->set_active_tab('detail_tab_'.$tab_id);
        echo $tab_obj->set_tab_mode("bottom");
        
        for ($j = 0; $j < 3; $j++) {
            $form_json = $filter_arr[$j][form_json];
            $tab_id = 'detail_tab_' . $filter_arr[$j][tab_id];
            $form_name = 'form_' . $j;
            if ($form_json) {
                echo $tab_obj->attach_form($form_name, $tab_id, $form_json, $form_namespace);
            }
        }
    } else {
        $filter_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10163013', @template_name='DashboardTemplateFilter', @group_name='". $group_name . "'";
        $filter_arr = readXMLURL2($filter_sql);
        $form_json = $filter_arr[0]['form_json'];
            
        $form_name = 'filters_form';
        echo $layout_obj->attach_form($form_name, 'a');
        $filter_form_obj->init_by_attach($form_name, $form_namespace);
        echo $filter_form_obj->load_form($form_json);
    }
    
    echo $layout_obj->close_layout();
    ?>
    
    <script>
        var callfrom = '<?php echo $callfrom; ?>';
        $(function() {
            attach_browse_event('filters.filters_form'); 
            var call_from = '<?php echo $callfrom; ?>';
            if (call_from == '27304') {
                var cm_param = {
                            "action": "('select time_series_definition_id, time_series_name from time_series_definition')"
                        };

                cm_param = $.param(cm_param);
                var url = js_dropdown_connector_url + '?has_blank_option=false&' + cm_param;
                var combo_obj = filters.filters_form.getCombo('generator_name'); 
                combo_obj.setComboText('');
                combo_obj.clearAll();
                combo_obj.load(url)
                filters.filters_form.setItemLabel('generator_name', 'Time Series');
            }
            
        });
        
        filters.save_click = function(id){
            switch(id) {
                case "save":
                    var dashboard_template_detail_id = '<?php echo $dashboard_template_detail_id; ?>';
                    
                    //For Deal Based Position
                    if(callfrom == '27301') {
                        var book_deal_type_map_id = 'NULL';
                        var deal_id_from = filters.form_0.getItemValue("id_from");
                        var deal_id_to = filters.form_0.getItemValue("id_to");
                        var structured_deal_id = filters.form_0.getItemValue("ref_id");
                        var trader_id = filters.form_0.getItemValue("trader");
                        var counterparty_id = filters.form_0.getItemValue("counterparty");
                        var contract_id = filters.form_0.getItemValue("contract");
                        var location = filters.form_0.getItemValue("location");
                        var source_deal_type_id = filters.form_0.getItemValue("deal_type");
                        var deal_date_from = filters.form_0.getItemValue("deal_date_from", true);
                        var deal_date_to = filters.form_0.getItemValue("deal_date_to", true);
                        var entire_term_start = filters.form_0.getItemValue("term_start", true);
                        var entire_term_end = filters.form_0.getItemValue("term_end", true);
                        var created_date_from = filters.form_0.getItemValue("create_date_from", true);
                        var created_date_to = filters.form_0.getItemValue("create_date_to", true);
                        var header_buy_sell_flag = filters.form_0.getItemValue("buy_sell");
                        var gis_cert_number = filters.form_0.getItemValue("certificate_from");
                        var gen_cert_num_to = filters.form_0.getItemValue("certificate_to");
                        
                        var block_type = filters.form_1.getItemValue("block_type");
                        var comodity = filters.form_1.getItemValue("commodity");
                        var dealstatuscombo = filters.form_1.getItemValue("deal_status");
                        var source_system_book_id1 = filters.form_1.getItemValue("group_1");
                        var source_system_book_id2 = filters.form_1.getItemValue("group_2");
                        var source_system_book_id3 = filters.form_1.getItemValue("group_3");
                        var source_system_book_id4 = filters.form_1.getItemValue("group_4");
                        var index = filters.form_1.getItemValue("index");
                        var index_group = filters.form_1.getItemValue("index_group");
                        var confirm_type = filters.form_1.getItemValue("confirmation_status");                        
                        var deal_sub_type_type_id = filters.form_1.getItemValue("deal_sub_type");
                        var deal_category_value_id = filters.form_1.getItemValue("deal_category");
                        var portfolio = filters.form_1.getItemValue("internal_portfolio");
                        var broker = filters.form_1.getItemValue("broker");
                        var sort_by = filters.form_1.getItemValue("sort_by");
                        var signed_off_flag = filters.form_1.getItemValue("signed_off_status");
                        var signed_off_by = filters.form_1.getItemValue("signed_off_by");
                        var physical_financial_flag = filters.form_1.getItemValue("physical_financial");
                        var description4 = filters.form_1.getItemValue("group_4");
                        var generator_id = filters.form_2.getItemValue("generator");
                        var gis_value_id = filters.form_2.getItemValue("certification_entity");
                        var gis_cert_date = filters.form_2.getItemValue("certification_date", true);
                        var gen_cert_number = filters.form_2.getItemValue("certificate_number");
                        var gen_cert_date = filters.form_2.getItemValue("registered_date", true);
                        var status_value_id = filters.form_2.getItemValue("status");
                        var status_date = filters.form_2.getItemValue("status_date", true);
                        var assignment_type_value_id = filters.form_2.getItemValue("assignment_type");
                        var compliance_year = filters.form_2.getItemValue("compliance_year");
                        var state_value_id = filters.form_2.getItemValue("assignment_jurisdiction");
                        var assigned_date = filters.form_2.getItemValue("assigned_date", true);
                        var assigned_by = filters.form_2.getItemValue("assignment_by");
                        
                        var sub_entity_id = 'NULL';
                        var strategy_entity_id = 'NULL';
                        var book_id = 'NULL';
                        var user_name = getAppUserName();
                        
                        /*var exec_call = 'EXEC spa_sourcedealheader '
                                + singleQuote(blank_check('s')) + ', '
                                + singleQuote(blank_check(book_deal_type_map_id)) + ', '
                                + blank_check(deal_id_from) + ', '
                                + blank_check(deal_id_to) + ', '
                                + singleQuote(blank_check(deal_date_from)) + ', '
                                + singleQuote(blank_check(deal_date_to)) + ', ' + 'NULL, NULL' + ', '
                                + singleQuote(blank_check(structured_deal_id)) + ', ' + 'NULL' + ', ' + 'NULL' + ', '
                                + singleQuote(blank_check(physical_financial_flag)) + ', ' + 'NULL, '
                                + singleQuote(blank_check(counterparty_id)) + ', '
                                + singleQuote(blank_check(entire_term_start)) + ', '
                                + singleQuote(blank_check(entire_term_end)) + ', '
                                + singleQuote(blank_check(source_deal_type_id)) + ', '
                                + singleQuote(blank_check(deal_sub_type_type_id)) + ', ' + ' NULL, NULL, NULL, '
                                + singleQuote(blank_check(source_system_book_id1)) + ', '
                                + singleQuote(blank_check(source_system_book_id2)) + ', '
                                + singleQuote(blank_check(source_system_book_id3)) + ', '
                                + singleQuote(blank_check(source_system_book_id4)) + ', NULL, NULL, NULL,'
                                + blank_check(deal_category_value_id) + ', '
                                + blank_check(trader_id) + ', NULL, NULL, '
                                + singleQuote(blank_check(book_id)) + ', NULL, NULL, '
                                + singleQuote(blank_check(header_buy_sell_flag)) + ', NULL, '
                                + blank_check(generator_id) + ', '
                                + singleQuote(blank_check(gis_cert_number)) + ', '
                                + blank_check(gis_value_id) + ', '
                                + singleQuote(blank_check(gis_cert_date)) + ', '
                                + singleQuote(blank_check(gen_cert_number)) + ', '
                                + singleQuote(blank_check(gen_cert_date)) + ', '
                                + blank_check(status_value_id) + ', '
                                + singleQuote(blank_check(status_date)) + ', '
                                + blank_check(assignment_type_value_id) + ', '
                                + blank_check(compliance_year) + ', '
                                + blank_check(state_value_id) + ', '
                                + singleQuote(blank_check(assigned_date)) + ', '
                                + singleQuote(blank_check(assigned_by)) + ', '
                                + singleQuote(blank_check(gen_cert_num_to)) + ', NULL, NULL, NULL, NULL, NULL, NULL, '
                                + singleQuote(blank_check(sort_by)) + ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '
                                + singleQuote(blank_check(block_type)) + ', NULL, NULL, NULL, '
                                + singleQuote(blank_check(description4)) + ', NULL, NULL, NULL, '
                                + blank_check(confirm_type) + ', ' + singleQuote(blank_check(created_date_from)) + ', '
                                + singleQuote(blank_check(created_date_to)) + ',NULL, NULL, NULL, NULL, '
                                + blank_check(dealstatuscombo) + ', NULL, ' + singleQuote(blank_check(signed_off_flag)) + ', '
                                + singleQuote(blank_check(signed_off_by)) + ', '
                                + singleQuote(blank_check(broker)) + ', NULL, '
                                + singleQuote(blank_check(index_group)) + ', '
                                + singleQuote(blank_check(location)) + ', '
                                + blank_check(index) + ', '
                                + blank_check(comodity) + ', NULL, NULL, NULL, NULL' + ', '
                                + singleQuote(blank_check(sub_entity_id)) + ', '
                                + singleQuote(blank_check(strategy_entity_id)) + ', NULL, '
                                + 'NULL, NULL, NULL, NULL, NULL, NULL, '
                                + singleQuote(blank_check(contract_id)) + ', '
                                + blank_check(portfolio);*/
                        var exec_call = deal_id_from;
                    } else if(callfrom == '27302') {
                        var meter_id = filters.filters_form.getItemValue("meter_id");
                        var channel = filters.filters_form.getItemValue("channel");
                        
                        exec_call = meter_id.toString();
                    } else if(callfrom == '27303') {
                        var profile = filters.filters_form.getItemValue("profile_id");
                        var ean = filters.filters_form.getItemValue("ean");
                        
                        var exec_call = 'EXEC spa_load_forecast_report '
                                        + profile + ', NULL, NULL, NULL, NULL, NULL, '
                                        + "''d''" + ',' 
                                        + "''r''" + ', 2, ' 
                                        + blank_check(ean);
                    } else if(callfrom = '27308' || callfrom == '27304') {
                        var generator_name = filters.filters_form.getItemValue("generator_name");;
                        var exec_call = generator_name;
                    }
                    
                    var param = {
                        "flag": "f",
                        "action": "spa_dashboard_template_detail",
                        "dashboard_template_detail_id": dashboard_template_detail_id,
                        "filter": exec_call
                    };
                    
                    var return_value = adiha_post_data('alert', param, '', '', '', '');
                    break;
                default:
                    break;
            }
        }
        
        function blank_check(x) {
            if (x == '') {
                var y = 'NULL';
            } else if (x == null) {
                var y = 'NULL';
            } else if (x != 'NULL') {
                var y = "'" + x + "'";
            } else {
                var y = x;
            }
            return y;
        }                
    </script>   