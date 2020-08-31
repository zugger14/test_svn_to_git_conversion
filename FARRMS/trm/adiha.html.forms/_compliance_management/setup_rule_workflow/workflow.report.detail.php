<?php
/**
* Workflow report detail screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html><head>
	<meta http-equiv="Content-type" content="text/html; charset=utf-8">
	<title>Basic initialization</title>
</head>

<?php include "../../../adiha.php.scripts/components/include.file.v3.php"; ?>
<script src="../../../adiha.php.scripts/components/dhtmlxGantt/codebase/dhtmlxgantt.js" type="text/javascript" charset="utf-8"></script>

<link rel="stylesheet" href="../../../adiha.php.scripts/components/dhtmlxGantt/codebase/dhtmlxgantt.css" type="text/css" media="screen" title="no title" charset="utf-8">
<script src="https://export.dhtmlx.com/gantt/api.js"></script> 

<style type="text/css">
    html, body{ height:100%; padding:0px; margin:0px; overflow: hidden;}
    .no_display{ visibility: hidden;}
    .nested_task .fa-plus{display: none !important;}  
    .complete_icon, .schedule_icon, .remove_icon, .approve_icon,.unapprove_icon{ cursor:pointer; margin-left: 5px; width:  }   
   	.complete_icon {background:url(../../../adiha.php.scripts/adiha_pm_html/process_controls/workflow_icons/complete.png) no-repeat; }
    .schedule_icon {background:url(../../../adiha.php.scripts/adiha_pm_html/process_controls/workflow_icons/schedule.png) no-repeat; }
    .ignore_icon   {background:url(../../../adiha.php.scripts/adiha_pm_html/process_controls/workflow_icons/ignore.png) no-repeat; }
    .doc_icon      {background:url(../../../adiha.php.scripts/adiha_pm_html/process_controls/workflow_icons/doc.png) no-repeat; }
    .remove_icon   {background:url(../../../adiha.php.scripts/adiha_pm_html/process_controls/workflow_icons/remove.png) no-repeat;  }
    .approve_icon  {background:url(../../../adiha.php.scripts/adiha_pm_html/process_controls/workflow_icons/approved.png) no-repeat;  }
    .unapprove_icon{background:url(../../../adiha.php.scripts/adiha_pm_html/process_controls/workflow_icons/unapproved.png) no-repeat; }  
    .add_icon      {background:url(../../../adiha.php.scripts/adiha_pm_html/process_controls/workflow_icons/add_top.png) no-repeat; }
</style>

<?php
	$rights_workflow_report_action = 10106613;
	list (
        $has_rights_workflow_report_action              
    ) = build_security_rights(
        $rights_workflow_report_action              
    );

	$datetime_format = $date_format . ' %H:%i';
	
    $module_event_id = get_sanitized_value($_GET['module_event_id']);
    $source_column = $_GET['source_column'];
    $filter_id = get_sanitized_value($_GET['filter_id']);
    $filter_string = get_sanitized_value($_GET['filter_string']);
	$workflow_group_id = get_sanitized_value($_GET['workflow_group_id']);
	$workflow_process_id  = get_sanitized_value($_GET['workflow_process_id']);
	$as_of_date = get_sanitized_value($_GET['as_of_date']);
	$show_all = get_sanitized_value($_GET['show_all']);
	
	if ($filter_id == -1) {
		$sql = "SELECT dbo.FNAGETNewID() [process_id]";
		$result = readXMLURL2($sql);
		$workflow_process_id = $result[0]['process_id'];
	}
	
	$status = get_sanitized_value($_GET['status']);
	$process_table_xml = get_sanitized_value($_GET['process_table_xml']);
	
	$sql = "EXEC spa_workflow_progress @flag='s',@filter_id='$filter_id', @source_column=$source_column,@module_event_id='$module_event_id',@workflow_group_id='$workflow_group_id',@status='$status',@workflow_process_id='$workflow_process_id',@show_all='$show_all'";
    $result = readXMLURL2($sql);
	//echo "<textarea>" .  var_dump($result) . "</testarea>";
	
	//$workflow_header = '';
	$workflow_events = '';
    $workflow_message = '';
	$workflow_status = '';
	$message_margin = 40;
	$workflow_historic_id = '';
    /*
    //print '<pre>';print_r($result);print '</pre>';
    foreach ($result as $value) {
        echo $workflow_header;
        if ($workflow_header != $value['modules_event_id']) {
            $workflow_header = $value['modules_event_id'];
        } else {
            $workflow_header = $value['modules_event_id'];
        }
        echo $workflow_header;
        print '<pre>';
        print_r($value);
        print '</pre>';
    }*/
