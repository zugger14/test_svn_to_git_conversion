<?php
/**
* Select privileges screen
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
    $php_script_loc = $app_php_script_loc;
    $app_user_loc = $app_user_name;

    $call_from = get_sanitized_value($_GET['call_from'] ?? '');
    $flag = get_sanitized_value($_GET['flag'] ?? '');
    $function_id = get_sanitized_value($_GET['function_id'] ?? '');
    $show_all = 0;
    if ($flag == 'u') {
        $show_all = 1;
    }
    $rights_privileges_add = '';
    
    if ($call_from == 'r') {
       $rights_privileges_add = 10111131; 
    } else if ($call_from == 'u') {
        $rights_privileges_add = 10111031;
    }
    

    list (
        $has_rights_privileges_add
    ) = build_security_rights (
        $rights_privileges_add
    );
    
    $has_rights_privileges_add = ($has_rights_privileges_add == '1') ? 'false' : 'true';
    
    $popup = new AdihaPopup();
    $form_name = 'form_select_privilege';

    $default_role_id = (isset($_GET['default_role_id'])) ? $_GET['default_role_id'] : NULL;
    $user_login_id = (isset($_GET['user_login_id'])) ? $_GET['user_login_id'] : NULL;
    $porfolio_data = array();
    if ($flag == 'u') {
        $porfolio_sql = "EXEC spa_AccessRights @flag='e', @login_id='$user_login_id', @application_function_id='$function_id'";
        $porfolio_data = readXMLURL2($porfolio_sql);
    }

//JSON for Layout
    $layout_json = '[
                        {
                            id:             "a",
                            text:           "Portfolio Group",
                            width:          507,
                            height:         130,
                            header:         true,
                            collapse:       false,
                            fix_size:       [false,null]
                        },
                        {
                            id:             "b",
                            text:           "Portfolio Hierarchy",
                            header:         true,
                            collapse:       false,
                            fix_size:       [false,null]
                        },
                        {
                            id:             "d",
                            text:           "Menu",
                            header:         true,
                            collapse:       false,
                            fix_size:       [false,null]                            
                        },
                        {
                            id:             "c",
                            text:           "Filter",
                            height:         100,
                            header:         false,
                            collapse:       false,
                            fix_size:       [false,null]
                        },
                        {
                            id:             "e",
                            text:           "Views",
                            height:         180,
                            header:         true,
                            collapse:       true,
                            fix_size:       [false,null]
                        }
                    ]';
                   
        
    $name_space = 'select_privilege';
    
    $select_privilege_layout = new AdihaLayout();
    echo $select_privilege_layout->init_layout('select_privilege', '', '5S', $layout_json, $name_space);
    
    //Attaching toolbar for tree
    $toolbar_user = 'add_user_toolbar';
    echo $select_privilege_layout->attach_toolbar_cell($toolbar_user, 'c');
    $toolbar_user_search = new AdihaToolbar();
    echo $toolbar_user_search->init_by_attach($toolbar_user, $name_space);
    $select_privilege_menu = '[
                            {id:"save", type: "button", img:"save.gif", imgdis:"save_dis.gif", text:"Save", title:"Save", disabled:' . $has_rights_privileges_add . '}
                                     
                        ]';
    echo $toolbar_user_search->load_toolbar($select_privilege_menu);
    echo $toolbar_user_search->attach_event('', 'onClick', 'save_btn_click');
    
    // ## Add Group 1 to 4 in form
    $groups_form_name = 'groups_form';
    $groups_form_object = new AdihaForm();
    echo "var group1 = " . $groups_form_object->adiha_form_dropdown("EXEC spa_source_book_maintain @flag='x',@source_system_book_type_value_id=50", 0, 1, true) . ";" . "\n";
    echo "var group2 = " . $groups_form_object->adiha_form_dropdown("EXEC spa_source_book_maintain @flag='x',@source_system_book_type_value_id=51", 0, 1, true) . ";" . "\n";
    echo "var group3 = " . $groups_form_object->adiha_form_dropdown("EXEC spa_source_book_maintain @flag='x',@source_system_book_type_value_id=52", 0, 1, true) . ";" . "\n";
    echo "var group4 = " . $groups_form_object->adiha_form_dropdown("EXEC spa_source_book_maintain @flag='x',@source_system_book_type_value_id=53", 0, 1, true) . ";" . "\n";

    $groups_form_json = "[
                        {type: 'combo', comboType: 'custom_checkbox', filtering: true, filtering_mode: 'between', name: 'group1', label: 'Tag 1', width: " . $ui_settings['field_size'] . ", options: group1, position:'label-top', 'offsetLeft': '" . $ui_settings['offset_left'] . "'},
                        {type: 'newcolumn'},
                        {type: 'combo', comboType: 'custom_checkbox', filtering: true, filtering_mode: 'between', name: 'group2', label: 'Tag 2', width: " . $ui_settings['field_size'] . ", options: group2, position:'label-top', 'offsetLeft': '" . $ui_settings['offset_left'] . "'},
                        {type: 'newcolumn'},
                        {type: 'combo', comboType: 'custom_checkbox', filtering: true, filtering_mode: 'between', name: 'group3', label: 'Tag 3', width: " . $ui_settings['field_size'] . ", options: group3, position:'label-top', 'offsetLeft': '" . $ui_settings['offset_left'] . "'},
                        {type: 'newcolumn'},
                        {type: 'combo', comboType: 'custom_checkbox', filtering: true, filtering_mode: 'between', name: 'group4', label: 'Tag 4', width: " . $ui_settings['field_size'] . ", options: group4, position:'label-top', 'offsetLeft': '" . $ui_settings['offset_left'] . "'}
                        ]";
    echo $select_privilege_layout->attach_form($groups_form_name, 'a');
    echo $groups_form_object->init_by_attach($groups_form_name, $name_space);
    echo $groups_form_object->load_form($groups_form_json);

    //Attaching toolbar for tree
    $tree_structure = new AdihaBookStructure($rights_privileges_add);
    $tree_name = 'tree_select_privilege';
    echo $select_privilege_layout->attach_tree_cell($tree_name, 'b');
    echo $tree_structure->init_by_attach($tree_name, $name_space);
    echo $tree_structure->set_portfolio_option(2);
    echo $tree_structure->set_subsidiary_option(2);
    echo $tree_structure->set_strategy_option(2);
    echo $tree_structure->set_book_option(2);
    echo $tree_structure->set_subbook_option(0);
    echo $tree_structure->load_book_structure_data();
    echo $tree_structure->load_tree_functons();
    echo $tree_structure->expand_Level();
   // echo $tree_structure->expand_tree(2);
    echo $tree_structure->load_bookstructure_events();
	echo $tree_structure->attach_search_filter('select_privilege.select_privilege', 'b');

    $form_object = new AdihaForm();
    $form_save_name = 'save_form';
    echo "tag1_dropdown = ". $form_object->adiha_form_dropdown("EXEC spa_get_all_function_id @flag='m',@product_id=" . $farrms_product_id ,0,1,true) . ";"."\n";
    echo "tag2_dropdown = ". $form_object->adiha_form_dropdown("EXEC spa_application_security_role 'y'",1,2,true) . ";"."\n";

    $form_save_load = "[
                        {type: 'input', name: 'search_text', label: 'Search', width: " . $ui_settings['field_size'] . ", position:'label-top', 'offsetLeft': '" . $ui_settings['offset_left'] . "'},
                        {type: 'newcolumn'},   
                        {type: 'combo', name: 'cmb_menu_group_filter', label: 'Menu Group', filtering:true, filtering_mode:'between', width: " . $ui_settings['field_size'] . ", options: tag1_dropdown, position:'label-top', 'offsetLeft': '" . $ui_settings['offset_left'] . "'},
                        {type: 'newcolumn'},
                        {type: 'combo', name: 'cmb_role_filter', label: 'Role', filtering:true, filtering_mode:'between', width: " . $ui_settings['field_size'] . ", options: tag2_dropdown, position:'label-top', 'offsetLeft': '" . $ui_settings['offset_left'] . "'},
                        ]";

    echo $select_privilege_layout->attach_form($form_save_name, 'c');
    echo $form_object->init_by_attach($form_save_name, $name_space);
    echo $form_object->load_form($form_save_load);
    //echo $form_object->attach_event('', 'onButtonClick', 'save_btn_click', $name_space.'.'.$form_save_name);     

    $menu_json = '[{id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif", enabled: 1},
                   {id:"expand_collapse", text:"Expand/Collapse", img:"exp_col.gif", imgdis:"exp_col_dis.gif", enabled: 1}
                  ]';
    $privilege_menu_name = 'privilege_menu';
    echo $select_privilege_layout->attach_menu_layout_cell($privilege_menu_name, 'd', $menu_json, $name_space . '.menu_click');
    
    $original_tree_name = 'original_tree';
    echo $select_privilege_layout->attach_tree_cell($original_tree_name, 'd');
    $original_tree = new AdihaTree();
    echo $original_tree->init_by_attach($original_tree_name, $name_space);
    $grouping_list = "function_level_7:function_name_7,function_level_6:function_name_6,function_level_5:function_name_5,function_level_4:function_name_4,function_level_3:function_name_3,function_level_2:function_name_2";
    
    $additional_param = "product_category=" . $farrms_product_id . "&flag=b" . (($call_from == 'r') ? "&role_id=" . $default_role_id : "&login_id=" . $user_login_id)."&show_all=".$show_all;
    echo $original_tree->load_tree_xml('spa_setup_menu', 'function_level_1:function_name_1', $grouping_list, $additional_param);
    echo $original_tree->enable_checkbox();
    echo $original_tree->attach_event('', 'onXLE', 'privilege_tree_onload');
    echo $original_tree->enable_DND('false');
   
    $grid_name = 'grd_report_view';
    echo $select_privilege_layout->attach_grid_custom_layout($grid_name, 'e', $name_space . '.select_privilege');
    $grid_view_privilege = new AdihaGrid(''); 
    echo $grid_view_privilege->init_by_attach($grid_name, $name_space);
    //echo $grid_view_privilege->load_grid_data("exec('select data_source_id, name , alias from data_source where type_id = 1')"); 
    echo $grid_view_privilege->set_header('ID, View Name, Alias');
    echo $grid_view_privilege->set_columns_ids('data_source_id, name, alias');
    echo $grid_view_privilege->set_sorting_preference('int,str,str');
    echo $grid_view_privilege->set_column_visibility('false,false,false');
    echo $grid_view_privilege->set_widths('100,235,200');
    echo $grid_view_privilege->set_column_types("ro,ro,ro");
    echo $grid_view_privilege->set_column_auto_size(); 
    echo $grid_view_privilege->enable_multi_select();
    echo $grid_view_privilege->set_search_filter(true);
    echo $grid_view_privilege->return_init(); 
            
    echo $select_privilege_layout->close_layout();        
?>
</body>

<style type="text/css">
    html, body {
        width: 100%;
        height: 100%;
        margin: 0px;
        overflow: hidden;
    }
</style>

<script type="text/javascript">
    var app_script_loc = '<?php echo $php_script_loc; ?>';
    select_privilege.form_select_privilege = {};
    select_privilege.grd_report_view = {};
    select_privilege.original_tree = {};    
    var expand_state = 0;
    var call_from = '<?php echo $call_from; ?>';
    var flag = '<?php echo $flag; ?>';
    var function_id = '<?php echo $function_id; ?>';
    var login_id = (call_from == 'u') ? '<?php echo $user_login_id; ?>' : 'NULL';
    var default_role_id = (call_from == 'r') ? '<?php echo $default_role_id; ?>' : '';
	var theme_selected = 'dhtmlx_' + default_theme;
    var report_manager_view_node_state = 0;
	var porfolio_data_array= <?php echo json_encode($porfolio_data ); ?>;

    /**
     * Checks all groups dropdown to whether to enable/disable portfolio hierarchy
     * Clears and enables portfolio heierarchy if any group is checked
     * Enables portfolio hierarchy if none groups are checked
     */
    select_privilege.disable_portfolio_hierarchy = function() {
        var group_data = select_privilege.groups_form.getFormData();
        var source_system_book_id1 = group_data.group1.join(",");
        var source_system_book_id2 = group_data.group2.join(",");
        var source_system_book_id3 = group_data.group3.join(",");
        var source_system_book_id4 = group_data.group4.join(",");

        if (source_system_book_id1 != '' || source_system_book_id2 != '' || source_system_book_id3 != '' || source_system_book_id4 != '') {
            select_privilege.clear_and_disable_tree();
        } else {
            select_privilege.enable_tree(true);
        }
    }

   select_privilege.menu_click = function(id){
        switch(id) {            
            case "expand_collapse":
                var a = select_privilege.original_tree.getSubItems(0).split(","); 
       
                if (expand_state == 0) {
                    select_privilege.original_tree.openAllItems(a[0]);
                    expand_state = 1;
                } else {
                    select_privilege.original_tree.closeAllItems(a[0]);
                    select_privilege.original_tree.openItem(a[0]);   
                    expand_state = 0;
                }                    
                break;
            case "refresh":
                orginal_tree_refresh();
                break;
            case 'chk_all_book':
                show_all_available_privileges();
                break;
            default:
                dhtmlx.alert({
                    title:'Error',
                    type:"alert-error",
                    text:"Under Maintainence! We will be back soon!"
                });
                break;
        }
   }
       
    $(function() {
        select_privilege.tree_select_privilege.enableThreeStateCheckboxes(true);
        select_privilege.original_tree.enableThreeStateCheckboxes(true);
        select_privilege.privilege_menu.addNewSibling('expand_collapse',"show_all", 'Hide/Show All Available Privileges', false, "Additional.gif", "Additional_dis.gif");
        select_privilege.privilege_menu.addCheckbox('child',"show_all", null, 'chk_all_book', "Show All", 0, 4);
        /*
        /*
         * To load the view grid when report manager view is checked.
         */
        select_privilege.original_tree.attachEvent("onCheck", function(id, state){
            var report_view_node_checked = select_privilege.original_tree.isItemChecked(10201633);

            if (report_view_node_checked == 1 && report_manager_view_node_state == 0) {
                report_manager_view_node_state = 1;
                var param = {
                                "flag": "p",
                                "product_category": "<?php echo $farrms_product_id; ?>",
                                "action": "spa_setup_menu",
                                "role_user_flag": call_from,
                                "role_id": default_role_id,
                                "login_id": login_id,
                                "grid_type": "g"
                            };
                
                param = $.param(param);
                var param_url = js_data_collector_url + "&" + param;
                select_privilege.grd_report_view.clearAll();
                select_privilege.grd_report_view.loadXML(param_url);
                select_privilege.select_privilege.cells('e').expand();
            } else if (report_view_node_checked == 0 && report_manager_view_node_state == 1) {
                report_manager_view_node_state = 0;
                select_privilege.grd_report_view.clearAll();
                select_privilege.select_privilege.cells('e').collapse();
            }
        });
    
        //select_privilege.save_form.attachEvent("onChange", function (name, value){
//            if (name == 'cmb_menu_group_filter' || name == 'cmb_role_filter') {
//                orginal_tree_refresh();
//            }
//        });
       
       /**
        * Attach onCheck events on all groups combo to disable portfolio hierarchy if needed
        */
       var group1_combo_obj = select_privilege.groups_form.getCombo('group1');
       var group2_combo_obj = select_privilege.groups_form.getCombo('group2');
       var group3_combo_obj = select_privilege.groups_form.getCombo('group3');
       var group4_combo_obj = select_privilege.groups_form.getCombo('group4');

       if (flag == 'u') {
           select_privilege.select_privilege.cells('c').hideArrow();
           select_privilege.select_privilege.cells('d').hideArrow();
           select_privilege.select_privilege.cells('e').hideArrow();
           select_privilege.select_privilege.cells('e').setText('');
           select_privilege.select_privilege.cells('c').setHeight(20);
           select_privilege.select_privilege.cells('c').fixSize(false, true);
           for (var i = 0; i < porfolio_data_array.length; i++) {
               if (porfolio_data_array[i].entity_id) { // IF Portfolio Hierarchy was selected
                   select_privilege.set_book_structure_node(porfolio_data_array[i].entity_id,porfolio_data_array[i].level)
               } else { // IF Portfolio Group was selected
                   if (porfolio_data_array[i].source_system_book_id1) {
                       $.each(porfolio_data_array[i].source_system_book_id1.split(','), function(index, value) {
                           var combo_index = group1_combo_obj.getIndexByValue(value);
                           group1_combo_obj.setChecked(combo_index,true);
                       });
                   }

                   if (porfolio_data_array[i].source_system_book_id2) {
                       $.each(porfolio_data_array[i].source_system_book_id2.split(','), function(index, value) {
                           var combo_index = group2_combo_obj.getIndexByValue(value);
                           group2_combo_obj.setChecked(combo_index,true);
                       });
                   }

                   if (porfolio_data_array[i].source_system_book_id3) {
                       $.each(porfolio_data_array[i].source_system_book_id3.split(','), function(index, value) {
                           var combo_index = group3_combo_obj.getIndexByValue(value);
                           group3_combo_obj.setChecked(combo_index,true);
                       });
                   }

                   if (porfolio_data_array[i].source_system_book_id4) {
                       $.each(porfolio_data_array[i].source_system_book_id4.split(','), function(index, value) {
                           var combo_index = group4_combo_obj.getIndexByValue(value);
                           group4_combo_obj.setChecked(combo_index,true);
                       });
                   }

                   if (porfolio_data_array[i].source_system_book_id1 || porfolio_data_array[i].source_system_book_id2 || porfolio_data_array[i].source_system_book_id3 || porfolio_data_array[i].source_system_book_id4) {
                       select_privilege.disable_portfolio_hierarchy();
                   }
               }
           }
           select_privilege.privilege_menu.setItemDisabled('refresh');
           select_privilege.privilege_menu.setItemDisabled('expand_collapse');
           select_privilege.privilege_menu.setItemDisabled('show_all');
           select_privilege.select_privilege.cells('e').hideArrow();
       }

       group1_combo_obj.attachEvent('onCheck', select_privilege.disable_portfolio_hierarchy);
       group2_combo_obj.attachEvent('onCheck', select_privilege.disable_portfolio_hierarchy);
       group3_combo_obj.attachEvent('onCheck', select_privilege.disable_portfolio_hierarchy);
       group4_combo_obj.attachEvent('onCheck', select_privilege.disable_portfolio_hierarchy);
    }); 
    
        
    function orginal_tree_refresh(is_checked) {
        is_checked = (is_checked == undefined) ? 0 : is_checked;
        var filter_obj = select_privilege.select_privilege.cells('c').getAttachedObject();
        var search_text = filter_obj.getItemValue('search_text');
        var role_value = filter_obj.getItemValue('cmb_role_filter');
        var menu_group_value = filter_obj.getItemValue('cmb_menu_group_filter');
        //select_privilege.refresh_tree('spa_setup_menu', 'function_level_1:function_name_1', 'function_level_6:function_name_6,function_level_5:function_name_5,function_level_4:function_name_4,function_level_3:function_name_3,function_level_2:function_name_2', 'flag=e');
        
        select_privilege.original_tree.deleteChildItems(0);
        select_privilege.original_tree.setSkin("dhx_web");
        select_privilege.original_tree.setImagePath(app_script_loc + "components/lib/adiha_dhtmlx/themes/" + theme_selected + "/imgs/dhxtree_web/");
        
        var param = {
           "action":'spa_setup_menu',
           "grid_type": "t",
           "show_all": is_checked,
           "value_list":'function_level_1:function_name_1',
           "product_category": "<?php echo $farrms_product_id; ?>", 
           "grouping_column":'function_level_7:function_name_7,function_level_6:function_name_6,function_level_5:function_name_5,function_level_4:function_name_4,function_level_3:function_name_3,function_level_2:function_name_2',
        };
        param = $.param(param);
        var data_url = js_data_collector_url + "&" + param;
        data_url += "&flag=b" + ((call_from == 'r') ? "&role_id=" + default_role_id : "&login_id=" + login_id) + "&filter_text=" + search_text + "&filter_menu=" + menu_group_value + "&filter_role=" + role_value;
        
        select_privilege.original_tree.loadXML(data_url);
        
        // Handled Views Layout Cell when Menu tree is refreshed
        report_manager_view_node_state = 0;
        select_privilege.grd_report_view.clearAll();
        select_privilege.select_privilege.cells('e').collapse();
    }
    
    
    function save_btn_click(args) {
        switch(args) {
            case 'save':
                var book_id_concat = get_selected_book_structure();
                var group_data = select_privilege.groups_form.getFormData();
                var source_system_book_id1 = group_data.group1.join(",");
                var source_system_book_id2 = group_data.group2.join(",");
                var source_system_book_id3 = group_data.group3.join(",");
                var source_system_book_id4 = group_data.group4.join(",");

                var trees_id = select_privilege.original_tree.getAllChecked();
                var role_id = (call_from == 'r') ? '<?php echo $default_role_id; ?>' : 'NULL';
                
                // Force to select Group/Book not both
                if(book_id_concat != '' && (source_system_book_id1 != '' || source_system_book_id2 != '' || source_system_book_id3 != '' || source_system_book_id4 != '')){
                    show_messagebox('Please select either a Book or a Group not both.');
                    return;
                }
                
                //Remove nodes with child
                var splited_value = trees_id.split(",");
                var checked_value = new Array();
                for(var i = 0; i < splited_value.length; i++) {
                    var has_child = select_privilege.original_tree.hasChildren(splited_value[i]);
                    if(has_child == 0) {
                        var func_id = splited_value[i].split("_");
                        checked_value.push(func_id[0]);
                    }
                }
                
                var trees_id_concat = checked_value.join();
                if (trees_id == 'NULL' || trees_id == '') {
					show_messagebox("Please select required menus.");
                    return;
                }
          
                if (call_from == 'u') {
                    var role_user_flag = 'u';                    
                } else 
                    var role_user_flag = 'r';
           
                var selected_views = select_privilege.grd_report_view.getSelectedRowId();
                if (selected_views == null || selected_views == '' || selected_views == 'null' || selected_views == 'NULL') {
                        view_id_string = 'NULL';
                } else {
                    var selected_views_array = selected_views.split(',');
                    var view_id_array = new Array();
                    selected_views_array.forEach(function(row_index) {
                        var view_id = select_privilege.grd_report_view.cells(row_index,0).getValue();
                        view_id_array.push(view_id);
                    });
                    var view_id_string = view_id_array.toString();
                }
                
                // return;
                data = {"action": "spa_AccessRights",
                        "flag": "i",
                        "functional_user_id": "NULL",
                        "function_id_text": trees_id_concat,
                        "role_id": role_id,
                        "login_id": login_id,
                        "role_user_flag" : role_user_flag,
                        "entity_id": book_id_concat,
                        "accessright": "NULL",
                        "rm_view_id": view_id_string,
                        "source_system_book_id1": null_if_blank(source_system_book_id1),
                        "source_system_book_id2": null_if_blank(source_system_book_id2),
                        "source_system_book_id3": null_if_blank(source_system_book_id3),
                        "source_system_book_id4": null_if_blank(source_system_book_id4),
                        "is_update" : (flag == 'u')?'1':'0'
                };
                adiha_post_data("confirm", data, '', '', 'privilege_save_success_callback', '', 'Are you sure you want to add the selected privilege?');
      
                break; 
        }
    };
      
    function cmb_menu_group_filter() {
          
    }
       
    function privilege_tree_onload() {
        var a = select_privilege.original_tree.getSubItems(0).split(","); 
        select_privilege.original_tree.openItem(a[0]);    
        if (flag == 'u') {
            select_privilege.original_tree.openItem(function_id);
            /* When view is selected it has same function id as its parent causing all the child nodes to be selected
            * Looping through child node and only selecting view privelege*/
            if (select_privilege.original_tree.hasChildren(function_id) != 0) {
                var child_nodes = select_privilege.original_tree.getSubItems(function_id);
                var child_nodes_array = child_nodes.split(",");
                for (var i = 0; i < child_nodes_array.length; i++) {
                    if (child_nodes_array[i].split('_')[0] == function_id) {
                        select_privilege.original_tree.setCheck(child_nodes_array[i],true);
                        break;
                    }
                }
            } else {
                select_privilege.original_tree.setCheck(function_id,true);
            }
            select_privilege.original_tree.focusItem(function_id);
            select_privilege.original_tree.lockTree(true);
        }
    }
        
    function template_response(result) {
        var data_url = js_data_collector_url + "&" + result;
        select_privilege.orignal_tree.loadXML(data_url);
        select_privilege.orignal_tree.attachEvent('onXLE', select_privilege.orignal_tree.expand_all);
      
        var json_obj = $.parseJSON(result);
        var json_data = {"total_count":json_obj.length, "pos":0, "data":json_obj};
          
    }
            
    function privilege_save_success_callback(result) {
        if (result[0].errorcode == 'Success') {
        setTimeout('parent.privilege_win.close()', 1000);
    }
    }
     
    function get_selected_book_structure() {
        var subsidary_id = select_privilege.get_tree_checked_value(2);
            subsidary_id = subsidary_id.toString();
        var subsidary_arr = subsidary_id.split(",");
        
        var strategy_id = select_privilege.get_tree_checked_value(3);
            strategy_id = strategy_id.toString();
        var strategy_arr = strategy_id.split(",");
        var final_strategy_arr = strategy_id.split(",");
        
        var books_id = select_privilege.get_tree_checked_value(4);
            books_id = books_id.toString();        
        var books_arr = books_id.split(",");
        var final_books_arr = books_id.split(",");
        
        //Filter Books
        for (var j = 0; j < books_arr.length; j++) {
            var book_parent_id = select_privilege.tree_select_privilege.getParentId(books_arr[j]);
            if (final_strategy_arr.indexOf(book_parent_id) != -1) {
                var index = final_books_arr.indexOf(books_arr[j]);
                final_books_arr.splice(index, 1);
            }
        }
        
        //Filter Strategy
        for (var i = 0; i < strategy_arr.length; i++) {
            var parent_id = select_privilege.tree_select_privilege.getParentId(strategy_arr[i]);
            
            if (subsidary_arr.indexOf(parent_id) != -1) {
                var index = final_strategy_arr.indexOf(strategy_arr[i]);
                final_strategy_arr.splice(index, 1);
            }
            
        }
       
        //Concat Subsidary, Strategy, Books
        var selected_book_structure = '';
        if (subsidary_id != '' || final_strategy_arr != '' || final_books_arr != '') {
            if (subsidary_id != '') {
                selected_book_structure += subsidary_id.replace(/a_/g, "");
            }
            
            if (final_strategy_arr != '') {
                if (selected_book_structure != '') {
                    selected_book_structure += ',';
                }
                selected_book_structure += final_strategy_arr.join().replace(/b_/g, "");
            }
            
            if (final_books_arr != '') {
                if (selected_book_structure != '') {
                    selected_book_structure += ',';
                }
                selected_book_structure += final_books_arr.join().replace(/c_/g, "");
            }
        }
        
        return selected_book_structure;
     }

     function show_all_available_privileges() {
        var is_checked = (select_privilege.privilege_menu.getCheckboxState('chk_all_book') == true) ? 1 : 0;

        orginal_tree_refresh(is_checked);
     }

    /**
     * Returns NULL if value is empty or undefined
     * @param  {String} value value to be checked
     * @return {String}       required value
     */
    function null_if_blank(value) {
        return (value == "" || value == "undefined") ? "NULL" : value;
    }
</script>