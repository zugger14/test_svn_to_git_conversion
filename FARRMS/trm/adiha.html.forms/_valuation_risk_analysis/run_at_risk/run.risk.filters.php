<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php require('../../../adiha.php.scripts/components/include.file.v3.php');?>
</head>
<body>
<?php
    $query = $_POST['dataquery'];
    $data_set = readXMLURL2($query);
    $component_tenor = get_sanitized_value($_POST['tenor_enable'] ?? 'false' , 'boolean'); 
    $component_portfolio_group = get_sanitized_value($_POST['req_portfolio_group'] ?? 'false' ,'boolean'); 
    
    $i = 0;
    $trader_id =array();
    $commodity_id = array();
    $deal_type_id = array();
    $counterparty_id = array();
    foreach ($data_set as $key => $value){
        foreach ($value as $key1 => $value1){
            if ($key1 == 'trader_id') {
                $trader_id[$i] = $value1;
            }
            if ($key1 == 'commodity_id') {
                $commodity_id[$i] = $value1;
            }
            if ($key1 == 'deal_type_id') {
                $deal_type_id[$i] = $value1;
            }
            if ($key1 == 'counterparty_id') {
                $counterparty_id[$i] = $value1;
            }
            $i++;
        }
    }
    $trader_id = implode(",", $trader_id);
    $commodity_id = implode(",", $commodity_id);
    $deal_type_id = implode(",", $deal_type_id);
    $counterparty_id = implode(",", $counterparty_id);

    $fixed_term_flag = ($data_set[0]['fixed_term'] ?? 0) == 1 ? 'true' : 'false';
    $relative_term_flag = ($data_set[0]['relative_term'] ?? 0) == 1 ? 'true' : 'false';
    $layout = new AdihaLayout();
    $form_object = new AdihaForm();
    
    $layout_name = 'layout_filter';
    $namespace = 'at_risk_filters';
    $form_name = 'filter_form';
    $layout_json = '[
            {
                id:       "a",
                header:   false,
                collapse: false,
                fix_size: [false,null]
            }
        ]';

    echo $layout->init_layout($layout_name, '', '1C', $layout_json, $namespace);
    
    $sp_url_trader = "EXEC spa_source_traders_maintain @flag = 'x'";
    $trader_dropdown = $form_object->adiha_form_dropdown($sp_url_trader, 0, 1, 'true', '', 2);

    $sp_url_counterparty = "EXEC spa_source_counterparty_maintain @flag = 'c', @is_active = 'y', @not_int_ext_flag = 'b'";
    $counterparty_dropdown = $form_object->adiha_form_dropdown($sp_url_counterparty, 0, 1, 'true', '', 2);

    $sp_url_commodity = "EXEC spa_source_commodity_maintain @flag = 'b'";
    $commodity_dropdown = $form_object->adiha_form_dropdown($sp_url_commodity, 0, 1, 'true', '', 2);

    $sp_url_deal_type = "Exec spa_source_deal_type_maintain @flag='x', @sub_type='n'";
    $deal_type_dropdown = $form_object->adiha_form_dropdown($sp_url_deal_type, 0, 1, 'true', '', 2);

    $sp_url_book_id = "EXEC spa_maintain_portfolio_group @flag = 'c'";
    $book_id_dropdown = $form_object->adiha_form_dropdown($sp_url_book_id, 0, 1, 'true');

    $form_struct = "[";
    if ($component_portfolio_group == 'true') {
        $form_struct .= "{type:'combo', label:'Portfolio Group', options: " . $book_id_dropdown . ", name:'portfolio_group_id', width:" . $ui_settings['field_size'] . ", labelWidth: 'auto', position: 'label-top', offsetLeft: 20, filtering: true, validate: 'ValidNumeric', userdata:{'validation_message':'Invalid Selection'}},";  
    }
                  
     $form_struct .= "{type: 'fieldset', name: 'filter', label: 'Book Filters', offsetLeft: 10, list:[
                        {type: 'block', list:[
                            {type: 'combo', name: 'trader', width: " . $ui_settings['field_size'] . ", label: 'Trader', options: " . $trader_dropdown . ", position: 'label-top', comboType: 'custom_checkbox', offsetLeft: " . $ui_settings['offset_left'] . "},
                            {type: 'newcolumn'},
                            {type: 'combo', name: 'commodity_id', width: " . $ui_settings['field_size'] . ", label: 'Commodity', options: " . $commodity_dropdown . ", position: 'label-top', comboType: 'custom_checkbox', offsetLeft: " . $ui_settings['offset_left'] . "},
                            {type: 'newcolumn'},
                            {type: 'combo', name: 'deal_type_id', label: 'Deal Type', width: " . $ui_settings['field_size'] . ", options: " . $deal_type_dropdown . ", position: 'label-top', comboType: 'custom_checkbox', offsetLeft: " . $ui_settings['offset_left'] . "},
                            {type: 'newcolumn'},
                            {type: 'combo', name: 'counterparty_id', width: " . $ui_settings['field_size'] . ", label: 'Counterparty', options: " . $counterparty_dropdown . ", position: 'label-top', comboType: 'custom_checkbox', offsetLeft: " . $ui_settings['offset_left'] . "},
                            {type: 'newcolumn'},
                        ]}";
    $form_struct .= "]}";

    if ($component_tenor == 'true') {
        $form_struct .= ", {type: 'fieldset', name: 'tenor', label: 'Tenor', blockOffset: 0, offsetLeft:10, list:[
                            {type: 'block', list:[
                                {type: 'checkbox', name: 'fixed_term', label: 'Fixed Term', position:'label-right', value:'1', offsetLeft: " . $ui_settings['offset_left'] . ", offsetTop:30, labelWidth:" . $ui_settings['field_size'] . ", checked: $fixed_term_flag},
                                {type: 'newcolumn'},
                                {type: 'calendar', name: 'term_start', width: " . $ui_settings['field_size'] . ", label: 'Term Start', position:'label-top', offsetLeft: " . $ui_settings['offset_left'] . "},
                                {type: 'newcolumn'},
                                {type: 'calendar', name: 'term_end', width: " . $ui_settings['field_size'] . ", label: 'Term End', position:'label-top', offsetLeft: " . $ui_settings['offset_left'] . "},
                                {type: 'newcolumn'},
                            ]},
                            {type: 'block', list:[
                                {type: 'checkbox', name: 'relative_term', label: 'Relative Term', position:'label-right', value:'1', offsetTop:30, offsetLeft: " . $ui_settings['offset_left'] . ", labelWidth:" . $ui_settings['field_size'] . ", checked: $relative_term_flag},
                                {type: 'newcolumn'},
                                {type: 'input', name: 'starting_month', width: " . $ui_settings['field_size'] . ", label: 'Start Month', position:'label-top', offsetLeft: " . $ui_settings['offset_left'] . ",validate:'ValidNumeric', userdata:{'validation_message':'Invalid Number'}},
                                {type: 'newcolumn'},
                                {type: 'input', name: 'no_of_month', width: " . $ui_settings['field_size'] . ", label: 'No of Months', position:'label-top', offsetLeft: " . $ui_settings['offset_left'] . ", validate:'ValidNumeric', userdata:{'validation_message':'Invalid Number'}},
                                {type: 'newcolumn'},
                            ]}
                        ]}";
    }

    $form_struct .= "]";

    echo $form_object->init_by_attach($form_name, $namespace);
    echo $form_object->attach_form($layout_name, 'a'); 
    echo $form_object->load_form($form_struct);
    echo $form_object->attach_event('', 'onChange', 'at_risk_filters.filter_form_event');
    echo $layout->close_layout();