?>

<style type="text/css">
    html, body{ height:100%; 
                padding:0px; 
                margin:0px; 
                background-color:  white;
            }
			
			body {
				overflow: scroll;
			}
    
    .workflow_report_div {
		margin-left: 25px;
    }
    
    .workflow_header {
        margin-top: 20px;
        font-size: 14px;
    }
    
    .workflow_message {
        line-height: 25px;
		font-size: 14px;
    }
    
    .workflow_message_status, .workflow_document_status, .workflow_message_status_false, .workflow_message_status_manual, .workflow_message_status_ignore, .workflow_message_status_calendar, .workflow_message_status_custom {
        height: 18px;
        width: 18px;
        background-color: darkseagreen;
        float: left;        
        margin: 3px 10px 0 0;
        border-radius:2px;  
        vertical-align: middle;
        color: white;
        text-transform: lowercase;
        font-size: 15px; 
        padding: 0px; text-align: center;
        
    }
    .workflow_message_status { 
    	line-height: 18px; 
    }

    .workflow_document_status {
        background-color: white;
    }
    
    .workflow_message_status_false {
        background-color: #cc0000 !important;
        line-height: 16px; cursor: pointer; font-size: 18px; 
    }
	
	.workflow_message_status_custom {
        background-color: #d1b9ea !important;line-height: 15px; color: #fff; font-size: 16px;  
    }
	
	.workflow_message_status_manual {
		background-color: #f7bf33 !important; line-height: 19px; text-transform: uppercase; font-size: 14px; 
	}
	
	.workflow_message_status_ignore {
		background-color: #6c727c !important;line-height: 20px; text-transform: uppercase; font-size: 15px; 
	}
	
	.workflow_message_status_calendar {
		background-color: #b436d1 !important; line-height: 18px;
	}
	
	.filter {
		margin-top: 25px;
		margin-left: 25px;
		font-size: 12px;
	}
	
	.process_hyperlink {
		/*background-color:#307af2;*/
		border-radius: 3px;
		color:white !important;
		padding: 2px 10px;
		text-decoration: none;
		font-size: 14px; 
		margin: 0 0 0 5px; 
		cursor: pointer;
	}
	
