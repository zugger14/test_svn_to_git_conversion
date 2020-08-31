<?php
/**
* Maintain deals screen
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
		$confirm_status_type = (isset($_REQUEST["confirm_status_type"]) && $_REQUEST["confirm_status_type"] != '') ? get_sanitized_value($_REQUEST["confirm_status_type"]) : '';
		
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
        //$rights_schedule_deal = 10131028;
        
        $read_only_mode = get_sanitized_value($_POST['read_only'] ?? false, 'boolean');      
        $col_list = get_sanitized_value($_POST['col_list'] ?? '');   
        $callback_function = get_sanitized_value($_POST['deal_select_completed'] ?? '');    
        $trans_type = get_sanitized_value($_POST['trans_type'] ?? 'NULL');    
    
        list (
             $has_rights_deal_edit,        
             $has_rights_deal_delete,
             $has_rights_change_deal_status,
             $has_rights_change_confirm_status,
             $has_rights_lock_deals,
             $has_rights_unlock_deals,
             $has_rights_view_audit_report,
             $has_rights_update_volume
        ) = build_security_rights(
             $rights_deal_edit, 
             $rights_deal_delete,
             $rights_change_deal_status,
             $rights_change_confirm_status,
             $rights_lock_deals,
             $rights_unlock_deals,
             $rights_view_audit_report,
             $rights_update_volume
        );

        $layout_json = '[
                            {id: "a", text: "Portfolio", fix_size:[false,true]},
                            {id: "b", text: "Deal Attributes"},
                            {id: "c", text:"<div><a class=\"undock_deals undock_custom\" title=\"Undock\" onClick=\"setupDeals.undock_deals()\"></a>Deals</div>", header:true}
                        ]';
        $layout_obj = new AdihaLayout();
        echo $layout_obj->init_layout('deal_layout', '', '3L', $layout_json, $form_namespace);
        echo $layout_obj->attach_event('', 'onDock', $form_namespace . '.on_dock_event');
        echo $layout_obj->attach_event('', 'onUnDock', $form_namespace . '.on_undock_event');
        
        $portfolio_name = 'portfolio_filter';
        echo $layout_obj->attach_tree_cell($portfolio_name, 'a');

        $portfolio_obj = new AdihaBookStructure(10131000);
        echo $portfolio_obj->init_by_attach($portfolio_name, $form_namespace);
        echo $portfolio_obj->set_portfolio_option(2);
        echo $portfolio_obj->set_subsidiary_option(2);
        echo $portfolio_obj->set_strategy_option(2);
        echo $portfolio_obj->set_book_option(2);
        echo $portfolio_obj->set_subbook_option(2);
        echo $portfolio_obj->load_book_structure_data();
        echo $portfolio_obj->expand_level('all');
        echo $portfolio_obj->enable_three_state_checkbox();
        echo $portfolio_obj->load_tree_functons();

        $toolbar_obj = new AdihaToolbar();
        echo $layout_obj->attach_toolbar_cell('filter_toggle', 'b');
        echo $toolbar_obj->init_by_attach('filter_toggle', $form_namespace);

        $text = '<div class="row"><div class="pull-left"><div class="onoffswitch">';
        $text .= '<input type="checkbox" name="onoffswitch" class="onoffswitch-checkbox" id="filter_toggler" checked>';
        $text .= '<label class="onoffswitch-label" for="filter_toggler">';
        $text .= '<span class="onoffswitch-inner"></span>';
        $text .= '<span class="onoffswitch-switch"></span>';
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

        $menu_json = '[  
                        {id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif", title: "Refresh"},
                        ';
        if ($read_only_mode)  {
            $menu_json = $menu_json . '{id:"ok", text:"Ok", img:"tick.png", title:"Ok"},';
            $menu_json = $menu_json . '{id:"select_unselect", text:"Select/Unselect All", img:"select_unselect.gif", imgdis:"select_unselect_dis.gif", enabled: 1}]';
        } else {         
            $menu_json = $menu_json .
                        '
                        {id:"t1", text:"Edit", img:"edit.gif", imgdis:"new_dis.gif" ,items:[
                            {id:"blotter", text:"Insert deal\/s using blotter", img:"new.gif", enabled:' . (int)$has_rights_deal_edit . ' ,imgdis:"new_dis.gif", title: "Insert deals using blotter"},
                            {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete",enabled:false},
                        ]},
                        {id:"t2", text:"Export", img:"export.gif", items:[
                            {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                            {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                        ]},
                        {id:"t3", text:"Process", img:"action.gif", items:[
                            {id:"calc_position", text:"Calculate Position", img:"calc_position.gif", imgdis:"calc_position_dis.gif", title: "Calculate Position", enabled:' . (int)$has_rights_deal_edit . '},
                            {id:"lock", text:"Lock", img:"lock.gif", imgdis:"lock_dis.gif", title: "Lock", enabled:false},
                            {id:"unlock", text:"Unlock", img:"unlock.gif", imgdis:"unlock_dis.gif", title: "Unlock", enabled:false},
                            {id:"deal_status", text:"Change Deal Status", img:"change_deal_status.gif", imgdis:"change_deal_status_dis.gif", title: "Change Deal Status", enabled:false},
                            {id:"confirm_status", text:"Change Confirm Status", img:"update_invoice_stat.gif", imgdis:"update_invoice_stat_dis.gif", title: "Change Confirm Status", enabled:false},
                            {id:"update_volume", text:"Update Volume", img:"update_volume.gif", imgdis:"update_volume_dis.gif", title: "Update Volume", enabled:false}
                        ]},
                        {id:"t4", text:"Reports", img:"report.gif", items:[
                            {id:"position_report", text:"View Position Report", img:"finalize.gif", imgdis:"finalize_dis.gif", title: "View Position Report", enabled:false},
                            {id:"audit_report", text:"View Audit Report", img:"audit.gif", imgdis:"audit_dis.gif", title: "View Audit Report", enabled:false},
                            {id:"generate_confirmation", text:"Generate Confirmation", img:"gene_confirm.gif", imgdis:"gene_confirm_dis.gif", title: "Generate Confirmation", enabled:false},
                            {id:"trade_ticket", text:"Run Trade Ticket", img:"run_trade_ticket.gif", imgdis:"run_trade_ticket_dis.gif", title: "Run Trade Ticket", enabled:false}
                        ]}                        
                        ]';
        }
        echo $menu_object->init_by_attach('deal_menu', $form_namespace);
        echo $menu_object->load_menu($menu_json);
        echo $menu_object->attach_event('', 'onClick', $form_namespace . '.deal_menu_click');

        // attach grid
        echo $layout_obj->attach_grid_cell('setup_deals', 'c');
        echo $layout_obj->attach_status_bar("c", true);
        $grid_obj = new GridTable('setup_deals');        
        echo $grid_obj->init_grid_table('setup_deals', $form_namespace);
        echo $grid_obj->set_column_auto_size();
        echo $grid_obj->set_search_filter(true, "");
        echo $grid_obj->enable_paging(50, 'pagingArea_c', 'true');       
        echo $grid_obj->enable_column_move();
        echo $grid_obj->enable_multi_select();
        echo $grid_obj->return_init();
        if (!$read_only_mode)
            echo $grid_obj->attach_event("", "onRowDblClicked", $form_namespace . '.open_update_popup');
        
        if (isset($_POST['call_from']) && ($_POST['call_from'] == 'Run MTM Process')) {
            
        } else {
            echo $grid_obj->attach_event("", "onSelectStateChanged", $form_namespace . '.grid_row_selection');
        }

        echo $layout_obj->close_layout();

        $form_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='" . $function_id . "', @template_name='SetupDeals'";
        $form_data = readXMLURL2($form_sql);
        $form_data_array = array();
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
            <input type="text" id="search-text" class="search-input" placeholder="Search Transactions">
        </div>
    </div>
    <textarea style="display:none" name="deleted_checked" id="deleted_checked">n</textarea>

</body>
<script type="text/javascript">
    setupDeals.filter_form = {};    `
    var blotter_window;
    var update_window;
    var comment_window;`
    var status_window;
    var confirm_window;
    var volume_window;
    var trade_window;
    var read_only_mode = Boolean(<?php echo $read_only_mode; ?>);
     
    $(function() {
        setupDeals.setup_deals.i18n.decimal_separator=".";
        setupDeals.setup_deals.i18n.group_separator=",";
        setupDeals.filter_type_changed();

        $('#filter_toggler').change(function () {
            setupDeals.show_hide_filter();
        });
        $('#hide_filter').change(function () {
            setupDeals.show_hide_filter();
        });

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
            setupDeals.deal_layout.cells("a").setWidth(w * 0.15);
        }
        setupDeals.deal_layout.cells("b").setHeight(h * 0.25);        
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
            case "pdf":
                setupDeals.setup_deals.toPDF(js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                break;
            case "excel":
                setupDeals.setup_deals.toPDF(js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                break;
            case "delete":
                dhtmlx.message({
                    title:"Confirmation",
                    type:"confirm",
                    ok: "Confirm",
                    text: "Are you sure you want to delete selected deal(s)?",
                    callback: function(result) {
                        if (result) {
                            var selected_ids = setupDeals.setup_deals.getColumnValues(0);
                            data = {"action": "spa_source_deal_header", "flag":"x", "deal_ids":selected_ids};
                            adiha_post_data("return_array", data, '', '', 'setupDeals.check_deals');
                        }
                    }
                });
                break;
            case 'calc_position':
                var selected_ids = setupDeals.setup_deals.getColumnValues(0);
                data = {"action": "spa_calc_deal_position_breakdown", "deal_header_ids":selected_ids};
                adiha_post_data("alert", data, '', '');
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
            case 'audit_report':
                setupDeals.open_report('audit');
                break;
            case 'generate_confirmation':
                setupDeals.open_confirmation_report();
                break;
            case 'send_confirmation':
                setupDeals.send_confirmation_report();
                break;
            case 'update_volume':
                setupDeals.open_update_volume();
                break;
            case 'schedule_deal':
                setupDeals.open_schedule_deal();
                break;
            case 'trade_ticket':
                setupDeals.open_trade_ticket();
                break;
            case 'ok':
                var selected_rows = setupDeals.setup_deals.getSelectedRowId();
                
                if (selected_rows == null) {
                    dhtmlx.message({
                        title:'Error',
                        type:"alert-error",
                        text:"Please select deals."
                    });
                    return;
                }
                setupDeals.return_selected_deals();
                break;
            case 'select_unselect':
                var grid_selected_rows = setupDeals.setup_deals.getSelectedRowId();
                
                if (grid_selected_rows == null) {
                    setupDeals.setup_deals.selectAll();
                } else {
                    setupDeals.setup_deals.clearSelection();
                }
                
                break;
            
            default:
                dhtmlx.message({
                    title:'Error',
                    type:"alert-error",
                    text:"Under Maintainence! We will be back soon!"
                });
                break;
        }
    }

    /**
    * Return selected deals to parent page for further processing.
    **/
    setupDeals.return_selected_deals = function() {
        var grid_obj = setupDeals.setup_deals;
        var selected_rows = grid_obj.getSelectedRowId();
        var arr_selected_rows = selected_rows.split(',');
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
                    grid_data_array.push(grid_obj.cells2(row_id, col_index).getValue()); //capture cell value
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
	
    /**
     * [open_blotter Opens blotter window]
     */
    setupDeals.open_blotter = function() {
        setupDeals.unload_deals_window();
        var sub_book_ids = setupDeals.get_subbook();
        if (sub_book_ids.indexOf(',') != -1) {
            sub_book_ids = '';
        }
        if (!blotter_window) {
            blotter_window = new dhtmlXWindows();
        }

        var new_blotter = blotter_window.createWindow('w1', 0, 0, 400, 400);
        new_blotter.setText(get_locale_value("Deal Blotter"));
        new_blotter.centerOnScreen();
        new_blotter.setModal(true);
        new_blotter.maximize();
        new_blotter.attachURL('deal.blotter.php', false, {sub_book:sub_book_ids});

        new_blotter.attachEvent("onClose", function(win){                         
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
                    var form_index = "filter_form_" + id;
                    setupDeals.filter_form[form_index] = tab.attachForm();
                    setupDeals.filter_form[form_index].loadStruct(form_json[i]);
                    i++;

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
                    } else if (tab_text == 'Attributes') {
                        form_obj.attachEvent("onChange", function (name, value){ 
                            if (name == 'source_deal_header_id_from' || name == 'source_deal_header_id_to') {
                                from_value = form_obj.getItemValue("source_deal_header_id_from");
                                to_value = form_obj.getItemValue("source_deal_header_id_to");
                                from_label = form_obj.getItemLabel("source_deal_header_id_from");
                                to_label = form_obj.getItemLabel("source_deal_header_id_to");

                                if (from_value != '' && to_value != '' && from_value > to_value) {
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
                    } else if (tab_text == 'Status') {
						var confirm_status_type = '<?php echo $confirm_status_type; ?>';
						if (confirm_status_type != '') {
							var confirm_status_type_combo = form_obj.getCombo('confirm_status_type');
							var index = confirm_status_type_combo.getIndexByValue(confirm_status_type);
							confirm_status_type_combo.setChecked(index, true);
							form_obj.setItemValue("confirm_status_type", confirm_status_type);
						}
					}
                });
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
            title:"Error",
            type:"alert-error",
            text:message,
            callback: function(result){                
                form_obj.setItemValue(name, min_max_val);
            }
        });
    }

    /**
     * [refresh_grid Refresh Grid]
     */
    setupDeals.refresh_grid = function() {
        setupDeals.deal_layout.cells("c").progressOn();
        var sub_books = setupDeals.get_subbook();
        var filter_mode = ($('#filter_toggler').prop('checked')) ? 'a' : 'g';
        var xml = '<Root><FormXML filter_mode="' + filter_mode + '"';

        if (sub_books == '') {
            dhtmlx.alert({
                type: "alert",
                title:'Alert',
                text:"Please select at least one Subsidiary or Strategy or Book or Sub Book."
            });
            setupDeals.deal_layout.cells("c").progressOff();
            return;
        } else {
            xml += ' sub_book_ids="' + sub_books + '"';
        }        

        if (filter_mode == 'g') {
            var search_text = $("#search-text").val()
            xml += ' search_text="' + search_text + '"';
        } else {
            setupDeals.tab_object.forEachTab(function(tab){
                var id = tab.getId();
                var form_object = setupDeals.filter_form["filter_form_" + id];
                form_data = form_object.getFormData();
                var filter_param = '';
                for (var label in form_data) {
                    //if (form_data[label] != '' && form_data[label] != null) {
                        if (form_object.getItemType(label) == 'calendar') {
                            value = form_object.getItemValue(label, true);
                        } else {
                            value = form_data[label];
                        }
                        xml += ' ' + label + '="' + value + '"';
                    //}
                }
            });
        }
        //Default is null. 400 for Hedge deals, 401 for Item deals.
        var trans_type = '<?php echo $trans_type; ?>';
        xml += '></FormXML></Root>';
        
        xml = escapeXML(xml);
        var sql_param = {
            "action":"spa_source_deal_header",
            "flag":"s",
            "filter_xml": xml,
            "trans_type": trans_type,
            "grid_type":"g"
        };

        sql_param = $.param(sql_param); 
        setupDeals.setup_deals.enableHeaderMenu();
        setupDeals.setup_deals.clearAll();
        setupDeals.setup_deals.post(js_data_collector_url, sql_param, function(){
            $('#hide_filter').prop('checked', false);
            setupDeals.show_hide_filter();
            
            if (!read_only_mode) {                
                setupDeals.grid_row_selection(null);
            }
            setupDeals.deal_layout.cells("c").progressOff();
        });
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
        deal_id = setupDeals.setup_deals.cells(row_id, 0).getValue();
        var win_id = 'w_' + deal_id;
        var new_update_window = update_window.createWindow(win_id, 0, 0, 400, 400);
        new_update_window.setText("Deal - " + deal_id);
        new_update_window.centerOnScreen();
        //new_update_window.setModal(true);
        new_update_window.maximize();
        var param = {deal_id:deal_id,view_deleted:deleted_checked};
        new_update_window.attachURL('deal.detail.php', false, param);

        new_update_window.addUserButton("undock", 0, "Undock", "Undock");

        new_update_window.attachEvent("onClose", function(win){                         
            setupDeals.refresh_grid();
            return true;
        })

        url = app_form_path + '_deal_capture/maintain_deals/deal.detail.php';
        new_update_window.button("undock").attachEvent("onClick", function(){
            open_window(url, param);
        });
    }

    /**
     * [grid_row_selection Grid rows select/unselect event function]
     * @param  {[string]} row_ids [row ids]
     */
    setupDeals.grid_row_selection = function(row_ids) {
        var deleted_checked = $('textarea[name="deleted_checked"]').val();

        var has_rights_deal_edit = Boolean('<?php echo $has_rights_deal_edit; ?>');
        var has_delete_rights = Boolean('<?php echo $has_rights_deal_delete; ?>');
        var has_rights_change_deal_status = Boolean('<?php echo $has_rights_change_deal_status; ?>');
        var has_rights_change_confirm_status = Boolean('<?php echo $has_rights_change_confirm_status; ?>');
        var has_rights_lock_deals = Boolean('<?php echo $has_rights_lock_deals; ?>');
        var has_rights_unlock_deals = Boolean('<?php echo $has_rights_unlock_deals; ?>');
        var has_rights_view_audit_report = Boolean('<?php echo $has_rights_view_audit_report; ?>');
        var has_rights_update_volume = Boolean('<?php echo $has_rights_update_volume; ?>');
        //var has_rights_schedule_deal = Boolean('<?php echo $has_rights_schedule_deal; ?>');

        if (row_ids != null && deleted_checked == 'n') {
            if (has_delete_rights) setupDeals.deal_menu.setItemEnabled('delete');
            if (has_rights_change_deal_status) setupDeals.deal_menu.setItemEnabled('deal_status');
            if (has_rights_lock_deals) setupDeals.deal_menu.setItemEnabled('lock');
            if (has_rights_unlock_deals) setupDeals.deal_menu.setItemEnabled('unlock');
            if (has_rights_view_audit_report) setupDeals.deal_menu.setItemEnabled('audit_report');
            if (has_rights_change_confirm_status) setupDeals.deal_menu.setItemEnabled('confirm_status');
            if (has_rights_deal_edit) setupDeals.deal_menu.setItemEnabled('calc_position');
            setupDeals.deal_menu.setItemEnabled('generate_confirmation');
            setupDeals.deal_menu.setItemEnabled('trade_ticket');
            if (has_rights_update_volume) setupDeals.deal_menu.setItemEnabled('update_volume');
            //if (has_rights_schedule_deal) setupDeals.deal_menu.setItemEnabled('schedule_deal');
            
            if (row_ids.indexOf(",") == -1) {
                setupDeals.deal_menu.setItemEnabled('position_report');
                setupDeals.deal_menu.setItemEnabled('generate_confirmation');
            } else {
                //setupDeals.deal_menu.setItemDisabled('position_report');
				setupDeals.deal_menu.setItemDisabled('generate_confirmation');
            }
        } else {
            setupDeals.deal_menu.setItemDisabled('delete');
            setupDeals.deal_menu.setItemDisabled('deal_status');
            setupDeals.deal_menu.setItemDisabled('confirm_status');
            setupDeals.deal_menu.setItemDisabled('lock');
            setupDeals.deal_menu.setItemDisabled('unlock');
            setupDeals.deal_menu.setItemDisabled('audit_report');
            setupDeals.deal_menu.setItemDisabled('calc_position');
            setupDeals.deal_menu.setItemDisabled('position_report');
            setupDeals.deal_menu.setItemDisabled('generate_confirmation');
            setupDeals.deal_menu.setItemDisabled('update_volume');
            //setupDeals.deal_menu.setItemDisabled('schedule_deal');

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

        if (return_value[0][3] != '' && return_value[0][3] != null) {
            setupDeals.delete_failed(return_value[0][3]);
            return;
        }
        
        if (return_value[0][2] != '' && return_value[0][2] != null) {
            dhtmlx.message({
                title:"Confirmation",
                type:"confirm",
                ok: "Confirm",
                text: return_value[0][2],
                callback: function(result) {
                    if (result) {
                        setupDeals.open_comment_window(return_value[0][0]);
                    } else {
                        return;
                    }
                }
            });
        } else {
            setupDeals.open_comment_window(return_value[0][0]);
        }
    }

    /**
     * [open_comment_window Open comment window to insert comment for deleting deals]
     * @param  {[char]} comment [Comment required]
     * @return {[type]}         [description]
     */
    setupDeals.open_comment_window = function(comment_required) {
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
            win.attachURL('deal.delete.comment.php', false, true);

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
        dhtmlx.alert({
            title:"Error",
            type:"alert-error",
            text:message
        });
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
        dhtmlx.message({
            title:"Confirmation",
            type:"confirm",
            ok: "Confirm",
            text: "Are you sure you want to " + status_name + " selected deal(s)?",
            callback: function(result) {
                if (result) {
                    var selected_ids = setupDeals.setup_deals.getColumnValues(0);
                    data = {"action": "spa_source_deal_header", "flag":"l", "lock_unlock":status, "deal_ids":selected_ids};
                    adiha_post_data("alert", data, '', '', 'setupDeals.refresh_grid');
                }
            }
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
        
        data = {"action": "spa_confirm_status", "flag":"c", "source_deal_header_id":selected_ids};
        adiha_post_data("return_array", data, '', '', 'open_confirmation_report_callback');
    }
    
    open_confirmation_report_callback = function(return_value){
        if (return_value[0][0] == 'Success') {
            window.open(return_value[0][1], '_blank');
        } else {
            setupDeals.unload_deals_window();
            if (!confirm_window) {
                confirm_window = new dhtmlXWindows();
            }
            var selected_ids = setupDeals.setup_deals.getColumnValues(0);
            var win_title = 'Generate Confirmation';
            var win_url = 'generate.confirmation.php';

            var win = confirm_window.createWindow('w1', 0, 0, 400, 400);
            win.setText(win_title);
            win.centerOnScreen();
            win.setModal(true);
            win.maximize();

            win.attachURL(win_url, false, {deal_ids:selected_ids});
        }
    }

    /**
     * [open_trade_ticket Open Trade Ticket]
     */
    setupDeals.open_trade_ticket = function() {
        setupDeals.unload_deals_window();
        if (!trade_window) {
            trade_window = new dhtmlXWindows();
        }
        var selected_ids = setupDeals.setup_deals.getColumnValues(0);
        var win_title = 'Run Trade Ticket';
        var win_url = 'trade.ticket.php';

        var win = trade_window.createWindow('w1', 0, 0, 500, 500);
        win.setText(win_title);
        win.centerOnScreen();
        win.setModal(true);
        win.maximize();
        
        win.attachURL(win_url, false, {deal_ids:selected_ids});
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
        var term_start = setupDeals.setup_deals.getColumnValues(9);
        term_start = dates.convert_to_sql(term_start);
        var win_title = 'Update Volume';
        var win_url = 'update.demand.volume.php';

        var win = volume_window.createWindow('w1', 0, 0, 400, 400);
        win.setText(win_title);
        win.centerOnScreen();
        win.setModal(true);
        win.maximize();

        win.attachURL(win_url, false, {deal_ref_ids:selected_ids,term_start:term_start});
    }
    
    setupDeals.open_update_volume_post = function(return_value) { 
        if (return_value[0][0] == 'Success') {
            var win_title = 'Update Volume';
            var win_url = 'update.demand.shaped.volume.php';
            var selected_ids = setupDeals.setup_deals.getColumnValues(0);
            var win = volume_window.createWindow('w1', 0, 0, 400, 400);
            
            win.setText(win_title);
            win.centerOnScreen();
            win.setModal(true);
            win.maximize();
            win.attachURL(win_url, false, {deal_ref_ids:selected_ids, profile_type:return_value[0][5]});
        } else  {
            profile_type_mismatch(return_value[0][4]);
            return;
        }                
    } 
    
    /**
     * [profile_type_mismatch Display msg for mismatch deals profile type]
     * @param  {[string]} message [Failed message]
     */
    setupDeals.profile_type_mismatch = function(message) {
        dhtmlx.alert({
            title:"Error",
            type:"alert-error",
            text:message
        });
    }
    
    /**
     * [open_schedule_deal Schedule Deal]
     */
    setupDeals.open_schedule_deal = function() {
        var row_id = setupDeals.setup_deals.getSelectedRowId();
        
        if(row_id.indexOf(',') > -1) {
            dhtmlx.alert({
                title: 'Error',
                type: 'alert-error',
                text: 'Please select one record to process.'
            });
            return;
        }
        setupDeals.unload_deals_window();
        if (!volume_window) {
            volume_window = new dhtmlXWindows();
        }
        var selected_ids = setupDeals.setup_deals.getColumnValues(0);
        var win_title = 'Schedule Deal';
        var win_url = 'schedule.deal.php';
        
        var param = {};
        var cols = new Array();
        setupDeals.setup_deals.forEachCell(0, function(cell_obj, ind) {
            cols.push(setupDeals.setup_deals.getColumnId(ind));
        })
        
        param.volume = setupDeals.setup_deals.cells(row_id, setupDeals.setup_deals.getColIndexById('deal_volume')).getValue();
        param.location_id = setupDeals.setup_deals.cells(row_id, setupDeals.setup_deals.getColIndexById('location_index')).getValue();
        param.counterparty_id = setupDeals.setup_deals.cells(row_id, setupDeals.setup_deals.getColIndexById('counterparty')).getValue();
        
        param.term = dates.convert_to_sql(setupDeals.setup_deals.cells(row_id, setupDeals.setup_deals.getColIndexById('term_start')).getValue());
        param.term_end = dates.convert_to_sql(setupDeals.setup_deals.cells(row_id, setupDeals.setup_deals.getColIndexById('term_end')).getValue());
        param.source_deal_header_id = selected_ids;
        param.group_by = 'Deal';
        
        
        win_url += '?term=' + param.term + '&term_end=' + param.term_end + '&group_by=' + param.group_by + '&source_deal_header_id=' + selected_ids;
        var win = volume_window.createWindow('w1', 0, 0, 400, 400);
        win.setText(win_title);
        win.centerOnScreen();
        win.setModal(true);
        //win.addUserButton("reload", 0, "Reload", "Reload");
        win.maximize();
        
        win.attachURL(win_url, null);
    }
    /*
    Function to open detail report for under schedule [deal schedule]
    */
    function sch_under_over_detail_report(warning_type, process_id) {
        var report_name = 'Schedule Detail Report';
        var exec_call = "EXEC spa_view_validation_log 'schedule_detail','" + process_id + "', 's'";
        open_spa_html_window(report_name, exec_call, 500, 1150);
    }
	
	/**
     * [send_confirmation_report Send/Download Confirmation Report]
     */
    setupDeals.send_confirmation_report = function() {
        var selected_ids = setupDeals.setup_deals.getColumnValues(0);
		var user_name = getAppUserName();
        var user_name_array = user_name.split("=");
        user_name = user_name_array[1];

        var report_name = 'Deal Confirm Report Template';
        var reporting_param = construct_report_export_cmd(report_name, report_name);
        var report_file_path = '<?php echo addslashes(addslashes($ssrs_config['EXPORTED_REPORT_DIR_INITIAL']))?>/' + 'Deal Confirm Report Template.pdf';
        var report_folder = '<?php echo $ssrs_config['REPORT_TARGET_FOLDER']; ?>' + '/custom_reports/';

        var title = "Send Confirmation";
		
		var param = 'source=confirmation_Process&gen_as_of_date=1&batch_type=v&call_from=confirmation'
									+ '&source_deal_header_id=' + selected_ids
									+ '&reporting_param=' + reporting_param
									+ '&report_file_path=' + report_file_path
									+ '&report_folder=' + report_folder
		var exec_call = "";
		adiha_run_batch_process(exec_call, param, title);
    }
	
	function construct_report_export_cmd(output_file, report_path) {
        output_file = '\\\\' + output_file;
        var cmd_call = '<?php
                        $report_export_cmd  = "rs";
                        $report_export_cmd .= " -e Exec2005";
                        $report_export_cmd .= " -l " . $ssrs_config['RS_TIMEOUT'];
                        $report_export_cmd .= " -s " . $ssrs_config['SERVICE_URL'];
                        $report_export_cmd .= ' -i "' . addslashes(addslashes($ssrs_config['REPORT_EXPORTER_PATH_CUSTOM'])) . '"';
                        $report_export_cmd .= ' -v vFullPathOfOutputFile="' . addslashes(addslashes($ssrs_config['EXPORTED_REPORT_DIR_INITIAL'])) . '' . "' + output_file + '" .'.pdf"';
                        $report_export_cmd .= ' -v vReportPath="' . $ssrs_config['REPORT_TARGET_FOLDER'] . '/custom_reports/' . "' + report_path + '" .'"';
                        $report_export_cmd .= ' -v vFormat="PDF"';
                        $report_export_cmd .= ' -v vReportFilter=' ;

                        echo $report_export_cmd;
                        ?>';
            return cmd_call;
    }
	
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
        content: "Text Search";
        padding-left: 10px;
        background-color: #34A7C1; color: #FFFFFF;
    }
    .onoffswitch-inner:after {
        content: "Advance Filters";
        padding-right: 10px;
        background-color: #EEEEEE; color: #999999;
        text-align: right;
    }

    .hide-filter-inner:before {
        content: "Hide Filters";
        padding-left: 10px;
        background-color: #34A7C1; color: #FFFFFF;
    }
    .hide-filter-inner:after {
        content: "Show Filter";
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