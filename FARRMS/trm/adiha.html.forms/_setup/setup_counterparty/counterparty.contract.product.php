<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
        <?php require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
        <?php require('../../../adiha.html.forms/_setup/manage_documents/manage.documents.button.php'); ?>
        
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
    </head>
    <body>
        <?php
        $counterparty_id = get_sanitized_value($_GET['counterparty_id']);
        $internal_counterparty_id = get_sanitized_value($_GET['internal_counterparty_id']);
        $contract_id = get_sanitized_value($_GET['contract_id']);
        $counterparty_credit_block_id = ($_GET['counterparty_credit_block_id']) ? get_sanitized_value($_GET['counterparty_credit_block_id']) : -1;
        $counterparty_contract_address_id = get_sanitized_value($_GET['counterparty_contract_address_id'] ?? '');

        $function_id = 10105904; 
        
        $form_namespace = 'CounterpartyContractProduct';
        $form_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='" . $function_id . "', @template_name='CounterpartyContractProduct', @group_name='General', @parse_xml = '<Root><PSRecordSet counterparty_credit_block_id=\"" . $counterparty_credit_block_id . "\"></PSRecordSet></Root>'";
        $form_arr = readXMLURL2($form_sql);
        $form_json = $form_arr[0]['form_json'];

        $layout_obj = new AdihaLayout();
        $toolbar_obj = new AdihaToolbar();
        $form_obj = new AdihaForm();
        $layout_json = '[{id: "a", header:false}]';
        $toolbar_json = '[{ id: "save", type: "button", img: "save.gif", imgdis: "save_dis.gif", text:"Save", title: "Save"}]';

        echo $layout_obj->init_layout('layout', '', '1C', $layout_json, $form_namespace);
        echo $layout_obj->attach_toolbar_cell("toolbar", "a");
        echo $toolbar_obj->init_by_attach("toolbar", $form_namespace);
        echo $toolbar_obj->load_toolbar($toolbar_json); 
        echo $toolbar_obj->attach_event('', 'onClick', $form_namespace . '.save_click');

        // attach filter form
        $form_name = 'form_counterparty_contract_product';
        echo $layout_obj->attach_form($form_name, 'a', $form_json, $form_arr[0]['dependent_combo']);

        echo $layout_obj->close_layout();      
    
        ?>
    </body>
    <script type="text/javascript">  
        var counter_check = 0;

        dhxWins = new dhtmlXWindows();
        var counterparty_contract_address_id = '<?php echo $counterparty_contract_address_id; ?>';
        //alert(counterparty_contract_address_id);
        
        $(function(){
            CounterpartyContractProduct.counterparty_credit_block_id = '<?php echo $counterparty_credit_block_id; ?>';
            counterparty_id = '<?php echo $counterparty_id; ?>';
            internal_counterparty_id = '<?php echo $internal_counterparty_id; ?>';
            contract_id = '<?php echo $contract_id; ?>';
            
            var object_id = CounterpartyContractProduct.counterparty_credit_block_id;
            toolbar_obj = CounterpartyContractProduct.layout.cells("a").getAttachedToolbar();             
 
        });
             
        
        CounterpartyContractProduct.save_click = function(id) {
            switch (id) {
                case 'save':
                    var object_id = (CounterpartyContractProduct.counterparty_credit_block_id == -1) ? '' : CounterpartyContractProduct.counterparty_credit_block_id;
                    var counterparty_id = '<?php echo $counterparty_id; ?>';
                    var internal_counterparty_id = '<?php echo $internal_counterparty_id; ?>';
                    var contract_id = '<?php echo $contract_id; ?>';

                    var status = validate_form(CounterpartyContractProduct.form_counterparty_contract_product);
                    if (status) {
                        form_data = CounterpartyContractProduct.form_counterparty_contract_product.getFormData();
                        var xml = '<Root function_id="10105904" object_id="' + object_id + '"><FormXML ';

                        for (var a in form_data) {
                            if (a!='counterparty_credit_block_id' && a!= 'counterparty_id' && a!= 'internal_counterparty_id' && a!= 'contract' && a!= 'counterparty_contract_address_id') {
                                value = form_data[a];
                                
                                xml += ' ' + a + '="' + value + '"';
                            }
                        }

                        // for New
                        if (!object_id) {
                             xml += ' counterparty_credit_block_id="" counterparty_id="' + counterparty_id + '" internal_counterparty_id="' + internal_counterparty_id + '" contract="' + contract_id + '" counterparty_contract_address_id="' + counterparty_contract_address_id + '"';
                         }
                        else
                            xml += ' counterparty_credit_block_id="'+CounterpartyContractProduct.counterparty_credit_block_id+'" counterparty_id="' + counterparty_id + '" counterparty_contract_address_id="' + counterparty_contract_address_id + '"';
                        
                        xml += ' ></FormXML></Root>';
                 
                        var param = {
                            "action": "spa_process_form_data",
                            "xml": xml
                        };
                        //CounterpartyContractProduct.toolbar.disableItem('save');
                        var return_val = adiha_post_data('return_array', param, '', '', 'CounterpartyContractProduct.save_callback', '');
                    } else {
                        generate_error_message();
                        return;
                    }
                    break; 
            }
        }
        
        CounterpartyContractProduct.save_callback = function(result) {            
            if (result[0][0] == 'Success') {
                if(result[0][5]) {
                    CounterpartyContractProduct.counterparty_credit_block_id = result[0][5].replace(/(^,)|(,$)/g, ""); 
                }
                dhtmlx.message({
                    text: result[0][4],
                    expire: 1000
                });
                setTimeout ( function() { 
                    window.parent.popup_window.window('w1').close(); 
                }, 1000);
            } else {
                dhtmlx.message({
                    title: "Error",
                    type: "alert-error",
                    text: result[0][4]
                });
            }
        }
    </script>

</html>