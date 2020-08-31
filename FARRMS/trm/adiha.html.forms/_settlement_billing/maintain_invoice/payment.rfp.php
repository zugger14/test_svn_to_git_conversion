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
    $calc_id = (isset($_REQUEST["calc_id"]) && $_REQUEST["calc_id"] != '') ? get_sanitized_value($_REQUEST["calc_id"]) : '';
    $payment_id= (isset($_REQUEST["payment_id"]) && $_REQUEST["payment_id"] != '') ? get_sanitized_value($_REQUEST["payment_id"]) : '';
    
    $payment_ins_header_sql = "EXEC spa_payment_instruction @flag='a', @payment_ins_header = '" . $payment_id . "', @calc_id=" . $calc_id;
    $payment_ins_header_data = readXMLURL2($payment_ins_header_sql);
    $payment_ins_header_id = $payment_ins_header_data[0]['payment_ins_header_id'];
    
    $form_namespace = 'payment_rfp';
    
    $layout_json = '[{id: "a", header:false}]';
    $toolbar_json = '[{ id: "ok", type: "button", img: "save.gif", text:"Save", title: "Ok"}]';

    $layout_obj = new AdihaLayout();
    $toolbar_obj = new AdihaToolbar();
    $form_obj = new AdihaForm();
    
    echo $layout_obj->init_layout('payment_rfp_layout', '', '1C', $layout_json, $form_namespace);
    echo $layout_obj->attach_toolbar_cell("toolbar", "a");  
    echo $toolbar_obj->init_by_attach("toolbar", $form_namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', $form_namespace . '.save_click');

    $form_name = 'payment_rfp_form';
   
    $sp_url_counterparty = "EXEC spa_source_counterparty_maintain 'c'";
    $counterparty_dropdown = $form_obj->adiha_form_dropdown($sp_url_counterparty, 0, 1, false, '');

    $sp_url_approver = "EXEC spa_get_user_name";
    $approver_dropdown = $form_obj->adiha_form_dropdown($sp_url_approver, 0, 1, false, ''); 

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
                            "name":"counterparty_id",
                            "label":"Counterparty",
                            "position":"label-top",
                            "offsetLeft":"'.$ui_settings['offset_left'].'",
                            "labelWidth":"auto",
                            "inputWidth":"'.$ui_settings['field_size'].'",
                            "tooltip":"Counterparty",
                            "filtering":"true",
                            "options": ' . $counterparty_dropdown . ',
                            "required":true,
                            "userdata":{"validation_message":"Required Field"}
                         },{  
                            "type":"combo",
                            "name":"payment_mode",
                            "label":"Method of Payment",
                            "position":"label-top",
                            "offsetLeft":"'.$ui_settings['offset_left'].'",
                            "labelWidth":"auto",
                            "inputWidth":"'.$ui_settings['field_size'].'",
                            "tooltip":"Method of Payment",
                            "filtering":"true",
                            "options": [{text:"ACH",value:"a","selected":"true"},{text:"Wire",value:"w"},{text:"Check",value:"c"}],
                            "required":true,
                            "userdata":{"validation_message":"Required Field"}
                         },{  
                            "type":"newcolumn"
                         },{  
                            "type":"combo",
                            "name":"approver",
                            "label":"Approver",
                            "position":"label-top",
                            "offsetLeft":"'.$ui_settings['offset_left'].'",
                            "labelWidth":"auto",
                            "inputWidth":"'.$ui_settings['field_size'].'",
                            "tooltip":"Approver",
                            "filtering":"true",
                            "options": '. $approver_dropdown . ',
                            "required":true,
                            "userdata":{"validation_message":"Required Field"}
                         },{  
                            "type":"combo",
                            "name":"addenda_line",
                            "label":"Addenda Lines",
                            "position":"label-top",
                            "offsetLeft":"'.$ui_settings['offset_left'].'",
                            "labelWidth":"auto",
                            "inputWidth":"'.$ui_settings['field_size'].'",
                            "tooltip":"Addenda Lines",
                            "filtering":"true",
                            "options": [{text:"Yes",value:"y"},{text:"No",value:"n","selected":"true"}],
                            "required":true,
                            "userdata":{"validation_message":"Required Field"}
                         }
                      ]
                    }
                ]';
        
    
   
    echo $layout_obj->attach_form($form_name, 'a');
    $form_obj->init_by_attach($form_name, $form_namespace);
    echo $form_obj->load_form($form_json);
     
    echo $layout_obj->close_layout();
?>
<script type="text/javascript">
    var call_from = '<?php echo $call_from; ?>';
    var calc_id = '<?php echo $calc_id; ?>';
    var payment_ins_header_id = '<?php echo $payment_ins_header_id; ?>';
    
	payment_rfp.save_click = function(id) {
		if (id == 'ok') {
            var attached_obj = payment_rfp.payment_rfp_form;
            var status = validate_form(attached_obj);
            if (status == false) return;
            
            var payment_mode = payment_rfp.payment_rfp_form.getItemValue('payment_mode');
			var addenda_line = payment_rfp.payment_rfp_form.getItemValue('addenda_line');
        	var counterparty_id = payment_rfp.payment_rfp_form.getItemValue('counterparty_id');
        	var approver = payment_rfp.payment_rfp_form.getItemValue('approver');
           
            var url = js_php_path + 'dev/template/RFP_report_Excel.php?counterparty_id=' + counterparty_id + '&payment_mode=' + payment_mode + '&addenda_line=' + addenda_line + '&approver=' + approver + '&payment_ins_header_id=' + payment_ins_header_id;
            
            var rfp_win = new dhtmlXWindows();
            var win = rfp_win.createWindow('w1', 0, 0, 600, 400);
            win.setText('RFP');
            win.centerOnScreen();
            win.maximize();
            win.attachURL(url, false, '');
            win.hide();
            
            setTimeout(function(){
                win.close();
            }, 2000);
            
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