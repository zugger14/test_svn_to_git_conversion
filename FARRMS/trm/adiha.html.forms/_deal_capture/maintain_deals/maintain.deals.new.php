<?php
/**
* Maintain deals new screen
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
<body>
<?php
$_REQUEST = array_merge($_GET, $_POST);
$read_only_mode = get_sanitized_value($_POST['read_only'] ?? false, 'boolean');
$col_list = get_sanitized_value($_POST['col_list'] ?? '');
$callback_function = get_sanitized_value($_POST['deal_select_completed'] ?? '');
$trans_type = get_sanitized_value($_POST['trans_type'] ?? 'NULL');
$grid_freeze = ($read_only_mode) ? 'n' : 'y';
$desisgnation_of_hedge = get_sanitized_value($_POST['call_from'] ?? 'NULL');

// values such as form_objects should not be sanitized
$ref_form_object = $_POST['form_obj'] ?? '';

$field_id = get_sanitized_value($_POST['browse_id'] ?? 'NULL');
$form_name = get_sanitized_value($_REQUEST['form_name'] ?? 'NULL');
$form_namespace = 'setupDeals';
$function_id = 10131000;
$rights_deal_edit = 10131010;
$rights_deal_delete = 10131011;
$rights_change_deal_status = 10131012;
$rights_change_confirm_status = 10131013;
$rights_lock_deals = 10131014;
$rights_unlock_deals = 10131015;
$rights_view_audit_report = 10131016;
$rights_update_volume = 10131018;
$rights_copy = 10131019;
$rights_transfer = 10131024;
$rights_schedule_deal = 10131028;
$rights_trade_ticket = 10131020;
$rights_schedule_volume_update = 10131032;
$rights_actual_volume_update = 10131033;
$rights_void_deal = 10131037;
$rights_unviod_deal = 10131038;

list (
    $has_rights_deal_edit,
    $has_rights_deal_delete,
    $has_rights_change_deal_status,
    $has_rights_change_confirm_status,
    $has_rights_lock_deals,
    $has_rights_unlock_deals,
    $has_rights_view_audit_report,
    $has_rights_update_volume,
    $has_rights_copy,
    $has_rights_transfer,
    $has_rights_schedule_deal,
    $has_rights_trade_ticket,
    $has_schedule_vol_update,
    $has_actual_vol_update ,
    $has_rights_void_deals,
    $has_rights_unvoid_deals
    ) = build_security_rights(
    $rights_deal_edit,
    $rights_deal_delete,
    $rights_change_deal_status,
    $rights_change_confirm_status,
    $rights_lock_deals,
    $rights_unlock_deals,
    $rights_view_audit_report,
    $rights_update_volume,
    $rights_copy,
    $rights_transfer,
    $rights_schedule_deal,
    $rights_trade_ticket,
    $rights_schedule_volume_update,
    $rights_actual_volume_update,
    $rights_void_deal,
    $rights_unviod_deal
);

if ($has_schedule_vol_update || $has_actual_vol_update) {
    $enable_update_actual = true;
} else {
    $enable_update_actual = false;
}

//For Sub Book Grid tag column name
$xml_file = "EXEC spa_source_book_mapping_clm";
$resultset = readXMLURL2($xml_file);
$group_1 = $resultset[0]['group1'];
$group_2 = $resultset[0]['group2'];
$group_3 = $resultset[0]['group3'];
$group_4 = $resultset[0]['group4'];

$layout_json = '[
                            {id: "a", text: "Portfolio Hierarchy", fix_size:[false,true], width:375, header:true},
                            {id: "b", text: "Deal Attributes"},
                            {id: "c", text:"Deals", undock:true, header:true}
                        ]';
$layout_obj = new AdihaLayout();
echo $layout_obj->init_layout('deal_layout', '', '3L', $layout_json, $form_namespace);
echo $layout_obj->attach_event('', 'onDock', $form_namespace . '.on_dock_event');
echo $layout_obj->attach_event('', 'onUnDock', $form_namespace . '.on_undock_event');

echo $layout_obj->attach_layout_cell('book_filter_layout', 'a', '2E', '[{id: "a", header:false, height:60},{id:"b", header:false}]');
$book_filter_layout_obj = new AdihaLayout();
echo $book_filter_layout_obj->init_by_attach('book_filter_layout', $form_namespace);
echo $book_filter_layout_obj->close_layout();

$portfolio_name = 'portfolio_filter';
echo $book_filter_layout_obj->attach_tree_cell($portfolio_name, 'b');

$portfolio_obj = new AdihaBookStructure($function_id, $rights_deal_edit, $rights_deal_delete);
echo $portfolio_obj->init_by_attach($portfolio_name, $form_namespace);
echo $portfolio_obj->set_portfolio_option(2);
echo $portfolio_obj->set_subsidiary_option(2);
echo $portfolio_obj->set_strategy_option(2);
echo $portfolio_obj->set_book_option(2);
echo $portfolio_obj->set_subbook_option(2);
echo $portfolio_obj->load_book_structure_data();
echo $portfolio_obj->enable_three_state_checkbox();
echo $portfolio_obj->attach_search_filter('setupDeals.book_filter_layout', 'b', true);

$toolbar_obj = new AdihaToolbar();
echo $layout_obj->attach_toolbar_cell('filter_toggle', 'b');
echo $toolbar_obj->init_by_attach('filter_toggle', $form_namespace);

$text = '<div class="row"><div class="pull-left"><div class="onoffswitch">';
$text .= '<input type="checkbox" name="onoffswitch" class="onoffswitch-checkbox" id="filter_toggler" checked>';
$text .= '<label class="onoffswitch-label" for="filter_toggler">';
$text .= '<span class="onoffswitch-inner"></span>';
$text .= '<span class="onoffswitch-sitch"></span>';
$text .= '</label></div></div>';
$text .= '<div class="pull-left" style="margin-left:3px"><div class="onoffswitch">';
$text .= '<input type="checkbox" name="hideFilter" class="hide_filter-checkbox" id="hide_filter" checked>';
$text .= '<label class="hide-filter-label" for="hide_filter">';
$text .= '<span class="hide-filter-inner"></span>';
$text .= '<span class="hide-filter-switch"></span>';
$text .= '</label></div></div></div>';

$toolbar_json = "[{
                            id:     'toggle',
                            type:   'text',
                            text:   '" . $text . "'
                        }]";
echo $toolbar_obj->load_toolbar($toolbar_json);

echo $layout_obj->attach_layout_cell('filter_layout', 'b', '1C', '[{id: "a", header:false}]');
$filter_layout_obj = new AdihaLayout();
echo $filter_layout_obj->init_by_attach('filter_layout', $form_namespace);
echo $filter_layout_obj->attach_html_object('a', 'search-box');
echo $filter_layout_obj->close_layout();

// Cell c
// attach Menu
echo $layout_obj->attach_menu_cell('deal_menu', 'c');
$menu_object = new AdihaMenu();

// Get Dashboard reports
$sp_db = "EXEC spa_pivot_report_dashboard @flag='x', @category=-104700";
$db_array = readXMLURL2($sp_db);
$db_items = '';

if (is_array($db_array) && sizeof($db_array) > 0) {
	$db_items = ',items:[';
	$icnt = 0;
    foreach ($db_array as $data) {
		if ($icnt > 0) $db_items .= ',';
    	$db_items .= ' {id:"dashboard_ ' . $data['dashboard_id'] . '", text:"' . $data['dashboard_name'] . '", img:"report.gif", imgdis:"report_dis.gif", text:"' . $data['dashboard_name'] . '", enabled:true}';
		$icnt++;
    }

    $db_items .= ']';
}

$menu_json = '[  
                        {id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif", title: "Refresh"},
                        ';
if ($read_only_mode)  {
    $menu_json = $menu_json . '{id:"ok", text:"Ok", img:"tick.png", imgdis:"tick_dis.png", title:"Ok", enabled:false},';
    $menu_json = $menu_json . '{id:"select_unselect", text:"Select/Unselect All", img:"select_unselect.gif", imgdis:"select_unselect_dis.gif", enabled: 0}]';
} else {
    $menu_json = $menu_json .
        '
                        {id:"t1", text:"Edit", img:"edit.gif", imgdis:"new_dis.gif" ,items:[
							{id:"blotter", text:"Insert deal\/s using blotter", img:"new.gif", enabled:' . (int)$has_rights_deal_edit . ' ,imgdis:"new_dis.gif", title: "Insert deal\/s using blotter <i><b>CTRL + i</b></i>"},
                            {id:"form_based", text:"Insert deal\/s using form", img:"new.gif", enabled:' . (int)$has_rights_deal_edit . ' ,imgdis:"new_dis.gif", title: "Insert deal\/s using form <i><b>ALT + i</b></i>"},
                            {id:"void", text:"Void", img:"void_deal.gif", imgdis:"void_deal_dis.gif", title: "Void", enabled:false},
                            {id:"unvoid", text:"UnVoid", img:"unvoid_deal.gif", imgdis:"unvoid_deal_dis.gif", title: "Undo Void", enabled:false},
                            {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete",enabled:false},
                        ]},
                        {id:"t2", text:"Export", img:"export.gif", items:[
                            {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                            {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                        ]},
                        {id:"t3", text:"Process", img:"action.gif", items:[
                            {id:"changestatus", text:"Change Status",img:"change_status.png", imgdis:"change_status_dis.png",  items:[
                            {id:"confirm_status", text:"Confirm Status", img:"update_invoice_stat.gif", imgdis:"update_invoice_stat_dis.gif", title: "Confirm Status", enabled:false},
                            {id:"deal_status", text:"Deal Status", img:"change_deal_status.gif", imgdis:"change_deal_status_dis.gif", title: "Deal Status", enabled:false},
                            {id:"lockstatus", text:"Lock Status", img:"lock_status.png", imgdis:"lock_status_dis.png",  items:[
	                            {id:"lock", text:"Lock", img:"lock.gif", imgdis:"lock_dis.gif", title: "Lock", enabled:false},
	                            {id:"unlock", text:"Unlock", img:"unlock.gif", imgdis:"unlock_dis.gif", title: "Unlock", enabled:false}
                            ]}
                            ]},
                            {id:"calc_position", text:"Calculate Position", img:"calc_position.gif", imgdis:"calc_position_dis.gif", title: "Calculate Position", enabled:false},
                            {id:"cascade", text:"Cascade", img:"calc_position.gif", imgdis:"calc_position_dis.gif", title: "Cascade", enabled:false},	
							{id:"rewind_cascade", text:"Rewind Cascade", img:"calc_position.gif", imgdis:"calc_position_dis.gif", title: "Rewind Cascade", enabled:false},										
                            {id:"update_volume", text:"Update Volume", img:"update_volume.gif", imgdis:"update_volume_dis.gif", title: "Update Volume", enabled:false},
                            {id:"copy", text:"Copy", img:"copy.gif", imgdis:"copy_dis.gif", title: "Copy", enabled:false},
                            {id:"transfer", text:"Transfer", img:"transfer.gif", imgdis:"transfer_dis.gif", title: "Transfer", enabled:false},
                            {id:"update_book", text:"Update Book", img:"update.gif", imgdis:"update_dis.gif", title: "Update Book", enabled:false},
							{id:"schedule_deal", text:"Schedule Deal", img:"run_view_schedule.gif", imgdis:"run_view_schedule_dis.gif", title: "Schedule Deal", enabled:false},
                            {id:"group_deal", text:"Group Deal", img:"new.gif", imgdis:"new_dis.gif", title: "Group Deal", enabled:false},
                            {id:"update_actual", text:"Update Actual", img:"update_volume.gif", imgdis:"update_volume_dis.gif", title: "Update Actual", enabled:false}							
                        ]},
                        {id:"t4", text:"Reports", img:"report.gif", items:[
                            {id:"position_report", text:"View Position Report", img:"finalize.gif", imgdis:"finalize_dis.gif", title: "View Position Report", enabled:false},
                            {id:"audit_report", text:"View Audit Report", img:"audit.gif", imgdis:"audit_dis.gif", title: "View Audit Report", enabled:false},
                            {id:"generate_confirmation", text:"Generate Confirmation", img:"gene_confirm.gif", imgdis:"gene_confirm_dis.gif", title: "Generate Confirmation", enabled:false},
                            {id:"trade_ticket", text:"Run Trade Ticket", img:"run_trade_ticket.gif", imgdis:"run_trade_ticket_dis.gif", title: "Run Trade Ticket", enabled:false},
                            {id:"workflow_report", text:"Workflow Status", img:"report.gif", imgdis:"report_dis.gif", title: "Workflow Status", enabled:false},
                            {id:"dashboard_reports", text:"Dashboard Reports", img:"report.gif", imgdis:"report_dis.gif", title: "Dashboard Reports", enabled:false ' . $db_items . '}
                        ]},
                        {id:"pivot", text:"Pivot", img:"pivot.gif", imgdis:"pivot_dis.gif",enabled:"false"}                       
                        ]';
}

echo $menu_object->init_by_attach('deal_menu', $form_namespace);
echo $menu_object->load_menu($menu_json);
echo $menu_object->attach_event('', 'onClick', $form_namespace . '.deal_menu_click');

// attach grid
echo $layout_obj->attach_grid_cell('setup_deals', 'c');
echo $layout_obj->attach_status_bar("c", true);
$grid_obj = new GridTable('setup_deals');
$grid_obj->enable_connector();
echo $grid_obj->init_grid_table('setup_deals', $form_namespace, $grid_freeze);
echo $grid_obj->set_column_auto_size();
echo $grid_obj->set_search_filter(true, "");
echo $grid_obj->enable_paging(100, 'pagingArea_c', 'true');
echo $grid_obj->enable_column_move();
if ($form_name != 'cci_enhancement.cci_enhancement_form') { //to select only one deal
    echo $grid_obj->enable_multi_select();
}
echo $grid_obj->return_init();

$column_list = $grid_obj->grid_columns;
$date_fields = $grid_obj->date_fields;
$numeric_fields = $grid_obj->numeric_fields;

if (!$read_only_mode) {
    echo $grid_obj->attach_event("", "onRowDblClicked", $form_namespace . '.open_update_popup');
}
echo $grid_obj->attach_event("", "onRowSelect", $form_namespace . '.on_row_select');
echo $grid_obj->attach_event("", "onSelectStateChanged", $form_namespace . '.grid_row_selection');
echo $grid_obj->attach_event("", "onBeforePageChanged", $form_namespace . '.grid_before_page_change');
echo $grid_obj->attach_event("", "onPageChanged", $form_namespace . '.grid_page_change');
echo $layout_obj->close_layout();

/* Note:- 10131000 id is for previous create and view deals. Function ID for new one is 10132000. So old ID cannot be removed but for privilege new should be considered.  */
$form_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='" . $function_id . "', @template_name='SetupDeals'";

