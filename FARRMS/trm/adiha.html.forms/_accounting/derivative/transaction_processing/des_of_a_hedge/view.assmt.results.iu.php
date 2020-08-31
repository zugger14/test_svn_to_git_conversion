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
    $layout_obj = new AdihaLayout();
	$namespace = 'ns_assesment_result';
    
    $link_id = get_sanitized_value($_POST["link_id"] ?? 'NULL');
    $rel_id = get_sanitized_value($_POST["rel_id"] ?? 'NULL');
    $calc_level = get_sanitized_value($_POST["calc_level"] ?? 'NULL');
    $initial_ongoing = get_sanitized_value($_POST["initial_ongoing"] ?? 'o');

	$layout_json = '[{id: "a", header:false}]';
    $layout_name = 'layout_assesment_result';
    echo $layout_obj->init_layout($layout_name, '', '1C', $layout_json, $namespace);
	
    
    $toolbar_obj = new AdihaToolbar();
    $toolbar_json = '[{id:"save", type:"button", img: "save.gif", img_disabled: "save_dis.gif", text:"Save", title: "Save"}]';
    echo $layout_obj->attach_toolbar_cell('toolbar', 'a');
    echo $toolbar_obj->init_by_attach('toolbar', $namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', $namespace . '.save_click');
    
    $form_obj = new AdihaForm();
    $form_json = '[{"type": "settings", position: "label-left", inputWidth:150, labelWidth:150},
    			   {"type": "block", position: "label-left", blockOffset: 20, width:"auto", list: [
                       {"type": "calendar", "validate":"NotEmptywithSpace", required:true, "userdata":{"validation_message":"Required Field"}, "dateFormat":"' . $date_format . '", "serverDateFormat": "%Y-%m-%d", "name": "as_of_date", "label": "As of Date"},
        			   {"type":"input","name":"result_value","label":"Assessment Value", required:true,"tooltip":"","validate":"ValidNumeric","hidden":"false","disabled":"false","value":"","userdata":{"validation_message":"Invalid Number."}},
                       {"type":"input","name":"additional_result_value","label":"Additional Value","tooltip":"","validate":"ValidNumeric","hidden":"false","disabled":"false","value":"","userdata":{"validation_message":"Invalid Number."}}
                    ]}
                  ]';
                  
    $form_name = 'form_assesment_result';
    echo $layout_obj->attach_form($form_name, 'a');    
    echo $form_obj->init_by_attach($form_name, $namespace);
    echo $form_obj->load_form($form_json);
    
    echo $layout_obj->close_layout();
?>
<textarea style="display:none" name="success_status" id="success_status"></textarea>
</body>
<script type="text/javascript">
    ns_assesment_result.save_click = function() {
        var form_obj = ns_assesment_result.form_assesment_result;
        var status = validate_form(form_obj);
        
        if (status) {
            var as_of_date = form_obj.getItemValue('as_of_date', true);
            var result_value = form_obj.getItemValue('result_value');
            var additional_result_value = form_obj.getItemValue('additional_result_value');
        } else {
            return;
        }
       
        var rel_id = '<?php echo $rel_id; ?>';
        var link_id = '<?php echo $link_id; ?>';
        var calc_level = '<?php echo $calc_level; ?>';
        var initial_ongoing = '<?php echo $initial_ongoing; ?>';
        
        var data = {
                        "action": "spa_Override_Assessment_Results",
                        "flag": 'i',
                        "rel_id": rel_id,
                        "link_id": link_id,
                        "calc_level": calc_level,
                        "initial_ongoing": initial_ongoing,
                        "as_of_date": as_of_date,
                        "result_value": result_value,
                        "additional_result_value": additional_result_value
                    };
        
        adiha_post_data('array', data, '', '', 'post_assessment_result', '');
    }
    
    function post_assessment_result(result) {
        if (result[0].errorcode == 'Success') {
            document.getElementById("success_status").value = 'Success';
            var win_obj = window.parent.new_win.window("w1");
            win_obj.close();
        } else {
            dhtmlx.alert({
                   title: 'Error',
                   type: "alert-error",
                   text: result[0].message
                });
        }
    }
    

</script>
</html>