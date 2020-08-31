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
            $namespace = 'buy_sell_link_ui_insert';
            $php_script_loc = $app_php_script_loc;
            $app_user_loc = $app_user_name;
            $enable = 'true';

            $filter_application_function_id = 20007900;
            $application_function_id_filter1 = 20007903;
            $application_function_id_filter2 = 20007904;
            

            $rights_deal_match = 20007900;
            $rights_deal_match_iu = 20007901;
            $rights_deal_match_delete = 20007902;
        
            list (
                $has_rights_deal_match,
                $has_rights_deal_match_iu,
                $has_rights_deal_match_delete
            ) = build_security_rights(
                $rights_deal_match,
                $rights_deal_match_iu,
                $rights_deal_match_delete
            );

            // Main Layout Object
            $layout_name = 'layout_link_ui_insert';
            $layout_obj = new AdihaLayout(); 
    
            $layout_json = '[
                {
                    id: "a",
                    text: "<div><a class=\"undock-btn-a undock_custom\" style=\"float:right;cursor:pointer\" title=\"Undock\"  onClick=\" buy_sell_link_ui_insert.undock_cell_a();\"></a>Match Criteria</div>", 
                    header: true, 
                    collapse: false, 
                    height: 100},
                {
                    id: "b",
                    text: "<div><a class=\"undock-btn-a undock_custom\" style=\"float:right;cursor:pointer\" title=\"Undock\"  onClick=\" buy_sell_link_ui_insert.undock_cell();\"></a>Filter Criteria</div>",
                    header: true,
                    height:250},
                {id: "c", text: "Deals", header: true},
            ]';

           


            $patterns = '3E';        
            echo $layout_obj->init_layout($layout_name, '', $patterns, $layout_json, $namespace);
           

            /* Sell Deal Start (Right Part) */
            

            //Inner layout for 'c' cell 
            $layout_json_inner3 = '[
                {
                    id: "a", 
                    text: "<div><a class=\"undock-btn-a undock_custom\" style=\"float:right;cursor:pointer\" title=\"Undock\"  onClick=\" buy_sell_link_ui_insert.undock_cell_left_grid();\"></a>Sell Deal</div>",
                    header: true
                },
                {
                    id: "b", 
                    text: "<div><a class=\"undock-btn-a undock_custom\" style=\"float:right;cursor:pointer\" title=\"Undock\"  onClick=\" buy_sell_link_ui_insert.undock_cell_right_grid();\"></a>Buy Deal</div>", 
                    header: true
                }
            ]';

            $layout_name_inner3 = 'layout_link_ui_insert_inner3';
            $inner_layout_obj3 = new AdihaLayout();
            echo $layout_obj->attach_layout_cell($layout_name_inner3, 'c', '2U', $layout_json_inner3);
            echo $inner_layout_obj3->init_by_attach($layout_name_inner3, $namespace);

            //Create UI JSON of match criteria
            $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id=" . $application_function_id_filter1 . ", @template_name='BuySellMatchFilter1', @group_name='MatchCriteria'";
            $return_value = readXMLURL($xml_file);

            $form_json = $return_value[0][2];
            $match_form_name = 'match_criteria';
        
            //Attach  Form
            echo $layout_obj->attach_form($match_form_name, 'a');
             $form_obj = new AdihaForm();

            echo $form_obj->init_by_attach($match_form_name, $namespace);
            echo $form_obj->load_form($form_json);

            //Create UI JSON of Set 1
            $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id=" . $application_function_id_filter1 . ", @template_name='BuySellMatchFilter1', @group_name='Dealset1Filter'";
            $return_value = readXMLURL($xml_file);
            $form1_json = $return_value[0][2];
            $filter_form_name1 = 'filter_Dealset1';
        
            // Attach Filter Form
            echo $layout_obj->attach_form($filter_form_name1, 'b');
            $filter_form_obj1 = new AdihaForm();

            echo $filter_form_obj1->init_by_attach($filter_form_name1, $namespace);
            echo $filter_form_obj1->load_form($form1_json);

            $left_menu_obj = new AdihaMenu();
            $right_menu_obj = new AdihaMenu();
            $left_menu_name = 'left_grid_menu';
            $right_menu_name = 'right_grid_menu';
            $menu_json =  '[
                { id: "refresh_buy_deal", img: "refresh.gif", imgdis:"refresh_dis.gif", text: "Refresh", title: "Refresh", disabled: true},
                {id:"t2", text:"Export", img:"export.gif", items:[
                {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}]},
                { id: "match_all", img: "match.gif", imgdis:"match_dis.gif", text: "Match All", title: "Match All", disabled: true}
            ]';
            echo $right_menu_obj->attach_menu_layout_header($namespace, $layout_name_inner3, 'a', $left_menu_name, $menu_json, $namespace . '.onclick_menu_left');

            echo $right_menu_obj->attach_menu_layout_header($namespace, $layout_name_inner3, 'b', $right_menu_name, $menu_json, $namespace . '.onclick_menu_right');
            //Make New Grid Object for Sell Deal (Left Grid)
            $grid_obj = new AdihaGrid();
            echo $inner_layout_obj3->attach_status_bar("a", true);
            $grid_name = 'left_grid';
            echo $inner_layout_obj3->attach_grid_cell($grid_name, 'a');
            $xml_file = "EXEC spa_adiha_grid 's','BuySellMatchDealset'";
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
            echo $grid_obj->set_date_format($date_format, "%Y-%m-%d");
            echo $grid_obj->set_search_filter(true);
            echo $grid_obj->split_grid('1');
            echo $grid_obj->enable_paging(100, 'pagingArea_a');
            echo $grid_obj->return_init();
			echo $grid_obj->enable_filter_auto_hide();
        
            // Attach Events
            echo $grid_obj->attach_event('', 'onSelectStateChanged', $namespace . '.left_grid_row_state_change');
            echo $grid_obj->attach_event('', 'onRowSelect', $namespace . '.sell_grid_row_select');
            echo $grid_obj->attach_event('', 'onBeforeSelect', $namespace . '.left_grid_before_row_select');

 
            // Make new Grid Object for Right
            $grid_obj = new AdihaGrid();
            $grid_name = 'right_grid';
            echo $inner_layout_obj3->attach_grid_cell($grid_name, 'b');
            echo $inner_layout_obj3->attach_status_bar('b', true);
            $xml_file = "EXEC spa_adiha_grid 's','BuySellMatchDealset'";
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
            echo $grid_obj->set_date_format($date_format, "%Y-%m-%d");
            echo $grid_obj->set_search_filter(true); 
            echo $grid_obj->enable_paging(100, 'pagingArea_b');
            echo $grid_obj->return_init();
            echo $grid_obj->split_grid('1');
            echo $grid_obj->attach_event('', 'onSelectStateChanged', $namespace . '.right_grid_row_state_change');
            echo $grid_obj->attach_event('', 'onRowSelect', $namespace . '.buy_grid_row_select');
            echo $grid_obj->attach_event('', 'onBeforeSelect', $namespace . '.right_grid_before_row_select');
			echo $grid_obj->enable_filter_auto_hide();
            /* Buy Deal End (Right Part) */

            // Close layout object at end
            echo $layout_obj->close_layout(); 
        ?>

        <script>
            var filter_application_function_id = '<?php echo $filter_application_function_id;?>';
            left_selected_grid_ids = '';
            right_selected_grid_ids = '';
            var php_script_loc_ajax = '<?php echo $app_php_script_loc; ?>';


            $(function() {

                for(var i=1; i<=2; i++) {
                    var attached_grid = (i == 1) ? buy_sell_link_ui_insert.left_grid : buy_sell_link_ui_insert.right_grid; 
                    attached_grid.attachFooter("<div id='footer_div"+i+"' style='padding-left:" + attached_grid.objBox.scrollLeft + "px' ><div style='float:left;padding-right:20px;'>Best Available Volume : <span id='av_q"+i+"'>0</span></div><div style='float:left;padding-right:20px;'>Matched : <span id='mt_q"+i+"'>0</span></div><div style='float:left;padding-right:20px;'>Remaining : <span id='rm_q"+i+"'>0</span></div><div style='clear:both;font-weight:bold;' id='net_pos_"+ i + "' ></div></div>,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan",["height:40px;text-align:left;"]);

                }

                buy_sell_link_ui_insert.layout_link_ui_insert.cells('a').setIconsPath;
                buy_sell_link_ui_insert.left_grid_menu.hideItem('match_all');
                buy_sell_link_ui_insert.left_grid_menu.hideItem('refresh_buy_deal');
                filter_obj = buy_sell_link_ui_insert.layout_link_ui_insert.cells('a');
                var layout_cell_obj = buy_sell_link_ui_insert.layout_link_ui_insert.cells('a');
                var layout_cell_obj1 = buy_sell_link_ui_insert.layout_link_ui_insert.cells('b');
                arr_layout = [layout_cell_obj, layout_cell_obj1];
                               
                load_form_filter(filter_obj, arr_layout, '20007903', 2, '', '', '', 'layout');

                attach_browse_event('buy_sell_link_ui_insert.match_criteria', filter_application_function_id);
                attach_browse_event('buy_sell_link_ui_insert.filter_Dealset1', filter_application_function_id);
                

                buy_sell_link_ui_insert.left_grid.setEditable(false);
                buy_sell_link_ui_insert.right_grid.setEditable(false);
                
                buy_sell_link_ui_insert.layout_link_ui_insert.attachEvent("onResizeFinish", function() {
                    
                    setTimeout(function() {
                        var layout_obj = buy_sell_link_ui_insert.layout_link_ui_insert_inner3;
                        var cell_a_obj = layout_obj.cells('a');
                        var cell_b_obj = layout_obj.cells('b');
                        cell_a_obj.setWidth((cell_a_obj.getWidth() + cell_b_obj.getWidth())/2) 
                    }, 5);           
                });

                buy_sell_link_ui_insert.right_grid.attachEvent("onColumnHidden", function(index, state) {
                    
                    if (buy_sell_link_ui_insert.right_grid.getColumnId(index) == 'process_id') {
                        
                        if (state === true) {
                            buy_sell_link_ui_insert.right_grid.setColumnHidden(index, true);
                        } else {
                            buy_sell_link_ui_insert.right_grid.setColumnHidden(index, true);
                        }
                    }
                });

                buy_sell_link_ui_insert.left_grid.attachEvent("onColumnHidden", function(index, state) {
                    
                    if (buy_sell_link_ui_insert.left_grid.getColumnId(index) == 'process_id') {
                        
                        if (state === true) {
                            buy_sell_link_ui_insert.left_grid.setColumnHidden(index, true);
                        } else {
                            buy_sell_link_ui_insert.left_grid.setColumnHidden(index, true);
                        }
                    }
                });
                
                buy_sell_link_ui_insert.left_grid.attachEvent("onXLE", function(grid_obj, count){
                    buy_sell_link_ui_insert.post_grid_XLE(grid_obj, 1);
                });

                buy_sell_link_ui_insert.right_grid.attachEvent("onXLE", function(grid_obj, count){
                    buy_sell_link_ui_insert.post_grid_XLE(grid_obj, 2);
                });

                // buy_sell_link_ui_insert.left_grid.attachEvent("onScroll", function(sLeft, sTop){
                //     $('#footer_div1').css('padding-left', sLeft);
                // });

                // buy_sell_link_ui_insert.right_grid.attachEvent("onScroll", function(sLeft, sTop){
                //     $('#footer_div2').css('padding-left', sLeft);
                // });
            });


            buy_sell_link_ui_insert.onclick_menu_left = function(id) {
                switch (id) {
                     case 'excel':
                        buy_sell_link_ui_insert.left_grid.toExcel(php_script_loc_ajax + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                        break

                    case 'pdf':
                        buy_sell_link_ui_insert.left_grid.toPDF(php_script_loc_ajax + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                        break        
                    default:
                        dhtmlx.alert({
                            title:'Sorry! <font size="5">&#x2639 </font>',
                            type:"alert-error",
                            text:"Event not defined."
                        });
                        break;
                }
            } 

            buy_sell_link_ui_insert.onclick_menu_right = function(id) {
                switch (id) {
                     case 'excel':
                        buy_sell_link_ui_insert.right_grid.toExcel(php_script_loc_ajax + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                        break;

                    case 'pdf':
                        buy_sell_link_ui_insert.right_grid.toPDF(php_script_loc_ajax + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                        break ;
                    case 'match_all':
						dhtmlx.message({
                                type: "confirm",
                                title: "Confirmation",
                                ok: "Confirm",
                                text: "Do you want to match all Buy deals in the grid?",
                                callback: function(result) {
									if (result) { 
										buy_sell_link_ui_insert.buy_deal_grid_refresh('b', 'm');
									}
								}
						});
                        break;    
                    case 'refresh_buy_deal':
                        buy_sell_link_ui_insert.buy_deal_grid_refresh('b');
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


            /**
             * Unchecks all Options in Multi-select Combo
             * @param   {Object}    combo_obj   DHTMLX Combo Object
             */
            buy_sell_link_ui_insert.uncheck_all = function(combo_obj) { 
                
                for (var i=0; i < combo_obj.getOptionsCount(); i++) {
                    combo_obj.setChecked(i, false);
                }
            }

            buy_sell_link_ui_insert.undock_cell = function() {
                var layout_obj = buy_sell_link_ui_insert.layout_link_ui_insert;
                layout_obj.cells("b").undock(300, 300, 900, 700);
                layout_obj.dhxWins.window("b").button("park").hide();
                layout_obj.dhxWins.window("b").maximize();
                layout_obj.dhxWins.window("b").centerOnScreen();
            }
            buy_sell_link_ui_insert.undock_cell_a = function() {
                var layout_obj = buy_sell_link_ui_insert.layout_link_ui_insert;
                layout_obj.cells("a").undock(300, 300, 900, 700);
                layout_obj.dhxWins.window("a").button("park").hide();
                layout_obj.dhxWins.window("a").maximize();
                layout_obj.dhxWins.window("a").centerOnScreen();
            }
            buy_sell_link_ui_insert.undock_cell_left_grid = function() {
                var layout_obj = buy_sell_link_ui_insert.layout_link_ui_insert_inner3;
                layout_obj.cells("a").undock(300, 300, 900, 700);
                layout_obj.dhxWins.window("a").button("park").hide();
                layout_obj.dhxWins.window("a").maximize();
                layout_obj.dhxWins.window("a").centerOnScreen();
            }
            buy_sell_link_ui_insert.undock_cell_right_grid = function() {
                var layout_obj = buy_sell_link_ui_insert.layout_link_ui_insert_inner3;
                layout_obj.cells("b").undock(300, 300, 900, 700);
                layout_obj.dhxWins.window("b").button("park").hide();
                layout_obj.dhxWins.window("b").maximize();
                layout_obj.dhxWins.window("b").centerOnScreen();
            }



            /**
             * Validates Date From and To fields in Left.
             * @return {Boolean}
             */
            buy_sell_link_ui_insert.validate_from_and_to_left = function() {
                // From and to fields names in order
                var from_param = ['delivery_date_from', 'term_start', 'deal_date_from', 'create_ts_from'];
                var to_param = ['delivery_date_to', 'term_end', 'deal_date_to', 'create_ts_to'];
                
                // By default its set to true
                var return_value = true;
                
                // Loop for each of from and to names
                $.each(from_param, function(fp_idx, fr_pr) {
                    
                    $.each(to_param, function(to_idx, to_pr) {
                        
                        if (fp_idx == to_idx) {
                            
                            if (return_value == true) {
                                var first_value = buy_sell_link_ui_insert.filter_Dealset1.getItemValue(fr_pr, true);
                                var second_value = buy_sell_link_ui_insert.filter_Dealset1.getItemValue(to_pr, true);
                                
                                if (first_value != '' && second_value != '') {
                                    
                                    // Convert value to number for comparing
                                    first_value = Date.parse(first_value);
                                    second_value = Date.parse(second_value);
                                    
                                    if (first_value > second_value) {
                                        
                                        show_messagebox(
                                            '<b>' + buy_sell_link_ui_insert.filter_Dealset1.getItemLabel(to_pr) + '</b>' +
                                            ' should be greater than <b>' + buy_sell_link_ui_insert.filter_Dealset1.getItemLabel(fr_pr) + '</b>' +
                                            ' on <b>Sell Deal</b>.'
                                        );

                                        return_value = false;
                                    } else {
                                        return_value = true;
                                    }
                                }
                            }
                        }
                    });
                });

                // return true/false
                return return_value;
            }

            /**
             * Validates Date From and To fields in Left.
             * @return {Boolean}
             */
            buy_sell_link_ui_insert.validate_from_and_to_right = function() {
                // From and to fields names in order
                var from_param = ['term_start', 'deal_date_from_2', 'create_ts_from_2'];
                var to_param = ['term_end', 'deal_date_to_2', 'create_ts_to_2'];
                
                // By default its set to true
                var return_value = true;

                
                // Loop for each of from and to names
                $.each(from_param, function(fp_idx, fr_pr) {
                    
                    $.each(to_param, function(to_idx, to_pr) {
                        
                        if (fp_idx == to_idx) {
                            
                            if (return_value == true) {
                                var first_value = buy_sell_link_ui_insert.filter_Dealset1.getItemValue(fr_pr, true);
                                var second_value = buy_sell_link_ui_insert.filter_Dealset1.getItemValue(to_pr, true);
                                
                                if (first_value != '' && second_value != '') {

                                    
                                    // Convert value to number for checking
                                    first_value = Date.parse(first_value);
                                    second_value = Date.parse(second_value);
                                    
                                    if (first_value > second_value) {
                                        
                                        show_messagebox(
                                            '<b>' + buy_sell_link_ui_insert.filter_Dealset1.getItemLabel(to_pr) + '</b>' +
                                            ' should be greater than <b>' + buy_sell_link_ui_insert.filter_Dealset1.getItemLabel(fr_pr) + '</b>'+
                                            ' on <b>Buy Deal</b>.'
                                        );

                                        return_value = false;
                                    } else {
                                        return_value = true;
                                    }
                                }
                            }
                        }
                    });
                });

                // return true/false
                return return_value;
            }

            buy_sell_link_ui_insert.load_match_grids = function(auto_manual) {
                for(var i=1; i<=2; i++) {
                    var attached_grid = (i == 1) ? buy_sell_link_ui_insert.left_grid : buy_sell_link_ui_insert.right_grid; 
                    if($('#mt_q' + i).length == 1) {
                        $('#mt_q'+i).text('0');
                        $('#rm_q'+i).text('0');
                        $('#av_q'+i).text('0');
                        $('#net_pos_'+i).text('0');

                    }
                }
                buy_sell_link_ui_insert.layout_link_ui_insert_inner3.cells('a').expand(); 
                buy_sell_link_ui_insert.layout_link_ui_insert_inner3.cells('b').expand();
                left_selected_grid_ids = '';

                buy_sell_link_ui_insert.match_criteria.clearNote('book_structure');
                buy_sell_link_ui_insert.filter_Dealset1.clearNote('book_structure');
                var validate_return1 = validate_form(buy_sell_link_ui_insert.filter_Dealset1);
                var validate_return3 = validate_form(buy_sell_link_ui_insert.match_criteria);
                
                
                if (auto_manual == 'manual') {
                    var validate_return2 = validate_form(buy_sell_link_ui_insert.filter_Dealset1);                  
                }
                

                if (validate_return1 === false || validate_return2 === false || validate_return3 === false) {
                    
                    if (validate_return1 === false) {
                        var bookstructure_validation_message1 = buy_sell_link_ui_insert.match_criteria.getUserData("book_structure", "validation_message");
                        
                        if (bookstructure_validation_message1 && buy_sell_link_ui_insert.match_criteria.getItemValue('book_structure') == '') {
                            
                            buy_sell_link_ui_insert.match_criteria.setNote('book_structure', {text:bookstructure_validation_message1});
                        }

                        
                    }
                    generate_error_message();
                    parent.enable_disable_deal_match_menu('refresh',true);
                    parent.enable_disable_deal_match_menu('match',true);
                    parent.enable_disable_deal_match_menu('auto',true);
                    
                    return;
                }

                buy_sell_link_ui_insert.layout_link_ui_insert.cells("a").collapse();
                //buy_sell_link_ui_insert.layout_link_ui_insert_inner1.cells("b").collapse();

                buy_sell_link_ui_insert.layout_link_ui_insert.cells('b').progressOn();

                for (i = 1; i <= 2; i ++) {
                    
                    var attached_obj = (i == 1) ? buy_sell_link_ui_insert.filter_Dealset1 : buy_sell_link_ui_insert.filter_Dealset1;
                    var attached_grid = (i == 1) ? buy_sell_link_ui_insert.left_grid : buy_sell_link_ui_insert.right_grid;
                    
                    var att_obj = buy_sell_link_ui_insert.match_criteria;
                    var match_criteria_data = att_obj.getFormData(true);
                    

                    if (auto_manual == 'auto' && i == 2) {

                        buy_sell_link_ui_insert.right_grid.clearAll();

                        // if ($('#mt_q' + i).length == 1) {
                        //     attached_grid.detachFooter(0);
                        // }

                        buy_sell_link_ui_insert.layout_link_ui_insert.cells('b').collapse();
                        return;                
                    }
                    
                    // if ($('#mt_q'+i).length == 1) {
                    //     attached_grid.detachFooter(0);
                    // }

                    var filter_xml = "<Root><FormXML ";

                    var filter_data = attached_obj.getFormData(true);
                    
                    var technology = 'NULL';
                    var jurisdiction = 'NULL';            
                    var not_technology = 'NULL';
                    var not_jurisdiction  = 'NULL';
                    var deal_detail_status = 'NULL';            
                    var tier_type = 'NULL';
                    var nottier_type = 'NULL';
                    var vintage_year = 'NULL';
                    var region_id = 'NULL';
                    var not_region_id = 'NULL';            
                    
                    // Newly Added
                    var delivery_date_from = 'NULL';
                    var delivery_date_to = 'NULL';
                    var description = 'NULL';
                    var volume_match = 'NULL';
                    var product_classification = 'NULL';
                    var include_expired_deals = 'NULL';
                    var show_all_deals = 'NULL';
                    var buy_sell = (i == 1) ? 's':'b';
                    var effective_date = 'NULL';
                    var book_structure_xml = '' ;
                    var book_structure_xml_buy = '' ;

                    for (var a in match_criteria_data) {

                        field_label = a;
                        field_value = match_criteria_data[a];

                        if(field_label == 'volume_match'){

                            field_value = match_criteria_data[a];
                            
                            //if (field_value != '' && field_value != null) volume_match = field_value;
                            
                            continue;
                        }

                        if(field_label == 'show_all_deals'){
                            field_value = match_criteria_data[a];
                            
                            if (field_value != '' && field_value != null) show_all_deals = field_value;
                            
                            continue;
                        }

                         if (field_label == 'apply_filters' 
                            || field_label == 'book_structure' 
                            || field_label == 'subsidiary_id' 
                            || field_label == 'strategy_id' 
                            || field_label == 'book_id' 
                            || field_label == 'volume_min'  
                            || field_label == 'volume_max'
                        ) {

                            continue;
                        }

                        if (field_label  == 'subbook_id') {
                            field_label = 'sub_book_ids';
                        }
                        book_structure_xml += " " + field_label + "=\"" + field_value + "\"";  


                    }
                    

                    for (var a in filter_data) {

                        field_label = a;
                        if(field_label.indexOf('_2')>-1 && i == 1)  {
                            continue;    
                        }

                        
                        if (field_label  == 'book_structure_1' && i == 1) {
                            field_label = 'sub_book_ids';
                            continue;
                        }
                        
                        if (field_label  == 'book_structure_1' && i == 2) {

                            field_label = 'sub_book_ids';
                            field_value = filter_data[a];
                            book_structure_xml_buy += " " + field_label + "=\"" + field_value + "\""; 
                            continue;
                        }

                        if(field_label.indexOf('_2') == -1 && i == 2)  {
                            continue;
                        }

                        field_label = field_label.replace('_2','');

                        if (field_label == 'deal_detail_status') {
                            field_value = filter_data[a];
                            if (field_value != '' && field_value != null) deal_detail_status = field_value;
                            
                            continue;
                        }     

                        if (field_label == 'tier_type') {
                            field_value = filter_data[a];
                            
                            if (field_value != '' && field_value != null) tier_type = field_value;
                            
                            continue;
                        }

                        if (field_label == 'nottier_type') {
                            field_value = filter_data[a];
                            
                            if (field_value != '' && field_value != null) nottier_type = field_value;
                            
                            continue;
                        }
                        
                        if (field_label == 'vintage_year') {
                            field_value = filter_data[a];
                            
                            if (field_value != '' && field_value != null) vintage_year = field_value;
                            
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

                        if (field_label == 'jurisdiction') {
                            field_value = filter_data[a];
                            
                            if (field_value != '' && field_value != null) jurisdiction  = field_value;
                            
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
                        if (field_label == 'not_jurisdiction') {
                            field_value = filter_data[a];
                            
                            if (field_value != '' && field_value != null) not_jurisdiction  = field_value;
                            
                            continue;
                        }

                        // Newly Added
                        if (field_label == 'description') {
                            field_value = filter_data[a];
                            
                            if (field_value != '' && field_value != null) description = field_value;
                            
                            continue;
                        }

                        if (field_label == 'include_expired_deals') {
                            field_value = filter_data[a];
                            
                            if (field_value != '' && field_value != null) include_expired_deals = field_value;
                            
                            continue;
                        }

                        if (field_label == 'product_classification') {
                            field_value = filter_data[a];
                            
                            if (field_value != '' && field_value != null) product_classification = field_value;
                            
                            continue;
                        }


                        if (field_label == 'delivery_date_from') {
                            field_value = filter_data[a];
                            
                            if (field_value != '' && field_value != null) delivery_date_from = field_value;
                            
                            continue;
                        }

                        if (field_label == 'delivery_date_to') {                    
                            field_value = filter_data[a];
                            
                            if (field_value != '' && field_value != null) delivery_date_to = field_value;
                            
                            continue;
                        }

                        if (field_label == 'effective_date') {                    
                            field_value = filter_data[a];
                            
                            if (field_value != '' && field_value != null) effective_date = field_value;
                            
                            continue;
                        }
                        
                        if (field_label == 'apply_filters' 
                            || field_label == 'book_structure' 
                            || field_label == 'subsidiary_id' 
                            || field_label == 'strategy_id' 
                            || field_label == 'book_id' 
                            || field_label == 'volume_min'  
                            || field_label == 'volume_max'
                        ) {

                            continue;
                        }

                        field_value = filter_data[a];
                        if (attached_obj.getItemType(a) == 'calendar') {
                            field_value = attached_obj.getItemValue(a, true);
                        } 
                        
                        
                        filter_xml += " " + field_label + "=\"" + field_value + "\"";                
                    }
                    

                    if (auto_manual == 'auto') {
                        filter_xml += ' filter_mode="a"';
                        
                    } else {
                        filter_xml += ' filter_mode="m"';
                        
                    }

                    filter_xml += ' buy_sell_id="' + buy_sell + '" source_deal_header_id_from="" source_deal_header_id_to="" deal_id="" view_deleted="n" show_unmapped_deals="n" deal_locked="" book_ids="" view_voided="n" source_system_book_id1="" source_system_book_id2="" source_system_book_id3="" source_system_book_id4="" view_detail="y" ';
                     
                    if(trim(book_structure_xml_buy) == 'sub_book_ids=""' || book_structure_xml_buy == ''){
                        filter_xml += ' '+book_structure_xml;
                    }
                    else{
                       filter_xml += ' '+book_structure_xml_buy; 
                    }
                    
                    filter_xml += "></FormXML></Root>";


                                       
                    technology = (technology != 'NULL') ? "'" + technology + "'" : 'NULL';
                    not_technology = (not_technology != 'NULL') ? "'" + not_technology + "'" : 'NULL';
                    jurisdiction  = (jurisdiction  != 'NULL') ? "'" + jurisdiction  + "'" : 'NULL';
                    not_jurisdiction  = (not_jurisdiction  != 'NULL') ? "'" + not_jurisdiction  + "'" : 'NULL';            
                    region_id = (region_id != 'NULL') ? "'" + region_id + "'" : 'NULL';
                    not_region_id = (not_region_id != 'NULL') ? "'" + not_region_id + "'" : 'NULL';
                    deal_detail_status = (deal_detail_status != 'NULL') ? "'" + deal_detail_status + "'" : 'NULL';            
                    tier_type = (tier_type != 'NULL') ? "'" + tier_type + "'" : 'NULL';
                    nottier_type = (nottier_type != 'NULL') ? "'" + nottier_type + "'" : 'NULL';
                    vintage_year = (vintage_year != 'NULL') ? "'" + vintage_year + "'" : 'NULL';            
                    
                    // Newly added
                    delivery_date_from = (delivery_date_from != 'NULL') ? "'" + delivery_date_from + "'" : 'NULL';
                    delivery_date_to = (delivery_date_to != 'NULL') ? "'" + delivery_date_to + "'" : 'NULL';
                    effective_date = (effective_date != 'NULL') ? "'" + effective_date + "'" : 'NULL';
                    description = (description != 'NULL') ? "'" + description + "'" : 'NULL';
                    product_classification = (product_classification != 'NULL') ? "'" + product_classification + "'" : 'NULL';
                    volume_match = (volume_match != 'NULL') ? "'" + volume_match + "'" : 'NULL';
                    include_expired_deals = (include_expired_deals != 'NULL') ? '' + include_expired_deals + '' : 'n';
                    show_all_deals = (show_all_deals != 'NULL') ? '' + show_all_deals + '' : 'n';

                    show_all_deals = (auto_manual == 'manual') ? 'y' : show_all_deals;

                    var sql_stmt = "EXEC spa_buy_sell_match @flag = 'g', @xmlValue = ' " + filter_xml + 
                        "', @technology=" + technology + ", @jurisdiction =" + jurisdiction  + 
                        ", @not_technology=" + not_technology + ", @not_jurisdiction =" + not_jurisdiction  +
                        ", @deal_detail_status=" + deal_detail_status +", @tier_type=" + tier_type + 
                        ", @nottier_type=" + nottier_type + ", @vintage_year=" + vintage_year + 
                        ", @region_id=" + region_id + ", @not_region_id=" + not_region_id + 
                        ", @delivery_date_from=" + delivery_date_from + ", @delivery_date_to=" + delivery_date_to + 
                        ", @description = " + description + ", @volume_match = " + volume_match + 
                        ", @include_expired_deals = '" + include_expired_deals + "', @show_all_deals = '" + show_all_deals + 
                        "', @product_classification = " + product_classification + ", @effective_date = " + effective_date + "";
                    
                    var sql_param = {
                        "sql": sql_stmt,
                        "grid_type": "tg",
                        "grouping_column": "source_deal_header_id",
                        "grouping_type": 3
                    };
                    
                    sql_param = $.param(sql_param);
                    
                    var sql_url = js_data_collector_url + "&" + sql_param;
                    attached_grid.clearAndLoad(sql_url);
                }
            }

            buy_sell_link_ui_insert.post_grid_XLE = function(grid_obj, set) {
                var actual_volume_col_index = grid_obj.getColIndexById("actual_volume");
                var matched_col_index = grid_obj.getColIndexById("matched");
                var remaining_col_index = grid_obj.getColIndexById("remaining");
                var price_col_index = grid_obj.getColIndexById("price");
                var vp_value_col_index = grid_obj.getColIndexById("vp_value");

                grid_obj.forEachRow(function(id){
                    
                    if (grid_obj.hasChildren(id)) {
                        var childs = grid_obj.getSubItems(id);

                        var child1 = childs.split(',')[0];

                        var g_actual_volume = sumColumnRowSelect(grid_obj, actual_volume_col_index, childs);
                        var g_matched = sumColumnRowSelect(grid_obj, matched_col_index, childs);
                        var g_remaining = sumColumnRowSelect(grid_obj, remaining_col_index, childs);
                        var g_price = averageColumnRowSelect(grid_obj, price_col_index, childs);
                        var g_vp_value = sumColumnRowSelect(grid_obj, vp_value_col_index, childs);

                        grid_obj.cells(id, actual_volume_col_index).setValue(g_actual_volume.toFixed(2));
                        grid_obj.cells(id, matched_col_index).setValue(g_matched.toFixed(2));
                        grid_obj.cells(id, remaining_col_index).setValue(g_remaining.toFixed(2));
                        grid_obj.cells(id, price_col_index).setValue(g_price.toFixed(2));
                        grid_obj.cells(id, vp_value_col_index).setValue(g_vp_value.toFixed(2));
                    }
                });

                buy_sell_link_ui_insert.load_grid_footer2(grid_obj, set);
            }

            buy_sell_link_ui_insert.get_match_grids = function(process_id_manual_case) {
                var left_grid_select_id = buy_sell_link_ui_insert.left_grid.getSelectedRowId();
                var right_grid_select_id = buy_sell_link_ui_insert.right_grid.getSelectedRowId();

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

                    if (buy_sell_link_ui_insert.left_grid.hasChildren(left_grid_select_id_arr[i])) {
                        left_grid_select_id_arr.splice(i, 1)
                    } 
                }

                for (var i = 0; i<right_grid_select_id_arr.length; i++) {
                    
                    if (buy_sell_link_ui_insert.right_grid.hasChildren(right_grid_select_id_arr[i])) {
                        right_grid_select_id_arr.splice(i, 1);
                    } 
                }

                // Sorted Array of Deals
                left_grid_select_id_arr.sort(function(a,b){
                    return a - b;
                })

                right_grid_select_id_arr.sort(function(a,b){
                    return a - b;
                })

                // Get total remaining for Deal Set 1 and Deal Set 2
                var left_remaining_total = 0;
                
                left_grid_select_id_arr.forEach(function(row_id) {
                    
                    buy_sell_link_ui_insert.left_grid.forEachCell(row_id, function(cellObj, ind){
                        
                        if (buy_sell_link_ui_insert.left_grid.getColumnId(ind) == 'source_deal_detail_id') {
                            dealset1_arr.push(cellObj.getValue());
                        }

                        if (buy_sell_link_ui_insert.left_grid.getColumnId(ind) == 'remaining') {
                            left_remaining_total += parseFloat(cellObj.getValue());
                        }
                    });
                });

                var right_remaining_total = 0;
                
                right_grid_select_id_arr.forEach(function(row_id) {
                    
                    buy_sell_link_ui_insert.right_grid.forEachCell(row_id, function(cellObj, ind){
                        
                        if (buy_sell_link_ui_insert.right_grid.getColumnId(ind) == 'source_deal_detail_id') {
                            dealset2_arr.push(cellObj.getValue());
                        }

                        if (buy_sell_link_ui_insert.right_grid.getColumnId(ind) == 'remaining') {
                            right_remaining_total += parseFloat(cellObj.getValue());
                        }
                    });
                });

               
                //Validation for same deals matched
                var common_dealset_arr = _.intersection(dealset1_arr, dealset2_arr);

                if (common_dealset_arr.length > 0) {
                    validated = false;
                    
                    error_json =  {
                        title: 'Alert', 
                        type: 'alert', 
                        text: 'Same Deal(s) are selected.'
                    };
                }
                
                var lowest_remaining_total = (left_remaining_total < right_remaining_total) ? left_remaining_total : right_remaining_total;        
           
                var remaining_total = parseFloat(lowest_remaining_total);
                var remaining_total2 = parseFloat(lowest_remaining_total);

                var actual_volume_col_index =  buy_sell_link_ui_insert.left_grid.getColIndexById("actual_volume");
                var remaining_col_index =  buy_sell_link_ui_insert.left_grid.getColIndexById("remaining");
                var matched_col_index =  buy_sell_link_ui_insert.left_grid.getColIndexById("matched");
                var source_deal_detail_id_col_index =  buy_sell_link_ui_insert.left_grid.getColIndexById("source_deal_detail_id");
                var source_deal_header_id_col_index =  buy_sell_link_ui_insert.left_grid.getColIndexById("source_deal_header_id");
                var process_id_grid_index = buy_sell_link_ui_insert.right_grid.getColIndexById('process_id');

                return_json += '{left_grid_ui: [{rows:[';

                left_grid_select_id_arr.forEach(function(row_id) {
                    return_json += '{source_deal_header_id: ';
                    
                    if (buy_sell_link_ui_insert.left_grid.cells(row_id, source_deal_header_id_col_index).getValue()=='') {
                        
                        if (!buy_sell_link_ui_insert.left_grid.hasChildren(row_id)) {
                            var parent_id = buy_sell_link_ui_insert.left_grid.getParentId(row_id);
                            return_json += buy_sell_link_ui_insert.left_grid.cells(parent_id, source_deal_header_id_col_index).getValue();
                        } else {
                            return_json += "\"\"";
                        }

                    } else {
                        return_json += buy_sell_link_ui_insert.left_grid.cells(row_id, source_deal_header_id_col_index).getValue();
                    }

                    return_json += ',source_deal_detail_id: ';

                    if (buy_sell_link_ui_insert.left_grid.cells(row_id, source_deal_detail_id_col_index).getValue()=='') {
                        return_json += "\"\"";
                    } else {
                        return_json += buy_sell_link_ui_insert.left_grid.cells(row_id, source_deal_detail_id_col_index).getValue();
                    }

                    return_json += ', actual_volume: "';

                    if (buy_sell_link_ui_insert.left_grid.cells(row_id, actual_volume_col_index).getValue() == '') {
                        return_json += 0 + '" ';
                    } else {
                        return_json += buy_sell_link_ui_insert.left_grid.cells(row_id, actual_volume_col_index).getValue() + '" ';
                    }

                    

                    return_json += ',vintage_year: "", expiration_date: "", sequence_from: "", sequence_to: "" ';
                    
                    buy_sell_link_ui_insert.left_grid.forEachCell(row_id,function(cellObj,ind) {
                        
                        if (buy_sell_link_ui_insert.left_grid.getColumnId(ind) == 'matched') {
                            var actual_volume_left = buy_sell_link_ui_insert.left_grid.cells(row_id,actual_volume_col_index).getValue();
                            
                            if (remaining_total > parseFloat(actual_volume_left) - parseFloat(cellObj.getValue())) {
                                return_json += ',matched:"' + (parseFloat(actual_volume_left) - parseFloat(cellObj.getValue())) + '"';                            
                            } else {
                                return_json += ',matched:"' + remaining_total + '"';        
                            }

                            //Remaining
                            var remaining_left = buy_sell_link_ui_insert.left_grid.cells(row_id, remaining_col_index).getValue();
                            
                            if (remaining_total >= parseFloat(remaining_left)) {
                                remaining_total = remaining_total - parseFloat(remaining_left); 
                            } else {
                                remaining_total = 0;        
                            }
                        } else if (buy_sell_link_ui_insert.left_grid.getColumnId(ind) == 'remaining') {
                            
                            if (remaining_total2 >= parseFloat(cellObj.getValue())) {
                                remaining_total2 = remaining_total2 - parseFloat(cellObj.getValue());  
                                return_json += ',remaining:0';
                            } else {
                                return_json += ',remaining:' + (parseFloat(cellObj.getValue()) - remaining_total2);
                                remaining_total2 = 0;        
                            } 
                        }
                    });

                    return_json += '},';
                });

                return_json += ']},]},';

                var remaining_total = parseFloat(lowest_remaining_total);
                var remaining_total2 = parseFloat(lowest_remaining_total);
                var actual_volume_col_index =  buy_sell_link_ui_insert.right_grid.getColIndexById("actual_volume");
                var remaining_col_index =  buy_sell_link_ui_insert.right_grid.getColIndexById("remaining");
                var matched_col_index =  buy_sell_link_ui_insert.right_grid.getColIndexById("matched");
                var source_deal_detail_id_col_index =  buy_sell_link_ui_insert.right_grid.getColIndexById("source_deal_detail_id");
                var source_deal_header_id_col_index =  buy_sell_link_ui_insert.right_grid.getColIndexById("source_deal_header_id");
                var vintage_year_col_index =  buy_sell_link_ui_insert.right_grid.getColIndexById("vintage_year");
                var exp_date_col_index =  buy_sell_link_ui_insert.right_grid.getColIndexById("expiration_date");
                var sequence_from_index =  buy_sell_link_ui_insert.right_grid.getColIndexById("sequence_from");
                var sequence_to_index =  buy_sell_link_ui_insert.right_grid.getColIndexById("sequence_to");

                return_json += '{right_grid_ui: [{rows:[';
                
                right_grid_select_id_arr.forEach(function(row_id) {
                    return_json += '{source_deal_header_id: ';
                    
                    if (buy_sell_link_ui_insert.right_grid.cells(row_id, source_deal_header_id_col_index).getValue()=='') {
                        
                        if (!buy_sell_link_ui_insert.right_grid.hasChildren(row_id)) {
                            var parent_id = buy_sell_link_ui_insert.right_grid.getParentId(row_id);
                            return_json += buy_sell_link_ui_insert.right_grid.cells(parent_id, source_deal_header_id_col_index).getValue();
                        } else {
                            return_json += 0;
                        }
                    } else {
                        return_json += buy_sell_link_ui_insert.right_grid.cells(row_id, source_deal_header_id_col_index).getValue();
                    }

                    return_json += ', source_deal_detail_id: ';
                    
                    if (buy_sell_link_ui_insert.right_grid.cells(row_id, source_deal_detail_id_col_index).getValue() == '') {
                        return_json += 0;
                    } else {
                        return_json += buy_sell_link_ui_insert.right_grid.cells(row_id, source_deal_detail_id_col_index).getValue();
                    }

                    return_json += ', vintage_year: ';

                    if (buy_sell_link_ui_insert.right_grid.cells(row_id, vintage_year_col_index).getValue() == '') {
                        return_json += 0;
                    } else {
                        return_json += buy_sell_link_ui_insert.right_grid.cells(row_id, vintage_year_col_index).getValue();
                    }

                    return_json += ', expiration_date: "';

                    if (buy_sell_link_ui_insert.right_grid.cells(row_id, exp_date_col_index).getValue() == '') {
                        return_json += 0 + '" ';
                    } else {
                        return_json += buy_sell_link_ui_insert.right_grid.cells(row_id, exp_date_col_index).getValue() + '" ';
                    }

                    return_json += ', sequence_from: "';

                    if (buy_sell_link_ui_insert.right_grid.cells(row_id, sequence_from_index).getValue() == '') {
                        return_json += 0 + '" ';
                    } else {
                        return_json += buy_sell_link_ui_insert.right_grid.cells(row_id, sequence_from_index).getValue() + '" ';
                    }

                    return_json += ', actual_volume: "';

                    if (buy_sell_link_ui_insert.right_grid.cells(row_id, actual_volume_col_index).getValue() == '') {
                        return_json += 0 + '" ';
                    } else {
                        return_json += buy_sell_link_ui_insert.right_grid.cells(row_id, actual_volume_col_index).getValue() + '" ';
                    }

                    return_json += ', sequence_to: "';

                    if (buy_sell_link_ui_insert.right_grid.cells(row_id, sequence_to_index).getValue() == '') {
                        return_json += 0 + '" ';
                    } else {
                        return_json += buy_sell_link_ui_insert.right_grid.cells(row_id, sequence_to_index).getValue() + '" ';
                    }

                    buy_sell_link_ui_insert.right_grid.forEachCell(row_id, function(cellObj, ind){
                        
                        if (buy_sell_link_ui_insert.right_grid.getColumnId(ind) == 'matched') {
                            var actual_volume_right = buy_sell_link_ui_insert.right_grid.cells(row_id, actual_volume_col_index).getValue();
                            
                            if (remaining_total > parseFloat(actual_volume_right) - parseFloat(cellObj.getValue())) {
                                return_json += ',matched:"' + (parseFloat(actual_volume_right) - parseFloat(cellObj.getValue())) + '"';                            
                            } else {
                                return_json += ',matched:"' + remaining_total + '"';        
                            }

                            //Remaining
                            var remaining_right = buy_sell_link_ui_insert.right_grid.cells(row_id, remaining_col_index).getValue();
                            
                            if (remaining_total >= parseFloat(remaining_right)) {
                                remaining_total = remaining_total - parseFloat(remaining_right); 
                            } else {
                                remaining_total = 0;        
                            }
                        } else if (buy_sell_link_ui_insert.right_grid.getColumnId(ind) == 'remaining') {
                            
                            if (remaining_total2 >= parseFloat(cellObj.getValue())) {
                                remaining_total2 = remaining_total2 - parseFloat(cellObj.getValue());  
                                return_json += ',remaining:0';
                            } else {                        
                                return_json += ',remaining:' + (parseFloat(cellObj.getValue()) - remaining_total2) + '';
                                remaining_total2 = 0;        
                            }
                        }
                    });

                    var auto_manual_text = parent.inner_menu_obj["-1"].getItemText('auto');
                    var process_id_grid;
                    
                    if (auto_manual_text == 'Manual') {
                        process_id_grid = process_id_manual_case;
                    } else {
                        process_id_grid = buy_sell_link_ui_insert.right_grid.cells(row_id, process_id_grid_index).getValue();
                    }

                    return_json += ',process_id: "' + process_id_grid + '"';
                    return_json += '},'
                });

                return_json += ']},]},';

                if (validated) {
                    return '{grids:[' + return_json + ']}';
                } else {
                    return error_json; 
                }
            }
    
            buy_sell_link_ui_insert.left_grid_row_state_change = function(rIds) {

				if (rIds != null) {

                   var diff = left_selected_grid_ids.split(',').filter(function(x) {
                        return rIds.split(',').indexOf(x) < 0 
                    })

                    left_selected_grid_ids = rIds;

                    var new_diff = new Array();

                    if (diff[0] != "") {

                        for (var i = 0; i < diff.length; i++) {
                            
                            if (buy_sell_link_ui_insert.left_grid.hasChildren(diff[i])) {
                                var childs = buy_sell_link_ui_insert.left_grid.getAllSubItems(diff[i]);
                                childs_arr = childs.split(',');
                                var child_count = 0;
                                
                                for (var a = 0; a < childs_arr.length; a++) {
                                    if (rIds.split(',').indexOf(childs_arr[a]) > -1) {
                                        child_count++;
                                    }
                                }

                                if (child_count == childs_arr.length) {
                                    new_diff.push(diff[i]);
                                }

                            }
                        }

                        if (new_diff.length > 0) {
                            
                            for (var i = 0; i < new_diff.length; i++) {
                                buy_sell_link_ui_insert.left_grid.closeItem(new_diff[i]);
                                var childs = buy_sell_link_ui_insert.left_grid.getAllSubItems(new_diff[i]);
                                buy_sell_link_ui_insert.left_grid.clearSelectionRowId(childs);
                            }

                            left_grid_select_ids = buy_sell_link_ui_insert.left_grid.getSelectedRowId();
                        }
                    }
                }        

                buy_sell_link_ui_insert.grid_row_select_post();
            }

            buy_sell_link_ui_insert.right_grid_row_state_change = function(rIds) { 
				   	   
                if (rIds != null) {
					right_selected_grid_ids = '';
                    var diff_r = right_selected_grid_ids.split(',').filter(function(x) {
                        return rIds.split(',').indexOf(x) < 0 
                    });
					
				   right_selected_grid_ids = rIds;
				
                    var new_diff = new Array();
                        
                    if (diff_r[0] != "") {
                            
                        for (var i=0; i < diff_r.length; i++ ) {
                            
                            if (buy_sell_link_ui_insert.right_grid.hasChildren(diff_r[i])) {
                                var childs = buy_sell_link_ui_insert.right_grid.getAllSubItems(diff_r[i]);
                                childs_arr = childs.split(',');
                                var child_count = 0;
                                
                                for (var a = 0; a < childs_arr.length; a++) {
                                    
                                    if (rIds.split(',').indexOf(childs_arr[a]) > -1) {
                                        child_count++;
                                    }
                                }

                                if (child_count == childs_arr.length) {
                                    new_diff.push(diff_r[i]);
                                }
                            }
                        }

                        if (new_diff.length > 0) {
                            
                            for (var i = 0; i < new_diff.length; i++ ) {
                                buy_sell_link_ui_insert.right_grid.closeItem(new_diff[i]);
                                var childs = buy_sell_link_ui_insert.right_grid.getAllSubItems(new_diff[i]);
                                buy_sell_link_ui_insert.right_grid.clearSelectionRowId(childs);
                            }
                        }
                    }
                }
                buy_sell_link_ui_insert.grid_row_select_post();
            }

            buy_sell_link_ui_insert.left_grid_before_row_select = function(new_row,old_row,new_col_index){
                var left_grid_select_ids = buy_sell_link_ui_insert.left_grid.getSelectedRowId();
                
                if (left_grid_select_ids != null) {
                    var left_grid_select_id_arr = left_grid_select_ids.split(',');

                    if (left_grid_select_id_arr.indexOf(new_row) > -1 && buy_sell_link_ui_insert.left_grid.hasChildren(new_row)) {
                        return false;
                    }
                }

                return true;
            }

            buy_sell_link_ui_insert.right_grid_before_row_select = function(new_row,old_row,new_col_index){
                var right_grid_select_ids = buy_sell_link_ui_insert.right_grid.getSelectedRowId();
                
                if (right_grid_select_ids != null) {
                    var right_grid_select_id_arr = right_grid_select_ids.split(',');
                    
                    if (right_grid_select_id_arr.indexOf(new_row) > -1 && buy_sell_link_ui_insert.right_grid.hasChildren(new_row)) {
                        return false;
                    }
                }

                return true;
            }

           /* buy_sell_link_ui_insert.buy_grid_row_select = function(rId, cInd) {
                buy_sell_link_ui_insert.grid_row_select(rId, cInd, 'b');
            }*/

            buy_sell_link_ui_insert.sell_grid_row_select = function(rId, cInd) {
                buy_sell_link_ui_insert.layout_link_ui_insert_inner3.cells('b').expand();
                var is_parent = buy_sell_link_ui_insert.left_grid.getLevel(rId);
                var has_children = buy_sell_link_ui_insert.left_grid.hasChildren(rId);
                //buy_sell_link_ui_insert.right_grid_menu.setItemEnabled('refresh_buy_deal');

                if(parent.inner_menu_obj["-1"].getItemText('auto') == "Auto" && ((is_parent == 0 && has_children == 0) || (is_parent == 1 && has_children == 0))) {
                        if(!buy_sell_link_ui_insert.match_criteria.isItemChecked('show_all_deals')) {
                            buy_sell_link_ui_insert.right_grid_menu.setItemEnabled('match_all');
                        }
                        
                        buy_sell_link_ui_insert.right_grid_menu.setItemEnabled('refresh_buy_deal');
                 } else if(is_parent == 0 && has_children > 0) {
                    buy_sell_link_ui_insert.right_grid_menu.setItemDisabled('match_all');
                    buy_sell_link_ui_insert.right_grid_menu.setItemDisabled('refresh_buy_deal');
                }
                //buy_sell_link_ui_insert.grid_row_select(rId, cInd, 's');
            }

            buy_sell_link_ui_insert.buy_deal_grid_refresh = function(buy_sell, call_from) {

                var left_grid_select_ids = buy_sell_link_ui_insert.left_grid.getSelectedRowId();        

                if (left_grid_select_ids != null) {
                    var left_grid_select_id_arr = left_grid_select_ids.split(',');
                    
                    for(var i = 0; i < left_grid_select_id_arr.length; i++) {
                        var left_grid_select_id = left_grid_select_id_arr[i];
                    }
                }

                var active_tab = parent.get_active_tab_id();
                var btn_text = parent.inner_menu_obj[active_tab].getItemText('auto');

                if (buy_sell === 'b') {
                    var filter_form_status = validate_form(buy_sell_link_ui_insert.filter_Dealset1);
                    if((buy_sell_link_ui_insert.left_grid.getLevel(left_grid_select_ids) == 0 && buy_sell_link_ui_insert.left_grid.hasChildren(left_grid_select_ids) > 0)) {
                        return;
                    }

                    if (!filter_form_status) {
                        buy_sell_link_ui_insert.layout_link_ui_insert.cells('b').expand();
                        return;
                    } 
                    var left_grid_select_ids = buy_sell_link_ui_insert.left_grid.getSelectedRowId();
                    var deal_id = buy_sell_link_ui_insert.left_grid.getColIndexById("source_deal_header_id");
                    var sell_detail_id = buy_sell_link_ui_insert.left_grid.getColIndexById('source_deal_detail_id');
                    var sdd_id;

                    var sdh_id;

                    if (buy_sell_link_ui_insert.left_grid.getLevel(left_grid_select_ids) <= 0) {

                        
                        var new_id = left_grid_select_ids.split(',').filter(function (e) {
                          return e.indexOf('_') == -1;
                        })[0];

                        sdh_id = buy_sell_link_ui_insert.left_grid.cells(new_id, deal_id).getValue();
                    } else {
                        var parent_id = buy_sell_link_ui_insert.left_grid.getParentId(left_grid_select_ids);
                        sdh_id = buy_sell_link_ui_insert.left_grid.cells(parent_id, deal_id).getValue();
                    }


                    buy_sell_link_ui_insert.layout_link_ui_insert_inner3.cells('a').progressOn();
                    

                    sdd_id = buy_sell_link_ui_insert.left_grid.cells(left_grid_select_ids, sell_detail_id).getValue();
                    //buy_sell_link_ui_insert.layout_link_ui_insert_inner1.cells('c').progressOn();


                    var attached_obj = buy_sell_link_ui_insert.filter_Dealset1;
                    var attached_grid = buy_sell_link_ui_insert.right_grid;
                    var att_obj = buy_sell_link_ui_insert.match_criteria;

                    

                    var filter_xml = "<Root><FormXML ";

                    var filter_data = attached_obj.getFormData(true);
                    var match_criteria_data = att_obj.getFormData(true);


                    var technology = 'NULL';
                    var jurisdiction = 'NULL';      
                    var not_technology = 'NULL';
                    var not_jurisdiction  = 'NULL';
                    var deal_detail_status = 'NULL';
                    var tier_type = 'NULL';
                    var nottier_type = 'NULL';
                    var vintage_year = 'NULL';
                    var region_id = 'NULL';
                    var not_region_id = 'NULL';            
                    // Newly Added
                    var delivery_date_from = 'NULL';
                    var delivery_date_to = 'NULL';
                    var description = 'NULL';
                    var volume_match = 'NULL';
                    var product_classification = 'NULL';
                    var include_expired_deals = 'NULL';
                    var show_all_deals = 'NULL';
                    var effective_date = 'NULL';
                    var book_structure_xml = '';
                    var book_structure_xml_buy = '';

                    for (var a in match_criteria_data) {

                        field_label = a;
                        field_value = match_criteria_data[a];
                        
                        if(field_label == 'volume_match'){
                            field_value = match_criteria_data[a];
                            
                            if (field_value != '' && field_value != null) volume_match = field_value;
                            
                            continue;
                        }

                        if(field_label == 'show_all_deals'){
                            field_value = match_criteria_data[a];
                            
                            if (field_value != '' && field_value != null) show_all_deals = field_value;
                            
                            continue;
                        }

                        if (field_label == 'apply_filters' 
                            || field_label == 'book_structure' 
                            || field_label == 'subsidiary_id' 
                            || field_label == 'strategy_id' 
                            || field_label == 'book_id' 
                            || field_label == 'volume_min'  
                            || field_label == 'volume_max'
                        ) {

                            continue;
                        }
                        
                        if (field_label  == 'subbook_id') {
                            field_label = 'sub_book_ids';
                        }
                        book_structure_xml += " " + field_label + "=\"" + field_value + "\"";
                    }
                    
                    

                    for (var a in filter_data) {

                        field_label = a;

                        if (field_label  == 'book_structure_1') {

                            field_label = 'sub_book_ids';
                            field_value = filter_data[a];
                            book_structure_xml_buy += " " + field_label + "=\"" + field_value + "\""; 
                            continue;
                        }

                        if(field_label.indexOf('_2') == -1 )  {
                            continue;
                        }
                        
                        field_label = field_label.replace('_2','');

                        if (field_label == 'deal_detail_status') {
                            field_value = filter_data[a];
                            
                            if (field_value != '' && field_value != null) deal_detail_status = field_value;
                            
                            continue;
                        }
                        
                        if (field_label == 'tier_type') {
                            field_value = filter_data[a];
                            
                            if (field_value != '' && field_value != null) tier_type = field_value;
                            

                            continue;
                        }

                        if (field_label == 'nottier_type') {
                            field_value = filter_data[a];
                            
                            if (field_value != '' && field_value != null) nottier_type = field_value;
                            
                            continue;
                        }

                        if (field_label == 'vintage_year') {
                            field_value = filter_data[a];
                            
                            if (field_value != '' && field_value != null) vintage_year = field_value;
                            
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

                        if (field_label == 'jurisdiction') {
                            field_value = filter_data[a];
                            
                            if (field_value != '' && field_value != null) jurisdiction  = field_value;
                            
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

                        if (field_label == 'not_jurisdiction') {
                            field_value = filter_data[a];
                            
                            if (field_value != '' && field_value != null) not_jurisdiction  = field_value;
                            
                            continue;
                        }

                        // Newly Added
                        if (field_label == 'description') {
                            field_value = filter_data[a];
                            
                            if (field_value != '' && field_value != null) description = field_value;
                            
                            continue;
                        }

                        if (field_label == 'include_expired_deals') {
                            field_value = filter_data[a];
                            
                            if (field_value != '' && field_value != null) include_expired_deals = field_value;
                            
                            continue;
                        }

                        if (field_label == 'show_all_deals') {
                            field_value = filter_data[a];
                            
                            if (field_value != '' && field_value != null) show_all_deals = field_value;
                            
                            continue;
                        }

                        if (field_label == 'product_classification') {
                            field_value = filter_data[a];
                            
                            if (field_value != '' && field_value != null) product_classification = field_value;
                            
                            continue;
                        }

                        if (field_label == 'volume_match') {
                            field_value = filter_data[a];
                            
                            if (field_value != '' && field_value != null) volume_match = field_value;
                            
                            continue;
                        }

                        if (field_label == 'delivery_date_from') {
                            field_value = filter_data[a];
                            
                            if (field_value != '' && field_value != null) delivery_date_from = field_value;
                            
                            continue;
                        }

                        if (field_label == 'delivery_date_to') {
                            field_value = filter_data[a];
                            
                            if (field_value != '' && field_value != null) delivery_date_to = field_value;
                            
                            continue;
                        }

                        if (field_label == 'effective_date') {
                            field_value = filter_data[a];
                            
                            if (field_value != '' && field_value != null) effective_date = field_value;
                            
                            continue;
                        }

                        if (sdd_id == ''){
                            sdd_id = null
                        }
                        
                        if (field_label == 'apply_filters'
                            || field_label == 'book_structure' 
                            || field_label == 'subsidiary_id' 
                            || field_label == 'strategy_id' 
                            || field_label == 'book_id' 
                            || field_label == 'volume_min'  
                            || field_label == 'volume_max'
                        ) {
                            continue;
                        }

                        field_value = filter_data[a];

                        if (attached_obj.getItemType(a) == 'calendar') {
                            field_value = attached_obj.getItemValue(a, true);
                        }
                        else if (field_label  == 'subbook_id') {
                            field_label = 'sub_book_ids';
                            
                        }
                       
                        

                        filter_xml += " " + field_label + "=\"" + field_value + "\"";                
                    }


                    

                    filter_xml += ' filter_mode="a" buy_sell_id="b" source_deal_header_id_from="" source_deal_header_id_to="" deal_id="" view_deleted="n" show_unmapped_deals="n" deal_locked="" book_ids="" view_voided="n" source_system_book_id1="" source_system_book_id2="" source_system_book_id3="" source_system_book_id4="" view_detail="y" ';
                    
                    if(trim(book_structure_xml_buy) == 'sub_book_ids=""' || book_structure_xml_buy == ''){
                        filter_xml += ' '+book_structure_xml;
                    }
                    else{
                       filter_xml += ' '+book_structure_xml_buy; 
                    }    

                    filter_xml += "></FormXML></Root>";
                    
                
                    if(call_from == 'm') {
                       data = {
                            "action": "spa_auto_buy_sell_match", 
                            "flag": "g",  
                            "xmlValue": filter_xml,
                            "technology": technology,
                            "jurisdiction": jurisdiction,
                            "not_technology": not_technology,
                            "not_jurisdiction": not_jurisdiction,
                            "deal_detail_status": deal_detail_status,
                            "tier_type": tier_type,
                            "source_deal_header_id": sdh_id,
                            "sell_deal_detail_id": sdd_id,
                            "nottier_type": nottier_type,
                            "vintage_year": vintage_year,
                            "region_id": region_id,
                            "not_region_id": not_region_id,
                            "delivery_date_from": delivery_date_from,
                            "delivery_date_to": delivery_date_to,
                            "description": description,
                            "volume_match": volume_match,
                            "include_expired_deals": include_expired_deals,
                            "show_all_deals": show_all_deals,
                            "product_classification": product_classification,
                            "effective_date": effective_date
                        };
                        adiha_post_data("return_json", data, '', '', 'buy_sell_link_ui_insert.match_all_callback');
                    } else {
                        technology = (technology != 'NULL') ? "'" + technology + "'" : 'NULL';
                        not_technology = (not_technology != 'NULL') ? "'" + not_technology + "'" : 'NULL';
                        jurisdiction  = (jurisdiction  != 'NULL') ? "'" + jurisdiction  + "'" : 'NULL';
                        not_jurisdiction  = (not_jurisdiction  != 'NULL') ? "'" + not_jurisdiction  + "'" : 'NULL';            
                        region_id = (region_id != 'NULL') ? "'" + region_id + "'" : 'NULL';
                        not_region_id = (not_region_id != 'NULL') ? "'" + not_region_id + "'" : 'NULL';
                        deal_detail_status = (deal_detail_status != 'NULL') ? "'" + deal_detail_status + "'" : 'NULL';            
                        tier_type = (tier_type != 'NULL') ? "'" + tier_type + "'" : 'NULL';
                        nottier_type = (nottier_type != 'NULL') ? "'" + nottier_type + "'" : 'NULL';
                        vintage_year = (vintage_year != 'NULL') ? "'" + vintage_year + "'" : 'NULL';            
                        
                        // Newly added
                        delivery_date_from = (delivery_date_from != 'NULL') ? "'" + delivery_date_from + "'" : 'NULL';
                        delivery_date_to = (delivery_date_to != 'NULL') ? "'" + delivery_date_to + "'" : 'NULL';
                        description = (description != 'NULL') ? "'" + description + "'" : 'NULL';
                        volume_match = (volume_match != 'NULL') ? "'" + volume_match + "'" : 'NULL';
                        product_classification = (product_classification != 'NULL') ? "'" + product_classification + "'" : 'NULL';
                        include_expired_deals = (include_expired_deals != 'NULL') ? '' + include_expired_deals + '' : 'n';
                        show_all_deals = (show_all_deals != 'NULL') ? '' + show_all_deals + '' : 'n';
                        effective_date = (effective_date != 'NULL') ? "'" + effective_date + "'" : 'NULL';
                        

                        var sql_stmt = "EXEC spa_buy_sell_match @flag = 'g', @xmlValue = ' " + filter_xml + "', @technology=" + technology + 
                        ", @jurisdiction =" + jurisdiction  + ", @not_technology=" + not_technology + 
                        ", @not_jurisdiction =" + not_jurisdiction  +", @deal_detail_status=" + deal_detail_status +
                        ", @tier_type=" + tier_type + ", @source_deal_header_id=" + sdh_id + ", @sell_deal_detail_id =" + sdd_id +", @nottier_type=" + nottier_type + 
                        ", @vintage_year=" + vintage_year + ", @region_id=" + region_id + ", @not_region_id=" + not_region_id + 
                        ", @delivery_date_from=" + delivery_date_from + ", @delivery_date_to=" + delivery_date_to + 
                        ", @description = " + description + ", @volume_match = " + volume_match + 
                        ", @include_expired_deals = '" + include_expired_deals + "', @show_all_deals = '" + show_all_deals + 
                        "', @product_classification = " + product_classification + ", @effective_date = " + effective_date + "";

                        var sql_param = {
                        "sql": sql_stmt,
                        "grid_type": "tg",
                        "grouping_column": "source_deal_header_id",
                        "grouping_type": 3
                        };
                        // console.log(sql_stmt);
                        sql_param = $.param(sql_param);
                        var sql_url = js_data_collector_url + "&" + sql_param;
                        
                        attached_grid.clearAndLoad(sql_url, function() {
                            buy_sell_link_ui_insert.layout_link_ui_insert_inner3.cells('a').progressOff();
                        });
                    }
                    
                }  
            }

             /*Block to select all child if parent is selected for buy deal grid*/
            buy_sell_link_ui_insert.buy_grid_row_select = function(rId, cId) {
                var right_grid_select_ids = buy_sell_link_ui_insert.right_grid.getSelectedRowId();

                if (right_grid_select_ids != null) {
                    var right_grid_select_id_arr = right_grid_select_ids.split(',')
                    
                    for (var i = 0; i < right_grid_select_id_arr.length; i++) {
                        var right_grid_select_id = right_grid_select_id_arr[i];
                        
                        if (buy_sell_link_ui_insert.right_grid.hasChildren(right_grid_select_id)) {
                            var childs = buy_sell_link_ui_insert.right_grid.getAllSubItems(right_grid_select_id)
                            buy_sell_link_ui_insert.right_grid.openItem(right_grid_select_id);
                            childs_arr = childs.split(',');
                            
                            for (var a = 0; a < childs_arr.length; a++) {
                                buy_sell_link_ui_insert.right_grid.selectRowById(childs_arr[a], true);
                            }
                        }
                    }
                }      
            }

            buy_sell_link_ui_insert.grid_row_select_post = function() {
                var left_grid_select_ids = buy_sell_link_ui_insert.left_grid.getSelectedRowId();
                var right_grid_select_ids = buy_sell_link_ui_insert.right_grid.getSelectedRowId();
                var select_state = false;

                for (var i = 1; i < 3; i++) {
                    var nrQ_val, srQ_val, nrS_val;
                    var attached_grid = (i == 1) ? buy_sell_link_ui_insert.left_grid : buy_sell_link_ui_insert.right_grid;
                    var select_ids = (i == 1) ? buy_sell_link_ui_insert.left_grid.getSelectedRowId() : buy_sell_link_ui_insert.right_grid.getSelectedRowId();

                    if (left_grid_select_ids == null && right_grid_select_ids == null) {
                        nrQ_val = sumColumn(attached_grid,attached_grid.getColIndexById("actual_volume"));
                        srQ_val = sumColumn(attached_grid,attached_grid.getColIndexById("matched"));
                        nrS_val = sumColumn(attached_grid,attached_grid.getColIndexById("remaining"));
                        select_state = false;
                    } else {
                        if (right_grid_select_ids == null && i == 2) {
                            nrQ_val = sumColumn(buy_sell_link_ui_insert.right_grid, buy_sell_link_ui_insert.right_grid.getColIndexById("actual_volume"));
                            srQ_val = sumColumn(buy_sell_link_ui_insert.right_grid, buy_sell_link_ui_insert.right_grid.getColIndexById("matched"));
                            nrS_val = sumColumn(buy_sell_link_ui_insert.right_grid, buy_sell_link_ui_insert.right_grid.getColIndexById("remaining"));
                        } else {
                            nrQ_val = sumColumnRowSelect(attached_grid,attached_grid.getColIndexById("actual_volume"),select_ids);
                            srQ_val = sumColumnRowSelect(attached_grid,attached_grid.getColIndexById("matched"),select_ids);
                            nrS_val = sumColumnRowSelect(attached_grid,attached_grid.getColIndexById("remaining"),select_ids);
                        }
                        select_state = true;
                    }

                    if (document.getElementById("av_q"+i) != null) {
                        document.getElementById("av_q"+i).innerHTML = numberWithCommas(nrQ_val);
                    }
                    
                    if (document.getElementById("mt_q"+i) != null) {
                        document.getElementById("mt_q"+i).innerHTML = numberWithCommas(srQ_val);
                    }
                    
                    if (document.getElementById("rm_q"+i) != null) {
                        document.getElementById("rm_q"+i).innerHTML = numberWithCommas(nrS_val);
                    }
                }

                buy_sell_link_ui_insert.show_net_position(select_state, left_grid_select_ids, right_grid_select_ids);
            }

            buy_sell_link_ui_insert.load_grid_footer2 = function(attached_grid, i) {
                attached_grid.filterByAll();
                var nrQ_val = sumColumn(attached_grid, attached_grid.getColIndexById("actual_volume"));
                var srQ_val = sumColumn(attached_grid, attached_grid.getColIndexById("matched"));
                var nrS_val = sumColumn(attached_grid, attached_grid.getColIndexById("remaining"));

                if ($('#mt_q'+i).length == 0) {
                    attached_grid.attachFooter("<div id='footer_div"+i+"' style='padding-left:" + attached_grid.objBox.scrollLeft + "px' ><div style='float:left;padding-right:20px;'>Best Available Volume : <span id='av_q"+i+"'>0</span></div><div style='float:left;padding-right:20px;'>Matched : <span id='mt_q"+i+"'>0</span></div><div style='float:left;padding-right:20px;'>Remaining : <span id='rm_q"+i+"'>0</span></div><div style='clear:both;font-weight:bold;' id='net_pos_"+ i + "' ></div></div>,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan,#cspan",["height:40px;text-align:left;"]);
                }

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
                
                // buy_sell_link_ui_insert.layout_link_ui_insert_inner1.cells('b').setWidth(buy_sell_link_ui_insert.layout_link_ui_insert_inner1.cells('b').getWidth() + 0.1);
                
                //if (i == 1) {
                    buy_sell_link_ui_insert.layout_link_ui_insert.cells('b').progressOff();
                    buy_sell_link_ui_insert.layout_link_ui_insert.cells("b").collapse();
                // } else {
                //     buy_sell_link_ui_insert.layout_link_ui_insert_inner2.cells('b').progressOff();
                //     buy_sell_link_ui_insert.layout_link_ui_insert_inner2.cells("b").collapse();            
                // }

                parent.enable_disable_deal_match_menu('refresh', true);
                parent.enable_disable_deal_match_menu('match', true);
                parent.enable_disable_deal_match_menu('auto', true);
                buy_sell_link_ui_insert.show_net_position();
            }

            buy_sell_link_ui_insert.show_net_position = function(select_state, left_grid_select_id, right_grid_select_id) {
                var nrS_val_left, nrS_val_right;
                
                if (select_state == true) {
                    if (left_grid_select_id == null && typeof $('#rm_q1').html() !== 'undefined') {
                        nrS_val_left = parseFloat($('#rm_q1').html().replace(/,/g, ''));
                    } else {
                        nrS_val_left = sumColumnRowSelect(buy_sell_link_ui_insert.left_grid,buy_sell_link_ui_insert.left_grid.getColIndexById("remaining"),left_grid_select_id);
                    }

                    if (right_grid_select_id == null && typeof $('#rm_q2').html() !== 'undefined') {
                        nrS_val_right = parseFloat($('#rm_q2').html().replace(/,/g, ''));
                    } else {           
                        nrS_val_right = sumColumnRowSelect(buy_sell_link_ui_insert.right_grid,buy_sell_link_ui_insert.right_grid.getColIndexById("remaining"),right_grid_select_id);
                    }  
                } else {
                    if (buy_sell_link_ui_insert.left_grid.getSelectedRowId() == null) {
                        nrS_val_left = sumColumn(buy_sell_link_ui_insert.left_grid,buy_sell_link_ui_insert.left_grid.getColIndexById("remaining"));
                    } else {
                        nrS_val_left = parseFloat($('#rm_q1').html().replace(/,/g, ''));
                    }

                    if (buy_sell_link_ui_insert.right_grid.getSelectedRowId() == null) {
                        nrS_val_right = sumColumn(buy_sell_link_ui_insert.right_grid,buy_sell_link_ui_insert.right_grid.getColIndexById("remaining"));
                    } else {
                        nrS_val_right = parseFloat($('#rm_q2').html().replace(/,/g, ''));
                    }
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

            buy_sell_link_ui_insert.open_update_book = function() {
                var left_dealid_col_index = buy_sell_link_ui_insert.left_grid.getColIndexById("source_deal_header_id");
                var right_dealid_col_index = buy_sell_link_ui_insert.right_grid.getColIndexById("source_deal_header_id");
                var left_grid_select_deals = buy_sell_link_ui_insert.left_grid.getColumnValues(left_dealid_col_index) || '0';
                var right_grid_select_deals = buy_sell_link_ui_insert.right_grid.getColumnValues(right_dealid_col_index) || '0';

                //validate matched_volume to be 0 to update
                var left_matched_col_index = buy_sell_link_ui_insert.left_grid.getColIndexById("matched");
                var right_matched_col_index = buy_sell_link_ui_insert.right_grid.getColIndexById("matched");
                var left_grid_matched = buy_sell_link_ui_insert.left_grid.getColumnValues(left_matched_col_index) || '0';
                var right_grid_matched = buy_sell_link_ui_insert.right_grid.getColumnValues(right_matched_col_index) || '0';

                
                var grid_matched = left_grid_matched + ',' + right_grid_matched;
                var grid_matched_arr = grid_matched.split(',');

                for (var i = 0; i < grid_matched_arr.length; i++) {
                    
                    if (parseInt(grid_matched_arr[i]) != 0) {
                        
                        return {
                            title: 'Alert', 
                            type: 'alert-error', 
                            text: 'Matched Deal(s) is selected. Please checked.'
                        };
                    }
                }        

                var deal_ids = left_grid_select_deals + ',' + right_grid_select_deals;

                if (deal_ids == '0,0') {
                    
                    return {
                        title: 'Alert', 
                        type: 'alert-error', 
                        text: 'No Deal(s) selected.'
                    };
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

                update_book.attachURL(js_php_path+'book.browser.php', false, {
                    enable_subbook: 1,win_name: 'update_book_win'
                });

                update_book.attachEvent('onClose', function(w) {
                    var ifr = w.getFrame();
                    var ifrWindow = ifr.contentWindow;
                    var ifrDocument = ifrWindow.document;
                    var return_string = $('textarea[name="return_string"]', ifrDocument).val();
                    
                    if (return_string != '') {
                        var return_array = JSON.parse(return_string);
                        var new_subbook = return_array[3];
                        
                        data = {
                            "action": "spa_source_deal_header", 
                            "flag": "y", 
                            "deal_ids": deal_ids, 
                            "sub_book": new_subbook
                        };
                        
                        adiha_post_data("return_array", data, '', '', 'buy_sell_link_ui_insert.delete_deals_callback');
                    }

                    return true;
                });
            }

            /**
             * Deal delete callback
             * @param  {Array}  return_value
             */
            buy_sell_link_ui_insert.delete_deals_callback = function(return_value) {
                
                if (return_value[0][0] == 'Success') {
                    
                    dhtmlx.message({
                        text: return_value[0][4],
                        expire: 1000
                    });

                    parent.buy_sell_link_ui_template.refresh_match_grids();
                } else {
                    dhtmlx.alert({
                        title: "Alert",
                        type: "alert-error",
                        text: return_value[0][4],
                    });

                    return;
                }
            }



            buy_sell_link_ui_insert.match_all_callback = function(result) {
                result = JSON.parse(result);
                buy_sell_link_ui_insert.layout_link_ui_insert_inner3.cells('a').progressOff();
                if (result[0].errorcode == 'Success' ) { 
                     success_call(result[0].message);
					 buy_sell_link_ui_insert.right_grid_menu.setItemDisabled('match_all');
                     buy_sell_link_ui_insert.right_grid_menu.setItemDisabled('refresh_buy_deal');
                     parent.parent.buy_sell_link_ui.refresh_link_grid_clicked();
                     parent.buy_sell_link_ui_template.refresh_match_grids();
                  } else {
                    success_call(result[0].message, 'error');
                  }
            }
            function sumColumn(myGrid, ind){
                var out = 0;
                var buy_sell = '';
                
                for (var i = 0; i < myGrid.getRowsNum(); i++) {
                        buy_sell = myGrid.cells2(i,4).getValue();
                        
                        if (buy_sell == 'Buy') {
                            out += parseFloat(myGrid.cells2(i,ind).getValue());
                        } else {
                            out -= parseFloat(myGrid.cells2(i,ind).getValue());
                        }
                }

                return Math.abs(out);
            }

            function sumColumnRowSelect(myGrid, ind, arr_string){
                if (arr_string == null)
                    return 0;

                var arr = arr_string.split(',');
                var out = 0;
                var buy_sell = '';
                
                arr.forEach(function(row_id) {

                    if (myGrid.hasChildren(row_id)) {
                        out += 0;
                    } else {
                        buy_sell = myGrid.cells(row_id, 4).getValue();
                        
                        if (buy_sell == 'Buy') {
                            out += parseFloat(myGrid.cells(row_id, ind).getValue())
                        } else {
                            out -= parseFloat(myGrid.cells(row_id, ind).getValue())
                        }
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
                        
                        if (buy_sell == 'Buy') {
                            out += parseFloat(myGrid.cells(row_id,ind).getValue())
                        } else {
                            out -= parseFloat(myGrid.cells(row_id,ind).getValue())
                        }
                    }
                });

                return Math.abs(out / arr.length);
            }

            function numberWithCommas(x) {
                x = Math.round(Math.abs(x) * 100) / 100;
                x = x.toFixed(2);
                return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
            }
        
      </script> 
    </body>

</html>