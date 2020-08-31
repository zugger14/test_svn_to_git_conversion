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
	$form_namespace = 'confirmStatus';
    $deal_ids = (isset($_POST["deal_ids"]) && $_POST["deal_ids"] != '') ? get_sanitized_value($_POST["deal_ids"]) : 'NULL';

	$layout_json = '[{id: "a", header:false}]';
	$toolbar_json = '[{id:"ok", type:"button", img: "save.gif", img_disabled: "save_dis.gif", text:"Ok", title: "Ok"},
                      {id:"cancel", type:"button", img: "close.gif", img_disabled: "close_dis.gif", text:"Cancel", title: "Cancel"}]';
    $layout_obj = new AdihaLayout();
    $form_obj = new AdihaForm();
    $toolbar_obj = new AdihaToolbar();

    $sp_url = "EXEC('Select value_id, code FROM static_data_value where type_id = 17200')";
    $confirm_status_json = $form_obj->adiha_form_dropdown($sp_url, 0, 1, true);

    $form_json = '[{"type": "settings", position: "label-top", inputWidth:150, labelWidth:150},
    			   {"type": "block", blockOffset: 20, width:"auto", list: [
                       {"type":"combo", "validate":"NotEmptywithSpace,ValidInteger", "userdata":{"validation_message":"Required Field"}, name:"confirm_status", "options": ' . $confirm_status_json . ' ,label:"Confirm Status", required:true},
                       {"type": "newcolumn", offset:20},
                       {"type": "calendar", "validate":"NotEmptywithSpace", required:true, "userdata":{"validation_message":"Required Field"}, "dateFormat":"' . $date_format . '", "serverDateFormat": "%Y-%m-%d", "name": "as_of_date", "label": "As of Date", "enableTime": false, "calendarPosition": "bottom"},
        			   {"type": "newcolumn", offset:20},
                       {"type":"input", "name":"confirm_id", "label": "Confirm ID"}
                   ]},
                   {"type": "block", blockOffset: 20, list: [
                        {"type":"input", "rows":3, "name":"comment1", "label": "Comment1", inputWidth:500, labelWidth:500},
                        {"type":"input", "rows":3, "name":"comment2", "label": "Comment2", inputWidth:500, labelWidth:500, note:{text:"Confirm staus for all the selected deal(s) will be changed when you click \'OK\'"}}
                    ]}
                  ]';
    echo $layout_obj->init_layout('confirm_status_layout', '', '1C', $layout_json, $form_namespace);
    echo $layout_obj->attach_form('confirm_status_form', 'a');
    echo $layout_obj->attach_toolbar_cell('toolbar', 'a');
    echo $toolbar_obj->init_by_attach('toolbar', $form_namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', $form_namespace . '.toolbar_click');
    echo $form_obj->init_by_attach('confirm_status_form', $form_namespace);
    echo $form_obj->load_form($form_json);
    echo $layout_obj->close_layout();
?>
</body>
<textarea style="display:none" name="success_status" id="success_status"></textarea>
<script type="text/javascript">
    $(function() {
        confirmStatus.confirm_status_form.enableLiveValidation(true);
    })

    /**
     * [toolbar_click Deal Status toolbar clicked.]
     * @param  {[string]} id [Menu Id]
     */
    confirmStatus.toolbar_click = function(id) {
        switch(id) {
            case "ok":
                var status = validate_form(confirmStatus.confirm_status_form);

                if (status) {
                    var confirm_status = confirmStatus.confirm_status_form.getItemValue("confirm_status");
                    var as_of_date = confirmStatus.confirm_status_form.getItemValue("as_of_date", true);
                    var confirm_id = confirmStatus.confirm_status_form.getItemValue("confirm_id");
                    var comment1 = confirmStatus.confirm_status_form.getItemValue("comment1");
                    var comment2 = confirmStatus.confirm_status_form.getItemValue("comment2");
                    var deal_ids = '<?php echo $deal_ids;?>';

                    form_xml = '<Root><FormXML deal_ids="' + deal_ids + '" confirm_status="' + confirm_status + '" as_of_date="' + as_of_date + '" confirm_id="' + confirm_id + '" comment1="' + comment1 + '" comment2="' + comment1 + '"></FormXML></Root>';
                    data = {"action": "spa_confirm_status", "flag":"x", "xml":form_xml};
                    adiha_post_data("alert", data, '', '', 'confirmStatus.confirm_status_callback');
                }
                break;
            case "cancel":
                document.getElementById("success_status").value = 'cancel';
                var win_obj = window.parent.status_window.window("w1");
                win_obj.close();
                break;
        }
    }

    /**
     * [confirm_status_callback Deal status update callback]
     * @param  {[array]} result [result array]
     */
    confirmStatus.confirm_status_callback = function(result) {
        if (result[0].errorcode == 'Success') {
            document.getElementById("success_status").value = 'Success';
            var win_obj = window.parent.status_window.window("w1");
            win_obj.close();
        } else {
            document.getElementById("success_status").value = 'error';
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