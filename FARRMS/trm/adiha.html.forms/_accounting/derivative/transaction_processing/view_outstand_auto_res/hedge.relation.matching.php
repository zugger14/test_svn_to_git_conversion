<!DOCTYPE html>
<html> 
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
        <?php  require('../../../../../adiha.php.scripts/components/include.file.v3.php'); ?>
    </head>
        
    <body>
        <?php 
        $php_script_loc = $app_php_script_loc;
        $app_user_loc = $app_user_name;
        $rights_hedge_relationship_type = 10231910;
        $rights_select_hedge_relationship_type = 10234515;
        $book_id = get_sanitized_value($_POST['fas_book_id'] ?? 'NULL');
        $gen_hedge_group_id = get_sanitized_value($_POST['gen_hedge_group_id'] ?? 'NULL');
        
        list (
            $has_rights_hedge_relationship_type,
            $has_rights_select_hedge_relationship_type
        ) = build_security_rights(
            $rights_hedge_relationship_type,
            $rights_select_hedge_relationship_type
        );
        
        $namespace = 'ns_hedge_relation_match';
        //attaching layout
        $layout_obj = new AdihaLayout();
        $layout_json = '[{id: "a", header:false}]';
        echo $layout_obj->init_layout('layout', '', '1C', $layout_json, $namespace);
        
        //toolbar
        $toolbar_obj = new AdihaToolbar();
        $toolbar_json = '[{id: "save", type: "button", img: "save.gif", imgdis: "save_dis.gif", text:"Save", title: "Save"}]';
        echo $layout_obj->attach_toolbar_cell("toolbar", "a");
        echo $toolbar_obj->init_by_attach("toolbar", $namespace);
        echo $toolbar_obj->load_toolbar($toolbar_json);

        if(!$has_rights_hedge_relationship_type) {
            echo $toolbar_obj->disable_item('save');
        }

        echo $toolbar_obj->attach_event('', 'onClick', $namespace . '.save_click');

        
        //attach form in layout
        $form_obj = new AdihaForm();        
        $form_name = 'form_hedge_relation_match';
        $form_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='" . $rights_select_hedge_relationship_type . "', @template_name='SelectHedgeRelationMatch', @group_name='General', @parse_xml = '<Root><PSRecordSet gen_hedge_group_id=\"" . $gen_hedge_group_id . "\"></PSRecordSet></Root>'";
        $form_arr = readXMLURL2($form_sql);
        $form_json = $form_arr[0]['form_json'];
        
        echo $layout_obj->attach_form($form_name, 'a');
        echo $form_obj->init_by_attach($form_name, $namespace);
        echo $form_obj->load_form($form_json);
        
        echo $layout_obj->close_layout();        
        
        ?>
        <textarea style="display:none" name="status" id="status"></textarea>
        <textarea style="display:none" name="msg" id="msg"></textarea>
    </body>
    <script>
        ns_hedge_relation_match.save_click = function() {
            var param_list = new Array();
            var form_obj = ns_hedge_relation_match.form_hedge_relation_match;
            var status = validate_form(form_obj);
            ns_hedge_relation_match.validation_status = 1;
            if (status) {
                data = form_obj.getFormData();
                for (var a in data) {
                    var field_label = a;
                    
                    if (form_obj.getItemType(field_label) == 'calendar') {
                        var field_value = form_obj.getItemValue(field_label, true);
                    } else {
                        var field_value = data[field_label];
                    }

                    if (!field_value)
                        field_value = '';
                    
                    
                    form_xml = " @" + field_label + "=\'" + field_value + "'";
                    param_list.push(form_xml);
                }            
            } else {
                ns_hedge_relation_match.validation_status = 0;
            }
            
            var param_string = param_list.toString();
            param_string = param_string.replace(/''/g, 'NULL');
            
            if (!ns_hedge_relation_match.validation_status) return;
            
            var data = {
                            "action": "spa_genhedgegroup @flag='m'," + param_string
                        };
            adiha_post_data('return_array', data, '', '', 'save_callback', ''); 
        }
                
        function save_callback(result) {
            if (result[0][3] == 'Success') {
                document.getElementById("status").value = result[0][3];
                document.getElementById("msg").value = result[0][4];
                var win_obj = window.parent.hedge_status.window("w1");
                win_obj.close();
            } else {
                dhtmlx.message({
                    title: "Error",
                    type: "alert-error",
                    text: result[0][4]
                });
            }
             
        }  
        
    </script>
</html>