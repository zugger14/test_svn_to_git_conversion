<?php

/**
 * Setup menu screen
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
<?php
$php_script_loc = $app_php_script_loc;
$form_namespace = 'setup_menu';
$application_function_id = 10105000;
$rights_setup_menu_iu = 10105001;
$rights_setup_menu_del = 10105002;

$has_rights_setup_menu_iu = false;
$has_right_setup_menu_del = false;

list(
    $has_rights_setup_menu_iu,
    $has_right_setup_menu_del
) = build_security_rights(
    $rights_setup_menu_iu,
    $rights_setup_menu_del
);

$form_obj = new AdihaStandardForm($form_namespace, $application_function_id);
$form_obj->define_grid("SetupMenu", "", "r");
$form_obj->define_layout_width(600);
$form_obj->define_custom_functions('save_setup_menu');
$form_obj->define_apply_filters(true, '10105003', 'FilterSetupMenu', 'General');

echo $form_obj->init_form('Menu Structure');
echo $form_obj->close_form();

?>

<body>
</body>
<script type="text/javascript">
    var has_rights_setup_menu_iu = '<?php echo (($has_rights_setup_menu_iu) ? $has_rights_setup_menu_iu : '0'); ?>';
    var has_rights_setup_menu_del = '<?php echo (($has_right_setup_menu_del) ? $has_right_setup_menu_del : '0'); ?>';
    var context_menu;
    var deleted_row_ids = new Array();
    var edited_row_ids = new Array();
    var moved_row_ids = new Array();
    var smid = new Array();
    var counter = 0;
    var debug_mode = true;
    var move = false;
    var expand_collapse = 'expand';


    $(function() {
        if (!has_rights_setup_menu_iu) {
            setup_menu.menu.setItemDisabled('add');
        }

        setup_menu.menu.addNewSibling('t1', 'save', 'Save', false, 'save.gif', 'save_dis.gif');
        setup_menu.menu.addNewSibling('save', 'hide_show', 'Show Hidden', false, 'show.png', 'show_dis.png');
        setup_menu.menu.addNewSibling('hide_show', 'expand_collapse', 'Expand All', false, 'exp_col.gif', 'exp_col_dis.gif');
        setup_menu.menu.addNewSibling('delete', 'arrange', 'Arrange', false, 'finalize.gif', 'finalize_dis.gif');
        setup_menu.menu.hideItem('add');
        setup_menu.menu.hideItem('delete');
        //setup_menu.grid.enableDragAndDrop(true);

        context_menu = new dhtmlXMenuObject({
            icons_path: js_image_path + 'dhxmenu_web/',
            context: true,
            items: [{
                    id: "add",
                    text: "Add Menu Group",
                    img: "add.gif",
                    imgdis: "add_dis.gif"
                },
                {
                    id: "rename",
                    text: "Rename",
                    img: "edit.gif",
                    imgdis: "edit_dis.gif"
                },
                {
                    id: "delete",
                    text: "Delete",
                    img: "delete.gif",
                    imgdis: "delete_dis.gif"
                },
                {
                    id: "hide_unhide",
                    text: "Hide",
                    img: "hide.png",
                    imgdis: "hide_dis.png"
                }
            ]
        });
        context_menu.renderAsContextMenu();
        setup_menu.grid.enableContextMenu(context_menu);
        //context_menu.setItemImage("add", "add.gif", "add_dis.gif");

        setup_menu.grid.attachEvent("onBeforeContextMenu", function(id) {
            setup_menu.grid.selectRowById(id); // Row should be selected to avoid adding new row somewhere else other than the child items when clicked on 'Add'.

            var return_value;
            level = setup_menu.grid.getLevel(id);
            hide_show_ind = setup_menu.grid.getColIndexById("hide_show");

            // Disable editing/deleting module
            if (level == 0) {
                context_menu.setItemDisabled('add');
                context_menu.setItemEnabled('rename');
                context_menu.setItemDisabled('delete');
            } else if (level == 1) {
                context_menu.setItemEnabled('add');
                context_menu.setItemEnabled('rename');
                context_menu.setItemDisabled('delete');
                context_menu.setItemImage('hide_unhide', 'hide.png', 'hide_dis.png');
            } else if (level == 3) {
                context_menu.setItemDisabled('add');
                context_menu.setItemEnabled('rename');
                context_menu.setItemEnabled('delete');
            } else {
                context_menu.setItemEnabled('add');
                context_menu.setItemEnabled('rename');
                context_menu.setItemEnabled('delete');
            }

            if (setup_menu.grid.cells(id, hide_show_ind).getValue().toLowerCase() == "yes") {
                context_menu.setItemImage('hide_unhide', 'show.png', 'show_dis.png');
                context_menu.setItemText('hide_unhide', 'Unhide');
            } else {
                context_menu.setItemImage('hide_unhide', 'hide.png', 'hide_dis.png');
                context_menu.setItemText('hide_unhide', 'Hide');
            }

            menu_type_ind = setup_menu.grid.getColIndexById("menu_type");
            menu_type = setup_menu.grid.cells(id, menu_type_ind).getValue();
            // Enable context menu for module and menu group only.
            if (level >= 0 && menu_type.toLowerCase() != 'menu') return true;

        });

        setup_menu.grid.attachEvent("onRowDblClicked", function(rId, cInd) {
            var menu_type = setup_menu.grid.cells(rId, menu_type_ind).getValue();
            var group_name_ind = setup_menu.grid.getColIndexById("group_name");

            if (menu_type.toLowerCase() != 'menu' && cInd == group_name_ind) {
                setup_menu.grid.selectCell(rId, group_name_ind);
                setup_menu.grid.editCell();
            }
        });

        context_menu.attachEvent("onClick", function(id) {
            var selected_row_id = setup_menu.grid.getSelectedRowId();
            if (counter == 0) {
                menu_group_name = "New Menu Group";
            } else {
                menu_group_name = "New Menu Group " + counter;
            }

            var row_ind = setup_menu.grid.getRowIndex(selected_row_id);
            var group_name_ind = setup_menu.grid.getColIndexById("group_name");
            var func_id_ind = setup_menu.grid.getColIndexById("function_id");
            var setup_menu_id_ind = setup_menu.grid.getColIndexById("setup_menu_id");
            var parent_menu_id_ind = setup_menu.grid.getColIndexById("parent_menu_id");
            var hide_show_ind = setup_menu.grid.getColIndexById("hide_show");
            var folder_img = 'folder.gif';

            switch (id) {
                case "add":
                    last_child = setup_menu.get_last_child_id_and_index(selected_row_id);
                    if (last_child == 0) {
                        parent_menu_id = setup_menu.grid.cells(selected_row_id, func_id_ind).getValue();
                        setup_menu.grid.addRow("new_id_" + "0_" + parent_menu_id, [menu_group_name, smid[smid.length - 1], smid[smid.length - 1], parent_menu_id, "Menu Group", "No"], 0, selected_row_id, folder_img);
                        setup_menu.grid.openItem(selected_row_id);
                        setup_menu.grid.selectRowById("new_id_" + 0 + "_" + parent_menu_id);
                    } else {
                        parent_menu_id = setup_menu.get_parent_menu_id(selected_row_id);
                        setup_menu.grid.addRowAfter("new_id_" + last_child[1] + "_" + parent_menu_id, [menu_group_name, smid[smid.length - 1], smid[smid.length - 1], parent_menu_id, "Menu Group", "No"], last_child[0], folder_img);
                        setup_menu.grid.openItem(selected_row_id);
                        setup_menu.grid.selectRowById("new_id_" + last_child[1] + "_" + parent_menu_id);
                    }
                    setup_menu.grid.selectCell(setup_menu.grid.getRowIndex(setup_menu.grid.getSelectedRowId()), group_name_ind);
                    setup_menu.grid.editCell();
                    counter++;
                    smid.push(smid[smid.length - 1] + 1);
                    break;
                case "rename":
                    setup_menu.grid.selectCell(row_ind, group_name_ind);
                    setup_menu.grid.editCell();
                    break;
                case "delete":
                    var has_child = setup_menu.grid.hasChildren(selected_row_id);

                    if (has_child == 0) {
                        if (selected_row_id.indexOf("new_id_") > -1) {
                            setup_menu.grid.deleteSelectedRows();
                        } else {
                            var del_setup_menu_id = setup_menu.grid.cells(selected_row_id, setup_menu_id_ind).getValue();
                            deleted_row_ids.push(selected_row_id + '__' + del_setup_menu_id);
                            setup_menu.grid.setRowHidden(selected_row_id, true);
                        }
                    } else {
                        var deleted_function_id = setup_menu.grid.cells(selected_row_id, func_id_ind).getValue();
                        var parent_row_id = setup_menu.grid.getParentId(selected_row_id);
                        var parent_menu_id = setup_menu.grid.cells(parent_row_id, func_id_ind).getValue();
                        var children = setup_menu.grid.getSubItems(selected_row_id);
                        children = children.split(",");
                        // Move all child items to its parent as its child
                        children.forEach(function(child) {
                            setup_menu.grid.moveRowTo(child, parent_row_id, "move", "child");
                            // Change parent_menu_id for each child after it has been moved
                            setup_menu.grid.cells(child, parent_menu_id_ind).setValue(parent_menu_id);
                            // Dump parent_menu_id update info in array
                            if (!(moved_row_ids.indexOf(child) > -1)) {
                                moved_row_ids.push(child);
                            }
                        });
                        // Hide row after all childs have been moved to make it look as deleted
                        deleted_row_ids.push(selected_row_id + '__' + deleted_function_id);
                        setup_menu.grid.setRowHidden(selected_row_id, true);
                    }
                    break;
                case "hide_unhide":
                    var selected_row_id = setup_menu.grid.getSelectedRowId();
                    setup_menu.grid.cells(selected_row_id, hide_show_ind).cell.wasChanged = true;

                    if (context_menu.getItemText("hide_unhide").toLowerCase() == "hide") {
                        setup_menu.grid.cells(selected_row_id, hide_show_ind).setValue("Yes");
                        setup_menu.grid.setRowTextStyle(selected_row_id, "color:#808080;");
                    } else {
                        setup_menu.grid.cells(selected_row_id, hide_show_ind).setValue("No");
                        setup_menu.grid.setRowTextStyle(selected_row_id, "color:#000;");
                    }

                    if (selected_row_id.indexOf("new_id_") == -1 && !(edited_row_ids.indexOf(selected_row_id) > -1)) {
                        edited_row_ids.push(selected_row_id);
                    }
                    break;
            }
        });

        setup_menu.grid.attachEvent("onXLE", function(grid_obj, count) {
            // Modify style for hidden menus
            var row_count = 0;
            var group_name_ind = setup_menu.grid.getColIndexById("group_name");
            var group_func_id_ind = setup_menu.grid.getColIndexById("group_function_id");
            var hide_show_ind = setup_menu.grid.getColIndexById("hide_show");
            var func_id_ind = setup_menu.grid.getColIndexById("function_id");
            var parent_menu_id_ind = setup_menu.grid.getColIndexById("parent_menu_id");
            var menu_type_ind = setup_menu.grid.getColIndexById("menu_type");
            var hide_show_ind = setup_menu.grid.getColIndexById("hide_show");
            var func_id_lvl_0_ind = setup_menu.grid.getColIndexById("function_id_lvl_0");
            var func_id_lvl_1_ind = setup_menu.grid.getColIndexById("function_id_lvl_1");
            var func_id_lvl_2_ind = setup_menu.grid.getColIndexById("function_id_lvl_2");
            var func_id_lvl_3_ind = setup_menu.grid.getColIndexById("function_id_lvl_3");
            var folder_img = js_image_path + '/dhxgrid_web/tree/folder.gif';

            setup_menu.grid.forEachRow(function(id) {
                level = setup_menu.grid.getLevel(id);
                menu_type = setup_menu.grid.cells(id, menu_type_ind).getValue().toLowerCase();

                if (menu_type == 'menu group') {
                    setup_menu.grid.setItemImage(id, folder_img);
                }

                if (setup_menu.grid.cells(id, hide_show_ind).getValue().toLowerCase() == 'yes') {
                    setup_menu.grid.setRowTextStyle(id, "color:#808080;");
                    group_name = setup_menu.grid.cells(id, group_name_ind).getValue();
                    group_label = group_name.split("_-_")[0];
                    setup_menu.grid.cells(id, group_name_ind).setValue(group_label);
                }

                if (level == 0) {
                    max_depth_child = setup_menu.get_max_depth(id, 1);
                    child = max_depth_child[1];
                    // Set Group Function ID for Tree node
                    group_function_id = setup_menu.grid.cells(child, group_func_id_ind).getValue();
                    setup_menu.grid.cells(id, group_func_id_ind).setValue(group_function_id);
                    setup_menu.grid.cells(id, func_id_ind).setValue(group_function_id);
                    // Check if row is hidden
                    group_name = setup_menu.grid.cells(id, group_name_ind).getValue();
                    if (group_name.indexOf("_-_") > -1) {
                        group_label = group_name.split("_-_")[0];
                        setup_menu.grid.cells(id, group_name_ind).setValue(group_label);
                        setup_menu.grid.cells(id, hide_show_ind).setValue("Yes");
                        setup_menu.grid.setRowTextStyle(id, "color:#808080;");
                    }
                } else if (level == 1) {
                    max_depth_child = setup_menu.get_max_depth(id, 1);
                    child = max_depth_child[1];
                    sm_id = setup_menu.grid.cells(child, func_id_lvl_0_ind).getValue();
                    setup_menu.grid.cells(id, func_id_ind).setValue(sm_id);
                    // Set Group Function ID for Tree node
                    if (setup_menu.grid.cells(id, group_func_id_ind).getValue() == "") {
                        group_function_id = setup_menu.grid.cells(child, group_func_id_ind).getValue();
                        setup_menu.grid.cells(id, group_func_id_ind).setValue(group_function_id);
                    }
                    // Check if row is hidden
                    group_name = setup_menu.grid.cells(id, group_name_ind).getValue();
                    if (group_name.indexOf("_-_") > -1) {
                        group_label = group_name.split("_-_")[0];
                        setup_menu.grid.cells(id, group_name_ind).setValue(group_label);
                        setup_menu.grid.cells(id, hide_show_ind).setValue("Yes");
                        setup_menu.grid.setRowTextStyle(id, "color:#808080;");
                    }
                } else if (level == 2 && setup_menu.grid.cells(id, parent_menu_id_ind).getValue() == "") {
                    max_depth_child = setup_menu.get_max_depth(id, 1);
                    child = max_depth_child[1];
                    sm_id = setup_menu.grid.cells(child, func_id_lvl_1_ind).getValue();
                    setup_menu.grid.cells(id, func_id_ind).setValue(sm_id);
                    // Set Group Function ID for Tree node
                    if (setup_menu.grid.cells(id, group_func_id_ind).getValue() == "") {
                        group_function_id = setup_menu.grid.cells(child, group_func_id_ind).getValue();
                        setup_menu.grid.cells(id, group_func_id_ind).setValue(group_function_id);
                    }
                    // Check if row is hidden
                    group_name = setup_menu.grid.cells(id, group_name_ind).getValue();
                    if (group_name.indexOf("_-_") > -1) {
                        group_label = group_name.split("_-_")[0];
                        setup_menu.grid.cells(id, group_name_ind).setValue(group_label);
                        setup_menu.grid.cells(id, hide_show_ind).setValue("Yes");
                        setup_menu.grid.setRowTextStyle(id, "color:#808080;");
                    }
                } else if (level == 3 && setup_menu.grid.cells(id, parent_menu_id_ind).getValue() == "") {
                    max_depth_child = setup_menu.get_max_depth(id, 1);
                    child = max_depth_child[1];
                    sm_id = setup_menu.grid.cells(child, func_id_lvl_2_ind).getValue();
                    setup_menu.grid.cells(id, func_id_ind).setValue(sm_id);
                    // Set Group Function ID for Tree node
                    if (setup_menu.grid.cells(id, group_func_id_ind).getValue() == "") {
                        group_function_id = setup_menu.grid.cells(child, group_func_id_ind).getValue();
                        setup_menu.grid.cells(id, group_func_id_ind).setValue(group_function_id);
                    }
                    // Check if row is hidden
                    group_name = setup_menu.grid.cells(id, group_name_ind).getValue();
                    if (group_name.indexOf("_-_") > -1) {
                        group_label = group_name.split("_-_")[0];
                        setup_menu.grid.cells(id, group_name_ind).setValue(group_label);
                        setup_menu.grid.cells(id, hide_show_ind).setValue("Yes");
                        setup_menu.grid.setRowTextStyle(id, "color:#808080;");
                    }
                }
            });
            //setup_menu.grid.sortRows(9,"int","asc");
        });

        // setup_menu.grid.attachEvent("onDragIn", function(dId,tId,sObj,tObj) {
        //     /* Restrict:
        //         1. moving group & module
        //         2. moving menu into group
        //         3. moving something into menu
        //     */
        //     source_item_level = setup_menu.grid.getLevel(dId);
        //     target_item_level = setup_menu.grid.getLevel(tId);
        //     source_item_depth = setup_menu.get_max_depth(dId, 0);
        //     target_item_depth = setup_menu.get_max_depth(tId, 0);
        //     menu_type_ind = setup_menu.grid.getColIndexById("menu_type");
        //     source_menu_type = setup_menu.grid.cells(dId, menu_type_ind).getValue().toLowerCase();
        //     target_menu_type = setup_menu.grid.cells(tId, menu_type_ind).getValue().toLowerCase();

        //     // restrict dragging menu group with child to a menu group whose parent is already a menu group. Application only supports 2 level menu group.
        //     if ((dId.indexOf("new_id_") > -1 || target_menu_type != 'menu' || setup_menu.grid.hasChildren(dId) > 0) && target_item_level == 3 && source_menu_type == 'menu group') {
        //         if (debug_mode) console.log('onDragIn case 1');
        //         return false;
        //     }

        //     // restrict dragging menu group with child to two level menu group while letting menu group with menu to move to module also letting menu group with child menu group with grand child menu to module.
        //     if ((source_item_depth == 4 && source_item_level == 2 && target_item_level >= 2) || (source_item_depth == 4 && source_item_level >= 2 && (target_item_level != 1 && target_item_level != 2))) {
        //         if (debug_mode) console.log('onDragIn case 2');
        //         return false;
        //     }

        //     if (source_item_level != 0 && source_item_level != 1 && target_item_level != 0 && target_menu_type != 'menu') {
        //         if (debug_mode) console.log('onDragIn case 3');
        //         //setup_menu.grid.setDragBehavior("child");
        //         return true;
        //     } 
        // });

        // setup_menu.grid.attachEvent("onDrop", function(sId,tId,dId,sObj,tObj,sCol,tCol){
        //     // setup_menu.sort_row_data(sId);
        //     func_id_ind = setup_menu.grid.getColIndexById("function_id");
        //     parent_menu_id_ind = setup_menu.grid.getColIndexById("parent_menu_id");

        //     if (sId.indexOf("new_id_") > -1) {
        //         if (debug_mode) console.log('source is new');
        //         setup_menu.grid.cells(sId, parent_menu_id_ind).setValue(setup_menu.get_parent_menu_id(tId));
        //     } else if (setup_menu.grid.hasChildren(sId) > 0) {
        //         if (debug_mode) console.log('source is a saved menu group with child');
        //         if (!(moved_row_ids.indexOf(sId) > -1)) {
        //             moved_row_ids.push(sId);
        //         }
        //         setup_menu.grid.cells(sId, parent_menu_id_ind).setValue(setup_menu.get_parent_menu_id(tId));
        //         //setup_menu.grid.setUserData(sId, "old_parent_menu_id", setup_menu.get_parent_menu_id(sId));
        //     } else if (setup_menu.grid.cells(tId, parent_menu_id_ind).getValue() != '') {
        //         if (debug_mode) console.log('target is a saved menu group with no child but has all required information');
        //         setup_menu.grid.cells(sId, parent_menu_id_ind).setValue(setup_menu.grid.cells(tId, func_id_ind).getValue());
        //     } else { // Assuming it is alread save menu group with no child menus
        //         if (debug_mode) console.log('target is a saved menu group with no child and no information on its row');
        //         setup_menu.grid.cells(sId, parent_menu_id_ind).setValue(setup_menu.get_parent_menu_id(tId));
        //     }
        //     return true;
        // });

        setup_menu.grid.attachEvent("onEditCell", function(stage, rId, cInd, nValue, oValue) {
            if (rId.indexOf("new_id_") == -1 && !(edited_row_ids.indexOf(rId) > -1)) {
                edited_row_ids.push(rId);
            }
            return true;
        });

        setup_menu.get_setup_menu_id();
    });

    setup_menu.save_grid = function(callfrom) {
        var product_category = setup_menu.filter_form.getFormData()['product_category'];
        var changed_ids = setup_menu.grid.getChangedRows();
        var group_name_ind = setup_menu.grid.getColIndexById("group_name");
        var func_id_ind = setup_menu.grid.getColIndexById("function_id");
        var setup_menu_id_ind = setup_menu.grid.getColIndexById("setup_menu_id");
        var parent_menu_id_ind = setup_menu.grid.getColIndexById("parent_menu_id");
        var menu_type_ind = setup_menu.grid.getColIndexById("menu_type");
        var hide_show_ind = setup_menu.grid.getColIndexById("hide_show");
        var menu_order_ind = setup_menu.grid.getColIndexById("menu_order");

        // For rows whose wasChanged property has been triggered manually is not included in getChangedRows() function after a row has been added. Logic below makes sure all those changes are also being included in save.
        edited_row_ids.forEach(function(item) {
            if (changed_ids.indexOf(item) == -1) {
                setup_menu.grid.cells(item, group_name_ind).cell.wasChanged = true;
                changed_ids = setup_menu.grid.getChangedRows();
            }
        });

        if (changed_ids != '' || deleted_row_ids.length > 0) {
            setup_menu.menu.setItemDisabled("save");
            grid_xml = "<GridGroup>";

            if (changed_ids != '') {
                changed_ids = changed_ids.split(",");
                // XML for added/updated rows 
                changed_ids.forEach(function(item) {
                    // Get Setup Menu ID, Display Name
                    setup_menu_id = setup_menu.grid.cells(item, setup_menu_id_ind).getValue();
                    display_name = setup_menu.grid.cells(item, group_name_ind).getValue();
                    display_name = display_name.replace("'", "''");
                    menu_type = setup_menu.grid.cells(item, menu_type_ind).getValue().toLowerCase();
                    hide_show = (setup_menu.grid.cells(item, hide_show_ind).getValue().toLowerCase() == 'yes') ? 0 : 1;
                    menu_order = setup_menu.grid.cells(item, menu_order_ind).getValue();
                    level = setup_menu.grid.getLevel(item);
                    // Get New Parent Menu ID From its Sibling as drag and drop may alter its parent_menu_id

                    if (setup_menu.grid.getLevel(item) !== 0) {
                        new_parent_row_id = setup_menu.grid.getParentId(item);
                        new_parent_menu_id = setup_menu.get_parent_menu_id(new_parent_row_id);
                    }

                    if (item.indexOf("new_id_") > -1) { // Condition for newly added menu groups
                        new_parent_menu_id = setup_menu.grid.cells(item, parent_menu_id_ind).getValue();
                        grid_xml += "<GridAddRow setup_menu_id=\"" + setup_menu_id + "\" display_name=\"" + display_name + "\" hide_show=\"" + hide_show + "\" parent_menu_id=\"" + new_parent_menu_id + "\" product_category=\"" + product_category + "\" menu_order=\"" + menu_order;
                        grid_xml += "\" ></GridAddRow>";
                    } else if (edited_row_ids.indexOf(item) > -1) { // Condition for already added menu groups/modules/sections
                        function_id = setup_menu.grid.cells(item, func_id_ind).getValue();
                        grid_xml += "<GridUpdateName display_name=\"" + display_name + "\" function_id =\"" + function_id + "\" product_category=\"" + product_category + "\" hide_show=\"" + hide_show;
                        grid_xml += "\" ></GridUpdateName>";
                    } else if (moved_row_ids.indexOf(item) > -1 && menu_type == "menu") { // Condition for child menus whose menu group has been deleted
                        function_id = setup_menu.grid.cells(item, func_id_ind).getValue();
                        grid_xml += "<GridUpdateParent function_id=\"" + function_id + "\" parent_menu_id=\"" + new_parent_menu_id + "\" product_category=\"" + product_category;
                        grid_xml += "\" ></GridUpdateParent>";
                    }
                });
            }

            // XML for delete rows
            deleted_row_ids.forEach(function(item) {
                item = item.split("__");
                grid_xml += "<GridDeleteRow function_id =\"" + item[1] + "\" product_category=\"" + product_category;
                grid_xml += "\" ></GridDeleteRow>";
            });
            grid_xml += "</GridGroup>";
            data = {
                "action": "spa_arrange_setup_menu",
                "flag": "g",
                "xml": grid_xml
            }
            if (debug_mode) console.log(grid_xml);
            result = adiha_post_data("alert", data, "", "", "setup_menu.grid_save_callback");
        } else {
            if (callfrom != 'arrange') {
                show_messagebox('No changes has been made to the grid.');
            }
        }
    }

    setup_menu.grid_menu_click = function(id, zoneId, cas) {
        switch (id) {
            case "save":
                setup_menu.grid.saveOpenStates('open_state');
                setup_menu.save_grid('save');
                break;
            case "add":
                setup_menu.create_tab(-1, 0, 0, 0);
                break;
            case "delete":
                var select_id = setup_menu.grid.getSelectedRowId();
                var count = select_id.indexOf(",") > -1 ? select_id.split(",").length : 1;
                select_id = select_id.indexOf(",") > -1 ? select_id.split(",") : [select_id];
                if (select_id != null) {
                    dhtmlx.message({
                        type: "confirm",
                        title: "Confirmation",
                        ok: "Confirm",
                        text: "Are you sure you want to delete?",
                        callback: function(result) {
                            if (result) {
                                for (var i = 1; i <= count; i++) {
                                    var full_id = setup_menu.get_id(setup_menu.grid, select_id[i - 1]);
                                    var full_id_split = full_id.split("_");
                                    full_id_split.splice(0, 1);
                                    var get_id_only = full_id_split.join("_");
                                    if (get_id_only == "") {
                                        dhtmlx.alert({
                                            title: "Alert",
                                            type: "alert",
                                            text: "Please select child item only."
                                        });
                                        return false;
                                    } else {
                                        if (i == 1) {
                                            var xml = "<Root function_id=\"10105000\" object_id=\"" + get_id_only + "\">";
                                        }
                                        xml += "<GridDelete grid_id=\"" + get_id_only + "\">";
                                        xml += get_id_only;
                                        xml += "</GridDelete>";
                                        if (i == count) {
                                            xml += "</Root>";
                                            xml = xml.replace(/'/g, "\"");
                                            data = {
                                                "action": "spa_process_form_data",
                                                "xml": xml,
                                                "flag": "d"
                                            }
                                            result = adiha_post_data("return_array", data, "", "", "setup_menu.post_delete_callback");
                                        }
                                    }
                                }
                            }
                        }
                    });
                } else {
                    dhtmlx.alert({
                        title: "Alert",
                        type: "alert",
                        text: "Please select a row from grid."
                    });
                }
                break;
            case "excel":
                setup_menu.grid.toExcel("../../../adiha.php.scripts/components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                break;
            case "pdf":
                setup_menu.grid.toPDF("../../../adiha.php.scripts/components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                break;
            case "refresh":
                setup_menu.grid_refresh();
                break;
            case "hide_show":
                var sql_param = {
                    "sql": "EXEC spa_arrange_setup_menu @flag='s', @hide_show=0",
                    "grid_type": "tg",
                    "grouping_column": "group_name,display_name_lvl_0,display_name_lvl_1,display_name_lvl_2,display_name_lvl_3"
                };
                var filter_param = setup_menu.get_filter_parameters();
                setup_menu.refresh_grid(sql_param, setup_menu.enable_menu_item, filter_param);
                break;
            case "arrange":
                setup_menu.grid.saveOpenStates('open_state');
                setup_menu.save_grid('arrange');
                setup_menu.open_new_window();
                break;

            case "expand_collapse":
                if (expand_collapse == 'expand') {
                    expand_collapse = 'collapse';
                    setup_menu.menu.setItemText('expand_collapse', "Collapse All");
                    setup_menu.grid.expandAll();
                } else {
                    expand_collapse = 'expand';
                    setup_menu.menu.setItemText('expand_collapse', "Expand All");
                    setup_menu.grid.collapseAll();
                }
                break;
        }
    }

    setup_menu.save_setup_menu = function(id) {
        setup_menu.layout.cells("a").expand();
        var tab_id = setup_menu.tabbar.getActiveTab();
        var win = setup_menu.tabbar.cells(tab_id);
        var valid_status = 1;
        var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(" ", ""));
        var tab_obj = win.tabbar[object_id];
        var detail_tabs = tab_obj.getAllTabs();
        var form_xml = "<FormXML ";
        var form_status = true;
        var first_err_tab;
        var first_err_tab;
        var tabsCount = tab_obj.getNumberOfTabs();

        $.each(detail_tabs, function(index, value) {
            layout_obj = tab_obj.cells(value).getAttachedObject();
            layout_obj.forEachItem(function(cell) {
                attached_obj = cell.getAttachedObject();
                if (attached_obj instanceof dhtmlXForm) {
                    var status = validate_form(attached_obj);
                    form_status = form_status && status;
                    if (tabsCount == 1 && !status) {
                        first_err_tab = "";
                    } else if ((!first_err_tab) && !status) {
                        first_err_tab = tab_obj.cells(value);
                    }
                    if (status) {
                        data = attached_obj.getFormData();
                        for (var a in data) {
                            field_label = a;
                            if (attached_obj.getItemType(field_label) == "calendar") {
                                field_value = attached_obj.getItemValue(field_label, true);
                            } else {
                                field_value = data[a];
                            }
                            form_xml += " " + field_label + "=\"" + field_value + "\"";
                        }
                    } else {
                        valid_status = 0;
                    }
                }
            });
        });
        form_xml += "></FormXML>";
        var xml = "<Root function_id=\"10105000\" object_id=\"" + object_id + "\">";
        xml += form_xml;
        xml += "</Root>";
        xml = xml.replace(/'/g, "\"");
        if (!form_status) {
            generate_error_message(first_err_tab);
        }
        if (valid_status == 1) {
            win.getAttachedToolbar().disableItem('save');
            data = {
                "action": "spa_arrange_setup_menu",
                "flag": "i",
                "xml": xml
            }
            result = adiha_post_data("alert", data, "", "", "setup_menu.post_callback");
        }
    }

    setup_menu.get_parent_menu_id = function(new_parent_row_id) {
        var has_child = setup_menu.grid.hasChildren(new_parent_row_id);
        var func_id_ind = setup_menu.grid.getColIndexById("function_id");
        var parent_menu_id_ind = setup_menu.grid.getColIndexById("parent_menu_id");
        var func_id_lvl_0_ind = setup_menu.grid.getColIndexById("function_id_lvl_0");
        var func_id_lvl_1_ind = setup_menu.grid.getColIndexById("function_id_lvl_1");
        var func_id_lvl_2_ind = setup_menu.grid.getColIndexById("function_id_lvl_2");
        var func_id_lvl_3_ind = setup_menu.grid.getColIndexById("function_id_lvl_3");
        var parent_menu_id = setup_menu.grid.cells(new_parent_row_id, func_id_ind).getValue();
        var new_parent_menu_id = '';
        var mode = 'basic';

        if (parent_menu_id != '') {
            if (debug_mode) console.log('Case 1: Parent is setup menu ID.');
            return parent_menu_id;
        } else if (has_child > 0) {
            child_items = setup_menu.grid.getSubItems(new_parent_row_id);
            child_items = child_items.split(",");
            var break_exception = {};
            try {
                child_items.forEach(function(child) {
                    leaf_child = setup_menu.grid.hasChildren(child);
                    if (leaf_child == 0 && child.indexOf("new_id_") == -1) {
                        if (debug_mode) console.log('Case 2a: Basic Search');
                        new_parent_menu_id = setup_menu.grid.cells(child, parent_menu_id_ind).getValue();
                        if (new_parent_menu_id != "") // this should be checked everytime else empty is returned for cases when a parent has just been deleted and it acts like a leaf node
                            throw break_exception;
                    } else if (leaf_child > 0 && child.indexOf("new_id_") == -1) {
                        mode = 'advanced';
                    }

                    // Tries to get parent_menu_id from grand child
                    if (child == child_items[child_items.length - 1] || mode == 'advanced') {
                        if (debug_mode) console.log('Case 2: Advanced Search');
                        var level = 1; // Menu group can be added from only level 1.
                        all_sub_items = setup_menu.grid.getAllSubItems(new_parent_row_id);
                        all_sub_items = all_sub_items.split(",");
                        all_sub_items.forEach(function(item) {
                            current_level = setup_menu.grid.getLevel(item);
                            if (current_level > level) {
                                level = current_level;
                                max_depth_item = item;
                            }
                        });
                        new_parent_row_level = setup_menu.grid.getLevel(new_parent_row_id);
                        if (new_parent_row_level == 1) {
                            new_parent_menu_id = setup_menu.grid.cells(max_depth_item, func_id_lvl_0_ind).getValue();
                        } else if (new_parent_row_level == 2) {
                            new_parent_menu_id = setup_menu.grid.cells(max_depth_item, func_id_lvl_1_ind).getValue();
                        } else if (new_parent_row_level == 3) { // This case will not be necessary
                            new_parent_menu_id = setup_menu.grid.cells(max_depth_item, func_id_lvl_2_ind).getValue();
                        }

                        if (mode == 'advanced') throw break_exception;
                    }
                });
            } catch (err) {
                if (err !== break_exception) throw err;
            }
            if (new_parent_menu_id == '') {
                if (debug_mode) console.log('still null');
            } else {
                return new_parent_menu_id;
            }
        } else {
            if (debug_mode) console.log('Case 3: Child Column 2')
            new_parent_menu_id = setup_menu.grid.cells(new_parent_row_id, parent_menu_id_ind).getValue();
            return new_parent_menu_id;
        }
    }

    setup_menu.get_last_child_id_and_index = function(new_parent_row_id) {
        var has_child = setup_menu.grid.hasChildren(new_parent_row_id);

        if (has_child > 0) {
            children = setup_menu.grid.getSubItems(new_parent_row_id);
            last_child = children.split(",");
            return [last_child[last_child.length - 1], last_child.length];
        } else {
            return 0;
        }
    }


    setup_menu.grid_save_callback = function(result) {
        setup_menu.menu.setItemEnabled("save");
        if (debug_mode) console.log(result);
        if (result[0].errorcode == "Success") {
            // Refresh grid
            var filter_param = setup_menu.get_filter_parameters();
            setup_menu.refresh_grid("", setup_menu.enable_menu_item, filter_param);
            setup_menu.layout.cells("a").collapse();
            setup_menu.layout.cells("b").collapse();
            deleted_row_ids = [];
            edited_row_ids = [];
        }

    }

    setup_menu.get_max_depth = function(row_id, return_type) {
        var level = 1; // Menu group can be added from only level 1.
        all_sub_items = setup_menu.grid.getAllSubItems(row_id);
        all_sub_items = all_sub_items.split(",");
        all_sub_items.forEach(function(item) {
            current_level = setup_menu.grid.getLevel(item);
            if (current_level > level) {
                level = current_level;
                max_depth_item = item;
            }
        });
        if (return_type == 0)
            return level;
        else
            return [level, max_depth_item];
    }

    setup_menu.get_setup_menu_id = function() {
        var result;
        data = {
            "action": "spa_arrange_setup_menu",
            "flag": "n"
        }
        result = adiha_post_data("return_array", data, "", "", function(result) {
            smid.push(result[0][0]);
        });
    }

    setup_menu.sort_row_data = function(row_id) {
        var menu_order_ind = setup_menu.grid.getColIndexById("menu_order");

        if (row_id != '') {
            if (setup_menu.grid.hasChildren(row_id) == 0) {
                var level = setup_menu.grid.getLevel(row_id);
                var parent_row_id;

                if (level == 4) {
                    parent_row_id = setup_menu.grid.getParentId(setup_menu.grid.getParentId(setup_menu.grid.getParentId(row_id)));
                } else if (level == 3) {
                    parent_row_id = setup_menu.grid.getParentId(setup_menu.grid.getParentId(row_id));
                } else if (level == 2) {
                    parent_row_id = setup_menu.grid.getParentId(row_id);
                } else {
                    parent_row_id = row_id;
                }

                var child = setup_menu.grid.getAllSubItems(parent_row_id);
                child = child.split(",");
                for (var i = 1; i <= child.length; i++) {
                    setup_menu.grid.cells(child[i - 1], menu_order_ind).setValue(i);
                }
            }
        }
    }

    setup_menu.open_new_window = function() {
        dhxWins = new dhtmlXWindows();
        var is_win = dhxWins.isWindow('w1');
        var product_category = setup_menu.filter_form.getFormData()['product_category'];
        param = 'arrange.menu.items.php?is_pop=true' + '&product_category=' + product_category;
        text = 'Arrange Menu Items';
        if (is_win == true) {
            w1.close();
        }
        w1 = dhxWins.createWindow("w1", 0, 0, 700, 500);
        w1.centerOnScreen();
        w1.setText(text);
        w1.setModal(true);
        w1.denyMove();
        w1.denyResize();
        w1.button('minmax').hide();
        w1.button('park').hide();
        w1.attachURL(param, false, true);
    }

    setup_menu.create_tab = function(r_id, col_id, grid_obj, acc_id, tab_index) {
        if (r_id != -1) { // Restrict tab open for menu group
            menu_type_ind = setup_menu.grid.getColIndexById("menu_type");
            menu_type = setup_menu.grid.cells(r_id, menu_type_ind).getValue().toLowerCase();
            if (menu_type != 'menu') {
                return false;
            }
        }

        if (r_id == -1 && col_id == 0) {
            full_id = setup_menu.uid();
            full_id = full_id.toString();
            text = "New";
        } else {
            full_id = setup_menu.get_id(setup_menu.grid, r_id);
            text = setup_menu.get_text(setup_menu.grid, r_id);
            if (full_id == "tab_") {
                var selected_row = setup_menu.grid.getSelectedRowId();
                var state = setup_menu.grid.getOpenState(selected_row);
                if (state)
                    setup_menu.grid.closeItem(selected_row);
                else
                    setup_menu.grid.openItem(selected_row);
                return false;
            }
        }
        if (!setup_menu.pages[full_id]) {
            var tab_context_menu = new dhtmlXMenuObject();
            tab_context_menu.setIconsPath(js_image_path + "dhxtoolbar_web/");
            tab_context_menu.renderAsContextMenu();
            setup_menu.tabbar.addTab(full_id, text, null, tab_index, true, true);
            //using window instead of tab
            var win = setup_menu.tabbar.cells(full_id);
            setup_menu.tabbar.t[full_id].tab.id = full_id;
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
                setup_menu.tabbar.tabs(zoneId).setActive();
            });
            tab_context_menu.attachEvent("onClick", function(id, zoneId) {
                var ids = setup_menu.tabbar.getAllTabs();
                switch (id) {
                    case "close_other":
                        ids.forEach(function(tab_id) {
                            if (tab_id != zoneId) {
                                delete setup_menu.pages[tab_id];
                                setup_menu.tabbar.tabs(tab_id).close();
                            }
                        });
                        break;
                    case "close_all":
                        ids.forEach(function(tab_id) {
                            delete setup_menu.pages[tab_id];
                            setup_menu.tabbar.tabs(tab_id).close();
                        });
                        break;
                    case "close":
                        ids.forEach(function(tab_id) {
                            if (tab_id == zoneId) {
                                delete setup_menu.pages[tab_id];
                                setup_menu.tabbar.tabs(tab_id).close();
                            }
                        });
                        break;
                }
            });
            var toolbar = win.attachToolbar();
            toolbar.setIconsPath(js_image_path + "dhxtoolbar_web/");
            toolbar.attachEvent("onClick", setup_menu.tab_toolbar_click);
            toolbar.loadStruct([{
                id: "save",
                type: "button",
                img: "save.gif",
                imgdis: "save_dis.gif",
                text: "Save",
                title: "Save"
            }]);
            setup_menu.tabbar.cells(full_id).setText(text);
            setup_menu.tabbar.cells(full_id).setActive();
            setup_menu.tabbar.cells(full_id).setUserData("row_id", r_id);
            win.progressOn();
            setup_menu.set_tab_data(win, full_id);
            setup_menu.pages[full_id] = win;
        } else {
            setup_menu.tabbar.cells(full_id).setActive();
        }
    }

    setup_menu.grid_refresh = function() {
        var filter_param = setup_menu.get_filter_parameters();
        setup_menu.grid.saveSortingToCookie();
        setup_menu.refresh_grid("", setup_menu.enable_menu_item, filter_param);
        setup_menu.grid.loadSortingFromCookie();
        deleted_row_ids = [];
        edited_row_ids = [];
        moved_row_ids = [];
        smid = [];
        setup_menu.get_setup_menu_id();
        counter = 0;
    }
</script>

</html>