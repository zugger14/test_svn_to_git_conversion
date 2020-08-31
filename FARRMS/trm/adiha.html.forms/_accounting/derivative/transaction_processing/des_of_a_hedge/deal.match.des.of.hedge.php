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
    $title = 'Deal Match';  

    $application_function_id_filter1 = 10233722;
    $application_function_id_filter2 = 10233723;

    $rights_deal_match_refresh = 10233724;
    
    list (
        $has_rights_deal_match_refresh
    ) = build_security_rights(
        $rights_deal_match_refresh
    );
        
    $namespace = 'link_ui_insert';
    $layout_obj = new AdihaLayout();    
    $enable = 'true';

    $top_layout_json = '[
                        {id: "a", height:800,text: "Hedges", header: true},         
                        {id: "b", height:800,text: "Items", header: true}
                    ]';
    
    $patterns = '2U';

    $layout_name = 'layout_link_ui_insert';
    echo $layout_obj->init_layout($layout_name, '', $patterns, $top_layout_json, $namespace);

    $toolbar_obj = new AdihaToolbar();
    $toolbar_name = 'toolbar_deal_des_hedge';
    $toolbar_json = '[{ id: "match", type: "button", img: "match.gif", imgdis: "match_dis.gif", text: "Match", title: "Match", enabled: ' . $has_rights_deal_match_refresh. '},
                    { id: "refresh", type: "button", img: "refresh.gif", imgdis: "refresh_dis.gif", text: "Refresh", title: "Refresh", enabled: ' . $has_rights_deal_match_refresh . '}
                ]';
    echo $layout_obj->attach_toolbar($toolbar_name);
    echo $toolbar_obj->init_by_attach($toolbar_name, $namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', $namespace . '.onclick_menu');

    $layout_json_inner1 = '[
                    {id: "a", height:250, text: "Hedges", header: true},
                    {id: "b", text: "Deals", header: true},
                ]';

    $layout_name_inner1 = 'layout_link_ui_insert_inner1';
    $inner_layout_obj1 = new AdihaLayout();
    echo $layout_obj->attach_layout_cell($layout_name_inner1, 'a', "2E", $layout_json_inner1);
    echo $inner_layout_obj1->init_by_attach($layout_name_inner1, $namespace);

    $layout_json_inner2 = '[
                    {id: "a",height:250, text: "Items", header: true},
                    {id: "b", text: "Deals", header: true},
                ]';    
    
    $layout_name_inner2 = 'layout_link_ui_insert_inner2';
    $inner_layout_obj2 = new AdihaLayout();
    echo $layout_obj->attach_layout_cell($layout_name_inner2, 'b', '2E', $layout_json_inner2);
    echo $inner_layout_obj2->init_by_attach($layout_name_inner2, $namespace);
  
    /***Dealset 1***/    
    $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id=". $application_function_id_filter1 . ", @template_name='DealMatchFilter1DesignationOfHedge', @group_name='Dealset1FilterDesignationOfHedge'";
    $return_value = readXMLURL($xml_file);
    $form_json = $return_value[0][2];
    
    $filter_name = 'des_filter_dealset1';
    echo $inner_layout_obj1->attach_form($filter_name, 'a');
    $filter_obj = new AdihaForm();
    echo $filter_obj->init_by_attach($filter_name, $namespace);
    echo $filter_obj->load_form_filter($namespace, $filter_name, $layout_name_inner1, 'a', $application_function_id_filter1, 2);
    echo $filter_obj->load_form($form_json);

    $grid_obj = new AdihaGrid();
    $grid_name = 'left_grid';
    echo $inner_layout_obj1->attach_grid_cell($grid_name, 'b');    
    $xml_file = "EXEC spa_adiha_grid 's','DealMatchDesignation'";
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

    echo $grid_obj->attach_event('', 'onSelectStateChanged', $namespace . '.grid_row_select_post');
    echo $grid_obj->attach_event('', 'onBeforeSelect', $namespace . '.left_grid_before_row_select');
    /***Dealset 1 END***/
    
    /********Dealset 2**********/

    $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id=". $application_function_id_filter2 . ", @template_name='DealMatchFilter2DesignationOfHedge', @group_name='Dealset2FilterDesignationOfHedge'";
    $return_value = readXMLURL($xml_file);
    $form_json = $return_value[0][2];
   
    $filter_name2 = 'des_filter_dealset2';
    echo $inner_layout_obj2->attach_form($filter_name2, 'a');
    $filter_obj2 = new AdihaForm();
    echo $filter_obj2->init_by_attach($filter_name2, $namespace);
    echo $filter_obj2->load_form_filter($namespace, $filter_name2, $layout_name_inner2, 'a', $application_function_id_filter2, 2);
    echo $filter_obj2->load_form($form_json);

    $grid_obj = new AdihaGrid();
    $grid_name = 'right_grid';
    echo $inner_layout_obj2->attach_grid_cell($grid_name, 'b');    
    $xml_file = "EXEC spa_adiha_grid 's','DealMatchDesignation'";
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

    echo $grid_obj->attach_event('', 'onSelectStateChanged', $namespace . '.grid_row_select_post');
    echo $grid_obj->attach_event('', 'onBeforeSelect', $namespace . '.right_grid_before_row_select'); 
    /********Dealset 2 END**********/

    echo $layout_obj->close_layout(); 
    ?>
