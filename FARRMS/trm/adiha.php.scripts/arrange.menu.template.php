<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('components/include.file.v3.php'); ?>
</head>
<body>
<?php
    $php_script_loc = $app_php_script_loc;
    $application_function_id = 10105003; 
    $namespace = 'arrange_menu_items';

    $product_category = $_GET['product_category'];
    $menu_id = isset($_GET['menu_id']) ? $_GET['menu_id'] : null;
    $menu_name = isset($_GET['menu_name']) ? $_GET['menu_name'] : null;
    $call_from = isset($_GET['call_from']) ? $_GET['call_from'] : null;
    $app_function_id = isset($_GET['app_function_id']) ? $_GET['app_function_id'] : null;
    $callback = isset($_GET['callback']) && $_GET['callback'] == 'true' ? true : false;

    $action = 'spa_arrange_setup_menu';
    $value_list = 'function_id_lvl_4:display_name_lvl_4';
    $grouping_list = 'group_name:group_name,function_id_lvl_0:display_name_lvl_0,function_id_lvl_1:display_name_lvl_1,function_id_lvl_2:display_name_lvl_2,function_id_lvl_3:display_name_lvl_3';
    $additional_param = "flag=t&product_category=" . $product_category;

    $layout_json = "[
                    {
                        id:             'a',
                        text:           'Portfolio Hiearchy',
                        width:          400,
                        collapse:       false,
                        fix_size:       [false, null]
                    }
                    ]";

    $toolbar_json =  '[
            {id:"add", text:"Add", img:"add.gif", imgdis:"add_dis.gif", title: "Add", enabled:"false"},
            {id:"remove", text:"Remove", img:"delete.gif", imgdis:"delete_dis.gif", title: "Remove", enabled:"false"},
            {id:"save", text:"Save", img:"save.gif", imgdis:"save_dis.gif", title: "Save", enabled:"false"},
            {id:"expand_collapse", text:"Expand/Collapse", img:"exp_col.gif", imgdis:"exp_col_dis.gif", title: "Expand All", enabled:"true"}                                                     
         ]';
    $layout_obj = new AdihaLayout();
    echo $layout_obj->init_layout('layout', '', '1C', $layout_json, $namespace);
    echo $layout_obj->attach_menu_cell('menu', 'a');
    echo $layout_obj->attach_tree_cell('tree', 'a');

    $menu_obj = new AdihaMenu();
    echo $menu_obj->init_by_attach('menu', $namespace);
    echo $menu_obj->load_menu($toolbar_json);
    echo $menu_obj->attach_event('', 'onClick', $namespace . '.menu_click');

    $tree = new AdihaTree();
    echo $tree->init_by_attach('tree', $namespace);
    echo $tree->load_tree_xml($action, $value_list, $grouping_list, $additional_param);
    echo $tree->load_tree_functions();

    //$toolbar_obj = new AdihaToolbar();
    echo $layout_obj->close_layout();
