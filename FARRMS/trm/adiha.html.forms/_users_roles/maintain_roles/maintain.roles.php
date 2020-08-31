<?php
/**
* Maintain roles screen
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
    $popup_obj = new AdihaPopup();
    $form_namespace = 'maintain_roles';
    $application_function_id = 10111100; 
    
    $right_roles_iu = 10111110;
    $rights_roles_del = 10111111;
    $rights_users_iu = 10111116;
    $rights_users_del = 10111117;
    $rights_privileges_iu = 10111131;
    $rights_privileges_del = 10111132;

    list (
        $has_rights_roles_iu,    //not in use
        $has_rights_roles_del,   //not in use
        $has_rights_users_iu,
        $has_rights_users_del,
        $has_rights_privileges_iu,
        $has_rights_privileges_del
    ) = build_security_rights (
        $right_roles_iu, 
        $rights_roles_del,
        $rights_users_iu,
        $rights_users_del,
        $rights_privileges_iu, 
        $rights_privileges_del
    );
    
    $users_add = ($has_rights_users_iu == '1') ? 'false' : 'true';
    $users_del = ($has_rights_users_del == '1') ? 'false' : 'true';
    $privileges_add = ($has_rights_privileges_iu == '1') ? 'false' : 'true';
    $privileges_del = ($has_rights_privileges_del == '1') ? 'false' : 'true';
         
    $form_obj = new AdihaStandardForm($form_namespace, $application_function_id);
    $form_obj->define_grid("maintain_role_grid", "EXEC spa_application_security_role @flag = z");
    $form_obj->define_layout_width(400);
    $form_obj->define_custom_functions('save_role', '', 'delete_application_role', 'post_form_load');
    echo $form_obj->init_form('Roles', 'Role Details');
    
    $menu_json_array = array(
                           array(
                                'json' => '{id: "edit", text: "Edit", img: "edit.gif", items: [
									{id: "new", img: "new.gif", imgdis: "new_dis.gif", text: "Add", title:"Add", disabled:' . $users_add . '},
                                    {id: "delete", img: "trash.gif", imgdis: "trash_dis.gif", text: "Delete", title:"Delete", disabled:true}
								    ]},
                                {id: "t2", text: "Export", img: "export.gif", items: [
                                    {id:"excel",img:"excel.gif", imgdis:"excel_dis.gif", text:"Excel", title:"Excel"},
                                    {id:"pdf", img:"pdf.gif", text:"PDF", title:"PDF"}]}',
                                'on_click' => 'maintain_roles.role_users_toolbar_click',
                                'on_select' => "delete|$users_del"
                             ),
                             array(
                                'json' => '{id: "edit", text: "Edit", img: "edit.gif", items: [
									{id: "new", img: "new.gif", imgdis: "new_dis.gif", text: "Add", title:"Add", disabled:' . $privileges_add . '},
                                    {id: "delete", img: "trash.gif", imgdis: "trash_dis.gif", text: "Delete", title:"Delete", disabled:true}
                                    ]},
                                {id: "t2", text: "Export", img: "export.gif", items: [    
                                    {id:"excel", img:"excel.gif", imgdis:"excel_dis.gif", text:"Excel", title:"Excel"},
                                    {id:"pdf", img:"pdf.gif", text:"PDF", title:"PDF"}]},
                                    {id:"expand_collapse", text:"Expand/Collapse", img:"exp_col.gif", imgdis:"exp_col_dis.gif", enabled: 1},
                                    {id:"select_unselect", text:"Select/Unselect All", img:"select_unselect.gif", imgdis:"select_unselect_dis.gif", enabled: 1}',
                                    
                                'on_click' => 'maintain_roles.application_privilege_toolbar_click',
                                'on_select' => "delete|$privileges_del"
                             )
                         );
                         
    echo $form_obj->set_grid_menu_json($menu_json_array, true);
             
    echo $form_obj->close_form();
?>

<script type="text/javascript">
    var app_script_loc = '<?php echo $php_script_loc; ?>';
    var expand_state = 0;
    var has_rights_users_iu = Boolean('<?php echo $has_rights_users_iu; ?>');
    var has_rights_privileges_iu = Boolean('<?php echo $has_rights_privileges_iu; ?>');
    var has_rights_roles_delete = Boolean('<?php echo $has_rights_roles_del; ?>');
    
    maintain_roles.role_users_toolbar_click = function(id) {
        var role_id =  maintain_roles.tabbar.getActiveTab();
        var default_role_id = (role_id.indexOf("tab_") != -1) ? role_id.replace("tab_", "") : role_id;  
        var php_script_loc_ajax = "<?php echo $app_php_script_loc; ?>"; 
                          
        switch(id) {
            case 'new':
                maintain_roles.open_role_window(default_role_id);
                break;
            case 'delete':
				 var t_layout = maintain_roles.layout.cells('b').getAttachedObject();
					t_layout.forEachTab(function(tab){
						var is_active = tab.isActive();
						if (is_active == true) {
							var tab_obj = tab.getAttachedObject();
								tab_obj.forEachCell(function(cell){
									
                               	var text = cell.getText();
								if (text == get_locale_value('General')) {
									   var j = 1;
								        var obj = cell.getAttachedObject();
										 obj.forEachItem(function(outer_object_export) {
										 var test_object_33 =  outer_object_export.getAttachedObject();
                                         
                                         outer_object_export.dock();   
									     var ttt = outer_object_export.getAttachedObject();
										 if (j == 2){
											var xyz = outer_object_export.getAttachedObject();
											var selectedId_delete=xyz.getSelectedRowId();
    											
                                            if (selectedId_delete == null) {
       	   									    show_messagebox('Please select roles to delete.');
                                            return;
											}
                                            
                                           if (test_object_33 == null) {
                                            outer_object_export.undock();
                                           }
                                          var selected_row_array_delete = selectedId_delete.split(',');
                                          var selected_item_id_delete = '';
														for(var i = 0; i < selected_row_array_delete.length; i++) {
											   if (i == 0) {
													selected_item_id_delete =  xyz.cells(selected_row_array_delete[i],0).getValue();
											
											   } else {
													selected_item_id_delete = selected_item_id_delete + ',' + xyz.cells(selected_row_array_delete[i],0).getValue();
											  }
										  }
                                            if (test_object_33 == null) {
                                            outer_object_export.undock();
                                           }
                                          
                                             data = {"action": "spa_role_user",
                                                    "flag": "e",
                                                     "role_id": default_role_id,
                                                     "user_type": "NULL",
                                                     "user_login_id": selected_item_id_delete
                                                 };
                                           adiha_post_data("confirm", data, "", "", "maintain_roles.success_callback_general_grid", "", "Are you sure you want to delete?");
                                         }
                                        j++;
                                            
                                       });
                                       
                                   } 
                                 
							});
						}
					});
                break;
            case "excel":
                var t_layout = maintain_roles.layout.cells('b').getAttachedObject();
				t_layout.forEachTab(function(tab){
					var is_active = tab.isActive();
					if (is_active == true) {
						var tab_obj = tab.getAttachedObject();
							tab_obj.forEachCell(function(cell){
							var text = cell.getText();
                            if (text == get_locale_value('General')) {
								   var j = 1;
							        var obj = cell.getAttachedObject();
                                    obj.forEachItem(function(outer_object_export) {
									var test_obj_3 = outer_object_export.getAttachedObject(); 
								    if (j == 2){
								      outer_object_export.dock();   
									  var inner_object_xcel = outer_object_export.getAttachedObject();
                                      if (test_obj_3 == null){
                                         outer_object_export.undock(); 
                                      }
                                      inner_object_xcel.toExcel(php_script_loc_ajax + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                                      } 
                                    j++;
                                   });
                               } 
                             
						});
					}
				}); 
                break;
            case "pdf":
                var t_layout = maintain_roles.layout.cells('b').getAttachedObject();
                 t_layout.forEachTab(function(tab){
					var is_active = tab.isActive();
					if (is_active == true) {
						var tab_obj = tab.getAttachedObject();
							tab_obj.forEachCell(function(cell){
							var text = cell.getText();
							if (text == get_locale_value('General')) {
								   var j = 1;
							        var obj = cell.getAttachedObject();
                                  	obj.forEachItem(function(outer_object_export) {
						           var test_obj_2 = outer_object_export.getAttachedObject(); 
								    if (j == 2){
					                  outer_object_export.dock(); 
                                      var inner_object_pdf = outer_object_export.getAttachedObject();
                                      if (test_obj_2 == null) {
                                            outer_object_export.undock(); 
                                        }  
                                      inner_object_pdf.toPDF(php_script_loc_ajax + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                                    
                                          
                                    }
                                      j++;
                                   });
                                  
                               } 
                        
						});
                         
					}
				}); 
               
                break; 		          
            default:
        }
    }
            
    maintain_roles.application_privilege_toolbar_click = function(id) {
       var default_role_id =  maintain_roles.tabbar.getActiveTab();
       var default_role_id = (default_role_id.indexOf("tab_") != -1) ? default_role_id.replace("tab_", "") : default_role_id; 
        
        switch(id) {
            case 'new':
                maintain_roles.open_privilege_window(default_role_id); 
            break;
            case 'delete':
                var t_layout = maintain_roles.layout.cells('b').getAttachedObject();
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
                                    var selectedId=ttt.getSelectedRowId(); // catch menu name
                                    var selectedId_null_check = ttt.getSelectedRowId();                                                                                                                                                        
                                    if (selectedId_null_check == null) {
                                        show_messagebox('Please select privilege to delete.');
                                        return;
                                    } 
                                                                                                                         
                                    var selected_row_array = selectedId.split(',');
                                    var selected_item_id = '';
                                    var selected_item_to_delete = '';
                                    var rm_view_id = [];

                                    for(var i = 0; i < selected_row_array.length; i++) {
                                      selected_item_to_delete =  ttt.cells(selected_row_array[i],1).getValue();

                                      //if row is for report manager views
                                      if(ttt.cells(selected_row_array[i],2).getValue() == 10201633) {
                                        if(ttt.cells(selected_row_array[i],0).getValue().indexOf('[') > -1) {
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
                                  }
                                  selected_item_id = selected_item_id.replace(/\,\,/g,','); 
                                  if (selected_item_id.charAt(0) == ',' ) {
                                    selected_item_id = selected_item_id.substring(1);
                                  } 
                                  if (selected_item_id.charAt(selected_item_id.length-1) == ',') {
                                        selected_item_id = selected_item_id.substr(0, selected_item_id.length - 1);
                                      //selected_item_id = selected_item_id.slice((selected_item_id.length),(selected_item_id.length-1));  
                                  }
                                  //    return  
                                  if (selected_item_id == ''){
                                    show_messagebox('Please select privilege to delete.');
                                    return;
                                  } 
                                       
                                                                                                                             
                                  var data = {"action": "spa_AccessRights",
                                                  "flag": "d",
                                                  "functional_user_id": selected_item_id,
                                                  'role_id': default_role_id,
                                                  'role_user_flag': 'r',
                                                  'rm_view_id': rm_view_id.join(',')
                                                };
                                 adiha_post_data("confirm", data, "", "", "maintain_roles.success_callback", "", "Are you sure you want to delete?");
                                                                                      
                                });
                              }
                        });
                        
                    }
                    
                });
            break;
            case "excel":
                var t_layout = maintain_roles.layout.cells('b').getAttachedObject();
                var php_script_loc_ajax = "<?php echo $app_php_script_loc; ?>"; 
                t_layout.forEachTab(function(tab){
                    var is_active = tab.isActive();
                    if (is_active == true) {
                        var tab_obj = tab.getAttachedObject();
                        tab_obj.forEachCell(function(cell){
                            var text = cell.getText();
                            var j = 1;
                            if (text == get_locale_value('Privilege')) {
                                var obj_privilege_excl = cell.getAttachedObject();
                                	//obj.forEachItem(function(obj_privilege_excl) {
                                       obj_privilege_excl.forEachItem(function(outer_obj_excl) {
                                        if (j == 1){
                                           var inner_obj_excl = outer_obj_excl.getAttachedObject();
                                           inner_obj_excl.toPDF(php_script_loc_ajax + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                                        }                                    
                                    });
                                } 
                            
                       });
                   }
                });     
            break;
            case "pdf":
                 var t_layout = maintain_roles.layout.cells('b').getAttachedObject();
                 var php_script_loc_ajax = "<?php echo $app_php_script_loc; ?>";                  
                    t_layout.forEachTab(function(tab){
                        var is_active = tab.isActive();
                        if (is_active == true) {
                            var tab_obj = tab.getAttachedObject();
                            tab_obj.forEachCell(function(cell){
                                var text = cell.getText();
                                if (text == get_locale_value('Privilege')) {
                                    var obj_privilege_pdf = cell.getAttachedObject();
                                    obj_privilege_pdf.forEachItem(function(outer_obj_pdf) {
                                        var inner_obj_pdf = outer_obj_pdf.getAttachedObject();
                                        inner_obj_pdf.toPDF(php_script_loc_ajax + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                                    });
                                } 
                                     
                           });
                       }
                    });             
            
            break;
           case "expand_collapse":
               var t_layout = maintain_roles.layout.cells('b').getAttachedObject();                  
                t_layout.forEachTab(function(tab){
                    var is_active = tab.isActive();
                    if (is_active == true) {
                        var tab_obj = tab.getAttachedObject();
                        tab_obj.forEachCell(function(cell){
                            var text = cell.getText();
                            if (text == get_locale_value('Privilege')) {
                                var obj_privilege_pdf = cell.getAttachedObject();
                                obj_privilege_pdf.forEachItem(function(outer_obj_pdf) {
                                    var inner_obj_pdf = outer_obj_pdf.getAttachedObject();                               
                                    if (expand_state == 0) {
                                        inner_obj_pdf.expandAll();
                                        expand_state = 1;
                                    } else {
                                        inner_obj_pdf.collapseAll();
                                        expand_state = 0;
                                    }
                                });
                            }    
                       });
                   }
                });          
                break;
            case "select_unselect":
                var t_layout = maintain_roles.layout.cells('b').getAttachedObject();                  
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
                                    var selected_id = inner_obj_exp_col.getSelectedRowId();
                                    
                                    if (selected_id == null) {
                                        inner_obj_exp_col.expandAll();
                                        var ids = inner_obj_exp_col.getAllRowIds();
                                        
                                        for (var id in ids) {
                                           inner_obj_exp_col.selectRow(id, true, true, false);
                                        }
                                    } else {
                                        inner_obj_exp_col.clearSelection();
                                    }
                                    
                                });
                            }    
                       });
                   }
                });
                break;
            default:
                show_messagebox(id);
        }
    }
       
    var privilege_window;
    maintain_roles.open_privilege_window = function(default_role_id) {
        unload_window();
        if (!privilege_window) {
            privilege_window = new dhtmlXWindows();
        }
        privilege_win = privilege_window.createWindow('w1', 0, 0, 800, 600);
        var text = (default_role_id == -1) ? "Privilege Select" : "Assign Privilege";
        privilege_win.setText(text);
        privilege_win.maximize();
        privilege_win.setModal(true);
        var url = '../maintain_privileges/select.privileges.php';
        url = url + '?call_from=r&default_role_id=' + default_role_id;
        privilege_win.attachURL(url, false, true);
        
		privilege_win.attachEvent("onClose", function(win){                         
        var t_layout = maintain_roles.layout.cells('b').getAttachedObject();
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
                                        "sql":"Exec spa_AccessRights @flag = m, @product_id = " + <?php echo $farrms_product_id; ?>  + ", @role_id =" + default_role_id,
                                        "grid_type":"tg",
                                        "grouping_column": "function_name2,function_name3,function_name4,function_name5,function_name6"
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

    /**
     * [unload_window Window unload function]
     */
    function unload_window() {
        if (privilege_window != null && privilege_window.unload != null) {
            privilege_window.unload();
            privilege_window = w1 = null;
        }
    }
    
    var role_window;
	maintain_roles.open_role_window = function(default_role_id) {
	    unload_window_role();
        if (!role_window) {
            role_window = new dhtmlXWindows();
        }
        new_win = role_window.createWindow('w2', 0, 0, 530, 600);
        var text = (default_role_id == -1) ? "Role Select" : "Assign Users";
        new_win.setText(text);
      //  new_win.maximize();
        new_win.setModal(true);
        var url = 'select.users.php';
        url = url + '?default_role_id=' + default_role_id;
        new_win.attachURL(url, false, true);
		new_win.attachEvent("onClose", function(win){
		  maintain_roles.refresh_grid();
           var t_layout = maintain_roles.layout.cells('b').getAttachedObject();
			t_layout.forEachTab(function(tab){
				var is_active = tab.isActive();
				if (is_active == true) {
					var tab_obj = tab.getAttachedObject();
					tab_obj.forEachCell(function(cell){
						var text = cell.getText();
                     	if (text == get_locale_value('General')) {
                            var j = 1;
                            var obj = cell.getAttachedObject();
                            
                            obj.forEachItem(function(outer_object_export) {
                                var tt2 = outer_object_export.getAttachedObject();
                                outer_object_export.dock();
                                var ttt = outer_object_export.getAttachedObject();
                               
                                if (j == 2){
                                   var sql_param = {
                                        "sql":"Exec spa_application_security_role @flag = f, @role_id =" + default_role_id,
                                        "grid_type":"g",
                                    };
                                    
                                    sql_param = $.param(sql_param);
                                    var sql_url = js_data_collector_url + "&" + sql_param;
                                    
                                    ttt.clearAndLoad(sql_url, function(){
                                        var menu_object = outer_object_export.getAttachedMenu();
                                        menu_object.setItemDisabled("delete");
                                    });
                                        if (tt2 == null){                              
                                        outer_object_export.undock();
                                        }
                                    
                                }
                                j++;
                            });
						}					
					});
                }
            });
            return true;
        })
	}
    
	function unload_window_role() {
        if (role_window != null && role_window.unload != null) {
            role_window.unload();
            role_window = w2 = null;
        }
    }
  
    maintain_roles.success_callback = function(result){
        var default_role_id =  maintain_roles.tabbar.getActiveTab();
        var default_role_id = (default_role_id.indexOf("tab_") != -1) ? default_role_id.replace("tab_", "") : default_role_id; 
        var t_layout = maintain_roles.layout.cells('b').getAttachedObject();
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
                                "sql":"Exec spa_AccessRights @flag = m, @product_id = " + <?php echo $farrms_product_id; ?>  + ", @role_id =" + default_role_id,
                                "grid_type":"tg",
                                "grouping_column": "function_name2,function_name3,function_name4,function_name5,function_name6"
                            };
                            sql_param = $.param(sql_param);
                            var sql_url = js_data_collector_url + "&" + sql_param;
                            ttt.clearAndLoad(sql_url, function(){
                                ttt.filterByAll();
                                var menu_object = aaa.getAttachedMenu();
                                menu_object.setItemDisabled("delete");
                            });
                        });        
                    }
                });
            }
        });
    } 
    
    maintain_roles.success_callback_general_grid = function(result) {
        var default_role_id =  maintain_roles.tabbar.getActiveTab();
        var default_role_id = (default_role_id.indexOf("tab_") != -1) ? default_role_id.replace("tab_", "") : default_role_id; 
        var t_layout = maintain_roles.layout.cells('b').getAttachedObject();
		t_layout.forEachTab(function(tab){
			var is_active = tab.isActive();
			if (is_active == true) {
				var tab_obj = tab.getAttachedObject();
				tab_obj.forEachCell(function(cell){
					var text = cell.getText();
					if (text == get_locale_value('General')) {
				        var j = 1;
				        var obj = cell.getAttachedObject();
                       	obj.forEachItem(function(outer_object_export) {
                           var ttt_1 = outer_object_export.getAttachedObject();
                           outer_object_export.dock();
                            var ttt = outer_object_export.getAttachedObject();
                            if (j == 2){
                                var sql_param = {
                                    "sql":"Exec spa_application_security_role @flag = f, @role_id =" + default_role_id,
                                    "grid_type":"g",
                                };
                                sql_param = $.param(sql_param);
                                var sql_url = js_data_collector_url + "&" + sql_param;
                                
                                ttt.clearAndLoad(sql_url, function(){
                                    ttt.filterByAll();
                                    if (ttt_1== null){
                                      outer_object_export.undock(); 
                                    }
                                    var menu_object = outer_object_export.getAttachedMenu();
                                    menu_object.setItemDisabled("delete");
                                });
                            }
                            j++;
                        });
					}					
				});
            }
        });  
    }
    
	maintain_roles.refresh_grid_callback = function(result) { 
	    attached_obj.clearAll();
      attached_obj.filterByAll();
        attached_obj.parse(result, "js");
    }
    
    maintain_roles.save_role = function(tab_id) {
        var win = maintain_roles.tabbar.cells(tab_id);
        var valid_status = 1;
        var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(" ", ""));
        var tab_obj = win.tabbar[object_id];
        var detail_tabs = tab_obj.getAllTabs();
        var tabsCount = tab_obj.getNumberOfTabs();
        var form_status = true;
          var first_err_tab;
        var form_xml = "<FormXML ";
        $.each(detail_tabs, function(index,value) {
         layout_obj = tab_obj.cells(value).getAttachedObject();
         layout_obj.forEachItem(function(cell){
             attached_obj = cell.getAttachedObject();
             
             if(attached_obj instanceof dhtmlXForm) {
                 var status = validate_form(attached_obj);
                 form_status = form_status && status; 
                if (tabsCount == 1 && !status) {
                     first_err_tab = "";
                } else if ((!first_err_tab) && !status) {
                    first_err_tab = tab_obj.cells(value);
                }
                 if(status) {
                     data = attached_obj.getFormData();
                     for (var a in data) {
                        field_label = a;
                        field_value = data[a];
                        if (field_label == 'role_description') {
                            if(data[a] == '') {
                                field_value = data['role_name'];
                            }
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
        
        var xml = "<Root function_id=\"<?php echo $application_function_id;?>\" object_id=\"" + object_id + "\">";
        xml += form_xml;
        xml += "</Root>";
        xml = xml.replace(/'/g, "\"");
        
        data = {"action": "spa_process_form_data", "xml": xml};
        
    	if(valid_status == 1){
        //console.log(win.getAttachedToolbar());
        win.getAttachedToolbar().disableItem('save');
        result = adiha_post_data("alert", data, "", "","maintain_roles.post_callback");
    	}
      if (!form_status) {
                generate_error_message(first_err_tab);
            }
    }

    /*function post_callback() {
      win.getAttachedToolbar().enableItem('save');

    }*/

    maintain_roles.post_form_load = function(win,tab_id) {  //alert(win , tab_id)     
        var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(" ", ""));
        var tab_obj = win.tabbar[object_id];
        var detail_tabs = tab_obj.getAllTabs();
        
        $.each(detail_tabs, function(index,value) {
            if (index == 0) {
                //General Tab
                layout_obj = tab_obj.cells(value).getAttachedObject();
                layout_obj.cells('a').setHeight(80);
                
                var menu_object = layout_obj.cells('b').getAttachedMenu();
                if (has_rights_users_iu) {
                    if (tab_id.indexOf("tab_") != -1) {                        
                        menu_object.setItemEnabled("new");
                    } else {
                        menu_object.setItemDisabled("new");
                    }
                }
                
                layout_obj.forEachItem(function(cell){
                    attached_obj = cell.getAttachedObject();
                    
                    if(attached_obj instanceof dhtmlXForm) {
                     data = attached_obj.getFormData();
                     for (var a in data) {
                        field_label = a;
                        field_value = data[a];
                        if (field_label == 'role_type_value_id') {
                            var role_type_id = maintain_roles.grid.getSelectedRowId();
                            var hierarchy_level = maintain_roles.grid.getLevel(role_type_id);                           
                           if (hierarchy_level != 0) {
                                role_type_id = maintain_roles.grid.getParentId(role_type_id);
                           } 
                           var role_type = maintain_roles.grid.cells(role_type_id, 0).getValue();
                            if (role_type != null) {
                                var combo_obj_role_type = attached_obj.getCombo('role_type_value_id');
                                var opt = combo_obj_role_type.getOptionByLabel(role_type);
                                var opt_index = (opt == null) ? 0 : opt['index'];
                                combo_obj_role_type.selectOption(opt_index); 
                            }                                                     
                        }
                        }                    
                    }                 
                 });   
            }
            else if (index == 1) {
                //Privilege Tab
                layout_obj = tab_obj.cells(value).getAttachedObject();
                var menu_object = layout_obj.cells('a').getAttachedMenu();
                 
                if (has_rights_privileges_iu) {
                    if (tab_id.indexOf("tab_") != -1) {                        
                        menu_object.setItemEnabled("new");
                    } else {
                        menu_object.setItemDisabled("new");
                    }
                }
            }
        });
    }
    
    /**
     * [Enable menu items]
     */

    maintain_roles.enable_menu_item = function(id,ind) {
        var c_row = maintain_roles.grid.getChildItemIdByIndex(id, 0);
        var selected_row = maintain_roles.grid.getSelectedRowId();        
        maintain_roles.menu.setItemDisabled("delete");
        
        if(selected_row == '' || c_row != null ) { // if selected row is parent
            maintain_roles.menu.setItemDisabled("delete");
        } else { // if child is selected   
            if (has_rights_roles_delete) {
                maintain_roles.menu.setItemEnabled("delete");
            }
        }
    } 
    
    maintain_roles.delete_application_role = function() {
        var select_id = maintain_roles.grid.getSelectedRowId();
        var count = select_id.indexOf(",") > -1 ? select_id.split(",").length : 1;
        select_id = select_id.indexOf(",") > -1 ? select_id.split(",") : [select_id];
        var application_role_id = '';
        var get_application_role_id;
        if (select_id != null) {
            confirm_messagebox("Are you sure you want to delete?", function() {
                for (var i = 0; i < count; i++) {
                    var get_application_role_id = maintain_roles.grid.cells(select_id[i], 1).getValue();
                    application_role_id +=  get_application_role_id + ',';
                }
                application_role_id = application_role_id.slice(0, -1);
                data = {
                    "action": "spa_application_security_role", 
                    "del_role_id": application_role_id, 
                    "flag": "d"
                }
                result = adiha_post_data("return_array", data, "", "","maintain_roles.post_delete_callback");
            });
        }
    }
</script>
</html>