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
    $module_type = '';//"15500"; //Fas (module type)
    list($default_as_of_date_to, $default_as_of_date_from) = getDefaultAsOfDate($module_type);
    
    $rights_first_day_gain_loss = 10234600;
    $rights_first_day_gain_loss_iu = 10234610;
    $rights_first_day_gain_loss_delete = 10234612;
    
    list (
        $has_rights_first_day_gain_loss,
        $has_rights_first_day_gain_loss_iu,
        $has_rights_first_day_gain_loss_delete
    ) = build_security_rights(
        $rights_first_day_gain_loss,
        $rights_first_day_gain_loss_iu,
        $rights_first_day_gain_loss_delete
    );
    
    $namespace = 'ns_first_day_gain_loss';
    $layout = new AdihaLayout();
    //JSON for Layout
    $main_layout_json = '[
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
                            header:         false,
                            fix_size:       [false,null]
                        }
                        
                    ]';
                        
    
    $main_layout_name = 'layout_first_day_gain_loss';
    echo $layout->init_layout($main_layout_name,'', '2U',$main_layout_json, $namespace);
    
    //Attaching Book Structue cell a
    $tree_structure = new AdihaBookStructure($rights_first_day_gain_loss);
    $tree_name = 'tree_portfolio_hierarchy';
    echo $layout->attach_tree_cell($tree_name, 'a');
    echo $tree_structure->init_by_attach($tree_name, $namespace);
    echo $tree_structure->set_portfolio_option(2);
    echo $tree_structure->set_subsidiary_option(2);
    echo $tree_structure->set_strategy_option(2);
    echo $tree_structure->set_book_option(2);
    echo $tree_structure->set_subbook_option(0);//echo $tree_structure->set_subbook_option(2);
    echo $tree_structure->load_book_structure_data();
    echo $tree_structure->load_bookstructure_events();
    echo $tree_structure->expand_level(0);
    echo $tree_structure->enable_three_state_checkbox();
    echo $tree_structure->load_tree_functons();
    echo $tree_structure->attach_search_filter('ns_first_day_gain_loss.layout_first_day_gain_loss', 'a'); 
    
    //Attach cell layout
    
    $right_layout_cell_json = '[
                            {
                            id:             "a",
                            text:           "Apply Filter",
                            height:         80,
                            header:         true,
                            collapse:       false,
                            fix_size:       [false,null]
                            },
                            {
                                id:             "b",
                                text:           "Filter Criteria",
                                height:         235,
                                header:         true,
                                collapse:       false,
                                fix_size:       [false,null]
                            },
                            {
                                id:             "c",
                                header:         true,
                                text:           "<div><a class=\"undock_cell_c undock_custom\" title=\"Undock\" onClick=\"ns_first_day_gain_loss.undock_cell(\'c\')\"></a>Deals</div>"                           
                            }
                        ]';
                        
               
    $right_layout_cell_name = 'detail_layout_first_day_gain_loss';
    //Attach second layout in b cell
    echo $layout->attach_layout_cell($right_layout_cell_name,'b', '3E', $right_layout_cell_json);
    $layout_right = new AdihaLayout();
    //initial this new layout in namespace.
    echo $layout_right->init_by_attach($right_layout_cell_name, $namespace);
    
     //Attaching Filter form for grid
    $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id=". $rights_first_day_gain_loss . ", @template_name='FirstDayGainLossTreatment', @group_name='General,Treatment Detail'";
    $return_value1 = readXMLURL($xml_file);
    $form_json = $return_value1[0][2];
    $grid_json = json_decode($return_value1[1][4], true);
    
    //attach filter form
    $form_obj = new AdihaForm();
    $form_name = 'frm_first_day_gain_loss';
    echo $layout_right->attach_form($form_name, 'b');    
    echo $form_obj->init_by_attach($form_name, $namespace);
    echo $form_obj->load_form($form_json);
    
    //Attaching menus in cell c and d at right layout.
    $menu_obj = new AdihaMenu();
    $menu_json = '[
                    { id: "refresh", img: "refresh.gif", text: "Refresh", title: "Refresh"},
                    {id:"t2", text:"Export", img:"export.gif", items:[
                            {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel", enabled:"true"},
                            {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF", enabled:"true"}
                            ]
                    },
                    {id:"t3", text:"Process", img:"process.gif", items:[
                                { id: "treatment", img: "treatment.gif", imgdis: "treatment_dis.gif", text: "FDGL Treatment", title: "FDGL Treatment", enabled:false},
                                { id: "unprocess", img: "unprocess.gif", imgdis: "unprocess_dis.gif", text: "Revert", title: "Revert", enabled:false}
                            ]
                    }
                    
                  ]';
    
    
    
    //attach hedge menu cell at right layout
    $menu_name = 'grid_menu';
    echo $layout_right->attach_menu_cell($menu_name, 'c');    
    echo $menu_obj->init_by_attach($menu_name, $namespace);
    echo $menu_obj->load_menu($menu_json);
    echo $menu_obj->attach_event('', 'onClick', 'onclick_menu');
    
    //Attach grid
    $xml_file = "EXEC spa_adiha_grid 's', '" . $grid_json['grid_id'] . "'";
    $return_value = readXMLURL2($xml_file);
    $grid_json_definition_outst = json_encode($return_value);
    
    $grid_obj = new AdihaGrid();
    $grid_name = 'grid_first_day_gain_loss';
    echo $layout_right->attach_grid_cell($grid_name, 'c');
    echo $grid_obj->init_by_attach($grid_name, $namespace);
    echo $grid_obj->set_header($return_value[0]['column_label_list']);
    echo $grid_obj->set_columns_ids($return_value[0]['column_name_list']);
    echo $grid_obj->set_widths($return_value[0]['column_width']);
    //echo $grid_obj->split_grid(3); 
    echo $grid_obj->set_column_types($return_value[0]['column_type_list']);
    echo $grid_obj->set_sorting_preference($return_value[0]['sorting_preference']);
    echo $grid_obj->set_column_auto_size(true);
    echo $grid_obj->set_column_visibility($return_value[0]['set_visibility']);
    echo $grid_obj->set_search_filter(false,"#text_filter,#text_filter,#numeric_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#numeric_filter,#numeric_filter,#numeric_filter,#text_filter,#numeric_filter");
    echo $grid_obj->enable_multi_select();
    //echo $grid_obj->enable_paging(25, 'pagingArea_a'); 
    echo $grid_obj->return_init();
    echo $grid_obj->load_grid_functions();
    echo $grid_obj->attach_event('', 'onRowSelect', 'set_privileges');
    echo $grid_obj->attach_event('', 'onRowDblClicked', $namespace . '.update_process_treatment');
    
    //This should be loaded at end
    echo $layout->close_layout();
    
    ?>
</body>
<script>
    var function_id = '<?php echo $rights_first_day_gain_loss; ?>';
    var has_rights_iu =  Boolean(<?php echo $has_rights_first_day_gain_loss_iu; ?>);
    var has_rights_delete =  Boolean(<?php echo $has_rights_first_day_gain_loss_delete; ?>);
    
    $(function() {
        filter_obj = ns_first_day_gain_loss.detail_layout_first_day_gain_loss.cells('a').attachForm();
        
        var layout_cell_obj = ns_first_day_gain_loss.detail_layout_first_day_gain_loss.cells('b');  
        var layout_tree_obj = ns_first_day_gain_loss;

        load_form_filter(filter_obj, layout_cell_obj, function_id, 2, '', layout_tree_obj);   

        form_obj = 'ns_first_day_gain_loss.frm_first_day_gain_loss';
        attach_browse_event(form_obj,function_id, '', 'n');
        //set default values
        ns_first_day_gain_loss.frm_first_day_gain_loss.setItemValue('as_of_date_from', '<?php echo $default_as_of_date_from; ?>');
        ns_first_day_gain_loss.frm_first_day_gain_loss.setItemValue('as_of_date_to', '<?php echo $default_as_of_date_to; ?>');
        var load_value_sql = {
            "action": "spa_book_tag_name", 
            "flag": "s"
        };
        var load_value_result = adiha_post_data('return_array', load_value_sql, '', '', function(load_value_result) {
            ns_first_day_gain_loss.frm_first_day_gain_loss.setItemLabel('group1', load_value_result[0][0]);
            ns_first_day_gain_loss.frm_first_day_gain_loss.setItemLabel('group2', load_value_result[0][1]);
            ns_first_day_gain_loss.frm_first_day_gain_loss.setItemLabel('group3', load_value_result[0][2]);
            ns_first_day_gain_loss.frm_first_day_gain_loss.setItemLabel('group4', load_value_result[0][3]);
        });
        set_privileges();
        ns_first_day_gain_loss.detail_layout_first_day_gain_loss.cells('a').collapse();   
    });
            
    function onclick_menu(id) {
        switch(id) {
            case "refresh": 
                ns_first_day_gain_loss.refresh_fdgl_grid();
                break;
            case "excel":
                ns_first_day_gain_loss.grid_first_day_gain_loss.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                break;
            case "pdf":
                ns_first_day_gain_loss.grid_first_day_gain_loss.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                break;
            case "treatment":
                ns_first_day_gain_loss.process_treatment('i');
                break;
			case "unprocess":
                ns_first_day_gain_loss.unprocess();
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
    
    ns_first_day_gain_loss.update_process_treatment = function() {
        var row_id = ns_first_day_gain_loss.grid_first_day_gain_loss.getSelectedRowId();
        var status = get_selected_ids(ns_first_day_gain_loss.grid_first_day_gain_loss, 'status');
        if (status == 'Processed') {
            ns_first_day_gain_loss.process_treatment('u');    
        }           
    }
    
    ns_first_day_gain_loss.refresh_fdgl_grid = function() {
        var form_obj = ns_first_day_gain_loss.frm_first_day_gain_loss;
        var validation_flag = 0;
        var status = validate_form(form_obj);
        var as_of_date_from = form_obj.getItemValue('as_of_date_from', true);
        var as_of_date_to = form_obj.getItemValue('as_of_date_to', true);
        var sub_entity_id = ns_first_day_gain_loss.get_subsidiary('browser');
        var strategy_entity_id = ns_first_day_gain_loss.get_strategy('browser');
        var book_entity_id = ns_first_day_gain_loss.get_book('browser');
        var summary_option ='d';
    	var discount_option = 'u';
    	var settlement_option =  'a';
    	var report_type = 'a';
        var show_gain_loss="y";
        var trans_type=400;
        var counterparty_id = form_obj.getItemValue('counterparty_id');
        var trader_id = form_obj.getItemValue('trader_id');
        var group1 = form_obj.getItemValue('group1');
        var group2 = form_obj.getItemValue('group2');
        var group3 = form_obj.getItemValue('group3');
        var group4 = form_obj.getItemValue('group4');
        var deal_id_from = form_obj.getItemValue('deal_id_from');
        var deal_id_to = form_obj.getItemValue('deal_id_to');
        var deal_id = form_obj.getItemValue('ref_id');
        var show_only_for_deal_date = form_obj.isItemChecked('find_deal_date');
        show_only_for_deal_date = (show_only_for_deal_date) ? 'y' : 'n';
        var use_create_date = form_obj.isItemChecked('use_as_create_date');
        use_create_date = (use_create_date) ? 'y' : 'n';
        var show_prior_processed_values = 'n';
        var exceed_threshold_value='y';
        var err_msg = '';
        
        if (status) {
            if (as_of_date_from > as_of_date_to) {    
                err_msg = 'As of Date From should be greater than As of Date To.';
                validation_flag = 1;
                dhtmlx.alert({
                        title: 'Alert',
                        type: 'alert',
                        text: err_msg
                    });
                
            } else if (group1 == '' && group2 == '' && group3 == '' && group4 == '' && book_entity_id == '') {    
                err_msg = 'Please select at least a Book Structure or Group.';
                validation_flag = 1;
                dhtmlx.alert({
                        title: 'Alert',
                        type: 'alert',
                        text: err_msg
                    });
                
            }
        }
        
        if (validation_flag == 1) {
            return;
        } 
        group1 = (group1 == '') ? 'NULL' : group1;
        group2 = (group2 == '') ? 'NULL' : group2;
        group3 = (group3 == '') ? 'NULL' : group3;
        group4 = (group4 == '') ? 'NULL' : group4;
        deal_id_from = (deal_id_from == '') ? 'NULL' : deal_id_from;
        deal_id_to = (deal_id_to == '') ? 'NULL' : deal_id_to;
        deal_id = (deal_id == '') ? 'NULL' : deal_id;
        counterparty_id = (counterparty_id == '') ? 'NULL' : counterparty_id;
        trader_id = (trader_id == '') ? 'NULL' : trader_id;
        
        var sql_param = {
                'action': 'spa_Create_MTM_Period_Report',
                'as_of_date': as_of_date_to,
                'sub_entity_id': sub_entity_id,
                'strategy_entity_id': strategy_entity_id,
                'book_entity_id': book_entity_id,
                'discount_option': discount_option,
                'settlement_option': settlement_option,
                'report_type': report_type,
                'summary_option': summary_option,
                'counterparty_id': counterparty_id,
                'previous_as_of_date': as_of_date_from,
                'trader_id': trader_id,
                'source_system_book_id1': group1,  
                'source_system_book_id2': group2,  
                'source_system_book_id3': group3,  
                'source_system_book_id4': group4,     
                'show_firstday_gain_loss': show_gain_loss,
                'transaction_type': trans_type,
                'deal_id_from': deal_id_from,  
                'deal_id_to': deal_id_to,
                'deal_id': deal_id,
                'threshold_values': 'NULL',
                'show_prior_processed_values': show_prior_processed_values,
                'exceed_threshold_value': exceed_threshold_value,
                'show_only_for_deal_date': show_only_for_deal_date,
                'use_create_date': use_create_date ,           
                'grid_type': 'g'
            };
        
        sql_param = $.param(sql_param);
        
        var sql_url = js_data_collector_url + "&" + sql_param;
        
        ns_first_day_gain_loss.grid_first_day_gain_loss.clearAll();
        ns_first_day_gain_loss.grid_first_day_gain_loss.load(sql_url, function(){
            ns_first_day_gain_loss.detail_layout_first_day_gain_loss.cells('b').collapse();
            ns_first_day_gain_loss.grid_first_day_gain_loss.filterByAll();
        }); 
        ns_first_day_gain_loss.grid_menu.setItemDisabled('treatment'); 
        ns_first_day_gain_loss.grid_menu.setItemDisabled('unprocess');          
    }
        
    var new_win;
    ns_first_day_gain_loss.process_treatment = function(mode) {
        var grid_obj = ns_first_day_gain_loss.grid_first_day_gain_loss;
        var deal_id = get_selected_ids(grid_obj, 'source_deal_header_id');
        
        var pnl_date = get_selected_ids(grid_obj, 'pnl_as_of_date');
        pnl_date = dates.convert_to_sql(pnl_date);
        var pnl_value = get_selected_ids(grid_obj, 'pnl');
        var fas_deal_type_id = get_selected_ids(grid_obj, 'fas_deal_type_id');
        var params = {source_deal_header_id:deal_id,pnl_date:pnl_date,pnl_value:pnl_value,fas_deal_type_id:fas_deal_type_id,mode:mode};
        var width = 700;
        var height = 410;
        var win_title = 'FDGL Treatment';
        var win_url = 'first.day.gain.loss.iu.php';
        
        if (!new_win) {
            new_win = new dhtmlXWindows();
        }
        
        var win = new_win.createWindow('w1', 0, 0, width, height);
        win.setText(win_title);
        win.centerOnScreen();
        win.setModal(true);
        win.button('minmax').hide();
        win.button('park').hide();        
        win.attachURL(win_url, false, params);

        win.attachEvent('onClose', function(w) { 
            var ifr = w.getFrame();
            var ifrWindow = ifr.contentWindow;
            var ifrDocument = ifrWindow.document;
            var success_status = $('textarea[name="success_status"]', ifrDocument).val();
            if (success_status == 'Success') {
                dhtmlx.message('Data saved successfully.');
                ns_first_day_gain_loss.refresh_fdgl_grid();
            }
            
            return true;
        });
        
    }
    
    
    ns_first_day_gain_loss.unprocess = function() {
        //spa_first_day_gain_loss_decision
        var ids = get_selected_ids(ns_first_day_gain_loss.grid_first_day_gain_loss, 'source_deal_header_id');
        
        if (ids != null) {
         	dhtmlx.message({
                    type: "confirm",
                    title: "Confirmation",
                    ok: "Confirm",
                    text: "Are you sure you want to revert?",
                    callback: function(result) {    
                        if (result) {                            
                        data = {
                            "action": "spa_first_day_gain_loss_decision",
                            "flag": "d",
                            "source_deal_header_id": ids
                        }                                                    
                        adiha_post_data("return_array", data, "", "","post_unprocess_treatment");
                   }
                }
    		});
        }
    }
    
    function post_unprocess_treatment() {
        dhtmlx.message('Process has been successfully reverted.');
        ns_first_day_gain_loss.refresh_fdgl_grid();
    }
    
    function get_selected_ids(grid_obj, column_name) {
        var rid = grid_obj.getSelectedRowId();
        if (rid == '' || rid == null) {
            //alert('Link id is null'); 
            return false;
        }
        var rid_array = new Array();
        if (rid.indexOf(",") != -1) {
            rid_array = rid.split(',');
        } else {
            rid_array.push(rid);
        }
        
        var cid = grid_obj.getColIndexById(column_name);
        var selected_ids = new Array();
        $.each(rid_array, function( index, value ) {
          selected_ids.push(grid_obj.cells(value,cid).getValue());
        });
        selected_ids = selected_ids.toString();
        return selected_ids;
    }
    
    function set_privileges() {
        var ids = ns_first_day_gain_loss.grid_first_day_gain_loss.getSelectedRowId();
        var has_rights_process_treatment = has_rights_iu;
        var has_rights_unprocess_treatment = has_rights_delete;
        
        if (ids == null || ids.indexOf(',') != -1) {
            has_rights_process_treatment = false;
            has_rights_unprocess_treatment = false;
        } else {
            // status = get_selected_ids(ns_first_day_gain_loss.grid_first_day_gain_loss, 'status');
            var changed_ids = ids.split(',');
            var status;
            $.each(changed_ids, function(index, value) {
                var status_index = ns_first_day_gain_loss.grid_first_day_gain_loss.getColIndexById('status');
                status = ns_first_day_gain_loss.grid_first_day_gain_loss.cells(value, status_index).getValue();
            });
            if (status == 'Processed') {
                has_rights_process_treatment = false;
            } else {
                has_rights_unprocess_treatment = false;
            }         
        }
        
        if (has_rights_process_treatment) {
            ns_first_day_gain_loss.grid_menu.setItemEnabled('treatment');
        } else {
            ns_first_day_gain_loss.grid_menu.setItemDisabled('treatment');
        }
        if (has_rights_unprocess_treatment) {
            ns_first_day_gain_loss.grid_menu.setItemEnabled('unprocess');
        } else {
            ns_first_day_gain_loss.grid_menu.setItemDisabled('unprocess');
        }
        
    }
    
    ns_first_day_gain_loss.undock_cell = function(val) {
        var layout_obj = ns_first_day_gain_loss.detail_layout_first_day_gain_loss; 
        layout_obj.cells(val).undock(300, 300, 900, 700);
        layout_obj.dhxWins.window(val).button("park").hide();
        layout_obj.dhxWins.window(val).maximize();
        layout_obj.dhxWins.window(val).centerOnScreen();
        ns_first_day_gain_loss.on_undock_event(val);
    }
    
    /**
     * [on_undock_event On undock event]
     * @param  {[type]} id [Cell id]
     */
    ns_first_day_gain_loss.on_undock_event = function(id) {
        if (id == 'c') {
            $(".undock_cell_c").hide();         
        }            
    }
</script>
</html>