<?php
/**
* Eod process screen
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
    include '../../../adiha.php.scripts/components/include.file.v3.php';

    $form_namespace = 'eod_process';
    $application_function_id = 20007100;
    /*
    list (
        $has_rights_approval_approve,
        $has_rights_approval_delete                
    ) = build_security_rights(
        $rights_approval_approve,
        $rights_approval_delete                
    );*/
    
    $layout_json = '[
                        {id: "a", text: "Apply Filters",height:100},
                        {id: "b", text: "Filters Criteria",height:100},
                        {id: "c", text: "EOD Processes"}
                    ]';
    $layout_obj = new AdihaLayout();
    echo $layout_obj->init_layout('eod_process_layout', '', '3E', $layout_json, $form_namespace);
    
    $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='20007100', @template_name='EODProcess', @group_name='General'";
    $return_value = readXMLURL($xml_file);
    $form_json = $return_value[0][2];
    
    echo $layout_obj->attach_form('filter_form', 'b');
    $form_obj = new AdihaForm();
    echo $form_obj->init_by_attach('filter_form', $form_namespace);
    echo $form_obj->load_form($form_json);
    
    $menu_name = 'eod_menu';
    $menu_json = '[
            {id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif"},
            {id:"t2", text:"Export", img:"export.gif", imgdis:"export_dis.gif", disabled:false, items:[
                {id:"excel", text:"Excel", img:"excel.gif"},
                {id:"pdf", text:"PDF", img:"pdf.gif"},
                {id:"eod_report", text:"EOD Report", img:"process.gif", imgdis:"process_dis.gif", disabled:true}
            ]},
            {id:"workflow_status", text:"Workflow Status", img:"select_unselect.gif", imgdis:"select_unselect_dis.gif", disabled:true},
            {id:"new_eod_process", text:"New EOD Process", img:"select_unselect.gif", imgdis:"select_unselect_dis.gif"}
            ]';

    echo $layout_obj->attach_menu_layout_cell($menu_name, 'c', $menu_json, $form_namespace.'.menu_click');
    
    //attach grid
    $grid_name = 'eod_process_grid';
    echo $layout_obj->attach_grid_cell($grid_name, 'c');
    $grid_obj = new AdihaGrid();
    echo $layout_obj->attach_status_bar("c", true);
    echo $grid_obj->init_by_attach($grid_name, $form_namespace);
    echo $grid_obj->set_header("Master Process, As of Date, Create User, Create Time");
    echo $grid_obj->set_columns_ids("master_process_id,as_of_date,create_user, create_time");
    echo $grid_obj->set_widths("400,200,200,200");
    echo $grid_obj->set_column_types("ro,ro,ro,ro");
     echo $grid_obj->set_column_visibility("false,false,false,false");
    echo $grid_obj->enable_paging(100, 'pagingArea_c', 'true');
    echo $grid_obj->enable_column_move('false,false,false,false');
    echo $grid_obj->set_sorting_preference('str,date,str,date');
    echo $grid_obj->set_search_filter(true);
    echo $grid_obj->return_init();
    echo $grid_obj->enable_header_menu();
    echo $grid_obj->attach_event('', 'onRowSelect', 'eod_process_grid_select');
    
    echo $layout_obj->close_layout();
	
	$term_start =date('Y-m-d');
    $month_ini = new DateTime("first day of this month");
    $month_end = new DateTime("last day of this month");

    $date_from= $month_ini->format('Y-m-d'); 
    $date_to= $month_end->format('Y-m-d'); 
	
	$now = new DateTime();
	$today = $now->format('Y-m-d');
