<?php
/**
* Maintain invoice screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <?php
        include '../../../adiha.php.scripts/components/include.file.v3.php'; 
        require('../../../adiha.html.forms/_setup/manage_documents/manage.documents.button.php');
    ?>
</head>
<?php
    $counterparty_id = get_sanitized_value($_GET['counterparty_id'] ?? '');
    $contract_id = get_sanitized_value($_GET['contract_id'] ?? '');
    $date_from = get_sanitized_value($_GET['date_from'] ?? '');
    $date_to= get_sanitized_value($_GET['date_to'] ?? '');
    $counterparty= get_sanitized_value($_GET['counterparty'] ?? '');
    $contract= get_sanitized_value($_GET['contract'] ?? '');
    $invoice_id = get_sanitized_value($_GET['invoice_id'] ?? '');
    $counterparty_type = get_sanitized_value($_GET['counterparty_type'] ?? '');
    $calc_id = get_sanitized_value($_REQUEST['calc_id'] ?? '');
    
    if ($calc_id != '') {
        $invoice_no_sql = "SELECT invoice_number, prod_date, prod_date_to FROM calc_invoice_volume_variance WHERE calc_id = " . $calc_id;
        $invoice_data = readXMLURL2($invoice_no_sql);
        $invoice_id = $invoice_data[0]['invoice_number'];
        $prod_date = $invoice_data[0]['prod_date'];
		$prod_date_to = $invoice_data[0]['prod_date_to'];
    }
    
    $rfx_custom_report_filter = '';
    $rfx_custom_report_param = array();
    $rfx_custom_report_param['invoice_ids'] = 'NULL';
    $rfx_custom_report_param['export_type'] = 'NULL';
    $rfx_custom_report_param['runtime_user'] = 'NULL';
    $rfx_custom_report_param['is_excel'] = 'NULL';
    $rfx_custom_report_param['t_type'] = 'NULL';
    $rfx_custom_report_param['t_category'] = 'NULL';

    $rpc_url  = $app_php_script_loc . '../adiha.html.forms/_reporting/report_manager_dhx/report.viewer.custom.php';
    $rpc_arg  = '?__user_name__=' . $app_user_name . '&session_id=' . $session_id;
    $rpc_arg .= '&windowTitle=Report%20viewer&export_type=NULL&invoice_ids=NULL&runtime_user=NULL&is_excel=NULL&t_type=38&t_category=42031';
    $rpc_arg .= '&disable_header=2&report_name=Invoice Report Collection'; // disable_header=2 is for multiple Invoice view.
    $rpc_arg .= '&param_list=' . implode(',', array_keys($rfx_custom_report_param));
    array_walk($rfx_custom_report_param, 'explode_key_val_array', '=');
    $rfx_custom_report_filter = implode('&', $rfx_custom_report_param);
    $rpc_arg .= "&" . $rfx_custom_report_filter;
    $iframe_src = $rpc_url . $rpc_arg;
    $iframe_src .= '&batch_call=y&batch_call_from=invoice';
    $rfx_js_url_call = $iframe_src;
    
    $php_script_loc = $app_php_script_loc;
    $date_format = str_replace('yyyy', '%Y', str_replace('dd', '%d', str_replace('mm', '%m', $client_date_format)));
    
    $filter_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10221300', @template_name='SettlementHistory', @group_name='Filters'";
    $filter_arr = readXMLURL2($filter_sql);
    
    $tab_id = $filter_arr[0]['tab_id'];
    $form_json = $filter_arr[0]['form_json'];
    $dependent_combos = $filter_arr[0]['dependent_combo'];
    
    if($dependent_combos)
        $dependent_combo_array = explode(',', $dependent_combos);
    else
        $dependent_combo_array=NULL;
    
    $rights_view_invoice = 10221300;
    $rights_view_invoice_delete = 10221310;
    $rights_view_invoice_void = 10221311;
    $rights_view_invoice_unfinalize = 10221316;
	$rights_view_invoice_finalize = 10221315;
    $rights_view_invoice_lock_unlock = 10221317;
    $rights_view_invoice_invoice_status = 10221319; 
    $rights_view_invoice_save = 10221314;
    $rights_view_invoice_document = 10102900; 
    $right_view_invoice_export = 10221313;
    $rights_manual_adjustment = 10221330;
    $rights_manual_adjustment_iu = 10221331;
    $rights_manual_adjustment_delete = 10221332;
    $rights_invoice_dispute_iu = 10221346;
    $rights_invoice_dispute_delete = 10221347;
    $rights_invoice_split = 10221318; 
    $rights_invoice_reprocess = 10221000;
    $rights_counterparty_invoice = 10221312;
	$rights_gl_export = 10202201;
   list (
        $has_rights_view_invoice,
        $has_rights_view_invoice_delete,
        $has_rights_view_invoice_void,
        $has_rights_view_invoice_unfinalize,
        $has_rights_view_invoice_lock_unlock,
        $has_rights_view_invoice_invoice_status,
        $has_rights_view_invoice_save,
        $has_rights_view_invoice_document,
        $has_right_view_invoice_export,
        $has_rights_manual_adjustment,
        $has_rights_manual_adjustment_iu,
        $has_rights_manual_adjustment_delete,
        $has_rights_invoice_dispute_iu,
        $has_rights_invoice_dispute_delete,
        $has_rights_invoice_split,
        $has_rights_invoice_reprocess,
        $has_rights_counterparty_invoice,
		$has_rights_gl_export,      
		$has_rights_view_invoice_finalize
    ) = build_security_rights(
        $rights_view_invoice,
        $rights_view_invoice_delete,
        $rights_view_invoice_void,
        $rights_view_invoice_unfinalize,
        $rights_view_invoice_lock_unlock,
        $rights_view_invoice_invoice_status,
        $rights_view_invoice_save,
        $rights_view_invoice_document,
        $right_view_invoice_export,
        $rights_manual_adjustment,
        $rights_manual_adjustment_iu,
        $rights_manual_adjustment_delete,
        $rights_invoice_dispute_iu,
        $rights_invoice_dispute_delete,
        $rights_invoice_split,
        $rights_invoice_reprocess,
        $rights_counterparty_invoice,
		$rights_gl_export, 
        $rights_view_invoice_finalize     
    );

    $form_namespace = 'setHistory';

    $layout_json = '[   
                        {id: "a", text: "Apply Filter",collapse: false, height: 100 ,width:550},
                        {id: "b", text: "Filters", height:200},
                        {id: "c", text: "Invoice"},
                        {id: "d", text: "Invoice Details"}
                    ]';
    $layout_obj = new AdihaLayout();
    //echo $layout_obj->init_layout('set_history', '', '3J', $layout_json, $form_namespace);
    echo $layout_obj->init_layout('set_history', '', '4G', $layout_json, $form_namespace);
    echo $layout_obj->set_text("c",get_locale_value("Invoices"));
    $menu_name = 'invoice_menu';
    $menu_json = '[
            {id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif"},
            {id:"t", text:"Edit", img:"edit.gif", imgdis:"edit_dis.gif", disabled:true, items:[
                {id:"delete", text:"Delete", img:"delete.gif",enabled:"'.$has_rights_view_invoice_delete.'"}
            ]},
            {id:"t1", text:"Process", img:"action.gif", imgdis:"action_dis.gif", enabled:"false", items:[
                {id:"lock", text:"Lock", img:"lock.gif", imgdis:"lock_dis.gif",enabled:"'.$has_rights_view_invoice_lock_unlock.'"},
                {id:"unlock", text:"UnLock", img:"unlock.gif", imgdis:"unlock_dis.gif",enabled:"'.$has_rights_view_invoice_lock_unlock.'"},
                    {id:"finalize", text:"Finalize", img:"finalize.gif",imgdis:"finalize_dis.gif",enabled:"'.$has_rights_view_invoice_finalize.'"},
                    {id:"unfinalize", text:"UnFinalize", img:"unfinalize.gif", imgdis:"unfinalize_dis.gif",enabled:"'.$has_rights_view_invoice_unfinalize.'"},
                {id:"invoice_status", text:"Update Workflow Status", img:"update_invoice_stat.gif", imgdis:"update_invoice_stat_dis.gif",enabled:"'.$has_rights_view_invoice_invoice_status.'"},
                {id:"audit", text:"View Audit", img:"audit.gif", imgdis:"audit_dis.gif", enabled:"false"}

            ]},
            {id:"t2", text:"Export", img:"export.gif", imgdis:"export_dis.gif", disabled:true, items:[
                {id:"data", text:"Data", items:[
                    {id:"excel", text:"Excel", img:"excel.gif"},
                    {id:"pdf", text:"PDF", img:"pdf.gif"}
                ]},
                {id:"invoice", text:"Invoice", items:[
                    {id:"invoice_html", text:"Generate Invoice", img:"html.gif"},
                    {id:"invoice_send", text:"Batch", img:"batch.gif"}
                ], enabled: "'.$has_right_view_invoice_export.'"} 
            ]},
            {id:"expand_collapse", text:"Expand/Collapse", img:"exp_col.gif", imgdis:"exp_col_dis.gif", enabled: 0},
            {id:"pivot", text:"Pivot", img:"pivot.gif", imgdis:"pivot_dis.gif", enabled: 0}
            ]';

    echo $layout_obj->attach_menu_layout_cell($menu_name, 'c', $menu_json, $form_namespace.'.menu_click');

    // attach filter form
    $filter_form_name = 'filter_form';
    echo $layout_obj->attach_form($filter_form_name, 'b');
    
    $filter_form_obj = new AdihaForm();
    
    $sp_url_invoice_status = "EXEC spa_staticdatavalues @flag=h, @type_id=20700";
    echo "invoice_status_dropdown = ".  $filter_form_obj->adiha_form_dropdown($sp_url_invoice_status, 0, 1, false, 2) . ";"."\n";

    $filter_form_obj->init_by_attach($filter_form_name, $form_namespace);

    echo $filter_form_obj->load_form($form_json);

    /*echo $filter_form_obj->attach_event('', 'onButtonClick', $form_namespace . '.filter_form_click', $form_namespace . '.' . $filter_form_name);
    echo 'dhxCombo = setHistory.filter_form.getCombo("apply_filters");
          dhxCombo.attachEvent("onChange", setHistory.filter_apply_change);';
    */

    //attach grid
    $invoice_grid_name = 'invoice_grid';
    echo $layout_obj->attach_grid_cell($invoice_grid_name, 'c');
    $invoice_grid_obj = new AdihaGrid();
    echo $layout_obj->attach_status_bar("c", true);
    echo $invoice_grid_obj->init_by_attach($invoice_grid_name, $form_namespace);
    echo $invoice_grid_obj->set_header("Invoice ID,Counterparty ID,Contract ID,Invoice Template,Date From,Date To,Invoice Date,Amount,Currency,Accounting Status,Workflow Status,Invoice Type,Lock Status,Payment Date,Calc ID,Finalized Date,Invoice Note,Invoice Status ID,As of Date,Incoming Invoice Amount,Variance,Invoice Ref ID,Invoice Ref No, Delta,Create Date,Create User,Update Date,Update User,Netting Calc ID,Invoice File Name,Document Type",",,,,,,,right,right,,,,,,,,,,,right,,,,,,,,,,");
    echo $invoice_grid_obj->set_columns_ids("invoice_number,counterparty_id,contract_id,invoice_template,date_from,date_to,settlement_date,amount,currency,calc_status,invoice_status,invoice_type,lock_status,payment_date,calc_id,finalized_date,invoice_note,invoice_status_id,as_of_date,incoming_invoice_amount,variance,inv_ref_id,invoice_ref_no,delta,create_date,create_user,update_date,update_user,netting_calc_id,invoice_file_name,document_type");
    echo $invoice_grid_obj->set_widths("200,150,150,150,150,150,150,150,150,150,150,150,150,150,150,150,150,150,200,150,150,150,150,150,150,150,150,150,150,150,150");
    echo $invoice_grid_obj->set_column_types("tree,ro_int,ro_int,ro,ro,ro,ro,ro_a,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro_a,ro_a,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro");
    echo $invoice_grid_obj->set_column_alignment(",,,,,,,right,right,,,,,,,,,,,right,,,,,,,,,,,");
    //echo $invoice_grid_obj->set_column_auto_size();
    echo $invoice_grid_obj->enable_multi_select();
    echo $invoice_grid_obj->set_column_visibility("false,true,true,false,false,false,false,false,false,false,false,false,false,false,true,true,true,true,true,true,true,true,true,false,true,true,true,true,true,false,true");
    echo $invoice_grid_obj->enable_paging(100, 'pagingArea_c', 'true');
    echo $invoice_grid_obj->enable_column_move('false,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,false,false,false,false,false');
    echo $invoice_grid_obj->set_sorting_preference('int,int,int,str,date,date,date,int,str,str,str,str,str,date,str,date,str,str,date,str,str,str,str,str,date,str,date,str,srt,str,str');
    echo $invoice_grid_obj->set_search_filter(false,"#text_filter,#numeric_filter,#numeric_filter,#text_filter,#text_filter,#text_filter,#text_filter,#numeric_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#numeric_filter,#numeric_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter");
    echo $invoice_grid_obj->split_grid('1');
    echo $invoice_grid_obj->return_init();
    echo $invoice_grid_obj->enable_header_menu();
    
    echo $invoice_grid_obj->attach_event('', 'onRowDblClicked', $form_namespace.'.create_invoice_detail_tab');
    echo $invoice_grid_obj->attach_event('', 'onRowSelect', $form_namespace.'.invoice_grid_select');
    //attach grid ends
    
    $tabbar_name = 'invoice_details';
    echo $layout_obj->attach_tab_cell($tabbar_name, 'd');
    $tabbar_obj = new AdihaTab();
    echo $tabbar_obj->init_by_attach($tabbar_name, $form_namespace);
    echo $tabbar_obj->enable_tab_close();
    echo $tabbar_obj->attach_event('', "onTabClose", 'setHistory.invoice_details_close');

    echo $layout_obj->close_layout();

    $category_name = 'Invoice';
    $category_sql = "SELECT value_id FROM static_data_value WHERE type_id = 25 AND code = '" . $category_name . "'";
    $category_data = readXMLURL2($category_sql);

    $invoice_template_options_sql = "EXEC('SELECT template_id, template_name FROM contract_report_template WHERE template_type = 38')";
    $invoice_template_options = readXMLURL($invoice_template_options_sql);

    $invoice_template_options_json = '';
    $invoice_template_options_json = '{"text":"", "value":""}';
    for ($i = 0; $i < sizeof($invoice_template_options); $i++) {
        $invoice_template_options_json .= ',{"text":"' . $invoice_template_options[$i][1] . '", "value":"' . $invoice_template_options[$i][0] . '"}';
    }
?>
<body class = "bfix2">
</body>
<style>
    html, body {
        width: 100%;
        height: 100%;
        margin: 0px;
        padding: 0px;
        background-color: #ebebeb;
        overflow: hidden;
    }
</style>
<!-- Invoice Summary Template -->
<script id="form_template" type="text/template">
    [{"type": "settings", "position": "label-top"},                
    {"type": "input", "name": "counterparty", "label": "Counterparty", "position": "label-top","readonly":1, "disabled":1, "value": "<%= counterparty %>","inputWidth":"<%= ui_settings['field_size'] %>", "offsetLeft": "<%= ui_settings['offset_left'] %>"},
    {"type": "newcolumn"},
    {"type": "input", "name": "contract", "label": "Contract", "readonly":1, "disabled":1, "value": "<%= contract %>", "inputWidth":"<%= ui_settings['field_size'] %>", "offsetLeft": "<%= ui_settings['offset_left'] %>"},
     {"type": "newcolumn"},
    {"type": "input", "name": "invoice_no", "label": "Invoice No", "readonly":1, "disabled":1, "value": "<%= invoice_no %>", "inputWidth":"<%= ui_settings['field_size'] %>", "offsetLeft": "<%= ui_settings['offset_left'] %>"},
    {"type": "newcolumn"},
    {"type": "input", "name": "invoice_type", "label": "Invoice Type", "readonly":1, "disabled":1, "value": "<%= invoice_type %>", "inputWidth":"<%= ui_settings['field_size'] %>", "offsetLeft": "<%= ui_settings['offset_left'] %>"},
    {"type": "newcolumn"},
    {"type": "combo", "filtering":"true", "name": "invoice_status", "disabled":1, "label": "Workflow Status", "position": "label-top", "options": <%= invoice_status_dropdown %>, "inputWidth":"<%= ui_settings['field_size'] %>", "offsetLeft": "<%= ui_settings['offset_left'] %>"},
    {"type": "newcolumn"},
    {"type": "input", "readonly":1, "disabled":1, "name": "calc_status", "<%= date_format %>":"true", "label": "Accounting Status", "value": "<%= calc_status %>", "inputWidth":"<%= ui_settings['field_size'] %>", "offsetLeft": "<%= ui_settings['offset_left'] %>"},
     {"type": "newcolumn"},
    {"type": "input", "value": "<%= as_of_date %>", "readonly":1, "disabled":1, "name": "as_of_date", "label": "As of Date", "inputWidth":"<%= ui_settings['field_size'] %>", "offsetLeft": "<%= ui_settings['offset_left'] %>"},
    {"type": "newcolumn"},
    {"type": "input", "value": "<%= date_from %>", "readonly":1, "disabled":1, "name": "prod_date_from", "label": "Date From", "inputWidth":"<%= ui_settings['field_size'] %>", "offsetLeft": "<%= ui_settings['offset_left'] %>"},
    {"type": "newcolumn"},
    {"type": "input", "value": "<%= date_to %>", "readonly":1, "disabled":1, "name": "prod_date_to", "label": "Date To", "inputWidth":"<%= ui_settings['field_size'] %>", "offsetLeft": "<%= ui_settings['offset_left'] %>"},
    {"type": "newcolumn"},
    {"type": "combo", "filtering":"true", "name": "lock_status", "label": "Lock Status", "inputWidth":"<%= ui_settings['field_size'] %>", "offsetLeft": "<%= ui_settings['offset_left'] %>",
        "options":[
            {"value": "y", "text": "Locked" <% (lock_status == 'y') ? print(',"selected":"true"') :  print(''); %>},
            {"value": "n", "text": "Unlocked" <% (lock_status == 'n') ? print(',"selected":"true"') :  print(''); %>}
        ]
    },
     {"type": "newcolumn"},
    {"type": "calendar", "dateFormat":"<%= date_format %>", "value": "<%= settlement_date %>", "serverdateFormat": "%Y-%m-%d", "name": "settlement_date", "label": "Invoice Date", "enableTime": false, "calendarPosition": "bottom", "disabled":1, "inputWidth":"<%= ui_settings['field_size'] %>", "offsetLeft": "<%= ui_settings['offset_left'] %>"},    
    {"type": "newcolumn"},
    {"type": "calendar", "dateFormat":"<%= date_format %>", "value": "<%= payment_date %>", "serverdateFormat": "%Y-%m-%d", "name": "payment_date", "label": "Payment Date", "enableTime": false, "calendarPosition": "bottom", "inputWidth":"<%= ui_settings['field_size'] %>", "offsetLeft": "<%= ui_settings['offset_left'] %>"},
    {"type": "newcolumn"},
    {"type": "newcolumn"},
    {"type": "calendar", "value": "<%= finalized_date %>", "readonly":1, "disabled":1, "name": "finalized_date", "label": "Finalized Date", "serverdateFormat": "%Y-%m-%d","dateFormat":"<%= date_format %>", "inputWidth":"<%= ui_settings['field_size'] %>", "offsetLeft": "<%= ui_settings['offset_left'] %>"},  
    {"type": "newcolumn"},
    {"type": "input", "name":"invoice_note", "label": "Invoice Notes", "value": "<%= invoice_note %>", "rows":5, "inputWidth":"<%= ui_settings['field_size'] %>", "offsetLeft": "<%= ui_settings['offset_left'] %>"},
    {"type": "input", "name": "counterparty_id", "label": "Counterparty ID", "readonly":1, "disabled":1, "value": "<%= counterparty_id %>", "hidden":1},
    {"type": "newcolumn"},
    {"type": "input", "name": "contract_id", "label": "Contract ID", "readonly":1, "disabled":1, "value": "<%= contract_id %>", "hidden":1}
    ]
</script>   
<!-- Invoice Summary Template -->

