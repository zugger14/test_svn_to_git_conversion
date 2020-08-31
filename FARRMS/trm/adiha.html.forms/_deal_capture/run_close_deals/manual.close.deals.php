<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
</head>
    
<body>
    <?php   
    include '../../../adiha.php.scripts/components/include.file.v3.php';
    global $image_path;
    $php_script_loc = $app_php_script_loc;
    $app_user_loc = $app_user_name;

    $rights_manual_close_deals = 20013500;
    
    list (
       $has_right_manual_close_deals
    ) = build_security_rights (
       $rights_manual_close_deals
    );
    
    $namespace = 'manual_close_deals';
    $form_name = 'manual_close_deals_form';

    $json = '[
                {
                    id:             "a",
                    text:           "Apply Filters",
                    header:         true,
                    collapse:       false,
                    height:         85
                },
                {
                    id:             "b",
                    text:           "Filters",
                    header:         true,
                    collapse:       false,
                    height:         200
                },
                {
                    id:             "c",
                    text:           "Match Grid",
                    header:         true,
                    collapse:       false
                }
            ]';

    $manual_close_deals_layout_obj = new AdihaLayout();
    echo $manual_close_deals_layout_obj->init_layout('manual_close_deals_layout', '', '3E', $json, $namespace);
    
    $form_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='20013500', @template_name='ManualCloseDeals', @parse_xml=''";
    $form_arr = readXMLURL2($form_sql);
    $form_json = $form_arr[0]['form_json'];
    
    echo $manual_close_deals_layout_obj->attach_form($form_name, 'b');
    $manual_close_deals_form_obj = new AdihaForm();
    echo $manual_close_deals_form_obj->init_by_attach($form_name, $namespace);
    echo $manual_close_deals_form_obj->load_form($form_json);
    
    //Attach Menu.
    echo $manual_close_deals_layout_obj->attach_menu_cell('manual_close_menu', 'c');
    $menu_object = new AdihaMenu();

    $menu_json = '[
        {id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif", title: "Refresh"},
        {id:"match", img: "match.gif", imgdis:"match_dis.gif", text: "Match", title: "Match", enabled: "false"}
    ]';

    echo $menu_object->init_by_attach('manual_close_menu', $namespace);
    echo $menu_object->load_menu($menu_json);
    echo $menu_object->attach_event('', 'onClick', 'grid_menu_click');

    // Attach layout in cell 'C'
    $layout_json_grids = '[
        {id: "a", text: "<a class=\"undock_a undock-btn undock_custom\" style=\"float: right; cursor:pointer\" title=\"Undock\"  onClick=\" undock_window(\'a\');\"></a>Match Deals From ", header: true},
        {id: "b", text: "<a class=\"undock_a undock-btn undock_custom\" style=\"float: right; cursor:pointer\" title=\"Undock\"  onClick=\" undock_window(\'b\');\"></a>Match Deals To", header:true}
    ]';

    $inner_layout_c_obj = new AdihaLayout();
    echo $manual_close_deals_layout_obj->attach_layout_cell("manual_close_grid_layout", 'c', '2U', $layout_json_grids);
    echo $inner_layout_c_obj->init_by_attach('manual_close_grid_layout', $namespace);

    //Attach Grid :
    $manual_close_deals_from_grid = 'grid_manual_close_deals_from';
    echo $inner_layout_c_obj->attach_grid_cell($manual_close_deals_from_grid, 'a');

    $manual_close_deals_from_grid_obj = new GridTable($manual_close_deals_from_grid);
    echo $inner_layout_c_obj->attach_status_bar("a", true);
    echo $manual_close_deals_from_grid_obj->init_grid_table($manual_close_deals_from_grid, $namespace, 'n');
    echo $manual_close_deals_from_grid_obj->set_search_filter(true);
    echo $manual_close_deals_from_grid_obj->return_init();
    echo $manual_close_deals_from_grid_obj->load_grid_functions();
    echo $manual_close_deals_from_grid_obj->enable_paging(25, 'pagingArea_a', 'true');
    // echo $manual_close_deals_from_grid_obj->enable_multi_select();


    $manual_close_deals_to_grid = 'grid_manual_close_deals_to';
    echo $inner_layout_c_obj->attach_grid_cell($manual_close_deals_to_grid, 'b');

    $manual_close_deals_to_grid_obj = new GridTable($manual_close_deals_to_grid);
    echo $inner_layout_c_obj->attach_status_bar("b", true);
    echo $manual_close_deals_to_grid_obj->init_grid_table($manual_close_deals_to_grid, $namespace, 'n');
    echo $manual_close_deals_to_grid_obj->set_search_filter(true);
    echo $manual_close_deals_to_grid_obj->return_init();
    echo $manual_close_deals_to_grid_obj->load_grid_functions();
    echo $manual_close_deals_to_grid_obj->enable_paging(25, 'pagingArea_b', 'true');
    // echo $manual_close_deals_to_grid_obj->enable_multi_select();
    
    echo $manual_close_deals_layout_obj->close_layout();
    
