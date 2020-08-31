<?php
/**
* Data import export ssis parameters screen
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
    
<body class = "bfix">
    <?php 
    $php_script_loc = $app_php_script_loc;
    $app_user_loc = $app_user_name;
    $rule_id = get_sanitized_value($_GET['rules_id']);
    $process_id = get_sanitized_value($_GET['process_id']);
    $open_from = get_sanitized_value($_GET['open_from']);

    $json = '[
                
                {
                    id:             "a",
                    text:           "Filter Criteria",
                    header:         false,
                    collapse:       false,
                    height:         170
                }
            ]';
    
    $namespace = 'ssis_parameter';
    $ssis_parameter_layout_obj = new AdihaLayout();
    echo $ssis_parameter_layout_obj->init_layout('ssis_parameter_layout', '', '1C', $json, $namespace);
    
    
    $xml_file = "EXEC spa_create_ssis_json_parameters @flag='f', @rule_id=" . $rule_id;
    $return_value1 = readXMLURL($xml_file);
    $form_json = $return_value1[0][2];
    
    echo $ssis_parameter_layout_obj->attach_form('ssis_parameter_form', 'a');
    $ssis_parameter_form = new AdihaForm();
    echo $ssis_parameter_form->init_by_attach('ssis_parameter_form', $namespace);
    echo $ssis_parameter_form->load_form($form_json);

    $toolbar_json = '[
                        { id: "ok", type: "button", img: "tick.png", text: "OK", title: "OK"}
                     ]';

    echo $ssis_parameter_layout_obj->attach_toolbar_cell('ssis_parameters_toolbar', 'a');
    $ssis_parameter_toolbar = new AdihaToolbar();
    echo $ssis_parameter_toolbar->init_by_attach('ssis_parameters_toolbar', $namespace);
    echo $ssis_parameter_toolbar->load_toolbar($toolbar_json);
    echo $ssis_parameter_toolbar->attach_event('', 'onClick', 'ssis_parameter_toolbar_onclick');
    
    echo $ssis_parameter_layout_obj->close_layout();
    ?> 
</body>
    
<script>
    var rules_id = '<?php echo $rule_id; ?>';
    var process_id = '<?php echo $process_id; ?>';
    var open_from = '<?php echo $open_from; ?>';
    var php_script_loc_ajax = "<?php echo $app_php_script_loc; ?>";
    
    $(function(){
        //parent.data_ixp.new_run_win.setMinDimension(750, 500);
        attach_browse_event('ssis_parameter.ssis_parameter_form');
    })
    
    function ssis_parameter_toolbar_onclick(name) {
        if (name == 'ok') {
            data = {
                        'action': 'spa_ixp_import_data_source',
                        'flag':'s',
                        'rules_id': rules_id
                    }
            adiha_post_data('return_json', data, "", "", "ssis_parameter.direct_run_callback", "", "");

        } 
    }

    ssis_parameter.direct_run_callback = function(result) {

                var form_xml = '<Root>';
                var data = ssis_parameter.ssis_parameter_form.getFormData();
                for (var a in data) {
                    field_label = a;
                    if (ssis_parameter.ssis_parameter_form.getItemType(a) == "calendar") {
                        field_value = ssis_parameter.ssis_parameter_form.getItemValue(a, true);
                    } else {
                        field_value = data[a];
                    }
                    if (field_label.indexOf("label_") == -1) {
                        if (field_value == '') { field_value = 'null'; }
                        form_xml += '<PSRecordset paramName="' + field_label + '" paramValue="' + field_value + '"/>';
                    }
                }
                form_xml += '</Root>';

                var data = JSON.parse(result);
                // process_id
                 data = {    
                    "xml_parameters": form_xml,
                    "call_from": 'run',
                    "relation_source": data[0].data_source_type,
                    "process_id": process_id,
                    "rules_id": data[0].rules_id,
                    "is_header_less": data[0].is_header_less,
                    "alias": data[0].data_source_alias
                };
                // console.log(data);
                url = php_script_loc_ajax + "spa_generic_import.php";
                data = $.param(data);

                $.ajax({
                    type: "POST",
                    dataType: "json",
                    url: url,
                    data: data,
                    success: function(data) {
                        // console.log(data)
                        if(data['status']=='Success'){
                            success_call(data['message']);
                        }
                        else {
                            show_messagebox(data['message']);
                        }
                        if (open_from == 'batch') {
                            parent.data_ixp.open_batch_wizard(form_xml);
                            parent.data_ixp.new_run_win.close();
                        }

                    },
                    error: function(xht) {
                        //console.log('xht: ', xht)
                        show_messagebox('Alert');
                    }
        });
    }

</script>
