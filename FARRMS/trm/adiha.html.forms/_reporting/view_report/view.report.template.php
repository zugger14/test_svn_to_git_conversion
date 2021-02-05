<?php
/**
* View report template screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  
        require('../../../adiha.php.scripts/components/include.file.v3.php'); 
        require_once('../report_manager_dhx/report.global.vars.php');
		require('../../../adiha.php.scripts/components/include.ssrs.reporting.files.php');
    ?>   
</head>
<body>
    <?php
        $mode = strtolower(get_sanitized_value($_GET['mode'] ?? 'view_report'));
        $rights_report_manager_powerbi = 10202512;
        
        list (
            $has_rights_report_manager_powerbi
        ) = build_security_rights (
            $rights_report_manager_powerbi
        );

        $export_extension = '.xlsx';
        $export_extension_full = 'EXCELOPENXML';

        $php_script_loc = $app_php_script_loc;
        $app_user_loc = $app_user_name;

        $form_namespace = 'report_ui_template';
        $json = '[
                    {
                        id:             "a",
                        text:           "Reports",
                        header:         false,
                        offsetTop:0
                    }
                ]';
        $report_template_layout_obj = new AdihaLayout();
        echo $report_template_layout_obj->init_layout('template_layout', '', '1C', $json, $form_namespace);
        echo $report_template_layout_obj->attach_tab_cell('report_ui_tabbar', 'a', '');
        echo $report_template_layout_obj->close_layout();       
    ?>
</body>   
<style>
    html, body {
        width: 100%;
        height: 100%;
        margin: 0px;
        padding: 0px;
        background-color: #ebebeb;
        overflow: hidden;
    }
</style>
    <script>
		google.load("visualization", "1", {packages:["corechart", "charteditor"]});
		
        report_type_arr = {};
        report_ui = {};
        undock_state = 0;
        progress_on = 0;
        var volume_window;
        var session_id = '<?php echo $session_id; ?>';

        var paramset_id_gbl = {};
        var power_bi_reports = {};
        var mode = '<?php echo $mode; ?>';
		var glb_pivot_id = '';
        var todays_date = '<?php echo date('Y-m-d'); ?>';
		
        /**
         * [Load function when the accordion is double clicked]
         */
        report_ui_template.load_report_detail = function(report_id, report_name, report_type, report_param_id, call_from, link_id, strategy_id, subsidiary_id, book_id, book_structure_text, effective_date_to,report_unique_identifier,effective_date_from,link_id_from, link_id_to) {
            inner_active_tab = '';
            var full_id = "tab_" + (report_type == 1 ? report_param_id : report_id);
            var all_tab_id = report_ui_template.report_ui_tabbar.getAllTabs();

            if (jQuery.inArray(full_id, all_tab_id ) != -1) {
                report_ui_template.report_ui_tabbar.tabs(full_id).setActive();
                return;
            }
            
            report_ui_template.report_ui_tabbar.addTab(full_id, report_name, null, null, true, true);
            var win = report_ui_template.report_ui_tabbar.cells(full_id);
            report_ui_template.report_ui_tabbar.cells(full_id).progressOn();
            
            var report_ui_tab_id = (report_type == 1 ? report_param_id : report_id);
            report_type_arr[report_ui_tab_id] = report_type;
            paramset_id_gbl[report_ui_tab_id] = report_param_id;

            if(report_type == 4 && false) { //apply same logic for excel add-in reports
                report_ui_template["inner_tab_layout_" + report_ui_tab_id] = win.attachLayout({
                    pattern:"1C",
                    cells: [
                        {
                            id: "a", 
                            text: "Report",
                            header: true
                        }
                    ]
                });
                
                var old_layout_header_text = report_ui_template["inner_tab_layout_" + report_ui_tab_id].cells('a').getText();
                report_ui_template["inner_tab_layout_" + report_ui_tab_id].cells('a').setText("<div>" + old_layout_header_text + " <a class=\"undock_custom\" style=\"float:right;cursor:pointer\" title=\"" + get_locale_value("Undock") + "\"  onClick=\" new_window_report(" + report_type + ");\"><!--&#8599--></a></div>");

                report_ui_template["inner_tab_layout_" + report_ui_tab_id].attachEvent("onUnDock", function(name){
                    $(".undock_custom").hide();
                    report_ui_template["inner_tab_layout_" + report_ui_tab_id].dhxWins.window("a").maximize();
                    undock_state = 1;
                });
                
                report_ui_template["inner_tab_layout_" + report_ui_tab_id].attachEvent("onDock", function(name){
                    $(".undock_custom").show();
                    undock_state = 0;
                });
                report_ui_template["inner_tab_layout_" + report_ui_tab_id].attachEvent("onContentLoaded", function(name){
                    report_ui_template["inner_tab_layout_" + report_id].cells('a').progressOff();
                });
                
                load_excel_report_toolbar(report_type);
                report_ui_template.report_ui_tabbar.cells(full_id).progressOff(); 
            } else { //start for report type other than 4
                var inner_layout_cell_title = 'Report';
                if (mode == 'run_process')
                    inner_layout_cell_title = 'Process';
                else if (mode == 'data_export')
                    inner_layout_cell_title = 'Data';
                    
                report_ui_template["inner_tab_layout_" + report_ui_tab_id] = win.attachLayout({
                    pattern:"3E",
                    cells: [
                        {
                            id: "a", 
                            text: "Apply Filters",
                            header:true,
                            height:100,
                            collapse:false
                        },
                        {
                            id: "b", 
                            header:true,
                            text: "Criteria",
                            height:500
                        },
                        {
                            id: "c", 
                            text: inner_layout_cell_title,
                            header: true
                        }
                    ]
                });
                
                var old_layout_header_text = report_ui_template["inner_tab_layout_" + report_ui_tab_id].cells('c').getText();
                report_ui_template["inner_tab_layout_" + report_ui_tab_id].cells('c').setText("<div>" + old_layout_header_text + " <a class=\"undock_custom\" style=\"float:right;cursor:pointer\" title=\"" + get_locale_value("Undock") + "\"  onClick=\" new_window_report(" + report_type + ");\"><!--&#8599--></a></div>");
                
                var template_name = get_report_template(report_ui_tab_id);
                
                var php_path = '<?php echo $app_adiha_loc; ?>';
                var url = php_path + 'adiha.html.forms/_reporting/view_report/' + template_name;
                
                report_ui_template["inner_tab_layout_" + report_ui_tab_id].attachEvent("onUnDock", function(name){
                    $(".undock_custom").hide();
                    report_ui_template["inner_tab_layout_" + report_ui_tab_id].dhxWins.window("c").maximize();
                    undock_state = 1;
                });
                
                report_ui_template["inner_tab_layout_" + report_ui_tab_id].attachEvent("onDock", function(name){
                    $(".undock_custom").show();
                    undock_state = 0;
                });
            
                report_ui_template["inner_tab_layout_" + report_ui_tab_id].attachEvent("onContentLoaded", function(name){
                            report_ui_template.report_ui_tabbar.cells("tab_" + report_ui_tab_id).progressOff();
                    report_ui_template["inner_tab_layout_" + report_id].cells('c').progressOff();
                });

            var params = {active_object_id: report_ui_tab_id, 
                          report_type: report_type, 
                          report_id: report_id, 
                          report_name: report_name, 
                          report_param_id: report_param_id, 
                          link_id: link_id, 
                          strategy_id:strategy_id, 
                          subsidiary_id:subsidiary_id, 
                          book_id:book_id,
                          book_structure_text:book_structure_text,
                          effective_date_to:effective_date_to,
                          call_from:call_from,
                          report_unique_identifier:report_unique_identifier,
                          effective_date_from:effective_date_from,
                          link_id_from:link_id_from,
                          link_id_to:link_id_to
                      };
            report_ui_template["inner_tab_layout_" + report_ui_tab_id].cells('b').attachURL(url, null, params);
                
                if(report_type == 3) {
                    load_dashboard_report(report_id);
                } else {
                    load_report_toolbar(report_type);
                }   
                
            } //End for report_type other than 4
        }
        
        /**
         * [show_hide_filter Shows/hide filters]
         */
        report_ui_template.show_hide_filter = function(report_id, export_type) {
            if (export_type != 'pdf' && export_type != 'excel' && export_type != 'pivot') {
                parent.report_ui.layout.cells('a').collapse();
                if (report_id != '') {
                    report_ui_template["inner_tab_layout_" + report_id].cells('a').collapse();
                    report_ui_template["inner_tab_layout_" + report_id].cells('b').collapse();
                    report_ui_template["inner_tab_layout_" + report_id].cells('c').progressOn();
                }
            }
        }
        
        /**
         * [Generates the apply filter form and its logic - Function called from the attached report page]
         * @param obj [Layout cell obj, Returned from the attached report page]
         */
        function set_apply_filter(obj) {
            var active_tab_id = report_ui_template.report_ui_tabbar.getActiveTab();
            var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            
            var report_id = active_object_id;
            var report_type = report_type_arr[report_id];
            var filter_obj = report_ui_template["inner_tab_layout_" + active_object_id].cells('a').attachForm();
            var layout_cell_obj = obj;
            
            //storing extra parameter to pass on apply filter logic, other parameters also can be added on array
            var extra_paramater = {}; 
            extra_paramater['paramset_id'] = paramset_id_gbl[report_id];
            
            filter_obj.setUserData('btn_filter_save', 'extra_paramater', extra_paramater);
            
            load_form_filter(filter_obj, layout_cell_obj, report_id, report_type);
            if (report_type != 4) report_ui_template.report_ui_tabbar.cells(active_tab_id).progressOff();
            report_ui_template["inner_tab_layout_" + active_object_id].cells('a').collapse();
        }
        
        function show_pivot_button(obj) {
            var active_tab_id = report_ui_template.report_ui_tabbar.getActiveTab();
            var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            if (mode != 'run_process' && mode != 'data_export') {
                report_ui_template["report_toolbar_" + active_object_id].showItem('rp');
            }
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
            } else if (report_id == 10161500) {
                template_name = '../../_scheduling_delivery/gas/schedule_delivery/storage_position_report.php'
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
            } else if (report_id == 10235200) {
                template_name = 'aoci.report.php'
            } else if (report_id == 10234200) {
                template_name = 'lifecycles.of.hedges.php'
            } else if (report_id == 12131000) {
                template_name = 'run.target.report.php';
            } else if (report_id == 10141400) {
                template_name = 'transaction.report.php';
            } else if (report_id == 12121500) {
                template_name = 'lifecycle.of.transactions.php'; 
             } else if (report_id == 20009500) {
               template_name = 'counterparty.mtm.report.php'; 
            } else if (report_id == 20007800) {
                template_name = 'mtm.report.php'; 
            }  else {
                if (report_type == 1) {
                    template_name = 'report.manager.report.template.php';
                } else if (report_type == 2) {
                    template_name = 'standard.report.template.php';
                } else if (report_type == 3) {
                    template_name = 'dashboard.report.template.php';
                } else if (report_type == 4) {
                    template_name = 'report.manager.report.template.php';
                } else if (report_type == 5) {
                    template_name = 'report.manager.report.template.php';
                }
            }
            
            return template_name;
        }
        
        /**
         * [Attach the toolbar for the report]
         */
        function load_report_toolbar(report_type) {
            var active_tab_id = report_ui_template.report_ui_tabbar.getActiveTab();
            var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            
            report_ui_template["report_toolbar_" + active_object_id] = report_ui_template["inner_tab_layout_" + active_object_id].cells("c").attachMenu();
            report_ui_template["report_toolbar_" + active_object_id].setIconsPath(js_image_path + "dhxtoolbar_web/");

            btn_title_html = (report_type == 4 ? 'Refresh' : 'HTML');
            hide_excel_btn = (report_type == 4 ? 1 : 0);

            if (mode == 'document_generation') {
                btn_title_html = 'Generate';
                btn_icon = 'doc.gif';
            } else if (mode == 'calculation_engine') {
                btn_title_html = 'Calculate';
                btn_icon = 'run.gif';
            } else if (mode == 'data_export') {
                btn_title_html = 'Preview';
                btn_icon = 'html.gif';
            } else {
                btn_icon = 'html.gif';
            }

            if (report_type == 5) {
                var menu_json = [
                            { id: "bi_refresh", img: "refresh.gif", text: "Refresh", title: "Refresh"}
                         ];
            } else {
            var menu_json = [
                        { id: "html", img: btn_icon, text: btn_title_html, title: btn_title_html},
                        { id: "pdf", img: "pdf.gif", text: "PDF", title: "PDF"},
                        { id: "excel", img: "excel.gif", text: "Excel", title: "Excel"},
                        { id: "batch", img: "batch.gif", text: "Batch", title: "Batch" },
                        { id: "pivot", img: "pivot.gif", text: "Pivot", title: "Pivot", items:[
							{ id: "pivot_view", img: "pivot.gif", text: "Pivot Views", title: "Pivot Views"},
							{ id: "rp", img: "pivot.gif", text: "Create and Edit Pivot", title: "Create and Edit Pivot"}
						]},
						{ id: "refresh_pivot", img: "refresh.gif", text: "Refresh Pivot", title: "Refresh Pivot"}
                     ];
            }
            report_ui_template["report_toolbar_" + active_object_id].loadStruct(menu_json);
			//report_ui_template["report_toolbar_" + active_object_id].hideItem(id);
			
			report_ui_template["report_toolbar_" + active_object_id].setUserData('refresh_pivot', 'pivot_id', -1);
			report_ui_template["report_toolbar_" + active_object_id].hideItem('refresh_pivot');
			load_pivot_view_menu(active_object_id, report_type);
			
            if(hide_excel_btn == 1){
                //report_ui_template["report_toolbar_" + active_object_id].hideItem("pdf");
                //report_ui_template["report_toolbar_" + active_object_id].hideItem("excel");
                report_ui_template["report_toolbar_" + active_object_id].hideItem("pivot");
            }
            
            if (mode == 'run_process') {
                report_ui_template["report_toolbar_" + active_object_id].hideItem("pdf");
                report_ui_template["report_toolbar_" + active_object_id].hideItem("excel");
                report_ui_template["report_toolbar_" + active_object_id].hideItem("html");
                report_ui_template["report_toolbar_" + active_object_id].hideItem("pivot");

                report_ui_template["report_toolbar_" + active_object_id].setItemText("batch", get_locale_value("Run"));
                report_ui_template["report_toolbar_" + active_object_id].setItemImage("batch", "run.gif");
            } else if (mode == 'data_export') {
                report_ui_template["report_toolbar_" + active_object_id].hideItem("pdf");
                report_ui_template["report_toolbar_" + active_object_id].hideItem("excel");
                report_ui_template["report_toolbar_" + active_object_id].hideItem("batch");
                report_ui_template["report_toolbar_" + active_object_id].hideItem("pivot");

                report_ui_template["report_toolbar_" + active_object_id].addButtonSelect("export","2","Export",[],"export.gif","export.gif",false,true);
                report_ui_template["report_toolbar_" + active_object_id].addListOption("export", "batch", "1", "button", get_locale_value("Batch"), "batch.gif");
                report_ui_template["report_toolbar_" + active_object_id].addListOption("export", "excel", "2", "button", get_locale_value("Excel"), "excel.gif");
                report_ui_template["report_toolbar_" + active_object_id].addListOption("export", "pdf", "3", "button", get_locale_value("PDF"), "pdf.gif");
            }
            
            report_ui_template["report_toolbar_" + active_object_id].attachEvent("onClick", function(id){
				var is_prev_hidden = report_ui_template["report_toolbar_" + active_object_id].isItemHidden('refresh_pivot');
                report_ui_template["report_toolbar_" + active_object_id].hideItem('refresh_pivot');
				
				if (id.indexOf('pivot_view_') > -1) {
					var pivot_id = id.replace('pivot_view_','');
					glb_pivot_id = pivot_id;
				} else if (id != 'rp') {
					glb_pivot_id = '';
				}
				
				if (id == 'batch') {
                    if (report_type == 2) {
                        run_batch_standard_report();
                    } else if(report_type == 1) {
                        run_batch_report_manager();
                    } else if(report_type == 4) {
                        run_batch_excel_report();
                    }
                } else if (id == 'pdf') {
                    show_report(active_object_id, (report_type == 4 ? 'pdf2' : 'pdf'), (report_type == 4 ? false: true));
                } else if (id == 'excel') {
                    //show_report(active_object_id, 'excel', false);
                    show_report(active_object_id, (report_type == 4 ? 'excel2' : 'excel'), false);

                } else if (id == 'html') {
                    // if (report_type == 4) {
                    //     show_excel_report(active_object_id, 'html', false);
                    // } else if(report_type == 1) {
                    //     show_report(active_object_id, 'html', false);
                    // }
                    show_report(active_object_id, (report_type == 4 ? 'html2' : 'html'), false);
                    
                } else if (id == 'pivot') {
                    show_report(active_object_id, 'pivot', false);
                } else if (id == 'rp') {
					if (is_prev_hidden == false) {
						report_ui_template["report_toolbar_" + active_object_id].showItem('refresh_pivot');
					}
					show_report(active_object_id, 'rp', false);
                } else if (id == 'bi_refresh') {
                    show_power_bi_report(active_object_id, id, false, false);
                } else if (id.indexOf('pivot_view_') > -1) {
					var pivot_id = id.replace('pivot_view_','');
					report_ui_template["report_toolbar_" + active_object_id].setUserData('refresh_pivot', 'pivot_id', pivot_id);
					report_ui_template["report_toolbar_" + active_object_id].showItem('refresh_pivot');
					load_pivot_view(pivot_id);
				} else if (id == 'refresh_pivot') {
					report_ui_template["report_toolbar_" + active_object_id].showItem('refresh_pivot');
					var pivot_id = report_ui_template["report_toolbar_" + active_object_id].getUserData('refresh_pivot', 'pivot_id');
					load_pivot_view(pivot_id);
				}
            });
        }
		
		load_pivot_view_menu = function(id, report_type) {
			data = {
						"action": "spa_pivot_report_view",
						"flag": "k",
						"report_paramset_id": id,
						"report_type": report_type
					};

		   adiha_post_data('return_array', data, '', '', 'load_pivot_view_menu_callback');	
		}
		
		load_pivot_view_menu_callback = function(result) {
			var active_tab_id = report_ui_template.report_ui_tabbar.getActiveTab();
            var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            
			report_ui_template["report_toolbar_" + active_object_id].forEachItem(function(itemId){
				if (itemId.indexOf('pivot_view_') > -1) {
					report_ui_template["report_toolbar_" + active_object_id].removeItem(itemId);
				}
			});
			
			if (result.length == 0) {
				report_ui_template["report_toolbar_" + active_object_id].addNewChild('pivot_view', 1, 'no_pivot', '<i>No Pivot Reports</i>', true, '', '');
			}
			
			for (cnt = 0; cnt < result.length; cnt++) {
				report_ui_template["report_toolbar_" + active_object_id].addNewChild('pivot_view', cnt+1, 'pivot_view_' + result[cnt][0], result[cnt][1], false, '', '');
			}
		}
		
		
        /*
         *====================================================================================================================
         */
         function call_back_report_refresh(){
            var active_tab_id = report_ui_template.report_ui_tabbar.getActiveTab();
            var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            show_report(active_object_id, 'html', false);
         }

         /**
         * [Attach the toolbar for the Excel report]
         */
        function load_excel_report_toolbar(report_type) {
            var active_tab_id = report_ui_template.report_ui_tabbar.getActiveTab();
            var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            
            report_ui_template["report_toolbar_" + active_object_id] = report_ui_template["inner_tab_layout_" + active_object_id].cells("a").attachToolbar();
            report_ui_template["report_toolbar_" + active_object_id].setIconsPath(js_image_path + "dhxtoolbar_web/");

            var menu_json = [
                        { id: "html2", type: "button", img: "refresh.gif", text: "Refresh", title: "Refresh"},
                        { type: "separator" },
                        { id: "pdf", type: "button", img: "export.gif", text: "Export", title: "Export" },
                        { type: "separator" },
                        { id: "excel", type: "button", img: "print.gif", text: "Print", title: "Print" },
                        { type: "separator" }
                     ];
            report_ui_template["report_toolbar_" + active_object_id].loadStruct(menu_json); 
                       
            show_excel_report(active_object_id, 'html', false);
            
            report_ui_template["report_toolbar_" + active_object_id].attachEvent("onClick", function(id){ 
                if (id == 'pdf') {
                    show_excel_report(active_object_id, 'pdf', true);
                } else if (id == 'excel') { 
                    show_excel_report(active_object_id, 'excel', true);
                } else if (id == 'html2') {
                    var confirm_msg = "Would you like to continue ?";
                    
                    confirm_messagebox(confirm_msg, function() {
                            show_excel_report(active_object_id, 'html2', false);
                });
                } 
            });
        }
        /**
         * [Create multiple tabs for Dashboard Report]
         */
        function load_dashboard_report(report_id) {
            report_ui_template["inner_tab_layout_" + report_id].cells('c').progressOn();
            
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
            
            var active_tab_id = report_ui_template.report_ui_tabbar.getActiveTab();
            var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            
            report_ui["dashboard_report_tabs_" + active_object_id] = report_ui_template["inner_tab_layout_" + active_object_id].cells("c").attachTabbar();
            report_ui["dashboard_report_tabs_" + active_object_id].loadStruct(tab_json);
            
            if (inner_active_tab != '')
                report_ui["dashboard_report_tabs_" + active_object_id].tabs(inner_active_tab).setActive();
            
            for (j = 0; j < result_length; j++) {
                var tab_id = 'detail_tab_' + result[j][1]  + result[j][0];
                report_ui_template["report_toolbar_" + active_object_id] = report_ui["dashboard_report_tabs_" + active_object_id].cells(tab_id).attachToolbar();
                report_ui_template["report_toolbar_" + active_object_id].setIconsPath(js_image_path + "dhxtoolbar_web/");
                report_ui_template["report_toolbar_" + active_object_id].loadStruct([
                            { id: "refresh", type: "button", img: "refresh.gif", text: "Refresh", title: "Refresh"}
                ]);
                
                report_ui_template["report_toolbar_" + active_object_id].attachEvent("onClick", function(id){
                    switch(id) {
                        case "refresh":
                            progress_on = 0;
                            var active_tab_id = report_ui_template.report_ui_tabbar.getActiveTab();
                            var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
                            inner_active_tab = report_ui["dashboard_report_tabs_" + active_object_id].getActiveTab();
                            
                            if (undock_state == 0) {
                                var frame_obj = report_ui_template["inner_tab_layout_" + active_object_id].cells('b').getFrame();
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
            var active_tab_id = report_ui_template.report_ui_tabbar.getActiveTab();
            var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            var tab_id = 'detail_tab_' + active_object_id  + result[0][4];
            
            var frame_obj = report_ui_template["inner_tab_layout_" + active_object_id].cells('b').getFrame();
            
            if (typeof (frame_obj.contentWindow.return_as_of_date) === 'function') {
                var as_of_date = frame_obj.contentWindow.return_as_of_date();
            } else {
                var as_of_date = '';
            }
            
            report_ui["dashboard_report_tabs_" + active_object_id].attachEvent("onContentLoaded", function(name){
                report_ui_template["inner_tab_layout_" + active_object_id].cells('c').progressOff();
                
                if (undock_state == 0 && progress_on == 0) {
                    report_ui_template["inner_tab_layout_" + active_object_id].cells('c').undock();
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
        }
        /**
         *
         */
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
        /**
         * [show the custom report when toolbar is clicked]
         */
        function show_report(report_id, export_type, reload_option, undock_opt) {
            var report_type = report_type_arr[report_id];
            if (report_type == 2) {
                var js_php_path = '<?php echo $php_script_loc; ?>';
                if (export_type == 'pdf') {
                    var url = js_php_path + 'dev/spa_pdf.php';
                } else {
                    var url = js_php_path + 'dev/spa_html.php';
                }    
            } else if (report_type == 1 || report_type == 4) {// also for excel addin reports
                var php_path = '<?php echo $app_adiha_loc; ?>';
                var url = php_path + 'adiha.html.forms/_reporting/report_manager_dhx/report.viewer.php';
            }
            
            var active_tab_id = report_ui_template.report_ui_tabbar.getActiveTab();
            var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            var frame_obj = report_ui_template["inner_tab_layout_" + active_object_id].cells("b").getFrame();  

            if (export_type == 'rp') {
                if (report_type == 2) {
                    var active_tab_id = report_ui_template.report_ui_tabbar.getActiveTab();
                    var report_label = report_ui_template.report_ui_tabbar.tabs(active_tab_id).getText();
                    var report_name = report_label.replace(/ /g, '_');
                    
                    var params = frame_obj.contentWindow.report_parameter(false);

                    if (params != false) {
                        var filter_list = params.split('&');
                    var exec_sql = filter_list[0];
                        if(report_name == 'Gas_Storage_Position_Report') {// Pivot case of Gas position report.
                        exec_sql +=',@is_pivot = \'y\'';
                        }
                    parent.report_ui.layout.cells('a').collapse();
                    open_grid_pivot('', report_name, 0, exec_sql, report_label, '', report_id)
                    }                    
                } else if (report_type == 1) {
                    var params = frame_obj.contentWindow.report_parameter(false, 1);
                    if (params) {
                        parent.report_ui.layout.cells('a').collapse();
                        open_pivot_report(params);
                    }
                }
                
            } else { 
                var parameters = frame_obj.contentWindow.report_parameter(false, 2);
                if (parameters != false) {
                    var sec_filters_info = parameters[1];
                    var filter_list = parameters[0].split('&applied_filters=');
                    parameters = filter_list[0];
                    var filters_used = filter_list[1];
                }                

                var applied_filters = '';
                var enable_paging = '';
                var new_paging = '';
                var is_sap_report = '';
                var round_value = '';

                if (parameters != false) {
                    if (report_type == 2) { 
                        url_param = frame_obj.contentWindow.report_parameter(false, 2);
                        // Send report sql and applied filters using post method to prevent url length from exceeding its limit and send rest of the parameters only
                        exec_sql = url_param.split('&')[0];
                        applied_filters = get_url_param('applied_filters', url_param);
                        enable_paging = get_url_param('enable_paging', url_param);
                        new_paging = get_url_param('np', url_param);
                        is_sap_report = get_url_param('is_sap_report', url_param);
                        round_value = get_url_param('rnd', url_param);
                        url += '?report_type=' + report_type; // This param is just to prevent having argument separator right after query string i.e. '?&' in the url and make sure url format is valid

                        if (enable_paging != null) {
                            url += '&enable_paging=' + enable_paging;
                        }
                        if (new_paging != null) {
                            url += '&np=' + new_paging;
                        }
                        if (is_sap_report != null) {
                            url += '&is_sap_report=' + is_sap_report;
                        }
                        if (round_value != null) {
                            url += '&rnd=' + round_value;
                        }                      
                        
                        url += '&session_id=' +  session_id + '&' +  getAppUserName();
                    } else if (report_type == 1 || report_type == 4) {
                        var param1 = parameters.split('&report_filter=');
                        var param2 = param1[1].split('&is_refresh=');                       
                        var param3 = param1[0] + '&is_refresh=' + param2[1];
                        
                        parameters = param3;

                        if (export_type == 'html') {
                            parameters += '&export_type=HTML4.0';
                        } else if (export_type == 'html2') {
                            parameters += '&export_type=SYNC';
                        } else if (export_type == 'pdf') {
                            parameters += '&export_type=PDF';
                        } else if (export_type == 'excel') {
                            parameters += '&export_type=EXCEL';
                        } else if (export_type == 'pivot') {
                            parameters += '&export_type=PIVOT';
                        }
                        url += parameters;
                        url += '&session_id=' +  session_id + '&' +  getAppUserName();
                        
                        if (report_type == 4) {
                            if(export_type == 'pdf2' ) {
                                var sec_filters_info_arr = sec_filters_info.split('_-_');
                                sec_filters_info = sec_filters_info_arr[0];
                                url += '&call_from=excel&excel_sheet_id=' + report_id + '&export_type=' + export_type;
                            } else if(export_type == 'excel2') {
                                var sec_filters_info_arr = sec_filters_info.split('_-_');
                                sec_filters_info = sec_filters_info_arr[0];
                                url += '&call_from=excel&excel_sheet_id=' + report_id + '&export_type=' + export_type;
                            } else {
                                var sec_filters_info_arr = sec_filters_info.split('_-_');
                                sec_filters_info = sec_filters_info_arr[0];
                                url += '&call_from=excel&excel_sheet_id=' + report_id;
                            }
                        }
                    }          
                    
                    if (undock_opt == true) {
                        var post_data = '';
                        if (report_type == 2) {
                            post_data = {'sec_filters_info': sec_filters_info,
                                         'exec': exec_sql};
                        } else {
                            post_data = {'sec_filters_info': sec_filters_info};
                        }
                        open_window_with_post(url, '', post_data);
                        return;
                    }

                    if (export_type == 'excel') { 
                        url += '&writeCSV=true';
                    }

                    if (reload_option == true) { 
                        if (report_type == 2) {
                            data = {'sec_filters_info': sec_filters_info,
                                'applied_filters': applied_filters,                           
                                'exec': exec_sql};
                        } else {
                           data = {'applied_filters': filters_used,'sec_filters_info': sec_filters_info}; 
                        }
                        if (export_type == 'pdf') {
                            open_window_with_post(url, '', data);
                        } else {
                            open_window_with_post(url, '', data);
                        }      
                    } else { 
                        if (export_type == 'html' || export_type == 'html2') {
                            report_ui_template["inner_tab_layout_" + active_object_id].cells("c").progressOn();
                            url += '&close_progress=1';
                        }
                        if (report_type == 2) {
                            report_ui_template["inner_tab_layout_" + active_object_id].cells("c").attachURL(url, null, {
                                    sec_filters_info: sec_filters_info,
                                    applied_filters: applied_filters,
                                    exec: exec_sql
                            });
                        } else {
                            report_ui_template["inner_tab_layout_" + active_object_id].cells("c").attachURL(url, null, {
                                applied_filters: filters_used,
                                sec_filters_info: sec_filters_info
                            });
                        }
                    }         
                    report_ui_template.show_hide_filter(active_object_id, export_type);
                } else {
                    if (undock_opt == true) {
                        return false;
                    }
                }
            }
        }

        function show_excel_report(report_id, export_type, reload_option, undock_opt) {
            var report_type = report_type_arr[report_id];  
                var php_path = '<?php echo $app_adiha_loc; ?>';
                var url = php_path + 'adiha.html.forms/_reporting/report_manager_dhx/report.viewer.php';
                url += '?call_from=excel&excel_sheet_id=' + report_id;

            var active_tab_id = report_ui_template.report_ui_tabbar.getActiveTab();
            var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;

            var frame_obj = report_ui_template["inner_tab_layout_" + active_object_id].cells("b").getFrame();
            var filter_parameters = frame_obj.contentWindow.report_parameter(false, 2);
            if (filter_parameters != false) {
                var sec_filters_info = filter_parameters[1];
            }
            
            var parameters = ''; 

            if (export_type == 'html') {
                parameters += '&export_type=HTML4.0';
            } else if (export_type == 'html2') {
                parameters += '&export_type=SYNC';
            } else if (export_type == 'pdf') {
                parameters += '&export_type=PDF';
            } else if (export_type == 'excel') {
                parameters += '&export_type=EXCEL';
            }
            url += parameters;
                    
            url += '&session_id=' +  session_id + '&' +  getAppUserName();
            
            if (undock_opt == true) {
                return url;
            }

            if (export_type == 'excel') { 
                url += '&writeCSV=true';   

                 $.get(url, function(data){   
                     report_ui_template.print_report(data);
                 });  
                return;
            } 

            if (reload_option == true) {
                if (export_type == 'pdf') {
                    window.location = url; 
                } else {
                    open_window_with_post(url)  
                }      
            } else {
                if (export_type == 'html' || export_type == 'html2') {
                    //report_ui_template["inner_tab_layout_" + active_object_id].cells("c").progressOn();
                    url += '&close_progress=1';
                }
                report_ui_template["inner_tab_layout_" + active_object_id].cells("c").attachURL(url, null, {sec_filters_info: sec_filters_info}); 
            }
            parent.report_ui.layout.cells('a').collapse();
            report_ui_template["inner_tab_layout_" + active_object_id].cells("a").collapse();
            report_ui_template["inner_tab_layout_" + active_object_id].cells("b").collapse();
        }

        function show_power_bi_report(report_id, export_type, reload_option, undock_opt) {
            var report_type = report_type_arr[report_id];
            var report_name = power_bi_reports[report_id];

            var active_tab_id = report_ui_template.report_ui_tabbar.getActiveTab();
            var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            var frame_obj = report_ui_template["inner_tab_layout_" + active_object_id].cells("b").getFrame();

            var parameters = frame_obj.contentWindow.report_parameter(false, 2);
            if (parameters != false) {                
                report_ui_template["inner_tab_layout_" + active_object_id].cells("c").progressOn();
                parent.report_ui.layout.cells('a').collapse();
                report_ui_template["inner_tab_layout_" + active_object_id].cells("a").collapse();
                report_ui_template["inner_tab_layout_" + active_object_id].cells("b").collapse();

                var sec_filters_info = parameters[1];
                var filter_list = parameters[0].split('&applied_filters=');
                parameters = filter_list[0];
                var filters_used = filter_list[1];
            } else {
               var sec_filters_info = 'NULL';
               return false;
            }   

            var sec_filters_info_arr = sec_filters_info.split('_-_');
            sec_filters_info = sec_filters_info_arr[0];

             var data = {
                            "action": "spa_power_bi_report",
                            "flag":'r',
                            "report_filter": sec_filters_info,
                            "power_bi_report_id": report_id,
                            "undock_opt": undock_opt
                        };

            adiha_post_data('return_array', data, '', '', 'show_power_bi_report_post', ''); 
        }

        function show_power_bi_report(report_id, export_type, reload_option, undock_opt) {
            var has_rights_report_manager_powerbi =<?php echo ($has_rights_report_manager_powerbi) ? $has_rights_report_manager_powerbi : '0'; ?>;
            var report_type = report_type_arr[report_id];
            var report_name = power_bi_reports[report_id];

            var active_tab_id = report_ui_template.report_ui_tabbar.getActiveTab();
            var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            var frame_obj = report_ui_template["inner_tab_layout_" + active_object_id].cells("b").getFrame();

            var parameters = frame_obj.contentWindow.report_parameter(false, 2);
            if (parameters != false) {                
                report_ui_template["inner_tab_layout_" + active_object_id].cells("c").progressOn();
                parent.report_ui.layout.cells('a').collapse();
                report_ui_template["inner_tab_layout_" + active_object_id].cells("a").collapse();
                report_ui_template["inner_tab_layout_" + active_object_id].cells("b").collapse();

                var sec_filters_info = parameters[1];
                var filter_list = parameters[0].split('&applied_filters=');
                parameters = filter_list[0];
                var filters_used = filter_list[1];
            } else {
               var sec_filters_info = 'NULL';
               return false;
            }   

            /*var sec_filters_info_arr = sec_filters_info.split('_-_');
            sec_filters_info = sec_filters_info_arr[0];
            */

            var php_path = '<?php echo $app_adiha_loc; ?>';
            var url = php_path + 'adiha.html.forms/_reporting/report_manager_dhx/report.viewer.php';
            url += '?call_from=power_bi&close_progress=1&report_name=' + report_name;

            var post_data = {
                                report_filter: sec_filters_info,
                                power_bi_report_id: report_id,
                                undock_opt: undock_opt,
                                has_rights_report_manager_powerbi: has_rights_report_manager_powerbi
                            };

            if (undock_opt == true || undock_opt == 'true') {
                report_ui_template["inner_tab_layout_" + active_object_id].cells('c').progressOff();                
                open_window_with_post(url, '', post_data);
                /*dhxWins = new dhtmlXWindows();
                var winPB =  dhxWins.createWindow('pb1', 0, 0,$(window).width(), $(window).height());
                winPB.setText(report_name);
                winPB.centerOnScreen();
                winPB.setModal(true);
                winPB.attachURL(url, null, post_data);
                var post_data = {'sec_filters_info': sec_filters_info};
                */
                return;
            }

            report_ui_template["inner_tab_layout_" + active_object_id].cells("c").attachURL(url, null, post_data);

        }

        var pivot_report_window;
        function open_pivot_report(params) {
            if (pivot_report_window != null && pivot_report_window.unload != null) {
                pivot_report_window.unload();
                pivot_report_window = w1 = null;
            }

            if (!pivot_report_window) {
                pivot_report_window = new dhtmlXWindows();
            }

            var win_title = get_locale_value('Pivot') + ' - ' + get_locale_value(params.report_name);
            var win_url = 'view.pivot.report.php';

            var win = pivot_report_window.createWindow('w1', 0, 0, 600, 400);
            win.setText(win_title);
            win.centerOnScreen();
            win.maximize();
            win.attachURL(win_url, false, params);
			
			win.attachEvent("onClose", function(win){
				var active_tab_id = report_ui_template.report_ui_tabbar.getActiveTab();
				var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
				load_pivot_view_menu(active_object_id, 1);
				return true;
			});
        }

        function excel_download(url) {
            location.href = url;
            var active_tab_id = report_ui_template.report_ui_tabbar.getActiveTab();
            var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            report_ui_template["inner_tab_layout_" + active_object_id].cells("c").progressOff();
        }

        function close_progress() {
            var active_tab_id = report_ui_template.report_ui_tabbar.getActiveTab();
            var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            report_ui_template["inner_tab_layout_" + active_object_id].cells("c").progressOff();
        }

        function close_progress_from_excel() {
            var active_tab_id = report_ui_template.report_ui_tabbar.getActiveTab();
            var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            report_ui_template["inner_tab_layout_" + active_object_id].cells("a").progressOff();
        }
        
        function run_batch_standard_report() {
            var active_tab_id = report_ui_template.report_ui_tabbar.getActiveTab();
            var report_name = report_ui_template.report_ui_tabbar.tabs(active_tab_id).getText();
            var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            var frame_obj = report_ui_template["inner_tab_layout_" + active_object_id].cells("b").getFrame();
            
            var exec_call = frame_obj.contentWindow.report_parameter(true);
                        
            if (typeof (frame_obj.contentWindow.return_as_of_date) === 'function') {
                var as_of_date = frame_obj.contentWindow.return_as_of_date();
            } else{
                var as_of_date = todays_date;
            }
            
            if (as_of_date == ''){
                var as_of_date = todays_date;
            }
            
            var gen_as_of_date = (exec_call.indexOf('gen_as_of_date=') == '-1') ? 0 : exec_call.substr(exec_call.indexOf('gen_as_of_date=') + 15, 1);
            
            /**
                    * gen_as_of_date is reset to 0 to hide the As of date Block on Batch Window
                    * As of date logic is handled on report filter after modification done to change 
                    * Calendar Date to Dynamic date.  
            **/
            gen_as_of_date = 0;
            var filter_list = exec_call.split('&');
            exec_call = filter_list[0].replace(/"/g, "'");
           
            if (exec_call != false) {
                var param = 'report_type=standard&call_from=' + report_name + '&gen_as_of_date=' + gen_as_of_date + '&as_of_date=' + as_of_date; 
                adiha_run_batch_process(exec_call, param, report_name);
            }
        }
        
        function run_batch_report_manager() {
            var active_tab_id = report_ui_template.report_ui_tabbar.getActiveTab();
            var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            var frame_obj = report_ui_template["inner_tab_layout_" + active_object_id].cells("b").getFrame();
            
            var report_id = active_object_id;
            var report_name = report_ui_template.report_ui_tabbar.tabs(active_tab_id).getText();
            
            var return_value = frame_obj.contentWindow.report_parameter(true);
            
            if (typeof (frame_obj.contentWindow.return_as_of_date) === 'function') {
                var as_of_date = frame_obj.contentWindow.return_as_of_date();
            } else{
                var as_of_date = todays_date;
            }
            
            if (as_of_date == ''){
                var as_of_date = todays_date;
            }
            
            if (return_value != false) {
                var report_filter = return_value[0];
                
                /*-------------------------------------------*/
                //added to pass the value of as of date from report filter page.
                var filter_array = report_filter.toString().split(',');
                var as_of_date = '';
                
                for (var i = 0; i < filter_array.length; i++) {
                    if (filter_array[i].split('=')[0] == 'as_of_date')
                        as_of_date = filter_array[i].split('=')[1];
                }

                var today_date = new Date();
                as_of_date = (as_of_date != '') ? as_of_date : dates.convert_to_sql(today_date);
                /*-------------------------------------------*/
                
                var items_combined = return_value[1];
                var report_paramset_id = return_value[2];
                var v_paramset_hash = return_value[3];
                var report_path = return_value[4];
                var c_as_of_date = return_value[6];
                var gen_as_of_date = return_value[7];

                /**
                    * gen_as_of_date is reset to 0 to hide the As of date Block on Batch Window
                    * As of date logic is handled on report filter after modification done to change 
                    * Calendar Date to Dynamic date.  
                **/
                gen_as_of_date = 0;

                var is_refresh = 0;
                var export_extension = '<?php echo $export_extension;?>';
                var export_extension_full = '<?php echo $export_extension_full;?>';

                var param = "call_from=Report Batch Job&gen_as_of_date=" + Number(gen_as_of_date) + "&rfx=1&as_of_date=" + c_as_of_date + "&report_paramset_id="+ report_paramset_id + "&paramset_hash=" + v_paramset_hash;
                var rs_additional_cmd = construct_report_export_cmd(report_name, report_path, report_paramset_id, report_filter, items_combined, v_paramset_hash, is_refresh, export_extension, export_extension_full, '_DELIM_', '_IS_HEADER_');//rds_display_combined);
                
                //var cmd_command = 'paramset_id:' + report_paramset_id + ',' + items_combined + ",report_filter:''''" + report_filter + "''''" + ',' +  rs_additional_cmd;
                var cmd_command = "report_filter:''''" + report_filter + "''''" + ',' +  rs_additional_cmd;
                //var exec_call = return_batch_sp_call(cmd_command, report_name, report_name + export_extension);
                var exec_call = return_batch_sp_call(cmd_command, report_path, report_name + export_extension);
                
                adiha_run_batch_process(exec_call, param, report_name);
            }
        }
        //function to batch excel add in reports
        function run_batch_excel_report() {
            var active_tab_id = report_ui_template.report_ui_tabbar.getActiveTab();
            var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            var frame_obj = report_ui_template["inner_tab_layout_" + active_object_id].cells("b").getFrame();
            
            var report_id = active_object_id;
            var report_name = report_ui_template.report_ui_tabbar.tabs(active_tab_id).getText();
            
            var return_value = frame_obj.contentWindow.report_parameter(true);
            
            if (typeof (frame_obj.contentWindow.return_as_of_date) === 'function') {
                var as_of_date = frame_obj.contentWindow.return_as_of_date();
            } else{
                var as_of_date = todays_date;
            }
            
            if (as_of_date == ''){
                var as_of_date = todays_date;
            }
            
            if (return_value != false) {
                var report_filter = return_value[0];
                
                /*-------------------------------------------*/
                //added to pass the value of as of date from report filter page.
                var filter_array = report_filter.toString().split(',');
                var as_of_date = '';
                
                for (var i = 0; i < filter_array.length; i++) {
                    if (filter_array[i].split('=')[0] == 'as_of_date')
                        as_of_date = filter_array[i].split('=')[1];
                }

                var today_date = new Date();
                as_of_date = (as_of_date != '') ? as_of_date : dates.convert_to_sql(today_date);
                /*-------------------------------------------*/
                
                //var items_combined = return_value[1];
                var report_paramset_id = return_value[2];
                //var v_paramset_hash = return_value[3];
                //var report_path = return_value[4];
                //var is_refresh = 0;
                //var export_extension = '<?php echo $export_extension;?>';
                //var export_extension_full = '<?php echo $export_extension_full;?>';

                var param = "call_from=Report Batch Job Excel Addin&batch_type=r&gen_as_of_date=0&rfx=4&as_of_date="+ as_of_date;
                //var rs_additional_cmd = construct_report_export_cmd(report_name, report_path, report_paramset_id, report_filter, items_combined, v_paramset_hash, is_refresh, export_extension, export_extension_full, '_DELIM_', '_IS_HEADER_');//rds_display_combined);
                //var cmd_command = 'paramset_id:' + report_paramset_id + ',' + items_combined + ",report_filter:''''" + report_filter + "''''" + ',' +  rs_additional_cmd;
                //var exec_call = return_batch_sp_call(cmd_command, report_name, report_name + export_extension);
                //var exec_call = return_batch_sp_call(cmd_command, report_path, report_name + export_extension);

                var sp_string = "EXEC spa_rfx_format_filter @flag='f'"
                    + ", @paramset_id='" + report_paramset_id + "'"
                    + ", @parameter_string='" + report_filter + "'"
                    + ", @is_excel_report=1"
                    + ""; 
                var post_data = { sp_string: sp_string };
                
                $.ajax({
                    url: js_form_process_url,
                    data: post_data,
					type: "POST"
                }).done(function(data) {
                    
                    var json_data = JSON.parse(data);					
                    var filter_in_xml = '<Parameters>';
					
                    $.each(json_data.json, function(key, val) {
						// console.log(val);
                        if (val["filter_value"] != null ) {
                            var dyn_cal_val =  val["filter_value"].split('|');
                            if(val['widget_id'] == 6) { // case dynamic date
                                if(dyn_cal_val.length == 1) { /*case static date selected*/
                                   /*added as the new formate doesnot contains dynamic date part when static date is selected */
                                   dyn_cal_val.push(0, 0, "", "n")  
                                } else if(dyn_cal_val.length == 4) { /* case dynamic date selected*/
                                   /* added as the new formate doesnot contain static date as first i.e 45606|0|106400|n*/
                                    dyn_cal_val.unshift(""); 
							}


                            }
                            filter_in_xml += "<Parameter><Name>" + val["filter_name"] + "</Name><Value>" + (val['widget_id'] == '6' ? dyn_cal_val[0] : val["filter_value"].replace(/,/g, "!")) + "</Value><DisplayLabel>" + val["filter_display_label"] + "</DisplayLabel><DisplayValue>" + (val['widget_id'] == '6' ? dyn_cal_val[0] : val["filter_display_value"]) + "</DisplayValue>" + (val['widget_id'] == '6' ? '<OverwriteType>' + dyn_cal_val[1] + '</OverwriteType><AdjustmentDays>' + dyn_cal_val[2] + '</AdjustmentDays><AdjustmentType>' + dyn_cal_val[3] + '</AdjustmentType><BusinessDay>' + dyn_cal_val[4] + '</BusinessDay>' : '') + "</Parameter>";
                        } else {
							filter_in_xml += "<Parameter><Name>" + val["filter_name"] + "</Name><Value>" + (val['filter_value'] == null ? '' : val["filter_value"].replace(/,/g, "!")) + "</Value><DisplayLabel>" + val["filter_display_label"] + "</DisplayLabel><DisplayValue>" + val["filter_display_value"] + "</DisplayValue></Parameter>";
						}
                    });
                    filter_in_xml += "</Parameters>";
                    //console.log(filter_in_xml);return;
                    var exec_call = "EXEC spa_view_report @flag='b', @report_id=" + active_object_id + ", @view_report_filter_xml='" + filter_in_xml + "'";
                    adiha_run_batch_process(exec_call, param, report_name);

                });

                
            }
        }
        /**
         *
         */
        function new_window_report(report_type) {
            var active_tab_id = report_ui_template.report_ui_tabbar.getActiveTab();
            var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            if (glb_pivot_id != '') {
				report_ui_template["inner_tab_layout_" + active_object_id].cells('c').undock(300, 300, 900, 700);
			} else if (report_type == 4) {
                show_excel_report(active_object_id, 'html', true);
                report_ui_template["inner_tab_layout_" + active_object_id].cells('a').progressOff();
            } else if (report_type == 5) {
                show_power_bi_report(active_object_id, 'bi_refresh', true, true);
                report_ui_template["inner_tab_layout_" + active_object_id].cells('a').progressOff();
            } else {
                show_report(active_object_id, 'html', true, true);
                report_ui_template["inner_tab_layout_" + active_object_id].cells('c').progressOff();    
            }       
        }
        
        /**
         *[Function to open deal schedule window]
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
        /**
         * [Function to open detail report for under schedule [deal schedule]
         */
        function sch_under_over_detail_report(warning_type, process_id) {
            var report_name = 'Schedule Detail Report';
            var exec_call = "EXEC spa_view_validation_log 'schedule_detail','" + process_id + "', 's'";
            open_spa_html_window(report_name, exec_call, 500, 1150);
        }

        report_ui_template.print_report = function(data) {
        //printing in same window       
               var iframe = document.createElement('iframe');                
                document.body.appendChild(iframe);
                iframe.contentWindow.document.open(); 
                iframe.contentWindow.document.write('<body onload="window.focus();window.print();">'+data+'</body>');              
                iframe.contentWindow.document.close();  
         }

		/*
        //ajax setup for default values
        $.ajaxSetup({
            method: 'POST',
            dataType: 'json',
            error: function(jqXHR, text_status, error_thrown) {
                console.log('*** Error on ajax: ' + text_status + ', ' + error_thrown);
            }
        });
		*/

        function show_progress_on(){
            var active_tab_id = report_ui_template.report_ui_tabbar.getActiveTab();
            var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            report_ui_template["inner_tab_layout_" + active_object_id].cells("c").progressOn();
        }

        function get_url_param(key, target) {
            var values = [];
            if (!target) target = location.href;

            key = key.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");

            var pattern = key + '=([^&#]+)';
            var o_reg = new RegExp(pattern,'ig');
            while (true) {
                var matches = o_reg.exec(target);
                if (matches && matches[1]) {
                    values.push(matches[1]);
                } else {
                    break;
                }
            }

            if (!values.length) {
                return null;   
            } else {
                return values.length == 1 ? values[0] : values;
            }
        }
		
		pivot_file_name = ''
		generate_pivot_sql = function() {
			var active_tab_id = report_ui_template.report_ui_tabbar.getActiveTab();
            var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
			var frame_obj = report_ui_template["inner_tab_layout_" + active_object_id].cells('b').getFrame();
			var params = frame_obj.contentWindow.report_parameter(false, 1);
			var paramset_id = params.paramset_id;
			var component_id = params.items_combined;
			var criteria = params.report_filter;
			var report_name = params.report_name;
			var d = new Date();
			var file_name = report_name + '_' + d.getTime() + '.csv';
			pivot_file_name = file_name;
			
			var sp_string = "EXEC spa_generate_pivot_file "
                    + "@paramset_id='" + paramset_id + "'"
                    + ", @component_id='" + component_id + "'"
					+ ", @criteria='" + criteria + "'"
					+ ", @file_name='" + file_name + "'"
					+ ", @report_name='" + report_name + "'";
			
			return sp_string;
		}
		
		load_pivot_view = function(view_id) {
            var active_tab_id = report_ui_template.report_ui_tabbar.getActiveTab();
            var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            var frame_obj = report_ui_template["inner_tab_layout_" + active_object_id].cells('b').getFrame();
            var params = frame_obj.contentWindow.report_parameter(false, 1);
            var paramset_id = params.paramset_id;
            var component_id = params.items_combined;
			var sql = generate_pivot_sql();
			var data_sql = {"action": "spa_pivot_report_view", "flag":'1', "view_id":view_id, "paramset_id":paramset_id, "component_id":component_id, "pivot_file_sql": sql}
			adiha_post_data("return_array", data_sql, '', '', 'load_pivot_view_callback');
		}
        
        var PIVOT_VIEW_COL_FORMATTING_INFO = '';
        var PIVOT_VIEW_REPORT_NAME = '';
		load_pivot_view_callback = function(result) {
			var attach_docs = '<?php echo $attach_docs_url_path; ?>';
			var full_file_path = attach_docs.replace('attach_docs', 'temp_Note') + '/' + pivot_file_name;
			var graph_type = '';
			
			var pivot_col_list = {
				detail_columns: '',
				grouping_columns: '',
				rows_columns: '',
				cols_columns: '',
				xaxis:'',
				yaxis:'',
				series:''
			};
			var aggregators = '';
			
			if (result.length == 0) {
				var post_param = {
					file_path: full_file_path,
					report_type: 'mixed',
					renderer_type: 'Table',
					aggregators: 'Sum',
					col_list: JSON.stringify(pivot_col_list)
				};
			} else {
                PIVOT_VIEW_COL_FORMATTING_INFO = JSON.parse(result[0][10]);
                PIVOT_VIEW_REPORT_NAME = result[0][5];
				var renderer = result[0][3];

				if (renderer == 'Table') {
					pivot_col_list['detail_columns'] = (result[0][1] == null) ? '' : result[0][1];
					pivot_col_list['grouping_columns'] = (result[0][0] == null) ? '' : result[0][0];
					aggregators = '';
				} else if (renderer == 'CrossTab Table') {                
					pivot_col_list['rows_columns'] = (result[0][0] == null) ? '' : result[0][0];
					pivot_col_list['cols_columns'] = (result[0][1] == null) ? '' : result[0][1];
					var detail = (result[0][2] == null) ? '' : result[0][2];                

					if (detail != '') {
						var detail_com = detail.split(',');
						var detail_col_arr = new Array();
						var aggregator_arr = new Array();
						for (cnt = 0; cnt < detail_com.length; cnt++) {
							details = detail_com[cnt].split('||||');
							aggregator_arr.push(details[1]);
							detail_col_arr.push(details[0]);
						}
						var aggregator_str = aggregator_arr.toString();
						var detail_col_str = detail_col_arr.toString();
					} else {
						var aggregator_str = '';
						var detail_col_str = '';
					}
					pivot_col_list['detail_columns'] = aggregator_str;
					aggregators = detail_col_str;
				} else {
					pivot_col_list['xaxis'] = (result[0][1] == null) ? '' : result[0][1];

					var detail = (result[0][2] == null) ? '' : result[0][2];

					if (detail != '') {
						var detail_com = detail.split(',');
						var detail_col_arr = new Array();
						var aggregator_arr = new Array();
						var graph_type_arr = new Array();

						for (cnt = 0; cnt < detail_com.length; cnt++) {
							details = detail_com[cnt].split('||||');
							aggregator_arr.push(details[1]);
							detail_col_arr.push(details[0]);

							if (details[2]) graph_type_arr.push(details[2]);
							else graph_type_arr.push('line');
						}
						var aggregator_str = aggregator_arr.toString();
						var detail_col_str = detail_col_arr.toString();
						var graph_type_str = graph_type_arr.toString();
					} else {
						var aggregator_str = '';
						var detail_col_str = '';
						var graph_type_str = '';
					}
					
					pivot_col_list['yaxis'] = aggregator_str;
					aggregators = detail_col_str;
					graph_type = graph_type_str;

					pivot_col_list['series'] = (result[0][0] == null) ? '' : result[0][0];
				}
				
				var post_param = {
					file_path: full_file_path,
					report_type: 'mixed',
					renderer_type: renderer,
					aggregators: aggregators,
					graphType:graph_type,
					col_list: JSON.stringify(pivot_col_list),
                    is_pin:'',
                    call_from: 'pivot_views'
				};
			}
			refresh_pivot_view(post_param);
		}

		refresh_pivot_view = function(params) {   
            
			var active_tab_id = report_ui_template.report_ui_tabbar.getActiveTab();
            var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
			parent.report_ui.layout.cells('a').collapse();
			report_ui_template.show_hide_filter(active_object_id, 'html');
            var url = js_php_path + 'pivot.template.php?pivot_view_mode=true&active_tab_id=' + active_object_id;
			report_ui_template["inner_tab_layout_" + active_object_id].cells("c").attachURL(url, true, params);
			report_ui_template["inner_tab_layout_" + active_object_id].cells("c").progressOff();
        }
        
        report_ui_template.fx_get_label_pivot_views = function(id, name) {
            var return_val = name;
			if (PIVOT_VIEW_COL_FORMATTING_INFO != null) {
				$.each(PIVOT_VIEW_COL_FORMATTING_INFO, function(ind, val) {
					if(val.columns_name == name) {
						return_val = val.label;
					}
				});
			}
            return return_val;
        };
		
		report_ui_template.fx_get_formatted_value_pivot_views = function(id, value, name) {
			var return_val = value;
			var start_format = 0;
			
			var render_as = '';
			var date_fmt = '';
			var currency = '';
			var thou_sep = '';
			var rounding = '';
			var neg_as_red = '';

			if (PIVOT_VIEW_COL_FORMATTING_INFO != null) {
				$.each(PIVOT_VIEW_COL_FORMATTING_INFO, function(ind, val) {
					if(val.columns_name == name) {
						start_format =  1;
						render_as = val.render_as;
						date_fmt = val.date_format;
						currency = val.currency;
						thou_sep = val.thou_sep;
						rounding = val.rounding;
						neg_as_red = val.neg_as_red;
					}
				});
			}

			var is_hyperlink = is_column_pivot_hyperlink(name);
			if (start_format == 0 && is_hyperlink == true) {
					render_as = 'h';
					start_format = 1;
			}
			
			if (render_as == null) { render_as = ''; }
			if (date_fmt == null) { date_fmt = ''; }
			if (currency == null) { currency = ''; }
			if (thou_sep == null) { thou_sep = ''; }
			if (rounding == null) { date_fmt = ''; }
			if (date_fmt == null) { date_fmt = ''; }
			
			if (start_format == 1) {
				if (render_as != '') {
					if (render_as == 'n' || render_as == 'p' || render_as == 'c' || render_as == 'a' || render_as == 'v' || render_as == 'r') {
						var sep = (thou_sep == 'n') ? '' : global_group_separator;

						if (thou_sep != '' && rounding != '') {
							var val1 = value.replaceAll(',','');
							var re = /,(?=[\d,]*\.\d{2}\b)/;
							if (sep == '') {
								val1 = val1.replace(re, '');							
							}
							return_val = $.number(val1, rounding, global_decimal_separator, sep);
						} else if (rounding != '') {
                            var val1 = value.replaceAll(',','');
							return_val = $.number(val1, rounding, global_decimal_separator, sep);
						} else if (thou_sep !== '') {
							var val1 = value;
                            var val1 = value.replaceAll(',','');
							var re = /,(?=[\d,]*\.\d{2}\b)/;
							if (sep == '') {
								val1 = val1.replace(re, '');
							}
							return_val = $.number(val1, '', global_decimal_separator, sep);
						} else {
                            var val1 = value.replaceAll(',','');
							return_val = $.number(val1, '', global_decimal_separator, sep);
						}
						
						value = value.toString();
						return_val = return_val.toString();
						
						if (neg_as_red == 'y') {
							if (value.indexOf('-') != -1) {
								if (currency != '') {
									return_val = '<span style="color:red !important">' + currency + return_val.replace('-', '') + '</span>';
								} else {
									return_val =  '<span style="color:red !important">' + return_val.replace('-', '') + '</span>';
								}
							} else {
								if (currency != '') {
									return_val = currency + '' + return_val
								}
							}
						} else if (neg_as_red == 'a') {
							if (value.indexOf('-') != -1) {
								if (currency != '') {
									return_val = currency + return_val.replace('-', '');
								} else {
									return_val =  return_val.replace('-', '');
								}
							} else {
								if (currency != '') {
									return_val = currency + '' + return_val
								}
							}
						} else {
							if (currency != '') {
								if (value.indexOf('-') != -1) {
									return_val = return_val.replace('-', '-' + currency)
								} else {
								   return_val = currency + '' + return_val;	
								}
							} else {
								return_val = return_val
							}
						}		

						if (render_as == 'p') {
							return_val = return_val + '%';
						}
						
					} else if (render_as == 'h') {
						var hyperlink = build_column_as_pivot_hyperlink(name, return_val);
						
						return_val = hyperlink;
					} else if (render_as == 't') {
						return_val = value;
					} else if (render_as == 'd') {
						
						if (date_fmt != '')
							return_val = $.format.date(dates.convert(value), date_fmt)
						else 
							return_val = value;
					}	
				} else {
					return_val = value;
				}
			} else {
				return_val = value;
			}
			return return_val;
		}
		
		report_ui_template.fx_get_xaxis_label_pivot_views = function(id, name) {
			var return_val = '';
			if (PIVOT_VIEW_COL_FORMATTING_INFO != null) {
				$.each(PIVOT_VIEW_COL_FORMATTING_INFO, function(ind, val) {
					if(ind == 1) {
						return_val = (val.xaxis_label != 'undefined' || val.xaxis_label != '')? '' : val.yaxis_label;
					}
				});
			}
            return return_val;
        };
		
		report_ui_template.fx_get_yaxis_label_pivot_views = function() {
            var return_val = '';
			if (PIVOT_VIEW_COL_FORMATTING_INFO != null) {
				$.each(PIVOT_VIEW_COL_FORMATTING_INFO, function(ind, val) {
					if(ind == 1) {
						return_val = (val.yaxis_label != 'undefined' || val.yaxis_label != '')? '' : val.yaxis_label;
					}
				});
			}
            return return_val;
        };
		
		report_ui_template.fx_get_report_label_pivot_views = function() {
            var return_val = '';
            return_val = (PIVOT_VIEW_REPORT_NAME != 'undefined' || PIVOT_VIEW_REPORT_NAME != '' ||PIVOT_VIEW_REPORT_NAME != null)? PIVOT_VIEW_REPORT_NAME : '' ;
            return return_val;
        };

    </script>