<?php
/**
* Actualize schedules screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <?php include '../../../adiha.php.scripts/components/include.file.v3.php';?>
 
</head>
<?php
    $php_script_loc = $app_php_script_loc;
    $form_namespace = 'ticket';
    $form_name = 'filters';
    $toolbar_match_name = 'toolbar_match';
    $menu_ticket_name = 'menu_ticket';
    $layout_name = 'ticket_layout';
    $inner_layout_name = 'layout_ticket_match';
    $toolbar_ticket_match_name = 'toolbar_ticket_match';
    $ticket_grid_name = 'ticket';

    $rights_actualize_schedule = 10166500;
    $rights_actualize_schedule_UI = 10166510;
    $rights_actualize_delete = 10166511;
    $rights_ticket_UI = 10166610;
    $rights_ticket_delete = 10166611;

    $rights_actualize_schedule_schedules_save = 10166513;
    $rights_actualize_schedule_schedules_unmatch = 10166514;

    list (
        $has_rights_actualize_schedule,
        $has_rights_actualize_schedule_UI,
        $has_rights_actualize_delete,
        $has_rights_ticket_UI,
        $has_rights_ticket_delete,
        $has_rights_actualize_schedule_schedules_save,
        $has_rights_actualize_schedule_schedules_unmatch
    ) = build_security_rights (
        $rights_actualize_schedule,
        $rights_actualize_schedule_UI,
        $rights_actualize_delete,
        $rights_ticket_UI,
        $rights_ticket_delete,
        $rights_actualize_schedule_schedules_save,
        $rights_actualize_schedule_schedules_unmatch
    );

    $has_rights_actualize_schedule = ($has_rights_actualize_schedule != 1) ? "false" : "true";
    $has_rights_actualize_schedule_UI = ($has_rights_actualize_schedule_UI != 1) ? "false"  : "true";
    $has_rights_actualize_delete = ($has_rights_actualize_delete != 1) ? "false"  : "true";
    $has_rights_ticket_UI = ($has_rights_ticket_UI != 1) ? "false"  : "true";
    $has_rights_ticket_delete = ($has_rights_ticket_delete != 1) ? "false"  :"true";
    $has_rights_actualize_schedule_schedules_save = ($has_rights_actualize_schedule_schedules_save != 1) ? "false"  : "true";
    $has_rights_actualize_schedule_schedules_unmatch = ($has_rights_actualize_schedule_schedules_unmatch != 1) ? "false"  :"true";


   $layout_json = '[
                        {id: "a", text: "Apply Filter", header: true, collapse:true, height:80},
                        {id: "b", text: "Filter Criteria", header: true, height:210, collapse: false},
                        {id: "c", text: "Ticket/Match", header: true}
                    ]';
    $filter_criteria_tab = '[
                                {id: "a1", text: "Filters", active: true},
                                {id: "a2", text: "Commodity"}
                            ]';
    $layout_json_ticket_match = '[
                        {id: "a", text: "Tickets", header: true},
                        {id: "b", text: "Schedules", header: true}
                    ]';
    $ticket_match_toolbar_json = '[
                                    {id:"refresh", type:"button", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif", title: "Refresh"}
                                ]';

    $matching_json = '[
                        {id:"save",  img:"save.gif", imgdis:"save_dis.gif", text:"Save", title:"Save", enabled: ' . $has_rights_actualize_schedule_schedules_save . '},
                            {id:"unmatch", text:"Unactualize", img:"unmatch.gif", imgdis:"unmatch_dis.gif", title: "Unactualize", enabled: ' . $has_rights_actualize_schedule_schedules_unmatch . '},
                            {id:"complete", text:"Complete", img:"tick.png", imgdis:"tick_dis.png", title: "Complete", enabled: ' . $has_rights_actualize_schedule_schedules_unmatch . '}
                        ]';

    $ticket_json = '[
                            {id:"edit", text:"Edit", img:"edit.gif", items:[
                            {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add", enabled: ' . $has_rights_actualize_schedule_UI . '},
                            {id:"copy", text:"Copy", img:"copy.gif", imgdis:"copy_dis.gif", title: "Copy", enabled:false},
                            {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete", enabled:false}
                            ]},
                            {id:"export", text:"Export", img:"export.gif", items:[
                                {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                                {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                            ]}
                    ]';

    $context_menu_json = '[{id:"add", text:"Actualize with new Ticket", img:"new.gif", imgdis:"new_dis.gif", title: "Actualize with new Ticket", enabled:' . $has_rights_actualize_schedule . '}]';

    $xml_file = "EXEC spa_adiha_grid 's','MatchGroupDetail'";
    $resultset_detail = readXMLURL2($xml_file);
    $sub_grid_detail_json = json_encode($resultset_detail);

    $layout_obj = new AdihaLayout();
    $inner_layout_obj = new AdihaLayout();
    $form_obj = new AdihaForm();
    $menu_match_obj = new AdihaMenu();
    $menu_ticket_obj = new AdihaMenu();
    $context_menu = new AdihaMenu();
    $toolbar_obj = new AdihaToolbar();
    $tab_obj = new AdihaTab();

    $ticket_grid_obj = new GridTable($ticket_grid_name);
    echo $layout_obj->init_layout($layout_name, '', '3E', $layout_json, $form_namespace);

    //attach tabs on cell b
    $tab_name = 'filter_criteria_tab';
    echo $layout_obj->attach_tab_cell($tab_name, 'b', $filter_criteria_tab);
    
    //form in tab a1
    $filter_sql = "EXEC spa_create_application_ui_json  @flag='j', 
                                                        @application_function_id='" . $rights_actualize_schedule . "',
                                                        @template_name='actualize_schedule',
                                                        @group_name='Filters,Commodity Filters'";

    $filter_arr = readXMLURL2($filter_sql);
    $form_json = $filter_arr[0]['form_json'];
    echo $tab_obj->attach_form_new($tab_name, $form_name, 'a1', $form_json, $form_namespace, $filter_arr[0]['dependent_combo']);
        
    $commodity_json = $filter_arr[1]['form_json'];
    echo $tab_obj->attach_form_new($tab_name, 'commodity_form', 'a2', $commodity_json, $form_namespace, $filter_arr[1]['dependent_combo']);
  
    echo $layout_obj->attach_toolbar_cell($toolbar_ticket_match_name, "c");
    echo $toolbar_obj->init_by_attach($toolbar_ticket_match_name, $form_namespace);
    echo $toolbar_obj->load_toolbar($ticket_match_toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', 'toolbar_ticket_menu_click');

    echo $layout_obj->attach_layout_cell($inner_layout_name, 'c', '2U', $layout_json_ticket_match);
    echo $inner_layout_obj->init_by_attach($inner_layout_name, $form_namespace);

    echo $menu_ticket_obj->attach_menu_layout_header($form_namespace, $inner_layout_name, 'a', $menu_ticket_name, $ticket_json, 'menu_ticket_click');

    //echo $context_menu->init_menu('context_menu', $form_namespace);
   // echo $context_menu->render_as_context_menu();
    //echo $context_menu->attach_event('', 'onClick', 'context_menu_match_click');
    //echo $context_menu->load_menu($context_menu_json);

    echo $inner_layout_obj->attach_grid_cell($ticket_grid_name, 'a');
    echo $inner_layout_obj->attach_status_bar("a", true);
    echo $ticket_grid_obj->init_grid_table($ticket_grid_name, $form_namespace);
    echo $ticket_grid_obj->set_column_auto_size();
    echo $ticket_grid_obj->set_search_filter(true, "");
    echo $ticket_grid_obj->enable_column_move();
    echo $ticket_grid_obj->enable_multi_select();
    // echo $ticket_grid_obj->split_grid('1');
    echo $ticket_grid_obj->return_init();
    echo $ticket_grid_obj->enable_paging(50, 'pagingArea_a', true);
    echo $ticket_grid_obj->enable_header_menu();
    echo $ticket_grid_obj->enable_filter_auto_hide();
    //echo $ticket_grid_obj->load_grid_data();
    echo $ticket_grid_obj->enable_DND(true);
    echo $ticket_grid_obj->attach_event('', 'onDrag', 'ticket_drag');
    echo $ticket_grid_obj->attach_event('', 'onRowDblClicked', 'open_window_ticket_update');
    //echo $ticket_grid_obj->attach_event('', 'onBeforeDrag', 'enable_ticket_drag');
    echo $ticket_grid_obj->attach_event('', 'onRowSelect', 'ticket_grid_click');

    echo $menu_match_obj->attach_menu_layout_header($form_namespace, $inner_layout_name, 'b', $toolbar_match_name, $matching_json, 'on_matching_click');

    echo $inner_layout_obj->close_layout();
    echo $layout_obj->close_layout();
?>
<script>
    var selected_match_id;
    var message_shown = false;
    var function_id = <?php echo $rights_actualize_schedule;?>;
    var has_rights_ticket_delete = <?php echo $has_rights_ticket_delete;?>;
    var rights_actualize_schedule = <?php echo $rights_actualize_schedule;?>;
    var has_rights_actualize_delete = <?php echo $rights_actualize_delete;?>; 
    var combo_names = '<?php echo $filter_arr[1]['dependent_combo'];?>';
    //alert(combo_names);
    var sub_grid_detail_json  = <?php echo $sub_grid_detail_json; ?>;

    $(function() {   
        var filter_obj = ticket.ticket_layout.cells("a").attachForm();
        var layout_b_obj = ticket.ticket_layout.cells("b"); 
        ticket.ticket.enableMultiselect(false);       
        load_form_filter(filter_obj, layout_b_obj, function_id, 2);
        create_match_grid();
        load_default_filter();
        attach_edit_event();   
        ticket.cmb_location_pre_populate();
        ticket.cmb_commodity_pre_populate();
        attach_browse_event('ticket.filters', 10166500, '', 'n'); 

        // added additional attribute in form to load dependent child combo without selecting parent combo value
        ticket.filters['load_child_without_selecting_parent'] = 1;
    });

    function on_change_combos(name, value){
        toolbar_ticket_menu_click('refresh');
        var attached_obj = ticket.layout_ticket_match.cells('a').getAttachedObject();
        //attached_obj.insertColumn(6, 'New Column','ro',120,'na','left','top',null,'red');
    }

    function attach_edit_event() {        
        var quantity_uom_combo = ticket.filters.getCombo('quantity_uom');
        quantity_uom_combo.attachEvent("onChange", on_change_combos);

        var frequency_combo = ticket.filters.getCombo('frequency');
        frequency_combo.attachEvent("onChange", on_change_combos);

        ticket.filters.attachEvent("onChange", function (value) {        
            if (value == 'period_from') {
                var period_from =  ticket.filters.getItemValue('period_from', true); 
                var date = new Date(period_from + 'T12:00:00');
                ticket.filters.setItemValue('period_to', new Date(date.getFullYear(), date.getMonth() + 1, 0));
            }
            if (value == 'quantity_uom' || 'frequency') {
                on_change_combos;
            }
        });
    }
    

    ticket.cmb_location_pre_populate = function() {
        var cm_param = {
            'action': 'spa_source_minor_location',
            'flag': 'f',
            'source_major_location_ID':'NULL'
        };
        
        cm_param = $.param(cm_param);
        var url = js_dropdown_connector_url + '&' + cm_param;

        url = decodeURIComponent(url);

        var cm_data = ticket.filters.getCombo('location');
        cm_data.clearAll();
        cm_data.setComboText('');
        cm_data.load(url, function(e) {
            
        });   
    }
    
    /**
    * [load commodity]
    */
    ticket.cmb_commodity_pre_populate = function() {        
        var cm_param = {
                    'action': 'spa_source_commodity_maintain',
                    'has_blank_option': 'false',
                    'flag': 'z',
                    'commodity_group':'NULL'
                };
                       
        cm_param = $.param(cm_param);
        var url = js_dropdown_connector_url + '&' + cm_param;
        url = decodeURIComponent(url);
        var cm_data = ticket.commodity_form.getCombo('commodity_id');
    
        cm_data.clearAll();
        cm_data.setComboText('');
        cm_data.load(url, function(e) {
          
        });
    }


    function ticket_drag() {
        return false;
    }

    function load_default_filter () {
        var date = new Date();
        //ticket.filters.setItemValue('period_from', new Date(date.getFullYear(), date.getMonth(), 1));
        //ticket.filters.setItemValue('period_to', new Date(date.getFullYear(), date.getMonth() + 1, 0));
        //ticket.filters.setItemValue('quantity_uom', ticket.filters.getCombo('quantity_uom').getOptionByLabel('lbs.')['value']);
        refresh_all_grid();
    }

    function create_match_grid () {
        ticket.layout_ticket_match.cells('b').attachStatusBar({
            height: 30,
            text: '<div id="pagingAreaGrid_b"></div>'
        });

        ticket.actualize_schedule = ticket.layout_ticket_match.cells('b').attachGrid();
        ticket.actualize_schedule.setImagePath(js_image_path + "dhxgrid_web/");
        ticket.actualize_schedule.setHeader(get_locale_value('&nbsp,Match ID,Shipment,Location,Commodity,Term Start,Term End,Line Up,Contractual Volume,Scheduled Volume,Price,UOM,Finalized,Location ID,Match Group ID, Create User',true));
        ticket.actualize_schedule.setColTypes('sub_row_grid,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro');            
        ticket.actualize_schedule.setColumnIds('match_group_header_id,bookout_id_show,Location_Name,commodity_name,term_start,term_end,lineup,deal_volume,bookout_amt,fixed_price,uom_name,is_finalize,location_id,shipment_name,match_group_id, create_user');
        ticket.actualize_schedule.setInitWidths('30,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200');
        ticket.actualize_schedule.attachHeader("&nbsp,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter");         

        ticket.actualize_schedule.init();
        ticket.actualize_schedule.enableMultiselect(true);

        ticket.actualize_schedule.setPagingWTMode(true, true, true, true);
        ticket.actualize_schedule.enablePaging(true, 10, 0, 'pagingAreaGrid_b');
        ticket.actualize_schedule.setPagingSkin('toolbar');

        ticket.actualize_schedule.enableContextMenu(ticket.context_menu);

        ticket.actualize_schedule.setStyle(
            "", "background-color:#EAF5CA;", "", ""
        );

        ticket.actualize_schedule.enableDragAndDrop(true);
        ticket.actualize_schedule.attachEvent("onDrop", add_ticket);
        ticket.actualize_schedule.attachEvent("onRowAdded", function (rId) {
             ticket.actualize_schedule.deleteRow(rId);
        });

        ticket.actualize_schedule.enableMercyDrag(false);
        ticket.actualize_schedule.attachEvent('onRowDblClicked', open_window_match);
        ticket.actualize_schedule.attachEvent("onPageChanged", init_subgrid);
        ticket.actualize_schedule.setColumnHidden(ticket.actualize_schedule.getColIndexById('location_id'),true);

        ticket.actualize_schedule.callEvent("onGridReconstructed", []);

        ticket.actualize_schedule.enableHeaderMenu();
        ticket.actualize_schedule.enableFilterAutoHide();
        ticket.actualize_schedule.enableColumnMove(true);
        
        var id = get_locale_value('Match Group Detail ID');//to support other language as the value was hardcoded
        var first_sub_grid_set_header = '&nbsp,' + sub_grid_detail_json[0].column_label_list.replace(id +',' , '');
        var first_sub_grid_set_columns = sub_grid_detail_json[0].column_label_list.replace(id +',' , '');
        var first_sub_grid_set_coumn_types = 'sub_row_grid,' + sub_grid_detail_json[0].column_type_list.replace('ro,', '');
        var first_sub_grid_visibility = 'false,' + sub_grid_detail_json[0].set_visibility.replace('true,', '')
        var first_sub_grid_width = '30,' + sub_grid_detail_json[0].column_width.replace('150,', '');

        ticket.actualize_schedule.attachEvent("onSubGridCreated", function(sub_grid_obj1, id, ind) {
            sub_grid_obj1.setImagePath(js_image_path + "dhxgrid_web/");
            sub_grid_obj1.setHeader(first_sub_grid_set_header);
            sub_grid_obj1.setColumnIds(first_sub_grid_set_columns);
            sub_grid_obj1.setColTypes(first_sub_grid_set_coumn_types);
            sub_grid_obj1.setColumnsVisibility(first_sub_grid_visibility);
            sub_grid_obj1.setInitWidths(first_sub_grid_width);
            sub_grid_obj1.setStyle('','background-color:#FFFFCC','','background-color:#e3e378 !important');
            sub_grid_obj1.init();
            sub_grid_obj1.enableHeaderMenu();
            sub_grid_obj1.attachEvent('onRowSelect', function (rid,cid) {ticket.actualize_schedule.clearSelection();});
            // sub_grid_obj1.objBox.style.overflow = 'visible';
        
            sub_grid_obj1.setStyle(
                "", "background-color:#dbf2a2;", "", ""
            );
            sub_grid_obj1.setDragBehavior('sibling');
            sub_grid_obj1.enableDragAndDrop(true);
            sub_grid_obj1.attachEvent("onDrop", add_ticket);
            sub_grid_obj1.callEvent("onGridReconstructed", []);
            sub_grid_obj1.enableMercyDrag(false);
            sub_grid_obj1.setColumnHidden(1, false);
            sub_grid_obj1.setColWidth(1, "150");
            sub_grid_obj1.attachEvent("onRowAdded", function (rId) {
                 sub_grid_obj1.deleteRow(rId);
            });

            sub_grid_obj1.attachEvent('onSubGridCreated', function (actualize_schedule_sub_grid, id1, ind1) {
            actualize_schedule_sub_grid.setImagePath(js_image_path + "dhxgrid_web/");
            actualize_schedule_sub_grid.setHeader(get_locale_value("ID, Ticket Detail ID,Ticket Number,Line Item,Ticket Issuer,Movement Date/Time,Issue Date,Movement Location,Commodity,Gross Volume,Net Volume,Volume UOM,Ticket Type,Match ID,Origin,Destination,Term Start,Term End",true));
            actualize_schedule_sub_grid.setColumnIds("ticket_header_id,ticket_detail_id,ticket_number,line_item,ticket_issuer,movement_date_time,date_issued,Location_Name,commodity_name,gross_volume,net_volume,volume_uom,ticket_type,match_id,origin,destination,term_start,term_end");
            actualize_schedule_sub_grid.setColTypes("ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ed,ed,ro,ro,ro,ro,ro,ro");
            actualize_schedule_sub_grid.setColumnHidden(actualize_schedule_sub_grid.getColIndexById('ticket_header_id'), true);
            actualize_schedule_sub_grid.setColumnHidden(actualize_schedule_sub_grid.getColIndexById('ticket_detail_id'), true);
            actualize_schedule_sub_grid.setColumnHidden(actualize_schedule_sub_grid.getColIndexById('match_id'), true);
            actualize_schedule_sub_grid.setColumnHidden(actualize_schedule_sub_grid.getColIndexById('origin'), true);
            actualize_schedule_sub_grid.setColumnHidden(actualize_schedule_sub_grid.getColIndexById('destination'), true);
            actualize_schedule_sub_grid.setColumnHidden(actualize_schedule_sub_grid.getColIndexById('term_start'), true);
            actualize_schedule_sub_grid.setColumnHidden(actualize_schedule_sub_grid.getColIndexById('term_end'), true);

            actualize_schedule_sub_grid.setInitWidths("160,160,160,160,160,160,160,160,160,160,160,160,160,330,160,160,160,160");
            actualize_schedule_sub_grid.enableDragAndDrop(true);
            actualize_schedule_sub_grid.setDragBehavior('sibling');

            actualize_schedule_sub_grid.init();

            actualize_schedule_sub_grid.setStyle(
                "background-color:#83ACC5 !important;border: 1px outset silver;color:white;", "background-color:#F3F8FD;", "", ""
            );
            actualize_schedule_sub_grid.enableMultiselect(true);
            actualize_schedule_sub_grid.enableHeaderMenu();

            actualize_schedule_sub_grid.attachEvent("onDrop", function(sId,tId,dId,sObj,tObj,sCol,tCol){
                var tickets = sId.split(",");
                for (var i = tickets.length - 1; i >= 0; i--) {
                    sObj.deleteRow(tickets[i]);
                }
                sub_grid_obj1.callEvent('onGridReconstructed', []);
            });

            actualize_schedule_sub_grid.attachEvent('onRowSelect', function (rid,cid) {
                ticket.actualize_schedule.clearSelection();
                sub_grid_obj1.clearSelection();
                });
            actualize_schedule_sub_grid.attachEvent('onBeforeDrag', stop_drag);
            actualize_schedule_sub_grid.attachEvent('onRowDblClicked', function(rId,cInd) { 
                var is_matched = 0;
                var schedule_match_id = actualize_schedule_sub_grid.cells(rId, actualize_schedule_sub_grid.getColIndexById('match_id')).getValue();
                if (schedule_match_id != '') is_matched = 1

                var url = 'ticket.php?mode=u&ticket_id=' + actualize_schedule_sub_grid.cells(rId, actualize_schedule_sub_grid.getColIndexById('ticket_header_id')).getValue() + '&is_matched=' + is_matched + '&schedule_match_id=' + ticket.actualize_schedule.cells(actualize_schedule_sub_grid.getUserData("", "parent_rid"),ticket.actualize_schedule.getColIndexById('match_group_header_id')).getValue();

                open_window_ticket(url);
           });

            var filter_xml = '<Root><FormFilterXML ';
            var form_data = ticket.filters.getFormData();
            var filter_param = '';

            for (var a in form_data) {
                if (form_data[a] != '' && form_data[a] != null) {

                    if (a == 'quantity_uom' || a == 'frequency') {
                        filter_xml +=  a + '="' + form_data[a] + '" ';
                    }
                }
            }

            var match_group_detail_id = sub_grid_obj1.cells(id1, 0).getValue();

            filter_xml += '></FormFilterXML></Root>';
            var param = {
                "action" : "spa_split_deal_actuals",
                "flag" : "o",
                "filter_xml" : filter_xml ,
                "match_group_detail_id" : match_group_detail_id,
                "schedule_match_id" : ticket.actualize_schedule.cells(id, ticket.actualize_schedule.getColIndexById('match_group_header_id')).getValue()
            };

            param = $.param(param);
            var param_url = js_data_collector_url + "&" + param;
            actualize_schedule_sub_grid.clearAll();

            //LOAD GRID DATA
            actualize_schedule_sub_grid.load(param_url, function() {
                actualize_schedule_sub_grid.callEvent("onGridReconstructed", []);
                sub_grid_obj1.callEvent('onGridReconstructed', []);
            });

            sub_grid_obj1.attachEvent("onSubRowOpen", function(id, state) {
                sub_grid_obj1.callEvent('onGridReconstructed', []);
            });

            actualize_schedule_sub_grid.setUserData('', 'parent_rid', id);
            return true;
        });


            var convert_uom = ticket.filters.getItemValue('quantity_uom');
            var match_group_header_col_id = ticket.actualize_schedule.getColIndexById('match_group_header_id');
            var match_group_header_id = ticket.actualize_schedule.cells(id, match_group_header_col_id).getValue();
           
            var param = {
                'action': 'spa_scheduling_workbench',
                'flag': 'z',
                'process_id': new Date().valueOf(),
                'filter_xml' : '',
                'grid_name' : 'MatchGroupDetail',
                'match_group_header_id' : match_group_header_id,
                'call_from': 'actulize',
                'convert_uom' : convert_uom
            };
        
            param = $.param(param);
            
            var param_url = js_data_collector_url + '&' + param;
            sub_grid_obj1.clearAll();
            
            //after finished loading the data, fire sub grid reconstruct event so that the height of the parent grid is maintained when expanded.
            sub_grid_obj1.load(param_url, function() {
                sub_grid_obj1.callEvent('onGridReconstructed', []); 
            });
             
            sub_grid_obj1.setUserData('', 'first_sub_parent_rid', id);
            return true;
        });
    }

    check_match_node = function(sId, tId, sObj, tObj, sInd, tInd) {
       return false;
    }

    function stop_drag() {
        return false;
    }

    function toolbar_ticket_menu_click (id) {
          switch(id) {
            case 'refresh':
                ticket.ticket_layout.cells('b').collapse();
                refresh_all_grid();
            break;
        }
    }

    function refresh_all_grid() {
        message_shown = false;
        ticket.refresh_grid_ticket();
        ticket.refresh_grid_match();
    }

    function add_ticket(sId,tId,dId,sObj,tObj,sCol,tCol) {
        var tickets = sId.split(',');

        if (sObj == tObj) return;

        var show_validation = '';

        var parent_grid_obj = ticket.actualize_schedule;
        var target_id = '';

        if (parent_grid_obj == tObj) {
            parent_grid_obj.cells(tId, 0).open(); 
            target_id = tId;
        } else {
            target_id = tObj.getUserData("", "first_sub_parent_rid");
        }

        var first_sub_grid_obj = parent_grid_obj.cells(target_id, 0).getSubGrid();
         
        //var first_sub_ids = first_sub_grid_obj.getAllRowIds().split(',');     
        var to_update_id = '';
        var second_sub_grid_obj = '';    
        first_sub_grid_obj.forEachRow(function(subrowid) { 
            if ((subrowid == tId && tObj == first_sub_grid_obj) || tObj == parent_grid_obj) {
                first_sub_grid_obj.cells(subrowid, 0).open();                
                    //if (second_sub_grid_obj == '')
                second_sub_grid_obj = first_sub_grid_obj.cells(subrowid, 0).getSubGrid(); 

            tickets.forEach(function(id) {
                sObj.moveRowTo(id, 1, "copy", "sibling", sObj, second_sub_grid_obj);
                ticket.actualize_schedule.setUserData(target_id, 'isModified', '1');
                second_sub_grid_obj.setUserData(id, 'isModified', '1');
                first_sub_grid_obj.callEvent('onGridReconstructed', []);
            });
            }
            
        });        
    }

    function on_matching_click (id) {
        switch(id) {
            case "save":
                save_ticket_matching();
            break;
            case 'unmatch':
                prepare_grid_to_unmatch();
            break;
            case 'complete':
                complete_match_details();
            break;
        }
    }


    function complete_match_details() {
        var parent_grid_obj = ticket.actualize_schedule;
        var sel_ids = parent_grid_obj.getSelectedRowId();
        var match_group_header_id = '';
        sel_ids = sel_ids.split(',');
        sel_ids.forEach(function(id) {
            match_group_header_id = match_group_header_id + parent_grid_obj.cells(id, parent_grid_obj.getColIndexById('match_group_header_id')).getValue() + ',' ;
        });
        match_group_header_id = match_group_header_id.slice(0, -1);  
        var data = {
            'action' : 'spa_scheduling_workbench',
            'flag' : 'complete',
            'match_id' : match_group_header_id
        };
        adiha_post_data('confirm', data, '', '', 'ticket.complete_match_details_callback', '', 'Are you sure to complete ?');
    }

    ticket.complete_match_details_callback = function(return_value) {
        refresh_all_grid();
        //return;
    }
    /**
        *   [prepare_grid_to_unmatch]
        *   @desc {Prepares grid before unmatching}
        *   @param {null}
    */
    function prepare_grid_to_unmatch() {
        ticket.layout_ticket_match.cells('b').progressOn();
        var sub_grid_count = 0;
        var second_sub_grid_obj = [];
        var sel_ids = ticket.actualize_schedule.getSelectedRowId();
        if (sel_ids == null) {
            unmatch_ticket("child");
        } else {
            sel_ids = sel_ids.split(',')
            sel_ids.forEach(function(id) {
                var first_sub_grid_obj = ticket.actualize_schedule.cells(id, 0).getSubGrid();
                first_sub_grid_obj.forEachRow(function(rid) {
                    sub_grid_count += 1;
                    first_sub_grid_obj.cells(rid, 0).open();
                    while (second_sub_grid_obj[rid] == null) {
                        second_sub_grid_obj[rid] = first_sub_grid_obj.cells(rid, 0).getSubGrid();
                    }
                    first_sub_grid_obj.cells(rid, 0).close();
                    if (second_sub_grid_obj[rid] != null) {
                        // Unmatch only after the sub grid is loaded completely and data is loaded on grid.
                        second_sub_grid_obj[rid].attachEvent("onXLE", function() {
                            unmatch_ticket("parent");
                        });
                        ticket.layout_ticket_match.cells('b').progressOff();
                    }
                });
            });
        }
    }

    /**
        *   [unmatch_ticket]
        *   @desc {Unactualize the values from sub grid,
                    when parent is selected then all child are unactualized,
                    when child are selected then they are individually unactualized.
            }
        *   @param {[call_from] 
                type: string,
                possible_values: {parent, child},
                desc: defines if the unactualize is called from parent or from subgrid itself
            }
    */
    function unmatch_ticket(call_from) {
        var parent_grid_obj = ticket.actualize_schedule;
        var parent_selected_row = ''; 
        var detail_selected_row = '';
        var match_group_header_selected = '';
        var match_group_detail_selected = '';
        var first_sub_grid_obj =  '';
        var second_sub_grid_obj = '';  
        var tickets = new Array();

        if (parent_grid_obj.getSelectedRowId() !== null) {
            parent_selected_row = parent_grid_obj.getSelectedRowId().split(',');
        }

        parent_grid_obj.forEachRow(function(id) {
            if (parent_selected_row.indexOf(id) > -1) {
                match_group_header_selected = true;
            } else {
                match_group_header_selected = false;
            }
            
            first_sub_grid_obj = parent_grid_obj.cells(id, 0).getSubGrid();
            
            if (first_sub_grid_obj.getSelectedRowId() !== null) {
                detail_selected_row = first_sub_grid_obj.getSelectedRowId().split(',');
            }
            
            if (first_sub_grid_obj !== null) {
                first_sub_grid_obj.forEachRow(function(first_sub_id) {
                    
                    if (detail_selected_row.indexOf(first_sub_id) > -1) {
                        match_group_detail_selected = true;
                    } else {
                        match_group_detail_selected = false;
                    }
                                        
                    second_sub_grid_obj = first_sub_grid_obj.cells(first_sub_id, 0).getSubGrid(); 
                    
                    if (second_sub_grid_obj !== null) {
                        if (second_sub_grid_obj.getSelectedRowId() !== null || match_group_detail_selected == true || match_group_header_selected == true) {
                            
                            if (second_sub_grid_obj.getSelectedRowId() !== null) {
                                tickets = second_sub_grid_obj.getSelectedRowId().split(',');
                                tickets.forEach(function(ticket_id) {
                                    var search_value = ticket.ticket.findCell(second_sub_grid_obj.cells(ticket_id, second_sub_grid_obj.getColIndexById('ticket_header_id')).getValue(),ticket.ticket.getColIndexById('ticket_header_id'),true);
                                    parent_grid_obj.setUserData(id, 'isModified', '1');
                                    parent_grid_obj.setUserData('', 'isdeleted', '1');
                                    second_sub_grid_obj.setUserData('', 'isModified', '1');
                                    second_sub_grid_obj.deleteRow(ticket_id);
                                });
                            }
                             
                            if (match_group_detail_selected == true || match_group_header_selected == true) {
                                second_sub_grid_obj.forEachRow(function(second_sub_id) {
                                    var search_value = ticket.ticket.findCell(second_sub_grid_obj.cells(second_sub_id, second_sub_grid_obj.getColIndexById('ticket_header_id')).getValue(),ticket.ticket.getColIndexById('ticket_header_id'),true);
                                    parent_grid_obj.setUserData(id, 'isModified', '1');
                                    parent_grid_obj.setUserData('', 'isdeleted', '1');
                                    second_sub_grid_obj.setUserData('', 'isModified', '1');
                                    second_sub_grid_obj.deleteRow(second_sub_id);
                                });
                            }
                        }
                    }                    
                });
            }
        });

        if (ticket.actualize_schedule.getUserData('', 'isdeleted') == '1' && call_from == 'child') {
            success_call('Ticket has been unactualized. Click save button to save the changes.');
            ticket.layout_ticket_match.cells('b').progressOff();
        } else if (ticket.actualize_schedule.getUserData('', 'isdeleted') == '1' && call_from == 'parent' && message_shown == false) {
            message_shown = true;
            success_call('Ticket has been unactualized. Click save button to save the changes.', 'error');
            ticket.layout_ticket_match.cells('b').progressOff();
        } else {
            ticket.layout_ticket_match.cells('b').progressOff();
        }
    }

    function save_ticket_matching() {
        var ticket_matching_xml = '<Root>';
        var is_ticket_deleted = 0;
        var match_group_header_id = '';
        var match_group_detail_id = '';
        var ticket_volume = '';
        var parent_grid_obj = ticket.actualize_schedule;
        var first_sub_grid_obj = '';
        var ticket_id_value  = '';
        var second_sub_grid_obj = '';

        parent_grid_obj.forEachRow(function(id) {            
            if (parent_grid_obj.getUserData(id, 'isModified') == '1') {
                first_sub_grid_obj = parent_grid_obj.cells(id, 0).getSubGrid();
                match_group_header_id = parent_grid_obj.cells(id, parent_grid_obj.getColIndexById('match_group_header_id')).getValue();

                ticket_matching_xml += '<match match_group_header_id="' + match_group_header_id + '">';
                first_sub_grid_obj.forEachRow(function(first_sub_id) {
                    match_group_detail_id = first_sub_grid_obj.cells(first_sub_id, 0).getValue();
                    second_sub_grid_obj = first_sub_grid_obj.cells(first_sub_id, 0).getSubGrid(); 
                    
                    if (second_sub_grid_obj !== null) {
                    var tickets = second_sub_grid_obj.getAllRowIds().split(',');
                    ticket_matching_xml +=  '<match_group_detail_id match_group_detail_id="' + match_group_detail_id + '">'
                    if (tickets != '') {
                        tickets.forEach(function(ticket_id) {
                            ticket_id_value = second_sub_grid_obj.cells(ticket_id, second_sub_grid_obj.getColIndexById('ticket_detail_id')).getValue();
                            ticket_matching_xml +=  '<ticket ticket_detail_id="' + ticket_id_value + '"></ticket>';
                                //alert(ticket_id_value + '_'+ match_group_header_id + '_' + match_group_detail_id);
                            }
                        );
                    } else {
                        ticket_matching_xml +=  '<ticket ticket_detail_id="" match_group_detail_id = ""></ticket>';
                    }
                    
                    ticket_matching_xml += '</match_group_detail_id>';      
                    }
                });
            ticket_matching_xml += '</match>';   
            }
            
        });
        //alert(ticket_matching_xml);

        ticket_matching_xml += '</Root>';
        var confirmation_msg = 'Are you sure you want to match the actuals?';
        if (ticket.actualize_schedule.getUserData('', 'isdeleted') == '1') { 
            confirmation_msg = 'Actuals have been deleted. Are you sure you want to update the matches?';
        }

        if (ticket_matching_xml != '<Root></Root>') {
            var data = {
                            "flag":'MATCH',
                            "action":'spa_ticket',
                            "ticket_match_xml":ticket_matching_xml
                        };
            adiha_post_data('confirm', data, '', '', 'save_ticket_matching_cb', '', confirmation_msg);
        }
    }

    function save_ticket_matching_cb() {
        refresh_all_grid();
        parent.refresh_window('Scheduling Workbench');
    }

    function open_window_ticket(url) {
        ticket_detail_window = new dhtmlXWindows();
        new_win = ticket_detail_window.createWindow('w1', 0, 0, '', '', '', 500, 1200);
        var text = "Ticket";
        new_win.setText(text);
        new_win.maximize();
        new_win.setModal(true);

        var ticket_id = '';

        new_win.attachURL(url, false, true);
        new_win.attachEvent("onClose", function(win){
            //console.log(window.frames[0]);
            //var top_win = ticket_detail_window.getTopmostWindow(true/false);
          //console.log(top_win);
            //alert(top_win);



            /*if () {
                dhtmlx.message({ 
                            type:"confirm-warning", 
                            ok: "Confirm",
                            text:"Ticket data will not be saved. Are you sure you want to close ?",
                            callback: function(result) {
                                if (result) {
                                        refresh_all_grid(); 
                                        return true;
                                    } 
                            }
               
                });
            } else {*/

                refresh_all_grid(); 
                return true;
           /* }*/
           
        });

    }

    function open_window_ticket_update(rid, cid) {
        var ticket_id = ticket.ticket.cells(rid, 0).getValue();
        var schedule_match_id = ticket.ticket.cells(rid, ticket.ticket.getColIndexById('match_id')).getValue();
        var is_match = 0;
        if (schedule_match_id != '') is_match = 1;

        var url = 'ticket.php?mode=u' + '&ticket_id=' + ticket_id + '&is_match=' + is_match;
      //alert(url);
        open_window_ticket(url);
    }

    function open_window_match (rid, cid) {
        var match_group_id = ticket.actualize_schedule.cells(rid, ticket.actualize_schedule.getColIndexById('match_group_id')).getValue();
      
        ticket.layout_ticket_match.cells('b').progressOn();
        var data = {
            "action" : "spa_scheduling_workbench",
            "flag" : "s",
            'match_group_id' : match_group_id
        };
        adiha_post_data('return_array', data, '', '', 'ticket.open_window_match_call_back');    
    }

 
            
    ticket.open_window_match_call_back = function (return_value) {     
        ticket.layout_ticket_match.cells('b').progressOff();
        var process_id = return_value[0][0];
        var match_group_id = return_value[0][1];
        var data = {
            "action" : "spa_scheduling_workbench",
            "flag" : "s",
            "buy_sell_flag" : 'NULL',
            "process_id" : process_id
        };

        adiha_post_data('alert', data, '', '', '');

       // match_group_id = ticket.actualize_schedule.cells(ticket.actualize_schedule.getSelectedRowId(), ticket.actualize_schedule.getColIndexById('match_group_id')).getValue();

        var convert_uom = ticket.filters.getItemValue('quantity_uom');

        cc_detail_window = new dhtmlXWindows();
        new_win = cc_detail_window.createWindow('w1', 0, 0, 2000,2000);
        var text = "Match Detail";
        new_win.setText(text);
        new_win.maximize();
        new_win.setModal(true);
        var url = 'match.php?mode=u' + '&process_id=' + process_id + '&match_group_id=' + match_group_id + '&convert_uom=' + convert_uom + '&convert_frequency=703';



        new_win.attachURL(url, false, true);
    }

    function menu_ticket_click(id) {
        switch(id) {
            case 'add':
                open_window_ticket('ticket.php?mode=i');
            break;
            case 'copy':
                ticket_copy();
            break;
            case 'delete':
                if (ticket.ticket.getSelectedRowId() !== null) {
                    var tickets = ticket.ticket.getSelectedRowId();
                    var selected_ticket_id = '';
                    var selected_ticket_detail_id = '';
                    var has_match_id = '';
                    tickets = tickets.split(',');
                    tickets.forEach(
                        function(id) {
                            if (selected_ticket_id == '') {
                                selected_ticket_id += ticket.ticket.cells(id, 0).getValue();
                                selected_ticket_detail_id += ticket.ticket.cells(id, 1).getValue();
                            }
                            else {
                                selected_ticket_id += ',' + ticket.ticket.cells(id, 0).getValue();
                                selected_ticket_detail_id += ticket.ticket.cells(id, 1).getValue();
                            }

                            if (ticket.ticket.cells(id, ticket.ticket.getColIndexById('match_id')).getValue()) 
                                    has_match_id = 1;
                        }
                    );
                    
                    var data = {
                        "action" : "spa_ticket",
                        "flag" : "d",
                        "ticket_header_id" : selected_ticket_id,
                        "ticket_detail_ids" : selected_ticket_detail_id
                    };
                    
                    adiha_post_data('confirm', data, '', '', 'ticket.refresh_grid_ticket');
                

                }
            break;
            case "excel":
                ticket.ticket.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
            break;
            case "pdf":
                ticket.ticket.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
            break;
        }
    }

    ticket.refresh_grid_match = function () {
        ticket.actualize_schedule.setUserData('', 'isdeleted', '0');
        
        ticket.layout_ticket_match.cells('b').progressOn();
        var filter_xml = '<Root><FormFilterXML ';
        var form_data = ticket.filters.getFormData();
        var filter_param = '';

        for (var a in form_data) {
            if (form_data[a] != '' && form_data[a] != null) {

                if (ticket.filters.getItemType(a) == 'calendar') {
                    value = ticket.filters.getItemValue(a, true);
                } else {
                   if (a == 'label_ticket_number') {               
                        value = form_data[a].replace(/[0-9]/g, '');
                    } else {
                        value = form_data[a];
                    } ;
                }
                filter_xml +=  a + '="' + value + '" ';
            }
        }

        filter_xml += '></FormFilterXML></Root>';

        var sql_param = {
            "action" : "spa_scheduling_workbench",
            "flag" : "t",
            "filter_xml" : filter_xml
        };

        sql_param = $.param(sql_param);
        var sql_url = js_data_collector_url + "&" + sql_param;

        ticket.actualize_schedule.clearAll();
        ticket.actualize_schedule.load(sql_url, function(){
            ticket.actualize_schedule.filterByAll();
			init_subgrid();
            ticket.layout_ticket_match.cells('b').progressOff();
		});
    }

    function init_subgrid() {
        ticket.actualize_schedule.forEachRow(function(rid) {
           ticket.actualize_schedule.cells(rid,0).open();
           ticket.actualize_schedule.cells(rid,0).close();
        });
    }

    function context_menu_match_click(menu_id, type) {

        var data = ticket.actualize_schedule.contextID.split("_"); //rowId_colInd
        var row_id = data[0];


        var url = 'ticket.php?mode=i&schedule_match_id=' + ticket.actualize_schedule.cells(row_id,ticket.actualize_schedule.getColIndexById('match_group_header_id')).getValue()
                                + '&location=' + ticket.actualize_schedule.cells(row_id, ticket.actualize_schedule.getColIndexById('location_id')).getValue()
                                + '&commodity=' + ticket.actualize_schedule.cells(row_id, ticket.actualize_schedule.getColIndexById('commodity_name')).getValue()
                                + '&volume_uom=' + ticket.actualize_schedule.cells(row_id, ticket.actualize_schedule.getColIndexById('uom_name')).getValue();
        
        open_window_ticket(url);
    }

    ticket.refresh_grid_ticket = function (result) {
        if (result != undefined) {
            if (result[0].status == 'DB Error') {
                return;
            }    
        }
        
       // ticket.actualize_schedule.layout_ticket_match.cells("a").progressOn();
        ticket.layout_ticket_match.cells('a').progressOn();
        ticket_menu = ticket.layout_ticket_match.cells("a").getAttachedMenu();
        var filter_xml = '<Root><FormFilterXML ';
        //For form in first tab
        var form_data = ticket.filters.getFormData();
        var filter_param = '';

        for (var a in form_data) {
            if (form_data[a] != '' && form_data[a] != null) {

                if (ticket.filters.getItemType(a) == 'calendar') {
                    value = ticket.filters.getItemValue(a, true);
                } else {
                    if (a == 'label_ticket_number') {
                        value = form_data[a].replace(/[0-9]/g, '');
                    } else {
                        value = form_data[a];
                    }
                }
                filter_xml +=  a + '="' + value + '" ';
            }
        }

        //for form in second tab
        form_data = ticket.commodity_form.getFormData();
        
        for (var a in form_data) {
            if (form_data[a] != '' && form_data[a] != null) {

                if (ticket.commodity_form.getItemType(a) == 'calendar') {
                    value = ticket.commodity_form.getItemValue(a, true);
                } else {
                    value = form_data[a];
                }
                filter_xml +=  a + '="' + value + '" ';
            }
        }

        filter_xml += '></FormFilterXML></Root>';
        
        var sql_param = {
            "action" : "spa_split_deal_actuals",
            "flag" : "t",
            "filter_xml" : filter_xml
        };

        sql_param = $.param(sql_param);
        var sql_url = js_data_collector_url + "&" + sql_param;

        ticket.ticket.clearAll();
        ticket.ticket.loadXML(sql_url, function(){
            ticket.layout_ticket_match.cells('a').progressOff();
            ticket.ticket.filterByAll();
        });

        ticket_menu.setItemDisabled("delete");
        ticket_menu.setItemDisabled("copy"); 
    }

    function ticket_grid_click() {      
        ticket_menu = ticket.layout_ticket_match.cells("a").getAttachedMenu();
        //alert('<?php echo $has_rights_actualize_delete;?>');
        //var has_rights_actualize_delete = <?php echo $has_rights_actualize_delete;?>;
        if (ticket.ticket.getSelectedRowId() && has_rights_ticket_delete == true) {
        //if (ticket.ticket.getSelectedRowId() && has_rights_actualize_delete == true) {
           ticket_menu.setItemEnabled("delete");
           ticket_menu.setItemEnabled("copy");
        } else {
           ticket_menu.setItemDisabled("delete");
           ticket_menu.setItemDisabled("copy");
        }
    }

    function disable_row_add(rid) {
        ticket.ticket.deleteRow(rid);
    }

    function ticket_copy() {        
        var row_id = ticket.ticket.getSelectedRowId();
        var ticket_id = ticket.ticket.cells(row_id, 0).getValue();

        var data = {
                        "action" : "spa_ticket",
                        "flag" : "COPY_TICKET",
                        "ticket_header_id" : ticket_id
                    };
                    
        adiha_post_data('alert', data, '', '', 'ticket.refresh_grid_ticket');
    }

</script>
    
