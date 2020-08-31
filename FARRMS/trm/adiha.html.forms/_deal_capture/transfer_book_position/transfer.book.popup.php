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
    //Creating Layout
    $layout_obj = new AdihaLayout();
    $form_obj = new AdihaForm();
    $layout_name = 'transfer_criteria_layout';
    $namespace = 'transfer_criteria_namespace';
    $function_id = 10131600;
    $index = get_sanitized_value($_REQUEST['index_id'] ?? 'NULL');
    $json = '[
                {
                    id:             "a",
                    text:           "Apply Filters",
                    header:         true,
                    collapse:       false,
                    height:         90
                },               
                {
                    id:             "b",
                    text:           "Transfer Criteria",
                    header:         true,
                    collapse:       false
                },               

            ]';
    echo $layout_obj->init_layout($layout_name, '', '2E', $json, $namespace);
    $form_name = 'transfer_criteria';
    $toolbar_json = '[      
                        { id: "ok", type: "button", img: "tick.png", text: "Ok", title: "Ok", imgdis:"tick_dis.png"},
                        { id: "cancel", type: "button", img: "close.gif", text: "Cancel", title: "Cancel", imgdis:"close_dis.gif", hidden: true},
                      ]';
    echo $layout_obj->attach_toolbar($form_name); 
    $transfer_book_toolbar = new AdihaToolbar();
    echo $transfer_book_toolbar->init_by_attach($form_name, $namespace);
    echo $transfer_book_toolbar->load_toolbar($toolbar_json);
    echo $transfer_book_toolbar->attach_event('', 'onClick', 'btn_ok_click'); 

    $filter_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10131600', @template_name='TransferCriteria', @group_name='general'";
    $filter_arr = readXMLURL2($filter_sql);
    $form_json = $filter_arr[0]['form_json'];

    $form_obj = new AdihaForm();
    $form_name = 'common_form';
    echo $layout_obj->attach_form($form_name, 'b');
    $form_obj->init_by_attach($form_name, $namespace);
    echo $form_obj->load_form($form_json);

    echo $layout_obj->close_layout();
    ?>
