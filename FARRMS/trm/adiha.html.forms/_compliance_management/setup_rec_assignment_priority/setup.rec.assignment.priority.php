<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
</head>
<?php
    include '../../../adiha.php.scripts/components/include.file.v3.php';


    $php_script_loc = $app_php_script_loc;
    $layout_obj = new AdihaLayout();
    $toolbar_obj = new AdihaToolbar();
    $rec_assignment_priority = new AdihaTree();
    $tabbar_obj = new AdihaTab();
    $menu_obj = new AdihaMenu();
    
    $name_space = 'rec_assignment_priority';
    $toolbar_name = 'toolbar_rec_assignment_priority';
    $rec_assignment_priority_name = 'rec_assignment_priority';
    $tabbar_name = 'rec_assignment_priority_details';
    $grouping_list = 'group_id:group_name,detail_id:detail_type';
    $additional_param = 'flag=s';
    $form_name = 'frm_rec_assignment_priority';
    $layout_name = 'rec_assignment_priority_layout';
    $menu_name = 'rec_assignment_priority_menu';
    
    
    $rights_rec_assignment_priority_group = 12103200;    
    $rights_rec_assignment_priority_group_UI = 12103210;
    $rights_rec_assignment_priority_group_delete = 12103211;
    $rights_rec_assignment_priority_detail_UI = 12103212;
    $rights_rec_assignment_priority_detail_delete = 12103213;
    $rights_rec_assignment_priority_order_UI = 12103214;
    $rights_rec_assignment_priority_order_delete = 12103215;
   
    list (
        $has_rights_rec_assignment_priority_group, 
        $has_rights_rec_assignment_priority_group_UI,
        $has_rights_rec_assignment_priority_group_delete,
        $has_rights_rec_assignment_priority_detail_UI,
        $has_rights_rec_assignment_priority_detail_delete,
        $has_rights_rec_assignment_priority_order_UI,
        $has_rights_rec_assignment_priority_order_delete
    ) = build_security_rights(
        $rights_rec_assignment_priority_group, 
        $rights_rec_assignment_priority_group_UI,
        $rights_rec_assignment_priority_group_delete,
        $rights_rec_assignment_priority_detail_UI,
        $rights_rec_assignment_priority_detail_delete,
        $rights_rec_assignment_priority_order_UI,
        $rights_rec_assignment_priority_order_delete       
    );    
  
    $enable_rec_assignment_priority_group_UI = ($has_rights_rec_assignment_priority_group_UI) ? 'false' : 'true';
    $enable_rec_assignment_priority_group_delete = ($has_rights_rec_assignment_priority_group_delete) ? 'false' : 'true';
    
    
    $layout_json = "[
                        {
                            id:             'a',
                            text:           'Setup REC Assignment Priority',
                            width:          250,
                            collapse:       false,
                            fix_size:       [false, null]
                        },
                        {
                            id:             'b',
                            text:           'Setup REC Assignment Priority',
                            width:          250,
                            collapse:       false,
                            fix_size:       [false, null]
                        }
                    ]";
    
    $tree_toolbar_json =  '[
                            
                            {id:"t1", text:"Edit", img:"edit.gif", items:[
                            {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add", disabled: ' . $enable_rec_assignment_priority_group_UI . '},
                            {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete", disabled:"true"}
                            ]}                                                          
                         ]';
        
//        
//        { id: "add", type: "button", img: "new.gif", text:"Add", title: "Add},
//                            { type: "separator" },
//                            { id: "delete", type: "button", img: "trash.gif", text: "Delete", title: "Delete"},
        
    echo $layout_obj->init_layout($layout_name, '', '2U', $layout_json, $name_space);    
    echo $layout_obj->attach_menu_cell($menu_name, 'a');
    echo $layout_obj->attach_tree_cell($rec_assignment_priority_name, 'a');    
    echo $layout_obj->attach_form($form_name, 'b');
    
    echo $menu_obj->init_by_attach($menu_name, $name_space);
    echo $menu_obj->load_menu($tree_toolbar_json);
    echo $menu_obj->attach_event('', 'onClick', $name_space . '.grid_toolbar_click');
        
    echo $rec_assignment_priority->init_by_attach($rec_assignment_priority_name, $name_space);    
    echo $rec_assignment_priority->load_tree_xml('spa_maintain_rec_assignment_priority_group', 'detail_order_id:detail_order_value', $grouping_list, $additional_param);
    echo $rec_assignment_priority->attach_event('', 'onDblClick', $name_space . '.open_detail');
    echo $rec_assignment_priority->attach_event('', 'onCheck', $name_space . '.single_check');
    echo $rec_assignment_priority->enable_checkbox();
    
    echo $rec_assignment_priority->load_tree_functions();    
    
    echo $layout_obj->attach_tab_cell($tabbar_name, 'b');    
    echo $tabbar_obj->init_by_attach($tabbar_name, $name_space);
    echo $tabbar_obj->enable_tab_close();
    echo $tabbar_obj->attach_event('', 'onTabClose', 'rec_assignment_priority.details_close');
   
    echo $layout_obj->close_layout(); 
     
?>
<body></body>
<script type="text/javascript">
    rec_assignment_priority.rec_assignment_priority_layout_form = {};
    
    var php_script_loc = '<?php echo $php_script_loc; ?>';
    var new_tab_name = '';
    var node_level = '';
    var checked_priority_node = '';
    var mode = '';
    var theme_selected = 'dhtmlx_' + default_theme;

    var enable_rec_assignment_priority_group_UI = <?php echo ($has_rights_rec_assignment_priority_group_UI) ? 'false' : 'true'; ?>;
    var enable_rec_assignment_priority_group_delete = <?php echo ($has_rights_rec_assignment_priority_group_delete) ? 'false' : 'true'; ?>;
    var enable_rec_assignment_priority_detail_UI = <?php echo ($has_rights_rec_assignment_priority_detail_UI) ? 'false' : 'true'; ?>;
    var enable_rec_assignment_priority_detail_delete = <?php echo ($has_rights_rec_assignment_priority_detail_delete) ? 'false' : 'true'; ?>;
    var enable_rec_assignment_priority_order_UI = <?php echo ($has_rights_rec_assignment_priority_order_UI) ? 'false' : 'true'; ?>;
    var enable_rec_assignment_priority_order_delete = <?php echo ($has_rights_rec_assignment_priority_order_delete) ? 'false' : 'true'; ?>; 
    
   $(function() {
        rec_assignment_priority.rec_assignment_priority_layout.cells('a').setWidth(300);
        rec_assignment_priority.rec_assignment_priority.enableDragAndDrop(true, false); 
        rec_assignment_priority.rec_assignment_priority.setDragBehavior('sibling');
        rec_assignment_priority.rec_assignment_priority.enableMercyDrag(true);
        
        rec_assignment_priority.rec_assignment_priority.attachEvent("onDrag", function(sId, tId, id, sObject, tObject){
            if (tId == 0) { //disable drag for parent node
                return false;
            }
            
            var sId_arr = sId.split('_');
            var tId_arr = tId.split('_');
            
            if (sId_arr[2] > 0) { // for order node
                if (sId_arr[0] == tId_arr[0] && sId_arr[1] == tId_arr[1] && enable_rec_assignment_priority_order_UI == false) {
                    return true;
                } else {
                    return false;
                }                
            } else if (sId_arr[2] == 0 && sId_arr[1] > 0 && enable_rec_assignment_priority_detail_UI == false) { // for detail node
                if (sId_arr[0] == tId_arr[0] && tId_arr[1] == 0) {
                    return true;
                } else {
                    return false;
                } 
            } else {
                return false;
            }
            return false;
        });
                   
        rec_assignment_priority.rec_assignment_priority.attachEvent("onDrop", function(sId, tId, id, sObject, tObject){
            //alert(sId);
            //alert(tId); // trailing item id
            //alert(id);
            
            /****/
            dhtmlx.message({
                type: "confirm",
                text: "Are you sure you want to save order?",
                callback: function(result) {
                    if (result) {
                        var sId_arr = sId.split('_');
                        if (id != null) { // if drop as last item then return null
                            var id_arr = id.split('_');
                        }
                        var sId_org = '';
                        
                        for (var i = 0; i< sId_arr.length - 1; i++) {
                            sId_org += sId_arr[i];
                            sId_org += (i < sId_arr.length - 2 ) ? '_' : '';                                
                        }
                                                
                        rec_assignment_priority.rec_assignment_priority.deleteItem(sId_org);
                        
                        // code to save in database
                        var form_xml = '<Root function_id=""><FormXML ';
                        
                        form_xml += " rec_assignment_priority_group_id=\"" + sId_arr[0] + "\"";
                        form_xml += " rec_assignment_priority_detail_id=\"" + sId_arr[1] + "\"";
                        form_xml += " rec_assignment_priority_order_id=\"" + sId_arr[2] + "\"";
                        
                        if (id != null) { // if drop as last item then return null
                            form_xml += " trailing_group_id=\"" + id_arr[0] + "\"";
                            form_xml += " trailing_detail_id=\"" + id_arr[1] + "\"";
                            form_xml += " trailing_order_id=\"" + id_arr[2] + "\"";
                        } else {
                            form_xml += " trailing_group_id=\"\"";
                            form_xml += " trailing_detail_id=\"\"";
                            form_xml += " trailing_order_id=\"\"";
                        }
                        
                        form_xml += "></FormXML></Root>";
                        
                        if (sId_arr[2] == 0) {
                            data = {"action": "spa_maintain_rec_assignment_priority_detail", 
                                "flag": "y",
                                "form_xml": form_xml
                            };
                        } else {
                            data = {"action": "spa_maintain_rec_assignment_priority_order", 
                                "flag": "y",
                                "form_xml": form_xml
                            };
                        }  
                        
                        var return_json = adiha_post_data('alert', data, 'Changes have been saved successfully.', '', '');
                        
                        
                    } else {
                        rec_assignment_priority.rec_assignment_priority.deleteItem(sId);
                    }
                }                        
            });
            /****/
        });
    })
        
    //Prevent multi check in treeview
    rec_assignment_priority.single_check = function (id, state) {  
        
        if (checked_priority_node != '' && checked_priority_node != id) {
            rec_assignment_priority.rec_assignment_priority.setCheck(checked_priority_node, false);
        }               
        
        checked_priority_node = id;  
        var id_arr = id.split('_');
        
        rec_assignment_priority.rec_assignment_priority_menu.setItemDisabled("add");
        
        if (id_arr[2] > 0 && id_arr[1] > 0 && id_arr[0] > 0) {
            if (enable_rec_assignment_priority_order_delete == false && state == 1)
                rec_assignment_priority.rec_assignment_priority_menu.setItemEnabled("delete");
        } else if (id_arr[2] == 0 && id_arr[1] > 0 && id_arr[0] > 0) {
            if (enable_rec_assignment_priority_detail_UI == false && state == 1)
                rec_assignment_priority.rec_assignment_priority_menu.setItemEnabled("add");
            if (enable_rec_assignment_priority_detail_delete == false && state == 1)
                rec_assignment_priority.rec_assignment_priority_menu.setItemEnabled("delete");            
        } else {
            if (enable_rec_assignment_priority_group_UI == false && state == 1)
                rec_assignment_priority.rec_assignment_priority_menu.setItemEnabled("add");
            if (enable_rec_assignment_priority_group_delete == false && state == 1)
                rec_assignment_priority.rec_assignment_priority_menu.setItemEnabled("delete");        
        }
        
        if (state == 0) {
            rec_assignment_priority.rec_assignment_priority_menu.setItemDisabled("delete");
            if (enable_rec_assignment_priority_group_UI == false)
                rec_assignment_priority.rec_assignment_priority_menu.setItemEnabled("add");
        } 
    }
    
    /*
        param id:   It has format [parentID_childID_detailID] 
                    For parent, id will be in the format [parentID_0_0] (Only parent part will have value, other part will have 0) eg: 2_0_0
                    For child, id will be in the format [parentID_childID_0] (Only parent and child part will have value, part will have 0) eg: 2_10_0 
                    For detail, id will be in the format [parentID_childID_detailID] eg: 2_10_15
                    
                    For adding new parent, the parent part of the id will be -1 eg: -1_0_0
                    For adding new child, the child part of the id will be -1 eg: 1_-1_0
                    For adding new detail, the detail part of the id will be -1 eg: 1_1_-1
    */
    rec_assignment_priority.open_detail = function(id, unused, tab_label, level) {
        rec_assignment_priority.rec_assignment_priority.enableSingleRadioMode(true);
        var node_id = id;//rec_assignment_priority.rec_assignment_priority.getSelectedItemId();
        var hierarchy_level = typeof level !== 'undefined' ? level : rec_assignment_priority.rec_assignment_priority.getLevel(id); 
        var group_name = '';
        var node_id_array = [];
        var id_array = [];
        var add_new_tab = 0;
        node_id_array = node_id.split('_'); 
        id_array = id.split('_'); 
        
        current_node_id = node_id_array[hierarchy_level - 1];
        var icon_loc = '../../../adiha.php.scripts/components/lib/adiha_dhtmlx/themes/' + theme_selected + '/imgs/dhxtoolbar_web/';
              
           
        if (!rec_assignment_priority.pages[id]) {
      
            var tab_name = typeof tab_label !== 'undefined' ? tab_label : rec_assignment_priority.rec_assignment_priority.getSelectedItemText();     
            
            
           // alert( tab_label + ' ' + typeof mode +' '+ rec_assignment_priority.rec_assignment_priority.getSelectedItemText() + ' ');
            //Add New Parent
            if (id_array[0] == -1) {
                hierarchy_level = 1;
                current_node_id = 0;                
                tab_name = 'New Priority Group';
            }
            //Add New Child
            if (id_array[1] == -1) {
                hierarchy_level = 2;
                current_node_id = 0;                
                tab_name = 'New Priority Type';
            }
            //Add New GChild
            if (id_array[2] == -1) {
                hierarchy_level = 3;
                current_node_id = 0;
                tab_name = 'New Priority Value';
            }
            
           
            rec_assignment_priority.rec_assignment_priority_details.addTab(id, tab_name, null, null, true, true);         
            win = rec_assignment_priority.rec_assignment_priority_details.cells(id);
            rec_assignment_priority.pages[id] = win;      
            var active_tab_id = rec_assignment_priority.rec_assignment_priority_details.getActiveTab();
            
            if (hierarchy_level == 1) {
                rec_assignment_priority_layout = win.attachLayout({
                                                pattern: "1C",
                                                cells: [
                                                    {id: "a", text: "General", height: 200}
                                                ]
                                            });
                
                form_toolbar = rec_assignment_priority_layout.cells('a').attachToolbar();     
                form_toolbar.setIconsPath(icon_loc);                
                form_toolbar.loadStruct([
                    { id: 'save', type: 'button', img: 'save.gif', imgdis: 'save_dis.gif',text:'Save', title: 'Save', disabled: enable_rec_assignment_priority_group_UI}
                 ]);
                form_toolbar.attachEvent('onClick', rec_assignment_priority.rec_assignment_priority_toolbar_click);  
                                   
                
            } else if (hierarchy_level == 2) {
                rec_assignment_priority_layout = win.attachLayout({
                                                pattern: "1C",
                                                cells: [
                                                    {id: "a", text: "General", height: 200}
                                                ]
                                            });
                
                form_toolbar = rec_assignment_priority_layout.cells('a').attachToolbar();     
                form_toolbar.setIconsPath(icon_loc);                
                form_toolbar.loadStruct([
                    { id: 'save', type: 'button', img: 'save.gif', text:'Save', title: 'Save', imgdis: 'save_dis.gif', disabled: enable_rec_assignment_priority_detail_UI}
                 ]);
                form_toolbar.attachEvent('onClick', rec_assignment_priority.rec_assignment_priority_toolbar_click);
                
            } else {      
                rec_assignment_priority_layout = win.attachLayout({
                                                pattern: "1C",
                                                cells: [
                                                    {id: "a", text: "General", height: 200}
                                                ]
                                            });
                
                form_toolbar = rec_assignment_priority_layout.cells('a').attachToolbar();     
                form_toolbar.setIconsPath(icon_loc);                
                form_toolbar.loadStruct([
                    { id: 'save', type: 'button', img: 'save.gif', text:'Save', title: 'Save', imgdis: 'save_dis.gif', disabled: enable_rec_assignment_priority_order_UI}
                 ]);
                form_toolbar.attachEvent('onClick', rec_assignment_priority.rec_assignment_priority_toolbar_click);
            }         
            
            if (hierarchy_level == 1) {
                group_name = 'Priority Group';
                var xml_value = '<Root><PSRecordset rec_assignment_priority_group_id="' + current_node_id + '"></PSRecordset></Root>';
                data = {"action": "spa_create_application_ui_json",
                        "flag": "j",
                        "application_function_id": 12103200,
                        "template_name": "RecAssignmentPriorityGroup",
                        "parse_xml": xml_value
                     };
                     
            } else if (hierarchy_level == 2) {
                group_name = 'Priority Type';
                var xml_value = '<Root><PSRecordset rec_assignment_priority_detail_id="' + current_node_id + '"></PSRecordset></Root>';
                data = {"action": "spa_create_application_ui_json",
                        "flag": "j",
                        "application_function_id": 12103212,
                        "template_name": "RecAssignmentPriorityDetail",
                        "parse_xml": xml_value
                     };
                
            } else {
                group_name = 'Priority Value';
                var xml_value = '<Root><PSRecordset rec_assignment_priority_order_id="' + current_node_id + '"></PSRecordset></Root>';
                data = {"action": "spa_create_application_ui_json",
                        "flag": "j",
                        "application_function_id": 12103214,
                        "template_name": "RECAssignmentPriorityOrder",
                        "parse_xml": xml_value
                     };
                    
            }
           
            adiha_post_data('return_array', data, '', '', 'load_rec_assignment_priority_callback', '');          
        } else {        
           
            rec_assignment_priority.rec_assignment_priority_details.cells(id).setActive();
        }
    }
    
    function load_rec_assignment_priority_callback(result) {       
        var active_tab_id = rec_assignment_priority.rec_assignment_priority_details.getActiveTab();
        //['form' + active_tab_id]
        var result_length = result.length;      
        var tab_json = '';
        for (i = 0; i < result_length; i++) {
            if (i > 0)
                tab_json = tab_json + ",";
            tab_json = tab_json + (result[i][1]);
        }
        tab_json = '{tabs: [' + tab_json + ']}';
        rec_assignment_priority_layout_tab = rec_assignment_priority_layout.cells("a").attachTabbar({mode:"bottom",arrows_mode:"auto"});
        rec_assignment_priority_layout_tab.loadStruct(tab_json);
    
        for (j = 0; j < result_length; j++) {
            tab_id = 'detail_tab_' + result[j][0];
            rec_assignment_priority.rec_assignment_priority_layout_form["form_" + active_tab_id] = rec_assignment_priority_layout_tab.cells(tab_id).attachForm();
            
            if (result[j][2]) {
                rec_assignment_priority.rec_assignment_priority_layout_form["form_" + active_tab_id].loadStruct(result[j][2]);
            }
        }   
        
        // set group_id for detail tab form        
        var tab_id_array = active_tab_id.split('_');
        if ((tab_id_array[0] > 0 && tab_id_array[1] > 0 && tab_id_array[2] > 0) || tab_id_array[2] < 0) {
            
            rec_assignment_priority.rec_assignment_priority_layout_form["form_" + active_tab_id].setItemValue('rec_assignment_priority_detail_id', tab_id_array[1]);
            //load combo                               
            var cm_param = {
                                "action": "[spa_maintain_rec_assignment_priority_order]", 
                                "flag": "l",
                                "detail_id": tab_id_array[1],
                                "has_blank_option": false
                            };
                            
            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;
            var combo_obj = rec_assignment_priority.rec_assignment_priority_layout_form["form_" + active_tab_id].getCombo("priority_type_value_id"); 

            var rec_assignment_priority_order_combo_val = rec_assignment_priority.rec_assignment_priority.getSelectedItemText();           
            combo_obj.load(url, function() {
                var option_obj = combo_obj.getOptionByLabel(rec_assignment_priority_order_combo_val);
                if (option_obj == null) {
                    combo_obj.selectOption(0); 
                } else {
                    combo_obj.selectOption(option_obj.index, null, true); 
                }
            });
        } else if ((tab_id_array[0] > 0 && tab_id_array[1] > 0) || tab_id_array[1] == -1) {
            rec_assignment_priority.rec_assignment_priority_layout_form["form_" + active_tab_id].setItemValue('rec_assignment_priority_group_id', tab_id_array[0]);
        }
    }
    
    rec_assignment_priority.rec_assignment_priority_toolbar_click = function(id) {
        var active_tab_id = rec_assignment_priority.rec_assignment_priority_details.getActiveTab();
        switch(id) {
            case "save":
                form_data = rec_assignment_priority.rec_assignment_priority_layout_form["form_" + active_tab_id].getFormData();             
                var active_tab_id_array = [];                
                
                active_tab_id_array = active_tab_id.split('_'); 
                
                mode = 'u';
                
                if (active_tab_id_array[0] == -1 || active_tab_id_array[1] == -1 || active_tab_id_array[2] == -1) {
                    mode = 'i';
                }
                
                
                var form_xml = '<Root function_id=""><FormXML ';
                for (var a in form_data) {
                    if (form_data[a] != '' && form_data[a] != null) {
                        value = form_data[a];
                        
                        field_label = a;
                        field_value = (field_label == 'effective_date') ? dates.convert_to_sql(form_data[a]) : form_data[a];
                        form_xml += " " + field_label + "=\"" + field_value + "\"";
                                                                        
                        //get new tab name 
                        if (a == 'rec_assignment_priority_group_name' ) {
                            new_tab_name = value;
                            node_level = 1;
                            if (rec_assignment_priority.rec_assignment_priority_layout_form["form_" + active_tab_id].getItemValue('description') == "") {
                                rec_assignment_priority.rec_assignment_priority_layout_form["form_" + active_tab_id].setItemValue('description', field_value);
                            }
                            
                        } else if ( a == 'priority_type') {
                            new_tab_name = rec_assignment_priority.rec_assignment_priority_layout_form["form_" + active_tab_id].getCombo("priority_type").getComboText();
                            node_level = 2;
                           
                        } else if (a == 'priority_type_value_id') {                                  
                            node_level = 3;  
                            new_tab_name = rec_assignment_priority.rec_assignment_priority_layout_form["form_" + active_tab_id].getCombo("priority_type_value_id").getComboText();
                        }
                                                                                 
                    }
                }
                form_xml += "></FormXML></Root>";
                
                
                if (active_tab_id_array[0] != 0 && active_tab_id_array[1] == 0 && active_tab_id_array[2] == 0) { 
                    //parent
                    
                    if (validate_form(rec_assignment_priority.rec_assignment_priority_layout_form["form_" + active_tab_id]) == false) {
                            generate_error_message();
                        return;
                    } 
                    
                    data = {"action": "spa_maintain_rec_assignment_priority_group", 
                            "flag": "" + mode + "",
                            "form_xml": form_xml
                    };
                    
                    
                } else if (active_tab_id_array[0] != 0 && active_tab_id_array[1] != 0 && active_tab_id_array[2] == 0) {
                    //Child
                    
                    //check for mandatory fields
                    if (validate_form(rec_assignment_priority.rec_assignment_priority_layout_form["form_" + active_tab_id]) == false) {
                        generate_error_message();
                        return;
                    }
                    
                    data = {"action": "spa_maintain_rec_assignment_priority_detail", 
                            "flag": "" + mode + "",
                            "form_xml": form_xml
                    };
                      
                } else {                
                    
                    //check for mandatory fields
                    if (validate_form(rec_assignment_priority.rec_assignment_priority_layout_form["form_" + active_tab_id]) == false) {
                         generate_error_message();
                        return;
                    }
                    
                    data = {"action": "spa_maintain_rec_assignment_priority_order", 
                            "flag": "" + mode + "",
                            "form_xml": form_xml
                    };
                }
                var return_json = adiha_post_data('alert', data, 'Changes have been saved successfully.', '', 'refresh_tree_rec_assignment_priority');
                
                
            break;
            default:
                show_messagebox(id);
        }
    }  
    
    function refresh_tree_rec_assignment_priority(response_data) { 
        if(response_data[0].errorcode != 'Success') return;

        var active_tab_id = rec_assignment_priority.rec_assignment_priority_details.getActiveTab();
        active_tab_id_array = active_tab_id.split('_'); 
                
        var mode = 'u';
        
        if (active_tab_id_array[0] == -1 || active_tab_id_array[1] == -1 || active_tab_id_array[2] == -1) {
            rec_assignment_priority.open_detail(response_data[0].recommendation, '', new_tab_name, node_level);
            rec_assignment_priority.rec_assignment_priority_details.cells(response_data[0].recommendation).setActive();
            rec_assignment_priority.rec_assignment_priority_details.tabs(active_tab_id).close(true);
            rec_assignment_priority.details_close(active_tab_id);
        
            
        } else {
            rec_assignment_priority.rec_assignment_priority_details.cells(active_tab_id).setText(new_tab_name);
        }

        rec_assignment_priority.refresh_tree('spa_maintain_rec_assignment_priority_group', 'detail_order_id:detail_order_value', '<?php echo $grouping_list; ?>', '<?php echo $additional_param;?>');
    }

    rec_assignment_priority.expand_callback_node = function () {        
        var new_tab_id = rec_assignment_priority.rec_assignment_priority_details.getActiveTab();
        rec_assignment_priority.rec_assignment_priority.openItem(new_tab_id);
    }
    
    /*
    * Close tab
    */
    
    rec_assignment_priority.details_close = function(id) {
        delete rec_assignment_priority.pages[id];
        return true;
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
    
    rec_assignment_priority.grid_toolbar_click = function(id) {
        var selected_row = rec_assignment_priority.rec_assignment_priority.getAllChecked();
        var selected_row_array = [];
        
        if (selected_row.indexOf(',') != -1) {
            show_messagebox("Please select only one node from tree!");
            return;
        }
        
        switch(id) {
            case 'add': 
                
                selected_row = selected_row.replace('_0', '_-1');        
                selected_row_array = selected_row.split('_'); 
                if (selected_row_array == '') {
                    //show new tab for parent
                    rec_assignment_priority.open_detail('-1_0_0');
                } else if (selected_row_array[1] == '-1') {
                    //show new tab for child
                    rec_assignment_priority.open_detail(selected_row);
                } else if (selected_row_array[2] == '-1') {
                    //show new tab for Gchild
                    rec_assignment_priority.open_detail(selected_row);
                } else {
                    show_messagebox("No data can be insert under this node!");
                    return;
                }
                
            break;
            case 'delete':                         
                
                if (selected_row != '') {                
                    dhtmlx.confirm({
                        title: "Confirmation",
                        text: "Are you sure you want to delete?",
                        callback: function(result) {
                            if (result) {
                                selected_row_array = selected_row.split('_'); 
                                    
                                if (selected_row_array[0] != 0 && selected_row_array[1] == 0 && selected_row_array[2] == 0 ) {
                                    //show new tab for parent
                                    var param = {
                                            "flag": 'd',
                                            "action": '[spa_maintain_rec_assignment_priority_group]',
                                            "group_id" : selected_row_array[0]              
                                        };
                                } else if (selected_row_array[0] != 0 && selected_row_array[1] != 0 && selected_row_array[2] == 0 ) {
                                    //show new tab for child
                                    var param = {
                                            "flag": 'd',
                                            "action": '[spa_maintain_rec_assignment_priority_detail]',
                                        "detail_id": selected_row_array[1]
                                        };
                                } else {
                                    //show new tab for Gchild
                                    var param = {
                                        "flag": 'd',
                                        "action": '[spa_maintain_rec_assignment_priority_order]',
                                        "order_id": selected_row_array[2]                   
                                    };   
                                }   
                                param = $.param(param);
                                param = deparam(param);
                                adiha_post_data('alert', param, '', '', 'delete_rec_assignment_node'); 
                                
                                if(rec_assignment_priority.pages[selected_row]) {
                                    rec_assignment_priority.rec_assignment_priority_details.tabs(selected_row).close(); 
                                    rec_assignment_priority.details_close(selected_row);
                                }
                                                      
                            }
                        }
                 });
             } else {
                 dhtmlx.alert({
                     title: "Alert",
                     type: "alert-error",
                     text: "Please select a node from tree!"
                 });
             }
               
            break;
            default:
                show_messagebox(id);                    
        }
    }
    
    function delete_rec_assignment_node(response_data) {
        if(response_data[0].errorcode != 'Success') return;
        
        var selected_row = rec_assignment_priority.rec_assignment_priority.getAllChecked(); 
        rec_assignment_priority.rec_assignment_priority.deleteItem(selected_row, false);       
    }
</script>