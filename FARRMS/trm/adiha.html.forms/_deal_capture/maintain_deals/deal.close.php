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
    $form_namespace = 'dealClose';
    $deal_id = (isset($_POST["deal_id"]) && $_POST["deal_id"] != '') ? get_sanitized_value($_POST["deal_id"]) : '';
    
    $sp_term = "EXEC spa_deal_close @flag='s', @deal_id='" . $deal_id . "'";
    $data = readXMLURL2($sp_term);
    $term_start = $data[0]['term_start'];
    $term_end = $data[0]['term_end'];
    $leg = $data[0]['leg'];
    $post_date = $data[0]['post_date'];
    $label = $data[0]['type'];
    $price = $data[0]['price'];
    $floating_volume = $data[0]['floating_volume'];
    $uom = $data[0]['uom'];

    $layout_json = '[{id: "a", header:false}]';
    $toolbar_json = '[{id:"ok", type:"button", img: "save.gif", img_disabled: "save_dis.gif", text:"Ok", title: "Ok"},
                      {id:"cancel", type:"button", img: "close.gif", img_disabled: "close_dis.gif", text:"Cancel", title: "Cancel"}]';
                      
    $layout_obj = new AdihaLayout();
    $form_obj = new AdihaForm();
    $toolbar_obj = new AdihaToolbar();

    $form_json = '[{"type": "settings", position: "label-top", offsetLeft:20, inputWidth:150},
                   {"type": "calendar", disabled:true, "validate":"NotEmptywithSpace", "userdata":{"validation_message":"Required Field"}, "dateFormat":"' . $date_format . '", "serverDateFormat": "%Y-%m-%d", "name": "term_start", "label": "Term Start", "enableTime": false, "calendarPosition": "bottom", "value":"' . $term_start . '"},
                   {"type": "calendar", "validate":"NotEmptywithSpace", required:true, "userdata":{"validation_message":"Required Field"}, "dateFormat":"' . $date_format . '", "serverDateFormat": "%Y-%m-%d", "name": "as_of_date", "label": "Close Date", "enableTime": false, "calendarPosition": "bottom", "value":"' . $post_date . '"},
                   {"type": "input", "name":"post_price",  required:true, "label": "Price", value:"' . $price . '", numberFormat:"' . $GLOBAL_PRICE_FORMAT . '"},
                   {"type":"newcolumn"},
                   {"type": "calendar", disabled:true, "validate":"NotEmptywithSpace", "userdata":{"validation_message":"Required Field"}, "dateFormat":"' . $date_format . '", "serverDateFormat": "%Y-%m-%d", "name": "term_end", "label": "Term End", "enableTime": false, "calendarPosition": "bottom", "value":"' . $term_end . '"},
                   {"type": "input", "validate":"ValidRange", "name":"floating_volume",  required:true, "label": "Close Volume", value:"' . $floating_volume . '", numberFormat:"' . $GLOBAL_NUMBER_FORMAT . '"},
                   {"type": "input", "name":"vol_per", "validate":"ValidPercentage", required:true, "label": "Close %", value:"100", numberFormat:"0.00%"},
                   {"type":"newcolumn"},
                   {"type": "input", "name":"leg", label: "Leg", disabled:"true", value:"' . $leg . '"},
                   {"type": "input", "name":"uom", label: "UOM", disabled:"true", value:"' . $uom . '"}                   
                  ]';
    echo $layout_obj->init_layout('layout', '', '1C', $layout_json, $form_namespace);
    echo $layout_obj->attach_form('form', 'a');
    echo $layout_obj->attach_toolbar_cell('toolbar', 'a');
    echo $toolbar_obj->init_by_attach('toolbar', $form_namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', $form_namespace . '.toolbar_click');
    
    echo $form_obj->init_by_attach('form', $form_namespace);
    echo $form_obj->load_form($form_json);
    echo $form_obj->attach_event('', 'onChange', $form_namespace . '.form_change');
    echo $layout_obj->close_layout();
?>
</body>
<textarea style="display:none" name="txt_status" id="txt_status">cancel</textarea>
<script type="text/javascript">
    var type = '<?php echo $type; ?>';
    var min_date = '<?php echo $min_date; ?>';
    var max_date = '<?php echo $max_date; ?>';
    
    function ValidPercentage(data) {
        return (data<=100);
    }
    function ValidRange(data) {
        var floating_volume = <?php echo $floating_volume;?>;
        return (data>0 && data<=floating_volume);
    }

    $(function() {
        dealClose.form.enableLiveValidation(true);

        dealClose.form.attachEvent("onValidateSuccess", function(name, value){
           dealClose.form.setNote(name,{text:""});
           dealClose.toolbar.enableItem('ok');
        });

        dealClose.form.attachEvent("onValidateError", function (name, value, result){  
            if (name == 'floating_volume') {      
                var floating_volume = '<?php echo $floating_volume;?>';
                var val = (name == 'vol_per') ? '100' : floating_volume;
                var message = 'Closing volume exceeds the remaining volume. Available volume: ' + val;
                dealClose.form.setNote(name, {text:message,width:150});
                dealClose.toolbar.disableItem('ok');
            } else if(name == 'vol_per') {
                var message = 'Invalid data. Value can be less than or equal to 100.';
                dealClose.form.setNote(name, {text:message,width:150});
                dealClose.toolbar.disableItem('ok');
            }            
        });
    })

    /**
     * [toolbar_click Deal Status toolbar clicked.]
     * @param  {[string]} id [Menu Id]
     */
    dealClose.toolbar_click = function(id) {
        switch(id) {
            case "ok":
                var status = validate_form(dealClose.form);
                if (status) {
                    var floating_volume = '<?php echo $floating_volume;?>';
                    var deal_id = '<?php echo $deal_id; ?>';
                    var post_date = dealClose.form.getItemValue("as_of_date", true);
                    var close_vol = dealClose.form.getItemValue("floating_volume");
                    var post_price = dealClose.form.getItemValue("post_price");
                    var vol_per = dealClose.form.getItemValue("vol_per");
                    var xml = '<Form><FormXML deal_id="' + deal_id + '" close_date="' + post_date + '" close_volume="' + close_vol + '" left_volume="' + floating_volume + '" fixed_price="' + post_price + '"></FormXML></Form>';
                    data = {"action": "spa_deal_close", "flag":"c", "xmlValue":xml, "per_close":vol_per};
                    adiha_post_data("alert", data, '', '', 'dealClose.save_callback');
                }
                break;
            case "cancel":
                document.getElementById("txt_status").value = 'cancel';
                var win_obj = window.parent.deal_close_window.window("w1");
                win_obj.close();
                break;
        }
    }


    dealClose.save_callback = function(result) {
        if (result[0].errorcode == 'Success') {
            document.getElementById("txt_status").value = 'Success';
            var win_obj = window.parent.deal_close_window.window("w1");
            win_obj.close();
        }
    }

    /**
     * [form_change Form Change callback]
     * @param  {[type]} name [item name]
     */
    dealClose.form_change = function(name, value) {
        var show_per = '<?php echo $show_per; ?>';
        var floating_volume = '<?php echo $floating_volume; ?>';
        
        if (name == 'vol_per') {
            var volume = ((floating_volume*value)/100);
            dealClose.form.setItemValue("floating_volume", volume);
        } else if (name == 'floating_volume') {
            var percentage = (value/floating_volume) * 100;
            dealClose.form.setItemValue("vol_per", percentage);
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