</body>
<script>
    $(function(){ 
        //Load Apply Filters
        var function_id  = 10131600;
        var report_type = 2;
        var filter_obj = transfer_criteria_namespace.transfer_criteria_layout.cells('a').attachForm();
        var layout_cell_obj =transfer_criteria_namespace.transfer_criteria_layout.cells('b');

        load_form_filter(filter_obj, layout_cell_obj, function_id, report_type);
        transfer_criteria_namespace.transfer_criteria_layout.cells('a').collapse();

        var combo_counterpart_from = transfer_criteria_namespace.common_form.getCombo('txt_cmb_counterparty_from'); 
        combo_counterpart_from.attachEvent("onChange", function(value, text) {       
        var combo_coutract_from = transfer_criteria_namespace.common_form.getCombo("txt_cmb_contract_id_from");
        var combo_coutract_from_sql = {"action":"spa_source_contract_detail", "flag":"e", "counterparty_id":value};
        load_combo(combo_coutract_from, combo_coutract_from_sql);
          });

        var combo_counterpart_to = transfer_criteria_namespace.common_form.getCombo('txt_cmb_counterparty_to'); 
        combo_counterpart_to.attachEvent("onChange", function(value, text) {       
        var combo_coutract_to = transfer_criteria_namespace.common_form.getCombo("txt_cmb_contract_id_to");
        var combo_coutract_to_sql = {"action":"spa_source_contract_detail", "flag":"e", "counterparty_id":value};
        load_combo(combo_coutract_to, combo_coutract_to_sql);
          });

        var combo_counterpart_to = transfer_criteria_namespace.common_form.getCombo('transfer_pricing'); 
        combo_counterpart_to.attachEvent("onChange", function(value, text) { 
            if(value == 'd'){ 
                transfer_criteria_namespace.common_form.disableItem('txt_fixed_price');
            }else 
                transfer_criteria_namespace.common_form.enableItem('txt_fixed_price');
         });    
    });

    function load_combo(combo_obj, combo_sql) {
        var data = $.param(combo_sql);
        var url = js_dropdown_connector_url + '&' + data;
        combo_obj.load(url);
    }

    function btn_ok_click(id){ 

        switch(id) {
            case "ok":
                var existing_curve_id = '<?php echo $index; ?>';
                
                check_price_value =transfer_criteria_namespace.common_form.getItemValue('txt_fixed_price');
                if (check_price_value != null ) {
                    if (isNaN(check_price_value)){ 
                        transfer_criteria_namespace.common_form.setNote('txt_fixed_price',{text:'Invalid Number',width:100});
                        return false;
                    } 
                }

                if (validate_form(transfer_criteria_namespace.common_form) == false) {
                    return false;
                }       

                transfer_criteria_namespace.transfer_criteria.disableItem('ok');    
                var template_id = transfer_criteria_namespace.common_form.getItemValue('template');
                var source_book_mapping_offset = transfer_criteria_namespace.common_form.getItemValue('txt_source_book_mapping_offset');
                var cmb_counterparty_from = transfer_criteria_namespace.common_form.getItemValue('txt_cmb_counterparty_from');
                var contract_from = transfer_criteria_namespace.common_form.getItemValue('txt_cmb_contract_id_from');
                contract_from = (contract_from == '') ? 'NULL' : contract_from; 
                var cmb_trader_from = transfer_criteria_namespace.common_form.getItemValue('txt_cmb_trader_from');
                var source_book_mapping_to = transfer_criteria_namespace.common_form.getItemValue('txt_source_book_mapping_to');
                var cmb_counterparty_to = transfer_criteria_namespace.common_form.getItemValue('txt_cmb_counterparty_to');
                var contract_to = transfer_criteria_namespace.common_form.getItemValue('txt_cmb_contract_id_to');
                contract_to = (contract_to == '') ? 'NULL' : contract_to;
                var cmb_trader_to = transfer_criteria_namespace.common_form.getItemValue('txt_cmb_trader_to'); 
                var txt_fixed_price = transfer_criteria_namespace.common_form.getItemValue('txt_fixed_price');
                txt_fixed_price = (txt_fixed_price == '') ? 'NULL' : txt_fixed_price;         
                var transfer_pricing_option = transfer_criteria_namespace.common_form.getItemValue('transfer_pricing'); 
                var as_of_date = dates.convert_to_sql(parent.transfer_book_namespace.common_form.getItemValue('dt_as_of_date_text', true));            
                var trader_id = parent.layout_tab_cell_a2_from_f.getItemValue('txt_cmb_source_trader');
                trader_id = (trader_id == '') ? 'NULL' : trader_id; 
                var term_start = dates.convert_to_sql(parent.transfer_book_namespace.common_form.getItemValue('dt_term_start', true));
                var term_end = dates.convert_to_sql(parent.transfer_book_namespace.common_form.getItemValue('dt_term_end', true)); 
                var counterparty_id = parent.layout_tab_cell_a2_from_f.getItemValue('txt_cmb_counterparty');
                counterparty_id = (counterparty_id == '') ? 'NULL' : counterparty_id;               
                var round = parent.layout_tab_cell_a2_from_f.getItemValue('txt_cmb_round');        
                var commodity_id = parent.layout_tab_cell_a2_from_f.getItemValue('txt_cmb_source_commodity');
                commodity_id = (commodity_id == '') ? 'NULL' : commodity_id;      
                //var location = parent.transfer_book_namespace.new_position_form.getItemValue('location'); 
                var volume_uom = parent.transfer_book_namespace.new_position_form.getItemValue('txt_cmb_volume_uom');
                var curve_id = parent.transfer_book_namespace.new_position_form.getItemValue('txt_cmb_index');
                var volume_frequency = parent.transfer_book_namespace.new_position_form.getItemValue('txt_cmb_volume_frequency');
                volume_frequency = (volume_frequency == '') ? 'NULL' : volume_frequency;
                var volume = parent.transfer_book_namespace.new_position_form.getItemValue('txt_volume');
                volume = (volume == '') ? 'NULL' : volume; 
                var subsidiary_id = parent.layout_tab_cell_a2_from_f.getItemValue('subsidiary_id'); 
                subsidiary_id = (subsidiary_id == '') ? 'NULL' : subsidiary_id; 
                var strategy_id = parent.layout_tab_cell_a2_from_f.getItemValue('strategy_id');
                strategy_id = (strategy_id == '') ? 'NULL' : strategy_id; 
                var book_entity_id = parent.layout_tab_cell_a2_from_f.getItemValue('book_id');
                book_entity_id = (book_entity_id == '') ? 'NULL' : book_entity_id; 
                var chk_use_existing_deals = 'y';       
                var active_tab_id = parent.transfer_book_namespace.transfer_layout_book_tabs.getActiveTab(); 
                
                if(active_tab_id == 'a1') {
                var chk_use_existing_deals = 'n';  
                data = {
                        "action":                       "spa_transfer_book_position",                                     
                        "template_id":                  template_id,
                        "book_map_id_offset":           source_book_mapping_offset,
                        "book_map_id_transfer":         source_book_mapping_to,
                        "counterparty_from":            cmb_counterparty_from,               
                        "trader_from":                  cmb_trader_from,
                        "counterparty_to":              cmb_counterparty_to,
                        "trader_to":                    cmb_trader_to,
                        "fixed_price":                  txt_fixed_price,
                        "transfer_pricing_option":      transfer_pricing_option,
                        "as_of_date":                   as_of_date,
                        "sub_entity_id":                'NULL',
                        "strategy_entity_id":           'NULL',
                        "book_entity_id":               'NULL',
                        "source_system_book_id1":       'NULL',
                        "source_system_book_id2":       'NULL',
                        "source_system_book_id3":       'NULL',
                        "source_system_book_id4":       'NULL',
                        "commodity_id":                 'NULL',
                        "trader_id":                    'NULL',
                        "term_start":                   term_start,
                        "term_end":                     term_end,
                        "counterparty_id":              'NULL',
                        "use_existing_deal":            chk_use_existing_deals,
                        "curve_id":                     curve_id,
                        "volume":                       volume,
                        "volume_frequency":             volume_frequency,
                        "volume_uom":                   volume_uom,
                        "round":                        'NULL',
                        "contract_id_from":             contract_from,
                        "contract_id_to":               contract_to
                        };     
                        adiha_post_data("return_array", data, '', '', 'call_back');
                        }

                        if(active_tab_id == 'a2') {
                    var chk_use_existing_deals = 'y'; 
                        data = {
                            "action":                       "spa_transfer_book_position",                                     
                            "template_id":                  template_id,
                            "book_map_id_offset":           source_book_mapping_offset,
                            "book_map_id_transfer":         source_book_mapping_to,
                            "counterparty_from":            cmb_counterparty_from,               
                            "trader_from":                  cmb_trader_from,
                            "counterparty_to":              cmb_counterparty_to,
                            "trader_to":                    cmb_trader_to,
                            "fixed_price":                  txt_fixed_price,
                            "transfer_pricing_option":      transfer_pricing_option,
                            "as_of_date":                   as_of_date,
                            "sub_entity_id":                subsidiary_id,
                            "strategy_entity_id":           strategy_id,
                            "book_entity_id":               book_entity_id,
                            "source_system_book_id1":       'NULL',
                            "source_system_book_id2":       'NULL',
                            "source_system_book_id3":       'NULL',
                            "source_system_book_id4":       'NULL',
                            "commodity_id":                 commodity_id,
                            "trader_id":                    trader_id,
                            "term_start":                   term_start,
                            "term_end":                     term_end,
                            "counterparty_id":              counterparty_id,
                            "use_existing_deal":            chk_use_existing_deals,
                            "curve_id":                     existing_curve_id,
                            "volume":                       'NULL',
                            "volume_frequency":             'NULL',
                            "volume_uom":                   'NULL',
                            "round":                        round,
                            "contract_id_from":             contract_from,
                            "contract_id_to":               contract_to
                            };                                               
                            adiha_post_data("return_array", data, '', '', 'call_back');
                        }
                       break;                                          
            case "cancel": 
                parent.close_window();
            break;
            }
        }
        function call_back(result) {
            if (result[0][0] == 'Success') {
                dhtmlx.message({
                    text:(result[0][4]),
                    expire:1000
                });

                setTimeout(function(){
                    parent.close_window(); 
                }, 1050);   
            } else {
                dhtmlx.message({
                    type: "alert",
                    title: "Alert",
                    text: (result[0][4])
                });                
            }           
        }
</script>
     
