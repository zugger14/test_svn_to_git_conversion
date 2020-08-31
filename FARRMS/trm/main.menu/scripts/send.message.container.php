<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    </head>
<?php
  
include "../../adiha.php.scripts/components/include.file.v3.php";
$namespace = 'send_message';
$form_name = 'frm_forward_msg';

$layout_obj = new AdihaLayout();
$form_obj = new AdihaForm();

$layout_json = '[{id: "a", header:false}]';

echo $layout_obj->init_layout('layout', '', '1C', $layout_json, $namespace);
echo $layout_obj->attach_form($form_name, 'a');

$toolbar_obj = new AdihaToolbar();
$toolbar_name = 'toolbar_send_message';
$toolbar_namespace = 'toolbar_ns_send_message';
$tree_toolbar_json = '[ {id:"save", type:"button", img:"tick.png", text:"OK", title:"OK"}]';

echo $layout_obj->attach_toolbar_cell($toolbar_name, 'a');
echo $toolbar_obj->init_by_attach($toolbar_name, $namespace);
echo $toolbar_obj->load_toolbar($tree_toolbar_json);
echo $toolbar_obj->attach_event('', 'onClick', 'send_message');

$sp_url_from = "EXEC spa_application_users @flag='v'";
$from_users = $form_obj->adiha_form_dropdown($sp_url_from, 0, 1);

$comm_type = 'EXEC spa_staticDataValues @flag=s, @type_id=750,@license_not_to_static_value_id= "757,754,756,753,755"';
$communication_type = $form_obj->adiha_form_dropdown($comm_type, 1, 2);

$sp_role_from = "EXEC spa_application_security_role @flag='s'";
$from_roles = $form_obj->adiha_form_dropdown($sp_role_from, 0, 1);

$message_id = get_sanitized_value($_GET['selected_id']);
$get_msg_info_sp = 'EXEC spa_send_message @flag=f, @message_id=' . $message_id;
$recordsets = readXMLURL2($get_msg_info_sp);

$form_json = "[
    			{type: 'settings', position: 'label-top',offsetLeft:0},
    			{type: 'block', width:630, list:[
	    			{type: 'multiselect', label: 'User List', name: 'user_from', size:6,  options:" . $from_users . " ,inputWidth:240},
	    			{type: 'newcolumn', offset:10},
	    			{type: 'block', width:100, list:[
	    				{type: 'button', name: 'add', value: '&#187;', offsetTop:40},
	    				{type: 'button', name: 'remove', value: '&#171;'}
	    			]},
	    			{type: 'newcolumn', offset:10},
	    			{type: 'multiselect', label: 'Message to users', name: 'user_to', size:6, inputWidth:250}
    			]},
    			{type: 'block', width:630, list:[
	    			{type: 'multiselect', label: 'Role List', name: 'role_from', size:6,  options:" . $from_roles . " ,inputWidth:240},
	    			{type: 'newcolumn', offset:10},
	    			{type: 'block', width:100, list:[
	    				{type: 'button', name: 'add_role', value: '&#187;', offsetTop: 40, action:'send_message.button_click'},
	    				{type: 'button', name: 'remove_role', value: '&#171;', action:'send_message.button_click'}
	    			]},
	    			{type: 'newcolumn', offset:10},
	    			{type: 'multiselect', label: 'Message to role', name: 'role_to', size:6, inputWidth:250}
    			]},
    			{type:'block', width:610, list:[  
    				{type:'input', label:'Message', name:'text_message', rows:3, inputWidth:610, readonly: 'true', value: '" . str_replace("&nbsp;"," ",$recordsets[0]['description_no_html']) . "'}
    			]},
                {type:'block', width:610, list:[  
    				{type:'input', label:'Text Message', name:'text_additional_message', rows:3, inputWidth:610, value: ''}
    			]},
    			{type:'block', width:630, list:[    				
    				{type:'fieldset', inputWidth:330, label: 'Attachment', list:[
    					{type: 'upload', name: 'attachment', url:'" . $app_form_path .  "//_setup//manage_documents//file_uploader.php?call_form=mb', inputWidth:330, autoStart: true}
					]},
					{type: 'newcolumn', offset:50},
					{type: 'combo', name: 'communication_type', label:'Communication Type', options:" . $communication_type ." ,inputWidth:200} ,
    			]},
                {type:'block', width:630, list:[  
    				{type:'hidden', value:'', name:'file_name_hidden'}
    			]}
    		]";

echo $form_obj->init_by_attach($form_name, $namespace);
echo $form_obj->load_form($form_json);
echo $form_obj->attach_event('', 'onButtonClick', 'send_message.button_click');
echo $form_obj->attach_event('', 'onUploadFile', 'send_message.upload');
echo $layout_obj->close_layout();

