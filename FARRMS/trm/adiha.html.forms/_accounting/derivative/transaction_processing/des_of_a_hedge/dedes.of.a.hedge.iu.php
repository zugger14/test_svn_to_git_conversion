<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
        <?php  require('../../../../../adiha.php.scripts/components/include.file.v3.php'); ?>

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
    </head>
    <body>
        <?php
        $link_id = get_sanitized_value($_POST['selected_link_id']);
        $disable = get_sanitized_value($_POST['disable'] ?? 1);
        $call_from = get_sanitized_value($_POST['call_from'] ?? 'NULL');
        $callback_function = get_sanitized_value($_POST['post_dedesignate'] ?? ''); 
        
        $function_id = 10233719; //Dedesignate
        list (
            $has_rights_dedesignate_hedge
        ) = build_security_rights(
            $function_id            
        );
        $form_namespace = 'dedesignate_hedge';
        $layout_obj = new AdihaLayout();
        $toolbar_obj = new AdihaToolbar();
        $form_obj = new AdihaForm();
        $layout_json = '[{id: "a", header:false}]';
        $toolbar_json = '[{ id: "save", type: "button", img: "save.gif", imgdis: "save_dis.gif", text:"Save", title: "Save"}]';
        $query = "EXEC spa_StaticDataValues @flag = 'h', @type_id=450"; 
        $des_type_combo = $form_obj->adiha_form_dropdown($query, 0, 1, false, '', 2);
        $current_date = date('Y-m-d');
        $form_json = '[
                        {"type":"settings","position":"label-left"},
                        {"type": "block", "blockOffset": 10, "list":[
                            {"type":"input","name":"link_id","label":"Link ID","tooltip":"Link ID","required":false,"validate":"NotEmpty","hidden":"false","disabled":"true","value":"' . $link_id . '","offsetLeft":"10","offsetTop":"20","labelWidth":120,"inputWidth":"250"},
                            {"type":"combo","name":"dedesignation_type", "options":' . $des_type_combo . ', "required":true,"label":"Dedesignation Type","tooltip":"","offsetLeft":"10","offsetTop":"20","labelWidth":120,"inputWidth":"250","disabled":false},
                            {"type":"calendar","name":"dedesignation_date","label":"Dedesignation Date","tooltip":"","required":false,"validate":"NotEmpty","hidden":"false","disabled":"false","value":"' . $current_date . '","offsetLeft":"10","offsetTop":"20","labelWidth":120,"inputWidth":"250","dateFormat":"' . $date_format . '","serverDateFormat": "%Y-%m-%d"},
                            {"type":"input","name":"dedesignation_percentage","label":"Dedesignation%","tooltip":"","required":false,"validate":"NotEmpty","hidden":"false","disabled":"false","value":"1","offsetLeft":"10","offsetTop":"20","labelWidth":120,"inputWidth":"250"}
                        ]}
                       ]';
        
        echo $layout_obj->init_layout('layout', '', '1C', $layout_json, $form_namespace);
        echo $layout_obj->attach_toolbar_cell("toolbar", "a");
        echo $toolbar_obj->init_by_attach("toolbar", $form_namespace);
        echo $toolbar_obj->load_toolbar($toolbar_json);

        if(!$has_rights_dedesignate_hedge) {
            echo $toolbar_obj->disable_item('save');
        }

        echo $toolbar_obj->attach_event('', 'onClick', $form_namespace . '.save_click');

        $form_name = 'form_dedegnation_hedge';
        echo $layout_obj->attach_form($form_name, 'a');
        $form_obj->init_by_attach($form_name, $form_namespace);
        echo $form_obj->load_form($form_json);

        echo $layout_obj->close_layout();
        ?>
    </body>
    <script type="text/javascript">
        var call_from = '<?php echo $call_from; ?>';
        callback_function = '<?php echo $callback_function; ?>';
        dedesignate_hedge.save_click = function(id) {
            switch (id) {
                case 'save':
                    
                    var sp_name = '';
                    if (call_from == 'hedges') {
                        sp_name = "spa_dedesignate_hedges";
                    } else {
                        //TODO for this block refer previous version of fastracker to complete the logic.
                       sp_name = "spa_view_dedesignation_criteria_detail"; 
                    }
                    var param = {
                        "action": "spa_dedesignate_hedges",
                        "link_id": "<?php echo $link_id; ?>",
                        "dedesignation_percentage": dedesignate_hedge.form_dedegnation_hedge.getItemValue('dedesignation_percentage'),
                        "dedesignation_date": dedesignate_hedge.form_dedegnation_hedge.getItemValue('dedesignation_date',true),
                        "dedesignation_type": dedesignate_hedge.form_dedegnation_hedge.getItemValue('dedesignation_type')
                    };
                    adiha_post_data('alert', param, '', '', 'dedesignate_hedge.save_callback');
                break;
                default:
                    //do nothing
                break;
            }
        }

        dedesignate_hedge.save_callback = function(result) {
            if (result[0]['errorcode'] == 'Success') {
                setTimeout(function () { eval('parent.' + callback_function + '()'); }, 1500);
            } 
        }
        
    </script>
</html>