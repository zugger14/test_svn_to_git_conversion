<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
        <script src="../../../adiha.php.scripts/components/lib/adiha_dhtmlx/adiha_scheduler_3.0/dhtmlxscheduler.js" type="text/javascript"></script>
        <?php require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
    </head>
    <body>
    <?php
    $function_id = 10106800;
    $namespace = 'share_calendar';
    
    $sp_user_calendar  = "EXEC spa_calendar @flag= 'f'";
    $user_calendar = readXMLURL2($sp_user_calendar);
    $user_login_id = $user_calendar[0]['user_id'];
    $role_id = $user_calendar[0]['role_id'];;
    $share_calendar = $user_calendar[0]['share_calendar'];
	$action_permission = $user_calendar[0]['action_permission'];
    
    $layout_obj = new AdihaLayout();
    $layout_json = '[{id: "a", header:false}]';
    echo $layout_obj->init_layout('layout', '', '1C', $layout_json, $namespace);
    
    $toolbar_obj = new AdihaToolbar();
    $toolbar_name = 'toolbar';
    $toolbar_json = '[ {id:"save", type:"button", img:"save.gif", imgdis:"save_dis.gif", text:"Save", title:"Save"}]';
    
    echo $layout_obj->attach_toolbar_cell($toolbar_name, 'a');
    echo $toolbar_obj->init_by_attach($toolbar_name, $namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', 'save_click');
    
    $form_obj = new AdihaForm();
    $form_name = 'share_calendar_form';
    
    $sp_url_from = "EXEC spa_application_users @flag='a'";
    $from_users = $form_obj->adiha_form_dropdown($sp_url_from, 0, 1);
    
    $sp_role_from = "EXEC spa_application_security_role @flag='s'";
    $from_roles = $form_obj->adiha_form_dropdown($sp_role_from, 0, 1);
    
    $form_json = "[
        			{type: 'settings', position: 'label-top',offsetLeft:0},
                    {
                        type: 'block',
                        blockOffset: 10,
                        offsetTop: 20,                        
                        list: [
                                {
                                    'type': 'checkbox',
                                    'name': 'share_calendar',
                                    'label': 'Share Calendar',
                                    'hidden': 'false',
                                    'disabled': 'false',
                                    'position': 'label-right',
                                    'labelWidth': 'auto',
                                    'tooltip': 'Share Calendar',
                                    'checked':'$share_calendar'
                                },{type: 'newcolumn'},
								{
                                    'type': 'checkbox',
                                    'name': 'action_permission',
                                    'label': 'Allow To Perform Action',
                                    'hidden': 'false',
                                    'disabled': 'false',
                                    'position': 'label-right',
                                    'labelWidth': 'auto',
                                    'tooltip': 'Allow To Perform Action',
                                    'checked':'$action_permission'
                                }
                            ]
                    },
                    {type: 'block',blockOffset: 10, width:630, list:[
    	    			{type: 'multiselect', label: 'User List', name: 'user_from', size:5,  options:" . $from_users . " ,inputWidth:240},
    	    			{type: 'newcolumn', offset:10},
    	    			{type: 'block', width:100, list:[
    	    				{type: 'button', name: 'add', value: '>>', offsetTop:25},
    	    				{type: 'button', name: 'remove', value: '<<'}
    	    			]},
    	    			{type: 'newcolumn', offset:10},
    	    			{type: 'multiselect', label: 'Share to users', name: 'user_to', size:5, inputWidth:250}
        			]},
        			{type: 'block',blockOffset: 10, width:630, list:[
    	    			{type: 'multiselect', label: 'Role List', name: 'role_from', size:5,  options:" . $from_roles . " ,inputWidth:240},
    	    			{type: 'newcolumn', offset:10},
    	    			{type: 'block', width:100, list:[
    	    				{type: 'button', name: 'add_role', value: '>>', offsetTop: 25, action:'send_message.button_click'},
    	    				{type: 'button', name: 'remove_role', value: '<<', action:'send_message.button_click'}
    	    			]},
    	    			{type: 'newcolumn', offset:10},
    	    			{type: 'multiselect', label: 'Share to roles', name: 'role_to', size:5, inputWidth:250}
        			]}
        		]";
    echo $layout_obj->attach_form($form_name, 'a');
    echo $form_obj->init_by_attach($form_name, $namespace);
    echo $form_obj->load_form($form_json);
    echo $form_obj->attach_event('', 'onButtonClick', 'share_calendar.button_click');
    echo $form_obj->attach_event('', 'onChange', 'share_calendar.on_change_checkbox');
    
    echo $layout_obj->close_layout();
    ?>
    </body>
    <script type="text/javascript" charset="utf-8">
        $(function() {
            var shared_calendar = '<?php echo $share_calendar; ?>';
            if (shared_calendar == 1) {
                enable_disable_form(true);
            } else {
                enable_disable_form(false);
            }
            
            var users = '<?php echo $user_login_id; ?>';
            if (users != '') {
                var user_arr = users.split(',');
                for (cn = 0; cn < user_arr.length; cn++) {
                    share_calendar.share_calendar_form.setItemValue('user_from', user_arr[cn]);  
                    changeContactState(true, 'user_from', 'user_to');
                }
            }
            var roles = '<?php echo $role_id; ?>';
            
            if (roles != '' && roles != 0) {
                var roles_arr = roles.split(',');
                for (cn = 0; cn < roles_arr.length; cn++) {
                    share_calendar.share_calendar_form.setItemValue('role_from', roles_arr[cn]);  
                    changeContactState(true, 'role_from', 'role_to');
                }
            }
            
            var from_users = share_calendar.share_calendar_form.getSelect('user_from');
    		var to_users = share_calendar.share_calendar_form.getSelect('user_to');
    		var from_roles = share_calendar.share_calendar_form.getSelect('role_from');
    		var roles_to = share_calendar.share_calendar_form.getSelect('role_to');
    		
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
        
        function save_click(id) {
            switch(id) {
                case "save":
                    var role_to_obj = share_calendar.share_calendar_form.getOptions('role_to');
                    var user_to_obj = share_calendar.share_calendar_form.getOptions('user_to');
                    var is_share_calendar = (share_calendar.share_calendar_form.isItemChecked('share_calendar')) ? 'y' : 'n';
					var action_permission = (share_calendar.share_calendar_form.isItemChecked('action_permission')) ? 'y' : 'n';
                    
                    var role_to = [];
                    $.each(role_to_obj, function (index, value) {
                    	role_to.push(role_to_obj[index]["value"]);
                    });
                    
                    var user_to = [];
                    $.each(user_to_obj, function (index, value) {
                    	user_to.push(user_to_obj[index]["value"]);
                    });
                    
                    var user_role_xml = '<Root>';
                    for (var i = 0; i < user_to.length; i++) {
                        user_role_xml += '<FormXML user_login_id="' + user_to[i] + '" role_id=""></FormXML>';
                    }
                    
                    for (var i = 0; i < role_to.length; i++) {
                        user_role_xml += '<FormXML user_login_id="" role_id="' + role_to[i] + '"></FormXML>';
                    }
                    user_role_xml += '</Root>';
                    
					if (is_share_calendar == 'y' && action_permission == 'y') {
						var is_shared = 2; // Share with action permission
					} else if (is_share_calendar == 'y')
                        var is_shared = 1; // // Share with view permission
                    else
                        var is_shared = 0;
                    
                    data = {
                                "action": "spa_calendar", 
                                "flag": 'e',
                                "xml": user_role_xml,
                                "is_shared": is_shared
                            }
                    adiha_post_data("alert", data, "", "", "");
                    break;
                default:
                    break;
            }
        }
        
        share_calendar.on_change_checkbox = function(name, value, state) {
            if (name == 'share_calendar') {
                if (state) {
                    enable_disable_form(true);
                } else {
                    enable_disable_form(false);
                }
            }
        }
        
        function enable_disable_form(state) {
            if (state) {
                share_calendar.share_calendar_form.enableItem('user_to');
                share_calendar.share_calendar_form.enableItem('user_from');
                share_calendar.share_calendar_form.enableItem('role_from');
                share_calendar.share_calendar_form.enableItem('role_to');
                
                share_calendar.share_calendar_form.enableItem('add_role');
                share_calendar.share_calendar_form.enableItem('remove_role');
                share_calendar.share_calendar_form.enableItem('add');
                share_calendar.share_calendar_form.enableItem('remove');
            } else {
                share_calendar.share_calendar_form.disableItem('user_to');
                share_calendar.share_calendar_form.disableItem('user_from');
                share_calendar.share_calendar_form.disableItem('role_from');
                share_calendar.share_calendar_form.disableItem('role_to');
                
                share_calendar.share_calendar_form.disableItem('add_role');
                share_calendar.share_calendar_form.disableItem('remove_role');
                share_calendar.share_calendar_form.disableItem('add');
                share_calendar.share_calendar_form.disableItem('remove');
            }
        }
        
        share_calendar.button_click = function(id) {
    		if (id == "add" || id == "remove") {
    		   changeContactState(id == "add", 'user_from', 'user_to');
    		} else if (id == "add_role" || id == "remove_role") {
    			changeContactState(id == "add_role", 'role_from', 'role_to');
    		}
        }
        
    	function changeContactState(block, from, to) {   
            var ida = (block ? from : to);
            var idb = (block ? to : from);
    		var sa = share_calendar.share_calendar_form.getSelect(ida);
            var sb = share_calendar.share_calendar_form.getSelect(idb);
            var t = share_calendar.share_calendar_form.getItemValue(ida);
            
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
    		eval('var k={"'+t.join(':true,')+'":true};');
    
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
    </style>
</html>