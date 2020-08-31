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
	$form_namespace = 'dealDeleteComment';
    $source_deal_id = isset($_REQUEST['source_deal_id']) ? get_sanitized_value($_REQUEST['source_deal_id']) : 'NULL';
    $sql_request = "EXEC spa_source_deal_header @flag='h',@deal_ids='$source_deal_id'";
    $return_value = readXMLURL($sql_request);
    $is_mandatory = ($return_value[0][0] == 1) ? 'true' : 'false';

	$layout_json = '[{id: "a", header:false}]';
	$toolbar_json = '[{id:"ok", type:"button", img: "tick.png", img_disabled: "tick_dis.png", text:"Ok", title: "Ok"},
                      {id:"cancel", type:"button", img: "close.gif", img_disabled: "close_dis.gif", text:"Cancel", title: "Cancel", hidden: true}]';
    $layout_obj = new AdihaLayout();
    $form_obj = new AdihaForm();
    $toolbar_obj = new AdihaToolbar();


    $form_json = '[{type: "settings", position: "label-top", offsetLeft:20, inputWidth:500},
    			   {type:"input", name:"comment", label:"Please enter comments for deleting the deal(s).", rows:10,required:"' . $is_mandatory . '",note:{text:"The selected deal(s) will be deleted when you click \'OK\'"}}
    			  ]';
    echo $layout_obj->init_layout('deal_delete_layout', '', '1C', $layout_json, $form_namespace);
    echo $layout_obj->attach_form('delete_comment_form', 'a');
    echo $layout_obj->attach_toolbar_cell('toolbar', 'a');
    echo $toolbar_obj->init_by_attach('toolbar', $form_namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', $form_namespace . '.toolbar_click');
    echo $form_obj->init_by_attach('delete_comment_form', $form_namespace);
    echo $form_obj->load_form($form_json);
    echo $layout_obj->close_layout();
?>
</body>
<textarea style="display:none" name="delete_status" id="delete_status"></textarea>
<textarea style="display:none" name="delete_comments" id="delete_comments"></textarea>
<script type="text/javascript">
	document.getElementById("delete_status").value = 'cancel';
    dealDeleteComment.toolbar_click = function(id) {		
        switch(id) {
            case "ok":
                var comments = dealDeleteComment.delete_comment_form.getItemValue("comment");

                var validate_return = validate_form(dealDeleteComment.delete_comment_form);
            
                if (validate_return === false) {
                    dealDeleteComment.delete_comment_form.setNote('comment', {text: "Required field.", width:500});
                    return;
                    
                }

                document.getElementById("delete_status").value = 'ok';
                document.getElementById("delete_comments").value = comments;               
                break;
            case "cancel":
                document.getElementById("delete_status").value = 'cancel';
                document.getElementById("delete_comments").value = '';
                break;
        }
        var win_obj = window.parent.comment_window.window("w1");
        win_obj.close();
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