<?php
/**
* Template mapping privilege detail screen
* @copyright Pioneer Solutions
*/
?>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
        <?php require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
    </head>

    <body>
        <?php
            $form_namespace = 'deal_template_privilege';
            $layout_name = 'layout';
            $grid_menu_name = 'grid_menu';
            $grid_context_menu_name = 'grid_context_menu';
            $grid_name = 'grid';

            // Get Template ID (deal_template_id) passed from Parent Window.
            $template_id = get_sanitized_value($_GET["deal_template_id"] ?? '', 'string');

            $layout_json = '[{id: "a", header: false}]';

            $layout_obj = new AdihaLayout();
            echo $layout_obj->init_layout($layout_name, '', '1C', $layout_json, $form_namespace);
            
            $menu_json = '[
                {id: "refresh", text: "Refresh", img: "refresh.gif", img_disabled: "refresh_dis.gif"},
                {id: "save", text: "Save", img: "save.gif", img_disabled: "save_dis.gif", disabled: true},
                {id: "edit", text: "Edit", img: "edit.gif", img_disabled: "edit_dis.gif", items: [
                    {id: "add", text: "Add", img: "add.gif", img_disabled: "add_dis.gif", disabled: true},
                    {id: "delete", text: "Delete", disabled: true, img: "delete.gif", img_disabled: "delete_dis.gif"}
                ]},
                {id: "t2", text: "Export", img: "export.gif", items: [
                    {id: "excel", text: "Excel", img: "excel.gif", imgdis: "excel_dis.gif", title: "Excel"},
                    {id: "pdf", text: "PDF", img: "pdf.gif", imgdis: "pdf_dis.gif", title: "PDF"}
                ]}
            ]';

            $grid_menu = new AdihaMenu();
            echo $layout_obj->attach_menu_cell($grid_menu_name, 'a');
            echo $grid_menu->init_by_attach($grid_menu_name, $form_namespace);
            echo $grid_menu->load_menu($menu_json);
            echo $grid_menu->attach_event('', 'onClick', $form_namespace . '.grid_menu_click');

            $context_menu_json = '[
                {id: "a1", text: "Apply to all rows"},
                {id: "a2", text: "Apply to preceding rows"},
                {id: "a3", text: "Apply to succeeding rows"}
            ]';

            $context_menu = new AdihaMenu();
            echo $context_menu->init_menu($grid_context_menu_name, $form_namespace);
            echo $context_menu->render_as_context_menu();
            echo $context_menu->load_menu($context_menu_json);
            echo $context_menu->attach_event('', 'onClick', $form_namespace . '.context_menu_click');

            // Attach Grid in cell 'a' and attach footer of grid.
            echo $layout_obj->attach_grid_cell('grid', 'a');
            echo $layout_obj->attach_status_bar("a", true);

            $template_privilege = new GridTable('TemplatePrivilege');
            echo $template_privilege->init_grid_table('grid', $form_namespace, 'n');
            echo $template_privilege->set_column_auto_size();
            echo $template_privilege->set_search_filter(true, "");
            echo $template_privilege->enable_paging(100, 'pagingArea_a', 'true');
            echo $template_privilege->return_init();
            // echo $template_privilege->load_grid_functions();

            // Events for Grid Actions
            echo $template_privilege->attach_event('', 'onEditCell', $form_namespace . '.grid_edit');
            echo $template_privilege->attach_event('', 'onSelectStateChanged', $form_namespace . '.grid_select');
            echo $template_privilege->attach_event("", "onRowDblClicked", $form_namespace . '.open_popup');
            echo $template_privilege->attach_event("", "onXLE", $form_namespace . '.data_loaded');
            // Events for Context Menu on Grid
            echo $template_privilege->enable_context_menu($form_namespace . '.grid_context_menu');
            echo $template_privilege->attach_event("", "onBeforeContextMenu", $form_namespace . '.pre_context_menu');
            
            // Load data in grid
            $sp_grid = "EXEC spa_template_mapping_privilege @flag='s', @template_id_list='" . $template_id . "'";
            echo $template_privilege->load_grid_data($sp_grid);

            echo $layout_obj->close_layout();
        ?>

        <script type="text/javascript">
            var template_id = "<?php echo $template_id;?>";
            var is_row_deleted = false;
            var deleted_privileges = [];

            $(function() {
                deal_template_privilege.grid.enableEditEvents(true,false,true);
                
                // Event Attached Before the Row is Deleted, So that the ID that the deleted ID is pushed into Array, which can be later used in sending request for deletion.
                deal_template_privilege.grid.attachEvent("onBeforeRowDeleted", function(id) {
                    var mapping_id_index = deal_template_privilege.grid.getColIndexById('template_mapping_id');
                    var mapping_id = deal_template_privilege.grid.cells(id, mapping_id_index).getValue();
                    deleted_privileges.push(mapping_id);
                    deal_template_privilege.grid_menu.setItemEnabled('save');
                });
            });

            var static_data_privilege_win;
            
            /**
            * [open_popup Open popup to assign privilege]
            * @param  {[String]} row_id   [Id of the row that is selected.]
            * @param  {[Int]} col_index   [Index of Column from where the Double Click action is performed.]
            */
            deal_template_privilege.open_popup = function(row_id, col_index) {
                var user_index = deal_template_privilege.grid.getColIndexById('user_id');
                var user_id = deal_template_privilege.grid.cells(row_id, user_index).getValue();
                var role_name_index = deal_template_privilege.grid.getColIndexById('role_name');
                var role = deal_template_privilege.grid.cells(row_id, role_name_index).getValue();

                if (deal_template_privilege.grid.getParentId(row_id) == 0) {
                    return false;
                }

                if (col_index == user_index || col_index == role_name_index) {
                    unload_static_data_privilege_window();
                    
                    if (!static_data_privilege_win) {
                        static_data_privilege_win = new dhtmlXWindows();
                    }
                    
                    var post_params = {
                        user: user_id,
                        role: role,
                        selected_row: row_id
                    };

                    var url = app_form_path + '_setup/maintain_static_data/maintain.static.data.privileges.php';

                    var new_win = static_data_privilege_win.createWindow('w2', 0, 0, 680, 380);
                    new_win.setText("Privilege");  
                    new_win.centerOnScreen();
                    new_win.setModal(true); 
                    new_win.attachURL(url, false, post_params); 
                } else {
                    return;
                }
            }

            function unload_static_data_privilege_window() {
                if (static_data_privilege_win != null && static_data_privilege_win.unload != null) {
                    static_data_privilege_win.unload();
                    static_data_privilege_win = w2 = null;
                }
            }

            /**
            * [user_role_callback Defines what to do after the user and role is selected to give privilege.]
            * @param  {[String]} val_from_to  [Users List for specific Template.]
            * @param  {[String]} val_role_to  [Roles List for specific Template.]
            * @param  {[String]} selected_row [Selected Row which contains specific Template Privilege Detail.]
            * @return [Sets users & roles name on selected column of Grid and Save is enabled.]
            */
            function user_role_callback(val_from_to, val_role_to, selected_row) {
                var user_index = deal_template_privilege.grid.getColIndexById('user_id');
                var role_index = deal_template_privilege.grid.getColIndexById('role_name');

                deal_template_privilege.grid.cells(selected_row, user_index).setValue(val_from_to);
                deal_template_privilege.grid.cells(selected_row, user_index).cell.wasChanged = true;
                deal_template_privilege.grid.cells(selected_row, role_index).setValue(val_role_to);
                deal_template_privilege.grid.cells(selected_row, role_index).cell.wasChanged = true;
                deal_template_privilege.grid_menu.setItemEnabled('save');
            }

            /**
            * [data_loaded Expand all the group after data is loaded.]
            */
            deal_template_privilege.data_loaded = function() {
                deal_template_privilege.grid.expandAll();
            }

            /**
            * [save_privilege Save privilege for template as defined on grid.]
            */
            deal_template_privilege.save_privilege = function() {
                if (is_row_deleted) {
                    confirm_messagebox("Some data has been deleted from grid. Are you sure you want to save?",function() {
                        deal_template_privilege.save_privilege_confirm();
                    }, function() {
                        parent.templateMapping.enable_save_menu();
                        deal_template_privilege.refresh_grid();
                    });
                } else {
                    deal_template_privilege.save_privilege_confirm();
                }
                is_row_deleted = false;
            }

            /**
            * [save_privilege_confirm Confirmed Save]
            */
            deal_template_privilege.save_privilege_confirm = function() {
                var xml_grid = '<GridXml>';
                var changed_rows = deal_template_privilege.grid.getChangedRows();
                changed_rows = changed_rows.split(',');
                
                // If there are no rows changed.
                if (changed_rows.toString() !== '') {
                    changed_rows.forEach(function(id) {
                        xml_grid = xml_grid + '<GridRow ';
                        var row_parent_id = deal_template_privilege.grid.getParentId(id);
                        var template_name_index = deal_template_privilege.grid.getColIndexById('template_name');
                        var template_name = deal_template_privilege.grid.cells(row_parent_id, template_name_index).getValue();

                        deal_template_privilege.grid.forEachCell(id, function (cellObj, ind) {
                            var column_id = deal_template_privilege.grid.getColumnId(ind);
                            value = cellObj.getValue(ind);
                            
                            if (column_id == 'template_name') {
                                xml_grid = xml_grid + column_id + '="' + template_name  + '" ';
                            } else {
                                xml_grid = xml_grid + column_id + '="' + value  + '" ';
                            }
                        });

                        xml_grid = xml_grid + '></GridRow>';
                    });
                }

                xml_grid = xml_grid + '</GridXml>';
                var deleted_rows = deleted_privileges.toString();
                
                var data = {
                    'action' : 'spa_template_mapping_privilege',
                    'flag' : 'y',
                    'xml_data' : xml_grid,
                    'deleted_ids' : deleted_rows
                };

                adiha_post_data('alert', data, '', '', 'deal_template_privilege.save_callback', '', '');
            }

            /**
            * [save_callback Describes what to do after save action is completed.]
            */
            deal_template_privilege.save_callback = function(result){
                if (result[0].errorcode == 'Success') {
                    deal_template_privilege.refresh_grid();
                }
            }

            /**
            * [pre_context_menu Pre context menu show function - used to hide context menu other than user and role column]
            * @param  {[String]} rowId     [ID of the row that is selected.]
            * @param  {[Int]} cInd         [Column Index of the Grid on which cell the right click is done.]
            * @param  {[Object]} grid      [Grid Object on which the context menu is displayed.]
            */
            deal_template_privilege.pre_context_menu = function(rowId, cInd, grid) {
                var user_index = deal_template_privilege.grid.getColIndexById('user_id');
                var role_index = deal_template_privilege.grid.getColIndexById('role_name');

                if (cInd == user_index || role_index == cInd){
                    return true;
                }
                
                return false;
            }

            /**
            * [context_menu_click Contect menu on click function]
            * @param  {[String]} id    [Menu Id]
            * @param  {[type]} type    [Menu Type]
            */
            deal_template_privilege.context_menu_click = function(id, type) {
                var context_data = deal_template_privilege.grid.contextID.split("_");
                var selected_row_id = deal_template_privilege.grid.getSelectedRowId();
                var row_index = deal_template_privilege.grid.getRowIndex(selected_row_id);
                var deal_type_idx = deal_template_privilege.grid.getColIndexById('deal_type_id');
                var selected_cell_idx = context_data[context_data.length - 1];
                var row_num = deal_template_privilege.grid.getRowsNum();
                
                // If total rows number is less than 2 then cancel.
                if (row_num < 2) {
                    return false;
                }

                if (row_index == -1) {
                    return false;
                }

                var column_value = deal_template_privilege.grid.cells2(row_index, selected_cell_idx).getValue();
                
                for (var i = 0; i < row_num; i++) {
                    var row_id = deal_template_privilege.grid.getRowId(i);
                    var is_parent = deal_template_privilege.grid.hasChildren(row_id);
                    var is_valid_row = deal_template_privilege.grid.cells2(i, deal_type_idx).getValue();
                    
                    // Exclude Parent Rows.
                    if (is_parent == 0) {
                        if ((id == 'a1' && i != row_index)
                            || (id == 'a2' && i < row_index)
                            || (id == 'a3' && i > row_index)
                        ) {
                            deal_template_privilege.grid.cells2(i, selected_cell_idx).setValue('');
                            deal_template_privilege.grid.cells2(i, selected_cell_idx).setValue(column_value);
                            deal_template_privilege.grid.cells2(i, selected_cell_idx).cell.wasChanged = true;
                            deal_template_privilege.grid_menu.setItemEnabled('save');
                        }
                    }
                }

                return true;
            }

            /**
            * [grid_select Grid select state change callback]
            * @param  {[type]} ids  [Row Ids]
            * @param  {[type]} inds [Row Index]
            */
            deal_template_privilege.grid_select = function(ids, inds) {
                var parent_id = deal_template_privilege.grid.getParentId(ids);
                
                if (parent_id != 0 && parent_id != null) {
                    deal_template_privilege.grid_menu.setItemDisabled('add');
                    deal_template_privilege.grid_menu.setItemEnabled('delete');
                } else {
                    deal_template_privilege.grid_menu.setItemEnabled('add');
                    deal_template_privilege.grid_menu.setItemDisabled('delete');
                }
            }

            /**
            * [grid_edit Grid Edit callback]
            * @param  {[Int]} stage       [Edit state]
            * @param  {[String]} rId      [Row Id of Grid which is edited.]
            * @param  {[Int]} cInd        [Column Index of Grid Cell where the value is changed]
            * @param  {[String]} nValue   [New Value after the cell value is changed.]
            * @param  {[String]} oValue   [Old Value before changing the new value.]
            */
            deal_template_privilege.grid_edit = function(stage, rId, cInd, nValue, oValue) {
                var template_index = deal_template_privilege.grid.getColIndexById('template_name');

                if (deal_template_privilege.grid.getParentId(rId) == 0) {
                    return false;
                }

                if (cInd == template_index) {
                    return false;
                }

                // Enable save only if the value is changed in a grid.
                if (nValue !== oValue) {
                    deal_template_privilege.grid_menu.setItemEnabled('save');
                }

                return true;
            }

            /**
            * [refresh_grid Refresh the Grid.]
            */
            deal_template_privilege.refresh_grid = function() {
                // Clear deleted rows.
                deleted_privileges = [];
                deal_template_privilege.grid_menu.setItemDisabled('delete');
                deal_template_privilege.grid_menu.setItemDisabled('save');
                var sql = "EXEC spa_template_mapping_privilege @flag = 's', @template_id_list = '" + template_id + "'";
                
                var sql_param = {
                    "sql" : sql,
                    "grid_type" : "tg",
                    "grouping_column" : "template_name,template_description"
                };

                sql_param = $.param(sql_param);
                var sql_url = js_data_collector_url + "&" + sql_param;

                deal_template_privilege.grid.clearAll();

                deal_template_privilege.grid.load(sql_url, function() {
                    deal_template_privilege.grid.expandAll();
                    deal_template_privilege.layout.cells("a").progressOff();
                });
            }

            /**
            * [add_row_in_template Add Row in the template where the row is selected.]
            */
            deal_template_privilege.add_row_in_template = function() {
                var parent_id = deal_template_privilege.grid.getSelectedRowId();
                var row_id = (new Date()).valueOf();
                deal_template_privilege.grid.addRow(row_id, [null], null, parent_id);
                deal_template_privilege.grid.selectRowById(row_id);
            }

            /**
            * [grid_menu_click Describes what to do after the menu on top of grid is clicked.]
            * @param  {[String]} id [ID of the menu that is clicked.]
            */
            deal_template_privilege.grid_menu_click = function(id) {
                switch (id) {
                    case "refresh":
                        deal_template_privilege.layout.cells("a").progressOn();
                        var changed_rows = deal_template_privilege.grid.getChangedRows(true);
                        
                        if (changed_rows != '') {
                            confirm_messagebox("There are unsaved changes. Are you sure you want to refresh grid?", function() {
                                deal_template_privilege.refresh_grid();
                            }, function() {
                                deal_template_privilege.layout.cells("a").progressOff();
                            });
                        } else {
                            deal_template_privilege.refresh_grid();
                        }
                        
                        break;
                    case "add":
                        deal_template_privilege.add_row_in_template();
                        break;
                    case "delete":
                        deal_template_privilege.grid.deleteSelectedRows();
                        is_row_deleted = true;
                        break;
                    case "excel":
                        deal_template_privilege.grid.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                        break;
                    case "pdf":
                        deal_template_privilege.grid.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                        break;
                    case "save":
                        deal_template_privilege.save_privilege();
                        break;
                }
            }
        </script>
    </body>
</html>