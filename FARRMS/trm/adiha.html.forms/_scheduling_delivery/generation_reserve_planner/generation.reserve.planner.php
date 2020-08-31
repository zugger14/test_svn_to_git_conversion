<?php
/**
* Generation reserve planner screen
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
    include '../../../adiha.php.scripts/components/include.file.v3.php';
    $php_script_loc = $app_php_script_loc;
    
	$rights_generation_reserve_planner = 10166700;
	$rights_generation_reserve_planner_iu = 10166710;
	$rights_generation_reserve_planner_delete = 10166711;
	
	   list (
        $has_rights_generation_reserve_planner, 
        $has_rights_generation_reserve_planner_iu,
        $has_rights_generation_reserve_planner_delete
    ) = build_security_rights(
        $rights_generation_reserve_planner, 
        $rights_generation_reserve_planner_iu,
        $rights_generation_reserve_planner_delete
       
    );
	
	
    $form_name = 'generation_reserve_planner_form';
    $form_namespace = 'generation_reserve_planner';
    $layout_json = '[
                        {id: "a", text: "Filters", header: true, height:100},
                        {id: "b", text: "Generation Reserve Planner", header: true, undock: true}
                    ]';
    $layout_obj = new AdihaLayout();
    $filter_form_obj = new AdihaForm();
    
    echo $layout_obj->init_layout('generation_reserve_planner_layout', '', '2E', $layout_json, $form_namespace);
    
    $menu_name = 'generation_reserve_planner_menu';
    $menu_json = '[
                    {id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif"},
                    {id:"export", text:"Export", img:"export.gif", imgdis:"export_dis.gif", enabled:false,items:[
                        {id:"excel", text:"Excel", img:"excel.gif"},
                        {id:"pdf", text:"PDF", img:"pdf.gif"}
                    ]},
                    {id:"expand_collapse", text:"Expand/Collapse", img:"exp_col.gif", imgdis:"exp_col_dis.gif",enabled:false} ,
                    {id:"save", text:"Save", img:"save.gif", imgdis:"save_dis.gif", enabled:"' . $rights_generation_reserve_planner_iu . '"}   
                ]';

    echo $layout_obj->attach_menu_layout_cell($menu_name, 'b', $menu_json, $form_namespace.'.menu_click');
        
    $filter_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10166700', @template_name='GenerationReservePlanner', @group_name='General'";
    $filter_arr = readXMLURL2($filter_sql);
    $form_json = $filter_arr[0]['form_json'];
    
    echo $layout_obj->attach_form($form_name, 'a');
    $filter_form_obj->init_by_attach($form_name, $form_namespace);
    echo $filter_form_obj->load_form($form_json);
    echo $layout_obj->close_layout();
    ?>
    
    <script type="text/javascript">
        var total_row_color = '#FCFCC5';
        var edit_row_color = '#C4F0FF';
        var negative_value_color = '#FF0303';
        var unavailable_color = '#F7CBD5'
        var online_cell_value = new Array();
        var expand_collapse_state = 1;
        var changed_cell_value = new Array();
        var capacity_uasge_value = new Array();
		var exception_count = 0;
		
		var has_rights_generation_reserve_planner_iu = '<?php echo $has_rights_generation_reserve_planner_iu;?>';
        var has_rights_generation_reserve_planner_delete = '<?php echo $has_rights_generation_reserve_planner_delete;?>';
        
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
        
        generation_reserve_planner.menu_click = function (id) {
            switch(id) {
                case "refresh":
                    generation_reserve_planner_refresh();
                    break;
                case "pdf":
                    generation_reserve_planner_grid.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                    break;
                case "excel":
                    generation_reserve_planner_grid.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                    break;
                case "expand_collapse":
                    grid_expand_collapse();
                    break;
                case "save":
                    generation_reserve_planner_save();
                    break;
            }
        }
        
        generation_reserve_planner_refresh = function() {
            changed_cell_value = [];
			exception_count = 0;
            generation_reserve_planner.generation_reserve_planner_layout.cells('a').collapse();
            generation_reserve_planner.generation_reserve_planner_layout.cells('b').progressOn();
            var term_start = generation_reserve_planner.generation_reserve_planner_form.getItemValue('term_start');
            var current_hour = generation_reserve_planner.generation_reserve_planner_form.getItemValue('current_hour');
            var next_hour = generation_reserve_planner.generation_reserve_planner_form.getItemValue('next_hour');
            
            col_header1 = 'Group/Category/Gen,process_id,process_row_id,id';
            col_header2 = '#rspan,#rspan,#rspan,#rspan';
            col_visibility = 'fase,true,true,true';
            col_type = 'tree,ro,ro,ro';
            col_width = '300,0,0,ro';
            col_width1 = '300,0,0,0';
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
            
            generation_reserve_planner_grid = generation_reserve_planner.generation_reserve_planner_layout.cells('b').attachGrid();
            generation_reserve_planner_grid.setImagePath(js_image_path + "dhxgrid_web/");
            generation_reserve_planner_grid.setHeader(get_locale_value(col_header1,true), null, col_align);
			generation_reserve_planner_grid.attachHeader(col_header2, col_align);
            generation_reserve_planner_grid.setColumnsVisibility(col_visibility);
            generation_reserve_planner_grid.setColAlign(align);
			generation_reserve_planner_grid.setColumnMinWidth(col_width);
            generation_reserve_planner_grid.setInitWidths(col_width1);
			generation_reserve_planner_grid.setColTypes(col_type);
            generation_reserve_planner_grid.enableTreeCellEdit(false)
            generation_reserve_planner_grid.init();
            generation_reserve_planner_grid.enableUndoRedo();
            generation_reserve_planner_grid.enableBlockSelection();
            generation_reserve_planner_grid.enableEditEvents(true,false,true);
            generation_reserve_planner_grid.attachEvent("onEditCell", generation_reserve_planner_grid_cell_edit);
            generation_reserve_planner_grid.attachEvent("onRowDblClicked", generation_reserve_db_click);
            generation_reserve_planner_grid.attachEvent("onHeaderClick", function(ind,obj){
                generation_reserve_planner_grid.clearSelection();
            });
			generation_reserve_planner_grid.attachEvent("onBlockSelected", block_select_function);
            
            term_start = generation_reserve_planner.generation_reserve_planner_form.getItemValue('term_start', true);
            var flag = 'g';
            
            var grid_data = {
                                    "action": "spa_process_power_dashboard",
                                    "flag": flag,
                                    "term_start": term_start,
                                    "hr_start": current_hour-1,
                                    "hr_no": next_hour,
                                    "solver_decision": "n",
                                    "grid_type":"tg",
                                    "grouping_column":"group,group2,deal_id"
                                 }
            
            grid_data = $.param(grid_data);
            var grid_date_url = js_data_collector_url + "&" + grid_data;
            generation_reserve_planner_grid.loadXML(grid_date_url, generation_reserve_planner_refresh_callback);
            
            generation_reserve_planner.generation_reserve_planner_menu.setItemEnabled('export');
            generation_reserve_planner.generation_reserve_planner_menu.setItemEnabled('expand_collapse');
			
			if(has_rights_generation_reserve_planner_iu){
            generation_reserve_planner.generation_reserve_planner_menu.setItemEnabled('save');
			} 
        }
        
        generation_reserve_planner_refresh_callback = function() {
            generation_reserve_planner_grid.expandAll();
            
            generation_reserve_planner_grid.forEachRow(function(id){
                var tree_level = generation_reserve_planner_grid.getLevel(id);
                if (tree_level == 0) {
                    generation_reserve_planner_grid.setRowColor(id,total_row_color);
                }
                
                var name = generation_reserve_planner_grid.cells(id,0).getValue();
                if (name.toLowerCase() == 'what if purchase trade +ve' || name.toLowerCase() == 'what if sale trade -ve' || name.toLowerCase() == 'spin requirement' || name.toLowerCase() == 'peak load') {
                    generation_reserve_planner_grid.setRowColor(id,edit_row_color);
                    generation_reserve_planner_grid.forEachCell(id,function(cellObj,ind){
                        if (ind > 3) {
                            generation_reserve_planner_grid.setCellExcellType(id,ind,"ed"); 
                        }
                   });
                }
                
                if (name.toLowerCase() == 'capacity usage') {
                    var childitem = generation_reserve_planner_grid.getAllSubItems(id);
                    var childitem_arr = childitem.split(','); 
                    
                    for (i = 0; i < childitem_arr.length; i++) {
                        var row_id = childitem_arr[i];
                        var child_tree_level = generation_reserve_planner_grid.getLevel(row_id);
                        
                        if (child_tree_level == 1) {
                            generation_reserve_planner_grid.forEachCell(row_id,function(cellObj,ind){
                                if (ind > 3) {
                                    var value = generation_reserve_planner_grid.cells(row_id,ind).getValue();
                                    var deal_id = generation_reserve_planner_grid.cells(row_id,3).getValue();
                                    capacity_uasge_value.push([deal_id, ind, value]);
                                }
                            }); 
                        }
                        generation_reserve_planner_grid.setRowHidden(row_id,true);
                    }
                    generation_reserve_planner_grid.setRowHidden(id,true);
                }
                
                if (name.toLowerCase() == 'online status') {
                    var childitem = generation_reserve_planner_grid.getAllSubItems(id);
                    var childitem_arr = childitem.split(','); 
                    
                    for (i = 0; i < childitem_arr.length; i++) {
                        var row_id = childitem_arr[i];
                        var child_tree_level = generation_reserve_planner_grid.getLevel(row_id);
                        
                        if (child_tree_level == 2) {
                            var child_parent_id = generation_reserve_planner_grid.cells(generation_reserve_planner_grid.getParentId(row_id),0).getValue();
                            var child_ref_id = generation_reserve_planner_grid.cells(row_id,3).getValue();
                            
                            generation_reserve_planner_grid.forEachCell(row_id,function(cellObj,ind){
                                if (ind > 3) {
                                    var status = generation_reserve_planner_grid.cells(row_id,ind).getValue();
                                    online_offline_toggle(child_parent_id, child_ref_id, status, ind);
                                }
                            }); 
                        }
                        generation_reserve_planner_grid.setRowHidden(row_id,true);
                    }
                    generation_reserve_planner_grid.setRowHidden(id,true);
                }
                
                if (name.toLowerCase() == 'online capacity') {
                    var childitem = generation_reserve_planner_grid.getAllSubItems(id);
                    var childitem_arr = childitem.split(','); 
                    
                    for (i = 0; i < childitem_arr.length; i++) {
                        var child_tree_level = generation_reserve_planner_grid.getLevel(childitem_arr[i]);
                        var child_parent_id = generation_reserve_planner_grid.cells(generation_reserve_planner_grid.getParentId(childitem_arr[i]),0).getValue();
                        
                        if (child_tree_level == 2 && child_parent_id.toLowerCase() != 'purchases') {
                            generation_reserve_planner_grid.forEachCell(childitem_arr[i],function(cellObj,ind){
                                if (ind > 3) {
                                    var val = generation_reserve_planner_grid.cells(childitem_arr[i],ind).getValue();
                                    if (val == '-') {
                                        generation_reserve_planner_grid.cells(childitem_arr[i],ind).setBgColor(unavailable_color); 
                                    }
                                }
                            });
                            var link_value = generation_reserve_planner_grid.cells(childitem_arr[i], 0).getValue();
                            var new_link_value = "<a href=# onclick=open_hyperlink('" + childitem_arr[i].toString() + "','deal')>" + link_value + "</a>";   
                            generation_reserve_planner_grid.cells(childitem_arr[i], 0).setValue(new_link_value);    
                        }
                    }
                }
				
				if (name.toLowerCase() == 'loads') {
					var childitem = generation_reserve_planner_grid.getAllSubItems(id);
                    var childitem_arr = childitem.split(','); 
					
					for (i = 0; i < childitem_arr.length; i++) {
                        var child_tree_level = generation_reserve_planner_grid.getLevel(childitem_arr[i]);
                        
						if (child_tree_level == 1) {
							generation_reserve_planner_grid.forEachCell(childitem_arr[i],function(cellObj,ind){
                                if (ind > 3) {
                                    var value = generation_reserve_planner_grid.cells(childitem_arr[i],ind).getValue() * -1;
                                    generation_reserve_planner_grid.cells(childitem_arr[i],ind).setValue(value);
                                }
                            });   
						}
                    }
				}
				
				if (name.toLowerCase() == 'ancillary') {
					var childitem = generation_reserve_planner_grid.getAllSubItems(id);
                    var childitem_arr = childitem.split(','); 
					
					for (i = 0; i < childitem_arr.length; i++) {
                        var child_tree_level = generation_reserve_planner_grid.getLevel(childitem_arr[i]);
						var child_name = generation_reserve_planner_grid.cells(childitem_arr[i],0).getValue()
						
						if (child_tree_level == 1 && (child_name.toLowerCase() == 'interruptible loads' || child_name.toLowerCase() == 'sale 10min spin' || child_name.toLowerCase() == 'sale spin')) {
							generation_reserve_planner_grid.forEachCell(childitem_arr[i],function(cellObj,ind){
                                if (ind > 3) {
                                    var value = generation_reserve_planner_grid.cells(childitem_arr[i],ind).getValue() * -1;
                                    generation_reserve_planner_grid.cells(childitem_arr[i],ind).setValue(value);
                                }
                            });   
						}
                    }
				}
            });
            
            generation_reserve_planner_grid.forEachCell('Reserves',function(cellObj,ind){
                if (ind > 3) calculate_reserve(ind);
            });
            
            generation_reserve_planner.generation_reserve_planner_layout.cells('b').progressOff();
        }
        
        online_offline_toggle = function(child_parent_id, child_ref_id, status, ind) {
            var toggle_list = generation_reserve_planner_grid.getAllSubItems('OnlineCapacity');
            var toggle_list_arr = toggle_list.split(',');
            
            for (var cnt = 0; cnt < toggle_list_arr.length; cnt++) {
                var level = generation_reserve_planner_grid.getLevel(toggle_list_arr[cnt]);   
                
                if (level == 2) {
                    var p_id = generation_reserve_planner_grid.cells(generation_reserve_planner_grid.getParentId(toggle_list_arr[cnt]),0).getValue();
                    var c_ref_id = generation_reserve_planner_grid.cells(toggle_list_arr[cnt],3).getValue();
                    if(p_id == child_parent_id && c_ref_id == child_ref_id) {
                        var set_value = generation_reserve_planner_grid.cells(toggle_list_arr[cnt], ind).getValue();
                        online_cell_value.push([child_ref_id, ind, set_value]);
						
						if (set_value == '0') {
							generation_reserve_planner_grid.cells(toggle_list_arr[cnt], ind).setValue('-');
						} else if (status == 0 && set_value != '-') {
                            generation_reserve_planner_grid.cells(toggle_list_arr[cnt], ind).setValue('0');
                        } 
                        
                        for (var i = 0; i < capacity_uasge_value.length; i++) {
                            if(capacity_uasge_value[i][0] == child_ref_id && capacity_uasge_value[i][1] == ind) {
                                var capacity_uasge_val = capacity_uasge_value[i][2];
                                if (capacity_uasge_val != 0 && status != 0)
                                    generation_reserve_planner_grid.cells(toggle_list_arr[cnt], ind).setValue(capacity_uasge_value[i][2]);   
                            }
                        }
                    }
                }
            }
        }
        
        calculate_reserve = function(cInd) {
			var spin = 0;
            var spin_with_10 = 0;
            var spin_available = 0;
            var spin_non_firm = 0;
            var spin_interruptible = 0;
            
            var all_ids = generation_reserve_planner_grid.getAllRowIds();
            var all_ids_arr = all_ids.split(',');
            
            for (cn = 0; cn < all_ids_arr.length; cn++) {
                var parent_id = generation_reserve_planner_grid.getParentId(all_ids_arr[cn]);
                var id_name = generation_reserve_planner_grid.cells(all_ids_arr[cn], 0).getValue();
                var tree_level = generation_reserve_planner_grid.getLevel(all_ids_arr[cn]);
                
                //To calculate spin
                if (id_name.toLowerCase() == 'online capacity' || id_name.toLowerCase() == 'purchase spin' || id_name.toLowerCase() == 'loads' || id_name.toLowerCase() == 'sale spin') {
                    spin = parseFloat(spin) + parseFloat(generation_reserve_planner_grid.cells(all_ids_arr[cn], cInd).getValue());
                } 
			}
			
            for (cn = 0; cn < all_ids_arr.length; cn++) {   
				var id_name = generation_reserve_planner_grid.cells(all_ids_arr[cn], 0).getValue();
				if (cn == 0) {
					spin_with_10 = spin_with_10 + spin;
					spin_available = spin_available + spin;
					spin_non_firm = spin_non_firm + spin;
					spin_interruptible = spin_interruptible + spin;	
				}
				
                //To calculate spin with 10 minute ancillary spin deals
                if (id_name.toLowerCase() == 'purchase 10min spin' || id_name.toLowerCase() == 'sale 10min spin') {
                    spin_with_10 = spin_with_10 + parseFloat(generation_reserve_planner_grid.cells(all_ids_arr[cn], cInd).getValue());
                } 
				
                //To calculate spin available upon cutting non firm sales
                if (id_name.toLowerCase() == 'non firm sales from trades') {
                    spin_available = spin_available - parseFloat(generation_reserve_planner_grid.cells(all_ids_arr[cn], cInd).getValue());
                } 
                
                //To calculate spin upon cutting non firm purchases
                if (id_name.toLowerCase() == 'non firm purchases from trades') {
                    spin_non_firm = spin_non_firm - parseFloat(generation_reserve_planner_grid.cells(all_ids_arr[cn], cInd).getValue());
                } 
                
                //To calculate spin upon cutting interruptible loads
                if (id_name.toLowerCase() == 'interruptible loads') {
					spin_interruptible = spin_interruptible - parseFloat(generation_reserve_planner_grid.cells(all_ids_arr[cn], cInd).getValue());
				}     
            }
			
			var reserve_ids = generation_reserve_planner_grid.getAllSubItems('Reserves');;
            var reserve_ids_arr = reserve_ids.split(',');
            
            for (cn = 0; cn < reserve_ids_arr.length; cn++) {
                var id_name = generation_reserve_planner_grid.cells(reserve_ids_arr[cn], 0).getValue();
                if (id_name.toLowerCase() == 'spin') {
					generation_reserve_planner_grid.cells(reserve_ids_arr[cn], cInd).setValue(spin);
                } else if (id_name.toLowerCase() == 'spin with 10 minute ancillary spin deals') {
                    generation_reserve_planner_grid.cells(reserve_ids_arr[cn], cInd).setValue(spin_with_10);
                } else if (id_name.toLowerCase() == 'spin available upon cutting non firm sales') {
                    generation_reserve_planner_grid.cells(reserve_ids_arr[cn], cInd).setValue(spin_available);
                } else if (id_name.toLowerCase() == 'spin upon cutting non firm purchases') {
                    generation_reserve_planner_grid.cells(reserve_ids_arr[cn], cInd).setValue(spin_non_firm);
                } else if (id_name.toLowerCase() == 'spin upon cutting interruptible loads') {
                    generation_reserve_planner_grid.cells(reserve_ids_arr[cn], cInd).setValue(spin_interruptible);
                } 
            }
			
			clear_cell('Reserves');
			clear_cell('Ancillary');
        }
		
		/*
         * [Clear the cell value of the row]
         */
        function clear_cell(id) {
            generation_reserve_planner_grid.forEachCell(id,function(cellObj,ind){
                if (ind > 3) {
					var val = generation_reserve_planner_grid.cells(id,ind).getValue();
					if (val != 'Add Unit') {
						generation_reserve_planner_grid.cells(id,ind).setValue("");
					}
                }
            });  
        }
		
		generation_reserve_db_click = function(rId,cInd) {
			if (generation_reserve_planner_grid.getLevel(rId) == 2) {
				var parent_id = generation_reserve_planner_grid.getParentId(rId);
                var parent_parent_id = generation_reserve_planner_grid.getParentId(parent_id);
				var parent_name = generation_reserve_planner_grid.cells(parent_id, 0).getValue();
				var val = generation_reserve_planner_grid.cells(rId, cInd).getValue();
				
				if (parent_parent_id.toLowerCase() == 'onlinecapacity' && parent_name.toLowerCase() != 'purchases' && val != '-' && cInd > 3) {
					var name = generation_reserve_planner_grid.cells(rId,0).getValue();
					if (name.toLowerCase() == 'what if purchase trade +ve' || name.toLowerCase() == 'what if sale trade -ve' || name.toLowerCase() == 'spin requirement' || name.toLowerCase() == 'peak load') {
						return true;    
					}

					var child_ref_id = generation_reserve_planner_grid.cells(rId,3).getValue();
					var s_value = generation_reserve_planner_grid.cells(rId,cInd).getValue();
					if(s_value == 0) {
						for (var i = 0; i < online_cell_value.length; i++) {
							if(online_cell_value[i][0] == child_ref_id && online_cell_value[i][1] == cInd) {
								generation_reserve_planner_grid.cells(rId, cInd).setValue(online_cell_value[i][2]);   
							}
						}            
					} else {
						generation_reserve_planner_grid.cells(rId, cInd).setValue('0');
					}
					
					if (jQuery.inArray([rId, cInd], changed_cell_value) == -1) {
						changed_cell_value.push([rId, cInd]);
					}
					
					calculate_reserve(cInd);
				}
			}
			//generation_reserve_planner_grid.setCellTextStyle(rId,cInd,"font-weight:normal;"); 
			//generation_reserve_planner_grid.cells(rId,cInd).setTextColor('#000000'); 
		}
        
        generation_reserve_planner_grid_cell_edit = function(stage,rId,cInd,nValue,oValue) {
            if (stage == 2)  {
				calculate_reserve(cInd);
                
				if (jQuery.inArray([rId, cInd], changed_cell_value) == -1) {
                    changed_cell_value.push([rId, cInd]);
                }
            }
            
            return true;
        }
        
        generation_reserve_planner_save = function() {
			if (exception_count > 0) {
				show_messagebox('Please check the exception');
				return;
			}
			
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
			
			var d_flag = 0;
			var dst_index = 0;
			var row_id = generation_reserve_planner_grid.getRowId(0);
			generation_reserve_planner_grid.forEachCell(row_id,function(cellObj,ind){
				if (generation_reserve_planner_grid.getColLabel(ind,1) == '3-DST') {
					d_flag = 1;
					dst_index= ind;
				}
			});
			
			var grid_xml = '';
            for(cnt = 0; cnt < changed_val_arr.length; cnt++) {
				var deal_id = generation_reserve_planner_grid.cells(changed_val_arr[cnt][0],3).getValue();
				if (deal_id == '') {
					deal_id = generation_reserve_planner_grid.cells(changed_val_arr[cnt][0],0).getValue();
				}
                grid_xml += '<grid deal_id="' + deal_id + '"';
                if (generation_reserve_planner_grid.getColLabel(changed_val_arr[cnt][1],1) == '3-DST') {
                    var s_hour = 3;
                    var is_dst = 1;
                } else {
                    var s_hour = generation_reserve_planner_grid.getColLabel(changed_val_arr[cnt][1],1);
                    var is_dst = 0;
                }
				s_hour = parseInt(s_hour) - 1;
                grid_xml += ' hour="' + s_hour + '"'; 
				
				if (changed_val_arr[cnt][1] < dst_index) {
					var term_ind = changed_val_arr[cnt][1] - generation_reserve_planner_grid.getColLabel(changed_val_arr[cnt][1],1) + 1;
				} else if (changed_val_arr[cnt][1] == dst_index){
					var term_ind = changed_val_arr[cnt][1] - 2 - d_flag;
				} else {
					var term_ind = changed_val_arr[cnt][1] - generation_reserve_planner_grid.getColLabel(changed_val_arr[cnt][1],1) + 1 - d_flag;
				}
				grid_xml += ' term="' + generation_reserve_planner_grid.getColLabel(term_ind,0)  + '"';
				grid_xml += ' value="' + generation_reserve_planner_grid.cells(changed_val_arr[cnt][0],changed_val_arr[cnt][1]).getValue()  + '"';
                grid_xml += ' is_dst="' + is_dst + '"';
                grid_xml += ' />';
                process_id = generation_reserve_planner_grid.cells(changed_val_arr[cnt][0],1).getValue();
            }
            var save_xml = '<Root>' + grid_xml + '</Root>';
			
			var term_start = generation_reserve_planner.generation_reserve_planner_form.getItemValue('term_start', true);
            var current_hour = generation_reserve_planner.generation_reserve_planner_form.getItemValue('current_hour');
            var next_hour = generation_reserve_planner.generation_reserve_planner_form.getItemValue('next_hour');
			
            var flag = 'z';
            var generator_data = {
                                    "action": "spa_process_power_dashboard",
                                    "flag": flag,
                                    "save_xml": save_xml,
                                    "process_id": process_id,
									"term_start": term_start,
                                    "hr_start": current_hour-1,
                                    "hr_no": next_hour,
                                  }
            
            adiha_post_data('alert', generator_data, '', '', 'generation_reserve_planner_refresh', '', '');
        }
        
        /*
         * [Expand/collapse treegrid]
         */
        function grid_expand_collapse() {
            if (expand_collapse_state == 0) {
                generation_reserve_planner_grid.expandAll();
                expand_collapse_state = 1;
            } else if (expand_collapse_state == 1) {
                generation_reserve_planner_grid.collapseAll();
                expand_collapse_state = 0;
            }   
        }
        
        function open_hyperlink(row_id) {
            var deal_id = generation_reserve_planner_grid.cells(row_id, 3).getValue();
            parent.TRMHyperlink(10131010,deal_id,'n','NULL');
        }
		
		/*
         * [Function to drag and select the block]
         */
        function block_select_function() {
            var top_row = generation_reserve_planner_grid.getSelectedBlock().LeftTopRow;
            var bottom_row = generation_reserve_planner_grid.getSelectedBlock().RightBottomRow;
            var left_column = generation_reserve_planner_grid.getSelectedBlock().LeftTopCol;
            var right_column = generation_reserve_planner_grid.getSelectedBlock().RightBottomCol;
            
            if (left_column < 3) return;
            if (top_row != bottom_row) return;
            
			var drag_ind = generation_reserve_planner_grid.cells2(top_row, 0).getValue();
			
			if (drag_ind.toLowerCase() == 'what if purchase trade +ve' || drag_ind.toLowerCase() == 'what if sale trade -ve' || drag_ind.toLowerCase() == 'spin requirement' || drag_ind.toLowerCase() == 'peak load') {
				var copy_value = generation_reserve_planner_grid.cells2(top_row, left_column).getValue();
				
				for (ct = left_column+1; ct <= right_column; ct++) {
                    generation_reserve_planner_grid.cells2(top_row, ct).setValue(copy_value);
                    generation_reserve_planner_grid.cells2(top_row,ct).setBgColor('#FAE2B6');   
                    var rId = generation_reserve_planner_grid.getRowId(top_row);
					if (jQuery.inArray([rId, ct], changed_cell_value) == -1) {
                        changed_cell_value.push([rId, ct]);
                    } 
                }
			}
		}
        
    </script>    
