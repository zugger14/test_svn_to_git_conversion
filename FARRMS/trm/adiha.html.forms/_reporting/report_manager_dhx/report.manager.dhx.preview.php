<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  
        require_once('../../../adiha.php.scripts/components/include.file.v3.php'); 
        require_once('../../../adiha.php.scripts/components/include.ssrs.reporting.files.php');
        require_once('../report_manager_dhx/report.global.vars.php');
    ?>
    
</head>
<body>
    <?php
        $process_id = get_sanitized_value($_POST['process_id'] ?? '');
        
        $xml_url_major_ver = "EXEC spa_rfx_report_paramset_dhx @flag='m'";
        $data_url_major_ver = readXMLURL2($xml_url_major_ver);
        $major_version_no = $data_url_major_ver[0]['major_version_no'];
        $export_extension = (intval($major_version_no) > 10)?'.xlsx':'.xls';
        $export_extension_full = (intval($major_version_no) > 10)?'EXCELOPENXML':'EXCEL';

        $php_script_loc = $app_php_script_loc;
        $app_user_loc = $app_user_name;

        $form_namespace = 'rm_preview';
        $json = '[
                    {
                        id:             "a",
                        text:           "Parameters",
                        header:         true,
                        collapse:       false,
                        height: 120,
                        offsetTop:0
                    },
                    {
                        id:             "b",
                        text:           "",
                        header:         false,
                        offsetTop:0
                    }
                ]';
        $layout = new AdihaLayout();
        echo $layout->init_layout('layout', '', '2E', $json, $form_namespace);
        
        // attach menu
        //$menu_json = '[{id: "refresh", img:"refresh.gif", img_disabled:"refresh_dis.gif", text:"Refresh", title:"Refresh"}]';
//        $menu_obj = new AdihaMenu();
//        echo $layout->attach_menu_cell("preview_menu", "a");  
//        echo $menu_obj->init_by_attach("preview_menu", $form_namespace);
//        echo $menu_obj->load_menu($menu_json);
//        echo $menu_obj->attach_event('', 'onClick', $form_namespace . '.menu_click');  
    
        echo $layout->close_layout();    
        
           
    ?>
