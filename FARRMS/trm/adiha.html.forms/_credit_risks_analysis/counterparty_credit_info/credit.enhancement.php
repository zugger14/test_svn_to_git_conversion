<!--DOCTYPE transitional.dtd-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<meta http-equiv="X-UA-Compatible" content="IE=Edge">
<html>
<?php
include '../../../adiha.php.scripts/components/include.file.v3.php';
require '../../../adiha.html.forms/_setup/manage_documents/manage.documents.button.php';

$php_script_loc = $app_php_script_loc;
$app_user_loc = $app_user_name;
$function_id = 10101125;
$counterparty_id = get_sanitized_value($_GET['counterparty_id'] ?? 'NULL');
$counterparty_credit_info_id = get_sanitized_value($_GET['counterparty_credit_info_id'] ?? 'NULL');
$counterparty_credit_enhancement_id = get_sanitized_value($_GET['counterparty_credit_enhancement_id'] ?? 'NULL');
$is_new_tab = get_sanitized_value($_GET['is_new_tab'] ?? 'NULL');
$mode = get_sanitized_value($_GET['mode']);
$source_deal_header_id = get_sanitized_value($_GET['deal_id']);

$tab_json = '';

//Loads data for form from backend.
$xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10101125', @template_name='CounterpartyCreditInfoEnhancement', @parse_xml='<Root><PSRecordset counterparty_credit_enhancement_id=" . '"' . $counterparty_credit_enhancement_id . '"' . "></PSRecordset></Root>'";
$return_value1 = readXMLURL($xml_file);

//creating main layout for the form
$form_namespace = 'cci_enhancement';
$layout = new AdihaLayout();

//json for main layout.
$json = '[
        {
            id:             "a",
            text:           "Counterparty Credit Info - Enhancement",
            header:         false,
            collapse:       false,
            width:          200,
            fix_size:       [true,null]
        }
    ]';

echo $layout->init_layout('new_layout', '', '1C', $json, $form_namespace);

//json for toolbar.
$save_button_json = '[
                    {id:"save", type:"button", img:"save.gif", imgdis:"save_dis.gif", text:"Save", title:"Save"},
                    {id:"documents", type:"button", img:"doc.gif", imgdis:"doc_dis.gif", text:"Documents", title:"Documents"}, 
                ]';

//Attaching a toolbar to save button
$toolbar_name = 'toolbar';
echo $layout->attach_toolbar_cell($toolbar_name, 'a');
$toolbar_obj = new AdihaToolbar();
echo $toolbar_obj->init_by_attach($toolbar_name, $form_namespace);
echo $toolbar_obj->load_toolbar($save_button_json);
echo $toolbar_obj->attach_event('', 'onClick', 'cci_enhancement.save_cci_enhancement_detail');

//attaching form to main layout
foreach ($return_value1 as $temp1) {
    $form_json = $temp1[2];
    $form_name = 'cci_enhancement_form';
    if ($form_json) {
        echo $layout->attach_form($form_name, 'a');
        $form_obj = new AdihaForm();
        echo $form_obj->init_by_attach($form_name, $form_namespace);
        echo $form_obj->load_form($form_json);
    }
}
echo $layout->close_layout();
?>
<form name="<?php echo $form_name; ?>">
    <textarea id='xml_ids' name="xml_ids" style="display:none;"></textarea>
    <input type="hidden" id="dropdown" name="dropdown">
    <div id="layoutObj"></div>
