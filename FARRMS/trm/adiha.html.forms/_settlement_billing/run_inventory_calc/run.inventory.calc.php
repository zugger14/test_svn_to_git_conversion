<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
</head>
    
<body>
    <?php   
    include '../../../adiha.php.scripts/components/include.file.v3.php';

    $rights_run_inventory_calc = 10162500;
    
    list (
       $has_right_run_inventory_calc
    ) = build_security_rights (
       $rights_run_inventory_calc
    );
    
    $namespace = 'inventory_calc';
    $form_name = 'inventory_calc_form';

    $json = '[
                {
                    id:             "a",
                    text:           "Run Invetory Calc",
                    header:         true,
                    collapse:       false,
                    height:         100
                }
            ]';

    $inventory_calc_layout_obj = new AdihaLayout();
    echo $inventory_calc_layout_obj->init_layout('inventory_calc_layout', '', '1C', $json, $namespace);
    
    $form_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10162500', @template_name='RunInventoryCalc', @parse_xml=''";
    $form_arr = readXMLURL2($form_sql);
    $form_json = $form_arr[0]['form_json'];

    echo $inventory_calc_layout_obj->attach_form($form_name, 'a');
    $inventory_calc_form_obj = new AdihaForm();
    echo $inventory_calc_form_obj->init_by_attach($form_name, $namespace);
    echo $inventory_calc_form_obj->load_form($form_json);

    $toolbar_json = '[
                        { id: "run", type: "button", img: "run.gif", text: "Run", title: "Run"}
                     ]';

    echo $inventory_calc_layout_obj->attach_toolbar_cell('inventory_calc_toolbar', 'a');
    $inventory_calc_toolbar = new AdihaToolbar();
    echo $inventory_calc_toolbar->init_by_attach('inventory_calc_toolbar', $namespace);
    echo $inventory_calc_toolbar->load_toolbar($toolbar_json);
    echo $inventory_calc_toolbar->attach_event('', 'onClick', 'run_button_click');

    $as_of_date_from = date('Y-m-d', strtotime("-1 months"));
    $as_of_date_to = date('Y-m-d');

    echo $inventory_calc_form_obj->set_input_value($namespace . '.' . $form_name, 'as_of_date_from', $as_of_date_from);
    echo $inventory_calc_form_obj->set_input_value($namespace . '.' . $form_name, 'as_of_date_to', $as_of_date_to);
    echo $inventory_calc_form_obj->set_input_value($namespace . '.' . $form_name, 'calc_forward_months', 1);

    echo $inventory_calc_layout_obj->close_layout();
?>
</body>

<script>    
    $(function(){
        var has_right_run_inventory_calc = Boolean('<?php echo $has_right_run_inventory_calc; ?>');
        
        if (has_right_run_inventory_calc == false)
            inventory_calc.inventory_calc_form.disableItem('btn_run');
        else 
            inventory_calc.inventory_calc_form.enableItem('btn_run');
    });

    function result_text(name, value) {
        var f = this.getForm();
        return value;
    }

    function run_button_click(args) {
        var as_of_date_from = inventory_calc.inventory_calc_form.getItemValue('as_of_date_from', true);
        var as_of_date_to = inventory_calc.inventory_calc_form.getItemValue('as_of_date_to', true);
        var inventory_calc_group = inventory_calc.inventory_calc_form.getItemValue('inventory_calc_group', true);
        var calc_forward_months = inventory_calc.inventory_calc_form.getItemValue('calc_forward_months', true);

        if (as_of_date_from == '') {
            show_messagebox('Please enter As of Date From');
            return;
        }

        if ((as_of_date_from > as_of_date_to) && as_of_date_to != '') {
            show_messagebox('As of Date From cannot be greater than As of Date To');
            return;
        }

        var param = 'call_from=Settlement Adjustment Insert Batch Job&gen_as_of_date=1&as_of_date=' + as_of_date_from;
        var title = 'Run Invetory Calc';
        var exec_call = "EXEC spa_calc_inventory_accounting_entries " + 
                        singleQuote(as_of_date_from) + ',' +
                        singleQuote(as_of_date_to) + ',' +
                        singleQuote(inventory_calc_group) + ', NULL,' +
                        singleQuote(calc_forward_months);
        
        adiha_run_batch_process(exec_call, param, title);
    }

    function current_date() {
        var today = new Date();
        var dd = today.getDate();
        var mm = today.getMonth()+1; //January is 0!
        var yyyy = today.getFullYear();

        dd = (dd < 10)?('0' + dd): dd
        mm = (mm < 10)?('0' + mm): mm

        var current_date = yyyy + '-' + mm + '-' + dd;
        return current_date;
    }
 </script>