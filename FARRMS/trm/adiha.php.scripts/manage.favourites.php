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
    global $image_path;
    $php_script_loc = $app_php_script_loc;
    $app_user_loc = $app_user_name;
    $form_namespace = 'manageFavourites';
    $deal_ids = (isset($_POST["deal_ids"]) && $_POST["deal_ids"] != '') ? $_POST["deal_ids"] : 'NULL';

    $layout_json = '[{id: "a", header:false}]';
    $toolbar_json = '[{id:"save", type:"button", img: "tick.png", img_disabled: "tick_dis.png", text:"Ok", title: "Ok", enabled:false},
                      {id:"delete", type:"button", img: "trash.gif", img_disabled: "trash_dis.gif", text:"Delete", title: "Delete", enabled:false}]';
    $layout_obj = new AdihaLayout();
    $toolbar_obj = new AdihaToolbar();
    $tree_obj = new AdihaTree();

    echo $layout_obj->init_layout('layout', '', '1C', $layout_json, $form_namespace);
    echo $layout_obj->attach_form('form', 'a');
    echo $layout_obj->attach_toolbar_cell('toolbar', 'a');
    echo $toolbar_obj->init_by_attach('toolbar', $form_namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', $form_namespace . '.toolbar_click');

    echo $layout_obj->attach_tree_cell('tree', 'a');
    echo $tree_obj->init_by_attach('tree', $form_namespace);
    $grid_sp = "EXEC spa_favourites 't'";
    echo $tree_obj->enable_DND();
    echo $tree_obj->set_drag_behavior('sibling');
    echo $tree_obj->attach_event('', 'onSelect', $form_namespace . '.select_event');
    echo $tree_obj->attach_event('', 'onDragIn', $form_namespace . '.control_dragin');
    echo $tree_obj->attach_event('', 'onXLE', $form_namespace . '.after_load');
    echo $tree_obj->load_tree_xml('spa_favourites', 'favourites_menu_id:favourites_menu_name', 'group_id:favourites_group_name', 'flag=t');
    echo $tree_obj->enable_multi_selection();
    echo $tree_obj->enable_editor();
    echo $tree_obj->attach_event('', 'onEdit', $form_namespace . '.editor_control');
    echo $layout_obj->close_layout();
?>
</body>
<textarea style="display:none" name="success_status" id="success_status"></textarea>
<script type="text/javascript">
    var changed_saved = true;
    $(function() {
        var win_obj = window.parent.manage_favourites.window("w1");
        
        win_obj.attachEvent("onClose", function(win){                         
            if (!changed_saved) {
                close = false;
                dhtmlx.confirm({
                    title:"Confirmation",
                    type:"confirm-error",
                    ok:"Confirm", 
                    cancel:"Cancel",
                    text: 'There are unsaved changes. Do you want to close without saving?',
                    callback: function(result) {
                        if (result) {
                            changed_saved = true;
                            win_obj.close();
                        } 
                    }
                });
            } else {
                return true;
            }
        })
        
        manageFavourites.tree.attachEvent("onEdit", function(state, id, tree, value){
            if (state == 3) {
                if (value)
                    manageFavourites.toolbar.enableItem('save');
            }   
            return true;
        });
    })

    /**
     * [select_event Select event for tree]
     * @param  {[type]} id [selected id]
     */
    manageFavourites.select_event = function(id) {
        if (id != '') {
            manageFavourites.toolbar.enableItem('delete');
        } else {
            manageFavourites.toolbar.disableItem('delete');
        }
    }

    /**
     * [after_load After load event for tree]
     */
    manageFavourites.after_load = function() {     
		manageFavourites.tree.lockItem('g_-1');
		manageFavourites.tree.enableTreeLines(true);
		manageFavourites.tree.openAllItems(0);        
    }

    /**
     * [editor_control Edit control]
     * @param  {[type]} state [state of edit]
     * @param  {[type]} id    [id of node]
     * @param  {[type]} tree  [tree obj]
     * @param  {[type]} value [value]
     */
    manageFavourites.editor_control = function(state, id, tree, value) {
        if (state == 0) {
            if (id == 'g_-1') return false;
            if (tree.getLevel(id) != 1) return false;
        }

        return true;
    }

    /**
     * [control_dragin Control drag behaviour]
     * @param  {[type]} sid     [source id]
     * @param  {[type]} tid     [target id]
     * @param  {[type]} sObject [source object]
     * @param  {[type]} tObject [target object]
     */
        
    manageFavourites.control_dragin = function(sid, tid, sObject, tObject) {
        var target_level = tObject.getLevel(tid);
        var source_level = sObject.getLevel(sid);

        if (sObject != tObject) return false;
        if (sid == 'g_-1') return false;
        if (source_level == 1 && target_level == 2) return false;

        if (target_level == 2 && source_level == 2) {
            manageFavourites.tree.setDragBehavior('sibling');
            changed_saved = false;
            manageFavourites.toolbar.enableItem('save');
        } else if (source_level == 2 && target_level == 1) {
            manageFavourites.tree.setDragBehavior('child');
            changed_saved = false;
            manageFavourites.toolbar.enableItem('save');
        } else if (target_level == 1 && source_level == 1 && tid != 'g_-1' && sid != 'g_-1') {          
            if (tObject.getIndexById(tid) > sObject.getIndexById(sid)) {
                sObject.moveItem(sid, 'item_sibling_next', tid, tObject);
            } else {
                sObject.moveItem(sid, 'item_sibling', tid, tObject);
            }
            changed_saved = false;
            //manageFavourites.toolbar.enableItem('save');
            return false;
        } else {            
            return false;
        }

        return true;
    }

    /**
     * [toolbar_click Deal Status toolbar clicked.]
     * @param  {[string]} id [Menu Id]
     */
    manageFavourites.toolbar_click = function(id) {
        manageFavourites.toolbar.enableItem('save');
        switch(id) {
            case "save":
                var items = manageFavourites.tree.getAllSubItems(0);
                var items_array = items.split(',');

                var xml = '<Root>'
                $.each(items_array, function(i, item) { 
                    if (item.indexOf('g_') != -1) {
                        var group_name = manageFavourites.tree.getItemText(item);
                        var group_order = manageFavourites.tree.getIndexById(item);
                        group_name = (group_name == null) ? '' : group_name;
                        group_order = (group_order == null) ? 0 : group_order;

                        var child_items = manageFavourites.tree.getAllSubItems(item);
                        var child_array = new Array();
                        child_array = child_items.split(',');
                        $.each(child_array, function(i, menu) {
                            var menu_name = manageFavourites.tree.getItemText(menu);
                            var menu_order = manageFavourites.tree.getIndexById(menu);
                            menu_name = (menu_name == null) ? '' : menu_name;
                            menu_order = (menu_order == null) ? 0 : menu_order;
                            
                            xml += '<TNode group_id="' + item + '" group_name="' + group_name + '" group_order="' + group_order + '" menu_id="' + menu + '" menu_name="' + menu_name + '" menu_order="' + menu_order + '" ></TNode>';
                        });
                    }
                });

                xml += '</Root>';
                data = {"action": "spa_favourites", "flag":"u", "xml":xml};
                adiha_post_data("alert", data, '', '','');
                changed_saved = true;
                //manageFavourites.toolbar.disableItem('save');
                break;
            case "delete":

                var selected_item = manageFavourites.tree.getSelectedItemId();
                var pid = manageFavourites.tree.getParentId(selected_item);                
                if (selected_item != '') {
                    changed_saved = false;
                    manageFavourites.toolbar.enableItem('save');
                    var selected_array = selected_item.split(',');
                    $.each(selected_array, function(i, item) {  
                        manageFavourites.tree.deleteItem(item, true);
                         manageFavourites.toolbar.enableItem('save');
                    });
                } 
                break;
        }
    }
</script>
<style type="text/css">
    html, body {
        width: 100%;
        height: 100%;
        margin: 0px;
        padding: 0px;
        background-color: #ebebeb;
        overflow: hidden;
    }
</style>
</html>