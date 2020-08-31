<?php
/**
* Setup transportation path screen
* @copyright Pioneer Solutions
*/
?>
<!--DOCTYPE transitional.dtd-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<meta http-equiv="X-UA-Compatible" content="IE=Edge"> 
<html> 
    <?php 
    include '../../../adiha.php.scripts/components/include.file.v3.php';
    global $image_path;
    $contract_id = get_sanitized_value($_GET['contract_id'] ?? '0');
    $php_script_loc = $app_php_script_loc;
    $rights_setup_transportation_path = 20000300;
    $rights_setup_transportation_path_iu = 20000301;
    $rights_setup_transportation_path_del = 20000302;

    //data from flow optimization 
    $call_from = get_sanitized_value($_GET['call_from'] ?? '');
    $mode = get_sanitized_value($_GET['mode'] ?? '');
    $path_id = get_sanitized_value($_GET['path_id'] ?? '');
    $from_loc_id = get_sanitized_value($_GET['from_loc_id'] ?? '');
    $to_loc_id = get_sanitized_value($_GET['to_loc_id'] ?? '');
    $from_loc = get_sanitized_value($_GET['from_loc'] ?? '');
    $to_loc = get_sanitized_value($_GET['to_loc'] ?? '');
    $trans_contract_id = get_sanitized_value($_GET['contract_id'] ?? '');
    
    list (
        $has_rights_setup_transportation_path,
        $has_rights_setup_transportation_path_iu,
        $has_rights_setup_transportation_path_del
    ) = build_security_rights (
        $rights_setup_transportation_path,
        $rights_setup_transportation_path_iu,
        $rights_setup_transportation_path_del  
    );

    $layout_obj = new AdihaLayout();
    $layout_name = 'setup_transportation_path_layout';
    $layout_json = "[
        {
            id:             'a',
            text:           'Transportation Path',
            width:          360,
            collapse:       false,
            fix_size:       [false, null],
            header:         true,
            undock:         true
        },
        {
            id:             'b',
            text:           ' ',
            collapse:       false,
            fix_size:       [false, null],
            header:         true
        }
    ]";
    $namespace = 'setup_transportation_path';
    echo $layout_obj->init_layout($layout_name, '', '2U', $layout_json, $namespace); 
    
    //Add menu object in a layout
    $menu_obj = new AdihaMenu();
    $menu_name = 'transportation_path_menu';
    echo $layout_obj->attach_menu_cell($menu_name, 'a'); 
    echo $layout_obj->attach_event('', 'onDock', $namespace . '.on_dock_event');
    echo $layout_obj->attach_event('', 'onUnDock', $namespace . '.on_undock_event');
    echo $layout_obj->attach_status_bar('a', true);
    
    $tree_menu_json =  '[
        {id:"f1", text:"Edit", img:"edit.gif", items:[
            {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add"},
            {id:"copy", text:"Copy", img:"copy.gif", imgdis:"copy_dis.gif", title: "Copy"},
            {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete"}
        ]},
        {id:"t2", text:"Export", img:"export.gif", items:[
            {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel", enabled:"true"},
            {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF", enabled:"true"},
        ]},
        { id: "expand_collapse", img: "exp_col.gif", text: "Expand/Collapse", title: "Expand/Collapse"}
    ]';
                         
    echo $menu_obj->init_by_attach($menu_name, $namespace);
    echo $menu_obj->load_menu($tree_menu_json);
    echo $menu_obj->attach_event('', 'onClick', $namespace . '.grid_toolbar_click');
    
    $grid_sql = "EXEC spa_adiha_grid 's', 'SetupTransportationPath'";
    $grid_data = readXMLURL2($grid_sql);

    $grid_column_ids = $grid_data[0]['column_name_list'];
    $grid_column_headers = $grid_data[0]['column_label_list'];
    $grid_column_widths = $grid_data[0]['column_width'];
    $grid_column_types = $grid_data[0]['column_type_list'];
    $grid_sorting_preferences = $grid_data[0]['sorting_preference'];
    $grid_column_visibilities = $grid_data[0]['set_visibility'];

    //Add treegrid in 'a' layout
    $treegrid_obj = new AdihaGrid();
    $treegrid_name = 'tg_transportation_path';
    $grid_sp = "EXEC spa_setup_delivery_path @flag='g', @path_type=1";
    $grid_type = 'tg';
    $grouping_column = 'path_type,grouping_name'; 
    echo $layout_obj->attach_grid_cell($treegrid_name, 'a');       
    echo $treegrid_obj->init_by_attach($treegrid_name, $namespace);
    echo $treegrid_obj->set_header($grid_column_headers);
    echo $treegrid_obj->set_columns_ids($grid_column_ids);
    echo $treegrid_obj->set_widths($grid_column_widths);
    echo $treegrid_obj->split_grid(1); 
    echo $treegrid_obj->set_column_types($grid_column_types);  
    echo $treegrid_obj->set_sorting_preference($grid_sorting_preferences);     
    echo $treegrid_obj->set_column_auto_size();
    echo $treegrid_obj->set_column_visibility($grid_column_visibilities);
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
        echo 'setup_transportation_path.tg_transportation_path.attachEvent("onXLE", function(grid_obj,count){';
        echo '  setup_transportation_path.tg_transportation_path.expandAll();';
        echo "      setup_transportation_path.tg_transportation_path.filterBy(12,function(data){";
        echo "        return (data==".$contract_id.");";
        echo "      });";
        echo "});";
    }
    echo $layout_obj->close_layout();       
?>
        
</body>

<script type="text/javascript"> 
    setup_transportation_path.details_layout = {};
    setup_transportation_path.details_tabs = {};
    setup_transportation_path.details_form = {};
    var php_script_loc = '<?php echo $app_php_script_loc; ?>';
    var image_path = '<?php echo $image_path; ?>';
    var treegrid_name = '<?php echo $treegrid_name; ?>';
    var application_function_id = 20000300;
    var template_name = 'SetupTransportationPath';
    var path_type = '';
    var grouping_column = '<?php echo $grouping_column; ?>';
    var today = new Date();
    var dd = today.getDate();
    var mm = today.getMonth()+1; //January is 0!
    var yyyy = today.getFullYear();
    var validation_check = 0;
    var msg_confirm_delete = '';
    var is_delete_true = new Array(); //This array is used
    var theme_selected = '<?php echo isset($_SESSION['dhtmlx_theme']) ? 'dhtmlx_'.$_SESSION['dhtmlx_theme'] : 'dhtmlx_default'; ?>';
    var theme_selected = '<?php echo isset($_SESSION['dhtmlx_theme']) ? 'dhtmlx_'.$_SESSION['dhtmlx_theme'] : 'dhtmlx_default'; ?>';
    var expand_state = 0;
     
    if (dd < 10) {
        dd = '0' + dd
    } 
    
    if (mm < 10) {
        mm = '0' + mm
    } 
    
    var current_date = mm + '/' + dd + '/' + yyyy;
    /**Privilege listing**/
    var edit_permission = '<?php echo $has_rights_setup_transportation_path_iu;?>';
    var delete_permission = '<?php echo $has_rights_setup_transportation_path_del;?>';


    var rate_schedule_grid_result;
    setup_transportation_path.rate_schedule_grid_data = function(result) {
        rate_schedule_grid_result = result;
    }
    
    $(function(){
        // test for flow optimization
        call_from = '<?php echo $call_from; ?>';
        mode = '<?php echo $mode; ?>';
        passed_path_id = '<?php echo $path_id; ?>';
        from_loc_id = '<?php echo $from_loc_id; ?>';
        to_loc_id = '<?php echo $to_loc_id; ?>';  
        from_loc = '<?php echo $from_loc; ?>';
        to_loc = '<?php echo $to_loc; ?>';  

        if (call_from != null && call_from == 'flow_optimization' || call_from == 'schedule_detail_report') {
            setup_transportation_path.setup_transportation_path_layout.cells('a').collapse();
            switch (mode) {
                case 'i':
                    setup_transportation_path.load_data();
                    break;
                case 'u':
                    var data = {
                                "action": "spa_setup_delivery_path",
                                "flag": "g",
                                "single_path_id": passed_path_id
                            };
        
                    adiha_post_data('return_array', data, '', '', 'load_value', '');
                    break;
                default:
                    break;
            }
        }
        
        set_setup_transportation_path_menu_disabled('add', false);
        set_setup_transportation_path_menu_disabled('delete', false);
        set_setup_transportation_path_menu_disabled('copy', false);
        
        setup_transportation_path.tg_transportation_path.attachEvent("onRowSelect", function(id, ind) {
            var group_col = setup_transportation_path.tg_transportation_path.cells(id, 0).getValue();
            set_setup_transportation_path_menu_disabled('add', edit_permission);

            if (group_col != 'SINGLE PATH' && group_col != 'GROUP PATH' && group_col != '') {
                if (setup_transportation_path.tg_transportation_path.cells(id, 11).getValue() == 'group') {
                    path_type = 'group';
                } else {
                    path_type = 'single';
                }

                set_setup_transportation_path_menu_disabled('delete', delete_permission);
                set_setup_transportation_path_menu_disabled('copy', edit_permission);
            } else {
                set_setup_transportation_path_menu_disabled('delete', false);
                set_setup_transportation_path_menu_disabled('copy', false);

                path_type = (group_col == 'SINGLE PATH') ? 'single' : 'group';
            }
        })
    });

    function load_value(result) {
        var tab_id = 'tab_' + passed_path_id;
        var tab_label = result[0][1];
        
        if (result[0][0] == "GROUP PATH") {
            var path_type = 'group'
        }

        setup_transportation_path.dp_tab.addTab(tab_id, tab_label, null, null, true, true);
        var icon_loc = '../../../../adiha.php.scripts/components/lib/adiha_dhtmlx/themes/' + js_dhtmlx_theme + '/imgs/dhxtoolbar_web/';
                 
        win = setup_transportation_path.dp_tab.cells(tab_id);
        setup_transportation_path.pages[tab_id] = win;      
        var active_object_id = passed_path_id;
        setup_transportation_path["inner_tab_layout_" + active_object_id] = win.attachLayout("1C");
        setup_transportation_path["inner_tab_layout_" + active_object_id].cells('a').setHeight(500);
        setup_transportation_path["inner_tab_layout_" + active_object_id].cells('a').hideHeader()
        
        form_toolbar = setup_transportation_path["inner_tab_layout_" + active_object_id].cells('a').attachToolbar();                
        form_toolbar.setIconsPath(image_path + 'dhxmenu_web/');    
        
        form_toolbar.loadStruct([
            { id: 'save', type: 'button', img: 'save.gif', imgdis:"save_dis.gif", text: 'Save', title: 'Save'}
        ]);

        form_toolbar.disableItem('save');
                      
        form_toolbar.attachEvent('onClick', setup_transportation_path.save_click); 
        
        if (path_type == 'group') {                   
            load_group_path_detail();
        } else {
            var xml_value =  '<Root><PSRecordset path_id="' + passed_path_id + '"></PSRecordset></Root>';

            data = {
                "action": "spa_create_application_ui_json",
                "flag": "j",
                "application_function_id": application_function_id,
                "template_name": template_name,
                "parse_xml": xml_value
            };
            
            result = adiha_post_data('return_array', data, '', '', 'setup_transportation_path.load_form_data');   
        }
    }
    
    setup_transportation_path.load_data = function(id) {
        var hierarchy_level = setup_transportation_path.tg_transportation_path.getLevel(setup_transportation_path.tg_transportation_path.getSelectedRowId());
        if (hierarchy_level == 0) {
            // alert(hierarchy_level);
            var state = setup_transportation_path.tg_transportation_path.getOpenState(id);
            if (state)
                setup_transportation_path.tg_transportation_path.closeItem(id);
            else 
                setup_transportation_path.tg_transportation_path.openItem(id);
            return;
        }
        setup_transportation_path.load_form_detail(id);
    }
    
    setup_transportation_path.load_form_detail = function(id) {
        var tab_label = (typeof id=="undefined") ? 'New' : setup_transportation_path.tg_transportation_path.cells(id, 0).getValue();
        tab_label = (tab_label == '') ? 'New' : tab_label;
        var new_id = (new Date()).valueOf();
        var tab_id = (typeof id=="undefined" || tab_label == 'New') ? new_id.toString() : "tab_" + setup_transportation_path.tg_transportation_path.cells(id, 2).getValue();
        
        var path_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        
        if (typeof id != "undefined" && tab_label != 'New') {
            group_path_id = setup_transportation_path.tg_transportation_path.getParentId(id);
            path_type = (setup_transportation_path.tg_transportation_path.cells(group_path_id, 0).getValue() == 'GROUP PATH') ? 'group' : 'single';
        }


        if (!setup_transportation_path.pages[tab_id]) {  
            setup_transportation_path.dp_tab.addTab(tab_id, tab_label, null, null, true, true);  
            var icon_loc = '../../../../adiha.php.scripts/components/lib/adiha_dhtmlx/themes/' + theme_selected + '/imgs/dhxtoolbar_web/';     
                     
            win = setup_transportation_path.dp_tab.cells(tab_id);
            setup_transportation_path.pages[tab_id] = win;      
            var active_object_id = path_id;
            setup_transportation_path["inner_tab_layout_" + active_object_id] = win.attachLayout("1C");
            setup_transportation_path["inner_tab_layout_" + active_object_id].cells('a').setHeight(500);
            setup_transportation_path["inner_tab_layout_" + active_object_id].cells('a').hideHeader()
            
            form_toolbar = setup_transportation_path["inner_tab_layout_" + active_object_id].cells('a').attachToolbar();                
            form_toolbar.setIconsPath(image_path + 'dhxmenu_web/'); 
            form_toolbar.loadStruct([
                { id: 'save', type: 'button', img: 'save.gif', imgdis:"save_dis.gif",text: 'Save', title: 'Save'}
            ]);
            
            if (!edit_permission) {
                form_toolbar.disableItem('save');
            }
            
            form_toolbar.attachEvent('onClick', setup_transportation_path.save_click);
             
            setup_transportation_path.setup_transportation_path_layout.cells("b").progressOn();
            
            if (path_type == 'group') {   
                load_group_path_detail();
            } else {
                var xml_value =  '<Root><PSRecordset path_id="' + path_id + '"></PSRecordset></Root>';
                data = {
                    "action": "spa_create_application_ui_json",
                    "flag": "j",
                    "application_function_id":application_function_id,
                    "template_name":template_name,
                    "parse_xml": xml_value
                };
                
                result = adiha_post_data('return_array', data, '', '', 'setup_transportation_path.load_form_data');   
            } 
        } else {            
            setup_transportation_path.dp_tab.cells(tab_id).setActive();
        }
        
        var active_tab_id = setup_transportation_path.dp_tab.getActiveTab();
        is_delete_true[active_tab_id]  = false;  
    }
    
    setup_transportation_path.load_form_data = function(result) {
        var tab_json = '';
        var form_json = {};
        // create tab json and form json
        for (i = 0; i < result.length; i++) {
            if (i > 0)
                tab_json = tab_json + ",";
            tab_json = tab_json + (result[i][1]);

            form_json[i] = result[i][2];
        }
        var active_tab_id = setup_transportation_path.dp_tab.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        tab_json = '{mode: "bottom", arrows_mode: "auto",tabs: [' + tab_json + ']}';
        setup_transportation_path["delivery_path_tab_" + active_object_id] = setup_transportation_path["inner_tab_layout_" + active_object_id].cells('a').attachTabbar({mode:"bottom",arrows_mode:"auto"});
        
        // attach tab 
        setup_transportation_path["delivery_path_tab_" + active_object_id].loadStruct(tab_json);
        
        //attach form/grid
        var result_length = result.length;
        for (j = 0; j < result_length; j++) {
            tab_id = 'detail_tab_' + result[j][0];
            var tab_name = setup_transportation_path["delivery_path_tab_" + active_object_id].cells(tab_id).getText();
            
            switch(tab_name) {
                case get_locale_value("Path Detail"):
                    load_single_path_detail(tab_id, result[j][2]); //Form                    
                    break;
                case get_locale_value("Rate Schedule"):
                    load_rate_schedule(tab_id); //Grid
                    break;
            }
        }

       
        
        if (from_loc_id != '') {
            setup_transportation_path.details_form["single_form_" + active_object_id].setItemValue('from_location', from_loc_id);
            setup_transportation_path.details_form["single_form_" + active_object_id].setItemValue('label_from_location', from_loc);
        }
        
        if (to_loc_id != '') {
            setup_transportation_path.details_form["single_form_" + active_object_id].setItemValue('to_location', to_loc_id);
            setup_transportation_path.details_form["single_form_" + active_object_id].setItemValue('label_to_location', to_loc);
        }
        
        setup_transportation_path.setup_transportation_path_layout.cells("b").progressOff();        
    }
    
    setup_transportation_path.close_path_detail = function(id) {
        delete setup_transportation_path.pages[id];
        return true;
    }
    
    setup_transportation_path.grid_toolbar_click = function(id) {
        switch(id) {
            case 'add':
                setup_transportation_path.load_form_detail();
                break;
            case 'delete': 
                if (selected_row != '') {   
                    var selected_row = setup_transportation_path.tg_transportation_path.getSelectedRowId(); 
                    id_array = selected_row.split(',');                
                    arr_length = id_array.length;
                    path_type = setup_transportation_path.tg_transportation_path.cells(id_array[0], 10).getValue();
                    
                    var grid_xml = "<GridGroup><GridDelete>";
                    for (var i =0; i < arr_length; i++) {
                        var path_id = setup_transportation_path.tg_transportation_path.cells(id_array[i], 2).getValue();
                        
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
                    show_messagebox("Please select any path.");
                }       
            break;                
            case 'excel':
                setup_transportation_path.tg_transportation_path.toPDF(php_script_loc + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                break;                
            case 'pdf':
                setup_transportation_path.tg_transportation_path.toPDF(php_script_loc + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                break;                
            case 'copy':   
                var selected_row = setup_transportation_path.tg_transportation_path.getSelectedRowId();
                var path_ids = ''; 
                
                if (selected_row == null) {
                    show_messagebox("Select Path to copy.");
                    return;
                }             
                if (selected_row != null || (selected_row.indexOf(',') != -1)) {   
                    var id_array = selected_row.split(',');                
                    var arr_length = id_array.length;
                    path_type = setup_transportation_path.tg_transportation_path.cells(id_array[0], 10).getValue();
                    
                    for(var i = 0; i < arr_length; i++) {
                        if (i > 0) path_ids = path_ids + ',';
                        path_ids = path_ids + setup_transportation_path.tg_transportation_path.cells(id_array[i], 2).getValue();
                    }
                    
                    confirm_messagebox("Are you sure you want to copy?", function(){
                        var data = {
                                    "action": "spa_setup_delivery_path",
                                    "flag": "c",
                                    "path_id": path_ids,
                                    "path_type":1
                                };
                
                                adiha_post_data('alert', data, '', '', 'refresh_tree', '');
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
        setup_transportation_path.tg_transportation_path.expandAll();
        expand_state = 1;
    }

    /**
     *[closeAllInvoices Close All nodes of Invoice Grid]
     */
    close_all_group = function() {
        setup_transportation_path.tg_transportation_path.collapseAll();
        expand_state = 0;
    }

    setup_transportation_path.save_click = function(id, is_confirm) {
        if (is_confirm == undefined) is_confirm = 0; 
        var active_tab_id = setup_transportation_path.dp_tab.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        
        switch(id) {
            case "save":
            var group_status = 1;
            var form_xml = "<FormXML ";
            data = setup_transportation_path.details_form["single_form_" + active_object_id].getFormData();
            
            var status = validate_form(setup_transportation_path.details_form["single_form_" + active_object_id]);
            
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
            var path_detail_xml = 'NULL';
            var grid_xml = 'NULL';
            var rate_sch_arr_check = 0;            
            var rate_sch_arr = new Array();
            var path_detail_arr_check = 0;            
            var path_detail_arr = new Array();
            var err_msg = '';
            
            if (path_type == 'group') {

                // console.log(setup_transportation_path.details_tabs["gp_path_" + active_object_id]);
                if (setup_transportation_path.validate_form_grid((setup_transportation_path.details_tabs["gp_path_" + active_object_id]),'Path Detail') == false) {
                    group_status = 0;
                    // return;
                 // var status = setup_transportation_path.validate_form_grid(attached_obj, 'Rate Schedule');
                }

                path_detail_xml = "<GridGroup>";
                setup_transportation_path.details_tabs["gp_path_" + active_object_id].clearSelection();
                for (var row_index=0; row_index < setup_transportation_path.details_tabs["gp_path_" + active_object_id].getRowsNum(); row_index++) {
                    if (jQuery.inArray(setup_transportation_path.details_tabs["gp_path_" + active_object_id].cells2(row_index,1).getValue(), path_detail_arr ) == -1) {
                        path_detail_arr.push(setup_transportation_path.details_tabs["gp_path_" + active_object_id].cells2(row_index,1).getValue());
                    } else {
                        path_detail_arr_check = 1;
                        err_msg = 'Duplicate data(Path Name) in Path Detail grid.';
                    }
                    
                    path_detail_xml = path_detail_xml + "<PSRecordset ";
                    for(var cellIndex = 0; cellIndex < setup_transportation_path.details_tabs["gp_path_" + active_object_id].getColumnsNum(); cellIndex++){
                        field_label = setup_transportation_path.details_tabs["gp_path_" + active_object_id].getColumnId(cellIndex);
                        field_value = setup_transportation_path.details_tabs["gp_path_" + active_object_id].cells2(row_index,cellIndex).getValue();
                        
                        // if (field_label == 'path_id' && field_value == '') { 
                        //     dhtmlx.alert({
                        //         title:"Error!",
                        //         type:"alert-error",
                        //         text:"Please enter Path Name in grid."
                        //     });
                        //     return;
                        // }  
                        
                        path_detail_xml = path_detail_xml + " " + field_label + '="' + field_value + '"';
                    }
                    path_detail_xml = path_detail_xml + " ></PSRecordset> ";
                }
                path_detail_xml = path_detail_xml + "</GridGroup>"; 
            } else {
                var attached_obj = setup_transportation_path.details_tabs["rate_schedule_" + active_object_id];
                console.log(attached_obj)
                var status = setup_transportation_path.validate_form_grid(attached_obj, 'Rate Schedule');

                setup_transportation_path.details_tabs["rate_schedule_" + active_object_id].clearSelection();
                grid_xml = "<GridGroup>";

                if (status == false) return;

                if (status == true) {
                    for (var row_index=0; row_index < setup_transportation_path.details_tabs["rate_schedule_" + active_object_id].getRowsNum(); row_index++) {
                        grid_xml = grid_xml + "<PSRecordset ";
                        for(var cellIndex = 0; cellIndex < setup_transportation_path.details_tabs["rate_schedule_" + active_object_id].getColumnsNum(); cellIndex++){
                            field_label = setup_transportation_path.details_tabs["rate_schedule_" + active_object_id].getColumnId(cellIndex);
                            field_value = setup_transportation_path.details_tabs["rate_schedule_" + active_object_id].cells2(row_index,cellIndex).getValue();
                            if (field_label == 'contract_id' && field_value == '') {
                            } else {        
                                grid_xml = grid_xml + " " + field_label + '="' + field_value + '"';
                            }
                        }
                        grid_xml = grid_xml + " ></PSRecordset> ";
                    }
                }
                grid_xml += "</GridGroup>";                      
            }

            var tab_name = setup_transportation_path.dp_tab.tabs(active_tab_id).getText();
            var flag;
            
            if (tab_name == 'New') { 
                flag = 'i';
            } else {
                flag = 'u';
            }
            
            if (path_detail_xml == '<GridGroup></GridGroup>'){
                path_detail_xml = 'NULL';
            }
            if(group_status == 0) {
                return;

            }
            var data = {
                "action": "spa_setup_delivery_path",
                "flag": flag,
                "path_type": 1,
                "form_xml": form_xml,
                "rate_schedule_xml": grid_xml,
                "group_path_xml": path_detail_xml,
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
        var active_tab_id = setup_transportation_path.dp_tab.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;  
        var return_data = JSON.parse(result);

        if ((return_data[0].status).toLowerCase() == 'success') {
            var result_arr = return_data[0].recommendation.split(';'); 
            var new_id = result_arr[0];
            setup_transportation_path.details_form["single_form_" + active_object_id].setItemValue('path_id', new_id);
            var tab_name = result_arr[1]; 

            setup_transportation_path.details_form["single_form_" + active_object_id].setItemValue('path_name', tab_name);
            setup_transportation_path.dp_tab.tabs(active_tab_id).setText(tab_name);
            dhtmlx.message(return_data[0].message);
            refresh_tree();
            if (path_type == 'group') {
               refresh_grid_gp_path_detail(); 
            } else {
                refresh_grid_rate_schedule();
            }

            // active_obj
            if (path_type == 'single') {
                setup_transportation_path.dp_tab.tabs(active_object_id).close(false);
                open_single_path(new_id);
            } else {
                setup_transportation_path.dp_tab.tabs(active_object_id).close(false);
                open_group_path(new_id, tab_name);
            }
            
        } else if ((return_data[0].status).toLowerCase() == 'error') {
            if (return_data[0].recommendation == 'form') {
                show_messagebox(return_data[0].message);
            } else if (return_data[0].recommendation == 'Rate Schedule') {
                show_messagebox(return_data[0].message);
            } else {
                show_messagebox(return_data[0].message);
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
        var sp_url = "EXEC spa_setup_delivery_path @flag='g', @path_type=1"
        var sql_param = {
            "sql":sp_url,
            "grid_type":"tg",
            "grouping_column": grouping_column
        };
        sql_param = $.param(sql_param);
        var sql_url = js_data_collector_url + "&" + sql_param;

        setup_transportation_path.tg_transportation_path.clearAll();
        setup_transportation_path.tg_transportation_path.enableHeaderMenu();
               
        var grouping_col = (path_type == 'group') ? 'GROUP PATH' : 'SINGLE PATH';
        setup_transportation_path.tg_transportation_path.load(sql_url, function() {    
            setup_transportation_path.tg_transportation_path.filterByAll();
            grouping_col = grouping_col.replace(/\s+/g,"");
           setup_transportation_path.tg_transportation_path.openItem(grouping_col);            
        });

        set_setup_transportation_path_menu_disabled('delete', false);
        set_setup_transportation_path_menu_disabled('copy', false);
        
        return true;    
    }
    
    function delete_path(response_data) {
        if(response_data[0].errorcode != 'Success') {            
           return; 
        }  
        var selected_row = setup_transportation_path.tg_transportation_path.getSelectedRowId();
        id_array = selected_row.split(',');                
        arr_length = id_array.length;
        for (var i = 0; i < arr_length; i++) {
            var path_id = setup_transportation_path.tg_transportation_path.cells(id_array[i], 2).getValue(); 
            if (setup_transportation_path.pages['tab_' + path_id]) {           
                setup_transportation_path.dp_tab.tabs('tab_' + path_id).close(); 
                delete setup_transportation_path.pages['tab_' + path_id]; 
            }            
        }
               
        refresh_tree();  
    }
    
    /*
    Add Group path Detail
    */
    function load_group_path_detail () {
        setup_transportation_path.setup_transportation_path_layout.cells("b").progressOn();
        var active_tab_id = setup_transportation_path.dp_tab.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id; 
         
        setup_transportation_path["delivery_path_tab_" + active_object_id] = setup_transportation_path["inner_tab_layout_" + active_object_id].cells('a').attachTabbar();
        
        // attach tab 
        tab_id = 'detail_tab_group_path';
        tab_json = '{mode: "bottom",arrows_mode: "auto",tabs: [{"id":"' + tab_id + '","text": get_locale_value("Path Detail"),"active":"true"}]}';
        setup_transportation_path["delivery_path_tab_" + active_object_id].loadStruct(tab_json);
              
        setup_transportation_path["inner_tab_gp_layout_" + active_object_id] = setup_transportation_path["delivery_path_tab_" + active_object_id].cells(tab_id).attachLayout(
            "2E"
        );
        
        setup_transportation_path["inner_tab_gp_layout_" + active_object_id].cells('a').setHeight(100);
        setup_transportation_path["inner_tab_gp_layout_" + active_object_id].cells('a').hideHeader();
        // setup_transportation_path["inner_tab_gp_layout_" + active_object_id].cells('b').hideHeader();
        setup_transportation_path["inner_tab_gp_layout_" + active_object_id].cells('b').setText(get_locale_value('Group Path'));
        setup_transportation_path.details_form["single_form_" + active_object_id] = setup_transportation_path["inner_tab_gp_layout_" + active_object_id].cells('a').attachForm();
        
        var gp_form_json = [
            {type: "settings", position: "label-top", labelWidth: 170, inputWidth: 150},
            {type:"hidden",  name: "path_id", label:"Path ID" },
            {type:"hidden",  name: "groupPath", label:"Group path", value:"y"}, 
            {type:"block", width:500, offsetTop: 20, list:[
                {type:"input",  name: "path_name", label:"Path Name",required:true,validate:"NotEmpty", userdata:{validation_message:"Required Field"}},
                {type: "newcolumn"},
                {type:"checkbox",  name: "isactive", label:"Active", checked:true, position: "label-right",offsetTop: 30},
                {type:"hidden",  name: "path_type", label:"", value:"1"}
            ]}
        ];

        setup_transportation_path.details_form["single_form_" + active_object_id].loadStruct(get_form_json_locale(gp_form_json));
                        
        var path_id = 1;
        
        var tab_name = setup_transportation_path.dp_tab.tabs(active_tab_id).getText();
            
        if (tab_name != 'New') {  
            path_id = active_object_id;
            path_name = setup_transportation_path.dp_tab.tabs(active_tab_id).getText();
            
            var data = {
                "action": "spa_setup_delivery_path",
                "flag": "a",
                "path_id": path_id
            };
            
            adiha_post_data('return_json', data, '', '', 'callback_group_path_detail', '');
        }            
        
        //Attach toolbar in cell b
        var gp_path_toolbar = [
            {id:"g1", text:"Edit", img:"edit.gif", items:[
                {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add"},
                {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete"}
            ]},
            {id:"g2", text:"Export", img:"export.gif", items:[
                {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
            ]}   
        ];
        
        setup_transportation_path["gp_path_toolbar_" + active_object_id] = setup_transportation_path["inner_tab_gp_layout_" + active_object_id].cells('b').attachMenu();
        setup_transportation_path["gp_path_toolbar_" + active_object_id].setIconsPath(image_path + 'dhxmenu_web/');
        setup_transportation_path["gp_path_toolbar_" + active_object_id].loadStruct(gp_path_toolbar);
        
        if (!edit_permission) {
            setup_transportation_path["gp_path_toolbar_" + active_object_id].setItemDisabled('add');
            setup_transportation_path["gp_path_toolbar_" + active_object_id].setItemDisabled('delete');
        } else {
            setup_transportation_path["gp_path_toolbar_" + active_object_id].setItemDisabled('delete');  
        }
         
        setup_transportation_path["gp_path_toolbar_" + active_object_id].attachEvent('onClick', function(id){
            switch(id) {
                case "add":
                    var newId = (new Date()).valueOf();
                    setup_transportation_path.details_tabs["gp_path_" + active_object_id].addRow(newId, "");
                    setup_transportation_path.details_tabs["gp_path_" + active_object_id].selectRowById(newId);
                    setup_transportation_path.details_tabs["gp_path_" + active_object_id].forEachRow(function(row){
                        setup_transportation_path.details_tabs["gp_path_" + active_object_id].forEachCell(row,function(cellObj,ind){
                            setup_transportation_path.details_tabs["gp_path_" + active_object_id].validateCell(row,ind)
                        });
                    });
                    break;
                case "delete":
                    msg_confirm_delete = "Some data has been deleted from Path Detail. Are you sure you want to save?";
                    is_delete_true[active_tab_id] = true;
                    var row_id = setup_transportation_path.details_tabs["gp_path_" + active_object_id].getSelectedRowId();
                    setup_transportation_path.details_tabs["gp_path_" + active_object_id].deleteRow(row_id);
                    setup_transportation_path["gp_path_toolbar_" + active_object_id].setItemDisabled('delete');
                    break;
                case "excel":
                    setup_transportation_path.details_tabs["gp_path_" + active_object_id].toExcel(php_script_loc + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                    break;
                case "pdf":
                    setup_transportation_path.details_tabs["gp_path_" + active_object_id].toPDF(php_script_loc +'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                    break;
            }
        });
        
        //Creating the path detail grid
        setup_transportation_path.details_tabs["gp_path_" + active_object_id] = setup_transportation_path["inner_tab_gp_layout_" + active_object_id].cells('b').attachGrid();
        setup_transportation_path.details_tabs["gp_path_" + active_object_id].setHeader(get_locale_value('Path ID,Path Name, Path Code, Receipt Location, Delivery Location,Grid,Contract,Transmission Priority',true)); 
        setup_transportation_path.details_tabs["gp_path_" + active_object_id].setColumnIds("delivery_path_detail_id,path_id,path_code,from_location,to_location,counterparty_name,contract_name,priority");
        setup_transportation_path.details_tabs["gp_path_" + active_object_id].setColTypes("ro,combo,link,ro,ro,ro,ro,ro");   
        setup_transportation_path.details_tabs["gp_path_" + active_object_id].setColSorting('str,str,str,str,str,str,str,str');      
        setup_transportation_path.details_tabs["gp_path_" + active_object_id].setInitWidths('0,150,150,150,150,150,150,150'); 
        setup_transportation_path.details_tabs["gp_path_" + active_object_id].attachHeader(",#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter");

        // 
        setup_transportation_path.details_tabs["gp_path_" + active_object_id].enableValidation(true); 
        setup_transportation_path.details_tabs["gp_path_" + active_object_id].setColValidators(",NotEmpty,,,,,");

        setup_transportation_path.details_tabs["gp_path_" + active_object_id].attachEvent("onValidationError",function(id, ind, value) {
            var message = "Invalid Data";
            setup_transportation_path.details_tabs["gp_path_" + active_object_id].cells(id,ind).setAttribute("validation", message);
            return true;
        });

        setup_transportation_path.details_tabs["gp_path_" + active_object_id].attachEvent("onValidationCorrect",function(id,ind,value){
            setup_transportation_path.details_tabs["gp_path_" + active_object_id].cells(id,ind).setAttribute("validation", "");
            return true;
        });
        // 


        setup_transportation_path.details_tabs["gp_path_" + active_object_id].init(); 

        setup_transportation_path.details_tabs["gp_path_" + active_object_id].enableHeaderMenu(); 
        setup_transportation_path.details_tabs["gp_path_" + active_object_id].setColumnsVisibility('true,false,false,false,false,true,true,true');
        setup_transportation_path.details_tabs["gp_path_" + active_object_id].attachEvent("onRowSelect", function(id,ind){ 
            if (edit_permission) {                   
                setup_transportation_path["gp_path_toolbar_" + active_object_id].setItemEnabled('delete');         
            } else {
                setup_transportation_path["gp_path_toolbar_" + active_object_id].setItemDisabled('delete');
            }
            
        });

         //Loading dropdown for Path in grid
        var cm_param = {
            "action": "[spa_setup_delivery_path]", 
            "flag": "m"
        };

        cm_param = $.param(cm_param);
        var url = js_dropdown_connector_url + '&' + cm_param;
        var combo_obj = setup_transportation_path.details_tabs["gp_path_" + active_object_id].getColumnCombo(1); 
        combo_obj.enableFilteringMode("between", null, false); 
        
        combo_obj.attachEvent("onChange", function (name, value) {
            var sp_string = "EXEC spa_setup_delivery_path @flag='a', @path_id=" + name;           
            var data_for_post =  {"sp_string": sp_string};
            adiha_post_data('return_array', data_for_post, 's', 'e', 'get_path_detail');
                
        }); 
        
        combo_obj.load(url, function() {
            refresh_grid_gp_path_detail()
        });
        setup_transportation_path.setup_transportation_path_layout.cells("b").progressOff();
    }
    
    function refresh_grid_gp_path_detail() {
        var active_tab_id = setup_transportation_path.dp_tab.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id; 
        var path_id = setup_transportation_path.details_form["single_form_" + active_object_id].getItemValue('path_id');   
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
        setup_transportation_path.details_tabs["gp_path_" + active_object_id].clearAll();
        setup_transportation_path.details_tabs["gp_path_" + active_object_id].load(sql_url, function() {
            setup_transportation_path.details_tabs["gp_path_" + active_object_id].filterByAll();
        });
    }
    
    //json
    function callback_group_path_detail(result) {
        var return_data = JSON.parse(result);
        var active_tab_id = setup_transportation_path.dp_tab.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id; 
        setup_transportation_path.details_form["single_form_" + active_object_id].setItemValue('path_id', return_data[0].path_id);
        setup_transportation_path.details_form["single_form_" + active_object_id].setItemValue('path_name', return_data[0].path_name);
        if (return_data[0].isactive == 'y') {
            setup_transportation_path.details_form["single_form_" + active_object_id].checkItem('isactive');
        } else {
            setup_transportation_path.details_form["single_form_" + active_object_id].uncheckItem('isactive');
        }
        
     }   
            
    function get_path_detail(result) {    
        var active_tab_id = setup_transportation_path.dp_tab.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;         
        var row_id = setup_transportation_path.details_tabs["gp_path_" + active_object_id].getSelectedRowId();        
        
        for (var i = 1; i < result[0].length - 1; i++) {
            setup_transportation_path.details_tabs["gp_path_" + active_object_id].cells(row_id, i + 1).setValue(result[0][i]);
        } 
    }
     /*
     * Load single path detail
     */
    function load_single_path_detail(tab_id, form_json) {
        var active_tab_id = setup_transportation_path.dp_tab.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;   
        var selected_row = setup_transportation_path.tg_transportation_path.getSelectedRowId(); 
     
        setup_transportation_path.details_form["single_form_" + active_object_id] = setup_transportation_path["delivery_path_tab_" + active_object_id].cells(tab_id).attachForm();
        
        if (form_json) {
            setup_transportation_path.details_form["single_form_" + active_object_id].loadStruct(form_json, function() {
                var form_name = 'setup_transportation_path.details_form["single_form_" + ' + active_object_id + ']';
                attach_browse_event(form_name, application_function_id);
            });
        }

        var tab_name = setup_transportation_path.dp_tab.tabs(active_tab_id).getText();   
    }
    
    function load_rate_schedule(tab_id) {        
       var active_tab_id = setup_transportation_path.dp_tab.getActiveTab();
       var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id; 

       setup_transportation_path.details_layout["details_layout_" + active_object_id] = setup_transportation_path["delivery_path_tab_" + active_object_id].cells(tab_id).attachLayout({
           pattern: "1C",
           cells: [
               {
                   id: "a",
                   text: "<div>Rate Schedule</div>",
                   header: true,
                   collapse: false
               }
           ]
       });
        
        //Menu for the Constraints Grid
        var rate_schedule_toolbar = [
            {id:"t1", text:"Edit", img:"edit.gif", items:[
                {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add"},
                {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete"}
            ]},
            {id:"t2", text:"Export", img:"export.gif", items:[
                {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
            ]}   
        ];
        
        setup_transportation_path["rate_schedule_toolbar_" + active_object_id] = setup_transportation_path.details_layout["details_layout_" + active_object_id].cells("a").attachMenu();
        setup_transportation_path["rate_schedule_toolbar_" + active_object_id].setIconsPath(image_path + 'dhxmenu_web/');
        setup_transportation_path["rate_schedule_toolbar_" + active_object_id].loadStruct(rate_schedule_toolbar);
        
        if (!edit_permission) {
            setup_transportation_path["rate_schedule_toolbar_" + active_object_id].setItemDisabled('add');
            setup_transportation_path["rate_schedule_toolbar_" + active_object_id].setItemDisabled('delete');
        } else {
            setup_transportation_path["rate_schedule_toolbar_" + active_object_id].setItemDisabled('delete');
        }

        setup_transportation_path["rate_schedule_toolbar_" + active_object_id].attachEvent('onClick', function(id) {
            switch(id) {
                case "add":
                    var rate_sch = setup_transportation_path.details_form["single_form_" + active_object_id].getItemValue('rateSchedule');
                    var newId = (new Date()).valueOf();
                    setup_transportation_path.details_tabs["rate_schedule_" + active_object_id].addRow(newId, "");
                    setup_transportation_path.details_tabs["rate_schedule_" + active_object_id].selectRowById(newId);
                    setup_transportation_path.details_tabs["rate_schedule_" + active_object_id].forEachRow(function(row){
                        setup_transportation_path.details_tabs["rate_schedule_" + active_object_id].forEachCell(row,function(cellObj,ind){
                            setup_transportation_path.details_tabs["rate_schedule_" + active_object_id].validateCell(row,ind)
                        });
                    });
                    break;

                case "delete":
                    msg_confirm_delete = "Some data has been deleted from Rate Schedule. Are you sure you want to save?";
                    var row_id = setup_transportation_path.details_tabs["rate_schedule_" + active_object_id].getSelectedRowId();
                    var sel_value = setup_transportation_path.details_tabs["rate_schedule_" + active_object_id].cells(row_id,0).getValue();
                    is_delete_true[active_tab_id] = (sel_value == '') ? false : true;
                    setup_transportation_path.details_tabs["rate_schedule_" + active_object_id].cells(row_id, 0).getValue();
                    setup_transportation_path.details_tabs["rate_schedule_" + active_object_id].deleteRow(row_id);
                    break;

                case "excel":
                    setup_transportation_path.details_tabs["rate_schedule_" + active_object_id].toExcel(php_script_loc + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                    break;

                case "pdf":
                    setup_transportation_path.details_tabs["rate_schedule_" + active_object_id].toPDF(php_script_loc + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                    break;
            }
        });
    
        rate_schedule_data = {
            "action": "spa_adiha_grid",
            "flag": "s",
            "grid_name": "TransportationRateSchedule"
        }
        adiha_post_data('return_array', rate_schedule_data, '', '', 'setup_transportation_path.rate_schedule_grid_data', false);

        //Creating the constraints grid
        setup_transportation_path.details_tabs["rate_schedule_" + active_object_id] = setup_transportation_path.details_layout["details_layout_" + active_object_id].cells("a").attachGrid();
        setup_transportation_path.details_tabs["rate_schedule_" + active_object_id].setHeader(get_locale_value(rate_schedule_grid_result[0][3],true)); 
        setup_transportation_path.details_tabs["rate_schedule_" + active_object_id].setColumnIds(rate_schedule_grid_result[0][2]);
        setup_transportation_path.details_tabs["rate_schedule_" + active_object_id].setColTypes(rate_schedule_grid_result[0][4]);        
        setup_transportation_path.details_tabs["rate_schedule_" + active_object_id].setInitWidths(rate_schedule_grid_result[0][10]);
        setup_transportation_path.details_tabs["rate_schedule_" + active_object_id].enableColumnAutoSize(true);
        setup_transportation_path.details_tabs["rate_schedule_" + active_object_id].setColSorting(rate_schedule_grid_result[0][11]);
        setup_transportation_path.details_tabs["rate_schedule_" + active_object_id].enableColumnMove(true); 
        setup_transportation_path.details_tabs["rate_schedule_" + active_object_id].setDateFormat(user_date_format, "%Y-%m-%d"); 

        setup_transportation_path.details_tabs["rate_schedule_" + active_object_id].enableValidation(true); 
        setup_transportation_path.details_tabs["rate_schedule_" + active_object_id].setColValidators(rate_schedule_grid_result[0][14]);

        setup_transportation_path.details_tabs["rate_schedule_" + active_object_id].attachEvent("onValidationError",function(id, ind, value) {
            var message = "Invalid Data";
            setup_transportation_path.details_tabs["rate_schedule_" + active_object_id].cells(id,ind).setAttribute("validation", message);
            return true;
        });

        setup_transportation_path.details_tabs["rate_schedule_" + active_object_id].attachEvent("onValidationCorrect",function(id,ind,value){
            setup_transportation_path.details_tabs["rate_schedule_" + active_object_id].cells(id,ind).setAttribute("validation", "");
            return true;
        });

        var filter = '';
        var counter = 0;
        $.each(rate_schedule_grid_result[0][10].split(','), function(index, value) {
            filter += (counter == 0) ? '' : ',';
            filter += '#text_filter';
            counter++;
        })
        setup_transportation_path.details_tabs["rate_schedule_" + active_object_id].attachHeader(filter);

        setup_transportation_path.details_tabs["rate_schedule_" + active_object_id].init(); 
        setup_transportation_path.details_tabs["rate_schedule_" + active_object_id].enableHeaderMenu(); 
        setup_transportation_path.details_tabs["rate_schedule_" + active_object_id].setColumnsVisibility(rate_schedule_grid_result[0][9]);        
        setup_transportation_path.details_tabs["rate_schedule_" + active_object_id].attachEvent("onRowSelect", function(id, ind) { 
            var cm_param = {
                "action": "spa_contract_group", 
                "flag": "r", 
                "counterparty_id": setup_transportation_path.details_tabs["rate_schedule_" + active_object_id].cells(id, 1).getValue()
            };

            cm_param = $.param(cm_param);
            var url1 = js_dropdown_connector_url + '&' + cm_param;
            var combo_obj1 = setup_transportation_path.details_tabs["rate_schedule_" + active_object_id].cells(id, 2).getCellCombo();
            // combo_obj1.clearAll();
            combo_obj1.selectOption(0);
            combo_obj1.enableFilteringMode("between", null, false);
            combo_obj1.load(url1);


            if (edit_permission) {                   
                setup_transportation_path["rate_schedule_toolbar_" + active_object_id].setItemEnabled('delete');         
            } else {
                setup_transportation_path["rate_schedule_toolbar_" + active_object_id].setItemDisabled('delete');
            }
        });

         //Loading dropdown for Counterparty in grid
        var cm_param = {
            "action": "[spa_getsourcecounterparty]", 
            "flag": "s",
            "has_blank_option": "false"
        };

        cm_param = $.param(cm_param);
        var url = js_dropdown_connector_url + '&' + cm_param;
        var combo_obj = setup_transportation_path.details_tabs["rate_schedule_" + active_object_id].getColumnCombo(1);

        combo_obj.attachEvent('onChange', function(){
            var cm_param = {
                "action": "spa_contract_group", 
                "flag": "r", 
                "counterparty_id": combo_obj.getSelectedValue()
            };

            cm_param = $.param(cm_param);
            var url1 = js_dropdown_connector_url + '&' + cm_param;
            var rid = setup_transportation_path.details_tabs["rate_schedule_" + active_object_id].getSelectedRowId();
            setup_transportation_path.details_tabs["rate_schedule_" + active_object_id].cells(rid, 2).setValue('');
            var combo_obj1 = setup_transportation_path.details_tabs["rate_schedule_" + active_object_id].cells(rid, 2).getCellCombo();
            // combo_obj1.clearAll();
            combo_obj1.selectOption(0);
            combo_obj1.enableFilteringMode("between", null, false);
            combo_obj1.load(url1);
        }); 
        combo_obj.enableFilteringMode("between", null, false);
        combo_obj.load(url, function(){
            //Loading dropdown for Contract in grid
            var cm_param = {
                "action": "spa_contract_group", 
                "flag": "r", 
                "counterparty_id": combo_obj.getSelectedValue()
            };

            cm_param = $.param(cm_param);
            var url1 = js_dropdown_connector_url + '&' + cm_param;
            var combo_obj1 = setup_transportation_path.details_tabs["rate_schedule_" + active_object_id].getColumnCombo(2);                
            combo_obj1.enableFilteringMode("between", null, false);
            combo_obj1.load(url1, function() {
                //Loading dropdown for rate Schedule in grid
                var cm_param = {
                    "action": "spa_transportation_rate_schedule", 
                    "flag": "c" 
               
                };

                cm_param = $.param(cm_param);
                var url2 = js_dropdown_connector_url + '&' + cm_param;
                var combo_obj2 = setup_transportation_path.details_tabs["rate_schedule_" + active_object_id].getColumnCombo(3);                
                combo_obj2.enableFilteringMode("between", null, false);
                combo_obj2.load(url2, function() {
                    refresh_grid_rate_schedule();
                });
                refresh_grid_rate_schedule();
            });
            refresh_grid_rate_schedule();
        });
    }
    
    function refresh_grid_rate_schedule() {
        var active_tab_id = setup_transportation_path.dp_tab.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id; 
        var path_id = setup_transportation_path.details_form["single_form_" + active_object_id].getItemValue('path_id');
        var flag = 'j';
        var sql_param = {
            "flag": flag,
            "action":"spa_counterparty_contract_rate_schedule",
            "grid_type":"g",
            "path_id": path_id,
        };
        sql_param = $.param(sql_param);
        var sql_url = js_data_collector_url + "&" + sql_param;
        setup_transportation_path.details_tabs["rate_schedule_" + active_object_id].clearAll();
        setup_transportation_path.details_tabs["rate_schedule_" + active_object_id].load(sql_url, function() {
            setup_transportation_path.details_tabs["rate_schedule_" + active_object_id].filterByAll();
        });   
    }
    
    /**
    * Function enable/disable menu.
    */
    function set_setup_transportation_path_menu_disabled(item_id, bool) {
        if (bool == false) {
            setup_transportation_path.transportation_path_menu.setItemDisabled(item_id);    
        } else {
            setup_transportation_path.transportation_path_menu.setItemEnabled(item_id);
        }
    }

    //Custom Validation rule
    $(function() {  
        //for form validation.
        ValidatePositiveInteger = function(data){
            // data should be positive
            return(parseFloat(data) >= 0);
        };
    });
     
    /**
    * Function defined in backend.
    */ 
    open_single_path = function(path_id) {

        var data = {
            "action": "spa_setup_delivery_path",
            "flag": "g",
            "single_path_id": path_id,
            "path_type": 1
        };
        
        adiha_post_data('return_array', data, '', '', 'single_path_form_tab');
    }

    open_group_path = function(path_id, tab_name) {
        var tab_id = 'tab_' + path_id;
        var tab_label = tab_name;

        setup_transportation_path.dp_tab.addTab(tab_id, tab_label, null, null, true, true);  

        var icon_loc = '../../../../adiha.php.scripts/components/lib/adiha_dhtmlx/themes/' + theme_selected + '/imgs/dhxtoolbar_web/'; 
                 
        win = setup_transportation_path.dp_tab.cells(tab_id);
        setup_transportation_path.pages[tab_id] = win;      
        var active_object_id = path_id;
        setup_transportation_path["inner_tab_layout_" + active_object_id] = win.attachLayout("1C");
        setup_transportation_path["inner_tab_layout_" + active_object_id].cells('a').setHeight(500);
        setup_transportation_path["inner_tab_layout_" + active_object_id].cells('a').hideHeader()
        
        form_toolbar = setup_transportation_path["inner_tab_layout_" + active_object_id].cells('a').attachToolbar();                
        form_toolbar.setIconsPath(image_path + 'dhxmenu_web/');    
        
        form_toolbar.loadStruct([
            { id: 'save', type: 'button', img: 'save.gif', imgdis:"save_dis.gif", text: 'Save', title: 'Save'}
        ]);
        
        if (!edit_permission) {
            form_toolbar.disableItem('save');
        }  
                  
        form_toolbar.attachEvent('onClick', setup_transportation_path.save_click);                
        load_group_path_detail();
    }

    /**
    * Call back function to open single path tab.
    */
    function single_path_form_tab(result) {
        var passed_path_id = result[0][3];
        var tab_id = 'tab_' + passed_path_id;
        var tab_label = result[0][1];

        // console.log(setup_transportation_path.dp_tab.getAllTabs());

        if (setup_transportation_path.dp_tab.getAllTabs().indexOf(tab_id) != -1) {
            setup_transportation_path.dp_tab.cells(tab_id).setActive();
            return;
        }
        
        setup_transportation_path.dp_tab.addTab(tab_id, tab_label, null, null, true, true);  
        var icon_loc = '../../../../adiha.php.scripts/components/lib/adiha_dhtmlx/themes/' + theme_selected + '/imgs/dhxtoolbar_web/';     
                 
        win = setup_transportation_path.dp_tab.cells(tab_id);
        setup_transportation_path.pages[tab_id] = win;      
        var active_object_id = passed_path_id;
        setup_transportation_path["inner_tab_layout_" + active_object_id] = win.attachLayout("1C");
        setup_transportation_path["inner_tab_layout_" + active_object_id].cells('a').setHeight(500);
        setup_transportation_path["inner_tab_layout_" + active_object_id].cells('a').hideHeader()
        
        form_toolbar = setup_transportation_path["inner_tab_layout_" + active_object_id].cells('a').attachToolbar();                
        form_toolbar.setIconsPath(image_path + 'dhxmenu_web/');    
        
        form_toolbar.loadStruct([
            { id: 'save', type: 'button', img: 'save.gif', imgdis:"save_dis.gif", text: 'Save', title: 'Save'}
        ]);
        
        if (!edit_permission) {
            form_toolbar.disableItem('save');
        }  
        
        form_toolbar.attachEvent('onClick', setup_transportation_path.save_click);
        
        var xml_value =  '<Root><PSRecordset path_id="' + passed_path_id + '"></PSRecordset></Root>';

        data = {
            "action": "spa_create_application_ui_json",
            "flag": "j",
            "application_function_id": application_function_id,
            "template_name": 'SetupTransportationPath',
            "parse_xml": xml_value
        };
        
        result = adiha_post_data('return_array', data, '', '', 'setup_transportation_path.load_form_data');
    }
</script> 