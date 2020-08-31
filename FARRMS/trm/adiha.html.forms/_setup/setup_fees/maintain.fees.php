<?php
/**
* Maintain fees screen
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
            $function_id = 20001200;
            $form_namespace = 'setup_fees';
            $template_name = "SetupFees";
            $form_obj = new AdihaStandardForm($form_namespace, 20001200);
            $form_obj->define_grid("SetupFees");
            $form_obj->define_layout_width(350);
            $form_obj->define_custom_functions('custom_save_function', '', '','after_form_load');
            echo $form_obj->init_form('Setup Fees');
            echo $form_obj->close_form();
        ?>
    </body>

    <script>
        setup_fees.after_form_load = function() { 
            var tab_id = setup_fees.tabbar.getActiveTab();
            var win = setup_fees.tabbar.cells(tab_id);
            var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
            object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(" ", ""));
            var tab_obj = win.tabbar[object_id];
            var detail_tabs = tab_obj.getAllTabs();
            lay_obj = tab_obj.cells(detail_tabs[0]).getAttachedObject();

            var grid_obj = lay_obj.cells('b').getAttachedObject();

            var juri_index = grid_obj.getColIndexById('jurisdiction');
            var tier_index = grid_obj.getColIndexById('tier');

            grid_obj.attachEvent("onRowAdded", function(row_id){
                var juris_value = grid_obj.cells(row_id, juri_index).getValue("jurisdiction");
                    if (juris_value === '') {
                        var ind_combo = grid_obj.cells(row_id, tier_index).getCellCombo();
                        ind_combo.hide();
                    }
            });

            if (tab_id.indexOf('tab_') != -1) {
                lay_obj.cells('b').progressOn();
                // SQL for loading grid value
                var load_grid_sql = "EXEC spa_setup_fees_grid_data @flag = 'k', @source_fee_id = " + object_id + " ";
                var sql_param = {'sql' : load_grid_sql};
                sql_param = $.param(sql_param);
                var sql_url = js_data_collector_url + "&" + sql_param;
                //Load values on  Grid
                grid_obj.clearAndLoad(sql_url, function() {
                    lay_obj.cells('b').progressOff();
                });
            }


            grid_obj.attachEvent("onCellChanged", function(rId, cInd, nValue) {
                if (juri_index == cInd) {
                    /*
                        # nValue gives 'text' on first load and gives 'id' afterwards
                        # Pattern to check if nValue is String or a Number
                    */
                    // grid_obj.cells(rId, tier_index).setValue("");
                    var patt = /^[0-9]/g;
                    var is_num = patt.test(nValue);

                    var ind_combo = grid_obj.cells(rId, tier_index).getCellCombo();
                    var first_value = grid_obj.cells(rId, cInd).getValue();
                    // var juris_value = nValue;
                    var state_value;
                    if (is_num == false) {
                        state_value = first_value;
                    } else {
                        state_value = nValue;
                    }

                    
                    var cm_params = {
                                    'action' : 'spa_setup_fees_grid_data',
                                    'flag' : 'j',
                                    'jurisdiction_id' : state_value,
                                    'has_blank_option' : 'true'
                                };
                    cm_params = $.param(cm_params);
                    var urls = js_dropdown_connector_url + '&' + cm_params;
                    ind_combo.clearAll();
                       
                    lay_obj.cells('b').progressOn();
                    
                    ind_combo.load(urls, function() {
                        var tier_value = grid_obj.cells(rId, tier_index).getValue();
                        ind_combo.show();
                        if (is_num == false) {
                            grid_obj.cells(rId, tier_index).setValue(tier_value);
                        } else {
                            grid_obj.cells(rId, tier_index).setValue('');
                        }
                        
                        lay_obj.cells('b').progressOff();
                        
                    });
                }
            });

            grid_obj.attachEvent("onXLE", function(grid_obj,count) {
                var type_col_index = grid_obj.getColIndexById("type");
                var from_volume_col_index = grid_obj.getColIndexById("from_volume");
                var to_volume_col_index = grid_obj.getColIndexById("to_volume");

                grid_obj.forEachRow(function(id) {
                    if (grid_obj.cells(id,type_col_index).getText().trim() != 'Tiered') {
                        grid_obj.cells(id,from_volume_col_index).setDisabled(true);
                        grid_obj.cells(id,to_volume_col_index).setDisabled(true);
                        grid_obj.cells(id,from_volume_col_index).setValue('');
                        grid_obj.cells(id,to_volume_col_index).setValue('');
                    }
                });

                grid_obj.attachEvent("onCellChanged", function(rId,cInd,nValue) {
                    if(cInd == type_col_index) {
                        if(grid_obj.cells(rId,type_col_index).getText().trim() == 'Tiered') {
                            grid_obj.cells(rId,from_volume_col_index).setDisabled(false);
                            grid_obj.cells(rId,to_volume_col_index).setDisabled(false);
                        } else {
                            grid_obj.cells(rId,from_volume_col_index).setDisabled(true);
                            grid_obj.cells(rId,to_volume_col_index).setDisabled(true);
                            grid_obj.cells(rId,from_volume_col_index).setValue('');
                            grid_obj.cells(rId,to_volume_col_index).setValue('');
                        }
                    }
                });                
            });
        }

        setup_fees.create_tab = function(r_id, col_id, grid_obj, acc_id,tab_index) {  
            if (r_id == -1 && col_id == 0) {
                full_id = setup_fees.uid();
                full_id = full_id.toString();
                text = "New";
            } else {
                full_id = setup_fees.get_id(setup_fees.grid, r_id);
                //text = setup_fees.get_text(setup_fees.grid, r_id);
                var fee_name_colIndex=setup_fees.grid.getColIndexById('fee_name');
                text = setup_fees.grid.cells(r_id,fee_name_colIndex).getValue();

                if (full_id == "tab_"){ 
                    var selected_row = setup_fees.grid.getSelectedRowId();
                    var state = setup_fees.grid.getOpenState(selected_row);
                    if (state)
                        setup_fees.grid.closeItem(selected_row);
                    else
                        setup_fees.grid.openItem(selected_row);
                return false;
                }
            }

            if (!setup_fees.pages[full_id]) {
                var tab_context_menu = new dhtmlXMenuObject();
                var icon_path = js_image_path + 'dhxtoolbar_web/';
                tab_context_menu.setIconsPath(icon_path);
                tab_context_menu.renderAsContextMenu();
                setup_fees.tabbar.addTab(full_id,text, null, tab_index, true, true);
                //using window instead of tab
                var win = setup_fees.tabbar.cells(full_id);
                setup_fees.tabbar.t[full_id].tab.id = full_id;
                tab_context_menu.addContextZone(full_id);
                tab_context_menu.loadStruct([{id:"close", text:"Close", title: "Close"},{id:"close_all", text:"Close All", title: "Close All"},{id:"close_other", text:"Close Other Tabs", title: "Close Other Tabs"}]);

                tab_context_menu.attachEvent("onContextMenu", function(zoneId){
                    setup_fees.tabbar.tabs(zoneId).setActive();
                });

                tab_context_menu.attachEvent("onClick", function(id, zoneId) {
                    var ids = setup_fees.tabbar.getAllTabs();

                    switch(id) {
                        case "close_other":
                            ids.forEach(function(tab_id) {
                                if (tab_id != zoneId) {
                                    delete setup_fees.pages[tab_id];
                                    setup_fees.tabbar.tabs(tab_id).close();
                                }
                            });
                         break;
                        case "close_all":
                            ids.forEach(function(tab_id) {
                                delete setup_fees.pages[tab_id];
                                setup_fees.tabbar.tabs(tab_id).close();
                            });
                            break;
                        case "close":
                            ids.forEach(function(tab_id) {
                                if (tab_id == zoneId) {
                                    delete setup_fees.pages[tab_id];
                                    setup_fees.tabbar.tabs(tab_id).close();
                                }
                            });
                            break;
                    }
                });
                var toolbar = win.attachToolbar();
                toolbar.setIconsPath(icon_path);
                toolbar.attachEvent("onClick",setup_fees.tab_toolbar_click);
                toolbar.loadStruct([{id:"save", type: "button", img: "save.gif", imgdis: "save_dis.gif", text:"Save", title: "Save"}]);
                setup_fees.tabbar.cells(full_id).setText(text);
                setup_fees.tabbar.cells(full_id).setActive();
                setup_fees.tabbar.cells(full_id).setUserData("row_id", r_id);
                win.progressOn();
                setup_fees.set_tab_data(win,full_id);
                setup_fees.pages[full_id] = win;
            }
            else {
                setup_fees.tabbar.cells(full_id).setActive();
            }
        };

        setup_fees.post_callback = function(result) {  
            var tab_id = setup_fees.tabbar.getActiveTab(); 
            setup_fees.tabbar.cells(tab_id).getAttachedToolbar().enableItem('save');   
            if (result[0].errorcode == "Success") {
                setup_fees.clear_delete_xml();
                var col_type = setup_fees.grid.getColType(0);
                if (col_type == "tree") {
                    setup_fees.grid.saveOpenStates();
                }

                if (result[0].recommendation != null) {
                    var previous_text = setup_fees.tabbar.tabs(tab_id).getText();
                    var tab_text = new Array();
                    if (result[0].recommendation.indexOf(",") != -1) { 
                        tab_text = result[0].recommendation.split(",") 
                    } else { 
                        tab_text.push(0, result[0].recommendation); 
                    }
                    setup_fees.tabbar.tabs(tab_id).setText(tab_text[1]);
                    setup_fees.refresh_grid("", setup_fees.open_tab);
                }
                setup_fees.menu.setItemDisabled("delete");
            }
        };

        /*setup_fees.refresh_tab_properties = function() {  
            var col_type = setup_fees.grid.getColType(0); 
            var prev_id = setup_fees.tabbar.getActiveTab();
            var system_id = (prev_id.indexOf("tab_") != -1) ? prev_id.replace("tab_", "") : prev_id;

            if (col_type == "tree") {
                setup_fees.grid.loadOpenStates();
                var primary_value = setup_fees.grid.findCell(system_id, 1, true, true);
            } else {
                var primary_value = setup_fees.grid.findCell(system_id, 0, true, true);
            } 

            setup_fees.grid.filterByAll();  

            if (primary_value != "") {
                var r_id = primary_value.toString().substring(0, primary_value.toString().indexOf(","));

                var fee_name_colIndex=setup_fees.grid.getColIndexById('fee_name'); 
                var tab_text = setup_fees.grid.cells(r_id,fee_name_colIndex).getValue();  
                //var tab_text = setup_fees.get_text(setup_fees.grid, r_id); 
                setup_fees.tabbar.tabs(prev_id).setText(tab_text);
                setup_fees.grid.selectRowById(r_id,false,true,true);
            } 
            var win = setup_fees.tabbar.cells(prev_id);
            var tab_obj = win.tabbar[system_id];
            var detail_tabs = tab_obj.getAllTabs();
            var grid_xml = "<GridGroup>";
            var form_xml = "<FormXML ";
            $.each(detail_tabs, function(index,value) {
                layout_obj = tab_obj.cells(value).getAttachedObject();
                layout_obj.forEachItem(function(cell){
                attached_obj = cell.getAttachedObject();
                if (attached_obj instanceof dhtmlXGridObject) {
                    attached_obj.clearSelection();
                    var grid_obj = attached_obj.getUserData("","grid_obj");
                    eval(grid_obj + ".refresh_grid()");
                    }  
                });
            });
        }*/

        setup_fees.custom_save_function = function(tab_id) {
            var tab_id = setup_fees.tabbar.getActiveTab();
            var win = setup_fees.tabbar.cells(tab_id);
            var valid_status = 1;
            var mode;
            var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
            object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(" ", ""));
            var tab_obj = win.tabbar[object_id];
            var detail_tabs = tab_obj.getAllTabs();
            lay_obj = tab_obj.cells(detail_tabs[0]).getAttachedObject();
            form_obj = lay_obj.cells('a').getAttachedObject();
            var source_fee_id = form_obj.getItemValue('source_fee_id');
            if (source_fee_id == '') {
                mode = 'i';
            } else {
                mode = 'u';
            }

            var grid_xml = "<GridGroup>";
            var form_xml = "<FormXML ";

            $.each(detail_tabs, function(index,value) {
                layout_obj = tab_obj.cells(value).getAttachedObject();
                layout_obj.forEachItem(function(cell) {
                    attached_obj = cell.getAttachedObject();
                    if (attached_obj instanceof dhtmlXGridObject) {
                        attached_obj.clearSelection();
                        var ids = attached_obj.getChangedRows(true);
                        grid_id = attached_obj.getUserData("", "grid_id");
                        grid_label = attached_obj.getUserData("", "grid_label");
                        deleted_xml = attached_obj.getUserData("", "deleted_xml");
                        if (deleted_xml != null && deleted_xml != "") {
                            grid_xml += "<GridDelete" + grid_id + " grid_id=\"" + grid_id + "\" grid_label=\"" + grid_label + "\">";
                            grid_xml += deleted_xml;
                            grid_xml += "</GridDelete" + grid_id + ">";

                            if(delete_grid_name == "") {
                                delete_grid_name = grid_label
                            } else { 
                                delete_grid_name += "," + grid_label
                            };
                        };

                        if (ids != "") {
                            attached_obj.setSerializationLevel(false,false,true,true,true,true);
                            if (valid_status != 0) {
                                var grid_status = setup_fees.validate_form_grid(attached_obj,grid_label);
                            }
                            grid_xml += "<Grid" + grid_id + ">";
                            var changed_ids = new Array();
                            changed_ids = ids.split(",");
                            if (grid_status) {
                                $.each(changed_ids, function(index, value) {
                                    attached_obj.setUserData(value, "row_status", "new row");
                                    grid_xml += "<GridRow ";
                                    for (var cellIndex = 0; cellIndex < attached_obj.getColumnsNum(); cellIndex++) {
                                        if (attached_obj.cells(value, cellIndex).getValue() == 'undefined') { //Cannot use typeof because it returns string
                                            grid_xml += " " + attached_obj.getColumnId(cellIndex) + '= "NULL"';
                                            continue;
                                        }
                                        grid_xml += " " + attached_obj.getColumnId(cellIndex) + '="' + attached_obj.cells(value,cellIndex).getValue() + '"';
                                    }
                                    grid_xml += " ></GridRow> ";
                                });
                                grid_xml += "</Grid" + grid_id + ">";
                            } else { 
                                valid_status = 0; 
                            };
                        }
                    } else if(attached_obj instanceof dhtmlXForm) {
                        var status = validate_form(attached_obj);
                        if(status) {
                            data = attached_obj.getFormData();
                            for (var a in data) {
                                field_label = a;
                                if (attached_obj.getItemType(field_label) == "calendar") {
                                    field_value = attached_obj.getItemValue(field_label,true);
                                } else {
                                    field_value = data[a];
                                }
                                form_xml += " " + field_label + "=\"" + field_value + "\"";
                            }
                        } else { 
                            valid_status = 0;
                        }
                    }
                });
            });

            form_xml += "></FormXML>";
            grid_xml += "</GridGroup>";
            var xml = "<Root function_id=\"20001200\" object_id=\"" + object_id + "\">";
            xml += form_xml;
            xml += grid_xml;
            xml += "</Root>";
            
            xml = xml.replace(/'/g, "\"");
            if(valid_status == 1) {
                data = {"action": "spa_source_fees", "flag": mode, "source_fee_id": source_fee_id, "xml": xml}
                if(delete_grid_name != ""){
                    del_msg =  "Some data has been deleted from " + delete_grid_name + " grid. Are you sure you want to save?";
                    result = adiha_post_data("confirm-warning", data, "", "", "setup_fees.post_callback", "", del_msg);
                } else {
                    result = adiha_post_data("alert", data, "", "", "setup_fees.post_callback");
                }
                delete_grid_name = "";
                deleted_xml = attached_obj.setUserData("", "deleted_xml", "");
            }
        }
    </script>
</html>