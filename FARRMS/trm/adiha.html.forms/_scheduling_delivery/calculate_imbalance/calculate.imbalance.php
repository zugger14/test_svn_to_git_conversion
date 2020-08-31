<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
     <?php  require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
    
<body>
    <?php   
   
    global $image_path;
    $php_script_loc = $app_php_script_loc;
    $app_user_loc = $app_user_name;

    $rights_run_calculate_imbalance = 20009801;
    
    list (
       $has_right_run_calculate_imbalance
    ) = build_security_rights (
       $rights_run_calculate_imbalance
    );

    $namespace   = 'calculate_imbalance';
    $form_name   = 'calculate_imbalance_form';
    $function_id = 20009800;

    $json = '[
                {
                    id:             "a",
                    text:           "Apply Filters",
                    header:         true,
                    collapse:       true,
                    height:         90
                },
                {
                    id:             "b",
                    text:           "Filters",
                    header:         true,
                    collapse:       false
                }
            ]';

    $calculate_imbalance_layout_obj = new AdihaLayout();
    echo $calculate_imbalance_layout_obj->init_layout('calculate_imbalance_layout', '', '2E', $json, $namespace);
    
    $form_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='20009800', @template_name='CalculateImbalance', @parse_xml=''";
    $form_arr = readXMLURL2($form_sql);
    $form_json = $form_arr[0]['form_json'];

    echo $calculate_imbalance_layout_obj->attach_form($form_name, 'b');
    $calculate_imbalance_form_obj = new AdihaForm();
    echo $calculate_imbalance_form_obj->init_by_attach($form_name, $namespace);
    echo $calculate_imbalance_form_obj->load_form($form_json);

    $toolbar_obj = new AdihaToolbar();
    $toolbar_json = '[
                        { id: "run", type: "button", img: "run.gif", text: "Run", title: "Run"}
                    ]';
    echo $calculate_imbalance_layout_obj->attach_toolbar("inventory_calc_toolbar");  
    echo $toolbar_obj->init_by_attach("inventory_calc_toolbar", $namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', 'run_button_click');
    // echo $calculate_imbalance_form_obj->set_input_value($namespace . '.' . $form_name, 'as_of_date', $as_of_date);
    echo $calculate_imbalance_layout_obj->close_layout();
?>
    
    <script>    
        $(function(){
            var function_id = <?php echo $function_id ?>;
            attach_browse_event('calculate_imbalance.calculate_imbalance_form',function_id, 'browse_callback');
            var has_right_run_calculate_imbalance = Boolean('<?php echo $has_right_run_calculate_imbalance; ?>');

            if (has_right_run_calculate_imbalance == false){
                calculate_imbalance.calculate_imbalance_form.disableItem('btn_run');
            } else {
                calculate_imbalance.calculate_imbalance_form.enableItem('btn_run');
            }

            var report_type = 2;
            var filter_obj = calculate_imbalance.calculate_imbalance_layout.cells('a').attachForm();
            var layout_cell_obj = calculate_imbalance.calculate_imbalance_layout.cells('b');

            load_form_filter(filter_obj, layout_cell_obj, function_id, report_type);
        });

        function run_button_click(args) {
            var status = validate_form(calculate_imbalance.calculate_imbalance_form);
            if (status) {
                var cpty_combo_obj = calculate_imbalance.calculate_imbalance_form.getCombo('counterparty_id');
                var counterparty_ids = cpty_combo_obj.getChecked('counterparty_id');
                var contract = calculate_imbalance.calculate_imbalance_form.getItemValue('contract');
                var location_id = calculate_imbalance.calculate_imbalance_form.getItemValue('location_id');
                var term_start = calculate_imbalance.calculate_imbalance_form.getItemValue('term_start', true);
                var term_end = calculate_imbalance.calculate_imbalance_form.getItemValue('term_end', true);
                var status = validate_form(calculate_imbalance.calculate_imbalance_form);
                
                if (status == 0) { return; }

                if (term_start > term_end) {
                    show_messagebox('<b>Term Start</b> cannot be greater than <b>Term End</b>');
                    return;
                }

                var param = ''
                var title = 'Run Calculate Imbalance';
                var exec_call = "EXEC spa_create_imbalance_report " +
                "@summary_option = 'd', @drill_type = 'calc', " + 
                "@pipeline_counterparty = " + singleQuote(counterparty_ids) + ", " +
                "@contract_ids = "          + singleQuote(contract)     + ", " +
                "@drill_location = "        + singleQuote(location_id)  + ", " +
                "@term_start = "            + singleQuote(term_start)   + ", " +
                "@term_end = "              + singleQuote(term_end)
                adiha_run_batch_process(exec_call, param, title)
            }
        }  
    </script>
</body>