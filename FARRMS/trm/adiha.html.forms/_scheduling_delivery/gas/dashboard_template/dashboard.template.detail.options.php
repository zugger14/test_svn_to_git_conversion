<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
</head>
    <?php
    include '../../../../adiha.php.scripts/components/include.file.v3.php';
    
    $form_name = 'form_dashboard_template_detail_options';
    $rights_dashboard_template_detail_options = 10163014;
    
    list (
        $has_rights_dashboard_template_detail_options
    ) = build_security_rights(
        $rights_dashboard_template_detail_options
    );
    
    $dashboard_template_detail_id = get_sanitized_value($_GET['dashboard_template_detail_id'] ?? 'NULL');
    
    $sql = 'EXEC spa_dashboard_template_detail @flag=p, @dashboard_template_detail_id=' . $dashboard_template_detail_id;
    $return_value = readXMLURL2($sql);
    $option_editable = $return_value[0]['option_editable'];
    $option_formula = $return_value[0]['option_formula'];
    
    $form_json = '[{
                        "type": "settings",
                        "position": "label-top"
                    }, {
                        type: "block",
                        blockOffset: 10,
                        list: [{
                            "type": "checkbox",
                            "name": "editable",
                            "label": "Editable",
                            "position": "label-right",
                            "offsetLeft": "10",
                            "offsetTop": "20",
                            "labelWidth": "auto",
                            "inputWidth": "150",
                            "checked": "'.$option_editable.'",
                            "tooltip": "Editable"
                        },
                        {
                            "type": "input",
                            "name": "formula",
                            "label": "Formula",
                            "position": "label-top",
                            "offsetLeft": "10",
                            "labelWidth": "auto",
                            "inputWidth": "300",
                            "tooltip": "Formula",
                            "value": "' . $option_formula . '",
                            "rows":6
                        }]
                    }]';

    $layout_json = '[
                        {id: "a", text: "Options", header: false}
                    ]';
    $layout_obj = new AdihaLayout();
    $toolbar_obj = new AdihaToolbar();
    $filter_form_obj = new AdihaForm();
    
    $form_namespace = 'options';
    $toolbar_json = '[{ id: "save", type: "button", img: "save.gif", text:"Save", title: "Save"}]';
    
    echo $layout_obj->init_layout('options_layout', '', '1C', $layout_json, $form_namespace);
    echo $layout_obj->attach_toolbar_cell("toolbar", "a");  
    echo $toolbar_obj->init_by_attach("toolbar", $form_namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', $form_namespace . '.save_click');
    
    $form_name = 'options_form';
    echo $layout_obj->attach_form($form_name, 'a');
    $filter_form_obj->init_by_attach($form_name, $form_namespace);
    echo $filter_form_obj->load_form($form_json);
    
    echo $layout_obj->close_layout();
    ?>
           
    <script>
        options.save_click = function(id) {
            switch(id) {
                case "save":
                    var dashboard_template_detail_id = '<?php echo $dashboard_template_detail_id; ?>';
                    var option_editable = (options.options_form.getItemValue("editable") == 1) ? 'y' : 'n';
                    
                    var option_formula = options.options_form.getItemValue("formula");
                    
                    if(option_formula != '') {
                        option_editable = 'y';
                    }
                     
                    var param = {
                        "flag": "o",
                        "action": "spa_dashboard_template_detail",
                        "dashboard_template_detail_id": dashboard_template_detail_id,
                        "option_editable": option_editable,
                        "option_formula": option_formula
                    };
                
                    adiha_post_data('alert', param, '', '', '', '');
                    break;
                default:
                    break;
            }
        }
    </script>   