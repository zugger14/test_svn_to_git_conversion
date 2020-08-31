
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
    $default_gl_id = get_sanitized_value($_GET["default_gl_id"] ?? ''); 
    $detail_id = get_sanitized_value($_GET["detail_id"] ?? ''); 
    
    
    $term_start = get_sanitized_value($_GET["term_start"] ?? ''); 
    $term_end = get_sanitized_value($_GET["term_end"] ?? ''); 
    $debit_gl_number = get_sanitized_value($_GET["debit_gl_number"] ?? ''); 
    $credit_gl_number = get_sanitized_value($_GET["credit_gl_number"] ?? ''); 
    $netting_debit_gl_number = get_sanitized_value($_GET["netting_debit_gl_number"] ?? '');
    $netting_credit_gl_number = get_sanitized_value($_GET["netting_credit_gl_number"] ?? '');
    $debit_gl_number_minus = get_sanitized_value($_GET["debit_gl_number_minus"] ?? '');
    $credit_gl_number_minus = get_sanitized_value($_GET["credit_gl_number_minus"] ?? '');
    $netting_debit_gl_number_minus = get_sanitized_value($_GET["netting_debit_gl_number_minus"] ?? '');
    $netting_credit_gl_number_minus = get_sanitized_value($_GET["netting_credit_gl_number_minus"] ?? '');
    $debit_volume_multiplier = get_sanitized_value($_GET["debit_volume_multiplier"] ?? '');
    $credit_volume_multiplier = get_sanitized_value($_GET["credit_volume_multiplier"] ?? '');
    $debit_remark = get_sanitized_value($_GET["debit_remark"] ?? '');
    $credit_remark = get_sanitized_value($_GET["credit_remark"] ?? '');
    $uom_id = get_sanitized_value($_GET["uom_id"] ?? '');
    
    $flag = get_sanitized_value($_GET["flag"] ?? '');
    $form_namespace = 'cc_glcode_detail';
    $right = get_sanitized_value($_REQUEST['right']) ?? '';

    if ($right == '') {
        $rights_gl_group_detail_insert = 10103312;
    } else {
        $rights_gl_group_detail_insert = $right;
    }

    $rights_gl_group_detail_insert = $right;
   
    list (            
        $has_rights_gl_group_detail_insert
    ) = build_security_rights(
        $rights_gl_group_detail_insert 
    );
    
    $enable_gl_group_detail_insert = ($has_rights_gl_group_detail_insert) ? 'false' : 'true';
   
    $layout_json = '[{id: "a", header:false}]';
    $toolbar_json = '[
                        { id: "save", type: "button", img: "tick.png", text:"OK", title: "OK", disabled: ' . $rights_gl_group_detail_insert . '},
                        { id: "close", type: "button", img: "close.gif", text:"Close", title: "Close"}  
                    ]';
    
    
    $filter_sql = "EXEC spa_create_application_ui_json @flag='j', 
                                                        @application_function_id='10103312', 
                                                        @template_name='cc_glcode_detail', 
                                                        @group_name='General', 
                                                        @parse_xml = '<Root><PSRecordSet detail_id=\"" . $detail_id . "\"></PSRecordSet></Root>'";
    $filter_arr = readXMLURL2($filter_sql);
    $form_json = $filter_arr[0]['form_json'];

    $layout_obj = new AdihaLayout();
    $toolbar_obj = new AdihaToolbar();
    $form_obj = new AdihaForm();

    echo $layout_obj->init_layout('cc_glcode_detail', '', '1C', $layout_json, $form_namespace);
    echo $layout_obj->attach_toolbar_cell("toolbar", "a");  
    echo $toolbar_obj->init_by_attach("toolbar", $form_namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', $form_namespace . '.save_click');
    
    
    
    $form_name = 'frm_cc_glcode_detail';
    echo $layout_obj->attach_form($form_name, 'a');
    
    $form_obj->init_by_attach($form_name, $form_namespace);
    echo $form_obj->load_form($form_json);
    
    //hardcored... need to workout on this
    //echo 'cc_glcode_detail.frm_cc_glcode_detail.setCalendarDateFormat("term_start", "%m/%d/%Y", "%m/%d/%Y");';
    //echo 'cc_glcode_detail.frm_cc_glcode_detail.setCalendarDateFormat("term_end", "%m/%d/%Y", "%m/%d/%Y");';
    
    
    echo $layout_obj->close_layout();
?>
<script type="text/javascript">
    
    var flag = '<?php echo $flag;?>';
    
    
    $(function() {       
        
        if (flag == 'u') {        
            var term_start = '<?php echo $term_start;?>';
            var term_end = '<?php echo $term_end;?>';
            var debit_gl_number = <?php echo ($debit_gl_number == '') ? "''" : $debit_gl_number;?>;
            var credit_gl_number = <?php echo ($credit_gl_number == '') ? "''" : $credit_gl_number;?>;
            var netting_debit_gl_number = <?php echo ($netting_debit_gl_number == '') ? "''" : $netting_debit_gl_number ;?>;
            var netting_credit_gl_number = <?php echo ($netting_credit_gl_number == '') ? "''" : $netting_credit_gl_number ;?>;
            var debit_gl_number_minus = <?php echo ($debit_gl_number_minus == '') ? "''" : $debit_gl_number_minus ;?>;
            var credit_gl_number_minus = <?php echo ($credit_gl_number_minus == '') ? "''" : $credit_gl_number_minus ;?>;		
            var netting_debit_gl_number_minus = <?php echo ($netting_debit_gl_number_minus == '') ? "''" : $netting_debit_gl_number_minus ;?>;
            var netting_credit_gl_number_minus = <?php echo ($netting_credit_gl_number_minus == '') ? "''" : $netting_credit_gl_number_minus ;?>;
            var debit_volume_multiplier = <?php echo ($debit_volume_multiplier == '') ? "''" : $debit_volume_multiplier ;?>;
            var credit_volume_multiplier = <?php echo ($credit_volume_multiplier == '') ? "''" : $credit_volume_multiplier ;?>;
            var debit_remark = <?php echo ($debit_remark == '') ? "''" : $debit_remark ;?>;
            var credit_remark = <?php echo ($credit_remark == '') ? "''" : $credit_remark ;?>;
            var uom_id = <?php echo ($uom_id == '') ? "''" : $uom_id  ;?>;
            
			
            cc_glcode_detail.frm_cc_glcode_detail.setItemValue('term_start', term_start);
            cc_glcode_detail.frm_cc_glcode_detail.setItemValue('term_end', term_end);
            cc_glcode_detail.frm_cc_glcode_detail.setItemValue('debit_gl_number', debit_gl_number);
            cc_glcode_detail.frm_cc_glcode_detail.setItemValue('credit_gl_number', credit_gl_number);
            cc_glcode_detail.frm_cc_glcode_detail.setItemValue('netting_debit_gl_number', netting_debit_gl_number);
            cc_glcode_detail.frm_cc_glcode_detail.setItemValue('netting_credit_gl_number', netting_credit_gl_number);
            cc_glcode_detail.frm_cc_glcode_detail.setItemValue('debit_gl_number_minus', debit_gl_number_minus);
            cc_glcode_detail.frm_cc_glcode_detail.setItemValue('credit_gl_number_minus', credit_gl_number_minus);	
            cc_glcode_detail.frm_cc_glcode_detail.setItemValue('netting_debit_gl_number_minus', netting_debit_gl_number_minus);
            cc_glcode_detail.frm_cc_glcode_detail.setItemValue('netting_credit_gl_number_minus', netting_credit_gl_number_minus);
            cc_glcode_detail.frm_cc_glcode_detail.setItemValue('debit_volume_multiplier', debit_volume_multiplier);
            cc_glcode_detail.frm_cc_glcode_detail.setItemValue('credit_volume_multiplier', credit_volume_multiplier);
            cc_glcode_detail.frm_cc_glcode_detail.setItemValue('debit_remark', debit_remark);
            cc_glcode_detail.frm_cc_glcode_detail.setItemValue('credit_remark', credit_remark);
            cc_glcode_detail.frm_cc_glcode_detail.setItemValue('uom_id', uom_id);    
        }
    
    });
         
    
	cc_glcode_detail.save_click = function(id) { 
	   
        if (id == 'save') {            
            //check for mandatory fields
           /* if (cc_glcode_detail.frm_cc_glcode_detail.validate() == false) { 
                generate_error_message();
                
                return;
            } */

            if(!validate_form(cc_glcode_detail.frm_cc_glcode_detail)) { 
                generate_error_message();
                return;
            }
            
            flag = "<?php echo $flag;?>";
            filter_param =  new Array();  
            form_data = cc_glcode_detail.frm_cc_glcode_detail.getFormData();
	        
	        for (var a in form_data) {
	            if (form_data[a] != '' && form_data[a] != null) {
	                if (cc_glcode_detail.frm_cc_glcode_detail.getItemType(a) == 'calendar') {
	                    value = cc_glcode_detail.frm_cc_glcode_detail.getItemValue(a, true);
	                } else {
						value = form_data[a];
	                }	                
	                filter_param[a] = value;                    
	            }
	        }
            
            if (filter_param['term_start'] > filter_param['term_end']) {
                dhtmlx.alert({
                    title:"Alert",
                    type:"alert",
                    text:'<b>Term Start</b> should be less than <b>Term End</b>.'
                });                 
                return;
            }
            parent.invoice_glcode.callback_modified_detail(flag, filter_param);
            parent.new_win.close();
	   } else if (id == 'close') {
       	    parent.new_win.close();
            
       }         
	}
    
    function deparam(querystring) {
        // remove any preceding url and split
        querystring = querystring.substring(querystring.indexOf('?') + 1).split('&');
        var params = {}, pair, d = decodeURIComponent, i;
        // march and parse
        for (i = querystring.length; i > 0;) {
            pair = querystring[--i].split('=');
            params[d(pair[0])] = d(pair[1]);
        }
        
        return params;
    };
    
    /*
    
    if (id == 'save') {			
			form_data = cc_glcode_detail.frm_cc_glcode_detail.getFormData();
	        var filter_param = '';
	        for (var a in form_data) {
	            if (form_data[a] != '' && form_data[a] != null) {
	                if (cc_glcode_detail.frm_cc_glcode_detail.getItemType(a) == 'calendar') {
	                    value = cc_glcode_detail.frm_cc_glcode_detail.getItemValue(a, true);
	                } else {
	                    value = form_data[a];
	                }
	                
	                filter_param += "&" + a + '=' + value;
	            }
	        }
	        var param = {
	            "flag": '<?php echo $flag; ?>',
	            "action": '[spa_get_adjustment_defaultGLCode_detail]',
                "detail_id": '<?php echo $detail_id; ?>',
                "default_gl_id": '<?php echo $default_gl_id; ?>'
                
	        };
            
     
	        param = $.param(param);
	        param = param + filter_param;
            param = deparam(param);
            adiha_post_data('alert', param, '', '');


		
	   }
   
    
        */
    
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