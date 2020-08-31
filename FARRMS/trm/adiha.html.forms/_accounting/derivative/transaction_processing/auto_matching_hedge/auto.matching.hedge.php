<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
</head>
    <?php
    include '../../../../../adiha.php.scripts/components/include.file.v3.php';
    $form_cell_json = '[
            {
                id:             "a",
                text:           "Portfolio Hierarchy",
                width:          300,
                height:         500,
                collapse:       false
            },
            {
                id:             "b",
                header:         false,
                height:         50,
                collapse:       false
            },
            {
                id:             "c",
                text:           "Apply Filters",
                height:         270,
                collapse:       false
            },
            {
                id:             "d",
                collapse:       false,
               
                text:           "<a class=\"undock-btn undock_custom\" style=\"float: right; cursor:pointer\" title=\"Undock\"  onClick=\" undock_window();\"></a>View Proposed Match" 
            }
        ]';
     
    $rights_auto_matching_hegde = 10234400; 
    $rights_run_auto_match = 10234410;
    $rights_run_auto_add = 10234412;
    $rights_run_auto_unprocess = 10234413;
    
    list (
        $has_rights_auto_matching_hedge,
        $has_rights_run_auto_match,
        $has_rights_run_add,
        $has_rights_run_unprocess
    ) = build_security_rights (
        $rights_auto_matching_hegde,
        $rights_run_auto_match,
        $rights_run_auto_add,
        $rights_run_auto_unprocess
    ); 
    
    $form_layout = new AdihaLayout();
    $layout_name = 'layout_auto_matching_hedge';
    $form_name_space = 'form_auto_matching_hedge';
    echo $form_layout->init_layout($layout_name, '', '4C', $form_cell_json, $form_name_space);
    //Attaching tree in CELL A
    $tree_structure = new AdihaBookStructure($rights_auto_matching_hegde);
    $tree_name = 'tree_auto_matching_hedge';
    echo $form_layout->attach_tree_cell($tree_name, 'a');
    echo $tree_structure->init_by_attach($tree_name, $form_name_space);
    echo $tree_structure->set_portfolio_option(2);
    echo $tree_structure->set_subsidiary_option(2);
    echo $tree_structure->set_strategy_option(2);
    echo $tree_structure->set_book_option(2);
    echo $tree_structure->set_subbook_option(0);
    echo $tree_structure->load_book_structure_data();
    echo $tree_structure->load_bookstructure_events();
    echo $tree_structure->expand_level('all');
    echo $tree_structure->enable_three_state_checkbox();
    echo $tree_structure->load_tree_functons();    
    echo $tree_structure->attach_search_filter('form_auto_matching_hedge.layout_auto_matching_hedge', 'a');  
    //Attaching Toolbar in Layout CELL B
    $toolbar_json = '[
                    { id: "matchtransaction", type: "button", img: "match_transaction.gif", imgdis: "match_transaction_dis.gif", text: "Match Transaction", title: "Match Transaction"}
                 ]';

    echo $form_layout->attach_toolbar_cell('auto_matching_hedge_toolbar', 'b');
    $auto_matching_hedge_toolbar = new AdihaToolbar();
    echo $auto_matching_hedge_toolbar->init_by_attach('auto_matching_hedge_toolbar', $form_name_space);
    echo $auto_matching_hedge_toolbar->load_toolbar($toolbar_json);
    echo $auto_matching_hedge_toolbar->attach_event('', 'onClick', 'btn_match_transaction_click');
     
    $dt_as_of_date_from = date('Y-m-d', strtotime('-1 month'));
    $dt_as_of_date_to = date('Y-m-d');        
  
    $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10234400', @template_name='AutomateMatchingOfHedges', @group_name='General'";
    $return_value1 = readXMLURL($xml_file);
    $form_structure_filter = $return_value1[0][2];
    
    //report filter json
    $form_obj = new AdihaForm();
    $sp_url_index = "EXEC spa_source_price_curve_def_maintain @flag=l, @source_system_id=2";
    $index_dropdown = $form_obj->adiha_form_dropdown($sp_url_index, 0, 1, true, '', 2);
    $buy_sell_dropdown = '[{text:"Both",value:"a"},{text:"Buy", value:"b"},{text:"Sell",value:"s"}]';
    $der_item_dropdown = '[{text:"Both",value:"b"},{text:"Der", value:"h"},{text:"Item",value:"i"}]';
    
    $report_filter_form_structure = "[
                                {'type':'settings','position':'label-top','offsetLeft':".$ui_settings['offset_left'].",'labelWidth':'auto','inputWidth':".$ui_settings['field_size']."},
                                {'type':'combo','name':'cmb_index','label':'Index','tooltip':'Index',required:false,'validate':'ValidInteger','hidden':'false','disabled':'false','offsetLeft':".$ui_settings['offset_left'].",'labelWidth':'auto','inputWidth':".$ui_settings['field_size'].",'filtering':'true','options':$index_dropdown},
                                {'type':'newcolumn'},
                                {'type':'combo','name':'cmb_buy_sell','label':'Buy/Sell','tooltip':'Buy/Sell',required:false,'hidden':'false','disabled':'false','offsetLeft':".$ui_settings['offset_left'].",'labelWidth':'auto','inputWidth':".$ui_settings['field_size'].",'filtering':'true','options':$buy_sell_dropdown},
                                {'type':'newcolumn'},
                                {'type':'combo','name':'cmb_der_item','label':'Der/Item','tooltip':'Der/Item',required:false,'hidden':'false','disabled':'false','offsetLeft':".$ui_settings['offset_left'].",'labelWidth':'auto','inputWidth':".$ui_settings['field_size'].",'filtering':'true','options':$der_item_dropdown}
                            ]";  
    
    echo $form_layout->close_layout(); 
