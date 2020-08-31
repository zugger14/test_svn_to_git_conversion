<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    </head>
<?php
  
include "../../../adiha.php.scripts/components/include.file.v3.php";
$callback_function = get_sanitized_value($_GET['callback_function']);
$users = get_sanitized_value($_GET['users']);
$roles = get_sanitized_value($_GET['roles']);
$namespace = 'generic_privilege';
$form_name = 'generic_privilege_form';

$layout_obj = new AdihaLayout();
$form_obj = new AdihaForm();

$layout_json = '[{id: "a", header:false}]';

echo $layout_obj->init_layout('layout', '', '1C', $layout_json, $namespace);
echo $layout_obj->attach_form($form_name, 'a');

$toolbar_obj = new AdihaToolbar();
$toolbar_name = 'toolbar_generic_privilege';
$toolbar_namespace = 'generic_privilege';
$tree_toolbar_json = '[ {id:"save", type:"button", img:"tick.png", text:"OK", title:"OK"}]';

echo $layout_obj->attach_toolbar_cell($toolbar_name, 'a');
echo $toolbar_obj->init_by_attach($toolbar_name, $namespace);
echo $toolbar_obj->load_toolbar($tree_toolbar_json);
echo $toolbar_obj->attach_event('', 'onClick', 'ok_click');

$sp_url_from = "EXEC spa_application_users @flag='v'";
$from_users = $form_obj->adiha_form_dropdown($sp_url_from, 0, 1);

$comm_type = 'EXEC spa_staticDataValues @flag=s, @type_id=750,@license_not_to_static_value_id= "757,754,756,753,755"';
$communication_type = $form_obj->adiha_form_dropdown($comm_type, 1, 2);

