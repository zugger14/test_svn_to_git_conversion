<?php
/**
 * Setup simple alerts screen
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
<?php
$application_function_id = 10122600;

$rights_alerts_iu = 10122610;
$rights_alerts_delete = 10122611;

list (
    $has_rights_alerts_delete ,
    $has_rights_alerts_iu,
    $has_right_form
    ) = build_security_rights(
    $rights_alerts_delete ,
    $rights_alerts_iu,
    $application_function_id
);

$form_namespace = 'setup_alert';
$form_obj = new AdihaStandardForm($form_namespace, $application_function_id);
$form_obj->define_grid("SetupAlerts", "EXEC spa_alert_sql @flag = 's', @alert_category = 's'", "t");
$form_obj->define_layout_width(450);
$form_obj->define_custom_functions('', 'load_rule_alert', 'delete_rule_alert', '');
$form_obj->define_custom_setting('true');
echo $form_obj->init_form('Alerts', 'Alert Details');
echo $form_obj->close_form();
?>
<body>
</body>
<script type="text/javascript">
    var form_right = '<?php echo $has_right_form; ?>';
    var add_save_right = '<?php echo $has_rights_alerts_iu; ?>';
    var sql_param = {
        "sql":"EXEC spa_alert_sql @flag = 's', @alert_category = 's', @show_unused_rule = '1'",
        "grid_type":"tg"
        ,"grouping_column":"Category,Rule_Name"
    };
    $(function() {
        /*Added new menu to show unused rule*/
        setup_alert.menu.addNewSibling('t2','import_export_alert', 'Import/Export Workflow', false, 'export.gif', 'export_dis.gif');
        setup_alert.menu.addNewSibling('import_export_alert','show_unused_rule', 'Show Unused Rule', false, 'show.png', 'show_dis.png');
        setup_alert.menu.addNewSibling('show_unused_rule','hide_unused_rule', 'Hide Unused Rule', false, 'hide.png', 'hide_dis.png');
        setup_alert.menu.hideItem('hide_unused_rule');
        setup_alert.menu.addNewChild('import_export_alert',1,'import_alert', 'Import', false, 'import.gif', 'import_dis.gif');
        setup_alert.menu.addNewChild('import_export_alert',2,'import_alert_as', 'Import As', false, 'import.gif', 'import_dis.gif');
        setup_alert.menu.addNewChild('import_export_alert',3,'export_alert', 'Export', true, 'export.gif', 'export_dis.gif');
        setup_alert.menu.addNewChild('t1',1,'copy_alert', 'Copy', true, 'export.gif', 'export_dis.gif');
        //setup_alert.menu.addNewChild('t2',6,'export_copy_alert', 'Export Alert as Copy', true, 'export.gif', 'export_dis.gif');
        setup_alert.grid.attachEvent("onRowSelect", function(id,ind){
            setup_alert.menu.setItemEnabled('export_alert');
            setup_alert.menu.setItemEnabled('copy_alert');
            // setup_alert.menu.setItemEnabled('export_copy_alert');
        });

    });

    setup_alert.load_rule_alert = function(win, tab_id, grid_obj) {
        var alert_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        var alert_name = setup_alert.tabbar.tabs(tab_id).getText();

        if (alert_name == get_locale_value('New')) {
            var alert_rule_id = '';
        } else {
            var selected_row = setup_alert.grid.getSelectedRowId();
            var alert_rule_id = setup_alert.grid.cells(selected_row,1).getValue();
        }
        win.progressOff();
        win.attachURL("../setup_rule_workflow/workflow.rule.php?call_from=alert&alert_id=" + alert_rule_id + '&rights_ui=' + form_right + '&add_save_right=' + add_save_right);
    }

    setup_alert.delete_rule_alert = function() {
        var select_id = setup_alert.grid.getSelectedRowId();
        var count = select_id.indexOf(",") > -1 ? select_id.split(",").length : 1;
        select_id = select_id.indexOf(",") > -1 ? select_id.split(",") : [select_id];
        var delete_id = [];
        if(select_id == null) {
            show_messagebox('Please select the data you want to delete.');
            return;
        }

        for (var i = 1; i <= count; i++) {
            var full_id = setup_alert.get_id(setup_alert.grid, select_id[i - 1]);
            var full_id_split = full_id.split("_");
            full_id_split.splice(0, 1);
            var get_id_only = full_id_split.join("_");
            if (get_id_only == "") {
                dhtmlx.alert({
                    title: "Alert",
                    type: "alert",
                    text: "Please select child item only."
                });
                return false;
            } else {
                delete_id.push(get_id_only);
            }
        }

        var data = {
            "action": "spa_setup_rule_workflow",
            "flag": "l",
            "alert_rule_id": delete_id.join(",")
        };
        var confirm_msg = 'Are you sure you want to delete?';

        dhtmlx.message({
            type: "confirm",
            title: "Confirmation",
            ok: "Confirm",
            text: confirm_msg,
            callback: function(result) {
                if (result)
                    adiha_post_data('return_array', data, '', '', 'setup_alert.post_delete_callback', '');
            }
        });
    }

    /*overridden adiha standard function since save button being custom added button. */
    setup_alert.post_callback = function(result) {
        var tab_id = setup_alert.tabbar.getActiveTab();
        var is_hidden = setup_alert.menu.isItemHidden('show_unused_rule');
        if (result[0].errorcode == "Success") {
            var col_type = setup_alert.grid.getColType(0);
            if (col_type == "tree") {
                setup_alert.grid.saveOpenStates();
            }
            if (result[0].recommendation != null) {
                var tab_id = setup_alert.tabbar.getActiveTab();
                var previous_text = setup_alert.tabbar.tabs(tab_id).getText();
                if (previous_text == get_locale_value("New")) {
                    var tab_text = new Array();
                    if (result[0].recommendation.indexOf(",") != -1) {
                        tab_text = result[0].recommendation.split(",")
                    } else {
                        tab_text.push(0, result[0].recommendation);
                    }
                    setup_alert.tabbar.tabs(tab_id).setText(tab_text[1]);

                    if (is_hidden) {
                        sql_param.sql = "EXEC spa_alert_sql @flag = 's', @alert_category = 's', @show_unused_rule = '1'";
                        setup_alert.refresh_grid(sql_param, setup_alert.open_tab);
                    } else {
                        setup_alert.refresh_grid("", setup_alert.open_tab);
                    }
                } else {
                    if (is_hidden) {
                        sql_param.sql = "EXEC spa_alert_sql @flag = 's', @alert_category = 's', @show_unused_rule = '0'";
                        setup_alert.refresh_grid(sql_param, setup_alert.refresh_tab_properties);
                    } else {
                        setup_alert.refresh_grid("", setup_alert.refresh_tab_properties);
                    }
                }
            }
            setup_alert.menu.setItemDisabled("delete");
        }
    };

    /*overridden adiha standard function to disable double click for unused rule. */
    setup_alert.create_tab = function(r_id, col_id, grid_obj, acc_id,tab_index) {
        if (r_id == -1 && col_id == 0) {
            full_id = setup_alert.uid();
            full_id = full_id.toString();
            text = get_locale_value("New");
        } else {
            /*Value of notification type is not present for unused rule*/
            var col_notification_type = setup_alert.grid.getColIndexById('notification_type');
            var notification_type = setup_alert.grid.cells(r_id,col_notification_type).getValue();
            if (!notification_type || notification_type == '' || notification_type == null)
                return false;

            full_id = setup_alert.get_id(setup_alert.grid, r_id);
            text = setup_alert.get_text(setup_alert.grid, r_id);
            if (full_id == "tab_"){
                var selected_row = setup_alert.grid.getSelectedRowId();
                var state = setup_alert.grid.getOpenState(selected_row);
                if (state)
                    setup_alert.grid.closeItem(selected_row);
                else
                    setup_alert.grid.openItem(selected_row);
                return false;
            }
        }

        if (!setup_alert.pages[full_id]) {
            var tab_context_menu = new dhtmlXMenuObject();
            tab_context_menu.setIconsPath(js_image_path + '/dhxtoolbar_web/');
            tab_context_menu.renderAsContextMenu();
            setup_alert.tabbar.addTab(full_id,text, null, tab_index, true, true);
            //using window instead of tab
            var win = setup_alert.tabbar.cells(full_id);
            setup_alert.tabbar.t[full_id].tab.id = full_id;
            tab_context_menu.addContextZone(full_id);
            tab_context_menu.loadStruct([{id:"close", text:"Close", title: "Close"},{id:"close_all", text:"Close All", title: "Close All"},{id:"close_other", text:"Close Other Tabs", title: "Close Other Tabs"}]);
            tab_context_menu.attachEvent("onContextMenu", function(zoneId){
                setup_alert.tabbar.tabs(zoneId).setActive();
            });
            tab_context_menu.attachEvent("onClick", function(id, zoneId){
                var ids = setup_alert.tabbar.getAllTabs();
                switch(id) {
                    case "close_other":
                        ids.forEach(function(tab_id) {
                            if (tab_id != zoneId) {
                                delete setup_alert.pages[tab_id];
                                setup_alert.tabbar.tabs(tab_id).close();
                            }
                        })
                        break;
                    case "close_all":
                        ids.forEach(function(tab_id) {
                            delete setup_alert.pages[tab_id];
                            setup_alert.tabbar.tabs(tab_id).close();
                        })
                        break;
                    case "close":
                        ids.forEach(function(tab_id) {
                            if (tab_id == zoneId) {
                                delete setup_alert.pages[tab_id];
                                setup_alert.tabbar.tabs(tab_id).close();
                            }
                        })
                        break;
                }
            });
            setup_alert.tabbar.cells(full_id).setText(text);
            setup_alert.tabbar.cells(full_id).setActive();
            setup_alert.tabbar.cells(full_id).setUserData("row_id", r_id);
            win.progressOn();
            setup_alert.load_rule_alert(win,full_id,grid_obj,acc_id);
            setup_alert.pages[full_id] = win;
        }
        else {
            setup_alert.tabbar.cells(full_id).setActive();
        };
    };

    setup_alert.post_delete_callback = function(result) {
        var full_id;
        var is_hidden = setup_alert.menu.isItemHidden('show_unused_rule');
        if (is_hidden) {
            sql_param.sql = "EXEC spa_alert_sql @flag = 's', @alert_category = 's', @show_unused_rule = '1'";
        }
        if (result[0][0] == "Success") {
            var select_id = setup_alert.grid.getSelectedRowId();
            var count = select_id.indexOf(",") > -1 ? select_id.split(",").length : 1;
            select_id = select_id.indexOf(",") > -1 ? select_id.split(",") : [select_id];
            for (var i = 0; i < count ; i++) {
                full_id = setup_alert.get_id(setup_alert.grid, select_id[i]);
                if (setup_alert.pages[full_id]) {
                    setup_alert.tabbar.cells(full_id).close();
                }
            }
            setup_alert.menu.setItemDisabled("delete");
            dhtmlx.message({
                text:result[0][4],
                expire:1000
            });
            var col_type = setup_alert.grid.getColType(0);
            if (col_type == "tree") {
                setup_alert.grid.saveOpenStates();
            }
            var page_no = setup_alert.grid.currentPage;
            setup_alert.refresh_grid(sql_param, function(){
                setup_alert.grid.filterByAll();
                if (col_type == "tree") {
                    setup_alert.grid.loadOpenStates();
                };
                setup_alert.grid.changePage(page_no);
            });
        } else {
            dhtmlx.message({
                title:"Alert",
                type:"alert",
                text:result[0][4]
            });
        }
    };

    setup_alert.grid_menu_click = function(id, zoneId, cas) {
        var selected_row = "";
        switch(id) {
            case "add":
                setup_alert.create_tab(-1,0,0,0);
                break;
            case "delete":
                setup_alert.delete_rule_alert();
                break;
            case "excel":
                setup_alert.grid.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                break;
            case "pdf":
                setup_alert.grid.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                break;
            case "refresh":
                var filter_param = setup_alert.get_filter_parameters();
                setup_alert.refresh_grid("",setup_alert.enable_menu_item, filter_param);
                setup_alert.layout.cells("a").collapse();
                break;
            case "pivot":
                var grid_obj = setup_alert.grid;
                var grid_name = "SetupAlerts";
                var grid_sp = "EXEC spa_alert_sql @flag = 's', @alert_category = 's'";
                open_grid_pivot(grid_obj, grid_name, -1, grid_sp);
                break;
            case "import_alert":
                if (setup_alert.import_window != null && setup_alert.import_window.unload != null) {
                    setup_alert.import_window.unload();
                    setup_alert.import_window = w2 = null;
                }
                if (!setup_alert.import_window) {
                    setup_alert.import_window = new dhtmlXWindows();
                }

                setup_alert.new_win = setup_alert.import_window.createWindow('w2', 0, 0, 650, 250);

                var text = "Import Alert";

                setup_alert.new_win.setText(text);
                setup_alert.new_win.setModal(true);

                var url = app_form_path + '_compliance_management/setup_rule_workflow/manage.alert.workflow.import.export.php';
                url = url + '?flag=import_workflow&call_from=mapping';
                setup_alert.new_win.attachURL(url, false, true);
                break;
            case "export_alert":
                var selected_id = setup_alert.grid.getSelectedRowId();
                if (!selected_id || selected_id == '') {
                    dhtmlx.alert({
                        type: "alert",
                        title:'Alert',
                        text:"No alert selected."
                    });
                    return;
                }

                if (selected_id.split(',').length > 1) {
                    dhtmlx.alert({
                        type: "alert",
                        title:'Alert',
                        text:"Select single module."
                    });
                    return;
                }
                var level = setup_alert.grid.getLevel(selected_id);
                if (level == 0)
                    return;
                var col_module_event_id = setup_alert.grid.getColIndexById('module_events_id');
                var module_event_id = setup_alert.grid.cells(selected_id,col_module_event_id).getValue();
                data = {"action": "spa_workflow_import_export",
                    "flag": "export_workflow",
                    "module_event_id": module_event_id
                };
                adiha_post_data('return_array', data, '', '', 'setup_alert.download_script', '', '');
                break;
            case "import_alert_as":
                if (setup_alert.import_window != null && setup_alert.import_window.unload != null) {
                    setup_alert.import_window.unload();
                    setup_alert.import_window = w2 = null;
                }
                if (!setup_alert.import_window) {
                    setup_alert.import_window = new dhtmlXWindows();
                }

                setup_alert.new_win = setup_alert.import_window.createWindow('w2', 0, 0, 650, 250);

                var text = "Import Alert";

                setup_alert.new_win.setText(text);
                setup_alert.new_win.setModal(true);

                var url = app_form_path + '_compliance_management/setup_rule_workflow/manage.alert.workflow.import.export.php';
                url = url + '?flag=import_workflow&call_from=mapping&copy_field_req=1';
                setup_alert.new_win.attachURL(url, false, true);
                break;
            case "copy_alert":
                var selected_id = setup_alert.grid.getSelectedRowId();
                if (!selected_id || selected_id == '') {
                    dhtmlx.alert({
                        type: "alert",
                        title:'Alert',
                        text:"No alert selected."
                    });
                    return;
                }

                if (selected_id.split(',').length > 1) {
                    dhtmlx.alert({
                        type: "alert",
                        title:'Alert',
                        text:"Select single module."
                    });
                    return;
                }
                var level = setup_alert.grid.getLevel(selected_id);
                if (level == 0)
                    return;
                var col_module_event_id = setup_alert.grid.getColIndexById('module_events_id');
                var module_event_id = setup_alert.grid.cells(selected_id,col_module_event_id).getValue();
                data = {"action": "spa_workflow_import_export",
                    "flag": "copy_workflow",
                    "module_event_id": module_event_id
                };
                adiha_post_data('return_array', data, '', '', 'setup_alert.import_copy', '', '');
                break;
            case "export_copy_alert":
                var selected_id = setup_alert.grid.getSelectedRowId();
                if (!selected_id || selected_id == '') {
                    dhtmlx.alert({
                        type: "alert",
                        title:'Alert',
                        text:"No alert selected."
                    });
                    return;
                }

                if (selected_id.split(',').length > 1) {
                    dhtmlx.alert({
                        type: "alert",
                        title:'Alert',
                        text:"Select single module."
                    });
                    return;
                }
                var level = setup_alert.grid.getLevel(selected_id);
                if (level == 0)
                    return;
                var col_module_event_id = setup_alert.grid.getColIndexById('module_events_id');
                var module_event_id = setup_alert.grid.cells(selected_id,col_module_event_id).getValue();
                data = {"action": "spa_workflow_import_export",
                    "flag": "copy_workflow",
                    "module_event_id": module_event_id
                };
                adiha_post_data('return_array', data, '', '', 'setup_alert.download_script', '', '');
                break;

            case "show_unused_rule":
                sql_param.sql = "EXEC spa_alert_sql @flag = 's', @alert_category = 's', @show_unused_rule = '1'";
                setup_alert.refresh_grid(sql_param,setup_alert.enable_menu_item, '');
                setup_alert.menu.showItem('hide_unused_rule');
                setup_alert.menu.hideItem('show_unused_rule');
                setup_alert.menu.setItemDisabled('import_export_alert');
                break;
            case "hide_unused_rule":
                sql_param.sql = "EXEC spa_alert_sql @flag = 's', @alert_category = 's', @show_unused_rule = '0'";
                setup_alert.refresh_grid(sql_param,setup_alert.enable_menu_item, '');
                setup_alert.menu.showItem('show_unused_rule');
                setup_alert.menu.hideItem('hide_unused_rule');
                setup_alert.menu.setItemEnabled('import_export_alert');
                break;

            default:
                break;
        }
    };

    setup_alert.download_script = function(result) {
        var selected_id = setup_alert.grid.getSelectedRowId();
        var col_alert_sql_name = setup_alert.grid.getColIndexById('alert_sql_name');
        var module_name = setup_alert.grid.cells(selected_id,col_alert_sql_name).getValue();
        var ua = window.navigator.userAgent;
        var msie = ua.indexOf("MSIE ");
        var blob = null;
        if (msie > 0|| !!navigator.userAgent.match(/Trident.*rv\:11\./)) { // Code to download file for IE
            if ( window.navigator.msSaveOrOpenBlob && window.Blob ) {
                blob = new Blob( [result[0][0]], { type: "text/csv;charset=utf-8;" } );
                navigator.msSaveOrOpenBlob( blob, module_name+ "_import.txt" );
            }
        }
        else { // Code to download file for other browser
            blob = new Blob([result[0][0]],{type: "text/csv;charset=utf-8;"});
            var link = document.createElement("a");
            if (link.download !== undefined) {
                var url = URL.createObjectURL(blob);
                link.setAttribute("href", url);
                link.setAttribute("download", module_name+ "_import.txt");
                link.style = "visibility:hidden";
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);
            }
        }
    }

    setup_alert.import_copy = function(result) {
        data = {"action": "spa_workflow_import_export",
            "flag": "import_workflow",
            "import_string": result[0][0]
        };
        adiha_post_data('return_array', data, '', '','setup_alert.import_export_call_back', '', '');
    }

    function import_from_file(file_name, copy_as) {
        var data = {"action": "spa_workflow_import_export",
            "flag": "confirm_override",
            "import_file": file_name,
            "import_as" : copy_as
        };

        adiha_post_data('return_array', data, '', '', 'import_after_confirmation', '', '');
    }

    function import_after_confirmation(return_value) {
        setup_alert.new_win.close();

        var confirm_type = return_value[0][0];
        var adiha_type = '';
        var validation = '';
        var file_name = return_value[0][1];
        var copy_as = return_value[0][2];

        if (confirm_type == 'r') {
            validation = 'Data already exist. Are you sure you want to replace data? ';
            adiha_type = 'confirm';
        } else {
            adiha_type = 'return_array';
        }

        data = {"action": "spa_workflow_import_export",
            "flag": "import_workflow",
            "import_file": file_name,
            "import_as" : copy_as
        };

        setTimeout(function() { /*Loading icon was not loaded without adding some delay*/
            adiha_post_data(adiha_type, data, '', '', 'setup_alert.import_export_call_back', '', validation);
        }, 10);
    }

    setup_alert.import_export_call_back = function(result) {
        setup_alert.layout.progressOn();

        var is_success = result[0][0];
        var error_code;
        var message;
        var show_msg;

        if (is_success === undefined) {
            error_code = result[0].errorcode;
            message = result[0].message
        } else {
            error_code = result[0][0];
            message = result[0][4];
            show_msg = 1;
        }

        if (error_code == "Success") {
            if (show_msg == 1) {
                dhtmlx.message({
                    text:result[0][4],
                    expire:1000
                });
            }
            setup_alert.refresh_grid("",'', '');
            setup_alert.layout.progressOff();
        } else {
            dhtmlx.message({
                title:"Alert",
                type:"alert",
                text:message
            });
            setup_alert.refresh_grid("",'', '');
            setup_alert.layout.progressOff();
        }
    }
</script>
</html>