?>
<script type="text/javascript">
    var user_name = '<?php echo $app_user_name; ?>';
    var dhx_unprocess_unmatch;
    var win_unprocess_unmatch,win_log_report;
    var log_report_window;
    var has_rights_run_auto_match = Boolean('<?php echo $has_rights_run_auto_match; ?>');
    var has_rights_run_add = Boolean('<?php echo $has_rights_run_add; ?>');
    var has_rights_run_unprocess = Boolean('<?php echo $has_rights_run_unprocess; ?>');
    var rights_run_auto_match = (has_rights_run_auto_match == true ? 0 : 1);
    var check_window_in_dock_mode = 'n';

    //Attaching Form Objects
    $(function() {
        if (has_rights_run_auto_match) {
            form_auto_matching_hedge.auto_matching_hedge_toolbar.enableItem('matchtransaction');
        } else {
            form_auto_matching_hedge.auto_matching_hedge_toolbar.disableItem('matchtransaction');
        }
        var function_id =  '<?php echo $rights_auto_matching_hegde; ?>';
        var as_of_date_from = '<?php echo $dt_as_of_date_from; ?>';
        var as_of_date_to = '<?php echo $dt_as_of_date_to; ?>';
        
        form_auto_matching_hedge.layout_auto_matching_hedge.cells("b").setHeight(2);
        //Attaching layout in Filter
        var filters_layout = form_auto_matching_hedge.layout_auto_matching_hedge.cells('c').attachLayout({
                                pattern: '2E',
                                cells: [ {id:'a', header:'true', text:'Apply Filters', height:100, collapse:true},
                                        {id:'b', header:'true', text:'Criteria', collapse:false}
                                        ] 
                            });
        
        //Attching Filter form in cell B of filters_layout
        var general_form_filter = <?php echo $form_structure_filter; ?>;
        filter_form = filters_layout.cells('b').attachForm(general_form_filter);

        //Attaching Filter in cell A of filters_layout
        var filter_obj = filters_layout.cells('a').attachForm();
        var layout_cell_obj = filters_layout.cells('b');
        load_form_filter(filter_obj, layout_cell_obj, function_id, 2, '', form_auto_matching_hedge);  
        
        set_default_value(); //set 'dt_as_of_date_from' from setup menu 'Setup As of Date'
        filter_form.setItemValue('dt_as_of_date_to', as_of_date_to);
        filter_form.disableItem('cmb_tenor_bucket');
        filter_form.attachEvent('onChange', function(name, value) {
            if (name == 'chk_apply_limit') {
                var apply_limit = filter_form.isItemChecked('chk_apply_limit');   
                        
                if (apply_limit == false) {
                    filter_form.disableItem('cmb_tenor_bucket');
                } else {
                    filter_form.enableItem('cmb_tenor_bucket');
                }                  
            }
            
            if (name == 'chk_ext_match') {
                var ext_match = filter_form.isItemChecked('chk_ext_match');
                var matching_type = filter_form.getItemValue('cmb_matching_type');   
                        
                if (ext_match == false) {
                    if (matching_type == 'a') {                        
                        if (has_rights_run_unprocess) {
                            form_auto_matching_hedge.toolbar_proposed_match.setItemEnabled('unprocess');
                        } else {
                            form_auto_matching_hedge.toolbar_proposed_match.setItemDisabled('unprocess');
                        }

                        if (has_rights_run_add) {
                            form_auto_matching_hedge.toolbar_proposed_match.setItemEnabled('hedge');
                        } else {
                            form_auto_matching_hedge.toolbar_proposed_match.setItemDisabled('hedge');
                        }
                        
                        form_auto_matching_hedge.toolbar_proposed_match.setItemEnabled('logreport');
                        form_auto_matching_hedge.toolbar_proposed_match.setItemEnabled('refresh');
                        form_auto_matching_hedge.toolbar_proposed_match.setItemEnabled('batch');
                        form_auto_matching_hedge.toolbar_proposed_match.setItemEnabled('excel');
                        form_auto_matching_hedge.toolbar_proposed_match.setItemEnabled('pdf');                    
                    } else {
                        form_auto_matching_hedge.toolbar_proposed_match.setItemDisabled('refresh');
                        form_auto_matching_hedge.toolbar_proposed_match.setItemDisabled('unprocess');
                        form_auto_matching_hedge.toolbar_proposed_match.setItemDisabled('hedge');
                        form_auto_matching_hedge.toolbar_proposed_match.setItemDisabled('logreport');
                        form_auto_matching_hedge.toolbar_proposed_match.setItemDisabled('batch');
                        form_auto_matching_hedge.toolbar_proposed_match.setItemDisabled('excel');
                        form_auto_matching_hedge.toolbar_proposed_match.setItemDisabled('pdf'); 
                    }                    
                } else {
                    form_auto_matching_hedge.toolbar_proposed_match.setItemDisabled('refresh');
                    form_auto_matching_hedge.toolbar_proposed_match.setItemDisabled('unprocess');
                    form_auto_matching_hedge.toolbar_proposed_match.setItemDisabled('hedge');
                    form_auto_matching_hedge.toolbar_proposed_match.setItemDisabled('logreport');
                    form_auto_matching_hedge.toolbar_proposed_match.setItemDisabled('batch');
                    form_auto_matching_hedge.toolbar_proposed_match.setItemDisabled('excel');
                    form_auto_matching_hedge.toolbar_proposed_match.setItemDisabled('pdf');
                }                  
            }
            
            if (name == 'cmb_matching_type') {
                var matching_type = filter_form.getItemValue('cmb_matching_type');
                var ext_match = filter_form.isItemChecked('chk_ext_match');   
                        
                if (ext_match == false) {        
                    if (matching_type == 'a') {
                        if (has_rights_run_unprocess) {
                            form_auto_matching_hedge.toolbar_proposed_match.setItemEnabled('unprocess');
                        } else {
                            form_auto_matching_hedge.toolbar_proposed_match.setItemDisabled('unprocess');
                        }

                        if (has_rights_run_add) {
                            form_auto_matching_hedge.toolbar_proposed_match.setItemEnabled('hedge');
                        } else {
                            form_auto_matching_hedge.toolbar_proposed_match.setItemDisabled('hedge');
                        }
                        
                        form_auto_matching_hedge.toolbar_proposed_match.setItemEnabled('logreport');
                        form_auto_matching_hedge.toolbar_proposed_match.setItemEnabled('refresh');
                        form_auto_matching_hedge.toolbar_proposed_match.setItemEnabled('batch');
                        form_auto_matching_hedge.toolbar_proposed_match.setItemEnabled('excel');
                        form_auto_matching_hedge.toolbar_proposed_match.setItemEnabled('pdf');                    
                    } else {
                        form_auto_matching_hedge.toolbar_proposed_match.setItemDisabled('refresh');
                        form_auto_matching_hedge.toolbar_proposed_match.setItemDisabled('unprocess');
                        form_auto_matching_hedge.toolbar_proposed_match.setItemDisabled('hedge');
                        form_auto_matching_hedge.toolbar_proposed_match.setItemDisabled('logreport');
                        form_auto_matching_hedge.toolbar_proposed_match.setItemDisabled('batch');
                        form_auto_matching_hedge.toolbar_proposed_match.setItemDisabled('excel');
                        form_auto_matching_hedge.toolbar_proposed_match.setItemDisabled('pdf'); 
                    }
                }                  
            }   
        });
        
        //Attaching layout for report and Filters
        report_filters_layout = form_auto_matching_hedge.layout_auto_matching_hedge.cells('d').attachLayout({
                                pattern: '2E',
                                cells: [ {id:'a', header:'false', height:60, collapse:false},
                                        {id:'b', header:'false', collapse:false}
                                        ] 
                            });
                            
        var report_filter_form_structure = <?php echo $report_filter_form_structure; ?>;
        report_filters_form = report_filters_layout.cells('a').attachForm(report_filter_form_structure);
        form_auto_matching_hedge.toolbar_proposed_match = report_filters_layout.cells('b').attachMenu({
                            icons_path: js_image_path + "dhxmenu_web/"
                        });
        form_auto_matching_hedge.toolbar_proposed_match.loadStruct([{id:"refresh", img:"refresh.gif", imgdis:"refresh_dis.gif", text:"Refresh", title:"Refresh"},                                
                        {id:"t2", text:"Export", img:"export.gif", items:[
                            {id:"batch", img:"batch.gif", text:"Batch", imgdis:"batch_dis.gif", title:"Batch"},
                            {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                            {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                        ]},
                        {id:"t3", text:"Process", img:"process.gif", items:[
                            {id:"unprocess", img: "unprocess.gif", imgdis:"unprocess_dis.gif",  text: "Unprocess/Unmatch", title: "Unprocess/Unmatch", enabled: has_rights_run_unprocess},
                            {id:"hedge", text:"Create Hedge Relationship", img:"create_hedging_relationship.gif", imgdis:"create_hedging_relationship_dis.gif", title: "Create Hedge Relationship", enabled: has_rights_run_add}
                        ]},
                        {id:"t4", text:"Reports", img:"report.gif", items:[
                            {id:"logreport", text:"View Unprocess/Unmatch Log Report", img:"view_unprocess_unmatch_log_report.gif", imgdis:"view_unprocess_unmatch_log_report_dis.gif", title: "View Unprocess/Unmatch Log Report", disabled: 0}
                        ]}
                    ]);
        form_auto_matching_hedge.toolbar_proposed_match.attachEvent('onClick', refresh_export_toolbar_click);
        form_auto_matching_hedge.layout_auto_matching_hedge.cells('d').showHeader(); 
        form_auto_matching_hedge.layout_auto_matching_hedge.attachEvent("onDock", function(name) {
            $('.undock-btn').show();
            check_window_in_dock_mode = 'n';
        });
        form_auto_matching_hedge.layout_auto_matching_hedge.attachEvent("onUnDock", function(name) {$('.undock-btn').hide();});       
    });   
    // END of Attaching Form Objects
    
    //Function to enable menu item
    function enable_menu_items() {
        if (has_rights_run_unprocess) {
            form_auto_matching_hedge.toolbar_proposed_match.setItemEnabled('unprocess');
        }

        if (has_rights_run_add) {
            form_auto_matching_hedge.toolbar_proposed_match.setItemEnabled('hedge');
        }
        //form_auto_matching_hedge.toolbar_proposed_match.setItemEnabled('logreport');                    
    }
    
    //Function to disable menu item
    function disable_menu_items() {
        form_auto_matching_hedge.toolbar_proposed_match.setItemDisabled('unprocess');
        form_auto_matching_hedge.toolbar_proposed_match.setItemDisabled('hedge');
        //form_auto_matching_hedge.toolbar_proposed_match.setItemDisabled('logreport');
    }
    
    //Get Message function
    function get_message(message_code) {
        switch (message_code) {
            case 'SUB_VALIDATE':
                return 'Please select atleast one Book';
            case 'VALIDATE_DATE':
                return "'As of Date To' must be greater than 'As of Date From'.";
            case 'RECORD_VALIDATE':
                return 'Please select a single record to unprocess or two records to unmatch.';
            case 'DEAL_TYPE_VALIDATE':
                return 'Deal Type should be different.';
            case 'DER_ITEM_VALIDATE':
                return 'Different deal types(Der/Item) should be selected for designation. Please select different deal type.';
        }
    }
    
    //Function for Match Transaction click
    function btn_match_transaction_click() {
        var param = get_parameters('match_transaction');
        if (param == 'hold') return;
        var as_of_date_to = filter_form.getItemValue('dt_as_of_date_to', true);
		var arg = 'call_from=Automate Matching of Hedges&gen_as_of_date=1&batch_type=c&as_of_date=' + as_of_date_to;
        var title = 'Automate Hedge Matching';       
        adiha_run_batch_process(param, arg, title);
    }
    //End of match transaction
    
    //Get Parameter for Match Transcation, Batch and Reports
    function get_parameters(type) {
		var sub_entity_id = form_auto_matching_hedge.get_subsidiary('browser');
        var strategy_entity_id = form_auto_matching_hedge.get_strategy('browser');
        var book_entity_id = form_auto_matching_hedge.get_book('browser');
        
	    var as_of_date_from = filter_form.getItemValue('dt_as_of_date_from', true);
	    var as_of_date_to = filter_form.getItemValue('dt_as_of_date_to', true);
        
	    var fifo_lifo = filter_form.getItemValue('cmb_match_type');       
	    var match_approach = filter_form.getItemValue('cmb_match_approach');
	    var curve_id = report_filters_form.getItemValue('cmb_index');
        curve_id = (curve_id == '') ? 'NULL' : curve_id;
        var der_item = report_filters_form.getItemValue('cmb_der_item');
	    var buy_sell = report_filters_form.getItemValue('cmb_buy_sell');  
	    var match_type = filter_form.getItemValue('cmb_match_type');
	    var slice_option = filter_form.getItemValue('cmb_no_deals');
        var matching_type = filter_form.getItemValue('cmb_matching_type');
        var deal_date = filter_form.getItemValue('cmb_deal_date');
        var limit_bucketing = filter_form.getItemValue('cmb_tenor_bucket');
        limit_bucketing = (limit_bucketing == '') ? 'NULL' : limit_bucketing;
        var dice_exposure = (filter_form.isItemChecked('chk_dice_exp') == true) ? 'y' : 'n';        
	    var include_extenal = (filter_form.isItemChecked('chk_ext_derivatives') == true) ? 'y' : 'n';
	    var externalization_match = (filter_form.isItemChecked('chk_ext_match') == true) ? 'y' : 'n';
        var apply_limit = (filter_form.isItemChecked('chk_apply_limit') == true) ? 'y' : 'n';
        var param;
        var process_id = filter_form.getItemValue('txt_process_id');
        
        var form_validate = validate_form(filter_form);
        if (form_validate == 0) return;
        
	    if (book_entity_id == '' && sub_entity_id == '' && strategy_entity_id == '') {
            var text_message = get_message('SUB_VALIDATE');
            show_messagebox(text_message);
			param = 'hold';
            return param;
	    }
		 
	    if ((as_of_date_from != 'NULL' && as_of_date_to != 'NULL') && (as_of_date_from > as_of_date_to)) {
	       var text_message = get_message('VALIDATE_DATE');
	       show_messagebox(text_message);
           param = 'hold';
	       return param;
	    }

        if (type == 'match_transaction') {
            if (matching_type == 'a') {
                 param = 'EXEC spa_auto_matching_job ' + singleQuote(sub_entity_id) + ', ' + singleQuote(strategy_entity_id)  
                          + ', ' + singleQuote(book_entity_id) + ', ' + singleQuote(as_of_date_from) + ', ' + singleQuote(as_of_date_to)
                          + ', ' + singleQuote(fifo_lifo) + ', ' + singleQuote(match_approach) + ', ' + singleQuote(dice_exposure)
                          + ', ' + curve_id + ', ' + singleQuote(der_item) + ', ' + singleQuote(buy_sell) + ", 'n'" 
                          + ', ' + singleQuote(slice_option) + ', ' + singleQuote(user_name) + ', ' + singleQuote(include_extenal)
                          + ', ' + singleQuote(externalization_match) + ', NULL, NULL' + ', ' + singleQuote(deal_date)
                          + ', ' + singleQuote(apply_limit) + ', ' + singleQuote(limit_bucketing);
            } else {
                var book_structure = (sub_entity_id != 'NULL' || sub_entity_id != '') ? sub_entity_id : '';
                
                if (book_entity_id != 'NULL' || book_entity_id != '') {
                    if (book_structure != 'NULL' || book_structure != '') {
                         book_structure +=  ', ' + book_entity_id;
                    }
                }
                 
                if (strategy_entity_id != 'NULL' || strategy_entity_id != '') {
                    if (book_structure != 'NULL' || book_structure != '') {
                         book_structure +=  ', ' + strategy_entity_id;
                    }
                }
                
                param = 'EXEC spa_automation_forecasted_transaction ' + singleQuote(book_structure) + ', ' + singleQuote(as_of_date_to)         
                         + ', NULL, NULL, ' + singleQuote(matching_type);
            }           
        } else if (type == 'refresh') {
            param = { "action": "spa_auto_matching_job", 
                     "sub_id": sub_entity_id, 
                     "str_id": strategy_entity_id,
                     "book_id": book_entity_id,
                     "as_of_date_from": as_of_date_from,
                     "as_of_date_to": as_of_date_to,
                     "FIFO_LIFO": fifo_lifo,
                     "slicing_first": match_approach,
                     "perform_dicing": dice_exposure,
                     "v_curve_id": curve_id,
                     "h_or_i": der_item,
                     "v_buy_sell": buy_sell,
                     "call_for_report": "y",
                     "slice_option": slice_option,
                     "only_include_external_der": include_extenal,
                     "externalization": externalization_match,
                     "apply_limit": apply_limit,
                     "limit_bucketing": limit_bucketing,
                     "deal_dt_option":deal_date
                    }
	    } else if (type == 'after_refresh') {
	           param = 'EXEC spa_auto_matching_report ' + singleQuote(process_id) + ', '
                            + singleQuote(curve_id) + ', '
                            + singleQuote(der_item) + ', '
                            + singleQuote(buy_sell) + ', '
                            + singleQuote(user_name); 
                           //+ "," + singleQuote(ref_id);
                           
        } else if (type == 'rerun_link') {  
            param = { "action": "spa_auto_matching_job", 
                     "sub_id": sub_entity_id, 
                     "str_id": strategy_entity_id,
                     "book_id": book_entity_id,
                     "as_of_date_from": as_of_date_from,
                     "as_of_date_to": as_of_date_to,
                     "FIFO_LIFO": fifo_lifo,
                     "v_curve_id": curve_id,
                     "h_or_i": der_item,
                     "v_buy_sell": buy_sell,
                     "call_for_report": 'y',
                     "slice_option": slice_option,
                     "only_include_external_der": include_extenal,
                     "externalization": externalization_match,
                     "deal_dt_option":deal_date
                    }; 
        } else {
		    param = singleQuote(sub_entity_id) 
		    		+ ', ' + singleQuote(strategy_entity_id) 
		    		+ ', ' + singleQuote(book_entity_id) 
		    		+ ', ' + singleQuote(as_of_date_from) 
		    		+ ', ' + singleQuote(as_of_date_to)
		    		+ ', ' + singleQuote(fifo_lifo) 
		    		+ ', ' + singleQuote(match_approach) 
		    		+ ', ' + singleQuote(dice_exposure) 
		    		+ ', ' + curve_id 
		    		+ ', ' + singleQuote(match_type) 
		    		+ ', ' + singleQuote(buy_sell) 
		    		+ ', \'y\''
		    		+ ', ' + singleQuote(slice_option)
		    		+ ', ' + singleQuote(user_name) 
		    		+ ', ' + singleQuote(include_extenal) 
		    		+ ', ' + singleQuote(externalization_match)
                    + ', ' + singleQuote(apply_limit)
                    + ', ' + singleQuote(limit_bucketing);
	    }
        return param;
	}
    //End of Get Parameter for Match Transcation, Batch and Reports
    
    function get_selected_rows() {
        var match_report = report_filters_layout.cells('b').getFrame();
        var selected_rows = match_report.contentWindow.selected_rows();
        return selected_rows;
    }
    
    //Toolbar click function
    function refresh_export_toolbar_click(args) {
        var process_id = filter_form.getItemValue('txt_process_id');
        var curve_id = filter_form.getItemValue('cmb_index');
        //curve_id = (curve_id == '') ? 'NULL' : curve_id;
        var der_item = filter_form.getItemValue('cmb_der_item');
	    var buy_sell = filter_form.getItemValue('cmb_buy_sell'); 
        var selected_row_id;
                
        switch(args) {
            case 'refresh':
                disable_menu_items();
                report_filters_layout.cells('b').progressOn();
                var param = get_parameters('refresh');
                if (param == 'hold') return ;
                if (check_window_in_dock_mode != 'y') form_auto_matching_hedge.layout_auto_matching_hedge.cells('c').collapse();
                adiha_post_data('return_data', param, '', '', 'call_back_refresh_export_toolbar_click', '');
                break;
            case 'excel':
                var exec_call = get_parameters('after_refresh');
                var path = js_php_path + '/dev/spa_html.php?__user_name__=' + js_user_name + '&spa=' + exec_call + '&pop_up=true&writeCSV=true';
                open_window_with_post(path); 
                break;
            case 'pdf':
                var exec_call = get_parameters('after_refresh');
                var path = js_php_path + '/dev/spa_pdf.php?__user_name__=' + js_user_name + '&spa=' + exec_call + '&pop_up=true';
                open_window_with_post(path);
                break;
            case 'unprocess':
                selected_row_id = get_selected_rows();
                
                if (selected_row_id != '') {
                    var row_size = selected_row_id.split(',');
                }
                
                if (selected_row_id != '' && row_size.length > 2) {
                    var message = get_message('RECORD_VALIDATE');
                    show_messagebox(message);
                    return;
                }
                 
                if (row_size.length == 2) {
                   var match_report = report_filters_layout.cells('b').getFrame();
                   var check_deal_type = match_report.contentWindow.check_deal_type(selected_row_id);
                   
                   if (check_deal_type == false) {
                        var message = get_message('DEAL_TYPE_VALIDATE');
                        show_messagebox(message);
                        return;
                    }
                }
                
                var row_id = selected_row_id;
                var param = 'unprocess.unmatch.php?&is_pop=true&process_id=' + process_id + '&row_id=' + row_id;
                var title_text = 'Unprocess/Unmatch'; 
                
        		dhx_unprocess_unmatch = new dhtmlXWindows();
                win_unprocess_unmatch = dhx_unprocess_unmatch.createWindow("w1", 5, 5, 500, 410);
        		win_unprocess_unmatch.centerOnScreen();
        		win_unprocess_unmatch.setText(title_text);
        		win_unprocess_unmatch.attachURL(param, false, true);
                win_unprocess_unmatch.attachEvent('onClose', function() {
                    rerun_link_creation();
                    return true; 
                });
                break;
            case 'batch':
                var param = get_parameters('b');
                if (param == 'hold') return ;
        		var exec_call = 'EXEC spa_auto_matching_batch ' + param;
                //var as_of_date_from = filter_form.getItemValue('dt_as_of_date_from', true);
                var as_of_date_to = filter_form.getItemValue('dt_as_of_date_to', true);
                var arg = 'call_from=Automate Matching of Hedges&gen_as_of_date=1&as_of_date=' + as_of_date_to;
                var title = 'Automate Matching of Hedges';       
                adiha_run_batch_process(exec_call, arg, title);   
                break;
            case 'hedge':
                selected_row_id = get_selected_rows();
                var sp_url_param = {'process_id': process_id,
                                    'IDs': selected_row_id,
                                    'operation': 'v',
                                    'action': 'spa_hedge_relationship'
                                    };
                adiha_post_data('return_data', sp_url_param, '', '', 'call_back_hedge_relationship', '');
                break;
            case 'logreport':
                //var param = 'process_id=' + process_id;
                var param = 'view.unprocess.unmatch.log.report.php?&is_pop=true';//&process_id=' + process_id;
                var title_text = 'View Unprocess/Unmatch Log Report'; 
                log_report_window = new dhtmlXWindows();
                win_log_report = log_report_window.createWindow("w2", 5, 5, 1100, 410);
        		win_log_report.centerOnScreen();
        		win_log_report.setText(title_text);
        		win_log_report.attachURL(param, false, true);
                win_log_report.attachEvent('onClose', function() {
                    rerun_link_creation();
                    return true;                    
                });
                break;    
        }
    	    
    }
    
    //Function to refresh the Report
    function report_refresh() {
        var exec_call = get_parameters('after_refresh');
        var sp_url = js_php_path + 'dev/spa_html.php?spa=' + escape(exec_call) + '&report_display=g&' + getAppUserName();
        report_filters_layout.cells('b').attachURL(sp_url, null);  
        report_filters_layout.attachEvent("onContentLoaded", function(id){
            report_filters_layout.cells('b').progressOff();
        });
    }
    
    //Unmatch/Unprocess function
    function call_back_hedge_relationship(result) {
        var process_id = filter_form.getItemValue('txt_process_id');
        var selected_row_id = get_selected_rows();
        var sp_url_param = {'process_id': process_id,
                            'IDs': selected_row_id,
                            'operation': 'p',
                            'action': 'spa_hedge_relationship'
                            };
                           
         //if validated, create relationship
        if (result[0].errorcode == 'Success' && result[0].recommendation == 0) {
            adiha_post_data('return_data', sp_url_param, '', '', 'create_hedge_rel', '');
        } else if (result[0].errorcode == 'Success' && result[0].recommendation == -1) {
            var message = get_message('DER_ITEM_VALIDATE');
            show_messagebox(message);
        } else {
            //if validation fails, ask for confirmation to create relationship
            dhtmlx.message({
            type: "confirm",
            title: "Confirmation",
            text: result[0].message,
            ok: "Confirm",
            callback: function(result) {
                         adiha_post_data('return_data', sp_url_param, '', '', 'create_hedge_rel', '')
                     }
            })
        }
    }
    
    function create_hedge_rel(result) {
        dhtmlx.alert({
            text: result[0].message
        });
        
        if (result[0].errorcode != 'Error') {
            var link_id = result[0].recommendation;
            //openLink_Id(link_id);                                 // what does this do?
            //rerun link creation process
            rerun_link_creation();
        }    
    }
    
    function rerun_link_creation() {                               
        var param = get_parameters('rerun_link');
        adiha_post_data('return_data', param, '', '', 'call_back_refresh_export_toolbar_click', '');
    }
    
    
    //Call back of Toolbar click
    function call_back_refresh_export_toolbar_click(return_value) {
        if (return_value[0].errorcode== 'Success') {
            filter_form.setItemValue('txt_process_id', return_value[0].recommendation);
        }
        
        disable_menu_items();        
        report_refresh();        
    }
       
    //Dock/Undock Cell D of the form
    function undock_window() {
        check_window_in_dock_mode = 'y';
        form_auto_matching_hedge.layout_auto_matching_hedge.cells('d').undock(300, 300, 900, 700);
        form_auto_matching_hedge.layout_auto_matching_hedge.dhxWins.window('d').maximize();
        form_auto_matching_hedge.layout_auto_matching_hedge.dhxWins.window('d').button("park").hide();
    }             

    function set_default_value() {        
        var sp_string =  "EXEC spa_as_of_date @flag = 'a', @screen_id = 10234400";
        var data_for_post = {"sp_string": sp_string};          
        var return_json = adiha_post_data('return_json', data_for_post, '', '', 'set_default_value_call_back');                  
    }

    function set_default_value_call_back(return_json) { 
        return_json = JSON.parse(return_json);
        as_of_date = return_json[0].as_of_date;
        no_of_days = return_json[0].no_of_days;
        var date = new Date();
        var custom_as_of_date;

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
        filter_form.setItemValue('dt_as_of_date_from', custom_as_of_date);
    }       
    }    

    function load_business_day(return_json) { 
        var return_json = JSON.parse(return_json);
        var business_day = return_json[0].business_day;             
        
        filter_form.setItemValue('dt_as_of_date_from', business_day);
    }   
</script>
</html>