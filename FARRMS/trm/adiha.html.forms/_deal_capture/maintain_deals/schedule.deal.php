<?php
/**
* Schedule deal screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
<body>
    <?php
        $php_script_loc = $app_php_script_loc;
        $app_user_loc = $app_user_name;
        $form_function_id = 10131028;
        $rights_sch_file_create_add = 10164301;
        $rights_sch_file_delete = 10164302;
        $rights_sch_file_submit = 10164303; //function id of view nomination schedule menu
        $right_add_save_schedule_row = 10131035;
        $right_delete_schedule_row = 10131036;

        list (
            $has_right_sch_file_create_add,
            $has_right_sch_file_delete,
            $has_right_sch_file_submit,
            $has_right_add_save_schedule_row,
            $has_right_delete_schedule_row
        ) = build_security_rights (
            $rights_sch_file_create_add,
            $rights_sch_file_delete,
            $rights_sch_file_submit,
            $right_add_save_schedule_row,
            $right_delete_schedule_row
        );

        $has_right_add_save_schedule_row = ($has_right_add_save_schedule_row == '') ? '0' : '1';
    
        $flag = 'i';
        $volume = get_sanitized_value($_GET['volume'] ?? '');
        $rad_value = ($volume > 0) ? 'd' : 'r';
        $location_id = get_sanitized_value($_GET['location_id'] ?? '');
        $term = get_sanitized_value($_GET['term'] ?? '');
        $term_end = get_sanitized_value($_GET['term_end'] ?? '');
        $counterparty_id = get_sanitized_value($_GET['counterparty_id'] ?? '');
        $primary_counterparty_id = get_sanitized_value($_GET['primary_counterparty_id'] ?? 'NULL');
        $source_deal_header_id = get_sanitized_value($_GET['source_deal_header_id'] ?? 'NULL');
        $source_deal_detail_id = get_sanitized_value($_GET['source_deal_detail_id'] ?? 'NULL');
        $deal_id = get_sanitized_value($_GET['deal_id'] ?? '');
        $call_from = get_sanitized_value($_GET['group_by'] ?? 'Deal_Detail');
        $book_deal_type_map_id = get_sanitized_value($_GET['book_deal_type_map_id'] ?? '');
        $option_radio_label_array = array('Deliver', 'Receive');
        $option_radio_value_array = array('d', 'r');
        $available_volume = 0;

        if (($counterparty_id == 0 || $counterparty_id == '') && $source_deal_detail_id != 'NULL') {
            $xml_file = "EXEC spa_getsourcecounterparty @flag='a', @source_system_id=$source_deal_detail_id";
            $return_value = readXMLURL($xml_file);
            $counterparty_id = $return_value[0][0];
        }

        $rad_value = 'd';
        $xml_file = "EXEC spa_get_loss_factor_volume @path=null, @flag='t', @source_deal_header_id=$source_deal_header_id, @source_deal_detail_id=$source_deal_detail_id";

        $return_value = readXMLURL2($xml_file);

        $physical_deal_id = $return_value[0]['source_deal_header_id'];
        $deal_id = $return_value[0]['deal_id'];
        $trader_id = $return_value[0]['trader_id'];
        $total_volume = $return_value[0]['total_volume'];
        $primary_counterparty_id = $return_value[0]['primary_counterparty_id'];
        $entire_term_start = $return_value[0]['entire_term_start'];
        $entire_term_end = $return_value[0]['entire_term_end'];
        $counterparty_id =  $return_value[0]['counterparty_id'];
        $location_id = ($location_id == '') ? $return_value[0]['location_id'] : $location_id;
        $uom = $return_value[0]['deal_volume_uom_id'];
	
        $volume = $available_volume;       //not in use

        if ($rad_value == 'd') {
            $xml_file = "EXEC spa_delivery_path @flag='s', @from_location=$location_id";
        } else if ($rad_value == 'r') {
            $xml_file = "EXEC spa_delivery_path @flag=s, @to_location=$location_id";
        }
        $return_value = readXMLURL($xml_file);

        $physical_path = isset($return_value[0][0]) ? $return_value[0][0] : 'NULL';

        if ($call_from == 'NULL' || $call_from == 'null' || $call_from == ''){
            $call_from = 'Deal';
        }

        $form_namespace = 'sch';

        $json = "[
            {
                id:         'a',
                text:       'Filters',
                header:     true,
                collapse:   false,
                    height:     150
            },
            {
                id:         'b',
                text:       'Schedules',
                header:     true,
                    collapse:   false,
                    height:     200
                },
                {
                    id:         'c',
                    text:       'Re-Schedules',
                    header:     true,
                    collapse:   true
            }

        ]";


        $sch_obj = new AdihaLayout();
    echo $sch_obj->init_layout('sch_layout', '', '3E', $json, $form_namespace);

        $xml_file = "EXEC spa_create_application_ui_json @flag='j'
            , @application_function_id='$form_function_id'
            , @template_name='schedule_deal'
            , @dynamic_filter_xml = '<fields>
                    <field field_id=\"location\">
                        <filter filter_id=\"source_deal_header_id\" value= \"$source_deal_header_id\" />
                        <filter filter_id=\"source_deal_detail_id\" value= \"$source_deal_detail_id\" />
                    </field>
                    <field field_id=\"leg\">
                        <filter filter_id=\"source_deal_header_id\" value= \"$source_deal_header_id\" />
                        <filter filter_id=\"source_deal_detail_id\" value= \"$source_deal_detail_id\" />
                    </field>
                    <field field_id=\"priority\">
                        <filter filter_id=\"source_deal_header_id\" value= \"$source_deal_header_id\" />
                        <filter filter_id=\"source_deal_detail_id\" value= \"$source_deal_detail_id\" />
                    </field>
                </fields>
            '
        ";

        $return_value1 = readXMLURL2($xml_file);
        $form_json = $return_value1[0]['form_json'];
        $tab_id = $return_value1[0]['tab_id'];

        echo $sch_obj->attach_form('sch_form', 'a');
        $sch_form = new AdihaForm();
        echo $sch_form->init_by_attach('sch_form', $form_namespace);
        echo $sch_form->load_form($form_json);

        $menu_json = '[
            {id: "refresh", text: "Refresh", img: "refresh.gif", img_disabled: "refresh_dis.gif", enabled: true},
            {id: "menu_action", text: "Action", img: "action.gif", img_disabled: "action_dis.gif", enabled: true,
            items: [
                {id: "insert_deal_sch", text: "Add Row", img: "add.gif", img_disabled: "add_dis.gif", enabled: ' . (int) $has_right_add_save_schedule_row . '},
                {id: "delete_grid_row", text: "Delete Row", img: "delete.gif", img_disabled: "delete_dis.gif", enabled: 0},
                {id: "delete_deal_sch", text: "Delete Schedule", img: "delete.gif", img_disabled: "delete_dis.gif", enabled: 0}
            ]},
            {id: "process_deal_sch", text: "Save Schedule", img: "run_view_schedule.gif", img_disabled: "run_view_schedule_dis.gif", enabled: 0},
            {id: "process_deal_resch", text: "Save Re-Schedule", img: "run_view_schedule.gif", img_disabled: "run_view_schedule_dis.gif", enabled: 0},
            {id:"html", text:"Export", img:"export.gif", imgdis:"export_dis.gif", title: "Export"}
        ]';

        echo $sch_obj->attach_menu_layout_cell('sch_menu', 'b', $menu_json, $form_namespace.'.menu_click');

        //attach sch grid
        $sch_grid_name = 'sch_grid';
        echo $sch_obj->attach_grid_cell($sch_grid_name, 'b');
        $sch_grid_obj = new AdihaGrid();

        echo $sch_grid_obj->init_by_attach($sch_grid_name, $form_namespace);

        $column_text = "Path,&nbsp;,Contract,Storage Contract,Flow Date From,Flow Date To,Scheduled Volume,Fuel Charge,Delivered Volume,Total Sch Vol,Shrinkage,Total Del Vol,Location From,Location To,Book,Volume Frequency,Shipping Counterparty,Receiving Counterparty,Trans ID,Is MR,Available Volume,Deal ID,delivery_path_detail_id,Process ID,row_number,Rescheduled Flag";
        $column_id = "Path,sub,Contract,storage_contract,Flow Date From,Flow Date To,Scheduled Volume,Fuel Charge,Delivered Volume,Total Sch Vol,Shrinkage,Total Del Vol,Location From,Location To,Book,Volume Frequency,Shipping Counterparty,Receiving Counterparty,Trans ID,Is MR,Available Volume,Deal ID,delivery_path_detail_id,Process ID,row_number,Rescheduled Flag";
        $column_width = "250,50,130,130,100,100,120,100,110,90,70,90,150,150,150,130,180,180,80,310,200,200,200,200,100,100";
        $column_type = "combo,sub_row_grid,combo,combo,dhxCalendarA,dhxCalendarA,ed_v,ro,ro_v,ro_v,ed,ro_v,combo,combo,combo,ro,combo,combo,ro,combo,ro,ro,ro,ro,ro,ro";
        $column_visbility = "false,false,true,true,false,false,true,true,true,false,true,false,true,true,false,true,false,false,true,false,true,true,true,true,true,true";
        
        echo $sch_grid_obj->set_header($column_text);
        echo $sch_grid_obj->set_columns_ids($column_id);
        echo $sch_grid_obj->set_widths($column_width);
        echo $sch_grid_obj->enable_multi_select(true);
        echo $sch_grid_obj->set_column_types($column_type);
        echo $sch_grid_obj->set_column_visibility($column_visbility);
        echo $sch_grid_obj->set_date_format($date_format, "%Y-%m-%d");

        echo $sch_grid_obj->return_init();
        echo $sch_grid_obj->enable_header_menu();

    //attach resch grid
    $resch_grid_name = 'resch_grid';
    echo $sch_obj->attach_grid_cell($resch_grid_name, 'c');
    $resch_grid_obj = new AdihaGrid();
    //echo $sch_obj->attach_status_bar("b", true);
    echo $resch_grid_obj->init_by_attach($resch_grid_name, $form_namespace);

    echo $resch_grid_obj->set_header($column_text);
    echo $resch_grid_obj->set_columns_ids($column_id);
    echo $resch_grid_obj->set_widths($column_width);
    echo $resch_grid_obj->set_column_types($column_type);
    echo $resch_grid_obj->set_column_visibility($column_visbility);
    //echo $resch_grid_obj->set_search_filter(false, '#daterange_filter,#text_filter,#text_filter, , ,#text_filter, ');
    echo $resch_grid_obj->set_date_format($date_format, "%Y-%m-%d");

    echo $resch_grid_obj->return_init();
    echo $resch_grid_obj->enable_header_menu();

    //echo $resch_grid_obj->attach_event('', 'onRowDblClicked', $form_namespace.'.create_invoice_detail_tab');
    //echo $resch_grid_obj->attach_event('', 'onRowSelect', $form_namespace.'.invoice_grid_select');
    //attach grid ends

        echo $sch_obj->close_layout();
    ?>

</body>

    <script>
        dhx_wins = new dhtmlXWindows();
        get_param = {};
        form_function_id = '<?php echo $form_function_id; ?>';
        has_right_sch_file_create_add = Boolean('<?php echo $has_right_sch_file_create_add; ?>');
        has_right_add_save_schedule_row = Boolean('<?php echo $has_right_add_save_schedule_row; ?>');
        has_right_delete_schedule_row = Boolean('<?php echo $has_right_delete_schedule_row; ?>');
        var row_count_first;
        is_add_clicked = false;
        var php_script_loc = '<?php echo $php_script_loc; ?>';

        get_param.term_start = '<?php echo $entire_term_start; ?>';
        get_param.term_end = '<?php echo $entire_term_end; ?>';
        get_param.deal_id = '<?php echo $source_deal_header_id; ?>';
        get_param.deal_detail_id = '<?php echo $source_deal_detail_id; ?>';
        get_param.deal_ref_id = '<?php echo $deal_id; ?>';
        get_param.location_id = '<?php echo $location_id; ?>';
        get_param.counterparty = '<?php echo $counterparty_id; ?>';
        get_param.trader_id = '<?php echo $trader_id; ?>';
        get_param.uom = '<?php echo $uom; ?>';
        get_param.total_volume = '<?php echo $total_volume; ?>';
        get_param.path_id = '<?echo $physical_path; ?>';
        get_param.call_from = '<?echo $call_from; ?>';
        get_param.primary_counterparty_id = '<?echo $primary_counterparty_id; ?>';
        
        grid_creation_status = {};
        grid_creation_status.status = 0;

        var check_subgrid = new Array();

        $(function() {
            date_obj = new Date();
            date_obj_tomorrow = new Date();
            date_obj_tomorrow.setDate(date_obj.getDate() + 1);

            attach_browse_event('sch.sch_form');
            sch.fx_grid_other_initialization(sch.sch_grid);

            sch.fx_grid_other_initialization(sch.resch_grid);
            sch.fx_attach_events(sch.sch_grid);
            sch.fx_attach_events(sch.resch_grid);

            sch.fx_initial_load();
            
            sch.refresh_sch_grid();   
        });
        
        /*
        * Function for grid other initialization.
        */
        sch.fx_grid_other_initialization = function(grid_obj) {
            grid_obj.setNumberFormat('0,000', grid_obj.getColIndexById('Scheduled Volume'), '.', ',');
            grid_obj.setNumberFormat('0,000', grid_obj.getColIndexById('Delivered Volume'), '.', ',');
            grid_obj.setNumberFormat('0,000', grid_obj.getColIndexById('Total Sch Vol'), '.', ',');
            grid_obj.setNumberFormat('0,000', grid_obj.getColIndexById('Total Del Vol'), '.', ',');
        sch.resch_grid.setNoHeader(true);
        };

        /*
        * Function to load initial values to form fields.
        */
        sch.fx_initial_load = function() {
            sch.sch_form.setItemValue('term_start', get_param.term_start);
            sch.sch_form.setItemValue('term_end', get_param.term_end);
            sch.sch_form.setItemValue('deal_id', get_param.deal_id);
            sch.sch_form.setItemValue('deal_ref_id', get_param.deal_ref_id);
            sch.sch_form.setItemValue('location', get_param.location_id);
            sch.sch_form.setItemValue('counterparty', get_param.counterparty);
            sch.sch_form.setItemValue('trader', get_param.trader_id);
            sch.sch_form.setItemValue('uom', get_param.uom);
            sch.sch_form.setItemValue('total_volume', get_param.total_volume);

            sch.sch_load_all_grid_cmbo(sch.sch_grid);
            sch.sch_load_all_grid_cmbo(sch.resch_grid);
        };

        /*
        Function to attach events on schedule grid
        */
        sch.fx_attach_events = function (grid_obj) {
            sch.sch_grid.attachEvent('onRowSelect', function (rid, ind) {
                grid_creation_status.status = 0;
                
                if (has_right_delete_schedule_row){
                    sch.sch_menu.setItemEnabled('delete_deal_sch');
                }
                
                if (sch.sch_grid.cells(rid, sch.sch_grid.getColIndexById('Deal ID')).getValue() != '') {
                    sch.refresh_resch_grid(rid, true);
                    sch.sch_menu.setItemDisabled('process_deal_sch');
                    sch.sch_menu.setItemDisabled('delete_grid_row');
                } else {
                    sch.refresh_resch_grid(rid);
                
                    if (has_right_add_save_schedule_row)
                        sch.sch_menu.setItemEnabled('process_deal_sch');

                    sch.sch_menu.setItemDisabled('delete_deal_sch');

                    if (has_right_add_save_schedule_row)
                        sch.sch_menu.setItemEnabled('delete_grid_row');
                }
            });

        sch.resch_grid.attachEvent('onRowSelect', function(rid, ind) {
            if (has_right_add_save_schedule_row)
                sch.sch_menu.setItemEnabled('process_deal_resch');

        });

            grid_obj.attachEvent('onEditCell', function(stage, rid, cid, n_val, o_val) {
                if (grid_obj.getColumnId(cid) == 'Flow Date From' || grid_obj.getColumnId(cid) == 'Flow Date To') {
                    return true;
                } else if (stage == 2 ) {
                    if (isNaN(n_val) || n_val == '') {
                        return false;
                    } else if (n_val != o_val) {
                        if (grid_obj.getColumnId(cid) == 'Scheduled Volume') {
                            var calc_val = n_val * (1 - grid_obj.cells(rid, grid_obj.getColIndexById('Shrinkage')).getValue());
                            grid_obj.cells(rid, grid_obj.getColIndexById('Delivered Volume')).setValue(calc_val);
                            sch.change_group_path_volume(grid_obj, rid, n_val);                          
                        } else if (grid_obj.getColumnId(cid) == 'Shrinkage') {
                            var schedule_volume = grid_obj.cells(rid, grid_obj.getColIndexById('Scheduled Volume')).getValue()
                            var calc_val = schedule_volume * (1 - n_val);
                            grid_obj.cells(rid, grid_obj.getColIndexById('Delivered Volume')).setValue(calc_val);
                        } else if (grid_obj.getColumnId(cid) == 'Path') {
                            var grid_type = grid_obj.getUserData('', 'grid_type');
                            var call_back_fx = (grid_type == 'sch' ? 'sch.change_path_event_sch' : 'sch.change_path_event_resch');
                            var param = {
                                "action": 'spa_get_loss_factor_volume',
                                "flag": 'l',
                                "term_start": grid_obj.cells(rid, grid_obj.getColIndexById('Flow Date From')).getValue(),
                                "path": n_val
                            };

                            adiha_post_data('return_json', param, '', '', call_back_fx);
                            load_path_contract(sch.sch_grid,rid, n_val);
                            
                            check_subgrid[rid] = true; 
                            if (grid_type == 'sch')
                                sch.subgrid(rid, '', grid_obj, 's');
                            else
                                sch.subgrid(rid, '', grid_obj, 'r');  
                        }
                        return true;
                    }
                }
            });

            grid_obj.attachEvent("onCellChanged", function(stage, rid, cid, n_val, o_val){
                if (grid_obj.getColumnId(cid) == 'Path' && is_add_clicked) {
                }
            });
            
            grid_obj.attachEvent('onXLE', function (grid_obj,count) {
                grid_obj.forEachRow(function(id){ 
                    load_path_contract(sch.sch_grid, id, grid_obj.cells(id, sch.sch_grid.getColIndexById('Path')).getValue()) 
                });
            });
        }

        sch.change_group_path_volume = function(grid_obj, rid, schedule_volume) {
            var sub_grid = grid_obj.cells(rid, 1).getSubGrid();  
            
            if (sub_grid != 'null') {
                if (sub_grid.getRowsNum() != 0) {
                    sub_grid.forEachRow(function(rid) {
                        var new_sch_vol;
                        if (rid == 0) { 
                            new_sch_vol = schedule_volume;
                            sub_grid.cells(rid, sub_grid.getColIndexById('scheduled_volume')).setValue(new_sch_vol);
                        } else {
                            new_sch_vol = sub_grid.cells(rid - 1, sub_grid.getColIndexById('delivered_volume')).getValue();
                            sub_grid.cells(rid, sub_grid.getColIndexById('scheduled_volume')).setValue(new_sch_vol);
                        }

                        var calc_val = parseInt(new_sch_vol * (1 - sub_grid.cells(rid, sub_grid.getColIndexById('shrinkage')).getValue()));
                        sub_grid.cells(rid, sub_grid.getColIndexById('delivered_volume')).setValue(calc_val);
                    });
                }
            }
        }

        /*
        Function to set loss factor when path dd is changed on sch grid
        */
        sch.change_path_event_sch = function(result) {
            var json_obj = $.parseJSON(result);
            sch.sch_grid.cells(sch.sch_grid.getSelectedRowId(), sch.sch_grid.getColIndexById('Shrinkage')).setValue(json_obj[0].loss_factor);
            
            var calc_val = sch.sch_grid.cells(sch.sch_grid.getSelectedRowId(), sch.sch_grid.getColIndexById('Scheduled Volume')).getValue() * (1 - json_obj[0].loss_factor);
            sch.sch_grid.cells(sch.sch_grid.getSelectedRowId(), sch.sch_grid.getColIndexById('Delivered Volume')).setValue(calc_val);
            sch.sch_grid.cells(sch.sch_grid.getSelectedRowId(), sch.sch_grid.getColIndexById('Contract')).setValue(json_obj[0].contract);
            sch.sch_grid.cells(sch.sch_grid.getSelectedRowId(), sch.sch_grid.getColIndexById('Location To')).setValue(json_obj[0].to_location);
        };
        
        function load_path_contract(grid_obj, rid, path_id) {
            var cm_param = {"action": "spa_counterparty_contract_rate_schedule", "flag": "p", "path_id": path_id,"has_blank_option" : "n"};
            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;            

            var contract_combo = grid_obj.cells(rid, sch.sch_grid.getColIndexById('Contract')).getCellCombo();
           
            contract_combo.clearAll();        
            contract_combo.load(url);  
        }
        
    
    /*
    Function to set loss factor when path dd is changed on resch grid
    */
    sch.change_path_event_resch = function(result) {
        var json_obj = $.parseJSON(result);
        sch.resch_grid.cells(sch.resch_grid.getSelectedRowId(), sch.resch_grid.getColIndexById('Shrinkage')).setValue(json_obj[0].loss_factor);
        sch.resch_grid.cells(sch.resch_grid.getSelectedRowId(), sch.resch_grid.getColIndexById('path_id')).setValue('');

        var calc_val = sch.resch_grid.cells(sch.resch_grid.getSelectedRowId(), sch.resch_grid.getColIndexById('Scheduled Volume')).getValue() * (1 - json_obj[0].loss_factor);
        sch.resch_grid.cells(sch.resch_grid.getSelectedRowId(), sch.resch_grid.getColIndexById('Delivered Volume')).setValue(calc_val);
        sch.resch_grid.cells(sch.resch_grid.getSelectedRowId(), sch.resch_grid.getColIndexById('Contract')).setValue(json_obj[0].contract);
    };
        /*
        Function for menu click on layout b
        */
        sch.menu_click = function(name, value) {
            if (name == 'refresh') {
                sch.refresh_sch_grid();
            } else if(name == 'insert_deal_sch') {            
                sch.menu_insert_schedule();
            } else if (name == 'delete_grid_row') {
                sch.menu_delete_grid_row();
            } else if (name == 'delete_deal_sch') {
                sch.menu_delete_schedule();
            } else if (name == 'process_deal_sch') {
                sch.menu_process_deal_sch(0);
        } else if (name == 'process_deal_resch') {
                sch.menu_process_deal_resch(0);
            }  else if (name == 'html') {
                sch.html_view();
            }
        }   
          
        /**
         * Function to load all combos on sch grid
         */
        sch.sch_load_all_grid_cmbo = function(grid_obj) {
            sch.sch_layout.cells('b').progressOn();
            sch.load_dropdown("EXEC spa_delivery_path @flag='x', @from_location=" + get_param.location_id, sch.sch_grid.getColIndexById('Path'), '', grid_obj);
            sch.load_dropdown("EXEC spa_contract_group @flag='r', @transportation_contract ='y'", sch.sch_grid.getColIndexById('Contract'), '', grid_obj);
            sch.load_dropdown("EXEC spa_contract_group @flag='r', @contract_type='s'", sch.sch_grid.getColIndexById('storage_contract'), '', grid_obj);
            sch.load_dropdown("EXEC spa_source_minor_location @flag='o',@is_active='y'", sch.sch_grid.getColIndexById('Location From'), '', grid_obj);
            sch.load_dropdown("EXEC spa_source_minor_location @flag='o',@is_active='y'", sch.sch_grid.getColIndexById('Location To'), '', grid_obj);
            sch.load_dropdown("EXEC spa_get_source_book_map @flag='s',@function_id=10131000", sch.sch_grid.getColIndexById('Book'), '', grid_obj);
            sch.load_dropdown("EXEC spa_maintain_fields_templates @flag='f'", sch.sch_grid.getColIndexById('Is MR'), '', grid_obj);
            sch.load_dropdown("EXEC spa_getsourcecounterparty @flag='b'", sch.sch_grid.getColIndexById('Shipping Counterparty'), '', grid_obj);
        	sch.load_dropdown("EXEC spa_getsourcecounterparty @flag='b', @counterparty_type= 'i'", sch.sch_grid.getColIndexById('Receiving Counterparty'), '', grid_obj);
        };  

        /*
        Loads the dropdown values on grid cells
        */
        sch.load_dropdown = function(sql_stmt, column_index, callback_function, obj_grid) {
            var cm_param = {
                "action": "[spa_generic_mapping_header]",
                "flag": "n",
                "combo_sql_stmt": sql_stmt,
                "call_from": "grid"
            };

            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;
            var combo_obj = obj_grid.getColumnCombo(column_index);
            combo_obj.enableFilteringMode("between", null, false)

            if (callback_function != '')
                combo_obj.load(url, callback_function);
            else
                combo_obj.load(url);
        };

        /**
         * Function for menu insert sch deal
         */
        sch.menu_insert_schedule = function() {
            // sch.refresh_sch_grid('insert_row');
            // return;

            // out of scope code.
            var param = {
                "flag": "r",
                "action": "spa_get_loss_factor_volume",
                "schedule_volume": 0,
                "deliver_volume": 0,
                "path": get_param.path_id,
                "volume": get_param.total_volume,
                "term_start": get_param.term_start,
                "term_end": get_param.term_end,
                "source_deal_header_id": get_param.deal_id
            };
            adiha_post_data('return_array', param, '', '', 'sch.menu_insert_schedule_cb');
        }

        /*
        callback for insert schedule fx
        */
        sch.menu_insert_schedule_cb = function(result) {
            var num_rows = sch.sch_grid.getRowsNum();
            sch.sch_grid.addRow(num_rows+1, result.join(','));

            sch.sch_grid.forEachRow(function(id){
                if (id == num_rows+1) {                       
                    sch.sch_grid.cellById(id, 1).open();                    
                } else {
                    sch.sch_grid.cellById(id, 1).close();
                }
            });

            sch.sch_grid.enableHeaderMenu();
            sch.sch_layout.cells('b').progressOff();

            if (has_right_add_save_schedule_row)
                sch.sch_menu.setItemEnabled('process_deal_sch');
        };

        /*
        Function to delete the selected rows on schedule grid
        */
        sch.menu_delete_grid_row = function() {
            sch.sch_grid.deleteSelectedRows();

            // get only unsaved rows
            var rows = sch.sch_grid.getAllRowIds().split(',').filter(function(index) {
                return sch.sch_grid.cells(index, sch.sch_grid.getColIndexById('Deal ID')).getValue() == ''
            });

            if(rows.length == 0)
                sch.sch_menu.setItemDisabled('process_deal_sch');
        };

        /*
        Function to schedule the selected deal
        */
        sch.menu_process_deal_sch = function(is_confirm) {
            if(sch.sch_grid instanceof dhtmlXGridObject) {
                var deal_xml = '<Root>';


                // get ids of only unsaved rows.
                var selected_row_ids = sch.sch_grid.getAllRowIds().split(',').filter(function(index) {
                    return sch.sch_grid.cells(index, sch.sch_grid.getColIndexById('Deal ID')).getValue() == '';
                }).join(',');

                selected_row_ids.split(',').forEach(function(selected_row_id) {

                    sch.sch_layout.cells('b').progressOn();

                    var group_path_xml = '';
                    var row_no;

                    var sub_grid = sch.sch_grid.cells(selected_row_id, 1).getSubGrid();
					sub_grid.clearSelection();
                    if (sub_grid !== null) {
                        sub_grid.forEachRow(function(rid) {
                            row_no = parseInt(rid) + 1;
                            group_path_xml = group_path_xml 
                                + '<group_path row_no="' + row_no + '" contract_id="' + sub_grid.cells(rid, sub_grid.getColIndexById('contract')).getValue() 
                                + '" clm_primary_path_id="' + sch.sch_grid.cells(selected_row_id, sch.sch_grid.getColIndexById('Path')).getValue() 
                                + '" clm_path="' +  sub_grid.cells(rid, sub_grid.getColIndexById('path_id')).getValue() 
                                + '" clm_scheduled_volume="' +  sub_grid.cells(rid, sub_grid.getColIndexById('scheduled_volume')).getValue() 
                                + '" clm_shrinkage="' +  sub_grid.cells(rid, sub_grid.getColIndexById('shrinkage')).getValue() 
                                + '" clm_delivered_volume="' +  sub_grid.cells(rid, sub_grid.getColIndexById('delivered_volume')).getValue() 
                                + '"/>';
                        });
                    }

                    deal_xml += '<PSRecordset edit_grid0="' + selected_row_id +
                        '" edit_grid1="' + sch.sch_grid.cells(selected_row_id, sch.sch_grid.getColIndexById('Path')).getValue() +
                        '" edit_grid2="' + sch.sch_grid.cells(selected_row_id, sch.sch_grid.getColIndexById('Contract')).getValue() +
                        '" edit_grid3="' + sch.sch_grid.cells(selected_row_id, sch.sch_grid.getColIndexById('Flow Date From')).getValue() +
                        '" edit_grid4="' + sch.sch_grid.cells(selected_row_id, sch.sch_grid.getColIndexById('Flow Date To')).getValue() +
                        '" edit_grid5="' + sch.sch_grid.cells(selected_row_id, sch.sch_grid.getColIndexById('Scheduled Volume')).getValue() +
                        '" edit_grid6="' + sch.sch_grid.cells(selected_row_id, sch.sch_grid.getColIndexById('Shrinkage')).getValue() +
                        '" edit_grid7="' + sch.sch_grid.cells(selected_row_id, sch.sch_grid.getColIndexById('Fuel Charge')).getValue() +
                        '" edit_grid8="' + sch.sch_grid.cells(selected_row_id, sch.sch_grid.getColIndexById('Delivered Volume')).getValue() +
                        '" edit_grid9="' + sch.sch_grid.cells(selected_row_id, sch.sch_grid.getColIndexById('Total Sch Vol')).getValue() +
                        '" edit_grid10="' + sch.sch_grid.cells(selected_row_id, sch.sch_grid.getColIndexById('Total Del Vol')).getValue() +
                        '" edit_grid11="' + sch.sch_grid.cells(selected_row_id, sch.sch_grid.getColIndexById('Location From')).getValue() +
                        '" edit_grid12="' + sch.sch_grid.cells(selected_row_id, sch.sch_grid.getColIndexById('Location To')).getValue() +
                        '" edit_grid13="' + sch.sch_grid.cells(selected_row_id, sch.sch_grid.getColIndexById('Book')).getValue() +
                        '" edit_grid14="' + sch.sch_grid.cells(selected_row_id, sch.sch_grid.getColIndexById('Volume Frequency')).getValue() +
                        '" edit_grid15="' + sch.sch_grid.cells(selected_row_id, sch.sch_grid.getColIndexById('Shipping Counterparty')).getValue() +
                        '" edit_grid16="' + sch.sch_grid.cells(selected_row_id, sch.sch_grid.getColIndexById('Receiving Counterparty')).getValue() +
                        '" edit_grid17="' + sch.sch_grid.cells(selected_row_id, sch.sch_grid.getColIndexById('Trans ID')).getValue() +
                        '" edit_grid18="' + sch.sch_grid.cells(selected_row_id, sch.sch_grid.getColIndexById('Is MR')).getValue() +
                        '" edit_grid19="' + sch.sch_grid.cells(selected_row_id, sch.sch_grid.getColIndexById('Available Volume')).getValue() +
                        '" edit_grid20="' + sch.sch_grid.cells(selected_row_id, sch.sch_grid.getColIndexById('Deal ID')).getValue() +
                        '" edit_grid21="' + sch.sch_grid.cells(selected_row_id, sch.sch_grid.getColIndexById('delivery_path_detail_id')).getValue() +
                        '" edit_grid23="' + sch.sch_grid.cells(selected_row_id, sch.sch_grid.getColIndexById('storage_contract')).getValue() +
                        '" edit_grid22="' + get_param.trader_id +
                        '"> ' + group_path_xml +' </PSRecordset>'
                });

                deal_xml += '</Root>';

                var param = {
                    "flag": "i",
                    "action": "spa_insert_position_schedule_xml_deal",
                    "deal_xml": deal_xml,
                    "source_deal_header_id": get_param.deal_id,
                    "source_deal_detail_id": get_param.deal_detail_id,
                    "isconfirm": is_confirm
                };

                adiha_post_data('return_json', param, '', '', 'sch.menu_process_deal_sch_cb');
            }
        };

        /*
        Callback fx for schd deal process
        */
        sch.menu_process_deal_sch_cb = function(result) {
            sch.sch_layout.cells('b').progressOff();
            var json_obj = $.parseJSON(result);
            if(json_obj[0].errorcode == 'Success') {
                success_call('Deal Scheduled successfully.', 'error');
                sch.update_total_volume();
                sch.refresh_sch_grid();
            } else if(json_obj[0].message.indexOf('proceed') != -1) {
                dhtmlx.message({
                    title: "Warning",
                    type: "confirm-warning",
                    text: json_obj[0].message,
                    callback: function(is_true) {
                        if(is_true === true) {
                            sch.menu_process_deal_sch(1);
                        }
                    }
                });
            } else if(json_obj[0].message.indexOf('Insufficient') != -1) {
                dhtmlx.message({
                     title: "Warning",
                    type: "confirm-warning",
                    text: json_obj[0].message,
                    callback: function(is_true) {
                         if(is_true === true) {
                            sch.menu_process_deal_sch(1);
                        }
                    }
                });
            } else if(json_obj[0].message.indexOf('MDQ') != -1) {
              //open_spa_html_window(report_name, exec_call, 500, 1150);
                dhtmlx.message({
                    title: "Warning",
                    type: "confirm-warning",
                    text: json_obj[0].message,
                    callback: function(is_true) {
                        if(is_true === true) {
                            sch.menu_process_deal_sch(1);
                        }

                    }
                });

            } else if(json_obj[0].message.indexOf('Counterparty') != -1) {
              //open_spa_html_window(report_name, exec_call, 500, 1150);
              dhtmlx.message({
                  title: "Warning",
                    type: "confirm-warning",
                  text: json_obj[0].message,
                  callback: function(is_true) {
                         if(is_true === true) {
                            sch.menu_process_deal_sch(1);
                        }
                  }
              });

        } else {
            dhtmlx.message({
                title: "Alert",
                type: "alert",
                text: 'SQL Error (menu_process_deal_sch)',
                callback: function(is_true) {

                }
            });
        }
    };


    /*
    Function to Reschedule the selected deal
    */
    sch.menu_process_deal_resch = function(is_confirm) {
        if(sch.resch_grid instanceof dhtmlXGridObject) {
            var selected_row_id = sch.resch_grid.getSelectedRowId();
            //sch.resch_grid.clearSelection();
            sch.sch_layout.cells('c').progressOn();
            
            var group_path_xml = '';
            var row_no;

            var sub_grid = sch.resch_grid.cells(selected_row_id, 1).getSubGrid();
			sub_grid.clearSelection();
            if(sub_grid !== null) {
                sub_grid.forEachRow(function(rid) {
                    row_no = parseInt(rid) + 1;
                    group_path_xml = group_path_xml + '<group_path row_no="' + row_no + '" contract_id="' + sub_grid.cells(rid, sub_grid.getColIndexById('contract')).getValue() 
                                                + '" clm_primary_path_id="' + sch.resch_grid.cells(selected_row_id, sch.resch_grid.getColIndexById('Path')).getValue() 
                                                + '" clm_path="' +  sub_grid.cells(rid, sub_grid.getColIndexById('path_id')).getValue() 
                                                + '" clm_scheduled_volume="' +  sub_grid.cells(rid, sub_grid.getColIndexById('scheduled_volume')).getValue() 
                                                + '" clm_shrinkage="' +  sub_grid.cells(rid, sub_grid.getColIndexById('shrinkage')).getValue() 
                                                + '" clm_delivered_volume="' +  sub_grid.cells(rid, sub_grid.getColIndexById('delivered_volume')).getValue()  
                                                 + '"/>';
                });
            }



        
            var deal_xml = '<Root>';

            //sch.resch_grid.forEachCell(selected_row_id, function(cell_obj, ind) {
                deal_xml += '<PSRecordset edit_grid0="' + selected_row_id +
                            '" edit_grid1="' + sch.resch_grid.cells(selected_row_id, sch.resch_grid.getColIndexById('Path')).getValue() +
                            '" edit_grid2="' + sch.resch_grid.cells(selected_row_id, sch.resch_grid.getColIndexById('Contract')).getValue() +
                            '" edit_grid3="' + sch.resch_grid.cells(selected_row_id, sch.resch_grid.getColIndexById('Flow Date From')).getValue() +
                            '" edit_grid4="' + sch.resch_grid.cells(selected_row_id, sch.resch_grid.getColIndexById('Flow Date To')).getValue() +
                            '" edit_grid5="' + sch.resch_grid.cells(selected_row_id, sch.resch_grid.getColIndexById('Scheduled Volume')).getValue() +
                            '" edit_grid6="' + sch.resch_grid.cells(selected_row_id, sch.resch_grid.getColIndexById('Shrinkage')).getValue() +
                            '" edit_grid7="' + sch.resch_grid.cells(selected_row_id, sch.resch_grid.getColIndexById('Fuel Charge')).getValue() +
                            '" edit_grid8="' + sch.resch_grid.cells(selected_row_id, sch.resch_grid.getColIndexById('Delivered Volume')).getValue() +
                            '" edit_grid9="' + sch.resch_grid.cells(selected_row_id, sch.resch_grid.getColIndexById('Total Sch Vol')).getValue() +
                            '" edit_grid10="' + sch.resch_grid.cells(selected_row_id, sch.resch_grid.getColIndexById('Total Del Vol')).getValue() +
                            '" edit_grid11="' + sch.resch_grid.cells(selected_row_id, sch.resch_grid.getColIndexById('Location From')).getValue() +
                            '" edit_grid12="' + sch.resch_grid.cells(selected_row_id, sch.resch_grid.getColIndexById('Location To')).getValue() +
                            '" edit_grid13="' + sch.resch_grid.cells(selected_row_id, sch.resch_grid.getColIndexById('Book')).getValue() +
                            '" edit_grid14="' + sch.resch_grid.cells(selected_row_id, sch.resch_grid.getColIndexById('Volume Frequency')).getValue() +
                            '" edit_grid15="' + sch.resch_grid.cells(selected_row_id, sch.resch_grid.getColIndexById('Shipping Counterparty')).getValue() +
                            '" edit_grid16="' + sch.resch_grid.cells(selected_row_id, sch.resch_grid.getColIndexById('Receiving Counterparty')).getValue() +
                            '" edit_grid17="' + sch.resch_grid.cells(selected_row_id, sch.resch_grid.getColIndexById('Trans ID')).getValue() +
                            '" edit_grid18="' + sch.resch_grid.cells(selected_row_id, sch.resch_grid.getColIndexById('Is MR')).getValue() +
                            '" edit_grid19="' + sch.resch_grid.cells(selected_row_id, sch.resch_grid.getColIndexById('Available Volume')).getValue() +
                            '" edit_grid20="' + '' + //sch.resch_grid.cells(selected_row_id, sch.resch_grid.getColIndexById('Deal ID')).getValue() +
                            '" edit_grid21="' + sch.resch_grid.cells(selected_row_id, sch.resch_grid.getColIndexById('delivery_path_detail_id')).getValue() +                            
                            '" edit_grid23="' + sch.resch_grid.cells(selected_row_id, sch.resch_grid.getColIndexById('storage_contract')).getValue() +
                            '" edit_grid22="' + get_param.trader_id +

                             '"> ' + group_path_xml +' </PSRecordset></Root>';

            //});
            //console.log(deal_xml);
            var param = {
                "flag": "r",
                "action": "spa_insert_position_schedule_xml_deal",
                "deal_xml": deal_xml,
                "source_deal_header_id": get_param.deal_id,
                "isconfirm": is_confirm
            };
            console.dir(param);
            adiha_post_data('return_json', param, '', '', 'sch.menu_process_deal_resch_cb');
        }
    };
    /*
    Callback fx for schd deal process
    */
    sch.menu_process_deal_resch_cb = function(result) {
        sch.sch_layout.cells('c').progressOff();
        var json_obj = $.parseJSON(result);
        //console.dir(json_obj);
        if(json_obj[0].errorcode == 'Success') {
            success_call('Deal Re-Scheduled successfully.', 'error');
            sch.update_total_volume();
            sch.refresh_sch_grid();
            sch.refresh_resch_grid(-1);
        } else if(json_obj[0].message.indexOf('proceed') != -1) {
            //open_spa_html_window(report_name, exec_call, 500, 1150);
            dhtmlx.message({
                title: "Warning",
                type: "confirm-warning",
                text: json_obj[0].message,
                callback: function(is_true) {
                    if(is_true === true) {
                        sch.menu_process_deal_resch(1);
                    }
                }
            });
        } else if(json_obj[0].message.indexOf('Insufficient') != -1) {
            //open_spa_html_window(report_name, exec_call, 500, 1150);
                dhtmlx.message({
                    title: "Alert",
                    type: "alert",
                    text: json_obj[0].message,
                    callback: function(is_true) {

                    }
                });
        } else if(json_obj[0].message.indexOf('MDQ') != -1) {
              //open_spa_html_window(report_name, exec_call, 500, 1150);
              dhtmlx.message({
                   title: "Warning",
                    type: "confirm-warning",
                  text: json_obj[0].message,
                  callback: function(is_true) {
                     if(is_true === true) {
                            sch.menu_process_deal_resch(1);
                        }

                  }
              });

        }  else if(json_obj[0].message.indexOf('Counterparty') != -1) {
              //open_spa_html_window(report_name, exec_call, 500, 1150);
              dhtmlx.message({
                  title: "Warning",
                    type: "confirm-warning",
                  text: json_obj[0].message,
                  callback: function(is_true) {
                         if(is_true === true) {
                            sch.menu_process_deal_resch(1);
                        }
                  }
              });

            } else {
                dhtmlx.message({
                    title: "Alert",
                    type: "alert",
                    text: 'SQL Error (menu_process_deal_sch)',
                    callback: function(is_true) {

                    }
                });
            }
        };

        open_schedule_report_hyperlink = function(name, value) {
            var url = "EXEC spa_deal_schedule_report 't', "+ get_param.deal_id;
            open_spa_html_window('', url, 600, 1175);
        }

        sch.html_view = function() {
            var url = "EXEC spa_deal_schedule_report 'd', "+ get_param.deal_id + ", '"+ get_param.term_start +"', '"+ get_param.term_end +"'";
            open_spa_html_window('Schedule Detail Report', url, 600, 1175);
        }

        function sch_under_over_detail_report(warning_type, process_id) {
            var report_name = 'Schedule Detail Report';
            var exec_call = "EXEC spa_view_validation_log 'schedule_detail','" + process_id + "', 's'";
            open_spa_html_window(report_name, exec_call, 500, 1150);
        }

        /*
        Function to update deal volume after successful deal schedule
        */
        sch.update_total_volume = function() {
            var param = {
                "flag": "t",
                "action": "spa_get_loss_factor_volume",
                "source_deal_header_id": get_param.deal_id,
                "path": get_param.path_id,
                "source_deal_detail_id": get_param.deal_detail_id
            };
            adiha_post_data('return_json', param, '', '', 'sch.update_total_volume_cb');
        };

        /*
        Callback fx for update_total_volume
        */
        sch.update_total_volume_cb = function(result) {
            var json_obj = $.parseJSON(result);
            sch.sch_form.setItemValue('total_volume', json_obj[0].total_volume);
        }

        /*
        Function to refresh sch grid
        */
        sch.refresh_sch_grid = function(call_from) {
            check_subgrid = [];
            sch.sch_menu.setItemDisabled('process_deal_sch');
            sch.sch_menu.setItemDisabled('delete_deal_sch');
            sch.sch_menu.setItemDisabled('delete_grid_row');
        sch.refresh_resch_grid(-1);

            var flag = 'd';
            var filter_param = '&path=' + get_param.path_id + '&term_start=' + get_param.term_start
                + '&term_end=' + get_param.term_end + '&source_deal_header_id=' + get_param.deal_id + '&source_deal_detail_id=' + get_param.deal_detail_id;

            row_count_first =  sch.sch_grid.getRowsNum();

            if(call_from == 'insert_row') {
                flag = 'r';
            }

            sch.sch_layout.cells('b').progressOn();
            var param = {
                "flag": flag,
                "action":"spa_get_loss_factor_volume"
            };

            param = $.param(param);
            var param_url = js_data_collector_url + "&" + param + filter_param;

            var sch_rows = sch.sch_grid.getRowsNum();

            sch.sch_grid.clearAndLoad(param_url, function() {
                sch.sch_grid.setUserData('', "grid_type", "sch");
                sch.sch_layout.cells('b').progressOff();

                sch.sch_grid.forEachRow(function(rid) {
                    if(sch.sch_grid.cells(rid, sch.sch_grid.getColIndexById('Deal ID')).getValue() != '') {
                        sch.sch_grid.setRowColor(rid, "#EBD3AA");
                        var colNum = sch.sch_grid.getColumnsNum();
                        for(i = 0; i < colNum; i++) {
                            if(i != 1) {
                                sch.sch_grid.cells(rid,i).setDisabled(true);
                            }
                        }
                    } else {
                        sch.sch_grid.cells(rid, sch.sch_grid.getColIndexById('Shipping Counterparty')).setValue(get_param.counterparty);
                        sch.sch_grid.cells(rid, sch.sch_grid.getColIndexById('Receiving Counterparty')).setValue(get_param.primary_counterparty_id);
                    }  
                    sch.sch_grid.forEachRow(function(id){
                        var row_count_final = sch.sch_grid.getRowsNum(); // to check the row is added or not

                        if (row_count_final == row_count_first) { //expand only when refresh                        
                            sch.sch_grid.cellById(id, 1).open();                    
                        } else {
                            sch.sch_grid.cellById(row_count_final-1 , 1).open();   //expand the added row
                        }
                    });
                });

                if(call_from == 'insert_row') {
                    // flag = 'r';

                    
                    if(sch_rows >= 1) {
                        sch.sch_grid.cells(0,1).close();
                        for (var i = 1; i <= sch_rows; i++) {
                            // alert();
                            sch.sch_grid.addRow(i,'');
                            sch.sch_grid.copyRowContent('0',i);
                            sch.sch_grid.cells(i,1).close();
                                
                            if(i == sch_rows) {
                                sch.sch_grid.cells(i,1).open();
                            }
                        }


                        return;
                    }
                }
            });


            sch.subgrid(sch.sch_grid.getRowsNum(), '' ,sch.sch_grid);



        };
                                    
        sch.subgrid = function (rid, sub_open, grid_obj, status_gird) {
            if(typeof check_subgrid[rid] === 'undefined') {
                // does not exist
                check_subgrid[rid] = false;
            } else {
                check_subgrid[rid] = true;
            }
            
            if (check_subgrid[rid] == false) { 
                grid_obj.callEvent("onGridReconstructed", []);
                grid_obj.callEvent("onSubGridCreated", []);   
                grid_obj.attachEvent("onSubGridCreated", function(subgrid, id, ind) {  
                    if (status_gird == 'r') { // Sending rid always 0 because rescheduling grid have only one row at a time.
                        
                        create_sub_grid(subgrid, true, 0, sub_open, grid_obj, status_gird)
                    } else 
                        create_sub_grid(subgrid, true, id, sub_open, grid_obj, status_gird)
                   check_subgrid[rid] = true;                        
                });
            } else {
                subgrid = grid_obj.cells(rid,1).getSubGrid();
                create_sub_grid(subgrid, false, rid, sub_open,grid_obj, status_gird);
            }
        }

        function create_sub_grid(subgrid, is_new_grid, rid, sub_open, grid_obj, status_gird) { 
            var date_format = '<?php echo $date_format ?>';
            var rid_num;
            is_add_clicked = true;
            if ((is_new_grid == true) && (typeof subgrid !== 'undefined')) {
                subgrid.setImagePath(php_script_loc + "components/dhtmlxSuite/codebase/imgs/");
                subgrid.setHeader("Flow Date,Path ID, Path, From Location, To Location, Contract, Scheduled Volume, Shrinkage, Delivered Volume, Receiving Counterparty, Shipping Counterparty,Deal ID, Test");
                subgrid.setColumnIds("term_start,path_id, path,from_location,to_location,contract,scheduled_volume,shrinkage,delivered_volume,receiving_counterparty,shipping_counterparty,source_deal_header_id, delivery_path_detail_id");
                subgrid.setColTypes("dhxCalendar,ro,ro,ro,ro,combo,ed_v,ed_no,ro,ro,ro,ro,ro");
                subgrid.setInitWidths("100,100,150,150,150,150,150,100,150,100,80,80,0");
                subgrid.enableMultiselect(true);
                subgrid.setColSorting("str,int,str,str,str,str,int,int,int,str,str,str,str");
                subgrid.enableColumnMove(true);
                subgrid.setColumnHidden(1,true);
                subgrid.setColumnHidden(9,true);
                subgrid.setColumnHidden(10,true);
                subgrid.setDateFormat(date_format,"%Y-%m-%d");
                subgrid.init();
                subgrid.enableAutoHeight(true)
            }

            var path_id = grid_obj.cells(rid, grid_obj.getColIndexById('Path')).getValue();
            var trans_id = grid_obj.cells(rid, grid_obj.getColIndexById('Trans ID')).getValue();
            var schedule_volume = grid_obj.cells(rid, grid_obj.getColIndexById('Scheduled Volume')).getValue()

            var data = {
                "flag": "q",
                "action": "spa_get_loss_factor_volume",
                "path": path_id,
                "trans_id": trans_id,
                "source_deal_header_id": get_param.deal_id,
                "schedule_volume" : schedule_volume
            };

            if(status_gird == 'r') { // For rescheduling.
                data = {
                    "flag": "q",
                    "action": "spa_get_loss_factor_volume",
                    "path": path_id,
                    "source_deal_header_id": get_param.deal_id,
                    "schedule_volume" : schedule_volume
                };
            }
            
            header_param = $.param(data);
            var header_url = js_data_collector_url + "&" + header_param;
            check_subgrid[rid] = true;  
           
            if (typeof subgrid !== 'undefined') {
                subgrid.clearAll();
                subgrid.loadXML(header_url, function() {
                    var sub_path_ids = null; 
                    var contract_cmb_obj;

                    if(sch.sch_grid.cells(rid, sch.sch_grid.getColIndexById('Deal ID')).getValue() == ''){
                        var sch_vol = grid_obj.cells(rid, grid_obj.getColIndexById('Scheduled Volume')).getValue()
                        sch.change_group_path_volume(grid_obj, rid, sch_vol);    
                    }     

                    subgrid.forEachRow(function(id) {
                        // Load combo value for contract.
                        var col_index = subgrid.getColIndexById("contract");
                        contract_cmb_obj = subgrid.getColumnCombo(col_index);
                        contract_cmb_obj.enableFilteringMode(true);
                        var sub_path_id = subgrid.cells(id, subgrid.getColIndexById('path_id')).getValue();

                         if (sub_path_ids == null) 
                            sub_path_ids = sub_path_id;
                        else
                            sub_path_ids = sub_path_ids + ',' + sub_path_id;
                    });

                    var cm_param = {
                        "action": "spa_counterparty_contract_rate_schedule", 
                        "flag": "p", 
                        "path_id" : sub_path_ids,
                        "has_blank_option" : "n"
                    };

                    cm_param = $.param(cm_param);
                    var url = js_dropdown_connector_url + '&' + cm_param;

                    // Replacing combo id by its combo value.
                    if (typeof contract_cmb_obj !== 'undefined') {
                        contract_cmb_obj.load(url, function() {
                            subgrid.forEachRow(function(id) {
                                if (trans_id !== '' && status_gird !== 'r') {
                                    subgrid.setRowColor(id, "#EBD3AA");
                                    subgrid.setEditable(false);
                                } else {
                                    subgrid.setRowColor(id, "white");
                                    subgrid.setEditable(true);
                                }
                                var contract_id = subgrid.cells(id, subgrid.getColIndexById('contract')).getValue();
                                subgrid.cells(id, subgrid.getColIndexById('contract')).setValue(contract_id);
                            });
                        });
                    }

                    // Loading combo value as per specific path id per row.
                    // subgrid.detachAllEvents();  // Uncomment code to remove problem of spa being called multiple time

                    subgrid.attachEvent("onRowSelect", function(rId, cInd) {
						
						return true
						
                       /* var col_contract = subgrid.getColIndexById('contract');
                        if (cInd == col_contract) {
                            var contract_combo = subgrid.cells(rId, cInd).getCellCombo();
                            grid_combo_status = true;
                            var path_id = subgrid.cells(rId, subgrid.getColIndexById('path_id')).getValue();

                            var cm_param = {
                                "action": "spa_counterparty_contract_rate_schedule",
                                "flag": "p",
                                "path_id": path_id,
                                "has_blank_option": "n"
                            };

                            cm_param = $.param(cm_param);

                            var combo_url = js_dropdown_connector_url + '&' + cm_param;

                            contract_combo.enableFilteringMode(true);
                            contract_combo.load(combo_url);
                        }
						*/
                    });

                    subgrid.attachEvent("onCellChanged", function(rId, cInd,nValue) {
                        var col_shrinkage = subgrid.getColIndexById('shrinkage');
                        var col_sch_volume = subgrid.getColIndexById('scheduled_volume');
                        if (cInd == col_shrinkage || cInd == col_sch_volume) {
                            var col_delivered_volume = subgrid.getColIndexById('delivered_volume');
                            var col_scheduled_volume = subgrid.getColIndexById('scheduled_volume');
                            var col_from_location = subgrid.getColIndexById('from_location');
                            var col_to_location = subgrid.getColIndexById('to_location');
                            var delivered_volume = subgrid.cells(rId, col_delivered_volume).getValue();
                            var shrinkage = subgrid.cells(rId, col_shrinkage).getValue();
                            var scheduled_volume = subgrid.cells(rId, col_scheduled_volume).getValue();
                            var to_location = subgrid.cells(rId, col_to_location).getValue();
                            var new_delivered_volume = Math.round((1-shrinkage) * scheduled_volume);
                            subgrid.cells(rId, col_delivered_volume).setValue(new_delivered_volume);
                            var new_row_id = parseInt(rId) + 1;
                            if (subgrid.doesRowExist(new_row_id.toString())) {
                                subgrid.cells(new_row_id, col_scheduled_volume).setValue(new_delivered_volume);
                                subgrid.cells(new_row_id, col_delivered_volume).setValue(Math.round( (1- subgrid.cells(new_row_id, col_shrinkage).getValue()) * new_delivered_volume));
                            }
                        }
                    });
                    
                    if (!sub_open || sub_open == 'undefined') {
                        grid_obj.callEvent("onSubRowOpen", []);
                    }
                    setTimeout(function(){
                         subgrid.callEvent("onGridReconstructed", []);
                    },1);
                    return false;  // block default behavior
                }); 
            } else {
                if (!sub_open || sub_open == 'undefined') {
                    grid_obj.callEvent("onSubRowOpen", []);
               }
            }
        }

 
    /*
    Function to refresh resch grid
    */
    sch.refresh_resch_grid = function(rid, call_grid) {
        check_subgrid = [];
        // console.log('refresh_resch_grid : ' + rid);
        if(rid == -1) { //
            sch.resch_grid.clearAll();
            return;
        }
        sch.sch_menu.setItemDisabled('process_deal_resch');
        sch.sch_layout.cells('c').progressOn();
        var flag = 'c';
        var filter_param = '&path=' + get_param.path_id + '&term_start=' + get_param.term_start
            + '&term_end=' + get_param.term_end + '&volume=' + get_param.total_volume
            + '&schedule_volume=' + sch.sch_grid.cells(rid, sch.sch_grid.getColIndexById('Scheduled Volume')).getValue()
            + '&deliver_volume=' + sch.sch_grid.cells(rid, sch.sch_grid.getColIndexById('Delivered Volume')).getValue()
            + '&process_id=' + sch.sch_grid.cells(rid, sch.sch_grid.getColIndexById('Process ID')).getValue()
            + '&trans_id=' + sch.sch_grid.cells(rid, sch.sch_grid.getColIndexById('Trans ID')).getValue()
            ;
        // console.log(filter_param);
        var param = {
            "flag": flag,
            "action":"spa_get_loss_factor_volume"
        };
        param = $.param(param);
        var param_url = js_data_collector_url + "&" + param + filter_param;
	
        sch.resch_grid.clearAndLoad(param_url, function() {

            sch.resch_grid.setUserData('', "grid_type", "resch");

            sch.resch_grid.forEachRow(function(id){ 
                load_path_contract(sch.resch_grid, id, sch.resch_grid.cells(id, sch.resch_grid.getColIndexById('Path')).getValue()) 
            });

            sch.sch_layout.cells('c').progressOff();
        });
        if(call_grid)
        sch.subgrid(rid, '', sch.resch_grid, 'r'); 
        // sch.subgrid(rid, '', sch.sch_grid); 
    };
        /*
        Function to delete the schedule deal
        */
        sch.menu_delete_schedule = function() {
            var trans_ids = [];
            sch.sch_grid.getSelectedRowId().split(',').forEach(function(id) {
                var row_id = sch.sch_grid.getRowIndex(id);
                trans_ids.push(sch.sch_grid.cells(row_id, sch.sch_grid.getColIndexById('Trans ID')).getValue())
            });


            var param = {
                "flag": "d",
                "action": "spa_insert_position_schedule_xml_deal",
                "trans_id": trans_ids.join(',')
            };

            confirm_messagebox('Do you want to continue?', function() {
                sch.sch_layout.cells('b').progressOn();
                adiha_post_data('return_json', param, '', '', 'sch.menu_delete_schedule_cb');
            });
        };

        sch.menu_delete_schedule_cb = function(result) {
            var json_obj = $.parseJSON(result);
            if(json_obj[0].errorcode == 'Success') {
                success_call('Schedule successfully deleted.');
                sch.refresh_sch_grid();
            sch.refresh_resch_grid(-1);
                sch.update_total_volume();
            } else {
                dhtmlx.message({
                    title: "Alert",
                    type: "alert",
                    text: 'SQL Error (menu_delete_shedule)',
                    callback: function(is_true) {

                    }
                });
                sch.sch_layout.cells('b').progressOff();
            }
        };
    </script>
</body>