?>
</body>
    
<script>   
    var check_status = 0;  
    $(function() {
        var has_right_manual_close_deals = Boolean('<?php echo $has_right_manual_close_deals; ?>');
        
        var function_id  = 20013500;
        var report_type = 2;
        var filter_obj = manual_close_deals.manual_close_deals_layout.cells('a').attachForm();
        var layout_cell_obj =manual_close_deals.manual_close_deals_layout.cells('b');
        var row_a, row_b
        
        load_form_filter(filter_obj, layout_cell_obj, function_id, report_type);
        attach_browse_event('manual_close_deals.manual_close_deals_form', function_id, '');

        filter_obj.attachEvent("onChange", function (name, value, state) {
           manual_close_deals.manual_close_deals_form.callEvent("onChange",['filter_call','','','']);
        });

        manual_close_deals.manual_close_deals_form.attachEvent("onChange", function (name, value, state, call_from) {
            if (name == 'filter_call') {
                check_status = 2;
            } else if (name == 'perfect_volume_match' || name == 'best_match_only') {
                check_status = check_status -1;
            }

            if ((name == 'perfect_volume_match' || name == 'best_match_only') && check_status < 0) {
               refresh_grid('d');   
            }
        });


        manual_close_deals.grid_manual_close_deals_from.attachEvent("onRowSelect", function(id,ind) {
            refresh_grid('d');
        });

        manual_close_deals.grid_manual_close_deals_to.attachEvent("onRowSelect", function(id,ind) {
            manual_close_deals.manual_close_menu.setItemEnabled('match');
        });

    });

    function grid_menu_click(id) {
        switch(id) {
            case 'refresh':
                row_a = '';
                row_b = '';
                refresh_grid('c');
                break;
            case 'match':
                dhtmlx.message({
                    type: "confirm",
                    title: "Confirmation",
                    text: "Are you sure you want to match deals?",
                    ok: "Confirm",
                    callback: function(result) {
                        if (result)
                            match_button_click();
                    }
                });
                break;
        }
    }

    function refresh_grid(flag) {
        check_status = 0;
        var status = validate_form(manual_close_deals.manual_close_deals_form);
        if (status == false) { 
            manual_close_deals.manual_close_grid_layout.cells('a').progressOff();
            return; 
        }

        var sub_id =  manual_close_deals.manual_close_deals_form.getItemValue('subsidiary_id', true);
        var stra_id = manual_close_deals.manual_close_deals_form.getItemValue('strategy_id', true);
        var book_id = manual_close_deals.manual_close_deals_form.getItemValue('book_id', true);
        var sub_book_id = manual_close_deals.manual_close_deals_form.getItemValue('subbook_id', true);
        var book_structure = manual_close_deals.manual_close_deals_form.getItemValue('book_structure', true);
        var deal_type = manual_close_deals.manual_close_deals_form.getItemValue('deal_type', true);
        var tenor_from = manual_close_deals.manual_close_deals_form.getItemValue('tenor_from', true);
        var tenor_to = manual_close_deals.manual_close_deals_form.getItemValue('tenor_to', true);
        var approach = manual_close_deals.manual_close_deals_form.getItemValue('approach', true);
        var margin_product = manual_close_deals.manual_close_deals_form.getItemValue('margin_product', true);
        var buy_sell = manual_close_deals.manual_close_deals_form.getItemValue('buy_sell', true);
        var perfect_volume_match = manual_close_deals.manual_close_deals_form.isItemChecked('perfect_volume_match') ? 'y' : 'n';
        var source_deal_header_id = null;
        var margin_product = (margin_product == '') ? null : margin_product;

        if(flag != 'c') {  // For only 'Mathc Deals To' grid
            var selected_row = manual_close_deals.grid_manual_close_deals_from.getSelectedRowId();
            var source_deal_detail_id = manual_close_deals.grid_manual_close_deals_from.cells(selected_row, 1).getValue();
        }

        var best_match_only = manual_close_deals.manual_close_deals_form.isItemChecked('best_match_only') ? 'y' : 'n';

        if (Date.parse(tenor_from) > Date.parse(tenor_to)) {
            manual_close_deals.manual_close_grid_layout.cells('a').progressOff();
            show_messagebox('<strong>Tenor From</strong> cannot be greater than <strong>Tenor To</strong>.');
            return;
        }

        var grid_param = {
            "action": "spa_match_deal_volume",
            "flag": "g",
            "sub_id" : sub_id,
            "stra_id" : stra_id,
            "book_id" : book_id,
            "sub_book_id" : sub_book_id,
            "source_deal_header_id" : source_deal_header_id,
            "deal_type" : deal_type,
            "tenor_from" : tenor_from,
            "tenor_to" : tenor_to,
            "approach" : approach,
            "buy_sell" : buy_sell,
            "margin_product" : margin_product,
            "perfect_volume_match" : perfect_volume_match,
            "source_deal_detail_id" : source_deal_detail_id,
            "best_match_only" : best_match_only
        }

        grid_param = $.param(grid_param);
        var grid_param_url = js_data_collector_url + "&" + grid_param;

        if(flag == 'c') { // 'Match Deal From' grid
            manual_close_deals.manual_close_grid_layout.cells('a').progressOn();
            manual_close_deals.grid_manual_close_deals_from.clearAll();
            manual_close_deals.grid_manual_close_deals_from.clearAndLoad(grid_param_url, function() {
                manual_close_deals.manual_close_grid_layout.cells('a').progressOff();
                if(row_a !== '')
                    manual_close_deals.grid_manual_close_deals_from.selectRow(row_a,true,true,true);
            });
            manual_close_deals.grid_manual_close_deals_to.clearAll();
            manual_close_deals.manual_close_menu.setItemDisabled('match');
        } else { // 'Match Deal To' grid
            manual_close_deals.manual_close_grid_layout.cells('b').progressOn();
            manual_close_deals.grid_manual_close_deals_to.clearAll();
            manual_close_deals.grid_manual_close_deals_to.clearAndLoad(grid_param_url, function(){
                manual_close_deals.manual_close_grid_layout.cells('b').progressOff();
                if(row_a !== '')
                    manual_close_deals.grid_manual_close_deals_to.selectRow(row_b,true,true,true);
            });
        }
    }

    function match_button_click() {
        var selected_row_a = manual_close_deals.grid_manual_close_deals_from.getSelectedRowId();
        var source_deal_detail_id = manual_close_deals.grid_manual_close_deals_from.cells(selected_row_a, 1).getValue();
        row_a = selected_row_a;

        var selected_row_b = manual_close_deals.grid_manual_close_deals_to.getSelectedRowId();
        var source_deal_detail_id_2 = manual_close_deals.grid_manual_close_deals_to.cells(selected_row_b, 1).getValue();
        row_b = selected_row_b


        data = {
            "action": "spa_match_deal_volume", 
            "flag": "m",
            "source_deal_detail_id": source_deal_detail_id, 
            "source_deal_detail_id_2": source_deal_detail_id_2
        }

        result = adiha_post_data("return_array", data, "", "","manual_close_deals.match_callback");

    }

    manual_close_deals.match_callback = function(result) {
          if (result[0][0] == "Success") {
            dhtmlx.message({
                text:result[0][4],
                expire:1000
            });
            refresh_grid('c');
            
        } else {
            show_messagebox(result[0][4]);
        }
    }

 </script>