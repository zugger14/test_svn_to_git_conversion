<?php
/**
* Maintain transportation rate schedule screen
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
        // $formula_info_url = 'select formula_id,formula from formula_editor';
        // $formula_info = readXMLURL2($formula_info_url);

        $open_tab = isset($_REQUEST["maintain_rate_schedule"]) ? (empty($_REQUEST["maintain_rate_schedule"]) ? 'new' : get_sanitized_value($_REQUEST["maintain_rate_schedule"])) : '';

        $call_from = get_sanitized_value($_REQUEST['call_from'] ?? '');
        $contract_id = get_sanitized_value($_REQUEST['contract_id'] ?? '');

        $form_namespace = 'name_space';
        $form_obj = new AdihaStandardForm($form_namespace, 10162000);
        $form_obj->define_grid("transportation_rate_code", "","g");
        // $form_obj->define_custom_functions('', '', '', 'grid_activities','fx_before_save_validation');
        $form_obj->define_custom_functions('', '', '', 'grid_activities');
        echo $form_obj->init_form('Transportation Rate Schedules', 'Transportation Rate Schedules');
        echo $form_obj->close_form();
        $grid_sp = "EXEC spa_adiha_grid 's', 'transportation_rate_code'";
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
</script>
</body>
<script type="text/javascript">
    var open_tab = '<?php echo $open_tab ?>';
    var call_from = '<?php echo $call_from ?>';
    var contract_id = '<?php echo $contract_id ?>';
   
    name_space.after_post_callback = function(){
        parent.contract_group.grid.expandAll();
        parent.contract_group.tabbar.tabs(parent.contract_group.tabbar.getActiveTab()).close();    
        delete parent.contract_group.pages['tab_' + contract_id];
        rid = parent.contract_group.grid.findCell(contract_id,1,true)[0][0]//.getAllRowIds().split(',').filter(e=>parent.contract_group.grid.cells(e,1).getValue() == contract_id);
        parent.contract_group.create_tab(rid);
    }

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
            get_loaded_grid();
        }

        name_space.fx_before_save_validation = function() {
            var tab_id = name_space.tabbar.getActiveTab();
            var win = name_space.tabbar.cells(tab_id);
            var valid_status = 1;
            var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
            object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(" ", ""));
            var tab_obj = win.tabbar[object_id];
            var detail_tabs = tab_obj.getAllTabs();
            var id = detail_tabs.toString().split('_')[2];

            var grid_obj_fc = eval("transportation_rate_schedule_" + object_id + ".grid_" + id);
            
            grid_obj_fc.forEachRow(function(rid) {
                var formula_info = grid_obj_fc.getUserData(rid, 'formula_info');

                if(_.size(formula_info) > 0) {
                    grid_obj_fc.cells(rid, grid_obj_fc.getColIndexById('formula_id')).setValue(formula_info.formula_id);
                }
            });
            return 1;
             
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

                        var rate_category = rate_schedule_obj.getItemValue('rate_category');
                        var zone_from_ind = eval("variable_charge_" + object_id + ".grid_" + id).getColIndexById('zone_from');
                        var zone_to_ind = eval("variable_charge_" + object_id + ".grid_" + id).getColIndexById('zone_to');
                        var zone_from_ind_left = eval("transportation_rate_schedule_" + object_id + ".grid_" + id).getColIndexById('zone_from');
                        var zone_to_ind_left = eval("transportation_rate_schedule_" + object_id + ".grid_" + id).getColIndexById('zone_to');

                        
                        if (rate_category == 45203) {
                            eval("variable_charge_" + object_id + ".grid_" + id).setColumnHidden(zone_from_ind, false);
                            eval("variable_charge_" + object_id + ".grid_" + id).setColumnHidden(zone_to_ind, false);
                            eval("transportation_rate_schedule_" + object_id + ".grid_" + id).setColumnHidden(zone_from_ind_left, false);
                            eval("transportation_rate_schedule_" + object_id + ".grid_" + id).setColumnHidden(zone_to_ind_left, false);
                        } else if (rate_category == 45202) {
                            eval("variable_charge_" + object_id + ".grid_" + id).setColumnHidden(zone_from_ind, false);
                            eval("variable_charge_" + object_id + ".grid_" + id).setColumnHidden(zone_to_ind, true);
                            eval("transportation_rate_schedule_" + object_id + ".grid_" + id).setColumnHidden(zone_from_ind_left, false);
                            eval("transportation_rate_schedule_" + object_id + ".grid_" + id).setColumnHidden(zone_to_ind_left, true);
                        } else {
                            eval("variable_charge_" + object_id + ".grid_" + id).setColumnHidden(zone_from_ind, false);
                            eval("variable_charge_" + object_id + ".grid_" + id).setColumnHidden(zone_to_ind, false);
                            eval("transportation_rate_schedule_" + object_id + ".grid_" + id).setColumnHidden(zone_from_ind_left, false);
                            eval("transportation_rate_schedule_" + object_id + ".grid_" + id).setColumnHidden(zone_to_ind_left, false);
                        }

                        rate_schedule_obj.attachEvent('onChange', function(name, value){
                            if (name == 'rate_category') {
                                if (value == 45203) {
                                    eval("variable_charge_" + object_id + ".grid_" + id).setColumnHidden(zone_from_ind, false);
                                    eval("variable_charge_" + object_id + ".grid_" + id).setColumnHidden(zone_to_ind, false);
                                    eval("transportation_rate_schedule_" + object_id + ".grid_" + id).setColumnHidden(zone_from_ind_left, false);
                                    eval("transportation_rate_schedule_" + object_id + ".grid_" + id).setColumnHidden(zone_to_ind_left, false);
                                } else if (value == 45202) {
                                    eval("variable_charge_" + object_id + ".grid_" + id).setColumnHidden(zone_from_ind, false);
                                    eval("variable_charge_" + object_id + ".grid_" + id).setColumnHidden(zone_to_ind, true);
                                    eval("transportation_rate_schedule_" + object_id + ".grid_" + id).setColumnHidden(zone_from_ind_left, false);
                                    eval("transportation_rate_schedule_" + object_id + ".grid_" + id).setColumnHidden(zone_to_ind_left, true);
                                } else {
                                    eval("variable_charge_" + object_id + ".grid_" + id).setColumnHidden(zone_from_ind, false);
                                    eval("variable_charge_" + object_id + ".grid_" + id).setColumnHidden(zone_to_ind, false);
                                    eval("transportation_rate_schedule_" + object_id + ".grid_" + id).setColumnHidden(zone_from_ind_left, false);
                                    eval("transportation_rate_schedule_" + object_id + ".grid_" + id).setColumnHidden(zone_to_ind_left, false);
                                }   
                            }                            
                        });

                        grid_name = "transportation_rate_schedule_" + object_id + ".grid_" + id;
                        grid_object = eval("transportation_rate_schedule_" + object_id + ".grid_" + id);

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
                            grid_object.cells(id, grid_object.getColIndexById('rate_schedule_type')).setValue('t');

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
                            grid_object_c.cells(id, grid_object_c.getColIndexById('rate_schedule_type')).setValue('t');

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

        name_space.grid.attachEvent("onXLE", function(grid_obj,count){
            open_hyperlink_id();
        });
    }

    function open_hyperlink_id() {   
        name_space.grid.expandAll();
        if(open_tab == 'new') {
            name_space.create_tab(-1,0,name_space.grid);
        } else {
            // alert(open_tab);
            var cell_value = name_space.grid.findCell(open_tab, 1, true);  
            // alert(cell_value)        
            var row_index = name_space.grid.selectRowById(cell_value[0][0]);
            var parent_id = name_space.grid.getParentId(row_index);
            // alert(parent_id);
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
