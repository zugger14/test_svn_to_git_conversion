<?php

/**
 * Setup renewable source screen
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
    require('../../../adiha.html.forms/_setup/manage_documents/manage.documents.button.php');
    ?>
</head>

<body>
    <?php
    $php_script_loc = $app_php_script_loc;
    $generator_id = get_sanitized_value($_REQUEST["generator_id"] ?? 0);

    $form_namespace = 'ns_renewable_source';
    $function_id = 12101700;
    $rights_setup_renewable_source_iu = 12101710;
    $rights_setup_renewable_source_delete = 12101711;

    list(
        $has_rights_setup_renewable_source_iu,
        $has_rights_setup_renewable_source_del
    ) = build_security_rights(
        $rights_setup_renewable_source_iu,
        $rights_setup_renewable_source_delete
    );

    $category_name = 'Renewable Source';
    $category_sql = "SELECT value_id FROM static_data_value WHERE type_id = 25 AND code = '" . $category_name . "'";
    $category_data = readXMLURL2($category_sql);

    $form_obj = new AdihaStandardForm($form_namespace, $function_id);
    $form_obj->define_grid('RenewableSource', "EXEC spa_rec_generator 's'", 'g', false, '', false);
    $form_obj->define_layout_width(520);
    $form_obj->define_custom_functions('save_function', '', 'delete_function', 'form_load_complete');
    $form_obj->define_apply_filters(true, '12101728', 'RenewableSourceFilters', 'General');
    echo $form_obj->init_form('RenewableSource', 'Sources Details', $generator_id);
    echo $form_obj->close_form();
    ?>
</body>
<script type="text/javascript">
    var generator_id = '<?php echo $generator_id; ?>';
    var category_id = '<?php echo $category_data[0]['value_id'] ?? ''; ?>';
    var has_rights_setup_renewable_source_iu = '<?php echo $has_rights_setup_renewable_source_iu ?>';
    var has_rights_setup_renewable_source_del = '<?php echo $has_rights_setup_renewable_source_del ?>';

    $(function() {
        ns_renewable_source.layout.cells('a').expand();
        attach_browse_event('ns_renewable_source.filter_form', 12101700);

        ns_renewable_source.menu.addNewSibling('add', 'copy', 'Copy', true, 'copy.gif', 'copy_dis.gif');
        ns_renewable_source.menu.addNewSibling('t2', 'select_unselect', 'Select/Unselect All', false, 'select_unselect.gif', 'select_unselect_dis.gif');

        ns_renewable_source.grid.attachEvent('onRowSelect', function() {
            ns_renewable_source.menu.setItemEnabled('copy');
        })

        ns_renewable_source.menu.attachEvent('onClick', function(id) {
            switch (id) {
                case 'copy':
                    var row_id = ns_renewable_source.grid.getSelectedRowId();
                    var generator_id = ns_renewable_source.grid.cells(row_id, 0).getValue();
                    var del_msg = "Are you sure you want to copy?";

                    dhtmlx.message({
                        type: "confirm",
                        text: del_msg,
                        title: "Confirmation",
                        ok: "Confirm",
                        callback: function(result) {
                            if (result) {
                                copy_selected_source(generator_id);
                            }
                        }
                    });
                    break;
                case 'select_unselect':
                    var select_rows = ns_renewable_source.grid.getSelectedRowId();
                    if (select_rows == null) {
                        ns_renewable_source.grid.selectAll();
                        ns_renewable_source.menu.setItemEnabled('delete');
                        ns_renewable_source.menu.setItemDisabled('copy');
                    } else {
                        ns_renewable_source.grid.clearSelection(true);
                        ns_renewable_source.menu.setItemDisabled('delete');
                        ns_renewable_source.menu.setItemDisabled('copy');
                    }
                    break;
            }
        })
    });

    ns_renewable_source.save_function = function() {
        ns_renewable_source.layout.cells("a").expand();
        var tab_id = ns_renewable_source.tabbar.getActiveTab();
        var win = ns_renewable_source.tabbar.cells(tab_id);
        var valid_status = 1;
        var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        var flag = (tab_id.indexOf("tab_") != -1) ? 'u' : 'i';
        object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(" ", ""));
        var tab_obj = win.tabbar[object_id];
        var detail_tabs = tab_obj.getAllTabs();
        var grid_xml = "<Root><GridGroup>";
        var form_xml = "<Root><FormXML ";
        var del_xml = "<Root><GridGroup>";
        var form_status = true;
        var first_err_tab;
        var ppa_expiration_date_value = null;
        var ppa_effective_date_value = null;
        var tabsCount = tab_obj.getNumberOfTabs();
        $.each(detail_tabs, function(index, value) {
            layout_obj = tab_obj.cells(value).getAttachedObject();
            layout_obj.forEachItem(function(cell) {
                attached_obj = cell.getAttachedObject();
                if (attached_obj instanceof dhtmlXGridObject) {
                    attached_obj.clearSelection();
                    var ids = attached_obj.getChangedRows(true);
                    grid_id = attached_obj.getUserData("", "grid_id");
                    grid_label = attached_obj.getUserData("", "grid_label");
                    deleted_xml = attached_obj.getUserData("", "deleted_xml");
                    
                    if (deleted_xml != null && deleted_xml != "") {
                        del_xml += "<GridDelete grid_id=\"" + grid_id + "\" grid_label=\"" + grid_label + "\">";
                        del_xml += deleted_xml;
                        del_xml += "</GridDelete>";
                        if (delete_grid_name == "") {
                            delete_grid_name = 'Meter ID'
                        }
                    };
                    if (ids != "") {
                        attached_obj.setSerializationLevel(false, false, true, true, true, true);
                        if (valid_status != 0) {
                            var grid_status = ns_renewable_source.validate_form_grid(attached_obj, grid_label);
                        }
                        grid_xml += "<Grid grid_id=\"" + grid_id + "\">";
                        var changed_ids = new Array();
                        changed_ids = ids.split(",");

                        if (grid_status) {
                            $.each(changed_ids, function(index, value) {
                                attached_obj.setUserData(value, "row_status", "new row");
                                grid_xml += "<GridRow ";
                                for (var cellIndex = 0; cellIndex < attached_obj.getColumnsNum(); cellIndex++) {
                                    if (attached_obj.cells(value, cellIndex).getValue() == 'undefined') { //Cannot use typeof because it returns string
                                        grid_xml += " " + attached_obj.getColumnId(cellIndex) + '= "NULL"';
                                        continue;
                                    }
                                    var cell_index = attached_obj.getColumnId(cellIndex);
                                    var cell_value = attached_obj.cells(value, cellIndex).getValue();
                                    if (cell_index == 'generator_id') {
                                        cell_value = object_id;
                                    }
                                    grid_xml += " " + cell_index + '="' + cell_value + '"';
                                }
                                grid_xml += " ></GridRow> ";
                            });
                            grid_xml += "</Grid>";
                        } else {
                            valid_status = 0;
                        };
                    }
                } else if (attached_obj instanceof dhtmlXForm) {
                    var status = validate_form(attached_obj);
                    form_status = form_status && status;

                    if (status) {

                        data = attached_obj.getFormData();
                        for (var a in data) {
                            field_label = a;
                            if (attached_obj.getItemType(field_label) == "calendar") {
                                field_value = attached_obj.getItemValue(field_label, true);
                            } else {
                                field_value = data[a];
                            }
                            if (field_value != '') {
                                if (field_label == 'book_id' && (field_value.indexOf(',') != -1)) {
                                    show_messagebox('Please select only one Book.');
                                    return;
                                }
                                if (field_label == 'subbook_id' && (field_value.indexOf(',') != -1)) {
                                    show_messagebox('Please select only one <b>Sub Book</b>.');
                                    return;
                                }

                                if (field_label == 'ppa_expiration_date') {
                                    ppa_expiration_date_value = field_value;
                                }

                                if (field_label == 'ppa_effective_date') {
                                    ppa_effective_date_value = field_value;
                                }

                                if (Date.parse(ppa_effective_date_value) > Date.parse(ppa_expiration_date_value)) {
                                    valid_status = 0;
                                    show_messagebox('<strong>Effective Date</strong> cannot be greater than <strong>Expiration Date</strong>.');
                                    generate_error_message();
                                    return
                                }

                                if (field_label == 'auto_assignment_per' && field_value > 100) {
                                    attached_obj.setNote(field_label, {
                                        text: "Cannot be more than 100 (100%)."
                                    });
                                    attached_obj.setValidateCss(field_label, false);
                                    form_status = false;
                                } else if (field_label == 'auto_assignment_per') {
                                    attached_obj.setNote(field_label, {
                                        text: ""
                                    });
                                    attached_obj.setValidateCss(field_label, true);
                                }

                                if (field_label == 'contract_allocation' && field_value > 100) {
                                    attached_obj.setNote(field_label, {
                                        text: "Cannot be more than 100 (100%)."
                                    });
                                    attached_obj.setValidateCss(field_label, false);
                                    form_status = false;
                                } else if (field_label == 'contract_allocation') {
                                    attached_obj.setNote(field_label, {
                                        text: ""
                                    });
                                    attached_obj.setValidateCss(field_label, true);
                                }

                                form_xml += " " + field_label + "=\"" + field_value + "\"";
                            }
                        }
                    } else {
                        generate_error_message();
                        tab_obj.cells(value).setActive();
                        valid_status = 0;
                    }
                }
            });
        });

        form_xml = form_xml.replace('subsidiary_id', 'legal_entity_value_id');
        form_xml = form_xml.replace('book_id', 'fas_book_id');
        form_xml = form_xml.replace('subbook_id', 'fas_sub_book_id');
        form_xml += "></FormXML></Root>";
        grid_xml += "</GridGroup></Root>";
        del_xml += "</GridGroup></Root>";
        console.log(form_xml);
        console.log(grid_xml);
        console.log(del_xml);

        if (valid_status == 1) {
            win.getAttachedToolbar().disableItem('save');

            data = {
                'action': 'spa_rec_generator',
                'flag': flag,
                'form_xml': form_xml,
                'grid_xml': grid_xml,
                'delete_xml': del_xml
            }
            if (delete_grid_name != "") {
                del_msg = "Some data has been deleted from <b>" + delete_grid_name + "</b> grid. Are you sure you want to save?";
                result = adiha_post_data("confirm-warning", data, "", "", "ns_renewable_source.post_callback", "", del_msg);
            } else {
                result = adiha_post_data("alert", data, "", "", "ns_renewable_source.post_callback");
            }
            delete_grid_name = "";
            deleted_xml = attached_obj.setUserData("", "deleted_xml", "");
        }
    }

    /**
     * [Function to delete renewable resources]
     */
    ns_renewable_source.delete_function = function() {
        var selected_row = ns_renewable_source.grid.getSelectedRowId();
        var generator_id_index = ns_renewable_source.grid.getColIndexById('generator_id');
        selected_row = selected_row.split(',');
        var generator_ids = [];
        selected_row.forEach(function(rid) {
            var generator_id = ns_renewable_source.grid.cells(rid, generator_id_index).getValue();
            generator_ids.push(generator_id);
        });
        generator_ids = generator_ids.toString();
        var sql = {
            'action': 'spa_rec_generator',
            'flag': 'd',
            'del_generator_ids': generator_ids
        }

        if (generator_ids != '') {
            dhtmlx.message({
                type: "confirm",
                title: "Confirmation",
                text: "Are you sure you want to delete?",
                callback: function(result) {
                    if (result) {
                        grid_del = true;
                        result = adiha_post_data("return_array", sql, "", "", "ns_renewable_source.post_delete_callback");
                    }
                }
            });
        }

    }

    ns_renewable_source.form_load_complete = function() {
        var tab_id = ns_renewable_source.tabbar.getActiveTab();
        var win = ns_renewable_source.tabbar.cells(tab_id);
        var tabbar_cell = ns_renewable_source.tabbar.tabs(tab_id);
        var toolbar_obj = tabbar_cell.getAttachedToolbar();
        var flag = (tab_id.indexOf("tab_") != -1) ? 'u' : 'i';
        var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(" ", ""));
        var tab_obj = win.tabbar[object_id];
        var detail_tabs = tab_obj.getAllTabs();
        var additional_tab;
        var contract_tab;
        var certification_tab;
        var administration_tab;
        var meter_tab;
        var form_obj;
        var administration_form_obj;
        var certification_form_obj;
        var meter_grid;

        add_manage_document_button(object_id, toolbar_obj, has_rights_setup_renewable_source_iu);

        toolbar_obj.attachEvent('onClick', function(id) {
            if (id == 'documents') {
                open_document(generator_id);
            }
        })

        function open_document(generator_id) {
            document_window = new dhtmlXWindows();

            var win_title = 'Document';
            var win_url = app_form_path + '_setup/manage_documents/manage.documents.php?call_from=renewable_source&notes_object_id=' + generator_id + '&is_pop=true';

            var win = document_window.createWindow('w1', 0, 0, 400, 400);
            win.setText(win_title);
            win.centerOnScreen();
            win.setModal(true);
            win.maximize();
            win.attachURL(win_url, false, {
                notes_category: category_id
            });

            win.attachEvent('onClose', function(w) {
                update_document_counter(object_id, toolbar_obj);
                return true;
            });
        }

        if (flag == 'i') {
            tab_obj.forEachTab(function(tab) {

                if (tab.getText() != "General") {
                    tab.hide();
                }
            });
        }

        $.each(detail_tabs, function(index, value) {
            tab_text = tab_obj.cells(value).getText();
            layout_obj = tab_obj.cells(value).getAttachedObject();

            if (tab_text == 'General') {
                layout_obj.forEachItem(function(cell) {
                    attached_obj = cell.getAttachedObject();

                    if (attached_obj instanceof dhtmlXForm) {
                        form_obj = attached_obj;
                    }
                });
            } else if (tab_text == 'Additional') {
                additional_tab = tab_obj.cells(value);
            } else if (tab_text == 'Contact') {
                contract_tab = tab_obj.cells(value);
            } else if (tab_text == 'Certification') {
                layout_obj.forEachItem(function(cell) {
                    attached_obj = cell.getAttachedObject();

                    if (attached_obj instanceof dhtmlXForm) {
                        certification_form_obj = attached_obj;
                    }
                });
                certification_tab = tab_obj.cells(value);
            } else if (tab_text == 'Administration') {
                administration_tab = tab_obj.cells(value);
                layout_obj.forEachItem(function(cell) {
                    attached_obj = cell.getAttachedObject();

                    if (attached_obj instanceof dhtmlXForm) {
                        administration_form_obj = attached_obj;
                        attached_obj.setItemLabel('contract_allocation', "<a id='trader_id' href='javascript:void(0);' onclick='open_percent_allocation_report();'>Allocation Percent<\/a>")
                        attached_obj.setItemLabel('auto_assignment_per', "<a id='trader_id' href='javascript:void(0);' onclick='open_assignment_percentage();'>Assignment Percent<\/a>")
                    }
                });
            } else if (tab_text == 'Meter ID') {
                var myMenu = layout_obj.cells('a').getAttachedMenu();
                
                if (flag == 'i') {
                    myMenu.setItemDisabled('add');
                }

                meter_tab = tab_obj.cells(value);
                layout_obj.cells('a').hideHeader();

                layout_obj.forEachItem(function(cell) {
                    attached_obj = cell.getAttachedObject();

                    if (attached_obj instanceof dhtmlXGridObject) {
                        meter_grid = attached_obj;
                        attached_obj.attachEvent('onRowDblClicked', function(id, ind) {
                            if (ind == 4) {
                                var recorder_id_index = attached_obj.getColIndexById('recorder_id');
                                var row_id = attached_obj.getSelectedRowId();
                                if (ind == recorder_id_index) {
                                    meter_id_window = new dhtmlXWindows();
                                    var src = 'browse.meter.id.php?row_id=' + row_id;

                                    win_meter_id = meter_id_window.createWindow('w1', 0, 0, 700, 500);
                                    win_meter_id.setText("Browse");
                                    win_meter_id.centerOnScreen();
                                    win_meter_id.setModal(true);
                                    win_meter_id.attachURL(src, false);
                                }
                            }
                        });
                    }
                });
            }
        });

        meter_grid.attachEvent('onXLE', function() {

        });

        function detail_changed() {
            var detail_value = form_obj.isItemChecked('show_detail');

            if (detail_value) {
                additional_tab.show();
                additional_tab.show();
                contract_tab.show();
                certification_tab.show();
                administration_tab.show();
                meter_tab.show();
            } else {
                additional_tab.hide();
                additional_tab.hide()
                contract_tab.hide()
                certification_tab.hide()
                administration_tab.hide()
                meter_tab.hide()
            }
        }

        function contract_changed() {
            var contract_value = administration_form_obj.getItemValue('ppa_contract_id')

            if (contract_value == '') {
                administration_form_obj.setItemValue('contract_allocation', '');
                administration_form_obj.disableItem('contract_allocation');
            } else {
                administration_form_obj.enableItem('contract_allocation');
            }
        }

        function assignement_changed() {
            var assignment_value = administration_form_obj.getItemValue('auto_assignment_type');

            if (assignment_value == '') {
                administration_form_obj.setItemValue('auto_assignment_per', '');
                administration_form_obj.disableItem('auto_assignment_per');
            } else {
                administration_form_obj.enableItem('auto_assignment_per');
            }
        }

        function register_changed() {
            var register_value = certification_form_obj.getItemValue('registered');

            if (register_value == 'y') {
                certification_form_obj.enableItem('gis_value_id')
                certification_form_obj.enableItem('registration_date')
                certification_form_obj.enableItem('gis_id_number')
            } else {
                certification_form_obj.setItemValue('gis_value_id', '');
                certification_form_obj.setItemValue('registration_date', '');
                certification_form_obj.setItemValue('gis_id_number', '');
                certification_form_obj.disableItem('gis_value_id')
                certification_form_obj.disableItem('registration_date')
                certification_form_obj.disableItem('gis_id_number')
            }
        }

        detail_changed();
        contract_changed();
        assignement_changed();
        register_changed();

        form_obj.attachEvent('onChange', function(id) {
            if (id == 'show_detail') {
                detail_changed();
            }
        });

        administration_form_obj.attachEvent('onChange', function(id) {
            if (id == 'ppa_contract_id') {
                contract_changed();
            }

            if (id == 'auto_assignment_type') {
                assignement_changed();
            }
        });

        certification_form_obj.attachEvent('onChange', function(id) {
            if (id == 'registered') {
                register_changed();
            }
        })


    }

    function copy_selected_source(generator_id) {
        var params = {
            'action': 'spa_rec_generator',
            'flag': 'c',
            'generator_id': generator_id
        }
        adiha_post_data('alert', params, '', '', 'post_copy_callback');
    }

    function post_copy_callback(result) {
        if (result[0].errorcode == "Success") {
            ns_renewable_source.refresh_grid();
            ns_renewable_source.menu.setItemDisabled('copy');
            ns_renewable_source.menu.setItemDisabled('delete');
        }
    }

    var percent_allocation_window;

    function open_percent_allocation_report(args) {
        var tab_id = ns_renewable_source.tabbar.getActiveTab();
        var win = ns_renewable_source.tabbar.cells(tab_id);
        var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(" ", ""));
        var tab_obj = win.tabbar[object_id];
        var detail_tabs = tab_obj.getAllTabs();
        var ppa_contract;
        $.each(detail_tabs, function(index, value) {
            tab_text = tab_obj.cells(value).getText();
            layout_obj = tab_obj.cells(value).getAttachedObject();

            if (tab_text == 'Administration') {
                layout_obj.forEachItem(function(cell) {
                    attached_obj = cell.getAttachedObject();

                    if (attached_obj instanceof dhtmlXForm) {
                        ppa_contract = attached_obj.getItemValue('ppa_contract_id');
                    }
                });
            }
        });

        if (ppa_contract == '') {
            return;
        }

        percent_allocation_window = new dhtmlXWindows();
        var new_win = percent_allocation_window.createWindow('w1', 0, 0, 1000, 600);
        new_win.setText("Allocation Percentage Report");
        new_win.centerOnScreen();
        new_win.setModal(true);

        var js_php_path = '<?php echo $php_script_loc; ?>';
        var url = js_php_path + "dev/spa_html.php?exec=EXEC spa_rec_generator_per_allocation " + ppa_contract;

        new_win.attachURL(url, false, true);
    }

    var browse_window

    function open_assignment_percentage(args) {
        browse_window = new dhtmlXWindows();
        var src = js_php_path + '../adiha.html.forms/_models_and_activity/setup_renewable_source/assignment.percent.php?generator_id=' + generator_id;
        new_browse = browse_window.createWindow('Assignment Percent', 0, 0, 1200, 600);
        new_browse.setText("Assignment Percent");
        new_browse.setModal(true);
        new_browse.attachURL(src, false, true);
    }

    function set_meter_grid_columns(meter_id, recorder_id, row_id) { // called from child page in meter id tab while svaing data in Recorder ID
        var tab_id = ns_renewable_source.tabbar.getActiveTab();
        var win = ns_renewable_source.tabbar.cells(tab_id);
        var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(" ", ""));
        var tab_obj = win.tabbar[object_id];
        var detail_tabs = tab_obj.getAllTabs();

        $.each(detail_tabs, function(index, value) {
            tab_text = tab_obj.cells(value).getText();
            layout_obj = tab_obj.cells(value).getAttachedObject();

            if (tab_text == 'Meter ID') {
                layout_obj.forEachItem(function(cell) {
                    attached_obj = cell.getAttachedObject();

                    if (attached_obj instanceof dhtmlXGridObject) {
                        var recorder_id_index = attached_obj.getColIndexById('recorder_id');
                        var meter_id_index = attached_obj.getColIndexById('meter_id');

                        attached_obj.cells(row_id, meter_id_index).setValue(meter_id);
                        attached_obj.cells(row_id, recorder_id_index).setValue(recorder_id);
                        attached_obj.validateCell(row_id, meter_id_index);
                        attached_obj.validateCell(row_id, recorder_id_index);
                    }
                });
            }
        });
    }

    ns_renewable_source.validate_form_grid = function(attached_obj, grid_label) {
        var status = true;
        var recorder_id = 1;
        var allocation_per = 1;
        var from_vol = 1;
        var to_vol = 1;
        var allocation_per_value = 0;
        var recorder_generator_map_id = null;
        for (var i = 0; i < attached_obj.getRowsNum(); i++) {
            var row_id = attached_obj.getRowId(i);
            var no_of_child = "";

            for (var j = 0; j < attached_obj.getColumnsNum(); j++) {
                var type = attached_obj.getColType(j);
                if (type == "combo") {
                    combo_obj = attached_obj.getColumnCombo(j);
                    var value = attached_obj.cells(row_id, j).getValue();
                    var selected_option = combo_obj.getIndexByValue(value);
                    if (selected_option == -1) {
                        var message = "Invalid Data";
                        attached_obj.cells(row_id, j).setAttribute("validation", message);
                        attached_obj.cells(row_id, j).cell.className = " dhtmlx_validation_error";
                    } else {
                        attached_obj.cells(row_id, j).setAttribute("validation", "");
                        attached_obj.cells(row_id, j).cell.className = attached_obj.cells(row_id, j).cell.className.replace(/[ ]*dhtmlx_validation_error/g, "");
                    }
                }
                var validation_message = attached_obj.cells(row_id, j).getAttribute("validation");
                if (validation_message != "" && validation_message != undefined) {
                    var column_text = attached_obj.getColLabel(j);
                    error_message = "Data Error in <b>" + grid_label + "</b> grid. Please check the data in column <b>" + column_text + "</b> and resave.";
                    dhtmlx.alert({
                        title: "Alert",
                        type: "alert",
                        text: error_message
                    });
                    status = false;
                    generate_error_message();
                    return;
                }
                var gird_index = grid_index = attached_obj.getColumnId(j);
                var cell = attached_obj.cells(row_id, j).getValue();
                if (grid_index == 'recorder_id' && cell == '') {
                    recorder_id = 0;
                }
                if (grid_index == 'meter_id') {
                    if (recorder_generator_map_id) {
                        var data = {
                            "action": "spa_rec_generator",
                            "flag": "l",
                            "meter_id": cell,
                            "recorder_generator_map_id": recorder_generator_map_id
                        }
                    } else {
                        var data = {
                            "action": "spa_rec_generator",
                            "flag": "l",
                            "meter_id": cell
                        }
                    }

                    result = adiha_post_data('return_array', data, '', '', 'check_allocation_percent', false);
                }
                if (grid_index == 'allocation_per' && cell == '') {
                    allocation_per = 0;
                }

                if (grid_index == 'id' && cell != '') {
                    recorder_generator_map_id = cell;
                }

                if (grid_index == 'allocation_per' && cell != '') {
                    allocation_per_value = cell;
                }

                if (grid_index == 'from_vol' && cell == '') {
                    from_vol = 0;
                }

                if (grid_index == 'to_vol' && cell == '') {
                    to_vol = 0;
                }
            }
            if (recorder_id == 1) {
                if ((allocation_per == 1) && (from_vol == 1) && (to_vol == 1) || (allocation_per == 0) && (from_vol == 0) && (to_vol == 0)) {
                    show_messagebox('Please enter either <b>Allocation</b> or <b>Volume</b>.');
                    status = false;
                    generate_error_message();
                    return
                } else {
                    if ((allocation_per == 1) && ((from_vol == 1) || (to_vol == 1))) {
                        show_messagebox('Please enter either <b>Allocation</b> or <b>Volume</b>.');
                        status = false;
                        generate_error_message();
                        return
                    } else if (allocation_per_value > 1 || allocation_per_value < 0) {
                        show_messagebox('<b>Allocation Percent</b> Should be between 0 to 1.');
                        status = false;
                        generate_error_message();
                        return;
                    } else if ((Number(allocation_per_value) + Number(total_allocation_per_value)) > 1) {
                        show_messagebox('<b>Total Allocation Percent</b> Should not exceed 1.');
                        status = false;
                        generate_error_message();
                        return;
                    } else if ((allocation_per == 0) && (from_vol == 1) && (to_vol == 0)) {
                        show_messagebox('<b>To Volume</b> should be defined when <b>From Volume</b> is entered.');
                        status = false;
                        generate_error_message();
                        return
                    } else if ((allocation_per == 0) && (from_vol == 0) && (to_vol == 1)) {
                        show_messagebox('<b>From Volume</b> should be defined when <b>To Volume</b> is entered.');
                        status = false;
                        generate_error_message();
                        return
                    }
                }
            }
            if (validation_message != "" && validation_message != undefined) {
                break;
            };
        }
        return status;
    }

    function check_allocation_percent(result) {
        total_allocation_per_value = result[0][0];
    }
</script>

</html>