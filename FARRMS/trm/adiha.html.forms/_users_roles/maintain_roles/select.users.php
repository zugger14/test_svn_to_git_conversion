<?php
/**
* Select users screen
* @copyright Pioneer Solutions
*/
?>
<style type="text/css">
    html, body {
        width: 100%;
        height: 100%;
        margin: 0px;
        overflow: hidden;
    }
</style>
 <?php require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
<?php
   // include 'components/include.file.v3.php';
    $rights_users_add = 10111116;

    list (
        $has_rights_users_add
    ) = build_security_rights (
        $rights_users_add
    );
    
    $has_rights_users_add = ($has_rights_users_add == '1') ? 'false' : 'true';
    $popup = new AdihaPopup();
    $form_name = 'form_add_users';
    $default_role_id = (isset($_GET['default_role_id'])) ? $_GET['default_role_id'] : 'NULL';
    //JSON for Layout
    $layout_json = '[
                        {
                            id:             "a",
                            text:           "Add Users",
                            width:          720,
                            header:         false,
                            collapse:       false,
                            fix_size:       [false,null]
                        }
                    ]';
    
    $deal_toolbar_json = '[
                            {id:"save", type: "button", img:"save.gif", imgdis:"save_dis.gif", text:"Save", title:"Save", disabled:' . $has_rights_users_add . '}
                                     
                        ]';
    $name_space = 'Add_users';
    
    //Creating Layout
    $grd_add_user_role_layout = new AdihaLayout();
    echo $grd_add_user_role_layout->init_layout('add_users_layout', '', '1C', $layout_json, $name_space);
    
    //Attaching toolbar for tree
    $toolbar_user = 'add_user_toolbar';
    echo $grd_add_user_role_layout->attach_toolbar_cell($toolbar_user, 'a');
    $toolbar_user_search = new AdihaToolbar();
    echo $toolbar_user_search->init_by_attach($toolbar_user, $name_space);
    echo $toolbar_user_search->load_toolbar($deal_toolbar_json);
    echo $toolbar_user_search->attach_event('', 'onClick', 'add_toolbar_click');
    
    $grid_name='grd_add_user_role';
    echo $grd_add_user_role_layout->attach_grid_cell($grid_name, 'a');
    $grid_user_search = new GridTable('application_users');
    echo $grid_user_search->init_grid_table($grid_name, $name_space);
    echo $grid_user_search->set_widths('230,250,130');
    echo $grid_user_search->load_grid_functions();
    echo $grid_user_search->load_grid_data("EXEC spa_application_users @flag='f', @user_role=" . $default_role_id); 
    echo $grid_user_search->attach_event('', 'onRowSelect', 'grd_add_user_role_click');
    echo $grid_user_search->enable_multi_select(); 
    echo $grid_user_search->return_init();
    
    //$select_row = attach_event('', 'onRowSelect', 'grd_add_user_role_click');
    
    //Closing Layout
    echo $grd_add_user_role_layout->close_layout();       
?>
<script type="text/javascript">
    
    function add_toolbar_click (args) {
        switch(args) {
            case 'save':
                var role_id = '<?php echo $default_role_id; ?>';
                var selected_row_id = Add_users.grd_add_user_role.getSelectedRowId();
                  
                var selected_row_array = selected_row_id.split(',');
                var selected_item_id = '';
                
                for(var i = 0; i < selected_row_array.length; i++) {
                    if (i == 0) {
                        selected_item_id = Add_users.grd_add_user_role.cells(selected_row_array[i], 0).getValue();
                    } else {
                        selected_item_id = selected_item_id + ',' + Add_users.grd_add_user_role.cells(selected_row_array[i], 0).getValue();
                    }
                }
                    
                data = {"action": "spa_role_user",
                        "flag": "j",
                        "role_id": role_id,
                        "user_type": "NULL",
                        "user_login_id": selected_item_id
                    };
                adiha_post_data('return_json', data, '', '', 'Add_users.Success_callback', '', 'Success');
                
                break;
        }
    }
        
    Add_users.Success_callback = function(return_arr) {
        var return_data = JSON.parse(return_arr);
        if (return_data[0].errorcode == 'Success') {
            success_call(return_data[0].message);
            setTimeout('parent.new_win.close()', 1000);
        } else {
            success_call(return_data[0].message);
        }
    }
        
        
    function grd_add_user_role_click() {
        var obj = Add_users.add_users_layout.cells('a').getAttachedObject();
        var selected_row = obj.getSelectedRowId();
    }
            
</script>