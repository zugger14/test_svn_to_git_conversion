<!DOCTYPE html>
<html> 
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    </head>
        
    <body class = "bfix">
    <?php 
    include_once('../../../adiha.php.scripts/components/include.file.v3.php'); 
    $php_script_loc = $app_php_script_loc;
    $app_user_loc = $app_user_name;
    
    $rights_run_generation_process = 10166800;
      
    $current_date = date('Y-m-d');
        
    list (
        $has_rights_run_generation_process
    ) = build_security_rights(
        $rights_run_generation_process
    );

    
    $json = '[
                {
                    id:             "a",
                    text:           "Apply Filter",
                    header:         false,
                    collapse:       false,
                    height:         70
                },{
                    id:             "b",
                    text:           "Run Generation Process",
                    header:         false,
                    collapse:       false,
                    height:         150
                },{
                    id:             "c",
                    text:           "Location",
                    header:         false,
                    collapse:       false
                }
            ]';
    
    $namespace = 'run_generation_process';
    $form_name = 'run_generation_process_form';
    
    $run_generation_process_layout_obj = new AdihaLayout();
    echo $run_generation_process_layout_obj->init_layout('run_generation_process_layout', '', '3E', $json, $namespace);
 
    $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10166800', @template_name='Run Generation Process', @group_name='General'";
    $return_value1 = readXMLURL($xml_file);
    $form_json = $return_value1[0][2];    
        
    echo $run_generation_process_layout_obj->attach_form($form_name, 'b');
    $run_generation_process_form = new AdihaForm();
    echo $run_generation_process_form->init_by_attach($form_name, $namespace);
    echo $run_generation_process_form->load_form($form_json);
    echo $run_generation_process_form->attach_event('', 'onChange', 'run_generation_onchange');
        
    $toolbar_json = '[
                        { id: "run", type: "button", img: "process.gif", text: "Run", title: "Run"}
                     ]';

    echo $run_generation_process_layout_obj->attach_toolbar_cell('run_generation_process_toolbar', 'b');
    $run_generation_process_toolbar = new AdihaToolbar();
    echo $run_generation_process_toolbar->init_by_attach('run_generation_process_toolbar', $namespace);
    echo $run_generation_process_toolbar->load_toolbar($toolbar_json);
    echo $run_generation_process_toolbar->attach_event('', 'onClick', 'run_generation_process_toolbar_onclick');
    
        
    $location_grid_obj = new GridTable('run_generation_location');
    echo $run_generation_process_layout_obj->attach_grid_cell('location_grid','c');
    echo $location_grid_obj->init_grid_table('location_grid', $namespace);
    echo $location_grid_obj->set_search_filter(true,'');
    echo $location_grid_obj->enable_multi_select();
    echo $location_grid_obj->return_init();
    echo $location_grid_obj->load_grid_data();
    echo $location_grid_obj->load_grid_functions();
        
        
        
    echo $run_generation_process_layout_obj->close_layout();
    ?> 
    </body>
    
    <style type="text/css">
       html, body {
           width: 100%;
           height: 100%;
           margin: 0px;
           overflow: hidden;
       }
    </style>
    
    <script type="text/javascript"> 
        
        $(function() {
            filter_obj = run_generation_process.run_generation_process_layout.cells('a').attachForm();
            var layout_cell_obj = run_generation_process.run_generation_process_layout.cells('b');
            load_form_filter(filter_obj, layout_cell_obj, '10166800', 2);
            
            var current_date = '<?php echo $current_date; ?>';
        
            //run_generation_process.run_generation_process_form.setItemValue('as_of_date', current_date);
            run_generation_process.run_generation_process_form.setItemValue('term_from', current_date);

            /*
                Calculation Period is by default set to Short Term i.e is value = 's'
            */ 
            run_generation_process.run_generation_process_form.setItemValue('term_to', '');
            run_generation_process.run_generation_process_form.setItemValue('as_of_date', '');
            run_generation_process.run_generation_process_form.disableItem('term_to');
            run_generation_process.run_generation_process_form.disableItem('as_of_date');
        })
        
        
        run_generation_onchange = function(name, value) {
            if (name == 'calculation_period') {
                if (value == 's') {
                    run_generation_process.run_generation_process_form.setItemValue('term_to', '');
                    run_generation_process.run_generation_process_form.setItemValue('as_of_date', '');
                    run_generation_process.run_generation_process_form.disableItem('term_to');
                    run_generation_process.run_generation_process_form.disableItem('as_of_date');
                    run_generation_process.run_generation_process_form.enableItem('term_from');
                    run_generation_process.run_generation_process_form.enableItem('operation_days');
                } else if (value == 'l') {
                    run_generation_process.run_generation_process_form.setItemValue('term_from', '');
                    run_generation_process.run_generation_process_form.setItemValue('operation_days', '');
                    run_generation_process.run_generation_process_form.disableItem('term_from');
                    run_generation_process.run_generation_process_form.disableItem('operation_days');
                    run_generation_process.run_generation_process_form.enableItem('term_to');
                    run_generation_process.run_generation_process_form.enableItem('as_of_date');
                } else {
                    run_generation_process.run_generation_process_form.enableItem('term_to');
                    run_generation_process.run_generation_process_form.enableItem('as_of_date');
                    run_generation_process.run_generation_process_form.enableItem('term_from');
                    run_generation_process.run_generation_process_form.enableItem('operation_days');
                }
            }
        }
     
        function run_generation_process_toolbar_onclick(name) {
            var status = validate_form(run_generation_process.run_generation_process_form);
            if (status == false) {
                return;
            }
            
            var as_of_date = run_generation_process.run_generation_process_form.getItemValue('as_of_date', true);
            var term_from = run_generation_process.run_generation_process_form.getItemValue('term_from', true);
            var term_to = run_generation_process.run_generation_process_form.getItemValue('term_to', true);
            var operation_days = run_generation_process.run_generation_process_form.getItemValue('operation_days');
            var calculation_period = run_generation_process.run_generation_process_form.getItemValue('calculation_period');
            var purge =  run_generation_process.run_generation_process_form.isItemChecked('purge') ? 'y':'n';
            if (calculation_period == 's' && (term_from == '' || operation_days == '')) {
                show_messagebox('Term Form and Operation Days are required for short term calculation.');
                return;
            }
            
            if (calculation_period == 'l' && (as_of_date == '' || term_to == '')) {
                show_messagebox('As of Date and Term To are required for the long term calculation.');
                return;
            }
            
            var location_id_arr = new Array();
            var selected_row = run_generation_process.location_grid.getSelectedRowId();
            
            if (selected_row == '' || selected_row == null) 
                var selected_row_arr = new Array()
            else
                var selected_row_arr = selected_row.split(',');
            
            for (cnt = 0; cnt < selected_row_arr.length; cnt++) {
                var loc_id =  run_generation_process.location_grid.cells(selected_row_arr[cnt], 0).getValue();
                location_id_arr.push(loc_id);
            }
            var location_ids = location_id_arr.toString();
            
            var exec_call = "EXEC spa_calc_generation_unit_cost_wrapper " 
                            + " @flag='" + calculation_period + "',"
                            + " @as_of_date='" + as_of_date + "',"
                            + " @term_start='" + term_from + "',"
                            + " @term_end='" + term_to + "',"
                            + " @hourly_no_days='" + operation_days + "',"
                            + " @location_ids='" + location_ids + "',"
                            + " @purge='" + purge + "'";
                            
            if (as_of_date == '')
                var param = 'call_from=Run_Generation_Process_Job&gen_as_of_date=1&batch_type=c';
            else
                var param = 'call_from=Run_Generation_Process_Job&gen_as_of_date=1&batch_type=c&as_of_date=' + as_of_date; 
            adiha_run_batch_process(exec_call, param, 'Run Generation Process');
            
        } 
        
        open_deal_window = function(source_deal_header_id) {
            var deal_window = new dhtmlXWindows();
            var new_update_window = deal_window.createWindow('w1', 0, 0, 400, 400);
            new_update_window.setText("Deal - " + source_deal_header_id);
            new_update_window.centerOnScreen();
            new_update_window.maximize();
            var param = {deal_id:source_deal_header_id};
            new_update_window.attachURL('../../../adiha.html.forms/_deal_capture/maintain_deals/deal.detail.new.php', false, param);
        }
        
        open_generation_window = function(source_deal_header_id) {
            var setup_generation = new dhtmlXWindows();
            setup_generation_win = setup_generation.createWindow('w1', 0, 0, 900, 700);
            setup_generation_win.setText("Setup Generation");
            setup_generation_win.centerOnScreen();
            setup_generation_win.setModal(true);
            setup_generation_win.maximize();

            var page_url = js_php_path + '../adiha.html.forms/_deal_capture/maintain_deals/setup.generation.php?source_deal_header_id=' + source_deal_header_id;
            setup_generation_win.attachURL(page_url, false, null);
        }

    </script> 
</html>