?>
</body>
<script type="text/javascript">
    var trader_id = "<?php echo $trader_id;?>";
    var commodity_id = "<?php echo $commodity_id;?>";
    var deal_type_id = "<?php echo $deal_type_id;?>";
    var counterparty_id = "<?php echo $counterparty_id;?>";

    var relative_term_flag = <?php echo $relative_term_flag;?>;
    var fixed_term_flag = <?php echo $fixed_term_flag;?>;
    var term_start = "<?php echo isset($data_set[0]['term_start']) ? $data_set[0]['term_start'] : '';?>";
    var term_end = "<?php echo isset($data_set[0]['term_end']) ? $data_set[0]['term_end'] : '';?>";
    var starting_month = "<?php echo isset($data_set[0]['starting_month']) ? $data_set[0]['starting_month'] : '';?>";
    var no_of_month = "<?php echo isset($data_set[0]['no_of_month']) ? $data_set[0]['no_of_month'] : '';?>";
    var portfolio_group_id = "<?php echo isset($data_set[0]['portfolio_group_id']) ? $data_set[0]['portfolio_group_id'] : '';?>";
    var component_portfolio_group = Boolean(<?php echo $component_portfolio_group; ?>);
    var component_tenor = Boolean(<?php echo $component_tenor; ?>);
    
    $(function() {
        var trader_obj = at_risk_filters.filter_form.getCombo('trader');
        //trader_obj.deleteOption('');
        trader_obj.enableFilteringMode(true);

        trader_obj.attachEvent("onClose", function() {
            fx_set_combo_text(trader_obj);
        });

        var commodity_obj = at_risk_filters.filter_form.getCombo('commodity_id');
        //commodity_obj.deleteOption('');
        commodity_obj.enableFilteringMode(true);

        commodity_obj.attachEvent("onClose", function() {
            fx_set_combo_text(commodity_obj);
        });

        var deal_type_obj = at_risk_filters.filter_form.getCombo('deal_type_id');
        //deal_type_obj.deleteOption('');
        deal_type_obj.enableFilteringMode(true);

        deal_type_obj.attachEvent("onClose", function() {
            fx_set_combo_text(deal_type_obj);
        });

        var counterparty_obj = at_risk_filters.filter_form.getCombo('counterparty_id');
        //counterparty_obj.deleteOption('');
        counterparty_obj.enableFilteringMode(true);
        
        counterparty_obj.attachEvent("onClose", function() {
            fx_set_combo_text(counterparty_obj);
        });
        
        load_portfolio_book_filters();
    });
    /**
     *
     */
    at_risk_filters.filter_form_event = function() {
        var fixed_term = at_risk_filters.filter_form.isItemChecked('fixed_term');
        if(fixed_term == true){
            at_risk_filters.filter_form.enableItem('term_start');
            at_risk_filters.filter_form.enableItem('term_end');
        } else {
            at_risk_filters.filter_form.disableItem('term_start');
            at_risk_filters.filter_form.disableItem('term_end');

            at_risk_filters.filter_form.setItemValue('term_start', '');
            at_risk_filters.filter_form.setItemValue('term_end', '');
        }

        var relative_term = at_risk_filters.filter_form.isItemChecked('relative_term');
        if(relative_term == true){
            at_risk_filters.filter_form.enableItem('starting_month');
            at_risk_filters.filter_form.enableItem('no_of_month');
        } else {
            at_risk_filters.filter_form.disableItem('starting_month');
            at_risk_filters.filter_form.disableItem('no_of_month');

            at_risk_filters.filter_form.setItemValue('starting_month', '');
            at_risk_filters.filter_form.setItemValue('no_of_month', '');
        }
    }
    /**
     *
     */
    function get_form() {
        return at_risk_filters.filter_form;
    }
    /**
     *
     */
    function load_portfolio_book_filters(){
        var form_obj = at_risk_filters.filter_form;
        //setTimeout is to ensure form load complete
        setTimeout(function() {
            $(function() {
                //trader_id
                var combo_trader = form_obj.getCombo('trader');
                var trader_id_array = [];
                if(trader_id.indexOf(",") != -1) {
                    trader_id_array = trader_id.split(',');
                } else {
                    trader_id_array[0] = trader_id;
                }
                
                for (var j = 0, len = trader_id_array.length; j < len; j++) {
                    combo_trader.setChecked(combo_trader.getIndexByValue(trader_id_array[j]), true);
                }
                fx_set_combo_text(combo_trader);

                //commodity_id
                var combo_commodity_id = form_obj.getCombo('commodity_id');
                var commodity_id_array = [];
                if(trader_id.indexOf(",") != -1) {
                    commodity_id_array = commodity_id.split(',');
                } else {
                    commodity_id_array[0] = commodity_id;
                }
                
                for (var j = 0, len = commodity_id_array.length; j < len; j++) {
                    combo_commodity_id.setChecked(combo_commodity_id.getIndexByValue(commodity_id_array[j]), true);
                }
                fx_set_combo_text(combo_commodity_id);

                //deal_type_id
                var combo_deal_type_id = form_obj.getCombo('deal_type_id');
                var deal_type_id_array = [];
                if(trader_id.indexOf(",") != -1) {
                    deal_type_id_array = deal_type_id.split(',');
                } else {
                    deal_type_id_array[0] = deal_type_id;
                }
                
                for (var j = 0, len = deal_type_id_array.length; j < len; j++) {
                    combo_deal_type_id.setChecked(combo_deal_type_id.getIndexByValue(deal_type_id_array[j]), true);
                }
                fx_set_combo_text(combo_deal_type_id);

                //counterparty_id
                var combo_counterparty_id = form_obj.getCombo('counterparty_id');
                var counterparty_id_array = [];
                if(counterparty_id.indexOf(",") != -1) {
                    counterparty_id_array = counterparty_id.split(',');
                } else {
                    counterparty_id_array[0] = counterparty_id;
                }
                
                for (var j = 0, len = counterparty_id_array.length; j < len; j++) {
                    combo_counterparty_id.setChecked(combo_counterparty_id.getIndexByValue(counterparty_id_array[j]), true);
                }                
                fx_set_combo_text(combo_counterparty_id);
    
                if (component_tenor) {                   
                    if (relative_term_flag) {
                        form_obj.checkItem('relative_term');
                        form_obj.showItem('starting_month');
                        form_obj.showItem('no_of_month');
                    } else {
                        form_obj.disableItem('starting_month');
                        form_obj.disableItem('no_of_month');
            
                        form_obj.setItemValue('starting_month', '');
                        form_obj.setItemValue('no_of_month', '');
                    }
                    if (fixed_term_flag) {
                        form_obj.checkItem('fixed_term');
                        form_obj.showItem('term_start');
                        form_obj.showItem('term_end');
                    } else {
                        form_obj.disableItem('term_start');
                        form_obj.disableItem('term_end');
            
                        form_obj.setItemValue('term_start', '');
                        form_obj.setItemValue('term_end', '');
                    }
                
                    form_obj.setItemValue('term_start', term_start);
                    form_obj.setItemValue('term_end', term_end);
                    form_obj.setItemValue('starting_month', starting_month);
                    form_obj.setItemValue('no_of_month', no_of_month);
                }
                
                if (component_portfolio_group) {
                    var combo_portfolio_group = form_obj.getCombo('portfolio_group_id');
                    var idx = combo_portfolio_group.getIndexByValue(portfolio_group_id);
                    combo_portfolio_group.selectOption(idx);
                }
                
                
                
            });
        }, 100);
    }
    /**
     *
     */
    function fx_set_combo_text(cmb_obj) {
        var checked_loc_arr = cmb_obj.getChecked();
        var final_combo_text = new Array();        
        
        $.each(checked_loc_arr, function(i) {
            var opt_obj = cmb_obj.getOption(checked_loc_arr[i]);
            
            if (opt_obj.text != '')
                final_combo_text.push(opt_obj.text);            
        });
        
        cmb_obj.setComboText(final_combo_text.join(','));  
    }
</script>
