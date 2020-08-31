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
        $counterparty_product_id = ($_GET['counterparty_product_id']) ? get_sanitized_value($_GET['counterparty_product_id']) : -1;

        $function_id = 10105890;
        $rights_conterparty_contact_iu = 10105891;
        list (
            $has_rights_conterparty_contact_iu
        ) = build_security_rights(
            $rights_conterparty_contact_iu            
        );
        
        $form_namespace = 'counterpartyProducts';
        $form_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='" . $function_id . "', @template_name='CounterpartyProducts', @group_name='General', @parse_xml = '<Root><PSRecordSet counterparty_product_id=\"" . $counterparty_product_id . "\"></PSRecordSet></Root>'";
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
        if(!$has_rights_conterparty_contact_iu) {
            echo $toolbar_obj->disable_item('save');
        }
        echo $toolbar_obj->attach_event('', 'onClick', $form_namespace . '.save_click');

        // attach filter form
        $form_name = 'form_counterparty_products';
        echo $layout_obj->attach_form($form_name, 'a', $form_json, $form_arr[0]['dependent_combo']);
        
        $dependent_combo_array = array();
        $dependent_combo_array = explode(',', $form_arr[0]['dependent_combo']);

        echo $layout_obj->close_layout();      
        
        $category_name = 'Counterparty';
        $category_sql = "SELECT value_id FROM static_data_value WHERE type_id = 25 AND code = '" . $category_name . "'";
        $category_data = readXMLURL2($category_sql);
        
        $product_data_sql = "EXEC spa_counterparty_products @flag='u', @dependent_id = '" . $counterparty_product_id . "'";
        $product_data = readXMLURL2($product_data_sql);
        ?>
    </body>
    <script type="text/javascript">
   
        var commodity_origin_id = '';
        var commodity_form_id = '';
        var commodity_form_attribute1 = '';
        var commodity_form_attribute2 = '';
        var commodity_form_attribute3 = '';
        var commodity_form_attribute4 = '';
        var commodity_form_attribute5 = '';
        var trader_id = '';
        var commodity_id = '';
        var category_id = '<?php echo $category_data[0]['value_id'];?>';
        var sub_category_id = 42002;
        var counter_check = 0;
        var has_rights_conterparty_contact_iu = '<?php echo $has_rights_conterparty_contact_iu; ?>';
        dhxWins = new dhtmlXWindows();
        
        $(function(){
            counterpartyProducts.counterparty_product_id = '<?php echo $counterparty_product_id; ?>';
            counterparty_id = '<?php echo $counterparty_id; ?>';
            
            var object_id = counterpartyProducts.counterparty_product_id;
            toolbar_obj = counterpartyProducts.layout.cells("a").getAttachedToolbar();
            


            //if(object_id != -1)
            //    add_manage_document_button(object_id, toolbar_obj, true);
            
            var cmb_commodity_obj = counterpartyProducts.form_counterparty_products.getCombo('commodity_id');


            commodity_id = cmb_commodity_obj.getSelectedValue();
            
            if (commodity_id != null) {
                cmb_commodity_obj.setComboValue(null);
                cmb_commodity_obj.setComboValue(commodity_id);
            }
            
            load_trader_dropdown();
        });
        
        function get_product_data(parent_id, dependent_id) { //return;
            var commodity_origin_id = '<?php echo $product_data[0]['commodity_origin_id'];?>';
            var commodity_form_id = '<?php echo $product_data[0]['commodity_form_id'];?>';
            var commodity_form_attribute1 = '<?php echo $product_data[0]['commodity_form_attribute1'];?>';
            var commodity_form_attribute2 = '<?php echo $product_data[0]['commodity_form_attribute2'];?>';
            var commodity_form_attribute3 = '<?php echo $product_data[0]['commodity_form_attribute3'];?>';
            var commodity_form_attribute4 = '<?php echo $product_data[0]['commodity_form_attribute4'];?>';
            var commodity_form_attribute5 = '<?php echo $product_data[0]['commodity_form_attribute5'];?>';
            var trader_id = '<?php echo $product_data[0]['trader_id'];?>';
            var commodity_id = '<?php echo $product_data[0]['commodity_id'];?>';
            
            var parent_combo = counterpartyProducts.form_counterparty_products.getCombo(parent_id)
            var parent_val = parent_combo.getSelectedValue();
            
            var combo = counterpartyProducts.form_counterparty_products.getCombo(dependent_id);
            
            if (dependent_id == 'commodity_origin_id') { 
                compare_val = commodity_id;
                set_val = commodity_origin_id;
            } else if (dependent_id == 'commodity_form_attribute1') {
                compare_val = commodity_form_id;
                set_val = commodity_form_attribute1;
            } else if (dependent_id == 'commodity_form_id') {
                compare_val = commodity_origin_id;
                set_val = commodity_form_id;
            } else if (dependent_id == 'commodity_form_attribute2') {
                compare_val = commodity_form_attribute1;
                set_val = commodity_form_attribute2;
            } else if (dependent_id == 'commodity_form_attribute3') {
                compare_val = commodity_form_attribute2;
                set_val = commodity_form_attribute3;
            } else if (dependent_id == 'commodity_form_attribute4') {
                compare_val = commodity_form_attribute3;
                set_val = commodity_form_attribute4;
            } else if (dependent_id == 'commodity_form_attribute5') {
                compare_val = commodity_form_attribute4;
                set_val = commodity_form_attribute5;
            }
            
            if (counter_check == 0 && parent_val == compare_val) {
                combo.setComboValue(set_val);
            } else {
                counter_check++;
                //combo.setComboText(null);
                //combo.setComboValue(null);
            }
        }
        
        function load_trader_dropdown() {
            var cm_param = {
                "action": 'spa_counterparty_products',
                "call_from": "multiselect",
                "has_blank_option": "false",
                "flag": 't',
                "dependent_id": counterparty_id,
                "product_id": counterpartyProducts.counterparty_product_id
            };
    
            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;
            
            counterpartyProducts.form_counterparty_products.reloadOptions('trader_id', url);
        }
        
        counterpartyProducts.save_click = function(id) {
            switch (id) {
                case 'save':
                    var object_id = (counterpartyProducts.counterparty_product_id == -1) ? '' : counterpartyProducts.counterparty_product_id;
                    var counterparty_id = '<?php echo $counterparty_id; ?>';
                    var status = validate_form(counterpartyProducts.form_counterparty_products);
                    if (status) {
                        form_data = counterpartyProducts.form_counterparty_products.getFormData();
                        var xml = '<Root function_id="10105890" object_id="' + object_id + '"><FormXML ';

                        for (var a in form_data) {
                            if (a!='counterparty_product_id'&&a!='counterparty_id') {
                                if (counterpartyProducts.form_counterparty_products.getItemType(a) == 'calendar') {
                                    value = counterpartyProducts.form_counterparty_products.getItemValue(a, true);
                                } else {
                                    value = form_data[a];
                                }
                                xml += ' ' + a + '="' + value + '"';
                            }
                        }

                        // for New
                        if (!object_id) {
                             xml += ' counterparty_product_id="" counterparty_id="' + counterparty_id + '"';
                         }
                        else
                            xml += ' counterparty_product_id="'+counterpartyProducts.counterparty_product_id+'" counterparty_id="' + counterparty_id + '"';
                        
                        xml += ' ></FormXML></Root>';
                        
                        var param = {
                            "action": "spa_process_form_data",
                            "xml": xml
                        };
                        counterpartyProducts.toolbar.disableItem('save');
                        var return_val = adiha_post_data('return_array', param, '', '', 'counterpartyProducts.save_callback', '');
                    } else {
                        generate_error_message();
                        return;
                    }
                    break;
                case "documents":
                    var object_id = counterpartyProducts.counterparty_product_id;
                    counterpartyProducts.open_document(object_id);
                    break;
            }
        }
        
        counterpartyProducts.open_document = function(object_id) {
            parent.maximize_minimize_window(true);
            var object_id = (object_id.indexOf("tab_") != -1) ? object_id.replace("tab_", "") : object_id;
             
            param = '../../_setup/manage_documents/manage.documents.php?call_from=counterparty_window_product&parent_object_id=' + counterparty_id + '&notes_category=' + category_id + '&notes_object_id=' + object_id + '&sub_category_id=' + sub_category_id + '&is_pop=true';
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
                update_document_counter(object_id, toolbar_obj);
                parent.maximize_minimize_window(false);
                return true;
            });
        }
        
        counterpartyProducts.save_callback = function(result) {
            if (has_rights_conterparty_contact_iu) {
                counterpartyProducts.toolbar.enableItem('save');
            };
            if (result[0][0] == 'Success') {
                if(result[0][5]) {
                    counterpartyProducts.counterparty_product_id = result[0][5].replace(/(^,)|(,$)/g, "");
                    //var is_found = toolbar_obj.getPosition('documents');
                    //if (!is_found)
                    //    add_manage_document_button(counterpartyProducts.counterparty_product_id, toolbar_obj, true);
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