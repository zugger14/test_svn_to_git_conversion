<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge, chrome=1"/>
    <?php require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
<?php
    $function_id = 20010600; //function id for eligibility_mapping_template
    $called_template_id = get_sanitized_value($_GET['template_id'] ?? ''); //called from setup renewable sources
    $form_namespace = 'eligibility_mapping_template';
    $form_obj = new AdihaStandardForm($form_namespace, $function_id);
    $form_obj->define_grid("EligibilityMappingTemplate");
    $form_obj->define_layout_width(300);
    $form_obj->define_custom_functions('save_value', '', '', 'form_loaded');
    echo $form_obj->init_form('Eligibility Mapping Template', 'Eligibility Mapping Template', $called_template_id); //used to open value if called from another window
    echo $form_obj->close_form();
?>
<body>
    <script type = 'text/javascript'>
        var grid_obj = []; //made array of grid object

        /*
            # Actions to do when a form loads completely (provides window object and id of tab)
        */
        eligibility_mapping_template.form_loaded = function (win, id) {
            var object_id = (id.indexOf('tab_') != -1) ? id.replace('tab_', '') : id;
            object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(' ', ''));
            var tab_obj = win.tabbar[object_id];
            var detail_tabs = tab_obj.getAllTabs();
            $.each(detail_tabs, function(index, value) {
                var layout_obj = tab_obj.cells(value).getAttachedObject();
                layout_obj.forEachItem(function(cell) {
                    attached_obj = cell.getAttachedObject();
                    if (attached_obj instanceof dhtmlXGridObject) {
                        // Issue arises when there are multiple tabs open, so grid object is put on array ...
                        grid_obj[id] = attached_obj;

                        /*
                            # When the row is added on new creation without saving then validation is thrown ...
                            # When row is added logic is written to set value on template id and also to hide
                              combo if no value is selected on jurisdiction combo
                        */
                        grid_obj[id].attachEvent("onRowAdded", function(row_id) {
                            if (id.indexOf('tab_') != -1) {
                                var template_id_index = grid_obj[id].getColIndexById("template_id");
                                var state_value_index = grid_obj[id].getColIndexById("state_value_id");
                                var tier_index = grid_obj[id].getColIndexById("tier_id");
                                grid_obj[id].cells(row_id, template_id_index).setValue(object_id);
                                var juris_value = grid_obj[id].cells(row_id, state_value_index).getValue("state_value_id");
                                if (juris_value === '') {
                                    var ind_combo = grid_obj[id].cells(row_id, tier_index).getCellCombo();
                                    ind_combo.hide();
                                }
                            } else {
                                show_messagebox('Please save the template first.');
                                grid_obj[id].clearAll();
                                return;
                            }
                        });

                        // Get Jurisdiction Combo
                        var juri_index = grid_obj[id].getColIndexById('state_value_id');
                        var juri_combo_obj = grid_obj[id].getColumnCombo(juri_index);
                        // Get Tier Combo
                        var tier_index = grid_obj[id].getColIndexById('tier_id');
                        var tier_combo_obj = grid_obj[id].getColumnCombo(tier_index);

                        /*
                            # This logic is used to check if the tab is new or not.
                            # tab_[id] is created as ID of tab for saved data whereas new tab id is created with current timestamp without prefix "tab_".
                        */
                        if (id.indexOf('tab_') != -1) {
                            layout_obj.cells('b').progressOn();
                            // SQL for loading grid value
                            var load_grid_sql = "EXEC spa_eligibility_mapping @flag = 'x', @template_id = " + object_id + " ";
                            var sql_param = {'sql' : load_grid_sql};
                            sql_param = $.param(sql_param);
                            var sql_url = js_data_collector_url + "&" + sql_param;
                            //Load values on  Grid
                            grid_obj[id].clearAndLoad(sql_url, function() {
                                layout_obj.cells('b').progressOff();
                            });
                        }

                        /*
                            # This logic is only when the Jurisdiction Combo is Changed
                        */
                        grid_obj[id].attachEvent("onCellChanged", function(rId, cInd, nValue) {
                            if (juri_index == cInd) {
                                /*
                                    # nValue gives 'text' on first load and gives 'id' afterwards
                                    # Pattern to check if nValue is String or a Number
                                */
                                var patt = /^[0-9]/g;
                                var is_num = patt.test(nValue);

                                var ind_combo = grid_obj[id].cells(rId, tier_index).getCellCombo();
                                var first_value = grid_obj[id].cells(rId, cInd).getValue();
                                var state_value;

                                if (is_num == false) {
                                    state_value = first_value;
                                } else {
                                    state_value = nValue;
                                }

                                var cm_params = {
                                                'action' : 'spa_eligibility_mapping',
                                                'flag' : 'l',
                                                'state_value_id' : state_value,
                                                'has_blank_option' : 'false'
                                            };
                                cm_params = $.param(cm_params);
                                var urls = js_dropdown_connector_url + '&' + cm_params;
                                ind_combo.clearAll();
                                layout_obj.cells('b').progressOn();
                                ind_combo.load(urls, function() {
                                    var tier_value = grid_obj[id].cells(rId, tier_index).getValue();
                                    ind_combo.show();
                                    if (is_num == false) {
                                        grid_obj[id].cells(rId, tier_index).setValue(tier_value);
                                    } else {
                                        grid_obj[id].cells(rId, tier_index).setValue('');
                                    }
                                    layout_obj.cells('b').progressOff();
                                });
                            }
                        });
                    }
                });
            });
        }

        /*
            # Actions to do when a form is saved
        */
        eligibility_mapping_template.save_value = function (tab_id) {
            var ins_status = 0;
            var del_status = 0;
            var grid_xml = '<GridGroup>';
            var form_xml = '<FormGroup>';
            var win = eligibility_mapping_template.tabbar.cells(tab_id);
            var object_id = (tab_id.indexOf('tab_') != -1) ? tab_id.replace('tab_', '') : tab_id;
            object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(' ', ''));
            var tab_obj = win.tabbar[object_id];
            var detail_tabs = tab_obj.getAllTabs();
            $.each(detail_tabs, function(index, value) {
                layout_obj = tab_obj.cells(value).getAttachedObject();
                layout_obj.forEachItem(function(cell) {
                    attached_obj = cell.getAttachedObject();
                    grid_id = attached_obj.getUserData('', 'grid_id');
                    grid_label = attached_obj.getUserData('', 'grid_label');

                    if (attached_obj instanceof dhtmlXForm) {
                        attached_obj.clearNote('template_name');
                        var template_name = attached_obj.getItemValue('template_name');
                        var form_status = attached_obj.validate();
                        if (form_status == true) {
                            form_xml += '<Form template_id="' + object_id + '"';
                            form_xml += ' template_name="' + template_name + '">';
                            form_xml += '</Form>';
                            form_xml += '</FormGroup>';
                        } else {
                            attached_obj.setNote('template_name', {text: "Required Field"});
                            success_call('<span style="color:red;">One or more data are missing or invalid. Please check.</span>', 'error');
                            return;
                        }
                    }

                    if (attached_obj instanceof dhtmlXGridObject) {
                        //check if rows are deleted or not at first while saving
                        attached_obj.clearSelection();
                        deleted_xml = attached_obj.getUserData('','deleted_xml');

                        if (deleted_xml != null && deleted_xml != '') {
                            grid_xml += '<GridDelete grid_id = "'+ grid_id + '" grid_label = "' + grid_label + '">';
                            grid_xml += deleted_xml;
                            grid_xml += '</GridDelete>';
                            if (delete_grid_name == '') {
                                delete_grid_name = grid_label
                            } else {
                                delete_grid_name += ',' + grid_label
                            }
                            del_status = 1;
                        }

                        var ids = attached_obj.getChangedRows();

                        if (ids != '') {
                            attached_obj.clearSelection();
                            attached_obj.setSerializationLevel(false,false,true,false,true,true);
                            var grid_status = eligibility_mapping_template.validate_grid(attached_obj, grid_label);
                            grid_xml += '<Grid grid_id="' + grid_id + '">';
                            var changed_ids = [];
                            changed_ids = ids.split(',');
                            if (grid_status) {
                                $.each(changed_ids, function(index, value) {
                                    grid_xml += '<GridRow ';

                                    var template_detail_index = attached_obj.getColIndexById('template_detail_id');
                                    var juri_index = attached_obj.getColIndexById('state_value_id');
                                    var tier_index = attached_obj.getColIndexById('tier_id');
  
                                    var template_detail_id = attached_obj.cells(value, template_detail_index).getValue();
                                    var juri_value = attached_obj.cells(value, juri_index).getValue();
                                    var tier_value = attached_obj.cells(value, tier_index).getValue();

                                    if (template_detail_id == '') {
                                        //insert mode
                                        grid_xml += ' template_id = "' + object_id +'"';
                                        grid_xml += ' state_value_id = "' + juri_value +'"';
                                        grid_xml += ' tier_id = "' + tier_value +'"';
                                        grid_xml += " ></GridRow> "; 
                                        ins_status = 1;
                                    } else {
                                        //update mode
                                        grid_xml += ' template_detail_id = "' + template_detail_id +'"';
                                        grid_xml += ' template_id = "' + object_id +'"';
                                        grid_xml += ' state_value_id = "' + juri_value +'"';
                                        grid_xml += ' tier_id = "' + tier_value +'"';
                                        grid_xml += " ></GridRow> ";
                                        upd_status = 1;
                                    }
                                });
                                grid_xml += '</Grid>';
                            }
                            
                        }
                        grid_xml += '</GridGroup>';
                    }                    
                });
            });
            // Build Final XML
            
            var xml = '<Root object_id = "' + object_id + '">';
            xml += form_xml;
            xml += grid_xml;
            xml += '</Root>';
            xml = xml.replace(/'/g, "\"");
            //alert(xml);
            var data_iud = { 'action': 'spa_eligibility_mapping', 'flag': 'i', 'xml': xml };
            if (del_status == 1) {
                //case with deletion
                result = adiha_post_data('confirm', data_iud, '', '', 'eligibility_mapping_template.post_callback', '', 'Some data has been deleted from Eligibility Mapping grid. Are you sure you want to save?');
                return;
            }
            result = adiha_post_data('alert', data_iud, '', '', 'eligibility_mapping_template.post_callback');
        }

        /*
            # Actions to do when a grid needs to be validated. Called before saving. (provided grid object)
        */
        eligibility_mapping_template.validate_grid = function(attached_obj, grid_label) {
            var status = true;
            for (var i = 0; i < attached_obj.getRowsNum(); i++) {
                var row_id = attached_obj.getRowId(i);
                var no_of_child = ""; 
                for (var j = 0; j < attached_obj.getColumnsNum(); j++) {
                    var type = attached_obj.getColType(j);
                    if (type == "combo") {
                        combo_obj = attached_obj.getColumnCombo(j);
                        var value = attached_obj.cells(row_id, j).getValue();
                        if (value == '') {
                            var message = "Invalid Data";
                            attached_obj.cells(row_id,j).setAttribute("validation", message);
                            attached_obj.cells(row_id, j).cell.className = " dhtmlx_validation_error";
                        } else {
                            if (combo_obj.getIndexByValue(value) == -1) {
                                var message = "Invalid Data";
                                attached_obj.cells(row_id,j).setAttribute("validation", message);
                                attached_obj.cells(row_id, j).cell.className = " dhtmlx_validation_error";
                            } else {
                                attached_obj.cells(row_id,j).setAttribute("validation", "");
                                attached_obj.cells(row_id, j).cell.className = attached_obj.cells(row_id, j).cell.className.replace(/[ ]*dhtmlx_validation_error/g, "");
                            }                        
                        }
                    }
                    var validation_message = attached_obj.cells(row_id,j).getAttribute("validation");
                    if(validation_message != "" && validation_message != undefined) {
                        var column_text = attached_obj.getColLabel(j);
                        error_message = "Data Error in <b>Elibigility Mapping</b> grid. Please check the data in column <b>"+column_text+"</b> and resave.";
                        dhtmlx.alert({
                            title:"Alert",
                            type:"alert",
                            text: error_message
                        });
                        status = false;
                        break;
                    }
                }

                if(validation_message != "" && validation_message != undefined){
                    break;
                }
            }
            return status;
        }

        /*
            # Actions to do after grid is saved. (Refresh current tab)
        */
        eligibility_mapping_template.refresh_tab_properties = function() {
            var col_type = eligibility_mapping_template.grid.getColType(0);
            var tab_id = eligibility_mapping_template.tabbar.getActiveTab(); //tab_1
            var system_id = eligibility_mapping_template.tabbar.tabs(tab_id).getText(); //Ams Veg Renew
            var tab_index = (tab_id == "") ? null:eligibility_mapping_template.tabbar.tabs(tab_id).getIndex(); //0
            system_id_array = new Array();
            system_id_array = system_id.split(",");
            for (var i = 0; i < system_id_array.length; i++) {
                var primary_value = eligibility_mapping_template.grid.findCell(system_id_array[i], 1, true); //0, 1
                eligibility_mapping_template.grid.filterByAll();
                if (primary_value != "") {
                    if (eligibility_mapping_template.pages[tab_id]) {
                        delete eligibility_mapping_template.pages[tab_id];
                        eligibility_mapping_template.tabbar.cells(tab_id).close(false);
                        eligibility_mapping_template.tabbar.tabs(tab_id).close(false);
                    }
                    var r_id = primary_value.toString().substring(0, primary_value.toString().indexOf(","));
                    eligibility_mapping_template.grid.selectRowById(r_id,false,true,true);
                    eligibility_mapping_template.create_tab(r_id, 0, 0, 0,tab_index);
                }
            }
        }
    </script>
</body>
</html>