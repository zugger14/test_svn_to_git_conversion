<?php
/**
* View nom schedules screen
* @copyright Pioneer Solutions
*/
?>
<!--DOCTYPE transitional.dtd-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<meta http-equiv="X-UA-Compatible" content="IE=Edge"> 
    <html> 
        <?php
        include '../../../../adiha.php.scripts/components/include.file.v3.php';

        $php_script_loc = $app_php_script_loc;
        $app_user_loc = $app_user_name;

        $term_start = get_sanitized_value($_GET['flow_date'] ?? '');
        $term_end = get_sanitized_value($_GET['flow_date_end'] ?? '');
        $delivery_receipt_group = get_sanitized_value($_GET['delivery_receipt_group'] ?? '');
        $location_ids = get_sanitized_value($_GET['location_ids'] ?? '');
        $path_ids = get_sanitized_value($_GET['path_ids'] ?? '');
        $call_from = get_sanitized_value($_GET['call_from'] ?? '');

        $rights_ui = 10163410;
        $rights_delete = 10163411;
        $rights_upd_deal_vol = 10131031;
        $rights_upd_sch_vol = 10131032;
        $rights_upd_act_vol = 10131033;

        list (
                $has_rights_ui,
                $has_rights_delete,
                $has_rights_upd_deal_vol,
                $has_rights_upd_sch_vol,
                $has_rights_upd_act_vol
                ) = build_security_rights(
                $rights_ui, 
                $rights_delete,
                $rights_upd_deal_vol,
                $rights_upd_sch_vol,
                $rights_upd_act_vol
        );

        $json = '[
                {
                    id:             "a",
                    text:           "Delivery Paths",
                    header:         true,
                    collapse:       false,
                    width:          390,
                    undock:         true
                },
                {
                    id:             "b",
                    text:           "Filters",
                    header:         true,
                    collapse:       false,
                    height:         90
                },
                {
                    id:             "c",
                    text:           "Filter Criteria",
                    header:         true,
                    collapse:       false,
                    height:         100
                },
                {
                    id:             "d",
                    text:           "Schedules",
                    header:         true,
                    collapse:       false,
                    undock:         true
                }  
            ]';

        $namespace = 'view_nom_schedules';
        $view_nom_schedules_layout_obj = new AdihaLayout();
        echo $view_nom_schedules_layout_obj->init_layout('view_nom_schedules_layout', '', '4C', $json, $namespace);

        //Attaching filter form for View Nom Schedules Grid
        $filter_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10163400', @template_name='View Nom Schedules', @group_name='Filters'";
        $filter_arr = readXMLURL2($filter_sql);
        $tab_id = $filter_arr[0]['tab_id'];
        $form_json = $filter_arr[0]['form_json'];
        echo $view_nom_schedules_layout_obj->attach_form('filter_form', 'c', $form_json, $filter_arr[0]['dependent_combo']);

        //Attaching Toolbar for Delivery Path Grid
        $delivery_path_menu_json = '[
                                    // { id: "refresh", img: "refresh.gif", text: "Refresh", title: "Refresh"},
                                    { id: "expand_collapse", img: "exp_col.gif", text: "Expand/Collapse", title: "Expand/Collapse"}
                                 ]';

        echo $view_nom_schedules_layout_obj->attach_menu_cell('delivery_path_menu', 'a');
        $delivery_path_menu_obj = new AdihaMenu();
        echo $delivery_path_menu_obj->init_by_attach('delivery_path_menu', $namespace);
        echo $delivery_path_menu_obj->load_menu($delivery_path_menu_json);
        echo $delivery_path_menu_obj->attach_event('', 'onClick', 'delivery_path_menu_onclick');

        //Attaching Delivery Path Grid
        echo $view_nom_schedules_layout_obj->attach_status_bar('a', true);
        echo $view_nom_schedules_layout_obj->attach_grid_cell('delivery_path_grid', 'a');
        $delivery_path_grid = new AdihaGrid();
        echo $delivery_path_grid->init_by_attach('delivery_path_grid', $namespace);
        echo $delivery_path_grid->set_header("Path Name,Path Code,Path ID,Receipt Location,Delivery Location,Pipeline,Contract");
        echo $delivery_path_grid->set_columns_ids("path_name,path_code,path_id,receipt_location,delivery_location,pipeline,contract");
        echo $delivery_path_grid->set_widths("300,100,50,150,150,150,150");
        echo $delivery_path_grid->set_column_types("tree,ro,ro,ro,ro,ro,ro");
        echo $delivery_path_grid->set_column_auto_size();
        echo $delivery_path_grid->set_column_visibility("false,true,true,false,false,false,false");
        echo $delivery_path_grid->enable_multi_select();
        echo $delivery_path_grid->enable_paging(25, 'pagingArea_a', true);
        echo $delivery_path_grid->return_init();
        echo $delivery_path_grid->set_search_filter(true);
        echo $delivery_path_grid->load_grid_data("EXEC spa_setup_delivery_path 'g'", 'tg', 'path_type,grouping_name');
        echo $delivery_path_grid->attach_event('', 'onRowDblClicked', $namespace . '.expand_paths');
        echo $delivery_path_grid->attach_event('', 'onXLE', $namespace . '.set_default_calendar_value');
        //Attaching Toolbar for Schedule Grid
        $menu_json = '[
                { id: "refresh", img: "refresh.gif", text: "Refresh", title: "Refresh"},
                {id:"t2", text:"Export", img:"export.gif", items:[
                                    {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                                    {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                                ]},
                {id:"t3", text:"Actions", img:"action.gif", imgdis:"action_dis.gif", items:[
                        {id:"update_del_rank", text:"Update Delivery Rank", img:"edit.gif", imgdis:"edit_dis.gif", disabled:true, title: "Update Delivery Rank"},
                        {id:"delete", text:"Delete", img:"delete.gif", imgdis:"delete_dis.gif", disabled:true, title: "Delete"},
                        {id:"delete_all", text:"Delete All", img:"delete.gif", imgdis:"delete_dis.gif", title: "Delete All"}
                    ]},
                {id: "expand_collapse", img: "exp_col.gif", text: "Expand/Collapse"},
                {id: "pivot", img: "pivot.gif", text: "Pivot"},
                {id: "save", img: "save.gif", imgdis: "save_dis.gif", text: "Save"},
                {id: "html", img: "html.gif", imgdis: "html_dis.gif", text: "Balancing Report", disabled: true}
             ]';
        echo $view_nom_schedules_layout_obj->attach_menu_layout_cell('view_nom_schedules_menu', 'd', $menu_json, 'view_nom_schedules_toolbar_onclick');
        echo $view_nom_schedules_layout_obj->close_layout();

        $sql_query = "EXEC [spa_adiha_default_codes_values] @flag = 'combo_grid', @default_code_id = 206";
        $return_data = readXMLURL($sql_query);
        $granularity = $return_data[0][4];
        ?> 

        </body>
        <style>
            html, body {
                width: 100%;
                height: 100%;
                margin: 0px;
                overflow: hidden;
            }
           
        </style>
        <textarea style="display:none" name="txt_process_table" id="txt_process_table"></textarea>
        <script type="text/javascript">
            var expand_state = 0;
            var expand_state1 = 1;
            var php_script_loc = '<?php echo $php_script_loc; ?>';
            var php_script_loc_ajax = '<?php echo $php_script_loc; ?>';
            grid_creation_status = {};
            grid_creation_status.status = 0;
            var blotter_window;
            var has_rights_ui = <?php echo (($has_rights_ui) ? $has_rights_ui : '0'); ?>;
            var has_rights_delete = <?php echo (($has_rights_delete) ? $has_rights_delete : '0'); ?>;
            var has_rights_upd_deal_vol = <?php echo (($has_rights_upd_deal_vol) ? $has_rights_upd_deal_vol : '0'); ?>;
            var has_rights_upd_sch_vol = <?php echo (($has_rights_upd_sch_vol) ? $has_rights_upd_sch_vol : '0'); ?>;
            var has_rights_upd_act_vol = <?php echo (($has_rights_upd_act_vol) ? $has_rights_upd_act_vol : '0'); ?>;
            var delivery_receipt_group  = '<?php echo $delivery_receipt_group ?>';
            var location_ids  = '<?php echo $location_ids ?>';
			location_ids_temp = location_ids;
            var path_ids  = '<?php echo $path_ids ?>';
            var call_from  = '<?php echo $call_from ?>';
            var granularity = '<?php echo $granularity; ?>';

            $(function() {
                filter_obj = view_nom_schedules.view_nom_schedules_layout.cells('b').attachForm();
                var layout_cell_obj = view_nom_schedules.view_nom_schedules_layout.cells('c');
                load_form_filter(filter_obj, layout_cell_obj, '10163400', 2);

                filter_obj.attachEvent("onBeforeChange",function(name,oldValue,newValue){
                    view_nom_schedules.delivery_path_grid.expandAll();
                    return true;
                });
            });

            view_nom_schedules.set_default_calendar_value = function() {
                var term_start = "<?php echo $term_start; ?>";
                var term_end = "<?php echo $term_end; ?>";
                var currentTime = new Date();
                var lastDay = new Date(currentTime.getFullYear(), currentTime.getMonth() + 1, 0);
 
                date_end = formatDate(tomorrow);
                var today = new Date();
                today.setDate(30);
                var tomorrow = new Date();
                tomorrow.setDate(currentTime.getDate() + 1);
                date_start = formatDate(tomorrow);
                date_end = formatDate(tomorrow);
                
                if (formatDate(new Date()) == date_end) {    
                    date_end = formatDate(new Date(currentTime.getFullYear(), currentTime.getMonth() + 2, 0));
                } 
                
                if (term_start) {
                    view_nom_schedules.filter_form.setItemValue('date_from', term_start);
                } else {
                    view_nom_schedules.filter_form.setItemValue('date_from', date_start);
                }
               
                if (term_end)
                    view_nom_schedules.filter_form.setItemValue('date_to', term_end);
                else
                    view_nom_schedules.filter_form.setItemValue('date_to', date_end);

                if (delivery_receipt_group != '') {
                    var location_group_obj = view_nom_schedules.filter_form.getCombo('location_group');
                    var loc_group_splitted_ids = delivery_receipt_group.split(",");
                    for (var i = 0; i < loc_group_splitted_ids.length; i++) {
                        location_group_obj.setChecked(location_group_obj.getIndexByValue(loc_group_splitted_ids[i]), true);
                    }
                }

                if (location_ids != '') {
                    var form_obj =  view_nom_schedules.filter_form;
                    dependent_combo_default_data = "location_group->location_name->m->" + location_ids +  "->m";
                    load_dependent_combo(dependent_combo_default_data, 0, form_obj,'');
                }





                if (path_ids != '') { //IF opened from flow Optimization
                    var path_ids_splitted = path_ids.split(",");
                    for (var i = 0; i < path_ids_splitted.length; i++) {
                        var primary_value = view_nom_schedules.delivery_path_grid.findCell(path_ids_splitted[i], 2, true, true);
                        var r_id = primary_value.toString().substring(0, primary_value.toString().indexOf(","));
                        view_nom_schedules.delivery_path_grid.selectRowById(r_id,true,true,true);
                    }
                }

                view_nom_schedules_refresh();
            }
            
            //function to formatDate
            function formatDate(date) {
				if(typeof date == 'undefined') return date;
				if(typeof date == 'string') date = date.replace(/-/g, '/');	
                var d = new Date(date),
                        month = '' + (d.getMonth() + 1),
                        day = '' + d.getDate(),
                        year = d.getFullYear();

                if (month.length < 2)
                    month = '0' + month;
                if (day.length < 2)
                    day = '0' + day;

                return [year, month, day].join('-');
            }
            /*Triggers when window is to be undocked.*/
            /*START*/
            view_nom_schedules.undock_window = function(cell) {
                if (cell == 'a') {
                    w1 = view_nom_schedules.view_nom_schedules_layout.cells('a').undock(0, 0, 1000, 600);
                    view_nom_schedules.view_nom_schedules_layout.dhxWins.window('a').button('minmax').show();
                    view_nom_schedules.view_nom_schedules_layout.dhxWins.window('a').button('park').hide();
                    view_nom_schedules.view_nom_schedules_layout.dhxWins.window('a').centerOnScreen();
                }
                else if (cell == 'b') {
                    w1 = view_nom_schedules.view_nom_schedules_layout.cells('b').undock(0, 0, 1000, 600);
                    view_nom_schedules.view_nom_schedules_layout.dhxWins.window('b').button('minmax').show();
                    view_nom_schedules.view_nom_schedules_layout.dhxWins.window('b').button('park').hide();
                    view_nom_schedules.view_nom_schedules_layout.dhxWins.window('b').centerOnScreen();
                }
                else if (cell == 'd') {
                    w1 = view_nom_schedules.view_nom_schedules_layout.cells('d').undock(0, 0, 1000, 600);
                    view_nom_schedules.view_nom_schedules_layout.dhxWins.window('d').button('minmax').show();
                    view_nom_schedules.view_nom_schedules_layout.dhxWins.window('d').button('park').hide();
                    view_nom_schedules.view_nom_schedules_layout.dhxWins.window('d').centerOnScreen();

                }
                w1.maximize();
            }

            /**
             * [Function to expand/collapse Locations Grid when double clicked]
             */
            view_nom_schedules.expand_paths = function(r_id, col_id) {
                var selected_row = view_nom_schedules.delivery_path_grid.getSelectedRowId();
                var state = view_nom_schedules.delivery_path_grid.getOpenState(selected_row);

                if (state)
                    view_nom_schedules.delivery_path_grid.closeItem(selected_row);
                else
                    view_nom_schedules.delivery_path_grid.openItem(selected_row);
            }

            /**
             *[openAllInvoices Open All nodes of Invoice Grid]
             */
            open_all_paths = function() {
                view_nom_schedules.delivery_path_grid.expandAll();
                expand_state = 1;
            }

            /**
             *[closeAllInvoices Close All nodes of Invoice Grid]
             */
            close_all_paths = function() {
                view_nom_schedules.delivery_path_grid.collapseAll();
                expand_state = 0;
            }
            /**
             *[openAllSchedules Open All nodes of Grid]
             */
            open_all_schedules = function() {
                if (view_nom_schedules.view_nom_schedules_grid) {
                    view_nom_schedules.view_nom_schedules_grid.expandAllGroups();
                    expand_state1 = 1;
                }
            }
            /**
             *[closeAllSchedules Close All nodes of Grid]
             */
            close_all_schedules = function() {
                if (view_nom_schedules.view_nom_schedules_grid) {
                    view_nom_schedules.view_nom_schedules_grid.collapseAllGroups();
                    expand_state1 = 0;
                }
            }
            /**
             * [Toolbar onclick function for Counterparty/Contract Grid]
             */
            function delivery_path_menu_onclick(name, value) {
                /* Refresh the Contract/Counterparty Grid (counterparty_type and subsidiary_id as filter) */
                if (name == 'refresh') {
                    delivery_path_grid_refresh()
                } else if (name == 'expand_collapse') {
                    if (expand_state == 0) {
                        open_all_paths();
                    } else {
                        close_all_paths();
                    }
                }
            }
            /**
             * [Toolbar onclick function for Contract Settlement Grid]
             */
            function view_nom_schedules_toolbar_onclick(name) {
                if (name == 'save') {
                    save_schedule_value();
                } else if (name == 'pivot') {
                    var process_table = $('textarea#txt_process_table').val();
                    if (process_table == '') {
                        show_messagebox("Please refresh grid.")
                        return;
                    }
                    var pivot_exec_spa = "SELECT * FROM " + process_table;
                    open_grid_pivot('', 'nomination_schedule_grid', 1, pivot_exec_spa, 'Nomination Schedule');
                } else if (name == 'refresh') {
                    expand_state1 = 1;
                    view_nom_schedules_refresh();
                } else if (name == 'pdf') {
                    if (view_nom_schedules.view_nom_schedules_grid)
                        view_nom_schedules.view_nom_schedules_grid.toPDF(php_script_loc_ajax + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                    else {
                        var message = "Grid is empty to perform any operations.";
                        show_messagebox(message);
                        return;
                    }
                } else if (name == 'excel') { 
                    var process_table = $('textarea#txt_process_table').val();
                    if (process_table == '') {
                        show_messagebox("Please refresh grid.")
                        return;
                    }
                    var header = 'Path,Flow Date,Single Path,Deal ID,Nom Rec Vol,Shrinkage,Nom Del Vol,Schedule Rec Vol,Schedule Del Vol,Actual Rec Vol,Actual Del Vol,Rec Location,Del Location,Contract,Pipeline,Nom Group,Path Priority,Rec Priority,Del Priority,UOM';
                    view_nom_schedules.view_nom_schedules_grid.PSExport('excel', process_table, 'Schedules',header);
                } else if (name == 'expand_collapse') {
                    if (expand_state1 == 0) {
                        open_all_schedules();
                    } else {
                        close_all_schedules();
                    }
                } else if (name == 'delete') {
                    delete_deals();
                } else if (name == 'delete_all') {
                    open_term_window();
                } else if (name == 'update_del_rank') {
                    view_nom_schedules.acc_pop = new dhtmlXPopup();
                    view_nom_schedules.acc_form = view_nom_schedules.acc_pop.attachForm(
                        [
                            {type: "combo", label: "Del Rank", name: "del_rank", position: "label-top"},
                            {type: "button", value: "Ok"}
                        ]);
                    view_nom_schedules.acc_pop.show(555,200,50,50);
                    
                    delivery_priority_cmb_obj = view_nom_schedules.acc_form.getCombo("del_rank");
                    delivery_priority_cmb_obj.enableFilteringMode(true);

                    var cm_param = {
                                    "action": "spa_StaticDataValues", 
                                    "flag": "h", 
                                    "type_id": "32000",
                                    "has_blank_option" : "n"
                                    };
                    cm_param = $.param(cm_param);
                    var url = js_dropdown_connector_url + '&' + cm_param;
                    delivery_priority_cmb_obj.load(url);
                    
                    view_nom_schedules.acc_form.attachEvent("onButtonClick", function(name){
                        view_nom_schedules.acc_pop.hide();
                        var del_rank_id = view_nom_schedules.acc_form.getItemValue("del_rank");
                        var ids = collect_ids();
                        
                        data = {"action": "spa_schedules_view", 
                                "flag": "p", 
                                "source_deal_header_id": ids, 
                                "del_priority_id": del_rank_id
                                };
                        result = adiha_post_data("confirm", data, "", "", "view_nom_schedules_refresh","","Are you sure you want to update delivery rank of selected?");
                    });
                } else if (name == 'html') {
                    var dhxWins = new dhtmlXWindows();
                    var param = '../../../../adiha.html.forms/_scheduling_delivery/gas/view_nom_schedules/view.nom.schedules.grid.php';
                    var is_win = dhxWins.isWindow('w1');
                    if (is_win == true) {
                        w11.close();
                    }
                    w11 = dhxWins.createWindow("w1", 520, 100, 530, 550);
                    w11.setText("View Nomination Balancing Report");
                    w11.setModal(true);
                    w11.maximize();
                    w11.attachURL(param, false, {process_id: process_id});
            
                    w11.attachEvent("onClose", function(win) {  
                        return true;
                    });
                }
            }

            var term_window;
            function open_term_window() {
                unload_term_window();

                if (!term_window) {
                    term_window = new dhtmlXWindows();
                }

                var win = term_window.createWindow('w1', 0, 0, 530, 360);
                win.setText("Delete Term Range");
                win.centerOnScreen();
                win.setModal(true);

                var date_from = view_nom_schedules.filter_form.getItemValue("date_from", true);
                var date_to = view_nom_schedules.filter_form.getItemValue("date_to", true);

                var form_json = [{
                                type: 'block',
                                blockOffset: ui_settings['block_offset'],
                                list: [
                                    {
                                        'type': 'calendar',
                                        'name': 'term_from',
                                        'label': 'Term From',
                                        'position': 'label-top',
                                        'validate': 'NotEmpty',
                                        'inputWidth': ui_settings['field_size'],
                                        'offsetLeft':ui_settings['offset_left'],
                                        'labelWidth': 'auto',
                                        'required': true,
                                        'userdata': {
                                            'validation_message': 'Required Field'
                                        },
                                        'tooltip': 'Term From',
                                        'dateFormat': user_date_format ,
                                        'serverDateFormat': "%Y-%m-%d",
                                        'value': date_from
                                    }, {type: 'newcolumn', offset: 1},
                                    {
                                        'type': 'calendar',
                                        'name': 'term_to',
                                        'label': 'Term To',
                                        'position': 'label-top',
                                        'validate': 'NotEmpty',
                                        'inputWidth': ui_settings['field_size'],
                                        'offsetLeft':ui_settings['offset_left'],
                                        'labelWidth': 'auto',
                                        'required': true,
                                        'userdata': {
                                            'validation_message': 'Required Field'
                                        },
                                        'tooltip': 'Term To',
                                        'dateFormat': user_date_format ,
                                        'serverDateFormat': "%Y-%m-%d",
                                        'value': date_to
                                    }
                                ]
                            }];
                var toolbar_json = [{id:"ok", type:"button", img:"save.gif", imgdis:"save_dis.gif", text:"Ok", title:"Ok"}];
                var toolbar_obj = win.attachToolbar();
                toolbar_obj.setIconsPath(js_image_path + '/dhxtoolbar_web/');
                toolbar_obj.loadStruct(toolbar_json);
                toolbar_obj.attachEvent("onClick", function(id){
                    if (id == 'ok') {
                        var form_obj = win.getAttachedObject();
                        var status = validate_form(form_obj);
                        if (status) {
                            form_obj.setUserData("term_from", "click", "ok");
                            win.close();
                        }
                    }
                });
                
                var form_obj = win.attachForm();
                form_obj.load(form_json);

                win.attachEvent('onClose', function(w) {
                    var form_obj = w.getAttachedObject();
                    var button_click = form_obj.getUserData("term_from", "click");
                    if (button_click != "ok") return true;
                    
                    var term_start = form_obj.getItemValue('term_from', true);
                    var term_to = form_obj.getItemValue('term_to', true);
                    delete_all_deals(term_start, term_to);
                    return true;
                });
            }

            function unload_term_window() {
                if (term_window != null && term_window.unload != null) {
                    term_window.unload();
                    term_window = w1 = null;
                }
            }

            /**
             * [Refresh function for delivery_path_grid]
             */
            function delivery_path_grid_refresh() {
                expand_state = 0;
                var param = {
                    "flag": "g",
                    "grid_type": "tg",
                    "grouping_column": "path_type,grouping_name",
                    "action": "spa_setup_delivery_path"
                };

                param = $.param(param);
                var param_url = js_data_collector_url + "&" + param;
                view_nom_schedules.delivery_path_grid.clearAll();
                view_nom_schedules.delivery_path_grid.loadXML(param_url);
            }

            var main_context_menu, apply_to_window;
            view_nom_schedules.add_context_menu = function (row_id, ind) {
                main_context_menu = new dhtmlXMenuObject();
                main_context_menu.renderAsContextMenu();
                var menu_obj = [{id:"apply_all", text:"Apply to All", enabled:true},
                                {id:"trickle", text:"Trickle Up/Down", enabled:true}
                                ];
                main_context_menu.loadStruct(menu_obj);
                view_nom_schedules.view_nom_schedules_grid.enableContextMenu(main_context_menu);

                main_context_menu.attachEvent("onClick", function(menuitemId, zoneId) {
                    switch(menuitemId){
                        case 'apply_all':
                            var data = view_nom_schedules.view_nom_schedules_grid.contextID.split("_");
                            row_id = view_nom_schedules.view_nom_schedules_grid.getSelectedRowId();
                            var column_index = (data.length == 2) ? data[1] : data[3];
                            var rId = view_nom_schedules.view_nom_schedules_grid.getSelectedRowId()
                            var col_label = view_nom_schedules.view_nom_schedules_grid.getColLabel(column_index);
                            var col_value = view_nom_schedules.view_nom_schedules_grid.cells(rId, column_index).getValue();
                            var flow_date_index = view_nom_schedules.view_nom_schedules_grid.getColIndexById("flow_date")
                            var flow_date = view_nom_schedules.view_nom_schedules_grid.cells(rId, flow_date_index).getValue();
                            var group_path_name = view_nom_schedules.view_nom_schedules_grid.cells(rId, view_nom_schedules.view_nom_schedules_grid.getColIndexById("group_path_name")).getValue();

                            var filtered_schedule_data = _.filter(global_schedule_data.data, function(item) {
                                return (item.group_path_name == group_path_name && item.type == 2 && item.flow_date == flow_date);
                            });

                            var all_info = [];
                            for (var i = 0; i < filtered_schedule_data.length; i++) {
                                var deal_id = $(filtered_schedule_data[i]['deal_id']).attr("id");
                                all_info.push({
                                    deal_id: deal_id,
                                    shrinkage: filtered_schedule_data[i]['shrinkage'],
                                    rec_vol: col_value,
                                    del_vol: col_value
                                });
                            }
                            var deal_info = JSON.stringify(all_info);

                            view_nom_schedules.unload_apply_to_window();
                            if (!apply_to_window) {
                                apply_to_window = new dhtmlXWindows();
                            }
                            var min_max_term = view_nom_schedules.view_nom_schedules_grid.collectValues(flow_date_index); 
                            min_max_term.sort(function(a, b){
                                return Date.parse(a) - Date.parse(b);
                            });
                            var flow_date_to = min_max_term[min_max_term.length-1];

                            var win_title = "Apply To Column - " + col_label;
                            var win_url = 'apply.to.rows.php';

                            var win = apply_to_window.createWindow('w1', 0, 0, 540, 410);
                            win.setText(win_title);
                            win.centerOnScreen();
                            win.setModal(true);
                            win.attachURL(win_url, false, {flow_date:formatDate(flow_date),flow_date_to:formatDate(flow_date_to),col_label:col_label,col_value:col_value,info:deal_info});

                            win.attachEvent('onClose', function(w) {
                                var ifr = w.getFrame();
                                var ifrWindow = ifr.contentWindow;
                                var ifrDocument = ifrWindow.document;
                                var status_message = $('textarea[name="txt_status"]', ifrDocument).val();
                                if (status_message != '') {
                                    success_call(status_message, 'success');
                                    view_nom_schedules_refresh();
                                }
                                return true;
                            });
                        break;
                        case 'trickle':
                            var rId = view_nom_schedules.view_nom_schedules_grid.getSelectedRowId();
                            var data = view_nom_schedules.view_nom_schedules_grid.contextID.split("_");
                            var cInd = (data.length == 2) ? data[1] : data[3];
                            trickle_volume(true, rId, cInd);
                        break;
                    }
                });
            }

            /**
             * [unload_apply_to_window Unload Apply To Window]
             */
            view_nom_schedules.unload_apply_to_window = function() {
                if (apply_to_window != null && apply_to_window.unload != null) {
                    apply_to_window.unload();
                    apply_to_window = w1 = null;
                }
            }

            view_nom_schedules.right_click_grid = function(rowId, ind) {
                view_nom_schedules.view_nom_schedules_grid.selectRowById(rowId,false,true,true);
                var delivery_vol_index = view_nom_schedules.view_nom_schedules_grid.getColIndexById("delivery_vol");
                var scheduled_vol_index = view_nom_schedules.view_nom_schedules_grid.getColIndexById("schedule_vol");
                var schedule_del_vol_index = view_nom_schedules.view_nom_schedules_grid.getColIndexById("schedule_del_vol");
                var schedule_rec_vol_index = view_nom_schedules.view_nom_schedules_grid.getColIndexById("schedule_rec_vol");
                var actual_del_vol_index = view_nom_schedules.view_nom_schedules_grid.getColIndexById("actual_del_vol");
                var actual_rec_vol_index = view_nom_schedules.view_nom_schedules_grid.getColIndexById("actual_rec_vol");

                var group_path_name = view_nom_schedules.view_nom_schedules_grid.cells(rowId, view_nom_schedules.view_nom_schedules_grid.getColIndexById("group_path_name")).getValue();
                var flow_date = view_nom_schedules.view_nom_schedules_grid.cells(rowId, view_nom_schedules.view_nom_schedules_grid.getColIndexById("flow_date")).getValue();
                var deal_ref_id = view_nom_schedules.view_nom_schedules_grid.cells(rowId, view_nom_schedules.view_nom_schedules_grid.getColIndexById("deal")).getValue();
                
                if (granularity == 982) {
                    if (ind == delivery_vol_index || ind == schedule_del_vol_index || ind == actual_del_vol_index) {
                        var leg = 1;
                    } else if (ind == scheduled_vol_index || ind == schedule_rec_vol_index || ind == actual_rec_vol_index) {
                        var leg = 2;
                    }
                    open_actual_window(deal_ref_id, flow_date, leg);
                }

                var filtered_schedule_data = _.filter(global_schedule_data.data, function(item) {
                    return (unescapeXML(item.group_path_name) == unescapeXML(group_path_name) && item.type == 2 && item.flow_date == flow_date);
                });
                view_nom_schedules.view_nom_schedules_grid.enableContextMenu(null);
                
                if (filtered_schedule_data.length > 0) {
                    if (filtered_schedule_data[0].deal == deal_ref_id && (ind == scheduled_vol_index || ind == schedule_rec_vol_index || ind == actual_rec_vol_index)
                            || filtered_schedule_data[filtered_schedule_data.length -1].deal == deal_ref_id && (ind == delivery_vol_index || ind == schedule_del_vol_index || ind == actual_del_vol_index)) {
                        view_nom_schedules.view_nom_schedules_grid.enableContextMenu(main_context_menu);

                        if (filtered_schedule_data[0].is_group_path == 'n')
                            main_context_menu.setItemDisabled('trickle');
                        else
                            main_context_menu.setItemEnabled('trickle');
                    }
                }
                return true;
            }

            view_nom_schedules.select_grid = function(rowId, ind) {
                var delivery_vol_index = view_nom_schedules.view_nom_schedules_grid.getColIndexById("delivery_vol");
                var scheduled_vol_index = view_nom_schedules.view_nom_schedules_grid.getColIndexById("schedule_vol");
                var schedule_del_vol_index = view_nom_schedules.view_nom_schedules_grid.getColIndexById("schedule_del_vol");
                var schedule_rec_vol_index = view_nom_schedules.view_nom_schedules_grid.getColIndexById("schedule_rec_vol");
                var actual_del_vol_index = view_nom_schedules.view_nom_schedules_grid.getColIndexById("actual_del_vol");
                var actual_rec_vol_index = view_nom_schedules.view_nom_schedules_grid.getColIndexById("actual_rec_vol");

                var flow_date = view_nom_schedules.view_nom_schedules_grid.cells(rowId, view_nom_schedules.view_nom_schedules_grid.getColIndexById("flow_date")).getValue();
                var deal_ref_id = view_nom_schedules.view_nom_schedules_grid.cells(rowId, view_nom_schedules.view_nom_schedules_grid.getColIndexById("deal_id")).getValue();
                var deal_id = $(deal_ref_id).attr("id");
                if (granularity == 982) {
                    if (ind == delivery_vol_index || ind == schedule_del_vol_index || ind == actual_del_vol_index) {
                        open_actual_window(deal_id, flow_date, 2);
                    } else if (ind == scheduled_vol_index || ind == schedule_rec_vol_index || ind == actual_rec_vol_index) {
                        open_actual_window(deal_id, flow_date, 1);
                    }
                }
                return true;
            }

            function save_schedule_value(ids, flow_date_from, flow_date_to) {
                if (ids == '' || ids == undefined) {
                    var ids = view_nom_schedules.view_nom_schedules_grid.getChangedRows();
                    var changed_ids = ids.split(",");
                } else {
                    var changed_ids = ids;
                }
                
                var grid_xml = '<GridXML>';
                $.each(changed_ids, function(index, rId) {
                    var flow_date_from = view_nom_schedules.view_nom_schedules_grid.cells(rId, view_nom_schedules.view_nom_schedules_grid.getColIndexById("flow_date")).getValue();
                    var schedule_vol = view_nom_schedules.view_nom_schedules_grid.cells(rId, view_nom_schedules.view_nom_schedules_grid.getColIndexById("schedule_vol")).getValue();
                    var delivery_vol = view_nom_schedules.view_nom_schedules_grid.cells(rId, view_nom_schedules.view_nom_schedules_grid.getColIndexById("delivery_vol")).getValue();
                    var schedule_del_vol = view_nom_schedules.view_nom_schedules_grid.cells(rId, view_nom_schedules.view_nom_schedules_grid.getColIndexById("schedule_del_vol")).getValue();
                    var schedule_rec_vol = view_nom_schedules.view_nom_schedules_grid.cells(rId, view_nom_schedules.view_nom_schedules_grid.getColIndexById("schedule_rec_vol")).getValue();
                    var actual_rec_vol = view_nom_schedules.view_nom_schedules_grid.cells(rId, view_nom_schedules.view_nom_schedules_grid.getColIndexById("actual_rec_vol")).getValue();
                    var actual_del_vol = view_nom_schedules.view_nom_schedules_grid.cells(rId, view_nom_schedules.view_nom_schedules_grid.getColIndexById("actual_del_vol")).getValue();
                    var deal_type = view_nom_schedules.view_nom_schedules_grid.cells(rId, view_nom_schedules.view_nom_schedules_grid.getColIndexById("type")).getValue();
                    var deal_anchor_tag = view_nom_schedules.view_nom_schedules_grid.cells(rId, view_nom_schedules.view_nom_schedules_grid.getColIndexById("deal_id")).getValue();
                    var leg = view_nom_schedules.view_nom_schedules_grid.cells(rId, view_nom_schedules.view_nom_schedules_grid.getColIndexById("leg")).getValue();
                    var deal_id = $(deal_anchor_tag).attr("id");

                    grid_xml += '<GridRow deal_id="' + deal_id + '" term_start="' + formatDate(flow_date_from) 
                                + '" nom_rec_vol="' + schedule_vol + '" nom_del_vol="' + delivery_vol 
                                + '" schedule_rec_vol="' + schedule_rec_vol + '" schedule_del_vol="' + schedule_del_vol
                                + '" actual_rec_vol="' + actual_rec_vol + '" actual_del_vol="' + actual_del_vol 
                                + '" deal_type="' + deal_type + '" leg="' + leg + '"></GridRow>';
                });
                grid_xml += '</GridXML>';
                // console.log(grid_xml)
                var data = {
                            'action' : 'spa_schedules_view',
                            'flag' : 'c',
                            'xml_data' : grid_xml
                        }
                adiha_post_data('alert', data, '', '', 'save_schedule_value_callback', '', '');
            }

            function save_schedule_value_callback(result) {
                if (result[0].errorcode == 'Success')
                    view_nom_schedules_refresh();
            }
            /**
             * [Refresh function of COntract Settlement Grid]
             */
            function view_nom_schedules_refresh() {
                var randLetter = String.fromCharCode(65 + Math.floor(Math.random() * 26));
                process_id = randLetter + Date.now();
                 
                view_nom_schedules.view_nom_schedules_layout.cells('a').collapse();
                view_nom_schedules.view_nom_schedules_layout.cells('b').collapse();
                view_nom_schedules.view_nom_schedules_layout.cells('c').collapse();
                view_nom_schedules.view_nom_schedules_menu.setItemDisabled("update_del_rank");
                view_nom_schedules.view_nom_schedules_menu.setItemDisabled("delete");
                view_nom_schedules.view_nom_schedules_menu.setItemDisabled("save");
                view_nom_schedules.view_nom_schedules_layout.cells('d').progressOn();
                var date_from = view_nom_schedules.filter_form.getItemValue("date_from", true);
                var date_to = view_nom_schedules.filter_form.getItemValue("date_to", true);
                var split = date_from.split('-');
                var year = +split[0];
                var month = +split[1];
                var day = +split[2];

                var date_from_js = new Date(year, month - 1, day);

                var split = date_to.split('-');
                var year = +split[0];
                var month = +split[1];
                var day = +split[2];

                var date_to_js = new Date(year, month - 1, day);
                if (date_to_js < date_from_js) {
                    var message = '<strong>Flow Date From</strong> should be less than <strong>Flow Date To</strong>.';
                    show_messagebox(message);
                    view_nom_schedules.view_nom_schedules_layout.cells('d').progressOff();
                    return false;
                }
                
                if (view_nom_schedules.view_nom_schedules_grid) {
                    view_nom_schedules.view_nom_schedules_grid.clearAll();
                } else {
                    view_nom_schedules.view_nom_schedules_grid = view_nom_schedules.view_nom_schedules_layout.cells('d').attachGrid();
                    view_nom_schedules.view_nom_schedules_grid.setImagePath("<?php echo $image_path; ?>dhxtoolbar_web/");
                    view_nom_schedules.view_nom_schedules_grid.setHeader(get_locale_value("&nbsp;,Flow Date,Group Path,&nbsp;,&nbsp;,Deal ID,Nom Rec Vol,Shrinkage,Nom Del Vol,Sch Rec Vol,Sch Del Vol,Act Rec Vol,Act Del Vol,Rec Location,Del Location,Path,Contract,Counterparty/Pipeline,Nom Group,Path Priority,Rec Priority,Del Priority,UOM,Capacity,Action,&nbsp;,&nbsp;,&nbsp;,Type,Leg", true));
                    view_nom_schedules.view_nom_schedules_grid.setColumnIds("group_column,flow_date,group_path_name,deal_icon,rec_id,deal_id,schedule_vol,shrinkage,delivery_vol,schedule_rec_vol,schedule_del_vol,actual_rec_vol,actual_del_vol,rec_location,delivery_location,path,contract,pipeline,nom_group,priority_path,priority,delivery_priority,uom,capacity,schedule_rec_volaction,del_id,flow_date,deal,type,leg");
                    view_nom_schedules.view_nom_schedules_grid.setColTypes("ro,ro,ro,img,ro,ro,ed_v,ro,ed_v,ed_v,ed_v,ed_v,ed_v,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,combo,ro,ro,ro,ro,ro,ro");
                    view_nom_schedules.view_nom_schedules_grid.enableMultiselect(true);
                    view_nom_schedules.view_nom_schedules_grid.setNumberFormat("0,000", view_nom_schedules.view_nom_schedules_grid.getColIndexById("schedule_vol"), ".", ",");
                    view_nom_schedules.view_nom_schedules_grid.setNumberFormat("0,000.0000", view_nom_schedules.view_nom_schedules_grid.getColIndexById("shrinkage"), ".", ",");
                    view_nom_schedules.view_nom_schedules_grid.setNumberFormat("0,000", view_nom_schedules.view_nom_schedules_grid.getColIndexById("delivery_vol"), ".", ",");
                    view_nom_schedules.view_nom_schedules_grid.setNumberFormat("0,000", view_nom_schedules.view_nom_schedules_grid.getColIndexById("schedule_rec_vol"), ".", ",");
                    view_nom_schedules.view_nom_schedules_grid.setNumberFormat("0,000", view_nom_schedules.view_nom_schedules_grid.getColIndexById("schedule_del_vol"), ".", ",");
                    view_nom_schedules.view_nom_schedules_grid.setNumberFormat("0,000", view_nom_schedules.view_nom_schedules_grid.getColIndexById("actual_rec_vol"), ".", ",");
                    view_nom_schedules.view_nom_schedules_grid.setNumberFormat("0,000", view_nom_schedules.view_nom_schedules_grid.getColIndexById("actual_del_vol"), ".", ",");
                    view_nom_schedules.view_nom_schedules_grid.setColSorting("str,str,na,str,str,str,str,str,str,str,str,str,str,str,str,str,str,str,str,str,str,str,str,str,str,na,date,str,str,str");
                    view_nom_schedules.view_nom_schedules_grid.setColumnsVisibility("false,true,true,false,true,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,true,true,true,true,true,true,true");
                    view_nom_schedules.view_nom_schedules_grid.setInitWidths("0,70,170,30,10,70,90,70,90,90,90,90,90,120,120,170,80,170,85,90,85,85,70,70,70,10,10,10,10,85");
                    view_nom_schedules.view_nom_schedules_grid.attachHeader('#text_filter,#text_filter,#text_filter,,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter');
                    view_nom_schedules.view_nom_schedules_grid.init();
                    view_nom_schedules.add_context_menu();
                    
                    if (granularity = 982) {
                        view_nom_schedules.view_nom_schedules_grid.attachEvent("onRowSelect", view_nom_schedules.select_grid);
                    } else {
                        view_nom_schedules.view_nom_schedules_grid.attachEvent("onRightClick", view_nom_schedules.right_click_grid);
                    }
                    
                    view_nom_schedules.view_nom_schedules_grid.attachEvent("onSelectStateChanged", function(row_id){
                        if (has_rights_ui){
                            view_nom_schedules.view_nom_schedules_menu.setItemEnabled("update_del_rank");
                        }
                        if (has_rights_delete){
                            view_nom_schedules.view_nom_schedules_menu.setItemEnabled("delete");
                        }
                    });

                    view_nom_schedules.view_nom_schedules_grid.attachEvent("onEditCell", function(stage, rId, cInd, nValue, oValue) {
                        var delivery_vol_index = view_nom_schedules.view_nom_schedules_grid.getColIndexById("delivery_vol");
                        var scheduled_vol_index = view_nom_schedules.view_nom_schedules_grid.getColIndexById("schedule_vol");
                        var schedule_del_vol_index = view_nom_schedules.view_nom_schedules_grid.getColIndexById("schedule_del_vol");
                        var schedule_rec_vol_index = view_nom_schedules.view_nom_schedules_grid.getColIndexById("schedule_rec_vol");
                        var actual_del_vol_index = view_nom_schedules.view_nom_schedules_grid.getColIndexById("actual_del_vol");
                        var actual_rec_vol_index = view_nom_schedules.view_nom_schedules_grid.getColIndexById("actual_rec_vol");
                        var deal_type = view_nom_schedules.view_nom_schedules_grid.cells(rId, view_nom_schedules.view_nom_schedules_grid.getColIndexById("type")).getValue();
                        
                        //## Handle Volume Update privileges
                        //## Case 1. Nomination Volume & buy/sell deal
                        //## Case 2. Schedule Volume
                        //## Case 3. Actual Volume
                        var message = 'You do not have privilege to update/save data';
                        if (!has_rights_ui 
                            || (deal_type == 1 || deal_type == 3) && (cInd == delivery_vol_index || cInd == scheduled_vol_index) && !has_rights_upd_deal_vol
                            || (cInd == schedule_rec_vol_index || cInd == schedule_del_vol_index) && !has_rights_upd_sch_vol
                            || (cInd == actual_rec_vol_index || cInd == actual_del_vol_index) && !has_rights_upd_act_vol) {
                            show_messagebox(message);
                            return false;
                        }

                        if (stage == 0) {
                            if ((deal_type == 1 &&  (cInd == delivery_vol_index || cInd == schedule_del_vol_index || cInd == actual_del_vol_index)) 
                                || (deal_type == 3 && (cInd == scheduled_vol_index || cInd == schedule_rec_vol_index || cInd == actual_rec_vol_index))) {
                                return false;
                            }
                        } else  if (stage == 2) {
                            if (isNaN(nValue)) {
                                return false;
                            } else if (nValue == oValue) {
                                return false;
                            } else {
                                if (deal_type == 2) {
                                    trickle_volume(false, rId, cInd);
                                } else {
                                    view_nom_schedules.view_nom_schedules_menu.setItemEnabled("save");
                                }
                                return true;
                            }
                        }
                    });
                }

                filter_flow_date_from = view_nom_schedules.filter_form.getItemValue('date_from', true);
                filter_flow_date_to = view_nom_schedules.filter_form.getItemValue('date_to', true);
                filter_priority = view_nom_schedules.filter_form.getItemValue('priority');
                filter_pipeline = view_nom_schedules.filter_form.getItemValue('pipeline');
                filter_contract = view_nom_schedules.filter_form.getItemValue('contract');
                filter_rec_priority = view_nom_schedules.filter_form.getItemValue('rec_priority');
                filter_del_priority = view_nom_schedules.filter_form.getItemValue('del_priority');

                var grid_selected = view_nom_schedules.delivery_path_grid.getSelectedRowId();
                var path_id_arr = new Array();

                if (grid_selected != null) {
                    var grid_selected_array = grid_selected.split(',');
                    for (i = 0; i < grid_selected_array.length; i++) {
                        var tree_level = view_nom_schedules.delivery_path_grid.getLevel(grid_selected_array[i]);
                        if (tree_level == 0) {
                            var node_text = view_nom_schedules.delivery_path_grid.cells(grid_selected_array[i],0).getValue();
                            var path_id = '';
                            if (node_text == 'GROUP PATH') path_id = -1; else if (node_text == 'SINGLE PATH') path_id = -2;
                            path_id_arr.push(path_id);
                        } else if (tree_level == 1) {
                            var path_id = view_nom_schedules.delivery_path_grid.cells(grid_selected_array[i], 2).getValue();
                            path_id_arr.push(path_id);
                        }
                    }
                }

                var location_group_obj = view_nom_schedules.filter_form.getCombo('location_group');
                var location_group_id_arr = location_group_obj.getChecked();
                var location_name_obj = view_nom_schedules.filter_form.getCombo('location_name');
                var location_id_arr = location_name_obj.getChecked();
                var location_group_id = location_group_id_arr.toString().replace(/^,/, '');
                var location_id = (location_ids_temp != '') ? location_ids_temp : (location_id_arr.toString().replace(/^,/, ''));
				location_ids_temp = '';
                var filter_path_id = path_id_arr.toString();

                var transaction_type = view_nom_schedules.filter_form.getItemValue('transaction_type');

                var data = {
                    "flag": "b",
                    "action": "spa_schedules_view",
                    "flow_date_from": filter_flow_date_from,
                    "flow_date_to": filter_flow_date_to,
                    "priority_id": filter_priority,
                    "location_type": location_group_id,
                    "location": location_id,
                    "filter_pipeline": filter_pipeline,
                    "filter_contract": filter_contract,
                    "rec_priority_id": filter_rec_priority,
                    "del_priority_id": filter_del_priority,
                    "process_id" : process_id,
                    "path_id" : filter_path_id,
                    "call_from" : call_from,
                    "transaction_type": transaction_type
                };
                adiha_post_data("return_json", data, "", "", "load_grid_data");
            }

            function load_grid_data(result) {
                if (result != '[]') {
                    var schedules_json = get_grid_json($.parseJSON(result));
                    global_schedule_data = $.parseJSON(schedules_json);
                    var temp_data = global_schedule_data.data;
                    for (var i = 0; i < temp_data.length; i++) {
                        var deal_id = temp_data[i].deal_id;
                        temp_data[i].deal_id = '<a href="#" id="' + deal_id + '" onclick="view_nom_schedules.open_update_popup(' + deal_id + ')">' + deal_id + ' </a>';
                        // ## Separate Icons for different type of deals
                        if (temp_data[i].type == 1)
                            temp_data[i].deal_icon = js_image_path + 'dhxgrid_web/phys_buy_new.png^Purchase';
                        else if (temp_data[i].type == 3)
                            temp_data[i].deal_icon = js_image_path + 'dhxgrid_web/phys_sell_new.png^Sales';
                        else
                            temp_data[i].deal_icon = js_image_path + 'dhxgrid_web/transportation.png^Schedule';
                    }
                    
                    view_nom_schedules.view_nom_schedules_grid.parse(temp_data, "js");

                    view_nom_schedules.view_nom_schedules_grid.customGroupFormat = function(name, count) {
                          return name;
                    }
                    view_nom_schedules.view_nom_schedules_grid.groupBy(0);
                    view_nom_schedules.view_nom_schedules_grid.moveColumn(view_nom_schedules.view_nom_schedules_grid.getColIndexById("path"), 6);
                }

                var data = {
                    "action": "spa_schedules_view",
                    "flag": "q",
                    "process_id" : process_id
                };
                adiha_post_data("return", data, "", "", "get_grid_process_table");
                view_nom_schedules.view_nom_schedules_layout.cells('d').progressOff();
            }

            /*
            *   Trickles Down Volume Up/Down
            *   [mode] boolean wheather to trickle or not
            *   [cInd] column index which value is changed
            *   [nVlaue] new value of the cell
            *   [sugrid_obj] sub grid obj
            *   [parent_id] row id of parent grid
            */
            function trickle_volume(mode, rId, cInd) {
                var delivery_vol_index = view_nom_schedules.view_nom_schedules_grid.getColIndexById("delivery_vol");
                var scheduled_vol_index = view_nom_schedules.view_nom_schedules_grid.getColIndexById("schedule_vol");
                var schedule_del_vol_index = view_nom_schedules.view_nom_schedules_grid.getColIndexById("schedule_del_vol");
                var schedule_rec_vol_index = view_nom_schedules.view_nom_schedules_grid.getColIndexById("schedule_rec_vol");
                var actual_del_vol_index = view_nom_schedules.view_nom_schedules_grid.getColIndexById("actual_del_vol");
                var actual_rec_vol_index = view_nom_schedules.view_nom_schedules_grid.getColIndexById("actual_rec_vol");

                var group_path_name = view_nom_schedules.view_nom_schedules_grid.cells(rId, view_nom_schedules.view_nom_schedules_grid.getColIndexById("group_path_name")).getValue();
                var flow_date = view_nom_schedules.view_nom_schedules_grid.cells(rId, view_nom_schedules.view_nom_schedules_grid.getColIndexById("flow_date")).getValue();
                var deal_ref_id = view_nom_schedules.view_nom_schedules_grid.cells(rId, view_nom_schedules.view_nom_schedules_grid.getColIndexById("deal")).getValue();
                var trickle_mode = 0;

                var filtered_schedule_data = _.filter(global_schedule_data.data, function(item) {
                    return (unescapeXML(item.group_path_name) == unescapeXML(group_path_name) && item.type == 2 && item.flow_date == flow_date);
                });
                if (mode == true && (filtered_schedule_data[0].deal == deal_ref_id && (cInd == scheduled_vol_index || cInd == schedule_rec_vol_index || cInd == actual_rec_vol_index)
                        || filtered_schedule_data[filtered_schedule_data.length -1].deal == deal_ref_id && (cInd == delivery_vol_index || cInd == schedule_del_vol_index || cInd == actual_del_vol_index))) {
                    trickle_mode = 1;
                } else { trickle_mode = 0; }

                for (var i = 0; i < filtered_schedule_data.length; i++) {
                    var shrinkage = view_nom_schedules.view_nom_schedules_grid.cells(rId, view_nom_schedules.view_nom_schedules_grid.getColIndexById("shrinkage")).getValue();
                    if (cInd == scheduled_vol_index || cInd == schedule_rec_vol_index || cInd == actual_rec_vol_index) {
                        var new_rec_vol = view_nom_schedules.view_nom_schedules_grid.cells(rId, cInd).getValue();
                        var new_vol = (new_rec_vol * (1 - shrinkage));
                        var new_col_ind = (cInd == scheduled_vol_index) ? delivery_vol_index : 
                                            (cInd == schedule_rec_vol_index) ? schedule_del_vol_index : actual_del_vol_index
                        new_vol = Math.round(new_vol);
                        view_nom_schedules.view_nom_schedules_grid.cells(rId, new_col_ind).setValue(new_vol);
                        rId++;
                        if (i < filtered_schedule_data.length - 1 && trickle_mode == 1)
                            view_nom_schedules.view_nom_schedules_grid.cells(rId, cInd).setValue(new_vol);
                    } else if (cInd == delivery_vol_index || cInd == schedule_del_vol_index || cInd == actual_del_vol_index) {
                        var new_del_vol = view_nom_schedules.view_nom_schedules_grid.cells(rId, cInd).getValue();
                        var new_vol = (new_del_vol / (1 - shrinkage));
                        var new_col_ind = (cInd == delivery_vol_index) ? scheduled_vol_index : 
                                            (cInd == schedule_del_vol_index) ? schedule_rec_vol_index : actual_rec_vol_index
                        new_vol = Math.round(new_vol);
                        view_nom_schedules.view_nom_schedules_grid.cells(rId, new_col_ind).setValue(new_vol);
                        rId--;
                        if (i < filtered_schedule_data.length - 1 && trickle_mode == 1)
                            view_nom_schedules.view_nom_schedules_grid.cells(rId, cInd).setValue(new_vol);
                    }
                    view_nom_schedules.view_nom_schedules_menu.setItemEnabled("save");
                    
                    if (trickle_mode == 0) break;

                    view_nom_schedules.view_nom_schedules_grid.cells(rId, 0).cell.wasChanged = true;
                }
            }

            function get_grid_process_table(result) { 
                var process_table = result[0].process_table;
                document.getElementById("txt_process_table").value = process_table;
            }

            /**
             * Deletes all transportation deal seen in Grid.
             */
            function delete_all_deals(from_date, to_date) {
                var total_rows = view_nom_schedules.view_nom_schedules_grid.getRowsNum();
                if (total_rows == 0) {
                    var message = "Grid is empty to perform any operations.";
                    show_messagebox(message);
                    return;
                }

                var xml_data = '<Root>';
                var deal_id_check_array = [];
                view_nom_schedules.view_nom_schedules_grid.forEachRow(function(row_id) {
                    var deal_type = view_nom_schedules.view_nom_schedules_grid.cells(row_id, view_nom_schedules.view_nom_schedules_grid.getColIndexById("type")).getValue();
                    //## Transportation Deal
                    if (deal_type == 2) {
                        var deal_anchor_tag = view_nom_schedules.view_nom_schedules_grid.cells(row_id, view_nom_schedules.view_nom_schedules_grid.getColIndexById("deal_id")).getValue();
                        var deal_id = $(deal_anchor_tag).attr("id");

                        if (deal_id_check_array.indexOf(deal_id) == -1) {
                            deal_id_check_array.push(deal_id);
                            xml_data += '<DataRow deal_id="' + deal_id + '" flow_date_from="' + from_date + '" flow_date_to="' + to_date + '"></DataRow>';
                        }
                    }
                });
                
                xml_data += '</Root>';
                non_transport_deal_selected = 0;
                delete_deal(xml_data);
            }

            /**
             * Deletes the selected deal.
             */
            function delete_deals() {
                var xml_data = collect_ids(true);
                var selected_deals = view_nom_schedules.view_nom_schedules_grid.getSelectedRowId();
                if (xml_data == '' && selected_deals == null) {
                    var message = "Please select the data first.";
                    show_messagebox(message);
                    return;
                }
                delete_deal(xml_data);
            }

            var non_transport_deal_selected = 0;
            /**
             * Collect selected data in xml from grid
             */
            function collect_ids(mode) {
                var total_rows = view_nom_schedules.view_nom_schedules_grid.getRowsNum();
                if (total_rows == 0) {
                    var message = "Grid is empty to perform any operations.";
                    show_messagebox(message);
                    return;
                }
                var deal_ids = '';
                var selected_deals = view_nom_schedules.view_nom_schedules_grid.getSelectedRowId();
                var selected_deals_array = new Array();

                if (selected_deals != null) {
                    selected_deals_array = selected_deals.split(',');
                    var xml_data = '<Root>';
                    jQuery.each(selected_deals_array, function(index, row_id) {
                        var deal_type = view_nom_schedules.view_nom_schedules_grid.cells(row_id, view_nom_schedules.view_nom_schedules_grid.getColIndexById("type")).getValue();
                        var deal_term = view_nom_schedules.view_nom_schedules_grid.cells(row_id, view_nom_schedules.view_nom_schedules_grid.getColIndexById("flow_date")).getValue();
                        if (deal_type == 1 || deal_type == 3) {
                            non_transport_deal_selected = 1;
                            return false;
                        } else {
                            var deal_anchor_tag = view_nom_schedules.view_nom_schedules_grid.cells(row_id, view_nom_schedules.view_nom_schedules_grid.getColIndexById("deal_id")).getValue();
                            var deal_id = $(deal_anchor_tag).attr("id");
                            deal_ids += deal_id + ',';
                            xml_data += '<DataRow deal_id="' + deal_id + '" flow_date_from="' + formatDate(deal_term) + '" flow_date_to=""></DataRow>';
                            non_transport_deal_selected = 0;
                        }
                    });
                    xml_data += '</Root>';
                }
                if (mode) return xml_data;
                deal_ids = deal_ids.replace(/,\s*$/, "");
                return deal_ids;
            }

            /*
             *  Deal delete 
             * @param {type} result
             * @returns {undefined}
             */
            function delete_deal(xml_data) {
                if (!has_rights_delete) {
                    show_messagebox("You do not have privilege to delete");
                    return false;
                }
                
                var message = "Are you sure you want to delete?";
                confirm_messagebox(message, function() {
                    if (non_transport_deal_selected == 1) {
                        var message = "Purchase and sale deal cannot be deleted.";
                        show_messagebox(message);
                    }
                    view_nom_schedules.view_nom_schedules_layout.cells('d').progressOn();
                    data = {"action": "spa_schedules_view", "flag": "d", "xml_data": xml_data};
                    result = adiha_post_data("alert", data, "Changes have been saved successfully.", "", "callback_delete");
                });
            }
            /*
             * Callback delete
             * @param {type} result
             * @returns {undefined}
             */
            function callback_delete(result) {
                if (result[0].errorcode == 'Success') {
                    view_nom_schedules_refresh();
                }

            }
            /**
             * Create JSON object for grid.
             * @param  {[type]} grid_array [JSON]
             * @return {[type]}      [JSON object]
             */
            function get_grid_json(grid_array) {
                var total_count = grid_array.length;

                var json_data = '';
                json_data = '{"total_count":"' + total_count + '", "pos":"0", "data":[';

                var string_array = new Array();

                if (total_count > 0) {
                    _.each(grid_array, function(array_value, array_key) {
                        var string = '{ ';
                        i = 0;

                        _.each(array_value, function(value, key) {
                            if (i == 0) {
                                string += '"' + key + '":' + '"' + value + '"';
                            } else {
                                string += ',"' + key + '":' + '"' + value + '"';
                            }
                            i++;
                        });
                        string += '}';
                        string_array.push(string);
                    });
                }
                json_data += string_array.join(", \n") + "]}";
                return json_data;
            }

            /**
             * [open_update_popup Opens a deal update window]
             * @param  {[int]} deal_id [Deal Id]
             */
            view_nom_schedules.open_update_popup = function(deal_id) {
                view_nom_schedules.unload_deals_window();
                if (!blotter_window) {
                    blotter_window = new dhtmlXWindows();
                }
                var new_update_window = blotter_window.createWindow('w1', 0, 0, 400, 400);
                new_update_window.setText("Deal - " + deal_id);
                new_update_window.centerOnScreen();
                new_update_window.setModal(true);
                new_update_window.maximize();
                new_update_window.attachURL('../../../_deal_capture/maintain_deals/deal.detail.new.php', false, {deal_id: deal_id});
            }
            /**
             * [unload_deals_window Unload popup window.]
             */
            view_nom_schedules.unload_deals_window = function() {
                if (blotter_window != null && blotter_window.unload != null) {
                    blotter_window.unload();
                    blotter_window = w1 = null;
                }
            }
            
            var update_actual_window;
            /**
             * Open Acutal Volume window
             */
            function open_actual_window(deal_id, flow_date, leg) {
                if (update_actual_window != null && update_actual_window.unload != null) {
                    update_actual_window.unload();
                    update_actual_window = w1 = null;
                }

                if (!update_actual_window) {
                    update_actual_window = new dhtmlXWindows();
                }
                
                var data = {
                    deal_id: deal_id,
                    term_start: flow_date,
                    term_end: flow_date,
                    leg: leg,
                    granularity: granularity,
                    call_from: 'nomination'
                }
                
                var formatted_flow_date = dates.convert_to_user_format(flow_date);
                var win_title = 'Update Actual Volume (Deal: ' + deal_id + ', Term: ' + formatted_flow_date + ' - ' + formatted_flow_date + ')';
                var win = update_actual_window.createWindow('w1', 0, 0, 500, 500);
                win.setText(win_title);
                win.centerOnScreen();
                win.setModal(true);
                win.maximize();
                win.attachURL(app_form_path + '_deal_capture/maintain_deals/update.actual.php', false, data);

                win.attachEvent('onClose', function(w) {
                    view_nom_schedules_refresh();
                    return true;
                });
            }
        </script> 
