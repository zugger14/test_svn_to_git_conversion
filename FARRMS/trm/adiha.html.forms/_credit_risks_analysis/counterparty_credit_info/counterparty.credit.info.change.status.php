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
	$form_namespace = 'CollateralStatus';
    $enhancement_id = get_sanitized_value($_GET['enhancement_id'] ?? 'NULL');  		
	$layout_json = '[{id: "a", header:false}]';
	$toolbar_json = '[{id:"ok", type:"button", img: "tick.gif", img_disabled: "tick_dis.gif", text:"Ok", title: "Ok"},
                      {id:"cancel", type:"button", img: "close.gif", img_disabled: "close_dis.gif", text:"Cancel", title: "Cancel"}]';
    $layout_obj = new AdihaLayout();
    $form_obj = new AdihaForm();
    $toolbar_obj = new AdihaToolbar();

    $sp_url = "EXEC spa_StaticDataValues @flag='h', @type_id=105200";
    $deal_status_json = $form_obj->adiha_form_dropdown($sp_url, 0, 1, true, '', 2);

    $form_json = '[{type: "settings", position: "label-top", offsetLeft:20, inputWidth:250},
    			   {type:"combo", "validate":"NotEmptywithSpace,ValidInteger", "userdata":{"validation_message":"Required Field"}, name:"collateral_status", "options": ' . $deal_status_json . ' ,label:"Collateral Status", rows:10, required:true, note:{text:"Collateral staus for the selected enhancement(s) will be changed when you click \'OK\'"}}
    			  ]';
    echo $layout_obj->init_layout('CollateralStatus_layout', '', '1C', $layout_json, $form_namespace);
    echo $layout_obj->attach_form('CollateralStatus_form', 'a');
    echo $layout_obj->attach_toolbar_cell('toolbar', 'a');
    echo $toolbar_obj->init_by_attach('toolbar', $form_namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', $form_namespace . '.toolbar_click');
    echo $form_obj->init_by_attach('CollateralStatus_form', $form_namespace);
    echo $form_obj->load_form($form_json);
    echo $layout_obj->close_layout();

    $category_name = 'Collateral Status';
    $category_sql = "SELECT value_id FROM static_data_value WHERE type_id = 25 AND code = '" . $category_name . "'";
    $category_data = readXMLURL2($category_sql);
?>
</body>
<textarea style="display:none" name="success_status" id="success_status"></textarea>
<script type="text/javascript">
    var category_id = '<?php echo $category_data[0]['value_id'] ?? '';?>';
    var object_id = '<?php echo $enhancement_id;?>';
		
    $(function() {
		CollateralStatus.CollateralStatus_form.enableLiveValidation(true);
        dhxWins = new dhtmlXWindows();

        toolbar_obj = CollateralStatus.toolbar;
    })

    /**
     * [toolbar_click Deal Status toolbar clicked.]
     * @param  {[string]} id [Menu Id]
     */
    CollateralStatus.toolbar_click = function(id) {
        switch(id) {
            case "ok":
		        var status = validate_form(CollateralStatus.CollateralStatus_form);                
                if (status) {
                    var collateral_status = CollateralStatus.CollateralStatus_form.getItemValue("collateral_status");
                    var counterparty_credit_enhancement_id = '<?php echo $enhancement_id;?>';									
				    data = {"action": "spa_counterparty_credit_enhancements", "flag":"u", "collateral":collateral_status, "counterparty_credit_enhancement_id":counterparty_credit_enhancement_id};
                    adiha_post_data("alert", data, '', '', 'CollateralStatus.status_callback');
                }
                break;
            case "cancel":
                document.getElementById("success_status").value = 'cancel';				
                window.parent.change_satatus_win.close();				
                break;
            }
    }

    /**
     * [deal_status_callback Deal status update callback]
     * @param  {[array]} result [result array]
     */
    CollateralStatus.status_callback = function(result) {
	    if (result[0].errorcode == 'Success') {
            document.getElementById("success_status").value = 'Success';			
		    window.parent.change_satatus_win.close();			
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