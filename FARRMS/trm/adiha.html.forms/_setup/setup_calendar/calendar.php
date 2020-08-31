<?php
/**
* Calendar screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
        <script src="../../../adiha.php.scripts/components/lib/adiha_dhtmlx/adiha_scheduler_3.0/dhtmlxscheduler.js" type="text/javascript"></script>
        <script src="api.js"></script>
        <link rel="stylesheet" href="../../../adiha.php.scripts/components/lib/adiha_dhtmlx/adiha_scheduler_3.0/dhtmlxscheduler.css" type="text/css" />
        <script src="../../../adiha.php.scripts/components/lib/adiha_dhtmlx/adiha_scheduler_3.0/ext/dhtmlxscheduler_editors.js" type="text/javascript" charset="utf-8"></script>
        <script src="../../../adiha.php.scripts/components/lib/adiha_dhtmlx/adiha_scheduler_3.0/ext/dhtmlxscheduler_serialize.js" type="text/javascript" charset="utf-8"></script>        
        <script src="../../../adiha.php.scripts/components/lib/adiha_dhtmlx/adiha_scheduler_3.0/common/dhtmlxCombo/dhtmlxcombo.js" type="text/javascript" charset="utf-8"></script>
        <script src="../../../adiha.php.scripts/components/lib/adiha_dhtmlx/adiha_scheduler_3.0/ext/dhtmlxscheduler_pdf.js" type="text/javascript" charset="utf-8"></script>
        <script src="../../../adiha.php.scripts/components/lib/adiha_dhtmlx/adiha_scheduler_3.0/ext/dhtmlxscheduler_year_view.js" type="text/javascript" charset="utf-8"></script>
        <script src="../../../adiha.php.scripts/components/lib/adiha_dhtmlx/adiha_scheduler_3.0/ext/dhtmlxscheduler_recurring.js" type="text/javascript" charset="utf-8"></script>
        <script src="../../../adiha.php.scripts/components/lib/adiha_dhtmlx/adiha_scheduler_3.0/ext/dhtmlxscheduler_readonly.js" type="text/javascript" charset="utf-8"></script>
        <script src="../../../adiha.php.scripts/components/lib/adiha_dhtmlx/adiha_scheduler_3.0/ext/dhtmlxscheduler_minical.js" type="text/javascript" charset="utf-8"></script>
          
        <?php require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
        
        <style type="text/css">
            html, body {
                width: 100%;
                height: 100%;
                margin: 0px;
                padding: 0px;
                background-color: #ebebeb;
                overflow: hidden;
            }
            
            .dhx_cal_lsection.dhx_cal_checkbox label {
                font-weight: 700;
            }
            
            .dhx_cal_event_line_start{
                border-top-left-radius: 1px;
                border-bottom-left-radius: 1px;
            }
            
            .dhx_cal_event_line_end{
                border-top-right-radius: 1px;
                border-bottom-right-radius: 1px;
            }
            /*multi-day event in month view*/
        	.dhx_cal_event_line.past_event{
        		background-color:purple !important; 
        		color:white !important;
        	}
            /*event with fixed time, in month view*/
        	.dhx_cal_event_clear.past_event{
                background-color:purple !important;
        		color:white !important;
        	}
            /*Normal Default*/
            .dhx_cal_event_line{
        		background-color:#AF7AC5 !important; 
        		color:white !important;
        	}
            .dhx_cal_event_line{
                font-size:8pt;
                height:12px;
                line-height:12px;
                padding-left:2px;
                white-space:nowrap;
                overflow:hidden;
                cursor:pointer;
                margin-left: 4px;
            }
            .dhx_cal_event_clear{
                background-color:#AF7AC5 !important;
        		color:white !important;
                margin-left: 4px;
        	}
            /*Day And Week View*/
            .dhx_cal_event .dhx_body, 
            .dhx_cal_event .dhx_footer, 
            .dhx_cal_event .dhx_header, 
            .dhx_cal_event .dhx_title{
                background-color:#AF7AC5 !important;
        		color:white !important;
        	}
            /*Workflow Event*/
            /*multi-day event in month view*/
        	.dhx_cal_event_line.workflow_event{
        		background-color:#EC7063 !important; 
        		color:white !important;
        	}
            /*event with fixed time, in month view*/
        	.dhx_cal_event_clear.workflow_event{
                background-color:#EC7063 !important;
        		color:white !important;
        	}
            /*Day And Week View*/
            .dhx_cal_event.workflow_event .dhx_body, 
            .dhx_cal_event.workflow_event .dhx_footer, 
            .dhx_cal_event.workflow_event .dhx_header, 
            .dhx_cal_event.workflow_event .dhx_title{
                background-color:#EC7063 !important;
        		color:white !important;
        	}
            /*Completed Event*/
            /*multi-day event in month view*/
        	.dhx_cal_event_line.completed_event{
        		background-color:#2ECC71 !important; 
        		color:white !important;
        	}
            /*event with fixed time, in month view*/
        	.dhx_cal_event_clear.completed_event{
                background-color:#2ECC71 !important;
        		color:white !important;
        	}
            /*Day And Week View*/
            .dhx_cal_event.completed_event .dhx_body, 
            .dhx_cal_event.completed_event .dhx_footer, 
            .dhx_cal_event.completed_event .dhx_header, 
            .dhx_cal_event.completed_event .dhx_title{
                background-color:#2ECC71 !important;
        		color:white !important;
        	}
            /*Read Only Event*/
            /*multi-day event in month view*/
        	.dhx_cal_event_line.readonly_event{
        		background-color:#F4D03F !important; 
        		color:white !important;
        	}
            /*event with fixed time, in month view*/
        	.dhx_cal_event_clear.readonly_event{
                background-color:#F4D03F !important;
        		color:white !important;
        	}
            /*Day And Week View*/
            .dhx_cal_event.readonly_event .dhx_body, 
            .dhx_cal_event.readonly_event .dhx_footer, 
            .dhx_cal_event.readonly_event .dhx_header, 
            .dhx_cal_event.readonly_event .dhx_title{
                background-color:#F4D03F !important;
        		color:white !important;
        	}
            
            /* Legends */
            #calendar_legend {
    			margin-left: 30px;
    			margin-top: 15px;
    			font-size: 12px;
    		}
    		
    		.legent_icon {
    			float: left;
    			height: 12px;
    			width: 25px;
    			border-radius: 3px;
    		}
    		
    		.legend_item {
    			float: left;
    			margin-left:5px;
    			margin-right:15px;
    		}
        </style>
    </head>
    <body>
    <?php
	
	$module_id = get_sanitized_value($_GET['module_id'] ?? '');
    $source_id = get_sanitized_value($_GET['source_id'] ?? '');
	
    $form_namespace = 'namespace';
    $function_id = 10106800;
    $layout_obj = new AdihaLayout();
    $layout_json = '[
                        {id: "a", header:true, height: 95, text: "Apply Filters", collapse: false},
                        {id: "b", header:true, height: 95, text: "Filters Criteria", collapse: false},
                        {id: "c", header:false},
                        {id: "d", collapse: false, header:true, height:70, text: "Legend"}
                    ]';
    echo $layout_obj->init_layout('calendar_layout', '', '4E', $layout_json, $form_namespace);
    
    $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='$function_id', @template_name='Calendar', @group_name='General'";
    $return_value = readXMLURL($xml_file);
    $form_json = $return_value[0][2];
    
    echo $layout_obj->attach_form('apply_filter', 'a');
    echo $layout_obj->attach_form('filter_form', 'b');
    $form_obj = new AdihaForm();
    echo $form_obj->init_by_attach('filter_form', $form_namespace);
    echo $form_obj->load_form($form_json);
    echo $form_obj->load_form_filter($form_namespace, 'apply_filter', 'calendar_layout', 'b', $function_id, 2);
    
    $menu_name = 'calendar_menu';
    $menu_json = '[
            {id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif"},
            {id:"reminder_window", text:"Reminders", img:"reminder.gif", imgdis:"reminder_dis.gif"},
            {id:"t2", text:"Export", img:"export.gif", imgdis:"export_dis.gif", disabled:false, items:[
                {id:"excel", text:"Excel", img:"excel.gif"},
                {id:"pdf", text:"PDF", img:"pdf.gif"},
                {id:"ical", text:"iCal", img:"send_schedule_qty.gif"},
                {id:"calendar_report", text:"Report", img:"report.gif"}
            ]},
            {id:"t3", text:"Options", img:"options.gif", imgdis:"options_dis.gif", items:[
                {id:"share", text:"Share Calendar", img:"share.png", imgdis: "share_dis.png"},
                {id:"new_alert", text:"New Alert", img:"new.gif", imgdis: "new_dis.gif"}
            ]}
            ]';

    echo $layout_obj->attach_menu_layout_cell($menu_name, 'c', $menu_json, 'calendar_menu_click');
    
    echo $layout_obj->attach_html_object('c', "scheduler_here");
    echo $layout_obj->attach_html_object('d', "calendar_legend");
    echo $layout_obj->close_layout();
    ?>
    </body>
    <form action="./php/ical_writer.php" method="post" target="hidden_frame" accept-charset="utf-8">
		<input type="hidden" name="data" value="" id="data">
	</form>
    <div id="calendar_legend">
		<div class="legent_icon" style="background-color:#AF7AC5;"></div><div class="legend_item"><?php echo get_locale_value('Outstanding Event'); ?></div>
		<div class="legent_icon" style="background-color:#EC7063;"></div><div class="legend_item"><?php echo get_locale_value('Outstanding Workflow'); ?></div>
        <div class="legent_icon" style="background-color:#2ECC71;"></div><div class="legend_item"><?php echo get_locale_value('Completed'); ?></div>
		<div class="legent_icon" style="background-color:#F4D03F;"></div><div class="legend_item"><?php echo get_locale_value('Shared'); ?></div>
	</div>
    <div id="scheduler_here" class="dhx_cal_container" style='width:100%; height:100%'>
		<div class="dhx_cal_navline">
            <!--<div class="dhx_cal_export refresh" id='' title="Refresh" onclick='javascript:update_calendar_view();'>&nbsp;</div>
            <div class="dhx_cal_export reminder" id='' title="Reminder" onclick='javascript:parent.open_reminder_window_from_parent();'>&nbsp;</div>
            <div class='dhx_cal_export pdf' id='export_pdf' title='Export to PDF' onclick='scheduler.toPDF("http://dhtmlxscheduler.appspot.com/export/pdf", "color")'>&nbsp;</div>
            -->
            <div class="dhx_cal_prev_button">&nbsp;</div>
			<div class="dhx_cal_next_button">&nbsp;</div>
			<div class="dhx_cal_today_button"></div>
			<div class="dhx_cal_date"></div>
			<div class="dhx_cal_tab" name="day_tab" style="right:204px;"></div>
			<div class="dhx_cal_tab" name="week_tab" style="right:140px;"></div>
			<div class="dhx_cal_tab" name="month_tab" style="right:76px;"></div>
            <div class="dhx_cal_tab" name="year_tab" style="right:330px;"></div>
		</div>
		<div class="dhx_cal_header">
		</div>
		<div class="dhx_cal_data">
		</div>
	</div>
    <script type="text/javascript" charset="utf-8">
        var mode = 'u';
        var context_menu = new dhtmlXMenuObject();
        var ev_id = '';
        var posx = 0;
		var posy = 0;
        var myPop = new dhtmlXPopup();
        var parent_start_date = new Date();
        var load_count = 0;
		var module_id = '<?php echo $module_id; ?>';
		var source_id = '<?php echo $source_id; ?>';
		
		$(function() {
            combo_obj = namespace.filter_form.getCombo('user_id');
            combo_obj.setChecked(combo_obj.getIndexByValue(js_user_name), true);
            
            load_workflow();
			
			if (module_id != '') {
				namespace.calendar_menu.hideItem('reminder_window');
				namespace.calendar_menu.hideItem('t3');
			}
        });
        
        function load_workflow() {
            var param = {
                "action": 'spa_calendar',
                "flag": 'w'
            };
            adiha_post_data('return_json', param, '', '', 'load_schedular', '');
        }
        
        function load_alerts(result) {
            workflow = result;
            var param = {
                "action": 'spa_calendar',
                "flag": 'a'
            };
            adiha_post_data('return_json', param, '', '', 'load_schedular', '');
        }
        
        function load_schedular(workflow) {
            load_schedular_configurations();
            load_schedular_locales();
            
            var reminder = [
                                {"key":-1,"label":"None"},
                                {"key":0,"label":"0 Minutes"},
                                {"key":5,"label":"5 Minutes"},
                                {"key":10,"label":"10 Minutes"},
                                {"key":15,"label":"15 Minutes"},
                                {"key":30,"label":"30 Minutes"},
                                {"key":60,"label":"1 Hour"},
                                {"key":120,"label":"2 Hours"},
                                {"key":180,"label":"3 Hours"},
                                {"key":240,"label":"4 Hours"},
                                {"key":300,"label":"5 Hours"},
                                {"key":360,"label":"6 Hours"},
                                {"key":420,"label":"7 Hours"},
                                {"key":480,"label":"8 Hours"},
                                {"key":540,"label":"9 Hours"},
                                {"key":600,"label":"10 Hours"},
                                {"key":660,"label":"11 Hours"},
                                {"key":720,"label":"12 Hours"},
                                {"key":1440,"label":"1 Day"}
                            ];
    		
            scheduler.config.lightbox.sections = [	
    			{name:"name", height:27, map_to:"text", type:"textarea" , focus:true},
    			{name:"description", height:70, map_to:"description", type:"textarea"},
    			//{name:"alert", height:21, map_to:"alert", type:"select", options: JSON.parse(alerts)},
                {name:"recurring", type:"recurring", map_to:"rec_type", button:"recurring", form: "my_recurring_form"},
    			{name:"time", height:72, type:"calendar_time", map_to:"time",time_format:["%H:%i","%m","%d","%Y"]},
                {name:"workflow", height:21, map_to:"workflow", type:"select", options: JSON.parse(workflow)},
                { name:"include_holiday", map_to:"include_holiday", type:"checkbox", checked_value: "y", unchecked_value: "n", height:21 },
                {name:"reminder", height:21, type:"select", map_to:"reminder", options: reminder, image_path:js_php_path+"/components/lib/adiha_dhtmlx/adiha_scheduler_3.0/common/dhtmlxCombo/imgs/", filtering: true}	
    		];
            
            override_schedular_templates();
            load_schedular_events();
            
            scheduler.init("scheduler_here",null,"month");
            update_calendar_view();
        }
        
        function calendar_menu_click(id) {
            switch(id){
                case "refresh":
                    update_calendar_view();
                    break;
                case "reminder_window":
                    parent.open_reminder_window_from_parent();
                    break;
                case "excel":
                    scheduler.exportToExcel();
                    break;
                case "pdf":
                    scheduler.toPDF("http://dhtmlxscheduler.appspot.com/export/pdf", "color");
                    //scheduler.exportToPDF({
//                        format:"A4",
//                        orientation:"landscape"
//                    });
                    break;
                case "ical":
                    var form = document.forms[0];
            		form.action = "ical_download.php";
            		form.elements.data.value = scheduler.toICal();
            		form.submit();
                    break;
				 case "calendar_report":
                    open_calendar_report();
                    break;
                case "share":
                    open_share_calendar();
                    break;
                case "new_alert":
                    open_rule_window();
                    break;
                default:
                    break;
            }
        }
        
        function open_share_calendar() {
            if (typeof(dhxWins) === "undefined" || !dhxWins) {
                dhxWins = new dhtmlXWindows();      
            }
            
            var window_name = 'Share Calendar';
            var file_path = '_setup/setup_calendar/share.calendar.php';
            
            dhxWins.createWindow(window_name, 0, 0, 680, 400);
            dhxWins.window(window_name).setText('Share Calendar');
            dhxWins.window(window_name).center();
            dhxWins.window(window_name).progressOn();
            dhxWins.window(window_name).attachURL(app_form_path+file_path, false, true);
            dhxWins.window(window_name).attachEvent("onContentLoaded", function(win){
                dhxWins.window(window_name).progressOff();
            });
            
            dhxWins.window(window_name).button("close").attachEvent("onClick", function(win){
                win.close();
                return true;
            });
        }
        
        function update_calendar_view() {
            data = namespace.filter_form.getFormData();

            for (var name in data) {
            	var item_type = namespace.filter_form.getItemType(name);
            	
            	if (item_type != 'block' && item_type!= 'fieldset'&& item_type!= 'button') {
            		if (name != 'apply_filters') {
            			if (name == 'user_id') {
            				var user_id = data[name];
            			} else if (name == 'role_id') {
            			    var role_id = data[name];
            			} else if (name == 'status') {
                            var status = data[name];
            			}
            		}
            	}
            }
            
            namespace.calendar_layout.cells('a').collapse();
            namespace.calendar_layout.cells('b').collapse();
            scheduler.setCurrentView();
            
            var cm_param = {
                "sql": "EXEC spa_calendar @flag='c', @user_id='" + user_id + "', @role_id='" + role_id + "', @status='" + status + "', @module_id='" + module_id + "', @source_object_id='" + source_id + "'",
                "grid_type": "c"
            };
    
            cm_param = $.param(cm_param);
            var url = js_data_collector_url + '&' + cm_param;
            scheduler.clearAll();
            scheduler.load(url, "xml", function(){
                var all_events = scheduler.getEvents(new Date(new Date().setFullYear(new Date().getFullYear() - 6)), new Date(new Date().setFullYear(new Date().getFullYear() + 4)));
                for (var i = 0; i < all_events.length; i++){
                    if (all_events[i].type == 'readonly' || all_events[i].type == 'completed') {
                        var exist_length = String(all_events[i].id).indexOf("#");
                        
                        if (exist_length == -1) {
                            scheduler.getEvent(all_events[i].id).readonly = true;
                        } else {
                            var id_arrays = all_events[i].id.split("#");
                            scheduler.getEvent(id_arrays[0]).readonly = true;
                        }
                    }
                }
            });
            
            /* Sample Data to load on schedular 
                event_options = [{"id":5,"text":"Events Series","description":"Editing/deleting a certain occurrence in the series",
                "start_date":"01/24/2017 00:00:00","end_date":"01/30/2017 00:00:00","workflow":0,"shared":"n",
                "rec_type":"week_1___1,2,3,4,5#","event_pid":"0","event_length":"300"},
                {"id":6,"text":"Events Series","description":"Editing/deleting a certain occurrence in the series",
                "start_date":"01/26/2017 10:00:00","end_date":"01/26/2017 10:00:00","workflow":0,"shared":"",
                "rec_type":"","event_pid":5,"event_length":"1485368100"}];
            */
            //scheduler.parse(event_options, "json")
        }
        
        function load_schedular_configurations() {
            scheduler.config.max_month_events = 4;
			scheduler.config.include_end_by = true;
			scheduler.config.repeat_precise = true;
            scheduler.config.prevent_cache = true;
            scheduler.config.show_loading = true;
            scheduler.config.first_hour = 0;
            scheduler.config.last_hour = 24;
            scheduler.config.separate_short_events = true;
            scheduler.config.details_on_dblclick = true;
            scheduler.config.details_on_create = true;
            scheduler.config.scroll_hour = new Date().getHours();
            //Change Date to User Date Format
            scheduler.config.repeat_date = user_date_format;
            scheduler.templates.calendar_time = scheduler.date.date_to_str(user_date_format);
            scheduler.config.occurrence_timestamp_in_utc = true;
            scheduler.config.buttons_left = ["dhx_delete_btn"];
            scheduler.config.buttons_right = ["dhx_cancel_btn", "dhx_save_btn"];
        }
        
        function override_schedular_templates() {
            scheduler.templates.lightbox_header = function(start, end, event){
                if (event.text == undefined)
                    var header = "New Event";
                else
                    var header = event.text;
                    
    			return header;
    		}
            
            scheduler.templates.event_bar_text = scheduler.templates.event_text = function(start,end,event){
    			if (event.text == undefined)
                    return "New Event";
                else
                    return event.text;
    		};
            
            scheduler.templates.event_class = function(start, end, event){
                var event_type = event.type;
                if(event_type == 'workflow')
                    return "workflow_event";
                else if(event_type == 'readonly')
                    return "readonly_event";
                else if(event_type == 'completed')
                    return "completed_event";
    		}
        }
        
        function load_schedular_events() {
            scheduler.attachEvent("onClick", function (id, e){
                return false;
            });
            scheduler.attachEvent("onDblClick", function (id){
                var event_type = scheduler.getEvent(id).type;
                var parent_id = scheduler.getEvent(id).event_pid;
                
                if (event_type == 'workflow') {
                    open_manage_approval();
                    return false;
                //} else if (event_type == 'completed' && parent_id != 0) {
//                    return false;    
                } else {
                    return true;
                }
            });
            
            scheduler.attachEvent("onLightbox", function(){
				var lightbox_form = scheduler.getLightbox(); // this will generate lightbox form
				var inputs = lightbox_form.getElementsByTagName('input');
				var date_of_end = null;
				for (var i=0; i<inputs.length; i++) {
					if (inputs[i].name == "date_of_end") {
						date_of_end = inputs[i];
						break;
					}
				}

                // Hide end date time from Time Period Section
                var time_period = scheduler.formSection("time");
                var controls = time_period.node.querySelector("span"); // Find span with - separator
                controls.style.display = "none";
                $(controls).nextAll().css({"display" : "none"});
                
				var repeat_end_date_format = scheduler.date.date_to_str(scheduler.config.repeat_date);
                var repeat_end_str_format = scheduler.date.str_to_date(scheduler.config.repeat_date);
                
				var show_minical = function(){
					if (scheduler.isCalendarVisible())
						scheduler.destroyCalendar();
					else {
						scheduler.renderCalendar({
							position:date_of_end,
							date: repeat_end_str_format(date_of_end.value),
							navigation:true,
							handler:function(date,calendar) {
								date_of_end.value = repeat_end_date_format(date);
								scheduler.destroyCalendar()
							}
						});
					}
				};
				date_of_end.onclick = show_minical;
			});
            
            scheduler.attachEvent("onEventCreated",function(id){
                mode = 'i';
                scheduler.getEvent(id).text = "New Event";
                return true;
            })

            scheduler.attachEvent("onEventSave",function(id,ev){
                var name = ev.text;
    			if (!name) {
                    show_messagebox("<b>Name</b> cannot be empty");
    				return false;
    			}
                
                var description = ev.description;
                var workflow_id = ev.workflow;
                var alert_id = 0;//ev.alert;
                var include_holiday = ev.include_holiday;
                var reminder = ev.reminder
                var rec_type = ev.rec_type;
                //var start_date = dates.convert_to_sql_with_time(scheduler.date.convert_to_utc(new Date(ev.start_date)));
                var start_date = dates.convert_to_sql_with_time(ev.start_date);
                //var end_date = dates.convert_to_sql_with_time(scheduler.date.convert_to_utc(new Date(ev.end_date)));
                var end_date = dates.convert_to_sql_with_time(ev.end_date);
                
                var exist_length = String(id).indexOf("#");
                if (exist_length != -1) {
                    var parent_date_offset = parent_start_date.getTimezoneOffset();
                    var date1 = new Date(parent_start_date.getTime() + (-1) * parent_date_offset * 60000);
                    var event_length = date1.getTime()/1000;
                    
                    var id_arrays = id.split("#");
                    var event_parent_id = id_arrays[0];
                    var id = id_arrays[1];
                    rec_type = '';
                    mode = 'i';
                } else {
                    var date1 = new Date(ev.start_date);
                    var date2 = new Date(ev.end_date);
                    var timeDiff = Math.abs(date2.getTime() - date1.getTime());
                    var event_length = Math.ceil(timeDiff / (1000));
                    var event_parent_id = 0;
                }
                
                if (rec_type != '') {
                    var end_date = dates.convert_to_sql_with_time(ev._end_date);
                    //var end_date = dates.convert_to_sql_with_time(scheduler.date.convert_to_utc(new Date(ev._end_date)));
                }
                
                if (mode == 'i') {
                    var xml = '<Root calendar_event_id="' + id + '" name="' + name + '" description="' + description + 
                                '" workflow_id="' +  workflow_id + '" alert_id="' + alert_id + '" include_holiday="' + include_holiday + '" reminder="' + reminder +
                                '" rec_type="' + rec_type + '" start_date="' + start_date + '" end_date="' + end_date +
                                '" event_parent_id="' +  event_parent_id + '" event_length="' + event_length + '"></Root>';
                } else {
                    var xml = '<Root calendar_event_id="' + id + '" name="' + name + '" description="' + description + 
                                '" workflow_id="' +  workflow_id + '" alert_id="' + alert_id + '" include_holiday="' + include_holiday + '" reminder="' + reminder +
                                '" rec_type="' + rec_type + '" start_date="' + start_date + '" end_date="' + end_date +
                                '" event_parent_id="' +  event_parent_id + '" event_length="' + event_length + '"></Root>';
                }
                
                var data = {
                    "action": "spa_calendar",
                    "flag": mode,
                    "xml": xml
                };
                
                adiha_post_data('return_json', data, '', '', '', '');
                
    			return true;
    		});
            
            scheduler.attachEvent("onConfirmedBeforeEventDelete", function(id, ev){
                var exist_length = id.indexOf("#");
                if (exist_length != -1) {
                    var name = ev.text;
                    var description = ev.description;
                    var start_date = dates.convert_to_sql_with_time(ev.start_date);
                    var end_date = dates.convert_to_sql_with_time(ev.end_date);
                    
                    var parent_date_offset = parent_start_date.getTimezoneOffset();
                    var date1 = new Date(parent_start_date.getTime() + (-1) * parent_date_offset * 60000);
                    var event_length = date1.getTime()/1000;
                    
                    var id_arrays = id.split("#");
                    var calendar_event_id = id_arrays[0];
                    var id = id_arrays[1];
                    
                    var xml = '<Root calendar_event_id="'+ id +'" name="' + name + '" description="' + description + 
                                '" workflow_id="" shared="" rec_type="none" start_date="' + start_date + '" end_date="' + end_date +
                                '" event_parent_id="' +  calendar_event_id + '" event_length="' + event_length + '"></Root>';
                    var data = {
                            "action": "spa_calendar",
                            "flag": "i",
                            "xml": xml
                        };
                } else {
                    var data = {
                                "action": "spa_calendar",
                                "flag": "d",
                                "calendar_event_id": id
                            };
                }
                
                adiha_post_data('return_json', data, '', '', '', '');
                return true;
            });
    		
            //Block Drag and Drop Temporarily
            scheduler.attachEvent("onBeforeDrag",function(){return false;})
            scheduler.attachEvent("onAfterLightbox",function(){
                mode = 'u';
                update_calendar_view();
            });
            
            scheduler.attachEvent("onBeforeLightbox", function (id){
                //For event length ()actual start date)
                var eventObj = scheduler.getEvent(id);
                parent_start_date = eventObj.start_date;
                //Change end by date dynamically
                var repeat_end_date_format = scheduler.date.date_to_str(scheduler.config.repeat_date);
                scheduler.config.repeat_date_of_end = repeat_end_date_format(scheduler.date.add(scheduler._date,30,"day"))
                
                return true;
            });
            
            scheduler.attachEvent("onContextMenu", function (event_id, native_event_object){
                ev_id = event_id;
                if (event_id) {
                    var event_obj = scheduler.getEvent(event_id);
                    var event_type = event_obj.type;
                    var menu_json = [{id:"set_reminder", text:"Set Reminder"},{id:"create_instance", text:"Complete"}];;
                    
                    context_menu.renderAsContextMenu();
                    context_menu.loadStruct(menu_json);
                    
                    if (event_type == 'workflow') {
                        context_menu.showItem("set_reminder");
                        context_menu.hideItem("create_instance");
                    } else if (event_type == 'calendar') {
                        context_menu.showItem("create_instance");
                        context_menu.hideItem("set_reminder");
                    } else {
                        context_menu.hideItem("create_instance");
                        context_menu.hideItem("set_reminder");
                    }
                    
					if (native_event_object.pageX || native_event_object.pageY) {
						posx = native_event_object.pageX;
						posy = native_event_object.pageY;
					} else if (native_event_object.clientX || native_event_object.clientY) {
						posx = native_event_object.clientX + document.body.scrollLeft + document.documentElement.scrollLeft;
						posy = native_event_object.clientY + document.body.scrollTop + document.documentElement.scrollTop;
					}
					context_menu.showContextMenu(posx, posy);
					return false;
				}
				return true;
            });
            
            context_menu.attachEvent("onClick", function(id, zoneId, cas){
                switch(id) {
                    case "set_reminder":
                        var formData = [
                        				{type: "settings", position: "label-top", labelWidth: 200, inputWidth: 200},
                        				{type: "combo", label: "Click Remind to be reminded in", name: "remind", options: [
                                            {"value":"5","text":"5 Minutes"}, 
                                            {"value":"10","text":"10 Minutes"}, 
                                            {"value":"15","text":"15 Minutes"}, 
                                            {"value":"30","text":"30 Minutes"},
                                            {"value":"60","text":"1 Hour"} 
                                        ]},
                        				{type: "button", value: "Remind", offsetLeft: 120}
                        			];
                        
    					myPop.attachEvent("onShow", function(){
    						myForm = myPop.attachForm(get_form_json_locale(formData));
							myForm.attachEvent("onButtonClick", function(){
								var remind_time = myForm.getItemValue("remind");
                                var data = {
                                    "action": "spa_calendar",
                                    "flag": "t",
                                    "snooze_time": remind_time                                    
                                };
                                myPop.hide();
                                adiha_post_data('return_json', data, '', '', '', '');
							});
    						myForm.setFocusOnFirstActive();
    					});
                        posx = posx -150;
                        myPop.show(posx,posy,350,300);
                        break;
                    case "create_instance":
                        var event_obj = scheduler.getEvent(ev_id);
                        var start_date = dates.convert_to_sql_with_time(event_obj.start_date);
                        
                        var id_arrays = ev_id.split("#");
                        var calendar_event_id = id_arrays[0];
                        
                        var data = {
                                "action": "spa_calendar",
                                "flag": "b",
                                "calendar_event_id": calendar_event_id,
                                "date_from": start_date
                            };
                        
                        adiha_post_data('return_json', data, '', '', 'create_instance_callback', '');
                        break;
                    default:
                        break;
                }
            });
        }
        
		
		function create_instance_callback(result) {
			var return_data = JSON.parse(result);
			if (return_data[0].recommendation == '') {
				dhtmlx.message({
					text:return_data[0].message,
					expire:1000
				});
				update_calendar_view();
				return;
			} else {
				open_manage_approval();
			}
		}
		
        function open_manage_approval() {
            if (dhx_wins != null && dhx_wins.unload != null) {
                dhx_wins.unload();
                dhx_wins = w1 = null;
            }
    
            if (!dhx_wins) {
                dhx_wins = new dhtmlXWindows();
            }
            
            param = app_form_path + '_compliance_management/setup_rule_workflow/workflow.approval.php';
            
            w11 = dhx_wins.createWindow("w1", 0, 0, 650, 550);
            w11.setText("Manage Approval");
            w11.setModal(true);
            w11.centerOnScreen();
            w11.maximize();
            w11.attachURL(param, false);

            w11.attachEvent("onClose", function(win) {
                update_calendar_view();
                return true;
            });
        }
		
		open_calendar_report = function() {
			combo_obj = namespace.filter_form.getCombo('user_id');
			var user = combo_obj.getChecked();
			var role = namespace.filter_form.getItemValue('role_id');
			var status = namespace.filter_form.getItemValue('status');
			var hour_from = namespace.filter_form.getItemValue('hour_from');
			var hour_to = namespace.filter_form.getItemValue('hour_to');
			
			var title_text = 'Calendar Report';
			var param = 'calendar.report.php?user=' + user + '&role' + role + '&status=' + status + '&hour_from=' + hour_from + '&hour_to=' + hour_to;
			
			var dhx_calendar_report = new dhtmlXWindows();
			
			calendar_report = dhx_calendar_report.createWindow("w1", 0, 0, 650, 500);		
			calendar_report.centerOnScreen();
			calendar_report.setText(title_text);
			calendar_report.attachURL(param, false, true);
			calendar_report.maximize();
		}
        
        open_rule_window = function() {
            var new_rule_window = new dhtmlXWindows();
            win = new_rule_window.createWindow('w1', 0, 0, 900, 830);
            win.setText("Rule");
            win.centerOnScreen();
            win.setModal(true);
            win.attachURL(js_php_path + "../adiha.html.forms/_compliance_management/setup_rule_workflow/workflow.rule.php?call_from=calendar");

            new_rule_window.attachEvent("onClose", function(win){
                load_workflow();       
                return true;
            });
        }

        /**
         * Loads i18n for the scheduler
         */
        function load_schedular_locales() {
            scheduler.locale.labels.section_name = "Name";
            scheduler.locale.labels.section_time = "Time";
            scheduler.locale.labels.section_workflow = "Workflow";
            scheduler.locale.labels.section_alert = "Alert";
            scheduler.locale.labels.section_reminder = "Reminder";
            scheduler.locale.labels.section_include_holiday = "Include Holiday";
            scheduler.locale.labels.confirm_deleting = "Are you sure you want to delete?";
            scheduler.locale.labels.confirm_recurring = "Are you sure you want to edit the whole set of repeated events?";
            var confirmation_label = "Confirmation";
            scheduler.locale.labels.title_confirm_deleting = confirmation_label;
            scheduler.locale.labels.title_confirm_recurring = confirmation_label;

            var locale_labels = {};
            Object.keys(scheduler.locale.labels).forEach(function(key) {
                locale_labels[key] = get_locale_value(scheduler.locale.labels[key]);
            });

            scheduler.locale = {
                date:{
                    month_full: dhtmlXCalendarObject.prototype.langData.custom.monthesFNames,
                    month_short: dhtmlXCalendarObject.prototype.langData.custom.monthesSNames,
                    day_full: dhtmlXCalendarObject.prototype.langData.custom.daysFNames,
                    day_short: dhtmlXCalendarObject.prototype.langData.custom.daysSNames
                },
                labels: locale_labels
            }
        }
    </script>
    
    <!--
    -- Custom Template Form for Recurring Event Start (Same as default only end by is checked instead of no end date)
    -->
    <div class="dhx_form_repeat" id="my_recurring_form">
	   <form>
            <div class="dhx_repeat_left">
               <label><input class="dhx_repeat_radio" type="radio" name="repeat" value="day" />Daily</label><br />
               <label><input class="dhx_repeat_radio" type="radio" name="repeat" value="week"/>Weekly</label><br />
               <label><input class="dhx_repeat_radio" type="radio" name="repeat" value="month" checked />Monthly</label><br />
               <label><input class="dhx_repeat_radio" type="radio" name="repeat" value="year" />Yearly</label>
            </div>
            <div class="dhx_repeat_divider"></div>
            <div class="dhx_repeat_center">
               <div style="display:none;" id="dhx_repeat_day">
                   <label><input class="dhx_repeat_radio" type="radio" name="day_type" value="d"/>Every</label><input class="dhx_repeat_text" type="text" name="day_count" value="1" />day<br />
                   <label><input class="dhx_repeat_radio" type="radio" name="day_type" checked value="w"/>Every workday</label>
               </div>
               <div style="display:none;" id="dhx_repeat_week">
                   Repeat every<input class="dhx_repeat_text" type="text" name="week_count" value="1" />week next days:<br />

                   <table class="dhx_repeat_days">
                       <tr>
                           <td>
                               <label><input class="dhx_repeat_checkbox" type="checkbox" name="week_day" value="1" />Monday</label><br />
                               <label><input class="dhx_repeat_checkbox" type="checkbox" name="week_day" value="5" />Friday</label>
                           </td>
                           <td>
                               <label><input class="dhx_repeat_checkbox" type="checkbox" name="week_day" value="2" />Tuesday</label><br />
                               <label><input class="dhx_repeat_checkbox" type="checkbox" name="week_day" value="6" />Saturday</label>
                           </td>
                           <td>
                               <label><input class="dhx_repeat_checkbox" type="checkbox" name="week_day" value="3" />Wednesday</label><br />
                               <label><input class="dhx_repeat_checkbox" type="checkbox" name="week_day" value="0" />Sunday</label>
                           </td>
                           <td>
                               <label><input class="dhx_repeat_checkbox" type="checkbox" name="week_day" value="4" />Thursday</label><br /><br />
                           </td>
                       </tr>
                   </table>

               </div>
               <div id="dhx_repeat_month">
                   <label><input class="dhx_repeat_radio" type="radio" name="month_type" value="d"/>Repeat</label><input class="dhx_repeat_text" type="text" name="month_day" value="1" />day every<input class="dhx_repeat_text" type="text" name="month_count" value="1" />month<br />
                   <label><input class="dhx_repeat_radio" type="radio" name="month_type" checked value="w"/>On</label><input class="dhx_repeat_text" type="text" name="month_week2" value="1" /><select name="month_day2"><option value="1" selected >Monday<option value="2">Tuesday<option value="3">Wednesday<option value="4">Thursday<option value="5">Friday<option value="6">Saturday<option value="0">Sunday</select>every<input class="dhx_repeat_text" type="text" name="month_count2" value="1" />month<br />
               </div>
               <div style="display:none;" id="dhx_repeat_year">
                   <label><input class="dhx_repeat_radio" type="radio" name="year_type" value="d"/>Every</label><input class="dhx_repeat_text" type="text" name="year_day" value="1" />day<select name="year_month"><option value="0" selected >January<option value="1">February<option value="2">March<option value="3">April<option value="4">May<option value="5">June<option value="6">July<option value="7">August<option value="8">September<option value="9">October<option value="10">November<option value="11">December</select>month<br />
                   <label><input class="dhx_repeat_radio" type="radio" name="year_type" checked value="w"/>On</label><input class="dhx_repeat_text" type="text" name="year_week2" value="1" /><select name="year_day2"><option value="1" selected >Monday<option value="2">Tuesday<option value="3">Wednesday<option value="4">Thursday<option value="5">Friday<option value="6">Saturday<option value="7">Sunday</select>of<select name="year_month2"><option value="0" selected >January<option value="1">February<option value="2">March<option value="3">April<option value="4">May<option value="5">June<option value="6">July<option value="7">August<option value="8">September<option value="9">October<option value="10">November<option value="11">December</select><br />
               </div>
            </div>
            <div class="dhx_repeat_divider"></div>
            <div class="dhx_repeat_right">
                   <label><input class="dhx_repeat_radio" type="radio" name="end" />No end date</label><br />
                   <label><input class="dhx_repeat_radio" type="radio" name="end" />After</label><input class="dhx_repeat_text" type="text" name="occurences_count" value="1" />occurrences<br />
                   <label><input class="dhx_repeat_radio" type="radio" name="end" checked/>End by</label><input class="dhx_repeat_date" type="text" name="date_of_end" value="'+scheduler.config.repeat_date_of_end+'" /><br />
            </div>
        </form>
    </div>
    <div style="clear:both">
    </div>
    <!--Custom Form Template ENDs-->
</html>