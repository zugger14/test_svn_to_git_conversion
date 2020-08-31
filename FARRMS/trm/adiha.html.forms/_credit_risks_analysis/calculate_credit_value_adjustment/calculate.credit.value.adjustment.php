<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta http-equiv="X-UA-Compatible" content="IE=edge" />
        <?php  include '../../../adiha.php.scripts/components/include.file.v3.php'; ?>
    </head>
<body>
<?php
    $form_name = 'calculate_credit_value_adjustment';
    
    $right_calculate_credit_value_adjustment = 10192200;
    
    list (
        $has_right_calculate_credit_value_adjustment
    ) = build_security_rights (
        $right_calculate_credit_value_adjustment
    );
    
    //JSON for Layout
    $layout_json = '[   {
                            id:             "a",
                            height:         10,
                            header:         false,
                            collapse:       false,
                            fix_size:       [null,true]   
                        },
                        {
                            id:             "b",
                            width:          250,
                            height:         90,
                            header:         true,
                            collapse:       false,
                            text:           "Apply Filters",
                            fix_size:       [null,true]   
                        },
                        {
                            id:             "c",
                            header:         true,
                            collapse:       false,
                            text:           "Filters",
                            fix_size:       [null,true]   
                        }
                    ]';
  
    $name_space = 'calculate_credit_value_adjustment';
    
    $calculate_credit_value_adjustment_layout = new AdihaLayout();

    echo $calculate_credit_value_adjustment_layout->init_layout('calculate_credit_value_adjustment_layout', '', '3E', $layout_json, $name_space);
    
    $form_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10192200', @template_name='CalculateCreditValueAdjustment', @parse_xml=''";
    $form_arr = readXMLURL2($form_sql);
    $form_json = $form_arr[0]['form_json'];
    
    $toolbar_json = '[
                    { id: "run", type: "button", img: "run.gif",imgdis: "run_dis.gif", text: "Run", title: "Run", enabled:'.$has_right_calculate_credit_value_adjustment.'}
               ]';

    echo $calculate_credit_value_adjustment_layout->attach_toolbar_cell('calculate_credit_value_adjustment_toolbar', 'a');
    
   // Attaching Toolbar
    $calculate_credit_value_adjustment_toolbar = new AdihaToolbar();
    echo $calculate_credit_value_adjustment_toolbar->init_by_attach('calculate_credit_value_adjustment_toolbar', $name_space);
    echo $calculate_credit_value_adjustment_toolbar->load_toolbar($toolbar_json);
    echo $calculate_credit_value_adjustment_toolbar->attach_event('', 'onClick', 'calculate_credit_value_adjustment_onclick');
    
    // Attaching Form
    $form_object = new AdihaForm();

    echo $calculate_credit_value_adjustment_layout->attach_form($form_name, 'c');    
    echo $form_object->init_by_attach($form_name, $name_space);
    echo $form_object->load_form($form_json);
    
    echo $calculate_credit_value_adjustment_layout->close_layout();   
?>   
</body>

