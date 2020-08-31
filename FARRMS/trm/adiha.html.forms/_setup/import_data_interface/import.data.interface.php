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
        $rule_id = (isset($_REQUEST["rule_id"]) && $_REQUEST["rule_id"] != '') ? get_sanitized_value($_REQUEST["rule_id"]) : '';
        $form_namespace = 'ice_interface';
        $function_id = 20001100;
        

        $form_obj = new AdihaStandardForm($form_namespace, $function_id);
        $form_obj->define_grid('import_data_interface', '', 'g');
        $form_obj->define_layout_width(300);
        $form_obj->define_custom_functions('', 'load_ice_interface', '');
        //$form_obj->define_apply_filters(true,'','','');
        $form_obj->show_apply_filter(false);
        
          if ($rule_id != '') {
            $rule_id_sql = "EXEC spa_ixp_import_data_interface @flag = 'g',@import_rule_id='".$rule_id."'";

            $rules_data = readXMLURL2($rule_id_sql);
            $ice_interface_data_id = $rules_data[0]['ice_interface_data_id'];
            $data_type = $rules_data[0]['data_type'];
            $description = $rules_data[0]['description'];
            $import_rule_id = $rules_data[0]['import_rule_id'];
            $column_name = $rules_data[0]['column_name'];
            $display_config = $rules_data[0]['display_config'];
            $max_date =$rules_data[0]['max_date'];
            $min_date =$rules_data[0]['min_date'];
            
        }

        
        $menu_json_array =  array(
                                array(
                                    'json' => ' {id: "Word3", img: "Word3.gif", text: "Word3", title: "Word3"},
                                                {id: "Word4", img: "Word4.gif", text: "Word4", title: "Word4"}',
                                    'on_click' => 'ice_interface.second_grid_menu_click'
                                )
                            );
        $form_obj->set_grid_menu_json($menu_json_array, false);
        $form_obj->define_custom_setting(true);
        echo $form_obj->init_form('Interface', 'Details',$rule_id);
        echo $form_obj->close_form();
        
        ?>
    </body>
        
    <script type="text/javascript">
        var client_date_format = '<?php echo $date_format; ?>';
        var php_script_loc = '<?php echo $app_php_script_loc; ?>';
        var theme_selected = 'dhtmlx_' + default_theme;
        
        var ice_interface_data_id = '<?php echo $ice_interface_data_id; ?>';
        var expand_state = 0;
        var default_selected_row = '';
       
        $(function(){
            
            
            // refresh_ice_interface_grid();
            
            ice_interface.menu.hideItem('t1');
            ice_interface.menu.hideItem('t2');
           // ice_interface.menu.addNewSibling('t2', 'action', 'Action', false, 'action.gif', 'action_dis.gif');
           // ice_interface.menu.addNewChild('action', 1, 'request', 'Send Request', false, 'export.gif', 'export_dis.gif');
           // ice_interface.menu.addNewChild('action', 2, 'import_rule', 'Import Rule', false, 'rule.gif', 'rule_dis.gif');
            //ice_interface.menu.addNewSibling('action', 'config', 'Config', true, 'audit.gif', 'audit_dis.gif');
            ice_interface.menu.addNewSibling('t2','expand_collapse', 'Expand/Collapse', false, 'exp_col.gif', 'exp_col_dis.gif');
            ice_interface.menu.attachEvent("onClick", function(id, zoneId, cas){
                
                if (id == 'request') {
                    //show_run_popup();
                   ice_interface_send_request();
                } else if (id == 'import_rule') {
                    ice_interface_import_rule();
                } else if (id == 'config') {
                    ice_interface_config();
                } else if(id=='expand_collapse'){                    
                    if (expand_state == 0) 
                        openAllInvoices();
                    else
                        closeAllInvoices();
                    
                }
            });
            if(ice_interface_data_id !== null && ice_interface_data_id !== '')
            {
                ice_interface.layout.cells('a').collapse();
            }
            
            ice_interface.layout.cells('a').setText("Import Rule List");
            ice_interface.layout.cells('a').setHeight(90);
            ice_interface.grid.attachEvent("onRowSelect", function(row_id){
                var display = ice_interface.grid.cells(row_id, ice_interface.grid.getColIndexById('display_config')).getValue();
                
                    // if(display=='false')
                    //     ice_interface.menu.setItemDisabled('config');
                    // else
                    //     ice_interface.menu.setItemEnabled('config');
            });
            
            
            
        //    load_connection_form();
        });
         /* 
        
       
         * [Load the form to connect and disconnect]
         */
     /*   load_connection_form = function() {
            var connection_form_json =  [
                {type: "settings", position: "label-right", inputWidth: ui_settings['field_size'], offsetLeft: ui_settings['offset_left']},
                {type: "block", blockOffset: 0, list: [
                    {type: "button", name:"connection", value: "Connection", tooltip: "Connect", className: "filter_publish",offsetTop:"28"},
                    {type: "newcolumn"},
                    {type: "label", name: "connect_status", label:"<span style='color:red'>Disconnected<span>", offsetTop:"23"},
                    {type: "newcolumn"},
                    {type: "input", name: "status", value:"0", offsetTop:"23", hidden:true}
                 ]}
            ];
            connection_form = ice_interface.layout.cells('a').attachForm();
            connection_form.load(connection_form_json);
            
            connection_form.attachEvent("onButtonClick", function(name){
                if(name == "connection") {
                    var status = connection_form.getItemValue('status');
                    if (status == '0') {
                        connection_form.setItemLabel("connect_status", "<span style='color:blue'>Connecting....<span>");
                    } else {
                        connection_form.setItemLabel("connect_status", "<span style='color:blue'>Disconnecting....<span>");
                    }
                    ice_interface_connection();
                }
            });
        }
        
        
        /*
         * [Function to connect/disconnect the connection]
         */
        ice_interface_connection = function() {
            
            /*
            TODO: Connection Logic
            */
            
            setTimeout(function(){ 
                ice_interface_connection_callback(); 
            }, 1000);
            
        }
        
        
        /*
         * [Callback function of ice_interface_connection]
         
        ice_interface_connection_callback = function() {
            var status = connection_form.getItemValue('status');
            if (status == 0) {
                connection_form.setItemLabel("connect_status", "<span style='color:green'>Connected<span>");
                connection_form.setItemValue("status", "1");
            } else {
                connection_form.setItemLabel("connect_status", "<span style='color:red'>Disconnected<span>");
                connection_form.setItemValue("status", "0");
            }
        }
    
            */
        /*
         * [Function triggered when send request to interface]
         */
         function show_run_popup() {
    
        }
        ice_interface_send_request = function() {
            
             var selected_row = ice_interface.grid.getSelectedRowId();
            
            if (selected_row == null) {
                show_messagebox('Please select an ICE Interface data type.');
                return;
            }
            
            var ice_interface_data_id = ice_interface.grid.cells(selected_row, ice_interface.grid.getColIndexById("id")).getValue();
            var import_id = ice_interface.grid.cells(selected_row, ice_interface.grid.getColIndexById("import_rule_id")).getValue();
            var as_of_date = null;
            var xml = null;
            var import_rule_id= null;
            var date_from= null;
            var date_to = null;
            var security_def_id  = null;
            var import_data_list = null;
            
            if(ice_interface_data_id ==2){
                  var import_rule_json = [
                                        {type: "settings", labelWidth: ui_settings['field_size'], inputWidth: ui_settings['field_size'], position: "label-top", offsetLeft: ui_settings['offset_left']},
                                        {type: "combo", name: "market_type", label: "Security Market type", "options":[{value:"t", text: "Delivery", selected: "true"}, {value: "s", text: "Settlement"}]},
                                        {type: "button", value: "Ok", img: "tick.png"}
                                    ];
                import_rule_popup = new dhtmlXPopup();
                var import_rule_form1 = import_rule_popup.attachForm(import_rule_json);
                var cm_param = {
                "action"                : "('EXEC spa_ICE_interface ''t''')",
                "has_blank_option"      : "false"
                };

                cm_param = $.param(cm_param);
                var url = js_dropdown_connector_url + '&' + cm_param;
                var cmb_import_obj = import_rule_form1.getCombo('market_type');
                cmb_import_obj.clearAll();
                cmb_import_obj.setComboText('');
                cmb_import_obj.load(url, function(){
                    
                import_rule_popup.show(100,120,45,45);
                });
                 import_rule_form1.attachEvent("onButtonClick", function(){
                     security_def_id = import_rule_form1.getItemValue('market_type');
                    var exec_call = "EXEC spa_ixp_import_data_interface " 
                            + "'i'"
                            + "," + singleQuote(ice_interface_data_id)
                            + "," + singleQuote(as_of_date)
                            + "," + singleQuote(xml)
                            + "," + singleQuote(import_id)
                            + "," + singleQuote(date_from)
                            + "," + singleQuote(date_to)
                            + "," + singleQuote(security_def_id)
                            + "," + singleQuote(import_data_list);
                    var param = 'call_from=Ice_interface&batch_type=c&gen_as_of_date=1'; 
                 //adiha_post_data('alert', data, '', '', 'ice_interface_import_rule_callback', '', '');
                 adiha_run_batch_process(exec_call, param, 'Reimport data from staging table.');
                    
                });
                return;
            }
            else {
           /*    var data = {
                                "action": "spa_ICE_interface",
                                "flag": "i",
                                "import_type": ice_interface_data_id,
                                "import_rule_id":import_id
                              }*/
                var exec_call = "EXEC spa_ixp_import_data_interface " 
                            + "'i'"
                            + "," + singleQuote(ice_interface_data_id)
                            + "," + singleQuote(as_of_date)
                            + "," + singleQuote(xml)
                            + "," + singleQuote(import_id)
                            + "," + singleQuote(date_from)
                            + "," + singleQuote(date_to)
                            + "," + singleQuote(security_def_id)
                            + "," + singleQuote(import_data_list);
                            
                var param = 'call_from=Ice_interface&gen_as_of_date=1&batch_type=c'; 
             //adiha_post_data('alert', data, '', '', 'ice_interface_import_rule_callback', '', '');
             adiha_run_batch_process(exec_call, param, 'Reimport data from staging table.');
             }
          //  alert('Send Request in progress...');
        }
        
        
        
        /*
         * [Function to select the import rule]
         */
        ice_interface_import_rule = function() {
            var selected_row = ice_interface.grid.getSelectedRowId();
            
            if (selected_row == null) {
                show_messagebox('Please select an ICE Interface data type.');
                return;
            }
            var ice_interface_data_id = ice_interface.grid.cells(selected_row, ice_interface.grid.getColIndexById("id")).getValue();
            var import_rule_id = ice_interface.grid.cells(selected_row, ice_interface.grid.getColIndexById("import_rule_id")).getValue();
            
            var import_rule_json = [
                                    {type: "settings", labelWidth: ui_settings['field_size'], inputWidth: ui_settings['field_size'], position: "label-top", offsetLeft: ui_settings['offset_left']},
                                    {type: "combo", name: "import_rule", label: "Import Rule", "options":[{value:"t", text: "Delivery", selected: "true"}, {value: "s", text: "Settlement"}]},
                                    {type: "button", value: "Ok", img: "tick.png"}
                                ];
            import_rule_popup = new dhtmlXPopup();
            var import_rule_form = import_rule_popup.attachForm(import_rule_json);
            
            
            var cm_param = {
                "action"                : "('SELECT ixp_rules_id, ixp_rules_name FROM ixp_rules')",
                "has_blank_option"      : "true"
            };

            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;
            var cmb_import_obj = import_rule_form.getCombo('import_rule');
            cmb_import_obj.clearAll();
            cmb_import_obj.setComboText('');
            cmb_import_obj.load(url, function(){
                cmb_import_obj.setComboValue(import_rule_id);
                import_rule_popup.show(100,120,45,45);
            });
            
            import_rule_form.attachEvent("onButtonClick", function(){
                var import_rule_id = import_rule_form.getItemValue('import_rule');
                
                var data = {
                                "action": "spa_ixp_import_data_interface",
                                "flag": "r",
                                "import_rule_id":import_rule_id
                              }

                adiha_post_data('alert', data, '', '', 'ice_interface_import_rule_callback', '', '');
            });
        }
        
        
        /*
         * [Callback Function of ice_interface_import_rule]
         */
        ice_interface_import_rule_callback = function(result) {
            refresh_ice_interface_grid();
            import_rule_popup.hide();
        }
        
        
        /*
         * [Function to open the ICE interface config]
         */
        ice_interface_config = function() {
            var js_path_trm = '<?php echo $app_adiha_loc; ?>';
            config_window = new dhtmlXWindows();
            
            var src = js_path_trm + 'adiha.html.forms/_setup/import_data_interface/ice.interface.config.php'; 
            config_win_obj = config_window.createWindow('w1', 0, 0, 550, 400);
            config_win_obj.setText("ICE Interface Config");

            config_win_obj.centerOnScreen();
            config_win_obj.setModal(true);
            config_win_obj.attachURL(src, false, true);
        }
        
        
        /*
         * [Refresh the main left side grid]
         */
        refresh_ice_interface_grid = function() {
        
            var grid_param = {
                "flag": "g",
                "action": "spa_ixp_import_data_interface",
                "grid_type": "t",
                "grouping_column": "category,date_type"
            };

            grid_param = $.param(grid_param);
            var data_url = js_data_collector_url + "&" + grid_param;
            ice_interface.grid.clearAll();
            ice_interface.grid.load(data_url, function() {
                ice_interface.grid.forEachRow(function(rid) {
                    var value = ice_interface.grid.cells(rid,1).getValue();
                    
                    if(value == ice_interface_data_id) {
                        default_selected_row = rid;
                        ice_interface.create_tab(rid,0,0,0,null);
                        ice_interface.layout.cells('a').collapse();
                    }
                    
                });
                
            });
        }
        
        
        /**************** DETAIL TAB FUNCTION STARTS *******************************/
        
        
        /*
         * [Tab Load Funtion]
         */
        ice_interface.load_ice_interface = function(win, tab_id, grid_obj) {
            win.progressOff();
            var active_object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
            
            ice_interface["details_layout_" + active_object_id] = win.attachLayout({
                pattern: "2E",
                cells: [
                    {id: "a", text: "Filter",header:false,height:90},
                    {id: "b", text: "Details"}
                ]
            });
            
            ice_interface.load_filter();
            ice_interface.load_detail_tabbar();
            
        }
        
        
        /*
         * [Load the filter form]
         */
        ice_interface.load_filter = function(){
            active_object_id = get_active_object_id();
              //  var new_date = new Date();
                //var date = new Date(new_date.getFullYear(), new_date.getMonth() , new_date.getDate());
                if (default_selected_row == '') {
                    var  selected_row = ice_interface.grid.getSelectedRowId();
                } else {
                    var  selected_row = default_selected_row;
                }
                
            var filter_form_json = [
                                    {type: "settings", labelWidth: ui_settings['field_size'], inputWidth: ui_settings['field_size'], position: "label-top", offsetLeft: ui_settings['offset_left']},
                                    {type: "calendar", name: "date_from", label: "Date From", "dateFormat": client_date_format,"serverDateFormat":"%Y-%m-%d", required: true,"validate":"NotEmptywithSpace"},
                                    {type: "newcolumn"},
                                    {type: "calendar", name: "date_to", label: "Date To", "dateFormat": client_date_format,"serverDateFormat":"%Y-%m-%d", required: true,"validate":"NotEmptywithSpace"},
                                    {type: "newcolumn"}
                                    //,
                                    //{type: "checkbox", name: "imported", label: "Imported", position: "label-right",offsetTop:25,"visibility":false}
                                ];
            ice_interface["filter_form_" + active_object_id] = ice_interface["details_layout_" + active_object_id].cells('a').attachForm();
          
            ice_interface["filter_form_" + active_object_id].load(filter_form_json);
           // ice_interface["filter_form_" + active_object_id].setItemValue('date_from', date);
            //ice_interface["filter_form_" + active_object_id].setItemValue('date_to', date);
                ice_interface["filter_form_" + active_object_id].setItemValue('date_from', ice_interface.grid.cells(selected_row, ice_interface.grid.getColIndexById("min_date")).getValue());
                ice_interface["filter_form_" + active_object_id].setItemValue('date_to', ice_interface.grid.cells(selected_row, ice_interface.grid.getColIndexById("max_date")).getValue());
                
          //  ice_interface["filter_form_" + active_object_id].setItemValue('imported', false);
        
        }
        
        
        /*
         * [Load the tabbar in detail tab]
         */
        ice_interface.load_detail_tabbar = function() {
            active_object_id = get_active_object_id();
            
            ice_interface["details_tabbar_" + active_object_id] = ice_interface["details_layout_" + active_object_id].cells('b').attachTabbar({
                mode: "bottom",
                tabs: [
                 {id: "a1", text: "Status"},
                    {id: "a2", text: "Data", active: true}
                    ,
                    {id: "a3", text: "Error"}
                ]
            });
            
            //ice_interface.load_status();
            ice_interface.load_process();
            ice_interface.load_error();
            ice_interface.load_menu();
            
            ice_interface["details_tabbar_" + active_object_id].tabs('a1').hide();
             ice_interface["details_tabbar_" + active_object_id].tabs('a3').hide();
        }
        
        
        /*
         * [Load the status grid in detail tab]
         */
        ice_interface.load_status = function(){
            active_object_id = get_active_object_id();
            
            active_object_id = get_active_object_id();
          
            ice_interface["details_tabbar_" + active_object_id].tabs('a1').attachStatusBar({
                                height: 30,
                                text: '<div id="pagingArea_a"></div>'
                            });
            
            ice_interface["status_grid_" + active_object_id] = ice_interface["details_tabbar_" + active_object_id].tabs('a1').attachGrid();
            ice_interface["status_grid_" + active_object_id].setImagePath(php_script_loc + 'components/lib/adiha_dhtmlx/themes/' + theme_selected + '/imgs/dhxgrid_web/');
            ice_interface["status_grid_" + active_object_id].setHeader('Status ID, Status, Date');
            ice_interface["status_grid_" + active_object_id].attachHeader('#text_filter,#text_filter,#text_filter');
            ice_interface["status_grid_" + active_object_id].setColumnIds('status_id,status,date');
            ice_interface["status_grid_" + active_object_id].setColTypes('ro,ro,ro');
            ice_interface["status_grid_" + active_object_id].setColSorting('str,str,str');
            ice_interface["status_grid_" + active_object_id].setColumnsVisibility('true,false,false');
            ice_interface["status_grid_" + active_object_id].setInitWidths('150,400,150');
            
            ice_interface["status_grid_" + active_object_id].enableMultiselect(true);
            ice_interface["status_grid_" + active_object_id].setPagingWTMode(true,true,true,[5,10,20,30,40,50,60,70,80,90,100]);
            ice_interface["status_grid_" + active_object_id].enablePaging(true,100, 0, 'pagingArea_a'); 
            ice_interface["status_grid_" + active_object_id].setPagingSkin('toolbar'); 
            ice_interface["status_grid_" + active_object_id].init();
        }
        
        
        /*
         * [Load the process grid in detail tab]
         */
        ice_interface.load_process= function(){
                active_object_id = get_active_object_id();
                if (default_selected_row == '') {
                    var  selected_row = ice_interface.grid.getSelectedRowId();
                } else {
                    var  selected_row = default_selected_row;
                }
            
                 var   column_list = column_list + ice_interface.grid.cells(selected_row, ice_interface.grid.getColIndexById("column_list")).getValue();
                 var header = column_list.replace(/_/g,' ');

                 var column_ids = column_list;
                 var col_list_arr = column_list.split(',');
                 
                 var column_filter ='';
                 var column_types='',column_string='',column_visibility='true',column_width='';
                 for (cnt = 0; cnt < col_list_arr.length; cnt++)
                 {
                     if(column_filter!='')
                    {
                        column_filter=column_filter+',';
                    }
                        if(column_types!='')
                    {
                        column_types=column_types+',';
                    }
                        if(column_string!='')
                    {
                        column_string=column_string+',';
                    }
                        
                        column_visibility=column_visibility+',';
                    
                        if(column_width!='')
                    {
                        column_width=column_width+',';
                    }
                    column_filter=column_filter+'#text_filter';
                    column_types=column_types+'ro';
                    column_string=column_string+'str';
                    column_visibility=column_visibility+'false';
                    column_width=column_width+'150';
                 }
            
            
            ice_interface["details_tabbar_" + active_object_id].tabs('a2').attachStatusBar({
                                height: 30,
                                text: '<div id="pagingArea_b"></div>'
                            });
            
            ice_interface["process_grid_" + active_object_id] = ice_interface["details_tabbar_" + active_object_id].tabs('a2').attachGrid();
            ice_interface["process_grid_" + active_object_id].setImagePath(php_script_loc + 'components/lib/adiha_dhtmlx/themes/' + theme_selected + '/imgs/dhxgrid_web/');
            ice_interface["process_grid_" + active_object_id].setHeader(header);
            ice_interface["process_grid_" + active_object_id].attachHeader(column_filter);
            ice_interface["process_grid_" + active_object_id].setColumnIds(column_ids);
            ice_interface["process_grid_" + active_object_id].setColTypes(column_types);
            ice_interface["process_grid_" + active_object_id].setColSorting(column_string);
            ice_interface["process_grid_" + active_object_id].setColumnsVisibility(column_visibility);
            ice_interface["process_grid_" + active_object_id].setInitWidths(column_width);
            
            ice_interface["process_grid_" + active_object_id].enableMultiselect(true);
            ice_interface["process_grid_" + active_object_id].setPagingWTMode(true,true,true,[5,10,20,30,40,50,60,70,80,90,100]);
            ice_interface["process_grid_" + active_object_id].enablePaging(true,100, 0, 'pagingArea_b'); 
            ice_interface["process_grid_" + active_object_id].setPagingSkin('toolbar'); 
            
            ice_interface["process_grid_" + active_object_id].attachEvent("onRowSelect",enable_menu);
            ice_interface["process_grid_" + active_object_id].init();
        }
        
             enable_menu = function(){
              var active_object_id = get_active_object_id();
              
              ice_interface["details_menu_" + active_object_id].setItemEnabled('refresh');
              ice_interface["details_menu_" + active_object_id].setItemEnabled('edit');
              ice_interface["details_menu_" + active_object_id].setItemEnabled('delete');
              ice_interface["details_menu_" + active_object_id].setItemEnabled('import');
         }
         disable_menu = function(){
              var active_object_id = get_active_object_id();
              ice_interface["details_menu_" + active_object_id].setItemDisabled('edit');
              ice_interface["details_menu_" + active_object_id].setItemDisabled('import');
         }
        
        /*
         * [Load the error grid in detail tab]
         */
        ice_interface.load_error = function(){
            active_object_id = get_active_object_id();
            
            ice_interface["details_tabbar_" + active_object_id].tabs('a3').attachStatusBar({
                                height: 30,
                                text: '<div id="pagingArea_c"></div>'
                            });
            
            ice_interface["error_grid_" + active_object_id] = ice_interface["details_tabbar_" + active_object_id].tabs('a3').attachGrid();
            ice_interface["error_grid_" + active_object_id].setImagePath(php_script_loc + 'components/lib/adiha_dhtmlx/themes/' + theme_selected + '/imgs/dhxgrid_web/');
            ice_interface["error_grid_" + active_object_id].setHeader('Status ID, Description, Recommendation, Error Date');
            ice_interface["error_grid_" + active_object_id].attachHeader('#text_filter,#text_filter,#text_filter,#text_filter');
            ice_interface["error_grid_" + active_object_id].setColumnIds('status_id,description,recommendation,error_date');
            ice_interface["error_grid_" + active_object_id].setColTypes('ro,ro,ro,ro');
            ice_interface["error_grid_" + active_object_id].setColSorting('str,str,str,str');
            ice_interface["error_grid_" + active_object_id].setColumnsVisibility('true,false,false,false');
            ice_interface["error_grid_" + active_object_id].setInitWidths('150,300,300,150');
            
            ice_interface["error_grid_" + active_object_id].enableMultiselect(true);
            ice_interface["error_grid_" + active_object_id].setPagingWTMode(true,true,true,[5,10,20,30,40,50,60,70,80,90,100]);
            ice_interface["error_grid_" + active_object_id].enablePaging(true,100, 0, 'pagingArea_c'); 
            ice_interface["error_grid_" + active_object_id].setPagingSkin('toolbar'); 
            ice_interface["error_grid_" + active_object_id].init();
        }
        
        
        /*
         * [Load the menu in detail tab]
         */
        ice_interface.load_menu = function() {
            active_object_id = get_active_object_id();
            
            ice_interface["details_menu_" + active_object_id] = ice_interface["details_layout_" + active_object_id].cells('b').attachMenu({
                icons_path: js_image_path + "dhxmenu_web/",
                items: [
                    {id: "refresh", text: "Refresh", img: "refresh.gif", img_disabled: "refresh_dis.gif"},
                    {id:"edit", img:"edit.gif",img_disabled: "edit_dis.gif", text:"Edit", disabled:true, items:[
            {id:"delete", img:"delete.gif", img_disabled:"delete_dis.gif", text:"Delete", title:"Delete"}
                    ]},
                    {id: "import", text: "Re-Import", img: "re-import.gif", img_disabled: "re-import_dis.gif", disabled:true},
                    {id:"export", img:"export.gif",img_disabled: "export_dis.gif", text:"Export", items:[
            {id:"excel", img:"excel.gif", img_disabled:"excel_dis.gif", text:"Excel", title:"Excel"},
            {id:"pdf", img:"pdf.gif", img_disabled:"pdf_dis.gif", text:"PDF", title:"PDF"}
                ]}
                ]
            });
            
            ice_interface["details_menu_" + active_object_id].attachEvent("onClick", function(id, zoneId, cas){
                if (id == 'refresh') {
                    disable_menu();
                    ice_interface_detail_refresh();
                } else if (id == 'import') {
                    ice_interface_import();
                } else if (id == 'delete'){
                    delete_deal_information();
                } else if (id == 'excel'){
                    fx_export_to_excel();
                }else if (id == 'pdf'){
                    fx_export_to_pdf();
                }
                
            });
        }
        fx_export_to_pdf = function() {
            active_object_id = get_active_object_id();
            ice_interface["process_grid_" + active_object_id].toPDF(php_script_loc +'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
        }
        fx_export_to_excel = function() {
            active_object_id = get_active_object_id();
            ice_interface["process_grid_" + active_object_id].toExcel(php_script_loc +'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
        }
        
        delete_deal_information = function(){
            active_object_id = get_active_object_id();
            var selected_row = ice_interface["process_grid_" + active_object_id].getSelectedId();
            if(selected_row ===null){
                    dhtmlx.message({
                            title:'Error',
                            type:"alert-error",
                            text:"Please Select delete list from grid."
                });
                return;
            }
            var selected_row_arr = selected_row.split(',');
            
                        var id_arr = new Array();
                  for (cnt = 0; cnt < selected_row_arr.length; cnt++) {
                      var a = ice_interface["process_grid_" + active_object_id].cells(selected_row_arr[cnt],0).getValue();
                      id_arr.push(a);
                  }
                  var staging_deal_id = id_arr.toString();
            var data = {
                                "action": "spa_ixp_import_data_interface",
                                "flag": "d",
                                "staging_deal_id":staging_deal_id
                              };
                adiha_post_data('confirm', data, '', '', 'ice_interface_detail_refresh','','Are you sure, You want to delete all data from grid?');           
        }
        ice_interface_import = function() {
            /*
            TODO: ...
            */
            var import_data_list = '';
              active_object_id = get_active_object_id();
              var selected_row = ice_interface["process_grid_" + active_object_id].getSelectedId();
               var data = {
                                "action": "spa_ICE_interface",
                                "flag": "r",
                                "import_rule_id":import_rule_id,
                                "import_type": ice_interface_data_id
                              };
             //   if( selected_row === null){
               //         adiha_post_data('confirm', data, '', '', 'ice_import_all_data_from_grid','','Are you sure, You want to import all data from grid?');
                //      return;
                  //} 
                  if(selected_row !== null)
                  {
                      
                      var selected_row_arr = selected_row.split(',');
                        var id_arr = new Array();
                      for (cnt = 0; cnt < selected_row_arr.length; cnt++) {
                          var a = ice_interface["process_grid_" + active_object_id].cells(selected_row_arr[cnt],0).getValue();
                          id_arr.push(a);
                      }
              
                     import_data_list  = id_arr.toString();
                  }
             var ice_interface_data_id = active_object_id;
            var import_id = active_object_id;
            var as_of_date = null;
            var xml = null;
            var import_rule_id= null;
            var date_from= null;
            var date_to = null;
            var security_def_id  = null;
             
            var exec_call = "EXEC spa_ixp_import_data_interface " 
                            + "'i'"
                            + "," + singleQuote(ice_interface_data_id)
                            + "," + singleQuote(as_of_date)
                            + "," + singleQuote(xml)
                            + "," + singleQuote(import_id)
                            + "," + singleQuote(date_from)
                            + "," + singleQuote(date_to)
                            + "," + singleQuote(security_def_id)
                            + "," + singleQuote(import_data_list);
                    var param = 'call_from=Ice_interface&gen_as_of_date=1&batch_type=c'; 
                 //adiha_post_data('alert', data, '', '', 'ice_interface_import_rule_callback', '', '');
                 adiha_run_batch_process(exec_call, param, 'Re-Import Data');
            
        }
        
        ice_import_all_data_from_grid =function(){
            
             active_object_id = get_active_object_id();
            var import_data_list  = null
             var ice_interface_data_id = active_object_id;
            var import_id = null;
            var as_of_date = null;
            var xml = null;
            var import_rule_id= null;
            var date_from= null;
            var date_to = null;
            var security_def_id  = null;
            
            var exec_call = "EXEC spa_ixp_import_data_interface " 
                            + "'i'"
                            + "," + singleQuote(ice_interface_data_id)
                            + "," + singleQuote(as_of_date)
                            + "," + singleQuote(xml)
                            + "," + singleQuote(import_rule_id)
                            + "," + singleQuote(date_from)
                            + "," + singleQuote(date_to)
                            + "," + singleQuote(security_def_id)
                            + "," + singleQuote(import_data_list);
                    var param = 'call_from=Ice_interface&gen_as_of_date=1&batch_type=c'; 
                 //adiha_post_data('alert', data, '', '', 'ice_interface_import_rule_callback', '', '');
                 adiha_run_batch_process(exec_call, param, 'Send ICE Request');
        }
        ice_interface_detail_refresh = function() {

            //refresh_status_grid();
            refresh_process_grid();
         //  refresh_error_grid();
        }
        
        /*
         * [Refresh the status grid in detail tab]
         */
        refresh_status_grid = function() {
            /*
            TODO: ...
            */
        }
        
        /*
         * [Load the process grid in detail tab for ICE Trade]
         */
    
        refresh_process_grid = function() {
            var active_object_id = get_active_object_id(); 
            ice_interface["details_layout_" + active_object_id].cells('b').progressOn();
            var ixp_import_rule_id;
            var selected_row = ice_interface.grid.getSelectedRowId();
            
            if(selected_row!='')
            {
                 ixp_import_rule_id =  ice_interface.grid.cells(selected_row, ice_interface.grid.getColIndexById("import_rule_id")).getValue();
            }
            else 
            {
                ixp_import_rule_id =ice_interface_data_id;
            }
          /*  if (active_object_id == 1) {
                var flag = 'p';
            } else if (active_object_id == 2) {
                var flag = 's';
            }
            */
            var flag = 's';
            var date_from = ice_interface["filter_form_" + ixp_import_rule_id].getItemValue('date_from', true);
            var date_to = ice_interface["filter_form_" + ixp_import_rule_id].getItemValue('date_to', true);
            var imported  = "0";//ice_interface["filter_form_" + active_object_id].getItemValue('imported', true);
            var grid_param = {
                "flag": flag,
                "action": "spa_ixp_import_data_interface",
                "date_from": date_from,
                "date_to": date_to,
                "import_rule_id":ixp_import_rule_id,
                "import_status":imported

            };

            grid_param = $.param(grid_param);
            var data_url = js_data_collector_url + "&" + grid_param;
            ice_interface["process_grid_" + active_object_id].clearAll();
            ice_interface["process_grid_" + active_object_id].loadXML(data_url, function(){
                ice_interface["process_grid_" + active_object_id].filterByAll();
                ice_interface["details_layout_" + active_object_id].cells('b').progressOff();
            });
            
        }
           /**
    *[openAllInvoices Open All nodes of Invoice Grid]
    */
    openAllInvoices = function() {
        
       ice_interface.grid.expandAll();
       expand_state = 1;
    }
    
    /**
    *[closeAllInvoices Close All nodes of Invoice Grid]
    */
    closeAllInvoices = function() {
       ice_interface.grid.collapseAll();
       expand_state = 0;
    }
        
        /*
         * [Refresh the error grid in detail tab]
         */
        refresh_error_grid = function() {
            
            var active_object_id = get_active_object_id();
            var date_from = ice_interface["filter_form_" + active_object_id].getItemValue('date_from', true);
            var date_to = ice_interface["filter_form_" + active_object_id].getItemValue('date_to', true);
            
            var grid_param = {
                "flag": "e",
                "action": "spa_ICE_interface",
                 "import_type":active_object_id,
                "date_from": date_from,
                "date_to": date_to
            };

            grid_param = $.param(grid_param);
            var data_url = js_data_collector_url + "&" + grid_param;
            ice_interface["error_grid_" + active_object_id].clearAll();
            ice_interface["error_grid_" + active_object_id].loadXML(data_url);
        }
           
        
        /*
         * [Return the active object id]
         */
        get_active_object_id = function() {
            var active_object = ice_interface.tabbar.getActiveTab();
            var active_object_id = (active_object.indexOf("tab_") != -1) ? active_object.replace("tab_", "") : active_object;
            return active_object_id;
        }
    </script>
</html>
        
