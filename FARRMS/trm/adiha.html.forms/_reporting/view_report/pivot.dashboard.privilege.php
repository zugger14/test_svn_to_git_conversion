<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  
        require_once('../../../adiha.php.scripts/components/include.file.v3.php');
    ?>
</head>
<body>
    <?php     
    $call_from = get_sanitized_value($_POST['call_from'] ?? 'NULL');
    $dashboard_id = get_sanitized_value($_POST['dashboard_id'] ?? 'NULL');
    
    $form_namespace = 'dashboardPrivilege';
    $layout_json = "[{id:'a', header: false}]";
          
    $layout_obj = new AdihaLayout();
    echo $layout_obj->init_layout('layout', '', '1C', $layout_json, $form_namespace);
    
    $context_menu = new AdihaMenu();
    $context_menu_json = '[{id:"add", text:"Apply to All Dashboard(s)", title: "Apply to All Dashboard(s)"}]';
    echo $context_menu->init_menu('context_menu_report', $form_namespace);
    echo $context_menu->render_as_context_menu();
    echo $context_menu->attach_event('', 'onClick', $form_namespace . '.context_menu_click');
    echo $context_menu->load_menu($context_menu_json);
    
    // attach menu
    $menu_json = '[		
		{id:"refresh", text:"Refresh", img:"refresh.gif", enabled:true, imgdis:"refresh_dis.gif", title: "Refresh"},
		{id:"export", text:"Export", img:"export.gif", items:[
            {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
            {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
        ]},
		{id: "save", img:"save.gif", img_disabled:"save.gif", text:"Save", title:"Save"}
		]';

    $menu_obj = new AdihaMenu();
    echo $layout_obj->attach_menu_cell("privilege_menu", "a");  
    echo $menu_obj->init_by_attach("privilege_menu", $form_namespace);
    echo $menu_obj->load_menu($menu_json);
    echo $menu_obj->attach_event('', 'onClick', $form_namespace . '.menu_click');  

    echo $layout_obj->attach_grid_cell('pivot_dashboard_privilege', 'a');
    $pivot_dashboard_privilege = new GridTable('pivot_dashboard_privilege');        
    echo $pivot_dashboard_privilege->init_grid_table('pivot_dashboard_privilege', $form_namespace, 'n');
    echo $pivot_dashboard_privilege->set_column_auto_size();     
    echo $pivot_dashboard_privilege->enable_column_move();
    echo $pivot_dashboard_privilege->enable_multi_select();
    echo $pivot_dashboard_privilege->attach_event("", "onRowDblClicked", $form_namespace . '.open_popup');
    echo $pivot_dashboard_privilege->return_init(); 
    
    echo $layout_obj->close_layout();
    ?>
</body>  
<script>
    var dashboard_id = '<?php echo $dashboard_id; ?>';

    $(function(){
        dashboardPrivilege.refresh_grid();
    });

    dashboardPrivilege.refresh_grid = function() {
    	var sql_param = {
            "action":"spa_pivot_dashboard_privilege",
            "flag":"s",
            "dashboard_id":dashboard_id,
            "grid_type":"g"
        }

        sql_param = $.param(sql_param);
        var sql_url = js_data_collector_url + "&" + sql_param;
        dashboardPrivilege.pivot_dashboard_privilege.clearAll();
        dashboardPrivilege.pivot_dashboard_privilege.load(sql_url);
    }

    dashboardPrivilege.menu_click = function(id) {
    	switch (id) {
            case 'excel':
                dashboardPrivilege.pivot_dashboard_privilege.toExcel(js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                break;
            case 'pdf':
                dashboardPrivilege.pivot_dashboard_privilege.toPDF(js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                break;  
            case 'save':
                dashboardPrivilege.save_privilege();
                break;  
            case 'refresh':
            	dashboardPrivilege.refresh_grid();
            	break;
        }        
    }

    var static_data_privilege_win;
    dashboardPrivilege.open_popup = function(row_id, col_id) {
    	var user_index = dashboardPrivilege.pivot_dashboard_privilege.getColIndexById('user_id');
        var user_id = dashboardPrivilege.pivot_dashboard_privilege.cells(row_id, user_index).getValue();
        var role_name_index = dashboardPrivilege.pivot_dashboard_privilege.getColIndexById('role_name');
        var role = dashboardPrivilege.pivot_dashboard_privilege.cells(row_id, role_name_index).getValue();

        unload_static_data_privilege_window();
            
        if (!static_data_privilege_win) {
            static_data_privilege_win = new dhtmlXWindows();
        }
        
        var post_params = {
            user: user_id,
            role: role,
            selected_row:row_id
        };
        var url = app_form_path + '_setup/maintain_static_data/maintain.static.data.privileges.php';

        var new_win = static_data_privilege_win.createWindow('w2', 0, 0, 680, 380);
        new_win.setText("Privilege");  
        new_win.centerOnScreen();
        new_win.setModal(true); 
        new_win.attachURL(url, false, post_params); 
    }

    function unload_static_data_privilege_window() {        
        if (static_data_privilege_win != null && static_data_privilege_win.unload != null) {
            static_data_privilege_win.unload();
            static_data_privilege_win = w2 = null;
        }
    }

    function user_role_callback(val_from_to, val_role_to, selected_row) {
        dashboardPrivilege.pivot_dashboard_privilege.cells(selected_row, dashboardPrivilege.pivot_dashboard_privilege.getColIndexById('user_id')).setValue(val_from_to); 
        dashboardPrivilege.pivot_dashboard_privilege.cells(selected_row, dashboardPrivilege.pivot_dashboard_privilege.getColIndexById('role_name')).setValue(val_role_to); 
    }

    dashboardPrivilege.save_privilege = function(){    
        var xml_grid = '<GridXml>';
        
        dashboardPrivilege.pivot_dashboard_privilege.forEachRow(function (id) {    
            xml_grid = xml_grid + '<GridRow ';
            dashboardPrivilege.pivot_dashboard_privilege.forEachCell(id, function (cellObj, ind) { 
                var column_id = dashboardPrivilege.pivot_dashboard_privilege.getColumnId(ind);
                value = cellObj.getValue(ind);

                xml_grid = xml_grid + column_id + '="' + value  + '" ';
                    
            })  
            xml_grid = xml_grid + '></GridRow>';                      
        });

        xml_grid = xml_grid + '</GridXml>';     
      
      	var data = {
                        'action' : 'spa_pivot_dashboard_privilege',
                        'flag' : 'y',
                        'xml_data' : xml_grid
                    };

        adiha_post_data('alert', data, '', '', 'dashboardPrivilege.save_privilege_callback', '', '');
    }

    dashboardPrivilege.save_privilege_callback = function(result){
        if (result[0].errorcode == 'Success') {
           setTimeout('close_window()', 1000);
        }
    }

    function close_window() {
         var win_obj = parent.privilege_window.window("w1");
         win_obj.close();       
    }
    
</script>
<style type="text/css">
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