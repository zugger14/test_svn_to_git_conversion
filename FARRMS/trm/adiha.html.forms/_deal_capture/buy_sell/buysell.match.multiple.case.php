<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
        <?php require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
    </head>
    <?php
        // No need to sanitize because it takes JSON value.
        $grid_values = isset($_POST['grids']) ? $_POST['grids'] : '';

        $namespace = 'multiple_case_popup';

        $json = '[
                    {
                        id:             "a",
                        text:           "Grid",
                        header:         true,
                        collapse:       false,
                        height:         200
                    }
                ]';

        $form_practice_obj = new AdihaLayout();
        echo $form_practice_obj->init_layout('multiple_case_layout', '', '1C', $json, $namespace);

        $toolbar_name = 'ok_toolbar';
        $toolbar_json = '
                        [
                            {
                                id:"ok",
                                text:"OK",
                                img:"tick.gif",
                                imgdis:"tick_dis.gif",
                                enabled:false
                            }
                        ]';

        

        $menu_obj = new AdihaMenu();
        echo $form_practice_obj->attach_menu_cell($toolbar_name, 'a');
        echo $menu_obj->init_by_attach($toolbar_name, $namespace);
        echo $menu_obj->load_menu($toolbar_json);
        echo $menu_obj->attach_event('', 'onClick', $namespace . '.ok_clicked');
    
        $grid_obj = new AdihaGrid();
        $grid_name = 'multiple_case';
        echo $form_practice_obj->attach_grid_cell($grid_name, 'a');
        $xml_file = "EXEC spa_adiha_grid 's','MultipleCase'";
        $resultset = readXMLURL2($xml_file);
        echo $grid_obj->init_by_attach($grid_name, $namespace);
        echo $grid_obj->set_header($resultset[0]['column_label_list']);
        echo $grid_obj->set_column_alignment($resultset[0]['column_alignment']);
        echo $grid_obj->set_columns_ids($resultset[0]['column_name_list']);
        echo $grid_obj->set_widths($resultset[0]['column_width']);
        echo $grid_obj->set_column_types($resultset[0]['column_type_list']);
        echo $grid_obj->set_sorting_preference($resultset[0]['sorting_preference']);
        echo $grid_obj->set_column_visibility($resultset[0]['set_visibility']);
        echo $grid_obj->return_init();
        echo $grid_obj->load_grid_data("");
        echo $grid_obj->enable_multi_select(true);
        echo $grid_obj->attach_event('', 'onXLE', $namespace . '.on_grid_load');
        echo $grid_obj->attach_event('', 'onRowSelect', $namespace . '.on_grid_select');
		echo $grid_obj->enable_filter_auto_hide();

        echo $form_practice_obj->close_layout();
    ?>
    <script type="text/javascript">
        var grid_data = '<?php echo $grid_values; ?>';
        var active_tab_id = '<?php echo $active_tab_id;?>';
        var result;

        multiple_case_popup.on_grid_select = function(id, ind) {
            multiple_case_popup.ok_toolbar.setItemEnabled('ok');
        }

        multiple_case_popup.on_grid_load = function(grid_obj, count) {
            grid_data = JSON.parse(grid_data);
            //console.log(grid_data);
            $.each(grid_data, function(ind, value) {
                grid_obj.addRow(ind + 1, '');
                grid_obj.setRowData(ind + 1, grid_data[ind]);
            });
        }

        multiple_case_popup.ok_clicked = function(id) {
            var form_obj = parent.buy_sell_deal_match_ui.form_link;
            var grid_obj_current = multiple_case_popup.multiple_case;
            var grid_obj_left = parent.buy_sell_deal_match_ui.left_grid_ui;
            var grid_obj_right = parent.buy_sell_deal_match_ui.right_grid_ui;

            var process_id_right_grid = form_obj.getItemValue('process_id');
            var total_matched_volume1 = parseFloat(parent.$('#mt_q1').text().replace(',',''));
            var total_matched_volume2 = parseFloat(parent.$('#mt_q2').text().replace(',',''));
            var total_matched_volume = (total_matched_volume1 < total_matched_volume2) ? total_matched_volume1 : total_matched_volume2;
            var form_xml = "<FormXML ";
            var form_data = form_obj.getFormData();

            /* # Added logic to set match status on save */
            var match_status = "";
            var remaining_deal_value = parent.document.getElementById("rm_q1").innerHTML.replace(',', '');
            var actual_deal_value1 = parent.document.getElementById("av_q1").innerHTML.replace(',', '');
            var matched_deal_value1 = parent.document.getElementById("mt_q1").innerHTML.replace(',', '');
            var actual_deal_value2 = parent.document.getElementById("av_q2").innerHTML.replace(',', '');
            var matched_deal_value2 = parent.document.getElementById("mt_q2").innerHTML.replace(',', '');

            if (parseFloat(actual_deal_value1) < parseFloat(matched_deal_value1) || parseFloat(actual_deal_value2) < parseFloat(matched_deal_value2)) {
                match_status = 27209;
            } else if (parseFloat(remaining_deal_value) > 0) {
                match_status = 27207;
            } else if (parseFloat(remaining_deal_value) == 0 || parseFloat(remaining_deal_value) >= 0) {
                match_status = 27201;
            }

            for (var a in form_data) {
                field_label = a;
                field_value = form_data[a];
                if (form_obj.getItemType(field_label) == 'calendar') {
                    field_value = form_obj.getItemValue(field_label, true);
                } else if (field_label == 'match_status' && match_status != "") {
                    field_value = match_status;
                }
                form_xml += " " + field_label + "=\"" + field_value + "\"";
            }
            form_xml += " total_matched_volume =\"" + total_matched_volume + "\"";
            form_xml += "></FormXML>";

            var grid_xml = "<Grid>";
            var inner_grid_xml1 = '';
            var inner_grid_xml2 = '';

            /**Dealset1 xml**/
            for (var row_id1 = 0; row_id1 < grid_obj_left.getRowsNum(); row_id1++) {
                var source_deal_header_id_index1 = grid_obj_left.getColIndexById("source_deal_header_id");
                var deal_id_index1 = grid_obj_left.getColIndexById("source_deal_detail_id");
                var matched_index1 = grid_obj_left.getColIndexById("matched");
                if (grid_obj_left.cells2(row_id1, matched_index1).getValue() != 0) {
                    inner_grid_xml1 += '<GridRow ';
                    inner_grid_xml1 += ' source_deal_header_id="' + grid_obj_left.cells2(row_id1, source_deal_header_id_index1).getValue() + '"';
                    inner_grid_xml1 += ' source_deal_detail_id="' + grid_obj_left.cells2(row_id1, deal_id_index1).getValue()
                                        + '" matched="' + grid_obj_left.cells2(row_id1, matched_index1).getValue()
                                        + '" vintage_year= "" expiration_date= "" state_value_id= "" tier_value_id="'
                                        + '" sequence_from="'
                                        + '" sequence_to="'
                                        + '" set_id="1"';
                    inner_grid_xml1 += '></GridRow>';
                }
            }

            var sel_row_id = grid_obj_current.getSelectedRowId();
            sel_row_id = sel_row_id.split(',');
            var cmb_deal_seq_arr = [];

            // Validation when user selects multiple jurisdiction for single deal
            /*Validation Starts*/
            var validate_current_grid_sdh_id = [];
            var is_correct = true;

            for(i = 0; i < sel_row_id.length; i++) {
                validate_current_grid_sdh_id.push(grid_obj_current.cells(sel_row_id[i], 1).getValue());
            }

            validate_current_grid_sdh_id.sort();
            $.each(validate_current_grid_sdh_id, function(i,j) {
                if (validate_current_grid_sdh_id[i] == validate_current_grid_sdh_id[i+1]) {
                    is_correct = false;                    
                }
            });

            if (is_correct == false) {
                show_messagebox('Please select single product data for each <b>Buy Deal.</b>');
                return;
            }

            var all_detail_ids = [];
            var selected_detail_ids = [];
            var difference_detail_ids;

            multiple_case_popup.multiple_case.forEachRow(function(i) {
                all_detail_ids.push(multiple_case_popup.multiple_case.getRowData(i).buy_deal_detail_id);
            });
            all_detail_ids = _.uniq(all_detail_ids);

            var selected_rows_juris = multiple_case_popup.multiple_case.getSelectedRowId();
            selected_rows_juris = selected_rows_juris.split(',');

            $.each(selected_rows_juris, function(k, l) {
                selected_detail_ids.push(multiple_case_popup.multiple_case.getRowData(l).buy_deal_detail_id);
            });
            selected_detail_ids = _.uniq(selected_detail_ids);

            difference_detail_ids = _.difference(all_detail_ids, selected_detail_ids);

            if (difference_detail_ids.length != 0) {
                show_messagebox('Please select product data for each <b>Buy Deal.</b>');
                return;
            }
            /*Validation Ends*/

            /**Dealset2 xml**/
            // Build XML which does have multiple jurisdiction/tier
            grid_obj_right.forEachRow(function(id) {
                var row_data = parent.buy_sell_deal_match_ui.right_grid_ui.getRowData(id);
                var right_grid_sdh_seq_id = row_data.source_deal_detail_id + '_' + row_data.sequence_from;

                for(i = 0; i < sel_row_id.length; i++) {
                    var current_grid_sdh_seq_id = grid_obj_current.cells(sel_row_id[i], 1).getValue() + '_' + grid_obj_current.cells(sel_row_id[i], 12).getValue();
                    // alert('first check ' + created_arr + ' and ' + current_grid_sdh_id + ' ra ' + right_grid_sdh_id);
                    if (cmb_deal_seq_arr.indexOf(current_grid_sdh_seq_id) === -1 ) {
                        // alert(row_data.source_deal_detail_id)
                        if (right_grid_sdh_seq_id == current_grid_sdh_seq_id) {
                            if (row_data.matched != 0) {
                                inner_grid_xml2 += '<GridRow ';
                                inner_grid_xml2 += ' source_deal_header_id="' + row_data.source_deal_header_id +'"';
                                inner_grid_xml2 += ' source_deal_detail_id="' + row_data.source_deal_detail_id
                                                + '" matched="' + row_data.matched
                                                + '" vintage_year="' + row_data.vintage_year
                                                + '" expiration_date="' + row_data.expiration_date
                                                + '" actual_volume="' + row_data.actual_volume
                                                + '" remaining="' + row_data.remaining
                                                + '" state_value_id="' + grid_obj_current.cells(sel_row_id[i], grid_obj_current.getColIndexById("state_value_id")).getValue()
                                                + '" tier_value_id="' + grid_obj_current.cells(sel_row_id[i], grid_obj_current.getColIndexById("tier_value_id")).getValue()
                                                + '" sequence_from="' + grid_obj_current.cells(sel_row_id[i],grid_obj_current.getColIndexById("sequence_from")).getValue()
                                                + '" sequence_to="' + grid_obj_current.cells(sel_row_id[i], grid_obj_current.getColIndexById("sequence_to")).getValue()
                                                + '" set_id="2"';
                                inner_grid_xml2 += '></GridRow>';
                                cmb_deal_seq_arr.push(row_data.source_deal_detail_id + '_' +  grid_obj_current.cells(sel_row_id[i],grid_obj_current.getColIndexById("sequence_from")).getValue());
                            }
                        }
                    }
                }
            });

            // Build XML which doesnot have multiple jurisdiction/tier
            grid_obj_right.forEachRow(function(id) {
                var row_data = parent.buy_sell_deal_match_ui.right_grid_ui.getRowData(id);
                var right_grid_sdh_seq_id = row_data.source_deal_detail_id + '_' + row_data.sequence_from;
                for(i = 0; i < sel_row_id.length; i++) {
                    var current_grid_sdh_seq_id = grid_obj_current.cells(sel_row_id[i], 1).getValue() + '_' + grid_obj_current.cells(sel_row_id[i], 12).getValue();
                    // alert('first check ' + created_arr + ' and ' + current_grid_sdh_id + ' ra ' + right_grid_sdh_id);
                    if (cmb_deal_seq_arr.indexOf(right_grid_sdh_seq_id) === -1 ) {
                        if (right_grid_sdh_seq_id != current_grid_sdh_seq_id) {
                            if (row_data.matched != 0) {
                                inner_grid_xml2 += '<GridRow ';
                                inner_grid_xml2 += ' source_deal_header_id="' + row_data.source_deal_header_id +'"';
                                inner_grid_xml2 += ' source_deal_detail_id="' + row_data.source_deal_detail_id
                                                + '" matched="' + row_data.matched
                                                + '" vintage_year="' + row_data.vintage_year 
                                                + '"  expiration_date="' + row_data.expiration_date
                                                + '"  actual_volume="' + row_data.actual_volume
                                                + '"  remaining="' + row_data.remaining
                                                + '"  state_value_id= "" tier_value_id="'
                                                + '" sequence_from="' + row_data.sequence_from
                                                + '" sequence_to="' + row_data.sequence_to
                                                + '" set_id="2"';
                                inner_grid_xml2 += '></GridRow>';
                                cmb_deal_seq_arr.push(row_data.source_deal_detail_id + '_' + row_data.sequence_from);
                            }
                        }
                    }
                }
            });
          
            if (inner_grid_xml1 == '' || inner_grid_xml2 == '') {
                validate_return = false;
                error_json =  {title: 'Error', type: 'alert-error', text: 'Empty Grid Row fetched.'};
                return error_json;
            }
            
            grid_xml += inner_grid_xml1 + inner_grid_xml2;
            grid_xml += "</Grid>";
            var xml = "<Root>";
            xml += form_xml;
            xml += grid_xml;
            xml += "</Root>";
            xml = xml.replace(/'/g, "\"");

            var data = {
                    "action" : "spa_buy_sell_match",
                    "flag" : 'i',
                    "link_id" : form_obj.getItemValue('link_id'),
                    "xmlValue" : xml,
                    "process_id" : process_id_right_grid
                }
            /*console.log(grid_xml);
			return;*/
            parent.show_popup_window = 0; //resetted the value to show/hide common product popup
            result = adiha_post_data('return_json', data, '', '', 'parent.buy_sell_deal_match_ui.save_matched_deals_callback');
        }
    </script>
    <body>
    </body>
</html>