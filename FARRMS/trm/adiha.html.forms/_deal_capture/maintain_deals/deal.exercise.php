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
    $form_namespace = 'dealExercise';
    $deal_id = (isset($_POST["deal_id"]) && $_POST["deal_id"] != '') ? get_sanitized_value($_POST["deal_id"]) : 'NULL';
	$detail_id = (isset($_POST["detail_id"]) && $_POST["detail_id"] != '') ? get_sanitized_value($_POST["detail_id"]) : 'NULL';
	$group_id = (isset($_POST["group_id"]) && $_POST["group_id"] != '') ? get_sanitized_value($_POST["group_id"]) : 'NULL';
    $term_start = (isset($_POST["term_start"]) && $_POST["term_start"] != '') ? get_sanitized_value($_POST["term_start"]) : '';
    $term_end = (isset($_POST["term_end"]) && $_POST["term_end"] != '') ? get_sanitized_value($_POST["term_end"]) : '';
	
	$sp_exp_term = "EXEC spa_deal_exercise_detail @flag='e', @source_deal_detail_id=" . $detail_id . ", @source_deal_header_id=" . $deal_id . " ,@source_deal_group_id=" . $group_id;
	$data = readXMLURL2($sp_exp_term);
	$exercise_date = $data[0]['exercise_date'];
    
    $layout_json = '[{id: "a", header:false}]';
    $toolbar_json = '[{id:"ok", type:"button", img: "save.gif", img_disabled: "save_dis.gif", text:"Ok", title: "Ok"},
                      {id:"cancel", type:"button", img: "close.gif", img_disabled: "close_dis.gif", text:"Cancel", title: "Cancel"}]';
    $layout_obj = new AdihaLayout();
    $form_obj = new AdihaForm();
    $toolbar_obj = new AdihaToolbar();

    $form_json = '[{type: "settings", position: "label-top", offsetLeft:20, inputWidth:150},
                   {"type": "calendar", "validate":"NotEmptywithSpace", required:true, "userdata":{"validation_message":"Required Field"}, "dateFormat":"' . $date_format . '", "serverDateFormat": "%Y-%m-%d", "name": "term_start", "label": "Term Start", "enableTime": false, "calendarPosition": "bottom", "value":"' . $term_start . '"},
				   {"type": "calendar", "validate":"NotEmptywithSpace", required:true, "userdata":{"validation_message":"Required Field"}, "dateFormat":"' . $date_format . '", "serverDateFormat": "%Y-%m-%d", "name": "exercise_date", "label": "Exercise Date", "enableTime": false, "calendarPosition": "bottom", "value":"' . $exercise_date . '"},
                   {"type":"newcolumn"},
                   {"type": "calendar", "validate":"NotEmptywithSpace", required:true, "userdata":{"validation_message":"Required Field"}, "dateFormat":"' . $date_format . '", "serverDateFormat": "%Y-%m-%d", "name": "term_end", "label": "Term End", "enableTime": false, "calendarPosition": "bottom", "value":"' . $term_end . '"}
                  ]';
    echo $layout_obj->init_layout('layout', '', '1C', $layout_json, $form_namespace);
    echo $layout_obj->attach_form('term_form', 'a');
    echo $layout_obj->attach_toolbar_cell('toolbar', 'a');
    echo $toolbar_obj->init_by_attach('toolbar', $form_namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', $form_namespace . '.toolbar_click');
    
    echo $form_obj->init_by_attach('term_form', $form_namespace);
    echo $form_obj->load_form($form_json);
    echo $form_obj->attach_event('', 'onChange', $form_namespace . '.form_change');
    echo $layout_obj->close_layout();
?>
</body>
<textarea style="display:none" name="txt_btn_click" id="txt_btn_click"></textarea>
<script type="text/javascript">
    /**
     * [toolbar_click Deal Status toolbar clicked.]
     * @param  {[string]} id [Menu Id]
     */
    dealExercise.toolbar_click = function(id) {
        switch(id) {
            case "ok":
                var status = validate_form(dealExercise.term_form);
                if (status) {
                    var term_start = dealExercise.term_form.getItemValue("term_start", true);
                    var term_end = dealExercise.term_form.getItemValue("term_end", true);
					var exercise_date = dealExercise.term_form.getItemValue("exercise_date", true);
					var deal_id = '<?php echo $deal_id;?>';
					var detail_id = '<?php echo $detail_id;?>';
                    var group_id = '<?php echo $group_id;?>';
					
					data = {
							"action": "spa_deal_exercise_detail", 
							"flag":"i", 
							"source_deal_detail_id":detail_id, 
							"source_deal_header_id":deal_id, 
							"source_deal_group_id":group_id,
							"term_start":term_start,
							"term_end":term_end,
							"exercise_date":exercise_date
							};
					adiha_post_data("alert", data, '', '', 'dealExercise.exercise_callback');
                }
                break;
            case "cancel":
                document.getElementById("txt_btn_click").value = 'cancel';
                var win_obj = window.parent.term_window.window("w1");
                win_obj.close();
                break;
        }
    }
	
	dealExercise.exercise_callback = function(result) {
		if (result[0].errorcode == 'Success') {
			document.getElementById("txt_btn_click").value = 'ok';
			var ret_val = result[0].recommendation;
			var return_index = ret_val.indexOf("GRP-"); 
			if (return_index != -1) {
				var group_id = ret_val.replace("GRP-", "");
				window.parent.dealDetail.refresh_efp_trigger('NULL', group_id);
			} else {				
				window.parent.dealDetail.refresh_efp_trigger(result[0].recommendation, 'NULL');
			}
			var win_obj = window.parent.exercise_window.window("w1");
			win_obj.close();
        }
	}

    /**
     * [form_change Form Change callback]
     * @param  {[type]} name [item name]
     */
    dealExercise.form_change = function(name, value) {
        var term_start = dealExercise.term_form.getItemValue("term_start", true);
        var term_end = dealExercise.term_form.getItemValue("term_end", true);
		var min_max_val = (name == 'term_start') ? term_end : term_start;
		
        if (dates.compare(term_end, term_start) == -1) {
            if (name == 'term_start') {
                var message = 'Term Start cannot be less than Term End.';
            } else {
                var message = 'Term End cannot be greater than Term Start.';
            }
            dealExercise.show_error(message, name, min_max_val);
            return;
        }
    }

    /**
     * [show_error Show Error]
     * @param  {[string]} message     [Message]
     * @param  {[string]} name        [Item name]
     * @param  {[date]} min_max_val   [Date]
     */
    dealExercise.show_error = function(message, name, min_max_val) {
        dhtmlx.alert({
            title:"Error",
            type:"alert-error",
            text:message,
            callback: function(result){
                dealExercise.term_form.setItemValue(name, min_max_val);
            }
        });
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