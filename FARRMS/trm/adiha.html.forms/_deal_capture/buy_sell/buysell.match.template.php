<!DOCTYPE html>
<html>

    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
        <?php require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>

        <style>
            html, body {
                background-color: #ebebeb;
                height: 100%;
                margin: 0px;
                overflow: hidden;
                padding: 0px;
                width: 100%;
            }
        </style>

    </head>
    
    <body>
        <?php
            $php_script_loc = $app_php_script_loc;
            $app_user_loc = $app_user_name;
            $link_id = get_sanitized_value($_GET['link_id'] ?? '0');
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

            $filter_application_function_id = 20007900;

            $enable = 'true';

            $form_namespace = 'buy_sell_link_ui_template';
            
            $json = '[{
                id:             "a",
                text:           "Links",
                header:         true,
                offsetTop:      0
            }]';

            $report_template_layout_obj = new AdihaLayout();
            echo $report_template_layout_obj->init_layout('template_layout', '', '1C', $json, $form_namespace);
            echo $report_template_layout_obj->attach_tab_cell('link_ui_tabbar', 'a', '');
             
            echo $report_template_layout_obj->close_layout(); 

        ?>  

        <script>
            var has_rights_deal_match_iu = Boolean(<?php echo $has_rights_deal_match_iu; ?>);
            var has_rights_deal_match_delete = Boolean(<?php echo $has_rights_deal_match_delete; ?>);
            var link_id = <?php echo $link_id; ?>;

            buy_sell_link_ui_template = {};
            inner_menu_obj = {};
            header_menu_obj = {};

            undock_state = 0;
            progress_on = 0;
            var volume_window;
            var session_id = '<?php echo $session_id; ?>';

            $(function() {
                // load Deal Match Tab
                if (link_id != 0) {
                    buy_sell_link_ui_template.load_link_detail(-1);
                    buy_sell_link_ui_template.load_link_detail(link_id);    
                } else {
                    buy_sell_link_ui_template.load_link_detail(-1);
                }
                
            })
            
            /**
             * Load function when the grid is double clicked
             * @param  {int}    link_id
             *                  -1    : Deal Match Tab
             *                  -2    : New Tab 
             *                  else  : Link Tab (update)
             * @param  {String} link_name
             * @param  {String} data
             * @param  {String} product_class
             */
            buy_sell_link_ui_template.load_link_detail = function(link_id, link_name, data, product_class) {
                var params = '';
                inner_active_tab = '';
                
                if (link_id == -1) {
                    full_id = -1;
                    full_id = full_id.toString();
                    tab_text = "Match Environmental Product"; 
                } else if (link_id == -2) {
                    full_id = (new Date()).valueOf();
                    full_id = full_id.toString();
                    tab_text = "New"; 
                    link_id  = full_id;
                } else {
                    full_id = 'tab_' + link_id;
                    tab_text = 'Match Environmental Product : ' + link_id;   
                }
                
                link_name = tab_text
                product_class = product_class
                
                params = {
                    active_object_id: full_id, 
                    link_name: link_name,
                    data: data,
                    product_class: product_class
                };  
                
                
                var all_tab_id = buy_sell_link_ui_template.link_ui_tabbar.getAllTabs();
                
                if (jQuery.inArray(full_id, all_tab_id ) != -1) {
                    buy_sell_link_ui_template.link_ui_tabbar.tabs(full_id).setActive();
                    return;
                }
                
                buy_sell_link_ui_template.link_ui_tabbar.addTab(full_id, link_name, null, null, true, (link_id == -1) ? false : true);
                var win = buy_sell_link_ui_template.link_ui_tabbar.cells(full_id);
                win.progressOn();
                
                var link_ui_tab_id = link_id;
                
                
                buy_sell_link_ui_template["inner_tab_layout_" + link_ui_tab_id] = win.attachLayout({
                    pattern:"1C",
                    cells: [{
                        id: "a", 
                        text: "Filter",
                        header:false,
                        height:100,
                        collapse:false
                    }]
                });
               
                                
            
                var inner_layout_obj = buy_sell_link_ui_template["inner_tab_layout_" + link_ui_tab_id];
               
                inner_menu_obj[link_ui_tab_id] = inner_layout_obj.cells('a').attachToolbar();
                

                inner_menu_obj[link_ui_tab_id].setIconsPath(js_image_path + "dhxtoolbar_web/");
                 


                if (link_id == -1) {
                    
                    inner_menu_obj[link_ui_tab_id].loadStruct([
                        {id: "refresh", type: "button", img: "refresh.gif", imgdis: "refresh_dis.gif", text: "Refresh", title: "Refresh"},
                        {id: "match", type: "button", img: "match.gif", imgdis: "match_dis.gif", text: "Match", title: "Match"},
                        {id: "auto", type: "button", img:"switch_on.png", imgdis: "switch_on.png", text: "Auto",title: "Auto"}
                    ]);
                } else {
                    inner_menu_obj[link_ui_tab_id].loadStruct([
                        {id:"save", type: "button", img: "save.gif", imgdis: "save_dis.gif", text:"Save", title: "Save", enabled: has_rights_deal_match_iu}
                    ]);
                }

                inner_menu_obj[link_ui_tab_id].attachEvent('onClick', buy_sell_link_ui_template.onclick_menu);

                inner_layout_obj.attachEvent("onContentLoaded", function(name) {
                    win.progressOff();
                });

                var template_name = (link_id == -1) ? 'buysell.match.insert.php' : 'buysell.match.iu.php';        
                var php_path = '<?php echo $app_adiha_loc; ?>';
                var url = php_path + 'adiha.html.forms/_deal_capture/buy_sell/' + template_name;
                
                inner_layout_obj.cells('a').attachURL(url, null, params);
            }

            buy_sell_link_ui_template.onclick_menu = function(id) {
                switch (id) {
                    case 'refresh':
                        parent.show_hide_left_panel(true);
                        buy_sell_link_ui_template.refresh_match_grids();
                        break;
                    case 'match':
                        parent.show_hide_left_panel(true);
                        var active_tab = get_active_tab_id();
                        var btn_text = inner_menu_obj[active_tab].getItemText('auto');
                        var source_deal_header_id;
                        var source_deal_detail_id;
                        var frame_obj = buy_sell_link_ui_template["inner_tab_layout_" + active_tab].cells("a").getFrame();

                              // get selected row id and split if multiple
                        var selected_row_id = frame_obj.contentWindow.buy_sell_link_ui_insert.right_grid.getSelectedRowId();
                        var left_grid_select_id = frame_obj.contentWindow.buy_sell_link_ui_insert.left_grid.getSelectedRowId();
                        var right_grid_select_id = frame_obj.contentWindow.buy_sell_link_ui_insert.right_grid.getSelectedRowId();

                        if (left_grid_select_id == null || right_grid_select_id == null) {
                            show_messagebox('Deals are not selected. Please select the deal(s).');
                            return false;
                        }


                        var effective_date = frame_obj.contentWindow.buy_sell_link_ui_insert.filter_Dealset1.getItemValue('effective_date', true);
                        effective_date = Date.parse(effective_date);
                        
                  
                        var has_child = frame_obj.contentWindow.buy_sell_link_ui_insert.left_grid.hasChildren(left_grid_select_id);
                        var is_parent = frame_obj.contentWindow.buy_sell_link_ui_insert.left_grid.getLevel(left_grid_select_id);


                        if(has_child > 0 && is_parent == 0) {
                            show_messagebox("Please select the detail of multiple term deal on Sell Deal grid.");
                            return;
                        }
                        // alert(has_child)
                        if(has_child == 0 && is_parent == 0) {
                            source_deal_header_id = frame_obj.contentWindow.buy_sell_link_ui_insert.left_grid.cells(left_grid_select_id, frame_obj.contentWindow.buy_sell_link_ui_insert.left_grid.getColIndexById("source_deal_header_id")).getValue();

                         } else {
                            var parent_sel_row_id = frame_obj.contentWindow.buy_sell_link_ui_insert.left_grid.getParentId(left_grid_select_id);
                            source_deal_header_id = frame_obj.contentWindow.buy_sell_link_ui_insert.left_grid.cells(parent_sel_row_id, frame_obj.contentWindow.buy_sell_link_ui_insert.left_grid.getColIndexById("source_deal_header_id")).getValue();
                         }
                       
                        source_deal_detail_id = frame_obj.contentWindow.buy_sell_link_ui_insert.left_grid.cells(left_grid_select_id, frame_obj.contentWindow.buy_sell_link_ui_insert.left_grid.getColIndexById("source_deal_detail_id")).getValue();

                        var array_val_exp_date = [];
                        var array_val_dtl_stat = [];
                        var array_val_deal_ids = [];
                        var array_source_deal_detail_id_from = [];
                        selected_row_id = selected_row_id.split(',');
                        
                        var product_class = frame_obj.contentWindow.buy_sell_link_ui_insert.left_grid.cells(frame_obj.contentWindow.buy_sell_link_ui_insert.left_grid.getSelectedRowId(),frame_obj.contentWindow.buy_sell_link_ui_insert.left_grid.getColIndexById('product_class')).getValue();
                        
                        var deal_ids_index = frame_obj.contentWindow.buy_sell_link_ui_insert.right_grid.getColIndexById("source_deal_header_id");
                        var deal_detail_ids_index = frame_obj.contentWindow.buy_sell_link_ui_insert.right_grid.getColIndexById("source_deal_detail_id");

                        $.each(selected_row_id, function(a, c) {
                            
                            var b = frame_obj.contentWindow.buy_sell_link_ui_insert.right_grid.getRowIndex(c);

                            var deal_ids = frame_obj.contentWindow.buy_sell_link_ui_insert.right_grid.cells2(b, deal_ids_index).getValue();

                            var deal_detail_id_from = frame_obj.contentWindow.buy_sell_link_ui_insert.right_grid.cells2(b, deal_detail_ids_index).getValue();
                            
                            if (deal_ids == '') {
                                var has_parent = frame_obj.contentWindow.buy_sell_link_ui_insert.right_grid.getParentId(c);
                                deal_ids = has_parent;
                            }

                            var expiration_date_index = frame_obj.contentWindow.buy_sell_link_ui_insert.right_grid.getColIndexById("expiration_date");
                            var detail_status_index = frame_obj.contentWindow.buy_sell_link_ui_insert.right_grid.getColIndexById("detail_status");

                            var expiration_date = frame_obj.contentWindow.buy_sell_link_ui_insert.right_grid.cells2(b, expiration_date_index).getValue();

                            if (expiration_date != '') {
                                var id_date_obj = {deal_id: deal_ids, date: expiration_date};
                            }                        

                            var detail_status = frame_obj.contentWindow.buy_sell_link_ui_insert.right_grid.cells2(b, detail_status_index).getValue();
                            array_val_dtl_stat.push(detail_status);

                            if(array_val_deal_ids.indexOf(deal_ids) < 0) {
                                array_val_deal_ids.push(deal_ids);
                            }
                            array_val_exp_date.push(id_date_obj);
                            if(deal_detail_id_from != '') {
                               array_source_deal_detail_id_from.push(deal_detail_id_from); 
                            }
                            
                        });


                        // sort with date in ascending order
                        array_val_exp_date.sort(function(a, b) {
                            return Date.parse(a.date) - Date.parse(b.date);
                        });

                        var product_class_index = frame_obj.contentWindow.buy_sell_link_ui_insert.left_grid.getColIndexById("product_class");
                        var product_class_val = frame_obj.contentWindow.buy_sell_link_ui_insert.left_grid.cells(left_grid_select_id, product_class_index).getValue();

                        var exp_index = array_val_dtl_stat.indexOf('Expired');
                        var filtered_expired_deals = [];
                        
                        array_val_dtl_stat.forEach(function(value, index) {
                            
                            if (value.indexOf('Expired') > -1) {
                               filtered_expired_deals.push(array_val_deal_ids[index]);
                            }
                        }); 

                        if (exp_index >= 0) {
                            var filtered_expired_deal_ids = filtered_expired_deals.filter(function(value, index) {
                                return filtered_expired_deals.indexOf(value) === index;
                            });

                            var msg = 'Detail status of <b>' + filtered_expired_deal_ids.join(',') + '</b> is expired. Are you sure you want to create a Match Deal?'                                
                            
                            dhtmlx.message({
                                type: "confirm",
                                title: "Confirmation",
                                ok: "Confirm",
                                text: msg,
                                callback: function(result) {
                                    
                                    if (result) {
                                        
                                        if ((btn_text == 'Manual' && array_val_exp_date[0] != undefined) 
                                            || (btn_text == 'Auto' && product_class_val == '107400' && array_val_exp_date[0] != undefined)
                                        ) {
                                            var exp_deal_ids = buy_sell_link_ui_template.get_expired_selected_deal_ids(array_val_exp_date, effective_date);
                                            
                                            if (exp_deal_ids.length > 0 && product_class_val == '107400') {
                                                var msg = '<b>' + exp_deal_ids.join(',') + '</b> is expired. Are you sure you want to create a Match Deal?';

                                                dhtmlx.message({
                                                    type: "confirm",
                                                    title: "Confirmation",
                                                    ok: "Confirm",
                                                    text: msg,
                                                    callback: function(result) {
                                                        
                                                        if (result) {
                                                            
                                                            if (btn_text == 'Manual') {
                                                                buy_sell_link_ui_template.run_deal_match_manual_mode(source_deal_header_id, array_val_deal_ids, source_deal_detail_id, array_source_deal_detail_id_from);
                                                            } else {
                                                                buy_sell_link_ui_template.match_deal_grids();
                                                            }
                                                        }
                                                    }
                                                });

                                            } else {
                                                if (btn_text == 'Manual') {
                                                   buy_sell_link_ui_template.run_deal_match_manual_mode(source_deal_header_id, array_val_deal_ids, source_deal_detail_id, array_source_deal_detail_id_from);
                                                } else {
                                                    buy_sell_link_ui_template.match_deal_grids();
                                                }
                                            }
                                        } 

                                        /* 
                                         * For product_class_val other than 107400 i.e Compliance Target,
                                         * we do not need exp_deal_ids validation.
                                         * So this else block is added.
                                        */
                                        else {
                                            
                                            if (btn_text == 'Manual') {
                                               buy_sell_link_ui_template.run_deal_match_manual_mode(source_deal_header_id, array_val_deal_ids, source_deal_detail_id, array_source_deal_detail_id_from);
                                            } else {
                                                buy_sell_link_ui_template.match_deal_grids();
                                            }
                                        }
                                    } else {
                                        return false;
                                    }
                                }
                            });

                        } else if ((btn_text == 'Manual' && array_val_exp_date[0] != undefined) 
                            || (btn_text == 'Auto' && product_class_val == '107400' && array_val_exp_date[0] != undefined)
                        ) {
                            var exp_deal_ids = buy_sell_link_ui_template.get_expired_selected_deal_ids(array_val_exp_date, effective_date);
                            
                            if (exp_deal_ids.length > 0 && product_class_val == '107400') {
                                
                                var msg = '<b>' + exp_deal_ids.join(',') 
                                    + '</b> is expired. Are you sure you want to create a Match Deal?';
                                
                                dhtmlx.message({
                                    type: "confirm",
                                    title: "Confirmation",
                                    ok: "Confirm",
                                    text: msg,
                                    callback: function(result) {
                                        
                                        if (result) {
                                            
                                            if (btn_text == 'Manual') {
                                                buy_sell_link_ui_template.template_layout.progressOn();
                                               
                                                var manual_case_data = {
                                                    "action": "spa_buy_sell_match",
                                                    "flag": "g",
                                                    "source_deal_header_id": source_deal_header_id,
                                                    "source_deal_header_id_from": array_val_deal_ids.toString(),
                                                    "sell_deal_detail_id": source_deal_detail_id,
                                                    "source_deal_detail_id_from": array_source_deal_detail_id_from.toString()
                                                };

                                                adiha_post_data('return_json', manual_case_data, '', '', function(return_json) {
                                                    return_json = JSON.parse(return_json);
                                                    if (return_json.length > 0) {
                                                        buy_sell_link_ui_template.template_layout.progressOff();
                                                        buy_sell_link_ui_template.match_deal_grids('', return_json[0].process_id);
                                                    } else {
                                                        buy_sell_link_ui_template.template_layout.progressOff();
                                                        show_messagebox('Product details of deals do not match. Please check the deals.');
                                                        return;
                                                    }
                                                });
                                            } else {
                                                buy_sell_link_ui_template.match_deal_grids();
                                            }
                                        } else {
                                            return false;
                                        }
                                    }
                                });
                            } else {
                                if (btn_text == 'Manual') {
                                    buy_sell_link_ui_template.template_layout.progressOn();
                                    
                                    var manual_case_data = {
                                        "action": "spa_buy_sell_match",
                                        "flag": "g",
                                        "source_deal_header_id": source_deal_header_id,
                                        "source_deal_header_id_from": array_val_deal_ids.toString(),
                                        "sell_deal_detail_id": source_deal_detail_id,
                                        "source_deal_detail_id_from": array_source_deal_detail_id_from.toString()

                                    };

                                    adiha_post_data('return_json', manual_case_data, '', '', function(return_json) {
                                        return_json = JSON.parse(return_json);
                                        if (return_json.length > 0) {
                                            buy_sell_link_ui_template.template_layout.progressOff();
                                            buy_sell_link_ui_template.match_deal_grids('', return_json[0].process_id);
                                        } else {
                                            show_messagebox('Product details of deals do not match. Please check the deals.');
                                            buy_sell_link_ui_template.template_layout.progressOff();
                                            return;
                                        }
                                    });
                                } else {
                                    buy_sell_link_ui_template.match_deal_grids();
                                }
                            }
                        } else {
                            if (btn_text == 'Manual') {
                                buy_sell_link_ui_template.template_layout.progressOn();
                                
                                var manual_case_data = {
                                    "action": "spa_buy_sell_match",
                                    "flag": "g",
                                    "source_deal_header_id": source_deal_header_id,
                                    "source_deal_header_id_from": array_val_deal_ids.toString(),
                                    "sell_deal_detail_id": source_deal_detail_id,
                                    "source_deal_detail_id_from": array_source_deal_detail_id_from.toString()
                                };

                                adiha_post_data('return_json', manual_case_data, '', '', function(return_json) {
                                    return_json = JSON.parse(return_json);
                                    if (return_json.length > 0) {
                                        buy_sell_link_ui_template.template_layout.progressOff();
                                        buy_sell_link_ui_template.match_deal_grids('', return_json[0].process_id);
                                    } else {
                                        show_messagebox('Product details of deals do not match. Please check the deals.');
                                        buy_sell_link_ui_template.template_layout.progressOff();
                                        return;
                                    }
                                });
                            } else {
                                buy_sell_link_ui_template.match_deal_grids();
                            }                        
                        }

                        break;
                    case 'auto':
                        parent.show_hide_left_panel(true);
                        var active_tab = get_active_tab_id();
                        var btn_text = inner_menu_obj[active_tab].getItemText(id);

                        var frame_obj = buy_sell_link_ui_template["inner_tab_layout_" + active_tab].cells("a").getFrame();

                        // Added logic to check from date and to date (returns true/false)
                        var from_to_status1 = frame_obj.contentWindow.buy_sell_link_ui_insert.validate_from_and_to_left();
                        frame_obj.contentWindow.buy_sell_link_ui_insert.right_grid_menu.setItemDisabled('match_all');
                        frame_obj.contentWindow.buy_sell_link_ui_insert.right_grid_menu.setItemDisabled('refresh_buy_deal');
                        
                        
                        if (from_to_status1 == true) {
                            var from_to_status2 = frame_obj.contentWindow.buy_sell_link_ui_insert.validate_from_and_to_right();
                        }

                        if (from_to_status1 === true && from_to_status2 === true) {
                            
                            // List of Items to enable/disable
                            var item_list = [ 'vintage_year_2', 'region_id_2', 'not_region_id_2', 'jurisdiction_2', 'not_jurisdiction_2', 'tier_type_2', 'nottier_type_2', 'technology_2', 'not_technology_2' ];

                            if (btn_text === 'Auto') {
                                inner_menu_obj[active_tab].disableItem("auto");
                                inner_menu_obj[active_tab].setItemImage('auto', 'switch_off.png', 'switch_off.png');
                                inner_menu_obj[active_tab].setItemText(id, "Manual");

                                $.each(item_list, function(item_id, item_name) {
                                    //console.log(item_name);
                                    var check_enabled = frame_obj.contentWindow.buy_sell_link_ui_insert.filter_Dealset1.isItemEnabled(item_name);
                                    
                                    if (check_enabled === false) {
                                        frame_obj.contentWindow.buy_sell_link_ui_insert.filter_Dealset1.enableItem(item_name);
                                    }
                                });

                                if (frame_obj.contentWindow.buy_sell_link_ui_insert.filter_Dealset1.isItemChecked('include_expired_deals_2') == false) {
                                    frame_obj.contentWindow.buy_sell_link_ui_insert.filter_Dealset1.checkItem('include_expired_deals_2');
                                }

                                frame_obj.contentWindow.buy_sell_link_ui_insert.match_criteria.disableItem('show_all_deals');
                                frame_obj.contentWindow.buy_sell_link_ui_insert.match_criteria.setItemValue('volume_match', '');
                                frame_obj.contentWindow.buy_sell_link_ui_insert.match_criteria.disableItem('volume_match');
                                frame_obj.contentWindow.buy_sell_link_ui_insert.filter_Dealset1.setRequired('tier_type',true);
                                frame_obj.contentWindow.buy_sell_link_ui_insert.filter_Dealset1.setRequired('jurisdiction',true);
                                frame_obj.contentWindow.buy_sell_link_ui_insert.filter_Dealset1.setUserData("tier_type", "validation_message", "Invalid Selection");
                                frame_obj.contentWindow.buy_sell_link_ui_insert.filter_Dealset1.setUserData("jurisdiction", "validation_message", "Invalid Selection"); 

                                frame_obj.contentWindow.buy_sell_link_ui_insert.filter_Dealset1.setRequired('tier_type_2',true);
                                frame_obj.contentWindow.buy_sell_link_ui_insert.filter_Dealset1.setRequired('jurisdiction_2',true);
                                frame_obj.contentWindow.buy_sell_link_ui_insert.filter_Dealset1.setUserData("tier_type_2", "validation_message", "Invalid Selection");
                                frame_obj.contentWindow.buy_sell_link_ui_insert.filter_Dealset1.setUserData("jurisdiction_2", "validation_message", "Invalid Selection");

                                frame_obj.contentWindow.buy_sell_link_ui_insert.filter_Dealset1.setRequired('term_start_2', true);
                                frame_obj.contentWindow.buy_sell_link_ui_insert.filter_Dealset1.setRequired('term_end_2', true);
                                frame_obj.contentWindow.buy_sell_link_ui_insert.filter_Dealset1.setUserData("term_Start_2", "validation_message", "Invalid Selection");
                                frame_obj.contentWindow.buy_sell_link_ui_insert.filter_Dealset1.setUserData("term_end_2", "validation_message", "Invalid Selection");

                                frame_obj.contentWindow.buy_sell_link_ui_insert.load_match_grids('manual');
                            } else {
                                inner_menu_obj[active_tab].disableItem("auto");
                                inner_menu_obj[active_tab].setItemImage('auto', 'switch_on.png', 'switch_on.png');
                                inner_menu_obj[active_tab].setItemText(id, "Auto");
                                
                                frame_obj.contentWindow.buy_sell_link_ui_insert.match_criteria.setItemValue('volume_match', 'p');

                                $.each(item_list, function(item_id, item_name) {
                                    var check_enabled = frame_obj.contentWindow.buy_sell_link_ui_insert.filter_Dealset1.isItemEnabled(item_name);
                                    
                                    if (check_enabled === true) {
                                        frame_obj.contentWindow.buy_sell_link_ui_insert.filter_Dealset1.disableItem(item_name);
                                    }                      
                                });

                               


                                if (frame_obj.contentWindow.buy_sell_link_ui_insert.filter_Dealset1.isItemChecked('include_expired_deals_2')) {
                                    frame_obj.contentWindow.buy_sell_link_ui_insert.filter_Dealset1.uncheckItem('include_expired_deals_2');
                                }

                                frame_obj.contentWindow.buy_sell_link_ui_insert.match_criteria.enableItem('show_all_deals');
                                frame_obj.contentWindow.buy_sell_link_ui_insert.match_criteria.enableItem('volume_match');
                               

                                frame_obj.contentWindow.buy_sell_link_ui_insert.filter_Dealset1.setRequired('tier_type',false);
                                frame_obj.contentWindow.buy_sell_link_ui_insert.filter_Dealset1.setRequired('jurisdiction',false);
                                // frame_obj.contentWindow.buy_sell_link_ui_insert.match_criteria.setRequired('book_structure',true);
                               
                                frame_obj.contentWindow.buy_sell_link_ui_insert.filter_Dealset1.clearNote("tier_type");
                                frame_obj.contentWindow.buy_sell_link_ui_insert.filter_Dealset1.clearNote("jurisdiction");
                                frame_obj.contentWindow.buy_sell_link_ui_insert.filter_Dealset1.setRequired('tier_type_2',false);
                                frame_obj.contentWindow.buy_sell_link_ui_insert.filter_Dealset1.setRequired('jurisdiction_2',false);
                                // frame_obj.contentWindow.buy_sell_link_ui_insert.match_criteria.setRequired('book_structure',true);
                               
                                frame_obj.contentWindow.buy_sell_link_ui_insert.filter_Dealset1.clearNote("tier_type_2");
                                frame_obj.contentWindow.buy_sell_link_ui_insert.filter_Dealset1.clearNote("jurisdiction_2");

                                
                                // frame_obj.contentWindow.buy_sell_link_ui_insert.match_criteria.setUserData("book_structure", "validation_message", "");

                                frame_obj.contentWindow.buy_sell_link_ui_insert.filter_Dealset1.setRequired('term_start_2',false);
                                frame_obj.contentWindow.buy_sell_link_ui_insert.filter_Dealset1.setRequired('term_end_2',false);
                                frame_obj.contentWindow.buy_sell_link_ui_insert.filter_Dealset1.clearNote("term_start_2");
                                frame_obj.contentWindow.buy_sell_link_ui_insert.filter_Dealset1.clearNote("term_end_2");
                                

                               


                                var form = frame_obj.contentWindow.buy_sell_link_ui_insert.filter_Dealset1;
                                var form_data = form.getFormData();

                                

                                var cleared_data = Object.keys(form_data)
                                    .reduce(function(obj, key) {
                                        obj[key] = form.isItemEnabled(key) ? form_data[key] : '';
                                        return obj;
                                    }, {});

                                form.setFormData(cleared_data);
                                
                                frame_obj.contentWindow.buy_sell_link_ui_insert.load_match_grids('auto');
                            }
                        }

                        break;
                    case 'save':
                        buy_sell_link_ui_template.save_deal_match_ui();
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
             * Refresh left and right grid for Deal Match Tab
             * @param  {String} tab_id
             */
            buy_sell_link_ui_template.refresh_match_grids = function(tab_id) {
                var active_tab_id;
                
                if (tab_id) {
                    active_tab_id = tab_id;
                } else {
                    active_tab_id = get_active_tab_id();    
                }

                var frame_obj = buy_sell_link_ui_template["inner_tab_layout_" + active_tab_id].cells("a").getFrame();
             
                var btn_text = inner_menu_obj[active_tab_id].getItemText('auto');

                var from_to_status1 = frame_obj.contentWindow.buy_sell_link_ui_insert.validate_from_and_to_left();

                frame_obj.contentWindow.buy_sell_link_ui_insert.right_grid_menu.setItemDisabled('match_all');

               
                
                if (from_to_status1 === true) {
                    var from_to_status2 = frame_obj.contentWindow.buy_sell_link_ui_insert.validate_from_and_to_right();
                }

                // if valid then refresh grids
                if (from_to_status1 === true && from_to_status2 === true) {
                    enable_disable_deal_match_menu('refresh',false);
                    enable_disable_deal_match_menu('match',false);
                    enable_disable_deal_match_menu('auto',false);

                    frame_obj.contentWindow.buy_sell_link_ui_insert.load_match_grids(btn_text.toLowerCase());
                }
            }

            /**
             * Match left and right grid for insert mode at Deal Match Tab
             * @param  {String}  tab_id
             * @param  {String}  process_id_manual_case
             */
            buy_sell_link_ui_template.match_deal_grids = function(tab_id, process_id_manual_case) {
                
                if (tab_id) {
                    var active_tab_id = tab_id;
                } else {
                    var active_tab_id = get_active_tab_id();    
                }
                
                var frame_obj = buy_sell_link_ui_template["inner_tab_layout_" + active_tab_id].cells("a").getFrame();
                var return_result = frame_obj.contentWindow.buy_sell_link_ui_insert.get_match_grids(process_id_manual_case);
                var product_class = frame_obj.contentWindow.buy_sell_link_ui_insert.left_grid.cells(frame_obj.contentWindow.buy_sell_link_ui_insert.left_grid.getSelectedRowId(), frame_obj.contentWindow.buy_sell_link_ui_insert.left_grid.getColIndexById('product_class')).getValue();
                
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
                    buy_sell_link_ui_template.load_link_detail(-2,'',return_result, product_class);
                }
            }

            /**
             * Matched left and right grid for insert mode at Deal Match Tab
             */
            buy_sell_link_ui_template.process_deal_grids = function() {
                var active_tab_id = get_active_tab_id(); 
                
                var frame_obj = buy_sell_link_ui_template["inner_tab_layout_" + active_tab_id].cells("a").getFrame();
                var return_result = frame_obj.contentWindow.buy_sell_link_ui_insert.open_update_book();
                
                if (!return_result) {
                    return;
                } else if (return_result.type != 'Success') {
                    dhtmlx.alert({
                        title:return_result.title,
                        type:return_result.type,
                        text: return_result.text,
                    });
                } else {
                    buy_sell_link_ui_template.load_link_detail(-2, '', return_result);   
                }
            }

            /**
             * Save matched deals data
             */
            buy_sell_link_ui_template.save_deal_match_ui = function(){
                var active_tab_id = get_active_tab_id();
                var frame_obj = buy_sell_link_ui_template["inner_tab_layout_" + active_tab_id].cells("a").getFrame();

                var matched_index = frame_obj.contentWindow.buy_sell_deal_match_ui.right_grid_ui.getColIndexById("matched");
                var unique_val =frame_obj.contentWindow.buy_sell_deal_match_ui.right_grid_ui.collectValues(matched_index); 

                if(unique_val.indexOf("0") > -1 || unique_val.indexOf("0.00") > -1) {
                    show_messagebox("Match volume is 0 in <b>Buy Deal</b> grid.");
                    return; 

                }
                buy_sell_link_ui_template.template_layout.progressOn();
                var right_grid_select_id = frame_obj.contentWindow.buy_sell_deal_match_ui.right_grid_ui.getChangedRows();
                
                if (frame_obj.contentWindow.mode == 'u' && right_grid_select_id != '') {

                    var left_grid_select_id_source_deal_header_id = frame_obj.contentWindow.buy_sell_deal_match_ui.left_grid_ui.getRowData(frame_obj.contentWindow.buy_sell_deal_match_ui.left_grid_ui.getStateOfView()[1]).source_deal_header_id;
					var left_grid_select_id_source_deal_detail_id = frame_obj.contentWindow.buy_sell_deal_match_ui.left_grid_ui.getRowData(frame_obj.contentWindow.buy_sell_deal_match_ui.left_grid_ui.getStateOfView()[1]).source_deal_detail_id;

                    var right_grid_select_id = frame_obj.contentWindow.buy_sell_deal_match_ui.right_grid_ui.getChangedRows();

                    var array_val_deal_ids_right = [];
					var array_val_deal_detail_ids_ids_right = [];
                    right_grid_select_id = right_grid_select_id.split(',');
                            
                    $.each(right_grid_select_id, function(a, c) {
                        var deal_ids_index = frame_obj.contentWindow.buy_sell_deal_match_ui.right_grid_ui.getColIndexById("source_deal_header_id");
						var deal_detail_ids_index = frame_obj.contentWindow.buy_sell_deal_match_ui.right_grid_ui.getColIndexById("source_deal_detail_id");
                        var b = frame_obj.contentWindow.buy_sell_deal_match_ui.right_grid_ui.getRowIndex(c);
                        var deal_ids = frame_obj.contentWindow.buy_sell_deal_match_ui.right_grid_ui.cells2(b, deal_ids_index).getValue();
						var deal_detail_ids = frame_obj.contentWindow.buy_sell_deal_match_ui.right_grid_ui.cells2(b, deal_detail_ids_index).getValue();
                        array_val_deal_ids_right.push(deal_ids);
						array_val_deal_detail_ids_ids_right.push(deal_detail_ids);
                    });

                    var manual_case_data_update = {
                        "action": "spa_buy_sell_match",
                        "flag": "g",
                        "source_deal_header_id": left_grid_select_id_source_deal_header_id,
                        "source_deal_header_id_from": array_val_deal_ids_right.toString(),
						"sell_deal_detail_id": left_grid_select_id_source_deal_detail_id,
						"source_deal_detail_id_from": array_val_deal_detail_ids_ids_right.toString()
						
                    };

                    adiha_post_data('return_json', manual_case_data_update, '', '', function(return_json) {
                        return_json = JSON.parse(return_json);
                        buy_sell_link_ui_template.template_layout.progressOff();
                        frame_obj.contentWindow.buy_sell_deal_match_ui.form_link.setItemValue('process_id', return_json[0].process_id);
                        var return_result = frame_obj.contentWindow.buy_sell_deal_match_ui.save_matched_deals(active_tab_id);
                        
                        if (!return_result) {
                            return;
                        } else if (return_result.type == 'alert-error' || return_result.type == 'alert') {
                            
                            dhtmlx.alert({
                                title:return_result.title,
                                type:return_result.type,
                                text: return_result.text,
                            });
                            return false;
                        }
                    });
                } else {
                    buy_sell_link_ui_template.template_layout.progressOff();
                    var return_result = frame_obj.contentWindow.buy_sell_deal_match_ui.save_matched_deals(active_tab_id);
                    
                    if (!return_result) {
                        return;
                    } else if (return_result.type == 'alert-error' || return_result.type == 'alert') {
                        
                        dhtmlx.alert({
                            title: return_result.title,
                            type: return_result.type,
                            text: return_result.text,
                        });

                        return false;
                    }
                }
            }

            /**
             * Parent function to be called after deal match saved from buysell.match.ui.php
             */
            buy_sell_link_ui_template.save_matched_deals_callback_parent = function(mode, type, msg, link_id) {
                
                if (type == 'Success') {
                    success_call(msg);

                    var closing_tab_id = get_active_tab_id();
                    
                    //refresh parent buysell.match.php grid
                    parent.buy_sell_link_ui.refresh_link_grid();
                    
                    //refresh deal match tab gris
                    buy_sell_link_ui_template.refresh_match_grids(-1);
                    
                    //create update tab
                    buy_sell_link_ui_template.load_link_detail(link_id);
                    
                    if (mode == 'i') {
                        buy_sell_link_ui_template.link_ui_tabbar.cells(closing_tab_id).close();
                    }
                } else {
                    success_call(msg, 'error');
                    return;
                }
            }

            function get_active_tab_id() {
                var active_tab_id = buy_sell_link_ui_template.link_ui_tabbar.getActiveTab(); 
                active_tab_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
                return active_tab_id;
            } 

            buy_sell_link_ui_template.close_tabs = function(tab_id) {
                if (buy_sell_link_ui_template.link_ui_tabbar.cells(tab_id)) {
                    buy_sell_link_ui_template.link_ui_tabbar.cells(tab_id).close();
                }
            }
          
            
            function enable_disable_menu(itemId, is_enable) {
                var active_tab_id = get_active_tab_id();
                
                if (is_enable) {
                    
                    if (has_rights_deal_match_iu === true) {
                        inner_menu_obj[active_tab_id].enableItem(itemId);
                    } else {
                        inner_menu_obj[active_tab_id].disableItem(itemId);
                    }
                } else {
                    inner_menu_obj[active_tab_id].disableItem(itemId);
                }
            }
            
            function enable_disable_deal_match_menu(itemId,is_enable) {
                var active_tab_id = '-1';
                
                if (is_enable) {               
                   inner_menu_obj[active_tab_id].enableItem(itemId);
                } else {
                    inner_menu_obj[active_tab_id].disableItem(itemId);
                }
            }

            buy_sell_link_ui_template.run_deal_match_manual_mode = function(source_deal_header_id, array_val_deal_ids, source_deal_detail_id, array_source_deal_detail_id_from) {
                buy_sell_link_ui_template.template_layout.progressOn();
                
                var manual_case_data = {
                    "action": "spa_buy_sell_match",
                    "flag": "g",
                    "source_deal_header_id": source_deal_header_id,
                    "source_deal_header_id_from": array_val_deal_ids.toString(),
                    "sell_deal_detail_id": source_deal_detail_id,
                    "source_deal_detail_id_from": array_source_deal_detail_id_from
                };

                adiha_post_data('return_json', manual_case_data, '', '', function(return_json) {
                    return_json = JSON.parse(return_json);
                    if (return_json.length > 0) {
                        buy_sell_link_ui_template.template_layout.progressOff();
                        buy_sell_link_ui_template.match_deal_grids('', return_json[0].process_id);
                    } else {
                        buy_sell_link_ui_template.template_layout.progressOff();
                        show_messagebox('Product details of deals do not match. Please check the deals.');
                        return;
                    }
                });
            }

            buy_sell_link_ui_template.get_expired_selected_deal_ids = function(array_val_exp_date, effective_date) {
                
                var expired_deals = array_val_exp_date.filter(function(exp_date) {
                    
                    if (exp_date != undefined && Date.parse(exp_date.date) < effective_date) {
                        return exp_date;
                    }                         
                });

                var exp_deal_ids = [];
                
                if (expired_deals.length > 0) {
                    exp_deal_ids = expired_deals.reduce(function(a, v, i) {
                        a.push(v.deal_id);
                        
                        if (i % 6 == 0 && i > 0) {
                            a.push("\n");
                        }

                        return a;
                    }, []);
                }
                
                var filtered_exp_deal_ids = exp_deal_ids.filter(function(value, index) {
                    return exp_deal_ids.indexOf(value) === index || value === "\n";
                });

                return filtered_exp_deal_ids;
            }
        </script>
    </body>

</html>