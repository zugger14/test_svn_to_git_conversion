<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
        <?php require('../../../../../adiha.php.scripts/components/include.file.v3.php'); ?>
    </head>
    <style>
        .push_clear_button {
            margin-right: 8px !important;
        }
    </style>
    <body>
        <?php 
        require('../../../../../adiha.html.forms/_setup/manage_documents/manage.documents.button.php');       
        $rights_setup_hedge_rel = 10231900;
        $rights_setup_hedge_rel_ui = 10231910;
        $rights_setup_hedge_rel_delete = 10231912;
        $rights_document = 10102900;
        $rights_setup_hedge_item = 10231916;
		$rights_setup_hedge_item_add = 10231913;
		$rights_setup_hedge_item_delete = 10231915;
        $relation_id = get_sanitized_value($_GET['relation_id'] ?? 0);
        $eff_test_profile_id = get_sanitized_value($_GET['eff_test_profile_id'] ?? 'null');

        list (
            $has_rights_setup_hedge_rel_ui,
            $has_rights_setup_hedge_rel_delete,
            $has_document_rights,
            $has_rights_setup_hedge_item,
			$has_rights_setup_hedge_item_add,
			$has_rights_setup_hedge_item_delete			
        ) = build_security_rights(
            $rights_setup_hedge_rel_ui,
            $rights_setup_hedge_rel_delete,
            $rights_document,
            $rights_setup_hedge_item,
			$rights_setup_hedge_item_add,
			$rights_setup_hedge_item_delete
        );
        
        $application_function_id = $rights_setup_hedge_rel;
        $form_namespace = 'setup_hedge_rel_type';
        //Attaching main layout
        $layout_obj = new AdihaLayout();
       
        $layout_json = '[
                            {id: "a", height: 160, text: "Filters", header: true, collapse: true},
                            {id: "b", text: "Form", header: false, collapse: false},
                            {id: "c", width: 400, text: "<div><a class=\"undock_cell_a undock_custom\" style=\"float:right;cursor:pointer\" title=\"Undock\" onClick=\"setup_hedge_rel_type.undock_cell_a_standard_form();\"></a>Hedge Relationship Type</div>", header: true, collapse: false}
                        ]';
        $patterns = '3J';
                          
        $layout_name = 'layout_setup_hedge_rel_type';
        echo $layout_obj->init_layout($layout_name, '', $patterns, $layout_json, $form_namespace);
        
        //Attaching Filter form on cell b
        $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id=". $rights_setup_hedge_rel . ", @template_name='Setup Hedging Relationship Types', @group_name='General'";
        $return_value = readXMLURL($xml_file);
        $form_json = $return_value[0][2];
        
        $filter_name = 'filter_form';
        echo $layout_obj->attach_form($filter_name, 'a');
        $filter_obj = new AdihaForm();
        echo $filter_obj->init_by_attach($filter_name, $form_namespace);
        echo $filter_obj->load_form_filter($form_namespace, $filter_name, $layout_name, 'a', 10231900, 2);
        echo $filter_obj->load_form($form_json);
        
        //Attaching objects in cell c
        $menu_obj = new AdihaMenu();
        $menu_name = 'left_menu';
        $menu_json = '[{ id: "refresh", img: "refresh.gif", text: "Refresh"},
                        {id: "edit", img:"edit.gif", imgdis: "edit_dis.gif", text: "Edit", items:[
                                {id:"add", text:"Add", img:"add.gif", imgdis:"add_dis.gif", enabled:"' . $has_rights_setup_hedge_rel_ui. '"},
                                {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", enabled:false},
                                {id:"copy", text:"Copy", img:"copy.gif", imgdis:"copy_dis.gif", enabled:false}
                            ]
                        },
                        {id: "export", img:"export.gif", imgdis: "export_dis.gif", text: "Export", items:[
                                {id: "excel", text: "Excel", img:"excel.gif", imgdis:"excel_dis.gif", enabled:true},
                                {id: "pdf", text: "PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", enabled:true}
                            ]
                        }
                    ]';
        echo $layout_obj->attach_menu_cell($menu_name, 'c');
        echo $menu_obj->init_by_attach($menu_name, $form_namespace);
        echo $menu_obj->load_menu($menu_json);
        echo $menu_obj->attach_event('', 'onClick', $form_namespace . '.grid_menu_click');
        
        //Attaching grid in cell 'c'
        $grid_obj = new AdihaGrid();
        $grid_name = 'left_grid';
        echo $layout_obj->attach_grid_cell($grid_name, 'c');
        
        $xml_file = "EXEC spa_adiha_grid 's','setup_hedging_relationship_type'";
        $resultset = readXMLURL2($xml_file);
        echo $grid_obj->init_by_attach($grid_name, $form_namespace);
        echo $grid_obj->set_header($resultset[0]['column_label_list']);
        echo $grid_obj->set_columns_ids($resultset[0]['column_name_list']);
        echo $grid_obj->set_widths($resultset[0]['column_width']);
        echo $grid_obj->set_column_types($resultset[0]['column_type_list']);
        echo $grid_obj->set_sorting_preference($resultset[0]['sorting_preference']);
        echo $grid_obj->set_column_auto_size(true);
        echo $grid_obj->set_column_visibility($resultset[0]['set_visibility']);
        echo $grid_obj->enable_multi_select(false);
        echo $grid_obj->set_search_filter(true);
        echo $grid_obj->return_init();
        echo $grid_obj->attach_event('', 'onRowDblClicked', $form_namespace . '.create_tab');
        echo $grid_obj->attach_event('', 'onRowSelect', $form_namespace . '.enable_menu_item');
        echo $grid_obj->attach_event('', 'onXLE', $form_namespace . '.open_tab_by_hyperlink');
        echo $grid_obj->load_grid_functions();
        echo $layout_obj->close_layout();  
        //Definition for Hedge and Item Grids
        $grid_definition = array();
        $grid_def = "EXEC spa_adiha_grid 's', 'setup_hedges_items'";
        $def = readXMLURL2($grid_def);        
        $grid_definition_json = json_encode($def);    
    ?>
    </body>
    <script type="text/javascript">
        setup_hedge_rel_type.details_layout = {};
        setup_hedge_rel_type.details_toolbar = {};
        setup_hedge_rel_type.details_tabs = {};
        setup_hedge_rel_type.details_form = {};
        setup_hedge_rel_type.details_grid = {}; 
        setup_hedge_rel_type.details_menu = {}; 
        setup_hedge_rel_type.left_grid_dropdowns = {};
        var rights_setup_hedge_rel = '<?php echo $application_function_id; ?>';
        var category_id = 41;   //Note type RelationshipType
        var eff_test_profile_id =  '<?php echo $eff_test_profile_id; ?>';
        var php_script_loc = '<?php echo $app_php_script_loc; ?>';
        var popup_window;
        var grid_definition_json = <?php echo $grid_definition_json; ?>;
        var has_rights_ui = Boolean(<?php echo $has_rights_setup_hedge_rel_ui; ?>);    //used add/save priviledge of setup hedge relationship
        var has_rights_delete = Boolean(<?php echo $has_rights_setup_hedge_rel_delete; ?>); //used delete priviledge of setup hedge relationship
        var function_id = <?php echo $rights_setup_hedge_rel_ui; ?>;
        var has_document_rights = <?php echo (($has_document_rights) ? $has_document_rights : '0'); ?>;
        var has_rights_setup_hedge_rel_ui_copy = <?php echo (($has_rights_setup_hedge_rel_ui) ? $has_rights_setup_hedge_rel_ui : '0'); ?>;
		var has_rights_setup_hedge_item_add = <?php echo (($has_rights_setup_hedge_item_add) ? $has_rights_setup_hedge_item_add : '0'); ?>;
		var has_rights_setup_hedge_item_delete = <?php echo (($has_rights_setup_hedge_item_delete) ? $has_rights_setup_hedge_item_delete : '0'); ?>;
        var is_hover;
        
        var relation_id = '<?php echo $relation_id; ?>';
        
        $(function() {
            //Load Default Tab
            setTimeout(function(){
                if (relation_id) {
                    var row_id = setup_hedge_rel_type.left_grid.findCell(relation_id,0,true);
                    setup_hedge_rel_type.left_grid.selectRow(row_id[0][0]);                    
                    setup_hedge_rel_type.create_hyperlink_tab(relation_id, setup_hedge_rel_type.left_grid, row_id[0][0]);
                }
            }, 1500);
            /*filter_obj = setup_hedge_rel_type.layout_setup_hedge_rel_type.cells('a').attachForm();
            var layout_cell_obj = setup_hedge_rel_type.layout_setup_hedge_rel_type.cells('b');
            load_form_filter(filter_obj, layout_cell_obj, rights_setup_hedge_rel, 2);*/
            filter_form_obj = 'setup_hedge_rel_type.filter_form';
            attach_browse_event(filter_form_obj, rights_setup_hedge_rel, '', 'n');
        
            refresh_relation_grid();
            setup_hedge_rel_type.layout_setup_hedge_rel_type.cells('c').attachStatusBar({
                                height: 30,
                                text: '<div id="pagingArea_c"></div>'
                            });
            setup_hedge_rel_type.left_grid.splitAt(2);
            setup_hedge_rel_type.left_grid.setColumnHidden(0,true); 
            setup_hedge_rel_type.left_grid.setPagingWTMode(true,true,true,[10,20,30,40,50,60,70,80,90,100]);
            setup_hedge_rel_type.left_grid.enablePaging(true, 25, 0, 'pagingArea_c'); 
            setup_hedge_rel_type.left_grid.setPagingSkin('toolbar');
            setup_hedge_rel_type.left_grid.enableDragAndDrop(true); 
            setup_hedge_rel_type.left_grid.attachEvent('onBeforeDrag', function(){is_hover = 1; return true;})
            setup_hedge_rel_type.left_grid.rowToDragElement = function(id) {
                var text = setup_hedge_rel_type.left_grid.cellById(id,1).getValue();
                return text;
            }
            setup_hedge_rel_type.left_grid.attachEvent('onDrag', function(){return false;})
            setup_hedge_rel_type.tabbar = setup_hedge_rel_type.layout_setup_hedge_rel_type.cells('b').attachTabbar(); 
            setup_hedge_rel_type.tabbar.enableTabCloseButton(true);
            setup_hedge_rel_type.tabbar.attachEvent("onTabClose", function(id) {
                 delete setup_hedge_rel_type.pages[id];
                 return true;
            });
            
            setup_hedge_rel_type.layout_setup_hedge_rel_type.attachEvent('onDock', setup_hedge_rel_type.on_dock_event);
            setup_hedge_rel_type.layout_setup_hedge_rel_type.attachEvent('onUnDock', setup_hedge_rel_type.on_undock_event); 
            
            //set is_hover to 0 on mouse up on every div of the form
            $("div").mouseup(function() {
                is_hover = 0;
            });
                      
        });
        
        function refresh_relation_grid() {
            subsidiary_id = setup_hedge_rel_type.filter_form.getItemValue('subsidiary_id');
            strategy_id = setup_hedge_rel_type.filter_form.getItemValue('strategy_id');
            book_entity_id = setup_hedge_rel_type.filter_form.getItemValue('book_id');
            
            subsidiary_id = (subsidiary_id == '') ? 'NULL' : subsidiary_id;
            strategy_id = (strategy_id == '') ? 'NULL' : strategy_id;
            book_entity_id = (book_entity_id == '') ? 'NULL' : book_entity_id;
            
            var param = {
                            'action': 'spa_effhedgereltype',
                            'flag': 's',
                            'subsidiary_id': subsidiary_id,
                            'strategy_id': strategy_id,
                            'book_id': book_entity_id
                        }
                                                
            param = $.param(param);
            var param_url = js_data_collector_url + "&" + param;
            setup_hedge_rel_type.left_grid.clearAll();
            setup_hedge_rel_type.left_grid.loadXML(param_url, function(){
                setup_hedge_rel_type.left_grid.filterByAll();
            });
        }
        
        setup_hedge_rel_type.enable_menu_item = function() {
            if (has_rights_delete) {
                setup_hedge_rel_type.left_menu.setItemEnabled('delete');
            }
            
            if (has_rights_setup_hedge_rel_ui_copy) {
                setup_hedge_rel_type.left_menu.setItemEnabled('copy');
            }
            
        }
        
        setup_hedge_rel_type.grid_menu_click = function(id, zoneId, cas) {
            switch(id) {
                case "refresh":
                    setup_hedge_rel_type.layout_setup_hedge_rel_type.cells('a').collapse();
                    //setup_hedge_rel_type.layout_setup_hedge_rel_type.cells('b').collapse();
                    refresh_relation_grid();
                    break;
                case "add":
                    setup_hedge_rel_type.create_tab(-1,0,0,0);
                    break;
                case "delete":
                    setup_hedge_rel_type.delete_hedge_relationship();
                    break;
                case "excel":
                    setup_hedge_rel_type.left_grid.toExcel(js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                    break;
                case "pdf":
                    setup_hedge_rel_type.left_grid.toPDF(js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                    break;
                case 'copy':
                    var selected_row_id = setup_hedge_rel_type.left_grid.getSelectedRowId();
                    var eff_test_profile_id = get_selected_ids(setup_hedge_rel_type.left_grid, 'eff_test_profile_id');
            
                    var data = {
                                'action': 'spa_effhedgereltype',
                                'flag': 'c',
                                'eff_test_profile_id': eff_test_profile_id                                
                            };
                            
                    adiha_post_data('alert', data, '', '', 'refresh_relation_grid', '');        
                    break;
            }
        };

        setup_hedge_rel_type.open_tab_by_hyperlink = function() { //Called only from messageboards hyperling
            if (eff_test_profile_id != 'null') {                
                var eff_test_profile_id_grid = setup_hedge_rel_type.left_grid.findCell(eff_test_profile_id,0,true);
                setup_hedge_rel_type.create_tab(eff_test_profile_id_grid[0][0],0,0,0);
            }
            eff_test_profile_id = 'null';
        }
        
        setup_hedge_rel_type.create_tab = function(r_id, col_id, grid_obj, acc_id, tab_index) {
            if (r_id == -1 && col_id == 0) {
                full_id = setup_hedge_rel_type.uid();
                full_id = full_id.toString();
                text = "New";
            } else { 
                full_id = setup_hedge_rel_type.get_id(setup_hedge_rel_type.left_grid, r_id);
                text = setup_hedge_rel_type.get_text(setup_hedge_rel_type.left_grid, r_id);
                
                if (full_id == "tab_"){ 
                    var selected_row = setup_hedge_rel_type.left_grid.getSelectedRowId();
                    var state = setup_hedge_rel_type.left_grid.getOpenState(selected_row);
                    if (state) setup_hedge_rel_type.left_grid.closeItem(selected_row);
                    else setup_hedge_rel_type.left_grid.openItem(selected_row);
                    return false;
                }
            }

            if (!setup_hedge_rel_type.pages[full_id]) {
                var tab_context_menu = new dhtmlXMenuObject();
                tab_context_menu.setIconsPath(js_image_path + '/dhxtoolbar_web/');
                tab_context_menu.renderAsContextMenu();
                
                setup_hedge_rel_type.tabbar.addTab(full_id,text, null, tab_index, true, true);
                 //using window instead of tab
                var win = setup_hedge_rel_type.tabbar.cells(full_id);
                 
                setup_hedge_rel_type.tabbar.t[full_id].tab.id = full_id;
                tab_context_menu.addContextZone(full_id);
                tab_context_menu.loadStruct([{id:"close", text:"Close", title: "Close"},{id:"close_all", text:"Close All", title: "Close All"},{id:"close_other", text:"Close Other Tabs", title: "Close Other Tabs"}]);
                tab_context_menu.attachEvent("onContextMenu", function(zoneId){
                    setup_hedge_rel_type.tabbar.tabs(zoneId).setActive();
                });
                
                tab_context_menu.attachEvent("onClick", function(id, zoneId){
                     var ids = setup_hedge_rel_type.tabbar.getAllTabs();
                     switch(id) {
                         case "close_other":
                             ids.forEach(function(tab_id) {
                                 if (tab_id != zoneId) {
                                    delete setup_hedge_rel_type.pages[tab_id];
                                    setup_hedge_rel_type.tabbar.tabs(tab_id).close();
                                 }
                             })
                             break;
                         case "close_all":
                             ids.forEach(function(tab_id) {
                                 delete setup_hedge_rel_type.pages[tab_id];
                                 setup_hedge_rel_type.tabbar.tabs(tab_id).close();
                             })
                             break;
                         case "close":
                             ids.forEach(function(tab_id) {
                                 if (tab_id == zoneId) {
                                     delete setup_hedge_rel_type.pages[tab_id];
                                     setup_hedge_rel_type.tabbar.tabs(tab_id).close();
                                 }
                             })
                             break;
                     }
                 });
                 
                var toolbar = win.attachToolbar();       
                toolbar.setIconsPath(js_image_path + '/dhxtoolbar_web/');
                toolbar.attachEvent("onClick",setup_hedge_rel_type.tab_toolbar_click);  
                    
                toolbar.loadStruct([{id:"save", type: "button", img: "save.gif", imgdis: "save_dis.gif", text:"Save", title: "Save", enabled:has_rights_ui}]);
               
                setup_hedge_rel_type.tabbar.cells(full_id).setText(text);
                setup_hedge_rel_type.tabbar.cells(full_id).setActive();
                setup_hedge_rel_type.tabbar.cells(full_id).setUserData("row_id", r_id);
                win.progressOn();
                setup_hedge_rel_type.load_form(win,full_id,grid_obj,acc_id);
                setup_hedge_rel_type.pages[full_id] = win;
            } else {
                setup_hedge_rel_type.tabbar.cells(full_id).setActive();
            };
        };
        
        setup_hedge_rel_type.get_id = function(grid,r_id) {
            var id = "tab_" + grid.cells(r_id,0).getValue();
            return id;
        }
        
        setup_hedge_rel_type.get_text = function(grid,r_id) {
            var name = grid.cells(r_id,1).getValue();
            return name;
        }
        
        setup_hedge_rel_type.uid = function() {
            return (new Date()).valueOf();
        }                
        
        /**
         * [load_form description] - Load Form Data
         * @param  {[type]} win      [Active Tab]
         * @param  {[type]} tab_id   [Tab ID]
         * @param  {[type]} grid_obj [Grid Object - for accordion ]
         */
        setup_hedge_rel_type.load_form = function(win, tab_id, grid_obj) {
            win.progressOff();
            var tab_text = win.getText();
            var link_id = tab_id.replace("tab_", "");
            setup_hedge_rel_type.details_toolbar[link_id] = win.getAttachedToolbar();
            setup_hedge_rel_type.details_toolbar[link_id].attachEvent("onClick", function(id){
                    switch(id) {                        
                    case "documents":
                        setup_hedge_rel_type.open_document(link_id);
                        break;
                    default:
                        break;
                    }
                });
            if (tab_id.indexOf("tab_") != -1) { 
                add_manage_document_button(link_id, setup_hedge_rel_type.details_toolbar[link_id], has_document_rights);
            }
            // get id from the tab object
            var eff_test_profile_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;

            // Attach layout
            setup_hedge_rel_type.details_layout["details_layout_" + eff_test_profile_id] = win.attachLayout({
                pattern: "1C",
                cells: [
                            {
                                id: "a",
                                text: "Hegdge Relationship Details",
                                header: false,
                                collapse: false,
                                fix_size: [true, null]
                            }
                        ]
                    });
            
            // collect data for upper tabs, and print forms
            var xml_value = '<Root><PSRecordset eff_test_profile_id="' + eff_test_profile_id + '"></PSRecordset></Root>';
            data = {"action": "spa_create_application_ui_json",
                        "flag": "j",
                        "application_function_id": function_id,
                        "template_name": 'SetupHedgingRelationshipType',
                        "parse_xml": xml_value,
                        //"group_name": 'General,Assessment Criteria,Forecast Criteria'
                    };
            result = adiha_post_data('return_array', data, '', '', 'setup_hedge_rel_type.load_form_data', false);

        }           
        
        /**
         * [load_form_data Callback function to load upper tab forms]
         * @param  {[Array]} result [Form Array]
         */

        setup_hedge_rel_type.load_form_data = function(result) {
            var eff_test_profile_id = setup_hedge_rel_type.tabbar.getActiveTab(); 
            var eff_test_profile_id = (eff_test_profile_id.indexOf("tab_") != -1) ? eff_test_profile_id.replace("tab_", "") : eff_test_profile_id;

            var tab_json = '';
            var form_json = {};

            // create tab json and form json
            for (i = 0; i < result.length; i++) {
                if (i > 0)
                    tab_json = tab_json + ",";
                tab_json = tab_json + (result[i][1]);

                form_json[i] = result[i][2];
            }

            // attach forms to the a cell of layout
            var cell_a = setup_hedge_rel_type.details_layout["details_layout_" + eff_test_profile_id].cells("a");
            
            cell_a.progressOn();
            tab_json = '{tabs: [' + tab_json + ']}';
            setup_hedge_rel_type.details_tabs["details_tabs_a_" + eff_test_profile_id] = cell_a.attachTabbar();
            var tab_bar = setup_hedge_rel_type.details_tabs["details_tabs_a_" + eff_test_profile_id]
            tab_bar.loadStruct(tab_json);
            tab_bar.setTabsMode("bottom");

            // load forms to tabs
            var i = 0;
            tab_bar.forEachTab(function(tab) {
                var id = tab.getId();
                var tab_index = tab.getIndex();
                var tab_text = tab.getText();
                var form_index = "details_form_" + eff_test_profile_id + "_" + tab_index;
                
                var today = new Date();    
                if (tab_text == 'Hedges/Items') {
                    //Attach cell layout 2E
					  setup_hedge_rel_type.details_layout[form_index] = tab_bar.tabs(id).attachLayout({
                        pattern: "2E",
                        cells: [
                            {id: "a", text: "Hedges", collapse: false, header: true,fix_size: [true, null]},
                            {id: "b", text: "Items", collapse: false, header: true,fix_size: [true, null]}
                        ]
                    });
                    var hedge_item_layout = setup_hedge_rel_type.details_layout[form_index];
                    load_grid_n_menu(hedge_item_layout, 'a', 'hedges', "EXEC spa_effhedgereltypedetail 's','h',<ID>");
                    load_grid_n_menu(hedge_item_layout, 'b', 'items', "EXEC spa_effhedgereltypedetail 's','i',<ID>");
                    
                } else {                    
                    setup_hedge_rel_type.details_form[form_index] = tab.attachForm();
                    var form_obj = setup_hedge_rel_type.details_form[form_index];
                    form_obj.loadStruct(form_json[i]);
                    if (i == 0) {
                       if (form_obj.getItemValue('eff_test_profile_id') == '') form_obj.setItemValue('effective_start_date', today);
                       
                       var form_name =  'setup_hedge_rel_type.details_form["details_form_' + eff_test_profile_id + '_' + tab_index + '"]';
                       attach_browse_event(form_name, '10231910', 'onchange_book_structure', 'n');

                       $('div[title="Hedging Documentation"]').find('a').off().click(function() {
                            var win = new dhtmlXWindows(); 
                            //var hedge_document = form_obj.getItemValue('hedge_doc_temp');
                            var hedge_document = $(this).parent().parent('div').next('div').find('input[name="hedge_doc_temp"]').val();// Selected data this way because clicking Hedge Documentation on 1st tab grabbing Hedge Documentation value from subsiquent tabs.
                            
                            if (hedge_document == '' || hedge_document == 'NULL') {
                                var message = "No data selected for hyperlink.";
                                show_messagebox(message);
                                return;
                            }
                            
                            param = '../../../../_accounting/derivative/accounting_strategy/setup_hedge_rel_type/' + hedge_document + '.php';
                            var is_win = win.isWindow('hedge_doc_win');
                            
                            if (is_win == true) {
                                hedge_doc_win.close();
                            }
                            
                            hedge_doc_win = win.createWindow("hedge_doc_win", 520, 100, 530, 550);
                            hedge_doc_win.setText("Hedging Documentation");
                            hedge_doc_win.setModal(true);
                            hedge_doc_win.maximize();
                            hedge_doc_win.attachURL(param, false, true);
                        });  
                    }
                    
                    if (tab_text == 'Assessment Criteria') {

                        if (i == 1) {

                            var form_name =  'setup_hedge_rel_type.details_form["details_form_' + eff_test_profile_id + '_' + tab_index + '"]';
                            attach_browse_event(form_name, '10231910', '', 'n');
                        }
                        inherit_assmt_eff_test_obj = form_obj.getInput('label_inherit_assmt_eff_test_profile_id');
                        
                        form_obj.removeItem('browse_inherit_assmt_eff_test_profile_id'); 
                        
                        $("input[name=label_inherit_assmt_eff_test_profile_id]").addClass('push_clear_button');
                       
                        inherit_assmt_eff_test_obj.onmouseover = function() {
                            if (is_hover == 1) {
                                $("input[name=label_inherit_assmt_eff_test_profile_id]").addClass('highlight');
                                inherit_assmt_eff_test_obj.onmouseup = function() {  
                                    if (is_hover == 1) {
                                        var selected_row_id = setup_hedge_rel_type.left_grid.getSelectedRowId();
                                        var eff_test_profile_id = setup_hedge_rel_type.left_grid.cells(selected_row_id,0).getValue();
                                        var eff_test_profile_name = setup_hedge_rel_type.left_grid.cells(selected_row_id,1).getValue();
                                        form_obj.setItemValue('label_inherit_assmt_eff_test_profile_id', eff_test_profile_name);
                                        form_obj.setItemValue('inherit_assmt_eff_test_profile_id', eff_test_profile_id);
                                    }
                                }
                            }
                        }
                        
                        inherit_assmt_eff_test_obj.onmouseout = function() {
                            $("input[name=label_inherit_assmt_eff_test_profile_id]").removeClass('highlight');
                        }  
                    }
                    
                    form_obj.attachEvent('onOptionsLoaded', function(name) { 
                        if (name == 'on_eff_test_approach_value_id') {
                            var active_id = setup_hedge_rel_type.tabbar.getActiveTab();
                            if (active_id.indexOf('tab_') > -1) {
                                combo = form_obj.getCombo(name);
                                combo.setOptionIndex(304, 0); 
                            } else {
                                combo = form_obj.getCombo(name);
                                combo.setOptionIndex(304, 0); //value_id 304 -> No Hedge Ineffectiveness
                                combo.setComboValue(304);
                            }
                            form_obj.attachEvent("onChange", function (name, value) {
                                if (name == 'on_eff_test_approach_value_id') {

                                    var assmt_value = value;
                                	
                                    if (assmt_value == 320) {
                                        form_obj.disableItem('on_assmt_curve_type_value_id');
                                        form_obj.disableItem('on_curve_source_value_id');
                                        form_obj.disableItem('on_number_of_curve_points');
                                        form_obj.disableItem('mstm_eff_test_type_id');
                                    } else if (assmt_value==302 || assmt_value==303 || assmt_value==304 ) {
                                        form_obj.disableItem('on_assmt_curve_type_value_id');
                                        form_obj.disableItem('on_curve_source_value_id');
                                        form_obj.disableItem('on_number_of_curve_points');
                                        form_obj.enableItem('mstm_eff_test_type_id');
                                	} else {
                                		form_obj.enableItem('on_assmt_curve_type_value_id');
                                        form_obj.enableItem('on_curve_source_value_id');
                                        form_obj.enableItem('on_number_of_curve_points');
                                        form_obj.enableItem('mstm_eff_test_type_id');
                                	}
                                }
                            })
                        }
                        
                        if (name == 'init_eff_test_approach_value_id') {
                            var active_id = setup_hedge_rel_type.tabbar.getActiveTab();
                            if (active_id.indexOf('tab_') > -1) {
                                combos = form_obj.getCombo(name);
                                combos.setOptionIndex(304, 0); 
                            } else {
                                combos = form_obj.getCombo(name);
                                combos.setOptionIndex(304, 0); //value_id 304 -> No Hedge Ineffectiveness
                                combos.setComboValue(304);
                            }
                            form_obj.attachEvent("onChange", function (name, value) {
                                if (name == 'init_eff_test_approach_value_id') {
                                    var assmt_value = value;
                                    
                                    if (assmt_value == 302 || assmt_value == 303 || assmt_value == 304 ||assmt_value == 320) {
                                        form_obj.disableItem('init_assmt_curve_type_value_id');
                                        form_obj.disableItem('init_curve_source_value_id');
                                        form_obj.disableItem('init_number_of_curve_points');
                                	} else {
                                		form_obj.enableItem('init_assmt_curve_type_value_id');
                                        form_obj.enableItem('init_curve_source_value_id');
                                        form_obj.enableItem('init_number_of_curve_points');
                                	}
                                }
                            })
                        }                           
                    });

                    form_obj.attachEvent("onChange", function (name, value) {
                        if (name == 'profile_approved') {
                            if (form_obj.isItemChecked('profile_approved')) {
                                form_obj.setItemValue('profile_approved_by', js_user_name);
                            } else {
                                form_obj.setItemValue('profile_approved_by', '');
                            }
                        }     
                    })
                }
            
            i++;
             
            });

            cell_a.progressOff();
            form_obj = setup_hedge_rel_type.details_form["details_form_" + eff_test_profile_id + "_1"]

            form_obj.attachEvent('onOptionsLoaded', function(name) {
                if (name == 'on_eff_test_approach_value_id') {
                    var on_eff_assmt_value = form_obj.getItemValue('on_eff_test_approach_value_id');
                    
                    if (on_eff_assmt_value == 320) {
                        form_obj.disableItem('on_assmt_curve_type_value_id');
                        form_obj.disableItem('on_curve_source_value_id');
                        form_obj.disableItem('on_number_of_curve_points');
                        form_obj.disableItem('mstm_eff_test_type_id');
                    } else if (on_eff_assmt_value == 302 || on_eff_assmt_value == 303 || on_eff_assmt_value == 304 ) {
                        form_obj.disableItem('on_assmt_curve_type_value_id');
                        form_obj.disableItem('on_curve_source_value_id');
                        form_obj.disableItem('on_number_of_curve_points');
                        form_obj.enableItem('mstm_eff_test_type_id');
                	} else {
                		form_obj.enableItem('on_assmt_curve_type_value_id');
                        form_obj.enableItem('on_curve_source_value_id');
                        form_obj.enableItem('on_number_of_curve_points');
                        form_obj.enableItem('mstm_eff_test_type_id');
                	}
                }                
            });
            
            form_obj.attachEvent('onOptionsLoaded', function(name) {
                if (name == 'init_eff_test_approach_value_id') {
                    var init_eff_assmt_value = form_obj.getItemValue('init_eff_test_approach_value_id');
                	if (init_eff_assmt_value == 302 || init_eff_assmt_value == 303 || init_eff_assmt_value == 304 || init_eff_assmt_value == 320) {
                        form_obj.disableItem('init_assmt_curve_type_value_id');
                        form_obj.disableItem('init_curve_source_value_id');
                        form_obj.disableItem('init_number_of_curve_points');
                	} else {
                		form_obj.enableItem('init_assmt_curve_type_value_id');
                        form_obj.enableItem('init_curve_source_value_id');
                        form_obj.enableItem('init_number_of_curve_points');
                	}
                }                
            });                      
                      
            onchange_book_structure();
        }
        
        //Open documnets
        setup_hedge_rel_type.open_document = function(object_id) {        
            var dhxWins = new dhtmlXWindows();
            var object_id = (object_id.indexOf("tab_") != -1) ? object_id.replace("tab_", "") : object_id;
            param = '../../../../_setup/manage_documents/manage.documents.php?notes_category=' + category_id + '&notes_object_id=' + object_id + '&is_pop=true';
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
                update_document_counter(object_id, setup_hedge_rel_type.details_toolbar[object_id]);
                return true;
            });
        } 
        
        function onchange_book_structure() {
            var eff_test_profile_id = setup_hedge_rel_type.tabbar.getActiveTab();
            var eff_test_profile_id = (eff_test_profile_id.indexOf("tab_") != -1) ? eff_test_profile_id.replace("tab_", "") : eff_test_profile_id;

            var tab_bar = setup_hedge_rel_type.details_tabs["details_tabs_a_" + eff_test_profile_id];
            var general_form_obj = '';
            var criteria_form_obj = '';
            
            tab_bar.forEachTab(function(tab) {
                var id = tab.getId();
                var tab_index = tab.getIndex();
                var form_index = "details_form_" + eff_test_profile_id + "_" + tab_index;
                
                if (tab_index == 0) {
                    general_form_obj = setup_hedge_rel_type.details_form[form_index];
                }
                if (tab_index == 1) {
                    criteria_form_obj = setup_hedge_rel_type.details_form[form_index];
                }                
                
            });
            
            var book_id = general_form_obj.getItemValue('book_id');
            
            //load Convert UOM dropdown
            var cm_param = {
                        "action": "spa_source_uom_maintain", 
                        "flag": "s",
						"eff_test_profile_id": book_id
                    };

            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;
            
            var combo_obj_uom = criteria_form_obj.getCombo('convert_uom_value_id');
            combo_obj_uom.load(url);
            
            
            //load Convert Currency dropdown
            var cm_param = {
                        "action": "spa_source_currency_maintain", 
                        "flag": "c",
						"eff_test_profile_id": book_id
                    };
                   
            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param
            
            var combo_obj_currency = criteria_form_obj.getCombo('convert_currency_value_id');
            combo_obj_currency.load(url);
            
            var data = {
                        "action": "spa_effhedgereltype", 
                        "flag": "h",
						"eff_test_profile_id": eff_test_profile_id
                    };
                    
            data = $.param(data);
    
            $.ajax({
                type: "POST",
                dataType: "json",
                url: js_form_process_url,
                async: true,
                data: data,
                success: function(data) {
                     response_data = data["json"];
                     convert_currency_value_id = response_data[0].convert_currency_value_id;
                     convert_uom_value_id = response_data[0].convert_uom_value_id;
                     combo_obj_currency.setComboValue(convert_currency_value_id);
                     combo_obj_uom.setComboValue(convert_uom_value_id);
                }
            })      
                    
        }
        
        function load_grid_n_menu(hedge_item_layout, cell_text, grid_name, sql_stmt) {
            var active_tab_id = setup_hedge_rel_type.tabbar.getActiveTab();
            var allow_add = (active_tab_id.indexOf("tab_") == -1) ? false : has_rights_setup_hedge_item_add;
		    active_tab_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            var general_form_obj = setup_hedge_rel_type.details_form["details_form_" + active_tab_id + "_0"];
            var subsidiary_id = general_form_obj.getItemValue('subsidiary_id');
            var strategy_id = general_form_obj.getItemValue('strategy_id');
            var book_id = general_form_obj.getItemValue('book_id');
            var subsidiary_id = general_form_obj.getItemValue('subsidiary_id');                       
            var hedge_or_item = (cell_text == 'a') ? 'h' : 'i';
            var eff_test_profile_id = general_form_obj.getItemValue('eff_test_profile_id');
			
			if(hedge_or_item == 'h'){
			sql_stmt_hedge = sql_stmt
			}
			
            //Attach menu/grid in cell a
            var hedge_item_cell = hedge_item_layout.cells(cell_text);
			            
            setup_hedge_rel_type.details_menu["details_menu_" + cell_text + "_" + active_tab_id] = hedge_item_cell.attachMenu({
                icons_path: js_image_path + "dhxmenu_web/",
                items: [
                    {id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif", title: "Refresh"},
                    {id: "edit", text: "Edit", img: "edit.gif", img_disabled: "edit_dis.gif", items: [
                            {id: "add", text: "Add", img: "add.gif", img_disabled: "add_dis.gif", enabled:allow_add},
                            {id: "delete", text: "Delete", disabled: true, img: "delete.gif", img_disabled: "delete_dis.gif"}
                        ]},
                    {id: "export", text: "Export", img: "export.gif", items: [
                            {id: "excel", text: "Excel", img: "excel.gif", imgdis: "excel_dis.gif", title: "Excel"},
                            {id: "pdf", text: "PDF", img: "pdf.gif", imgdis: "pdf_dis.gif", title: "PDF"}
                        ]}
                ]});
                
            var hedge_item_cell_menu = setup_hedge_rel_type.details_menu["details_menu_" + cell_text + "_" + active_tab_id];
            //Attaching Menu event
			hedge_item_cell_menu.attachEvent("onClick", function(id) {
			       switch (id) {
                   case "add":
                        //get new leg
                        var col_index = setup_hedge_rel_type.details_grid[grid_index].getColIndexById("leg");
                        var leg_arr = new Array();
                        setup_hedge_rel_type.details_grid[grid_index].forEachRow(function(id){
                        leg_arr.push(setup_hedge_rel_type.details_grid[grid_index].cells(id,col_index).getValue())
                        });
                        //var indexOfMaxValue = leg_arr.reduce(function(iMax,x,i,a) {return x>a[iMax] ? i : iMax;}, 0);
//                        var next_leg = (leg_arr.length > 0) ? (parseInt(leg_arr[indexOfMaxValue]) + 1) : 1;
                        
                        //get new deal sequence
                        col_index = setup_hedge_rel_type.details_grid[grid_index].getColIndexById("deal_sequence_number");
                        var deal_seq_arr = new Array();
                        setup_hedge_rel_type.details_grid[grid_index].forEachRow(function(id){
                        deal_seq_arr.push(setup_hedge_rel_type.details_grid[grid_index].cells(id,col_index).getValue())
                        });
                        var indexOfMaxValue = deal_seq_arr.reduce(function(iMax,x,i,a) {return x>a[iMax] ? i : iMax;}, 0);
                        var next_deal_seq = (deal_seq_arr.length > 0) ? (parseInt(deal_seq_arr[indexOfMaxValue]) + 1) : 1;
                        eff_test_profile_id = setup_hedge_rel_type.details_form["details_form_" + active_tab_id + "_0"].getItemValue('eff_test_profile_id');
                        sql_stmt = sql_stmt.replace('<ID>', eff_test_profile_id);   
						sql_stmt_hedge =  sql_stmt_hedge.replace('<ID>', eff_test_profile_id); 
                        setup_hedge_rel_type.open_popup_window(eff_test_profile_id,'NULL', '', subsidiary_id, strategy_id, book_id, hedge_or_item, sql_stmt, setup_hedge_rel_type.details_grid[grid_index],1, next_deal_seq)
                        break;
                    case "delete":
                        var profile_detail_ids = [];
                        var col_index = setup_hedge_rel_type.details_grid[grid_index].getColIndexById("eff_test_profile_detail_id");
                        var row_index = setup_hedge_rel_type.details_grid[grid_index].getSelectedId();
                        row_index = row_index.split(',');
                        row_index.forEach(function(val) {
                            var eff_test_profile_detail_id = setup_hedge_rel_type.details_grid[grid_index].cells(val, col_index).getValue();
                            profile_detail_ids.push(eff_test_profile_detail_id);
                        });

                        profile_detail_ids = profile_detail_ids.toString();
                        
                        if (profile_detail_ids != '') {
                            dhtmlx.message({
                                type: "confirm",
                                title: "Confirmation",
                                ok: "Confirm",
                                text: "Are you sure you want to delete?",
                                callback: function(result) {
                                    if (result) {                                        
                                        data = {
                                            "action": "spa_effhedgereltypedetail", 
                                            "flag": "d",
                                            "eff_test_profile_detail_id": profile_detail_ids
                                        }
                                        adiha_post_data("return_array", data, "", "",'post_hedge_item_delete');
                                    }
                                }
                            });
                        }
                        break;
                    case 'excel':
                        setup_hedge_rel_type.details_grid[grid_index].toExcel(php_script_loc + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                        break;                
                    case 'pdf':
                        setup_hedge_rel_type.details_grid[grid_index].toPDF(php_script_loc + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                        break;                
                    case 'refresh':
						refresh_hedge_item_grid();
                        break;                      
                    default:
                        show_messagebox(id);                         
                        
                }
                
            });
			
			function refresh_hedge_item_grid() {		
					var grid_index_a = "details_grid_" +'a'+ "_" + eff_test_profile_id;
					
					setup_hedge_rel_type.refresh_grids(sql_stmt_hedge.replace('<ID>', eff_test_profile_id), setup_hedge_rel_type.details_grid[grid_index_a], 'g');
										
					setup_hedge_rel_type.refresh_grids(sql_stmt.replace('<ID>', eff_test_profile_id), setup_hedge_rel_type.details_grid[grid_index], 'g');
			}
			
			post_hedge_item_delete = function(result) {
				refresh_hedge_item_grid();				
			}
            
             //attach grid to the tab, grid definition that is collected above is used to construct grid
            
            var grid_name = grid_definition_json[0]["grid_name"];
            var grid_cookies = "grid_" + cell_text + "_" + grid_name;
            var grid_index = "details_grid_" + cell_text + "_" + eff_test_profile_id;
            setup_hedge_rel_type.details_grid[grid_index] = hedge_item_cell.attachGrid();
            setup_hedge_rel_type.details_grid[grid_index].setImagePath(js_image_path + "dhxgrid_web/");
            setup_hedge_rel_type.details_grid[grid_index].setHeader(grid_definition_json[0]["column_label_list"]);
            setup_hedge_rel_type.details_grid[grid_index].setColumnIds(grid_definition_json[0]["column_name_list"]);
            setup_hedge_rel_type.details_grid[grid_index].setInitWidths(grid_definition_json[0]["column_width"]);
            setup_hedge_rel_type.details_grid[grid_index].setColTypes(grid_definition_json[0]["column_type_list"]);
            setup_hedge_rel_type.details_grid[grid_index].setColumnsVisibility(grid_definition_json[0]["set_visibility"]);
            setup_hedge_rel_type.details_grid[grid_index].setColSorting(grid_definition_json[0]["sorting_preference"]);
            setup_hedge_rel_type.details_grid[grid_index].setDateFormat("%m/%d/%Y");   
            //setup_hedge_rel_type.details_grid[grid_index].attachHeader(",#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter");
            setup_hedge_rel_type.details_grid[grid_index].enableMultiselect(true);
            setup_hedge_rel_type.details_grid[grid_index].enableColumnMove(true);
            setup_hedge_rel_type.details_grid[grid_index].setUserData("", "grid_id", grid_name);
            setup_hedge_rel_type.details_grid[grid_index].init();
            setup_hedge_rel_type.details_grid[grid_index].loadOrderFromCookie(grid_cookies);
            setup_hedge_rel_type.details_grid[grid_index].loadHiddenColumnsFromCookie(grid_cookies);
            setup_hedge_rel_type.details_grid[grid_index].enableOrderSaving(grid_cookies);
            setup_hedge_rel_type.details_grid[grid_index].enableAutoHiddenColumnsSaving(grid_cookies);
            
            //attach grid event
            setup_hedge_rel_type.details_grid[grid_index].attachEvent("onRowDblClicked", function(row_id, col_id){
                var eff_test_profile_detail_id = setup_hedge_rel_type.details_grid[grid_index].cells(row_id, 0).getValue();
                var sub_book_name = setup_hedge_rel_type.details_grid[grid_index].cells(row_id, 3).getValue();  //source_book_map
                setup_hedge_rel_type.open_popup_window(eff_test_profile_id,eff_test_profile_detail_id, sub_book_name, subsidiary_id, strategy_id, book_id, hedge_or_item, sql_stmt, setup_hedge_rel_type.details_grid[grid_index])
            });
            
            setup_hedge_rel_type.details_grid[grid_index].attachEvent("onRowSelect", function(){
                
                if (has_rights_setup_hedge_item_delete) {				
                    setup_hedge_rel_type.details_menu["details_menu_"+ cell_text + "_" + eff_test_profile_id].setItemEnabled('delete');                    
                }
            });
            
            //load grid data
            setup_hedge_rel_type.refresh_grids(sql_stmt.replace('<ID>', eff_test_profile_id), setup_hedge_rel_type.details_grid[grid_index], 'g');
            setup_hedge_rel_type.details_grid[grid_index].enableHeaderMenu();
        
        }
		
        /**
         * [refresh_grids Refresh Grid]
         * @param  {[type]} sql_stmt        [Grid Population query]
         * @param  {[type]} grid_obj        [Grid Object]
         * @param  {[type]} grid_type       [Grid Type]
         */
        setup_hedge_rel_type.refresh_grids = function(sql_stmt, grid_obj, grid_type) {
            // load grid data
            var sql_param = {
                "sql": sql_stmt,
                "grid_type": grid_type
            };

            sql_param = $.param(sql_param);
            var sql_url = js_data_collector_url + "&" + sql_param;
            grid_obj.clearAll();
            grid_obj.load(sql_url);
        }
     
        /**
         * [open_popup_window Open popups for data insertion and update]
         * @param  {[int]} eff_test_profile_id  [Header ID]
         * @param  {[type]} id              [id from the respective grid]
         * @param  {[type]} hedge_or_item        ['i' for Item, h for Hedge]
         */
         
        setup_hedge_rel_type.open_popup_window = function(eff_test_profile_id, eff_test_profile_detail_id, sub_book_name, subsidiary_id, strategy_id, book_id, hedge_or_item, sql_stmt, grid_obj, next_leg, next_deal_seq) {
            unload_window();
            var win_text = 'Hedge/Item Relationship Type Detail';
            //url = 'set.hedge.rel.type.detail.h.i.php?eff_test_profile_id=' + eff_test_profile_id 
//                    + '&eff_test_profile_detail_id=' + eff_test_profile_detail_id
//                    + '&sub_id=' + subsidiary_id
//                    + '&strategy_id=' + strategy_id
//                    + '&book_id=' + book_id
//                    + '&hedge_or_item=' + hedge_or_item;
            width = 690;
            height = 360;
            var url = 'set.hedge.rel.type.detail.h.i.php';
            var params = {next_leg:next_leg,next_deal_seq:next_deal_seq,sub_book_name:sub_book_name,hedge_or_item:hedge_or_item,book_id:book_id,eff_test_profile_id:eff_test_profile_id,eff_test_profile_detail_id:eff_test_profile_detail_id,sub_id:subsidiary_id,strategy_id:strategy_id};
            
            if (!popup_window) {
                popup_window = new dhtmlXWindows();
            }
            
            var new_win = popup_window.createWindow('w1', 0, 0, width, height);
            new_win.centerOnScreen();
            new_win.setModal(true);
            new_win.attachEvent("onClose", function(win) {
                var ifr = win.getFrame();
                var ifrWindow = ifr.contentWindow;
                var ifrDocument = ifrWindow.document;
                var success_status = $('textarea[name="success_status"]', ifrDocument).val();
                if (success_status == 'Success') {
                        dhtmlx.message({
                        text: 'Data Saved Successfully.',
                        expire: 1000
                    });
                    
                    setup_hedge_rel_type.refresh_grids(sql_stmt.replace('<ID>', eff_test_profile_id), grid_obj, 'g');
                }                
                return true;
            })
            new_win.setText(win_text);
            new_win.maximize();
            new_win.attachURL(url, false, params);
        }
        /**
         * [unload_window Window unload function]
         */
        function unload_window() {
            if (popup_window != null && popup_window.unload != null) {
                popup_window.unload();
                popup_window = w1 = null;
            }
        }
            
        function get_selected_ids(grid_obj, column_name) {
            var rid = grid_obj.getSelectedRowId();
            if (rid == '' || rid == null) {
                return false;
            }
            var rid_array = new Array();
            if (rid.indexOf(",") != -1) {
                rid_array = rid.split(',');
            } else {
                rid_array.push(rid);
            }
            
            var cid = grid_obj.getColIndexById(column_name);
            var selected_ids = new Array();
            $.each(rid_array, function( index, value ) {
              selected_ids.push(grid_obj.cells(value,cid).getValue());
            });
            selected_ids = selected_ids.toString();
            return selected_ids;
        }

        /**
         * [Function to delete Hedge Relationship]
         */
        setup_hedge_rel_type.delete_hedge_relationship = function() {
            var select_id = setup_hedge_rel_type.left_grid.getSelectedRowId();
            
            if (select_id != null) {
                dhtmlx.message({
                    type: "confirm",
                    title: "Confirmation",
                    ok: "Confirm",
                    text: "Are you sure you want to delete?",
                    callback: function(result) {
                        if (result) {
                            
                            id = get_selected_ids(setup_hedge_rel_type.left_grid, 'eff_test_profile_id')
                            
                            data = {
                                "action": "spa_effhedgereltype", 
                                "eff_test_profile_id": id, 
                                "flag": "d"
                            }
                            result = adiha_post_data("return_array", data, "", "","setup_hedge_rel_type.post_delete_callback");
                            //todo check i think call back is not reuiredhere.
                        }
                    }
                });
            }
        }
        
        setup_hedge_rel_type.post_delete_callback = function(result) {
            if (result[0][0] == "Success") {     
                dhtmlx.message({
                    text:result[0][4],
                    expire:1000
                });
                
                refresh_relation_grid();
            } else {
                dhtmlx.message({
                    title:"Error",
                    type:"alert-error",
                    text:result[0][4]
                });
            }
        };
        
        setup_hedge_rel_type.undock_cell_a_standard_form = function() {
            setup_hedge_rel_type.layout_setup_hedge_rel_type.cells("c").undock(300, 300, 900, 700);
            setup_hedge_rel_type.layout_setup_hedge_rel_type.dhxWins.window("c").button("park").hide();
            setup_hedge_rel_type.layout_setup_hedge_rel_type.dhxWins.window("c").maximize();
            setup_hedge_rel_type.layout_setup_hedge_rel_type.dhxWins.window("c").centerOnScreen();
        }
        
        setup_hedge_rel_type.on_dock_event = function(name) {
            $(".undock_cell_a").show();
        }
        
        setup_hedge_rel_type.on_undock_event = function(name) {
            $(".undock_cell_a").hide();
        }
        
        setup_hedge_rel_type.tab_toolbar_click = function(id) {
            switch(id) {
                case "close":             
                    var tab_id = setup_hedge_rel_type.tabbar.getActiveTab();
                    delete setup_hedge_rel_type.pages[tab_id];
                    setup_hedge_rel_type.tabbar.tabs(tab_id).close(true);
                    break;
                case "save":
                    var tab_id = setup_hedge_rel_type.tabbar.getActiveTab();
                    setup_hedge_rel_type.save_relation(tab_id);
                    break;
                default:         
                break;        
            }
        };
        
        setup_hedge_rel_type.save_relation = function(tab_id) {
            var eff_test_profile_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
            var details_tabs = setup_hedge_rel_type.details_tabs["details_tabs_a_" + eff_test_profile_id];
            var tab_name = setup_hedge_rel_type.tabbar.tabs(tab_id).getText();
            
            setup_hedge_rel_type.validation_status = 1;
            var form_xml = '<FormXML ';
            var param_list = new Array();
            var chk_required_doc = 0;
            var is_approved = 'n';
            var tabsCount = details_tabs.getNumberOfTabs();
            var form_status = true;
            var first_err_tab;

                
            details_tabs.forEachTab(function(tab) {
                var id = tab.getId();
                var tab_index = tab.getIndex();
                var tab_text = tab.getText();
                var form_index = "details_form_" + eff_test_profile_id + "_" + tab_index;
                var form_obj = setup_hedge_rel_type.details_form[form_index];
                var status = 1; //validate_form(form_obj);
                
                if (tab_index == 1 || tab_index == 0 || tab_index == 2) {
                    status = validate_form(form_obj);
                    form_status = form_status && status; 
                    if (tabsCount == 1 && !status) {
                        first_err_tab = "";
                    } else if ((!first_err_tab) && !status) {
                    first_err_tab = tab;
                    }
                }
                
                if (status) {
                    if (tab_index == 1 || tab_index == 0 || tab_index == 2) {
                        data = form_obj.getFormData();
                        for (var a in data) {
                            var field_label = a;
                            
                            if (form_obj.getItemType(field_label) == 'calendar') {
                                    var field_value = form_obj.getItemValue(field_label, true);
                                } else {
                                    var field_value = data[field_label];
                                }
        
                                if (!field_value)
                                    field_value = '';
                                
                                field_label = (field_label == 'book_id') ? 'fas_book_id' : field_label;
                                
                                if (field_label == 'profile_approved') is_approved = field_value;
                                
                                if (jQuery.inArray(field_label, Array('risk_mgmt_strategy','risk_mgmt_policy','formal_documentation')) != -1 && chk_required_doc == 0 && is_approved == 'y')  {
                                    chk_required_doc = (field_value == 'y') ? 1 : 0;
                                }
                                
                                if (field_label != 'book_structure' &&
                                    field_label != 'subsidiary_id' &&
                                    field_label != 'strategy_id' &&
                                    field_label != 'subbook_id') 
                                    {
                                        if (field_label == 'fas_book_id') {
                                            var is_comma_present = field_value.indexOf(',');
                                            if (is_comma_present > 1) {
                                                dhtmlx.alert({
                                                   title: 'Error',
                                                   type: "alert-error",
                                                   text: 'Please select single book.'
                                                });
                                                setup_hedge_rel_type.validation_status = 0;
                                            }
                                        }

                                        form_xml += " " + field_label + "=\"" + field_value + "\"";
                                    }
                                
                            }                             
                    }
                } else {
                    /*tab.setActive();
                    generate_error_message();*/
                    setup_hedge_rel_type.validation_status = 0;
                }
            });
            
            //if (!setup_hedge_rel_type.validation_status) return;
            if (!form_status) {
                generate_error_message(first_err_tab);
                return
            }

            // if (form_obj.isItemChecked('effectiveness_testing_not_required')) {
            //     var effectiveness_testing_not_required = 'y'; //not required
            // } else {
            //     var effectiveness_testing_not_required = 'n';
            // }
            
            // form_xml += " effectiveness_testing_not_required = \""+effectiveness_testing_not_required+"\" ";
            form_xml += " profile_for_value_id = \"327\"";
            form_xml += "></FormXML>";
            
            form_index = "details_form_" + eff_test_profile_id + "_0";
            form_obj = setup_hedge_rel_type.details_form[form_index];
            // alert(form_xml);return;
            var risk_mgmt_strategy = form_obj.isItemChecked('risk_mgmt_strategy');
            var risk_mgmt_policy = form_obj.isItemChecked('risk_mgmt_policy');
            var formal_documentation = form_obj.isItemChecked('formal_documentation');
            
            var validate_risk_mgmt_strategy = '<div align="left">* Consistent with Risk Management Strategy</div>';
            var validate_risk_mgmt_policy = '<div align="left">* Governed by Existing Risk Management Policies</div>';
            var validate_formal_documentation = '<div align="left">* Governed by Formal Existing Hedge Documentation</div>';
            var combine_validate = '';
            
            if (risk_mgmt_strategy === false) 
                combine_validate += validate_risk_mgmt_strategy;
                
            if (formal_documentation === false) 
                combine_validate += validate_formal_documentation;
          
            if (risk_mgmt_policy === false) 
                combine_validate += validate_risk_mgmt_policy;
            
            var validate_documentation = "<div align='left'>The following Documentation Requirement options are not selected.</div>" + combine_validate + "<div align='left'>Are you sure you want to approve without these conditions?</div>" ;
            
            if (tab_name == 'New') { 
                flag = 'i';
            } else {
                flag = 'u';
            }
           
            var data = {
                            "action": "spa_effhedgereltype",
                            "flag": flag,
                            "form_xml": form_xml
                        };
            
            if (combine_validate != '') {
                dhtmlx.message({
                        type: "confirm",
                        title: "Confirmation",
                        ok: "Confirm",
                        text: validate_documentation,
                        width: '450px',
                        callback: function(result) {
                            if (result) {                                        
                                adiha_post_data('return_json', data, '', '', 'save_callback', '');
                            }
                        }
                    });                            
             } else {
                adiha_post_data('return_json', data, '', '', 'save_callback', '');
             }           
               
            
        }
        
        function save_callback(result) {
            var return_data = JSON.parse(result);
            
            if ((return_data[0].status).toLowerCase() == 'success') {
                var result_arr = return_data[0].recommendation.split(';'); 
                var new_id = result_arr[0];
                
                var active_tab_id = setup_hedge_rel_type.tabbar.getActiveTab();
                eff_test_profile_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;        
                var tab_bar = setup_hedge_rel_type.details_tabs["details_tabs_a_" + eff_test_profile_id];
                var general_form_obj = '';
                
                tab_bar.forEachTab(function(tab) {
                    var id = tab.getId();
                    var tab_index = tab.getIndex();
                    var form_index = "details_form_" + eff_test_profile_id + "_" + tab_index;
                    
                    if (tab_index == 0) {
                        general_form_obj = setup_hedge_rel_type.details_form[form_index];
                    }             
                    
                });
                
                if (new_id != '') {
                    general_form_obj.setItemValue('eff_test_profile_id', new_id);
                    add_manage_document_button(new_id, setup_hedge_rel_type.details_toolbar[active_tab_id], has_document_rights);
                }
                
                var tab_name = general_form_obj.getItemValue('eff_test_name');
                dhtmlx.message(return_data[0].message);
                setup_hedge_rel_type.tabbar.tabs(active_tab_id).setText(tab_name);
                
                if (has_rights_ui) {
                  setup_hedge_rel_type.details_menu["details_menu_a_" + eff_test_profile_id].setItemEnabled('add'); 
                  setup_hedge_rel_type.details_menu["details_menu_b_" + eff_test_profile_id].setItemEnabled('add');  
                } else {
                  setup_hedge_rel_type.details_menu["details_menu_a_" + eff_test_profile_id].setItemDisabled('add'); 
                  setup_hedge_rel_type.details_menu["details_menu_b_" + eff_test_profile_id].setItemDisabled('add');  
                }

                if (new_id != ''){
                    var tab_id = setup_hedge_rel_type.tabbar.getActiveTab();
                    setup_hedge_rel_type.tabbar.tabs(tab_id).close();
                    eff_test_profile_id = new_id;
                } else{
                    eff_test_profile_id = 'null'
                }

                refresh_relation_grid();
            } 
        }        
            
    setup_hedge_rel_type.create_hyperlink_tab = function(r_id, grid_obj, grid_row_id) {
        var full_id = "tab_" + r_id;
        var text = setup_hedge_rel_type.get_text(grid_obj, grid_row_id);
        
        if (!setup_hedge_rel_type.pages[full_id]) {
            var tab_context_menu = new dhtmlXMenuObject();
            tab_context_menu.setIconsPath(js_image_path + '/dhxtoolbar_web/');
            tab_context_menu.renderAsContextMenu();
            
            //
            setup_hedge_rel_type.tabbar.addTab(full_id,text, null, 1, true, true);
            var win = setup_hedge_rel_type.tabbar.cells(full_id);
            setup_hedge_rel_type.tabbar.t[full_id].tab.id = full_id;
            //
          
            var toolbar = win.attachToolbar();
            toolbar.setIconsPath(js_image_path + '/dhxtoolbar_web/');
            toolbar.loadStruct([{id:"save", type: "button", img: "save.gif", imgdis: "save_dis.gif", text:"Save", title: "Save"}]);
            toolbar.attachEvent("onClick",setup_hedge_rel_type.tab_toolbar_click);  
            //
            tab_context_menu.addContextZone(full_id);
            tab_context_menu.loadStruct([{id:"close", text:"Close", title: "Close"},{id:"close_all", text:"Close All", title: "Close All"},{id:"close_other", text:"Close Other Tabs", title: "Close Other Tabs"}]);
            tab_context_menu.attachEvent("onContextMenu", function(zoneId){
                setup_hedge_rel_type.tabbar.tabs(zoneId).setActive();
            });
            
            tab_context_menu.attachEvent("onClick", function(id, zoneId){
                var ids = setup_hedge_rel_type.tabbar.getAllTabs();
                switch(id) {
                    case "close_other":
                        ids.forEach(function(tab_id) {
                            if (tab_id != zoneId) {
                                delete setup_hedge_rel_type.pages[tab_id];
                                setup_hedge_rel_type.tabbar.tabs(tab_id).close();
                            }
                        })
                    break;
                    case "close_all":
                        ids.forEach(function(tab_id) {
                            delete setup_hedge_rel_type.pages[tab_id];
                            setup_hedge_rel_type.tabbar.tabs(tab_id).close();
                        })
                    break;
                    case "close":
                        ids.forEach(function(tab_id) {
                            if (tab_id == zoneId) {
                                delete setup_hedge_rel_type.pages[tab_id];
                                setup_hedge_rel_type.tabbar.tabs(tab_id).close();
                            }
                        })
                    break;
                }
            });
            //var win = setup_hedge_rel_type.tabbar.cells("tab_" + r_id); 
            
            setup_hedge_rel_type.tabbar.cells(full_id).setText(text);
            setup_hedge_rel_type.tabbar.cells(full_id).setActive();
            setup_hedge_rel_type.tabbar.cells(full_id).setUserData("row_id", r_id);
            win.progressOn();
            setup_hedge_rel_type.load_form(win, full_id, grid_obj);           
            

            setup_hedge_rel_type.pages[full_id] = win;
        } else {
            setup_hedge_rel_type.tabbar.cells(full_id).setActive();
        };
    };    
    </script> 
</html>