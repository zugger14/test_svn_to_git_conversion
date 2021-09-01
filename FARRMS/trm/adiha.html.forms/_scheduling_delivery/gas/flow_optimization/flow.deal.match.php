<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <?php include '../../../../adiha.php.scripts/components/include.file.v3.php';?>
</head>
<?php
$php_script_loc = $app_php_script_loc;
$form_namespace = 'flow_match';
$form_name = 'filters';
$toolbar_flow_match_name = 'toolbar_flow_match';
$menu_flow_match_name = 'menu_flow_match';
$layout_name = 'flow_match_layout';
$inner_layout_name = 'flow_match_inner_layout';
$inner_layout_location_pool_name = 'flow_match_location_pool';
$receipt_grid_name = 'FlowReceipt';
$delivery_grid_name = 'FlowDelivery';
$storage_grid_name = 'FlowStorage';
$pool_grid_name = 'FlowPool';
$form_function_id =  10163610;

$call_from_ui =  get_sanitized_value($_REQUEST['call_from_ui'] ?? 'main_menu');
$call_from_bookout_label = 'book_out';

$layout_json = '[';
if ($call_from_ui != $call_from_bookout_label) {
    $layout_json .= '{id: "a", text: "Filter Criteria", header: true, collapse:false, height:145},';
    $receipt_delivery_cell_id = 'b';
} else {
    $receipt_delivery_cell_id = 'a';
}

$layout_json .= '{id: "' . $receipt_delivery_cell_id . '", text: "Receipt/Delivery", header: true}';

if ($call_from_ui != $call_from_bookout_label) {
    $layout_json .= ',{id: "c", text: "Storage/Pool", header: true}';
}
$layout_json .= ']';

$layout_json_ticket_match = '[
                        {id: "a", text: "Receipt", header: true, undock: true},  
                        {id: "b", text: "Deliveries", header: true, undock: true}
                    ]';
$layout_json_storage_pool = '[
                        {id: "a", text: "Storage/Imbalance", header: true, undock: true},
                        {id: "b", text: "Pool/Location", header: true, undock: true}
                    ]';
$menu_json = '[
                        
                {id: "refresh_all", text: "Refresh All", img: "refresh.gif", img_disabled: "refresh_dis.gif", enabled: true},
                {id:"match", text:"Match", img:"run.gif", imgdis:"run_dis.gif", title: "Match", enabled: true},
                {id:"multi_match", text:"Multi Match", img:"run.gif", imgdis:"run_dis.gif", title: "Multi Match", enabled: true},
                {id:"view_schedule", text:"View Schedule", img:"run_view_schedule.gif", imgdis:"run_view_schedule_dis.gif", title: "View Schedule", enabled: true},
            ';
if ($call_from_ui != $call_from_bookout_label) {
    $menu_json .= '{id:"t3", text:"Action", img:"action.gif", items:[
                        {id:"show_zero_vol", type: "checkbox", text: "Show Zero Volume", checked: false}
                    ]},
                ';
}
$menu_json .=   '{id:"report", text:"Report", img:"report.gif", imgdis:"report_dis.gif", title: "Report", enabled: true}    
                    ]';
$toolbar_receipt_json = '[
                            {id: "refresh_receipt", text:"Refresh", img: "refresh.gif", title:"Refresh"}
                        ]';
$toolbar_delivery_json = '[
                            {id: "refresh_delivery", text:"Refresh", img: "refresh.gif", title:"Refresh"}
                        ]';
$toolbar_storage_json = '[
                            {id: "refresh_storage", text:"Refresh", img: "refresh.gif", title:"Refresh"}
                        ]';
$toolbar_pool_json =  '[
                            {id: "refresh_pool", text:"Refresh", img: "refresh.gif", title:"Refresh"}
                        ]';

$process_id = get_sanitized_value($_REQUEST['process_id'] ?? '');
$flow_date_from = get_sanitized_value($_REQUEST['flow_date_from'] ?? '');
$flow_date_to = get_sanitized_value($_REQUEST['flow_date_to'] ?? '');
$box_id = get_sanitized_value($_GET['box_id'] ?? '');
$receipt_loc_id = get_sanitized_value($_GET['receipt_loc_id'] ?? '');
$delivery_loc_id = get_sanitized_value($_GET['delivery_loc_id'] ?? '');
$receipt_loc = get_sanitized_value($_GET['receipt_loc'] ?? '');
$delivery_loc = get_sanitized_value($_GET['delivery_loc'] ?? '');
$from_loc_grp_name = get_sanitized_value($_GET['from_loc_grp_name'] ?? '');
$to_loc_grp_name = get_sanitized_value($_GET['to_loc_grp_name'] ?? '');
$from_loc_grp_id = get_sanitized_value($_GET['from_loc_grp_id'] ?? '');
$to_loc_grp_id = get_sanitized_value($_GET['to_loc_grp_id'] ?? '');
$selected_path_id = get_sanitized_value($_GET['selected_path_id'] ?? '');
$selected_contract_id = get_sanitized_value($_GET['selected_contract_id'] ?? '');
$selected_storage_asset_id = get_sanitized_value($_GET['selected_storage_asset_id'] ?? '');
$selected_storage_checked = get_sanitized_value($_GET['selected_storage_checked'] ?? '');

$counterparty_id = get_sanitized_value($_GET['counterparty_id'] ?? '');
$pipeline = get_sanitized_value($_GET['pipeline'] ?? '');
$contract = get_sanitized_value($_GET['contract'] ?? '');
$subsidiary_id = get_sanitized_value($_GET['subsidiary_id'] ?? '');
$strategy_id = get_sanitized_value($_GET['strategy_id'] ?? '');
$book_id = get_sanitized_value($_GET['book_id'] ?? '');
$sub_book_id = get_sanitized_value($_GET['sub_book_id'] ?? '');
$book_structure_text = get_sanitized_value($_GET['book_structure_text'] ?? '');
$source_deal_header_id = get_sanitized_value($_GET['source_deal_header_id'] ?? 'NULL');
$uom = get_sanitized_value($_GET['uom'] ?? 'NULL');
$granularity = get_sanitized_value($_GET['granularity'] ?? '');

$layout_pattern = '3E';
//call from handling for book_out
$b2b = get_sanitized_value($_POST['b2b'] ?? 'false');
if ($call_from_ui == $call_from_bookout_label) {
    $location_id_call_from = $_POST['location_id'];
    $counterparty_id = get_sanitized_value($_POST['counterparty_id'] ?? '');
    $xml_file_call_from = "EXEC spa_source_minor_location @flag='z', @source_minor_location_id='$location_id_call_from'";
    $return_value_call_from = readXMLURL2($xml_file_call_from);
    $source_major_location_id = $return_value_call_from[0]['source_major_location_id'];
    $source_major_location = $return_value_call_from[0]['source_major_location'];
    $source_minor_location = $return_value_call_from[0]['source_minor_location'];

    $from_loc_grp_id = $source_major_location_id;
    $to_loc_grp_id = $source_major_location_id;
    $from_loc_grp_name = $source_major_location;
    $to_loc_grp_name = $source_major_location;

    $receipt_loc_id = $location_id_call_from;
    $delivery_loc_id = $location_id_call_from;
    $receipt_loc = $source_minor_location;
    $delivery_loc = $source_minor_location;

    $layout_pattern = '1C';
}  

$layout_obj = new AdihaLayout();
$inner_layout_obj = new AdihaLayout();
$form_obj = new AdihaForm();
$menu_match_obj = new AdihaMenu();
$menu_ticket_obj = new AdihaMenu();
$context_menu = new AdihaMenu();
$toolbar_obj = new AdihaMenu();
$tab_obj = new AdihaTab();
$inner_layout_location_pool_obj = new AdihaLayout();
$toolbar_receipt_obj = new AdihaMenu();
$toolbar_delivery_obj = new AdihaMenu();
$toolbar_storage_obj = new AdihaMenu();
$toolbar_pool_obj = new AdihaMenu();
$toolbar_receipt = 'toolbar_receipt';
$toolbar_delivery = 'toolbar_delivery';
$toolbar_storage = 'toolbar_storage';
$toolbar_pool = 'toolbar_pool';

$receipt_grid_obj = new GridTable($receipt_grid_name);
$delivery_grid_obj = new GridTable($delivery_grid_name);
$storage_grid_obj = new GridTable($storage_grid_name);
$pool_grid_obj = new GridTable($pool_grid_name);
echo $layout_obj->init_layout($layout_name, '', $layout_pattern, $layout_json, $form_namespace);

echo $layout_obj->attach_menu_layout_cell('flow_match_menu', $receipt_delivery_cell_id, $menu_json, $form_namespace . '.menu_click');
echo $layout_obj->attach_layout_cell($inner_layout_name, $receipt_delivery_cell_id, '2U', $layout_json_ticket_match);
echo $inner_layout_obj->init_by_attach($inner_layout_name, $form_namespace);
echo $menu_ticket_obj->init_by_attach($menu_flow_match_name, $form_namespace);
echo $context_menu->init_menu('context_menu', $form_namespace);

if ($call_from_ui != $call_from_bookout_label) {
    $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='$form_function_id', @template_name='flow optimization match filter', @group_name = 'General'";
    $return_value1 = readXMLURL2($xml_file);
    $form_json = $return_value1[0]['form_json'];
    echo $layout_obj->attach_form('flow_optimization_form', 'a', $form_json, $return_value1[0]['dependent_combo']);
}

// Logic to get list of Storage Location and Pool Location among all provided.
$check_storage_loc_id = $receipt_loc_id . ',' .  $delivery_loc_id;
$sql = "EXEC spa_storage '$check_storage_loc_id'";
$return_storage = readXMLURL2($sql);

$storage_loc_id = $return_storage[0]['storage_location_id'];
$pool_loc_id = $return_storage[0]['pool_location_id'];
$storage_group_id = $return_storage[0]['storage_group_id'];
$pool_group_id = $return_storage[0]['pool_group_id'];

// Create array of Pool Location and Storage Location.
$pool_loc_id_arr = explode(',', $pool_loc_id);
$storage_loc_id_arr = explode(',', $storage_loc_id);

// Logic to filter out Storage and Pool Group in Receipt Grid.
$receipt_loc_id_to_filter = explode(',', $receipt_loc_id);
$receipt_loc_id_filtered = array_diff($receipt_loc_id_to_filter, $pool_loc_id_arr);
$receipt_loc_id_filtered = array_diff($receipt_loc_id_filtered, $storage_loc_id_arr);
$receipt_loc_id_filtered = implode(',', $receipt_loc_id_filtered);

echo $toolbar_receipt_obj->attach_menu_layout_header($form_namespace, $inner_layout_name, 'a', $toolbar_receipt, $toolbar_receipt_json, 'refresh');

echo $inner_layout_obj->attach_grid_cell($receipt_grid_name, 'a');
echo $receipt_grid_obj->init_grid_table($receipt_grid_name, $form_namespace, 'n');
echo $receipt_grid_obj->set_column_auto_size();
echo $receipt_grid_obj->set_search_filter(true, "");
echo $receipt_grid_obj->enable_column_move();
echo $receipt_grid_obj->enable_multi_select();
echo $receipt_grid_obj->return_init();
echo $receipt_grid_obj->enable_filter_auto_hide();

// Logic to filter out Storage and Pool Group in Deliveries Grid.
$delivery_loc_id_to_filter = explode(',', $delivery_loc_id);
$delivery_loc_id_filtered = array_diff($delivery_loc_id_to_filter, $pool_loc_id_arr);
$delivery_loc_id_filtered = array_diff($delivery_loc_id_filtered, $storage_loc_id_arr);
$delivery_loc_id_filtered = implode(',', $delivery_loc_id_filtered);

echo $toolbar_delivery_obj->attach_menu_layout_header($form_namespace, $inner_layout_name, 'b', $toolbar_delivery, $toolbar_delivery_json, 'refresh');

