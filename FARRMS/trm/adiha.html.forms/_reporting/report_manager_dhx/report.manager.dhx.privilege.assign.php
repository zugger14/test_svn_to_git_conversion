<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  
        require_once('../../../adiha.php.scripts/components/include.file.v3.php');
        require_once('../../../adiha.php.scripts/components/include.ssrs.reporting.files.php'); 
    ?>
</head>
<body class = "bfix2">
    <div id="div_design_area"></div>
    <?php     
    
    $call_from = get_sanitized_value($_POST['call_from'] ?? 'NULL');
    $hash = get_sanitized_value($_POST['report_hash'] ?? 'NULL');
    $grid_row_id = get_sanitized_value($_POST['grid_row_id'] ?? '');
    $user_ids = get_sanitized_value($_POST['user_ids'] ?? '');
    $role_ids = get_sanitized_value($_POST['role_ids'] ?? '');
    
    $form_namespace = 'rpa';
    $json = "[
                {
                    id:         'a',
                    header: false
                }
            ]";
          
    $rpa_layout = new AdihaLayout();
    echo $rpa_layout->init_layout('layout', '', '1C', $json, $form_namespace);
    
    
    
    // attach menu
    $menu_json = '[{id: "ok", img:"tick.gif", img_disabled:"tick_dis.gif", text:"Ok", title:"Ok"}]';
    $menu_obj = new AdihaMenu();
    echo $rpa_layout->attach_menu_cell("rpa_menu", "a");  
    echo $menu_obj->init_by_attach("rpa_menu", $form_namespace);
    echo $menu_obj->load_menu($menu_json);
    echo $menu_obj->attach_event('', 'onClick', $form_namespace . '.menu_click');
    //print '<pre>';print_r($_POST);print '</pre>';die();
    
    echo $rpa_layout->attach_form('form_rpa', 'a');
    $form_obj = new AdihaForm();
    
    echo $form_obj->init_by_attach('form_rpa', $form_namespace);
    
    if($call_from == 'report_privilege') {
        $sp_url = "EXEC spa_rfx_report_privilege_dhx @flag='x', @report_hash='$hash', @report_privilege_type='e'";
        echo " user_list = " . $form_obj->adiha_form_dropdown($sp_url, 0, 1) . ";" . "\n";
        $sp_url = "EXEC spa_rfx_report_privilege_dhx @flag='u', @report_hash='$hash', @report_privilege_type='e'";
        echo "user_list_assigned = " . $form_obj->adiha_form_dropdown($sp_url, 0, 1) . ";" . "\n";
        
        $sp_url = "EXEC spa_rfx_report_privilege_dhx @flag='y', @report_hash='$hash', @report_privilege_type='e'";
        echo "role_list = " . $form_obj->adiha_form_dropdown($sp_url, 0, 1) . ";" . "\n";
        $sp_url = "EXEC spa_rfx_report_privilege_dhx @flag='r', @report_hash='$hash', @report_privilege_type='e'";
        echo "role_list_assigned = " . $form_obj->adiha_form_dropdown($sp_url, 0, 1) . ";" . "\n";
    } else if($call_from == 'paramset_privilege') {
        $sp_url = "EXEC spa_rfx_report_paramset_privilege_dhx @flag='x', @paramset_hash='$hash', @report_paramset_privilege_type='v'";
        echo " user_list = " . $form_obj->adiha_form_dropdown($sp_url, 0, 1) . ";" . "\n";
        $sp_url = "EXEC spa_rfx_report_paramset_privilege_dhx @flag='u', @paramset_hash='$hash', @report_paramset_privilege_type='v'";
        echo "user_list_assigned = " . $form_obj->adiha_form_dropdown($sp_url, 0, 1) . ";" . "\n";
        
        $sp_url = "EXEC spa_rfx_report_paramset_privilege_dhx @flag='y', @paramset_hash='$hash', @report_paramset_privilege_type='v'";
        echo "role_list = " . $form_obj->adiha_form_dropdown($sp_url, 0, 1) . ";" . "\n";
        $sp_url = "EXEC spa_rfx_report_paramset_privilege_dhx @flag='r', @paramset_hash='$hash', @report_paramset_privilege_type='v'";
        echo "role_list_assigned = " . $form_obj->adiha_form_dropdown($sp_url, 0, 1) . ";" . "\n";
    }
    
    
    /** update list from parent grid **/
    if($user_ids != '') {
        echo "
        $('" . $user_ids . "'.split(',')).each(function(key,val) {
            user_list = _.filter(user_list, function(item) {
                if(item.value == val) user_list_assigned.push(item);
                return item.value != val;
            });
        });
        ";
    }
    if($role_ids != '') {
        echo "
        $('" . $role_ids . "'.split(',')).each(function(key,val) {
            role_list = _.filter(role_list, function(item) {
                if(item.value == val) role_list_assigned.push(item);
                return item.value != val;
            });
        });
        ";
    }
    /** update list from parent grid **/
    
    $form_json = "[
            {type: 'settings', position: 'label-top'},
            {type:'block', list: [
                { type: 'fieldset', label: 'Users and Roles', width: 710, offsetTop:10, list: [
                    {type: 'block', width:680, list:[
    	    			{type: 'multiselect', label: 'User List', name: 'user_from', size:6,  options: user_list, inputWidth:250},
    	    			{type: 'newcolumn', offset:10},
    	    			{type: 'block', width:100, list:[
    	    				{type: 'button', name: 'add_user', className: 'arrow_right', value: '', offsetTop:40, title: 'Right', inputLeft: 20},
    	    				{type: 'button', name: 'remove_user', value: '', className: 'arrow_left', title: 'Left', inputLeft: 20}
    	    			]},
    	    			{type: 'newcolumn', offset:10},
    	    			{type: 'multiselect', label: 'Notify Users', name: 'user_to', size:6, inputWidth: 250, options: user_list_assigned},
        			]}, 
                    
                    {type: 'block', width:680, list:[
    	    			{type: 'multiselect', label: 'Role List', name: 'role_from', size:6,  options: role_list, inputWidth:250},
    	    			{type: 'newcolumn', offset:10},
    	    			{type: 'block', width:100, list:[
    	    				{type: 'button', name: 'add_role', className: 'arrow_right', value: '', offsetTop:40, title: 'Right', inputLeft: 20},
    	    				{type: 'button', name: 'remove_role', className: 'arrow_left', value: '', title: 'Left', inputLeft: 20}
    	    			]},
    	    			{type: 'newcolumn', offset:10},
    	    			{type: 'multiselect', label: 'Notify Roles', name: 'role_to', size:6, inputWidth: 250, options: role_list_assigned},
                    ]}
                ]}
            ]}
        ]";
    echo $form_obj->load_form($form_json);
    
    
    
    
    
    echo $rpa_layout->close_layout();
    
    
    ?>