/*$key_prefix = 'UI_' . $function_id;
$form_data = readXMLURLCached($form_sql,false,$key_prefix,'',true);*/   
/* Above lines are commented to bypass data caching without reverting all changes done for data caching. */
$form_data = readXMLURL2($form_sql);

$form_data_array = array();
$grid_data_array = array();
$tab_data = array();

if (is_array($form_data) && sizeof($form_data) > 0) {
    foreach ($form_data as $data) {
        array_push($tab_data, $data['tab_json']);
        array_push($form_data_array, $data['form_json']);
    }
}

$form_tab_data = 'tabs: [' . implode(",", $tab_data) . ']';
$form_data_json = json_encode($form_data_array);
?>
<div id="search-box" style="display:none">
    <div class="search-box">
        <input type="text" id="search-text" class="search-input" placeholder="<?php echo get_locale_value("Search Transactions") ?>">
    </div>
</div>
<textarea style="display:none" name="deleted_checked" id="deleted_checked">n</textarea>
<textarea style="display:none" name="txt_process_table" id="txt_process_table"></textarea>
</body>
<script type="text/javascript">
    setupDeals.filter_form = {};
    var blotter_window;
    var update_window;
    var comment_window;
    var status_window;
    var confirm_window;
    var volume_window;
    var trade_window;
    var read_only_mode = Boolean(<?php echo $read_only_mode; ?>);

    var php_script_loc = "<?php echo $php_script_loc ?? ''; ?>";
    var SHOW_SUBBOOK_IN_BS = <?php echo $SHOW_SUBBOOK_IN_BS;?>;

    $(function() {
        setupDeals.filter_type_changed();

        $('#filter_toggler').change(function () {
            setupDeals.show_hide_filter();
        });
        $('#hide_filter').change(function () {
            setupDeals.show_hide_filter();
        });
        setupDeals.deal_layout.cells('a').showHeader();
        var cell_c = setupDeals.deal_layout.cells('c');

        setupDeals.deal_layout.attachEvent("onCollapse", function(name){
            if (name == 'c') {
                $('#hide_filter').prop('checked', true);
                setupDeals.show_hide_filter();
            }
        });

        setupDeals.deal_layout.attachEvent("onExpand", function(name){
            if (name == 'c') {
                setupDeals.show_hide_filter();
            }
        });
        setupDeals.resize_layout('all');

        filter_obj = setupDeals.book_filter_layout.cells('a').attachForm();
        var layout_cell_obj = setupDeals.filter_layout.cells('a');
        load_form_filter(filter_obj, layout_cell_obj, '10131000', 2);
    });

    /**
     * [resize_layout Resize the layout cells]
     */
    setupDeals.resize_layout = function(cells) {
        var h = 0;
        var w = 0;

        setupDeals.deal_layout.forEachItem(function(item){
            var id = item.getId();
            if (id == 'b' || id == 'c') {
                h += item.getHeight();
            }
            if (id == 'b' || id == 'a') {
                w += item.getWidth();
            }
        });
        if (cells = 'all') {
            //setupDeals.deal_layout.cells("a").setWidth(w * 0.15);
        }
        var height_multiplier = (SHOW_SUBBOOK_IN_BS == 1) ? 0.25 : 0.55;
        setupDeals.deal_layout.cells("b").setHeight(h * height_multiplier);
    }

    /**
     * [undock_deals Undock deal grid]
     */
    setupDeals.undock_deals = function() {
        var layout_obj = setupDeals.deal_layout;
        layout_obj.cells("c").undock(300, 300, 900, 700);
        layout_obj.dhxWins.window("c").button("park").hide();
        layout_obj.dhxWins.window("c").maximize();
        layout_obj.dhxWins.window("c").centerOnScreen();
    }

    /**
     * [grid_before_page_change Event before page change]
     * @param  {[type]} ind   [the index of the current page]
     * @param  {[type]} count [Page Count]
     * @return {[type]}       [description]
     */
    setupDeals.grid_before_page_change = function(ind,count) {
        setupDeals.deal_layout.cells("c").progressOn();
        return true;
    }

    /**
     * [grid_page_change description]
     * @param  {[type]} ind  [the index of the current page]
     * @param  {[type]} fInd [the index of the first row of the page]
     * @param  {[type]} lInd [the index of the last row of the page]
     * @return {[type]}      [description]
     */
    setupDeals.grid_page_change = function(ind,fInd,lInd) {
        setupDeals.deal_layout.cells("c").progressOff();
    }

    /**
     * [on_dock_event On dock event]
     * @param  {[type]} id [Cell id]
     */
    setupDeals.on_dock_event = function(id) {
        if (id == 'c')
            $(".undock_deals").show();
    }
    /**
     * [on_undock_event On undock event]
     * @param  {[type]} id [Cell id]
     */
    setupDeals.on_undock_event = function(id) {
        if (id == 'c')
            $(".undock_deals").hide();
    }

    /**
     * [deal_menu_click Menu clicked function]
     * @param  {[int]} id     [Menu id]
     * @param  {[mixed]} zoneId [mixed context menu zone, if a menu rendered in the context menu mode]
     * @param  {[mixed]} cas    [object state of CTRL/ALT/SHIFT keys during the click (pressed/not pressed)]
     */
    setupDeals.deal_menu_click = function(id, zoneId, cas) {
        switch(id) {
            case 'refresh':
                setupDeals.refresh_grid();
                break;
            case 'blotter':
                setupDeals.open_blotter();
                break;
            case 'form_based':
                setupDeals.open_deal_insert();
                break;
            case "pdf":
                setupDeals.setup_deals.toPDF(js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                break;
            case "excel":
                var process_table = $('textarea#txt_process_table').val();
                if (process_table == '') {
                    dhtmlx.alert({
                        type: "alert",
                        title:'Alert',
                        text:"Please refresh grid."
                    });
                    return;
                }
                setupDeals.setup_deals.PSExport('excel', process_table, 'Deals', '', ' id DESC');
                break;
            case "delete":
                confirm_messagebox("Are you sure you want to delete selected deal(s)?",function(){
                    var selected_ids = setupDeals.setup_deals.getColumnValues(0);
                            var row_id = setupDeals.setup_deals.getSelectedRowId();
                            var subsidiary_index = setupDeals.setup_deals.getColIndexById('subsidiary');
                            var subsidiary = '';
                            var book_index = setupDeals.setup_deals.getColIndexById('book');
                            var book = '';

                            var row_id = setupDeals.setup_deals.getSelectedRowId();
                            var selected_row_array_d = row_id.split(',');

                            for(var i = 0; i < selected_row_array_d.length; i++) {
                                if (i == 0) {
                                    subsidiary = setupDeals.setup_deals.cells(selected_row_array_d[i], subsidiary_index).getValue();
                                    book = setupDeals.setup_deals.cells(selected_row_array_d[i], book_index).getValue();
                                } else {
                                    subsidiary = subsidiary + ',' + setupDeals.setup_deals.cells(selected_row_array_d[i], subsidiary_index).getValue();
                                    book = book + ',' + setupDeals.setup_deals.cells(selected_row_array_d[i], book_index).getValue();
                                }
                            }

                            data = {"action": "spa_source_deal_header", "flag":"x", "deal_ids":selected_ids, "subsidiary": subsidiary, "book": book};
                            adiha_post_data("return_array", data, '', '', 'setupDeals.check_deals');

                });
                break;
            case 'calc_position':
                var selected_ids = setupDeals.setup_deals.getColumnValues(0);
                // data = {"action": "spa_calc_deal_position_breakdown", "deal_header_ids":selected_ids};

                var exec_call = "EXEC spa_calc_deal_position_breakdown  @deal_header_ids='" + selected_ids + "'";
                var param = 'call_from=Calculate Position Batch Import&gen_as_of_date=1&batch_type=c'; 
                //alert(exec_call);
                adiha_run_batch_process(exec_call, param, 'Calculate Position');

                //adiha_post_data("alert", data, '', '');
                break;
            case 'cascade':
                confirm_messagebox("Are you sure you want to cascade selected deal(s)?",function(){
                    var selected_ids = setupDeals.setup_deals.getColumnValues(0);
					data = {"action": "spa_cascade_deal", "parent_deal_ids":selected_ids, flag: "cascade"};
					adiha_post_data("alert", data, '', '');
                });
                break;		
			case 'rewind_cascade':
				confirm_messagebox("Are you sure you want to rewind cascade selected deal(s)?",function(){
                    var selected_ids = setupDeals.setup_deals.getColumnValues(0);
					data = {"action": "spa_cascade_deal", "parent_deal_ids":selected_ids, flag: "rewind_cascade"};
					adiha_post_data("alert", data, '', '');
                });
				break;
            case 'lock':
                setupDeals.lock_unlock_deals('y');
                break;
            case 'unlock':
                setupDeals.lock_unlock_deals('n');
                break;
            case 'deal_status':
                setupDeals.change_status('deal');
                break;
            case 'confirm_status':
                setupDeals.change_status('confirm');
                break;
            case 'position_report':
                setupDeals.open_report('position');
                break;
            // case 'scheduling_report':
            //     var selected_rows = setupDeals.setup_deals.getColumnValues(1);
            //     selected_rows = selected_rows.replace(/,/g,'!');

            //     data = {
            //         "action": 'spa_call_report_manager_report',
            //         "flag": 'scheduling_report',
            //         "report_name": 'Scheduling Match Detail Report', 
            //         "deal_id": selected_rows
            //     };

            //     adiha_post_data('return_json', data, '', '', 'setupDeals.scheduling_report_callback', '');

            //     break;
            case 'audit_report':
                setupDeals.open_report('audit');
                break;
            case 'generate_confirmation':
                setupDeals.open_confirmation_report();
                break;
            case 'update_volume':
                setupDeals.open_update_volume();
                break;
            case 'update_actual':
                setupDeals.update_actual_clicked();
                break;
            case 'copy':
                var selected_ids = setupDeals.setup_deals.getColumnValues(0);
                setupDeals.open_deal_detail('', '', selected_ids, '', '', '', '', '');
                break;
            case 'schedule_deal':
                setupDeals.open_schedule_deal();
                break;
            case 'transfer':
                setupDeals.open_deal_transfer();
                break;
            case 'update_book':
                setupDeals.open_update_book();
                break;
            case 'trade_ticket':
                setupDeals.open_trade_ticket();
                break;
            case 'ok':
                var selected_rows = setupDeals.setup_deals.getSelectedRowId();

                if (selected_rows == null) {
                    show_messagebox("Please select deals.");
                    return;
                }
                setupDeals.return_selected_deals();
                break;
            case 'select_unselect':
                var grid_selected_rows = setupDeals.setup_deals.getSelectedRowId();

                if (grid_selected_rows == null) {
                    setupDeals.setup_deals.selectAll();
                    setupDeals.deal_menu.setItemEnabled('ok');
                } else {
                    setupDeals.setup_deals.clearSelection();
                    setupDeals.deal_menu.setItemDisabled('ok');
                }
                break;
            case 'workflow_report':
                setupDeals.workflow_report();
                break;
            case 'pivot':
                var grid_obj = setupDeals.setup_deals;
                open_grid_pivot(grid_obj, 'setup_deals', 1, pivot_exec_spa, 'Setup Deals');
                break;
            case 'group_deal':
                setupDeals.open_deal_group();
                break;
            case 'void':
                setupDeals.void_unvoid_deals('void');
                break;
            case 'unvoid':
                setupDeals.void_unvoid_deals('unvoid');
                break;
            default:
            	if (id.indexOf("dashboard_") != -1) {
				    var str_len = id.length;
				    var dashboard_id = id.substring(10, str_len);
				    var dashboard_name = setupDeals.deal_menu.getItemText(id);

				    setupDeals.open_dashboard_window(dashboard_id, dashboard_name);
				    break;
                } else {        
                    show_messagebox("Under Maintainence! We will be back soon!");        	
	                break;
                }
                
        }
    }

    var dashboard_window;
    setupDeals.open_dashboard_window = function(dashboard_id, dashboard_name) {
    	var row_id = setupDeals.setup_deals.getSelectedRowId();
		var deal_id = setupDeals.setup_deals.cells(row_id, 0).getValue();

		if (!dashboard_window) {
			dashboard_window = new dhtmlXWindows();
		}
		dashboard_id = dashboard_id.trim();
		var win_id = dashboard_id;
		var new_dashboard_window = dashboard_window.createWindow(win_id, 0, 0, 400, 400);
		new_dashboard_window.setText(dashboard_name + " (Deal - " + deal_id + ")");
		new_dashboard_window.centerOnScreen();
		new_dashboard_window.maximize();
		var url = app_form_path + '_reporting/view_report/my.dashboard.php?dashboard_id='+ dashboard_id;
		var param_xml = '<Root><FormXML param_name="source_deal_header_id" param_value="' + deal_id + '"></FormXML></Root>';
		var post_param = {'param_xml':escape(param_xml)}
		new_dashboard_window.attachURL(url, false, post_param);

		new_dashboard_window.addUserButton("undock", 0, "Undock", "Undock");

		new_dashboard_window.button("undock").attachEvent("onClick", function(){
			open_window(url, post_param);
		});

    }	

    var deal_insert_window;
    setupDeals.open_deal_insert = function() {
        setupDeals.unload_deals_window();
        var sub_book_ids = '';

        if (SHOW_SUBBOOK_IN_BS == 1) {
            sub_book_ids = setupDeals.get_subbook();
        } else {
            setupDeals.tab_object = setupDeals.filter_layout.cells('a').getAttachedObject();
            setupDeals.tab_object.forEachTab(function(tab) {
                var id = tab.getId();
                var tab_text = tab.getText();

                if (tab_text == 'Source Book Mapping') {
                    var attached_obj = setupDeals.tab_object.tabs(id).getAttachedObject();
                    if (attached_obj instanceof dhtmlXGridObject) {
                        sub_book_ids = attached_obj.getColumnValues(0);
                    }
                }
            });
        }

        if (sub_book_ids.indexOf(',') != -1) {
            sub_book_ids = '';
        }

        var new_id = (new Date()).valueOf();
        var win_id = 'w_' + new_id;
        var params = 'select.template.php?sub_book=' + sub_book_ids;

        if (!blotter_window) {
            blotter_window = new dhtmlXWindows();
        }

        var height = $(document).height();
        var width = $(document).width();
        
        var new_blotter = blotter_window.createWindow('w1', 0, 0, width, height);
        new_blotter.setText("Deal Insert");
        new_blotter.centerOnScreen();
        new_blotter.setModal(true);
        new_blotter.denyResize();
        new_blotter.button('minmax').hide();
        new_blotter.attachURL(params, false);

        new_blotter.attachEvent("onClose", function(win){
            var ifr = win.getFrame();
            var ifrWindow = ifr.contentWindow;
            var ifrDocument = ifrWindow.document;
            var success_template = $('textarea[name="success_template"]', ifrDocument).val();
            var template_name = $('textarea[name="template_name"]', ifrDocument).val();
            var deal_type_id = $('textarea[name="deal_type_id"]', ifrDocument).val();
            var pricing_type_id = $('textarea[name="pricing_type_id"]', ifrDocument).val();
            var term_frequency = $('textarea[name="term_type"]', ifrDocument).val();
            var commodity_id = $('textarea[name="commodity_id"]', ifrDocument).val();

            var success_template = $('textarea[name="success_template"]', ifrDocument).val();
            if (success_template != -1) {
                setupDeals.open_deal_detail(success_template, sub_book_ids, '', deal_type_id, pricing_type_id, template_name, term_frequency, commodity_id);
            }
            return true;
        })
    }

    setupDeals.open_deal_detail = function(template_id, sub_book_ids, copy_deal_id, deal_type_id, pricing_type_id, template_name, term_frequency, commodity_id) {
        if (deal_insert_window != null && deal_insert_window.unload != null) {
            deal_insert_window.unload();
            deal_insert_window = w1 = null;
        }

        if (!deal_insert_window) {
            deal_insert_window = new dhtmlXWindows();
        }

        var new_deal = deal_insert_window.createWindow('w1', 0, 0, 400, 400);
        var win_text = "Deal - <i> " + template_name + " </i> - New";
        new_deal.setText(win_text);
        new_deal.centerOnScreen();
        new_deal.setModal(true);
        new_deal.maximize();

        new_deal.attachURL('deal.detail.new.php', false, {template_id:template_id,sub_book:sub_book_ids,copy_deal_id:copy_deal_id,deal_type_id:deal_type_id,pricing_type_id:pricing_type_id,term_frequency:term_frequency,commodity_id:commodity_id});

        new_deal.attachEvent("onClose", function(win){
            var ifr = win.getFrame();
            var ifrWindow = ifr.contentWindow;
            var ifrDocument = ifrWindow.document;
            var status = $('textarea[name="txt_save_status"]', ifrDocument).val();

            if (status != 'cancel' && sub_book_ids != '') {
                setupDeals.refresh_grid();
            }
            return true;
        });
    }

    /**
     * Return selected deals to parent page for further processing.
     **/
    setupDeals.return_selected_deals = function() {
        var grid_obj = setupDeals.setup_deals;
        var selected_rows = grid_obj.getSelectedRowId();
        var arr_selected_rows = selected_rows.split(',');
        if('<?php echo $desisgnation_of_hedge; ?>' == 'deal_filter') {
            var ref_form_object = '<?php echo $ref_form_object;?>';
            var field_id = '<?php echo $field_id;?>';
            var call_back = '<?php echo $callback_function;?>';
            if (call_back) {
                eval('parent.' + call_back + '("' + arr_selected_rows  +'")');
                parent.new_browse.close();
            } else {
                post_callback(arr_selected_rows,ref_form_object,field_id);
            }
        } else {
            var grid_array = new Array();
            //var col_id = '';
            // var col_num = grid_obj.getColumnsNum();
            // var grid_header_array, grid_data_array;
            var col_list = '<?php echo $col_list; ?>';
            // var col_list = 'id,term_start,deal_id1';
            var arr_col_list = col_list.split(',');
            var arr_col_index = new Array();

            //get column index from label
            $.each(arr_col_list, function(index, value) {

                if (grid_obj.getColIndexById(value) == undefined) {
                    arr_col_index.push('na');
                } else {
                    arr_col_index.push(grid_obj.getColIndexById(value));
                }
            });

            //loop over selected rows only
            $.each(arr_selected_rows, function(i, row_id) {
                grid_data_array = new Array();
                $.each(arr_col_index, function(j, col_index) {
                    if (col_index == 'na') {
                        grid_data_array.push(col_index);
                    } else {
                        grid_data_array.push(grid_obj.cells(row_id, col_index).getValue());    //capture cell value
                    }
                });
                //push data array
                grid_array.push(grid_data_array);
            });

            var callback_function = '<?php echo $callback_function; ?>';

            if(Boolean(callback_function)) {
                eval('parent.' + callback_function + '(grid_array)');
            }

        }
    }
    /**
     * [open_blotter Opens blotter window]
     */
    setupDeals.open_blotter = function() {
        setupDeals.unload_deals_window();
        var sub_book_ids = '';

        if (SHOW_SUBBOOK_IN_BS == 1) {
            sub_book_ids = setupDeals.get_subbook();
        } else {
            setupDeals.tab_object = setupDeals.filter_layout.cells('a').getAttachedObject();
            setupDeals.tab_object.forEachTab(function(tab) {
                var id = tab.getId();
                var tab_text = tab.getText();

                if (tab_text == 'Source Book Mapping') {
                    var attached_obj = setupDeals.tab_object.tabs(id).getAttachedObject();
                    if (attached_obj instanceof dhtmlXGridObject) {
                        sub_book_ids = attached_obj.getColumnValues(0);
                    }
                }
            });
        }

        var book_ids = setupDeals.get_book();
        var sub_ids = setupDeals.get_subsidiary();

        if (sub_book_ids.indexOf(',') != -1) {
            sub_book_ids = '';
        }

        if (!blotter_window) {
            blotter_window = new dhtmlXWindows();
        }

        var new_blotter = blotter_window.createWindow('w1', 0, 0, 400, 400);
        new_blotter.setText("Deal Blotter");
        new_blotter.centerOnScreen();
        new_blotter.setModal(true);
        new_blotter.maximize();
        new_blotter.attachURL('deal.blotter.php', false, {sub_book:sub_book_ids, book_ids:book_ids, sub_ids:sub_ids});

        new_blotter.attachEvent("onClose", function(win){
            if (sub_book_ids != '')
                setupDeals.refresh_grid();

            return true;
        })
    }

    /**
     * [show_hide_filter Shows/hide filters]
     */
    setupDeals.show_hide_filter = function() {
        var cell = setupDeals.filter_layout.cells("a");
        if ($('#hide_filter').prop('checked')) {
            setupDeals.deal_layout.cells('a').expand();
            setupDeals.filter_type_changed();
        } else {
            setupDeals.deal_layout.cells('a').collapse();
            setupDeals.deal_layout.cells('c').expand();
            cell.setHeight(0);
        }
    }

    /**
     * [filter_type_changed Filter type on change function]
     */
    setupDeals.filter_type_changed = function() {
        if ($('#filter_toggler').prop('checked')) {
            setupDeals.change_filter_view('advance');
            setupDeals.resize_layout('b');
        } else {
            setupDeals.change_filter_view('def');
            setupDeals.filter_layout.cells('a').setHeight(90);
            setupDeals.resize_layout('b');
        }
    }

    /**
     * [change_filter_view Changes filter view]
     * @param  {[string]} view [View id]
     */
    setupDeals.change_filter_view = function(view) {
        var show = setupDeals.filter_layout.cells("a").showView(view);
        if (show) {
            if (view == 'advance') {
                setupDeals.tab_object = setupDeals.filter_layout.cells('a').attachTabbar({
                    <?php echo $form_tab_data;?>
                });

                var i=0;
                var form_json = <?php echo $form_data_json;?>;
                setupDeals.tab_object.forEachTab(function(tab){
                    var id = tab.getId();
                    var tab_text = tab.getText();

                    if (SHOW_SUBBOOK_IN_BS == 1) {
                        if(tab_text == 'Source Book Mapping') {
                            tab.hide();
                        }
                        if(tab_text == 'General')
                            tab.setActive();

                    }

                    var form_index = "filter_form_" + id;
                    setupDeals.filter_form[form_index] = tab.attachForm();

                    if (form_json[i]) {
                        setupDeals.filter_form[form_index].loadStruct(form_json[i]);
                        i++;
                    }

                    var form_namespace_name = "setupDeals.filter_form[" + form_index + "]";
                    var from_value = '';
                    var to_value = '';
                    var from_label = '';
                    var to_label = '';
                    var form_obj = setupDeals.filter_form[form_index];
                    if (tab_text == 'Dates' || tab_text == 'Audit') {
                        form_obj.attachEvent("onChange", function (name, value){
                            if (tab_text == 'Dates') {
                                var changed = true;
                                if (name == 'deal_date_from' || name == 'deal_date_to') {
                                    from_value = form_obj.getItemValue("deal_date_from", true);
                                    to_value = form_obj.getItemValue("deal_date_to", true);
                                    from_label = form_obj.getItemLabel("deal_date_from");
                                    to_label = form_obj.getItemLabel("deal_date_to");
                                } else if (name == 'term_start' || name == 'term_end') {
                                    from_value = form_obj.getItemValue("term_start", true);
                                    to_value = form_obj.getItemValue("term_end", true);
                                    from_label = form_obj.getItemLabel("term_start");
                                    to_label = form_obj.getItemLabel("term_end");
                                } else if (name == 'settlement_date_from' || name == 'settlement_date_to') {
                                    from_value = form_obj.getItemValue("settlement_date_from", true);
                                    to_value = form_obj.getItemValue("settlement_date_to", true);
                                    from_label = form_obj.getItemLabel("settlement_date_from");
                                    to_label = form_obj.getItemLabel("settlement_date_to");
                                } else {
                                    changed = false;
                                }
                            } else {
                                var changed = true;
                                if (name == 'create_ts_from' || name == 'create_ts_to') {
                                    from_value = form_obj.getItemValue("create_ts_from", true);
                                    to_value = form_obj.getItemValue("create_ts_to", true);
                                    from_label = form_obj.getItemLabel("create_ts_from");
                                    to_label = form_obj.getItemLabel("create_ts_to");
                                } else if (name == 'update_ts_from' || name == 'update_ts_to') {
                                    from_value = form_obj.getItemValue("update_ts_from", true);
                                    to_value = form_obj.getItemValue("update_ts_to", true);
                                    from_label = form_obj.getItemLabel("update_ts_from");
                                    to_label = form_obj.getItemLabel("update_ts_to");
                                } else {
                                    changed = false;
                                }
                            }

                            if (changed && dates.compare(to_value, from_value) == -1) {
                                if (dates.compare(from_value, value) == 0 || dates.compare(from_value, value) == -1) {
                                    var message = from_label + ' cannot be greater than ' + to_label;
                                    var min_max_val = to_value;
                                } else {
                                    var message = to_label + ' cannot be less than ' + from_label;
                                    var min_max_val = from_value;
                                }
                                setupDeals.error_call(form_obj, name, min_max_val, message);
                            }
                        });
                    } else if (tab_text == 'General') {
                        form_obj.attachEvent("onChange", function (name, value){
                            if (name == 'source_deal_header_id_from' || name == 'source_deal_header_id_to') {
                                from_value = parseInt(form_obj.getItemValue("source_deal_header_id_from"));
                                to_value = parseInt(form_obj.getItemValue("source_deal_header_id_to"));
                                from_label = form_obj.getItemLabel("source_deal_header_id_from");
                                to_label = form_obj.getItemLabel("source_deal_header_id_to");

                                if (from_value != '' && to_value != '' && Number(from_value) > Number(to_value)) {
                                    if (name == 'source_deal_header_id_from') {
                                        var message = from_label + ' cannot be greater than ' + to_label;
                                        var min_max_val = to_value;
                                    } else {
                                        var message = to_label + ' cannot be less than ' + from_label;
                                        var min_max_val = from_value;
                                    }
                                    setupDeals.error_call(form_obj, name, min_max_val, message);
                                }
                            }

                            if (name == 'view_deleted') {
                                var delete_ts_index = setupDeals.setup_deals.getColIndexById('delete_ts');
                                var delete_user_index = setupDeals.setup_deals.getColIndexById('delete_user');
                                if(form_obj.isItemChecked("view_deleted")) {
                                    document.getElementById("deleted_checked").value = 'y';
                                    setupDeals.setup_deals.setColumnHidden(delete_ts_index, false);
                                    setupDeals.setup_deals.setColumnHidden(delete_user_index, false);
                                } else {
                                    document.getElementById("deleted_checked").value = 'n';
                                    setupDeals.setup_deals.setColumnHidden(delete_ts_index, true);
                                    setupDeals.setup_deals.setColumnHidden(delete_user_index, true);
                                }
                            }
                        });
                    } else if (tab_text == 'Source Book Mapping') {
                        setupDeals.load_source_book_mapping(setupDeals.tab_object, id);
                    }
                });
            }
        }
    }
    /**
     *
     */
    setupDeals.load_source_book_mapping = function (tab_object, tab_id) {
        var group_1 = '<?php echo $group_1; ?>';
        var group_2 = '<?php echo $group_2; ?>';
        var group_3 = '<?php echo $group_3; ?>';
        var group_4 = '<?php echo $group_4; ?>';
        var menu_json = [{id:"refresh", img:"refresh.gif", imgdis:'refresh_dis.gif', text:"Refresh", title:"Refresh", enabled: true},
            {id:"export", img:"export.gif", imgdis:'export_dis.gif', text:"Export", items:[
                {id:"excel", img:"excel.gif", imgdis:'excel_dis.gif', text:"Excel", title:"Excel"},
                {id:"pdf", img:"pdf.gif", imgdis:'pdf_dis.gif', text:"PDF", title:"PDF"}
            ]}];
        var menu_obj = tab_object.tabs(tab_id).attachMenu();
        menu_obj.setIconsPath(js_image_path + "dhxmenu_web/");
        menu_obj.loadStruct(menu_json);
        menu_obj.attachEvent("onClick", function(id) {
            setupDeals.refresh_source_book_mapping(tab_object, tab_id, id);
        });

        tab_object.tabs(tab_id).attachStatusBar({height: 10,text: '<div id="pagingAreaGrid_b"></div>'});

        var source_book_grid_obj = tab_object.tabs(tab_id).attachGrid();
        source_book_grid_obj.setImagePath(js_image_path + "dhxgrid_web/");
        source_book_grid_obj.setColumnIds("fas_book_id,logical_name,tag1,tag2,tag3,tag4,transaction_type");
        source_book_grid_obj.setHeader("FAS Book ID,Logical Name," + group_1 + "," + group_2 + "," + group_3 + "," + group_4 + ",Transaction Type");
        source_book_grid_obj.attachHeader('#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter');
        source_book_grid_obj.setColSorting('str,str,str,str,str,str,str');
        source_book_grid_obj.setColTypes("ro,ro,ro,ro,ro,ro,ro");
        source_book_grid_obj.setInitWidths('100,200,130,130,130,200,200');
        source_book_grid_obj.setColumnsVisibility("true,false,false,false,false,false,false");
        source_book_grid_obj.init();
        source_book_grid_obj.enableMultiselect(true);
        source_book_grid_obj.enableHeaderMenu();
        source_book_grid_obj.setPagingWTMode(true, true, true, true);
        source_book_grid_obj.enablePaging(true, 10, 0, 'pagingAreaGrid_b');
        source_book_grid_obj.setPagingSkin('toolbar');
        //source_book_grid_obj.load();
        //refresh_source_book_mapping(tab_object, tab_id, 'refresh');
        //return true;
        //setupDeals.deal_layout.cells('b').setHeight(500);
    }
    /**
     *
     */
    setupDeals.refresh_source_book_mapping = function(tab_object, tab_id, button_id) {
        var fas_book_id = (setupDeals.get_book()) ? setupDeals.get_book() : '0';
        var attached_obj = tab_object.tabs(tab_id).getAttachedObject();
        var trans_type = '<?php echo $trans_type; ?>';

        if (attached_obj instanceof dhtmlXGridObject) {
            switch(button_id) {
                case 'refresh':
                    if (fas_book_id == 0) {
                        dhtmlx.alert({type: "alert", title:'Alert', text:"Please select a Book."});
                        return;
                    }
                    var param = {"action": "spa_sourcesystembookmap","flag": "n","fas_book_id_arr":fas_book_id,"grid_type": "g", 'fas_deal_type_value_id': trans_type};
                    param = $.param(param);
                    var param_url = js_data_collector_url + "&" + param;
                    attached_obj.clearAndLoad(param_url);
                    break;
                case 'pdf':
                    attached_obj.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                    break;
                case 'excel':
                    attached_obj.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                    break;
                default:
                    //Do nothing
                    break;
            }
        }

    }
    /**
     * [error_call Error call for min max value]
     * @param  {[type]} form_obj    [Form Object]
     * @param  {[type]} name        [Item name]
     * @param  {[type]} min_max_val [Min Max value]
     * @param  {[type]} message     [Error message]
     */
    setupDeals.error_call = function(form_obj, name, min_max_val, message) {
        dhtmlx.alert({
            title:"Alert",
            type:"alert-error",
            text:message,
            callback: function(result){
                form_obj.setItemValue(name, min_max_val);
            }
        });
    }

    /**
     * [clear_filter Clear inline filters]
     */
    // setupDeals.clear_filter = function() {
    //     for (var i=0; i < setupDeals.setup_deals.getColumnCount(); i++) {
    //       var filter = setupDeals.setup_deals.getFilterElement(i);
    //       if (filter) filter.value = '';
    //     }
    //     setupDeals.setup_deals.filterByAll();
    // }

    /**
     * [refresh_grid Refresh Grid]
     */
    setupDeals.refresh_grid = function() {
        setupDeals.deal_layout.cells("c").progressOn();
        var sub_books = '';
        var book_ids = setupDeals.get_book();

        if (SHOW_SUBBOOK_IN_BS == 1) {
            sub_books = setupDeals.get_subbook();
        }

        if (read_only_mode) {
            setupDeals.deal_menu.setItemDisabled('ok');
        }

        var filter_mode = ($('#filter_toggler').prop('checked')) ? 'a' : 'g';
        var xml = '<Root><FormXML filter_mode="' + filter_mode + '"';

        if (SHOW_SUBBOOK_IN_BS == 1 && sub_books == '') {
            xml += ' book_ids="' + book_ids + '" sub_book_ids="" ';
        } else if (SHOW_SUBBOOK_IN_BS == 1&& sub_books != ''){
            xml += ' book_ids="' + book_ids + '" sub_book_ids="' + sub_books + '"';
        } else if (SHOW_SUBBOOK_IN_BS == 0 && book_ids != '') {
            xml += ' book_ids="' + book_ids + '"';
        }

        if (SHOW_SUBBOOK_IN_BS == 0) {
            if (book_ids == '') {
                show_messagebox("Please select a book.");
                setupDeals.deal_layout.cells("c").progressOff();
                return;
            }
        } else {
            if (sub_books == '') {
                show_messagebox("Please select at least one Subsidiary or Strategy or Book or Sub Book.");
                setupDeals.deal_layout.cells("c").progressOff();
                return;
            }
        }

        if (read_only_mode) {
            setupDeals.deal_menu.setItemDisabled('ok');
        }
        var show_unmapped_deals = '';

        if (filter_mode == 'g') {
            var search_text = $("#search-text").val()
            xml += ' search_text="' + search_text + '"';

            if (search_text == '' || search_text == undefined) {
                show_messagebox("Please provide search text.");
                setupDeals.deal_layout.cells("c").progressOff();
                return;
            }
        } else {
            setupDeals.tab_object.forEachTab(function(tab){
                var id = tab.getId();

                if (tab.getText() != 'Source Book Mapping') {
                    var form_object = setupDeals.filter_form["filter_form_" + id];
                    form_data = form_object.getFormData();

                    var filter_param = '';
                    for (var label in form_data) {
                        if (form_object.getItemType(label) == 'calendar') {
                            value = form_object.getItemValue(label, true);
                        } else if (label == 'buy_sell_id' && '<?php echo $desisgnation_of_hedge; ?>' == 'buysell_match') {
                            value = 'b';
                        } else {
                            value = form_data[label];
                        }
                        xml += ' ' + label + '="' + value + '"';

                        if (label == 'show_unmapped_deals') {
                            show_unmapped_deals = value;
                        }
                    }
                } else {
                    if (SHOW_SUBBOOK_IN_BS == 0 && tab.getText() == 'Source Book Mapping') {
                        var source_book_grid_obj = setupDeals.tab_object.tabs(id).getAttachedObject();

                        var selected_row_id = source_book_grid_obj.getSelectedRowId();
                        if (selected_row_id) {
                            if(selected_row_id.indexOf(',') == 1){
                                selected_row_id = selected_row_id.split(',');
                                var sub_book_ids = '';

                                selected_row_id.forEach(function(item){
                                    sub_book_ids += source_book_grid_obj.cells(item, 0).getValue() + ',';
                                });

                                sub_book_ids = sub_book_ids.substr(0, sub_book_ids.length - 1);

                                xml += ' sub_book_ids="' + sub_book_ids + '"';
                            } else {
                                xml += ' sub_book_ids="' + source_book_grid_obj.cells(selected_row_id, 0).getValue() + '"';
                            }
                        } else {
                            xml += ' sub_book_ids=""';
                        }
                    }
                }
            });
        }

        xml += '></FormXML></Root>';

        if (SHOW_SUBBOOK_IN_BS == 1 && sub_books == '' && show_unmapped_deals == 'n') {
            show_messagebox("Please select at least one Subsidiary or Strategy or Book or Sub Book.");
            setupDeals.deal_layout.cells("c").progressOff();
            return;
        }

        //Default is null. 400 for Hedge deals, 401 for Item deals.
        var trans_type = '<?php echo $trans_type; ?>';
        var call_from = '<?php echo $desisgnation_of_hedge; ?>';

        var sql_param = {
            "action":"spa_source_deal_header",
            "flag":"t",
            "filter_xml": xml,
            "trans_type": trans_type,
            "call_from":call_from
        };
        pivot_exec_spa = "EXEC spa_source_deal_header @flag= 's''"
            + "',@filter_xml='" + unescapeXML(xml)
            + "',@trans_type=" + trans_type
            + ",@call_from='" + call_from + "'";

        adiha_post_data("return", sql_param, '', '', 'setupDeals.smart_refresh');
    }

    /**
     * [smart_refresh Refresh grid using connector]
     * @param  {[type]} result [Return Data]
     */
    setupDeals.smart_refresh = function(result) {
        if (result[0].process_table == '' || result[0].process_table == null) {
            setupDeals.deal_layout.cells("c").progressOff();
            return;
        }

        setupDeals.setup_deals.enableHeaderMenu();
        var column_list = '<?php echo $column_list; ?>';
        var numeric_fields = '<?php echo $numeric_fields; ?>';
        var date_fields = '<?php echo $date_fields; ?>';
        var process_table = result[0].process_table;

        document.getElementById("txt_process_table").value = process_table;

        var sql_param = {
            "process_table":process_table,
            "text_field":column_list,
            "id_field": "id",
            "date_fields":date_fields,
            "numeric_fields":numeric_fields,
            "sorting_fields":"id::DESC"
        };
        sql_param = $.param(sql_param);
        var sql_url = js_php_path + "grid.connector.php?"+ sql_param;

        setupDeals.setup_deals.clearAll();
        setupDeals.setup_deals.loadXML(sql_url, function() {
            setupDeals.setup_deals.filterByAll();
            $('#hide_filter').prop('checked', false);

            setupDeals.show_hide_filter();

            if (!read_only_mode) {
                setupDeals.grid_row_selection(null);
            }
            setupDeals.deal_layout.cells("c").progressOff();
        });

        setupDeals.deal_menu.setItemEnabled('pivot');
    }

    /**
     * [open_update_popup Opens a deal update window, called on grid row double click]
     * @param  {[int]} row_id [Row Id from grid]
     * @param  {[int]} col_id [Column Id]
     */
    setupDeals.open_update_popup = function(row_id, col_id) {
        var deleted_checked = $('textarea[name="deleted_checked"]').val();
        //setupDeals.unload_deals_window();
        if (!update_window) {
            update_window = new dhtmlXWindows();
        }

        var row_id = setupDeals.setup_deals.getSelectedRowId();
        var subsidiary_index = setupDeals.setup_deals.getColIndexById('subsidiary');
        var subsidiary = setupDeals.setup_deals.cells(row_id, subsidiary_index).getValue();
        var book_index = setupDeals.setup_deals.getColIndexById('book');
        var book = setupDeals.setup_deals.cells(row_id, book_index).getValue();

        var buy_sell_index = setupDeals.setup_deals.getColIndexById('buy_sell');
        var buy_sell = setupDeals.setup_deals.cells(row_id, buy_sell_index).getValue();

        var deal_type_index = setupDeals.setup_deals.getColIndexById('deal_type');
        var deal_type = setupDeals.setup_deals.cells(row_id, deal_type_index).getValue(); 

        deal_id = setupDeals.setup_deals.cells(row_id, 0).getValue();
        var win_id = 'w_' + deal_id;
        var new_update_window = update_window.createWindow(win_id, 0, 0, 400, 400);
        new_update_window.setText("Deal - " + deal_id);
        new_update_window.centerOnScreen();
        //new_update_window.setModal(true);
        new_update_window.maximize();
        var param = {deal_id:deal_id,view_deleted:deleted_checked, buy_sell:buy_sell};
        new_update_window.attachURL('deal.detail.new.php?deal_type=' + deal_type, false, param);

        new_update_window.addUserButton("undock", 0, "Undock", "Undock");

        new_update_window.attachEvent("onClose", function(win){
            var ifr = win.getFrame();
            var ifrWindow = ifr.contentWindow;
            var ifrDocument = ifrWindow.document;
            var status = $('textarea[name="txt_save_status"]', ifrDocument).val();

            if (status != 'cancel') {
                setupDeals.refresh_grid();
            }
            return true;
        })

        url = app_form_path + '_deal_capture/maintain_deals/deal.detail.new.php';
        new_update_window.button("undock").attachEvent("onClick", function(){
            open_window(url, param);
        });
    }

    /**
     * [Enable/Disable Ok button on grid rows select/unselect]
     */
    setupDeals.on_row_select = function() {
        if (read_only_mode) {

            if (setupDeals.setup_deals.getSelectedRowId()) {
                setupDeals.deal_menu.setItemEnabled('ok');
                setupDeals.deal_menu.setItemEnabled('select_unselect');
            } else {
                setupDeals.deal_menu.setItemDisabled('ok');
            }

        }
    }
    /**
     * [grid_row_selection Grid rows select/unselect event function]
     * @param  {[string]} row_ids [row ids]
     */
    setupDeals.grid_row_selection = function(row_ids) {
        if (read_only_mode) return; //Buttons trying to set privilege are not loaded in case of read only mode. 
        
        var deleted_checked = $('textarea[name="deleted_checked"]').val();
        var has_rights_deal_edit = Boolean('<?php echo $has_rights_deal_edit; ?>');
        var has_delete_rights = Boolean('<?php echo $has_rights_deal_delete; ?>');
        var has_rights_change_deal_status = Boolean('<?php echo $has_rights_change_deal_status; ?>');
        var has_rights_change_confirm_status = Boolean('<?php echo $has_rights_change_confirm_status; ?>');
        var has_rights_lock_deals = Boolean('<?php echo $has_rights_lock_deals; ?>');
        var has_rights_unlock_deals = Boolean('<?php echo $has_rights_unlock_deals; ?>');
        var has_rights_view_audit_report = Boolean('<?php echo $has_rights_view_audit_report; ?>');
        var has_rights_update_volume = Boolean('<?php echo $has_rights_update_volume; ?>');
        var has_rights_copy = Boolean('<?php echo $has_rights_copy; ?>');
        var has_rights_transfer = Boolean('<?php echo $has_rights_transfer; ?>');
        var has_rights_schedule_deal = Boolean('<?php echo $has_rights_schedule_deal; ?>');
        var has_rights_trade_ticket = Boolean('<?php echo $has_rights_trade_ticket; ?>');
        var has_update_actual_edit = Boolean('<?php echo $enable_update_actual; ?>');
        var has_rights_void_deals = Boolean('<?php echo $has_rights_void_deals; ?>');
        var has_rights_unvoid_deals = Boolean('<?php echo $has_rights_unvoid_deals; ?>');

        if (row_ids != null && deleted_checked == 'n') {
            if (has_delete_rights) setupDeals.deal_menu.setItemEnabled('delete');
            if (has_rights_change_deal_status) setupDeals.deal_menu.setItemEnabled('deal_status');
            if (has_rights_lock_deals) setupDeals.deal_menu.setItemEnabled('lock');
            if (has_rights_unlock_deals) setupDeals.deal_menu.setItemEnabled('unlock');
            if (has_rights_view_audit_report) setupDeals.deal_menu.setItemEnabled('audit_report');
            if (has_rights_change_confirm_status) setupDeals.deal_menu.setItemEnabled('confirm_status');
            if (has_rights_schedule_deal) setupDeals.deal_menu.setItemEnabled('schedule_deal');
            if (has_rights_void_deals) setupDeals.deal_menu.setItemEnabled('void');
            if (has_rights_unvoid_deals) setupDeals.deal_menu.setItemEnabled('unvoid');
            setupDeals.deal_menu.setItemEnabled('group_deal');
            // setupDeals.deal_menu.setItemEnabled('scheduling_report');

            if (has_rights_deal_edit) {
                setupDeals.deal_menu.setItemEnabled('calc_position');
                setupDeals.deal_menu.setItemEnabled('cascade');		
				setupDeals.deal_menu.setItemEnabled('rewind_cascade');					
                setupDeals.deal_menu.setItemEnabled('update_book');
            }
            setupDeals.deal_menu.setItemEnabled('generate_confirmation');
            setupDeals.deal_menu.setItemEnabled('workflow_report');
            if(has_rights_trade_ticket) setupDeals.deal_menu.setItemEnabled('trade_ticket');
            if (has_rights_update_volume) setupDeals.deal_menu.setItemEnabled('update_volume');

            if (row_ids.indexOf(",") == -1) {
                setupDeals.deal_menu.setItemEnabled('position_report');
                if (has_rights_copy) setupDeals.deal_menu.setItemEnabled('copy');
                if (has_rights_transfer) setupDeals.deal_menu.setItemEnabled('transfer');
                if (has_update_actual_edit) setupDeals.deal_menu.setItemEnabled('update_actual');
                setupDeals.deal_menu.setItemEnabled('dashboard_reports');                
            } else {
                setupDeals.deal_menu.setItemDisabled('copy');
                setupDeals.deal_menu.setItemDisabled('transfer');
                setupDeals.deal_menu.setItemDisabled('update_actual');
                setupDeals.deal_menu.setItemDisabled('dashboard_reports');
            }
        } else {
            setupDeals.deal_menu.setItemDisabled('delete');
            setupDeals.deal_menu.setItemDisabled('deal_status');
            setupDeals.deal_menu.setItemDisabled('confirm_status');
            setupDeals.deal_menu.setItemDisabled('lock');
            setupDeals.deal_menu.setItemDisabled('unlock');
            setupDeals.deal_menu.setItemDisabled('audit_report');
            setupDeals.deal_menu.setItemDisabled('calc_position');
            setupDeals.deal_menu.setItemDisabled('cascade');	
			setupDeals.deal_menu.setItemDisabled('rewind_cascade');						
            setupDeals.deal_menu.setItemDisabled('position_report');
            setupDeals.deal_menu.setItemDisabled('generate_confirmation');
            setupDeals.deal_menu.setItemDisabled('trade_ticket');
            setupDeals.deal_menu.setItemDisabled('update_volume');
            setupDeals.deal_menu.setItemDisabled('copy');
            setupDeals.deal_menu.setItemDisabled('transfer');
            setupDeals.deal_menu.setItemDisabled('update_book');
            setupDeals.deal_menu.setItemDisabled('schedule_deal');
            setupDeals.deal_menu.setItemDisabled('workflow_report');
            setupDeals.deal_menu.setItemDisabled('group_deal');
            setupDeals.deal_menu.setItemDisabled('update_actual');
            setupDeals.deal_menu.setItemDisabled('dashboard_reports');
            // setupDeals.deal_menu.setItemDisabled('scheduling_report');

            if (row_ids != null && has_rights_view_audit_report) setupDeals.deal_menu.setItemEnabled('audit_report');
        }
    }

    /**
     * [check_deals Check deals before deleting]
     * @param  {[array]} return_value [return array]
     */
    setupDeals.check_deals = function(return_value) {
        if (return_value[0][1] != '' && return_value[0][1] != null) {
            setupDeals.delete_failed(return_value[0][1]);
            return;
        }

        if (return_value[0][8] != '' && return_value[0][8] != null) {
            setupDeals.delete_failed(return_value[0][8]);
            return;
        }

        if (return_value[0][3] != '' && return_value[0][3] != null) {
            setupDeals.delete_failed(return_value[0][3]);
            return;
        }

        if (return_value[0][4] != '' && return_value[0][4] != null) {
            setupDeals.delete_failed(return_value[0][4]);
            return;
        }

        if (return_value[0][2] != '' && return_value[0][2] != null) {
            confirm_messagebox(return_value[0][2],
                function(){
                    setupDeals.open_comment_window(return_value[0][0], return_value[0][5]);
                },
                function(){
                    return;
                }
            );
        } 
        else if (return_value[0][6] != '' && return_value[0][6] != null) {
            confirm_messagebox(return_value[0][6],
                function(){
                    setupDeals.open_comment_window(return_value[0][0]);
                },
                function(){
                    return;
                }
            );
        }
         else if (return_value[0][7] != '' && return_value[0][7] != null) {
            confirm_messagebox(return_value[0][7],
                function(){
                    setupDeals.open_comment_window(return_value[0][0], return_value[0][5]);
                },
                function(){
                    return;
                }
            );
        }
        else {
            setupDeals.open_comment_window(return_value[0][0], return_value[0][5]);
        }
    }

    /**
     * [open_comment_window Open comment window to insert comment for deleting deals]
     * @param  {[char]} comment [Comment required]
     * @return {[type]}         [description]
     */
    setupDeals.open_comment_window = function(comment_required, source_deal_id) {
        if (comment_required == 'y') {
            setupDeals.unload_deals_window();
            if (!comment_window) {
                comment_window = new dhtmlXWindows();
            }

            var win = comment_window.createWindow('w1', 0, 0, 600, 350);
            win.setText("Deal Delete Comment");
            win.centerOnScreen();
            win.setModal(true);
            win.button('minmax').hide();
            win.button('park').hide();
            var source_url = 'deal.delete.comment.php?source_deal_id=' + source_deal_id;
            win.attachURL(source_url, false, true);

            win.attachEvent('onClose', function(w) {
                var ifr = w.getFrame();
                var ifrWindow = ifr.contentWindow;
                var ifrDocument = ifrWindow.document;
                delete_status = $('textarea[name="delete_status"]', ifrDocument).val();
                delete_comment = $('textarea[name="delete_comments"]', ifrDocument).val();
                setupDeals.delete_deals(delete_status, delete_comment);
                return true;
            });
        } else {
            setupDeals.delete_deals('ok', '');
        }
    }

    /**
     * [delete_deals Delete deals]
     * @param  {[string]} delete_status  [status to carry on the delete]
     * @param  {[string]} delete_comment [delete comments]
     */
    setupDeals.delete_deals = function(delete_status, delete_comment) {
        if (delete_status == 'cancel') {
            return;
        } else {
            setupDeals.deal_layout.cells("c").progressOn();
            var selected_ids = setupDeals.setup_deals.getColumnValues(0);
            data = {"action": "spa_source_deal_header", "flag":"d", "deal_ids":selected_ids, "comments":delete_comment};
            adiha_post_data("return_array", data, '', '', 'setupDeals.delete_deals_callback');
        }
    }

    /**
     * [delete_deals_callback Deal delete callback]
     * @param  {[array]} return_value [description]
     */
    setupDeals.delete_deals_callback = function(return_value) {
        setupDeals.deal_layout.cells("c").progressOff();
        if (return_value[0][0] == 'Success') {
            dhtmlx.message({
                text:return_value[0][4],
                expire:1000
            });
            setupDeals.refresh_grid();
        } else {
            setupDeals.delete_failed(return_value[0][4]);
            return;
        }
    }

    /**
     * [delete_failed Display delete failed notifications]
     * @param  {[string]} message [Failed message]
     */
    setupDeals.delete_failed = function(message) {
        show_messagebox(message);
    }

    /**
     * [unload_deals_window Unload splitting invoice window.]
     */
    setupDeals.unload_deals_window = function() {
        if (blotter_window != null && blotter_window.unload != null) {
            blotter_window.unload();
            blotter_window = w1 = null;
        }

        if (update_window != null && update_window.unload != null) {
            update_window.unload();
            update_window = w1 = null;
        }

        if (comment_window != null && comment_window.unload != null) {
            comment_window.unload();
            comment_window = w1 = null;
        }

        if (status_window != null && status_window.unload != null) {
            status_window.unload();
            status_window = w1 = null;
        }

        if (confirm_window != null && confirm_window.unload != null) {
            confirm_window.unload();
            confirm_window = w1 = null;
        }

        if (volume_window != null && volume_window.unload != null) {
            volume_window.unload();
            volume_window = w1 = null;
        }

        if (trade_window != null && trade_window.unload != null) {
            trade_window.unload();
            trade_window = w1 = null;
        }
    }

    /**
     * [lock_unlock_deals Lock/Unlock Deals]
     * @param  {[type]} status [lock unlock status]
     */
    setupDeals.lock_unlock_deals = function(status) {
        var status_name = (status == 'y') ? 'lock' : 'unlock';
        var message =  "Are you sure you want to " + status_name + " selected deal(s)?";
        show_messagebox(message, function() {
                    var selected_ids = setupDeals.setup_deals.getColumnValues(0);
                    data = {"action": "spa_source_deal_header", "flag":"l", "lock_unlock":status, "deal_ids":selected_ids};
                    adiha_post_data("alert", data, '', '', 'setupDeals.refresh_grid');
        });
    }

    /**
     * [void_unvoid_deals Void/UnVoid Deals]
     * @param  {[type]} void_unvoid_status [void unvoid status]
     * note --> 5607 hard coded for Cancelled and 5606 for amendend
     */
    setupDeals.void_unvoid_deals = function(void_unvoid_status) {
        var deal_status = (void_unvoid_status == 'void') ? 5607 :  5606
        var message = "Are you sure you want to " + void_unvoid_status + " selected deal(s)?";
        confirm_messagebox(message, function(){
            var selected_ids = setupDeals.setup_deals.getColumnValues(0);
            data = {"action": "spa_source_deal_header", "flag":"m", "deal_status":deal_status, "deal_ids":selected_ids};
            adiha_post_data("alert", data, '', '', 'setupDeals.refresh_grid');
        });

    }


    /**
     * [change_status Change status]
     * @param  {[type]} status_type [Status type - deal and confirm]
     * @return {[type]}             [description]
     */
    setupDeals.change_status = function(status_type) {
        setupDeals.unload_deals_window();
        if (!status_window) {
            status_window = new dhtmlXWindows();
        }
        var selected_ids = setupDeals.setup_deals.getColumnValues(0);
        var width = 400;
        var height = 300;
        var win_title = 'Change Deal Status';
        var win_url = 'change.deal.status.php';

        if (status_type == 'confirm') {
            width = 800;
            height = 600;
            win_title = 'Confirmation History -' + selected_ids;

            if (selected_ids.indexOf(",") == -1) {
                win_url = 'confirm.status.history.php';
            } else {
                width = 560;
                height = 380;
                win_url = 'change.confirm.status.php';
            }
        }

        var win = status_window.createWindow('w1', 0, 0, width, height);
        win.setText(win_title);
        win.centerOnScreen();
        win.setModal(true);
        //win.button('minmax').hide();
        win.button('park').hide();

        win.attachURL(win_url, false, {deal_ids:selected_ids});

        win.attachEvent('onClose', function(w) {
            var ifr = w.getFrame();
            var ifrWindow = ifr.contentWindow;
            var ifrDocument = ifrWindow.document;
            var success_status = $('textarea[name="success_status"]', ifrDocument).val();
            if (success_status == 'Success') {
                setupDeals.refresh_grid();
            }
            return true;
        });
    }

    /**
     * [open_report Open Report]
     * @param  {[type]} report_type [Report type]
     */
    setupDeals.open_report = function(report_type) {
        var selected_deal_ids = setupDeals.setup_deals.getColumnValues(0);
        var deleted_checked = $('textarea[name="deleted_checked"]').val();
        if (report_type == 'position') {
            var deal_date_index = setupDeals.setup_deals.getColIndexById('deal_date');
            var deal_dates = setupDeals.setup_deals.getColumnValues(deal_date_index);
            deal_date_array = deal_dates.split(',');
            deal_date = jQuery.map(deal_date_array, function( n, i ) {
                return dates.convert_to_sql(n);
            }).join(',');
            var exec_call = "EXEC spa_create_hourly_position_report 'm', NULL, NULL, NULL, NULL, '" + deal_date + "', NULL, NULL, 982, 'i', NULL, NULL, NULL, NULL,'" + selected_deal_ids + "', NULL, NULL, NULL, NULL, NULL, 2, NULL, NULL, 'b', 'a', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL";
        } else if (report_type == 'audit') {
            var exec_call = 'EXEC spa_Create_Deal_Audit_Report '
                + singleQuote('c') + ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '
                + singleQuote(selected_deal_ids) + ', NULL, NULL, '
                + ' NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,' + singleQuote(deleted_checked);
        }

        var sp_url = js_php_path + 'dev/spa_html.php?spa=' + exec_call + '&' + getAppUserName();
        openHTMLWindow(sp_url);
    }

    /**
     * [open_confirmation_report Open Confirmation Report]
     */
    setupDeals.open_confirmation_report = function() {
        var selected_ids = setupDeals.setup_deals.getColumnValues(0);
        setupDeals.deal_layout.cells('c').progressOn();
        generate_document_for_view(selected_ids, '33', '42018', 'confirmation_report_callback');
    }

    confirmation_report_callback = function(status, file_path) {
        setupDeals.deal_layout.cells('c').progressOff();
    }

    setupDeals.scheduling_report_callback = function(result) {
        var result = JSON.parse(result);

        var deal_id = result[0]['deal_id']
        deal_id = deal_id.replace(',', '!!!');
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
            'sec_filters_info': 'commodity_id=NULL,contract_id=NULL,counterparty_id=NULL,deal_id=' + deal_id + ',location_id=NULL,shipment_id=NULL,sub_id=NULL,stra_id=NULL,book_id=NULL,sub_book_id=NULL_-_' + process_id + ''
        }

        w2.attachURL(url, false, param);

        w2.attachEvent("onClose", function(win) {
              return true;
        });
    }


    /**
     * [open_trade_ticket Open Trade Ticket]
     */
    window_trade_ticket = null;
    setupDeals.open_trade_ticket = function() {
        setupDeals.unload_deals_window();
        if (!trade_window) {
            trade_window = new dhtmlXWindows();
        }
        var selected_ids = setupDeals.setup_deals.getColumnValues(0);
        var win_title = 'Run Trade Ticket';
        var win_url = 'trade.ticket.php';

        window_trade_ticket = trade_window.createWindow('w1', 0, 0, 500, 500);
        window_trade_ticket.progressOn();
        window_trade_ticket.setText(win_title);
        window_trade_ticket.centerOnScreen();
        window_trade_ticket.setModal(true);
        window_trade_ticket.maximize();

        window_trade_ticket.attachURL(win_url, false, {deal_ids:selected_ids});
    }

    /**
     * [open_update_volume Update Deal Volume]
     */
    setupDeals.open_update_volume = function() {
        setupDeals.unload_deals_window();
        if (!volume_window) {
            volume_window = new dhtmlXWindows();
        }
        var selected_ids = setupDeals.setup_deals.getColumnValues(0);

        data = {"action": "spa_shaped_deal", "flag":"z", "source_deal_header_id":selected_ids};
        adiha_post_data("return_array", data, '', '', 'setupDeals.check_deal_frequency');


    }

    setupDeals.check_deal_frequency = function(return_value) {
        recommendation = return_value[0][5];
        term_frequency_type = recommendation.split(',')[0];
        profile_id = recommendation.split(',')[1];

        if (return_value[0][0] == 'Success') {
            var selected_ids = setupDeals.setup_deals.getColumnValues(0);
            data = {"action": "spa_shaped_deal", "flag":"c", "source_deal_header_id":selected_ids};
            adiha_post_data("return_array", data, '', '', 'setupDeals.open_update_volume_post');
        } else {
            setupDeals.profile_type_mismatch(return_value[0][4]);//used same alert function.
            return;
        }
    }

    setupDeals.open_update_volume_post = function(return_value) {
        if (return_value[0][0] == 'Success') {
            var win_title = 'Update Volume';
            var win_url = 'shaped.deals.php';

            var selected_ids = setupDeals.setup_deals.getColumnValues(0);
            var win = volume_window.createWindow('w1', 0, 0, 400, 400);
            var term_start = setupDeals.setup_deals.getColumnValues(9);
            term_start = dates.convert_to_sql(term_start);
            var term_end = setupDeals.setup_deals.getColumnValues(10);
            term_end = dates.convert_to_sql(term_end);

            if (return_value[0][5] == 17301) {
                win_url = '../../_price_curve_management/update_profile_data/update.profile.data.php?profile_id=' + profile_id + '&call_from=deal_detail&term_start=' + term_start + '&term_end=' + term_end;
            } else {
                win_url = (term_frequency_type == 'd') ? 'update.demand.shaped.volume.php' : win_url;    
            }

            win.setText(win_title);
            win.centerOnScreen();
            win.setModal(true);
            win.maximize();
            win.attachURL(win_url, false, {deal_ref_ids:selected_ids, profile_type:return_value[0][5],term_start:term_start});
        } else  {
            setupDeals.profile_type_mismatch(return_value[0][4]);
            return;
        }
    }

    /**
     * [profile_type_mismatch Display msg for mismatch deals profile type]
     * @param  {[string]} message [Failed message]
     */
    setupDeals.profile_type_mismatch = function(message) {
        show_messagebox(message);
    }

    /**
     * [open_schedule_deal Schedule Deal]
     */
    setupDeals.open_schedule_deal = function() {
        var row_id = setupDeals.setup_deals.getSelectedRowId();

         if(setupDeals.setup_deals.cells(row_id, setupDeals.setup_deals.getColIndexById('buy_sell')).getValue() == 'Sell') {
            show_messagebox("Sell deal cannot be scheduled.");
            return;
         }
		 if(setupDeals.setup_deals.cells(row_id, setupDeals.setup_deals.getColIndexById('commodity')).getValue() == 'Power') {
            show_messagebox("Power deal cannot be scheduled.");
            return;
         }
         if(setupDeals.setup_deals.cells(row_id, setupDeals.setup_deals.getColIndexById('physical_financial_flag')).getValue() == 'Financial'){
            show_messagebox("Financial deal cannot be scheduled.");
            return;
         }

        if(row_id.indexOf(',') > -1) {
            show_messagebox('Please select one record to process.');
            return;
        }
        setupDeals.unload_deals_window();
        if (!volume_window) {
            volume_window = new dhtmlXWindows();
        }
        var selected_ids = setupDeals.setup_deals.getColumnValues(0);
		
	
		data = {"action": "spa_source_deal_header", "flag":"r", "deal_ids":selected_ids};
		adiha_post_data("return_array", data, '', '', 'setupDeals.open_schedule_deal_callback');
			
       
    }
	
	setupDeals.open_schedule_deal_callback = function(return_value) {
		var row_id = setupDeals.setup_deals.getSelectedRowId();
		
        //store first rec loc id and rec loc group id, since it's value will be same for whole array
        var from_loc_id = return_value[0][0];
        var from_loc_group_id = return_value[0][1];
        var to_loc_id_arr = [];
        var to_loc_group_id_arr = [];

        //get comma separated to_loc ids and to_loc group ids
        $.each(return_value, function(k,v) {
            to_loc_id_arr.push(v[2]);
            to_loc_group_id_arr.push(v[3]);
        });
        to_loc_id = to_loc_id_arr.join(',');
        to_loc_group_id = to_loc_group_id_arr.join(',');

		var win_title = 'Schedule Deal';
        //var win_url = '../../_scheduling_delivery/gas/flow_optimization/match.php';
        var win_url = '../../_scheduling_delivery/gas/flow_optimization/flow.deal.match.php';

        var param = {};
        var cols = new Array();
        setupDeals.setup_deals.forEachCell(0, function(cell_obj, ind) {
            cols.push(setupDeals.setup_deals.getColumnId(ind));
        })
		
		 var selected_ids = setupDeals.setup_deals.getColumnValues(0);

        param.volume = setupDeals.setup_deals.cells(row_id, setupDeals.setup_deals.getColIndexById('deal_volume')).getValue();
        param.location_id = setupDeals.setup_deals.cells(row_id, setupDeals.setup_deals.getColIndexById('location_id')).getValue();
        param.counterparty_id = setupDeals.setup_deals.cells(row_id, setupDeals.setup_deals.getColIndexById('counterparty')).getValue();

        param.term = dates.convert_to_sql(setupDeals.setup_deals.cells(row_id, setupDeals.setup_deals.getColIndexById('term_start')).getValue());
        param.term_end = dates.convert_to_sql(setupDeals.setup_deals.cells(row_id, setupDeals.setup_deals.getColIndexById('term_end')).getValue());
        param.source_deal_header_id = selected_ids;
        param.group_by = 'Deal';
        
		win_url += '?flow_date_from=' + param.term 
            + '&flow_date_to=' + param.term_end 
            + '&receipt_loc_id=' + from_loc_id 
            + '&delivery_loc_id=' + to_loc_id 
            + '&from_loc_grp_id=' + from_loc_group_id 
            + '&to_loc_grp_id=' + to_loc_group_id
            + '&source_deal_header_id=' + param.source_deal_header_id  
            + '&call_from_ui=deal_schedule';  
		
		var win = volume_window.createWindow('w1', 0, 0, 400, 400);
        win.setText(win_title);
        win.centerOnScreen();
        win.setModal(true);
        //win.addUserButton("reload", 0, "Reload", "Reload");
        win.maximize();

        win.attachURL(win_url, null);
	}

    var deal_transfer_window;
    setupDeals.open_deal_transfer = function() {
        var selected_ids = setupDeals.setup_deals.getColumnValues(0);
        if (deal_transfer_window != null && deal_transfer_window.unload != null) {
            deal_transfer_window.unload();
            deal_transfer_window = w1 = null;
        }

        if (!deal_transfer_window) {
            deal_transfer_window = new dhtmlXWindows();
        }

        var transfer_win = deal_transfer_window.createWindow('w1', 0, 0, 660, 480);
        transfer_win.setText("Deal Transfer - " + selected_ids);
        transfer_win.centerOnScreen();
        transfer_win.setModal(true);
        //transfer_win.denyResize();
        //transfer_win.button('minmax').hide();
        transfer_win.attachURL('deal.transfer.php', false, {deal_id:selected_ids});
        transfer_win.maximize();

        transfer_win.attachEvent('onClose', function(w) {
            var ifr = w.getFrame();
            var ifrWindow = ifr.contentWindow;
            var ifrDocument = ifrWindow.document;
            var return_string = $('textarea[name="txt_status"]', ifrDocument).val();

            if (return_string.toLowerCase() == 'success') {
                setupDeals.refresh_grid();
            }

            return true;
        });
    }

    var update_book_win;
    setupDeals.open_update_book = function() {
        var selected_ids = setupDeals.setup_deals.getColumnValues(0);

        if (update_book_win != null && update_book_win.unload != null) {
            update_book_win.unload();
            update_book_win = w1 = null;
        }

        if (!update_book_win) {
            update_book_win = new dhtmlXWindows();
        }

        if (SHOW_SUBBOOK_IN_BS == 0){
            var update_book = update_book_win.createWindow('w1', 0, 0, 1000, 550);
        } else {
            var update_book = update_book_win.createWindow('w1', 0, 0, 500, 650);
        }

        update_book.setText("Update Book");
        update_book.centerOnScreen();
        update_book.setModal(true);
        update_book.denyResize();
        update_book.button('minmax').hide();
        update_book.attachURL(js_php_path+'book.browser.php', false, {enable_subbook:1,win_name:'update_book_win'});

        update_book.attachEvent('onClose', function(w) {
            var ifr = w.getFrame();
            var ifrWindow = ifr.contentWindow;
            var ifrDocument = ifrWindow.document;
            var return_string = $('textarea[name="return_string"]', ifrDocument).val();

            if (return_string != '') {
                var return_array = JSON.parse(return_string);
                var new_subbook = return_array[3];
                setupDeals.update_subook(selected_ids, new_subbook);
            }

            return true;
        });
    }

    setupDeals.update_subook = function(deal_ids, sub_book) {
        data = {"action": "spa_source_deal_header", "flag":"y", "deal_ids":deal_ids, "sub_book":sub_book};

        // use callback that is already available
        adiha_post_data("return_array", data, '', '', 'setupDeals.delete_deals_callback');
    }

    setupDeals.workflow_report = function() {
        var selected_ids = setupDeals.setup_deals.getColumnValues(0);
        var workflow_report = new dhtmlXWindows();
        workflow_report_win = workflow_report.createWindow('w1', 0, 0, 900, 700);
        workflow_report_win.setText("Workflow Status");
        workflow_report_win.centerOnScreen();
        workflow_report_win.setModal(true);
        workflow_report_win.maximize();

        var filter_string = 'Deal ID = <i>' + setupDeals.setup_deals.getColumnValues(0) +  '</i>,  Ref ID = <i>' + setupDeals.setup_deals.getColumnValues(1) + '</i>';
        var process_table_xml = 'source_deal_header_id:' + selected_ids;
        var page_url = js_php_path + '../adiha.html.forms/_compliance_management/setup_rule_workflow/workflow.report.php?filter_id=' + selected_ids + '&source_column=source_deal_header_id&module_id=20601&process_table_xml=' + process_table_xml + '&filter_string=' + filter_string;
        workflow_report_win.attachURL(page_url, false, null);
    }

    var deal_group_window;
    /**
     * [open_deal_group Open deal grouping window (Grouping by structure deal id)]
     */
    setupDeals.open_deal_group = function() {
        var selected_ids = setupDeals.setup_deals.getColumnValues(0);
        if (deal_group_window != null && deal_group_window.unload != null) {
            deal_group_window.unload();
            deal_group_window = w1 = null;
        }

        if (!deal_group_window) {
            deal_group_window = new dhtmlXWindows();
        }

        var group_win = deal_group_window.createWindow('w1', 0, 0, 900, 480);
        group_win.setText("Deal Group");
        group_win.centerOnScreen();
        group_win.setModal(true);
        group_win.attachURL('deal.group.php', false, {deal_id:selected_ids});
    }

    /**
     * [update_actual_clicked Update Actual Click.]
     */
    setupDeals.update_actual_clicked = function() {
        var deal_id = setupDeals.setup_deals.getColumnValues(0);
        var data = {
            "action":"spa_source_deal_header",
            "flag":'f',
            "deal_ids":deal_id
        }
        adiha_post_data("return", data, '', '', 'setupDeals.open_update_actual');
    }

    var update_actual_window;
    /**
     * [open_update_actual Open Update Actual Volume UI.]
     */
    setupDeals.open_update_actual = function(result) {
        if (update_actual_window != null && update_actual_window.unload != null) {
            update_actual_window.unload();
            update_actual_window = w1 = null;
        }

        if (!update_actual_window) {
            update_actual_window = new dhtmlXWindows();
        }
        var win_title = 'Update Actual Volume';
        if (result[0].actualization_flag == 'd') {
            var win_url = 'update.actual.deal.php';
        } else if (result[0].actualization_flag == 'm') {
            var win_url = 'update.actual.meter.php';
        } else {
            var win_url = 'update.actual.php';
        }
        var deal_id = setupDeals.setup_deals.getColumnValues(0);

        var win_title = 'Update Actual Volume (Deal: ' + deal_id + ')';

        var win = update_actual_window.createWindow('w1', 0, 0, 500, 500);
        win.setText(win_title);
        win.centerOnScreen();
        win.setModal(true);
        win.maximize();
        win.attachURL(win_url, false, {deal_id:deal_id});

        /*
         win.attachEvent('onClose', function(w) {
         setupDeals.refresh_document_grid();
         return true;
         });
         */
    }
	
	$(window).keydown(function(event) {
		if(event.ctrlKey && event.keyCode == 73) { 
			event.preventDefault(); 			
			setupDeals.open_blotter();
		  }
		  
		if(event.altKey && event.keyCode == 73) { 
			event.preventDefault(); 
			setupDeals.open_deal_insert();
		}
	});
