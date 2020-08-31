<?php
/**
* Contract charge type screen
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
    $rights_contract_ui = 10211110;
    $rights_contract_delete = 10211111;
    $rights_contract_charge_type_ui = 10211116;
    $rights_contract_charge_type_delete = 10211117;
    $rights_contract_charge_type_copy = 10211116;
    $rights_contract_formula_ui = 10211131;
    list (
        $has_rights_contract_ui,
        $has_rights_contract_delete,
        $has_rights_contract_charge_type_ui,
        $has_rights_contract_charge_type_delete,
        $has_rights_contract_charge_type_copy,
        $has_rights_contract_formula_ui 
    ) = build_security_rights(
        $rights_contract_ui,
        $rights_contract_delete,
        $rights_contract_charge_type_ui,
        $rights_contract_charge_type_delete,
        $rights_contract_charge_type_copy,
        $rights_contract_formula_ui      
    );
  
    $function_id = 10211100;
    $template_name = 'contract_charge_type';
    $grid_name = "contract_charge_type";
    $grid_sp = "EXEC spa_contract_charge_type @flag = 'g'";
    
    $form_namespace = 'contract_group';
    $form_obj = new AdihaStandardForm($form_namespace, $function_id);
    $form_obj->define_grid($grid_name,  $grid_sp);

    $grid_obj = new GridTable();
    
    $form_obj->define_custom_functions('save_contract', 'load_contract', 'delete_contract_template');
    echo $form_obj->init_form('Contract Component Templates', '');

    echo "contract_group.menu.addNewChild('t1', 3, 'copy', 'Copy', false, 'copy.gif', 'copy_dis.gif');";
    echo "contract_group.menu.setItemDisabled('copy');";
	if ($has_rights_contract_ui){
    echo "contract_group.grid.attachEvent('onRowSelect', function(){";
    echo      "contract_group.menu.setItemEnabled('copy');";
    echo      "contract_group.menu.attachEvent('onClick', contract_group.copy_function);";
    echo "});";
	}

    echo $form_obj->close_form();

    $table_name = 'contract_charge_type_detail';
    $grid_def = "EXEC spa_adiha_grid 's', '" . $table_name . "'";
    $def = readXMLURL2($grid_def);
    $grid_id = $def[0]['grid_id'];
    $table_name = $def[0]['grid_name'];
    $grid_columns = $def[0]['column_name_list'];
    $grid_col_labels = $def[0]['column_label_list'];
    $grid_col_types = $def[0]['column_type_list'];
    $column_alignment = $def[0]['column_alignment'];
    $sql_string = trim($def[0]['sql_stmt']);
    $grid_set_visibility = $def[0]['set_visibility'];
    $grid_column_width = $def[0]['column_width'];
    $grid_sorting_preference= $def[0]['sorting_preference'];
    $grid_column_width = '';
    $pieces = explode(",", $grid_columns);
    // echo count($pieces);
    for ($x = 1; $x <= count($pieces); $x++) {
        if ($x != 1)
            $grid_column_width .=',';
        $grid_column_width .='*';
    }

    /* JSON for grid toolbar */
    $button_grid_charge_json = '[
                                {id:"t1", text:"Edit", img:"edit.gif", imgdis:"edit_dis.gif", items:[
                                    {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add", enabled:"'.$has_rights_contract_charge_type_ui.'"},
                                    {id:"remove", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete", enabled:"'.$has_rights_contract_charge_type_delete.'"},
                                    {id:"copy", text:"Copy", img:"copy.gif", imgdis:"copy_dis.gif", title: "Copy", enabled:"'.$has_rights_contract_charge_type_ui.'"}
                                ]},
                                {id:"t2", text:"Export", img:"export.gif",imgdis:"export_dis.gif",items:[
                                    {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                                    {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                                ]}
                                ]';
    /* END */

    /* JSON for formula toolbar */
    $button_grid_formula_json = '[
                                {id:"t1", text:"Edit", img:"edit.gif", imgdis:"edit_dis.gif", items:[
                                    {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add", enabled:"'.$has_rights_contract_formula_ui.'"},
                                    {id:"remove", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete", enabled:"'.$has_rights_contract_formula_ui.'"}
                                ]},
                                {id: "save", text: "Save", img: "save.gif", imgdis:"save_dis.gif", title: "Save", enabled:"'.$has_rights_contract_formula_ui.'"},
                                {id:"additional", text:"Additional", img:"additional.gif", imgdis:"additional_dis.gif", title: "Additional", enabled:"'.$has_rights_contract_formula_ui.'"}
                                ]';
    /* JSON for contract price grid toolbar */
    $button_pricegrid_formula_json = '[
                        {id:"add", type:"button", img:"new.gif", text:"Add", title:"Add"},
                        {id:"remove", type:"button", img:"trash.gif", imgdis:"trash_dis.gif", text:"Remove", title:"Remove" }
                    ]';
    /* DataView Structure */
    $dataview_name = 'dataview_formula';
    $template = "<div class='select_button' onclick='select_clicked(#formula_id#,#row#,#nested_idd#,#formula_group_id#);'></div><div><div><div><div><span> #row# </span><span></span><span> #description_1# </span></div><div><span> Formula: </span><span> #formula# </span></div><div><div><span>Granularity: </span><span> #granularity# </span><span>, Show Value As: </span><span> #volume# </span><span style='display:none;'> Nested ID: </span><span style='display:none;'> #nested_id# </span></div></div></div></div>";
    $tooltip = "<b>#formula#</b>";
    ?>
    <body>
        <div id="layoutObj"></div>
        <!-- will used as windows viewport -->
        <div id="winVP" style="display: none;"></div>
    </body>
    
    <script type="text/javascript">
        var php_script_loc_ajax = "<?php echo $app_php_script_loc; ?>";
        var session = "<?php echo $session_id; ?>";
        var grid_toolbar_json =<?php echo $button_grid_charge_json; ?>;
        var formula_toolbar_json =<?php echo $button_grid_formula_json; ?>;
        var contractprice_toolbar_json =<?php echo $button_pricegrid_formula_json; ?>;
        var function_id = "<?php echo $function_id;?>";

        var has_rights_contract_formula_ui = <?php echo (($has_rights_contract_formula_ui) ? $has_rights_contract_formula_ui : '0');?>;
        var has_rights_contract_ui = <?php echo (($has_rights_contract_ui) ? $has_rights_contract_ui : '0');?>;
        var has_rights_contract_delete = <?php echo (($has_rights_contract_delete) ? $has_rights_contract_delete : '0'); ?>;
        var has_rights_contract_charge_type_ui = <?php echo (($has_rights_contract_charge_type_ui) ? $has_rights_contract_charge_type_ui : '0'); ?>;
        var has_rights_contract_charge_type_delete = <?php echo (($has_rights_contract_charge_type_delete) ? $has_rights_contract_charge_type_delete : '0'); ?>;
		var theme_selected = 'dhtmlx_' + default_theme;
        dhxWins = new dhtmlXWindows();
        
        contract_group.copy_function = function(id){
            if (id == 'copy') {
                var selectedId = contract_group.grid.getSelectedRowId();
                var id = contract_group.grid.cells(selectedId, 0).getValue();
                
                if (id == null) {
                    dhtmlx.message({
                        title: "Alert", type: "alert", text:"Please select contract template before copying."
                    });
                    return;
                } else {
                    /*dhtmlx.message({type: 'confirm', title: 'Confirmation', ok: 'Confirm', text: 'Are you sure you copy contract template?',
                        callback: function(result) {
                            if (result) {      */
                                data = {"action": "spa_contract_charge_type", "flag": "c", "contract_id": id};
                                adiha_post_data("alert", data, "", "", "contract_group.callback_copy_contract", "", "");
                            /*}
                        }
                    });*/
                }
            }
        }
        /**
         * [Copies contract]
         * @param {type} tab_id
         * @returns {undefined}
         */
        /*contract_group.copy_contract = function(object_id) {
            if (object_id) {
                data = {"action": "spa_contract_charge_type", "flag": "c", "contract_id": object_id};
                adiha_post_data("alert", data, "", "", "contract_group.callback_copy_contract", "", "");
            }
        }*/
        /*
         * Calback function to copy contract function to reload the tree. 
         * @param {type} result
         * @returns {undefined}         
         */
        contract_group.callback_copy_contract = function(result) {
            contract_group.grid.clearAll();
            contract_group.refresh_grid();
            contract_group.menu.setItemDisabled('copy');
        }
        /******************* Triggers when the tree is double clicked.***************************/
        /*START*/
        contract_group.load_contract = function(win, full_id) {
            win.progressOff();
            var object_id = (full_id.indexOf("tab_") != -1) ? full_id.replace("tab_", "") : full_id;
            /*JSON FOR inner layout*/
            var inner_tab_layout_jsob = [
                {
                    id: "a",
                    text: "Contracts",
                    header: true,
                    collapse: false,
                    height: 110,
                    fix_size: [true, null]
                },
                {
                    id: "b",
                    text: "Contract Component and Formula",
                    header: true,
                    collapse: false,
                    fix_size: [true, null],
					undock: true
                }
            ];
            contract_group["inner_tab_layout_" + object_id] = win.attachLayout({pattern: "2E", cells: inner_tab_layout_jsob});
            contract_group["inner_grid_layout_" + object_id] = contract_group["inner_tab_layout_" + object_id].cells("b").attachLayout({pattern: "2U"});

            /*Attaching status bar for grid pagination*/
            contract_group["inner_grid_layout_" + object_id].cells('a').attachStatusBar({
                height: 30,
                text: '<div id="pagingAreaGrid_b' + object_id + '"></div>'
            });
            
            contract_group["inner_tab_layout_" + object_id].cells("b").showHeader();
            var undock_class = 'undock-btn-a';
            //contract_group["inner_tab_layout_" + object_id].cells('b').setText("<div><a class=\" undock_class undock_custom\" style=\"float:right;cursor:pointer\" title=\"Undock\"  onClick=\" contract_group.undock_window();\"></a>Contract Component and Formula</div>");
            contract_group["inner_grid_layout_" + object_id].cells('a').hideHeader();
            contract_group["inner_grid_layout_" + object_id].cells('b').hideHeader();


            /*Undock functionality code block*/
            /*START*/
            contract_group["inner_tab_layout_" + object_id].attachEvent("onDock", function(name) {
                $('.undock-btn-a').show();
            });
            contract_group["inner_tab_layout_" + object_id].attachEvent("onUnDock", function(name) {
                $('.undock-btn-a').hide();

            });
            /*END*/
            /*Attaching tabbar to the inner layout*/
            contract_group["contract_tabs_" + object_id] = contract_group["inner_tab_layout_" + object_id].cells("a").attachTabbar();
            //contract_group["contract_tabs_" + object_id].setTabsMode("bottom");

            /*Attaching toolbar for grid.*/
            /*START*/
            contract_group["contract_toolbar_grid_" + object_id] = contract_group["inner_grid_layout_" + object_id].cells('a').attachMenu();
            contract_group["contract_toolbar_grid_" + object_id].setIconsPath(php_script_loc_ajax + 'components/lib/adiha_dhtmlx/themes/'+theme_selected+'/imgs/dhxtoolbar_web/');
            contract_group["contract_toolbar_grid_" + object_id].loadStruct(grid_toolbar_json);
           
            if(has_rights_contract_charge_type_ui){
                contract_group["contract_toolbar_grid_" + object_id].setItemEnabled("add");
            }
			
            contract_group["contract_toolbar_grid_" + object_id].setItemDisabled("copy");
            contract_group["contract_toolbar_grid_" + object_id].setItemDisabled("remove");
            
            contract_group["contract_toolbar_grid_" + object_id].attachEvent('onClick', contract_group.grd_charge_toolbar_click);
            /*END*/
            /*Attaching grid for contract component.*/
            /*START*/
            contract_group["contract_component_grid_" + object_id] = contract_group["inner_grid_layout_" + object_id].cells('a').attachGrid();
            contract_group["contract_component_grid_" + object_id].setImagePath("<?php echo $image_path; ?>dhxtoolbar_web/");
            contract_group["contract_component_grid_" + object_id].setHeader("<?php echo $grid_col_labels; ?>",null,["text-align:left;","text-align:left;","text-align:left;","text-align:right;"]);
            contract_group["contract_component_grid_" + object_id].setColumnIds("<?php echo $grid_columns; ?>");
            contract_group["contract_component_grid_" + object_id].setColTypes("<?php echo $grid_col_types; ?>");
            contract_group["contract_component_grid_" + object_id].setColAlign("<?php echo $column_alignment; ?>");
            contract_group["contract_component_grid_" + object_id].setInitWidths("<?php echo $grid_column_width; ?>");
            contract_group["contract_component_grid_" + object_id].setColumnsVisibility("<?php echo $grid_set_visibility; ?>");
            contract_group["contract_component_grid_" + object_id].setColSorting("<?php echo $grid_sorting_preference; ?>");

            contract_group["contract_component_grid_" + object_id].setPagingWTMode(true, true, true, true);
            contract_group["contract_component_grid_" + object_id].enablePaging(true, 100, 0, 'pagingAreaGrid_b' + object_id);
            contract_group["contract_component_grid_" + object_id].attachHeader("#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter");
            contract_group["contract_component_grid_" + object_id].setPagingSkin('toolbar');
            contract_group["contract_component_grid_" + object_id].enableDragAndDrop(true);

            contract_group["contract_component_grid_" + object_id].attachEvent("onRowSelect", contract_group.load_dataview_formula);
            contract_group["contract_component_grid_" + object_id].attachEvent("onRowDblClicked", function(rId,cInd){
                if (contract_group["dataview_formula_" + object_id]) {
                    contract_group["dataview_formula_" + object_id].clearAll();
                }
                contract_group.grd_charge_toolbar_click('edit');
            });
            //To save sequence order in drag and drop.
            if(has_rights_contract_charge_type_ui){
                contract_group["contract_component_grid_" + object_id].attachEvent("onDrop", function(sId, tId, dId, sObj, tObj, sCol, tCol) {
                    update_charge_type_sequence();
                });
            }

            //end of sequence
            contract_group["contract_component_grid_" + object_id].enableColumnMove(true);
            contract_group["contract_component_grid_" + object_id].init();
            contract_group["contract_component_grid_" + object_id].loadOrderFromCookie("contract_component_grid");
            contract_group["contract_component_grid_" + object_id].loadHiddenColumnsFromCookie("contract_component_grid");
            contract_group["contract_component_grid_" + object_id].enableOrderSaving("contract_component_grid");
            contract_group["contract_component_grid_" + object_id].enableAutoHiddenColumnsSaving("contract_component_grid");

            contract_group["contract_component_grid_" + object_id].attachEvent("onBeforeCMove",function(cInd, newPos){
                if (newPos < 2) return false;
                if (cInd < 2) return false;
                else return true;
            });

            contract_group["contract_component_grid_" + object_id].setUserData("", "grid_delete_xml", "");
            contract_group["contract_component_grid_" + object_id].setUserData("", "grid_update_xml", "");
            contract_group["contract_component_grid_" + object_id].setUserData("", "formula_delete_xml", "");
            contract_group["contract_component_grid_" + object_id].setUserData("", "form_validate_code_xml", "");
            contract_group["contract_component_grid_" + object_id].setUserData("", "pricegrid_delete_xml", "");
            contract_group["contract_component_grid_" + object_id].setUserData("", "contract_mode_xml", "");
            contract_group["contract_component_grid_" + object_id].setUserData("", "contract_mode_xml", "");
            contract_group["contract_component_grid_" + object_id].setUserData("", "contract_name_store", "");
            
            /*Getting tab and form JSON from backend to bind in the main tabbar.*/
            /*START*/
            contract_group.grid.forEachRow(function(id) {
                if (contract_group.grid.cells(id, 1).getValue() == object_id) {
                    selectedId = id;
                }
            });
            grid_function_name = <?php echo $function_id;?>;
            template_name = 'contract_group';
            
            var additional_data = {"action": "spa_create_application_ui_json",
                "flag": "j",
                "application_function_id": grid_function_name,
                "template_name": "<?php echo $template_name;?>",
                "parse_xml": "<Root><PSRecordset contract_charge_type_id=" + '"' + object_id + '"' + "></PSRecordset></Root>",
                "session_id": session
            };
            adiha_post_data('return_array', additional_data, '', '', 'contract_group.load_tab_and_forms');
            /*END*/
            grid_obj_name = 'contract_group[' + '"' + 'contract_component_grid_' + object_id + '"' + ']';
            var str = "<?php echo $sql_string; ?>";
            var spa_url = str.replace("<ID>", object_id);
            var additional_data1 = {"sp_url": spa_url,
                "grid_obj_name": grid_obj_name,
                "session_id": session
            };
            url = php_script_loc_ajax + "load_grid_data.php"
            data = $.param(additional_data1);
            $.ajax({
                type: "POST",
                dataType: "json",
                url: url,
                data: data,
                success: function(data) {
                    eval((data));
                },
                error: function(xht) {
                    show_messagebox('error');
                }

            });
            /*END*/

            /*Attaching toolbar for formula.*/
            /*START*/
            contract_group["contract_toolbar_formula_" + object_id] = contract_group["inner_grid_layout_" + object_id].cells('b').attachMenu();
            contract_group["contract_toolbar_formula_" + object_id].setIconsPath(php_script_loc_ajax + 'components/lib/adiha_dhtmlx/themes/'+theme_selected+'/imgs/dhxtoolbar_web/');
            contract_group["contract_toolbar_formula_" + object_id].loadStruct(formula_toolbar_json);
            contract_group["contract_toolbar_formula_" + object_id].attachEvent('onClick', contract_group.grd_formula_toolbar_click);
            /*END*/

            // if(has_rights_contract_formula_ui) {
            //     contract_group["contract_toolbar_formula_" + object_id].setItemEnabled("additional");
            //     contract_group["contract_toolbar_formula_" + object_id].setItemEnabled("add");
            //     contract_group["contract_toolbar_formula_" + object_id].setItemEnabled("save");
            // }

            //contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("t1");
            contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("add");
            contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("remove");
            contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("save");
            contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("additional");
        }
        /*Callback function to load tabs and form from the result gained by the backend.*/
        /*START*/
        contract_group.load_tab_and_forms = function(result) {
            var active_tab_id = contract_group.tabbar.getActiveTab();
            var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
                        
            contract_group_layout = contract_group["inner_tab_layout_" + object_id].cells("a").attachForm();
            contract_group_layout.loadStruct(result[0][2]);
            contract_id = contract_group["contract_component_grid_" + object_id].getUserData("", "contract_mode_xml");
            
            if (contract_id) {
                toolbar_obj = contract_group.tabbar.cells("tab_" + object_id).getAttachedToolbar();              
            }
        }
        /*END*/
		
		
		update_charge_type_sequence = function() {
			var active_tab_id = contract_group.tabbar.getActiveTab();
            var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
			grid_xml = '<Root>';
			var count = contract_group["contract_component_grid_" + object_id].getRowsNum();
			var j = 1;
			for (i = 0; i <= count; i++) {
				var contract_detail_id = contract_group["contract_component_grid_" + object_id].getRowId(i);
				if (contract_detail_id) {
					grid_xml = grid_xml + '<GridUpdate contract_id=' + '"' + object_id + '"' + ' contract_detail_id=' + '"' + contract_detail_id + '"' + ' sequence_order=' + '"' + j + '"' + '></GridUpdate>';
				}
				j++;
			}
			grid_xml += '</Root>';
			data = {"action": "spa_contract_charge_type_detail_UI",
				"flag": "v",
				"xml": grid_xml
			};
			adiha_post_data('alert', data, '', '', '');
		}
        /****************************************************END of Triggers when the tree is double clicked.********************************************/
        /*********************************************************GRID******************************************************/
        /*****************************************************END OF GRID***************************************************/

        /************************************************************Contract component GRID TOOLBAR**************************************************************************/
        /*Function triggered when grid toolbar is clicked.*/
        /*START*/
        contract_group.grd_charge_toolbar_click = function(id) {
            var active_tab_id = contract_group.tabbar.getActiveTab();
            var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            var contract_component_store = new Array();
            
            if ((active_tab_id.indexOf("tab_") == -1)&& (id == 'add')) {
                show_messagebox('Contract Component Template need to be saved first.');
                return;
            }
            

            if (id == 'add') {
                var RowsNum = contract_group["contract_component_grid_" + object_id].getRowsNum();
                RowsNum = RowsNum + 1;
                param = 'charge.type.php?contract_id=' + object_id + '&mode=i&count=' + RowsNum + '&is_pop=true&right='+ has_rights_contract_charge_type_ui;
                var is_win = dhxWins.isWindow('w3');
                if (is_win == true) {
                    w3.close();
                     
                }
                w3 = dhxWins.createWindow("w3", 320, 0, 560, 400);
                w3.setText("Charge Type Mapping");
                w3.setModal(true);
                w3.attachURL(param, false, true);

                w3.attachEvent("onClose", function(win) {
                    contract_group.ID = false;
                    //contract_group.charge_type_post_callback();
                    return true;
                });

            }
            else if (id == 'remove') {
                var selectedId = contract_group["contract_component_grid_" + object_id].getSelectedRowId();
                if (!selectedId) {
                    var message = get_message('VALIDATE_DATA');
                    show_messagebox(message);
                    return false;
                } else {
                    data = {"action": "spa_contract_charge_type_detail",
                                    "flag": "z",
                                    "contract_detail_id": selectedId
                            };

                    adiha_post_data('confirm', data, '', '', ' contract_group.delete_charge_callback');
                    
                    contract_group["contract_toolbar_grid_" + object_id].setItemDisabled("copy");
                    contract_group["contract_toolbar_grid_" + object_id].setItemDisabled("remove");
                }
            }
            else if (id == 'edit') {
                var grid_data = contract_group["contract_component_grid_" + object_id].getSelectedRowId();
                var type = contract_group["contract_component_grid_" + object_id].cells(grid_data, 1).getValue();
                param = 'charge.type.php?contract_detail_id=' + grid_data + '&contract_id=' + object_id + '&type=' + type + '&mode=u&is_pop=true&right='+ has_rights_contract_charge_type_ui;
                var is_win = dhxWins.isWindow('w5');
                if (is_win == true) {
                    w5.close();
                }
                w5 = dhxWins.createWindow("w5", 320, 0, 560, 400);
                w5.setText("Charge Type Mapping");
                w5.setModal(true);
                w5.attachURL(param, false, true);
                w5.attachEvent("onContentLoaded", function(win) {
                    var delay = 1000; //1 seconds
                    setTimeout(function() {
                        if (contract_group["dataview_formula_" + object_id]) {
                            contract_group["dataview_formula_" + object_id].clearAll();
                            contract_group["contract_toolbar_grid_" + object_id].setItemDisabled("copy");
                            contract_group["contract_toolbar_grid_" + object_id].setItemDisabled("remove");
                            return true;
                        }
                    }, delay);
                });
                
                w5.attachEvent("onClose", function(win) {
                    //contract_group["dataview_formula_" + object_id].clearAll();
                    contract_group.charge_type_post_callback();
                    return true;
                });
            }
            else if (id == 'copy') {
                var selectedId = contract_group["contract_component_grid_" + object_id].getSelectedRowId();
                if (!selectedId) {
                    var message = get_message('VALIDATE_DATA');
                    show_messagebox(message);
                    return false;
                } else {
                    var type = contract_group["contract_component_grid_" + object_id].cells(selectedId, 1).getValue();
                    
                    param = 'charge.type.php?contract_detail_id=' + selectedId + '&contract_id=' + object_id + '&type=' + type + '&mode=c&is_pop=true&right='+ has_rights_contract_charge_type_ui;
                    var is_win = dhxWins.isWindow('w5');
                    if (is_win == true) {
                        w5.close();
                    }
                    w5 = dhxWins.createWindow("w3", 320, 0, 700, 365);
                    w5.setText("Charge Type Mapping");
                    w5.setModal(true);
                    w5.attachURL(param, false, true);
                }
                contract_group.delete_charge_callback();
            }
            else if (id == 'pdf') {
                contract_group["contract_component_grid_" + object_id].toPDF(php_script_loc_ajax + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
            }
            else if (id == 'excel') {
                contract_group["contract_component_grid_" + object_id].toExcel(php_script_loc_ajax + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
            }
        }
        /*END*/
        
        contract_group.delete_charge_callback = function() {
            var active_tab_id = contract_group.tabbar.getActiveTab();
            var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            var str = "<?php echo $sql_string; ?>";
            var spa_url = str.replace("<ID>", object_id);
            
            sp_url = {"sp_string": spa_url};
            result = adiha_post_data("return_data", sp_url, "", "", "contract_group.refresh_contract_component_grid_callback");
            contract_group.callback_formula_save();
        }
        contract_group.refresh_contract_component_grid_callback = function(result) {
            var active_tab_id = contract_group.tabbar.getActiveTab();
            var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            contract_group["contract_component_grid_" + object_id].clearAll();
            contract_group["contract_component_grid_" + object_id].parse(result, "js");
        }
        /*******************************************END OF GRID TOOLBAR******************************************************************/
        /***********************************************Contract Price Toolbar grid*******************************************************/
        /*START*/
        contract_group.grd_price_toolbar_click = function(id) {
            var active_tab_id = contract_group.tabbar.getActiveTab();
            var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            if (id == 'add') {//when add is clicked.
                var new_id = (new Date()).valueOf();
                new_id = new_id + '_grid';
                contract_group["contract_price_grid_" + object_id].addRow(new_id, "");
                contract_group["contract_price_grid_" + object_id].selectRow(contract_group["contract_price_grid_" + object_id].getRowIndex(new_id), false, false, true);
            }
            else if (id == 'remove') {//when is delete is clicked
                var selectedId = contract_group["contract_price_grid_" + object_id].getSelectedRowId();
                if (!selectedId) {
                    var message = get_message('VALIDATE_DATA');
                    show_messagebox(message);
                    return false;
                } else {
                    var grid_xml = '';
                    var deleted_xml = contract_group["contract_price_grid_" + object_id].getUserData("", "pricegrid_delete_xml");
                    var del_array = new Array();
                    del_array = (selectedId.indexOf(",") != -1) ? selectedId.split(",") : selectedId.split();
                    contract_group["contract_price_grid_" + object_id].setUserData("", "pricegrid_delete_xml", grid_xml);
                    $.each(del_array, function(index, value) {
                        grid_xml += '<GridRow ';
                        for (var cellIndex = 0; cellIndex < contract_group["contract_price_grid_" + object_id].getColumnsNum(); cellIndex++) {
                            grid_xml += contract_group["contract_price_grid_" + object_id].getColumnId(cellIndex) + '= "' + contract_group["contract_price_grid_" + object_id].cells(value, cellIndex).getValue() + '" ';
                        }
                        contract_group["contract_price_grid_" + object_id].deleteRow(value);
                        grid_xml += '></GridRow>';
                    });
                    if (deleted_xml)
                        grid_xml = grid_xml + deleted_xml;
                    contract_group["contract_component_grid_" + object_id].setUserData("", "pricegrid_delete_xml", grid_xml);

                }
            }

        }
        /*END*/
        /***********************************************END of Contract Price Toolbar grid************************************************/
        /*******************************************************DATAVIEW****************************************************************/
        /*Triggers to load dataview for displaying formula.*/
        /*START*/

        contract_group.load_dataview_formula = function() {
            var is_win = dhxWins.isWindow('w3');
            if (is_win == true) {
                contract_group["dataview_formula_" + object_id].clearAll();
                return;
            }
            var active_tab_id = contract_group.tabbar.getActiveTab();
            var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            var selectedId = contract_group["contract_component_grid_" + object_id].getSelectedRowId();
            var contract_type = contract_group["contract_component_grid_" + object_id].cells(selectedId, 1).getValue();
            var flat_fee = contract_group["contract_component_grid_" + object_id].cells(selectedId, 2).getValue();
            if(has_rights_contract_charge_type_delete) {
                contract_group["contract_toolbar_grid_" + object_id].setItemEnabled("remove");    
            } 
            // if(has_rights_contract_charge_type_ui){
                // contract_group["contract_toolbar_formula_" + object_id].setItemEnabled("add"); 
            // } 
            if(has_rights_contract_charge_type_ui){
                contract_group["contract_toolbar_grid_" + object_id].setItemEnabled("copy");               
            } 

            if (contract_type != 'Formula') {
                // contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("t1");
                contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("additional");
                contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("save");

                layout_obj = contract_group["inner_grid_layout_" + object_id].cells('b').getAttachedObject();
                if (layout_obj instanceof dhtmlXDataView) {
                    contract_group["dataview_formula_" + object_id].clearAll();
                }
                var selectedId = contract_group["contract_component_grid_" + object_id].getSelectedRowId();
                var ind = contract_group["contract_component_grid_" + object_id].getSelectedCellIndex();
                var n = selectedId.indexOf("_grid");//To check if the dataview is inserted new or updated old id.
                return false;
            }
            else {
                if(has_rights_contract_formula_ui) {
                    contract_group["contract_toolbar_formula_" + object_id].setItemEnabled("add");                   
                }
            }

            contract_group["dataview_formula_" + object_id] = contract_group["inner_grid_layout_" + object_id].cells('b').attachDataView(
            {
                edit: true,
                type: {
                    template: "<?php echo $template; ?>",
                    template_edit: "<textarea class='dhx_item_editor' bind='obj.description_1'>",
                    padding: 10,
                    height: 60,
                    width: 800,
                },
                tooltip: {
                    template: "<?php echo $tooltip; ?>"
                },
                drag: true,
                select: true,
            });
            contract_group["dataview_formula_" + object_id].attachEvent("oneditkeypress", contract_group.item_clicked);
            contract_group["dataview_formula_" + object_id].attachEvent("onAfterDrop", contract_group.item_moved);
            contract_group["dataview_formula_" + object_id].attachEvent("onAfterSelect", contract_group.item_selected);
            var selectedId = contract_group["contract_component_grid_" + object_id].getSelectedRowId();
            var ind = contract_group["contract_component_grid_" + object_id].getSelectedCellIndex();
            var n = selectedId.indexOf("_grid");//To check if the dataview is inserted new or updated old id.
            
            if (selectedId && n < 0) {
                var selectedId = contract_group["contract_component_grid_" + object_id].getSelectedRowId();
                var ind = contract_group["contract_component_grid_" + object_id].getSelectedCellIndex();
                data = {"action": "spa_contract_charge_type_detail",
                    "flag": "a",
                    "contract_detail_id": selectedId,
                    "session_id": session
                };
                adiha_post_data("return_array", data, "", "", "contract_group.build_formula_dataview");
            }
            if (n < 0) {
                contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("additional");
                contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("save");
            }
            else {
                contract_group["contract_toolbar_formula_" + object_id].setItemEbabled("additional");
                contract_group["contract_toolbar_formula_" + object_id].setItemEbabled("save");
            }
 
        }


        /*END*/
        /**
         * callback function
         * contract_group.build_formula_dataview() [gets the group_formula id to call for laoding dataview.]
         * @param [array] result
         * @return [callback function]
         */
        /*START*/

        contract_group.build_formula_dataview = function(result) {
            if (result[0][4]) {
                var group_formula_id = result[0][4];
                data = {"action": "spa_formula_nested",
                    "flag": "s",
                    "formula_group_id": group_formula_id,
                    "session_id": session
                };
                adiha_post_data("return_json", data, "", "", "contract_group.callback_dataview_load");
            }
        }
        /*END*/
        /*Callback function to load the data of the dataview*/
        /*START*/
        contract_group.callback_dataview_load = function(result) {
            var active_tab_id = contract_group.tabbar.getActiveTab();
            var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            contract_group["dataview_formula_" + object_id].parse(result, "json");



        }
        /*END*/
        /**
         * contract_group.item_clicked() [this triggers when dataview item clicked.]
         * @param [string] code
         */
        contract_group.item_clicked = function(code) {
            /*if (code == 13)
                this.stopEdit();
            else if (code == 27)
                this.stopEdit(true);*/
            if(!has_rights_contract_formula_ui)
                return;
            if (code == 13)
                this.stopEdit();
            else if (code == 27)
                this.stopEdit(true);
        }
        /**
         * contract_group.item_moved() [this function moves item in dataview.]
         * @param [string] context
         */
        contract_group.item_moved = function(context) {
            if(!has_rights_contract_formula_ui)
                return;
            var active_tab_id = contract_group.tabbar.getActiveTab();
            var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            var dataview_object = contract_group["dataview_formula_" + object_id];
            var count = dataview_object.dataCount();
            for (i = 0; i < count; i++) {
                id = dataview_object.idByIndex(i);
                dataview_object.item(id).row = i + 1;
                dataview_object.refresh(id);
            }
            var xml = contract_group.get_sorted_data_for_formula();
            submit_sp(xml, 'x');
        }
        /**
         * submit_sp() [this is the function to submit.]
         * @param [string] xml
         * @param [string] flag
         */
        function submit_sp(xml, flag) {
            data = {"action": "spa_contract_charge_type_detail_UI",
                    "flag": flag,
                    "xml": xml,
                    "session_id": session
            };
            adiha_post_data('alert', data, '', '', '');
        }
        /**
         * contract_group.item_selected() [this function is triggered when dataview is clicked.]
         * @param [string] context
         */
        contract_group.item_selected = function(id) {
            var active_tab_id = contract_group.tabbar.getActiveTab();
            var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
             contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("save");
             contract_group["contract_toolbar_formula_" + object_id].setItemEnabled("remove");
             
             if(has_rights_contract_formula_ui) {
                contract_group["contract_toolbar_formula_" + object_id].setItemEnabled("save");
                contract_group["contract_toolbar_formula_" + object_id].setItemEnabled("additional");
            }
			 if(has_rights_contract_formula_ui == 0) {
                contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("remove");
            }

            var dataview_object = contract_group["dataview_formula_" + object_id];
            if (dataview_object.item(id).nested_id) {
                if(has_rights_contract_formula_ui) {
                     contract_group["contract_toolbar_formula_" + object_id].setItemEnabled("save");
                     contract_group["contract_toolbar_formula_" + object_id].setItemEnabled("additional");
                }
            }
            else {
                contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("additional");
            }
        }
        /**
         * contract_group.get_sorted_data_for_formula() [this function gives new position of dataview items.]
         * @return [returns the formula sorted data from formula grid in xml format.]
         */
        contract_group.get_sorted_data_for_formula = function() {
            var active_tab_id = contract_group.tabbar.getActiveTab();
            var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            var dataview_object = contract_group["dataview_formula_" + object_id];
            var count = dataview_object.dataCount();
            var return_ids_xml = '<Root>';
            for (i = 0; i < count; i++) {
                id = dataview_object.idByIndex(i);
                nested_id = dataview_object.item(id).nested_id;
                seq_order = dataview_object.item(id).row;
                return_ids_xml += '<PSRecordSet nested_id="' + nested_id + '" seq_order="' + seq_order + '"></PSRecordSet>';
            }
            return_ids_xml += '</Root>';
            return return_ids_xml;
        }
        /**
         * select_clicked() [this function trigger when dataview item selected.]
         * @param [string] formula_id of the formula.
         * @return [opens up formula builder screen.]
         */
       function select_clicked(formula_id,row,nested_id,formula_group_id) {
            if (!has_rights_contract_formula_ui)
                return;
            if (typeof formula_id === "undefined")
                formula_id = 'NULL';
            var g = isNaN(formula_group_id);
            if(g)
                formula_group_id = 'NULL';
            if (typeof nested_id === "undefined")
                nested_id = 'NULL';
            param = '../../_setup/formula_builder/formula.editor.php?formula_id=' + formula_id +'&formula_group_id='+formula_group_id+'&sequence_number='+row+'&formula_nested_id='+nested_id+'&call_from=other&is_pop=true';
            var is_win = dhxWins.isWindow('w1');
            if (is_win == true) {
                w1.close();
            }
            w1 = dhxWins.createWindow("w1", 20, 10, 900, 530);
            w1.setText("Formula Editor");
            w1.setModal(true);
            w1.attachURL(param, false, true);
        }
        /**
         * callback function
         * formula_editor_callback() [this function triggered after the formula builder is closed.]
         * @param [array] return_value
         * @return [callback function]
         */
        function formula_editor_callback(return_value) {
            var active_tab_id = contract_group.tabbar.getActiveTab();
            var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            var dataview_object = contract_group["dataview_formula_" + object_id];
            var id = dataview_object.getSelected();
            if (return_value[0] == 'Remove') {
                formula_group_id = '';
                dataview_object.item(id).formula_id = formula_group_id;
                dataview_object.item(id).formula = formula_group_id;
                dataview_object.refresh(id);
            }
            else {
                formula_group_id = return_value[0];
                formula_value = return_value[1];
                formula_value = formula_value.replace(/</g, "&lt;");
				dataview_object.item(id).formula_id = formula_group_id;
                dataview_object.item(id).formula = formula_value;
                dataview_object.refresh(id);
            }
        }
        /****************************************************END OF DATAVIEW************************************************************/

        /*****************************************************FORMULA TOOLBAR**************************************************************/
        /**
         * contract_group.grd_formula_toolbar_click() [this function is triggered when formula toolbar is triggered.]
         * @param [int] id id of the button.[add,save and delete]
         */
        contract_group.grd_formula_toolbar_click = function(id) {
            var active_tab_id = contract_group.tabbar.getActiveTab();
            var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            if (id == 'add') {//when add is clicked.
                var count = contract_group["dataview_formula_" + object_id].dataCount();
                count = count + 1;
                contract_group["dataview_formula_" + object_id].add({
                    id: 'dataview_' + count,
                    row: count,
                    description_1: "",
                    formula: "",
                    nested_id: "",
                    granularity: "",
                    volume: ""
                });
                contract_group["dataview_formula_" + object_id].select('dataview_' + count);
                contract_group["dataview_formula_" + object_id].show('dataview_' + count);
                contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("additional");
            }
            else if (id == 'save') {//when save is clicked.
                var selectedGridId = contract_group["contract_component_grid_" + object_id].getSelectedRowId();
                var formula_xml = '<Root contract_detail_id="' + selectedGridId + '">';
                var i = 1;
                var save_validation_status = 1;
                var items = contract_group["dataview_formula_" + object_id].dataCount();
                if (items > 0) {
                    id = contract_group["dataview_formula_" + object_id].first();
                    data = contract_group["dataview_formula_" + object_id].get(id);
                    for (var loop = 1; loop <= items; loop++) {
                        var nested_id = data.nested_id;
                        var formula_description = data.description_1;
                        var nested_formula_id = data.formula_id;
                        var row_seq = data.row;
                       
                        if (!nested_formula_id) {
                            var message = get_message('VALIDATE_FORMULA');
                            show_messagebox(message);
                            return false;
                        }
                        if (!formula_description) {
                            var message = get_message('VALIDATE_DESC');
                            show_messagebox(message);
                            return false;
                        }
                        if (nested_id)
                            formula_xml += '<FormulaUpdate nested_id=' + '"' + nested_id + '" ' + 'formula_description="' + formula_description + '" nested_formula_id="' + nested_formula_id + '" row_seq="' + row_seq + '"></FormulaUpdate>';
                        else
                            formula_xml += '<FormulaInsert nested_id=' + '"' + nested_id + '" ' + 'formula_description="' + formula_description + '" nested_formula_id="' + nested_formula_id + '" row_seq="' + row_seq + '"></FormulaInsert>';

                        id = contract_group["dataview_formula_" + object_id].next(id);
                        data = contract_group["dataview_formula_" + object_id].get(id);
                    }
                }
                var deleted_xml = contract_group["contract_component_grid_" + object_id].getUserData("", "formula_delete_xml");
                formula_xml += deleted_xml + '</Root>';
                data = {"action": "spa_contract_charge_type_detail_UI",
                    "flag": "w",
                    "xml": formula_xml,
                    "session_id": session
                };
                adiha_post_data('alert', data, '', '', 'contract_group.callback_formula_save');
                contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("remove");
            }

            else if (id == 'remove') {//when delete is clicked.
                var selectedId = contract_group["dataview_formula_" + object_id].getSelected();
                if (!selectedId) {
                    var message = 'Please select formula item';
                    show_messagebox(message);
                    return false;
                }
                var active_tab_id = contract_group.tabbar.getActiveTab();
                var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
                var dataview_object = contract_group["dataview_formula_" + object_id];
                var count = dataview_object.dataCount();
                var data = dataview_object.get(selectedId);
                var a = selectedId.indexOf("dataview_");
                if (a < 0) {
                    var nested_id = data.nested_id;
                    var fomula_xml = '';
                    var deleted_xml = contract_group["contract_component_grid_" + object_id].getUserData("", "formula_delete_xml");
                    fomula_xml = fomula_xml + '<FormulaDelete nested_id=' + '"' + nested_id + '"' + '></FormulaDelete>';
                    fomula_xml = fomula_xml + deleted_xml;
                    contract_group["contract_component_grid_" + object_id].setUserData("", "formula_delete_xml", fomula_xml);
                }
                dhtmlx.message({
                    title: "Confirmation",
                    type: "confirm",
                    ok: "Confirm",
                    text:"Are you sure you want to delete?",
                    callback: function(type) {
                        if (type) {
                            contract_group["dataview_formula_" + object_id].remove(selectedId);
                            for (i = 0; i < count; i++) {
                                id = dataview_object.idByIndex(i);
                                dataview_object.item(id).row = i + 1;
                                dataview_object.refresh(id);
                            }
                        }
                    }
                });
                
                for (i = 0; i < count; i++) {
                    id = dataview_object.idByIndex(i);
                    dataview_object.item(id).row = i + 1;
                    dataview_object.refresh(id);
                }
                contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("remove");
            }
            else if (id == 'additional') {//when additional is clicked.

                var dataview_object = contract_group["dataview_formula_" + object_id];
                var id = dataview_object.getSelected();
                var nested_id = dataview_object.item(id).nested_id;
                
                param = 'formula.additional.php?id=' + nested_id + '&is_pop=true&right='+ has_rights_contract_formula_ui;

                var is_win = dhxWins.isWindow('contract_group.w4');
                if (is_win == true) {
                    contract_group.w4.close();
                }
                contract_group.w4 = dhxWins.createWindow("w2", 250, 10, 600, 300);
                contract_group.w4.setText("Formula Addtional");
                contract_group.w4.setModal(true);
                contract_group.w4.attachURL(param, false, true);
            }
        }
        /*
         * Callback function for formula save. 
         * @param {type} result
         * @returns {undefined}         
         */
        contract_group.callback_formula_save = function(result) {
            var active_tab_id = contract_group.tabbar.getActiveTab();
            var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            contract_group["dataview_formula_" + object_id].clearAll();
            var selectedId = contract_group["contract_component_grid_" + object_id].getSelectedRowId();
            var ind = contract_group["contract_component_grid_" + object_id].getSelectedCellIndex();
            data = {"action": "spa_contract_charge_type_detail",
                "flag": "a",
                "contract_detail_id": selectedId,
                "session_id": session
            };
            adiha_post_data('return_array', data, '', '', ' contract_group.build_formula_dataview', false);
           // contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("remove");
        }
        /*************************************************END OF FORMULA TOOLBAR**********************************************************/
        /*END*/
        /*Triggers when save button for tabs is clicked*/
        /*START*/
        contract_group.save_contract = function(tab_id) {
            var active_tab_id = contract_group.tabbar.getActiveTab();
            var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            /*if (contract_group_layout.validate() == false) {
                return;
            }*/
            
            var form_xml = '<Root function_id="<?php echo $function_id;?>"><FormXML ';
            var validation_status = 1;
            layout_obj = contract_group["inner_tab_layout_" + object_id].cells('a').getAttachedObject();
            if (layout_obj instanceof dhtmlXForm) {
                attached_obj=layout_obj;
                var status = validate_form(attached_obj);
                if (status == false) {
                    generate_error_message();
                    validation_status = 0;
                }
                data = layout_obj.getFormData();
                for (var a in data) {
                    field_label = a;
                    if (field_label == 'contract_charge_desc') {
                        contract_group["contract_component_grid_" + object_id].setUserData("", "contract_charge_desc", data[a]);
                    }
                    field_value = data[a];
                    form_xml += " " + field_label + "=\"" + field_value + "\"";
                }
            }

            form_xml += "></FormXML></Root>";
            if(validation_status) {
                contract_group.tabbar.tabs(tab_id).getAttachedToolbar().disableItem('save');
                data = {"action": "spa_process_form_data", "xml": form_xml};
                result = adiha_post_data("alert", data, "", "", "contract_group.post_callback");
            }
        }
        function post_callback_grd_refresh() {
            var param = {
                "flag": "g",
                "grid_type": "g",
                "action": "spa_contract_charge_type"
            };

            param = $.param(param);
            var param_url = js_data_collector_url + "&" + param;
            contract_group.grid.clearAll();
            contract_group.grid.loadXML(param_url);
        }
        /*END*/
        contract_group.post_callback = function(result) {
            var tab_id = '';
            var active_tab_id = contract_group.tabbar.getActiveTab();
            var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            var contract_name = contract_group["contract_component_grid_" + object_id].getUserData("", "contract_charge_desc");
            if (has_rights_contract_ui) {
                contract_group.tabbar.tabs(active_tab_id).getAttachedToolbar().enableItem('save');
            };
            if (result[0].errorcode == 'Success') {
                //var contract_name = contract_group["contract_component_grid_" + object_id].getUserData("", "contract_charge_desc");
            
                if(result[0].recommendation == null){
                    contract_group.tabbar.tabs(active_tab_id).setText(contract_name);
                } else {
                    tab_id = 'tab_' + result[0].recommendation;
                    contract_group.create_tab_custom(tab_id, contract_name);
                    contract_group.tabbar.tabs(active_tab_id).close(true);
                }
            }
            contract_group.refresh_grid();
            contract_group.menu.setItemDisabled("delete");
            contract_group.menu.setItemDisabled("copy");
        }
        /*Triggers when window is to be undocked.*/
        /*START*/
        contract_group.undock_window = function() {
            var active_tab_id = contract_group.tabbar.getActiveTab();
            var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            w1 = contract_group["inner_tab_layout_" + object_id].cells('b').undock(300, 300, 900, 700);
            contract_group["inner_tab_layout_" + object_id].dhxWins.window('b').button('park').hide();
            contract_group["inner_tab_layout_" + object_id].dhxWins.window('b').maximize();
            contract_group["inner_tab_layout_" + object_id].dhxWins.window('b').centerOnScreen();
        }
        /*END*/
        contract_group.charge_type_post_callback = function(result) {
            if (result) {
                contract_group.ID = result[0].recommendation;
            }
            var active_tab_id = contract_group.tabbar.getActiveTab();
            var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            
            var grid_obj_name = 'contract_group[' + '"' + 'contract_component_grid_' + object_id + '"' + ']';
            contract_group["contract_component_grid_" + object_id].clearAll();
            contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("add");
            contract_group["contract_toolbar_grid_" + object_id].setItemDisabled("copy");
            contract_group["contract_toolbar_grid_" + object_id].setItemDisabled("remove");
            var str = "<?php echo $sql_string; ?>";
            var spa_url = str.replace("<ID>", object_id);
            var additional_data1 = {"sp_url": spa_url,
                "grid_obj_name": grid_obj_name,
                "session_id": session
            };
            url = php_script_loc_ajax + "load_grid_data.php"
            data = $.param(additional_data1);
            $.ajax({
                type: "POST",
                dataType: "json",
                url: url,
                data: data,
                success: function(data) {
                    eval((data));
					update_charge_type_sequence();
                },
                error: function(xht) {
                    show_messagebox('error');
                }

            });
            
            var is_win = dhxWins.isWindow('w3');
        }
        contract_group.create_tab_custom = function(full_id,text) {
            var spa_url = "<?php echo $grid_sp;?>";
            grid_obj_name = ' contract_group.grid';
            contract_group.grid.clearAll();
            var additional_data1 = {"sp_url": spa_url,
                                    "grid_obj_name": grid_obj_name,
                                    "group_by": 0,
                                    "session_id": session
                                };
            url = php_script_loc_ajax + "load_grid_data.php"
            data = $.param(additional_data1);
            $.ajax({
                type: "POST",
                dataType: "json",
                url: url,
                data: data,
                success: function(data) {
                    eval((data));
                },
                error: function(xht) {
                    show_messagebox('error');
                }

            });
            if (!contract_group.pages[full_id]) {
                contract_group.tabbar.addTab(full_id, text, null, null, true, true);
                var win = contract_group.tabbar.cells(full_id);
                win.progressOn();
                //using window instead of tab 
                var toolbar = win.attachToolbar();
                toolbar.setIconsPath("<?php echo $app_php_script_loc; ?>components/lib/adiha_dhtmlx/themes/"+theme_selected+"/imgs/dhxtoolbar_web/");
                toolbar.attachEvent("onClick", contract_group.tab_toolbar_click);
                toolbar.loadStruct([{id: "save", type: "button", img: "save.gif", text: "Save", title: "Save"}]);
                contract_group.tabbar.cells(full_id).setActive();
                contract_group.tabbar.cells(full_id).setText(text);
                contract_group.load_contract(win, full_id);
                contract_group.pages[full_id] = win;
            }
            else {
                contract_group.tabbar.cells("'"+full_id+"'").setActive();
            }
        };

        contract_group.delete_contract_template = function() {
            var selectedId = contract_group.grid.getSelectedRowId();
            if (selectedId == 'NULL') {
                var message = get_message('VALIDATE_DATA');
                show_messagebox(message);
                return false;
            }

            // Handle multiple selection deletion
            var id = "";
            if (selectedId.indexOf(",") != -1) {
                var sel_id_arr = selectedId.split(",");
                for (var i = 0; i < sel_id_arr.length; i++) {
                    id += "," + contract_group.grid.cells(sel_id_arr[i], 0).getValue();
                }
            } else {
                id += contract_group.grid.cells(selectedId, 0).getValue();
            }
            id = id.replace(/^,/, '');

            var success_message = get_message('DELETE_SUCCESS');
            var error_message = get_message('DELETE_FAILED');

            data = {"action": "spa_contract_charge_type",
                "flag": "d",
                "contract_charge_type_id": id,
                "session_id": session
            };

            adiha_post_data('confirm', data, '', '', 'contract_group.success_delete_contract');
        }

        contract_group.success_delete_contract = function(result) {
            if (result[0].errorcode == 'Success') {
                var selectedId = contract_group.grid.getSelectedRowId();
                var sel_id_array = [];
                if (selectedId.indexOf(",") != -1) {
                    var sel_id_arr = selectedId.split(",");
                    for (var i = 0; i < sel_id_arr.length; i++) {
                        sel_id_array.push(contract_group.grid.cells(sel_id_arr[i], 0).getValue());
                        contract_group.grid.deleteRow(sel_id_arr[i]);
                    }
                } else {
                    sel_id_array.push(contract_group.grid.cells(selectedId, 0).getValue());
                }
                
                //clsoe the tab if the contract is deleted from the grid.
                var ids = contract_group.tabbar.getAllTabs();
                if (ids) {
                    contract_group.tabbar.forEachTab(function(tab) {
                        var id = tab.getId();
                        var object_id = (id.indexOf("tab_") != -1) ? id.replace("tab_", "") : id;
                        if (sel_id_array.indexOf(object_id) > -1)
                            contract_group.tabbar.tabs(id).hide();
                    });
                }
            }
            contract_group.refresh_grid();
            contract_group.menu.setItemDisabled("delete");
            contract_group.menu.setItemDisabled("copy"); 

        }

        /**
         * get_message() [get the message for the message box.]
         * @param [string] message_code [the code to obtain the required message according to the code.]
         * @return [string] html_str [return the message.]
         */
        function get_message(message_code) {
            switch (message_code) {
                case 'VALIDATE_DATA':
                    return 'Please select data first.';
                case 'DELETE_CONFIRM':
                    return 'Are you sure you want to delete the selected data?';
                case 'DELETE_SUCCESS':
                    return 'Data deleted successfully.';
                case 'DELETE_FAILED':
                    return 'Failed to delete data.';
                case 'INSERT_SUCCESS':
                    return 'Data Inserted Successfully';
                case 'UPDATE_SUCCESS':
                    return 'Data Updated Successfully';
                case 'INSERT_FAILED':
                    return 'Failed to Insert Data';
                case 'UPDATE_FAILED':
                    return 'Failed to Update Data';
                case 'SAVE_SUCCESS':
                    return 'Successfully Saved Contract Detail values.';
                case 'SAVE_FAIL':
                    return 'Failed to save Contract Detail values.';
                case 'DUPLICATE_DATA':
                    return 'Cannot save wtih duplicate contract components.';
                case 'SELECT_DATA':
                    return 'One of the contract component is not selected.';
                case 'VALIDATE_FORMULA':
                    return 'Formula is not inserted.';
                case 'VALIDATE_DESC':
                    return 'Description is empty.';
                case 'VALIDATE_GRID':
                    return 'Please insert some missing values in grid.';
            }
        }
    </script>
    <style type="text/css">
        html, body {
            width: 100%;
            height: 100%;
            margin: 0px;
            overflow: hidden;
        }
        .dhx_item_editor{
            width:210px;
            height:113px;
        }

        img.book_icon {
            float: left;
            margin-right: 10px;
        }


        div.select_button {
            width: 20px;
            height: 50px;
            float: left;
            background-image: url("<?php echo $image_path; ?>dhxtoolbar_web/formula_1.png");
            padding-left: 30px;
            padding-top: 4px;
        }
    </style>
</html>