<?php
/**
* Flow optimization screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
<body class = "bfix2">
    <?php     
    $php_script_loc = $app_php_script_loc;
    $app_user_loc = $app_user_name;
    $form_function_id = 10163600;
    $rights_flow_optimization_run_optimizer = 10163601;
    $rights_flow_optimization_save_schedule = 10163602;
    $rights_flow_optimization_view_schedule = 10163400; //function id of view nomination schedule menu
    $rights_flow_optimization_book_out = 10163603;
    $right_flow_optimization_back_to_back = 10163612;
    
    list (
        $has_right_flow_optimization_run_optimizer,
        $has_right_flow_optimization_save_schedule,
        $has_right_flow_optimization_view_schedule,
        $has_right_flow_optimization_book_out,
        $has_right_flow_optimization_back_to_back
    ) = build_security_rights (
        $rights_flow_optimization_run_optimizer, 
        $rights_flow_optimization_save_schedule,
        $rights_flow_optimization_view_schedule,
        $rights_flow_optimization_book_out,
        $right_flow_optimization_back_to_back
    );
    
    $form_namespace = 'flow_optimization';
    $json = "[
        {
            id:         'a',
            text:       'Portfolio Hierarchy',
            header:     true,
            collapse:   true,
            width:      300
        },
        {
            id:         'b',
            text:       'Filters',
            header:     true,
            collapse:   true,
            height:     80
        },
        {
            id:         'c',
            text:       'Filter Criteria',
            header:     true,
            collapse:   false,
            height:     250
        },
        {
            id:         'd',
            text:       'Optimization Grid',
            header:     true,
            collapse:   false
        }

    ]";
          
    $flow_optimization_obj = new AdihaLayout();
    echo $flow_optimization_obj->init_layout('layout', '', '4C', $json, $form_namespace);

    $tree_name = 'tree_book';
    echo $flow_optimization_obj->attach_tree_cell($tree_name, 'a');
    $book_tree_obj = new AdihaBookStructure($form_function_id);
    echo $book_tree_obj->init_by_attach($tree_name, $form_namespace);
    echo $book_tree_obj->set_portfolio_option(0);
    echo $book_tree_obj->load_book_structure_data();
    echo $book_tree_obj->enable_three_state_checkbox();
    echo $book_tree_obj->attach_search_filter('flow_optimization.layout', 'a'); 
    echo $book_tree_obj->expand_tree('x_1');

    $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='$form_function_id', @template_name='flow optimization', @group_name = 'General'";
    $return_value1 = readXMLURL2($xml_file);
    $form_json = $return_value1[0]['form_json'];
    $tab_id = $return_value1[0]['tab_id'];
    echo $flow_optimization_obj->attach_form('flow_optimization_form', 'c', $form_json, $return_value1[0]['dependent_combo']);
	
	echo '
	dhxCombo_granularity = flow_optimization.flow_optimization_form.getCombo("granularity");
	dhxCombo_granularity.attachEvent("onClose", flow_optimization.cmb_granularity_onclose);

	dhxCombo_period_from = flow_optimization.flow_optimization_form.getCombo("period_from");
	dhxCombo_period_from.attachEvent("onClose", flow_optimization.cmb_period_from_onclose);
	';
          
    $menu_json = '[
        {id: "refresh", text: "Refresh", img: "refresh.gif", img_disabled: "refresh_dis.gif", enabled: true},
        {id: "run_optimizer", text: "Run Optimizer", img: "run.gif", img_disabled: "run_dis.gif", enabled: ' . (int) $has_right_flow_optimization_run_optimizer . '},
        {id: "save_schedule", text: "Save Schedule", img: "save.gif", img_disabled: "save_dis.gif", enabled: ' . (int) $has_right_flow_optimization_save_schedule . '},
        {id: "book_out", text: "Book Out", img: "run.gif", img_disabled: "run_dis.gif", enabled: ' . (int) $has_right_flow_optimization_book_out . '},
        
        {id: "back_to_back", text: "Back to Back", img: "back_to_back.png", img_disabled: "back_to_back_dis.png", enabled: ' . (int) $has_right_flow_optimization_back_to_back . '},
        {id: "match", text: "Match", img: "match.png", img_disabled: "match_dis.png", enabled: true},
        {id: "view_schedule", text: "View Schedule", img: "run_view_schedule.gif", img_disabled: "run_view_schedule_dis.gif", enabled: ' . (int) $has_right_flow_optimization_view_schedule . '},
        {id: "view_pipeline_capacity", text: "View Pipeline Capacity", img: "send_schedule_qty.gif", img_disabled: "send_schedule_qty_dis.gif", enabled: true},
        {id: "hide_pos_zero", type: "checkbox", text: "Hide Position Zero", checked: true, enabled: true},
    ]';

    echo $flow_optimization_obj->attach_menu_layout_cell('flow_optimization_menu', 'd', $menu_json, $form_namespace.'.menu_click');
    echo $flow_optimization_obj->close_layout();
    ?>
</body>
<script>
    $(function(){
        filter_obj = flow_optimization.layout.cells('b').attachForm();
        var layout_cell_obj = flow_optimization.layout.cells('c');
        load_form_filter(filter_obj, layout_cell_obj, '10163600', 2,'','',flow_optimization.callback_flow_optimization);
        filter_obj.attachEvent("onBeforeChange",function(name,oldValue,newValue){
            if (name=='apply_filters' && oldValue != newValue) {
                if(newValue != -1) {   //default                 
                    flow_optimization.layout.cells('d').progressOn();
                }
            }
            return true;
        });

        //create js date obj and sotre next day date
        date_obj_tomorrow = new Date();
        date_obj_tomorrow.setDate(date_obj_tomorrow.getDate() + 1);
        
        fx_initial_load();

        // flow_optimization.flow_optimization_menu.hideItem('hide_pos_zero');
        fx_enable_disable_menu_items('disable', 'all');
    });
	//refresh period_from/period_to as values of granularity combo
    flow_optimization.cmb_granularity_onclose = function() {
        var granularity = dhxCombo_granularity.getSelectedValue();
		if(granularity == 981) { //daily
			flow_optimization.flow_optimization_form.disableItem('period_from');
            return;
		}else if(granularity == 982) { //hourly
			flow_optimization.flow_optimization_form.enableItem('period_from');
		}
        var cm_param = {
            "action": 'spa_flow_optimization',
            "has_blank_option": "true",
            "flag":'h',
            "granularity":granularity
        };
                                    
        cm_param = $.param(cm_param);
        var url = js_dropdown_connector_url + "&" + cm_param;
        var cm_data_pf = flow_optimization.flow_optimization_form.getCombo('period_from');
        cm_data_pf.clearAll();
        cm_data_pf.setComboText('');
        cm_data_pf.load(url, function(e) {
            
        });
       
        
    }
	flow_optimization.cmb_period_from_onclose = function() {
        //fx_set_combo_text_final(dhxCombo_period_from);
    }

    //function to load initial values
    function fx_initial_load() {
        dhxCombo_rg = flow_optimization.flow_optimization_form.getCombo("receipt_group");
        dhxCombo_rg.setChecked(dhxCombo_rg.getIndexByValue('-10'), true);

        dhxCombo_dg = flow_optimization.flow_optimization_form.getCombo("delivery_group");
        dhxCombo_dg.setChecked(dhxCombo_dg.getIndexByValue('-11'), true);

        dhxCombo_pp = flow_optimization.flow_optimization_form.getCombo("path_priority");
        option_pp_p2p = dhxCombo_pp.getOptionByLabel("Point-Point");
        dhxCombo_pp.selectOption(option_pp_p2p.index, false, true);

        dhxCombo_objv = flow_optimization.flow_optimization_form.getCombo("opt_objectives");
        option_objv_default = dhxCombo_objv.getOptionByLabel("Maximum Flow based on Location Ranking");
        dhxCombo_objv.selectOption(option_objv_default.index, false, true);
        
        flow_optimization.flow_optimization_form.setItemValue('flow_date_from', date_obj_tomorrow);   

		flow_optimization.cmb_granularity_onclose();		
    }

    flow_optimization.callback_flow_optimization = function () {
        flow_optimization.layout.cells('d').progressOff();
    }
        
    flow_optimization.menu_click = function(name, value) {
        var ifr_optimizer = flow_optimization.layout.cells('d').getFrame();
                
        if (name == 'refresh' || name == 'match') {
            //flow_optimization.flow_optimization_menu.setCheckboxState('hide_pos_zero', true);
            flow_optimization.flow_optimization_menu.setItemDisabled('refresh');
            refresh_flow_optimization(name);
        } else if (name == 'run_optimizer') {
            ifr_optimizer.contentWindow.fx_run_optimizer(); 
        } else if(name == 'hide_pos_zero') {
            ifr_optimizer.contentWindow.fx_hide_position_zero(flow_optimization.flow_optimization_menu.getCheckboxState(name));
        } else if (name == 'save_schedule') {
            ifr_optimizer.contentWindow.fx_save_schedule_pre();
        } else if (name == 'view_schedule') {
            ifr_optimizer.contentWindow.fx_view_schedules();
        } else if (name == 'view_pipeline_capacity') {
            ifr_optimizer.contentWindow.fx_view_pipeline_capacity();
        } else if (name == 'book_out') {
            ifr_optimizer.contentWindow.fx_book_out();
        } else if (name == 'back_to_back') {
            ifr_optimizer.contentWindow.fx_book_out('back_to_back');
        }  
    }
    
    refresh_flow_optimization = function(call_from) {
        var delivery_path = flow_optimization.flow_optimization_form.getItemValue('delivery_path');
       
        if(!validate_form(flow_optimization.flow_optimization_form)) {
            return;
        }
        
        flow_optimization.layout.cells('b').collapse();
        flow_optimization.layout.cells('c').setHeight(240);
        var flow_date_from = flow_optimization.flow_optimization_form.getItemValue('flow_date_from', true);
        var flow_date_to = flow_optimization.flow_optimization_form.getItemValue('flow_date_to', true);
        
        //set flow date to = flow date from when it is null
        if(flow_date_to == '' || flow_date_to == undefined) {
            flow_date_to = flow_date_from;
        }
        
        var priority_from = flow_optimization.flow_optimization_form.getItemValue('priority_from');
        var priority_to = flow_optimization.flow_optimization_form.getItemValue('priority_to');
        var path_priority = flow_optimization.flow_optimization_form.getItemValue('path_priority');
        var opt_objectives = flow_optimization.flow_optimization_form.getItemValue('opt_objectives');
        var receipt_group_obj = flow_optimization.flow_optimization_form.getCombo('receipt_group');
        var receipt_group = receipt_group_obj.getChecked();
        var uom = flow_optimization.flow_optimization_form.getItemValue('uom');
		var uom_name = flow_optimization.flow_optimization_form.getCombo('uom').getComboText();
        
        var receipt_location_name_obj = flow_optimization.flow_optimization_form.getCombo('receipt_location_name');
        var receipt_location_name = receipt_location_name_obj.getChecked();
        //console.log(receipt_location_name);
        
        var delivery_group_obj = flow_optimization.flow_optimization_form.getCombo('delivery_group');
        var delivery_group = delivery_group_obj.getChecked();
        
        var delivery_location_name_obj = flow_optimization.flow_optimization_form.getCombo('delivery_location_name');
        var delivery_location_name = delivery_location_name_obj.getChecked();
        //console.log(delivery_location_name);
        
        var pipeline_obj = flow_optimization.flow_optimization_form.getCombo('pipeline');
        var pipeline = pipeline_obj.getChecked();
        
        var contract_obj = flow_optimization.flow_optimization_form.getCombo('contract');
        var contract = contract_obj.getChecked();
        //console.log(contract);
        
        var subsidiary_id = flow_optimization.get_subsidiary();
        var strategy_id = flow_optimization.get_strategy();
        var book_id = flow_optimization.get_book();
        var sub_book_id = flow_optimization.get_subbook();

        var subsidiary_id_label = flow_optimization.get_subsidiary_label();
        var strategy_id_label = flow_optimization.get_strategy_label();
        var book_id_label = flow_optimization.get_book_label();
        var sub_book_id_label = flow_optimization.get_subbook_label();

        // console.log(subsidiary_id_label + '|' + strategy_id_label + '|' + book_id_label + '|' + sub_book_id_label);
        var book_structure_text = subsidiary_id_label + '|' + strategy_id_label + '|' + book_id_label + '|' + sub_book_id_label

        var hide_pos_zero = (flow_optimization.flow_optimization_form.isItemChecked('hide_pos_zero')?'y':'n');
        var reschedule = (flow_optimization.flow_optimization_form.isItemChecked('reschedule') ? 1 : 0);
		
		var granularity = flow_optimization.flow_optimization_form.getItemValue('granularity');
		var period_from_obj = flow_optimization.flow_optimization_form.getCombo('period_from');
        var period_from = period_from_obj.getChecked();

        //if blank pass all hours
        if(period_from == '') {
            //period_from = '7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,1,2,3,4,5,6';
            period_from = '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25';
        }
                
        var post_data = {
                            "flow_date_from":  flow_date_from == '' ? 'NULL' : flow_date_from,
                            "flow_date_to":  flow_date_to == '' ? 'NULL' : flow_date_to,
                            "priority_from": priority_from == '' ? 'NULL' : priority_from,
                            "priority_to": priority_to == '' ? 'NULL' : priority_to,
                            "path_priority": path_priority == '' ? 'NULL' : path_priority, 
                            "opt_objectives": opt_objectives == '' ? 'NULL' : opt_objectives, 
                            "receipt_group": receipt_group == '' ? 'NULL' : receipt_group, 
                            "receipt_location_name": receipt_location_name == '' ? 'NULL' : receipt_location_name, 
                            "delivery_group": delivery_group == '' ? 'NULL' : delivery_group, 
                            "delivery_location_name": delivery_location_name == '' ? 'NULL' : delivery_location_name, 
                            "pipeline": pipeline == '' ? 'NULL' : pipeline, 
                            "contract": contract == '' ? 'NULL' : contract,
                            "subsidiary_id": subsidiary_id == '' ? 'NULL' : subsidiary_id,
                            "strategy_id": strategy_id == '' ? 'NULL' : strategy_id,
                            "book_id": book_id == '' ? 'NULL' : book_id,
                            "sub_book_id": sub_book_id == '' ? 'NULL' : sub_book_id,
                            "uom": uom == '' ? 'NULL' : uom,
							"uom_name": uom_name == '' ? 'NULL' : uom_name,
                            "delivery_path": delivery_path == '' ? 'NULL' : delivery_path,
                            "call_from": call_from,
                            "hide_pos_zero": hide_pos_zero,
                            "reschedule": reschedule,
                            "book_structure_text" : encodeURIComponent(book_structure_text),
							"granularity" : granularity,
							"period_from" : period_from
                        }
        
        var url = '<?php echo $app_adiha_loc; ?>' + 'adiha.html.forms/_scheduling_delivery/gas/flow_optimization/flow.optimization.template.php';
        
        flow_optimization.layout.cells('d').attachURL(url, null, post_data);
    }
    
    //function to open position drill from optimization grid
    var position_window;
    function fx_position_report(std_report_url) {
        open_spa_html_window('Optimizer Position Detail', std_report_url, 600, 1200);
    }
    
    var flow_deal_match_window = new dhtmlXWindows();

    flow_optimization.fx_close_window = function(window_id) {
        flow_deal_match_window.window(window_id).close();
    }

    function fx_enable_disable_menu_items(enable_disable, menu_item) {
        if (enable_disable == 'enable' && menu_item == 'all') {
            flow_optimization.flow_optimization_menu.setItemEnabled('run_optimizer');
            flow_optimization.flow_optimization_menu.setItemEnabled('save_schedule');
            flow_optimization.flow_optimization_menu.setItemEnabled('book_out');
            flow_optimization.flow_optimization_menu.setItemEnabled('back_to_back');
            flow_optimization.flow_optimization_menu.setItemEnabled('view_schedule');
            flow_optimization.flow_optimization_menu.setItemEnabled('view_pipeline_capacity');
        } else if (enable_disable == 'disable' && menu_item == 'all') {
            flow_optimization.flow_optimization_menu.setItemDisabled('run_optimizer');
            flow_optimization.flow_optimization_menu.setItemDisabled('save_schedule');
            flow_optimization.flow_optimization_menu.setItemDisabled('book_out');
            flow_optimization.flow_optimization_menu.setItemDisabled('back_to_back');
            flow_optimization.flow_optimization_menu.setItemDisabled('view_schedule');
            flow_optimization.flow_optimization_menu.setItemDisabled('view_pipeline_capacity');
            
        }
    }
</script>