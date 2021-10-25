<?php
/**
* Counterparty contract type screen
* @copyright Pioneer Solutions
*/
?>
<!--DOCTYPE transitional.dtd-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<meta http-equiv="X-UA-Compatible" content="IE=Edge"> 
<html> 
    <?php 
		global $app_adiha_loc;
	    include '../../../adiha.php.scripts/components/include.file.v3.php';
	    
		$category_id = get_sanitized_value($_POST['category_id'] ?? '');
		$sub_category_id = get_sanitized_value($_POST['sub_category_id'] ?? '');
		$contract_id = get_sanitized_value($_POST['contract_id'] ?? '');
		$counterparty_id = get_sanitized_value($_POST['counterparty_id'] ?? '');
		$counterparty_contract_address_id = get_sanitized_value($_POST['counterparty_contract_address_id'] ?? '');
		$notes_object_id = get_sanitized_value($_POST['notes_object_id'] ?? '');
		$parent_object_id = get_sanitized_value($_POST['parent_object_id'] ?? '');
		$counterparty_contract_type_id = get_sanitized_value($_POST['counterparty_contract_type_id'] ?? '');
		$counterparty_contract_type_dropdown_id = get_sanitized_value($_POST['counterparty_contract_type_dropdown_id'] ?? '');
		$description = get_sanitized_value($_POST['description'] ?? '');
		$item_id = get_sanitized_value($_POST['item_id'] ?? '');
		$ammendment_date = get_sanitized_value($_POST['ammendment_date'] ?? '');
		$number = get_sanitized_value($_POST['number'] ?? '');
		$contract_status = get_sanitized_value($_POST['contract_status'] ?? '');
		$contract_status_id = get_sanitized_value($_POST['contract_status_id'] ?? '');
		$param = '?call_from=manage_document&category_id=' . $category_id;
		$param_detail = '&call_from=manage_document&category_id=' . $category_id;


		$contract_counterparty_type_url = "SELECT value_id [value],code [text] FROM static_data_value WHERE type_id = 105800";
	    $result_contract_counterparty_type = readXMLURL2($contract_counterparty_type_url);
	    $json_contract_counterparty_type = json_encode($result_contract_counterparty_type);
		
		$json = '[
	                 {
	                    id:             "a", 
	                    header:         false,
	                    collapse:       false,
						height:			100
					},  
	                {
	                    id:             "b",
	                    text:           "Document",
	                    header:         true,
	                    collapse:       false,
	                    width:          500,
						height:			500
	                } 
	            ]';

	    $namespace = 'counterparty_contract_type';

	    $counterparty_contract_type_layout_obj = new AdihaLayout();
	    echo $counterparty_contract_type_layout_obj->init_layout('counterparty_contract_type_layout', '', '2E', $json, $namespace);

	    $toolbar_json = '[{ id: "save", type: "button", img: "save.gif", imgdis: "save_dis.gif", text: "Save", enabled: 1, title: "Save"}]';   

	    echo $counterparty_contract_type_layout_obj->attach_toolbar('counterparty_contract_type_toolbar');
	    $counterparty_contract_type_toolbar_obj = new AdihaToolbar();
	    echo $counterparty_contract_type_toolbar_obj->init_by_attach('counterparty_contract_type_toolbar', $namespace);
	    echo $counterparty_contract_type_toolbar_obj->load_toolbar($toolbar_json);
	    echo $counterparty_contract_type_toolbar_obj->attach_event('', 'onClick', 'counterparty_contract_type_toolbar_onclick');	

		echo $counterparty_contract_type_layout_obj->attach_form('contract_counterparty_type_form', 'a');
		$form_obj_contract_counterparty_type_obj = new AdihaForm();
		
		$status_sql = "EXEC spa_staticDataValues h, 1900";
        $status_combo = $form_obj_contract_counterparty_type_obj->adiha_form_dropdown($status_sql, 0, 1, true, '', 2);

	    $cpty_contact_type_json = "[	
							{type: 'settings',position:'label-top'},
							{type: 'combo', name: 'counterparty_contract_type', label: 'Contract Type', required:'true', inputWidth:200,offsetLeft:10, options: " . $json_contract_counterparty_type . "},
							{type: 'newcolumn'},
							{type: 'input', name: 'description', label: 'Description',  disabled: 0,  inputWidth:200,offsetLeft:10, },
							{type: 'newcolumn'},
							{type:'calendar', label:'Date', name:'ammendment_date' ,dateFormat:'". $date_format . "', width:" . $ui_settings['field_size'] . ", position: 'label-top', labelWidth: 'auto', offsetLeft: " . $ui_settings['offset_left'] . "},
							{type: 'newcolumn'},
							{type: 'input', name: 'number', label: 'Number',  disabled: 0,  inputWidth:200,offsetLeft:10, },
							{type: 'newcolumn'},
							{type: 'combo', name: 'contract_status', label: 'Status', inputWidth:200,offsetLeft:10, options: " . $status_combo . "},
						]";      

		
	    echo $form_obj_contract_counterparty_type_obj->init_by_attach('contract_counterparty_type_form', $namespace);
	    echo $form_obj_contract_counterparty_type_obj->load_form($cpty_contact_type_json);				

	    $upload_json = "[	
							{type: 'settings',position:'label-top', offsetLeft: 10},
							{type: 'block', blockOffset:0, list: [
								{type: 'fieldset', inputWidth:450, label: 'File Attachment', list:[
									{type: 'upload', name: 'upload', inputWidth:400, url:'" . $app_adiha_loc . "adiha.html.forms/_setup/manage_documents/file_uploader.php" . $param . "', autoStart:true}
								]},
								{type: 'newcolumn'},
								{type: 'hidden', value:'', name:'file_attachment'},									
							]},
							{type: 'block', blockOffset:0, list: [
								{type: 'label', inputWidth:580, label: 'Current Attached File(s): current_attached_file', hidden: true, offsetTop: 0, className: 'current_attached'}
							]}
						]";     

		if($counterparty_contract_type_id != '') {
	        $xml_url = "EXEC spa_counterparty_contract_type @flag='f',@counterparty_contract_type_id=" . $counterparty_contract_type_id;
	        $result_set = readXMLURL2($xml_url);
	        $file_name =  $result_set[0]['attachment_file_name'];
	        $download_url = $app_php_script_loc . 'force_download.php';
	        $attached_file_link = '<a href="' . $download_url . '?path=' . $result_set[0]['notes_attachment'] . '" download>' . $result_set[0]['attachment_file_name'] . '</a>';
	        $upload_json = str_replace("current_attached_file', hidden: true", $attached_file_link."', hidden: false", $upload_json);
	    }

	    echo $counterparty_contract_type_layout_obj->attach_form('upload_form', 'b');
	    $upload_form_obj = new AdihaForm();
	    echo $upload_form_obj->init_by_attach('upload_form', $namespace);
	    echo $upload_form_obj->load_form($upload_json);
		echo $upload_form_obj->attach_event('', 'onUploadFile', 'upload_doc');
		echo $upload_form_obj->attach_event('', 'onFileRemove', 'remove_doc');
		
	    echo $counterparty_contract_type_layout_obj->close_layout();		
    ?>		
    <script type="text/javascript">   
		var param = '<?php echo $param; ?>';
		var param_detail = '<?php echo $param_detail; ?>'; 
    	var category_id = '<?php echo $category_id; ?>';
		if (category_id == 'NULL') category_id = '';
		var sub_category_id = '<?php echo $sub_category_id; ?>';
		if (sub_category_id == 'NULL') sub_category_id = '';
		var notes_object_id = '<?php echo $notes_object_id; ?>';
		if (notes_object_id == 'NULL') notes_object_id = '';
		var parent_object_id = '<?php echo $parent_object_id; ?>';
		if (parent_object_id == 'NULL') parent_object_id = '';
		var item_id = '<?php echo $item_id; ?>';
		var counterparty_contract_type_id = '<?php echo $counterparty_contract_type_id; ?>';
		var counterparty_contract_address_id = '<?php echo $counterparty_contract_address_id; ?>';
		var counterparty_contract_type_dropdown_id = '<?php echo $counterparty_contract_type_dropdown_id; ?>';
		var description = '<?php echo $description; ?>';
		var contract_id = '<?php echo $contract_id; ?>';
		var counterparty_id = '<?php echo $counterparty_id; ?>';
		var ammendment_date = '<?php echo $ammendment_date; ?>';
		var number = '<?php echo $number; ?>';
		var contract_status = '<?php echo $contract_status; ?>';
		var contract_status_id = '<?php echo $contract_status_id; ?>';
		var counterparty_contract_type_log_window;
		var file_name = '<?php echo $file_name ?? '';?>';
		 
    	$(function(){   
    		if(counterparty_contract_type_dropdown_id) {
    			counterparty_contract_type.contract_counterparty_type_form.setItemValue('counterparty_contract_type',counterparty_contract_type_dropdown_id);
    		}

    		if(description) {
    			counterparty_contract_type.contract_counterparty_type_form.setItemValue('description',description);
    		}

			if(ammendment_date) {
    			counterparty_contract_type.contract_counterparty_type_form.setItemValue('ammendment_date',ammendment_date);
    		}

			if(number) {
    			counterparty_contract_type.contract_counterparty_type_form.setItemValue('number',number);
    		}
    				
			
			if(contract_status_id) {
    			counterparty_contract_type.contract_counterparty_type_form.setItemValue('contract_status',contract_status_id);
    		}
    					
		});
		
        
        /*
		 * [Counterparty Contract Type Menu click function]
		 */
		counterparty_contract_type_toolbar_onclick = function(name, value) {
			if (name == 'save') {
				save_counterparty_contract_type_log();
			}
		}


		/*
		 * [Save Function]
		 */
		save_counterparty_contract_type_log = function() {  
			var status = validate_form(counterparty_contract_type.contract_counterparty_type_form);
			if (status == false) {
				return;
			}

			var upload_status = counterparty_contract_type.upload_form.getUploaderStatus('upload');
			if(upload_status == -1){
				dhtmlx.alert({
					title:"Error!",
					type:"alert-error",
					text:'Please upload some file.'
				});
				return;
			}

			var file_attachment = counterparty_contract_type.upload_form.getItemValue('file_attachment');    
			if(file_attachment.indexOf(',') >= 0) {
				dhtmlx.alert({
					title:"Error!",
					type:"alert-error",
					text:'Please upload only 1 file.'
				});
				return;
			}
			

			var counterparty_contract_types = counterparty_contract_type.contract_counterparty_type_form.getItemValue('counterparty_contract_type');
			var description = counterparty_contract_type.contract_counterparty_type_form.getItemValue('description');
			var ammendment_date = counterparty_contract_type.contract_counterparty_type_form.getCalendar('ammendment_date').getFormatedDate("%Y-%m-%d");
			var number = counterparty_contract_type.contract_counterparty_type_form.getItemValue('number');
			var contract_status = counterparty_contract_type.contract_counterparty_type_form.getItemValue('contract_status');
			notes_object_id = counterparty_contract_types;
			var counterparty_contract_type_xml = '<CounterpartyContractTypeLog ';
			counterparty_contract_type_xml += ' counterparty_contract_type_id="' + counterparty_contract_type_id + '"';
			counterparty_contract_type_xml += ' counterparty_contract_address_id="' + counterparty_contract_address_id + '"'; 
			counterparty_contract_type_xml += ' counterparty_id="' + counterparty_id + '"'; 
			counterparty_contract_type_xml += ' contract_id="' + contract_id + '"'; 
			counterparty_contract_type_xml += ' counterparty_contract_type="' + counterparty_contract_types + '"'; 
			counterparty_contract_type_xml += ' description="' + description + '"'; 
			counterparty_contract_type_xml += ' ammendment_date="' + ammendment_date + '"'; 
			counterparty_contract_type_xml += ' number="' + number + '"'; 
			counterparty_contract_type_xml += ' contract_status="' + contract_status + '"'; 
		
			counterparty_contract_type_xml += ' />';

			
			var application_notes_xml = '<ApplicationNotes '
			application_notes_xml += ' category_id ="' + category_id + '"'
			application_notes_xml += ' sub_category_id ="' + sub_category_id + '"'
			application_notes_xml += ' notes_object_id ="' + counterparty_contract_address_id + '"'
			application_notes_xml += ' parent_object_id ="' + parent_object_id + '"'
			application_notes_xml += ' notes_subject ="' + counterparty_contract_types + '"'
			if((file_name != null || file_name != '') && (file_attachment == null || file_attachment == '')){
				application_notes_xml += ' file_attachment ="' + file_name + '"'
			}
			else {
				application_notes_xml += ' file_attachment ="' + file_attachment + '"'
			}
			
			application_notes_xml += ' />'
			
			var final_xml = '<Root>' + counterparty_contract_type_xml + application_notes_xml + '</Root>';
			  
			var data = {
                                "action": "spa_counterparty_contract_type",
                                "flag": "i",
                                "xml_data":final_xml
                              }

            adiha_post_data('return_json', data, '', '', 'save_counterparty_contract_type_callback', '', '');
		}


		/*
		 * [Save Callback Function]
		 */
		function save_counterparty_contract_type_callback(result) {  
			var return_data = JSON.parse(result);
			var new_id = return_data[0].recommendation;

			
			dhtmlx.message({
				text:return_data[0].message,
				expire:500
			}); 

			setTimeout ( function() { 
                    window.parent.counterparty_contract_type_log_window.window('w1').close(); 
                }, 1000);

		} 


        upload_doc = function(realName,serverName) {
			var get_pre_name = counterparty_contract_type.upload_form.getItemValue('file_attachment');

			if (get_pre_name == '') {
				final_name = serverName;
			} else {
				final_name = get_pre_name + ', ' + serverName;
			}
			
			counterparty_contract_type.upload_form.setItemValue('file_attachment', final_name);
		}

		/**
		 * [remove_doc Remove document]
		 * @param  {[type]} realName   [description]
		 * @param  {[type]} serverName [description]
		 */
		remove_doc = function(realName,serverName){
			var file_name_list = counterparty_contract_type.upload_form.getItemValue('file_attachment');
			file_name_list = remove_file_name(file_name_list, realName);
			counterparty_contract_type.upload_form.setItemValue('file_attachment', file_name_list);
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