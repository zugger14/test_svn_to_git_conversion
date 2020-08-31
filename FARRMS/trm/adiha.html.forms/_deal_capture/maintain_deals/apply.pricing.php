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
    $form_namespace = 'applyPricingTo';

    $term_start = (isset($_POST["term_start"]) && $_POST["term_start"] != '') ? get_sanitized_value($_POST["term_start"]) : 'NULL';
    $term_end = (isset($_POST["term_end"]) && $_POST["term_end"] != '') ? get_sanitized_value($_POST["term_end"]) : 'NULL';
    $col_label = (isset($_POST["col_label"]) && $_POST["col_label"] != '') ? get_sanitized_value($_POST["col_label"]) : 'NULL';
    $col_text = (isset($_POST["col_text"]) && $_POST["col_text"] != '') ? get_sanitized_value($_POST["col_text"]) : 'NULL';
    $max_leg = (isset($_POST["max_leg"]) && $_POST["max_leg"] != '') ? get_sanitized_value($_POST["max_leg"]) : 'NULL';
    $selected_leg = (isset($_POST["selected_leg"]) && $_POST["selected_leg"] != '') ? get_sanitized_value($_POST["selected_leg"]) : 'NULL';
    $source_deal_detail_id = (isset($_POST["source_deal_detail_id"]) && $_POST["source_deal_detail_id"] != '') ? get_sanitized_value($_POST["source_deal_detail_id"]) : 'NULL';
    $source_deal_header_id = (isset($_POST["source_deal_header_id"]) && $_POST["source_deal_header_id"] != '') ? get_sanitized_value($_POST["source_deal_header_id"]) : 'NULL';
    $deal_price_data_process_id = (isset($_REQUEST["deal_price_data_process_id"]) && $_REQUEST["deal_price_data_process_id"] != '') ? get_sanitized_value($_REQUEST["deal_price_data_process_id"]) : 'NULL';
    $layout_json = '[{id: "a", header:false}]';
    $toolbar_json = '[{id:"ok", type:"button", img: "save.gif", img_disabled: "save_dis.gif", text:"Ok", title: "Ok"},
                      {id:"cancel", type:"button", img: "close.gif", img_disabled: "close_dis.gif", text:"Cancel", title: "Cancel"}]';
    $layout_obj = new AdihaLayout();
    $form_obj = new AdihaForm();
    $toolbar_obj = new AdihaToolbar();

    $leg_value = range(1, $max_leg);
    $leg_data = $form_obj->create_static_combo_box($leg_value, $leg_value, $selected_leg);

    $form_json = '[{"type": "settings", "position": "label-top", "offsetLeft":'.$ui_settings['offset_left'].', "inputWidth":'.$ui_settings['field_size'].'},
                   {"type": "input", "inputWidth":'.$ui_settings['field_size'].', "name":"field_label", "label": "Field Name", "disabled":"true", "value":"' . trim($col_label) . '"}, 
                   {"type":"newcolumn"},
                   {"type": "input", "name":"field_value", "label": "Field Value", "disabled":"true", "value":"' . $col_text . '"}, 
                   {"type":"newcolumn"}, 
                   {"type":"calendar", "validate":"NotEmptywithSpace", "required":true, "userdata":{"validation_message":"Required Field"}, "dateFormat":"' . $date_format . '", "serverDateFormat": "%Y-%m-%d", "name": "from_date", "label": "From", "enableTime": false, "calendarPosition": "bottom", "value":"' . $term_start . '"},
                   {"type":"newcolumn"},
                   {"type": "calendar", "validate":"NotEmptywithSpace", required:true, "userdata":{"validation_message":"Required Field"}, "dateFormat":"' . $date_format . '", "serverDateFormat": "%Y-%m-%d", "name": "to_date", "label": "To", "enableTime": false, "calendarPosition": "bottom", "value":"' . $term_end . '"},
                   {"type":"newcolumn"},
                   {"type":"combo","name":"leg","label":"Leg","validate":"NotEmptywithSpace","hidden":"false","disabled":"false","userdata":{"validation_message":"Invalid Selection"}, "tooltip":"Leg","required":"true","comboType":"custom_checkbox","filtering":"true","options":' . $leg_data . '}
				   ]';
    echo $layout_obj->init_layout('layout', '', '1C', $layout_json, $form_namespace);
    echo $layout_obj->attach_form('apply_to_form', 'a');
    echo $layout_obj->attach_toolbar_cell('toolbar', 'a');
    echo $toolbar_obj->init_by_attach('toolbar', $form_namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', $form_namespace . '.toolbar_click');
    
    echo $form_obj->init_by_attach('apply_to_form', $form_namespace);
    echo $form_obj->load_form($form_json);
    echo $form_obj->attach_event('', 'onChange', $form_namespace . '.form_change');
    echo $layout_obj->close_layout();
?>
</body>
<textarea style="display:none" name="txt_from_date" id="txt_from_date"></textarea>
<textarea style="display:none" name="txt_to_date" id="txt_to_date"></textarea>
<textarea style="display:none" name="txt_legs" id="txt_legs"></textarea>
<script type="text/javascript">
    var source_deal_detail_id = '<?php echo $source_deal_detail_id;?>';
    var source_deal_header_id = '<?php echo $source_deal_header_id;?>';
    var deal_price_data_process_id = '<?php echo $deal_price_data_process_id;?>';

    $(function() {
        var selected_value = '<?php echo $selected_leg;?>';
        var leg_combo = applyPricingTo.apply_to_form.getCombo('leg');
        var selected_index = leg_combo.getIndexByValue(selected_value);

        leg_combo.setChecked(selected_index, true);
        applyPricingTo.set_description();
    })

    applyPricingTo.set_description = function() {       
        var data = {
            "action":"spa_deal_pricing_detail",
            "flag":"x",
            "source_deal_detail_id":source_deal_detail_id
        }
        adiha_post_data("return_array", data, '', '', 'applyPricingTo.call_back_set_description');
    } 

    applyPricingTo.call_back_set_description = function(result) {
        if (result[0][0] !== '') {
            applyPricingTo.apply_to_form.setItemValue('field_value', result[0][0]);
        }
    }

    /**
     * [toolbar_click Deal Status toolbar clicked.]
     * @param  {[string]} id [Menu Id]
     */
    applyPricingTo.toolbar_click = function(id) {
        switch(id) {
            case "ok":
                var status = validate_form(applyPricingTo.apply_to_form);
                var leg_combo = applyPricingTo.apply_to_form.getCombo("leg");
                var leg = leg_combo.getChecked();

                if (leg == '') {
                    var message = applyPricingTo.apply_to_form.getUserData("leg","validation_message"); 
                    applyPricingTo.apply_to_form.setNote("leg", {text:message,width:100});
                    break;
                }
                var from_date = applyPricingTo.apply_to_form.getItemValue("from_date", true);
                var to_date = applyPricingTo.apply_to_form.getItemValue("to_date", true);
                var leg_combo = applyPricingTo.apply_to_form.getCombo("leg");
                var leg = leg_combo.getChecked();

                var deal_detail_index = parent.dealDetail.grid.getColIndexById('source_deal_detail_id');
                var parent_leg_index = parent.dealDetail.grid.getColIndexById('blotterleg');
                var parent_term_start_index = parent.dealDetail.grid.getColIndexById('term_start');
                var parent_term_end_index = parent.dealDetail.grid.getColIndexById('term_end');

                var deal_detail_ids = get_columns_value(parent.dealDetail.grid, deal_detail_index);
                var legs = get_columns_value(parent.dealDetail.grid, parent_leg_index);
                var term_starts = get_columns_value(parent.dealDetail.grid, parent_term_start_index);
                var term_ends = get_columns_value(parent.dealDetail.grid, parent_term_end_index);
                var matched_detail_ids_arr = [];

                for (var j = 0; j <= deal_detail_ids.length; j++) {
                    if (term_starts[j] >= from_date && term_starts[j] <= to_date) {
                        for (var i = 0; i<=leg.length; i++) {
                            if (legs[j] == leg[i])
                                matched_detail_ids_arr.push(deal_detail_ids[j]);
                        }
                    }
                }

                var matched_detail_ids = matched_detail_ids_arr.toString();

                if (status) {
                    var data = {
                        "action":"spa_deal_pricing_detail",
                        "flag":"t",
                        "mode":"fetch",
                        "xml_process_id":deal_price_data_process_id,
                        "source_deal_detail_id":source_deal_detail_id,
                        "ids_to_apply_price": matched_detail_ids
                    }
                
                    adiha_post_data("return_array", data, '', '', 'applyPricingTo.check_pricing_data');
                    
                }
                break;
            case "cancel":
                document.getElementById("txt_from_date").value = 'cancel';
                var win_obj = window.parent.apply_to_window.window("w1");
                win_obj.close();
                break;
        }
    }

    applyPricingTo.check_pricing_data = function(result) {
        if (result[0][3] == 'Error') {
            var message = result[0][4];

            dhtmlx.alert({
                title: "Error",
                type: "alert-error",
                text: message
            });

            return;
        }
        
        
        var process_id = result[0][5];
        parent.deal_price_data_process_id = process_id;
        
        var win_obj = window.parent.apply_to_window.window("w1");
        win_obj.close();
    }

    /**
     * [form_change Form Change callback]
     * @param  {[type]} name [item name]
     */
    applyPricingTo.form_change = function(name) {
        var from_date = applyPricingTo.apply_to_form.getItemValue("from_date", true);
        var to_date = applyPricingTo.apply_to_form.getItemValue("to_date", true);

        if (dates.compare(to_date, from_date) == -1) {
            if (name == 'from_date') {
                var message = 'From Date cannot be less than To Date.';
            } else {
                var message = 'To Date cannot be greater than From Date.';
            }

            dhtmlx.alert({
                title:"Error",
                type:"alert-error",
                text:message,
                callback: function(result){
                    var min_max_val = (name == 'from_date') ? to_date : from_date;
                    applyPricingTo.apply_to_form.setItemValue(name, min_max_val);
                }
            });
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
</html>