<?php
/**
* View report screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
<body>
    <?php 
    $mode = strtolower(get_sanitized_value($_GET['mode'] ?? 'view_report'));
    $form_name = 'form_maintain_static_data';
    $php_script_loc = $app_php_script_loc;
    $app_user_loc = $app_user_name;
    
    if ($mode == 'document_generation') {
        $title = 'Documents';
    } else if ($mode == 'calculation_engine') {
        $title = 'Calculation Process';
    } else if ($mode == 'run_process') {
        $title = 'Process';
    } else if ($mode == 'data_export') {
        $title = 'Export';
    } else {
        $title = 'Reports';
    }

    $form_namespace = 'report_ui';
    $json = '[
                {
                    id:             "a",
                    text:           "' . $title . '",
                    header:         true,
                    collapse:       false,
                    width:          300
                },
                {
                    id:             "b",
                    text:           "Criteria",
                    header:         false
                }

            ]';
    $key_prefix = 'RptList';     
    $report_layout_obj = new AdihaLayout();
    echo $report_layout_obj->init_layout('layout', '', '2U', $json, $form_namespace);
    $grid_name = 'report_grid';
    echo $report_layout_obj->attach_grid_cell($grid_name, 'a');
	echo $report_layout_obj->attach_status_bar('a', true, '');
    $grid_obj = new GridTable('report_ui');
	echo $grid_obj->init_grid_table($grid_name, $form_namespace, 'n');
	echo $grid_obj->set_search_filter(true);
	echo $grid_obj->enable_paging('100', 'pagingArea_a', true);
	echo $grid_obj->return_init('','true,true,true,true,false,true');

    if ($mode == 'view_report') {
        $grid_sql = "EXEC spa_view_report @flag='s',@product_category=$farrms_product_id";
        $url = $app_adiha_loc . 'adiha.html.forms/_reporting/view_report/view.report.template.php';
    } else {
        $key_prefix = $key_prefix . '_' . $mode;     
        $grid_sql = "EXEC spa_view_report @flag='s',@product_category=$farrms_product_id,@call_from='$mode'";
        $url = $app_adiha_loc . 'adiha.html.forms/_reporting/view_report/view.report.template.php?mode=' . $mode;
    }

	echo $grid_obj->load_grid_data($grid_sql,'',false,'',$farrms_product_id,'',$key_prefix,'s');  //RptList for Reporting Menu. It is case sensitve.
    echo $grid_obj->attach_event('', 'onRowDblClicked', $form_namespace . '.report_click');
    echo $grid_obj->attach_event('', 'onRowSelect', $form_namespace . '.report_select');
    echo $grid_obj->attach_event('', 'onXLE', $form_namespace . '.report_load');     
    echo $report_layout_obj->attach_url('b', $url);
    //Attached event onContentLoaded to excute after layout load completed
    echo $report_layout_obj->attach_event('', 'onContentLoaded', 'on_content_loaded');
    $menu_json = '[
        {id: "refresh", text: "Refresh", img: "refresh.gif", img_disabled: "refresh_dis.gif", enabled: true},
		{id:"expand_collapse", text:"Expand/Collapse", img:"exp_col.gif", imgdis:"exp_col_dis.gif", enabled: 1},        
    ]';
    
    echo $report_layout_obj->attach_menu_layout_cell('left_menu', 'a', $menu_json, $form_namespace.'.menu_click');
    echo $report_layout_obj->close_layout();
    
    //To open measurement report directly
    $report_id = get_sanitized_value($_POST['report_id'] ?? 'false');
    $flag = get_sanitized_value($_POST['flag'] ?? '0');
    $report_name = get_sanitized_value($_POST['report_name'] ?? '');
    $link_id = get_sanitized_value($_POST['link_id'] ?? '0');
    $strategy_id = get_sanitized_value($_POST['strategy_id'] ?? '0');
    $subsidiary_id = get_sanitized_value($_POST['subsidiary_id'] ?? '0');
    $book_id = get_sanitized_value($_POST['book_id'] ?? '0');
    $book_structure_text = get_sanitized_value($_POST['book_structure_text'] ?? '0');
    $effective_date_to = get_sanitized_value($_POST['effective_date_to'] ?? '0');
    $get_report_param_id = get_sanitized_value($_POST['report_param_id'] ?? '');
    $get_report_type = get_sanitized_value($_POST['report_type'] ?? '2');
    $call_from = get_sanitized_value($_POST['call_from'] ?? 'report_manager_dhx');
    $effective_date_from = get_sanitized_value($_POST['effective_date_from'] ?? '');
    $link_id_from = get_sanitized_value($_POST['link_id_from'] ?? '');
    $link_id_to = get_sanitized_value($_POST['link_id_to'] ?? '');
    ?> 
    
    <div id="report_context_menu" style="display: none;">
        <div id="pin_my_report" text="Pin to My Report"></div>
		<div id="unpin_my_report" text="Unpin from My Report"></div>
    </div>
    
    <style>
       html, body {
           width: 100%;
           height: 100%;
           margin: 0px;
           padding:0px;
           overflow: hidden;
       }
    </style>
    
    <script type="text/javascript">  
        var dhx_wins = new dhtmlXWindows();
        var report_id = <?php echo $report_id;?>;
        var post_data = '';
        var mode = '<?php echo $mode; ?>';

        //To open measurement report directly from Designation of Hedge
        var flag = '<?php echo $flag;?>';
        var report_name = '<?php echo $report_name;?>';
        var link_id = '<?php echo $link_id;?>';
        var strategy_id = '<?php echo $strategy_id;?>';
        var subsidiary_id = '<?php echo $subsidiary_id;?>';
        var book_id = '<?php echo $book_id;?>';
        var book_structure_text = '<?php echo $book_structure_text;?>';
        var effective_date_to = '<?php echo $effective_date_to; ?>';
        var get_report_type = '<?php echo $get_report_type; ?>';
        var get_report_param_id = '<?php echo $get_report_param_id; ?>';
        var call_from = '<?php echo $call_from;?>';
		var expand_state = 0;
        var link_id_from = '<?php echo $link_id_from; ?>';
        var link_id_to = '<?php echo $link_id_to; ?>';
        var effective_date_from = '<?php echo $effective_date_from; ?>';

        /**
         * Load reprot details
         */
        function on_content_loaded() {
            if (flag == 1) {
                report_ui.layout.cells("a").collapse();
                var frame_obj = report_ui.layout.cells("b").getFrame();
                
                frame_obj.contentWindow.report_ui_template.load_report_detail(report_id, report_name, get_report_type, get_report_param_id, call_from, link_id, strategy_id, subsidiary_id, book_id, book_structure_text, effective_date_to);
            } else if (flag == 2) {
                report_ui.layout.cells("a").collapse();
                var frame_obj = report_ui.layout.cells("b").getFrame();
                frame_obj.contentWindow.report_ui_template.load_report_detail(report_id,report_name, 1, get_report_param_id, "rec_match_report", "", "", "", "", "",effective_date_to,"",effective_date_from,link_id_from, link_id_to);
            }
        }

        /**
         * [Function to load context menu in the report]
         */
        $(function() {
            report_ui.layout.cells("a").showHeader();
            var attached_grid = report_ui.layout.cells('a').getAttachedObject();
            
            context_menu = new dhtmlXMenuObject();
			context_menu.renderAsContextMenu();
			
			context_menu.loadFromHTML("report_context_menu", false);
			
			var row_id;
            attached_grid.attachEvent("onBeforeContextMenu", function(rowId,celInd,grid){
				var tree_level = report_ui.report_grid.getLevel(rowId);
				if (report_ui.report_grid.hasChildren(rowId)) {
					return false;
				}
				
				var parent_id = report_ui.report_grid.getParentId(rowId);
				var parent_category = report_ui.report_grid.cells(parent_id, '0').getValue();
				
				if (parent_category == 'My Reports') {
					context_menu.hideItem('pin_my_report');
					context_menu.showItem('unpin_my_report');
				} else {
					context_menu.hideItem('unpin_my_report');
					context_menu.showItem('pin_my_report');
				}
				row_id = rowId;
				return true;
			});
			
			context_menu.attachEvent("onClick", function(menuitemId, zoneId) {
				switch (menuitemId) {
					case 'pin_my_report':
						pin_to_my_report(row_id);
						break;
					case 'unpin_my_report':
						unpin_to_my_report(row_id);
						break;
				}
			});
			attached_grid.enableContextMenu(context_menu);

            // Change Column Names for Different Excel Modes
            if (mode == 'document_generation') {
                report_ui.report_grid.setColLabel(0, get_locale_value("Document Name"));
                report_ui.report_grid.setColLabel(1, get_locale_value("Document ID"));
                report_ui.report_grid.setColLabel(2, get_locale_value("Document Type"));
            } else if (mode == 'calculation_engine') {
                report_ui.report_grid.setColLabel(0, get_locale_value("Calculation"));
                report_ui.report_grid.setColLabel(1, get_locale_value("Calculation ID"));
                report_ui.report_grid.setColLabel(2, get_locale_value("Calculation Type"));
            } else if (mode == 'run_process') {
                report_ui.report_grid.setColLabel(0, get_locale_value("Process"));
                report_ui.report_grid.setColLabel(1, get_locale_value("Process ID"));
                report_ui.report_grid.setColLabel(2, get_locale_value("Process Type"));
            } else if (mode == 'data_export') {
                report_ui.report_grid.setColLabel(0, get_locale_value("Export"));
                report_ui.report_grid.setColLabel(1, get_locale_value("Export ID"));
                report_ui.report_grid.setColLabel(2, get_locale_value("Export Type"));
            }
        });
        
        /**
         * [Function to pin report to My Report]
         */
        pin_to_my_report = function(row_id) {
            grid_report_id = report_ui.report_grid.cells(row_id, '1').getValue();
            grid_report_name = report_ui.report_grid.cells(row_id, '0').getValue();
            grid_report_type = report_ui.report_grid.cells(row_id, '2').getValue();
            paramset_id = report_ui.report_grid.cells(row_id, '3').getValue();
            
            data = {"action": "spa_view_report",
                        "flag": "p",
                        "report_id": grid_report_id,
                        "report_type": grid_report_type,
                        "report_param_id": paramset_id
                     };

            adiha_post_data('alert', data, '', '', 'add_to_my_report', '');
        }
        
        function add_to_my_report(result) {
            var response = result[0].errorcode;
            
            if (response == 'Success') {
                fx_refresh_tree();
            }
        }
        
        /**
         * [Function to unpin report from My Report]
         */
        unpin_to_my_report = function(row_id) {
            grid_report_id = report_ui.report_grid.cells(row_id, '1').getValue();
            grid_report_name = report_ui.report_grid.cells(row_id, '0').getValue();
            grid_report_type = report_ui.report_grid.cells(row_id, '2').getValue();
            paramset_id = report_ui.report_grid.cells(row_id, '3').getValue();
            grid_row_id = row_id;
            
            data = {"action": "spa_view_report",
                        "flag": "d",
                        "report_id": grid_report_id,
                        "report_type": grid_report_type,
                        "report_param_id": paramset_id
                    };

            adiha_post_data('alert', data, '', '', 'fx_refresh_tree', '');
        }
        
        /**
         * [Double click function when accordion grid is clicked]
         */
        report_ui.report_click = function(r_id, col_id) {
            var tree_level = report_ui.report_grid.getLevel(r_id);
			if (report_ui.report_grid.hasChildren(r_id)) {
				var state = report_ui.report_grid.getOpenState(r_id);
            
				if (state)
					report_ui.report_grid.closeItem(r_id);
				else
					report_ui.report_grid.openItem(r_id);
			} else {
				var report_id = report_ui.report_grid.cells(r_id, '1').getValue();
				var report_name = report_ui.report_grid.cells(r_id, '0').getValue();
				var report_type = report_ui.report_grid.cells(r_id, '2').getValue();
				var report_param_id = report_ui.report_grid.cells(r_id, '3').getValue();

                var report_unique_identifier = report_ui.report_grid.cells(r_id, '4').getValue();

                if(report_type == 4 && report_param_id == 0) {
                    show_messagebox("Error on Report");
                    return;
                }

				var frame_obj = report_ui.layout.cells("b").getFrame();
				frame_obj.contentWindow.report_ui_template.load_report_detail(report_id, report_name, report_type, report_param_id, 'report_manager_dhx','','','','','','',report_unique_identifier);
			}
        }
        /** Function for left menu click
         *
         */
        report_ui.menu_click = function(name, value) {
            if (name == 'refresh') {
                fx_refresh_tree();
            }
			if (name == 'expand_collapse'){
				fx_expand_collapse_tree();
			}
        }
        
        fx_refresh_tree = function() {
            var product_category = <?php echo $farrms_product_id; ?>;
            var key_prefix = '<?php echo $key_prefix; ?>';
            
            if (mode == 'view_report') {
                var param = {
                    'action': 'spa_view_report',
                    'grid_type': 'tg',
                    'grouping_column': 'report_category,report_name',
                    'flag': 's',
                    'product_category': product_category,
                    'key_prefix': key_prefix,
                    'key_suffix': 's'
                };
            } else {
                var param = {
                    'action': 'spa_view_report',
                    'grid_type': 'tg',
                    'grouping_column': 'report_category,report_name',
                    'flag': 's',
                    'product_category': product_category,
                    'call_from' : mode,
                    'key_prefix': key_prefix,
                    'key_suffix': 's'
                };
            }

            var tree_obj = report_ui.report_grid;
            tree_obj.deleteChildItems(0);
            tree_obj.clearAll(); 
            param = $.param(param);
            
            var data_url = js_data_collector_url + '&' + param;
            tree_obj.loadXML(data_url, function() {
                // tree_obj.getFilterElement(0).value = '';
                tree_obj.filterBy(0,'');
                tree_obj.filterByAll();
            });
        }
		
		fx_expand_collapse_tree = function() {
			var product_category = <?php echo $farrms_product_id; ?>;
            var param = {
                'action': 'spa_view_report',
                'grid_type': 'tg',
                'grouping_column': 'report_category,report_name',
                'flag': 's',
                'call_from' : mode,
                'product_category': product_category
            };
            var tree_obj = report_ui.report_grid;
            tree_obj.deleteChildItems(0);
            tree_obj.clearAll(); 
            param = $.param(param);
            var data_url = js_data_collector_url + '&' + param;
            tree_obj.loadXML(data_url, function() {
				if (expand_state == 0) {
                    tree_obj.expandAll();
                    expand_state = 1;
                } else {
                    tree_obj.collapseAll();
                    expand_state = 0;
                }
				tree_obj.filterBy(0,'');
                tree_obj.filterByAll();
            });
		
		}
        
        //function on grid row select
        report_ui.report_select = function(r_id, col_id) {
            var paramset_id = report_ui.report_grid.cells(r_id, '3').getValue();
            var parent_id = report_ui.report_grid.getParentId(r_id);
        }

        function remove_from_my_report() {
            report_ui.report_grid.deleteRow(grid_row_id);
        }
        
         /**
         * [load function when accordion grid is Loaded]
         */
        report_ui.report_load = function(grid_obj,count) {
            var image_full_path = js_image_path + "dhxmenu_web/excel.gif";
            var image_full_path_bi = js_image_path + "dhxmenu_web/powerBI.gif";
            grid_obj.forEachRow(function(id){
                var report_type = grid_obj.cells(id, '2').getValue();
                if (report_type == 4) {                    
                    grid_obj.setItemImage(id, image_full_path);
                } else if (report_type == 5) {
                    grid_obj.setItemImage(id, image_full_path_bi);
                }

                level = grid_obj.getLevel(id);
                if ((mode == 'run_process' || mode == 'data_export') && level == 0) {
                    grid_obj.setRowHidden(id,true);
                } else if ((mode == 'run_process' || mode == 'data_export') && level != 0) {
                    grid_obj.moveRow(id, 'row_sibling');
                }
            });   
        }
        
        //ajax setup for default values
        $.ajaxSetup({
            method: 'POST',
            dataType: 'json',
            error: function(jqXHR, text_status, error_thrown) {
                console.log('*** Error on ajax: ' + text_status + ', ' + error_thrown);
            }
        });
        
    </script> 
