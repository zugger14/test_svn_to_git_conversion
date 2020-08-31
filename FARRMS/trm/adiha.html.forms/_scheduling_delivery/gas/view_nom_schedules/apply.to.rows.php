<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
<body>
<?php 
    $form_namespace = 'volumeApplyTo';

    $flow_date = get_sanitized_value($_POST['flow_date'] ?? '');
    $flow_date_to = get_sanitized_value($_POST['flow_date_to'] ?? '');
    $col_label = get_sanitized_value($_POST['col_label'] ?? '');
    $col_value = get_sanitized_value($_POST['col_value'] ?? '');
    $deal_info = get_sanitized_value($_POST['info'] ?? '');
    
    $layout_json = '[{id: "a", header:false}]';
    $toolbar_json = '[{id:"ok", type:"button", img: "save.gif", img_disabled: "save_dis.gif", text:"Ok", title: "Ok"},
                      {id:"cancel", type:"button", img: "close.gif", img_disabled: "close_dis.gif", text:"Cancel", title: "Cancel"}]';
    $layout_obj = new AdihaLayout();
    $form_obj = new AdihaForm();
    $toolbar_obj = new AdihaToolbar();

    $form_json = '[{"type": "settings", "position": "label-top", "offsetLeft":'.$ui_settings['offset_left'].', "inputWidth":'.$ui_settings['field_size'].'},
                   {"type": "input", "inputWidth":'.$ui_settings['field_size'].', "name":"field_label", "label": "Field Name", "disabled":"true", "value":"' . trim($col_label) . '"}, 
                   {"type":"newcolumn"},
                   {"type":"calendar", "validate":"NotEmptywithSpace", "required":true, "userdata":{"validation_message":"Required Field"}, "dateFormat":"' . $date_format . '", "serverDateFormat": "%Y-%m-%d", "name": "from_date", "label": "From", "enableTime": false, "calendarPosition": "bottom", "value":"' . $flow_date . '"},
                   {"type":"newcolumn"},
                   {"type": "calendar", "validate":"NotEmptywithSpace", required:true, "userdata":{"validation_message":"Required Field"}, "dateFormat":"' . $date_format . '", "serverDateFormat": "%Y-%m-%d", "name": "to_date", "label": "To", "enableTime": false, "calendarPosition": "bottom", "value":"' . $flow_date_to . '"},
                   {"type":"newcolumn"},
                   {"type": "input", "inputWidth":'.$ui_settings['field_size'].', "name":"field_value", "label": "Value", "value":"' . trim($col_value) . '"},
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
<textarea style="display:none" name="txt_status" id="txt_status"></textarea>
<script type="text/javascript">
    
    /**
     * [toolbar_click Deal Status toolbar clicked.]
     * @param  {[string]} id [Menu Id]
     */
    volumeApplyTo.toolbar_click = function(id) {
        switch(id) {
            case "ok":
                var status = validate_form(volumeApplyTo.apply_to_form);

                if (status) {
                    var col_label = '<?php echo $col_label; ?>';
                    // Trickle Volume Starts
                    var mode = (col_label.indexOf('Rec') != -1) ? true : false;
                    var deal_info = JSON.parse('<?php echo $deal_info; ?>');
                    if (mode) {
                        var new_vol = final_del_vol = 0;
                        var final_rec_vol = volumeApplyTo.apply_to_form.getItemValue("field_value");
                        
                        deal_info.forEach(function(item, index) {
                            var shrinkage = item.shrinkage;
                            var schedule_vol = (index == 0) ? final_rec_vol : new_vol;
                            item.rec_vol = schedule_vol.toString();
                            new_vol = (schedule_vol * (1 - shrinkage));
                            final_del_vol = new_vol = Math.round(new_vol);

                            item.del_vol = new_vol.toString();
                        });
                    } else {
                        var new_vol = final_rec_vol = 0;
                        var final_del_vol = volumeApplyTo.apply_to_form.getItemValue("field_value");
                        deal_info.forEach(function(item, index) {
                            index = deal_info.length - 1 - index;
                            var shrinkage = deal_info[index].shrinkage;
                            var delivery_vol = (index + 1 == deal_info.length) ? final_del_vol : new_vol;
                            deal_info[index].del_vol = delivery_vol.toString();
                            new_vol = (delivery_vol / (1 - shrinkage));
                            final_rec_vol = new_vol = Math.round(new_vol);
                            deal_info[index].rec_vol = new_vol.toString();
                        });
                    }
                    // Trickle Volume Ends

                    var from_date = volumeApplyTo.apply_to_form.getItemValue("from_date", true);
                    var to_date = volumeApplyTo.apply_to_form.getItemValue("to_date", true);
                    var flow_date = '<?php echo $flow_date; ?>';
                    var apply_to = (col_label.indexOf('Nom') != -1) ? 'deal_volume' : (col_label.indexOf('Sch') != -1) ? 'schedule_volume' : 'actual_volume';
                    var xml_data = '<Root>';
                    
                    $.each(deal_info, function(index, value) {
                        xml_data += '<DataRow deal_id="' + value.deal_id + '" rec_vol="' + value.rec_vol + '" del_vol="' + value.del_vol 
                                + '" flow_date_from="' + from_date + '" flow_date_to="' + to_date 
                                + '" apply_to="' + apply_to + '"></DataRow>';
                    });

                    xml_data += '</Root>';
                    var data = {
                            'action' : 'spa_schedules_view',
                            'flag' : 'f',
                            'xml_data' : xml_data
                        }
                    
                    adiha_post_data('alert', data, '', '', 'apply_all_callback', '', '');
                }
                break;
            case "cancel":
                var win_obj = window.parent.apply_to_window.window("w1");
                win_obj.close();
                break;
        }
    }

    function apply_all_callback(result) {
        if (result[0].errorcode == 'Success') {
            document.getElementById("txt_status").value = result[0].message;
            var win_obj = window.parent.apply_to_window.window("w1");
            win_obj.close();
        }
    }

    /**
     * [form_change Form Change callback]
     * @param  {[type]} name [item name]
     */
    volumeApplyTo.form_change = function(name) {
        var from_date = volumeApplyTo.apply_to_form.getItemValue("from_date", true);
        var to_date = volumeApplyTo.apply_to_form.getItemValue("to_date", true);

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
                    volumeApplyTo.apply_to_form.setItemValue(name, min_max_val);
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