?>
<body class = "bfix2">
</body>
<script type="text/javascript">
    var client_date_format = '<?php echo $date_format; ?>';
	
    $(function(){
		eod_process.filter_form.setItemValue("date_from", "<?php echo $date_from;?>");
		eod_process.filter_form.setItemValue("date_to", "<?php echo $date_to;?>");
            
		
        filter_obj = eod_process.eod_process_layout.cells('a').attachForm();
        var layout_cell_obj = eod_process.eod_process_layout.cells('b');
        load_form_filter(filter_obj, layout_cell_obj, '20007100', 2);
    });
    
    function refresh_eod_process_grid() {
		eod_process.eod_menu.setItemDisabled("workflow_status");
		eod_process.eod_menu.setItemDisabled("eod_report");
        
        var status = validate_form(eod_process.filter_form);
        if (status == false) { 
			return; 
		}
		
		eod_process.eod_process_layout.cells('a').collapse();
        eod_process.eod_process_layout.cells('b').collapse();
        eod_process.eod_process_layout.cells('c').progressOn();
		
		var date_from = eod_process.filter_form.getItemValue("date_from", true);
		var date_to = eod_process.filter_form.getItemValue("date_to", true);
		var cmb_user_login_obj = eod_process.filter_form.getCombo("user_login_id");
		var user_login_id = cmb_user_login_obj.getChecked().join(',');
		
		var param = {
            "flag": "e",
            "action":"spa_workflow_progress",
            "grid_type":"g",
			"date_from": date_from,
			"date_to": date_to,
			"user_login_id": user_login_id
        };

        param = $.param(param);
        var param_url = js_data_collector_url + "&" + param;
        eod_process.eod_process_grid.clearAll();
        eod_process.eod_process_grid.loadXML(param_url);
        
        eod_process.eod_process_layout.cells('c').progressOff();
        
    }
    
    
    eod_process.menu_click = function(id, zoneId, cas) {
        switch(id) {
            case "refresh":
                refresh_eod_process_grid();
                break;
            case "pdf":
                eod_process.eod_process_grid.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                break;
            case "excel":
                eod_process.eod_process_grid.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                break;
            case "workflow_status":
                open_workflow_status_report('');
                break;
			case "new_eod_process":
				open_eod_param_popup();
                break;
			case "eod_report":
				open_eod_report()
				break;
            default:
                break;
        }
    }
    
    
    
    eod_process_grid_select = function() {
        eod_process.eod_menu.setItemEnabled("workflow_status");
		eod_process.eod_menu.setItemEnabled("eod_report");
    }
	
	open_workflow_status_report = function(as_of_date) {
		var filter_flag = 0;
		if (as_of_date != '') {
			filter_flag = -1;
		}
		var selected_row = eod_process.eod_process_grid.getSelectedRowId();
        if (selected_row != null) {
			var master_process_id = eod_process.eod_process_grid.cells(selected_row, eod_process.eod_process_grid.getColIndexById('master_process_id')).getValue();
			
			if (as_of_date == '') {
                as_of_date = eod_process.eod_process_grid.cells(selected_row, eod_process.eod_process_grid.getColIndexById('as_of_date')).getValue();
                as_of_date = dates.convert_to_sql(as_of_date); 
            }
		}
		
        var workflow_report = new dhtmlXWindows();
        workflow_report_win = workflow_report.createWindow('w1', 0, 0, 900, 700);
        workflow_report_win.setText("Workflow Status");
        workflow_report_win.centerOnScreen();
        workflow_report_win.setModal(true);
        workflow_report_win.maximize();
        
        var page_url = js_php_path + '../adiha.html.forms/_compliance_management/setup_rule_workflow/workflow.report.php?filter_id=' + filter_flag + '&source_column=workflow_process_id&module_id=20619&workflow_process_id='+master_process_id+'&as_of_date='+as_of_date; 
        workflow_report_win.attachURL(page_url, false, null);
        
        workflow_report_win.attachEvent("onClose", function(win){
            refresh_eod_process_grid();
            return true;
        });
    }
	
	open_eod_param_popup = function() {
		var label_width = parseInt(ui_settings['field_size']) + parseInt(ui_settings['offset_left']);
		var today = '<?php echo $today; ?>';
		var param_form_data = [
								{type: "settings", labelWidth: label_width, inputWidth: ui_settings['field_size'], position: "label-top", offsetLeft: ui_settings['offset_left']},
								{type: "calendar", name: "as_of_date", label: "As of Date", "dateFormat": client_date_format,serverDateFormat:"%Y-%m-%d", "value":today},
								{type: "block", blockOffset: 0, list: [
									{type: "button", name: "ok", value: "Ok", img: "tick.png"},
									{type: "newcolumn"},
									{type: "button", name: "cancel", value: "Cancel", img: "cancel.png"}
								]}
							];
				
		var param_popup = new dhtmlXPopup();
		var param_form = param_popup.attachForm(get_form_json_locale(param_form_data));
		
		var h = eod_process.eod_process_layout.cells('b').getHeight();
		var h1 = eod_process.eod_process_layout.cells('b').getHeight();
		
		param_form.attachEvent("onButtonClick", function(name){
			if (name == 'ok') {
				var as_of_date = param_form.getItemValue('as_of_date', true);
				open_workflow_status_report(as_of_date);
				param_popup.hide();	
			} else if (name == 'cancel') {
				param_popup.hide();
			}
		});
		
		var height = h+h1+40;
		param_popup.show(100,height,475,45);
	}
	
	open_eod_report = function() {
		eod_report_window = new dhtmlXWindows();
        
        var new_win = eod_report_window.createWindow('w1', 0, 0, 800, 600);
        new_win.setText("EOD Report");
        new_win.centerOnScreen();
        new_win.setModal(true);
        new_win.maximize();
        
        var selected_row = eod_process.eod_process_grid.getSelectedRowId();
        if (selected_row != null) {
			var master_process_id = eod_process.eod_process_grid.cells(selected_row, eod_process.eod_process_grid.getColIndexById('master_process_id')).getValue();
		}
		
		var url = app_form_path  + "_reporting/eod_process/eod.process.report.php?master_process_id=" + master_process_id;
        new_win.attachURL(url, false, true);
	}

    
    
</script>

<style>
    html, body {
        width: 100%;
        height: 100%;
        margin: 0px;
        padding: 0px;
        background-color: #ebebeb;
        overflow: hidden;
    }
</style>
</html>