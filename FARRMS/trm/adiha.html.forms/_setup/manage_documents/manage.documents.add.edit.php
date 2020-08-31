<?php
/**
* Manage documents add edit screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
</head>
<?php
    include '../../../adiha.php.scripts/components/include.file.v3.php';     
	global $app_adiha_loc, $app_php_script_loc;

	$rights_grd_manage_documents_iu = 10102910; 

	list (
	    $has_rights_grd_manage_documents_iu
	) = build_security_rights (
	    $rights_grd_manage_documents_iu
	);

    $mode = get_sanitized_value($_REQUEST['mode'] ?? 'NULL');
    $notes_id = get_sanitized_value($_REQUEST['notes_id'] ?? 'NULL');
    $category_id = get_sanitized_value($_REQUEST['category_id'] ?? 'NULL');
    $category_name = get_sanitized_value($_REQUEST['category_name'] ?? 'NULL');
    $notes_object_id = (isset($_REQUEST['notes_object_id']) ? get_sanitized_value($_REQUEST['notes_object_id']) : 0);
    $sub_category_id = get_sanitized_value($_GET['sub_category_id'] ?? 'NULL') ;
    $is_pop = get_sanitized_value($_REQUEST['is_pop'] ?? 'NULL');
    $process_id = get_sanitized_value($_POST['process_id'] ?? 'NULL');
    $parent_object_id = get_sanitized_value($_REQUEST['parent_object_id'] ?? 'NULL');
    $call_from = get_sanitized_value($_REQUEST['call_from'] ?? 'search_document');
    $workflow_process_id = '';
    $workflow_message_id = '';
    
    if($call_from == 'manage_approval_window') {
        echo $xml_url = "EXEC spa_manage_document_search @flag='w', @activity_id=$notes_object_id";
        $arr_category_filtered = readXMLURL2($xml_url);
        $workflow_process_id = $arr_category_filtered[0]['workflow_process_id'];
        $workflow_message_id = $arr_category_filtered[0]['workflow_message_id'];
        $workflow_deal_id = $arr_category_filtered[0]['source_deal_header_id'];
        $parent_object_id = $workflow_deal_id;
    }
    
    $save_button_state = empty($has_rights_grd_manage_documents_iu) || $call_from == 'search_document' ?'true':'false';
	$form_name = 'form_manage_document_iu';
	
    $rights_form_manage_documents = 10102900; 
     
    $layout_json = '[{id:"a", header: false}]';
    
    //Creating Layout
    $manage_documents_iu_layout = new AdihaLayout();
    echo $manage_documents_iu_layout->init_layout('manage_documents_iu', '', '1C', $layout_json, $form_name);

    // Attaching Toolbar 
    $toolbar_obj = new AdihaToolbar();
    $toolbar_name = 'toolbar_manage_doc';
    $toolbar_namespace = 'toolbar_ns_manage_doc';
    $tree_toolbar_json = '[ {id:"save", type:"button", img:"save.gif", imgdis:"save_dis.gif", text:"Save", title:"Save", disabled:' . $save_button_state . '}]';
    
    echo $manage_documents_iu_layout->attach_toolbar_cell($toolbar_name, 'a');
    echo $toolbar_obj->init_by_attach($toolbar_name, $form_name);
    echo $toolbar_obj->load_toolbar($tree_toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', 'save_form');
    
    //for creating dropdown json data for general form
    $form_obj = new AdihaForm();
    $form_name_inner = 'form_add';
    echo $manage_documents_iu_layout->attach_form($form_name_inner, 'a');

    $document_type = '[]';
    $hide_document_type = 'true';
    $param = '?call_from=manage_document&category_id=' . $category_id;
    
    $subject_label = 'Subject';
    $subject_required = 'true';
    $document_required = 'false';
    
    $sp_url = "EXEC spa_StaticDataValues @flag = 'h', @type_id = 43000";

    if ($call_from == 'contract_window_template') {
        $sp_url = "EXEC spa_StaticDataValues @flag = 'h', @type_id = 43000, @value_ids = '-43001'";
    } else if ($call_from == 'contract_window') {
        $sp_url = "EXEC spa_StaticDataValues @flag = 'h', @type_id = 43000, @license_not_to_static_value_id = '-43000'";
    } else if ($category_id !== '10000132') { //Not showing Signature option in drop down if its not setup user form.
        $sp_url = "SELECT value_id AS ID,  code AS VALUE, 'enable' AS state FROM static_data_value WHERE TYPE_ID = 43000 AND value_id > 1";
    }

        $user_category = $form_obj->adiha_form_dropdown($sp_url, 0, 1, true, '', 2);
    // for direct upload from page other than manage document
    if ($category_id == 33 || $category_id == 38 || $category_id == 45) {    
    	$deal_id = get_sanitized_value($_POST['deal_id'] ?? 'NULL');

	    $sp_url = "EXEC('SELECT document_id, document_name FROM documents_type WHERE document_type_id = 42003')";
	    $document_type = $form_obj->adiha_form_dropdown($sp_url, 0, 1, false);
	    $hide_document_type = 'false';
	    $document_required = 'true';
        $category_name = ($category_id == 33 ? 'Deal' : $category_name);
    }
    
    $doc_path = '../../../adiha.php.scripts/'.'dev/shared_docs/attach_docs/' . $category_name . '/';
    
    $title_text = $mode == 'i' ? 'New Document' : 'Note Category: ' . $category_name;
    
    $general_form_structure = "[{type: 'settings',position:'label-top', offsetLeft: 10},
							    {type: 'block', blockOffset:0, list: [
							    	{type: 'combo', name: 'document_type', label: 'Document Type', hidden:" . $hide_document_type . ", required:" . $document_required . ", inputWidth:360, options: " . $document_type . "},
                                    {type: 'hidden', name: 'source_system', label: 'Source System', width: 1, value: 2, className: 'combo_source_system_css'},
								    {type: 'hidden', name: 'notes_category', label: 'Notes Category', width: 1, disabled:'true', value: '" . $category_name . "'},
								    {type: 'input', inputWidth:360, name: 'subject', label:'" . $subject_label . "', required:'" . $subject_required . "'}, {type: 'newcolumn'},
                                    {type: 'combo', name: 'user_category', label: 'User Category', required:0, inputWidth:200, options: " . $user_category. "},
							    ]},
								{type: 'block', blockOffset:0, list: [
								    {type: 'fieldset', inputWidth:580, label: 'File Attachment', list:[
										{type: 'upload', name: 'upload', inputWidth:500, url:'" . $app_adiha_loc . "adiha.html.forms/_setup/manage_documents/file_uploader.php" . $param . "', autoStart:true},
										{type: 'label', label: '* Note: The permitted file formats are documents, spreadsheets and images.'}
									]},
									{type: 'newcolumn'},
									{type: 'hidden', value:'', name:'file_attachment'},									
									{type: 'newcolumn'},
								    {type: 'input', rows:2, inputWidth:580, name: 'url', label: 'URL', position:'label-top'}
							    ]},
							    {type: 'block', blockOffset:0, list: [
						    		{type: 'label', inputWidth:580, label: 'Current Attached File(s): current_attached_file', hidden: true, offsetTop: 0, className: 'current_attached'}
					    		]},    
							    {type: 'block', blockOffset:0, list: [
							    	{type: 'editor', name: 'text', label: 'Text', position: 'label-top', inputWidth:580, inputHeight:225, toolbar: true, iconsPath:'" . $image_path . "'},
							   		{type: 'hidden', name: 'share_email', label: 'Enable Share / Email', value:0}
						   		]}
							    ]";
    if ($mode == 'u') {
    	if ($category_id == 33 && $process_id != 'NULL') {
    		$xml_url = "EXEC spa_post_template @flag='z',@notes_id='" . $notes_id . "', @process_id='" . $process_id . "'";
	        $result_set = readXMLURL2($xml_url);

	        $download_url = $app_php_script_loc . 'force_download.php';
	        $attached_file_link = '<a href="' . $download_url . '?path=' . str_replace('/', 'aaaa', $result_set[0]['notes_attachment']) . '" download>' . $result_set[0]['attachment_file_name'] . '</a>';
			$general_form_structure = str_replace("current_attached_file', hidden: true", $attached_file_link."', hidden: false", $general_form_structure);
    	} else {
    		$xml_url = "EXEC spa_application_notes @flag='a',@notes_id=" . $notes_id;
	        $result_set = readXMLURL2($xml_url);
            
			$download_url = $app_php_script_loc . 'force_download.php';
	        $attached_file_link = '<a href="' . $download_url . '?path=' . str_replace('/', 'aaaa', $result_set[0]['notes_attachment']) . '" download>' . $result_set[0]['attachment_file_name'] . '</a>';
			$general_form_structure = str_replace("current_attached_file', hidden: true", $attached_file_link."', hidden: false", $general_form_structure);
    	}
    }
    
    echo $form_obj->init_by_attach($form_name_inner, $form_name);
    echo $form_obj->load_form($general_form_structure);
    echo $form_obj->attach_event('', 'onButtonClick', 'save_form', $form_name_inner);
	echo $form_obj->attach_event('', 'onUploadFile', 'upload_doc');
	echo $form_obj->attach_event('', 'onFileRemove', 'remove_doc');
    
    echo $manage_documents_iu_layout->close_layout();
?>
<style type="text/css">
    html, body {
        width: 100%;
        height: 100%;
        margin: 0px;
        padding: 0px;
        background-color: #ebebeb;
        overflow: hidden;
    }

    .current_attached div {
		font-weight: normal !important;
		left:0;
	}

	.mce-branding-powered-by {
		display: none;
	}
</style>
    	
<script type="text/javascript">
	mode = '<?php echo $mode;?>';
    var call_from = '<?php echo $call_from; ?>';
    
    var workflow_process_id = (call_from == 'manage_approval_window' ? '<?php echo $workflow_process_id; ?>' : 'NULL');
    var workflow_message_id = (call_from == 'manage_approval_window' ? '<?php echo $workflow_message_id; ?>' : 'NULL');
    var parent_object_id = '<?php echo $parent_object_id; ?>';
    
	$(function () {
		if(mode == 'u') {
			form_manage_document_iu.manage_documents_iu.cells("a").setText("<?php echo $result_set[0]['notes_subject'] ?? ''; ?>");
			form_manage_document_iu.form_add.setItemValue('source_system', "<?php echo $result_set[0]['source_system_id'] ?? ''; ?>");
			form_manage_document_iu.form_add.setItemValue('subject', "<?php echo $result_set[0]['notes_subject'] ?? ''; ?>");
			form_manage_document_iu.form_add.setItemValue('url', "<?php echo $result_set[0]['url'] ?? ''; ?>");
            form_manage_document_iu.form_add.setItemValue('user_category', "<?php echo $result_set[0]['user_category'] ?? ''; ?>");

			var process_id = '<?php echo $process_id; ?>';
			var category_id = '<?php echo $category_id; ?>';
			
			if (category_id == 33) {
				form_manage_document_iu.form_add.setItemValue('document_type', "<?php echo $result_set[0]['document_type'] ?? ''; ?>");
			}

			var text_body = "<?php echo $result_set[0]['notes_text'] ?? ''; ?>";
			text_body = fx_html_decode(text_body);

			form_manage_document_iu.form_add.setItemValue('text', text_body);
			form_manage_document_iu.form_add.setItemValue('share_email', "<?php echo $result_set[0]['notes_share_email_enable'] ?? ''; ?>");

			var current_attached_html = compose_current_attaced_files("<?php echo $result_set[0]['attachment_file_name'] ?? '';?>", "<?php echo $result_set[0]['notes_attachment'] ?? '';?>");
			$(".current_attached div").html(current_attached_html);
		}
		
		// While called from template upload option set option to template and disable by default
		if (call_from == 'contract_window_template') {
           form_manage_document_iu.form_add.setItemValue('user_category',-43001);
           form_manage_document_iu.form_add.disableItem('user_category');
        }
	});
	
	function compose_current_attaced_files(attachment_file_name, notes_attachment) {
		var download_url = '<?php echo $app_adiha_loc . 'adiha.php.scripts/force_download.php'; ?>';
		var current_attached_html = 'Current Attached File(s) : ';
		notes_attachment = notes_attachment.replace(attachment_file_name, '');
		var files = attachment_file_name.split(", ");

		for(var i=0; i<files.length; i++) {
			if(i > 0) {
				current_attached_html += ", ";
			}
			current_attached_html += '<a href=' + download_url +'?path=' + encodeURIComponent(notes_attachment + files[i]) + ' download>' + files[i] + '</a>';
		}

		return current_attached_html;
	}

	upload_doc = function(realName,serverName) {
		var get_pre_name = form_manage_document_iu.form_add.getItemValue('file_attachment');

		if (get_pre_name == '') {
			final_name = serverName;
		} else {
			final_name = get_pre_name + ', ' + serverName;
		}
		
		form_manage_document_iu.form_add.setItemValue('file_attachment', final_name);
	}

	/**
	 * [remove_doc Remove document]
	 * @param  {[type]} realName   [description]
	 * @param  {[type]} serverName [description]
	 */
	remove_doc = function(realName,serverName){
		var file_name_list = form_manage_document_iu.form_add.getItemValue('file_attachment');
		file_name_list = remove_file_name(file_name_list, realName);
		form_manage_document_iu.form_add.setItemValue('file_attachment', file_name_list);
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
	
	function save_form() {
		var validate_return = form_manage_document_iu.form_add.validate();
		
		var category_id = '<?php echo $category_id; ?>';
		var sub_category_id = '<?php echo $sub_category_id; ?>';
		var current_attached_file_name = "<?php echo isset($result_set[0]['attachment_file_name']) ? $result_set[0]['attachment_file_name'] : '';?>";
		var source_system = form_manage_document_iu.form_add.getItemValue('source_system');
		var subject = form_manage_document_iu.form_add.getItemValue('subject');
		var file_attachment = form_manage_document_iu.form_add.getItemValue('file_attachment');
		var url = form_manage_document_iu.form_add.getItemValue('url');
		var process_id = '<?php echo $process_id; ?>';
        var user_category = form_manage_document_iu.form_add.getItemValue('user_category');
        user_category = (user_category == '' ? 'NULL' : user_category);

		if(subject.trim() == '' && process_id == 'NULL') {
			show_messagebox('<b>Subject</b> cannot be blank.');
			return;
		}

		if(file_attachment.indexOf(',') >= 0) {
			show_messagebox('Please upload only 1 file.');
			return;
		}
		
		if(url != '' && url != undefined) {
			if(!form_manage_document_iu.is_valid_url(url)) {
				show_messagebox('Please enter valid url.');
				return;
			}
		}

		/* checks the uploaded file types */
		var name_ext_array = file_attachment.split('.');
		var len_file_name = name_ext_array.length - 1 ;
		var ext = name_ext_array[len_file_name];//this.getFileExtension(file.name);
		//var allowed_types = ["pdf", "txt", "jpeg", "jpg", "png", "doc", "docx", "xls", "xlsx", "ppt", "pptx", "odt", "vnd", "mssheet"];
		
		//if (mode != 'u' ) {
        if(call_from != 'deal_window_doc') {
            if(url == '' && file_attachment == '' && current_attached_file_name == '') {
                show_messagebox('Please upload a file or enter URL.');
    			return;
            }
        }
			
		var text = form_manage_document_iu.form_add.getItemValue('text');
		text = fx_html_encode(text).replace(/\n/g, "\\n");

		var share_email = 0;
		var doc_type = 'NULL';
		var doc_type_file_unique_name = file_attachment;

		if (mode == 'i') {
			var file_name = doc_type_file_unique_name;
		} else {
			var file_name = (doc_type_file_unique_name == '' ? current_attached_file_name : doc_type_file_unique_name);
		}

		var notes_object_id = '<?php echo $notes_object_id; ?>';
		var notes_id = '<?php echo $notes_id; ?>';
		var category_based_id = 'NULL';
		var document_type = 'NULL';

		if (category_id == 33 && process_id != 'NULL') {
			category_based_id =  '<?php echo $deal_id ?? ''; ?>';
			mode = (mode == 'i' ? 'x' : 'y');
			document_type = form_manage_document_iu.form_add.getItemValue('document_type');
			if (file_name != '') {
				file_attachment = '<?php echo $doc_path;?>' + file_name; 
			} 
			notes_id = (notes_id == 'NULL' || notes_id == -1) ? 'New_' + (new Date()).valueOf() : notes_id;
		} else {
            if(category_id == 33 || category_id == 38 || category_id == 45) {
                document_type = form_manage_document_iu.form_add.getItemValue('document_type');
            }
			if (file_name != '') {
				file_attachment = '<?php echo $doc_path;?>' + file_name; 
			} 
		}

		if (!category_id || category_id == '') {
            category_id = 'NULL';
        }

		var data_for_post = {
			'action': 'spa_post_template',
			'flag': mode, 
			'internal_type_value_id': category_id,
			'notes_object_id': notes_object_id,
			'notes_subject': subject,
			'notes_text': text,
			'doc_type': doc_type,
			'doc_file_unique_name': file_name,
			'doc_file_name': file_attachment,
			'source_system': source_system,
			'notes_id': notes_id,
			'notes_share_email_enable': share_email,
			'url': url, 
			'category_value_id': sub_category_id,
			'process_id': process_id,
			'category_based_id': category_based_id,
			'document_type': document_type,
			'user_category': user_category,
			'workflow_process_id': workflow_process_id,
			'workflow_message_id': workflow_message_id,
			'parent_object_id': parent_object_id
		}

		adiha_post_data('alert', data_for_post, '', '', 'save_callback');
	}

	/**
	 * [save_callback save callback]
	 * @param  {[type]} result [result array]
	 */
	function save_callback(result) {
		if (result[0].errorcode == 'Success') {
			success_call(return_data[0].message);
			mode = 'u';
		}
		else {
			success_call(return_data[0].message, 'error');
		}
	}
	/**
	 * [fixedEncodeURIComponent Resolved !, ', (, ), and *]
	 * @param  {[type]} str [description]
	 */
	function fixedEncodeURIComponent (str) {
	  return encodeURIComponent(str).replace(/[!'()*]/g, function(c) {
	    return '%' + c.charCodeAt(0).toString(16);
	  });
	}

	form_manage_document_iu.is_valid_url = function(url) {
	     return url.match(/^(ht|f)tps?:\/\/[a-z0-9-\.]+\.[a-z]{2,4}\/?([^\s<>\#%"\,\{\}\\|\\\^\[\]`]+)?$/);
         return true;             
	}

	//function to encode and decode html string
	function fx_html_encode(value){
	  return $('<div/>').text(value).html();
	}

	function fx_html_decode(value){
	  return $('<div/>').html(value).text();
	}
</script>