<!DOCTYPE html>
<html> 
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
    
<body class = "bfix">
    <?php 
    $php_script_loc = $app_php_script_loc;
    $app_user_loc = $app_user_name;
    $rules_id = get_sanitized_value($_GET['rules_id'] ?? 'NULL');
    $process_id = get_sanitized_value($_GET['process_id']);
    $call_from = get_sanitized_value($_GET['call_from'] ?? '');
    $data_source_type = get_sanitized_value($_GET['data_source_type']);

    $json = '[
                
                {
                    id:             "a",
                    text:           "Filter Criteria",
                    header:         false,
                    collapse:       false,
                    height:         170
                }
            ]';
    
    $namespace = 'parameter';
    $parameter_layout_obj = new AdihaLayout();
    echo $parameter_layout_obj->init_layout('parameter_layout', '', '1C', $json, $namespace);
    
    $xml_file = "EXEC spa_create_json_parameters @flag='f', @rule_id=" . $rules_id .",@data_source_type =".$data_source_type;
    $return_value1 = readXMLURL($xml_file);
    $form_json = $return_value1[0][2];
    
    echo $parameter_layout_obj->attach_form('parameter_form', 'a');
    $parameter_form = new AdihaForm();
    echo $parameter_form->init_by_attach('parameter_form', $namespace);
    echo $parameter_form->load_form($form_json);

    $toolbar_json = '[
                        { id: "ok", type: "button", img: "tick.png", text: "OK", title: "OK"}
                     ]';

    echo $parameter_layout_obj->attach_toolbar_cell('parameters_toolbar', 'a');
    $parameter_toolbar = new AdihaToolbar();
    echo $parameter_toolbar->init_by_attach('parameters_toolbar', $namespace);
    echo $parameter_toolbar->load_toolbar($toolbar_json);
    echo $parameter_toolbar->attach_event('', 'onClick', 'parameter_toolbar_onclick');
    
    echo $parameter_layout_obj->close_layout();
    ?> 
</body>
    
<script>
    var rules_id = '<?php echo $rules_id; ?>';
   
    var process_id = '<?php echo $process_id; ?>';
    var call_from = '<?php echo $call_from; ?>';
    var php_script_loc_ajax = "<?php echo $app_php_script_loc; ?>";
    var data_source_type  = "<?php echo $data_source_type; ?>"; 
   
    $(function(){
        parent.parent.data_ixp.new_run_win.setMinDimension(750, 500);
        attach_browse_event('parameter.parameter_form');       
    })
    
    function parameter_toolbar_onclick(name) {
        if (name == "ok") {
            data = {
                        "action": "spa_ixp_import_data_source",
                        "flag":"s",
                        "rules_id": rules_id
                    };
            result = adiha_post_data("return_json", data, "", "", "direct_run_callback");
            //result = adiha_post_data("return_json", data, "", "", "set_new_process_id_callback");

        } 
    }

    function direct_run_callback (result) {
        var validate_return = validate_form(parameter.parameter_form);
        if (!validate_return) {
            generate_error_message();
            return;
        }
        var form_xml = '<Root>';
        var data = parameter.parameter_form.getFormData();
        var field_type;
        for (var a in data) {
            field_label = a;
            if (parameter.parameter_form.getItemType(a) == "calendar") {
                field_value = parameter.parameter_form.getItemValue(a, true);
            } else {
                field_value = data[a];
            }
            
            if (field_label.indexOf("label_") == -1) {
                if (field_value == '') { 
                    field_value = 'null';
                }
                field_type = parameter.parameter_form.getItemType(a);
                form_xml += '<PSRecordset paramName="' + field_label + '" paramValue="' + field_value + '" paramType="' + field_type + '"/>';
            }
        }
        form_xml += '</Root>';

        parent.parent.data_ixp.open_batch_wizard(data_source_type, '', form_xml);
        parent.parent.data_ixp.new_run_win.close();
      
    }
</script>
    