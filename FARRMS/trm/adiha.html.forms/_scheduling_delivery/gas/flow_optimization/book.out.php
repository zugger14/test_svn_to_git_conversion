<?php
/**
* Book out screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
        <?php require('../../../../adiha.php.scripts/components/include.file.v3.php'); ?>
    </head>
<body>
<?php
	$name_space = 'ns_book_out';
	$form_name = 'form_book_out';
	$todays_date = date('Y-m-d');
    $flow_date_from = get_sanitized_value($_GET['flow_date_from'] ?? $todays_date);
    $flow_date_to = get_sanitized_value($_GET['flow_date_to'] ?? $todays_date);
    $menu = get_sanitized_value($_GET['menu'] ?? '');
	
	$uom_name = get_sanitized_value($_GET['uom_name'] ?? 'NULL');
	$location_ids = get_sanitized_value($_GET['location_ids'] ?? '');

    $rights_book_out = 10163603;
    $has_rights_book_out = build_security_rights($rights_book_out);
 
    $layout_json = '[
						{
    						id: "a",
    						text: "Filter Criteria",
    						height: 130,
    						fix_size: [true,true]
						},
    					{
    						id: "b",
							text: "Bookout/Back to Back",
							height: 100,
							undock: true
    					},
    					{
    						id: "c",
							text: "Match",
							collapse: true
    					}
    				]';
    $book_out_layout = new AdihaLayout();
	echo $book_out_layout->init_layout('book_out_layout', '', '3E', $layout_json, $name_space);
	
	$form_object = new AdihaForm();
    
    $sp_url_location = "EXEC spa_source_minor_location 's'";
    echo "location_dropdown = ".  $form_object->adiha_form_dropdown($sp_url_location, 0, 1, true) . ";"."\n";

    $sp_url_counterparty = "EXEC spa_getsourcecounterparty 's'";
    echo "counterparty_dropdown = ".  $form_object->adiha_form_dropdown($sp_url_counterparty, 0, 1, true) . ";"."\n";
    
    $sp_url_commodity = "EXEC spa_source_commodity_maintain @flag='c'";
    echo "commodity_dropdown = ".  $form_object->adiha_form_dropdown($sp_url_commodity, 0, 1, true, 50) . ";"."\n";
	
    $filter_sql = "EXEC spa_create_application_ui_json 'j', '10163603', 'BookOut', NULL";
    $filter_arr = readXMLURL($filter_sql);    
    $general_form_structure = $filter_arr[0][2];
    
    echo $book_out_layout->attach_form($form_name, 'a');    
    echo $form_object->init_by_attach($form_name, $name_space);
    echo $form_object->load_form($general_form_structure);

    $menu_name = 'book_out_list_menu';
    $menu_json = "[    		
        	{id:'list_refresh', text:'Refresh', img:'refresh.gif'},                
            
            {id:'t2', text:'Export', img:'export.gif', items:[
                {id:'excel', text:'Excel', img:'excel.gif', imgdis:'excel_dis.gif', title: 'Excel'},
                {id:'pdf', text:'PDF', img:'pdf.gif', imgdis:'pdf_dis.gif', title: 'PDF'}
            ]},
            {id:'expand_collapse', text:'Expand/Collapse', img:'exp_col.gif', imgdis:'exp_col_dis.gif', enabled: 1}
        ]";

	$book_out_list_toolbar = new AdihaMenu();
	echo $book_out_list_toolbar->attach_menu_layout_header($name_space, 'book_out_layout', 'b', $menu_name, $menu_json, 'refresh_book_out_list');
	
    $grid_name = 'grd_book_out_list';
    echo $book_out_layout->attach_grid_cell($grid_name, 'b');
    $book_out_grid = new AdihaGrid();
    echo $book_out_grid->init_by_attach($grid_name, $name_space);
    echo $book_out_grid->set_header("Location/Counterparty,Term Start,Term End,Buy Volume,Sell Volume,process_id,counterparty_id,location_id");
    echo $book_out_grid->set_columns_ids("Counterparty_Name,term_start,term_end,buy_volume,sell_volume,process_id,counterparty_id,location_id");
    echo $book_out_grid->set_widths("*,*,*,*,*,*,*,*");
    echo $book_out_grid->set_column_types("tree,dhxCalendar,dhxCalendar,ro_v,ro_v,ro,ro,ro");
    echo $book_out_grid->set_column_visibility("false,false,false,false,false,true,true,true");
    echo $book_out_grid->set_sorting_preference('str,str,str,str,str,str,str,str');
	echo $book_out_grid->attach_event('', 'onRowDblClicked', 'fx_dbclick_grid');
	echo $book_out_grid->attach_event('', 'onBeforeSelect', 'before_select_book_out');
	echo $book_out_grid->attach_event('', 'onSelectStateChanged', 'load_match_url');
    echo $book_out_grid->set_search_filter(true);
    echo $book_out_grid->set_date_format($date_format, "%Y-%m-%d");
	echo $book_out_grid->return_init();
	echo $book_out_grid->enable_filter_auto_hide();
    echo $book_out_grid->enable_header_menu();

    echo $book_out_layout->close_layout();
?>
<script type="text/javascript">
    var location_ids = '<?php echo $location_ids; ?>';
	var buy_grid_check_flag = 0;
	var sell_grid_check_flag = 0;	
	var uom_name = '<?php echo $uom_name; ?>';
	var menu = '<?php echo $menu; ?>';
	var function_id  = <?php echo $rights_book_out; ?>;
	
	$(function() {
		if (menu != '' && menu != 'undefined') {
			ns_book_out.form_book_out.hideItem('back_to_back');
		} else {
			ns_book_out.form_book_out.attachEvent('onChange', function() {
				fx_enable_back_to_back();
			});
		}

		filter_obj = ns_book_out.book_out_layout.cells('a');
        var layout_a_obj = ns_book_out.book_out_layout.cells("a");
        load_form_filter(filter_obj, layout_a_obj, function_id, 2, '', '', '', 'layout');
        
        ns_book_out.form_book_out.setItemValue('dt_as_of_date', '<?php echo $flow_date_from; ?>');
        ns_book_out.form_book_out.setItemValue('dt_term_start', '<?php echo $flow_date_from; ?>');
        ns_book_out.form_book_out.setItemValue('dt_term_end', '<?php echo $flow_date_to; ?>');
		
		var location_cmb = ns_book_out.form_book_out.getCombo('cmb_location');
		if (location_ids != '') {
			$.each(location_ids.split(','), function(index, value) {
				if (value != '') {
					location_cmb.setChecked(location_cmb.getIndexByValue(value), true);
				}
			});
		}
		
		if (menu == 'back_to_back') {
			ns_book_out.form_book_out.checkItem('back_to_back');
			fx_enable_back_to_back();
		} else {
			refresh_book_out_list('list_refresh');
		}
		
		var grid_object = ns_book_out.book_out_layout.cells('b').getAttachedObject();
		grid_object.attachEvent('onXLE', function() {
			grid_object.setUserData('', 'expand_status', 0);
		});
	});
	
    function fx_enable_back_to_back() {
		var is_back_to_back = ns_book_out.form_book_out.isItemChecked('back_to_back');
		
		if (is_back_to_back) {
			var view = 'b2b';
			ns_book_out.book_out_list_menu.hideItem('expand_collapse');
		} else {
			var view = 'def';
			ns_book_out.book_out_list_menu.showItem('expand_collapse');
		}

		var firstShow = ns_book_out.book_out_layout.cells("b").showView(view);
		
		// view became visible first time, loading content
		if (firstShow) {
			if (view == 'b2b') {
				fx_init_b2b_grid();
				if (menu != '' && menu != 'undefined') {
					refresh_book_out_list('list_refresh_b2b');
				}
			}
		}
	}
	
	function fx_init_b2b_grid() {
		ns_book_out.grd_book_out_list_b2b = ns_book_out.book_out_layout.cells("b").attachGrid();
		ns_book_out.grd_book_out_list_b2b.setImagePath(js_image_path);
		ns_book_out.grd_book_out_list_b2b.setHeader('Location,Counterparty,Term Start,Term End,Buy Volume,Sell Volume,process_id,counterparty_id,location_id');
		ns_book_out.grd_book_out_list_b2b.setColumnIds("location_name,Counterparty_Name,term_start,term_end,buy_volume,sell_volume,process_id,counterparty_id,location_id".replace(/, */g , ","));
		ns_book_out.grd_book_out_list_b2b.setInitWidths('*,*,*,*,*,*,*,*');
		ns_book_out.grd_book_out_list_b2b.setColTypes("ro,ro,dhxCalendar,dhxCalendar,ro,ro,ro,ro,ro".replace(/, */g , ","));
		ns_book_out.grd_book_out_list_b2b.setColumnsVisibility('false,true,false,false,false,false,true,true,true');
		ns_book_out.grd_book_out_list_b2b.setColSorting('str,str,str,str,str,str,str,str,str');
		ns_book_out.grd_book_out_list_b2b.attachEvent("onRowDblClicked", fx_dbclick_grid);
		ns_book_out.grd_book_out_list_b2b.attachEvent("onSelectStateChanged", load_match_url);
		ns_book_out.grd_book_out_list_b2b.attachHeader('#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter');
		ns_book_out.grd_book_out_list_b2b.setDateFormat(user_date_format,'%Y-%m-%d');
		ns_book_out.grd_book_out_list_b2b.init();
		ns_book_out.grd_book_out_list_b2b.enableHeaderMenu();
		ns_book_out.grd_book_out_list_b2b.enableFilterAutoHide();
		ns_book_out.grd_book_out_list_b2b.i18n.decimal_separator = '.';
		ns_book_out.grd_book_out_list_b2b.i18n.group_separator = ',';
	}

	function load_match_url(id, ind) {
		var b2b = ns_book_out.form_book_out.isItemChecked('back_to_back');
		var grid_obj_parent = ((b2b) ? ns_book_out.grd_book_out_list_b2b : ns_book_out.grd_book_out_list);

		var counterparty_id = grid_obj_parent.cells(id, grid_obj_parent.getColIndexById('counterparty_id')).getValue();
		var location_id = grid_obj_parent.cells(id, grid_obj_parent.getColIndexById('location_id')).getValue();
        var term_start = grid_obj_parent.cells(id, grid_obj_parent.getColIndexById('term_start')).getValue();
        var term_end = grid_obj_parent.cells(id, grid_obj_parent.getColIndexById('term_end')).getValue();
        var process_id = grid_obj_parent.cells(id, grid_obj_parent.getColIndexById('process_id')).getValue();
		var dt_term_start = ns_book_out.form_book_out.getItemValue('dt_term_start', true);
		var dt_term_end = ns_book_out.form_book_out.getItemValue('dt_term_end', true);
		var commodity_id = ''; 
		if(ns_book_out.grd_book_out_list)
			commodity_id = ns_book_out.grd_book_out_list.getUserData("", "commodity_id");
		
		var location_name = grid_obj_parent.cells(
				((b2b) ? id : grid_obj_parent.getParentId(id))
				, grid_obj_parent.getColIndexById('Counterparty_Name')).getValue();
				
		var post_data = {
			call_from_ui: "book_out",
			b2b: b2b,
			counterparty_id: counterparty_id,
			location_id: location_id,
			term_start: term_start,
			term_end: term_end,
			process_id: process_id,
			uom_name: uom_name,
			location_name: location_name,
			flow_date_from: dt_term_start,
			flow_date_to: dt_term_end,
			commodity_id: commodity_id
		};
		
		var url = app_form_path + '../adiha.html.forms/_scheduling_delivery/gas/flow_optimization/flow.deal.match.php';
		ns_book_out.book_out_layout.cells('a').collapse();
		ns_book_out.book_out_layout.cells('c').expand();
		ns_book_out.book_out_layout.cells('c').showArrow();
		ns_book_out.book_out_layout.progressOn();
		ns_book_out.book_out_layout.cells("c").attachURL(url, false, post_data);
		ns_book_out.book_out_layout.attachEvent('onContentLoaded', function() {
			if (id = 'c') {
				ns_book_out.book_out_layout.cells('b').collapse();
				ns_book_out.book_out_layout.progressOff();
			}
		});
	}

	function before_select_book_out(new_row, old_row, new_col_index) {
		var tree_level = ns_book_out.grd_book_out_list.getLevel(new_row);
		if (tree_level == 0) {
			return false;
		}

		return true;		
	}

    function fx_dbclick_grid(row_id, col_ind) {
		if (this.getColType(0) == 'tree') {
			var tree_level = this.getLevel(row_id);
			if (tree_level == 0) {
				if (!this.getOpenState(row_id)) {	
					this.openItem(row_id);
				} else {
					this.closeItem(row_id);
				}
			}
		}
		
		return false;
    }

	function refresh_book_out_list(args, selected_location_id) {
		var book_out_grid = ns_book_out.grd_book_out_list;
		var b2b = ns_book_out.form_book_out.isItemChecked('back_to_back');
		if (b2b) {
			book_out_grid = ns_book_out.grd_book_out_list_b2b;
		}

		if (args == 'list_refresh' || args == 'list_refresh_b2b') {
			if (!validate_form(ns_book_out.form_book_out)) {
				return;
			}
			
			ns_book_out.book_out_layout.cells('a').collapse();
			ns_book_out.book_out_layout.progressOn();

			var counterparty_id = ns_book_out.form_book_out.getItemValue('cmb_counterparty');
			var location_id_obj = ns_book_out.form_book_out.getCombo('cmb_location');
			var location_id = location_id_obj.getChecked();
			var term_start = ns_book_out.form_book_out.getItemValue('dt_term_start', true);
			var term_end = ns_book_out.form_book_out.getItemValue('dt_term_end', true);
            var commodity = ns_book_out.form_book_out.getItemValue('cmb_commodity', true);
            var as_of_date = ns_book_out.form_book_out.getItemValue('dt_as_of_date', true);
			
			var sp_url_param = {
				"flag": 'a',                    
                "counterparty_id": counterparty_id,
                "location_ids": location_id.join(),
                "term_start_date": term_start,
                "term_end_date": term_end,
                "commodity": commodity,   
                "as_of_date": as_of_date,                        	                        
                "action": "spa_book_out",
                "grouping_column": ((b2b) ? '' : 'location_name,counterparty_name'),
                "grid_type": ((b2b) ? 'g' : 'tg'),
				"call_from": ((b2b) ? 'b2b' : 'opt_book_out')
			};
			
	        sp_url_param  = $.param(sp_url_param );
	        var sp_url  = js_data_collector_url + "&" + sp_url_param ;
			
			book_out_grid.clearAll();
			book_out_grid.loadXML(sp_url, function() {
				ns_book_out.book_out_layout.cells('c').detachObject();
				ns_book_out.book_out_layout.progressOff();
				if (!ns_book_out.book_out_layout.cells('c').isCollapsed()) {
					ns_book_out.book_out_layout.cells('c').collapse();
				}
				ns_book_out.book_out_layout.cells('c').hideArrow();
				
				var select_row_id = '';
				if(selected_location_id != '') {
					book_out_grid.forEachRow(function(rid) {
						book_out_grid.forEachCell(rid, function(cell_obj, cid) {
							if(book_out_grid.getColumnId(cid) == 'location_id' && cell_obj.getValue() == selected_location_id) {
								select_row_id = rid;	
							}
						});
					});
					book_out_grid.selectRow(select_row_id);
				}

				//store commodity on grid userdata
				if(ns_book_out.grd_book_out_list)
					ns_book_out.grd_book_out_list.setUserData("", "commodity_id", commodity);
			});
        } else if (args == 'excel') {
			path = js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php';
            book_out_grid.toExcel(path);
		} else if (args == 'pdf') {
			path = js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php';
            book_out_grid.toPDF(path);
		} else if(args == 'expand_collapse') {
			expand_status = book_out_grid.getUserData('', 'expand_status');

			if (expand_status == 0) {
                book_out_grid.expandAll();
            } else {
                book_out_grid.collapseAll();
			}
			
			book_out_grid.setUserData('','expand_status', expand_status == 0 ? 1 : 0);
		}
	}
</script>