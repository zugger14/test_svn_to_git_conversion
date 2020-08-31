<?php
/**
* Dashboard manager screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
</head>
    <?php
    include '../../../../adiha.php.scripts/components/include.file.v3.php';
	$right_dashboard_manager = 10163200;
	$right_dashboard_manager_iu = 10163210;
	
	list (
		$has_right_dashboard_manager,
		$has_right_dashboard_manager_iu
	) = build_security_rights(
		$right_dashboard_manager,
	    $right_dashboard_manager_iu);
		 
	$php_script_loc = $app_php_script_loc;
    $img_rel_loc = $app_php_script_loc;
    $img_rel_loc .= 'adiha_pm_html/process_controls/radio_img/';
    $form_name = 'form_power_schedule_dash_board';
    
    $layout_json = '[
                        {id: "a", text: "Filters", header: true, height:100},
                        {id: "b", text: "Dispatch Cost Evaluator", header: true, undock: true}
                    ]';
    $layout_obj = new AdihaLayout();
    $filter_form_obj = new AdihaForm();
    
    $form_namespace = 'dashboard_manager';
    
    echo $layout_obj->init_layout('dashboard_manger_layout', '', '2E', $layout_json, $form_namespace);

    $menu_name = 'dashboard_menu';
    $menu_json = '[
            {id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif"},
            {id:"export", text:"Export", img:"export.gif", imgdis:"export_dis.gif", enabled:false,items:[
                {id:"excel", text:"Excel", img:"excel.gif"},
                {id:"pdf", text:"PDF", img:"pdf.gif"}
            ]},
            {id:"solver", text:"Solver", img:"process.gif", imgdis:"process_dis.gif",enabled:"'.$has_right_dashboard_manager_iu.'"},
            {id:"calc", text:"LT Solver", img:"run.gif", imgdis:"run_dis.gif",enabled:"'.$has_right_dashboard_manager_iu.'"},
            {id:"action", text:"Action", img:"action.gif", imgdis:"action_dis.gif",enabled:false,items:[
                {id:"save", text:"Save", img:"save.gif", imgdis:"save_dis.gif",enabled:"'.$has_right_dashboard_manager_iu.'"},
                {id:"save_snapshot", text:"Save Snapshot", img:"save.gif", imgdis:"save_dis.gif",enabled:"'.$has_right_dashboard_manager_iu.'"}
            ]},
            {id:"view", text:"View", img:"view.gif", imgdis:"view_dis.gif",enabled:false,items:[
                {id:"summary", text:"Summary", img:"audit.gif", imgdis:"audit_dis.gif"},
                {id:"basecase", text:"Base Case", img:"select_unselect.gif", imgdis:"select_unselect_dis.gif"},
                {id:"snapshot", text:"Snapshot", img:"select_unselect.gif", imgdis:"select_unselect_dis.gif"}
            ]},
            {id:"undo", text:"Undo", img:"undo.gif", imgdis:"undo_dis.gif",enabled:false},
            {id:"expand_collapse", text:"Expand/Collapse", img:"exp_col.gif", imgdis:"exp_col_dis.gif",enabled:false}
            ]';

    echo $layout_obj->attach_menu_layout_cell($menu_name, 'b', $menu_json, $form_namespace.'.menu_click');
        
    $filter_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10163200', @template_name='DashboardManager', @group_name='General'";
    $filter_arr = readXMLURL2($filter_sql);
    $form_json = $filter_arr[0]['form_json'];
    
    $form_name = 'filters_form';
    echo $layout_obj->attach_form($form_name, 'a');
    $filter_form_obj->init_by_attach($form_name, $form_namespace);
    echo $filter_form_obj->load_form($form_json);
    echo $layout_obj->close_layout();
    ?>
    
    <script type="text/javascript">
        var php_path = '<?php echo $app_php_script_loc; ?>';
        var form_name = '<?php echo $form_name; ?>';
		var has_right_dashboard_manager = <?php echo (($has_right_dashboard_manager) ? $has_right_dashboard_manager : '0');?>;
        var has_right_dashboard_manager_iu = <?php echo (($has_right_dashboard_manager_iu) ? $has_right_dashboard_manager_iu : '0');?>;
        var online_cell_value = new Array();
        var changed_cell_value = new Array();
        var solver_result_color = '#E1EBE7';
        var total_row_color = '#FCFCC5';
        var what_if_row_color = '#C4F0FF';
        var negative_value_color = '#FF0303';
        var changed_for_undo = new Array();
        var online_index = new Array();
        var what_if_index;
        var client_date_format = '<?php echo $date_format; ?>';
        var dst_arr = new Array();
        var expand_collapse_state = 1;
        
        $(function(){
            var dashboard_data = {
                                    "action": "spa_process_power_dashboard",
                                    "flag": "d"
                                 }
            
            adiha_post_data('return_array', dashboard_data, '', '', 'load_dst_values', '', '');
        });
        
        function load_dst_values(result) {
            dst_arr = result
        }
        
        /*
         * [Menu click function]
         */
        dashboard_manager.menu_click = function (id) {
            switch(id) {
                case "refresh":
                    dashboard_manager_refresh();
                    break;
                case "pdf":
                    dashboard_grid.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                    break;
                case "excel":
                    dashboard_grid.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                    break;
                case "solver":
                    dashboard_solver();
                    break;
                case "save":
                    dashboard_save();
                    break;
                case "undo":
                    dashboard_grid.doUndo();
                    break;
                case "calc":
                    dashboard_grid_calc();
                    break;
                case "summary":
                    dashboard_grid_summary();
                    break;
                case "basecase":
                    dashboard_basecase_grid('basecase', '');
                    break;
                case "expand_collapse":
                    dashboard_expand_collapse();
                    break;
                case "save_snapshot":
                    dashboard_snapshot_popup('save_snapshot');
                    break;
                case "snapshot":
                    dashboard_snapshot_popup('snapshot');
                    break;
                default:
                    break;
            }
        }
        
        
        /*
         * [Dashboard Grid refresh function]
         */
        function dashboard_manager_refresh() {
            changed_cell_value = [];
			online_cell_value = [];
			changed_for_undo = [];
			online_index = [];
		
            dashboard_manager.dashboard_manger_layout.cells('a').collapse();
            dashboard_manager.dashboard_manger_layout.cells('b').progressOn();
                                                            
            var term_start = dashboard_manager.filters_form.getItemValue('term_start');
            var current_hour = dashboard_manager.filters_form.getItemValue('current_hour');
            var next_hour = dashboard_manager.filters_form.getItemValue('next_hour');
            
            col_header1 = 'Group/Category/Gen,process_id,process_row_id,id';
            col_header2 = '#rspan,#rspan,#rspan,#rspan';
            col_visibility = 'fase,true,true,true';
            col_type = 'tree,ro,ro,ro';
            col_width = '250,0,0,ro';
            col_width1 = '250,0,0,0';
            col_align = '"text-align:left;","text-align:center;","text-align:center;","text-align:center;"';
            align = "left,center,center,center";
            
            var pre_date = '';
            var now_date = term_start;
            var hours = current_hour;
            for (cnt = current_hour; cnt < parseInt(current_hour)+parseInt(next_hour); cnt++) {
                if (hours % 25 == 0) {
                    hours = 1;
                    var added_date = new Date(now_date);
                    added_date = new Date(added_date.getFullYear(), added_date.getMonth(), added_date.getDate()+1);
                    now_date = dates.convert_to_sql(added_date);
                }
                
                if (dates.convert_to_sql(pre_date) == dates.convert_to_sql(now_date)) {
                    col_header1 += ',#cspan';
                } else {
                    col_header1 += ',' + dates.convert_to_sql(now_date);
                    pre_date = now_date;
                }
                
                col_header2 += ',' + hours;
                col_visibility += ',fase';
                col_type += ',ed[=sum]';
                col_width += ',55';
                col_width1 += ',*';
                col_align += ',"text-align:center;"';
                align +=',center';
                
                for(dcnt = 0; dcnt < dst_arr.length; dcnt++) {
                    if (dates.convert_to_sql(dst_arr[dcnt][0]) == dates.convert_to_sql(now_date) && hours == 3) {
                        col_header2 += ',' + hours + '-DST';
                        col_header1 += ',#cspan';
                        col_visibility += ',fase';
                        col_type += ',ed[=sum]';
                        col_width += ',55';
                        col_width1 += ',*';
                        col_align += ',"text-align:center;"';
                        align +=',center';
                    }
                }
                hours++;
            }
            
            col_header2 = jQuery.parseJSON('["' + col_header2.replace(/,/g, '", "') + '"]');
            col_align = jQuery.parseJSON('[' + col_align + ']');
            
            dashboard_grid = dashboard_manager.dashboard_manger_layout.cells('b').attachGrid();
            dashboard_grid.setImagePath(js_image_path + "dhxgrid_web/");
            dashboard_grid.setHeader(col_header1, null, col_align);
			dashboard_grid.attachHeader(col_header2, col_align);
            dashboard_grid.setColumnsVisibility(col_visibility);
            dashboard_grid.setColAlign(align);
			dashboard_grid.setColumnMinWidth(col_width);
            dashboard_grid.setInitWidths(col_width1);
			dashboard_grid.setColTypes(col_type);
            dashboard_grid.enableTreeCellEdit(false)
            dashboard_grid.init();
            dashboard_grid.enableUndoRedo();
            dashboard_grid.enableBlockSelection();
            dashboard_grid.enableEditEvents(true,false,true);
            dashboard_grid.attachEvent("onCellChanged", dashboard_grid_cell_changed);
            dashboard_grid.attachEvent("onEditCell", dashboard_grid_cell_edit);
            dashboard_grid.attachEvent("onRowDblClicked", dashboard_grid_db_click);
            dashboard_grid.attachEvent("onUndo", dashboard_undo);
            dashboard_grid.attachEvent("onHeaderClick", function(ind,obj){
                dashboard_grid.clearSelection();
            });
            dashboard_grid.attachEvent("onBlockSelected", block_select_function);
            
            term_start = dashboard_manager.filters_form.getItemValue('term_start', true);
            var flag = 's';
            var dashboard_data = {
                                    "action": "spa_process_power_dashboard",
                                    "flag": flag,
                                    "term_start": term_start,
                                    "hr_start": current_hour-1,
                                    "hr_no": next_hour,
                                    "grid_type":"tg",
                                    "grouping_column":"group,group2,deal_id"
                                 }
            
            dashboard_data = $.param(dashboard_data);
            var dashboard_data_url = js_data_collector_url + "&" + dashboard_data;
            dashboard_grid.loadXML(dashboard_data_url, dashboard_manager_refresh_callback);
            dashboard_manager.dashboard_menu.setItemEnabled('export');
			if (has_right_dashboard_manager_iu){
			dashboard_manager.dashboard_menu.setItemEnabled('save');
			dashboard_manager.dashboard_menu.setItemEnabled('solver');
			dashboard_manager.dashboard_menu.setItemEnabled('calc');
			dashboard_manager.dashboard_menu.setItemEnabled('snapshot');
			dashboard_manager.dashboard_menu.setItemEnabled('save_snapshot');
			}
            dashboard_manager.dashboard_menu.setItemEnabled('action');
            dashboard_manager.dashboard_menu.setItemEnabled('undo');
            dashboard_manager.dashboard_menu.setItemEnabled('view');
            dashboard_manager.dashboard_menu.setItemEnabled('expand_collapse');
            expand_collapse_state = 1;
        }
        
        
        /*
         * [grid onload function]
         * Set the color of the row, make the required grid editable, calculate the required formula, clear the cell values.
         */
        function dashboard_manager_refresh_callback() {
            dashboard_grid.expandAll();
            var no_of_rows = dashboard_grid.getRowsNum();
            
            dashboard_grid.forEachRow(function(id){
                var tree_level = dashboard_grid.getLevel(id);
                
                if (tree_level == 0) {
                    if (id.toLowerCase() == 'onlinestatus' || id.toLowerCase() == 'onlinecapacity' || id.toLowerCase() == 'minimumunits'){
                        var category_items = dashboard_grid.getAllSubItems(id);
                        var category_items_arr = category_items.split(',');   
                        
                        for (cnt = 0; cnt < category_items_arr.length; cnt++) {
                            if (dashboard_grid.getLevel(category_items_arr[cnt]) ==  1) {
                                if (id.toLowerCase() == 'onlinestatus') {
                                    var childitem = dashboard_grid.getAllSubItems(category_items_arr[cnt]);
                                    var childitem_arr = childitem.split(','); 
                                   
                                    for (i = 0; i < childitem_arr.length; i++) {
                                        var row_id = childitem_arr[i].toString();
                                        var row_index = dashboard_grid.getRowIndex(row_id);
                                        online_index.push(row_index);
                                        //dashboard_grid.setRowColor(row_id,what_if_row_color);
                                        //var link_value = dashboard_grid.cells(row_id, 0).getValue();
                                        //var new_link_value = "<a href=# onclick=open_hyperlink('" + childitem_arr[i].toString() + "','time_series')>" + link_value + "</a>";
                                        //dashboard_grid.cells(row_id, 0).setValue(new_link_value);
                                        dashboard_grid.forEachCell(row_id,function(cellObj,ind){
                                            if (ind > 3) {
                                                //dashboard_grid.setCellExcellType(row_id,ind,"ed"); 
                                                var value = dashboard_grid.cells(row_id,ind).getValue();
                                                
												/*
                                                if (value == 0) {
                                                    dashboard_grid.cells(row_id,ind).setValue('N');
                                                    value = 'n';
                                                } else if (value == 1) {
                                                    dashboard_grid.cells(row_id,ind).setValue('Y');
                                                    value = 'y';
                                                }
												*/
						
                                                var change_item = dashboard_grid.cells(category_items_arr[cnt],0).getValue();
												var ref_id = dashboard_grid.cells(childitem_arr[i],3).getValue();
                                                grid_value_toggle('OnlineCapacity',change_item,ref_id,value,ind, 'load');
                                                grid_value_toggle('MinimumUnits',change_item,ref_id,value,ind, 'load');
                                            }
                                        }); 
                                        dashboard_grid.setRowHidden(childitem_arr[i],true);
                                    }
                                    dashboard_grid.setRowHidden(category_items_arr[cnt],true);
                                    dashboard_grid.setRowHidden(id,true);
                                    //clear_cell(category_items_arr[cnt]);   
                                } else {
                                    var row_id = category_items_arr[cnt].toString();
                                    
                                    if (id.toLowerCase() == 'onlinecapacity' || id.toLowerCase() == 'minimumunits') {
                                        var childitem = dashboard_grid.getAllSubItems(row_id);
                                        var childitem_arr = childitem.split(','); 
                                        
                                        for (i = 0; i < childitem_arr.length; i++) {
                                            var link_value = dashboard_grid.cells(childitem_arr[i], 0).getValue();
                                            if (id.toLowerCase() == 'onlinecapacity') 
                                                var new_link_value = "<a href=# onclick=open_hyperlink('" + childitem_arr[i].toString() + "','deal')>" + link_value + "</a>";
                                            else 
                                                var new_link_value = "<a href=# onclick=open_hyperlink('" + childitem_arr[i].toString() + "','time_series')>" + link_value + "</a>";
                                            dashboard_grid.cells(childitem_arr[i], 0).setValue(new_link_value);
                                        }
                                    }
                                     dashboard_grid.forEachCell(id,function(cellObj,ind){
                                        dashboard_grid.setCellTextStyle(id,ind,"font-weight:bold;");     
                                    });
                                }
                            }
                        }
                        
                        dashboard_grid.forEachCell(id,function(cellObj,ind){
                            dashboard_grid.cells(id,ind).setBgColor(total_row_color); 
                        }); 
                    } 
					else if (id.toLowerCase() == 'solverresults') {
                        var category_items = dashboard_grid.getAllSubItems(id);
                        var category_items_arr = category_items.split(',');       
						
                        for (cnt = 0; cnt < category_items_arr.length; cnt++) {
                            clear_parent_cell(category_items_arr[cnt]);   
                        }
                         
                        for (cnt = 0; cnt < category_items_arr.length; cnt++) {
                            var level = dashboard_grid.getLevel(category_items_arr[cnt]);
                            dashboard_grid.setRowColor(category_items_arr[cnt],solver_result_color);    
                            
                        }
						
						for (cnt = 0; cnt < category_items_arr.length; cnt++) {
                            var level = dashboard_grid.getLevel(category_items_arr[cnt]);
                            if (level == 1) {
                               clear_cell(category_items_arr[cnt]);
                            } 
                        }
                        clear_cell(id);
						dashboard_grid.forEachCell(id,function(cellObj,ind){
                            dashboard_grid.cells(id,ind).setBgColor(solver_result_color); 
                        });
                    } else if (id.toLowerCase() == 'reserves') {
                        clear_cell(id);
                        dashboard_grid.forEachCell(id,function(cellObj,ind){
                            if (ind > 3) {
                                calculate_reserve(ind);
                            }
                        });  
                        clear_cell('Reserves');
						dashboard_grid.forEachCell(id,function(cellObj,ind){
                            dashboard_grid.cells(id,ind).setBgColor(total_row_color); 
                        }); 
                    } else if (id.toLowerCase() == 'nettransactionsandload') {
                        dashboard_grid.setRowColor(id,total_row_color);  
                        
                        var category_items = dashboard_grid.getAllSubItems(id);
                        var category_items_arr = category_items.split(',');       

                        for (cnt = 0; cnt < category_items_arr.length; cnt++) {
                            var row_id = category_items_arr[cnt].toString();
                            if(dashboard_grid.cells(row_id,0).getValue().toLowerCase() == 'what if + purchase , - sale') {
                                var row_index = dashboard_grid.getRowIndex(row_id);
                                what_if_index = row_index;
                                dashboard_grid.setRowColor(row_id,what_if_row_color);
                                dashboard_grid.forEachCell(row_id,function(cellObj,ind){
                                    if (ind > 3) {
                                        dashboard_grid.setCellExcellType(row_id,ind,"ed"); 
                                    }
                                });   
                            }
                        }
                        dashboard_grid.forEachCell(id,function(cellObj,ind){
                            dashboard_grid.setCellTextStyle(id,ind,"font-weight:bold;");     
                        });
                    }
                }
            });
            dashboard_expand_collapse();
            dashboard_manager.dashboard_manger_layout.cells('b').progressOff();
        }
        
        function open_hyperlink(row_id, option) {
            if (option == 'time_series') {
                var deal_id = dashboard_grid.cells(row_id, 3).getValue();
                var term_start = dashboard_manager.filters_form.getItemValue('term_start');
                var current_hour = dashboard_manager.filters_form.getItemValue('current_hour');
                var next_hour = dashboard_manager.filters_form.getItemValue('next_hour');
                
                var term_end = new Date(term_start);
                var hrs = parseInt(current_hour)+parseInt(next_hour) - 2;
                term_end = new Date(term_start.getFullYear(), term_start.getMonth(), term_start.getDate(), term_start.getHours()+hrs);
                term_end = dates.convert_to_sql(term_end);
                term_start = dates.convert_to_sql(term_start);
				var process_id = dashboard_grid.cells(row_id, 1).getValue();
                
                var exec_call = "exec spa_generation_report @flag='g', @term_start='" + term_start + " ', @term_end='" + term_end + "', @source_deal_header_id=" + deal_id + ", @process_id='" + process_id + "'";
                open_spa_html_window('Generation Level Report', exec_call, 500, 1200);
            } else if (option == 'deal') {
                var deal_id = dashboard_grid.cells(row_id, 3).getValue();
                parent.TRMHyperlink(10131010,deal_id,'n','NULL');
            }
        }
        
        /*
         * [Cell edit function]
         * Calculate reserve value if what if is changed.
         * Toggle the value to orginal and 0 when the online status is changed.
         */
        function dashboard_grid_cell_edit(stage,rId,cInd,nValue,oValue) {
            var parent_id = dashboard_grid.getParentId(rId);
            
            if (stage == 2) {
                if (parent_id.toLowerCase() == 'nettransactionsandload') {
                    if (cInd > 3) {
                        calculate_reserve(cInd);   
                        clear_cell('Reserves');
                    }
                } 
				/*
				else {
                    if (nValue.toLowerCase() != 'n' && nValue.toLowerCase() != 'y') {
                        dashboard_grid.cells(rId, cInd).setValue(oValue);    
                        grid_cell_clearance()
                    } else {
                        var change_item;

                        var change_item = dashboard_grid.cells(parent_id,0).getValue().toLowerCase();
                        var onlinestatus_subitem = dashboard_grid.getAllSubItems(parent_id);
                        var onlinestatus_subitem_arr = onlinestatus_subitem.split(',');    

						var ref_id = dashboard_grid.cells(rId,5).getValue();
                        grid_value_toggle('OnlineCapacity',change_item,ref_id,nValue,cInd, 'change');
                        grid_value_toggle('MinimumUnits',change_item,ref_id,nValue,cInd, 'change');
                        if (cInd > 3)  {
                            calculate_reserve(cInd);
							clear_cell('Reserves');
                        }
                    }
                }
                */
				
				if(oValue.toLowerCase() != nValue.toLowerCase()) {
                    if (jQuery.inArray([rId, cInd], changed_cell_value) == -1) {
                        changed_cell_value.push([rId, cInd]);
                    }
                    dashboard_grid.cells(rId,cInd).setBgColor('#FAE2B6');   
					changed_for_undo.push(cInd);
                }
                
            }
            return true;
        }
        
        
        /*
         * [To change the cell color to red if its value is negative]
         */
        function dashboard_grid_cell_changed(rId,cInd,nValue) {
            if (cInd > 3) {
				if(parseFloat(nValue) < 0) {
                    dashboard_grid.setCellTextStyle(rId,cInd,"font-weight:bold;"); 
                    dashboard_grid.cells(rId,cInd).setTextColor(negative_value_color); 
                } else if(parseFloat(nValue) > 0) {
                    dashboard_grid.setCellTextStyle(rId,cInd,"font-weight:normal;"); 
                    dashboard_grid.cells(rId,cInd).setTextColor('#000000'); 
                } 
                
				/*
                if (nValue == 'n' || nValue == 'y') {
                    dashboard_grid.cells(rId,cInd).setValue(nValue.toUpperCase()); 
                }
                */
                if (dashboard_grid.cells(rId,0).getValue().toLowerCase() == 'online unit spin') {
                    var parent_id = dashboard_grid.getParentId(rId);
                    if(parseFloat(nValue) < 0)
                        dashboard_grid.cells(parent_id, cInd).setValue('Add Unit');
                    else 
                        dashboard_grid.cells(parent_id, cInd).setValue('');
                }
            }
        }
        
                        
        /*
         * [Calculate the value of the reserves when online status and what if is changed]
         */
        function calculate_reserve(cInd) {
            var total_online_capacity = 0;
            var total_sales = dashboard_grid.cells('NetTransactionsandLoad',cInd).getValue();
            dashboard_grid.setCellTextStyle('NetTransactionsandLoad',cInd,"font-weight:bold;");     
            
            var resources_child = dashboard_grid.getAllSubItems('OnlineCapacity');
            var resources_child_arr = resources_child.split(',');
            
            for (cnt = 0; cnt < resources_child_arr.length; cnt++) {
                if (dashboard_grid.getLevel(resources_child_arr[cnt]) == 1) {
                    total_online_capacity += parseFloat(dashboard_grid.cells(resources_child_arr[cnt],cInd).getValue());
                }
            }
            
            var reserves_child = dashboard_grid.getAllSubItems('Reserves');
            var reserves_child_arr = reserves_child.split(',');
            
            var available = 0;
            var actual = 0;
            for (cnt = 0; cnt < reserves_child_arr.length; cnt++) {
                if (dashboard_grid.getLevel(reserves_child_arr[cnt]) == 1 && dashboard_grid.cells(reserves_child_arr[cnt],0).getValue().toLowerCase() == 'online unit spin') {
                    dashboard_grid.cells(reserves_child_arr[cnt],cInd).setValue(parseFloat(total_online_capacity) + parseFloat(total_sales));  
                    available = parseFloat(total_online_capacity) + parseFloat(total_sales);
                    var r_parent_id = dashboard_grid.getParentId(reserves_child_arr[cnt]);
                }
                
                if (dashboard_grid.getLevel(reserves_child_arr[cnt]) == 1 && dashboard_grid.cells(reserves_child_arr[cnt],0).getValue().toLowerCase() == 'contracted net spin') {
                    actual = dashboard_grid.cells(reserves_child_arr[cnt],cInd).getValue();       
                }
                
                if (dashboard_grid.getLevel(reserves_child_arr[cnt]) == 1 && dashboard_grid.cells(reserves_child_arr[cnt],0).getValue().toLowerCase() == 'total spin') {
                    dashboard_grid.cells(reserves_child_arr[cnt],cInd).setValue(parseFloat(available) + parseFloat(actual));        
                }
                
                if (available < 0) {
					dashboard_grid.cells(r_parent_id, cInd).setValue('Add Unit');
				} 
				dashboard_grid.cells(r_parent_id,cInd).setBgColor(total_row_color); 
			}
        }
        
        
        /*
         * [Function to drag and select the block]
         */
        function block_select_function() {
            var top_row = dashboard_grid.getSelectedBlock().LeftTopRow;
            var bottom_row = dashboard_grid.getSelectedBlock().RightBottomRow;
            var left_column = dashboard_grid.getSelectedBlock().LeftTopCol;
            var right_column = dashboard_grid.getSelectedBlock().RightBottomCol;
            
            if (left_column < 3) return;
            if (top_row != bottom_row) return;
            
            var push_array = new Array();
            var copy_value = dashboard_grid.cells2(top_row, left_column).getValue();
            if (what_if_index == top_row) {
                for (ct = left_column+1; ct <= right_column; ct++) {
                    dashboard_grid.cells2(top_row, ct).setValue(copy_value);
                    dashboard_grid.cells2(top_row,ct).setBgColor('#FAE2B6');   
                    calculate_reserve(ct);
					var rId = dashboard_grid.getRowId(top_row);
					if (jQuery.inArray([rId, ct], changed_cell_value) == -1) {
                        changed_cell_value.push([rId, ct]);
                    } 
					push_array.push(ct);
                }
				clear_cell('Reserves');
            } else if (jQuery.inArray(top_row, online_index) > -1) {
                for (ct = left_column+1; ct <= right_column; ct++) {
                    dashboard_grid.cells2(top_row, ct).setValue(copy_value);
                    dashboard_grid.cells2(top_row,ct).setBgColor('#FAE2B6');  
                    var ind = ct; 
                    var rId = dashboard_grid.getRowId(top_row);
                    var value = dashboard_grid.cells(rId,ind).getValue(); 
                    var parent_id = dashboard_grid.getParentId(rId);
                    var change_item = dashboard_grid.cells(parent_id,0).getValue().toLowerCase();
                    
                    var onlinestatus_subitem = dashboard_grid.getAllSubItems(parent_id);
                    var onlinestatus_subitem_arr = onlinestatus_subitem.split(',');  

					var ref_id = dashboard_grid.cells(rId,3).getValue();
                    grid_value_toggle('OnlineCapacity',change_item,ref_id,value,ind, 'change');
                    grid_value_toggle('MinimumUnits',change_item,ref_id,value,ind, 'change');

                    calculate_reserve(ind);
					clear_cell('Reserves');
                    if (jQuery.inArray([rId, ind], changed_cell_value) == -1) {
                        changed_cell_value.push([rId, ind]);
                    } 
                    push_array.push(ct);
                }
            }
            var push_string = push_array.toString();
        }
        
        
        /*
         * [To change the value of onlinecapacity and minimum units when the Online status is changed]
         * [Online status = 'y', then show orginal value. Online status = 'n' then show 0]
         */
        function grid_value_toggle(id, change_item, ref_id, nValue, cInd, status) {
			
            var resources_category = dashboard_grid.getAllSubItems(id);
            var resources_category_arr = resources_category.split(',');
            
            for (var cnt = 0; cnt < resources_category_arr.length; cnt++) {
                var level = dashboard_grid.getLevel(resources_category_arr[cnt]);
                
				if (level == 2) {
					var p_id = dashboard_grid.cells(dashboard_grid.getParentId(resources_category_arr[cnt]),0).getValue();
                    var c_ref_id = dashboard_grid.cells(resources_category_arr[cnt],3).getValue();
					
					if (p_id.toLowerCase() == change_item.toLowerCase() && c_ref_id == ref_id) {
						
						if (nValue == 0) {
							var value = dashboard_grid.cells(resources_category_arr[cnt], cInd).getValue();
							dashboard_grid.cells(resources_category_arr[cnt], cInd).setValue('0');
							online_cell_value.push([resources_category_arr[cnt], cInd, value]);
						} else if (nValue == 1) {
                            var row_index = resources_category_arr[cnt];

                            for (var i = 0; i < online_cell_value.length; i++) {
                                if(online_cell_value[i][0] == row_index && online_cell_value[i][1] == cInd) {
                                    dashboard_grid.cells(resources_category_arr[cnt], cInd).setValue(online_cell_value[i][2]);   
                                }
                            }
                        }
						//var parent_id = dashboard_grid.getParentId(resources_category_arr[cnt]);
                        dashboard_grid.setCellTextStyle(id,cInd,"font-weight:bold;");  
						
					}
				}
				
				/*
                if (level == 1) {
                    if (dashboard_grid.cells(resources_category_arr[cnt],0).getValue().toLowerCase() == change_item.toLowerCase()) {
                        var child = dashboard_grid.getAllSubItems(resources_category_arr[cnt]);
                        var child_arr = child.split(',');

                        if (nValue.toLowerCase() == 'n') {
                            var value = dashboard_grid.cells(child_arr[change_pos], cInd).getValue();
                            online_cell_value.push([child_arr[change_pos], cInd, value]);
                            dashboard_grid.cells(child_arr[change_pos], cInd).setValue('0');
                        } else if (nValue.toLowerCase() == 'y') {
                            var row_index = child_arr[change_pos];

                            for (var i = 0; i < online_cell_value.length; i++) {
                                if(online_cell_value[i][0] == row_index && online_cell_value[i][1] == cInd) {
                                    dashboard_grid.cells(child_arr[change_pos], cInd).setValue(online_cell_value[i][2]);   
                                }
                            }
                        }
                        var parent_id = dashboard_grid.getParentId(resources_category_arr[cnt]);
                        dashboard_grid.setCellTextStyle(parent_id,cInd,"font-weight:bold;");  
                    }
                }
				*/
            } 
            dashboard_grid.cells(id,cInd).setBgColor(total_row_color); 
            
            if (status == 'change') {
				grid_cell_clearance();
            }
        }
        
        
        /*
         * [Expand/collapse treegrid on double click]
         */
        function dashboard_grid_db_click(rId,cInd) {
            var selected_row = dashboard_grid.getSelectedRowId();
            var state = dashboard_grid.getOpenState(selected_row);
            
            if (state)
                dashboard_grid.closeItem(selected_row);
            else
                dashboard_grid.openItem(selected_row);
            
            //Toggle online offline when double clicked.
            if (dashboard_grid.getLevel(rId) == 2) {
                var parent_id = dashboard_grid.getParentId(rId);
                var parent_parent_id = dashboard_grid.getParentId(parent_id);

                if (parent_parent_id.toLowerCase() == 'onlinecapacity') {
                    var ref_id = dashboard_grid.cells(rId, 3).getValue();
                    var childitem = dashboard_grid.getAllSubItems('OnlineStatus');
                    var childitem_arr = childitem.split(','); 
                    
                    for (i = 0; i < childitem_arr.length; i++) {
                        var tree_level = dashboard_grid.getLevel(childitem_arr[i]);

                        if (tree_level == 2 && ref_id == dashboard_grid.cells(childitem_arr[i],3).getValue()) {
                            var online_status = dashboard_grid.cells(childitem_arr[i], cInd).getValue();
                            var chn_val;

                            if (online_status == 0) {
                                dashboard_grid.cells(childitem_arr[i], cInd).setValue('1');
                                chn_val = 1;
                            } else if (online_status == 1) {
                                dashboard_grid.cells(childitem_arr[i], cInd).setValue('0');
                                chn_val = 0;
                            }
							
							if (jQuery.inArray([childitem_arr[i], cInd], changed_cell_value) == -1) {
								changed_cell_value.push([childitem_arr[i], cInd]);
							}
							
							var change_item = dashboard_grid.cells(parent_id,0).getValue().toLowerCase();
                            var onlinestatus_subitem = dashboard_grid.getAllSubItems(parent_id);
                            var onlinestatus_subitem_arr = onlinestatus_subitem.split(',');    

                            var ref_id = dashboard_grid.cells(rId,3).getValue();
                            grid_value_toggle('OnlineCapacity',change_item,ref_id,chn_val,cInd, 'change');
                            grid_value_toggle('MinimumUnits',change_item,ref_id,chn_val,cInd, 'change');
							
                            if (cInd > 3)  {
                                calculate_reserve(cInd);
                                clear_cell('Reserves');
                            }
                        }
                    }
                }
            }
        }
        
        
        /*
         * [Clear the cell value where formula is not required]
         */
        function grid_cell_clearance() {
            var no_of_rows = dashboard_grid.getRowsNum();
            
            dashboard_grid.forEachRow(function(id){
                var tree_level = dashboard_grid.getLevel(id);
                if (tree_level == 0 && id.toLowerCase() == 'onlinestatus'){
                    var category_items = dashboard_grid.getAllSubItems(id);
                    var category_items_arr = category_items.split(',');   

                    for (cnt = 0; cnt < category_items_arr.length; cnt++) {
                        if (dashboard_grid.getLevel(category_items_arr[cnt]) ==  1) {
                            clear_cell(category_items_arr[cnt]);   
                        }
                    } 
                }
            });
        }
                
        
        /*
         * [Clear the cell value of the row]
         */
        function clear_cell(id) {
            dashboard_grid.forEachCell(id,function(cellObj,ind){
                if (ind > 3) {
					var val = dashboard_grid.cells(id,ind).getValue();
					if (val != 'Add Unit') {
						dashboard_grid.cells(id,ind).setValue("");
					}
                }
            });  
            
            var tree_level = dashboard_grid.getLevel(id);
            if(tree_level > 0) {
                clear_parent_cell(id)     
            }
        }
        
        
        /*
         * [Clear the cell value of the parents row]
         */
        function clear_parent_cell(id) {
            var parent_id = dashboard_grid.getParentId(id);
            
             dashboard_grid.forEachCell(parent_id,function(cellObj,ind){
                if (ind > 3) {
                    dashboard_grid.cells(parent_id,ind).setValue("");
                }
            }); 
            
            var tree_level = dashboard_grid.getLevel(parent_id);
            if(tree_level > 0) {
                clear_parent_cell(parent_id)     
            }
        }
        
        
        /*
         * [Function to call when solver button is clicked]
         */
		function dashboard_solver(){
			var exception_hour_ind = check_exception();
			if (exception_hour_ind == 3) {
				show_messagebox('Cannot run solver due to exceptions.');
				return;
			} else if (exception_hour_ind > 3) {
				var exp_hour = dashboard_grid.getColLabel(exception_hour_ind,1);
				var term_ind = exception_hour_ind - exp_hour + 1;
				var exp_year = dashboard_grid.getColLabel(term_ind,0);
				
				var msg = 'There are some exceptions. Solver will run till <strong>' + exp_year + ' hour ' +  exp_hour + '</strong>. Do you want to proceed?';
				
				dhtmlx.message({
					type: "confirm",
					title: "Confirmation",
					text: msg,
					ok: "Confirm",
					callback: function(result) {
							if (result)
								dashboard_solver_exp(exception_hour_ind);
							}
				});
			} else {
				dashboard_solver_exp(-1);
			}
		}
		 
        function dashboard_solver_exp(exception_hour_ind){
			if (exception_hour_ind == -1) {
				exception_hour_ind = dashboard_grid.getColumnsNum();
			}
			dashboard_manager.dashboard_manger_layout.cells('b').progressOn();
            dashboard_grid.clearSelection();
            var solver_xml = '<Root>';
            var process_id;
            
			var d_flag = 0;
			var dst_index = 0;
			var row_id = dashboard_grid.getRowId(0);
			dashboard_grid.forEachCell(row_id,function(cellObj,ind){
				if (dashboard_grid.getColLabel(ind,1) == '3-DST') {
					d_flag = 1;
					dst_index= ind;
				}
			});
			
			var changed_val_arr = new Array();
			changed_val_arr[0] = changed_cell_value[0];
			for(var i=0;i<changed_cell_value.length;i++)
			{
				var flag = true;
				for(var j=0;j<changed_val_arr.length;j++)
				{
					if(changed_val_arr[j][0]==changed_cell_value[i][0] && changed_val_arr[j][1]==changed_cell_value[i][1])
					{
						flag = false;
					}
				}
				if(flag==true)
				changed_val_arr.push(changed_cell_value[i]);
			}
			
			changed_cell_value = changed_val_arr;
			var grid_xml = '';
			for(cnt = 0; cnt < changed_cell_value.length; cnt++) {
				if (changed_cell_value[cnt][1] <= exception_hour_ind) {
					grid_xml += '<grid process_row_id="' + dashboard_grid.cells(changed_cell_value[cnt][0],3).getValue() + '"';
					if (dashboard_grid.getColLabel(changed_cell_value[cnt][1],1) == '3-DST') {
						var s_hour = 3;
						var is_dst = 1;
					} else {
						var s_hour = dashboard_grid.getColLabel(changed_cell_value[cnt][1],1);
						var is_dst = 0;
					}
					grid_xml += ' hour="' + s_hour + '"'; 
					
					if (changed_cell_value[cnt][1] < dst_index) {
						var term_ind = changed_cell_value[cnt][1] - dashboard_grid.getColLabel(changed_cell_value[cnt][1],1) + 1;
					} else if (changed_cell_value[cnt][1] == dst_index){
						var term_ind = changed_cell_value[cnt][1] - 2 - d_flag;
					} else {
						var term_ind = changed_cell_value[cnt][1] - dashboard_grid.getColLabel(changed_cell_value[cnt][1],1) + 1 - d_flag;
					}
					grid_xml += ' term="' + dashboard_grid.getColLabel(term_ind,0)  + '"';
					grid_xml += ' value="' + dashboard_grid.cells(changed_cell_value[cnt][0],changed_cell_value[cnt][1]).getValue()  + '"';
					grid_xml += ' is_dst="' + is_dst + '"';
					grid_xml += ' />';
					process_id = dashboard_grid.cells(changed_cell_value[cnt][0],1).getValue();
				}
            }
            solver_xml += grid_xml + '</Root>';
            s_term_start = dashboard_manager.filters_form.getItemValue('term_start', true);
            s_current_hour = dashboard_manager.filters_form.getItemValue('current_hour');
            s_next_hour = dashboard_manager.filters_form.getItemValue('next_hour');
			
			var flag = 'w';
            var dashboard_data = {
                                    "action": "spa_process_power_dashboard",
                                    "flag": flag,
                                    "term_start": s_term_start,
                                    "hr_start": s_current_hour-1,
                                    "hr_no": s_next_hour,
                                    "xml": solver_xml,
                                    "grid_type":"tg",
                                    "grouping_column":"group,group2,deal_id"
                                 }
			
            var sql_param = $.param(dashboard_data);
            
            dashboard_grid.clearAll();
            dashboard_grid.post(js_data_collector_url, sql_param, function(){
                load_solver_data();
            });
        }
        
        
        /*
         * [Call back function of solver, to show result in popup]
         */
        function dashboard_solver_callback(result) {
			var flag = 's';
            var dashboard_data = {
                                    "action": "spa_process_power_dashboard",
                                    "flag": flag,
                                    "term_start": s_term_start,
                                    "hr_start": s_current_hour-1,
                                    "hr_no": s_next_hour,
                                    "grid_type":"tg",
                                    "grouping_column":"group,group2,deal_id"
                                 }
								 
			dashboard_data = $.param(dashboard_data);
            var dashboard_data_url = js_data_collector_url + "&" + dashboard_data;
			dashboard_grid.clearAll();
            dashboard_grid.loadXML(dashboard_data_url, load_solver_data);
		}
		
		function load_solver_data() {
			dashboard_manager_refresh_callback();
			dashboard_grid_summary();
			dashboard_manager.dashboard_manger_layout.cells('b').progressOff();
        }
        
        
        /*
         * [Save function]
         */
		function dashboard_save() {
			var exception_hour_ind = check_exception();
			if (exception_hour_ind == 3) {
				show_messagebox('Cannot save due to exceptions.');
				return;
			} else if (exception_hour_ind > 3) {
				var exp_hour = dashboard_grid.getColLabel(exception_hour_ind,1);
				var term_ind = exception_hour_ind - exp_hour + 1;
				var exp_year = dashboard_grid.getColLabel(term_ind,0);
				
				var msg = 'There are some exceptions. Data will be saved till <strong>' + exp_year + ' hour ' +  exp_hour + '</strong>. Do you want to proceed?';
				
				dhtmlx.message({
					type: "confirm",
					title: "Confirmation",
					text: msg,
					ok: "Confirm",
					callback: function(result) {
							if (result)
								dashboard_save_exp(exception_hour_ind);
							}
				});
			} else {
				dashboard_save_exp(-1);
			}
		}		
		
        function dashboard_save_exp(exception_hour_ind) {
			if (exception_hour_ind == -1) {
				exception_hour_ind = dashboard_grid.getColumnsNum();
			}
			sa_term_start = dashboard_manager.filters_form.getItemValue('term_start', true);
            sa_current_hour = dashboard_manager.filters_form.getItemValue('current_hour');
            sa_next_hour = dashboard_manager.filters_form.getItemValue('next_hour');
            
            dashboard_grid.clearSelection();
            var save_xml = '<Root>';
            var process_id;
            
            var grid_xml = '';
            var subitem = dashboard_grid.getAllSubItems('NetTransactionsandLoad');
            var subitem_arr = subitem.split(',');

            for(i = 0; i < subitem_arr.length; i++) {
                if(dashboard_grid.cells(subitem_arr[i],0).getValue().toLowerCase() == 'what if + purchase , - sale') {
                    var row_id = subitem_arr[i].toString();
					var dst_flag = 0;
                    dashboard_grid.forEachCell(row_id,function(cellObj,ind){
                        if (ind > 3 && ind <= exception_hour_ind) {
                            grid_xml += '<grid deal_id="' + dashboard_grid.cells(row_id,3).getValue() + '"';
                            if (dashboard_grid.getColLabel(ind,1) == '3-DST') {
                                var s_hour = 3;
                                var is_dst = 1;
                                var term_ind = ind - 3 + 1;
								dst_flag = 1;
                            } else {
                                var s_hour = dashboard_grid.getColLabel(ind,1);
                                var is_dst = 0;
                                var term_ind = ind - dashboard_grid.getColLabel(ind,1) + 1 - dst_flag;
                            }
                            grid_xml += ' hour="' + s_hour + '"'; 
							grid_xml += ' term="' + dashboard_grid.getColLabel(term_ind,0) +'"';
                            grid_xml += ' value="' + dashboard_grid.cells(row_id,ind).getValue() + '"';
                            grid_xml += ' is_dst="' + is_dst + '"';
                            grid_xml += ' type="d"';
                            grid_xml += ' ></grid>';  
                            process_id = dashboard_grid.cells(row_id,1).getValue();
                        }
                    });       
                }
            }
            
            var subitem_t = dashboard_grid.getAllSubItems('OnlineStatus');
            var subitem_t_arr = subitem_t.split(',');
            
			
            for(i = 0; i < subitem_t_arr.length; i++) {
				if(dashboard_grid.getLevel(subitem_t_arr[i]) == 2) {
                    var row_id = subitem_t_arr[i].toString();
					var dst_flag = 0;
					dashboard_grid.forEachCell(row_id,function(cellObj,ind){
                        if (ind > 3 && ind <= exception_hour_ind) {
                            grid_xml += '<grid deal_id="' + dashboard_grid.cells(row_id,3).getValue() + '"';
                            if (dashboard_grid.getColLabel(ind,1) == '3-DST') {
                                var s_hour = 3;
                                var is_dst = 1;
                                var term_ind = ind - 3 + 1;
								dst_flag = 1;
                            } else {
                                var s_hour = dashboard_grid.getColLabel(ind,1);
                                var is_dst = 0;
                                var term_ind = ind - dashboard_grid.getColLabel(ind,1) + 1 - dst_flag;
                            }
                            grid_xml += ' hour="' + s_hour + '"'; 
                            grid_xml += ' term="' + dashboard_grid.getColLabel(term_ind,0) + '"';
							if (dashboard_grid.cells(row_id,ind).getValue().toLowerCase() == 1) {
								var t_val = 1;
							} else {
								var t_val = 0;
							}
                            grid_xml += ' value="' + t_val +'"';
                            grid_xml += ' is_dst="' + is_dst + '"';
                            grid_xml += ' type="t"';
                            grid_xml += ' ></grid>';  
                            process_id = dashboard_grid.cells(row_id,1).getValue();
                        }
                    });       
                }
            }
            save_xml += grid_xml + '</Root>';
			var term_start = dashboard_manager.filters_form.getItemValue('term_start', true);
            var current_hour = dashboard_manager.filters_form.getItemValue('current_hour');
            var next_hour = dashboard_manager.filters_form.getItemValue('next_hour');
			
			var flag = 't';
            var dashboard_data = {
                                    "action": "spa_process_power_dashboard",
                                    "flag": flag,
                                    "save_xml": save_xml,
                                    "process_id": process_id,
									"term_start": term_start,
                                    "hr_start": current_hour-1,
                                    "hr_no": next_hour,
                                  }
            
            adiha_post_data('alert', dashboard_data, '', '', 'dashboard_save_callback', '', '');
        }
        
		/*
		 * [Save callback function, to reload the grid]
         */
        function dashboard_save_callback() {
            var flag = 'c';
			var term_start = dashboard_manager.filters_form.getItemValue('term_start', true);
            var current_hour = dashboard_manager.filters_form.getItemValue('current_hour');
            var next_hour = dashboard_manager.filters_form.getItemValue('next_hour');
			var new_date = new Date(term_start);
			
			var term_end = new Date(new_date.getFullYear(), new_date.getMonth() , new_date.getDate(), new_date.getHours()+ parseInt(current_hour)+parseInt(next_hour));
			term_end = dates.convert_to_sql(term_end);
			var dashboard_data = {
                                    "action": "spa_process_power_dashboard",
                                    "flag": flag,
                                    "term_start": term_start,
                                    "term_end": term_end,
									"hr_start": "0"
                                  }
            
            adiha_post_data('return_json', dashboard_data, '', '', 'dashboard_grid_save_calc_callback', '', '');   
        }
		
		function dashboard_grid_save_calc_callback(result) {
			var today = new Date();
			dashboard_save_snapshot(today);
			/*
			var return_data = JSON.parse(result);
			
			dhtmlx.message({
				text:return_data[0].message,
				expire:1000
			});
			*/
			dashboard_save_callback_refresh();
		}
		
        /*
         * [Save callback function, to reload the grid]
         */
        function dashboard_save_callback_refresh() {
            var flag = 's';
            var dashboard_data = {
                                    "action": "spa_process_power_dashboard",
                                    "flag": flag,
                                    "term_start": sa_term_start,
                                    "hr_start": sa_current_hour-1,
                                    "hr_no": sa_next_hour,
                                    "grid_type":"tg",
                                    "grouping_column":"group,group2,deal_id"
                                 }
								 
			dashboard_data = $.param(dashboard_data);
            var dashboard_data_url = js_data_collector_url + "&" + dashboard_data;
			dashboard_grid.clearAll();
            dashboard_grid.loadXML(dashboard_data_url, dashboard_manager_refresh_callback);  
		}
        
        /*
         * [Undo function, called when undo button is clicked]
         */
        function dashboard_undo(rId) {
            var parent_id = dashboard_grid.getParentId(rId);
            
            if (parent_id == 'NetTransactionsandLoad') {
                var ind = changed_for_undo.pop();
                calculate_reserve(ind);  
                clear_cell('Reserves');
            } else {
                var ind = changed_for_undo.pop();
                var value = dashboard_grid.cells(rId,ind).getValue(); 
                var parent_id = dashboard_grid.getParentId(rId);
                var change_item = dashboard_grid.cells(parent_id,0).getValue().toLowerCase();
                var onlinestatus_subitem = dashboard_grid.getAllSubItems(parent_id);
                var onlinestatus_subitem_arr = onlinestatus_subitem.split(',');  

                var ref_id = dashboard_grid.cells(rId,3).getValue();
                grid_value_toggle('OnlineCapacity',change_item,ref_id,value,ind, 'change');
                grid_value_toggle('MinimumUnits',change_item,ref_id,value,ind, 'change');

                calculate_reserve(ind);
                

                if (jQuery.inArray([rId, ind], changed_cell_value) == -1) {
                    changed_cell_value.push([rId, ind]);
                }
				clear_cell('Reserves');
            }
        }
        
        function dashboard_grid_calc() {
            var today_date = new Date();
            var term_start = new Date(today_date.getFullYear(), today_date.getMonth() , today_date.getDate());
            var term_end = new Date(today_date.getFullYear(), today_date.getMonth() , today_date.getDate()+1);
            term_start = dates.convert_to_sql(term_start);
            term_end = dates.convert_to_sql(term_end);
            
            calc_popup = new dhtmlXPopup();
            calc_form = calc_popup.attachForm(
                [
                    {type: "settings", position: "label-left", labelWidth: 100, inputWidth: 130, position: "label-left", offsetLeft: 20},
                    {type: "calendar", name: "term_start", label: "Term Start", value:term_start, "dateFormat": client_date_format, serverDateFormat: "%Y-%m-%d"},
                    {type: "calendar", name: "term_end", label: "Term End", value:term_end, "dateFormat": client_date_format, serverDateFormat: "%Y-%m-%d"},
                    {type: "button", value: "Ok", img: "tick.png"}
                ]);
            
            calc_form.setItemValue('term_start', term_start);
            
            var h = dashboard_manager.dashboard_manger_layout.cells('a').getHeight();
            calc_popup.show(250,h+20,50,50);
            
            calc_form.attachEvent("onButtonClick", function(name){
                var term_start = calc_form.getItemValue('term_start', true);
                var term_end = calc_form.getItemValue('term_end', true);
                
                var flag = 'c';
                var data = {
                                "action": "spa_process_power_dashboard",
                                "flag": flag,
                                "term_start": term_start,
                                "term_end": term_end,
								"hr_start": "0"
                              }

                adiha_post_data('return_json', data, '', '', 'dashboard_grid_calc_callback', '', '');
				calc_popup.hide();
            });
        }
		
		function dashboard_grid_calc_callback(result) {
			var return_data = JSON.parse(result);
			
			dhtmlx.message({
				text:return_data[0].message,
				expire:1000
			});
		}
        
        function dashboard_grid_summary() {
        	summary_win = new dhtmlXWindows();
			w1 = summary_win.createWindow("w1", 100, 30, 520, 200);
			w1.setText("Summary");
            
            var summary_grid = summary_win.window('w1').attachGrid();
            summary_grid.setImagePath(js_image_path + "dhxgrid_web/");
            summary_grid.setHeader("Result, Value");
            summary_grid.setColumnMinWidth("150,150");
            summary_grid.setInitWidths("*,150");
			summary_grid.setColTypes("ro,ro");
            summary_grid.init();
            
			//var ids=dashboard_grid.getAllRowIds();
			var ids = dashboard_grid.getAllSubItems('NetTransactionsandLoad');
			var ids_arr = ids.split(',');
            var row_id = ids_arr[0].toString();
			var process_id = dashboard_grid.cells(row_id,1).getValue();

            var dashboard_data = {
                                    "action": "spa_process_power_dashboard",
                                    "flag": "r",
									"process_id":process_id
                                 }
            
            dashboard_data = $.param(dashboard_data);
            var dashboard_data_url = js_data_collector_url + "&" + dashboard_data;
            summary_grid.loadXML(dashboard_data_url);
        }

        function undock_window() {
            dashboard_manager.dashboard_manger_layout.cells('b').undock(300, 300, 900, 700);
            dashboard_manager.dashboard_manger_layout.dhxWins.window('b').maximize();
            dashboard_manager.dashboard_manger_layout.window("b").button("park").hide();
        }
        
        function dashboard_basecase_grid(option, snapshot_name) {
            basecase_win = new dhtmlXWindows();
            b1 = basecase_win.createWindow("b1", 100, 30, 1000, 500);
            if(option == 'basecase') 
                b1.setText("Base Case");
            else 
                b1.setText("Snapshot");
            basecase_win.window('b1').maximize();
            
            dashboard_basecase = basecase_win.window('b1').attachGrid();
            dashboard_basecase.setImagePath(js_image_path + "dhxgrid_web/");
            dashboard_basecase.setHeader(col_header1, null, col_align);
			dashboard_basecase.attachHeader(col_header2, col_align);
            dashboard_basecase.setColumnsVisibility(col_visibility);
            dashboard_basecase.setColAlign(align);
			dashboard_basecase.setColumnMinWidth(col_width);
            dashboard_basecase.setInitWidths(col_width1);
			dashboard_basecase.setColTypes(col_type);
            dashboard_basecase.enableTreeCellEdit(false)
            dashboard_basecase.init();
            
            var term_start = dashboard_manager.filters_form.getItemValue('term_start', true);
            var current_hour = dashboard_manager.filters_form.getItemValue('current_hour');
            var next_hour = dashboard_manager.filters_form.getItemValue('next_hour');
            if (option == 'basecase') 
                var flag = 's';
            else 
                var flag = 's'
            var basecase_data = {
                                    "action": "spa_process_power_dashboard",
                                    "flag": flag,
                                    "term_start": term_start,
                                    "hr_start": current_hour-1,
                                    "hr_no": next_hour,
                                    "grid_type":"tg",
                                    "grouping_column":"group,group2,deal_id"
                                 }
            
            basecase_data = $.param(basecase_data);
            var basecase_data_url = js_data_collector_url + "&" + basecase_data;
            dashboard_basecase.loadXML(basecase_data_url, dashboard_basecase_callback);
        }
        
        function dashboard_basecase_callback() {
            dashboard_basecase.expandAll();
            var no_of_rows = dashboard_basecase.getRowsNum();
            
            dashboard_basecase.forEachRow(function(id){
                var tree_level = dashboard_basecase.getLevel(id);
                
                if (tree_level == 0) {
                    if (id.toLowerCase() == 'onlinestatus') {
                        var childitem = dashboard_basecase.getAllSubItems(id);
                        var childitem_arr = childitem.split(','); 

                        for (i = 0; i < childitem_arr.length; i++) {
                            var row_id = childitem_arr[i].toString();
                            var t_level = dashboard_basecase.getLevel(row_id);
                            
                            if (t_level == 2) {
                                 dashboard_basecase.forEachCell(row_id,function(cellObj,ind){
                                    var value = dashboard_basecase.cells(row_id,ind).getValue();    
                                    if (value == 0) {
                                        dashboard_basecase.cells(row_id,ind).setValue('N');
                                        value = 'n';
                                    } else if (value == 1) {
                                        dashboard_basecase.cells(row_id,ind).setValue('Y');
                                        value = 'y';
                                    } 
                                    var parent_id =  dashboard_basecase.getParentId(row_id);
                                    if(ind > 3) {
										dashboard_basecase.cells(parent_id,ind).setValue('');  
                                    	var change_item = dashboard_basecase.cells(parent_id,0).getValue(); 

										if (value == 'n') {
											base_case_toggle('OnlineCapacity',change_item,i-1,value,ind);
											base_case_toggle('MinimumUnits',change_item,i-1,value,ind);
										}
									}
                                 });
                            }
                        }
                    } else if (id.toLowerCase() == 'solverresults') {
                        var childitem = dashboard_basecase.getAllSubItems(id);
                        var childitem_arr = childitem.split(','); 
                        
                        for (i = 0; i < childitem_arr.length; i++) {
                            var row_id = childitem_arr[i].toString();
                            var t_level = dashboard_basecase.getLevel(row_id);
                            
                            if (t_level == 1) {
                                var name = dashboard_basecase.cells(row_id, 0).getValue();
                                if (name == 'What If' || name == 'Delta') {
                                    dashboard_basecase.deleteRow(row_id);
                                } else {
                                    dashboard_basecase.forEachCell(row_id,function(cellObj,ind){
                                        if(ind > 3) dashboard_basecase.cells(row_id,ind).setValue('');      
                                    });
                                }
                            }
                        }
                    }
                    
                    dashboard_basecase.forEachCell(id,function(cellObj,ind){
                        dashboard_basecase.setCellTextStyle(id,ind,"font-weight:bold;"); 
                        dashboard_basecase.cells(id,ind).setBgColor(total_row_color); 
                        if (id.toLowerCase() == 'onlinestatus' || id.toLowerCase() == 'reserves' || id.toLowerCase() == 'solverresults') {
                            if (ind > 3) {
                                if (id.toLowerCase() == 'reserves') {
									calculate_basecase_reserve(ind);    
                                }
                                dashboard_basecase.cells(id,ind).setValue("");   
                            }
                        }
                    });  
                }
            });
        }
        
        function base_case_toggle(id, change_item, change_pos, nValue, cInd) {
			var resources_category = dashboard_basecase.getAllSubItems(id);
            var resources_category_arr = resources_category.split(',');
            
            for (var cnt = 0; cnt < resources_category_arr.length; cnt++) {
                var level = dashboard_basecase.getLevel(resources_category_arr[cnt]);
                
                if (level == 1) {
					if (dashboard_basecase.cells(resources_category_arr[cnt],0).getValue().toLowerCase() == change_item.toLowerCase()) {
                        var child = dashboard_basecase.getAllSubItems(resources_category_arr[cnt]);
                        var child_arr = child.split(',');
						dashboard_basecase.cells(child_arr[change_pos], cInd).setValue('0');
                    }
                }
            } 
        }
        
        function calculate_basecase_reserve(cInd) {
			var total_online_capacity = dashboard_basecase.cells('OnlineCapacity',cInd).getValue();
            var total_sales = dashboard_basecase.cells('NetTransactionsandLoad',cInd).getValue();
            
            var reserves_child = dashboard_basecase.getAllSubItems('Reserves');
            var reserves_child_arr = reserves_child.split(',');
            
            var available = 0;
            var actual = 0;
            for (cnt = 0; cnt < reserves_child_arr.length; cnt++) {
                if (dashboard_basecase.getLevel(reserves_child_arr[cnt]) == 1 && dashboard_basecase.cells(reserves_child_arr[cnt],0).getValue().toLowerCase() == 'actual spinning reserve') {
                    dashboard_basecase.cells(reserves_child_arr[cnt],cInd).setValue(total_online_capacity - total_sales);  
                    available = total_online_capacity - total_sales;
                    var r_parent_id = dashboard_basecase.getParentId(reserves_child_arr[cnt]);
                }
                
                if (dashboard_basecase.getLevel(reserves_child_arr[cnt]) == 1 && dashboard_basecase.cells(reserves_child_arr[cnt],0).getValue().toLowerCase() == 'contracted spin sales') {
                    actual = dashboard_basecase.cells(reserves_child_arr[cnt],cInd).getValue();       
                }
                
                if (dashboard_basecase.getLevel(reserves_child_arr[cnt]) == 1 && dashboard_basecase.cells(reserves_child_arr[cnt],0).getValue().toLowerCase() == 'total spin') {
                    dashboard_basecase.cells(reserves_child_arr[cnt],cInd).setValue(available - actual);        
                }
			}
        }
		
		function check_exception() {
			var exception_hour_ind = 0;
			var flag = 0;
			dashboard_grid.forEachCell('Reserves',function(cellObj,ind){
				if (ind > 3 && dashboard_grid.cells('Reserves', ind).getValue() == 'Add Unit' && flag == 0) {
					exception_hour_ind = ind;
					flag = 1;
				}
			}); 
			return exception_hour_ind-1;
		}
        
        function dashboard_expand_collapse() {
            if (expand_collapse_state == 0) {
                dashboard_grid.expandAll();
                expand_collapse_state = 1;
            } else if (expand_collapse_state == 1) {
                dashboard_grid.collapseAll();
                dashboard_grid.openItem('SolverResults')
                
                var solver_child = dashboard_grid.getAllSubItems('SolverResults');
                var solver_child_arr = solver_child.split(',')
                for (cnt = 0; cnt < solver_child_arr.length; cnt++) {
                    var level = dashboard_grid.getLevel(solver_child_arr[cnt]);
                    if (level == 1) {
                        dashboard_grid.openItem(solver_child_arr[cnt]);
                    }
                }
                
                expand_collapse_state = 0;
            }   
        }
        
        function dashboard_snapshot_popup(call_from) {
            snapshot_popup = new dhtmlXPopup();
            snapshot_form = snapshot_popup.attachForm(
                [
                    {type: "settings", position: "label-left", labelWidth: 100, inputWidth: 160, position: "label-left", offsetLeft: 20},
                    {type: "combo", name: "snapshot_id", label: "Snapshot Name", value:""},
                    {type: "input", name: "snapshot_name", label: "Snapshot Name", value:""},
                    {type: "button", value: "Ok", img: "tick.png"}
                ]);
            
            var cm_param = {
                "action": "('SELECT dashboard_snaphots_id, dashboard_snaphots_name FROM dashboard_snaphots')",
                "call_from": "form",
                "has_blank_option": "false"
            };

            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;
            var snapshot_obj = snapshot_form.getCombo('snapshot_id');
            snapshot_obj.clearAll();
            snapshot_obj.setComboText('');
            snapshot_obj.load(url);
            
            var h = dashboard_manager.dashboard_manger_layout.cells('a').getHeight();
            if (call_from == 'save_snapshot') {
                pos = 350;
				var today = new Date();
				snapshot_form.setItemValue('snapshot_name', today);
				snapshot_form.hideItem('snapshot_id');
            } else if (call_from == 'snapshot') {
                pos = 420;
                snapshot_form.hideItem('snapshot_name');
            }
            snapshot_popup.show(pos,h+20,50,50);
            
            snapshot_form.attachEvent("onButtonClick", function(name){
                if (call_from == 'save_snapshot') {
                    var snapshot_name = snapshot_form.getItemValue('snapshot_name');
                    dashboard_save_snapshot(snapshot_name)
                } else if (call_from == 'snapshot') {
                    var snapshot_name = snapshot_form.getItemValue('snapshot_id');
                    dashboard_snapshot(snapshot_name)
                }
                snapshot_popup.hide();
            });
        }
        
        function dashboard_save_snapshot(snapshot_name) {
            var pdf_xml = dashboard_grid.toGetPDFXml(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
            pdf_xml = pdf_xml.replace(/\'/g, "''");
            var pdf_xml_data = {
                                    "action": "spa_process_power_dashboard",
                                    "flag": "p",
                                    "snapshot_name": snapshot_name,
                                    "pdf_xml": pdf_xml
                                 }
            
            adiha_post_data('alert', pdf_xml_data, '', '', '', '', '');
        }
        
        function dashboard_snapshot(snapshot_name) {
            var pdf_xml_data = {
                                    "action": "spa_process_power_dashboard",
                                    "flag": "x",
                                    "snapshot_id": snapshot_name
                                 }
            
            adiha_post_data('return_array', pdf_xml_data, '', '', 'dashboard_snapshot_callback', '', '');
        }
        
        function dashboard_snapshot_callback(result) {
            var pdf_xml = result[0][0];
            var y = document.createElement("div");
            y.style.display = "none";
            document.body.appendChild(y);
            var m = "form_1";
			y.innerHTML = '<form id="' + m + '" method="post" action="' + js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php" accept-charset="utf-8"  enctype="application/x-www-form-urlencoded" target="_blank"><input type="hidden" name="grid_xml" id="grid_xml"/> </form>';
            document.getElementById(m).firstChild.value = pdf_xml;
            document.getElementById(m).submit();
            y.parentNode.removeChild(y);
        }
        
    </script>
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