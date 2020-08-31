<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    </head>
    <body>
        <?php
        require('../../../adiha.php.scripts/components/include.file.v3.php');
        $server_path = $BATCH_FILE_EXPORT_PATH;
        $name_space = 'rm_privilege';
        $selected_row = get_sanitized_value($_GET['selected_row'] ?? 'null');
        $value_id = get_sanitized_value($_GET['value_id'] ?? '');
        $type_id = get_sanitized_value($_GET['type_id'] ?? '');
        $call_from = get_sanitized_value($_GET['call_from'] ?? '0');

        //JSON for Layout
        $layout_json = '[
                     {id:"a", text:"Assign Privileges", header:false, fix_size:[true,true]}
                    
                    ]';
        $menu_json = '[
                    {id:"save", text:"Save", img:"save.gif", imgdis:"save_dis.gif"},
    
                    {id:"export", text:"Export", img:"export.gif", items:[
                        {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                        {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                    ]}
                 ]';

        //Creating Layout
        $rm_privilege_layout = new AdihaLayout();
        echo $rm_privilege_layout->init_layout('layout', '', '1C', $layout_json, $name_space);

        //Attach Menu
        echo $rm_privilege_layout->attach_menu_cell('menu', 'a');

        $rm_privilege_menu = new AdihaMenu();
        echo $rm_privilege_menu->init_by_attach('menu', $name_space);
        echo $rm_privilege_menu->load_menu($menu_json);
        echo $rm_privilege_menu->attach_event('', 'onClick', $name_space . '.menu_click');

        echo $rm_privilege_layout->attach_status_bar('a', false, '<div id="pagingArea_a"></div>');
        // Create Grid
        
        $grid_name = 'rm_privilege_grid';
        echo $rm_privilege_layout->attach_grid_cell($grid_name, 'a');
        $rm_privilege_grid = new GridTable($grid_name);
        echo $rm_privilege_grid->init_grid_table($grid_name, $name_space);
        echo $rm_privilege_grid->set_column_auto_size();
        echo $rm_privilege_grid->set_search_filter(true, "");      
        echo $rm_privilege_grid->enable_column_move();
        echo $rm_privilege_grid->enable_paging(25, 'pagingArea_a');

        echo $rm_privilege_grid->return_init();
        // echo $rm_privilege_grid->load_grid_data();
        echo $rm_privilege_grid->attach_event('', 'onRowDblClicked', $name_space . '.dbclick_grid');
        echo $rm_privilege_grid->attach_event('', 'onRowSelect', $name_space . '.enabled_button');

        echo $rm_privilege_layout->close_layout();
        ?>
    </body>
    <script type="text/javascript">
    rm_privilege = {};
    rm_privilege_grid ={};

    $(function() {
                rm_privilege.load_grid();
        });

    rm_privilege.load_grid = function(){
        var selected_row = '<?php echo $selected_row;?>';
        var value_id = '<?php echo $value_id; ?>';
        var type_id = '<?php echo $type_id; ?>';
        var call_from = '<?php echo $call_from; ?>';
        var param = {
                "flag": "t",
                "action":"spa_excel_addin_report_manager",
                "filename":selected_row,
                "grid_type":"tg",
                "value_id" : value_id,
                "type_id" : type_id, 
                "call_from" : call_from,
                "grouping_column":"file_name,sheet_name"
                };

        param = $.param(param);
        var param_url = js_data_collector_url + "&" + param;
        rm_privilege.rm_privilege_grid.clearAndLoad(param_url, function() {
            //file privilege load
            var data = {"action": "spa_excel_addin_report_manager",
                    "flag": "t",
                    "type_id": type_id,
                    "filename":selected_row,
                    "call_from" : "File"
            };
        var return_json = adiha_post_data('return_json', data, '', '', 'rm_privilege.grid_load_callback');
        });
    }

    rm_privilege.grid_load_callback = function(result){
        var theme_selected = 'dhtmlx_' + default_theme;
        var image_full_path = js_php_path + "components/lib/adiha_dhtmlx/themes/" +   theme_selected + "/imgs/dhxmenu_web/excel.gif";
        rm_privilege.rm_privilege_grid.forEachRow(function(id){
        var level = rm_privilege.rm_privilege_grid.getLevel(id);
        if (level == 0) { 
            rm_privilege.rm_privilege_grid.setItemImage(id, image_full_path);
            rm_privilege.rm_privilege_grid.cells(id, rm_privilege.rm_privilege_grid.getColIndexById('type')).setValue("Edit");
        } else {
            rm_privilege.rm_privilege_grid.cells(id, rm_privilege.rm_privilege_grid.getColIndexById('type')).setValue("View");
        }

        });
        var return_data = JSON.parse(result);
        rm_privilege.rm_privilege_grid.cells(return_data[0].file_name, rm_privilege.rm_privilege_grid.getColIndexById('type_id')).setValue(return_data[0].excel_file_id);
        rm_privilege.rm_privilege_grid.cells(return_data[0].file_name, rm_privilege.rm_privilege_grid.getColIndexById('user')).setValue(return_data[0].user_id);
        rm_privilege.rm_privilege_grid.cells(return_data[0].file_name, rm_privilege.rm_privilege_grid.getColIndexById('role')).setValue(return_data[0].role_id);
        rm_privilege.rm_privilege_grid.loadOpenStates();
        rm_privilege.rm_privilege_grid.expandAll();
    }

    rm_privilege.dbclick_grid = function(id){
        var level = rm_privilege.rm_privilege_grid.getLevel(id);         
        var selected_row = rm_privilege.rm_privilege_grid.getSelectedRowId();     
        rm_privilege.open_user_role_window(selected_row);
    }

    rm_privilege.open_user_role_window = function(selected_row, type_id) {
        setTimeout(function(){
            var user = rm_privilege.rm_privilege_grid.cells(selected_row, rm_privilege.rm_privilege_grid.getColIndexById('user')).getValue(); 
            var role = rm_privilege.rm_privilege_grid.cells(selected_row, rm_privilege.rm_privilege_grid.getColIndexById('role')).getValue(); 
        
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
     
            new_win.setText("Privilege");  
            new_win.centerOnScreen();
            new_win.setModal(true); 
            
            new_win.attachURL(url, false, params); 
        }, 100);
    }

     var static_data_privilege_win;
    
    function unload_static_data_privilege_window() {        
        if (static_data_privilege_win != null && static_data_privilege_win.unload != null) {
            static_data_privilege_win.unload();
            static_data_privilege_win = w2 = null;
        }
    }

    function user_role_callback(val_from_to, val_role_to, selected_row) {
        rm_privilege.rm_privilege_grid.cells(selected_row, rm_privilege.rm_privilege_grid.getColIndexById('user')).setValue(val_from_to); 
        rm_privilege.rm_privilege_grid.cells(selected_row, rm_privilege.rm_privilege_grid.getColIndexById('role')).setValue(val_role_to); 
    }

    rm_privilege.menu_click = function(id) {
        switch (id) {
            case 'excel':
                rm_privilege.rm_privilege_grid.toExcel(js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                break;
            case 'pdf':
                rm_privilege.rm_privilege_grid.toPDF(js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                break;  
            case 'save':
                rm_privilege.save_privilege();
                break;  
        }
    }

    rm_privilege.save_privilege = function(){    
        var xml_grid = '<gridXml>';
        var rowId = rm_privilege.rm_privilege_grid.getSelectedRowId();
        var level = rm_privilege.rm_privilege_grid.getLevel(rowId);
        if (level == 0) {
            var row_index = rm_privilege.rm_privilege_grid.getRowIndex(rowId);     
            var row_id = rm_privilege.rm_privilege_grid.getRowId(row_index+1);
            var file_id = rm_privilege.rm_privilege_grid.cells(row_id,2).getValue();
            rm_privilege.rm_privilege_grid.forEachRow(function (id) {   
                xml_grid = xml_grid + '<GridRow ';
                rm_privilege.rm_privilege_grid.forEachCell(id, function (cellObj, ind) { 
                    grid_index = rm_privilege.rm_privilege_grid.getColumnId(ind);
                    value = cellObj.getValue(ind);
                    rm_privilege.rm_privilege_grid.cells(rowId, rm_privilege.rm_privilege_grid.getColIndexById('type_id')).setValue(file_id);
                    if (grid_index != 'action') {
                        xml_grid = xml_grid + grid_index + '="' + value  + '" ';
                    }
                        
                })  
                xml_grid = xml_grid + '></GridRow>';                      
            });
            
        } else {
            rm_privilege.rm_privilege_grid.forEachRow(function (id) {    
                xml_grid = xml_grid + '<GridRow ';
                rm_privilege.rm_privilege_grid.forEachCell(id, function (cellObj, ind) { 
                    grid_index = rm_privilege.rm_privilege_grid.getColumnId(ind);
                    value = cellObj.getValue(ind);
                    if (grid_index != 'action') {
                        xml_grid = xml_grid + grid_index + '="' + value  + '" ';
                    }
                        
                })  
                xml_grid = xml_grid + '></GridRow>';                      
            });
        }
        xml_grid = xml_grid + '</gridXml>';     
          
        var data = {
                        'action' : 'spa_excel_addin_report_manager',
                        'flag' : 'y',
                        'xml_data' : xml_grid
                    };

        adiha_post_data('return_array', data, '', '', 'rm_privilege.save_privilege_callback', '', '');
    }

    rm_privilege.save_privilege_callback = function(return_value){
        if (return_value[0][0] == 'Success') {
            dhtmlx.message({
                text:return_value[0][4] 
            });
           setTimeout('close_window()', 1000);
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
         var win_obj = parent.rm_window.window("w5");
         win_obj.close();
         parent.rm_excel.excel_file_sheet_grid();        
    }

    </script>
        <style>
            html, body {
                width: 100%;
                height: 100%;
                margin: 0px;
                overflow: hidden;
            }
        </style>
</html>