echo $inner_layout_obj->attach_grid_cell($delivery_grid_name, 'b');
echo $delivery_grid_obj->init_grid_table($delivery_grid_name, $form_namespace, 'n');
echo $delivery_grid_obj->set_column_auto_size();
echo $delivery_grid_obj->set_search_filter(true, "");
echo $delivery_grid_obj->enable_column_move();
echo $delivery_grid_obj->enable_multi_select();
echo $delivery_grid_obj->return_init();
echo $delivery_grid_obj->enable_filter_auto_hide();

echo $inner_layout_obj->close_layout();

if ($call_from_ui != $call_from_bookout_label) {
    echo $layout_obj->attach_layout_cell($inner_layout_location_pool_name, 'c', '2U', $layout_json_storage_pool);
    echo $inner_layout_location_pool_obj->init_by_attach($inner_layout_location_pool_name, $form_namespace);

    echo $toolbar_storage_obj->attach_menu_layout_header($form_namespace, $inner_layout_location_pool_name, 'a', $toolbar_storage, $toolbar_storage_json, 'refresh');

    echo $inner_layout_location_pool_obj->attach_grid_cell($storage_grid_name, 'a');
    echo $storage_grid_obj->init_grid_table($storage_grid_name, $form_namespace, 'n');
    echo $storage_grid_obj->set_column_auto_size();
    echo $storage_grid_obj->set_search_filter(true, "");
    echo $storage_grid_obj->enable_column_move();
    echo $storage_grid_obj->enable_multi_select();
    echo $storage_grid_obj->return_init();
    echo $storage_grid_obj->enable_filter_auto_hide();

    echo $toolbar_pool_obj->attach_menu_layout_header($form_namespace, $inner_layout_location_pool_name, 'b', $toolbar_pool, $toolbar_pool_json, 'refresh');

    echo $inner_layout_location_pool_obj->attach_grid_cell($pool_grid_name, 'b');
    echo $pool_grid_obj->init_grid_table($pool_grid_name, $form_namespace, 'n');
    echo $pool_grid_obj->set_column_auto_size();
    echo $pool_grid_obj->set_search_filter(true, "");
    echo $pool_grid_obj->enable_column_move();
    echo $pool_grid_obj->enable_multi_select();
    echo $pool_grid_obj->return_init();
    echo $pool_grid_obj->enable_filter_auto_hide();
}

echo $layout_obj->close_layout();

