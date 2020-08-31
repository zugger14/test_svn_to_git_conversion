<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    </head>
    <?php 
    include "../../../adiha.php.scripts/components/include.file.v3.php";
    
    $message_id = get_sanitized_value($_GET['message_id']);
    $action_id = get_sanitized_value($_GET['action_id']);
    
    if ($message_id != '') {
        $sql = "EXEC spa_setup_rule_workflow @flag='v',@action_id=$action_id";
        $return_value = readXMLURL2($sql);
        $next_rule = $return_value[0]['alert_id'];
        $workflow_action = $return_value[0]['status_id'];
    } else {
        $next_rule = '';
        $workflow_action = '';
    }
    
    $namespace = 'workflow_rule_action';
    $form_name = 'workflow_rule_action_form';
    
    $layout_obj = new AdihaLayout();
    $form_obj = new AdihaForm();
    $toolbar_obj = new AdihaToolbar();
    
    $layout_json = '[{id: "a", header:false}]';
    echo $layout_obj->init_layout('layout', '', '1C', $layout_json, $namespace);
    echo $layout_obj->attach_form($form_name, 'a');
    
    $toolbar_name = 'toolbar_workflow_rule_action';
    $toolbar_namespace = 'workflow_rule_action';
    $tree_toolbar_json = '[ {id:"save", type:"button", img:"save.gif", imgdis:"save_dis.gif", text:"Save", title:"Save"}]';
    
    echo $layout_obj->attach_toolbar_cell($toolbar_name, 'a');
    echo $toolbar_obj->init_by_attach($toolbar_name, $namespace);
    echo $toolbar_obj->load_toolbar($tree_toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', 'save_click');
    
    $rule_list_sql = 'EXEC spa_setup_rule_workflow @flag=n, @message_id=' . $message_id;
    $rule_list = $form_obj->adiha_form_dropdown($rule_list_sql, 0, 1, true, $next_rule);
    
    $action_list_sql = 'EXEC spa_setup_rule_workflow @flag=p';
    $action_list = $form_obj->adiha_form_dropdown($action_list_sql, 0, 1, true, $workflow_action);
    
    $form_json = "[
        			{type: 'settings', position: 'label-top',offsetLeft:0},
                    {
                        type: 'block',
                        blockOffset: 20,
                        list: [{
                            'type': 'input',
                            'name': 'message_id',
                            'label': 'Message ID',
                            'validate': 'NotEmpty',
                            'required': true,
                            'hidden': 'false',
                            'disabled': 'true',
                            'position': 'label-top',
                            'inputWidth': 120,
                            'labelWidth': 'auto',
                            'tooltip': 'Workflow Action',
                            'userdata': {
                                'validation_message': 'Required Field'
                            },
                            'value':'$message_id'
                        },{
                            type: 'newcolumn', offset: 20
                        },{
                            'type': 'combo',
                            'name': 'approval_action',
                            'label': 'Approval Action',
                            'validate': 'NotEmpty',
                            'required': true,
                            'hidden': 'false',
                            'disabled': 'false',
                            'position': 'label-top',
                            'inputWidth': 200,
                            'labelWidth': 'auto',
                            'tooltip': 'Approval Action',
                            'filtering':true,
                            'filtering_mode':'between',
                            'userdata': {
                                'validation_message': 'Required Field'
                            },
                            'options':$action_list
                        }]
                    },{
                        type: 'block',
                        blockOffset: 20,
                        list: [
                        {
                            'type': 'combo',
                            'name': 'next_rule',
                            'label': 'Next Rule',
                            'hidden': 'false',
                            'disabled': 'false',
                            'position': 'label-top',
                            'inputWidth': 340,
                            'labelWidth': 'auto',
                            'filtering': true,
                            'tooltip': 'Next Rule',
                            'validate': 'NotEmpty',
                            'required': true,
                            'filtering':true,
                            'filtering_mode':'between',
                            'userdata': {
                                'validation_message': 'Required Field'
                            },
                            'options': $rule_list
                        }]
                    }
        		]";
    
    echo $form_obj->init_by_attach($form_name, $namespace);
    echo $form_obj->load_form($form_json);
    echo $layout_obj->close_layout();
    ?>
    <script type="text/javascript">	
        var message_id = '<?php echo $message_id; ?>';
        var action_id = '<?php echo $action_id; ?>';
        
        $(function() {
            
    	});
        
        function save_click() {
            var attached_obj = workflow_rule_action.workflow_rule_action_form;
            var status = validate_form(attached_obj);
            
            if(status) {
                var next_rule = workflow_rule_action.workflow_rule_action_form.getItemValue('next_rule');
                var approval_action = workflow_rule_action.workflow_rule_action_form.getItemValue('approval_action');
                
                var xml = '<Root><FormXML event_action_id="' + action_id + '" event_message_id="' + message_id + '" approval_action="' + approval_action +
                '" next_rule="' + next_rule +
                '"></FormXML></Root>'
                
                data = {
                            "action": "spa_setup_rule_workflow", 
                            "flag": 'q',
                            "xml": xml
                        }
                result = adiha_post_data("alert", data, "", "", "workflow_rule_actions.save_post_callback");
            }
        }
        
        workflow_rule_actions.save_post_callback = function(result) {
            if(result[0].errorcode == 'Success') {
                action_id = result[0].recommendation;
            }
        }
        
    </script>
    <style>
        html, body {
            width: 100%;
            height: 615px;
            margin: 0px;
            padding: 0px;
            background-color: #ebebeb;
            overflow: hidden;
        }
    </style>
</html>