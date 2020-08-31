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
    $app_user_loc = $app_user_name;

    
    $title = 'Deal Match';  
    
    $filter_application_function_id = 20004700;
    $application_function_id_filter1 = 20004703;
    $application_function_id_filter2 = 20004704;

    $rights_deal_match = 20004700;
    $rights_deal_match_iu = 20004701;
    $rights_deal_match_delete = 20004702;
    
    list (
        $has_rights_deal_match,
        $has_rights_deal_match_iu,
        $has_rights_deal_match_delete
    ) = build_security_rights(
        $rights_deal_match,
        $rights_deal_match_iu,
        $rights_deal_match__delete
    );
        
    $namespace = 'link_ui_insert';

    $layout_obj = new AdihaLayout();
    
    
    $enable = 'true';

    $layout_json = '[
                        {id: "a", height:250, text: "Dealset 1", header: true},                        
                        {id: "b", text: "Dealset 2",header: true, collapse: false, fix_size: [false,null]},         
                        {id: "c", text: "Grid 1", header: false},
                    ]';
    
    $patterns = '3J';

    $layout_name = 'layout_link_ui_insert';
    echo $layout_obj->init_layout($layout_name, '', $patterns, $layout_json, $namespace);

    /*
    $layout_json_inner1 = '[
                    {id: "a", height:300, text: "Dealset 1", header: true},
                    {id: "b", text: "Grid 1", header: false},
                ]';
    
    $patterns_inner = '2E';

    $layout_name_inner1 = 'layout_link_ui_insert_inner1';
    $inner_layout_obj1 = new AdihaLayout();
    echo $layout_obj->attach_layout_cell($layout_name_inner1, 'a', "2E", $layout_json_inner1);
    echo $inner_layout_obj1->init_by_attach($layout_name_inner1, $namespace);
    */

   $layout_json_inner2 = '[
                    {id: "a",height:250, text: "Dealset 2", header: true},
                    {id: "b", text: "Grid 2", header: false},
                ]';
    
    $patterns_inner = '2E';

    $layout_name_inner2 = 'layout_link_ui_insert_inner2';
    $inner_layout_obj2 = new AdihaLayout();
    echo $layout_obj->attach_layout_cell($layout_name_inner2, 'b', $patterns_inner, $layout_json_inner2);
    echo $inner_layout_obj2->init_by_attach($layout_name_inner2, $namespace);
    

    /***Dealset 1***/
    $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id=". $application_function_id_filter1 . ", @template_name='DealMatchFilter1', @group_name='Dealset1Filter'";
    $return_value = readXMLURL($xml_file);
    $form_json = $return_value[0][2];
    
    $filter_name = 'filter_Dealset1';
    echo $layout_obj->attach_form($filter_name, 'a');
    $filter_obj = new AdihaForm();
    echo $filter_obj->init_by_attach($filter_name, $namespace);
    echo $filter_obj->load_form_filter($namespace, $filter_name, $layout_name, 'a', $application_function_id_filter1, 2);
    echo $filter_obj->load_form($form_json);


    $grid_obj = new AdihaGrid();
    $grid_name = 'left_grid';
    echo $layout_obj->attach_grid_cell($grid_name, 'c');    
    $xml_file = "EXEC spa_adiha_grid 's','DealMatchDealset'";
    $resultset = readXMLURL2($xml_file);
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
    echo $grid_obj->set_search_filter(true); 
    //echo $grid_obj -> split_grid('1');
    echo $grid_obj->return_init();

    echo $grid_obj->attach_event('', 'onSelectStateChanged', $namespace . '.left_grid_row_state_change');
    echo $grid_obj->attach_event('', 'onRowSelect', $namespace . '.grid_row_select');
    echo $grid_obj->attach_event('', 'onBeforeSelect', $namespace . '.left_grid_before_row_select');
    /***Dealset 1 END***/
    
    /********Dealset 2**********/

    $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id=". $application_function_id_filter2 . ", @template_name='DealMatchFilter2', @group_name='Dealset2Filter'";
    $return_value = readXMLURL($xml_file);
    $form_json = $return_value[0][2];
   
    $filter_name2 = 'filter_Dealset2';
    echo $inner_layout_obj2->attach_form($filter_name2, 'a');
    $filter_obj2 = new AdihaForm();
    echo $filter_obj2->init_by_attach($filter_name2, $namespace);
    echo $filter_obj2->load_form_filter($namespace, $filter_name2, $layout_name_inner2, 'a', $application_function_id_filter2, 2);
    echo $filter_obj2->load_form($form_json);


    $grid_obj = new AdihaGrid();
    $grid_name = 'right_grid';
    echo $inner_layout_obj2->attach_grid_cell($grid_name, 'b');    
    $xml_file = "EXEC spa_adiha_grid 's','DealMatchDealset'";
    $resultset = readXMLURL2($xml_file);
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
    echo $grid_obj->set_search_filter(true); 
    //echo $grid_obj -> split_grid('1');
    echo $grid_obj->return_init();

    echo $grid_obj->attach_event('', 'onSelectStateChanged', $namespace . '.right_grid_row_state_change');
    echo $grid_obj->attach_event('', 'onRowSelect', $namespace . '.grid_row_select');
    echo $grid_obj->attach_event('', 'onBeforeSelect', $namespace . '.right_grid_before_row_select');
    
    
    /********Dealset 2 END**********/

    echo $layout_obj->close_layout(); 
    ?>
