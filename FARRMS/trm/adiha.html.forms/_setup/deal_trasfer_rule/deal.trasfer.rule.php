<?php
/**
* Deal trasfer rule screen
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
            $application_function_id = 20005600;
            $form_namespace = "deal_trasfer_rule";

            $form_obj = new AdihaStandardForm($form_namespace, $application_function_id);
            $form_obj->define_grid("deal_trasfer_rule", "");

            $form_obj->define_custom_functions('', '', '', 'load_complete','validate_criteria_grid');

            echo $form_obj->init_form("Deal Transfer Rule", "Deal Transfer Rule");
            echo $form_obj->close_form();
        ?>

        <script>
            // Override load complete function
            /* Offset criteria columns*/
            var col_sub_book = null;
            var col_trader_id = null;
            var col_counterparty_id = null;
            var col_contract_id = null;
            var col_template_id = null;

            /* Transfer criteria columns*/
            var col_transfer_sub_book = null;
            var col_transfer_trader_id = null;
            var col_transfer_counterparty_id = null;
            var col_transfer_contract_id = null;
            var col_transfer_template_id = null;

            /* Other columns*/
            var col_pricing_options = null;
            var col_fixed_price = null;
            var col_index_adder = null;
            var col_fixed_adder = null;
            var col_location_id = null;

            deal_trasfer_rule.load_complete = function(win, id) {
                var tab_object = win.getAttachedObject();
                var form_object = '';
                var grid_object = '';
                tab_object.forEachTab(function(cell) {
                    if (cell.getText() == get_locale_value('General')) {
                        var layout_object = cell.getAttachedObject();
                        var attached_object = layout_object.cells('a').getAttachedObject();
                        if (attached_object instanceof dhtmlXForm) {
                            form_object = attached_object;
                        }
                        attached_object = layout_object.cells('b').getAttachedObject();
                        if (attached_object instanceof dhtmlXGridObject) {
                            grid_object = attached_object;
                        }
                    }
                });

                /* Offset criteria columns*/
                col_sub_book = grid_object.getColIndexById('sub_book');
                col_trader_id = grid_object.getColIndexById('trader_id');
                col_counterparty_id = grid_object.getColIndexById('counterparty_id');
                col_contract_id = grid_object.getColIndexById('contract_id');
                col_template_id = grid_object.getColIndexById('template_id');

                /* Transfer criteria columns*/
                col_transfer_sub_book = grid_object.getColIndexById('transfer_sub_book');
                col_transfer_trader_id = grid_object.getColIndexById('transfer_trader_id');
                col_transfer_counterparty_id = grid_object.getColIndexById('transfer_counterparty_id');
                col_transfer_contract_id = grid_object.getColIndexById('transfer_contract_id');
                col_transfer_template_id = grid_object.getColIndexById('transfer_template_id');

                /* Other Columns */
                col_pricing_options = grid_object.getColIndexById('pricing_options');
                col_fixed_price = grid_object.getColIndexById('fixed_price');
                col_index_adder = grid_object.getColIndexById('index_adder');
                col_fixed_adder = grid_object.getColIndexById('fixed_adder');
                col_location_id = grid_object.getColIndexById('location_id');

                reset_blocks(form_object,grid_object, 'transfer');

                /* Always hide columns Template columns by default */
                grid_object.setColumnHidden(col_template_id,true);
                grid_object.setColumnHidden(col_transfer_template_id,true);

                form_object.attachEvent('onChange', function(name, value, state){
                    if (name == 'transfer') {
                        reset_blocks(form_object,grid_object, name);
                    }
                });

                grid_object.attachEvent("onRowAdded", function(rId){
                    var col_transfer_date= grid_object.getColIndexById('transfer_date');
                    var col_volume_per = grid_object.getColIndexById('volume_per');
                    grid_object.cells(rId,col_transfer_date).setValue(new Date());
                    // grid_object.cells(rId,col_volume_per).setValue(100);
                });

                grid_object.attachEvent("onXLE", function(grid_obj1,count){
                    grid_obj1.forEachRow(function(rId){
                        grid_obj1.forEachCell(rId,function(cellObj,ind){
                            grid_obj1.validateCell(rId,ind);
                            grid_obj1.cells(rId, ind).cell.wasChanged = true;
                            if (ind == col_pricing_options) { //Pricing Pptions
                                var value_pricing_options = grid_object.cells(rId,col_pricing_options).getValue();
                                deal_trasfer_rule.hide_show_columns(grid_object,value_pricing_options,rId);
                            }
                        });
                    });

                    /* Attaching event after exisitng data has been loaded */
                    grid_obj1.attachEvent("onCellChanged", function(rId,cInd,nValue){
                        if (cInd == col_pricing_options) { //Pricing Pptions
                            deal_trasfer_rule.hide_show_columns(grid_object,nValue,rId);
                        } else if (cInd == col_sub_book) {
                            deal_trasfer_rule.dropdown_select(col_sub_book,nValue,rId);
                        } else if (cInd == col_counterparty_id || cInd == col_transfer_counterparty_id) {
                            deal_trasfer_rule.dropdown_select(cInd,nValue,rId);
                        }
                    });
                });

            }

            /**
             * Reset Offset/Transfer block
             * @param  {Object} form_object Form Object
             * @param  {Object} grid_object Form Object
             * @param  {String} combo_name  Name of combo
             */
            function reset_blocks(form_object,grid_object, combo_name) {
                var transfer_value = form_object.getItemValue(combo_name);
                var show_offset = false; // true/false to hide/show a column
                var show_transfer = false;

                if (transfer_value == 'o') {
                    show_offset = false;
                    show_transfer = true;
                } else if (transfer_value == 'x') {
                    show_offset = true;
                    show_transfer = false;
                } else {
                    show_offset = false;
                    show_transfer = false;
                }
                /* Show/hide offset criteria columns*/
                grid_object.setColumnHidden(col_sub_book,show_offset);
                grid_object.setColumnHidden(col_trader_id,show_offset);
                grid_object.setColumnHidden(col_counterparty_id,show_offset);
                grid_object.setColumnHidden(col_contract_id,show_offset);
                grid_object.setColumnHidden(col_template_id,show_offset);

                /* Show/hide transfer criteria columns*/
                grid_object.setColumnHidden(col_transfer_sub_book,show_transfer);
                grid_object.setColumnHidden(col_transfer_trader_id,show_transfer);
                grid_object.setColumnHidden(col_transfer_counterparty_id,show_transfer);
                grid_object.setColumnHidden(col_transfer_contract_id,show_transfer);
                grid_object.setColumnHidden(col_transfer_template_id,show_transfer);

                /* Always hide column location id*/
                grid_object.setColumnHidden(col_location_id,true);
            }

            /**
             * Show or Hide Fildset According to Fieldset Label.
             * @param  {String} fieldset_label  Label of Fieldset
             * @param  {Boolean} status         Show/Hide Fieldset (true/false)
             */
            function show_hide_fieldset(fieldset_label, status) {
                $('.fs_legend').each(function(e, el) {
                    if ($(el).text() == fieldset_label) {
                        if (status === true) {
                            $(el).parent().parent().parent().show();
                        } else {
                            $(el).parent().parent().parent().hide();
                        }
                    }
                });
            }

            deal_trasfer_rule.validate_criteria_grid = function() {
                var active_tab_id = deal_trasfer_rule.tabbar.getActiveTab();
                var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
                var tab_obj = deal_trasfer_rule.tabbar.cells(active_tab_id).getAttachedObject();
                var valid_status = true;
                var form_object = '';
                var grid_object = '';
                tab_obj.forEachTab(function(cell) {
                    if (cell.getText() == get_locale_value('General')) {
                        var layout_object = cell.getAttachedObject();
                        var attached_object = layout_object.cells('a').getAttachedObject();
                        if (attached_object instanceof dhtmlXForm) {
                            form_object = attached_object;
                        }
                        attached_object = layout_object.cells('b').getAttachedObject();
                        if (attached_object instanceof dhtmlXGridObject) {
                            grid_object = attached_object;
                        }
                        var count = grid_object.getRowsNum();
                        /* Validation whnen no criteria is inserted */
                        if (count == 0) {
                            show_messagebox("Enter at least one criteria.");
                            valid_status = false;
                            return false;
                        }

                        /* Validation whnen no criteria is inserted */
                        var col_transfer_volume = grid_object.getColIndexById('transfer_volume');
                        var col_volume_per = grid_object.getColIndexById('volume_per');
                        grid_object.forEachRow(function(id){
                            var val_transfer_volume = grid_object.cells(id,col_transfer_volume).getValue();
                            var val_volume_per = grid_object.cells(id,col_volume_per).getValue();
                            if ((val_transfer_volume == '') && (val_volume_per == '')) {
                                count = -1;
                                valid_status = false;
                            }

                            if (val_volume_per != '' && (val_volume_per < 0 || val_volume_per > 100)) {
                                count = -2;
                                valid_status = false;
                            }

                        });
                        if (count == -1) {
                            show_messagebox("Enter either <b>Transfer Volume</b> or <b>Volume%</b>.");
                        } else if (count == -2) {
                            show_messagebox("<b>Volume%</b> must be between 0 and 100.");
                        }

                    }
                });

                if (!valid_status)
                    return 0;

                return 1;
            }


            deal_trasfer_rule.validate_form_grid = function(attached_obj,grid_label,call_from) {
                var active_tab_id = deal_trasfer_rule.tabbar.getActiveTab();
                var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
                var tab_obj = deal_trasfer_rule.tabbar.cells(active_tab_id).getAttachedObject();
                var form_object = '';
                tab_obj.forEachTab(function(cell) {
                    if (cell.getText() == get_locale_value('General')) {
                        var layout_object = cell.getAttachedObject();
                        var attached_object = layout_object.cells('a').getAttachedObject();
                        if (attached_object instanceof dhtmlXForm) {
                            form_object = attached_object;
                        }
                    }
                });

                var transfer = form_object.getItemValue('transfer');
                var offset_columns = [col_sub_book,col_trader_id,col_counterparty_id,col_contract_id,col_template_id];
                var transfer_columns = [col_transfer_sub_book,col_transfer_trader_id,col_transfer_counterparty_id,col_transfer_contract_id,col_transfer_template_id];

                var status = true;
                for (var i = 0;i < attached_obj.getRowsNum();i++){
                    var row_id = attached_obj.getRowId(i);
                    var no_of_child = "";
                    if (call_from == "deal") {
                        no_of_child =  attached_obj.hasChildren(row_id);
                    }
                    call_from = (call_from && typeof call_from != "undefined") ? call_from : "";
                    if (call_from == "" || (call_from == "deal" && no_of_child == 0)) {
                        for (var j = 0;j < attached_obj.getColumnsNum();j++){
                            if (transfer == 'o' && $.inArray(j, transfer_columns) != -1) {
                                attached_obj.cells(row_id, j).cell.className = attached_obj.cells(row_id, j).cell.className.replace(/[ ]*dhtmlx_validation_error/g, "");
                                continue;
                            }
                            if (transfer == 'x' && $.inArray(j, offset_columns) != -1) {
                                attached_obj.cells(row_id, j).cell.className = attached_obj.cells(row_id, j).cell.className.replace(/[ ]*dhtmlx_validation_error/g, "");
                                continue;
                            }

                            var type = attached_obj.getColType(j);
                            if (type == "combo") {
                                combo_obj = attached_obj.getColumnCombo(j);
                                var value = attached_obj.cells(row_id,j).getValue();
                                if (combo_obj.getOptionsCount() != 0 && value != "") {
                                    var selected_option = combo_obj.getIndexByValue(value);
                                    if (selected_option == -1) {
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
                            if(validation_message != "" && validation_message != undefined){
                                var column_text = attached_obj.getColLabel(j);
                                error_message = "Data Error in <b>"+grid_label+"</b> grid. Please check the data in column <b>"+column_text+"</b> and resave.";
                                show_messagebox(error_message);
                                status = false; break;
                            }
                        }
                    }
                    if(validation_message != "" && validation_message != undefined){ break;};
                }
                return status;
            }

            deal_trasfer_rule.hide_show_columns = function (grid_object,val,rId) {
                var show_fixed_price = false;
                var show_index_adder = false;
                var show_fixed_adder = false;
                if (val == 'd') { //Original Deal Price
                    show_fixed_price = true;
                    show_index_adder = true;
                    show_fixed_adder = true;
                } else if (val == 'm') { // Market Price
                    show_fixed_price = true;
                    show_index_adder = false;
                    show_fixed_adder = false;
                } else { // fixed Price or blank
                    show_fixed_price = false;
                    show_index_adder = false;
                    show_fixed_adder = false;
                }
                // /* Hide show columns*/
                // grid_object.setColumnHidden(col_fixed_price,show_fixed_price);
                // grid_object.setColumnHidden(col_index_adder,show_index_adder);
                // grid_object.setColumnHidden(col_fixed_adder,show_fixed_adder);

                /*Disable enable columns*/
                grid_object.cells(rId,col_fixed_price).setDisabled(show_fixed_price);
                grid_object.cells(rId,col_index_adder).setDisabled(show_index_adder);
                grid_object.cells(rId,col_fixed_adder).setDisabled(show_fixed_adder);

            }

            deal_trasfer_rule.dropdown_select = function (col_index,nValue,rId) {
                var active_tab_id = deal_trasfer_rule.tabbar.getActiveTab();
                var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
                var tab_obj = deal_trasfer_rule.tabbar.cells(active_tab_id).getAttachedObject();
                var form_object = '';
                var grid_object = '';
                tab_obj.forEachTab(function(cell) {
                    if (cell.getText() == get_locale_value('General')) {
                        var layout_object = cell.getAttachedObject();
                        var attached_object = layout_object.cells('a').getAttachedObject();
                        if (attached_object instanceof dhtmlXForm) {
                            form_object = attached_object;
                        }
                        attached_object = layout_object.cells('b').getAttachedObject();
                        if (attached_object instanceof dhtmlXGridObject) {
                            grid_object = attached_object;
                        }
                        var value_transfer = form_object.getItemValue('transfer');
                        var data = null;
                        if ((col_index == col_sub_book && value_transfer == 'b') || col_index == col_counterparty_id || col_index == col_transfer_counterparty_id) { //Only in case of xfer with offset
                            if (col_index == col_sub_book) {
                                data = {"action": "spa_transfer_mapping",
                                    "flag": "g",
                                    "sub_book": nValue
                                };
                            } else if (col_index == col_counterparty_id || col_index == col_transfer_counterparty_id) {
                                nValue = grid_object.cells(rId,col_index).getValue();
                                data = {"action": "spa_transfer_mapping",
                                    "flag": "k",
                                    "counterparty_id": nValue
                                };
                            }
                            
                            data = $.param(data);
                            $.ajax({
                                type: "POST",
                                dataType: "json",
                                url: js_form_process_url,
                                async: false,
                                data: data,
                                success: function(data) {
                                    if (data.length > 0) {
                                        response_data = data["json"];
                                        if (col_index == col_sub_book) {
                                            var counterparty_id = response_data[0].counterparty_id;
                                            if (counterparty_id)
                                                grid_object.cells(rId,col_transfer_counterparty_id).setValue(counterparty_id);
                                            else
                                                grid_object.cells(rId,col_transfer_counterparty_id).setValue('');

                                            var contract_id = response_data[0].contract_id;
                                            if (contract_id)
                                                grid_object.cells(rId,col_transfer_contract_id).setValue(contract_id);
                                            else
                                                grid_object.cells(rId,col_transfer_contract_id).setValue('');
                                        } else if (col_index == col_transfer_counterparty_id) {
                                            contract_id = response_data[0].contract_id;
                                            if (contract_id)
                                                grid_object.cells(rId,col_transfer_contract_id).setValue(contract_id);
                                            else
                                                grid_object.cells(rId,col_transfer_contract_id).setValue('');
                                        } else if (col_index == col_counterparty_id) {
                                            contract_id = response_data[0].contract_id;
                                            if (contract_id)
                                                grid_object.cells(rId,col_contract_id).setValue(contract_id);
                                            else
                                                grid_object.cells(rId,col_contract_id).setValue('');
                                        }
                                    }
                                }
                            });
                        }
                    }
                });
            }

        </script>
    </body>
</html>