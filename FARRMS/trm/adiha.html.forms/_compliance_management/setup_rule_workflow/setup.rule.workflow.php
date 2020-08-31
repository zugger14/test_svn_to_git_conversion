<?php
/**
* Setup rule workflow screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<head>
	<meta http-equiv="Content-type" content="text/html; charset=utf-8">
</head>
    <?php include "../../../adiha.php.scripts/components/include.file.v3.php"; ?>
	<script src="../../../adiha.php.scripts/components/dhtmlxGantt/codebase/dhtmlxgantt.js" type="text/javascript" charset="utf-8"></script>
	<!--<script src="../../../adiha.php.scripts/components/dhtmlxGantt/codebase/ext/dhtmlxgantt_tooltip.js"></script> -->
	<link rel="stylesheet" href="../../../adiha.php.scripts/components/dhtmlxGantt/codebase/dhtmlxgantt.css" type="text/css" media="screen" title="no title" charset="utf-8">
    <link rel="stylesheet" href="../../../adiha.php.scripts/components/lib/adiha_dhtmlx/adiha_dhtmlx.css" type="text/css" media="screen" title="no title" />
	
	<style type="text/css">
		html, body  { height:100%; padding:0px; margin:0px; overflow: hidden;}
        .no_display { visibility: hidden;}
        .nested_task_w .fa-plus {display: none !important;}
        .nested_task .fa-plus   {display: none !important;}
        .nested_task .fa-times  {display: none !important;}
        
        .fa{
            cursor: pointer;
            font-size: 14px;
            text-align: center;
            opacity: 0.2;
            padding: 8px;
        }
        .fa:hover{
            opacity: 1;
        }
        .fa-plus{
            color: #328EA0;
        }
        .fa-times{
            color: red;
        }
		.fa-times.disable{
            color:black;
        }
        .fa-times.disable:hover{
            opacity: 0.2;
        }

		#workflow_legend {
			padding-left: 30px;
			padding-top: 15px;
			font-size: 12px;
            height: 50px;
            background-color: #f9f9f9;
		}
		
		.legent_icon {
			float: left;
			height: 12px;
			width: 16px;
			border-radius: 3px;
		}
		
		.legend_item {
			float: left;
			margin-left:5px;
			margin-right:15px;
		}
		
		.legent_icon_line {
			float: left;
			height:3px;
			width: 25px;
			margin-top: 9px;
		}
		
		.legent_icon_diamond {
			float: left;
			height: 12px;
			width: 12px;
			margin-right: 3px;
			transform: rotate(45deg);
		}
        
        #workflow_footer{
            width: 100%;
            height: 20px;
        }
        
        .hr_line {
            height: 2px;
            width: 100px;
            background-color: #3d5c5c;
            margin-top: 10px;
            float:left;
        }
        
        .hidden_message_task{
            display: none;
        } 

        /* CSS for Setup workflow conformation popup */
        .gantt_popup_button.gantt_ok_button, .gantt_popup_button.gantt_cancel_button  {
            color: #fff; font-style: italic; font-weight: 400; border-radius: 3px; border:0!important; 
        }

	</style>
	
	
	<?php
        $theme_selected = 'dhtmlx_'.$default_theme;

        $namespace = 'workflow_gantt';
        $rights_view = 10106600;
        $rights_save = 10106610;
        $rights_del = 10106611;

            list (
                $has_rights_view,
                $has_rights_save,
                $has_rights_del

            ) = build_security_rights(
                $rights_view,
                $rights_save,
                $rights_del
            );

        $layout_obj = new AdihaLayout();
        $layout_json = '[
                         {id: "a", header:true, collapse: false, height:90,width:300, text:"Filter",fix_size:[true,null]},
                         {id: "b", header:true, collapse: true, text:"Legend",fix_size:[true,null]},
                         {id: "c", header:false,fix_size:[true,true]}
                        ]';
        echo $layout_obj->init_layout('layout', '', '3U', $layout_json, $namespace);
        
        $menu_name = 'workflow_menu';
        $menu_json = '[
                        {id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif"},
                        {id:"expand_collapse", text:"Expand/Collapse", img:"exp_col.gif", imgdis:"exp_col_dis.gif"},
                        {id:"view", text:"View", img:"view.gif", items:[
                            {id:"normal_view", text:"Normal", img:"view_all.gif", imgdis:"view_all_dis.gif.gif" },
                            {id:"compact_view", text:"Compact", img:"view_active.gif", imgdis:"view_active_dis.gif"}
                        ]},
                        {id:"import_export", text:"Import/Export Rule", img:"export.gif", items:[
                            {id:"copy_workflow", text:"Copy", img:"export.gif", imgdis:"export_dis.gif", enabled :0},
                            {id:"import_workflow", text:"Import", img:"import.gif", imgdis:"import_dis.gif" },
                            {id:"import_workflow_as", text:"Import As", img:"import.gif", imgdis:"import_dis.gif" },
                            {id:"export_workflow", text:"Export", img:"export.gif", imgdis:"export_dis.gif", enabled :0}
                        ]}
                      ]';

        echo $layout_obj->attach_menu_layout_cell($menu_name, 'c', $menu_json, $namespace.'.menu_click');
        echo $layout_obj->attach_footer('workflow_footer');

        $form_name = 'workflow_form';
        $form_obj = new AdihaForm();
        echo $layout_obj->attach_form($form_name, 'a');

        $sp_workflow_group = "EXEC ('SELECT id,[text] FROM workflow_schedule_task WHERE workflow_id_type = 0 AND ISNULL(system_defined,0) = 0 ORDER BY [text]')";
        $opt_workdflow_group = $form_obj->adiha_form_dropdown($sp_workflow_group, 0, 1, true);
        $sql = "EXEC spa_StaticDataValues @flag = 'h', @type_id = 20600";
        $modules_val = $form_obj->adiha_form_dropdown($sql, 0, 1, true, '', 2);
        $sql = "EXEC spa_StaticDataValues @flag = 'h', @type_id = 20500";
        $event_val = $form_obj->adiha_form_dropdown($sql, 0, 1, true, '', 2);
        
        $form_json = "[
                        {type: 'settings', position: 'label-top',offsetLeft:".$ui_settings['offset_left']."},
                        {
                            type: 'block',
                            blockOffset: ".$ui_settings['block_offset'].",
                            list: [
                            {
                                'type': 'combo',
                                'name': 'system_defined',
                                'label': 'Workflow Type',
                                'inputWidth': ".$ui_settings['field_size'].",
                                'labelWidth': ".$ui_settings['field_size'].",
                                'tooltip': 'Workflow Type',
                                'filtering':true,
                                'filtering_mode': 'between',
                                'options':[{text:'Workflow',value:'0',selected:true},{text:'System Defined',value:'1'}]
                            },{type: 'newcolumn', offset: 1},{
                                'type': 'combo',
                                'name': 'workflow_group',
                                'label': 'Workflow Group',
                                'inputWidth': ".$ui_settings['field_size'].",
                                'labelWidth': 'auto',
                                'tooltip': 'Workflow Group',
                                'filtering':true,
                                'filtering_mode': 'between',
                                'options':$opt_workdflow_group
                            },{type: 'newcolumn', offset: 1},{
                                'type': 'combo',
                                'name': 'module_id',
                                'label': 'Module',
                                'inputWidth': ".$ui_settings['field_size'].",
                                'labelWidth': 'auto',
                                'tooltip': 'Workflow Group',
                                'filtering':true,
                                'filtering_mode': 'between',
                                'options':$modules_val
                            },{type: 'newcolumn', offset: 1},{
                                'type': 'combo',
                                'name': 'event_id',
                                'label': 'Event',
                                'inputWidth': ".$ui_settings['field_size'].",
                                'labelWidth': 'auto',
                                'tooltip': 'Workflow Group',
                                'filtering':true,
                                'filtering_mode': 'between',
                                'options':$event_val
                            }]
                        }]";
    
        echo $form_obj->init_by_attach($form_name, $namespace);
        echo $form_obj->load_form($form_json);
        echo $form_obj->attach_event('', 'onChange', $namespace .'.workflow_group_change');

        echo $layout_obj->close_layout();
    ?>
	<!--<input value="Export to PDF" type="button" onclick='gantt.exportToPDF()'>
	<input value="Export to Excel" type="button" onclick='gantt.exportToExcel()'>	-->