</body>
<script>
    var filter_application_function_id = '<?php echo $filter_application_function_id;?>';
    left_selected_grid_ids = '';
    right_selected_grid_ids = '';

    $(function() {
        attach_browse_event('link_ui_insert.filter_Dealset1',filter_application_function_id);
        attach_browse_event('link_ui_insert.filter_Dealset2',filter_application_function_id);

        link_ui_insert.left_grid.setEditable(false);
        link_ui_insert.right_grid.setEditable(false);
        
        link_ui_insert.layout_link_ui_insert.attachEvent("onResizeFinish", function(){
            setTimeout(function() {link_ui_insert.layout_link_ui_insert.cells('a').setWidth((link_ui_insert.layout_link_ui_insert.cells('a').getWidth() + link_ui_insert.layout_link_ui_insert.cells('b').getWidth())/2) }, 5);           
        });
        
        link_ui_insert.left_grid.attachEvent("onXLE", function(grid_obj,count){
            link_ui_insert.post_grid_XLE(grid_obj,1);
        });

        link_ui_insert.right_grid.attachEvent("onXLE", function(grid_obj,count){
            link_ui_insert.post_grid_XLE(grid_obj,2);
        });

        link_ui_insert.left_grid.attachEvent("onScroll", function(sLeft,sTop){
            $('#footer_div1').css('padding-left',sLeft);
        });

        link_ui_insert.right_grid.attachEvent("onScroll", function(sLeft,sTop){
            $('#footer_div2').css('padding-left',sLeft);
        });
        

    })

    link_ui_insert.load_match_grids = function() {
        left_selected_grid_ids = '';
        var validate_return1 = validate_form(link_ui_insert.filter_Dealset1);
        var validate_return2 = validate_form(link_ui_insert.filter_Dealset2);
    
        if (validate_return1 === false || validate_return2 === false) {
            parent.enable_disable_deal_match_menu('refresh',true);
            parent.enable_disable_deal_match_menu('match',true);
            parent.enable_disable_deal_match_menu('process',true);
            return;
        }

        link_ui_insert.layout_link_ui_insert.cells("a").collapse();
        link_ui_insert.layout_link_ui_insert_inner2.cells("a").collapse();

        link_ui_insert.layout_link_ui_insert.cells('c').progressOn();
        link_ui_insert.layout_link_ui_insert_inner2.cells('b').progressOn();

        for (i=1; i<=2; i++) {            
            var attached_obj = (i==1) ? link_ui_insert.filter_Dealset1 : link_ui_insert.filter_Dealset2;
            var attached_grid = (i==1) ? link_ui_insert.left_grid : link_ui_insert.right_grid;

            if ($('#mt_q'+i).length == 1) {
                attached_grid.detachFooter(0);
            }

            var filter_xml = "<Root><FormXML ";

            var filter_data = attached_obj.getFormData();
			
			var volume_min = 'NULL';
			var volume_max = 'NULL';
			var technology = 'NULL';
			var country = 'NULL';
			var label = 'NULL';
            var not_technology = 'NULL';
            var not_country = 'NULL';
            var region_id = 'NULL';
            var not_region_id = 'NULL';

            for (var a in filter_data) {
                field_label = a;
                field_label = (i == 2) ? field_label.replace('2','') : field_label;
				
				if (field_label == 'volume_max') {
					field_value = filter_data[a];
					if (field_value != '' && field_value != null) volume_max = field_value;
					continue;
				}
				
				if (field_label == 'volume_min') {
					field_value = filter_data[a];
					if (field_value != '' && field_value != null) volume_min = field_value;
					continue;
				}
				
				if (field_label == 'technology') {
					field_value = filter_data[a];
					if (field_value != '' && field_value != null) technology = field_value;
					continue;
				}

                if (field_label == 'not_technology') {
                    field_value = filter_data[a];
                    if (field_value != '' && field_value != null) not_technology = field_value;
                    continue;
                }
				
				if (field_label == 'country') {
					field_value = filter_data[a];
					if (field_value != '' && field_value != null) country = field_value;
					continue;
				}

                if (field_label == 'not_country') {
                    field_value = filter_data[a];
                    if (field_value != '' && field_value != null) not_country = field_value;
                    continue;
                }
				
				if (field_label == 'label') {
					field_value = filter_data[a];
					if (field_value != '' && field_value != null) label = field_value;
					continue;
				}
				
                if (field_label == 'region_id') {
                                    field_value = filter_data[a];
                                    if (field_value != '' && field_value != null) region_id = field_value;
                                    continue;
                                }

                if (field_label == 'not_region_id') {
                    field_value = filter_data[a];
                    if (field_value != '' && field_value != null) not_region_id = field_value;
                    continue;
                }
                
                if (field_label == 'apply_filters' || field_label == 'book_structure' || field_label == 'subsidiary_id' || field_label == 'strategy_id' || field_label == 'book_id' || field_label == 'volume_min'  || field_label == 'volume_max') {
                    continue;
                 }
                    field_value = filter_data[a];
                    if (attached_obj.getItemType(a) == 'calendar') {
                        field_value = attached_obj.getItemValue(a, true);
                    } else if (field_label  == 'subbook_id') {
                        field_label = 'sub_book_ids';
                    }
                    filter_xml += " " + field_label + "=\"" + field_value + "\"";
                
            }

            filter_xml += ' filter_mode="a"  trader_id="" contract_id="" broker_id="" source_deal_header_id_from="" source_deal_header_id_to="" deal_id="" view_deleted="n" show_unmapped_deals="n" generator_id="" location_group_id="" location_id="" template_id="" Index_group_id="" formula_curve_id="" formula_id="" deal_type_id="" deal_sub_type_id="" field_template_id="" physical_financial_id="" product_id="" internal_desk_id=""  settlement_date_from="" settlement_date_to="" payment_date_from="" payment_date_to="" deal_status="" confirm_status_type="" calc_status="" invoice_status="" deal_locked="" create_user = "" update_ts_from="" update_ts_to="" update_user="" book_ids="" view_voided="n" source_system_book_id1="" source_system_book_id2="" source_system_book_id3="" source_system_book_id4="" view_detail="y" ';

            filter_xml += "></FormXML></Root>";
			
			volume_min = (volume_min != 'NULL') ? "'" + volume_min + "'" : 'NULL';
			volume_max = (volume_max != 'NULL') ? "'" + volume_max + "'" : 'NULL';
			technology = (technology != 'NULL') ? "'" + technology + "'" : 'NULL';
            not_technology = (not_technology != 'NULL') ? "'" + not_technology + "'" : 'NULL';
			country = (country != 'NULL') ? "'" + country + "'" : 'NULL';
            not_country = (not_country != 'NULL') ? "'" + not_country + "'" : 'NULL';
			label = (label != 'NULL') ? "'" + label + "'" : 'NULL';
			
			region_id = (region_id != 'NULL') ? "'" + region_id + "'" : 'NULL';
            not_region_id = (not_region_id != 'NULL') ? "'" + not_region_id + "'" : 'NULL';
            var sql_stmt = "EXEC spa_deal_match @flag = 'g', @xmlValue = ' " + filter_xml + "', @volume_max=" + volume_max + ", @volume_min=" + volume_min + ", @technology=" + technology + ", @country=" + country + ", @label=" + label + ", @not_technology=" + not_technology + ", @not_country=" + not_country + ", @region_id=" + region_id + ", @not_region_id=" + not_region_id;
							
            var sql_param = {
                    "sql":sql_stmt,
                    //"grid_type":"g",
                    "grid_type":"tg",
                    "grouping_column":"ext_deal_id",
                    "grouping_type" : 3
                };
            sql_param = $.param(sql_param);
            var sql_url = js_data_collector_url + "&" + sql_param;

            attached_grid.clearAndLoad(sql_url);

            //attached_grid.groupBy(0,["#title","","","","","","","","","","","#stat_total","","","","#stat_average","#stat_average"]);

            
        }
    }

    link_ui_insert.post_grid_XLE = function(grid_obj,set) {
        var actual_volume_col_index = grid_obj.getColIndexById("actual_volume");
        var matched_col_index = grid_obj.getColIndexById("matched");
        var remaining_col_index = grid_obj.getColIndexById("remaining");
        var price_col_index = grid_obj.getColIndexById("price");
        var vp_value_col_index = grid_obj.getColIndexById("vp_value");

        grid_obj.forEachRow(function(id){
            if (grid_obj.hasChildren(id)) {
                var childs = grid_obj.getSubItems(id);

                var child1 = childs.split(',')[0];
                
                grid_obj.forEachCell(child1,function(cellObj,ind){
                    var col_id = grid_obj.getColumnId(ind);
                    if (col_id == 'product' || col_id == 'commodity' || col_id == 'buy_sell' || col_id == 'Counterparty' || col_id == 'expiration_date' || col_id == 'uom' || col_id == 'currency') {
                        grid_obj.cells(id, ind).setValue(cellObj.getValue());
                    }
                });
                var  g_actual_volume = sumColumnRowSelect(grid_obj,actual_volume_col_index,childs);
                var  g_matched = sumColumnRowSelect(grid_obj,matched_col_index,childs);
                var  g_remaining = sumColumnRowSelect(grid_obj,remaining_col_index,childs);
                var g_price = averageColumnRowSelect(grid_obj,price_col_index,childs);
                var g_vp_value = sumColumnRowSelect(grid_obj,vp_value_col_index,childs);

                grid_obj.cells(id, actual_volume_col_index).setValue(g_actual_volume.toFixed(2));
                grid_obj.cells(id, matched_col_index).setValue(g_matched.toFixed(2));
                grid_obj.cells(id, remaining_col_index).setValue(g_remaining.toFixed(2));
                grid_obj.cells(id, price_col_index).setValue(g_price.toFixed(2));
                grid_obj.cells(id, vp_value_col_index).setValue(g_vp_value.toFixed(2));
            }
        });

        link_ui_insert.load_grid_footer2(grid_obj,set);
    }


    link_ui_insert.get_match_grids = function() {
        var left_grid_select_id = link_ui_insert.left_grid.getSelectedRowId();
        var right_grid_select_id = link_ui_insert.right_grid.getSelectedRowId();
        if (left_grid_select_id == null || right_grid_select_id == null) {            
            return {title: 'Alert', type: 'alert', text: 'Deal(s) not selected. Please select.'};
        }

        var return_json = '';
        var validated = true;
        var error_json = {};

        // Used for product validation
        var commodity_name = '';
        var uom_name = '';


        var left_grid_select_id_arr = new Array();
        var right_grid_select_id_arr = new Array();
        var dealset1_arr = new Array();
        var dealset2_arr = new Array();

        left_grid_select_id_arr = left_grid_select_id.split(',');
        right_grid_select_id_arr = right_grid_select_id.split(',');

        for (var i = 0; i<left_grid_select_id_arr.length; i++) {
            if (link_ui_insert.left_grid.hasChildren(left_grid_select_id_arr[i])) {
                left_grid_select_id_arr.splice(i,1);
            }
        }

        for (var i = 0; i<right_grid_select_id_arr.length; i++) {
            if (link_ui_insert.right_grid.hasChildren(right_grid_select_id_arr[i])) {
                right_grid_select_id_arr.splice(i,1);
            }
        }


        left_grid_select_id_arr.sort(function(a,b){return a-b;})
        right_grid_select_id_arr.sort(function(a,b){return a-b;})


        // Get total remaining for Deal Set 1 and Deal Set 2
        var left_remaining_total = 0;
        left_grid_select_id_arr.forEach(function(row_id) {
            link_ui_insert.left_grid.forEachCell(row_id,function(cellObj,ind){
                if (link_ui_insert.left_grid.getColumnId(ind) == 'source_deal_header_id') {
                    dealset1_arr.push(cellObj.getValue());
                }
                if (link_ui_insert.left_grid.getColumnId(ind) == 'commodity') {
                    if (commodity_name != '' && commodity_name != cellObj.getValue()) {
                        validated = false;
                        error_json =  {title: 'Alert', type: 'alert', text: 'Deal(s) with different product have been selected.'};          
                    } else {
                        commodity_name = cellObj.getValue();
                    }
                }
                /*
                if (link_ui_insert.left_grid.getColumnId(ind) == 'uom') {
                    if (uom_name != '' && uom_name != cellObj.getValue()) {
                        validated = false;
                        error_json =  {title: 'Alert', type: 'alert', text: 'Deal(s) with different UOM have been selected.'};                 
                    } else {
                        uom_name = cellObj.getValue();
                    }
                }
                */
                if (link_ui_insert.left_grid.getColumnId(ind) == 'remaining') {
                    left_remaining_total += parseFloat(cellObj.getValue());
                }
            });
        });

        var right_remaining_total = 0;
        right_grid_select_id_arr.forEach(function(row_id) {
            link_ui_insert.right_grid.forEachCell(row_id,function(cellObj,ind){
                if (link_ui_insert.right_grid.getColumnId(ind) == 'source_deal_header_id') {
                    dealset2_arr.push(cellObj.getValue());
                }
                if (link_ui_insert.right_grid.getColumnId(ind) == 'commodity') {
                    if (commodity_name != '' && commodity_name != cellObj.getValue()) {
                        validated = false;
                        error_json =  {title: 'Alert', type: 'alert', text: 'Deal(s) with different product have been selected.'};                     
                    } else {
                        commodity_name = cellObj.getValue();
                    }
                }
                /*
                if (link_ui_insert.right_grid.getColumnId(ind) == 'uom') {
                    if (uom_name != '' && uom_name != cellObj.getValue()) {
                        validated = false;
                        error_json =  {title: 'Alert', type: 'alert', text: 'Deal(s) with different UOM have been selected.'};                    
                    } else {
                        uom_name = cellObj.getValue();
                    }
                }
                */
                if (link_ui_insert.right_grid.getColumnId(ind) == 'remaining') {
                    right_remaining_total += parseFloat(cellObj.getValue());
                }
            });
        });

        //Validation for same deals matched
        var common_dealset_arr = _.intersection(dealset1_arr, dealset2_arr);

        if (common_dealset_arr.length > 0) {
            validated = false;
            error_json =  {title: 'Alert', type: 'alert', text: 'Same Deal(s) are selected.'};

        }
        
        var lowest_remaining_total = (left_remaining_total < right_remaining_total) ? left_remaining_total : right_remaining_total;
        
        
        var remaining_total = parseFloat(lowest_remaining_total);
        var remaining_total2 = parseFloat(lowest_remaining_total);
        var actual_volume_col_index =  link_ui_insert.left_grid.getColIndexById("actual_volume");
        var remaining_col_index =  link_ui_insert.left_grid.getColIndexById("remaining");
        var matched_col_index =  link_ui_insert.left_grid.getColIndexById("matched");
        var source_deal_header_id_col_index =  link_ui_insert.left_grid.getColIndexById("source_deal_header_id");
        return_json += '{left_grid_ui: [{rows:[';
        left_grid_select_id_arr.forEach(function(row_id) {
            return_json += '{id: ' + link_ui_insert.left_grid.cells(row_id, source_deal_header_id_col_index).getValue() + '';
            link_ui_insert.left_grid.forEachCell(row_id,function(cellObj,ind){
                //console.log(cellObj.getValue());
                if (link_ui_insert.left_grid.getColumnId(ind) == 'matched') {
                    var actual_volume_left = link_ui_insert.left_grid.cells(row_id,actual_volume_col_index).getValue();
                    if (remaining_total > parseFloat(actual_volume_left) - parseFloat(cellObj.getValue())) {
                        return_json += ',matched:"' + (parseFloat(actual_volume_left) - parseFloat(cellObj.getValue())) + '"';                            
                    } else {
                        return_json += ',matched:"' + remaining_total + '"';        
                    }

                    
                    //Remaining
                        var remaining_left = link_ui_insert.left_grid.cells(row_id,remaining_col_index).getValue();
                        if (remaining_total >= parseFloat(remaining_left)) {
                            remaining_total = remaining_total - parseFloat(remaining_left); 
                        } else {
                            remaining_total = 0;        
                        }
                    

                    
                } else if (link_ui_insert.left_grid.getColumnId(ind) == 'remaining') {
                    if (remaining_total2 >= parseFloat(cellObj.getValue())) {
                        remaining_total2 = remaining_total2 - parseFloat(cellObj.getValue());  
                        return_json += ',remaining:0';
                    } else {
                        return_json += ',remaining:' + (parseFloat(cellObj.getValue()) - remaining_total2);
                        remaining_total2 = 0;        
                    }
                    
                } else {
                    //return_json += '"' + cellObj.getValue() + '",';
                }
            });
            return_json += '},'
        })
        return_json += ']},]},';

        var remaining_total = parseFloat(lowest_remaining_total);
        var remaining_total2 = parseFloat(lowest_remaining_total);
        var actual_volume_col_index =  link_ui_insert.right_grid.getColIndexById("actual_volume");
        var remaining_col_index =  link_ui_insert.right_grid.getColIndexById("remaining");
        var matched_col_index =  link_ui_insert.right_grid.getColIndexById("matched");
        var source_deal_header_id_col_index =  link_ui_insert.right_grid.getColIndexById("source_deal_header_id");
        return_json += '{right_grid_ui: [{rows:[';
        right_grid_select_id_arr.forEach(function(row_id) {
            return_json += '{id: ' + link_ui_insert.right_grid.cells(row_id, source_deal_header_id_col_index).getValue() + '';
            link_ui_insert.right_grid.forEachCell(row_id,function(cellObj,ind){
                //console.log(cellObj.getValue());
                if (link_ui_insert.right_grid.getColumnId(ind) == 'matched') {
                    var actual_volume_right = link_ui_insert.right_grid.cells(row_id,actual_volume_col_index).getValue();
                    if (remaining_total > parseFloat(actual_volume_right) - parseFloat(cellObj.getValue())) {
                        return_json += ',matched:"' + (parseFloat(actual_volume_right) - parseFloat(cellObj.getValue())) + '"';                            
                    } else {
                        return_json += ',matched:"' + remaining_total + '"';        
                    }

                    //Remaining
                        var remaining_right = link_ui_insert.right_grid.cells(row_id,remaining_col_index).getValue();
                        if (remaining_total >= parseFloat(remaining_right)) {
                            remaining_total = remaining_total - parseFloat(remaining_right); 
                        } else {
                            remaining_total = 0;        
                        }
                    
                    
                } else if (link_ui_insert.right_grid.getColumnId(ind) == 'remaining') {
                    if (remaining_total2 >= parseFloat(cellObj.getValue())) {
                        remaining_total2 = remaining_total2 - parseFloat(cellObj.getValue());  
                        return_json += ',remaining:0';
                    } else {                        
                        return_json += ',remaining:' + (parseFloat(cellObj.getValue()) - remaining_total2) + '';
                        remaining_total2 = 0;        
                    }
                    
                } else {
                    //return_json += '"' + cellObj.getValue() + '",';
                }
            });
            return_json += '},'
        })
        return_json += ']},]},';

        //console.log(return_json);

        //$json  = '{rows:[{ id:0,data:[ "74","EUAT","Buy", "XYZ","11/10/2017","11/10/2017","123","0","123","Tons","3.15","EUR"]}],}';
        
        if (validated)
            return '{grids:['+return_json+']}';
        else
            return error_json;
        
    }

    
    link_ui_insert.left_grid_row_state_change = function(rIds){
        /*
        $('table tr.odd_undefined').removeClass(' rowselected');
        $('table tr.odd_undefined').removeClass('rowselected');
        $('table tr.ev_undefined').removeClass(' rowselected');
        $('table tr.ev_undefined').removeClass('rowselected');

        $('table tr.odd_undefined td').removeClass('cellSelected');
        $('table tr.ev_undefined td').removeClass('cellSelected');
        */
       
        if (rIds != null) {
            var diff = left_selected_grid_ids.split(',').filter(function(x) { return rIds.split(',').indexOf(x) < 0 })
            left_selected_grid_ids = rIds;

            var new_diff = new Array();

            if (diff[0] != "") {
                for (var i=0; i<diff.length;i++ ) {
                    if (link_ui_insert.left_grid.hasChildren(diff[i])) {                        
                        var childs = link_ui_insert.left_grid.getAllSubItems(diff[i]);
                        childs_arr = childs.split(',');
                        var child_count = 0;
                        for (var a=0;a<childs_arr.length;a++) {
                            if (rIds.split(',').indexOf(childs_arr[a]) > -1) {child_count++;}
                        }
                        if (child_count == childs_arr.length) {new_diff.push(diff[i]);}

                    }
                }
                //console.log(new_diff);
                if (new_diff.length > 0) {
                    for (var i=0; i<new_diff.length;i++ ) {
                        link_ui_insert.left_grid.closeItem(new_diff[i]);
                        var childs = link_ui_insert.left_grid.getAllSubItems(new_diff[i]);
                        link_ui_insert.left_grid.clearSelectionRowId(childs);
                    }
                    left_grid_select_ids = link_ui_insert.left_grid.getSelectedRowId();
                }
            }
        }        

        link_ui_insert.grid_row_select_post();
            //return false;
    }

    link_ui_insert.right_grid_row_state_change = function(rIds){
       
        if (rIds != null) {
            var diff = right_selected_grid_ids.split(',').filter(function(x) { return rIds.split(',').indexOf(x) < 0 })
            right_selected_grid_ids = rIds;

            var new_diff = new Array();

            if (diff[0] != "") {
                for (var i=0; i<diff.length;i++ ) {
                    if (link_ui_insert.right_grid.hasChildren(diff[i])) {                        
                        var childs = link_ui_insert.right_grid.getAllSubItems(diff[i]);
                        childs_arr = childs.split(',');
                        var child_count = 0;
                        for (var a=0;a<childs_arr.length;a++) {
                            if (rIds.split(',').indexOf(childs_arr[a]) > -1) {child_count++;}
                        }
                        if (child_count == childs_arr.length) {new_diff.push(diff[i]);}

                    }
                }
                //console.log(new_diff);
                if (new_diff.length > 0) {
                    for (var i=0; i<new_diff.length;i++ ) {
                        link_ui_insert.right_grid.closeItem(new_diff[i]);
                        var childs = link_ui_insert.right_grid.getAllSubItems(new_diff[i]);
                        link_ui_insert.right_grid.clearSelectionRowId(childs);
                    }
                }
            }
        }


        link_ui_insert.grid_row_select_post();
            //return false;
    }

    link_ui_insert.left_grid_before_row_select = function(new_row,old_row,new_col_index){
        var left_grid_select_ids = link_ui_insert.left_grid.getSelectedRowId();
        if (left_grid_select_ids != null) {
            var left_grid_select_id_arr = left_grid_select_ids.split(',');
            if (left_grid_select_id_arr.indexOf(new_row) > -1 && link_ui_insert.left_grid.hasChildren(new_row)) {
                return false;
            }
        }
        return true;
    }

    link_ui_insert.right_grid_before_row_select = function(new_row,old_row,new_col_index){
        var right_grid_select_ids = link_ui_insert.right_grid.getSelectedRowId();
        if (right_grid_select_ids != null) {
            var right_grid_select_id_arr = right_grid_select_ids.split(',');
            if (right_grid_select_id_arr.indexOf(new_row) > -1 && link_ui_insert.right_grid.hasChildren(new_row)) {
                return false;
            }
        }
        return true;
    }

    link_ui_insert.grid_row_select = function(rId,cInd){
        var left_grid_select_ids = link_ui_insert.left_grid.getSelectedRowId();
        

        if (left_grid_select_ids != null) {
            var left_grid_select_id_arr = left_grid_select_ids.split(',');
            //if (left_grid_select_id_arr.indexOf(rId) == -1) {
                for(var i=0; i< left_grid_select_id_arr.length; i++) {
                    var left_grid_select_id = left_grid_select_id_arr[i];
                    if (link_ui_insert.left_grid.hasChildren(left_grid_select_id)) {
                        var childs = link_ui_insert.left_grid.getAllSubItems(left_grid_select_id)
                        //link_ui_insert.left_grid.openItem(left_grid_select_id);
                        childs_arr = childs.split(',');
                        for (var a=0;a<childs_arr.length;a++) {
                            link_ui_insert.left_grid.selectRowById(childs_arr[a],true);
                        }
                        
                    }
                }
            //}
        }

        var right_grid_select_ids = link_ui_insert.right_grid.getSelectedRowId();
        

        if (right_grid_select_ids != null) {
            var right_grid_select_id_arr = right_grid_select_ids.split(',')
            for(var i=0; i< right_grid_select_id_arr.length; i++) {
                var right_grid_select_id = right_grid_select_id_arr[i];
                if (link_ui_insert.right_grid.hasChildren(right_grid_select_id)) {
                    var childs = link_ui_insert.right_grid.getAllSubItems(right_grid_select_id)
                    //link_ui_insert.right_grid.openItem(right_grid_select_id);
                    childs_arr = childs.split(',');
                    for (var a=0;a<childs_arr.length;a++) {
                        link_ui_insert.right_grid.selectRowById(childs_arr[a],true);
                    }
                    
                }
            }
        }
        
    }

    link_ui_insert.grid_row_select_post = function(){
        
        left_grid_select_ids = link_ui_insert.left_grid.getSelectedRowId();
        right_grid_select_ids = link_ui_insert.right_grid.getSelectedRowId();

        for (var i =1; i<3; i++) {

            var attached_grid = (i == 1) ? link_ui_insert.left_grid : link_ui_insert.right_grid;
            var select_ids = (i == 1) ? link_ui_insert.left_grid.getSelectedRowId() : link_ui_insert.right_grid.getSelectedRowId();

            
            if (left_grid_select_ids == null && right_grid_select_ids == null) {      
                var nrQ_val = sumColumn(attached_grid,attached_grid.getColIndexById("actual_volume"));
                var srQ_val = sumColumn(attached_grid,attached_grid.getColIndexById("matched"));
                var nrS_val = sumColumn(attached_grid,attached_grid.getColIndexById("remaining"));
                var select_state = false;
            
            } else {
                var nrQ_val = sumColumnRowSelect(attached_grid,attached_grid.getColIndexById("actual_volume"),select_ids);
                var srQ_val = sumColumnRowSelect(attached_grid,attached_grid.getColIndexById("matched"),select_ids);
                var nrS_val = sumColumnRowSelect(attached_grid,attached_grid.getColIndexById("remaining"),select_ids);
                var select_state = true;
            }
        
            var nrQ = document.getElementById("av_q"+i);
                nrQ.innerHTML = numberWithCommas(nrQ_val);
            var srQ = document.getElementById("mt_q"+i);
                srQ.innerHTML = numberWithCommas(srQ_val);
            var nrS = document.getElementById("rm_q"+i);
                nrS.innerHTML = numberWithCommas(nrS_val);

        }

        link_ui_insert.show_net_position(select_state,left_grid_select_ids,right_grid_select_ids);

    }

    link_ui_insert.load_grid_footer2 = function(attached_grid, i) {
        attached_grid.filterByAll();
        if ($('#mt_q'+i).length == 0) {
            var nrQ_val = sumColumn(attached_grid,attached_grid.getColIndexById("actual_volume"));
            var srQ_val = sumColumn(attached_grid,attached_grid.getColIndexById("matched"));
            var nrS_val = sumColumn(attached_grid,attached_grid.getColIndexById("remaining"));


            attached_grid.attachFooter("<div id='footer_div"+i+"' style='padding-left:" + attached_grid.objBox.scrollLeft + "px' ><div style='float:left;padding-right:20px;'>Actual Volume : <span id='av_q"+i+"'>0</span></div><div style='float:left;padding-right:20px;'>Matched : <span id='mt_q"+i+"'>0</span></div><div style='float:left;padding-right:20px;'>Remaining : <span id='rm_q"+i+"'>0</span></div><div style='clear:both;font-weight:bold;' id='net_pos_"+ i + "' ></div></div>,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan",["height:40px;text-align:left;"]);
        
             
             var nrQ = document.getElementById("av_q"+i);
             if (typeof nrQ != "undefined") {
                nrQ.innerHTML = numberWithCommas(nrQ_val);
            }
            var srQ = document.getElementById("mt_q"+i);
            if (typeof srQ != "undefined") {
                srQ.innerHTML = numberWithCommas(srQ_val);
            }
            var nrS = document.getElementById("rm_q"+i);
            if (typeof nrS != "undefined") {
                nrS.innerHTML = numberWithCommas(nrS_val);
            }
        } 
        
        link_ui_insert.layout_link_ui_insert.cells('c').setWidth(link_ui_insert.layout_link_ui_insert.cells('c').getWidth() + 0.1);
        
        if (i == 1)
            link_ui_insert.layout_link_ui_insert.cells('c').progressOff();
        else  {
            link_ui_insert.layout_link_ui_insert_inner2.cells('b').progressOff();
            parent.enable_disable_deal_match_menu('refresh',true);
            parent.enable_disable_deal_match_menu('match',true);
            parent.enable_disable_deal_match_menu('process',true);
            link_ui_insert.show_net_position();
        }
        
    }

    link_ui_insert.show_net_position = function(select_state, left_grid_select_id, right_grid_select_id) {

        if (select_state) {
            var nrS_val_left = sumColumnRowSelect(link_ui_insert.left_grid,link_ui_insert.left_grid.getColIndexById("remaining"),left_grid_select_id);
            var nrS_val_right = sumColumnRowSelect(link_ui_insert.right_grid,link_ui_insert.right_grid.getColIndexById("remaining"),right_grid_select_id);

        } else {
            var nrS_val_left = sumColumn(link_ui_insert.left_grid,link_ui_insert.left_grid.getColIndexById("remaining"));
            var nrS_val_right = sumColumn(link_ui_insert.right_grid,link_ui_insert.right_grid.getColIndexById("remaining"));
        }


        if (nrS_val_left > nrS_val_right) {
            if (document.getElementById("net_pos_1") && typeof document.getElementById("net_pos_1") != "undefined") {                
                document.getElementById("net_pos_1").innerHTML = 'Net Position : ' + numberWithCommas(nrS_val_left - nrS_val_right);
            }
            if (document.getElementById("net_pos_2") && typeof document.getElementById("net_pos_2") != "undefined") {
                document.getElementById("net_pos_2").innerHTML = '';
            }
        } else if (nrS_val_right > nrS_val_left) {
            if (document.getElementById("net_pos_2") && typeof document.getElementById("net_pos_2") != "undefined") {
                document.getElementById("net_pos_2").innerHTML = 'Net Position : ' + numberWithCommas(nrS_val_right - nrS_val_left);
            }
            if (document.getElementById("net_pos_1") && typeof document.getElementById("net_pos_1") != "undefined") {
                document.getElementById("net_pos_1").innerHTML = '';
            }
        } else {
            if (document.getElementById("net_pos_2") && typeof document.getElementById("net_pos_2") != "undefined") {
                document.getElementById("net_pos_2").innerHTML = 'Net Position : ' + numberWithCommas(0);
            }
            if (document.getElementById("net_pos_1") && typeof document.getElementById("net_pos_1") != "undefined") {
                document.getElementById("net_pos_1").innerHTML = 'Net Position : ' + numberWithCommas(0);
            }
        }


    }


    var update_book_win;
    link_ui_insert.open_update_book = function() {

        var left_dealid_col_index = link_ui_insert.left_grid.getColIndexById("source_deal_header_id");
        var right_dealid_col_index = link_ui_insert.right_grid.getColIndexById("source_deal_header_id");
        var left_grid_select_deals = link_ui_insert.left_grid.getColumnValues(left_dealid_col_index) || '0';
        var right_grid_select_deals = link_ui_insert.right_grid.getColumnValues(right_dealid_col_index) || '0';

        //validate matched_volume to be 0 to update
        var left_matched_col_index = link_ui_insert.left_grid.getColIndexById("matched");
        var right_matched_col_index = link_ui_insert.right_grid.getColIndexById("matched");
        var left_grid_matched = link_ui_insert.left_grid.getColumnValues(left_matched_col_index) || '0';
        var right_grid_matched = link_ui_insert.right_grid.getColumnValues(right_matched_col_index) || '0';

        
        var grid_matched = left_grid_matched + ',' + right_grid_matched;
        var grid_matched_arr = grid_matched.split(',');

        for (var i=0; i< grid_matched_arr.length; i++) {
            if (parseInt(grid_matched_arr[i]) != 0) {
                return {title: 'Alert', type: 'alert-error', text: 'Matched Deal(s) is selected. Please checked.'};
            }

        }
        

        var deal_ids = left_grid_select_deals + ',' + right_grid_select_deals;

        if (deal_ids == '0,0') {
            return {title: 'Alert', type: 'alert-error', text: 'No Deal(s) selected.'};
        }

        if (update_book_win != null && update_book_win.unload != null) {
            update_book_win.unload();
            update_book_win = w1 = null;
        }

        if (!update_book_win) {
            update_book_win = new dhtmlXWindows();
        }

        var update_book = update_book_win.createWindow('w1', 0, 0, 500, 650);
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
                data = {"action": "spa_source_deal_header", "flag":"y", "deal_ids":deal_ids, "sub_book":new_subbook};
                adiha_post_data("return_array", data, '', '', 'link_ui_insert.delete_deals_callback');
            }

            return true;
        });

    }

    /**
     * [delete_deals_callback Deal delete callback]
     * @param  {[array]} return_value [description]
     */
    link_ui_insert.delete_deals_callback = function(return_value) {
        if (return_value[0][0] == 'Success') {
            dhtmlx.message({
                text:return_value[0][4],
                expire:1000
            });
            parent.link_ui_template.refresh_match_grids();
        } else {
            dhtmlx.alert({
                title:"Alert",
                type:"alert-error",
                text:return_value[0][4],
            });
            return;
        }
    }


    function sumColumn(myGrid,ind){
        var out = 0;
        var buy_sell = '';
        for(var i=0;i<myGrid.getRowsNum();i++){
            //if (myGrid.hasChildren(myGrid.getRowId(i))) {
             //   out += 0;
            //} else {
                buy_sell = myGrid.cells2(i,4).getValue();
                
                if (buy_sell == 'Buy')
                    out += parseFloat(myGrid.cells2(i,ind).getValue());
                else
                    out -= parseFloat(myGrid.cells2(i,ind).getValue());
            //}
        }
        return Math.abs(out);
    }

     function sumColumnRowSelect(myGrid,ind,arr_string){
        if (arr_string == null)
            return 0;

        var arr = arr_string.split(',');
        var out = 0;
        var buy_sell = '';
        
        arr.forEach(function(row_id) {

            if (myGrid.hasChildren(row_id)) {
                out += 0;
            } else {
            
                buy_sell = myGrid.cells(row_id,4).getValue();
                
                if (buy_sell == 'Buy')
                    out += parseFloat(myGrid.cells(row_id,ind).getValue())
                else
                    out -= parseFloat(myGrid.cells(row_id,ind).getValue())
            }
        });

        return Math.abs(out);
    }

    function averageColumnRowSelect(myGrid,ind,arr_string){
        if (arr_string == null)
            return 0;

        var arr = arr_string.split(',');
        var out = 0;
        var buy_sell = '';
        
        arr.forEach(function(row_id) {

            if (myGrid.hasChildren(row_id)) {
                out += 0;
            } else {
            
                buy_sell = myGrid.cells(row_id,4).getValue();
                
                if (buy_sell == 'Buy')
                    out += parseFloat(myGrid.cells(row_id,ind).getValue())
                else
                    out -= parseFloat(myGrid.cells(row_id,ind).getValue())
            }
        });

        return Math.abs(out/arr.length);
    }

    function numberWithCommas(x) {
        x = Math.round(Math.abs(x) * 100) / 100;
        x = x.toFixed(2);
        return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    }
  

</script>
</html>