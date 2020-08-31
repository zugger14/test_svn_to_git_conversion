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
    $netting_tree = new AdihaTree();
    $tabbar_obj = new AdihaTab();
    $menu_obj = new AdihaMenu();
    
    $name_space = 'netting_asset_liab_group';
    $toolbar_name = 'toolbar_netting';
    $netting_tree_name = 'netting_tree';
    $tabbar_name = 'netting_details';
    $grouping_list = 'parent_netting_id:netting_parent_group_name,netting_id:netting_group_name';
    $additional_param = 'flag=g';
	$form_name = 'frm_netting';
    $layout_name = 'netting_layout';
    $menu_name = 'netting_menu';
    
    $rights_setup_netting_group = 10101500;    
    $rights_setup_netting_group_UI = 10101510;
    $rights_setup_netting_group_delete = 10101511;
   
    list (
        $has_rights_setup_netting_group, 
        $has_rights_setup_netting_group_UI,
        $has_rights_setup_netting_group_delete
    ) = build_security_rights(
        $rights_setup_netting_group, 
        $rights_setup_netting_group_UI,
        $rights_setup_netting_group_delete
    );
  
    $enable_setup_netting_group_UI = ($has_rights_setup_netting_group_UI) ? 'false' : 'true';
    $enable_setup_netting_group_delete = ($has_rights_setup_netting_group_delete) ? 'false' : 'true';
    
    $layout_json = "[
                        {
                            id:             'a',
                            text:           'Setup Netting Group',
                            width:          250,
                            collapse:       false,
                            fix_size:       [false, null]
                        },
                        {
                            id:             'b',
                            text:           'Setup Netting Group',
                            width:          250,
                            collapse:       false,
                            fix_size:       [false, null]
                        }
                    ]";
    
    $tree_toolbar_json =  '[
                            {id:"t1", text:"Edit", img:"edit.gif", items:[
                                {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add", disabled: ' . $enable_setup_netting_group_UI . '},
                                {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete", disabled:"true"}
                            ]}
                        ]';
        
    echo $layout_obj->init_layout($layout_name, '', '2U', $layout_json, $name_space);
    echo $layout_obj->attach_menu_cell($menu_name, 'a');
    echo $layout_obj->attach_tree_cell($netting_tree_name, 'a');
    echo $layout_obj->attach_form($form_name, 'b');
	
    echo $menu_obj->init_by_attach($menu_name, $name_space);
    echo $menu_obj->load_menu($tree_toolbar_json);
    echo $menu_obj->attach_event('', 'onClick', $name_space . '.grid_toolbar_click');
        
    echo $netting_tree->init_by_attach($netting_tree_name, $name_space);
    echo $netting_tree->load_tree_xml('spa_netting_parent_groups', 'netting_detail_id:netting_detail_name', $grouping_list, $additional_param);
    echo $netting_tree->attach_event('', 'onDblClick', $name_space . '.open_detail');
    echo $netting_tree->attach_event('', 'onCheck', $name_space . '.single_check');
    echo $netting_tree->enable_checkbox();
    echo $netting_tree->enable_multi_selection('true');
    echo $netting_tree->load_tree_functions();
	
    echo $layout_obj->attach_tab_cell($tabbar_name, 'b');
    echo $tabbar_obj->init_by_attach($tabbar_name, $name_space);
    echo $tabbar_obj->enable_tab_close();
    echo $tabbar_obj->attach_event('', 'onTabClose', 'netting_asset_liab_group.details_close');
   
    echo $layout_obj->close_layout();
?>
<body></body>
<script type="text/javascript">
    netting_asset_liab_group.netting_layout_form = {};
    netting_asset_liab_group.netting_grid = {};
    netting_asset_liab_group.netting_child_grid = {};
    netting_asset_liab_group.check_new_tab = {};
    netting_asset_liab_group.delete_subsidiary_flag = {};
    netting_asset_liab_group.delete_contract_flag = {};
    
    var php_script_loc = '<?php echo $php_script_loc; ?>';
    var new_tab_name = '';
    var node_level = '';
    var netting_flag = '';
	var theme_selected = 'dhtmlx_' + default_theme;
    var enable_setup_netting_group_UI = <?php echo ($has_rights_setup_netting_group_UI) ? 'false' : 'true'; ?>;
    var enable_setup_netting_group_delete = <?php echo ($has_rights_setup_netting_group_delete) ? 'false' : 'true'; ?>;
    /**
    *enable_setup_netting_group_delete is to check only for enabling save button after save
    *
    **/
    var enable_setup_netting_group_IU = <?php echo $has_rights_setup_netting_group_UI; ?>
    
    $(function() {
		netting_asset_liab_group.netting_layout.cells('a').setWidth(300);
	});
    
    //Prevent multi check in treeview
    netting_asset_liab_group.single_check = function (id, state) {
        var all_checked = netting_asset_liab_group.netting_tree.getAllChecked();
        if (enable_setup_netting_group_delete == false && state == 1) {
            netting_asset_liab_group.netting_menu.setItemEnabled("delete");
        }
        if (state == 0 && all_checked == '') {
            netting_asset_liab_group.netting_menu.setItemDisabled("delete");
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
    netting_asset_liab_group.open_detail = function(id, unused, tab_label, level) {
        netting_asset_liab_group.netting_tree.enableSingleRadioMode(true);
        var node_id = id;//netting_asset_liab_group.netting_tree.getSelectedItemId();
        var hierarchy_level = typeof level !== 'undefined' ? level : netting_asset_liab_group.netting_tree.getLevel(id);
        var group_name = '';
        var node_id_array = [];
        var id_array = [];
        var add_new_tab = 0;
        if (node_id != null){
            node_id_array = node_id.split('_');
            id_array = id.split('_');
        } 
        
        current_node_id = node_id_array[hierarchy_level - 1];
        var icon_loc = '../../../adiha.php.scripts/components/lib/adiha_dhtmlx/themes/' + theme_selected + '/imgs/dhxtoolbar_web/';

        if (!netting_asset_liab_group.pages[id]) {
            var tab_name = typeof tab_label !== 'undefined' ? tab_label : netting_asset_liab_group.netting_tree.getSelectedItemText();
           // alert( tab_label + ' ' + typeof mode +' '+ netting_asset_liab_group.netting_tree.getSelectedItemText() + ' ');
            //Add New Parent
            if (id_array[0] == -1) {
                hierarchy_level = 1;
                current_node_id = 0;                
                tab_name = 'New Parent Netting';
            }
            //Add New Child
            if (id_array[1] == -1) {
                hierarchy_level = 2;
                current_node_id = 0;                
                tab_name = 'New Child Netting';
            }
            //Add New GChild
            if (id_array[2] == -1) {
                hierarchy_level = 3;
                current_node_id = 0;
                tab_name = 'New Detail Netting';
            }

            netting_asset_liab_group.netting_details.addTab(id, tab_name, null, null, true, true);
            win = netting_asset_liab_group.netting_details.cells(id);
            netting_asset_liab_group.pages[id] = win;
            var active_tab_id = netting_asset_liab_group.netting_details.getActiveTab();
			
            if (hierarchy_level == 1) {
                netting_layout = win.attachLayout("2E");
                netting_layout.cells('a').setHeight(300);
                netting_layout.cells('b').hideHeader();
                form_toolbar = netting_layout.cells('a').attachToolbar();
				form_toolbar.setIconsPath(icon_loc);
				form_toolbar.loadStruct([
				    { id: 'save', type: 'button', img: 'save.gif', imgdis: 'save_dis.gif', text:'Save', title: 'Save', disabled: enable_setup_netting_group_UI}
				]);
				form_toolbar.attachEvent('onClick', netting_asset_liab_group.netting_toolbar_click);
               
                netting_parent_menu = netting_layout.cells('b').attachMenu({icons_path: js_image_path + "dhxmenu_web/"});
                netting_parent_menu.loadStruct([
                    {id:"parent_menu", text:"Edit", img:"edit.gif", items:[
                        {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add", disabled: enable_setup_netting_group_UI},
                        {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete", disabled: true}
                    ]},
                    {id:"parent_export", text:"Export", img:"export.gif", items:[
                        {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                        {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                    ]}
                ]);
				
                netting_parent_menu.attachEvent('onClick', netting_asset_liab_group.grid_toolbar_parent_click);

                netting_asset_liab_group.netting_grid["grid_" + active_tab_id] = netting_layout.cells('b').attachGrid();
                netting_asset_liab_group.netting_grid["grid_" + active_tab_id].setImagePath(php_script_loc + "components/lib/adiha_dhtmlx/themes/"+theme_selected+"/imgs/dhxtoolbar_web/");
                                    
                netting_asset_liab_group.netting_grid["grid_" + active_tab_id].setHeader("netting_parent_group_id,Subsidiary");
                netting_asset_liab_group.netting_grid["grid_" + active_tab_id].setInitWidths("*");
                netting_asset_liab_group.netting_grid["grid_" + active_tab_id].setColTypes("ro,combo");
                
                netting_asset_liab_group.netting_grid["grid_" + active_tab_id].setColSorting("na,str");
                netting_asset_liab_group.netting_grid["grid_" + active_tab_id].setColumnsVisibility("true,false");
                netting_asset_liab_group.netting_grid["grid_" + active_tab_id].setInitWidths('0,500');
                netting_layout.cells('b').attachStatusBar({
                                        height: 30,
                                        text: '<div id="pagingArea_b"></div>'
                                    });
                netting_asset_liab_group.netting_grid["grid_" + active_tab_id].setImagePath(php_script_loc + "components/lib/adiha_dhtmlx/themes/"+theme_selected+"/imgs/dhxgrid_web/");
                netting_asset_liab_group.netting_grid["grid_" + active_tab_id].enablePaging(true, 100, 0, 'pagingArea_b');
                netting_asset_liab_group.netting_grid["grid_" + active_tab_id].setPagingSkin('toolbar');
                netting_asset_liab_group.netting_grid["grid_" + active_tab_id].enableMultiselect(true);
                netting_asset_liab_group.netting_grid["grid_" + active_tab_id].attachEvent('onSelectStateChanged', netting_asset_liab_group.enable_disable_delete);
                netting_asset_liab_group.netting_grid["grid_" + active_tab_id].init();

                //load combo
                var cm_param = {
                                    "action": "[spa_generic_mapping_header]",
                                    "flag": "n",
                                    "combo_sql_stmt": "EXEC spa_Get_All_Subsidiaries @flag='g'",
                                    "call_from": "grid"
                                };
                cm_param = $.param(cm_param);
                var url = js_dropdown_connector_url + '&' + cm_param;
                
                var combo_obj = netting_asset_liab_group.netting_grid["grid_" + active_tab_id].getColumnCombo(1);
                combo_obj.enableFilteringMode("between", null, false);
                combo_obj.load(url);
                
                setTimeout(netting_asset_liab_group.refresh_parent_grid, 500);
                
            } else if (hierarchy_level == 2) {
                netting_layout = win.attachLayout("2E");                
                
                netting_layout.cells('b').hideHeader();
                
                form_toolbar = netting_layout.cells('a').attachToolbar();                 
                
				form_toolbar.setIconsPath(icon_loc);					
				
                form_toolbar.loadStruct([
					{ id: 'save', type: 'button', img: 'save.gif', imgdis: 'save_dis.gif', text:'Save', title: 'Save', disabled: enable_setup_netting_group_UI}
				]);
                
				form_toolbar.attachEvent('onClick', netting_asset_liab_group.netting_toolbar_click); 
               
                netting_layout.cells('a').setHeight(300);
                /*
                grid_toolbar_child = netting_layout.cells('b').attachToolbar();    
				grid_toolbar_child.setIconsPath(icon_loc);				
				
                grid_toolbar_child.loadStruct([
					{ id: 'new', type: 'button', img: 'new.gif', text:'Add', title: 'Add'},
					{ type: "separator" },
					{ id: 'delete', type: 'button', img: 'trash.gif', text:'Delete', title: 'Delete'}
				]);
				
                grid_toolbar_child.attachEvent('onClick', netting_asset_liab_group.grid_toolbar_child_click);
                
                */
                netting_child_menu = netting_layout.cells('b').attachMenu({
                                                                           icons_path: js_image_path + "dhxmenu_web/"
                                                                        });
                
                netting_child_menu.loadStruct([
                            
                            {id:"child_menu", text:"Edit", img:"edit.gif", items:[
                            {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add", disabled: enable_setup_netting_group_UI},
                            {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete", disabled: true}
                        ]},
                        {id:"child_export", text:"Export", img:"export.gif", 
                            items:[
                                {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                                {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                             ]
                        }
                        
                ]);
				
                netting_child_menu.attachEvent('onClick', netting_asset_liab_group.grid_toolbar_child_click);
				
                netting_asset_liab_group.netting_child_grid["grid_" + active_tab_id] = netting_layout.cells('b').attachGrid();
                netting_asset_liab_group.netting_child_grid["grid_" + active_tab_id].setImagePath(php_script_loc + "components/lib/adiha_dhtmlx/themes/"+theme_selected+"/imgs/dhxtoolbar_web/");
                                
                netting_asset_liab_group.netting_child_grid["grid_" + active_tab_id].setHeader("ID,Contract Name");
                netting_asset_liab_group.netting_child_grid["grid_" + active_tab_id].setInitWidths("*");
                netting_asset_liab_group.netting_child_grid["grid_" + active_tab_id].setColTypes("ro,combo");
                netting_asset_liab_group.netting_child_grid["grid_" + active_tab_id].setColSorting("istr,str");
                netting_asset_liab_group.netting_child_grid["grid_" + active_tab_id].setColumnsVisibility("true,false");
                netting_asset_liab_group.netting_child_grid["grid_" + active_tab_id].setInitWidths('0,500');
                netting_layout.cells('b').attachStatusBar({
                                        height: 30,
                                        text: '<div id="pagingArea_c"></div>'
                                    });
                netting_asset_liab_group.netting_child_grid["grid_" + active_tab_id].setImagePath(php_script_loc + "components/lib/adiha_dhtmlx/themes/"+theme_selected+"/imgs/dhxgrid_web/");
                netting_asset_liab_group.netting_child_grid["grid_" + active_tab_id].enablePaging(true, 100, 0, 'pagingArea_c'); 
                netting_asset_liab_group.netting_child_grid["grid_" + active_tab_id].setPagingSkin('toolbar');
                
                netting_asset_liab_group.netting_child_grid["grid_" + active_tab_id].attachEvent('onSelectStateChanged', netting_asset_liab_group.enable_disable_delete)
                        
                netting_asset_liab_group.netting_child_grid["grid_" + active_tab_id].enableMultiselect(true);
                netting_asset_liab_group.netting_child_grid["grid_" + active_tab_id].init();
                                
                //load combo                               
                var cm_param = {
                    "action":"[spa_generic_mapping_header]", 
                    "flag":"n",
                    "combo_sql_stmt" : "EXEC spa_source_contract_detail 'r'",
                    "call_from": "grid"};
                cm_param = $.param(cm_param);
                var url = js_dropdown_connector_url + '&' + cm_param;
                
                var combo_obj = netting_asset_liab_group.netting_child_grid["grid_" + active_tab_id].getColumnCombo(1);   
                combo_obj.enableFilteringMode("between", null, false);             
                combo_obj.load(url);
                
                //setTimeout is use to load label in combo rather than value
                setTimeout(netting_asset_liab_group.refresh_child_grid, 500);
                
            } else {
                netting_layout = win.attachLayout("1C");
				form_toolbar = netting_layout.cells('a').attachToolbar();
				form_toolbar.setIconsPath(icon_loc);
				
                form_toolbar.loadStruct([
				    {id: 'save', type: 'button', img: 'save.gif', imgdis: 'save_dis.gif', text: 'Save', title: 'Save', disabled: enable_setup_netting_group_UI}
				]);
				
                form_toolbar.attachEvent('onClick', netting_asset_liab_group.netting_toolbar_click);
                netting_layout.cells('a').setHeight(300);
            }

            if (hierarchy_level == 1) {
                group_name = 'Parent Netting Group';
    			data = {
                            "action": "spa_create_application_ui_json",
                            "flag": "j",
                            "application_function_id": "10101500",
                            "template_name": "netting_asset_liab_parent_group",
                            "parse_xml": "<Root><PSRecordSet netting_parent_group_id=\"" + current_node_id + "\"></PSRecordSet></Root>",
                            "group_name": group_name
                        };
            } else if (hierarchy_level == 2) {
                group_name = 'Netting Group';
				data =  {
                            "action": "spa_create_application_ui_json",
                            "flag": "j",
                            "application_function_id": "10101512",
                            "template_name": "netting_asset_liab_group",
                            "parse_xml": "<Root><PSRecordSet netting_group_id=\"" + current_node_id + "\"></PSRecordSet></Root>",
                            "group_name": group_name
                        };
            } else {
                group_name = 'Netting Rules';
				data = {
                        "action": "spa_create_application_ui_json",
                        "flag": "j",
                        "application_function_id": "10101514",
                        "template_name": "netting_asset_liab_group_detail",
                        "parse_xml": "<Root><PSRecordSet netting_group_detail_id=\"" + current_node_id + "\"></PSRecordSet></Root>",
                        "group_name": group_name
                    };
            }
            adiha_post_data('return_array', data, '', '', 'show_netting_tab', '');
        } else {
            netting_asset_liab_group.netting_details.cells(id).setActive();
        }
    }
    
    
    netting_asset_liab_group.enable_disable_delete = function(id) {
        var active_tab_id = netting_asset_liab_group.netting_details.getActiveTab();
        
        inner_tab_obj = netting_asset_liab_group.netting_details.cells(active_tab_id).getAttachedObject();
  
        if (inner_tab_obj instanceof dhtmlXLayoutObject) {
            subs_menu = inner_tab_obj.cells("b").getAttachedMenu();
            
            grid_layout = inner_tab_obj.cells("b").getAttachedObject();
            
            if(grid_layout instanceof dhtmlXGridObject) {
                
                seletced_subs = grid_layout.getSelectedRowId();
                if (enable_setup_netting_group_UI == false && seletced_subs) {   
                    subs_menu.setItemEnabled("delete");
                } else {
                    subs_menu.setItemDisabled("delete");
                }            
            }
        } 
    }
    
    function show_netting_tab(result) {       
		var active_tab_id = netting_asset_liab_group.netting_details.getActiveTab();
	
		//['form' + active_tab_id]
		var result_length = result.length;
		
		var tab_json = '';
		for (i = 0; i < result_length; i++) {
			if (i > 0)
				tab_json = tab_json + ",";
			tab_json = tab_json + (result[i][1]);
		}

		tab_json = '{tabs: [' + tab_json + ']}';
		netting_layout_tab = netting_layout.cells("a").attachTabbar({mode:"bottom",arrows_mode:"auto"});
		netting_layout_tab.loadStruct(tab_json);
	
		for (j = 0; j < result_length; j++) {
			tab_id = 'detail_tab_' + result[j][0];
			netting_asset_liab_group.netting_layout_form["form_" + active_tab_id] = netting_layout_tab.cells(tab_id).attachForm();
			
			if (result[j][2]) {
				netting_asset_liab_group.netting_layout_form["form_" + active_tab_id].loadStruct(result[j][2]);
			}
		}   
    }
	
    netting_asset_liab_group.grid_toolbar_parent_click = function(id) {
         var active_tab_id = netting_asset_liab_group.netting_details.getActiveTab();
         switch(id) {
            case "browse":
                subsidiary_popup = new dhtmlXPopup();
                subsidiary_popup.attachHTML('<iframe style="width:500px;height:300px;" src="../../../adiha.php.scripts/components/lib/treeview_3.0.php?call_from=netting"></iframe>');
                subsidiary_popup.show(500, 170, 50, 50);  
         
            break;
            case "add":
                var new_id = (new Date()).valueOf();            
                netting_asset_liab_group.netting_grid["grid_" + active_tab_id].addRow(new_id, '');              
                                
            break;
            case "delete":
                if (netting_asset_liab_group.netting_grid["grid_" + active_tab_id].getSelectedRowId() != '') {                
                    netting_asset_liab_group.netting_grid["grid_" + active_tab_id].deleteSelectedRows();
                    netting_asset_liab_group.delete_subsidiary_flag["grid_" + active_tab_id] = 1;
                }
                
            break;
            case "excel":                        
                netting_asset_liab_group.netting_grid["grid_" + active_tab_id].toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
              
            break;
            case "pdf":                
                netting_asset_liab_group.netting_grid["grid_" + active_tab_id].toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                        
            break;
            default:
        }           
    }
    
    function callback_bookstructure_popup(book_array) {
        var selected_subsidiary = book_array['selected_subsidiary'];
        var active_tab_id = netting_asset_liab_group.netting_details.getActiveTab();
        var selected_subsidiary_array = selected_subsidiary.split(',');
        var new_id = '';
        
        for(i = 0; i < selected_subsidiary_array.length; i++) {
            new_id = (new Date()).valueOf();
            netting_asset_liab_group.netting_grid["grid_" + active_tab_id].addRow(new_id, ['', selected_subsidiary_array[i]], netting_asset_liab_group.netting_grid["grid_" + active_tab_id].getRowsNum());
        }
        netting_asset_liab_group.netting_grid["grid_" + active_tab_id].selectRow(netting_asset_liab_group.netting_grid["grid_" + active_tab_id].getRowIndex(new_id), false, false, true);
        
        subsidiary_popup.hide();
    }
    
    netting_asset_liab_group.grid_toolbar_child_click = function(id) {
         var active_tab_id = netting_asset_liab_group.netting_details.getActiveTab();
         
         switch(id) {
            case "add":
                var new_id = (new Date()).valueOf(); 
                netting_asset_liab_group.netting_child_grid["grid_" + active_tab_id].addRow(new_id, '');  
            break;
            case "delete":
                if (netting_asset_liab_group.netting_child_grid["grid_" + active_tab_id].getSelectedRowId() != '') {                
                    netting_asset_liab_group.netting_child_grid["grid_" + active_tab_id].deleteSelectedRows();
                    netting_asset_liab_group.delete_contract_flag["grid_" + active_tab_id] = 1;
                }
            break;            
            case "excel":
                netting_asset_liab_group.netting_child_grid["grid_" + active_tab_id].toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
              
            break;
            case "pdf":
                netting_asset_liab_group.netting_child_grid["grid_" + active_tab_id].toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                        
            break;
            default:
        }   
    }
	
	netting_asset_liab_group.netting_toolbar_click = function(id) {
        // console.log(netting_asset_liab_group.netting_layout.netting_details);
	    var active_tab_id = netting_asset_liab_group.netting_details.getActiveTab();
        switch(id) {
            case "save":
                form_data = netting_asset_liab_group.netting_layout_form["form_" + active_tab_id].getFormData();
				var filter_param = '';
				var comma = '';
                var active_tab_id_array = [];
                
                active_tab_id_array = active_tab_id.split('_');
                
                netting_flag = 'u';
                
                if (active_tab_id_array[0] == -1 || active_tab_id_array[1] == -1 || active_tab_id_array[2] == -1) {
                    netting_flag = 'i';
                }
                
                for (var a in form_data) {
					if (form_data[a] != '' && form_data[a] != null) {
						if (netting_asset_liab_group.netting_layout_form["form_" + active_tab_id].getItemType(a) == 'calendar') {
							value = netting_asset_liab_group.netting_layout_form["form_" + active_tab_id].getItemValue(a, true);
						} else {
							value = form_data[a];
						}
						
						filter_param += "&" + a + '=' + value;
                        
                        //get new tab name 
                        if (a == 'netting_parent_group_name' ) {
                            new_tab_name = value;
                            node_level = 1; 
                            
                        } else if ( a == 'netting_group_name') {
                            new_tab_name = value;
                            node_level = 2;
                           
                        } else if (a == 'source_counterparty_id') {                                  
                            node_level = 3;  
                            new_tab_name = netting_asset_liab_group.netting_layout_form["form_" + active_tab_id].getCombo("source_counterparty_id").getComboText();
                        }
                                                                                 
                    }
				}
				
                var delete_grid_name = '';
                
                if (active_tab_id_array[0] != 0 && active_tab_id_array[1] == 0 && active_tab_id_array[2] == 0) { 
                    //parent
                                        
                    var grid_subsidiary = '';
                    //check for mandatory fields
                    
                    var valid_return = validate_form(netting_asset_liab_group.netting_layout_form["form_" + active_tab_id])
                    if (!valid_return) {
                        generate_error_message();
                        return;
                    }
                    
                    for (var row_index = 0; row_index < netting_asset_liab_group.netting_grid["grid_" + active_tab_id].getRowsNum(); row_index++) {  
                        grid_subsidiary = grid_subsidiary + comma + netting_asset_liab_group.netting_grid["grid_" + active_tab_id].cells2(row_index, 1).getValue();
                        comma = ',';                        
                    }
                    
                    if (check_duplicate_data(grid_subsidiary)) {
                        show_messagebox('There is duplicate data in grid.');                        
                        return;
                    }
                    
                    delete_grid_name = 'subsidiary';                    
                    var param = {
    					"flag": netting_flag,
    					"action": '[spa_netting_parent_groups]',
    					"subsidiary_ids": grid_subsidiary
				    };          
                    
                } else if (active_tab_id_array[0] != 0 && active_tab_id_array[1] != 0 && active_tab_id_array[2] == 0) {
                    //Child
                    
                    //check for mandatory fields
                    var valid_return = validate_form(netting_asset_liab_group.netting_layout_form["form_" + active_tab_id]);
                    if (!valid_return) {
                        generate_error_message();
                        return;
                    }
                    
                    var grid_contract = '';
                    comma = '';
                    for (var row_index = 0; row_index < netting_asset_liab_group.netting_child_grid["grid_" + active_tab_id].getRowsNum(); row_index++) {  
                        grid_contract = grid_contract + comma + netting_asset_liab_group.netting_child_grid["grid_" + active_tab_id].cells2(row_index, 1).getValue();
                        comma = ',';
                    }
                    
                    if (check_duplicate_data(grid_contract)) {
                        show_messagebox('There is duplicate data in grid.');                        
                        return;
                    }
                    
                    delete_grid_name = 'contract'; 
                    var param = {
                        "flag": netting_flag,
                        "action": '[spa_netting_groups]',
                        "contract_ids": grid_contract                 
                    };
                      
                } else {                
                    
                    //check for mandatory fields
                    var valid_return = validate_form(netting_asset_liab_group.netting_layout_form["form_" + active_tab_id]);
                    if (!valid_return) {
                        generate_error_message();
                        return;
                    }
                    
                    //GChild
                    var param = {
					"flag": netting_flag,
					"action": '[spa_netting_group_detail]'
					
				    };
                }
                
                if (active_tab_id_array[1] == -1) {
                    filter_param += '&netting_parent_group_id=' + active_tab_id_array[0];
                }
                if (active_tab_id_array[1] != -1 && active_tab_id_array[2] == -1) {
                    filter_param += '&netting_group_id=' + active_tab_id_array[1];
                }
				param = $.param(param);
				param = param + filter_param;
				param = deparam(param);
                success_callback = 'refresh_tree_netting';
                
                
                if (netting_asset_liab_group.delete_subsidiary_flag["grid_" + active_tab_id] == 1 
                    || netting_asset_liab_group.delete_contract_flag["grid_" + active_tab_id] == 1) {   
                    
                    var del_msg =  "Some data has been deleted from " + delete_grid_name + " grid. Are you sure you want to save?";
                    
                    dhtmlx.message({
                        type: "confirm-warning",
                        text: del_msg,
                        title: "Warning",
                        callback: function(result) {
                            if (result) {
                                adiha_post_data('alert', param, 'Changes have been saved successfully.', '', success_callback, '', del_msg);
                                netting_asset_liab_group.delete_subsidiary_flag["grid_" + active_tab_id] = 0;
                                netting_asset_liab_group.delete_contract_flag["grid_" + active_tab_id] = 0; 
                            }                            
                        } 
                    });                    
                   
                   
                    
                } else {
                    adiha_post_data('alert', param, 'Changes have been saved successfully.', '', success_callback);

                }
                delete netting_asset_liab_group.pages[active_tab_id];
                break;
            default:
                show_messagebox(id);
        }
    }
    
    function check_duplicate_data(check_data) {
        var check_data_array = check_data.split(',');
        //1. sorting / map
        var check_data_array_sorted = check_data_array.sort();
       
        for (index = 1; index < check_data_array_sorted.length; index++) {
            if (check_data_array_sorted[index - 1] == check_data_array_sorted[index]) {
                return 1;
            }
        }
        return 0;
    }
	
    function refresh_tree_netting(response_data) {
        if (enable_setup_netting_group_IU) {
            form_toolbar.enableItem('save');
        }

        if(response_data[0].errorcode != 'Success') return;

        var active_tab_id = netting_asset_liab_group.netting_details.getActiveTab();
        active_tab_id_array = active_tab_id.split('_');
        var netting_flag = 'u';

        if (active_tab_id_array[0] == -1 || active_tab_id_array[1] == -1 || active_tab_id_array[2] == -1) {
            netting_asset_liab_group.open_detail(response_data[0].recommendation, '', new_tab_name, node_level);
            netting_asset_liab_group.netting_details.cells(response_data[0].recommendation).setActive();
            netting_asset_liab_group.netting_details.tabs(active_tab_id).close(true);
        } else {
            netting_asset_liab_group.netting_details.cells(active_tab_id).setText(new_tab_name);
        }

        netting_asset_liab_group.refresh_tree('spa_netting_parent_groups', 'netting_detail_id:netting_detail_name', 'parent_netting_id:netting_parent_group_name,netting_id:netting_group_name', 'flag=g');
    }
    
	netting_asset_liab_group.details_close = function(id) {
        delete netting_asset_liab_group.pages[id];
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
    }
	
	netting_asset_liab_group.grid_toolbar_click = function(id) {
        var selected_row = netting_asset_liab_group.netting_tree.getAllChecked();        
        var selected_row_array = [];
        var del_row_ids = [];
        
        switch(id) {
            case 'add':
                if (selected_row.indexOf(',') != -1) {
                    show_messagebox("Please select only one node!");
                    return;
                }

                selected_row = selected_row.replace('_0', '_-1');
                selected_row_array = selected_row.split('_');

                if (selected_row_array == '') {
                    //show new tab for parent
                    netting_asset_liab_group.open_detail('-1_0_0');
                } else if (selected_row_array[1] == '-1') {
                    //show new tab for child
                    netting_asset_liab_group.open_detail(selected_row);
                } else if (selected_row_array[2] == '-1') {
                    //show new tab for Gchild
                    netting_asset_liab_group.open_detail(selected_row);
                } else {
                    show_messagebox("No data can be insert under this node!");
                    return;
                }
            break;
            case 'delete':
                if (selected_row != '') {
                    dhtmlx.message({
                        type: (selected_row == '') ? "alert" : "confirm",
						title:(selected_row == '') ? "Alert" : "Confirmation",
						ok: (selected_row == '') ? "Ok" : "Confirm",
                        text: "Are you sure you want to delete?",
                        callback: function(result) {
                            if (result) {
                                var type_of_deletion = '';
                                selected_row = selected_row.split(',');
                                var wrong_level = 0;
                                selected_row.forEach(function(rid) {
                                    var has_child = netting_asset_liab_group.netting_tree.hasChildren(rid);
                                    if(has_child > 0) {
                                        var get_level = netting_asset_liab_group.netting_tree.getLevel(rid);
                                        wrong_level = get_level;
                                    }
                                    var detail_id = rid.split('_');
                                    if (detail_id[0] != 0 && detail_id[1] == 0 && detail_id[2] == 0) {
                                        type_of_deletion = 'netting_parent_groups';
                                        del_row_ids.push(detail_id[0]);
                                    } else if (detail_id[0] != 0 && detail_id[1] != 0 && detail_id[2] == 0) {
                                        type_of_deletion = 'netting_groups';
                                        del_row_ids.push(detail_id[1]);
                                    } else {
                                        type_of_deletion = 'netting_groups_detail';
                                        del_row_ids.push(detail_id[2]);
                                    }
                                });
                                del_row_ids = del_row_ids.toString();

                                if (wrong_level == 1) {
                                    success_call('Please delete netting groups first.', 'error');
                                    return;
                                } else if (wrong_level == 2) {
                                    success_call('Please delete netting groups details first.', 'error');
                                    return;
                                }

                                if (type_of_deletion == 'netting_parent_groups') {
                                    var param = {
                                        "action": 'spa_netting_parent_groups',
                                        "flag": 'd',
                                        "del_net_parent_grp_id": del_row_ids
                                    };
                                } else if (type_of_deletion == 'netting_groups') {
                                    var param = {
                                        "flag": 'd',
                                        "action": 'spa_netting_groups',
                                        "del_net_grp_id": del_row_ids
                                    };
                                } else {
                                    var param = {
                                        "flag": 'd',
                                        "action": 'spa_netting_group_detail',
                                        "del_net_grp_det_id": del_row_ids
                                    };
                                }

                                param = $.param(param);
                				param = deparam(param);
                				adiha_post_data('return_json', param, '', '', 'delete_netting_node');
                                
                                if(netting_asset_liab_group.pages[selected_row]) {
                                    netting_asset_liab_group.netting_details.tabs(selected_row).close();
                                    delete netting_asset_liab_group.pages[selected_row];
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
    
    function delete_netting_node(response_data) {
        response_data = JSON.parse(response_data);
        if (response_data[0].errorcode == 'Success') {
            var selected_row = netting_asset_liab_group.netting_tree.getAllChecked();
            selected_row = selected_row.split(',');
            selected_row.forEach(function(rid) {
                netting_asset_liab_group.netting_tree.deleteItem(rid);
            });
            success_call(response_data[0].message);
        } else {
            success_call(response_data[0].message, 'error');
            return;
        }
    }
    
    netting_asset_liab_group.refresh_parent_grid = function() {
        var active_tab_id = netting_asset_liab_group.netting_details.getActiveTab();
        var history_a_param = {
            "flag": "g",
            "action": "spa_Netting_Group_Parent_Subsidiary",
            "netting_parent_group_id": current_node_id
        };
        history_a_param = $.param(history_a_param);
        var history_a_url = js_data_collector_url + "&" + history_a_param;
        netting_asset_liab_group.netting_grid["grid_" + active_tab_id].loadXML(history_a_url);
    }
    
    netting_asset_liab_group.refresh_child_grid = function() {
        var active_tab_id = netting_asset_liab_group.netting_details.getActiveTab();
        var history_a_param = {
            "flag": "g",
            "action": "spa_netting_group_detail_contract",
            "netting_group_detail_id": current_node_id
        };
        history_a_param = $.param(history_a_param);
        var history_a_url = js_data_collector_url + "&" + history_a_param;
        netting_asset_liab_group.netting_child_grid["grid_" + active_tab_id].loadXML(history_a_url);
    }
</script>