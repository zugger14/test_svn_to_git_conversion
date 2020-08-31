<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    </head>
<?php
require('../../../adiha.php.scripts/components/include.file.v3.php');
$form_namespace = 'deal_template_privilege';
$layout_obj = new AdihaLayout();
$form_obj = new AdihaForm();

$layout_json = '[{id: "a", header:false}]';

echo $layout_obj->init_layout('layout', '', '1C', $layout_json, $form_namespace);
echo $layout_obj->attach_menu_cell('deal_template_privilege_menu', 'a');
$deal_template_privilege_menu_object = new AdihaMenu();
$menu_json = '[{id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif", title: "Refresh"},
                {id:"export", text:"Export", img:"export.gif", items:[
                    {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                    {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"} ]},
                {id:"save", text:"Save", img:"save.gif", imgdis:"Save_dis.gif", title: "Save"}
                ]';
echo $deal_template_privilege_menu_object->init_by_attach('deal_template_privilege_menu', $form_namespace);
echo $deal_template_privilege_menu_object->load_menu($menu_json);
echo $deal_template_privilege_menu_object->attach_event('', 'onClick', $form_namespace . '.deal_template_privilege_menu_click');

$grid_name = 'deal_template_privilege';
echo $layout_obj->attach_grid_cell($grid_name, 'a');
 
$deal_template_privilege_grid_obj = new GridTable($grid_name);        
echo $deal_template_privilege_grid_obj->init_grid_table($grid_name, $form_namespace, 'n');
echo $deal_template_privilege_grid_obj->set_column_auto_size();
echo $deal_template_privilege_grid_obj->set_search_filter(true, "");      
echo $deal_template_privilege_grid_obj->enable_column_move();
echo $deal_template_privilege_grid_obj->return_init();
echo $deal_template_privilege_grid_obj->enable_header_menu();
 
//ADD CONTEXT MENU 
$context_menu_privilege = new AdihaMenu();
$context_menu_json_del = '[{id:"apply_to_all", text:"Apply to all", img:"paste.gif", imgdis:"paste_dis.gif", title: "Apply to all", enabled:"true"}]';
echo $context_menu_privilege->init_menu('context_menu_privilege', $form_namespace);
echo $context_menu_privilege->render_as_context_menu();
echo $context_menu_privilege->attach_event('', 'onClick', 'context_menu_privilege_click');
echo $context_menu_privilege->load_menu($context_menu_json_del);
echo $deal_template_privilege_grid_obj->enable_context_menu($form_namespace .'.context_menu_privilege');
echo $deal_template_privilege_grid_obj->attach_event('', 'onBeforeContextMenu', 'limit_to_column');
    
echo $layout_obj->close_layout();
?>
<script type="text/javascript">
    $(function() {
        deal_template_privilege.refresh_grid_deal_template_privilege();
    });
    
    function limit_to_column(row_id, col_ind, grid) {
        var user_col_ind = deal_template_privilege.deal_template_privilege.getColIndexById('user');
        var role_col_ind = deal_template_privilege.deal_template_privilege.getColIndexById('role');
        
        if (col_ind == user_col_ind || col_ind == role_col_ind) {
            grid.selectRowById(row_id);
            return true;
        } else {
            return false;
        }
    }
    /**
    * [Privilege Menu Click]
    */
    deal_template_privilege.deal_template_privilege_menu_click = function(id) {
    	switch(id) {
    		case 'refresh':
                deal_template_privilege.refresh_grid_deal_template_privilege();
                break;
            case 'excel':
                deal_template_privilege.deal_template_privilege.toExcel(js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                break;
            case 'pdf':
                deal_template_privilege.deal_template_privilege.toPDF(js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                break;  
            case 'save':
                deal_template_privilege.save_deal_template_privilege();
                break;
        }
    }
    
    deal_template_privilege.save_deal_template_privilege = function() {
        var xml = '<Root><GridXML>';
        deal_template_privilege.deal_template_privilege.forEachRow(function (id) {
            var template_id_column_id = deal_template_privilege.deal_template_privilege.getColIndexById('template_id'); 
            var template_id = deal_template_privilege.deal_template_privilege.cells(id, template_id_column_id).getValue();
            if (template_id != '') {
                xml = xml + '<GridRow ';
                deal_template_privilege.deal_template_privilege.forEachCell(id, function (cellObj, ind) {
                    grid_index = deal_template_privilege.deal_template_privilege.getColumnId(ind);
                    value = escapeXML(cellObj.getValue(ind));   
                    if (grid_index != 'action') {
                        xml = xml + grid_index + '="' + value  + '" ';
                    }	
                })
                xml = xml + '></GridRow>';
            }
        });
        xml = xml + '</GridXML></Root>';
        
        var data = {
                        'action' : 'spa_setup_deal_template',
                        'flag' : 'u',
                        'xml' : xml
                    };
        adiha_post_data('return_array', data, '', '', 'deal_template_privilege.save_deal_template_privilege_callback', '', '');
    }
    
    deal_template_privilege.save_deal_template_privilege_callback = function (return_value) {
        if (return_value[0][0] == 'Success') {
            dhtmlx.message({
                text:return_value[0][4] 
            });
           setTimeout('close_window()', 1000)
        } else {
            dhtmlx.message({
                        title:'Error',
                        type:'alert-error',
                        text:return_value[0][4]
                    });
            return;
        } 
    }
    
    function close_window() {
         var win_obj = parent.deal_template_privilege.window("w2");
         var namespace = '<?php echo get_sanitized_value($_GET['namespace']); ?>';
         var callback = '<?php echo get_sanitized_value($_GET['callback']); ?>';
         
         if(callback == '')
            eval("parent." + namespace + ".refresh_grid('', parent." + namespace + ".enable_menu_item)");
         else
            eval("parent." + namespace + ".refresh_grid('', parent." + callback + ")");
         
         win_obj.close();
    }
    
    function context_menu_privilege_click(menu_id, type) {
        var data = deal_template_privilege.deal_template_privilege.contextID.split('_');
        var column_id = data[1];
        var row_id = deal_template_privilege.deal_template_privilege.getSelectedRowId();
        var user_column_id = deal_template_privilege.deal_template_privilege.getColIndexById('user');
        var role_column_id = deal_template_privilege.deal_template_privilege.getColIndexById('role');
        
        if (column_id == user_column_id) {
             var to_update_value = deal_template_privilege.deal_template_privilege.cells(row_id, user_column_id).getValue();
        } else if (column_id == role_column_id) {
             var to_update_value = deal_template_privilege.deal_template_privilege.cells(row_id, role_column_id).getValue();
        } else {
            return;
        }
        
        deal_template_privilege.deal_template_privilege.forEachRow(function (id) {
            deal_template_privilege.deal_template_privilege.cells(id, column_id).setValue(to_update_value); 
        });
    }
    
    deal_template_privilege.refresh_grid_deal_template_privilege = function() {
        var deal_template_id = '<?php echo get_sanitized_value($_GET['deal_template_id']); ?>';
        var sql_param = {
                            'action' : 'spa_setup_deal_template',
                            'flag' : 'l',
                            'deal_template_id' : deal_template_id
                        };

        sql_param = $.param(sql_param);
        var sql_url = js_data_collector_url + "&" + sql_param;
 
		deal_template_privilege.deal_template_privilege.clearAndLoad(sql_url);
    }
    
    var static_data_privilege_win;
    
    function unload_static_data_privilege_window() {        
        if (static_data_privilege_win != null && static_data_privilege_win.unload != null) {
            static_data_privilege_win.unload();
            static_data_privilege_win = w2 = null;
        }
    }
    
    function open_user_role_window() {
        setTimeout(function(){
            var selected_row = deal_template_privilege.deal_template_privilege.getSelectedRowId();
            var user = deal_template_privilege.deal_template_privilege.cells(selected_row, deal_template_privilege.deal_template_privilege.getColIndexById('user')).getValue(); 
            var role = deal_template_privilege.deal_template_privilege.cells(selected_row, deal_template_privilege.deal_template_privilege.getColIndexById('role')).getValue(); 
            
            // params json
            var params = {
                            'user': user,
                            'role': role,
                            'selected_row': selected_row
            };
            
            unload_static_data_privilege_window();
            
            if (!static_data_privilege_win) {
                static_data_privilege_win = new dhtmlXWindows();
            }
            
            var new_win = static_data_privilege_win.createWindow('w2', 0, 0, 680, 380);
            
            var url = '<?php echo $app_php_script_loc; ?>' +  '../adiha.html.forms/_setup/maintain_static_data/maintain.static.data.privileges.php';
     
            new_win.setText("Maintain Privilege");  
            new_win.centerOnScreen();
            new_win.setModal(true); 
            
            new_win.attachURL(url, false, params);
        }, 100); 
    }
    
    function add_edit_privilege() {
        open_user_role_window();
    }
    
    function user_role_callback(val_from_to, val_role_to, selected_row) {
        deal_template_privilege.deal_template_privilege.cells(selected_row, deal_template_privilege.deal_template_privilege.getColIndexById('user')).setValue(val_from_to); 
        deal_template_privilege.deal_template_privilege.cells(selected_row, deal_template_privilege.deal_template_privilege.getColIndexById('role')).setValue(val_role_to); 
    
    }
</script>
</html>