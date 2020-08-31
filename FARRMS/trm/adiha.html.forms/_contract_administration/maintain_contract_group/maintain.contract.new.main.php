<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
        <?php require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
    </head>
    <?php
    /* Use of standard form */
    /* START */
    $form_namespace = 'contract_group';
    $form_obj = new AdihaStandardForm($form_namespace, 10211200);
    $form_obj->define_grid("contract_group", "EXEC('SELECT  CASE WHEN ISNULL(contract_type_def_id,''1'')=''1'' THEN ''Standard'' ELSE sdv.code END as contract_group_def_id, contract_id,contract_name FROM contract_group cg left join static_data_value sdv  on sdv.value_id=cg.contract_type_def_id and sdv.type_id=38400 order by contract_type_def_id')");
    $form_obj->define_custom_functions('save_contract', 'load_contract');
    echo $form_obj->init_form('Contracts', 'Contract Details');
    echo $form_obj->close_form();
    /* END */

    /* Using grid table for contract component */
    /* START */
    $table_name = 'contract_component';
    $grid_def = "EXEC spa_adiha_grid 's', '" . $table_name . "'";
    $def = readXMLURL2($grid_def);
    $grid_id = $def[0]['grid_id'];
    $table_name = $def[0]['grid_name'];
    $grid_columns = $def[0]['column_name_list'];
    $grid_col_labels = $def[0]['column_label_list'];
    $grid_col_types = $def[0]['column_type_list'];
    $sql_string = trim($def[0]['sql_stmt']);
    $grid_set_visibility = $def[0]['set_visibility'];
    $grid_column_width = $def[0]['column_width'];

    if ($def[0]['dropdown_columns'] != 'NULL' && $def[0]['dropdown_columns'] != '')
        $combo_fields = explode(",", $def[0]['dropdown_columns']);
    $html_string = '';
    foreach ($combo_fields as $combo_column) {
        $column_def = "EXEC spa_adiha_grid @flag='t', @grid_name = '" . $table_name . "', @column_name='" . $combo_column . "'";
        $column_data = readXMLURL2($column_def);
        $html_string .= 'var colIndex_object_id= contract_group["contract_component_grid_object_id"].getColIndexById("' . $combo_column . '");';
        $html_string .= 'var column_object_' . $combo_column . '_object_id' . ' = contract_group["contract_component_grid_object_id"].getColumnCombo(colIndex_object_id);';
        $html_string .= 'column_object_' . $combo_column . '_object_id' . '.enableFilteringMode(true);';
        $html_string .= 'column_object_' . $combo_column . '_object_id' . '.load(' . $column_data[0]['json_string'] . ');';
    }
    /* END */
    /* Using grid table for contract price tab. */
    /* START */
    $table_name1 = 'source_price_curve_def';
    $grid_def1 = "EXEC spa_adiha_grid 's', '" . $table_name1 . "'";
    $def1 = readXMLURL2($grid_def1);
    $grid_id1 = $def1[0]['grid_id'];
    $table_name1 = $def1[0]['grid_name'];
    $grid_columns1 = $def1[0]['column_name_list'];
    $grid_col_labels1 = $def1[0]['column_label_list'];
    $grid_col_types1 = $def1[0]['column_type_list'];
    $sql_string1 = trim($def1[0]['sql_stmt']);
    $grid_set_visibility1 = $def1[0]['set_visibility'];
    $grid_column_width1 = $def1[0]['column_width'];

    if ($def1[0]['dropdown_columns'] != 'NULL' && $def1[0]['dropdown_columns'] != '')
        $combo_fields1 = explode(",", $def1[0]['dropdown_columns']);
    $html_string1 = '';
    foreach ($combo_fields1 as $combo_column1) {
        $column_def1 = "EXEC spa_adiha_grid @flag='t', @grid_name = '" . $table_name1 . "', @column_name='" . $combo_column1 . "'";
        $column_data1 = readXMLURL2($column_def1);
        $html_string1 .= 'var colIndex_object_id= contract_group["contract_price_grid_object_id"].getColIndexById("' . $combo_column1 . '");';
        $html_string1 .= 'var column_object_' . $combo_column1 . '_object_id' . ' = contract_group["contract_price_grid_object_id"].getColumnCombo(colIndex_object_id);';
        $html_string1 .= 'column_object_' . $combo_column1 . '_object_id' . '.enableFilteringMode(true);';
        $html_string1 .= 'column_object_' . $combo_column1 . '_object_id' . '.load(' . $column_data1[0]['json_string'] . ');';
    }
    /* END */

    /* JSON for grid toolbar */
    /* START */
    $button_grid_charge_json = '[
                        {id:"add", type:"button", img:"new.gif", text:"", title:"Add"},
                        {id:"remove", type:"button", img:"paste_dis.gif", text:"", title:"Remove" },
                        {id:"copy", type:"button", img:"copy.gif", text:"", title:"Copy" },
                        {id:"edit", type:"button", img:"edit.gif", text:"", title:"Edit" },
                        {id:"gl_code", type:"button", img:"gl_code.gif", text:"", title:"Gl Code Mapping" }
                    ]';
    /* END */

    /* JSON for formula toolbar */
    /* START */
    $button_grid_formula_json = '[
                        {id:"add", type:"button", img:"new.gif", text:"", title:"Add"},
                        {id:"remove", type:"button", img:"paste_dis.gif", text:"", title:"Remove" },
                        {id:"save", type:"button", img:"save.gif", text:"", title:"Save"},
                        {id:"additional", type:"button", img:"additional.gif", text:"", title:"Additional" }
                    ]';
    /* END */
    /* JSON for contract price grid toolbar */
    /* START */
    $button_pricegrid_formula_json = '[
                        {id:"add", type:"button", img:"new.gif", text:"Add", title:"Add"},
                        {id:"remove", type:"button", img:"paste_dis.gif", text:"Remove", title:"Remove" }
                    ]';
    /* END */
    /* DataView Structure */
    /* START */
    $dataview_name = 'dataview_formula';
    $template = "<div class='select_button' onclick='select_clicked(#formula_id#);'></div><div><div><div><div><span> #row# </span><span></span><span> #description_1# </span></div><div><span> Formula: </span><span> #formula# </span></div><div><span style='display:none;'> Nested ID: </span><span style='display:none;'> #nested_id# </span></div></div></div></div>";
    $tooltip = "<b>#formula#</b>";
    /* END */
    ?>
    <body>
        <div id="layoutObj"></div>
        <!-- will used as windows viewport -->
        <div id="winVP" style="display: none;"></div>
    </body>
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
            background-image: url("<?php echo $image_path;?>dhxtoolbar_web/formula_1.png");
            padding-left: 30px;
            padding-top: 4px;
        }
    </style>
    <script type="text/javascript">
        var php_script_loc_ajax = "<?php echo $app_php_script_loc; ?>";
        var session = "<?php echo $session_id; ?>";
        var combo_string = '<?php echo $html_string; ?>';
        var combo_string1 = '<?php echo $html_string1; ?>';
        var grid_toolbar_json =<?php echo $button_grid_charge_json; ?>;
        var formula_toolbar_json =<?php echo $button_grid_formula_json; ?>;
        var contractprice_toolbar_json =<?php echo $button_pricegrid_formula_json; ?>;
        dhxWins = new dhtmlXWindows();
        $(function() {
            //  contract_group.grid.setColumnHidden(0,true);
            //  contract_group.grid.setColWidth(1,"0");
        });
        /**************************************************** Triggers when the tree is double clicked.********************************************/
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
                    width: 200,
                    fix_size: [true, null]
                },
                {
                    id: "b",
                    text: "Contract Details",
                    header: true,
                    collapse: false,
                    fix_size: [true, null]
                }


            ];
            contract_group["inner_tab_layout_" + object_id] = win.attachLayout({pattern: "2E", cells: inner_tab_layout_jsob});
            contract_group["inner_grid_layout_" + object_id] = contract_group["inner_tab_layout_" + object_id].cells("b").attachLayout({pattern: "2U"});

            /*Attaching status bar for grid pagination*/
            contract_group["inner_grid_layout_" + object_id].cells('a').attachStatusBar({
                height: 30,
                text: '<div id="pagingAreaGrid_b"></div>'
            });
            contract_group["inner_tab_layout_" + object_id].cells("b").showHeader();
            var undock_class = 'undock-btn-' + object_id;
            contract_group["inner_tab_layout_" + object_id].cells('b').setText("<div>Contract Components and Formula <a class=\"" + undock_class + undock_custom"\" style=\"float:right;cursor:pointer\" title=\"Undock\"  onClick=\" contract_group.undock_window();\"><!--&#8599;--></a></div>");
            contract_group["inner_grid_layout_" + object_id].cells('a').hideHeader();
            contract_group["inner_grid_layout_" + object_id].cells('b').hideHeader();

            /*Undock functionality code block*/
            /*START*/
            contract_group["inner_tab_layout_" + object_id].attachEvent("onDock", function(name) {
                $('.undock-btn' + object_id).show();
                $('.undock-btn' + object_id).on("click", function() {
                    contract_group["inner_tab_layout_" + object_id].cells('b').undock();
                });
            });
            contract_group["inner_tab_layout_" + object_id].attachEvent("onUnDock", function(name) {
                $('.undock-btn' + object_id).hide();
            });
            /*END*/
            /*Attaching tabbar to the inner layout*/
            contract_group["contract_tabs_" + object_id] = contract_group["inner_tab_layout_" + object_id].cells("a").attachTabbar();

            /*Attaching toolbar for grid.*/
            /*START*/
            contract_group["contract_toolbar_grid_" + object_id] = contract_group["inner_grid_layout_" + object_id].cells('a').attachToolbar();
            contract_group["contract_toolbar_grid_" + object_id].setIconsPath(php_script_loc_ajax + 'components/lib/adiha_dhtmlx/adiha_toolbar_3.0/adiha_dhtmlxToolbar/common/icons_web/');
            contract_group["contract_toolbar_grid_" + object_id].loadStruct(grid_toolbar_json);
            contract_group["contract_toolbar_grid_" + object_id].attachEvent('onClick', contract_group.grd_charge_toolbar_click);
            contract_group["contract_toolbar_grid_" + object_id].disableItem("gl_code");
            contract_group["contract_toolbar_grid_" + object_id].disableItem("edit");
            contract_group["contract_toolbar_grid_" + object_id].disableItem("copy");
            /*END*/
            /*Attaching grid for contract component.*/
            /*START*/
            contract_group["contract_component_grid_" + object_id] = contract_group["inner_grid_layout_" + object_id].cells('a').attachGrid();
            contract_group["contract_component_grid_" + object_id].setImagePath("<?php echo $image_path;?>dhxtoolbar_web/");
            contract_group["contract_component_grid_" + object_id].setHeader("<?php echo $grid_col_labels; ?>");
            contract_group["contract_component_grid_" + object_id].setColumnIds("<?php echo $grid_columns; ?>");
            contract_group["contract_component_grid_" + object_id].setColTypes("<?php echo $grid_col_types; ?>");
            contract_group["contract_component_grid_" + object_id].setInitWidths("<?php echo $grid_column_width; ?>");
            contract_group["contract_component_grid_" + object_id].setColumnsVisibility("<?php echo $grid_set_visibility; ?>");
            contract_group["contract_component_grid_" + object_id].setPagingWTMode(true, true, true, true);
            contract_group["contract_component_grid_" + object_id].enablePaging(true, 25, 0, 'pagingAreaGrid_b');
            contract_group["contract_component_grid_" + object_id].setPagingSkin('toolbar');
            contract_group["contract_component_grid_" + object_id].enableDragAndDrop(true);
            contract_group["contract_component_grid_" + object_id].attachEvent("onRowSelect", contract_group.load_dataview_formula);
            contract_group["contract_component_grid_" + object_id].init();
            contract_group["contract_component_grid_" + object_id].setUserData("", "grid_delete_xml", "");
            contract_group["contract_component_grid_" + object_id].setUserData("", "grid_update_xml", "");
            contract_group["contract_component_grid_" + object_id].setUserData("", "formula_delete_xml", "");
            contract_group["contract_component_grid_" + object_id].setUserData("", "form_validate_code_xml", "");
            contract_group["contract_component_grid_" + object_id].setUserData("", "pricegrid_delete_xml", "");
            contract_group["contract_component_grid_" + object_id].setUserData("", "contract_mode_xml", "");
            /*Getting tab and form JSON from backend to bind in the main tabbar.*/
            /*START*/
            
            var additional_data = {"action": "spa_create_application_ui_json",
                "flag": "j",
                "application_function_id": "10211200",
                "template_name": "contract_group",
                "parse_xml": "<Root><PSRecordset contract_id=" + '"' + object_id + '"' + "></PSRecordset></Root>",
                "session_id": session
            };
            adiha_post_data('return_array', additional_data, '', '', 'contract_group.load_tab_and_forms');
            /*END*/
            var find = 'object_id';
            combo_evalstring = '';
            var re = new RegExp(find, 'g');
            combo_evalstring = combo_string.replace(re, object_id);
            eval(combo_evalstring);
            grid_obj_name = 'contract_group[' + '"' + 'contract_component_grid_' + object_id + '"' + ']';
            var str = "<?php echo $sql_string; ?>";
            var spa_url = str.replace("<ID>", object_id);
            var additional_data1 = {"sp_url": spa_url,
                "grid_obj_name": grid_obj_name,
                "session_id": session
            };
            url = php_script_loc_ajax + "load_grid_data.php"
            data = $.param(additional_data1);
