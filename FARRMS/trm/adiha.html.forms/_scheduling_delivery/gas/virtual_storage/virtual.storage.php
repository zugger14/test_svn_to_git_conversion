<?php

/**
 * Virtual storage screen
 * @copyright Pioneer Solutions
 */
?>
<!DOCTYPE html>
<html>

<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php require('../../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>

<body>
    <?php

    $open_tab = isset($_REQUEST["storage_asset_id"]) ? (empty($_REQUEST["storage_asset_id"]) ? 'new' : get_sanitized_value($_REQUEST["storage_asset_id"])) : '';
    $contract_id = get_sanitized_value($_REQUEST['contract_id'] ?? '');
    $counterparty_id = get_sanitized_value($_REQUEST['counterparty_id'] ?? '');
    global $image_path;
    $php_script_loc = $app_php_script_loc;
    $app_user_loc = $app_user_name;

    $rights_strorage_assets = 10162300;
    $rights_strorage_assets_ui = 10162310;
    $rights_strorage_assets_delete = 10162311;

    list(
        $has_rights_strorage_assets,
        $has_rights_strorage_assets_ui,
        $has_rights_strorage_assets_delete
    ) = build_security_rights(
        $rights_strorage_assets,
        $rights_strorage_assets_ui,
        $rights_strorage_assets_delete
    );

    $form_namespace = 'storage_assets';
    $form_obj = new AdihaStandardForm($form_namespace, 10162300);
    $form_obj->define_grid("storage_assets", "", 't');
    $form_obj->define_layout_width("350");
    $form_obj->define_custom_functions('pre_save_storage_assets', 'load_storage_assets', 'delete_storage_assets');
    echo $form_obj->init_form('Storage', 'Details', $open_tab);
    echo $form_obj->close_form();
    ?>
</body>

<script>
    var has_rights_strorage_assets_ui = <?php echo (($has_rights_strorage_assets_ui) ? $has_rights_strorage_assets_ui : '0'); ?>;
    var has_rights_strorage_assets_delete = <?php echo (($has_rights_strorage_assets_delete) ? $has_rights_strorage_assets_delete : '0'); ?>;
    var delete_flag_arr = new Array();

    var isparent;

    var open_tab = '<?php echo $open_tab; ?>';
    var open_tab_add_check = '<?php echo $open_tab; ?>';
    var contract_id = '<?php echo $contract_id; ?>';
    var counterparty_id = '<?php echo $counterparty_id; ?>';

    storage_assets.tab_select_callback = function(result) {
        var data = JSON.parse(result);
        if (data[0].general_assest_id) {
            storage_assets.ggg = data;
            storage_assets.grid.expandAll();
            ag = storage_assets.ggg[0].general_assest_id;
            all = storage_assets.grid.getAllRowIds().split(',');

            idx = storage_assets.grid.getColIndexById('id');
            row_id = all.filter(function(e) {
                return storage_assets.grid.cells(e, idx).getValue() == ag
            })[0];

            storage_assets.grid.selectRowById(row_id);
            storage_assets.create_tab(row_id, 0, 0, 0);
        } else {
            storage_assets.grid.expandAll();
            storage_assets.grid.selectRowById(data[0]['asset_name'].split(' ').join(''));
            storage_assets.create_tab(-1, 0, 0, 0);
        }

        // reset contract id to prevent setting contract id for each new tab.
        // contract_id = ''; 
        storage_assets.grid.detachEvent(a);
    }

    $(function() {
        if (open_tab != '') {
            storage_assets.layout.cells('a').collapse();
            if (open_tab != 'new') {
                a = storage_assets.grid.attachEvent('onXLE', function() {
                    data = {
                        "action": "spa_storage_assets",
                        "flag": 'k',
                        "storage_asset_id": open_tab_add_check,
                        "agreement": contract_id,
                    };
                    adiha_post_data('return_json', data, '', '', 'storage_assets.tab_select_callback', false);
                });
            }
        }

        if (open_tab_add_check != "")
            storage_assets.menu.setItemDisabled('add');

        storage_assets.grid.enableMultiselect(true);
        storage_assets.grid.attachEvent("onKeyPress", function(code, cFlag, sFlag) {
            if (code == 27) {
                storage_assets.grid.clearSelection();
            }
        });
        storage_assets.grid.attachEvent('onRowDblClicked', function(rId, cId) {
            selected_rows = storage_assets.grid.getSelectedId();
            g_level = storage_assets.grid.getLevel(selected_rows);
            if (g_level == 0) { // Getting parent Primary id from its unique description value.
                data = {
                    "action": "spa_storage_assets",
                    "flag": "f",
                    "storage_asset_id": selected_rows
                };
                adiha_post_data('return_array', data, '', '', 'onRowDblClicked_call_back', '');
            }
        });
    });

    var php_script_loc = '<?php echo $php_script_loc; ?>';
    var image_path = '<?php echo $image_path; ?>';

    function onRowDblClicked_call_back(result) { // Load parent data.
        var tab_id = 'tab_' + storage_assets.grid.getSelectedId();
        var a = storage_assets.tabbar.getAllTabs();
        if ($.inArray(tab_id, a) == -1) {
            storage_assets.tabbar.addTab(tab_id, storage_assets.grid.getSelectedId(), null, null, true, true);
            win = storage_assets.tabbar.cells(tab_id);
            storage_assets.load_storage_assets(win, tab_id, storage_assets.grid, 'parent', result[0][0])
        } else {
            storage_assets.tabbar.cells(tab_id).setActive();
        }
    }

    storage_assets.pre_save_storage_assets = function(tab_id) {

        var active_tab_id = storage_assets.tabbar.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;


        if (storage_assets["storage_assets_tab_" + active_object_id].isParent) {
            storage_assets.save_storage_assets(true);
        } else {
            var del_flag = storage_assets["constraints_" + active_object_id].getUserData("", "deleted_xml");

            if (del_flag == 'deleted') {
                del_msg = "Some data has been deleted from Constraints grid. Are you sure you want to save?";
                dhtmlx.message({
                    type: "confirm",
                    text: del_msg,
                    callback: function(result) {
                        if (result)
                            storage_assets.save_storage_assets();
                    }
                });
            } else {
                storage_assets.save_storage_assets();
            }
        }
    }

    /*
     * save_storage_assets [function to save the form and grid data]
     */
    storage_assets.save_storage_assets = function(isparent) {

        isparent == isparent === undefined ? false : true;
        // alert('isparent? : '+(isparent?'yes':'no'));

        var active_tab_id = storage_assets.tabbar.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;

        if (isparent) {

            var status_asset = validate_form(storage_assets["asset_form" + active_object_id]);
            // alert(status_asset);
            if (status_asset == false) return;

            var asset_xml = "<FormXML ";
            asset_data = storage_assets["asset_form" + active_object_id].getFormData();
            var assets_id = storage_assets["asset_form" + active_object_id].getItemValue('storage_asset_id');

            for (var a in asset_data) {
                field_label = a;
                field_value = asset_data[a];
                asset_xml += " " + field_label + "=\"" + field_value + "\"";
            }

            asset_xml += "></FormXML>";



            var tab_name = storage_assets.tabbar.tabs(active_tab_id).getText();
            if (tab_name == 'New') {
                flag = 'i';
                id = '';
            } else {
                flag = 'u';
                id = assets_id;
            }

            var data = {
                "action": "spa_storage_asset_parent",
                "flag": flag,
                "storage_asset_id": id,
                "asset_xml": asset_xml,
            };

            adiha_post_data('return_json', data, '', '', 'save_callback', '');

        } else {
            var status = validate_form(storage_assets["general_form" + active_object_id]);

            if (status == false) {
                return;
            }

            var form_xml = "<FormXML ";
            data = storage_assets["general_form" + active_object_id].getFormData();
            var g_assets_id = storage_assets["general_form" + active_object_id].getItemValue('general_assest_id');
            var agreement_cmb = storage_assets["general_form" + active_object_id].getCombo('agreement');
            var loc_cmb = storage_assets["general_form" + active_object_id].getCombo('storage_location');
            agreement = loc_cmb.getSelectedText() + ' -> ' + agreement_cmb.getSelectedText();

            for (var a in data) {
                field_label = a;
                field_value = data[a];
                form_xml += " " + field_label + "=\"" + field_value + "\"";
            }


            form_xml += "></FormXML>";


            var contraint_check = 0;
            var storage_value = 0;
            var uom_check = 0;
            var constraint_arr_check = 0;
            var constraint_arr = new Array();
            var date_check = 0;

            var grid_xml = "<GridGroup>";

            for (var row_index = 0; row_index < storage_assets["constraints_" + active_object_id].getRowsNum(); row_index++) {


                if (storage_assets["constraints_" + active_object_id].cells2(row_index, 1).getValue() == '') {
                    contraint_check = 1;
                }

                if (storage_assets["constraints_" + active_object_id].cells2(row_index, 2).getValue() == '') {
                    storage_value = 1;
                }

                if (storage_assets["constraints_" + active_object_id].cells2(row_index, 3).getValue() == '') {
                    uom_check = 1;
                }
                if (storage_assets["constraints_" + active_object_id].cells2(row_index, 4).getValue() == '') {
                    date_check = 1;
                }


                var constraint_type_value = storage_assets["constraints_" + active_object_id].cells2(row_index, 1).getValue();
                var eff_date_value = storage_assets["constraints_" + active_object_id].cells2(row_index, 4).getValue();

                if (jQuery.inArray(constraint_type_value + '-' + eff_date_value, constraint_arr) == -1) {
                    constraint_arr.push(constraint_type_value + '-' + eff_date_value);
                } else {
                    constraint_arr_check = 1;
                }

                grid_xml = grid_xml + "<PSRecordset ";
                for (var cellIndex = 0; cellIndex < storage_assets["constraints_" + active_object_id].getColumnsNum(); cellIndex++) {
                    grid_xml = grid_xml + " " + storage_assets["constraints_" + active_object_id].getColumnId(cellIndex) + '="' + storage_assets["constraints_" + active_object_id].cells2(row_index, cellIndex).getValue() + '"';
                }
                grid_xml = grid_xml + " ></PSRecordset> ";
            }

            grid_xml += "</GridGroup>";

            if (contraint_check == 1) {
                show_messagebox('Please select the Constraint Type.');
                return;
            }

            if (storage_value == 1) {
                show_messagebox('Please enter storage value.');
                return
            }

            if (uom_check == 1) {
                show_messagebox('Please select the UOM.');
                return
            }

            if (date_check == 1) {
                show_messagebox('Please select the Effective Date.');
                return
            }

            if (constraint_arr_check == 1) {
                show_messagebox('Constaint Name for same effective date should not be duplicated.');
                return
            }


            // For ratchets
            var ratchet_grid_xml = "<GridGroupRatchet>";
            var col_type_no = storage_assets["ratchets_" + active_object_id].getColIndexById('type');

            for (var row_index = 0; row_index < storage_assets["ratchets_" + active_object_id].getRowsNum(); row_index++) {

                if (storage_assets["ratchets_" + active_object_id].cells2(row_index, col_type_no).getValue() == '') {
                    show_messagebox('Please select the Type.');
                    return;
                }

                var gas_in_storage_perc_from = 0;
                var gas_in_storage_perc_to = 0;

                ratchet_grid_xml = ratchet_grid_xml + "<PSRecordset ";
                for (var cellIndex = 0; cellIndex < storage_assets["ratchets_" + active_object_id].getColumnsNum(); cellIndex++) {

                    var column = storage_assets["ratchets_" + active_object_id].getColumnId(cellIndex);
                    var value = storage_assets["ratchets_" + active_object_id].cells2(row_index, cellIndex).getValue();

                    if ($.trim(column) == 'gas_in_storage_perc_to') {
                        gas_in_storage_perc_to = value;
                    };

                    ratchet_grid_xml = ratchet_grid_xml + " " + storage_assets["ratchets_" + active_object_id].getColumnId(cellIndex) + '="' + storage_assets["ratchets_" + active_object_id].cells2(row_index, cellIndex).getValue() + '"';
                }
                ratchet_grid_xml = ratchet_grid_xml + " ></PSRecordset> ";
            }

            ratchet_grid_xml += "</GridGroupRatchet>";
            storage_asset_id = storage_assets.grid.getSelectedRowId();
            //alert(storage_asset_id);

            var tab_name = storage_assets.tabbar.tabs(active_tab_id).getText();
            if (tab_name == 'New') {
                flag = 'i';
                id = '';
            } else {
                flag = 'u';
                id = g_assets_id;
            }

            var data = {
                "action": "spa_storage_assets",
                "flag": flag,
                "general_assets_id": id,
                "general_xml": form_xml,
                "constraints_xml": grid_xml,
                "ratchet_grid_xml": ratchet_grid_xml,
                "storage_asset_id": storage_asset_id
            };

            adiha_post_data('return_json', data, '', '', 'save_callback', '');
        }
    }

    function save_callback(result) {
        var active_tab_id = storage_assets.tabbar.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;

        var return_data = JSON.parse(result);

        if (return_data[0].recommendation.indexOf('parent') >= 0) {
            var tab_info = new Array();
            if (return_data[0].recommendation.indexOf("_") != -1) {
                tab_info = return_data[0].recommendation.split("_")
            }
            tab_name = storage_assets["asset_form" + active_object_id].getItemValue('asset_name');

            var previous_text = storage_assets.tabbar.tabs(active_tab_id).getText();
            storage_assets.tabbar.tabs(active_tab_id).setText(tab_name);
            var user_data = {
                "r_id": tab_name.replace(/\s/g, ''),
                "new_id": tab_info[0]
            }
            storage_assets.tabbar.tabs(active_tab_id).setUserData('user_data', user_data);
            storage_assets.refresh_grid("", storage_assets.open_tab_new);

            success_call(return_data[0].message);
            return;
        }

        if (return_data[0].status == 'Success') {
            success_call(return_data[0].message);

            if (flag == 'i') {
                var new_id = return_data[0].recommendation;
                storage_assets["general_form" + active_object_id].setItemValue('general_assest_id', new_id);
                if (return_data[0].module != '') {
                    storage_assets["general_form" + active_object_id].setItemValue('logical_name', return_data[0].module);
                }
                storage_assets.tabbar.tabs(active_object_id).setText(new_id);
            } else if (flag == 'u') {
                storage_assets.tabbar.tabs(active_tab_id).setText(active_object_id);
                if (return_data[0].recommendation != '') {
                    storage_assets["general_form" + active_object_id].setItemValue('logical_name', return_data[0].recommendation);
                }
            }
            storage_assets.grid.saveOpenStates();
            storage_assets.refresh_grid("", storage_assets.open_tab);
        } else {
            show_messagebox(return_data[0].message);
        }
    }

    /*
     * delete_storage_assets [function to delete the storage assets]
     */
    storage_assets.delete_storage_assets = function() {
        var selected_id = storage_assets.grid.getSelectedId();

        if (selected_id == null) {
            show_messagebox('Please select the data you want to delete.');
            return;
        }

        var selected_array = new Array();
        var selected_id_array = new Array();
        selected_parent_id_array = new Array();
        selected_array = selected_id.split(",");
        var tree_level_flag = 0

        for (count = 0; count < selected_array.length; count++) {
            var tree_level = storage_assets.grid.getLevel(selected_array[count]);

            if (tree_level == 0) {
                temp_id = storage_assets.grid.cells(selected_array[count], 0).getValue();
                selected_parent_id_array.push(temp_id);
            } else {
                temp_id = storage_assets.grid.cells(selected_array[count], 1).getValue();
                selected_id_array.push(temp_id);
            }
        }

        // if (tree_level_flag == 1) {
        //     show_messagebox('Please select the contract.');
        //     return;
        // }

        general_assets_id = selected_id_array.toString();
        var data = {
            "action": "spa_storage_assets",
            "flag": "d",
            "general_assets_id": general_assets_id,
            "general_assets_parent_id": selected_parent_id_array.toString()
        };

        var confirm_msg = 'Are you sure you want to delete?';

        dhtmlx.message({
            type: "confirm",
            text: confirm_msg,
            callback: function(result) {
                if (result)
                    adiha_post_data('alert', data, '', '', 'storage_assets.delete_callback', '');
            }
        });
    }

    storage_assets.delete_callback = function(result) {
        if (result[0].recommendation.indexOf(",") > -1) {
            var ids = result[0].recommendation.split(",");
            var count_ids = ids.length;
            for (var i = 0; i < count_ids; i++) {
                full_id = 'tab_' + ids[i];
                if (storage_assets.pages[full_id]) {
                    storage_assets.tabbar.cells(full_id).close();
                } else if (all_ids.indexOf("tab_" + selected_parent_id_array.toString().replace(' ', '')) > -1) {
                    var prev_id = "tab_" + selected_parent_id_array.toString().replace(' ', '');
                    delete storage_assets.pages[prev_id];
                    storage_assets.tabbar.cells(prev_id).close(false);
                    storage_assets.tabbar.tabs(prev_id).close();
                }
            }
        } else {
            full_id = 'tab_' + result[0].recommendation;
            if (storage_assets.pages[full_id]) {
                storage_assets.tabbar.cells(full_id).close();
            }
        }
        storage_assets.refresh_grid();
    }

    function save_parent() {
        storage_assets.layout.cells("a").expand();
        var tab_id = storage_assets.tabbar.getActiveTab();
        storage_assets.pre_save_storage_assets(tab_id);
    }


    function load_parent(win, tab_id, grid_obj, storage_asset_id) {
        var storage_assets_tab_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;

        var storage_assets_name = storage_assets.tabbar.tabs(tab_id).getText();

        storage_assets["inner_tab_layout_" + storage_assets_tab_id] = win.attachLayout("1C");
        storage_assets["inner_tab_layout_" + storage_assets_tab_id].cells('a').setHeight(220);

        if (!win.getAttachedToolbar()) {
            var toolbar = win.attachToolbar();
            toolbar.setIconsPath(image_path + 'dhxmenu_web/');
            toolbar.loadStruct([{
                id: "save",
                type: "button",
                img: "save.gif",
                imgdis: "save_dis.gif",
                text: "Save",
                title: "Save"
            }]);
            toolbar.attachEvent("onClick", save_parent);
        }






        data = {
            "action": "spa_create_application_ui_json",
            "flag": "j",
            "application_function_id": 10162301,
            "template_name": "StorageAssetParent",
            "parse_xml": "<Root><PSRecordSet storage_asset_id=\"" + storage_asset_id + "\"></PSRecordSet></Root>"
        };



        adiha_post_data('return_array', data, '', '', 'load_storage_assets_callback', '');
        win.progressOff();
    }

    function load_child(win, tab_id, grid_obj) {
        var storage_assets_tab_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;

        var storage_assets_name = storage_assets.tabbar.tabs(tab_id).getText();

        storage_assets["inner_tab_layout_" + storage_assets_tab_id] = win.attachLayout("1C");
        storage_assets["inner_tab_layout_" + storage_assets_tab_id].cells('a').setHeight(220);

        data = {
            "action": "spa_create_application_ui_json",
            "flag": "j",
            "application_function_id": 10162300,
            "template_name": "storage assets",
            "parse_xml": "<Root><PSRecordSet general_assest_id=\"" + storage_assets_tab_id + "\"></PSRecordSet></Root>"
        };

        adiha_post_data('return_array', data, '', '', 'load_storage_assets_callback', '');
        win.progressOff();

        if (storage_assets_name != 'New') {
            var agreement_cmb = storage_assets["general_form" + storage_assets_tab_id].getCombo('agreement');
            var loc_cmb = storage_assets["general_form" + storage_assets_tab_id].getCombo('storage_location');
            var new_tab_name = loc_cmb.getSelectedText() + ' -> ' + agreement_cmb.getSelectedText();

            storage_assets.tabbar.tabs("tab_" + storage_assets_tab_id).setText(new_tab_name);
        }
    }

    storage_assets.open_tab_new = function() {
        var col_type = storage_assets.grid.getColType(0);
        var prev_id = storage_assets.tabbar.getActiveTab();
        var system_id = storage_assets.tabbar.tabs(prev_id).getText();
        var tab_index = (prev_id == "") ? null : storage_assets.tabbar.tabs(prev_id).getIndex();
        system_id_array = new Array();
        system_id_array = system_id.split(",");
        for (var i = 0; i < system_id_array.length; i++) {
            var user_data = storage_assets.tabbar.tabs(prev_id).getUserData('user_data');
            primary_value = user_data.r_id;
            var new_id = user_data.new_id;
            storage_assets.grid.filterByAll();
            if (primary_value != "") {
                if (storage_assets.pages[prev_id]) {
                    delete storage_assets.pages[prev_id];
                    storage_assets.tabbar.cells(prev_id).close(false);
                    storage_assets.tabbar.tabs(prev_id).close(false);
                } else {
                    storage_assets.tabbar.cells(prev_id).close(false);
                    storage_assets.tabbar.tabs(prev_id).close(false);
                }
                storage_assets.grid.selectRowById(primary_value, false, true, true);
                storage_assets.create_tab_new(primary_value, 0, 0, 0, tab_index, new_id);
            }
        }
    }

    storage_assets.create_tab_new = function(r_id, col_id, grid_obj, acc_id, tab_index, new_id) {
        if (r_id == -1 && col_id == 0) {
            full_id = storage_assets.uid();
            full_id = full_id.toString();
            text = "New";
        } else {
            full_id = storage_assets.get_id(storage_assets.grid, r_id) + r_id;
            text = storage_assets.get_text(storage_assets.grid, r_id);
            if (full_id == "tab_") {
                var selected_row = storage_assets.grid.getSelectedRowId();
                var state = storage_assets.grid.getOpenState(selected_row);
                if (state)
                    storage_assets.grid.closeItem(selected_row);
                else
                    storage_assets.grid.openItem(selected_row);
                return false;
            }
        }
        if (!storage_assets.pages[full_id]) {
            var tab_context_menu = new dhtmlXMenuObject();
            tab_context_menu.setIconsPath(js_image_path + "dhxtoolbar_web/");
            tab_context_menu.renderAsContextMenu();
            storage_assets.tabbar.addTab(full_id, text, null, tab_index, true, true);
            //using window instead of tab
            var win = storage_assets.tabbar.cells(full_id);
            storage_assets.tabbar.t[full_id].tab.id = full_id;
            tab_context_menu.addContextZone(full_id);
            tab_context_menu.loadStruct([{
                id: "close",
                text: "Close",
                title: "Close"
            }, {
                id: "close_all",
                text: "Close All",
                title: "Close All"
            }, {
                id: "close_other",
                text: "Close Other Tabs",
                title: "Close Other Tabs"
            }]);
            tab_context_menu.attachEvent("onContextMenu", function(zoneId) {
                storage_assets.tabbar.tabs(zoneId).setActive();
            });
            tab_context_menu.attachEvent("onClick", function(id, zoneId) {
                var ids = storage_assets.tabbar.getAllTabs();
                switch (id) {
                    case "close_other":
                        ids.forEach(function(tab_id) {
                            if (tab_id != zoneId) {
                                delete storage_assets.pages[tab_id];
                                storage_assets.tabbar.tabs(tab_id).close();
                            }
                        })
                        break;
                    case "close_all":
                        ids.forEach(function(tab_id) {
                            delete storage_assets.pages[tab_id];
                            storage_assets.tabbar.tabs(tab_id).close();
                        })
                        break;
                    case "close":
                        ids.forEach(function(tab_id) {
                            if (tab_id == zoneId) {
                                delete storage_assets.pages[tab_id];
                                storage_assets.tabbar.tabs(tab_id).close();
                            }
                        })
                        break;
                }
            });
            var toolbar = win.attachToolbar();
            toolbar.setIconsPath(js_image_path + "dhxtoolbar_web/");
            toolbar.attachEvent("onClick", storage_assets.tab_toolbar_click);
            toolbar.loadStruct([{
                id: "save",
                type: "button",
                img: "save.gif",
                imgdis: "save_dis.gif",
                text: "Save",
                title: "Save"
            }]);
            storage_assets.tabbar.cells(full_id).setText(text);
            storage_assets.tabbar.cells(full_id).setActive();
            storage_assets.tabbar.cells(full_id).setUserData("row_id", r_id);
            win.progressOn();
            storage_assets.load_storage_assets(win, full_id, grid_obj, 'parent', new_id);
            storage_assets.pages[full_id] = win;
        } else {
            storage_assets.tabbar.cells(full_id).setActive();
        };
    };
    /*
     * load_storage_assets [function to load and create the form when storage assets is double clicked]
     */
    storage_assets.load_storage_assets = function(win, tab_id, grid_obj, status, storage_asset_id) {
        grid_row_selected = storage_assets.grid.getSelectedRowId() ? true : false;
        grid_row_selected_val = storage_assets.grid.getSelectedRowId();

        if (((tab_id.indexOf('tab_') == -1 && open_tab != "") || (tab_id.indexOf('tab_') > -1 && tab_id.match(/[0-9]+/))) && grid_row_selected && status !== 'parent') {
            storage_assets.form_type = 'child';
            load_child(win, tab_id, grid_obj);
        } else {
            load_parent(win, tab_id, grid_obj, storage_asset_id);
            storage_assets.form_type = 'parent'
        }
    }

    /*
     * load_storage_assets_callback [callback function]
     */
    function load_storage_assets_callback(result) {
        var active_tab_id = storage_assets.tabbar.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;

        var result_length = result.length;
        var tab_json = '';
        for (i = 0; i < result_length; i++) {
            if (i > 0)
                tab_json = tab_json + ",";
            tab_json = tab_json + (result[i][1]);
        }
        tab_json = '{tabs: [' + tab_json + ']}';

        storage_assets["storage_assets_tab_" + active_object_id] = storage_assets["inner_tab_layout_" + active_object_id].cells("a").attachTabbar({
            mode: "bottom",
            arrows_mode: "auto"
        });
        storage_assets["storage_assets_tab_" + active_object_id].loadStruct(tab_json);

        // alert(result_length);

        for (j = 0; j < result_length; j++) {
            tab_id = 'detail_tab_' + result[j][0];
            var tab_name = storage_assets["storage_assets_tab_" + active_object_id].cells(tab_id).getText();

            if (result_length == 2) {
                storage_assets["storage_assets_tab_" + active_object_id].isParent = true;
                switch (tab_name) {
                    case get_locale_value("Asset"):
                        load_asset(tab_id, result[j][2]);
                        break;
                    case get_locale_value("Capacity"):
                        load_capacity(tab_id, result[j][2]);
                        break;
                }
            } else {
                switch (tab_name) {
                    case get_locale_value("General"):
                        load_general(tab_id, result[j][2]);
                        break;
                    case get_locale_value("Constraints"):
                        load_constraints(tab_id);
                        break;
                    case get_locale_value("Ratchets"):
                        load_ratchets(tab_id);
                        break;
                }
            }
        }
    }

    /*
     * Load Asset [Load the form of Asset tab]
     */
    function load_asset(tab_id, form_json) {
        var active_tab_id = storage_assets.tabbar.getActiveTab();

        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;

        var asset_layout_json = {
            pattern: "2E",
            cells: [{
                    id: "a",
                    text: "Storage Asset",
                    width: 100,
                    height: 100,
                    header: false
                },
                {
                    id: "b",
                    text: "Storage Asset Owner",
                    height: 500
                },
            ]
        }

        storage_assets["asset_layout" + active_object_id] = storage_assets["storage_assets_tab_" + active_object_id].cells(tab_id).attachLayout(asset_layout_json);

        storage_assets["asset_form" + active_object_id] = storage_assets["asset_layout" + active_object_id].cells('a').attachForm();

        storage_assets["asset_form" + active_object_id].loadStruct(form_json);

        //Menu for the Asset Owner Grid
        var asset_owner_toolbar = [{
                id: "save",
                text: "Save",
                img: "save.gif",
                imgdis: "save_dis.gif",
                title: "Save",
                enabled: has_rights_strorage_assets_ui
            },
            {
                id: "t1",
                text: "Edit",
                img: "edit.gif",
                items: [{
                        id: "add",
                        text: "Add",
                        img: "new.gif",
                        imgdis: "new_dis.gif",
                        title: "Add",
                        enabled: has_rights_strorage_assets_ui
                    },
                    {
                        id: "delete",
                        text: "Delete",
                        img: "trash.gif",
                        imgdis: "trash_dis.gif",
                        title: "Delete",
                        enabled: 0
                    }
                ]
            },
            {
                id: "t2",
                text: "Export",
                img: "export.gif",
                items: [{
                        id: "excel",
                        text: "Excel",
                        img: "excel.gif",
                        imgdis: "excel_dis.gif",
                        title: "Excel"
                    },
                    {
                        id: "pdf",
                        text: "PDF",
                        img: "pdf.gif",
                        imgdis: "pdf_dis.gif",
                        title: "PDF"
                    }
                ]
            }
        ];

        storage_assets["asset_owner_toolbar_" + active_object_id] = storage_assets["asset_layout" + active_object_id].cells('b').attachMenu();
        storage_assets["asset_owner_toolbar_" + active_object_id].setIconsPath(image_path + 'dhxmenu_web/');
        storage_assets["asset_owner_toolbar_" + active_object_id].loadStruct(asset_owner_toolbar);

        storage_assets["asset_owner_toolbar_" + active_object_id].attachEvent('onClick', function(id) {
            switch (id) {
                case "add":
                    var new_id = (new Date()).valueOf();
                    storage_assets["asset_owner_" + active_object_id].addRow(new_id, ['', '', '']);
                    break;
                case "delete":
                    var cons_flag = 0;
                    var row_id = storage_assets["asset_owner_" + active_object_id].getSelectedRowId();
                    var row_id_array = row_id.split(",");
                    for (count = 0; count < row_id_array.length; count++) {
                        if (storage_assets["asset_owner_" + active_object_id].cells(row_id_array[count], 0).getValue() != '') {
                            cons_flag = 1;
                        }
                        storage_assets["asset_owner_" + active_object_id].deleteRow(row_id_array[count]);
                    }

                    if (row_id_array != '' && cons_flag == 1) {
                        storage_assets["asset_owner_" + active_object_id].setUserData("", "deleted_xml", "deleted");
                    }
                    break;
                case "excel":
                    storage_assets["asset_owner_" + active_object_id].toExcel(php_script_loc + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                    break;
                case "pdf":
                    storage_assets["asset_owner_" + active_object_id].toPDF(php_script_loc + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                    break;
                case "save":
                    var grid_obj = storage_assets["asset_owner_" + active_object_id];
                    var r_count = grid_obj.getRowsNum();
                    grid_obj.clearSelection();
                    var grid_xml = "<Grid>";
                    for (var row_index = 0; row_index < r_count; row_index++) {
                        grid_xml += "<GridRow ";
                        for (var cell_index = 0, c_count = grid_obj.getColumnsNum(); cell_index < c_count; cell_index++) {
                            if (grid_obj.getColType(cell_index) == 'dhxCalendarA') {
                                //alert(dates.convert_to_sql(grid_obj.cells2(row_index,cell_index).getValue()));    //dates.convert_to_sql()
                                grid_xml += " " + grid_obj.getColumnId(cell_index) + '="' + grid_obj.cells2(row_index, cell_index).getValue() + '"';
                            } else {
                                grid_xml += " " + grid_obj.getColumnId(cell_index) + '="' + grid_obj.cells2(row_index, cell_index).getValue() + '"';
                            }
                        }
                        grid_xml += '  storage_asset = "' + active_object_id + '"';
                        grid_xml += " ></GridRow> ";
                    }
                    grid_xml += "</Grid>";
                    var data = {
                        "action": "spa_storage_assets",
                        "flag": 's',
                        "general_xml": grid_xml,
                        "storage_asset_id": storage_assets["asset_form" + active_object_id].getItemValue('storage_asset_id')
                    };

                    adiha_post_data('alert', data, '', '', '', '');
                    break;
            }
        });

        //Creating the Asset Owner grid
        storage_assets["asset_owner_" + active_object_id] = storage_assets["asset_layout" + active_object_id].cells('b').attachGrid();
        storage_assets["asset_owner_" + active_object_id].setHeader(get_locale_value('ID, Effective Date, Counterparty, Percentage',true));
        storage_assets["asset_owner_" + active_object_id].attachHeader('#text_filter,#text_filter,#text_filter,#text_filter');
        storage_assets["asset_owner_" + active_object_id].setColumnIds("storage_asset_owner_id, effective_date, counterparty_id, percentage");
        storage_assets["asset_owner_" + active_object_id].setColTypes("ro,dhxCalendarA,combo,ed");
        storage_assets["asset_owner_" + active_object_id].setColumnMinWidth("100,200,150,150");
        storage_assets["asset_owner_" + active_object_id].setInitWidths('100,200,150,*');
        storage_assets["asset_owner_" + active_object_id].setColSorting("int,date,int,int");
        storage_assets["asset_owner_" + active_object_id].init();
        storage_assets["asset_owner_" + active_object_id].setColumnsVisibility('true,false,false,false');
        storage_assets["asset_owner_" + active_object_id].setDateFormat(user_date_format, "%Y-%m-%d");
        storage_assets["asset_owner_" + active_object_id].enableMultiselect(true);
        storage_assets["asset_owner_" + active_object_id].enableHeaderMenu();

        var cm_param = {
            "action": "[spa_generic_mapping_header]",
            "flag": "n",
            "combo_sql_stmt": "EXEC spa_source_counterparty_maintain 'c'",
            "call_from": "grid"
        };

        cm_param = $.param(cm_param);

        var url = js_dropdown_connector_url + '&' + cm_param;
        var combo_obj = storage_assets["asset_owner_" + active_object_id].getColumnCombo(2);
        combo_obj.enableFilteringMode("between", null, false);
        combo_obj.load(url);
        //load grid data
        var sql_param = {
            "flag": "o",
            "action": "spa_storage_assets",
            "grid_type": "g",
            "storage_asset_id": active_object_id
        };

        sql_param = $.param(sql_param);
        var sql_url = js_data_collector_url + "&" + sql_param;

        storage_assets["asset_owner_" + active_object_id].clearAll();
        storage_assets["asset_owner_" + active_object_id].load(sql_url);

        storage_assets["asset_owner_" + active_object_id].attachEvent("onRowSelect", function(id, ind) {
            if (has_rights_strorage_assets_ui) {
                storage_assets["asset_owner_toolbar_" + active_object_id].setItemEnabled('delete');
            }
        });
    }

    /*
     * Load Asset [Load the form of Asset tab]
     */
    function load_capacity(tab_id, form_json) {
        var active_tab_id = storage_assets.tabbar.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;

        var capacity_layout_json = {
            pattern: "2E",
            cells: [{
                    id: "a",
                    text: "Filters",
                    width: 100,
                    height: 100,
                    header: true
                },
                {
                    id: "b",
                    text: "Storage Asset Capacity",
                    height: 500
                },
            ]
        }

        storage_assets["capacity_layout" + active_object_id] = storage_assets["storage_assets_tab_" + active_object_id].cells(tab_id).attachLayout(capacity_layout_json);

        storage_assets["capacity_form" + active_object_id] = storage_assets["capacity_layout" + active_object_id].cells('a').attachForm();

        // filter_obj = storage_assets["capacity_layout" + active_object_id].cells('a').attachForm();
        // var layout_cell_obj = storage_assets["capacity_layout" + active_object_id].cells('b');
        // load_form_filter(filter_obj,layout_cell_obj,10162301,'a');

        storage_assets["capacity_form" + active_object_id].loadStruct(form_json);

        //Menu for the Constraints Grid
        var asset_capacity_toolbar = [{
                id: "save",
                text: "Save",
                img: "save.gif",
                imgdis: "save_dis.gif",
                title: "Save",
                enabled: has_rights_strorage_assets_ui
            },
            {
                id: "refresh",
                img: "refresh.gif",
                text: "Refresh"
            },
            {
                id: "t1",
                text: "Edit",
                img: "edit.gif",
                items: [{
                        id: "add",
                        text: "Add",
                        img: "new.gif",
                        imgdis: "new_dis.gif",
                        title: "Add",
                        enabled: has_rights_strorage_assets_ui
                    },
                    {
                        id: "delete",
                        text: "Delete",
                        img: "trash.gif",
                        imgdis: "trash_dis.gif",
                        title: "Delete",
                        enabled: 0
                    }
                ]
            },
            {
                id: "t2",
                text: "Export",
                img: "export.gif",
                items: [{
                        id: "excel",
                        text: "Excel",
                        img: "excel.gif",
                        imgdis: "excel_dis.gif",
                        title: "Excel"
                    },
                    {
                        id: "pdf",
                        text: "PDF",
                        img: "pdf.gif",
                        imgdis: "pdf_dis.gif",
                        title: "PDF"
                    }
                ]
            }
        ];

        storage_assets["asset_capacity_toolbar_" + active_object_id] = storage_assets["capacity_layout" + active_object_id].cells('b').attachMenu();
        storage_assets["asset_capacity_toolbar_" + active_object_id].setIconsPath(image_path + 'dhxmenu_web/');
        storage_assets["asset_capacity_toolbar_" + active_object_id].loadStruct(asset_capacity_toolbar);

        storage_assets["capacity_form" + active_object_id].attachEvent('onChange', function(name, value) {
            if (name == 'effective_date') {
                if (value) {
                    var data = {
                        "flag": "k",
                        "action": "spa_storage_asset_parent",
                        "storage_asset_id": active_object_id,
                        "effective_date": storage_assets["capacity_form" + active_object_id].getItemValue(name, true)
                    };
                    adiha_post_data('return_array', data, '', '', 'set_total_capcity');
                } else {
                    storage_assets["capacity_form" + active_object_id].setItemValue('capacity', '');
                }
                storage_assets["asset_capacity_toolbar_" + active_object_id].callEvent("onClick", ['refresh']);
            }
        });

        var current_date = new Date().toJSON().slice(0, 10);
        storage_assets["capacity_form" + active_object_id].setItemValue('effective_date', current_date);
        storage_assets["capacity_form" + active_object_id].callEvent("onChange", ['effective_date', current_date]);

        storage_assets["asset_capacity_toolbar_" + active_object_id].attachEvent('onClick', function(id) {
            switch (id) {
                case "refresh":
                    var value = storage_assets["capacity_form" + active_object_id].getItemValue('effective_date', true);

                    var sql_param = {
                        "flag": "c",
                        "action": "spa_storage_asset_parent",
                        "grid_type": "g",
                        "storage_asset_id": active_object_id,
                        "effective_date": value
                    };
                    sql_param = $.param(sql_param);
                    var sql_url = js_data_collector_url + "&" + sql_param;

                    storage_assets["asset_capacity_" + active_object_id].clearAll();
                    storage_assets["asset_capacity_" + active_object_id].load(sql_url);
                    break;
                case "save":
                    var grid_obj = storage_assets["asset_capacity_" + active_object_id];
                    grid_obj.clearSelection();
                    var r_count = grid_obj.getRowsNum();

                    var grid_xml = "<Grid>";
                    for (var row_index = 0; row_index < r_count; row_index++) {
                        grid_xml += "<GridRow ";
                        for (var cell_index = 0, c_count = grid_obj.getColumnsNum(); cell_index < c_count; cell_index++) {
                            if (grid_obj.getColType(cell_index) == 'dhxCalendarA') {
                                //alert(dates.convert_to_sql(grid_obj.cells2(row_index,cell_index).getValue()));    //dates.convert_to_sql()
                                grid_xml += " " + grid_obj.getColumnId(cell_index) + '="' + grid_obj.cells2(row_index, cell_index).getValue() + '"';
                            } else {
                                grid_xml += " " + grid_obj.getColumnId(cell_index) + '="' + grid_obj.cells2(row_index, cell_index).getValue() + '"';
                            }
                        }
                        grid_xml += '  storage_asset = "' + active_object_id + '"';
                        grid_xml += " ></GridRow> ";
                    }
                    grid_xml += "</Grid>";
                    var data = {
                        "action": "spa_storage_asset_parent",
                        "flag": 's',
                        "asset_xml": grid_xml,
                        "storage_asset_id": storage_assets["asset_form" + active_object_id].getItemValue('storage_asset_id')
                    };

                    adiha_post_data('return_array', data, '', '', 'storage_assets.after_save_capacity');
                    break;
                case "add":
                    var new_id = (new Date()).valueOf();
                    storage_assets["asset_capacity_" + active_object_id].addRow(new_id, ['', '', '', '', '', '']);
                    break;
                case "delete":
                    var cons_flag = 0;
                    var row_id = storage_assets["asset_capacity_" + active_object_id].getSelectedRowId();
                    var row_id_array = row_id.split(",");
                    for (count = 0; count < row_id_array.length; count++) {
                        if (storage_assets["asset_capacity_" + active_object_id].cells(row_id_array[count], 0).getValue() != '') {
                            cons_flag = 1;
                        }
                        storage_assets["asset_capacity_" + active_object_id].deleteRow(row_id_array[count]);
                    }

                    if (row_id_array != '' && cons_flag == 1) {
                        storage_assets["asset_capacity_" + active_object_id].setUserData("", "deleted_xml", "deleted");
                    }
                    break;
                case "excel":
                    storage_assets["asset_capacity_" + active_object_id].toExcel(php_script_loc + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                    break;
                case "pdf":
                    storage_assets["asset_capacity_" + active_object_id].toPDF(php_script_loc + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                    break;
            }
        });

        // Creating the constraints grid
        storage_assets["asset_capacity_" + active_object_id] = storage_assets["capacity_layout" + active_object_id].cells('b').attachGrid();
        storage_assets["asset_capacity_" + active_object_id].setHeader(get_locale_value('Capacity ID, Effective Date, Reservoir, Reservoir Type, Capacity, UOM',true));
        storage_assets["asset_capacity_" + active_object_id].attachHeader('#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter');
        storage_assets["asset_capacity_" + active_object_id].setColumnIds("asset_capacity_id,effective_date,reservoir,reservoir_type,capacity,uom");
        storage_assets["asset_capacity_" + active_object_id].setColTypes("ro,dhxCalendarA,combo,combo,ed,combo");
        storage_assets["asset_capacity_" + active_object_id].setColumnMinWidth("0,200,150,150,150,150");
        storage_assets["asset_capacity_" + active_object_id].setInitWidths('0,250,150,150,150,*');
        storage_assets["asset_capacity_" + active_object_id].setColSorting("int,date,int,str,str,str");
        storage_assets["asset_capacity_" + active_object_id].init();
        storage_assets["asset_capacity_" + active_object_id].setColumnsVisibility('true,false,false,false,false,false');
        storage_assets["asset_capacity_" + active_object_id].setDateFormat(user_date_format, "%Y-%m-%d");
        storage_assets["asset_capacity_" + active_object_id].enableMultiselect(true);

        var col_reservoir = storage_assets["asset_capacity_" + active_object_id].getColIndexById('reservoir');
        var col_reservoir_type = storage_assets["asset_capacity_" + active_object_id].getColIndexById('reservoir_type');
        var col_uom = storage_assets["asset_capacity_" + active_object_id].getColIndexById('uom');
        var cmb_reservoir = storage_assets["asset_capacity_" + active_object_id].getColumnCombo(col_reservoir);
        var cmb_reservoir_type = storage_assets["asset_capacity_" + active_object_id].getColumnCombo(col_reservoir_type);
        var cmb_uom = storage_assets["asset_capacity_" + active_object_id].getColumnCombo(col_uom);
        var cmb_sql_param = {
            "flag": "h",
            "action": "spa_StaticDataValues",
            "type_id": "105000",
            "has_blank_option": "false"
        };

        cmb_sql_param = $.param(cmb_sql_param);
        var cmb_sql_url = js_dropdown_connector_url + '&' + cmb_sql_param;
        cmb_reservoir.load(cmb_sql_url);


        cmb_sql_param = {
            "flag": "s",
            "action": "spa_source_uom_maintain",
            "has_blank_option": "false"
        };

        cmb_sql_param = $.param(cmb_sql_param);
        cmb_sql_url = js_dropdown_connector_url + '&' + cmb_sql_param;
        cmb_uom.load(cmb_sql_url);

        cmb_sql_param = {
            "flag": "h",
            "action": "spa_StaticDataValues",
            "type_id": "105100",
            "has_blank_option": "false"
        };

        cmb_sql_param = $.param(cmb_sql_param);
        cmb_sql_url = js_dropdown_connector_url + '&' + cmb_sql_param;


        cmb_reservoir_type.load(cmb_sql_url, function() {
            //load grid data
            var sql_param = {
                "flag": "c",
                "action": "spa_storage_asset_parent",
                "grid_type": "g",
                "storage_asset_id": active_object_id,
                "effective_date": current_date
            };

            sql_param = $.param(sql_param);
            var sql_url = js_data_collector_url + "&" + sql_param;

            storage_assets["asset_capacity_" + active_object_id].clearAll();
            storage_assets["asset_capacity_" + active_object_id].load(sql_url);
        });

        storage_assets["asset_capacity_" + active_object_id].attachEvent("onRowSelect", function(id, ind) {
            if (has_rights_strorage_assets_ui) {
                storage_assets["asset_capacity_toolbar_" + active_object_id].setItemEnabled('delete');
            }
        });

    }

    storage_assets.after_save_capacity = function() {

        // alert
        dhtmlx.message({
            text: "Changes have been saved successfully.",
            expire: 1000
        });

        var active_tab_id = storage_assets.tabbar.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        var data = {
            "flag": "k",
            "action": "spa_storage_asset_parent",
            "storage_asset_id": active_object_id,
            "effective_date": storage_assets["capacity_form" + active_object_id].getItemValue('effective_date', true)
        };
        adiha_post_data('return_array', data, '', '', 'set_total_capcity');
    }

    /*
     * load_general [Load the form of general tab]
     */
    function load_general(tab_id, form_json) {
        var active_tab_id = storage_assets.tabbar.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        storage_assets["general_form" + active_object_id] = storage_assets["storage_assets_tab_" + active_object_id].cells(tab_id).attachForm();
        if (form_json) {
            storage_assets["general_form" + active_object_id].loadStruct(form_json);
        }

        // Disable counterparty combo in update mode.
        if (active_tab_id.indexOf('tab_') != -1) {
            storage_assets["general_form" + active_object_id].disableItem('source_counterparty_id');
        }

        if (open_tab != '' && open_tab != 'new') {
            storage_assets["general_form" + active_object_id].setItemValue('agreement', contract_id);
            storage_assets["general_form" + active_object_id].setItemValue('source_counterparty_id', counterparty_id);
            storage_assets["general_form" + active_object_id].disableItem('agreement');
            storage_assets["general_form" + active_object_id].disableItem('storage_location');
        }
        open_tab = '';

        attach_browse_event("storage_assets.general_form" + active_object_id, 10162300);

        grid_row_selected_val = storage_assets.grid.getSelectedRowId();
        var g_level = storage_assets.grid.getLevel(grid_row_selected_val);
        if (g_level != 0) {
            grid_row_selected_val = storage_assets.grid.getParentId(grid_row_selected_val);
        }

        data = {
            "action": "spa_storage_assets",
            "flag": "f",
            "storage_asset_id": grid_row_selected_val
        };
        adiha_post_data('return_array', data, '', '', 'load_default_asset_id', '');

    }

    /*
     * load_constraints [Load the grid of constraints tab]
     */
    function load_constraints(tab_id) {
        var active_tab_id = storage_assets.tabbar.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;

        //Menu for the Constraints Grid
        var constraints_toolbar = [{
                id: "t1",
                text: "Edit",
                img: "edit.gif",
                items: [{
                        id: "add",
                        text: "Add",
                        img: "new.gif",
                        imgdis: "new_dis.gif",
                        title: "Add",
                        enabled: has_rights_strorage_assets_ui
                    },
                    {
                        id: "delete",
                        text: "Delete",
                        img: "trash.gif",
                        imgdis: "trash_dis.gif",
                        title: "Delete",
                        enabled: 0
                    }
                ]
            },
            {
                id: "t2",
                text: "Export",
                img: "export.gif",
                items: [{
                        id: "excel",
                        text: "Excel",
                        img: "excel.gif",
                        imgdis: "excel_dis.gif",
                        title: "Excel"
                    },
                    {
                        id: "pdf",
                        text: "PDF",
                        img: "pdf.gif",
                        imgdis: "pdf_dis.gif",
                        title: "PDF"
                    }
                ]
            }
        ];

        storage_assets["constraints_toolbar_" + active_object_id] = storage_assets["storage_assets_tab_" + active_object_id].cells(tab_id).attachMenu();
        storage_assets["constraints_toolbar_" + active_object_id].setIconsPath(image_path + 'dhxmenu_web/');
        storage_assets["constraints_toolbar_" + active_object_id].loadStruct(constraints_toolbar);
        storage_assets["constraints_toolbar_" + active_object_id].attachEvent('onClick', function(id) {
            switch (id) {
                case "add":
                    var new_id = (new Date()).valueOf();
                    storage_assets["constraints_" + active_object_id].addRow(new_id, ['', '', '', '', '', 'd']);
                    break;
                case "delete":
                    var cons_flag = 0;
                    var row_id = storage_assets["constraints_" + active_object_id].getSelectedRowId();
                    var row_id_array = row_id.split(",");
                    for (count = 0; count < row_id_array.length; count++) {
                        if (storage_assets["constraints_" + active_object_id].cells(row_id_array[count], 0).getValue() != '') {
                            cons_flag = 1;
                        }
                        storage_assets["constraints_" + active_object_id].deleteRow(row_id_array[count]);
                    }

                    if (row_id_array != '' && cons_flag == 1) {
                        storage_assets["constraints_" + active_object_id].setUserData("", "deleted_xml", "deleted");
                    }
                    break;
                case "excel":
                    storage_assets["constraints_" + active_object_id].toExcel(php_script_loc + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                    break;
                case "pdf":
                    storage_assets["constraints_" + active_object_id].toPDF(php_script_loc + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                    break;
            }
        });

        //Creating the constraints grid
        storage_assets["constraints_" + active_object_id] = storage_assets["storage_assets_tab_" + active_object_id].cells(tab_id).attachGrid();
        storage_assets["constraints_" + active_object_id].setHeader(get_locale_value('Constraint ID, Constraint Type, Value, UOM, Effective Date, Frequency',true));
        storage_assets["constraints_" + active_object_id].setColumnIds("constraint_id, constraint_type, value, uom, effective_date, frequency");
        storage_assets["constraints_" + active_object_id].setColTypes("ro,combo,ed_no,combo,dhxCalendarA,combo");
        storage_assets["constraints_" + active_object_id].setColumnMinWidth("0,200,150,150,150,150");
        storage_assets["constraints_" + active_object_id].setInitWidths('0,250,150,150,150,*');
        storage_assets["constraints_" + active_object_id].setColSorting("int,str,int,str,str,str");
        storage_assets["constraints_" + active_object_id].init();
        storage_assets["constraints_" + active_object_id].setColumnsVisibility('true,false,false,false,false,false');
        storage_assets["constraints_" + active_object_id].setDateFormat(user_date_format, "%Y-%m-%d");
        storage_assets["constraints_" + active_object_id].enableMultiselect(true);

        storage_assets["constraints_" + active_object_id].attachEvent("onRowSelect", function(id, ind) {
            if (has_rights_strorage_assets_ui) {
                storage_assets["constraints_toolbar_" + active_object_id].setItemEnabled('delete');
            }
        });

        //Loading dropdown for Constraint Type in grid
        var cm_param = {
            "action": "[spa_generic_mapping_header]",
            "flag": "n",
            "combo_sql_stmt": "SELECT value_id, code FROM static_data_value WHERE type_id = 18600",
            "call_from": "grid"
        };

        cm_param = $.param(cm_param);
        var url = js_dropdown_connector_url + '&' + cm_param;
        var combo_obj = storage_assets["constraints_" + active_object_id].getColumnCombo(1);
        combo_obj.enableFilteringMode(true);
        combo_obj.load(url);

        //Loading dropdown for UOM in grid
        var cm_param = {
            "action": "[spa_generic_mapping_header]",
            "flag": "n",
            "combo_sql_stmt": "SELECT source_uom_id, uom_name FROM source_uom",
            "call_from": "grid"
        };

        cm_param = $.param(cm_param);
        var url1 = js_dropdown_connector_url + '&' + cm_param;
        var combo_obj1 = storage_assets["constraints_" + active_object_id].getColumnCombo(3);
        combo_obj1.enableFilteringMode(true);
        combo_obj1.load(url1);

        //Loading dropdown for Frequency in grid
        var cm_param = {
            "action": "spa_getVolumeFrequency",
            "exclude_values": "h,m,a,t,x,y"

        };

        cm_param = $.param(cm_param);
        var url2 = js_dropdown_connector_url + '&' + cm_param;
        var combo_obj2 = storage_assets["constraints_" + active_object_id].getColumnCombo(5);
        combo_obj2.enableFilteringMode(true);

        combo_obj2.load(url2, function() {
            var flag = 'g';
            var sql_param = {
                "flag": flag,
                "action": "spa_storage_assets",
                "grid_type": "g",
                "general_assets_id": active_object_id
            };
            sql_param = $.param(sql_param);
            var sql_url = js_data_collector_url + "&" + sql_param;
            storage_assets["constraints_" + active_object_id].clearAll();
            storage_assets["constraints_" + active_object_id].load(sql_url);
        });
    }

    /*
     * load_ratchets [Load the grid of ratchets tab]
     */
    function load_ratchets(tab_id) {
        var active_tab_id = storage_assets.tabbar.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;

        //Menu for the Ratchets Grid
        var ratchets_toolbar = [{
                id: "t1",
                text: "Edit",
                img: "edit.gif",
                items: [{
                        id: "add",
                        text: "Add",
                        img: "new.gif",
                        imgdis: "new_dis.gif",
                        title: "Add",
                        enabled: has_rights_strorage_assets_ui
                    },
                    {
                        id: "delete",
                        text: "Delete",
                        img: "trash.gif",
                        imgdis: "trash_dis.gif",
                        title: "Delete",
                        enabled: 0
                    }
                ]
            },
            {
                id: "t2",
                text: "Export",
                img: "export.gif",
                items: [{
                        id: "excel",
                        text: "Excel",
                        img: "excel.gif",
                        imgdis: "excel_dis.gif",
                        title: "Excel"
                    },
                    {
                        id: "pdf",
                        text: "PDF",
                        img: "pdf.gif",
                        imgdis: "pdf_dis.gif",
                        title: "PDF"
                    }
                ]
            }
        ];

        storage_assets["ratchets_toolbar_" + active_object_id] = storage_assets["storage_assets_tab_" + active_object_id].cells(tab_id).attachMenu();
        storage_assets["ratchets_toolbar_" + active_object_id].setIconsPath(image_path + 'dhxmenu_web/');
        storage_assets["ratchets_toolbar_" + active_object_id].loadStruct(ratchets_toolbar);
        storage_assets["ratchets_toolbar_" + active_object_id].attachEvent('onClick', function(id) {
            switch (id) {
                case "add":
                    var new_id = (new Date()).valueOf();
                    storage_assets["ratchets_" + active_object_id].addRow(new_id, ['', '', '', '', '', '', '', '']);
                    break;
                case "delete":
                    var cons_flag = 0;
                    var row_id = storage_assets["ratchets_" + active_object_id].getSelectedRowId();
                    var row_id_array = row_id.split(",");
                    for (count = 0; count < row_id_array.length; count++) {
                        if (storage_assets["ratchets_" + active_object_id].cells(row_id_array[count], 0).getValue() != '') {
                            cons_flag = 1;
                        }
                        storage_assets["ratchets_" + active_object_id].deleteRow(row_id_array[count]);
                    }

                    if (row_id_array != '' && cons_flag == 1) {
                        storage_assets["ratchets_" + active_object_id].setUserData("", "deleted_xml", "deleted");
                    }
                    break;
                case "excel":
                    storage_assets["ratchets_" + active_object_id].toExcel(php_script_loc + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                    break;
                case "pdf":
                    storage_assets["ratchets_" + active_object_id].toPDF(php_script_loc + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                    break;
            }
        });

        var grid_cookies = "grid_ratchets";

        //Creating the constraints grid
        storage_assets["ratchets_" + active_object_id] = storage_assets["storage_assets_tab_" + active_object_id].cells(tab_id).attachGrid();
        storage_assets["ratchets_" + active_object_id].setHeader(get_locale_value('Ratchet ID, Term From, Term To, Inventory Level From, Inventory Level To, Gas in Storage % From, Gas in Storage % To, Type, % of Contracted Storage Space, Fixed Value',true));
        storage_assets["ratchets_" + active_object_id].setColumnIds("storage_ratchet_id,term_from,term_to,inventory_level_from,inventory_level_to,gas_in_storage_perc_from,gas_in_storage_perc_to,type,perc_of_contracted_storage_space,fixed_value");
        storage_assets["ratchets_" + active_object_id].attachHeader('#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter')
        storage_assets["ratchets_" + active_object_id].setColTypes("ro,dhxCalendarA,dhxCalendarA,ed,ed,ed,ed,combo,ed,ed_no");
        storage_assets["ratchets_" + active_object_id].setColumnMinWidth("0,150,150,150,150,150,150,150,180,100");
        storage_assets["ratchets_" + active_object_id].setInitWidths('0,150,150,150,150,150,150,150,180,150');
        storage_assets["ratchets_" + active_object_id].setColSorting("int,date,date,str,str,str,str,str,str,int");
        storage_assets["ratchets_" + active_object_id].attachEvent("onKeyPress", storage_assets.onKeyPressed);
        storage_assets["ratchets_" + active_object_id].enableBlockSelection();
        storage_assets["ratchets_" + active_object_id].enableMultiselect(true);
        storage_assets["ratchets_" + active_object_id].enableColumnMove(true);
        storage_assets["ratchets_" + active_object_id].init();
        storage_assets["ratchets_" + active_object_id].setColumnsVisibility('true,false,false,false,false,false,false,false,false,false');
        storage_assets["ratchets_" + active_object_id].setDateFormat(user_date_format, '%Y-%m-%d');
        storage_assets["ratchets_" + active_object_id].loadOrderFromCookie(grid_cookies);
        storage_assets["ratchets_" + active_object_id].loadHiddenColumnsFromCookie(grid_cookies);
        storage_assets["ratchets_" + active_object_id].enableOrderSaving(grid_cookies);
        storage_assets["ratchets_" + active_object_id].enableAutoHiddenColumnsSaving(grid_cookies);

        storage_assets["ratchets_" + active_object_id].attachEvent("onRowSelect", function(id, ind) {
            if (has_rights_strorage_assets_ui) {
                storage_assets["ratchets_toolbar_" + active_object_id].setItemEnabled('delete');
            }
        });

        var cm_param = {
            "action": "[spa_generic_mapping_header]",
            "flag": "n",
            "combo_sql_stmt": "select 'w' id,'Withdrawal' value Union select 'i' id,'Injection' value",
            "call_from": "grid"
        };

        cm_param = $.param(cm_param);
        var url = js_dropdown_connector_url + '&' + cm_param;
        var col_type_no = storage_assets["ratchets_" + active_object_id].getColIndexById('type');
        var combo_obj = storage_assets["ratchets_" + active_object_id].getColumnCombo(col_type_no);
        combo_obj.enableFilteringMode(true);
        combo_obj.load(url);

        var flag = 'r';
        var sql_param = {
            "flag": flag,
            "action": "spa_storage_assets",
            "grid_type": "g",
            "general_assets_id": active_object_id
        };
        sql_param = $.param(sql_param);
        var sql_url = js_data_collector_url + "&" + sql_param;
        storage_assets["ratchets_" + active_object_id].clearAll();
        storage_assets["ratchets_" + active_object_id].load(sql_url);
    }

    storage_assets.onKeyPressed = function(code, ctrl, shift) {
        var active_tab_id = storage_assets.tabbar.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        if (code == 86 && ctrl) {
            storage_assets["ratchets_" + active_object_id].setCSVDelimiter("\t");
            storage_assets["ratchets_" + active_object_id].pasteBlockFromClipboard()
        }
        return true;
    }

    function refresh_constraints_grid() {
        var active_tab_id = storage_assets.tabbar.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;

        var flag = 'g';
        var sql_param = {
            "flag": flag,
            "action": "spa_storage_assets",
            "grid_type": "g",
            "general_assets_id": active_object_id
        };
        sql_param = $.param(sql_param);
        var sql_url = js_data_collector_url + "&" + sql_param;
        storage_assets["constraints_" + active_object_id].clearAll();
        storage_assets["constraints_" + active_object_id].load(sql_url);
    }

    function refresh_ratchets_grid() {
        var active_tab_id = storage_assets.tabbar.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;

        var flag = 'r';
        var sql_param = {
            "flag": flag,
            "action": "spa_storage_assets",
            "grid_type": "g",
            "general_assets_id": active_object_id
        };
        sql_param = $.param(sql_param);
        var sql_url = js_data_collector_url + "&" + sql_param;
        storage_assets["ratchets_" + active_object_id].clearAll();
        storage_assets["ratchets_" + active_object_id].load(sql_url);
    }

    /*
     * Refresh the grid
     */
    function refresh_grid() {
        // var param = {
        //                 "action": "('SELECT sml.Location_Name AS [location_name],cg.contract_name AS [contract_name], general_assest_id AS [id] FROM [general_assest_info_virtual_storage] gaivs INNER JOIN contract_group cg ON cg.contract_id = gaivs.agreement INNER JOIN source_minor_location sml ON sml.source_minor_location_id = gaivs.storage_location')",
        //                 "grid_type": "tg",
        //                 "grouping_column": "location_name,contract_name",            
        //          };

        var param = {
            "action": "spa_storage_assets 't'",
            "grid_type": "tg",
            "grouping_column": "asset_description,location_name",
        };

        param = $.param(param);
        var param_url = js_data_collector_url + "&" + param;
        console.log(param_url);
        storage_assets.grid.clearAll();
        storage_assets.grid.loadXML(param_url);
    }

    function load_default_asset_id(result) {

        if (result.length == 0) return;

        var return_data = JSON.parse(result);

        var active_tab_id = storage_assets.tabbar.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;

        storage_assets["general_form" + active_object_id].setItemValue('storage_asset_id', return_data);


        data = {
            "action": "spa_storage_assets",
            "flag": "b",
            "storage_asset_id": return_data
        };
        adiha_post_data('return_json', data, '', '', 'load_capacity_general', '');

    }

    function load_capacity_general(result) {

        var return_data = JSON.parse(result);

        if (return_data.length == 0) return;

        var active_tab_id = storage_assets.tabbar.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;

        storage_assets["general_form" + active_object_id].setItemValue('storage_capacity', return_data[0]['capacity']);
    }

    function set_total_capcity(result) {
        var active_tab_id = storage_assets.tabbar.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        storage_assets["capacity_form" + active_object_id].setItemValue('capacity', result[0][0]);
    }
</script>

</html>