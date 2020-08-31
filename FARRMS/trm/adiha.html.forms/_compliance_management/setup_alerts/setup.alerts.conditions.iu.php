<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
</head>
<?php
    include '../../../adiha.php.scripts/components/include.file.v3.php';
    
    $mode = get_sanitized_value($_GET["flag"] ?? '');
    $alert_id = get_sanitized_value($_GET["alert_id"] ?? '');
    $alert_conditions_id = get_sanitized_value($_GET["alert_conditions_id"] ?? '');
    
    if ($mode == 'u') {
        $sql = "EXEC spa_alert_conditions @flag='a', @rules_id = $alert_id,@alert_conditions_id=$alert_conditions_id";
        $return_value = readXMLURL2($sql);
        $conditions_name = $return_value[0]['alert_conditions_name'];
        $condition_description = $return_value[0]['alert_conditions_description'];
    } else {
        $conditions_name = '';
        $condition_description = '';
    }
    
    $form_namespace = 'alert_actions';
    
    $layout_json = '[{id: "a", header:false, height:30}]';
    $layout_obj = new AdihaLayout();
    
    echo $layout_obj->init_layout('action', '', '1C', $layout_json, $form_namespace);
    
    $toolbar_obj = new AdihaToolbar();
    $toolbar_name = 'save_toolbar';
    $toolbar_json = '[{id:"save", type:"button", text:"Save", img:"save.gif", imgdis:"save_dis.gif"}]';
    echo $layout_obj->attach_toolbar($toolbar_name);
    echo $toolbar_obj->init_by_attach($toolbar_name, $form_namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', "onClick", $form_namespace. ".save_click");
    
    $form_name = "action_form";
    $form_json = '[{
                        "type": "settings",
                        "position": "label-top"
                    }, {
                        type: "block",
                        blockOffset: 10,
                        list: [{
                            "type": "input",
                            "name": "alert_conditions_name",
                            "label": "Name",
                            "required": "true",
                            "validate": "NotEmptywithSpace",
                            "hidden": "false",
                            "disabled": "false",
                            "position": "label-top",
                            "inputWidth": 250,
                            "labelWidth": "auto",
                            "tooltip": "Name",
                            "value": "'.$conditions_name.'"
                        },
                        {
                            "type": "input",
                            "name": "alert_conditions_description",
                            "label": "Description",
                            "hidden": "false",
                            "disabled": "false",
                            "position": "label-top",
                            "inputWidth": 250,
                            "labelWidth": "auto",
                            "tooltip": "Description",
                            "value": "'.$condition_description.'"
                        }]
                    }]';
    $form_obj = new AdihaForm();
    echo $layout_obj->attach_form($form_name, 'a');
    echo $form_obj->init_by_attach($form_name, $form_namespace);
    echo $form_obj->load_form($form_json);
                        
    echo $layout_obj->close_layout();
?>
<script type="text/javascript">
    var mode = '<?php echo $mode; ?>';
    var alert_id = '<?php echo $alert_id; ?>';
    var alert_conditions_id = '<?php echo $alert_conditions_id; ?>';
    
    alert_actions.save_click = function(id) {
        switch(id) {
            case "save":
                var alert_conditions_name = alert_actions.action_form.getItemValue('alert_conditions_name');
                var alert_conditions_description = alert_actions.action_form.getItemValue('alert_conditions_description');
                
                if(mode == 'i') {
                    data = {
                            "action": "spa_alert_conditions", 
                            "flag":"i", 
                            "rules_id": alert_id,
                            "alert_conditions_name": alert_conditions_name,
                            "alert_conditions_description": alert_conditions_description
                            };
                } else {
                    data = {
                            "action": "spa_alert_conditions", 
                            "flag":"u", 
                            "rules_id": alert_id,
                            "alert_conditions_id": alert_conditions_id,
                            "alert_conditions_name": alert_conditions_name,
                            "alert_conditions_description": alert_conditions_description
                            };
                }
                adiha_post_data("alert", data, "", "", "");
                break;
            default:
                break;
        }
    }
</script>
<style type="text/css">
    html, body {
        width: 100%;
        height: 100%;
        margin: 0px;
        padding: 0px;
        background-color: #ebebeb;
        overflow: hidden;
    }
</style>