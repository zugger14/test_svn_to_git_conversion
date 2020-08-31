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
    require('../../../adiha.html.forms/_setup/manage_documents/manage.documents.button.php');
    $counterparty_id = get_sanitized_value($_GET["counterparty_id"] ?? '');
    $contract_id = get_sanitized_value($_GET["contract_id"] ?? '');
    $dispute_id = get_sanitized_value($_GET["dispute_id"] ?? '');
    $as_of_date = get_sanitized_value($_GET["as_of_date"] ?? '');
    $prod_date = get_sanitized_value($_GET["prod_date"] ?? '');
    $mode = get_sanitized_value($_GET["mode"] ?? '');
    $invoice_no = get_sanitized_value($_GET["invoice_no"] ?? '');
    $has_rights = get_sanitized_value($_REQUEST["right_id"] ?? '');

    if ($has_rights != 0) {
        $rights = true;
    } else {
        $rights = false;
    }
    
    $form_namespace = 'invoiceDispute';

    $layout_json = '[{id: "a", header:false}]';
    $toolbar_json = '[{ id: "save", type: "button", img: "save.gif", text:"Save", title: "Save", enabled: "'.$rights.'"}';

    if($dispute_id != '') {
        $toolbar_json = $toolbar_json . ', { id: "documents", type: "button", img: "doc.gif", imgdis: "doc_dis.gif", text:"Documents", title: "Documents", enabled: "'.$rights.'"}';
    }

    $toolbar_json = $toolbar_json . ']';

    $filter_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10221345', @template_name='InvoiceDispute', @group_name='invoice_dispute', @parse_xml = '<Root><PSRecordSet dispute_id=\"" . $dispute_id . "\"></PSRecordSet></Root>'";
    $filter_arr = readXMLURL2($filter_sql);
    $form_json = $filter_arr[0]['form_json'];

    $layout_obj = new AdihaLayout();
    $toolbar_obj = new AdihaToolbar();
    $form_obj = new AdihaForm();

    echo $layout_obj->init_layout('invoice_dispute', '', '1C', $layout_json, $form_namespace);
    echo $layout_obj->attach_toolbar_cell("toolbar", "a");  
    echo $toolbar_obj->init_by_attach("toolbar", $form_namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', $form_namespace . '.save_click');

    // attach filter form
    $form_name = 'frm_invoice_dispute';
    echo $layout_obj->attach_form($form_name, 'a');
    $form_obj->init_by_attach($form_name, $form_namespace);
    echo $form_obj->load_form($form_json);

    echo $layout_obj->close_layout();
    $category_name = 'Dispute';
    $category_sql = "SELECT value_id FROM static_data_value WHERE type_id = 25 AND code = '" . $category_name . "'";
    $category_data = readXMLURL2($category_sql);
?>
<script type="text/javascript">
    var category_id = '<?php echo $category_data[0]['value_id'] ?? '';?>';
    var mode = '<?php echo $mode; ?>';
    var object_id = '<?php echo $dispute_id;?>';

    $(function() {
        var invoice_no = '<?php echo $invoice_no; ?>';
        var sql_q = "SELECT DISTINCT value_id, code FROM static_data_value sdv INNER JOIN calc_invoice_volume civ ON sdv.value_id = civ.invoice_line_item_id INNER JOIN Calc_invoice_Volume_variance civv ON civ.calc_id = civv.calc_id WHERE sdv.[type_id] = 10019 AND civv.invoice_number = ''" + invoice_no + "'' ORDER BY [code]"
        var sel_val = invoiceDispute.frm_invoice_dispute.getItemValue('charge_type');
        
        var cm_param = {
                            "action": "[spa_generic_mapping_header]", 
                            "flag": "n",
                            "combo_sql_stmt": sql_q,
                            "call_from": "grid"
                        };

        cm_param = $.param(cm_param);
        var url = js_dropdown_connector_url + '&' + cm_param;
		var combo_obj = invoiceDispute.frm_invoice_dispute.getCombo('charge_type');   
        combo_obj.clearAll();
        combo_obj.setComboValue(null);
        combo_obj.setComboText(null);
        combo_obj.load(url, function(){
            combo_obj.selectOption(0);
        });
        
        if(mode == 'b') {
            invoiceDispute.frm_invoice_dispute.setItemValue('charge_type', sel_val);
        } else {
            combo_obj.setComboValue(0);;
        }

        dhxWins = new dhtmlXWindows();

        apply_sticker(object_id);
        toolbar_obj = invoiceDispute.toolbar;
        update_document_counter(object_id, toolbar_obj);
    });
    
    invoiceDispute.save_click = function(id) {
        if (id == 'save') {
            var counterparty_id = '<?php echo $counterparty_id; ?>';
            var contract_id = '<?php echo $contract_id; ?>';
            var as_of_date = '<?php echo $as_of_date; ?>';
            var prod_date = '<?php echo $prod_date; ?>';
            var dispute_user = '<?php echo $app_user_name; ?>';
            
            var status = validate_form(invoiceDispute.frm_invoice_dispute);
            
            if (status) {
                form_data = invoiceDispute.frm_invoice_dispute.getFormData();
                
                var xml = '<Root><PSRecordSet';
                for (var a in form_data) {
                    if (form_data[a] != '' && form_data[a] != null) {
                        if (invoiceDispute.frm_invoice_dispute.getItemType(a) == 'calendar') {
                            value = invoiceDispute.frm_invoice_dispute.getItemValue(a, true);
                        } else {
                            value = form_data[a];
                        }
                        
                        xml += ' ' + a + '="' + value + '"';
                    }
                }
                xml += ' counterparty_id="' + counterparty_id + '" contract_id="' + contract_id +
                                    '" billing_period="' + dates.convert_to_sql(prod_date) + '" as_of_date="' + dates.convert_to_sql(as_of_date) + 
                                    '" dispute_user="' + dispute_user + '" prod_date="' + dates.convert_to_sql(prod_date) +
                                    '">';
                xml += '</PSRecordSet></Root>';
                
                var param = {
                    "flag": mode,
                    "action": "spa_settlement_history",
                    "xml": xml
                };
            
                adiha_post_data('return_json', param, '', '', 'save_click_callback', '');
            }
        } else if (id == 'documents') {
            open_document();
        }
    }

    function open_document() {
        param = '../../_setup/manage_documents/manage.documents.php?notes_category=' + category_id + '&notes_object_id=' + object_id + '&is_pop=true';
        var win_obj = window.parent.invoice_dispute_window.window("w1");
        win_obj.maximize();

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
            win_obj.minimize();
            update_document_counter(object_id, toolbar_object);
            return true;
        });            
    }
    
    function save_click_callback(result) {
        var return_data = JSON.parse(result);
        
        var status = return_data[0].status;
        
        if (status == 'Error') {
           show_messagebox(return_data[0].message);
        } else {
            if (mode == 'a') {
                mode = 'b';
                var new_id = return_data[0].recommendation;
                invoiceDispute.frm_invoice_dispute.setItemValue('dispute_id', new_id);
            } 
            
            dhtmlx.message({
                text:return_data[0].message,
                expire:1000
            });

            setTimeout(function() {
                window.parent.invoice_dispute_window.window('w1').close();
            }, 1000);
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