.workflow_message_text {}
.workflow_message_text:hover { background:#f2f2f2; }
.icon_right_align { float:right; margin-right:100px;}
.legend { border:1px solid #e5e5e5; width: 870px; height: 20px; background: #f2f2f2; border-radius: 2px;  padding: 5px; float: right;   }
.legend ul { margin:0; padding:0;}
.legend li { list-style:none; float:left; display:inline; font-size: 12px; margin-left: 5px;}
.legend_task { color:#44494a; position:relative; top:-5px;}

</style>
<body>
	<div class="legend">
	<ul>
    	<li>
			<img src="../../../adiha.php.scripts/adiha_pm_html/process_controls/workflow_icons/legend/completed_approved.png" width="18" height="18">
        	<span class="legend_task"><?php echo get_locale_value('Completed/Approved'); ?></span>
        </li>
        <li>
			<img src="../../../adiha.php.scripts/adiha_pm_html/process_controls/workflow_icons/legend/mannual_workflow.png" width="18" height="18">
        	<span class="legend_task"><?php echo get_locale_value('Manual Workflow'); ?></span>
        </li>
        <li>
			<img src="../../../adiha.php.scripts/adiha_pm_html/process_controls/workflow_icons/legend/calendar_scheduled_workflow.png" width="18" height="18">
        	<span class="legend_task"><?php echo get_locale_value('Calendar Scheduled Workflow'); ?></span>
        </li>
        <li>
			<img src="../../../adiha.php.scripts/adiha_pm_html/process_controls/workflow_icons/legend/custom_workflow.png" width="18" height="18">
        	<span class="legend_task"><?php echo get_locale_value('Custom Workflow'); ?></span>
        </li>
        <li>
			<img src="../../../adiha.php.scripts/adiha_pm_html/process_controls/workflow_icons/legend/ignored_workflow.png" width="18" height="18">
        	<span class="legend_task"><?php echo get_locale_value('Ignored Workflow'); ?> </span>
        </li>
        <li>
			<img src="../../../adiha.php.scripts/adiha_pm_html/process_controls/workflow_icons/legend/non_triggered_workflow.png" width="18" height="18">
        	<span class="legend_task"><?php echo get_locale_value('Non Triggered Workflow'); ?> </span>
        </li>
	</ul>
    
	</div> 
	<div class="workflow_report_div">
        <?php foreach ($result as $value) { //echo "<textarea>" . $workflow_historic_id . "--->" .$value['workflow_historic_id'] . "</textarea>";?>
            <?php if ($workflow_historic_id != $value['workflow_historic_id']) { ?>
                <?php $message_margin = -20; ?>
                <div class="workflow_header">
					<strong><?php echo $value['workflow_name']; ?></strong>
					<?php
						if ($value['is_latest'] == 1) {
							echo '<a title="'. get_locale_value('Add') . '" class="process_hyperlink add_icon" onClick="hyperlink_custom_activity_click(' . $value["modules_event_id"] . ',' . $value["workflow_group_id"]. ')"> </a>';
							if ( $value['event'] == 20548 && $value['group_ignore'] == 'y' && $has_rights_workflow_report_action == 1) { 
								echo '<a title="'. get_locale_value('Ignore') . '" class="process_hyperlink ignore_icon" onClick="hyperlink_ignore_workflow_click(' . $value["modules_event_id"] . ',' . $value["workflow_group_id"]. ')"></a>';
							} else if ($value['event'] == 20548 && $value['group_ignore'] == 'r' && $has_rights_workflow_report_action == 1) {
								echo '<a title="'. get_locale_value('Remove/Ignore') . '" class="process_hyperlink remove_icon" onClick="hyperlink_unignore_workflow_click(' . $value["modules_event_id"] . ',' . $value["workflow_group_id"]. ')"></a>';
							}
						}
					?>
				</div>
                <hr>
				<?php 
					//$workflow_header = $value['modules_event_id'] . $value['workflow_historic_id']; 
					$workflow_historic_id = $value['workflow_historic_id'];
				?>
            <?php } else { ?>
                
				<?php //$workflow_header = $value['modules_event_id'] . $value['workflow_historic_id']; 
					  $workflow_historic_id = $value['workflow_historic_id'];
				?>
            <?php } ?> 
			<?php
			if ($workflow_events != $value['event_trigger_id']) {
				 $message_margin = $message_margin + 30;
				 $workflow_events = $value['event_trigger_id'];
			} else {
				$workflow_events = $value['event_trigger_id'];
			} 
			
			if($value['manual_step'] != "n") {
				$message_margin = 10;
			}
			
			?>
            <div class="workflow_message" style="margin-left:<?php echo $message_margin; ?>px;">
				<?php if ($workflow_message != $value['event_message_id'] || $workflow_status != $value['status'] || $workflow_document == '') { ?>
					<?php if ($value['manual_step'] == 'y') { ?>
						<div class="workflow_message_status_manual"> M </div>
					<?php } else if ($value['manual_step'] == 'i') { ?>
						<div class="workflow_message_status_ignore"> &Oslash; </div>
					<?php } else if ($value['manual_step'] == 'a') { ?>
						<div class="workflow_message_status_custom"> C </div>
					<?php } else if ($value['manual_step'] == 'c') { ?>
						<div class="workflow_message_status_calendar"> &#128197; </div>
					<?php } else if ($value['status'] == ' - Not Started' || $value['status'] == null) { ?>
						<div class="workflow_message_status_false"> ! </div>
					<?php } else { ?>
						<div class="workflow_message_status" onClick="workflow_btn_click(this)"> &#10004; </div>
					<?php } ?>
					<div class="workflow_message_text">
						<?php echo $value['event_message_name'] . '<i>' . $value['status'] . '</i>' . $value['approved_date'] . '<i>' . $value['approved_by'] . '</i>'; ?>
						
						<?php if ($value['hyperlink'] != '' && $has_rights_workflow_report_action == 1) { ?>
							<?php echo $value['hyperlink']; ?>
						<?php } ?> 
					</div>
					<?php $workflow_message = $value['event_message_id']; ?>
					<?php $workflow_status = $value['status']; ?>
					<?php $workflow_document = $value['attachment_file_name']; ?>
				<?php } else { ?>
                	<?php $workflow_message = $value['event_message_id']; ?>
					<?php $workflow_status = $value['status']; ?>
					<?php $workflow_document = $value['attachment_file_name']; ?>
				<?php } ?> 
				<?php if ($value['message'] != '') { ?>
                    <div class="workflow_message_details" style="margin-left:30px;display:none;">
						<?php echo trim($value['message']); ?> 
                    </div>
                <?php } ?> 
				<?php if ($value['attachment_file_name'] != '') { ?>
                    <div class="workflow_document" style="margin-left:30px;">
                        <div class="workflow_document_status">
                            <img src="../../../adiha.php.scripts/components/lib/adiha_dhtmlx/themes/dhtmlx_jomsomGreen/imgs/dhxmenu_web/doc.gif"/>
                        </div>
                        <div class="workflow_document_text"> 
                            
							<?php 
								if ($value['is_manual_upload'] == 1) {
									echo $value['category'] . ' ' . get_locale_value('Document Attached') . ' - ';
								} else {
									echo get_locale_value('Document Generated') . ' - ';
								}
							?>
                            <a target="_blank" href='../../../adiha.php.scripts/dev/shared_docs/attach_docs/<?php echo $value['attachment_folder']; ?>/<?php echo $value['attachment_file_name']; ?>'><?php echo $value['attachment_file_name']; ?></a>
                        </div>
                    </div>
                 <?php } ?> 
            </div>
            
       <?php } ?>
    </div>
</body>

<script type="text/javascript">
	var source_id = '<?php echo $filter_id; ?>';
	var source_column = <?php echo $source_column; ?>;
	var process_table_xml = '<?php echo $process_table_xml; ?>';	
	process_table_data = process_table_xml.split('::');
	var workflow_process_id = '<?php echo $workflow_process_id; ?>';
	var as_of_date = '<?php echo $as_of_date; ?>';
	
	if (process_table_xml != '') {
		process_table_xml = '<row ';
		process_table_data.forEach(function(data, index) {
			data_arr = data.split(':');
			process_table_xml += data_arr[0] + '="' + data_arr[1] + '"';
		});
		process_table_xml += ' />';
	}
	
	hyperlink_complete_click = function(event_trigger_id, module_event_id, workflow_group_id) {
		workflow_report.layout.cells('c').progressOn();
		
		var data = {
						'action': 'spa_register_event_manual',
						'flag': 't',
						'event_trigger_id' : event_trigger_id,
						'module_event_id' : module_event_id,
						'group_id': workflow_group_id,
						'source_id': source_id,
						'is_batch': '1',
						'process_table_xml':process_table_xml,
						'group_process_id':workflow_process_id,
						'custom_schedule_date': as_of_date
						
                   };
        result = adiha_post_data('alert', data, '', '', 'refresh_report', true);
		
		if (source_id == -1) source_id = 0;
		update_workflow_process_id(workflow_process_id, source_id);
	}
	
	hyperlink_schedule_click = function(event_trigger_id, module_event_id, workflow_group_id, custom_activity_id) {
		var today = new Date();
		today = dates.convert_to_sql_with_time(today);
		
		schedule_window = new dhtmlXWindows();
		win = schedule_window.createWindow('w1', 0, 0, 450, 200);
		win.setText("Schedule");
		win.centerOnScreen();
		win.setModal(true);
		var form_json = [{
							type: 'block',
							blockOffset: 20,
							list: [{
								'type': 'calendar',
								'name': 'schedule_date',
								'label': 'Schedule Time',
								'position': 'label-top',
								'validate': 'NotEmpty',
								'inputWidth': 220,
								'labelWidth': 'auto',
								'required': true,
								'userdata': {
								'validation_message': 'Required Field'
								},
								'tooltip': 'Schedule Time',
								'enableTime': true,
								'dateFormat': '<?php echo $datetime_format; ?>',
								'serverDateFormat': '%Y-%m-%d %H:%i',
								'value': today
							},{
								'type': 'checkbox',
								'name': 'automatic_trigger',
								'label': 'Allow Automatic Trigger',
								'position': 'label-right',
								'labelWidth': 'auto',
								'offsetTop':25,
								'tooltip': 'Allow Automatic Trigger',
								'checked': true
							},{'type': 'newcolumn'},{
								'type': 'checkbox',
								'name': 'run_only_this_step',
								'label': 'Run only this step',
								'position': 'label-right',
								'labelWidth': 'auto',
								'offsetTop':25,
								'offsetLeft':25,
								'tooltip': 'Run only this step'
							}]
						}];
		var form_obj = win.attachForm();
		form_obj.load(get_form_json_locale(form_json), function() {
			if (custom_activity_id != '') {
				form_obj.hideItem('automatic_trigger');
				form_obj.hideItem('only_this_step');
			}
		});
		
		var toolbar_json = [{id:"ok", type:"button", img:"save.gif", imgdis:"save_dis.gif", text:"Ok", title:"Ok"}];
		var toolbar_obj = win.attachToolbar();
		toolbar_obj.setIconsPath(js_image_path + '/dhxtoolbar_web/');
		toolbar_obj.loadStruct(toolbar_json);
		
		toolbar_obj.attachEvent("onClick", function(id){
			var status = validate_form(form_obj);
			if (status == false) return;
			
			if (custom_activity_id == '') {
				schedule_workflow_step(form_obj,event_trigger_id, module_event_id, workflow_group_id);
			} else {
				schedule_custom_activity(form_obj,custom_activity_id)
			}
		});
	}
	
	schedule_workflow_step = function(form_obj,event_trigger_id, module_event_id, workflow_group_id) {
		var schedule_date = form_obj.getItemValue('schedule_date', true);
		var automatic_trigger = (form_obj.isItemChecked('automatic_trigger')) ? 'y' : 'n';
		var run_only_this_step = (form_obj.isItemChecked('run_only_this_step')) ? 'y' : 'n';
		var xml = '<Root calendar_event_id="" name="' + source_id + '" description="" workflow_id="' + module_event_id + '" alert_id="' + event_trigger_id + '" reminder="-1" rec_type="" start_date="' + schedule_date + '" end_date="' + schedule_date + '" event_parent_id="0" event_length="300" workflow_group_id="' + workflow_group_id + '" automatic_trigger="' + automatic_trigger + '"  run_only_this_step="' + run_only_this_step + '" workflow_process_id="' + workflow_process_id + '" scheduled_as_of_date="' + as_of_date + '"></Root>';
		
		var data = {
						'action': 'spa_register_event_manual',
						'flag': 's',
						'xml' : xml,
						'process_table_xml' : process_table_xml,
						'source_id' : source_id
						
                   };
        result = adiha_post_data('alert', data, '', '', 'refresh_report', true);
		schedule_window.window('w1').close();
	}
	
	hyperlink_ignore_click = function(event_trigger_id, module_event_id, workflow_group_id) {
		workflow_report.layout.cells('c').progressOn();
		
		var data = {
						'action': 'spa_register_event_manual',
						'flag': 'i',
						'event_trigger_id' : event_trigger_id,
						'module_event_id' : module_event_id,
						'group_id': workflow_group_id,
						'source_id': source_id,
						'source_column': source_column
						
                   };
        result = adiha_post_data('alert', data, '', '', 'refresh_report', true);
	}
	
	hyperlink_remove_igonore_click = function(workflow_activities_id) {
		workflow_report.layout.cells('c').progressOn();
		
		var data = {
						'action': 'spa_register_event_manual',
						'flag': 'r',
						'activity_id' : workflow_activities_id						
                   };
        result = adiha_post_data('alert', data, '', '', 'refresh_report', true);
	}
	
	
	hyperlink_cancel_schedule_click = function(calendar_event_id) {
		workflow_report.layout.cells('c').progressOn();
		
		var data = {
						'action': 'spa_register_event_manual',
						'flag': 'c',
						'activity_id' : calendar_event_id						
                   };
        result = adiha_post_data('alert', data, '', '', 'refresh_report', true);
	}
	
	hyperlink_ignore_workflow_click = function(module_event_id, workflow_group_id) {
		workflow_report.layout.cells('c').progressOn();
		
		var data = {
						'action': 'spa_register_event_manual',
						'flag': 'g',
						'module_event_id' : module_event_id,
						'group_id': workflow_group_id,
						'source_id': source_id,
						'source_column': source_column
						
                   };
        result = adiha_post_data('alert', data, '', '', 'refresh_report', true);
	}
	
	hyperlink_unignore_workflow_click = function(module_event_id, workflow_group_id) {
		workflow_report.layout.cells('c').progressOn();
		
		var data = {
						'action': 'spa_register_event_manual',
						'flag': 'u',
						'module_event_id' : module_event_id,
						'group_id': workflow_group_id,
						'source_id': source_id,
						'source_column': source_column
						
                   };
        result = adiha_post_data('alert', data, '', '', 'refresh_report', true);
	}
	
	refresh_report = function() {
		workflow_report.layout.cells('c').progressOff();
		workflow_status_report_refresh();
	}
	
	hyperlink_custom_activity_click = function(module_event_id, workflow_group_id) {
		custom_activity_window = new dhtmlXWindows();
		win = custom_activity_window.createWindow('w1', 0, 0, 400, 200);
		win.setText("Custom Activity");
		win.centerOnScreen();
		win.setModal(true);
		var form_json = [{
							type: 'block',
							blockOffset: 20,
							list: [{
								'type': 'input',
								'name': 'custom_activity_desc',
								'label': 'Custom Activity Description',
								'position': 'label-top',
								'validate': 'NotEmpty',
								'inputWidth': 220,
								'labelWidth': 'auto',
								'required': true,
								'userdata': {
									'validation_message': 'Required Field'
								},
								'tooltip': 'Custom Activity Description'
							}]
						}];
		var form_obj = win.attachForm();
		form_obj.load(get_form_json_locale(form_json));
		
		var toolbar_json = [{id:"ok", type:"button", img:"save.gif", imgdis:"save_dis.gif", text:"Ok", title:"Ok"}];
		var toolbar_obj = win.attachToolbar();
		toolbar_obj.setIconsPath(js_image_path + '/dhxtoolbar_web/');
		toolbar_obj.loadStruct(toolbar_json);
		
		toolbar_obj.attachEvent("onClick", function(id){
			var status = validate_form(form_obj);
			if (status == false) return;
			
			create_custom_activity(form_obj, module_event_id, workflow_group_id);
		});
	}
	
    /*
     * [Create the custom activity]
     */
	create_custom_activity = function(form_obj, module_event_id, workflow_group_id) {
		workflow_report.layout.cells('c').progressOn();
		var custom_activity_desc = form_obj.getItemValue('custom_activity_desc'); 
		
		var data = {
						'action': 'spa_register_event_manual',
						'flag': 'z',
						'module_event_id' : module_event_id,
						'group_id': workflow_group_id,
						'source_id': source_id,
						'source_column': source_column,
						'custom_activity_desc': custom_activity_desc
						
                   };
        result = adiha_post_data('alert', data, '', '', 'refresh_report', true);
		custom_activity_window.window('w1').close();
	}
	
    /*
     * [Complete/Remove the custom activity]
     */
	hyperlink_custom_click = function(workflow_custom_activity_id, flag) {
		workflow_report.layout.cells('c').progressOn();
		
		var data = {
						'action': 'spa_register_event_manual',
						'flag': flag,
						'custom_activity_id': workflow_custom_activity_id
					};
        result = adiha_post_data('alert', data, '', '', 'refresh_report', true);
	}
	
	
	hyperlink_custom_schedule_click = function(workflow_custom_activity_id) {
		hyperlink_schedule_click('','','',workflow_custom_activity_id)
	}
	
    /*
     * [Schedule the custom activity]
     */
	schedule_custom_activity = function(form_obj,custom_activity_id) {
		var schedule_date = form_obj.getItemValue('schedule_date', true);
		workflow_report.layout.cells('c').progressOn();
		
		var data = {
						'action': 'spa_register_event_manual',
						'flag': 'p',
						'custom_activity_id': custom_activity_id,
						'custom_schedule_date':schedule_date
					};
        result = adiha_post_data('alert', data, '', '', 'refresh_report', true);
		schedule_window.window('w1').close();
	}
	
    /*
     * [Cancel the scheduled custom activity]
     */
	hyperlink_custom_cancel_click = function(custom_activity_id, custom_activity_name) {
		workflow_report.layout.cells('c').progressOn();
		
		var data = {
						'action': 'spa_register_event_manual',
						'flag': 'f',
						'custom_activity_id': custom_activity_id,
						'custom_activity_desc': custom_activity_name
					};
        result = adiha_post_data('alert', data, '', '', 'refresh_report', true);		
	}
	
	/**
     * [open_document Open Document window]
     */
    function open_workflow_document(activity_id) {
        var document_window = new dhtmlXWindows();
        var win_title = 'Document';
        var win_url = app_form_path + '_setup/manage_documents/manage.documents.php?notes_object_id=' + activity_id + '&is_pop=true';

        var win = document_window.createWindow('w1', 0, 0, 400, 400);
        win.setText(win_title);
        win.centerOnScreen();
        win.setModal(true);
        win.maximize();
        win.attachURL(win_url, false, {call_from:'manage_approval_window',sub_category_id:42005,notes_category:44});

        win.attachEvent('onClose', function(w) {
            return true;
        });
    }
	
	
	hyperlink_calendar_complete_click = function(calendar_event_id) {
		workflow_report.layout.cells('c').progressOn();
		
		var date_from = new Date();
		date_from = dates.convert_to_sql_with_time(date_from)
		
		var data = {
						'action': 'spa_calendar',
						'flag': 'b',
						'calendar_event_id': calendar_event_id,
						'date_from': date_from,
						'is_batch': 0
					};
        result = adiha_post_data('alert', data, '', '', 'refresh_report', true);		
	}
	
	hyperlink_workflow_approval_click = function(action, workflow_activity_id) {
		workflow_report.layout.cells('c').progressOn();
		
		var data = {
						'action': ' spa_setup_rule_workflow',
						'flag': 'c',
						'activity_id': workflow_activity_id,
						'approved': action
					};
        result = adiha_post_data('alert', data, '', '', 'refresh_report', true);		
	}
	
	workflow_btn_click = function(obj) {
		$( ".workflow_message_details" ).each(function() {
			$(this).css( "display", "none" );
		});
		
		$(obj).siblings(".workflow_message_details").css( "display", "block" );
	}

</script>

