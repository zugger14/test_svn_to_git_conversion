<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    </head>
    <?php 
    include '../../include.file.v3.php';
    $filter_id = isset($_GET['filter_id']) ? $_GET['filter_id'] : '';
	$call_from = isset($_GET['call_from']) ? $_GET['call_from'] : '';
    $filter_text = isset($_GET['filter_text']) ? $_GET['filter_text'] : '';
    $function_id = isset($_GET['function_id']) ? $_GET['function_id'] : '';
    $report_type = isset($_GET['report_type']) ? $_GET['report_type'] : '';
    
    $namespace = 'filter_publish';
    $form_name = 'filter_publish_form';
    
    $layout_obj = new AdihaLayout();
    $layout_json = '[{id: "a", header:false}]';
    echo $layout_obj->init_layout('layout', '', '1C', $layout_json, $namespace);
    echo $layout_obj->attach_form($form_name, 'a');
    
    $toolbar_obj = new AdihaToolbar();
    $toolbar_name = 'filter_publish_toolbar';
    $toolbar_json = '[ {id:"publish", type:"button", img:"save.gif", imgdis:"save_dis.gif", text:"Publish", title:"Publish", enabled:1}]';
    echo $layout_obj->attach_toolbar_cell($toolbar_name, 'a');
    echo $toolbar_obj->init_by_attach($toolbar_name, $namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', 'publish_apply_filter');
    
    $form_obj = new AdihaForm();
    
    $sp_url_from = "EXEC spa_application_users @flag='a'";
    $from_users = $form_obj->adiha_form_dropdown($sp_url_from, 0, 1);
    
    $sp_role_from = "EXEC spa_application_security_role @flag='s'";
    $from_roles = $form_obj->adiha_form_dropdown($sp_role_from, 0, 1);
    
    $publish_users = "EXEC spa_application_ui_filter @flag='k', @filter_id = '$filter_id' , @function_id = '$function_id'";
    $user_to = $form_obj->adiha_form_dropdown($publish_users, 0, 1);

    $sp_roles_to = "EXEC spa_application_ui_filter @flag = 'l', @filter_id = '$filter_id' , @function_id = '$function_id'";
    $roles_to =$form_obj->adiha_form_dropdown($sp_roles_to, 0, 1);
    
    $form_json = "[
        			{type: 'settings', position: 'label-top'},
                    {type: 'block', name:'left_list', blockOffset: ".$ui_settings['block_offset'].", width:740, list:[
    	    			{type: 'multiselect', label: 'User List', name: 'user_from', size:5,  options:" . $from_users . " ,'offsetLeft':".$ui_settings['offset_left'].",inputWidth:300},
    	    			{type: 'newcolumn', offset:10},
    	    			{type: 'block', width:100, list:[
    	    				{type: 'button', name: 'add', value: '&#187;', offsetTop:40},
    	    				{type: 'button', name: 'remove', value: '&#171;'}
    	    			]},
    	    			{type: 'newcolumn', offset:10},
    	    			{type: 'multiselect', label: 'Message to users', name: 'user_to', size:5, options:" . $user_to . " , inputWidth:300}
        			]},
        			{type: 'block', name:'right_list', blockOffset: ".$ui_settings['block_offset'].", list:[
    	    			{type: 'multiselect', label: 'Role List', name: 'role_from', size:5,  options:" . $from_roles . " ,'offsetLeft':".$ui_settings['offset_left'].",inputWidth:300},
    	    			{type: 'newcolumn', offset:10},
    	    			{type: 'block', width:100, list:[
    	    				{type: 'button', name: 'add_role', value: '&#187;', offsetTop: 40},
    	    				{type: 'button', name: 'remove_role', value: '&#171;'}
    	    			]},
    	    			{type: 'newcolumn', offset:10},
    	    			{type: 'multiselect', label: 'Message to role', name: 'role_to', size:5, options:" . $roles_to . " ,inputWidth:300}
                       
        			]},
                
                    {type: 'block',  blockOffset: ".$ui_settings['block_offset'].", list:[
                         {type:  'checkbox' ,'offsetLeft':".$ui_settings['offset_left'].",  position: 'label-right', name:'make_public', label: 'Make Public', checked:false}
                    ]}

        		]";
    
    echo $form_obj->init_by_attach($form_name, $namespace);
    echo $form_obj->load_form($form_json);
    echo $form_obj->attach_event('', 'onButtonClick', 'filter_publish.button_click');

    echo $form_obj->attach_event('', 'onChange', 'filter_publish.make_public');
    
    echo $layout_obj->close_layout();
    ?>
    <script type="text/javascript">
		var call_from = '<?php echo $call_from; ?>';
        var filter_text = '<?php echo $filter_text; ?>';
        var filter_id = '<?php echo $filter_id; ?>';
        var function_id = '<?php echo $function_id; ?>';
        var report_type = '<?php echo $report_type; ?>';

        $(function() {
            
            //var users = '<?php //echo $user_login_id; ?>//';
            //if (users != '') {
            //    var user_arr = users.split(',');
            //    for (cn = 0; cn < user_arr.length; cn++) {
            //        filter_publish.filter_publish_form.setItemValue('user_from', user_arr[cn]);
            //        changeContactState(true, 'user_from', 'user_to');
            //    }
            //}
            //var roles = '<?php //echo $role_id; ?>//';
            //
            //if (roles != '' && roles != 0) {
            //    var roles_arr = roles.split(',');
            //    for (cn = 0; cn < roles_arr.length; cn++) {
            //        filter_publish.filter_publish_form.setItemValue('role_from', roles_arr[cn]);
            //        changeContactState(true, 'role_from', 'role_to');
            //    }
            //}
          
            var from_users = filter_publish.filter_publish_form.getSelect('user_from');
    		var to_users = filter_publish.filter_publish_form.getSelect('user_to');
    		var from_roles = filter_publish.filter_publish_form.getSelect('role_from');
    		var roles_to = filter_publish.filter_publish_form.getSelect('role_to');
    		
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
          
            if(filter_text.indexOf('(Public)') !== -1) {
                filter_publish.filter_publish_form.checkItem('make_public');
                filter_publish.make_public ('make_public', '', true);
            }
            manageRolesFrom(); 
    	});
        
         
        filter_publish.button_click = function(id) {
    		if (id == "add" || id == "remove") {
    		   changeContactState(id == "add", 'user_from', 'user_to');
    		} else if (id == "add_role" || id == "remove_role") {
    			changeContactState(id == "add_role", 'role_from', 'role_to');
    		}
        }
        filter_publish.make_public = function(name, value, state) { 

            if (name == 'make_public') {
                if (state == true) {
                    filter_publish.filter_publish_form.disableItem('left_list');
                    filter_publish.filter_publish_form.disableItem('right_list');


                } else {
                    filter_publish.filter_publish_form.enableItem('left_list');
                    filter_publish.filter_publish_form.enableItem('right_list');

                }

            }
        }

        function manageRolesFrom(){
            var sa = filter_publish.filter_publish_form.getSelect('role_from');
            var sb = filter_publish.filter_publish_form.getSelect('role_to');
            var ua = filter_publish.filter_publish_form.getSelect('user_from');
            var ub = filter_publish.filter_publish_form.getSelect('user_to');
        
            var w = 0;
            var ind = -1;
            while (w < sa.options.length) {
                var wi = 0;
                var indi = -1;
                    while(wi<sb.options.length){
                        if(sa.options[w].value == sb.options[wi].value){
                            sa.options.remove(w);
                        }
                        wi++;
                    }
                w++

            }

            var a = 0;
            while(a < ua.options.length){
                var b = 0;
                while(b < ub.options.length) {
                    if(ua.options[a].value == ub.options[b].value){
                        ua.options.remove(a);
                    }
                    b++;
                }
                a++;
            }          
        }

    	function changeContactState(block, from, to) {   
            var ida = (block ? from : to);
            var idb = (block ? to : from);
    		var sa = filter_publish.filter_publish_form.getSelect(ida);
            var sb = filter_publish.filter_publish_form.getSelect(idb);
            var t = filter_publish.filter_publish_form.getItemValue(ida);
            
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
    
            //arr_texts.sort();
    
            for (var i = 0; i < sb.length; i++) {
                sb.options[i].text = arr_texts[i];
            }
    
    	}
        
        
        publish_apply_filter = function() {
            var filter_id = '<?php echo $filter_id; ?>';
            var role_to_obj = filter_publish.filter_publish_form.getOptions('role_to');
            var user_to_obj = filter_publish.filter_publish_form.getOptions('user_to');
            var user_role_xml = '';
            var is_make_public_checked = filter_publish.filter_publish_form.getItemValue('make_public')
            var flag = ''

            if (is_make_public_checked) {
                flag = 'e';
            } else {
                flag = 'p';
                var role_to = [];
                $.each(role_to_obj, function (index, value) {
                    role_to.push(role_to_obj[index]["value"]);
                });

                var user_to = [];
                $.each(user_to_obj, function (index, value) {
                    user_to.push(user_to_obj[index]["value"]);
                });
                
                user_role_xml = '<ApplicationFilter>';
                for (var i = 0; i < user_to.length; i++) {
                    user_role_xml += '<UserRole user_login_id="' + user_to[i] + '" role_id="" />';
                }

                for (var i = 0; i < role_to.length; i++) {
                    user_role_xml += '<UserRole user_login_id="" role_id="' + role_to[i] + '" />';
                }
                user_role_xml += '</ApplicationFilter>';
            }
            
           
            
			if (call_from == 'view') {
				data = {
					"action": "spa_pivot_report_view", 
					"flag": 'p',
					"xml_string": user_role_xml,
					"view_id": filter_id
				}
				result = adiha_post_data("alert", data, "", "", "");
				
			} else {
				data = {
					"action": "spa_application_ui_filter", 
					"flag": flag,
					"xml_string": user_role_xml,
					"filter_id": filter_id
				}
				result = adiha_post_data("alert", data, "", "", "publish_apply_filter_callback");
			}
        }

        function publish_apply_filter_callback(result) {
            if (result[0].errorcode == "Success") {
                update_form_filter_combo(parent.filter_form_object, function_id , report_type); 
        }
        
            else if (result[0].errorcode == "Error" && result[0].recommendation == "1") {
                dhtmlx.message({
                    type:  "alert" ,
                    title:  "Alert" ,
                    ok:  "Ok" ,
                    text: "This filter has already been made public. ",
                    callback: function(result) {
                            parent.win_doc.wins.window('w1').close();
                    }
                });
            }

            else if (result[0].errorcode == "Error" && result[0].recommendation == "Not Owner") {
                dhtmlx.message({
                    type:  "alert" ,
                    title:  "Alert" ,
                    ok:  "Ok" ,
                    text: "Only owner of the filter can update it. ",
                    callback: function(result) {
                            parent.win_doc.wins.window('w1').close();
                    }
                });
            }
        }

        function update_form_filter_combo(filter_form_obj, id, report_type) {

            var js_form_process_url = get_form_process_url();
            var combo_xml = '<ApplicationFilter application_function_id="' + id + '"></ApplicationFilter>';
            
            if (report_type == 1) {
                var combo_xml = '<ApplicationFilter report_id="' + id + '"></ApplicationFilter>';
            } else if (report_type == 2) {
                var combo_xml = '<ApplicationFilter application_function_id="' + id + '"></ApplicationFilter>';
            } else if (report_type == 3) {
                var combo_xml = '<ApplicationFilter report_id="' + id + '" application_function_id="10201700"></ApplicationFilter>';
            } else if (report_type == 4) { //for excel addin reports
                var combo_xml = '<ApplicationFilter report_id="' + id + '" application_function_id="10202600"></ApplicationFilter>';
            } else if (report_type == 5) { //for excel addin reports
                var combo_xml = '<ApplicationFilter report_id="' + id + '" application_function_id="10202700"></ApplicationFilter>';
            }

            var combo_data = {"action": "spa_application_ui_filter", "flag": "s", "xml_string": combo_xml};

           
            $.ajax({
            type: "POST",
                dataType: "json",
                url: js_form_process_url,
                async: true,
                data: combo_data,
                success: function(result) { 
                    response_data = result['json'];
                    var cmb_data = JSON.stringify(response_data);
                    cmb_data = (JSON.parse(cmb_data));
                    var cmb_obj = filter_form_obj.getCombo('apply_filters');
                    for (i = 0; i < (cmb_data.length); i++) {
                        if (filter_id == cmb_data[i].value) {
                            cmb_obj.updateOption(cmb_data[i].value, cmb_data[i].value, cmb_data[i].text);
                        }
                    }
                    parent.win_doc.wins.window('w1').close();
                }
            });

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