<?php
/**
* Workflow approval comment screen
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
    $call_from = get_sanitized_value($_REQUEST['call_from'] ?? '');
    $is_require = ($call_from == "approval_click") ? "true" : "false";
    $approved = get_sanitized_value($_REQUEST['approved'] ?? '');
    $pre_comment = get_sanitized_value($_REQUEST['pre_comment'] ?? '');
	$form_namespace = 'approvalComment';
	$layout_json = '[{id: "a", header:false}]';
	$toolbar_json = '[{id:"ok", type:"button", img: "save.gif", img_disabled: "save_dis.gif", text:"Ok", title: "Ok"},
                      {id:"cancel", type:"button", img: "close.gif", img_disabled: "close_dis.gif", text:"Cancel", title: "Cancel"}]';
    $layout_obj = new AdihaLayout();
    $form_obj = new AdihaForm();
    $toolbar_obj = new AdihaToolbar();


    $form_json = '[{type: "settings", position: "label-top", offsetLeft:20, inputWidth:500},
    			   {type:"input", name:"comment", label:"Please enter comments", rows:10,required:"' . $is_require . '", value:"'. $pre_comment . '"}
    			  ]';
    echo $layout_obj->init_layout('approval_layout', '', '1C', $layout_json, $form_namespace);
    echo $layout_obj->attach_form('approval_comment_form', 'a');
    echo $layout_obj->attach_toolbar_cell('toolbar', 'a');
    echo $toolbar_obj->init_by_attach('toolbar', $form_namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', $form_namespace . '.toolbar_click');
    echo $form_obj->init_by_attach('approval_comment_form', $form_namespace);
    echo $form_obj->load_form($form_json);
    echo $layout_obj->close_layout();
?>
</body>
<textarea style="display:none" name="action_status" id="action_status"></textarea>
<textarea style="display:none" name="action_comments" id="action_comments"></textarea>
<script type="text/javascript">
	document.getElementById("action_status").value = 'cancel';
    approvalComment.toolbar_click = function(id) {		
        switch(id) {
            case "ok":
                var comments = approvalComment.approval_comment_form.getItemValue("comment");
                document.getElementById("action_comments").value = comments;
                
                if('<?php echo $call_from;?>' =='approval_click') {
                    var status = validate_form(approvalComment.approval_comment_form);
                    if(status) {
                        parent.save_comment_fromapprove_window('<?php echo $approved;?>', comments);   
                        document.getElementById("action_status").value = '';
                    }
                    else {
                        generate_error_message();
                        return;
                    }
                } else {
                    document.getElementById("action_status").value = 'ok'; 
                }     
                
                break;
            case "cancel":
                document.getElementById("action_status").value = 'cancel';
                document.getElementById("action_comments").value = '';
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