<script type="text/javascript">
    var category_id = "<?php echo $category_data[0]['value_id'];?>";
    var has_rights_view_invoice_delete = <?php echo (($has_rights_view_invoice_delete) ? $has_rights_view_invoice_delete : '0'); ?>;
    var has_rights_view_invoice_lock_unlock = <?php echo (($has_rights_view_invoice_lock_unlock) ? $has_rights_view_invoice_lock_unlock : '0'); ?>;
    
    var has_rights_view_invoice_invoice_status = <?php echo (($has_rights_view_invoice_invoice_status) ? $has_rights_view_invoice_invoice_status : '0'); ?>;
    var has_rights_view_invoice_void = <?php echo (($has_rights_view_invoice_void) ? $has_rights_view_invoice_void : '0'); ?>;
    var has_rights_view_invoice_unfinalize = <?php echo (($has_rights_view_invoice_unfinalize) ? $has_rights_view_invoice_unfinalize : '0'); ?>;
	var has_rights_view_invoice_finalize = <?php echo (($has_rights_view_invoice_finalize) ? $has_rights_view_invoice_finalize : '0'); ?>;
    var has_rights_view_invoice_save = <?php echo (($has_rights_view_invoice_save) ? $has_rights_view_invoice_save : '0'); ?>;
    var has_rights_view_invoice_document = <?php echo (($has_rights_view_invoice_document) ? $has_rights_view_invoice_document : '0'); ?>;
    var has_right_view_invoice_export = <?php echo (($has_right_view_invoice_export) ? $has_right_view_invoice_export : '0'); ?>;
    var has_rights_manual_adjustment_iu = <?php echo (($has_rights_manual_adjustment_iu) ? $has_rights_manual_adjustment_iu : '0'); ?>;
    var has_rights_manual_adjustment_delete = <?php echo (($has_rights_manual_adjustment_delete) ? $has_rights_manual_adjustment_delete : '0'); ?>;
    var has_rights_invoice_dispute_iu = <?php echo (($has_rights_invoice_dispute_iu) ? $has_rights_invoice_dispute_iu : '0'); ?>;
    var has_rights_invoice_dispute_delete = <?php echo (($has_rights_invoice_dispute_delete) ? $has_rights_invoice_dispute_delete : '0'); ?>;
    
    var has_rights_invoice_split = <?php echo (($has_rights_invoice_split) ? $has_rights_invoice_split : '0'); ?>;
    var has_rights_invoice_reprocess = <?php echo (($has_rights_invoice_reprocess) ? $has_rights_invoice_reprocess : '0'); ?>;
    var has_rights_counterparty_invoice = <?php echo (($has_rights_counterparty_invoice) ? $has_rights_counterparty_invoice : '0'); ?>;
    
        var void_disable = '';	
	var has_rights_gl_export = <?php echo (($has_rights_gl_export) ? $has_rights_gl_export : '0'); ?>;
    
	var pivot_exec_invoice = '';
    var undock_state = 0, undock_status;
    var expand_state = 0;
    var today = new Date();
    var dd = today.getDate();
    var mm = today.getMonth()+1; //January is 0!
    var yyyy = today.getFullYear();
    var php_script_loc = '<?php echo $php_script_loc; ?>'
    var client_date_format = '<?php echo $date_format; ?>';

	var runtime_user = getAppUserName();
    var runtime_user_array = runtime_user.split("=");
    runtime_user = runtime_user_array[1];
    //alert(runtime_user);
   
	var report_name = 'Invoice Report Template';
	var reporting_param = construct_report_export_cmd(report_name, report_name);
	var report_file_path = '<?php echo addslashes(addslashes($ssrs_config['EXPORTED_REPORT_DIR_INITIAL']))?>/' + 'Invoice Report Template.pdf';
	// var report_folder = '<?php echo $ssrs_config['REPORT_TARGET_FOLDER']; ?>' + '/custom_reports/';
	var report_folder = 'custom_reports/';
    var app_php_script_loc = '<?php echo $app_php_script_loc; ?>';

	
    if(dd<10) {
        dd='0'+dd
    } 
    
    if(mm<10) {
        mm='0'+mm
    }

    var today_date = yyyy + '-' + mm + '-' + dd;
    
    invoiceDetails = {};
    invoiceDetails.toolbar = {};
    invoiceDetails.tabbar = {};
    invoiceDetails.layout = {};
    invoiceDetails.form = {};
    invoiceDetails.grid = {};
    invoiceDetails.menu = {};
    var invoice_context_menu;
    var split_contract_window, original_invoice_tree, new_invoice_tree, gl_entries_window;
    var status_close_accounting_period = true;
    var close_accounting_period = '';

    /**
     * [To set the invoice number and load invoice grid when called from Run Contract Settlement]
     */
    $(function(){
        attach_browse_event('setHistory.filter_form');
        
        var counterparty_id = '<?php echo $counterparty_id; ?>';
        var contract_id = '<?php echo $contract_id; ?>';
        var date_from = '<?php echo $date_from; ?>';
        var date_to = '<?php echo $date_to; ?>';
        var counterparty = '<?php echo $counterparty; ?>';
        var contract = '<?php echo $contract; ?>';
        var counterparty_type = '<?php echo $counterparty_type; ?>';
        
        var delivery_date = new Date();
        var delivery_month_from = new Date(delivery_date.getFullYear(), delivery_date.getMonth() -1 , 1);
        var delivery_month_to = new Date(delivery_date.getFullYear(), delivery_date.getMonth(), 0);
        
        var invoice_id = '<?php echo $invoice_id; ?>';
        if (invoice_id != '') {
            setHistory.filter_form.setItemValue('invoice_number', invoice_id);
            setHistory.filter_form.setItemValue('counterparty_type', counterparty_type);
            
            var calc_id = '<?php echo $calc_id; ?>';
            if (calc_id != '') {
                var delivery_month_from = "<?php echo $prod_date ?? ''; ?>";
                var delivery_month_to = "<?php echo $prod_date_to ?? ''; ?>";
                
                setHistory.filter_form.setItemValue('prod_date_from', delivery_month_from);
                setHistory.filter_form.setItemValue('prod_date_to', delivery_month_to);
            }
            
            setHistory.refresh_invoice_grid();
        } else {
            if (setHistory.filter_form.getItemValue('prod_date_from') != '') 
                setHistory.filter_form.setItemValue('prod_date_from', delivery_month_from);
            if (setHistory.filter_form.getItemValue('prod_date_to') != '') 
                setHistory.filter_form.setItemValue('prod_date_to', delivery_month_to);
        }
        
        setHistory.set_history.attachEvent("onUnDock", function(name){
            $(".undock_a").hide();
            undock_state = 1;
        });
        
        setHistory.set_history.attachEvent("onDock", function(name){
            $(".undock_a").show();
            undock_state = 0;
        });
        
        setHistory.filter_form.attachEvent("onChange", function(name,value,is_checked){
            if (name == 'settlement_date_from' || name == 'prod_date_from' || name == 'payment_date_from') {
                var date_from = setHistory.filter_form.getItemValue(name, true);
                var split = date_from.split('-');
                var year =  +split[0];
                var month = +split[1];
                var day = +split[2];

                var date = new Date(year, month-1, day);
                var lastDay = new Date(date.getFullYear(), date.getMonth() + 1, 0);
                date_end = formatDate(lastDay);
                
                var to_name = name.replace("from", "to");
                setHistory.filter_form.setItemValue(to_name, date_end);
            } 
        });
        
        cmb_counterparty_obj = setHistory.filter_form.getCombo("counterparty_id");
        cmb_counterparty_obj.attachEvent("onCheck", load_contract_dropdown);
        cmb_counterparty_obj.setComboText('');
        cmb_contract_obj = setHistory.filter_form.getCombo("contract_id");
        cmb_contract_obj.setComboText('');
        //cmb_contract_obj.clearAll();
        
        //contract_settlement.contract_settlement_form.setItemValue('date_to', date_end);
        
        cmb_counterparty_type_obj = setHistory.filter_form.getCombo("counterparty_type");
        cmb_counterparty_type_obj.attachEvent("onChange", load_counterparty_dropdown);
        load_contract_dropdown();

        //adding filter
        var function_id  = 10221300;
        var report_type = 2;

        var filter_obj = setHistory.set_history.cells("a").attachForm();
        var layout_b_obj = setHistory.set_history.cells("b");
        load_form_filter(filter_obj, layout_b_obj, function_id, 2, setHistory);
        setHistory.set_history.cells("a").collapse();
    });
    
    function load_contract_dropdown() {
        var counterparty_ids = cmb_counterparty_obj.getChecked().join(',');
        var cm_param = {
            "action"            : 'spa_settlement_history',
            "call_from"         : "form",
            "has_blank_option"  : "false",
            "flag"              : 'i',
            "counterparty_id"   : counterparty_ids
        };

        cm_param = $.param(cm_param);
        var url = js_dropdown_connector_url + '&' + cm_param;
        var cmb_contract_obj = setHistory.filter_form.getCombo('contract_id');
        cmb_contract_obj.clearAll();
        cmb_contract_obj.setComboText('');
        cmb_contract_obj.load(url);
    }
    
    function load_counterparty_dropdown() {
        var counterparty_type = cmb_counterparty_type_obj.getSelectedValue();

        var cm_param = {
                "action"                : "spa_source_counterparty_maintain",
                "flag"                  : "c",
                "call_from"             : "form",
                "has_blank_option"      : "false",
                "int_ext_flag"          : counterparty_type
            };

        cm_param = $.param(cm_param);
        var url = js_dropdown_connector_url + '&' + cm_param;
        var cmb_contract_obj = setHistory.filter_form.getCombo('counterparty_id');
        cmb_contract_obj.clearAll();
        cmb_contract_obj.setComboText('');
        cmb_contract_obj.load(url);/*, function() {
            setHistory.filter_apply_change();
        });*/
    }

    //function to formatDate
    function formatDate(date) {
        var d = new Date(date),
            month = '' + (d.getMonth() + 1),
            day = '' + d.getDate(),
            year = d.getFullYear();

        if (month.length < 2) month = '0' + month;
        if (day.length < 2) day = '0' + day;

        return [year, month, day].join('-');
    }
    
    /**
     * [invoice_details_close Close tab and freeup the memories]
     * @param  {[type]} id [tab id]
     */
    setHistory.invoice_details_close = function(id) {
        delete setHistory.pages[id];
        delete invoiceDetails.toolbar[id];
        delete invoiceDetails.tabbar[id];
        delete invoiceDetails.layout["invoice_"+id];
        delete invoiceDetails.layout["history_"+id];
        delete invoiceDetails.layout["dispute_"+id];

        delete invoiceDetails.form[id];
        delete invoiceDetails.grid["invoice_"+id];
        delete invoiceDetails.menu["invoice_"+id];
        delete invoiceDetails.grid["history_a_"+id];
        delete invoiceDetails.grid["history_b_"+id];
        delete invoiceDetails.grid["dispute_"+id];
        delete invoiceDetails.menu["dispute_"+id];
        return true;
    };

    /**
     * [invoice_grid_select Invoice Grid Select event callback function - creates a context menu]
     * @param  {[type]} row_id [row id]
     * @param  {[type]} ind    [row index]
     */
    setHistory.invoice_grid_select = function(row_id,ind) {
        var calc_id = setHistory.invoice_grid.cells(row_id, setHistory.invoice_grid.getColIndexById('calc_id')).getValue();


        data = {"action": "spa_settlement_history",
            "flag": "y",
            "calc_id": calc_id
        };

       adiha_post_data('return_array', data, '', '', 'return_void_disable');
   
           
        var invoice_no = setHistory.invoice_grid.cells(row_id, setHistory.invoice_grid.getColIndexById('invoice_number')).getValue();
        
        if (calc_id != '' && calc_id >'0') {
            if(has_rights_view_invoice_delete)
                setHistory.invoice_menu.setItemEnabled("t");
                
            setHistory.invoice_menu.setItemEnabled("audit");
            setHistory.invoice_menu.setItemEnabled("t1");
			/*if (has_rights_gl_export){
            setHistory.invoice_menu.setItemEnabled("gl_entries");
			}*/
            
            invoice_context_menu = new dhtmlXMenuObject();
            invoice_context_menu.renderAsContextMenu();
            var menu_obj = [{id:"split_invoice", text:"Split", enabled:has_rights_invoice_split},
                            {id:"reprocess", text:"Rerun", enabled:has_rights_invoice_reprocess},
                            {id:"counterparty_invoice", text:"Counterparty Invoice", enabled:has_rights_counterparty_invoice} 
                            ];
            invoice_context_menu.loadStruct(menu_obj);
            setHistory.invoice_grid.enableContextMenu(invoice_context_menu);
            var invoice_remittance = setHistory.invoice_grid.cells(row_id, setHistory.invoice_grid.getColIndexById('invoice_type')).getValue();
            var lock_status = setHistory.invoice_grid.cells(row_id, setHistory.invoice_grid.getColIndexById('lock_status')).getValue();
            var finalize_status = setHistory.invoice_grid.cells(row_id, setHistory.invoice_grid.getColIndexById('calc_status')).getValue();

            if (invoice_remittance == 'Invoice' || invoice_remittance == 'Netting') {
                invoice_context_menu.setItemDisabled('counterparty_invoice');
            } else {
                if (has_rights_counterparty_invoice) {
                    invoice_context_menu.setItemEnabled('counterparty_invoice');
                }
            }

            if (lock_status == 'Locked' || finalize_status == 'Finalized') {
                invoice_context_menu.setItemDisabled('split_invoice');
                invoice_context_menu.setItemDisabled('counterparty_invoice');
            } else {
                if (has_rights_invoice_split) {
                    invoice_context_menu.setItemEnabled('split_invoice');
                   }
                 if (has_rights_counterparty_invoice && invoice_remittance == 'Remittance') {
                    invoice_context_menu.setItemEnabled('counterparty_invoice');
                }                                
            }
            
            if (has_rights_view_invoice_invoice_status) {
                setHistory.invoice_menu.setItemEnabled("invoice_status");
            } 
            //setHistory.invoice_menu.setItemEnabled("invoice_send");
            
            invoice_context_menu.attachEvent("onClick", function(menuitemId, zoneId) {
                switch(menuitemId){
                    case 'split_invoice':
                        var calc_id = setHistory.invoice_grid.cells(row_id, setHistory.invoice_grid.getColIndexById('calc_id')).getValue();
                        var invoice_no = setHistory.invoice_grid.cells(row_id, setHistory.invoice_grid.getColIndexById('invoice_number')).getValue();
                        call_split_invoice(calc_id, invoice_no);
                        break;
                    case 'reprocess':
						var as_of_date = setHistory.invoice_grid.cells(row_id, setHistory.invoice_grid.getColIndexById('as_of_date')).getValue();
						var accounting_status = setHistory.invoice_grid.cells(row_id, setHistory.invoice_grid.getColIndexById('calc_status')).getValue();
						var calc_id = setHistory.invoice_grid.cells(row_id, setHistory.invoice_grid.getColIndexById('calc_id')).getValue();
						var contract_id = setHistory.invoice_grid.cells(row_id, setHistory.invoice_grid.getColIndexById('contract_id')).getValue();
                        var invoice_no = setHistory.invoice_grid.cells(row_id, setHistory.invoice_grid.getColIndexById('invoice_number')).getValue();
						var lock_status = setHistory.invoice_grid.cells(row_id, setHistory.invoice_grid.getColIndexById('lock_status')).getValue();
                        var label_width = parseInt(ui_settings['field_size']) + parseInt(ui_settings['offset_left']);
						var rerun_form_data = [
                                    {type: "settings", labelWidth: label_width, inputWidth: ui_settings['field_size'], position: "label-top", offsetLeft: ui_settings['offset_left']},
                                    {type: "calendar", name: "as_of_date", label: "As of Date", "dateFormat": client_date_format, "value":as_of_date},
                                    {type: "checkbox", name: "calculate_deal_settlement", label: "Calculate Deal Settlement", position: "label-right"},
                                    {type: "button", value: "Ok", img: "tick.png"}
                                ];
								
						var rerun_popup = new dhtmlXPopup();
						var rerun_form = rerun_popup.attachForm(rerun_form_data);
						//var width = setHistory.invoice_grid.cells('a').getWidth();
						rerun_popup.show(100,100,45,45);
						rerun_form.attachEvent("onButtonClick", function(){
							var rerun_as_of_date = rerun_form.getItemValue('as_of_date', true);
                            var calculate_deal_settlement = rerun_form.isItemChecked('calculate_deal_settlement');
                            if (calculate_deal_settlement == true) { calculate_deal_settlement = 'y'; } else {calculate_deal_settlement = 'n';}
				            
							if (rerun_as_of_date == as_of_date && (accounting_status == 'Finalized' || accounting_status == 'Voided' || calc_id.trim() != invoice_no.trim() || lock_status == 'Locked')) {
                                show_messagebox('Please select different as of date.');
                                return;
                            }
                            
							data_for_post = { 'action': 'spa_close_measurement_books_dhx', 
									  'flag': 'v',
									  'as_of_date': dates.convert_to_sql(rerun_as_of_date),
                                      'contract_id': contract_id
									};
							var data = $.param(data_for_post);
							
							$.ajax({
								type: "POST",
								dataType: "json",
								url: js_form_process_url,
								async: true,
								data: data,
								success: function(data) {
									response_data = data["json"];
									if (response_data[0].validation == 'true') {
										rerun_contract_settlement(row_id,rerun_as_of_date,calculate_deal_settlement);
									} else {
										show_messagebox('Accounting Period ' + as_of_date + ' has already been closed.');
									}
								}
							});
							rerun_popup.hide();	
						});
						
						rerun_popup.attachEvent("onBeforeHide", function(type, ev, id){
							if (type == 'click' || type == 'esc') {
						rerun_popup.hide();
							return true;
							}
						});
		
                        break;
                    case 'counterparty_invoice':
                        insert_invoice(row_id);
                        break;
                }
            });
        } else {
            setHistory.invoice_menu.setItemDisabled("t");
            // setHistory.invoice_menu.setItemDisabled("t1");
            setHistory.invoice_grid.enableContextMenu();
        }
    }
	
     function return_void_disable(result){
       void_disable = result;
    }
	
	function rerun_contract_settlement(row_id,rerun_as_of_date,calculate_deal_settlement) {        
		var date_from = setHistory.invoice_grid.cells(row_id, setHistory.invoice_grid.getColIndexById('date_from')).getValue();
		var as_of_date = rerun_as_of_date;
		var counterparty_id = setHistory.invoice_grid.cells(row_id, setHistory.invoice_grid.getColIndexById('counterparty_id')).getValue();
		var contract_id = setHistory.invoice_grid.cells(row_id, setHistory.invoice_grid.getColIndexById('contract_id')).getValue();
		var charge_type_id = 'NULL';
		var date_to = setHistory.invoice_grid.cells(row_id, setHistory.invoice_grid.getColIndexById('date_to')).getValue()
		//var calculate_deal_settlement = 'n';
		var date_type = 't';
		var calc_id = setHistory.invoice_grid.cells(row_id, setHistory.invoice_grid.getColIndexById('calc_id')).getValue();

		var exec_call = "EXEC spa_process_settlement_invoice " 
			+ "NULL"
			+ "," + singleQuote(dates.convert_to_sql(date_from))
			+ "," + singleQuote(dates.convert_to_sql(as_of_date))
			+ "," + singleQuote(counterparty_id)
			+ ",n"
			+ "," + singleQuote(contract_id)
			+ ",NULL"
			+ ",'n'"
			+ ",'stlmnt'"
			+ "," + singleQuote(charge_type_id)
			+ ",NULL"
			+ ",NULL"
			+ "," + singleQuote(dates.convert_to_sql(date_to))
			+ "," + singleQuote(calculate_deal_settlement)
			+ ",'e'"
			+ ",NULL"
			+ "," + singleQuote(date_type)
			+ ",NULL, 'n'";

		var param = 'call_from=Run_Settlement_Process_Job&gen_as_of_date=1&batch_type=c&as_of_date=' + dates.convert_to_sql(as_of_date); 
        adiha_run_batch_process(exec_call, param, 'Run Settlement Process');
     }
	

    /**
     * [unload_window Unload splitting invoice window.]
     */
    function unload_window() {        
        if (split_contract_window != null && split_contract_window.unload != null) {
            split_contract_window.unload();
            split_contract_window = w1 = null;
        }
    }

    var manual_line_item_window;
    /**
     * [unload_manual_item_window Unload manual line item window.]
     */
    function unload_manual_item_window() {        
        if (manual_line_item_window != null && manual_line_item_window.unload != null) {
            manual_line_item_window.unload();
            manual_line_item_window = w1 = null;
        }
    }
    
    var audit_report_window;
    /**
     * [unload_manual_item_window Unload manual line item window.]
     */
    function unload_audit_report_window() {        
        if (audit_report_window != null && audit_report_window.unload != null) {
            audit_report_window.unload();
            audit_report_window = w1 = null;
        }
    }
    
    var invoice_dispute_window;
    /**
     * [unload_invoice_dispute_window Unload manual line item window.]
     */
    function unload_invoice_dispute_window() {        
        if (invoice_dispute_window != null && invoice_dispute_window.unload != null) {
            invoice_dispute_window.unload();
            invoice_dispute_window = w1 = null;
        }
    }
    
    var invoice_status_window;
    /**
     * [unload_invoice_status_window Unload manual line item window.]
     */
    function unload_invoice_status_window() {        
        if (invoice_status_window != null && invoice_status_window.unload != null) {
            invoice_status_window.unload();
            invoice_status_window = w1 = null;
        }
    }
    
    var gl_entries_window;
    /**
     * [unload_window Unload splitting invoice window.]
     */
    function unload_gl_entries_window() {        
        if (gl_entries_window != null && gl_entries_window.unload != null) {
            gl_entries_window.unload();
            gl_entries_window = w1 = null;
        }
    }
    
    /**
     * [call_split_invoice Function for first context menu. Split Invoice. Opens up window for splitting invoice.]
     * @param  {[int]} calc_id        [calc_id]
     * @param  {[int]} invoice_number [invoice_number]
     */
    function call_split_invoice(calc_id, invoice_number) {
        unload_window();
        if (!split_contract_window) {
            split_contract_window = new dhtmlXWindows();
        }

        var new_win = split_contract_window.createWindow('w1', 0, 0, 800, 600);
        new_win.setText("Split Invoice: Invoice no - " + invoice_number);
        new_win.centerOnScreen();
        new_win.setModal(true);
        new_win.attachURL('split.invoice.php?calc_id=' + calc_id, false, true);
        
        new_win.attachEvent("onClose", function(win){
            setHistory.refresh_invoice_grid();
            return true;
        });
    }
    
    function call_audit_report(calc_id) {
        unload_audit_report_window();
        if (!audit_report_window) {
            audit_report_window = new dhtmlXWindows();
        }

        var new_win = audit_report_window.createWindow('w1', 0, 0, 800, 600);
        new_win.setText("Audit Log");
        new_win.centerOnScreen();
        new_win.setModal(true);
        
        var js_php_path = '<?php echo $php_script_loc; ?>';
        var url = js_php_path + "dev/spa_html.php?exec=EXEC spa_calc_Invoice_volume_variance_audit 's','" + calc_id + "'";
           
        new_win.attachURL(url, false, true);
    }
    
    function call_settlement_report(flag, counterparty_id, contract_id, prod_date, as_of_date, line_item_id, invoice_type, settlement_date) {
        unload_audit_report_window();
        if (!audit_report_window) {
            audit_report_window = new dhtmlXWindows();
        }
        /*
        var new_win = audit_report_window.createWindow('w1', 0, 0, 800, 600);
        new_win.setText("View Detail");
        new_win.centerOnScreen();
        new_win.setModal(true);
        */
        var js_php_path = '<?php echo $php_script_loc; ?>';
        
        var report_name = 'Contract Settlement Report'; 

        var exec_call = "EXEC spa_gen_invoice_variance_report " + counterparty_id + ",'" 
                + prod_date + "',"
                + contract_id + ", NULL,'"
                + flag + "','"
                + as_of_date + "', NULL, NULL, NULL, NULL,"
                + line_item_id + ", NULL, NULL, NULL, NULL,'" + invoice_type + "','" + settlement_date + "', NULL, NULL,2,NULL" ;
        open_spa_html_window(report_name, exec_call, 500, 1150, 1);         

    }

    /**
     * [create_invoice_detail_tab Creates tab for invoice details on double click event for invoice grid]
     * @param  {[type]} r_id   [row_id]
     * @param  {[type]} col_id [col_id]
     */
    setHistory.create_invoice_detail_tab = function(r_id, col_id) {
		var tree_level = setHistory.invoice_grid.getLevel(r_id);
		var invoice_no = setHistory.invoice_grid.cells(r_id, setHistory.invoice_grid.getColIndexById('invoice_number')).getValue();
        var calc_id = setHistory.invoice_grid.cells(r_id, setHistory.invoice_grid.getColIndexById('calc_id')).getValue();
        var invoice_type = setHistory.invoice_grid.cells(r_id, setHistory.invoice_grid.getColIndexById('invoice_type')).getValue();
        if (calc_id != '' && invoice_type != 'Netting') {
			if (tree_level == 2) {
				setHistory.add_detail_tab(invoice_no, calc_id, r_id);
			}
        } else {
            var selected_row = setHistory.invoice_grid.getSelectedRowId();
            var state = setHistory.invoice_grid.getOpenState(selected_row);
            
            if (state)
                setHistory.invoice_grid.closeItem(selected_row);
            else
                setHistory.invoice_grid.openItem(selected_row);
        }
    }

    /**
     * [add_detail_tab Add invoice detail tab]
     * @param {[type]} invoice_no [invoice number]
     * @param {[type]} calc_id    [calc id]
     * @param {[type]} r_id       [row id]
     */
    setHistory.add_detail_tab = function(invoice_no, calc_id, r_id) {
        
        if (!setHistory.pages[calc_id]) {
            setHistory.set_history.cells('d').progressOn();
            // add tab
            setHistory.invoice_details.addTab(calc_id, invoice_no);
            setHistory.invoice_details.cells(calc_id).setActive();

            // treat tab cell as window
            win = setHistory.invoice_details.cells(calc_id);
            setHistory.pages[calc_id] = win;

            invoiceDetails.toolbar[calc_id] = setHistory.invoice_details.cells(calc_id).attachMenu({
                icons_path: js_image_path + "dhxmenu_web/",
                items:[
                        {id:"save", img: "save.gif", imgdis: "save_dis.gif", text:"Save", title: "Save", enabled: has_rights_view_invoice_save}
                        ,{ id: "documents", img: "doc.gif", imgdis: "doc_dis.gif", text:"Documents", title: "Documents", enabled: has_rights_view_invoice_document}
                    ]
            });
            
            var object_id = calc_id;
            apply_sticker(object_id);
            toolbar_obj = invoiceDetails.toolbar[calc_id];//setHistory.invoice_details.cells(calc_id).getAttachedToolbar();
            update_document_counter(object_id, toolbar_obj);

            invoiceDetails.toolbar[calc_id].attachEvent("onClick", function(id) {
                switch(id) {
                    case "save":
                        invoice_status = invoiceDetails.form[calc_id].getItemValue("invoice_status");
                        lock_status = invoiceDetails.form[calc_id].getItemValue("lock_status");
                        invoice_note = invoiceDetails.form[calc_id].getItemValue("invoice_note");
                        payment_date = dates.convert_to_sql(invoiceDetails.form[calc_id].getItemValue("payment_date", true)); 

                        if (payment_date) {
                           payment_date = dates.convert_to_sql(invoiceDetails.form[calc_id].getItemValue("payment_date", true)); 
                        }

                        settlement_date = invoiceDetails.form[calc_id].getItemValue("settlement_date", true)
                        if (settlement_date) {
                           settlement_date = dates.convert_to_sql(invoiceDetails.form[calc_id].getItemValue("settlement_date", true)); 
                        }
                        
                        var xml = '<Root><PSRecordSet calc_id="' + calc_id + '" invoice_status="' + invoice_status + '" lock_status="' + lock_status + '" invoice_note="' + invoice_note + '" payment_date="' + payment_date + '" settlement_date="' + settlement_date + '"></PSRecordSet></Root>';
                               
                        data = {"action": "spa_settlement_history",
                            "flag": "m",
                            "xml": xml
                        };

                        adiha_post_data('alert', data, '', '', 'setHistory.refresh_invoice_grid', '', '');
                        
                        break;
                    case "documents":
                        setHistory.open_document(calc_id);
                        break;
                    default:
                        break;
                }
            });
            // attach child tabbar
            invoiceDetails.tabbar[calc_id] = setHistory.invoice_details.tabs(calc_id).attachTabbar({
                mode:"bottom",
                arrows_mode:"auto",
                tabs: [
                    {id: "invoice_"+calc_id, text: get_locale_value("Invoice"), active: true },
                    {id: "history_"+calc_id, text: get_locale_value("History") },
                    {id: "dispute_"+calc_id, text: get_locale_value("Dispute") },
                    {id: "trueup_"+calc_id, text: get_locale_value("Trueup")}
                    //,{id: "payment_"+calc_id, text: "Payment" }
                ]
            });

            // attach layout for invoice tab

            invoiceDetails.layout["invoice_"+calc_id] = invoiceDetails.tabbar[calc_id].cells("invoice_"+calc_id).attachLayout({
                pattern:'2E',
                cells:[
                    {id: "a", text: "Summary",height:200},
                    {id: "b", text: "Details", undock: true}					
                ]
            });
            
            invoiceDetails.layout["invoice_"+calc_id].attachEvent("onUnDock", function(name){
                $(".undock_b").hide();
            });

            invoiceDetails.layout["invoice_"+calc_id].attachEvent("onDock", function(name){
                $(".undock_b").show();
            });

            var form_json = null;
            form_json = setHistory.get_form_data(r_id);

            // attach form for invoice tab
            invoiceDetails.form[calc_id] = invoiceDetails.layout["invoice_"+calc_id].cells("a").attachForm();
            invoiceDetails.form[calc_id].loadStruct(get_form_json_locale(form_json));
            
			var invoice_status = setHistory.invoice_grid.cells(r_id, setHistory.invoice_grid.getColIndexById('invoice_status_id')).getValue();
			invoiceDetails.form[calc_id].setItemValue('invoice_status', invoice_status);
			
            // attach menu for detail cell in invoice tab
            invoiceDetails.menu["invoice_" + calc_id] = invoiceDetails.layout["invoice_"+calc_id].cells("b").attachMenu({
                icons_path: js_image_path + "dhxmenu_web/",
                items:[
                        {id: "edit", text: "Process", img: "action.gif", imgdis: "action_dis.gif", disabled: true, items: [
                                {id: "finalize", text: "Finalize", img: "finalize.gif", imgdis: "finalize_dis.gif", enabled: has_rights_view_invoice_finalize},
                                {id: "unfinalize", text: "Unfinalize", img: "unfinalize.gif", imgdis: "unfinalize_dis.gif", enabled: has_rights_view_invoice_unfinalize},
                                {id: "void", text: "Void", img: "void.gif", imgdis: "void_dis.gif", enabled: has_rights_view_invoice_void }
                            ]},
                        {id: "manual", text: "Manual Adjustment", img:"manual_adj.gif", imgdis:"manual_adj_dis.gif", items: [
                                {id: "add_manual", text: "Add", img: "add.gif",imgdis: "add_dis.gif", enabled: has_rights_manual_adjustment_iu},
                                {id: "delete_manual", text: "Delete", img: "delete.gif", imgdis: "delete_dis.gif", disabled: true}
                            ]},
                        {id:"export", text:"Export", img:"export.gif", items:[
                                {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                                {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                            ]},
                         {id:"pivot", text:"Pivot", img:"pivot.gif", imgdis:"pivot_dis.gif",enabled:"true"}
                        //,
                        //{id:"documents", text:"Documents", img:"doc.gif", imgdis:"doc_dis.gif", title: "Documents"}
                    ]
                });

                has_rights_invoice_document = 1;
                toolbar_obj = invoiceDetails.menu["invoice_" + calc_id];
                apply_sticker(object_id);
                update_document_counter(object_id, toolbar_obj)

                var finalized_status = invoiceDetails.form[calc_id].getItemValue('calc_status');
                
                if (finalized_status == 'Finalized') {
                    invoiceDetails.form[calc_id].disableItem("invoice_status");
                    invoiceDetails.form[calc_id].disableItem("lock_status");
                    invoiceDetails.form[calc_id].disableItem("invoice_note");
                    invoiceDetails.form[calc_id].disableItem("payment_date");
                    //invoiceDetails.form[calc_id].disableItem("settlement_date");
                    invoiceDetails.menu["invoice_" + calc_id].setItemDisabled("manual");
                }
            
                var lock_status = invoiceDetails.form[calc_id].getItemValue('lock_status');
                if (lock_status == 'y') {
                    invoiceDetails.form[calc_id].disableItem("invoice_status");
                    //invoiceDetails.form[calc_id].disableItem("lock_status");
                    invoiceDetails.form[calc_id].disableItem("invoice_note");
                    invoiceDetails.form[calc_id].disableItem("payment_date");
                    //invoiceDetails.form[calc_id].disableItem("settlement_date");
                    invoiceDetails.menu["invoice_" + calc_id].setItemDisabled("manual");
                }
                
                // attach grid for detail cell in invoice tab
                invoiceDetails.grid["invoice_" + calc_id] = invoiceDetails.layout["invoice_" + calc_id].cells("b").attachGrid();
                invoiceDetails.grid["invoice_" + calc_id].setImagePath(js_image_path + "dhxgrid_web/");
                invoiceDetails.grid["invoice_" + calc_id].setHeader(get_locale_value("Calc Detail ID, Manual Input, Charge Type ID, Charge Type, Amount, Currency,Volume, UOM, Delivery Month,  Accounting Status, Finalized Date",true),null,["text-align:left;","text-align:left;","text-align:left;","text-align:left;","text-align:right;","text-align:right;","text-align:right;","text-align:right;","text-align:left;","text-align:left;","text-align:left;"]);
                invoiceDetails.grid["invoice_" + calc_id].setInitWidths("80,80,80,200,80,90,80,80,150,150,150");
                invoiceDetails.grid["invoice_" + calc_id].setColTypes("ro,ro,ro,ro,ro_a,ro,ro_v,ro,ro,ro,ro");
                invoiceDetails.grid["invoice_" + calc_id].setColAlign(",,,,right,right,right,right,,,");
                invoiceDetails.grid["invoice_" + calc_id].setColSorting("int,str,int,str,int,str,float,str,date,str,date");
                invoiceDetails.grid["invoice_" + calc_id].setColumnsVisibility("true,true,true,false,false,false,false,false,false,false,false");
                invoiceDetails.grid["invoice_" + calc_id].enableMultiselect(true);
                invoiceDetails.grid["invoice_" + calc_id].enableColumnMove(true);
                invoiceDetails.grid["invoice_" + calc_id].init();
                invoiceDetails.grid["invoice_" + calc_id].loadOrderFromCookie("invoice");
                invoiceDetails.grid["invoice_" + calc_id].loadHiddenColumnsFromCookie("invoice");
                invoiceDetails.grid["invoice_" + calc_id].enableOrderSaving("invoice");
                invoiceDetails.grid["invoice_" + calc_id].enableAutoHiddenColumnsSaving("invoice");
                invoiceDetails.grid["invoice_" + calc_id].enableHeaderMenu();
                invoiceDetails.grid["invoice_" + calc_id].attachEvent("onRowDblClicked", function(row_id){
                    unload_manual_item_window();
                    if (!manual_line_item_window) {
                        manual_line_item_window = new dhtmlXWindows();
                    }
                    
                    if (row_id != null) {
                        var manual_input = invoiceDetails.grid["invoice_" + calc_id].cells(row_id, 1).getValue();
                        var lock_status = invoiceDetails.form[calc_id].getItemValue("lock_status");
                        if (lock_status == 'y') { return; }
						var finalized_status = invoiceDetails.form[calc_id].getItemValue("calc_status");
                        if (finalized_status == 'Finalized') { return; }

                        if (manual_input == 'y') {
							var prod_date = invoiceDetails.form[calc_id].getItemValue("prod_date_from", true);
							prod_date = dates.convert_to_sql(prod_date);
							var calc_detail_id = invoiceDetails.grid["invoice_" + calc_id].cells(row_id, 0).getValue();
                            var win = manual_line_item_window.createWindow('w1', 0, 0, 830, 380);
                            win.setText("Update Manual Line Item: Invoice no - " + invoice_no);
                            win.centerOnScreen();
                            win.setModal(true);
                            win.attachURL('manual.line.items.php?mode=y&prod_date=' + prod_date + '&calc_detail_id=' + calc_detail_id + '&right_id=' + has_rights_manual_adjustment_iu,  false, true);
							win.attachEvent("onClose", function(win){
								setHistory.refresh_invoice_detail_grid(calc_id);
								return true;
							});
                        }    
                    }
                });
                
                invoiceDetails.grid["invoice_" + calc_id].attachEvent("onRowSelect", function(row_id){
                        invoiceDetails.menu["invoice_"+calc_id].setItemEnabled("edit");
					
                                
					if (void_disable == 'v'){						
						invoiceDetails.menu["invoice_"+calc_id].setItemDisabled("void");
					}

                    var manual_input = invoiceDetails.grid["invoice_" + calc_id].cells(row_id, 1).getValue();
                    
                    if (manual_input == 'y' && (has_rights_manual_adjustment_delete)) {
                        invoiceDetails.menu["invoice_"+calc_id].setItemEnabled("delete_manual");
                    } else {
                        invoiceDetails.menu["invoice_"+calc_id].setItemDisabled("delete_manual");
                    }
                    
                    invoice_detail_context_menu = new dhtmlXMenuObject();
                    invoice_detail_context_menu.renderAsContextMenu();
                    var invoice_menu_obj = [{id:"view_detail", text:"View Detail"}];
                    invoice_detail_context_menu.loadStruct(get_form_json_locale(invoice_menu_obj));
                    invoiceDetails.grid["invoice_" + calc_id].enableContextMenu(invoice_detail_context_menu);
                    
                    invoice_detail_context_menu.attachEvent("onClick", function(menuitemId, zoneId) {
                        switch(menuitemId){
                            case 'view_detail':
                                var counterparty_id = invoiceDetails.form[calc_id].getItemValue("counterparty_id");
                                var contract_id = invoiceDetails.form[calc_id].getItemValue("contract_id");
                                var prod_date = dates.convert_to_sql(invoiceDetails.form[calc_id].getItemValue("prod_date_from", true));
                                var as_of_date = dates.convert_to_sql(invoiceDetails.form[calc_id].getItemValue("as_of_date", true));
                                var line_item_id = invoiceDetails.grid["invoice_" + calc_id].cells(row_id, 2).getValue();
                                var invoice_type = invoiceDetails.form[calc_id].getItemValue("invoice_type");
                                var settlement_date = dates.convert_to_sql(invoiceDetails.form[calc_id].getItemValue("settlement_date", true));
                                if (invoice_type == 'Invoice') {
                                    invoice_type = 'i';
                                } else if (invoice_type == 'Remittance') {
                                    invoice_type = 'r';
                                }

                                var data = {
                                    "action"                : "spa_data_component",
                                    "flag"                  : "k",
                                    "contract_id"           : contract_id,
                                    "invoice_line_item_id"  : line_item_id,
                                    "calc_id"               : calc_id
                                };
                                var additional_data = {
                                    "type": 'return_array'
                                };
                                
                                data = $.param(data) + "&" + $.param(additional_data);
                                $.ajax({
                                    type: "POST",
                                    dataType: "json",
                                    url: js_form_process_url,
                                    async: true,
                                    data: data,
                                    success: function(data) {
                                        var is_excel =  data.json[0][0];
                                        var file_name = data.json[0][1];
                                        if (is_excel == '1' && file_name != 'error') {
                                            window.location = app_php_script_loc + 'force_download.php?path=dev/shared_docs/excel_calculations/'+ file_name;
                                        } else if (is_excel == '1' && file_name == 'error') {
                                            dhtmlx.alert({
                                                title:"Alert",
                                                type:"alert",
                                                text:"File does not exist."
                                            });
                                        } else {
                                            call_settlement_report('h', counterparty_id, contract_id, prod_date, as_of_date, line_item_id, invoice_type, settlement_date);
                                        }

                                    }
                                });
                                break;
                            default:
                                break;                            
                        }
                    });
                                    
                });                                

                var manual_line_popup;
                var date_format = "<?php echo $date_format; ?>";
                var manual_form_data = [
                    {type: "select", label: "Status", name: "status", options: [
                            {text: "Finalize", value: "y"},
                            {text: "Estimate", value: "n"}
                        ]},
                    {type: "calendar", dateFormat: date_format, name: "finalize_date", label: "Finalize Date", className: "my_calendar", readonly: true},
                    {type: "block", list: [
                            {type: "button", value: "Save", name: "save", className: "button_save"},
                            {type: "newcolumn"},
                            {type: "button", value: "Cancel", name: "cancel", className: "button_cancel", offsetLeft: 7}
                        ]}
                ];

                // open popup window for on click evet of invoice detail add menu
                invoiceDetails.menu["invoice_" + calc_id].attachEvent("onClick", function(id) {
                    var as_of_date = invoiceDetails.form[calc_id].getItemValue("as_of_date", true);
                    var prod_date = invoiceDetails.form[calc_id].getItemValue("prod_date_from", true);
					//prod_date = dates.convert_to_sql(prod_date);
					var selected_row = invoiceDetails.grid["invoice_" + calc_id].getSelectedRowId();

                    switch (id) {
                        case "add_manual":
                            unload_manual_item_window();
                            if (!manual_line_item_window) {
                                manual_line_item_window = new dhtmlXWindows();
                            }

                            var win = manual_line_item_window.createWindow('w1', 0, 0, 790, 345);
                            win.setText("Add Manual Line Item: Invoice no - " + invoice_no);
                            win.centerOnScreen();
                            win.setModal(true);
                            win.attachURL('manual.line.items.php?calc_id=' + calc_id + '&as_of_date=' + as_of_date + '&prod_date=' + prod_date + '&mode=x'+ '&right_id=' + has_rights_manual_adjustment_iu, false, true);
							win.attachEvent("onClose", function(win){
								setHistory.refresh_invoice_detail_grid(calc_id);
								return true;
							});
                            break;
                        case "delete_manual":
                            if (selected_row != null) {
                                var selected_row_array = new Array();
                                selected_row_array = selected_row.split(',');
                                var manual_input = 'y';
                                
                                for (count = 0; count < selected_row_array.length; count++) {
                                    if (invoiceDetails.grid["invoice_" + calc_id].cells(selected_row_array[count], 1).getValue() != 'y') {
                                         manual_input = 'n';   
                                    }      
                                }
                                
                                if (manual_input == 'y') {
                                    var xml = '<Root>' 
                                    
                                    for (count = 0; count < selected_row_array.length; count++) {
                                        var calc_detail_id = invoiceDetails.grid["invoice_" + calc_id].cells(selected_row_array[count], 0).getValue();
                                        xml += '<PSRecordSet calc_detail_id="' + calc_detail_id + '"></PSRecordSet>'
                                    }
                                    xml += '</Root>';
                                
                                    data = {"action": "spa_settlement_history",
                                        "flag": "z",
                                        "xml": xml
                                    };
            
                                    adiha_post_data('confirm', data, '', '', 'setHistory.refresh_invoice_detail_grid('+calc_id+')', '', 'Are you sure you want to delete selected charge type(s)?');
                                }
                            }
                            break;
                        case "finalize":
                            if (selected_row != null) {
                                var selected_row_array = selected_row.split(',');
                                var xml = "<Root>";
                                
                                for(var i = 0; i < selected_row_array.length; i++) {
                                    var invoice_line_item_id = invoiceDetails.grid["invoice_" + calc_id].cells(selected_row_array[i], 2).getValue();
                                    var finalized_date = today_date;
                                    
                                    if (calc_id != '') {
                                        xml += '<PSRecordSet calc_id = "' + calc_id + '" invoice_line_item_id = "' + invoice_line_item_id + '" finalized_date = "' + finalized_date + '"></PSRecordSet>'
                                    }
                                }
                                xml += "</Root>";
                                
                                if (xml != '<Root></Root>') {
                                    data = {"action": "spa_settlement_history",
                                            "flag": "j",
                                            "xml": xml
                                         };
                
                                    adiha_post_data('confirm', data, '', '', 'setHistory.refresh_invoice_grid', 'false', 'Are you sure you want to finalize selected charge type(s)?');
                                }
                            }
                            break;
                        case "unfinalize":
                            if (selected_row != null) {
                                var selected_row_array = selected_row.split(',');
                                var xml = "<Root>";
                                
                                for(var i = 0; i < selected_row_array.length; i++) {
                                    var invoice_line_item_id = invoiceDetails.grid["invoice_" + calc_id].cells(selected_row_array[i], 2).getValue();
                                    
                                    if (calc_id != '') {
                                        xml += '<PSRecordSet calc_id = "' + calc_id + '" invoice_line_item_id = "' + invoice_line_item_id + '"></PSRecordSet>'
                                    }
                                }
                                xml += "</Root>";
                                
                                if (xml != '<Root></Root>') {
                                    data = {"action": "spa_settlement_history",
                                            "flag": "k",
                                            "xml": xml
                                         };
                
                                    adiha_post_data('confirm', data, '', '', 'setHistory.refresh_invoice_grid', 'false','Are you sure you want to unfinalize selected charge type(s)?');
                                }
                            }
                            break;
                        case "void":
                            if (selected_row != null) {
                                var selected_row_array = selected_row.split(',');
                                var calc_status = 0;
                                
                                for(var i = 0; i < selected_row_array.length; i++) {
                                    var c_status = invoiceDetails.grid["invoice_" + calc_id].cells(selected_row_array[i], 9).getValue();
                                    
                                    if (c_status != 'Finalized') {
                                        calc_status = 1;
                                    }
                                }
                                
                                if (calc_status == 0) {
                                    invoiceDetails.layout["invoice_"+calc_id].acc_pop = new dhtmlXPopup();
									invoiceDetails.layout["invoice_"+calc_id].acc_form = invoiceDetails.layout["invoice_"+calc_id].acc_pop.attachForm(
										[
											{type: "calendar", label: "As of Date", name: "as_of_date", "dateFormat": client_date_format, position: "label-top", serverDateFormat:"%Y-%m-%d"},
											{type: "button", value: "Ok"}
										]);
									invoiceDetails.layout["invoice_"+calc_id].acc_pop.show(625,300,50,50);
									var current_date = new Date();
									invoiceDetails.layout["invoice_"+calc_id].acc_form.setItemValue('as_of_date', current_date);
									invoiceDetails.layout["invoice_"+calc_id].acc_form.attachEvent("onButtonClick", function(name){
										invoiceDetails.layout["invoice_"+calc_id].acc_pop.hide();
										var xml = "<Root>";
										
										for(var i = 0; i < selected_row_array.length; i++) {
											var invoice_line_item_id = invoiceDetails.grid["invoice_" + calc_id].cells(selected_row_array[i], 2).getValue();
											//var as_of_date = dates.convert_to_sql(invoiceDetails.layout["invoice_"+calc_id].acc_form.getItemValue("as_of_date", true));
											var as_of_date = invoiceDetails.layout["invoice_"+calc_id].acc_form.getItemValue("as_of_date", true);
											
											if (calc_id != '') {
												xml += '<PSRecordSet calc_id = "' + calc_id + '" invoice_line_item_id = "' + invoice_line_item_id + '" as_of_date = "' + as_of_date + '"></PSRecordSet>'
											}
										}
										xml += "</Root>";
										//alert(xml);return;
										if (xml != '<Root></Root>') {
											//var invoie_reporting_param = reporting_param.replace('temp_Note','invoice_docs');
                                            var report_file_path_new = report_file_path.replace('temp_Note','invoice_docs');

											data = {"action": "spa_settlement_history",
													"flag": "v",
													"xml": xml,
													"reporting_param": '',
													"report_file_path": report_file_path_new,
													"report_folder": report_folder
												 };
						
											adiha_post_data('confirm', data, '', '', 'setHistory.refresh_invoice_grid', '', 'Are you sure you want to void selected charge type(s)?');
										}
									});
								} else {
									show_messagebox("Please finalize the invoice first before voiding.");
								}
                            }                            
                            break;
                        case "excel":
                            invoiceDetails.grid["invoice_" + calc_id].toExcel(php_script_loc + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                            break;
                        case "pdf":
                            invoiceDetails.grid["invoice_" + calc_id].toPDF(php_script_loc +'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                            break;
                        case 'pivot':
                            pivot_exec_spa = "EXEC spa_settlement_history @flag='w', @calc_id='" +  calc_id + "'";

                            var grid_obj =invoiceDetails.grid["invoice_" + calc_id];
                            open_grid_pivot(grid_obj, 'invoice_grid', 1, pivot_exec_spa, 'Invoice');
                            break;
                        default:
                            dhtmlx.alert({
                                title:'Error',
                                type:"alert-error",
                                text:"Under Maintainence! We will be back soon!"
                            });
                            break;
                    }
                });

                setHistory.refresh_invoice_detail_grid(calc_id);

                // attach layout to history tab
                invoiceDetails.layout["history_" + calc_id] = invoiceDetails.tabbar[calc_id].cells("history_" + calc_id).attachLayout({
                    pattern: '2E',
                    cells: [
                        {id: "a", text: "Invoice Header"},
                        {id: "b", text: "Invoice Details"}
                    ]
                });

                // attach grid to first cell history tab
                invoiceDetails.grid["history_a_" + calc_id] = invoiceDetails.layout["history_" + calc_id].cells("a").attachGrid();
                invoiceDetails.grid["history_a_" + calc_id].setImagePath(js_image_path + "dhxgrid_web/");
                invoiceDetails.grid["history_a_" + calc_id].setHeader(get_locale_value("Calc ID,Invoice No, Invoice Type, As of Date,Date From, Date To, Invoice Date, Payment Date, Accounting Status, Finalized Date, Workflow Status, Lock Status, Invoice File Name",true));
                invoiceDetails.grid["history_a_" + calc_id].setInitWidths("100,100,110,100,100,100,150,120,150,120,120,150,150");
                invoiceDetails.grid["history_a_" + calc_id].setColTypes("ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro");
                invoiceDetails.grid["history_a_" + calc_id].setColSorting("int,int,str,date,date,date,date,date,str,date,str,str,str");
                invoiceDetails.grid["history_a_" + calc_id].setColumnsVisibility("true,false,false,false,false,false,false,false,false,false,false,false,true");
                invoiceDetails.grid["history_a_" + calc_id].enableColumnMove(true);
                invoiceDetails.grid["history_a_" + calc_id].init();
                invoiceDetails.grid["history_a_" + calc_id].loadOrderFromCookie("history_a");
                invoiceDetails.grid["history_a_" + calc_id].loadHiddenColumnsFromCookie("history_a");
                invoiceDetails.grid["history_a_" + calc_id].enableOrderSaving("history_a");
                invoiceDetails.grid["history_a_" + calc_id].enableAutoHiddenColumnsSaving("history_a");
                invoiceDetails.grid["history_a_" + calc_id].enableHeaderMenu();

                // load data to first grid in history tab
                var history_a_param = {
                    "flag": "h",
                    "calc_id": calc_id,
                    "action": "spa_settlement_history"
                };

                pivot_exec_spa_1 = "EXEC spa_settlement_history @flag='h', @calc_id='" +  calc_id + "'";

                history_a_param = $.param(history_a_param);
                var history_a_url = js_data_collector_url + "&" + history_a_param;

                invoiceDetails.grid["history_a_" + calc_id].loadXML(history_a_url);

                // attach grid to second cell history tab
                invoiceDetails.grid["history_b_" + calc_id] = invoiceDetails.layout["history_" + calc_id].cells("b").attachGrid();
                invoiceDetails.grid["history_b_" + calc_id].setImagePath(js_image_path + "dhxgrid_web/");
                invoiceDetails.grid["history_b_" + calc_id].setHeader(get_locale_value("Calc Detail ID, Manual Input, Charge Type ID, Charge Type, Amount, Currency,Volume, UOM, Delivery Month, Accounting Status, Finalized Date",true),null,["text-align:left;","text-align:left;","text-align:left;","text-align:left;","text-align:right;","text-align:right;","text-align:right;","text-align:right;","text-align:left;","text-align:left;","text-align:left;"]);
                invoiceDetails.grid["history_b_" + calc_id].setInitWidths("80,80,80,200,80,90,80,80,120,150,120");
                invoiceDetails.grid["history_b_" + calc_id].setColTypes("ro,ro,ro,ro,ro_p,ro,ro_no,ro,ro,ro,ro");
                invoiceDetails.grid["history_b_" + calc_id].setColAlign(",,,,right,right,right,right,,,");
                invoiceDetails.grid["history_b_" + calc_id].setColSorting("int,str,int,str,int,str,int,str,str,date,str,date");
                invoiceDetails.grid["history_b_" + calc_id].setColumnsVisibility("true,true,true,false,false,false,false,false,false,false,false");
                invoiceDetails.grid["history_b_" + calc_id].enableColumnMove(true);
                invoiceDetails.grid["history_b_" + calc_id].init();
                invoiceDetails.grid["history_b_" + calc_id].loadOrderFromCookie("history_b");
                invoiceDetails.grid["history_b_" + calc_id].loadHiddenColumnsFromCookie("history_b");
                invoiceDetails.grid["history_b_" + calc_id].enableOrderSaving("history_b");
                invoiceDetails.grid["history_b_" + calc_id].enableAutoHiddenColumnsSaving("history_b");
                invoiceDetails.grid["history_b_" + calc_id].enableHeaderMenu();

                // load data to first grid in history tab
                invoiceDetails.grid["history_a_" + calc_id].attachEvent("onRowSelect", function(id, ind) {
                    var history_calc_id = invoiceDetails.grid["history_a_" + calc_id].cells(id, 0).getValue();
                    var history_b_param = {
                        "flag": "w",
                        "calc_id": history_calc_id,
                        "action": "spa_view_invoice"
                    };

                    pivot_exec_spa_2 = "EXEC spa_view_invoice @flag='w', @calc_id='" +  history_calc_id + "'";

                    history_b_param = $.param(history_b_param);
                    var history_b_url = js_data_collector_url + "&" + history_b_param;

                    invoiceDetails.grid["history_b_" + calc_id].clearAll();
                    invoiceDetails.grid["history_b_" + calc_id].loadXML(history_b_url);
                });
            
                invoiceDetails.grid["history_b_" + calc_id].attachEvent("onRowSelect", function(row_id){
                    invoice_history_context_menu = new dhtmlXMenuObject();
                    invoice_history_context_menu.renderAsContextMenu();
                    var invoice_history_menu_obj = [{id:"view_detail", text:"View Detail"}];
                    invoice_history_context_menu.loadStruct(get_form_json_locale(invoice_history_menu_obj));
                    invoiceDetails.grid["history_b_" + calc_id].enableContextMenu(invoice_history_context_menu);
                    
                    invoice_history_context_menu.attachEvent("onClick", function(menuitemId, zoneId) {
                        switch(menuitemId){
                            case 'view_detail':
                                var counterparty_id = invoiceDetails.form[calc_id].getItemValue("counterparty_id");
                                var contract_id = invoiceDetails.form[calc_id].getItemValue("contract_id");
                                var prod_date = dates.convert_to_sql(invoiceDetails.form[calc_id].getItemValue("prod_date_from", true));
                                //var history_row_id = invoiceDetails.grid["history_b_" + calc_id].getSelectedRowId();
                                var line_item_id = invoiceDetails.grid["history_b_" + calc_id].cells(row_id, 2).getValue();
                                var history_a_row_id = invoiceDetails.grid["history_a_" + calc_id].getSelectedRowId();
                                var as_of_date = dates.convert_to_sql(invoiceDetails.grid["history_a_" + calc_id].cells(history_a_row_id, 3).getValue());
                                var invoice_type = invoiceDetails.grid["history_a_" + calc_id].cells(history_a_row_id, 2).getValue();
                                var settlement_date = dates.convert_to_sql(invoiceDetails.form[calc_id].getItemValue("settlement_date", true));
                                
                                if (invoice_type == 'Invoice') {
                                    invoice_type = 'i';
                                } else if (invoice_type == 'Remittance') {
                                    invoice_type = 'r';
                                }
                                
                                call_settlement_report('h', counterparty_id, contract_id, prod_date, as_of_date, line_item_id, invoice_type, settlement_date);
                                break;
                            default:
                                break;                            
                        }
                    });
                });   
                
                // attach menu for invoice header grid
                invoiceDetails.menu["invoice_header_" + calc_id] = invoiceDetails.layout["history_" + calc_id].cells("a").attachMenu({
                        icons_path: js_image_path + "dhxmenu_web/",
                        items: [
                            {id:"export", text:"Export", img:"export.gif", imgdis:"export_dis.gif", items:[
                                {id:"data", text:"Export Data", items:[
                                    {id:"excel", text:"Excel", img:"excel.gif"},
                                    {id:"pdf", text:"PDF", img:"pdf.gif"}
                                ]},
                                {id:"invoice", text:"Export Invoice", items:[
                                    {id:"invoice_html", text:"Generate Invoice", img:"html.gif"},
                                    {id:"invoice_send", text:"Batch", img:"batch.gif"}
                                ], enabled: has_right_view_invoice_export}
                            ]},
                            {id:"pivot", text:"Pivot", img:"pivot.gif", imgdis:"pivot_dis.gif",enabled:"true"}
                        ]
                });
            
                invoiceDetails.menu["invoice_header_" + calc_id].attachEvent("onClick", function(id){
                    switch(id) {
                        case "excel":
                            invoiceDetails.grid["history_a_"+calc_id].toExcel(php_script_loc + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                            break;
                        case "pdf":
                            invoiceDetails.grid["history_a_"+calc_id].toPDF(php_script_loc +'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                            break;
                        case "invoice_html":
						    generate_invoice(calc_id);
							break;
                        case "invoice_pdf":
                            invoice_export_click("PDF", calc_id, runtime_user);
                            break;
                        case "invoice_excel":
                            invoice_export_click("EXCEL", calc_id, runtime_user);
                            break;
                        case "invoice_send":
                            invoice_send(calc_id);
                            break;
                        case 'pivot':
                            var grid_obj =invoiceDetails.grid["history_a_"+calc_id];
                            open_grid_pivot(grid_obj, 'invoice_header_grid', 1, pivot_exec_spa_1, 'Invoice Header');
                            break;
                        default:
                            break;
                    }
                });
            
                // attach menu for invoice header grid
                invoiceDetails.menu["invoice_detail_" + calc_id] = invoiceDetails.layout["history_" + calc_id].cells("b").attachMenu({
                        icons_path: js_image_path + "dhxmenu_web/",
                        items: [
                            {id:"export", text:"Export", img:"export.gif", items:[
                                {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                                {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                            ]},
                            {id:"pivot", text:"Pivot", img:"pivot.gif", imgdis:"pivot_dis.gif",enabled:"true"}
                        ]
                });
            
                invoiceDetails.menu["invoice_detail_" + calc_id].attachEvent("onClick", function(id){
                    switch(id) {
                        case "excel":
                            invoiceDetails.grid["history_b_"+calc_id].toExcel(php_script_loc + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                            break;
                        case "pdf":
                            invoiceDetails.grid["history_b_"+calc_id].toPDF(php_script_loc +'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                            break;
                        case 'pivot':
                            var grid_obj =invoiceDetails.grid["history_b_"+calc_id];
                            open_grid_pivot(grid_obj, 'invoice_details_grid', 1, pivot_exec_spa_2, 'Invoice Details');
                            break;
                        default:
                            break;
                    }
                });
            
                // attach layout to dispute tab
                invoiceDetails.layout["dispute_" + calc_id] = invoiceDetails.tabbar[calc_id].cells("dispute_" + calc_id).attachLayout({
                    pattern: '1C',
                    cells: [
                        {id: "a", text: "Dispute Summary"}
                    ]
                });

                // attach grid to layout in dispute tab
                invoiceDetails.grid["dispute_" + calc_id] = invoiceDetails.layout["dispute_" + calc_id].cells("a").attachGrid();
                invoiceDetails.grid["dispute_" + calc_id].setImagePath(js_image_path + "dhxgrid_web/");
                invoiceDetails.grid["dispute_" + calc_id].setHeader(get_locale_value("Invoice ID, Counterparty, Contact, Dispute Date,Charge Type, Notes",true));
                invoiceDetails.grid["dispute_" + calc_id].setInitWidths("100,120,120,120,200,150");
                invoiceDetails.grid["dispute_" + calc_id].setColTypes("ro,ro,ro,ro,ro,ro");
                invoiceDetails.grid["dispute_" + calc_id].setColSorting("int,str,str,date,str,str");
                invoiceDetails.grid["dispute_" + calc_id].setColumnsVisibility("true,true,true,false,false,false");
                invoiceDetails.grid["dispute_" + calc_id].enableColumnMove(true);
                invoiceDetails.grid["dispute_" + calc_id].init();
                invoiceDetails.grid["dispute_" + calc_id].loadOrderFromCookie("dispute");
                invoiceDetails.grid["dispute_" + calc_id].loadHiddenColumnsFromCookie("dispute");
                invoiceDetails.grid["dispute_" + calc_id].enableOrderSaving("dispute");
                invoiceDetails.grid["dispute_" + calc_id].enableAutoHiddenColumnsSaving("dispute");
                invoiceDetails.grid["dispute_" + calc_id].attachEvent("onRowDblClicked", function(row_id){
                    var lock_status = invoiceDetails.form[calc_id].getItemValue("lock_status");
                    if (lock_status == 'y') { 
                        return; 
                    }
                    
                    var counterparty_id = invoiceDetails.form[calc_id].getItemValue("counterparty_id", true);
                    var contract_id = invoiceDetails.form[calc_id].getItemValue("contract_id", true);
                    var as_of_date = invoiceDetails.form[calc_id].getItemValue("as_of_date", true);
                    var prod_date = invoiceDetails.form[calc_id].getItemValue("prod_date_from", true);
                    
                    unload_invoice_dispute_window();
                    if (!invoice_dispute_window) {
                        invoice_dispute_window = new dhtmlXWindows();
                    }
                    
                    var dispute_id = invoiceDetails.grid["dispute_"+calc_id].cells(row_id, 0).getValue();
                    
                    var win = invoice_dispute_window.createWindow('w1', 0, 0, 525, 350);
                    win.setText("Invoice Dispute: Invoice no - " + invoice_no);
                    win.centerOnScreen();
                    win.setModal(true);
                    win.attachURL('invoice.dispute.php?invoice_no=' + invoice_no + '&dispute_id=' + dispute_id + '&mode=b&counterparty_id=' + counterparty_id + '&contract_id=' + contract_id + '&as_of_date=' + as_of_date + '&prod_date=' + prod_date + '&right_id=' + has_rights_invoice_dispute_iu, false, true);
					win.attachEvent("onClose", function(win){
						setHistory.refresh_invoice_dispute_grid(calc_id);
						return true;
					});
                });
                // attach menu layout in dispute tab
                invoiceDetails.menu["dispute_" + calc_id] = invoiceDetails.layout["dispute_" + calc_id].cells("a").attachMenu({
                    icons_path: js_image_path + "dhxmenu_web/",
                    items: [
                        {id: "edit", text: "Edit", img: "edit.gif", imgdis: "edit_dis.gif", items: [
                            {id:"add_dispute", text:"Add", img:"add.gif", imgdis: "add_dis.gif", enabled: has_rights_invoice_dispute_iu},
                            {id:"delete_dispute", text:"Delete", img:"delete.gif", imgdis: "delete_dis.gif", disabled: true}
                        ]},
                        {id:"export", text:"Export", img:"export.gif", items:[
                            {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                            {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                        ]},
                        {id:"pivot", text:"Pivot", img:"pivot.gif", imgdis:"pivot_dis.gif",enabled:"true"}
                    ]
            });
            
            invoiceDetails.grid["dispute_" + calc_id].attachEvent("onRowSelect", function(row_id){
                var lock_status = invoiceDetails.form[calc_id].getItemValue("lock_status");
                var calc_status = invoiceDetails.form[calc_id].getItemValue("calc_status");
                
                if (lock_status == 'y' || calc_status == 'Finalized') { return; }
                if (has_rights_invoice_dispute_delete)
                    invoiceDetails.menu["dispute_"+calc_id].setItemEnabled("delete_dispute");
            });
            
            invoiceDetails.grid["dispute_" + calc_id].attachEvent("onXLE", function(grid_obj,count){
                var lock_status = invoiceDetails.form[calc_id].getItemValue("lock_status");
                var calc_status = invoiceDetails.form[calc_id].getItemValue("calc_status");
                
                if (lock_status == 'y' || calc_status == 'Finalized') { 
                    invoiceDetails.menu["dispute_" + calc_id].setItemDisabled('add_dispute');  
                }
                invoiceDetails.menu["dispute_" + calc_id].setItemDisabled('delete_dispute');    
            });
            
            // open popup window for on click evet of invoice detail add menu
            invoiceDetails.menu["dispute_"+calc_id].attachEvent("onClick", function(id){
                var counterparty_id = invoiceDetails.form[calc_id].getItemValue("counterparty_id", true);
                var contract_id = invoiceDetails.form[calc_id].getItemValue("contract_id", true);
                var as_of_date = invoiceDetails.form[calc_id].getItemValue("as_of_date", true);
                var prod_date = invoiceDetails.form[calc_id].getItemValue("prod_date_from", true);
                
                switch(id) {
                    case "add_dispute":
                        unload_invoice_dispute_window();
                        if (!invoice_dispute_window) {
                            invoice_dispute_window = new dhtmlXWindows();
                        }
                        
                        var win = invoice_dispute_window.createWindow('w1', 0, 0, 525, 350);
                        win.setText("Invoice Dispute: Invoice no - " + invoice_no);
                        win.centerOnScreen();
                        win.setModal(true);
                        win.attachURL('invoice.dispute.php?invoice_no=' + invoice_no + '&counterparty_id=' + counterparty_id + '&contract_id=' + contract_id + '&as_of_date=' + as_of_date + '&prod_date=' + prod_date + '&mode=a' + '&right_id=' + has_rights_invoice_dispute_iu, false, true);
						win.attachEvent("onClose", function(win){
							setHistory.refresh_invoice_dispute_grid(calc_id);
							return true;
						});
                        break;
                    case "delete_dispute":
                        var selected_row = invoiceDetails.grid["dispute_"+calc_id].getSelectedRowId();
                        if (selected_row != null) {
                            var dispute_id = invoiceDetails.grid["dispute_"+calc_id].cells(selected_row, 0).getValue();
                            var xml = '<Root><PSRecordSet dispute_id="'+dispute_id+'"></PSRecordSet></Root>';
                            
                            data = {"action": "spa_settlement_history",
                                "flag": "c",
                                "xml": xml
                            };
    
                            adiha_post_data('confirm', data, '', '', 'setHistory.refresh_invoice_dispute_grid('+calc_id+')', '', 'Are you sure you want to delete selected dispute record(s)?');
                        }
                        break;
                    case "excel":
                        invoiceDetails.grid["dispute_"+calc_id].toExcel(php_script_loc + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                        break;
                    case "pdf":
                        invoiceDetails.grid["dispute_"+calc_id].toPDF(php_script_loc +'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                        break;
                    case 'pivot':
                        pivot_exec_spa_3 = "EXEC spa_settlement_history @flag='d', @calc_id='" +  calc_id + "'";
                        var grid_obj =invoiceDetails.grid["dispute_"+calc_id];
                        open_grid_pivot(grid_obj, 'dispute_summary', 1, pivot_exec_spa_3, 'Dispute Summary');
                        break;
                    default:
                        break;
                }
            });
            
            setHistory.refresh_invoice_dispute_grid(calc_id);
            
            // attach layout to trueup tab
            invoiceDetails.layout["trueup_" + calc_id] = invoiceDetails.tabbar[calc_id].cells("trueup_" + calc_id).attachLayout({
                pattern: '1C',
                cells: [
                    {id: "a", text: "True up Summary"}
                ]
            });
            
            // attach menu layout in trueup tab
            invoiceDetails.menu["trueup_" + calc_id] = invoiceDetails.layout["trueup_" + calc_id].cells("a").attachMenu({
                icons_path: js_image_path + "dhxmenu_web/",
                items: [
                    {id: "edit", text: "Edit", img: "edit.gif", imgdis: "edit_dis.gif", items: [
                        {id:"finalize", text:"Finalize", img:"finalize.gif", imgdis: "finalize_dis.gif", enabled: has_rights_view_invoice_finalize},
                        {id:"delete_true_up", text:"Delete", img:"delete.gif", imgdis: "delete_dis.gif", disabled: true}
                    ]},
                    {id:"export", text:"Export", img:"export.gif", items:[
                        {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                        {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                    ]},
                    {id:"pivot", text:"Pivot", img:"pivot.gif", imgdis:"pivot_dis.gif",enabled:"true"}
                ]
            });
            invoiceDetails.menu["trueup_"+calc_id].attachEvent("onClick", function(id){
                switch(id) {
                    case 'excel':
                        invoiceDetails.grid["trueup_"+calc_id].toExcel(php_script_loc + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                        break;
                    case 'pdf':
                        invoiceDetails.grid["trueup_"+calc_id].toPDF(php_script_loc +'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                        break;
                    case 'finalize':
                        setHistory.trueup_finalize(calc_id);
                        break;
                    case 'delete_true_up':
                        setHistory.trueup_delete(calc_id);
                        break;    
                    case 'pivot':
                        var grid_obj =invoiceDetails.grid["trueup_"+calc_id];
                        open_grid_pivot(grid_obj, 'trueup_summary', 1, pivot_exec_spa_4, 'True Up Summary');
                        break;
                    }
            });
                                
            invoiceDetails.grid["trueup_" + calc_id] = invoiceDetails.layout["trueup_" + calc_id].cells("a").attachGrid();
            invoiceDetails.grid["trueup_" + calc_id].setImagePath(js_image_path + "dhxgrid_web/");
            invoiceDetails.grid["trueup_" + calc_id].setHeader(get_locale_value("Month/Charge Type, System ID, Amount, Currency,Volume, UOM, Accounting Status, Finalized Date",true),null,["text-align:left;","text-align:left;","text-align:right;","text-align:right;","text-align:right;","text-align:right;","text-align:left;","text-align:left;"]);
            invoiceDetails.grid["trueup_" + calc_id].setColumnIds("month,charge_type,true_up_id,value,currency,Volume,uom,accounting_status,finalized_date");
            invoiceDetails.grid["trueup_" + calc_id].attachHeader('#text_search,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter');
            invoiceDetails.grid["trueup_" + calc_id].setInitWidths("150,0,150,150,150,150,150,150");
            invoiceDetails.grid["trueup_" + calc_id].setColTypes("tree,ro,ro_p,ro,ro_no,ro,ro,ro");
            invoiceDetails.grid["trueup_" + calc_id].setColAlign(",,right,right,right,right,,");
            invoiceDetails.grid["trueup_" + calc_id].setColSorting("str,int,int,str,int,str,str,date");
            invoiceDetails.grid["trueup_" + calc_id].setColumnsVisibility("false,false,false,false,false,false,false,false");
            invoiceDetails.grid["trueup_" + calc_id].enableMultiselect(true);
			invoiceDetails.grid["trueup_" + calc_id].enableTreeCellEdit(false);
            invoiceDetails.grid["trueup_" + calc_id].init();
            setHistory.refresh_trueup_grid(calc_id);
            
            //setHistory.load_payment_tab();
        } else {
            // select tab if already present
            setHistory.invoice_details.cells(calc_id).setActive();
        }

        invoiceDetails.grid["trueup_" + calc_id].attachEvent("onRowSelect", function(id,ind){
            invoiceDetails.menu["trueup_" + calc_id].setItemEnabled('delete_true_up');
        });

        setHistory.set_history.cells('d').progressOff();
    }
    
    setHistory.refresh_trueup_grid = function(calc_id) {
        var param = {
                    "flag": "t",
                    "action": "spa_view_invoice",
                    "grid_type": "tg",
                    "grouping_column": "month,charge_type",
                    "calc_id":calc_id
                };

        pivot_exec_spa_4 = "EXEC spa_view_invoice @flag='t', @calc_id='" +  calc_id + "'";

        param = $.param(param);
        var param_url = js_data_collector_url + "&" + param;
        invoiceDetails.grid["trueup_" + calc_id].clearAll();
        invoiceDetails.grid["trueup_" + calc_id].loadXML(param_url, function(){
            if (invoiceDetails.grid["trueup_" + calc_id].getRowsNum() == 0) {
                invoiceDetails.tabbar[calc_id].cells("trueup_" + calc_id).disable(true);
            } else {
                var finalized_status = invoiceDetails.form[calc_id].getItemValue('calc_status');

                if (finalized_status == 'Finalized'){
                    invoiceDetails.menu["trueup_" + calc_id].setItemDisabled('finalize');
                } else {
                    invoiceDetails.menu["trueup_" + calc_id].setItemEnabled('finalize');
                }

                invoiceDetails.grid["trueup_" + calc_id].expandAll();
            } 
        });
    }
    
    /*
     * [Load the payment tab]
     */ 
    setHistory.load_payment_tab = function() {
        var active_tab_id = setHistory.invoice_details.getActiveTab();
        var calc_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;

        // attach layout to payment tab
        invoiceDetails.layout["payment_" + calc_id] = invoiceDetails.tabbar[calc_id].cells("payment_" + calc_id).attachLayout({
            pattern: '1C',
            cells: [
                {id: "a", text: "Payment Instruction"}
            ]
        });
        
        // attach menu layout in payment tab
        invoiceDetails.menu["payment_" + calc_id] = invoiceDetails.layout["payment_" + calc_id].cells("a").attachMenu({
            icons_path: js_image_path + "dhxmenu_web/",
            items: [
                {id: "edit", text: "Edit", img: "edit.gif", imgdis: "edit_dis.gif", items: [
                    {id:"add_group", text:"Add Group", img:"add.gif", imgdis: "add_dis.gif", enabled: 1},
                    {id:"add_charge_type", text:"Add Charge Type", img:"add.gif", imgdis: "add_dis.gif", enabled: 1},
                    {id:"delete", text:"Delete", img:"delete.gif", imgdis: "delete_dis.gif", enabled: 0}
                ]},
                {id:"export", text:"Export", img:"export.gif", items:[
                    {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                    {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                ]},
                {id:"rpf", text:"RPF", img:"process.gif", imgdis:"process_dis.gif",enabled:"true"}
            ]
        });
        invoiceDetails.menu["payment_"+calc_id].attachEvent("onClick", function(id){
            switch(id) {
                case 'add_group':
                    setHistory.open_payment_instruction('header', '');
                    break;    
                case 'add_charge_type':
                    setHistory.open_payment_instruction('detail', '');
                    break;
                case 'delete':
                    var selected_row = invoiceDetails.grid["payment_" + calc_id].getSelectedRowId();
                    var tree_level = invoiceDetails.grid["payment_" + calc_id].getLevel(selected_row);
                    if (tree_level == 0) {
                        var payment_id = invoiceDetails.grid["payment_" + calc_id].cells(selected_row, invoiceDetails.grid["payment_" + calc_id].getColIndexById('payment_charge_type')).getValue();
                        setHistory.delete_payment_instrcution('header', payment_id);
                    } else if (tree_level == 1) {
                        var payment_id = invoiceDetails.grid["payment_" + calc_id].cells(selected_row, invoiceDetails.grid["payment_" + calc_id].getColIndexById('payment_ins_detail_id')).getValue();
                        setHistory.delete_payment_instrcution('detail', payment_id);
                    }
                    break;
                case 'excel':
                    invoiceDetails.grid["payment_"+calc_id].toExcel(php_script_loc + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                    break;
                case 'pdf':
                    invoiceDetails.grid["payment_"+calc_id].toPDF(php_script_loc +'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                    break;
                case 'rpf':
                    var selected_row = invoiceDetails.grid["payment_" + calc_id].getSelectedRowId();
                    var tree_level = invoiceDetails.grid["payment_" + calc_id].getLevel(selected_row);
                    if (tree_level == 0) {
                        var payment_id = invoiceDetails.grid["payment_" + calc_id].cells(selected_row, invoiceDetails.grid["payment_" + calc_id].getColIndexById('payment_charge_type')).getValue();
                        setHistory.open_payment_rfp(payment_id);
                    } else if (tree_level == 1) {
                        show_messagebox('Please select the Payment Instruction.');
                        return;
                    }
                    break;
            }
        });
        
        invoiceDetails.grid["payment_" + calc_id] = invoiceDetails.layout["payment_" + calc_id].cells("a").attachGrid();
        invoiceDetails.grid["payment_" + calc_id].setImagePath(js_image_path + "dhxgrid_web/");
        invoiceDetails.grid["payment_" + calc_id].setHeader("Payment Instruction/Charge Type,Date,Prod Month, Value,Payment Instruction Header, Payment Instruction Detail, Invoice Line Item ID, Calc Detail ID ");
        invoiceDetails.grid["payment_" + calc_id].attachHeader('#text_search,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filterr');
        invoiceDetails.grid["payment_" + calc_id].setColumnIds("payment_charge_type,date,prod_month,value,paymment_ins_header_id,payment_ins_detail_id,invoice_line_item_id,calc_detail_id");
        invoiceDetails.grid["payment_" + calc_id].setInitWidths("250,180,180,180,180,180,180,180");
        invoiceDetails.grid["payment_" + calc_id].setColTypes("tree,ro,ro,ro,ro,ro,ro,ro");
        invoiceDetails.grid["payment_" + calc_id].setColSorting("str,str,str,str,str,str,str,str");
        invoiceDetails.grid["payment_" + calc_id].setColumnsVisibility("false,false,false,false,true,true,true,true");
        invoiceDetails.grid["payment_" + calc_id].enableTreeCellEdit(false);
        invoiceDetails.grid["payment_" + calc_id].init();
        setHistory.refresh_payment_grid();
        
        invoiceDetails.grid["payment_" + calc_id].attachEvent("onRowDblClicked", function(rId,cInd){
            var tree_level = invoiceDetails.grid["payment_" + calc_id].getLevel(rId);
            if (tree_level == 0) {
                var payment_id = invoiceDetails.grid["payment_" + calc_id].cells(rId, invoiceDetails.grid["payment_" + calc_id].getColIndexById('payment_charge_type')).getValue();
                setHistory.open_payment_instruction('header', payment_id);
            } else if (tree_level == 1) {
                var payment_id = invoiceDetails.grid["payment_" + calc_id].cells(rId, invoiceDetails.grid["payment_" + calc_id].getColIndexById('payment_ins_detail_id')).getValue();
                setHistory.open_payment_instruction('detail', payment_id);
            }
        });
        
        invoiceDetails.grid["payment_" + calc_id].attachEvent("onRowSelect", function(id,ind){
            invoiceDetails.menu["payment_" + calc_id].setItemEnabled('delete');
        });
    }
    
    
    /*
     * [Open the payment grid window]
     */
    setHistory.open_payment_instruction = function(call_from, payment_id) {
        var calc_id = setHistory.get_active_calc_id();
        
        var dhxWins = new dhtmlXWindows();
        param = 'payment.instruction.php?call_from=' + call_from + '&calc_id=' + calc_id + '&payment_ins_id=' + payment_id;
        var is_win = dhxWins.isWindow('w11');
        if (is_win == true) {
            w11.close();
        }
        w11 = dhxWins.createWindow("w11", 0, 0, 530, 350);
        if (call_from == 'header') {
            w11.setText("Payment Instruction - Group");    
        } else {
            w11.setText("Payment Instruction -  Charge Type");
        }
        w11.centerOnScreen();
        w11.setModal(true);
        w11.attachURL(param, false, true);

        w11.attachEvent("onClose", function(win) {
             setHistory.refresh_payment_grid();
            return true;
        });
    }
                    
    /*
     * [Open the payment grid window]
     */
    setHistory.open_payment_rfp = function(payment_id) {
        var calc_id = setHistory.get_active_calc_id();
        
        var dhxWins = new dhtmlXWindows();
        param = 'payment.rfp.php?calc_id=' + calc_id + '&payment_id=' + payment_id;
        var is_win = dhxWins.isWindow('w11');
        if (is_win == true) {
            w11.close();
        }
        w11 = dhxWins.createWindow("w11", 0, 0, 530, 350);
        w11.setText("Payment Instruction - RFP");    
        w11.centerOnScreen();
        w11.setModal(true);
        w11.attachURL(param, false, true);

        w11.attachEvent("onClose", function(win) {
            return true;
        });
    }                 
    
    /*
     * [Delete the payment grid header and detail]
     */
    setHistory.delete_payment_instrcution = function(call_from, payment_id) {
        var calc_id = setHistory.get_active_calc_id();
        
        if (call_from == 'header') {
            var data = {
                            "flag": "d",
                            "action": "spa_payment_instruction",
                            "payment_ins_header":payment_id,
                            "calc_id": calc_id
                        };
        } else if (call_from == 'detail') {
            var data = {
                            "flag": "e",
                            "action": "spa_payment_instruction",
                            "payment_ins_detail_id":payment_id
                        };
        }
        
        adiha_post_data('confirm', data, '', '', 'setHistory.refresh_payment_grid()', '', '');
    }
    
    /*
     * [Refresh the payment grid]
     */
    setHistory.refresh_payment_grid = function() {
        var calc_id = setHistory.get_active_calc_id();
        
        var param = {
                    "flag": "g",
                    "action": "spa_payment_instruction",
                    "grid_type": "tg",
                    "grouping_column": "payment_ins_name,charge_type",
                    "calc_id":calc_id
                };

        param = $.param(param);
        var param_url = js_data_collector_url + "&" + param;
        invoiceDetails.grid["payment_" + calc_id].clearAll();
        invoiceDetails.grid["payment_" + calc_id].loadXML(param_url, function(){
            invoiceDetails.menu["payment_" + calc_id].setItemDisabled('delete');
            invoiceDetails.grid["payment_" + calc_id].expandAll();
        });
    }
    
    
    setHistory.get_active_calc_id = function() {
        var active_tab_id = setHistory.invoice_details.getActiveTab();
        var calc_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        return calc_id;
    }
    
    setHistory.trueup_delete = function(calc_id) {
         var true_up_id_arr = new Array(); 
         var selected_row = invoiceDetails.grid["trueup_" + calc_id].getSelectedRowId();
         var selected_row_arr = selected_row.split(',');  
         var true_up_column_id = invoiceDetails.grid["trueup_" + calc_id].getColIndexById('true_up_id'); 
         
         for (cnt = 0; cnt < selected_row_arr.length; cnt++) { 
           var level = invoiceDetails.grid["trueup_" + calc_id].getLevel(selected_row_arr[cnt]); 
           if (level == 0) {
                var child_ids = invoiceDetails.grid["trueup_" + calc_id].getAllSubItems(selected_row_arr[cnt]);
                var child_ids_arr = child_ids.split(',');   

                for (child_cnt = 0; child_cnt < child_ids_arr.length; child_cnt++) { 
                    var c_id = invoiceDetails.grid["trueup_" + calc_id].cells(child_ids_arr[child_cnt],true_up_column_id - 1).getValue();
                    true_up_id_arr.push(c_id);
                }
           } else{
                var id = invoiceDetails.grid["trueup_" + calc_id].cells(selected_row_arr[cnt],true_up_column_id - 1).getValue();
                true_up_id_arr.push(id);
           }
            
         } 

         unique_true_up_ids = true_up_id_arr.filter(function(item, pos, self) {
            return self.indexOf(item) == pos;
         })
 
         var true_up_ids = unique_true_up_ids.toString();
 
         dhtmlx.confirm({
                                title: "Confirmation",
                                ok: "Confirm",
                                cancel: "No",
                                type: "confirm-error",
                                text: 'Are you sure you want to delete selected trueup(s)?',
                                callback: function(type) {
                                    if (type) {
                                        var data = {
                                            "action": "spa_view_invoice",
                                            "flag": "z", 
                                            "true_up_id": true_up_ids
                                          }
                  
                                        adiha_post_data('alert', data, '', '', 'trueup_delete_callback('+calc_id+')', '', '');
                                    }
                                }
                            });         
         
    }    

    trueup_delete_callback = function(calc_id) {
        setHistory.refresh_trueup_grid(calc_id);
        setHistory.refresh_invoice_grid();
        setHistory.refresh_invoice_detail_grid(calc_id);

    }

    setHistory.trueup_finalize = function(calc_id) {
		var prod_date = invoiceDetails.form[calc_id].getItemValue("prod_date_from", true);
        var selected_row = invoiceDetails.grid["trueup_" + calc_id].getSelectedRowId();
        var selected_row_arr = selected_row.split(',');
        var finalized_flag = 0;
        var true_up_id_arr = new Array();
        if (selected_row == null) {
            show_messagebox('Please select the row');
            return;
        }
        
        for (cnt = 0; cnt < selected_row_arr.length; cnt++) {
            var tree_level = invoiceDetails.grid["trueup_" + calc_id].getLevel(selected_row_arr[cnt]);
            if (tree_level > 0) {
                var accounting_status = invoiceDetails.grid["trueup_" + calc_id].cells(selected_row_arr[cnt],6).getValue();
                if (accounting_status == 'Finalized') {
                    finalized_flag = 1;
                }
                var id = invoiceDetails.grid["trueup_" + calc_id].cells(selected_row_arr[cnt],1).getValue();
                true_up_id_arr.push(id);
            }
        }

        if (finalized_flag == 1) {
            show_messagebox('The charge type is already finalized.');
            return;
        }
        
        var invoice_template_options = '<?php echo $invoice_template_options_json; ?>';
        var finalize_form_data = [
                                    {type: "settings", position: "label-left", labelWidth: 150, inputWidth: 130, position: "label-top", offsetLeft: 20},
                                    {type: "combo", name: "invoice_template", label: "Invoice Template", "options":[<?php echo $invoice_template_options_json; ?>]},
                                    {type: "calendar", name: "invoice_month", label: "Invoice Month", "dateFormat": client_date_format, "value":prod_date,  "disabled":1},
                                    {type: "button", value: "Ok", img: "tick.png"}
                                ];
            
        var finalize_popup = new dhtmlXPopup();
        var finalize_form = finalize_popup.attachForm(finalize_form_data);
        var width = setHistory.set_history.cells('a').getWidth();
        finalize_popup.show(parseInt(width) + 25,100,45,45);
        
        finalize_form.attachEvent("onButtonClick", function(){
            var invoice_template = finalize_form.getItemValue('invoice_template');
            var invoice_month = finalize_form.getItemValue('invoice_month', true);
			invoice_month = dates.convert_to_sql(invoice_month);
            var true_up_id = true_up_id_arr.toString();
            finalize_popup.hide();
				
			var data = {
                                "action": "spa_view_invoice",
                                "flag": "f",
                                "calc_id":calc_id,
                                "true_up_id": true_up_id,
                                "invoice_template": invoice_template,
                                "invoice_month": invoice_month
                              }

            adiha_post_data('alert', data, '', '', 'trueup_finalize_callback('+calc_id+')', '', '');

         });
		
		
    }
    
    trueup_finalize_callback = function(calc_id) {
        setHistory.refresh_trueup_grid(calc_id);
        setHistory.refresh_invoice_grid();
        setHistory.refresh_invoice_detail_grid(calc_id);

    }
    
    /*
     * Open document
     * @param {type} tab_id
     * @returns {undefined}         */
    setHistory.open_document = function(object_id) {
        var dhxWins = new dhtmlXWindows();
        var object_id = (object_id.indexOf("tab_") != -1) ? object_id.replace("tab_", "") : object_id;
        param = '../../_setup/manage_documents/manage.documents.php?notes_category=' + category_id + '&notes_object_id=' + object_id + '&is_pop=true&call_from=invoice';
        var is_win = dhxWins.isWindow('w11');
        if (is_win == true) {
            w11.close();
        }
        w11 = dhxWins.createWindow("w11", 520, 100, 530, 550);
        w11.setText("Documents");
        w11.setModal(true);
        w11.maximize();
        w11.attachURL(param, false, true);

        w11.attachEvent("onClose", function(win) {
            update_document_counter(object_id, toolbar_object);
            return true;
        });
    } 

    /**
     * [get_form_data get form data for invoice tab first cell using template]
     * @param  {[type]} r_id [row id of invoice grid]
     */
    setHistory.get_form_data = function(r_id) {
        var date_format = "<?php echo $date_format;?>";
        var form_template = _.template($('#form_template').text());
        var tree_contract_id = setHistory.invoice_grid.getParentId(r_id);
        var tree_counterparty_id = setHistory.invoice_grid.getParentId(tree_contract_id);
        var contract = setHistory.invoice_grid.getItemText(tree_contract_id);
        var counterparty = setHistory.invoice_grid.getItemText(tree_counterparty_id);
        var invoice_no = setHistory.invoice_grid.cells(r_id, setHistory.invoice_grid.getColIndexById('invoice_number')).getValue();
        var as_of_date = setHistory.invoice_grid.cells(r_id, setHistory.invoice_grid.getColIndexById('as_of_date')).getValue();
        var date_from = setHistory.invoice_grid.cells(r_id, setHistory.invoice_grid.getColIndexById('date_from')).getValue();
        var date_to = setHistory.invoice_grid.cells(r_id, setHistory.invoice_grid.getColIndexById('date_to')).getValue();
        var settlement_date = setHistory.invoice_grid.cells(r_id, setHistory.invoice_grid.getColIndexById('settlement_date')).getValue();
        var payment_date = setHistory.invoice_grid.cells(r_id, setHistory.invoice_grid.getColIndexById('payment_date')).getValue();
        var lock_status = (setHistory.invoice_grid.cells(r_id, setHistory.invoice_grid.getColIndexById('lock_status')).getValue() == 'Locked') ? 'y' : 'n';
        var calc_status = setHistory.invoice_grid.cells(r_id, setHistory.invoice_grid.getColIndexById('calc_status')).getValue();
        var invoice_status = setHistory.invoice_grid.cells(r_id, setHistory.invoice_grid.getColIndexById('invoice_status_id')).getValue();
        var invoice_type = setHistory.invoice_grid.cells(r_id, setHistory.invoice_grid.getColIndexById('invoice_type')).getValue();
        var finalized_date = setHistory.invoice_grid.cells(r_id, setHistory.invoice_grid.getColIndexById('finalized_date')).getValue();
        var invoice_note = setHistory.invoice_grid.cells(r_id, setHistory.invoice_grid.getColIndexById('invoice_note')).getValue();
        var counterparty_id = setHistory.invoice_grid.cells(r_id, setHistory.invoice_grid.getColIndexById('counterparty_id')).getValue();
        var contract_id = setHistory.invoice_grid.cells(r_id, setHistory.invoice_grid.getColIndexById('contract_id')).getValue();
        
        formData = form_template({                            
                        date_format: date_format,
                        invoice_no: invoice_no,
                        as_of_date: as_of_date,
                        date_from: date_from,
                        date_to: date_to,
                        settlement_date: settlement_date,
                        payment_date: payment_date,
                        lock_status: lock_status,
                        calc_status: calc_status,
                        invoice_status: invoice_status,
                        invoice_type: invoice_type,
                        finalized_date: finalized_date,
                        invoice_note:invoice_note,
                        invoice_status_dropdown: JSON.stringify(invoice_status_dropdown),
                        counterparty: counterparty,
                        contract: contract,
                        counterparty_id: counterparty_id,
                        contract_id: contract_id,
                   });
        formData = jQuery.parseJSON(formData);

        return formData;
    }
    
    setHistory.reload_form_data = function(invoice_number, calc_id) {
        var date_format = "<?php echo $date_format;?>";
        var form_template = _.template($('#form_template').text());
        
        var form_param = {"action": "spa_settlement_history", "flag": "g", "calc_id": calc_id};
        
        $.ajax({
        type: "POST",
            dataType: "json",
            url: js_form_process_url,
            async: false,
            data: form_param,
            success: function(result) { 
                response_data = result['json'];
                var contract = response_data[0].contract;
                var counterparty = response_data[0].counterparty;
                var invoice_no = response_data[0].invoice_number;
                var as_of_date = response_data[0].as_of_date;
                var date_from = response_data[0].date_from;
                var date_to = response_data[0].date_to;
                var settlement_date = response_data[0].settlement_date;
                var payment_date = response_data[0].payment_date;
                var lock_status = (response_data[0].lock_status == 'Locked') ? 'y' : 'n';
                var calc_status = response_data[0].calc_status;
                var invoice_status = response_data[0].invoice_status_id;
                var invoice_type = response_data[0].invoice_type;
                var finalized_date = response_data[0].finalized_date;
                var invoice_note = response_data[0].invoice_note;
                var counterparty_id = response_data[0].counterparty_id;
                var contract_id = response_data[0].contract_id;
                 
                                     
                formData = form_template({                            
                                        date_format: date_format,
                                        invoice_no: invoice_no,
                                        as_of_date: as_of_date,
                                        date_from: date_from,
                                        date_to: date_to,
                                        settlement_date: settlement_date,
                                        payment_date: payment_date,
                                        lock_status: lock_status,
                                        calc_status: calc_status,
                                        invoice_status: invoice_status,
                                        invoice_type: invoice_type,
                                        finalized_date: finalized_date,
                                        invoice_note:invoice_note,
                                        invoice_status_dropdown: JSON.stringify(invoice_status_dropdown),
                                        counterparty: counterparty,
                                        contract: contract,
                                        counterparty_id: counterparty_id,
                                        contract_id: contract_id,
                                   });
                formData = jQuery.parseJSON(formData);
                
                invoiceDetails.form[calc_id] = invoiceDetails.layout["invoice_"+calc_id].cells("a").attachForm();
                invoiceDetails.form[calc_id].loadStruct(get_form_json_locale(formData), function() {
                	invoiceDetails.form[calc_id].setItemValue('invoice_status', invoice_status);
			
                    var finalized_status = invoiceDetails.form[calc_id].getItemValue('calc_status');
                    var lock_status = invoiceDetails.form[calc_id].getItemValue('lock_status');
                    if (finalized_status == 'Finalized' || lock_status == 'y') {
                        invoiceDetails.form[calc_id].disableItem("invoice_status");
                        if (lock_status != 'y') {
                            invoiceDetails.form[calc_id].disableItem("lock_status");
                        }
                        invoiceDetails.form[calc_id].disableItem("invoice_note");
                        invoiceDetails.form[calc_id].disableItem("payment_date");
                        //invoiceDetails.form[calc_id].disableItem("settlement_date");
                        invoiceDetails.menu["invoice_" + calc_id].setItemDisabled("manual");
                        invoiceDetails.menu["dispute_" + calc_id].setItemDisabled('add_dispute');  
                        invoiceDetails.menu["dispute_" + calc_id].setItemDisabled('delete_dispute');    
                    } else {
                        invoiceDetails.menu["invoice_" + calc_id].setItemEnabled("manual");
                        invoiceDetails.menu["dispute_" + calc_id].setItemEnabled('add_dispute');  
                    }

                    setHistory.refresh_invoice_detail_grid(calc_id);
                    setHistory.refresh_trueup_grid(calc_id);
                    invoiceDetails.grid["dispute_"+calc_id].clearSelection();
                });
				setHistory.invoice_details.tabs(calc_id).setText(invoice_no);
            }
        });    
    }
    
    setHistory.refresh_invoice_grid_after_delete = function(calc_id) {
        var all_tab = setHistory.invoice_details.getAllTabs();
        var calc_id_arr = calc_id.split(',');
        
        for (i=0; i<calc_id_arr.length; i++) {
            if(jQuery.inArray(calc_id_arr[i], all_tab) > -1) {
                setHistory.invoice_details.tabs(calc_id_arr[i]).close();
            }
        }
        setHistory.refresh_invoice_grid();
    }

    /**
     * [refresh_invoice_grid Refresh invoice grid]
     */
    setHistory.refresh_invoice_grid = function() {
		pivot_exec_invoice = '';
        setHistory.set_history.cells('b').collapse();
        setHistory.set_history.cells('c').progressOn();
        //setHistory.invoice_grid.saveOpenStates();
        form_data = setHistory.filter_form.getFormData();
        var filter_param = '';
        for (var a in form_data) {
           if (form_data[a] != '' && form_data[a] != null) {

                if (a == 'prod_date_from') {
                  var value_prod_date_from = setHistory.filter_form.getItemValue(a, true);
                }
                 if (a == 'prod_date_to') {
                  var value_prod_date_to = setHistory.filter_form.getItemValue(a, true);
                }
                if (a == 'settlement_date_from') {
                  var  value_settlement_date_from = setHistory.filter_form.getItemValue(a, true);
                }              
                if (a == 'settlement_date_to') {
                   var value_settlement_date_to = setHistory.filter_form.getItemValue(a, true);
                }
                if (a == 'payment_date_from') {
                  var value_payment_date_from = setHistory.filter_form.getItemValue(a, true);
                }
                 if (a == 'payment_date_to') {
                  var value_payment_date_to = setHistory.filter_form.getItemValue(a, true);
                }
                
               
               
                if (setHistory.filter_form.getItemType(a) == 'calendar') {
				if (value_prod_date_to != '' && value_prod_date_from != '' && value_prod_date_from > value_prod_date_to) {
                show_messagebox('<strong>Delivery Date To </strong> should be greater than <strong> Delivery Date From.</strong>');
                setHistory.set_history.cells('b').progressOff();
				setHistory.set_history.cells('c').progressOff();
				return;
				 
                }
                
                if (value_settlement_date_to != '' && value_settlement_date_from != '' && value_settlement_date_from > value_settlement_date_to) {
                show_messagebox('<strong> Settlement Date To </strong> should be greater than <strong> Settlement Date From.</strong>');
                 setHistory.set_history.cells('b').progressOff();
				setHistory.set_history.cells('c').progressOff();
				return;
				 
                }
                
                if (value_payment_date_to != '' && value_payment_date_from != '' && value_payment_date_from > value_payment_date_to) {
                show_messagebox('<strong> Payment Date To </strong> should be greater than <strong>Payment Date From.</strong>');
                 setHistory.set_history.cells('b').progressOff();
				setHistory.set_history.cells('c').progressOff();
				return;
				 
                }
                    value = setHistory.filter_form.getItemValue(a, true);
                } else {
                    value = form_data[a];
                }
                
                if (a != 'apply_filters' && a != 'label_counterparty_id' && a != 'label_contract_id') {
                        filter_param += "&" + a + '=' + value;    
						pivot_exec_invoice += ",@" + a + "='" + value + "'";
                }
            }
          }
        
		pivot_exec_invoice = "EXEC spa_settlement_history @flag = 'g'" + pivot_exec_invoice
		
        var param = {
            "flag": "g",
            "action":"spa_settlement_history",
            "grid_type":"tg",
            "grouping_column":"Counterparty,contract,invoice_number"
        };

        param = $.param(param);
        var param_url = js_data_collector_url + "&" + param + filter_param;
        var grid_cell = setHistory.set_history.cells("c");
        //grid_cell.progressOn();
        //setHistory.invoice_grid.clearAll();
        //setHistory.invoice_grid.loadOpenStates();
        setHistory.invoice_grid.clearAndLoad(param_url, loadGridStates);
        setHistory.invoice_menu.setItemDisabled("t");
        setHistory.invoice_menu.setItemDisabled("audit");
        //setHistory.invoice_menu.setItemDisabled("invoice_status");
        //setHistory.invoice_menu.setItemDisabled("invoice_send");
        setHistory.invoice_menu.setItemEnabled("t1");
        setHistory.invoice_menu.setItemEnabled("t2");
        setHistory.invoice_menu.setItemEnabled("expand_collapse");
		setHistory.invoice_menu.setItemEnabled("pivot");
        //grid_cell.progressOff();
        
        if (undock_status == 1) {
            undock_window();
        } 
    }

    /**
	*[loadGridStates Load states of Invoice Grid]
	*/
	loadGridStates = function() {
        openAllInvoices();
        setHistory.invoice_grid.filterByAll();
        if(undock_status == 1) {    
            setHistory.set_history.dhxWins.window("c").progressOff();
        }
        setHistory.set_history.cells('c').progressOff();
        refresh_open_tab();
	}
    
    function refresh_open_tab() {
        var opened_tabs = setHistory.invoice_details.getAllTabs();
        for (count = 0; count < opened_tabs.length; count++) {
            var invoice_number = setHistory.invoice_details.tabs(opened_tabs[count]).getText();
            var calc_id = setHistory.invoice_details.tabs(opened_tabs[count]).getId();
            setHistory.reload_form_data(invoice_number, calc_id);
        }

        var invoice_id = '<?php echo $invoice_id; ?>';
        if (invoice_id != '') {
            setHistory.invoice_grid.forEachRow(function(id) {
                var value = setHistory.invoice_grid.cells(id, 0).getValue();                         
                if(value.trim() == invoice_id.trim()) {
                    setHistory.create_invoice_detail_tab(id, 0);
                }
            }); 
        }        
    }
    
    /**
	*[openAllInvoices Open All nodes of Invoice Grid]
	*/
	openAllInvoices = function() {
       setHistory.invoice_grid.expandAll();
       expand_state = 1;
	}
    
    /**
	*[closeAllInvoices Close All nodes of Invoice Grid]
	*/
	closeAllInvoices = function() {
       setHistory.invoice_grid.collapseAll();
       expand_state = 0;
	}
    
	/**
	*[refresh_invoice_detail_grid Refresh Invoice Detail Grid]
    * @param  {[type]} calc_id     [Calc id]
	*/
	setHistory.refresh_invoice_detail_grid = function(calc_id) {
		// load data to detail grid in invoice tab
		var invoice_param = {
			"flag": "w",
			"calc_id": calc_id,
			"action": "spa_settlement_history"
		};

		invoice_param = $.param(invoice_param);
		var data_url = js_data_collector_url + "&" + invoice_param;
		invoiceDetails.grid["invoice_" + calc_id].clearAll();
		invoiceDetails.grid["invoice_" + calc_id].loadXML(data_url, function(){
            invoiceDetails.menu["invoice_"+calc_id].setItemDisabled("edit");
        });
	}
	
	/**
	*[refresh_invoice_dispute_grid Refresh Invoice Dispute Grid]
    * @param  {[type]} calc_id     [Calc id]
	*/
	setHistory.refresh_invoice_dispute_grid = function(calc_id) {
		// load data to Dispute grid in Dispute tab
		var invoice_param = {
			"flag": "d",
			"calc_id": calc_id,
			"action": "spa_settlement_history"
		};

		invoice_param = $.param(invoice_param);
		var data_url = js_data_collector_url + "&" + invoice_param;
		invoiceDetails.grid["dispute_"+calc_id].clearAll();
		invoiceDetails.grid["dispute_"+calc_id].loadXML(data_url, function() {
            setHistory.set_history.cells('b').progressOff();
        });
	}
	
	
    /**
     * [menu_click Menu click function for invoice grid]
     * @param  {[type]} id     [Menu id]
     * @param  {[type]} zoneId [mixed context menu zone, if a menu rendered in the context menu mode]
     * @param  {[type]} cas    [object state of CTRL/ALT/SHIFT keys during the click (pressed/not pressed)]
     */

    function check_close_accounting_period(id) {
        var xml = "<Root>";
        var selected_row = setHistory.invoice_grid.getSelectedRowId();
        if (selected_row != null) {
            var selected_row_array = selected_row.split(',');
            for (var i = 0; i < selected_row_array.length; i++) {
                var invoice_id = setHistory.invoice_grid.cells(selected_row_array[i], setHistory.invoice_grid.getColIndexById('invoice_number')).getValue();
                var contract_id = setHistory.invoice_grid.cells(selected_row_array[i], setHistory.invoice_grid.getColIndexById('contract_id')).getValue();
                var as_of_date = setHistory.invoice_grid.cells(selected_row_array[i], setHistory.invoice_grid.getColIndexById('as_of_date')).getValue();
                if( as_of_date) {
                   as_of_date = dates.convert_to_sql(as_of_date);
                }
                xml += '<PSRecordSet invoice_id = "' + invoice_id + '" contract_id = "' + contract_id + '" as_of_date = "' + as_of_date + '" action = "' + id +'"></PSRecordSet>';
            }
        } else {
            setHistory.invoice_grid.forEachRow(function(rid){
                var tree_level = setHistory.invoice_grid.getLevel(rid);
                if (tree_level == 2) {
                    var invoice_id = setHistory.invoice_grid.cells(rid, setHistory.invoice_grid.getColIndexById('invoice_number')).getValue();
                    var contract_id = setHistory.invoice_grid.cells(rid, setHistory.invoice_grid.getColIndexById('contract_id')).getValue();
                    var as_of_date = setHistory.invoice_grid.cells(rid, setHistory.invoice_grid.getColIndexById('as_of_date')).getValue();
                    if( as_of_date) {
                        as_of_date = dates.convert_to_sql(as_of_date);
                    }
                    xml += '<PSRecordSet invoice_id = "' + invoice_id + '" contract_id = "' + contract_id + '" as_of_date = "' + as_of_date +  '" action = "' + id +'"></PSRecordSet>';
                }
            });
        }
        xml += "</Root>";
        if (xml != '<Root></Root>') {
            data = {"action": "spa_close_measurement_books_dhx",
                "flag": "l",
                "xml": xml
            };
            adiha_post_data('return_array', data, '', '', 'setHistory.status_close_accounting_period', '', '');
        }
    }

    setHistory.status_close_accounting_period = function (result) {
        status_close_accounting_period = result[0][0];
        var selected_row = null;
        var selected_row_array = [];
        var grid_obj = setHistory.invoice_grid;
        var row_ids =  grid_obj.getSelectedRowId();
        if (row_ids) {
            var row_id_array = row_ids.split(",");
            for (var count = 0; count < row_id_array.length; count++) {
                var tree_level = grid_obj.getLevel(row_id_array[count]);
                if (tree_level == 0) {
                    var child = grid_obj.getAllSubItems(row_id_array[count]);
                    var child_array = [];
                    child_array = child.split(",");
                    for (var i = 0; i < child_array.length; i++) {
                        var child_level = grid_obj.getLevel(child_array[i]);
                        if (child_level == 2) {
                            if (selected_row_array.indexOf(child_array[i]) == '-1' && child_array[i] != '') {
                                selected_row_array.push(child_array[i]);
                            }
                        }

                    }
                } else if (tree_level == 1) {
                    child = grid_obj.getAllSubItems(row_id_array[count]);
                    child_array = [];
                    if (child) {
                        child_array = child.split(",");
                        for (var i = 0; i < child_array.length; i++) {
                            if (selected_row_array.indexOf(child_array[i]) == '-1' && child_array[i] != '') {
                                selected_row_array.push(child_array[i]);
                            }
                        }
                    }
                } else {
                    if (selected_row_array.indexOf(row_id_array[count]) == '-1' && row_id_array[count] != '') {
                        selected_row_array.push(row_id_array[count]);
                    }
                }
            }
            selected_row = selected_row_array.toString();
        }

        undock_status = undock_state;
        var action = result[0][2];
        if(status_close_accounting_period == 'true') {
            switch(action) {
                case "lock":
                    var xml = "<Root>";
                    if (selected_row != null) {
                        var selected_row_array = selected_row.split(',');

                        for(var i = 0; i < selected_row_array.length; i++) {
                            var invoice_no = setHistory.invoice_grid.cells(selected_row_array[i], setHistory.invoice_grid.getColIndexById('invoice_number')).getValue();
                            var calc_id = setHistory.invoice_grid.cells(selected_row_array[i], setHistory.invoice_grid.getColIndexById('calc_id')).getValue();

                            if (calc_id != '') {
                                xml += '<PSRecordSet calc_id = "' + calc_id + '" invoice_number = "' + invoice_no + '"></PSRecordSet>';
                            }
                        }
                        var message = 'Are you sure you want to lock selected invoice(s)?';
                    } else {
                        setHistory.invoice_grid.forEachRow(function(rid){
                            var tree_level = setHistory.invoice_grid.getLevel(rid);

                            if (tree_level == 2) {
                                var invoice_type = setHistory.invoice_grid.cells(rid, setHistory.invoice_grid.getColIndexById('invoice_type')).getValue();

                                if (invoice_type != 'Netting') {
                                    var invoice_no = setHistory.invoice_grid.cells(rid, setHistory.invoice_grid.getColIndexById('invoice_number')).getValue();
                                    var calc_id = setHistory.invoice_grid.cells(rid, setHistory.invoice_grid.getColIndexById('calc_id')).getValue();

                                    if (calc_id != '') {
                                        xml += '<PSRecordSet calc_id = "' + calc_id + '" invoice_number = "' + invoice_no + '"></PSRecordSet>';
                                    }
                                }
                            }
                        })
                        var message = 'Are you sure you want to lock all invoice(s)?';
                    }
                    xml += "</Root>";

                    if (xml != '<Root></Root>') {
                        data = {"action": "spa_settlement_history",
                            "flag": "l",
                            "xml": xml
                        };

                        adiha_post_data('confirm', data, '', '', 'setHistory.refresh_invoice_grid', '', message);
                    }
                    break;

                case "unlock":
                    var xml = "<Root>";
                    if (selected_row != null) {
                        var selected_row_array = selected_row.split(',');

                        for(var i = 0; i < selected_row_array.length; i++) {
                            var invoice_no = setHistory.invoice_grid.cells(selected_row_array[i], setHistory.invoice_grid.getColIndexById('invoice_number')).getValue();
                            var calc_id = setHistory.invoice_grid.cells(selected_row_array[i], setHistory.invoice_grid.getColIndexById('calc_id')).getValue();

                            if (calc_id != '') {
                                xml += '<PSRecordSet calc_id = "' + calc_id + '" invoice_number = "' + invoice_no + '"></PSRecordSet>';
                            }
                        }
                        var message = 'Are you sure you want to unlock selected invoice(s)?';
                    } else {
                        setHistory.invoice_grid.forEachRow(function(rid){
                            var tree_level = setHistory.invoice_grid.getLevel(rid);

                            if (tree_level == 2) {
                                var invoice_type = setHistory.invoice_grid.cells(rid, setHistory.invoice_grid.getColIndexById('invoice_type')).getValue();

                                if (invoice_type != 'Netting') {
                                    var invoice_no = setHistory.invoice_grid.cells(rid, setHistory.invoice_grid.getColIndexById('invoice_number')).getValue();
                                    var calc_id = setHistory.invoice_grid.cells(rid, setHistory.invoice_grid.getColIndexById('calc_id')).getValue();

                                    if (calc_id != '') {
                                        xml += '<PSRecordSet calc_id = "' + calc_id + '" invoice_number = "' + invoice_no + '"></PSRecordSet>';
                                    }
                                }
                            }
                        })
                        var message = 'Are you sure you want to unlock all invoice(s)?';
                    }
                    xml += "</Root>";

                    if (xml != '<Root></Root>') {
                        data = {"action": "spa_settlement_history",
                            "flag": "o",
                            "xml": xml
                        };

                        adiha_post_data('confirm', data, '', '', 'setHistory.refresh_invoice_grid', '', message);
                    }

                    break;
                case "finalize":
                    var xml = "<Root>";
                    var finalized_date = today_date;
                    var finalized_invoice = new Array();
                    var netting_individual = 0;
                    var voided_invoice = 0;
                    if (selected_row != null) {
                        var selected_row_array = selected_row.split(',');

                        for(var i = 0; i < selected_row_array.length; i++) {
                            var calc_id = setHistory.invoice_grid.cells(selected_row_array[i], setHistory.invoice_grid.getColIndexById('calc_id')).getValue();
                            var invoice_number = setHistory.invoice_grid.cells(selected_row_array[i], setHistory.invoice_grid.getColIndexById('invoice_number')).getValue();
                            var netting_calc_id = setHistory.invoice_grid.cells(selected_row_array[i], setHistory.invoice_grid.getColIndexById('netting_calc_id')).getValue();
                            if (netting_calc_id != '') {
                                netting_individual = 1;
                            }

                            var finalized_status = setHistory.invoice_grid.cells(selected_row_array[i], setHistory.invoice_grid.getColIndexById('calc_status')).getValue();
                            if(finalized_status == 'Finalized') {
                                finalized_invoice.push(setHistory.invoice_grid.cells(selected_row_array[i], setHistory.invoice_grid.getColIndexById('invoice_number')).getValue());
                            } else {
                                var split_invoice_index = invoice_number.indexOf("(");
                                if (calc_id.trim() != invoice_number.trim() && split_invoice_index == -1)
                                    voided_invoice = 1;
                            }

                            if (calc_id != '') {
                                xml += '<PSRecordSet calc_id = "' + calc_id + '" finalized_date = "' + finalized_date + '"></PSRecordSet>';
                            }
                        }
                        var message = 'Are you sure you want to finalize selected invoice(s)?';
                    } else {
                        setHistory.invoice_grid.forEachRow(function(rid){
                            var tree_level = setHistory.invoice_grid.getLevel(rid);

                            if (tree_level == 2) {
                                var invoice_type = setHistory.invoice_grid.cells(rid, setHistory.invoice_grid.getColIndexById('invoice_type')).getValue();

                                if (invoice_type != 'Netting') {
                                    var calc_id = setHistory.invoice_grid.cells(rid, setHistory.invoice_grid.getColIndexById('calc_id')).getValue();
                                    var invoice_number = setHistory.invoice_grid.cells(rid, setHistory.invoice_grid.getColIndexById('invoice_number')).getValue();
                                    var netting_calc_id = setHistory.invoice_grid.cells(rid, setHistory.invoice_grid.getColIndexById('netting_calc_id')).getValue();
                                    if (netting_calc_id != '') {
                                        netting_individual = 1;
                                    }

                                    var finalized_status = setHistory.invoice_grid.cells(rid, setHistory.invoice_grid.getColIndexById('calc_status')).getValue();
                                    if(finalized_status == 'Finalized') {
                                        finalized_invoice.push(setHistory.invoice_grid.cells(rid, setHistory.invoice_grid.getColIndexById('invoice_number')).getValue());
                                    }else {
                                        var split_invoice_index = invoice_number.indexOf("(");
                                        if (calc_id.trim() != invoice_number.trim() && split_invoice_index == -1)
                                            voided_invoice = 1;
                                    }

                                    if (calc_id != '') {
                                        xml += '<PSRecordSet calc_id = "' + calc_id + '" finalized_date = "' + finalized_date + '"></PSRecordSet>';
                                    }
                                }

                            }
                        })
                        var message = 'Are you sure you want to finalize all invoice(s)?';
                    }

                    if (netting_individual == 1) {
                        show_messagebox('Please select the aggregrate invoice to finalize');
                        return;
                    }
                    if (finalized_invoice.length > 0 || voided_invoice == 1) {
                        show_messagebox('Settlement is finalized for one or more selected invoice(s). Please unfinalize first.');
                        return;
                    }

                    xml += "</Root>";
                    if (xml != '<Root></Root>') {
                        //var invoie_reporting_param = reporting_param.replace('temp_Note','invoice_docs');
                        var report_file_path_new = report_file_path.replace('temp_Note','invoice_docs');

                        data = {
							"action": "spa_finalize_invoice_job",
                            "flag": "f",
                            "xml": xml,
                            "reporting_param": '',
                            "report_file_path": report_file_path_new,
                            "report_folder": report_folder
                        };

                        dhtmlx.message({
                            type: "confirm",
                            title: "Confirmation",
                            text: message,
                            ok: "Confirm",
                            callback: function(result) {
                                if (result) {
                                    adiha_post_data('alert', data, '', '', 'setHistory.post_finalize', true, message);
                                    setHistory.set_history.progressOn();
                                }
                            }
                        });

                    }

                    break;
                case "unfinalize":
                    var report_file_path_del = '<?php echo addslashes(addslashes($ssrs_config['EXPORTED_REPORT_DIR_INITIAL']))?>'.replace('temp_Note', 'invoice_docs');

                    var xml = "<Root>";
                    var netting_individual = 0;
                    if (selected_row != null) {
                        var selected_row_array = selected_row.split(',');

                        for(var i = 0; i < selected_row_array.length; i++) {
                            var calc_id = setHistory.invoice_grid.cells(selected_row_array[i], setHistory.invoice_grid.getColIndexById('calc_id')).getValue();
                            var netting_calc_id = setHistory.invoice_grid.cells(selected_row_array[i], setHistory.invoice_grid.getColIndexById('netting_calc_id')).getValue();
                            if (netting_calc_id != '') {
                                netting_individual = 1;
                            }
                            if (calc_id != '') {
                                xml += '<PSRecordSet calc_id = "' + calc_id + '"></PSRecordSet>';
                            }
                        }
                        var message = 'Are you sure you want to unfinalize selected invoice(s)?';
                    } else {
                        setHistory.invoice_grid.forEachRow(function(rid){
                            var tree_level = setHistory.invoice_grid.getLevel(rid);

                            if (tree_level == 2) {
                                var invoice_type = setHistory.invoice_grid.cells(rid, setHistory.invoice_grid.getColIndexById('invoice_type')).getValue();

                                if (invoice_type != 'Netting') {
                                    var calc_id = setHistory.invoice_grid.cells(rid, setHistory.invoice_grid.getColIndexById('calc_id')).getValue();
                                    var netting_calc_id = setHistory.invoice_grid.cells(rid, setHistory.invoice_grid.getColIndexById('netting_calc_id')).getValue();
                                    if (netting_calc_id != '') {
                                        netting_individual = 1;
                                    }
                                    if (calc_id != '') {
                                        xml += '<PSRecordSet calc_id = "' + calc_id + '"></PSRecordSet>';
                                    }
                                }
                            }
                        })
                        var message = 'Are you sure you want to unfinalize all invoice(s)?';
                    }
                    xml += "</Root>";

                    if (netting_individual == 1) {
                        show_messagebox('Please select the aggregrate invoice to finalize');
                        return;
                    }

                    if (xml != '<Root></Root>') {
                        data = {"action": "spa_settlement_history",
                            "flag": "n",
                            "xml": xml,
                            "report_file_path": report_file_path_del
                        };

                        adiha_post_data('confirm', data, '', '', 'setHistory.refresh_invoice_grid', '', message);
                    }

                    break;
                case "delete":
                    if (selected_row != null) {
                        var calc_id_arr = new Array();
                        var selected_row_array = selected_row.split(',');
                        var xml = "<Root>";
                        var finalized_flag = 0;
                        var finalized_invoice = new Array();
                        var locked_flag = 0;
                        var locked_invoice = new Array();

                        for(var i = 0; i < selected_row_array.length; i++) {
                            var invoice_no = setHistory.invoice_grid.cells(selected_row_array[i], setHistory.invoice_grid.getColIndexById('invoice_number')).getValue();
                            var calc_id = setHistory.invoice_grid.cells(selected_row_array[i], setHistory.invoice_grid.getColIndexById('calc_id')).getValue();

                            if (setHistory.invoice_grid.cells(selected_row_array[i], setHistory.invoice_grid.getColIndexById('calc_status')).getValue() == 'Finalized') {
                                finalized_flag = 1;
                                finalized_invoice.push(setHistory.invoice_grid.cells(selected_row_array[i], setHistory.invoice_grid.getColIndexById('invoice_number')).getValue());
                            }

                            if (setHistory.invoice_grid.cells(selected_row_array[i], setHistory.invoice_grid.getColIndexById('lock_status')).getValue() == 'Locked') {
                                locked_flag = 1;
                                locked_invoice.push(setHistory.invoice_grid.cells(selected_row_array[i], setHistory.invoice_grid.getColIndexById('invoice_number')).getValue());
                            }

                            if (calc_id != '') {
                                calc_id_arr.push(calc_id);
                                xml += '<PSRecordSet calc_id = "' + calc_id + '" invoice_number = "' + invoice_no + '"></PSRecordSet>'
                            }
                        }
                        xml += "</Root>";

                        if (finalized_flag == 1) {
                            show_messagebox('Settlement is finalized for one or more selected invoice(s). Please unfinalize first.');
                            return;
                        }

                        if (locked_flag == 1) {
                            show_messagebox('Settlement is locked for one or more selected invoice(s). Please unlock first.');
                            return;
                        }

                        if (xml != '<Root></Root>') {
                            data = {"action": "spa_settlement_history",
                                "flag": "e",
                                "xml": xml
                            };
                            var data = $.param(data);

                            dhtmlx.confirm({
                                title: "Confirmation",
                                ok: "Confirm",
                                cancel: "No",
                                type: "confirm-error",
                                text: 'Are you sure you want to delete selected invoice(s)?',
                                callback: function(type) {
                                    if (type) {
                                        $.ajax({
                                            type: "POST",
                                            dataType: "json",
                                            url: js_form_process_url,
                                            async: true,
                                            data: data,
                                            success: function(data) {
                                                response_data = data["json"];
                                                if (response_data[0].errorcode == 'Success') {
                                                    setHistory.refresh_invoice_grid_after_delete("'" + calc_id_arr + "'");
                                                } else {
                                                    dhtmlx.message({
                                                        type: "alert-error",
                                                        title: "Error",
                                                        text: response_data[0].message
                                                    });
                                                }
                                            }
                                        });
                                    }
                                }
                            });

                        }
                    }

                    break;
                case "invoice_status":
                    var finalized_lock_flag = 0;
                    var up_finalized_invoice = new Array();
                    var up_locked_invoice = new Array();

                    var xml = "<Root>";
                    if (selected_row != null) {
                        var selected_row_array = selected_row.split(',');
                        for(var i = 0; i < selected_row_array.length; i++) {
                            var calc_id = setHistory.invoice_grid.cells(selected_row_array[i], setHistory.invoice_grid.getColIndexById('calc_id')).getValue();
                            var invoice_no = setHistory.invoice_grid.cells(selected_row_array[i], setHistory.invoice_grid.getColIndexById('invoice_number')).getValue();
                            var lock_status = setHistory.invoice_grid.cells(selected_row_array[i], setHistory.invoice_grid.getColIndexById('lock_status')).getValue();
                            var status = setHistory.invoice_grid.cells(selected_row_array[i], setHistory.invoice_grid.getColIndexById('calc_status')).getValue();
                            if (status == 'Finalized') {
                                finalized_lock_flag = 1;
                                up_finalized_invoice.push(invoice_no);
                            }

                            if (lock_status == 'Locked') {
                                finalized_lock_flag = 2;
                                up_locked_invoice.push(invoice_no);
                            }

                            if (calc_id != '') {
                                xml += '<PSRecordSet calc_id = "' + calc_id + '" invoice_number = "' + invoice_no + '"></PSRecordSet>'
                            }
                        }
                    } else {
                        setHistory.invoice_grid.forEachRow(function(rid){
                            var tree_level = setHistory.invoice_grid.getLevel(rid);

                            if (tree_level == 2) {
                                var invoice_type = setHistory.invoice_grid.cells(rid, setHistory.invoice_grid.getColIndexById('invoice_type')).getValue();

                                if (invoice_type != 'Netting') {
                                    var calc_id = setHistory.invoice_grid.cells(rid, setHistory.invoice_grid.getColIndexById('calc_id')).getValue();
                                    var invoice_number = setHistory.invoice_grid.cells(rid, setHistory.invoice_grid.getColIndexById('invoice_number')).getValue();
                                    var lock_status = setHistory.invoice_grid.cells(rid, setHistory.invoice_grid.getColIndexById('lock_status')).getValue();
                                    var finalized_status = setHistory.invoice_grid.cells(rid, setHistory.invoice_grid.getColIndexById('calc_status')).getValue();
                                    if(finalized_status == 'Finalized') {
                                        finalized_lock_flag = 1;
                                        up_finalized_invoice.push(invoice_number);
                                    }

                                    if (lock_status == 'Locked') {
                                        finalized_lock_flag = 2;
                                        up_locked_invoice.push(invoice_number);
                                    }

                                    if (calc_id != '') {
                                        xml += '<PSRecordSet calc_id = "' + calc_id + '" finalized_date = "' + finalized_date + '"></PSRecordSet>';
                                    }
                                }
                            }
                        })
                    }
                    xml += "</Root>";

                    /*
                     if (finalized_lock_flag == 1) {
                     show_messagebox('Settlement is finalized for one or more selected invoice(s). Please unfinalize first.');
                     return;
                     }

                     if (finalized_lock_flag == 2) {
                     show_messagebox('Settlement is locked for one or more selected invoice(s). Please unlock first.');
                     return;
                     }
                     */

                    if (xml != '<Root></Root>') {
                        unload_invoice_status_window();
                        if (!invoice_status_window) {
                            invoice_status_window = new dhtmlXWindows();
                        }

                        win = invoice_status_window.createWindow('w1', 0, 0, 350, 250);
                        win.setText("Workflow Status");
                        win.centerOnScreen();
                        win.setModal(true);

                        var xml_json = {"xml":xml};
                        win.attachURL("update.invoice.status.php", null, xml_json);
                        win.attachEvent("onClose", function(win){
                            setHistory.refresh_invoice_grid();
                            return true;
                        });
                    }
                    break;

            }
        } else {
            close_accounting_period = result[0][1];
            show_messagebox("Accounting Period has already been closed for invoices with following id " + close_accounting_period.substring(0, close_accounting_period.length-1));
        }
    }
    
    setHistory.menu_click = function(id, zoneId, cas) {
      
        var selected_row = setHistory.invoice_grid.getSelectedRowId();
        undock_status = undock_state;
        switch(id) {
            case "refresh":
                setHistory.refresh_invoice_grid();
                break;
            case "expand_collapse":
                if (expand_state == 0) 
                    openAllInvoices();
                else
                    closeAllInvoices();
                break;
            case "lock":
            case "unlock":
            case "finalize":
            case "unfinalize":
            case "invoice_status":
            case "delete":
                check_close_accounting_period(id);
                break;
            case "audit":
                var selected_row_array = selected_row.split(',');
                var calc_id = '';
                for(var i = 0; i < selected_row_array.length; i++) {
                    if (i == 0) {
                        var calc_id = setHistory.invoice_grid.cells(selected_row_array[i], setHistory.invoice_grid.getColIndexById('calc_id')).getValue();
                    } else {
                        calc_id += ',' + setHistory.invoice_grid.cells(selected_row_array[i], setHistory.invoice_grid.getColIndexById('calc_id')).getValue();    
                    }
                }
                
                call_audit_report(calc_id);
                break;
            case "pdf":
                setHistory.invoice_grid.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                break;
            case "excel":
                setHistory.invoice_grid.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                break;
            case "invoice_html":
				var selected_row_array = selected_row.split(',');
                var calc_id = '';
                for(var i = 0; i < selected_row_array.length; i++) {
                    var calc_id = setHistory.invoice_grid.cells(selected_row_array[i], setHistory.invoice_grid.getColIndexById('calc_id')).getValue();
                    generate_invoice(calc_id);
                }
                break;
            case "invoice_pdf":
                invoice_export_click("PDF", "invoice", runtime_user);
                break;
            case "invoice_excel":
                invoice_export_click("EXCEL", "invoice");
                break;
            case "invoice_send":
                invoice_send("invoice");
                break; 
			case "pivot":
				invoice_grid_pivot();
				break;
            default:
                dhtmlx.alert({
                    title:'Error',
                    type:"alert-error",
                    text:"Under Maintainence! We will be back soon!"
                });
                break;
        }
    }
    
    setHistory.post_finalize = function(result) {
		
		var return_array = result;	//JSON.parse(result);
		console.log(return_array);
        if (return_array[0].errorcode == 'Success') {
			dhtmlx.message({
                    title:'Success',
                    type:"alert",
                    text:return_array[0].message
                });
            //setHistory.refresh_invoice_grid();
		} else {
			dhtmlx.message({
                    title:'Error',
                    type:"alert-error",
                    text:return_array[0].message
                });
		} 
		setHistory.set_history.progressOff();
    }
    /**
    * [insert_invoice Open window to insert the invoice]
    * @param row_id    Context menu clicked row id
    */
    function insert_invoice(row_id) {
        var js_path = '<?php echo $app_php_script_loc; ?>';
        var js_path_trm = '<?php echo $app_adiha_loc; ?>';
        
        counterparty_invoice_window = new dhtmlXWindows();
        var counterparty_id = setHistory.invoice_grid.cells(row_id, setHistory.invoice_grid.getColIndexById('counterparty_id')).getValue();
        var contract_id = setHistory.invoice_grid.cells(row_id, setHistory.invoice_grid.getColIndexById('contract_id')).getValue();
        var as_of_date = setHistory.invoice_grid.cells(row_id, setHistory.invoice_grid.getColIndexById('as_of_date')).getValue();
        as_of_date = dates.convert_to_sql(as_of_date);
        var prod_date = setHistory.invoice_grid.cells(row_id, setHistory.invoice_grid.getColIndexById('date_from')).getValue(); 
        prod_date = dates.convert_to_sql(prod_date);
        var inv_rec_id = setHistory.invoice_grid.cells(row_id, setHistory.invoice_grid.getColIndexById('inv_ref_id')).getValue();
        var invoice_type = setHistory.invoice_grid.cells(row_id, setHistory.invoice_grid.getColIndexById('invoice_type')).getValue();
            
        
        var src = js_path_trm + 'adiha.html.forms/_settlement_billing/maintain_invoice/counterparty.invoice.php?counterparty_id=' + counterparty_id + '&contract_id=' + contract_id + '&as_of_date=' + as_of_date + '&prod_date=' + prod_date + '&processed=true' + '&inv_rec_id=' + inv_rec_id +'&invoice_type=' + invoice_type; 
        counterparty_invoice_obj = counterparty_invoice_window.createWindow('w1', 0, 0, 900, 600);
        counterparty_invoice_obj.setText("Counterparty Invoice");
        
        counterparty_invoice_obj.centerOnScreen();
        counterparty_invoice_obj.setModal(true);
        counterparty_invoice_obj.attachURL(src, false, true);
    }
    
    var invoice_export_window;
    /**
     * [unload_invoice_export_window Unload invoice export window.]
     */
    function unload_invoice_export_window() {        
        if (invoice_export_window != null && invoice_export_window.unload != null) {
            invoice_export_window.unload();
            invoice_export_window = w1 = null;
        }
    }


    /**
     * [call_export_invoice Opens up window for exporting invoice.]
     * @param  {[str]} url        [url]
     */
    window_invoice = null;
    function call_export_invoice(url) {
      
        unload_invoice_export_window();
        if (!invoice_export_window) {
            invoice_export_window = new dhtmlXWindows();
        }

        window_invoice = invoice_export_window.createWindow('w1', 0, 0, 800, 600);
        window_invoice.progressOn();
        window_invoice.setText("Invoice Preview");
        window_invoice.centerOnScreen();
        window_invoice.setModal(true);
        window_invoice.attachURL(url, false, true);
                
    }
	
	function window_download(url) {
		location.href = url;
		window_invoice.close();
	}
    
    function invoice_export_click($type, grid, runtime_user) {
        invoice_export($type, grid, runtime_user);
    }

    function invoice_export(export_type, grid, runtime_user) {
       
        var invoice_ids = "";
		var netting_status = 1;
        var inv_chk = 0;
		var v_invoice = 0;
		var hv_invoice = 0;
		var is_word = 0;
        var is_excel = 0;

        var selected_row = setHistory.invoice_grid.getSelectedRowId();

        if (grid == 'invoice') {
            var selected_row = setHistory.invoice_grid.getSelectedRowId();
            
            if (selected_row != null) {
                var selected_row_array = selected_row.split(',');
				var pre_inv = '';

                for(var i = 0; i < selected_row_array.length; i++) {
					var tree_level = setHistory.invoice_grid.getLevel(selected_row_array[i]);
					
					if (tree_level == 2) {
						var invoice_no = setHistory.invoice_grid.cells(selected_row_array[i], setHistory.invoice_grid.getColIndexById('calc_id')).getValue();
						var invoice_number = setHistory.invoice_grid.cells(selected_row_array[i], setHistory.invoice_grid.getColIndexById('invoice_number')).getValue();
                        var document_type = setHistory.invoice_grid.cells(selected_row_array[i], setHistory.invoice_grid.getColIndexById('document_type')).getValue();
                        //runtime_user = runtime_user
                          
                        if(document_type =='w'){
                            is_word = 1;
                        }

                        if(document_type =='e'){
                            is_excel = 1;
                        }

						var fin_est = setHistory.invoice_grid.cells(selected_row_array[i], setHistory.invoice_grid.getColIndexById('calc_status')).getValue();
						if (fin_est == 'Voided') {
							fin_est = 'Finalized';
						}
						
						var split_invoice_index = invoice_number.indexOf("(");
						if (fin_est == 'Estimate' && invoice_no.trim() != invoice_number.trim() && split_invoice_index == -1) 
							v_invoice = 1;
						
						if (fin_est == '') {
							var invoice_file_name = setHistory.invoice_grid.cells(selected_row_array[i], setHistory.invoice_grid.getColIndexById('invoice_file_name')).getValue();
							if (invoice_file_name == '') {
								netting_status = 0;
							}
							fin_est = 'Netting';
						}
						invoice_no_arr = invoice_no.split('(');
						invoice_no = invoice_no_arr[0];
						if (i == 0) {
							invoice_ids = invoice_no;
						} else {
							invoice_ids += ',' + invoice_no;
							
							if (pre_inv != fin_est) {
								inv_chk = 1;
							}
						}
						pre_inv = fin_est;
					}
                }
            } else {
                show_messagebox('Please select an invoice.');
                return;
            }
        } else {
            var selected_row = invoiceDetails.grid["history_a_" + grid].getSelectedRowId();
            if (selected_row != null) {
                var selected_row_array = selected_row.split(',');
				var pre_inv = '';

                for(var i = 0; i < selected_row_array.length; i++) {
					var invoice_no = invoiceDetails.grid["history_a_" + grid].cells(selected_row_array[i], 1).getValue();
					var fin_est = invoiceDetails.grid["history_a_" + grid].cells(selected_row_array[i], 8).getValue();
					if (fin_est == 'Voided') {
						fin_est = 'Finalized';
					}
						
					invoice_no_arr = invoice_no.split('(');
					invoice_no = invoice_no_arr[0];
					if (i == 0) {
						invoice_ids = invoice_no;
					} else {
						invoice_ids += ',' + invoice_no;
						
						if (pre_inv != fin_est) {
							inv_chk = 1;
						}
					} 
					pre_inv = fin_est;
				}
            }
        }
		
		// For finalized and voided invoice, only use pdf export.
		if (inv_chk == 1) {
			show_messagebox('Please select the invoices having the same accounting status.');
			return;
		}
		
		if ((export_type == 'HTML4.0' || export_type == 'EXCEL') && (pre_inv == 'Finalized' || pre_inv == 'Voided') && v_invoice == 0 ) {
			var my_url = "<?php echo $rfx_js_url_call; ?>";
		
			my_url = my_url.replace(/&invoice_ids=NULL/, "&invoice_ids=" + invoice_ids);
			my_url = my_url.replace(/&export_type=NULL/, "&export_type=" + export_type);
            my_url = my_url.replace(/&runtime_user=NULL/, "&runtime_user=" + runtime_user);
            if(is_excel == 1) {
                my_url = my_url.replace(/&is_excel=NULL/, "&is_excel=" + is_excel);
            } else {
                my_url = my_url.replace(/&is_excel=NULL/, "&is_excel=" + is_excel);
            }
			call_export_invoice(my_url);
			return;
		}
		
		if ((export_type == 'HTML4.0' || export_type == 'EXCEL') && (pre_inv == 'Estimate') && v_invoice == 1 &&  is_excel == 0) {
			var my_url = "<?php echo $rfx_js_url_call; ?>";
		
			my_url = my_url.replace(/&invoice_ids=NULL/, "&invoice_ids=" + invoice_ids);
			my_url = my_url.replace(/&export_type=NULL/, "&export_type=" + export_type);
            my_url = my_url.replace(/&runtime_user=NULL/, "&runtime_user=" + runtime_user);

            if(is_excel == 1) {
                my_url = my_url.replace(/&is_excel=NULL/, "&is_excel=" + is_excel);
            } else {
                my_url = my_url.replace(/&is_excel=NULL/, "&is_excel=" + 0);
            }

			call_export_invoice(my_url);
			return;
		}
		
		if ((export_type == 'HTML4.0' || export_type == 'EXCEL') && pre_inv == 'Netting' && netting_status == 1) {
			show_messagebox('Please use pdf export for the this netting invoice.');
			return;
		}
		
		// Show the invoice from the folder for the finalized and voided invoice
		var invoice_file_arr = new Array();	
		if (((pre_inv == 'Finalized' || pre_inv == 'Voided' || pre_inv == 'Netting') && grid == 'invoice' && netting_status == 1) || v_invoice == 1) {
			var selected_row = setHistory.invoice_grid.getSelectedRowId();
			var selected_row_array = selected_row.split(',');
			
			for(var i = 0; i < selected_row_array.length; i++) {
				var tree_level = setHistory.invoice_grid.getLevel(selected_row_array[i]);
				if (tree_level == 2) {
					var invoice_file_name = setHistory.invoice_grid.cells(selected_row_array[i], setHistory.invoice_grid.getColIndexById('invoice_file_name')).getValue();
					if (invoice_file_name == '') {
						invoice_file_arr.push(setHistory.invoice_grid.cells(selected_row_array[i], setHistory.invoice_grid.getColIndexById('invoice_number')).getValue());
					}
				}
			}
			
			if (invoice_file_arr.length > 0) {
				show_messagebox('Invoice pdf file is missing for selected invoice(s).');
				return;
			}
			
			for(var i = 0; i < selected_row_array.length; i++) {
				var tree_level = setHistory.invoice_grid.getLevel(selected_row_array[i]);
				
				if (tree_level == 2) {
					var invoice_file_name = setHistory.invoice_grid.cells(selected_row_array[i], setHistory.invoice_grid.getColIndexById('invoice_file_name')).getValue();
					var my_url = php_script_loc + 'dev/shared_docs/invoice_docs/' + invoice_file_name;
					window.open(my_url, '_blank');
				}
			}
		} else if ((pre_inv == 'Finalized' || pre_inv == 'Voided') && netting_status == 1)  {
			var selected_row = invoiceDetails.grid["history_a_" + grid].getSelectedRowId();
			var selected_row_array = selected_row.split(',');
			
			for(var i = 0; i < selected_row_array.length; i++) {
				var invoice_file_name = invoiceDetails.grid["history_a_" + grid].cells(selected_row_array[i], 12).getValue();
				if (invoice_file_name == '') {
					invoice_file_arr.push(setHistory.invoice_grid.cells(selected_row_array[i], 1).getValue());
				}
			}
			
			if (invoice_file_arr.length > 0) {
				show_messagebox('Invoice pdf file is missing for selected invoice(s).');
				return;
			}
			
			for(var i = 0; i < selected_row_array.length; i++) {
				var invoice_file_name = invoiceDetails.grid["history_a_" + grid].cells(selected_row_array[i], 12).getValue();
				var my_url = php_script_loc + 'dev/shared_docs/invoice_docs/' + invoice_file_name + '.pdf';
				window.open(my_url, '_blank');
			}
		} else {

                if(is_word == 0){
				
                    var my_url = "<?php echo $rfx_js_url_call; ?>";
                    if (!invoice_ids) {
                        show_messagebox("Please select an Invoice.");
                        return;
                    }
                   
                    my_url = my_url.replace(/&invoice_ids=NULL/, "&invoice_ids=" + invoice_ids);
                    my_url = my_url.replace(/&export_type=NULL/, "&export_type=" + export_type);
                    my_url = my_url.replace(/&runtime_user=NULL/,"&runtime_user=" + runtime_user);

                    if(is_excel == 1) {
                        my_url = my_url.replace(/&is_excel=NULL/, "&is_excel=" + is_excel);
                    } else {
                        my_url = my_url.replace(/&is_excel=NULL/, "&is_excel=" + 0);
                    }

                    call_export_invoice(my_url);
                }
                else{
                     var selected_row = setHistory.invoice_grid.getSelectedRowId();
                    var selected_row_array = selected_row.split(',');
                    for(var i = 0; i < selected_row_array.length; i++) {
                        var invoice_no = setHistory.invoice_grid.cells(selected_row_array[i], setHistory.invoice_grid.getColIndexById('calc_id')).getValue();
                        generate_document_for_view(invoice_no, '38', '', 'confirmation_report_callback');
                        setTimeout(function() {
          //your code to be executed after 1 second
                    }, 3000);
    
                    }   
                }
		
    }
}
  confirmation_report_callback = function(status, file_path) {
           dhtmlx.alert({
                    title:"Alert",
                    type:"alert",
                    text:status
                });
    }  
    function invoice_send(grid) {
        var invoice_ids = '';
		var inv_chk = 0;
		
        //var invoice_status_flag = 0;
        if (grid == 'invoice') {   
            var selected_row = setHistory.invoice_grid.getSelectedRowId();
            if (selected_row != null) {
                var selected_row_array = selected_row.split(',');
				var pre_inv = '';
				
                for(var i = 0; i < selected_row_array.length; i++) {
                    /*
                    if(setHistory.invoice_grid.cells(selected_row_array[i], setHistory.invoice_grid.getColIndexById('invoice_status')).getValue() != 'Ready to send') {
                        invoice_status_flag = 1;
                    }
                    */
					var fin_est = setHistory.invoice_grid.cells(selected_row_array[i], setHistory.invoice_grid.getColIndexById('calc_status')).getValue();
					if (fin_est == 'Voided') {
						fin_est = 'Finalized';
					}
                    if (i == 0) {
                        invoice_ids = setHistory.invoice_grid.cells(selected_row_array[i], setHistory.invoice_grid.getColIndexById('calc_id')).getValue();
                    } else {
                        invoice_ids += ',' + setHistory.invoice_grid.cells(selected_row_array[i], setHistory.invoice_grid.getColIndexById('calc_id')).getValue();    
						
						if (pre_inv != fin_est) {
							inv_chk = 1;
						}
                    }
					pre_inv = fin_est;
                }
            }
        } else {
            var selected_row = invoiceDetails.grid["history_a_" + grid].getSelectedRowId();
            if (selected_row != null) {
                var selected_row_array = selected_row.split(',');
				var pre_inv = '';
				
                for(var i = 0; i < selected_row_array.length; i++) {
                    var invoice_no = invoiceDetails.grid["history_a_" + grid].cells(selected_row_array[i], 0).getValue();
					var fin_est = invoiceDetails.grid["history_a_" + grid].cells(selected_row_array[i], 8).getValue();
					if (fin_est == 'Voided') {
						fin_est = 'Finalized';
					}
					if (i == 0) {
                        invoice_ids = invoice_no;
                    } else {
                        invoice_ids += ',' + invoice_no;
						
						if (pre_inv != fin_est) {
							inv_chk = 1;
						}
                    } 
					pre_inv = fin_est;
                }
            }
        }
        
		if (inv_chk == 1) {
			show_messagebox('Please select the invoices having the same accounting status.');
			return;
		}
		
        var table_name = 'adiha_process.dbo.print_invoices_paging';
        var user_name = getAppUserName();
        var user_name_array = user_name.split("=");
        user_name = user_name_array[1];

        var title = "Send Invoice";
        //var as_of_date = setHistory.invoice_grid.cells(selected_row, 21).getValue();
        // alert(invoice_ids);
        if (invoice_ids == 'NULL' || invoice_ids == null || invoice_ids == '') {
            var send_all_invoice = 'Do you want to send all invoices/remittance?';
            dhtmlx.confirm({
                title: "Confirmation",
                ok: "Confirm",
                cancel: "Cancel",
                type: "confirm-error",
                text: send_all_invoice,
                callback: function(type) {
					if (type) {
						var inv_id_arr = new Array();
                        if (grid == 'invoice') {
    						setHistory.invoice_grid.forEachRow(function(rid){
    							var tree_level = setHistory.invoice_grid.getLevel(rid);
    							if (tree_level == 2) {
    								var inv_id = setHistory.invoice_grid.cells(rid, setHistory.invoice_grid.getColIndexById('calc_id')).getValue();
    								inv_id_arr.push(inv_id);
    							}
    						})
                        } else {
                            invoiceDetails.grid["history_a_" + grid].forEachRow(function(rid){
                                var inv_id = invoiceDetails.grid["history_a_" + grid].cells(rid, 1).getValue();
                                inv_id_arr.push(inv_id);
                            })
                        }

                        var inv_id_str = inv_id_arr.toString();
						
						var param = 'source=Settlement_Process&gen_as_of_date=1&batch_type=v&call_from=invoice'
									+ '&report_file_path=' + report_file_path
									+ '&report_folder=' + report_folder
						var exec_call = "invoice_ids=" + inv_id_str;
						adiha_run_batch_process(exec_call, param, title);
					}
				}
			});
        } else {
            var param = "source=Settlement_Process&gen_as_of_date=1&batch_type=v&call_from=invoice" +                        
                        "&invoice_ids=" + invoice_ids +
                        "&report_file_path=" + report_file_path + 
                        "&report_folder=" + report_folder;
            var exec_call = "";
            adiha_run_batch_process(exec_call, param, title);
        }
    }
    
    function construct_report_export_cmd(output_file, report_path) {
        // output_file = '\\\\' + output_file;
        // var cmd_call = '<?php
        //                 $report_export_cmd  = "rs";
        //                 $report_export_cmd .= " -e Exec2005";
        //                 $report_export_cmd .= " -l " . $ssrs_config['RS_TIMEOUT'];
        //                 $report_export_cmd .= " -s " . $ssrs_config['SERVICE_URL'];
        //                 $report_export_cmd .= ' -i "' . addslashes(addslashes($ssrs_config['REPORT_EXPORTER_PATH_CUSTOM'])) . '"';
        //                 $report_export_cmd .= ' -v vFullPathOfOutputFile="' . addslashes(addslashes($ssrs_config['EXPORTED_REPORT_DIR_INITIAL'])) . '' . "' + output_file + '" .'.pdf"';
        //                 $report_export_cmd .= ' -v vReportPath="' . $ssrs_config['REPORT_TARGET_FOLDER'] . '/custom_reports/' . "' + report_path + '" .'"';
        //                 $report_export_cmd .= ' -v vFormat="PDF"';
        //                 $report_export_cmd .= ' -v vReportFilter=' ;

        //                 echo $report_export_cmd;
        //                 ?>';
        //     return cmd_call;
    }
    
    /**
     * [undock_window Function for undocking invoice grid]
     */
    function undock_window() {
        setHistory.set_history.cells('c').undock(300, 300, 900, 700);
        setHistory.set_history.dhxWins.window('c').maximize();
        setHistory.set_history.dhxWins.window("c").button("park").hide();
    }
    
    /**
     * [undock_detail_window Function for undocking detail grid]
     */
    function undock_detail_window(calc_id) {
        invoiceDetails.layout["invoice_"+calc_id].cells('b').undock(300, 300, 900, 700);
        invoiceDetails.layout["invoice_"+calc_id].dhxWins.window('b').maximize();
        invoiceDetails.layout["invoice_"+calc_id].dhxWins.window("b").button("park").hide();
    }
    
    function open_gl_entries() {
        unload_gl_entries_window();
        if (!gl_entries_window) {
            gl_entries_window = new dhtmlXWindows();
        }

        var new_win = gl_entries_window.createWindow('w1', 0, 0, 800, 600);
        new_win.setText("Export GL Entries");
        new_win.centerOnScreen();
        new_win.setModal(true);
        new_win.maximize();
        
        var selected_row = setHistory.invoice_grid.getSelectedRowId();
        var calc_id = setHistory.invoice_grid.cells(selected_row, setHistory.invoice_grid.getColIndexById('calc_id')).getValue();
        
        var url = app_form_path  + "_settlement_billing/sap_export/sap_export.php?calc_id=" + calc_id;
           
        new_win.attachURL(url, false, true);
    }
    
    function alert_hyperlink(report_name, exec_call, height, width) {
        dhtmlx.modalbox.hide(box);
        open_spa_html_window(report_name, exec_call, height, width);
    }
    
    function maximize_window() {
        win.maximize();
    }
	
	invoice_grid_pivot = function() {
		var grid_obj = setHistory.invoice_grid;
		open_grid_pivot(grid_obj, 'invoice_grid', 3, pivot_exec_invoice, 'Invoice');
	}
	
	generate_invoice = function(calc_id) {
		generate_document_for_view(calc_id, '38', '42031', '');
	}
</script>