</form>
<script>
    var session = "<?php echo $session_id; ?>";
    var php_script_loc = "<?php echo $php_script_loc; ?>";
    var mode = "<?php echo $mode;?>";
    var function_id = <?php echo $function_id;?>;
    dhxWins = new dhtmlXWindows();
    var source_deal_header_id = "<?php echo $source_deal_header_id ?>";
    if (mode == 'i') {
        var counterparty_credit_info_id = <?php echo $counterparty_credit_info_id;?>;
    }

    var counterparty_id = <?php echo $counterparty_id; ?>;
    var source_deal_header_id = "<?php echo $source_deal_header_id ?>";

    dhxWins = new dhtmlXWindows();
    var document_window;

    $(function() {
        //hiding documents button for new form
            var is_new_tab = '<?php echo $is_new_tab; ?>';  
            if (is_new_tab == 'y') { 
                cci_enhancement.toolbar.hideItem('documents');
            }   
            

        attach_browse_event('cci_enhancement.cci_enhancement_form','10101125');
        var combo_counterparty = cci_enhancement.cci_enhancement_form.getCombo('internal_counterparty');
        var combo_contract = cci_enhancement.cci_enhancement_form.getCombo('contract_id');
        var default_format = cci_enhancement.cci_enhancement_form.getUserData("internal_counterparty", "default_format");

        if (source_deal_header_id && source_deal_header_id != '' && mode =='i') {
            cci_enhancement.cci_enhancement_form.setItemValue('deal_id',source_deal_header_id);
            cci_enhancement.cci_enhancement_form.setItemValue('label_deal_id',source_deal_header_id);
        }
        var counterparty_combo_value, counterparty_index, contract_combo_value = '', contract_index;
        if (mode == 'u') {
            contract_combo_value = combo_contract.getSelectedValue();
            counterparty_combo_value = combo_counterparty.getSelectedValue();
        }

            // //Initial internal_counterparty_id combo option
            // var ici_sql = {
            //     "action"            : "spa_source_counterparty_maintain",//spa_getsourcecounterparty
            //     "flag"              : "o",
            //     "counterparty_type" : "i",
            //     "counterparty_id"   : counterparty_id
            // }
            // combo_counterparty.clearAll();
            // cci_enhancement.load_combo(combo_counterparty, ici_sql);

        // Initial contract_id combo option
            // var combo_sql = {
            //     "action"            : "spa_source_contract_detail",
            //     "flag"              : "r",
            //     "counterparty_id"   : counterparty_id
            // }
            // combo_contract.clearAll();
            // cci_enhancement.load_combo(combo_contract, combo_sql);

            // setTimeout(function() {
            //     counterparty_index = combo_counterparty.getIndexByValue(counterparty_combo_value);
            //     combo_counterparty.selectOption(counterparty_index);
            // }, 500);

            // if (default_format == 't') {
            //     combo_counterparty.attachEvent('onChange', function(value) {
            //         parent_value_ids = combo_counterparty.getSelectedValue();
            //         combo_contract.clearAll();
            //         combo_contract.setComboValue(null);
            //         combo_contract.setComboText(null);
            //         var combo_sql = {
            //             "action" : "spa_source_contract_detail",
            //             "flag"   : "o",
            //             "counterparty_id" : counterparty_id,
            //             "internal_counterparty_id" : parent_value_ids
            //         }
            //         cci_enhancement.load_combo(combo_contract, combo_sql);

            //         if(contract_combo_value != '') {
            //             setTimeout(function() {
            //                 contract_index = combo_contract.getIndexByValue(contract_combo_value);
            //                 combo_contract.selectOption(contract_index);
            //             }, 500);
            //         }
            //     });
            // }
            });

    cci_enhancement.load_combo = function(combo_obj, combo_sql) {
        var data = $.param(combo_sql);
        var url = js_dropdown_connector_url + '&' + data;
        combo_obj.load(url);
    }

    cci_enhancement.save_cci_enhancement_detail = function(id) {
        if (id == 'save') {
            var form_xml = '<Root function_id="10101125"><FormXML ';
            data = cci_enhancement.cci_enhancement_form.getFormData();
            var validation_status = true;
            var status = validate_form(cci_enhancement.cci_enhancement_form);

            if (status == false) {
                generate_error_message();
                validation_status = false;
                return false;
            }

            var expiration_date = cci_enhancement.cci_enhancement_form.getItemValue('expiration_date',true);
            var effective_date = cci_enhancement.cci_enhancement_form.getItemValue('eff_date',true);
            if (expiration_date && expiration_date < effective_date) {
                dhtmlx.alert({
                    title:"Alert",
                    type:"alert",
                    text:'<b>Expiration Date</b> should be greater than <b>Effective Date</b>.'
                });
                return false;
            }

            if (status == true) {
                cci_enhancement.new_layout.cells("a").progressOn();
                adiha_post_data('alert', data, '', '', 'parent.callback_enhancement_grid_refresh');
            }

            for (var a in data) {
                field_label = a;

                if (mode == 'i' && field_label == 'counterparty_credit_info_id') {
                    field_value = counterparty_credit_info_id;
                } else if (cci_enhancement.cci_enhancement_form.getItemType(a) == "calendar") {
                    field_value = cci_enhancement.cci_enhancement_form.getItemValue(a, true);
                }  else {
                    field_value = data[a];
                }

                if(field_label == 'label_deal_id') {
                    continue;
                }
                form_xml += " " + field_label + "=\"" + field_value + "\"";
            }
            form_xml += "></FormXML></Root>";
            if(validation_status){  
                // cci_enhancement.toolbar.disableItem('save');
                data = {"action": "spa_counterparty_credit_enhancements", flag: "t", "xml": form_xml};
                adiha_post_data("alert", data, "", "", "cci_enhancement.save_callback");
            }
        } else if (id == 'documents') {
             cci_enhancement.open_document(); 
        } 

        cci_enhancement.new_layout.cells("a").progressOff(); 
    }

    /**
     * [open_document Open Document window]
     */
    cci_enhancement.open_document = function() {
        cci_enhancement.unload_document_window();
        counterparty_credit_enhancement_id = '<?php echo $counterparty_credit_enhancement_id; ?>';

        if (!document_window) {
            document_window = new dhtmlXWindows();
        }

        var win_title = 'Document';
        var url_call_from = 'credit_enhancement_window';
        var parent_object_id = 'NULL';
        var sub_category_id = 'NULL';
        var category_id = 55;

        var win_url = app_form_path + '_setup/manage_documents/manage.documents.php?parent_object_id=' + parent_object_id + '&call_from=' + url_call_from + '&notes_category=' + category_id + '&notes_object_id=' + counterparty_credit_enhancement_id + '&sub_category_id=' + sub_category_id + '&is_pop=true';

        var win = document_window.createWindow('w1', 0, 0, 400, 400);
        win.setText(win_title);
        win.centerOnScreen();
        win.setModal(true);
        win.maximize();
        win.attachURL(win_url, false, {notes_category:category_id});

        win.attachEvent('onClose', function(w) {
            update_document_counter(counterparty_credit_enhancement_id, cci_enhancement.toolbar);
            return true;
        });
    }

    /**
     * [unload_document_window Unload Document Window]
     */
    cci_enhancement.unload_document_window = function() {
        if (document_window != null && document_window.unload != null) {
            document_window.unload();
            document_window = w1 = null;
        }
    }

    cci_enhancement.save_callback = function(result) {
        var new_id = result[0].recommendation;
        if(mode == 'i') { // Insert
            counterparty_credit_enhancement_id = new_id;
            data = {"action": "spa_register_event", module_id: 20618, event_id: 20560,process_table: "temp",process_id: "temp", p_id: new_id };
            adiha_post_data("", data, "", "", "");
        } else {  //Update
            counterparty_credit_enhancement_id = '<?php echo $counterparty_credit_enhancement_id; ?>';
            data = {"action": "spa_register_event", module_id: 20618, event_id: 20559,process_table: "temp",process_id: "temp", p_id: counterparty_credit_enhancement_id };
            adiha_post_data("", data, "", "", "");
        } 
        //insert update both case
        data = {"action": "spa_register_event", module_id: 20618, event_id: 20576,process_table: "temp",process_id: "temp", p_id: counterparty_credit_enhancement_id };
        adiha_post_data("", data, "", "", "");
        parent.callback_enhancement_grid_refresh(new_id, result[0].message);
    }

</script>
<div id="myToolbar1"></div>


        
        


