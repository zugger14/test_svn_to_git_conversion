<!--DOCTYPE transitional.dtd-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<meta http-equiv="X-UA-Compatible" content="IE=Edge"> 
<html> 
    <?php 
    include '../../../adiha.php.scripts/components/include.file.v3.php';
    
    $form_name = 'form_maintain_static_data';
    $php_script_loc = $app_php_script_loc;
    $app_user_loc = $app_user_name;
    
    $form_namespace = 'setup_workflow';
    $form_obj = new AdihaStandardForm($form_namespace, 10111200);
    $form_obj->define_grid('grid_setup_workflow', '', 'a', true);
    $form_obj->define_custom_setting(true);
    $form_obj->define_custom_functions('save_workflow', 'load_workflow');
    echo $form_obj->init_form('Workflow', 'Workflow Detail');
    echo $form_obj->close_form();    
    
    $rights_privileges_save = 10111211;
   
    list ($has_rights_privileges_save) = build_security_rights($rights_privileges_save);
   
    $context_menu_json_del = '[{id:"change_icon", text:"Change Icon", img:"change_icon.png", imgdis:"change_icon_dis.png", title: "Change Icon", enabled:true}]';
    ?>         

<script type="text/javascript">
    var has_rights_workflow_save = Boolean('<?php echo $has_rights_privileges_save; ?>');
    is_deleted = false;
    var product_id = '<?php echo $farrms_product_id; ?>';
    
    $(function() {
        setup_workflow.layout.cells('a').showHeader();
        //setup_workflow.menu.hideItem('t1');            
    });

    var checked_node = '';
    setup_workflow.details_layout = {};
    setup_workflow.new_tree = {};
    setup_workflow.original_tree = {};
    
    /**
     * [Load function when the accordion is double clicked]
     */
    setup_workflow.load_workflow = function(win, tab_id, grid_obj) {
        group_id = 1;      
        var active_tab_id = setup_workflow.tabbar.getActiveTab();
        
        win.progressOff();
        var is_new = win.getText();
        //get tab object id
        var id = (tab_id.indexOf('tab_') != -1) ? tab_id.replace('tab_', '') : tab_id;

        //attach layout a left cell anb b right cell.
        setup_workflow['details_layout_' + id] = win.attachLayout({
            pattern:'2U',
            cells: [
                {id: 'a', text:'System Menu'},
                {id: 'b', text: 'Workflow Menu'}
            ]
        });
        
        if (active_tab_id == 'tab_0') {
            setup_workflow['menu' + id] = setup_workflow['details_layout_' + id].attachToolbar({
                icons_path: js_image_path + 'dhxmenu_web/',
                json:[
                    { id: 'save', type: 'button', img: 'save.gif', imgdis:'save_dis.gif', text:'Save', title: 'Save', enabled: has_rights_workflow_save}
                ]
            });
           
        } else {
            setup_workflow['menu' + id] = setup_workflow['details_layout_' + id].attachToolbar({
                icons_path: js_image_path + 'dhxmenu_web/',
                json:[
                    { id: 'save', type: 'button', img: 'save.gif', imgdis:'save_dis.gif', text:'Save', title: 'Save', enabled: has_rights_workflow_save},
                    { id: 'copy', type: 'button', img: 'copy.gif', imgdis:'copy_dis.gif', text:'Copy', title: 'Copy', enabled: has_rights_workflow_save}
                ]
            });
        }
        
        //attach save on click event.
        setup_workflow['menu' + id].attachEvent('onClick', function(id){
            switch(id) {
                case 'save':
                    setup_workflow.new_tree[active_tab_id].stopEdit();
                    if (is_deleted != true) {
                        save_user_workflow();
                    } else {
                        dhtmlx.message ({
                            type: 'confirm',
                            title: "Confirmation",
                            text: 'Some data has been deleted from Workflow Menu. Are you sure you want to save?',
                            callback: function(result) {
                                if (result) {
                                    save_user_workflow();
									is_deleted = false;
                                }
                            }
                        });
                    }
                    break;
                case 'copy':
                   copy_role();
                   break;
            }
        });
        
        setup_workflow['menu_toolbar_' + id] = setup_workflow['details_layout_' + id].cells('b').attachMenu({
            icons_path: js_image_path + 'dhxmenu_web/',
            json:[
                {id:'t2', text:'Edit', img:'edit.gif', items:[
                        {id:'add', text:'Add', img:'add.gif', imgdis:'add_dis.gif', title: 'Add', enabled: has_rights_workflow_save},
                        {id:'delete', text:'Delete', img:'delete.gif', imgdis:'delete_dis.gif', title: 'Delete', enabled: 'false'}
                    ]}
            ]
        });
        
        // attach on click event
        setup_workflow['menu_toolbar_' + id].attachEvent('onClick', function(id){
            var active_tab_id = setup_workflow.tabbar.getActiveTab();
                                
            switch (id) {
                case 'add':
                    var group_name = 'Group ' + group_id;
                    
                    var parent_id = setup_workflow.new_tree[active_tab_id].getSelectedItemId();  
                    parent_id = parent_id == '' ? 0 : parent_id;
                    var target_level = setup_workflow.new_tree[active_tab_id].getLevel(parent_id); 
       
                    if (target_level == 6) {
                        show_messagebox('Grouping is allow upto 6 level only.');  
                        return;
                    }
                    
                    setup_workflow.new_tree[active_tab_id].insertNewItem(parent_id,group_id,group_name,0,0,0,0,'SELECT'); 
                    setup_workflow.new_tree[active_tab_id].setItemImage2(group_id, 'leaf.gif', 'folderClosed.gif', 'folderOpen.gif');//*/
                    group_id += 1;                     
                    break;
                case 'delete':
                    var all_checked = setup_workflow.new_tree[active_tab_id].getSelectedItemId();
                    var checked_array = all_checked.split(',');
                    var not_deleted = false;
                    
                    for(var i = 0; i < checked_array.length; i++) {    
                        setup_workflow.new_tree[active_tab_id].deleteItem(checked_array[i]);
                        change_status();   
                        is_deleted = true;
                    }
                    break;
                }
        });
       
        var active_tab_id = setup_workflow.tabbar.getActiveTab();
        setup_workflow.original_tree[active_tab_id] = setup_workflow['details_layout_' + id].cells('a').attachTree();
        setup_workflow.original_tree[active_tab_id].setImagePath(js_image_path + '/dhxtree_web/');
        var param = {
           'action':'spa_setup_menu',
           'grid_type': 't',
           'value_list': 'l6_id:l6_name',
           'grouping_column':'L1_id:L1_name,l2_id:l2_name,l3_id:l3_name,l4_id:l4_name,l5_id:l5_name'
        };
        param = $.param(param);
        var data_url = js_data_collector_url + '&' + param;
        data_url += '&flag=w&filter_role=' + id + '&product_category=' + product_id;
       
        setup_workflow.original_tree[active_tab_id].loadXML(data_url);
        setup_workflow.original_tree[active_tab_id].attachEvent('onXLE', setup_workflow.expand_all_org_tree);
        setup_workflow.original_tree[active_tab_id].enableDragAndDrop(true, false);
        setup_workflow.original_tree[active_tab_id].enableMercyDrag(true);
        setup_workflow.original_tree[active_tab_id].enableMultiselection(true);
        setup_workflow.original_tree[active_tab_id].attachEvent('onDragIn', setup_workflow.control_dragin);
        setup_workflow.original_tree[active_tab_id].attachEvent('onXLE', setup_workflow.before_grid_load);
       
        load_new_tree(id);                                 
    }
        
    function load_new_tree(id) {
        var active_tab_id = setup_workflow.tabbar.getActiveTab();
        setup_workflow.new_tree[active_tab_id] = setup_workflow['details_layout_' + id].cells('b').attachTree();
        setup_workflow.new_tree[active_tab_id].setImagePath(js_image_path + "/dhxtree_web/");
        var param = {
           'action':'spa_workflow',
           'grid_type': 't',
           'value_list': 'l6_id:l6_name',
           'grouping_column':'l1_id:l1_name,l2_id:l2_name,l3_id:l3_name,l4_id:l4_name,l5_id:l5_name'
        };
        param = $.param(param);
        var data_url = js_data_collector_url + '&' + param;
        data_url += '&flag=t&role_id=' + id;
       
        setup_workflow.new_tree[active_tab_id].enableItemEditor(true);
        setup_workflow.new_tree[active_tab_id].setOnEditHandler(name_check);
        setup_workflow.new_tree[active_tab_id].loadXML(data_url, function() {
           var all_ids = setup_workflow.new_tree[active_tab_id].getAllSubItems(0);
           all_ids = all_ids.split(',');
           var item_level = '';
           for (var i = 0; i <all_ids.length; i++) {
                item_level = setup_workflow.new_tree[active_tab_id].getLevel(all_ids[i]);
                if (item_level == 1) {
                    var data = {
                        'action' : 'spa_workflow_icons',
                        'flag' : 'a',
                        'workflow_menu_id' : all_ids[i] 
                        };
    
                    adiha_post_data('return_array', data, '', '', 'get_image_name', '', '');   
                }
           }             
        }); 
        
        setup_workflow.new_tree[active_tab_id].attachEvent('onXLE', setup_workflow.expand_all);
        setup_workflow.new_tree[active_tab_id].enableDragAndDrop(true, false);
        setup_workflow.new_tree[active_tab_id].enableMultiselection(true);
        setup_workflow.new_tree[active_tab_id].attachEvent('onSelect', function(){ 
            change_status();
        });
        
        setup_workflow.new_tree[active_tab_id].attachEvent('onRightClick', function(id, ind, obj){
            var tree_level = setup_workflow.new_tree[active_tab_id].getLevel(id);
 
                //open context menu
                var tree_obj = setup_workflow.new_tree[active_tab_id];
                context_menu(tree_obj, id, tree_level);
        });

        // Blocks dragging nodes of level 1 and level 2 from system menu to workflow menu
        setup_workflow.new_tree[active_tab_id].attachEvent("onDragIn", function(sId,tId,sObj,tObj) {
            source_level = setup_workflow.original_tree[active_tab_id].getLevel(sId);
            check_if_node_exists = 0;
            source_parent_nodes = sObj.getAllSubItems(sId);
            target_childless_nodes = tObj.getAllChildless();

            source_parent_nodes.split(',').forEach(function(pid) {
                target_childless_nodes.split(',').forEach(function(cid) {
                    child_node = cid.indexOf('_') > -1 ? cid.split("_")[0] : cid;
                    if (pid == child_node) {
                        check_if_node_exists = 1;
                    }
                });
            });
            
            if (source_level <= 2) {
                return false;
            } else if (check_if_node_exists == 1) {
                dhtmlx.message ({
                    type: 'alert',
                    title: 'Alert',
                    text: 'Cannot move current node. One or two child nodes have already been moved.'
                });
                return false;
            } else {
                return true;
            }
        });
    }
                
                 
    
    function get_image_name(return_value) {     
        if (return_value != '') {
            if (return_value[0][3] != '' || return_value[0][3] !== undefined) {
            change_image(return_value[0][2], return_value[0][1], return_value[0][3]);    
        }        
    }
    }
    
    function context_menu(tree_obj, id, level) {
        context_menu_json_del = '<?php echo $context_menu_json_del; ?>';
        var icon_change = new dhtmlXMenuObject();
        icon_change.setIconsPath(js_image_path + '/dhxmenu_web/');
        icon_change.renderAsContextMenu();
        icon_change.loadStruct(context_menu_json_del);
        
		icon_change.attachEvent('onClick', icon_change_click);
        
        if (level == 1) {
            tree_obj.setItemContextMenu(id, icon_change);
        } else {
            // to do
//                  tree_obj.enableContextMenu(false);
//                myMenu.hideContextMenu();
        }                    
    }
    
    function icon_change_click(id, type) {
        var active_tab_id = setup_workflow.tabbar.getActiveTab();
        var data = setup_workflow.new_tree[active_tab_id].contextID.split('_');
 
        unload_change_icon_window();
        
        if (!create_change_icon_window) {
            create_change_icon_window = new dhtmlXWindows();
        }
    
        var new_win = create_change_icon_window.createWindow('w2', 0, 0, 525, 300);
        var params = '?workflow_menu_id=' + data[0];
        
        url = '<?php echo $app_php_script_loc; ?>' +  '../adiha.html.forms/_users_roles/maintain_menu_item/change.icon.php' + params;  
        new_win.setText('Select Icon');  
        new_win.centerOnScreen();
        new_win.setModal(true); 
   
        new_win.attachURL(url, false, true); 
    }
    
    
    var create_change_icon_window;
    /**create_change_icon_window
     * [unload injection withdrawal deal window invoice export window.]
     */
    function unload_change_icon_window() {        
        if (create_change_icon_window != null && create_change_icon_window.unload != null) {
            create_change_icon_window.unload();
            create_change_icon_window = w2 = null;
        }
    }
    
    function change_image(image_name, workflow_menu_id, value_id) {
        //alert(image_name + '_'+ workflow_menu_id +'_' + value_id);
        var active_tab_id = setup_workflow.tabbar.getActiveTab();
        var tree = setup_workflow.new_tree[active_tab_id];
        var image_full_path = '../customize_icons_18/' + image_name + '.png';
        tree.setItemImage2(workflow_menu_id, image_full_path, image_full_path, image_full_path);
        tree.setUserData(workflow_menu_id, 'value_id', value_id);
        //var a = tree.getUserData(workflow_menu_id, 'value_id' );
         
    }
        
    function name_check(state,id,tree,value) {
        if(state == 2)
            value  = value.replace(/^\s+/i, '');
            
        if((state == 2) && (value == "")) {
			return false;
		}
		return true;
    }
    
    function change_status() {
        var active_tab_id = setup_workflow.tabbar.getActiveTab();
        var id = (active_tab_id.indexOf('tab_') != -1) ? active_tab_id.replace('tab_', '') : active_tab_id;
        var is_checked = setup_workflow.new_tree[active_tab_id].getSelectedItemId();
        
        if (is_checked != '' && has_rights_workflow_save == true) {
            setup_workflow['menu_toolbar_' + id].setItemEnabled('add');
            is_checked_array = is_checked.split(',');
            if(is_checked_array.length > 1) {
                setup_workflow['menu_toolbar_' + id].setItemDisabled('add');    
            }
            setup_workflow['menu_toolbar_' + id].setItemEnabled('delete');
        } else{
            setup_workflow['menu_toolbar_' + id].setItemDisabled('delete');
        }
    }
    
    function copy_role() { 
        var active_tab_id = setup_workflow.tabbar.getActiveTab();
        var role_id = new Array();
        role_id = active_tab_id.split('_');
        
         var param = {
            'flag': 'c',
            'role_id': role_id[1],
            'action': 'spa_workflow'
        };
        
        adiha_post_data('confirm-warning', param, '', '', '','','Copy will overwrite your existing data of "My Workflow". Please Confirm.');
    }        
    
    function save_user_workflow() {
        var active_tab_id = setup_workflow.tabbar.getActiveTab();
        var inserted_menu= '';
        var has_child = '';
        var role_id = new Array();
        role_id = active_tab_id.split('_');
                                                            
		var list = setup_workflow.new_tree[active_tab_id].getAllSubItems(0);
	    var leaf_node = setup_workflow.new_tree[active_tab_id].getAllChildless();
        var parent_nodes = setup_workflow.new_tree[active_tab_id].getAllItemsWithKids();
        var leaf_node_split = leaf_node.split(',');
        var parent_nodes_split = parent_nodes.split(',');           
        var items = list.split(',');
	    var xml = '<Root>';
        var user_data = 'NULL';

	    for (var i = 0; i < items.length; i++) {
	        if(items[i] != '') {
                var level_check = setup_workflow.new_tree[active_tab_id].getLevel(items[i]);  
                if (level_check == 1) {
                    user_data = setup_workflow.new_tree[active_tab_id].getUserData(items[i], 'value_id');
                    
                    if (user_data === undefined) {
                        user_data = 'NULL';
                    }
                }    
                            
                var item_level = setup_workflow.new_tree[active_tab_id].getLevel(items[i]);
                var parent_name = setup_workflow.new_tree[active_tab_id].getItemText(items[i]);
                
	            var menu_item = setup_workflow.new_tree[active_tab_id].getAllSubItems(items[i]);
                if (menu_item != 0) {
    	            var menus = new Array();
                	menus = menu_item.split(',');  
                    menu_name_col = new Array();
    	            if (menus.length > 0) {
    	                _.each(menus, function(val, key) { 
                            var menu_name = setup_workflow.new_tree[active_tab_id].getItemText(val);
                            var child_level = setup_workflow.new_tree[active_tab_id].getLevel(val);                            
                     
                            has_child = (leaf_node.indexOf(val) == -1) ? 1 : 0;
                            if (val != '' && (child_level - item_level) == 1 ) {
                                
                                if (item_level == 1 && items[i] != inserted_menu) {
                                    xml += '<PSRecordSet  function_id="' + items[i] + '" menu_name="' + parent_name + '" parent_id="NULL" parent_name="NULL" menu_level = "0" menu_type = "1" user_data = "' + user_data + '"></PSRecordSet>';    	                     
                                    inserted_menu = items[i];
                                }                            
                                xml += '<PSRecordSet  function_id="' + val + '" menu_name="' + menu_name + '" parent_id="' + items[i] + '" parent_name="' + parent_name + '" menu_level = "' + item_level + '" menu_type = "' + has_child + '" user_data = "NULL"></PSRecordSet>';    	
                            }      
    	                });
    	            } 
                }
            }        	        
	    }

        xml += '</Root>'; 
        var param = {
            'flag': 'm',
            'role_id': role_id[1],
            'product_category': product_id,
            'action': 'spa_workflow',
            'xml': xml
        };
        
        adiha_post_data('return_json', param, '', '', 'setup_workflow.msg');
	}

    setup_workflow.msg = function (result) {
        var result_data = JSON.parse(result);

        if ((result_data[0].status).toLowerCase() == 'success') {
            dhtmlx.message(result_data[0].message);
            
            var active_tab_id = setup_workflow.tabbar.getActiveTab();
            var role_id = new Array();
            role_id = active_tab_id.split('_');
            load_new_tree(role_id[1]);
        } else {
            dhtmlx.message ({
                type: 'alert',
                title: "Alert",
                text: result_data[0].message
            });
        }
    }
    
    setup_workflow.expand_all_org_tree = function(id) {
        var active_tab_id = setup_workflow.tabbar.getActiveTab();
        setup_workflow.original_tree[active_tab_id].openAllItems(0);
    }
    
    setup_workflow.expand_all = function(id) {
        var active_tab_id = setup_workflow.tabbar.getActiveTab();
        setup_workflow.new_tree[active_tab_id].openAllItems(0);
        var child_no = setup_workflow.new_tree[active_tab_id].hasChildren(0);
        
        if (child_no == 0) {
            var group_name = 'Group ' + group_id;
            setup_workflow.new_tree[active_tab_id].insertNewItem(0,group_id,group_name);
            group_id += 1;
        }
	}
    
    setup_workflow.control_dragin = function(sid, tid, sObject, tObject) {
        return false;
    }
    
    // Changes text color of level 1 and level 2 nodes to distinguish it with nodes that can be moved
    setup_workflow.before_grid_load = function(grid_obj, count) {
        grid_obj.getAllItemsWithKids().split(",").forEach( function(id) {
            var level = grid_obj.getLevel(id);
            if (level <= 2) {
               grid_obj.setItemStyle(id, "color:#808080;");
            }
        });
    }
    
    
</script>