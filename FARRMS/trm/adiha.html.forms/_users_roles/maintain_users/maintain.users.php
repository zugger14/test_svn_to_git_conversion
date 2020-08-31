<?php
/**
* Maintain users screen
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
        <?php require('../../../adiha.html.forms/_setup/manage_documents/manage.documents.button.php'); ?>
        <link rel="stylesheet" type="text/css" href="../../../main.menu/css/compiled/theme_styles.css" />
    </head>
    <?php
    
    global $db_pwd;
    $win_auth = "NULL";
    if($_SERVER['AUTH_TYPE'] != '') {
        $win_auth = "1";
    }   
    $form_namespace = 'maintain_users';
    $grid_name = "application_users";
    $application_function_id = 10111000;
    $grid_sp = "EXEC spa_application_users 'x'";
    $view_profile = get_sanitized_value($_GET['view_profile'] ?? '');
    
	unset($_COOKIE['client_date_format']);
    $user_login_id = '';
    if ($view_profile == 1) {
        $grid_sp .= ", '" . $_SESSION['app_user_name'] . "'";
        $user_login_id = $_SESSION['app_user_name'];
    }

    $rights_form_maintain_users = 10111000;
    
    $rights_grd_user_insert = 10111011;
    $rights_grd_user_update = 10111012;
    $rights_grd_user_change_pw = 10111013;
    $rights_grd_user_delete = 10111014;
    
    $rights_roles_insert = 10111016;
    $rights_roles_delete = 10111017;
    
    $rights_privileges_insert = 10111031;
    $rights_privileges_delete = 10111032;
   
    list (
        $has_rights_form_maintain_users, 
        $has_rights_grd_user_insert,
        $has_rights_grd_user_update,
        $has_rights_grd_user_change_pw,
        $has_rights_grd_user_delete,        
        $has_rights_roles_insert,
        $has_rights_roles_delete,        
        $has_rights_privileges_insert,
        $has_rights_privileges_delete
    ) = build_security_rights(
        $rights_form_maintain_users, 
        $rights_grd_user_insert,
        $rights_grd_user_update,
        $rights_grd_user_change_pw,
        $rights_grd_user_delete,        
        $rights_roles_insert,
        $rights_roles_delete,        
        $rights_privileges_insert,
        $rights_privileges_delete   
    );
    
    $form_sql = "EXEC spa_create_application_ui_json 'j', '10111000', 'MaintainUsers', '<Root><PSRecordset user_login_id=".'"0"'."></PSRecordset></Root>'";
    $form_data = readXMLURL2($form_sql);

    // Check login user is admin or not
    $admin_check_query = "EXEC ('SELECT dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) perm')";
    $admin_chk_rs = readXMLURL2($admin_check_query);
    $is_user_admin = $admin_chk_rs[0]['perm'];  

    //Check Login user is security admin or not
    $security_check_query = "EXEC ('SELECT ISNULL(dbo.FNASecurityAdminRoleCheck(dbo.FNADBUser()),0) perm')";
    $security_chk_rs = readXMLURL2($security_check_query);
    $is_security_admin = $security_chk_rs[0]['perm'];

    //Get default separator
    $default_separator_query = "EXEC spa_application_users @flag = 'y'";
    $default_separator = readXMLURL2($default_separator_query);
    $default_decimal_separator = $default_separator[0]['default_decimal_separator'];
    $default_group_separator = $default_separator[0]['default_group_separator'];

    $tab_data = array();
    $grid_definition = array();

    if (is_array($form_data) && sizeof($form_data) > 0) {
        foreach ($form_data as $data) {
            array_push($tab_data, $data['tab_json']);

            // Grid data collection
            $grid_json = array();
            $pre = strpos($data['grid_json'], '[');
            if ($pre === false) {
                $data['grid_json'] = '[' . $data['grid_json'] . ']';
            }

            $grid_json = json_decode($data['grid_json'], true);
            foreach ($grid_json as $grid) {
                $grid_def = "EXEC spa_adiha_grid 's', '" . $grid['grid_id'] . "'";
                $def = readXMLURL2($grid_def);

                $it = new RecursiveIteratorIterator(new RecursiveArrayIterator($def));
                $l = iterator_to_array($it, true);

                array_push($grid_definition, $l);
            }
        }
    }

    $grid_tab_data = 'tabs: [' . implode(",", $tab_data) . ']';
    $grid_definition_json = json_encode($grid_definition);

    $form_obj = new AdihaStandardForm($form_namespace, $rights_form_maintain_users);
    $form_obj->define_grid($grid_name, $grid_sp, 'g');
    $form_obj->define_custom_functions('save_application_users', '', 'delete_application_users', 'after_form_load');
    echo $form_obj->init_form("Users", "Setup User Form", $user_login_id, $farrms_product_id);
   
    $enable_privilege_insert = ($has_rights_privileges_insert) ? 'false' : 'true';
    $enable_privilege_delete = ($has_rights_privileges_delete) ? 'false' : 'true';
    $enable_role_insert = ($has_rights_roles_insert) ? 'false' : 'true';
    $enable_role_delete = ($has_rights_roles_delete) ? 'false' : 'true';

    $toolbar_json_array = array(
        array(
            'json' => '{id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif", title: "Refresh"},
                    {id:"t1", text:"Edit", img:"edit.gif", imgdis:"edit_dis.gif", items:[
                        {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add", disabled: ' . $enable_privilege_insert . '},
                        {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete", disabled: true}
                        ]},
                    {id: "t2", text: "Export", img: "export.gif", items: [
                                    {id:"excel",img:"excel.gif", imgdis:"excel_dis.gif", text:"Excel", title:"Excel"},
                                    {id:"pdf", img:"pdf.gif", text:"PDF", title:"PDF"}]},
                                    {id:"expand_collapse", text:"Expand/Collapse", img:"exp_col.gif", imgdis:"exp_col_dis.gif", enabled: 1},
                                    {id:"select_unselect", text:"Select/Unselect All", img:"select_unselect.gif", imgdis:"select_unselect_dis.gif", enabled: 1}
                                
                                
                    ',  
                    'on_click' => 'maintain_users.user_privillege_grid_toolbar_click',
                    'on_select' => "delete|$enable_privilege_delete"
        ),
        array(
            'json' => '{id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif", title: "Refresh"},
                        {id:"t1", text:"Edit", img:"edit.gif", imgdis:"edit_dis.gif", items:[
                        {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add", disabled: ' . $enable_role_insert . '},
                        {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete", disabled: true}
                                ]},
                    {id: "t2", text: "Export", img: "export.gif", items: [
                                    {id:"excel",img:"excel.gif", imgdis:"excel_dis.gif", text:"Excel", title:"Excel"},
                                    {id:"pdf", img:"pdf.gif", text:"PDF", title:"PDF"}]}',
            'on_click' => 'maintain_users.user_roles_grid_toolbar_click',
            'on_select' => "delete|$enable_role_delete"
        ),
        array(
            'json' => '',
            'on_click' => ''
        )
    );

    echo $form_obj->set_grid_menu_json($toolbar_json_array, 'true');
    echo $form_namespace . ".layout.cells('a').hideHeader();";
    if ($view_profile == 1) {
        echo $form_namespace . ".layout.cells('a').collapse();";
        echo $form_namespace . ".layout.cells('a').hideArrow();";    
    }
    
    echo $form_obj->close_form();
    
    if ($expire_date > 0) {
        $nodate = $expire_date;
    }
    $pwd_expire_date = date("m/d/Y", mktime(0, 0, 0, date("m"), date("d") + $nodate, date("Y"))); 

    ?>
    <body>
        <div id="context_menu" style="display: none;">
            <div id="change_password" text="Change Password"></div>
        </div>
    </body>

    <script type="text/javascript">
        var cloud_mode = '<?php echo $CLOUD_MODE; ?>';
        var client_dir = '<?php echo $_COOKIE["client_folder"]; ?>';
        var db_server_name = '<?php echo strpos($db_servername, "\\") > -1 ? str_replace("\\", "\\\\", $db_servername) : $db_servername; ?>';
        var view_profile = '<?php echo $view_profile; ?>';
        var token = '<?php echo isset($_COOKIE["_token"]) ? $_COOKIE["_token"] : ""; ?>';
      
        var php_script_loc_ajax = "<?php echo $app_php_script_loc; ?>";
        var popup_window;
        var grid_definition_json = <?php echo $grid_definition_json; ?>;
        var mode = '';
        var win_auth = "<?php echo $win_auth; ?>";
        var app_user_login_id = "<?php echo $user_login_id;?>";

        var has_rights_grd_user_insert = Boolean('<?php echo $has_rights_grd_user_insert; ?>');
        var has_rights_grd_user_update = Boolean('<?php echo $has_rights_grd_user_update; ?>');
        var has_rights_grd_user_delete = Boolean('<?php echo $has_rights_grd_user_delete; ?>');
        var has_rights_grd_user_change_pw = Boolean('<?php echo $has_rights_grd_user_change_pw; ?>');
        var has_rights_privileges_insert = Boolean('<?php echo $has_rights_privileges_insert; ?>');
        var has_rights_privileges_delete = Boolean('<?php echo $has_rights_privileges_delete; ?>');
        var has_rights_roles_insert = Boolean('<?php echo $has_rights_roles_insert; ?>');
        var has_rights_roles_delete = Boolean('<?php echo $has_rights_roles_delete; ?>');
       
        var no_of_must_contain_char = '<?php echo $no_of_must_contain_char; ?>';
        var number_must_contain = '<?php echo $number_must_contain; ?>';
        var must_contain_char = '<?php echo $must_contain_char; ?>';
        var last_letter_can_not = '<?php echo $last_letter_can_not; ?>';
        var alphabets_must_contain = '<?php echo $alphabets_must_contain; ?>';
        var must_contain_alphabets = '<?php echo $must_contain_alphabets; ?>';
       
        var min_char_login_name = '<?php echo $min_char_login_name; ?>';
        var max_char_login_name = '<?php echo $max_char_login_name; ?>';
        // var login_integers = '<?php echo $login_integers; ?>';
        // var no_of_login_integers = '<?php echo $no_of_login_integers; ?>';
        // var login_letters = '<?php echo $login_letters; ?>';
        // var no_of_login_letters = '<?php echo $no_of_login_letters; ?>';
        var login_sp_chars = "<?php echo $login_spChars; ?>";
        var expand_state = 0;
        var is_user_admin = '<?php echo $is_user_admin; ?>';
        var is_security_admin = '<?php echo $is_security_admin;?>';
        var category_id = 10000132;
        dhxWins = new dhtmlXWindows();

        var rights_grd_user_insert = "<?php echo $rights_grd_user_insert; ?>";
        var rights_grd_user_update = "<?php echo $rights_grd_user_update; ?>";
        var rights_grd_user_change_pw = "<?php echo $rights_grd_user_change_pw; ?>";
        var rights_grd_user_delete = "<?php echo $rights_grd_user_delete; ?>";
        var rights_roles_insert = "<?php echo $rights_roles_insert; ?>";
        var rights_roles_delete = "<?php echo $rights_roles_delete; ?>";
        var rights_privileges_insert = "<?php echo $rights_privileges_insert; ?>";
        var rights_privileges_delete = "<?php echo $rights_privileges_delete ; ?>";
        var default_decimal_separator = '<?php echo $default_decimal_separator;?>';
        var default_group_separator = '<?php echo $default_group_separator;?>';
        /*
         * Function that is called after form is completely loaded
         * @param {type} win object of the tab of the user.
         * @param {type} full_id Id of the tab.
         * @returns {Boolean}
         */
        $(function() { 
            maintain_users.tab_toolbar_click = function(id) {
                switch (id) {
                    case "documents":
                        var tab_id = maintain_users.tabbar.getActiveTab();
                        maintain_users.open_document(tab_id);
                        break;
                    case "save":
                        var tab_id = maintain_users.tabbar.getActiveTab();
                        if (cloud_mode == 1) {
                            maintain_users.before_save(tab_id);
                        } else {
                            maintain_users.save_application_users(tab_id);
                        }                      
                        break;
                    default:
                        break;
                }
            };

            maintain_users.grid.attachEvent('onRowSelect', function() {
                var main_menu = maintain_users.layout.cells('a').getAttachedMenu();
                if (has_rights_grd_user_delete) {
                    main_menu.setItemEnabled('delete');
                } else {
                    main_menu.setItemDisabled('delete');
                }
            });

            if (view_profile == '') {
                // Add new menu to manage read-only users
                maintain_users.menu.addNewSibling('t1', 'process', 'Process', false, 'action.gif', 'action_dis.gif');
                maintain_users.menu.addNewChild('process', 0, 'read_only_user', 'Set as read-only user', true, 'show.png', 'show_dis.png');
                maintain_users.menu.addNewChild('process', 1, 'read_write_user', 'Unset as read-only user', true, 'audit.gif', 'audit_dis.gif');
                maintain_users.menu.attachEvent('onClick', function(id, zoneId, cas) {
                    switch(id) {
                        case "read_only_user":
                            maintain_users.update_user_as_read_only("y");
                            break;
                        case "read_write_user":
                            maintain_users.update_user_as_read_only("n");
                            break;
                    }
                });

                // Enable 'Process' menu's child items only when a row is selected
                maintain_users.grid.attachEvent("onSelectStateChanged", function(id){
                    var selected_ids = maintain_users.grid.getSelectedId();
                    if (selected_ids) {
                        var count = selected_ids.indexOf(",") > -1 ? selected_ids.split(",").length : 1;
                        if (count < 1) {
                            maintain_users.menu.setItemDisabled('read_only_user');
                            maintain_users.menu.setItemDisabled('read_write_user');
                        } else {
                            maintain_users.menu.setItemEnabled('read_only_user');
                            maintain_users.menu.setItemEnabled('read_write_user');
                        }
                    } else {
                        maintain_users.menu.setItemDisabled('read_only_user');
                        maintain_users.menu.setItemDisabled('read_write_user');
                    }
                });
            }
        });

        maintain_users.after_form_load = function(win, full_id) {
            var user_login_id = maintain_users.tabbar.getActiveTab();
           
            var save_toolbar = maintain_users.tabbar.cells(full_id).getAttachedToolbar();
            save_toolbar.disableItem('save');
            //save_toolbar.setItemText('save', 'Update');
            //save_toolbar.setItemToolTip('save', 'Update');
            
            if (has_rights_grd_user_insert || has_rights_grd_user_update || js_user_name == user_login_id.replace("tab_", "")) {
               save_toolbar.enableItem('save');
            }
            
            var object_id = (full_id.indexOf("tab_") != -1) ? full_id.replace("tab_", "") : full_id;
            if (full_id.indexOf("tab_") != -1) {
                var user_row = maintain_users.grid.findCell(object_id,0,true);
                var application_users_id = maintain_users.grid.cells(user_row[0][0],2).getValue();
                add_manage_document_button(application_users_id, save_toolbar, true);
            }
            var tab_object = win.getAttachedObject();
            detail_tabs = tab_object.getAllTabs();
            
            $.each(detail_tabs, function(index, value) {

                layout_obj = tab_object.cells(value).getAttachedObject();

                if (index == 0) { 
                    attached_layout_obj = layout_obj.cells('a').getAttachedObject();
                    if (attached_layout_obj instanceof dhtmlXForm) {
                        if (full_id.indexOf("tab_") == -1) {
                            //hide password link in insert mode.
                            attached_layout_obj.hideItem('password_link');                                                         
                        } else {
                            //hide Login in update mode
                            attached_layout_obj.disableItem('user_login_id');
                            if (is_user_admin == 0 && is_security_admin == 0 && has_rights_grd_user_update != true) {
                                attached_layout_obj.disableItem('user_active');
                                attached_layout_obj.disableItem('lock_account');
                            }
                        }
                        if (cloud_mode == 1) {
                            attached_layout_obj.disableItem('user_login_id');
                            attached_layout_obj.setRequired('user_login_id', false);
                            attached_layout_obj.attachEvent("onBlur", function(name){
                                if (name == 'user_emal_add') {
                                    check_if_available();
                                }
                            });
                        }

                        var decimal_separator = attached_layout_obj.getCombo('decimal_separator')._checkedComboValue;
                        var group_separator = attached_layout_obj.getCombo('group_separator')._checkedComboValue;
                        if (decimal_separator == ',') {
                            attached_layout_obj.setItemValue('decimal_separator','1');
                        } else if (!decimal_separator) {
                            decimal_separator = (default_decimal_separator == ',')?'1':default_decimal_separator;
                            attached_layout_obj.setItemValue('decimal_separator',decimal_separator);
                        }

                        if (group_separator == ',') {
                            attached_layout_obj.setItemValue('group_separator','1');
                        } else if (!group_separator) {
                            group_separator = (default_group_separator == ',')?'1':default_group_separator;
                            attached_layout_obj.setItemValue('group_separator',group_separator);
                        }

                        var input_theme =  attached_layout_obj.getInput('theme_value_id');
                        if (view_profile == 1) {
                            var parent_input_theme_div = $(input_theme).closest('.dhxform_base');
                            // Same theme must be added in setup default application theme modal
                            parent_input_theme_div.append("<div id='config-tool' class = 'user_theme_div'>\n" +
                                "                    <div id='config-tool-options' >\n" +
                                "                        <div class='theme-config color-settings col-xs-12'>\n" +
                                "                            <ul id='skin-colors' class='clearfix'>\n" +
                                "                                <li>\n" +
                                "                                    <a class='skin-changer skin-changer-user' data-skin='theme-jomsomGreen' data-toggle='tooltip' title='Jomsom Green' alt='Jomsom Green' onClick=\"set_theme_value(attached_layout_obj,'jomsomGreen')\">\n" +
                                "                                        <div class='color-box' style = 'background-color: #00944A;'></div>\n" +
                                "                                    </a>\n" +
                                "                                </li>\n" +
                                "                                <li>\n" +
                                "                                    <a class='skin-changer skin-changer-user' data-skin='theme-jomsomBlue' data-toggle='tooltip' title='Jomsom Blue' onClick=\"set_theme_value(attached_layout_obj,'jomsomBlue')\">\n" +
                                "                                        <div class='color-box' style = 'background-color: #9fc6fd;'></div>\n" +
                                "                                    </a>\n" +
                                "                                </li>\n" +
                                "                                <li>\n" +
                                "                                    <a class='skin-changer skin-changer-user' data-skin='theme-jomsomBrown'  data-placement='bottom' data-toggle='tooltip' title='Jomsom Brown' onClick=\"set_theme_value(attached_layout_obj,'jomsomBrown')\">\n" +
                                "                                        <div class='color-box' style = 'background-color: #c5a490;'></div>\n" +
                                "                                    </a>\n" +
                                "                                </li>\n" +
                                "                                <li>\n" +
                                "                                    <a class='skin-changer skin-changer-user' data-skin='theme-jomsomPurple'  data-placement='bottom' data-toggle='tooltip' title='Jomsom Purple' onClick=\"set_theme_value(attached_layout_obj,'jomsomPurple')\">\n" +
                                "                                        <div class='color-box' style = 'background-color: #c3d0ff;'></div>\n" +
                                "                                    </a>\n" +
                                "                                </li>\n" +
                                "                            </ul>\n" +
                                "                        </div>\n" +
                                "                    </div>\n" +
                                "                </div>");
                            var theme_value_name = attached_layout_obj.getItemValue('theme_value_id');
                            if (theme_value_name && theme_value_name != '') {
                                $(".user_theme_div a[data-skin='theme-" + theme_value_name +"']").addClass("active");
                            }

                            $('#skin-colors .skin-changer-user').on('click', function() {
                                $('#skin-colors .skin-changer-user').removeClass('active');
                                $(this).addClass('active');
                            });

                            // Get timezone, region and menu type values
                            udata = {
                                'fields': {
                                    'user_time_zone': attached_layout_obj.getItemValue('timezone_id'),
                                    'user_region': attached_layout_obj.getItemValue('region_id'),
                                    'user_menu_type': attached_layout_obj.getItemValue('user_menu_type'),
                                    'user_theme': attached_layout_obj.getItemValue('user_theme'),
                                    'user_language': attached_layout_obj.getItemValue('user_language'),
                                    'decimal_separator': attached_layout_obj.getItemValue('decimal_separator'),
                                    'group_separator': attached_layout_obj.getItemValue('group_separator'),
                                }
                            };
                        } else { //Hide theme option while UI opened from setup user
                            $(input_theme).closest('fieldset').hide();
                        }

                    }
                }
                if (index == 1 || index == 2) {
                    //attached_layout_obj = layout_obj.cells('a').getAttachedObject();
                    var myMenu = layout_obj.cells('a').getAttachedMenu();
                    myMenu.forEachItem(function(itemId) {
                        if (full_id.indexOf("tab_") == -1) {
                            //disable menu items in insert mode.
                            myMenu.setItemDisabled(itemId);
                        }
                        if (index == 1) {
                            if (!has_rights_privileges_insert) {
                                myMenu.setItemDisabled('add');
                            } else {
                                myMenu.setItemEnabled('add');
                            }
                            if (!has_rights_privileges_delete) {
                                myMenu.setItemDisabled('delete');
                            } else {
                                myMenu.setItemEnabled('delete');
                            }
                        } else {
                            if (!has_rights_roles_insert) {
                                myMenu.setItemDisabled('add');
                            } else {
                                myMenu.setItemEnabled('add');
                            }
                            if (!has_rights_roles_delete) {
                                myMenu.setItemDisabled('delete');
                            } else {
                                myMenu.setItemEnabled('delete');
                            }
                        }
                    });
                    /* For Privelege grid attach dbclick event*/
                    if (index == 1) {
                        attached_layout_grid_obj = layout_obj.cells('a').getAttachedObject();
                        if (attached_layout_grid_obj instanceof dhtmlXGridObject) {
                            attached_layout_grid_obj.attachEvent("onRowDblClicked", function(rId,cInd){
                                maintain_users.user_privillege_grid_dbclick(rId,cInd);
                            });
                        }
                    }
                }
            });
            
        }

        set_theme_value = function test(obj,value) {
            obj.setItemValue('theme_value_id',value);
        }

        open_password_hyperlink = function(name, value) {
            var user_login_id = maintain_users.tabbar.getActiveTab();
           
            if (
                    (is_user_admin                              //if user is admin, allow
                    || has_rights_grd_user_change_pw            //if user is not admin, but has privilege, allow
                    || ('tab_' + js_user_name == user_login_id) //if user is changing his own password, allow (no extra privilege required)
                    ) 
                && user_login_id.indexOf("tab_") != -1) {
                change_pwd_html = '<a style="margin-top:0px; display:block;" href="#" id= "hyperlink_test" onclick="maintain_users.password_change(id)">' + get_locale_value('Change Password') + '</a>';
            } else {
                change_pwd_html = '<a style="margin-top:0px; display:block;" id= "hyperlink_test">' + get_locale_value('Change Password') + '</a>';
            }

            return change_pwd_html;
        }

        var privilege_window;
        maintain_users.password_change = function(id) {
            var user_login_id = maintain_users.tabbar.getActiveTab();
           
           user_login_id = (user_login_id.indexOf("tab_") != -1) ? user_login_id.replace("tab_", "") : user_login_id;

            var user_pwd_popup = new dhtmlXPopup();
            // user_pwd_popup.attachHTML('<iframe style="width:500px;height:400px;"src="maintain.pwd.php?&user_login_id=' + user_login_id + '"></iframe>');
            // user_pwd_popup.show(80, 80, 500, 500);
            unload_window();
            win_text = 'Change Password';
            param = 'maintain.pwd.php?&call_from=maintain_user&user_login_id=' + user_login_id
            width = 380;
            height = 360;
            if (!privilege_window) {
                privilege_window = new dhtmlXWindows();
            }

            new_win = privilege_window.createWindow('w9', 0, 0, width, height);
            new_win.centerOnScreen();
            new_win.setModal(true);
            new_win.setText(win_text);
            new_win.attachURL(param, false, true);
        }

        /**
         * [after_role_privilege_deleted Check privileges of current profile window after the role/privileges are deleted.]
         */
        maintain_users.after_role_privilege_deleted = function() {
            // Build an array of all privileges of profile window
            var all_ids = [
                            rights_grd_user_insert,
                            rights_grd_user_update,
                            rights_grd_user_change_pw,
                            rights_grd_user_delete,
                            rights_roles_insert,
                            rights_roles_delete,
                            rights_privileges_insert,
                            rights_privileges_delete
                        ];
            all_ids = all_ids.toString();

            var data_check = {
                'action': 'spa_get_permissions',
                'function_ids': all_ids
            }
            adiha_post_data('return_json', data_check, '', '', function(result) {
                var return_value = JSON.parse(result);
                // Get permissions in form of string Eg: "y,y,n,n,n"
                var permissions = return_value[0].permission_string;
                manage_menu_after_permission(permissions);
            });
        }

        /**
         * [manage_menu_after_permission Enable/Disable menu after the change in Role/Privileges.]
         * @param  {[String]} permissions [Privileges string returned from spa_get_permissions for requested operations.]
         */
        function manage_menu_after_permission(permissions) {
            var permissions = permissions.split(',');

            has_rights_grd_user_insert = (permissions[0] == 'y') ? true : false;
            has_rights_grd_user_update = permissions[1] == 'y' ? true : false;
            has_rights_grd_user_change_pw = permissions[2] == 'y' ? true : false;
            has_rights_grd_user_delete = permissions[3] == 'y' ? true : false;

            // For Role Tab
            has_rights_roles_insert = permissions[4] == 'y' ? true : false;
            has_rights_roles_delete = permissions[5] == 'y' ? true : false;
            // For Privilege Tab
            has_rights_privileges_insert = permissions[6] == 'y' ? true : false;
            has_rights_privileges_delete = permissions[7] == 'y' ? true : false;

            if (!has_rights_grd_user_insert) {
                maintain_users.menu.setItemDisabled('add');
            } else {
                maintain_users.menu.setItemEnabled('add');
            }

            if (!has_rights_grd_user_delete) {
                maintain_users.menu.setItemDisabled('delete');
            } else {
                maintain_users.menu.setItemEnabled('delete');
            }

            var top_tab_obj = maintain_users.layout.cells('b').getAttachedObject();
            var active_tab_id = top_tab_obj.getActiveTab();
            var tab_obj = maintain_users.pages[active_tab_id].getAttachedObject();
            tab_obj.forEachCell(function(cell_obj) {
                if (cell_obj.getText() == get_locale_value("General")) {
                    if (!has_rights_grd_user_update) {
                        maintain_users.pages[active_tab_id].getAttachedToolbar().disableItem('save');
                    } else {
                        maintain_users.pages[active_tab_id].getAttachedToolbar().enableItem('save');
                    }
                }

                if (cell_obj.getText() == get_locale_value("Role")) {
                    if (!has_rights_roles_insert) {
                        cell_obj.getAttachedObject().cells('a').getAttachedMenu().setItemDisabled('add');
                    } else {
                        cell_obj.getAttachedObject().cells('a').getAttachedMenu().setItemEnabled('add');
                    }
                    if (!has_rights_roles_delete) {
                        cell_obj.getAttachedObject().cells('a').getAttachedMenu().setItemDisabled('delete');
                    } else {
                        cell_obj.getAttachedObject().cells('a').getAttachedMenu().setItemEnabled('delete');
                    }
                }

                if (cell_obj.getText() == get_locale_value("Privilege")) {
                    if (!has_rights_privileges_insert) {
                        cell_obj.getAttachedObject().cells('a').getAttachedMenu().setItemDisabled('add');
                    } else {
                        cell_obj.getAttachedObject().cells('a').getAttachedMenu().setItemEnabled('add');
                    }
                    if (!has_rights_privileges_delete) {
                        cell_obj.getAttachedObject().cells('a').getAttachedMenu().setItemDisabled('delete');
                    } else {
                        cell_obj.getAttachedObject().cells('a').getAttachedMenu().setItemEnabled('delete');
                    }
                }
            });
            // After privilege change, the password hyperlink needs to be updated.
            open_password_hyperlink();
            // Refresh all grids after change in role/permission.
            maintain_users.refresh_grids("EXEC spa_application_users 'x'", maintain_users.grid, 'g');
        }

        /**
         * [Function to save application users]
         */
        maintain_users.save_application_users = function(tab_id) {	
            var user_login_id = null;
            var user_l_name = null;
            var send_to = null;
            var expire_date = '<?php echo $pwd_expire_date; ?>';  
            var field_label = null;
            var field_value = null;			
			
            var win = maintain_users.tabbar.cells(tab_id);
            //var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
            //object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(" ", ""));
            //var tab_obj = win.tabbar[object_id];
            var tab_obj = win.getAttachedObject();
            var detail_tabs = tab_obj.getAllTabs();
            var tabsCount = tab_obj.getNumberOfTabs();
            var form_status = true;
            var first_err_tab;
           // var form_xml = '<Root function_id="<?php echo $application_function_id; ?>"><FormXML ';
            var form_params = '';
            
            var form_validation_status = 0;
            var valid_login = true;
            var valid_email = true;
            var valid_separator = true;
            maintain_users["user_full_name" + tab_id] = '';
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
                        if (status == false) {
                            form_validation_status = 1;
                        }
                        data = attached_obj.getFormData();

                        for (var a in data) {
                            field_label = a;
                    
                            if (a != 'user_pwd' && a.indexOf('dhxId_') == -1) { //a.indexOf('dhxId_') is for excluding change password hyperlink
                                field_value = data[a];

                                if (a == 'user_login_id') {                                    
                                    field_value = field_value.trim();
                                    user_login_id = field_value;
                                    
                                    if (cloud_mode == 1) {
                                        valid_login = true;
                                    } else {
                                        valid_login = is_login_validation(user_login_id);
                                        
                                        if (user_login_id.length < min_char_login_name || user_login_id.length > max_char_login_name) {
                                            valid_login = false;
                                        }
                                    }
                                } else if (a == 'user_f_name') {
                                    maintain_users["user_full_name" + tab_id] += field_value;
                                                                       
                                } else if (a == 'user_m_name') {
                                    maintain_users["user_full_name" + tab_id] += ' ' + field_value;
                                } else if (a == 'user_l_name') {
                                    user_l_name = field_value;
                                    maintain_users["user_full_name" + tab_id] += ' ' + user_l_name;
                                } else if (a == 'user_emal_add') {
                                    send_to = field_value;
                                    
                                    valid_email = isEmail(send_to);
                                }   else if (a == 'decimal_separator') {
                                    var group_separator = data['group_separator'];
                                    if (field_value == group_separator) {
                                        valid_separator = false;
                                    }
                                }
                                
                                form_params += "&" + field_label + "=" + field_value;
                         
                            }
                        }
                    }
                });
            });

            if (cloud_mode == 1) {
                form_params += "&cloud_mode=" + cloud_mode + "&db_server_name=" + db_server_name + '&auth_token=' + token;
            }
            
            if (!form_status) {
                generate_error_message(first_err_tab);
            }
            if (form_validation_status) {
                return false;
            }
            
            if (!valid_login) {
                 var msg = " <div align='left' style='font-size: 90%' ><b><u>Login Rules:</u></b><br /><br />- Login should contain minimum " 
                                + min_char_login_name + " and maximum of " + max_char_login_name 
                                + " characters.<br />- Login should not contain special characters except (underscore).<br />- Login should not contain space.</div>" ;

                show_messagebox(msg);
                return false;
            }
            
            if (!valid_email) {
                show_messagebox('Please enter a valid email address.');
                return false;
            }

            if (!valid_separator) {
                var text = '<span style="color:red;">' + get_locale_value('Choose different decimal and group separator.') + '</span>';
                success_call(text, 'error');
                return false;
            }

            //console.log(maintain_users.tabbar.cells(tab_id).getAttachedToolbar());
            maintain_users.tabbar.cells(tab_id).getAttachedToolbar().disableItem('save');

            //password encryption in case of new user
            if (tab_id.indexOf("tab_") == -1) {
                var user_pwd = generatePassword();
                var company_code = '<?php echo $COMPANY_CODE; ?>';
                //## In case of cloud mode, use company code as user login id for password hashing
                var user_login_id = (cloud_mode == 1) ? company_code : user_login_id;

                var password_data = {"user_pwd": user_pwd,
                    "user_login_id": user_login_id
                };
                var url = php_script_loc_ajax + "encrypt_password.php";
                var data = $.param(password_data);
                $.ajax({
                    type: "POST",
                    dataType: "json",
                    url: url,
                    data: data,
                    success: function(data) {
                        field_value = data;
                        //since it is a call back function, vars should be set in the call back function itself
                        //otherwise, old value of field_value may be used if set outside call back function
                        form_params += "&user_pwd=" + field_value;
                        
                        var db_pwd = "<?php echo $db_pwd;?>";
                        // form_params += "&user_db_pwd=" + db_pwd;
                        
                        form_params += "&pwd_raw=" + user_pwd;
                        form_params += "&expire_date=" + expire_date;
                        form_params +=(win_auth == 1)?"&user_mode_create=1":"";
                        
                        var param = {
                            "flag": 'i',
                            "action": '[spa_application_users]'
                            
                        };
                        
                        param = $.param(param);
                        param = param + form_params;
                        param = deparam(param);   
                        
                        adiha_post_data('alert', param, '', '', 'save_insert_callback');
                    }
                });
                //end of password encryption
            } else {
                var param = {
                        "flag": 'u',
                        "action": '[spa_application_users]'
                        
                    };
                    
                    param = $.param(param);
                    param = param + form_params;
                    param = deparam(param);   
                    
                    adiha_post_data('alert', param, '', '', 'save_update_callback');
            }


        }
        
        function deparam(querystring) {
            // remove any preceding url and split
            querystring = querystring.substring(querystring.indexOf('?') + 1).split('&');
            var params = {}, pair, d = decodeURIComponent, i;
            // march and parse
            for (i = querystring.length; i > 0;) {
                pair = querystring[--i].split('=');
                params[d(pair[0])] = d(pair[1]);
            }
            
            return params;
        };

        function save_insert_callback(result) {		
            if (view_profile == 1) {
                parent.window.location.reload();
            }
            var user_login_id = maintain_users.tabbar.getActiveTab();
            if (has_rights_grd_user_insert || has_rights_grd_user_update || js_user_name == user_login_id.replace("tab_", "")) {
                 maintain_users.tabbar.cells(maintain_users.tabbar.getActiveTab()).getAttachedToolbar().enableItem('save');
            }
            if (result[0].errorcode == 'Success') {
                var active_tab_id = maintain_users.tabbar.getActiveTab();
                // ## Login ID is returned from db for tab id (result[0].recommendation)
                var tab_id = 'tab_' + result[0].recommendation;
                var full_name = maintain_users["user_full_name" + active_tab_id];
                maintain_users.create_tab_custom(tab_id, full_name);
                maintain_users.tabbar.tabs(active_tab_id).close(true);
                maintain_users.refresh_grid();
            }
        }
        maintain_users.create_tab_custom = function(full_id, text, grid_obj, acc_id) {
            if (!maintain_users.pages[full_id]) {
                maintain_users.tabbar.addTab(full_id, text, null, null, true, true);
                //using window instead of tab
                var win = maintain_users.tabbar.cells(full_id);
                var toolbar = win.attachToolbar();
                toolbar.setIconsPath(js_image_path+'dhxtoolbar_web/');
                toolbar.attachEvent("onClick", maintain_users.tab_toolbar_click);
                toolbar.loadStruct([{id: "save", type: "button", img: "save.gif", text: "Save", title: "Save"}]);
                maintain_users.tabbar.cells(full_id).setActive();
                maintain_users.tabbar.cells(full_id).setText(text);
                win.progressOn();
                maintain_users.set_tab_data(win, full_id);
                maintain_users.pages[full_id] = win;
            }
            else {
                maintain_users.tabbar.cells(full_id).setActive();
            }


        };

        function save_update_callback(result) {
            if (view_profile == 1 ) {
                var tab_id = maintain_users.tabbar.getActiveTab();
                var win = maintain_users.tabbar.cells(tab_id);
                var tab_obj = win.getAttachedObject();
                var detail_tabs = tab_obj.getAllTabs();
                var is_field_changed = 0;

                $.each(detail_tabs, function(index, value) {
                    layout_obj = tab_obj.cells(value).getAttachedObject();
                    layout_obj.forEachItem(function(cell) {
                        if (index == 0) {
                            attached_obj = cell.getAttachedObject();
                            if (attached_obj instanceof dhtmlXForm) {
                                var user_time_zone = attached_obj.getItemValue('timezone_id');
                                var user_region = attached_obj.getItemValue('region_id');
                                var user_menu_type =  attached_obj.getItemValue('menu_type_role_id');
                                var user_theme = attached_obj.getItemValue('theme_value_id');
                                var user_language = attached_obj.getItemValue('language');
                                var decimal_separator = attached_obj.getItemValue('decimal_separator');
                                var group_separator = attached_obj.getItemValue('group_separator');

                                if ((udata.fields.user_time_zone !== user_time_zone) || (udata.fields.user_region !== user_region) || (udata.fields.user_menu_type !== user_menu_type) || (udata.fields.user_theme !== user_theme)
                                    || (udata.fields.user_language !== user_language) || (udata.fields.decimal_separator !== decimal_separator) || (udata.fields.group_separator !== group_separator)) {
                                    is_field_changed = 1;
                                }
                            }
                        }
                    });
                });

                if (is_field_changed == 1) {
                    $.ajax({
                        type: "POST",
                        dataType: "json",
                        url: 'unset.date.session.php',
                        data: '',
                        success: function(data) {
                            parent.window.location.reload();
                        }
                    });
                    return;
                }
            }

			var user_login_id = maintain_users.tabbar.getActiveTab();
            if (has_rights_grd_user_insert || has_rights_grd_user_update || js_user_name == user_login_id.replace("tab_", "")) {
                maintain_users.tabbar.cells(maintain_users.tabbar.getActiveTab()).getAttachedToolbar().enableItem('save');
            }
            var active_tab_id = maintain_users.tabbar.getActiveTab();
            if (result[0].errorcode == 'Success') {
                var full_name = maintain_users["user_full_name" + active_tab_id];
                maintain_users.tabbar.tabs(active_tab_id).setText(full_name);
                maintain_users.refresh_grid();
            }
            
            /*
            After changing the date format from setup user page, the value of session variable 'client_date_format'
            should be cleared, otherwise it contains its old value until the application is logged out. So to avoid
            logging out after changing the date format, simply the session variable is unset from the page unset.date.session.
            */
            $.ajax({
                   type: "POST",
                   dataType: "json",
                   url: 'unset.date.session.php',
                   data: '',
                   success: function(data) {
                     //do nothing
                   }
               });
        }

        /**
         * [Function to email password to new application users]
         */
     /*   function email_pwd(user_pwd, user_l_name, send_to) {
            var email_params = '<Root><PSRecordset name="%26lt%3BTRM_USER_NAME%26gt%3B" value="' + user_l_name + '" /><PSRecordset name="%26lt%3BTRM_PASSWORD%26gt%3B" value="' + user_pwd + '" /></Root>';
            var email_data = {"action": "spa_email_notes",
                "flag": 'i',
                "template_params": email_params,
                "email_module_type_value_id": 17808,
                "send_to": send_to,
                "send_status": 'n',
                "active_flag": 'y'
            };

            return adiha_post_data("alert", email_data, "", "", "");
        }
*/
        /**
         * 
        */

        maintain_users.user_privillege_grid_toolbar_click = function(id) {
            var user_login_id = maintain_users.tabbar.getActiveTab();
            var user_login_id = (user_login_id.indexOf("tab_") != -1) ? user_login_id.replace("tab_", "") : user_login_id;

            switch (id) {
                case 'add':

//                    var user_roles_popup = new dhtmlXPopup();
//                    user_roles_popup.attachHTML('<iframe style="width:800px;height:600px;"src="select.privileges.php?flag=i&user_login_id=' + user_login_id + '"></iframe>');
//                    user_roles_popup.show(0,0,50,50); 
                 //   unload_window();
//                    
//                    win_text = 'Privilege Mapping';
//                    param = 'select.privileges.php?flag=i&user_login_id=' + user_login_id;
//                    width = 700;
//                    height = 500;
//                    if (!popup_window) {
//                        popup_window = new dhtmlXWindows();
//                    }
//
//                    var new_win = popup_window.createWindow('w1', 0, 0, width, height);
//                    //new_win.centerOnScreen();
//                    new_win.setModal(true);
//                    new_win.setText(win_text);
//                    new_win.maximize();
//                    new_win.attachURL(param, false, true);

                    maintain_users.open_privilege_window(user_login_id,'i','');
                    break;

                case 'password':
                    var user_roles_popup = new dhtmlXPopup();
                    user_roles_popup.attachHTML('<iframe style="width:500px;height:400px;"src="maintain.pwd.php?&user_login_id=' + user_login_id + '"></iframe>');
                    user_roles_popup.show(80, 80, 80, 50);
                    break;
                case 'refresh':     
                    maintain_users.refresh_all_grids('refresh');
                    break;
                case 'delete':
                    var t_layout = maintain_users.layout.cells('b').getAttachedObject();
                    t_layout.forEachTab(function(tab) {
                        var is_active = tab.isActive();
                        if (is_active == true) {
                            var tab_obj = tab.getAttachedObject();
                            tab_obj.forEachCell(function(cell) {
                                var text = cell.getText();
                                if (text == get_locale_value('Privilege')) {
                                    var obj = cell.getAttachedObject();

                                    obj.forEachItem(function(aaa) {
                                        var ttt = aaa.getAttachedObject();
                                        var selectedId = ttt.getSelectedRowId();
                                        var selected_row_array = selectedId.split(',');
                                        var selected_item_id = '';
                                        var selected_item_id_delete = '';
                                        var is_role_privilege = 0;
                                        var rm_view_id = [];
                                        
                                        for(var i = 0; i < selected_row_array.length; i++) {
                                              if (ttt.cells(selected_row_array[i],3).getValue() == '') {
                                                  //Collects only user privileges.
                                                  selected_item_to_delete =  ttt.cells(selected_row_array[i],1).getValue();
                                                  
                                                  //if row is for report manager views
                                                  if(ttt.cells(selected_row_array[i],2).getValue() == 10201633) {
                                                    if(ttt.cells(selected_row_array[i],0).getValue().indexOf('[') > -1) {
                                                        //alert(ttt.cells(selected_row_array[i],0).getValue());
                                                        rm_view_id.push(ttt.cells(selected_row_array[i],0).getValue().split('[')[1].split(']')[0]);
                                                    }
                                                     
                                                  }
                                                                                                    
                                                   if (selected_item_to_delete != '') {
                                                       if (i == 0) {
                                                            selected_item_id =  selected_item_to_delete;
                                                                                            
                                                       } else {
                                                            selected_item_id = selected_item_id + ',' + selected_item_to_delete;
                                                      }
                                                  }
                                              } else {
                                                  //if row is for report manager views
                                                  if(ttt.cells(selected_row_array[i],2).getValue() == 10201633) {
                                                    //alert(ttt.cells(selected_row_array[i],0).getValue());
                                                    //rm_view_id.push(ttt.cells(selected_row_array[i],0).getValue().split('[')[1].split(']')[0]); 
                                                  }
                                                 is_role_privilege =  1;
                                              }

                                        }
                                        
                                      selected_item_id = selected_item_id.replace(/\,\,/g,','); 
                                      if (selected_item_id.charAt(0) == ',' ) {
                                        selected_item_id = selected_item_id.substring(1);
                                      } 
                                      if (selected_item_id.charAt(selected_item_id.length-1) == ',') {
                                            selected_item_id = selected_item_id.substr(0, selected_item_id.length - 1);  
                                      }
                                    
                                    if (is_role_privilege == 1) {
                                        if (selecte_item_id == '') {
                                            show_messagebox("Privileges assigned from roles cannot be deleted.");
                                        } else {
                                            confirm_messagebox("Privileges assigned from roles cannot be deleted. Are you sure you want to delete the privileges assigned from user?", function() {
                                                var data = {
                                                    "action": "spa_AccessRights",
                                                    "flag": "d",
                                                    "functional_user_id": selected_item_id,
                                                    'login_id': user_login_id,
                                                    'role_user_flag': 'u',
                                                    'rm_view_id': rm_view_id.join(',')
                                                };
                                                    
                                                adiha_post_data("alert", data, "", "", "role_privilege_deleted", "", "");                                                        
                                            });
                                        }
                                    } else if (selected_item_id == ''){
                                        show_messagebox('Please select privilege to delete.');
                                        return;
                                    } else {
                                        confirm_messagebox("Are you sure you want to delete?", function() {
                                            var data = {
                                                "action": "spa_AccessRights",
                                                "flag": "d",
                                                "functional_user_id": selected_item_id,
                                                'login_id': user_login_id,
                                                'role_user_flag': 'u',
                                                'rm_view_id': rm_view_id.join(',')
                                            };
                                            //console.log(rm_view_id);
                                            adiha_post_data("alert", data, "", "", "role_privilege_deleted", "", "");
                                       });
                                    } 
                                        //ttt.deleteSelectedRows();
                                    });
                                }
                            });
                        }

                    });

                    break;
                case "excel":
                    var t_layout = maintain_users.layout.cells('b').getAttachedObject();
                    t_layout.forEachTab(function(tab){
                        var is_active = tab.isActive();
                        if (is_active == true) {
                            var tab_obj = tab.getAttachedObject();
                                tab_obj.forEachCell(function(cell){
                                var text = cell.getText();
                                if (text == get_locale_value('Privilege')) {
                                       var j = 1;
                                        var obj = cell.getAttachedObject();
                                        obj.forEachItem(function(bbb) {
                                        if (j == 1){
                                          var xyz = bbb.getAttachedObject();
                                          xyz.toExcel(php_script_loc_ajax + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                                        }
                                        j++;
                                       });
                                   } 
                                 
                            });
                        }
                    }); 
                    break;
                case "pdf":
                    var t_layout = maintain_users.layout.cells('b').getAttachedObject();
                    t_layout.forEachTab(function(tab){
                    var is_active = tab.isActive();
                    if (is_active == true) {
                        var tab_obj = tab.getAttachedObject();
                            tab_obj.forEachCell(function(cell){
                            var text = cell.getText();
                          
                            if (text == get_locale_value('Privilege')) {
                                   var j = 1;
                                    var obj = cell.getAttachedObject();
                                    obj.forEachItem(function(bbb) {
                                    if (j ==1){ 
                                      var xyz = bbb.getAttachedObject();
                                      xyz.toPDF(php_script_loc_ajax + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                                    }
                                      j++;
                                   });
                               } 
                             
                        });
                    }
                }); 
                break;
                case "expand_collapse":
                    var t_layout = maintain_users.layout.cells('b').getAttachedObject();                  
                    t_layout.forEachTab(function(tab){
                        var is_active = tab.isActive(); 
                        if (is_active == true) {
                            var tab_obj = tab.getAttachedObject();
                            tab_obj.forEachCell(function(cell){
                                var text = cell.getText();
                                if (text == get_locale_value('Privilege')) {
                                    var obj_privilege_exp_col = cell.getAttachedObject();
                                    obj_privilege_exp_col.forEachItem(function(outer_obj_exp_col) {
                                        var inner_obj_exp_col = outer_obj_exp_col.getAttachedObject();                               
                                        if (expand_state == 0) {
                                            inner_obj_exp_col.expandAll();
                                            expand_state = 1;
                                        } else {
                                            inner_obj_exp_col.collapseAll();
                                            expand_state = 0;
                                        }
                                    });
                                }    
                           });
                       }
                    });          
                break;
                case "select_unselect":
                    var t_layout = maintain_users.layout.cells('b').getAttachedObject();                  
                    t_layout.forEachTab(function(tab){
                        var is_active = tab.isActive(); 
                        if (is_active == true) {
                            var tab_obj = tab.getAttachedObject();
                            tab_obj.forEachCell(function(cell){
                                var text = cell.getText();
                                if (text == get_locale_value('Privilege')) {


                                    var obj_privilege_exp_col = cell.getAttachedObject();
                                    obj_privilege_exp_col.forEachItem(function(outer_obj_exp_col) {
                                        var menu_object = outer_obj_exp_col.getAttachedMenu();
                                        var inner_obj_exp_col = outer_obj_exp_col.getAttachedObject();                               
                                        var selected_id = inner_obj_exp_col.getSelectedRowId();
                                        
                                        if (selected_id == null) {
                                            inner_obj_exp_col.expandAll();
                                            var ids = inner_obj_exp_col.getAllRowIds();
                                            
                                            for (var id in ids) {
                                               inner_obj_exp_col.selectRow(id, true, true, false);
                                            }

                                            if (has_rights_privileges_delete) {
                                                menu_object.setItemEnabled('delete')
                                            } else {
                                                menu_object.setItemDisabled('delete')
                                            }
                                            
                                        } else {
                                            inner_obj_exp_col.clearSelection();
                                            menu_object.setItemDisabled('delete')
                                        }
                                        
                                    });
                                }    
                           });
                       }
                    });
                    break;
                default:
                    show_messagebox(id);
                    break;
            }
        }

        /**
         * [role_privilege_deleted Called right after role or privileges is deleted.]
         * @param  {[Array]} result [Response after deletion.]
         */
        function role_privilege_deleted(result) {
            // Recheck privileges and Enable/Disable menu items after role/privileges deleted.
            maintain_users.after_role_privilege_deleted();
            maintain_users.refresh_all_grids(result);
        }

        maintain_users.user_roles_grid_toolbar_click = function(id) {
            var user_login_id = maintain_users.tabbar.getActiveTab();
            var user_login_id = (user_login_id.indexOf("tab_") != -1) ? user_login_id.replace("tab_", "") : user_login_id;

            switch (id) {
                case 'add':
                    unload_window();
                    win_text = 'Assign Roles';
                    param = 'select.roles.php?&user_login_id=' + user_login_id
                    width = 700;
                    height = 500;
                    if (!privilege_window) {
                        privilege_window = new dhtmlXWindows();
                    }

                    new_win = privilege_window.createWindow('w1', 0, 0, width, height);
                    new_win.centerOnScreen();
                    new_win.setModal(true);
                    new_win.setText(win_text);
                    new_win.maximize();
                    new_win.attachURL(param, false, true); 
                    
                    new_win.attachEvent("onClose", function(win){                         
                        var t_layout = maintain_users.layout.cells('b').getAttachedObject();
                        t_layout.forEachTab(function(tab){
                        var is_active = tab.isActive();
                        if (is_active == true) {
                            var tab_obj = tab.getAttachedObject();
                            tab_obj.forEachCell(function(cell){
                                var text = cell.getText();
                                
                               
                                if (text == get_locale_value('Role')) {
                                    var obj = cell.getAttachedObject();
                                    obj.forEachItem(function(aaa) {
                                            var ttt = aaa.getAttachedObject();
                                            var sql_param = {
                                                
                                                "sql":"EXEC spa_application_security_role @flag = g, @user_login_id ='" + user_login_id + "'",
                                                "grid_type":"g"
                                            };
                                            sql_param = $.param(sql_param);
                                            var sql_url = js_data_collector_url + "&" + sql_param;
                                            ttt.clearAndLoad(sql_url, function(){
                                                var menu_object = aaa.getAttachedMenu();
                                                //menu_object.setItemDisabled("delete");
                                            });
                                    });        
                                }
                            });
                        }
                    });
                    return true;
                })
                    
                    
                    break;
                case 'delete':     
                    var role_id = maintain_users.get_role_id();
                    data = {"action": "spa_role_user",
                        "flag": "d",
                        "role_id": role_id,
                        "user_type": "NULL",
                        "user_login_id": user_login_id
                    };
                    adiha_post_data("confirm", data, "", "", "role_privilege_deleted", "", "Are you sure you want to delete?");
                    break;
                case 'refresh':     
                    maintain_users.refresh_all_grids('refresh');
                    break;
                case "excel":
                    var t_layout = maintain_users.layout.cells('b').getAttachedObject();
                    t_layout.forEachTab(function(tab){
                    var is_active = tab.isActive();
                    if (is_active == true) {
                        var tab_obj = tab.getAttachedObject();
                            tab_obj.forEachCell(function(cell){
                                var text = cell.getText();
                                if (text == get_locale_value('Role')) {
                                    var j = 1;
                                    var obj = cell.getAttachedObject();
                                    obj.forEachItem(function(bbb) {
                                        if (j == 1){
                                          var xyz = bbb.getAttachedObject();
                                          xyz.toExcel(php_script_loc_ajax + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                                        }
                                        j++;
                                    });
                               } 
                             
                            });
                        }
                }); 
                    break;
                case "pdf":
                    var t_layout = maintain_users.layout.cells('b').getAttachedObject();
                    t_layout.forEachTab(function(tab){
                        var is_active = tab.isActive();
                        if (is_active == true) {
                            var tab_obj = tab.getAttachedObject();
                            tab_obj.forEachCell(function(cell){
                                var text = cell.getText();
                          
                                if (text == get_locale_value('Role')) {
                                    var j = 1;
                                    var obj = cell.getAttachedObject();
                                    obj.forEachItem(function(bbb) {
                                        if (j ==1){ 
                                          var xyz = bbb.getAttachedObject();
                                          xyz.toPDF(php_script_loc_ajax + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                                        }
                                        j++;
                                    });
                               } 
                             
                            });
                        }
                }); 
                    break;
                default:
                    show_messagebox(id);
                    break;
            }
        }
        
		
        
        
        maintain_users.open_privilege_window = function(user_login_id,mode,function_id) {
            unload_window();
            if (!privilege_window) {
                privilege_window = new dhtmlXWindows();
            }
            privilege_win = privilege_window.createWindow('w1', 0, 0, 800, 600);
            var text = "Assign Privilege";
            privilege_win.setText(text);
            privilege_win.maximize();
            privilege_win.setModal(true);
            var url = '../maintain_privileges/select.privileges.php?flag=' + mode + '&call_from=u&user_login_id=' + user_login_id + '&function_id=' + function_id;
            privilege_win.attachURL(url, false, true);
            
            privilege_win.attachEvent("onClose", function(win){                         
            var t_layout = maintain_users.layout.cells('b').getAttachedObject();
                t_layout.forEachTab(function(tab){
                    var is_active = tab.isActive();
                    if (is_active == true) {
                        var tab_obj = tab.getAttachedObject();
                        tab_obj.forEachCell(function(cell){
                            var text = cell.getText();
                            if (text == get_locale_value('Privilege')) {
                                var obj = cell.getAttachedObject();
                                obj.forEachItem(function(aaa) {
                                        var ttt = aaa.getAttachedObject();
                                        var sql_param = {
                                            "sql":"Exec spa_AccessRights @flag = n, @product_id = " + <?php echo $farrms_product_id; ?>  + ", @login_id ='" + user_login_id + "'",
                                            "grid_type":"tg",
                                            "grouping_column": "function_name2,function_name3,function_name4,function_name5,function_name6,function_name7"
                                        };
                                        sql_param = $.param(sql_param);
                                        var sql_url = js_data_collector_url + "&" + sql_param;
                                        ttt.clearAndLoad(sql_url, function(){
                                            var menu_object = aaa.getAttachedMenu();
                                            menu_object.setItemDisabled("delete");
                                        });
                                });        
                            }
                        });
                    }
                });
                return true;
            })
        }
            
        function unload_window() {
            if (privilege_window != null && privilege_window.unload != null) {
                privilege_window.unload();
                privilege_window = w1 = null;
            }
        }
        maintain_users.refresh_all_grids =function(result){
            if (result[0].errorcode == 'Success' || result == 'refresh') {
                var tab_id = maintain_users.tabbar.getActiveTab();
                var user_login_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
                //alert(tab_id); 
                var tab_object =  maintain_users.tabbar.tabs(tab_id).getAttachedObject();
                detail_tabs = tab_object.getAllTabs();

                $.each(detail_tabs, function(index, value) {
                    layout_obj = tab_object.cells(value).getAttachedObject();
                    attached_layout_obj = layout_obj.cells('a').getAttachedObject();
                    if (attached_layout_obj instanceof dhtmlXGridObject) {
                        if(index==1){
                            sql_stmt = grid_definition_json[1]["sql_stmt"];
                            grid_type = grid_definition_json[1]["grid_type"];
                            var grid_name = grid_definition_json[1]["grid_name"];
                            var grouping_column = grid_definition_json[1]["grouping_column"];
                            //var grid_index = "grid_" + counterparty_id + "_" + grid_name;
                   //alert(sql_stmt);
                            attached_menu_obj = layout_obj.cells('a').getAttachedMenu();
                            attached_menu_obj.setItemDisabled('delete')
                    maintain_users.refresh_grids(sql_stmt,attached_layout_obj,grid_type, user_login_id,grouping_column);
                        }
                        else if(index==2){
                                sql_stmt = grid_definition_json[2]["sql_stmt"];
                            grid_type = grid_definition_json[2]["grid_type"];
                            var grid_name = grid_definition_json[2]["grid_name"];
                            attached_menu_obj = layout_obj.cells('a').getAttachedMenu();
                            attached_menu_obj.setItemDisabled('delete')
                            //var grid_index = "grid_" + counterparty_id + "_" + grid_name;
                   //alert(sql_stmt);
                    maintain_users.refresh_grids(sql_stmt,attached_layout_obj,grid_type, user_login_id,'');
                }
                    }
    //                if (index == 0) {
    //                    attached_layout_obj = layout_obj.cells('a').getAttachedObject();
    //                    if (attached_layout_obj instanceof dhtmlXForm) {
    //                        if (full_id.indexOf("tab_") == -1) {
    //                            //hide password link in insert mode.
    //                            attached_layout_obj.hideItem('password_link'); 
    //                        }
    //                    }
    //                }
    //                if (index == 1 || index == 2) {
    //                    //attached_layout_obj = layout_obj.cells('a').getAttachedObject();
    //                    var myMenu = layout_obj.cells('a').getAttachedMenu();
    //                    myMenu.forEachItem(function(itemId) {
    //                        if (full_id.indexOf("tab_") == -1) {
    //                            //disable menu items in insert mode.
    //                            myMenu.setItemDisabled(itemId);
    //                        }
    //                    });
    //
    //                }
                });
            }
        }
        /**
         * [refresh_grids Refresh Grid]
         * @param  {[type]} sql_stmt        [Grid Population query]
         * @param  {[type]} grid_obj        [Grid Object]
         * @param  {[type]} grid_type       [Grid Type]
         * @param  {[type]} counterparty_id [Counterparty ID]
         */
        maintain_users.refresh_grids = function(sql_stmt, grid_obj, grid_type, login_id,grouping_column) {
            if (sql_stmt.indexOf('<ID>') != -1) {
                var stmt = sql_stmt.replace('<ID>', login_id);
            } else {
                var stmt = sql_stmt;
            }
            
            if (stmt.indexOf('<FARRMS_PRODUCT_ID>') != -1) {
                var stmt = stmt.replace('<FARRMS_PRODUCT_ID>', <?php echo $farrms_product_id; ?>);
            }
                        
            if(grid_type=='t') {
                var sql_param = {
                    "sql": stmt,
                    "grid_type": 'tg',
                    "grouping_column":grouping_column
                };
            }
            else {
                var sql_param = {
                    "sql": stmt,
                    "grid_type": grid_type
                };
            }
            sql_param = $.param(sql_param);
            var sql_url = js_data_collector_url + "&" + sql_param;
            grid_obj.clearAll();
            grid_obj.load(sql_url);
        }
        
        maintain_users.delete_application_users = function() {
           var select_id = maintain_users.grid.getSelectedRowId();
            var count = select_id.indexOf(",") > -1 ? select_id.split(",").length : 1;
            select_id = select_id.indexOf(",") > -1 ? select_id.split(",") : [select_id];
            var application_users_id = '';
            var get_application_users_id;
            if (select_id != null) {
                confirm_messagebox("Are you sure you want to delete?", function() {
                    for ( var i = 0; i < count; i++) {
                        get_application_users_id = maintain_users.grid.cells(select_id[i], 2).getValue();
                        application_users_id +=  get_application_users_id + ',';
                    }
                    application_users_id = application_users_id.slice(0, -1);
                    data = {
                        "action": "spa_application_users", 
                        "del_application_users_id": application_users_id, 
                        "user_mode_create": win_auth,
                        "flag": "d",
                        "cloud_mode": cloud_mode,
                        "auth_token": token
                    }
                    result = adiha_post_data("return_array", data, "", "","maintain_users.post_delete_callback");
                });
            } 
        }
        
        
        /**
         * [Function to get role id of application users]
         */
        maintain_users.get_role_id = function() {
            var tab_id = maintain_users.tabbar.getActiveTab();
            var win = maintain_users.tabbar.cells(tab_id);
            //var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
            //object_id = ord(object_id.replace(" ", ""));
            //var tab_obj = win.tabbar[object_id];
            var tab_obj = win.getAttachedObject();
            var detail_tabs = tab_obj.getAllTabs();
            var detail_id = '';

            $.each(detail_tabs, function(index, value) {
                var layout_obj = tab_obj.cells(value).getAttachedObject();

                layout_obj.forEachItem(function(cell) {
                    var attached_obj = cell.getAttachedObject();
                    if (attached_obj instanceof dhtmlXGridObject) {
                        var selected_row = attached_obj.getSelectedRowId();
                        
                        if (selected_row != null) {
                            //  show_messagebox('Please select a row from grid!');
                        var array_selected_row = selected_row.split(',');
                        array_selected_row.forEach(function(row){
                             if(isNaN(attached_obj.cells(row, 0).getValue()) == false){
                                detail_id += attached_obj.cells(row, 0).getValue() + ",";
                            }
                        }) 
                            
                        }
                    }
                });
            });
            return detail_id.substring(0, detail_id.length - 1);
        }
        /**
         *Function to generate random password
         */
        function generatePassword() {
            var length = 8,
                    charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789",
                    retVal = "";
            for (var i = 0, n = charset.length; i < length; ++i) {
                retVal += charset.charAt(Math.floor(Math.random() * n));
            }
            return retVal;
        }
        
        ////Validation for special characters such as "-", "_" and "." (hyphen, dot and apostrophe.)//////
        function is_login_validation(val) {
            var arr = new Array(login_sp_chars);
            
            if (val.indexOf(' ') >= 0) {               
                return 0;
            }
            
            return(isAlphaSpecialchar(unescape(val), arr));
        }
        
        /**
         
         * [Function to get validation message]
         */
        function get_message(message_code) {
            switch (message_code) {
                case 'VALIDATE_DATA':
                    return 'Please select data you want to delete.';
                case 'DELETE_CONFIRM':
                    return 'Are you sure you want to delete the selected data?';
            }
        }


        /*
         * Open document
         * @param {type} tab_id
         * @returns {undefined}         */
        maintain_users.open_document = function(object_id, certificate_sub_category_id, id) {
            var url_call_from = 'setup_user_window';
            var object_id = (object_id.indexOf("tab_") != -1) ? object_id.replace("tab_", "") : object_id;

            var user_row = maintain_users.grid.findCell(object_id,0,true);
            var application_users_id = maintain_users.grid.cells(user_row[0][0],2).getValue();                 

            param = '../../_setup/manage_documents/manage.documents.php?parent_object_id= ' + application_users_id + '&call_from=' + url_call_from + '&notes_category=' + category_id + '&notes_object_id=' + application_users_id  + '&is_pop=true';
            var is_win = dhxWins.isWindow('w11');
            if (is_win == true) {
                w11.close();
            }
            w11 = dhxWins.createWindow("w11", 520, 100, 530, 550);
            w11.setText("Documents");
            w11.setModal(true);
            w11.maximize();
            w11.attachURL(param, false, true);

            w11.attachEvent("onClose", function(win) {
                if (certificate_sub_category_id != undefined)
                    maintain_users.refresh_all();
                else
                    update_document_counter(application_users_id, toolbar_object);
                
                return true;
            });            
        }

        maintain_users.user_privillege_grid_dbclick = function(rId,cInd) {
            var privilege_grid_obj;
            var layout_obj_t = maintain_users.layout.cells('b').getAttachedObject();
            layout_obj_t.forEachTab(function(tab){
                var is_active = tab.isActive();
                if (is_active == true) {
                    var tab_obj = tab.getAttachedObject();
                    tab_obj.forEachCell(function(cell){
                        var text = cell.getText();
                        if (text == get_locale_value('Privilege')) {
                            var layout_obj = cell.getAttachedObject();
                            privilege_grid_obj = layout_obj.cells('a').getAttachedObject();
                        }
                    });
                }
            });
            var has_children = privilege_grid_obj.hasChildren(rId);
            if (has_children == 0) {
                var user_login_id = maintain_users.tabbar.getActiveTab();
                user_login_id = (user_login_id.indexOf("tab_") != -1) ? user_login_id.replace("tab_", "") : user_login_id;
                var col_function_id = privilege_grid_obj.getColIndexById('function_id');
                var function_id = privilege_grid_obj.cells(rId,col_function_id).getValue('function_id');
                maintain_users.open_privilege_window(user_login_id,'u',function_id);
            }
        }

        maintain_users.before_save = function(tab_id) {
            var api_request = build_api_request();
            var form_obj = api_request['form_obj'];
            var param = api_request['param'];
            $.ajax(param).success(function (response) {
                if (response['message'].toLowerCase() == 'available') {
                    response['message'] = '<a style="color: green;">' + response['message'] + '</a>';
                    maintain_users.save_application_users(tab_id);
                    win.progressOff();
                } else {
                    show_messagebox("Email address is already registered to another user in cloud database.");

                    form_obj.setItemFocus('user_emal_add');
                    form_obj.setNote('user_emal_add', {
                        text: response['message'], width:300
                    });
                    win.progressOff();
                }
            });
        }

        function build_api_request() {
            var tab_id = maintain_users.tabbar.getActiveTab();
            var win = maintain_users.tabbar.cells(tab_id);
            var tab_obj = win.getAttachedObject();
            var detail_tabs = tab_obj.getAllTabs();
            var form_obj;

            $.each(detail_tabs, function(index, value) {
                layout_obj = tab_obj.cells(value).getAttachedObject();
                layout_obj.forEachItem(function(cell) {
                    attached_obj = cell.getAttachedObject();
                    if (attached_obj instanceof dhtmlXForm) {
                        form_obj = attached_obj;
                        data = attached_obj.getFormData();
                        for (var a in data) {
                            if (a == 'user_login_id') {
                                user_login_id = data[a];
                            } else if (a == 'user_emal_add') {
                                user_email_address = data[a];
                            }
                        }
                    }
                });
            });

            var param = {
                "url": js_php_path.split('/trm/')[0] + "/api/index.php?route=resolve-path/check-email",
                "headers": {
                    "Content-Type": "application/json",
                    "Authorization": "Bearer " + token
                },
                "method": "POST",
                "timeout": 0,
                "data": "{\"user_email_address\":\"" + user_email_address + "\", \"user_login_id\":\"" + user_login_id + "\"}"
            };

            return {"form_obj": form_obj, "param": param};
        }

        function check_if_available() {
            var api_request = build_api_request();
            var form_obj = api_request['form_obj'];
            var param = api_request['param'];
            $.ajax(param).done(function(response) {
                if (response['message'].toLowerCase() == 'available') {
                    response['message'] = '<a style="color: green;">' + response['message'] + '</a>';
                    form_obj.setNote('user_emal_add', {
                        text: response['message'], width:300
                    });
                } else {
                    form_obj.setNote('user_emal_add', {
                        text: response['message'], width:300
                    });
                }
            });
        }

        maintain_users.update_user_as_read_only = function(read_only_user) {
            var selected_ids = maintain_users.grid.getSelectedId();
            var count = selected_ids.indexOf(",") > -1 ? selected_ids.split(",").length : 1;
            selected_ids = selected_ids.indexOf(",") > -1 ? selected_ids.split(",") : [selected_ids];
            var login_id_index =  maintain_users.grid.getColIndexById('user_login_id');
            var user_login_ids = '';
            var confirm_msg = "Are you sure you want to set user(s) as read-only?";

            if (read_only_user == 'n') {
                confirm_msg = "Are you sure you want to set user(s) as read-write?";
            }

            if (selected_ids != null) {
                for ( var i = 0; i < count; i++) {
                    user_login_ids += maintain_users.grid.cells(selected_ids[i], login_id_index).getValue() + ',';
                }
                user_login_ids = user_login_ids.slice(0, -1);
            }
            
            data = {
                "action": "spa_application_users",
                "flag": "e",
                "user_login_id": user_login_ids,
                "read_only_user": read_only_user
            };
            adiha_post_data("confirm", data, "", "", "", "", confirm_msg);
        }

    </script>
</html>