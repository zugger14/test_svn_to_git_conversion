<?php
/**
* Maintain static data privileges grid screen
* @copyright Pioneer Solutions
*/
?>
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
$form_namespace = 'static_data_privilege';
$form_name = 'frm_sdp';

$layout_obj = new AdihaLayout();
$form_obj = new AdihaForm();

$layout_json = '[{id: "a", header:false}]';

echo $layout_obj->init_layout('layout', '', '1C', $layout_json, $form_namespace);
echo $layout_obj->attach_menu_cell('static_data_privilege_menu', 'a');
$static_data_privilege_menu_object = new AdihaMenu();
$menu_json = '[{id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif", title: "Refresh"},
                {id:"export", text:"Export", img:"export.gif", items:[
                    {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                    {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"} ]},
                {id:"expand_collapse", text:"Expand/Collapse All", img:"exp_col.gif", imgdis:"exp_col_dis.gif", title:"Expand/Collapse All"},
                {id:"save", text:"Save", img:"save.gif", imgdis:"Save_dis.gif", title: "Save"},
               
                ]';
echo $static_data_privilege_menu_object->init_by_attach('static_data_privilege_menu', $form_namespace);
echo $static_data_privilege_menu_object->load_menu($menu_json);
echo $static_data_privilege_menu_object->attach_event('', 'onClick', $form_namespace . '.static_data_privilege_menu_click');

$grid_name = 'static_data_privilege';
echo $layout_obj->attach_grid_cell($grid_name, 'a');
 
$static_data_privilege_grid_obj = new GridTable($grid_name);        
echo $static_data_privilege_grid_obj->init_grid_table($grid_name, $form_namespace, 'n');
echo $static_data_privilege_grid_obj->set_column_auto_size();
echo $static_data_privilege_grid_obj->set_search_filter(true, "");      
echo $static_data_privilege_grid_obj->enable_column_move();
echo $static_data_privilege_grid_obj->return_init();
echo $static_data_privilege_grid_obj->enable_header_menu();
echo $static_data_privilege_grid_obj->attach_event('', 'onRowDblClicked', 'open_close_groups');
 
//ADD CONTEXT MENU 
$context_menu_privilege = new AdihaMenu();
$context_menu_json_del = '[{id:"apply_to_all", text:"Apply to all", img:"paste.gif", imgdis:"paste_dis.gif", title: "Apply to all", enabled:"true"}]';
echo $context_menu_privilege->init_menu('context_menu_privilege', $form_namespace);
echo $context_menu_privilege->render_as_context_menu();
echo $context_menu_privilege->attach_event('', 'onClick', 'context_menu_privilege_click');
echo $context_menu_privilege->load_menu($context_menu_json_del);
echo $static_data_privilege_grid_obj->enable_context_menu($form_namespace .'.context_menu_privilege');
echo $static_data_privilege_grid_obj->attach_event('', 'onBeforeContextMenu', 'limit_to_column');
    
    
echo $layout_obj->close_layout();
?>
<script type="text/javascript">
    var expand_state = 0;
    $(function() {
        static_data_privilege.refresh_grid_static_data_privilege();
    });
    
    function open_close_groups(row_id, col_id) {
        var level = static_data_privilege.static_data_privilege.getLevel(row_id);
        if (level == 0) {
            var state = static_data_privilege.static_data_privilege.getOpenState(row_id);
            
            if (state)
                static_data_privilege.static_data_privilege.closeItem(row_id);
            else
                static_data_privilege.static_data_privilege.openItem(row_id);
        }
    }
    
    function limit_to_column(row_id, col_ind, grid) {
        if (col_ind == 4 || col_ind == 5 || col_ind == 6) {
            grid.selectRowById(row_id);
            return true;
        } else {
            return false;
        }
    }
    /**
    * [Privilege Menu Click]
    */
    static_data_privilege.static_data_privilege_menu_click = function(id) {
    	switch(id) {
    		case 'refresh':
                static_data_privilege.refresh_grid_static_data_privilege();
                expand_state = 0;
                break;
            case 'excel':
                static_data_privilege.static_data_privilege.toExcel(js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                break;
            case 'pdf':
                static_data_privilege.static_data_privilege.toPDF(js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                break;  
            case 'save':
                static_data_privilege.save_static_data_privilege();
                break;
            case "expand_collapse":
                if(expand_state == 0) {
                    static_data_privilege.static_data_privilege.expandAll();
                    expand_state = 1;
                } else {
                    static_data_privilege.static_data_privilege.collapseAll();
                    expand_state = 0;
                }
                break;
        }
    }
    
    static_data_privilege.save_static_data_privilege = function() {
        var xml_grid = '<gridXml>';
        static_data_privilege.static_data_privilege.forEachRow(function (id) {
            var type_column_id = static_data_privilege.static_data_privilege.getColIndexById('type_id'); 
            var type_id = static_data_privilege.static_data_privilege.cells(id, type_column_id).getValue();
            if (type_id != '') {
                xml_grid = xml_grid + '<GridRow ';
                static_data_privilege.static_data_privilege.forEachCell(id, function (cellObj, ind) {
                    grid_index = static_data_privilege.static_data_privilege.getColumnId(ind);
                    value = escapeXML(cellObj.getValue(ind));   
                    if (grid_index != 'action' && grid_index != 'disabled') {
                        xml_grid = xml_grid + grid_index + '="' + value  + '" ';
                    }	
                })
                xml_grid = xml_grid + '></GridRow>';
            }
        });
        xml_grid = xml_grid + '</gridXml>';
        
        var data = {
                        'action' : 'spa_static_data_privilege',
                        'flag' : 'i',
                        'xml_data' : xml_grid
                    };
        adiha_post_data('return_array', data, '', '', 'static_data_privilege.save_static_data_privilege_callback', '', '');
    }
    
    static_data_privilege.save_static_data_privilege_callback = function (return_value) {
        if (return_value[0][0] == 'Success') {
            sucess_call(return_value[0][4]);
            setTimeout('close_window()', 1000)
        } else {
            show_messagebox(return_value[0][4]);
            return;
        } 
    }
    
    function close_window() {
         var win_obj = parent.static_data_privilege.window("w2");
         var namespace = '<?php echo get_sanitized_value($_GET['namespace']); ?>';
         var callback = '<?php echo get_sanitized_value($_GET['callback']); ?>';
         
         if(callback == '')
            eval("parent." + namespace + ".refresh_grid('', parent." + namespace + ".enable_menu_item)");
         else
            eval("parent." + namespace + ".refresh_grid('', parent." + callback + ")");
         
         win_obj.close();
    }
    
    function context_menu_privilege_click(menu_id, type) {
        var data = static_data_privilege.static_data_privilege.contextID.split('_');
        var column_id = data[3];
        var row_id = static_data_privilege.static_data_privilege.getSelectedRowId();
        
        var enable_disable_id = static_data_privilege.static_data_privilege.getColIndexById('code');
        var user_column_id = static_data_privilege.static_data_privilege.getColIndexById('user');
        var user_name_column_id = static_data_privilege.static_data_privilege.getColIndexById('user_name'); 
        var role_column_id = static_data_privilege.static_data_privilege.getColIndexById('role');
        var enable_disable = static_data_privilege.static_data_privilege.cells(row_id, enable_disable_id).getValue();

        
        if (column_id == user_column_id) {
             var to_update_value = static_data_privilege.static_data_privilege.cells(row_id, user_column_id).getValue();
        } else if (column_id == role_column_id) {
             var to_update_value = static_data_privilege.static_data_privilege.cells(row_id, role_column_id).getValue();
        } else if (column_id == user_name_column_id)  {
             var to_update_value = static_data_privilege.static_data_privilege.cells(row_id, user_name_column_id).getValue();
             var to_update_value_user = static_data_privilege.static_data_privilege.cells(row_id, user_column_id).getValue(); 
         } 
         else {
            return;
        }
        
        static_data_privilege.static_data_privilege.forEachRow(function (id) {
            var enable_disable_id = static_data_privilege.static_data_privilege.getColIndexById('code');
            var enable_disable_compare = static_data_privilege.static_data_privilege.cells(id, enable_disable_id).getValue();
            var level = static_data_privilege.static_data_privilege.getLevel(id);

            if(level != 0 && enable_disable_compare == enable_disable) {
                static_data_privilege.static_data_privilege.cells(id, column_id).setValue(to_update_value); 
                static_data_privilege.static_data_privilege.cells(id, user_column_id).setValue(to_update_value_user); 
            }
        });
        
    }
    
    static_data_privilege.refresh_grid_static_data_privilege = function() {
        var value_id = '<?php echo get_sanitized_value($_GET['value_id']); ?>';
        var type_id = '<?php echo get_sanitized_value($_GET['type_id']); ?>';
        var call_from = '<?php echo isset($_GET['call_from']) ? get_sanitized_value($_GET['call_from']) : 0; ?>';
        var sql_param = {
                            'action' : 'spa_static_data_privilege',
                            'flag' : 's',
                            'grid_type' : 'tg',
                            'value_id' : value_id,
                            'type_id' : type_id, 
                            'call_from' : call_from,
                            'grouping_column': 'code,disabled'
                        };

        sql_param = $.param(sql_param);
        var sql_url = js_data_collector_url + "&" + sql_param;
 
		static_data_privilege.static_data_privilege.clearAndLoad(sql_url, function() {
 
		}); 
    }
    
    var static_data_privilege_win;
    
    function unload_static_data_privilege_window() {        
        if (static_data_privilege_win != null && static_data_privilege_win.unload != null) {
            static_data_privilege_win.unload();
            static_data_privilege_win = w2 = null;
        }
    }
    
    function open_user_role_window(selected_row) {
        setTimeout(function(){
            var selected_row = static_data_privilege.static_data_privilege.getSelectedRowId();
            var user = static_data_privilege.static_data_privilege.cells(selected_row, static_data_privilege.static_data_privilege.getColIndexById('user')).getValue(); 
            var role = static_data_privilege.static_data_privilege.cells(selected_row, static_data_privilege.static_data_privilege.getColIndexById('role')).getValue(); 
            
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
    
    function add_edit_privilege(selected_row) {
        open_user_role_window(selected_row);
    }
    
    function user_role_callback(val_from_to, val_role_to, selected_row,user_name) {
        static_data_privilege.static_data_privilege.cells(selected_row, static_data_privilege.static_data_privilege.getColIndexById('user')).setValue(val_from_to); 
        static_data_privilege.static_data_privilege.cells(selected_row, static_data_privilege.static_data_privilege.getColIndexById('role')).setValue(val_role_to); 
        static_data_privilege.static_data_privilege.cells(selected_row, static_data_privilege.static_data_privilege.getColIndexById('role_id')).setValue(val_role_to); 
		static_data_privilege.static_data_privilege.cells(selected_row, static_data_privilege.static_data_privilege.getColIndexById('user_name')).setValue(user_name); 
    
    }
</script>
 
</html>

