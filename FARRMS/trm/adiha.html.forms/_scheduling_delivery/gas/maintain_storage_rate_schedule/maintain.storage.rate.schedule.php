<?php
/**
* Maintain storage rate schedule screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
    <?php
        
        $open_tab = isset($_REQUEST["maintain_rate_schedule"]) ? (empty($_REQUEST["maintain_rate_schedule"]) ? 'new' : get_sanitized_value($_REQUEST["maintain_rate_schedule"])) : '';

        $call_from = get_sanitized_value($_REQUEST['call_from'] ?? '');
        $contract_id = get_sanitized_value($_REQUEST['contract_id'] ?? '');
        $contract_name = get_sanitized_value($_REQUEST['contract_name'] ?? '');
        $counterparty_name = get_sanitized_value($_REQUEST['counterparty_name'] ?? '');

        $form_namespace = 'name_space';
        $form_obj = new AdihaStandardForm($form_namespace, 20008900);
        $form_obj->define_grid("storage_rate_code");
        $form_obj->define_custom_functions('', '', '', 'grid_activities');
        echo $form_obj->init_form('Storage Rate Schedules', 'Storage Rate Schedules');
        echo $form_obj->close_form();
        $grid_sp = "EXEC spa_adiha_grid 's', 'storage_rate_schedule'";
        $return_value1 = readXMLURL($grid_sp);
        $col_list = $return_value1[0][2];
        $label_list = $return_value1[0][3];
    ?>
<body>
<script type="text/javascript">
    /*This is to decresase the layout size cell  in the standard form*/ 
    name_space.post_form_load = function(win, tab_id) {
        var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;       
        var tab_obj = win.tabbar[object_id];     
        var detail_tabs = tab_obj.getAllTabs();  
        $.each(detail_tabs, function(index,value) {
            layout_obj = tab_obj.cells(value).getAttachedObject();          
            layout_obj.cells("a").setHeight(65);
        })
    }