</script>

</html>
<style type="text/css">
    html, body {
        width: 100%;
        height: 100%;
        margin: 0px;
        padding: 0px;
        background-color: #ebebeb;
        overflow: hidden;
    }
    .search-box {
        margin: 5px;
        padding: 5px;
    }

    .search-input {
        width: 97%;
        height: 30px;
        padding: 6px 12px;
        font-size: 14px;
        line-height: 1.42857143;
        color: #555;
        background-color: #fff;
        background-image: none;
        border: 1px solid #ccc;
        border-radius: 4px;
        -webkit-box-shadow: inset 0 1px 1px rgba(0, 0, 0, .075);
        box-shadow: inset 0 1px 1px rgba(0, 0, 0, .075);
        -webkit-transition: border-color ease-in-out .15s, -webkit-box-shadow ease-in-out .15s;
        -o-transition: border-color ease-in-out .15s, box-shadow ease-in-out .15s;
        transition: border-color ease-in-out .15s, box-shadow ease-in-out .15s;
    }
    .pull-left {
        float: left !important;
    }

    @media (min-width: 1200px) {
        .search-input {
            width:98%;
        }
    }

    .onoffswitch {
        position: relative; width: 130px;
        -webkit-user-select:none; -moz-user-select:none; -ms-user-select: none;
    }
    .onoffswitch-checkbox,
    .hide_filter-checkbox {
        display: none;
    }
    .onoffswitch-label,
    .hide-filter-label {
        display: block; overflow: hidden; cursor: pointer;
        border: 2px solid #999999; border-radius: 20px;
    }
    .onoffswitch-inner,
    .hide-filter-inner {
        display: block; width: 200%; margin-left: -100%;
        transition: margin 0.3s ease-in 0s;
    }
    .onoffswitch-inner:before, .onoffswitch-inner:after,
    .hide-filter-inner:before, .hide-filter-inner:after {
        display: block; float: left; width: 50%; height: 16px; padding: 0; line-height: 16px;
        font-size: 13px; color: white; font-family: Trebuchet, Arial, sans-serif; font-weight: bold;
        box-sizing: border-box;
    }
    .onoffswitch-inner:before {
        content: "<?php echo get_locale_value("Text Search") ?>";
        padding-left: 10px;
        background-color: #34A7C1; color: #FFFFFF;
    }
    .onoffswitch-inner:after {
        content: "<?php echo get_locale_value("Advance Filters") ?>";
        padding-right: 10px;
        background-color: #EEEEEE; color: #999999;
        text-align: right;
    }

    .hide-filter-inner:before {
        content: "<?php echo get_locale_value("Hide Filters")?>";
        padding-left: 10px;
        background-color: #34A7C1; color: #FFFFFF;
    }
    .hide-filter-inner:after {
        content: "<?php echo get_locale_value("Show Filter")?>";
        padding-right: 10px;
        background-color: #EEEEEE; color: #999999;
        text-align: right;
    }
    .onoffswitch-switch,
    .hide-filter-switch {
        display: block; width: 12px; margin: 2px;
        background: #FFFFFF;
        position: absolute; top: 0; bottom: 0;
        right: 110px;
        border: 2px solid #999999; border-radius: 50px;
        transition: all 0.3s ease-in 0s;
    }

    .onoffswitch-checkbox:checked + .onoffswitch-label .onoffswitch-inner,
    .hide_filter-checkbox:checked + .hide-filter-label .hide-filter-inner {
        margin-left: 0;
    }
    .onoffswitch-checkbox:checked + .onoffswitch-label .onoffswitch-switch,
    .hide_filter-checkbox:checked + .hide-filter-label .hide-filter-switch {
        right: 0px;
    }
</style>