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
    $form_name = 'form_calculate_credit_exposure';
    
    $rights_calculate_credit_exposure = 10191800;
    
    list (
        $has_right_calculate_credit_exposure
    ) = build_security_rights (
        $rights_calculate_credit_exposure
    );
    
    //JSON for Layout
    $layout_json = '[   {
                            id:             "a",
                            height:         1,
                            header:         false,
                            collapse:       false,
                            fix_size:       [false,null]
                        },
                        {
                            id:             "b",
                            width:          250,
                            height:         65,
                            header:         true,
                            collapse:       false,
                            text:           "Apply Filters",
                            fix_size:       [false,null]
                        },
                        {
                            id:             "c",
                            header:         true,
                            collapse:       false,
                            text:           "Filters",
                            fix_size:       [false,null]
                        }
                    ]';
  
    $name_space = 'calculate_credit_exposure';
    
    $calculate_credit_exposure_layout = new AdihaLayout();

    echo $calculate_credit_exposure_layout->init_layout('calculate_credit_exposure_layout', '', '3E', $layout_json, $name_space);
    
    $form_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10191800', @template_name='CalculateCreditExposure', @parse_xml=''";
    $form_arr = readXMLURL2($form_sql);
    $form_json = $form_arr[0]['form_json'];
    
    $toolbar_json = '[
                    { id: "run", type: "button", img: "run.gif",imgdis: "run_dis.gif", text: "Run", title: "Run", enabled:'.$has_right_calculate_credit_exposure.'}
               ]';

    echo $calculate_credit_exposure_layout->attach_toolbar_cell('calculate_credit_exposure_toolbar', 'a');
    
   // Attaching Toolbar
    $calculate_credit_exposure_toolbar = new AdihaToolbar();
    echo $calculate_credit_exposure_toolbar->init_by_attach('calculate_credit_exposure_toolbar', $name_space);
    echo $calculate_credit_exposure_toolbar->load_toolbar($toolbar_json);
    echo $calculate_credit_exposure_toolbar->attach_event('', 'onClick', 'calculate_credit_exposure_onclick');
    
    // Attaching Form
    $form_object = new AdihaForm();

    echo $calculate_credit_exposure_layout->attach_form($form_name, 'c');    
    echo $form_object->init_by_attach($form_name, $name_space);
    echo $form_object->load_form($form_json);
    
    echo $calculate_credit_exposure_layout->close_layout();   
?>   
</body>

<script type="text/javascript">

    $(function(){
        calculate_credit_exposure.calculate_credit_exposure_layout.cells("a").setHeight(1);
        attach_browse_event('calculate_credit_exposure.form_calculate_credit_exposure');
        var default_as_of_date_to =  new Date();
        var form_obj = calculate_credit_exposure.calculate_credit_exposure_layout.cells("c").getAttachedObject();
        calculate_credit_exposure.form_calculate_credit_exposure.setItemValue('as_of_date', default_as_of_date_to);
      
        form_obj.attachEvent("onChange", function(name, value, is_checked){
            if (name == 'simulation'){
                if (is_checked){
                    calculate_credit_exposure.form_calculate_credit_exposure.checkItem('purge_all');
                    calculate_credit_exposure.form_calculate_credit_exposure.uncheckItem('run_credit_availability_report_only')
                    calculate_credit_exposure.form_calculate_credit_exposure.hideItem('run_credit_availability_report_only');
                } else {
                    calculate_credit_exposure.form_calculate_credit_exposure.uncheckItem('purge_all');
                    calculate_credit_exposure.form_calculate_credit_exposure.showItem('run_credit_availability_report_only');
                }
            }
        });
        
        var function_id  = 10191800;
        var report_type = 2;
        var filter_obj = calculate_credit_exposure.calculate_credit_exposure_layout.cells("b").attachForm();
        var layout_cell_obj = calculate_credit_exposure.calculate_credit_exposure_layout.cells("c");
        load_form_filter(filter_obj, layout_cell_obj, function_id, report_type);
        
    });
    
    function calculate_credit_exposure_onclick() {
        var counterparty = calculate_credit_exposure.form_calculate_credit_exposure.getItemValue('counterparty_id')? calculate_credit_exposure.form_calculate_credit_exposure.getItemValue('counterparty_id'): 'NULL';
        var sub_entity_id = 'NULL';
        var strategy_entity_id = 'NULL';
        var book_entity_id = 'NULL';
        var as_of_date = calculate_credit_exposure.form_calculate_credit_exposure.getItemValue('as_of_date', true);
        var curve_source_value = calculate_credit_exposure.form_calculate_credit_exposure.getItemValue('curve_source');
        var pruge_all = (calculate_credit_exposure.form_calculate_credit_exposure.isItemChecked('purge_all') ? 'y' : 'n');
        var run_car_report = (calculate_credit_exposure.form_calculate_credit_exposure.isItemChecked('run_credit_availability_report_only') ? 'y' : 'n');
        var simulation = (calculate_credit_exposure.form_calculate_credit_exposure.isItemChecked('simulation') ? 'y' : 'n');
        
        var form_obj = calculate_credit_exposure.calculate_credit_exposure_layout.cells("c").getAttachedObject();
        var validate_return = validate_form(form_obj);
        if (validate_return === false) {
            return;
        }
        
        var param = 'call_from=calculate_credit_exposure&gen_as_of_date=1&batch_type=c&as_of_date=' + as_of_date;
        var title = 'Calculate Credit Exposure Job';
        var exec_call = 'EXEC spa_Calc_Credit_Netting_Exposure ' + 
                            singleQuote(as_of_date) + ", " +
                            singleQuote('NULL') + ", " +
                            curve_source_value + ", " +
                            singleQuote('NULL') + ", " +
                            singleQuote('NULL') + ", " +
                            singleQuote('NULL') + ", " +
                            singleQuote(counterparty) + ", " +
                            singleQuote(pruge_all) + ", " +
                            singleQuote(run_car_report) + ", " +
                            singleQuote('NULL') + ",0, " +
                            singleQuote(simulation);
        adiha_run_batch_process(exec_call, param, title);     
    }
    
    
</script>