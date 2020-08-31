<?php
/**
* Setup regerssion testing screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
        <?php require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
    </head>
    <body>
        <?php
            $function_id =  20009400;
            $filter_function_id = 20009401;
            $form_namespace = 'setup_regression_testing';
            $template_name = "SetupRegressionTesting";

            $form_obj = new AdihaStandardForm($form_namespace, $function_id);
            $form_obj->define_grid("SetupRegressionTesting");
            $form_obj->define_layout_width(380);
            //$form_obj->disable_multiple_select(false);
            $form_obj->define_custom_functions('', '', 'delete_regression_rule', 'load_complete');
            echo $form_obj->init_form('Setup Regression Testing');
            echo $form_obj->close_form();

            $rights_setup_regression_testing_iu = 20009401;
            $rights_setup_regression_testing_delete = 20009402;

            list (
                $has_rights_setup_regression_testing_iu,
                $has_rights_setup_regression_testing_delete
            ) = build_security_rights(
                $rights_setup_regression_testing_iu,
                $rights_setup_regression_testing_delete
            );
        ?>
    </body>
    <script type="text/javascript">
        setup_regression_testing.win_opened = false;
        var dhxWins;
        var tolerance_val;

        var has_rights_setup_regression_testing_iu = Boolean(<?php echo $has_rights_setup_regression_testing_iu ?>);
        var has_rights_setup_regression_testing_delete = Boolean(<?php echo $has_rights_setup_regression_testing_delete ?>);

        setup_regression_testing.load_complete = function(win, id) {
            var inner_tab_id = win.getAttachedObject().getAllTabs()[0];

            var form_obj = win.getAttachedObject().tabs(inner_tab_id).getAttachedObject().cells("a").getAttachedObject();
          
            //form_obj.addItem(null, {type:"input", name: "report_id", label:"Report", hidden: true}, 5, 4);
            form_obj.addItem(null, {type:"input", name: "paramset_id", label:"Paramset", hidden: true}, 6, 5);

            set_report_param_values(form_obj);

            form_obj.attachEvent('onChange', function(name, value) {
                if(name === 'regression_module_header_id') {
                    set_report_param_values(form_obj);
                    form_obj.setItemValue('label_filter', '');
                }
            });
        }

        function set_report_param_values(form_obj) {
            data = {
                "action": "spa_regression_testing",
                "flag": "k",
                "regression_module_header_id": form_obj.getItemValue('regression_module_header_id')
            };
            adiha_post_data('return_json', data, '', '', 'setup_regression_testing.load_complete_callback', false);
        }

        setup_regression_testing.load_complete_callback = function(result) {
            var data = JSON.parse(result);
            var tab_id = setup_regression_testing.tabbar.getActiveTab();
            var inner_tab = setup_regression_testing.tabbar.tabs(tab_id).getAttachedObject().getAllTabs()[0];
            var form_obj = setup_regression_testing.tabbar.tabs(tab_id).getAttachedObject().tabs(inner_tab).getAttachedObject().cells('a').getAttachedObject();
            form_obj.setItemValue('paramset_id', data[0]['paramset_id']);
            //form_obj.setItemValue('report_id', data[0]['report_id']);
        };

        benchmark_popup = new dhtmlXPopup();
        tolerance_popup = new dhtmlXPopup();
        $(function() {
            dhxWins = new dhtmlXWindows();
            var grid_menu = setup_regression_testing.menu;
            var grid_obj = setup_regression_testing.grid;
            var parent_row = ''

            // Add Copy menu in Edit.
            grid_menu.addNewChild('t1', 1, 'copy', 'Copy', true, 'copy.gif', 'copy_dis.gif');

            grid_menu.addNewSibling('t1', 'process', 'Process', false , 'process.gif', 'process_dis.gif');
            grid_menu.addNewChild('process', 1, 'benchmark', 'Run BenchMark', true, 'run_benchmark.png', 'run_benchmark_dis.png');
            grid_menu.addNewChild('process', 1, 'post_regression', 'Post Regression', true, 'post_regression.png', 'post_regression_dis.png');
            grid_menu.addNewChild('process', 1, 'view_benchmark', 'View BenchMark', true, 'view_benchmark.png', 'view_benchmark_dis.png');

            grid_menu.attachEvent('onClick', setup_regression_testing.grid_menu_click_custom);
        
            grid_obj.attachEvent('onRowSelect', function() {
                var selected_row_id = grid_obj.getSelectedRowId();
                parent_row = grid_obj.getParentId(selected_row_id);

                grid_menu.setItemEnabled('copy');
                grid_menu.setItemEnabled('benchmark');
                grid_menu.setItemEnabled('post_regression');
                grid_menu.setItemEnabled('view_benchmark');
                if(selected_row_id.indexOf(',') > -1 || parent_row == 0) {
                    //grid_menu.setItemDisabled('benchmark');
                    //grid_menu.setItemDisabled('post_regression');
                    grid_menu.setItemDisabled('view_benchmark');
                    grid_menu.setItemDisabled('copy');
                    //return false;
                }
                if (parent_row == 0) {
                    grid_menu.setItemDisabled('copy');
                    grid_menu.setItemDisabled('delete');
                }
            });
        });

        // Overridden create tab function to check for the authorized user and then continue creating tab for authorized user.
        setup_regression_testing.create_tab = function(r_id, col_id, grid_obj, acc_id, tab_index) {
            var system_defined_index = setup_regression_testing.grid.getColIndexById('is_system_defined');
            var is_system_defined = 'No';
            if (r_id < 0) {
                is_system_defined = 'No';
            } else {
                is_system_defined = setup_regression_testing.grid.cells(r_id, system_defined_index).getValue();
            }

            if (is_system_defined == 'Yes') {
                var param = {
                    "r_id": r_id,
                    "col_id": col_id,
                    "grid_obj": grid_obj,
                    "acc_id": acc_id,
                    "tab_index": tab_index
                }
                is_user_authorized('create_tab_auth_user', param);
            } else {
                create_tab_auth_user(r_id, col_id, grid_obj, acc_id, tab_index);
            }
        }

        // Same function copied from setup_regression_testing.create_tab
        function create_tab_auth_user(r_id, col_id, grid_obj, acc_id, tab_index) {
            var icons_path  = js_image_path + 'dhxtoolbar_web/';
            var full_id, text;
            var grid_obj = setup_regression_testing.grid;
            var tabbar_obj = setup_regression_testing.tabbar;

            if (r_id == -1 && col_id == 0) {
                full_id = setup_regression_testing.uid();
                full_id = full_id.toString();
                text = "New";
            } else {
                full_id = setup_regression_testing.get_id(grid_obj, r_id);
                text = setup_regression_testing.get_text(grid_obj, r_id);
                if (full_id == "tab_") {
                    var selected_row = grid_obj.getSelectedRowId();
                    var state = grid_obj.getOpenState(selected_row);
                    if (state) {
                        grid_obj.closeItem(selected_row);
                    } else {
                        grid_obj.openItem(selected_row);
                    }
                    return false;
                }
            }
            
            if (!setup_regression_testing.pages[full_id]) {
                var tab_context_menu = new dhtmlXMenuObject();
                tab_context_menu.setIconsPath(icons_path);
                tab_context_menu.renderAsContextMenu();
                tabbar_obj.addTab(full_id, text, null, tab_index, true, true);
                //using window instead of tab
                var win = tabbar_obj.cells(full_id);
                tabbar_obj.t[full_id].tab.id = full_id;
                tab_context_menu.addContextZone(full_id);
                tab_context_menu.loadStruct([{id:"close", text:"Close", title: "Close"},{id:"close_all", text:"Close All", title: "Close All"},{id:"close_other", text:"Close Other Tabs", title: "Close Other Tabs"}]);

                tab_context_menu.attachEvent("onContextMenu", function(zoneId) {
                    tabbar_obj.tabs(zoneId).setActive();
                });

                tab_context_menu.attachEvent("onClick", function(id, zoneId) {
                    var ids = tabbar_obj.getAllTabs();
                    switch(id) {
                        case "close_other":
                            ids.forEach(function(tab_id) {
                                if (tab_id != zoneId) {
                                    delete setup_regression_testing.pages[tab_id];
                                    tabbar_obj.tabs(tab_id).close();
                                }
                            });
                        break;
                        case "close_all":
                            ids.forEach(function(tab_id) {
                                delete setup_regression_testing.pages[tab_id];
                                tabbar_obj.tabs(tab_id).close();
                            });
                        break;
                        case "close":
                            ids.forEach(function(tab_id) {
                                if (tab_id == zoneId) {
                                    delete setup_regression_testing.pages[tab_id];
                                    tabbar_obj.tabs(tab_id).close();
                                }
                            });
                        break;
                    }
                });

                var toolbar = win.attachToolbar();
                toolbar.setIconsPath(icons_path);
                toolbar.attachEvent("onClick",setup_regression_testing.tab_toolbar_click);
                toolbar.loadStruct([{id:"save", type: "button", img: "save.gif", imgdis: "save_dis.gif", text:"Save", title: "Save"}]);
                tabbar_obj.cells(full_id).setText(text);
                tabbar_obj.cells(full_id).setActive();
                tabbar_obj.cells(full_id).setUserData("row_id", r_id);
                win.progressOn();
                setup_regression_testing.set_tab_data(win, full_id);
                setup_regression_testing.pages[full_id] = win;
            } else {
                tabbar_obj.cells(full_id).setActive();
            }

            setup_regression_testing.uid = function() {
                return (new Date()).valueOf();
            }
        }

        setup_regression_testing.run_batch_process = function(regression_rule_id, is_post_regression) {
            if(is_post_regression == false) {
                var is_drop_benchmark_checked = ($('#drop_benchmark_table:checked').length > 0) ? 1 : 0;
                var sql = "spa_pre_post_analysis @flag='b', @regression_rule_id='" + regression_rule_id + "', @drop_benchmark_table=" +  is_drop_benchmark_checked;
                adiha_run_batch_process(sql, 'batch_type=c', 'Benchmark');
                benchmark_popup.hide();
            } else if(is_post_regression == true) {
                tolerance_val = $('#tolerance_value').val();
                if(tolerance_val.match(/^\d*\.?\d*$/)) {
                    tolerance_popup.hide()
                    var param = {
                        "action": "spa_pre_post_analysis",
                        "flag": "v",
                        "regression_rule_id": regression_rule_id
                    };
                    adiha_post_data('return_json', param, '', '', 'setup_regression_testing.confirm_post_regression', false);
                } else {
                    show_messagebox("Invalid Tolerance Value.");
                }
            }
        }

        setup_regression_testing.grid_menu_click_custom = function (id, zoneId, cas) {
            switch (id) {
                case "benchmark":
                    var selected_row_id = setup_regression_testing.grid.getSelectedRowId();
                    var regression_rule_id_index = setup_regression_testing.grid.getColIndexById('regression_rule_id');
                    var regression_rule_group_name_index = setup_regression_testing.grid.getColIndexById('regression_group');
                    var regression_rule_id = setup_regression_testing.grid.getSelectedRowId()
                        .split(',')
                        .reduce(function (a, b) {
                            if (a.indexOf(b) < 0) {
                                if (this.getParentId(b) != 0) {
                                    a.push(b);
                                } else {
                                    this.getAllSubItems(b).split(',').forEach(function (e) {
                                        return a.push(e);
                                    });
                                }
                            }
                            return a;
                        }.bind(setup_regression_testing.grid), [])
                        .map(function(e) {
                            return this.cells(e,1).getValue();
                        }
                        .bind(setup_regression_testing.grid))
                        .join(',');

                        var html = '<div style=" width:190px; height:50px;"><input type="checkbox" id="drop_benchmark_table" />'
                        html += '<label for="drop_benchmark_table">Re-create Benchmark Table</label>'
                        html += '<br/><br/><input type="button" style="background: #82e1d4; border:none;" value="OK" id="btn_ok" onclick="setup_regression_testing.run_batch_process(' + "'" + regression_rule_id + "'"+ ', false)" />'
                        html += '<input style="margin-left:10px; background: #82e1d4; border:none;" type="button" value="Cancel" id="btn_cancel" onclick="benchmark_popup.hide()" /></div>'
                        benchmark_popup.attachHTML(html);
                        benchmark_popup.show(-150,-250,400,300);
                break;
                case "view_benchmark":
                    var selected_row_id = setup_regression_testing.grid.getSelectedRowId();
                    var regression_rule_id_index = setup_regression_testing.grid.getColIndexById('regression_rule_id');
                    var filter_index = setup_regression_testing.grid.getColIndexById('filter');
                    var regression_rule_id = setup_regression_testing.grid.cells(selected_row_id, regression_rule_id_index).getValue();
                    var filter = setup_regression_testing.grid.cells(selected_row_id, filter_index).getValue();
                   
                    var popup_window = new dhtmlXWindows();
                    var view_benchmark_window = popup_window.createWindow('w1', 0, 0, 1080, 460);
                    view_benchmark_window.centerOnScreen();
                    view_benchmark_window.maximize();
                    view_benchmark_window.setText('View Benchmark');
                    view_benchmark_window.setModal(true);
                    //view_benchmark_window.attachURL('view.benchmark.php?regression_rule_id=' + regression_rule_id + '&filter=' + filter,   false);
                    var filter_params = {
                        regression_rule_id: regression_rule_id,
                        filter: filter
                    }
                    var src = 'view.benchmark.php';
                    view_benchmark_window.attachURL(src, false, filter_params);
                break;
                case "post_regression":
                    var selected_row_id = setup_regression_testing.grid.getSelectedRowId();
                    var regression_rule_id_index = setup_regression_testing.grid.getColIndexById('regression_rule_id');
                    var regression_rule_group_name_index = setup_regression_testing.grid.getColIndexById('regression_group');
                    var regression_rule_id = setup_regression_testing.grid.getSelectedRowId()
                        .split(',')
                        .reduce(function (a, b) {
                            if (a.indexOf(b) < 0) {
                                if (this.getParentId(b) != 0) {
                                    a.push(b);
                                } else {
                                    this.getAllSubItems(b).split(',').forEach(function (e) {
                                        return a.push(e);
                                    });
                                }
                            }
                            return a;
                        }.bind(setup_regression_testing.grid), [])
                        .map(function(e) {
                            return this.cells(e,1).getValue();
                        }
                        .bind(setup_regression_testing.grid))
                        .join(',');
                    var html = '<div style=" width:190px; height:70px;"><input type="text" value="0.0001" id="tolerance_value" style="width: 180px;" />'
                    html += '<label for="tolerance_value">Fault Tolerance Value</label>'
                    html += '<br><br><input type="button" style="background: #82e1d4; border:none;" value="OK" id="btn_ok1" onclick="setup_regression_testing.run_batch_process(' + "'" + regression_rule_id + "'"+ ',true)" />'
                    html += '<input style="margin-left:10px; background: #82e1d4; border:none;" type="button" value="Cancel" id="btn_cancel" onclick="tolerance_popup.hide()" /></div>'
                    tolerance_popup.attachHTML(html);
                    tolerance_popup.show(-150,-250,400,300);
                break;
                case "copy":
                    var selected_row_id = setup_regression_testing.grid.getSelectedRowId();
                    var regression_rule_id_index = setup_regression_testing.grid.getColIndexById('regression_rule_id');
                    var rule_id = setup_regression_testing.grid.cells(selected_row_id, regression_rule_id_index).getValue();

                    data = {
								"action": "spa_regression_testing",
								"flag": "c",
								"regression_rule_id": rule_id
							};
					adiha_post_data('return_array', data, '', '', 'setup_regression_testing.post_delete_callback');
                break;
            }
        };

        setup_regression_testing.confirm_post_regression = function(result){
            var data = JSON.parse(result);
            var selected_row_id = setup_regression_testing.grid.getSelectedRowId();
            var regression_rule_id_index = setup_regression_testing.grid.getColIndexById('regression_rule_id');
            var regression_rule_group_name_index = setup_regression_testing.grid.getColIndexById('regression_group');
            var regression_rule_id = setup_regression_testing.grid.getSelectedRowId()
                .split(',')
                .reduce(function (a, b) {
                    if (a.indexOf(b) < 0) {
                        if (this.getParentId(b) != 0) {
                            a.push(b);
                        } else {
                            this.getAllSubItems(b).split(',').forEach(function (e) {
                                return a.push(e);
                            });
                        }
                    }
                    return a;
                }.bind(setup_regression_testing.grid), [])
                .map(function(e) {
                    return this.cells(e,1).getValue();
                }
                .bind(setup_regression_testing.grid))
                .join(',');

            var is_confirmed = false;
            if(data[0]['errorcode'] === 'Error') {
                if(data[0]['recommendation'] === '1') {
                    show_messagebox("No Benchmark Found For Run Filter.");
                    return;
                }
                dhtmlx.confirm({
                    title: "Confirmation",
                    type:"confirm-warning",
                    text: "Benchmark data is missing for few/all table(s). Do you want to continue?",
                    callback: function(result) {
                        if(result) {
                            var sql = "spa_pre_post_analysis @flag='p',@floating_tolerance_value=" + tolerance_val + " ,@regression_rule_id='" + regression_rule_id + "'";
                            adiha_run_batch_process(sql, '', 'Post Regression'); 
                        }
                    }
                });
            } else if(data[0]['errorcode'] == 'Success') {
                var sql = "spa_pre_post_analysis @flag='p',@floating_tolerance_value=" + tolerance_val + ", @regression_rule_id='" + regression_rule_id + "'";
                adiha_run_batch_process(sql, 'batch_type=c', 'Post Regression');
            }
        }

        setup_regression_testing.delete_regression_rule = function(result) {
            var sel_row_id = setup_regression_testing.grid.getSelectedRowId();
            var rule_id_col_index = setup_regression_testing.grid.getColIndexById('regression_rule_id');
            var system_defined_index = setup_regression_testing.grid.getColIndexById('is_system_defined');
            var is_system_defined = setup_regression_testing.grid.cells(sel_row_id, system_defined_index).getValue();

            if (sel_row_id != null) {
                sel_row_id = sel_row_id.split(',');
                var rule_ids = [];
                sel_row_id.forEach(function(rid) {
                    var rule_id =  setup_regression_testing.grid.cells(rid, rule_id_col_index).getValue();
                    rule_ids.push(rule_id);
                });
                rule_ids = rule_ids.toString();

                dhtmlx.confirm({
                    title: "Confirmation",
                    type:"confirm-warning",
                    text: "Are you sure you want to delete?",
                    callback: function(result) {
                        if(result) {
                            var data = {
                                "action": "spa_regression_testing",
                                "flag": "d",
                                "del_regression_rule_id": rule_ids
                            };

                            if (is_system_defined == 'Yes') {
                                is_user_authorized('confirm_delete', data);
                            } else {
                                confirm_delete(data['action'], data['flag'], data['del_regression_rule_id']);
                            }
                        }
                    }
                });
            }
        }

        function confirm_delete(action, flag, del_regression_rule_id) {
            var data = {
                "action": action,
                "flag": flag, 
                "del_regression_rule_id": del_regression_rule_id
            }
            adiha_post_data('return_array', data, '', '', 'setup_regression_testing.post_delete_callback');
        }
    </script>
</html>