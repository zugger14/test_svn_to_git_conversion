<!DOCTYPE html>
<head>
    <meta charset='UTF-8' />
    <meta name='viewport' content='width=device-width, initial-scale=1.0' />
    <meta http-equiv='X-UA-Compatible' content='IE=edge,chrome=1' />
</head>
<html>
    <?php
    include '../../../adiha.php.scripts/components/include.file.v3.php';
    $form_cell_json = "[
            {
                id:     'a',
                width:  240,
                height: 1,
                header: false
            },
            {
                id:     'b',
                width:  240,
                height: 220,
                text: 'Apply Filter',
                header: true
            },
            {
                id:     'c',
                width:  240,
                height: 385,
                text: 'Filters',
                header: true
            }
        ]";
     
    $rights_fx_ineffectiveness = 13231000; 
    
    $form_layout = new AdihaLayout();
    $layout_name = 'layout_fx_ineffectiveness';
    $form_name_space = 'ns_fx_ineffectiveness';
    echo $form_layout->init_layout($layout_name, '', '3E', $form_cell_json, $form_name_space); 
    
    //Attaching Run Toolbar
    $toolbar_run_json = "[ {id:'run', img:'run.gif', imgdis:'run_dis.gif', text:'Run', title:'Run', enabled: 1} ]";
    
    $toolbar_run = new AdihaMenu();
    echo $form_layout->attach_menu_cell('toolbar_run', 'a'); 
    echo $toolbar_run->init_by_attach('toolbar_run', $form_name_space);
    echo $toolbar_run->load_menu($toolbar_run_json);
    echo $toolbar_run->attach_event('', 'onClick', 'btn_run_click');
    
    $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id=" . $rights_fx_ineffectiveness . ", @template_name='Run FX Ineffectiveness', @group_name='General'";
    $return_value1 = readXMLURL($xml_file);
    $form_json = $return_value1[0][2];
    //Attach form
    $form_obj = new AdihaForm();
    $form_name = 'form_fx_ineffectiveness';
    echo $form_layout->attach_form($form_name, 'c');    
    echo $form_obj->init_by_attach($form_name, $form_name_space);
    echo $form_obj->load_form($form_json);
    echo $form_layout->close_layout();     
    ?>
</html>
<script type="text/javascript">
    var function_id = '<?php echo $rights_fx_ineffectiveness; ?>';
    $(function() {
        filter_obj = ns_fx_ineffectiveness.layout_fx_ineffectiveness.cells('b').attachForm();
        var layout_cell_obj = ns_fx_ineffectiveness.layout_fx_ineffectiveness.cells('c');        
        load_form_filter(filter_obj, layout_cell_obj, function_id, 2);   
        form_obj = 'ns_fx_ineffectiveness.form_fx_ineffectiveness';
        attach_browse_event(form_obj,function_id);
        ns_fx_ineffectiveness.layout_fx_ineffectiveness.cells("a").setHeight(1);
    });
    
    function btn_run_click() {
        var as_of_date = ns_fx_ineffectiveness.form_fx_ineffectiveness.getItemValue('as_of_date', true);
        var deal_id_from = ns_fx_ineffectiveness.form_fx_ineffectiveness.getItemValue('deal_id_from');                     
        var deal_id_to = ns_fx_ineffectiveness.form_fx_ineffectiveness.getItemValue('deal_id_to');                     
                
        var form_validate = validate_form(ns_fx_ineffectiveness.form_fx_ineffectiveness);
        if (form_validate == 0) return;
        
        var param = 'call_from=run_fx_ineffectiveness&gen_as_of_date=1&batch_type=c&job_name=Run FX Ineffectiveness&as_of_date=' + as_of_date;
        var title = 'Run FX Ineffectiveness';       
        
        exec_call = "EXEC spa_calc_FX_ineffectiveness_adjustment 'i' ,'" + as_of_date + "', NULL, NULL, NULL, " + deal_id_from + ", " + deal_id_to;
        adiha_run_batch_process(exec_call, param, title); 
    }
    
</script>