$schedule_granularity = $granularity;
if ($granularity == '') {
    $xml_file = "EXEC [spa_adiha_default_codes_values] @flag = 'combo_grid', @default_code_id = 206";
    $return_solver_data = readXMLURL($xml_file);
    $schedule_granularity = $return_solver_data[0][4];
}
?>
<div id="page_info_custom" style="display:none"></div>
<script type="text/javascript">
    var process_id = '<?php echo $process_id; ?>';

    //process id to pass for spa_flow_optimization flag c to create process tables
    var FLAG_C_PROCESS_ID = $.now().toString();
    var FLAG_C_RESULT_DATA = '';
    $('#page_info_custom').attr('flag_c_process_id', FLAG_C_PROCESS_ID);
    
    var call_from_ui = '<?php echo $call_from_ui;?>';
    var call_from_bookout_label = '<?php echo $call_from_bookout_label;?>';

    var call_from = null;
    if (!process_id) {
        process_id = Math.random().toString(36).substring(7);
        call_from = 'deal_scheduling_match';
    }
	
	var schedule_granularity = '<?php echo $schedule_granularity; ?>';
    
    var flow_date_from = '<?php echo $flow_date_from; ?>';
    var flow_date_to = '<?php echo $flow_date_to; ?>';
    var box_id = '<?php echo $box_id; ?>';
    var receipt_loc = '<?php echo $receipt_loc; ?>';
    var delivery_loc = '<?php echo $delivery_loc; ?>';
    var receipt_loc_id = '<?php echo $receipt_loc_id; ?>';
    var delivery_loc_id = '<?php echo $delivery_loc_id; ?>';
    var uom = '<?php echo $uom; ?>';

    var counterparty_id = '<?php echo $counterparty_id; ?>';
    var pipeline = '<?php echo $pipeline; ?>';
    var contract = '<?php echo $contract; ?>';
    var subsidiary_id = '<?php echo $subsidiary_id; ?>';
    var strategy_id = '<?php echo $strategy_id; ?>';
    var book_id = '<?php echo $book_id; ?>';
    var sub_book_id = '<?php echo $sub_book_id; ?>';

    var from_loc_grp_name = '<?php echo $from_loc_grp_name; ?>';
    var to_loc_grp_name = '<?php echo $to_loc_grp_name; ?>';
    var from_loc_grp_id = '<?php echo $from_loc_grp_id; ?>';
    var to_loc_grp_id = '<?php echo $to_loc_grp_id; ?>';
    var selected_path_id = '<?php echo $selected_path_id; ?>';
    var selected_contract_id = '<?php echo $selected_contract_id; ?>';
    var selected_storage_asset_id = '<?php echo $selected_storage_asset_id; ?>';
    var selected_storage_checked = '<?php echo $selected_storage_checked; ?>';
    var source_deal_header_id = '<?php echo $source_deal_header_id; ?>';
    
    storage_loc_id = '<?php echo $storage_loc_id; ?>';
    pool_loc_id = '<?php echo $pool_loc_id; ?>';
    storage_group_id = '<?php echo $storage_group_id; ?>';
    pool_group_id = '<?php echo $pool_group_id; ?>';
    
    var book_structure_text = '<?php echo $book_structure_text; ?>';
    
    // removed pool ids and storage ids from receipt and deliveries
    receipt_loc_id_arr = receipt_loc_id.split(',');
    delivery_loc_id_arr = delivery_loc_id.split(',');
    storage_loc_id_arr = storage_loc_id.split(',');
    pool_loc_id_arr = pool_loc_id.split(',');
    receipt_loc_id_arr = receipt_loc_id_arr.filter(function(el) {return !includes(pool_loc_id_arr, el);});
    receipt_loc_id_arr = receipt_loc_id_arr.filter(function(el) {return !includes(storage_loc_id_arr, el);});
    receipt_loc_id = receipt_loc_id_arr.join(',');
    delivery_loc_id_arr = delivery_loc_id_arr.filter(function(el) {return !includes(pool_loc_id_arr, el);});
    delivery_loc_id_arr = delivery_loc_id_arr.filter(function(el) {return !includes(storage_loc_id_arr, el);});
    delivery_loc_id = delivery_loc_id_arr.join(',');

    var storage_counterparty = null;

    var storage_location = null;

    var proxy_loc_column_id_rec = null;
    var proxy_loc_column_id_del = null;
    new_win_report = '';

    flow_match.grid_load_params = {};

    // Object doesn't support property or method 'includes' in IE. So, a function includes is created to work similar as Object.includes.
    function includes(container, value) {
        var return_value = false;
        var position = container.indexOf(value);
        if (position >= 0) {
            return_value = true;
        }
        return return_value;
    }
    
    $(function() {
        if (call_from_bookout_label != call_from_ui) {
            filter_obj = flow_match.flow_match_layout.cells('a');
            var layout_cell_obj = flow_match.flow_match_layout.cells('a');
            load_form_filter(filter_obj, layout_cell_obj, '10163610', 2, '', '', '', 'layout');
            attach_browse_event('flow_match.flow_optimization_form', '10163610');
        
            if ((storage_loc_id == '' && pool_loc_id == '') || schedule_granularity == '982') {
                flow_match.flow_match_layout.cells('c').collapse();
            }

            //console.log('From URL : ' + subsidiary_id + '|' + strategy_id + '|' + book_id + '|' + sub_book_id);
            flow_match.flow_optimization_form.setItemValue('subsidiary_id', subsidiary_id);
            flow_match.flow_optimization_form.setItemValue('strategy_id', strategy_id);
            flow_match.flow_optimization_form.setItemValue('book_id', book_id);
            flow_match.flow_optimization_form.setItemValue('subbook_id', sub_book_id);
            flow_match.flow_optimization_form.setItemValue('book_structure', decodeURIComponent(book_structure_text));

            flow_date_from = (flow_date_from == '') ? new Date().toISOString().slice(0, 10).replace('T', ' ') : flow_date_from;

            flow_match.flow_optimization_form.setItemValue('flow_date_from', flow_date_from);
            flow_match.flow_optimization_form.setItemValue('flow_date_to', flow_date_to);

            if (receipt_loc_id != '') {
                flow_match.flow_optimization_form.setUserData('receipt_location_name', 'filter_values', receipt_loc_id);
            }

            if (delivery_loc_id != '') {
                flow_match.flow_optimization_form.setUserData('delivery_location_name', 'filter_values', delivery_loc_id);
            }
            
            if (from_loc_grp_id != '') {
                var from_location_groups = from_loc_grp_id.split(',');
                var from_location_groups_index = from_location_groups.length - 1;

                var from_location_group_combo_obj = flow_match.flow_optimization_form.getCombo('receipt_group');
                $.each(from_location_groups, function(index, value) {
                    if (value != storage_group_id && value != pool_group_id) {
                        from_location_group_combo_obj.setChecked(from_location_group_combo_obj.getIndexByValue(value), true, false);
                    }

                    if (from_location_groups_index == index) {
                        from_location_group_combo_obj.callEvent('onCheck', []);
                    }
                });
            }
            
            if (to_loc_grp_id != '') {
                var to_location_groups = to_loc_grp_id.split(',');
                var to_location_groups_index = to_location_groups.length - 1;
                
                var to_location_group_combo_obj = flow_match.flow_optimization_form.getCombo('delivery_group');
                $.each(to_location_groups, function(index, value) {
                    if (value != storage_group_id && value != pool_group_id) {
                        to_location_group_combo_obj.setChecked(to_location_group_combo_obj.getIndexByValue(value), true, false);
                    }

                    if (to_location_groups_index == index) {
                        to_location_group_combo_obj.callEvent('onCheck', []);
                    }
                });
            }

            $.each(pipeline.split(','), function(index, value) {
                combo_obj = flow_match.flow_optimization_form.getCombo('pipeline');
                combo_obj.setChecked(combo_obj.getIndexByValue(value), true);
            });
            
            if (storage_loc_id != '') {
                $.each(storage_loc_id.split(','), function(index, value) {
                    combo_obj = flow_match.flow_optimization_form.getCombo('storage_location_id');
                    combo_obj.setChecked(combo_obj.getIndexByValue(value), true);
                });
            }
            
            if (pool_loc_id != '') {
                $.each(pool_loc_id.split(','), function(index, value) {
                    combo_obj = flow_match.flow_optimization_form.getCombo('pool_id');
                    combo_obj.setChecked(combo_obj.getIndexByValue(value), true);
                });
            }
            
            flow_match.flow_optimization_form.setItemValue('uom', uom);

            var is_proxy_location_checked = flow_match.flow_optimization_form.isItemChecked('proxy_location');
            var proxy_loc_column_id_rec = flow_match.FlowReceipt.getColIndexById('Proxy Location');
            var proxy_loc_column_id_del = flow_match.FlowDelivery.getColIndexById('Proxy Location');

            if (is_proxy_location_checked) {
                flow_match.FlowReceipt.setColumnHidden(proxy_loc_column_id_rec, false);
                flow_match.FlowDelivery.setColumnHidden(proxy_loc_column_id_del, false);
            } else {
                flow_match.FlowReceipt.setColumnHidden(proxy_loc_column_id_rec, true);
                flow_match.FlowDelivery.setColumnHidden(proxy_loc_column_id_del, true);
            }

            flow_match.flow_optimization_form.attachEvent("onChange", function (name, value, is_checked) {
                if (name == 'proxy_location') {
                    if (is_checked) {
                        flow_match.FlowReceipt.setColumnHidden(proxy_loc_column_id_rec, false);
                        flow_match.FlowDelivery.setColumnHidden(proxy_loc_column_id_del, false);
                    } else {
                        flow_match.FlowReceipt.setColumnHidden(proxy_loc_column_id_rec, true);
                        flow_match.FlowDelivery.setColumnHidden(proxy_loc_column_id_del, true);
                    }
                }
            });

            /* Get id of pool and storage */
            pool_group_id = '';
            storage_group_id = '';
            var receipt_group_obj = flow_match.flow_optimization_form.getCombo('receipt_group');
            receipt_group_obj.forEachOption(function(optId) {
                if (optId.text == 'Pool')
                    pool_group_id = optId.value;
                else if (optId.text == 'Storage')
                    storage_group_id = optId.value;
            });
            /* End */
        } else {
            refresh('refresh_all');
        }
        
        if (call_from_bookout_label != call_from_ui) {
            flow_match.FlowReceipt.attachEvent("onSelectStateChanged", function(id, ind) {
                var receipt_call_from_label = 'receipt';
                if (is_only_one_grid_row_selected(receipt_call_from_label)) {
                    var location_id = get_selected_location(this, id, 'Location ID');
                    on_row_select(receipt_call_from_label, location_id);
                }
            });
            
            flow_match.FlowDelivery.attachEvent("onSelectStateChanged", function(id, ind) {
                var delivery_call_from_label = 'delivery';
                if (is_only_one_grid_row_selected(delivery_call_from_label)) {
                    var location_id = get_selected_location(this, id, 'Location ID');
                    on_row_select(delivery_call_from_label, location_id);
                }
            });

            flow_match.FlowPool.attachEvent("onBeforeSelect", disable_tree_level_select);
            flow_match.FlowPool.attachEvent("onRowDblClicked", disable_tree_dbl_click);

            flow_match.FlowPool.attachEvent("onSelectStateChanged", function(id) {
                var pool_call_from_label = 'pool';
                if (is_only_one_grid_row_selected(pool_call_from_label)) {
                    var location_id = get_selected_location(this, id, 'Location ID');
                    on_row_select(pool_call_from_label, location_id);
                }
            });

            flow_match.FlowStorage.attachEvent("onBeforeSelect", disable_tree_level_select);
            flow_match.FlowStorage.attachEvent("onRowDblClicked", disable_tree_dbl_click);

            flow_match.FlowStorage.attachEvent("onSelectStateChanged", function(id) {
                var storage_call_from_label = 'storage';
                if (is_only_one_grid_row_selected(storage_call_from_label)) {
                    var location_id = get_selected_location(this, id, 'location_id');
                    on_row_select(storage_call_from_label, location_id);
                }
            });
        }
        
        if (!Math.sign) {
            Math.sign = function(x) {
                return ((x > 0) - (x < 0)) || +x;
            };
        }
    });

    function disable_tree_level_select(new_row, old_row, new_col_index) {
        var tree_level = this.getLevel(new_row);
		if (tree_level == 0) {
			return false;
		}

		return true;
    }

    function disable_tree_dbl_click(row_id, col_ind) {
        if (this.getColType(0) == 'tree') {
			var tree_level = this.getLevel(row_id);
			if (tree_level == 0) {
				if (!this.getOpenState(row_id)) {	
					this.openItem(row_id);
				} else {
					this.closeItem(row_id);
				}
			}
		}
		
		return false;
    }

    function get_selected_location(grid_obj, row_ids, column_id) {
        if (row_ids == '' || row_ids == null) {
            return '';
        }
        
        var row_id_array = row_ids.split(',');
        var location_id_array = row_id_array.map(function(item) {
            return grid_obj.cells(item, grid_obj.getColIndexById(column_id)).getValue();
        });

        var location_id_array = location_id_array.filter(function (item) {
            return item != '';
        });
        
        return location_id_array.join(',');
    }

    function is_only_one_grid_row_selected(grid_selected) {
        if (grid_selected != 'receipt') {
            var receipt_selected = flow_match.FlowReceipt.getSelectedRowId();
        }
        if (grid_selected != 'delivery') {
            var delivery_selected = flow_match.FlowDelivery.getSelectedRowId();
        }
        if (grid_selected != 'storage') {
            var storage_selected = flow_match.FlowStorage.getSelectedRowId();
        }
        if (grid_selected != 'pool') {
            var pool_selected = flow_match.FlowPool.getSelectedRowId();
        }
        
        var first_grid_selected = flow_match.first_grid_selected;
        if ((receipt_selected == null && delivery_selected == null && storage_selected == null && pool_selected == null) || first_grid_selected == grid_selected) {
            flow_match.first_grid_selected = grid_selected;
            return true;
        }
        
        return false;
    }

    flow_match.menu_click = function(id) {
        switch (id) {
            case "multi_match" :
            case "match" :
                open_flow_match_popup(id);
                break;
            case "show_zero_vol" :
                var status = flow_match.flow_match_menu.getCheckboxState('show_zero_vol');
                if (call_from == 'deal_scheduling_match') {
                    flow_date_from = flow_match.flow_optimization_form.getItemValue('flow_date_from', true);
                    flow_date_to =flow_match.flow_optimization_form.getItemValue('flow_date_to', true);

                    receipt_location_name_obj = flow_match.flow_optimization_form.getCombo('receipt_location_name');
                    receipt_loc_id = receipt_location_name_obj.getChecked();

                    delivery_location_name_obj = flow_match.flow_optimization_form.getCombo('delivery_location_name');
                    delivery_loc_id = delivery_location_name_obj.getChecked();
                }

                if (status == true) {
                    status = 'y';
                } else {
                    status = 'n';
                }
                show_zero_vol_top(status);
                show_zero_vol_bottom(status);
                break;
            case "refresh_all":
                flow_match.first_grid_selected = null;
                refresh('refresh_all');
                break;
            case "view_schedule":
                open_view_schedule_window();
                break;
            case "report":
                if (new_win_report && new_win_report != undefined && new_win_report != '') {
                    if (new_win_report._idd != null) {
                        new_win_report.close();
                    }
                }
                load_position_report();
                break;
        }
    }

    function load_position_report() {
        if (call_from_ui != call_from_bookout_label) {
            if (!validate_form(flow_match.flow_optimization_form)) {
                return;
            }
            var filter_flow_date_from = flow_match.flow_optimization_form.getItemValue('flow_date_from', true);
            var filter_flow_date_to =flow_match.flow_optimization_form.getItemValue('flow_date_to', true);
            //set flow date to = flow date from when it is null
            if (filter_flow_date_to == '' || filter_flow_date_to == undefined) {
                filter_flow_date_to = filter_flow_date_from;
            }
            var receipt_group_obj = flow_match.flow_optimization_form.getCombo('receipt_group');
            var receipt_loc_group_id = receipt_group_obj.getChecked();

            var receipt_location_name_obj = flow_match.flow_optimization_form.getCombo('receipt_location_name');
            var receipt_loc_id = receipt_location_name_obj.getChecked();

            var delivery_group_obj = flow_match.flow_optimization_form.getCombo('delivery_group');
            var delivery_loc_group_id = delivery_group_obj.getChecked();

            var delivery_location_name_obj = flow_match.flow_optimization_form.getCombo('delivery_location_name');
            var delivery_loc_id = delivery_location_name_obj.getChecked();

            var pipeline_obj = flow_match.flow_optimization_form.getCombo('pipeline');
            var pipeline_id = pipeline_obj.getChecked();
            var contract_obj = flow_match.flow_optimization_form.getCombo('contract');
            var contract_id = contract_obj.getChecked();
            var uom = flow_match.flow_optimization_form.getItemValue('uom');
            var proxy_location = flow_match.flow_optimization_form.isItemChecked('proxy_location');
            var proxy_loc_column_id_rec = flow_match.FlowReceipt.getColIndexById('Proxy Location');
            var proxy_loc_column_id_del = flow_match.FlowDelivery.getColIndexById('Proxy Location');

            var storage_location_obj = flow_match.flow_optimization_form.getCombo('storage_location_id');
            var storage_location_id = storage_location_obj.getChecked();

            var pool_location_obj = flow_match.flow_optimization_form.getCombo('pool_location_id');
            var pool_location_id = pool_location_obj.getChecked();

            var pool_obj = flow_match.flow_optimization_form.getCombo('pool_id');
            var pool_id = pool_obj.getChecked();


            var filter_subsidiary_id = flow_match.flow_optimization_form.getItemValue('subsidiary_id');
            var filter_strategy_id = flow_match.flow_optimization_form.getItemValue('strategy_id');
            var filter_book_id = flow_match.flow_optimization_form.getItemValue('book_id');
            var filter_sub_book_id = flow_match.flow_optimization_form.getItemValue('subbook_id');
            var volume_conversion = flow_match.flow_optimization_form.getItemValue('volume_conversion');
            var counterparty_obj = flow_match.flow_optimization_form.getCombo('counterparty_id');
            var filter_counterparty_id = counterparty_obj.getChecked();
            var uom_name = flow_match.flow_optimization_form.getCombo('volume_conversion').getComboText();
        } else {
            var filter_flow_date_from = flow_date_from;
            var filter_flow_date_to = flow_date_to;
            var filter_uom = uom;
            var uom_name = '';
            var filter_subsidiary_id = subsidiary_id;
            var filter_strategy_id = strategy_id;
            var filter_book_id = book_id;
            var filter_sub_book_id = sub_book_id;
            
            var receipt_loc_group_id = from_loc_grp_id.split(',');
            var delivery_loc_group_id = to_loc_grp_id.split(',');
            var receipt_loc_id = receipt_loc_id_arr;
            var delivery_loc_id = delivery_loc_id_arr;
            var storage_location_id = storage_loc_id_arr;
            var contract_id = selected_contract_id.split(',');
            var pipeline_id = pipeline.split(',');
            var volume_conversion = '';
            var filter_counterparty_id = counterparty_id;
            filter_counterparty_id = filter_counterparty_id.split(',');
            var pool_location_id = Array();
            var pool_id = Array();
        }

        // Grid Row Selection Location filter
        if (flow_match.first_grid_selected != null) {
            if (flow_match.first_grid_selected == 'receipt') {
                var receipt_row_id = flow_match.FlowReceipt.getSelectedRowId();
            } else {
                var receipt_row_id = flow_match.FlowReceipt.getAllRowIds();
            }
            receipt_loc_id = get_selected_location(flow_match.FlowReceipt, receipt_row_id, 'Location ID').split(',');
            
            if (flow_match.first_grid_selected == 'delivery') {
                var delivery_row_id = flow_match.FlowDelivery.getSelectedRowId();
            } else {
                var delivery_row_id = flow_match.FlowDelivery.getAllRowIds();
            }
            delivery_loc_id = get_selected_location(flow_match.FlowDelivery, delivery_row_id, 'Location ID').split(',');
            
            if (flow_match.first_grid_selected == 'storage') {
                var storage_row_id = flow_match.FlowStorage.getSelectedRowId();
            } else {
                var storage_row_id = flow_match.FlowStorage.getAllRowIds();
            }
            storage_location_id = get_selected_location(flow_match.FlowStorage, storage_row_id, 'location_id').split(',');
            
            if (flow_match.first_grid_selected == 'pool') {
                var pool_row_id = flow_match.FlowPool.getSelectedRowId();
            } else {
                var pool_row_id = flow_match.FlowPool.getAllRowIds();
            }
            pool_id = get_selected_location(flow_match.FlowPool, pool_row_id, 'Location ID').split(',');
        }
        
        /** receipt and delivery locations distribute logic - start **/
        var receipt_loc_id_string = '';
        var receipt_loc_group_string = '';
        var delivery_loc_id_string = '';
        var delivery_loc_group_string = '';
        var storage_location_id_string = '';
        var pool_id_string = '';
        
        if (flow_match.first_grid_selected != 'receipt') {
            receipt_loc_id = _.union(receipt_loc_id, storage_location_id, pool_id);
            receipt_loc_group_id = _.union(receipt_loc_group_id, storage_group_id, pool_group_id);
        }

        if (flow_match.first_grid_selected != 'delivery') {
            delivery_loc_id = _.union(delivery_loc_id, storage_location_id, pool_id);
            delivery_loc_group_id = _.union(delivery_loc_group_id, storage_group_id, pool_group_id);
        }
        
        receipt_loc_id_string = receipt_loc_id.join();
        delivery_loc_id_string = delivery_loc_id.join();
        receipt_loc_group_string = receipt_loc_group_id.join();
        delivery_loc_group_string = delivery_loc_group_id.join();
        
        /** receipt and delivery locations distribute logic - end **/

        var post_data = {
            "flow_date_from":  filter_flow_date_from == '' ? 'NULL' : filter_flow_date_from,
            "flow_date_to":  filter_flow_date_to == '' ? 'NULL' : filter_flow_date_to,
            "priority_from": 'NULL',
            "priority_to": 'NULL',
            "path_priority": 'NULL',
            "opt_objectives": 'NULL',
            "receipt_group": receipt_loc_group_string == '' ? 'NULL' : receipt_loc_group_string,
            "receipt_location_name": receipt_loc_id_string == '' ? 'NULL' : receipt_loc_id_string,
            "delivery_group": delivery_loc_group_string == '' ? 'NULL' : delivery_loc_group_string,
            "delivery_location_name": delivery_loc_id_string == '' ? 'NULL' : delivery_loc_id_string,
            "pipeline": pipeline_id.join() == '' ? 'NULL' : pipeline_id.join(),
            "contract": contract_id.join() == '' ? 'NULL' : contract_id.join(),
            "subsidiary_id": filter_subsidiary_id == '' ? 'NULL' : filter_subsidiary_id,
            "strategy_id": filter_strategy_id == '' ? 'NULL' : filter_strategy_id,
            "book_id": filter_book_id == '' ? 'NULL' : filter_book_id,
            "sub_book_id": filter_sub_book_id == '' ? 'NULL' : filter_sub_book_id,
            //"uom": volume_conversion == '' ? 'NULL' : volume_conversion,
			"uom": volume_conversion,
            "uom_name": uom_name == '' ? 'NULL' : uom_name,
            "delivery_path": 'NULL',
            "call_from": 'flow_deal_match',
            "hide_pos_zero": 0,
            "reschedule": 0,
            "book_structure_text" : 'NULL'
        }

        var url = app_form_path  + '_scheduling_delivery/gas/flow_optimization/flow.optimization.template.php';
        new_win_report = new dhtmlXWindows();
        new_win_report = new_win_report.createWindow('w1', 0, 0, 900, 380);
        new_win_report.setText('Position Report');
        new_win_report.centerOnScreen();
        new_win_report.maximize();
        /* The window is placed at bottom*/
        new_win_report.attachEvent("onParkUp", function(wins) {
            wins.bottom();
        });

        /*Position of window is centered in viewport
        * When position is set as bottom in viewport, Window gets expanded in same position making the
        * windows content invisible without repositioning window.
        * */
        new_win_report.attachEvent("onParkDown", function(wins) {
            wins.center();
        });
        new_win_report.attachEvent("onMaximize", function(wins) {
            wins.center();
        });
        new_win_report.attachEvent("onMinimize", function(wins) {
            wins.center();
        });
        new_win_report.attachURL(url, false, post_data);
    }
    
    function refresh_storage_grid(refresh_type, params_storage) {
        if (refresh_type == 'dependent') {
            var param = params_storage;
            var storage_id = params_storage.location_id;
        } else {
            var flow_date_from = flow_match.flow_optimization_form.getItemValue('flow_date_from', true);
            var flow_date_to = flow_match.flow_optimization_form.getItemValue('flow_date_to', true);
            if (flow_date_to == '' || flow_date_to == undefined) {
                flow_date_to = flow_date_from;
            }
            var uom = flow_match.flow_optimization_form.getItemValue('uom');
            var storage_location_obj = flow_match.flow_optimization_form.getCombo('storage_location_id');
            var storage_location_id = storage_location_obj.getChecked();
            var volume_conversion = flow_match.flow_optimization_form.getItemValue('volume_conversion');
            var counterparty_obj = flow_match.flow_optimization_form.getCombo('counterparty_id');
            var counterparty_id = counterparty_obj.getChecked();
            var storage_id = storage_location_id.join();
            
            var param = {
                "action":"spa_storage_position_report",
                "grid_type":"tg",
                "grouping_column":"location_group,location",
                "commodity_id":50,
                "location_id":storage_id,
                "term_start":flow_date_from,
                "term_end":flow_date_to,
                "uom":uom,
                "call_from":"STORAGE_GRID",
                "volume_conversion":volume_conversion,
                "counterparty_id":counterparty_id.join(),
            };
            flow_match.grid_load_params.storage = param;
        }

        if (storage_id) {
            param = $.param(param);
            var param_url = js_data_collector_url + "&" + param;

            flow_match.FlowStorage.clearAndLoad(param_url, function() {
                flow_match.FlowStorage.loadOpenStates();
                flow_match.FlowStorage.expandAll();
                if (refresh_type == 'refresh_storage') {
                    flow_match.flow_match_location_pool.cells('a').progressOff();
                } else { //refresh all case
                    GRID_LOAD_STATUS.grid3 = true;
                    fx_final_grid_load_callback();
                }
            });
        } else {
            if (refresh_type == 'refresh_storage') {
                flow_match.flow_match_location_pool.cells('a').progressOff();
            } else {//refresh all case
                GRID_LOAD_STATUS.grid3 = true;
                fx_final_grid_load_callback();
            }
        }
    }

    function open_view_schedule_window() {
        if (call_from_bookout_label != call_from_ui) {
            if (!validate_form(flow_match.flow_optimization_form)) {
                return;
            }
            var filter_flow_date_from = flow_match.flow_optimization_form.getItemValue('flow_date_from', true);
            var filter_flow_date_to = flow_match.flow_optimization_form.getItemValue('flow_date_to', true);
            if (filter_flow_date_to == '' || filter_flow_date_to == undefined) {
                filter_flow_date_to = filter_flow_date_from;
            }

            var receipt_group_obj = flow_match.flow_optimization_form.getCombo('receipt_group');
            var receipt_group = receipt_group_obj.getChecked();

            var receipt_location_name_obj = flow_match.flow_optimization_form.getCombo('receipt_location_name');
            var receipt_locs = receipt_location_name_obj.getChecked();

            var delivery_group_obj = flow_match.flow_optimization_form.getCombo('delivery_group');
            var delivery_group = delivery_group_obj.getChecked();

            var delivery_location_name_obj = flow_match.flow_optimization_form.getCombo('delivery_location_name');
            var delivery_locs = delivery_location_name_obj.getChecked();

            var path_id = selected_path_id;

            var storage_location_obj = flow_match.flow_optimization_form.getCombo('storage_location_id');
            var storage_location_id = storage_location_obj.getChecked();

            var pool_location_obj = flow_match.flow_optimization_form.getCombo('pool_location_id');
            var pool_location_id = pool_location_obj.getChecked();

            var pool_obj = flow_match.flow_optimization_form.getCombo('pool_id');
            var pool_id = pool_obj.getChecked();
        } else {
            var filter_flow_date_from = flow_date_from;
            var filter_flow_date_to = flow_date_to;
            if (filter_flow_date_to == '' || filter_flow_date_to == undefined) {
                filter_flow_date_to = filter_flow_date_from;
            }
            var storage_location_id = storage_loc_id_arr;
            var receipt_locs = receipt_loc_id_arr;
            var delivery_locs = delivery_loc_id_arr;
            var receipt_group = from_loc_grp_id.split(',');
            var delivery_group = to_loc_grp_id.split(',');
            var pool_id = Array();
            var pool_location_id = Array();
        }

        /* Get location ids for receipt group*/
        var receipt_loc_id_string = receipt_locs.join();
        receipt_loc_id_string = (receipt_loc_id_string && receipt_loc_id_string) ? (storage_location_id.join() && storage_location_id.join() !='') ? receipt_loc_id_string + ',' + storage_location_id.join() : receipt_loc_id_string : storage_location_id.join();
        receipt_loc_id_string = (receipt_loc_id_string && receipt_loc_id_string) ? (pool_id.join() && pool_id.join() !='') ? receipt_loc_id_string + ',' + pool_id.join() : receipt_loc_id_string : pool_id.join();
        receipt_loc_id_string = (receipt_loc_id_string && receipt_loc_id_string) ? (pool_location_id.join() && pool_location_id.join() !='') ? receipt_loc_id_string + ',' + pool_location_id.join() : receipt_loc_id_string : pool_location_id.join();
        if (receipt_loc_id_string && receipt_loc_id_string != '') {
            var receipt_loc_id_array = uniq(receipt_loc_id_string.split(','));
            receipt_loc_id_string = receipt_loc_id_array.join();
        }

        /* Add pool and storage group to receipt group if pool and storage present*/
        var receipt_loc_group_string = receipt_group.join();
        receipt_loc_group_string = (receipt_loc_group_string && receipt_loc_group_string) ? (storage_location_id.join() && storage_location_id.join() !='') ? receipt_loc_group_string + ',' + storage_group_id : receipt_loc_group_string : (storage_location_id.join() && storage_location_id.join() !='') ? storage_group_id : '';
        receipt_loc_group_string = (receipt_loc_group_string && receipt_loc_group_string) ? (pool_id.join() && pool_id.join() !='') ? receipt_loc_group_string + ',' + pool_group_id:receipt_loc_group_string : (pool_id.join() && pool_id.join() !='') ? pool_group_id : '';
        if (receipt_loc_group_string && receipt_loc_group_string != '') {
            var receipt_loc_group_array = uniq(receipt_loc_group_string.split(','));
            receipt_loc_group_string = receipt_loc_group_array.join();
        }

        var location_ids =  (receipt_loc_id_string + ',' + delivery_locs).replace(/^,/, '').replace(/,\s*$/, '') ;
        var delivery_receipt_group = (receipt_loc_group_string + ',' + delivery_group).replace(/^,/, '').replace(/,\s*$/, '') ;
		
        var args = '?call_from=deal_scheduling_match&location_ids=' + location_ids + '&flow_date=' + filter_flow_date_from + '&flow_date_end=' + filter_flow_date_to + '&delivery_receipt_group=' + delivery_receipt_group + '&path_ids=' + path_id;

        if (parent && parent.parent)
            parent.parent.open_menu_window("_scheduling_delivery/gas/view_nom_schedules/view.nom.schedules.php" + args, "windowSchedulesView", "View Nomination Schedules");

    }

    /**
     * global object for grid loaded status.
     *
     */
    GRID_LOAD_STATUS = {
        grid1: false, //receipt grid
        grid2: false, //delivery grid
        grid3: false, //storage grid
        grid4: false  //pool grid
    }

    /**
     * Function to progress off the layout progress loader when all grid loaded, called from every grid load call.
     *
     */
    fx_final_grid_load_callback = function() {
        if (GRID_LOAD_STATUS.grid1 && GRID_LOAD_STATUS.grid2 && GRID_LOAD_STATUS.grid3 && GRID_LOAD_STATUS.grid4) {
            flow_match.flow_match_layout.progressOff();
        }
    };

    /**
     * grid refresh function to refresh all grid
     *
     */
    function refresh(id) {
        if (call_from_ui != call_from_bookout_label) {
            if (!validate_form(flow_match.flow_optimization_form)) {
                return;
            }
            storage_location = null;
            storage_counterparty = null;

            var filter_flow_date_from = flow_match.flow_optimization_form.getItemValue('flow_date_from', true);
            var filter_flow_date_to = flow_match.flow_optimization_form.getItemValue('flow_date_to', true);
            //set flow date to = flow date from when it is null
            if (filter_flow_date_to == '' || filter_flow_date_to == undefined) {
                filter_flow_date_to = filter_flow_date_from;
            }

            var receipt_group_obj = flow_match.flow_optimization_form.getCombo('receipt_group');
            var receipt_loc_group_id = receipt_group_obj.getChecked();

            var receipt_location_name_obj = flow_match.flow_optimization_form.getCombo('receipt_location_name');
            var receipt_loc_id = receipt_location_name_obj.getChecked();

            var delivery_group_obj = flow_match.flow_optimization_form.getCombo('delivery_group');
            var delivery_loc_group_id = delivery_group_obj.getChecked();

            var delivery_location_name_obj = flow_match.flow_optimization_form.getCombo('delivery_location_name');
            var delivery_loc_id = delivery_location_name_obj.getChecked();

            var pipeline_obj = flow_match.flow_optimization_form.getCombo('pipeline');
            var pipeline_id = pipeline_obj.getChecked();
            var contract_obj = flow_match.flow_optimization_form.getCombo('contract');
            var contract_id = contract_obj.getChecked();
            var filter_uom = flow_match.flow_optimization_form.getItemValue('uom');
            var proxy_location = flow_match.flow_optimization_form.isItemChecked('proxy_location');
            
            var storage_location_obj = flow_match.flow_optimization_form.getCombo('storage_location_id');
            var storage_location_id = storage_location_obj.getChecked();

            var pool_location_obj = flow_match.flow_optimization_form.getCombo('pool_location_id');
            var pool_location_id = pool_location_obj.getChecked();

            var pool_obj = flow_match.flow_optimization_form.getCombo('pool_id');
            var pool_id = pool_obj.getChecked();

            var filter_subsidiary_id = flow_match.flow_optimization_form.getItemValue('subsidiary_id');
            var filter_strategy_id = flow_match.flow_optimization_form.getItemValue('strategy_id');
            var filter_book_id = flow_match.flow_optimization_form.getItemValue('book_id');
            var filter_sub_book_id = flow_match.flow_optimization_form.getItemValue('subbook_id');
            var volume_conversion = flow_match.flow_optimization_form.getItemValue('volume_conversion');
            var counterparty_obj = flow_match.flow_optimization_form.getCombo('counterparty_id');
            var filter_counterparty_id = counterparty_obj.getChecked();
            //console.log('From Browser : ' +subsidiary_id + '|' + strategy_id + '|' + book_id + '|' + sub_book_id);
        } else {
            var filter_flow_date_from = flow_date_from;
            var filter_flow_date_to = flow_date_to;
            var filter_uom = uom;
            var filter_subsidiary_id = subsidiary_id;
            var filter_strategy_id = strategy_id;
            var filter_book_id = book_id;
            var filter_sub_book_id = sub_book_id;
            var proxy_location = false;
            var receipt_loc_group_id = from_loc_grp_id.split(',');
            var delivery_loc_group_id = to_loc_grp_id.split(',');
            var receipt_loc_id = receipt_loc_id_arr;
            var delivery_loc_id = delivery_loc_id_arr;
            var storage_location_id = storage_loc_id_arr;
            var contract_id = selected_contract_id.split(',');
            var pipeline_id = pipeline.split(',');
            var volume_conversion = '';
            var filter_counterparty_id = counterparty_id;
            filter_counterparty_id = filter_counterparty_id.split(',');
            var pool_location_id = Array();
            var pool_id = Array();
        }

        /* Remove location that has been selected in receipt location and also in location filter*/
        pool_location_id = pool_location_id.filter( function( el ) {
            return receipt_loc_id.indexOf( el ) < 0;
        });

        /* Remove location that has been selected in delivery location and also in location filter*/
        pool_location_id = pool_location_id.filter( function( el ) {
            return delivery_loc_id.indexOf( el ) < 0;
        });
		
		//removed this filter as this will avoid locations on pool grid
		/*
        pool_id = pool_id.filter( function( el ) {
            return receipt_loc_id.indexOf( el ) < 0;
        });

        pool_id = pool_id.filter( function( el ) {
            return delivery_loc_id.indexOf( el ) < 0;
        });
		*/
        
        var collective_to_loc_id = _.union(delivery_loc_id, storage_location_id, pool_id);
		var collective_from_loc_id = _.union(receipt_loc_id, pool_id);
        //console.log(collective_to_loc_id);

        var proxy_loc_column_id_rec = flow_match.FlowReceipt.getColIndexById('Proxy Location');
        var proxy_loc_column_id_del = flow_match.FlowDelivery.getColIndexById('Proxy Location');

        if (proxy_location) {
            flow_match.FlowReceipt.setColumnHidden(proxy_loc_column_id_rec, false);
            flow_match.FlowDelivery.setColumnHidden(proxy_loc_column_id_del, false);
        } else {
            flow_match.FlowReceipt.setColumnHidden(proxy_loc_column_id_rec, true);
            flow_match.FlowDelivery.setColumnHidden(proxy_loc_column_id_del, true);
        }
        
        switch (id) {
            case 'refresh_all':
                if (call_from_ui != call_from_bookout_label) {
                    flow_match.flow_match_layout.cells('a').collapse();
                    if (schedule_granularity == '982') {
                        flow_match.flow_match_layout.cells('c').expand();
                    }
                    flow_match.FlowStorage.clearAll();
                    flow_match.FlowPool.clearAll();
                }

                flow_match.FlowReceipt.clearAll();
                flow_match.FlowDelivery.clearAll();
                break;
            case 'refresh_receipt':
                flow_match.flow_match_inner_layout.cells('a').progressOn();
                flow_match.FlowReceipt.clearAll();
                break;
            case 'refresh_delivery':
                flow_match.flow_match_inner_layout.cells('b').progressOn();
                flow_match.FlowDelivery.clearAll();
                break;
            case 'refresh_storage':
                flow_match.flow_match_location_pool.cells('a').progressOn();
                flow_match.FlowStorage.clearAll();
                break;
            case 'refresh_pool':
                flow_match.flow_match_location_pool.cells('b').progressOn();
                flow_match.FlowPool.clearAll();
                break;
            default:
                break;
        }

        var params_receipt = {
            'action': 'spa_flow_optimization',
            'flag': 'm',
            'flow_date_from': filter_flow_date_from,
            'flow_date_to': filter_flow_date_to,
            'major_location': receipt_loc_group_id.join(),
            'minor_location': receipt_loc_id.join(),
            'process_id': FLAG_C_PROCESS_ID,
            'contract_id': contract_id.join(),
            'pipeline_ids': pipeline_id.join(),
            'uom': filter_uom,
            "volume_conversion": volume_conversion,
            "counterparty_id": filter_counterparty_id.join(),
            "source_deal_header_ids" : source_deal_header_id
        };
        flow_match.grid_load_params.receipt = params_receipt;

        var params_delivery = {
            'action': 'spa_flow_optimization',
            'flag': 'n',
            'flow_date_from': filter_flow_date_from,
            'flow_date_to': filter_flow_date_to,
            'major_location': delivery_loc_group_id.join(),
            'minor_location': delivery_loc_id.join(),
            'process_id': FLAG_C_PROCESS_ID,
            'contract_id': contract_id.join(),
            'pipeline_ids': pipeline_id.join(),
            'uom': filter_uom,
            "volume_conversion": volume_conversion,
            "counterparty_id": filter_counterparty_id.join()

        };
        flow_match.grid_load_params.delivery = params_delivery;

        var params_pool = {
            'action': 'spa_flow_optimization',
            'flag': 'pl',
            'flow_date_from': filter_flow_date_from,
            'flow_date_to': filter_flow_date_to,
            'major_location': delivery_loc_group_id.join(),
            'minor_location': delivery_loc_id.join(),
            'process_id' : FLAG_C_PROCESS_ID,
            'contract_id': contract_id.join(),
            'pipeline_ids': pipeline_id.join(),
            'uom': filter_uom,
            "pool_id": pool_id.join(),
            "pool_location_id": pool_location_id.join(),
            "volume_conversion": volume_conversion,
            "counterparty_id": filter_counterparty_id,
            "grid_type": 'tg',
            'grouping_column': 'location_type,Location'
        };
        flow_match.grid_load_params.pool = params_pool;

        var data = {"action": "spa_flow_optimization_hourly",
            "flag": 'c',
            "flow_date_from": filter_flow_date_from,
            "flow_date_to": filter_flow_date_to,
            "from_location": collective_from_loc_id.join(),
            "to_location": collective_to_loc_id.join(),
            "process_id": FLAG_C_PROCESS_ID,
            "pipeline_ids": pipeline_id.join(),
            "contract_id": contract_id.join(),
            "uom": volume_conversion ,
            "sub": filter_subsidiary_id,
            "str": filter_strategy_id,
            "book": filter_book_id,
            "sub_book_id": filter_sub_book_id,
            "pool_location_id": pool_location_id.join(),
            "pool_id": pool_id.join(),
            "volume_conversion": volume_conversion,
            "counterparty_id": filter_counterparty_id.join()

        };

        if (id == 'refresh_storage') {
            refresh_storage_grid(id);
        } else {
            if (id == 'refresh_all') {
                flow_match.flow_match_layout.progressOn();
                GRID_LOAD_STATUS.grid1 = false;
                GRID_LOAD_STATUS.grid2 = false;
                GRID_LOAD_STATUS.grid3 = false;
                GRID_LOAD_STATUS.grid4 = false;
                
                if (call_from_ui == call_from_bookout_label) {
                    GRID_LOAD_STATUS.grid3 = true;
                    GRID_LOAD_STATUS.grid4 = true;
                }
            }
            
            adiha_post_data('return_json', data, '', '', function(result_data) {
                FLAG_C_RESULT_DATA = JSON.parse(result_data);
                
                switch (id) {
                    case 'refresh_all':
                        load_all_grids(params_receipt, params_delivery, params_pool, '', 'all');
                        break;
                    case 'refresh_receipt':
                        if (receipt_loc_id.join() && receipt_loc_id.join() != '') {
                            var params_receipts = $.param(params_receipt);
                            var params_receipt_url = js_data_collector_url + "&" + params_receipts;

                            flow_match.FlowReceipt.loadXML(params_receipt_url, function() {
                                flow_match.flow_match_inner_layout.cells('a').progressOff();
                            });
                        } else {
                            flow_match.flow_match_inner_layout.cells('a').progressOff();
                        }
                        break;
                    case 'refresh_delivery':
                        if (delivery_loc_id.join() && delivery_loc_id.join() != '') {
                            var params_deliverys = $.param(params_delivery);
                            var params_delivery_url = js_data_collector_url + "&" + params_deliverys;
                            
                            flow_match.FlowDelivery.loadXML(params_delivery_url, function() {
                                flow_match.flow_match_inner_layout.cells('b').progressOff();
                            });
                        } else {
                            flow_match.flow_match_inner_layout.cells('b').progressOff();
                        }
                        break;
                    case 'refresh_pool':
                        if ((pool_id.join() && pool_id.join() != '') || (pool_location_id.join() && pool_location_id.join() != '')) {
                            var params_pools = $.param(params_pool);
                            var params_pool_url = js_data_collector_url + "&" + params_pools;
                            
                            flow_match.FlowPool.loadXML(params_pool_url, function() {
                                flow_match.FlowPool.expandAll();
                                flow_match.flow_match_location_pool.cells('b').progressOff();
                            });
                        } else {
                            flow_match.flow_match_location_pool.cells('b').progressOff();
                        }
                        break;
                    default:
                        break;
                }
            });
        }
    }

    function on_row_select(grid_selected, location_id) {
        flow_match.flow_match_layout.progressOn();

        GRID_LOAD_STATUS.grid1 = false;
        GRID_LOAD_STATUS.grid2 = false;
        GRID_LOAD_STATUS.grid3 = false;
        GRID_LOAD_STATUS.grid4 = false;

		if (location_id == '') {
			on_row_select_callback([], grid_selected, true);
		} else {
            var data = {
                'action': 'spa_flow_optimization',
                'flag': 'a',
                'minor_location': location_id,
                'call_from': grid_selected
            }
            
            adiha_post_data('return_array', data, '', '', function(result) {
                var result = result[0][0];
                on_row_select_callback(result, grid_selected);
            });
        }
    }

    function on_row_select_callback(result, grid_selected, is_unselection) {
        var params_receipt = JSON.parse(JSON.stringify(flow_match.grid_load_params.receipt));
        var params_delivery = JSON.parse(JSON.stringify(flow_match.grid_load_params.delivery));
        var params_pool = JSON.parse(JSON.stringify(flow_match.grid_load_params.pool));
        var params_storage = JSON.parse(JSON.stringify(flow_match.grid_load_params.storage));

        if (!is_unselection) {
            var location_id_array = params_receipt.minor_location.split(',');
            var filter_location_id = location_id_array.filter(function(item) {
                return includes(result, item);
            });
            params_receipt.minor_location = filter_location_id.join();

            var location_id_array = params_delivery.minor_location.split(',');
            var filter_location_id = location_id_array.filter(function(item) {
                return includes(result, item);
            });
            params_delivery.minor_location = filter_location_id.join();

            var location_id_array = params_pool.pool_id.split(',');
            var filter_location_id = location_id_array.filter(function(item) {
                return includes(result, item);
            });
            params_pool.pool_id = filter_location_id.join();

            var location_id_array = params_storage.location_id.split(',');
            var filter_location_id = location_id_array.filter(function(item) {
                return includes(result, item);
            });
            params_storage.location_id = filter_location_id.join();
        }
        
        if (grid_selected != 'receipt') {
            flow_match.FlowReceipt.clearAll();
        }
        if (grid_selected != 'delivery') {
            flow_match.FlowDelivery.clearAll();
        }
        if (grid_selected != 'storage') {
            flow_match.FlowStorage.clearAll();
        }
        if (grid_selected != 'pool') {
            flow_match.FlowPool.clearAll();
        }
        
        load_all_grids(params_receipt, params_delivery, params_pool, params_storage, grid_selected);
    }

    function load_all_grids(params_receipt, params_delivery, params_pool, params_storage, grid_selected) {
        if (params_receipt.minor_location && params_receipt.minor_location != '' && grid_selected != 'receipt') {
            var params_receipt = $.param(params_receipt);
            var params_receipt_url = js_data_collector_url + "&" + params_receipt;

            flow_match.FlowReceipt.clearAndLoad(params_receipt_url, function() {
                GRID_LOAD_STATUS.grid1 = true;
                fx_final_grid_load_callback();
            });
        } else {
            GRID_LOAD_STATUS.grid1 = true;
            fx_final_grid_load_callback();
        }

        if (params_delivery.minor_location && params_delivery.minor_location != '' && grid_selected != 'delivery') {
            var params_delivery = $.param(params_delivery);
            var params_delivery_url = js_data_collector_url + "&" + params_delivery;

            flow_match.FlowDelivery.clearAndLoad(params_delivery_url, function() {
                GRID_LOAD_STATUS.grid2 = true;
                fx_final_grid_load_callback();
            });
        } else {
            GRID_LOAD_STATUS.grid2 = true;
            fx_final_grid_load_callback();
        }

        if (call_from_ui != call_from_bookout_label) {
            if (grid_selected != 'storage') {
                refresh_storage_grid((params_storage != '') ? 'dependent' : 'refresh_all', params_storage);
            } else {
                GRID_LOAD_STATUS.grid3 = true;
            }

            if ((params_pool.pool_id && params_pool.pool_id != '' && grid_selected != 'pool') || (params_pool.pool_location_id && params_pool.pool_location_id != '' && grid_selected != 'pool')) {
                var params_pool = $.param(params_pool);
                var params_pool_url = js_data_collector_url + "&" + params_pool;

                flow_match.FlowPool.clearAndLoad(params_pool_url, function() {
                    GRID_LOAD_STATUS.grid4 = true;
                    fx_final_grid_load_callback();
                    flow_match.FlowPool.expandAll();
                });
            } else {
                GRID_LOAD_STATUS.grid4 = true;
                fx_final_grid_load_callback();
            }
        }
    }

    function show_zero_vol_top(status) {
        var params = {'sql' : 'EXEC spa_flow_optimization \'m\', DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, \''+ flow_date_from + '\', DEFAULT, \'' + receipt_loc_id + '\', DEFAULT, DEFAULT, DEFAULT, DEFAULT, \'' + process_id + '\', DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, \'' + flow_date_to + '\', DEFAULT, DEFAULT, DEFAULT, \'' + status + '\' '
        }
        params = $.param(params);
        var params_url = js_data_collector_url + "&" + params;
        flow_match.FlowReceipt.clearAndLoad(params_url);
    }

    function show_zero_vol_bottom(status) {
        var param = {'sql' : 'EXEC spa_flow_optimization \'n\', DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, \''+ flow_date_from + '\', DEFAULT, \'' + delivery_loc_id + '\', DEFAULT, DEFAULT, DEFAULT, DEFAULT, \'' + process_id + '\', DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, \'' + flow_date_to + '\', DEFAULT, DEFAULT, DEFAULT, \'' + status + '\' '
        }
        param = $.param(param);
        var param_url = js_data_collector_url + "&" + param;
        flow_match.FlowDelivery.clearAndLoad(param_url);
    }

    /**
     * open single match window operations
     * @id  string  id   call flag identifier eg. match, match_toggle
     *
     */
    function open_flow_match_popup(id) {
        var no_of_deals_category = 0
        var receipt_deals = '';
        var delivery_deals = '';
        var receipt_loc_id = '';
        var delivery_loc_id = '';
        var storage_loc_id = '';
        var pool_loc_id = '';
        var storage_type = '';
        var pool_type = '';

        var storage_loc_name = '';
        var pool_loc_name = '';
        var from_loc_id = '';
        var to_loc_id = '';
        var from_loc_name = '';
        var to_loc_name = '';

        var avail_vol_b = 0;
        var avail_vol_s = 0;
        var avail_vol_neg = 0;
        var total_receipt_vol = 0;
        var total_delivery_vol = 0;

        var flow_start = '';
        var flow_end = '';
        var proxy_location = false;
        if (call_from_ui != call_from_bookout_label) {
            proxy_location = flow_match.flow_optimization_form.isItemChecked('proxy_location');
        }

        var storage_volume = 0;
        var pool_volume = 0;

        var receipt_locations = '';
        var delivery_locations = '';
        var pool_deal_ids = '';
        var match_within_pool = false;
        var storage_contract = '';

        //for flow receipt up grid
        if (flow_match.FlowReceipt.getSelectedRowId() != null) {
            no_of_deals_category++;
        }

        if (flow_match.FlowDelivery.getSelectedRowId() != null) {
            no_of_deals_category++;
        }

        if (call_from_ui != call_from_bookout_label) {
            if (flow_match.FlowStorage.getSelectedRowId() != null) {
                no_of_deals_category++;
            }

            if (flow_match.FlowPool.getSelectedRowId() != null) {
                r_id = flow_match.FlowPool.getSelectedRowId().split(',');
                len = r_id.length;
                if (len > 1) {
                    for(i = 0; i < len; i++) {
                        var new_pool_loc_id = flow_match.FlowPool.cells(r_id[i], flow_match.FlowPool.getColIndexById('Location ID')).getValue();
                        if (pool_loc_id != '' && pool_loc_id != new_pool_loc_id) {
                            no_of_deals_category++;
                            match_within_pool = true;
                        } else if (pool_loc_id == '') {
                            no_of_deals_category++;
                            pool_loc_id = new_pool_loc_id;
                        } else {
                            pool_loc_id = new_pool_loc_id;
                        }
                    }
                } else {
                    no_of_deals_category++;
                }
            }
        }
        if (no_of_deals_category < 1) {
            show_messagebox("Deal selection not valid for match.");
            return;
        }

        unload_create_match_split_window();
        if (!create_match_split_window) {
            create_match_split_window = new dhtmlXWindows();
        }
        
        if (flow_match.FlowReceipt.getSelectedRowId() != null) {
            r_id = flow_match.FlowReceipt.getSelectedRowId().split(',');
            len = r_id.length;
            for (i = 0; i < len; i++) {
                var rec_proxy = flow_match.FlowReceipt.cells(r_id[i], flow_match.FlowReceipt.getColIndexById('Proxy Location ID')).getValue();
                var rec_proxy_id = rec_proxy;

                var deal_link = flow_match.FlowReceipt.cells(r_id[i], flow_match.FlowReceipt.getColIndexById('Deal ID')).getValue();

                xmlDoc = $.parseXML( deal_link ), $xml = $(xmlDoc), $title = $xml.find("u"); //takes deal id eg: 48858
                receipt_deals += $title.text();

                if (i != len - 1) {
                    receipt_deals += ',';
                }
                
                new_receipt_loc_id = flow_match.FlowReceipt.cells(r_id[i], flow_match.FlowReceipt.getColIndexById('Location ID')).getValue();

                from_loc_name = flow_match.FlowReceipt.cells(r_id[i], flow_match.FlowReceipt.getColIndexById('Location')).getValue();

                if (from_loc_name.lastIndexOf('[') != -1) {
                    from_loc_name = from_loc_name.substring(0, from_loc_name.lastIndexOf('['))
                }

                var rec_proxy_name = flow_match.FlowReceipt.cells(r_id[i], flow_match.FlowReceipt.getColIndexById('Proxy Location')).getValue();

                if (rec_proxy_name.lastIndexOf('[') != -1) {
                    rec_proxy_name = rec_proxy_name.substring(0, rec_proxy_name.lastIndexOf('['))
                }
                
                if (proxy_location) {
                    if (!rec_proxy_id) {
                        rec_proxy_id = new_receipt_loc_id
                        rec_proxy_name = from_loc_name;
                    }

                    if (receipt_loc_id != '' && receipt_loc_id != rec_proxy_id) {
                        show_messagebox("Deals from different receipt locations can not be selected.");
                        return;
                    } else {
                        receipt_loc_id = rec_proxy_id;
                        from_loc_id = receipt_loc_id;
                        from_loc_name = rec_proxy_name;
                    }
                } else {
                    if (receipt_loc_id != '' && receipt_loc_id != new_receipt_loc_id) {
                        show_messagebox("Deals from different receipt locations can not be selected.");
                        return;
                    } else {
                        receipt_loc_id = new_receipt_loc_id;
                        from_loc_id = receipt_loc_id;
                    }
                }

                avail_vol_b += parseInt(flow_match.FlowReceipt.cells(r_id[i], flow_match.FlowReceipt.getColIndexById('avail_vol')).getValue());
                new_flow_start = dates.convert_to_sql(flow_match.FlowReceipt.cells(r_id[i], flow_match.FlowReceipt.getColIndexById('Flow Start')).getValue());

                if (i == 0 || new_flow_start < flow_start ) {
                    flow_start = new_flow_start;
                }

                new_flow_end = dates.convert_to_sql(flow_match.FlowReceipt.cells(r_id[i],flow_match.FlowReceipt.getColIndexById('Flow End')).getValue());

                if (i == 0 || new_flow_end < flow_end) {
                    flow_end = new_flow_end;
                }

                total_receipt_vol += parseInt(flow_match.FlowReceipt.cells(r_id[i],flow_match.FlowReceipt.getColIndexById('Position')).getValue());
            }
        }

        // for flow delivery down grid
        if (flow_match.FlowDelivery.getSelectedRowId() != null) {
            r_id = flow_match.FlowDelivery.getSelectedRowId().split(',');
            len = r_id.length;

            for (i = 0; i < len; i++) {
                var del_proxy = flow_match.FlowDelivery.cells(r_id[i], flow_match.FlowDelivery.getColIndexById('Proxy Location ID')).getValue();
                var del_proxy_id = del_proxy;

                var deal_link = flow_match.FlowDelivery.cells(r_id[i], flow_match.FlowDelivery.getColIndexById('Deal ID')).getValue();
                xmlDoc = $.parseXML(deal_link), $xml = $(xmlDoc), $title = $xml.find( "u" );
                delivery_deals += $title.text();

                if (i != len - 1) delivery_deals += ',';

                new_delivery_loc_id = flow_match.FlowDelivery.cells(r_id[i], flow_match.FlowDelivery.getColIndexById('Location ID')).getValue();
                to_loc_name = flow_match.FlowDelivery.cells(r_id[i], flow_match.FlowDelivery.getColIndexById('Location')).getValue();

                if (to_loc_name.lastIndexOf('[') != -1) {
                    to_loc_name = to_loc_name.substring(0, to_loc_name.lastIndexOf('['))
                }

                var del_proxy_name = flow_match.FlowDelivery.cells(r_id[0], flow_match.FlowDelivery.getColIndexById('Proxy Location')).getValue();

                if (del_proxy_name.lastIndexOf('[') != -1) {
                    del_proxy_name = del_proxy_name.substring(0, del_proxy_name.lastIndexOf('['))
                }

                if (proxy_location) {
                    if (!del_proxy_id) {
                        del_proxy_id = new_delivery_loc_id;
                        del_proxy_name = to_loc_name;
                    }

                    if (delivery_loc_id != '' && delivery_loc_id != del_proxy_id) {
                        show_messagebox("Deals from different delivery locations can not be selected.");
                        return;
                    } else {
                        delivery_loc_id = del_proxy_id;
                        from_loc_id = delivery_loc_id;
                        to_loc_name = del_proxy_name;
                    }
                } else {
                    if (delivery_loc_id != '' && delivery_loc_id != new_delivery_loc_id) {
                        show_messagebox("Deals from different delivery locations can not be selected.");
                        return;
                    } else {
                        delivery_loc_id = new_delivery_loc_id;
                        to_loc_id = delivery_loc_id;
                    }
                }

                avail_vol_s += Math.abs(parseInt(flow_match.FlowDelivery.cells(r_id[i], flow_match.FlowDelivery.getColIndexById('avail_vol')).getValue()));
                avail_vol_neg += parseInt(flow_match.FlowDelivery.cells(r_id[i], flow_match.FlowDelivery.getColIndexById('avail_vol')).getValue());

                new_flow_start = dates.convert_to_sql(dates.convert(flow_match.FlowDelivery.cells(r_id[i], flow_match.FlowDelivery.getColIndexById('Flow Start')).getValue()));
                new_flow_end = dates.convert_to_sql(flow_match.FlowDelivery.cells(r_id[i], flow_match.FlowDelivery.getColIndexById('Flow End')).getValue());

                if (flow_start != '') {
                    if (i == 0 || new_flow_start < flow_start ) {
                        flow_start = new_flow_start;
                    }

                    if (i == 0 || new_flow_end < flow_end) {
                        flow_end = new_flow_end;
                    }
                } else {
                    flow_start = new_flow_start;
                    flow_end = new_flow_end;
                }

                var uom = flow_match.FlowDelivery.cells(r_id[i],flow_match.FlowDelivery.getColIndexById('UOM')).getValue();
                total_delivery_vol += parseInt(flow_match.FlowDelivery.cells(r_id[i],flow_match.FlowDelivery.getColIndexById('Position')).getValue());
            }
        }
        
        if (call_from_ui != call_from_bookout_label) {
            // for flow storage down grid
            if (flow_match.FlowStorage.getSelectedRowId() != null) {
                r_id = flow_match.FlowStorage.getSelectedRowId().split(',');
                len = r_id.length;

                for (i = 0; i < len; i++) {

                    new_storage_loc_id = flow_match.FlowStorage.cells(r_id[i],flow_match.FlowStorage.getColIndexById('location_id')).getValue();
                    storage_loc_name = flow_match.FlowStorage.cells(r_id[i], flow_match.FlowStorage.getColIndexById('Location')).getValue();
                    storage_contract = flow_match.FlowStorage.cells(r_id[i], flow_match.FlowStorage.getColIndexById('Contract')).getValue();
                    storage_volume += parseInt(flow_match.FlowStorage.cells(r_id[i], flow_match.FlowStorage.getColIndexById('Inventory Volume')).getValue());
                    if (storage_loc_name.lastIndexOf('[') != -1) {
                        storage_loc_name = from_loc_name.substring(0, storage_loc_name.lastIndexOf('['))
                    }

                    if (storage_loc_id != '' && storage_loc_id != new_storage_loc_id) {
                        show_messagebox("Different Storage locations can not be selected.");
                        return;
                    } else {
                        storage_loc_id = new_storage_loc_id;
                    }
                }

                if (receipt_loc_id != '') {
                    storage_type = 'i';

                } else {
                    storage_type = 'w';
                }

            }

            if (flow_match.FlowPool.getSelectedRowId() != null) {
                r_id = flow_match.FlowPool.getSelectedRowId().split(',');
                len = r_id.length;
                var array_pool_receipt_delivery = {};
                array_pool_receipt_delivery[0] = {};
                array_pool_receipt_delivery[1] = {};
                var pool_count = 0;

                if (match_within_pool) {

                    for(i = 0; i < len; i++) {
                        var new_pool_loc_id = flow_match.FlowPool.cells(r_id[i],flow_match.FlowPool.getColIndexById('Location ID')).getValue();
                        pool_loc_name = flow_match.FlowPool.cells(r_id[i], flow_match.FlowPool.getColIndexById('Location Type')).getValue();
                        var link_pool_volume = flow_match.FlowPool.cells(r_id[i], flow_match.FlowPool.getColIndexById('Volume')).getValue();
                        var link_pool_volume_value = $('<div>').append(link_pool_volume).find('a:first').text();
                        if (!link_pool_volume_value || link_pool_volume_value == '')
                            link_pool_volume_value = 0;
                        if (pool_loc_id != '' && pool_loc_id != new_pool_loc_id) {
                            pool_volume = 0;
                            pool_count = 1;
                        } else {
                            pool_loc_id = new_pool_loc_id;
                        }
                        pool_volume += parseInt(link_pool_volume_value);
                        pool_deal_ids = flow_match.FlowPool.cells(r_id[i], flow_match.FlowPool.getColIndexById('deal_id')).getValue();
                        if (pool_loc_name.lastIndexOf('[') != -1) {
                            pool_loc_name = from_loc_name.substring(0, pool_loc_name.lastIndexOf('['))
                        }
                        new_flow_start = dates.convert_to_sql(dates.convert(flow_match.FlowPool.cells(r_id[i],flow_match.FlowPool.getColIndexById('Flow Start')).getValue()));
                        new_flow_end = dates.convert_to_sql(flow_match.FlowPool.cells(r_id[i],flow_match.FlowPool.getColIndexById('Flow End')).getValue());
                        if (flow_start != '') {
                            if (i == 0 || new_flow_start < flow_start ) {
                                flow_start = new_flow_start;
                            }

                            if (i == 0 || new_flow_end < flow_end) {
                                flow_end = new_flow_end;
                            }
                        } else {
                            flow_start = new_flow_start;
                            flow_end = new_flow_end;
                        }

                        array_pool_receipt_delivery[pool_count].location_id = new_pool_loc_id;
                        array_pool_receipt_delivery[pool_count].location_name = pool_loc_name;
                        array_pool_receipt_delivery[pool_count].volume = pool_volume;
                        array_pool_receipt_delivery[pool_count].pool_deal_ids = pool_deal_ids;
                    }

                    if ((!array_pool_receipt_delivery[0].pool_deal_ids && array_pool_receipt_delivery[0].pool_deal_ids == '') && (!array_pool_receipt_delivery[1].pool_deal_ids && array_pool_receipt_delivery[1].pool_deal_ids == '')) {
                        show_messagebox("Deal selection not valid for match.");
                        return;
                    }

                    if (array_pool_receipt_delivery[0].volume > array_pool_receipt_delivery[1].volume) {
                        receipt_loc_id = array_pool_receipt_delivery[0].location_id;
                        from_loc_name = array_pool_receipt_delivery[0].location_name;
                        total_receipt_vol = array_pool_receipt_delivery[0].volume;
                        delivery_loc_id = array_pool_receipt_delivery[1].location_id;
                        to_loc_name = array_pool_receipt_delivery[1].location_name;
                        total_delivery_vol = array_pool_receipt_delivery[1].volume;
                    } else {
                        receipt_loc_id = array_pool_receipt_delivery[1].location_id;
                        from_loc_name = array_pool_receipt_delivery[1].location_name;
                        total_receipt_vol = array_pool_receipt_delivery[1].volume;
                        delivery_loc_id = array_pool_receipt_delivery[0].location_id;
                        to_loc_name = array_pool_receipt_delivery[0].location_name;
                        total_delivery_vol = array_pool_receipt_delivery[0].volume;
                    }

                } else {
                    for(i = 0; i < len; i++) {
                        var pool_loc_id = flow_match.FlowPool.cells(r_id[i],flow_match.FlowPool.getColIndexById('Location ID')).getValue();
                        pool_loc_name = flow_match.FlowPool.cells(r_id[i], flow_match.FlowPool.getColIndexById('Location Type')).getValue();
                        var link_pool_volume = flow_match.FlowPool.cells(r_id[i], flow_match.FlowPool.getColIndexById('Volume')).getValue();
                        var link_pool_volume_value = $('<div>').append(link_pool_volume).find('a:first').text();
                        if (!link_pool_volume_value || link_pool_volume_value == '')
                            link_pool_volume_value = 0;
                        pool_volume += parseInt(link_pool_volume_value);
                        pool_deal_ids = flow_match.FlowPool.cells(r_id[i], flow_match.FlowPool.getColIndexById('deal_id')).getValue();
                        if (pool_loc_name.lastIndexOf('[') != -1) {
                            pool_loc_name = from_loc_name.substring(0, pool_loc_name.lastIndexOf('['))
                        }
                        new_flow_start = dates.convert_to_sql(dates.convert(flow_match.FlowPool.cells(r_id[i],flow_match.FlowPool.getColIndexById('Flow Start')).getValue()));
                        new_flow_end = dates.convert_to_sql(flow_match.FlowPool.cells(r_id[i],flow_match.FlowPool.getColIndexById('Flow End')).getValue());
                        if (flow_start != '') {
                            if (i == 0 || new_flow_start < flow_start ) {
                                flow_start = new_flow_start;
                            }

                            if (i == 0 || new_flow_end < flow_end) {
                                flow_end = new_flow_end;
                            }
                        } else {
                            flow_start = new_flow_start;
                            flow_end = new_flow_end;
                        }
                    }
                    if (receipt_loc_id != '') {
                        pool_type = 'i';
                    } else if (pool_volume != '' && storage_volume != ''){
                        if (parseInt(pool_volume) > 0 && parseInt(pool_volume) > parseInt(storage_volume))
                            pool_type = 'i';
                        else
                            pool_type = 'w';
                    } else {
                        pool_type = 'w';
                    }
                }
            }
        }
        if (storage_type != '' && pool_type != '') {
            /* Condition when zero scheduling is selected in pool and storage grid */
            if ((!storage_contract || storage_contract == '') && (!pool_deal_ids || pool_deal_ids == '')) {
                show_messagebox("Deal selection not valid for match.");
                return;
            }

            if (pool_type == 'i') {
                from_loc_id = pool_loc_id;
                receipt_loc = pool_loc_name;
                to_loc_id = storage_loc_id;
                to_loc_name = storage_loc_name;
                receipt_deals = pool_deal_ids;
                total_receipt_vol = pool_volume;
                total_delivery_vol = storage_volume;

            } else if (pool_type == 'w') {
                to_loc_id = pool_loc_id;
                delivery_loc = pool_loc_name;
                from_loc_id = storage_loc_id;
                from_loc_name = storage_loc_name;
                delivery_deals = pool_deal_ids;
                total_receipt_vol = storage_volume;
                total_delivery_vol = pool_volume;
            }
        } else if (pool_type == 'i') {
            from_loc_id = receipt_loc_id;
            receipt_loc = from_loc_name;
            to_loc_id = pool_loc_id;
            to_loc_name = pool_loc_name;
            total_delivery_vol = pool_volume;
            delivery_deals = pool_deal_ids;
        } else if (pool_type == 'w') {
            to_loc_id = delivery_loc_id;
            delivery_loc = to_loc_name;
            from_loc_id = pool_loc_id;
            from_loc_name = pool_loc_name;
            total_receipt_vol = pool_volume;
            receipt_deals = pool_deal_ids;

        } else if (storage_type == 'i') {
            from_loc_id = receipt_loc_id;
            receipt_loc = from_loc_name;
            to_loc_id = storage_loc_id;
            to_loc_name = storage_loc_name;
            total_delivery_vol = storage_volume;

        } else if (storage_type == 'w') {
            to_loc_id = delivery_loc_id;
            delivery_loc = to_loc_name;
            from_loc_id = storage_loc_id;
            from_loc_name = storage_loc_name;
            total_receipt_vol = storage_volume;
        } else {
            from_loc_id = receipt_loc_id;
            to_loc_id = delivery_loc_id;
            delivery_loc = to_loc_name;
            receipt_loc = from_loc_name;
        }

        var path_info = '';
        var check_proxy = 'y';
        if (!proxy_location) {
            check_proxy = 'n';
        }
        
        var combo_data = {"action": "spa_delivery_path", "flag": "s", "from_location": from_loc_id, "to_location": to_loc_id, "check_proxy": check_proxy};
        
        $.ajax({
            type: "POST",
            dataType: "json",
            url: js_form_process_url,
            async: true,
            data: combo_data,
            success: function(result1) {
                response_data = result1['json'];
                path_info = JSON.stringify(response_data);
                path_info = (JSON.parse(path_info));
                if (path_info.length == 0) {
                    var message = 'Delivery Path do not exist between selected locations. Click Ok to add delivery path.';
                    confirm_messagebox(message, function() {
                        fx_open_delivery_path_window(from_loc_id, to_loc_id, from_loc_name, to_loc_name);
                    });
                } else {
                    if (id == 'match' || id == 'match_toggle') {
                        if (call_from_bookout_label != call_from_ui) {
                            var contract_obj = flow_match.flow_optimization_form.getCombo('contract');
                            var contract_id = contract_obj.getChecked();
                            var contract_ids = (contract_id.join() && contract_id.join() != '') ? contract_id.join():"NULL";
                            var filter_subsidiary_id = flow_match.flow_optimization_form.getItemValue('subsidiary_id');
                            var filter_strategy_id = flow_match.flow_optimization_form.getItemValue('strategy_id');
                            var filter_book_id = flow_match.flow_optimization_form.getItemValue('book_id');
                            var filter_sub_book_id = flow_match.flow_optimization_form.getItemValue('subbook_id');
                            var volume_conversion = flow_match.flow_optimization_form.getItemValue('volume_conversion');
                        } else {
                            var contract_ids = selected_contract_id;
                            var filter_subsidiary_id = subsidiary_id;
                            var filter_strategy_id = strategy_id;
                            var filter_book_id = book_id;
                            var filter_sub_book_id = sub_book_id;
                            var volume_conversion = '';
                        }
                        var reschedule = 0; //No reschedule logic exists, hence set as 0.
                        
                        if (id == 'match_toggle') {
                            new_win.close();
                        }

                        var check_min_vol = 1;
						if (pool_type || storage_type) {
							check_min_vol = 0;
						}
						
                        //new_win = create_match_split_window.createWindow('w1', 0, 0, 680, 300);
                        var new_win = create_match_split_window.createWindow({
                            id: 'window_match'
                            ,width: 700 //1250
                            ,height: 270 //500
                            ,modal: true
                            ,resize: false
                            ,text: 'Match'
                            ,center: true
                            ,maximize: true
                            ,move: false
                        });
                        var toggle = (id == 'match') ? 'n' : 'y';
                        
                        //when call from match click of flow optimization, selected path id is set to one path_id from results of flag c call comparing from and to locations
                        if (call_from_ui == 'match') {
                            var path_id = $(FLAG_C_RESULT_DATA).map(function(k, v) {
                                if (v.from_loc_id == from_loc_id && v.to_loc_id == to_loc_id) {
                                    return v.path_exists;
                                }
                            }).get()[0];
                            selected_path_id = (path_id ? path_id : '' );
                        }
                        var args_hourly = {
                            process_id: FLAG_C_PROCESS_ID
                            ,flow_start: flow_start
                            ,flow_end: flow_end
                            ,box_id: box_id
                            ,uom: volume_conversion
                            ,receipt_loc_id: from_loc_id
                            ,delivery_loc_id: to_loc_id
                            ,storage_type: storage_type
                            ,selected_path_id: selected_path_id
                            ,period_from: '7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,1,2,3,4,5,6'
                            ,toggle: toggle
                            ,receipt_deals: receipt_deals
                            ,delivery_deals: delivery_deals
                            ,granularity: 982 //hourly
                            ,call_from: 'flow_deal_match'
                        };
                        var args_daily = {
                            flow_start: flow_start
                            ,flow_end: flow_end
                            ,receipt_loc: receipt_loc
                            ,delivery_loc: delivery_loc
                            ,receipt_loc_id: from_loc_id
                            ,delivery_loc_id: to_loc_id
                            ,uom: volume_conversion
                            ,total_receipt_vol: total_receipt_vol
                            ,total_delivery_vol: total_delivery_vol
                            ,process_id: FLAG_C_PROCESS_ID
                            ,receipt_deals: receipt_deals
                            ,delivery_deals: delivery_deals
                            ,avail_vol: (check_min_vol ? ((avail_vol_b < avail_vol_s) ? avail_vol_b : avail_vol_neg) : avail_vol_b)
                            ,min_rec_or_del_vol: ((avail_vol_b < avail_vol_s) ? 'receipt' : 'delivery') 
                            ,storage_loc_id: storage_loc_id
                            ,storage_type: storage_type
                            ,pool_loc_id: pool_loc_id
                            ,pool_type: pool_type
                            ,from_loc_name: from_loc_name
                            ,to_loc_name: to_loc_name
                            ,toggle: toggle
                            ,contract_id: contract_ids
                            ,subsidiary_id: filter_subsidiary_id
                            ,strategy_id: filter_strategy_id
                            ,book_id: filter_book_id
                            ,sub_book_id: filter_sub_book_id
                            ,reschedule: reschedule
                            ,granularity: 981 //daily
							,call_from: call_from_ui

                        };
                        //console.log(args);return;
                        //alert(schedule_granularity);
                        //schedule_granularity=982;
                        var url = app_form_path  + '_scheduling_delivery/gas/flow_optimization/single.match.php?' +  $.param(args_daily);
                        
                        if (schedule_granularity == 982) {//hourly
                            new_win.allowResize();
                            new_win.maximize();
                            new_win.denyResize();
							url = app_form_path  + '_scheduling_delivery/gas/flow_optimization/hourly.scheduling.php?' +  $.param(args_hourly);
                        }
                        
                        //new_win.progressOn();
                        new_win.attachURL(url, false, true);
                    } else {
                        var new_win = create_match_split_window.createWindow('w2', 0, 0, 610, 400);
                        if (call_from_ui != call_from_bookout_label) {
                            var volume_conversion = flow_match.flow_optimization_form.getItemValue('volume_conversion');
                        } else {
                            var volume_conversion = '';
                        }
						var b2b = <?php echo $b2b;?>;
                        param = '?process_id=' + process_id +
                            '&flow_start=' + flow_start +
                            '&flow_end=' + flow_end +
                            '&box_id=' + box_id +
                            '&uom=' + volume_conversion +
                            '&receipt_loc=' + receipt_loc +
                            '&delivery_loc=' + delivery_loc +
                            '&receipt_loc_id=' + from_loc_id +
                            '&delivery_loc_id=' + to_loc_id +
                            '&from_loc_grp_name=' + from_loc_grp_name +
                            '&to_loc_grp_name=' + to_loc_grp_name +
                            '&selected_path_id=' + selected_path_id +
                            '&selected_contract_id=' + selected_contract_id +
                            '&selected_storage_asset_id=' + selected_storage_asset_id +
                            '&selected_storage_checked=' + selected_storage_checked +
                            '&receipt_deals=' + receipt_deals +
                            '&delivery_deals=' + delivery_deals +
                            '&avail_vol=' + ((avail_vol_b < avail_vol_s) ? avail_vol_b : avail_vol_neg) +
                            '&total_receipt_vol=' + total_receipt_vol +
                            '&total_delivery_vol=' + total_delivery_vol +
                            '&process_id=' + process_id +
                            '&min_rec_or_del_vol=' + ((avail_vol_b < avail_vol_s) ? 'receipt' : 'delivery') +
                            '&storage_loc_id=' + storage_loc_id +
                            '&storage_type=' + storage_type+
                            '&pool_type=' + pool_type+
                            '&pool_loc_id=' + pool_loc_id +
                            '&from_loc_name=' + from_loc_name+
                            '&to_loc_name=' + to_loc_name +
							'&call_from=' + ((b2b) ? 'opt_book_out_b2b' : call_from_ui);

                        ;

                        var url = app_form_path  +  '_scheduling_delivery/gas/flow_optimization/match.php' + param;
                        new_win.setText("Multi Match");
                        new_win.centerOnScreen();
                        new_win.setModal(true);
                        new_win.maximize();
                        new_win.attachURL(url, false, true);

                        new_win.attachEvent('onClose', function(win) {
                            //process_id = Math.random().toString(36).substring(7);
                            refresh('refresh_all');
                            if (new_win_report && new_win_report != undefined && new_win_report != '') {
                                new_win_report.close();
                                load_position_report();
                            }
                            return true;
                        });
                    }
                }
            }
        });
    }
    
    function fx_open_delivery_path_window(from_loc_id, to_loc_id, from_loc_name, to_loc_name,popup_call_from) {
        if (popup_call_from == 'single_match_toggle') {
            var args = '?call_from=flow_optimization_toggle&mode=i&from_loc_id=' + from_loc_id + '&to_loc_id=' + to_loc_id + '&from_loc=' + from_loc_name + '&to_loc=' + to_loc_name;
        } else {
            var args = '?call_from=flow_optimization&mode=i&from_loc_id=' + from_loc_id + '&to_loc_id=' + to_loc_id + '&from_loc=' + from_loc_name + '&to_loc=' + to_loc_name;
        }
        // open_menu_window("_scheduling_delivery/gas/Setup_Delivery_Path/Setup.Delivery.Path.php" + args, "windowSetupDeliveryPath", "Setup Delivery Path")
        var param = "../Setup_Delivery_Path/Setup.Delivery.Path.php" + args

        var win = new dhtmlXWindows();
        setup_delivery_path_win = win.createWindow("windowSetupDeliveryPath", 0, 0, 400, 400);
        setup_delivery_path_win.setText("Setup Delivery Path");
        setup_delivery_path_win.setModal(true);
        setup_delivery_path_win.maximize();
        setup_delivery_path_win.attachURL(param, false, true);
    }

    var create_match_split_window;

    function SetupDeliveryPath_SaveCallback(id) {
        setup_delivery_path_win.close();
        open_flow_match_popup(id);
    };

    function single_match_save_callback () {
        create_match_split_window.window('window_match').close();
        process_id = Math.random().toString(36).substring(7);
        refresh('refresh_all');
		if(call_from_ui == 'book_out') {
			if(typeof parent.refresh_book_out_list === "function") {
				parent.refresh_book_out_list('list_refresh_b2b', receipt_loc_id);
			}
		}
        if (new_win_report && new_win_report != undefined && new_win_report != '') {
            new_win_report.close();
            load_position_report();
        }
    };

    function unload_create_match_split_window() {
        if (create_match_split_window != null && create_match_split_window.unload != null) {
            create_match_split_window.unload();
            create_match_split_window = w2 = null;
        }
    }

    function fx_position_report(std_report_url) {
        open_spa_html_window('Optimizer Position Detail', std_report_url, 600, 1200);
    }

    function uniq(arr) {
        var prims = {"boolean":{}, "number":{}, "string":{}}, objs = [];

        return arr.filter(function(item) {
            var type = typeof item;
            if(type in prims)
                return prims[type].hasOwnProperty(item) ? false : (prims[type][item] = true);
            else
                return objs.indexOf(item) >= 0 ? false : objs.push(item);
        });
    }

    flow_match.fx_close_window = function (window_id) {
        create_match_split_window.window(window_id).close();
    };
</script>