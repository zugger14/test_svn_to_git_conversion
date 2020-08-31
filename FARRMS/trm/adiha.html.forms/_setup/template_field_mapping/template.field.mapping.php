<?php
/**
* Template field mapping screen
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
    
<body>
<?php
    $function_id = 10106400;
    $form_namespace = 'templateFieldMapping';
    $application_function_id = 10106400;
    $form_obj = new AdihaStandardForm($form_namespace, $application_function_id);
    $form_obj->define_grid("deal_field_mapping", "", "g");
    $form_obj->hide_edit_menu();
    $form_obj->disable_multiple_select();
    echo $form_obj->init_form('Templates', 'Mapping');    
    $form_obj->define_custom_functions('save_mapping', 'load_mapping');
    echo $form_obj->close_form();

    $form_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id=10106400, @template_name='TemplateFieldMapping',@parse_xml='<Root><PSRecordset deal_fields_mapping_id=\"NULL\"></PSRecordset></Root>', @group_name='Location,Contract,Formula Curve,Curve,Fees,Commodity,Counterparty,Trader,Deal Detail Status,UOM,Sub Book'";
    $form_data = readXMLURL2($form_sql);

    $process_sql = "EXEC spa_template_field_mapping @flag='x'";
    $process_data = readXMLURL2($process_sql);
    $process_id = $process_data[0]['process_id'];

    $tab_data = array();
    $grid_definition = array();

    if (is_array($form_data) && sizeof($form_data) > 0) {
    	$icnt = 0;
        foreach ($form_data as $data) {
        	if ($icnt > 0) {
            	array_push($tab_data, str_replace('true', 'false', $data['tab_json']));
        	} else {
            	array_push($tab_data, $data['tab_json']);
        	}

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
            $icnt++;
        }
    }

    $grid_tab_data = 'tabs: [' . implode(",", $tab_data) . ']';
    $grid_definition_json = json_encode($grid_definition);

    $main_gridsp = "EXEC spa_adiha_grid 's','TemplateFieldsMapping'";
    $main_grid_data = readXMLURL2($main_gridsp);

?>
</body>
<script type="text/javascript"> 
    templateFieldMapping.details_layout = {};
    templateFieldMapping.details_tabs = {};
    templateFieldMapping.menu = {};
    templateFieldMapping.grids = {};
    templateFieldMapping.mgrid_dropdowns = {};
    templateFieldMapping.grid_dropdowns = {};
    templateFieldMapping.grid_menu = {};
    var grid_definition_json = <?php echo $grid_definition_json; ?>;    
    var process_id = '<?php echo $process_id;?>';
    var php_script_loc_ajax = "<?php echo $app_php_script_loc; ?>";
    var menu_json = [
                        {id: "refresh", text: "Refresh", img: "refresh.gif", img_disabled: "refresh_dis.gif"},
                        {id: "edit", text: "Edit", img: "edit.gif", img_disabled: "edit_dis.gif", items: [
                            {id: "add", text: "Add", img: "add.gif", img_disabled: "add_dis.gif"},
                            {id: "delete", text: "Delete", disabled: true, img: "delete.gif", img_disabled: "delete_dis.gif"}
                        ]},
                        {id: "t2", text: "Export", img: "export.gif", items: [
                            {id: "excel", text: "Excel", img: "excel.gif", imgdis: "excel_dis.gif", title: "Excel"},
                            {id: "pdf", text: "PDF", img: "pdf.gif", imgdis: "pdf_dis.gif", title: "PDF"}
                        ]}
                    ];

    $(function() {
        templateFieldMapping.tabbar.attachEvent("onTabClose", function(id){
            var tab_id = id;
            var template_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
            var main_grid_index = 'grid_'+template_id+'TemplateFieldsMapping';
            var process_id = '<?php echo $process_id;?>';

            var data = {
                "action":"spa_template_field_mapping",
                "flag":'d',
                "template_id":template_id,
                "grid_name":'deal_fields_mapping',
                "process_id":process_id,
                "call_from":'x'
            }
            adiha_post_data("return_status", data, '', '', '');
            return true;
        });
    })

    templateFieldMapping.save_mapping = function() {
        var tab_id = templateFieldMapping.tabbar.getActiveTab();
        var template_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        var main_grid_index = 'grid_'+template_id+'TemplateFieldsMapping';
        var row_id = templateFieldMapping.grids[main_grid_index].getSelectedRowId();

        templateFieldMapping.save_data('s', row_id, template_id);
    }

    templateFieldMapping.load_mapping = function(win, tab_id, grid_obj) {
        win.progressOff();
        var is_new = win.getText();
        var collapse = (is_new == 'New') ? true : false;

        // get template id from the tab object
        var template_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;

        templateFieldMapping.details_layout["details_layout_" + template_id] = win.attachLayout({
            pattern: "2E",
            cells: [
                {id: "a", header:false},
                {
                    id: "b",
                    text: "Details",
                    header: true,
                    collapse: false,
                    fix_size: [true, null],
                    undock: true
                }
            ]
        });

        templateFieldMapping.details_layout["details_layout_" + template_id].attachEvent("onDock", function(name) {
            $('.undock-btn-a').show();
        });
        templateFieldMapping.details_layout["details_layout_" + template_id].attachEvent("onUnDock", function(name) {
            $('.undock-btn-a').hide();

        });

        templateFieldMapping.menu["menu_" + template_id] = templateFieldMapping.details_layout["details_layout_" + template_id].cells("a").attachMenu({
            icons_path: js_image_path + "dhxmenu_web/",
            items: menu_json
        });

        var main_grid_index = 'grid_'+template_id+'TemplateFieldsMapping';

        templateFieldMapping.grids[main_grid_index] = templateFieldMapping.details_layout["details_layout_" + template_id].cells("a").attachGrid();
        templateFieldMapping.grids[main_grid_index].setImagePath(js_image_path + "dhxgrid_web/");                
        templateFieldMapping.grids[main_grid_index].setHeader('<?php echo $main_grid_data[0]["column_label_list"] ?>');                
        templateFieldMapping.grids[main_grid_index].setColumnIds('<?php echo $main_grid_data[0]["column_name_list"] ?>');
        templateFieldMapping.grids[main_grid_index].setInitWidths('<?php echo $main_grid_data[0]["column_width"] ?>');
        templateFieldMapping.grids[main_grid_index].setColTypes('<?php echo $main_grid_data[0]["column_type_list"] ?>');
        templateFieldMapping.grids[main_grid_index].setColAlign('<?php echo $main_grid_data[0]["column_alignment"] ?>');
        templateFieldMapping.grids[main_grid_index].setColumnsVisibility('<?php echo $main_grid_data[0]["set_visibility"] ?>');
        templateFieldMapping.grids[main_grid_index].setColSorting('<?php echo $main_grid_data[0]["sorting_preference"] ?>');
        templateFieldMapping.grids[main_grid_index].setDateFormat(user_date_format,'%Y-%m-%d');
        // templateFieldMapping.grids[main_grid_index].enableMultiselect(true);
        templateFieldMapping.grids[main_grid_index].enableColumnMove(true);
        templateFieldMapping.grids[main_grid_index].setUserData("", "grid_id", 'TemplateFieldsMapping');
        templateFieldMapping.grids[main_grid_index].init();                      
        templateFieldMapping.grids[main_grid_index].enableHeaderMenu();
        templateFieldMapping.grids[main_grid_index].loadOrderFromCookie('TemplateFieldsMapping');
        templateFieldMapping.grids[main_grid_index].loadHiddenColumnsFromCookie('TemplateFieldsMapping');
        templateFieldMapping.grids[main_grid_index].enableOrderSaving('TemplateFieldsMapping',cookie_expire_date);
        templateFieldMapping.grids[main_grid_index].enableAutoHiddenColumnsSaving('TemplateFieldsMapping',cookie_expire_date);  
        templateFieldMapping.grids[main_grid_index].enableEditEvents(true,false,true);

        var main_grid_dropdowns = '<?php echo $main_grid_data[0]["dropdown_columns"] ?>';

        if (main_grid_dropdowns != null && main_grid_dropdowns != '') {
            var dropdown_columns = main_grid_dropdowns.split(',');
            _.each(dropdown_columns, function(item) {
                var col_index = templateFieldMapping.grids[main_grid_index].getColIndexById(item);
                templateFieldMapping.mgrid_dropdowns[item + '_' + template_id] = templateFieldMapping.grids[main_grid_index].getColumnCombo(col_index);
                templateFieldMapping.mgrid_dropdowns[item + '_' + template_id].enableFilteringMode('between');

                var cm_param = {"action": "spa_adiha_grid", "flag": "t", "grid_name":"TemplateFieldsMapping", "column_name": item, "call_from": "grid"};
                cm_param = $.param(cm_param);
                var url = js_dropdown_connector_url + '&' + cm_param;
                templateFieldMapping.mgrid_dropdowns[item + '_' + template_id].load(url);
            });
        }

        //echo $grid_obj->attach_event("", "onBeforeSelect", $form_namespace . '.grid_before_row_selection');
        templateFieldMapping.grids[main_grid_index].attachEvent("onBeforeSelect", function(new_row, old_row){
            if (old_row != null && old_row != '') {
                templateFieldMapping.save_data('p', old_row, template_id);
            }
            return true;
        });
        

        templateFieldMapping.grids[main_grid_index].attachEvent("onSelectStateChanged", function(ids, inds){
            if (ids != '' && ids != null) {
                templateFieldMapping.menu["menu_" + template_id].setItemEnabled('delete');
                templateFieldMapping.enable_grids(true, template_id, ids);
            } else {
                templateFieldMapping.menu["menu_" + template_id].setItemDisabled('delete');
                templateFieldMapping.enable_grids(false, template_id, null);
            }
        })

        templateFieldMapping.grids[main_grid_index].attachEvent("onEditCell", function(stage,rId,cInd,nValue,oValue){
            var template_index = templateFieldMapping.grids[main_grid_index].getColIndexById('template_id');

            if (cInd == template_index) {
                return false;
            }

            return true;
        })


        templateFieldMapping.menu["menu_" + template_id].attachEvent("onClick", function(id) {
            switch (id) {
                case "refresh":
                    var sql_param = {
                        "action":"spa_template_field_mapping",
                        "flag":"y",
                        "process_id":process_id,
                        "template_id":template_id,
                        "grid_type":"g"
                    };

                    sql_param = $.param(sql_param);
                    var sql_url = js_data_collector_url + "&" + sql_param;
                    templateFieldMapping.details_layout["details_layout_" + template_id].cells("a").progressOn();

                    var changed_rows = templateFieldMapping.grids[main_grid_index].getChangedRows(true);
                    
                    if (changed_rows != '') {
                        confirm_messagebox("There are unsaved changes. Are you sure you want to refresh grid?",
                            function(){
                                templateFieldMapping.delete_unsaved_data(templateFieldMapping.grids[main_grid_index], 'deal_fields_mapping', template_id, '');

                                if (templateFieldMapping.details_tabs["detail_tab_b_" + template_id])
                                    templateFieldMapping.enable_grids(false, template_id, null);    

                                templateFieldMapping.grids[main_grid_index].clearAll();
                                templateFieldMapping.grids[main_grid_index].load(sql_url, function(){
                                    templateFieldMapping.details_layout["details_layout_" + template_id].cells("a").progressOff();
                                });
                            },
                            function(){
                                templateFieldMapping.details_layout["details_layout_" + template_id].cells("a").progressOff();
                            }
                        );
                    } else {
                        if (templateFieldMapping.details_tabs["detail_tab_b_" + template_id])
                            templateFieldMapping.enable_grids(false, template_id, null);

                        templateFieldMapping.grids[main_grid_index].clearAll();
                        templateFieldMapping.grids[main_grid_index].load(sql_url, function(){
                            templateFieldMapping.details_layout["details_layout_" + template_id].cells("a").progressOff();
                        });
                    }
                    break;
                case "add":
                    var new_id = 'New_' + (new Date()).valueOf();
                    templateFieldMapping.grids[main_grid_index].addRow(new_id, [new_id,template_id]);    
                    templateFieldMapping.grids[main_grid_index].selectRowById(new_id);                
                    break;
                case "delete":
                    var selected_row = templateFieldMapping.grids[main_grid_index].getSelectedRowId();

                    confirm_messagebox("Are you sure you want to delete the selected data?",function(){
                        templateFieldMapping.delete_grid_row(templateFieldMapping.grids[main_grid_index], 'deal_fields_mapping'); 
                    });
                    break;
                case "excel":
                    templateFieldMapping.grids[main_grid_index].toExcel(php_script_loc_ajax + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                    break;

                case "pdf":
                    templateFieldMapping.grids[main_grid_index].toPDF(php_script_loc_ajax + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                    break;
            }
        });

        // create lower tabs
        templateFieldMapping.details_tabs["detail_tab_b_" + template_id] = templateFieldMapping.details_layout["details_layout_" + template_id].cells("b").attachTabbar({
            mode: "bottom",
            arrows_mode: "auto",
            <?php echo $grid_tab_data; ?>
        });

        var i = 0;
        templateFieldMapping.details_tabs["detail_tab_b_" + template_id].forEachTab(function(tab) {
            var tab_id = tab.getId();
            var tab_text = tab.getText();
            var menu_index = "grid_menu_" + template_id + "_" + tab_id;

            // attach menubar for each tab/grid
            templateFieldMapping.grid_menu[menu_index] = tab.attachMenu({
                icons_path: js_image_path + "dhxmenu_web/",
                items: menu_json
            });
            templateFieldMapping.grid_menu[menu_index].setItemDisabled("edit");
            templateFieldMapping.grid_menu[menu_index].setItemDisabled("refresh");

            tab.attachStatusBar({
                height: 30,
                text: '<div id="pagingAreaGrid_' + grid_definition_json[i]["grid_name"] + '_' + template_id + '"></div>'
            });

            // variables to create grids
            var grid_name = grid_definition_json[i]["grid_name"];
            var grid_index = "grid_" + template_id + "_" + grid_name;
            var grid_cookies = "grid_" + grid_name;
            var pagination_div_name = 'pagingAreaGrid_' + grid_definition_json[i]["grid_name"] + '_' + template_id;

            var header_allignment;
            var filter;
            var counter = 0;
            $.each(grid_definition_json[i]["column_alignment"].split(','), function(index, value) {                
                if (counter == 0) {
                    header_allignment = 'text-align:' + value ;
                    filter = '#text_filter'
                } else {
                    header_allignment += ',text-align:' + value ;
                    filter += ',#text_filter'
                }
                counter ++;
            }) 


            // attach grid to the tab, grid definition that is collected above is used to construct grid
            templateFieldMapping.grids[grid_index] = tab.attachGrid();
            templateFieldMapping.grids[grid_index].setImagePath(js_image_path + "dhxgrid_web/");                
            templateFieldMapping.grids[grid_index].setHeader(grid_definition_json[i]["column_label_list"],null,header_allignment.split(","));                
            templateFieldMapping.grids[grid_index].setColumnIds(grid_definition_json[i]["column_name_list"]);
            templateFieldMapping.grids[grid_index].setInitWidths(grid_definition_json[i]["column_width"]);
            templateFieldMapping.grids[grid_index].setColTypes(grid_definition_json[i]["column_type_list"]);
            templateFieldMapping.grids[grid_index].setColAlign(grid_definition_json[i]["column_alignment"]);
            templateFieldMapping.grids[grid_index].setColumnsVisibility(grid_definition_json[i]["set_visibility"]);
            templateFieldMapping.grids[grid_index].setColSorting(grid_definition_json[i]["sorting_preference"]);
            templateFieldMapping.grids[grid_index].setDateFormat(user_date_format,'%Y-%m-%d');
            templateFieldMapping.grids[grid_index].setPagingWTMode(true, true, true, true);
            templateFieldMapping.grids[grid_index].enablePaging(true, 25, 0, pagination_div_name);
            templateFieldMapping.grids[grid_index].setPagingSkin('toolbar');
            templateFieldMapping.grids[grid_index].attachHeader(filter);
            templateFieldMapping.grids[grid_index].enableMultiselect(true);
            templateFieldMapping.grids[grid_index].enableColumnMove(true);
            templateFieldMapping.grids[grid_index].setUserData("", "grid_id", grid_name);
            templateFieldMapping.grids[grid_index].init();            
            templateFieldMapping.grids[grid_index].enableHeaderMenu();
            templateFieldMapping.grids[grid_index].loadOrderFromCookie(grid_cookies);
            templateFieldMapping.grids[grid_index].loadHiddenColumnsFromCookie(grid_cookies);
            templateFieldMapping.grids[grid_index].enableOrderSaving(grid_cookies);
            templateFieldMapping.grids[grid_index].enableAutoHiddenColumnsSaving(grid_cookies);
            templateFieldMapping.grids[grid_index].enableEditEvents(true,false,true);

            templateFieldMapping.grids[grid_index].attachEvent("onSelectStateChanged", function(row_id, col_id) {
                if (row_id != '' && row_id != null) {
                    templateFieldMapping.grid_menu[menu_index].setItemEnabled('delete');
                } else {
                    templateFieldMapping.grid_menu[menu_index].setItemDisabled('delete');
                }
            });

            if (grid_definition_json[i]["dropdown_columns"] != null && grid_definition_json[i]["dropdown_columns"] != '') {
                var dropdown_columns = grid_definition_json[i]["dropdown_columns"].split(',');
                _.each(dropdown_columns, function(item) {
                    var col_index = templateFieldMapping.grids[grid_index].getColIndexById(item);
                    templateFieldMapping.grid_dropdowns[item + '_' + template_id] = templateFieldMapping.grids[grid_index].getColumnCombo(col_index);
                    templateFieldMapping.grid_dropdowns[item + '_' + template_id].enableFilteringMode(true);

                    var cm_param = {"action": "spa_adiha_grid", "flag": "t", "grid_name": grid_definition_json[i]["grid_name"], "column_name": item, "call_from": "grid"};
                    cm_param = $.param(cm_param);
                    var url = js_dropdown_connector_url + '&' + cm_param;
                    templateFieldMapping.grid_dropdowns[item + '_' + template_id].load(url);
                });
            }
            var sql_stmt = grid_definition_json[i]["sql_stmt"];
            templateFieldMapping.grid_menu[menu_index].attachEvent("onClick", function(id) {
                switch (id) {
                    case "refresh":
                        tab.progressOn();
                        if (sql_stmt.indexOf('<PROCESS_ID>') != -1) {
                            sql_stmt = sql_stmt.replace('<PROCESS_ID>', process_id);
                        } 
                        var id_index = templateFieldMapping.grids[main_grid_index].getColIndexById('deal_fields_mapping_id');
                        var row_id = templateFieldMapping.grids[main_grid_index].getSelectedRowId();
                        var mapping_id = templateFieldMapping.grids[main_grid_index].cells(row_id, id_index).getValue();

                        if (sql_stmt.indexOf('<MAPPING_ID>') != -1) {
                            sql_stmt = sql_stmt.replace('<MAPPING_ID>', mapping_id);
                        }
                        var sql_param = {
                            "sql": sql_stmt,
                            "grid_type":"g"
                        };
                        sql_param = $.param(sql_param);
                        var sql_url = js_data_collector_url + "&" + sql_param;

                        var changed_rows = templateFieldMapping.grids[grid_index].getChangedRows(true);
                        if (changed_rows != '') {
                            confirm_messagebox("There are unsaved changes. Are you sure you want to refresh grid?",
                                function(){
                                    templateFieldMapping.grids[grid_index].clearAll();
                                    templateFieldMapping.grids[grid_index].load(sql_url, function(){
                                        tab.progressOff();
                                    });
                                },
                                function(){
                                    tab.progressOff();
                                }
                            );
                        } else {
                            templateFieldMapping.grids[grid_index].clearAll();
                            templateFieldMapping.grids[grid_index].load(sql_url, function(){
                                tab.progressOff();
                            });
                        }
                        break;
                    case "add":
                        var id_index = templateFieldMapping.grids[main_grid_index].getColIndexById('deal_fields_mapping_id');
                        var row_id = templateFieldMapping.grids[main_grid_index].getSelectedRowId();
                        var mapping_id = templateFieldMapping.grids[main_grid_index].cells(row_id, id_index).getValue();
                        var new_id = 'New_' + (new Date()).valueOf();
                        templateFieldMapping.grids[grid_index].addRow(new_id, [new_id,mapping_id]);    
                        templateFieldMapping.grids[grid_index].selectRowById(new_id);                
                        break;
                    case "delete":
                        var selected_row = templateFieldMapping.grids[grid_index].getSelectedRowId();

                        confirm_messagebox("Are you sure you want to delete the selected data?",function(){
                            templateFieldMapping.delete_grid_row(templateFieldMapping.grids[grid_index], grid_name);
                                
                        });
                        
                        //templateFieldMapping.grid_menu[menu_index].callEvent("onClick", ['refresh']);
                        break;
                    case "excel":
                        templateFieldMapping.grids[grid_index].toExcel(php_script_loc_ajax + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                        break;

                    case "pdf":
                        templateFieldMapping.grids[grid_index].toPDF(php_script_loc_ajax + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                        break;
                }
            });

            i++;

        });
        templateFieldMapping.details_layout["details_layout_" + template_id].cells("b").showHeader();
        templateFieldMapping.menu["menu_" + template_id].callEvent("onClick", ['refresh']);

    }

    /**
     * [delete_grid_row Delete selected grid row from process table]
     * @param  {[type]} grid_obj  [Grid Object]
     * @param  {[type]} grid_name [Grid Name]
     */
    templateFieldMapping.delete_grid_row = function(grid_obj, grid_name) {
        var selected_row = grid_obj.getSelectedRowId();
        var id_index = grid_obj.getColIndexById(grid_name+'_id'); 
        var selected_id = grid_obj.cells(selected_row, id_index).getValue();

        var data = {
            "action":"spa_template_field_mapping",
            "flag":'d',
            "selected_id":selected_id,
            "grid_name":grid_name,
            "process_id":process_id
        }
        grid_obj.deleteSelectedRows();
        adiha_post_data("return_status", data, '', '', '');
    }

    templateFieldMapping.delete_unsaved_data = function(grid_obj, grid_name, template_id, selected_id) {
        if (selected_id == '' || selected_id === 'undefined') selected_id = 'NULL';
        var data = {
            "action":"spa_template_field_mapping",
            "flag":'d',
            "selected_id":selected_id,
            "grid_name":grid_name,
            "template_id":template_id,
            "process_id":process_id
        }
        adiha_post_data("return_status", data, '', '', '');
    }

    /**
     * [enable_grids Enable Grid Menu and refresh Grid]
     * @param  {[type]} flag        [enable/disable flag]
     * @param  {[type]} template_id [template_id]
     * @param  {[type]} row_id      [Row_id]
     */
    templateFieldMapping.enable_grids = function(flag, template_id, row_id) {  
        var j = 0;
        var main_grid_index = 'grid_'+template_id+'TemplateFieldsMapping';

        var number_of_tabs = templateFieldMapping.details_tabs["detail_tab_b_" + template_id].getNumberOfTabs();
        templateFieldMapping.details_layout["details_layout_" + template_id].cells("b").progressOn();

        templateFieldMapping.details_tabs["detail_tab_b_" + template_id].forEachTab(function(tab) {
            var tab_id = tab.getId();
            var menu_index = "grid_menu_" + template_id + "_" + tab_id;

            var grid_name = grid_definition_json[j]["grid_name"];
            var grid_index = "grid_" + template_id + "_" + grid_name;

            if (flag) {
                templateFieldMapping.grid_menu[menu_index].setItemEnabled("edit");
                templateFieldMapping.grid_menu[menu_index].setItemEnabled("refresh");
            } else {
                templateFieldMapping.grid_menu[menu_index].setItemDisabled("edit");
                templateFieldMapping.grid_menu[menu_index].setItemDisabled("refresh");
                templateFieldMapping.grids[grid_index].clearAll();
                templateFieldMapping.details_layout["details_layout_" + template_id].cells("b").progressOff();
                j++;
                return;
            }

            var id_index = templateFieldMapping.grids[main_grid_index].getColIndexById('deal_fields_mapping_id');
            var mapping_id = templateFieldMapping.grids[main_grid_index].cells(row_id, id_index).getValue();

            var sql_stmt = grid_definition_json[j]["sql_stmt"];
            if (sql_stmt.indexOf('<PROCESS_ID>') != -1) {
                sql_stmt = sql_stmt.replace('<PROCESS_ID>', process_id);
            } 

            if (sql_stmt.indexOf('<MAPPING_ID>') != -1) {
                sql_stmt = sql_stmt.replace('<MAPPING_ID>', mapping_id);
            }
            var sql_param = {
                "sql": sql_stmt,
                "grid_type":"g"
            };

            sql_param = $.param(sql_param);
            var sql_url = js_data_collector_url + "&" + sql_param;
            templateFieldMapping.grids[grid_index].clearAll();
            templateFieldMapping.grids[grid_index].load(sql_url);


            j++;
            if (number_of_tabs == j) {
                templateFieldMapping.details_layout["details_layout_" + template_id].cells("b").progressOff();
                }
            });
    }

    templateFieldMapping.save_data = function(call_from, row_id, template_id) {
        if (row_id != '' && row_id != null) {
            var main_grid_index = 'grid_'+template_id+'TemplateFieldsMapping';
            var main_grid = templateFieldMapping.grids[main_grid_index];
            var number_of_columns = main_grid.getColumnsNum();
            var is_detail_changed = false;
            var changed_rows = main_grid.getChangedRows(true);
            var main_grid_changed_ids = new Array();
            main_grid_changed_ids = changed_rows.split(",");

            var grid_xml = '<GridXML>';

            if ($.inArray(row_id, main_grid_changed_ids) != -1) {
                grid_xml += '<GridRow grid_name="deal_fields_mapping" '         
                for (var cellIndex = 0; cellIndex < number_of_columns; cellIndex++) {
                    var column_id = main_grid.getColumnId(cellIndex);
                    var cell_value = main_grid.cells(row_id, cellIndex).getValue();
                    grid_xml += ' ' + column_id + '="' + cell_value + '"';
                }
                grid_xml += '></GridRow>';
            }
            

            var k = 0;
            templateFieldMapping.details_tabs["detail_tab_b_" + template_id].forEachTab(function(tab) {
                var tab_id = tab.getId();
                var menu_index = "grid_menu_" + template_id + "_" + tab_id;

                var grid_name = grid_definition_json[k]["grid_name"];
                var grid_index = "grid_" + template_id + "_" + grid_name;
                var detail_grid = templateFieldMapping.grids[grid_index];
                var detail_changed = '';
                detail_changed = detail_grid.getChangedRows(true);
                var no_col = detail_grid.getColumnsNum();

                if (detail_changed != '') {
                    is_detail_changed = true;

                    var changed_ids = new Array();
                    changed_ids = detail_changed.split(",");

                    $.each(changed_ids, function(index, value) {
                        grid_xml += '<GridRow grid_name="' + grid_name + '" '
                        for (var cellIndex = 0; cellIndex < no_col; cellIndex++) {
                            var column_id = detail_grid.getColumnId(cellIndex);
                            var cell_value = detail_grid.cells(value, cellIndex).getValue();
                            grid_xml += ' ' + column_id + '="' + cell_value + '"';
                        }
                        grid_xml += '></GridRow>';
                    })                
                }
                k++;
            });

            grid_xml += '</GridXML>';
        } else {
            grid_xml = 'NULL';
        }

        grid_xml = (grid_xml == '<GridXML></GridXML>' || grid_xml == '') ? 'NULL' : grid_xml;

        if (changed_rows == '' && !is_detail_changed && call_from == 'p') {
            return;
        } else {
            var data = {
                "action":"spa_template_field_mapping",
                "flag":"i",
                "process_id":process_id,
                "template_id":template_id,
                "grid_xml":grid_xml,
                "call_from":call_from
            };

            if (call_from == 'p') {
                adiha_post_data('return_status', data, '', '', '');
            } else {
                templateFieldMapping.details_layout["details_layout_" + template_id].progressOn();
                adiha_post_data('alert', data, '', '', 'templateFieldMapping.save_data_callback');
            }
        }
    }

    templateFieldMapping.save_data_callback = function(return_val) {
        var tab_id = templateFieldMapping.tabbar.getActiveTab();
        var template_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        if (return_val[0].errorcode == 'Success') {
            templateFieldMapping.details_layout["details_layout_" + template_id].progressOff();
            var main_grid_index = 'grid_'+template_id+'TemplateFieldsMapping';

            templateFieldMapping.grids[main_grid_index].clearAll();
            templateFieldMapping.menu["menu_" + template_id].callEvent("onClick", ['refresh']);
        } else {
            templateFieldMapping.details_layout["details_layout_" + template_id].progressOff();
        }
    }


</script>
</html>