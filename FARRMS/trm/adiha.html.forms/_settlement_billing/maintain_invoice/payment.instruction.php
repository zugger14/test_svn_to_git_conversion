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
    $call_from = (isset($_REQUEST["call_from"]) && $_REQUEST["call_from"] != '') ? get_sanitized_value($_REQUEST["call_from"]) : '';
    $calc_id = (isset($_REQUEST["calc_id"]) && $_REQUEST["calc_id"] != '') ? get_sanitized_value($_REQUEST["calc_id"]) : '';
    $payment_ins_id = (isset($_REQUEST["payment_ins_id"]) && $_REQUEST["payment_ins_id"] != '') ? get_sanitized_value($_REQUEST["payment_ins_id"]) : '';
    
    $form_namespace = 'payment_instruction';
    
    $layout_json = '[{id: "a", header:false}]';
    $toolbar_json = '[{ id: "save", type: "button", img: "save.gif", text:"Save", title: "Save"}]';

    $layout_obj = new AdihaLayout();
    $toolbar_obj = new AdihaToolbar();
    $form_obj = new AdihaForm();

    echo $layout_obj->init_layout('payment_instruction_layout', '', '1C', $layout_json, $form_namespace);
    echo $layout_obj->attach_toolbar_cell("toolbar", "a");  
    echo $toolbar_obj->init_by_attach("toolbar", $form_namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', $form_namespace . '.save_click');

    $form_name = 'payment_instruction_form';
    if ($call_from == 'header') {
        
        if ($payment_ins_id == '') {
            $payment_ins_header_id = '';
            $payment_ins_name = '';
            $prod_date = '';
            $comments = ''; 
        } else {
            $payment_ins_header_sql = "EXEC spa_payment_instruction @flag='a', @payment_ins_header = '" . $payment_ins_id . "', @calc_id=" . $calc_id;
            $payment_ins_header_data = readXMLURL2($payment_ins_header_sql);
            $payment_ins_header_id = $payment_ins_header_data[0]['payment_ins_header_id'];
            $payment_ins_name = $payment_ins_header_data[0]['payment_ins_name'];
            $prod_date = $payment_ins_header_data[0]['prod_date'];
            $comments = $payment_ins_header_data[0]['comments']; 
        }
        
        $form_json = '[  
                        {  
                          "type":"settings",
                          "position":"label-top"
                        },
                        {  
                          type:"block",
                          blockOffset:'.$ui_settings['block_offset'].',
                          list:[  
                             {  
                                "type":"input",
                                "name":"payment_ins_header_id",
                                "label":"Payement Instruction ID",
                                "value":"' . $payment_ins_header_id . '",
                                "position":"label-top",
                                "offsetLeft":"'.$ui_settings['offset_left'].'",
                                "labelWidth":"auto",
                                "inputWidth":"'.$ui_settings['field_size'].'",
                                "tooltip":"Payement Instruction ID",
                                "hidden":"true"
                             },{  
                                "type":"input",
                                "name":"payment_ins_name",
                                "label":"Name",
                                "value":"' . $payment_ins_name . '",
                                "position":"label-top",
                                "offsetLeft":"'.$ui_settings['offset_left'].'",
                                "labelWidth":"auto",
                                "inputWidth":"'.$ui_settings['field_size'].'",
                                "tooltip":"Name",
                                "required":true,
                                "userdata":{"validation_message":"Required Field"}
                             },{  
                                "type":"input",
                                "name":"comments",
                                "label":"Comments",
                                "value":"' . $comments .'",
                                "position":"label-top",
                                "offsetLeft":"'.$ui_settings['offset_left'].'",
                                "labelWidth":"auto",
                                "inputWidth":"'.$ui_settings['field_size'].'",
                                "tooltip":"Comments",
                                "rows":4
                             },{  
                                "type":"newcolumn"
                             },{  
                                "type":"calendar",
                                "name":"prod_date",
                                "label":"Date",
                                "value":"'. $prod_date . '",
                                "position":"label-top",
                                "offsetLeft":"'.$ui_settings['offset_left'].'",
                                "labelWidth":"auto",
                                "inputWidth":"'.$ui_settings['field_size'].'",
                                "tooltip":"Prod Date", 
                                "dateFormat": "' . $date_format .'",
                                "serverDateFormat":"%Y-%m-%d",
                                "required":true,
                                "userdata":{"validation_message":"Required Field"}
                             }
                          ]
                        }
                    ]';
        
    } else if ($call_from == 'detail') {
        $payment_ins_detail_sql = "SELECT payment_ins_header_id, calc_detail_id FROM payment_instruction_detail WHERE payment_ins_detail_Id = " . $payment_ins_id;
        $payment_ins_detail_data = readXMLURL2($payment_ins_detail_sql);
        $payment_ins_header_id = $payment_ins_detail_data[0]['payment_ins_header_id'];
        $calc_detail_id = $payment_ins_detail_data[0]['calc_detail_id'];
        
        $sp_url_paymen_ins = "EXEC spa_payment_instruction @flag='p',@calc_id='" . $calc_id . "'";
        $payment_ins_dropdown = $form_obj->adiha_form_dropdown($sp_url_paymen_ins, 0, 1, false, $payment_ins_header_id);
        
        $sp_url_charge_type = "EXEC spa_payment_instruction @flag='c',@calc_id='" . $calc_id . "'";
        $charge_type_dropdown = $form_obj->adiha_form_dropdown($sp_url_charge_type, 0, 1, false, $sp_url_charge_type); 
        
        $form_json = '[  
                        {  
                          "type":"settings",
                          "position":"label-top"
                        },
                        {  
                          type:"block",
                          blockOffset:'.$ui_settings['block_offset'].',
                          list:[  
                             {  
                                "type":"combo",
                                "name":"payment_ins_header_id",
                                "label":"Payment Instruction",
                                "position":"label-top",
                                "offsetLeft":"'.$ui_settings['offset_left'].'",
                                "labelWidth":"auto",
                                "inputWidth":"'.$ui_settings['field_size'].'",
                                "tooltip":"Payment Instruction",
                                "filtering":"true",
                                "options": ' . $payment_ins_dropdown . ',
                                "required":true,
                                "userdata":{"validation_message":"Required Field"}
                             },{  
                                "type":"newcolumn"
                             },{  
                                "type":"combo",
                                "name":"calc_detail_id",
                                "label":"Charge Type",
                                "position":"label-top",
                                "offsetLeft":"'.$ui_settings['offset_left'].'",
                                "labelWidth":"auto",
                                "inputWidth":"'.$ui_settings['field_size'].'",
                                "tooltip":"Charge Type",
                                "filtering":"true",
                                "options": '. $charge_type_dropdown . ',
                                "required":true,
                                "userdata":{"validation_message":"Required Field"}
                             }
                          ]
                        }
                    ]';
        
    }
   
    echo $layout_obj->attach_form($form_name, 'a');
    $form_obj->init_by_attach($form_name, $form_namespace);
    echo $form_obj->load_form($form_json);
     
    echo $layout_obj->close_layout();
