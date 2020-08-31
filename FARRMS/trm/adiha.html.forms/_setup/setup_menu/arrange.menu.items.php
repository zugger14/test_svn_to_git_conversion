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
    $php_script_loc = $app_php_script_loc;
    $application_function_id = 10105003; 
    $namespace = 'arrange_menu_items';

    $product_category = get_sanitized_value($_GET['product_category']);

    $action = 'spa_arrange_setup_menu';
    $value_list = 'function_id_lvl_4:display_name_lvl_4';
    $grouping_list = 'group_function_id:group_name,function_id_lvl_0:display_name_lvl_0,function_id_lvl_1:display_name_lvl_1,function_id_lvl_2:display_name_lvl_2,function_id_lvl_3:display_name_lvl_3';
    $additional_param = "flag=t&product_category=" . $product_category;

    $layout_json = "[
                    {
                        id:             'a',
                        text:           'Menu Structure',
                        width:          400,
                        collapse:       false,
                        fix_size:       [false, null]
                    }
                    ]";

    $toolbar_json =  '[
            {id:"save", text:"Save", img:"save.gif", imgdis:"save_dis.gif", title: "Save", enabled:"true"},
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
    var expand_collapse = 'expand';
    var menu_group_list = new Array();
    var menu_list = new Array();

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
            if (source_item_level <= target_item_level && (source_item_level == 1 || source_item_level == 2)) {
                add_msg = 'A section or module canot be moved into another section or module or menu group or menu.';
                arrange_menu_items.throw_error_message(sId, tId, add_msg);               
                return false;
            } else if (source_item_level > 2 && target_item_level <= 1) { // restrict moving menu group to level of a module
                add_msg = 'A menu group cannot be moved to the level of a module.';
                arrange_menu_items.throw_error_message(sId, tId, add_msg);
                return false;
            } else if (arrange_menu_items.is_nested_menu_group(tId) && menu_list.indexOf(sId) == -1 && target_item_level != 3) { // restrict moving menu group into nested menu groups of level 3
                add_msg = 'A menu group having child menu group cannot be moved into another menu group.';
                arrange_menu_items.throw_error_message(sId, tId, add_msg);
                return false;
            } else if (menu_list.indexOf(sId) > -1 && menu_list.indexOf(tId) > -1) { // restrict moving menu to menu
                add_msg = 'A menu cannot be moved into another menu.';
                arrange_menu_items.throw_error_message(sId, tId, add_msg);
                return false;
            } else if (menu_group_list.indexOf(sId) > -1 && menu_list.indexOf(tId) > -1) { // restrict moving menu group to menu
                add_msg = 'A menu group cannot be moved into a menu.';
                arrange_menu_items.throw_error_message(sId, tId, add_msg);
                return false;
            } else if (source_item_level == 3 && arrange_menu_items.is_nested_menu_group(sId) && menu_group_list.indexOf(tId) > -1) { // restrict moving menu group of level 3 with child menu group to another menu group
                add_msg = 'A menu group having child menu group cannot be moved into another menu group.';
                arrange_menu_items.throw_error_message(sId, tId, add_msg);
                return false;
            }

            return true;
        });

        arrange_menu_items.throw_error_message = function(sId, tId, add_msg) {
            msg = "Cannot move '" +  arrange_menu_items.tree.getItemText(sId) + "' to '" + arrange_menu_items.tree.getItemText(tId) + "'.";

            if (typeof add_msg !== 'undefined') {
                msg += ' ' + add_msg;
            }

            dhtmlx.alert({
                title:"Alert",
                type:"alert",
                text: msg
            });
        }

        arrange_menu_items.tree.attachEvent("onXLS", function(){
            // before loading started
            arrange_menu_items.tree.setStdImages('folderClosedPrivilege.png','folderOpen.png','folderClosed.png');
        });
        
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
            });
        });
    });

    arrange_menu_items.menu_click = function(id) {
        switch(id) {
            case "save":
                arrange_menu_items.save_menu_items();
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
                
        }
    }

    arrange_menu_items.save_menu_items = function() {
        var top_nodes = new Array();
        var parent_nodes = arrange_menu_items.tree.getAllItemsWithKids();
        parent_nodes = parent_nodes.split(",");
        grid_xml = "<GridGroup>";
        count = 1;

        parent_nodes.forEach(function(parent) {
            //if (arrange_menu_items.tree.getLevel(parent) == 2)
                top_nodes.push(parent);

            if (arrange_menu_items.tree.getLevel(parent) == 1) {
                function_id = parent.indexOf("_") > -1 ? parent.split("_")[0] : parent;
                menu_order = count++;

                grid_xml += "<GridItem function_id=\"" + function_id + "\" parent_menu_id=\"" + product_category + "\" product_category=\"" + product_category + "\" menu_order=\"" + menu_order;
                grid_xml += "\" ></GridItem>";
            }
        });

        top_nodes.forEach(function(top_node) {
            sub_nodes = arrange_menu_items.tree.getAllSubItems(top_node);
            sub_nodes = sub_nodes.split(",");

            sub_nodes.forEach(function(node) {
                function_id = node.indexOf("_") > -1 ? node.split("_")[0] : node;
                display_name = arrange_menu_items.tree.getItemText(node);
                parent_menu_id = arrange_menu_items.tree.getParentId(node);
                parent_menu_id = parent_menu_id.indexOf("_") > -1 ? parent_menu_id.split("_")[0] : parent_menu_id;
                menu_order = count++;

                grid_xml += "<GridItem function_id=\"" + function_id + "\" parent_menu_id=\"" + parent_menu_id + "\" product_category=\"" + product_category + "\" menu_order=\"" + menu_order;
                grid_xml += "\" ></GridItem>";
            });
        });
        grid_xml += "</GridGroup>";

        data = {"action": "spa_arrange_setup_menu", "flag": "o", "xml":grid_xml}
        result = adiha_post_data("alert", data, "", "", "arrange_menu_items.grid_save_callback");
    }

    arrange_menu_items.grid_save_callback = function(result) {
        if (result[0].errorcode == "Success") {
            parent.setup_menu.grid_refresh();
            setTimeout(function() {
                parent.dhxWins.window('w1').close();
            }, 2000);
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

</script>
</html> 