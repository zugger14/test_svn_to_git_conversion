<?php
/**
* Workflow report screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<head>
	<meta http-equiv="Content-type" content="text/html; charset=utf-8">
	<title>Basic initialization</title>
</head>
    <?php include "../../../adiha.php.scripts/components/include.file.v3.php"; ?>
	
    <style type="text/css">
		html, body{ height:100%; padding:0px; margin:0px; overflow: hidden;}
        .no_display{ visibility: hidden;}
        .nested_task .fa-plus{display: none !important;}    
        
        .workflow_tooltip {
            font-size: 14px;
        }
	</style>
	
    <?php
		$function_id = 10106612;
		$namespace = 'workflow_report';
	
        $filter_id = get_sanitized_value($_GET['filter_id']);
        $source_column = get_sanitized_value($_GET['source_column']);
		$filter_string = get_sanitized_value($_GET['filter_string'] ?? '');
		$module_id = get_sanitized_value($_GET['module_id']);
		$process_table_xml = get_sanitized_value($_GET['process_table_xml'] ?? '');
		$workflow_process_id  = get_sanitized_value($_GET['workflow_process_id'] ?? '');
		$as_of_date  = get_sanitized_value($_GET['as_of_date'] ?? '');
		
		$workflow_status_layout_label = get_locale_value('Workflow Status');
        $layout_obj = new AdihaLayout();
        $layout_json = '[{id: "a", height:100, width:300, text:"Apply Filter"},{id: "b", text:"Filter"},{id: "c", text:"' . $workflow_status_layout_label. ' - ' . $filter_string . '"}]';
        echo $layout_obj->init_layout('layout', '', '3U', $layout_json, $namespace);

		$default_wf_group_sql = "EXEC spa_workflow_progress @flag = 'b', @filter_id = '" . $filter_id . "', @source_column = '" . $source_column . "', @module_id = '" . $module_id . "'";
		$return_value = readXMLURL($default_wf_group_sql);
		$default_wf_group = $return_value[0][0] ?? '';
		
		$form_data_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10106612', @template_name='WorkflowStatusReport', @group_name='General'";
		$return_value = readXMLURL($form_data_sql);
		$form_json = $return_value[0][2];
		echo $layout_obj->attach_form('workflow_report_form', 'b');
		$workflow_report_form_obj = new AdihaForm();
		echo $workflow_report_form_obj->init_by_attach('workflow_report_form', $namespace);
		echo $workflow_report_form_obj->load_form($form_json);

		$menu_json = '[{id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif"}]';
		echo $layout_obj->attach_menu_layout_cell('workflow_report_menu', 'c', $menu_json, 'workflow_report_menu_onclick');
		
        echo $layout_obj->close_layout();
    ?> 
<body>
<div id="gantt_here" style='width:100%; height:100%;'></div>


<script type="text/javascript">
		var workflow_process_id = '<?php echo $workflow_process_id; ?>';
		var filter_id = '<?php echo $filter_id; ?>';
		var default_wf_group = '<?php echo $default_wf_group; ?>';
		var filter_string = '<?php echo $filter_string; ?>';
        $(function() {
            filter_obj = workflow_report.layout.cells('a').attachForm();
            var layout_cell_obj = workflow_report.layout.cells('b');
            load_form_filter(filter_obj, layout_cell_obj, '10106612', 2);
			
			var status_cmb = workflow_report.workflow_report_form.getCombo('status')
			status_cmb.setChecked(1, true);
			status_cmb.setChecked(3, true);
			status_cmb.setChecked(4, true);
			
			workflow_report.workflow_report_form.attachEvent("onChange", function (name, value){
				 if(name == 'workflow_group') {
					 reload_workflow_name_combo();
				 }
			});
			reload_workflow_group_combo();
			reload_workflow_name_combo();
        });
        
        function workflow_report_menu_onclick(name) {
			if (name == 'refresh') {
                workflow_status_report_refresh();
            }
		}
		
		workflow_status_report_refresh = function() {
			var module_event_obj = workflow_report.workflow_report_form.getCombo('workflow_name');
			var module_event_id = module_event_obj.getChecked();
			var status_obj = workflow_report.workflow_report_form.getCombo('status');
			var status = status_obj.getChecked();
			var show_all =(workflow_report.workflow_report_form.isItemChecked('show_all') == true) ? 'y' : 'n';
			if (module_event_id == '') {
				var module_event_arr = new Array();
				module_event_obj.forEachOption(function(optId){
					if(optId.value != '') {
						module_event_arr.push(optId.value);
					}
				});
				module_event_id = module_event_arr.toString();
			}
			
			if (status == '') {
				var status_arr = new Array();
				status_obj.forEachOption(function(optId){
					if(optId.value != '') {
						status_arr.push(optId.value);
					}
				});
				status = status_arr.toString();
			}
			
			var workflow_group_id = workflow_report.workflow_report_form.getItemValue('workflow_group');
			var source_col = '<?php echo $source_column; ?>';
			var process_table_xml = '<?php echo $process_table_xml; ?>';
			
			var as_of_date = '<?php echo $as_of_date; ?>';
			workflow_report.layout.cells('c').attachURL("workflow.report.detail.php?module_event_id=" + module_event_id + "&source_column='" + source_col + "'&filter_id=" + filter_id + "&filter_string=" + filter_string + '&workflow_group_id=' + workflow_group_id + '&process_table_xml=' + process_table_xml + '&status=' + status + '&workflow_process_id=' + workflow_process_id + '&as_of_date=' + as_of_date + '&show_all=' + show_all, true);
		}
    
		reload_workflow_name_combo = function() {
			var module_id = '<?php echo $module_id; ?>';
			var workflow_group_id = workflow_report.workflow_report_form.getItemValue('workflow_group');
			var workflow_name_obj = workflow_report.workflow_report_form.getCombo('workflow_name');
			
			var cm_param = {
                                "action": "spa_workflow_progress", 
                                "call_from": "form",
                                "flag": "w",
								"workflow_group_id": workflow_group_id,
								"module_id": module_id
                            };

            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;
            workflow_name_obj.clearAll();
            workflow_name_obj.load(url, function() {
				workflow_name_obj.setComboText('');
				if(filter_string == '') {
					workflow_status_report_refresh();
				}
			})
		}
	
		reload_workflow_group_combo = function() {
			var module_id = '<?php echo $module_id; ?>';
			var workflow_group_obj = workflow_report.workflow_report_form.getCombo('workflow_group');
			
			var cm_param = {
                                "action": "spa_workflow_progress", 
                                "call_from": "form",
                                "flag": "z",
								"module_id": module_id,
								"has_blank_option":false
                            };

            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;
            workflow_group_obj.unSelectOption();
            workflow_group_obj.load(url, function() {
                if (default_wf_group == '') {
                    workflow_group_obj.selectOption(0);
                } else {
                    workflow_group_obj.setComboValue(default_wf_group);
                }
            });
		}
		
		update_workflow_process_id = function(id, s_id) {
			workflow_process_id = id;
			filter_id = s_id;
		}
</script>