<?php
/**
* View prices screen
* @copyright Pioneer Solutions
*/
?>
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
        
        $rights_view_price = 10151000;
        $rights_view_price_edit = 10151010;

        list (
            $has_rights_view_price,
            $has_rights_view_price_edit
        )  = build_security_rights(
            $rights_view_price,
            $rights_view_price_edit
        );

        $namespace = 'view_price';
        $json = '[
                    {
                        id:             "a",
                        text:           "Price Curves",
                        header:         true,
                        collapse:       false,
                        width:          350,
                        height:         125,
                        undock:         true
                    },
                    {
                        id:             "b",
                        text:           "Filters",
                        header:         true,
                        collapse:       true,
                        height:         80
                    },
                    {
                        id:             "c",
                        text:           "Filter Criteria",
                        header:         true,
                        collapse:       false,
                        height:         250
                    },
                    {
                        id:             "d",
                        text:           "<div>Curve Values <a class=\"undock_cell_a undock_custom\" style=\"float:right;cursor:pointer\" title=\"Undock\"  onClick=\" undock_curve_values();\"><!--&#8599--></a></div>",
                        header:         true,
                        collapse:       false
                    }
                ]';
        $view_price_layout_obj = new AdihaLayout();
        echo $view_price_layout_obj->init_layout('view_price_layout', '', '4C', $json, $namespace);
        echo $view_price_layout_obj->attach_event('', 'onDock', 'view_price.on_dock_event');
        echo $view_price_layout_obj->attach_event('', 'onUnDock', 'view_price.on_undock_event');
        
        $price_curve_menu = 'price_curve_menu';
        $price_curve_menu_json = '[{id: "refresh_panel", text: "Refresh", img: "refresh.gif", img_disabled: "refresh_dis.gif", enabled: true},
                                    {id:"t2", text:"Export", img:"export.gif", imgdis:"export_dis.gif", items:[
                                        {id:"excel", text:"Excel", img:"excel.gif"},
                                        {id:"pdf", text:"PDF", img:"pdf.gif"}
                                    ]},
                                    {id:"expand_collapse", text:"Expand/Collapse", img:"exp_col.gif", imgdis:"exp_col_dis.gif"}
                                ]';

        echo $view_price_layout_obj->attach_menu_layout_cell($price_curve_menu, 'a', $price_curve_menu_json, $namespace.'.price_curve_menu_click');

        //attach grid
        $curve_grid_name = 'price_curve_grid';
        echo $view_price_layout_obj->attach_status_bar("a", true);
        echo $view_price_layout_obj->attach_grid_cell($curve_grid_name, 'a');
        $price_curve_grid_obj = new GridTable('view_price_curve');
        echo $price_curve_grid_obj->init_grid_table($curve_grid_name, $namespace);
        echo $price_curve_grid_obj->enable_multi_select();
        echo $price_curve_grid_obj->set_search_filter(true); 
        echo $price_curve_grid_obj->return_init();
        echo $price_curve_grid_obj->load_grid_data("EXEC spa_source_price_curve_def_maintain @flag='t', @is_active='y'");
        
        echo $price_curve_grid_obj->enable_paging(100, 'pagingArea_a', 'true');
        
        $form_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10151000', @template_name='view price', @parse_xml=''";
        $form_arr = readXMLURL2($form_sql);
        $tab_id = $form_arr[0]['tab_id'];
        $form_json = $form_arr[0]['form_json'];
        echo $view_price_layout_obj->attach_form('view_price_filter_form', 'c');
        $view_price_filter_form_obj = new AdihaForm();
        echo $view_price_filter_form_obj->init_by_attach('view_price_filter_form', $namespace);
        echo $view_price_filter_form_obj->load_form($form_json);

        $curve_values_menu = 'curve_values_menu';
        $curve_values_menu_json = '[
                                    {id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif"},
                                    {id:"save", text:"Save", img:"save.gif", imgdis:"save_dis.gif", enabled: "'. $has_rights_view_price_edit .'"},
                                    {id:"edit", text:"Edit", img:"edit.gif", imgdis:"edit_dis.gif", items:[
                                        {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", enabled: "'. $has_rights_view_price_edit .'"},
                                        {id:"delete", text:"Delete", img:"delete.gif", imgdis:"delete_dis.gif", enabled: "'. $has_rights_view_price_edit .'"}
                                    ]},
                                    {id:"process", text:"Process", img:"process.gif", imgdis:"process_dis.gif", items:[
                                        {id:"derive", text:"Derive", img:"derive.gif", imgdis:"derive_dis.gif", enabled: "' . $has_rights_view_price_edit . '"},
                                        {id:"copy", text:"Copy", img:"copy.gif", imgdis:"copy_dis.gif", enabled: "' . $has_rights_view_price_edit . '"}
                                    ]},
                                    {id:"export", text:"Export", img:"export.gif", imgdis:"export_dis.gif", items:[
                                        {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", enabled: 1},
                                        {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", enabled: 1},
                                        {id:"batch", text:"Batch", img:"batch.gif", imgdis:"batch_dis.gif", enabled: "' . $has_rights_view_price_edit . '"}
                                    ]},
                                    {id:"select_unselect", text:"Select/Unselect", img:"select_unselect.gif", imgdis:"select_unselect_dis.gif", enabled: 1},
                                    {id:"pivot", text:"Pivot", img:"pivot.gif", imgdis:"pivot_dis.gif", enabled: 1},
                                    {id:"pivot_view", text:"Pivot View", img:"pivot_view.png", imgdis:"pivot_view_dis.png", enabled: "0"},
                                ]';
        echo $view_price_layout_obj->attach_menu_layout_cell($curve_values_menu, 'd', $curve_values_menu_json, $namespace.'.curve_value_menu_click');
        //echo $view_price_layout_obj->attach_tab_cell('price_curves', 'd', '');
        
        //echo "view_price.view_price_layout.cells('d').showHeader();";

        echo $view_price_layout_obj->close_layout();
    ?>
</body>
    
<script>
    var has_rights_view_price_edit = <?php echo (($has_rights_view_price_edit) ? $has_rights_view_price_edit : '0'); ?>;
    var expand_state = 0;
    var forward_header_level_cnt, forward_fxd_header;
    var settlement_header_level_cnt, settlement_fxd_header;
    var forward_delete_xml,settlement_delete_xml;
    var forward_settlement_status;
    var ask_bid_level;
    var client_date_format = '<?php echo $date_format; ?>';
    var privilege_status = true;
    var selected_row;
    var granularity_id;
    var as_of_date_from;
    var as_of_date_to;
    var curve_source_value;
    var tenor_from;
    var tenor_to;
    var set_headers;
    var attach_header;
    var col_widths;
    var col_ids;
    var col_type;
    var global_curve_name;
    var global_source_curve_def_id;
    var col_validation;
    var curve_value_defination_id;
    var col_sort;

    var curves_grid_data = {}; 

    $(function() {
        filter_obj = view_price.view_price_layout.cells('b').attachForm();
        var layout_cell_obj = view_price.view_price_layout.cells('c');
        load_form_filter(filter_obj, layout_cell_obj, '10151000', 2,'','');
        filter_obj.attachEvent("onBeforeChange",function(name,oldValue,newValue){
			view_price.price_curve_grid.expandAll();
            // if (name=='apply_filters' && oldValue != newValue) {
            //     view_price.view_price_layout.cells('d').progressOn();
            // }
            return true;
        });
        price_curves_tabbar = view_price.view_price_layout.cells('d').attachTabbar({
                                        align: "left",
                                        mode: "bottom"
                                    });
        price_curves_tabbar.addTab("forward", get_locale_value("Forward"));
        price_curves_tabbar.addTab("settlement", get_locale_value("Settlement"));
        price_curves_tabbar.addTab("general", get_locale_value("General"));
        price_curves_tabbar.tabs("forward").hide();
        price_curves_tabbar.tabs("settlement").hide();
        price_curves_tabbar.tabs("general").hide();
        view_price.view_price_layout.cells('c').showHeader();
        
        var curve_source_obj = view_price.view_price_filter_form.getCombo('curve_source');
        curve_source_obj.setComboValue(4500);
        
        view_price.price_curve_grid.attachEvent("onRowDblClicked", function(rId,cInd){
            view_price.expand_price_curve(rId,cInd);
        });

        view_price.price_curve_grid.attachEvent("onSelectStateChanged", function(id) {
            id.split(',')
                .forEach(function(e) {
                    if(view_price.price_curve_grid.getLevel(e) == 1) {
                        curves_grid_data[e] = view_price.price_curve_grid.cells(e, view_price.price_curve_grid.getColIndexById('source_curve_def_id')).getValue()
                    }
                })
        });

        price_curves_tabbar.attachEvent("onTabClick", function(id, lastId){
            if (id == 'forward') {
                forward_grid.clearSelection();
                view_price.curve_values_menu.setItemDisabled('delete');
            } else if (id == 'settlement') {
                settlement_grid.clearSelection();
                view_price.curve_values_menu.setItemDisabled('delete');
            }
        });
        
        var today = new Date();
        var as_of_date = new Date(today.getFullYear(), today.getMonth() , today.getDate());
        view_price.view_price_filter_form.setItemValue('as_of_date_to', as_of_date);
        view_price.price_curve_grid.attachEvent("onRowSelect", function(id,ind){
            selected_row = view_price.price_curve_grid.getSelectedRowId();
            var check_multi_select = selected_row.indexOf(",");
            if (check_multi_select !=-1) {
                view_price.curve_values_menu.setItemEnabled('pivot_view');
                return;
            }
            var col_index = view_price.price_curve_grid.getColIndexById('s_granularity');
            var active_tab = price_curves_tabbar.getActiveTab();
            if(active_tab == 'general') {
                view_price.curve_values_menu.setItemDisabled('save');
            }
            granularity_id = view_price.price_curve_grid.cells(selected_row, col_index).getValue();
            if(granularity_id == '5Min' || granularity_id == '10Min' || granularity_id == '15Min'  || granularity_id == '30Min'|| granularity_id == 'Hourly') {
                view_price.curve_values_menu.setItemEnabled('pivot_view');
            } else {
                view_price.curve_values_menu.setItemDisabled('pivot_view');
            }
        });
        
        // Set 'As of Date From' to a month ahead.
        var as_of_date_from = new Date(today.getFullYear(), today.getMonth() - 1 , today.getDate());
        view_price.view_price_filter_form.setItemValue('as_of_date_from', as_of_date_from);
    });
    

    // view_price.callback_view_price = function () {
    //     setTimeout (function(){
    //         view_price.view_price_layout.cells('d').progressOff();
    //     },1000);
    // }

    /*
     * price_curve_menu_click [Menu click function of Price Curve Grid]
     */
    view_price.price_curve_menu_click = function(id, zoneId, cas) {
        switch(id) {
            case 'excel':
                view_price.price_curve_grid.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                break;
            case 'pdf':
                view_price.price_curve_grid.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                break;    
            case 'expand_collapse':
                if (expand_state == 0) {
                    view_price.price_curve_grid.expandAll();
                    expand_state = 1;
                } else {
                    view_price.price_curve_grid.collapseAll();
                    expand_state = 0;
                }
                break;
            case 'refresh_panel': var sql_param = {
                                    "sql":"Exec spa_source_price_curve_def_maintain @flag = t, @is_active = y",
                                     "grid_type": 'tg',
                                     "key_prefix":"",
                                     "key_suffix":"",
                                     "grouping_column":"s_curve_type,curve_name"
                                };
                    sql_param = $.param(sql_param);
                    var sql_url = js_data_collector_url + "&" + sql_param; 
           
                    view_price.price_curve_grid.clearAll(); //removes all rows 
                    view_price.price_curve_grid.load(sql_url, function () {
                         view_price.price_curve_grid.filterByAll();
                    });                 
                    break;
   
        }
    }
    
    /*
     * price_curve_menu_click [Menu click function of Curve Value Grid]
     */
    view_price.curve_value_menu_click = function(id, zoneId, cas) {
        switch(id) {
            case 'refresh':
                view_price.curve_values_menu.setItemEnabled('save');

                var selected_row_ids = view_price.price_curve_grid.getSelectedRowId();

                if (selected_row_ids != null) {
                    selected_row_ids = selected_row_ids.split(',')
                    var index_effective_date = view_price.price_curve_grid.getColIndexById('effective_date')
                    var effective_row_count = selected_row_ids
                        .map(function(row_id){
                            return view_price.price_curve_grid.cells(row_id, index_effective_date).getValue()
                        })
                        .filter(function(effective_date) {
                            return effective_date == 'y'
                    }).length

                var selected_row_count = view_price.price_curve_grid.getSelectedRowId().split(',').length

                if (effective_row_count > 1 && (effective_row_count < selected_row_count)) {
                    show_messagebox("Price for effective date applied and not applied curves can not be shown at once.");
                        return;
                    }
                }

                curve_values_refresh();
                break;
            case 'save':
              var active_tab = price_curves_tabbar.getActiveTab();
                if(active_tab == "general") {
                    save_pivot_curve();
                } else {
                    if (forward_del_flag == 1 || settlement_del_flag == 1) {
                        var gname;
                        if (forward_del_flag == 1) { gname = 'Forward'; } else { gname = 'Settlement'; }
                        del_msg =  "Some data has been deleted from " + gname + " grid. Are you sure you want to save?";
                        dhtmlx.message({
                            type: "confirm",
                            title: "Confirmation",
                            ok: "Confirm",
                            text: del_msg,
                            callback: function(result) {
                                if (result)
                                    curve_values_save();                
                            }
                        });
                    } else {
                        curve_values_save();
                    }

                }
                break;
            case 'add':
                var active_tab = price_curves_tabbar.getActiveTab();
                var new_id = (new Date()).valueOf();
                if (active_tab == 'forward') {
                    forward_grid.addRow(new_id, '');
                    forward_grid.forEachRow(function(row){
                        forward_grid.forEachCell(row,function(cellObj,ind){
                            forward_grid.validateCell(row,ind)
                        });
                    });
                } else if (active_tab == 'settlement') {
                    settlement_grid.addRow(new_id, '');
                    settlement_grid.forEachRow(function(row){
                        settlement_grid.forEachCell(row,function(cellObj,ind){
                            settlement_grid.validateCell(row,ind)
                        });
                    }); 
                } else if (active_tab == 'general') {
                    grid_obj.addRow(new_id, '');
                    var name_html = $.parseHTML( global_curve_name );
                    var name_text = $(name_html).text();
                    grid_obj.cells(new_id,2).setValue(name_text);
                    grid_obj.forEachRow(function(row){
                        grid_obj.forEachCell(row,function(cellObj,ind){
                            grid_obj.validateCell(row,ind)
                        });
                    });
                }
                break;
            case 'delete':
                var active_tab = price_curves_tabbar.getActiveTab();
                 if(active_tab == "general") {
                    pivot_view_curve_value_delete();
                } else {
                    curve_value_delete(active_tab);
                }
                break;
            case 'excel':
                var active_tab = price_curves_tabbar.getActiveTab();
                if (active_tab == 'forward') {
                    forward_grid.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                } else if (active_tab == 'settlement') {
                    settlement_grid.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                } else if(active_tab == 'general') {
                    grid_obj.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                }
                break;
            case 'pdf':
                var active_tab = price_curves_tabbar.getActiveTab();
                if (active_tab == 'forward') {
                    forward_grid.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                } else if (active_tab == 'settlement') {
                    settlement_grid.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                } else if(active_tab == 'general') {
                    grid_obj.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                
                }
                break;  
            case 'select_unselect':
                var active_tab = price_curves_tabbar.getActiveTab();
                if (active_tab == 'forward') {
                    var selected_id = forward_grid.getSelectedRowId();
                
                    if (selected_id == null) {
                        // forward_grid.selectAll();
                        var arr = forward_grid.getAllRowIds().split(',');
                        for (i=0; i < arr.length; i++) {
                            forward_grid.selectRowById(arr[i], true, false);
                        }

                        if (has_rights_view_price_edit) {
                            view_price.curve_values_menu.setItemEnabled('delete');
                        }
                    } else {
                        forward_grid.clearSelection();
                        view_price.curve_values_menu.setItemDisabled("delete");    
                    }
                } else if (active_tab == 'settlement') {
                    var selected_id = settlement_grid.getSelectedRowId();
                
                    if (selected_id == null) {
                        // settlement_grid.selectAll();
                        var arr = settlement_grid.getAllRowIds().split(',');
                        for (i=0; i < arr.length; i++) {
                            settlement_grid.selectRowById(arr[i], true, false);
                        }

                        if (has_rights_view_price_edit) {
                            view_price.curve_values_menu.setItemEnabled('delete');
                        }
                    } else {
                        settlement_grid.clearSelection();
                        view_price.curve_values_menu.setItemDisabled("delete");    
                    }
                 } else if (active_tab == 'general') {
                    var selected_id = grid_obj.getSelectedRowId();
                    if (selected_id == null) {
                        // grid_obj.selectAll();
                        var arr = grid_obj.getAllRowIds().split(',');
                        for (i=0; i < arr.length; i++) {
                            grid_obj.selectRowById(arr[i], true, false);
                        }

                        if (has_rights_view_price_edit) {
                            view_price.curve_values_menu.setItemEnabled('delete');
                        }
                    } else {
                        grid_obj.clearSelection();
                        view_price.curve_values_menu.setItemDisabled("delete");    
                    }
                }
                break;
            case 'derive':
                derive_curve_values();
                break;
            case 'copy':
                copy_price();
                break;
            case 'batch':
                curve_value_batch();
                break;
            case 'pivot_view':
                view_price.curve_values_menu.setItemDisabled('pivot_view');
                curve_pivot_view();
                break;
            case 'pivot':
                var source_price_curve = (view_price.price_curve_grid.getSelectedRowId() || '')
					.split(',')
					.map(function(id) {
						return curves_grid_data[id]
					})
                
                if (source_price_curve == '') {
                    show_messagebox('Please select a price curve.');
                    return;
                }
 
                var curve_source_value_obj = view_price.view_price_filter_form.getCombo('curve_source');
                var curve_source_value = curve_source_value_obj.getChecked();
                curve_source_value = curve_source_value.toString();
                var as_of_date_from = view_price.view_price_filter_form.getItemValue('as_of_date_from', true);
                var as_of_date_to = view_price.view_price_filter_form.getItemValue('as_of_date_to', true);
                var tenor_from = view_price.view_price_filter_form.getItemValue('tenor_from', true);
                var tenor_to = view_price.view_price_filter_form.getItemValue('tenor_to', true);
                
                var pivot_exec_spa = "EXEC spa_display_price_curve @flag='p', @source_price_curve='" + source_price_curve 
                                                        + "',@curve_source_value='" + curve_source_value 
                                                        + "',@as_of_date_from='" + as_of_date_from 
                                                        + "',@as_of_date_to='" + as_of_date_to 
                                                        + "',@tenor_from='" + tenor_from 
                                                        + "',@tenor_to='" + tenor_to + "'";
                
                open_grid_pivot('', 'view_price_grid', 1, pivot_exec_spa, 'View Price');
                break;
        }
    }
    
    // Save Logic for pivot view save
    save_pivot_curve = function() {

        detail_tabs = price_curves_tabbar.getActiveTab();
        if(detail_tabs == 'general') {
            deleted_xml = grid_obj.getUserData("","deleted_xml");
                valid_status = 1;
                var grid_status = 1;
                var grid_xml = "<Root><GridGroup>";
                grid_obj.clearSelection();
                var ids = grid_obj.getChangedRows(true);
           
          
                if(deleted_xml != null && deleted_xml != "") {
                    grid_xml += "<GridDelete>";
                    grid_xml += deleted_xml;
                    grid_xml += "</GridDelete>";
                }; 
                if(ids != "") {
                        grid_obj.setSerializationLevel(false,false,true,true,true,true);
                        if(valid_status != 0){
                            grid_status = view_price.validate_form_grid(grid_obj, 'Pivot View');
                        }
                        if(grid_status == false) {
                            return

                        }
                        grid_xml += "<Grid>";
                        var changed_ids = new Array();
                        changed_ids = ids.split(",");
              
                        if(grid_status){
                                $.each(changed_ids, function(index, value) {
                                    grid_obj.setUserData(value,"row_status","new row");
                                    grid_xml += "<GridRow ";
                                    for(var cellIndex = 0; cellIndex < grid_obj.getColumnsNum(); cellIndex++){
                    
                                            if(grid_obj.cells(value, cellIndex).getValue() == 'undefined') { //Cannot use typeof because it returns string
                                                grid_xml += " " + grid_obj.getColumnId(cellIndex) + '= "NULL"';
                                                continue;
                                            }
                                            grid_xml += " " + grid_obj.getColumnId(cellIndex) + '="' + grid_obj.cells(value,cellIndex).getValue() + '"';
                                    }
                                    grid_xml += " ></GridRow> ";
                                });
                                grid_xml += "</Grid>";
                        }
                }
                grid_xml += "</GridGroup></Root>";

        }
       /* var curve_source_obj = view_price.view_price_filter_form.getCombo('curve_source');
        curve_source_value_id = curve_source_obj.getChecked();
        curve_source_value_id = curve_source_value_id.toString();*/
        curve_source_value_id = view_price.view_price_filter_form.getItemValue('curve_source');
        tenor_from = view_price.view_price_filter_form.getItemValue('tenor_from', true);
        tenor_to = view_price.view_price_filter_form.getItemValue('tenor_to', true);
        var data = {
                        "action": "spa_display_price_curve",
                        "flag": "v",
                        "source_curve_def_id" : global_source_curve_def_id,
                        "curve_source_value" : curve_source_value_id,
                        //"curve_source_value" : '4500',
                        "tenor_from" : tenor_from,
                        "tenor_to" : tenor_to,
                        "xml": grid_xml

                        //,"ask_bid": bid_ask
                    };
        if(deleted_xml != null && deleted_xml != "") {
            var grid_name = "Pivot View";
            del_msg =  "Some data has been deleted from " + grid_name + " grid. Are you sure you want to save?";
                        dhtmlx.message({
                            type: "confirm-warning",
                            title: "Warning",
                            ok: "Confirm",
                            text: del_msg,
                            callback: function(result) {
                                if (result)
                                    adiha_post_data('alert', data, '', '', 'pivot_save_callback');          
                            }
                        });
        } else {
            adiha_post_data('alert', data, '', '', 'pivot_save_callback');   
        }
        deleted_xml = grid_obj.setUserData("", "deleted_xml", "");


    }

    function pivot_save_callback (result) {
        if(result[0].errorcode == 'Success') {
            load_grid_data();
        }
    }
    curve_pivot_view = function() {
        var selected_option = view_price.price_curve_grid.getSelectedId();
        var check_multi_select = selected_option.indexOf(",");
        if (check_multi_select !=-1) {
            show_messagebox("Please select only one curve for pivot view");
            return;
        }
        var col_index_source_curve_id = view_price.price_curve_grid.getColIndexById('source_curve_def_id');
        var col_index_curve_name = view_price.price_curve_grid.getColIndexById('s_curve_type');
        global_source_curve_def_id =  view_price.price_curve_grid.cells(selected_option,col_index_source_curve_id).getValue();
        var curve_name = view_price.price_curve_grid.cells(selected_option,col_index_curve_name).getValue();
        var name_html = $.parseHTML( curve_name );
        global_curve_name = $(name_html).text();
        set_headers = null;
        attach_header = null;
        col_widths = null;
        set_headers = ['Price Curve ID','As of Date','Curve Name','Maturity Date','Interval End'];
        attach_header = ['#rspan','#rspan','#rspan','#rspan'];
        col_widths = ['80','80','80','80'];
        col_ids = ['source_curve_def_id','as_of_date','curve_name','maturity_date'];
        col_type = ['ro','dhxCalendarA','ro','dhxCalendarA','ed'];
        col_sort = ['int','date','str','date'];
        col_validation = ['','','',''];
        view_price.curve_values_menu.setItemDisabled('delete');
        as_of_date_from = view_price.view_price_filter_form.getItemValue('as_of_date_from', true);
        as_of_date_to = view_price.view_price_filter_form.getItemValue('as_of_date_to', true);
       /* var curve_source_value_obj = view_price.view_price_filter_form.getCombo('curve_source');
        curve_source_value = curve_source_value_obj.getChecked();
        curve_source_value = curve_source_value.toString();*/
        tenor_from = view_price.view_price_filter_form.getItemValue('tenor_from', true);
        tenor_to = view_price.view_price_filter_form.getItemValue('tenor_to', true);
        if (as_of_date_to != '' && as_of_date_from != '' && as_of_date_from > as_of_date_to) {
            show_messagebox('As of Date To should be greater than As of Date From.');
            view_price.curve_values_menu.setItemEnabled('pivot_view');
            return;
        }
        if (tenor_from == '') {
            view_price.curve_values_menu.setItemEnabled('pivot_view');
            show_messagebox('Please select Tenor From.');
            return;
        }
        
        if (tenor_to == '') {
            tenor_to = tenor_from;
        }
        
        if (tenor_from != '' && tenor_to != '' && tenor_from > tenor_to) {
            view_price.curve_values_menu.setItemEnabled('pivot_view');
            show_messagebox('Tenor To should be greater than Tenor From.');
            return;
        }
        var data = {
                "action": "spa_display_price_curve",
                "flag": "x",
                "source_curve_def_id" : global_source_curve_def_id,
                "tenor_from": tenor_from,
                "tenor_to": tenor_to
            } 
        result = adiha_post_data('return_json', data, '', '', 'curve_callback');
    }

    function curve_callback(result) {        
        var return_data = JSON.parse(result);
        for(i=0; i<return_data.length;i++) {
            attach_header.push(return_data[i].alias_name);
            set_headers.push('#cspan');
            col_widths.push('80');
            col_ids.push("hr"+ return_data[i].clm_name);
            col_type.push('ed');
            col_validation.push('EmptyOrNumeric');
            col_sort.push('int');
        }
        var set_header_list =set_headers.join() ;
        price_curves_tabbar.tabs("general").setActive();
        price_curves_tabbar.tabs("forward").hide();
        price_curves_tabbar.tabs("settlement").hide();
        price_curves_tabbar.tabs("general").show();    
        var attach_header_list = attach_header.join() ;
        var inti_width = col_widths.join() ;
        var set_col_id = col_ids.join()  ;
        var col_type_id = col_type.join();
        var column_validation_rule = col_validation.join();
        var clm_sort = col_sort.join();
        grid_obj = price_curves_tabbar.tabs('general').attachGrid();
        grid_obj.setColumnHidden(0,true);
        grid_obj.setHeader(set_header_list);
        grid_obj.attachHeader(attach_header_list);
        grid_obj.setInitWidths(inti_width);
        grid_obj.setColumnIds(set_col_id);
        grid_obj.setColTypes(col_type_id);
        grid_obj.enableValidation(true); 
        grid_obj.setColValidators(column_validation_rule);
        grid_obj.setColSorting(clm_sort);
        grid_obj.setDateFormat(user_date_format, "%Y-%m-%d");
        grid_obj.init();
        grid_obj.enableHeaderMenu();
        grid_obj.enableMultiselect(true);
        load_grid_data();
    }
     

    function load_grid_data () {
        var rounding_value = view_price.view_price_filter_form.getItemValue('round_value', true);
        curve_source_value_id = view_price.view_price_filter_form.getItemValue('curve_source');
        var data = {
                "action": "spa_display_price_curve",
                "flag": "z",
                "as_of_date_from":as_of_date_from,
                "as_of_date_to":as_of_date_to ,
                "source_price_curve":global_curve_name,
                "source_curve_def_id" : global_source_curve_def_id,
                /*"granularity":granularity_id,*/
                "tenor_from": tenor_from,
                "tenor_to": tenor_to,
                "curve_source_value":curve_source_value_id,
                //"curve_source_value": '4500',
                "round_value": rounding_value
            }               
        data = $.param(data);
        var sql_url = js_data_collector_url + "&" + data;

        grid_obj.clearAll();
        grid_obj.load(sql_url);
        view_price.curve_values_menu.setItemEnabled('pivot_view');
        grid_obj.attachEvent("onRowSelect", function(id,ind){
            view_price.curve_values_menu.setItemEnabled('delete');
        });
        grid_obj.attachEvent("onValidationError",function(id,ind,value){
            var message = "Invalid Data";
            grid_obj.cells(id,ind).setAttribute("validation", message);
            return true;
        });
        grid_obj.attachEvent("onValidationCorrect",function(id,ind,value){
            grid_obj.cells(id,ind).setAttribute("validation", "");
            return true;
        });
        view_price.view_price_layout.cells('c').progressOff();
        view_price.curve_values_menu.setItemEnabled('save');
     }



    // Function to disable save button if privilege is disabled
    view_price.check_privilege_callback = function(result) {
        // Disable Save button if disabled privilege
        privilege_status = result[0]['privilege_status'];
        
        if (privilege_status == 'false') {
            view_price.curve_values_menu.setItemDisabled("save");
            if (result[0]['name'] != '') {
                var message = 'Price Curve: <b>' + result[0]['name'] + '</b> is disabled. Please select the price curves with same privilege type.';
                show_messagebox(message);
            }
        } else {
            view_price.curve_values_menu.setItemEnabled("save");
        }
        enable_menu_items();
    }
    /*
     * curve_values_refresh [Refresh function of Price Curve Grid]
     */
    curve_values_refresh = function() {
        price_curves_tabbar.tabs("general").hide();
        var form_obj = view_price.view_price_layout.cells('c').getAttachedObject();
        var status = validate_form(form_obj);
        if (status == false) { return; }
        
        var source_price_curve_arr = new Array();
        var selected_row = view_price.price_curve_grid.getSelectedId();
        var granularity_check = 0;
        var forward_settlement_status_arr = new Array();
        granularity = '';
        ask_bid_level = 0;
        settle_ask_bid_level = 0;
        
        if (selected_row != null) {
            var selected_row_arr = selected_row.split(',');
            for(i = 0; i < selected_row_arr.length; i++) {
                if ((view_price.price_curve_grid.cells(selected_row_arr[i],view_price.price_curve_grid.getColIndexById('s_granularity')).getValue()) != (view_price.price_curve_grid.cells(selected_row_arr[0],view_price.price_curve_grid.getColIndexById('s_granularity')).getValue())) {
                    granularity_check = 1;
                }
  
                if (jQuery.inArray(view_price.price_curve_grid.cells(selected_row_arr[i],view_price.price_curve_grid.getColIndexById('Forward_settle')).getValue(), forward_settlement_status_arr ) == -1) {
                    forward_settlement_status_arr.push(view_price.price_curve_grid.cells(selected_row_arr[i],view_price.price_curve_grid.getColIndexById('Forward_settle')).getValue());
                }

                var value = view_price.price_curve_grid.cells(selected_row_arr[i], view_price.price_curve_grid.getColIndexById('source_curve_def_id')).getValue();
                
                if (value != '')
                    source_price_curve_arr.push(value);

                granularity = view_price.price_curve_grid.cells(selected_row_arr[0],view_price.price_curve_grid.getColIndexById('s_granularity')).getValue();
                curve_value_defination_id = view_price.price_curve_grid.cells(selected_row_arr[0],view_price.price_curve_grid.getColIndexById('source_curve_def_id')).getValue();
            }
        }
        
        var source_price_curve = source_price_curve_arr.toString();
        if (source_price_curve == '') {
            show_messagebox('Please select a price curve.');
            return;
        }
        
        var col_index = view_price.price_curve_grid.getColIndexById("is_privilege_active");
        var privilege_active = view_price.price_curve_grid.cells(selected_row_arr[0], col_index).getValue();
        // Privilege Check to disable/enable save button
        if (privilege_active == 1) {
            data = {
                        "action": "spa_static_data_privilege",
                        "flag": 'c',
                        "type_id": 4008,
                        "value_id": source_price_curve
                   };
            adiha_post_data("", data, "", "", "view_price.check_privilege_callback");
        }

        //Check whether price curve is forward, settle or both.
        if (forward_settlement_status_arr.length == 1 && forward_settlement_status_arr[0] != '') {
            if (forward_settlement_status_arr[0] == 'Forward') {
                forward_settlement_status = 'f';
            } else {
                forward_settlement_status = 's';
            }
        } else {
            forward_settlement_status = 'b';
        }
        
        if (granularity_check == 1) {
            show_messagebox('Please select the price curves of same granularity.');
            return;
        }
        
        var as_of_date_from = view_price.view_price_filter_form.getItemValue('as_of_date_from', true);
        var as_of_date_to = view_price.view_price_filter_form.getItemValue('as_of_date_to', true);
        
        if ((forward_settlement_status == 'f' || forward_settlement_status == 'b') && (as_of_date_from == '')) {
            show_messagebox('Please select As of Date From.');
            return;
        }
        
        if (as_of_date_to == '') {
            as_of_date_to = as_of_date_from;
        }
        
        if (as_of_date_to != '' && as_of_date_from != '' && as_of_date_from > as_of_date_to) {
            show_messagebox('As of Date To should be greater than As of Date From.');
            return;
        }
        
        var tenor_from = view_price.view_price_filter_form.getItemValue('tenor_from', true);
        var tenor_to = view_price.view_price_filter_form.getItemValue('tenor_to', true);
        
        if (forward_settlement_status == 's' && tenor_from == '') {
            show_messagebox('Please select Tenor From.');
            return;
        }
        
        if (tenor_to == '') {
            tenor_to = tenor_from;
        }
        
        if (tenor_from != '' && tenor_to != '' && tenor_from > tenor_to) {
            show_messagebox('Tenor To should be greater than Tenor From.');
            return;
        }
        
        var curve_source_value_obj = view_price.view_price_filter_form.getCombo('curve_source');
        var curve_source_value = curve_source_value_obj.getSelectedValue();
        curve_source_value = curve_source_value.toString();
        
        if (curve_source_value == '') {
            show_messagebox('Please select a curve source.');
            return;
        }
        var round_value = view_price.view_price_filter_form.getItemValue('round_value');
        var bid_ask = view_price.view_price_filter_form.isItemChecked('bid_ask');
        if (bid_ask == true) { bid_ask = 'y'; } else { bid_ask = 'n'; }
        

        view_price.view_price_layout.cells('d').progressOn();
        
        // Create the Tab as per Forward or Settlement
        if (forward_settlement_status == 'f') {
            price_curves_tabbar.tabs("forward").show();
            price_curves_tabbar.tabs("settlement").hide();
            price_curves_tabbar.tabs("forward").setActive();
        } else if (forward_settlement_status == 's') {
            price_curves_tabbar.tabs("settlement").show();
            price_curves_tabbar.tabs("forward").hide();
            price_curves_tabbar.tabs("settlement").setActive();
        } else if (forward_settlement_status == 'b') {
            price_curves_tabbar.tabs("forward").show();
            price_curves_tabbar.tabs("settlement").show();
            price_curves_tabbar.tabs("forward").setActive();
        }
        
        var data = {
                        "action": "spa_display_price_curve",
                        "flag": "s",
                        "source_price_curve": source_price_curve,
                        "as_of_date_from": as_of_date_from,
                        "as_of_date_to": as_of_date_to,
                        "tenor_from": tenor_from,
                        "tenor_to": tenor_to,
                        "curve_source_value": curve_source_value,
                        "round_value": round_value,
                        "ask_bid": bid_ask,
                        "forward_settle": forward_settlement_status,
                        "granularity":granularity
                    };
        
        adiha_post_data('return_json', data, '', '', 'curve_values_refresh_callback', '', '');
        
    }
    var process_id;
    /*
     * curve_values_refresh_callback [Creating the tab and grid]
     */
    function curve_values_refresh_callback(result) {
        forward_del_flag = 0;
        settlement_del_flag = 0;
        // view_price.view_price_layout.cells('c').progressOn();
        
        view_price.curve_values_menu.setItemDisabled('delete');
        var return_data = JSON.parse(result);
        var data_length = return_data.length;
        process_id = return_data[0].process_id;
        
        //Variable to store header information, used while building XML
        fh1 = [];
        fh2 = [];
        fh3 = [];
        fh4 = [];
        sh1 = [];
        sh2 = [];
        sh3 = [];
        
        var forward_header1 = new Array();
        var forward_header2 = new Array();
        var forward_header3 = new Array();
        var forward_header4 = new Array();
        var forward_col_width = new Array();
        var forward_col_type = new Array();
        var forward_col_visibility = new Array();
        var for_val1, for_val2, for_val3, for_val4;
        var forward_col_align = new Array();
        var forward_col = new Array();
        var forward_cell_col_align = new Array();
        var forward_col_validator = new Array();
        var forward_col_sort = new Array();
        var forward_col_rounding = new Array();
        
        var settlement_header1 = new Array();
        var settlement_header2 = new Array();
        var settlement_header3 = new Array();
        var settlement_col_width = new Array();
        var settlement_col_type = new Array();
        var settlement_col_visibility = new Array();
        var set_val1, set_val2, set_val3;
        var settlement_col_align = new Array();
        var settlement_col = new Array();
        var settlement_cell_col_align = new Array();
        var settlement_col_validator = new Array();
        var settlement_col_sort = new Array();
        var settlement_col_rounding = new Array();
        var round_value = view_price.view_price_filter_form.getItemValue('round_value');
        
        forward_changed_cell_arr = [[]];
        forward_delete_cell_arr = [[]];
        settlement_changed_cell_arr = [[]];
        settlement_delete_cell_arr = [[]];
        
        forward_delete_xml = '';
        settlement_delete_xml = '';
        var for_count = 0;
        //Building the multiline header information
        forward_fxd_header = 0;
        settlement_fxd_header = 0;
        for(i=0; i<data_length; i++) {
            if (return_data[i].forward_settle == 'f') {
                forward_col_sort.push('connector');
                if (return_data[i].name == 'Maturity Date' || return_data[i].name == 'forward_settle' || return_data[i].name == 'is_dst' || return_data[i].name.toString().toLowerCase() == 'hour') {
                    if (return_data[i].name == 'forward_settle') {
                        forward_col_visibility.push('true');
                     } else if (return_data[i].name == 'is_dst') {
                        if(granularity == 'Daily' || granularity == 'Weekly' || granularity == 'Monthly' || granularity == 'Quarterly' || granularity == 'Semi-Annually' || granularity == 'Annually' || granularity == 'TOU Daily') {
                            forward_col_visibility.push('true');
                        } else {
                             forward_col_visibility.push('false');
                        }
                        
                    } else {
                        if (return_data[i].name.toString().toLowerCase() == 'hour' && (granularity == 'Daily' || granularity == 'Weekly' || granularity == 'Monthly' || granularity == 'Quarterly' || granularity == 'Semi-Annually' || granularity == 'Annually' || granularity == 'TOU Daily')) {
                            forward_col_visibility.push('true');
                        } else {
                            forward_col_visibility.push('false');
                        }
                    }

                    if (return_data[i].name == 'Maturity Date') {
                        forward_header1.push(return_data[i].name);
                        forward_col_type.push('dhxCalendarA');
                        forward_col_rounding.push('');
                    } else if (return_data[i].name.toString().toLowerCase() == 'hour') {
                        forward_header1.push('Interval End');
                        forward_col_type.push('ed');
                        forward_col_rounding.push('');
                    } else if (return_data[i].name == 'is_dst') {
                        forward_header1.push('DST');
                        forward_col_type.push('ed');
                        forward_col_rounding.push('');
                    } else {
                        forward_header1.push(return_data[i].name);
                        forward_col_type.push('ed_p');
                        forward_col_rounding.push(round_value);
                    }
                    forward_header2.push('#rspan');
                    forward_header3.push('#rspan');
                    forward_header4.push('#rspan');
                    
                    fh1.push(return_data[i].name);
                    fh2.push(return_data[i].name);
                    fh3.push(return_data[i].name);
                    fh4.push(return_data[i].name);
                    forward_cell_col_align.push('left');
                    if (return_data[i].name.toString().toLowerCase() == 'hour') {
                        forward_col_validator.push('HourMin');
                    } else {
                        forward_col_validator.push('');
                    }
                    forward_col_align.push('"text-align:left;"');
                    forward_fxd_header++;
                } else {
                    var temp_array = return_data[i].name.split('::');
                    forward_header_level_cnt = temp_array.length;
                    for(j=0; j<temp_array.length; j++) {
                        if (j == 0) {
                            if(for_val1 == temp_array[j]) {
                                forward_header1.push('#cspan'); 
                            } else {
                                forward_header1.push(temp_array[j]);       
                            }
                            for_val1 = temp_array[j];
                            fh1.push(temp_array[j]);
                        } else if (j == 1) {
                            if(for_val2 == temp_array[j] && forward_header1[i] == '#cspan') {
                                forward_header2.push('#cspan'); 
                            } else {
                                forward_header2.push(temp_array[j]);    
                            }
                            for_val2 = temp_array[j];
                            fh2.push(temp_array[j]);
                        } else if (j == 2) {
                            if(for_val3 == temp_array[j] && forward_header2[i] == '#cspan') {
                               forward_header3.push('#cspan'); 
                            } else {
                               forward_header3.push(temp_array[j]);          
                            }
                            for_val3 = temp_array[j];
                            fh3.push(temp_array[j]);
                        } else if (j == 3) {
                            if(for_val4 == temp_array[j] && forward_header3[i] == '#cspan') {
                                forward_header4.push('#cspan'); 
                            } else {
                                forward_header4.push(temp_array[j]);    
                            }
                            for_val4 = temp_array[j];
                            fh4.push(temp_array[j]);
                        } 
                    }
                    forward_col_visibility.push('false');
                    forward_col_type.push('ed_p');
                    forward_cell_col_align.push('right');
                    forward_col_validator.push('EmptyOrNumeric');
                    forward_col_align.push('"text-align:right;"');
                    forward_col_rounding.push(round_value);
                }
                forward_col_width.push('100');                
                for_count++;
            } else {
                settlement_col_sort.push('connector');
                if (return_data[i].name == 'as_of_date' || return_data[i].name == 'Maturity Date' || return_data[i].name == 'forward_settle' || return_data[i].name == 'is_dst' || return_data[i].name.toString().toLowerCase() == 'hour') {
                    if (return_data[i].name == 'forward_settle') {
                        settlement_col_visibility.push('true');
                     } else if (return_data[i].name == 'is_dst') {
                        if(granularity == 'Daily' || granularity == 'Weekly' || granularity == 'Monthly' || granularity == 'Quarterly' || granularity == 'Semi-Annually' || granularity == 'Annually' || granularity == 'TOU Daily') {
                            settlement_col_visibility.push('true');
                        } else {
                            settlement_col_visibility.push('false');
                        }
                        
                    } else {
                        if (return_data[i].name.toString().toLowerCase() == 'hour' && (granularity == 'Daily' || granularity == 'Weekly' || granularity == 'Monthly'  || granularity == 'Quarterly' || granularity == 'Semi-Annually' || granularity == 'Annually' || granularity == 'TOU Daily')) {
                            settlement_col_visibility.push('true');
                        } else {
                            settlement_col_visibility.push('false');
                        }
                    } 
                    if (return_data[i].name == 'Maturity Date') {
                        settlement_col_type.push('dhxCalendarA');
                        settlement_col_rounding.push('');
                    } else if (return_data[i].name == 'as_of_date') {
                        settlement_col_type.push('ro');
                        settlement_col_rounding.push('');
                    } else if (return_data[i].name.toString().toLowerCase() == 'hour') {
                        settlement_col_type.push('ed');
                        settlement_col_rounding.push('');
                    } else if(return_data[i].name == 'is_dst'){
                        settlement_col_type.push('ro');
                        settlement_col_rounding.push('');
                    } else {
                        settlement_col_type.push('ed_p');
                        settlement_col_rounding.push(round_value);
                    } 
                    
                    if (return_data[i].name == 'as_of_date') {
                        settlement_header1.push('As of Date');
                    }  else if (return_data[i].name == 'hour') {
                        settlement_header1.push('Interval End');
                    } else if (return_data[i].name == 'is_dst') {
                        settlement_header1.push('DST');
                    } else {
                        settlement_header1.push(return_data[i].name);
                    }
                    settlement_header2.push('#rspan');
                    settlement_header3.push('#rspan');
                    
                    sh1.push(return_data[i].name);
                    sh2.push(return_data[i].name);
                    sh3.push(return_data[i].name);
                    settlement_cell_col_align.push('left');
                    if (return_data[i].name.toString().toLowerCase() == 'hour') {
                        settlement_col_validator.push('HourMin');
                    } else {
                        settlement_col_validator.push('');
                    }
                    settlement_col_align.push('"text-align:left;"');
                    settlement_fxd_header++;
                } else {
                    var temp_array = return_data[i].name.split('::');
                    settlement_header_level_cnt = temp_array.length;
                    for(j=0; j<temp_array.length; j++) {
                        if (j == 0) {
                            if(set_val1 == temp_array[j]) {
                                settlement_header1.push('#cspan'); 
                            } else {
                                settlement_header1.push(temp_array[j]);       
                            }
                            set_val1 = temp_array[j];
                            sh1.push(temp_array[j]);
                        } else if (j == 1) {
                            if(set_val2 == temp_array[j] && settlement_header1[i-for_count] == '#cspan') {
                                settlement_header2.push('#cspan'); 
                            } else {
                                settlement_header2.push(temp_array[j]);    
                            }
                            set_val2 = temp_array[j];
                            sh2.push(temp_array[j]);
                        } else if (j == 2) {
                            if(set_val3 == temp_array[j] && settlement_header2[i-for_count] == '#cspan') {
                                settlement_header3.push('#cspan'); 
                            } else {
                                settlement_header3.push(temp_array[j]);    
                            }
                            set_val3 = temp_array[j];
                            sh3.push(temp_array[j]);
                        }
                    }
                    settlement_col_visibility.push('false');
                    settlement_col_type.push('ed_p');
                    settlement_cell_col_align.push('right');
                    settlement_col_validator.push('EmptyOrNumeric');
                    settlement_col_align.push('"text-align:right;"');
                    settlement_col_rounding.push(round_value);
                }
                settlement_col_width.push('100');                
            }
        }
        //End of building the multiline header information
        
        var bid_ask = view_price.view_price_filter_form.isItemChecked('bid_ask');
        if (bid_ask == true) { bid_ask = 'y'; } else { bid_ask = 'n'; }
        
        if (bid_ask == 'y') {
            ask_bid_level = forward_header_level_cnt;
            settle_ask_bid_level = settlement_header_level_cnt;
        } 
        
        //Creating the Curve Value Forward Grid
        if (forward_settlement_status == 'f' || forward_settlement_status == 'b') {
            var forward_header2_str = jQuery.parseJSON('["' + forward_header2.toString().replace(/,/g, '", "') + '"]');
            var forward_header3_str = jQuery.parseJSON('["' + forward_header3.toString().replace(/,/g, '", "') + '"]');
            var forward_header4_str = jQuery.parseJSON('["' + forward_header4.toString().replace(/,/g, '", "') + '"]');
            var forward_col_type_str = forward_col_type.toString();
            var forward_col_width_str = forward_col_width.toString();
            var forward_col_visibility_str = forward_col_visibility.toString();
            var forward_col_sort_str = forward_col_sort.toString();
            var forward_col_align = jQuery.parseJSON('[' + forward_col_align.toString() + ']');
            var forward_cell_col_align_str = forward_cell_col_align.toString();
            var forward_col_validator_str = forward_col_validator.toString();

            price_curves_tabbar.tabs('forward').attachStatusBar({
                                height: 30,
                                text: '<div id="pagingArea_b"></div>'
                            });

            forward_grid = price_curves_tabbar.tabs('forward').attachGrid();
            forward_grid.setImagePath(js_image_path + "dhxgrid_web/");
            forward_grid.setHeader(get_locale_value(forward_header1.toString(),true), null, forward_col_align);
            
            forward_grid.attachHeader(forward_header2_str,forward_col_align);
            if (forward_header_level_cnt > 2) {
                forward_grid.attachHeader(forward_header3_str,forward_col_align);
            }
            forward_grid.setColAlign(forward_cell_col_align_str);
            if (forward_header_level_cnt > 3) {
                forward_grid.attachHeader(forward_header4_str,forward_col_align);
            }
            forward_grid.setInitWidths(forward_col_width_str);
            forward_grid.setColTypes(forward_col_type_str);
            forward_grid.setColumnsVisibility(forward_col_visibility_str);
            forward_grid.enableValidation(true);
            forward_grid.setColValidators(forward_col_validator_str);
            forward_grid.setColSorting(forward_col_sort_str);

            forward_grid.setPagingWTMode(true,true,true,[10,20,30,40,50,60,70,80,90,100]);
            forward_grid.enablePaging(true, 100, 0, 'pagingArea_b');  
            forward_grid.setPagingSkin('toolbar'); 

            forward_grid.init();
            forward_grid.enableMultiselect(true);
            forward_grid.enableEditEvents(true,false,true);
            forward_grid.setDateFormat(user_date_format);
            if (round_value && round_value != '') {
                forward_grid.enableRounding(forward_col_rounding.toString());
            }
            forward_grid.attachEvent("onRowSelect", function(id,ind){
                if (has_rights_view_price_edit) {
                    view_price.curve_values_menu.setItemEnabled('delete');
                }
            });
            
            forward_grid.attachEvent("onEditCell", function(stage,rId,cInd,nValue,oValue){
                if (stage == 2) {
                    if(fh1[cInd].toString().toLowerCase() == 'hour'  && nValue != '') {
                        var time_arr = nValue.split(':');
                        var hour, minutes;

                        if (time_arr.length == 1) {
                            minutes = '00';
                            hour = '0' + time_arr[0];
                        } else {
                            if (time_arr[1] == '') {
                                time_arr[1] = 0;
                            }
                            if (time_arr[0] == '') {
                                time_arr[0] = 0;
                            }
                            minutes = '0' + time_arr[1];
                            hour = '0' + time_arr[0];
                        }

                        hour = hour[hour.length-2] + hour[hour.length-1];
                        minutes = minutes[minutes.length-2] + minutes[minutes.length-1];
                        var new_hour =  hour + ':' + minutes;
                        forward_grid.cells(rId,cInd).setValue(new_hour);
                    }
                    if (nValue != oValue && cInd >= forward_fxd_header) {
                        forward_changed_cell_arr.push([rId, cInd]);
                    }
                } 
                return true;
            });
            
            forward_grid.attachEvent("onValidationError",function(id,ind,value){
                var message = "Invalid Data";
                forward_grid.cells(id,ind).setAttribute("validation", message);
                return true;
            });
            forward_grid.attachEvent("onValidationCorrect",function(id,ind,value){
                forward_grid.cells(id,ind).setAttribute("validation", "");
                return true;
            });
        } 
        
        //Creating the Curve Value Settlement Grid
        if (forward_settlement_status == 's' || forward_settlement_status == 'b') {
            var settlement_header2_str = jQuery.parseJSON('["' + settlement_header2.toString().replace(/,/g, '", "') + '"]');
            var settlement_header3_str = jQuery.parseJSON('["' + settlement_header3.toString().replace(/,/g, '", "') + '"]');
            var settlement_col_type_str = settlement_col_type.toString();
            var settlement_col_width_str = settlement_col_width.toString();
            var settlement_col_visibility_str = settlement_col_visibility.toString();
            var settlement_col_align = jQuery.parseJSON('[' + settlement_col_align.toString() + ']');
            var settlement_cell_col_align_str = settlement_cell_col_align.toString();
            var settlement_col_validator_str = settlement_col_validator.toString();
            var settlement_col_sort_str = settlement_col_sort.toString();
            
            price_curves_tabbar.tabs('settlement').attachStatusBar({
                                height: 30,
                                text: '<div id="pagingArea_c"></div>'
                            });

            settlement_grid = price_curves_tabbar.tabs('settlement').attachGrid();
            settlement_grid.setImagePath(js_image_path + "dhxgrid_web/");
            settlement_grid.setHeader(get_locale_value(settlement_header1.toString(),true), null, settlement_col_align);
            if (settlement_header_level_cnt > 1) {
                settlement_grid.attachHeader(settlement_header2_str,settlement_col_align);
            }
            if (settlement_header_level_cnt > 2) {
                settlement_grid.attachHeader(settlement_header3_str,settlement_col_align);
            }
            settlement_grid.setColAlign(settlement_cell_col_align_str);
            settlement_grid.setInitWidths(settlement_col_width_str);
            settlement_grid.setColTypes(settlement_col_type_str);
            settlement_grid.setColumnsVisibility(settlement_col_visibility_str);
            //settlement_grid.splitAt(1);
            settlement_grid.enableValidation(true);
            settlement_grid.setColValidators(settlement_col_validator_str);

            settlement_grid.setPagingWTMode(true,true,true,[10,20,30,40,50,60,70,80,90,100]);
            settlement_grid.enablePaging(true, 100, 0, 'pagingArea_c');  
            settlement_grid.setPagingSkin('toolbar'); 
             settlement_grid.setColSorting(settlement_col_sort_str);
            settlement_grid.init();
            settlement_grid.enableMultiselect(true);
            settlement_grid.enableEditEvents(true,false,true);
            settlement_grid.setDateFormat(user_date_format);
            if (round_value && round_value != '') {
                settlement_grid.enableRounding(settlement_col_rounding.toString());
            }
            settlement_grid.attachEvent("onRowSelect", function(id,ind){
                if (has_rights_view_price_edit) {
                    view_price.curve_values_menu.setItemEnabled('delete');
                }
            });
            
            settlement_grid.attachEvent("onEditCell", function(stage,rId,cInd,nValue,oValue){
                if (stage == 2) {
                    if(sh1[cInd].toString().toLowerCase() == 'hour' && nValue != '') {
                        var time_arr = nValue.split(':');
                        var hour, minutes;

                        if (time_arr.length == 1) {
                            minutes = '00';
                            hour = '0' + time_arr[0];
                        } else {
                            if (time_arr[1] == '') {
                                time_arr[1] = 0;
                            }
                            if (time_arr[0] == '') {
                                time_arr[0] = 0;
                            }
                            minutes = '0' + time_arr[1];
                            hour = '0' + time_arr[0];
                        }

                        hour = hour[hour.length-2] + hour[hour.length-1];
                        minutes = minutes[minutes.length-2] + minutes[minutes.length-1];
                        var new_hour =  hour + ':' + minutes;
                        settlement_grid.cells(rId,cInd).setValue(new_hour);
                    }
                    if (nValue != oValue && cInd >= settlement_fxd_header) {
                        settlement_changed_cell_arr.push([rId, cInd]);
                    }
                } 
                return true;
            });
            
            settlement_grid.attachEvent("onValidationError",function(id,ind,value){
                var message = "Invalid Data";
                settlement_grid.cells(id,ind).setAttribute("validation", message);
                return true;
            });
            settlement_grid.attachEvent("onValidationCorrect",function(id,ind,value){
                settlement_grid.cells(id,ind).setAttribute("validation", "");
                return true;
            });
        }
        
        load_forward_grid(process_id);
        enable_menu_items();
    }
    
    /**
     * [forward_smart_refresh Refresh Forward grid using connector]
     * @param  {[type]} result [Return Data]
     */
    forward_smart_refresh = function(result) {
        if (result[0].process_table == '' || result[0].process_table == null) {
            view_price.view_price_layout.cells('d').progressOff();
            return;
        }
        var process_table = result[0].process_table + " WHERE [Maturity Date] IS NOT NULL";
        var header_list = result[0].column_header;
        header_list = header_list.replace(/\[/g, "").replace(/]/g,"");
        var sql_param = {
            "process_table":process_table,
            "text_field": header_list
            //"sorting_fields":"dbo.FNAClientToSqlDate([Maturity Date])::ASC"
        };
        sql_param = $.param(sql_param);
         var sql_url = js_php_path + "grid.connector.php";

        forward_grid.clearAll();
        forward_grid.post(sql_url, sql_param, function() {
            if (forward_settlement_status == 'b') {
                load_settlement_grid(process_id);
            } else {
                view_price.view_price_layout.cells('d').progressOff();
            }
        });

        var is_event_executed = 'n';
        // Added case to prevent attach event execution more than once.
        // On each refresh, new grid is created. Event is attached after grid creation once.
        if (is_event_executed == 'n') {
            forward_grid.attachEvent('onDynXLS', function(start, count) {
                // Ignore First Load.
                if (start > 0) {
                    // Set event executed as y to prevent next execution of attach event
                    is_event_executed = 'y';
                    view_price.view_price_layout.cells('d').progressOn();
                    var process_table = result[0].process_table + " WHERE [Maturity Date] IS NOT NULL";
                    var header_list = result[0].column_header;
                    header_list = header_list.replace(/\[/g, "").replace(/]/g,"");
                    var sql_param = {
                        "process_table":process_table,
                        "text_field": header_list
                        //"sorting_fields":"dbo.FNAClientToSqlDate([Maturity Date])::ASC"
                    };
                    sql_param = $.param(sql_param);
                    var sql_url = js_php_path + "grid.connector.php?posStart=" + start + "&count=" + count + "";
                    forward_grid.post(sql_url, sql_param, function() {
                        view_price.view_price_layout.cells('d').progressOff();
                    });
                    return false;
                }
            });
        }
    }

    /**
     * [settlement_smart_refresh Refresh Settlement grid using connector]
     * @param  {[type]} result [Return Data]
     */
    settlement_smart_refresh = function(result) {
        if (result[0].process_table == '' || result[0].process_table == null) {
            view_price.view_price_layout.cells('d').progressOff();
            return;
        }
        var process_table = result[0].process_table + " WHERE [Maturity Date] IS NOT NULL";
        var header_list = result[0].column_header;
        header_list = header_list.replace(/\[/g, "").replace(/]/g,"");
        var sql_param = {
            "process_table":process_table,
            "text_field": header_list
            //"sorting_fields":"dbo.FNAClientToSqlDate([Maturity Date])::ASC,as_of_date::ASC"
        };
        sql_param = $.param(sql_param);
        var sql_url = js_php_path + "grid.connector.php?"+ sql_param;

        settlement_grid.clearAll();
        settlement_grid.loadXML(sql_url, function() {
            view_price.view_price_layout.cells('d').progressOff();
        });

    }
    /*
     * load_forward_grid [Load the data in the Forward grid]
     */
    load_forward_grid = function(process_id) {
        if (forward_settlement_status == 'f' || forward_settlement_status == 'b') {
            var forward_param = {
                                    "action": "spa_display_price_curve",
                                    "forward_settle": "f",
                                    "process_id": process_id
                                };
            adiha_post_data('return', forward_param, '', '', 'forward_smart_refresh', '', '');
        } else {
            load_settlement_grid(process_id);
        }
    }
    
    /*
     * load_settlement_grid [Load the data in the Settlement grid]
     */
    load_settlement_grid = function(process_id) {
        var settlement_param = {
                                    "action": "spa_display_price_curve",
                                    "forward_settle": "s",
                                    "process_id": process_id
                                };
        adiha_post_data('return', settlement_param, '', '', 'settlement_smart_refresh', '', '');
    }
    
    /*
     * curve_values_save [Build the XML and save the grid data]
     */
    curve_values_save = function() {
        maturity_date_flag = 0;
        hourly_flag = 0;
        
        if (forward_settlement_status == 'b' || forward_settlement_status == 'f') {
            forward_grid.clearSelection();
            
            var f_grid_status = view_price.validate_form_grid(forward_grid, 'Forward');
            if (f_grid_status == false) {
                return;
            }
        }
        
        if (forward_settlement_status == 'b' || forward_settlement_status == 's') {
            settlement_grid.clearSelection();
            
            var s_grid_status = view_price.validate_form_grid(settlement_grid, 'Settlement');
            if (s_grid_status == false) {
                return;
            }
        }
        
        var grid_xml = '<Root><GridGroup>';
        var forward_grid_xml = '';
        var settlement_grid_xml = '';
        
        if (forward_settlement_status == 'f' || forward_settlement_status == 'b') {
            forward_grid_xml = build_forward_xml('save'); 
        }
        
        if (forward_settlement_status == 's' || forward_settlement_status == 'b') {
            settlement_grid_xml = build_settlement_xml('save'); 
        }
        
        if (forward_grid_xml != '' || settlement_grid_xml != '') {
            grid_xml = grid_xml + '<Grid>';
            if (forward_grid_xml != '') {
                 grid_xml = grid_xml + forward_grid_xml;    
            }
            
            if (settlement_grid_xml != '') {
                 grid_xml = grid_xml + settlement_grid_xml;    
            }
            grid_xml = grid_xml + '</Grid>';
        }
        
        if (forward_delete_xml != '' || settlement_delete_xml != '') {
            grid_xml = grid_xml + '<GridDelete>';
            if (forward_delete_xml != '') {
                grid_xml = grid_xml + forward_delete_xml;
            }

            if (settlement_delete_xml != '') {
                grid_xml = grid_xml + settlement_delete_xml;
            }
            grid_xml = grid_xml + '</GridDelete>';
        }
        grid_xml = grid_xml + '</GridGroup></Root>';
        
        if (maturity_date_flag == 1) {
            dhtmlx.alert({
                title:"Alert",
                type:"alert",
                text:"Data Error in <strong>Curve Values</strong> grid. Please check the data in column <strong>Maturity Date</strong> and resave."
            }); 
            return;
        }
        
        if (hourly_flag == 1) {
            dhtmlx.alert({
                title:"Alert",
                type:"alert",
                text:"Data Error in <strong>Curve Values</strong> grid. Please check the data in column <strong>Hour</strong> and resave."
            }); 
            return;
        }
        
        if (grid_xml == '<Root><GridGroup></GridGroup></Root>') {
            show_messagebox('No changes in the grid.');
            return;
        }
        
        var bid_ask = view_price.view_price_filter_form.isItemChecked('bid_ask');
        if (bid_ask == true) { bid_ask = 'y'; } else { bid_ask = 'n'; }
        
        forward_del_flag = 0;
        settlement_del_flag = 0;
        
        var data = {
                        "action": "spa_display_price_curve",
                        "flag": "i",
                        "xml": grid_xml,
                        "ask_bid": bid_ask,
                        "source_curve_def_id":curve_value_defination_id
                    };
        
        adiha_post_data('alert', data, '', '', '', '', '');
        curve_values_refresh();
    }
    
    /*
     * curve_value_delete [Build the XML of deleted data]
     */
    curve_value_delete = function(active_tab) {
        if (active_tab == 'forward') {
            var row_id = forward_grid.getSelectedRowId();
            forward_grid.clearSelection();
            var row_id_array = row_id.split(",");
            forward_delete_cell_arr = [[]];
            for (count = 0; count < row_id_array.length; count++) {
                for (count1 = forward_fxd_header; count1 < forward_grid.getColumnsNum(); count1++) {
                    forward_delete_cell_arr.push([row_id_array[count], count1]);   
                }
            }
            var delete_xml = build_forward_xml('delete'); 
            forward_delete_xml = forward_delete_xml + delete_xml;
            
            for (count = 0; count < row_id_array.length; count++) {
                var new_check = forward_grid.cells(row_id_array[count], 1).getValue();
                if (new_check != '') { forward_del_flag = 1; }
                forward_grid.deleteRow(row_id_array[count]);
            }
        } else if (active_tab == 'settlement') {
            var row_id = settlement_grid.getSelectedRowId();
            settlement_grid.clearSelection();
            var row_id_array = row_id.split(",");
            settlement_delete_cell_arr = [[]];
            for (count = 0; count < row_id_array.length; count++) {
                for (count1 = settlement_fxd_header; count1 < settlement_grid.getColumnsNum(); count1++) {
                    settlement_delete_cell_arr.push([row_id_array[count], count1]);   
                }
            }
            var delete_xml = build_settlement_xml('delete');
            settlement_delete_xml = settlement_delete_xml + delete_xml;
            
            for (count = 0; count < row_id_array.length; count++) {
                var new_check = settlement_grid.cells(row_id_array[count], 1).getValue();
                if (new_check != '') { settlement_del_flag = 1; }
                settlement_grid.deleteRow(row_id_array[count]);
            }
        }
        view_price.curve_values_menu.setItemDisabled('delete');
    }
    
    /*
     * build_forward_xml    [Build the XML of the forward grid]
     * @param   save_delete - 'save' for XML of insert/update, 'delere' for XML of delete
     */
    build_forward_xml = function(save_delete) {
        var grid_xml = '';
        var curve_source_value_obj = view_price.view_price_filter_form.getCombo('curve_source');
        var curve_source_text = curve_source_value_obj.getSelectedText();
        
        if (save_delete == 'save') {
            var row_col_arr = forward_changed_cell_arr;
        } else {
            var row_col_arr = forward_delete_cell_arr;
        }
        
        for (count =1; count < row_col_arr.length; count++) {
            var row_index = row_col_arr[count][0];
            var cellIndex = row_col_arr[count][1];
            grid_xml = grid_xml + '<GridRow';
            
            var maturity_date = forward_grid.cells(row_index,0).getValue();

            if(maturity_date != ''){
                maturity_date = dates.convert_to_sql(maturity_date);
            } 
            
            grid_xml = grid_xml + ' maturity_date="' + maturity_date + '"';
            grid_xml = grid_xml + ' is_dst="' + forward_grid.cells(row_index,3).getValue() + '"';
            
            /* if (forward_fxd_header > 3) {
                if (forward_grid.cells(row_index,2).getValue() == 0) {
                    var minutes = 0;
                } else {
                    var hour_arr = forward_grid.cells(row_index,2).getValue().split(':');
                    if(granularity == 'Hourly') {
                        var minutes = parseInt((hour_arr[0]-1) * 60) + parseInt(hour_arr[1]);
                    } else {
                        var minutes = parseInt(hour_arr[0] * 60) + parseInt(hour_arr[1]);
                    }
                    
                }
                grid_xml = grid_xml + ' hour="' + minutes + '"';
                
                if (forward_grid.cells(row_index,2).getValue()  == '') {
                    if (granularity != 'Daily' && granularity != 'Weekly' && granularity != 'Monthly'  && granularity != 'Quarterly' && granularity != 'Semi-Annually' && granularity != 'Annually') {
                        hourly_flag = 1;
                    } 
                }
            } else {
                grid_xml = grid_xml + ' hour="0"';    
            }
            */
            var minutes = forward_grid.cells(row_index,2).getValue();
            grid_xml = grid_xml + ' hour="' + minutes + '"';
            if (forward_grid.cells(row_index,0).getValue()  == '') {
                maturity_date_flag = 1;
            } 
            
            grid_xml = grid_xml + ' as_of_date="' + dates.convert_to_sql(fh1[cellIndex]) + '"';
            grid_xml = grid_xml + ' source_price_curve="' + fh2[cellIndex] + '"';
            
            if (ask_bid_level == 0) {
                grid_xml = grid_xml + ' ask=""';
                grid_xml = grid_xml + ' bid=""';
                grid_xml = grid_xml + ' mid=""'; 
                if (forward_header_level_cnt < 3) {
                    grid_xml = grid_xml + ' curve_source="' + curve_source_text + '"';
                } else {
                    grid_xml = grid_xml + ' curve_source="' + fh3[cellIndex] + '"';   
                }
                grid_xml = grid_xml + ' curve_value="' + forward_grid.cells(row_index,cellIndex).getValue() + '"';
            } else {
                if (forward_header_level_cnt == 4) { 
                    if (fh4[cellIndex] == 'ask') {
                        grid_xml = grid_xml + ' ask="' + forward_grid.cells(row_index ,cellIndex).getValue() + '"';
                        grid_xml = grid_xml + ' bid="' + forward_grid.cells(row_index ,cellIndex + 1).getValue() + '"';
                        grid_xml = grid_xml + ' mid="' + forward_grid.cells(row_index ,cellIndex + 2).getValue() + '"';     
                    } else if (fh4[cellIndex] == 'bid') {
                        grid_xml = grid_xml + ' ask="' + forward_grid.cells(row_index ,cellIndex - 1).getValue() + '"';
                        grid_xml = grid_xml + ' bid="' + forward_grid.cells(row_index ,cellIndex).getValue() + '"';
                        grid_xml = grid_xml + ' mid="' + forward_grid.cells(row_index ,cellIndex + 1).getValue() + '"';     
                    } else {
                        grid_xml = grid_xml + ' ask="' + forward_grid.cells(row_index ,cellIndex - 2).getValue() + '"';
                        grid_xml = grid_xml + ' bid="' + forward_grid.cells(row_index ,cellIndex - 1).getValue() + '"';
                        grid_xml = grid_xml + ' mid="' + forward_grid.cells(row_index ,cellIndex).getValue() + '"';     
                    }
                    grid_xml = grid_xml + ' curve_source="' + fh3[cellIndex] + '"';   
                    grid_xml = grid_xml + ' curve_value=""';
                } else {
                    if (fh3[cellIndex] == 'ask') {
                        grid_xml = grid_xml + ' ask="' + forward_grid.cells(row_index ,cellIndex).getValue() + '"';
                        grid_xml = grid_xml + ' bid="' + forward_grid.cells(row_index ,cellIndex + 1).getValue() + '"';
                        grid_xml = grid_xml + ' mid="' + forward_grid.cells(row_index ,cellIndex + 2).getValue() + '"';     
                    } else if (fh3[cellIndex] == 'bid') {
                        grid_xml = grid_xml + ' ask="' + forward_grid.cells(row_index ,cellIndex - 1).getValue() + '"';
                        grid_xml = grid_xml + ' bid="' + forward_grid.cells(row_index ,cellIndex).getValue() + '"';
                        grid_xml = grid_xml + ' mid="' + forward_grid.cells(row_index ,cellIndex + 1).getValue() + '"';     
                    } else {
                        grid_xml = grid_xml + ' ask="' + forward_grid.cells(row_index ,cellIndex - 2).getValue() + '"';
                        grid_xml = grid_xml + ' bid="' + forward_grid.cells(row_index ,cellIndex - 1).getValue() + '"';
                        grid_xml = grid_xml + ' mid="' + forward_grid.cells(row_index ,cellIndex).getValue() + '"';     
                    }
                    grid_xml = grid_xml + ' curve_source="' + curve_source_text + '"';
                    grid_xml = grid_xml + ' curve_value=""';
                }
            }
            
            grid_xml = grid_xml + ' forward_settle="f"';
            grid_xml = grid_xml + '></GridRow>';
        }
        return grid_xml;
    }
    
    /*
     * build_settlemente_xml    [Build the XML of the of settlement grid]
     * @param   save_delete - 'save' for XML of insert/update, 'delere' for XML of delete
     */
    build_settlement_xml = function(save_delete) {
        var curve_source_value_obj = view_price.view_price_filter_form.getCombo('curve_source');
        var curve_source_text = curve_source_value_obj.getSelectedText();
        
        if (save_delete == 'save') {
            var row_col_arr = settlement_changed_cell_arr;
        } else {
            var row_col_arr = settlement_delete_cell_arr;
        }
        
        var grid_xml = '';
        for (count =1; count < row_col_arr.length; count++) {
            var row_index = row_col_arr[count][0];
            var cellIndex = row_col_arr[count][1];
            grid_xml = grid_xml + '<GridRow';
            
            var maturity_date = settlement_grid.cells(row_index,1).getValue();  

            if(maturity_date != ''){
                maturity_date = dates.convert_to_sql(maturity_date);
            }  

            grid_xml = grid_xml + ' maturity_date="' + maturity_date + '"';
            grid_xml = grid_xml + ' is_dst="' + settlement_grid.cells(row_index,4).getValue() + '"';
            
            /* if (settlement_fxd_header > 4) {
                if (settlement_grid.cells(row_index,3).getValue() == 0) {
                    var minutes = 0;
                } else {
                    var hour_arr = settlement_grid.cells(row_index,3).getValue().split(':');
                    if(granularity == 'Hourly') { 
                        var minutes = parseInt(hour_arr[0]-1 * 60) + parseInt(hour_arr[1]);
                    } else  {
                        var minutes = parseInt(hour_arr[0] * 60) + parseInt(hour_arr[1]);
                    }
                   
                }
                minutes = settlement_grid.cells(row_index,3).getValue();
                grid_xml = grid_xml + ' hour="' + minutes + '"';
                
                if (settlement_grid.cells(row_index,3).getValue() == '') {
                    if (granularity != 'Daily' && granularity != 'Weekly' && granularity != 'Monthly' && granularity != 'Yearly') {
                        hourly_flag = 1;
                    }
                } 
            } else {
                grid_xml = grid_xml + ' hour="0"';    
            }
            */
            var minutes = settlement_grid.cells(row_index,3).getValue();
            grid_xml = grid_xml + ' hour="' + minutes + '"';
            if (settlement_grid.cells(row_index,1).getValue() == '') {
                maturity_date_flag = 1;
            } 
            
            if (settlement_grid.cells(row_index,0).getValue() != '') {
                grid_xml = grid_xml + ' as_of_date="' + dates.convert_to_sql(settlement_grid.cells(row_index,0).getValue()) + '"';
            } else {
                grid_xml = grid_xml + ' as_of_date="' + settlement_grid.cells(row_index,0).getValue() + '"';
            }
            grid_xml = grid_xml + ' source_price_curve="' + sh1[cellIndex] + '"';
            if (settle_ask_bid_level == 0) {
                if (settlement_header_level_cnt > 1) {
                    grid_xml = grid_xml + ' curve_source="' + sh2[cellIndex] + '"';
                } else {
                    grid_xml = grid_xml + ' curve_source="' + curve_source_text + '"';
                }
                grid_xml = grid_xml + ' curve_value="' + settlement_grid.cells(row_index,cellIndex).getValue() + '"';

                grid_xml = grid_xml + ' ask=""';
                grid_xml = grid_xml + ' bid=""';
                grid_xml = grid_xml + ' mid=""';
            } else {
                if (settlement_header_level_cnt == 3) { 
                    if (sh3[cellIndex] == 'ask') {
                        grid_xml = grid_xml + ' ask="' + settlement_grid.cells(row_index ,cellIndex).getValue() + '"';
                        grid_xml = grid_xml + ' bid="' + settlement_grid.cells(row_index ,cellIndex + 1).getValue() + '"';
                        grid_xml = grid_xml + ' mid="' + settlement_grid.cells(row_index ,cellIndex + 2).getValue() + '"';     
                    } else if (sh3[cellIndex] == 'bid') {
                        grid_xml = grid_xml + ' ask="' + settlement_grid.cells(row_index ,cellIndex - 1).getValue() + '"';
                        grid_xml = grid_xml + ' bid="' + settlement_grid.cells(row_index ,cellIndex).getValue() + '"';
                        grid_xml = grid_xml + ' mid="' + settlement_grid.cells(row_index ,cellIndex + 1).getValue() + '"';     
                    } else {
                        grid_xml = grid_xml + ' ask="' + settlement_grid.cells(row_index ,cellIndex - 2).getValue() + '"';
                        grid_xml = grid_xml + ' bid="' + settlement_grid.cells(row_index ,cellIndex - 1).getValue() + '"';
                        grid_xml = grid_xml + ' mid="' + settlement_grid.cells(row_index ,cellIndex).getValue() + '"';     
                    }
                    grid_xml = grid_xml + ' curve_source="' + sh2[cellIndex] + '"';   
                    grid_xml = grid_xml + ' curve_value=""';
                } else {
                    if (sh2[cellIndex] == 'ask') {
                        grid_xml = grid_xml + ' ask="' + settlement_grid.cells(row_index ,cellIndex).getValue() + '"';
                        grid_xml = grid_xml + ' bid="' + settlement_grid.cells(row_index ,cellIndex + 1).getValue() + '"';
                        grid_xml = grid_xml + ' mid="' + settlement_grid.cells(row_index ,cellIndex + 2).getValue() + '"';     
                    } else if (sh2[cellIndex] == 'bid') {
                        grid_xml = grid_xml + ' ask="' + settlement_grid.cells(row_index ,cellIndex - 1).getValue() + '"';
                        grid_xml = grid_xml + ' bid="' + settlement_grid.cells(row_index ,cellIndex).getValue() + '"';
                        grid_xml = grid_xml + ' mid="' + settlement_grid.cells(row_index ,cellIndex + 1).getValue() + '"';     
                    } else {
                        grid_xml = grid_xml + ' ask="' + settlement_grid.cells(row_index ,cellIndex - 2).getValue() + '"';
                        grid_xml = grid_xml + ' bid="' + settlement_grid.cells(row_index ,cellIndex - 1).getValue() + '"';
                        grid_xml = grid_xml + ' mid="' + settlement_grid.cells(row_index ,cellIndex).getValue() + '"';     
                    }
                    grid_xml = grid_xml + ' curve_source="' + curve_source_text + '"';
                    grid_xml = grid_xml + ' curve_value=""';
                }
            }
            grid_xml = grid_xml + ' forward_settle="s"';
            grid_xml = grid_xml + '></GridRow>';
        }
        return grid_xml;
    }
    
    copy_price = function() {
        var selected_row = view_price.price_curve_grid.getSelectedId();
        var selected_row_arr = (selected_row != null) ? selected_row.split(',') : '';
        
        if (selected_row_arr.length > 1 && selected_row != null) {
            show_messagebox('Please select single curve to copy.');
            return;
        }

        var curve_id = (selected_row != null) ? view_price.price_curve_grid.cells(selected_row, view_price.price_curve_grid.getColIndexById('source_curve_def_id')).getValue() : 'NULL';
        var curve_name = (selected_row != null) ? view_price.price_curve_grid.cells(selected_row, view_price.price_curve_grid.getColIndexById('curve_id')).getValue() : 'NULL';
        copy_price_window = new dhtmlXWindows();
                    
        new_copy_price = copy_price_window.createWindow('w1', 0, 0, 1150, 450);
        new_copy_price.setText(get_locale_value("Copy Price"));
        new_copy_price.centerOnScreen();
        new_copy_price.setModal(true);
        new_copy_price.attachURL('copy.price.php?curve_id=' + curve_id + '&curve_name=' + curve_name, false);
        return;
    }
    /*
     * derive_curve_values    [derive_curve_values]
     */
    derive_curve_values = function() {
        var price_curve_arr = new Array();
        var selected_row = view_price.price_curve_grid.getSelectedId();
        var formula_chk_flag = 0;
        
        if (selected_row != null) {
            var selected_row_arr = selected_row.split(',');
            for(i = 0; i < selected_row_arr.length; i++) {
                var tree_level = view_price.price_curve_grid.getLevel(selected_row_arr[i]);
                
                if (tree_level == 1) {
                    var value = view_price.price_curve_grid.cells(selected_row_arr[i], view_price.price_curve_grid.getColIndexById('source_curve_def_id')).getValue();
                    price_curve_arr.push(value);
                    
                    if (view_price.price_curve_grid.cells(selected_row_arr[i], view_price.price_curve_grid.getColIndexById('formula_id')).getValue() == 'Yes') {
                        formula_chk_flag =1;       
                    }
                }
            }
        } else {
            show_messagebox('Please select a price curve.');
            return;
        }
        
        if (formula_chk_flag == 0) {
            show_messagebox('Please select a derived price curve.');
            return;
        }
        
        var price_curve = price_curve_arr.toString();
        var as_of_date_from = view_price.view_price_filter_form.getItemValue('as_of_date_from', true);
        var as_of_date_to = view_price.view_price_filter_form.getItemValue('as_of_date_to', true);
        var tenor_from = view_price.view_price_filter_form.getItemValue('tenor_from', true);
        var tenor_to = view_price.view_price_filter_form.getItemValue('tenor_to', true);
        var curve_source_value_obj = view_price.view_price_filter_form.getCombo('curve_source');
        var curve_source_value = curve_source_value_obj.getSelectedValue();
        
        if (as_of_date_from == '') {
            show_messagebox('Please select As of Date From.');
            return;
        }
        
        if (as_of_date_to == '') {
            show_messagebox('Please select As of Date To.');
            return;
        }
        
        if (tenor_from == '') {
            show_messagebox('Please select Tenor From.');
            return;
        }
        
        if (tenor_to == '') {
            show_messagebox('Please select Tenor To.');
            return;
        }
        
        var exec_call = "EXEC spa_save_derived_curve_value 'c', "                 
                            + singleQuote(price_curve) + ', 77, '
                            + singleQuote(as_of_date_from) + ', '
                            + singleQuote(as_of_date_to) + ', '
                            + singleQuote(curve_source_value) + ', '
                            + singleQuote(tenor_from) + ', '
                            + singleQuote(tenor_to);
        
        var as_of_date_from = view_price.view_price_filter_form.getItemValue('as_of_date_from');    
        var param = 'gen_as_of_date=0&batch_type=c&as_of_date='+as_of_date_from;
        adiha_run_batch_process(exec_call, param, 'Derive Curve Value');
    }
    
    /*
     * undock_curve_values    [Undock function for the price curve grid layout cell]
     */
    undock_curve_values = function() {
        w1 = view_price.view_price_layout.cells('d').undock(300, 300, 900, 700);
        view_price.view_price_layout.dhxWins.window('d').button('park').hide();
        view_price.view_price_layout.dhxWins.window('d').maximize();
        view_price.view_price_layout.dhxWins.window('d').centerOnScreen();
    }
    
    /*
     * undock_price_curves    [Undock function for the curve value grid layout cell]
     */
    undock_price_curves = function() {
        w1 = view_price.view_price_layout.cells('a').undock(300, 300, 900, 700);
        view_price.view_price_layout.dhxWins.window('a').button('park').hide();
        view_price.view_price_layout.dhxWins.window('a').maximize();
        view_price.view_price_layout.dhxWins.window('a').centerOnScreen();
    }
    
    /*
     * view_price.on_dock_event    [Shows the undock button]
     */
    view_price.on_dock_event = function() {
        $(".undock_cell_a").show();
    }
    
    /*
     * view_price.on_undock_event    [Hides the undock button]
     */
    view_price.on_undock_event = function() {
        $(".undock_cell_a").hide();
    }
    
    /*
     * enable_menu_items    [Enables the menu items when the grid is loaded]
     */
    enable_menu_items = function() {
        if (has_rights_view_price_edit) {
            if (privilege_status == 'true')
                view_price.curve_values_menu.setItemEnabled("save");
            view_price.curve_values_menu.setItemEnabled("add");
            //view_price.curve_values_menu.setItemEnabled("delete");
        } else {
            view_price.curve_values_menu.setItemDisabled("save");
            view_price.curve_values_menu.setItemDisabled("add");
            view_price.curve_values_menu.setItemDisabled("delete");
        }
        view_price.curve_values_menu.setItemEnabled("excel");
        view_price.curve_values_menu.setItemEnabled("pdf");
        view_price.curve_values_menu.setItemEnabled("select_unselect");    
    }
    
    /**
     * [Function to expand/collapse price curve Grid when double clicked]
     */
    view_price.expand_price_curve = function(r_id, col_id) {
        var selected_row = view_price.price_curve_grid.getSelectedRowId();
        var state = view_price.price_curve_grid.getOpenState(selected_row);

        if (state)
            view_price.price_curve_grid.closeItem(selected_row);
        else
            view_price.price_curve_grid.openItem(selected_row);
    }   
    
    curve_value_batch = function() {
        var selected_row = view_price.price_curve_grid.getSelectedId();
        var curve_id_arr = new Array();
        
        if (selected_row != null) {
            var selected_row_arr = selected_row.split(',');
            for(i = 0; i < selected_row_arr.length; i++) {
                var tree_level = view_price.price_curve_grid.getLevel(selected_row_arr[i]);

                if (tree_level == 1) {
                    var value = view_price.price_curve_grid.cells(selected_row_arr[i], view_price.price_curve_grid.getColIndexById('source_curve_def_id')).getValue();
                    curve_id_arr.push(value);
                }
            }
        }
        
        var curve_id = curve_id_arr.toString();
        
        var curve_source_value_obj = view_price.view_price_filter_form.getCombo('curve_source');
        var curve_source = curve_source_value_obj.getChecked();
        curve_source = curve_source.toString();
        curve_source = view_price.view_price_filter_form.getItemValue('curve_source');
        
        var from_date = view_price.view_price_filter_form.getItemValue('as_of_date_from', true);
        var to_date = view_price.view_price_filter_form.getItemValue('as_of_date_to', true);
        
        var tenor_from = view_price.view_price_filter_form.getItemValue('tenor_from', true);
        var tenor_to =  view_price.view_price_filter_form.getItemValue('tenor_to', true);
        
        var ind_con_month = 'NULL';
        var mode = 's';
        var bid_ask = view_price.view_price_filter_form.isItemChecked('bid_ask');
        if (bid_ask == true) { bid_ask = 'y'; } else { bid_ask = 'n'; }
        
        var average = 'NULL';                  
        var settlement_changes = 'n';                    
        var copy_curve_id = 'NULL'
        var curve_type = 77;    
        
        if (curve_id == '') {
            show_messagebox('Please select a price curve.');
            return;
        }
        
        if (tenor_from == '' && forward_settlement_status == 's') {
            show_messagebox('Please select Tenor From.');
            return;
        }
        
        if (from_date == '') 
            from_date = tenor_from;

        if (to_date == '') {
            to_date = from_date;
        }
        
        if (from_date == '' && forward_settlement_status != 's') {
            show_messagebox('Please select As of Date From.');
            return;
        }
        
        var exec_call = 'EXEC spa_maintain_price_curve ' +
                                singleQuote(curve_id) + ', ' +
                                curve_type + ', ' +
                                curve_source + ', ' +
                                singleQuote(from_date) + ', ' +
                                singleQuote(to_date) + ', ' +
                                singleQuote(tenor_from) + ', ' +
                                singleQuote(tenor_to) + ', ' +
                                singleQuote(ind_con_month) + ', ' +
                                singleQuote(mode) + ', ' +
                                singleQuote(bid_ask) + ', ' +
                                singleQuote('NULL') + ', ' + //show differential removed
                                singleQuote(copy_curve_id) + ', ' +
                                singleQuote(average) + ', ' +
                                singleQuote(settlement_changes) + ', ' +
                                singleQuote('n'); // show non-derived price only - removed
        var from_date = view_price.view_price_filter_form.getItemValue('as_of_date_from',true);
        var param = 'call_from=Price Batch Import&gen_as_of_date=1&batch_type=r&as_of_date=' + to_date; 
        adiha_run_batch_process(exec_call, param, 'View Price');
    }
    
    view_price.validate_form_grid = function(attached_obj,grid_label) {;
        var status = true;
        for (var i = 0;i < attached_obj.getRowsNum();i++){
            var row_id = attached_obj.getRowId(i);
            
            if (row_id != undefined) {
                for (var j = 0;j < attached_obj.getColumnsNum();j++){ 
                    var validation_message = attached_obj.cells(row_id,j).getAttribute("validation");
                    
                    if(validation_message != "" && validation_message != undefined){
                        var column_text = attached_obj.getColLabel(j);
                        error_message = "Data Error in <b>"+grid_label+"</b> grid. Please check the data in column <b>"+column_text+"</b> and save.";
                        dhtmlx.alert({title:"Alert",type:"alert",text: error_message});
                        status = false; break;
                    }
                }
            }
            if(validation_message != "" && validation_message != undefined){ break;};
         }
        return status;
    }
    
    dhtmlxValidation.isHourMin=function(data){ 
        var d = data.replace(':','');
        if (isNaN(d)) {
            return false;
        } else {
            return true;
        }
    };
    
    dhtmlxValidation.isEmptyOrNumeric=function(data){
        if (data=="") {
            return true;
        } else if (isNaN(data) == false) {
            return true;
        } else {
            return false;
        }
    }

    function set_default_value() {        
        var sp_string =  "EXEC spa_as_of_date @flag = 'a', @screen_id = 10151000";
        var data_for_post = {"sp_string": sp_string};          
        var return_json = adiha_post_data('return_json', data_for_post, '', '', 'set_default_value_call_back');                  
    }

    function set_default_value_call_back(return_json) { 
        return_json = JSON.parse(return_json);

        var as_of_date = null;
        var no_of_days = null;
        
        if (return_json.length > 0) {
            as_of_date = return_json[0].as_of_date;
            no_of_days = return_json[0].no_of_days;    
        } 
        
        var date = new Date();
        var custom_as_of_date;
        // to get the latest update of the as of date
        if (as_of_date == 1) {   
        custom_as_of_date = return_json[0].custom_as_of_date;
        } else if (as_of_date == 2) {
            var custom_as_of_date = new Date(date.getFullYear(), date.getMonth(), 1);                   
        } else if (as_of_date == 3) {
            var custom_as_of_date = new Date(date.getFullYear(), date.getMonth() + 1, 0);                                                
        } else if (as_of_date == 4) {
            var custom_as_of_date = new Date(date.getFullYear(), date.getMonth(), date.getDate() - 1);            
        } else if (as_of_date == 5) {
            var calculated_date = date.setDate(date.getDate() - no_of_days);                
            calculated_date = new Date(calculated_date).toUTCString();
            custom_as_of_date = new Date(calculated_date);                             
        } else if (as_of_date == 6) {
            var first_day_next_mth = new Date(date.getFullYear(), date.getMonth() + 1, 1);                     
            first_day_next_mth = dates.convert_to_sql(first_day_next_mth);
            data = {
                        "action": "spa_get_business_day", 
                        "flag": "p",
                        "date": first_day_next_mth 
            } 
            return_json = adiha_post_data('return_json', data, '', '', 'load_business_day'); 
        } else if (as_of_date == 7) {
            var last_day_prev_mth = new Date(date.getFullYear(), date.getMonth(), 0);   
            last_day_prev_mth = dates.convert_to_sql(last_day_prev_mth);                                        
            data = {
                        "action": "spa_get_business_day", 
                        "flag": "n",
                        "date": last_day_prev_mth 
            }                                                                   
            return_json = adiha_post_data('return_json', data, '', '', 'load_business_day');
        } else if (as_of_date == 8) {
            var first_day_of_mth = new Date(date.getFullYear(), date.getMonth(), 1);    
            first_day_of_mth = dates.convert_to_sql(first_day_of_mth);                      
            data = {
                        "action": "spa_get_business_day", 
                        "flag": "p",
                        "date": first_day_of_mth 
            }
            return_json = adiha_post_data('return_json', data, '', '', 'load_business_day'); 
        }               

        if (as_of_date < 6) { //6,7,8 are called from call back function load_business_day
        view_price.view_price_filter_form.setItemValue('as_of_date_from', custom_as_of_date);
    }
    }

    function load_business_day(return_json) { 
        var return_json = JSON.parse(return_json);
        var business_day = return_json[0].business_day;             
        
        view_price.view_price_filter_form.setItemValue('as_of_date_from', business_day);
    }

       //function to delete pivot view grid data
    function pivot_view_curve_value_delete () {
        var del_ids =  grid_obj.getSelectedRowId();
        var previously_xml = grid_obj.getUserData("", "deleted_xml");        
        
        var grid_xml = "";    
        if (previously_xml != null) {     
            grid_xml += previously_xml    
        }
        var del_array = new Array();             
        del_array = (del_ids.indexOf(",") != -1) ? del_ids.split(",") : del_ids.split();             
          
        $.each(del_array, function(index, value) {
            grid_xml += "<GridRow ";                   
            for(var cellIndex = 0; cellIndex < grid_obj.getColumnsNum(); cellIndex++) {                       
                if((grid_obj.cells(value,0).getValue() != "")){
                    grid_xml += " " + grid_obj.getColumnId(cellIndex) + '="' + grid_obj.cells(value,cellIndex).getValue() + '"';                      
                }
            }
            grid_xml += " ></GridRow> ";  
        });

        grid_obj.setUserData("", "deleted_xml", grid_xml);
        grid_obj.deleteSelectedRows();
        view_price.curve_values_menu.setItemDisabled('delete');
    }
</script>
    
    