?>
<script type="text/javascript">
    var call_from = '<?php echo $call_from; ?>';
    var calc_id = '<?php echo $calc_id; ?>';
    var payment_ins_id = '<?php echo $payment_ins_id; ?>';
    
	payment_instruction.save_click = function(id) {
		if (id == 'save') {
            var attached_obj = payment_instruction.payment_instruction_form;
            var status = validate_form(attached_obj);
            
            if (status == false) return;
            
            if (call_from == 'header') {
                var flag = 'i';
                var payment_ins_header_id = payment_instruction.payment_instruction_form.getItemValue('payment_ins_header_id');
                var payment_ins_name = payment_instruction.payment_instruction_form.getItemValue('payment_ins_name');
                var prod_date = payment_instruction.payment_instruction_form.getItemValue('prod_date', true);
                var comments = payment_instruction.payment_instruction_form.getItemValue('comments');
                
                var xml_data = '<Root><FormXML payment_ins_header_id="' + payment_ins_header_id + '" ';
                xml_data += 'payment_ins_name="' + payment_ins_name + '" ';
                xml_data += 'prod_date="' + prod_date + '" ';
                xml_data += 'comments="' + comments + '" ';
                xml_data += 'calc_id="' + calc_id + '" /></Root>';
            } else if (call_from == 'detail') {
                
                var flag = 'j';
                var payment_ins_header_id = payment_instruction.payment_instruction_form.getItemValue('payment_ins_header_id');
                var calc_detail_id = payment_instruction.payment_instruction_form.getItemValue('calc_detail_id');
                
                var xml_data = '<Root><FormXML payment_ins_detail_id="' + payment_ins_id + '" ';
                xml_data += 'payment_ins_header_id="' + payment_ins_header_id + '" ';
                xml_data += 'calc_detail_id="' + calc_detail_id + '" /></Root>';
            }
            
            var param = {
	            "flag": flag,
	            "action": "spa_payment_instruction",
	            "xml_data": xml_data
	        };
            adiha_post_data('alert', param, '', '', 'payment_instruction.save_callback');
        }
	}

    payment_instruction.save_callback = function() {
        setTimeout(function() {
            window.parent.w11.close();
        }, 1000);
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