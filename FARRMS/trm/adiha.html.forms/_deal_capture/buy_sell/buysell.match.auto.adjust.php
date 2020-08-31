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
    $php_script_loc = $app_php_script_loc;
    $application_function_id = 10105003; 
    $namespace = 'buy_deal_adjustment';

    $deal_id = (isset($_REQUEST["deal_id"]) && $_REQUEST["deal_id"] != '') ? get_sanitized_value($_REQUEST["deal_id"]) : 'NULL';
    $detail_id = (isset($_REQUEST["sell_deal_detail_id"]) && $_REQUEST["sell_deal_detail_id"] != '') ? get_sanitized_value($_REQUEST["sell_deal_detail_id"]) : 'NULL';
    $effective_date = (isset($_REQUEST["effective_date"]) && $_REQUEST["effective_date"] != '') ? get_sanitized_value($_REQUEST["effective_date"]) : 'NULL';

    $layout_json = "[
                    {
                        id:             'a',
                        text:           'Buy Deal',
                        width:          400,
                        collapse:       false,
                        fix_size:       [false, null]
                    }
                    ]";

    $toolbar_json =  '[
            {id:"add", text:"Add", img:"tick.gif", imgdis:"tick_dis.gif", title: "Add", enabled:"true"}                                 
         ]';

    $layout_obj = new AdihaLayout();
    echo $layout_obj->init_layout('layout', '', '1C', $layout_json, $namespace);
    echo $layout_obj->attach_menu_cell('menu', 'a');
    echo $layout_obj->attach_tree_cell('tree', 'a');

    $menu_obj = new AdihaMenu();
    echo $menu_obj->init_by_attach('menu', $namespace);
    echo $menu_obj->load_menu($toolbar_json);
    echo $menu_obj->attach_event('', 'onClick', $namespace . '.menu_click');

    $grid_obj = new AdihaGrid();
    $grid_name = 'sell_deal_grid';

    echo $layout_obj->attach_grid_cell($grid_name, 'a');  
    echo $layout_obj->attach_status_bar('a', true); 
    $xml_file = "EXEC spa_adiha_grid 's','BuySellMatchDealsetIU'";
    $resultset = readXMLURL2($xml_file);
    //ob_clean(); var_dump($resultset); die();
    echo $grid_obj->init_by_attach($grid_name, $namespace);    
    echo $grid_obj->set_header($resultset[0]['column_label_list']);
    echo $grid_obj->set_column_alignment($resultset[0]['column_alignment']);
    echo $grid_obj->set_columns_ids($resultset[0]['column_name_list']);
    echo $grid_obj->set_widths($resultset[0]['column_width']);
    echo $grid_obj->set_column_types($resultset[0]['column_type_list']);
    echo $grid_obj->set_sorting_preference($resultset[0]['sorting_preference']);
    echo $grid_obj->set_column_auto_size(true);
    echo $grid_obj->set_column_visibility($resultset[0]['set_visibility']);
    echo $grid_obj->enable_column_move();
    echo $grid_obj->enable_multi_select(true);
    echo $grid_obj->set_date_format($date_format, "%Y-%m-%d");
    echo $grid_obj->enable_paging(100, 'pagingArea_a');
    echo $grid_obj->set_search_filter(true); 
    echo $grid_obj->split_grid('1');
    //echo $grid_obj->load_grid_data($grid_data, 'g');
    echo $grid_obj->return_init();
    //echo $grid_obj->attach_event('', 'onSelectStateChanged', $namespace . '.set_right_dealset_menu_privileges');
	echo $grid_obj->enable_filter_auto_hide();
    echo $layout_obj->close_layout();
?>
</body>
<script type="text/javascript">
    var deal_id = '<?php echo $deal_id; ?>';
    var effective_date = '<?php echo $effective_date; ?>';
    var detail_id = '<?php echo $detail_id; ?>';

    $(function() {
        buy_deal_adjustment.menu.setItemDisabled("add");
        buy_deal_adjustment.menu.setItemText("add", "OK");
        buy_deal_adjustment.layout.progressOn();
        //buy_deal_adjustment.menu.setItemImage("add", img, imgDis);
        buy_deal_adjustment.sell_deal_grid.attachEvent("onRowSelect", function(id,ind){
            buy_deal_adjustment.menu.setItemEnabled("add");
        });

        buy_deal_adjustment.sell_deal_grid.attachEvent("onXLE", function(grid_obj,count){
             buy_deal_adjustment.layout.progressOff();
        });

        buy_deal_adjustment.sell_deal_grid.attachEvent("onSelectStateChanged", function(id){
            buy_deal_adjustment.menu.setItemDisabled("add");
        });
        
        var xml = '<Root><FormXML filter_mode="a" buy_sell_id="b" view_deleted="n" show_unmapped_deals="n" view_voided="n" view_detail="y"></FormXML></Root>';
        var grid_data = "EXEC spa_buy_sell_match @flag='g', @xmlValue='" + xml + "', @source_deal_header_id=" + deal_id +  ", @include_expired_deals='n', @show_all_deals='n', @effective_date='" + effective_date + "', @sell_deal_detail_id=" + detail_id + ", @volume_match ='p'";
        
        var sql_param = {
            "sql": grid_data,
            "grid_type": "g"
        };
        sql_param = $.param(sql_param);
        var sql_url = js_data_collector_url + "&" + sql_param;
        buy_deal_adjustment.sell_deal_grid.clearAndLoad(sql_url);

    });

    buy_deal_adjustment.menu_click = function(id) {
        switch(id) {
            case 'add':
                var selected_row = buy_deal_adjustment.sell_deal_grid.getSelectedRowId();
                selected_row = selected_row.split(",");
                var existing_deals = new Array();
                for (i = 0; i < selected_row.length; i++) {
                    var row_data = buy_deal_adjustment.sell_deal_grid.getRowData(selected_row[i]);
                    // Get inner HTML text
                    var temp_div_element = document.createElement("div");
                    temp_div_element.innerHTML = row_data["ref_id"];
                    row_data["ref_id"] = temp_div_element.innerText;

                    parent.buy_sell_deal_match_ui.right_grid_ui.forEachRow(function(row_id) {
                        var parent_row_data = parent.buy_sell_deal_match_ui.right_grid_ui.getRowData(row_id);

                        if(parent_row_data.source_deal_header_id ==row_data.source_deal_header_id && parent_row_data.term_start ==row_data.term_start && parent_row_data.term_end == row_data.term_end && parent_row_data.leg == row_data.leg && row_data.sequence_from ==  parent_row_data.sequence_from) {
                            existing_deals.push(parent_row_data.source_deal_header_id);
                        }
                    });

                    if (existing_deals.length == 0) {
                        var newId = (new Date()).valueOf();
                        parent.buy_sell_deal_match_ui.right_grid_ui.addRow(newId,"");
                        parent.buy_sell_deal_match_ui.right_grid_ui.setRowData(newId, row_data);
                    } else {
                        dhtmlx.alert({
                            title:'Alert',
                            type:"alert-error",
                            text:"Deal ID " + row_data.source_deal_header_id + " has already been added."
                        });
                        parent.buy_sell_deal_match_ui.load_match_grids();
                        return;
                    }
                }
                parent.dhxWins.window('w1').close();
                break;
            default:
                dhtmlx.alert({
                    title:'Sorry! <font size="5">&#x2639 </font>',
                    type:"alert-error",
                    text:"Event not defined."
                });
                break;
        }

    }
</script>
</html>