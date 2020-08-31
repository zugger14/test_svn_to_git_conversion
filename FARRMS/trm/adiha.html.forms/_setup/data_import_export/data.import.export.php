<?php
/**
* Data import export screen
* @copyright Pioneer Solutions
*/
?>
 <!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    </head>
    <body>
        <?php
        require('../../../adiha.php.scripts/components/include.file.v3.php');
        $server_path = $BATCH_FILE_EXPORT_PATH;
        $name_space = 'data_ixp';
        $rights_data_import_export_iu = 10104810;
        $rights_data_import_export_delete = 10104811;
        $rights_data_import_export_run = 10104812;
        $rights_data_import_export_copy = 10104810; // Need to Update
        $rights_data_import_export_privilege = 10104813;
        $rights_data_import_export_reprocess = 10106301;
        $rights_data_import_export_notification = 10104810;
        
        list (
                $has_rights_data_import_export_iu,
                $has_rights_data_import_export_delete,
                $has_rights_data_import_export_run,
                $has_rights_data_import_export_copy,
                $has_rights_data_import_export_privilege,
                $has_rights_data_import_export_reprocess,
				$has_rights_data_import_export_notification
            ) = build_security_rights(
                $rights_data_import_export_iu, 
                $rights_data_import_export_delete, 
                $rights_data_import_export_run, 
                $rights_data_import_export_copy,
                $rights_data_import_export_privilege,
                $rights_data_import_export_reprocess,
				$rights_data_import_export_notification
        );
        

        //JSON for Layout
        $layout_json = '[
                     {id:"a", text:"Data Import\Export", header:false, fix_size:[true,true]}
                    
                    ]';
        $menu_json = '[
                    {id: "edit", text: "Edit", img:"edit.gif", items: [
                        {id:"add_import_rule", img:"new.gif", imgdis:"new_dis.gif", text:"Add", enabled:"'.$has_rights_data_import_export_iu.'"},
                        {id:"copy", text:"Copy", img:"copy.gif", imgdis:"copy_dis.gif", enabled:0},
                        {id:"delete", text:"Delete", img:"remove.gif", imgdis:"remove_dis.gif", enabled:0}
                    ]},
                    {id:"t3", text:"Process", img:"process.gif", items:[
                        {id:"run_rule", text:"Run Rule", img:"rule.gif", imgdis:"rule_dis.gif",  enabled:0},                                         
                        {id:"download_sample", text:"Download Sample File", img:"download.gif", imgdis:"download_dis.gif",  enabled:0}                       
                    ]},
                    {id:"t2", text:"Export", img:"export.gif", items:[
                        {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                        {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                    ]},
                    {id:"privilege", text:"Privilege", img:"privilege.gif", imgdis:"privilege_dis.gif",  enabled:"'.$has_rights_data_import_export_privilege.'"},
                    {id:"view", text:"View", img:"view.gif", items:[
                        {id:"view_all", text:"View All", img:"view_all.gif", imgdis:"view_all_dis.gif", title: "View All"},
                        {id:"view_active", text:"View Active", img:"view_active.gif", imgdis:"view_active_dis.gif", title: "View Active"}
                    ]},
                    {id:"select_unselect", text:"Select/Unselect All", img:"select_unselect.gif", imgdis:"select_unselect_dis.gif", enabled: 1},
                    {id:"import_export", text:"Import/Export Rule", img:"export.gif", items:[
                        {id:"import_rule", text:"Import", img:"import.gif", imgdis:"import_dis.gif" },
                        {id:"import_rule_as", text:"Import As", img:"import.gif", imgdis:"import_dis.gif" },
                        {id:"export_rule", text:"Export", img:"export.gif", imgdis:"export_dis.gif", enabled :0}
					]},
                     {id:"notification", text:"Notification", img:"notification.png", imgdis:"notification_dis.png", enabled:0, items: [
							{id:"notification_onsucess" ,text:"Notification Group", img:"notification_group.png", imgdis:"notification_group_dis.png"},
                            {id:"notification_onerror", text:"Error Notification Group", img:"error_notification_group.png", imgdis:"error_notification_group_dis.png"},
                            {id:"clear_notification", text:"Clear All Notification", img:"remove.gif", imgdis:"remove.gif"}
                    ]}
                 ]';

        //{id:"export_rule_copy_as", text:"Export As", img:"export.gif", imgdis:"export_dis.gif", enabled :0}
        //Creating Layout
        $ixp_layout = new AdihaLayout();
        echo $ixp_layout->init_layout('layout', '', '1C', $layout_json, $name_space);

        //Attach Menu
        echo $ixp_layout->attach_menu_cell('menu', 'a');

        $ixp_menu = new AdihaMenu();
        echo $ixp_menu->init_by_attach('menu', $name_space);
        echo $ixp_menu->load_menu($menu_json);
        echo $ixp_menu->attach_event('', 'onClick', $name_space . '.menu_click');

        //Attach Grid
        echo $ixp_layout->attach_grid_cell('ixp_grid', 'a');
        echo $ixp_layout->attach_status_bar('a', false, '<div id="pagingArea_a"></div>');
        // Create Grid
        $ixp_grid = new GridTable('data_export_import');
        echo $ixp_grid->init_grid_table('ixp_grid', $name_space);
        echo $ixp_grid->enable_paging(25, 'pagingArea_a');
        echo $ixp_grid->set_search_filter(false,'#text_filter,#numeric_filter,#combo_filter,#combo_filter,#combo_filter,#combo_filter,#combo_filter');
        echo $ixp_grid->return_init();
        echo $ixp_grid->load_grid_data();
        echo $ixp_grid->enable_multi_select();
        //echo $ixp_grid->split_grid('1');
        echo $ixp_grid->attach_event('', 'onRowDblClicked', $name_space . '.update_rule');
        echo $ixp_grid->attach_event('', 'onRowSelect', 'enabled_button');

        echo $ixp_layout->close_layout();
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
            var wizard_window;
            var run_window;
            var php_script_loc_ajax = "<?php echo $app_php_script_loc; ?>";
            var has_rights_data_import_export_iu =<?php echo (($has_rights_data_import_export_iu) ? $has_rights_data_import_export_iu : '0'); ?>;
            var has_rights_data_import_export_delete =<?php echo (($has_rights_data_import_export_delete) ? $has_rights_data_import_export_delete : '0'); ?>;
            var has_rights_data_import_export_run =<?php echo (($has_rights_data_import_export_run) ? $has_rights_data_import_export_run : '0'); ?>;
            var has_rights_data_import_export_copy =<?php echo (($has_rights_data_import_export_copy) ? $has_rights_data_import_export_copy : '0'); ?>;
            var has_rights_data_import_export_privilege =<?php echo (($has_rights_data_import_export_privilege) ? $has_rights_data_import_export_privilege : '0'); ?>;
            var has_rights_data_import_export_reprocess=<?php echo (($has_rights_data_import_export_run) ? $has_rights_data_import_export_run : '0'); ?>;
			var has_rights_data_import_export_notification=<?php echo (($rights_data_import_export_notification) ? $rights_data_import_export_notification : '0'); ?>;
            var dhx_wins = new dhtmlXWindows();
            var process_id = '';
            var param_present = '';
                
            $(function() {
                data_ixp.ixp_grid.setColumnMinWidth(300,1);
//                data_ixp.ixp_grid.setColWidth(1,"*"); // code commented to reduce the width of column
                data_ixp.menu.setItemDisabled('privilege');
				data_ixp.menu.setItemDisabled('notification');
            });
            
            data_ixp.menu_click = function(id) {
                switch (id) {
                    case "add_import_rule":
                        data_ixp.open_wizard(-1, '', 'Import');
                        break;
                    case "add_export_rule":
                        data_ixp.open_wizard(-1, '', 'Export');
                        break;
                    case "run_rule":
                        data_ixp.open_run_wizard();
                        break;
                    case "download_sample":
                        data_ixp.download_sample_file();
                        break;
                    case "delete":
                        data_ixp.delete_grid();
                        break;
                    case "copy":
                        data_ixp.copy_rule();
                        break;
                    case "refresh":
                        data_ixp.refresh_grid();
                        break;
                    case "excel":
                        data_ixp.ixp_grid.toExcel(php_script_loc_ajax + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                        break;
                    case "pdf":
                        data_ixp.ixp_grid.toPDF(php_script_loc_ajax + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                        break;
                    case "privilege":
                        data_ixp.set_privilege();
                        break;
                    case "view_all":
                        data_ixp.refresh_all_grid();
                        break;
                    case "view_active":
                        data_ixp.refresh_grid();
                        break;
                    case "select_unselect":
                        data_ixp.select_all_data();
                        break; 
                    case "reprocess":
                        data_ixp.open_import_data_interface();
                        break;      
                    case 'import_rule':
                        if (data_ixp.import_window != null && data_ixp.import_window.unload != null) {
                            data_ixp.import_window.unload();
                            data_ixp.import_window = w2 = null;
                        }
                        if (!data_ixp.import_window) {
                            data_ixp.import_window = new dhtmlXWindows();
                        }

                        data_ixp.new_win = data_ixp.import_window.createWindow('w2', 0, 0, 670, 325);

                        var text = "Import Rules";

                        data_ixp.new_win.setText(text);
                        data_ixp.new_win.setModal(true);

                        var url = app_form_path + '_compliance_management/setup_rule_workflow/manage.alert.workflow.import.export.php';
                        url = url + '?flag=import_rules&call_from=mapping';
                        data_ixp.new_win.attachURL(url, false, true);
                        break;
					case 'notification_onsucess':
						data_ixp.import_notification('Success');
						break;
					case 'notification_onerror':
						data_ixp.import_notification('Error');
						break;
                   case 'clear_notification':
                        data_ixp.clear_all_notification();
                        break;    
                    case 'import_rule_as' :
                        if (data_ixp.import_window != null && data_ixp.import_window.unload != null) {
                            data_ixp.import_window.unload();
                            data_ixp.import_window = w2 = null;
                        }
                        if (!data_ixp.import_window) {
                            data_ixp.import_window = new dhtmlXWindows();
                        }

                        data_ixp.new_win = data_ixp.import_window.createWindow('w2', 0, 0, 650, 325);

                        var text = "Import Rules";

                        data_ixp.new_win.setText(text);
                        data_ixp.new_win.setModal(true);

                        var url = app_form_path + '_compliance_management/setup_rule_workflow/manage.alert.workflow.import.export.php';
                        url = url + '?flag=import_rules&call_from=mapping&copy_field_req=1';
                        data_ixp.new_win.attachURL(url, false, true);
                        break;            
                    case 'export_rule' :
                        var r_id = data_ixp.ixp_grid.getSelectedRowId();
                        var level = data_ixp.ixp_grid.getLevel(r_id);

                        if (!r_id || r_id == '') {
                            dhtmlx.alert({
                                type: "alert",
                                title:'Alert',
                                text:"No Rule selected."
                            });
                            return;
                        }
                        
                        if (level == 0) {                            
                            return; 
                        } else {
                            var row_index = data_ixp.ixp_grid.getRowIndex(r_id);
                            var ixp_rule_ids = data_ixp.ixp_grid.cells2(row_index, 1).getValue();
                            var data = '';
                            data = {"action": "spa_data_import_export_rules",
                                    "flag": "export_rule",
                                    "rule_ids": ixp_rule_ids
                            };
                            adiha_post_data('return_array', data, '', '', 'data_ixp.download_script', '', '');
                          
                        }
                        break; 
                    case 'export_rule_copy_as':
                        open_copy_as_param_popup();
                        break;
                }
            }

            function import_from_file(file_name, copy_as) {                
                var data = {"action": "spa_data_import_export_rules",
                    "flag": "confirm_override",
                    "import_file_name": file_name,
                    "copy_as" : copy_as
                };
               
                adiha_post_data('return_array', data, '', '', 'data_ixp.import_from_confirmation', '', '');                 
            }

           data_ixp.import_from_confirmation = function(return_value) {              
                var confirm_type = return_value[0][0];
                var adiha_type = '';
                var validation = '';
                var file_name = return_value[0][1];
                var copy_as = return_value[0][2];

                if (confirm_type == 'r') {
                    validation = 'Data already exist. Are you sure you want to replace data? ';
                    adiha_type = 'confirm';
                } else {
                    adiha_type = 'return_array';
                }

                
                
                data_ixp.new_win.close();
                data = {"action": "spa_data_import_export_rules",
                        "flag": "import_file_data_mapping",
                        "import_file_name": file_name,
                        "copy_as" : copy_as
                    };
                
                adiha_post_data(adiha_type, data, '', '', 'data_ixp.import_export_call_back', '', validation);                 
            }

            data_ixp.import_export_call_back = function(result) {  
                var is_success = result[0][0];
                var msg_req = 'n';

                if (is_success === undefined) {
                    is_success = result[0].errorcode;
                    message = result[0].message
                } else {
                    message = result[0][4];
                    msg_req = 'y';
                }

                if (is_success == "Success") {
                    if (msg_req == 'y') {
                        dhtmlx.message({
                        text:message,
                        expire:1000
                        });    
                    }
                    
                    data_ixp.refresh_grid();
                } else {
                    dhtmlx.message({
                        title:"Alert",
                        type:"alert",
                        text:message
                    });                    
                }
            }

            open_copy_as_param_popup = function() {
                var r_id = data_ixp.ixp_grid.getSelectedRowId();
                var level = data_ixp.ixp_grid.getLevel(r_id);
                    
                if (!r_id || r_id == '') {
                    dhtmlx.alert({
                        type: "alert",
                        title:'Alert',
                        text:"No Rule selected."
                    });
                    return;
                }
                
                if (level == 0) {                            
                    return; 
                } else {
                    show_copy_as_charges_popup();
                }
            }

            function show_copy_as_charges_popup() {
                var label_width = parseInt(ui_settings['field_size']) + parseInt(ui_settings['offset_left']);
                var copy_as_form_data = [
                    {type: "settings", labelWidth: label_width, inputWidth: ui_settings['field_size'], position: "label-top", offsetLeft: ui_settings['offset_left']},
                    {type: "input", name: "copy_as", label: "Copy As", 'required':true, id: "copy_as"},                     
                    {type: "button", value: "Ok", img: "tick.png"}
                ];

                copy_as_charges_popup = new dhtmlXPopup({ toolbar: data_ixp.menu, id: "export_rule_copy_as" });

                var scheduling_workbench_form = copy_as_charges_popup.attachForm(copy_as_form_data);

                copy_as_charges_popup.attachEvent("onBeforeHide", function(type, ev, id){
                    if (type == 'click' || type == 'esc') {
                        copy_as_charges_popup.hide();
                    }  
                });
                
                var height = 50;
                copy_as_charges_popup.show(600,height+10,45,45);

                scheduling_workbench_form.attachEvent("onButtonClick", function() {
                    var copy_as = scheduling_workbench_form.getItemValue('copy_as');
                    if (!copy_as) {
                        show_messagebox("Copy As field cannot be null.");
                    } else {
                        copy_as_charges_popup.hide();
                        var r_id = data_ixp.ixp_grid.getSelectedRowId();                        
                        var row_index = data_ixp.ixp_grid.getRowIndex(r_id);
                        var ixp_rule_ids = data_ixp.ixp_grid.cells2(row_index, 1).getValue();
                        var data = '';
                        data = {"action": "spa_data_import_export_rules",
                                "flag": "export_rule_copy_as",
                                "rule_ids": ixp_rule_ids,
                                "copy_as" : copy_as
                        };
                        adiha_post_data('return_array', data, '', '', 'data_ixp.download_script', '', '');                      
                    }                
                });
            }

            data_ixp.download_script = function(result) {          
                var selected_id = data_ixp.ixp_grid.getSelectedId();
                var row_index = data_ixp.ixp_grid.getRowIndex(selected_id);
                var export_rule_name = result[0][1]; //data_ixp.ixp_grid.cells2(row_index, 0).getValue();
                var getdate = new Date().toJSON().slice(0, 10).replace(/-/g, '_');
                export_rule_name = export_rule_name + '_' + getdate;
               
                var ua = window.navigator.userAgent;
                var msie = ua.indexOf("MSIE ");
                var blob = null;
                if (msie > 0|| !!navigator.userAgent.match(/Trident.*rv\:11\./)) { // Code to download file for IE
                    if ( window.navigator.msSaveOrOpenBlob && window.Blob ) {
                        blob = new Blob( [result[0][0]], { type: "text/csv;charset=utf-8;" } );
                        navigator.msSaveOrOpenBlob( blob, export_rule_name + "_import.txt" );
                    }
                } else { // Code to download file for other browser
                    blob = new Blob([result[0][0]],{type: "text/csv;charset=utf-8;"});
                    var link = document.createElement("a");
                    if (link.download !== undefined) {
                        var url = URL.createObjectURL(blob);
                        link.setAttribute("href", url);
                        link.setAttribute("download", export_rule_name + "_import.txt");
                        link.style = "visibility:hidden";
                        document.body.appendChild(link);
                        link.click();
                        document.body.removeChild(link);
                    }
                }
            }


            data_ixp.download_sample_file = function() { 
                var r_id = data_ixp.ixp_grid.getSelectedRowId();
                
                var row_index = data_ixp.ixp_grid.getRowIndex(r_id);
                var file_name;
                var file_path;
                var copy_file_path;
                var selected_id = new Array(); 
                selected_id = r_id.split(",");   
                var ixp_rule_name_array = new Array(); 
                final_file_path = js_php_path + 'dev/shared_docs/temp_note/';

                for (count = 0; count < selected_id.length; count++){
                    var row_index = data_ixp.ixp_grid.getRowIndex(selected_id[count]); 
                    var ixp_rule_name = data_ixp.ixp_grid.cells2(row_index, 0).getValue();
                    var is_parent = data_ixp.ixp_grid.getSubItems(selected_id[count]);

                    if (is_parent == '') {
                        file_name = ixp_rule_name;
                        ixp_rule_name_array.push(file_name); 
                    }
                }
                
                if (ixp_rule_name_array.length < 1) {
                    show_messagebox('Please select a rule.')
                    return;
                }

                file_name = ixp_rule_name_array.join(',');
                data = {'action' : 'spa_process_import_sample_file',
                        'source_file_name' : file_name                        
                    };
                data_ixp.layout.cells('a').progressOn();
                result = adiha_post_data('return_data', data, '', '', 'data_ixp.post_download_sample_file');                   
            }

            data_ixp.post_download_sample_file = function(result) { 
                var final_file_path = result[0]['destination'];
                var file_name = result[0]['output_file_name'];
                var status = result[0]['result'];
                var message = result[0]['message'];

                if (status == 'success') {
                    window.location = js_php_path + '/force_download.php?path=' + final_file_path + '&name=' + file_name;    
                } else if (status == 'few_file_missing')  {
                    show_messagebox(message);
                    window.location = js_php_path + '/force_download.php?path=' + final_file_path + '&name=' + file_name;  
                } else {
                    show_messagebox(message);
                }
                
                data_ixp.layout.cells('a').progressOff();
            }
           
            /*
             * Function that enables the button when row is selected.
             */
            enabled_button = function() { 
                var selID = data_ixp.ixp_grid.getSelectedRowId();                  
                var selectedID = new Array(); 
                selectedID = selID.split(",");   

                if (selectedID.length == 1) { 
                    if (has_rights_data_import_export_delete) {
                        data_ixp.menu.setItemEnabled('delete');
                    }
                    if (has_rights_data_import_export_run) {
                        data_ixp.menu.setItemEnabled('run_rule');
                    }
                    if (has_rights_data_import_export_copy) {
                        data_ixp.menu.setItemEnabled('copy');    
                    }
                    if (has_rights_data_import_export_privilege) {
                       data_ixp.menu.setItemEnabled('privilege');    
                    }
                    if (has_rights_data_import_export_notification) {
			           data_ixp.menu.setItemEnabled('notification');  
                    }
                    data_ixp.menu.setItemEnabled('export_rule');  
                    //data_ixp.menu.setItemEnabled('export_rule_copy_as');  
					/*
					All import rules are not re-import compatible so this feature is disable temporarily.
                    if (has_rights_data_import_export_reprocess) {
                       data_ixp.menu.setItemEnabled('reprocess');    
                    }  */
                    data_ixp.menu.setItemEnabled('download_sample');
                    var ixp_id_array = new Array(); 
                    var ixp_is_parent = new Array();
                    for(count = 0; count < selectedID.length; count++){ 
                            var row_index = data_ixp.ixp_grid.getRowIndex(selectedID[count]);  
                            var coll = data_ixp.ixp_grid.getSubItems(selectedID[count]);  
                            var ixp_type = data_ixp.ixp_grid.cells2(row_index, 2).getValue();
                            ixp_is_parent.push(coll);
                            ixp_id_array.push(ixp_type);
                    }  
                    var ixp_type_all = ixp_id_array.join(); 
                    var ixp_par = ixp_is_parent.join(); 

                    //check is selected row is parent 
                    if (ixp_par.length > 0) {
                        data_ixp.menu.setItemDisabled('delete');
                        data_ixp.menu.setItemDisabled('copy');
                        data_ixp.menu.setItemDisabled('run_rule');
                        data_ixp.menu.setItemDisabled('privilege'); 
                        data_ixp.menu.setItemDisabled('export_rule');  
                        //data_ixp.menu.setItemDisabled('export_rule_copy_as');  
                        data_ixp.menu.setItemDisabled('notification');
                    }

                    if (ixp_type_all == 'Import') {
                         if (has_rights_data_import_export_run){
                            data_ixp.menu.setItemEnabled('run_rule');
                         }
                    } else {
                        data_ixp.menu.setItemDisabled('run_rule');
                        if (has_rights_data_import_export_run){
                        }
                    } 
                } else if (selectedID.length > 1){ 
                     data_ixp.menu.setItemDisabled('run_rule');
                }   else if (selectedID.length < 1) { 
                    data_ixp.menu.setItemDisabled('download_sample');   
                    data_ixp.menu.setItemDisabled('export_rule');  
                    //data_ixp.menu.setItemDisabled('export_rule_copy_as'); 
                }
            }
            
            /*
             * Function that refreshes the grid.
             * @returns {undefined}
             */
            data_ixp.refresh_grid = function() { 
                var sql_param = {
                    "action": "spa_ixp_rules",
                    "flag": "s",
                    "grid_type": "tg",
                    "grouping_column": "category,ixp_rules_name"
                };

                sql_param = $.param(sql_param);
                var sql_url = js_data_collector_url + "&" + sql_param;
                data_ixp.ixp_grid.clearAll();
                var delays = 1300; //1 seconds 
                setTimeout(function() { 
                    data_ixp.ixp_grid.loadXML(sql_url, function(){
                        data_ixp.ixp_grid.filterByAll();
                    });
                }, delays);
                                
                data_ixp.menu.setItemDisabled('delete');
                data_ixp.menu.setItemDisabled('run_rule');
                data_ixp.menu.setItemDisabled('copy'); 
                data_ixp.menu.setItemDisabled('privilege'); 
            }

            data_ixp.select_all_data = function() { 
               var menu_object = data_ixp.layout.cells('a').getAttachedMenu();  
               var grid_obj = data_ixp.ixp_grid; 
               var selected_id = grid_obj.getSelectedRowId();  
               if (selected_id == null) {
                    grid_obj.expandAll();
                    data_ixp.menu.setItemDisabled('copy'); 
                    data_ixp.menu.setItemDisabled('delete');
                    data_ixp.menu.setItemEnabled('privilege'); 
                    data_ixp.menu.setItemDisabled('delete'); 
                    var ids = grid_obj.getAllRowIds();                    
                    for (var id in ids) {
                       grid_obj.selectRow(id, true, true, false); 
                    }
                    data_ixp.menu.setItemEnabled('download_sample');
                } else {
                    grid_obj.clearSelection(true);  
                    data_ixp.menu.setItemDisabled('privilege'); 
                    data_ixp.menu.setItemDisabled('copy'); 
                    data_ixp.menu.setItemDisabled('delete'); 
                    data_ixp.menu.setItemDisabled('download_sample');
                }
            }
             data_ixp.open_import_data_interface = function() {     
                    unload_import_data_interface_window();
                        if (!import_data_interface_window) {
                            import_data_interface_window = new dhtmlXWindows();
                        }

                       
            
                        var selected_row = data_ixp.ixp_grid.getSelectedRowId();
                        var row_index = data_ixp.ixp_grid.getRowIndex(selected_row);
                        var rules_id = data_ixp.ixp_grid.cells2(row_index, 1).getValue();
                        data_for_post = { 'action': 'spa_ixp_import_data_interface', 
                                      'flag': 'c',
                                      'import_rule_id': rules_id
                                    };
                      
                        var data = $.param(data_for_post);
                        
                        $.ajax({
                        type: "POST",
                        dataType: "json",
                        url: js_form_process_url,
                        async: true,
                        data: data,
                        success: function(data) {
                            response_data = data["json"];
                            if (response_data[0].data_present == 0) 
                            {
                                 show_messagebox('Selected rule has no data to re-import. ');
                                } else {
                                     var new_win = import_data_interface_window.createWindow('w1', 0, 0, 800, 600);
                                        new_win.setText("Re-Import Data");
                                        new_win.centerOnScreen();
                                        new_win.setModal(true);
                                        new_win.maximize();
                                    var url = app_form_path  + "_setup/import_data_interface/import.data.interface.php?rule_id=" + rules_id;
                                    new_win.attachURL(url, false, true);
                                }
                            }
                            
                    });
                        //var rules_id = data_ixp.ixp_grid.cells(selected_row, data_ixp.ixp_grid.getColIndexById('rules_id')).getValue();
                            
                        
            }
            
    
            /*
             * Function that refreshes the grid and show all active and inactive.
             * @returns {undefined}
             */
            data_ixp.refresh_all_grid = function() {
                var sql_param = {
                    "action": "spa_ixp_rules",
                    "flag": "s",
                    "active_flag":0,
                    "grid_type": "tg",
                    "grouping_column": "category,ixp_rules_name"
                };

                sql_param = $.param(sql_param);
                var sql_url = js_data_collector_url + "&" + sql_param;
                data_ixp.ixp_grid.clearAll();
                var delays = 1300; //1 seconds 
                setTimeout(function() { 
                    data_ixp.ixp_grid.loadXML(sql_url, function(){
                        data_ixp.ixp_grid.filterByAll();
                    });
                }, delays);
                
                
                data_ixp.menu.setItemDisabled('delete');
                data_ixp.menu.setItemDisabled('run_rule');
                data_ixp.menu.setItemDisabled('copy'); 
                data_ixp.menu.setItemDisabled('privilege'); 
            }
            
            /*
             * Edit of the rule.
             * @param {type} r_id Row ID
             * @param {type} col_id Column ID
             * @returns {undefined}
             */
            data_ixp.update_rule = function(r_id, col_id) {
                var is_parent = data_ixp.ixp_grid.hasChildren(r_id); 
                if (is_parent > 0) {
                    var state = data_ixp.ixp_grid.getOpenState(r_id);            
                if (state)
                    data_ixp.ixp_grid.closeItem(r_id);
                else
                    data_ixp.ixp_grid.openItem(r_id); 
                }
                if (!has_rights_data_import_export_iu) {
                    return;
                }

                var row_index = data_ixp.ixp_grid.getRowIndex(r_id);
                var ixp_id = data_ixp.ixp_grid.cells2(row_index, 1).getValue();
                var ixp_name = data_ixp.ixp_grid.cells2(row_index, 0).getValue();
                var ixp_type = data_ixp.ixp_grid.cells2(row_index, 2).getValue();
                //alert(ixp_id);alert(ixp_name);alert(ixp_type);
                var col_system_rule = data_ixp.ixp_grid.getColIndexById("system_rule");
                var system_rule = data_ixp.ixp_grid.cells2(row_index,col_system_rule).getValue();
                var system_rule_status = (system_rule == 'Yes')?1:0;
                if (ixp_type == 'Import') {
                    // Ask for password if rule is system defined
                    if (system_rule == 'Yes') {
                        var param_obj = {
                            "param1"  :  ixp_id,
                            "param2"   :  ixp_name,
                            "param3"      :  ixp_type,
                            "param4" : system_rule_status
                        };
                        is_user_authorized('data_ixp.open_wizard',param_obj);
                    } else
                        data_ixp.open_wizard(ixp_id,ixp_name,ixp_type,system_rule_status);
                }
            }
            /*
             * Opens import/export windows.
             * @param {type} ixp_id ID of the rule id
             * @param {type} ixp_name Name if the rule
             * @param {type} ixp_type Type of rule i.e. either import or export.
             * @returns {undefined}
             */
            data_ixp.open_wizard = function(ixp_id, ixp_name, ixp_type,system_rule_status) {
                unload_window();

                var locked_rule = '';
                if (system_rule_status == 1)
                    locked_rule = ' [Locked]';

                if (!wizard_window) {
                    wizard_window = new dhtmlXWindows();
                }
                var new_win = wizard_window.createWindow('w1', 0, 0, 800, 600);

                var text = (ixp_id == -1) ? "Import Rule New" : ixp_type + " Rule - " + ixp_name + locked_rule;

                new_win.setText(text);
                new_win.maximize();
                new_win.setModal(true);

                var url = (ixp_type.toLowerCase() == 'import') ? 'data.import.wizard.php' : 'data.export.wizard.php';
                url = url + '?ixp_id=' + ixp_id + '&system_rule_status='+system_rule_status;
                new_win.attachURL(url, false, true);
            }
            
            /*
             * Opens the run window.
             * @returns {Boolean}
             */
            data_ixp.open_run_wizard = function() {
                var r_id = data_ixp.ixp_grid.getSelectedRowId();
                var row_index = data_ixp.ixp_grid.getRowIndex(r_id);
                var ixp_id = data_ixp.ixp_grid.cells2(row_index, 1).getValue();
                var ixp_name = data_ixp.ixp_grid.cells2(row_index, 0).getValue();
                var ixp_type = data_ixp.ixp_grid.cells2(row_index, 2).getValue();

                // run SSIS Parameter window directly
                // data = {
                //     "action": "spa_ixp_parameters",
                //     "flag": 'p',
                //     "rules_id": ixp_id
                // }
                // adiha_post_data('return_array', data, "", "", "data_ixp.param_present_callback", "", "");

                //var ixp_data_source = data_ixp.ixp_grid.cells2(row_index, 6).getValue();

                data = {
                        "action": "spa_ixp_init",
                        "flag": 'x'
                    }
                adiha_post_data('return_array',data, "", "", "data_ixp.init_callback", "", "");


                // if(ixp_data_source == 'SSIS' && param_present == 'y'){
                //     data_ixp.open_direct_parameter_window(ixp_id, process_id);
                // } else if (ixp_data_source == 'SSIS' && param_present == 'n') {
                //     data_ixp.run_batch();
                // } else {
                    unload_run_window();
                    if (!data_ixp.run_window) {
                        data_ixp.run_window = new dhtmlXWindows();
                    }
                    
                    data_ixp.new_run_win = data_ixp.run_window.createWindow('w2', 0, 0, 600, 450);

                    var text = "Run Rule - " + ixp_name;

                    data_ixp.new_run_win.setText(text);
                    data_ixp.new_run_win.setModal(true);

                    var url = 'data.relations.php';
                    url = url + '?rules_id=' + ixp_id + '&call_from=run&mode=r';
                    data_ixp.new_run_win.attachURL(url, false, true);
                //}
            }

            // data_ixp.param_present_callback = function(result) {
            //     param_present = result[0][5];
            // }
            
            data_ixp.init_callback = function(result) {
                process_id = result[0][5];
            }
            
            data_ixp.open_direct_parameter_window = function(rules_id, process_id) {
                unload_parameter_window();
                ssis_param = new dhtmlXWindows();
                ssis_param_win = ssis_param.createWindow('w2', 0, 0, 700, 450);
                var text = "SSIS Package Parameters";
                ssis_param_win.setText(text);
                var url = 'data.import.export.parameters.php?rules_id=' + rules_id + '&process_id=' + process_id;
                ssis_param_win.attachURL(url, false, true);
                //parent.close_run_wizard();
            }
            /*
             * Closes the run window.
             * @returns {undefined}
             */
            function close_run_wizard() {
                data_ixp.new_run_win.close();
            }

        var import_data_interface_window;
            /**
             * [unload_window Unload splitting invoice window.]
             */
                    function unload_import_data_interface_window() {        
                        if (import_data_interface_window != null && import_data_interface_window.unload != null) {
                            import_data_interface_window.unload();
                            import_data_interface_window = w1 = null;
                        }
                    }
            /**
            /**
             * [unload_window Window unload function]
             */
            function unload_window() {
                if (wizard_window != null && wizard_window.unload != null) {
                    wizard_window.unload();
                    wizard_window = w1 = null;
                }
            }
            
            /**
             * [unload_window Window unload function]
             */
            function unload_run_window() {
                if (data_ixp.run_window != null && data_ixp.run_window.unload != null) {
                    data_ixp.run_window.unload();
                    data_ixp.run_window = w2 = null;
                }
            }
            
            /*
             * Run batch process
             * @returns {Boolean|undefined}
             */
            data_ixp.run_batch = function(data_source_type, enable_ftp) {
                enable_ftp = enable_ftp || null;
                var selectedID = data_ixp.ixp_grid.getSelectedRowId();
                
                var no_of_selected_rules = selectedID.lastIndexOf(',');
                var row_index = data_ixp.ixp_grid.getRowIndex(selectedID);
                var ixp_id = data_ixp.ixp_grid.cells2(row_index, 1).getValue();
                var ixp_type = data_ixp.ixp_grid.cells2(row_index, 2).getValue();
                var import_export_flag = data_ixp.ixp_grid.cells2(row_index, 2).getValue();

                if (data_source_type == '21407' || data_source_type == '21403') {
                    data = {
                        "action": "spa_ixp_parameters",
                        "flag": "p",
                        "rules_id": ixp_id,
                        "data_source_type": data_source_type
                    };

                    result = adiha_post_data("return_array", data, "", "", "data_ixp.callback_check_parameter", false);
                    
                }
                else
                    data_ixp.open_batch_wizard(data_source_type, enable_ftp);
            }
            
            /*
             * Callback function to check whether the rule has parameters present or not.
             * @param {type} result
             * @returns {undefined}
             */
            data_ixp.callback_check_parameter = function(result) {
                if (result[0][5] == 'y') {
                    data_ixp.open_parameter_window();
                }
                else
                    data_ixp.open_batch_wizard(result[0][6], '0');
            }
            
            /*
             * opens batch screen.
             * @returns {undefined}
             */
            data_ixp.open_batch_wizard = function(data_source_type, enable_ftp, parameters) {
              
                // console.log(data);
                var server_path = <?php echo "'" . addslashes($server_path) . "'"; ?>;
                //var import_export_flag = data_ixp.ixp_filter_form.getItemValue("ixp_type");
                var selectedID = data_ixp.ixp_grid.getSelectedRowId();
                var row_index = data_ixp.ixp_grid.getRowIndex(selectedID);
                var ixp_id = data_ixp.ixp_grid.cells2(row_index, 1).getValue();
                var import_export_flag = data_ixp.ixp_grid.cells2(row_index, 2).getValue();
                if (import_export_flag == 'Export') {
                    flag = 'm';
                }
                else
                    flag = 'r';

                var exec_call = "EXEC spa_ixp_rules " +
                        "@flag = " + singleQuote(flag) +
                        ",@ixp_rules_id = " + singleQuote(ixp_id) +
                        ",@server_path = " + singleQuote(server_path) +
                        ",@source = " + singleQuote(data_source_type) +
                        ",@enable_ftp = " + singleQuote(enable_ftp) +
                        ",@parameter_xml = '" + (parameters ? parameters.replace(/"/g, '\\"') + "'" : "'");

                var param = 'call_from=Import&batch_type=i&ixp_rules_id=' + ixp_id;
                adiha_run_batch_process(exec_call, param, 'Import Batch');
            }

            /*
             * Opens the parameter window.
             * @returns {undefined}             
             */
            data_ixp.open_parameter_window = function() {
                var selectedID = data_ixp.ixp_grid.getSelectedRowId();
                var row_index = data_ixp.ixp_grid.getRowIndex(selectedID);
                var ixp_id = data_ixp.ixp_grid.cells2(row_index, 1).getValue();

                data = {
                        "action": "spa_ixp_init",
                        "flag": 'x'
                    }
                adiha_post_data('return_array',data, "", "", "data_ixp.init_callback", "", "");
                
                unload_parameter_window();
                if (!data_ixp.param_window) {
                    data_ixp.param_window = new dhtmlXWindows();
                }
                data_ixp.new_run_win = data_ixp.param_window.createWindow('w2', 0, 0, 700, 450);
                var text = "SSIS Package Parameters";
                data_ixp.new_run_win.setText(text);
                //data_ixp.new_run_win.maximize();
                data_ixp.new_run_win.setModal(true);
                var url = 'data.import.export.parameters.php?rules_id=' + ixp_id + '&process_id=' + process_id + '&open_from=batch';
                data_ixp.new_run_win.attachURL(url, false, true);

            }
            
            /*
             * Closes the parameter window. This function is called by the opened parameter window.
             * @returns {undefined}
             */
            function close_parameter_window() {
                data_ixp.new_run_win.close();
                data_ixp.open_batch_wizard();

            }
            
            /*
             * Unloads the parameter window. 
             */
            function unload_parameter_window() {
                if (data_ixp.param_window != null && data_ixp.param_window.unload != null) {
                    data_ixp.param_window.unload();
                    data_ixp.param_window = w2 = null;
                }
            }
            
            /*
             * Function to copy the selected rule/
             */
            data_ixp.copy_rule = function() {
                var selID = data_ixp.ixp_grid.getSelectedRowId();                  
                var selectedID = new Array(); 
                selectedID = selID.split(",");   
                var ixp_id_array = new Array(); 
                 for(count = 0; count < selectedID.length; count++){ 
                        var row_index = data_ixp.ixp_grid.getRowIndex(selectedID[count]); 
                        var ixp_id = data_ixp.ixp_grid.cells2(row_index, 1).getValue();
                        ixp_id_array.push(ixp_id);
                 }  
                var ixp_id_all = ixp_id_array.join(); 
                
                data = {    "action": "spa_ixp_rules_export",
                            "flag": "c",
                            "ixp_export_id": ixp_id_all
                        };

                result = adiha_post_data('alert', data, '', '', 'data_ixp.refresh_grid');  
            }

            /*
             * Delete the grid data.
             * @returns {Boolean}
             */
            data_ixp.delete_grid = function() {
                var selID = data_ixp.ixp_grid.getSelectedRowId();                  
                var selectedID = new Array(); 
                selectedID = selID.split(",");   
                var ixp_id_array = new Array(); 
                var has_system_rule = false;
                var col_system_rule = data_ixp.ixp_grid.getColIndexById("system_rule");
                 for(count = 0; count < selectedID.length; count++){
                        var row_index = data_ixp.ixp_grid.getRowIndex(selectedID[count]); 
                        var ixp_id = data_ixp.ixp_grid.cells2(row_index, 1).getValue();
                        var system_rule = data_ixp.ixp_grid.cells2(row_index,col_system_rule).getValue();
                        ixp_id_array.push(ixp_id);
                        if (system_rule == 'Yes')
                            has_system_rule = true;
                 }
                var ixp_id_all = ixp_id_array.join();
                 /* Password required to delete system defined rule*/
                if (has_system_rule) {
                    var param_obj = {
                        "param1"  :  ixp_id_all
                    };
                    is_user_authorized('data_ixp.post_validation_grid_delete',param_obj);
                } else {
                    var delete_sp_string = "EXEC spa_ixp_rules @flag='d', @ixp_rules_id='" + ixp_id_all + "'";
                    var data = {"sp_string": delete_sp_string};

                    adiha_post_data('confirm', data, '', '', 'data_ixp.refresh_grid');
                }
            }

            data_ixp.post_validation_grid_delete = function(id) {
                var delete_sp_string = "EXEC spa_ixp_rules @flag='d', @ixp_rules_id='" + id + "'";
                var data = {"sp_string": delete_sp_string};

                adiha_post_data('confirm', data, '', '', 'data_ixp.refresh_grid');
            }
            
            /*
             * Function to set privilege for the selected row.
             */
            data_ixp.set_privilege = function() { 
                var selID = data_ixp.ixp_grid.getSelectedRowId();    
                //console.log(selID);              
                var selectedID = new Array(); 
                selectedID = selID.split(",");   
                var ixp_id_array = new Array();   
                for(count = 0; count < selectedID.length; count++){  
                    var ixp_id = data_ixp.ixp_grid.cells(selectedID[count], 1).getValue();  
                    ixp_id_array.push(ixp_id);
                }    
                var newArray = [];
                for (var i = 0; i < ixp_id_array.length; i++) {
                  if (ixp_id_array[i] !== undefined && ixp_id_array[i] !== null && ixp_id_array[i] !== "") {
                    newArray.push(ixp_id_array[i]);
                  }
                 } 
                var ixp_id_all = newArray.join();  


                import_export_privilege = dhx_wins.createWindow({
                id: 'import_export_privilege'
                ,width: 1100
                ,height: 600
                ,modal: true
                ,resize: true
                ,text: 'Data Import Privilege'
                ,center: true
            
                });
                var post_params = {
                    call_from: 'data_import_export_privilege',
                    object_id: ixp_id_all
                };
                var privilege_url = app_form_path + '_setup/data_import_export/data.import.export.privilege.window.php';
                import_export_privilege.attachURL(privilege_url, null, post_params);
                    
            }
            
            set_privilege_callback = function(result) {   
                var users = result[0][0];
                if (users != null)
                    users = users.substring(0,users.length-1);
                var roles = result[0][1];
                if (roles != null)
                    roles = roles.substring(0,roles.length-1);
                open_privilege('set_ixp_privilege', users, roles);
            }
            
            /*
             * Callback function to save privilege.
             */
            function set_ixp_privilege(role_id, user_id) {  
                var selID = data_ixp.ixp_grid.getSelectedRowId();                  
                var selectedID = new Array(); 
                selectedID = selID.split(","); 
                var ixp_id_array = new Array(); 
                 for(count = 0; count < selectedID.length; count++){ 
                        var row_index = data_ixp.ixp_grid.getRowIndex(selectedID[count]); 
                        var ixp_id = data_ixp.ixp_grid.cells2(row_index, 1).getValue();
                        ixp_id_array.push(ixp_id);
                 }  
                var ixp_id_all = ixp_id_array.join(); 
                
                data = {    "action": "spa_ipx_privileges",
                            "flag": "i",
                            "user_id": user_id,
                            "role_id": role_id,
                            "import_export_id": ixp_id_all
                        };

                adiha_post_data('alert', data, '', '', '');
            }

             /*
             * Funciton to close the run popup
             * @returns {undefined}             */
            function  close_run_window(){
                setTimeout("data_ixp.new_run_win.close()",1000);
            }
            
			data_ixp.import_notification = function(notifiction_on) {
				var error_success = 0;
				var r_id = data_ixp.ixp_grid.getSelectedRowId();
                var source_id = data_ixp.ixp_grid.cells(r_id, 1).getValue();
				var row_index = data_ixp.ixp_grid.getRowIndex(r_id); 
				var ixp_name = data_ixp.ixp_grid.cells2(row_index, 0).getValue();							
							
				if (notifiction_on == 'Success'){
					error_success = 1;
				}

				var attach_url = '../../_compliance_management/setup_rule_workflow/workflow.rule.message.php'
										+ '?call_from=import_notification' 
										+ '&module_id=20634'
										+ '&source_id=' + source_id
										+ '&error_success=' + error_success
				var message_window = new dhtmlXWindows();
				win = message_window.createWindow('w1', 0, 0, 890, 500);
				win.setText("Import Notification on " + ixp_name);
				win.centerOnScreen();
				win.setModal(true);
				win.attachURL(attach_url);
				win.attachEvent('onClose', function(w){
					return true;
				});
			}
            
            data_ixp.clear_all_notification = function(notifiction_on) {
                var r_id = data_ixp.ixp_grid.getSelectedRowId();
                var source_id = data_ixp.ixp_grid.cells(r_id, 1).getValue();
                data = {    "action": "spa_ixp_import_data_source",
                            "flag": "d",
                            "rules_id": source_id                            
                        };

                adiha_post_data('confirm', data, '', '', '');
            }
            
        </script>