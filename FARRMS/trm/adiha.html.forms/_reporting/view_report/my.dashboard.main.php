<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
        <?php require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
    </head>
    <?php
        $form_namespace = 'dashboard';
        $form_obj = new AdihaStandardForm($form_namespace, 20005500);
        $form_obj->define_grid("my_dashboard");
        $form_obj->define_layout_width(300);
        echo $form_obj->init_form('Dashboard', 'Dashboard Details', '');
        echo $form_obj->define_custom_setting(true);
        //function define_custom_functions($save_function, $form_load_function, $delete_function,$form_load_complete_function, $before_save_validation, $after_save_function) {
        echo $form_obj->define_custom_functions('', 'load_dashboard', 'delete_dashboard');
        echo $form_obj->close_form();
    ?>
<body>
</body>
<script type="text/javascript">
	$(function(){
		dashboard.menu.setItemEnabled('add');

		dashboard.grid.attachEvent('onRowSelect', function(id, ind) {
			if (id != null) dashboard.menu.setItemEnabled('delete');
		});

		dashboard.menu.addNewChild('t1', 2, 'privilege', 'Privilege', true, 'privilege.gif', 'privilege_dis.gif');

		dashboard.grid.attachEvent("onSelectStateChanged", function(row_id){
			if (row_id != null && row_id != '') {
				dashboard.menu.setItemEnabled('delete');
				dashboard.menu.setItemEnabled('privilege');
			} else {
				dashboard.menu.setItemDisabled('delete');
				dashboard.menu.setItemDisabled('privilege');
			}
		});

		dashboard.menu.attachEvent("onClick", function(id){
			if (id == 'privilege') {
				dashboard.check_privilege();
			}
		});
	})

	dashboard.check_privilege = function() {
		var selected_id = dashboard.grid.getSelectedRowId();
		var dashboard_id = dashboard.grid.getColumnValues(0);

		data = {"action": "spa_pivot_report_dashboard", "flag":"w", "dashboard_id":dashboard_id};
        adiha_post_data("return", data, '', '', 'dashboard.open_privilege_window');
	}

	var privilege_window;
	dashboard.open_privilege_window = function(result) {
		if (result[0].privilege == 1) {
			if (privilege_window != null && privilege_window.unload != null) {
	            privilege_window.unload();
	            privilege_window = w1 = null;
	        }

	        var dashboard_id = dashboard.grid.getColumnValues(0);
	        
	        if (!privilege_window) {
	            privilege_window = new dhtmlXWindows();
	        }

	        var win_title = 'Privilege';
	        var win_url = 'pivot.dashboard.privilege.php';
	        var win = privilege_window.createWindow('w1', 0, 0, 800, 500);

	        win.setText(win_title);
	        win.centerOnScreen();
	        win.setModal(true);

	        win.attachURL(win_url, false, {dashboard_id:dashboard_id});
		} else {
			show_messagebox('Dashboard Privilege can be assigned only by admin users or dashboard owners.');
            return;
		}
	}

	dashboard.load_dashboard = function(win, full_id, grid_obj, acc_id) {
		win.progressOff();		
		var dashboard_id = (full_id.indexOf("tab_") != -1) ? full_id.replace("tab_", "") : full_id;
		var win_text = win.getText();
		var url = 'my.dashboard.php?dashboard_id='+ dashboard_id;
		win.attachURL(url);
        dashboard.layout.cells("a").collapse();
	}

	dashboard.delete_dashboard = function() {
		var selected_id = dashboard.grid.getSelectedRowId();
		var count = selected_id.indexOf(",") > -1 ? selected_id.split(",").length : 1;
		selected_id = count > 1 ? selected_id.split(",") : [selected_id];

		var dashboard_ids = dashboard.grid.getColumnValues(0);

		dhtmlx.message({
			type: "confirm",
			title: "Confirmation",
			ok: "Confirm",
			text: "Are you sure you want to delete selected dashboard(s)?",
			callback: function(result) {
				if (result) {
					for ( var i = 1; i <= count; i++) {
						var full_id = dashboard.get_id(dashboard.grid, selected_id[i-1]);

						if (dashboard.pages[full_id]) {
				        	dashboard.tabbar.cells(full_id).close();			        	
							delete dashboard.pages[full_id];
				        }
				    }

			        data = {
				    	"action":"spa_pivot_report_dashboard",
		                "flag":"d",
		                "dashboard_id":dashboard_ids
				    }
			        adiha_post_data("alert", data, "", "", "dashboard.delete_callback");
				}
			}
		});
	}

	dashboard.delete_callback = function(result) {
		if (result[0].errorcode == 'Success') {
			dashboard.refresh_grid();
		}
	}

	dashboard.change_tab_name = function(name, is_new, id) {
		var tab_id = dashboard.tabbar.getActiveTab();
		var previous_text = dashboard.tabbar.tabs(tab_id).getText();

		if (previous_text != name && is_new == 'y') {
			dashboard.tabbar.tabs(tab_id).setText(id);
			dashboard.refresh_grid("", dashboard.open_tab);
		} else if (previous_text != name && is_new == 'n') {
			dashboard.tabbar.tabs(tab_id).setText(name);
		}
	}




</script>

</html>