<body>
    <div id="context_menu" style="display: none;">
        <div id="approve" text="Approve"></div>
        <div id="unapprove" text="Unapprove"></div>
        <div id="complete" text="Complete"></div>
        <div id="exception" text="Exception"></div>
        <div id="success" text="Success"></div>
        <div id="failure" text="Failure"></div>
    </div>
    <div id="automatic_proceed_menu" style="display: none;">
        <div id="automatic_proceed" text="Automatic Proceed"></div>
    </div>
	<div id="workflow_legend">
		<div class="legent_icon" style="background-color:#b8b894;"></div><div class="legend_item"><?php echo get_locale_value("Workflow Group"); ?></div>
		<div class="legent_icon" style="background-color:#29a329;"></div><div class="legend_item"><?php echo get_locale_value("Workflow"); ?></div>
		<div class="legent_icon" style="background-color:#3db9d3;"></div><div class="legend_item"><?php echo get_locale_value("Event"); ?></div>
		<div class="legent_icon" style="background-color:#9999ff;"></div><div class="legend_item"><?php echo get_locale_value("Notification"); ?></div>
		<div class="legent_icon_diamond" style="background-color:#ff4dff;"></div><div class="legend_item"><?php echo get_locale_value("Action"); ?></div>
		<div class="legent_icon_line" style="background-color:orange;"></div><div class="legend_item"><?php echo get_locale_value("Connector"); ?></div>
		<div class="legent_icon_line" style="background-color:green;"></div><div class="legend_item"><?php echo get_locale_value("Approve"); ?></div>
		<div class="legent_icon_line" style="background-color:red;"></div><div class="legend_item"><?php echo get_locale_value("Unapprove"); ?></div>
		<div class="legent_icon_line" style="background-color:blue;"></div><div class="legend_item"><?php echo get_locale_value("Complete"); ?></div>
		<div class="legent_icon_line" style="background-color:black;"></div><div class="legend_item"><?php echo get_locale_value("Exception"); ?></div>
	</div>
   <div id="workflow_footer">
       <div class="plus_minus" style="float:right;">
            <div style="margin-right:20px;">
                <div style="float:left;">
                    <img class="message_image" src="<?php echo $image_path; ?>dhxtoolbar_web/minus.png" alt="minus" height="24" width="24" title="Decrease" onclick="increase_decrease_gantt_chart('d')"/>
                </div>
                <div class="hr_line"></div>
                <div style="float:left;">
                    <img class="message_image" src="<?php echo $image_path; ?>dhxtoolbar_web/plus.png" alt="plus" height="24" width="24" title="Increase" onclick="increase_decrease_gantt_chart('i')"/>
                </div>
            </div>         
       </div>
       <div class="view_type" style="float:right; padding-top:3px; padding-right:20px;">Normal View</div>
   </div>
    <div id="gantt_here" style='width:100%; height:100%;'></div>
	<script type="text/javascript">
        var super_parent_id = '';
        var expand_collapse_state = 0;
        var max_end_date = new Date(1900, 00, 01);
        var has_rights_view = <?php echo (($has_rights_view) ? $has_rights_view : '0');?>;
        var has_rights_save = <?php echo (($has_rights_save) ? $has_rights_save : '0');?>;
        var has_rights_del = <?php echo (($has_rights_del) ? $has_rights_del : '0');?>;
        var php_script_loc_ajax = '<?php echo $app_php_script_loc; ?>';
        
        /* User Defined Properties of Task
            Workflow Group
                - text -> workflow_group_name(task_obj.text)
                - ud_value1 -> system_defined (task_obj.ud_value1)
            Workflow Task
                - text -> workflow_name (task_obj.text)
                - ud_value1 -> workflow_id(event_modules_id) (task_obj.ud_value1)
                - ud_value2 -> module_id (task_obj.ud_value2)
                - ud_value3 -> event_id (task_obj.ud_value3)
                - ud_value4 -> rule_table_id (task_obj.ud_value4)
            Workflow Event/Alert
                - text -> Alert name (task_obj.text)
                - ud_value1 -> event_trigger_id (task_obj.ud_value1)
                - ud_value2 -> alert_id (task_obj.ud_value2)
                - ud_value3 -> initial_event (task_obj.ud_value3)
            Workflow Message
                - text -> Message Name (task_obj.text)
                - ud_value1 -> event_message_id (task_obj.ud_value1)
                - ud_value2 -> automatic_proceed (task_obj.ud_value2)
            Workflow Action
                - ud_value1 -> Approve Rule (task_obj.ud_value1)
                - ud_value2 -> Unapprove Rule (task_obj.ud_value2)
                - ud_value3 -> Completed Rule (task_obj.ud_value3)
                - ud_value4 -> Exception Rule (task_obj.ud_value4)
                - ud_value5 -> Threshold Days (task_obj.ud_value5)
                - ud_value6 -> Success Rule (task_obj.ud_value6)
                - ud_value7 -> Failure Rule (task_obj.ud_value7)
        */
        
        
        $(function() {
            load_gantt();
        })
        
        load_gantt = function() {
            
            //CSS To hide the date in timeline
            gantt.templates.scale_row_class = function(scale){
                return 'no_display';
            }
            
            gantt.templates.task_class = function(start, end, task){
                if(task.type == gantt.config.types.hidden_message){
                    return "hidden_message_task";
                }
                return "";
            };

            var colHeader = '<div class="gantt_grid_head_cell gantt_grid_head_add workflow_g" onclick="gantt.createTask()"></div>',
                colContent = function(task){
                    if (has_rights_del) {
                        return ('<i class="fa fa-times" onclick="grid_button_click('+task.id+', \'delete\')"></i>' +'<i class="fa fa-plus" onclick="grid_button_click('+task.id+', \'add\')"></i>');
                    } else {
                         return ('<i class="fa fa-times disable"></i>' + '<i class="fa fa-plus" onclick="grid_button_click('+task.id+', \'add\')"></i>');
                    }
                };
            
            //Defining the grid and To hide start_date and duration in grid
            gantt.config.columns = [
                { name:"text", label: get_locale_value("Workflow/Event/Message/Action"), tree:true, width:250, resize: true},
                { name:"start_date", align: "center", width:150, hide:true},
                { name:"duration", align: "center", width:70, hide:true},
                {
                    name:"buttons",
                    label:colHeader,
                    width:75,
                    template:colContent
                }
            ];
            
            gantt.config.types.hidden_message = "type_id";
            gantt.locale.labels.confirm_deleting_title = get_locale_value("Confirmation");
            gantt.locale.labels.type_hidden_message = "hidden_message";  
			gantt.locale.labels.confirm_deleting = get_locale_value('Are you sure you want to delete?');
            gantt.config.order_branch = true;
            gantt.config.row_height = 35;
			gantt.config.min_column_width = 50;
            gantt.config.start_date = new Date(2015, 00, 01);
            gantt.config.end_date = new Date(2015, 00, 22);
            gantt.init("gantt_here");
            
            gantt.templates.grid_row_class = function(start, end, task){
                var task_id = task.id;
                
                var has_template = check_if_template(task_id,task.$level);
                
                if(has_template == 't' && task.$level == 1){
                  return "nested_task_w";
               } else if(has_template == 't'){
                  return "nested_task";
               }
               return "";
            };
            /*------------------ START OF EVENTS --------------------------*/
            
            //To prevent sorting only between the same parents.
            gantt.attachEvent("onBeforeTaskMove", function(id, parent, tindex){
                var task = gantt.getTask(id);
                
                var task_level = gantt.calculateTaskLevel(id);
                var template = check_if_template(id,task_level);
                if(template == 't') return false;
                
                if(task.parent != parent)
                    return false;
                return true;
            });
            
            // To Prevent from task resize
            gantt.attachEvent("onBeforeTaskDrag", function(id, mode, e){
                var task_level = gantt.calculateTaskLevel(id);
                var template = check_if_template(id,task_level);
                if(template == 't') return false;
                
                return true;
            });
            
            gantt.attachEvent("onAfterTaskDrag", function(id, mode, e){
                var task_level = gantt.calculateTaskLevel(id);
                var template = check_if_template(id,task_level);
                if(template == 't') return false;
                
                gantt_task_drag(id);
            });
            
            // To prevent the link between same level tasks
            gantt.attachEvent("onBeforeLinkAdd", function(id,link){
                var source_id = link.source;
                var target_id = link.target;
                var source_id_level = gantt.calculateTaskLevel(source_id);
                var target_id_level = gantt.calculateTaskLevel(target_id);
                
                var s_template = check_if_template(source_id,source_id_level);
                var t_template = check_if_template(target_id,target_id_level);
                if(s_template == 't' || t_template == 't') return false;
                
                if (source_id_level == target_id_level) 
                    return false;
                
                if (source_id_level == 0 || source_id_level == 1)
                    return false;
                
                if (source_id_level == 2 && target_id_level != 3)
                    return false;
                
                if (source_id_level == 3 && target_id_level != 4 && target_id_level != 1)
                    return false;
                
                if (source_id_level == 4 && target_id_level != 2 && target_id_level != 3)
                    return false;
                
                return true;
            });
            
            gantt.attachEvent("onBeforeLinkDelete", function(id,link){
                var source_id = link.source;
                var target_id = link.target;
                var source_id_level = gantt.calculateTaskLevel(source_id);
                var target_id_level = gantt.calculateTaskLevel(target_id);
                
                var s_template = check_if_template(source_id,source_id_level);
                var t_template = check_if_template(target_id,target_id_level);
                if(s_template == 't' || t_template == 't') return false;
                
                if (source_id_level >= 2)
                    return true;
                else 
                    return false;
            });
            
            
            /*//To open workflow windos on double click... UPDATE MODE
            gantt.attachEvent("onTaskDblClick", function(id,e){
                if (id == null) {
                    return true;
                } else {
                    var level = gantt.calculateTaskLevel(id);
                    if (level == 0) {
                        return true;
                    }
                    var task_obj = gantt.getTask(id);
                    gantt_task_window(level, task_obj);    
                }
            });*/
            
            //To open workflow window on + click...... INSERT MODE
            gantt.attachEvent("onBeforeLightbox", function(id) {
                var level = gantt.calculateTaskLevel(id);
                var task_obj = gantt.getTask(id);
                var task_name = task_obj.text;
                if (task_name == 'New task') {
                    add_gantt_task(id);
                } else {
                    update_gantt_task(id);
                }
            });    
            
            gantt.attachEvent("onAfterLinkAdd", function(id,item){
                add_gantt_link(id,item)
            });
            
            gantt.attachEvent("onAfterLinkDelete", function(id,item){
                delete_gantt_link(id,item);
            });
            
            gantt.attachEvent("onRowDragEnd", function(id, target) {
                var task_level = gantt.calculateTaskLevel(id);
                var parent_id = gantt.getParent(id);
                
                var template = check_if_template(id,task_level);
                if(template == 't') return false;
                
                if (task_level == 1 || task_level == 2 || task_level == 3)
                    update_squence_number(parent_id);
                else
                    return;
            });
            
            
            workflow_gantt.layout.cells("c").attachGantt(null, null, gantt); 
			workflow_gantt.layout.cells("b").attachObject("workflow_legend");
            
            load_gantt_context_menu();
            
            var workflow_group_id = workflow_gantt.workflow_form.getItemValue('workflow_group');
            if (workflow_group_id !='')
                load_gantt_data();
        }
        
        workflow_gantt.menu_click = function(id, zoneId, cas) {

            if (id == 'refresh') {
                super_parent_id = '';
                var workflow_type = workflow_gantt.workflow_form.getItemValue('system_defined');
                if (workflow_type == 1) {
                    is_user_authorized('load_gantt_data');
                } else {
                    load_gantt_data();
                }
            } else if (id == 'expand_collapse') {
                expand_collapse_gantt();
            } else if (id == 'normal_view') {
                var col = gantt.getGridColumn('buttons');
                col.hide = false;
                gantt.config.row_height = 35;
                gantt.config.readonly = false;
                gantt.config.scale_unit = "day";
                gantt.render();
                $('.view_type').html('Normal View');
            } else if (id == 'compact_view') {
                var col = gantt.getGridColumn('buttons');
                col.hide = true;
                gantt.config.scale_unit = "month";
                gantt.config.readonly = true;
                gantt.config.row_height = 30;
                gantt.render();    
                $('.view_type').html('Compact View (Read Only)');
            } else if (id == 'import_workflow') {
                if (workflow_gantt.import_window != null && workflow_gantt.import_window.unload != null) {
                    workflow_gantt.import_window.unload();
                    workflow_gantt.import_window = w2 = null;
                }
                if (!workflow_gantt.import_window) {
                    workflow_gantt.import_window = new dhtmlXWindows();
                }

                workflow_gantt.new_win = workflow_gantt.import_window.createWindow('w2', 0, 0, 650, 250);

                var text = "Import Workflow";

                workflow_gantt.new_win.setText(text);
                workflow_gantt.new_win.setModal(true);

                var url = app_form_path + '_compliance_management/setup_rule_workflow/manage.alert.workflow.import.export.php';
                url = url + '?flag=import_workflow&call_from=mapping';
                workflow_gantt.new_win.attachURL(url, false, true);
            } else if (id == 'import_workflow_as') {
                if (workflow_gantt.import_window != null && workflow_gantt.import_window.unload != null) {
                    workflow_gantt.import_window.unload();
                    workflow_gantt.import_window = w2 = null;
                }
                if (!workflow_gantt.import_window) {
                    workflow_gantt.import_window = new dhtmlXWindows();
                }

                workflow_gantt.new_win = workflow_gantt.import_window.createWindow('w2', 0, 0, 650, 250);

                var text = "Import Workflow";

                workflow_gantt.new_win.setText(text);
                workflow_gantt.new_win.setModal(true);

                var url = app_form_path + '_compliance_management/setup_rule_workflow/manage.alert.workflow.import.export.php';
                url = url + '?flag=import_workflow&call_from=mapping&copy_field_req=1';
                workflow_gantt.new_win.attachURL(url, false, true);    
            } else if (id == 'export_workflow' || id == 'copy_workflow' || id == 'export_copy_workflow') {
                var selected_id = gantt.getSelectedId();
                if (!selected_id || selected_id == '') {
                    show_messagebox("No workflow selected.");
                    return;
                }

                var task_level = gantt.calculateTaskLevel(selected_id);
                if (task_level != 0)
                    return;
                if (id == 'export_workflow') {
                    data = {"action": "spa_workflow_import_export",
                        "flag": "export_workflow",
                        "workflow_group_id": selected_id
                    };
                    adiha_post_data('return_array', data, '', '', 'workflow_gantt.download_script', '', '');
                } else if (id == 'copy_workflow') {
                    data = {"action": "spa_workflow_import_export",
                        "flag": "copy_workflow",
                        "workflow_group_id": selected_id
                    };
                    adiha_post_data('return_array', data, '', '', 'workflow_gantt.workflow_copy', '', '');
                } 
            }
        }
        
        increase_decrease_gantt_chart = function(flag) {
            var inc_val = ($('.view_type').html() == 'Compact View (Read Only)') ? 31 : 2;
            
            if (flag == 'i') {
                var end_date = new Date(gantt.config.end_date);
                var new_end_date = new Date(end_date.getTime() + inc_val * 86400000);
                gantt.config.end_date = new_end_date;
                gantt.render();
            } else if (flag == 'd') {
                var end_date = new Date(gantt.config.end_date);
                var new_end_date = new Date(end_date.getTime() - inc_val * 86400000);
                
                console.log(max_end_date + '   ' + new_end_date);
                
                if (max_end_date >= new_end_date)
                     new_end_date = new Date(max_end_date.getTime() + 2 * 86400000); 
                    
                gantt.config.end_date = new_end_date;
                gantt.render();
            }
        }
        
        workflow_gantt.workflow_group_change = function(name,value) {
            if (name == 'system_defined') {
                var workflow_type = workflow_gantt.workflow_form.getItemValue('system_defined');
                gantt.clearAll(); 
                if (workflow_type == 0) {
                    workflow_gantt.workflow_form.enableItem('module_id');
                    workflow_gantt.workflow_form.enableItem('event_id');
                } else {
                    workflow_gantt.workflow_form.disableItem('module_id');
                    workflow_gantt.workflow_form.disableItem('event_id');
                    workflow_gantt.workflow_form.setItemValue('module_id','');
                    workflow_gantt.workflow_form.setItemValue('event_id','');

                }
                reload_workflow_group('', 0, workflow_type);
            }
        }   
        
        expand_collapse_gantt = function() {
            var all_task = gantt.getTaskByTime();
            for (var i=0; i<all_task.length; i++){
                var task_id = all_task[i].id;
                var task_level = gantt.calculateTaskLevel(task_id);
                
                if (task_level == 1 && expand_collapse_state == 0) {
                    gantt.open(task_id);
                } else if (task_level == 1 && expand_collapse_state == 1) {
                    gantt.close(task_id);
                }
            }
            
            expand_collapse_state = (expand_collapse_state == 0) ? 1 : 0;
        }
        
        reload_workflow_group = function(cmb_val, reload_flag, system_defined) {
            var has_blank_option = (system_defined == 0 ? true : false);
            var workflow_group_cmb = workflow_gantt.workflow_form.getCombo('workflow_group');
            var cm_param = {
                                "action": "('SELECT id,[text] FROM workflow_schedule_task WHERE workflow_id_type = 0 AND ISNULL(system_defined,0) = " + system_defined + " ORDER BY [text]')", 
                                "call_from": "form",
                                "has_blank_option": has_blank_option
                            };

            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;
            workflow_group_cmb.clearAll();
            workflow_group_cmb.load(url, function() {
                if (cmb_val != '') {
                    workflow_gantt.workflow_form.setItemValue('workflow_group', cmb_val);
                } else {
                    if (has_blank_option == false) {
                        workflow_group_cmb.selectOption(0);
                    } else {
                        workflow_group_cmb.setComboText('');
                    }
                }
                
                if (reload_flag == 1) {
                    load_gantt_data();
                }
            });
        }

        /*
         * Load the data in the gantt
         */
        load_gantt_data = function() {
            var workflow_group_id = workflow_gantt.workflow_form.getItemValue('workflow_group');
            var module_id = workflow_gantt.workflow_form.getItemValue('module_id');
            var event_id = workflow_gantt.workflow_form.getItemValue('event_id');
            
            if (workflow_group_id == '' && module_id == '' && event_id == '') {
                show_messagebox('Please select any one of the filter.');
                return;
            }
            
            var data = {action : "spa_workflow_schedule", flag : "s", task_id: workflow_group_id, module_id:module_id, event_id:event_id}
            adiha_post_data("return_array", data, "", "", 'load_gantt_data_callback');

            workflow_gantt.workflow_menu.setItemEnabled('export_workflow');
            workflow_gantt.workflow_menu.setItemEnabled('copy_workflow');
        }
        
        /*
         * Callback of load
         */
        load_gantt_data_callback = function(result) {
            gantt.clearAll(); 
            var tasks = JSON.parse(result[0][0]);
            gantt.parse(tasks);
            var workflow_task_count = 0;
            var workflow_task_id;
            max_end_date = new Date(1900, 00, 01);
            max_task_level = 0;
            
            //To change the task type
            var all_task = gantt.getTaskByTime();
            if(all_task.length == 0) {
                show_messagebox('No workflow/alerts found for the applied filters.');
                return;
            }
            
            for (var i=0; i<all_task.length; i++){
                var task_id = all_task[i].id;
                var task_level = gantt.calculateTaskLevel(task_id); 
                
                if (task_level > max_task_level)
                    max_task_level = task_level;
            }
            
            for (var i=0; i<all_task.length; i++){
                var task_id = all_task[i].id;
                var task_level = gantt.calculateTaskLevel(task_id);
                
                var task_obj = gantt.getTask(task_id);
                var end_date = gantt.calculateEndDate(new Date(task_obj.start_date),task_obj.duration,"hour");
                
                if (end_date > max_end_date) 
                    max_end_date = end_date;
                
                if ((task_level == 0 || task_level == 1) && max_task_level > 1) {
                    all_task[i].type = gantt.config.types.project; 
                    gantt.updateTask(task_id); 
                    gantt.refreshData();
                } else if (task_level == 4) {
                    all_task[i].type = gantt.config.types.milestone; 
                    gantt.updateTask(task_id); 
                    gantt.refreshData();
                } else if (task_level == 3) {
                    var task_obj = gantt.getTask(task_id);
                    var is_automatic_proceed = task_obj.ud_value2;
                    if (is_automatic_proceed == 'h') {
                        all_task[i].type = gantt.config.types.hidden_message; 
                        gantt.updateTask(task_id); 
                        gantt.refreshData();
                    }
                }
                
                if (task_level == 1) {
                    workflow_task_count++;
                    workflow_task_id = task_id;
                }
            }
            
            if (max_end_date >= (new Date(2015, 00, 22))) {
                max_end_date = new Date(max_end_date.getTime() + 2 * 86400000);
                gantt.config.end_date = max_end_date;
                gantt.render();
            }
            
            if(super_parent_id != '') {
                var p_super_parent_id = gantt.getParent(super_parent_id);
                gantt.open(p_super_parent_id);
            }
            gantt.open(super_parent_id);
            
            if (workflow_task_count == 1) {
                gantt.open(workflow_task_id);
                expand_collapse_state = 1;
            } else {
                expand_collapse_state = 0;
            }
        }
        
        
        /*============= TASK FUNCTION START ==================*/
        grid_button_click = function(id, action) {

            switch (action) {
                case "add":
                    gantt.createTask(null, id);
                    break;
                case "delete":
                    gantt.confirm({
                        title: gantt.locale.labels.confirm_deleting_title,
                        text: gantt.locale.labels.confirm_deleting,
						ok: get_locale_value("Confirm"),
                        cancel: get_locale_value("Cancel"),                         
                        callback: function(res){
                            if(res)
                               delete_gantt_task(id); 
                        }
                    });
                    break;
            }
        }
        
        add_gantt_task = function(id) {
            var parent_id = gantt.getParent(id);
            var level = gantt.calculateTaskLevel(id);
            gantt.deleteTask(id);
            gantt.refreshData();
            
            gantt_task_window(level, '', parent_id);
        }
        
        update_gantt_task = function(id) {
            var level = gantt.calculateTaskLevel(id);
            var task_obj = gantt.getTask(id);
            var parent_id = gantt.getParent(id);
            gantt_task_window(level, task_obj, parent_id);
        } 
        
        delete_gantt_task = function(id) {
            var task_level = gantt.calculateTaskLevel(id);
            var data = {
                "action": "spa_workflow_schedule", 
                "flag": 'd',
                "task_id": id,
                "task_level": task_level
            }

            data = $.param(data)

            $.ajax({
                type: "POST",
                dataType: "json",
                url: js_form_process_url,
                async: false,
                data: data,
                success: function(data) {
                    response_data = data["json"];
                    if (response_data[0].errorcode == 'Success') {
                        gantt.deleteTask(id);
                        if (task_level == 0) {
                            reload_workflow_group('', 0, 0);
                        } else if (task_level == 2) {
                            load_gantt_data();
                        }
                        dhtmlx.message({
                            text:response_data[0].message,
                            expire:1000
                        });
                    } else {
                        show_messagebox('Error');
                   }
                }
            });
        }
        
        gantt_task_drag = function(id) {
            var task_obj = gantt.getTask(id);
            var start_date = task_obj.start_date;
            start_date = dates.convert_to_sql(start_date);
            var duration = task_obj.duration;
            
            var data = {
                "action": "spa_workflow_schedule", 
                "flag": 'u',
                "task_id": id,
                "task_date": start_date,
                "task_duration": duration
            }

            data = $.param(data);
            
            $.ajax({
                type: "POST",
                dataType: "json",
                url: js_form_process_url,
                async: false,
                data: data
            });
        }
        
        gantt_task_window = function(level, task_obj, parent_id) {
            var doc_window = new dhtmlXWindows();
            if (level == 0) {
                gantt_chart_workflow_group_window(task_obj);
            } else if (level == 1) {
                gantt_chart_workflow_window(task_obj, parent_id);
            } else if (level == 2) {
                gantt_task_rule_window(task_obj, parent_id, 'rule_add');
            } else if (level == 3 || level == 5) {
                if (task_obj == '') {
                    var message_id = '';
                    var template = 'w';
                } else {
                    var message_id = task_obj.ud_value1;
                    var template = check_if_template(parent_id, 2);
                    var is_automatic_proceed = task_obj.ud_value2;
                    if (is_automatic_proceed == 'h') {
                        success_call("Non-editable Message.", 'error');
                        return;
                    }
                }
                var parent_task_obj = gantt.getTask(parent_id);
                if (level == 3) {
                    var rule_id = parent_task_obj.ud_value1;
                } else if (level == 5) {
                    var rule_id = -9999;
                    parent_id = gantt.getParent(gantt.getParent(parent_id));
                }
                m_win = doc_window.createWindow('w1', 0, 0, 890, 650);
                m_win.setText("Message");
                m_win.centerOnScreen();
                m_win.setModal(true);
                m_win.attachURL("workflow.rule.message.php?rule_id=" + rule_id + "&message_id=" + message_id + "&parent_id=" + parent_id + "&template=" + template);
                
                doc_window.attachEvent("onClose", function(win){
                    set_super_parent_id(parent_id, 1);
                    load_gantt_data();
                    return true;
                });
            } else if (level == 4) {
                gantt_task_action_window(task_obj, parent_id, '');
            }
        }
        
        gantt_task_save_callback = function(result) {
            win.close();
            load_gantt_data();
            refresh_action_ui_fields();
        }

        action_gantt_task_save_callback = function(result) {
            action_win.close();
            load_gantt_data();
            refresh_action_ui_fields();
        }


        
        /*============= TASK FUNCTION END ==================*/
        
        
        
        /*============= LINK FUNCTION START ==================*/
        add_gantt_link = function(id, item) {

            var source = item.source;
            var target = item.target;
            var type = item.type;
            
            var data = {
                "action": "spa_workflow_schedule", 
                "flag": 'l',
                "link_source": source,
                "link_target": target,
                "link_type":type
            }

            data = $.param(data)

            $.ajax({
                type: "POST",
                dataType: "json",
                url: js_form_process_url,
                async: false,
                data: data,
                success: function(data) {
                    response_data = data["json"];
                    if (response_data[0].errorcode == 'Success') {
                        var new_id = response_data[0].recommendation;
                        gantt.changeLinkId(id, new_id);
                        gantt.refreshData();
                    } else {
                        show_messagebox('Error');
                   }
                    
                }
            });
        }

        delete_gantt_link = function(id, item) {

            var data = {
                "action": "spa_workflow_schedule", 
                "flag": 'k',
                "link_id": id
            }

            data = $.param(data);
            
            $.ajax({
                type: "POST",
                dataType: "json",
                url: js_form_process_url,
                async: false,
                data: data,
                success: function(data) {
                    load_gantt_data();
                }
            });
        }
        /*============= LINK FUNCTION END ==================*/
            
        
        /*============= WORKFLOW GROUP WINDOW FUNCTION START ==================*/
        gantt_chart_workflow_group_window = function(task_obj, parent_id) {
            if (task_obj == '') {
                var workflow_group_name = '';
                var system_defined = '';
            } else {
                var workflow_group_name = task_obj.text;
                var system_defined = task_obj.ud_value1;
            }
            
            var workflow_window = new dhtmlXWindows();
            win = workflow_window.createWindow('w1', 0, 0, 540, 200);
            win.setText("Workflow Group");
            win.centerOnScreen();
            win.setModal(true);
            
            var form_json = [{
                                type: 'block',
                                blockOffset: ui_settings['block_offset'],
                                list: [
                                    {
                                        'type': 'input',
                                        'name': 'workflow_group_name',
                                        'label': 'Workflow Group Name',
                                        'position': 'label-top',
                                        'validate': 'NotEmpty',
                                        'inputWidth': ui_settings['field_size'],
                                        'offsetLeft':ui_settings['offset_left'],
                                        'labelWidth': 'auto',
                                        'required': true,
                                        'filtering': true,
                                        'userdata': {
                                            'validation_message': 'Required Field'
                                        },
                                        'tooltip': 'Rule',
                                        'value': workflow_group_name
                                    }, {type: 'newcolumn', offset: 1},
                                    {
                                        'type': 'combo',
                                        'name': 'system_defined',
                                        'label': 'Workflow Type',
                                        'position': 'label-top',
                                        'inputWidth': ui_settings['field_size'],
										'offsetLeft':ui_settings['offset_left'],
                                        'labelWidth': 'auto',
                                        'tooltip': 'Workflow Type',
                                        'filtering':true,
                                        'filtering_mode': 'between',
                                        'options':[{text:'Workflow',value:'0',selected:true},{text:'System Defined',value:'1'}]
                                    }
                                ]
                            }];
            var toolbar_json = [{id:"save", type:"button", img:"save.gif", imgdis:"save_dis.gif", text:"Save", title:"Save", enabled:has_rights_save}];
            var toolbar_obj = win.attachToolbar();
            toolbar_obj.setIconsPath(js_image_path + '/dhxtoolbar_web/');
            toolbar_obj.loadStruct(toolbar_json);
            toolbar_obj.attachEvent("onClick", function(id){
                gantt_chart_workflow_group_save(form_obj, task_obj);
            });
            
            var form_obj = win.attachForm();
            form_obj.load(get_form_json_locale(form_json), function(){
                form_obj.setItemValue('system_defined', system_defined);
            });
        }
            
        gantt_chart_workflow_group_save = function(form_obj, task_obj) {
            var status = validate_form(form_obj);
            if (status) {
                if (task_obj == '') {
                    var workflow_group_id = '';
                } else {
                    var workflow_group_id = task_obj.id;
                }
                var workflow_group_name = form_obj.getItemValue("workflow_group_name");
                var system_defined = form_obj.getItemValue('system_defined');
                saved_system_defined = system_defined;
                
                var xml = '<Root>'
                xml = xml + '<TaskXML start_date="2015-01-02" duration="2" workflow_id_type="0" parent_id="" workflow_group_id="' + workflow_group_id + '" workflow_group_name="' + workflow_group_name + '" system_defined="' + system_defined + '"></TaskXML>'
                xml = xml + '</Root>';
                
                data = {
                        "action": "spa_workflow_schedule", 
                        "flag": 'g',
                        "xml": xml
                    }
                result = adiha_post_data("alert", data, "", "", "gantt_chart_workflow_group_save_callback");
                
             } 
        }  
        
        gantt_chart_workflow_group_save_callback = function(result) {
            if (result[0].errorcode == 'Success') {
                workflow_group_id = result[0].recommendation;
                if (saved_system_defined > 0) {
                    workflow_gantt.workflow_form.setItemValue('system_defined',saved_system_defined);
                    workflow_gantt.workflow_form.disableItem('module_id');
                    workflow_gantt.workflow_form.disableItem('event_id');
                    reload_workflow_group(workflow_group_id, 1, saved_system_defined);
                } else {
                    workflow_gantt.workflow_form.setItemValue('system_defined',saved_system_defined);
                    reload_workflow_group(workflow_group_id, 1, saved_system_defined);
                }
                super_parent_id = '';
                win.close();
            }
        }
        
        /*============= WORKFLOW GROUP WINDOW FUNCTION END ==================*/
        
        
            
        
        /*============= WORKFLOW WINDOW FUNCTION START ==================*/
        gantt_chart_workflow_window = function(task_obj, parent_id) {
            if (task_obj == '') {
                var task_id = '';
                var workflow_name = '';
                var module_id = '';
                var event_id = '';
                var module_events_id = '';
                var rule_table_id = '';
                var workflow_option = '';
				var is_active = 'y';
				var eod_as_of_date = new Date().toJSON().slice(0,10).replace(/-/g,'-');
            } else {
                var task_id = task_obj.id;
                var workflow_name = task_obj.text;
                var module_events_id = task_obj.ud_value1;
                var module_id = task_obj.ud_value2;
                var event_id = task_obj.ud_value3;
                var rule_table_id = task_obj.ud_value4;
                var workflow_option = task_obj.ud_value5;
				var is_active = task_obj.ud_value6;
				var eod_as_of_date = (task_obj.ud_value7)?task_obj.ud_value7:(new Date().toJSON().slice(0,10).replace(/-/g,'/'));
            }
            
            var workflow_window = new dhtmlXWindows();
            m_win = workflow_window.createWindow('w1', 0, 0, 610, 620);
            m_win.setText("Workflow");
            m_win.centerOnScreen();
            m_win.setModal(true);
            m_win.attachURL("workflow.window.php?module_events_id=" + module_events_id + "&workflow_name=" + workflow_name + "&event_id=" + event_id + "&module_id=" + module_id + "&rule_table_id=" + rule_table_id + "&parent_id=" + parent_id + "&task_id=" + task_id + "&workflow_option=" + workflow_option + "&is_active=" + is_active + "&eod_as_of_date=" + eod_as_of_date);
            
            workflow_window.attachEvent("onClose", function(win){
                set_super_parent_id(task_obj.id, 0);
                load_gantt_data();
                return true;
            });
        }
        
        /*============= WORKFLOW WINDOW FUNCTION END ==================*/
        
        
        
        /*============= RULE WINDOW FUNCTION START ==================*/
        gantt_task_rule_window = function(task_obj, parent_id, rule_from) {
            if (rule_from == 'next_action') {
                var p_obj = gantt.getTask(parent_id);
                var current_level = p_obj.$level;
                for (var i = current_level; i > 1; ) {
                    var rendered_parent_id = p_obj.$rendered_parent;
                    p_obj = gantt.getTask(rendered_parent_id);
                    i = p_obj.$level;
                    parent_id = rendered_parent_id;
                }
            } else {
                var p_obj = gantt.getTask(parent_id);
            }
            

            if (task_obj == '') {
                var alert_id = -1;
                var initial_event = '';
                var manual_step = '';
                var template = 'w';
				var is_disable = false;
				var report_paramset_id = '';
				var report_filters = ''
                var enable_rule_setup = true;
            } else {
                var alert_id = task_obj.ud_value2;
                var initial_event = (task_obj.ud_value3 == 'y' ? true : false);
                var manual_step = (task_obj.ud_value4 == 'y' ? true : false);
                var template = p_obj.ud_value5;
				var is_disable = (task_obj.ud_value5 == 'y' ? true : false);
				var report_paramset_id = task_obj.ud_value6;
				var report_filters = task_obj.ud_value7;
                if (alert_id == -1) 
                    enable_rule_setup = true; 
                else 
                    enable_rule_setup = false;
            }

            var parent_event_id = p_obj.ud_value3;
            var parent_module_id = p_obj.ud_value2;
			
            rule_window = new dhtmlXWindows();
            win = rule_window.createWindow('w1', 0, 0, 800, 250);
            win.setText("Rule");
            win.centerOnScreen();
            win.setModal(true);
            var form_json = [{
                                type: 'block',
                                blockOffset: ui_settings['block_offset'],
                                list: [
                                {
                                    'type': 'checkbox',
                                    'name': 'enable_rule_setup',
                                    'label': 'Use Default Rule',
                                    'position': 'label-right',
                                    'labelWidth': 'auto',
                                    'offsetTop':ui_settings['checkbox_offset_top'],
									'offsetLeft':ui_settings['offset_left'],
                                    'tooltip': 'Initial Event',
                                    'checked':enable_rule_setup
                                },{"type":"fieldset",name:"rule_definition_group","label":"Rule Definition","offsetLeft":"15","offsetTop":"5","inputLeft ":"500","inputTop":"500","width":"630","list": [
                                    {
                                        'type': 'combo',
                                        'name': 'alert_id',
                                        'label': 'Rule',
                                        'position': 'label-top',
                                        'validate': 'NotEmpty',
                                        'inputWidth': ui_settings['field_size'],
                                        'labelWidth': 'auto',
                                        'offsetLeft':ui_settings['offset_left'],
                                        'required': true,
                                        'filtering': true,
                                        'filtering_mode': 'between',
                                        'userdata': {
                                            'validation_message': 'Required Field'
                                        },
                                        'tooltip': 'Rule',
                                        'options': '',
                                    },{type: 'newcolumn', offset: 1},{
                                        'type': 'combo',
                                        'name': 'report_paramset_id',
                                        'label': 'EOD Parameter',
                                        'position': 'label-top',
                                        'inputWidth': ui_settings['field_size'],
                                        'labelWidth': 'auto',
                                        'offsetLeft':ui_settings['offset_left'],
                                        'required': false,
                                        'filtering': true,
                                        'filtering_mode': 'between',
                                        'tooltip': 'EOD Parameter',
                                        'options': '',
                                    },{type: 'newcolumn', offset: 1},{
                                        'type': 'combo',
                                        'name': 'report_filters',
                                        'label': 'EOD Filters',
                                        'position': 'label-top',
                                        'inputWidth': ui_settings['field_size'],
                                        'labelWidth': 'auto',
                                        'offsetLeft':ui_settings['offset_left'],
                                        'required': false,
                                        'filtering': true,
                                        'filtering_mode': 'between',
                                        'tooltip': 'EOD Filters',
                                        'options': '',
                                    },{type: 'newcolumn', offset: 1},{
                                        'type': 'checkbox',
                                        'name': 'manual_step',
                                        'label': 'Allow Execution From Status Page',
                                        'position': 'label-right',
                                        'labelWidth': 'auto',
                                        'offsetTop':ui_settings['checkbox_offset_top'],
                                        'offsetLeft':ui_settings['offset_left'],
                                        'tooltip': 'Allow Execution From Status Page',
                                        'checked':manual_step
                                    },{type: 'newcolumn', offset: 1},{
                                        'type': 'checkbox',
                                        'name': 'is_disable',
                                        'label': 'Disable',
                                        'position': 'label-right',
                                        'labelWidth': 'auto',
                                        'offsetTop':ui_settings['checkbox_offset_top'],
                                        'offsetLeft':ui_settings['offset_left'],
                                        'tooltip': 'Disabled',
                                        'checked':is_disable
                                    }
                                ]}
                                ]
                            }];
            var toolbar_json = [{id:"save", type:"button", img:"save.gif", imgdis:"save_dis.gif", text:"Save", title:"Save", enabled:has_rights_save},
                               {id:"add", type:"button", img:"add.gif", imgdis:"add_dis.gif", text:"New Rule", title:"New Rule", enabled:has_rights_save},
                               {id:"view", type:"button", img:"view_active.gif", imgdis:"view_active_dis.gif", text:"View Rule", title:"View Rule"}];
            var toolbar_obj = win.attachToolbar();
            toolbar_obj.setIconsPath(js_image_path + '/dhxtoolbar_web/');
            toolbar_obj.loadStruct(toolbar_json);
            
            if (template == 't') {
                toolbar_obj.disableItem('save');
                toolbar_obj.disableItem('add');
            }
            
            toolbar_obj.attachEvent("onClick", function(id){
                if (task_obj == '') {
                    var event_trigger_id = '';
                } else {
                    var event_trigger_id = task_obj.ud_value1;
                }
                var parent_task_obj = gantt.getTask(parent_id);
                var modules_event_id = parent_task_obj.ud_value1;
                
                if (id == 'save') {
                    var status = validate_form(form_obj);
                    if (status) {
                        var alert_id = form_obj.getItemValue("alert_id");
                        var initial_event = 'n';
                        var manual_step = (form_obj.isItemChecked('manual_step')) ? 'y' : 'n';
						var is_disable = (form_obj.isItemChecked('is_disable')) ? 'y' : 'n';
						var report_paramset_id = form_obj.getItemValue("report_paramset_id");
						var report_filters = form_obj.getItemValue("report_filters");
						gantt_task_rule_save(modules_event_id, alert_id,event_trigger_id, parent_id, initial_event, manual_step, is_disable, report_paramset_id, report_filters, rule_from);
                    } else {
                        generate_error_message();
                        return;
                    }
                } else if (id == 'add') {
                    open_rule_window(modules_event_id,event_trigger_id,parent_id,'',parent_module_id, rule_from);
                } else if (id == 'view') {
                    var status = validate_form(form_obj);
                    if (!status) {
                        generate_error_message();
                    };
                    if (status) {
                        var alert_id = form_obj.getItemValue("alert_id");
                        var data = {
                            "action": "('SELECT alert_category FROM alert_sql WHERE alert_sql_id = " + alert_id + "')"
                        }

                        data = $.param(data)

                        $.ajax({
                            type: "POST",
                            dataType: "json",
                            url: js_form_process_url,
                            async: false,
                            data: data,
                            success: function(data) {
                                response_data = data["json"];
                                if (response_data[0].alert_category == 's') {
                                    open_rule_window(modules_event_id,event_trigger_id,parent_id,alert_id,parent_module_id,'');
                                } else {
                                    show_messagebox('Please use Setup Advance Workflow Rule to view this rule.');
                               }
                            }
                        });
                        
                    }
                }
            });
            
            use_default_rule_on_change = function() {

                var enable_rule_setup = form_obj.isItemChecked('enable_rule_setup');
                
                if (enable_rule_setup == true) {
                    form_obj.setItemValue('alert_id', -1);
                    form_obj.disableItem('rule_definition_group');
                    toolbar_obj.disableItem('view');
                    toolbar_obj.disableItem('add');
                } else {
                    form_obj.enableItem('rule_definition_group');
                    toolbar_obj.enableItem('view');
                    toolbar_obj.enableItem('add');
                }
            }
            
            var form_obj = win.attachForm();
            form_obj.load(get_form_json_locale(form_json), function() {
                 var cm_param = {
                            "action": "('SELECT	alert_sql_id,alert_sql_name FROM alert_sql WHERE rule_category = " + parent_module_id + " OR rule_category = -1 ORDER BY alert_sql_name')", 
                            "call_from": "form",
                            "has_blank_option": false
                        };

                cm_param = $.param(cm_param);
                var url = js_dropdown_connector_url + '&' + cm_param;
                var combo_obj = form_obj.getCombo('alert_id');
                combo_obj.load(url, function() {
                    form_obj.setItemValue('alert_id', alert_id);
                });
				
				var cm_param = {
                            "action": "('SELECT rp.paramset_hash, r.name + '' - '' + rp.name FROM report_paramset rp INNER JOIN report_page rpg on rpg.report_page_id = rp.page_id INNER join report r on r.report_hash = rpg.report_hash')", 
                            "call_from": "form",
                            "has_blank_option": true
                        };

                cm_param = $.param(cm_param);
                var url = js_dropdown_connector_url + '&' + cm_param;
                var combo_obj = form_obj.getCombo('report_paramset_id');
                combo_obj.load(url, function() {
                    form_obj.setItemValue('report_paramset_id', report_paramset_id);
					report_on_change(report_filters);
                });
                
                if (parent_event_id == 20548) {
                    form_obj.checkItem('manual_step');
                    form_obj.hideItem('manual_step');
                }
				
				if (parent_module_id != 20619) {
					form_obj.hideItem('report_paramset_id');
					form_obj.hideItem('report_filters');
				}
				
				if (report_paramset_id != '') {
					form_obj.setItemLabel('report_filters', '<a href="#" onClick="open_report_parameter()">EOD Filters</a>');
				}
                
                use_default_rule_on_change();
            });
			
			form_obj.attachEvent("onChange", function (name, value){
				 if (name == 'report_paramset_id') {
					 report_on_change('');
				 } else if (name == 'enable_rule_setup') {
                     use_default_rule_on_change();
                 }
			});
			
			open_report_parameter = function() {
				var report_paramset_hash = form_obj.getItemValue("report_paramset_id");
                var report_filter_id = form_obj.getItemValue("report_filters");  
				var parameter_window = new dhtmlXWindows();
				
				p_win = parameter_window.createWindow('w1', 0, 0, 890, 650);
				p_win.setText("Parameters");
				p_win.centerOnScreen();
				p_win.setModal(true);
				p_win.attachURL("workflow.eod.parameter.php?report_paramset_hash=" + report_paramset_hash+ '&report_filter_id='+report_filter_id);
				
				p_win.attachEvent("onClose", function(win){
					report_on_change(report_filter_id);
					return true;
				});
				
			}
			
			report_on_change = function(report_filter_val) {
				var report_paramset_hash = form_obj.getItemValue("report_paramset_id");
                var data = {action : "spa_workflow_schedule", flag : "t", paramset_hash:report_paramset_hash}	 
                var callback_fn = (function (result) {report_on_change_with_paramset_id(report_filter_val, result); });
                adiha_post_data('return_array', data, '', '', callback_fn);       
            }

            report_on_change_with_paramset_id = function(report_filter_val,result) {            
                var report_paramset_id = result[0][0]; 
                var cm_param = {
                                "action": "('SELECT application_ui_filter_id, application_ui_filter_name FROM application_ui_filter WHERE report_id = " + report_paramset_id + "')", 
                                "call_from": "form",
                                "has_blank_option": true
                            };

                cm_param = $.param(cm_param);
                var url = js_dropdown_connector_url + '&' + cm_param;
                var combo_obj = form_obj.getCombo('report_filters');
                combo_obj.load(url, function() { 
                    if (report_filter_val != '')
                        form_obj.setItemValue('report_filters', report_filter_val);
                });
            }
		} 
        

        open_rule_window = function(modules_event_id,event_trigger_id,parent_id,alert_id,parent_module_id,rule_from) {
            var new_rule_window = new dhtmlXWindows();
            win = new_rule_window.createWindow('w1', 0, 0, 900, 830);
            win.setText("Rule");
            win.centerOnScreen();
            win.setModal(true);
            win.attachURL("workflow.rule.php?call_from=workflow&module_event_id=" + modules_event_id + '&event_trigger_id=' + event_trigger_id + '&parent_id=' + parent_id + '&alert_id=' + alert_id + '&parent_module_id=' + parent_module_id + '&rule_from=' + rule_from );

            new_rule_window.attachEvent("onClose", function(win){
                set_super_parent_id(parent_id, 0);
                load_gantt_data();
                return true;
            });
            
            if (alert_id == '')
                rule_window.window('w1').close();
        }
        
        gantt_task_rule_save = function(modules_event_id, alert_id,event_trigger_id, parent_id, initial_event, manual_step, is_disable, report_paramset_id, report_filters,rule_from) {
            var xml = '<Root>'
            xml = xml + '<FormXML modules_event_id="'+modules_event_id+'" alert_id="'+alert_id+'" event_trigger_id="'+event_trigger_id+'" initial_event="n" manual_step="' + manual_step + '" is_disable="' + is_disable + '" report_paramset_id="' + report_paramset_id + '" report_filters="' + report_filters + '"></FormXML>'
            xml = xml + '<TaskXML start_date="2015-01-02" duration="2" workflow_id_type="2" parent_id="' + parent_id + '"></TaskXML>'
            xml = xml + '</Root>';

            data = {
                    "action": "spa_workflow_schedule", 
                    "flag": 'r',
                    "xml": xml
                }
            set_super_parent_id(parent_id, 0)
            result = adiha_post_data("alert", data, "", "", "gantt_task_save_callback");
            
        }
        /*============= RULE WINDOW FUNCTION END ==================*/
        
        
        
        /*============= ACTION WINDOW FUNCTION START ==================*/
        gantt_task_action_window = function(task_obj, parent_id, event_trigger_id) {

            var parent_event_id = '';
            var parent_module_id = '';
            if (parent_id == '') {
                var message_id = '';
            } else {
                var parent_task_obj = gantt.getTask(parent_id);
                var message_id = parent_task_obj.ud_value1;
            }
            
            if (task_obj == '') {
                var approve_rule = '';
                var unapprove_rule = '';
                var complete_rule = '';
                var exception_rule = '';
                var threshold_days = '';
                var template = 'w';
                var success_rule = '';
                var failure_rule = '';
            } else {
                var approve_rule = task_obj.ud_value1;
                var unapprove_rule = task_obj.ud_value2;
                var complete_rule = task_obj.ud_value3;
                var exception_rule = task_obj.ud_value4;
                var threshold_days = task_obj.ud_value5;
                var template = check_if_template(parent_id, 3);
                var success_rule = task_obj.ud_value6;
                var failure_rule = task_obj.ud_value7;

            }
            
            action_window = new dhtmlXWindows();
            action_win = action_window.createWindow('w1', 0, 0, 600, 340);
            action_win.setText("Action");
            action_win.centerOnScreen();
            action_win.setModal(true);
            var form_json = [{
                                type: 'block',
                                blockOffset: ui_settings['block_offset'],
                                list: [{
                                    'type': 'combo',
                                    'name': 'approve_rule',
                                    'label': 'On Approval',
                                    'position': 'label-top',
                                    'inputWidth': ui_settings['field_size'],
                                    'labelWidth': 'auto',
                                    'filtering': true,
                                    'filtering_mode': 'between',
                                    'tooltip': 'On Approval',
                                    'offsetLeft':ui_settings['offset_left'],
                                    'options': '',
                                },{'type': 'newcolumn'},{
                                    'type': 'combo',
                                    'name': 'unapprove_rule',
                                    'label': 'On Unapproval',
                                    'position': 'label-top',
                                    'inputWidth': ui_settings['field_size'],
                                    'labelWidth': 'auto',
                                    'filtering': true,
                                    'filtering_mode': 'between',
                                    'tooltip': 'On Unapproval',
                                    'offsetLeft':ui_settings['offset_left'],
                                    'options': '',                            
                                },{'type': 'newcolumn'},{
                                    'type': 'combo',
                                    'name': 'complete_rule',
                                    'label': 'On Complete',
                                    'position': 'label-top',
                                    'inputWidth': ui_settings['field_size'],
                                    'labelWidth': 'auto',
                                    'filtering': true,
                                    'filtering_mode': 'between',
                                    'tooltip': 'On Complete',
                                    'offsetLeft':ui_settings['offset_left'],
                                    'options': '',
                                },{"type":"fieldset",name:"exception_group","label":"In Case of Exception","offsetLeft":"15","offsetTop":"5","inputLeft ":"500","inputTop":"500","width":"530","list": [
                                    {
                                        'type': 'input',
                                        'name': 'threshold_days',
                                        'label': 'Beyond Threshold Days',
                                        'position': 'label-top',
                                        'validate': 'ValidNumeric',
                                        'userdata': {
                                            'validation_message': 'Invalid Number'
                                        },
                                        'inputWidth': ui_settings['field_size'],
                                        'labelWidth': 'auto',
                                        'tooltip': 'Beyond Threshold Days',
                                        'offsetLeft':ui_settings['offset_left'],
                                        'value':threshold_days                               
                                    },{'type': 'newcolumn'},{'type': 'combo',
                                        'name': 'exception_rule',
                                        'label': 'On Exception',
                                        'position': 'label-top',
                                        'inputWidth': ui_settings['field_size'],
                                        'labelWidth': 'auto',
                                        'filtering': true,
                                        'filtering_mode': 'between',
                                        'tooltip': 'In Case of Exception',
                                        'offsetLeft':ui_settings['offset_left'],
                                        'options': '',
                                    }
                                ]},{'type': 'newcolumn'},{'type': 'combo',
                                    'name': 'success_rule',
                                    'label': 'On Success Action',
                                    'position': 'label-top',
                                    'inputWidth': ui_settings['field_size'],
                                    'labelWidth': 'auto',
                                    'filtering': true,
                                    'filtering_mode': 'between',
                                    'tooltip': 'On Success Action',
                                    'offsetLeft':ui_settings['offset_left'],
                                    'options': '',
                                },{'type': 'newcolumn'},{
                                    'type': 'combo',
                                    'name': 'failure_rule',
                                    'label': 'On Failure Action',
                                    'position': 'label-top',
                                    'inputWidth': ui_settings['field_size'],
                                    'labelWidth': 'auto',
                                    'filtering': true,
                                    'filtering_mode': 'between',
                                    'tooltip': 'On Failure Action',
                                    'offsetLeft':ui_settings['offset_left'],
                                    'options': '',
                                }]
                            }];
            var toolbar_json = [{id:"save", type:"button", img:"save.gif", imgdis:"save_dis.gif", text:"Save", title:"Save", enabled:has_rights_save},
                                {id:"add_rule", type:"button", img:"add.gif", imgdis:"add_dis.gif", text:"Add Rule", title:"Add Rule", enabled:has_rights_save}
            ];
            var toolbar_obj = action_win.attachToolbar();
            toolbar_obj.setIconsPath(js_image_path + '/dhxtoolbar_web/');
            toolbar_obj.loadStruct(toolbar_json);
            
            if (template == 't') {
                toolbar_obj.disableItem('save');
            }
            
            toolbar_obj.attachEvent("onClick", function(id){
                if (id == 'save') {
                    gantt_task_action_save(form_obj, task_obj, parent_id, event_trigger_id);
                } else if (id == 'add_rule') {
                    gantt_task_rule_window(task_obj, parent_id,'next_action');
                }
            });

            var form_obj = action_win.attachForm();
            form_obj.load(get_form_json_locale(form_json), function() {
                form_obj.setUserData('approve_rule','message_id',message_id);
                form_obj.setUserData('approve_rule','event_trigger_id',event_trigger_id);
                var cm_param = {
                            "action": "spa_setup_rule_workflow",
                            "flag": "n",
                            "message_id": message_id,
                            "alert_rule_id":event_trigger_id,
                            "call_from": "form"
                        };

                cm_param = $.param(cm_param);
                var url = js_dropdown_connector_url + '&' + cm_param;
                var approve_combo_obj = form_obj.getCombo('approve_rule');
                var unapprove_combo_obj = form_obj.getCombo('unapprove_rule');
                var complete_combo_obj = form_obj.getCombo('complete_rule');
                var exception_combo_obj = form_obj.getCombo('exception_rule');
                var success_combo_obj = form_obj.getCombo('success_rule');
                var failure_combo_obj = form_obj.getCombo('failure_rule');
                approve_combo_obj.load(url, function() {
                    form_obj.setItemValue('approve_rule', approve_rule);
                });
                unapprove_combo_obj.load(url, function() {
                    form_obj.setItemValue('unapprove_rule', unapprove_rule);
                });
                complete_combo_obj.load(url, function() {
                    form_obj.setItemValue('complete_rule', complete_rule);
                });
                exception_combo_obj.load(url, function() {
                    form_obj.setItemValue('exception_rule', exception_rule);
                });
                success_combo_obj.load(url, function() {
                    form_obj.setItemValue('success_rule', success_rule);
                });
                failure_combo_obj.load(url, function() {
                    form_obj.setItemValue('failure_rule', failure_rule);
                });
            });

            if (parent_id == '') {
                var is_automatic_proceed = '';
            } else {
                var parent_task = gantt.getTask(parent_id);
                var is_automatic_proceed = parent_task.ud_value2;
            }

            if (parent_id == '' || is_automatic_proceed == 'y' || is_automatic_proceed == 'h') {
                form_obj.hideItem('approve_rule');
                form_obj.hideItem('unapprove_rule');
                form_obj.hideItem('complete_rule');
                form_obj.hideItem('exception_rule');
                form_obj.hideItem('threshold_days');
                form_obj.hideItem('exception_group');
                form_obj.showItem('success_rule');
                form_obj.showItem('failure_rule');
            } else {
                form_obj.showItem('approve_rule');
                form_obj.showItem('unapprove_rule');
                form_obj.showItem('complete_rule');
                form_obj.showItem('exception_rule');
                form_obj.showItem('threshold_days');
                form_obj.showItem('exception_group');
                form_obj.hideItem('success_rule');
                form_obj.hideItem('failure_rule');
            }
        }

        gantt_task_action_save = function(form_obj, task_obj, parent_id, event_trigger_id) {

            var status = validate_form(form_obj);
            if (!status) {
                generate_error_message();
                return;
            }

            var n_parent_id = parent_id;
            if (parent_id == '') {
                var message_id = '';
            } else {
                var parent_task_obj = gantt.getTask(parent_id);
                var is_automatic_proceed = parent_task_obj.ud_value2;
                if (is_automatic_proceed == 'h') {
                    var trigger_obj = gantt.getTask(gantt.getParent(parent_id));
                    event_trigger_id = trigger_obj.ud_value1;
                    n_parent_id = '';
                }
                var message_id = parent_task_obj.ud_value1;
            }

            var approve_rule = form_obj.getItemValue("approve_rule");
            var unapprove_rule = form_obj.getItemValue("unapprove_rule");
            var complete_rule = form_obj.getItemValue("complete_rule");
            var exception_rule = form_obj.getItemValue("exception_rule");
            var threshold_days = form_obj.getItemValue("threshold_days");
            var success_rule = form_obj.getItemValue("success_rule");
            var failure_rule = form_obj.getItemValue("failure_rule");

            var xml = '<Root>'
            if (approve_rule != '')
                xml = xml + '<FormXML status_id="729" alert_id="' + approve_rule + '" event_message_id="'+message_id+'" threshold_days=""></FormXML>'
            if (unapprove_rule != '')
                xml = xml + '<FormXML status_id="726" alert_id="' + unapprove_rule + '" event_message_id="'+message_id+'" threshold_days=""></FormXML>'
            if (complete_rule != '')
                xml = xml + '<FormXML status_id="728" alert_id="' + complete_rule + '" event_message_id="'+message_id+'" threshold_days=""></FormXML>'
            if (exception_rule != '')
                xml = xml + '<FormXML status_id="733" alert_id="' + exception_rule + '" event_message_id="'+message_id+'" threshold_days="' + threshold_days + '"></FormXML>'
            if (success_rule !='')
                xml = xml + '<FormXML status_id="735" alert_id="' + success_rule + '" event_message_id="'+message_id+'" threshold_days=""></FormXML>'
            if (failure_rule !='')
                xml = xml + '<FormXML status_id="736" alert_id="' + failure_rule + '" event_message_id="'+message_id+'" threshold_days=""></FormXML>'

            xml = xml + '<TaskXML start_date="2015-01-08" duration="2" workflow_id_type="4" parent_id="' + n_parent_id + '" message_id="' + message_id + '"></TaskXML>'
            xml = xml + '</Root>';

            data = {
                    "action": "spa_workflow_schedule",
                    "flag": 'a',
                    "trigger_id": event_trigger_id,
                    "xml": xml
                }
            set_super_parent_id(parent_id, 2);
            result = adiha_post_data("alert", data, "", "", "action_gantt_task_save_callback");

        }

        /*============= ACTION WINDOW FUNCTION END ==================*/





        /*====================== CONTEXT MENU FUNCTION START ===========*/
        load_gantt_context_menu = function() {
            var link_id = ''
            var task_id = ''
            var context_menu = new dhtmlXMenuObject();
            context_menu.renderAsContextMenu();
            context_menu.loadFromHTML("context_menu", false);

            var automatic_proceed_menu = new dhtmlXMenuObject();
            automatic_proceed_menu.renderAsContextMenu();
            automatic_proceed_menu.loadFromHTML("automatic_proceed_menu", false);

            gantt.attachEvent("onContextMenu", function(taskId, linkId, event){
                link_id = linkId;
                task_id = taskId;
                var x = event.clientX + document.body.scrollLeft + document.documentElement.scrollLeft,
                    y = event.clientY + document.body.scrollTop + document.documentElement.scrollTop;

                if(linkId){
                    var link_obj = gantt.getLink(linkId);
                    var link_source = link_obj.source;
                    var link_task_level = gantt.calculateTaskLevel(link_source);

                    var template = check_if_template(link_source,link_task_level);
                    if(template == 't') return false;

                    if (link_task_level == 4) {
                        var source_parent_obj = gantt.getTask(gantt.getParent(link_source));
                        var is_automatic_proceed = source_parent_obj.ud_value2;

                        if (is_automatic_proceed == 'y'  || is_automatic_proceed == 'h') {
                            context_menu.hideItem('approve');
                            context_menu.hideItem('unapprove');
                            context_menu.hideItem('complete');
                            context_menu.hideItem('exception');
                            context_menu.showItem('success');
                            context_menu.showItem('failure');
                        } else {
                            context_menu.showItem('approve');
                            context_menu.showItem('unapprove');
                            context_menu.showItem('complete');
                            context_menu.showItem('exception');
                            context_menu.hideItem('success');
                            context_menu.hideItem('failure');
                        }

                        context_menu.showContextMenu(x, y);
                        return false;
                    }
                }

                if(taskId) {
                    var task_level = gantt.calculateTaskLevel(taskId);
                    if (task_level == 2) {
                        automatic_proceed_menu.showContextMenu(x, y);
                        return false;
                    }
                }

                return true;
            });

            context_menu.attachEvent("onClick", function(id, zoneId, cas){
                context_menu_click(id, link_id);
            });

            automatic_proceed_menu.attachEvent("onClick", function(id, zoneId, cas){
                automatic_proceed_menu_click(id, task_id);
            });
        }

        context_menu_click = function(context_id, link_id) {
            var action_type = '';
            if (context_id == 'approve') {
                action_type = 729;
            } else if (context_id == 'unapprove') {
                action_type = 726;
            } else if (context_id == 'complete') {
                action_type = 728;
            } else if (context_id == 'exception') {
                action_type = 733;
            } else if (context_id == 'success') {
                action_type = 735;
            } else if (context_id == 'failure') {
                action_type = 736;
            }

            data = {
                    "action": "spa_workflow_schedule",
                    "flag": 'c',
                    "action_type": action_type,
                    "link_id": link_id
                }
            var link_obj = gantt.getLink(link_id);
            var source = link_obj.source;
            set_super_parent_id(source, 3);
            result = adiha_post_data("alert", data, "", "", "load_gantt_data");
        }

        automatic_proceed_menu_click = function(context_id, task_id) {
            var task_obj = gantt.getTask(task_id);
            var event_trigger_id = task_obj.ud_value1;
            gantt_task_action_window('', '', event_trigger_id);
        }

        /*====================== CONTEXT MENU FUNCTION END ===========*/


        set_super_parent_id = function(id, level) {
            if (id == '') {
                super_parent_id = '';
            } else {
                if (level == 0) {
                    super_parent_id = id;
                } else if (level == 1) {
                    super_parent_id = gantt.getParent(id);
                } else if (level == 2) {
                    var tmp_parent_id = gantt.getParent(id);
                    super_parent_id = gantt.getParent(tmp_parent_id);
                } else if (level == 3) {
                    var tmp_parent_id = gantt.getParent(id);
                    var ntemp_parent_id = gantt.getParent(tmp_parent_id);
                    super_parent_id = gantt.getParent(ntemp_parent_id);
                }
            }
        }

        check_if_template = function(task_id, level) {
            var template = 'w';
            if (level == 1) {
                var task = gantt.getTask(task_id);
                template = task.ud_value5;
            } else if (level == 2) {
                var pr1 = gantt.getParent(task_id);
                var task = gantt.getTask(pr1);
                template = task.ud_value5;
            } else if (level == 3) {
                var pr1 = gantt.getParent(task_id);
                var pr2 = gantt.getParent(pr1);
                var task = gantt.getTask(pr2);
                template = task.ud_value5;
            } else if (level == 4) {
                var pr1 = gantt.getParent(task_id);
                var pr2 = gantt.getParent(pr1);
                var pr3 = gantt.getParent(pr2);
                var task = gantt.getTask(pr3);
                template = task.ud_value5;
            }
            return template;
        }

        update_squence_number = function(parent_id) {
            var xml = '<Root>';
            var children = gantt.getChildren(parent_id);

            for (cnt = 0; cnt < children.length; cnt++) {
                var sort_ord = cnt + 1;
                xml += '<Task task_id ="' + children[cnt] + '" sort_order="' + sort_ord + '" />';
            }
            xml += '</Root>'

            data = {
                    "action": "spa_workflow_schedule",
                    "flag": 'e',
                    "xml": xml
                }
            result = adiha_post_data("alert", data, "", "", "");
        }

        refresh_action_ui_fields = function() {
            /* Only refresh the fields if rule has been added from action window.*/
            if (!action_window.window('w1'))
                return;
            var form_obj = action_window.window('w1').getAttachedObject();
            var message_id = form_obj.getUserData('approve_rule','message_id');
            var event_trigger_id = form_obj.getUserData('approve_rule','event_trigger_id');
            var cm_param = {
                "action": "spa_setup_rule_workflow",
                "flag": "n",
                "message_id": message_id,
                "alert_rule_id":event_trigger_id,
                "call_from": "form"
            };
            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;
            var approve_combo_obj = form_obj.getCombo('approve_rule');
            var approve_rule = form_obj.getItemValue('approve_rule');
            var unapprove_combo_obj = form_obj.getCombo('unapprove_rule');
            var unapprove_rule = form_obj.getItemValue('unapprove_rule');
            var complete_combo_obj = form_obj.getCombo('complete_rule');
            var complete_rule = form_obj.getItemValue('complete_rule');
            var exception_combo_obj = form_obj.getCombo('exception_rule');
            var exception_rule = form_obj.getItemValue('exception_rule');
            var success_combo_obj = form_obj.getCombo('success_rule');
            var success_rule = form_obj.getItemValue('success_rule');
            var failure_combo_obj = form_obj.getCombo('failure_rule');
            var failure_rule = form_obj.getItemValue('failure_rule');
            approve_combo_obj.load(url, function() {
                form_obj.setItemValue('approve_rule', approve_rule);
            });
            unapprove_combo_obj.load(url, function() {
                form_obj.setItemValue('unapprove_rule', unapprove_rule);
            });
            complete_combo_obj.load(url, function() {
                form_obj.setItemValue('complete_rule', complete_rule);
            });
            exception_combo_obj.load(url, function() {
                form_obj.setItemValue('exception_rule', exception_rule);
            });
            success_combo_obj.load(url, function() {
                form_obj.setItemValue('success_rule', success_rule);
            });
            failure_combo_obj.load(url, function() {
                form_obj.setItemValue('failure_rule', failure_rule);
            });
        }

        function import_from_file(file_name, copy_as) {  
            data = {"action": "spa_workflow_import_export",
                    "flag": "confirm_override",
                    "import_file": file_name,
                    "import_as" : copy_as
                };
            adiha_post_data('return_array', data, '', '', 'import_after_confirmation', '', '');            
        }

        function import_after_confirmation(return_value) {
            workflow_gantt.new_win.close();

            var confirm_type = return_value[0][0];            
            var adiha_type = '';
            var validation = '';
            var file_name = return_value[0][1];
            var copy_as = return_value[0][2];

            if (confirm_type == 'r') {
                validation = 'Data already exist. Are you sure you want to replace data? ';
                adiha_type = 'confirm';
            } else {
                adiha_type = 'return_array';
            }

            data = {"action": "spa_workflow_import_export",
                "flag": "import_workflow",
                "import_file": file_name,
                "import_as" : copy_as
            };

            setTimeout(function() { /*Loading icon was not loaded without adding some delay*/
                adiha_post_data(adiha_type, data, '', '', 'workflow_gantt.import_export_call_back', '', validation);
            }, 10);
        }

        workflow_gantt.import_export_call_back = function(result) {
            workflow_gantt.layout.progressOn();
            var is_success = result[0][0];
            var error_code;
            var message;
            var show_msg;

            if (is_success === undefined) {
                error_code = result[0].errorcode;
                message = result[0].message
            } else {
                error_code = result[0][0];
                message = result[0][4];
                show_msg = 1;
            }

            if (error_code == "Success") {                
                if (show_msg == 1) {
                    success_call(result[0][4]);
                }
                workflow_gantt.layout.progressOff();
            } else {
                show_messagebox(message);
                workflow_gantt.layout.progressOff();
            }

            var workflow_group_id = workflow_gantt.workflow_form.getItemValue('workflow_group');
            var workflow_type = workflow_gantt.workflow_form.getItemValue('system_defined');
            reload_workflow_group(workflow_group_id, 0, workflow_type);
        }

        workflow_gantt.download_script = function(result) {
            var selected_id = gantt.getSelectedId();
            var task_obj = gantt.getTask(selected_id);
            var workflow_name = task_obj.text;
            var ua = window.navigator.userAgent;
            var msie = ua.indexOf("MSIE ");
            var blob = null;
            if (msie > 0|| !!navigator.userAgent.match(/Trident.*rv\:11\./)) { // Code to download file for IE
                if ( window.navigator.msSaveOrOpenBlob && window.Blob ) {
                    blob = new Blob( [result[0][0]], { type: "text/csv;charset=utf-8;" } );
                    navigator.msSaveOrOpenBlob( blob, workflow_name+ "_import.txt" );
                }
            }
            else { // Code to download file for other browser
                blob = new Blob([result[0][0]],{type: "text/csv;charset=utf-8;"});
                var link = document.createElement("a");
                if (link.download !== undefined) {
                    var url = URL.createObjectURL(blob);
                    link.setAttribute("href", url);
                    link.setAttribute("download", workflow_name+ "_import.txt");
                    link.style = "visibility:hidden";
                    document.body.appendChild(link);
                    link.click();
                    document.body.removeChild(link);
                }
            }
        }

        workflow_gantt.workflow_copy = function(result) {
            data = {"action": "spa_workflow_import_export",
                "flag": "import_workflow",
                "import_string": result[0][0]
            };
            adiha_post_data('return_array', data, '', '','workflow_gantt.import_export_call_back', '', '');
        }

	</script>
</body>