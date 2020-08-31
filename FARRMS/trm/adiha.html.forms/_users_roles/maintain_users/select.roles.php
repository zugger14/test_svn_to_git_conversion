<?php 
    require('../../../adiha.php.scripts/components/include.file.v3.php');
    $form_name = 'form_add_roles';
    $user_login_id = get_sanitized_value($_GET['user_login_id'] ?? '');

    $layout_json = '[
                        {
                            id:             "a",
                            text:           "Roles",
                            width:          720,
                            header:         false,
                            collapse:       false,
                            fix_size:       [false,null]
                        }
                    ]';
    
    $deal_toolbar_json = '[
                        {id:"save", type:"button", img:"save.gif", imgdis:"save.gif", text:"Save", title:"Save"}
                    ]';
    $name_space = 'add_roles';
    
    //Creating Layout
    $layout_obj = new AdihaLayout();
    echo $layout_obj->init_layout('add_roles_layout', '', '1C', $layout_json, $name_space);
    
    //Attaching toolbar for tree
    $toolbar_user = 'add_roles_toolbar';
    echo $layout_obj->attach_toolbar_cell($toolbar_user, 'a');
    $toolbar_obj = new AdihaToolbar();
    echo $toolbar_obj->init_by_attach($toolbar_user, $name_space);
    echo $toolbar_obj->load_toolbar($deal_toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', 'add_roles.add_toolbar_click');
        
    $grid_name='grd_add_role';
    echo $layout_obj->attach_grid_cell($grid_name, 'a');
    
    $tbl_grd_name = 'AddApplicationUserSecurityRole';
    $grid_table_obj = new GridTable($tbl_grd_name);
    echo $grid_table_obj->init_grid_table($grid_name, $name_space);
    echo $grid_table_obj->set_widths('300,500,500');
    echo $grid_table_obj->set_search_filter(false, '#numeric_filter,#text_filter,#text_filter');
    echo $grid_table_obj->set_sorting_preference('int,str,str');
    echo $grid_table_obj->return_init();    
    echo $grid_table_obj->load_grid_data("EXEC spa_application_security_role @flag = 'p', @user_login_id='$user_login_id'"); 
    //echo $grid_table_obj->load_grid_data();
    echo $grid_table_obj->attach_event('', 'onRowSelect', 'grd_add_user_role_click');
    echo $grid_table_obj->enable_multi_select(); 
    echo $grid_table_obj->load_grid_functions();
    
    echo $layout_obj->close_layout();       
?>
<script type="text/javascript">
    add_roles.add_toolbar_click = function(id) {
        switch (id){
            case 'save':
                var user_login_id = '<?php echo $user_login_id;?>';
                var selected_row_id = add_roles.grd_add_role.getSelectedRowId();

                var selected_row_array = selected_row_id.split(',');
                var selected_item_id = '';
                    
                for(var i = 0; i < selected_row_array.length; i++) {
                   if (i == 0) {
                        selected_item_id = add_roles.grd_add_role.cells(selected_row_array[i], 0).getValue();
                    } else {
                        selected_item_id = selected_item_id + ',' + add_roles.grd_add_role.cells(selected_row_array[i], 0).getValue();
                    }
                }
                
                data = {"action": "spa_role_user",
                            "flag": "r",
                            "role_id": selected_item_id,
                            "user_type": "NULL",
                            "user_login_id": user_login_id
                        };
               
                
                adiha_post_data('confirm', data, '', '', 'add_roles.success_callback','','Are you sure you want to add the selected role?');
            break;
            case 'close':
                show_messagebox(id);
            break;
            default:
                show_messagebox(id);
            break;
        }
    }
    
    add_roles.success_callback = function(return_arr) {
        
       /*
        if (return_arr[0].errorcode == 'Success') {
            dhtmlx.message({
                text:return_arr[0].message,
                expire:1000
            });
        }else {
            dhtmlx.alert({
                title:"Error",
                type:"alert-error",
                text:return_arr[0].message
            });
        }
     */
        parent.maintain_users.refresh_all_grids('refresh');
        if (return_arr[0].errorcode == 'Success') {
            setTimeout('parent.new_win.close()', 1000);
        }
    }
        
    function grd_add_user_role_click() {
        var obj = add_roles.add_roles_layout.cells('a').getAttachedObject();
        var selected_row = obj.getSelectedRowId();
    }
        
    function success_callback(result) {
        alert('ddddddddd');
        console.log(result);
    }
    function close_user_roles_popup() {
            parent.user_roles_popup.hide();
    }
        
</script>