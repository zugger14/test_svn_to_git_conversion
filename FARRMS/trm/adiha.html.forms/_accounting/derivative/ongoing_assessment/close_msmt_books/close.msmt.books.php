<?php
/**
* Close measurement books screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
    <head>
        <meta charset='UTF-8' />
        <meta name='viewport' content='width=device-width, initial-scale=1.0' />
        <meta http-equiv='X-UA-Compatible' content='IE=edge,chrome=1' />
    </head>

    <body>
        <?php
            include '../../../../../adiha.php.scripts/components/include.file.v3.php';
            
            $form_cell_json = "[
                {
                    id: 'a',
                    width: 240,
                    height: 200,
                    header: false
                }
            ]";

            $rights_closing_account = 10237500; 
            $rights_add_save = 10237510;
            $rights_delete = 10237511;
            
            list (
                $has_rights_add_save,
                $has_rights_delete
            ) = build_security_rights(
                $rights_add_save,
                $rights_delete
            );
            
            $form_layout = new AdihaLayout();
            $layout_name = 'layout_closing_account';
            $form_name_space = 'form_closing_account';
            echo $form_layout->init_layout($layout_name, '', '1C', $form_cell_json, $form_name_space);
            
            //Attaching Run Toolbar
            $toolbar_save_json = '[
                {id:"save", type:"button", text:"Save", img:"save.gif", imgdis:"save_dis.gif", enabled:"'.$has_rights_add_save.'"}
            ]';

            $toolbar_save = new AdihaToolbar();
            echo $form_layout->attach_toolbar('toolbar_save');
            echo $toolbar_save->init_by_attach('toolbar_save', $form_name_space);
            echo $toolbar_save->load_toolbar($toolbar_save_json);
            echo $toolbar_save->attach_event('', 'onClick', 'btn_save_click');
            
            //Attaching Grid Toolbar
            $menu_closing_date = new AdihaMenu();
            
            $menu_closing_date_json = '[
                {id: "refresh", text: "Refresh", img: "refresh.gif", imgdis: "refresh_dis.gif", title: "Refresh"},
                {id: "t2", text: "Edit", img: "edit.gif", items: [
                    {id: "add", img: "add.gif", imgdis:"add_dis.gif", text: "Add", title: "Add", enabled: "'.$has_rights_add_save.'"},
                    {id: "delete", text: "Delete", img: "trash.gif", imgdis: "trash_dis.gif", title: "Delete", enabled: 0}
                ]},
                {id: "t1", text: "Export", img: "export.gif", items: [
                    {id: "excel", text: "Excel", img: "excel.gif", imgdis: "excel_dis.gif", title: "Excel"},
                    {id: "pdf", text: "PDF", img: "pdf.gif", imgdis: "pdf_dis.gif", title: "PDF"}
                ]}
            ]';

            echo $form_layout->attach_menu_cell('menu_closing_account', 'a');
            echo $menu_closing_date->init_by_attach('menu_closing_account', $form_name_space);
            echo $menu_closing_date->load_menu($menu_closing_date_json);
            echo $menu_closing_date->attach_event('', 'onClick', 'menu_closing_date_click');
            
            //Attaching Grid 
            $grid_closing_account = new AdihaGrid();
            $grid_name = 'CloseMeasurementBooks';

            echo $form_layout->attach_grid_cell($grid_name, 'a');

            $grid_closing_account = new GridTable($grid_name);
            echo $form_layout->attach_status_bar("a", true);
            echo $grid_closing_account->init_grid_table($grid_name, $form_name_space);
            echo $grid_closing_account->set_search_filter(true);
            echo $grid_closing_account->split_grid(0);
            echo $grid_closing_account->return_init();
            echo $grid_closing_account->load_grid_data('', '', '', '');
            echo $grid_closing_account->attach_event('', 'onSelectStateChanged', 'CloseMeasurementBooks_click');
            echo $grid_closing_account->load_grid_functions();
            echo $grid_closing_account->enable_paging(25, 'pagingArea_a', 'true');
            echo $grid_closing_account->enable_multi_select();

            echo $form_layout->close_layout();
        ?>

        <script type="text/javascript">
            var has_rights_delete = Boolean('<?php echo $has_rights_delete; ?>');
            var rights_closing_account = '<?php echo $rights_closing_account; ?>';

            function menu_closing_date_click(args) {
                switch(args) {
                    case 'refresh':
                        form_closing_account.refresh_grid();
                        break;
                    case 'excel':
                        path = js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php';
                        form_closing_account.CloseMeasurementBooks.toExcel(path);
                        break;
                    case 'pdf':
                        path = js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php';
                        form_closing_account.CloseMeasurementBooks.toPDF(path);
                        break;
                    case 'delete':
                        var grid_obj = form_closing_account.CloseMeasurementBooks;
                        var del_ids = grid_obj.getSelectedRowId();
                        var previously_xml = grid_obj.getUserData("", "deleted_xml");
                        var grid_xml = "";

                        if (previously_xml != null) {
                            grid_xml += previously_xml
                        }

                        var del_array = new Array();
                        del_array = (del_ids.indexOf(",") != -1) ? del_ids.split(",") : del_ids.split();

                        $.each(del_array, function(index, value) {
                            if ((grid_obj.cells(value,0).getValue() != "") || (grid_obj.getUserData(value, "row_status") != "")) {
                                grid_xml += "<GridRow ";
                                
                                for(var cellIndex = 0; cellIndex < grid_obj.getColumnsNum(); cellIndex++) {
                                    grid_xml += " " + grid_obj.getColumnId(cellIndex) + '="' + grid_obj.cells(value,cellIndex).getValue() + '"';
                                }

                                grid_xml += " ></GridRow> ";
                            }
                        });

                        grid_obj.setUserData("", "deleted_xml", grid_xml);
                        grid_obj.deleteSelectedRows();
                        break;
                    case 'add':
                        var new_id = (new Date()).valueOf();
                        form_closing_account.CloseMeasurementBooks.addRow(new_id, '');
                        form_closing_account.CloseMeasurementBooks.selectRowById(new_id);

                        form_closing_account.CloseMeasurementBooks.forEachRow(function(row) {
                            form_closing_account.CloseMeasurementBooks.forEachCell(row, function(cellObj, ind) {
                                form_closing_account.CloseMeasurementBooks.validateCell(row, ind);
                            });
                        });
                        break;
                }
            }
            
            function CloseMeasurementBooks_click() {
                var selected_id = form_closing_account.CloseMeasurementBooks.getSelectedRowId();

                if (selected_id != '' && selected_id != null && has_rights_delete == true) {
                    form_closing_account.menu_closing_account.setItemEnabled('delete');
                } else {
                    form_closing_account.menu_closing_account.setItemDisabled('delete');
                }
            }

            function btn_save_click() {
                var grid_xml = "<GridGroup>";
                var changed_ids = new Array();
                var grid_obj = form_closing_account.CloseMeasurementBooks;
                var grid_status = null; // needs to be changed
                
                grid_obj.clearSelection();
                var ids = grid_obj.getAllRowIds();
                var grid_label = "Close Accounting Period";
                var deleted_xml = grid_obj.getUserData("", "deleted_xml");
                
                if (ids != "") {
                    grid_obj.setSerializationLevel(false, false, true, true, true, true);
                    grid_status = form_closing_account.validate_form_grid(grid_obj, grid_label);
                    changed_ids = ids.split(",");
                    
                    if (grid_status) {
                        $.each(changed_ids, function(index, value) {
                            var col_close_date = grid_obj.getColIndexById("close_date");
                            grid_obj.setUserData(value, "row_status", "new row");
                            grid_xml += "<GridRow ";

                            for(var cellIndex = 0; cellIndex < grid_obj.getColumnsNum(); cellIndex++) {
                                if (grid_obj.cells(value, cellIndex).getValue() == 'undefined') { //Cannot use typeof because it returns string
                                    grid_xml += " " + grid_obj.getColumnId(cellIndex) + '= "NULL"';
                                    continue;
                                }

                                if (cellIndex == col_close_date) {
                                    grid_xml += " " + grid_obj.getColumnId(cellIndex) + '="' + (dates.convert_to_sql(grid_obj.cells(value, cellIndex).getValue())) + '"';
                                    continue;
                                }

                                grid_xml += " " + grid_obj.getColumnId(cellIndex) + '="' + (grid_obj.cells(value, cellIndex).getValue()) + '"';
                            }
                            grid_xml += " ></GridRow> ";
                        });
                    }
                }

                grid_xml += "</GridGroup>";
                var xml = "<Root>";
                xml += grid_xml;
                xml += "</Root>";
                xml = xml.replace(/'/g, "\"");

                if (grid_status == false) return;

                if ((deleted_xml == null || deleted_xml == "") && grid_xml == "<GridGroup></GridGroup>") {
                    show_messagebox("At least one row must be Added.");
                    return;
                }
                
                data = {
                    "action": "spa_close_measurement_books_dhx", 
                    "flag": "i", 
                    "xml": xml
                }

                if (deleted_xml != "" && deleted_xml != null) {
                    del_msg =  "Some data has been deleted from " + grid_label + " grid. Are you sure you want to save?";
                    result = adiha_post_data("confirm", data, "", "", "form_closing_account.post_callback", "", del_msg);
                } else {
                    result = adiha_post_data("alert", data, "", "", "form_closing_account.post_callback");
                }

                grid_obj.setUserData("", "deleted_xml", "");
            }

            form_closing_account.post_callback = function(response_data) {
                if (response_data[0].errorcode == 'Success') {
                    form_closing_account.refresh_grid();
                }
            }
        </script>
    </body>
</html>