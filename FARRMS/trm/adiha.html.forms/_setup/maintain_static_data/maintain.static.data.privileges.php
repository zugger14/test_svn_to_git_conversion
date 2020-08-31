<?php
/**
* Maintain static data privileges screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    </head>
<?php
require('../../../adiha.php.scripts/components/include.file.v3.php');
$namespace = 'static_data_privilege';
$form_name = 'frm_sdp';

$layout_obj = new AdihaLayout();
$form_obj = new AdihaForm();

$layout_json = '[{id: "a", header:false}]';

echo $layout_obj->init_layout('layout', '', '1C', $layout_json, $namespace);
echo $layout_obj->attach_form($form_name, 'a');

$toolbar_obj = new AdihaToolbar();
$toolbar_name = 'toolbar_send_message';
$toolbar_namespace = 'toolbar_ns_send_message';
$tree_toolbar_json = '[{id:"save", type:"button", img:"tick.png", img_dis:"tick_dis.png", text:"Ok", title:"Ok"}]';


$role = get_sanitized_value($_POST['role']);
$user = get_sanitized_value($_POST['user']);

echo $layout_obj->attach_toolbar_cell($toolbar_name, 'a');
echo $toolbar_obj->init_by_attach($toolbar_name, $namespace);
echo $toolbar_obj->load_toolbar($tree_toolbar_json);
echo $toolbar_obj->attach_event('', 'onClick', 'static_data_privilege_click');
 
$sp_url_from = "EXEC spa_application_users @flag='z', @user='" . $user 
                . "', @include_exclude='e'" 
                . ", @user_role=1";
$from_users = $form_obj->adiha_form_dropdown($sp_url_from, 0, 1);

$sp_url_from = "EXEC spa_application_users @flag='z', @user='" . $user 
                . "', @include_exclude='i'" 
                . ", @user_role=1";
$from_users_assigned = $form_obj->adiha_form_dropdown($sp_url_from, 0, 1);
 
$sp_role_from = "EXEC spa_application_users @flag='z', @role='" . $role 
                . "', @include_exclude='e'" 
                . ", @user_role=0";
$from_roles = $form_obj->adiha_form_dropdown($sp_role_from, 0, 1);

$sp_role_from = "EXEC spa_application_users @flag='z', @role='" . $role 
                . "', @include_exclude='i'" 
                . ", @user_role=0";
$from_roles_assigned = $form_obj->adiha_form_dropdown($sp_role_from, 0, 1);
 
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
	    			{type: 'multiselect', label: 'Privilege to users', name: 'user_to', size:6,  options:" . $from_users_assigned . " , inputWidth:250}
    			]},
    			{type: 'block', width:630, list:[
	    			{type: 'multiselect', label: 'Role List', name: 'role_from', size:6,  options:" . $from_roles . " ,inputWidth:240},
	    			{type: 'newcolumn', offset:10},
	    			{type: 'block', width:100, list:[
	    				{type: 'button', name: 'add_role', value: '&#187;', offsetTop: 40, action:'static_data_privilege.button_click'},
	    				{type: 'button', name: 'remove_role', value: '&#171;', action:'static_data_privilege.button_click'}
	    			]},
	    			{type: 'newcolumn', offset:10},
	    			{type: 'multiselect', label: 'Privilege to roles', name: 'role_to', size:6,  options:" . $from_roles_assigned . ", inputWidth:250}
    			]}
    		]";

echo $form_obj->init_by_attach($form_name, $namespace);
echo $form_obj->load_form($form_json);
echo $form_obj->attach_event('', 'onButtonClick', 'static_data_privilege.button_click');
echo $layout_obj->close_layout();

?>
<script type="text/javascript">    
    var selected_row = '<?php echo get_sanitized_value($_POST['selected_row']); ?>';
	var user_name = '';
	function static_data_privilege_click() {
	    select_all_data('user_to');
        select_all_data('role_to');
        select_all_data('user_from');
        select_all_data('role_from');
		        
		var val_to_users = static_data_privilege.frm_sdp.getItemValue('user_to');
		var val_to_role = static_data_privilege.frm_sdp.getItemValue('role_to');
        var val_from_users = static_data_privilege.frm_sdp.getItemValue('user_from');
		var val_from_role = static_data_privilege.frm_sdp.getItemValue('role_from');
        
        val_to_users = (val_from_users == '') ? 'All' : val_to_users;
        val_to_role = (val_from_role == '') ? 'All' : val_to_role;
        val_to_users = (val_to_users == '') ? 'None' : val_to_users;
        val_to_role = (val_to_role == '') ? 'None' : val_to_role;
        user_name = (user_name == '') ? 'None' : user_name;
        
        parent.user_role_callback(val_to_users, val_to_role, selected_row, user_name);
    
        var win_obj = parent.static_data_privilege_win.window("w2");
        win_obj.close();
	}
	
	static_data_privilege.button_click = function(id) {
		if (id == "add" || id == "remove") {
		   changeContactState(id == "add", 'user_from', 'user_to');
		} else if (id == "add_role" || id == "remove_role") {
			changeContactState(id == "add_role", 'role_from', 'role_to');
		}
    }

	onload = function () {
		var from_users = static_data_privilege.frm_sdp.getSelect('user_from');
		var to_users = static_data_privilege.frm_sdp.getSelect('user_to');
		var from_roles = static_data_privilege.frm_sdp.getSelect('role_from');
		var roles_to = static_data_privilege.frm_sdp.getSelect('role_to');
		
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
		var sa = static_data_privilege.frm_sdp.getSelect(ida);
        var sb = static_data_privilege.frm_sdp.getSelect(idb);
        var t = static_data_privilege.frm_sdp.getItemValue(ida);
        
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
            show_messagebox(validation_empty);
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
    //        arr_texts[i] = sb.options[i].text;
    
            //if (idb == 'user_to' || idb == 'role_to')
            //    sb.options[i].selected = true;
        }

        //arr_texts.sort();
//
//        for (var i = 0; i < sb.length; i++) {
//            sb.options[i].text = arr_texts[i];
//        }
	}
    
    function select_all_data(name) {
        var sb = static_data_privilege.frm_sdp.getSelect(name);
        for (var i = 0; i < sb.length; i++) {
			if (name == 'user_to'){				
			user_name += sb.options[i].text + ',' ;				
			}			
		     sb.options[i].selected = true;
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

