<?php
/**
* Report manager excel screen
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
        <?php require('../../../adiha.html.forms/_setup/manage_documents/manage.documents.button.php'); ?>
    </head>
    <body>
        <?php
        require('../../../adiha.php.scripts/components/include.file.v3.php');
        $server_path = $BATCH_FILE_EXPORT_PATH;
        $name_space = 'rm_excel';
        $filename_docpath =  str_replace( '\\', '\\\\', $rootdir . '\\' . $farrms_root . '\\adiha.php.scripts\\dev\\shared_docs\\Excel_Reports\\');
        // $php_script_loc = $app_php_script_loc;
        $app_user_loc = $app_user_name;
        $file_id = get_sanitized_value($_GET['excel_file_id'] ?? 'NULL');
        $active_object_id = get_sanitized_value($_POST['active_object_id'] ?? 'NULL');
        
        $rights_rm_excel = 10202600;
        $rights_rm_excel_iu = 10202610;
        $rights_rm_excel_delete = 10202611;
        $rights_rm_excel_download = 10202612;
        $rights_rm_excel_privilege = 10202613;
        list (
            $has_rights_rm_excel_iu,
            $has_rights_rm_excel_delete,
            $has_rights_rm_excel_download,
            $has_rights_rm_excel_privilege
           ) 
        = build_security_rights(
                $rights_rm_excel_iu, 
                $rights_rm_excel_delete,
                $rights_rm_excel_download,
                $rights_rm_excel_privilege
          );
        

        //JSON for Layout
        /*$layout_json = '[
                     {id:"a", text:"Files/Sheets Name", header:true, fix_size:[true,true]}]';
                     */
        $layout_json = '[
            {
                id:             "a",
                text:           "Files/Sheets Name",
                header:         true,
                width:          350,
                collapse:       false,
                fix_size:       [false,null],
                undock:         true
            },
            {
                id:             "b",
                text:           "Detail",
                header:         false,
                collapse:       false,
                fix_size:       [false,null]
            }
        ]';            
                    
        $menu_json = '[
                        {id: "edit", text: "Edit", img:"edit.gif", items: [
                            {id:"upload", img:"upload.gif", text:"Upload", imgdis:"upload_dis.gif", enabled:' . (int)$has_rights_rm_excel_iu . '},
                            {id:"download", text:"Download", img:"download.gif", imgdis:"download_dis.gif", enabled:0},
                            {id:"delete", text:"Delete", img:"remove.gif", imgdis:"remove_dis.gif", enabled:0}                        
                        ]},
                        {id:"export", text:"Export", img:"export.gif", imgdis:"excel_dis.gif", items: [
                            {id:"excel",img:"excel.gif", imgdis:"excel_dis.gif", text:"Excel", title:"Excel"},
                            {id:"pdf", img:"pdf.gif", text:"PDF", title:"PDF"}
                        ]},
                        {id:"privilege", text:"Privilege", img:"privilege.gif", imgdis:"privilege_dis.gif",enabled:0}
                    ]';

        //Creating Layout
        $rm_excel_layout = new AdihaLayout();
        
        echo $rm_excel_layout->init_layout('layout', '', '2U', $layout_json, $name_space);
        echo $rm_excel_layout->attach_tab_cell('rm_excel_tabbar', 'b', '');
        echo $rm_excel_layout->attach_status_bar('a', false, '<div id="pagingArea_a"></div>');
        echo $rm_excel_layout->attach_event('', 'onDock', $name_space . '.on_dock_event');
        echo $rm_excel_layout->attach_event('', 'onUnDock', $name_space.'.on_undock_event');

        //Attach Menu
        echo $rm_excel_layout->attach_menu_cell('menu', 'a');

        $rm_excel_menu = new AdihaMenu();
        echo $rm_excel_menu->init_by_attach('menu', $name_space);
        echo $rm_excel_menu->load_menu($menu_json);
        echo $rm_excel_menu->attach_event('', 'onClick', $name_space . '.menu_click');

        //Attach Grid
        $grid_name = 'rm_excel_grid';
        echo $rm_excel_layout->attach_grid_cell($grid_name, 'a');
        $rm_excel_grid = new GridTable($grid_name);
        echo $rm_excel_grid->init_grid_table($grid_name, $name_space);
        echo $rm_excel_grid->set_search_filter(false,'#text_filter,#numeric_filter,#numeric_filter,#text_filter,#text_filter,#text_filter,#combo_filter'); 
        echo $rm_excel_grid->enable_multi_select(true);
        echo $rm_excel_grid->return_init();
        echo $rm_excel_grid->attach_event('', 'onRowDblClicked', $name_space . '.dbclick_rm_excel_grid');
        echo $rm_excel_grid->attach_event('', 'onRowSelect', $name_space.'.enabled_button');
        echo $rm_excel_grid->attach_event('', 'onBeforeSelect', $name_space.'.before_select');
        echo $rm_excel_grid->enable_paging(25, 'pagingArea_a');
        echo $rm_excel_layout->close_layout();
        ?>

        <style>
            html, body {
                width: 100%;
                height: 100%;
                margin: 0px;
                overflow: hidden;
            }
        </style>


        <script type="text/javascript">
            var has_rights_rm_excel_iu = Boolean (<?php echo $has_rights_rm_excel_iu ?>);
            var has_rights_rm_excel_delete = Boolean (<?php echo $has_rights_rm_excel_delete ?>);
            var has_rights_rm_excel_download = Boolean (<?php echo $has_rights_rm_excel_download ?>);
            var has_rights_rm_excel_privilege = Boolean (<?php echo $has_rights_rm_excel_privilege ?>);

            var active_object_id = '<?php echo $active_object_id; ?>';
            rm_excel_layout = {};
            //rm_excel = {};
            //rm_excel_grid = {};
            var excel_file_id = '<?php echo $file_id; ?>'; 
            var wizard_window;
            var run_window;
            var php_script_loc_ajax = "<?php echo $app_php_script_loc; ?>";
            dhxWins = new dhtmlXWindows();
                
            $(function() {
                rm_excel.excel_file_sheet_grid();
            });
          
            rm_excel.excel_file_sheet_grid = function () {
                var param = {
                            "flag": "g",
                            "action":"spa_excel_addin_report_manager",
                            "grid_type":"tg",
                            "grouping_column":"file_name,sheet_name",
                            "folder_icon":"excel.gif"
                        };

                param = $.param(param);
                var param_url = js_data_collector_url + "&" + param;
                rm_excel.rm_excel_grid.clearAndLoad(param_url, function() {
                    rm_excel.rm_excel_grid.loadOpenStates();
                    rm_excel.rm_excel_grid.expandAll();
                    rm_excel.rm_excel_grid.setEditable(false);

                    rm_excel.menu.setItemDisabled('delete');
                    rm_excel.menu.setItemDisabled('download');
                    rm_excel.menu.setItemDisabled('privilege');
                });
            }

            rm_excel.dbclick_rm_excel_grid = function(id){
                var level = rm_excel.rm_excel_grid.getLevel(id);
                if (level == 0) { 
                    
                    var row_index =rm_excel.rm_excel_grid.getRowIndex(id);  
                    
                    var row_id = rm_excel.rm_excel_grid.getRowId(row_index+1);

                    var file_id = rm_excel.rm_excel_grid.cells(row_id,1).getValue();
                    rm_excel.load_form(file_id,id);
                } 
            }
            
            var filename = '';
            rm_excel.load_form = function(id,filename) {
                var d = new Date();
                var t = d.getTime();
                var mode = '';

                inner_active_tab = '';
                // if (mode == 'i'){
                // inner_active_tab.clearAll();
                // }   
                if (id == 'upload') {
                    var full_id = "tab_" + t;
                    mode = 'mode=i';
                } else {
                    var full_id = "tab_" + id;
                    mode = 'mode=u&file_id=' + id;                    
                }
                // var full_id = "tab_" + (id == 'upload' ? t : id);
                var all_tab_id = rm_excel.rm_excel_tabbar.getAllTabs();
                if (jQuery.inArray(full_id, all_tab_id ) != -1) {
                    rm_excel.rm_excel_tabbar.tabs(full_id).setActive();
                return;
                }

                if (id == 'upload') {
                    rm_excel.rm_excel_tabbar.addTab(full_id, 'New', null, null, true, true);                    
                } else {
                    id = (filename != '') ? filename : id;
                    rm_excel.rm_excel_tabbar.addTab(full_id, id, null, null, true, true);                    
                    // var all_tab_id = rm_excel.rm_excel_tabbar.getAllTabs();
                }
                var win = rm_excel.rm_excel_tabbar.cells(full_id);
                rm_excel.rm_excel_tabbar.cells(full_id).progressOn();
                param = 'report.upload.php?' + mode + '&is_pop=true';
                win.attachURL(param);
                rm_excel.rm_excel_tabbar.tabs(full_id).setActive();
                rm_excel.rm_excel_tabbar.cells(full_id).progressOff();
            }

            rm_excel.getActiveTab = function() {
                var tab_id = rm_excel.rm_excel_tabbar.getActiveTab();
                // rm_excel.rm_excel_tabbar.cells(tab_id).close();
                return tab_id;
            }

            rm_excel.tab_close = function(tab_id) {
                success_call('Changes have been saved successfully.');
                rm_excel.rm_excel_tabbar.cells(tab_id).close();
            }

            rm_excel.menu_click = function(id) {
                switch (id) {
                    case "upload":
                        rm_excel.load_form(id);
                    return;  
                    break;  

                    case "privilege":
                    var selected_row = rm_excel.rm_excel_grid.getSelectedRowId();
                    var row_index = rm_excel.rm_excel_grid.getRowIndex(selected_row);
                    var row_id = rm_excel.rm_excel_grid.getRowId(row_index+1);
                    var value_id = ''; 
                    var type_id = ''; 
                    
                    value_id = rm_excel.rm_excel_grid.cells(selected_row, rm_excel.rm_excel_grid.getColIndexById('sheet_id')).getValue();
                    var type_id = rm_excel.rm_excel_grid.cells(row_id,1).getValue(); 

                    var params = '?value_id=' + value_id
                                + '&type_id=' + type_id
                                + '&call_from=1'
                                + '&selected_row=' + selected_row;

    
                    // unload_static_data_privilege_window();
                    
                    if (!static_data_privilege) {
                        rm_window = new dhtmlXWindows();
                    }
                    
                    var new_win = rm_window.createWindow('w5', 0, 0, 800, 550);
                    
                    var url = 'assign.privilege.php' + params;  
                     
                    new_win.setText("Assign Privileges");  
                    new_win.centerOnScreen();
                    new_win.setModal(true); 
                    new_win.attachURL(url, false, true);
                    break;
                    case "delete":
                        rm_excel.delete_grid();
                        break;
                    case "batch":
                        rm_excel.run_batch();
                        break;
                    case "download":
                         rm_excel.download_file(id);
                        break;
                    case "excel":
                        rm_excel.rm_excel_grid.toExcel(php_script_loc_ajax + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                        break;
                    case "pdf":
                        debugger;
                        rm_excel.rm_excel_grid.toPDF(php_script_loc_ajax + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                        break;

                }
            }


            rm_excel.delete_grid = function() {
                var selectedID = rm_excel.rm_excel_grid.getSelectedRowId();
                var selected_id = selectedID;
                var count = selected_id.indexOf(",") > -1 ? selected_id.split(",").length : 1;
                selected_id = selected_id.indexOf(",") > -1 ? selected_id.split(",") : [selected_id];
                var row_index;
                var row_id;
                var file_id = '';

                for (var i = 0; i < selected_id.length; i++) {
                    row_index =rm_excel.rm_excel_grid.getRowIndex(selected_id[i]);     
                    row_id = rm_excel.rm_excel_grid.getRowId(row_index+1);
                    file_id += rm_excel.rm_excel_grid.cells(row_id,1).getValue();
                    file_id += ',';
                }
                file_id = file_id.slice(0, -1);

                data = {
                        "action": "spa_excel_addin_report_manager",
                        "flag": "z",
                        "del_ids": file_id,
                        "filename":selectedID
                    };

                adiha_post_data('return_json', data, '', '', function(result) {
                        rm_excel.delete_callback_pre (result, file_id, selectedID);
                });
            }

            rm_excel.delete_callback_pre = function(result, file_id, selectedID) {
                var return_data = JSON.parse(result);

                if (return_data[0].errorcode == 'Success') {
                    var text = 'Are you sure you want to delete the file?';
                } else{
                    var text = 'Snapshot exists. Are you sure you want to delete the file?';
                }

                data = {
                        "action": "spa_excel_addin_report_manager",
                        "flag": "d",
                        "del_ids": file_id,
                        "filename":selectedID
                    };

                dhtmlx.message({
                    type: "confirm",
                    title: "Confirmation",
                    text: text,
                    ok: "Confirm",
                    callback: function(result) {
                        if (result)
                            return_json = adiha_post_data('return_json', data, '', '', 'rm_excel.delete_callback');
                    }
                });
            }

            rm_excel.delete_callback = function(result) {
                var return_data = JSON.parse(result);
                if (return_data[0].errorcode == 'Success') {
                    var tab_id = 'tab_' + return_data[0].recommendation;
                    var tab_id_array = rm_excel.rm_excel_tabbar.getAllTabs();
                    var tab_id_array_cnt = (tab_id_array == 0) ? '0' : tab_id_array.length;

                    for (var i=0;i<tab_id_array_cnt;i++) {
                        if (tab_id == tab_id_array[i]) {
                            rm_excel.rm_excel_tabbar.cells(tab_id).close();
                        }    
                    }
                    rm_excel.excel_file_sheet_grid();
                // }
                } else {
                    dhtmlx.message({
                    title:"Alert",
                    type:"alert",
                    text:'Sorry, You can not delete this file.'
                    });
                    return;
                }   
            }

            /*
             * Function that enables the button when row is selected.
             */
            rm_excel.enabled_button = function(id) {
                var level = rm_excel.rm_excel_grid.getLevel(id);
                if (level == 0) {
                    if (has_rights_rm_excel_delete){ 
                        rm_excel.menu.setItemEnabled('delete');
                    }
                    if (has_rights_rm_excel_download){
                        rm_excel.menu.setItemEnabled('download'); 
                    }
                    if (has_rights_rm_excel_privilege){
                        rm_excel.menu.setItemEnabled('privilege');
                    }
                }
                else if (level == 1) { 
                    rm_excel.menu.setItemDisabled('delete');
                    rm_excel.menu.setItemDisabled('download');
                    rm_excel.menu.setItemDisabled('privilege'); 
                }               
            }

            rm_excel.download_file = function(id) {
                var file_name = rm_excel.rm_excel_grid.getSelectedRowId();
                var filepath = "<?php echo $filename_docpath; ?>";
                filepath = filepath + file_name;
                var url = "../../../adiha.php.scripts/force_download.php?path="+filepath+"&name="+file_name;
                rm_excel.rm_excel_grid.toExcel(url);
            }

            var static_data_privilege;
    
            function unload_static_data_privilege_window() {        
                if (static_data_privilege != null && static_data_privilege.unload != null) {
                    static_data_privilege.unload();
                    static_data_privilege = w2 = null;
                }
            }  

            rm_excel.undock_excel_grid = function() {
            // var layout_obj = setup_counterparty.details_layout["details_layout_" + counterparty_id];
            rm_excel.layout.cells("a").undock(300, 300, 900, 700);
            rm_excel.layout.dhxWins.window("a").button("park").hide();
            rm_excel.layout.dhxWins.window("a").maximize();
            rm_excel.layout.dhxWins.window("a").centerOnScreen();
            }      

            rm_excel.on_dock_event = function(name) {
            $('.undock_cell_a').show();
            }
            rm_excel.on_undock_event = function(name) {
                $('.undock_cell_a').hide();
            }

            rm_excel.before_select = function(new_row, old_row) {
                var level = rm_excel.rm_excel_grid.getLevel(new_row);
                if (level == 0) {
                    return true;
                } else {
                    return false;
                }
            }   
        </script>