</body>
<script>
    var filter_application_function_id1 = "<?php echo $application_function_id_filter1;?>";
    var filter_application_function_id2 = "<?php echo $application_function_id_filter1;?>";
    left_selected_grid_ids = '';
    right_selected_grid_ids = '';
    var has_rights_deal_match_refresh = Boolean(<?php echo $has_rights_deal_match_refresh; ?>);
    

    $(function() {
        attach_browse_event('link_ui_insert.des_filter_dealset1',filter_application_function_id1);
        attach_browse_event('link_ui_insert.des_filter_dealset2',filter_application_function_id2);

        link_ui_insert.left_grid.setEditable(false);
        link_ui_insert.right_grid.setEditable(false);
        
        link_ui_insert.layout_link_ui_insert.attachEvent("onResizeFinish", function(){
            setTimeout(function() {link_ui_insert.layout_link_ui_insert.cells('a').setWidth((link_ui_insert.layout_link_ui_insert.cells('a').getWidth() + link_ui_insert.layout_link_ui_insert.cells('b').getWidth())/2) }, 5);           
        });
        
        link_ui_insert.left_grid.attachEvent("onXLE", function(grid_obj,count){
            //link_ui_insert.post_grid_XLE(grid_obj,1);
            link_ui_insert.load_grid_footer2(grid_obj,1);
        });

        link_ui_insert.right_grid.attachEvent("onXLE", function(grid_obj,count){
            //link_ui_insert.post_grid_XLE(grid_obj,2);
            link_ui_insert.load_grid_footer2(grid_obj,2);
        });

        link_ui_insert.left_grid.attachEvent("onScroll", function(sLeft,sTop){
            $('#footer_div1').css('padding-left',sLeft);
        });

        link_ui_insert.right_grid.attachEvent("onScroll", function(sLeft,sTop){
            $('#footer_div2').css('padding-left',sLeft);
        });
    })

    link_ui_insert.onclick_menu = function(id) {
        switch (id) {
            case 'refresh':
                link_ui_insert.load_match_grids();
                break;
            case 'match':
                link_ui_insert.match_deal_grids();
                break;
        }
    }

    link_ui_insert.load_match_grids = function() {
        left_selected_grid_ids = '';
        var validate_return1 = validate_form(link_ui_insert.des_filter_dealset1);
        var validate_return2 = validate_form(link_ui_insert.des_filter_dealset2);
    
        if (validate_return1 === false || validate_return2 === false) {
            link_ui_insert.enable_disable_deal_match_menu('refresh', has_rights_deal_match_refresh);
            link_ui_insert.enable_disable_deal_match_menu('match', has_rights_deal_match_refresh);
            return;
        }

        link_ui_insert.layout_link_ui_insert_inner1.cells('a').collapse();
        link_ui_insert.layout_link_ui_insert_inner2.cells('a').collapse();

        link_ui_insert.layout_link_ui_insert_inner1.cells('b').progressOn();
        link_ui_insert.layout_link_ui_insert_inner2.cells('b').progressOn();

        for (i = 1; i <= 2; i++) {            
            var attached_obj = (i == 1) ? link_ui_insert.des_filter_dealset1 : link_ui_insert.des_filter_dealset2;
            var attached_grid = (i == 1) ? link_ui_insert.left_grid : link_ui_insert.right_grid;

            if ($('#mt_q'+i).length == 1) {
                attached_grid.detachFooter(0);
            }

            var hedge_item = (i == 1) ? 'h' : 'i';
            var filter_xml = "<Root><FormXML ";
            var filter_data = attached_obj.getFormData();
            
            for (var a in filter_data) {
                field_label = a;

                if (field_label == 'apply_filters' || field_label == 'book_structure' || field_label == 'subsidiary_id' || field_label == 'strategy_id' || field_label == 'volume_min'  || field_label == 'volume_max') {
                    continue;
                }

                field_value = filter_data[a];
                if (attached_obj.getItemType(a) == 'calendar') {
                    field_value = attached_obj.getItemValue(a, true);
                } else if (field_label == 'subbook_id') {
                    field_label = 'sub_book_ids';
                } else if (field_label == 'book_id') {
                    field_label = 'book_ids';
                }

                filter_xml += " " + field_label + "=\"" + field_value + "\"";
                
            }

            filter_xml += ' filter_mode="a" contract_id="" broker_id="" source_deal_header_id_from="" source_deal_header_id_to="" deal_id="" view_deleted="n" show_unmapped_deals="n" generator_id="" location_group_id="" location_id="" template_id="" Index_group_id="" formula_curve_id="" formula_id="" deal_sub_type_id="" field_template_id="" physical_financial_id="" product_id="" internal_desk_id=""  settlement_date_from="" settlement_date_to="" payment_date_from="" payment_date_to="" deal_status="" confirm_status_type="" calc_status="" invoice_status="" deal_locked="" create_user = "" update_ts_from="" update_ts_to="" update_user=""  view_voided="n" view_detail="y" fas_deal_type_value_id= "" ';

            filter_xml += "></FormXML></Root>";            
            
            var sql_stmt = "EXEC spa_faslinkdetail @flag = 'k', @hedge_or_item = '" + hedge_item + "', @xml_filter = '" + filter_xml + "'";
                            
            var sql_param = {
                    "sql":sql_stmt,
                    "grid_type":"g"
                };

            sql_param = $.param(sql_param);
            var sql_url = js_data_collector_url + "&";
            attached_grid.post(sql_url, sql_param);
        }
    }

    link_ui_insert.enable_disable_deal_match_menu = function(itemId,is_enable) {
        if (is_enable) {               
            link_ui_insert.toolbar_deal_des_hedge.enableItem(itemId);
        } else {
            link_ui_insert.toolbar_deal_des_hedge.disableItem(itemId);
        }
    }

    link_ui_insert.match_deal_grids = function() {
        var return_result = link_ui_insert.get_match_grids();
       
        if (!return_result) {
                return;
            } else if (return_result.type == 'alert-error' || return_result.type == 'alert') {
                dhtmlx.alert({
                    title:return_result.title,
                    type:return_result.type,
                    text: return_result.text,
                });
                return false;
            } else {
                parent.parent.parent.link_ui.load_template_detail('add', return_result);
            }
    }
   
    link_ui_insert.get_match_grids = function() {
        var left_grid_select_id = link_ui_insert.left_grid.getSelectedRowId();
        var right_grid_select_id = link_ui_insert.right_grid.getSelectedRowId();
        if (left_grid_select_id == null) {            
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
        
        if (right_grid_select_id != null) {
            right_grid_select_id_arr = right_grid_select_id.split(',');
            right_grid_select_id_arr.sort(function(a,b){return a-b;})
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
                    } 
                });
                return_json += '},'
            })
            return_json += ']},]},';
        }

        left_grid_select_id_arr.sort(function(a,b){return a-b;})        

        // Get total remaining for Deal Set 1 and Deal Set 2
        var left_remaining_total = 0;
        left_grid_select_id_arr.forEach(function(row_id) {
            link_ui_insert.left_grid.forEachCell(row_id,function(cellObj,ind){
                if (link_ui_insert.left_grid.getColumnId(ind) == 'source_deal_header_id') {
                    dealset1_arr.push(cellObj.getValue());
                }      
               
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
                
                if (link_ui_insert.right_grid.getColumnId(ind) == 'remaining') {
                    right_remaining_total += parseFloat(cellObj.getValue());
                }
            });
        });
       
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
                    
                } 
            });
            return_json += '},'
        })
        return_json += ']},]},';       

        if (validated) {
            if (right_grid_select_id != null) {
                return '{"left_grid":"'+ dealset1_arr + '","right_grid":"' + dealset2_arr +'"}';
            } else {
                return '{"left_grid":"'+ dealset1_arr + '"}';
            }            
        } else {
            return error_json;
        }
        
    }

    link_ui_insert.left_grid_before_row_select = function(new_row,old_row,new_col_index){
        var left_grid_select_ids = link_ui_insert.left_grid.getSelectedRowId();
        if (left_grid_select_ids != null) {
            var left_grid_select_id_arr = left_grid_select_ids.split(',');
            if (left_grid_select_id_arr.indexOf(new_row) > -1) {
                return false;
            }
        }
        return true;
    }

    link_ui_insert.right_grid_before_row_select = function(new_row,old_row,new_col_index){
        var right_grid_select_ids = link_ui_insert.right_grid.getSelectedRowId();
        if (right_grid_select_ids != null) {
            var right_grid_select_id_arr = right_grid_select_ids.split(',');
            if (right_grid_select_id_arr.indexOf(new_row) > -1) {
                return false;
            }
        }
        return true;
    }

    link_ui_insert.grid_row_select_post = function() {
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
        
        link_ui_insert.layout_link_ui_insert.cells('b').setWidth(link_ui_insert.layout_link_ui_insert.cells('b').getWidth() + 0.1);
        
        if (i == 1) {
            link_ui_insert.layout_link_ui_insert_inner1.cells('b').progressOff();
        } else {
            link_ui_insert.layout_link_ui_insert_inner2.cells('b').progressOff();
            link_ui_insert.enable_disable_deal_match_menu('refresh',has_rights_deal_match_refresh);
            link_ui_insert.enable_disable_deal_match_menu('match',has_rights_deal_match_refresh);
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

    function sumColumn(myGrid,ind){
        var out = 0;
        var buy_sell = '';
        for(var i=0;i<myGrid.getRowsNum();i++){
            buy_sell = myGrid.cells2(i,4).getValue();
            
            if (buy_sell == 'Buy')
                out += parseFloat(myGrid.cells2(i,ind).getValue());
            else
                out -= parseFloat(myGrid.cells2(i,ind).getValue());
            
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
            buy_sell = myGrid.cells(row_id,4).getValue();
            
            if (buy_sell == 'Buy')
                out += parseFloat(myGrid.cells(row_id,ind).getValue())
            else
                out -= parseFloat(myGrid.cells(row_id,ind).getValue())
            
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
            buy_sell = myGrid.cells(row_id,4).getValue();
            
            if (buy_sell == 'Buy')
                out += parseFloat(myGrid.cells(row_id,ind).getValue())
            else
                out -= parseFloat(myGrid.cells(row_id,ind).getValue())
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