</body>   

    <script>
        //report_type_arr = {};
        //report_ui = {};
        undock_state = 0;
        progress_on = 0;
        process_id = '<?php echo $process_id; ?>';
        var volume_window;
        var session_id = '<?php echo $session_id; ?>';
        var post_data = '';
        var function_or_view_id_gbl = 100000000;
        
        $(function() {
            load_report_toolbar();
        })
        
        fx_get_form_json = function(report_id, paramset_id) {
            
            var sp_string = "EXEC spa_rfx_report_record_dhx @flag='a', @process_id='" + process_id + "', @report_paramset_id=" + paramset_id;
                
            post_data = { sp_string: sp_string };
            //console.log(sp_string);
            $.ajax({
                url: js_form_process_url,
                data: post_data
            }).done(function(data) {
                //console.log(data);
                var json_data = data['json'][0];
                var datasource_id = json_data.source_id;
                var data_source_sql_function_id = -10201625;
                var is_data_source_sql = (json_data.data_source_type == 2) ? 1 : 0; //DATA SOURCE TYPE SQL => 2
                function_or_view_id_gbl = datasource_id + 100000000;
                
                if (is_data_source_sql == 1) {
                    function_or_view_id_gbl =  data_source_sql_function_id;//<FUNCTION ID OF F10 Funtion SQL data source>    
                }
                
                var exec_call = {
                    action: 'spa_view_report_dhx',
                    flag: 'c',
                    report_id: report_id,
                    process_id: process_id,
                    report_param_id: paramset_id
                };
                //console.log(exec_call);
                adiha_post_data('return_json', exec_call, '', '', 'fx_get_form_json_cb');
                
            });
            
             
        };
        fx_get_form_json_cb = function(result) {
            var json_obj = $.parseJSON(result);
            
            var form_json = json_obj[0].form_json;
            //console.log(form_json);
            form_pm = rm_preview.layout.cells('a').attachForm();
            
            //var test_form_json = [{"type":"settings","position":"label-top"},{type: "block", blockOffset: 10, list: [{"type":"input","name":"report_name","label":"Report Name","hidden":"true","disabled":"false","value":"yy","position":"label-top","offsetLeft":"10","labelWidth":"auto","inputWidth":"250","tooltip":"Report Name","required":"false"},{"type":"newcolumn"},{"type":"input","name":"report_paramset_id","label":"Report Paramset ID","hidden":"true","disabled":"false","value":"1","position":"label-top","offsetLeft":"10","labelWidth":"auto","inputWidth":"250","tooltip":"Report Paramset ID","required":"false"},{"type":"newcolumn"},{"type":"input","name":"items_combined","label":"Items Combined","hidden":"true","disabled":"false","value":"","position":"label-top","offsetLeft":"10","labelWidth":"auto","inputWidth":"250","tooltip":"Items Combined","required":"false"},{"type":"newcolumn"}]},{type: "block", blockOffset: 10, list: [{"type":"input","name":"paramset_hash","label":"Paramset Hash","hidden":"true","disabled":"false","value":"CEF77720_CD30_40F4_98DA_FA7F588EA020","position":"label-top","offsetLeft":"10","labelWidth":"auto","inputWidth":"250","tooltip":"Paramset Hash","required":"false"},{"type":"newcolumn"},{"type":"input","name":"report_path","label":"Report Path","hidden":"true","disabled":"false","value":"yy","position":"label-top","offsetLeft":"10","labelWidth":"auto","inputWidth":"250","tooltip":"Report Path","required":"false"},{"type":"newcolumn"}]}];
            form_pm.loadStruct(form_json, function() {
                rm_preview.layout.cells('a').expand();
                toolbar_preview.forEachItem(function(id) {
                    toolbar_preview.enableItem(id);
                });
                //parent.parent.tab_report.progressOff();
                parent.parent.parent.rm.layout.cells('b').progressOff();
            });
            attach_browse_event('form_pm', function_or_view_id_gbl);
			// Added logic below to get combo objects and get checked values...
            form_pm.forEachItem(function(name) {
                var item_type = form_pm.getItemType(name);
                if (item_type == 'combo') {
                    var dropdown_obj = form_pm.getCombo(name);
                    var checked_ids = dropdown_obj.getChecked();
                    $.each(checked_ids, function(id, value) {
                        var ids = dropdown_obj.getIndexByValue(value);
                        dropdown_obj.setChecked(ids, true);
                    });
                }                
            });
        }
        /*
            rm_preview.menu_click = function(id) {
                if(id == 'refresh') {
                    fx_preview_refresh();
                }
            }
        */
        // function for preview refresh
        fx_preview_refresh = function() {
            var report_id = parent.parent.report_deploy[process_id].report_id;
            var deploy_type = parent.parent.report_deploy[process_id].deploy_type;
            //pick only one paramset id for preview
            var paramset_id = parent.grid_pm.cells(0, 0).getValue(); 
            
            if(deploy_type == '' || deploy_type === 'undefined') {
                parent.parent.parent.dhtmlx.message({
                    title: 'Warning',
                    type: 'alert-warning',
                    text: 'Report has not been deployed yet.'
                });
            } else {
                parent.rm_tabs.cells('tab_preview').show();
                parent.rm_tabs.tabs('tab_preview').setActive();
                parent.parent.parent.rm.layout.cells('a').collapse();
                parent.parent.rm_template["inner_tab_layout_" + parent.report_obj.report_id].cells('a').collapse();
                //rm_preview.load_report_detail(paramset_id);
                fx_get_form_json(report_id, paramset_id);
                rm_preview.layout.cells("b").detachObject(true);
            }
            
            
        };
        
        //function to call when click on click
        rm_preview.load_report_detail = function(paramset_id) {
            //to do: pass paramset id
            fx_get_form_json(report_id, paramset_id);
            
            return;
            
            
            
            inner_active_tab = '';
            var full_id = "tab_" + report_id;
            var all_tab_id = rm_preview.report_ui_tabbar.getAllTabs();
            
            if (jQuery.inArray(full_id, all_tab_id ) != -1) {
                rm_preview.report_ui_tabbar.tabs(full_id).setActive();
                return;
            }
            
            rm_preview.report_ui_tabbar.addTab(full_id, report_name, null, null, true, true);
            var win = rm_preview.report_ui_tabbar.cells(full_id);
            rm_preview.report_ui_tabbar.cells(full_id).progressOn();
            
            var report_ui_tab_id = report_id;
            report_type_arr[report_id] = report_type;
            
            rm_preview["inner_tab_layout_" + report_ui_tab_id] = win.attachLayout({
                pattern:"3E",
                cells: [
                    {
                        id: "a", 
                        text: "Apply Filters",
                        header:true,
                        height:100,
                        collapse:true
                    },
                    {
                        id: "b", 
                        header:false,
                        text: "Criteria",
                        height:500
                    },
                    {
                        id: "c", 
                        //text: "<div>Report <a class=\"undock_custom\" style=\"float:right;cursor:pointer\" title=\"Undock\"  onClick=\" undock_window();\"><!--&#8599--></a><a class=\"undock_custom\" style=\"float:right;cursor:pointer\" title=\"Undock\"  onClick=\" new_window_report();\"><!--&#8599--></a></div>", 
                        text: "<div>Report <a class=\"undock_custom\" style=\"float:right;cursor:pointer\" title=\"Undock\"  onClick=\" new_window_report();\"><!--&#8599--></a></div>", 
                        header: true
                    }
                ]
            });
            
            
            var template_name = 'report.manager.report.template.php'; //get_report_template(report_id);
            
            var php_path = '<?php echo $app_adiha_loc; ?>';
            var url = php_path + 'adiha.html.forms/_reporting/view_report/' + template_name;
            
            
            rm_preview["inner_tab_layout_" + report_ui_tab_id].attachEvent("onUnDock", function(name){
                $(".undock_custom").hide();
                rm_preview["inner_tab_layout_" + report_ui_tab_id].dhxWins.window("c").maximize();
                undock_state = 1;
            });
            
            rm_preview["inner_tab_layout_" + report_ui_tab_id].attachEvent("onDock", function(name){
                $(".undock_custom").show();
                undock_state = 0;
            });
        
            rm_preview["inner_tab_layout_" + report_ui_tab_id].attachEvent("onContentLoaded", function(name){
                rm_preview["inner_tab_layout_" + report_id].cells('c').progressOff();
            });
            
            rm_preview["inner_tab_layout_" + report_ui_tab_id].cells('b').attachURL(url, null, {active_object_id: report_ui_tab_id, report_type: report_type, report_id: report_id, report_name: report_name});
            
            if(report_type == 3) {
                load_dashboard_report(report_id);
            } else {
                load_report_toolbar(report_type);
            }
        }
        /**
         * [Attach the toolbar for the report]
         */
        function load_report_toolbar() {
            //var active_tab_id = rm_preview.report_ui_tabbar.getActiveTab();
            //var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            
            toolbar_preview = rm_preview.layout.cells("b").attachToolbar();
            toolbar_preview.setIconsPath(js_image_path + "dhxtoolbar_web/");
			toolbar_preview.loadStruct([
                { id: "html", type: "button", img: "html.gif", text: "HTML", title: "HTML", img_disabled: "html_dis.gif", enabled: 0},
                { type: "separator" },
                { id: "pdf", type: "button", img: "pdf.gif", text: "PDF", title: "PDF", img_disabled: "pdf_dis.gif", enabled: 0 },
                { type: "separator" },
                { id: "excel", type: "button", img: "excel.gif", text: "Excel", title: "Excel", img_disabled: "excel_dis.gif", enabled: 0 },
                { type: "separator" },
                { id: "pivot", type: "button", img: "pivot.gif", text: "Pivot", title: "Pivot", hidden:'true', img_disabled: "pivot_dis.gif", enabled: 0 },
                { type: "separator" },
                { id: "print", type: "button", img: "print.gif", text: "Print", title: "Print", img_disabled: "print_dis.gif", enabled: 0 }
            ]);
            toolbar_preview.attachEvent("onClick", function(id){
                if (id == 'batch') {
                    run_batch_report_manager();
                } else if (id == 'pdf') {
                    show_report('pdf', true);
                } else if (id == 'excel') {
                    show_report('excel', false);
                } else if (id == 'html') {
                    show_report('html', false);
                } else if (id == 'pivot') {
                    show_report('pivot', false);
                } else if (id == 'print') {
                    new_window_report();
                }
            });
        }
        
        /**
         * [show the custom report when toolbar is clicked]
         */
        function show_report(export_type, reload_option, undock_opt) {

            if(!validate_form(form_pm)) {
                return;
            }
            
            var url = app_form_path + '_reporting/report_manager_dhx/report.viewer.php';
            
            //var active_tab_id = rm_preview.report_ui_tabbar.getActiveTab();
            //var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            //var frame_obj = rm_preview["inner_tab_layout_" + active_object_id].cells("b").getFrame();
            
            var parameters = fx_build_parameter();
            var sec_filters_info = parameters[1];
            //console.log(parameters);
            parameters = parameters[0];
            //var filter_list = parameters.split('&applied_filters=');
            //parameters = filter_list[0];
            var filters_used = '';//filter_list[1];
                                           
            if (parameters != false) {
                if (export_type == 'html') {
					parameters += '&export_type=HTML4.0';
				} else if (export_type == 'pdf') {
					parameters += '&export_type=PDF';
				} else if (export_type == 'excel') {
					parameters += '&export_type=EXCEL';
				} else if (export_type == 'pivot') {
					parameters += '&export_type=PIVOT';
				}
                url += parameters;
                
                
                url += '&call_from=dhx_preview&process_id=' + process_id + '&session_id=' +  session_id + '&' +  getAppUserName();
                
                if (undock_opt == true) {
                    return url;
                }

                if (export_type == 'excel') {
                    url += '&writeCSV=true';
                }

                if (reload_option == true) {
                    data = {'applied_filters': filters_used};
                    
                    if (export_type == 'pdf') {
                        open_window_with_post(url)    
                    } else {
                        open_window_with_post(url, '', data)
                    }      
                    
                } else {
                    if (export_type == 'html') {
                        rm_preview.layout.cells("b").progressOn();
                        url += '&close_progress=1';
                    }
                    //console.log(url);
                    rm_preview.layout.cells("b").attachURL(url, null, {
                        applied_filters: filters_used,
                        sec_filters_info: sec_filters_info
                    });
                }
                
                //$('#hide_filter').prop('checked', false);
                rm_preview.layout.cells('a').collapse();
            } else {
                if (undock_opt == true) {
                    return false;
                }
            }
        }
        function fx_build_parameter(batch_flag) {
            //var inner_tab_obj = report_template.report_template_layout.cells("a").getAttachedObject();
            
            //inner_tab_obj.forEachTab(function(tab){
               //form_obj = form_pm;
            //});
            
            var report_filter_list = new Array();
            var report_name = '';
            var items_combined = '';
            var paramset_id = '';
            var paramset_hash = '';
            var report_path = '';
            
            var status = validate_form(form_pm);
            if (status == false) {
                return false;
            }
            
            form_pm.forEachItem(function(name){
                var item_type = form_pm.getItemType(name);
               
                if (name == 'report_name') {
                    value = form_pm.getItemValue(name);
                    report_name = value;
                } else if (name == 'items_combined') {
                    value = form_pm.getItemValue(name);
                    items_combined = value;
                } else if (name == 'report_paramset_id') {
                    value = form_pm.getItemValue(name);
                    paramset_id = value;
                }  else if (name == 'paramset_hash') {
                    value = form_pm.getItemValue(name);
                    paramset_hash = value;
                } else if (name == 'report_path') {
                    value = form_pm.getItemValue(name);
                    report_path = value;
                } else if (item_type != 'fieldset' && item_type != 'block' && item_type != 'button' && name!= 'book_structure') {
                    
                   if (item_type == 'calendar') {
                        var date_obj = form_pm.getCalendar(name);
                        var value = date_obj.getFormatedDate("%Y-%m-%d");
                    } else {
                        value = form_pm.getItemValue(name);
                        if (typeof(value) == 'object') {
                            value = (value.toString()).replace(/,/g, "!");
                        } else {
                            value = value.replace(/,/g, "!");
                        }   
                    }
                    
                    if (name == 'subsidiary_id') { name = 'sub_id'; }
                    if (name == 'strategy_id') { name = 'stra_id'; }
                    if (name == 'subbook_id') { name = 'sub_book_id'; }
                    
                    if (name.indexOf('label_') == -1) {
                        if (value == '') { 
                            report_filter_list.push(name + '=NULL');
                        } else {
                            //if ((name == 'sub_id') || (name == 'stra_id') || (name == 'sub_book_id') || (name == 'book_id')) { value = "'" + value + "'";}
                            report_filter_list.push(name + '=' + value);
                        }
                    }
                }
            });
            
            if (batch_flag == true) {
                var param_array = new Array();
                param_array.push(report_filter_list);
                param_array.push(items_combined);
                param_array.push(paramset_id);
                param_array.push(paramset_hash);
                param_array.push(report_path);
                
                return param_array;
            } else {
                report_name = '?report_name=' + report_name; 
                report_filter = '&report_filter=' + report_filter_list;
                is_refresh = '&is_refresh=0';
                items_combined = '&items_combined=' + items_combined; 
                paramset_id = '&paramset_id=' + paramset_id;

                var parameters = [];
                parameters[0] = report_name + report_filter + is_refresh + items_combined + paramset_id;
                parameters[1] = report_filter_list + '_-_' + process_id;

                return parameters;
            }
        }
        function close_progress() {
            rm_preview.layout.cells("b").progressOff();
        }
        
        /**
         * [show_hide_filter Shows/hide filters]
         */
        rm_preview.show_hide_filter = function(report_id, export_type) {
            /*
            if (report_id == '') {
                var all_tab_id = rm_preview.report_ui_tabbar.getAllTabs();
                if (all_tab_id != '') {
                    var active_tab_id = rm_preview.report_ui_tabbar.getActiveTab();
                    var report_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
                }
            }
            
            if ($('#hide_filter').prop('checked')) {
                parent.report_ui.layout.cells('a').expand();
                if (report_id != '')
                    rm_preview["inner_tab_layout_" + report_id].cells('b').expand();
            } else {  
            */  
            if (export_type != 'pdf' && export_type != 'excel' && export_type != 'pivot') {
                parent.report_ui.layout.cells('a').collapse();
                if (report_id != '') {
                    rm_preview["inner_tab_layout_" + report_id].cells('a').collapse();
                    rm_preview["inner_tab_layout_" + report_id].cells('b').collapse();
                    rm_preview["inner_tab_layout_" + report_id].cells('c').progressOn();
                }
            }
            //}
        }
        
        /**
         * [Generates the apply filter form and its logic - Function called from the attached report page]
         * @param obj [Layout cell obj, Returned from the attached report page]
         */
        function set_apply_filter(obj) {
            var active_tab_id = rm_preview.report_ui_tabbar.getActiveTab();
            var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            
            var report_id = active_object_id;
            var report_type = report_type_arr[report_id];
            var filter_obj = rm_preview["inner_tab_layout_" + active_object_id].cells('a').attachForm();
            var layout_cell_obj = obj;
            
            load_form_filter(filter_obj, layout_cell_obj, report_id, report_type);
			rm_preview.report_ui_tabbar.cells(active_tab_id).progressOff();
        }
        
        function show_pivot_button(obj) {
            var active_tab_id = rm_preview.report_ui_tabbar.getActiveTab();
            var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            rm_preview["report_toolbar_" + active_object_id].showItem('pivot');
        }
        
        /**
         * [Returns the template name for the report]
         * @param report_id [Function ID for the Standard report and function id fro report manager report]
         */
        function get_report_template(report_id) {
            var report_type = report_type_arr[report_id];

            if (report_id == 10222400) {
                template_name = 'meter.data.report.php';
            } else if (report_id == 10202100) {
                template_name = 'message.board.log.report.php';
            } else if (report_id == 10111400) {
                template_name = 'system.access.log.report.php';
            } else if (report_id == 10221900) {
                template_name = 'deal.settlement.report.php';
            } else if (report_id == 10221200) {
                template_name = 'contract.settlement.report.php';
            } else if (report_id == 10161400) {
                template_name = '../../_scheduling_delivery/gas/schedule_delivery/schedule_delivery_positionReport_main.php'
            } else if (report_id == 10171100) {
                template_name = '../../_deal_verification_confirmation/transaction_audit_log/transaction.audit.log.php'
            } else if (report_id == 10201500) {
				template_name = 'static.data.audit.report.php'
            } else if (report_id == 13121200) {
				template_name = 'run.hedge.ineffectiveness.report.php'
            } else if (report_id == 10141900) {
				template_name = 'load.forecast.report.php'
            } else if (report_id == 10161200) {
                template_name = 'gas.position.report.php'
            } else if (report_id == 10162600) {
                template_name = 'pipeline.imbalance.report.php'
            } else if (report_id == 10234900) {
                template_name = 'measurement.report.php'    
            } else if (report_id == 10142400) {
                template_name = 'derivative.position.report.php'    
            } else if (report_id == 10235400) {
                template_name = 'journal.entry.report.php'      
            } else if (report_id == 10236400) {
                template_name = 'available.hedge.capacity.exception.report.php'    
            } else if (report_id == 10235500) {
                template_name = 'net.journal.entry.report.php'
            } else if (report_id == 10235700) {
                template_name = 'net.asset.report.php'
            } else if (report_id == 10236500) {
                template_name = 'not.mapped.deal.report.php'
            } else if (report_id == 10235300) {
                template_name = 'dedes.values.report.php'
            } else if (report_id == 10233900) {
                template_name = 'des.of.a.hedge.report.php'
            } else if (report_id == 13160000) {
                template_name = 'hedging.relationship.audit.report.php'
            } else {
                if (report_type == 1) {
                    template_name = 'report.manager.report.template.php';
                } else if (report_type == 2) {
                    template_name = 'standard.report.template.php';
                } else if (report_type == 3) {
                    template_name = 'dashboard.report.template.php';
                }
            }
            
            return template_name;
        }
        
        
        
        /*
         *====================================================================================================================
         */
         
        /**
         * [Create multiple tabs for Dashboard Report]
         */
        function load_dashboard_report(report_id) {
            rm_preview["inner_tab_layout_" + report_id].cells('c').progressOn();
            
            data = {"action": "spa_rfx_group_template_group",
                        "flag": "s",
                        "report_template_name_id": report_id
                     };

            adiha_post_data('return_array', data, '', '', 'load_post_callback');
        }
        
         function load_post_callback(result) {
            var result_length = result.length;
            var tab_json = '';
            var is_active = true;
            
            for (i = 0; i < result_length; i++) {
                var tab_id = 'detail_tab_' + result[i][1]  + result[i][0];
                if (i > 0) {
                    tab_json = tab_json + ",";
                    var is_active = false;
                }
                tab_json = tab_json + '{"id":"' + tab_id + '", "text":"' + result[i][2] + '", "active":"' + is_active + '"}';
            }
            tab_json = '{tabs: [' + tab_json + ']}';
            
            var active_tab_id = rm_preview.report_ui_tabbar.getActiveTab();
            var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            
            report_ui["dashboard_report_tabs_" + active_object_id] = rm_preview["inner_tab_layout_" + active_object_id].cells("c").attachTabbar();
            report_ui["dashboard_report_tabs_" + active_object_id].loadStruct(tab_json);
            
            if (inner_active_tab != '')
                report_ui["dashboard_report_tabs_" + active_object_id].tabs(inner_active_tab).setActive();
            
            for (j = 0; j < result_length; j++) {
                var tab_id = 'detail_tab_' + result[j][1]  + result[j][0];
                rm_preview["report_toolbar_" + active_object_id] = report_ui["dashboard_report_tabs_" + active_object_id].cells(tab_id).attachToolbar();
                rm_preview["report_toolbar_" + active_object_id].setIconsPath(js_image_path + "dhxtoolbar_web/");
    			rm_preview["report_toolbar_" + active_object_id].loadStruct([
                            { id: "refresh", type: "button", img: "refresh.gif", text: "Refresh", title: "Refresh"}
                ]);
                
                rm_preview["report_toolbar_" + active_object_id].attachEvent("onClick", function(id){
                    switch(id) {
                        case "refresh":
                            progress_on = 0;
                            var active_tab_id = rm_preview.report_ui_tabbar.getActiveTab();
                            var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
                            inner_active_tab = report_ui["dashboard_report_tabs_" + active_object_id].getActiveTab();
                            
                            if (undock_state == 0) {
                                var frame_obj = rm_preview["inner_tab_layout_" + active_object_id].cells('b').getFrame();
                                var status = frame_obj.contentWindow.validate_dashboard_parameter();
                                
                                if (status == 0) {
                                    load_dashboard_report(active_object_id);
                                } else {
                                    return;
                                }
                            } else {
                                var inner_active_object_id = (inner_active_tab.indexOf("tab_") != -1) ? inner_active_tab.replace("tab_", "") : inner_active_tab;
                                var to_remove = 'detail_' + active_object_id;
                                var report_manager_group_id = inner_active_object_id.replace(to_remove, "");
                                
                                data = {"action": "spa_rfx_group_template_group",
                                        "flag": "c",
                                        "report_manager_group_id": report_manager_group_id
                                     };
                
                                adiha_post_data('return_array', data, '', '', 'dashboard_report_post_callback');
                            }
                        break;
                    }
                });
                
                data = {"action": "spa_rfx_group_template_group",
                        "flag": "c",
                        "report_manager_group_id": result[j][0]
                     };

                adiha_post_data('return_array', data, '', '', 'dashboard_report_post_callback');
            }
        }
        
        function dashboard_report_post_callback(result) {
            var active_tab_id = rm_preview.report_ui_tabbar.getActiveTab();
            var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            var tab_id = 'detail_tab_' + active_object_id  + result[0][4];
            
            var frame_obj = rm_preview["inner_tab_layout_" + active_object_id].cells('b').getFrame();
            
            if (typeof (frame_obj.contentWindow.return_as_of_date) === 'function') {
                var as_of_date = frame_obj.contentWindow.return_as_of_date();
            } else {
                var as_of_date = '';
            }
            
            report_ui["dashboard_report_tabs_" + active_object_id].attachEvent("onContentLoaded", function(name){
                rm_preview["inner_tab_layout_" + active_object_id].cells('c').progressOff();
                
                if (undock_state == 0 && progress_on == 0) {
                    rm_preview["inner_tab_layout_" + active_object_id].cells('c').undock();
                    progress_on = 1;
                }
            });
                                               
            var url = js_php_base_path  + 'adiha.html.forms/_reporting/report_manager_dhx/report.viewer.php?paramset_id=' + result[0][6];
            url += '&report_name=' + result[0][3];
            url += '&report_filter=' + rfx_override_as_of_date(result[0][2], as_of_date)
            url += '&items_combined=' + result[0][5];
            url += '&session_id=' + session_id;
            url += '&call_from=DASHBOARD&export_type=HTML4.0&refresh_time=' + result[0][8];
            
            report_ui["dashboard_report_tabs_" + active_object_id].cells(tab_id).attachURL(url, null);
            
            //parent.report_ui.layout.cells('a').collapse();
//            rm_preview["inner_tab_layout_" + active_object_id].cells('b').collapse();
        }
        
        function rfx_override_as_of_date(report_filter, as_of_date) {
            var final_report_filter = '';
            var first_split = report_filter.split(",");
            var count = 0;
            
            first_split.forEach(function(entry) {
                var second_final = new Array();
                var second_split = entry.split("=");
                
                if (second_split[0] == 'as_of_date' || second_split[0] == 'pnl_as_of_date' || second_split[0] == 'asOfDate') {
                    second_split[1] = (as_of_date != '' ? as_of_date : second_split[1]);
                    second_final = second_split.join("=");
                } else {
                    second_final = second_split.join("=");
                }
                final_report_filter += (count > 0 ? ',' : '') + second_final;
                count++;
            });
            return final_report_filter;
        }
        /*
         *===================================================================================================================
         */
         
        
        
        
        
        function run_batch_standard_report() {
            var active_tab_id = rm_preview.report_ui_tabbar.getActiveTab();
            var report_name = rm_preview.report_ui_tabbar.tabs(active_tab_id).getText();
            var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            var frame_obj = rm_preview["inner_tab_layout_" + active_object_id].cells("b").getFrame();
            
            var exec_call = frame_obj.contentWindow.report_parameter(true);
                        
            if (typeof (frame_obj.contentWindow.return_as_of_date) === 'function') {
                var as_of_date = frame_obj.contentWindow.return_as_of_date();
            } else{
                var as_of_date = '<?php echo date('Y-m-d'); ?>';
            }
            
            if (as_of_date == ''){
                var as_of_date = '<?php echo date('Y-m-d'); ?>';
            }
            
            var gen_as_of_date = (exec_call.indexOf('gen_as_of_date=') == '-1') ? 0 : exec_call.substr(exec_call.indexOf('gen_as_of_date=') + 15, 1);
            
            var filter_list = exec_call.split('&');
            exec_call = filter_list[0];
           
            if (exec_call != false) {
                var param = 'call_from=' + report_name + '&gen_as_of_date=' + gen_as_of_date + '&as_of_date=' + as_of_date; 
                adiha_run_batch_process(exec_call, param, report_name);
            }
        }
        
        function run_batch_report_manager() {
            var active_tab_id = rm_preview.report_ui_tabbar.getActiveTab();
            var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            var frame_obj = rm_preview["inner_tab_layout_" + active_object_id].cells("b").getFrame();
            
            var report_id = active_object_id;
            var report_name = rm_preview.report_ui_tabbar.tabs(active_tab_id).getText();
            
            var return_value = frame_obj.contentWindow.report_parameter(true);
            
            if (return_value != false) {
                var report_filter = return_value[0];
                var items_combined = return_value[1];
                var report_paramset_id = return_value[2];
                var v_paramset_hash = return_value[3];
                var report_path = return_value[4];
                var is_refresh = 0;
                var export_extension = '<?php echo $export_extension;?>';
                var export_extension_full = '<?php echo $export_extension_full;?>';

                var param = "call_from=Report Batch Job&gen_as_of_date=1&rfx=1";
                var cmd_command = construct_report_export_cmd(report_name, report_path, report_paramset_id, report_filter, items_combined, v_paramset_hash, is_refresh, export_extension, export_extension_full, '_DELIM_', '_IS_HEADER_');//rds_display_combined);
                var exec_call = return_batch_sp_call(cmd_command, report_name, report_name + export_extension);
                exec_call = exec_call + ', NULL'; //adding ftp param as NULL

                adiha_run_batch_process(exec_call, param, report_name);
            }
        }
        
        /*
        function undock_window() {
            var active_tab_id = rm_preview.report_ui_tabbar.getActiveTab();
            var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            
            var url = show_report(active_object_id, 'html', false, true);
            
            if (url == false) {
                return;
            }
            
            $('#hide_filter').prop('checked', false);
            rm_preview.show_hide_filter(active_object_id);
            
            report_dhxWins = new dhtmlXWindows();
            w1 = report_dhxWins.createWindow("w1", 300, 50, 900, 700);
            w1.setText("Reports");
            w1.attachURL(url, false, true);
            
            report_dhxWins.window("w1").button("close").hide();
            report_dhxWins.window("w1").button("park").hide();
            report_dhxWins.window("w1").button("minmax").hide();
            report_dhxWins.window("w1").addUserButton("dock", 3, "Undock", "Undock");
            report_dhxWins.window("w1").addUserButton("minmax", 3, "minmax", "minmax");
            report_dhxWins.window("w1").maximize();
            
            report_dhxWins.window("w1").button("dock").attachEvent("onClick", function(){
                report_dhxWins.window("w1").close();
                
            });
        }
        */
        
        function new_window_report() {
            var url = show_report('html', false, true);
            var params = [
                'height=' + (screen.availHeight),
                'width=' + (screen.availWidth),
                'resizable=yes'
            ].join(',');
            var win_print = window.open(url,'Report Print',params);
            win_print.moveTo(0,0);
            win_print.print();
            
        }
        
        /* DEAL SCHEDULE FUNCTIONS START */
        /*
        Function to open deal schedule window
        */
        function fx_open_deal_schedule(deal_id) {
            if (!volume_window) {
                volume_window = new dhtmlXWindows();
            }
            var win_url = '../../_deal_capture/maintain_deals/schedule.deal.php';
            var win_title = 'Schedule Deal';
            win_url += '?&group_by=Deal&source_deal_header_id=' + deal_id;
            var win = volume_window.createWindow('w1', 0, 0, 400, 400);
            win.setText(win_title);
            win.centerOnScreen();
            win.setModal(true);
            win.maximize();
            win.attachURL(win_url, null);
        }
        /*
        Function to open detail report for under schedule [deal schedule]
        */
        function sch_under_over_detail_report(warning_type, process_id) {
            var report_name = 'Schedule Detail Report';
            var exec_call = "EXEC spa_view_validation_log 'schedule_detail','" + process_id + "', 's'";
            open_spa_html_window(report_name, exec_call, 500, 1150);
        }
        /* DEAL SCHEDULE FUNCTIONS END */
        
        
        //ajax setup for default values
        $.ajaxSetup({
            method: 'POST',
            dataType: 'json',
            error: function(jqXHR, text_status, error_thrown) {
                console.log('*** Error on ajax: ' + text_status + ', ' + error_thrown);
            }
        });
    </script>