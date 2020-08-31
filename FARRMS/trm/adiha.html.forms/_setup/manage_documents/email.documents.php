<?php
/**
* Email documents screen
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
	$doc_path = $SHARED_ATTACH_DOCS_PATH;

	$namespace = 'email_document';
	$form_name = 'email_form';
    
    $mode = get_sanitized_value($_GET['mode'] ?? ''); 
	$notes_id = get_sanitized_value($_GET['notes_id'] ?? 'NULL'); 
	$internal_type_value_id = get_sanitized_value($_GET['internal_type_value_id'] ?? 'NULL'); 
	$file_attachment_name = get_sanitized_value($_GET['file_attachment_name'] ?? 'NULL'); 
    $notes_attachment_path = get_sanitized_value($_GET['notes_attachment_path'] ?? '');
    $call_from = get_sanitized_value($_GET['call_from'] ?? ''); 
    $hide_uploader = ($call_from == 'manage_email' && $mode == 'i' ? 'false' : 'true');
	$notes_object_id = get_sanitized_value($_GET['notes_object_id'] ?? 'NULL');

	$email_template = '';
    $notes_text = '';
    $notes_subject = '';
    $notes_user_category = '';
    $non_sys_users = '';
    if ($mode == 'u') {
		$xml_url = "EXEC spa_manage_email @flag='a',@notes_id=" . $notes_id;
		$result_set = readXMLURL2($xml_url);
		$file_attachment_name = $result_set[0]['attachment_file_name'];
        $notes_text = $result_set[0]['notes_text'];
        $notes_subject = $result_set[0]['notes_subject'];
        $notes_user_category = $result_set[0]['user_category'];
        $non_sys_users = $result_set[0]['non_sys_users'];

		if ($result_set[0]['admin_email_configuration_id'] == NULL) {
			$email_template = -1;
		} else {
			$email_template = $result_set[0]['admin_email_configuration_id'];
    } 
	}
    
	$is_pop = get_sanitized_value($_GET['is_pop'] ?? 'NULL');

	$title_text = 'Email Document';
	$rights_form_manage_documents = 10102900; 

	$layout_obj = new AdihaLayout();
	$form_obj = new AdihaForm();

	$layout_json = '[{id: "a", header:false}]';

	echo $layout_obj->init_layout('layout', '', '1C', $layout_json, $namespace);
	echo $layout_obj->attach_form($form_name, 'a');

	$toolbar_obj = new AdihaToolbar();
	$toolbar_name = 'toolbar_manage_doc';
	$save_disabled = 0;
	$tree_toolbar_json = "[ {id:'save', type:'button', img:'tick.png', text:'OK', title:'OK', disabled: $save_disabled}]";

	echo $layout_obj->attach_toolbar_cell($toolbar_name, 'a');
	echo $toolbar_obj->init_by_attach($toolbar_name, $namespace);
	echo $toolbar_obj->load_toolbar($tree_toolbar_json);
	echo $toolbar_obj->attach_event('', 'onClick', 'send_email');

	$sp_url_from = "EXEC spa_application_users @flag='v'";
	$from_users = $form_obj->adiha_form_dropdown($sp_url_from, 0, 1);
    
	$sp_template = "EXEC spa_email_setup @flag=m";
	$template_options = str_replace("\"", "'", $form_obj->adiha_form_dropdown($sp_template, 0, 1) );
	$template_options = str_replace("[", "[{value:'0', text:''},", $template_options);
    
    $sp_url = "EXEC('SELECT document_id, document_name FROM documents_type WHERE document_type_id = 42003')";
    $document_type = $form_obj->adiha_form_dropdown($sp_url, 0, 1, false);
    $sp_url = "EXEC spa_StaticDataValues @flag = 'h', @type_id = 43000";
    $user_category = $form_obj->adiha_form_dropdown($sp_url, 0, 1, true, '', 2);
    $param = '?call_from=manage_email';
    
    $update_disabled = 0;
    if($mode == 'u') {
        $sp_user_to = "EXEC spa_manage_email @flag='v',@notes_id=" . $notes_id;
        $user_to = $form_obj->adiha_form_dropdown($sp_user_to, 0, 1);
        $options = "options:".$user_to;
        $update_disabled = 1;
    } else {
        $options = "options:''";
    }
    
	$form_json = "[
				{type: 'settings',position:'label-top', offsetLeft: 10},
				{type: 'block', blockOffset:0, disabled: $update_disabled, list:[
					{type: 'multiselect', label: 'User List', name: 'user_from', size:6,  options:" . $from_users . " ,inputWidth:224},
					{type: 'newcolumn', offset:6},
					{type: 'block', width:100, list:[
						{type: 'button', name: 'add', value: '&#187;', offsetTop:40},
						{type: 'button', name: 'remove', value: '&#171;'}
					]},
					{type: 'newcolumn', offset:1},
					{type: 'multiselect', label: 'Notify Users', name: 'user_to', size:6, ".$options.", inputWidth:225},
                    {type: 'newcolumn', offset:1},      
                    {type:'input', label:'Send E-mail to non-system users', name:'text_email', className:'text-email', rows:6, inputWidth:580, note:{className:'text-email', text:'(Please use semicolon (;) to separate multiple e-mail address)'}}           
				
				]},
				{type:'block', blockOffset:0, list:[
					{type:'combo', label:'Email Template', name:'combo_template',  inputWidth:221, disabled: $update_disabled, options: " . $template_options . "},{type: 'newcolumn', offset:1},
                    {type:'combo', name:'document_type', label: 'Document Type', hidden:1, required:0, inputWidth:221, options: " . $document_type . "},
                    {type: 'combo', name: 'user_category', label: 'User Category', required:0, inputWidth:200, options: " . $user_category. "}
				]},
				{type:'block', blockOffset:0, list:[
					{type: 'input', inputWidth:580, name: 'text_subject', label: 'Subject', required:true}  
				]},
                {type: 'block', blockOffset:0, hidden: $hide_uploader, list: [
				    {type: 'fieldset', inputWidth:580, label: 'File Attachment', list:[
						{type: 'upload', name: 'upload', inputWidth:500, url:'" . $app_adiha_loc . "adiha.html.forms/_setup/manage_documents/file_uploader.php" . $param . "', autoStart:true},									
					]},
					{type: 'hidden', value:'', name:'file_attachment'}
			    ]},
			    {type: 'label', offsetTop:0, offsetLeft: 18, label: '* Note: The permitted file formats are documents, spreadsheets and images.', className: 'fieldset_note'}
				,";

	if ($file_attachment_name != 'NULL' && $file_attachment_name != '') {
		$attch_file_path = $SHARED_DOC_PATH . '\\' . $file_attachment_name;
		$download_url = $app_php_script_loc . 'force_download.php';
	    $attached_file_link = '<a href="' . $download_url . '?path=' . str_replace('\\', '\\\\', $attch_file_path) . '&name= ' . $file_attachment_name . '" download>' . $file_attachment_name . '</a>';
			
		$form_json	.= "{type: 'block', blockOffset:0, list: [
				    		{type: 'label', inputWidth:580, label: 'Attached File:  " . $attached_file_link. "', hidden: false, offsetTop: 0, className: 'current_attached'}
			    		]},";
	}

	$form_json	.= "{type:'block', blockOffset:0, list:[  
						{type:'editor', name:'text_message', label:'Message', inputWidth:580, inputHeight:325, value:'', toolbar: true, iconsPath:'" . $image_path . "'}
					]}
				]";
			
	echo $form_obj->init_by_attach($form_name, $namespace);
	echo $form_obj->load_form($form_json);
	echo $form_obj->attach_event('', 'onButtonClick', 'email_document.button_click', $form_name);
    echo $form_obj->attach_event('', 'onUploadFile', 'upload_doc');
	echo $form_obj->attach_event('', 'onFileRemove', 'remove_doc');
	echo $layout_obj->close_layout();
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

	.text-email > div.dhxform_control > div.dhxform_note {
		color: black !important;
	}
	.current_attached div {
		font-weight: normal !important;
		left:0;
	}

	.fieldset_note {
		font-size: 10px; 		
	}
</style>	
<script type="text/javascript">
	var mode = '<?php echo $mode; ?>';
    var notes_attachment_path = '<?php echo $notes_attachment_path; ?>';
    var notes_object_id =  '<?php echo $notes_object_id; ?>';
    var notes_id = '<?php echo $notes_id; ?>';
    var app_php_script_loc = '<?Php echo $app_php_script_loc;?>';
    var email_template = '<?php echo $email_template; ?>';
    
	$(function () {
		dhxWins = new dhtmlXWindows();
        
		var from_users = email_document.email_form.getSelect('user_from');
		var to_users = email_document.email_form.getSelect('user_to');
		var combo_template = email_document.email_form.getCombo('combo_template');
		
		if (mode!= 'u') {
			combo_template.attachEvent("onChange", template_apply);
		};
		
		from_users.ondblclick = function () {
			changeContactState(true, 'user_from', 'user_to');
		}
		
		to_users.ondblclick = function () {
			changeContactState(false, 'user_from', 'user_to');
		}
		
        if(mode == 'u') {
            //email_document.toolbar_manage_doc.disableItem('save');
            var form_obj = email_document.email_form;
            var text_body = "<?php echo $notes_text; ?>";
			text_body = fx_html_decode(text_body);
            //console.log(text_body);
            
            form_obj.setItemValue('text_subject', '<?php echo $notes_subject; ?>');
            form_obj.setItemValue('user_category', '<?php echo $notes_user_category; ?>');
            if(email_template != -1) {
				form_obj.setItemValue('combo_template', email_template);
			}
            form_obj.setItemValue('text_email', '<?php echo $non_sys_users; ?>');
            form_obj.setItemValue('text_message', text_body);
        }
	});
	
	email_document.button_click = function(id) {
		if (id == "add" || id == "remove") {
		   changeContactState(id == "add", 'user_from', 'user_to');
        } else if(id == 'save') {
			send_email();
		}
    }
	
	function send_email() {
		if(!validate_form(email_document.email_form)) {
            return;
        }
		
		var template_id = email_document.email_form.getItemValue('combo_template');
		var email = email_document.email_form.getItemValue('text_email');
		var subject = email_document.email_form.getItemValue('text_subject');
		var message = email_document.email_form.getItemValue('text_message');
        var file_attachment = email_document.email_form.getItemValue('file_attachment');
        var user_category = email_document.email_form.getItemValue('user_category');
        user_category = (user_category == '' || user_category == null) ? 'NULL' : user_category;        
		var user_ids = get_user_ids();
		user_ids  = (user_ids == '' || user_ids == null) ? 'NULL' : "'" + user_ids + "'";		
		template_id = (template_id == '' || template_id == null) ? 'NULL' : template_id;

		if ((email == 'NULL' || email == null || email == '' || email == undefined) && mode != 'u') { 
			if(user_ids == 'NULL') {
				show_messagebox('Please enter Email ID or select the system user.');
				return;
			}
		} else if(mode != 'u') {
			//email_expression = /^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i;	// for single email
			email_expression = /^\s*((\s*[a-zA-Z0-9\._%-]+@[a-zA-Z0-9\.-]+\.[a-zA-Z]{2,20}\s*[;]{1}\s*){1,100}?)?([a-zA-Z0-9\._%-]+@[a-zA-Z0-9\.-]+\.[a-zA-Z]{2,20})\s*$/i;	// for multiple email
			
			if(email_expression.test(email) == false) {
				show_messagebox('Please enter valid Email ID.');
				return;
			}
		}
		
		if (subject == 'NULL' || subject == '') { 
			show_messagebox('<b>Subject</b> cannot be blank.');
			return;
		}
        
        if(file_attachment.indexOf(',') >= 0) {
			show_messagebox('Please upload only 1 file.');
			return;
		}
		
		var attach_docs_path = '<?php echo addslashes($SHARED_ATTACH_DOCS_PATH . '\\'); ?>';
		var file_attachement_path = attach_docs_path + file_attachment;
		file_attachement_path = file_attachement_path.replace(/, /g, ';' + attach_docs_path);
		var internal_type_value_id = '<?php echo $internal_type_value_id;?>';
        
        if (file_attachment != '') {
            notes_attachment_path = file_attachement_path;
        }
        
        var sp_string = "EXEC spa_tempNotes " +  
				  "@send_cc=NULL" +
				  ", @send_bcc=NULL" +
				  ", @internal_type_value_id=" + internal_type_value_id +
				  ", @send_to='" + email + "'" +
				  ", @subject='" + subject + "'" +
				  ", @message='" + message.replace(/'/g,"''") + "'" +
				  
                  ", @file_attachment_name='" + notes_attachment_path + "'" +
                  ", @user_category=" + user_category +
				  ", @user_ids=" + user_ids +
                  ", @admin_email_configuration_id=" + template_id +
                  ", @notes_object_id=" + notes_object_id + 
                  ", @notes_id=" + notes_id;
		
		var data =  { "sp_string": sp_string};
		var result = adiha_post_data("return_array", data, "", "", "closing_function");  
	}
	
	function closing_function(result) { 
		if (result[0][0] == 'Success') {
			success_call('Email sent successfully.');
			setTimeout(function(){
				parent.email_document.close();
			}, 1000);
		}
	}

	function strip_tags(text) {
		var regex = /(<([^>]+)>)/ig
		var stripped_text = text.replace(regex, "");
		stripped_text =  stripped_text.replace(/&nbsp;/ig, '');
		stripped_text =  stripped_text.trim();
		return stripped_text;
	}
	
	function get_user_ids() {
		var user_to_obj = email_document.email_form.getSelect('user_to');
		var user_to_count = user_to_obj.options.length;
		var user_ids = '';
		
		for(var i = 0; i < user_to_count; i++) {
			if(i > 0) {
				user_ids = user_ids + ', ';
			}
			
			user_ids = user_ids + user_to_obj.options[i].value;
		}
		
		return user_ids;
	}
	
	function template_apply() {
		var template_id = email_document.email_form.getItemValue('combo_template');
		var data = {"action": "spa_email_setup", "flag": 'a', 'template_id': template_id};
		adiha_post_data("return_array", data, "", "", "template_response"); 
	}
	
	function template_response(result) {
		var subject, message;
		
		if(result == '') {
			subject = '';
			message = '';
		}	else {
			subject = result[0][4];
			message = decodeURIComponent(result[0][5]);
			message = message.replace(/<\/?([a-z][a-z0-9]*)\b[^>]*>/gi, '');
		}
		
		email_document.email_form.setItemValue('text_subject', subject);
		email_document.email_form.setItemValue('text_message', message);
	}
	
	function changeContactState(block, from, to) {
        var ida = (block ? from : to);
        var idb = (block ? to : from);
		var sa = email_document.email_form.getSelect(ida);
        var sb = email_document.email_form.getSelect(idb);
        var t = email_document.email_form.getItemValue(ida);
		
        if (t.length == 0) return;
        
		var to_eval = 'var k={';
        
        for (var i = 0; i < t.length; i++) {
            if (i >= 1)
            to_eval = to_eval + ',';
            to_eval = to_eval + '"' + t[i] + '":true';            
        }
        to_eval = to_eval + '};';
        
        eval(to_eval);
		
		var w = 0;
		var ind = -1;
		while (w < sa.options.length) {
			if (k[sa.options[w].value]) {
				sb.options.add(new Option(sa.options[w].text,sa.options[w].value));
				sa.options.remove(w);
				ind = w;
			} else {
				w++;
			}
		}
		
		if (sa.options.length > 0 && ind >= 0) {
			if (sa.options.length > 0) sa.options[t.length>1?0:Math.min(ind,sa.options.length-1)].selected = true;
		}

        var arr_texts = new Array();

        for (var i = 0; i < sb.length; i++) {
            arr_texts[i] = sb.options[i].text;
        }

        arr_texts.sort();

        for (var i = 0; i < sb.length; i++) {
            sb.options[i].text = arr_texts[i];
        }
	}

    upload_doc = function(realName,serverName) {
		var get_pre_name = email_document.email_form.getItemValue('file_attachment');

		if (get_pre_name == '') {
			final_name = serverName;
		} else {
			final_name = get_pre_name + ', ' + serverName;
		}
		
		email_document.email_form.setItemValue('file_attachment', final_name);
	}

	/**
	 * [remove_doc Remove document]
	 * @param  {[type]} realName   [description]
	 * @param  {[type]} serverName [description]
	 */
	remove_doc = function(realName,serverName){
		var file_name_list = email_document.email_form.getItemValue('file_attachment');
		file_name_list = remove_file_name(file_name_list, realName);
		email_document.email_form.setItemValue('file_attachment', file_name_list);
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

	//function to encode and decode html string
	function fx_html_encode(value){
	  return $('<div/>').text(value).html();
	}

	function fx_html_decode(value){
	  return $('<div/>').html(value).text();
	}
</script>
<style>
	.dhxform_btn_txt {font-size:28px; color:#17ae61; font-family:Verdana, Geneva, sans-serif!important;}
</style>
</html>