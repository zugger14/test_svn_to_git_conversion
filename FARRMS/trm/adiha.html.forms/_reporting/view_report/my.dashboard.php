<?php
/**
* My dashboard screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  
        require('../../../adiha.php.scripts/components/include.file.v3.php'); 
        require('../../../adiha.php.scripts/components/include.ssrs.reporting.files.php');
    ?>
</head>
<body>
	<?php 
		$dashboard_id = get_sanitized_value($_GET['dashboard_id'] ?? 'NULL');
		$param_xml = (isset($_POST["param_xml"]) && $_POST["param_xml"] != '') ? $_POST["param_xml"] : '';

		$form_namespace = 'myDashboard';
		$layout_obj = new AdihaLayout();
    	$layout_json = '[{id: "a", header:false, text:"View"}]';
        echo $layout_obj->init_layout('layout', '', '1C', $layout_json, $form_namespace);

        $page_toolbar_json = '[
	    	{id:"configure", type: "button", img:"action.gif", imgdis:"action_dis.gif", enabled:true, text:"Configure", title: "Configure"},
	    	{id:"filters", type: "button", img:"filter_save.gif", imgdis:"filter_save.gif", enabled:true, text:"Change Filters", title: "Change Filters"},
	    	{id:"refresh", type: "button", img:"refresh.gif", imgdis:"refresh_dis.gif", enabled:true, text:"Refresh", title: "Refresh"},
	    	{id:"auto_refresh", type: "button", img:"refresh.gif", imgdis:"refresh_dis.gif", enabled:true, text:"Set Auto Refresh", title: "Set Auto Refresh"},
	    	{id:"view_mode", type: "button", img:"close.gif", imgdis:"close_dis.gif", enabled:true, text:"View Mode Off", title: "View Mode Off"}
	    ]';

	    $page_toolbar = new AdihaToolbar();
	    echo $layout_obj->attach_toolbar_cell('toolbar', 'a');
	    echo $page_toolbar->init_by_attach('toolbar', $form_namespace);
	    echo $page_toolbar->load_toolbar($page_toolbar_json);
	    echo $page_toolbar->attach_event('', 'onClick', $form_namespace . '.dashboard_toolbar_click');

        echo $layout_obj->close_layout();


        $form_obj = new AdihaForm();
        $time_value = range(0, 59);
    	$time_data = $form_obj->create_static_combo_box($time_value, $time_value, '', '', true);

        $popup_form_json = '[{"type": "settings"},
	                    	 {type:"block", blockOffset:0, list:[
								{type:"combo", "offsetLeft":10, "labelWidth":50, "inputWidth":50, name: "mins", position:"label-right", label:"min", filtering:true, "options":' . $time_data . '},
								{"type":"newcolumn"},
								{type:"combo", "labelWidth":50, "inputWidth":50, "offsetLeft":0, name: "secs", position:"label-right", label:"sec",  filtering:true, "options":' . $time_data . '},
								{"type":"newcolumn"},
								{type: "button", value: "Ok", "offsetLeft":0, name:"ok"}
							]}							
							]';

	?>
</body>
<textarea style="display:none" name="txt_params" id="txt_params"><?php echo urldecode($param_xml); ?></textarea>
<textarea style="display:none" name="txt_mins" id="txt_mins"></textarea>
<textarea style="display:none" name="txt_secs" id="txt_secs"></textarea>
<textarea style="display:none" name="txt_total_ms" id="txt_total_ms"></textarea>

<script type="text/javascript">
	var configure_dashboard;
	var dashboard_detail_layout;
	var cell_info = {};
	var dashboard_id = '<?php echo $dashboard_id;?>';
	var is_new = 'n';
	var params_window;
	var param_form;
	var auto_refresh_form;
	var auto_refresh_timeout;
	var call_from_save = false;

	var auto_refresh = function () {
		myDashboard.load_dashboard(-1, false);
	}

	$(function(){
		var my_dashboard_popup = new dhtmlXPopup({ 
		        toolbar: myDashboard.toolbar,
		        id: "auto_refresh"
		});

		var popup_form_json = <?php echo $popup_form_json;?>;
		auto_refresh_form = my_dashboard_popup.attachForm(popup_form_json);
		auto_refresh_form.attachEvent('onButtonClick', function(name) {
			if (name == 'ok') {
				var min = auto_refresh_form.getItemValue('mins');
				var sec = auto_refresh_form.getItemValue('secs');

				$('#txt_mins').val(min);
				$('#txt_secs').val(sec).trigger('change');
				my_dashboard_popup.hide();
			}
		})
		
		myDashboard.load_dashboard(-1, false);

		$('#txt_mins').change(function(){
		    myDashboard.set_total_ms();
		})

		$('#txt_secs').change(function(){
		    myDashboard.set_total_ms();
		})

		$('#txt_total_ms').change(function(){
			var ms = $('#txt_total_ms').val();
			if (ms == 0) {
				if (auto_refresh_timeout) clearTimeout(auto_refresh_timeout);
				return;
			}
			
			if (ms != '' && ms != 0) {
		    	auto_refresh_timeout = setTimeout(auto_refresh, ms);
			}
		})
	})

	myDashboard.set_total_ms = function() {
		var minutes = $('#txt_mins').val();
	    var seconds = $('#txt_secs').val();

	    auto_refresh_form.setItemValue('mins',minutes);
		auto_refresh_form.setItemValue('secs',seconds);

	    minutes = (minutes == '') ? 0 : minutes;
	    seconds = (seconds == '') ? 0 : seconds;

	    var total_ms = Number(((Number(minutes)*60) + Number(seconds))*1000);
		
		if (auto_refresh_timeout) clearTimeout(auto_refresh_timeout);
		
	    if (total_ms != 0) {	    	
	    	$('#txt_total_ms').val(total_ms).trigger('change');
	    }
	}

	/**
	 * [dashboard_toolbar_click Dashboard toolbar click]
	 * @param  {[type]} id [Toolbar Id]
	 */
	myDashboard.dashboard_toolbar_click = function(id) {
		if (id == 'configure') {
			myDashboard.open_configure_win();
		} else if (id == 'filters') {
			var data = {
		    	"action":"spa_pivot_report_dashboard",
	            "flag":"z",
	            "dashboard_id":dashboard_id
		    }
		    adiha_post_data("return", data, '', '', 'myDashboard.open_params_win');
		} else if (id == 'refresh') {
			myDashboard.load_dashboard(-1, false);
		} else if (id == 'view_mode') {
            var text = myDashboard.toolbar.getItemText(id);

            if (text.toLowerCase() == 'view mode off') {
                myDashboard.toolbar.setItemText(id, 'View Mode On');
                myDashboard.toolbar.setItemImage(id, 'tick.gif');
                myDashboard.turn_view_mode(false);
            } else {
                myDashboard.toolbar.setItemText(id, 'View Mode Off');
                myDashboard.toolbar.setItemImage(id, 'close.gif');
                myDashboard.turn_view_mode(true);
            }
        }
	}

	myDashboard.open_params_win = function(result) {
		var form_json = JSON.parse(result[0].form_json);
		if (params_window != null && params_window.unload != null) {
            params_window.unload();
            params_window = w1 = null;
        }

        if (!params_window) {
            params_window = new dhtmlXWindows();
            var win = params_window.createWindow('w1', 0, 0, 400, 600);
            win.setText("Dashboard Filters");
            win.setModal(true);
            win.centerOnScreen();
            win.button("park").hide();
            win.maximize();

            var param_toolbar = win.attachToolbar();
			param_toolbar.setIconsPath(js_image_path + "dhxtoolbar_web/");
			param_toolbar.loadStruct([{id:"ok", type: "button", img:"tick.gif", imgdis:"tick_dis.gif", enabled:true, text:"Ok", title: "Ok"}]);
			
			if (param_form != null && param_form.unload != null) {
				param_form.unload();
				param_form = null;
			}
			
			param_form = win.attachForm();
			param_form.loadStruct(form_json);
			attach_browse_event('param_form',-10201625); //allowed all book str to be loaded on dashboard filters as on sql based reports.

			param_toolbar.attachEvent('onClick', function() {
				var param_xml = 'NULL';

			    if (param_form) {
			    	var form_data = param_form.getFormData();
			    	param_xml = '<Root>';
			    	for (var a in form_data) {
						var value = form_data[a];
						var name = a;
						if(param_form.getItemType(name) == 'calendar') {
							value = param_form.getItemValue(name,true);
						}
						value = (value == 'null' || value == null) ? '' : value;

						param_xml += '<FormXML param_name="' + name + '" param_value="' + value + '"></FormXML>'
					}
					param_xml += '</Root>';

					param_xml = (param_xml == '<Root></Root>') ? 'NULL' : param_xml;
			    }
			    win.close();
			    $('#txt_params').val(param_xml);
			    myDashboard.load_dashboard(-1, false);			    
			});
        }
	}

	/**
	 * [open_configure_win Open Configure win]
	 */
	myDashboard.open_configure_win = function() {
		if (configure_dashboard != null && configure_dashboard.unload != null) {
            configure_dashboard.unload();
            configure_dashboard = w1 = null;
        }
        if (!configure_dashboard) {
            configure_dashboard = new dhtmlXWindows();
            var win = configure_dashboard.createWindow('w1', 0, 0, 400, 600);
            win.setText("Configure Dashboard");
            win.setModal(true);
            win.centerOnScreen();
            win.button("park").hide();
            win.maximize();
            var url = 'configure.dashboard.php?dashboard_id=' + dashboard_id;
            win.attachURL(url);
            win.attachEvent("onClose", function(win){    
	            var ifr = win.getFrame();
	            var ifrWindow = ifr.contentWindow;
	            var ifrDocument = ifrWindow.document;
	            var status = $('textarea[name="txt_save_status"]', ifrDocument).val();
	            var new_id = $('textarea[name="txt_new_id"]', ifrDocument).val();
	            new_id = (new_id == '' || new_id == null) ? -1 : new_id;

	            if (status != 'cancel' && status != '') {
	                myDashboard.load_dashboard(new_id, true);
	            } 

	            return true;
            })
        }
	}

	myDashboard.load_dashboard = function(id, is_save) {
		if (id != -1) {
			dashboard_id = id;
			is_new = 'y';
		}
		call_from_save = is_save;

		var data = {
	    	"action":"spa_pivot_report_dashboard",
            "flag":"s",
            "dashboard_id":dashboard_id
	    }
	    adiha_post_data("return_status", data, '', '', 'myDashboard.load_dashboard_detail');
	}

	myDashboard.load_dashboard_detail = function(return_val) {
		if (return_val.length > 0) {
			var layout_pattern = return_val[0].layout_format.toUpperCase();
			var dashboard_name = return_val[0].dashboard_name;
			var mins = return_val[0].mins;
			var secs = return_val[0].secs;

			if (call_from_save && parent.dashboard) {
				parent.dashboard.change_tab_name(dashboard_name, is_new, dashboard_id);
			}

			var user_defined_mins = $('#txt_mins').val();
			var user_defined_secs = $('#txt_secs').val();

			if (user_defined_mins == '' || user_defined_mins == 0) {
				$('#txt_mins').val(mins);
			} else {
				$('#txt_mins').val(user_defined_mins);
			}

			if (user_defined_secs == '' || user_defined_secs == 0) {
				$('#txt_secs').val(secs).trigger('change');
			} else {
				$('#txt_secs').val(user_defined_secs).trigger('change');
			}

			if (is_new == 'y') return;

			var form_path = app_form_path;
			var main_win_url = form_path + '/_reporting/view_report/pivot.dashboard.php';

			if (dashboard_detail_layout != null) {	
				dashboard_detail_layout.unload();		
				dashboard_detail_layout = null;
			}
			dashboard_detail_layout = myDashboard.layout.cells('a').attachLayout(layout_pattern);

			dashboard_detail_layout.attachEvent("onContentLoaded", function(id){
			    dashboard_detail_layout.cells(id).progressOff();
			});

			dashboard_detail_layout.attachEvent("onUnDock", function(id){
			    $(".undock_cell").hide();
			});

			dashboard_detail_layout.attachEvent("onDock", function(id){
			    $(".undock_cell").show();
			});

			dashboard_detail_layout.attachEvent("onPanelResizeFinish", function(names){
			    myDashboard.resize_refresh('');
			});

			dashboard_detail_layout.attachEvent("onCollapse", function(name){
			    myDashboard.resize_refresh(name);
			});

			dashboard_detail_layout.attachEvent("onExpand", function(name){
			    myDashboard.resize_refresh(name);
			});

			var cell_a_width = myDashboard.layout.cells('a').getWidth();
			var cell_a_height = myDashboard.layout.cells('a').getHeight();
			var replace_params = $('#txt_params').val();
            replace_params = replace_params.replace("subbook_id", "sub_book_id");
			jQuery.each(return_val, function(i, val) {
				var cell_text = '<div><a class=\"undock_cell undock_custom\" title=\"Undock\" onClick=\"myDashboard.undock_cell(\'' + val.cell_id + '\', \'' + val.report_name + '\')\"></a>' + val.report_name + '</div>'
				
				var cell_width = Number((val.width/100)*cell_a_width).toFixed(2);
		    	var cell_height = Number((val.height/100)*cell_a_height).toFixed(2);

		    	dashboard_detail_layout.cells(val.cell_id).setHeight(cell_height);
		    	dashboard_detail_layout.cells(val.cell_id).setWidth(cell_width);
				dashboard_detail_layout.cells(val.cell_id).setText(cell_text);
				dashboard_detail_layout.cells(val.cell_id).progressOn();
				var data = {"view_id": val.report_id, "is_dashboard":'y', "dashboard_id":dashboard_id, "replace_params":replace_params, "cell_id":val.cell_id};
				var win_url = main_win_url + '?' + $.param(data);

				cell_info[val.cell_id] = win_url;
				dashboard_detail_layout.cells(val.cell_id).attachURL(win_url);
			});
		}
	}

	myDashboard.resize_refresh = function(id) {
		dashboard_detail_layout.forEachItem(function(cell){
			var cell_id = cell.getId();

			var ifr = cell.getFrame();
		    if (ifr) {		    	
	            var ifrWindow = ifr.contentWindow;
                ifrWindow.viewPivotDashboard.tab_click('view', 'advance'); 
		    }		    
		});
	}

	myDashboard.undock_cell = function(cell_id, cell_text) {
		var url = cell_info[cell_id];
		open_window(url);

		/*
		var obj = dashboard_detail_layout;
        obj.cells(cell_id).undock(300, 300, 900, 700);
        obj.dhxWins.window(cell_id).button("park").hide();
        obj.dhxWins.window(cell_id).maximize();
        obj.dhxWins.window(cell_id).centerOnScreen();
        */
	}

    myDashboard.turn_view_mode = function(mode) {
		if (mode) {
			myDashboard.toolbar.hideItem('configure');
			myDashboard.toolbar.hideItem('auto_refresh');
			myDashboard.toolbar.setItemText('view_mode', 'View Mode Off');
			myDashboard.toolbar.setItemImage('view_mode', 'close.gif');
		} else {
			myDashboard.toolbar.showItem('configure');
			myDashboard.toolbar.showItem('auto_refresh');
		}
		
        dashboard_detail_layout.forEachItem(function(cell){
            var cell_id = cell.getId();

            if (mode) cell.hideHeader();
            else cell.showHeader();

            var ifr = cell.getFrame();
            if (ifr) {
                var ifrWindow = ifr.contentWindow;


                ifrWindow.viewPivotDashboard.turn_view_mode(mode);
            }
        });
    }
</script>