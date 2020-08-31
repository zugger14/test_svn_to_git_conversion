<?php
/**
* Deal UDT screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
<body>
<?php
    $form_namespace = 'deal_udt';
    $header_detail = get_sanitized_value($_POST["header_detail"]);
    $source_deal_header_id = get_sanitized_value($_POST["source_deal_header_id"]);
    $deal_reference_id = get_sanitized_value($_POST["deal_reference_id"]);
    $term_start = get_sanitized_value($_POST["term_start"]);
    $leg = get_sanitized_value($_POST["leg"]);
    
    $sp_get_udt_details = "EXEC spa_deal_update_new @flag='get_udt_details', @source_deal_header_id=" . $source_deal_header_id . ", @call_from='" . $header_detail . "'";
    $udt_details = readXMLURL2($sp_get_udt_details);
    
    $layout_json = '[{id: "a", header: false}]';
    $layout_obj = new AdihaLayout();
    echo $layout_obj->init_layout('layout', '', '1C', $layout_json, $form_namespace);

    $toolbar_json = '[{id: "save", type: "button", img: "save.gif", imgdis: "save_dis.gif", text: "Save"}]';
    $toolbar_name = 'toolbar';
    $toolbar_obj = new AdihaToolbar();
    echo $layout_obj->attach_toolbar_cell($toolbar_name, 'a');
    echo $toolbar_obj->init_by_attach($toolbar_name, $form_namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', 'toolbar_click');

    $tab_name = 'udt_tab';
    $tab_obj = new AdihaTab();
    echo $layout_obj->attach_tab_cell($tab_name, 'a');
    echo $tab_obj->init_by_attach($tab_name, $form_namespace);
    
    $first_tab = 'true';
    foreach($udt_details as $details) {
        $tab_id = $details['tab_id'];
        $tab_text = $details['tab_name'];
        $grid_name = $details['grid_name'];

        echo $tab_obj->add_tab($tab_id, $tab_text, 'null', 'null', $first_tab);
        echo $tab_obj->set_tab_mode('bottom');
        
        $inner_layout_name = 'inner_layout';
        echo $tab_obj->attach_layout($inner_layout_name, $tab_id, '1C');

        $inner_layout_obj = new AdihaLayout();
        echo $inner_layout_obj->init_by_attach($inner_layout_name, $form_namespace);
        echo $inner_layout_obj->set_text('a', $tab_text);
        echo $inner_layout_obj->attach_status_bar('a', true, '', 'a_' . $tab_id);
        echo $inner_layout_obj->attach_grid_cell($grid_name, 'a');

        $menu_json = '
            [
                {id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif", title: "Refresh"},
                {id:"t1", text:"Edit", img:"edit.gif", imgdis:"new_dis.gif" ,items:[
                        {id:"add", text:"Add", img:"new.gif", enabled:false, imgdis:"new_dis.gif", title:"Add", enabled:true},
                        {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title:"Delete", enabled:false},
                ]},
                {id:"t2", text:"Export", img:"export.gif", items:[
                    {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                    {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                ]}
            ]
        ';
        
        $menu_name = $grid_name . '_menu';
        $menu = new AdihaMenu();
        echo $inner_layout_obj->attach_menu_cell($menu_name, 'a');
        echo $menu->init_by_attach($menu_name, $form_namespace);
        echo $menu->load_menu($menu_json);
        echo $menu->attach_event('', 'onClick', $form_namespace . '.menu_click');

        $grid_obj = new GridTable($grid_name);
        echo $grid_obj->init_grid_table($grid_name, $form_namespace, 'n');
        echo $grid_obj->set_column_auto_size();
        echo $grid_obj->enable_column_move();
        echo $grid_obj->enable_paging(25, 'pagingArea_a_' . $tab_id);
        echo $grid_obj->set_user_data("", "grid_id", $grid_name);
        echo $grid_obj->set_user_data("", "grid_obj", $form_namespace .  '_' . $grid_name);
        echo $grid_obj->set_user_data("", "grid_label", $tab_text);
        echo $grid_obj->return_init();
        echo $grid_obj->set_search_filter(true);
        echo $grid_obj->attach_event('', 'onRowSelect', 'on_row_select');
        if ($header_detail == 'd') {
            echo $grid_obj->attach_event('', 'onXLE', 'on_data_loaded');
        }
        
        $grid_sql = '';
        if ($header_detail == 'd') {
            $grid_sql = $grid_obj->get_grid_load_sql();
            $grid_sql = str_replace("<ID>", "'". $deal_reference_id . "' AND term_start = '" . $term_start . "' AND leg=" . $leg, $grid_sql);
        }

        echo $grid_obj->load_grid_data($grid_sql, $deal_reference_id, false);
        echo $grid_obj->load_grid_functions(true);

        $first_tab = 'false';
    }

    echo $layout_obj->close_layout();
?>
<script>
    var deal_reference_id = '<?php echo $deal_reference_id; ?>';
    var header_detail = '<?php echo $header_detail; ?>';
    var term_start = '<?php echo $term_start ?>';
    var leg = '<?php echo $leg ?>';

    /**
     * Grid Data Load Complete Event Callback
     *
     * @param {Object}  grid_obj    Grid Object
     */
    function on_data_loaded(grid_obj) {
        grid_obj.forEachRow(function(row) {
            var term_start_col_ind = grid_obj.getColIndexById('term_start');
            if (term_start_col_ind) {
                grid_obj.setColumnExcellType(term_start_col_ind, "ro_dhxCalendarA");
            }
            
            var leg_col_ind = grid_obj.getColIndexById('leg');
            if (leg_col_ind) {
                grid_obj.setColumnExcellType(leg_col_ind, "ro");
            }
        });
    }

    /**
     * Grid Row Select Event Callback
     *
     * @param {Integer}  id     Row Id
     * @param {Integer}  ind    Column Index
     */
    function on_row_select(id, ind) {
        var active_tab_id = deal_udt.udt_tab.getActiveTab();
        var menu_obj = deal_udt.udt_tab.tabs(active_tab_id).getAttachedObject().cells('a').getAttachedMenu();
        menu_obj.setItemEnabled('delete');
    }

    /**
     * Grid Menu Item Click
     *
     * @param {String} name    Name of the menu item
     */
    deal_udt.menu_click = function(name) {
        var active_tab_id = deal_udt.udt_tab.getActiveTab();
        var grid_obj = deal_udt.udt_tab.tabs(active_tab_id).getAttachedObject().cells('a').getAttachedObject();

        switch(name) {
            case "add":
                var row_id = (new Date()).valueOf();
                grid_obj.addRow(row_id, "");
                
                if (header_detail == 'd') {
                    var term_start_col_ind = grid_obj.getColIndexById('term_start');
                    if (term_start_col_ind) {
                        grid_obj.cells(row_id, term_start_col_ind).setValue(term_start);
                    }
                    
                    var leg_col_ind = grid_obj.getColIndexById('leg');
                    if (leg_col_ind) {
                        grid_obj.cells(row_id, leg_col_ind).setValue(leg);
                    }
                }

                grid_obj.selectRowById(row_id);
                this.setItemEnabled('delete');
                grid_obj.forEachRow(function(row) {
                    grid_obj.forEachCell(row, function(cellObj, ind) {
                        grid_obj.validateCell(row, ind);
                    });
                });
                break;
            case "delete":
                var row_id = grid_obj.getSelectedRowId();
                var previously_deleted_xml = grid_obj.getUserData("", "deleted_xml");          
                var grid_xml = "";
                if (previously_deleted_xml != null) {
                    grid_xml += previously_deleted_xml;
                }
                var del_array = new Array();
                del_array = (row_id.indexOf(",") != -1) ? row_id.split(",") : row_id.split();
                var total_column = grid_obj.getColumnsNum();
                $.each(del_array, function(index, value) {
                    if ((grid_obj.cells(value, 0).getValue() != "")) {
                        grid_xml += "<GridRow ";
                        for (var cellIndex = 0; cellIndex < total_column; cellIndex++) {
                            grid_xml += " " + grid_obj.getColumnId(cellIndex) + '="' + grid_obj.cells(value, cellIndex).getValue() + '"';
                        }
                        grid_xml += " ></GridRow> ";
                    }
                });
                grid_obj.setUserData("", "deleted_xml", grid_xml);

                grid_obj.deleteRow(row_id);
                
                this.setItemDisabled('delete');
                break;
            case "pdf":
                grid_obj.toPDF(js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                break;
            case "excel":
                grid_obj.toExcel(js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                break;
            case "refresh":
                grid_obj.refresh_grid();
                break;
            default:
                break;
        }
    }

    /**
     * Save Toolbar Click
     */
    function toolbar_click() {
        deal_udt.layout.cells("a").progressOn();
        deal_udt.toolbar.disableItem('save');

        var final_status = true;
        var deleted_xml = "";
        var deleted_grid_name = "";
        var grid_xml = '<GridGroup>';
        deal_udt.udt_tab.forEachTab(function(tab) {
            if (!final_status) return;

            var grid_obj = tab.getAttachedObject().cells('a').getAttachedObject();

            if (grid_obj instanceof dhtmlXGridObject) {
                grid_obj.clearSelection();

                var grid_label = grid_obj.getUserData("", "grid_label");
                var grid_status = deal_udt.validate_form_grid(grid_obj, grid_label);
                if (grid_status) {
                    var grid_id = grid_obj.getUserData("", "grid_id");
                    deleted_xml = grid_obj.getUserData("", "deleted_xml");

                    var ids = grid_obj.getChangedRows(true);
                    if (deleted_xml != null && deleted_xml != "") {
                        grid_xml += "<GridDelete grid_id=\"" + grid_id + "\">";
                        grid_xml += deleted_xml;
                        grid_xml += "</GridDelete>";
                        
                        if (deleted_grid_name == "") {
                            deleted_grid_name = grid_label;
                        } else {
                            deleted_grid_name += "," + grid_label;
                        }
                    }

                    if (ids != "") {
                        grid_obj.setSerializationLevel(false, false, true, true, true, true);

                        grid_xml += '<Grid grid_id="' + grid_id + '">';

                        var changed_ids = new Array();
                        changed_ids = ids.split(",");
                        var total_column = grid_obj.getColumnsNum();
                        $.each(changed_ids, function(index, value) {
                            grid_xml += "<GridRow ";
                            for (var cellIndex = 0; cellIndex < total_column; cellIndex++) {
                                grid_xml += " " + grid_obj.getColumnId(cellIndex) + '="' + grid_obj.cells(value, cellIndex).getValue() + '"';
                            }
                            grid_xml += " ></GridRow> ";
                        });

                        grid_xml += '</Grid>';
                    }
                } else {
                    final_status = false;
                }
                return;
            }
        });

        grid_xml += '</GridGroup>';

        if (final_status) {
            grid_xml = '<Root function_id="10131000" object_id="' + deal_reference_id + '">' + grid_xml + '</Root>';

		    var data = {
                action: 'spa_process_form_data',
                flag: 's',
                xml: grid_xml
            }

            if (deleted_grid_name != "") {
                var message = "Some data has been deleted from " + deleted_grid_name + " grid. Are you sure you want to save?";
                confirm_messagebox(message, function() {
                    adiha_post_data('alert', data, '', '', 'save_callback');
                }, function() {
                    enable_save_progress_off();
                });
            } else {
                adiha_post_data('alert', data, '', '', 'save_callback');
            }
        } else {
            enable_save_progress_off();
        }
    }

    /**
     * Grid Save Callback to refresh grid
     *
     * @param {Object}  result    Result
     */
    function save_callback(result) {
        if (result[0].errorcode == "Success") {
            deal_udt.udt_tab.forEachTab(function(tab) {
                var grid_obj = tab.getAttachedObject().cells('a').getAttachedObject();
                if (grid_obj instanceof dhtmlXGridObject) {
                    grid_obj.setUserData("", "deleted_xml", "");
                    grid_obj.refresh_grid();
                }
            });
        }
        enable_save_progress_off();
    }

    /**
     * Enable save button and off the progress
     */
    function enable_save_progress_off() {
        deal_udt.toolbar.enableItem('save');
        deal_udt.layout.cells("a").progressOff();
    }
</script>