$sp_role_from = "EXEC spa_application_security_role @flag='s'";
$from_roles = $form_obj->adiha_form_dropdown($sp_role_from, 0, 1);

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
	    			";

				if ($callback_function == 'set_privilege_10104000') { //Change Label name for 10104000 only.
					$form_json .= "
					{type: 'multiselect', label: 'Assigned User', name: 'user_to', size:6, inputWidth:250}";
				} else {
					$form_json .= "
					{type: 'multiselect', label: 'Message to users', name: 'user_to', size:6, inputWidth:250}";
				}	

				$form_json .= "]},
				{type: 'block', width:630, list:[
						{type: 'multiselect', label: 'Role List', name: 'role_from', size:6,  options:" . $from_roles . " ,inputWidth:240},
						{type: 'newcolumn', offset:10},
						{type: 'block', width:100, list:[
							{type: 'button', name: 'add_role', value: '&#187;', offsetTop: 40, action:'send_message.button_click'},
							{type: 'button', name: 'remove_role', value: '&#171;', action:'send_message.button_click'}
						]},
						{type: 'newcolumn', offset:10},
						";

	    			if ($callback_function == 'set_privilege_10104000') { //Change Label name for 10104000 only.
						$form_json .= "
						{type: 'multiselect', label: 'Assigned Role', name: 'role_to', size:6, inputWidth:250}";
	    			} else {
    					$form_json .= "
    					{type: 'multiselect', label: 'Message to role', name: 'role_to', size:6, inputWidth:250}";
	    			}	

				$form_json .= "]}
			]";

echo $form_obj->init_by_attach($form_name, $namespace);
echo $form_obj->load_form($form_json);
echo $form_obj->attach_event('', 'onButtonClick', 'generic_privilege.button_click');
echo $layout_obj->close_layout();

?>
<script type="text/javascript">
    var callback_function = '<?php echo $callback_function; ?>';
    $(function() {
        var users = '<?php echo $users; ?>';
        if (users != 'null' && users != '') {
            var user_arr = users.split(',');
            for (cn = 0; cn < user_arr.length; cn++) {
                generic_privilege.generic_privilege_form.setItemValue('user_from', user_arr[cn]);  
                changeContactState(true, 'user_from', 'user_to');
            }
        }
        var roles = '<?php echo $roles; ?>';
        if (roles != 'null' && roles != '') {
            var roles_arr = roles.split(',');
            for (cn = 0; cn < roles_arr.length; cn++) {
                generic_privilege.generic_privilege_form.setItemValue('role_from', roles_arr[cn]);  
                changeContactState(true, 'role_from', 'role_to');
            }
        }
       
        var from_users = generic_privilege.generic_privilege_form.getSelect('user_from');
		var to_users = generic_privilege.generic_privilege_form.getSelect('user_to');
		var from_roles = generic_privilege.generic_privilege_form.getSelect('role_from');
		var roles_to = generic_privilege.generic_privilege_form.getSelect('role_to');
		
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
	});
    
    function ok_click() {
        var result_value = new Array();
        // var role_to = generic_privilege.generic_privilege_form.getItemValue('role_to');
        var role_to_obj = generic_privilege.generic_privilege_form.getOptions('role_to');
        var role_to_array = [];
        var role_name_to_array = [];
        $.each(role_to_obj, function (index, value) {
        	role_to_array.push(role_to_obj[index]["value"]);
        });
        var role_to = (role_to_array.sort()).join(",");
        // console.log(role_to);

        // var user_to = generic_privilege.generic_privilege_form.getItemValue('user_to');
        var user_to_obj = generic_privilege.generic_privilege_form.getOptions('user_to'); 
        var user_to_array = [];
        $.each(user_to_obj, function (index, value) {
        	user_to_array.push(user_to_obj[index]["value"]);
        });
        var user_to = (user_to_array.sort()).join(",");
        // console.log(user_to);

        eval("parent." + callback_function + "('" + role_to + "','" + user_to + "')");
        parent.privilege.window('p1').close();
    }
    
    /*
    function send_message() {
		var to_users = generic_privilege.generic_privilege_form.getOptions('user_to');
		var val_to_users = $(to_users).map(function() {
			return this.value;
		}).get().join(",");

		var to_role = generic_privilege.generic_privilege_form.getOptions('role_to');
		var val_to_role = $(to_role).map(function() {
			return this.value;
		}).get().join(",");

		var text_message = generic_privilege.generic_privilege_form.getItemValue('text_message');
		var additional_message = generic_privilege.generic_privilege_form.getItemValue('text_additional_message');
		var communication_type = generic_privilege.generic_privilege_form.getItemValue('communication_type');
		var email_from = '<?php echo $app_user_name; ?>';
		var email_subject = 'Message sent from Message Board by User, ' + email_from;            

		if ((val_to_users == '' || val_to_users == 'NULL') && (val_to_role == '' || val_to_role == 'NULL')) {
			dhtmlx.alert({text: 'Please select User or Role.'});
			return;
		}

		var attachment = generic_privilege.generic_privilege_form.getItemValue('file_name_hidden');
		
		var attachment_split = 'NULL';
		if (attachment == '') {
			attachment_split = '';
		} else {
			attachment_split = attachment.split(',');   
		} 
	   
		var name_extension_arr = new Array([]);
		var attach_doc_url_path_arr = new Array();
		var attach_doc_path_arr = new Array();
	
        var document_path = "<?php echo $attach_docs_url_path; ?>" + "/";
		var attach_doc_path = "<?php echo addslashes($SHARED_ATTACH_DOCS_PATH); ?>" + "\\";
		var message_id = <?php echo $message_id; ?>;
		
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
				, message : text_message
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
	} */
	
	function close_forward_box_self(return_value) {
		setTimeout(function() { parent.close_forward_box() }, 2000);//close after 2 seconds
	}
	
	generic_privilege.button_click = function(id) {
		if (id == "add" || id == "remove") {
		   changeContactState(id == "add", 'user_from', 'user_to',id);
		} else if (id == "add_role" || id == "remove_role") {
			changeContactState(id == "add_role", 'role_from', 'role_to',id);
		}
    }

	function changeContactState(block, from, to, id) {   
        var ida = (block ? from : to);
        var idb = (block ? to : from);
		var sa = generic_privilege.generic_privilege_form.getSelect(ida);
        var sb = generic_privilege.generic_privilege_form.getSelect(idb);
        var t = generic_privilege.generic_privilege_form.getItemValue(ida);
        var show_alert_flag = 1;
		
		if(id == undefined){
			show_alert_flag = 0;
		}
        
        var validation_empty = '';

        if (t.length == 0 && show_alert_flag == 1) {
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

            if(callback_function !== 'set_privilege_10104000') // Not showing alert message for 10104000.
    		{
            	dhtmlx.alert({text: validation_empty});
			}
            return;
        }

		eval('var k={"'+t.join('":true,"')+'":true};');

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
        var arr_value = new Array();

        for (var i = 0; i < sb.length; i++) {
            arr_texts[i] = sb.options[i].text;
            arr_value[i] = sb.options[i].value;

            if (idb == 'user_to' || idb == 'role_to')
                sb.options[i].selected = true;
        }

        // arr_texts.sort();
        arr_value.sort();

        for (var i = 0; i < sb.length; i++) {
            sb.options[i].text = arr_texts[i];
        }

	}

</script>
<style>
    html, body {
        width: 100%;
        height: 615px;
        margin: 0px;
        padding: 0px;
        background-color: #ebebeb;
        overflow: hidden;
    }
			
	.dhxform_btn_txt {font-size:28px; color:#17ae61; font-family:Verdana, Geneva, sans-serif!important;}
		
</style>
</html>

