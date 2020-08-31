<?php
/**
* Trade ticket screen
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
<body>
<?php
$source_deal_header_id = (isset($_REQUEST["deal_ids"]) && $_REQUEST["deal_ids"] != '') ? get_sanitized_value($_REQUEST["deal_ids"]) : 'NULL';
$php_script_loc = $app_php_script_loc;

$trade_ticket_rights = 10131020;
$rights_trade_ticket_sign_off_trader = 10131021;
$rights_trade_ticket_sign_off_risk = 10131022;
$rights_trade_ticket_sign_off_back_office = 10131023;

//$btn_trader_sign_off_enabled = false;
//$btn_risk_sign_off_enabled = false;
//$btn_back_office_sign_off_enabled = false;

list (
    $has_rights_trade_ticket_sign_off_trader,
    $has_rights_trade_ticket_sign_off_risk,
    $has_rights_trade_ticket_sign_off_back_office
) = build_security_rights (
    $rights_trade_ticket_sign_off_trader,
    $rights_trade_ticket_sign_off_risk,
    $rights_trade_ticket_sign_off_back_office
);

$show_button = get_sanitized_value($_GET['show_button'] ?? 'NULL');
    
$xml_file = 'EXEC spa_trade_ticket_sign_off @flag=a, @source_deal_header_id=' . $source_deal_header_id;
$return_value = readXMLURL($xml_file);
$trader_login_id = $return_value[0][0];
$verified_date = $return_value[0][1];
$verified_by = $return_value[0][2];
$risk_sign_off_date = $return_value[0][3];
$risk_sign_off_by = $return_value[0][4];
$back_office_sign_off_date = $return_value[0][5];
$back_office_sign_off_by_name = $return_value[0][6];
$deal_rules = $return_value[0][7];
$confirm_rules = $return_value[0][8];
$template_id = ($return_value[0][9] != '') ? $return_value[0][9] : 'NULL';

//$has_rights_trade_ticket_sign_off_trader = 0;

$button_state = Array(
                        "trader"=>0,
                        "risk"=>0,
                        "back_office"=>0
                    );
if ($verified_date == '' && $verified_by == '') {
	if ($has_rights_trade_ticket_sign_off_trader){
        $button_state["trader"] = 1;
	}
} else if ($risk_sign_off_date == '' || $risk_sign_off_by == '') {
    if ($has_rights_trade_ticket_sign_off_risk){
        $button_state["risk"] = 1;
    }
} else if ($back_office_sign_off_date == '' || $back_office_sign_off_by_name == '') {
    if ($has_rights_trade_ticket_sign_off_back_office){
        $button_state["back_office"] = 1;
    }
}

if (count(explode(',', $source_deal_header_id)) > 1) {
    $has_rights_trade_ticket_sign_off_trader = 0;
    $has_rights_trade_ticket_sign_off_risk = 0;
    $has_rights_trade_ticket_sign_off_back_office = 0;
    $rfx_custom_report_name = 'Trade Ticket Collection.rdl';
    $rfx_custom_report_title = 'Trade Ticket Collection';
} else {                
    $xml_file = 'EXEC spa_contract_report_template @flag=t, @template_id=' . $template_id . ', @template_type=' . 42019;
    $return_value = readXMLURL($xml_file);
    $rfx_custom_report_name = $return_value[0][1];
    $rfx_custom_report_title = $return_value[0][0];
    $rfx_custom_report_doc_type  = $return_value[0][2];
}

$rfx_custom_report_filter = '';
$rfx_custom_report_param = array();
$rfx_custom_report_param['source_deal_header_id'] = $source_deal_header_id;
$rfx_custom_report_param['t_type'] = '33';
$rfx_custom_report_param['t_category'] = '42019';
$is_excel = ($rfx_custom_report_doc_type == 'e') ? 1 : 0;
$rfx_custom_report_param['is_excel'] = $is_excel;
$rfx_custom_report_param['trade_type_pdf'] = 'NULL'; 


$rpc_url = $app_php_script_loc . '../adiha.html.forms/_reporting/report_manager_dhx/report.viewer.custom.php';
$rpc_arg = '?__user_name__=' . $user_name . '&session_id=' . $session_id;
$rpc_arg .= '&windowTitle=Report%20viewer&export_type=HTML4.0';
$rpc_arg .= '&disable_header=1&batch_call_from=trade_ticket&report_name=' . $rfx_custom_report_name;
$rpc_arg .= '&report_title=' . $rfx_custom_report_title;
$rpc_arg .= '&param_list=' . implode(',', array_keys($rfx_custom_report_param));
array_walk($rfx_custom_report_param, 'explode_key_val_array', '=');
$rfx_custom_report_filter = implode('&', $rfx_custom_report_param);
$rpc_arg .= '&' . $rfx_custom_report_filter;
$iframe_src = $rpc_url . $rpc_arg;
$iframe_src .= '&batch_call=y';
$rfx_js_url_call = $iframe_src;

$layout_json = '[
                    {
                        id:             "a",
                        text:           "Trade Ticket",
                        width:          720,
                        header:         false,
                        collapse:       false,
                        fix_size:       [false,null]
                    }
                ]';
 
$form_namespace = 'tradeTicket';
$trade_ticket_layout = new AdihaLayout();
echo $trade_ticket_layout->init_layout('trade_ticket_layout', '', '1C', $layout_json, $form_namespace);

$toolbar_namespace = 'trade_ticket_toolbar';
$toolbar_json = '[ {id:"t1", text:"Action", img:"action.gif", items:[
                    {id:"trader_signoff", text:"Trader Sign Off", img:"trader_signoff.gif", imgdis:"trader_signoff_dis.gif", title: "Trader Sign Off", enabled:"'.$button_state["trader"].'"},
                    {id:"risk_signoff", text:"Risk Signoff", img:"risk_signoff.gif", imgdis:"risk_signoff_dis.gif", title: "Risk Signoff", enabled:"'.$button_state["risk"].'"},
                    {id:"backoffice_signoff", text:"Backoffice Signoff", img:"backoffice_signoff.gif", imgdis:"backoffice_signoff_dis.gif", title: "Backoffice Signoff", enabled:"'.$button_state["back_office"].'"}
                    ]},
                   {id:"t2", text:"Export", img:"export.gif", imgdis:"export_dis.gif", items:[
                    {id:"trade_pdf", text:"PDF", img:"pdf.gif"}
                   ]}                        
                ]';
echo $trade_ticket_layout->attach_menu_cell($toolbar_namespace, "a"); 
$toolbar_trade_ticket = new AdihaMenu();
echo $toolbar_trade_ticket->init_by_attach($toolbar_namespace, $form_namespace);
echo $toolbar_trade_ticket->load_menu($toolbar_json);
echo $toolbar_trade_ticket->attach_event('', 'onClick', $form_namespace . '.run_toolbar_click');
echo $trade_ticket_layout->attach_url('a', $iframe_src);
echo $trade_ticket_layout->close_layout();
?>
</body>
<script type="text/javascript">
    var source_deal_header_id = '<?php echo $source_deal_header_id; ?>';
	var is_excel = '<?php echo $is_excel; ?>';
	var has_rights_trade_ticket_sign_off_risk = <?php echo (($has_rights_trade_ticket_sign_off_risk) ? $has_rights_trade_ticket_sign_off_risk : '0'); ?>;
	var has_rights_trade_ticket_sign_off_back_office = <?php echo (($has_rights_trade_ticket_sign_off_back_office) ? $has_rights_trade_ticket_sign_off_back_office : '0'); ?>;
    var report_doc_type  =  '<?php echo $rfx_custom_report_doc_type; ?>'
    
    $(function() {
        if(report_doc_type == 'e'){
            tradeTicket.trade_ticket_toolbar.showItem('t2');
            tradeTicket.trade_ticket_toolbar.hideItem('t1');
        } else {
            tradeTicket.trade_ticket_toolbar.hideItem('t2');
            tradeTicket.trade_ticket_toolbar.showItem('t1');
        }
     });

    var deal_rules = '<?php echo $deal_rules; ?>';
    var confirm_rules = '<?php echo $confirm_rules; ?>';
    var show_button = '<?php echo $show_button; ?>';
    		
    if (show_button == 'n') {
        tradeTicket.trade_ticket_toolbar.setItemDisabled('trader_signoff');
		if(has_rights_trade_ticket_sign_off_risk){
		tradeTicket.trade_ticket_toolbar.setItemEnabled('risk_signoff');
		}
		if(has_rights_trade_ticket_sign_off_back_office){
		tradeTicket.trade_ticket_toolbar.setItemEnabled('backoffice_signoff');
		}
	}
    
    function reload_rfx_frame(){
        tradeTicket.trade_ticket_layout.cells('a').attachURL("<?php echo $iframe_src; ?>")
    }
    
    function get_message(arg) {
        switch (arg) {
            case 'DELETE_CONFIRM':
                return 'Please Provide Profile Name!';
            case 'TRADE_TICKET_SIGN_OFF_SUCCESS':
                return 'Trade Ticket Succesfully Signed Off';
            case 'TRADE_TICKET_SIGN_OFF_FAILURE':
                return 'Fail to SignOff the Trade Ticket';
        }
    }
                
    tradeTicket.run_toolbar_click = function(id) {
        switch(id) {
            case 'trader_signoff':
                var success_msg = get_message('TRADE_TICKET_SIGN_OFF_SUCCESS');
                var error_msg = get_message('TRADE_TICKET_SIGN_OFF_FAILURE');
                
            	data = {"action": "spa_trade_ticket_sign_off", 
                        "flag": "t",
                        "source_deal_header_id": source_deal_header_id
                        };
                adiha_post_data("alert", data, success_msg, error_msg, 'tradeTicket.callback_trader_signoff');                  
                break;
                
            case 'risk_signoff':
                var success_msg = get_message('TRADE_TICKET_SIGN_OFF_SUCCESS');
                var error_msg = get_message('TRADE_TICKET_SIGN_OFF_FAILURE');
                
                data = {"action": "spa_trade_ticket_sign_off", 
                        "flag": "r",
                        "source_deal_header_id": source_deal_header_id
                        };
                        
                adiha_post_data("alert", data, success_msg, error_msg, 'tradeTicket.callback_risk_signoff'); 
                break;
                
            case 'backoffice_signoff':
                var success_msg = get_message('TRADE_TICKET_SIGN_OFF_SUCCESS');
                var error_msg = get_message('TRADE_TICKET_SIGN_OFF_FAILURE');
            	
                data = {"action": "spa_trade_ticket_sign_off", 
                        "flag": "b",    
                        "source_deal_header_id": source_deal_header_id
                        };
                        
                adiha_post_data("alert", data, success_msg, error_msg, 'tradeTicket.callback_backoffice_signoff');  
                break;

            case 'trade_pdf':
               trade_ticket_pdf(source_deal_header_id);
               break;
               
            default:
                break;
                
        }
    }

    function trade_ticket_pdf (source_deal_header_id) {
        var trade_type_pdf = 'PDF';
        var my_url = "<?php echo $rfx_js_url_call; ?>";
            my_url = my_url.replace(/&source_deal_header_id=NULL/, "&source_deal_header_id=" + source_deal_header_id);
            my_url = my_url.replace(/&is_excel=NULL/, "&is_excel=" + is_excel);
            my_url = my_url.replace(/&t_type=NULL/, "&t_type=33"  );
            my_url = my_url.replace(/&t_category=NULL/, "&t_category=42019");
            my_url = my_url.replace(/&trade_type_pdf=NULL/, "&trade_type_pdf=" + trade_type_pdf);

        tradeTicket.trade_ticket_layout.cells('a').attachURL(my_url);
    }

    tradeTicket.callback_trader_signoff = function(result) {
        if (result[0].errorcode == "Success") {
            reload_rfx_frame();
            tradeTicket.trade_ticket_toolbar.setItemDisabled('trader_signoff');
			if(has_rights_trade_ticket_sign_off_risk){
            tradeTicket.trade_ticket_toolbar.setItemEnabled('risk_signoff');
			}
			//if(has_rights_trade_ticket_sign_off_back_office){			
           // tradeTicket.trade_ticket_toolbar.setItemEnabled('backoffice_signoff');
			//}
		
        }
    }
     
    tradeTicket.callback_risk_signoff = function(result) {
        if (result[0].errorcode == "Success") {
            reload_rfx_frame();
            tradeTicket.trade_ticket_toolbar.setItemDisabled('risk_signoff');
        }
		if(has_rights_trade_ticket_sign_off_back_office) {
		 tradeTicket.trade_ticket_toolbar.setItemEnabled('backoffice_signoff');
		}
    }
      
    tradeTicket.callback_backoffice_signoff = function(result) {
        if (result[0].errorcode == "Success") {
            reload_rfx_frame();
            tradeTicket.trade_ticket_toolbar.setItemDisabled('backoffice_signoff');
        }
    }
    
	/*
	* Call from custom view report
	*/
	function window_download(url) {
		location.href = url;
		window_invoice.close();
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
</html>