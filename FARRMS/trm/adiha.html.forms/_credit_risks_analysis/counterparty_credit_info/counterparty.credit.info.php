<?php
/**
* Counterparty credit info screen
* @copyright Pioneer Solutions
*/
?>
<!--DOCTYPE transitional.dtd-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html>
<?php
require('../../../adiha.php.scripts/components/include.file.v3.php');
require('../../../adiha.html.forms/_setup/manage_documents/manage.documents.button.php');

$function_id = 10101122;
$rights_counterparty_credit_info_iu = 10101123;
$rights_counterparty_credit_info_delete = 10101124;

$rights_counterparty_credit_info_limit_iu = 10101130;
$rights_counterparty_credit_info_limit_delete = 10101131;

$rights_counterparty_credit_info_enhancement_iu = 10101126;
$rights_counterparty_credit_info_enhancement_delete = 10101127;

$rights_counterparty_credit_info_migration_iu = 10101133;
$rights_counterparty_credit_info_migration_delete = 10101134;

list (
    $has_rights_counterparty_credit_info_iu,
    $has_rights_counterparty_credit_info_delete,
    $has_rights_counterparty_credit_info_limit_iu,
    $has_rights_counterparty_credit_info_limit_delete,
    $has_rights_counterparty_credit_info_enhancement_iu,
    $has_rights_counterparty_credit_info_enhancement_delete,
    $has_rights_counterparty_credit_info_migration_iu,
    $has_rights_counterparty_credit_info_migration_delete,
    ) = build_security_rights(
    $rights_counterparty_credit_info_iu,
    $rights_counterparty_credit_info_delete,
    $rights_counterparty_credit_info_limit_iu,
    $rights_counterparty_credit_info_limit_delete,
    $rights_counterparty_credit_info_enhancement_iu,
    $rights_counterparty_credit_info_enhancement_delete,
    $rights_counterparty_credit_info_migration_iu,
    $rights_counterparty_credit_info_migration_delete
);

if($has_rights_counterparty_credit_info_limit_delete) {
    $has_rights_counterparty_credit_info_limit_delete = 'false';
} else {
    $has_rights_counterparty_credit_info_limit_delete = 'true';
}

if($has_rights_counterparty_credit_info_limit_iu) {
    $has_rights_counterparty_credit_info_limit_iu = 'false';
} else {
    $has_rights_counterparty_credit_info_limit_iu = 'true';
}

if($has_rights_counterparty_credit_info_enhancement_delete) {
    $has_rights_counterparty_credit_info_enhancement_delete = 'false';
} else {
    $has_rights_counterparty_credit_info_enhancement_delete = 'true';
}

if($has_rights_counterparty_credit_info_enhancement_iu) {
    $has_rights_counterparty_credit_info_enhancement_iu = 'false';
} else {
    $has_rights_counterparty_credit_info_enhancement_iu = 'true';
}

if($has_rights_counterparty_credit_info_migration_delete) {
    $has_rights_counterparty_credit_info_migration_delete = 'false';
} else {
    $has_rights_counterparty_credit_info_migration_delete = 'true';
}

if($has_rights_counterparty_credit_info_migration_iu) {
    $has_rights_counterparty_credit_info_migration_iu = 'false';
} else {
    $has_rights_counterparty_credit_info_migration_iu = 'true';
}

$counterparty_id = get_sanitized_value($_GET['counterparty_id'] ?? '');
$open_enhancement = get_sanitized_value($_GET['open_enhancement'] ?? '');
$source_deal_header_id = get_sanitized_value($_GET['source_deal_header_id'] ?? '');
$hide_tab = get_sanitized_value($_GET['hide_tab'] ?? '');
$source_deal_header_id = get_sanitized_value($_GET['source_deal_header_id'] ?? '');
$template_name = 'CounterpartyCreditInfo';
$form_namespace = 'cci_namespace';
$grid_name = 'counterparty_credit_info';

$form_obj = new AdihaStandardForm($form_namespace, $function_id);
$form_obj->define_grid($grid_name);
$form_obj->define_custom_functions('save_counterparty_credit_info', '', '', 'post_load_function');
$form_obj->add_privilege_menu('');
echo $form_obj->init_form('Counterparties', 'Counterparty Credit Info', $counterparty_id);

