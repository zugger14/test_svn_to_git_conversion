<?php
/**
* Efp trigger screen
* @copyright Pioneer Solutions
*/
?>
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
    $form_namespace = 'efpTrigger';
    $detail_id = (isset($_POST["detail_id"]) && $_POST["detail_id"] != '') ? get_sanitized_value($_POST["detail_id"]) : '';
    $type = (isset($_POST["type"]) && $_POST["type"] != '') ? get_sanitized_value($_POST["type"]) : '';
    $show_per = ($type == 't') ? 'false' : 'true';

    if ($type == 'e') {
        $floating_volume_disable = ", disabled:true";
    } else {
        $floating_volume_disable = "";
    }
    
    $sp_term = "EXEC spa_efp_trigger @flag='" . $type . "', @detail_id='" . $detail_id . "'";
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
                   {"type": "calendar", "validate":"NotEmptywithSpace", required:true, "userdata":{"validation_message":"Required Field"}, "dateFormat":"' . $date_format . '", "serverDateFormat": "%Y-%m-%d", "name": "as_of_date", "label": "' . $label . ' Date", "enableTime": false, "calendarPosition": "bottom", "value":"' . $post_date . '"},
                   {"type": "input", "name":"post_price",  required:true, "label": "' . $label . ' Price", value:"' . $price . '", numberFormat:"' . $GLOBAL_PRICE_FORMAT . '"},
                   {"type":"newcolumn"},
                   {"type": "calendar", disabled:true, "validate":"NotEmptywithSpace", "userdata":{"validation_message":"Required Field"}, "dateFormat":"' . $date_format . '", "serverDateFormat": "%Y-%m-%d", "name": "term_end", "label": "Term End", "enableTime": false, "calendarPosition": "bottom", "value":"' . $term_end . '"},
                   {"type": "input", "validate":"ValidRange", "name":"floating_volume",  required:true, "label": "' . $label . ' Volume", value:"' . $floating_volume . '", numberFormat:"' . $GLOBAL_NUMBER_FORMAT . '" ' . $floating_volume_disable . '},
                   {"type": "input", "name":"vol_per", "validate":"ValidPercentage", required:true, "hidden":' . $show_per .', "label": "' . $label . ' %", value:"100", numberFormat:"0.00%"},
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
    
    function ValidPercentage(data) {
        return (data<=100);
    }
    function ValidRange(data) {
        var floating_volume = <?php echo $floating_volume;?>;
        return (data>0 && data<=floating_volume);
    }

    $(function() {
        efpTrigger.form.enableLiveValidation(true);

        efpTrigger.form.attachEvent("onValidateSuccess", function(name, value){
           efpTrigger.form.setNote(name,{text:""});
           efpTrigger.toolbar.enableItem('ok');
        });

        efpTrigger.form.attachEvent("onValidateError", function (name, value, result){    
            if (name == 'floating_volume') {      
                var floating_volume = '<?php echo $floating_volume;?>';
                var val = (name == 'vol_per') ? '100' : floating_volume;
                var message = 'Insufficient floating volume. Remaining floating volume: ' + val;
                efpTrigger.form.setNote(name, {text:message,width:150});
                efpTrigger.toolbar.disableItem('ok');
            } else if(name == 'vol_per') {
                var message = 'Invalid data. Value can be less than or equal to 100.';
                efpTrigger.form.setNote(name, {text:message,width:150});
                efpTrigger.toolbar.disableItem('ok');
            }           
        });
    })

    /**
     * [toolbar_click Deal Status toolbar clicked.]
     * @param  {[string]} id [Menu Id]
     */
    efpTrigger.toolbar_click = function(id) {
        switch(id) {
            case "ok":
                var status = validate_form(efpTrigger.form);
                if (status) {
                    var detail_id = '<?php echo $detail_id; ?>';
                    var post_date = efpTrigger.form.getItemValue("as_of_date", true);
                    var floating_volume = efpTrigger.form.getItemValue("floating_volume");
                    var post_price = efpTrigger.form.getItemValue("post_price");
                    var flag = (type == 'e') ? 'm' : 'n';

                    data = {"action": "spa_efp_trigger", "flag":flag, "detail_id":detail_id, "floating_volume":floating_volume, "fixed_price":post_price, "post_date":post_date};
                    adiha_post_data("alert", data, '', '', 'efpTrigger.save_callback');
                    
                }
                break;
            case "cancel":
                document.getElementById("txt_status").value = 'cancel';
                var win_obj = window.parent.efp_trigger_window.window("w1");
                win_obj.close();
                break;
        }
    }


    efpTrigger.save_callback = function(result) {
        if (result[0].errorcode == 'Success') {
            document.getElementById("txt_status").value = 'Success';
            var win_obj = window.parent.efp_trigger_window.window("w1");
            efpTrigger.toolbar.disableItem('ok');
            setTimeout(function() {
                win_obj.close();
            }, 1000);
        }
    }

    /**
     * [form_change Form Change callback]
     * @param  {[type]} name [item name]
     */
    efpTrigger.form_change = function(name, value) {
        var show_per = '<?php echo $show_per; ?>';
        var floating_volume = '<?php echo $floating_volume; ?>';
        
        if (show_per == 'false') {
            if (name == 'vol_per') {
                var volume = ((floating_volume*value)/100);
                efpTrigger.form.setItemValue("floating_volume", volume);
            } else if (name == 'floating_volume') {
                var percentage = (value/floating_volume) * 100;
                efpTrigger.form.setItemValue("vol_per", percentage);
            }
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