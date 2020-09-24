<?php
/**
* Workflow rule message screen
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
    include "../../../adiha.php.scripts/components/include.file.v3.php";
    $rule_id = get_sanitized_value($_GET["rule_id"] ?? '');
    $template = get_sanitized_value($_GET['template'] ?? '');
    $message_id= get_sanitized_value($_GET['message_id']?? '');
    $parent_id = get_sanitized_value($_GET['parent_id'] ?? '');
	$call_from = get_sanitized_value($_GET["call_from"] ?? '');
	$module_id = get_sanitized_value($_GET["module_id"] ?? '');
	$source_id = get_sanitized_value($_GET["source_id"] ?? '');
    $action = get_sanitized_value($_GET["action"] ?? '');
	$error_success = get_sanitized_value($_GET["error_success"] ?? '');
	$message_name_notification = '';
	$message_tag  = '';

    if ($call_from == 'import_notification') {
           $sql = "EXEC spa_ixp_import_data_source @flag = 'a',@rules_id = ". $source_id .",@error_success = $error_success ";
		   $return_value = readXMLURL2($sql);
		   $message_id = $return_value[0]['message_id'];
		   $action = $return_value[0]['action'];
		   $message_name_notification = $return_value[0]['notification_name'];	
		   
		   $sql_tag = "EXEC spa_setup_rule_workflow @flag = 'tag',@module_id =  $module_id ";
		   $return_value = readXMLURL2($sql_tag); 
		   $message_tag = $return_value[0]['workflow_message_tag'];			  
		 }  

    if ($message_id != '') {
        $sql = "EXEC spa_setup_rule_workflow @flag='a',@message_id=$message_id";
        $return_value = readXMLURL2($sql);
        $message_name = $return_value[0]['message_name'];
        $notification_type = $return_value[0]['notification_type'];
        $message = $return_value[0]['message'];
        $self_notify = $return_value[0]['self_notify'];
        if ($self_notify == 'y') 
            $self_notify = 'n'; 
        elseif ($self_notify == 'n') 
            $self_notify = 'y';
        
        $approval_req = $return_value[0]['approval_required'];
        $mult_approval_req = $return_value[0]['mult_approval_required'];
        $comment_req = $return_value[0]['comment_required'];
        $notify_trader = $return_value[0]['notify_trader'];
        $next_module_events_id = $return_value[0]['next_module_events_id'];
        $minimum_approval_required = $return_value[0]['minimum_approval_required'];
        $optional_event_msg = $return_value[0]['optional_event_msg'];
        
        $user_login_id = $return_value[0]['user_login_id'];
        $role_id = $return_value[0]['role_id'];
		$start_date = $return_value[0]['start_date'];
		$reminder_days = $return_value[0]['reminder_days'];
		$include_holiday = $return_value[0]['include_holiday'];
    } else {
        $message_name = '';
        $notification_type = '';
        $message = '';
        $self_notify = '';
        $approval_req = '';
        $mult_approval_req = '';
        $comment_req = '';
        $notify_trader = '';
        $next_module_events_id = '';
        $minimum_approval_required = '';
        $optional_event_msg = '';
        
        $user_login_id = '';
        $role_id = '';
		$start_date = '';
		$reminder_days = '';
		$include_holiday = '';
    }

    $rights_save = 10106610;
    $rights_delete = 10106611;

    list (
        $has_rights_save,
        $has_rights_delete
    ) = build_security_rights(
        $rights_save,
        $rights_delete
    );

    $has_rights_save = ($has_rights_save=='')?'false':'true';
    $has_rights_delete = ($has_rights_delete=='')?'false':'true';
    
    $namespace = 'workflow_rule_message';
    $form_name = 'workflow_rule_message_form';
    $tabbar_name = 'workflow_rule_message_tabbar';
    
    $layout_obj = new AdihaLayout();
    $form_obj = new AdihaForm();
    $toolbar_obj = new AdihaToolbar();
    $tabbar_obj = new AdihaTab();
    
    $layout_json = '[{id: "a", header:false}]';
    $tabbar_json = '[{id:"a", text:"Message", active:"true" }, {id:"b", text:"Document/Contact"}, {id:"c", text:"Report"}]';
    
    echo $layout_obj->init_layout('layout', '', '1C', $layout_json, $namespace);
    echo $layout_obj->attach_tab_cell($tabbar_name, 'a', $tabbar_json);
    
    echo $tabbar_obj->init_by_attach($tabbar_name, $namespace);
    echo $tabbar_obj->attach_form_cell($form_name, 'a');
    
    $toolbar_name = 'toolbar_workflow_rule_message';
    $toolbar_namespace = 'workflow_rule_message';
    $tree_toolbar_json = '[ {id:"save", type:"button", img:"save.gif", imgdis:"save_dis.gif", text:"Save", title:"Save", enabled:' . $has_rights_save . '}]';
    
    echo $layout_obj->attach_toolbar_cell($toolbar_name, 'a');
    echo $toolbar_obj->init_by_attach($toolbar_name, $namespace);
    echo $toolbar_obj->load_toolbar($tree_toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', 'save_click');
    
    $sp_url_from = "EXEC spa_application_users @flag='a'";
    $from_users = $form_obj->adiha_form_dropdown($sp_url_from, 0, 1);
    
    $sp_role_from = "EXEC spa_application_security_role @flag='s'";
    $from_roles = $form_obj->adiha_form_dropdown($sp_role_from, 0, 1);
    
    $message_template_sql = 'EXEC spa_setup_rule_workflow @flag=t';
    $message_template = $form_obj->adiha_form_dropdown($message_template_sql, 0, 1, true);
    

    $notification_type_sql = "EXEC('EXEC spa_StaticDataValues @flag = ''h'', @type_id = 750, @code = ''Alert,Email,Message Board''')";
    $notification_type_optn = $form_obj->adiha_form_dropdown($notification_type_sql, 0, 1, false, '');
    
    $doc_type_sql = "EXEC('SELECT DISTINCT value_id, code FROM static_data_value INNER JOIN Contract_report_template ON value_id = template_type WHERE type_id = 25 ORDER BY code')";
    $doc_type = $form_obj->adiha_form_dropdown($doc_type_sql, 0, 1, false);
    
    $contact_type_sql = "EXEC('EXEC spa_StaticDataValues @flag = ''h'', @type_id = 32200')";
    $contact_type = $form_obj->adiha_form_dropdown($contact_type_sql, 0, 1, true, '', 2);
    
    $delivery_method_sql = "EXEC('EXEC spa_StaticDataValues @flag = ''h'', @type_id = 21300, @value_ids = ''21301,21302,21304''')";
    $delivery_method = $form_obj->adiha_form_dropdown($delivery_method_sql, 0, 1, true, '', 2);
    
    $sp_next_module_event = "EXEC spa_setup_rule_workflow @flag='s', @message_id='" . $message_id . "'";
    $opt_next_module_event = $form_obj->adiha_form_dropdown($sp_next_module_event, 0, 1, true, $next_module_events_id);
    
    $sp_report_name = "EXEC ('SELECT paramset_hash, name FROM report_paramset ORDER BY name')";
    $opt_report_name = $form_obj->adiha_form_dropdown($sp_report_name, 0, 1, true);

    $sp_report_writer = "EXEC ('EXEC spa_setup_rule_workflow @flag = ''9'', @call_from = ''workflow''')";
    $opt_report_writer = $form_obj->adiha_form_dropdown($sp_report_writer, 0, 1, false);

    $email_group_sql = "EXEC('EXEC spa_setup_rule_workflow @flag = ''email_group'', @message_id = ''$message_id'', @group_type = ''e''')";
    $email_group = $form_obj->adiha_form_dropdown($email_group_sql, 0, 1, true);

    $email_group_cc_sql = "EXEC('EXEC spa_setup_rule_workflow @flag = ''email_group'', @message_id = ''$message_id'', @group_type = ''c''')";
    $email_group_cc = $form_obj->adiha_form_dropdown($email_group_cc_sql, 0, 1, true);

    $email_group_bcc_sql = "EXEC('EXEC spa_setup_rule_workflow @flag = ''email_group'', @message_id = ''$message_id'', @group_type = ''b''')";
    $email_group_bcc = $form_obj->adiha_form_dropdown($email_group_bcc_sql, 0, 1, true);
    
    $file_type_sql = "EXEC spa_setup_rule_workflow @flag = '10'";
    $opt_file_type = $form_obj->adiha_form_dropdown($file_type_sql, 0, 1, true);

    $form_json = "[
        			{type: 'settings', position: 'label-top'},
                    {
                        type: 'block',
                        blockOffset: ".$ui_settings['block_offset'].",
                        list: [{
                            'type': 'input',
                            'name': 'event_message_name',
                            'label': 'Name',
                            'validate': 'NotEmpty',
                            'required': true,
                            'hidden': 'false',
                            'disabled': 'false',
                            'position': 'label-top',
                            'offsetLeft':".$ui_settings['offset_left'].",
                            'inputWidth': ".$ui_settings['field_size'].",
                            'labelWidth': 'auto',
                            'tooltip': 'Name',
                            'userdata': {
                                'validation_message': 'Required Field'
                            },
                            'value':'$message_name'
                        },{
                            type: 'newcolumn'
                        },{
                            'type': 'combo',
                            'name': 'notification_type',
                            'label': 'Notification Type',
                            'hidden': 'false',
                            'disabled': 'false',
                            'position': 'label-top',
                            'offsetLeft':".$ui_settings['offset_left'].",
                            'inputWidth': ".$ui_settings['field_size'].",
                            'labelWidth': 'auto',
                            'filtering': true,
                            'filtering_mode':'between',
                            'tooltip': 'Notification Type',
                            'comboType':'custom_checkbox',
                            'options': $notification_type_optn
                        },{
                            type: 'newcolumn'
                        },{
                            'type': 'combo',
                            'name': 'next_module_events_id',
                            'label': 'Next Workflow',
                            'hidden': 'false',
                            'disabled': 'false',
                            'position': 'label-top',
                            'offsetLeft':".$ui_settings['offset_left'].",
                            'inputWidth': ".$ui_settings['field_size'].",
                            'labelWidth': 'auto',
                            'filtering': true,
                            'filtering_mode':'between',
                            'tooltip': 'Message Template',
                            'options': $opt_next_module_event
                        }]
                    },{
                        type: 'block',
                        blockOffset: ".$ui_settings['block_offset'].",
                        list: [
                        {
                            'type': 'input',
                            'name': 'message',
                            'label': 'Message (<i>Right click on message box for system defined tags</i>)',
                            'hidden': 'false',
                            'disabled': 'false',
                            'position': 'label-top',
                            'offsetLeft':".$ui_settings['offset_left'].",
                            'inputWidth': 720,
                            'labelWidth': 'auto',
                            'tooltip': 'Message',
                            'rows': 4,
                            'value':'$message'
                        }]
                    }, {type: 'block', blockOffset: ".$ui_settings['block_offset'].", width:740, list:[
    	    			{type: 'multiselect', label: 'User List', name: 'user_from', size:5,  options:" . $from_users . " ,'offsetLeft':".$ui_settings['offset_left'].",inputWidth:300},
    	    			{type: 'newcolumn', offset:10},
    	    			{type: 'block', width:100, list:[
    	    				{type: 'button', name: 'add', value: '&#187;', offsetTop:40},
    	    				{type: 'button', name: 'remove', value: '&#171;'}
    	    			]},
    	    			{type: 'newcolumn', offset:10},
    	    			{type: 'multiselect', label: 'Message to users', name: 'user_to', size:5, inputWidth:300}
        			]},
        			{type: 'block', blockOffset: ".$ui_settings['block_offset'].", list:[
    	    			{type: 'multiselect', label: 'Role List', name: 'role_from', size:5,  options:" . $from_roles . " ,'offsetLeft':".$ui_settings['offset_left'].",inputWidth:300},
    	    			{type: 'newcolumn', offset:10},
    	    			{type: 'block', width:100, list:[
    	    				{type: 'button', name: 'add_role', value: '&#187;', offsetTop: 40, action:'send_message.button_click'},
    	    				{type: 'button', name: 'remove_role', value: '&#171;', action:'send_message.button_click'}
    	    			]},
    	    			{type: 'newcolumn', offset:10},
    	    			{type: 'multiselect', label: 'Message to role', name: 'role_to', size:5, inputWidth:300}
        			]},{
                        type: 'block',
                        blockOffset: ".$ui_settings['block_offset'].",
                        list: [
                        {
                            'type': 'checkbox',
                            'name': 'self_notify',
                            'label': 'Do not Self Notify',
                            'hidden': 'false',
                            'disabled': 'false',
                            'position': 'label-right',
                            'offsetLeft':".$ui_settings['offset_left'].",
                            'labelWidth': 127,
                            'tooltip': 'Do not Self Notify',
                            'checked':'$self_notify'
                        },{
                            type: 'newcolumn'
                        },{
                            'type': 'checkbox',
                            'name': 'comment_req',
                            'label': 'Comment Required',
                            'hidden': 'false',
                            'disabled': 'false',
                            'position': 'label-right',
                            'labelWidth': 'auto',
                            'offsetLeft':".$ui_settings['offset_left'].",
                            'tooltip': 'Comment Required',
                            'checked':'$comment_req'
                        },{
                            type: 'newcolumn'
                        },{
                                'type': 'checkbox',
                                'name': 'optional_event_msg',
                                'label': 'Optional Approval',
                                'hidden': 'false',
                                'disabled': 'false',
                                'position': 'label-right',
                                'labelWidth': 'auto',
                                'offsetLeft':".$ui_settings['offset_left'].",
                                'tooltip': 'Optional Approval',
                                'checked':'$optional_event_msg'
                        },{
                            type: 'newcolumn'
                        },{
                            'type': 'checkbox',
                            'name': 'notify_trader',
                            'label': 'Send Notification to Trader',
                            'hidden': 'false',
                            'disabled': 'false',
                            'position': 'label-right',
                            'labelWidth': 'auto',
                            'offsetLeft':".$ui_settings['offset_left'].",
                            'tooltip': 'Send Notification to Trader',
                            'checked':'$notify_trader'
                        }
                    ]},{
                        type: 'block',
                        blockOffset: ".$ui_settings['block_offset'].",
                        list: [
                                {'type':'fieldset',name:'multiple_approval_group','label':'In Case of Multiple Approval Needed','offsetLeft':'15','offsetTop':'0','inputLeft ':'500','inputTop':'500','width':'530','list': [
                                {
                                    'type': 'checkbox',
                                    'name': 'mult_app_req',
                                    'label': 'Multiple Approval Required',
                                    'hidden': 'false',
                                    'disabled': 'false',
                                    'position': 'label-right',
                                    'labelWidth': 'auto',
                                    'offsetLeft':".$ui_settings['offset_left'].",
                                    'tooltip': 'Multiple Approval Required',
                                    'checked':'$mult_approval_req'
                                },{
                                    type: 'newcolumn'
                                },{
                                    'type': 'input',
                                    'name': 'minimum_approval_required',
                                    'label': 'Minimum No. of Approvers',
                                    'hidden': 'false',
                                    'disabled': 'false',
                                    'position': 'label-right',
                                    'inputWidth': 35,
                                    'labelWidth': 'auto',
                                    'offsetLeft':".$ui_settings['offset_left'].",
                                    'tooltip': 'Minimum No. of Approvers',
                                    'value':'$minimum_approval_required'
                                }
                                ]}
                            ]
                        }
        		]";
    
    echo $form_obj->init_by_attach($form_name, $namespace);
    echo $form_obj->load_form($form_json);
    echo $form_obj->attach_event('', 'onChange', 'workflow_rule_message.trader_change');
    echo $form_obj->attach_event('', 'onButtonClick', 'workflow_rule_message.button_click');
    
     /*------- Document Contact Tab ----- */
    $contact_layout_obj = new AdihaLayout();
    echo $tabbar_obj->attach_layout('contact_layout', 'b', '1C');
    echo $contact_layout_obj->init_by_attach('contact_layout', $namespace);
    
    $document_contacts_json = '[
                                    {id:"t1", text:"Edit", img:"edit.gif", items:[
                                        {id:"add_c", text:"Add Document/Contact", img:"new.gif", imgdis:"new_dis.gif", title: "Add Document/Contact", enabled:' . $has_rights_save . '},
                                        {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete",disabled: true}
                                    ]}
                             ]';
    
    echo $contact_layout_obj->attach_menu_layout_cell("document_contacts", "a", $document_contacts_json, 'document_contact_click'); 
    
    $grid_name = 'workflow_rule_message_grid';
    echo $contact_layout_obj->attach_grid_cell($grid_name, 'a');    
    $grid_obj = new GridTable('document_contacts');
    echo $grid_obj->init_grid_table($grid_name, $namespace);
    echo $grid_obj->return_init();
    echo $grid_obj->load_grid_data();
    echo $grid_obj->attach_event('','onRowDblClicked','contact_update');
    echo $grid_obj->attach_event('','onRowSelect','contact_row_select');
    echo $grid_obj->load_grid_functions();
    
    /*------- Alert Reports Tab ----- */
    $report_layout_obj = new AdihaLayout();
    echo $tabbar_obj->attach_layout('report_layout', 'c', '1C');
    echo $report_layout_obj->init_by_attach('report_layout', $namespace);
    
    $report_menu_json = '[
                                    {id:"t1", text:"Edit", img:"edit.gif", items:[
                                        {id:"add", text:"Add Document", img:"new.gif", imgdis:"new_dis.gif", title: "Add", enabled:' . $has_rights_save . '},
                                        {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete",disabled: true}
                                    ]}
                             ]';
    
    echo $report_layout_obj->attach_menu_layout_cell("report_menu", "a", $report_menu_json, 'report_menu_click'); 
    
    $grid_name = 'alert_report_grid';
    echo $report_layout_obj->attach_grid_cell($grid_name, 'a');    
    $grid_obj = new GridTable('alert_reports');
    echo $grid_obj->init_grid_table($grid_name, $namespace);
    echo $grid_obj->return_init();
    echo $grid_obj->load_grid_data();
    if ($template != 't') {
        echo $grid_obj->attach_event('','onRowDblClicked','report_update');
    }
    echo $grid_obj->attach_event('','onRowSelect','report_row_select');
    echo $grid_obj->load_grid_functions();
    
    echo $layout_obj->close_layout();
    
    $tag_options_sql = "EXEC spa_setup_rule_workflow @flag = '7', @workflow_id='" . $parent_id . "', @module_id='" . $module_id . "'";
    $return_value = readXMLURL2($tag_options_sql);
    $tag_options = $return_value[0]['tag_options'];
	
	$default_doc_type_sql = "EXEC spa_setup_rule_workflow @flag=8, @message_id='" . $message_id . "'";
    $return_value = readXMLURL2($default_doc_type_sql);
    $default_doc_type = $return_value[0]['document_type'] ?? '';
    ?>
    <script type="text/javascript">
        var has_rights_save = Boolean(<?php echo $has_rights_save ?>);
        var has_rights_delete = Boolean(<?php echo $has_rights_delete ?>);
        var message_id = '<?php echo (isset($message_id)?$message_id:""); ?>';
        var rule_id = '<?php echo (isset($rule_id)?$rule_id:""); ?>';
		var template = '<?php echo (isset($template)?$template:""); ?>';
        var parent_id = '<?php echo (isset($parent_id)?$parent_id:""); ?>';
        var noti_type = '<?php echo (isset($notification_type)?$notification_type:""); ?>';
		var default_doc_type = '<?php echo (isset($default_doc_type)?$default_doc_type:""); ?>';
        var call_from = '<?php echo (isset($call_from)?$call_from:""); ?>';
		var module_id = '<?php echo (isset($module_id)?$module_id:""); ?>';
		var source_id = '<?php echo (isset($source_id)?$source_id:""); ?>';
        var action = '<?php echo (isset($action)?$action:""); ?>';
        var tag_zones = {};
        var tag_menu_items = '';

        $(function() {
            var tag_options = '<?php echo $tag_options; ?>';
            var notification_type_obj = workflow_rule_message.workflow_rule_message_form.getCombo('notification_type');
            var noti_type_arr = noti_type.split(',');
            for (cnt = 0; cnt < noti_type_arr.length; cnt++) {
                var indx = notification_type_obj.getIndexByValue(noti_type_arr[cnt]);
                notification_type_obj.setChecked(indx, true);
            }
            
            if (template == 't') {
                workflow_rule_message.toolbar_workflow_rule_message.disableItem('save');
                workflow_rule_message.document_contacts.setItemDisabled('t1');
                workflow_rule_message.report_menu.setItemDisabled('t1');
            }
            
            workflow_rule_message.contact_layout.cells('a').hideHeader();
            workflow_rule_message.report_layout.cells('a').hideHeader();
            refresh_contact_grid();
            refresh_report_grid();
            
            var users = '<?php echo $user_login_id; ?>';
            if (users != '') {
                var user_arr = users.split(',');
                for (cn = 0; cn < user_arr.length; cn++) {
                    workflow_rule_message.workflow_rule_message_form.setItemValue('user_from', user_arr[cn]);  
                    changeContactState(true, 'user_from', 'user_to');
                }
            }
            var roles = '<?php echo $role_id; ?>';
            
            if (roles != '' && roles != 0) {
                var roles_arr = roles.split(',');
                for (cn = 0; cn < roles_arr.length; cn++) {
                    workflow_rule_message.workflow_rule_message_form.setItemValue('role_from', roles_arr[cn]);  
                    changeContactState(true, 'role_from', 'role_to');
                }
            }
            
            var from_users = workflow_rule_message.workflow_rule_message_form.getSelect('user_from');
    		var to_users = workflow_rule_message.workflow_rule_message_form.getSelect('user_to');
    		var from_roles = workflow_rule_message.workflow_rule_message_form.getSelect('role_from');
    		var roles_to = workflow_rule_message.workflow_rule_message_form.getSelect('role_to');
    		
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

			if (tag_options == '') {
				tag_menu_items = '';
			} else {
				tag_menu_items = JSON.parse(tag_options);
                tag_menu_items['subject'] = tag_menu_items['message'];
			}
            
            /*
            var tag_menu_items = {
                message: [  {id: "deal_hyperlink", text: "Deal Hyperlink", icon: null, tag_structure: "<DEAL#><ID><DEAL>"},
                            {id: "counterparty_hyperlink", text: "Counterparty Hyperlink", icon: null, tag_structure: "<COUNTERPARTY#><COUNTERPARTY><#COUNTERPARTY>"},
                            {id: "invoice_hyperlink", text: "Invoice Hyperlink", icon: null, tag_structure: "<VIEW_INVOICE#><ID><#VIEW_INVOICE>"}
                         ]
            };*/
            
            tag_menu = new dhtmlXMenuObject();
			tag_menu.renderAsContextMenu();
			tag_menu.attachEvent("onBeforeContextMenu", function(zoneId){
				return load_menu_tags(tag_zones[zoneId]);
			});
            
            tag_menu.attachEvent("onClick", function(id, zoneId){
                var new_message = workflow_rule_message.workflow_rule_message_form.getItemValue(tag_zones[zoneId]);
                var message_textarea_obj = workflow_rule_message.workflow_rule_message_form.getInput(tag_zones[zoneId]);
                $(message_textarea_obj).insert_at_caret(tag_menu.getUserData(id, "tag_structure"));
			});
	        
            var t = ["message"];
            for (var q=0; q<t.length; q++) {
				var id = workflow_rule_message.workflow_rule_message_form.getInput(t[q]).id;
				tag_zones[id] = t[q];
				tag_menu.addContextZone(id);
			}
			
			load_alert_reminder();
    	});

        function load_menu_tags(id) {
            tag_menu.clearAll();
            for (var q=0; q<tag_menu_items[id].length; q++) {
                tag_menu.addNewChild(tag_menu.topId, q, tag_menu_items[id][q].id, tag_menu_items[id][q].text, false, tag_menu_items[id][q].icon);
                tag_menu.setUserData(tag_menu_items[id][q].id, 'tag_structure', tag_menu_items[id][q].tag_structure);
            }
            return true;
        }

        function save_click() {
            var attached_obj = workflow_rule_message.workflow_rule_message_form;
            var status = validate_form(attached_obj);
            
            if(status) {
                var role_to_obj = workflow_rule_message.workflow_rule_message_form.getOptions('role_to');
                var user_to_obj = workflow_rule_message.workflow_rule_message_form.getOptions('user_to');
                var name = workflow_rule_message.workflow_rule_message_form.getItemValue('event_message_name');
                var notification_type_obj = workflow_rule_message.workflow_rule_message_form.getCombo('notification_type');
                var notification_type = notification_type_obj.getChecked();
                notification_type = notification_type.toString();
                var message = workflow_rule_message.workflow_rule_message_form.getItemValue('message');
				message = message.replace(/(?:\r\n|\r|\n)/g, ' ');
                var self_notify = (workflow_rule_message.workflow_rule_message_form.isItemChecked('self_notify')) ? 'n' : 'y';
                var approval_required = 'n';
                var comment_required = (workflow_rule_message.workflow_rule_message_form.isItemChecked('comment_req')) ? 'y' : 'n';
                var mult_approval_required = (workflow_rule_message.workflow_rule_message_form.isItemChecked('mult_app_req')) ? 'y' : 'n';
                var notify_trader = (workflow_rule_message.workflow_rule_message_form.isItemChecked('notify_trader')) ? 'y' : 'n';
                var next_module_events_id = workflow_rule_message.workflow_rule_message_form.getItemValue('next_module_events_id');
                var minimum_approval_required = workflow_rule_message.workflow_rule_message_form.getItemValue('minimum_approval_required');
                var optional_event_msg = (workflow_rule_message.workflow_rule_message_form.isItemChecked('optional_event_msg')) ? 'y' : 'n';
                var automatic_proceed = 'n';
                
                var role_to = [];
                $.each(role_to_obj, function (index, value) {
                	role_to.push(role_to_obj[index]["value"]);
                });
                
                var user_to = [];
                $.each(user_to_obj, function (index, value) {
                	user_to.push(user_to_obj[index]["value"]);
                });
                
                var xml = '<Root><FormXML event_message_id="' + message_id + '" event_message_name="' + name +
                '" event_trigger_id="' + rule_id + '" notification_type="' + notification_type + '" message="' + message +
                '" self_notify="' + self_notify + '" approval_req="' + approval_required +
                '" comment_req="' + comment_required + '" mult_app_req="' + mult_approval_required +
                '" notify_trader="' + notify_trader + '" next_module_events_id="' + next_module_events_id + '" minimum_approval_required="' + minimum_approval_required + 
                '" optional_event_msg="' + optional_event_msg + '" automatic_proceed="' + automatic_proceed + 
                '"></FormXML>'
                xml = xml + '<TaskXML start_date="2015-01-05" duration="2" workflow_id_type="3" parent_id="' + parent_id + '"></TaskXML>'
			
				if (call_from == 'alert_reminder') {
					var reminder_form_obj = workflow_rule_message.workflow_rule_message_tabbar.tabs('d').getAttachedObject();
					var reminder_days = reminder_form_obj.getItemValue('reminder_days');
					var start_date = reminder_form_obj.getItemValue('start_date', true);
					var include_holiday = (reminder_form_obj.isItemChecked('include_holiday')) ? 'y' : 'n';
					
					xml = xml + '<TaskReminder start_date="' + start_date + '" reminder_days = "' + reminder_days + '" module_id = "' + module_id + '" source_id= "' + source_id + '" include_holiday= "' + include_holiday + '" event_message_id=""></TaskReminder>';
				} else if (call_from == 'import_notification') {
                    var xml = xml +  '<ImportNotification ixp_rules_id = "' + source_id + '" action = "' + action + '"></ImportNotification>';
				} 
				
				xml = xml + '</Root>';
                
                //Create XML for message_user_role
                //alert(user_to);return;
                var user_role_xml = '<Root>';
                for (var i = 0; i < user_to.length; i++) {
                    user_role_xml += '<FormXML event_message_id="' + message_id + '" user_login_id="' + user_to[i] + '" role_id=""></FormXML>';
                }
                
                for (var i = 0; i < role_to.length; i++) {
                    user_role_xml += '<FormXML user_login_id="" role_id="' + role_to[i] + '"></FormXML>';
                }
                user_role_xml += '</Root>';
                
                //Submit the Data to the server
                data = {
                            "action": "spa_setup_rule_workflow", 
                            "flag": 'm',
                            "xml": xml,
                            "user_role_xml": user_role_xml
                        }
                result = adiha_post_data("alert", data, "", "", "workflow_rule_message.save_post_callback");
            } else {
                //workflow_rule_message.workflow_rule_message_tabbar.cells('a').setActive();
                generate_error_message(workflow_rule_message.workflow_rule_message_tabbar.cells('a'));
                return;
            }
        }
        
        workflow_rule_message.save_post_callback = function(result) {
            if(result[0].errorcode == 'Success') {
                message_id = result[0].recommendation;
				if (call_from == 'import_notification'){
					setTimeout(function () {parent.win.close(); }, 1000);					
				}
            }
        }
        
    	workflow_rule_message.button_click = function(id) {
    		if (id == "add" || id == "remove") {
    		   changeContactState(id == "add", 'user_from', 'user_to');
    		} else if (id == "add_role" || id == "remove_role") {
    			changeContactState(id == "add_role", 'role_from', 'role_to');
    		}
        }
        
        workflow_rule_message.trader_change = function(name, value) {
    		if (name == 'notify_trader') {
                if (workflow_rule_message.workflow_rule_message_form.isItemChecked('notify_trader') == true) {
                    workflow_rule_message.workflow_rule_message_form.checkItem('mult_app_req');
                    workflow_rule_message.workflow_rule_message_form.setItemValue('minimum_approval_required', 1);
                } else {
                    workflow_rule_message.workflow_rule_message_form.uncheckItem('mult_app_req');
                    workflow_rule_message.workflow_rule_message_form.setItemValue('minimum_approval_required', '');
                }
            }
        }
        
    	function changeContactState(block, from, to) {   
            var ida = (block ? from : to);
            var idb = (block ? to : from);
    		var sa = workflow_rule_message.workflow_rule_message_form.getSelect(ida);
            var sb = workflow_rule_message.workflow_rule_message_form.getSelect(idb);
            var t = workflow_rule_message.workflow_rule_message_form.getItemValue(ida);
            
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
    	}
        
        document_contact_click = function(id, zoneId, cas) {
            if(id == 'add') {
                add_document_type();
            } else if (id == 'add_c') {
                add_document_contact('i');
            } else if (id == 'delete') {
                delete_document_type_contact();
            }
        }
        
        add_document_type = function() {
            var client_date_format = '<?php echo $date_format; ?>';
            var doc_form_data = [
                                    {type: "settings", position: "label-left", labelWidth: ui_settings['field_size'], inputWidth: ui_settings['field_size'], position: "label-top", offsetLeft: ui_settings['offset_left']},
                                    {type: "combo", name: "document_type", label: "Document Type", "options": <?php echo $doc_type; ?>, filtering:"true", filtering_mode:'between'},
                                    {type: "calendar", name: "effective_date", label: "Effective Date", "dateFormat": client_date_format},{type: 'newcolumn'},
                                    {type: "combo", name: "document_category", label: "Document Category", "options": "", filtering:"true", filtering_mode:'between'}
                                ];
            var doc_window = new dhtmlXWindows();
            win_doc = doc_window.createWindow('w1', 0, 0, 540, 300);
            win_doc.setText("Document Type");
            win_doc.centerOnScreen();
            win_doc.setModal(true);
            doc_form = win_doc.attachForm(get_form_json_locale(doc_form_data), true);
            
            doc_form.attachEvent("onChange", function (name, value){
                 if (name == 'document_type') {
                    reload_document_category();
                 }
            });
            
            var doc_menu = win_doc.attachMenu({
                icons_path: js_image_path + "dhxmenu_web/",
                json: '[{id:"save", text:"Save", img:"save.gif", imgdis:"new_save.gif", title: "Save", enabled: 1}]'
            });
            
            doc_menu.attachEvent("onClick", function(id, zoneId, cas){
                 if (id == 'save') {
                     var document_type = doc_form.getItemValue('document_type');
                     var effective_date = doc_form.getItemValue('effective_date', true);
                     var document_category = doc_form.getItemValue('document_category');
                    
                     data = {
                            "action": "spa_setup_rule_workflow", 
                            "flag": 'h',
                            "document_template_id": document_type,
                            "effective_date": effective_date,
                            "message_id":message_id,
                            "document_category":document_category
                        }
                    result = adiha_post_data("alert", data, "", "", "close_win_grid_refresh");
                 }
            });
            reload_document_category();
        }
        
        
        reload_document_category = function() {
            var document_type = doc_form.getItemValue('document_type');
            document_type = (document_type == 10000283) ? 38 : document_type;

            var doc_cat_cmb = doc_form.getCombo('document_category');
            var cm_param = {
                                "action": "('SELECT DISTINCT value_id, code FROM static_data_value  INNER JOIN Contract_report_template ON value_id = template_category  WHERE type_id = 42000 AND category_id = " + document_type + "')", 
                                "call_from": "form",
                                "has_blank_option": false
                            };

            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;
            doc_cat_cmb.clearAll();
            doc_cat_cmb.load(url, function() {
                doc_cat_cmb.setComboText('');
                doc_cat_cmb.selectOption(0);
            });
        }
		
		reload_document_template = function() {
            var document_category = doc_form.getItemValue('document_category');
            
			var doc_template_cmb = doc_form.getCombo('document_template');
            var cm_param = {
                                "action": "('SELECT template_id, template_name FROM contract_report_template WHERE template_category =  " + document_category + "')", 
                                "call_from": "form",
                                "has_blank_option": true
                            };

            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;
            doc_template_cmb.clearAll();
            doc_template_cmb.load(url, function() {
                doc_template_cmb.setComboText('');
                doc_template_cmb.selectOption(0);
            });
        }
        
        add_document_contact = function(mode) {
            var client_date_format = '<?php echo $date_format; ?>';
            var event_message_id = message_id;

            if (mode == 'i') {
                var message_document_id = ''
                var event_document_id = ''
                var document_type = default_doc_type;
                var effective_date = '';
                var document_category = '';
				var document_template = '';

                var dc_id = ''
                var contact_type = '';
                var delivery_method = ''
                var as_defined_in_contact = false;
                var message = '';
                var email = '';
                var email_cc = '';
                var email_bcc = '';
                var internal_contact_type = '';
                var subject = '';
                var email_group = '';
                var email_group_cc = '';
                var email_group_bcc = '';
                var message_template_id = '';
                var use_generated_document = false;
            } else {
                var selected_row = workflow_rule_message.workflow_rule_message_grid.getSelectedRowId();
                var message_document_id = workflow_rule_message.workflow_rule_message_grid.cells(selected_row,workflow_rule_message.workflow_rule_message_grid.getColIndexById("message_document_id")).getValue();

                var document_type = workflow_rule_message.workflow_rule_message_grid.cells(selected_row,workflow_rule_message.workflow_rule_message_grid.getColIndexById("document_type")).getValue();
                var effective_date = workflow_rule_message.workflow_rule_message_grid.cells(selected_row,workflow_rule_message.workflow_rule_message_grid.getColIndexById("effective_date")).getValue();
                var document_category = workflow_rule_message.workflow_rule_message_grid.cells(selected_row,workflow_rule_message.workflow_rule_message_grid.getColIndexById("document_category")).getValue();
				var document_template = workflow_rule_message.workflow_rule_message_grid.cells(selected_row,workflow_rule_message.workflow_rule_message_grid.getColIndexById("document_template")).getValue();

                var dc_id = workflow_rule_message.workflow_rule_message_grid.cells(selected_row,workflow_rule_message.workflow_rule_message_grid.getColIndexById("id")).getValue();
                var contact_type = workflow_rule_message.workflow_rule_message_grid.cells(selected_row,workflow_rule_message.workflow_rule_message_grid.getColIndexById("contact_type")).getValue();
                var delivery_method = workflow_rule_message.workflow_rule_message_grid.cells(selected_row,workflow_rule_message.workflow_rule_message_grid.getColIndexById("delivery_method")).getValue();
                var as_defined_in_contact = workflow_rule_message.workflow_rule_message_grid.cells(selected_row,workflow_rule_message.workflow_rule_message_grid.getColIndexById("as_defined_in_contract")).getValue();
                var message = workflow_rule_message.workflow_rule_message_grid.cells(selected_row,workflow_rule_message.workflow_rule_message_grid.getColIndexById("message")).getValue();
                var email = workflow_rule_message.workflow_rule_message_grid.cells(selected_row,workflow_rule_message.workflow_rule_message_grid.getColIndexById("email")).getValue();;
                var email_cc = workflow_rule_message.workflow_rule_message_grid.cells(selected_row,workflow_rule_message.workflow_rule_message_grid.getColIndexById("email_cc")).getValue();;
                var email_bcc = workflow_rule_message.workflow_rule_message_grid.cells(selected_row,workflow_rule_message.workflow_rule_message_grid.getColIndexById("email_bcc")).getValue();;
                email = remove_hyperlink(email);
                email_cc = remove_hyperlink(email_cc);
                email_bcc = remove_hyperlink(email_bcc);
                var internal_contact_type = workflow_rule_message.workflow_rule_message_grid.cells(selected_row,workflow_rule_message.workflow_rule_message_grid.getColIndexById("internal_contact_type")).getValue();;
                var subject = workflow_rule_message.workflow_rule_message_grid.cells(selected_row,workflow_rule_message.workflow_rule_message_grid.getColIndexById("subject")).getValue();;
                var email_group = workflow_rule_message.workflow_rule_message_grid.cells(selected_row,workflow_rule_message.workflow_rule_message_grid.getColIndexById("email_group")).getValue();;
                var email_group_cc = workflow_rule_message.workflow_rule_message_grid.cells(selected_row,workflow_rule_message.workflow_rule_message_grid.getColIndexById("email_group_cc")).getValue();;
                var email_group_bcc = workflow_rule_message.workflow_rule_message_grid.cells(selected_row,workflow_rule_message.workflow_rule_message_grid.getColIndexById("email_group_bcc")).getValue();;
                var message_template_id = workflow_rule_message.workflow_rule_message_grid.cells(selected_row,workflow_rule_message.workflow_rule_message_grid.getColIndexById("message_template_id")).getValue();
                var use_generated_document =  workflow_rule_message.workflow_rule_message_grid.cells(selected_row,workflow_rule_message.workflow_rule_message_grid.getColIndexById("use_generated_document")).getValue() == 'y' ? true  : false;

            }
            var doc_form_data = [
                                    {type: "settings", labelWidth: ui_settings['field_size'], inputWidth: ui_settings['field_size'], position: "label-top"},
                                    {'type':'fieldset',name:'document','label':'Document','offsetLeft':'15','offsetTop':'0','inputLeft ':'500','inputTop':'500','width':'530','list': [
                                        {type: "combo", name: "document_type", label: "Document Type", offsetLeft:ui_settings['offset_left'], "options": <?php echo $doc_type; ?>, filtering:"true", filtering_mode:'between'},
                                        {type: 'newcolumn'},
                                        {type: "calendar", name: "effective_date", label: "Effective Date", offsetLeft:ui_settings['offset_left'], "dateFormat": client_date_format, value:effective_date},
                                        {type: 'newcolumn'},
                                        {type: "combo", name: "document_category", label: "Document Category", offsetLeft:ui_settings['offset_left'], "options": "", filtering:"true", filtering_mode:'between'},
										{type: 'newcolumn'},
                                        {type: "combo", name: "document_template", label: "Document Template", offsetLeft:ui_settings['offset_left'], "options": "", filtering:"true", filtering_mode:'between'},
                                        {type: 'newcolumn'},
                                        {type: "checkbox", name: "use_generated_document", label: "Use Generated Document", "checked": use_generated_document, offsetTop:ui_settings['checkbox_offset_top'], offsetLeft:ui_settings['offset_left']}        
                                    ]},
                                    {type: 'newcolumn'},
                                    {'type':'fieldset',name:'contact','label':'Contacts','offsetLeft':'15','offsetTop':'0','inputLeft ':'500','inputTop':'500','width':'530','list': [
                                        {type: "combo", name: "contact_type", label: "Contact Type", offsetLeft:ui_settings['offset_left'],filtering:"true",filtering_mode:'between', "options": <?php echo $contact_type; ?>, hidden : true},
                                        {type: "combo", name: "delivery_method", label: "Delivery Method", offsetLeft:ui_settings['offset_left'],filtering:"true",filtering_mode:'between',required:"false","userdata":{"validation_message":"Required Field"}, "options": <?php echo $delivery_method; ?>},
                                        {type: 'newcolumn'},
                                            {type: "combo", name: "message_template_id", label: "Message Template", offsetLeft:ui_settings['offset_left'],filtering:"true",filtering_mode:'between',required:"false","userdata":{"validation_message":"Required Field"}, "options": <?php echo $message_template; ?>},
                                        {type: 'newcolumn'},
                                            {type: "combo", name: "internal_contact_type", label: "Internal Contact Type", offsetLeft:ui_settings['offset_left'],filtering:"true",filtering_mode:'between', "options": <?php echo $contact_type; ?>, hidden : true},
                                        {type: 'newcolumn'},
                                            {type: "combo", comboType: "custom_checkbox", name: "email_group", label: "Email Group", offsetLeft:ui_settings['offset_left'],filtering:"true",filtering_mode:'between',required:"false", "options": <?php echo $email_group; ?>},
                                        {type: 'newcolumn'},
                                            {type: "combo", comboType: "custom_checkbox", name: "email_group_cc", label: "Email Group CC", offsetLeft:ui_settings['offset_left'],filtering:"true",filtering_mode:'between',required:"false", "options": <?php echo $email_group_cc; ?>},
                                        {type: 'newcolumn'},
                                            {type: "combo", comboType: "custom_checkbox", name: "email_group_bcc", label: "Email Group BCC", offsetLeft:ui_settings['offset_left'],filtering:"true",filtering_mode:'between',required:"false", "options": <?php echo $email_group_bcc; ?>},
                                        {type: 'newcolumn'},
                                            {type: "checkbox",name: "as_defined_in_contact",label:"Contacts defined in Contracts",position:"label-right",checked:as_defined_in_contact, offsetTop:ui_settings['checkbox_offset_top'], offsetLeft:ui_settings['offset_left'], hidden : true},
                                        {type: 'newcolumn'},
                                            {type: "input", name: "subject", label: "Subject", offsetLeft:ui_settings['offset_left'], rows:2, inputWidth: 475, value: subject},
                                        {type: 'newcolumn'},
                                            {type: "input", name: "email", label: "Email", offsetLeft:ui_settings['offset_left'], rows:2, inputWidth: 475, value: email},
                                        {type: 'newcolumn'},
                                            {type: "input", name: "email_cc", label: "Email CC", offsetLeft:ui_settings['offset_left'], rows:2, inputWidth: 475, value: email_cc},
                                        {type: 'newcolumn'},
                                            {type: "input", name: "email_bcc", label: "Email BCC", offsetLeft:ui_settings['offset_left'], rows:2, inputWidth: 475, value: email_bcc},
                                        {type: 'newcolumn'},
                                            {type: "input", name: "message", label: "Message", offsetLeft:ui_settings['offset_left'], rows:4, inputWidth: 475, value: message}
                                    ]},
                                ];
            var doc_window = new dhtmlXWindows();
            win_doc = doc_window.createWindow('w1', 0, 0, 650, 600);
            win_doc.setText("Document/Contacts");
            win_doc.centerOnScreen();
            win_doc.setModal(true);
            doc_form = win_doc.attachForm(get_form_json_locale(doc_form_data), true);

            tag_menu = new dhtmlXMenuObject();
            tag_menu.renderAsContextMenu();
            tag_menu.attachEvent("onBeforeContextMenu", function(zoneId){
                return load_menu_tags(tag_zones[zoneId]);
            });

            tag_menu.attachEvent("onClick", function(id, zoneId){
                var new_message = doc_form.getItemValue(tag_zones[zoneId]);
                var message_textarea_obj = doc_form.getInput(tag_zones[zoneId]);
                $(message_textarea_obj).insert_at_caret(tag_menu.getUserData(id, "tag_structure"));
            });

            var t = ["subject","message"];
            for (var q=0; q<t.length; q++) {
                var id = doc_form.getInput(t[q]).id;
                tag_zones[id] = t[q];
                tag_menu.addContextZone(id);
            }


            doc_form.attachEvent("onChange", function (name, value){
                 if (name == 'document_type') {
                    reload_document_category();
                 } else if (name == 'document_category') {
					 reload_document_template();
				 }
            });

            var doc_cat_cmb = doc_form.getCombo('document_category');
            var cm_param = {
                                "action": "('SELECT DISTINCT value_id, code FROM static_data_value  INNER JOIN Contract_report_template ON value_id = template_category  WHERE type_id = 42000 AND category_id = " + (document_type == 10000283) ? 38 : document_type + "')",
                                "call_from": "form",
                                "has_blank_option": false
                            };

            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;
            doc_cat_cmb.load(url, function() {
                if (mode == 'u') {
                    doc_form.setItemValue('document_type', document_type);
                    doc_form.setItemValue('document_category', document_category);
                    doc_form.setItemValue('contact_type', contact_type);
                    doc_form.setItemValue('internal_contact_type', internal_contact_type);
                    doc_form.setItemValue('delivery_method', delivery_method);
                    doc_form.setItemValue('message_template_id', message_template_id);
                }
				// doc_form.disableItem('document_type');
            });

            var cmb_email_group = doc_form.getCombo('email_group');
            var cmb_email_group_cc = doc_form.getCombo('email_group_cc');
            var cmb_email_group_bcc = doc_form.getCombo('email_group_bcc');

            if (email_group && email_group!= '' && email_group != null) {
                email_group_array = email_group.split(';');
                for (var j = 0, len = email_group_array.length; j < len; j++) {
                    cmb_email_group.setChecked(cmb_email_group.getIndexByValue(email_group_array[j]), true);
                }
            }

            if (email_group_cc && email_group_cc!= '' && email_group_cc != null) {
                email_group_cc_array = email_group_cc.split(';');
                for (var j = 0, len = email_group_cc_array.length; j < len; j++) {
                    cmb_email_group_cc.setChecked(cmb_email_group_cc.getIndexByValue(email_group_cc_array[j]), true);
                }
            }

            if (email_group_bcc && email_group_bcc!= '' && email_group_bcc != null) {
                email_group_bcc_array = email_group_bcc.split(';');
                for (var j = 0, len = email_group_bcc_array.length; j < len; j++) {
                    cmb_email_group_bcc.setChecked(cmb_email_group_bcc.getIndexByValue(email_group_bcc_array[j]), true);
                }
            }

			var doc_template_cmb = doc_form.getCombo('document_template');
            var cm_param = {
                                "action": "('SELECT template_id, template_name FROM contract_report_template WHERE template_category =  " + document_category + "')",
                                "call_from": "form",
                                "has_blank_option": true
                            };

            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;
            doc_template_cmb.clearAll();
            doc_template_cmb.load(url, function() {
                doc_form.setItemValue('document_template', document_template);
            });

            var doc_menu = win_doc.attachMenu({
                icons_path: js_image_path + "dhxmenu_web/",
                json: '[{id:"save", text:"Save", img:"save.gif", imgdis:"new_save.gif", title: "Save", enabled: 1}]'
            });

            doc_menu.attachEvent("onClick", function(id, zoneId, cas){
                 if (id == 'save') {
                    var status = validate_form(doc_form);
                    if (!status) {
                        generate_error_message();
                        return;
                    }
                    
                    if (!event_message_id || event_message_id == '' || event_message_id == null) {
                        show_messagebox("Please save data in message tab first.");
                        return;
                    }


                    var as_defined_in_contact = doc_form.isItemChecked('as_defined_in_contact');
                    if (as_defined_in_contact == true)  as_defined_in_contact = 'y'; else as_defined_in_contact = 'n';
                    var use_generated_document =  doc_form.getItemValue('use_generated_document') ? 'y' : 'n';

                    var save_xml = '<Root><FormData ';
                    save_xml += ' message_document_id="' + message_document_id + '"';
                    save_xml += ' event_message_id="' + event_message_id + '"';
                    save_xml += ' document_type="' + doc_form.getItemValue('document_type') + '"';
					var effective_date = doc_form.getItemValue('effective_date');
                    if (effective_date != null)
                        effective_date = dates.convert_to_sql(doc_form.getItemValue('effective_date'));
                    else
                        effective_date = '';
                    save_xml += ' effective_date="' + effective_date + '"';
                    save_xml += ' document_category="' + doc_form.getItemValue('document_category') + '"';
					save_xml += ' document_template="' + doc_form.getItemValue('document_template') + '"';
                    save_xml += ' id="' + dc_id + '"';
                    save_xml += ' contact_type="' + doc_form.getItemValue('contact_type') + '"';
                    save_xml += ' delivery_method="' + doc_form.getItemValue('delivery_method') + '"';
                    save_xml += ' as_defined_in_contact="' + as_defined_in_contact + '"';
                    save_xml += ' email="' + doc_form.getItemValue('email') + '"';
                    save_xml += ' email_cc="' + doc_form.getItemValue('email_cc') + '"';
                    save_xml += ' email_bcc="' + doc_form.getItemValue('email_bcc') + '"';
                    save_xml += ' message="' + doc_form.getItemValue('message') + '"';
                    save_xml += ' internal_contact_type="' + doc_form.getItemValue('internal_contact_type') + '"';
                    save_xml += ' subject="' + doc_form.getItemValue('subject') + '"';
                    save_xml += ' message_template_id="' + doc_form.getItemValue('message_template_id') + '"';
                    save_xml += ' use_generated_document="' +  use_generated_document + '"';
                    save_xml += ' />';

                    save_xml += '<EmailData> ';
                    var cmb_email_group = doc_form.getCombo('email_group');
                    var email_group = cmb_email_group.getChecked();

                    var cmb_email_group_cc = doc_form.getCombo('email_group_cc');
                    var email_group_cc = cmb_email_group_cc.getChecked();

                    var cmb_email_group_bcc = doc_form.getCombo('email_group_bcc');
                    var email_group_bcc = cmb_email_group_bcc.getChecked()


                     for (var i= 0; i < email_group.length; i++) {
                         var email_group_id = email_group[i].split('_');
                         save_xml += '<GridRow ';
                         save_xml += ' event_message_id="' + event_message_id + '"';
                         save_xml += ' group_type="e"';
                         if (email_group_id[0] == 1) {
                             save_xml += ' workflow_contacts_id="' + email_group_id[1] + '"';
                         } else if (email_group_id[0] == 2) {
                             save_xml += ' query_value="' + email_group_id[1] + '"';
                         }
                         save_xml += '></GridRow>';
                     }

                     for (var i= 0; i < email_group_cc.length; i++) {
                         var email_group_cc_id = email_group_cc[i].split('_');
                         save_xml += '<GridRow ';
                         save_xml += ' event_message_id="' + event_message_id + '"';
                         save_xml += ' group_type="c"';
                         if (email_group_cc_id[0] == 1) {
                             save_xml += ' workflow_contacts_id="' + email_group_cc_id[1] + '"';
                         } else if (email_group_cc_id[0] == 2) {
                             save_xml += ' query_value="' + email_group_cc_id[1] + '"';
                         }
                         save_xml += '></GridRow>';
                     }

                     for (var i= 0; i < email_group_bcc.length; i++) {
                         var email_group_bcc_id = email_group_bcc[i].split('_');
                         save_xml += '<GridRow ';
                         save_xml += ' event_message_id="' + event_message_id + '"';
                         save_xml += ' group_type="b"';
                         if (email_group_bcc_id[0] == 1) {
                             save_xml += ' workflow_contacts_id="' + email_group_bcc_id[1] + '"';
                         } else if (email_group_bcc_id[0] == 2) {
                             save_xml += ' query_value="' + email_group_bcc_id[1] + '"';
                         }
                         save_xml += '></GridRow>';
                     }

                     save_xml += '</EmailData> ';
                     save_xml += '</Root>';
                    data = {
                                "action": "spa_setup_rule_workflow",
                                "flag": 'j',
                                "xml": save_xml
                            }
                    result = adiha_post_data("alert", data, "", "", "close_win_grid_refresh");
                 }
            });
        }

        contact_update = function(rId, CInd) {
            add_document_contact('u');        
        }
        
        close_win_grid_refresh = function(result) {
            win_doc.close();
            refresh_contact_grid();
        }
                
        refresh_contact_grid = function() {
            var grid_param = {
                "flag": "g",
                "action": "spa_setup_rule_workflow",
                "grid_type": "g",
                "message_id": message_id
            };

            grid_param = $.param(grid_param);
            var grid_url = js_data_collector_url + "&" + grid_param;
            workflow_rule_message.workflow_rule_message_grid.clearAll();    
            workflow_rule_message.workflow_rule_message_grid.loadXML(grid_url);        
        }
                
        contact_row_select = function(id,ind) {
            if (has_rights_delete) {
                workflow_rule_message.document_contacts.setItemEnabled('delete'); 
            }    
        }
                
        delete_document_type_contact = function() {
            var select_row = workflow_rule_message.workflow_rule_message_grid.getSelectedRowId();
            
            var document_template_id = workflow_rule_message.workflow_rule_message_grid.cells(select_row,workflow_rule_message.workflow_rule_message_grid.getColIndexById("document_type")).getValue();  
            data = {
                        "action": "spa_setup_rule_workflow", 
                        "flag": 'k',
                        "document_template_id": document_template_id,
                        "message_id": message_id
                    }
            result = adiha_post_data("alert", data, "", "", "refresh_contact_grid");
               
        }
        
        
        report_menu_click = function(id, zoneId, cas) {
            if (id == 'add') {
                open_alert_report('i');
            } else if (id == 'delete') {
                var selected_row = workflow_rule_message.alert_report_grid.getSelectedRowId();
                var alert_report_id = workflow_rule_message.alert_report_grid.cells(selected_row,workflow_rule_message.alert_report_grid.getColIndexById("alert_reports_id")).getValue();
                data = {
                            "action": "spa_alert_reports", 
                            "flag": 'd',
                            "alert_report_id": alert_report_id
                        }
                result = adiha_post_data("alert", data, "", "", "refresh_report_grid");
            }
        }
        
        open_alert_report = function(mode) {
            if(mode == 'i') {
                var alert_reports_id = '';
                var report_writer = 'n';
                var paramset_hash = '';
                var report_desc = '';
                var report_table_suffix = '';
                var report_table_prefix = '';
				var report_where_clause = '';
                var file_type = '';
            } else if (mode == 'u') {
                var selected_row = workflow_rule_message.alert_report_grid.getSelectedRowId();
                var alert_reports_id = workflow_rule_message.alert_report_grid.cells(selected_row,workflow_rule_message.alert_report_grid.getColIndexById("alert_reports_id")).getValue();
                var report_writer = workflow_rule_message.alert_report_grid.cells(selected_row,workflow_rule_message.alert_report_grid.getColIndexById("report_type")).getValue();
                var paramset_hash = workflow_rule_message.alert_report_grid.cells(selected_row,workflow_rule_message.alert_report_grid.getColIndexById("paramset_hash")).getValue();
                var report_desc = workflow_rule_message.alert_report_grid.cells(selected_row,workflow_rule_message.alert_report_grid.getColIndexById("report_desc")).getValue();
                var report_table_prefix = workflow_rule_message.alert_report_grid.cells(selected_row,workflow_rule_message.alert_report_grid.getColIndexById("table_prefix")).getValue();
                var report_table_suffix = workflow_rule_message.alert_report_grid.cells(selected_row,workflow_rule_message.alert_report_grid.getColIndexById("table_postfix")).getValue();
				var report_where_clause = workflow_rule_message.alert_report_grid.cells(selected_row,workflow_rule_message.alert_report_grid.getColIndexById("report_where_clause")).getValue();
                var file_type = workflow_rule_message.alert_report_grid.cells(selected_row,workflow_rule_message.alert_report_grid.getColIndexById("file_option_type")).getValue();

            }
            var client_date_format = '<?php echo $date_format; ?>';
            var report_form_data = [
                                        {type: "settings", labelWidth: ui_settings['field_size'], inputWidth: ui_settings['field_size'], position: "label-top", offsetLeft: ui_settings['offset_left']},
                                        {type: "input", name: "alert_reports_id", label: "Alert Report ID", value: alert_reports_id, hidden: "true"},
                                        {type: "combo", name: "report_writer", label: "Report Type", options: <?php echo $opt_report_writer; ?>, filtering:"true",filtering_mode:'between', value: report_writer},
                                        {type: "newcolumn"},
                                        {type: "combo", name: "report", label: "Report", options: <?php echo $opt_report_name; ?>, filtering:"true",filtering_mode:'between', value: ""},
                                        {type: "newcolumn"},
                                        {type: "input", name: "report_desc", label: "Report Description", value: report_desc},
                                        {type: "newcolumn"},
                                        {type: "input", name: "report_table_suffix", label: "Report Table Suffix", value: report_table_suffix},
                                        {type: "newcolumn"},
                                        {type: "input", name: "report_table_prefix", label: "Report Table Prefix", value: report_table_prefix},
										{type: "newcolumn"},
                                        {type: "combo", name: "file_option_type", label: "File Option Type", options: <?php echo $opt_file_type; ?>, filtering:"true",filtering_mode:'between', value: file_type},
										{type: "newcolumn"},
                                        {type: "input", name: "report_where_clause", label: "Report Where Clause", value: report_where_clause, rows:"3", inputWidth: "475"}
                                    ];
            var report_window = new dhtmlXWindows();
            report_win = report_window.createWindow('w1', 0, 0, 540, 300);
            report_win.setText("Document Type");
            report_win.centerOnScreen();
            report_win.setModal(true);
            report_form = report_win.attachForm(get_form_json_locale(report_form_data), true);
            
            report_form.setItemValue('report',paramset_hash);
            report_form.setItemValue('report_writer',report_writer);
            report_form.setItemValue('file_option_type',file_type);
            change_report_input(report_writer);
            report_form.attachEvent("onChange", function (name, value){
                 if (name == 'report_writer') {
                    change_report_input(value);
                 }
            });

            var report_menu = report_win.attachMenu({
                icons_path: js_image_path + "dhxmenu_web/",
                json: '[{id:"save", text:"Save", img:"save.gif", imgdis:"new_save.gif", title: "Save", enabled: 1}]'
            });

            report_menu.attachEvent("onClick", function(id, zoneId, cas){
                 if (id == 'save') {
                     if (!message_id || message_id == '' || message_id == null) {
                        show_messagebox("Please save data in message tab first.");
                        return;
                     }
                     var alert_reports_id = report_form.getItemValue('alert_reports_id');
                     var report_writer = report_form.getItemValue('report_writer');
                     var paramset_hash = report_form.getItemValue('report');
                     var report_parameter = '';
                     var report_description = report_form.getItemValue('report_desc');
                     var table_prefix = report_form.getItemValue('report_table_prefix');
                     var table_suffix = report_form.getItemValue('report_table_suffix');
                     var sel_file_type = report_form.getItemValue('file_option_type');
                     var flag = ((alert_reports_id == '') ? 'i': 'u');
					 var report_where_clause = report_form.getItemValue('report_where_clause');
                     
                     data = {
                            "action": "spa_alert_reports", 
                            "flag": flag,
                            "alert_report_id": alert_reports_id,
                            "event_message_id": message_id,
                            "report_writer": report_writer,
                            "paramset_hash":paramset_hash,
                            "report_parameter":report_parameter,
                            "report_description":report_description,
                            "table_prefix":table_prefix,
                            "table_suffix":table_suffix,
                            "report_where_clause":report_where_clause,
                            "file_option_type": sel_file_type
                        }
                    result = adiha_post_data("alert", data, "", "", "close_and_refresh_report_grid");
                 }
            });
        }
         
        change_report_input = function(status) {
            if(status == 'y') {
                report_form.showItem('report');
                report_form.hideItem('report_desc');
                report_form.hideItem('report_table_suffix');
                report_form.hideItem('report_table_prefix');
				report_form.hideItem('report_where_clause');
				report_form.setItemValue('report_desc','');
                report_form.setItemValue('report_table_suffix','');
                report_form.setItemValue('report_table_prefix','');
				report_form.setItemValue('report_where_clause','');
            } else if (status == 'n') {
                report_form.hideItem('report');
                report_form.showItem('report_desc');
                report_form.showItem('report_table_suffix');
                report_form.showItem('report_table_prefix');
				report_form.showItem('report_where_clause');
                report_form.setItemValue('report','');
            } else if (status == 'a') {
                report_form.showItem('report');
                report_form.showItem('report_desc');
                report_form.hideItem('report_table_suffix');
                report_form.hideItem('report_table_prefix');
                report_form.hideItem('report_where_clause');
                report_form.setItemValue('report_table_suffix','');
                report_form.setItemValue('report_table_prefix','');
                report_form.setItemValue('report_where_clause','');
                report_form.hideItem('report');
            }
        } 
        
        report_update = function(rId, CInd) {
            open_alert_report('u');
        }
        
        report_row_select = function(id,ind) {
            if (has_rights_delete) {
                workflow_rule_message.report_menu.setItemEnabled('delete');
            }   
        }
        
        close_and_refresh_report_grid = function() {
            report_win.close();
            refresh_report_grid();
        }
        
        refresh_report_grid = function() {
            var grid_param = {
                "flag": "s",
                "action": "spa_alert_reports",
                "grid_type": "g",
                "event_message_id": message_id

            };

            grid_param = $.param(grid_param);
            var grid_url = js_data_collector_url + "&" + grid_param;
            workflow_rule_message.alert_report_grid.clearAll();    
            workflow_rule_message.alert_report_grid.loadXML(grid_url);        
        }
        
        remove_hyperlink = function(text) {
            var no_hyperlink_text = text.replace('</a>','');
            var txt_arr = no_hyperlink_text.split('>');
            
            return txt_arr[1];
        }

        $.fn.extend({
            insert_at_caret: function(myValue) {
                this.each(function() {
                    if (document.selection) {
                        this.focus();
                        var sel = document.selection.createRange();
                        sel.text = myValue;
                        this.focus();
                    } else if (this.selectionStart || this.selectionStart == '0') {
                        var startPos = this.selectionStart;
                        var endPos = this.selectionEnd;
                        var scrollTop = this.scrollTop;
                        this.value = this.value.substring(0, startPos) +
                            myValue + this.value.substring(endPos,this.value.length);
                        this.focus();
                        this.selectionStart = startPos + myValue.length;
                        this.selectionEnd = startPos + myValue.length;
                        this.scrollTop = scrollTop;
                    } else {
                        this.value += myValue;
                        this.focus();
                    }
                });
                return this;
            }
        });

		load_alert_reminder = function() {
			var client_date_format = '<?php echo $date_format; ?>'
			var client_date_format_t = client_date_format + ' %H:%i';
			var start_date = '<?php echo $start_date; ?>';
			var reminder_days = '<?php echo $reminder_days; ?>';
			var include_holiday = '<?php echo $include_holiday; ?>';
			
			if (call_from == 'alert_reminder') {
				workflow_rule_message.workflow_rule_message_form.hideItem('notify_trader');
				
				workflow_rule_message.workflow_rule_message_form.hideItem('comment_req');
				workflow_rule_message.workflow_rule_message_form.hideItem('optional_event_msg');
				workflow_rule_message.workflow_rule_message_form.hideItem('multiple_approval_group');
				
				workflow_rule_message.workflow_rule_message_tabbar.addTab('d','Schedule Event',  null, 1, false, false);
				
				var schedule_event_form_data = [
									{type: "settings", labelWidth: ui_settings['field_size'], inputWidth: ui_settings['field_size'], position: "label-top", offsetLeft: ui_settings['offset_left']},
									{type: "calendar", name: "start_date", label: "Start Date","dateFormat": client_date_format_t, enableTime: true, value: start_date, serverdateFormat: "%Y-%m-%d"},
									{type: "newcolumn"},
									{type: "input", name: "reminder_days", label: "Reminder Days", value: reminder_days},
									{type: "newcolumn"},
									{type: "checkbox",name: "include_holiday",label:"Include Holiday",position:"label-right",checked:include_holiday, offsetTop:ui_settings['checkbox_offset_top']},
								];
				
				var schedule_event_form = workflow_rule_message.workflow_rule_message_tabbar.tabs('d').attachForm(get_form_json_locale(schedule_event_form_data));
				
			} 
			else if (call_from == 'import_notification'){
				var message_name_notification = '<?php echo (isset($message_name_notification)?$message_name_notification:""); ?>';
				var message_tag = '<?php echo (isset($message_tag)?$message_tag:"");?>';
				var message_id = '<?php echo (isset($message_id)?$message_id:"");?>';
				if (message_id == ''){
					workflow_rule_message.workflow_rule_message_form.setItemValue('event_message_name',message_name_notification);
				}				
				var  message = workflow_rule_message.workflow_rule_message_form.getItemValue('message');
				if (message == ''){
					workflow_rule_message.workflow_rule_message_form.setItemValue('message',message_tag);
				}				
				workflow_rule_message.workflow_rule_message_form.hideItem('notify_trader');				
				workflow_rule_message.workflow_rule_message_form.hideItem('comment_req');
				workflow_rule_message.workflow_rule_message_form.hideItem('optional_event_msg');
				workflow_rule_message.workflow_rule_message_form.hideItem('multiple_approval_group');
				workflow_rule_message.workflow_rule_message_form.hideItem('self_notify');				
				workflow_rule_message.workflow_rule_message_tabbar.tabs('b').hide();
				workflow_rule_message.workflow_rule_message_tabbar.tabs('c').hide();
			}
			else {
				workflow_rule_message.workflow_rule_message_form.showItem('notify_trader');
				workflow_rule_message.workflow_rule_message_form.showItem('comment_req');
				workflow_rule_message.workflow_rule_message_form.showItem('optional_event_msg');
				workflow_rule_message.workflow_rule_message_form.showItem('multiple_approval_group');
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