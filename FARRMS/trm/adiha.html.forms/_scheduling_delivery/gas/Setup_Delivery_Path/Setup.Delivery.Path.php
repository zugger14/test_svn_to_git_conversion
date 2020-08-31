<!--DOCTYPE transitional.dtd-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<meta http-equiv="X-UA-Compatible" content="IE=Edge"> 
<html> 
    <?php 
    include '../../../../adiha.php.scripts/components/include.file.v3.php';
    global $image_path;
    $contract_id = get_sanitized_value($_GET['contract_id'] ?? '0');
    $php_script_loc = $app_php_script_loc;
    $rights_setup_delivery_path = 10161100;
    $rights_setup_delivery_path_iu = 10161110;
    $rights_setup_delivery_path_del = 10161111;
    
    //data from flow optimization
    $call_from = get_sanitized_value($_GET['call_from'] ?? '');
    $mode = get_sanitized_value($_GET['mode'] ?? '');
    $path_id = get_sanitized_value($_GET['path_id'] ?? '');
    $from_loc_id = get_sanitized_value($_GET['from_loc_id'] ?? '') ;
    $to_loc_id = get_sanitized_value($_GET['to_loc_id'] ?? '');
    $from_loc = get_sanitized_value($_GET['from_loc'] ?? '');
    $to_loc = get_sanitized_value($_GET['to_loc'] ?? '');
    $trans_contract_id = get_sanitized_value($_GET['contract_id']?? '');
   
    
    list (
        $has_rights_setup_delivery_path,
        $has_rights_setup_delivery_path_iu,
        $has_rights_setup_delivery_path_del
    ) = build_security_rights (
        $rights_setup_delivery_path,
        $rights_setup_delivery_path_iu,
        $rights_setup_delivery_path_del  
    ); 
    //Layout starts
    $layout_obj = new AdihaLayout();
    $layout_name = 'setup_delivery_path_layout';
    $layout_json = "[
                        {
                            id:             'a',
                            text:           '<div><a class=\'undock_cell_a undock_custom\' style=\'float:right;cursor:pointer\' title=\'Undock\'  onClick=\'setup_delivery_path.undock_cell_a();\'><!--&#8599;--></a>Delivery Paths</div>',
                            width:          400,
                            collapse:       false,
                            fix_size:       [false, null],
                            header:         true
                        },
                        {
                            id:             'b',
                            text:           ' ',
                            collapse:       false,
                            fix_size:       [false, null],
                            header:         true
                        }
                    ]";
    $namespace = 'setup_delivery_path';
    echo $layout_obj->init_layout($layout_name, '', '2U', $layout_json, $namespace); 
    
    //Add menu object in a layout
    $menu_obj = new AdihaMenu();
    $menu_name = 'dp_menu';
    echo $layout_obj->attach_menu_cell($menu_name, 'a'); 
    echo $layout_obj->attach_event('', 'onDock', $namespace . '.on_dock_event');
    echo $layout_obj->attach_event('', 'onUnDock', $namespace . '.on_undock_event');
    echo $layout_obj->attach_status_bar('a', true);
    
    $tree_menu_json =  '[{id:"f1", text:"Edit", img:"edit.gif", items:[
                                {id:"add", text:"Add Single Path", img:"new.gif", imgdis:"new_dis.gif", title: "Add Single Path"},
                                {id:"add_gp", text:"Add Group Path", img:"add_group_path.gif", imgdis:"add_group_path_dis.gif", title: "Add Group Path"},
                                {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete"},
                                {id:"copy", text:"Copy", img:"copy.gif", imgdis:"copy_dis.gif", title: "Copy"}
                                ]
                        },
                        {id:"t2", text:"Export", img:"export.gif", items:[
                                {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel", enabled:"true"},
                                {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF", enabled:"true"},
                                ]
                        },
                        { id: "expand_collapse", img: "exp_col.gif", text: "Expand/Collapse", title: "Expand/Collapse"}
                        ]';
                         
    echo $menu_obj->init_by_attach($menu_name, $namespace);
    echo $menu_obj->load_menu($tree_menu_json);
    echo $menu_obj->attach_event('', 'onClick', $namespace . '.grid_toolbar_click');
    
    //Add treegrid in 'a' layout
    $treegrid_obj = new AdihaGrid();
    $treegrid_name = 'dp_treegrid';
    $grid_sp = "EXEC spa_setup_delivery_path @flag='g'";
    $grid_type = 'tg';
    $grouping_column = 'path_type,grouping_name'; 
    echo $layout_obj->attach_grid_cell($treegrid_name, 'a');       
    echo $treegrid_obj->init_by_attach($treegrid_name, $namespace);
    echo $treegrid_obj->set_header("Path Name,Path Code,Path ID, Receipt Location, Delivery Location, Pipeline, Contract, MDQ, Effective Date, Priority, Rates, Group Path,Contract ID");
    echo $treegrid_obj->set_columns_ids($grouping_column . ",path_code,path_id,receipt_location,delivery_location,counterparty_name,contract_name,mdq,effective_date,priority,rate_schedule,is_grouppath,contract_id");
    echo $treegrid_obj->set_widths("210,100,120,120,120,120,120,120,120,120,120,20,120");
    echo $treegrid_obj->split_grid(1); 
    echo $treegrid_obj->set_column_types("tree,ro,ro_int,ro,ro,ro,ro,ro_no,ro,ro,ro_no,ro,ro");
    echo $treegrid_obj->set_sorting_preference('str,str,str,str,str,str,str,int,str,str,str,str,str');     
    echo $treegrid_obj->set_column_auto_size();
    echo $treegrid_obj->set_column_visibility("false,true,true,false,false,false,,falsefalse,false,false,false,true,true");
    echo $treegrid_obj->set_search_filter('true'); 
    echo $treegrid_obj->enable_multi_select();
    echo $treegrid_obj->enable_paging(25, 'pagingArea_a'); 
    echo $treegrid_obj->return_init();
    echo $treegrid_obj->load_grid_data($grid_sp, $grid_type, $grouping_column);
    echo $treegrid_obj->attach_event('', 'onRowDblClicked', $namespace . '.load_data');
    echo $treegrid_obj->load_grid_functions(); 
    //
    
    //Right Panal
    $form_obj = new AdihaForm();
    $form_name = 'frm_delivery_path';
    $tabbar_obj = new AdihaTab();
    $tabbar_name = 'dp_tab';
    echo $layout_obj->attach_tab_cell($tabbar_name, 'b');    
    echo $tabbar_obj->init_by_attach($tabbar_name, $namespace);
    echo $tabbar_obj->enable_tab_close();
    echo $tabbar_obj->attach_event('', 'onTabClose', $namespace . '.close_path_detail');
    //to filter the routes by contract when called from contract UI.
    if($contract_id!=0){
        echo 'setup_delivery_path.dp_treegrid.attachEvent("onXLE", function(grid_obj,count){';
        echo '  setup_delivery_path.dp_treegrid.expandAll();';
        echo "      setup_delivery_path.dp_treegrid.filterBy(12,function(data){";
        echo "        return (data==".$contract_id.");";
        echo "      });";
        echo "});";
        // echo 'logical_menu.setIconsPath("' . $app_php_script_loc . 'components/lib/adiha_dhtmlx/themes/'.$theme_selected.'/imgs/dhxtoolbar_web/");';
    }
    
    /*
    $form_obj = new AdihaStandardForm($form_namespace, 10161110);
    //$form_obj->define_grid("SetupDeliveryPath", "", 't', 'true');
    echo $form_obj->init_form('Report', 'Report Details');
    echo $form_obj->close_form();
    */
    
    echo $layout_obj->close_layout();       
?>
        
</body>

<script type="text/javascript">  
    setup_delivery_path.details_layout = {};
    setup_delivery_path.details_tabs = {};
    setup_delivery_path.details_form = {};
    var php_script_loc = '<?php echo $app_php_script_loc; ?>';
    var image_path = '<?php echo $image_path; ?>';
    var treegrid_name = '<?php echo $treegrid_name; ?>';
    var application_function_id = 10161110;
    var template_name = 'SetupDeliveryPath';
    var path_type = 'single';
    var grouping_column = '<?php echo $grouping_column; ?>';
    var call_from = '<?php echo $call_from; ?>';
    var today = new Date();
    var dd = today.getDate();
    var mm = today.getMonth()+1; //January is 0!
    var yyyy = today.getFullYear();
    var validation_check = 0;
    var msg_confirm_delete = '';
    //var is_deleted_true = false;
    var is_delete_true = new Array(); //This array is used
    var theme_selected = 'dhtmlx_' + default_theme;
    var expand_state = 0;
    var deal_id;
     
    if (dd < 10) {
        dd = '0' + dd
    } 
    
    if (mm < 10) {
        mm = '0' + mm
    } 
    
    var current_date = mm + '/' + dd + '/' + yyyy;
    /**Privilege listing**/
    var edit_permission = '<?php echo $has_rights_setup_delivery_path_iu;?>';
    var delete_permission = '<?php echo $has_rights_setup_delivery_path_del; ?>';
    
    $(function(){
        // test for flow optimization
        call_from = '<?php echo $call_from; ?>';
        mode = '<?php echo $mode; ?>';
        passed_path_id = '<?php echo $path_id; ?>';
        from_loc_id = '<?php echo $from_loc_id; ?>';
        to_loc_id = '<?php echo $to_loc_id; ?>';  
        from_loc = '<?php echo $from_loc; ?>';
        to_loc = '<?php echo $to_loc; ?>';  

        if (call_from != null && call_from == 'flow_optimization' || call_from == 'schedule_detail_report' || call_from == 'flow_optimization_toggle') {
            // setup_delivery_path.setup_delivery_path_layout.cells('a').collapse();
            switch (mode) {
                case 'i':
                    // console.log('insert');
                    setup_delivery_path.load_data();
                    break;
                case 'u':
                    // console.log('update');
                    var data = {
                                "action": "spa_setup_delivery_path",
                                "flag": "g",
                                "single_path_id": passed_path_id
                            };
        
                    adiha_post_data('return_array', data, '', '', 'load_value', '');
                    break;
                default:
                    // console.log('no flag');
                    break;
            }
        }
        
        set_setup_delivery_path_menu_disabled('add', edit_permission);
        set_setup_delivery_path_menu_disabled('add_gp', edit_permission);
        set_setup_delivery_path_menu_disabled('delete', false);
        set_setup_delivery_path_menu_disabled('copy', false);
        
        setup_delivery_path.dp_treegrid.attachEvent("onRowSelect", function(id,ind){
            var group_col = setup_delivery_path.dp_treegrid.cells(id, setup_delivery_path.dp_treegrid.getColIndexById('path_type')).getValue();
            if (group_col != 'SINGLE PATH' && group_col != 'GROUP PATH' && group_col != '') {
                set_setup_delivery_path_menu_disabled('delete', delete_permission);
                set_setup_delivery_path_menu_disabled('copy', edit_permission);
            } else {
                set_setup_delivery_path_menu_disabled('delete', false);
                set_setup_delivery_path_menu_disabled('copy', false);
            }
            
        })
    });

    setup_delivery_path.deal_id_select = function(result) {          
        deal_id = result;
        if (result.length > 0) {
            $('#deal_idss').text('Deal Link (' + deal_id + ')');
        }                 
    }

    setup_delivery_path.undock_cell_a = function() {
        setup_delivery_path.setup_delivery_path_layout.cells("a").undock(300, 300, 900, 700);
        setup_delivery_path.setup_delivery_path_layout.dhxWins.window("a").button("park").hide();
        setup_delivery_path.setup_delivery_path_layout.dhxWins.window("a").maximize();
        setup_delivery_path.setup_delivery_path_layout.dhxWins.window("a").centerOnScreen();
    }
    setup_delivery_path.on_dock_event = function(name) {
         $(".undock_cell_a").show();
    }
    setup_delivery_path.on_undock_event = function(name) {
         $(".undock_cell_a").hide();
    }

    function load_value(result) {
        // console.log(result);
        var tab_id = 'tab_' + passed_path_id;
        var tab_label = result[0][1];
        
        if (result[0][0] == "GROUP PATH") {
            var path_type = 'group'
        }

        setup_delivery_path.dp_tab.addTab(tab_id, tab_label, null, null, true, true);  
            // var theme_selected = '<?php //echo $theme_selected; ?>';
            // var icon_loc = '../../../../adiha.php.scripts/components/lib/adiha_dhtmlx/themes/' + theme_selected + '/imgs/dhxtoolbar_web/';  

            var icon_loc = js_image_path + "dhxmenu_web/";   
                     
            win = setup_delivery_path.dp_tab.cells(tab_id);
            setup_delivery_path.pages[tab_id] = win;      
            var active_object_id = passed_path_id;
            setup_delivery_path["inner_tab_layout_" + active_object_id] = win.attachLayout("1C");
            setup_delivery_path["inner_tab_layout_" + active_object_id].cells('a').setHeight(500);
            setup_delivery_path["inner_tab_layout_" + active_object_id].cells('a').hideHeader()
            
            form_toolbar = setup_delivery_path["inner_tab_layout_" + active_object_id].cells('a').attachToolbar();                
            form_toolbar.setIconsPath(icon_loc);    
            
            form_toolbar.loadStruct([
                { id: 'save', type: 'button', img: 'save.gif', imgdis:"save_dis.gif", text: 'Save', title: 'Save'}
            ]);
            
            if (!edit_permission) {
                form_toolbar.disableItem('save');
            }  
                      
            form_toolbar.attachEvent('onClick', setup_delivery_path.save_click); 
            
            if (path_type == 'group') {                   
                load_group_path_detail();
            } else {
                var xml_value =  '<Root><PSRecordset path_id="' + passed_path_id + '"></PSRecordset></Root>';
                data = {"action": "spa_create_application_ui_json",
                        "flag": "j",
                        "application_function_id":application_function_id,
                        "template_name":template_name,
                        "parse_xml": xml_value
                     };
                
                result = adiha_post_data('return_array', data, '', '', 'setup_delivery_path.load_form_data');   
          }
    }
    
    setup_delivery_path.load_data = function(id) {
       var hierarchy_level = setup_delivery_path.dp_treegrid.getLevel(setup_delivery_path.dp_treegrid.getSelectedRowId());
       if (hierarchy_level == 0) {
            return;
       }
      setup_delivery_path.load_form_detail(id);
    }
    //set_setup_delivery_path_menu_disabled
    
    setup_delivery_path.load_form_detail = function(id) {
        var tab_label = (typeof id=="undefined") ? get_locale_value('New') : setup_delivery_path.dp_treegrid.cells(id,setup_delivery_path.dp_treegrid.getColIndexById('path_type')).getValue();
        tab_label = (tab_label == '') ? get_locale_value('New') : tab_label;
        //if (typeof id=="undefined") id = '001';
        var new_id = (new Date()).valueOf();
        var tab_id = (typeof id=="undefined" || tab_label == get_locale_value('New')) ? new_id.toString() : "tab_" + setup_delivery_path.dp_treegrid.cells(id, setup_delivery_path.dp_treegrid.getColIndexById('path_code')).getValue();
        
        //alert(setup_delivery_path.dp_treegrid.cells(id, 1).getValue() + '' + setup_delivery_path.dp_treegrid.cells(id, 2).getValue())
        var path_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        
        if (typeof id != "undefined" && tab_label != get_locale_value('New')) {
           group_path_id = setup_delivery_path.dp_treegrid.getParentId(id);
           path_type = (setup_delivery_path.dp_treegrid.cells(group_path_id, setup_delivery_path.dp_treegrid.getColIndexById('path_type')).getValue() == 'GROUP PATH') ? 'group' : 'single';
        }

        if (!setup_delivery_path.pages[tab_id]) {  
            setup_delivery_path.dp_tab.addTab(tab_id, tab_label, null, null, true, true);  
            // var icon_loc = '../../../../adiha.php.scripts/components/lib/adiha_dhtmlx/themes/' + theme_selected + '/imgs/dhxtoolbar_web/';     
            var icon_loc = js_image_path + "dhxmenu_web/";

            win = setup_delivery_path.dp_tab.cells(tab_id);
            setup_delivery_path.pages[tab_id] = win;      
            var active_object_id = path_id;
            setup_delivery_path["inner_tab_layout_" + active_object_id] = win.attachLayout("1C");
            setup_delivery_path["inner_tab_layout_" + active_object_id].cells('a').setHeight(500);
            setup_delivery_path["inner_tab_layout_" + active_object_id].cells('a').hideHeader()
            
            form_toolbar = setup_delivery_path["inner_tab_layout_" + active_object_id].cells('a').attachToolbar();                
            form_toolbar.setIconsPath(icon_loc);    
            
            form_toolbar.loadStruct([
                { id: 'save', type: 'button', img: 'save.gif', imgdis:"save_dis.gif",text: 'Save', title: 'Save'}
            ]);
            
            if (!edit_permission) {
                form_toolbar.disableItem('save');
            }
            
            form_toolbar.attachEvent('onClick', setup_delivery_path.save_click);
             
            setup_delivery_path.setup_delivery_path_layout.cells("b").progressOn();
            
            if (path_type == 'group') {                   
                load_group_path_detail();
            } else {
                // get source_deal_header_id for deal link.
                data = {    
                            "action": "spa_setup_delivery_path",
                            "flag": "k",
                            "path_id":path_id                    
                       };
                result = adiha_post_data('return_array', data, '', '', 'setup_delivery_path.deal_id_select'); 

                var xml_value =  '<Root><PSRecordset path_id="' + path_id + '"></PSRecordset></Root>';
                data = {"action": "spa_create_application_ui_json",
                        "flag": "j",
                        "application_function_id":application_function_id,
                        "template_name":template_name,
                        "parse_xml": xml_value
                     };
                
                result = adiha_post_data('return_array', data, '', '', 'setup_delivery_path.load_form_data');   
          } 
        } else {            
            setup_delivery_path.dp_tab.cells(tab_id).setActive();
        }
        
        var active_tab_id = setup_delivery_path.dp_tab.getActiveTab();
        is_delete_true[active_tab_id]  = false;  
         
    }
    
    setup_delivery_path.load_form_data = function(result) {
        var tab_json = '';
        var form_json = {};
        // create tab json and form json
        for (i = 0; i < result.length; i++) {
            if (i > 0)
                tab_json = tab_json + ",";
            tab_json = tab_json + (result[i][1]);

            form_json[i] = result[i][2];
        }
        var active_tab_id = setup_delivery_path.dp_tab.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        tab_json = '{mode: "bottom", arrows_mode: "auto",tabs: [' + tab_json + ']}';
        setup_delivery_path["delivery_path_tab_" + active_object_id] = setup_delivery_path["inner_tab_layout_" + active_object_id].cells('a').attachTabbar({mode:"bottom",arrows_mode:"auto"});
        // attach tab 
        setup_delivery_path["delivery_path_tab_" + active_object_id].loadStruct(tab_json);
        //attach form/grid
        var result_length = result.length;
        for (j = 0; j < result_length; j++) {
            tab_id = 'detail_tab_' + result[j][0];
            var tab_name = setup_delivery_path["delivery_path_tab_" + active_object_id].cells(tab_id).getText();
            
            switch(get_locale_value(tab_name)) {
                case get_locale_value("Path Detail"):
                    load_single_path_detail(tab_id, result[j][2]); //Form                    
                    break;
                case get_locale_value("Rate Schedule"):
                    load_rate_schedule(tab_id); //Grid
                    break;
                case get_locale_value("Fuel/Loss Factor"):
                    load_fuel_factor(tab_id); //Grid
                    break;
                case get_locale_value("MDQ"):
                    load_mdq_grid(tab_id);
                    break;
            }
        }
        
        if (from_loc_id != '') {
            setup_delivery_path.details_form["single_form_" + active_object_id].setItemValue('from_location', from_loc_id);
            setup_delivery_path.details_form["single_form_" + active_object_id].setItemValue('label_from_location', from_loc);
        }
        
        if (to_loc_id != '') {
            setup_delivery_path.details_form["single_form_" + active_object_id].setItemValue('to_location', to_loc_id);
            setup_delivery_path.details_form["single_form_" + active_object_id].setItemValue('label_to_location', to_loc);
        }
        
        var path_name = setup_delivery_path.dp_tab.tabs(active_tab_id).getText();
        if (call_from != null && call_from == 'flow_optimization' && path_name != get_locale_value('New') && typeof(setup_delivery_path.dp_treegrid.findCell(path_name)[0]) != 'undefined') {
            var row_id = setup_delivery_path.dp_treegrid.findCell(path_name)[0][0];
            setup_delivery_path.dp_treegrid.expandAll();
            setup_delivery_path.dp_treegrid.selectRowById(row_id);
        }
        
        setup_delivery_path.setup_delivery_path_layout.cells("b").progressOff();        
    }
    
    setup_delivery_path.close_path_detail = function(id) {
        //show_messagebox("Close path deatil of path id " + id);
        delete setup_delivery_path.pages[id];
        return true;
    }
    
    setup_delivery_path.grid_toolbar_click = function(id) {
        
        switch(id) {
            case 'add': 
                //show_messagebox("Add Single path");
                path_type = 'single';
                setup_delivery_path.load_form_detail();
                break;
            case 'add_gp': 
                path_type = 'group';
                //show_messagebox("Add Group path");
                setup_delivery_path.load_form_detail();
                break;
            case 'delete': 
                //show_messagebox("Delete path");
               if (selected_row != '') {   
                    var selected_row = setup_delivery_path.dp_treegrid.getSelectedRowId(); 
                    id_array = selected_row.split(',');                
                    arr_length = id_array.length;
                    path_type = setup_delivery_path.dp_treegrid.cells(id_array[0], setup_delivery_path.dp_treegrid.getColIndexById('priority')).getValue();
                    
                    var grid_xml = "<GridGroup><GridDelete>";
                    for (var i =0; i < arr_length; i++) {
                        var path_id = setup_delivery_path.dp_treegrid.cells(id_array[i], setup_delivery_path.dp_treegrid.getColIndexById('path_code')).getValue();
                        grid_xml = grid_xml + "<GridRow path_id" + "=\"" + path_id + "\"";
                       
                        grid_xml = grid_xml + " ></GridRow> ";
                      
                    }
                    grid_xml += "</GridDelete></GridGroup>";
                    
                    var data = {
                                "action": "spa_setup_delivery_path",
                                "flag": "d",
                                "grid_xml": grid_xml
                            };
        
                    adiha_post_data('confirm', data, '', '', 'delete_path', '');                 
             } else {
                 dhtmlx.alert({
                     title: "Alert",
                     type: "alert-error",
                     text: "Please select any path."
                 });
             }       
            break;                
            case 'excel':
                setup_delivery_path.dp_treegrid.toPDF(php_script_loc + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                break;                
            case 'pdf':
                setup_delivery_path.dp_treegrid.toPDF(php_script_loc + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                break;                
            case 'copy':   
                var selected_row = setup_delivery_path.dp_treegrid.getSelectedRowId();
                var path_ids = ''; 
                
                if (selected_row == null) {
                    dhtmlx.alert({
                         title: "Alert",
                         type: "alert-error",
                         text: "Select Path to copy."
                     });
                    Return;
                } /*else if(selected_row.indexOf(',') != -1) {
                    show_messagebox('Multiple path is not allowed to copy.');
                    Return;
                }*/              
                if (selected_row != null || (selected_row.indexOf(',') != -1) ) {   
                    var id_array = selected_row.split(',');                
                    var arr_length = id_array.length;
                    path_type = setup_delivery_path.dp_treegrid.cells(id_array[0], setup_delivery_path.dp_treegrid.getColIndexById('priority')).getValue();
                    
                    for(var i = 0; i < arr_length; i++) {
                        if (i > 0) path_ids = path_ids + ',';
                        path_ids = path_ids + setup_delivery_path.dp_treegrid.cells(id_array[i], setup_delivery_path.dp_treegrid.getColIndexById('path_code')).getValue();
                    }
                    
                    dhtmlx.message({
                        type: "confirm",
                        text: "Are you sure you want to copy?",
                        title: 'Confirmation',
                        callback: function(result) {
                           if (result) {
                                var data = {
                                        "action": "spa_setup_delivery_path",
                                        "flag": "c",
                                        "path_id": path_ids
                                    };
                
                                adiha_post_data('alert', data, '', '', 'refresh_tree', ''); 
                           }   
                        }  
                   });  
                } else {
                    show_messagebox('Select Path to copy.');
                }                
                
                break;
            case 'expand_collapse':
                
                if (expand_state == 0) {
                    open_all_group();
                } else {
                    close_all_group();
                }

                break; 
            default:
                show_messagebox(id);                    
        }
       
    } 
    
        open_all_group = function() {
            setup_delivery_path.dp_treegrid.expandAll();
            expand_state = 1;
        }

        /**
         *[closeAllInvoices Close All nodes of Invoice Grid]
         */
        close_all_group = function() {
            setup_delivery_path.dp_treegrid.collapseAll();
            expand_state = 0;
        }


   
    setup_delivery_path.save_click = function(id, is_confirm) {
       if(is_confirm == undefined) is_confirm = 0; 
       var active_tab_id = setup_delivery_path.dp_tab.getActiveTab();
       var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        switch(id) {
            case "save":
            
            var form_xml = "<FormXML ";
            
            data = setup_delivery_path.details_form["single_form_" + active_object_id].getFormData();
            
            
            
            var status = validate_form(setup_delivery_path.details_form["single_form_" + active_object_id]);
            
            if (status == false) {
                return;
            }
            
            path_type = 'single';            
            for (var a in data) {
                field_label = a;
                field_value = data[a];
                form_xml += " " + field_label + "=\"" + field_value + "\""; 
                
                if (field_label == 'groupPath' && field_value == 'y') {                            
                    path_type = 'group';
                } 
                
            }
            
            form_xml += "></FormXML>";
            //console.log(form_xml);
            var path_detail_xml = 'NULL';
            var grid_xml = 'NULL';
            var fuel_loss_xml = 'NULL';
            var rate_sch_arr_check = 0;            
            var rate_sch_arr = new Array();
            var path_detail_arr_check = 0;            
            var path_detail_arr = new Array();
            var err_msg = '';
            var mdq_grid_xml = 'NULL';
            
            if (path_type == 'group') {                               
                path_detail_xml = "<GridGroup>";
                setup_delivery_path.details_tabs["gp_path_" + active_object_id].clearSelection();
                for (var row_index=0; row_index < setup_delivery_path.details_tabs["gp_path_" + active_object_id].getRowsNum(); row_index++) {
                    if (jQuery.inArray(setup_delivery_path.details_tabs["gp_path_" + active_object_id].cells2(row_index,setup_delivery_path.details_tabs["gp_path_" + active_object_id].getColIndexById('path_id')).getValue(), path_detail_arr ) == -1) {
                        path_detail_arr.push(setup_delivery_path.details_tabs["gp_path_" + active_object_id].cells2(row_index,setup_delivery_path.details_tabs["gp_path_" + active_object_id].getColIndexById('path_id')).getValue());
                    } else {
                        path_detail_arr_check = 1;
                        err_msg = 'Duplicate data(Path Name) in Path Detail grid.';
                    }
                    
                    path_detail_xml = path_detail_xml + "<PSRecordset ";
                    for(var cellIndex = 0; cellIndex < setup_delivery_path.details_tabs["gp_path_" + active_object_id].getColumnsNum(); cellIndex++){
                        field_label = setup_delivery_path.details_tabs["gp_path_" + active_object_id].getColumnId(cellIndex);
                        field_value = setup_delivery_path.details_tabs["gp_path_" + active_object_id].cells2(row_index,cellIndex).getValue();
                        
                        if (field_label == 'path_id' && field_value == '') { 
                            show_messagebox('Please enter Path Name in grid.');
                            return;
                        }  
                        
                        path_detail_xml = path_detail_xml + " " + field_label + '="' + field_value + '"';
                    }
                    path_detail_xml = path_detail_xml + " ></PSRecordset> ";
                }
               path_detail_xml = path_detail_xml + "</GridGroup>"; 
                //console.log(path_detail_xml);
            } else {   
                var rate_schedule_exist = setup_delivery_path.details_tabs["rate_schedule_" + active_object_id].getAllRowIds();
                if(!rate_schedule_exist) {
                    show_messagebox("Please insert Contract/Counterparty in <b>Rate Schedule</b> Grid.");
                    return
                }
                var status = setup_delivery_path.validate_form_grid(setup_delivery_path.details_tabs["rate_schedule_" + active_object_id], '');
                if(!status) {
                    return
                }
                setup_delivery_path.details_tabs["rate_schedule_" + active_object_id].clearSelection();
                grid_xml = "<GridGroup>";
                var combination = '';
                for (var row_index=0; row_index < setup_delivery_path.details_tabs["rate_schedule_" + active_object_id].getRowsNum(); row_index++) {
                    combination = setup_delivery_path.details_tabs["rate_schedule_" + active_object_id].cells2(row_index,setup_delivery_path.details_tabs["rate_schedule_" + active_object_id].getColIndexById('counterparty_name')).getValue() + ' ' + setup_delivery_path.details_tabs["rate_schedule_" + active_object_id].cells2(row_index,setup_delivery_path.details_tabs["rate_schedule_" + active_object_id].getColIndexById('contract_id')).getValue();
                    if (jQuery.inArray(combination, rate_sch_arr ) == -1) {
                        rate_sch_arr.push(combination);
                    } else {
                        rate_sch_arr_check = 1;
                        err_msg = 'Duplicate data(Pipeline and Contract) in Path Detail grid.';
                    }
                    
                    grid_xml = grid_xml + "<PSRecordset ";
                    for(var cellIndex = 0; cellIndex < setup_delivery_path.details_tabs["rate_schedule_" + active_object_id].getColumnsNum(); cellIndex++){
                        field_label = setup_delivery_path.details_tabs["rate_schedule_" + active_object_id].getColumnId(cellIndex);
                        field_value = setup_delivery_path.details_tabs["rate_schedule_" + active_object_id].cells2(row_index,cellIndex).getValue();
                        
                        if (field_label == 'contract_id' && field_value == '') { 
                            show_messagebox("Please enter rate schedule 'Contract.'");
                            return;
                        }  
                        if (field_label == 'counterparty_name' && field_value == '') { 
                            show_messagebox("Please enter rate schedule 'Pipeline.'");
                        }  
                        /*if (field_label == 'rate_schedule_id' && field_value == '') {
                            dhtmlx.alert({
                                title:"Error!",
                                type:"alert-error",
                                text:"Please enter Rate Schedule."
                            });
                            return;
                        }   */            
                        grid_xml = grid_xml + " " + field_label + '="' + field_value + '"';
                    }
                    grid_xml = grid_xml + " ></PSRecordset> ";
                }
                grid_xml += "</GridGroup>";                      
                
                fuel_loss_xml = "<GridGroup>";
                var loss_factor = ''
                var shrinkage_curve = '';
                var fuel_arr_check = 0;            
                var fuel_arr = new Array();
                
                setup_delivery_path.details_tabs["fuel_shrinkage_" + active_object_id].clearSelection();
                for (var row_index=0; row_index < setup_delivery_path.details_tabs["fuel_shrinkage_" + active_object_id].getRowsNum(); row_index++) {
                    combination = setup_delivery_path.details_tabs["fuel_shrinkage_" + active_object_id].cells2(row_index,setup_delivery_path.details_tabs["fuel_shrinkage_" + active_object_id].getColIndexById('is_receipt')).getValue() + ' ' + setup_delivery_path.details_tabs["fuel_shrinkage_" + active_object_id].cells2(row_index,setup_delivery_path.details_tabs["fuel_shrinkage_" + active_object_id].getColIndexById('effective_date')).getValue() + ' ' + setup_delivery_path.details_tabs["fuel_shrinkage_" + active_object_id].cells2(row_index,setup_delivery_path.details_tabs["fuel_shrinkage_" + active_object_id].getColIndexById('loss_factor')).getValue();
                    if (jQuery.inArray(combination, fuel_arr ) == -1) {
                        fuel_arr.push(combination);
                    } else {
                        fuel_arr_check = 1;
                        err_msg = 'Duplicate data(Contract, Receipt/Delivery and Effective Date) in Fuel/Loss Factor grid.';
                    }
                    
                    fuel_loss_xml = fuel_loss_xml + "<PSRecordset ";
                    for(var cellIndex = 0; cellIndex < setup_delivery_path.details_tabs["fuel_shrinkage_" + active_object_id].getColumnsNum(); cellIndex++){
                        field_label = setup_delivery_path.details_tabs["fuel_shrinkage_" + active_object_id].getColumnId(cellIndex);
                        field_value = setup_delivery_path.details_tabs["fuel_shrinkage_" + active_object_id].cells2(row_index,cellIndex).getValue();
                        
                        //console.log(field_label + '_'+ field_value);
                        if (field_label == 'loss_factor' && (field_value < 0 || field_value > 1)) {
                            show_messagebox('Please enter Loss Factor in between 0 to 1.');
                        return;
                        } 
                        
                        if (field_label == 'loss_factor') {                            
                            loss_factor = trim(field_value)
                        }  
                          
                        if (field_label == 'shrinkage_curve_id') {                            
                            shrinkage_curve = field_value
                        }                                    
                        
                        fuel_loss_xml = fuel_loss_xml + " " + field_label + '="' + field_value + '"';
                    }
                    fuel_loss_xml = fuel_loss_xml + " ></PSRecordset> ";
                   
                    //check for loss factor or shrinkage curve
                    if (loss_factor == '' && shrinkage_curve == '') {
                        show_messagebox('Please enter Fuel/Loss or Fuel Loss Group.');
                        return;
                    } 
                    
                    if (isNaN(loss_factor) == true) {
                       show_messagebox('Please enter Loss Factor in between 0 to 1.');
                        return
                    }              
                }
                
                fuel_loss_xml += "</GridGroup>";
                
                setup_delivery_path.details_tabs["mdq_" + active_object_id].clearSelection();
                mdq_grid_xml = "<GridGroup>";
                var combination = '';
                var mdq_arr_check = 0;            
                var mdq_arr = new Array();
                var attached_obj = setup_delivery_path.details_tabs["mdq_" + active_object_id];
                var status = setup_delivery_path.validate_form_grid(attached_obj, 'MDQ');
                
                if (!status) 
                    return false;
                    
                for (var row_index=0; row_index < setup_delivery_path.details_tabs["mdq_" + active_object_id].getRowsNum(); row_index++) {
                    combination = setup_delivery_path.details_tabs["mdq_" + active_object_id].cells2(row_index,setup_delivery_path.details_tabs["mdq_" + active_object_id].getColIndexById('contract')).getValue() + ' ' + setup_delivery_path.details_tabs["mdq_" + active_object_id].cells2(row_index,setup_delivery_path.details_tabs["mdq_" + active_object_id].getColIndexById('effective_date')).getValue();
                    if (jQuery.inArray(combination, mdq_arr ) == -1) {
                        mdq_arr.push(combination);
                    } else {
                        mdq_arr_check = 1;
                        err_msg = 'Duplicate data(Contract and Effective Date) in MDQ grid.';
                    }
                    
                    mdq_grid_xml = mdq_grid_xml + "<PSRecordset ";
                    for(var cellIndex = 0; cellIndex < setup_delivery_path.details_tabs["mdq_" + active_object_id].getColumnsNum(); cellIndex++){
                        field_label = setup_delivery_path.details_tabs["mdq_" + active_object_id].getColumnId(cellIndex);
                        field_value = setup_delivery_path.details_tabs["mdq_" + active_object_id].cells2(row_index,cellIndex).getValue();
                                   
                        mdq_grid_xml = mdq_grid_xml + " " + field_label + '="' + field_value + '"';
                    }
                    mdq_grid_xml = mdq_grid_xml + " ></PSRecordset> ";
                }
                mdq_grid_xml += "</GridGroup>";   
            }
                   
            if (rate_sch_arr_check == 1 || fuel_arr_check == 1 || path_detail_arr_check == 1|| mdq_arr_check == 1) {
                show_messagebox(err_msg);
                return
            }
            var tab_name = setup_delivery_path.dp_tab.tabs(active_tab_id).getText();
            var flag;
            
            if (tab_name == get_locale_value('New')) { 
                flag = 'i';
            } else {
                flag = 'u';
            }
            
            if (path_detail_xml == '<GridGroup></GridGroup>'){
                path_detail_xml = 'NULL';
            }
          //alert(path_detail_xml);
            var data = {
                            "action": "spa_setup_delivery_path",
                            "flag": flag,
                            "form_xml": form_xml,
                            "rate_schedule_xml": grid_xml,
                            "fuel_loss_xml": fuel_loss_xml,
                            "group_path_xml": path_detail_xml,
                            "mdq_grid_xml": mdq_grid_xml,
                            "is_confirm": is_confirm
                        };


            if (is_delete_true[active_tab_id]) {
                confirm_messagebox(msg_confirm_delete, function(){
                    adiha_post_data('return_json', data, '', '', 'save_callback', '');
                    is_delete_true[active_tab_id] = false;
                });
            } else {
                adiha_post_data('return_json', data, '', '', 'save_callback', '');
            }
            
            break;
            default:
                show_messagebox(id);
        }
    }
    
    function save_callback(result) {
        var active_tab_id = setup_delivery_path.dp_tab.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;  
        var return_data = JSON.parse(result);
                
        if ((return_data[0].status).toLowerCase() == 'success') {
            var result_arr = return_data[0].recommendation.split(';'); 
            var new_id = result_arr[0];
            setup_delivery_path.details_form["single_form_" + active_object_id].setItemValue('path_id', new_id);
            var tab_name = result_arr[1]; //setup_delivery_path.details_form["single_form_" + active_object_id].getItemValue('path_name');
            setup_delivery_path.details_form["single_form_" + active_object_id].setItemValue('path_name', tab_name);
            setup_delivery_path.dp_tab.tabs(active_tab_id).setText(tab_name);
           success_call(return_data[0].message);

            if (call_from == 'flow_optimization') {
                parent.SetupDeliveryPath_SaveCallback('multi_match');
                return;
            } else if (call_from == 'flow_optimization_toggle') {
                parent.SetupDeliveryPath_SaveCallback('match_toggle');
            } else if (call_from == 'flow_optimization_match') {
                parent.SetupDeliveryPath_SaveCallback(new_id);
            }

            data = {
                    "action": "spa_setup_delivery_path",
                    "flag": "k",
                    "path_id":new_id
                    };
            result = adiha_post_data('return_array', data, '', '', 'setup_delivery_path.deal_id_select'); 

            refresh_tree();
            if (path_type == 'group') {
               refresh_grid_gp_path_detail(); 
            } else {
                refresh_grid_rate_schedule();
                refresh_grid_fuel_shrinkage();
                refresh_grid_mdq();
            }
            
        } else if ((return_data[0].status).toLowerCase() == 'error') {
            if (return_data[0].recommendation == 'form') {
                confirm_messagebox('Total MDQ level assigned exceeds the available MDQ for the selected contract. Do you want to continue?',function(){
                     setup_delivery_path.save_click("save", "1");
                });
            } else if (return_data[0].recommendation == 'Rate Schedule') {
                dhtmlx.alert({
                    title: 'Error!',
                   type: "alert-error",
                   text: return_data[0].message
                });
            }
        }
    }
    
    function reset_filters(grid) {
        for (var i=0; i < grid.getColumnCount(); i++) {
          var filter = grid.getFilterElement(i);
          if (filter) filter.value = '';
        }
    }
    
    function refresh_tree() {       
        var sp_url = "EXEC spa_setup_delivery_path @flag='g'"
        var sql_param = {
                "sql":sp_url,
                "grid_type":"tg",
                "grouping_column": grouping_column
            };
        sql_param = $.param(sql_param);
        var sql_url = js_data_collector_url + "&" + sql_param;
        setup_delivery_path.dp_treegrid.clearAll();
        setup_delivery_path.dp_treegrid.enableHeaderMenu();
               
        //reset_filters(setup_delivery_path.dp_treegrid); 
        
        var grouping_col = (path_type == 'group') ? 'GROUP PATH' : 'SINGLE PATH';
        setup_delivery_path.dp_treegrid.load(sql_url, function(){    
            setup_delivery_path.dp_treegrid.filterByAll();
            grouping_col = grouping_col.replace(/\s+/g,"");
            setup_delivery_path.dp_treegrid.openItem(grouping_col);            
        });
        
        set_setup_delivery_path_menu_disabled('delete', false);
        set_setup_delivery_path_menu_disabled('copy', false);
        
        return true;    
    }
    
    function delete_path(response_data) {
        if(response_data[0].errorcode != 'Success') {            
           return; 
        }  
        var selected_row = setup_delivery_path.dp_treegrid.getSelectedRowId();
        id_array = selected_row.split(',');                
        arr_length = id_array.length;
        for (var i = 0; i < arr_length; i++) {
            var path_id = setup_delivery_path.dp_treegrid.cells(id_array[i], setup_delivery_path.dp_treegrid.getColIndexById('path_code')).getValue(); 
             if (setup_delivery_path.pages['tab_' + path_id]) {           
                setup_delivery_path.dp_tab.tabs('tab_' + path_id).close(); 
                delete setup_delivery_path.pages['tab_' + path_id]; 
            }            
        }
               
        refresh_tree();  
    }
    
    /*
    Add Group path Detail
    */
    function load_group_path_detail () {
        setup_delivery_path.setup_delivery_path_layout.cells("b").progressOn();
        var active_tab_id = setup_delivery_path.dp_tab.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id; 
         
        setup_delivery_path["delivery_path_tab_" + active_object_id] = setup_delivery_path["inner_tab_layout_" + active_object_id].cells('a').attachTabbar();
        // attach tab 
        tab_id = 'detail_tab_group_path';// + active_object_id; 
        tab_json = '{mode: "bottom",arrows_mode: "auto",tabs: [{"id":"' + tab_id + '","text":get_locale_value("Path Detail"),"active":"true"}]}';
        setup_delivery_path["delivery_path_tab_" + active_object_id].loadStruct(tab_json);
              
        setup_delivery_path["inner_tab_gp_layout_" + active_object_id] = setup_delivery_path["delivery_path_tab_" + active_object_id].cells(tab_id).attachLayout(
            "2E"
        );
        
        setup_delivery_path["inner_tab_gp_layout_" + active_object_id].cells('a').setHeight(100);
        setup_delivery_path["inner_tab_gp_layout_" + active_object_id].cells('a').hideHeader();
        setup_delivery_path["inner_tab_gp_layout_" + active_object_id].cells('b').hideHeader();
        setup_delivery_path.details_form["single_form_" + active_object_id] = setup_delivery_path["inner_tab_gp_layout_" + active_object_id].cells('a').attachForm();
        var gp_form_json = [{type: "settings", position: "label-top", labelWidth: 170, inputWidth: 150},
                            {type:"hidden",  name: "path_id", label:"Path ID" }                            
                            , {type:"hidden",  name: "groupPath", label:"Group path", value:"y"}
                            , {type:"block", width:500, offsetTop: 20, list:[
                             {type:"input",  name: "path_name", label:"Path Name",required:true,validate:"NotEmpty", userdata:{validation_message:"Required Field"}}
                            , {type: "newcolumn"},
                              {type:"checkbox",  name: "isactive", label:"Active", checked:true, position: "label-right",offsetTop: 30}
                            
                            ]}
                            ];
                            
        setup_delivery_path.details_form["single_form_" + active_object_id].loadStruct(get_form_json_locale(gp_form_json));
                        
        var path_id = 1;//'NULL';
        
        var tab_name = setup_delivery_path.dp_tab.tabs(active_tab_id).getText();
            
        if (tab_name != get_locale_value('New')) {  
            path_id = active_object_id;
            path_name = setup_delivery_path.dp_tab.tabs(active_tab_id).getText();
            
             var data = {
                            "action": "spa_setup_delivery_path",
                            "flag": "a",
                            "path_id": path_id
                        };
            
            adiha_post_data('return_json', data, '', '', 'callback_group_path_detail', '');
        }            
        
        //Attach toolbar in cell b
        var gp_path_toolbar =   [
                                    {id:"g1", text:"Edit", img:"edit.gif", items:[
                                        {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add"},
                                        {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete"}
                                    ]},
                                    {id:"g2", text:"Export", img:"export.gif", items:[
                                        {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                                        {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                                    ]}   
                                    ];
        
        setup_delivery_path["gp_path_toolbar_" + active_object_id] = setup_delivery_path["inner_tab_gp_layout_" + active_object_id].cells('b').attachMenu();
        setup_delivery_path["gp_path_toolbar_" + active_object_id].setIconsPath(image_path + 'dhxmenu_web/');
        setup_delivery_path["gp_path_toolbar_" + active_object_id].loadStruct(gp_path_toolbar);
        
        if (!edit_permission) {
            setup_delivery_path["gp_path_toolbar_" + active_object_id].setItemDisabled('add');
            setup_delivery_path["gp_path_toolbar_" + active_object_id].setItemDisabled('delete');
        } else {
          setup_delivery_path["gp_path_toolbar_" + active_object_id].setItemDisabled('delete');  
        }
         
        setup_delivery_path["gp_path_toolbar_" + active_object_id].attachEvent('onClick', function(id){
            switch(id) {
                case "add":
                    var new_id = (new Date()).valueOf();
                    setup_delivery_path.details_tabs["gp_path_" + active_object_id].addRow(new_id, "");
                    break;
                case "delete":
                    msg_confirm_delete = "Some data has been deleted from Path Detail. Are you sure you want to save?";
                    is_delete_true[active_tab_id] = true;
                    var row_id = setup_delivery_path.details_tabs["gp_path_" + active_object_id].getSelectedRowId();
                    setup_delivery_path.details_tabs["gp_path_" + active_object_id].deleteRow(row_id);
                    setup_delivery_path["gp_path_toolbar_" + active_object_id].setItemDisabled('delete');
                    break;
                case "excel":
                    setup_delivery_path.details_tabs["gp_path_" + active_object_id].toExcel(php_script_loc + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                    break;
                case "pdf":
                    setup_delivery_path.details_tabs["gp_path_" + active_object_id].toPDF(php_script_loc +'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                    break;
            }
        });
        
        //Creating the path detail grid
        setup_delivery_path.details_tabs["gp_path_" + active_object_id] = setup_delivery_path["inner_tab_gp_layout_" + active_object_id].cells('b').attachGrid();
        setup_delivery_path.details_tabs["gp_path_" + active_object_id].setHeader(get_locale_value('Path ID,Path Name, Path Code, Receipt Location, Delivery Location,Pipeline,Contract,MDQ,Priority', true)); 
        setup_delivery_path.details_tabs["gp_path_" + active_object_id].setColumnIds("delivery_path_detail_id,path_id,path_code,from_location,to_location,counterparty_name,contract_name,mdq,priority");
        setup_delivery_path.details_tabs["gp_path_" + active_object_id].setColTypes("ro,combo,link,ro,ro,ro,ro,ro,ro");   
        setup_delivery_path.details_tabs["gp_path_" + active_object_id].setColSorting('str,str,str,str,str,str,str,str,str');      
        setup_delivery_path.details_tabs["gp_path_" + active_object_id].setInitWidths('0,150,150,150,150,150,150,150,150'); 
        setup_delivery_path.details_tabs["gp_path_" + active_object_id].attachHeader(",#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter");
        setup_delivery_path.details_tabs["gp_path_" + active_object_id].init(); 
        setup_delivery_path.details_tabs["gp_path_" + active_object_id].setColumnsVisibility('true,false,false,false,false,false,false,true,false');
        setup_delivery_path.details_tabs["gp_path_" + active_object_id].attachEvent("onRowSelect", function(id,ind){ 
            if (edit_permission) {                   
                setup_delivery_path["gp_path_toolbar_" + active_object_id].setItemEnabled('delete');         
            } else {
                setup_delivery_path["gp_path_toolbar_" + active_object_id].setItemDisabled('delete');
            }
            
        }); 
         //Loading dropdown for Path in grid
        var cm_param = {
                            "action": "[spa_setup_delivery_path]", 
                            "flag": "l",
                            "is_group_path": "n"
                        };

        cm_param = $.param(cm_param);
        var url = js_dropdown_connector_url + '&' + cm_param;
        var combo_obj = setup_delivery_path.details_tabs["gp_path_" + active_object_id].getColumnCombo(1); 
        combo_obj.enableFilteringMode("between", null, false); 
        
         combo_obj.attachEvent("onChange", function (name, value){
                var sp_string = "EXEC spa_setup_delivery_path @flag='a', @path_id=" + name;           
                var data_for_post =  { "sp_string": sp_string};
                adiha_post_data('return_array', data_for_post, 's', 'e', 'get_path_detail');
                
            }); 
        
        combo_obj.load(url, function(){refresh_grid_gp_path_detail()});
        setup_delivery_path.setup_delivery_path_layout.cells("b").progressOff();        
    }
    
    function refresh_grid_gp_path_detail(){
        var active_tab_id = setup_delivery_path.dp_tab.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id; 
        var path_id = setup_delivery_path.details_form["single_form_" + active_object_id].getItemValue('path_id');   
        var flag = 'p';
        var sql_param = {
            "flag": flag,
            "action":"spa_setup_delivery_path",
            "grid_type":"g",
            "path_id": path_id, 
            "is_group_path": "y"
        };
        sql_param = $.param(sql_param);
        var sql_url = js_data_collector_url + "&" + sql_param;
        setup_delivery_path.details_tabs["gp_path_" + active_object_id].clearAll();
        setup_delivery_path.details_tabs["gp_path_" + active_object_id].load(sql_url, function(){
            setup_delivery_path.details_tabs["gp_path_" + active_object_id].filterByAll();
        });
    }
    
    //json
    function callback_group_path_detail(result) {
        var return_data = JSON.parse(result);
        var active_tab_id = setup_delivery_path.dp_tab.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id; 
        setup_delivery_path.details_form["single_form_" + active_object_id].setItemValue('path_id', return_data[0].path_id);
        setup_delivery_path.details_form["single_form_" + active_object_id].setItemValue('path_name', return_data[0].path_name);
        if (return_data[0].isactive == 'y') {
            setup_delivery_path.details_form["single_form_" + active_object_id].checkItem('isactive');
        } else {
            setup_delivery_path.details_form["single_form_" + active_object_id].uncheckItem('isactive');
        }
        
     }   
            
    function get_path_detail(result) {    
        var active_tab_id = setup_delivery_path.dp_tab.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;         
        var row_id = setup_delivery_path.details_tabs["gp_path_" + active_object_id].getSelectedRowId();        
        
        for (var i = 1; i < result[0].length - 1; i++) {
            setup_delivery_path.details_tabs["gp_path_" + active_object_id].cells(row_id, i+1).setValue(result[0][i]);
        } 
    }
     /*
     * Load single path detail
     */
    function load_single_path_detail(tab_id, form_json) {
        var active_tab_id = setup_delivery_path.dp_tab.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;   
        var selected_row = setup_delivery_path.dp_treegrid.getSelectedRowId(); 
        
         setup_delivery_path.details_form["layout_" + active_object_id] = setup_delivery_path["delivery_path_tab_" + active_object_id].cells(tab_id).attachLayout({
                    pattern: "2E",
                    cells: [
                        {id: "a", text: "Path Detail", header: false},
                        {id: "b", text: "Rate Schedule Detail"}
                    ]});



        setup_delivery_path.details_form["single_form_" + active_object_id] = setup_delivery_path.details_form["layout_" + active_object_id].cells('a').attachForm();
        
        if (form_json) {
            setup_delivery_path.details_form["single_form_" + active_object_id].loadStruct(form_json, function(){
                var form_name = 'setup_delivery_path.details_form["single_form_" + ' + active_object_id + ']';
                attach_browse_event(form_name, application_function_id);
            });
        }
        setup_delivery_path.details_form["single_form_" + active_object_id].setValidation('mdq', ValidatePositiveInteger);
        //setup_delivery_path.details_form["single_form_" + active_object_id].disableItem("counterParty");  
        if (call_from == 'transportation_contract') {
            //disable contract dropdown
            var trans_contract_id = '<?php echo $trans_contract_id; ?>';    //This is contract id passed from transportation contract.            
            var combo_obj_contract = setup_delivery_path.details_form["single_form_" + active_object_id].getCombo('CONTRACT');
            var opt = combo_obj_contract.getIndexByValue(trans_contract_id);
            var opt_index = (opt == null) ? 0 : opt;
            combo_obj_contract.selectOption(opt_index); 
            
            setup_delivery_path.details_form["single_form_" + active_object_id].disableItem('CONTRACT'); 
        }
        
        var mdq = setup_delivery_path.details_form["single_form_" + active_object_id].getItemLabel("mdq"); 
        var mdq_val = setup_delivery_path.details_form["single_form_" + active_object_id].getItemValue("mdq");
        
        var tab_name = setup_delivery_path.dp_tab.tabs(active_tab_id).getText();
            
        if (tab_name == get_locale_value('New')) {
            var combo_obj_priority = setup_delivery_path.details_form["single_form_" + active_object_id].getCombo('priority');
            var opt = combo_obj_priority.getOptionByLabel('Point-Point');
            var opt_index = (opt == null) ? 0 : opt['index'];
            combo_obj_priority.selectOption(opt_index);            
        }
         
         //Menu for the Constraints Grid
         var rate_schedule_toolbar =   [
                                     {id:"t1", text:"Edit", img:"edit.gif", items:[
                                         {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add"},
                                         {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete"}
                                     ]},
                                     {id:"t2", text:"Export", img:"export.gif", items:[
                                         {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                                         {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                                     ]}   
                                     ];
         
         setup_delivery_path["rate_schedule_toolbar_" + active_object_id] = setup_delivery_path.details_form["layout_" + active_object_id].cells('b').attachMenu();
         setup_delivery_path["rate_schedule_toolbar_" + active_object_id].setIconsPath(image_path + 'dhxmenu_web/');
         setup_delivery_path["rate_schedule_toolbar_" + active_object_id].loadStruct(rate_schedule_toolbar);
         
         if (!edit_permission) {
             setup_delivery_path["rate_schedule_toolbar_" + active_object_id].setItemDisabled('add');
             setup_delivery_path["rate_schedule_toolbar_" + active_object_id].setItemDisabled('delete');
         } else {
             setup_delivery_path["rate_schedule_toolbar_" + active_object_id].setItemDisabled('delete');
         }        
         setup_delivery_path["rate_schedule_toolbar_" + active_object_id].attachEvent('onClick', function(id){
             switch(id) {
                 case "add":
                    var new_id = (new Date()).valueOf(); 
                    setup_delivery_path.details_tabs["rate_schedule_" + active_object_id].addRow(new_id,"");
                break;
                 case "delete":
                     msg_confirm_delete = "Some data has been deleted from Rate Schedule. Are you sure you want to save?";
                     is_delete_true[active_tab_id] = true;
                     var row_id = setup_delivery_path.details_tabs["rate_schedule_" + active_object_id].getSelectedRowId();
                     setup_delivery_path.details_tabs["rate_schedule_" + active_object_id].cells(row_id, setup_delivery_path.details_tabs["rate_schedule_" + active_object_id].getColIndexById('counterparty_contract_rate_schedule_id')).getValue();
                     setup_delivery_path.details_tabs["rate_schedule_" + active_object_id].deleteRow(row_id);

                     break;
                 case "excel":
                     setup_delivery_path.details_tabs["rate_schedule_" + active_object_id].toExcel(php_script_loc + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                     break;
                 case "pdf":
                     setup_delivery_path.details_tabs["rate_schedule_" + active_object_id].toPDF(php_script_loc +'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                     break;
             }
         });
         
         //Creating the constraints grid
         setup_delivery_path.details_tabs["rate_schedule_" + active_object_id] = setup_delivery_path.details_form["layout_" + active_object_id].cells('b').attachGrid();
         setup_delivery_path.details_tabs["rate_schedule_" + active_object_id].setHeader(get_locale_value('ID,Pipeline, Contract, Rate Schedule, Rank', true)); 
         setup_delivery_path.details_tabs["rate_schedule_" + active_object_id].setColumnIds("counterparty_contract_rate_schedule_id,counterparty_name,contract_id,rate_schedule_id,rank");
         setup_delivery_path.details_tabs["rate_schedule_" + active_object_id].setColTypes("ro,combo,combo,combo,combo");        
         setup_delivery_path.details_tabs["rate_schedule_" + active_object_id].setInitWidths('0,180,180,180,180'); 
         setup_delivery_path.details_tabs["rate_schedule_" + active_object_id].enableColumnAutoSize(true)
         setup_delivery_path.details_tabs["rate_schedule_" + active_object_id].setColSorting('str,str,str,str,str'); 
         setup_delivery_path.details_tabs["rate_schedule_" + active_object_id].attachHeader("#text_filter,#text_filter,#text_filter,#text_filter,#text_filter");
      
         setup_delivery_path.details_tabs["rate_schedule_" + active_object_id].setColumnsVisibility('true,false,false,false,false');        
         setup_delivery_path.details_tabs["rate_schedule_" + active_object_id].attachEvent("onRowSelect", function(id,ind){ 
             if (edit_permission) {                   
                 setup_delivery_path["rate_schedule_toolbar_" + active_object_id].setItemEnabled('delete');         
             } else {
                 setup_delivery_path["rate_schedule_toolbar_" + active_object_id].setItemDisabled('delete');
             }
             
        });

         setup_delivery_path.details_tabs["rate_schedule_" + active_object_id].init(); 
        
                  
         //Loading dropdown for pipeline on grid
        var cm_param = {
                            "action": 'spa_source_counterparty_maintain' ,
                            "flag" : 'c',
                            "type_of_entity" : -10021 //type pipeline
                        };


        cm_param = $.param(cm_param);
        var url1 = js_dropdown_connector_url + '&' + cm_param;
        var combo_obj0 = setup_delivery_path.details_tabs["rate_schedule_" + active_object_id].getColumnCombo(1);                
        combo_obj0.enableFilteringMode("between", null, false);
        combo_obj0.load(url1);




         //Loading dropdown for Contract in grid
         var cm_param = {
                             "action": 'spa_contract_group' ,
                             "flag" : 'p'
                         };

         cm_param = $.param(cm_param);
         var url1 = js_dropdown_connector_url + '&' + cm_param;
         var combo_obj1 = setup_delivery_path.details_tabs["rate_schedule_" + active_object_id].getColumnCombo(2);                
         combo_obj1.enableFilteringMode("between", null, false);
         combo_obj1.load(url1);
         
         //Loading dropdown for Rate Schedule in grid
         var cm_param = {
                             "action": "[spa_transportation_rate_schedule]", 
                             "flag": "c" 
                         };

         cm_param = $.param(cm_param);
         var url2 =  js_dropdown_connector_url + '&' + cm_param;
         var combo_obj2 = setup_delivery_path.details_tabs["rate_schedule_" + active_object_id].getColumnCombo(3);                
         combo_obj2.enableFilteringMode("between", null, false);
         combo_obj2.load(url2);
         
         //Loading dropdown for Rank in grid
         var cm_param = {
                              "action": "[spa_StaticDataValues]", 
                             "flag": "h",
                             "type_id": "32100"
                         };

         cm_param = $.param(cm_param);
         var url3 =  js_dropdown_connector_url + '&' + cm_param;
         var combo_obj3 = setup_delivery_path.details_tabs["rate_schedule_" + active_object_id].getColumnCombo(4);
         combo_obj3.enableFilteringMode("between", null, false);
         combo_obj3.load(url3, function(){refresh_grid_rate_schedule();});
         
        /*setup_delivery_path.details_tabs["rate_schedule_" + active_object_id].attachEvent("onXLE", function(grid_obj,count){
            var is_new = active_tab_id.indexOf("tab_") == -1 ? true : false;
            var tab_name = setup_delivery_path.dp_tab.tabs(active_tab_id).getText();
            if(tab_name == 'New' && is_new == true) {
                var sel_contract = combo_obj1.getOptionByIndex(1)['value'];
                var sel_pipeline = combo_obj0.getOptionByIndex(1)['value'];
                var new_id = (new Date()).valueOf(); 
                setup_delivery_path.details_tabs["rate_schedule_" + active_object_id].addRow(new_id,['',sel_pipeline,sel_contract,'','']);
                    
            }
        });*/
    }
    
    
    function refresh_grid_rate_schedule() {
        var active_tab_id = setup_delivery_path.dp_tab.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id; 
        var path_id = setup_delivery_path.details_form["single_form_" + active_object_id].getItemValue('path_id');
        var counterparty_id = setup_delivery_path.details_form["single_form_" + active_object_id].getItemValue('counterParty');
        var flag = 'g';
        var is_new = active_tab_id.indexOf("tab_") == -1 ? true : false;
        var tab_name = setup_delivery_path.dp_tab.tabs(active_tab_id).getText();
        var inset_update_mode = 'u';
        if(tab_name == get_locale_value('New') && is_new == true)
                inset_update_mode = 'i';

        var sql_param = {
            "flag": flag,
            "action":"spa_counterparty_contract_rate_schedule",
            "grid_type":"g",
            "path_id": path_id,
            "mode": inset_update_mode
        };
        sql_param = $.param(sql_param);
        var sql_url = js_data_collector_url + "&" + sql_param;
        setup_delivery_path.details_tabs["rate_schedule_" + active_object_id].clearAll();
        setup_delivery_path.details_tabs["rate_schedule_" + active_object_id].load(sql_url, function(){
            setup_delivery_path.details_tabs["rate_schedule_" + active_object_id].filterByAll();
        });   
    }
    
    function load_fuel_factor(tab_id) {
       var image_path = '<?php echo $image_path; ?>';
       var active_tab_id = setup_delivery_path.dp_tab.getActiveTab();
       var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id; 
        //Menu for the Fuel Shrinkage Grid
        var fuel_shrinkage_toolbar =   [
                                    {id:"f1", text:"Edit", img:"edit.gif", items:[
                                        {id:"add_fuel", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add"},
                                        {id:"delete_fuel", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete"}
                                    ]},
                                    {id:"f2", text:"Export", img:"export.gif", items:[
                                        {id:"excel_fuel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                                        {id:"pdf_fuel", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                                    ]}   
                                    ];
        
        setup_delivery_path["fuel_shrinkage_toolbar_" + active_object_id] = setup_delivery_path["delivery_path_tab_" + active_object_id].cells(tab_id).attachMenu();
        setup_delivery_path["fuel_shrinkage_toolbar_" + active_object_id].setIconsPath(image_path + 'dhxmenu_web/');
        setup_delivery_path["fuel_shrinkage_toolbar_" + active_object_id].loadStruct(fuel_shrinkage_toolbar);
        
        if (!edit_permission) {
            setup_delivery_path["fuel_shrinkage_toolbar_" + active_object_id].setItemDisabled('add_fuel');
            setup_delivery_path["fuel_shrinkage_toolbar_" + active_object_id].setItemDisabled('delete_fuel');
        } else {
            setup_delivery_path["fuel_shrinkage_toolbar_" + active_object_id].setItemDisabled('delete_fuel');
        }
        
        setup_delivery_path["fuel_shrinkage_toolbar_" + active_object_id].attachEvent('onClick', function(id){
            switch(id) {
                case "add_fuel":
                    var new_id = (new Date()).valueOf();
                    setup_delivery_path.details_tabs["fuel_shrinkage_" + active_object_id].addRow(new_id,['','','','','','r',new Date()]);
                    break;
                case "delete_fuel":
                    msg_confirm_delete = "Some data has been deleted from Fuel/Loss Factor. Are you sure you want to save?";
                    is_delete_true[active_tab_id] = true;
                    var row_id = setup_delivery_path.details_tabs["fuel_shrinkage_" + active_object_id].getSelectedRowId();
                    setup_delivery_path.details_tabs["fuel_shrinkage_" + active_object_id].deleteRow(row_id);
                    setup_delivery_path["fuel_shrinkage_toolbar_" + active_object_id].setItemDisabled('delete_fuel');
                    break;
                case "excel_fuel":
                    setup_delivery_path.details_tabs["fuel_shrinkage_" + active_object_id].toExcel(php_script_loc + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                    break;
                case "pdf_fuel":
                    setup_delivery_path.details_tabs["fuel_shrinkage_" + active_object_id].toPDF(php_script_loc +'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                    break;
            }
        });
        
        //Creating the fuel Shrinkage grid
        setup_delivery_path.details_tabs["fuel_shrinkage_" + active_object_id] = setup_delivery_path["delivery_path_tab_" + active_object_id].cells(tab_id).attachGrid();
        setup_delivery_path.details_tabs["fuel_shrinkage_" + active_object_id].setHeader(get_locale_value('ID,Path ID, Contract,Fuel/Loss, Fuel Loss Group,Receipt/Delivery, Effective Date', true)); 
        setup_delivery_path.details_tabs["fuel_shrinkage_" + active_object_id].setColumnIds("path_loss_shrinkage_id,path_id,contract_id,loss_factor,shrinkage_curve_id,is_receipt,effective_date");
        setup_delivery_path.details_tabs["fuel_shrinkage_" + active_object_id].setColTypes("ro,ro,combo,ed_no,combo,combo,dhxCalendarA");
        setup_delivery_path.details_tabs["fuel_shrinkage_" + active_object_id].setInitWidths('0,0,180,180,180,180,180'); 
        setup_delivery_path.details_tabs["fuel_shrinkage_" + active_object_id].setDateFormat(user_date_format, '%Y-%m-%d');        
        setup_delivery_path.details_tabs["fuel_shrinkage_" + active_object_id].setColValidators(",,NotEmpty,ValidNumeric,,NotEmpty,ValidDate");
        setup_delivery_path.details_tabs["fuel_shrinkage_" + active_object_id].setColSorting('str,str,str,str,str,str,str'); 
        setup_delivery_path.details_tabs["fuel_shrinkage_" + active_object_id].attachEvent("onValidationError",function(id,ind,value){
            validation_check = 1;
            var message = "Invalid Data";
            setup_delivery_path.details_tabs["fuel_shrinkage_" + active_object_id].cells(id,ind).setAttribute("validation", message);
            return false;
        });
        
        setup_delivery_path.details_tabs["fuel_shrinkage_" + active_object_id].attachEvent("onValidationCorrect",function(id,ind,value){
            validation_check = 0;
            setup_delivery_path.details_tabs["fuel_shrinkage_" + active_object_id].cells(id,ind).setAttribute("validation", "");
            return true;
        });
        setup_delivery_path.details_tabs["fuel_shrinkage_" + active_object_id].init(); 
        setup_delivery_path.details_tabs["fuel_shrinkage_" + active_object_id].setColumnsVisibility('true,true,false,false,false,false,false'); 
        setup_delivery_path.details_tabs["fuel_shrinkage_" + active_object_id].attachHeader("#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter");
        setup_delivery_path.details_tabs["fuel_shrinkage_" + active_object_id].attachEvent("onRowSelect", function(id,ind){ 
            if (edit_permission) {                   
                setup_delivery_path["fuel_shrinkage_toolbar_" + active_object_id].setItemEnabled('delete_fuel');         
            } else {
                setup_delivery_path["fuel_shrinkage_toolbar_" + active_object_id].setItemDisabled('delete_fuel');
            }
            
        }); 
         //Loading dropdown for shrinkage curve in grid
        var cm_param = {
                            "action": "spa_route_group",
                            "flag": 'h'
                        };

        cm_param = $.param(cm_param);
        var url4 = js_dropdown_connector_url + '&' + cm_param;
        var combo_obj4 = setup_delivery_path.details_tabs["fuel_shrinkage_" + active_object_id].getColumnCombo(4);          
        combo_obj4.enableFilteringMode("between", null, false);
        combo_obj4.load(url4);
        
        //Loading dropdown for Receipt/Delivery in grid
        var cm_param = {
                            "action": "('SELECT ''r'', ''Receipt'' UNION SELECT ''d'', ''Delivery''')", 
                            "has_blank_option": "false"
                        };

        cm_param = $.param(cm_param);
        var url3 = js_dropdown_connector_url + '&' + cm_param;
        var combo_obj3 = setup_delivery_path.details_tabs["fuel_shrinkage_" + active_object_id].getColumnCombo(5); 
        combo_obj3.enableFilteringMode("between", null, false);
        combo_obj3.load(url3, function(){refresh_grid_fuel_shrinkage()});

        //add contract //EXEC spa_contract_group @flag='p'
        var cm_param = {
                    "action": "spa_contract_group",
                    "flag": 'p'
                };

        cm_param = $.param(cm_param);
        var url4 = js_dropdown_connector_url + '&' + cm_param;
        var combo_obj4 = setup_delivery_path.details_tabs["fuel_shrinkage_" + active_object_id].getColumnCombo(2);          
        combo_obj4.enableFilteringMode("between", null, false);
        combo_obj4.load(url4);
    }
    
    function refresh_grid_fuel_shrinkage() {
        var active_tab_id = setup_delivery_path.dp_tab.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id; 
        var path_id = setup_delivery_path.details_form["single_form_" + active_object_id].getItemValue('path_id');        
        var flag = 'f';
        var sql_param = {
            "flag": flag,
            "action":"spa_setup_delivery_path",
            "grid_type":"g",
            "path_id": path_id
        };
        sql_param = $.param(sql_param);
        var sql_url = js_data_collector_url + "&" + sql_param;
        setup_delivery_path.details_tabs["fuel_shrinkage_" + active_object_id].clearAll();
        setup_delivery_path.details_tabs["fuel_shrinkage_" + active_object_id].load(sql_url, function() {
            setup_delivery_path.details_tabs["fuel_shrinkage_" + active_object_id].filterByAll();
        }); 
        
    }
    
    function load_mdq_grid(tab_id) {
       var active_tab_id = setup_delivery_path.dp_tab.getActiveTab();
       var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id; 
        //Menu for the MDQ Grid
        var mdq_toolbar =   [
                                    {id:"m1", text:"Edit", img:"edit.gif", items:[
                                        {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add"},
                                        {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete"}
                                    ]},
                                    {id:"m2", text:"Export", img:"export.gif", items:[
                                        {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                                        {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                                    ]}   
                                    ];
        
        setup_delivery_path["mdq_toolbar" + active_object_id] = setup_delivery_path["delivery_path_tab_" + active_object_id].cells(tab_id).attachMenu();
        setup_delivery_path["mdq_toolbar" + active_object_id].setIconsPath(js_image_path  + 'dhxmenu_web/');
        setup_delivery_path["mdq_toolbar" + active_object_id].loadStruct(mdq_toolbar);
        
        if (!edit_permission) {
            setup_delivery_path["mdq_toolbar" + active_object_id].setItemDisabled('add');
            setup_delivery_path["mdq_toolbar" + active_object_id].setItemDisabled('delete');
        } else {
            setup_delivery_path["mdq_toolbar" + active_object_id].setItemDisabled('delete');
        }
        
        setup_delivery_path["mdq_toolbar" + active_object_id].attachEvent('onClick', function(id){
            switch(id) {
                case "add":
                    var current_date = yyyy + '-' + mm + '-' + dd;
                    var new_id = (new Date()).valueOf();
                   // var combo_obj_contract = setup_delivery_path.details_form["single_form_" + active_object_id].getCombo('CONTRACT');
                    //var contract_name = combo_obj_contract.getComboText();
                    setup_delivery_path.details_tabs["mdq_" + active_object_id].addRow(new_id,['','','','','','d']);
                    setup_delivery_path.details_tabs["mdq_" + active_object_id].forEachRow(function(row){
                        setup_delivery_path.details_tabs["mdq_" + active_object_id].forEachCell(row,function(cellObj,ind){
                            setup_delivery_path.details_tabs["mdq_" + active_object_id].validateCell(row,ind)
                        });
                    });
                    break;
                case "delete":
                    msg_confirm_delete = "Some data has been deleted from MDQ. Are you sure you want to save?";
                    is_delete_true[active_tab_id] = true;
                    var row_id = setup_delivery_path.details_tabs["mdq_" + active_object_id].getSelectedRowId();
                    setup_delivery_path.details_tabs["mdq_" + active_object_id].deleteRow(row_id);
                    setup_delivery_path["mdq_toolbar" + active_object_id].setItemDisabled('delete');
                    break;
                case "excel":
                    setup_delivery_path.details_tabs["mdq_" + active_object_id].toExcel(php_script_loc + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                    break;
                case "pdf":
                    setup_delivery_path.details_tabs["mdq_" + active_object_id].toPDF(php_script_loc +'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                    break;
            }
        });
        
        //Creating the fuel mdq grid
        setup_delivery_path.details_tabs["mdq_" + active_object_id] = setup_delivery_path["delivery_path_tab_" + active_object_id].cells(tab_id).attachGrid();
        setup_delivery_path.details_tabs["mdq_" + active_object_id].setHeader(get_locale_value('ID, Path ID, Contract, Effective Date, MDQ, Rec/Del', true));
        setup_delivery_path.details_tabs["mdq_" + active_object_id].setColumnIds("delivery_path_mdq_id,path_id,contract,effective_date,mdq,rec_del");
        setup_delivery_path.details_tabs["mdq_" + active_object_id].setColTypes("ro,ro,ro,dhxCalendarA,ed_no,combo");
        setup_delivery_path.details_tabs["mdq_" + active_object_id].setInitWidths('50,50,180,180,180,180');
        setup_delivery_path.details_tabs["mdq_" + active_object_id].setDateFormat(user_date_format, '%Y-%m-%d');
        setup_delivery_path.details_tabs["mdq_" + active_object_id].setColValidators(",,,ValidDate,ValidNumeric,NotEmpty");
        setup_delivery_path.details_tabs["mdq_" + active_object_id].setColSorting('str,str,str,str,str,str'); 
        setup_delivery_path.details_tabs["mdq_" + active_object_id].attachEvent("onValidationError",function(id,ind,value){
            validation_check = 1;
            var message = "Invalid Data";
            setup_delivery_path.details_tabs["mdq_" + active_object_id].cells(id,ind).setAttribute("validation", message);
            return false;
        });
        
        setup_delivery_path.details_tabs["mdq_" + active_object_id].attachEvent("onValidationCorrect",function(id,ind,value){
            validation_check = 0;
            setup_delivery_path.details_tabs["mdq_" + active_object_id].cells(id,ind).setAttribute("validation", "");
            return true;
        });
        setup_delivery_path.details_tabs["mdq_" + active_object_id].init(); 
        setup_delivery_path.details_tabs["mdq_" + active_object_id].setColumnsVisibility('true,true,true,false,false,false'); 
        setup_delivery_path.details_tabs["mdq_" + active_object_id].attachHeader(",,,#text_filter,#numeric_filter,#text_filter");
        setup_delivery_path.details_tabs["mdq_" + active_object_id].attachEvent("onRowSelect", function(id,ind){ 
            if (edit_permission) {                   
                setup_delivery_path["mdq_toolbar" + active_object_id].setItemEnabled('delete');         
            } else {
                setup_delivery_path["mdq_toolbar" + active_object_id].setItemDisabled('delete');
            }
            
        }); 
        
        //Loading dropdown for Receipt/Delivery in grid
        var cm_param = {
                            "action": "('SELECT ''r'', ''Receipt'' UNION SELECT ''d'', ''Delivery''')", 
                            "has_blank_option": "false"
                        };

        cm_param = $.param(cm_param);
        var url3 = js_dropdown_connector_url + '&' + cm_param;
        var combo_obj3 = setup_delivery_path.details_tabs["mdq_" + active_object_id].getColumnCombo(5); 
        combo_obj3.enableFilteringMode("between", null, false);
        combo_obj3.load(url3, function(){
            refresh_grid_mdq();
        });
    }
    
    function refresh_grid_mdq() {
        var active_tab_id = setup_delivery_path.dp_tab.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id; 
        var path_id = setup_delivery_path.details_form["single_form_" + active_object_id].getItemValue('path_id');        
        var flag = 'h';
        var sql_param = {
            "flag": flag,
            "action":"spa_setup_delivery_path",
            "grid_type":"g",
            "path_id": path_id
        };
        sql_param = $.param(sql_param);
        var sql_url = js_data_collector_url + "&" + sql_param;
        setup_delivery_path.details_tabs["mdq_" + active_object_id].clearAll();
        setup_delivery_path.details_tabs["mdq_" + active_object_id].load(sql_url, function() {
            setup_delivery_path.details_tabs["mdq_" + active_object_id].filterByAll();
        }); 
        
    }
    
    /**
    * Function enable/disable menu.
    */
    function set_setup_delivery_path_menu_disabled(item_id, bool) {
        if (bool == false) {
            setup_delivery_path.dp_menu.setItemDisabled(item_id);    
        } else {
            setup_delivery_path.dp_menu.setItemEnabled(item_id);
        }
    }
    //Custom Validation rule
     $(function() {  
        //for form validation.
        ValidatePositiveInteger = function(data){
            // data should be positive
            return(parseFloat(data) >= 0);
        };
    
        
        /*for grid validation.
        
        dhtmlxValidation.isValidatePositiveInteger = function(data) {
            // data should be positive interger
            return(parseFloat(data) >= 0);
        };*/
     });
     
    /**
    * Function defined in backend.
    */ 
    open_single_path = function(path_id) {
        var data = {
                    "action": "spa_setup_delivery_path",
                    "flag": "g",
                    "single_path_id": path_id
                    };
        
        adiha_post_data('return_array', data, '', '', 'single_path_form_tab');
    }
    
    /**
    * Call back function to open single path tab.
    */
    function single_path_form_tab(result) {
        var passed_path_id = result[0][3];
        var tab_id = 'tab_' + passed_path_id;
        var tab_label = result[0][1];
        
        setup_delivery_path.dp_tab.addTab(tab_id, tab_label, null, null, true, true);  
            // var icon_loc = '../../../../adiha.php.scripts/components/lib/adiha_dhtmlx/themes/' + theme_selected + '/imgs/dhxtoolbar_web/';     
            var icon_loc = js_image_path + "dhxmenu_web/";
                     
            win = setup_delivery_path.dp_tab.cells(tab_id);
            setup_delivery_path.pages[tab_id] = win;      
            var active_object_id = passed_path_id;
            setup_delivery_path["inner_tab_layout_" + active_object_id] = win.attachLayout("1C");
            setup_delivery_path["inner_tab_layout_" + active_object_id].cells('a').setHeight(500);
            setup_delivery_path["inner_tab_layout_" + active_object_id].cells('a').hideHeader()
            
            form_toolbar = setup_delivery_path["inner_tab_layout_" + active_object_id].cells('a').attachToolbar();                
            form_toolbar.setIconsPath(icon_loc);    
            
            form_toolbar.loadStruct([
                { id: 'save', type: 'button', img: 'save.gif', imgdis:"save_dis.gif", text: 'Save', title: 'Save'}
            ]);
            
            if (!edit_permission) {
                form_toolbar.disableItem('save');
            }  
            
            form_toolbar.attachEvent('onClick', setup_delivery_path.save_click);
            
            var xml_value =  '<Root><PSRecordset path_id="' + passed_path_id + '"></PSRecordset></Root>';
            data = {"action": "spa_create_application_ui_json",
                    "flag": "j",
                    "application_function_id":'10161110',
                    "template_name":'SetupDeliveryPath',
                    "parse_xml": xml_value
                 };
            
            result = adiha_post_data('return_array', data, '', '', 'setup_delivery_path.load_form_data');  
           
            //global_layout_object.cells('a').collapse();
      
        }
 
    open_deal_link = function(name, value) {    
        if (deal_id == '')
            return '';
        else        
            return '<a href="#" id= deal_idss onclick="setup_delivery_path.open_link(id)">Deal Link ('+deal_id+')</a>';          
    }

    setup_delivery_path.open_link = function(id) {
        var function_id = '';
            function_id = 10131010;
        parent.top.TRMHyperlink(function_id,deal_id,'n','NULL');        
            
    }
  
</script> 
