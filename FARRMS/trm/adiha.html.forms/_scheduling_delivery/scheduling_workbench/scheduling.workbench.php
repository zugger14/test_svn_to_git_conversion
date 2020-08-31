<?php
/**
* Scheduling workbench screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
<style>

.xhdr,.objbox {
    width: auto !important;
}

.gridbox_dhx_web {
    width: 100% !important;
}


</style>
<body>
<?php

    $form_namespace = 'ns_scheduling_workbench';

    $rights_scheduling_workbench = 10163700;
    $rights_scheduling_workbench_UI = 10163710;
    $rights_scheduling_workbench_del = 10163711;
    $rights_split_unsplit_UI = 10163720;
    $rights_create_receipt_delivery_deal = 10163730;
    $rights_match_split = 10163740;
    $rights_create_begining_storage_deal = 10163750;
    $rights_inject_into_storage = 10163782;
    $rights_inject_into_pool = 10163789;
    $rights_unmatch = 10163752;
    $rights_lock_unlock = 10163788;
    $rights_inventory_adjustment = 10163790;

list (
    $has_rights_scheduling_workbench,
    $has_rights_scheduling_workbench_UI,
    $has_rights_scheduling_workbench_del,
    $has_rights_split_unsplit_UI,
    $has_rights_create_receipt_delivery_deal,
    $has_rights_match_split,
    $has_rights_create_begining_storage_deal,
    $has_rights_inject_into_storage,
    $has_rights_inject_into_pool,
    $has_rights_unmatch,
    $has_rights_create_begining_storage_deal,
    $has_rights_lock_unlock,
    $has_rights_inventory_adjustment
) = build_security_rights (
    $rights_scheduling_workbench,
    $rights_scheduling_workbench_UI,
    $rights_scheduling_workbench_del,
    $rights_split_unsplit_UI,
    $rights_create_receipt_delivery_deal,
    $rights_match_split,
    $rights_create_begining_storage_deal,
    $rights_inject_into_storage,
    $rights_inject_into_pool,
    $rights_unmatch,
    $rights_create_begining_storage_deal,
    $rights_lock_unlock,
    $rights_inventory_adjustment
);

$has_rights_split_unsplit_UI = ($has_rights_split_unsplit_UI == '') ? 'false': 'true';
$has_rights_create_receipt_delivery_deal = ($has_rights_create_receipt_delivery_deal == '') ? 'false' : 'true';

$xml_user = "EXEC spa_get_regions @user_login_id= '" . $app_user_name . "'";
$def = readXMLURL2($xml_user);
$date_format = $def[0]['date_format'];
$date_format = str_replace('yyyy', '%Y', str_replace('dd', '%d', str_replace('mm', '%m', $date_format)));

$product_type = 1;//fungible         

$date_format_1 = 'Y-m-d';
$term_start = date($date_format_1);

$layout_json = '[
    {id: "a", text: "Apply Filter", header: true, collapse: true, height: 85},
    {id: "b", text: "Filter", header: true, height: 155},
    {id: "c", text: "Grids", header:true, height: 275},
    {id: "d", text: "<a class=\"undock_a undock-btn undock_custom\" style=\"float: right; cursor:pointer\" title=\"Undock\"  onClick=\" undock_window_match();\"></a>Matches"}
]';

$layout_obj = new AdihaLayout();
echo $layout_obj -> init_layout('deal_layout', '', '4E', $layout_json, $form_namespace);
echo $layout_obj -> attach_event('', 'onDock', $form_namespace . '.on_dock_event');
echo $layout_obj -> attach_event('', 'onUnDock', $form_namespace . '.on_undock_event');


// attach Menu
echo $layout_obj->attach_menu_cell('deal_menu', 'c');
$menu_object = new AdihaMenu();

$menu_json = '[
    {id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif", title: "Refresh"},
    {id:"t3", text:"Process", img:"action.gif", items:[
        {id:"bookout", text:"Bookout", img:"bookout.gif", imgdis:"bookout_dis.gif", title: "Bookout", enabled:false},
        {id:"match", text:"Match", img:"match.gif", imgdis:"match_dis.gif", title: "Match", enabled:false}
    ]},
    {id:"save", text:"Save", img:"save.gif", imgdis:"save_dis.gif", title: "Save"},
    {id:"export", text:"Export", img:"export.gif", items:[
        {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel Receipt"},
        {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF Receipt"},
        {id:"excel1", text:"Excel1", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel Delivery"},
        {id:"pdf1", text:"PDF1", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF Delivery"}
    ]}
]';

echo $menu_object->init_by_attach('deal_menu', $form_namespace);
echo $menu_object->load_menu($menu_json);
echo $menu_object->attach_event('', 'onClick', $form_namespace . '.deal_menu_click');


$layout_json_grids = '[
    {id: "a", text: "Receipts", header: true, undock: true},
    {id: "b", text: "Deliveries", header:true, undock: true}
]';

$inner_layout_obj = new AdihaLayout();
echo $layout_obj->attach_layout_cell("rec_del_grids", 'c', '2U', $layout_json_grids);
echo $inner_layout_obj->init_by_attach('rec_del_grids', $form_namespace);

//attach reciept grid
$receipt_deals_grid_name = 'receipts_deals';
echo $inner_layout_obj -> attach_grid_cell($receipt_deals_grid_name, 'a');

$rec_grid_obj = new GridTable('ReceiptsDeals');
echo $rec_grid_obj -> init_grid_table($receipt_deals_grid_name, $form_namespace, 'n');
echo $rec_grid_obj -> set_column_auto_size();
echo $rec_grid_obj -> set_search_filter(true, "");
echo $rec_grid_obj -> enable_column_move();
echo $rec_grid_obj -> enable_multi_select();
echo $rec_grid_obj -> split_grid('1');
echo $rec_grid_obj -> return_init();
echo $rec_grid_obj -> enable_header_menu();
            echo $rec_grid_obj -> enable_filter_auto_hide();
echo $rec_grid_obj -> attach_event('', 'onSelectStateChanged', $form_namespace . '.receipt_deal_deals_row_selection');

//add context menu
$context_menu_rec = new AdihaMenu();
$context_menu_json_rec = '[{id:"split", text:"Split", img:"split.gif", imgdis:"split_dis.gif", title: "Split", enabled:"'.$has_rights_split_unsplit_UI.'"},
    {id:"unsplit", text:"Unsplit", img:"unsplit.gif", imgdis:"unsplit_dis.gif", title: "Unsplit", enabled:"'.$has_rights_split_unsplit_UI.'"},
    {id:"injection_rec", text:"Inject into Storage", img:"injection_deal.gif", imgdis:"injection_deal_dis.gif", title: "Inject into Storage", enabled:"'.$has_rights_inject_into_storage.'"},
    {id:"injection_pipeline", text:"Inject into Pipeline", img:"injection_deal.gif", imgdis:"injection_deal_dis.gif", title: "Inject into Pipeline", enabled:"'.$has_rights_inject_into_pool.'"}
]';
echo $context_menu_rec -> init_menu('context_menu_rec', $form_namespace);
echo $context_menu_rec -> render_as_context_menu();
echo $context_menu_rec -> attach_event('', 'onClick', 'context_menu_rec_click');
echo $context_menu_rec -> load_menu($context_menu_json_rec);
echo $rec_grid_obj -> enable_context_menu($form_namespace .'.context_menu_rec');

//attach delivery grid
$delivery_deals_grid_name = 'delivery_deals';
echo $inner_layout_obj->attach_grid_cell($delivery_deals_grid_name, 'b');

$del_grid_obj = new GridTable('DeliveryDeals');
echo $del_grid_obj -> init_grid_table($delivery_deals_grid_name, $form_namespace, 'n');
echo $del_grid_obj -> set_column_auto_size();
echo $del_grid_obj -> set_search_filter(true, '');
echo $del_grid_obj -> enable_column_move();
echo $del_grid_obj -> enable_multi_select();
echo $del_grid_obj -> split_grid('1');
echo $del_grid_obj -> return_init();
echo $del_grid_obj -> enable_header_menu();
            echo $del_grid_obj -> enable_filter_auto_hide();
echo $del_grid_obj -> attach_event('', 'onSelectStateChanged', $form_namespace . '.receipt_deal_deals_row_selection');

//ADD CONTEXT MENU DEL
$context_menu_del = new AdihaMenu();
$context_menu_json_del = '[
    {id:"split", text:"Split", img:"split.gif", imgdis:"split_dis.gif", title: "Split", enabled:"'.$has_rights_split_unsplit_UI.'"},
    {id:"unsplit", text:"Unsplit", img:"unsplit.gif", imgdis:"unsplit_dis.gif", title: "Unsplit", enabled:"'.$has_rights_split_unsplit_UI.'"},
    {id:"injection_del", text:"Withdraw From Storage", img:"injection_deal.gif", imgdis:"injection_deal_dis.gif", title: "Withdraw From Storage", enabled:"'.$has_rights_inject_into_storage.'"},
    {id:"withdrawal_pipeline", text:"Withdraw From Pipeline", img:"injection_deal.gif", imgdis:"injection_deal_dis.gif", title: "Withdraw From Pipeline", enabled:"'.$has_rights_inject_into_pool.'"} 
]';
echo $context_menu_del -> init_menu('context_menu_del', $form_namespace);
echo $context_menu_del -> render_as_context_menu();
echo $context_menu_del -> attach_event('', 'onClick', 'context_menu_del_click');
echo $context_menu_del -> load_menu($context_menu_json_del);
echo $del_grid_obj -> enable_context_menu($form_namespace .'.context_menu_del');

//tab creation
$tab_json = '[
    {id: "a1", text: "Storage Report", active: "true"},
    {id: "a2", text: "Match"}
]';
echo $layout_obj -> attach_tab_cell('report_match_tab', 'd', $tab_json);

//bookout match menu

//bookout_match grid
$tab_obj = new AdihaTab();
$tab_obj->init_by_attach('report_match_tab', $form_namespace);
echo $tab_obj-> set_tab_mode('bottom');

echo $tab_obj -> attach_event('', 'onTabClick', $form_namespace.'.tab_click');

echo $tab_obj->attach_menu_cell('location_storage_menu', 'a1');
$location_storage_menu_object = new AdihaMenu();
$menu_json = '[{id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif", title: "Refresh"},
    {id:"export", text:"Export", img:"export.gif", items:[
        {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
        {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
            ]} ]';
echo $location_storage_menu_object -> init_by_attach('location_storage_menu', $form_namespace);
echo $location_storage_menu_object -> load_menu($menu_json);
echo $location_storage_menu_object -> attach_event('', 'onClick', $form_namespace . '.location_storage_menu_click');

$location_storage_grid_name = 'location_storage';
echo $tab_obj->attach_grid_cell($location_storage_grid_name, 'a1');
$location_storage_grid_obj = new GridTable('StoragePosition');
echo $location_storage_grid_obj -> init_grid_table($location_storage_grid_name, $form_namespace, 'n');
echo $location_storage_grid_obj -> set_column_auto_size();
echo $location_storage_grid_obj -> set_search_filter(true, '');
echo $location_storage_grid_obj -> enable_column_move();
echo $location_storage_grid_obj -> enable_multi_select();
// splitted grid at 5, because upto Purchase Deal Sub Type, the grid columns are hidden
// if the next column after the splitted column is hidden then column height becomes un-uniform.
// Note: Hiding the contract column will show un-uniform column header heights.
echo $location_storage_grid_obj -> split_grid(5);
echo $location_storage_grid_obj -> return_init();
echo $location_storage_grid_obj -> enable_header_menu();
            echo $location_storage_grid_obj -> enable_filter_auto_hide();
echo $location_storage_grid_obj -> attach_event('', 'onRowDblClicked', $form_namespace . '.location_storage_row_dbl_click');
echo $location_storage_grid_obj -> attach_event('', 'onSelectStateChanged', $form_namespace . '.location_storage_grid_row_selection');



//ADD CONTEXT storage grid
$context_menu_ls = new AdihaMenu();
$context_menu_json_ls = '[
      
                 {id:"injection_storage", text:"Inject into Storage", img:"injection_deal.gif", imgdis:"injection_deal_dis.gif", title: "Inject into Storage", enabled:"'.$has_rights_inject_into_storage.'"},                 
                 {id:"inventory_adjustment", text:"Inventory Adjustment", img:"injection_deal.gif", imgdis:"injection_deal_dis.gif", title: "Create Inventory Adjustment", enabled:"'.$has_rights_inventory_adjustment.'"}
 ]';
echo $context_menu_ls -> init_menu('context_menu_ls', $form_namespace);
echo $context_menu_ls -> render_as_context_menu();
echo $context_menu_ls -> attach_event('', 'onClick', 'context_menu_ls_click');
echo $context_menu_ls -> load_menu($context_menu_json_ls);
echo $location_storage_grid_obj -> enable_context_menu($form_namespace .'.context_menu_ls');

echo $tab_obj -> attach_menu_cell('bookout_match_menu', 'a2');
$menu_object = new AdihaMenu();

$menu_json = '[
    {id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif", title: "Refresh"},
        {id:"action", text:"Actions", img:"action.gif", items:[
    {id:"remove_bookout", text:"Unmatch", img:"unmatch.gif", imgdis:"unmatch_dis.gif", title: "Unmatch", enabled:false} ,
            {id:"lock_bookout", text:"Lock", img:"lock.gif", imgdis:"lock_dis.gif", title: "Lock", enabled:false},
            {id:"unlock_bookout", text:"Unlock", img:"unlock.gif", imgdis:"unlock_dis.gif", title: "Unlock", enabled:false}
        ]},                    
    {id:"export", text:"Export", img:"export.gif", items:[
        {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
        {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
    ]},
    {id:"report", text:"Reports", img:"report.gif", items:[
        {id:"workflow_status", text:"Workflow Status", img:"update_invoice_stat.gif", imgdis:"update_invoice_stat_dis.gif", title: "Workflow Status"},
        {id:"shipping_doc_control", text:"Shipping Document Control", img:"change_deal_status.gif", imgdis:"change_deal_status_dis.gif", title: "Shipping Document Control"},
        {id:"scheduling_report", text:"Scheduling Match Detail Report", img:"report.gif", imgdis:"report_dis.gif", title: "Scheduling Match Detail Report", enabled:true}
    ]}
]';
echo $menu_object -> init_by_attach('bookout_match_menu', $form_namespace);
echo $menu_object -> load_menu($menu_json);
echo $menu_object -> attach_event('', 'onClick', $form_namespace . '.bookout_match_menu_click');

// Attach bookout match grids
$grid_obj = new AdihaGrid();
// match group shipment
$xml_file = "EXEC spa_adiha_grid 's','MatchGroupShipment'";
$resultset_hg = readXMLURL2($xml_file);
$hg_col_array = explode(',', $resultset_hg[0]['column_width']);
$total_hg_width = array_sum($hg_col_array);
$grid_json_definition_hg = json_encode($resultset_hg);
$enable_header_menu = 'true';

for($i = 1; $i < count($hg_col_array); $i++) {
    $enable_header_menu .= ',' . 'true';
}

// Match group header
$xml_file = "EXEC spa_adiha_grid 's','MatchGroupHeader'";
$resultset_hgd = readXMLURL2($xml_file);
$hgd_col_array = explode(',', $resultset_hgd[0]['column_width']);
$total_hgd_width = array_sum($hgd_col_array);

// Increased the total width of main grid at run time. If the total column width of sub grid exceeds main grid then few column of sub grid may be invisible.
if ($total_hg_width < $total_hgd_width) {
    $last_key = key(array_slice($hg_col_array, -1, 1, TRUE));
    $hg_col_array[$last_key] = $hg_col_array[$last_key] + ($total_hgd_width - $total_hg_width);
    $resultset_hg[0]['column_width'] = implode(',', $hg_col_array);
}
$sub_grid_json = json_encode($resultset_hgd);

// Match group detail
$xml_file = "EXEC spa_adiha_grid 's','MatchGroupDetail'";
$resultset_detail = readXMLURL2($xml_file);
$sub_grid_detail_json = json_encode($resultset_detail);

$context_menu_match = new AdihaMenu();
$context_menu_json_ls = '[
    {id:"split_match", text:"Split", img:"split.gif", imgdis:"split_dis.gif", title: "Split", enabled:"'.$has_rights_match_split.'"},
    {id:"unsplit_match", text:"Unsplit", img:"unsplit.gif", imgdis:"unsplit_dis.gif", title: "Unsplit", enabled:"'.$has_rights_match_split.'"}
]';
echo $context_menu_match -> init_menu('context_menu_match', $form_namespace);

echo $context_menu_match -> render_as_context_menu();
echo $context_menu_match -> attach_event('', 'onClick', 'context_menu_match_click');
echo $context_menu_match -> load_menu($context_menu_json_ls);

$grid_name = 'grd_match_group';
echo $tab_obj -> attach_grid_cell($grid_name, 'a2');

echo $grid_obj -> init_by_attach($grid_name, $form_namespace);
echo $grid_obj -> set_header($resultset_hg[0]['column_label_list']);
echo $grid_obj -> set_columns_ids($resultset_hg[0]['column_name_list']);
echo $grid_obj -> set_widths($resultset_hg[0]['column_width']);
echo $grid_obj -> set_column_types($resultset_hg[0]['column_type_list']);
echo $grid_obj -> set_sorting_preference($resultset_hg[0]['sorting_preference']);
echo $grid_obj -> set_column_auto_size(true);
echo $grid_obj -> set_column_visibility($resultset_hg[0]['set_visibility']);
echo $grid_obj -> enable_multi_select();
echo $grid_obj -> set_search_filter(true, "");
echo $grid_obj -> enable_header_menu();
echo $grid_obj -> enable_context_menu($form_namespace .'.context_menu_match');


echo $grid_obj -> return_init();
            echo $grid_obj -> enable_filter_auto_hide();
echo $grid_obj -> attach_event('', 'onSubGridCreated', $form_namespace.'.load_match_group_header');
echo $grid_obj -> attach_event('', 'onSelectStateChanged', $form_namespace . '.bookout_match_row_selection');
echo $grid_obj -> attach_event('', 'onRowDblClicked', $form_namespace . '.bookout_match_row_dbl_click');
echo $grid_obj -> load_grid_functions();

echo $layout_obj->close_layout();
?>
</body>
<script type="text/javascript">
    var has_rights_scheduling_workbench = Boolean('<?php echo $has_rights_scheduling_workbench; ?>');
    var has_rights_scheduling_workbench_UI = Boolean('<?php echo $has_rights_scheduling_workbench_UI; ?>');
    var has_rights_scheduling_workbench_del = Boolean('<?php echo $has_rights_scheduling_workbench_del; ?>');
    var has_rights_lock_unlock = Boolean('<?php echo $has_rights_lock_unlock; ?>');
    report_ui = {};
    var active_object_id = 'NULL';
    
    var product_type = '<?php echo $product_type; ?>'; //logic changed. took from table scheduling_workbench_configuration
    /**
    * [onload complete function call]
    */
    $(function() {
        show_hide_location_storage_grid_columns(product_type);
        load_filter_components();
        reload_all_grids();

        ns_scheduling_workbench.receipts_deals.attachEvent("onEditCell", function(stage,rId,cInd,nValue,oValue){
            if (cInd == ns_scheduling_workbench.receipts_deals.getColIndexById('term_start') || cInd == ns_scheduling_workbench.receipts_deals.getColIndexById('term_end')) {
                return false;
            } else {
                return true;
            }
        });
        // Don't know why its used
        /*ns_scheduling_workbench.cmb_location_pre_populate();
        ns_scheduling_workbench.cmb_commodity_pre_populate();*/
    });

    var load_match_group_header_json = <?php echo $sub_grid_json; ?>;
    var sub_grid_detail_json  = <?php echo $sub_grid_detail_json; ?>;

    function show_hide_location_storage_grid_columns(product_type) {
        if (product_type == 1) show_hide = true;
        else show_hide = false;
        
        ns_scheduling_workbench.location_storage.setColumnHidden(ns_scheduling_workbench.location_storage.getColIndexById('purchase_deal_id'), show_hide);        
        ns_scheduling_workbench.location_storage.setColumnHidden(ns_scheduling_workbench.location_storage.getColIndexById('lot'), show_hide);
        ns_scheduling_workbench.location_storage.setColumnHidden(ns_scheduling_workbench.location_storage.getColIndexById('purchase_deal_sub_type'), show_hide);
        ns_scheduling_workbench.location_storage.setColumnHidden(ns_scheduling_workbench.location_storage.getColIndexById('storage_receipt_quantity'), show_hide);
        ns_scheduling_workbench.location_storage.setColumnHidden(ns_scheduling_workbench.location_storage.getColIndexById('original_quantity_uom'), show_hide);        
        //## Shwo oil specific columns
        ns_scheduling_workbench.location_storage.setColumnHidden(ns_scheduling_workbench.location_storage.getColIndexById('contract'), !show_hide);
        ns_scheduling_workbench.location_storage.setColumnHidden(ns_scheduling_workbench.location_storage.getColIndexById('operator'), !show_hide);
        ns_scheduling_workbench.location_storage.setColumnHidden(ns_scheduling_workbench.location_storage.getColIndexById('inventory_amount'), !show_hide);
    }

            //loads sub grids
    ns_scheduling_workbench.load_match_group_header = function(sub_grid_obj, id, ind) {
        var process_id = ns_scheduling_workbench.get_process_id();
        var filter_xml = get_filter_paramters();

        if (filter_xml == 'NULL') {
            return;
        }

        filter_xml = escapeXML(filter_xml);

        sub_grid_obj.setImagePath(js_php_path + 'components/lib/adiha_dhtmlx/adiha_grid_3.0/adiha_dhtmlxGrid/codebase/imgs/');
        sub_grid_obj.setHeader(load_match_group_header_json[0].column_label_list);
        sub_grid_obj.setColumnIds(load_match_group_header_json[0].column_name_list);
        sub_grid_obj.setColTypes(load_match_group_header_json[0].column_type_list);
        sub_grid_obj.setColumnsVisibility(load_match_group_header_json[0].set_visibility);
        sub_grid_obj.setInitWidths(load_match_group_header_json[0].column_width);
        sub_grid_obj.setStyle('','background-color:#F8E8B8', '', 'background-color:#F7D97E !important');
        sub_grid_obj.init();
        sub_grid_obj.enableHeaderMenu();
        sub_grid_obj.objBox.style.overflow = "visible";

        sub_grid_obj.attachEvent('onRowDblClicked', function (id) {
            var match_group_ids = sub_grid_obj.getAllRowIds().split(',');
            var match_group_col_id = sub_grid_obj.getColIndexById('match_group_id');

            if (match_group_ids != '') {
        match_group_ids.forEach(
            function(match_group_id) {
                    match_group_id_value = sub_grid_obj.cells(match_group_id, match_group_col_id).getValue();
                });
            }

            ns_scheduling_workbench.bookout_match_row_dbl_click('NULL', match_group_id_value);
        });

        sub_grid_obj.attachEvent('onSelectStateChanged', function (id) {
            ns_scheduling_workbench.bookout_match_row_selection(id);
        });

        sub_grid_obj.attachEvent('onSubGridCreated', function (sub_grid_obj1, id1, ind1) {
            sub_grid_obj1.setImagePath(js_php_path + 'components/lib/adiha_dhtmlx/adiha_grid_3.0/adiha_dhtmlxGrid/codebase/imgs/');
            sub_grid_obj1.setHeader(sub_grid_detail_json[0].column_label_list);
            sub_grid_obj1.setColumnIds(sub_grid_detail_json[0].column_name_list);
            sub_grid_obj1.setColTypes(sub_grid_detail_json[0].column_type_list);
            sub_grid_obj1.setColumnsVisibility(sub_grid_detail_json[0].set_visibility);
            sub_grid_obj1.setInitWidths(sub_grid_detail_json[0].column_width);
            sub_grid_obj1.setStyle('','background-color:#FFFFCC','','background-color:#e3e378 !important');
            sub_grid_obj1.init();
            sub_grid_obj1.enableHeaderMenu();
            sub_grid_obj1.objBox.style.overflow = 'visible';
            sub_grid_obj1.attachEvent('onRowDblClicked', function (id) {
                var match_group_ids = sub_grid_obj1.getAllRowIds().split(',');
                var match_group_col_id = sub_grid_obj1.getColIndexById('match_group_id');

                if (match_group_ids != '') {
            match_group_ids.forEach(
                function(match_group_id) {
                        match_group_id_value = sub_grid_obj1.cells(match_group_id, match_group_col_id).getValue();
                    });
                }
                ns_scheduling_workbench.bookout_match_row_dbl_click('NULL', match_group_id_value);
        //ns_scheduling_workbench.bookout_match_row_dbl_click(id);
            });

            sub_grid_obj1.attachEvent('onSelectStateChanged', function (id) {
                ns_scheduling_workbench.bookout_match_row_selection(id);
            });

            var match_group_header_col_id = sub_grid_obj.getColIndexById('match_group_header_id');
            var match_group_header_id = sub_grid_obj.cells(id1, match_group_header_col_id).getValue();

            var param = {
                'action': 'spa_scheduling_workbench',
                'flag': 'z',
                'process_id': process_id,
                'filter_xml' : filter_xml,
                'grid_name' : 'MatchGroupDetail',
                'match_group_header_id' : match_group_header_id
            };

            param = $.param(param);

            var param_url = js_data_collector_url + '&' + param;
            sub_grid_obj1.clearAll();

            //after finished loading the data, fire sub grid reconstruct event so that the height of the parent grid is maintained when expanded.
            sub_grid_obj1.load(param_url, function() {
                sub_grid_obj1.callEvent('onGridReconstructed', []);
            });
        });


        var match_group_shipping_col_id = ns_scheduling_workbench.grd_match_group.getColIndexById('match_group_shipment_id');
        var match_group_shipment_id = ns_scheduling_workbench.grd_match_group.cells(id,match_group_shipping_col_id).getValue();

        var param = {
            'action': 'spa_scheduling_workbench',
            'flag': 'z',
            'process_id': process_id,
            'filter_xml' : filter_xml,
            'grid_name': 'MatchGroupHeader',
            'match_group_shipment_id' : match_group_shipment_id
        };

        param = $.param(param);

        var param_url = js_data_collector_url + '&' + param;
        sub_grid_obj.clearAll();

        //after finished loading the data, fire sub grid reconstruct event so that the height of the parent grid is maintained when expanded.
        sub_grid_obj.load(param_url, function() {
            sub_grid_obj.callEvent('onGridReconstructed', []);
        });
    }
    //ends onSubGridCreated event

    //load main filters
    load_filter_components = function() {
        var function_id = '<?php echo $rights_scheduling_workbench; ?>';

        var data = {
            'action': 'spa_create_application_ui_json',
            'flag': 'j',
            'application_function_id' : function_id,
            'template_name': 'ScheduleLiquidHydrocarbonProducts',
            'group_name': 'Filters,Commodity'
        };
        result = adiha_post_data('return_array', data, '', '', 'load_filter_form_data', false);
    }

    //load main filters callback
    load_filter_form_data = function (result) {
        var function_id = 10163700;
        var result_length = result.length;
        var tab_json = '';

        for (i = 0; i < result_length; i++) {
            if (i > 0)
                tab_json = tab_json + ',';
            tab_json = tab_json + (result[i][1]);
        }
        tab_json = '{tabs: [' + tab_json + ']}';

        report_ui['report_tabs_' + active_object_id] = ns_scheduling_workbench.deal_layout.cells('b').attachTabbar();
        report_ui['report_tabs_' + active_object_id].loadStruct(tab_json);

        var first_tab = '';

        for (j = 0; j < result_length; j++) {
            first_tab = 'detail_tab_' + result[0][0];
            tab_id = 'detail_tab_' + result[j][0];
            report_ui['form_' + j] = report_ui['report_tabs_' + active_object_id].cells(tab_id).attachForm();

            if (result[j][2]) {
                report_ui["form_" + j].loadStruct(result[j][2]);

                // added additional attribute in form to load dependent child combo without selecting parent combo value
                report_ui["form_" + j]['load_child_without_selecting_parent'] = 1;
                
                var form_name = 'report_ui["form_" + ' + j + ']';
                load_dependent_combo(result[j][6], 0, report_ui['form_' + j],'',1);
            }
        }

        report_ui['report_tabs_' + active_object_id].tabs(first_tab).setActive();

        //default value

        var filter_obj = ns_scheduling_workbench.deal_layout.cells('a').attachForm();
        var layout_cell_obj = ns_scheduling_workbench.deal_layout.cells('b');
        load_form_filter(filter_obj, layout_cell_obj, function_id, 2);

        report_ui['form_0'].attachEvent('onChange', function(value) {
            if (value == 'quantity_uom' || value == 'price_uom') {
                reload_all_grids();
            }

            if (value == 'period_from') {
                var period_from =  report_ui['form_0'].getItemValue('period_from', true);
                var period_from = period_from.split('-');

                var lastDayOfMonth = new Date(period_from[0], period_from[1], 0);
                var date = new Date(lastDayOfMonth);

                var add_zero = '';
                if (period_from[1] > 9)  { add_zero = '-'; } else add_zero = '-0';

                lastDayOfMonth = date.getFullYear() +  add_zero + (date.getMonth() + 1) + '-' + date.getDate();
                report_ui['form_0'].setItemValue('period_to', lastDayOfMonth)
            }
        });
        load_pre_allocation_dd();
    }

    var create_match_split_window;
    /**
     * [unload injection withdrawal deal window invoice export window.]
     */
    function unload_create_match_split_window() {
        if (create_match_split_window != null && create_match_split_window.unload != null) {
            create_match_split_window.unload();
            create_match_split_window = w2 = null;
        }
    }

            /**
            * [context_menu match grid]
            */
    context_menu_match_click = function(menu_id, type) {
        var data = ns_scheduling_workbench.grd_match_group.contextID.split('_');
        var match_group_id = ns_scheduling_workbench.grd_match_group.cells(data[0], ns_scheduling_workbench.grd_match_group.getColIndexById('match_group_id')).getValue();
        var match_group_shipment_id = ns_scheduling_workbench.grd_match_group.cells(data[0], ns_scheduling_workbench.grd_match_group.getColIndexById('match_group_shipment_id')).getValue();
        var is_parent_shipment = ns_scheduling_workbench.grd_match_group.cells(data[0], ns_scheduling_workbench.grd_match_group.getColIndexById('is_parent')).getValue();

        switch(menu_id) {
            case 'split_match':
                var data = {
                    'action' : 'spa_match_split',
                    'flag' : 'z',
                    'match_group_id' : match_group_id,
                    'match_group_shipment_id' : match_group_shipment_id
                };
                adiha_post_data('return_array', data, '', '', 'ns_scheduling_workbench.split_match_call_back');
                break;
            case 'unsplit_match':
                if (is_parent_shipment == 'Yes') {
                    dhtmlx.message({
                        title : 'Alert',
                        type : 'alert',
                        text: 'Parent shipment cannot be un-split.'
                    });
                    return;
                }

                var data = {
                    'action' : 'spa_match_split',
                    'flag' : 'r',
                    'match_group_id' : match_group_id,
                    'match_group_shipment_id' : match_group_shipment_id
                };
                adiha_post_data('confirm', data, '', '', 'ns_scheduling_workbench.unsplit_match_call_back');
                break;
        }
    }

    /**
    * [unsplit match callback]
    */
    ns_scheduling_workbench.unsplit_match_call_back = function(return_value) {
        //ns_scheduling_workbench.report_match_tab.tabs('a2').setActive();
        //ns_scheduling_workbench.tab_click('a2');
        if (return_value[0]['errorcode'] == 'Success') {
        ns_scheduling_workbench.refresh_grid_match_bookout(); 
            return;
        }
    }

    /* [split match callback]
    */
    ns_scheduling_workbench.split_match_call_back = function(return_value) {
        if (return_value[0][0] == 'Success') {
            var convert_uom = report_ui['form_0'].getItemValue('quantity_uom');
            var match_group_id_match_group_shipment_id = return_value[0][5];
            match_group_id_match_group_shipment_id = match_group_id_match_group_shipment_id.split('_')
            var match_group_id = match_group_id_match_group_shipment_id[0];
            var match_group_shipment_id = match_group_id_match_group_shipment_id[1];
            var params = '?match_group_id=' + match_group_id
                + '&match_group_shipment_id=' + match_group_shipment_id 
                + '&convert_uom=' + convert_uom;                                                                                

            unload_create_match_split_window();

            if (!create_match_split_window) {
                create_match_split_window = new dhtmlXWindows();
            }

            var new_win = create_match_split_window.createWindow('w2', 0, 0, 980, 750);

            url = '<?php echo $app_php_script_loc; ?>' +  '../adiha.html.forms/_scheduling_delivery/scheduling_workbench/split.match.volume.php' + params;
            new_win.setText("Match Split");
            new_win.centerOnScreen();
            new_win.setModal(true);
            new_win.attachURL(url, false, true);
            return;
        } else {
            dhtmlx.message({
                title:'Alert',
                type:"alert",
                text:return_value[0][4]
            });
            return;
        }
    }

    /**
    * [context_menu receipts grid]
    */
    function context_menu_rec_click(menu_id, type) {
        var data = ns_scheduling_workbench.receipts_deals.contextID.split('_');
        var product_type = '<?php echo $product_type; ?>';
        switch(menu_id) {
            case 'split':
                var source_deal_detail_id = ns_scheduling_workbench.receipts_deals.cells(data[0], ns_scheduling_workbench.receipts_deals.getColIndexById('source_deal_detail_id')).getValue();
                var split_deal_detail_volume_id = ns_scheduling_workbench.receipts_deals.cells(data[0], ns_scheduling_workbench.receipts_deals.getColIndexById('split_deal_detail_volume_id')).getValue();
                var balance_qty = ns_scheduling_workbench.receipts_deals.cells(data[0], ns_scheduling_workbench.receipts_deals.getColIndexById('bal_quantity')).getValue();
                ns_scheduling_workbench.deal_detail_volume_split_window(source_deal_detail_id, balance_qty, split_deal_detail_volume_id)
                break;
            case 'unsplit':
                var deal_detail_id_split_deal_detail_volume_id = ns_scheduling_workbench.receipts_deals.cells(data[0], ns_scheduling_workbench.receipts_deals.getColIndexById('deal_detail_id_split_deal_detail_volume_id')).getValue();
                var merge_quantity = ns_scheduling_workbench.receipts_deals.cells(data[0], ns_scheduling_workbench.receipts_deals.getColIndexById('bal_quantity')).getValue();
                unsplit_deal_detail_volume(deal_detail_id_split_deal_detail_volume_id, merge_quantity)
                break;
            case 'injection_rec':
                var balance_qty = ns_scheduling_workbench.receipts_deals.cells(data[0], ns_scheduling_workbench.receipts_deals.getColIndexById('bal_quantity')).getValue();
                var commodity_name = ns_scheduling_workbench.receipts_deals.cells(data[0], ns_scheduling_workbench.receipts_deals.getColIndexById('commodity_name')).getValue();
                var counterparty_name = ns_scheduling_workbench.receipts_deals.cells(data[0], ns_scheduling_workbench.receipts_deals.getColIndexById('counterparty_name')).getValue();
                var location = ns_scheduling_workbench.receipts_deals.cells(data[0], ns_scheduling_workbench.receipts_deals.getColIndexById('location')).getValue();
                var term_start = ns_scheduling_workbench.receipts_deals.cells(data[0], ns_scheduling_workbench.receipts_deals.getColIndexById('term_start')).getValue();
                var est_movement_date = ns_scheduling_workbench.receipts_deals.cells(data[0], ns_scheduling_workbench.receipts_deals.getColIndexById('est_movement_date')).getValue();
                var source_deal_detail_id = ns_scheduling_workbench.receipts_deals.cells(data[0], ns_scheduling_workbench.receipts_deals.getColIndexById('source_deal_detail_id')).getValue();
                var deal_detail_id_split_deal_detail_volume_id = ns_scheduling_workbench.receipts_deals.cells(data[0], ns_scheduling_workbench.receipts_deals.getColIndexById('deal_detail_id_split_deal_detail_volume_id')).getValue();

                var deal_date = (est_movement_date == '') ? term_start : est_movement_date;
                ns_scheduling_workbench.begining_storage_deals_window(balance_qty, commodity_name, counterparty_name, location, deal_date, source_deal_detail_id, deal_detail_id_split_deal_detail_volume_id, product_type, 'from_purchase', '', ns_scheduling_workbench.context_menu_rec.getItemText(menu_id));
                break;
            case 'injection_pipeline':
                var select_id = ns_scheduling_workbench.receipts_deals.getSelectedRowId();
                if (select_id != null) {
                    select_id = select_id.split(',');
                    var location = 0;
                    var balance_qty = 0;
                    var pipeline_id = 0;
                    var valid = 1;;
                    var selected_row_id = 0;

                
                    select_id.forEach(function(id) { 
                        var location_new = ns_scheduling_workbench.receipts_deals.cells(id, ns_scheduling_workbench.receipts_deals.getColIndexById('location')).getValue();
                        pipeline_id = ns_scheduling_workbench.receipts_deals.cells(id, ns_scheduling_workbench.receipts_deals.getColIndexById('pipeline_id')).getValue();
                        
                        if (location != 0 && location != undefined && location != location_new) {
                            dhtmlx.message({
                                title : 'Alert',
                                type : 'alert',
                                text : 'Different Locations have been selected.'
                            });
                            valid = 0;
                            return;
                        }
                        /*
                        if (pipeline_id == "" || pipeline_id == "NULL") {
                            dhtmlx.message({
                                title : 'Alert',
                                type : 'alert',
                                text : 'Pipeline does not exist.'
                            });
                            valid = 0;
                            return;
                        }
                        */
                        location = location_new;

                        balance_qty += parseFloat(ns_scheduling_workbench.receipts_deals.cells(id, ns_scheduling_workbench.receipts_deals.getColIndexById('bal_quantity')).getValue());
                        selected_row_id = id;
                        
                    });
                    
                    if (valid == 1) {
                        var commodity_name = ns_scheduling_workbench.receipts_deals.cells(selected_row_id, ns_scheduling_workbench.receipts_deals.getColIndexById('commodity_name')).getValue();
                        var counterparty_name = ns_scheduling_workbench.receipts_deals.cells(selected_row_id, ns_scheduling_workbench.receipts_deals.getColIndexById('counterparty_name')).getValue();
                        var location = ns_scheduling_workbench.receipts_deals.cells(selected_row_id, ns_scheduling_workbench.receipts_deals.getColIndexById('location')).getValue();
                        var term_start = ns_scheduling_workbench.receipts_deals.cells(selected_row_id, ns_scheduling_workbench.receipts_deals.getColIndexById('term_start')).getValue();
                        var est_movement_date = ns_scheduling_workbench.receipts_deals.cells(selected_row_id, ns_scheduling_workbench.receipts_deals.getColIndexById('est_movement_date')).getValue();
                        var source_deal_detail_id = ns_scheduling_workbench.receipts_deals.cells(selected_row_id, ns_scheduling_workbench.receipts_deals.getColIndexById('source_deal_detail_id')).getValue();
                        var deal_detail_id_split_deal_detail_volume_id = ns_scheduling_workbench.receipts_deals.cells(selected_row_id, ns_scheduling_workbench.receipts_deals.getColIndexById('deal_detail_id_split_deal_detail_volume_id')).getValue();

                        var deal_date = (est_movement_date == '') ? term_start : est_movement_date;
                        
                        ns_scheduling_workbench.begining_pool_deals_window(balance_qty, commodity_name, counterparty_name, location, deal_date, source_deal_detail_id, deal_detail_id_split_deal_detail_volume_id, product_type, pipeline_id, 'from_inject_pipeline', '', ns_scheduling_workbench.context_menu_rec.getItemText(menu_id));
                    }
                } else {
                    dhtmlx.message({
                                title : 'Alert',
                                type : 'alert',
                                text : 'No Row(s) Selected.'
                            });
                            return;
                }
                break;
        }
    }

            /**
            * [open deal volume split window]
            */
    ns_scheduling_workbench.begining_storage_deals_window = function(balance_qty, commodity_name, counterparty_name, location, deal_date, source_deal_detail_id, deal_detail_id_split_deal_detail_volume_id, product_type, callfrom, contract_id, window_text, lot) {
        var process_id = ns_scheduling_workbench.get_process_id();
        var url = '';
        var selected_uom = get_selected_uom();
        var storage_data = 'NULL';
        
        var params =  '?balance_qty='+ balance_qty
                    + '&commodity_name=' + commodity_name
                    + '&counterparty_name=' + counterparty_name
                    + '&deal_date=' + deal_date
                    + '&source_deal_detail_id=' + source_deal_detail_id
                    + '&location=' + location
                    + '&deal_detail_id_split_deal_detail_volume_id=' + deal_detail_id_split_deal_detail_volume_id
                    + '&selected_uom=' + selected_uom
                    + '&product_type=' + product_type
                    + '&callfrom=' + callfrom
                    + '&contract_id=' + contract_id
                    + '&lot=' + lot;

        unload_begining_storage_deal_window_window();

        if (!begining_storage_deal_window) {
            begining_storage_deal_window = new dhtmlXWindows();
        }

        var new_win = begining_storage_deal_window.createWindow('w2', 0, 0, 1000, 550);

        url = '<?php echo $app_php_script_loc; ?>' +  '../adiha.html.forms/_scheduling_delivery/scheduling_workbench/begining.storage.deal.php' + params;
        if (callfrom == 'from_delivery') {
            new_win.setText('Withdraw from Storage');
        } else {
            new_win.setText('Inject into Storage');
        }
        new_win.centerOnScreen();
        new_win.maximize();
        new_win.setModal(true);
        new_win.attachURL(url, false, true);
    }

    var begining_storage_deal_window;
    /**
     * [Unload deal detail split window.]
     */
    function unload_begining_storage_deal_window_window() {
        if (begining_storage_deal_window != null && begining_storage_deal_window.unload != null) {
            begining_storage_deal_window.unload();
            begining_storage_deal_window = w2 = null;
        }
    }

    /**
        *[Matching Delivery grids and  transit grid for injection into pipeline]
    */
    ns_scheduling_workbench.call_injection_into_pipeline = function(pipeline_id) {
        var select_id = ns_scheduling_workbench.delivery_deals.getSelectedRowId();
        if (select_id != null) {
            select_id = select_id.split(',');
            var location = 0;
            var balance_qty = 0;
            var valid = 1;;
            var selected_row_id = 0;

        
            select_id.forEach(function(id) { 
                var location_new = ns_scheduling_workbench.delivery_deals.cells(id, ns_scheduling_workbench.delivery_deals.getColIndexById('location')).getValue();
                               
                if (location != 0 && location != undefined && location != location_new) {
                    dhtmlx.message({
                        title : 'Alert',
                        type : 'alert',
                        text : 'Different Locations have been selected.'
                    });
                    valid = 0;
                    return;
                }

                location = location_new;

                balance_qty += parseFloat(ns_scheduling_workbench.delivery_deals.cells(id, ns_scheduling_workbench.delivery_deals.getColIndexById('bal_quantity')).getValue());
                selected_row_id = id;
                
            });     
            
            if (valid == 1) {
                var commodity_name = ns_scheduling_workbench.delivery_deals.cells(selected_row_id, ns_scheduling_workbench.delivery_deals.getColIndexById('commodity_name')).getValue();
                var counterparty_name = ns_scheduling_workbench.delivery_deals.cells(selected_row_id, ns_scheduling_workbench.delivery_deals.getColIndexById('counterparty_name')).getValue();
                var location = ns_scheduling_workbench.delivery_deals.cells(selected_row_id, ns_scheduling_workbench.delivery_deals.getColIndexById('location')).getValue();
                var term_start = ns_scheduling_workbench.delivery_deals.cells(selected_row_id, ns_scheduling_workbench.delivery_deals.getColIndexById('term_start')).getValue();
                var est_movement_date = ns_scheduling_workbench.delivery_deals.cells(selected_row_id, ns_scheduling_workbench.delivery_deals.getColIndexById('est_movement_date')).getValue();
                var source_deal_detail_id = ns_scheduling_workbench.delivery_deals.cells(selected_row_id, ns_scheduling_workbench.delivery_deals.getColIndexById('source_deal_detail_id')).getValue();
                var deal_detail_id_split_deal_detail_volume_id = ns_scheduling_workbench.delivery_deals.cells(selected_row_id, ns_scheduling_workbench.delivery_deals.getColIndexById('deal_detail_id_split_deal_detail_volume_id')).getValue();
                
                var deal_date = (est_movement_date == '') ? term_start : est_movement_date;
                
                ns_scheduling_workbench.begining_pool_deals_window(balance_qty, commodity_name, counterparty_name, location, deal_date, source_deal_detail_id, deal_detail_id_split_deal_detail_volume_id, product_type, pipeline_id, 'from_withdraw_pipeline', '');
                
                
            }
        } else {
            dhtmlx.message({
                        title : 'Alert',
                        type : 'alert',
                        text : 'No Row(s) Selected.'
                    });
                    return;
        }
    }
    
    /**
            * [open Pipeline window]
            */
    ns_scheduling_workbench.begining_pool_deals_window = function(balance_qty, commodity_name, counterparty_name, location, deal_date, source_deal_detail_id, deal_detail_id_split_deal_detail_volume_id, product_type, pipeline_id, callfrom, contract_id) {
        var process_id = ns_scheduling_workbench.get_process_id();
        var url = '';
        var selected_uom = get_selected_uom();
        var pool_data = 'NULL';
        
        var params =  '?balance_qty='+ balance_qty
                    + '&commodity_name=' + commodity_name
                    + '&counterparty_name=' + counterparty_name
                    + '&deal_date=' + deal_date
                    + '&source_deal_detail_id=' + source_deal_detail_id
                    + '&location=' + location
                    + '&deal_detail_id_split_deal_detail_volume_id=' + deal_detail_id_split_deal_detail_volume_id
                    + '&selected_uom=' + selected_uom
                    + '&product_type=' + product_type
                    + '&callfrom=' + callfrom
                    + '&contract_id=' + contract_id
                    + '&pipeline_id=' + pipeline_id;

        unload_begining_pool_deal_window_window();

        if (!begining_pool_deal_window) {
            begining_pool_deal_window = new dhtmlXWindows();
        }

        var new_win = begining_pool_deal_window.createWindow('w2', 0, 0, 1000, 550);

        url = '<?php echo $app_php_script_loc; ?>' +  '../adiha.html.forms/_scheduling_delivery/scheduling_workbench/begining.pool.deal.php' + params;
        if (callfrom == 'from_inject_pipeline') {
            new_win.setText('Inject into Pipeline');
        } else {
            new_win.setText('Withdraw from Pipeline');
        }
        new_win.centerOnScreen();
        new_win.maximize();
        new_win.setModal(true);
        new_win.attachURL(url, false, true);
    }

    var begining_pool_deal_window;
    /**
     * [Unload deal detail split window.]
     */
    function unload_begining_pool_deal_window_window() {
        if (begining_pool_deal_window != null && begining_pool_deal_window.unload != null) {
            begining_pool_deal_window.unload();
            begining_pool_deal_window = w2 = null;
        }
    }


    /**
    * [context menu location storage grid]
    */
    function context_menu_ls_click(menu_id, type) {
        var data = ns_scheduling_workbench.location_storage.contextID.split('_');

        var context_id = data[0] + '_' + data[1] + '_' +  data[2];    
        var lot = '';
        var purchase_deal_id = '';
        var product_type = '<?php echo $product_type; ?>';
        var deal_date = new Date();
        var counterparty_name = '';
        var id = ns_scheduling_workbench.location_storage.getSelectedRowId();
     
        lot = ns_scheduling_workbench.location_storage.cells(context_id, ns_scheduling_workbench.location_storage.getColIndexById('lot')).getValue();
        purchase_deal_id = ns_scheduling_workbench.location_storage.cells(context_id, ns_scheduling_workbench.location_storage.getColIndexById('parent_source_deal_header_id')).getValue();                
         
        var source_minor_location_id = ns_scheduling_workbench.location_storage.cells(context_id, ns_scheduling_workbench.location_storage.getColIndexById('source_minor_location_id')).getValue();
        var balance_quantity = ns_scheduling_workbench.location_storage.cells(context_id, ns_scheduling_workbench.location_storage.getColIndexById('balance_quantity')).getValue();
        var product = ns_scheduling_workbench.location_storage.cells(context_id, ns_scheduling_workbench.location_storage.getColIndexById('product')).getValue();
        var original_quantity_uom = ns_scheduling_workbench.location_storage.cells(context_id, ns_scheduling_workbench.location_storage.getColIndexById('original_quantity_uom')).getValue();
        var convert_quantity_uom = ns_scheduling_workbench.location_storage.cells(context_id, ns_scheduling_workbench.location_storage.getColIndexById('convert_quantity_uom')).getValue();

        if (original_quantity_uom == '')
            original_quantity_uom = convert_quantity_uom;

        var location_name = ns_scheduling_workbench.location_storage.cells(context_id, ns_scheduling_workbench.location_storage.getColIndexById('grouper')).getValue();
        
        var contract_id = ns_scheduling_workbench.location_storage.cells(context_id, ns_scheduling_workbench.location_storage.getColIndexById('contract')).getValue();
        var counterparty_name = ns_scheduling_workbench.location_storage.cells(context_id, ns_scheduling_workbench.location_storage.getColIndexById('operator')).getValue();
        var seq_no = ns_scheduling_workbench.location_storage.cells(context_id, ns_scheduling_workbench.location_storage.getColIndexById('seq_no')).getValue();

        var wacog = ns_scheduling_workbench.location_storage.cells(context_id, ns_scheduling_workbench.location_storage.getColIndexById('price')).getValue();

        switch(menu_id) {
            case 'injection_deal':
                ns_scheduling_workbench.create_deal_window(source_minor_location_id, lot, purchase_deal_id, balance_quantity, product, original_quantity_uom, location_name, 'i', seq_no);
                break;
            case 'withdrawal_deal':
                ns_scheduling_workbench.create_deal_window(source_minor_location_id, lot, purchase_deal_id, balance_quantity, product, original_quantity_uom, location_name, 'w', seq_no);
                break;
            case 'injection_storage':
                ns_scheduling_workbench.begining_storage_deals_window(balance_quantity, product, counterparty_name, source_minor_location_id, deal_date, '', '', product_type, 'from_storage', contract_id, ns_scheduling_workbench.context_menu_del.getItemText(menu_id), lot);
                break;
            case 'inventory_adjustment': 
                ns_scheduling_workbench.create_adjustment_injection_storage_window(balance_quantity, seq_no, wacog, lot, contract_id, product, source_minor_location_id);
                break;
        }
    }

    var create_adjustment_injection_storage_window;

    /**
     * [unload injection withdrawal deal window invoice export window.]
     */
    function unload_create_adjustment_injection_storage_window() {
        if (create_adjustment_injection_storage_window != null && create_adjustment_injection_storage_window.unload != null) {
            create_adjustment_injection_storage_window.unload();
            create_adjustment_injection_storage_window = w3 = null;
        }
    }

    ns_scheduling_workbench.create_adjustment_injection_storage_window = function (balance_quantity, seq_no, wacog, lot_no, contract_id, product, sml_id) {
        unload_create_adjustment_injection_storage_window();

        if (!create_adjustment_injection_storage_window) {
            create_adjustment_injection_storage_window = new dhtmlXWindows();
        }

        var new_win = create_adjustment_injection_storage_window.createWindow('w3', 0, 0, 640, 450);
        var quantity_uom = report_ui['form_0'].getItemValue('quantity_uom');
        var process_id = ns_scheduling_workbench.get_process_id();
        
        if (seq_no >= 0) {
            var params = 'quantity_uom=' + quantity_uom
                    + '&balance_quantity=' + balance_quantity
                    + '&wacog=' + wacog
                    + '&process_id=' + process_id
                    + '&contract_id=' + contract_id
                    + '&product=' + product
                    + '&sml_id=' + sml_id
                    + '&lot=' + lot_no
                    + '&seq_no=' + seq_no;

            var url = '<?php echo $app_php_script_loc; ?>' +  '../adiha.html.forms/_scheduling_delivery/scheduling_workbench/adjustment.injection.storage.php?' + params;
            new_win.setText('Create Inventory Adjustment');
        } else {
            var params = 'seq_no=' + seq_no
                        + '&process_id=' + process_id
                        + '&lot_no=' + lot_no;
            var url = '<?php echo $app_php_script_loc; ?>' +  '../adiha.html.forms/_scheduling_delivery/scheduling_workbench/adjustment.intransit.storage.php?' + params;
            new_win.setText('Create In-Transit Adjustment');
        }

        new_win.centerOnScreen();
        new_win.setModal(true);

        new_win.attachURL(url, false, true);
    }


    /*tab click */
    ns_scheduling_workbench.tab_click = function(id) {
        if (id == 'a2') { //match tab
            ns_scheduling_workbench.deal_layout.cells('b').collapse();
            ns_scheduling_workbench.deal_layout.cells('c').collapse();
        } else {
            ns_scheduling_workbench.deal_layout.cells('c').expand();
            ns_scheduling_workbench.receipts_deals.setColumnHidden(0,false);
            ns_scheduling_workbench.delivery_deals.setColumnHidden(0,false);
        }
    }

    /**
    * [location_storage grid double click]
    */
    ns_scheduling_workbench.location_storage_row_dbl_click = function () {
        
        var select_id = ns_scheduling_workbench.location_storage.getSelectedRowId();
        var parent_lot_id = ns_scheduling_workbench.location_storage.cells(select_id, ns_scheduling_workbench.location_storage.getColIndexById('lot')).getValue();
        var source_minor_location_id = ns_scheduling_workbench.location_storage.cells(select_id, ns_scheduling_workbench.location_storage.getColIndexById('source_minor_location_id')).getValue();        //var filter_xml = get_filter_paramters();
        var product = ns_scheduling_workbench.location_storage.cells(select_id, ns_scheduling_workbench.location_storage.getColIndexById('product')).getValue();
        var batch_id = 'NULL'; //ns_scheduling_workbench.location_storage.cells(select_id, ns_scheduling_workbench.location_storage.getColIndexById('production_batch_reference_id')).getValue();
        var process_id = ns_scheduling_workbench.get_process_id();
        var quantity_uom = report_ui['form_0'].getItemValue('quantity_uom');
        var contract_id = ns_scheduling_workbench.location_storage.cells(select_id, ns_scheduling_workbench.location_storage.getColIndexById('contract')).getValue();
        
        var std_report_url = "EXEC spa_storage_position_report_sw @summary_detail='d'"
                            + ", @parent_lot_id='" + parent_lot_id 
                            + "', @location_id=" + source_minor_location_id
                            + ", @product='" + product
                            + "', @convert_uom='" + quantity_uom
                            + "', @batch_id='" + batch_id
                            + "', @process_id='" + process_id 
                            + "', @contract_id='" + contract_id + "'";

        open_spa_html_window('Scheduled Storage Position Report', std_report_url, 600, 1200);
    }

    /**
    * [create injection withdrawal deal window]
    */
    ns_scheduling_workbench.create_deal_window = function(source_minor_location_id, lot, purchase_deal_id, balance_quantity, product, original_quantity_uom, location_name, injection_withdrawal, seq_no) {
        var process_id = ns_scheduling_workbench.get_process_id();
        var url = '';
        var params =  '?source_minor_location_id='+ source_minor_location_id
                    + '&lot=' + lot
                    + '&location_name=' + location_name
                    + '&purchase_deal_id=' + purchase_deal_id
                    + '&balance_quantity=' + balance_quantity
                    + '&product=' + product
                    + '&original_quantity_uom=' + original_quantity_uom
                    + '&injection_withdrawal=' + injection_withdrawal
                    + '&seq_no=' + seq_no
                    + '&process_id=' + process_id;
        unload_deal_detail_spilt_window_window();

        if (!create_deal_window) {
            create_deal_window = new dhtmlXWindows();
        }

        var new_win = create_deal_window.createWindow('w2', 0, 0, 500, 480);

        url = '<?php echo $app_php_script_loc; ?>' +  '../adiha.html.forms/_scheduling_delivery/scheduling_workbench/create.injection.withdrawal.deal.php' + params;
        new_win.setText('Create Receipt/Delivery');
        new_win.centerOnScreen();
        new_win.setModal(true);

        new_win.attachURL(url, false, true);
    }

    var create_deal_window;
    /**
     * [unload injection withdrawal deal window invoice export window.]
     */
    function unload_deal_detail_spilt_window_window() {
        if (create_deal_window != null && create_deal_window.unload != null) {
            create_deal_window.unload();
            create_deal_window = w2 = null;
        }
    }

    /**
    * [context_menu delivery grid]
    */
    function context_menu_del_click(menu_id, type) {
        switch(menu_id) {
            case 'split':
                var data = ns_scheduling_workbench.delivery_deals.contextID.split('_');
                var source_deal_detail_id = ns_scheduling_workbench.delivery_deals.cells(data[0], ns_scheduling_workbench.delivery_deals.getColIndexById('source_deal_detail_id')).getValue();
                var split_deal_detail_volume_id = ns_scheduling_workbench.delivery_deals.cells(data[0], ns_scheduling_workbench.delivery_deals.getColIndexById('split_deal_detail_volume_id')).getValue();
                var balance_qty = ns_scheduling_workbench.delivery_deals.cells(data[0], ns_scheduling_workbench.delivery_deals.getColIndexById('bal_quantity')).getValue();
                ns_scheduling_workbench.deal_detail_volume_split_window(source_deal_detail_id, balance_qty, split_deal_detail_volume_id)
                break;
            case 'unsplit':
                var data = ns_scheduling_workbench.delivery_deals.contextID.split('_');
                var deal_detail_id_split_deal_detail_volume_id = ns_scheduling_workbench.delivery_deals.cells(data[0], ns_scheduling_workbench.delivery_deals.getColIndexById('deal_detail_id_split_deal_detail_volume_id')).getValue();
                var merge_quantity = ns_scheduling_workbench.delivery_deals.cells(data[0], ns_scheduling_workbench.delivery_deals.getColIndexById('bal_quantity')).getValue();
                unsplit_deal_detail_volume(deal_detail_id_split_deal_detail_volume_id, merge_quantity)
                break;
            case 'injection_del' :
                var data = ns_scheduling_workbench.delivery_deals.contextID.split('_');
                var balance_qty = ns_scheduling_workbench.delivery_deals.cells(data[0], ns_scheduling_workbench.receipts_deals.getColIndexById('bal_quantity')).getValue();
                var commodity_name = ns_scheduling_workbench.delivery_deals.cells(data[0], ns_scheduling_workbench.receipts_deals.getColIndexById('commodity_name')).getValue();
                var counterparty_name = ns_scheduling_workbench.delivery_deals.cells(data[0], ns_scheduling_workbench.receipts_deals.getColIndexById('counterparty_name')).getValue();
                var location = ns_scheduling_workbench.delivery_deals.cells(data[0], ns_scheduling_workbench.receipts_deals.getColIndexById('location')).getValue();
                var term_start = ns_scheduling_workbench.delivery_deals.cells(data[0], ns_scheduling_workbench.receipts_deals.getColIndexById('term_start')).getValue();
                var est_movement_date = ns_scheduling_workbench.delivery_deals.cells(data[0], ns_scheduling_workbench.receipts_deals.getColIndexById('est_movement_date')).getValue();
                var source_deal_detail_id = ns_scheduling_workbench.delivery_deals.cells(data[0], ns_scheduling_workbench.receipts_deals.getColIndexById('source_deal_detail_id')).getValue();
                var deal_detail_id_split_deal_detail_volume_id = ns_scheduling_workbench.delivery_deals.cells(data[0], ns_scheduling_workbench.delivery_deals.getColIndexById('deal_detail_id_split_deal_detail_volume_id')).getValue();

                var deal_date = (est_movement_date == '') ? term_start : est_movement_date;
                ns_scheduling_workbench.begining_storage_deals_window(balance_qty, commodity_name, counterparty_name, location, deal_date, source_deal_detail_id, deal_detail_id_split_deal_detail_volume_id, product_type, 'from_delivery', '', ns_scheduling_workbench.context_menu_del.getItemText(menu_id));
            break;
            case 'withdrawal_pipeline':
            var select_id = ns_scheduling_workbench.delivery_deals.getSelectedRowId();
                if (select_id != null) {
                    select_id = select_id.split(',');
                    var location = 0;
                    var balance_qty = 0;
                    var pipeline_id = 0;
                    var valid = 1;;
                    var selected_row_id = 0;

                
                    select_id.forEach(function(id) { 
                        var location_new = ns_scheduling_workbench.delivery_deals.cells(id, ns_scheduling_workbench.delivery_deals.getColIndexById('location')).getValue();
                        pipeline_id = ns_scheduling_workbench.delivery_deals.cells(id, ns_scheduling_workbench.delivery_deals.getColIndexById('pipeline_id')).getValue();
                        
                        if (location != 0 && location != undefined && location != location_new) {
                            dhtmlx.message({
                                title : 'Alert',
                                type : 'alert',
                                text : 'Different Locations have been selected.'
                            });
                            valid = 0;
                            return;
                        }
                        /*
                        if (pipeline_id == "" || pipeline_id == "NULL") {
                            dhtmlx.message({
                                title : 'Alert',
                                type : 'alert',
                                text : 'Pipeline does not exist.'
                            });
                            valid = 0;
                            return;
                        }
                        */
                        location = location_new;

                        balance_qty += parseFloat(ns_scheduling_workbench.delivery_deals.cells(id, ns_scheduling_workbench.delivery_deals.getColIndexById('bal_quantity')).getValue());
                        selected_row_id = id;
                        
                    });
                    
                    if (valid == 1) {
                        var commodity_name = ns_scheduling_workbench.delivery_deals.cells(selected_row_id, ns_scheduling_workbench.delivery_deals.getColIndexById('commodity_name')).getValue();
                        var counterparty_name = ns_scheduling_workbench.delivery_deals.cells(selected_row_id, ns_scheduling_workbench.delivery_deals.getColIndexById('counterparty_name')).getValue();
                        var location = ns_scheduling_workbench.delivery_deals.cells(selected_row_id, ns_scheduling_workbench.delivery_deals.getColIndexById('location')).getValue();
                        var term_start = ns_scheduling_workbench.delivery_deals.cells(selected_row_id, ns_scheduling_workbench.delivery_deals.getColIndexById('term_start')).getValue();
                        var est_movement_date = ns_scheduling_workbench.delivery_deals.cells(selected_row_id, ns_scheduling_workbench.delivery_deals.getColIndexById('est_movement_date')).getValue();
                        var source_deal_detail_id = ns_scheduling_workbench.delivery_deals.cells(selected_row_id, ns_scheduling_workbench.delivery_deals.getColIndexById('source_deal_detail_id')).getValue();
                        var deal_detail_id_split_deal_detail_volume_id = ns_scheduling_workbench.delivery_deals.cells(selected_row_id, ns_scheduling_workbench.delivery_deals.getColIndexById('deal_detail_id_split_deal_detail_volume_id')).getValue();

                        var deal_date = (est_movement_date == '') ? term_start : est_movement_date;
                        
                    ns_scheduling_workbench.begining_pool_deals_window(balance_qty, commodity_name, counterparty_name, location, deal_date, source_deal_detail_id, deal_detail_id_split_deal_detail_volume_id, product_type, pipeline_id, 'from_withdraw_pipeline', '', ns_scheduling_workbench.context_menu_del.getItemText(menu_id));
                    }
                } else {
                    dhtmlx.message({
                                title : 'Alert',
                                type : 'alert',
                                text : 'No Row(s) Selected.'
                            });
                            return;
                }
        }
    }

    /**
    * [split deals]
    */
    function unsplit_deal_detail_volume(deal_detail_id_split_deal_detail_volume_id, merge_quantity) {
        var convert_uom = report_ui['form_0'].getItemValue('quantity_uom');
        var data = {
            'action' : 'spa_scheduling_workbench',
            'flag' : 'u',
            'deal_detail_id_split_deal_detail_volume_id':deal_detail_id_split_deal_detail_volume_id,
            'merge_quantity' : merge_quantity,
            'convert_uom' : convert_uom
        };

        adiha_post_data('return_array', data, '', '', 'unsplit_deal_detail_volume_call_back');
    }

    /**
    * [split deals callback]
    */
    function unsplit_deal_detail_volume_call_back(return_value) {
        if (return_value[0][0] == 'Success') {
            dhtmlx.message({
                text:return_value[0][4],
                expire:1000
            });

            reload_all_grids();
        } else {
            dhtmlx.message({
                title:'Alert',
                type:'alert',
                text:return_value[0][4]
            });
            return;
        }
    }


    /**
    * [undock match bookout/match grid]
    */
    function undock_window_match() {
        ns_scheduling_workbench.deal_layout.cells('c').undock(300, 300, 900, 700);
        ns_scheduling_workbench.deal_layout.dhxWins.window('c').maximize();
        ns_scheduling_workbench.deal_layout.dhxWins.window('c').button('park').hide();
    }

    /**
    * [row select for bookout/match grid]
    */
    ns_scheduling_workbench.bookout_match_row_dbl_click = function(id, match_group_id_value) {
        if (has_rights_scheduling_workbench_UI == false) {
            return; //no privelege
        }

        if (id == 'NULL') {
            match_group_id = match_group_id_value;
        } else {
            var match_group_col_id = ns_scheduling_workbench.grd_match_group.getColIndexById('match_group_id');
            var match_group_id = ns_scheduling_workbench.grd_match_group.cells(id,match_group_col_id).getValue();
        }
        ns_scheduling_workbench.location_storage.clearSelection();
        ns_scheduling_workbench.call_bookout_match('m', 'NULL', 'NULL', 'u', match_group_id);
    }

    /**
    * [get process_id]
    */
    ns_scheduling_workbench.get_process_id = function () {
        var process_id = report_ui["form_0"].getItemValue('process_id');
        return process_id;
    }

    /**
    * [load bookout match grid]
    */
    ns_scheduling_workbench.refresh_grid_match_bookout = function () {
        //need to load grid here
        var process_id = ns_scheduling_workbench.get_process_id();
        var filter_xml = get_filter_paramters();

        if (filter_xml == 'NULL') {
            return;
        }

        filter_xml = escapeXML(filter_xml);

        var sql_param = {
            'action' : 'spa_scheduling_workbench',
            'flag' : 'z',
            'grid_type' : 'g',
            'process_id' : process_id,
            'filter_xml' : filter_xml,
            'grid_name' : 'MatchGroupShipment'
        };
        sql_param = $.param(sql_param);
        sql_url = js_data_collector_url + "&" + sql_param;

        ns_scheduling_workbench.grd_match_group.clearAll();
        ns_scheduling_workbench.grd_match_group.load(sql_url, function(){
            ns_scheduling_workbench.grd_match_group.filterByAll();
        });
    }

    /**
    * [storage grid row selection]
    */
    ns_scheduling_workbench.location_storage_grid_row_selection = function () {
        var storage_id = ns_scheduling_workbench.location_storage.getSelectedRowId();
        var location_id = '';

        if (storage_id == null) {
            location_id = 'NULL'
        } else {
            location_id = 1;
        }

        var receipt_detail_ids = ns_scheduling_workbench.receipts_deals.getSelectedRowId();
        var delivery_detail_ids = ns_scheduling_workbench.delivery_deals.getSelectedRowId();

        if (receipt_detail_ids == null && delivery_detail_ids == null) {
            ns_scheduling_workbench.deal_menu.setItemDisabled('bookout');
            ns_scheduling_workbench.deal_menu.setItemDisabled('match');
        } else if (receipt_detail_ids != null && delivery_detail_ids == null && location_id == 'NULL') {
            ns_scheduling_workbench.deal_menu.setItemDisabled('bookout');
            ns_scheduling_workbench.deal_menu.setItemDisabled('match');
        } else if (receipt_detail_ids == null && delivery_detail_ids != null && location_id == 'NULL') {
            ns_scheduling_workbench.deal_menu.setItemDisabled('bookout');
            ns_scheduling_workbench.deal_menu.setItemDisabled('match');
        }  else if (!has_rights_scheduling_workbench_UI){
            ns_scheduling_workbench.deal_menu.setItemDisabled('bookout');
            ns_scheduling_workbench.deal_menu.setItemDisabled('match');
        } else {
            ns_scheduling_workbench.deal_menu.setItemEnabled('bookout');
            ns_scheduling_workbench.deal_menu.setItemEnabled('match');
        }
    }

    /**
    * [enable bookout button]
    */

    back_to_back = 'n';
    ns_scheduling_workbench.receipt_deal_deals_row_selection = function () {
        var receipt_detail_ids = ns_scheduling_workbench.receipts_deals.getColumnValues(ns_scheduling_workbench.receipts_deals.getColIndexById('source_deal_detail_id'));
        var delivery_detail_ids = ns_scheduling_workbench.delivery_deals.getColumnValues(ns_scheduling_workbench.delivery_deals.getColIndexById('source_deal_detail_id'));
        var location_id = 'NULL';
        var storage_id = ns_scheduling_workbench.location_storage.getSelectedRowId();
        var deal_type_names = ns_scheduling_workbench.receipts_deals.getColumnValues(ns_scheduling_workbench.receipts_deals.getColIndexById('sub_type_name'));

        var deal_type_check = false;

        if (storage_id == null) {
            location_id = 'NULL';
        } else {
            location_id = 1; //has value
        }

        var receipt_split = '';
        var delivery_split = '';
        var deal_type_split = '';

        if (receipt_detail_ids != null) {
             var receipt_split = receipt_detail_ids.split(',');
        }

        if (delivery_detail_ids != null) {
            var delivery_split = delivery_detail_ids.split(',');
        }

        if (deal_type_names != null) {
            var deal_type_split = deal_type_names.split(',');
        }


        var receipt_count = receipt_split.length;
        var delivery_count = delivery_split.length;
        var deal_type_names = deal_type_split.length;

        //need to ask
        for (var i = 0; i < deal_type_names; i++) {
            if (deal_type_split[i] != 'Agency') {
                deal_type_check = false;
                i = deal_type_names;
                back_to_back = 'n';
            } else {
                deal_type_check = true;
                back_to_back = 'n';
            }
        }

        /****************************************
                if (receipt_detail_ids == null && delivery_detail_ids == null) {
                    ns_scheduling_workbench.deal_menu.setItemDisabled('bookout');
                    ns_scheduling_workbench.deal_menu.setItemDisabled('match');
            } else if (!has_rights_scheduling_workbench_UI){
                ns_scheduling_workbench.deal_menu.setItemDisabled('bookout');
                ns_scheduling_workbench.deal_menu.setItemDisabled('match');
            } else {
                ns_scheduling_workbench.deal_menu.setItemEnabled('bookout');
                ns_scheduling_workbench.deal_menu.setItemEnabled('match');
            }
            alert(receipt_detail_ids + '_' + delivery_detail_ids + '_' + location_id)
        **************************************/

        if (receipt_detail_ids == null && delivery_detail_ids == null) {
            ns_scheduling_workbench.deal_menu.setItemDisabled('bookout');
            ns_scheduling_workbench.deal_menu.setItemDisabled('match');
        } else if (receipt_detail_ids != null && deal_type_check == true && delivery_detail_ids == null && location_id == 'NULL') {
            ns_scheduling_workbench.deal_menu.setItemEnabled('bookout');
            ns_scheduling_workbench.deal_menu.setItemEnabled('match');
        } else if (receipt_detail_ids != null && deal_type_check == false && delivery_detail_ids == null && location_id == 'NULL') {
            ns_scheduling_workbench.deal_menu.setItemDisabled('bookout');
            ns_scheduling_workbench.deal_menu.setItemDisabled('match');
        } else if (receipt_detail_ids == null && delivery_detail_ids != null && location_id == 'NULL') {
            ns_scheduling_workbench.deal_menu.setItemDisabled('bookout');
            ns_scheduling_workbench.deal_menu.setItemDisabled('match');
        } else if (!has_rights_scheduling_workbench_UI){
            ns_scheduling_workbench.deal_menu.setItemDisabled('bookout');
            ns_scheduling_workbench.deal_menu.setItemDisabled('match');
        } else {
            ns_scheduling_workbench.deal_menu.setItemEnabled('bookout');
            ns_scheduling_workbench.deal_menu.setItemEnabled('match');
        }
    }

    /**
    * [enable disable remove bookout button]
    */
    ns_scheduling_workbench.bookout_match_row_selection = function (id) {
        var bookout_id = ns_scheduling_workbench.grd_match_group.getSelectedRowId();
        var mg_index = ns_scheduling_workbench.grd_match_group.getColIndexById('match_group_id');
        var mg_value = ns_scheduling_workbench.grd_match_group.cells(bookout_id, mg_index).getValue();

        var sp_string = "EXEC spa_change_lock_unlock @flag = 's', @match_group_id = '" + mg_value + "' ";
        var data_for_post = { 'sp_string' : sp_string };
        var return_json = adiha_post_data('return_json', data_for_post, '', '', function(return_json) {
            return_json = JSON.parse(return_json);
            lock_or_unlock = return_json[0].lock_unlock;
            if (id == null) {
            ns_scheduling_workbench.bookout_match_menu.setItemDisabled('remove_bookout');
            ns_scheduling_workbench.bookout_match_menu.setItemDisabled('lock_bookout');
            ns_scheduling_workbench.bookout_match_menu.setItemDisabled('unlock_bookout');
            } else {
                if (has_rights_scheduling_workbench_del) {
                    ns_scheduling_workbench.bookout_match_menu.setItemEnabled('remove_bookout');
                } else {
                    ns_scheduling_workbench.bookout_match_menu.setItemDisabled('remove_bookout');
                }

                if (has_rights_lock_unlock) {
                    // ns_scheduling_workbench.bookout_match_menu.setItemEnabled('lock_bookout');
                    // ns_scheduling_workbench.bookout_match_menu.setItemEnabled('unlock_bookout');
                    if (lock_or_unlock == 'u') {
                        //split_match
                        ns_scheduling_workbench.context_menu_match.setItemEnabled('split_match');
                        ns_scheduling_workbench.context_menu_match.setItemEnabled('unsplit_match');
                        ns_scheduling_workbench.bookout_match_menu.setItemEnabled('remove_bookout');
                        ns_scheduling_workbench.bookout_match_menu.setItemDisabled('unlock_bookout');
                        ns_scheduling_workbench.bookout_match_menu.setItemEnabled('lock_bookout');
                    } else {
                        ns_scheduling_workbench.context_menu_match.setItemDisabled('split_match');
                        ns_scheduling_workbench.context_menu_match.setItemDisabled('unsplit_match');
                        ns_scheduling_workbench.bookout_match_menu.setItemDisabled('remove_bookout');
                        ns_scheduling_workbench.bookout_match_menu.setItemDisabled('lock_bookout');
                        ns_scheduling_workbench.bookout_match_menu.setItemEnabled('unlock_bookout');
                    }
                } else {
                    ns_scheduling_workbench.bookout_match_menu.setItemDisabled('lock_bookout');
                    ns_scheduling_workbench.bookout_match_menu.setItemDisabled('unlock_bookout');
                }
            }
        });
    }

    /**
    * [location storage grid menu case]
    */
    ns_scheduling_workbench.location_storage_menu_click = function(id) {
        switch(id) {
            case 'refresh':
                ns_scheduling_workbench.location_storage_refresh();
                break;
            case 'excel':
                ns_scheduling_workbench.location_storage.toExcel(js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                break;
            case 'pdf':
                ns_scheduling_workbench.location_storage.toPDF(js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                break;
        }
    }

    /**
    * [bookout match menu case]
    */
    ns_scheduling_workbench.bookout_match_menu_click = function(id) {
        switch(id) {
            case 'refresh':
                ns_scheduling_workbench.refresh_grid_match_bookout();
                break;
            case 'save':
                ns_scheduling_workbench.save_actual_volume();
                break;
            case 'remove_bookout':
                ns_scheduling_workbench.remove_bookout_match();
                break;
    case 'lock_bookout':
        ns_scheduling_workbench.lock();
        break;
    case 'unlock_bookout':
        ns_scheduling_workbench.unlock();
        break;
            case 'excel':
                ns_scheduling_workbench.grd_match_group.toExcel(js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                break;
            case 'pdf':
                ns_scheduling_workbench.grd_match_group.toPDF(js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                break;
            case 'workflow_status':
                open_workflow_status_report();
                break;
            case 'shipping_doc_control':
                shipping_doc_control();
                break;
            case 'scheduling_report':
                var selected_rows = ns_scheduling_workbench.grd_match_group.getSelectedRowId();
                selected_rows = selected_rows.split(",");
                var match_group_shipment_id = '';
                var match_group_shipping_col_id = '';
                var match_group_shipment_ids = '';

                selected_rows.forEach(function(id) {
                    match_group_shipping_col_id = ns_scheduling_workbench.grd_match_group.getColIndexById('match_group_shipment_id');                    
                    match_group_shipment_id = ns_scheduling_workbench.grd_match_group.cells(id ,match_group_shipping_col_id).getValue();
                    match_group_shipment_ids = match_group_shipment_id + '!' + match_group_shipment_ids;                    
                })
                match_group_shipment_ids = match_group_shipment_ids.slice(0, -1);

                data = {
                    "action": 'spa_call_report_manager_report',
                    "flag": 'scheduling_report',
                    "report_name": 'Scheduling Match Detail Report', 
                    "shipment_id": match_group_shipment_ids
                };

                adiha_post_data('return_json', data, '', '', 'ns_scheduling_workbench.scheduling_report_callback', '');

                break;
        }
    }

    ns_scheduling_workbench.scheduling_report_callback = function(result) {
        var result = JSON.parse(result);

        var shipment_id = result[0]['shipment_id']
        var paramset_id = result[0]['paramset_id']
        var items_combined = result[0]['items_combined']
        var process_id = result[0]['process_id']
        var url = '../../_reporting/report_manager_dhx/report.viewer.php?report_name=Scheduling%20Match%20Detail%20Report_Scheduling%20Match%20Detail%20Report&items_combined=' + items_combined + '&paramset_id=' + paramset_id + '&export_type=HTML4.0'

        dhxWins = new dhtmlXWindows();
        var is_win = dhxWins.isWindow('w2');
        if (is_win == true) {
            w2.close();
        }
        w2 = dhxWins.createWindow("w3", 100, 0, 1100, 500);
        w2.setText("Scheduling Match Detail Report");
        w2.setModal(true);
        w2.maximize();

        var param = {
            'sec_filters_info': 'commodity_id=NULL,contract_id=NULL,counterparty_id=NULL,deal_id=NULL,location_id=NULL,shipment_id=' + shipment_id + ',sub_id=NULL,stra_id=NULL,book_id=NULL,sub_book_id=NULL_-_' + process_id + ''
        }

        w2.attachURL(url, false, param);

        w2.attachEvent("onClose", function(win) {
              return true;
        });
    }

    ns_scheduling_workbench.lock = function() {
        var bookout_id1 = ns_scheduling_workbench.grd_match_group.getSelectedRowId();
        var mg_index1 = ns_scheduling_workbench.grd_match_group.getColIndexById('match_group_id');
        var mg_value1 = '';

        if (bookout_id1.indexOf(",") > -1) {
            bookout_id1 = bookout_id1.split(",");
            bookout_id1.forEach(function(row) {
                mg_value1 += ns_scheduling_workbench.grd_match_group.cells(row, mg_index1).getValue();
                mg_value1 += ',';
            });
            mg_value1 = mg_value1.slice(0, -1);
        } else {
            mg_value1 = ns_scheduling_workbench.grd_match_group.cells(bookout_id1, mg_index1).getValue();
        }
        update_one = "EXEC spa_change_lock_unlock @flag = 'l', @match_group_id = '" + mg_value1 + "' ";
        update_one_post = { 'sp_string' : update_one };

        var return_json = adiha_post_data('return_json', update_one_post, '', '', function(return_json) {
            return_json = JSON.parse(return_json);
            success_call('Changes have been saved successfully.');
            ns_scheduling_workbench.refresh_grid_match_bookout();
        });
    }

    ns_scheduling_workbench.unlock = function() {
        var bookout_id2 = ns_scheduling_workbench.grd_match_group.getSelectedRowId();
        var mg_index2 = ns_scheduling_workbench.grd_match_group.getColIndexById('match_group_id');
        var mg_value2 = '';

        if (bookout_id2.indexOf(",") > -1) {
            bookout_id2 = bookout_id2.split(",");
            bookout_id2.forEach(function(row) {
                mg_value2 += ns_scheduling_workbench.grd_match_group.cells(row, mg_index2).getValue();
                mg_value2 += ',';
            });
            mg_value2 = mg_value2.slice(0, -1);
        } else {
            mg_value2 = ns_scheduling_workbench.grd_match_group.cells(bookout_id2, mg_index2).getValue();
        }
        update_two = "EXEC spa_change_lock_unlock @flag = 'u', @match_group_id = '" + mg_value2 + "' ";
        update_two_post = { 'sp_string' : update_two };
        
        var return_json = adiha_post_data('return_json', update_two_post, '', '', function(return_json) {
            return_json = JSON.parse(return_json);
            success_call('Changes have been saved successfully.');
            ns_scheduling_workbench.refresh_grid_match_bookout();
        });
    }
    
    /**
    * [clear row selection]
    */
    clear_selection = function() {
        var attached_obj = ns_scheduling_workbench.deal_layout.cells('c').getAttachedObject();
        if (attached_obj instanceof dhtmlXGridObject) {
            attached_obj.clearSelection();
        }
    }

    /**
    * [remove bookout]
    */
    ns_scheduling_workbench.remove_bookout_match = function() {
        var select_id = ns_scheduling_workbench.grd_match_group.getSelectedRowId();      
        select_id = select_id.split(',');
        var is_parent_shipment = '';
        
        select_id.forEach(function(id) { 
            is_parent_shipment = ns_scheduling_workbench.grd_match_group.cells(id, ns_scheduling_workbench.grd_match_group.getColIndexById('is_parent')).getValue();

            if (is_parent_shipment == 'No') {
                dhtmlx.message({
                    title : 'Alert',
                    type : 'alert',
                    text: 'Child shipment cannot be unmatched.'
                });
                return;
            }
        });
        
        if (select_id === null) {
            return;
        } else {
            var match_group_shipment_id_col_id = ns_scheduling_workbench.grd_match_group.getColIndexById('match_group_shipment_id');
            var match_group_shipment_id = '';
            
            select_id.forEach(function(id) { 
                match_group_shipment_id = match_group_shipment_id + ns_scheduling_workbench.grd_match_group.cells(id, match_group_shipment_id_col_id).getValue() + ',';
            });
            match_group_shipment_id = match_group_shipment_id.slice(0, -1); //remove final comma
        }
 

        var data = {
            'action' : 'spa_scheduling_workbench',
            'flag' : 'r',
            'match_group_shipment_id' : match_group_shipment_id
        };
        adiha_post_data('confirm', data, '', '', 'ns_scheduling_workbench.remove_bookout_match_call_back');
    }

    /**
    * [remove bookout callback]
    */
    ns_scheduling_workbench.remove_bookout_match_call_back = function(return_value) {
       var errorcode = return_value[0]['errorcode'];

       if (errorcode == 'Error') {
            return;
       } else {
            setTimeout('reload_all_grids()', 1000);
            ns_scheduling_workbench.report_match_tab.tabs('a1').setActive();
            ns_scheduling_workbench.tab_click('a1');
       }
    }

    /**
    * [save actual volume]
    */
    ns_scheduling_workbench.save_actual_volume = function() {
        var process_id = ns_scheduling_workbench.get_process_id();
        clear_selection();
        var ids = ns_scheduling_workbench.matches_bookout.getChangedRows(true);
        var ids_split = ids.split(',');
        var changed_data_length = ids_split.length;

        if (changed_data_length == 0) {
            xml_value = 'NULL';
        } else {
            xml_value = '<gridXml>';

            for (var i = 0; i < changed_data_length; i++) {
                xml_value = xml_value + '<GridRow ';
                xml_value = xml_value + ' actual_volume="' + ns_scheduling_workbench.matches_bookout.cells(ids_split[i], 12).getValue()
                            + '" split_id="' + ns_scheduling_workbench.matches_bookout.cells(ids_split[i], 2).getValue()
                            + '" is_complete="' + ns_scheduling_workbench.matches_bookout.cells(ids_split[i], 16).getValue()
                            + '" detail_id="' + ns_scheduling_workbench.matches_bookout.cells(ids_split[i], 18).getValue()
                            + '"';

                xml_value = xml_value + '></GridRow>';
            }
            xml_value = xml_value + '</gridXml>';
        }

        var data = {
            'action' : 'spa_scheduling_workbench',
            'flag' : 'y',
            'process_id' : process_id,
            'xml_value' : xml_value
        };

        adiha_post_data('return_array', data, '', '', 'ns_scheduling_workbench.refresh_bookout_split_callback');
    }

    /**
    * [save actual volume callback]
    */
    ns_scheduling_workbench.refresh_bookout_split_callback = function(return_value) {
        if (return_value[0][0] == 'Success') {
            dhtmlx.message({
                text:return_value[0][4],
                expire:1000
            });

            setTimeout('reload_all_grids()', 1000);
        } else {
            dhtmlx.message({
                title:'Alert',
                type:"alert",
                text:return_value[0][4]
            });
            return;
        }
    }

    /**
    * [bookout menu case]
    */
    ns_scheduling_workbench.deal_menu_click = function(id) {
        switch(id) {
            case 'refresh':
                ns_scheduling_workbench.refresh_grid_receipts();
                break;
            case 'bookout':
                ns_scheduling_workbench.call_bookout_match('b', 'NULL', 'NULL', 'i', 'NULL');
                break;
            case 'match':
                var storage_select_id = ns_scheduling_workbench.location_storage.getSelectedRowId();
                var storage_select_valid = 1;
                if (storage_select_id != null && storage_select_id.split(',').length == 1) {
                    var pipeline_id = ns_scheduling_workbench.location_storage.cells(storage_select_id, ns_scheduling_workbench.location_storage.getColIndexById('pipeline_id')).getValue();
                    
                    if (pipeline_id != "" && pipeline_id != "NULL") {
                        ns_scheduling_workbench.call_injection_into_pipeline(pipeline_id);
                        storage_select_valid = 0;
                        return;
                    }
                }
                if (storage_select_valid == 1) {
                ns_scheduling_workbench.call_bookout_match('m', 'NULL', 'NULL', 'i', 'NULL');
                }               
                
                break;
            case 'excel':
                ns_scheduling_workbench.receipts_deals.toExcel(js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                break;
            case 'pdf':
                ns_scheduling_workbench.receipts_deals.toPDF(js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                break;
            case 'excel1':
                ns_scheduling_workbench.delivery_deals.toExcel(js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                break;
            case 'pdf1':
                ns_scheduling_workbench.delivery_deals.toPDF(js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                break;
            case 'save':
                ns_scheduling_workbench.save_edited_fields();
                break;
        }
    }

    /* save estimated movement date */
    ns_scheduling_workbench.save_edited_fields = function () {
        ns_scheduling_workbench.deal_layout.cells('c').progressOn();
        ns_scheduling_workbench.receipts_deals.clearSelection();
        ns_scheduling_workbench.delivery_deals.clearSelection();
        var convert_uom = report_ui['form_0'].getItemValue('quantity_uom');
        var changed_row_receipt = ns_scheduling_workbench.receipts_deals.getChangedRows();
        var changed_row_delivery = ns_scheduling_workbench.delivery_deals.getChangedRows();

        var changed_row_receipt_ids = changed_row_receipt.split(',');
        var changed_row_delivery_ids = changed_row_delivery.split(',');

        var xml_value = '<gridXml>';


        for (var i = 0; i < changed_row_receipt_ids.length - 1; i++) {
            xml_value = xml_value + '<GridRow ';
            var est_movement_date =  ns_scheduling_workbench.receipts_deals.cells(changed_row_receipt_ids[i], ns_scheduling_workbench.receipts_deals.getColIndexById('est_movement_date')).getValue();
            var est_movement_date_to =  ns_scheduling_workbench.receipts_deals.cells(changed_row_receipt_ids[i], ns_scheduling_workbench.receipts_deals.getColIndexById('est_movement_date_to')).getValue();

            var source_deal_detail_id =  ns_scheduling_workbench.receipts_deals.cells(changed_row_receipt_ids[i], ns_scheduling_workbench.receipts_deals.getColIndexById('source_deal_detail_id')).getValue();
            var split_deal_detail_volume_id =  ns_scheduling_workbench.receipts_deals.cells(changed_row_receipt_ids[i], ns_scheduling_workbench.receipts_deals.getColIndexById('split_deal_detail_volume_id')).getValue();
            var changed_quantity = ns_scheduling_workbench.receipts_deals.cells(changed_row_receipt_ids[i], ns_scheduling_workbench.receipts_deals.getColIndexById('rec_quantity')).getValue();
            var location = ns_scheduling_workbench.receipts_deals.cells(changed_row_receipt_ids[i], ns_scheduling_workbench.receipts_deals.getColIndexById('location')).getValue();
            var scheduled_from = ns_scheduling_workbench.receipts_deals.cells(changed_row_receipt_ids[i], ns_scheduling_workbench.receipts_deals.getColIndexById('scheduled_from')).getValue();
            var scheduled_to = ns_scheduling_workbench.receipts_deals.cells(changed_row_receipt_ids[i], ns_scheduling_workbench.receipts_deals.getColIndexById('scheduled_to')).getValue();
            var comments = ns_scheduling_workbench.receipts_deals.cells(changed_row_receipt_ids[i], ns_scheduling_workbench.receipts_deals.getColIndexById('comments')).getValue();
            var split_finilized_status = ns_scheduling_workbench.receipts_deals.cells(changed_row_receipt_ids[i], ns_scheduling_workbench.receipts_deals.getColIndexById('split_finilized_status')).getValue();

            xml_value = xml_value +  ' source_deal_detail_id="' + source_deal_detail_id
                                + '" est_movement_date="' + est_movement_date
                                + '" est_movement_date_to="' + est_movement_date_to
                                + '" changed_quantity="' + changed_quantity
                                + '" location="' + location
                                + '" scheduled_to="' + scheduled_to
                                + '" scheduled_from="' + scheduled_from
                                + '" comments="' + comments
                                + '" split_finilized_status="' + split_finilized_status
                                + '" split_deal_detail_volume_id="' + split_deal_detail_volume_id + '" '

            xml_value = xml_value + '></GridRow>';
        }

        for (var i = 0; i < changed_row_delivery_ids.length - 2; i++) {
            xml_value = xml_value + '<GridRow ';
            var est_movement_date =  ns_scheduling_workbench.delivery_deals.cells(changed_row_delivery_ids[i], ns_scheduling_workbench.delivery_deals.getColIndexById('est_movement_date')).getValue();
            var est_movement_date_to =  ns_scheduling_workbench.delivery_deals.cells(changed_row_delivery_ids[i], ns_scheduling_workbench.delivery_deals.getColIndexById('est_movement_date_to')).getValue();

            var source_deal_detail_id = ns_scheduling_workbench.delivery_deals.cells(changed_row_delivery_ids[i], ns_scheduling_workbench.delivery_deals.getColIndexById('source_deal_detail_id')).getValue();
            var split_deal_detail_volume_id = ns_scheduling_workbench.delivery_deals.cells(changed_row_delivery_ids[i], ns_scheduling_workbench.delivery_deals.getColIndexById('split_deal_detail_volume_id')).getValue();
            var changed_quantity = ns_scheduling_workbench.delivery_deals.cells(changed_row_delivery_ids[i], ns_scheduling_workbench.delivery_deals.getColIndexById('del_quantity')).getValue();
            var location = ns_scheduling_workbench.delivery_deals.cells(changed_row_delivery_ids[i], ns_scheduling_workbench.delivery_deals.getColIndexById('location')).getValue();
            var scheduled_from = ns_scheduling_workbench.delivery_deals.cells(changed_row_delivery_ids[i], ns_scheduling_workbench.delivery_deals.getColIndexById('scheduled_from')).getValue();
            var scheduled_to = ns_scheduling_workbench.delivery_deals.cells(changed_row_delivery_ids[i], ns_scheduling_workbench.delivery_deals.getColIndexById('scheduled_to')).getValue();
            var comments = ns_scheduling_workbench.delivery_deals.cells(changed_row_delivery_ids[i], ns_scheduling_workbench.delivery_deals.getColIndexById('comments')).getValue();
            var split_finilized_status = ns_scheduling_workbench.delivery_deals.cells(changed_row_delivery_ids[i], ns_scheduling_workbench.delivery_deals.getColIndexById('split_finilized_status')).getValue();

            xml_value = xml_value +  'source_deal_detail_id="' + source_deal_detail_id
                                    + '" est_movement_date="' + est_movement_date
                                    + '" est_movement_date_to="' + est_movement_date_to
                                    + '" changed_quantity="' + changed_quantity
                                    + '" location="' + location
                                    + '" scheduled_to="' + scheduled_to
                                    + '" scheduled_from="' + scheduled_from
                                    + '" comments="' + comments
                                    + '" split_finilized_status="' + split_finilized_status
                                    + '" split_deal_detail_volume_id="' + split_deal_detail_volume_id + '" ';

            xml_value = xml_value + '></GridRow>';
        }


        xml_value = xml_value + '</gridXml>';

        var sql_param = {
            'action' : 'spa_scheduling_workbench',
            'flag' : 'e',
            'xml_value' : xml_value,
            'convert_uom' : convert_uom
        }

        adiha_post_data('return_array', sql_param, '', '', 'ns_scheduling_workbench.save_est_movement_date_call_back');
    }


    /* est movement date callback*/
    ns_scheduling_workbench.save_est_movement_date_call_back = function(return_value) {
        ns_scheduling_workbench.deal_layout.cells('c').progressOff();
        if (return_value[0][0] == 'Success') {
            dhtmlx.message({
                text : return_value[0][4],
                expire : 1000
            });

            setTimeout('reload_all_grids()', 1000);
        } else {
            dhtmlx.message({
                title : 'Alert',
                type : 'alert',
                text : return_value[0][4]
            });
            return;
        }
    }

    /**
    * [open deal volume split window]
    */
    ns_scheduling_workbench.deal_detail_volume_split_window = function(spilt_deal_detail_id, total_split_volume, split_deal_detail_volume_id) {
        var process_id = ns_scheduling_workbench.get_process_id();
        var converted_uom = report_ui['form_0'].getItemValue('quantity_uom');
        var url = '';
        var params =  '?spilt_deal_detail_id='+ spilt_deal_detail_id
                        + '&total_split_volume=' + total_split_volume
                        + '&split_deal_detail_volume_id=' + split_deal_detail_volume_id
                        + '&process_id=' + process_id
                        + '&converted_uom=' + converted_uom;

        unload_deal_detail_spilt_window_window();

        if (!deal_detail_spilt_window) {
            deal_detail_spilt_window = new dhtmlXWindows();
        }

        var new_win = deal_detail_spilt_window.createWindow('w2', 0, 0, 850, 600);

        url = '<?php echo $app_php_script_loc; ?>' +  '../adiha.html.forms/_scheduling_delivery/scheduling_workbench/deal.detail.split.volume.php' + params;
        new_win.setText('Deal Detail Split');
        new_win.centerOnScreen();
        new_win.setModal(true);
        new_win.attachURL(url, false, true);
    }


    var deal_detail_spilt_window;
    /**
     * [Unload deal detail split window.]
     */
    function unload_deal_detail_spilt_window_window() {
        if (deal_detail_spilt_window != null && deal_detail_spilt_window.unload != null) {
            deal_detail_spilt_window.unload();
            deal_detail_spilt_window = w2 = null;
        }
    }

    var bookout_match_window;
    /**
     * [unload_bookout_match_window Unload invoice export window.]
     */
    function unload_bookout_match_window() {
        if (bookout_match_window != null && bookout_match_window.unload != null) {
            bookout_match_window.unload();
            bookout_match_window = w1 = null;
        }
    }

    /**
     * [Opens match window]
     */
    ns_scheduling_workbench.call_bookout_match = function(bookout_match, match_id, shipment_name, mode, match_group_id) {
        var product_type = '<?php echo $product_type; ?>';
        var selected_receipt_ids = '';
        var selected_delivery_ids = '';
        var product_description = '';
        var term_start = report_ui['form_0'].getItemValue('period_from', true);

        if (mode == 'i') {
            selected_receipt_ids = (ns_scheduling_workbench.receipts_deals.getSelectedRowId() == null) ? 'NULL' : ns_scheduling_workbench.receipts_deals.getSelectedRowId().split(',');
            selected_delivery_ids = (ns_scheduling_workbench.delivery_deals.getSelectedRowId() == null) ? 'NULL' : ns_scheduling_workbench.delivery_deals.getSelectedRowId().split(',');
        }

        var process_id = ns_scheduling_workbench.get_process_id();
        var convert_uom = report_ui['form_0'].getItemValue('quantity_uom');
        var convert_frequency = report_ui['form_0'].getItemValue('frequency');

        var receipt_detail_ids = '';
        var delivery_detail_ids = '';

        if (selected_receipt_ids != 'NULL') {
            for (var i = 0; i < selected_receipt_ids.length; i++) {
                var receipt_detail_ids = receipt_detail_ids + ns_scheduling_workbench.receipts_deals.cells(selected_receipt_ids[i], ns_scheduling_workbench.receipts_deals.getColIndexById('deal_detail_id_split_deal_detail_volume_id')).getValue() + ',' ;
            }
            receipt_detail_ids = receipt_detail_ids.slice(0,-1);
        }

        if (selected_delivery_ids != 'NULL') {
            for (var i = 0; i < selected_delivery_ids.length; i++) {
                var delivery_detail_ids = delivery_detail_ids + ns_scheduling_workbench.delivery_deals.cells(selected_delivery_ids[i], ns_scheduling_workbench.receipts_deals.getColIndexById('deal_detail_id_split_deal_detail_volume_id')).getValue() + ',' ;
            }
            delivery_detail_ids = delivery_detail_ids.slice(0,-1);
        }

        var location_id = '';
        var base_id = '';
        var commodity_id = '';
        var product_description = '';
        var lot = '';
        var location_commodity_product_base_id = '';
        var storage_location_volume = '';
        var storage_id = ns_scheduling_workbench.location_storage.getSelectedRowId();
        var total_str_volume = '';

        var seq_no = ''; //added logic to take values from process table
        var seq_no_str = '';

        if (storage_id != null) {
            var storage_ids_arr = storage_id.split(',');

            for (var i = 0; i < storage_ids_arr.length; i++) {
                location_id =  ns_scheduling_workbench.location_storage.cells(storage_ids_arr[i], ns_scheduling_workbench.location_storage.getColIndexById('source_minor_location_id')).getValue();
                commodity_id = ns_scheduling_workbench.location_storage.cells(storage_ids_arr[i], ns_scheduling_workbench.location_storage.getColIndexById('commodity_id')).getValue();
                product_description = ns_scheduling_workbench.location_storage.cells(storage_ids_arr[i], ns_scheduling_workbench.location_storage.getColIndexById('product')).getValue();
                base_id = ns_scheduling_workbench.location_storage.cells(storage_ids_arr[i], ns_scheduling_workbench.location_storage.getColIndexById('parent_source_deal_header_id')).getValue();
                lot = ns_scheduling_workbench.location_storage.cells(storage_ids_arr[i], ns_scheduling_workbench.location_storage.getColIndexById('lot')).getValue();
                total_str_volume = ns_scheduling_workbench.location_storage.cells(storage_ids_arr[i], ns_scheduling_workbench.location_storage.getColIndexById('balance_quantity')).getValue();
                seq_no_str = ns_scheduling_workbench.location_storage.cells(storage_ids_arr[i], ns_scheduling_workbench.location_storage.getColIndexById('seq_no')).getValue();
                
                seq_no = seq_no + seq_no_str +  ':';
                storage_location_volume = storage_location_volume
                                        + location_id + '^'
                                        + product_description + '^'
                                        + total_str_volume + '^'
                                        + base_id + ':';
                                        
            }

            seq_no = seq_no.slice(0, -1); //location_commodity_product_base_id.slice(0, -1);
            storage_location_volume = storage_location_volume.slice(0, -1);
        }  else {
            location_id = 'NULL';
            base_id = 'NULL';
            commodity_id = 'NULL';
            product_description = 'NULL';
            location_contract_commodity = 'NULL';
            lot = 'NULL';
            storage_location_volume = 'NULL';
        }

        if (mode == 'i') {
            if (selected_receipt_ids != 'NULL' && selected_delivery_ids != 'NULL' && location_id != 'NULL') {
                dhtmlx.message({
                    title: 'Alert',
                    type: "alert",
                    text: 'Invalid selection in Receipts, Deliveries and Storage Report grids. Please select data from two grids only.'
                });
                return;
            }
        }

        if (mode == 'u') location_id = 'NULL';

        if (mode == 'i') {
            var sql_param = {
                'action':'spa_scheduling_workbench',
                'flag':'h',
                'process_id': process_id,
                'buy_deals': receipt_detail_ids,
                'sell_deals': delivery_detail_ids,
                'convert_uom' : convert_uom,
                'convert_frequency' : convert_frequency,
                'mode' : mode,
                'bookout_match' : bookout_match,
                'term_start' : term_start,
                'location_contract_commodity' : seq_no,
                'match_group_id' : match_group_id,
                'product_type' : product_type
            }

            adiha_post_data('return_array', sql_param, '', '', 'ns_scheduling_workbench.commodity_check_callback');
        } else {
            var params = '?receipt_detail_ids=' + receipt_detail_ids +
                        '&delivery_detail_ids=' + delivery_detail_ids +
                        '&process_id=' + process_id +
                        '&convert_uom=' + convert_uom +
                        '&convert_frequency=' + convert_frequency +
                        '&mode=' + mode +
                        '&bookout_match=' + bookout_match +
                        '&location_id=' + location_id +
                        '&shipment_name=' + shipment_name +
                        '&match_id=' + match_id +
                        '&match_group_id=' + match_group_id +
                        '&term_start=' + term_start +
                        '&save_enable=true';

            unload_bookout_match_window();

            if (!bookout_match_window) {
                bookout_match_window = new dhtmlXWindows();
            }
            var url = '';
            var new_win = bookout_match_window.createWindow('w1', 0, 0, 420, 430);

            url = '<?php echo $app_php_script_loc; ?>' +  '../adiha.html.forms/_scheduling_delivery/scheduling_workbench/match.php' + params;

            new_win.setText('Match');
            new_win.centerOnScreen();
            new_win.setModal(true);
            new_win.maximize();
            new_win.attachURL(url, false, true);
        }
    }

    /**
    * [return function for after transportation deal check]
    */
    ns_scheduling_workbench.commodity_check_callback = function(return_value) {

        if (return_value[0][0] == 'Success') {
            var receipt_detail_ids = '';
            var delivery_detail_ids = '';
            var selected_receipt_ids = (ns_scheduling_workbench.receipts_deals.getSelectedRowId() == null) ? 'NULL' : ns_scheduling_workbench.receipts_deals.getSelectedRowId().split(',');
            var selected_delivery_ids = (ns_scheduling_workbench.delivery_deals.getSelectedRowId() == null) ? 'NULL' : ns_scheduling_workbench.delivery_deals.getSelectedRowId().split(',');

            var bookout_match = return_value[0][5];
            var mode = 'i';
            var process_id = ns_scheduling_workbench.get_process_id();
            var convert_uom = report_ui['form_0'].getItemValue('quantity_uom');
            var convert_frequency = report_ui['form_0'].getItemValue('frequency');

            if (selected_receipt_ids != 'NULL') {
                for (var i = 0; i < selected_receipt_ids.length; i++) {
                    var receipt_detail_ids = receipt_detail_ids + ns_scheduling_workbench.receipts_deals.cells(selected_receipt_ids[i], ns_scheduling_workbench.receipts_deals.getColIndexById('deal_detail_id_split_deal_detail_volume_id')).getValue() + ',' ;
                }
                receipt_detail_ids = receipt_detail_ids.slice(0,-1);
            }

            if (selected_delivery_ids != 'NULL') {
                for (var i = 0; i < selected_delivery_ids.length; i++) {
                    var delivery_detail_ids = delivery_detail_ids + ns_scheduling_workbench.delivery_deals.cells(selected_delivery_ids[i], ns_scheduling_workbench.receipts_deals.getColIndexById('deal_detail_id_split_deal_detail_volume_id')).getValue() + ',' ;
                }
                delivery_detail_ids = delivery_detail_ids.slice(0,-1);
            }

            var location_id = '';
            var base_id = '';
            var commodity_id = '';
            var product_description = '';
            var location_commodity_product_base_id = '';
            var lot = '';
            var total_str_volume = '';
            var storage_location_volume = '';
            var storage_id = ns_scheduling_workbench.location_storage.getSelectedRowId();
            var batch_id = '';
            var storage_deal_id = '';
            var seq_no = '';

            if (storage_id != null) {
                var storage_ids_arr = storage_id.split(',');

                for (var i = 0; i < storage_ids_arr.length; i++) {
                    location_id =  ns_scheduling_workbench.location_storage.cells(storage_ids_arr[i], ns_scheduling_workbench.location_storage.getColIndexById('source_minor_location_id')).getValue();
                    commodity_id = ns_scheduling_workbench.location_storage.cells(storage_ids_arr[i], ns_scheduling_workbench.location_storage.getColIndexById('commodity_id')).getValue();
                    product_description = ns_scheduling_workbench.location_storage.cells(storage_ids_arr[i], ns_scheduling_workbench.location_storage.getColIndexById('product')).getValue();
                    base_id = ns_scheduling_workbench.location_storage.cells(storage_ids_arr[i], ns_scheduling_workbench.location_storage.getColIndexById('parent_source_deal_header_id')).getValue();
                    lot = ns_scheduling_workbench.location_storage.cells(storage_ids_arr[i], ns_scheduling_workbench.location_storage.getColIndexById('lot')).getValue();
                    batch_id = 'NULL'; //ns_scheduling_workbench.location_storage.cells(storage_ids_arr[i], ns_scheduling_workbench.location_storage.getColIndexById('production_batch_reference_id')).getValue();
                    total_str_volume = ns_scheduling_workbench.location_storage.cells(storage_ids_arr[i], ns_scheduling_workbench.location_storage.getColIndexById('balance_quantity')).getValue();
                    storage_deal_id = ns_scheduling_workbench.location_storage.cells(storage_ids_arr[i], ns_scheduling_workbench.location_storage.getColIndexById('storage_deal_id')).getValue();

                    seq_no_str = ns_scheduling_workbench.location_storage.cells(storage_ids_arr[i], ns_scheduling_workbench.location_storage.getColIndexById('seq_no')).getValue();
               

                    if (base_id == '') base_id = 'NULL';
                    location_commodity_product_base_id = location_commodity_product_base_id +
                                                        + location_id + '^'
                                                        + commodity_id + '^'
                                                        + product_description + '^'
                                                        + base_id + '^'
                                                    + lot + '_' + batch_id + '_' + storage_deal_id + ':';
                    seq_no = seq_no + seq_no_str + ':';
                    storage_location_volume = storage_location_volume
                                        + location_id + '^'
                                        + product_description + '^'
                                        + total_str_volume + '^'
                                    + base_id + '^' 
                                    + lot + '_' + batch_id + ':';
                }
                
                location_commodity_product_base_id = location_commodity_product_base_id.slice(0, -1);
                storage_location_volume = storage_location_volume.slice(0, -1);
                seq_no = seq_no.slice(0, -1);
            } else {
                location_id = 'NULL';
                base_id = 'NULL';
                commodity_id = 'NULL';
                product_description = 'NULL';
                location_contract_commodity = 'NULL';
                lot = 'NULL';
                storage_location_volume = 'NULL';
                seq_no = 'NULL';
            }



            var product_type = '<?php echo $product_type; ?>';
            var params = '?receipt_detail_ids=' + receipt_detail_ids +
                        '&delivery_detail_ids=' + delivery_detail_ids +
                        '&process_id=' + process_id +
                        '&convert_uom=' + convert_uom +
                        '&convert_frequency=' + convert_frequency +
                        '&mode=' + mode +
                        '&bookout_match=' + bookout_match +
                        '&location_contract_commodity=' + seq_no +
                        '&storage_location_volume=' + storage_location_volume +
                        '&shipment_name=NULL&match_id=NULL' +
                        '&save_enable=true' +
                        '&back_to_back=' + back_to_back + 
                        '&product_type=' + product_type;

            unload_bookout_match_window();

            if (!bookout_match_window) {
                bookout_match_window = new dhtmlXWindows();
            }

            var url = '';
            var new_win = bookout_match_window.createWindow('w1', 0, 0, 420, 430);

            if (bookout_match == 'b') {
                url = '<?php echo $app_php_script_loc; ?>' +  '../adiha.html.forms/_scheduling_delivery/scheduling_workbench/bookout.php' + params;
                new_win.setText('Bookout');
                new_win.centerOnScreen();
                new_win.setModal(true);
            } else {
                url = '<?php echo $app_php_script_loc; ?>' +  '../adiha.html.forms/_scheduling_delivery/scheduling_workbench/match.php' + params;
                new_win.setText('Match');
                new_win.centerOnScreen();
                new_win.setModal(true);
                new_win.maximize();
            }
            new_win.attachURL(url, false, true);
        } else {
            dhtmlx.message({
                title : 'Error',
                type : 'alert-error',
                text : return_value[0][4]
            });
            return;
        }
    }

    /**
    * [call_bookout_match callback]
    */
    ns_scheduling_workbench.call_bookout_match_callback = function(return_value) {
        if (return_value[0][0] == 'Success') {
            dhtmlx.message({
                text : return_value[0][4],
                expire : 1000
            });

            setTimeout('reload_all_grids()', 1000);
        } else {
            dhtmlx.message({
                title : 'Error',
                type : 'alert-error',
                text : return_value[0][4]
            });
            return;
        }
    }

    first_load_check_collapse = '';

    /**
    * [refresh grid with filters receipts and delivery]
    */
    ns_scheduling_workbench.refresh_grid_receipts = function() {
        ns_scheduling_workbench.report_match_tab.tabs('a1').setActive();
        ns_scheduling_workbench.tab_click('a1');
        var process_id = ns_scheduling_workbench.get_process_id();
        var filter_xml = get_filter_paramters();

        if (filter_xml == 'NULL') {
            return;
        }
        ns_scheduling_workbench.deal_layout.cells('c').progressOn();

        if (first_load_check_collapse != '') ns_scheduling_workbench.deal_layout.cells('b').collapse();

        filter_xml = escapeXML(filter_xml);

        var sql_param = {
            'action':'spa_scheduling_workbench',
            'flag':'s',
            'grid_type':'g',
            'buy_sell_flag' : 'b',
            'process_id': process_id,
            'filter_xml' : filter_xml,
            'product_type' : product_type //fugible
        };

        sql_param = $.param(sql_param);
        var sql_url = js_data_collector_url + '&' + sql_param;
        ns_scheduling_workbench.receipts_deals.clearAll();
        var total = new Array();
        ns_scheduling_workbench.receipts_deals.loadXML(sql_url, function() {
            total[0] = ns_scheduling_workbench.receipts_deals.getColIndexById('rec_quantity');
            total[1] = ns_scheduling_workbench.receipts_deals.getColIndexById('bal_quantity');
            total[2] = ns_scheduling_workbench.receipts_deals.getColIndexById('contractual_volume');
            total[3] = ns_scheduling_workbench.receipts_deals.getColIndexById('actual_volume');

            var del_quantity_total = 0;
            var bal_quantity_total = 0;
            var contractual_volume_total = 0;
            var actual_volume_total = 0;

            var exist = ns_scheduling_workbench.receipts_deals.doesRowExist('rectotalid');

            if (!exist) {
                ns_scheduling_workbench.receipts_deals.forEachRow(function(id) {
                    del_quantity_total += parseFloat(ns_scheduling_workbench.receipts_deals.cells(id,total[0]).getValue());
                    bal_quantity_total += parseFloat(ns_scheduling_workbench.receipts_deals.cells(id,total[1]).getValue());
                    contractual_volume_total += parseFloat(ns_scheduling_workbench.receipts_deals.cells(id,total[2]).getValue());
                    actual_volume_total += ns_scheduling_workbench.receipts_deals.cells(id,total[3]).getValue();
                });

                var id = 'rectotalid';
                ns_scheduling_workbench.receipts_deals.addRow(id, '') // add total row
                ns_scheduling_workbench.receipts_deals.setRowColor(id,'#FFFFCC')

                ns_scheduling_workbench.receipts_deals.cells(id,0).setValue('Total:');   // set total value
                ns_scheduling_workbench.receipts_deals.cells(id,total[0]).setValue(del_quantity_total.toFixed(4));   // set total value
                ns_scheduling_workbench.receipts_deals.cells(id,total[1]).setValue(bal_quantity_total.toFixed(4));   // set total value
                ns_scheduling_workbench.receipts_deals.cells(id,total[2]).setValue(contractual_volume_total.toFixed(4));   // set total value

                if (actual_volume_total != 0) {
                    ns_scheduling_workbench.receipts_deals.cells(id,total[3]).setValue(actual_volume_total);   // set total value
                }
            }
            ns_scheduling_workbench.receipts_deals.filterByAll();
            var sql_param_delivery = {
                'action' : 'spa_scheduling_workbench',
                'flag' : 's',
                'grid_type' : 'g',
                'buy_sell_flag' : 's',
                'process_id': process_id,
                'filter_xml' : filter_xml
            };
            ns_scheduling_workbench.refresh_grid_delivery(sql_param_delivery);
        });

    }

    /**
    * [refresh grid with filters delivery]
    */
    ns_scheduling_workbench.refresh_grid_delivery = function(sql_param_delivery) {
        sql_param = $.param(sql_param_delivery);
        var sql_url = js_data_collector_url + '&' + sql_param;
        ns_scheduling_workbench.delivery_deals.clearAll();
        var total = new Array();
        ns_scheduling_workbench.delivery_deals.loadXML(sql_url, function() {
            total[0] = ns_scheduling_workbench.delivery_deals.getColIndexById('del_quantity');
            total[1] = ns_scheduling_workbench.delivery_deals.getColIndexById('bal_quantity');
            total[2] = ns_scheduling_workbench.delivery_deals.getColIndexById('contractual_volume');
            total[3] = ns_scheduling_workbench.delivery_deals.getColIndexById('actual_volume');

            var del_quantity_total = 0;
            var bal_quantity_total = 0;
            var contractual_volume_total = 0;
            var actual_volume_total = 0;

            var exist = ns_scheduling_workbench.delivery_deals.doesRowExist('deltotalid');

            if (!exist) {
                ns_scheduling_workbench.delivery_deals.forEachRow(function(id) {
                    del_quantity_total += parseFloat(ns_scheduling_workbench.delivery_deals.cells(id,total[0]).getValue());
                    bal_quantity_total += parseFloat(ns_scheduling_workbench.delivery_deals.cells(id,total[1]).getValue());
                    contractual_volume_total += parseFloat(ns_scheduling_workbench.delivery_deals.cells(id,total[2]).getValue());
                    actual_volume_total += ns_scheduling_workbench.delivery_deals.cells(id,total[3]).getValue();
                });

                var id = 'deltotalid'; //ns_scheduling_workbench.delivery_deals.getUID();
                ns_scheduling_workbench.delivery_deals.addRow(id, '')   // add total row
                ns_scheduling_workbench.delivery_deals.setRowColor(id,'#FFFFCC')

                ns_scheduling_workbench.delivery_deals.cells(id,0).setValue('Total:');   // set total value
                ns_scheduling_workbench.delivery_deals.cells(id,total[0]).setValue(del_quantity_total.toFixed(4));   // set total value
                ns_scheduling_workbench.delivery_deals.cells(id,total[1]).setValue(bal_quantity_total.toFixed(4));   // set total value
                ns_scheduling_workbench.delivery_deals.cells(id,total[2]).setValue(contractual_volume_total.toFixed(4));   // set total value

                if (actual_volume_total != 0) {
                    ns_scheduling_workbench.delivery_deals.cells(id,total[3]).setValue(actual_volume_total);   // set total value
                }

                /* sub total start*/
                var count = ns_scheduling_workbench.receipts_deals.getRowsNum();
                var reciept_row_id = ns_scheduling_workbench.receipts_deals.getRowId(count-1);
                var sub_total_del_quantity = parseFloat(ns_scheduling_workbench.receipts_deals.cells(reciept_row_id,total[0]).getValue()) - parseFloat(ns_scheduling_workbench.delivery_deals.cells(id,total[0]).getValue());
                var sub_total_bal_quantity = parseFloat(ns_scheduling_workbench.receipts_deals.cells(reciept_row_id,total[1]).getValue()) - parseFloat(ns_scheduling_workbench.delivery_deals.cells(id,total[1]).getValue());
                var sub_total_del_contractual_volume = parseFloat(ns_scheduling_workbench.receipts_deals.cells(reciept_row_id,total[2]).getValue()) - parseFloat(ns_scheduling_workbench.delivery_deals.cells(id,total[2]).getValue());
                var sub_total_id = ns_scheduling_workbench.delivery_deals.getUID();

                ns_scheduling_workbench.delivery_deals.addRow(sub_total_id, '')   // add total row
                ns_scheduling_workbench.delivery_deals.setRowColor(sub_total_id,'#FFFFCC')
                ns_scheduling_workbench.delivery_deals.cells(sub_total_id,0).setValue('Net Position:');   // set total value
                ns_scheduling_workbench.delivery_deals.cells(sub_total_id,total[0]).setValue(sub_total_del_quantity.toFixed(4));   // set total value
                ns_scheduling_workbench.delivery_deals.cells(sub_total_id,total[1]).setValue(sub_total_bal_quantity.toFixed(4));   // set total value
                ns_scheduling_workbench.delivery_deals.cells(sub_total_id,total[2]).setValue(sub_total_del_contractual_volume.toFixed(4));   // set total value

            }
            ns_scheduling_workbench.delivery_deals.filterByAll();

        });

        ns_scheduling_workbench.receipt_deal_deals_row_selection();
        first_load_check_collapse = 1;
        ns_scheduling_workbench.deal_layout.cells('c').progressOff();
    }

    /**
    * [refresh grid with filters storage lcoation grid]
    */
    ns_scheduling_workbench.location_storage_refresh = function() {
        var process_id = ns_scheduling_workbench.get_process_id();
        var filter_xml = get_filter_paramters();

        if (filter_xml == 'NULL') {
            return;
        }

        var data = {
            'action' : 'spa_storage_position_report_sw',
            'summary_detail' : 's',
            'call_from' : 'r',
            'filter_xml' : filter_xml,
            'process_id' : process_id,
            'product_type' : product_type,
            'grid_type' : 'tg',
            'grouping_column' : 'grouper,location_name'
        };

        sql_param = $.param(data);
        var sql_url = js_data_collector_url + '&' + sql_param;
        ns_scheduling_workbench.location_storage.clearAll();

        ns_scheduling_workbench.location_storage.loadXML(sql_url, function(){
            ns_scheduling_workbench.location_storage.filterByAll();
            ns_scheduling_workbench.location_storage.expandAll();
        });
    }

    /**
    * [function to set comma separated selected options on combo text.]
    */
    function fx_set_combo_text_final(cmb_obj) {
        var checked_loc_arr = cmb_obj.getChecked();
        var final_combo_text = new Array();
        var final_combo_value = new Array();
        $.each(checked_loc_arr, function(i) {
            var opt_obj = cmb_obj.getOption(checked_loc_arr[i]);
            final_combo_text.push(opt_obj.text);
            final_combo_value.push(opt_obj.value);
        });
        cmb_obj.setComboText(final_combo_text.join(','));
    }

    /**
    * [load location ]
    */
    ns_scheduling_workbench.cmb_location_pre_populate = function() {
        var cm_param = {
            'action': 'spa_source_minor_location',
            'flag': 'f',
            'source_major_location_ID':'NULL'
        };
    
        cm_param = $.param(cm_param);
        var url = js_dropdown_connector_url + '&' + cm_param;

        url = decodeURIComponent(url);

                var cm_data = report_ui['form_0'].getCombo('location');
                cm_data.clearAll();
                cm_data.setComboText('');
        cm_data.load(url, function(e) {});   
    }

    /**
    * [load commodity]
    */
    ns_scheduling_workbench.cmb_commodity_pre_populate = function() {
        var cm_param = {
            'action': 'spa_source_commodity_maintain',
            'has_blank_option': 'false',
            'flag': 'z',
            'commodity_group':'NULL'
        };

        cm_param = $.param(cm_param);
        var url = js_dropdown_connector_url + '&' + cm_param;
                url = decodeURIComponent(url);
                var cm_data = report_ui['form_1'].getCombo('commodity_id');

                cm_data.clearAll();
                cm_data.setComboText('');
        cm_data.load(url, function(e) {});
    }

    function get_selected_uom() {
        var inner_tab_obj = ns_scheduling_workbench.deal_layout.cells("b").getAttachedObject();
        var tab_name = '';
        var selected_uom = '';

        inner_tab_obj.forEachTab(function(tab){
            tab_name = tab.getText();
            form_obj = tab.getAttachedObject();

            var status = validate_form(form_obj);


            data = form_obj.getFormData();

            for (var name in data) {
                var item_type = form_obj.getItemType(name);

                if (item_type != 'block' && item_type!= 'fieldset'&& item_type!= 'button') {
                    if (name == 'quantity_uom') {
                       selected_uom = data[name];
                    }
                }
            }
        });

        return selected_uom;
    }

    function get_filter_paramters() {
        var filter_xml = '<Root><FormFilterXML ';
        var inner_tab_obj = ns_scheduling_workbench.deal_layout.cells("b").getAttachedObject();

        var check_status = 'true';
        var tab_name = '';
        var period_from = '';
        var period_to = '';

        inner_tab_obj.forEachTab(function(tab) {
            tab_name = tab.getText();
            form_obj = tab.getAttachedObject();

            var status = validate_form(form_obj);

            if (status == false) {
                check_status = 'NULL';
                return;
            }

            data = form_obj.getFormData();

            for (var name in data) {
                var item_type = form_obj.getItemType(name);

                if (item_type != 'block' && item_type!= 'fieldset'&& item_type!= 'button') {
                    if (name != 'apply_filters') {
                        if (item_type == 'calendar') {
                            value = form_obj.getItemValue(name, true);
                            if (name == 'period_from') period_from = value;
                            if (name == 'period_to') period_to = value;

                        } else if (item_type == 'checkbox') {
                            value = (form_obj.isItemChecked(name)) === true ? 'y' : 'n';
                        } else {
                            value = data[name];
                        }
                        filter_xml +=  name + '="' + value + '" ';
                    }
                }
            }
        });

        if (period_from > period_to) {
            check_status = 'NULL';
            dhtmlx.message({
                title : 'Alert',
                type : 'alert',
                text: 'Period from cannot be greater then Period to'
            });
        }

        filter_xml += '></FormFilterXML></Root>';

        if (check_status == 'NULL') {
            filter_xml = 'NULL';
        }

        return filter_xml;
    }

    /**
    * [reload all grids]
    */
    function reload_all_grids() {
        var filter_xml = get_filter_paramters();
        if (filter_xml == 'NULL') {
            return;
        }

        var data = {
            'action' : 'spa_scheduling_workbench',
            'flag' : 's',
            'filter_xml' : filter_xml
        };
        adiha_post_data('return_array', data, '', '', 'ns_scheduling_workbench.reload_all_grids_call_back');
    }

    /**
    * [reload all grids callback]
    */
    ns_scheduling_workbench.reload_all_grids_call_back = function (return_value) {
        var process_id = return_value[0][0];
        report_ui["form_0"].setItemValue('process_id', process_id);
        ns_scheduling_workbench.refresh_grid_receipts();
        ns_scheduling_workbench.refresh_grid_match_bookout();
        ns_scheduling_workbench.location_storage_refresh();
    }

    //load status in sequence
    function load_pre_allocation_dd() {
        return;
        var cm_param = {
            "action": "spa_execute_query",
            "query": "[''47000'', ''Allocation''],[''47006'', ''Live | At Buyers''],[''47001'', ''Live | At Sellers''],[''47004'', ''Live | At Warehouse''],[''47003'', ''Live | Terminal''],[''47005'', ''Live | Transit Land''],[''47002'', ''Live | Transit Sea''],[47007, ''Finished'']",
            "has_blank_option": "true"
        };

        cm_param = $.param(cm_param);
        var url = js_dropdown_connector_url + '&' + cm_param

        combo_obj_mf = report_ui["form_0"].getCombo('schedule_match_status');
        combo_obj_mf.load(url, function(){
            report_ui["form_0"].setItemValue('schedule_match_status', '');
        });
    }

    /*
     * [Open workflow status report for scheduling]
     */
    open_workflow_status_report = function() {
        var selected_row = ns_scheduling_workbench.grd_match_group.getSelectedRowId();

        if (selected_row == null) {
            show_messagebox('Please select the Match Group.');
            return;
        }

        if (selected_row.indexOf(',') > -1) {
            show_messagebox('Please select single Match Group.');
            return;
        }

        var shippment_id = ns_scheduling_workbench.grd_match_group.cells(selected_row, ns_scheduling_workbench.grd_match_group.getColIndexById('match_group_shipment_id')).getValue();
        var match_group_id = ns_scheduling_workbench.grd_match_group.cells(selected_row, ns_scheduling_workbench.grd_match_group.getColIndexById('match_group_id')).getValue();
        var process_table_xml = 'mgs_match_group_shipment_id:' + shippment_id;
        var shippment = ns_scheduling_workbench.grd_match_group.cells(selected_row, ns_scheduling_workbench.grd_match_group.getColIndexById('match_group_shipment')).getValue();
        var filter_string = shippment;
        var workflow_report = new dhtmlXWindows();
        workflow_report_win = workflow_report.createWindow('w1', 0, 0, 900, 700);
        workflow_report_win.setText("Workflow Status");
        workflow_report_win.centerOnScreen();
        workflow_report_win.setModal(true);
        workflow_report_win.maximize();

        var page_url = js_php_path + '../adiha.html.forms/_compliance_management/setup_rule_workflow/workflow.report.php?filter_id=' + shippment_id + '&source_column=mgs_match_group_shipment_id&module_id=20611&process_table_xml=' + process_table_xml + '&filter_string=' + filter_string;
        workflow_report_win.attachURL(page_url, false, null);
    }

    shipping_doc_control = function(){
        var selected_row = ns_scheduling_workbench.grd_match_group.getSelectedRowId();

        if (selected_row == null) {
            show_messagebox('Please select the Match Group.');
            return;
        }

        if (selected_row.indexOf(',') > -1) {
            show_messagebox('Please select single Match Group.');
            return;
        }

        var shippment_id = ns_scheduling_workbench.grd_match_group.cells(selected_row, ns_scheduling_workbench.grd_match_group.getColIndexById('match_group_shipment_id')).getValue();
        var shipping_doc_ctrl_win = new dhtmlXWindows();

        doc_win = shipping_doc_ctrl_win.createWindow('w1', 0, 0, 1100, 600);
        doc_win.setText("Shipping Document Control");
        doc_win.centerOnScreen();
        doc_win.setModal(true);

        var page_url = js_php_path + '../adiha.html.forms/_scheduling_delivery/scheduling_workbench/shippment.document.control.php?shippment_id=' + shippment_id;
        doc_win.attachURL(page_url, false, null);
    }
    
    </script>   
    </body>
</html>