<?php
/**
* Stmt setup account code mapping screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge, chrome=1"/>
    <?php require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
<?php
    $function_id = 20011500; //function id for account code mapping
    $form_namespace = 'stmt_account_code_mapping';
    $form_obj = new AdihaStandardForm($form_namespace, $function_id);
    $form_obj->define_grid('account_code_mapping_grid');
    $form_obj->define_layout_width(400);
    $form_obj->define_custom_functions('','','','on_load_completed', 'before_save_validation');
    echo $form_obj->init_form('Account Code Mapping', 'Account Code Mapping Detail', '');
    echo $form_obj->close_form();
?>
<body>
    <script type="text/javascript"> 
        
        var grid_obj_b = [];
        var grid_obj_c = []; 
        var stmt_account_code_mapping_id;

        stmt_account_code_mapping.on_load_completed = function(win, id) {
            var object_id = (id.indexOf('tab_') != -1) ? id.replace('tab_', '') : id;           
            object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(' ', ''));
            var tab_obj = win.tabbar[object_id];
            var detail_tabs = tab_obj.getAllTabs(); 

            $.each(detail_tabs, function(index, value) {
                layout_obj = tab_obj.cells(value).getAttachedObject();
                var attached_menu_b;
                var attached_menu_c;
                var chargetype_value;
                var gl_grid_obj;

                layout_obj.forEachItem(function(cell) {  
                    if (cell.getId() == 'a') {
                        attached_obj = cell.getAttachedObject();
                        if (attached_obj instanceof dhtmlXForm) {
                            stmt_account_code_mapping_id = attached_obj.getItemValue('stmt_account_code_mapping_id'); 
                            gl_grid_obj = 'stmt_account_code_gl_' + stmt_account_code_mapping_id; 
                        }
                    }

                    if (cell.getId() == 'c') {
                        attached_obj = cell.getAttachedObject();
                        attached_menu_c = cell.getAttachedMenu();
                        attached_menu_c.setItemDisabled('add');   
                        if (attached_obj instanceof dhtmlXGridObject) {
                            grid_obj_c[id] = attached_obj;
                            grid_obj_c[id].attachEvent('onXLE', function() {
                                var row_id_b = grid_obj_b[id].getSelectedRowId();
                                if (row_id_b == null) {
                                    grid_obj_c[id].clearAll();
                                    grid_obj_c[id].setUserData('', 'grid_id', 'stmt_account_code_gl'); 
                                    grid_obj_c[id].setUserData('', 'grid_obj', gl_grid_obj); 
                                    grid_obj_c[id].setUserData('', 'grid_label', 'Account Code GL');
                                }
                            });
                        }
                        attached_obj.attachEvent('onRowAdded', function(rId) {
                            var acc_code_chargetype_index = grid_obj_c[id].getColIndexById('stmt_account_code_chargetype_id');
                            grid_obj_c[id].cells(rId, acc_code_chargetype_index).setValue(chargetype_value);
                        });
                    }

                    if(cell.getId() == 'b') {
                        attached_obj = cell.getAttachedObject();
                        if (attached_obj instanceof dhtmlXGridObject) {
                            grid_obj_b[id] = attached_obj;
                            attached_obj.attachEvent("onSelectStateChanged", function(rs_ind) {
                                var acc_code_chargetype_index = grid_obj_b[id].getColIndexById('stmt_account_code_chargetype_id');
                                chargetype_value = grid_obj_b[id].cells(rs_ind, acc_code_chargetype_index).getValue();

                                var load_grid_sql = "EXEC spa_stmt_account_code_mapping @flag = 'gl_grid', @acc_code_chargetype_id = " + chargetype_value + " ";
                                var sql_param = {'sql' : load_grid_sql};
                                sql_param = $.param(sql_param);
                                var sql_url = js_data_collector_url + "&" + sql_param;
                                //Load values on  Grid
                                layout_obj.progressOn();
                                grid_obj_c[id].clearAndLoad(sql_url, function() {
                                    grid_obj_c[id].setUserData('', 'grid_id', 'stmt_account_code_gl'); 
                                    grid_obj_c[id].setUserData('', 'grid_obj', gl_grid_obj); 
                                    grid_obj_c[id].setUserData('', 'grid_label', 'Account Code GL'); 
                                    layout_obj.progressOff();
                                });
                                if (chargetype_value) {
                                    attached_menu_c.setItemEnabled('add');
                                } else {
                                    attached_menu_c.setItemDisabled('add');
                                }
                            });
                        }
                    }                    
                });
            });
        }

        stmt_account_code_mapping.before_save_validation = function(win, id) {
            var object_id = stmt_account_code_mapping.tabbar.getActiveTab();
            var object_id = (object_id.indexOf('tab_') != -1) ? object_id.replace('tab_', '') : object_id;     
            
            var tab_id = stmt_account_code_mapping.tabbar.getActiveTab();
            var tab_obj = stmt_account_code_mapping.tabbar.cells(tab_id).getAttachedObject()
            ;
            var detail_tabs = tab_obj.getAllTabs(); 
            var grid_b_status_empty = true;
            var grid_c_status_empty = true;

            $.each(detail_tabs, function(index, value) {
                layout_obj = tab_obj.cells(value).getAttachedObject();

                layout_obj.forEachItem(function(cell) {  
                    if (cell.getId() == 'b') {
                        attached_obj = cell.getAttachedObject(); 
                        if (attached_obj instanceof dhtmlXGridObject) {
                            var ids = attached_obj.getChangedRows(true);
                            if(ids != "") {
                                var changed_ids = new Array();
                                changed_ids = ids.split(",");
                                var column_number = attached_obj.getColumnsNum();
                                $.each(changed_ids, function(index, value) {
                                    var a = '';
                                    for(var cellIndex = 0; cellIndex < attached_obj.getColumnsNum(); cellIndex++) {
                                        b = attached_obj.cells(value,cellIndex).getValue();
                                        a = a + b ;
                                    }
                                    if(a == '') {
                                        grid_b_status_empty = false;
                                    }
                                });
                            }
                        }
                    }

                    if (cell.getId() == 'c') {
                        attached_obj = cell.getAttachedObject(); 
                        if (attached_obj instanceof dhtmlXGridObject) {
                            var ids = attached_obj.getChangedRows(true);
                            if(ids != "") {
                                var changed_ids = new Array();
                                changed_ids = ids.split(",");
                                var column_number = attached_obj.getColumnsNum();
                                $.each(changed_ids, function(index, value) {
                                    var a = '';
                                    for(var cellIndex = 0; cellIndex < attached_obj.getColumnsNum(); cellIndex++) {
                                        if (attached_obj.getColumnId(cellIndex) !== 'stmt_account_code_chargetype_id')
                                            b = attached_obj.cells(value,cellIndex).getValue();
                                        a = a + b ;
                                    }
                                    if(a == '') {
                                        grid_c_status_empty = false;
                                    }
                                });
                            }
                        }
                    }                  
                });
            });

            if(!grid_b_status_empty) {
                show_messagebox("All field cannot be blank in Account Code Charge Type grid.");
                return 0;
            }
            
            if(!grid_c_status_empty) {
                show_messagebox("All field cannot be blank in Account Code GL grid.");
                return 0;
            }
        }
    </script>
</body>
</html>