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
        $eff_test_result_id = get_sanitized_value($_POST["eff_test_result_id"] ?? 'NULL');
    	$layout_json = '[{id: "a", header:false}]';
        $layout_name = 'layout_assesment_result';
        $sp_url = "EXEC spa_create_assessment_test_report @eff_test_result_id=" . $eff_test_result_id;
        $resultset = readXMLURL2($sp_url);
        
        $search_text = array("_", "Id", "O");
        $repalce_text = array(" ", "ID", "o");
        $dy_json = '';
        foreach($resultset[0] as $key=>$value) {       
            
            $new_value = ucwords(str_replace('_',' ',$key));
            $new_value = str_replace($search_text, $repalce_text, $new_value);
            $dy_json .= '{"type": "block", position: "label-left", blockOffset: 20, width:"auto", list: [
                       {"type":"label","name":"lbl_' . $key . '","label":"' .$new_value  . '"},
                       {"type":"newcolumn"},
                       {"type":"label","name":"result_id","label":"' . $value . '"}
                    ]},'; 
        }
        
        echo $layout_obj->init_layout($layout_name, '', '1C', $layout_json, $namespace);
         
        $form_obj = new AdihaForm();
        $form_json = '[{"type": "settings", position: "label-left", inputWidth:250, labelWidth:150},
        			   ' . $dy_json . '
                      ]';
                      
        $form_name = 'form_assesment_result';
        echo $layout_obj->attach_form($form_name, 'a');    
        $form_obj->init_by_attach($form_name, $namespace);
        echo $form_obj->load_form($form_json);
        
        echo $layout_obj->close_layout();
    ?>
</body>
</html>