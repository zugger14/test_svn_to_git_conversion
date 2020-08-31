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
	$form_namespace = 'generateConfirmation';
    $deal_ids = (isset($_REQUEST["deal_ids"]) && $_REQUEST["deal_ids"] != '') ? get_sanitized_value($_REQUEST["deal_ids"]) : 'NULL';
    
    function explode_key_val_array(&$item1, $key, $prefix) {
        $item1 = "$key$prefix$item1";
    }
    /*                        
    if ($confirm_status_flag == 'r') {
        $rfx_custom_report_name = 'Replacement Confirmation Report.rdl';
    } else {
        $rfx_custom_report_name = 'Deal Confirm Report Collection.rdl';
                                
    } 
    */
    $rfx_custom_report_name = 'Confirm Replacement Report Collection.rdl'; 
    $rfx_custom_report_title = 'Confirmation Report Batch';  
         
    $rfx_custom_report_filter = '';
    $rfx_custom_report_param = array();
    $rfx_custom_report_param['source_deal_header_id'] = $deal_ids;
    $rfx_custom_report_param['export_type'] = 'HTML4.0';

    $rpc_url = $app_php_script_loc . '../adiha.html.forms/_reporting/report_manager_dhx/report.viewer.custom.php';
    $rpc_arg = '?__user_name__=' . $app_user_name . '&session_id=' . $session_id;
    $rpc_arg .= '&windowTitle=Report%20viewer&export_type=HTML4.0';
    $rpc_arg .= '&disable_header=1&report_title=' . $rfx_custom_report_title . '&report_name=' . $rfx_custom_report_name;
    $rpc_arg .= "&param_list=" . implode(',', array_keys($rfx_custom_report_param));
    array_walk($rfx_custom_report_param, 'explode_key_val_array', '=');
    $rfx_custom_report_filter = implode('&', $rfx_custom_report_param);
    $rpc_arg .= '&' . $rfx_custom_report_filter;
    $iframe_src = $rpc_url . $rpc_arg;
    $iframe_src .= '&batch_call=y';
    $rfx_js_url_call = $iframe_src;

    $layout_json = '[{id: "a", header:false}]';
    $layout_obj = new AdihaLayout();    
    echo $layout_obj->init_layout('generate_confirm_layout', '', '1C', $layout_json, $form_namespace);
    echo $layout_obj->attach_form('generate_confirm_form', 'a');
    echo $layout_obj->attach_url('a', $iframe_src);
    echo $layout_obj->close_layout();
?>
</body>
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