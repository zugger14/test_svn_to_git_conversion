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
    
    $rights_privileges_add = 10111131;

    list (
        $has_rights_privileges_add
    ) = build_security_rights (
        $rights_privileges_add
    );
    
    $has_rights_privileges_add = ($has_rights_privileges_add == '1') ? 'false' : 'true';
    
    $popup = new AdihaPopup();
    $form_name = 'form_select_privilege';
    $default_role_id = (isset($_GET['default_role_id'])) ? $_GET['default_role_id'] : 'NULL';
    $user_login_id = (isset($_GET['user_login_id']) ? $_GET['user_login_id'] : 'NULL');
    //JSON for Layout   
    $layout_json = '[
                        {
                            id:             "a",
                            text:           "Book Structure",
                            width:          350,
                            header:         true,
                            collapse:       false,
                            fix_size:       [false,null]
                        },
                        {
                            id:             "c",
                            text:           "Menu",
                            header:         true,
                            collapse:       false,
                            fix_size:       [false,null]                            
                        },
                        {
                            id:             "b",
                            text:           "Filter",
                            height:         100,
                            header:         false,
                            collapse:       false,
                            fix_size:       [false,null]
                        },
                        {
                            id:             "d",
                            text:           "Views",
                            height:         180,
                            header:         true,
                            collapse:       true,
                            fix_size:       [false,null]
                        }
                    ]';
                   
        
    $name_space = 'select_privilege';
    
    $select_privilege_layout = new AdihaLayout();
    echo $select_privilege_layout->init_layout('select_privilege', '', '4C', $layout_json, $name_space);
    
    //Attaching toolbar for tree
    $toolbar_user = 'add_user_toolbar';
    echo $select_privilege_layout->attach_toolbar_cell($toolbar_user, 'b');
    $toolbar_user_search = new AdihaToolbar();
    echo $toolbar_user_search->init_by_attach($toolbar_user, $name_space);
    $select_privilege_menu = '[
                            {id:"save", type: "button", img:"save.gif", imgdis:"save_dis.gif", text:"Save", title:"Save", disabled:' . $has_rights_privileges_add . '}
                                     
                        ]';
    echo $toolbar_user_search->load_toolbar($select_privilege_menu);
    echo $toolbar_user_search->attach_event('', 'onClick', 'save_btn_click');
    
    //Attaching toolbar for tree
    $tree_structure = new AdihaBookStructure();
    $tree_name = 'tree_select_privilege';
    echo $select_privilege_layout->attach_tree_cell($tree_name, 'a');
    echo $tree_structure->init_by_attach($tree_name, $name_space);
    echo $tree_structure->set_portfolio_option(2);
    echo $tree_structure->set_subsidiary_option(2);
    echo $tree_structure->set_strategy_option(2);
    echo $tree_structure->set_book_option(2);
    echo $tree_structure->set_subbook_option(2);
    echo $tree_structure->load_book_structure_data();
    echo $tree_structure->load_tree_functons();
    echo $tree_structure->expand_Level();
   // echo $tree_structure->expand_tree(2);
    echo $tree_structure->load_bookstructure_events();
	echo $tree_structure->attach_search_filter('select_privilege.select_privilege', 'a');

    $form_object = new AdihaForm();
    $form_save_name = 'save_form';
    echo "tag1_dropdown = ". $form_object->adiha_form_dropdown("EXEC spa_get_all_function_id 'm'",0,1) . ";"."\n";
    echo "tag2_dropdown = ". $form_object->adiha_form_dropdown("EXEC spa_application_security_role 'y'",1,2) . ";"."\n";

    $form_save_load = "[
                        {type: 'combo', name: 'cmb_menu_group_filter', label: 'Menu Group:', width: 150, options: tag1_dropdown, position:'label-top', 'offsetLeft': '10'},
                        {type: 'newcolumn'},
                        {type: 'combo', name: 'cmb_role_filter', label: 'Role:', width: 150, options: tag2_dropdown, position:'label-top', 'offsetLeft': '20'},
                        ]";

    echo $select_privilege_layout->attach_form($form_save_name, 'b');
    echo $form_object->init_by_attach($form_save_name, $name_space);
    echo $form_object->load_form($form_save_load);
    //echo $form_object->attach_event('', 'onButtonClick', 'save_btn_click', $name_space.'.'.$form_save_name);     

    $menu_json = '[{id:"expand_collapse", text:"Expand/Collapse", img:"exp_col.gif", imgdis:"exp_col_dis.gif", enabled: 1}]';
    $privilege_menu_name = 'privilege_menu';
    echo $select_privilege_layout->attach_menu_layout_cell($privilege_menu_name, 'c', $menu_json, $name_space . '.menu_click');
    
    $original_tree_name = 'original_tree';
    echo $select_privilege_layout->attach_tree_cell($original_tree_name, 'c');
    $original_tree = new AdihaTree();
    echo $original_tree->init_by_attach($original_tree_name, $name_space);
    $grouping_list = "function_level_6:function_name_6,function_level_5:function_name_5,function_level_4:function_name_4,function_level_3:function_name_3,function_level_2:function_name_2";
    $additional_param = "product_category=" . $farrms_product_id . "&flag=b";
    echo $original_tree->load_tree_xml('spa_setup_menu', 'function_level_1:function_name_1', $grouping_list, $additional_param);
    echo $original_tree->enable_checkbox();
    echo $original_tree->attach_event('', 'onXLE', 'privilege_tree_onload');
    echo $original_tree->enable_DND('false');
   
    $grid_name = 'grd_report_view';
    echo $select_privilege_layout->attach_grid_custom_layout($grid_name, 'd', $name_space . '.select_privilege');
    $grid_view_privilege = new AdihaGrid(''); 
    echo $grid_view_privilege->init_by_attach($grid_name, $name_space);
    //echo $grid_view_privilege->load_grid_data("exec('select data_source_id, name , alias from data_source where type_id = 1')"); 
    echo $grid_view_privilege->set_header('ID, View Name, Alias');
    echo $grid_view_privilege->set_columns_ids('data_source_id, name, alias');
    echo $grid_view_privilege->set_column_visibility('false,false,false');
    echo $grid_view_privilege->set_widths('100,235,200');
    echo $grid_view_privilege->set_column_types("ro,ro,ro");
    echo $grid_view_privilege->set_column_auto_size(); 
    echo $grid_view_privilege->enable_multi_select();
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
    var login_id = '<?php echo $user_login_id; ?>';    
    var expand_state = 0;
   
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
        
        /*
        /*
         * To load the view grid when report manager view is checked.
         */
        select_privilege.original_tree.attachEvent("onCheck", function(id, state){
           if (id == 10201633 && state == 1) {
                var param = {
                                "flag": "p",
                                "product_category": "<?php echo $farrms_product_id; ?>",
                                "action": "spa_setup_menu",
                                "grid_type": "g"
                            };
                
                param = $.param(param);
                var param_url = js_data_collector_url + "&" + param;
                select_privilege.grd_report_view.clearAll();
                select_privilege.grd_report_view.loadXML(param_url);
                select_privilege.select_privilege.cells('d').expand();
            } else {
                select_privilege.grd_report_view.clearAll();
                select_privilege.select_privilege.cells('d').collapse();
            }
        });
    
        select_privilege.save_form.attachEvent("onChange", function (name, value){
            if (name == 'cmb_menu_group_filter' || name == 'cmb_role_filter') {
                orginal_tree_refresh();
            }
        });
    }); 
    
        
    function orginal_tree_refresh() {
        var filter_obj = select_privilege.select_privilege.cells('b').getAttachedObject();
        var role_value = filter_obj.getItemValue('cmb_role_filter');
        var menu_group_value = filter_obj.getItemValue('cmb_menu_group_filter');
        //select_privilege.refresh_tree('spa_setup_menu', 'function_level_1:function_name_1', 'function_level_6:function_name_6,function_level_5:function_name_5,function_level_4:function_name_4,function_level_3:function_name_3,function_level_2:function_name_2', 'flag=e');
        
        select_privilege.original_tree.deleteChildItems(0);
        select_privilege.original_tree.setSkin("dhx_web");
        select_privilege.original_tree.setImagePath(app_script_loc + "components/lib/adiha_dhtmlx/themes/" + theme_selected + "/imgs/dhxtree_web/");
        
        var param = {
           "action":'spa_setup_menu',
           "grid_type": "t",
           "value_list":'function_level_1:function_name_1', 
           "product_category": "<?php echo $farrms_product_id; ?>",
           "grouping_column":'function_level_6:function_name_6,function_level_5:function_name_5,function_level_4:function_name_4,function_level_3:function_name_3,function_level_2:function_name_2',
        };
        param = $.param(param);
        var data_url = js_data_collector_url + "&" + param;
        data_url += "&flag=e', @filter_menu='" + menu_group_value + "', @filter_role='" + role_value;
        select_privilege.original_tree.loadXML(data_url);
        
    }
        
    
    function save_btn_click(args) {
        switch(args) {
            case 'save':
                var book_id_concat = get_selected_book_structure();
                // var trees_id = select_privilege.original_tree.getAllChecked();
                
                var trees_id_partially_checked = select_privilege.original_tree.getAllPartiallyChecked();
                var trees_id_checked = select_privilege.original_tree.getAllChecked();

                var role_id = '<?php echo $default_role_id; ?>';
                
                /*if(book_id_concat == '' ){
                    show_messagebox('Please select a Book.');
                    return;
                }
                */
                //Remove nodes with child
                var splited_value_partially_checked = trees_id_partially_checked.split(",");
                var splited_value_checked = trees_id_checked.split(",");

                var checked_value = new Array();
                for(var i = 0; i < splited_value_partially_checked.length; i++) {
                //     var has_child = select_privilege.original_tree.hasChildren(splited_value_partially_checked[i]);
                //     //if(has_child == 0) {
                        var func_id = splited_value_partially_checked[i].split("_");
                        checked_value.push(func_id[0]);
                   // }
                }
                for(var i = 0; i < splited_value_checked.length; i++) {
                  //  var has_child = select_privilege.original_tree.hasChildren(splited_value_checked[i]);
                    //if(has_child == 0) {
                        var func_id_checked = splited_value_checked[i].split("_");
                        checked_value.push(func_id_checked[0]);
                   // }
                }
                
                var trees_id_concat = checked_value.join();
                if (trees_id_partially_checked == 'NULL' || trees_id_partially_checked == '') {
                    dhtmlx.alert({
                         title: "Alert",
                         type: "alert",
                         text: "Please select required menus."
                     });
                    return;
                }
           
                if (role_id == 'NULL') {
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
                        var view_id = select_privilege.grd_report_view.cells2(row_index,0).getValue();
                        view_id_array.push(view_id);
                    });
                    var view_id_string = view_id_array.toString();
                }
                
                
                data = {"action": "spa_AccessRights",
                        "flag": "i",
                        "functional_user_id": "NULL",
                        "function_id_text": trees_id_concat,
                        "role_id": "NULL",
                        "login_id": login_id,
                        "role_user_flag" : role_user_flag,
                        "entity_id": book_id_concat,
                        "accessright": "NULL",
                        "rm_view_id": view_id_string
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
</script>