</script>>
</body>
<script type="text/javascript">
    var maintain_rate_schedule = '<?php echo $maintain_rate_schedule ?? ''; ?>';

    var open_tab = '<?php echo $open_tab ?>';
    var call_from = '<?php echo $call_from ?>';
    var contract_id = '<?php echo $contract_id ?>';

    name_space.after_post_callback = function(){
        name_space.layout.cells('a').collapse();
        parent.contract_group.grid.expandAll();
        parent.contract_group.tabbar.tabs(parent.contract_group.tabbar.getActiveTab()).close();    
        delete parent.contract_group.pages['tab_' + contract_id];
        rid = parent.contract_group.grid.findCell(contract_id,1,true)[0][0];
        parent.contract_group.create_tab(rid);

        // parent.contract_group.rate_sch_win.close();
    }


    name_space.tab_toolbar_click = function (id) {
        var validation_status = 0;
        switch (id) {
            case "close":
                var tab_id = name_space.tabbar.getActiveTab();
                delete name_space.pages[tab_id];
                name_space.tabbar.tabs(tab_id).close(true);
                break;
            case "save":
                if(open_tab == ''){
                    name_space.layout.cells("a").expand();
                }
                var tab_id = name_space.tabbar.getActiveTab();
                var win = name_space.tabbar.cells(tab_id);
                var valid_status = 1;
                var object_id = tab_id.indexOf("tab_") != -1 ? tab_id.replace("tab_", "") : tab_id;
                object_id = $.isNumeric(object_id) ? object_id : ord(object_id.replace(" ", ""));
                var tab_obj = win.tabbar[object_id];
                var detail_tabs = tab_obj.getAllTabs();
                var grid_xml = "<GridGroup>";
                var form_xml = "<FormXML ";
                var form_status = true;
                var first_err_tab;
                var first_err_tab;
                var tabsCount = tab_obj.getNumberOfTabs();

                got_rate = true;
                got_formula = true;
                grid_name = '';

                $.each(detail_tabs, function (index, value) {
                    layout_obj = tab_obj.cells(value).getAttachedObject();
                    layout_obj.forEachItem(function (cell) {
                        attached_obj = cell.getAttachedObject();
                        if (attached_obj instanceof dhtmlXGridObject) {
                            attached_obj.clearSelection();
                            var ids = attached_obj.getChangedRows(true);
                            grid_id = attached_obj.getUserData("", "grid_id");
                            grid_label = attached_obj.getUserData("", "grid_label");
                            deleted_xml = attached_obj.getUserData("", "deleted_xml");
                            if (deleted_xml != null && deleted_xml != "") {
                                grid_xml += "<GridDelete grid_id=\"" + grid_id + "\" grid_label=\"" + grid_label + "\">";
                                grid_xml += deleted_xml;
                                grid_xml += "</GridDelete>";
                                if (delete_grid_name == "") {
                                    delete_grid_name = grid_label;
                                } else {
                                    delete_grid_name += "," + grid_label;
                                };
                            };
                            if (ids != "") {
                                attached_obj.setSerializationLevel(false, false, true, true, true, true);
                                if (valid_status != 0) {
                                    var grid_status = name_space.validate_form_grid(attached_obj, grid_label);
                                }
                                grid_xml += "<Grid grid_id=\"" + grid_id + "\">";
                                var changed_ids = new Array();
                                changed_ids = ids.split(",");
                                if (grid_status) {
                                    $.each(changed_ids, function (index, value) {
                                        attached_obj.setUserData(value, "row_status", "new row");
                                        grid_xml += "<GridRow ";
                                        for (var cellIndex = 0; cellIndex < attached_obj.getColumnsNum(); cellIndex++) {
                                            if (attached_obj.cells(value, cellIndex).getValue() == 'undefined') {
                                                //Cannot use typeof because it returns string
                                                grid_xml += " " + attached_obj.getColumnId(cellIndex) + '= "NULL"';
                                                continue;
                                            }

                                            if(attached_obj.getColumnId(cellIndex) == 'formula_name' && attached_obj.cells(value, cellIndex).getValue() == '') {
                                                got_formula = false;
                                                grid_name = attached_obj.getUserData("", "grid_label");

                                            }
                                            if(attached_obj.getColumnId(cellIndex) == 'rate'  && attached_obj.cells(value, cellIndex).getValue() == '') {
                                                got_rate = false;
                                                grid_name = attached_obj.getUserData("", "grid_label");
                                            }

                                            grid_xml += " " + attached_obj.getColumnId(cellIndex) + '="' + attached_obj.cells(value, cellIndex).getValue() + '"';
                                        }
                                        grid_xml += " ></GridRow> ";
                                    });

                                    // alert('got_rate_or_formula=>' + (got_rate || got_formula));
                                    grid_xml += "</Grid>";
                                } else {
                                    valid_status = 0;
                                };
                            }
                        } else if (attached_obj instanceof dhtmlXForm) {
                            var status = validate_form(attached_obj);
                            form_status = form_status && status;
                            if (tabsCount == 1 && !status) {
                                first_err_tab = "";
                            } else if (!first_err_tab && !status) {
                                first_err_tab = tab_obj.cells(value);
                            }
                            if (status) {

                                data = attached_obj.getFormData();
                                for (var a in data) {
                                    field_label = a;
                                    if (attached_obj.getItemType(field_label) == "calendar") {
                                        field_value = attached_obj.getItemValue(field_label, true);
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
                var xml = "<Root function_id=\"20008900\" object_id=\"" + object_id + "\">";
                xml += form_xml;
                xml += grid_xml;
                xml += "</Root>";
                xml = xml.replace(/'/g, "\"");
                if (!form_status) {
                    generate_error_message(first_err_tab);
                }
                if (valid_status == 1) {

                    if(!(got_rate || got_formula)){
                        show_messagebox('Either <b>Rate</b> or <b>Formula</b> is required in <b>' + grid_name + '</b>.');
                        return;
                    }

                    win.getAttachedToolbar().disableItem('save');

                    data = { "action": "spa_process_form_data", "xml": xml };
                    if (delete_grid_name != "") {
                        del_msg = "Some data has been deleted from " + delete_grid_name + " grid. Are you sure you want to save?";
                        result = adiha_post_data("confirm-warning", data, "", "", "name_space.post_callback", "", del_msg);
                    } else {
                        result = adiha_post_data("alert", data, "", "", "name_space.post_callback");
                    }
                    delete_grid_name = "";
                    deleted_xml = attached_obj.setUserData("", "deleted_xml", "");
                }
                break;
            default:
                break;
        }
    };

    name_space.post_callback = function (result) {
        var tab_id = name_space.tabbar.getActiveTab();
        name_space.tabbar.cells(tab_id).getAttachedToolbar().enableItem('save');
        if (result[0].errorcode == "Success") {
            name_space.clear_delete_xml();
            var col_type = name_space.grid.getColType(0);
            if (col_type == "tree") {
                name_space.grid.saveOpenStates();
            }
            if (result[0].recommendation != null) {
                var tab_id = name_space.tabbar.getActiveTab();
                var previous_text = name_space.tabbar.tabs(tab_id).getText();
                if (previous_text == get_locale_value("New")) {
                    var tab_text = new Array();
                    if (result[0].recommendation.indexOf(",") != -1) {
                        tab_text = result[0].recommendation.split(",");
                    } else {
                        tab_text.push(0, result[0].recommendation);
                    }
                    name_space.tabbar.tabs(tab_id).setText(tab_text[1]);
                    name_space.refresh_grid("", name_space.open_tab);
                } else {
                    name_space.refresh_grid("", name_space.refresh_tab_properties);
                }

                if(open_tab != ''){
                    data = {
                        "action": "spa_transportation_rate_maintain",
                        "flag":'y',
                        "transport_value_id":result[0].recommendation.indexOf(',') >= 0 ? result[0].recommendation.split(',')[1] : result[0].recommendation,
                        "contract_id" : contract_id
                    };

                    adiha_post_data('return_json', data, '', '', 'name_space.after_post_callback', false);


                }
            }
            name_space.menu.setItemDisabled("delete");
        }
    };

    $(function(){
        if(open_tab != '') {
            name_space.layout.cells('a').collapse();
            get_loaded_grid();
        }

        name_space.grid_activities = function() {
            var tab_id = name_space.tabbar.getActiveTab();

            var win = name_space.tabbar.cells(tab_id);
            var valid_status = 1;
            var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
            object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(" ", ""));
            var tab_obj = win.tabbar[object_id];
            var detail_tabs = tab_obj.getAllTabs();
            var id = detail_tabs.toString().split('_')[2];
             
            $.each(detail_tabs, function(index,value) {
                layout_obj = tab_obj.cells(value).getAttachedObject();
                layout_obj.cells("a").setHeight(100);
                layout_obj.forEachItem(function(cell) {
                    attached_obj = cell.getAttachedObject();
                    
                    if (attached_obj instanceof dhtmlXForm) {                    
                        var rate_schedule_obj = attached_obj.getForm();

                        if(open_tab == 'new'){
                            var contract_name = '<?php echo $contract_name ?>';
                            var counterparty_name = '<?php echo $counterparty_name ?>';

                            var name_value = contract_name + '_RS (' + counterparty_name + ')'; 
                            
                            rate_schedule_obj.setItemValue('code', name_value);
                            // open_tab = '';
                        }                

                        grid_name = "transportation_rate_schedule_" + object_id + ".grid_" + id;
                        grid_object = eval("transportation_rate_schedule_" + object_id + ".grid_" + id);
                        
                        var effective_date = grid_object.getColIndexById('effective_date');
                        grid_object.setColumnHidden(effective_date, true);

                        grid_object1 = eval("variable_charge_" + object_id + ".grid_" + id);
                        var effective_date1 = grid_object1.getColIndexById('effective_date');
                        grid_object1.setColumnHidden(effective_date1, true);


                        grid_object.csvParser.unblock = function (m, a, l) {
                            var h = (m || "").split(l);
                            for (var c = 0; c < h.length; c++) {
                                h[c] = (h[c] || "").split(a);
                            }
                            var g = h.length - 1;
                            if (h[g].length == 1 && h[g][0] == "") {
                                h.splice(g, 1)
                            }
                            return h.map(function(e){
                                return e.map(function(f){
                                    return (dates.convert_to_sql(f) == "NaN-NaN-NaN") ? f : dates.convert_to_sql(f);
                                })
                            });
                        }
                        grid_object.attachEvent("onKeyPress", function(code,ctrl,shift) {
                            if(code==86&&ctrl) {
                                var all_rows = grid_object.getAllRowIds();
                                var before_add = grid_object.getRowsNum();
                                //alert(before_add);
                               
                               for(var i = 0; i<30; i++){
                                   grid_object.addRow((new Date()).valueOf(),',,,,,,,,,,,,');
                               }
                                if( all_rows != '') {
                                    var after_add = grid_object.getRowsNum();
                                    var d = after_add-before_add;

                                    for(var j=before_add; j<after_add; j++) {
                                       grid_object.selectRow(after_add-j+before_add,true,true,false);
                                    }
                                    
                                }   else {
                                        grid_object.selectAll();
                                }

                                grid_object.setCSVDelimiter("\t");
                                grid_object.pasteBlockFromClipboard();
                                var rows = grid_object.getAllRowIds().split(',');
                                setTimeout(function() {
                                    for(var i = 0; i<rows.length; i++) {
                                        var kkk =0 
                                        $(grid_object.rowsAr[rows[i]]).find('td').each(function(e,el){
                                            var val = $(el).text().trim();
                                            kkk += parseInt(val == '' ? 0 : 1)
                                        });
                                        if(kkk == 0) {
                                            grid_object.deleteRow(rows[i]);
                                            
                                        }
                                    }
                                    
                                },100);
                            return true;
                            }
                        });

                        grid_object.attachEvent("onRowPaste", function(rId) {
                            grid_object.forEachCell(rId,function(cellObj,ind){
                                val = grid_object.cells(rId,ind).getValue();
                                if(val.trim() == ''){
                                    grid_object.cells(rId,ind).setValue('');
                                }
                                if(grid_object.getColType(ind) == 'combo'){
                                    combo = grid_object.getColumnCombo(ind);
                                    grid_object.cells(rId,ind).setValue(combo.getOptionByLabel(val).value);
                                }
                                grid_object.validateCell(rId,ind);
                            });

                        });

                        grid_object.enableBlockSelection();


                        grid_object.attachEvent('onRowSelect', function(id, ind) {

                            // set rate schedule type.
                            grid_object.cells(id, grid_object.getColIndexById('rate_schedule_type')).setValue('s');
                            // alert(grid_object.cells(id, grid_object.getColIndexById('rate_schedule_type')).getValue('t'));  


                            var formula_id_index = grid_object.getColIndexById('formula_id');
                            var formula_name_index = grid_object.getColIndexById('formula_name');
                            var row_id = grid_object.getSelectedRowId();
                            var formula_id = grid_object.cells(row_id, formula_id_index).getValue();
                            
                            if (ind == formula_name_index) {                
                                ___browse_win_link_window = new dhtmlXWindows();
                                var src = '../../../_setup/formula_builder/formula.editor.php?formula_id=' + formula_id + '&call_from=browser&is_rate_schedule=1&row_id=' + row_id + '&rate_category_grid=' + grid_name;

                                win_formula_id = ___browse_win_link_window.createWindow('w1', 0, 0, 1200, 650);
                                win_formula_id.setText("Browse");
                                win_formula_id.centerOnScreen();
                                win_formula_id.setModal(true);
                                win_formula_id.attachURL(src, false);
                            }
                        });
                        
                        grid_name_c = "variable_charge_" + object_id + ".grid_" + id;
                        grid_object_c = eval("variable_charge_" + object_id + ".grid_" + id);
                        grid_object_c.attachEvent('onRowSelect', function(id, ind) {

                            // set rate schedule type.
                            grid_object_c.cells(id, grid_object_c.getColIndexById('rate_schedule_type')).setValue('s');

                            var formula_id_index = grid_object_c.getColIndexById('formula_id');
                            var formula_name_index = grid_object_c.getColIndexById('formula_name');
                            var row_id = grid_object_c.getSelectedRowId();
                            var formula_id = grid_object_c.cells(row_id, formula_id_index).getValue();
                            
                            if (ind == formula_name_index) {                
                                ___browse_win_link_window = new dhtmlXWindows();
                                var src = '../../../_setup/formula_builder/formula.editor.php?formula_id=' + formula_id + '&call_from=browser&is_rate_schedule=1&row_id=' + row_id + '&rate_category_grid=' + grid_name_c;

                                win_formula_id = ___browse_win_link_window.createWindow('w1', 0, 0, 1200, 650);
                                win_formula_id.setText("Browse");
                                win_formula_id.centerOnScreen();
                                win_formula_id.setModal(true);
                                win_formula_id.attachURL(src, false);
                            }
                        });                        
                    }                                       
                });
            });
        } 
    });

    function get_loaded_grid() {
        var row_count = name_space.grid.getRowsNum();

        setTimeout(function () {
            open_hyperlink_id();
        }, 500);
    }

    function open_hyperlink_id() { 
        if(open_tab == 'new') {
            name_space.create_tab(-1,0,name_space.grid);
        } else {
            var cell_value = name_space.grid.findCell(open_tab, 0, true);          
            var row_index = name_space.grid.selectRowById(cell_value[0][0]);
            name_space.create_tab(cell_value[0][0],1,name_space.grid);   
        }             
    }

    function set_formula_columns(formula_id, txt_formula, row_id, rate_category_grid) {
        var tab_id = name_space.tabbar.getActiveTab();
        var win = name_space.tabbar.cells(tab_id);
        var valid_status = 1;
        var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(" ", ""));
        var tab_obj = win.tabbar[object_id];
        var detail_tabs = tab_obj.getAllTabs();
        var id = detail_tabs.toString().split('_')[2];
         
        $.each(detail_tabs, function(index,value) {
            layout_obj = tab_obj.cells(value).getAttachedObject();
            var grid_obj = eval(rate_category_grid);

            var formula_id_index = grid_obj.getColIndexById('formula_id');
            var formula_name_index = grid_obj.getColIndexById('formula_name');
            
            grid_obj.cells(row_id, formula_id_index).setValue(formula_id);  
            //grid_obj.setUserData(row_id,'formula_info',{'formula_id':formula_id,'formula_text':txt_formula});  
            grid_obj.cells(row_id, formula_name_index).setValue(txt_formula);          
            grid_obj.cells(row_id, formula_id_index).cell.wasChanged = true; //made dirty row after setting the formula column value.

        });          
    }
</script>
</html>