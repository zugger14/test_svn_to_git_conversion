<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
    <?php require('../../../adiha.html.forms/_setup/manage_documents/manage.documents.button.php'); ?>
</head>
<body>
<?php 
	$form_namespace = 'dealStatus';
    $deal_ids = (isset($_POST["deal_ids"]) && $_POST["deal_ids"] != '') ? get_sanitized_value($_POST["deal_ids"]) : 'NULL';

	$layout_json = '[{id: "a", header:false}]';
	$toolbar_json = '[{id:"ok", type:"button", img: "tick.gif", img_disabled: "tick_dis.gif", text:"Ok", title: "Ok"},
                      {id:"cancel", type:"button", img: "close.gif", img_disabled: "close_dis.gif", text:"Cancel", title: "Cancel"}]';
    $layout_obj = new AdihaLayout();
    $form_obj = new AdihaForm();
    $toolbar_obj = new AdihaToolbar();

    $sp_url = "EXEC spa_StaticDataValues @flag='h', @type_id=5600";
    $deal_status_json = $form_obj->adiha_form_dropdown($sp_url, 0, 1, true, '', 2);

    $form_json = '[{type: "settings", position: "label-top", offsetLeft:20, inputWidth:250},
    			   {type:"combo", "validate":"NotEmptywithSpace,ValidInteger", "userdata":{"validation_message":"Required Field"}, name:"deal_status", "options": ' . $deal_status_json . ' ,label:"Deal Status", rows:10, required:true, note:{text:"Deal staus for the selected deal(s) will be changed when you click \'OK\'"}}
    			  ]';
    echo $layout_obj->init_layout('deal_status_layout', '', '1C', $layout_json, $form_namespace);
    echo $layout_obj->attach_form('deal_status_form', 'a');
    echo $layout_obj->attach_toolbar_cell('toolbar', 'a');
    echo $toolbar_obj->init_by_attach('toolbar', $form_namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', $form_namespace . '.toolbar_click');
    echo $form_obj->init_by_attach('deal_status_form', $form_namespace);
    echo $form_obj->load_form($form_json);
    echo $layout_obj->close_layout();

    $category_name = 'Deal Status';
    $category_sql = "SELECT value_id FROM static_data_value WHERE type_id = 25 AND code = '" . $category_name . "'";
    $category_data = readXMLURL2($category_sql);
?>
</body>
<textarea style="display:none" name="success_status" id="success_status"></textarea>
<script type="text/javascript">
    var category_id = '<?php echo $category_data[0]['value_id'] ?? '';?>';
    var object_id = '<?php echo $deal_ids;?>';

    $(function() {
        dealStatus.deal_status_form.enableLiveValidation(true);
        dhxWins = new dhtmlXWindows();

        has_rights_deal_status_document = 1;
        toolbar_obj = dealStatus.toolbar;
        //add_manage_document_button(object_id, toolbar_obj, has_rights_deal_status_document);
    })

    /**
     * [toolbar_click Deal Status toolbar clicked.]
     * @param  {[string]} id [Menu Id]
     */
    dealStatus.toolbar_click = function(id) {
        switch(id) {
            case "ok":
                var status = validate_form(dealStatus.deal_status_form);
                
                if (status) {
                    var deal_status = dealStatus.deal_status_form.getItemValue("deal_status");
                    var deal_ids = '<?php echo $deal_ids;?>';
                    data = {"action": "spa_source_deal_header", "flag":"m", "deal_status":deal_status, "deal_ids":deal_ids};
                    adiha_post_data("alert", data, '', '', 'dealStatus.deal_status_callback');
                }
                break;
            case "cancel":
                document.getElementById("success_status").value = 'cancel';
                var win_obj = window.parent.status_window.window("w1");
                win_obj.close();
                break;
            case "documents":
                dealStatus.open_document();
                break;
        }
    }

    dealStatus.open_document = function() {
        param = '../../_setup/manage_documents/manage.documents.php?notes_category=' + category_id + '&notes_object_id=' + object_id + '&is_pop=true';
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
            update_document_counter(object_id, toolbar_object);
            return true;
        });
    }

    /**
     * [deal_status_callback Deal status update callback]
     * @param  {[array]} result [result array]
     */
    dealStatus.deal_status_callback = function(result) {
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