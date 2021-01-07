<?php
/**
* Stmt invoice screen
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
<body>
<?php
    $invoice_id = get_sanitized_value($_GET['invoice_id'] ?? '');

    $settlement_invoice_function_id = 20012200;
    $settlement_invoice_add_function_id = 20012201;
    $settlement_invoice_delete_function_id = 20012202;
    $settlement_invoice_counterparty_invoice_function_id = 20012203;
    $settlement_invoice_workflow_status_function_id = 20012204;
    $settlement_invoice_finalize_function_id = 20012205;
    $settlement_invoice_void_function_id = 20012206;
    $settlement_invoice_export_invoice_function_id = 20012207;
 
    list (
        $has_right_settlement_invoice_add_function_id,
        $has_right_settlement_invoice_delete_function_id,
        $has_right_settlement_invoice_counterparty_invoice_function_id,
        $has_right_settlement_invoice_workflow_status_function_id,
        $has_right_settlement_invoice_finalize_function_id,
        $has_right_settlement_invoice_void_function_id,
        $has_right_settlement_invoice_export_invoice_function_id
        ) = build_security_rights (
        $settlement_invoice_add_function_id,
        $settlement_invoice_delete_function_id,
        $settlement_invoice_counterparty_invoice_function_id,
        $settlement_invoice_workflow_status_function_id,
        $settlement_invoice_finalize_function_id,
        $settlement_invoice_void_function_id,
        $settlement_invoice_export_invoice_function_id
    );

    $form_namespace = 'SettlementInvoice';
    $form_obj = new AdihaStandardForm($form_namespace, 20012200); 
    $form_obj->define_grid("SettlementInvoice", "", "t");
    $form_obj->define_layout_width(500);
    $form_obj->define_apply_filters(true, '20012201', 'SettlementInvoiceFilter', 'Filters');
    $form_obj->define_custom_functions('save_function', '', '', 'form_load_complete_function', '', '');
    echo $form_obj->init_form('Settlement Invoice', 'Settlement Invoice', $invoice_id); 
    echo $form_obj->close_form();
?>
</body>
<script type="text/javascript">
    var category_id = 10000283;
    var has_right_settlement_invoice_add_function_id = <?php echo (($has_right_settlement_invoice_add_function_id) ? $has_right_settlement_invoice_add_function_id : '0'); ?>;
    var has_right_settlement_invoice_delete_function_id = <?php echo (($has_right_settlement_invoice_delete_function_id) ? $has_right_settlement_invoice_delete_function_id : '0'); ?>;
	var has_right_settlement_invoice_counterparty_invoice_function_id = <?php echo (($has_right_settlement_invoice_counterparty_invoice_function_id) ? $has_right_settlement_invoice_counterparty_invoice_function_id : '0'); ?>;
	var has_right_settlement_invoice_workflow_status_function_id = <?php echo (($has_right_settlement_invoice_workflow_status_function_id) ? $has_right_settlement_invoice_workflow_status_function_id : '0'); ?>;
	var has_right_settlement_invoice_finalize_function_id = <?php echo (($has_right_settlement_invoice_finalize_function_id) ? $has_right_settlement_invoice_finalize_function_id : '0'); ?>;
	var has_right_settlement_invoice_void_function_id = <?php echo (($has_right_settlement_invoice_void_function_id) ? $has_right_settlement_invoice_void_function_id : '0'); ?>;
	var has_right_settlement_invoice_export_invoice_function_id = <?php echo (($has_right_settlement_invoice_export_invoice_function_id) ? $has_right_settlement_invoice_export_invoice_function_id : '0'); ?>;
	
    var invoice_context_menu;
    var client_date_format = '<?php echo $date_format; ?>';

    var runtime_user = getAppUserName();
    var runtime_user_array = runtime_user.split("=");
    runtime_user = runtime_user_array[1];

    $(function () {  
        var invoice_id = '<?php echo $invoice_id; ?>';
 
        SettlementInvoice.layout.cells("b").expand(); 

        SettlementInvoice.menu.removeItem('add');

        SettlementInvoice.menu.addNewSibling('t2', "invoice", 'Invoice', false, "export.gif", "export_dis.gif");
        SettlementInvoice.menu.addNewChild('invoice', 0, "generate_invoice", 'Generate Invoice', true, "html.gif", "html_dis.gif");
        SettlementInvoice.menu.addNewChild('invoice',1, "settlement_invoice_send", 'Send Invoice', true, "batch.gif", "batch_dis.gif");

		// if (!has_right_settlement_invoice_export_invoice_function_id)
		// 	SettlementInvoice.menu.setItemDisabled('generate_invoice');

        SettlementInvoice.menu.attachEvent("onClick", function(id, zoneId, cas){  
            switch(id) {
                 case "generate_invoice":
                    SettlementInvoice.layout.cells('c').progressOn();
                    var selected_row = SettlementInvoice.grid.getSelectedRowId();
                    var selected_row_array = selected_row.split(',');
                    for(var i = 0; i < selected_row_array.length; i++) {
                        var stmt_invoice_id = SettlementInvoice.grid.cells(selected_row_array[i], SettlementInvoice.grid.getColIndexById('invoice_id')).getValue();
                        generate_invoice(stmt_invoice_id);
                    }
                    break;
                 case "settlement_invoice_send":
                    var selected_row = SettlementInvoice.grid.getSelectedRowId();
                    var selected_row_array = selected_row.split(',');
                    for(var i = 0; i < selected_row_array.length; i++) {
                        var stmt_invoice_id = SettlementInvoice.grid.cells(selected_row_array[i], SettlementInvoice.grid.getColIndexById('invoice_id')).getValue();
                        settlement_invoice_send(stmt_invoice_id);
                    }
                    break;
                 default:
                    break;
            }
        });

        var delivery_date = new Date();
        var delivery_month_from = new Date(delivery_date.getFullYear(), delivery_date.getMonth() -1 , 1);
        var delivery_month_to = new Date(delivery_date.getFullYear(), delivery_date.getMonth(), 0);
        
        if (!invoice_id) {
            SettlementInvoice.filter_form.setItemValue('prod_date_from', delivery_month_from);
            SettlementInvoice.filter_form.setItemValue('prod_date_to', delivery_month_to);
        }
        
        SettlementInvoice.filter_form.attachEvent("onChange", function(name,value,is_checked){
            if (name == 'settlement_date_from' || name == 'prod_date_from' || name == 'payment_date_from') {
                var date_from = SettlementInvoice.filter_form.getItemValue(name, true);
                var split = date_from.split('-');
                var year =  +split[0];
                var month = +split[1];
                var day = +split[2];

                var date = new Date(year, month-1, day);
                var lastDay = new Date(date.getFullYear(), date.getMonth() + 1, 0);
                date_end = formatDate(lastDay);
                
                var to_name = name.replace("from", "to");
                SettlementInvoice.filter_form.setItemValue(to_name, date_end);
            } 
        });

        cmb_counterparty_obj = SettlementInvoice.filter_form.getCombo("counterparty_id");
        cmb_counterparty_obj.attachEvent("onCheck", load_contract_dropdown);
        cmb_counterparty_obj.setComboText('');
        cmb_contract_obj = SettlementInvoice.filter_form.getCombo("contract_id");
        cmb_contract_obj.setComboText('');

        cmb_counterparty_type_obj = SettlementInvoice.filter_form.getCombo("counterparty_type");
        cmb_counterparty_type_obj.attachEvent("onChange", load_counterparty_dropdown);
        load_contract_dropdown();

        load_context_menu();
        load_workflow_status();

        if(invoice_id) {
            SettlementInvoice.filter_form.setItemValue("invoice_number",invoice_id);
            SettlementInvoice.refresh_grid(); 
          SettlementInvoice.create_tab('tab_' + invoice_id, '','','','','',true);  
        }
    }); 

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
        var cmb_contract_obj = SettlementInvoice.filter_form.getCombo('contract_id');
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
        var cmb_contract_obj = SettlementInvoice.filter_form.getCombo('counterparty_id');
        cmb_contract_obj.clearAll();
        cmb_contract_obj.setComboText('');
        cmb_contract_obj.load(url); 
    }

    SettlementInvoice.refresh_grid = function(sp_url, callback_function, filter_param) {
        SettlementInvoice.layout.cells('b').collapse();
        SettlementInvoice.layout.cells('c').progressOn();

        SettlementInvoice.menu.setItemDisabled('audit');
        SettlementInvoice.menu.setItemDisabled('finalize_status');
        SettlementInvoice.menu.setItemDisabled('workflow_status');
        SettlementInvoice.menu.setItemDisabled('void_status');
        SettlementInvoice.menu.setItemDisabled('unfinalize_status');
        SettlementInvoice.menu.setItemDisabled('paid');
        SettlementInvoice.menu.setItemDisabled('unpaid');
        SettlementInvoice.menu.setItemDisabled('lock');
        SettlementInvoice.menu.setItemDisabled('unlock');
        SettlementInvoice.menu.setItemDisabled('generate_invoice');
        SettlementInvoice.menu.setItemDisabled('settlement_invoice_send');
        SettlementInvoice.menu.setItemDisabled('delete');
        SettlementInvoice.menu.setItemDisabled('payment_status');

        var delivery_date_from  = SettlementInvoice.filter_form.getItemValue('prod_date_from',true);
        var delivery_date_to  = SettlementInvoice.filter_form.getItemValue('prod_date_to',true);
        var settlement_date_from  = SettlementInvoice.filter_form.getItemValue('settlement_date_from',true);
        var settlement_date_to  = SettlementInvoice.filter_form.getItemValue('settlement_date_to',true);
        var payment_date_from  = SettlementInvoice.filter_form.getItemValue('payment_date_from',true);
        var payment_date_to  = SettlementInvoice.filter_form.getItemValue('payment_date_to',true);
        var counterparty_type  = SettlementInvoice.filter_form.getItemValue('counterparty_type',true);
        // var counterparty_id  = SettlementInvoice.filter_form.getItemValue('counterparty_id',true);
        // var contract_id  = SettlementInvoice.filter_form.getItemValue('contract_id',true);

        var invoice_type_combo_obj  = SettlementInvoice.filter_form.getCombo('invoice_type');
        invoice_type = invoice_type_combo_obj.getChecked().toString();

        var invoice_id  = SettlementInvoice.filter_form.getItemValue('invoice_id',true);
        var show_backing_sheets  = SettlementInvoice.filter_form.isItemChecked('individual_invoice');
		if (show_backing_sheets == true) { show_backing_sheets = 'y'} else {show_backing_sheets = 'n'}
		var commodity_id  = SettlementInvoice.filter_form.getItemValue('commodity',true);
        var invoice_status  = SettlementInvoice.filter_form.getItemValue('invoice_status',true);
        var acc_status  = SettlementInvoice.filter_form.getItemValue('is_finalized',true);
        var loc_status  = SettlementInvoice.filter_form.getItemValue('is_locked',true);
        var is_voided  = SettlementInvoice.filter_form.getItemValue('is_voided',true); 
        var accounting_month = SettlementInvoice.filter_form.getItemValue('accounting_month',true);
        var pay_status  = SettlementInvoice.filter_form.getItemValue('payment_status',true);  
        var invoice_number  = SettlementInvoice.filter_form.getItemValue('invoice_number',true); 
        
        var counterparty_combo_obj = SettlementInvoice.filter_form.getCombo('counterparty_id');
        counterparty_id = counterparty_combo_obj.getChecked().toString();

        var contract_combo_obj = SettlementInvoice.filter_form.getCombo('contract_id');
        contract_id = contract_combo_obj.getChecked().toString();

        var counterparty_entity_type_combo_obj = SettlementInvoice.filter_form.getCombo('counterparty_entity_type');
        var counterparty_entity_type = counterparty_entity_type_combo_obj.getChecked().toString();

        var contract_category_combo_obj = SettlementInvoice.filter_form.getCombo('contract_category');
        var contract_category = contract_category_combo_obj.getChecked().toString();

        if (delivery_date_to != '' && delivery_date_from != '' && delivery_date_from > delivery_date_to) {
                show_messagebox('<strong>Delivery Date To </strong> should be greater than <strong> Delivery Date From.</strong>');
                SettlementInvoice.layout.cells('c').progressOff();
                return;                 
        }

        if (settlement_date_to != '' && settlement_date_from != '' && settlement_date_from > settlement_date_to) {
                show_messagebox('<strong>Settlement Date To </strong> should be greater than <strong> Settlement Date From.</strong>');
                SettlementInvoice.layout.cells('c').progressOff();
                return;
        }

        if (payment_date_to != '' && payment_date_from != '' && payment_date_from > payment_date_to) {
                show_messagebox('<strong> Payment Date To </strong> should be greater than <strong>Payment Date From.</strong>');
                SettlementInvoice.layout.cells('c').progressOff();
                return;                 
        }

        var sql = {
            "action"                : "spa_stmt_invoice",
            "flag"                  : "s",            
            "delivery_date_from"    : (delivery_date_from)?delivery_date_from:null,
            "delivery_date_to"      : (delivery_date_to)?delivery_date_to:null,
            "settlement_date_from"  : (settlement_date_from)?settlement_date_from:null,
            "settlement_date_to"    : (settlement_date_to)?settlement_date_to:null,
            "payment_date_from"     : (payment_date_from)?payment_date_from:null,
            "payment_date_to"       : (payment_date_to)?payment_date_to:null,
            "counterparty_type"     : counterparty_type,
            "counterparty_id"       : counterparty_id,
            "contract_id"           : contract_id,
            "invoice_type"          : invoice_type,
            "invoice_id"            : invoice_id,
            "show_backing_sheets"   : show_backing_sheets,
            "commodity_id"          : commodity_id,
            "invoice_status"        : invoice_status,
            "acc_status"            : acc_status,
            "loc_status"            : loc_status,
            "is_voided"             : is_voided,
            "accounting_month"		: (accounting_month)?accounting_month:null,
            "pay_status"            : pay_status,
            "invoice_number"        : invoice_number,
            "counterparty_entity_type" : counterparty_entity_type,
            "contract_category" : contract_category,
            "grid_type"             :"tg",
            "grouping_column"       :"counterparty,contract,invoice_number"
        };

        var active_detail_tab = SettlementInvoice.tabbar.getActiveTab();
        var ids = SettlementInvoice.tabbar.getAllTabs();
        // ids.forEach(function(tab_id) {
        //     SettlementInvoice.create_tab(tab_id, '','','','','',true); 

        // });
  

        var data = $.param(sql);
        var data_url = js_data_collector_url + "&" + data;        
        SettlementInvoice.grid.clearAndLoad(data_url, function() { 
            SettlementInvoice.grid.expandAll();
            SettlementInvoice.layout.cells('c').progressOff();
        });
      
        
      
    }

    SettlementInvoice.form_load_complete_function = function (win, full_id) {
        // alert(full_id);
        // var tab_id = SettlementInvoice.tabbar.getActiveTab();
        is_new = win.getText();
        var tab_object = win.getAttachedObject();

        SettlementInvoice.tabbar.tabs(full_id).getAttachedToolbar().addButton("documents", 'documents', "Documents", "doc.gif", "doc_dis.gif");

        SettlementInvoice.tabbar.tabs(full_id).getAttachedToolbar().attachEvent("onClick", function(id) {
            switch(id) {
                case "documents":
                    SettlementInvoice.open_document(full_id);
                    break;
                 default:
                    break;
            }
        });

        var object_id = (full_id.indexOf("tab_") != -1) ? full_id.replace("tab_", "") : tab_id;
        var toolbar_object = SettlementInvoice.tabbar.tabs(full_id).getAttachedToolbar();
        apply_sticker(object_id);
        update_document_counter(object_id, toolbar_object);

        detail_tabs = tab_object.getAllTabs();
        $.each(detail_tabs, function(index, value) { 
            layout_obj = tab_object.cells(value).getAttachedObject();
            if (index == 0) {
                grid_obj = layout_obj.cells('b').getAttachedObject();
                menu_obj = layout_obj.cells('b').getAttachedMenu();
                menu_obj.removeItem('t1'); 
                if (grid_obj instanceof dhtmlXGridObject) { 
                    grid_obj.enablePaging(false, 10, 0, 'pagingAreaGrid_b'); 
                    layout_obj.cells('b').detachStatusBar(); 
                }
            }

            layout_obj.forEachItem(function(cell) {
                attached_obj = cell.getAttachedObject();
                if(attached_obj instanceof dhtmlXForm) {
                    is_finalized = attached_obj.getItemValue("is_finalized");
                    if(is_finalized == '') {
                        attached_obj.setItemValue('is_finalized', 'n');
                    }
                    is_voided = attached_obj.getItemValue("is_voided");
                    if(is_voided == '') {
                        attached_obj.setItemValue('is_voided', 'n');
                    }
                }
            });
        });
    } 
    
    SettlementInvoice.save_function = function (win, full_id) {
        var tab_id = SettlementInvoice.tabbar.getActiveTab();
        var tab_obj = SettlementInvoice.tabbar.cells(tab_id).getAttachedObject();
        var detail_tabs = tab_obj.getAllTabs();

        $.each(detail_tabs, function(index,value) {
            layout_obj = tab_obj.cells(value).getAttachedObject();
            layout_obj.forEachItem(function(cell) {
                attached_obj = cell.getAttachedObject();
                if(attached_obj instanceof dhtmlXForm) {
                    var status = validate_form(attached_obj);
                    if(status) {                        
                        payment_date = (attached_obj.getItemValue("payment_date", true))? dates.convert_to_sql(new Date(attached_obj.getItemValue("payment_date", true))) : "";
                        invoice_date = (attached_obj.getItemValue("invoice_date", true))? dates.convert_to_sql(new Date(attached_obj.getItemValue("invoice_date", true))) : "";
                        invoice_status = attached_obj.getItemValue("invoice_status");
                        is_voided = attached_obj.getItemValue("is_voided");
                        invoice_note = attached_obj.getItemValue("invoice_note");
                        acc_status  = attached_obj.getItemValue("is_finalized");
                        loc_status  = attached_obj.getItemValue("is_locked");
                        pay_status  = attached_obj.getItemValue("payment_status");
                        stmt_invoice_id  = attached_obj.getItemValue("stmt_invoice_id");
                       
                        var xml = '<Root><PSRecordSet stmt_invoice_id="' + stmt_invoice_id 
                                    + '" invoice_status="' + invoice_status 
                                    + '" acc_status="' + acc_status 
                                    + '" loc_status="' + loc_status
                                    + '" pay_status="' +  pay_status
                                    + '" invoice_note="' + invoice_note 
                                    + '" payment_date="' + payment_date
                                    + '" invoice_date="' + invoice_date  
                                    + '" is_voided="' + is_voided 
                                    + '"></PSRecordSet></Root>';
                               
                        data = {"action": "spa_stmt_invoice",
                            "flag": "u",
                            "xml": xml
                        };

                        adiha_post_data('alert', data, '', '', 'SettlementInvoice.refresh_grid', '', '');
                    }
                }
            });
        });
    }

    function load_context_menu(){
        SettlementInvoice.grid.attachEvent("onRowSelect", function(row_id){
            // SettlementInvoice.menu.setItemEnabled('workflow_status');
            var level = SettlementInvoice.grid.getLevel(row_id);
             
            if(level == 2) {               
                var is_finalized = SettlementInvoice.grid.cells(row_id, SettlementInvoice.grid.getColIndexById('acc_status')).getValue();
                var void_status = SettlementInvoice.grid.cells(row_id, SettlementInvoice.grid.getColIndexById('void_status')).getValue();
                var payment_status = SettlementInvoice.grid.cells(row_id, SettlementInvoice.grid.getColIndexById('payment_status')).getValue();
                var is_locked = SettlementInvoice.grid.cells(row_id, SettlementInvoice.grid.getColIndexById('is_locked')).getValue();

                var invoice_type = SettlementInvoice.grid.cells(row_id, SettlementInvoice.grid.getColIndexById('invoice_type')).getValue();
  
                if(invoice_type == 'Netting') {
                    SettlementInvoice.menu.setItemDisabled('finalize_status');
                    SettlementInvoice.menu.setItemDisabled('unfinalize_status');
                    SettlementInvoice.menu.setItemDisabled('void_status');
                    SettlementInvoice.menu.setItemDisabled('paid');
                    SettlementInvoice.menu.setItemDisabled('unpaid');
                    SettlementInvoice.menu.setItemDisabled('lock');
                    SettlementInvoice.menu.setItemDisabled('unlock');
                    SettlementInvoice.menu.setItemDisabled('audit');
                    SettlementInvoice.menu.setItemDisabled('workflow_status');
                    SettlementInvoice.menu.setItemDisabled('delete');
                    SettlementInvoice.menu.setItemDisabled('payment_status');

                    if (has_right_settlement_invoice_export_invoice_function_id)
                        SettlementInvoice.menu.setItemEnabled('generate_invoice');
                        
                    SettlementInvoice.menu.setItemEnabled('settlement_invoice_send');
                    
                } else {
                    if(has_right_settlement_invoice_delete_function_id) {
                        SettlementInvoice.menu.setItemEnabled('delete'); 
                    }

                    SettlementInvoice.menu.setItemEnabled("audit");
                   
                    if (has_right_settlement_invoice_workflow_status_function_id)
					    SettlementInvoice.menu.setItemEnabled('workflow_status'); 

                    if(void_status != 'Voided' && (has_right_settlement_invoice_void_function_id)) {
                        SettlementInvoice.menu.setItemEnabled('void_status');
                    } else {
                        SettlementInvoice.menu.setItemDisabled('void_status');
                    }

                    if(is_finalized == 'Finalized' && (has_right_settlement_invoice_finalize_function_id)) {
                        SettlementInvoice.menu.setItemEnabled('unfinalize_status');
                    } else {
                        SettlementInvoice.menu.setItemDisabled('unfinalize_status');
                    }

                    if(is_finalized != 'Finalized' && (has_right_settlement_invoice_finalize_function_id)) {
                        SettlementInvoice.menu.setItemEnabled('finalize_status');
                    } else {
                        SettlementInvoice.menu.setItemDisabled('finalize_status');
                    }

                    SettlementInvoice.menu.setItemEnabled('payment_status');
                    if(payment_status == 'Paid'){
                        SettlementInvoice.menu.setItemEnabled('unpaid');
                        SettlementInvoice.menu.setItemDisabled('paid');
                    } else if (payment_status == 'Unpaid'){
                        SettlementInvoice.menu.setItemEnabled('paid');
                        SettlementInvoice.menu.setItemDisabled('unpaid');
                    } else {
                        SettlementInvoice.menu.setItemEnabled('paid');
                        SettlementInvoice.menu.setItemEnabled('unpaid');
                    }

                    if(is_locked == 'Locked'){
                        SettlementInvoice.menu.setItemEnabled('unlock');
                        SettlementInvoice.menu.setItemDisabled('lock');
                    } else {
                        SettlementInvoice.menu.setItemEnabled('lock');
                        SettlementInvoice.menu.setItemDisabled('unlock');
                    }

                    if (has_right_settlement_invoice_export_invoice_function_id)
                        SettlementInvoice.menu.setItemEnabled('generate_invoice');
                        
                    SettlementInvoice.menu.setItemEnabled('settlement_invoice_send');
                }

                invoice_context_menu = new dhtmlXMenuObject();
                invoice_context_menu.renderAsContextMenu();
                var menu_obj = [{id:"counterparty_invoice", text:"Counterparty Invoice", enabled:true} 
                                ];     
                invoice_context_menu.loadStruct(menu_obj);  
				SettlementInvoice.grid.enableContextMenu(invoice_context_menu);
				
				if (!has_right_settlement_invoice_counterparty_invoice_function_id)
					invoice_context_menu.setItemDisabled('counterparty_invoice');

                invoice_context_menu.attachEvent("onClick", function(menuitemId, zoneId) {  
                switch(menuitemId){
                        case 'counterparty_invoice':
                            open_counterparty_invoice_window(row_id);
                        break;
                    }
                });
            } else { 
                SettlementInvoice.grid.enableContextMenu();
                SettlementInvoice.menu.setItemDisabled('finalize_status'); 
                SettlementInvoice.menu.setItemDisabled('void_status');
                SettlementInvoice.menu.setItemDisabled('workflow_status');
                SettlementInvoice.menu.setItemDisabled('unfinalize_status'); 
                SettlementInvoice.menu.setItemDisabled('audit');
                SettlementInvoice.menu.setItemDisabled('paid'); 
                SettlementInvoice.menu.setItemDisabled('unpaid'); 
                SettlementInvoice.menu.setItemDisabled('lock'); 
                SettlementInvoice.menu.setItemDisabled('unlock'); 
                
            }  
        });        
    }

    function open_counterparty_invoice_window(row_id) {
        var js_path = '<?php echo $app_php_script_loc; ?>';
        var js_path_trm = '<?php echo $app_adiha_loc; ?>';
        
        counterparty_invoice_window = new dhtmlXWindows();
        var stmt_invoice_id = SettlementInvoice.grid.cells(row_id, SettlementInvoice.grid.getColIndexById('invoice_id')).getValue();
            
        var src = js_path_trm + 'adiha.html.forms/_settlement_billing/stmt_checkout/stmt.counterparty.invoice.php?stmt_invoice_id=' + stmt_invoice_id; 
        counterparty_invoice_obj = counterparty_invoice_window.createWindow('w1', 0, 0, 900, 600);
        counterparty_invoice_obj.setText("Counterparty Invoice");
        
        counterparty_invoice_obj.centerOnScreen();
        counterparty_invoice_obj.setModal(true);
        counterparty_invoice_obj.attachURL(src, false, true);
    }

    load_workflow_status = function() { 
        SettlementInvoice.menu.addNewSibling('t2', 'process', 'Process', false, 'action.gif', 'action_dis.gif'); 
        SettlementInvoice.menu.addNewChild('process', '0', 'workflow_status', 'Workflow Status', true, 'update_invoice_stat.gif', 'update_invoice_stat_dis.gif');
        SettlementInvoice.menu.addNewChild('process', '1', 'finalize_status', 'Finalize', true, 'finalize.gif', 'finalize_dis.gif');
        SettlementInvoice.menu.addNewChild('process', '2', 'unfinalize_status', 'UnFinalize', true, 'unfinalize.gif', 'unfinalize_dis.gif');

        SettlementInvoice.menu.addNewChild('process', '3', "payment_status", 'Payment Status', true, "export.gif", "export_dis.gif");
        SettlementInvoice.menu.addNewChild('payment_status', '0', "paid", 'Paid', true, "html.gif", "html_dis.gif");
        SettlementInvoice.menu.addNewChild('payment_status','1', "unpaid", 'Unpaid', true, "batch.gif", "batch_dis.gif");

        SettlementInvoice.menu.addNewChild('process', '6', 'void_status', 'Void', true, 'void.gif', 'void_dis.gif');
        SettlementInvoice.menu.addNewChild('process', '7', 'audit', 'View Audit', true, 'audit.gif', 'audit_dis.gif');
        SettlementInvoice.menu.addNewChild('process', '4', 'lock', 'Lock', false, 'lock.gif', 'lock_dis.gif');
        SettlementInvoice.menu.addNewChild('process', '5', 'unlock', 'Unlock', false, 'unlock.gif', 'unlock_dis.gif');
        //SettlementInvoice.menu.hideItem('finalize_status');

    }

    SettlementInvoice.grid_menu_click = function(id, zoneId, cas) {
        if (id == 'finalize_status' || id == 'unfinalize_status' || id == 'delete') {
            var selected_row = SettlementInvoice.grid.getSelectedRowId();
            var as_of_date_arr = new Array();
            if (selected_row != null) {
                var selected_row_array = selected_row.split(',');
                for(var i = 0; i < selected_row_array.length; i++) {
                    var as_of_date = SettlementInvoice.grid.cells(selected_row_array[i], SettlementInvoice.grid.getColIndexById('as_of_date')).getValue();
                    as_of_date = dates.convert_to_sql(as_of_date);
                    if (as_of_date_arr.indexOf(as_of_date) == -1)
                        as_of_date_arr.push(as_of_date);
                }
                var as_of_date = as_of_date_arr.toString();
                var params = {
                        'action': 'spa_stmt_checkout',
                        'flag': 'y',
                        'term_date': as_of_date
                    }

                var callback_fn = (function (result) {SettlementInvoice.grid_menu_click_callback(id, zoneId, cas, result); });
                adiha_post_data('return_array', params, '', '', callback_fn);
            }
        } else {
            SettlementInvoice.grid_menu_click_callback(id, zoneId, cas, true);
        }
    }

    SettlementInvoice.grid_menu_click_callback = function(id, zoneId, cas, result) {
        var selected_row = SettlementInvoice.grid.getSelectedRowId();
        if (result instanceof Array) {
            if(result[0][0] == 'false') {
                show_messagebox(result[0][2]);
                return;
            }
        }
        switch(id) {
        case "add":
            SettlementInvoice.create_tab(-1,0,0,0);
            break;
            
            case "delete":
            var select_id = SettlementInvoice.grid.getSelectedRowId();
            var invoice_id_index = SettlementInvoice.grid.getColIndexById('invoice_id');
            var acc_status_index = SettlementInvoice.grid.getColIndexById('acc_status');
            var lock_status_index = SettlementInvoice.grid.getColIndexById('is_locked');
            var acc_status = [];
            var invoice_ids = [];
            var is_locked = [];
            var is_parent = false;
            select_id = select_id.split(',');
            select_id.forEach(function(val) {
                var accounting_status = SettlementInvoice.grid.cells(val, acc_status_index).getValue();
                var child_count = SettlementInvoice.grid.hasChildren(val);
                if (child_count > 0) {
                    is_parent = true;
                }
                var locked_status = SettlementInvoice.grid.cells(val, lock_status_index).getValue();
                var child_count = SettlementInvoice.grid.hasChildren(val);
                if (child_count > 0) {
                    is_parent = true;
                }
                invoice_ids.push(SettlementInvoice.grid.cells(val, invoice_id_index).getValue());
                acc_status.push(accounting_status);
                is_locked.push(locked_status);
            });

            // if (is_parent === true) {
            //     dhtmlx.alert({
            //         title:"Alert",
            //         type:"alert",
            //         text:"Please select child item only."
            //     });
            //     return;
            // }

            if (acc_status.find('Finalized') !== false) {
                dhtmlx.alert({
                    title:"Alert",
                    type:"alert",
                    text:"Settlement is finalized for one or more selected invoice(s). Please unfinalize first."
                });
                return;
            }

             if (is_locked.find('Locked') !== false) {
                dhtmlx.alert({
                    title:"Alert",
                    type:"alert",
                    text:"Settlement is locked for one or more selected invoice(s). Please unlock first."
                });
                return;
            
            }

            if (select_id != null) {
                var xml = "<Root function_id=\"20012200\" object_id=\"" + invoice_ids[0] + "\">";
                invoice_ids.forEach(function(val) {
                    xml += "<GridDelete invoice_id=\""+ val + "\">";
                    xml += val;
                    xml += "</GridDelete>";
                });
                xml += "</Root>";
                xml = xml.replace(/'/g, "\"");

                dhtmlx.message({
                    type: "confirm",
                    title: "Confirmation",
                    ok: "Confirm",
                    text: "Are you sure you want to delete?",
                    callback: function(result) {
                        if (result) {
                            
                            data = {
                                    "action": "spa_stmt_invoice",
                                    "flag": "d",
                                    "xml":xml
                                };
                            adiha_post_data("return_array", data, "", "","SettlementInvoice.post_delete_callback");
                        }
                    }
                });
            } else {
                dhtmlx.alert({
                    title:"Alert",
                    type:"alert",
                    text:"Please select a row from grid."
                });
            }
            break;
        case "excel":
            SettlementInvoice.grid.toExcel(js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
            break;
        case "pdf":
            SettlementInvoice.grid.toPDF(js_php_path +'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
            break;
        case "refresh":
            var filter_param = SettlementInvoice.get_filter_parameters();
            SettlementInvoice.refresh_grid("",SettlementInvoice.enable_menu_item, filter_param);
            SettlementInvoice.layout.cells("a").collapse();
            SettlementInvoice.layout.cells("b").collapse();
            break;
        case "workflow_status":
            update_workflow_status();
            break;
        case "finalize_status":
            finalize_invoice();
            break;
        case "unfinalize_status":
            unfinalize_invoice();                
            break;
        case "void_status":
            if (selected_row != null) {
                var selected_row_array = selected_row.split(',');
                var calc_status = 0;
                
                for(var i = 0; i < selected_row_array.length; i++) {
                    var c_status = SettlementInvoice.grid.cells(selected_row_array[i], 10).getValue();
                    if (c_status != 'Finalized') {
                        calc_status = 1;
                    }
                }
                
                if (calc_status == 0) {
                    SettlementInvoice.layout.acc_pop = new dhtmlXPopup();
                    SettlementInvoice.layout.acc_form = SettlementInvoice.layout.acc_pop.attachForm(
                        [
                            {type: "calendar", label: "As of Date", name: "as_of_date", "dateFormat": client_date_format, position: "label-top", serverDateFormat:"%Y-%m-%d"},
                            {type: "button", value: "Ok"}
                        ]);
                    SettlementInvoice.layout.acc_pop.show(250,80,50,50);
                    var current_date = new Date();
                    SettlementInvoice.layout.acc_form.setItemValue('as_of_date', current_date);
                    SettlementInvoice.layout.acc_form.attachEvent("onButtonClick", function(name) {
                        SettlementInvoice.layout.acc_pop.hide();
                        var xml = "<Root>";
                        
                        for(var i = 0; i < selected_row_array.length; i++) {
                            var invoice_id = SettlementInvoice.grid.cells(selected_row_array[i], 1).getValue();
                            //var as_of_date = dates.convert_to_sql(SettlementInvoice.layout.acc_form.getItemValue("as_of_date", true));
                            var as_of_date = SettlementInvoice.layout.acc_form.getItemValue("as_of_date", true);
                            
                            if (invoice_id != '') {
                                xml += '<PSRecordSet invoice_id = "' + invoice_id + '" as_of_date = "' + as_of_date + '"></PSRecordSet>'
                            }
                        }
                        xml += "</Root>";
                        if (xml != '<Root></Root>') {

                            data = {"action": "spa_stmt_invoice",
                                    "flag": "v",
                                    "xml": xml
                                 };
                            adiha_post_data('confirm', data, '', '', 'SettlementInvoice.refresh_grid', '', 'Are you sure you want to void selected invoice ?');
                        }
                        SettlementInvoice.layout.acc_pop.hide(); 
                    });

                    settlementInvoice.layout.acc_pop.attachEvent("onBeforeHide", function(type, ev, id){
                        if (type == 'click' || type == 'esc') {
                            settlementInvoice.layout.acc_pop.hide();
                            return true;
                        }
                    });
                } else {
                    show_messagebox("Please finalize the invoice first before voiding.");
                }
            }                            

            break;
        case "audit":
            var selected_rows = SettlementInvoice.grid.getSelectedRowId();
            var invoice_ids = new Array();

            if (selected_rows != null) {
                var arr_selected_rows = selected_rows.split(',');

                $.each(arr_selected_rows, function(i, row_id) {
                    var invoice_id = SettlementInvoice.grid.cells(row_id, SettlementInvoice.grid.getColIndexById('invoice_id')).getValue();
                    invoice_ids.push(invoice_id);
                });

                call_audit_report(invoice_ids.join());
            }
            break;
        case "paid":
            paid_unpaid_invoice('paid');
            break;
        case "unpaid":
            paid_unpaid_invoice('unpaid');                
            break;

        case "lock":
            lock_unlock_status('y');    
        break;

        case "unlock":
            lock_unlock_status('n');
        break;    
       }
    };

    function finalize_invoice() {
        var selected_rows = SettlementInvoice.grid.getSelectedRowId();
        var invoice_ids = new Array();
        var arr_selected_rows = selected_rows.split(',');

        $.each(arr_selected_rows, function(i, row_id) {
            var invoice_id = SettlementInvoice.grid.cells(row_id, SettlementInvoice.grid.getColIndexById('invoice_id')).getValue();
            invoice_ids.push(invoice_id);
        });

        data = {"action": "spa_stmt_invoice",
                "flag": "f",
                "invoice_id": invoice_ids.join()
             };

        adiha_post_data('confirm', data, '', '', 'SettlementInvoice.refresh_grid', 'false', 'Are you sure you want to finalize selected invoice ?');
    }

    function unfinalize_invoice() {
        var selected_rows = SettlementInvoice.grid.getSelectedRowId();
        var invoice_ids = new Array();
        var arr_selected_rows = selected_rows.split(',');

        $.each(arr_selected_rows, function(i, row_id) {
            var invoice_id = SettlementInvoice.grid.cells(row_id, SettlementInvoice.grid.getColIndexById('invoice_id')).getValue();
            invoice_ids.push(invoice_id);
        });

        data = {"action": "spa_stmt_invoice",
                "flag": "n",
                "invoice_id": invoice_ids.join()
             };

        adiha_post_data('confirm', data, '', '', 'SettlementInvoice.refresh_grid', 'false', 'Are you sure you want to unfinalize selected invoice ?');

    }

    function call_audit_report(invoice_ids) {
        unload_audit_report_window();
        if (!audit_report_window) {
            audit_report_window = new dhtmlXWindows();
        }

        var new_win = audit_report_window.createWindow('w1', 0, 0, 800, 600);
        new_win.setText("Audit Log");
        new_win.centerOnScreen();
        new_win.setModal(true);
        
        var url = js_php_path + "dev/spa_html.php?exec=EXEC spa_stmt_invoice_audit 's','" + invoice_ids + "'";
           
        new_win.attachURL(url, false, true);
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
    
    function update_workflow_status() {
        var selected_row = SettlementInvoice.grid.getSelectedRowId();
        var un_finalized_invoice = new Array();
        var xml = "<Root>"; 

        if (selected_row != null) {
            var selected_row_array = selected_row.split(',');

            for(var i = 0; i < selected_row_array.length; i++) {
                var level = SettlementInvoice.grid.getLevel(selected_row_array[i]);
                if(level == 0) {
                    var child_ids = SettlementInvoice.grid.getAllSubItems(selected_row_array[i]);
                    var child_ids_arr = child_ids.split(',');   

                    for (child_cnt = 0; child_cnt < child_ids_arr.length; child_cnt++) {  
                        var sub_level = SettlementInvoice.grid.getLevel(child_ids_arr[child_cnt]);

                        if(sub_level == 1) {
                            var sub_child_ids = SettlementInvoice.grid.getAllSubItems(child_ids_arr[child_cnt]); 
                        }
                        var sub_child_ids_arr = sub_child_ids.split(',');  
                        
                        for (sub_child_cnt = 0; sub_child_cnt < sub_child_ids_arr.length; sub_child_cnt++) {  
                            var invoice_id = SettlementInvoice.grid.cells(sub_child_ids_arr[sub_child_cnt],SettlementInvoice.grid.getColIndexById('invoice_id')).getValue(); 
                            var status = SettlementInvoice.grid.cells(sub_child_ids_arr[sub_child_cnt], SettlementInvoice.grid.getColIndexById('acc_status')).getValue(); 

                            if (status != 'Finalized') { 
                                un_finalized_invoice.push(invoice_id);
                            } 
                        }  
                    }
                } else if(level == 1) {
                    var child_ids = SettlementInvoice.grid.getAllSubItems(selected_row_array[i]);
                    var child_ids_arr = child_ids.split(',');   

                    for (child_cnt = 0; child_cnt < child_ids_arr.length; child_cnt++) {  
                        var invoice_id = SettlementInvoice.grid.cells(child_ids_arr[child_cnt], SettlementInvoice.grid.getColIndexById('invoice_id')).getValue(); 
                        var status = SettlementInvoice.grid.cells(child_ids_arr[child_cnt], SettlementInvoice.grid.getColIndexById('acc_status')).getValue(); 

                        if (status != 'Finalized') { 
                            un_finalized_invoice.push(invoice_id);
                        } 
                    }                    
                } else if(level == 2) {
                    var invoice_id = SettlementInvoice.grid.cells(selected_row_array[i], SettlementInvoice.grid.getColIndexById('invoice_id')).getValue(); 
                    var status = SettlementInvoice.grid.cells(selected_row_array[i], SettlementInvoice.grid.getColIndexById('acc_status')).getValue(); 

                    if (status = 'Finalized') { 
                        un_finalized_invoice.push(invoice_id);
                    } 
                }
            }
        }
 
        var invoice_ids = new Array();
        $.each(un_finalized_invoice, function(i, el){
            if($.inArray(el, invoice_ids) === -1) invoice_ids.push(el);
        });       

        if (invoice_ids != '') { 
            for (invoice_cnt = 0; invoice_cnt < invoice_ids.length; invoice_cnt++) {  
                xml += '<PSRecordSet stmt_invoice_id = "' + invoice_ids[invoice_cnt]  + '"></PSRecordSet>'
            }
        }
        xml += "</Root>";

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
                        win.attachURL("stmt.update.invoice.status.php", null, xml_json);
                        win.attachEvent("onClose", function(win){
                            SettlementInvoice.refresh_grid();
                            var active_tab = SettlementInvoice.tabbar.getActiveTab()
                            var ids = SettlementInvoice.tabbar.getAllTabs();
                                if(active_tab) {
                                    ids.forEach(function(active_tab){
                                        delete SettlementInvoice.pages[active_tab];
                                        SettlementInvoice.tabbar.tabs(active_tab).close();
                                    })
                                }
                            return true;
                        });
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


    /*
     * Open document
     * @param {type} tab_id
     * @returns {undefined}         */
    SettlementInvoice.open_document = function(object_id) {
        var dhxWins = new dhtmlXWindows();
        var object_id = (object_id.indexOf("tab_") != -1) ? object_id.replace("tab_", "") : object_id;
        var tab_id = SettlementInvoice.tabbar.getActiveTab();
        var toolbar_object = SettlementInvoice.tabbar.tabs(tab_id).getAttachedToolbar();
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

    SettlementInvoice.create_tab = function (r_id, col_id, grid_obj, acc_id, tab_index, inner_tab, status) {
        var selected_row = SettlementInvoice.grid.getSelectedRowId();
        var stmt_invoice_type = SettlementInvoice.grid.cells(selected_row, SettlementInvoice.grid.getColIndexById('invoice_type')).getValue();
        if(stmt_invoice_type == 'Netting') {
            return
        }
        
        //status = true when creating tab when grid refreshed.
        if(typeof status === 'undefined' || status === null ) {
            if (r_id == -1 && col_id == 0) {
                 full_id = SettlementInvoice.uid();
                 full_id = full_id.toString();
                 text = "New";
            } else { 
                full_id = SettlementInvoice.get_id(SettlementInvoice.grid, r_id);
                text = SettlementInvoice.get_text(SettlementInvoice.grid, r_id);
                if (full_id == "tab_") { 
                    var selected_row = SettlementInvoice.grid.getSelectedRowId();
                    var state = SettlementInvoice.grid.getOpenState(selected_row);
                    if (state)
                        SettlementInvoice.grid.closeItem(selected_row);
                    else 
                        SettlementInvoice.grid.openItem(selected_row);
                    return false;
                }
            }
        }

        if(status) {
            var text = r_id.replace("tab_", "");
            full_id = r_id;

            if(SettlementInvoice.pages[full_id]) {
                delete SettlementInvoice.pages[full_id];
                if (SettlementInvoice.tabbar.cells(full_id) != null)
                    SettlementInvoice.tabbar.cells(full_id).close(false);
                if (SettlementInvoice.tabbar.tabs(full_id) != null)
                    SettlementInvoice.tabbar.tabs(full_id).close(false);
            }
        }

        if (!SettlementInvoice.pages[full_id]) {
            var tab_context_menu = new dhtmlXMenuObject();
            tab_context_menu.setIconsPath(js_image_path + "dhxmenu_web/")
            tab_context_menu.renderAsContextMenu();

            SettlementInvoice.tabbar.addTab(full_id,text, null, tab_index, true, true);
            //using window instead of tab
            var win = SettlementInvoice.tabbar.cells(full_id);
            SettlementInvoice.tabbar.t[full_id].tab.id = full_id;
            tab_context_menu.addContextZone(full_id);
            tab_context_menu.loadStruct([{id:"close", text:"Close", title: "Close"},{id:"close_all", text:"Close All", title: "Close All"},{id:"close_other", text:"Close Other Tabs", title: "Close Other Tabs"}]);
            tab_context_menu.attachEvent("onContextMenu", function(zoneId) {
                SettlementInvoice.tabbar.tabs(zoneId).setActive();
            });
            tab_context_menu.attachEvent("onClick", function(id, zoneId) {
                var ids = SettlementInvoice.tabbar.getAllTabs();
                switch(id) {
                    case "close_other":
                    ids.forEach(function(tab_id) {
                        if (tab_id != zoneId) {
                            delete SettlementInvoice.pages[tab_id];
                            SettlementInvoice.tabbar.tabs(tab_id).close();
                        }
                    })
                    break;
                    case "close_all":
                     ids.forEach(function(tab_id) {
                        delete SettlementInvoice.pages[tab_id];
                        SettlementInvoice.tabbar.tabs(tab_id).close();
                     })
                     break;
                    case "close":
                     ids.forEach(function(tab_id) {
                         if (tab_id == zoneId) {
                            delete SettlementInvoice.pages[tab_id];
                            SettlementInvoice.tabbar.tabs(tab_id).close();
                         }
                     })
                     break;
                }
            });

            var toolbar = win.attachToolbar();       
            toolbar.setIconsPath(js_image_path + "dhxmenu_web/");
            toolbar.attachEvent("onClick",SettlementInvoice.tab_toolbar_click);       
            toolbar.loadStruct([{id:"save", type: "button", img: "save.gif", imgdis: "save_dis.gif", text:"Save", title: "Save"}]);
            SettlementInvoice.tabbar.cells(full_id).setText(text);
            SettlementInvoice.tabbar.cells(full_id).setActive();
            SettlementInvoice.tabbar.cells(full_id).setUserData("row_id", r_id);
            win.progressOn();
            SettlementInvoice.set_tab_data(win,full_id);
            SettlementInvoice.pages[full_id] = win;
        } else {
            SettlementInvoice.tabbar.cells(full_id).setActive();
        };
    }

    SettlementInvoice.uid = function() {
        return (new Date()).valueOf();
    }

    function is_new_tab() {
        var tab_id = SettlementInvoice.tabbar.getActiveTab();
        if (tab_id.indexOf("tab_") == -1) {
            return 1;
        } else {
            return 0;
        }
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
     * [Function to generate invoice]
     */
    generate_invoice = function(stmt_invoice_id) {
		generate_document_for_view(stmt_invoice_id, '10000283', '', 'SettlementInvoice.generate_invoice_callback');
	}

    SettlementInvoice.generate_invoice_callback = function() {
        SettlementInvoice.layout.cells('c').progressOff();
    }
    
    /**
     * [Function to send settlement invoice]
     */
    settlement_invoice_send = function (stmt_invoice_id) {
        var title = "Send Settlement Invoice";
        var param = "source=Settlement_Process&gen_as_of_date=1&batch_type=v&call_from=invoice& is_stmt=1" + "&invoice_ids=" + stmt_invoice_id;
        var exec_call = "";
        adiha_run_batch_process(exec_call, param, title);
    }

    /**
     * [Function to change payment status to paid]
     */
    function paid_unpaid_invoice(status) {
        var selected_rows = SettlementInvoice.grid.getSelectedRowId();
        var invoice_ids = new Array();
        var arr_selected_rows = selected_rows.split(',');

        $.each(arr_selected_rows, function(i, row_id) {
            var invoice_id = SettlementInvoice.grid.cells(row_id, SettlementInvoice.grid.getColIndexById('invoice_id')).getValue();
            invoice_ids.push(invoice_id);
        });

        data = {"action": "spa_stmt_invoice",
                "flag": status,
                "invoice_id": invoice_ids.join()
        };

        if(status == 'paid')
            msg =  'Are you sure you want to paid the selected invoice ?';
        else
            msg =  'Are you sure you want to unpaid the selected invoice ?';

        adiha_post_data('confirm', data, '', '', 'SettlementInvoice.refresh_grid', 'false', msg);
    }
     /**
     * [Function to change status to lock/unlock.]
    */
    function lock_unlock_status(status) {
        var selected_rows = SettlementInvoice.grid.getSelectedRowId();
        var invoice_ids = new Array();
        var arr_selected_rows = selected_rows.split(',');

        $.each(arr_selected_rows, function(i, row_id) {
            var invoice_id = SettlementInvoice.grid.cells(row_id, SettlementInvoice.grid.getColIndexById('invoice_id')).getValue();
            invoice_ids.push(invoice_id);
        });

        data = {"action": "spa_stmt_invoice",
                "flag": status,
                "invoice_id": invoice_ids.join()
        };

        if(status == 'y')
            msg =  'Are you sure you want to lock the selected invoice ?';
        else
            msg =  'Are you sure you want to unlock the selected invoice ?';

        adiha_post_data('confirm', data, '', '', 'SettlementInvoice.refresh_grid', 'false', msg);
    }

</script> 