?>
</body>
<script type="text/javascript">
    var product_category = '<?php echo $product_category; ?>';
    var menu_id = '<?php echo $menu_id; ?>';
    var menu_name = '<?php echo $menu_name; ?>';
    var expand_collapse = 'expand';
    var menu_group_list = new Array();
    var menu_list = new Array();
    var count = 0;
    var existing_id = 0;
    var call_from = '<?php echo $call_from; ?>';
    var app_function_id = '<?php echo $app_function_id; ?>';
    var callback = '<?php echo $callback; ?>';

    $(function() {
        var parent_nodes = arrange_menu_items.tree.getAllItemsWithKids();
        parent_nodes = parent_nodes.split(",");
        parent_nodes.forEach(function(parent) {
            if (arrange_menu_items.tree.getLevel(parent) == 1)
                top_nodes.push(parent);
        });

        arrange_menu_items.tree.enableDragAndDrop(true, false); // 2nd parameter should be false else child item can be dragged to root
        arrange_menu_items.tree.enableTreeLines(true);
        arrange_menu_items.tree.setDragBehavior('complex');

        arrange_menu_items.tree.attachEvent("onDrag", function(sId, tId, id, sObject, tObject){
            source_item_level = arrange_menu_items.tree.getLevel(sId);
            target_item_level = arrange_menu_items.tree.getLevel(tId);
            sibling_item_level = arrange_menu_items.tree.getLevel(id);

            // restrict dragging groups and modules
            if (source_item_level <= 2 || target_item_level <= 1 ) {
                arrange_menu_items.throw_error_message(sId, tId);               
                return false;
            } else if (arrange_menu_items.is_nested_menu_group(tId) && menu_list.indexOf(sId) == -1 && target_item_level != 3) { // restrict moving menu group into nested menu groups of level 3
                arrange_menu_items.throw_error_message(sId, tId);
                return false;
            }
            else if (menu_list.indexOf(sId) > -1 && menu_list.indexOf(tId) > -1) { // restrict moving menu to menu
                arrange_menu_items.throw_error_message(sId, tId);
                return false;
            } else if (menu_group_list.indexOf(sId) > -1 && menu_list.indexOf(tId) > -1) { // restrict moving menu group to menu
                arrange_menu_items.throw_error_message(sId, tId);
                return false;
            } else if (source_item_level == 3 && arrange_menu_items.is_nested_menu_group(sId) && menu_group_list.indexOf(tId) > -1) { // restrict moving menu group of level 3 with child menu group to another menu group
                arrange_menu_items.throw_error_message(sId, tId);
                return false;
            } else if (sId == menu_id || sId == existing_id) {
                arrange_menu_items.menu.setItemEnabled('save');
                return true;
            } else {
                msg = "Cannot move other menu items.";
                arrange_menu_items.throw_error_message(sId, tId, msg);
            }
        });

        arrange_menu_items.throw_error_message = function(sId, tId, custom_msg) {
            if (custom_msg != null) {
                msg = custom_msg;
            } else {
                msg = "Cannot move '" +  arrange_menu_items.tree.getItemText(sId) + "' to '" + arrange_menu_items.tree.getItemText(tId);
            }

            dhtmlx.alert({
                title:"Alert",
                type:"alert",
                text: msg
            });
        }
        
        // Identify menu groups and modify id to identify it later as logic relies heavily on this part.
        arrange_menu_items.tree.attachEvent("onXLE", function(){
            parent_nodes = arrange_menu_items.tree.getAllItemsWithKids();
            child_nodes = arrange_menu_items.tree.getAllChildless();
            parent_nodes = parent_nodes.split(",");
            child_nodes = child_nodes.split(",");

            parent_nodes.forEach(function(node) {
                node_label = arrange_menu_items.tree.getItemText(node);
                level = arrange_menu_items.tree.getLevel(node);
                if (node_label.indexOf("_-_") > -1) {
                    menu_group_list.push(node);
                    node_label = node_label.split("_-_")[0];
                    arrange_menu_items.tree.setItemText(node,node_label,node_label);
                } else if (arrange_menu_items.tree.hasChildren(node) > 0 && level > 2) {
                    menu_group_list.push(node);
                } 

                if (level <= 2) {
                    arrange_menu_items.tree.setItemStyle(node,"color:#808080;");
                }

                if (level == 1) {
                    arrange_menu_items.tree.setItemImage(node, 'section.png', 'section.png');
                } else if (level == 2) {
                    arrange_menu_items.tree.setItemImage(node, 'module.png', 'module.png');
                }
            });

            child_nodes.forEach(function(node) {
                node_label = arrange_menu_items.tree.getItemText(node);
                if (node_label.indexOf("_-_") > -1) {
                    menu_group_list.push(node);
                    node_label = node_label.split("_-_")[0];
                    arrange_menu_items.tree.setItemText(node,node_label,node_label);
                } else {
                    menu_list.push(node);
                }

                if (node_label == menu_name) {
                    existing_id = node;
                    arrange_menu_items.tree.selectItem(existing_id);
                    arrange_menu_items.tree.focusItem(existing_id);
                }
            });
        });

        arrange_menu_items.tree.attachEvent("onSelect", function(id){
            // Only enable add button if selected item is menu group or module
            if (menu_group_list.indexOf(id) > -1 || arrange_menu_items.tree.getLevel(id) == 2) {
                arrange_menu_items.menu.setItemEnabled('add');
            } else {
                arrange_menu_items.menu.setItemDisabled('add');
            }

            if (id == menu_id || id == existing_id) {
                arrange_menu_items.menu.setItemEnabled('remove');
            } else {
                arrange_menu_items.menu.setItemDisabled('remove');
            }
        });
    });

    arrange_menu_items.menu_click = function(id) {
        switch(id) {
            case "add":
                var parent_id = arrange_menu_items.tree.getSelectedItemId();
                if (existing_id != 0) {
                    msg = "'" + menu_name + "' menu already exists.";
                    arrange_menu_items.throw_error_message('', '', msg);
                    arrange_menu_items.tree.selectItem(existing_id);
                    arrange_menu_items.tree.focusItem(existing_id);
                } else {
                    if (count == 0) {
                        arrange_menu_items.tree.insertNewItem(parent_id,menu_id,menu_name);
                        arrange_menu_items.menu.setItemDisabled(id);
                        arrange_menu_items.menu.setItemEnabled('save');
                        count = 1;
                    }
                }
                break;
            case "save":

                if (count == 1) {
                    arrange_menu_items.save_menu_items();
                }
                break;
            case "expand_collapse":
                var top_nodes = new Array();
                var parent_nodes = arrange_menu_items.tree.getAllItemsWithKids();
                parent_nodes = parent_nodes.split(",");

                parent_nodes.forEach(function(parent) {
                    if (arrange_menu_items.tree.getLevel(parent) == 1)
                        top_nodes.push(parent);
                });

                if (expand_collapse == 'expand') {
                    expand_collapse = 'collapse';
                    arrange_menu_items.menu.setItemText('expand_collapse', "Collapse All");
                    top_nodes.forEach(function(top_node) {
                        arrange_menu_items.tree.openAllItems(top_node);
                    });
                } else {
                    expand_collapse = 'expand';
                    arrange_menu_items.menu.setItemText('expand_collapse', "Expand All");
                    top_nodes.forEach(function(top_node) {
                        arrange_menu_items.tree.closeAllItems();
                    });
                }
                break;
            case "remove":
                selected_id = arrange_menu_items.tree.getSelectedItemId();
                if (selected_id == existing_id) {
                    xml_data = "<Root><Data function_id=\"" + selected_id + "\" product_category=\"" + product_category + "\"></Data></Root>";
                    data = {"action": "spa_arrange_setup_menu", "flag": "d", "xml": xml_data}
                    result = adiha_post_data("alert", data, "", "", "");

                    setTimeout(function() {
                        parent.dhxWins.window('w1').close();
                    }, 2000);
                } else {
                    arrange_menu_items.tree.deleteItem(selected_id, false);
                    arrange_menu_items.menu.setItemDisabled(id);
                    arrange_menu_items.menu.setItemDisabled('save');
                    count = 0;
                }
                break;
                
        }
    }

    arrange_menu_items.save_menu_items = function() {
        var parent_menu_id;

        if (existing_id != 0 && count != 1) {
            parent_menu_id = arrange_menu_items.tree.getParentId(existing_id);
            menu_order = arrange_menu_items.get_menu_order(existing_id);
            mode = 'u';
        } else {
            parent_menu_id = arrange_menu_items.tree.getParentId(menu_id);
            menu_order = arrange_menu_items.get_menu_order(menu_id);
            mode = 'i';
        }

        xml_data = "<Root><TreeXML parent_menu_id=\"" + parent_menu_id + "\" product_category=\"" + product_category + "\" menu_name=\"" + menu_name  + "\" tab_id=\"" + menu_id  + "\" menu_order=\"" + menu_order + "\" mode=\"" + mode + "\" app_function_id=\"" + app_function_id + "\"></TreeXML></Root>";
        data = {"action": "spa_arrange_setup_menu", "flag": "m", "xml": xml_data}
        result = adiha_post_data("alert", data, "", "", "arrange_menu_items.grid_save_callback");        
    }

    arrange_menu_items.grid_save_callback = function(result) {
        if (result[0].errorcode == "Success") {
            setTimeout(function() {
                if (callback) {
                    parent.add_to_menu_callback(menu_id);
                }
                parent.dhxWins.window('w1').close();
            }, 2000);
        } else {
            arrange_menu_items.tree.deleteItem(menu_id);
            arrange_menu_items.menu.setItemDisabled('save');
            arrange_menu_items.tree.selectItem(existing_id);
            arrange_menu_items.tree.focusItem(existing_id);
            count = 0;
        }
    }

    arrange_menu_items.get_max_depth = function(row_id) {
        var level = 1; // Menu group can be added from only level 1.
        all_sub_items = arrange_menu_items.tree.getAllSubItems(row_id);
        all_sub_items = all_sub_items.split(",");
        all_sub_items.forEach(function(item) {
            current_level = arrange_menu_items.tree.getLevel(item);
            if (current_level > level) {
                level = current_level;
                max_depth_item = item;
            }
        });
        return level;
    }

    arrange_menu_items.is_nested_menu_group = function(row_id) {
        var nested_menu_group = false;
        level = arrange_menu_items.tree.getLevel(row_id);

        if (level == 4 && menu_group_list.indexOf(row_id) > -1)
            nested_menu_group = true;
        else if (level == 3) {
            all_sub_items = arrange_menu_items.tree.getAllSubItems(row_id);
            all_sub_items = all_sub_items.split(",");
            all_sub_items.forEach(function(item) {
                if (menu_group_list.indexOf(item) > -1) {
                    nested_menu_group = true;
                }
            });
        }
        return nested_menu_group;
    }

    arrange_menu_items.get_menu_order = function(menu_id) {
        var menu_order = 0;
        var top_nodes = new Array();
        var parent_nodes = arrange_menu_items.tree.getAllItemsWithKids();
        parent_nodes = parent_nodes.split(",");
        count = 1;


        parent_nodes.forEach(function(parent) {
            if (arrange_menu_items.tree.getLevel(parent) == 2)
                top_nodes.push(parent);
        });

        top_nodes.forEach(function(top_node) {
            sub_nodes = arrange_menu_items.tree.getAllSubItems(top_node);
            sub_nodes = sub_nodes.split(",");

            sub_nodes.forEach(function(node) {
                order = count++;
                if (menu_id == node) {
                    menu_order = order;
                }
            });
        });

        return menu_order;
    }

</script>
</html>