<?php
/**
* Calculate volatility correlation screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
        <?php require('../../../adiha.php.scripts/components/include.file.v3.php');?>
    </head>

    <body>
        <?php
            $rights_volatility_correlation_iu = 10181400;
            $volatility_source_id = 10639;
            $name_space = 'volatility_correlation';
            
            list (
                $has_rights_volatility_correlation_iu
            ) = build_security_rights(
                $rights_volatility_correlation_iu
            );

            $run_button_state = empty($has_rights_volatility_correlation_iu) ? 'true' : 'false';
            
            //Creating Layout
            $layout = new AdihaLayout();
            $layout_name = 'layout_volatility_correlation';
            $layout_json = '[{id: "a"}]';
            echo $layout->init_layout($layout_name, '', '1C', $layout_json, $name_space);
            
            //Attaching Toolbar 
            $toolbar_obj = new AdihaToolbar();
            $toolbar_name = 'toolbar_volatility_correlation';
            
            $toolbar_json = '[
                {id:"run", type:"button", img:"run.gif", imgdis:"run_dis.gif", text:"Run", title:"Run", disabled:' . $run_button_state . '}
            ]';
            
            echo $layout->attach_toolbar_cell($toolbar_name, 'a');
            echo $toolbar_obj->init_by_attach($toolbar_name, $name_space);
            echo $toolbar_obj->load_toolbar($toolbar_json);
            echo $toolbar_obj->attach_event('', 'onClick', 'volatility_correlation.run_volatility_calculation');

            //Attaching tabs
            $tab_name = 'tab_volatility_correlation';
            
            $tab_json = '[
                {id: "a1", text: "General", active:  true, enabled: true},
                {id: "a2", text: "At Risk Criteria", active: false}
            ]';

            echo $layout->attach_tab_cell($tab_name, 'a', $tab_json);
            
            $form_name = 'general_form';
            
            $calculate_data = "[
                {text: 'Volatility', value: 'v'},
                {text: 'Correlation', value: 'c'},
                {text: 'Expected Return', value: 'd'},
                {text: 'All', value: 'a'}
            ]";
            
            $form = new AdihaForm();
            $sp_url_curve_source = "EXEC spa_staticdatavalues @flag='h', @type_id=10007";
            $curve_source = $form->adiha_form_dropdown($sp_url_curve_source, 0, 1, false, '', 2);
            
            $sp_url_index_from = "EXEC spa_source_price_curve_def_maintain @flag = 'l',  @source_system_id = 2, @show_only_monte_carlo_model = 'y'";
            $index_from = $form->adiha_form_dropdown($sp_url_index_from, 0, 1, false, '', 2);

            $form_structure = "[
                {type:'settings'},
                {type: 'block', blockOffset: " . $ui_settings['block_offset'] . ", list: [
                    {type:'calendar', label:'As of Date', name:'as_of_date', width:" . $ui_settings['field_size'].", position: 'label-top', labelWidth: 'auto', offsetLeft: ".$ui_settings['offset_left'].", required: true, validate:'NotEmpty', userdata:{validation_message:'Required Field'}, dateFormat: '" . $date_format . "'},
                    {type:'newcolumn'},
                    {type:'combo', label:'Calculate', name:'calculate', width:" . $ui_settings['field_size'] . ", position: 'label-top', labelWidth: 'auto', required: true, options:$calculate_data, offsetLeft: " . $ui_settings['offset_left'] . ", userdata:{'validation_message':'Invalid Selection'}, filtering: true},
                    {type:'newcolumn'},
                    {type:'calendar', label:'Term From', name:'term_from', width:" . $ui_settings['field_size'] . ", position: 'label-top', labelWidth: 'auto', offsetLeft: " . $ui_settings['offset_left'] . ", validate:'', userdata:{validation_message:'Invalid Date'}, dateFormat: '" . $date_format . "'},
                    {type:'newcolumn'},
                    {type:'calendar', label:'Term To', name:'term_to', width:" . $ui_settings['field_size'] . ", position: 'label-top', labelWidth: 'auto', offsetLeft: " . $ui_settings['offset_left'] . ", validate:'', userdata:{validation_message:'Invalid Date'}, dateFormat: '" . $date_format . "'},
                    {type:'newcolumn'},
                    {type:'combo', label:'Curve Source', name:'curve_source', width:" . $ui_settings['field_size'] . ", position: 'label-top', labelWidth: 'auto', required: true, offsetLeft: " . $ui_settings['offset_left'] . ", options:$curve_source, validate:'NotEmpty', userdata:{'validation_message':'Invalid Selection'}, filtering: true},
                    {type:'newcolumn'},
                    {type:'combo', label:'Commodity From', name:'comodity_from', width:" . $ui_settings['field_size'] . ", position: 'label-top', labelWidth: 'auto', offsetLeft: " . $ui_settings['offset_left'] . ", userdata:{'validation_message':'Invalid Selection'}},
                    {type:'newcolumn'},
                    {type:'combo','comboType':'custom_checkbox', label:'Index From', name:'index_from', width:" . $ui_settings['field_size'] . ", position: 'label-top', labelWidth: 'auto', offsetLeft: " . $ui_settings['offset_left'] . ", required: true, options: $index_from, userdata:{'validation_message':'Invalid Selection'}},
                    {type:'newcolumn'},
                    {type:'combo', label:'Commodity To', name:'comodity_to', width:" . $ui_settings['field_size'] . ", position: 'label-top', labelWidth: 'auto', offsetLeft: " . $ui_settings['offset_left'] . ", userdata:{'validation_message':'Invalid Selection'}},
                    {type:'newcolumn'},
                    {type:'combo','comboType':'custom_checkbox', label:'Index To', name:'index_to', width:" . $ui_settings['field_size'] . ", position: 'label-top', labelWidth: 'auto', offsetLeft:  " . $ui_settings['offset_left'] . ", filteringMode: true, options:$index_from, userdata:{'validation_message':'Invalid Selection'}},
                ]},
                {type: 'block', blockOffset: " . $ui_settings['block_offset'] . ", list: [
                    {type:'checkbox', name: 'calc_correlation_same_terms', label: 'Calculate Correlation for same terms only', hidden:true, position: 'label-right', labelWidth:" . $ui_settings['field_size'] . ", offsetTop:" . $ui_settings['checkbox_offset_top'] . "}
                ]}
            ]";
            
            $tab = new AdihaTab();
            echo $tab->init_by_attach($tab_name, $name_space);
            echo $tab->attach_form($form_name, 'a1', $form_structure);
            echo $tab->set_tab_mode('bottom');
            
            //Attach Layout in second tab
            $at_risk_layout = 'at_risk_layout';
            echo $tab->attach_layout($at_risk_layout, 'a2', '2E');
            
            $at_risk_form = 'at_risk_form';
            
            $at_risk_filter = "[
                {type: 'block', blockOffset: " . $ui_settings['block_offset'].", list: [
                    {type:'calendar', label:'As of Date', name:'as_of_date_at_risk', width:" . $ui_settings['field_size'].", position: 'label-top', labelWidth: 'auto', required: true, offsetLeft: " . $ui_settings['offset_left'].", validate:'NotEmpty', userdata:{validation_message:'Required Field'}, dateFormat: '" . $date_format . "'},
                    {type:'newcolumn'},
                    {type:'combo', label:'Calculate', name:'calculate_at_risk', width:" . $ui_settings['field_size'].", position: 'label-top', labelWidth: 'auto', required: true, offsetLeft: " . $ui_settings['offset_left'].", options: $calculate_data, filteringMode: true, validate:'NotEmpty', userdata:{'validation_message':'Invalid Selection'}},
                    {type:'newcolumn'},
                    {type:'checkbox', name: 'calc_correlation_same_terms_at_risk', hidden:true, label: 'Calculate Correlation for same terms only', position: 'label-right', offsetTop:" . $ui_settings['checkbox_offset_top'].", offsetLeft: " . $ui_settings['offset_left']."}
                ]}
            ]";
            
            echo $tab->attach_form_layout_cell($at_risk_form, 'a', $at_risk_layout, $at_risk_filter);
            
            //Attaching grid
            $grid_name = 'at_risk_grid';
            echo $layout->attach_grid_custom_layout($grid_name, 'b', $name_space . '.' . $at_risk_layout);
            $tbl_grd_name = 'at_risk_criteria_detail';
            $grid_sql = "EXEC spa_var_measurement_criteria_detail @flag='x'";
            
            $grid_table = new GridTable($tbl_grd_name);
            echo $grid_table->init_grid_table($grid_name, $name_space);
            echo $grid_table->set_search_filter(true, '');
            echo $grid_table->set_widths('150,150,150,150,150,150,150,150,150,150,150');
            echo $grid_table->load_grid_data($grid_sql); 
            echo $grid_table->load_grid_functions();
            echo $grid_table->return_init();    
            
            echo $layout->close_layout();
        ?>

        <script type="text/javascript">
            var form_obj;
            var volatility_source_id = <?php echo $volatility_source_id;?>;
            var daily_return_data_series = 'NULL';
            var data_points = 'NULL';
            var calc_only_vol_cor = 'y';

            $(function(){
                volatility_correlation.at_risk_layout.cells("a").setHeight(130);
                volatility_correlation.at_risk_layout.cells("a").setText('Filter');
                volatility_correlation.at_risk_layout.cells("b").setText('At Risk Criteria');

                form_obj = volatility_correlation.general_form;
                form_obj.setItemValue('as_of_date', new Date());
                var form_obj_at_risk = volatility_correlation.at_risk_form;
                form_obj_at_risk.setItemValue('as_of_date_at_risk', new Date());

                //filtering mode enable
                var combo_comodity_from = form_obj.getCombo('comodity_from');
                combo_comodity_from.enableFilteringMode("between", null, false);
                var combo_index_from = form_obj.getCombo('index_from');
                combo_index_from.enableFilteringMode("between", null, false);
                var combo_comodity_to = form_obj.getCombo('comodity_to');
                combo_comodity_to.enableFilteringMode("between", null, false);
                var combo_index_to = form_obj.getCombo('index_to');
                combo_index_to.enableFilteringMode("between", null, false);
                //end of filtering mode

                var combo_curve_source = form_obj.getCombo('curve_source');
                combo_curve_source.enableFilteringMode(true);
                combo_curve_source.selectOption(1); 

                form_obj.hideItem('index_to');
                form_obj.hideItem('comodity_to');
                form_obj.hideItem('calc_correlation_same_terms');

                var combo_calculate = form_obj.getCombo('calculate');
                combo_calculate.enableFilteringMode("between", null, false);

                combo_calculate.attachEvent("onChange", function(value, text) {
                    switch (value) {
                        case 'v':
                            form_obj.setRequired('index_to',false);
                            form_obj.hideItem('index_to');
                            form_obj.hideItem('comodity_to');
                            form_obj.hideItem('calc_correlation_same_terms');
                            break;
                        case 'c':
                            form_obj.setRequired('index_to',true);
                            form_obj.showItem('index_to');
                            form_obj.showItem('comodity_to');
                            form_obj.showItem('calc_correlation_same_terms');
                            break;
                        case 'd':
                            form_obj.setRequired('index_to',false);
                            form_obj.hideItem('index_to');
                            form_obj.hideItem('comodity_to');
                            form_obj.hideItem('calc_correlation_same_terms');
                            break;
                        case 'a':
                            form_obj.setRequired('index_to',true);
                            form_obj.showItem('index_to');
                            form_obj.showItem('comodity_to');
                            form_obj.showItem('calc_correlation_same_terms');
                            break;
                        default:
                            form_obj.setRequired('index_to',false);
                            form_obj.hideItem('index_to');
                            form_obj.hideItem('comodity_to');
                            form_obj.hideItem('calc_correlation_same_terms');
                            break;
                    }
                });
                
                var combo_comodity_from = form_obj.getCombo('comodity_from');
                
                var comodity_from_data = {
                    "action": "spa_source_commodity_maintain", 
                    "flag": "a"
                };
                
                load_combo(combo_comodity_from, comodity_from_data, true);
                
                var combo_comodity_to = form_obj.getCombo('comodity_to');
                
                var comodity_to_data = {
                    "action": "spa_source_commodity_maintain", "flag": "a"
                };
                
                load_combo(combo_comodity_to, comodity_to_data, true);
                
                var combo_index_from = form_obj.getCombo('index_from');

                combo_comodity_from.attachEvent("onChange", function(value) {
                    combo_index_from.setComboValue(null);
                    combo_index_from.setComboText(null);
                    combo_index_from.clearAll();

                    var index_from_data = {
                        "action": "spa_source_price_curve_def_maintain", 
                        "flag": "l", 
                        "source_system_id": 2, 
                        "commodity_id": value, 
                        "show_only_monte_carlo_model": 'y'
                    };
                    
                    load_combo(combo_index_from, index_from_data, false, 'combo_index_from');
                });

                var combo_index_to = form_obj.getCombo('index_to');

                combo_comodity_to.attachEvent("onChange", function(value) {
                    combo_index_to.setComboValue(null);
                    combo_index_to.setComboText(null);
                    combo_index_to.clearAll();
                    
                    var index_to_data = {
                        "action": "spa_source_price_curve_def_maintain", 
                        "flag": "l", 
                        "source_system_id": 2, 
                        "commodity_id": value, 
                        "show_only_monte_carlo_model": 'y'
                    };
                    
                    load_combo(combo_index_to, index_to_data, false, 'combo_index_to');

                });

                combo_index_to.deleteOption('');
                
                var form_obj_at_risk = volatility_correlation.at_risk_form;
                var combo_calculate_at_risk =  form_obj_at_risk.getCombo('calculate_at_risk');  
                combo_calculate_at_risk.enableFilteringMode("between", null, false);

                combo_calculate_at_risk.attachEvent("onChange", function(value, text) {
                    switch (value) {
                        case 'v':
                            form_obj_at_risk.hideItem('calc_correlation_same_terms_at_risk');
                            break;
                        case 'c':
                            form_obj_at_risk.showItem('calc_correlation_same_terms_at_risk');
                            break;
                        case 'd':
                            form_obj_at_risk.hideItem('calc_correlation_same_terms_at_risk');
                            break;
                        case 'a':
                            form_obj_at_risk.showItem('calc_correlation_same_terms_at_risk');
                            break;
                        default:
                            form_obj_at_risk.hideItem('calc_correlation_same_terms_at_risk');
                            break;
                    }
                });
            });
            
            volatility_correlation.run_volatility_calculation = function(id) {
                var var_criteria_id;
                var active_tab = volatility_correlation.tab_volatility_correlation.getActiveTab();
                var title = 'Calculate Volatility, Correlation and Expected Return';
                var param = '';

                switch(active_tab){
                    case 'a1':
                        var general_form_validation = validate_form(form_obj);
                        
                        if (general_form_validation == false) {
                            return false;
                        }
                        
                        if (form_obj.getItemValue('index_from') == 0) {
                            show_messagebox("<b>Index From</b> cannot be blank.");
                            return false;
                        }

                        var calculate = form_obj.getItemValue('calculate');
                        var as_of_date = form_obj.getItemValue('as_of_date', true);
                        var curve_source = form_obj.getItemValue('curve_source');
                        var term_from = form_obj.getItemValue('term_from', true);
                        var term_to = form_obj.getItemValue('term_to', true);
                        var comodity_from = form_obj.getItemValue('comodity_from');
                        var comodity_to = form_obj.getItemValue('comodity_to');
                        var index_from_obj = form_obj.getCombo('index_from');
                        var index_from = index_from_obj.getChecked();
                        index_from = index_from.toString();
                        var index_to_obj = form_obj.getCombo('index_to');
                        var index_to = index_to_obj.getChecked();
                        index_to = index_to.toString();

                        as_of_date  = (as_of_date && as_of_date != '' && as_of_date != null) ? dates.convert_to_sql(as_of_date) : as_of_date;
                        term_from  = (term_from && term_from != '' && term_from != null) ? dates.convert_to_sql(term_from) : term_from;
                        term_to  = (term_to && term_to != '' && term_to != null) ? dates.convert_to_sql(term_to) : term_to;

                        if (!as_of_date) {
                            
                            show_messagebox("<b>As of Date</b> cannot be blank.");
                            return false;
                        }

                        if (calculate == 'c' && index_to == '0') {
                            show_messagebox("<b>Index To</b> cannot be blank.")
                            return false;
                        }

                        if ((calculate == 'c' || calculate == 'e') && index_to == '0') {
                            show_messagebox("<b>Index To</b> cannot be blank.")
                            return false;
                        }

                        var d1 = Date.parse(term_from);
                        var d2 = Date.parse(term_to);
                        
                        if (d1 > d2) {
                            dhtmlx.message({
                                title: "Alert", 
                                type: "alert", 
                                text: "<b>Term To</b> should be greater than <b>Term From</b>."
                            });
                            
                            return false;
                        }
                        
                        var calc_correlation_same_terms = 'n';

                        if (form_obj.isItemChecked('calc_correlation_same_terms')) {
                            calc_correlation_same_terms = 'y';
                        }

                        param = 'call_from=volatility_correlation&gen_as_of_date=1&batch_type=c&as_of_date=' + as_of_date;
                        
                        var exec_call_general = 'EXEC spa_calc_vol_cor_job ' +
                            singleQuote(as_of_date) + ', ' +
                            curve_source + 
                            ', NULL, NULL,' +
                            singleQuote(index_from) + ', ' +
                            singleQuote(term_from) + ', ' +
                            singleQuote(term_to) + ', ' +
                            daily_return_data_series + ', ' +
                            data_points + ', ' +
                            singleQuote('n') + ', ' +
                            singleQuote(calc_only_vol_cor) + ', ' +
                            singleQuote(calculate) + ', ' +
                            singleQuote(index_to) +
                            ',NULL, NULL, NULL, NULL, NULL, NULL,' + 
                            volatility_source_id + ', ' +
                            singleQuote(calc_correlation_same_terms);

                        adiha_run_batch_process(exec_call_general, param, title);
                        
                        break;
                    case 'a2':
                        var run_at_risk_form_obj = volatility_correlation.at_risk_form;
                        var run_at_risk_form_validation = validate_form(run_at_risk_form_obj);
                        
                        if (run_at_risk_form_validation == false) {
                            return false;
                        }

                        var as_of_date_at_risk = run_at_risk_form_obj.getItemValue('as_of_date_at_risk', true);
                        as_of_date_at_risk = dates.convert_to_sql(as_of_date_at_risk);
                        var calculate_at_risk = run_at_risk_form_obj.getItemValue('calculate_at_risk');
                        var selected_row_id = volatility_correlation.at_risk_grid.getSelectedRowId();
                        
                        if (selected_row_id) {
                            var_criteria_id = volatility_correlation.at_risk_grid.cells(selected_row_id, 0).getValue();
                        } else {
                            show_messagebox("Please select the <b>At Risk Criteria</b>.")
                            return;
                        }

                        var calc_correlation_same_terms_at_risk = 'n';

                        if (run_at_risk_form_obj.isItemChecked('calc_correlation_same_terms_at_risk')) {
                            calc_correlation_same_terms_at_risk = 'y';
                        }

                        param = 'call_from=volatility_correlation&gen_as_of_date=1&batch_type=c&as_of_date=' + as_of_date_at_risk;
                        
                        var exec_call_as_of_date = 'EXEC spa_calc_vol_cor_job ' +
                            singleQuote(as_of_date_at_risk) + ', NULL, ' +
                            var_criteria_id + ', NULL, NULL, NULL, NULL, ' +
                            daily_return_data_series + ', ' +
                            data_points + ', ' +
                            singleQuote('n') + ', ' +
                            singleQuote(calc_only_vol_cor) + ', ' +
                            singleQuote(calculate_at_risk) + ', ' +
                            'NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, ' +
                            singleQuote(calc_correlation_same_terms_at_risk);

                        adiha_run_batch_process(exec_call_as_of_date, param, title);
                        break;
                    default:
                        //do nothing
                        break;
                }
            }

            /**
            * Load option value pairs from combo sql string
            */
            function load_combo(combo_obj, combo_sql, has_blank_option, call_from) {
                var data = $.param(combo_sql);
                var url = js_dropdown_connector_url + '&' + data + '&has_blank_option=' + has_blank_option;
                
                combo_obj.load(url, function() {
                    if (call_from == 'combo_index_from' || call_from == 'combo_index_to') {
                        combo_obj.setComboValue(combo_obj.getOptionByIndex(0).value);
                    }
                });
            }

            /**
            * Load static option value pairs to combo object
            */
            function load_combo_static_option(combo_obj, combo_data) {
                combo_obj.load({
                    data: combo_data
                });
            }
        </script>
    </body>
</html>