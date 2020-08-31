<?php
/**
* Setup alerts reminder screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<head>
    <meta charset='UTF-8' />
    <meta name='viewport' content='width=device-width, initial-scale=1.0' />
    <meta http-equiv='X-UA-Compatible' content='IE=edge,chrome=1' />
</head>
<html>
    <?php
    require('../../../adiha.php.scripts/components/include.file.v3.php');
	$module_id = get_sanitized_value($_GET['module_id'] ?? '');
    $source_id= get_sanitized_value($_GET['source_id'] ?? '');
	
	$form_cell_json = "[
                            {
                                id:     'a',
                                width:  500,
                                header: false
                            },
							{
                                id:     'b',
                                header: false
                            }
                        ]";
    $rights_alert_reminder_add = 10106612;
    $rights_alert_reminder_delete = 10106612;
    
    list (
        $has_rights_alert_reminder_add,
        $has_rights_alert_reminder_delete
    ) = build_security_rights(
        $rights_alert_reminder_add,
        $rights_alert_reminder_delete
    );
    
    $form_layout = new AdihaLayout();
    $layout_name = 'alert_reminder';
    $form_name_space = 'alert_reminder';
    echo $form_layout->init_layout($layout_name, '', '2U', $form_cell_json, $form_name_space);
    
    //Attaching Grid Toolbar
    $menu_closing_date = new AdihaMenu();
    $menu_closing_date_json = '[ {id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif", title: "Refresh"},
                                    {id:"t2", text:"Edit", img:"edit.gif", items:[
                                        {id:"add", img:"add.gif", imgdis:"add_dis.gif", text:"Add", title:"Add", enabled: "'.$has_rights_alert_reminder_add.'"},
                                        {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete", enabled: 0}
                                    ]},
                                    {id:"t1", text:"Export", img:"export.gif", items:[
                                        {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                                        {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                                    ]}
                                ]';
    echo $form_layout->attach_menu_cell('alert_reminder_menu', 'a');
    echo $menu_closing_date->init_by_attach('alert_reminder_menu', $form_name_space);
    echo $menu_closing_date->load_menu($menu_closing_date_json);
    echo $menu_closing_date->attach_event('', 'onClick', 'alert_reminder_menu_click');
    
	
    //Attaching Grid 
    $grid_closing_account = new AdihaGrid();
    $grid_name = 'alert_reminder_grid';

    echo $form_layout->attach_grid_cell($grid_name, 'a');
    $grid_closing_account = new GridTable($grid_name);
    echo $form_layout->attach_status_bar("a", true);
    echo $grid_closing_account->init_grid_table($grid_name, $form_name_space);
    echo $grid_closing_account->set_search_filter(true);
    echo $grid_closing_account->split_grid(0);
    echo $grid_closing_account->return_init();
    echo $grid_closing_account->load_grid_data('', '', '', '');
    echo $grid_closing_account->load_grid_functions();
    echo $grid_closing_account->enable_paging(25, 'pagingArea_a', 'true');
    echo $grid_closing_account->enable_multi_select();
	
	echo $form_layout->close_layout();
    ?>
</html>
<script type="text/javascript">
	var module_id = '<?php echo $module_id; ?>';
	var source_id = '<?php echo $source_id; ?>';
	
	$(function(){
		alert_reminder_refresh();
		
		alert_reminder.alert_reminder_grid.attachEvent("onRowSelect", function(id,ind){
			alert_reminder.alert_reminder_menu.setItemEnabled('delete');
		});
		
		alert_reminder.alert_reminder_grid.attachEvent("onRowDblClicked", function(rId,cInd){
			var event_message_id = alert_reminder.alert_reminder_grid.cells(rId, alert_reminder.alert_reminder_grid.getColIndexById('Workflow_Event_Message')).getValue();
			alert_reminder_add(event_message_id);
		});
	})
    
    alert_reminder_menu_click = function(args) {
        switch(args) {
            case 'refresh':
                alert_reminder_refresh();
                break;
            case 'excel':
                path = js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php';
                alert_reminder.alert_reminder_grid.toExcel(path);
                break;
            case 'pdf':
                path = js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php';
                alert_reminder.alert_reminder_grid.toPDF(path);
                break;
            case 'delete':
                alert_reminder_delete();
                break;
            case 'add':
                alert_reminder_add('');
                break;
        }
    }
	
	alert_reminder_delete = function() {
		var event_message_arr = new Array();
		
		var selected_rows = alert_reminder.alert_reminder_grid.getSelectedRowId();
		if (selected_rows == '' || selected_rows == null) {
			show_messagebox('Pleasse select.');
			return;
		} else {
			selected_rows_arr = selected_rows.split(',');
			for (cnt = 0; cnt < selected_rows_arr.length; cnt++) {
				var event_message_id = alert_reminder.alert_reminder_grid.cells(selected_rows_arr[cnt], alert_reminder.alert_reminder_grid.getColIndexById('Workflow_Event_Message')).getValue();
				event_message_arr.push(event_message_id);
			}
		}
		
		var event_message_id = event_message_arr.toString();
		
		var data = {
						"action": "spa_setup_alert_reminder", 
						"flag": 'delete_remainder',
						"event_message_id": event_message_id
					}
					
		confirm_messagebox('Are you sure you want to Delete ?', function(){
            result = adiha_post_data("alert", data, "", "", "alert_reminder_refresh");
        });   		
	}
	
	alert_reminder_add = function(event_message_id) {
		var message_window = new dhtmlXWindows();
		win = message_window.createWindow('w1', 0, 0, 890, 650);
		win.setText("Message");
		win.centerOnScreen();
		win.setModal(true);
		win.attachURL("../setup_rule_workflow/workflow.rule.message.php?call_from=alert_reminder&module_id=" + module_id + "&source_id=" + source_id + "&message_id=" + event_message_id);	

		win.attachEvent("onClose", function(win) {
			alert_reminder_refresh();
			return true;
		});
	}
	
	alert_reminder_refresh = function() {
		var grid_param = {
			"flag": "grid",
			"action": "spa_setup_alert_reminder",
			"grid_type": "g",
			"module_id": module_id,
			"source_id": source_id
		};

		grid_param = $.param(grid_param);
		var grid_url = js_data_collector_url + "&" + grid_param;
		alert_reminder.alert_reminder_grid.clearAll();    
		alert_reminder.alert_reminder_grid.loadXML(grid_url, function() {
			alert_reminder.alert_reminder_menu.setItemDisabled('delete');
		});    
		alert_reminder.alert_reminder.cells('b').attachURL("../../_setup/setup_calendar/calendar.php?module_id=" + module_id + "&source_id=" + source_id);
	}
    
</script>