</body>  
<script>
    var dhx_wins = new dhtmlXWindows();
    
    
    var post_data = '';
    var call_from = '<?php echo $call_from; ?>';
    var grid_row_id = '<?php echo $grid_row_id; ?>';
    var user_ids = '<?php echo $user_ids; ?>';
    var role_ids = '<?php echo $role_ids; ?>';
    
    
    
    $(function(){
        form_obj = rpa.form_rpa;
        form_obj.attachEvent('onButtonClick', function(id) {
            if (id == 'add_user' || id == 'remove_user') {
                change_contact_state(id == 'add_user', 'user_from', 'user_to');
            } else if (id == 'add_role' || id == 'remove_role') {
                change_contact_state(id == 'add_role', 'role_from', 'role_to');
            }         
        });     
        
        if(user_ids != '') {
            
            //change_contact_state(true, 'user_from', 'user_to');
        }   
    });
    
    rpa.menu_click = function(id) {
        if(id == 'ok') {
            selected_values = {};
            selected_values.assigned_users_values = get_all_list_values(form_obj.getOptions('user_to'), 'v');
            selected_values.assigned_roles_values = get_all_list_values(form_obj.getOptions('role_to'), 'v');
            selected_values.assigned_users_labels = get_all_list_values(form_obj.getOptions('user_to'), 'l');
            selected_values.assigned_roles_labels = get_all_list_values(form_obj.getOptions('role_to'), 'l');
            
            parent.rp.fx_set_user_role(selected_values, grid_row_id, call_from);
            
        }
    };

    function change_contact_state(block, from, to) {   
        var ida = (block ? from : to); 
        var idb = (block ? to : from);
		var sa = form_obj.getSelect(ida);
        var sb = form_obj.getSelect(idb);
        var t = form_obj.getItemValue(ida);
        
        var validation_empty = '';

        if (t.length == 0) {
            if (from == 'user_from') {
                if (block === true) {
                    validation_empty = 'Please select User from User List.';    
                } else {
                    validation_empty = 'Please select User from Notify Users.'; 
                }
            } else if (from == 'role_from') {
                if (block === true) {
                    validation_empty = 'Please select Role from Roles List.';    
                } else {
                    validation_empty = 'Please select Role from Notify Roles.'; 
                }
            } 
            
            dhtmlx.alert({text: validation_empty});
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

        for (var i = 0; i < sb.length; i++) {
            arr_texts[i] = sb.options[i].text;
        }

        arr_texts.sort();

        for (var i = 0; i < sb.length; i++) {
            sb.options[i].text = arr_texts[i];
        }

	}
    
    onload = function () {
		var from_users = form_obj.getSelect('user_from');
		var to_users = form_obj.getSelect('user_to');
		var from_roles = form_obj.getSelect('role_from');
		var roles_to = form_obj.getSelect('role_to');
		
		from_users.ondblclick = function () {
			change_contact_state(true, 'user_from', 'user_to');
		}

		to_users.ondblclick = function () {
			change_contact_state(false, 'user_from', 'user_to');
		}

		from_roles.ondblclick = function () {
			change_contact_state(true, 'role_from', 'role_to');
		}

		roles_to.ondblclick = function () {
			change_contact_state(false, 'role_from', 'role_to');
		}
	}
    
    function get_all_list_values(item_options, type) {
      var opt = "";
      var result = "";
      for (var i=0, len=item_options.length; i<len; i++) {
        opt = item_options[i];
        var extract_value = (type == 'v' ? opt.value : opt.text);
        if (i == 0) {
            result = extract_value;
        }else{    
            result = result + "," + extract_value;
        }    
      }
       return result;
    }
    
    
    
    //ajax setup for default values
    $.ajaxSetup({
        method: 'POST',
        dataType: 'json',
        error: function(jqXHR, text_status, error_thrown) {
            console.log('*** Error on ajax: ' + text_status + ', ' + error_thrown);
        }
    });
</script>