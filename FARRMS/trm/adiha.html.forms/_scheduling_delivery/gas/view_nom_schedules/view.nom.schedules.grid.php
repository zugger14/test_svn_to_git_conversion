<!--DOCTYPE transitional.dtd-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<meta http-equiv="X-UA-Compatible" content="IE=Edge"> 
    <html> 
        <?php
        include '../../../../adiha.php.scripts/components/include.file.v3.php';

        $process_id = get_sanitized_value($_POST['process_id'] ?? '');

        $layout_json = '[
                {
                    id:             "a",
                    text:           "Buy",
                    header:         true,
                    collapse:       false
                },
                {
                    id:             "b",
                    text:           "Sell",
                    header:         true,
                    collapse:       false
                },
                {
                    id:             "c",
                    text:           "Transport",
                    header:         true,
                    collapse:       false
                },  
            ]';

        $namespace = 'vnsg';
        $layout_obj = new AdihaLayout();
        echo $layout_obj->init_layout('layout_vnsg', '', '3E', $layout_json, $namespace);

        //Attaching Buy grid in cell 'a'
        $grid_obj = new AdihaGrid();
        $grid_name = 'grid';
        echo $layout_obj->attach_grid_cell($grid_name, 'a');
        
        $xml_file = "EXEC spa_adiha_grid 's','best_available_volume_buy'";
        $resultset = readXMLURL2($xml_file);
        echo $grid_obj->init_by_attach($grid_name, $namespace);
        echo $grid_obj->set_header($resultset[0]['column_label_list']);
        echo $grid_obj->set_columns_ids($resultset[0]['column_name_list']);
        echo $grid_obj->set_widths($resultset[0]['column_width']);
        echo $grid_obj->set_column_types($resultset[0]['column_type_list']);
        echo $grid_obj->set_sorting_preference($resultset[0]['sorting_preference']);
        echo $grid_obj->set_column_auto_size(true);
        echo $grid_obj->set_column_visibility($resultset[0]['set_visibility']);
        echo $grid_obj->enable_multi_select(false);
        echo $grid_obj->set_search_filter(true);
        echo $grid_obj->return_init();
        echo $grid_obj->attach_event('', 'onBeforeSelect', $namespace . '.sell_grid_unselect');
        echo $grid_obj->attach_event('', 'onRowSelect', $namespace . '.buy_grid_select');
        echo $grid_obj->load_grid_functions();

        //Attaching Transport grid in cell 'c'
        $grid_obj1 = new AdihaGrid();
        $grid_name = 'grid1';
        echo $layout_obj->attach_grid_cell($grid_name, 'c');
        
        $xml_file = "EXEC spa_adiha_grid 's','best_available_volume_transport'";
        $resultset = readXMLURL2($xml_file);
        echo $grid_obj1->init_by_attach($grid_name, $namespace);
        echo $grid_obj1->set_header($resultset[0]['column_label_list']);
        echo $grid_obj1->set_columns_ids($resultset[0]['column_name_list']);
        echo $grid_obj1->set_widths($resultset[0]['column_width']);
        echo $grid_obj1->set_column_types($resultset[0]['column_type_list']);
        echo $grid_obj1->set_sorting_preference($resultset[0]['sorting_preference']);
        echo $grid_obj1->set_column_auto_size(true);
        echo $grid_obj1->set_column_visibility($resultset[0]['set_visibility']);
        echo $grid_obj1->enable_multi_select(false);
        echo $grid_obj1->set_search_filter(true);
        echo $grid_obj1->return_init();
        echo $grid_obj1->load_grid_functions();
        

        //Attaching Sell grid in cell 'b'
        $grid_obj2 = new AdihaGrid();
        $grid_name = 'grid2';
        echo $layout_obj->attach_grid_cell($grid_name, 'b');
        
        $xml_file = "EXEC spa_adiha_grid 's','best_available_volume_sell'";
        $resultset = readXMLURL2($xml_file);
        echo $grid_obj2->init_by_attach($grid_name, $namespace);
        echo $grid_obj2->set_header($resultset[0]['column_label_list']);
        echo $grid_obj2->set_columns_ids($resultset[0]['column_name_list']);
        echo $grid_obj2->set_widths($resultset[0]['column_width']);
        echo $grid_obj2->set_column_types($resultset[0]['column_type_list']);
        echo $grid_obj2->set_sorting_preference($resultset[0]['sorting_preference']);
        echo $grid_obj2->set_column_auto_size(true);
        echo $grid_obj2->set_column_visibility($resultset[0]['set_visibility']);
        echo $grid_obj2->enable_multi_select(false);
        echo $grid_obj2->set_search_filter(true);
        echo $grid_obj2->return_init();
        echo $grid_obj2->attach_event('', 'onBeforeSelect', $namespace . '.buy_grid_unselect');
        echo $grid_obj2->attach_event('', 'onRowSelect', $namespace . '.sell_grid_select');
        echo $grid_obj2->load_grid_functions();
        
        echo $layout_obj->close_layout();
        ?> 

    </body>
    <script type="text/javascript">
        var process_id = '<?php echo $process_id; ?>';

    	$(function() {
    		load_grid_bav_buy();
            load_grid_bav_sell();
    	});

    	function load_grid_bav_buy() {
            var param = {
                "flag": "b",
                "action": "spa_best_available_volume",
                "process_id": process_id
            };

            param = $.param(param);
            var param_url = js_data_collector_url + "&" + param;
            vnsg.grid.clearAll();
            vnsg.grid.loadXML(param_url);
        }

        function load_grid_bav_sell() {
            var param = {
                "flag": "s",
                "action": "spa_best_available_volume",
                "process_id": process_id
            };

            param = $.param(param);
            var param_url = js_data_collector_url + "&" + param;
            vnsg.grid2.clearAll();
            vnsg.grid2.loadXML(param_url);
        }

        function load_grid_bav_transport(deal_id, flow_date, deal_type) {
            var param = {
                "flag": "t",
                "action": "spa_best_available_volume",
                "deal_id": deal_id,
                "flow_date": dates.convert_to_sql(flow_date),
                "deal_type": deal_type
            };

            param = $.param(param);
            var param_url = js_data_collector_url + "&" + param;
            vnsg.grid1.clearAll();
            vnsg.grid1.loadXML(param_url);
        }

        vnsg.buy_grid_unselect = function() {
            vnsg.grid.clearSelection();
            return true;
        }

        vnsg.sell_grid_unselect = function() {
            vnsg.grid2.clearSelection();
            return true;
        }

        vnsg.buy_grid_select = function() {
            var selected_row_id = vnsg.grid.getSelectedRowId();
            var deal_id_index = vnsg.grid.getColIndexById("deal_id");
            var flow_date_index = vnsg.grid.getColIndexById("flow_date");
            var deal_id = vnsg.grid.cells(selected_row_id, deal_id_index).getValue();
            var flow_date = vnsg.grid.cells(selected_row_id, flow_date_index).getValue();

            load_grid_bav_transport(deal_id, flow_date, 'b');
        }

        vnsg.sell_grid_select = function() {
            var selected_row_id = vnsg.grid2.getSelectedRowId();
            var deal_id_index = vnsg.grid2.getColIndexById("deal_id");
            var flow_date_index = vnsg.grid2.getColIndexById("flow_date");
            var deal_id = vnsg.grid2.cells(selected_row_id, deal_id_index).getValue();
            var flow_date = vnsg.grid2.cells(selected_row_id, flow_date_index).getValue();

            load_grid_bav_transport(deal_id, flow_date, 's');
        }
	</script>    	