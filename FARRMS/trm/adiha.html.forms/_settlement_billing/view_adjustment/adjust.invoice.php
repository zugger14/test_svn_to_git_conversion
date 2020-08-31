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
    $true_up_id = get_sanitized_value($_GET["true_up_id"] ?? '');
    $calc_id = get_sanitized_value($_GET["calc_id"] ?? '');
    $prod_date = get_sanitized_value($_GET["prod_date"] ?? '');
    $has_rights = get_sanitized_value($_REQUEST["right_id"] ?? '');
    $form_namespace = 'AdjustInvoice';

    if ($has_rights != 0) {
        $rights = true;
    } else {
        $rights = false;
    }
    
    $form_obj = new AdihaForm();

    $layout_json = '[{id: "a", header:false}]';
    $toolbar_json = '[{ id: "save", type: "button", img: "save.gif", text:"Save", title: "Save", enabled: "' . $rights . '"}]';

    $template_dropdown = "EXEC('SELECT template_id, template_name FROM contract_report_template WHERE template_type = 38')";
    $template_dropdown_json = $form_obj->adiha_form_dropdown($template_dropdown, 0, 1, true);

    $form_json = '[ 
        {"type": "settings", "position": "label-top", "offsetLeft": 10},
        
        {"type":"calendar","name":"invoice_month","label":"Invoice Month","validate":"NotEmpty","hidden":"false","disabled":"false","value":"' .$prod_date. '","position":"label-top","offsetLeft":'.$ui_settings['offset_left'].',"labelWidth":"auto","inputWidth":'.$ui_settings['field_size'].',"tooltip":"invoice_month","required":"true","dateFormat":"'.$date_format.'","serverDateFormat":"%Y-%m-%d","calendarPosition":"bottom","userdata":{"validation_message":"Required Field"}},
        {"type":"newcolumn"},

        {type: "checkbox", name: "new_invoice", label: "Create New Invoice", value: "new_invoice", position: "label-right", "offsetLeft":'.$ui_settings['offset_left'].',"inputWidth":'.$ui_settings['field_size'].', "labelWidth":'.$ui_settings['field_size'].', "offsetTop" :'.$ui_settings['checkbox_offset_top'].', checked: false},
        {"type":"newcolumn"},

        {"type":"combo","name":"template","label":"Template","hidden":"false","disabled":"false","value":"","position":"label-top","offsetLeft":'.$ui_settings['offset_left'].',"labelWidth":"auto","inputWidth":'.$ui_settings['field_size'].',"tooltip":"template","required":"false","filtering":"true","options": ' . $template_dropdown_json . ' }
        ]';  

    
    $layout_obj = new AdihaLayout();
    $toolbar_obj = new AdihaToolbar();

    echo $layout_obj->init_layout('AdjustInvoice', '', '1C', $layout_json, $form_namespace);
    echo $layout_obj->attach_toolbar_cell("toolbar", "a");  
    echo $toolbar_obj->init_by_attach("toolbar", $form_namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', $form_namespace . '.save_click');

    // attach filter form
    $form_name = 'adjust_invoice';
    echo $layout_obj->attach_form($form_name, 'a');
    $form_obj->init_by_attach($form_name, $form_namespace);
    echo $form_obj->load_form($form_json);

    echo $layout_obj->close_layout(); 
?>
<script type="text/javascript">
	$(function() {
        AdjustInvoice.adjust_invoice.disableItem('template');
        AdjustInvoice.adjust_invoice.attachEvent("onChange", function (name, value, state) {
            if(name == 'new_invoice' && state) {
                var combo_template = AdjustInvoice.adjust_invoice.getCombo('template');
                combo_template.deleteOption('');
                combo_template.selectOption(0);
                AdjustInvoice.adjust_invoice.enableItem('template');
            }
            else if(name == 'new_invoice' && !state) {
                var combo_template = AdjustInvoice.adjust_invoice.getCombo('template');
                combo_template.addOption([
                                            ["",""],
                                        ]);
                AdjustInvoice.adjust_invoice.setItemValue('template', '');
                AdjustInvoice.adjust_invoice.disableItem('template');
            }
        });
	})
    
    var true_up_id = '<?php echo $true_up_id; ?>';
    var calc_id = '<?php echo $calc_id; ?>';

    AdjustInvoice.save_click = function(id) {
        if (id == 'save') {
            
            var status = validate_form(AdjustInvoice.adjust_invoice);
            if (status) {
                var prod_month = AdjustInvoice.adjust_invoice.getItemValue('prod_month', true);
                var invoice_month = AdjustInvoice.adjust_invoice.getItemValue('invoice_month', true);
                var template_obj = AdjustInvoice.adjust_invoice.getCombo('template');
                var invoice_template = template_obj.getSelectedValue();

                var param = {
                    "flag": "f",
                    "action": "spa_invoice_adjustment",
                    "calc_id":calc_id,
                    "true_up_id":true_up_id,
                    "invoice_template":invoice_template,
                    "invoice_month":invoice_month
                };
                
                adiha_post_data('return_json', param, '', '', 'save_click_callback', '');
            }
       }
    }


    function save_click_callback(result) {
        var return_data = JSON.parse(result);
        var status = return_data[0].status;
        
        if (status == 'Error') {
           show_messagebox(return_data[0].message);
        } else {
            dhtmlx.message({
                text:return_data[0].message,
                expire:1000
            });

            setTimeout(function() {
                window.parent.adjust_invoice_window.window('w1').close();
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