?>
<script type="text/javascript">
    send_message.upload = function(realName,serverName) {
        var get_pre_name = send_message.frm_forward_msg.getItemValue('file_name_hidden');
        
        if (get_pre_name == '') {
            final_name = serverName;
        } else {
            final_name = get_pre_name + ', ' + serverName;
        }
        
        send_message.frm_forward_msg.setItemValue('file_name_hidden', final_name);
    }	
    
	function send_message() {
		var message_to_forward = '<?php echo $recordsets[0]['description']; ?>';
		var to_users = send_message.frm_forward_msg.getOptions('user_to');
		var val_to_users = $(to_users).map(function() {
			return this.value;
		}).get().join(",");

		var to_role = send_message.frm_forward_msg.getOptions('role_to');
		var val_to_role = $(to_role).map(function() {
			return this.value;
		}).get().join(",");

		var text_message = send_message.frm_forward_msg.getItemValue('text_message');  
		var additional_message = send_message.frm_forward_msg.getItemValue('text_additional_message');
		var communication_type = send_message.frm_forward_msg.getItemValue('communication_type');
		var email_from = '<?php echo $app_user_name; ?>';
		var email_subject = 'Message sent from Message Board by User, ' + email_from;            

		if ((val_to_users == '' || val_to_users == 'NULL') && (val_to_role == '' || val_to_role == 'NULL')) {
			dhtmlx.alert({text: 'Please select User or Role.'});
			return;
		}

		var attachment = send_message.frm_forward_msg.getItemValue('file_name_hidden');
		
		var attachment_split = 'NULL';
		if (attachment == '') {
			attachment_split = '';
		} else {
			attachment_split = attachment.split(',');   
		} 
	   
		var name_extension_arr = new Array([]);
		var attach_doc_url_path_arr = new Array();
		var attach_doc_path_arr = new Array();
		//var unique_name_name = new Array([]);
		
		//for (var a = 0; a < attachment_split.length; a++) {
//                var split_name_extension = attachment_split[a].split('.');
//                name_extension_arr.push(split_name_extension);
//            }

		var document_path = "<?php echo $attach_docs_url_path; ?>" + "/";
		var attach_doc_path = "<?php echo addslashes($SHARED_ATTACH_DOCS_PATH); ?>" + "\\";
		var message_id = '<?php echo $message_id; ?>';
		
		//var time_stamp = new Date();
		//time_stamp = time_stamp.getTime();
		
		for (var a = 0; a < attachment_split.length; a++) {
			attach_doc_url_path_arr.push(document_path + attachment_split[a]);
			attach_doc_path_arr.push(attach_doc_path + attachment_split[a]);
		}
		
		var path = attach_doc_path_arr.join(',');
		if (path == '') {
			path = 'NULL';
		}
		
		var data = {action : "spa_send_message"
				, role_user_flag : 'u'
				, user_ids : val_to_users
				, role_user_ids : val_to_role
				, message : message_to_forward
				, emailFrom : email_from
				, emailSubject : email_subject
				, url : attach_doc_url_path_arr.join(',')
				, file_name : attachment
				, file_path : path
				, flag : "y"                    
				, communication_type : communication_type
				, message_id : message_id
				, additional_message: additional_message
				}
			
		adiha_post_data("alert", data, "", "", 'close_forward_box_self');
	}
	
	function close_forward_box_self(return_value) {
		setTimeout(function() { parent.close_forward_box() }, 2000);//close after 2 seconds        
	}
    
	send_message.button_click = function(id) {
		if (id == "add" || id == "remove") {
		   changeContactState(id == "add", 'user_from', 'user_to');
		} else if (id == "add_role" || id == "remove_role") {
			changeContactState(id == "add_role", 'role_from', 'role_to');
		}
    }

	onload = function () {
		var from_users = send_message.frm_forward_msg.getSelect('user_from');
		var to_users = send_message.frm_forward_msg.getSelect('user_to');
		var from_roles = send_message.frm_forward_msg.getSelect('role_from');
		var roles_to = send_message.frm_forward_msg.getSelect('role_to');
		
		from_users.ondblclick = function () {
			changeContactState(true, 'user_from', 'user_to');
		}

		to_users.ondblclick = function () {
			changeContactState(false, 'user_from', 'user_to');
		}

		from_roles.ondblclick = function () {
			changeContactState(true, 'role_from', 'role_to');
		}

		roles_to.ondblclick = function () {
			changeContactState(false, 'role_from', 'role_to');
		}
	}

	function changeContactState(block, from, to) {   
        var ida = (block ? from : to);
        var idb = (block ? to : from);
		var sa = send_message.frm_forward_msg.getSelect(ida);
        var sb = send_message.frm_forward_msg.getSelect(idb);
        var t = send_message.frm_forward_msg.getItemValue(ida);
        
        var validation_empty = '';

        if (t.length == 0) {
            if (from == 'user_from') {
                if (block === true) {
                    validation_empty = 'Please select User from User List.';    
                } else {
                    validation_empty = 'Please select User from Message to users.'; 
                }
            } else if (from == 'role_from') {
                if (block === true) {
                    validation_empty = 'Please select Role from Roles List.';    
                } else {
                    validation_empty = 'Please select Role from Message to roles.'; 
                }
            } 
            dhtmlx.alert({text: validation_empty});
            return;
        }
        
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

            if (idb == 'user_to' || idb == 'role_to')
                sb.options[i].selected = true;
        }

        arr_texts.sort();

        for (var i = 0; i < sb.length; i++) {
            sb.options[i].text = arr_texts[i];
        }

	}

</script>
<style>
    html, body {
        margin: 0px;
        padding: 0px;   
        xoverflow-y: scroll;    
    }
	.dhxform_btn_txt {font-size:28px; color:#17ae61; font-family:Verdana, Geneva, sans-serif!important;}
</style>
</html>

