<!DOCTYPE html>
<html> 
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
    
<body>
    <?php
    $php_script_loc = $app_php_script_loc;
    $app_user_loc = $app_user_name;
    $rights_manual_journal_entry = 10237000;
    $rights_manual_journal_entry_iu = 10237010;
    
    list (
            $has_rights_manual_journal_entry_iu
    ) = build_security_rights(
            $rights_manual_journal_entry_iu
    );
    //Collects defination for tab 
    $form_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='" . $rights_manual_journal_entry . "', @template_name='ManualJournalEntries'";
    $form_data = readXMLURL2($form_sql);

    $tab_data = array();
    $upper_cell_tab_data = array();
    $grid_definition = array();
    $tab_form_json = array();

    if (is_array($form_data) && sizeof($form_data) > 0) {
        foreach ($form_data as $data) {
            array_push($tab_data, $data['tab_json']);
            if ($data['form_json'] != '') array_push($upper_cell_tab_data, $data['tab_json']);
            array_push($tab_form_json, $data['form_json']);

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
    
    $detail_tab_json = 'tabs: [' . implode(",", $tab_data) . ']';
    $upper_cell_tab_json = 'tabs: [' . implode(",", $upper_cell_tab_data) . ']';
    $grid_definition_json = json_encode($grid_definition);
    $tab_form_json = json_encode($tab_form_json);
    
    $namespace = 'ns_manual_journal_entry';
    $form_obj = new AdihaStandardForm($namespace, $rights_manual_journal_entry);
    $form_obj->define_grid("ManualJournalEntries", "", "g");
    $form_obj->define_layout_width(355);
    $form_obj->define_custom_functions('save_data', 'load_form'); //
    echo $form_obj->init_form('Journal Entries', 'Location Details');
    
    echo $form_obj->close_form();
    
    $todays_date = date('m/d/Y');
    
    ?>
</body>
<script>
    ns_manual_journal_entry.details_layout = {};
    //ns_manual_journal_entry.details_toolbar = {};
    ns_manual_journal_entry.details_tabs = {};
    ns_manual_journal_entry.details_form = {};
    ns_manual_journal_entry.grids = {};
    ns_manual_journal_entry.grid_menu = {};
    ns_manual_journal_entry.grid_dropdowns = {};
    
    var tab_form_json = <?php echo $tab_form_json; ?>;
    var grid_definition_json = <?php echo $grid_definition_json; ?>;
    var function_id = '<?php echo $rights_manual_journal_entry; ?>';
    var has_rights_manual_journal_entry = Boolean(<?php echo $rights_manual_journal_entry; ?>);
    var has_rights_manual_journal_entry_iu = Boolean(<?php echo $has_rights_manual_journal_entry_iu; ?>);
    var php_script_loc = '<?php echo $php_script_loc; ?>';
    
    ns_manual_journal_entry.load_form = function(win, tab_id, grid_obj) {
        win.progressOff();
        var is_new = win.getText();
        var collapse = (is_new == 'New') ? true : false;
        
        // get journal entry id from the tab object
        var active_tab_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        // Attach layout - 2 cells upper - 'a', lower - 'b'
        ns_manual_journal_entry.details_layout["details_layout_" + active_tab_id] = win.attachLayout({
            pattern: "2E",
            cells: [
                    {
                        id: "a", 
                        text: "<div><a class=\"undock-btn-a undock_custom\" style=\"float:right;cursor:pointer\" title=\"Undock\"  onClick=\" ns_manual_journal_entry.undock_mappings(" + active_tab_id + ");\"></a>Filter Criteria</div>",
                        header: true,
                        collapse: false,
                        fix_size: [true, null],                        
                        height: 200                       
                    },
                    {
                        id: "b",
                        text: "<div><a class=\"undock-btn-a undock_custom\" style=\"float:right;cursor:pointer\" title=\"Undock\"  onClick=\" ns_manual_journal_entry.undock_mappings(" + active_tab_id + ");\"></a>Journal Entries Detail</div>",
                        header: true,
                        collapse: false,
                        fix_size: [true, null]
                    }
            ]
        });
        detail_layout_obj = ns_manual_journal_entry.details_layout["details_layout_" + active_tab_id];
        
        detail_layout_obj.attachEvent("onDock", function(name) {
                $('.undock-btn-a').show();
            });
        detail_layout_obj.attachEvent("onUnDock", function(name) {
            $('.undock-btn-a').hide();

        });
        
        // upper cell
        
        //alert('form load ' + active_tab_id)
        
        var form_index = "details_form_" + active_tab_id;
        ns_manual_journal_entry.details_form[form_index] = detail_layout_obj.cells('a').attachForm();
        
        var xml_value = '<Root><PSRecordset manual_je_id="' + active_tab_id + '"></PSRecordset></Root>';
        var template_name = 'ManualJournalEntries';
        data = {"action": "spa_create_application_ui_json",
                    "flag": "j",
                    "application_function_id": function_id,
                    "template_name": template_name,
                    "parse_xml": xml_value,
                    "group_name": 'General'
                };
                
        result = adiha_post_data('return_array', data, '', '', 'ns_manual_journal_entry.load_form_data', false); 
        var menu_index = "grid_menu_" + active_tab_id + "_" + tab_id;
        //load form data
        
        
        //Lower cell
        // attach menubar for each tab/grid
        ns_manual_journal_entry.grid_menu[menu_index] = detail_layout_obj.cells("b").attachMenu({
            icons_path: js_image_path + "dhxmenu_web/",
            items: [
                {id: "refresh", text: "Refresh", img: "refresh.gif", img_disabled: "refresh_dis.gif"},
                {id: "edit", text: "Edit", img: "edit.gif", img_disabled: "edit_dis.gif", items: [
                        {id: "add", text: "Add", img: "add.gif", img_disabled: "add_dis.gif", enabled: has_rights_manual_journal_entry_iu},
                        {id: "delete", text: "Delete", disabled: true, img: "delete.gif", img_disabled: "delete_dis.gif"}
                    ]},
                {id: "t2", text: "Export", img: "export.gif", items: [
                        {id: "excel", text: "Excel", img: "excel.gif", imgdis: "excel_dis.gif", title: "Excel"},
                        {id: "pdf", text: "PDF", img: "pdf.gif", imgdis: "pdf_dis.gif", title: "PDF"}
                    ]}
            ]
        });
        var menu_obj = ns_manual_journal_entry.grid_menu[menu_index];
        menu_obj.attachEvent("onClick", function(id) {
            switch (id) {
                case "add":
                    var newId = (new Date()).valueOf();
                    lower_grid_obj.addRow(newId, "");
                    lower_grid_obj.selectRowById(newId);
                    break;
                case "delete":
                    msg = "Are you sure you want to delete?";
                    dhtmlx.message({
                        type: "confirm",
                        title: "Confirmation",
                        ok: "Confirm",
                        text: msg,
                        callback: function(result) {
                            if (result) {
                                lower_grid_obj.deleteSelectedRows();
                            }
                        }
                    });
                    break;
                case "refresh":
                    ns_manual_journal_entry.refresh_detail_grid(lower_grid_obj, active_tab_id);
                    break;
                case "excel":
                    lower_grid_obj.toExcel(php_script_loc + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                    break;
                case "pdf":
                    lower_grid_obj.toPDF(php_script_loc + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                    break;
             }
        });
        
        //if (is_new == 'New') {
//            menu_obj.setItemDisabled("edit");
//            menu_obj.setItemDisabled("refresh");
//        }
        
        i = 1;
        var grid_name = grid_definition_json[i]["grid_name"];
        var grid_index = "grid_" + active_tab_id;
        var grid_cookies = "grid_" + grid_name;
        
        // attach grid to the tab, grid definition that is collected above is used to construct grid
        ns_manual_journal_entry.grids[grid_index] = detail_layout_obj.cells("b").attachGrid();
        lower_grid_obj = ns_manual_journal_entry.grids[grid_index];
        lower_grid_obj.setImagePath(js_image_path + "dhxgrid_web/");
        
        lower_grid_obj.setHeader(",,,,Total,{#stat_total},{#stat_total},#cspan,#cspan,#cspan");
        lower_grid_obj.attachHeader(grid_definition_json[i]["column_label_list"]);
        lower_grid_obj.attachHeader(',,,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter');
        
        //lower_grid_obj.setHeader(grid_definition_json[i]["column_label_list"]);
        lower_grid_obj.setColumnIds(grid_definition_json[i]["column_name_list"]);
        lower_grid_obj.setInitWidths(grid_definition_json[i]["column_width"]);
        lower_grid_obj.setColTypes(grid_definition_json[i]["column_type_list"]);
        lower_grid_obj.setColumnsVisibility(grid_definition_json[i]["set_visibility"]);
        lower_grid_obj.setColSorting(grid_definition_json[i]["sorting_preference"]);
        lower_grid_obj.setColAlign(grid_definition_json[i]["column_alignment"]);
        lower_grid_obj.setDateFormat("%m/%d/%Y");
        lower_grid_obj.enableMultiselect(true);
        lower_grid_obj.enableColumnMove(true);
        lower_grid_obj.setUserData("", "grid_id", grid_name);
        lower_grid_obj.init();
        lower_grid_obj.loadOrderFromCookie(grid_cookies);
        lower_grid_obj.loadHiddenColumnsFromCookie(grid_cookies);
        lower_grid_obj.enableOrderSaving(grid_cookies);
        lower_grid_obj.enableAutoHiddenColumnsSaving(grid_cookies);
        //lower_grid_obj.setColLabel(5,'456')
        lower_grid_obj.attachEvent("onRowSelect", function(row_id, col_id) {
            if (has_rights_manual_journal_entry_iu) {
                menu_obj.setItemEnabled('delete');
            }
        });
        
        lower_grid_obj.attachEvent("onRowDblClicked", function(row_id,col_id) {
            var col_name = lower_grid_obj.getColumnId(col_id);
            if (col_name == 'account_type_name') {
                ns_manual_journal_entry.open_popup_window(row_id, col_id, lower_grid_obj);
            } else return true;

        });
        
        lower_grid_obj.attachEvent("onCellChanged", function(row_id,col_id,new_value) {
            var col_label = lower_grid_obj.getColLabel(col_id,1);
            new_value = (new_value == '&nbsp;') ? null : new_value;
            var col_name = lower_grid_obj.getColumnId(col_id);
            if ((col_name == 'debit_amount' || col_name == 'credit_amount' || col_name == 'volume') && isNaN(new_value)) {
                lower_grid_obj.cells(row_id,col_id).setValue("");
                dhtmlx.alert({
                            title:"Error",
                            type:"alert-error",
                            text:'Please insert valid value in ' + col_label
                        });
                        return;
            }
        });
        
        // populate the dropdowns fields in grids.
        if (grid_definition_json[i]["dropdown_columns"] != null && grid_definition_json[i]["dropdown_columns"] != '') {
            var dropdown_columns = grid_definition_json[i]["dropdown_columns"].split(',');
            _.each(dropdown_columns, function(item) {
                var col_index = lower_grid_obj.getColIndexById(item);
                ns_manual_journal_entry.grid_dropdowns[item + '_' + active_tab_id] = lower_grid_obj.getColumnCombo(col_index);
                ns_manual_journal_entry.grid_dropdowns[item + '_' + active_tab_id].enableFilteringMode(true);

                var cm_param = {"action": "spa_adiha_grid", "flag": "t", "grid_name": grid_definition_json[i]["grid_name"], "column_name": item, "call_from": "grid"};
                cm_param = $.param(cm_param);
                var url = js_dropdown_connector_url + '&' + cm_param;
                ns_manual_journal_entry.grid_dropdowns[item + '_' + active_tab_id].load(url);
            });
        }
        // load grid data
        
        var stmt = grid_definition_json[i]["sql_stmt"];
        ns_manual_journal_entry.refresh_detail_grid(lower_grid_obj, active_tab_id);
        set_default_value();     // sets the value for as_of_date set in setup   
    } //ends ns_manual_journal_entry.load_form
    
    ns_manual_journal_entry.load_form_data = function(result) {
        var active_object_id = ns_manual_journal_entry.tabbar.getActiveTab(); 
        var active_tab_id = (active_object_id.indexOf("tab_") != -1) ? active_object_id.replace("tab_", "") : active_object_id;

        var form_index = "details_form_" + active_tab_id;
        ns_manual_journal_entry.details_form[form_index].loadStruct(result[0][2]);
        ns_manual_journal_entry.details_form[form_index].attachEvent('onChange', function (name, value){
             if (name == 'frequency' && value == 'o') {
                ns_manual_journal_entry.details_form[form_index].disableItem('until_date');
             } else if (name == 'frequency') {
                ns_manual_journal_entry.details_form[form_index].enableItem('until_date');
             } 
        });
        if (ns_manual_journal_entry.details_form[form_index].getItemValue('frequency') == 'o') {
           ns_manual_journal_entry.details_form[form_index].disableItem('until_date'); 
        }
        
        var form_name =  'ns_manual_journal_entry.details_form["details_form_' + active_tab_id + '"]';
        attach_browse_event(form_name, 10233710, '', 'n'); 
        
    }
    
    ns_manual_journal_entry.refresh_detail_grid = function(lower_grid_obj, je_id) {
        // load grid data
        var i = 1;
        var sql_stmt = grid_definition_json[i]["sql_stmt"];
        var grid_type = grid_definition_json[i]["grid_type"];
        
        if (sql_stmt.indexOf('<ID>') != -1) {
            var stmt = sql_stmt.replace('<ID>', je_id);
        } else {
            var stmt = sql_stmt;
        }
        
        var sql_param = {
            "sql": stmt,
            "grid_type": grid_type
        };

        sql_param = $.param(sql_param);
        var sql_url = js_data_collector_url + "&" + sql_param;
        lower_grid_obj.clearAll();
        lower_grid_obj.load(sql_url);
    }
    
    /**
     * [open_popup_window Open popups for data selection]
     */
     var popup_window;
    ns_manual_journal_entry.open_popup_window = function(row_id, col_id, grid_obj) {
        unload_window();
        var win_text = 'Select GL Code';
        var width = 700;
        var height = 550;
        
        if (!popup_window) {
            popup_window = new dhtmlXWindows();
        }
        
        var win_url = '../../../_setup/map_gl_codes/map.gl.codes.php';  
        var params = {read_only:true};
        
        var new_win = popup_window.createWindow('w1', 0, 0, width, height);
        new_win.centerOnScreen();
        new_win.setModal(true);
        new_win.attachEvent('onClose', function(w) {
            var ifr = w.getFrame();
            var ifrWindow = ifr.contentWindow;
            var ifrDocument = ifrWindow.document;
            var close_status = $('textarea[name="close_status"]', ifrDocument).val();
            if (close_status == 'ok') {
                var gl_account_name = $('textarea[name="gl_account_name"]', ifrDocument).val();
                var gl_account_number = $('textarea[name="gl_account_number"]', ifrDocument).val();
                var gl_number_id = $('textarea[name="gl_number_id"]', ifrDocument).val();
                
                grid_obj.cells(row_id,col_id).setValue(gl_account_name);
                
                col_id = grid_obj.getColIndexById('gl_number_id');
                grid_obj.cells(row_id,col_id).setValue(gl_number_id);
                
                col_id = grid_obj.getColIndexById('gl_account_number');
                grid_obj.cells(row_id,col_id).setValue(gl_account_number);
            }            
            return true;
        });
        
        new_win.setText(win_text);        
        new_win.attachURL(win_url, false, params);  
    }

    function unload_window() {
        if (popup_window != null && popup_window.unload != null) {
            popup_window.unload();
            popup_window = w1 = null;
        }
    }
        
    ns_manual_journal_entry.undock_mappings = function(active_tab_id) {
        var layout_obj = detail_layout_obj;
        layout_obj.cells("b").undock(300, 300, 900, 700);
        layout_obj.dhxWins.window("b").button("park").hide();
        layout_obj.dhxWins.window("b").maximize();
        layout_obj.dhxWins.window("b").centerOnScreen();
    }

    ns_manual_journal_entry.save_data = function(tab_id) {
        var active_tab_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        var form_xml = '<FormXML ';
        var grid_xml = "";
        var final_xml = "";
        
        ns_manual_journal_entry.validation_status = 1;
        var form_index = "details_form_" + active_tab_id;
        var form_obj = ns_manual_journal_entry.details_form[form_index];
        var status = validate_form(form_obj);
        var dr_cr_match = 'y';
        if(!status){
            generate_error_message();
            return
        }
        if (status) {
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
                    
                if (field_label == 'dr_cr_match') {
                   dr_cr_match = field_value; 
                }
                
                 if (field_label != 'book_structure' &&
                    field_label != 'subsidiary_id' &&
                    field_label != 'strategy_id' &&
                    field_label != 'subbook_id') 
                    {
                        form_xml += " " + field_label + "=\"" + field_value + "\"";
                    }
            }
        } else {
            ns_manual_journal_entry.validation_status = 0;
        }
        
        var grid_xml = "<GridGroup>";
        var grid_obj = ns_manual_journal_entry.grids["grid_" + active_tab_id];
        grid_obj.clearSelection();
        
        var dr_col_idx = grid_obj.getColIndexById("debit_amount");
        var total_dr = grid_obj.getColLabel(dr_col_idx,0);
        var cr_col_idx = grid_obj.getColIndexById("credit_amount");
        var total_cr = grid_obj.getColLabel(cr_col_idx,0);
        
        if (dr_cr_match == 'y' && (total_dr != total_cr)) {
            dhtmlx.alert({
                title:"Error",
                type:"alert-error",
                text:'Debit & Credit amount must match.'
            });
            return;
        }
            
        for (var row_index = 0, rcount = grid_obj.getRowsNum(); row_index < rcount ; row_index++) {
            grid_xml = grid_xml + "<PSRecordset ";
            for(var cellIndex = 0, c_count = grid_obj.getColumnsNum(); cellIndex < c_count; cellIndex++){
                field_label = grid_obj.getColumnId(cellIndex);
                field_value = grid_obj.cells2(row_index,cellIndex).getValue();
                grid_xml = grid_xml + " " + field_label + '="' + field_value + '"';
            }
            grid_xml = grid_xml + " ></PSRecordset> ";
           

        }
        
        grid_xml += "</GridGroup>";  
        form_xml += "></FormXML>";
        var tab_name = ns_manual_journal_entry.tabbar.tabs(tab_id).getText();
        if (ns_manual_journal_entry.validation_status) {
            ns_manual_journal_entry.tabbar.tabs(tab_id).getAttachedToolbar().disableItem('save');
            if (tab_name == 'New') { 
                flag = 'i';
            } else {
                flag = 'u';
            }
            
            var data = {
                        "action": "spa_manual_journal_entries",
                        "flag": flag,
                        "form_xml": form_xml,
                        "grid_xml": grid_xml
                    };
        
            adiha_post_data('return_json', data, '', '', 'post_data_save', '');
        }
    }
    
    function post_data_save(result) {
        if (has_rights_manual_journal_entry_iu) {
            ns_manual_journal_entry.tabbar.tabs(ns_manual_journal_entry.tabbar.getActiveTab()).getAttachedToolbar().enableItem('save');
        };
        var return_data = JSON.parse(result);
        var tab_name = '';
        if ((return_data[0].status).toLowerCase() == 'success') {
            dhtmlx.message(return_data[0].message); 
            if (return_data[0].recommendation != '') {
                var result_arr = return_data[0].recommendation.split(';'); 
                var new_id = result_arr[0];
                var active_object_id = ns_manual_journal_entry.tabbar.getActiveTab();
                active_tab_id = (active_object_id.indexOf("tab_") != -1) ? active_object_id.replace("tab_", "") : active_object_id; 
                ns_manual_journal_entry.details_form["details_form_" + active_tab_id].setItemValue('manual_je_id', new_id);
                var tab_name = ns_manual_journal_entry.details_form["details_form_" + active_tab_id].getItemValue('as_of_date',true);
                tab_name =dates.convert_to_user_format(tab_name)
                ns_manual_journal_entry.tabbar.tabs(active_object_id).setText(tab_name);
                ns_manual_journal_entry.refresh_grid();
             } 
        } else {
            dhtmlx.alert({
                   title: 'Error',
                   type: "alert-error",
                   text: return_data[0].message
                });
        }
    }
    
    function set_default_value() {
        var sp_string =  "EXEC spa_as_of_date @flag = 'a', @screen_id = " + function_id; 
        var data_for_post = {"sp_string": sp_string};          
        var return_json = adiha_post_data('return_json', data_for_post, '', '', 'set_default_value_call_back');                  
    }
    
    function set_default_value_call_back(return_json) { 
        return_json = JSON.parse(return_json);        
        custom_as_of_date = return_json[0].custom_as_of_date;    
        var active_object_id = ns_manual_journal_entry.tabbar.getActiveTab();
        active_tab_id = (active_object_id.indexOf("tab_") != -1) ? active_object_id.replace("tab_", "") : active_object_id;         
        ns_manual_journal_entry.details_form["details_form_" + active_tab_id].setItemValue('as_of_date', custom_as_of_date);          
    }
</script>
</html>