//            		var jsoned_data = {"total_count":"2", "pos":"0", "data":[{ "ID":"3140","Contract Components":"-10019","GL Account":"","Flat Fee":"","Formula":"Nested Formula","Deal Type":"","EffectiveDate":"","Granularity":"","Contract Template":"","Contract Component Template":"","Alias":""}, 
//{ "ID":"3270","Contract Components":"303143","GL Account":"","Flat Fee":"","Formula":"","Deal Type":"","EffectiveDate":"","Granularity":"","Contract Template":"","Contract Component Template":"","Alias":""}]};contract_group["contract_component_grid_1078"].enableHeaderMenu();		try {contract_group["contract_component_grid_1078"].parse(jsoned_data, "js");		} catch (exception) {			alert("parse json exception.");		}
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
            contract_group["contract_toolbar_formula_" + object_id] = contract_group["inner_grid_layout_" + object_id].cells('b').attachToolbar();
            contract_group["contract_toolbar_formula_" + object_id].setIconsPath(php_script_loc_ajax + 'components/lib/adiha_dhtmlx/adiha_toolbar_3.0/adiha_dhtmlxToolbar/common/icons_web/');
            contract_group["contract_toolbar_formula_" + object_id].loadStruct(formula_toolbar_json);
            contract_group["contract_toolbar_formula_" + object_id].attachEvent('onClick', contract_group.grd_formula_toolbar_click);
            contract_group["contract_toolbar_formula_" + object_id].disableItem("add");
            contract_group["contract_toolbar_formula_" + object_id].disableItem("remove");
            //contract_group["contract_toolbar_formula_" + object_id].disableItem("save");
            contract_group["contract_toolbar_formula_" + object_id].disableItem("additional");
            /*END*/
        }
        /*Callback function to load tabs and form from the result gained by the backend.*/
        /*START*/
        contract_group.load_tab_and_forms = function(result) {
            var active_tab_id = contract_group.tabbar.getActiveTab();
            var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            var result_length = result.length;
            var tab_json = '';
            for (i = 0; i < result_length; i++) {
                if (i > 0)
                    tab_json = tab_json + ",";
                tab_json = tab_json + (result[i][1]);
            }
            tab_json = '{tabs: [' + tab_json + ']}';
            contract_group["contract_tabs_" + object_id] = contract_group["inner_tab_layout_" + object_id].cells("a").attachTabbar();
            contract_group["contract_tabs_" + object_id].loadStruct(tab_json);
            var form_code_xml = ' var form_validation_status=0;';
            for (j = 0; j < result_length; j++) {
                tab_id = 'detail_tab_' + result[j][0];
                var grid_json = JSON.stringify(result[j][4]);
                var check_form_status = (grid_json.indexOf("FORM") != -1) ? true : false;
                if (result[j][2]) {//loads form
                    contract_group["contract_form_" + result[j][0]] = contract_group["contract_tabs_" + object_id].cells(tab_id).attachForm();

                    contract_group["contract_form_" + result[j][0]].loadStruct(result[j][2]);
                    form_code_xml += 'var status_' + result[j][0] + '=contract_group[' + '"' + 'contract_form_' + result[j][0] + '"' + '].validate();';
                    form_code_xml += 'if(!status_' + result[j][0] + '){ form_validation_status=1;}';
                    contract_group["contract_component_grid_" + object_id].setUserData("", "form_validate_code_xml", form_code_xml);
                    if (j == 0) {
                        var contract_mode_value = contract_group["contract_form_" + result[j][0]].getItemValue("contract_id");
                        contract_group["contract_component_grid_" + object_id].setUserData("", "contract_mode_xml", contract_mode_value);
                    }
                }
                else {//loads grid.[Not dyanmic, its static code block.]
                    if (!check_form_status) {
                        contract_group["contract_price_grid_" + object_id] = contract_group["contract_tabs_" + object_id].cells(tab_id).attachGrid();
                        contract_group["contract_price_toolbar_grid_" + object_id] = contract_group["contract_tabs_" + object_id].cells(tab_id).attachToolbar();
                        contract_group["contract_tabs_" + object_id].cells(tab_id).attachStatusBar({
                            height: 30,
                            text: '<div id="pagingAreaPriceGrid"></div>'
                        });

                        contract_group["contract_price_toolbar_grid_" + object_id].setIconsPath(php_script_loc_ajax + 'components/lib/adiha_dhtmlx/adiha_toolbar_3.0/adiha_dhtmlxToolbar/common/icons_web/');
                        contract_group["contract_price_toolbar_grid_" + object_id].loadStruct(contractprice_toolbar_json);
                        contract_group["contract_price_toolbar_grid_" + object_id].attachEvent('onClick', contract_group.grd_price_toolbar_click);
                        contract_group["contract_price_grid_" + object_id].setImagePath("<?php echo $image_path;?>dhxtoolbar_web/");
                        contract_group["contract_price_grid_" + object_id].setHeader("<?php echo $grid_col_labels1; ?>");
                        contract_group["contract_price_grid_" + object_id].setColumnIds("<?php echo $grid_columns1; ?>");
                        contract_group["contract_price_grid_" + object_id].setColTypes("<?php echo $grid_col_types1; ?>");
                        contract_group["contract_price_grid_" + object_id].setInitWidths("<?php echo $grid_column_width1; ?>");
                        contract_group["contract_price_grid_" + object_id].setColumnsVisibility("<?php echo $grid_set_visibility1; ?>");
                        contract_group["contract_price_grid_" + object_id].setPagingWTMode(true, true, true, true);
                        contract_group["contract_price_grid_" + object_id].enablePaging(true, 25, 0, 'pagingAreaPriceGrid');
                        contract_group["contract_price_grid_" + object_id].setPagingSkin('toolbar');
                        contract_group["contract_price_grid_" + object_id].enableDragAndDrop(true);
                        contract_group["contract_price_grid_" + object_id].init();
                        var find = 'object_id';
                        combo_evalstring1 = '';
                        var re = new RegExp(find, 'g');
                        combo_evalstring1 = combo_string1.replace(re, object_id);
                        //alert(combo_evalstring1);
                        eval(combo_evalstring1);
                        grid_obj_name = 'contract_group[' + '"' + 'contract_price_grid_' + object_id + '"' + ']';
                        var str = "<?php echo $sql_string1; ?>";
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
                    }
                }
                contract_id = contract_group["contract_component_grid_" + object_id].getUserData("", "contract_mode_xml");
                if (!contract_id) {
                    contract_group["contract_toolbar_grid_" + object_id].disableItem("add");
                    contract_group["contract_toolbar_grid_" + object_id].disableItem("remove");
                    contract_group["contract_toolbar_grid_" + object_id].disableItem("copy");
                }
            }
        }
        /*END*/
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
            if (id == 'add') {//when add is clicked.
                var RowsNum = contract_group["contract_component_grid_" + object_id].getRowsNum();
                RowsNum = RowsNum + 1;
                param = 'charge.type.php?contract_id=' + object_id + '&mode=i&count=' + RowsNum + '&is_pop=true';
                var is_win = dhxWins.isWindow('w3');
                if (is_win == true) {
                    w3.close();
                }
                w3 = dhxWins.createWindow("w3", 320, 0, 600, 600);
                w3.setText("Charge Type Mapping");
                w3.attachURL(param, false, true);
//                var new_id = (new Date()).valueOf();
//                new_id = new_id + '_grid';
//                contract_group["contract_component_grid_" + object_id].addRow(new_id, "");
//                contract_group["contract_component_grid_" + object_id].selectRow(contract_group["contract_component_grid_" + object_id].getRowIndex(new_id), false, false, true);
            }
            else if (id == 'remove') {//when is delete is clicked
                var selectedId = contract_group["contract_component_grid_" + object_id].getSelectedRowId();
                if (!selectedId) {
                    var message = get_message('VALIDATE_DATA');
                    show_messagebox(message);
                    return false;
                } else {
                    var grid_xml = '';
                    contract_group["contract_component_grid_" + object_id].deleteRow(selectedId);
                    var deleted_xml = contract_group["contract_component_grid_" + object_id].getUserData("", "grid_delete_xml");
                    grid_xml = grid_xml + '<GridDelete contract_detail_id=' + '"' + selectedId + '"' + '></GridDelete>';
                    grid_xml = grid_xml + deleted_xml;
                    contract_group["contract_component_grid_" + object_id].setUserData("", "grid_delete_xml", grid_xml);
                    var grid_xml = '<Root>';
                    var grid_delete_xml = contract_group["contract_component_grid_" + object_id].getUserData("", "grid_delete_xml");
                    grid_xml = grid_xml + grid_delete_xml + '</Root>';
                    contract_group["contract_component_grid_" + object_id].setUserData("", "grid_update_xml", grid_xml);
                    var xml = contract_group["contract_component_grid_" + object_id].getUserData("", "grid_update_xml");
                    data = {"action": "spa_contract_group_detail_UI",
                        "flag": "v",
                        "xml": xml,
                        "session_id": session
                    };
                    adiha_post_data('alert', data, '', '', '');
                    var str = "<?php echo $sql_string; ?>";
                    var spa_url = str.replace("<ID>", object_id);
                    sp_url = {"sp_string": spa_url};
                    result = adiha_post_data("return_data", sp_url, "", "", "contract_group.refresh_contract_component_grid_callback");
                }
            }
            else if (id == 'save') {//when is save is clicked.
                var grid_xml = '<Root>';
                var i = 1;
                var save_validation_status = 1;
                contract_group["contract_component_grid_" + object_id].forEachRow(function(id) {
                    var contract_detail_id = contract_group["contract_component_grid_" + object_id].cells(id, 0).getValue();
                    var contract_component = contract_group["contract_component_grid_" + object_id].cells(id, 1).getValue();
                    if (!contract_component) {
                        var message = get_message('SELECT_DATA');
                        show_messagebox(message);
                        save_validation_status = 0;
                        return;
                    }
                    var a = contract_component_store.indexOf(contract_component);
                    if (a >= 0) {
                        var message = get_message('DUPLICATE_DATA');
                        show_messagebox(message);
                        save_validation_status = 0;
                        return;
                    }
                    contract_component_store.push(contract_component);
                    if (contract_detail_id) {
                        grid_xml = grid_xml + '<GridUpdate contract_id=' + '"' + object_id + '"' + ' contract_detail_id=' + '"' + contract_detail_id + '"' + ' contract_component=' + '"' + contract_component + '"' + ' sequence_order=' + '"' + i + '"' + '></GridUpdate>';
                    }
                    else {
                        grid_xml = grid_xml + '<GridInsert contract_id=' + '"' + object_id + '"' + ' contract_detail_id=' + '"NULL"' + ' contract_component=' + '"' + contract_component + '"' + ' sequence_order=' + '"' + i + '"' + '></GridInsert>';
                    }
                    i++;
                });
                if (save_validation_status) {
                    var grid_delete_xml = contract_group["contract_component_grid_" + object_id].getUserData("", "grid_delete_xml");
                    xml = grid_xml + grid_delete_xml + '</Root>';
                    contract_group["contract_component_grid_" + object_id].setUserData("", "grid_update_xml", grid_xml);
                    var xml = contract_group["contract_component_grid_" + object_id].getUserData("", "grid_update_xml");
                    data = {"action": "spa_contract_group_detail_UI",
                        "flag": "v",
                        "xml": xml,
                        "session_id": session
                    };
                    adiha_post_data('alert', data, '', '', '');
                    var str = "<?php echo $sql_string; ?>";
                    var spa_url = str.replace("<ID>", object_id);
                    sp_url = {"sp_string": spa_url};
                    result = adiha_post_data("return_data", sp_url, "", "", "contract_group.refresh_contract_component_grid_callback");
                }
            }
            else if (id == 'gl_code') {//when gl code mapping is clicked.
                var grid_data = contract_group["contract_component_grid_" + object_id].getSelectedRowId();
                param = 'gl.code.php?contract_detail_id=' + grid_data + '&is_pop=true';
                var is_win = dhxWins.isWindow('w2');
                if (is_win == true) {
                    contract_group.w2.close();
                }

                contract_group.w2 = dhxWins.createWindow("w2", 220, 10, 550, 500);
                contract_group.w2.setText("Gl Code Mapping");
                contract_group.w2.attachURL(param, false, true);
            }
            else if (id == 'edit') {//when edit is clicked.

                var grid_data = contract_group["contract_component_grid_" + object_id].getSelectedRowId();
                var type = contract_group["contract_component_grid_" + object_id].cells(grid_data, 1).getValue();
                param = 'charge.type.php?contract_detail_id=' + grid_data + '&contract_id=' + object_id + '&type=' + type + '&mode=u&is_pop=true';
                var is_win = dhxWins.isWindow('w5');
                if (is_win == true) {
                    w5.close();
                }
                w5 = dhxWins.createWindow("w3", 320, 0, 600, 600);
                w5.setText("Charge Type Mapping");
                w5.attachURL(param, false, true);
            }
        }
        /*END*/
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
            var active_tab_id = contract_group.tabbar.getActiveTab();
            var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;

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
                    }
            );
            contract_group["dataview_formula_" + object_id].attachEvent("oneditkeypress", contract_group.item_clicked);
            contract_group["dataview_formula_" + object_id].attachEvent("onAfterDrop", contract_group.item_moved);
            contract_group["dataview_formula_" + object_id].attachEvent("onAfterSelect", contract_group.item_selected);
            var selectedId = contract_group["contract_component_grid_" + object_id].getSelectedRowId();
            var ind = contract_group["contract_component_grid_" + object_id].getSelectedCellIndex();
            var n = selectedId.indexOf("_grid");//To check if the dataview is inserted new or updated old id.

            if (selectedId && n < 0) {
                var selectedId = contract_group["contract_component_grid_" + object_id].getSelectedRowId();
                var ind = contract_group["contract_component_grid_" + object_id].getSelectedCellIndex();
                data = {"action": "spa_contract_group_detail",
                    "flag": "a",
                    "contract_detail_id": selectedId,
                    "session_id": session
                };
                adiha_post_data('return_array', data, '', '', ' contract_group.build_formula_dataview', false);

            }


            if (n < 0) {
                contract_group["contract_toolbar_formula_" + object_id].enableItem("add");
                contract_group["contract_toolbar_formula_" + object_id].enableItem("remove");
                //contract_group["contract_toolbar_formula_" + object_id].enableItem("save");
                contract_group["contract_toolbar_formula_" + object_id].disableItem("additional");
                contract_group["contract_toolbar_grid_" + object_id].enableItem("gl_code");
                contract_group["contract_toolbar_grid_" + object_id].enableItem("edit");
                contract_group["contract_toolbar_grid_" + object_id].enableItem("copy");
            }
            else {
                contract_group["contract_toolbar_formula_" + object_id].disableItem("add");
                contract_group["contract_toolbar_formula_" + object_id].disableItem("remove");
                //contract_group["contract_toolbar_formula_" + object_id].disableItem("save");
                contract_group["contract_toolbar_formula_" + object_id].disableItem("additional");
                contract_group["contract_toolbar_grid_" + object_id].disableItem("gl_code");
                contract_group["contract_toolbar_grid_" + object_id].disableItem("edit");
                contract_group["contract_toolbar_grid_" + object_id].disableItem("copy");
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
         * contract_group.item_selected() [this function is triggered when dataview is clicked.]
         * @param [string] context
         */
        contract_group.item_selected = function(id) {
            var active_tab_id = contract_group.tabbar.getActiveTab();
            var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            var dataview_object = contract_group["dataview_formula_" + object_id];
            if (dataview_object.item(id).nested_id) {
                contract_group["contract_toolbar_formula_" + object_id].enableItem("additional");
            }
            else {
                contract_group["contract_toolbar_formula_" + object_id].disableItem("additional");
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
         * submit_sp() [this is the function to submit.]
         * @param [string] xml
         * @param [string] flag
         */
        function submit_sp(xml, flag) {
            data = {"action": "spa_contract_group_detail_UI",
                "flag": flag,
                "xml": xml,
                "session_id": session
            };
            adiha_post_data('alert', data, '', '', '');
        }
        /**
         * select_clicked() [this function trigger when dataview item selected.]
         * @param [string] formula_id of the formula.
         * @return [opens up formula builder screen.]
         */
        function select_clicked(formula_id) {
            if (typeof formula_id === "undefined")
                formula_id = 'NULL';
            param = '../../_deal_capture/maintain_deals/new.formula.editor.main.php?formula_id=' + formula_id + '&call_from=other&is_pop=true';
            var is_win = dhxWins.isWindow('w1');
            if (is_win == true) {
                w1.close();
            }
            w1 = dhxWins.createWindow("w1", 20, 10, 900, 530);
            w1.setText("Formula Editor");
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
                    nested_id: ""
                });
                contract_group["dataview_formula_" + object_id].select('dataview_' + count);
                contract_group["dataview_formula_" + object_id].show('dataview_' + count);
            }
            else if (id == 'save') {//when save is clicked.
                var selectedGridId = contract_group["contract_component_grid_" + object_id].getSelectedRowId();
                var formula_xml = '<Root contract_detail_id="' + selectedGridId + '">';
                var i = 1;
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
                data = {"action": "spa_contract_group_detail_UI",
                    "flag": "v",
                    "xml": formula_xml,
                    "session_id": session
                };
                adiha_post_data('alert', data, '', '', '');
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
                contract_group["dataview_formula_" + object_id].remove(selectedId);
                for (i = 0; i < count; i++) {
                    id = dataview_object.idByIndex(i);
                    dataview_object.item(id).row = i + 1;
                    dataview_object.refresh(id);
                }
            }
            else if (id == 'additional') {//when additional is clicked.

                var dataview_object = contract_group["dataview_formula_" + object_id];
                var id = dataview_object.getSelected();
                var nested_id = dataview_object.item(id).nested_id
                param = 'formula.additional.php?id=' + nested_id + '&is_pop=true';
                var is_win = dhxWins.isWindow('contract_group.w4');
                if (is_win == true) {
                    contract_group.w4.close();
                }

                contract_group.w4 = dhxWins.createWindow("w2", 220, 10, 900, 400);
                contract_group.w4.setText("Formula Addtional");
                contract_group.w4.attachURL(param, false, true);
            }


        }
        /*************************************************END OF FORMULA TOOLBAR**********************************************************/
        /*END*/
        /*Triggers when save button for tabs is clicked*/
        /*START*/
        contract_group.save_contract = function(tab_id) {
            var active_tab_id = contract_group.tabbar.getActiveTab();
            var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;

            if (contract_group["contract_component_grid_" + object_id].getUserData("", "contract_mode_xml"))
                contract_id = contract_group["contract_component_grid_" + object_id].getUserData("", "contract_mode_xml");
            else
                contract_id = 'NULL';
            var form_validate_code_xml = contract_group["contract_component_grid_" + object_id].getUserData("", "form_validate_code_xml");
            eval(form_validate_code_xml);
            var detail_tabs = contract_group["contract_tabs_" + object_id].getAllTabs();
            if (!form_validation_status) {
                var form_xml = '<FormXML ';
                var grid_xml = "";
                var final_xml = "";
                $.each(detail_tabs, function(index, value) {
                    layout_obj = contract_group["contract_tabs_" + object_id].cells(value).getAttachedObject();
                    if (layout_obj instanceof dhtmlXForm) {
                        data = layout_obj.getFormData();
                        for (var a in data) {
                            field_label = a;
                            field_value = data[a];
                            if (!field_value)
                                field_value = 'null';
                            form_xml += " " + field_label + "=\"" + field_value + "\"";
                        }
                    }
                    if (layout_obj instanceof dhtmlXGridObject) {
                        var ids = layout_obj.getAllRowIds();
                        if (ids != "") {
                            var changed_ids = new Array();
                            changed_ids = (ids.indexOf(",") != -1) ? ids.split(",") : ids.split();
                            grid_xml = '';
                            $.each(changed_ids, function(index, value) {
                                grid_xml += '<GridRow ';
                                for (var cellIndex = 0; cellIndex < layout_obj.getColumnsNum(); cellIndex++) {
                                    if (layout_obj.getColumnId(cellIndex) == 'source_system_id')
                                        grid_value = '2';
                                    else if (layout_obj.getColumnId(cellIndex) == 'source_curve_type_value_id')
                                        grid_value = '583';
                                    else if (layout_obj.getColumnId(cellIndex) == 'curve_id' || layout_obj.getColumnId(cellIndex) == 'market_value_id')
                                        grid_value = layout_obj.cells(value, 0).getValue();
                                    else if (layout_obj.getColumnId(cellIndex) == 'contract_id')
                                        grid_value = contract_id;
                                    else
                                        grid_value = layout_obj.cells(value, cellIndex).getValue();
                                    grid_xml += layout_obj.getColumnId(cellIndex) + '= "' + grid_value + '" ';
                                }
                                grid_xml += '></GridRow>';
                            });
                        }
                    }
                });

                grid_xml = '<Grid grid_id="' + "<?php echo $table_name1; ?>" + '">' + grid_xml + '</Grid>';
                var deleted_xml = contract_group["contract_component_grid_" + object_id].getUserData("", "pricegrid_delete_xml");
                // grid_xml += '<GridDelete grid_id="' + "<?php //echo $table_name1;    ?>" + '">' + deleted_xml + '</GridDelete>';
                form_xml += "></FormXML>";
                var object_id1 = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : "NULL";
                final_xml = '<Root function_id="10211200">' + form_xml + '<GridGroup>' + grid_xml + '</GridGroup></Root>';
                //final_xml = '<Root function_id="10211200">' + form_xml + '</Root>';
                alert(final_xml);
                // return;
                data = {"action": "spa_process_form_data", "xml": final_xml};
                contract_id = contract_group["contract_component_grid_" + object_id].getUserData("", "contract_mode_xml");
                if (contract_id)
                    result = adiha_post_data("alert", data, "", "", "");
                else
                    result = adiha_post_data("alert", data, "", "", "contract_group.post_callback");
            }
        }
        /*END*/
        contract_group.post_callback = function(result) {
            var active_tab_id = contract_group.tabbar.getActiveTab();
            contract_group.tabbar.tabs(active_tab_id).close(true);
            var tab_id = 'tab_' + result[0].recommendation;
            contract_group.create_tab_custom(tab_id);
        }
        /*Triggers when window is to be undocked.*/
        /*START*/
        contract_group.undock_window = function() {
            var active_tab_id = contract_group.tabbar.getActiveTab();
            var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            w1 = contract_group["inner_tab_layout_" + object_id].cells('b').undock(300, 300, 800, 600);
            contract_group["inner_tab_layout_" + object_id].dhxWins.window('b').button('minmax').hide();
            contract_group["inner_tab_layout_" + object_id].dhxWins.window('b').button('park').hide();
            contract_group["inner_tab_layout_" + object_id].dhxWins.window('b').centerOnScreen();

        }
        /*END*/
        contract_group.charge_type_post_callback = function(result) {
            var active_tab_id = contract_group.tabbar.getActiveTab();
            var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            grid_obj_name = 'contract_group[' + '"' + 'contract_component_grid_' + object_id + '"' + ']';
            contract_group["contract_component_grid_" + object_id].clearAll();
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
        }

        contract_group.delete_charge_type = function(result) {
            var grid_delete_xml = contract_group["contract_component_grid_" + object_id].getUserData("", "grid_delete_xml");
            alert(grid_delete_xml);
            return;
            var grid_xml = '<Root>';
            var i = 1;
            var save_validation_status = 1;
            contract_group["contract_component_grid_" + object_id].forEachRow(function(id) {
                var contract_detail_id = contract_group["contract_component_grid_" + object_id].cells(id, 0).getValue();
                var contract_component = contract_group["contract_component_grid_" + object_id].cells(id, 1).getValue();
                if (!contract_component) {
                    var message = get_message('SELECT_DATA');
                    show_messagebox(message);
                    save_validation_status = 0;
                    return;
                }
                var a = contract_component_store.indexOf(contract_component);
                if (a >= 0) {
                    var message = get_message('DUPLICATE_DATA');
                    show_messagebox(message);
                    save_validation_status = 0;
                    return;
                }
                contract_component_store.push(contract_component);
                if (contract_detail_id) {
                    grid_xml = grid_xml + '<GridUpdate contract_id=' + '"' + object_id + '"' + ' contract_detail_id=' + '"' + contract_detail_id + '"' + ' contract_component=' + '"' + contract_component + '"' + ' sequence_order=' + '"' + i + '"' + '></GridUpdate>';
                }
                else {
                    grid_xml = grid_xml + '<GridInsert contract_id=' + '"' + object_id + '"' + ' contract_detail_id=' + '"NULL"' + ' contract_component=' + '"' + contract_component + '"' + ' sequence_order=' + '"' + i + '"' + '></GridInsert>';
                }
                i++;
            });
            if (save_validation_status) {
                var grid_delete_xml = contract_group["contract_component_grid_" + object_id].getUserData("", "grid_delete_xml");
                grid_xml = grid_xml + grid_delete_xml + '</Root>';
                contract_group["contract_component_grid_" + object_id].setUserData("", "grid_update_xml", grid_xml);
                var xml = contract_group["contract_component_grid_" + object_id].getUserData("", "grid_update_xml");
                data = {"action": "spa_contract_group_detail_UI",
                    "flag": "v",
                    "xml": xml,
                    "session_id": session
                };
                adiha_post_data('alert', data, '', '', '');
                var str = "<?php echo $sql_string; ?>";
                var spa_url = str.replace("<ID>", object_id);
                sp_url = {"sp_string": spa_url};
                result = adiha_post_data("return_data", sp_url, "", "", "contract_group.refresh_contract_component_grid_callback");
            }
        }
        contract_group.create_tab_custom = function(full_id) {
            var text = (full_id.indexOf("tab_") != -1) ? full_id.replace("tab_", "") : full_id;
            if (!contract_group.pages[full_id]) {
                contract_group.tabbar.addTab(full_id, text, null, null, true, true);
                var win = contract_group.tabbar.cells(full_id);
                win.progressOn();
                //using window instead of tab
                var toolbar = win.attachToolbar();
                toolbar.setIconsPath("<?php echo  $app_php_script_loc;?>components/lib/adiha_dhtmlx/adiha_toolbar_3.0/adiha_dhtmlxToolbar/common/icons_web/");
                toolbar.attachEvent("onClick", contract_group.tab_toolbar_click);
                toolbar.loadStruct([{id: "save", type: "button", img: "save.gif", text: "Save", title: "Save"}]);
                contract_group.tabbar.cells(full_id).setActive();
                contract_group.tabbar.cells(full_id).setText(text);
                contract_group.load_contract(win, full_id);
                contract_group.pages[full_id] = win;
            }
            else {
                contract_group.tabbar.cells(full_id).setActive();
            }
            ;
        };
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
            }
        }
    </script>
</html>