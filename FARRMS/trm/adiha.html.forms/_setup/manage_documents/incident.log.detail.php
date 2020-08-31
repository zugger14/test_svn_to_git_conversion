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
	$incident_log_id = get_sanitized_value($_REQUEST['incident_log_id'] ?? ''); 
	$incident_log_detail_id = get_sanitized_value($_REQUEST['incident_log_detail_id'] ?? '');
	$call_from = get_sanitized_value($_REQUEST['call_from'] ?? ''); 
	$category_id = get_sanitized_value($_REQUEST['category_id'] ?? ''); 
	$param = '?call_from=manage_document&category_id=' . $category_id;
	
	if ($incident_log_detail_id != '') {
        $sql = "EXEC spa_incident_log @flag='p', @incident_log_detail_id= " . $incident_log_detail_id;
        $incident_detail_data = readXMLURL2($sql);
        $incident_status = $incident_detail_data[0]['incident_status'];
        $incident_update_date = $incident_detail_data[0]['incident_update_date'];
		$comments = $incident_detail_data[0]['comments'];
		$notes_attachment = $incident_detail_data[0]['notes_attachment'];
		$attachment_file_name = $incident_detail_data[0]['attachment_file_name'];
    } else {
		$incident_status = '';
        $incident_update_date = '';
		$comments = '';
		$notes_attachment = '';
		$attachment_file_name = '';
	}
	
	$form_namespace = 'incident_log_detail';
    
	$layout_json = '[{id: "a", header:false}]';
	$toolbar_json = '[{id:"ok", type:"button", img: "tick.gif", img_disabled: "tick_dis.gif", text:"Ok", title: "Ok"}
                     ]';
    $layout_obj = new AdihaLayout();
    $form_obj = new AdihaForm();
    $toolbar_obj = new AdihaToolbar();

    $sp_url = "EXEC('Select value_id, code FROM static_data_value where type_id = 45800')";
    $incident_status_json = $form_obj->adiha_form_dropdown($sp_url, 0, 1, true);

    $form_json = '[{"type": "settings", position: "label-top", inputWidth:190, labelWidth:190},
    			   {"type": "block", blockOffset: 20, width:"auto", list: [
                       {"type":"combo", "validate":"NotEmptywithSpace,ValidInteger", "userdata":{"validation_message":"Required Field"}, name:"incident_status", "options": ' . $incident_status_json . ' ,label:"Incident Status", required:true},
                       {"type": "newcolumn", offset:20},
                       {"type": "calendar", "validate":"NotEmptywithSpace", required:true, "userdata":{"validation_message":"Required Field"}, "dateFormat":"' . $date_format . '", "serverDateFormat": "%Y-%m-%d", "name": "date", "label": "Date", "enableTime": false, "calendarPosition": "bottom"},
                   ]},
                   {"type": "block", blockOffset: 20, list: [
                        {"type":"input", "rows":5, "name":"comment", "label": "Comment", inputWidth:400, labelWidth:400}
                    ]},';
	
					
	$form_json = $form_json . "{type: 'block', blockOffset:20, list: [
										{type: 'fieldset', inputWidth:400, label: 'File Attachment', list:[
											{type: 'upload', name: 'upload', inputWidth:360, url:'" . $app_adiha_loc . "adiha.html.forms/_setup/manage_documents/file_uploader.php" . $param . "', autoStart:true}
										]},
										{type: 'newcolumn'},
										{type: 'hidden', value:'', name:'file_attachment'},									
								]},
								{type: 'block', blockOffset:20, list: [
									{type: 'label', inputWidth:580, label: 'Current Attached File(s): current_attached_file', hidden: true, offsetTop: 0, className: 'current_attached'}
								]}
							  ]";
	if($incident_log_detail_id != '') {
        $download_url = $app_adiha_loc . 'adiha.html.forms/_setup/manage_documents/force_download.php';
        $attached_file_link = '<a href="' . $download_url . '?path=' . $notes_attachment . '" download>' . $attachment_file_name . '</a>';
        $form_json = str_replace("current_attached_file', hidden: true", $attached_file_link."', hidden: false", $form_json);
    }
    echo $layout_obj->init_layout('incident_log_detail_layout', '', '1C', $layout_json, $form_namespace);
    echo $layout_obj->attach_form('incident_log_detail_form', 'a');
    echo $layout_obj->attach_toolbar_cell('toolbar', 'a');
    echo $toolbar_obj->init_by_attach('toolbar', $form_namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', $form_namespace . '.toolbar_click');
    echo $form_obj->init_by_attach('incident_log_detail_form', $form_namespace);
    echo $form_obj->load_form($form_json);
	echo $form_obj->attach_event('', 'onUploadFile', 'upload_doc');
	echo $form_obj->attach_event('', 'onFileRemove', 'remove_doc');
    echo $layout_obj->close_layout();
?>
</body>
<textarea style="display:none" name="success_status" id="success_status"></textarea>
<script type="text/javascript">
    $(function() {
        incident_log_detail.incident_log_detail_form.enableLiveValidation(true);
		var incident_status = '<?php echo $incident_status; ?>';
		var incident_update_date = '<?php echo $incident_update_date; ?>';
		var comments = '<?php echo $comments; ?>';
				
		var today = new Date();
		var today_default = dates.convert_to_sql(today);
		
		incident_log_detail.incident_log_detail_form.setItemValue('incident_status', incident_status);
		incident_log_detail.incident_log_detail_form.setItemValue('date', incident_update_date);
		incident_log_detail.incident_log_detail_form.setItemValue('comment', comments);
    
	if (incident_status == ''){
		var dhxCombo = incident_log_detail.incident_log_detail_form.getCombo('incident_status');
		dhxCombo.selectOption(1);
	}
	
	if (incident_update_date == ''){
		incident_log_detail.incident_log_detail_form.setItemValue('date', today_default);
	}
	
	})

    /**
     * [toolbar_click Deal Status toolbar clicked.]
     * @param  {[string]} id [Menu Id]
     */
    incident_log_detail.toolbar_click = function(id) {
        switch(id) {
            case "ok":
				var status = validate_form(incident_log_detail.incident_log_detail_form);
				
                if (status) {
					var file_attachment = incident_log_detail.incident_log_detail_form.getItemValue('file_attachment');
					if(file_attachment.indexOf(',') >= 0) {
						dhtmlx.alert({
							title:"Error!",
							type:"alert-error",
							text:'Please upload only 1 file.'
						});
						return;
					}
					
					var incident_log_id = '<?php echo $incident_log_id; ?>';
					var incident_log_detail_id = '<?php echo $incident_log_detail_id; ?>';
					var incident_status = incident_log_detail.incident_log_detail_form.getItemValue("incident_status");
					var date = incident_log_detail.incident_log_detail_form.getItemValue("date",true);
					var comment = incident_log_detail.incident_log_detail_form.getItemValue("comment");
					
					var detail_xml = '<Root><IncidentDetail incident_log_id="' + incident_log_id + '" incident_log_detail_id="' + incident_log_detail_id + '" incident_status="' + incident_status + '" date="' + date + '" comment="' + comment + '" file_attachment="' + file_attachment + '" /></Root>';
                    data = {"action": "spa_incident_log", "flag":"l", "xml_data":detail_xml};
                    adiha_post_data("alert", data, '', '', 'ok_callback');

                }
				
                break;
            case "cancel":
				var win_obj = parent.incident_log_detail_window.window("w1");
                win_obj.close();
				break;
        }
    }
	
	ok_callback = function (){
		var incident_log_id = '<?php echo $incident_log_id; ?>';
		var incident_status = incident_log_detail.incident_log_detail_form.getItemValue("incident_status");
		parent.incident_log_detail_callback(incident_status,incident_log_id);
		var win_obj = parent.incident_log_detail_window.window("w1");
        win_obj.close();
	}

	upload_doc = function(realName,serverName) {
		var get_pre_name = incident_log_detail.incident_log_detail_form.getItemValue('file_attachment');

		if (get_pre_name == '') {
			final_name = serverName;
		} else {
			final_name = get_pre_name + ', ' + serverName;
		}
		
		incident_log_detail.incident_log_detail_form.setItemValue('file_attachment', final_name);
	}

	/**
	 * [remove_doc Remove document]
	 * @param  {[type]} realName   [description]
	 * @param  {[type]} serverName [description]
	 */
	remove_doc = function(realName,serverName){
		var file_name_list = incident_log_detail.incident_log_detail_form.getItemValue('file_attachment');
		file_name_list = remove_file_name(file_name_list, realName);
		incident_log_detail.incident_log_detail_form.setItemValue('file_attachment', file_name_list);
	}
	
	/**
	 * [remove_file_name Remove file name from list]
	 * @param  {[type]} list  [list]
	 * @param  {[type]} value [matching value]
	 */
	remove_file_name = function(list, value) {
		var elements = list.split(", ");
		var remove_index = elements.indexOf(value);

		elements.splice(remove_index,1);
		var result = elements.join(", ");
		return result;
	}

</script>

</html>