<?php
/**
* View outstanding automated screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html> 
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
    
<body>
    <?php 
    $php_script_loc = $app_php_script_loc;
    $app_user_loc = $app_user_name;    
    $rights_view_outst_auto = 10234500;
    $rights_view_outst_auto_del = 10234511;
    $rights_view_outst_auto_approve = 10234512;
    $rights_finalize_approved_results = 10234514;
   
    list (
        $has_rights_view_outst_auto,
        $has_rights_view_outst_auto_del,
        $has_rights_view_outst_auto_approve,
        $has_rights_finalize_approved_results
    ) = build_security_rights(
        $rights_view_outst_auto,
        $rights_view_outst_auto_del,
        $rights_view_outst_auto_approve,
        $rights_finalize_approved_results
    );
    
    //JSON for Layout
    $layout_json = '[
                        {
                            id:             "a",
                            width:          300,
                            text:           "Portfolio Hierarchy",
                            header:         true,
                            collapse:       false,
                            fix_size:       [false,null]
                        },
                        {
                            id:             "b",
                            text:           "btn",

                            fix_size:       [false,null]
                        }
                        
                    ]';
                        
    $namespace = 'view_outst_ns';
    $layout = new AdihaLayout();
    $layout_name = 'view_outst_layout';
    echo $layout->init_layout($layout_name,'', '2U',$layout_json, $namespace);
    
    //Attaching Book Structue cell a
    $tree_structure = new AdihaBookStructure($rights_view_outst_auto);
    $tree_name = 'tree_portfolio_hierarchy';
    echo $layout->attach_tree_cell($tree_name, 'a');
    echo $tree_structure->init_by_attach($tree_name, $namespace);
    echo $tree_structure->set_portfolio_option(2);
    echo $tree_structure->set_subsidiary_option(2);
    echo $tree_structure->set_strategy_option(2);
    echo $tree_structure->set_book_option(2);
    echo $tree_structure->set_subbook_option(0);
    echo $tree_structure->load_book_structure_data();
    echo $tree_structure->load_bookstructure_events();
    echo $tree_structure->expand_level(0);
    echo $tree_structure->enable_three_state_checkbox();
    echo $tree_structure->load_tree_functons();
    echo $tree_structure->attach_search_filter('view_outst_ns.view_outst_layout', 'a'); 
    
    //Attach cell layout
    
    $layout_cell_json = '[
                            {
                                id:             "a",
                                text:           "Apply Filters",
                                height:         80,
                                header:         true,
                                collapse:       false,
                                fix_size:       [false,null]
                            },
                            {
                                id:             "b",
                                text:           "Filter Criteria",
                                height:         80,
                                header:         true,
                                collapse:       false,
                                fix_size:       [false,null]
                            },
                            {
                                id:             "c",
                                header:         true,
                                text:           "Gen Group"                           
                            }
                        ]';
                        
    $layout_cell_name = 'view_outst_layout_right';
    //Attach second layout in b cell
    echo $layout->attach_layout_cell($layout_cell_name,'b', '3E', $layout_cell_json);
    $layout_right = new AdihaLayout();
    //initial this new layout in namespace.
    echo $layout_right->init_by_attach($layout_cell_name, $namespace);
    
     //Attaching Filter form for grid
    $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id=". $rights_view_outst_auto . ", @template_name='ViewOutstandingAutomationResult', @group_name='General'";
    $return_value1 = readXMLURL($xml_file);
    $form_json = $return_value1[0][2];
    $form1_name = 'view_outst_form1';
    echo $layout_right->attach_form($form1_name, 'b');
    $form1 = new AdihaForm();
    echo $form1->init_by_attach($form1_name, $namespace);
    echo $form1->load_form($form_json);
    $current_date = add_date();
    $prior_month = date('Y-m-d', strtotime('last month'));
    /*
    view.edit.nom.php
    col-type= sub_row_grid
    */
   
    //Attaching layout buttons cell b
    // Attaching Toolbar
    $toolbar_json = '[
                        { id: "approve", type: "button", img: "approve.gif", imgdis: "approve_dis.gif", text: "Approve", title: "Approve", enabled:false},
                        { id: "finalize", type: "button", img: "finalize.gif", imgdis: "finalize_dis.gif", text: "Finalize", title: "Finalize", enabled:false}   
                     ]';

    $toolbar_name = 'view_outst_toolbar';
    echo $layout->attach_toolbar_cell($toolbar_name, 'b');

    $toolbar = new AdihaToolbar();
    echo $toolbar->init_by_attach($toolbar_name, $namespace);
    echo $toolbar->load_toolbar($toolbar_json);
    echo $toolbar->attach_event('', 'onClick', 'onclick_toolbar_button');    
    
    //Attaching menu in cell c at right layout.
    $menu_json = '[
                  { id: "refresh", img: "refresh.gif", text: "Refresh", title: "Refresh"},
                    {id:"t2", text:"Export", img:"export.gif", items:[
                            {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel", enabled:"true"},
                            {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF", enabled:"true"}
                            ]
                    },
                    {id:"t3", text:"Edit", img:"edit.gif", items:[
                                {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete", enabled:false}
                                ]
                    },
                    {id:"t4", text:"Reports", img:"report.gif",imgdis:"report_dis.gif", items:[
                            {id:"gen_link_report",img:"gen_link_report.gif",imgdis:"gen_link_report_dis.gif", text:"Detailed Gen Link Report",  title: "Detailed Gen Link Report", enabled:"' . $has_rights_view_outst_auto . '"},
                            {id:"forecast_report",img:"forcast_generation_report.gif",imgdis:"forcast_generation_report_dis.gif", text:"Forecast Generation Report", title: "Forecast Generation Report", enabled:"' . $has_rights_view_outst_auto . '"}
                            ]
                    },
                    {id:"expand_collapse", text:"Expand/Collapse", img:"exp_col.gif", imgdis:"exp_col_dis.gif", enabled: 1},
                    {id:"select_unselect", text:"Select/Unselect All", img:"select_unselect.gif", imgdis:"select_unselect_dis.gif", enabled: 0},
                  ]';
    
    $menu_name = 'grid_menu';
    
    //attach menu cell at right layout
    echo $layout_right->attach_menu_cell($menu_name, 'c');
    $grid_menu = new AdihaMenu();
    echo $grid_menu->init_by_attach($menu_name, $namespace);
    echo $grid_menu->load_menu($menu_json);
    echo $grid_menu->attach_event('', 'onClick', 'onclick_menu');
        
    //Attach Hedge Group grid
    $grid_obj = new AdihaGrid();
    //Attach Hedge Group grid
    $xml_file = "EXEC spa_adiha_grid 's','GenHedgeGroup'";
    $resultset_hg = readXMLURL2($xml_file);
    $hg_col_array = explode(',', $resultset_hg[0]['column_width']);
    $total_hg_width = array_sum($hg_col_array);
    $grid_json_definition_hg = json_encode($resultset_hg);
    $enable_header_menu = 'false';
    
    for($i = 1; $i < count($hg_col_array); $i++) {
        $enable_header_menu .= ',' . 'true';
    }
    //Hedge Group Detail
    $xml_file = "EXEC spa_adiha_grid 's','GenHedgeGroupDetail'";
    $resultset_hgd = readXMLURL2($xml_file);
    $hgd_col_array = explode(',', $resultset_hgd[0]['column_width']);
    $total_hgd_width = array_sum($hgd_col_array);
    
    //Increased the total width of main grid at run time. If the total column width of sub grid exceeds main grid then few column of sub grid may be invisible.
    if ($total_hg_width<$total_hgd_width) {
        $last_key = key( array_slice($hg_col_array, -1, 1, TRUE ) );
        $hg_col_array[$last_key] = $hg_col_array[$last_key] + ($total_hgd_width - $total_hg_width);
        $resultset_hg[0]['column_width'] = implode(',',$hg_col_array);
    }
    $sub_grid_json = json_encode($resultset_hgd);
    
    $grid_name = 'grd_view_hedge_group';
    echo $layout_right->attach_grid_cell($grid_name, 'c');
    echo $layout_right->attach_status_bar("c", true);
    echo $grid_obj->init_by_attach($grid_name, $namespace);
       
    echo $grid_obj->set_header($resultset_hg[0]['column_label_list']);
    echo $grid_obj->set_columns_ids($resultset_hg[0]['column_name_list']);
    echo $grid_obj->set_widths($resultset_hg[0]['column_width']);
    echo $grid_obj->set_column_types($resultset_hg[0]['column_type_list']);
    echo $grid_obj->set_sorting_preference($resultset_hg[0]['sorting_preference']);
    echo $grid_obj->set_column_auto_size(true);
    
    echo $grid_obj->set_column_visibility($resultset_hg[0]['set_visibility']);
    echo $grid_obj->enable_multi_select();
    echo $grid_obj->enable_paging(25, 'pagingArea_c', 'true'); 
    echo $grid_obj->return_init('', $enable_header_menu);
    echo $grid_obj->attach_event('', 'onSubGridCreated', $namespace . '.load_hedge_group_detail');
    echo $grid_obj->attach_event('', 'onRowSelect', 'set_privileges');
    echo $grid_obj->load_grid_functions();        
    echo '
    view_outst_ns.grd_view_hedge_group.attachEvent("onMouseOver", function(row, col) {
        col_idx = view_outst_ns.grd_view_hedge_group.getColIndexById("status");
        this.cells(row,col).cell.title = "";  
    });
    
    ';
    //This should be loaded at end
    echo $layout->close_layout();
    
    ?>
</body>
<script>
    var function_id = '<?php echo $rights_view_outst_auto; ?>';
    var has_rights_view = Boolean(<?php echo $has_rights_view_outst_auto; ?>);
    var has_rights_view_outst_auto_approve = Boolean(<?php echo $has_rights_view_outst_auto_approve; ?>);
    var has_rights_view_outst_auto_del = Boolean(<?php echo $has_rights_view_outst_auto_del; ?>);
    var has_rights_finalize_approved_results = Boolean(<?php echo $has_rights_finalize_approved_results; ?>);
    var hedge_group_detail_grid_json = <?php echo $sub_grid_json; ?>;
    var forcast_win = null;
    var hedge_status = null;
    var expand_state = 0; 

    $(function() {
        filter_obj = view_outst_ns.view_outst_layout_right.cells('a').attachForm();
        var layout_cell_obj = view_outst_ns.view_outst_layout_right.cells('b');
        load_form_filter(filter_obj, layout_cell_obj, function_id, 2, '', view_outst_ns); 
        view_outst_ns.view_outst_form1.setItemValue('as_of_date_to', '<?php echo $current_date; ?>');   
        set_default_value(); //set 'as_of_date_from' from setup menu 'Setup As of Date'

    });
 
    function open_gen_hedge_status(gen_hedge_group_id, fas_book_id) {                
        hedge_status = new dhtmlXWindows();
        var win_id = 'w1';
        var gen_status_win = hedge_status.createWindow(win_id, 0, 0, 450, 410);
        gen_status_win.setModal(true);
        
        var win_title = 'Select Hedge Relationship Type';
        var win_url = './hedge.relation.matching.php';  
            
        var params = {gen_hedge_group_id:gen_hedge_group_id,fas_book_id:fas_book_id};
        
        gen_status_win.setText(win_title);
        gen_status_win.centerOnScreen();
        //gen_status_win.maximize();
        gen_status_win.attachEvent("onClose", function(win){  
            var ifr = win.getFrame();
            var ifrWindow = ifr.contentWindow;
            var ifrDocument = ifrWindow.document;
            var status = $('textarea[name="status"]', ifrDocument).val();
            var msg = $('textarea[name="msg"]', ifrDocument).val();
            if (status == 'Success') {
                dhtmlx.message({
                    text: msg
                }); 
                view_outst_ns.refresh_grd_view_hedge_group();   
            }
            return true;
        });
        gen_status_win.attachURL(win_url, false, params);
    }
    
    function open_deal_detail(deal_id) {                
        var win_obj = new dhtmlXWindows();
        var win_id = 'w1';
        var deal_win = win_obj.createWindow(win_id, 0, 0, 450, 410);
        deal_win.setModal(true);
        
        var win_title = 'Deal - ' + deal_id;
        var win_url = app_form_path + '_deal_capture/maintain_deals/deal.detail.new.php';            
        var params = {deal_id:deal_id};
        
        deal_win.setText(win_title);
        deal_win.centerOnScreen();
        deal_win.maximize();
        deal_win.attachURL(win_url, false, params);
        
        deal_win.attachEvent("onClose", function(win){  
            var ifr = win.getFrame();
            var ifrWindow = ifr.contentWindow;
            var ifrDocument = ifrWindow.document;
            var status = $('textarea[name="txt_save_status"]', ifrDocument).val();

            if (status != 'cancel') {
                view_outst_ns.refresh_grd_view_hedge_group();
            }
            return true;
        });
    }
    
    function set_privileges() {
        if (has_rights_view_outst_auto_del) {
            view_outst_ns.grid_menu.setItemEnabled('delete');                
        } else {
           view_outst_ns.grid_menu.setItemDisabled('delete'); 
        } 
        
        //approve btn
        var allow_approve = (view_outst_ns.view_outst_form1.isItemChecked('show_approved')) ? false : has_rights_view_outst_auto_approve;  
        var allow_finalize = (view_outst_ns.view_outst_form1.isItemChecked('show_approved')) ? has_rights_finalize_approved_results : false;  
        
        if(allow_approve) {
           view_outst_ns.view_outst_toolbar.enableItem('approve');                
        } else {
           view_outst_ns.view_outst_toolbar.disableItem('approve'); 
        } 
        //finalize btn
        if(allow_finalize) {
           view_outst_ns.view_outst_toolbar.enableItem('finalize');                
        } else {
           view_outst_ns.view_outst_toolbar.disableItem('finalize'); 
        } 
        
        //forecast_report menu        
        if(has_rights_view) {
           view_outst_ns.grid_menu.setItemEnabled('forecast_report'); 
           view_outst_ns.grid_menu.setItemEnabled('gen_link_report');               
        } else {
           view_outst_ns.grid_menu.setItemDisabled('forecast_report'); 
           view_outst_ns.grid_menu.setItemDisabled('gen_link_report');  
        } 
    }
    
    function onclick_toolbar_button(id) {
        switch (id) {
            case "approve":
                approve_gen_link();
                break;
            case "finalize":
                finalize_gen_link();
                break;
        }
    }
    
    function onclick_menu(id) {
        switch(id) {
            case "refresh":
                view_outst_ns.refresh_grd_view_hedge_group();
                break;
            case "excel":
                view_outst_ns.grd_view_hedge_group.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                break;
            case "pdf":
                view_outst_ns.grd_view_hedge_group.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                break;
            case "delete":
                view_outst_ns.delete_grid_data();
                break;
            case "gen_link_report":
                show_gen_link_report();
                break;
			case "forecast_report":
                show_forecast_report();
                break;
            case "expand_collapse":
                expand_collapse();
                break;
                
            case "select_unselect":
                select_unselect_grid_data();
                break;
            default:
                dhtmlx.alert({
                    title:'Sorry! <font size="5">&#x2639 </font>',
                    type:"alert",
                    text:"Under Maintainence! We will be back soon!"
                });
                break;
        }
    }

    function expand_collapse() {
        var expand_state = view_outst_ns.grd_view_hedge_group.getUserData("","expand_state");
        if (expand_state == 0) {
                    view_outst_ns.grd_view_hedge_group.getAllRowIds().split(',').forEach(function (e) {
                    view_outst_ns.grd_view_hedge_group.cells(e, 0).open();
                    });
                    view_outst_ns.grd_view_hedge_group.setUserData("","expand_state","1");
                }
                else {
                    view_outst_ns.grd_view_hedge_group.getAllRowIds().split(',').forEach(function (e) {
                    view_outst_ns.grd_view_hedge_group.cells(e, 0).close();
                    });
                    view_outst_ns.grd_view_hedge_group.setUserData("","expand_state","0");
                }
    }
    
    view_outst_ns.refresh_grd_view_hedge_group = function() {
        var book_id = view_outst_ns.get_book();
        var as_of_date_from = view_outst_ns.view_outst_form1.getItemValue('as_of_date_from', true);
        var as_of_date_to = view_outst_ns.view_outst_form1.getItemValue('as_of_date_to', true);
        var use_create_date = (view_outst_ns.view_outst_form1.isItemChecked('use_it_as_create_date')) ? 'y' : 'n';
        var show_approved = (view_outst_ns.view_outst_form1.isItemChecked('show_approved')) ? 'y' : 'n';
        var status = (validate_form(view_outst_ns.view_outst_form1)) ? 1 : 0;
        
        if (!status) {
            return;
        }
        
        if (book_id == '') {
            dhtmlx.alert({
                title:"Alert",
                type:"alert",
                text:"Please select any book."
            });
            return;
        }

        if (as_of_date_from > as_of_date_to) {
            dhtmlx.alert({
                title:"Alert",
                type:"alert",
                text:"As of Date cannot be greater than As of Date to."
            });
            return;
        }          
 
        view_outst_ns.view_outst_layout_right.cells('c').progressOn();
        
        // load grid data
        var sql_param = {
            'action': 'spa_GetAllUnapprovedItemGen',
            'book_id': book_id,
            'as_of_date_from': as_of_date_from,
            'as_of_date_to': as_of_date_to,
            'create_ts': use_create_date,
            'show_approved': show_approved,
            'grid_type': 'g'
        };

        sql_param = $.param(sql_param);
        
        var sql_url = js_data_collector_url + "&" + sql_param;
        //view_outst_ns.grd_view_hedge_group.enableEditEvents(true,false,true);

        view_outst_ns.grd_view_hedge_group.clearAll();
        view_outst_ns.grd_view_hedge_group.load(sql_url, function(){
           view_outst_ns.view_outst_layout_right.cells('c').progressOff(); 
            var row_count = view_outst_ns.grd_view_hedge_group.getRowsNum();
            if (row_count > 0)
                view_outst_ns.grid_menu.setItemEnabled('select_unselect'); 
            else
                view_outst_ns.grid_menu.setItemDisabled('select_unselect'); 
        }); 
        view_outst_ns.grid_menu.setItemDisabled('delete'); 
        view_outst_ns.grid_menu.setItemDisabled('forecast_report');
        view_outst_ns.view_outst_toolbar.disableItem('approve'); 
        view_outst_ns.view_outst_toolbar.disableItem('finalize');
    
    } 
        
    view_outst_ns.load_hedge_group_detail = function(sub_grid_obj, id, ind) {
        sub_grid_obj.setImagePath(js_php_path + "components/lib/adiha_dhtmlx/adiha_grid_3.0/adiha_dhtmlxGrid/codebase/imgs/");
        sub_grid_obj.setHeader(hedge_group_detail_grid_json[0].column_label_list);
        sub_grid_obj.setColumnIds(hedge_group_detail_grid_json[0].column_name_list);
        sub_grid_obj.setColTypes(hedge_group_detail_grid_json[0].column_type_list);
        sub_grid_obj.setColumnsVisibility(hedge_group_detail_grid_json[0].set_visibility);
        sub_grid_obj.setInitWidths(hedge_group_detail_grid_json[0].column_width);
        sub_grid_obj.setStyle('','background-color:#F8E8B8','','background-color:#F7D97E !important');
        sub_grid_obj.init();
        sub_grid_obj.enableHeaderMenu();
       // sub_grid_obj.objBox.style.overflow="visible";
        
        var col_id = view_outst_ns.grd_view_hedge_group.getColIndexById('gen_hedge_group_id');
        var gen_hedge_group_id = view_outst_ns.grd_view_hedge_group.cells(id,col_id).getValue();
        var param = {
                "action": "spa_GetAllGenTransactionsHedgeAndItem",
                "gen_link_id": gen_hedge_group_id,
            };
        
        param = $.param(param);
        
        
        var param_url = js_data_collector_url + "&" + param;
        sub_grid_obj.clearAll();
        
        //after finished loading the data, fire sub grid reconstruct event so that the height of the parent grid is maintained when expanded.
        sub_grid_obj.load(param_url, function() {
            sub_grid_obj.callEvent("onGridReconstructed", []); 
        });

                
            
    }//ends onSubGridCreated event
    
    function get_selected_gen_ids() {
        var rid = view_outst_ns.grd_view_hedge_group.getSelectedRowId();
        if(rid == '') return;
        var rid_array = new Array();
        if (rid.indexOf(",") != -1) {
            rid_array = rid.split(',');
        } else {
            rid_array.push(rid);
        }
        
        var cid = view_outst_ns.grd_view_hedge_group.getColIndexById('gen_hedge_group_id');
        var gen_link_ids = new Array();
        $.each(rid_array, function( index, value ) {
          gen_link_ids.push(view_outst_ns.grd_view_hedge_group.cells(value,cid).getValue());
        });
        gen_link_ids = gen_link_ids.toString();
        return gen_link_ids;
    }
    
    function check_gen_link_status() {
        var rid = view_outst_ns.grd_view_hedge_group.getSelectedRowId();
        var rid_array = new Array();
        if (rid.indexOf(",") != -1) {
            rid_array = rid.split(',');
        } else {
            rid_array.push(rid);
        }
        
        var cid = view_outst_ns.grd_view_hedge_group.getColIndexById('status');
        var status = 'success';
        $.each(rid_array, function( index, value ) {
            if (view_outst_ns.grd_view_hedge_group.cells(value,cid).getValue().toUpperCase() == 'WARNING') 
                status = 'warning';
        });
        
        return status;
    }
    
    view_outst_ns.delete_grid_data = function () {
        var gen_link_ids = get_selected_gen_ids();
        var show_approved = view_outst_ns.view_outst_form1.isItemChecked('show_approved');
        var flag = (show_approved) ? 'e' : 'd';
        
        if (gen_link_ids != null) {
            dhtmlx.message({
                type: "confirm",
                title: "Confirmation",
                ok: "Confirm",
                text: "Do you want to delete the selected deal group and generated relationships?",
                callback: function(result) {
                    if (result) {                                        
                        data = {
                            "action": "spa_genhedgegroup", 
                            "gen_hedge_group_id": gen_link_ids, 
                            "flag": flag
                        }
                        adiha_post_data("return_array", data, "", "", "post_group_delete");
                        //view_outst_ns.grd_view_hedge_group.deleteSelectedRows();
                        //view_outst_ns.grid_menu.setItemDisabled('delete');
                    }
                }
            });
        }
        
    }
    
    function post_group_delete(result){console.log(result)
        if (result[0][0] == 'Success') {
            view_outst_ns.grd_view_hedge_group.deleteSelectedRows();
            view_outst_ns.grid_menu.setItemDisabled('delete');
        } else {
           dhtmlx.alert({
                title:"Alert",
                type:"alert",
                text:"Failed to delete Hedge Group."
            }); 
        }
        
    }
    
    function show_gen_link_report() {
        var book_id = view_outst_ns.get_book();
        book_id = (book_id == '') ? 'NULL' : book_id;
        var as_of_date_from = view_outst_ns.view_outst_form1.getItemValue('as_of_date_from', true);
        
        if (as_of_date_from == '') {
            dhtmlx.alert({
                title:"Alert",
                type:"alert",
                text:"As of Date field cannot be blank."
            });
            return;
        }    
            
        var param = 'call_from=Run Batch Job&gen_as_of_date=0&batch_type=r';
        var title = 'Run Batch Job';
        var exec_call = "EXEC spa_export_hedge_item  " + singleQuote(book_id) + ", " + singleQuote(as_of_date_from); 
        
        adiha_run_batch_process(exec_call, param, title);
        
    }
    
    function show_forecast_report() {
        var gen_link_ids = get_selected_gen_ids();
        var sql = "EXEC spa_get_transaction_gen_status @gen_hedge_group_id=" + singleQuote(gen_link_ids) + ",@individual='y'";
                
        //var win_obj = new dhtmlXWindows();
//        var win_id = 'w1';
//        forcast_win = win_obj.createWindow(win_id, 0, 0, 600, 600);
//        forcast_win.setModal(true);
//        
//        var win_title = 'Forecast Generation Report';
//        var win_url = '../../../../../adiha.php.scripts/dev/spa_html.php';  
//            
//        var params = {spa:sql};
//        
//        forcast_win.setText(win_title);
//        forcast_win.maximize();
//        forcast_win.attachURL(win_url, false, params);
        win_url = js_php_path + '/dev/spa_html.php?__user_name__=' + js_user_name + '&spa=' + sql + '&pop_up=true';
        
        open_window_with_post(win_url);
    }
    
    function select_unselect_grid_data() {        
            var total = view_outst_ns.grd_view_hedge_group.getRowsNum();
            var page_size = view_outst_ns.grd_view_hedge_group.rowsBufferOutSize;
            var page_no = Math.ceil(total / page_size);

            var selected_id = view_outst_ns.grd_view_hedge_group.getSelectedRowId();
            
            if (selected_id == null) {               
                var ids = view_outst_ns.grd_view_hedge_group.getAllRowIds();
                
                for (var id in ids) {
                   view_outst_ns.grd_view_hedge_group.selectRow(id, true, true, false);
                }
                view_outst_ns.grd_view_hedge_group.changePage(page_no);
                var expand_state = view_outst_ns.grd_view_hedge_group.getUserData("","expand_state");
                if(expand_state == 1){
                    view_outst_ns.grd_view_hedge_group.setUserData("","expand_state","0");
                    expand_collapse();
                }
        } else {
            view_outst_ns.grd_view_hedge_group.clearSelection();
            view_outst_ns.grid_menu.setItemDisabled('delete'); 
                view_outst_ns.grd_view_hedge_group.changePage(1);
            var expand_state = view_outst_ns.grd_view_hedge_group.getUserData("","expand_state");
            if(expand_state == 1) {
                view_outst_ns.grd_view_hedge_group.setUserData("","expand_state","0");
                expand_collapse();
        }
        }
           
            
    }

    
   
    


    //Approve
    function approve_gen_link(){
       var gen_link_ids = get_selected_gen_ids();
       
       if (gen_link_ids != null) {
            var status = check_gen_link_status();
            var proceed_approve = false;
            dhtmlx.message({
                type: "confirm",
                title: "Confirmation",
                ok: "Confirm",
                text: "Do you want to approve the relationship(s)?",
                callback: function(result) {
                    if (result) {                                        
                        if (status == 'warning') {
                            dhtmlx.message({
                                type: 'confirm',
                                title: 'Confirmation',
                                ok: 'Confirm',
                                text: 'There is a warning found on this hedging relationship.<br>Do you still want to approve this relationship?',
                                callback: function(result) {
                                    if (result) { 
                                        proceed_approve = true;
                                    }
                                }
                            });
                        } else {                             
                          proceed_approve = true;
                        }
                        
                        if (proceed_approve) {
                            var as_of_date_from = view_outst_ns.view_outst_form1.getItemValue('as_of_date_from', true);
                            var as_of_date_to = view_outst_ns.view_outst_form1.getItemValue('as_of_date_to', true);
                            
                            data = {
                                'action': 'spa_approveLinkGen', 
                                'gen_link_id': gen_link_ids, 
                                'gen_approved': 'y',
                                'as_of_date': as_of_date_from,
                                'as_of_date_to': as_of_date_to
                            }
                            adiha_post_data('return_array', data, 'The selected Gen Links has been approved.', '', 'post_approve_gen_link');
                        }
                    }
                }
            });
        }
                      
    }
    
    function post_approve_gen_link(result) {
        if (result[0][0] == 'Success') {
            dhtmlx.message(result[0][4]); 
            view_outst_ns.view_outst_form1.checkItem('show_approved');
            view_outst_ns.refresh_grd_view_hedge_group();            
        } else {
            dhtmlx.alert({
                title:"Alert",
                type:"alert",
                text:"Failed to approve Hedge Group."
            }); 
        }
    }
    
    //Finalize
    function finalize_gen_link() {
        var gen_link_ids = get_selected_gen_ids();
        var as_of_date_from = view_outst_ns.view_outst_form1.getItemValue('as_of_date_from', true);
             
        if (as_of_date_from == '') {
            show_messagebox('As of Date field cannot be blank.');
            return;
        }         
             
        var param = 'call_from=approve_gen_link&gen_as_of_date=1&batch_type=c&as_of_date=' + as_of_date_from;
        var title = 'Run Batch Job';
        var exec_call = "EXEC spa_finalize_approved_transactions NULL, NULL, " + singleQuote(js_user_name) + ", " + singleQuote(gen_link_ids); 
        adiha_run_batch_process(exec_call, param, title);
    }
    
    function set_default_value() {        
        var sp_string =  "EXEC spa_as_of_date @flag = 'a', @screen_id = " + function_id;
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
        view_outst_ns.view_outst_form1.setItemValue('as_of_date_from', custom_as_of_date);
    }
    }

    function load_business_day(return_json) { 
        var return_json = JSON.parse(return_json);
        var business_day = return_json[0].business_day;             
        
        view_outst_ns.view_outst_form1.setItemValue('as_of_date_from', business_day);
    }  
</script>
</html>