$toolbar_json_array = array(
    array(
        'json' => ' 
		            {id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif", title: "Refresh"},
                    {id:"t1", text:"Edit", img:"edit.gif", imgdis:"edit_dis.gif", items:[
                        {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add",disabled: "' . $has_rights_counterparty_credit_info_limit_iu . '"},
                        {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete", disabled: true}
                    ]},
                    {id: "t2", text: "Export", img: "export.gif", items: [
                        {id:"excel",img:"excel.gif", imgdis:"excel_dis.gif", text:"Excel", title:"Excel"},
                        {id:"pdf", img:"pdf.gif", text:"PDF", title:"PDF"}
                    ]},
                    {id:"pivot", text:"Pivot", img:"pivot.gif", imgdis:"pivot_dis.gif",enabled:"true"},
                    {id:"workflow_status", text:"Workflow Status", img:"report.gif", imgdis:"report_dis.gif", enabled: true}
                     ',
        'on_click' => 'cci_namespace.function_limit_grid_toolbar',
        'on_select' => "delete|$has_rights_counterparty_credit_info_limit_delete"

    ),
    array(
            'json' => '
                    {id:"t1", text:"Edit", img:"edit.gif", imgdis:"edit_dis.gif", items:[
                        {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add", disabled: "' . $has_rights_counterparty_credit_info_migration_iu . '"},
                        {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete", disabled: true}
                    ]},
                    {id: "t2", text: "Export", img: "export.gif", items: [
                        {id:"excel",img:"excel.gif", imgdis:"excel_dis.gif", text:"Excel", title:"Excel"},
                        {id:"pdf", img:"pdf.gif", text:"PDF", title:"PDF"}
                    ]}',
		'on_click' => 'cci_namespace.function_migration_grid_toolbar',
        'on_select' => "delete|$has_rights_counterparty_credit_info_migration_delete"

    ),
    array(
            'json' => '
                    {id:"t1", text:"Edit", img:"edit.gif", imgdis:"edit_dis.gif", items:[
                        {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add", disabled: "' . $has_rights_counterparty_credit_info_migration_iu . '"},
                        {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete", disabled: true}
                    ]},
                    {id: "t2", text: "Export", img: "export.gif", items: [
                        {id:"excel",img:"excel.gif", imgdis:"excel_dis.gif", text:"Excel", title:"Excel"},
                        {id:"pdf", img:"pdf.gif", text:"PDF", title:"PDF"}
                    ]}',
					
            'on_click' => 'cci_namespace.function_netting_grid_toolbar',
            'on_select' => "delete|$has_rights_counterparty_credit_info_migration_delete"
                
    ),
    array(
        'json' => '',
        'on_click' => ''
    )
);

echo $form_obj->set_grid_menu_json($toolbar_json_array, 'true');
echo $form_obj->close_form();

$category_name = 'Counterparty';
$category_sql = "SELECT value_id FROM static_data_value WHERE type_id = 25 AND code = '" . $category_name . "'";
$category_data = readXMLURL2($category_sql);
?>
<body>
</body>
<style>
    .xhdr,.objbox {
        width: auto !important;
    }
</style>
</html>
<script type="text/javascript">
    var info_id = null;
    var php_script_loc = "<?php echo $app_php_script_loc; ?>";
    var category_id = '<?php echo $category_data[0]['value_id'];?>';
    var counterparty_id = '<?php echo $counterparty_id ?>';

    var session = "<?php echo $session_id; ?>";
    var open_enhancement_tab = "<?php echo $open_enhancement ?>";
    var source_deal_header_id = "<?php echo $source_deal_header_id ?>";
    var hide_tab = "<?php echo $hide_tab ?>";
    var source_deal_header_id = "<?php echo $source_deal_header_id ?>";
    var has_rights_counterparty_credit_info_iu = <?php echo $has_rights_counterparty_credit_info_iu; ?>

        dhxWins = new dhtmlXWindows();

    /** [Attaching function on row double click overriding left grid standard function]
     */
    $(function(){
        if(counterparty_id) {           
            cci_namespace.layout.cells("a").collapse();
            if (open_enhancement_tab == 1) {
                open_enhancement('', counterparty_id);
            }
        }

        cci_namespace.menu.hideItem('t1');
        cci_namespace.menu.hideItem('process');        

        
        load_workflow_status();
    });

     /**
     * [calling post load functions]
     */
    cci_namespace.post_load_function = function() {
        cci_namespace.override_netting_grid();
        cci_namespace.override_standard_callback();
        cci_namespace.callback_limit_grid_refresh();
    }

    /**

    /**
     * [Function to override left grid double click standard function]
     */
    cci_namespace.custom_left_grid_double_click = function(){
       setTimeout(function(){
           override_standard_callback();
        }, 3000);
    }

    /**
     * [Toolbar function for limit grid]
     */

     cci_namespace.override_netting_grid = function() {
        var tab_id = cci_namespace.tabbar.getActiveTab();

        var win = cci_namespace.tabbar.cells(tab_id);
        var valid_status = 1;
        var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(" ", ""));
        var tab_obj = win.tabbar[object_id];
        var detail_tabs = tab_obj.getAllTabs();
        var id = detail_tabs.toString().split('_')[2];

        $.each(detail_tabs, function(index,value) {
            layout_obj = tab_obj.cells(value).getAttachedObject();
            layout_obj.forEachItem(function(cell){
                attached_obj = cell.getAttachedObject();
                if (attached_obj instanceof dhtmlXGridObject) {
                    var grid_obj = attached_obj.getUserData("","grid_obj");
                    if (grid_obj.indexOf("netting_group_") != -1) {
                        attached_obj.attachEvent('onRowDblClicked', function(id, ind) {
                            var contract_index = attached_obj.getColIndexById('contract');
                            var contract_id_index = attached_obj.getColIndexById('contract_id');
                            var row_id = attached_obj.getSelectedRowId();
                            var selected_id = attached_obj.cells(row_id, contract_id_index).getValue();

                            if (ind == contract_index) {
                                contract_window = new dhtmlXWindows();
                                var src = js_php_path + '/components/lib/adiha_dhtmlx/generic.browser.php?&browse_name=browse_contract&call_from=grid&grid_obj=netting_group_&callback_function=set_browse_label_value&grid_name=browse_contract&grid_label=Contract&selected_id=' + selected_id;

                                new_browse = contract_window.createWindow(object_id, 0, 0, 500, 500);
                                new_browse.setText("Browse");
                                new_browse.centerOnScreen();
                                new_browse.setModal(true);
                                new_browse.attachURL(src, false);
                            }
                        });
                    }
                }
            })
        });
    }

    function set_browse_label_value(grid_obj_name, browse_name, browse_value, browse_label) {
        var tab_id = cci_namespace.tabbar.getActiveTab();

        var win = cci_namespace.tabbar.cells(tab_id);
        var valid_status = 1;
        var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(" ", ""));
        var tab_obj = win.tabbar[object_id];
        var detail_tabs = tab_obj.getAllTabs();
        var id = detail_tabs.toString().split('_')[2];

        $.each(detail_tabs, function(index,value) {
            layout_obj = tab_obj.cells(value).getAttachedObject();
            layout_obj.forEachItem(function(cell){
                attached_obj = cell.getAttachedObject();
                if (attached_obj instanceof dhtmlXGridObject) {
                    var grid_obj = attached_obj.getUserData("","grid_obj");
                    if (grid_obj.indexOf(grid_obj_name) != -1) {
                        var contract_index = attached_obj.getColIndexById('contract');
                        var contract_id_index = attached_obj.getColIndexById('contract_id');
                        var row_id = attached_obj.getSelectedRowId();
                        attached_obj.cells(row_id, contract_index).setValue(browse_label);
                        attached_obj.cells(row_id, contract_id_index).setValue(browse_value);
                        attached_obj.cells(row_id, contract_id_index).cell.wasChanged = true;
                        attached_obj.cells(row_id, contract_index).cell.wasChanged = true;
                    }
                }
            })
        });
    }

    cci_namespace.function_limit_grid_toolbar = function(id){
        var active_tab_id = cci_namespace.tabbar.getActiveTab();
        var tab_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;

        var win = cci_namespace.tabbar.cells(active_tab_id);
        var tab_obj = win.getAttachedObject();
        var detail_tabs = tab_obj.getAllTabs();

        switch(id) {
            case 'add':
                param = 'credit.limit.php?counterparty_id=' + tab_id + '&mode=i&is_pop=true';
                var is_win = dhxWins.isWindow('w3');
                if (is_win == true) {
                    w3.close();
                }
                w3 = dhxWins.createWindow("w3", 320, 0, 700, 350);
                w3.centerOnScreen();
                w3.setText("Counterparty Credit Info - Limit");
                w3.setModal(true);
                w3.attachURL(param, false, true);

                w3.attachEvent("onClose", function(win) {
                    return true;
                });
                break;
            case 'edit':
                var check_status = true;
                $.each(detail_tabs, function(index,value) {
                    layout_obj = tab_obj.cells(value).getAttachedObject();
                    layout_obj.forEachItem(function(cell){
                        attached_obj = cell.getAttachedObject();
                        if (attached_obj instanceof dhtmlXGridObject) {
                            var grid_obj = attached_obj.getUserData("","grid_obj");
                            if (grid_obj.indexOf("counterparty_credit_limits_") != -1) {
                                var selectedId = attached_obj.getSelectedRowId();

                                var selected_level = attached_obj.getLevel(selectedId);
                                if(selected_level == 0) {
                                    var has_child = attached_obj.hasChildren(selectedId); 
                                    if(has_child > 0) {
                                        check_status = false;
                                    }                                 
                                } else if (selected_level == 1) {
                                    var has_child = attached_obj.hasChildren(selectedId); 
                                    if(has_child > 0) {
                                        check_status = false;
                                    } 
                                }
                                var system_id_col =attached_obj.getColIndexById('system_id');
                                var system_id = attached_obj.cells(selectedId, system_id_col).getValue();
                                
                                param = 'credit.limit.php?counterparty_id=' + tab_id + '&limit_id=' + system_id + '&mode=u&is_pop=true';
                            }
                        }
                    });
                });

                if(check_status) {
                    var is_win = dhxWins.isWindow('w3');
                    if (is_win == true) {
                        w3.close();
                    }
                    var height = cci_namespace.layout.cells('a').getHeight();
                    var width = cci_namespace.layout.cells('b').getWidth() + cci_namespace.layout.cells('a').getWidth();
                    w3 = dhxWins.createWindow({
                        id: 'w3'
                        ,width: width
                        ,height: height
                        ,resize: true
                    });
                    w3.centerOnScreen();
                    w3.setText("Counterparty Credit Info - Limit");
                    w3.setModal(true);
                    w3.attachURL(param, false, true);

                    w3.attachEvent("onClose", function(win) {
                        return true;
                    });
                }
            break;
            case 'delete':
                //Inner grid object is grid_name_active_tab_id eg. counterparty_credit_enhancements_4128
                $.each(detail_tabs, function(index,value) {
                    layout_obj = tab_obj.cells(value).getAttachedObject();
                    layout_obj.forEachItem(function(cell){
                        attached_obj = cell.getAttachedObject();
                        if (attached_obj instanceof dhtmlXGridObject) {
                            var grid_obj = attached_obj.getUserData("","grid_obj");
                            if (grid_obj.indexOf("counterparty_credit_limits_") != -1) {
                                var selectedId = attached_obj.getSelectedRowId();
                                var selected_row_array_delete = selectedId.split(',');
                                var selected_item_id_delete = '';
                                for(var i = 0; i < selected_row_array_delete.length; i++) {
                                    if (i == 0) {
                                        selected_item_id_delete =  attached_obj.cells(selected_row_array_delete[i], 0).getValue();
                                    } else {
                                        selected_item_id_delete = selected_item_id_delete + ',' + attached_obj.cells(selected_row_array_delete[i], 0).getValue();
                                    }
                                }

                                //var limit_id = attached_obj.cells(selectedId, 0).getValue();
                                data = {"action": "spa_counterparty_credit_limits",
                                    "flag": "d",
                                    "counterparty_credit_limit_id": selected_item_id_delete
                                };
                                adiha_post_data('confirm', data, '', '', 'cci_namespace.callback_limit_grid_refresh');
                            }
                        }
                    });
                });
                break;
            case 'pdf':
                $.each(detail_tabs, function(index,value) {
                    layout_obj = tab_obj.cells(value).getAttachedObject();
                    layout_obj.forEachItem(function(cell){
                        attached_obj = cell.getAttachedObject();
                        if (attached_obj instanceof dhtmlXGridObject) {
                            var grid_obj = attached_obj.getUserData("","grid_obj");
                            if (grid_obj.indexOf("counterparty_credit_limits_") != -1) {
                                attached_obj.toPDF(php_script_loc + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                            }
                        }
                    });
                });
                break;
            case 'excel':
                $.each(detail_tabs, function(index,value) {
                    layout_obj = tab_obj.cells(value).getAttachedObject();
                    layout_obj.forEachItem(function(cell){
                        attached_obj = cell.getAttachedObject();
                        if (attached_obj instanceof dhtmlXGridObject) {
                            var grid_obj = attached_obj.getUserData("","grid_obj");
                            if (grid_obj.indexOf("counterparty_credit_limits_") != -1) {
                                attached_obj.toExcel(php_script_loc + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                            }
                        }
                    });
                });
                break;
            case 'pivot':
                var pivot_exec_spa = "EXEC spa_counterparty_credit_limits @flag='g', @Counterparty_id=" + tab_id;
                $.each(detail_tabs, function(index,value) {
                    layout_obj = tab_obj.cells(value).getAttachedObject();
                    layout_obj.forEachItem(function(cell){
                        attached_obj = cell.getAttachedObject();
                        if (attached_obj instanceof dhtmlXGridObject) {
                            var grid_obj = attached_obj.getUserData("","grid_obj");
                            if (grid_obj.indexOf("counterparty_credit_limits_") != -1) {
                                var grid_obj = attached_obj;
                                open_grid_pivot(grid_obj, 'counterparty_credit_limits', 1, pivot_exec_spa, 'Counterparty Credit Limits');
                            }
                        }
                    });
                });
                break;
            case 'workflow_status':
                var limit_id = '';
                $.each(detail_tabs, function(index,value) {
                    layout_obj = tab_obj.cells(value).getAttachedObject();
                    layout_obj.forEachItem(function(cell){
                        attached_obj = cell.getAttachedObject();
                        if (attached_obj instanceof dhtmlXGridObject) {
                            var grid_obj = attached_obj.getUserData("","grid_obj");
                            if (grid_obj.indexOf("counterparty_credit_limits_") != -1) {
                                var selectedId = attached_obj.getSelectedRowId();
                                if (selectedId != null)
                                    limit_id = attached_obj.cells(selectedId, 0).getValue();
                            }
                        }
                    });
                });
                
                var workflow_report = new dhtmlXWindows();
                workflow_report_win = workflow_report.createWindow('w1', 0, 0, 900, 700);
                workflow_report_win.setText("Workflow Status");
                workflow_report_win.centerOnScreen();
                workflow_report_win.setModal(true);
                workflow_report_win.maximize();

                var filter_string = '';
                var process_table_xml = 'counterparty_credit_limit_id:' + limit_id;
                var page_url = js_php_path + '../adiha.html.forms/_compliance_management/setup_rule_workflow/workflow.report.php?filter_id=' + limit_id + '&source_column=counterparty_credit_limit_id&module_id=20609&process_table_xml=' + process_table_xml + '&filter_string=' + filter_string;
                workflow_report_win.attachURL(page_url, false, null);
                
                break;
			case 'refresh':
               cci_namespace.callback_limit_grid_refresh();
               break
            default:
                 dhtmlx.alert({title: "Information!", type: "alert-error", text: "Not implemented"});
            break;
        }
    }

    /*
     * [Toolbar function for enchancement grid]
     */
    // cci_namespace.function_enhancement_grid_toolbar = function(id){
    //     var counterparty_credit_enhancement_id = null;
    //     var active_tab_id = cci_namespace.tabbar.getActiveTab();
    //     var tab_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        
    //     var win = cci_namespace.tabbar.cells(active_tab_id);
    //     var tab_obj = win.getAttachedObject();
    //     var detail_tabs = tab_obj.getAllTabs();

    //     switch(id) {
    //         case 'add':
    //             data = {"action": "spa_counterparty_credit_info","flag": "g","Counterparty_id": tab_id};
    //             adiha_post_data('', data, '', '', 'load_enhancement_form_window');
    //             break;
    //         case 'delete':
    //             $.each(detail_tabs, function(index,value) {
    //                 layout_obj = tab_obj.cells(value).getAttachedObject();
    //                 layout_obj.forEachItem(function(cell){
    //                     attached_obj = cell.getAttachedObject();
    //                     if (attached_obj instanceof dhtmlXGridObject) {
    //                         var grid_obj = attached_obj.getUserData("","grid_obj");
    //                         if (grid_obj.indexOf("counterparty_credit_enhancements_") != -1) {
    //                             //var selectedId = attached_obj.getSelectedRowId();
                                
    //                             var selectedId = attached_obj.getSelectedRowId();
    //                             var selected_row_array_delete_enhancement = selectedId.split(',');
    //                             var selected_item_id_delete_enhancement = '';
    //                             for(var i = 0; i < selected_row_array_delete_enhancement.length; i++) {
    //                                             if (i == 0) {
    //                                                 selected_item_id_delete_enhancement =  attached_obj.cells(selected_row_array_delete_enhancement[i], 0).getValue();
    //                                                 } else {
    //                                                 selected_item_id_delete_enhancement = selected_item_id_delete_enhancement + ',' + attached_obj.cells(selected_row_array_delete_enhancement[i], 0).getValue();
    //                                           }
    //                                       }                         
                                
    //                             data = {"action": "spa_counterparty_credit_enhancements",
    //                                     "flag": "d",
    //                                     "counterparty_credit_enhancement_id": selected_item_id_delete_enhancement
    //                             };
    //                             adiha_post_data('confirm', data, '', '', 'callback_enhancement_grid_refresh');
    //                         }
    //                     }
    //                 });
    //             });
    //             break;
    //         case 'edit':
    //             $.each(detail_tabs, function(index,value) {
    //                 layout_obj = tab_obj.cells(value).getAttachedObject();
    //                 layout_obj.forEachItem(function(cell){
    //                     attached_obj = cell.getAttachedObject();
    //                     if (attached_obj instanceof dhtmlXGridObject) {
    //                         var grid_obj = attached_obj.getUserData("","grid_obj");
    //                         if (grid_obj.indexOf("counterparty_credit_enhancements_") != -1) {
    //                             var selectedId = attached_obj.getSelectedRowId();
    //                             counterparty_credit_enhancement_id = attached_obj.cells(selectedId, 0).getValue();
    //                             param = 'credit.enhancement.php?counterparty_id=' + tab_id + '&counterparty_credit_enhancement_id=' + counterparty_credit_enhancement_id + '&mode=u&is_pop=true';
    //                         }
    //                     }
    //                 });
    //             });
    //             var is_win = dhxWins.isWindow('w3');
    //             if (is_win == true) {
    //                 w3.close();
    //             }
    //             w3 = dhxWins.createWindow("w3", 320, 0, 750, 430);
    //             w3.centerOnScreen();
    //             w3.setText("Counterparty Credit Info - Enhancement");
    //             w3.setModal(true);
    //             w3.maximize();
    //             w3.attachURL(param, false, true);

    //             w3.attachEvent("onClose", function(win) {
    //                 return true;
    //             });

    //             break;
    //         case 'pdf':
    //             $.each(detail_tabs, function(index,value) {
    //                 layout_obj = tab_obj.cells(value).getAttachedObject();
    //                 layout_obj.forEachItem(function(cell){
    //                     attached_obj = cell.getAttachedObject();
    //                     if (attached_obj instanceof dhtmlXGridObject) {
    //                         var grid_obj = attached_obj.getUserData("","grid_obj");
    //                         if (grid_obj.indexOf("counterparty_credit_enhancements_") != -1) {
    //                             attached_obj.toPDF(php_script_loc + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
    //                         }
    //                     }
    //                 });
    //             });
    //             break;
    //         case 'excel':
    //             $.each(detail_tabs, function(index,value) {
    //                 layout_obj = tab_obj.cells(value).getAttachedObject();
    //                 layout_obj.forEachItem(function(cell){
    //                     attached_obj = cell.getAttachedObject();
    //                     if (attached_obj instanceof dhtmlXGridObject) {
    //                         var grid_obj = attached_obj.getUserData("","grid_obj");
    //                         if (grid_obj.indexOf("counterparty_credit_enhancements_") != -1) {
    //                             attached_obj.toExcel(php_script_loc + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
    //                         }
    //                     }
    //                 });
    //             });
    //             break;
    //          case 'pivot':
    //             var pivot_exec_spa = "EXEC spa_counterparty_credit_enhancements @flag='g', @Counterparty_id=" + tab_id;

    //             $.each(detail_tabs, function(index,value) {
    //                 layout_obj = tab_obj.cells(value).getAttachedObject();
    //                 layout_obj.forEachItem(function(cell){
    //                     attached_obj = cell.getAttachedObject();
    //                     if (attached_obj instanceof dhtmlXGridObject) {
    //                         var grid_obj = attached_obj.getUserData("","grid_obj");
    //                         if (grid_obj.indexOf("counterparty_credit_enhancements_") != -1) {
    //                             var grid_obj = attached_obj;
    //                             open_grid_pivot(grid_obj, 'counterparty_credit_enhancements', 1, pivot_exec_spa, 'Counterparty Credit Enhancements');
    //                         }
    //                     }
    //                 });
    //             });
    //             break;    
    //         default:
    //             dhtmlx.alert({title: "Information!", type: "alert-error", text: "Not implemented"});
    //         break;
    //     }
    // }

    /**
     * [Toolbar function for Netting grid]
     */
    cci_namespace.function_netting_grid_toolbar = function(id){
        var active_tab_id = cci_namespace.tabbar.getActiveTab();
        var tab_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        
        var win = cci_namespace.tabbar.cells(active_tab_id);
        var tab_obj = win.getAttachedObject();
        var detail_tabs = tab_obj.getAllTabs();

        switch(id) {
            case 'add':
                $.each(detail_tabs, function(index,value) {
                    layout_obj = tab_obj.cells(value).getAttachedObject();
                    layout_obj.forEachItem(function(cell){
                        attached_obj = cell.getAttachedObject();
                        if (attached_obj instanceof dhtmlXGridObject) {
                            var grid_obj = attached_obj.getUserData("","grid_obj");
                            if (grid_obj.indexOf("netting_group_") != -1) {
                                var newId = (new Date()).valueOf();
                                attached_obj.addRow(newId,"");
                                //attached_obj.selectRowById(newId);
                            }
                        }
                    })
                });
            break;
            case 'delete':
                $.each(detail_tabs, function(index,value) {
                    layout_obj = tab_obj.cells(value).getAttachedObject();
                    layout_obj.forEachItem(function(cell){
                        attached_obj = cell.getAttachedObject();
                        if (attached_obj instanceof dhtmlXGridObject) {
                            var grid_obj = attached_obj.getUserData("","grid_obj");
                            if (grid_obj.indexOf("netting_group_") != -1) {
                                var selected_row = attached_obj.getSelectedRowId();
                                var selected_row_arr = selected_row.split(',');

                                var del_ids = attached_obj.getSelectedRowId();
                                var previously_xml = attached_obj.getUserData("", "deleted_xml");             
                                var grid_xml = "";              
                                if (previously_xml != null) {                   
                                    grid_xml += previously_xml              
                                }             
                                var del_array = new Array();             
                                del_array = (del_ids.indexOf(",") != -1) ? del_ids.split(",") : del_ids.split();             
                                $.each(del_array, function(index, value) {
                                    if((attached_obj.cells(value,0).getValue() != "") || (attached_obj.getUserData(value,"row_status") != "")){                         
                                        grid_xml += "<GridRow ";                        
                                        for(var cellIndex = 0; cellIndex < attached_obj.getColumnsNum(); cellIndex++){                            
                                            grid_xml += " " + attached_obj.getColumnId(cellIndex) + '="' + attached_obj.cells(value,cellIndex).getValue() + '"';                        
                                        }                   
                                        grid_xml += " ></GridRow> ";                 
                                    }             
                                });
                                attached_obj.setUserData("", "deleted_xml", grid_xml);
                                attached_obj.deleteSelectedRows();
                            }
                        }
                    })
                });
            break;
            case 'pdf':
                $.each(detail_tabs, function(index,value) {
                    layout_obj = tab_obj.cells(value).getAttachedObject();
                    layout_obj.forEachItem(function(cell){
                        attached_obj = cell.getAttachedObject();
                        if (attached_obj instanceof dhtmlXGridObject) {
                            var grid_obj = attached_obj.getUserData("","grid_obj");
                            if (grid_obj.indexOf("netting_group_") != -1) {
                                attached_obj.toPDF(php_script_loc + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                            }
                        }
                    });
                });
            break;
            case 'excel':
                $.each(detail_tabs, function(index,value) {
                    layout_obj = tab_obj.cells(value).getAttachedObject();
                    layout_obj.forEachItem(function(cell){
                        attached_obj = cell.getAttachedObject();
                        if (attached_obj instanceof dhtmlXGridObject) {
                            var grid_obj = attached_obj.getUserData("","grid_obj");
                            if (grid_obj.indexOf("netting_group_") != -1) {
                                attached_obj.toExcel(php_script_loc + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                            }
                        }
                    });
                });
            break;
            default:
                 dhtmlx.alert({title: "Information!", type: "alert-error", text: "Not implemented"});
            break;
        }
    }

    /*
     * [Toolbar function for enchancement grid]
     */
    // cci_namespace.function_enhancement_grid_toolbar = function(id){
    //     var counterparty_credit_enhancement_id = null;
    //     var active_tab_id = cci_namespace.tabbar.getActiveTab();
    //     var tab_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;

    //     var win = cci_namespace.tabbar.cells(active_tab_id);
    //     var tab_obj = win.getAttachedObject();
    //     var detail_tabs = tab_obj.getAllTabs();

    //     switch(id) {
    //         case 'add':
    //             data = {"action": "spa_counterparty_credit_info","flag": "g","Counterparty_id": tab_id};
    //             adiha_post_data('', data, '', '', 'load_enhancement_form_window');
    //             break;
    //         case 'delete':
    //             $.each(detail_tabs, function(index,value) {
    //                 layout_obj = tab_obj.cells(value).getAttachedObject();
    //                 layout_obj.forEachItem(function(cell){
    //                     attached_obj = cell.getAttachedObject();
    //                     if (attached_obj instanceof dhtmlXGridObject) {
    //                         var grid_obj = attached_obj.getUserData("","grid_obj");
    //                         if (grid_obj.indexOf("counterparty_credit_enhancements_") != -1) {
    //                             //var selectedId = attached_obj.getSelectedRowId();

    //                             var selectedId = attached_obj.getSelectedRowId();
    //                             var selected_row_array_delete_enhancement = selectedId.split(',');
    //                             var selected_item_id_delete_enhancement = '';
    //                             for(var i = 0; i < selected_row_array_delete_enhancement.length; i++) {
    //                                 if (i == 0) {
    //                                     selected_item_id_delete_enhancement =  attached_obj.cells(selected_row_array_delete_enhancement[i], 0).getValue();
    //                                 } else {
    //                                     selected_item_id_delete_enhancement = selected_item_id_delete_enhancement + ',' + attached_obj.cells(selected_row_array_delete_enhancement[i], 0).getValue();
    //                                 }
    //                             }

    //                             data = {"action": "spa_counterparty_credit_enhancements",
    //                                 "flag": "d",
    //                                 "counterparty_credit_enhancement_id": selected_item_id_delete_enhancement
    //                             };
    //                             adiha_post_data('confirm', data, '', '', 'callback_enhancement_grid_refresh');
    //                         }
    //                     }
    //                 });
    //             });
    //             break;
    //         case 'edit':
    //             $.each(detail_tabs, function(index,value) {
    //                 layout_obj = tab_obj.cells(value).getAttachedObject();
    //                 layout_obj.forEachItem(function(cell){
    //                     attached_obj = cell.getAttachedObject();
    //                     if (attached_obj instanceof dhtmlXGridObject) {
    //                         var grid_obj = attached_obj.getUserData("","grid_obj");
    //                         if (grid_obj.indexOf("counterparty_credit_enhancements_") != -1) {
    //                             var selectedId = attached_obj.getSelectedRowId();
    //                             counterparty_credit_enhancement_id = attached_obj.cells(selectedId, 0).getValue();
    //                             param = 'credit.enhancement.php?counterparty_id=' + tab_id + '&counterparty_credit_enhancement_id=' + counterparty_credit_enhancement_id + '&mode=u&is_pop=true';
    //                         }
    //                     }
    //                 });
    //             });
    //             var is_win = dhxWins.isWindow('w3');
    //             if (is_win == true) {
    //                 w3.close();
    //             }
    //             var height = cci_namespace.layout.cells('a').getHeight();
    //             var width = cci_namespace.layout.cells('b').getWidth() + cci_namespace.layout.cells('a').getWidth();
    //             w3 = dhxWins.createWindow({
    //                 id: 'w3'
    //                 ,width: width
    //                 ,height: height
    //                 ,resize: true
    //             });
    //             w3.centerOnScreen();
    //             w3.setText("Counterparty Credit Info - Enhancement");
    //             w3.setModal(true);
    //             w3.attachURL(param, false, true);

    //             w3.attachEvent("onClose", function(win) {
    //                 return true;
    //             });

    //             break;
    //         case 'pdf':
    //             $.each(detail_tabs, function(index,value) {
    //                 layout_obj = tab_obj.cells(value).getAttachedObject();
    //                 layout_obj.forEachItem(function(cell){
    //                     attached_obj = cell.getAttachedObject();
    //                     if (attached_obj instanceof dhtmlXGridObject) {
    //                         var grid_obj = attached_obj.getUserData("","grid_obj");
    //                         if (grid_obj.indexOf("counterparty_credit_enhancements_") != -1) {
    //                             attached_obj.toPDF(php_script_loc + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
    //                         }
    //                     }
    //                 });
    //             });
    //             break;
    //         case 'excel':
    //             $.each(detail_tabs, function(index,value) {
    //                 layout_obj = tab_obj.cells(value).getAttachedObject();
    //                 layout_obj.forEachItem(function(cell){
    //                     attached_obj = cell.getAttachedObject();
    //                     if (attached_obj instanceof dhtmlXGridObject) {
    //                         var grid_obj = attached_obj.getUserData("","grid_obj");
    //                         if (grid_obj.indexOf("counterparty_credit_enhancements_") != -1) {
    //                             attached_obj.toExcel(php_script_loc + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
    //                         }
    //                     }
    //                 });
    //             });
    //             break;
    //         case 'pivot':
    //             var pivot_exec_spa = "EXEC spa_counterparty_credit_enhancements @flag='g', @Counterparty_id=" + tab_id + ",@deal_id=" + source_deal_header_id;

    //             $.each(detail_tabs, function(index,value) {
    //                 layout_obj = tab_obj.cells(value).getAttachedObject();
    //                 layout_obj.forEachItem(function(cell){
    //                     attached_obj = cell.getAttachedObject();
    //                     if (attached_obj instanceof dhtmlXGridObject) {
    //                         var grid_obj = attached_obj.getUserData("","grid_obj");
    //                         if (grid_obj.indexOf("counterparty_credit_enhancements_") != -1) {
    //                             var grid_obj = attached_obj;
    //                             open_grid_pivot(grid_obj, 'counterparty_credit_enhancements', 1, pivot_exec_spa, 'Counterparty Credit Enhancements');
    //                         }
    //                     }
    //                 });
    //             });
    //             break;
    //         default:
    //             dhtmlx.alert({title: "Information!", type: "alert-error", text: "Not implemented"});
    //             break;
    //     }
    // }

    /*
     * [Toolbar function for migration grid]
     */
    cci_namespace.function_migration_grid_toolbar = function(id){
        var counterparty_credit_migration_id = null;
        var active_tab_id = cci_namespace.tabbar.getActiveTab();
        var tab_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;

        var win = cci_namespace.tabbar.cells(active_tab_id);
        var tab_obj = win.getAttachedObject();
        var detail_tabs = tab_obj.getAllTabs();

        switch(id) {
            case 'add':
                data = {"action": "spa_counterparty_credit_info","flag": "g","Counterparty_id": tab_id};
                adiha_post_data('', data, '', '', 'load_migration_form_window');
                break;
            case 'delete':
                $.each(detail_tabs, function(index,value) {
                    layout_obj = tab_obj.cells(value).getAttachedObject();
                    layout_obj.forEachItem(function(cell){
                        attached_obj = cell.getAttachedObject();
                        if (attached_obj instanceof dhtmlXGridObject) {
                            var grid_obj = attached_obj.getUserData("","grid_obj");
                            if (grid_obj.indexOf("counterparty_credit_migration_") != -1) {
                                var selectedId = attached_obj.getSelectedRowId();
                                var split_selectedId = selectedId.split(",");
                                var counterparty_credit_migration_id = [];
                                for(var i = 0; i < split_selectedId.length; i++) {
                                    var value_id = attached_obj.cells(split_selectedId[i], 0).getValue();
                                    counterparty_credit_migration_id.push(value_id);
                                }

                                data = {"action": "spa_counterparty_credit_migration",
                                    "flag": "d",
                                    "counterparty_credit_migration_id": counterparty_credit_migration_id.join(",")
                                };
                                adiha_post_data('confirm', data, '', '', 'cci_namespace.callback_migration_grid_refresh');
                            }
                        }
                    });
                });
                break;
            case 'edit':
                $.each(detail_tabs, function(index,value) {
                    layout_obj = tab_obj.cells(value).getAttachedObject();
                    layout_obj.forEachItem(function(cell){
                        attached_obj = cell.getAttachedObject();
                        if (attached_obj instanceof dhtmlXGridObject) {
                            var grid_obj = attached_obj.getUserData("","grid_obj");
                            if (grid_obj.indexOf("counterparty_credit_migration_") != -1) {
                                var selectedId = attached_obj.getSelectedRowId();
                                counterparty_credit_migration_id = attached_obj.cells(selectedId, 0).getValue();
                                internal_counterparty_id = attached_obj.cells(selectedId, 3).getValue();
                                param = 'credit.migration.php?counterparty_id=' + tab_id + '&counterparty_credit_migration_id=' + counterparty_credit_migration_id + '&mode=u&is_pop=true&internal_counterparty_id=' + internal_counterparty_id;
                            }
                        }
                    });
                });
                var is_win = dhxWins.isWindow('w3');
                if (is_win == true) {
                    w3.close();
                }
                w3 = dhxWins.createWindow("w3", 320, 0, 750, 430);
                w3.setText("Counterparty Credit Info - Migration");
                w3.setModal(true);
                w3.attachURL(param, false, true);

                w3.attachEvent("onClose", function(win) {
                    return true;
                });

                break;
            case 'pdf':
                $.each(detail_tabs, function(index,value) {
                    layout_obj = tab_obj.cells(value).getAttachedObject();
                    layout_obj.forEachItem(function(cell){
                        attached_obj = cell.getAttachedObject();
                        if (attached_obj instanceof dhtmlXGridObject) {
                            var grid_obj = attached_obj.getUserData("","grid_obj");
                            if (grid_obj.indexOf("counterparty_credit_migration_") != -1) {
                                attached_obj.toPDF(php_script_loc + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                            }
                        }
                    });
                });
                break;
            case 'excel':
                $.each(detail_tabs, function(index,value) {
                    layout_obj = tab_obj.cells(value).getAttachedObject();
                    layout_obj.forEachItem(function(cell){
                        attached_obj = cell.getAttachedObject();
                        if (attached_obj instanceof dhtmlXGridObject) {
                            var grid_obj = attached_obj.getUserData("","grid_obj");
                            if (grid_obj.indexOf("counterparty_credit_migration_") != -1) {
                                attached_obj.toExcel(php_script_loc + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                            }
                        }
                    });
                });
                break;
            default:
                dhtmlx.alert({title: "Information!", type: "alert-error", text: "Not implemented"});
                break;
        }
    }

    cci_namespace.form_load_complete = function(tab_id) {
        var active_tab_id = cci_namespace.tabbar.getActiveTab();
        var tab_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        var win = cci_namespace.tabbar.cells(active_tab_id);
        var tab_obj = win.getAttachedObject();
        var detail_tabs = tab_obj.getAllTabs();
        $.each(detail_tabs, function(index,value) {
            layout_obj = tab_obj.cells(value).getAttachedObject();
            layout_obj.forEachItem(function(cell){
                attached_obj = cell.getAttachedObject();
                if (attached_obj instanceof dhtmlXGridObject) {
                    var grid_obj = attached_obj.getUserData("","grid_obj");
                    if (grid_obj.indexOf("counterparty_credit_enhancements_") != -1) {
                        credit_enhancements_obj = attached_obj;
                        if(hide_tab == 1) {
                            tab_obj.cells(value).setActive();
                            attached_obj.attachEvent("onRowDblClicked", function(){
                                cci_namespace.function_enhancement_grid_toolbar('edit');
                            });
                        }
                        var param = {
                            "action": "spa_counterparty_credit_enhancements",
                            "Counterparty_id":tab_id,
                            "flag": "g",
                            "grid_type": "g",
                            "deal_id":source_deal_header_id
                        };
                        param = $.param(param);
                        var param_url = js_data_collector_url + "&" + param;
                        attached_obj.clearAll();
                        attached_obj.load(param_url,function () {
                            if (hide_tab == 1) {
                                if (credit_enhancements_obj.doesRowExist(0)) {
                                    credit_enhancements_obj.selectRow(0);
                                    cci_namespace.function_enhancement_grid_toolbar('edit');
                                } else {
                                    cci_namespace.function_enhancement_grid_toolbar('add');
                                }
                            }
                        });
                        attached_obj.setUserData("", "grid_obj", "counterparty_credit_enhancements_" + tab_id);
                    } else {
                        if(hide_tab == 1) {
                            tab_obj.tabs(value).close();
                        }
                    }
                } else {
                    if(hide_tab == 1) {
                        tab_obj.tabs(value).hide();
                    }
                }
            });
        });
    }

    /**
     *
     */
    cci_namespace.save_counterparty_credit_info = function(tab_id) {
        cci_namespace.layout.cells('a').expand();
        var active_tab_id = cci_namespace.tabbar.getActiveTab();
        var counterparty_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        var pre_info_id = '';

        var win = cci_namespace.tabbar.cells(tab_id);
        var tab_obj = win.getAttachedObject();
        var detail_tabs = tab_obj.getAllTabs();
        var tabsCount = tab_obj.getNumberOfTabs();
        var form_status = true;
        var first_err_tab;

        var form_xml = '<Root function_id="<?php echo $function_id;?>"><FormXML ';
        var grid_xml = "<GridGroup>";
        var validation_status = 1;
        $.each(detail_tabs, function(index, value) {
            layout_obj = tab_obj.cells(value).getAttachedObject();
            layout_obj.forEachItem(function(cell) {
                attached_obj = cell.getAttachedObject();
                if (attached_obj instanceof dhtmlXForm) {
                    var status = validate_form(attached_obj);
                    form_status = form_status && status;
                    if (tabsCount == 1 && !status) {
                        first_err_tab = "";
                    } else if ((!first_err_tab) && !status) {
                        first_err_tab = tab_obj.cells(value);
                    }
                    if(!status) {
                        validation_status = 0;
                    }
                    data = attached_obj.getFormData();
                    for (var a in data) {
                        field_label = a;

                        if (attached_obj.getItemType(a) == "calendar") {
                            field_value = attached_obj.getItemValue(a, true);
                            if(a === 'Last_review_date')
                                Last_review_date_value = field_value;
                            if(a === 'Next_review_date')
                                Next_review_date_value = field_value;
                        } else {
                            field_value = data[a];
                        }
                        if (field_label != 'counterparty_credit_info_id') {
                            form_xml += " " + field_label + "=\"" + field_value + "\"";
                        } else {
                            pre_info_id = attached_obj.getItemValue("counterparty_credit_info_id");
                        }
                    }
                } else if (attached_obj instanceof dhtmlXGridObject) {
                    var grid_obj = attached_obj.getUserData("","grid_obj");
                    if (grid_obj.indexOf("netting_group_") != -1 || grid_obj.indexOf("counterparty_credit_block_trading_") != -1) {
                        attached_obj.clearSelection();
                        grid_label = attached_obj.getUserData("","grid_label");
                                                                        
                        var ids = attached_obj.getChangedRows(true);
                        grid_id = attached_obj.getUserData("","grid_id");
                         
                        deleted_xml = attached_obj.getUserData("","deleted_xml");
                         
                        if(deleted_xml != null && deleted_xml != "") {
                            grid_xml += "<GridDelete grid_id=\""+ grid_id + "\" grid_label=\"" + grid_label + "\">";
                            grid_xml += deleted_xml;
                            grid_xml += "</GridDelete>";
                            if (delete_grid_name == "") {
                                delete_grid_name = grid_label
                            } else {
                                delete_grid_name += "," + grid_label
                            }
                        };
                        if(ids != "") {
                            attached_obj.setSerializationLevel(false,false,true,true,true,true);
                            var grid_status = true;//location_data.validate_form_grid(attached_obj,grid_label);
                             
                            grid_xml += "<Grid grid_id=\""+ grid_id + "\">";
                            var changed_ids = new Array();
                            changed_ids = ids.split(",");
                            if(grid_status){
                                $.each(changed_ids, function(index, value) {
                                    grid_xml += "<GridRow ";
                                    for(var cellIndex = 0; cellIndex < attached_obj.getColumnsNum(); cellIndex++){
                                        grid_xml += " " + attached_obj.getColumnId(cellIndex) + '="' + attached_obj.cells(value,cellIndex).getValue() + '"';
                                    }
                                    grid_xml += " ></GridRow> ";
                                });
                                grid_xml += "</Grid>";
                            } else {
                                validation_status = 0;
                            }
                        }
                    }
                }
            });
        });
        grid_xml += "</GridGroup>";
        form_xml += "></FormXML>" + grid_xml + "</Root>";
        if (!form_status) {
            generate_error_message(first_err_tab);
            return;
        }

        var Last_review_date_value_parse = Date.parse(Last_review_date_value);
        var Next_review_date_value_parse = Date.parse(Next_review_date_value);

        if (Last_review_date_value_parse >= Next_review_date_value_parse) {
            validation_status = false;
            show_messagebox('<strong>New Review Date</strong> should be greater than <strong>Last Review Date</strong>.');
        }

        if(validation_status) {
            //data = {"action": "spa_process_form_data", "xml": form_xml};
            //added by me
            //console.log(win.getAttachedToolbar());
            win.getAttachedToolbar().disableItem('save');
            //////////////
            data = {"action": "spa_counterparty_credit_info", "xml": form_xml, "flag": "u", "counterparty_credit_info_id": pre_info_id};
            if(delete_grid_name != ""){
                del_msg =  "Some data has been deleted from " + delete_grid_name + " grid. Are you sure you want to save?";
                result = adiha_post_data("confirm", data, "", "", "cci_namespace.post_callback","",del_msg);
            } else {
                result = adiha_post_data("alert", data, "", "", "cci_namespace.post_callback");
            }
            delete_grid_name = "";
            deleted_xml = attached_obj.setUserData("","deleted_xml", "");
        }
    }
    cci_namespace.post_callback = function(result) {
        var tab_id = cci_namespace.tabbar.getActiveTab();
        var win = cci_namespace.tabbar.cells(tab_id);
        //added by me
        //console.log(win.getAttachedToolbar());
        /* setTimeout(function(){
         win.getAttachedToolbar().enableItem('save');
         },1000);*/
        //if (has_rights_counterparty_credit_info_iu) {
        win.getAttachedToolbar().enableItem('save');
        //};
        ////////////
        if (result[0].errorcode == 'Success') {
            cci_namespace.refresh_grid();
        }
    }
    /**
     * [Refreshes the limit grid after saving next row]
     */
    cci_namespace.callback_limit_grid_refresh = function() {

        var is_win = dhxWins.isWindow('w3');

        var active_tab_id = cci_namespace.tabbar.getActiveTab();
        var tab_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        var win = cci_namespace.tabbar.cells(active_tab_id);
        var tab_obj = win.getAttachedObject();
        var detail_tabs = tab_obj.getAllTabs();

        $.each(detail_tabs, function(index,value) {
            layout_obj = tab_obj.cells(value).getAttachedObject();
            layout_obj.forEachItem(function(cell){
                attached_obj = cell.getAttachedObject();
                var menu_obj = cell.getAttachedMenu();
                if (menu_obj != undefined) {
                    menu_obj.setItemDisabled("delete");
                }
                if (attached_obj instanceof dhtmlXGridObject) {

                    var grid_obj = attached_obj.getUserData("","grid_obj");

                    if (grid_obj.indexOf("counterparty_credit_limits_") != -1) {

                        var param = {
                            "action": "spa_counterparty_credit_limits",
                            "Counterparty_id":tab_id,
                            "flag": "g",
                            "grid_type": "tg",
                            "grouping_column": "Internal_Counterparty,Limit_ID",
                            "grouping_type": "5"
                        };

                        param = $.param(param);
                        var param_url = js_data_collector_url + "&" + param;
                        attached_obj.clearAll();
                        attached_obj.loadXML(param_url);
                        attached_obj.setUserData("", "grid_obj", "counterparty_credit_limits_" + tab_id);

                    }
                }
            });
        });

        if (is_win == true) {
            setTimeout(function(){
                w3.close();
            }, 1000);
        }
    }
    /**
     * [Refreshes the enhancement grid after saving next row]
     */
    // callback_enhancement_grid_refresh = function(){
    //     var is_win = dhxWins.isWindow('w3');
    //     var active_tab_id = cci_namespace.tabbar.getActiveTab();
    //     var tab_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
    //     var win = cci_namespace.tabbar.cells(active_tab_id);
    //     var tab_obj = win.getAttachedObject();
    //     var detail_tabs = tab_obj.getAllTabs();
    //     $.each(detail_tabs, function(index,value) {
    //         layout_obj = tab_obj.cells(value).getAttachedObject();
    //         layout_obj.forEachItem(function(cell){
    //             attached_obj = cell.getAttachedObject();
    //             var menu_obj = cell.getAttachedMenu();
    //             if (menu_obj != undefined) {
    //                 menu_obj.setItemDisabled("delete");
    //             }
    //             if (attached_obj instanceof dhtmlXGridObject) {
    //                 var grid_obj = attached_obj.getUserData("","grid_obj");
    //                 if (grid_obj.indexOf("counterparty_credit_enhancements_") != -1) {
    //                     var param = {
    //                         "action": "spa_counterparty_credit_enhancements",
    //                         "Counterparty_id":tab_id,
    //                         "flag": "g",
    //                         "grid_type": "g",
    //                         "deal_id":source_deal_header_id
    //                     };
    //                     param = $.param(param);
    //                     var param_url = js_data_collector_url + "&" + param;
    //                     attached_obj.clearAll();
    //                     attached_obj.loadXML(param_url);
    //                     attached_obj.setUserData("", "grid_obj", "counterparty_credit_enhancements_" + tab_id);
    //                 }
    //             }
    //         });
    //     });
    //     if (is_win == true) {
    //         setTimeout(function(){
    //             w3.close();
    //         }, 1000);
    //     }
    // }
    /**
     * [Refreshes the enhancement grid after saving next row]
     */
    cci_namespace.callback_migration_grid_refresh = function(result){



        var is_win = dhxWins.isWindow('w3');

        var active_tab_id = cci_namespace.tabbar.getActiveTab();
        var tab_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        var win = cci_namespace.tabbar.cells(active_tab_id);
        var tab_obj = win.getAttachedObject();
        var detail_tabs = tab_obj.getAllTabs();

        $.each(detail_tabs, function(index,value) {
            layout_obj = tab_obj.cells(value).getAttachedObject();
            layout_obj.forEachItem(function(cell){
                attached_obj = cell.getAttachedObject();
                var menu_obj = cell.getAttachedMenu();
                if (menu_obj != undefined) {
                    menu_obj.setItemDisabled("delete");
                }
                if (attached_obj instanceof dhtmlXGridObject) {
                    var grid_obj = attached_obj.getUserData("","grid_obj");

                    if (grid_obj.indexOf("counterparty_credit_migration_") != -1) {
                        var param = {
                            "action": "spa_counterparty_credit_migration",
                            "Counterparty_id":tab_id,
                            "flag": "g",
                            "grid_type": "g"
                        };
                        param = $.param(param);
                        var param_url = js_data_collector_url + "&" + param;
                        attached_obj.clearAll();
                        attached_obj.loadXML(param_url);
                        attached_obj.setUserData("", "grid_obj", "counterparty_credit_migration_" + tab_id);
                    }
                }
            });
        });

        if (result[0].recommendation != '') {
            if (is_win == true) {
                setTimeout(function(){
                    w3.close();
                }, 1000);
            }
        }
    }
    /**
     * [Gets counterparty_info_id and opens enhancement window]
     */
    // function load_enhancement_form_window(result){
    //     info_id = result[0]['counterparty_credit_info_id'];

    //     var active_tab_id = cci_namespace.tabbar.getActiveTab();
    //     var tab_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;

    //     var param = 'credit.enhancement.php?counterparty_id=' + tab_id + '&counterparty_credit_info_id=' + info_id + '&mode=i&is_pop=true&deal_id='+source_deal_header_id;
    //     var is_win = dhxWins.isWindow('w3');
    //     if (is_win == true) {
    //         w3.close();
    //     }
    //     var height = cci_namespace.layout.cells('a').getHeight();
    //     var width = cci_namespace.layout.cells('b').getWidth() + cci_namespace.layout.cells('a').getWidth();
    //     w3 = dhxWins.createWindow({
    //         id: 'w3'
    //         ,width: width
    //         ,height: height
    //         ,resize: true
    //     });
    //     w3.centerOnScreen();
    //     w3.setText("Counterparty Credit Info - Enhancement");
    //     w3.setModal(true);
    //     w3.attachURL(param, false, true);

    //     w3.attachEvent("onClose", function(win) {
    //         return true;
    //     });
    // }
    /**
     * [Gets counterparty_info_id and opens migration window]
     */
    function load_migration_form_window(result){
        info_id = result[0]['counterparty_credit_info_id'];

        var active_tab_id = cci_namespace.tabbar.getActiveTab();
        var tab_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;

        var param = 'credit.migration.php?counterparty_id=' + tab_id + '&counterparty_credit_info_id=' + info_id + '&mode=i&is_pop=true';
        var is_win = dhxWins.isWindow('w3');
        if (is_win == true) {
            w3.close();
        }
        w3 = dhxWins.createWindow("w3", 320, 0, 750, 430);
        w3.setText("Counterparty Credit Info - Migration");
        w3.setModal(true);
        w3.attachURL(param, false, true);

        w3.attachEvent("onClose", function(win) {
            return true;
        });
    }
    /**
     * [Function to override left grid double click standard function]
     */
    cci_namespace.override_standard_callback = function(){
        var active_tab_id = cci_namespace.tabbar.getActiveTab();
        var tab_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        var win = cci_namespace.tabbar.cells(active_tab_id);
        var tab_obj = win.getAttachedObject();
        var detail_tabs = tab_obj.getAllTabs();
        $.each(detail_tabs, function(index,value) {
            layout_obj = tab_obj.cells(value).getAttachedObject();
            layout_obj.forEachItem(function(cell){
                attached_obj = cell.getAttachedObject();
                if (attached_obj instanceof dhtmlXGridObject) {
                    var grid_obj = attached_obj.getUserData("","grid_obj");
                    if (grid_obj.indexOf("counterparty_credit_limits_") != -1) {
                        //attached_obj.enableMultiselect(false);
                        attached_obj.attachEvent("onRowDblClicked", function(){
                            cci_namespace.function_limit_grid_toolbar('edit');
                        });
                    }
                    // if (grid_obj.indexOf("counterparty_credit_enhancements_") != -1) {
                    //     //attached_obj.enableMultiselect(false);
                    //     attached_obj.attachEvent("onRowDblClicked", function(){
                    //         cci_namespace.function_enhancement_grid_toolbar('edit');
                    //     });
                    //     var param = {
                    //         "action": "spa_counterparty_credit_enhancements",
                    //         "Counterparty_id":tab_id,
                    //         "flag": "g",
                    //         "grid_type": "g",
                    //         "deal_id":source_deal_header_id
                    //     };
                    //     param = $.param(param);
                    //     var param_url = js_data_collector_url + "&" + param;
                    //     attached_obj.clearAll();
                    //     attached_obj.loadXML(param_url);
                    //     attached_obj.setUserData("", "grid_obj", "counterparty_credit_enhancements_" + tab_id);
                    // }
                    if (grid_obj.indexOf("counterparty_credit_migration_") != -1) {
                        //attached_obj.enableMultiselect(false);
                        attached_obj.attachEvent("onRowDblClicked", function(){
                            cci_namespace.function_migration_grid_toolbar('edit');
                        });
                    }
                }
            });
            //added for doc icon
            var toolbar = cci_namespace.tabbar.cells(active_tab_id).getAttachedToolbar();
            var tab_text = tab_obj.cells(value).getText();
            if (tab_text.indexOf('Credit') == 0) {
                add_manage_document_button(tab_id, toolbar, true);
                toolbar.addButton('enhancement', 3, 'Enhancement', 'doc.gif', 'doc_dis.gif');
            }
            //end of doc icon
            //added credit enhancement button
        });
    }
    /**
     *
     */
    cci_namespace.tab_toolbar_click = function(id) {
        var tab_id = cci_namespace.tabbar.getActiveTab();
        switch(id) {
            case "close":
                delete cci_namespace.pages[tab_id];
                cci_namespace.tabbar.tabs(tab_id).close(true);
                break;
            case "save":
                //var tab_id = cci_namespace.tabbar.getActiveTab();
                cci_namespace.save_counterparty_credit_info(tab_id);
                break;
            case 'documents':
                //var tab_id = cci_namespace.tabbar.getActiveTab();
                open_document(tab_id);
                break;
            case 'enhancement':
                open_enhancement(tab_id,'');
            break;
            default:
                dhtmlx.alert({title:"Error",type:"alert-error",text:"Not implemented"});
                break;
        }
    }
    /*
     * Open document
     * @param {type} tab_id
     * @returns {undefined}
     */
    function open_document(object_id) {
        var object_id = (object_id.indexOf("tab_") != -1) ? object_id.replace("tab_", "") : object_id;
        var doc_url = '../../_setup/manage_documents/manage.documents.php?notes_category=' + category_id + '&notes_object_id=' + object_id + '&is_pop=true';

        var is_win = dhxWins.isWindow('w11');
        if (is_win == true) {
            w11.close();
        }
        w11 = dhxWins.createWindow("w11", 520, 100, 530, 550);
        w11.setText("Documents");
        w11.setModal(true);
        w11.maximize();
        w11.attachURL(doc_url, false, true);

        w11.attachEvent("onClose", function(win) {
            update_document_counter(object_id, toolbar_object);
            return true;
        });
    }

    /*
    * Open Enhancement
    */
    function open_enhancement(object_id,counterparty_id) {
        if (counterparty_id && counterparty_id != '') {
            var object_id = counterparty_id;
            var doc_url = 'counterparty.credit.info.enhancement.php?object_id=' + object_id + '&is_pop=true&source_deal_header_id='+ source_deal_header_id;
        }
        else {
            object_id = (object_id.indexOf("tab_") != -1) ? object_id.replace("tab_", "") : object_id;
            var doc_url = 'counterparty.credit.info.enhancement.php?object_id=' + object_id + '&is_pop=true';
        }
        var is_win = dhxWins.isWindow('w12');
        if (is_win == true) {
            w11.close();
        }
        w11 = dhxWins.createWindow("w12", 520, 100, 530, 550);
        w11.setText("Enhancement");
        w11.setModal(true);
        w11.maximize();
        w11.attachURL(doc_url, false, true);

        w11.attachEvent("onClose", function(win) {
            update_document_counter(object_id, toolbar_object);
            return true;
        });   
    }

    load_workflow_status = function() {
        cci_namespace.menu.addNewSibling('process', 'reports', 'Reports', false, 'report.gif', 'report_dis.gif');
        cci_namespace.menu.addNewChild('reports', '0', 'workflow_status', 'Workflow Status', true, 'report.gif', 'report_dis.gif');
        cci_namespace.menu.addNewChild('reports', '1', 'report_manager', 'Report Manager', true, 'report.gif', 'report_dis.gif');

        cci_namespace.grid.attachEvent("onRowSelect",function(rowId,cellIndex){
            cci_namespace.menu.setItemEnabled('workflow_status');
        });

        cci_namespace.grid.attachEvent("onSelectStateChanged",function(rowId,cellIndex){
            if (rowId != null) {			
                if (rowId.indexOf(",") == -1) cci_namespace.menu.setItemEnabled('report_manager');
            }
        });

        load_report_menu('cci_namespace.menu', 'report_manager', 2, -104701)

        cci_namespace.menu.attachEvent("onClick", function(id, zoneId, cas){
            if(id == 'workflow_status') {
                var selected_ids = cci_namespace.grid.getColumnValues(0);
                var workflow_report = new dhtmlXWindows();
                workflow_report_win = workflow_report.createWindow('w1', 0, 0, 900, 700);
                workflow_report_win.setText("Workflow Status");
                workflow_report_win.centerOnScreen();
                workflow_report_win.setModal(true);
                workflow_report_win.maximize();

                var filter_string = '';
                var process_table_xml = 'counterparty_credit_info_id:' + selected_ids;
                var page_url = js_php_path + '../adiha.html.forms/_compliance_management/setup_rule_workflow/workflow.report.php?filter_id=' + selected_ids + '&source_column=counterparty_id&module_id=20604&process_table_xml=' + process_table_xml + '&filter_string=' + filter_string;
                workflow_report_win.attachURL(page_url, false, null);
            } else if (id.indexOf("report_manager_") != -1 && id != 'report_manager')  { 
                var str_len = id.length;
                var report_param_id = id.substring(15, str_len);
                var selected_cpty_ids = cci_namespace.grid.getColumnValues(0);
                var param_filter_xml = '<Root><FormXML param_name="source_id" param_value="' + selected_cpty_ids + '"></FormXML></Root>';
                
                show_view_report(report_param_id, param_filter_xml, -104701) 
            }
        });
    } 

    function fx_click_parent_object_id_link(category_id, parent_object_id) {
        var function_id = '';
        if(category_id == 33) {
            function_id = 10131010;
            parent.parent.parent.TRMHyperlink(function_id,parent_object_id, 'n');
        } else if(category_id == 37) {
            function_id = 10105800;
            parent.parent.parent.TRMHyperlink(function_id,parent_object_id);
        } else if(category_id == 45) {
            var sp_string = "EXEC spa_scheduling_workbench @flag='s'";
            post_data = { sp_string: sp_string };
            $.ajax({
                url: ajax_url,
                data: post_data,
            }).done(function(data) {
                var json_data = data['json'][0];
                var process_id_generated = json_data.process_id;
                sp_string = "EXEC spa_scheduling_workbench @flag='s',@buy_sell_flag=NULL,@process_id='" + process_id_generated + "'";
                post_data = { sp_string: sp_string };
                $.ajax({
                    url: ajax_url,
                    data: post_data,
                }).done(function(data) {
                    //var json_data1 = data['json'][0];
                    sp_string = "EXEC spa_scheduling_workbench @flag = 'v', @process_id = '" + process_id_generated + "', @buy_deals = '', @sell_deals = '', @convert_uom = 1082, @convert_frequency=703, @mode = 'u', @get_group_id = 1, @bookout_match = 'm', @match_group_id = " + parent_object_id;
                    post_data = { sp_string: sp_string };
                    $.ajax({
                        url: ajax_url,
                        data: post_data,
                    }).done(function(data) {
                        //var json_data2 = data['json'][0];
                        sp_string = "EXEC spa_scheduling_workbench  @flag='q',@process_id='" + process_id_generated + "',@buy_deals='',@sell_deals='',@convert_uom='1082',@convert_frequency='703',,@mode='u',@location_id=NULL,@bookout_match='m',@contract_id=NULL,@commodity_name=NULL,@location_contract_commodity=NULL,@match_group_id=" + parent_object_id;
                        post_data = { sp_string: sp_string };
                        $.ajax({
                            url: ajax_url,
                            data: post_data,
                        }).done(function(data) {
                            //var json_data3 = data['json'][0];
                            var url_param = '?receipt_detail_ids=&delivery_detail_ids=&process_id=' + process_id_generated + '&convert_uom=1082&convert_frequency=703&mode=u&contract_id=NULL&bookout_match=m&location_id=NULL&shipment_name=&match_id=&match_group_id=' + parent_object_id;

                            function_id = 10163710;
                            parent.parent.parent.TRMHyperlink(function_id,url_param);
                            return;
                            var url_match = app_form_path + '_scheduling_delivery/scheduling_workbench/match.php' + url_param;
                            match_win = dhx_wins.createWindow("w2", 0, 0, 650, 500);
                            match_win.setText('Match');
                            match_win.maximize();
                            match_win.attachURL(url_match, false, true);
                            return;
                        });

                    });

                });
            });

        }
        else return;

    }

</script>