<script type="text/javascript">

    $(function(){
        calculate_credit_value_adjustment.calculate_credit_value_adjustment_layout.cells("a").setHeight(30);
        calculate_credit_value_adjustment.calculate_credit_value_adjustment_layout.cells("b").setHeight(90);
        attach_browse_event('calculate_credit_value_adjustment.calculate_credit_value_adjustment');
        var default_as_of_date_to =  new Date();
        var form_obj = calculate_credit_value_adjustment.calculate_credit_value_adjustment_layout.cells("c").getAttachedObject();
        calculate_credit_value_adjustment.calculate_credit_value_adjustment.setItemValue('as_of_date', default_as_of_date_to);
        
        /*CLear combo field for the first time when it is disable.
         Combo is Disabled when form is loaded.*/
        var cm_data = calculate_credit_value_adjustment.calculate_credit_value_adjustment.getCombo('exposures');
        cm_data.clearAll();
        cm_data.setComboText('');

        calculate_credit_value_adjustment.calculate_credit_value_adjustment.disableItem('exposures');
        calculate_credit_value_adjustment.calculate_credit_value_adjustment.disableItem('no_of_simulation');
        form_obj.attachEvent("onChange", function(name, value, is_checked){
            if (name == 'use_simulated_exposures'){
                if (is_checked){

                    // Load data in combo before enable.
                    var cm_data = calculate_credit_value_adjustment.calculate_credit_value_adjustment.getCombo('exposures');
                    cm_data.addOption([
                                {value: "10", text: "Expected Exposure", selected: true}, 
                                {value: "20", text: "PFE"} 
                        ]);
     
                    calculate_credit_value_adjustment.calculate_credit_value_adjustment.enableItem('exposures');
                    calculate_credit_value_adjustment.calculate_credit_value_adjustment.enableItem('no_of_simulation');
                } else {

                    // CLear combo field when it is disable.
                    var cm_data = calculate_credit_value_adjustment.calculate_credit_value_adjustment.getCombo('exposures');
                    cm_data.clearAll();
                    cm_data.setComboText('');

                    calculate_credit_value_adjustment.calculate_credit_value_adjustment.setItemValue('no_of_simulation', '');
                    calculate_credit_value_adjustment.calculate_credit_value_adjustment.disableItem('exposures');
                    calculate_credit_value_adjustment.calculate_credit_value_adjustment.disableItem('no_of_simulation');
                    
                }
            }
        });
        
        var function_id  = 10192200;
        var report_type = 2;
        var filter_obj = calculate_credit_value_adjustment.calculate_credit_value_adjustment_layout.cells("b").attachForm();
        var layout_cell_obj = calculate_credit_value_adjustment.calculate_credit_value_adjustment_layout.cells("c");
        load_form_filter(filter_obj, layout_cell_obj, function_id, report_type);
        
    });
    
    function calculate_credit_value_adjustment_onclick() {
        var counterparty = calculate_credit_value_adjustment.calculate_credit_value_adjustment.getItemValue('counterparty_id')? calculate_credit_value_adjustment.calculate_credit_value_adjustment.getItemValue('counterparty_id'): 'NULL';
        var sub_entity_id = 'NULL';
        var strategy_entity_id = 'NULL';
        var book_entity_id = 'NULL';

        var as_of_date = calculate_credit_value_adjustment.calculate_credit_value_adjustment.getItemValue('as_of_date', true);
        var curve_source_value = calculate_credit_value_adjustment.calculate_credit_value_adjustment.getItemValue('curve_source')? calculate_credit_value_adjustment.calculate_credit_value_adjustment.getItemValue('curve_source'): 'NULL';
        var term_start = calculate_credit_value_adjustment.calculate_credit_value_adjustment.getItemValue('term_start', true);
        var term_end = calculate_credit_value_adjustment.calculate_credit_value_adjustment.getItemValue('term_end', true);
        var exposures = calculate_credit_value_adjustment.calculate_credit_value_adjustment.getItemValue('exposures');
        var no_of_simulation = calculate_credit_value_adjustment.calculate_credit_value_adjustment.getItemValue('no_of_simulation', true)? calculate_credit_value_adjustment.calculate_credit_value_adjustment.getItemValue('no_of_simulation', true): 'NULL';
        var use_simulated_exposures = (calculate_credit_value_adjustment.calculate_credit_value_adjustment.isItemChecked('use_simulated_exposures') ? 'y' : 'n');

        if (term_start == '')
            term_start = 'NULL';
        if (term_end == '')
            term_end = 'NULL';

        var term_start_parse = Date.parse(term_start);
        var term_end_parse = Date.parse(term_end);
        if (term_start_parse > term_end_parse) {
            show_messagebox('<strong>Term End</strong> should be greater than <strong>Term Start</strong>.');
            return;
        }

        var form_obj = calculate_credit_value_adjustment.calculate_credit_value_adjustment_layout.cells("c").getAttachedObject();
        var validate_return = validate_form(form_obj);
        if (validate_return === false) {
            return;
        }

        if (exposures == '10')
            exposures = 'e';
        else
            exposures = 'p';

        var param = 'call_from=calculate_credit_value_adjustment&gen_as_of_date=1&batch_type=c&as_of_date=' + as_of_date;
        var title = 'Calculate Credit Value Adjustment';
        var exec_call = 'EXEC spa_calc_cva ' + 
                            singleQuote(as_of_date) + ", " +
                            singleQuote(counterparty) + ", " +
                            singleQuote(term_start) + ", " +
                            singleQuote(term_end) + ", " +
                            curve_source_value + ", " +
                            singleQuote(use_simulated_exposures) + ", " +
                            no_of_simulation + ", " +
                            singleQuote(exposures);
        adiha_run_batch_process(exec_call, param, title);     
    }
    
    
</script>