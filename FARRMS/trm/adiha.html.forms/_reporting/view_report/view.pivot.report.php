<?php
/**
* View pivot report screen
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
        require('../../../adiha.php.scripts/components/include.ssrs.reporting.files.php');
    ?>
</head>
<body>
<?php 
    $form_namespace = 'viewPivotReport';
    $file_path = get_sanitized_value($_POST['file_path'] ?? '');
    $paramset_id = get_sanitized_value($_POST['paramset_id'] ?? '');
    $report_filter = get_sanitized_value($_POST['report_filter'] ?? '');
    $component_id = get_sanitized_value($_POST['items_combined'] ?? '');
    $report_name = get_sanitized_value($_POST['report_name'] ?? '');
    $paramset_hash = get_sanitized_value($_POST['paramset_hash'] ?? '');
    $view_id = get_sanitized_value($_POST['view_id'] ?? '');
    $group_id = get_sanitized_value($_POST['group_id'] ?? '');
    $is_pin = get_sanitized_value($_POST['is_pin'] ?? '');
    $report_id = get_sanitized_value($_POST['report_id'] ?? '');

    // For Standard Reports
    if (($paramset_id == NULL || $component_id == NULL) && $view_id != NULL) {
        $sp_generate_file = "EXEC spa_generate_grid_pivot_file  @grid_name='" . $paramset_hash . "',@exec_sql='" . str_replace("'", "''", $report_filter) . "',@col_script='',@index='0',@primary_key=''"; 
        $file_detail = readXMLURL2($sp_generate_file);
        $file_path = $file_detail[0]['filename'];
        $report_type = 2;
    } else {
        if ($file_path == '') {
            $server_path = $BATCH_FILE_EXPORT_PATH;
            
            $sp_generate_file = "EXEC spa_generate_pivot_file @paramset_id=" . $paramset_id . ", @component_id=" . $component_id . ", @criteria='" . $report_filter . "', @server_path='" . $server_path . "', @report_name='" . $report_name . "'";
            $file_detail = readXMLURL2($sp_generate_file);
            
            $file_path = $file_detail[0]['path'];
            $report_type = 1;
        } else {
            // Using grid name instead of paramset hash for grid pivot.
            $paramset_hash = (isset($_POST["grid_name"]) && $_POST["grid_name"] != '') ? $_POST["grid_name"] : '';      
            $report_type = 2;
        }
    }
    
    $layout_obj = new AdihaLayout();
    $layout_json = '[{id: "a", header:true, text:"View", height:140}, {id: "b", text:"<div><a class=\"undock_report undock_custom\" title=\"Undock\" onClick=\"viewPivotReport.undock_reports()\"></a>Report</div>", header:true}]';
          
    echo $layout_obj->init_layout('pivot_template', '', '2E', $layout_json, $form_namespace);
    
    // attach filter form
    $view_form = new AdihaForm();
    $tab_obj = new AdihaTab();

    $view_form_name = 'view_form';
    echo $layout_obj->attach_form($view_form_name, 'a');

    $sp_url = "EXEC spa_pivot_report_view @flag = 'k', @paramset_hash='" . $paramset_hash . "', @report_type = '" . $report_type . "'";
    $view_dropdown_json = $view_form->adiha_form_dropdown($sp_url, 0, 1, true, $view_id);

    $sp_url = "EXEC spa_pivot_report_view @flag = 'z'";
    $group_dropdown_json = $view_form->adiha_form_dropdown($sp_url, 0, 1, true, $group_id);

    $form_json = '[ 
                    {"type": "settings", "position": "label-top"},
                    {type:"block", width:500, list:[
	                    {type:"combo", name: "view", label:"View", "labelWidth":240, required:true, filtering:true, "inputWidth":240, options:' . $view_dropdown_json . '},
	                    {"type":"newcolumn"},                        
	                    {type: "button", name: "save", value: "", tooltip: "Save View",offsetTop:"30", className: "filter_save"},                    
	                    {"type":"newcolumn"},
	                    {type: "button", name: "delete", value: "", tooltip: "Delete View",offsetTop:"30", className: "filter_delete"},
	                    {"type":"newcolumn"},
	                    {type: "button", name: "copy", value: "", tooltip: "Copy Filter",offsetTop:"30", className: "filter_publish"}
                    ]},
                    {type:"block", list:[
	                    {type:"combo", name: "group", label:"Pin to (Report Group)", "labelWidth":250, filtering:true, disabled:true, "inputWidth":240, options:' . $group_dropdown_json . '},
	                    {"type":"newcolumn"},
	                    {type: "checkbox", "offsetTop":25, position: "label-right", "labelWidht":180, "inputWidth":180, "name":"pin_it", label: "Add to Pinned Reports", checked:false},
	                    {"type":"newcolumn"},
	                    {type: "checkbox", "offsetTop":25, "offsetLeft":15, position: "label-right", "labelWidht":180, "inputWidth":180, "name":"is_public", label: "Public", checked:false}
                    ]}
                ]';

    $view_form->init_by_attach($view_form_name, $form_namespace);
    echo $view_form->load_form($form_json);    
    echo $view_form->attach_event('', 'onChange', $form_namespace . '.form_change');
    echo $view_form->attach_event('', 'onButtonClick', $form_namespace . '.menu_click');

	$tab_json =   '[ 
                    {id:"view", text:"View", active:true}, 
                    {id:"advance", text:"Formatting"}
                    ]';  

    echo $layout_obj->attach_tab_cell('pivot_tab', 'b', $tab_json);
    echo $tab_obj->init_by_attach('pivot_tab', $form_namespace);

    $inner_layout_view = new AdihaLayout();    

    echo $tab_obj->attach_layout('inner_layout_view', 'view', '1C');
    echo $inner_layout_view->init_by_attach('inner_layout_view', $form_namespace);
    echo $inner_layout_view->hide_header('a');
    echo $inner_layout_view->attach_event('', 'onDock', $form_namespace . '.on_dock_report_event');
    echo $inner_layout_view->attach_event('', 'onUnDock', $form_namespace . '.on_undock_report_event');

    $hide_filters = ($is_pin == 'y') ? 'y' : 'n';
    $page_toolbar_json = '[
    	{id:"print", type: "button", img:"print.gif", imgdis:"print_dis.gif", enabled:true, text:"Print", title: "Print"},
    	{id:"undock", type: "button", img:"add_and_condition.png", imgdis:"add_and_condition_dis.png", enabled:true, text:"Undock", title: "Undock"}';
    // Hide Change Filters button for standard report and grid pivot since change filter is not supported currently.
    if ($report_type == 1) {
        $page_toolbar_json .= ', {id:"filters", type: "button", img:"filter_save.gif", imgdis:"filter_save.gif", enabled:true, text:"Change Filters", title: "Change Filters"}';
    }
    $page_toolbar_json .= ']';

    $page_toolbar = new AdihaToolbar();
    echo $inner_layout_view->attach_toolbar_cell('toolbar', 'a');
    echo $page_toolbar->init_by_attach('toolbar', $form_namespace);
    echo $page_toolbar->load_toolbar($page_toolbar_json);
    echo $page_toolbar->attach_event('', 'onClick', $form_namespace . '.page_toolbar_click');

    $inner_layout_advance = new AdihaLayout();    
    echo $tab_obj->attach_layout('inner_layout_advance', 'advance', '2E');
    echo $inner_layout_advance->init_by_attach('inner_layout_advance', $form_namespace);
    echo $inner_layout_advance->hide_header('a');
    echo $inner_layout_advance->hide_header('b');
    echo $inner_layout_advance->set_cell_height('a', 100);

    
    $advance_form = new AdihaForm();

    $advance_form_json = '[ 
                    {"type": "settings", "position": "label-top", "offsetLeft": 10},
                    {type:"input", name: "report_name", label:"Report Name", "labelWidth":250, "inputWidth":240},
                    {"type":"newcolumn"},
                    {type:"input", name: "xaxis_label", label:"X-axis Label", "labelWidth":250, "inputWidth":240},
                    {"type":"newcolumn"},
                    {type:"input", name: "yaxis_label", label:"Y-axis Label", "labelWidth":250, "inputWidth":240}
                ]';

    echo $inner_layout_advance->attach_form('adv_form', 'a');
    echo $advance_form->init_by_attach('adv_form', $form_namespace);
    echo $advance_form->load_form($advance_form_json);    


    echo $inner_layout_advance->attach_grid_cell('pivot_advance', 'b');
    $advance_grid = new GridTable('pivot_advance');
    echo $advance_grid->init_grid_table('pivot_advance', $form_namespace, 'n');
    echo $advance_grid->set_column_auto_size();
    echo $advance_grid->set_search_filter(true, "");
    echo $advance_grid->return_init();
    echo $advance_grid->attach_event('', 'onEditCell', $form_namespace . '.grid_edit');

    echo $tab_obj->attach_event('', 'onTabClick', $form_namespace . '.tab_click');

    echo $layout_obj->close_layout();
?>
</body>
<textarea style="display:none" name="txt_status" id="txt_status">cancel</textarea>
<textarea style="display:none" name="txt_file_path" id="txt_file_path"><?php echo $file_path;?></textarea>
<script src="https://code.jquery.com/ui/1.11.4/jquery-ui.js"></script>
<link rel="stylesheet" href="https://code.jquery.com/ui/1.11.4/themes/smoothness/jquery-ui.css"/>

<script type="text/javascript">
    google.load("visualization", "1", {packages:["corechart", "charteditor"]});

    var pivot_col_list = {
        detail_columns: '',
        grouping_columns: '',
        rows_columns: '',
        rows_columns: '',
        xaxis:'',
        yaxis:'',
        series:''
    };
    $(function() {
    	var view_id = '<?php echo $view_id;?>';
    	var hide_filters = '<?php echo $hide_filters;?>';
    	var report_type = '<?php echo $report_type;?>';
    	var report_id = '<?php echo $report_id;?>';

    	if (hide_filters == 'y') {
    		viewPivotReport.toolbar.showItem('filters'); 
    		viewPivotReport.view_form.disableItem('view');   		
    	}

    	if (view_id == '') {
    		viewPivotReport.form_change('view', -1);
    	} else {
            viewPivotReport.view_form.setItemValue('view',view_id);
    		viewPivotReport.form_change('view', view_id);
    	}

    	viewPivotReport.pivot_advance.enableEditEvents(true,false,true);
        
        layout_b = viewPivotReport.inner_layout_view.cells('a');

        title_popup = new dhtmlXPopup({ toolbar: viewPivotReport.toolbar, id: "print"});    
		var form_json = [
                        {type: "settings", labelWidth: 270, inputWidth: 250, position: "label-top", offsetLeft: 20},
                        {type: "input", label: "Report Title", name: "report_title"},
                        {type: "button", value: "Print", offsetLeft: 220}
                    ];                
        title_form = title_popup.attachForm(get_form_json_locale(form_json));
        title_form.attachEvent("onButtonClick", function(){
            title_popup.hide();
            var title = title_form.getItemValue('report_title');
            viewPivotReport.print_report(title);
        });

        title_popup.attachEvent("onShow", function(){
            var form_obj = viewPivotReport.view_form.getCombo('view');     
            var view_name = form_obj.getSelectedText();
            title_form.setItemValue('report_title', view_name);
        });

        if (report_type == 2 && report_id == '') {
        	viewPivotReport.view_form.hideItem('group');
        	viewPivotReport.view_form.hideItem('pin_it');
        }
    })

    /**
     * [grid_edit Grid cell on edit function]
     * @param  {[type]} stage  [stage of edit 0 - edit open, 1 - on edit, 2 - on edit close]
     * @param  {[type]} rId    [row_id]
     * @param  {[type]} cInd   [column index]
     * @param  {[type]} nValue [new value]
     * @param  {[type]} oValue [old value]
     */
    viewPivotReport.grid_edit = function(stage,rId,cInd,nValue,oValue) {
    	var render_as = viewPivotReport.pivot_advance.cells(rId, 3).getValue();

    	if (stage == 0) {
	    	if (render_as !== '' && render_as !== 'undefined') {
	    		if (render_as == 'c' && cInd == 4) return false;
	    		if (render_as == 't' && cInd != 2 && cInd != 3) return false;
	    		if (render_as == 'd' && cInd != 2 && cInd != 4  && cInd != 3) return false;    		
	    		if (render_as == 'n' && (cInd == 4 || cInd == 5)) return false;
	    		if (render_as == 'p' && (cInd == 4 || cInd == 5)) return false;
	    		if (render_as.length > 1 && cInd != 3) return false;
	    	} else {
	    		if (cInd != 2 && cInd != 3) return false;
	    	}
    	} else if (cInd == 3 && stage == 2) {
    		if (nValue == 't') {    			
    			viewPivotReport.pivot_advance.cells(rId, 4).setValue('');
    			viewPivotReport.pivot_advance.cells(rId, 5).setValue('');
    			viewPivotReport.pivot_advance.cells(rId, 6).setValue('');
    			viewPivotReport.pivot_advance.cells(rId, 7).setValue('');
    			viewPivotReport.pivot_advance.cells(rId, 8).setValue('');
    		} else if (nValue == 'd') {    			
    			viewPivotReport.pivot_advance.cells(rId, 5).setValue('');
    			viewPivotReport.pivot_advance.cells(rId, 6).setValue('');
    			viewPivotReport.pivot_advance.cells(rId, 7).setValue('');
    			viewPivotReport.pivot_advance.cells(rId, 8).setValue('')
    		} else if (nValue == 'p' || nValue == 'n') {
    			viewPivotReport.pivot_advance.cells(rId, 4).setValue('');
    			viewPivotReport.pivot_advance.cells(rId, 5).setValue('');
    		} else if (nValue == 'c') {
    			viewPivotReport.pivot_advance.cells(rId, 4).setValue('');
    		} else if (nValue.length > 1) {
    			dhtmlx.alert({
                    title:"Alert",
                    type:"alert",
                    text:'Invalid value in <b>Render As</b>. Please insert a correct value.'
                });
    		}
    	}

    	return true;
	}

	/**
	 * [get_label Return Label]
	 * @param  {[type]} id [rowId]
	 */
	viewPivotReport.get_label = function(id, name) {
		id = id.trim();
		var label = '';
		var rowIndex = viewPivotReport.pivot_advance.getRowIndex(id);

		if (rowIndex == -1) {
			var find_row = viewPivotReport.pivot_advance.findCell(name, 1, true);
			if (find_row != "") {
        		id = find_row.toString().substring(0, find_row.toString().indexOf(","));
        		rowIndex = 0;
			}
		}

		if (rowIndex != -1) {
			label = viewPivotReport.pivot_advance.cells(id, 2).getValue();
		}

		return label;
	}

	/**
	 * [get_formatted_value Get formatted data]
	 * @param  {[type]} id    [RowId]
	 * @param  {[type]} value [Value]
	 */
	viewPivotReport.get_formatted_value = function(id, value, name) {
		var return_val;
		id = id.trim();
		var rowIndex = viewPivotReport.pivot_advance.getRowIndex(id);

		if (rowIndex == -1) {
			var find_row = viewPivotReport.pivot_advance.findCell(name, 1, true);
			if (find_row != "") {
        		id = find_row.toString().substring(0, find_row.toString().indexOf(","));
        		rowIndex = 0;
			}
		}
		
		var is_hyperlink = is_column_pivot_hyperlink(name);
		if (rowIndex == -1 && is_hyperlink == true) {
			var hyperlink = build_column_as_pivot_hyperlink(name, value);
			return hyperlink;
		}

		if (rowIndex != -1) {
			var render_as = viewPivotReport.pivot_advance.cells(id, 3).getValue();		

			if (render_as != '') {
                if (render_as == 'n' || render_as == 'p' || render_as == 'c' || render_as == 'a' || render_as == 'v' || render_as == 'r') {
					var currency = viewPivotReport.pivot_advance.cells(id, 5).getValue(); 
					var thou_sep = viewPivotReport.pivot_advance.cells(id, 6).getValue(); 
					var rounding = viewPivotReport.pivot_advance.cells(id, 7).getValue(); 
					var neg_as_red = viewPivotReport.pivot_advance.cells(id, 8).getValue();
                    var sep = (thou_sep == 'n') ? '' : global_group_separator;
                    
                    if (!rounding || rounding == '' || rounding == 'undefined' || rounding == '-1') {
                        switch (render_as) {
                            case 'r':
                                rounding = global_price_rounding;
                                break;
                            case 'a':
                                rounding = global_amount_rounding;
                                break;
                            case 'v':
                                rounding = global_volume_rounding;
                                break;
                            default:
                                rounding = global_number_rounding;
                                break;
                        }
                    }

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
					var hyperlink = build_column_as_pivot_hyperlink(name, value);
						
					return_val = hyperlink;
				} else if (render_as == 't') {
					return_val = value;
				} else if (render_as == 'd') {
					var date_fmt = viewPivotReport.pivot_advance.cells(id, 4).getValue(); 
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

	/**
	 * [tab_click Tab Click function]
	 * @param  {[type]} id     [TabId]
	 * @param  {[type]} lastId [LastClickedID]
	 */
    viewPivotReport.tab_click = function(tabid, lastId) {
    	if (tabid !== lastId && tabid == 'advance') {
    		var final_obj = {
			    rows: []
			};

    		var colsAttrsContainer = $("th.pvtAxisContainer.pvtCols");
			$(colsAttrsContainer).children("li").each(function() { 
				$this = $(this);
				var id = $(this).attr('class').replace('ui-sortable-handle', '').trim();				
				var label = $('span.pvtAttr', $this).contents().get(0).nodeValue;
				var rowIndex = viewPivotReport.pivot_advance.getRowIndex(id);

				var edt_label = label;
				var render_as = '';
				var date_format = '';
				var currency = '';
				var thou_sep = '';
				var rounding = '';
				var neg_as_red = '';


				if (rowIndex == -1) {
					var find_row = viewPivotReport.pivot_advance.findCell(label, 1, true);
					if (find_row != "") {
                		id = find_row.toString().substring(0, find_row.toString().indexOf(","));
                		rowIndex = 0;
					}
				}

				var is_hyperlink = is_column_pivot_hyperlink(label);
				if (is_hyperlink == true) {
					render_as = 'h';
				}				

				if (rowIndex != -1) {
					edt_label = viewPivotReport.pivot_advance.cells(id, 2).getValue();
					render_as = viewPivotReport.pivot_advance.cells(id, 3).getValue();
					date_format = viewPivotReport.pivot_advance.cells(id, 4).getValue();
					currency = viewPivotReport.pivot_advance.cells(id, 5).getValue();
					thou_sep = viewPivotReport.pivot_advance.cells(id, 6).getValue();
					rounding = viewPivotReport.pivot_advance.cells(id, 7).getValue();
					neg_as_red = viewPivotReport.pivot_advance.cells(id, 8).getValue();
				} 

				final_obj.rows.push({
					 id:id,
					 bgColor: "#EFE4B0",
					 data:[id,label,edt_label, render_as, date_format, currency, thou_sep, rounding, neg_as_red]
				});
			});

			var rowsAttrsContainer = $("td.pvtAxisContainer.pvtRows");
			$(rowsAttrsContainer).children("li").each(function() { 
				$this = $(this);
				var id = $(this).attr('class').replace('ui-sortable-handle', '').trim();
				var label = $('span.pvtAttr', $this).contents().get(0).nodeValue;
				var rowIndex = viewPivotReport.pivot_advance.getRowIndex(id);

				var edt_label = label;
				var render_as = '';
				var date_format = '';
				var currency = '';
				var thou_sep = '';
				var rounding = '';
				var neg_as_red = '';

				if (rowIndex == -1) {
					var find_row = viewPivotReport.pivot_advance.findCell(label, 1, true);
					if (find_row != "") {
                		id = find_row.toString().substring(0, find_row.toString().indexOf(","));
                		rowIndex = 0;
					}
				}

				var is_hyperlink = is_column_pivot_hyperlink(label);
				if (is_hyperlink == true) {
					render_as = 'h';
				}

				if (rowIndex != -1) {
					edt_label = viewPivotReport.pivot_advance.cells(id, 2).getValue();
					render_as = viewPivotReport.pivot_advance.cells(id, 3).getValue();
					date_format = viewPivotReport.pivot_advance.cells(id, 4).getValue();
					currency = viewPivotReport.pivot_advance.cells(id, 5).getValue();
					thou_sep = viewPivotReport.pivot_advance.cells(id, 6).getValue();
					rounding = viewPivotReport.pivot_advance.cells(id, 7).getValue();
					neg_as_red = viewPivotReport.pivot_advance.cells(id, 8).getValue();
				}

				final_obj.rows.push({
					 id:id,
					 bgColor: "#C8BFE7",
					 data:[id,label,edt_label, render_as, date_format, currency, thou_sep, rounding, neg_as_red] 
				});
			});

			var rend_val = $('.pvtRenderer').val();

			if (rend_val != 'Table') {
				var dataAttrsContainer = $("th.pvtAxisContainer.pvtAggs");
				$(dataAttrsContainer).children("li").each(function() { 
					$this = $(this);
					var id = $(this).attr('class').replace('ui-sortable-handle', '').replace('pvtVals', '').trim();
					var label = $('span.pvtAttr', $this).contents().get(0).nodeValue;
					var rowIndex = viewPivotReport.pivot_advance.getRowIndex(id);

					var edt_label = label;
					var render_as = '';
					var date_format = '';
					var currency = '';
					var thou_sep = '';
					var rounding = '';
					var neg_as_red = '';

					if (rowIndex == -1) {
						var find_row = viewPivotReport.pivot_advance.findCell(label, 1, true);
						if (find_row != "") {
	                		id = find_row.toString().substring(0, find_row.toString().indexOf(","));
	                		rowIndex = 0;
						}
					}

					var is_hyperlink = is_column_pivot_hyperlink(label);
					if (is_hyperlink == true) {
						render_as = 'h';
					}

					if (rowIndex != -1) {
						edt_label = viewPivotReport.pivot_advance.cells(id, 2).getValue();
						render_as = viewPivotReport.pivot_advance.cells(id, 3).getValue();
						date_format = viewPivotReport.pivot_advance.cells(id, 4).getValue();
						currency = viewPivotReport.pivot_advance.cells(id, 5).getValue();
						thou_sep = viewPivotReport.pivot_advance.cells(id, 6).getValue();
						rounding = viewPivotReport.pivot_advance.cells(id, 7).getValue();
						neg_as_red = viewPivotReport.pivot_advance.cells(id, 8).getValue();
					}

					final_obj.rows.push({
						 id:id,
						 bgColor: "#BEE4EE",
						 data:[id,label,edt_label, render_as, date_format, currency, thou_sep, rounding, neg_as_red]
					});
				});
			} 

			if (rend_val == 'CrossTab Table' || rend_val == 'Table') {
				viewPivotReport.adv_form.disableItem('xaxis_label');
				viewPivotReport.adv_form.disableItem('yaxis_label');
			} else {
				viewPivotReport.adv_form.enableItem('xaxis_label');
				viewPivotReport.adv_form.enableItem('yaxis_label');
			}

			viewPivotReport.pivot_advance.clearAll();
			viewPivotReport.pivot_advance.enableAlterCss("","");
			viewPivotReport.pivot_advance.parse(final_obj, "json");
    	} else if(tabid !== lastId && tabid == 'view') {
    		var report_title = viewPivotReport.adv_form.getItemValue('report_name');
    		var x_axis = viewPivotReport.adv_form.getItemValue('xaxis_label');
    		var y_axis = viewPivotReport.adv_form.getItemValue('yaxis_label');
    		window.refresh_report(report_title, x_axis, y_axis);
    	}
    }

    /**
     * [page_toolbar_click Toolbar click]
     * @param  {[type]} id [Tool id]
     */
    viewPivotReport.page_toolbar_click = function(id) {
    	if (id == 'undock') {
    		var name = viewPivotReport.toolbar.getItemText(id);

    		if (name.toLowerCase() == 'undock')
    			viewPivotReport.undock_reports();
    		else 
    			viewPivotReport.dock_reports();
    	} else if (id == 'filters') {
    		viewPivotReport.open_filter_win();
    	}
    }
    
    var criteria_window;
    var criteria_toolbar = {};
    var criteria_layout = {};
    var criteriaWin = {};

    /**
     * [open_filter_win Open Filter Window]
     */
    viewPivotReport.open_filter_win = function() {
    	var report_type = '<?php echo $report_type;?>';
    	var report_id = '<?php echo $report_id;?>';
    	var report_name = '<?php echo $report_name;?>';
    	var report_param_id = '<?php echo $paramset_id;?>';

    	var report_template = viewPivotReport.get_report_template(report_id, report_type);
	 	var php_path = '<?php echo $app_adiha_loc; ?>';
        var url = php_path + 'adiha.html.forms/_reporting/view_report/' + template_name;
        //var view_id = '<?php echo $view_id;?>';
        var view_id = viewPivotReport.view_form.getCombo('view').getSelectedValue();

        var params = {
        	active_object_id: report_param_id, 
			report_type: report_type, 
			report_name: report_name, 
			report_param_id: report_param_id,
			call_from:'pinned_pivot',
			view_id:view_id
		};

		if (!criteria_window) {
            criteria_window = new dhtmlXWindows();
        }

        var win_name = 'w_' + report_id;
        criteriaWin['win_' + report_id] = criteria_window.createWindow(win_name, 0, 0, 800, 600);
        criteriaWin['win_' + report_id].setText('Pivot Criteria');
        criteriaWin['win_' + report_id].centerOnScreen();
        criteriaWin['win_' + report_id].setModal(true);

        var toolbar_json = [{id:"save", type:"button", img:"save.gif", imgdis:"save_dis.gif", text:"Save", title:"Save"}];
	    criteria_toolbar['toolbar_' + report_id] = criteriaWin['win_' + report_id].attachToolbar();
	    criteria_toolbar['toolbar_' + report_id].setIconsPath(js_image_path + '/dhxtoolbar_web/');
	    criteria_toolbar['toolbar_' + report_id].loadStruct([
            {id:"ok", type: "button", img: "tick.gif", text: "Ok", title: "Ok"},
            {id:"cancel", type:"button", img: "close.gif", text:"Cancel", title: "Cancel"}
        ]);

	    criteria_layout['layout_' + report_id] = criteriaWin['win_' + report_id].attachLayout({
	    	pattern: '1C',
	    	cells: [{id:'a', header:'false'}]
	    });

	    criteriaWin['win_' + report_id].progressOn();

	    criteria_layout['layout_' + report_id].attachEvent("onContentLoaded", function(id){
		    criteriaWin['win_' + report_id].progressOff();
		});
        criteria_layout['layout_' + report_id].cells('a').attachURL(url, false, params);


        criteria_toolbar['toolbar_' + report_id].attachEvent("onClick", function(id){
        	var report_id = '<?php echo $report_id;?>';
        	var report_type = '<?php echo $report_type;?>';

		    if (id == 'cancel') {
		    	criteriaWin['win_' + report_id].close();
		    } else {
		    	var ifr = criteria_layout['layout_' + report_id].cells("a").getFrame();
	            var ifrWindow = ifr.contentWindow;

	            if (report_type == 2) {
	            	var params = ifrWindow.report_parameter(false);
	            	var filter_list = params.split('&applied_filters=');
                    var exec_sql = filter_list[0];
                    var grid_name = '<?php echo $grid_name ?? '';?>';

                    var data = {
						"action": "spa_generate_grid_pivot_file", 
						"grid_name": grid_name.replace(/\//g, '_').replace('/\/', '_'),
						"exec_sql": exec_sql.replace(/'/g,"''")
					}

					adiha_post_data("return", data, '', '', 'viewPivotReport.refresh_std_pivot_file');
            	} else {
            		var params = ifrWindow.report_parameter(false, 1);

                    if (params) {
                    	var server_path = "<?php echo $server_path ?? '';?>";
                    	params.report_id = report_id;
                    	var data = {
							"action": "spa_generate_pivot_file", 
							"paramset_id": params.paramset_id,
							"component_id": params.items_combined,
					        "criteria":params.report_filter.join(','),
					        "report_name":params.report_name
						}

						criteriaWin['win_' + report_id].close();
						adiha_post_data("return", data, '', '', 'viewPivotReport.refresh_rp_pivot_file');
                    }
            	}
		    }
		});
    }


    /**
     * [prepare_param Prepare param for pinned report refresh]
     */
    viewPivotReport.prepare_param = function() {
    	var file_path = $('#txt_file_path').val();
    	var rend_val = $('.pvtRenderer').val();
    	var attach_docs = '<?php echo $attach_docs_url_path; ?>';
        var full_file_path = attach_docs.replace('attach_docs', 'temp_Note') + '/' + file_path;

	    var columns_array = window.get_columns();

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
	    var graph_type = '';

	    if (rend_val == 'Table') {
            pivot_col_list['detail_columns'] = columns_array['detail_columns'];
            pivot_col_list['grouping_columns'] = columns_array['grouping_columns'];
            aggregators = '';
        } else if (rend_val == 'CrossTab Table') {                
            pivot_col_list['rows_columns'] = columns_array['rows'];
            pivot_col_list['cols_columns'] = columns_array['columns'];
            var detail = columns_array['detail_columns'];

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
            pivot_col_list['xaxis'] = columns_array['xaxis'];
            pivot_col_list['series'] = columns_array['series'];
            var detail = columns_array['yaxis'];
            
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
        }
        return post_param = {
	        file_path: full_file_path,
	        report_type: 'mixed',
	        renderer_type: rend_val,
	        aggregators: aggregators,
	        graphType:graph_type,
	        col_list: JSON.stringify(pivot_col_list),
	        is_pin:'y'
	    };
    }
    
    /**
     * [refresh_rp_pivot_file Callback for report manager report refresh]
     * @param  {[type]} result [Array]
     */
    viewPivotReport.refresh_rp_pivot_file = function(result) {
    	$('#txt_file_path').val(result[0].path);
    	viewPivotReport.refresh_pinned_report();
    }

    /**
     * [refresh_rp_pivot_file Callback for standard report refresh]
     * @param  {[type]} result [Array]
     */
    viewPivotReport.refresh_std_pivot_file = function(result) {
    	$('#txt_file_path').val(result[0].filename);  
    	viewPivotReport.refresh_pinned_report();
    }

    /**
     * [refresh_pinned_report Refresh pinned report]
     */
    viewPivotReport.refresh_pinned_report = function() {
    	var post_param = viewPivotReport.prepare_param();

    	if (
			post_param.col_list.detail_columns == '' 
			&& post_param.col_list.cols_columns == ''  
			&& post_param.col_list.rows_columns == '' 
			&& post_param.col_list.xaxis == '' 
			&& post_param.col_list.series == '' 
			&& post_param.col_list.yaxis == ''
		) {
    		viewPivotReport.refresh_view(post_param);
		} else {
            var view_id = viewPivotReport.view_form.getCombo('view').getSelectedValue();
	    	viewPivotReport.form_change('view', view_id);
    	}
    }

    /**
     * [Returns the template name for the report]
     * @param report_id [Function ID for the Standard report and function id fro report manager report]
     */
    viewPivotReport.get_report_template = function(report_id, report_type) {        
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
        } else if (report_id == 10232800) {
            template_name = 'run.files.import.audit.report.php'
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
        } else {
            if (report_type == 1) {
                template_name = 'report.manager.report.template.php';
            } else if (report_type == 2) {
                template_name = 'standard.report.template.php';
            } else if (report_type == 3) {
                template_name = 'dashboard.report.template.php';
            } else if (report_type == 4) {
                template_name = '';
            }
        }
        
        return template_name;
    }

    /**
     * [dock_reports Dock detail layout]
     */
    viewPivotReport.dock_reports = function() {
        var layout_obj = viewPivotReport.inner_layout_view;
        layout_obj.cells("a").dock();
    }

    /**
     * [undock_details Undock detail layout]
     */
    viewPivotReport.undock_reports = function() {
    	var report_name = '<?php echo $report_name;?>';
        var layout_obj = viewPivotReport.inner_layout_view;
        layout_obj.cells("a").undock(300, 300, 900, 700);
        layout_obj.dhxWins.window("a").button("park").hide();
        layout_obj.dhxWins.window("a").maximize();
        layout_obj.dhxWins.window("a").setText("Pivot - " + report_name);
        layout_obj.dhxWins.window("a").centerOnScreen();
    }

    /**
     * [on_dock_report_event On dock event]
     * @param  {[type]} id [Cell id]
     */
    viewPivotReport.on_dock_report_event = function(id) {
        if (id == 'a') {            
            viewPivotReport.toolbar.setItemText('undock', 'Undock');
        }
    }
    /**
     * [on_undock_report_event On undock event]
     * @param  {[type]} id [Cell id]
     */
    viewPivotReport.on_undock_report_event = function(id) {
        if (id == 'a') {
            viewPivotReport.toolbar.setItemText('undock', 'Dock');     
        }            
    }

    /**
     * [form_change Form change events]
     * @param  {[type]} name  [Item name]
     * @param  {[type]} value [Item value]
     * @param  {[type]} state [Item state]
     */
    viewPivotReport.form_change = function(name, value, state) {
        var file_path = '<?php echo $report_views_url_path;?>';

        if (name == 'view') {
        	if (value == '' || value == null) {
        		viewPivotReport.view_form.uncheckItem('pin_it');
        		viewPivotReport.view_form.uncheckItem('is_public');
        		viewPivotReport.view_form.uncheckItem('pin_it');
        		return;
	    	} else if (value == -1) {
	    		viewPivotReport.form_change_callback([]);
    		} else {
	        	var data = {
		            "action":"spa_pivot_report_view",
		            "flag":"t",
		            "view_id":value,
		            "grid_type":"g"
		        }
		        var sql_param = $.param(data);
		        var sql_url = js_data_collector_url + "&" + sql_param;

		        viewPivotReport.pivot_advance.clearAll();
		        viewPivotReport.pivot_advance.load(sql_url, function() {
		        	var data_sql = {"action": "spa_pivot_report_view", "flag":'s', "view_id":value}
	        		adiha_post_data("return_array", data_sql, '', '', 'viewPivotReport.form_change_callback');
		        });
		    }
        } else if (name == 'pin_it') {
        	if (state) {
        		viewPivotReport.view_form.enableItem('group');
        	} else {
        		viewPivotReport.view_form.setItemValue('group', '');
        		viewPivotReport.view_form.disableItem('group');
        	}
        }
    }

    /**
     * [form_change_callback Form change callback operations]
     * @param  {[object]} result  [Item name]
     */
    viewPivotReport.form_change_callback = function(result) {
        var file_path = $('#txt_file_path').val();
        var attach_docs = '<?php echo $attach_docs_url_path; ?>';
        var full_file_path = attach_docs.replace('attach_docs', 'temp_Note') + '/' + file_path;
	    var graph_type = '';
		
        if (result.length == 0) {
        	pivot_col_list = {
		        detail_columns: '',
		        grouping_columns: '',
		        rows_columns: '',
		        rows_columns: '',
		        xaxis:'',
		        yaxis:'',
		        series:''
		    };

            var post_param = {
                file_path: full_file_path,
                report_type: 'mixed',
                renderer_type: 'Table',
                aggregators: 'Sum',
                col_list: JSON.stringify(pivot_col_list)
            };
        } else {             
        	if (viewPivotReport.adv_form) {
	            viewPivotReport.adv_form.setItemValue('report_name', result[0][5]);
	            viewPivotReport.adv_form.setItemValue('xaxis_label', result[0][6]);
	            viewPivotReport.adv_form.setItemValue('yaxis_label', result[0][7]);   	            
            }       

            var renderer = result[0][3];

            if (result[0][4] == 1) {
            	viewPivotReport.view_form.checkItem('pin_it');
            	viewPivotReport.form_change('pin_it', 1, true);
        	}
            else  {
            	viewPivotReport.view_form.uncheckItem('pin_it');
            	viewPivotReport.form_change('pin_it', 0, false);
        	}

        	if (result[0][9] == 1) {
            	viewPivotReport.view_form.checkItem('is_public');
        	} else  {
            	viewPivotReport.view_form.uncheckItem('is_public');
        	}

            if (result[0][4] == 1) {
            	viewPivotReport.view_form.setItemValue('group', result[0][8]);
            }

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

            var is_pin = '<?php echo $is_pin;?>';

            var post_param = {
                file_path: full_file_path,
                report_type: 'mixed',
                renderer_type: renderer,
                aggregators: aggregators,
                graphType:graph_type,
                col_list: JSON.stringify(pivot_col_list),
                is_pin:is_pin
            };
        }
        viewPivotReport.refresh_view(post_param);
    }

    /**
     * [refresh_view Refresh View dropdown]
     * @param  {[type]} params [param object]
     */
    viewPivotReport.refresh_view = function(params) {      
        layout_b = viewPivotReport.inner_layout_view.cells('a');    
        var url = js_php_path + 'pivot.template.php';
        layout_b.attachURL(url, true, params);
    }


    /**
     * [menu_click Menu click]
     * @param  {[type]} id [id of menu]
     */
    viewPivotReport.menu_click = function(id) {
        switch (id) {
            case "save":
                var columns_array = window.get_columns();
                var form_obj = viewPivotReport.view_form.getCombo('view');
                var view_id = form_obj.getSelectedValue();         
                view_id = (view_id == null) ? "NULL" : view_id;       
                var view_name = (view_id == "NULL") ? form_obj.getComboText() : form_obj.getSelectedText();

                var group_obj = viewPivotReport.view_form.getCombo('group');
                var group_id = group_obj.getSelectedValue();         
                group_id = (group_id == null || group_id == '') ? "NULL" : group_id;       
                var group_name = (group_id == "NULL") ? group_obj.getComboText() : group_obj.getSelectedText();
                group_name = (group_name == '') ? 'NULL' : group_name;

                var pin_it = viewPivotReport.view_form.getItemValue("pin_it");
                var is_public = viewPivotReport.view_form.getItemValue("is_public");
                var report_type = '<?php echo $report_type;?>';
                var report_id = 'NULL';
                var report_name = 'NULL';
                var xaxis_label = 'NULL';
                var yaxis_label = 'NULL';

                if (report_type == 1) 
                    report_id = '<?php echo $report_id;?>';
                else if (report_type == 2)
                    report_id = '<?php echo $report_id;?>';

                var report_filter = 'NULL';
				report_filter = "<?php echo str_replace('"', '\'', $report_filter);?>";

                if (view_name == '') {
                    show_messagebox('View name cannot be empty.');
                    return;
                }

                var renderer = columns_array['renderer_type'];     

                if (viewPivotReport.adv_form) {
                	report_name = viewPivotReport.adv_form.getItemValue('report_name');
                	if (renderer != 'Table' && renderer != 'CrossTab Table') {
                		xaxis_label = viewPivotReport.adv_form.getItemValue('xaxis_label');
                		yaxis_label = viewPivotReport.adv_form.getItemValue('yaxis_label');
                	}
                }

                var paramset_hash = '<?php echo $paramset_hash; ?>';
                var no_of_rows = viewPivotReport.pivot_advance.getRowsNum();

                var grid_xml = 'NULL';
				
				var error_message = '';

                if (no_of_rows > 0) {
                	grid_xml = '<GridXML>';

                	viewPivotReport.pivot_advance.forEachRow(function(id) {
                		var name = viewPivotReport.pivot_advance.cells(id, 1).getValue();
                		var row_index = viewPivotReport.pivot_advance.getRowIndex(id);
                		row_index = row_index+1;
                		var myRegEx = new RegExp("(^|,)\s*" + name + "\s*($|,)", "i");

                		var col_pos = '';
                		if (renderer == 'Table') {
                			var is_contained = myRegEx.test(columns_array['grouping_columns']);

                			if (is_contained) col_pos = 'r';
                			else col_pos = 'c';
                		} else if (renderer == 'CrossTab Table') {
                			var is_contained = myRegEx.test(columns_array['rows']);

                			if (is_contained) col_pos = 'r';
                			else {
                				is_contained = myRegEx.test(columns_array['columns']);

                				if (is_contained) col_pos = 'c';
                				else col_pos = 'd';
                			}
                		} else {
                			var is_contained = myRegEx.test(columns_array['series']);

                			if (is_contained) col_pos = 'r';
                			else {
                				is_contained = myRegEx.test(columns_array['xaxis']);

                				if (is_contained) col_pos = 'c';
                				else col_pos = 'd';
                			}
                		}	

					    var edt_label = viewPivotReport.pivot_advance.cells(id, 2).getValue();
						var render_as = viewPivotReport.pivot_advance.cells(id, 3).getValue();
						var date_format = viewPivotReport.pivot_advance.cells(id, 4).getValue();
						var currency = viewPivotReport.pivot_advance.cells(id, 5).getValue();
						var thou_sep = viewPivotReport.pivot_advance.cells(id, 6).getValue();
						var rounding = viewPivotReport.pivot_advance.cells(id, 7).getValue();
						var neg_as_red = viewPivotReport.pivot_advance.cells(id, 8).getValue();

						if (error_message == '' && render_as.length > 1) {
							error_message = 'Invalid value in <b>Render As</b> (Row:' + row_index + '). Please insert a correct value.';							
						}

						grid_xml += '<GridRows name="' + name + '" label="' + edt_label + '"  col_pos="' + col_pos + '" render_as="' + render_as + '" date_format="' + date_format + '" currency="' + currency + '" thou_sep="' + thou_sep + '" rounding="' + rounding + '" neg_as_red="' + neg_as_red + '"></GridRows>'
					});

                	grid_xml += '</GridXML>';
                }

                if (error_message != '') {	
	                dhtmlx.alert({
	                    title:"Alert",
	                    type:"alert",
	                    text:error_message
	                });
	                return;
                }                

                if (renderer == 'Table') {
					data = {
						"action": "spa_pivot_report_view",
						"flag": 'i',
						"view_id": view_id,
						"view_name": view_name,
						"paramset_hash": paramset_hash,
						"renderer": renderer,
						"row_fields": columns_array['grouping_columns'],
						"column_fields": columns_array['detail_columns'],
						"grid_xml": grid_xml,
						"pin_it": pin_it,
						"report_filter": report_filter,
						"report_id": report_id,
						"user_report_name":report_name,
						"xaxis_label":xaxis_label,
						"yaxis_label":yaxis_label,
						"group_id":group_id,
						"group_name":group_name,
						"is_public":is_public
					};
                } else if (renderer == 'CrossTab Table') {
					data = {
						"action": "spa_pivot_report_view",
						"flag": 'i',
						"view_id": view_id,
						"view_name": view_name,
						"paramset_hash": paramset_hash,
						"renderer": renderer,
						"row_fields": columns_array['rows'],
						"column_fields": columns_array['columns'],
						"detail_fields": columns_array['detail_columns'],
						"grid_xml": grid_xml,
						"pin_it": pin_it,
						"report_filter": report_filter,
						"report_id": report_id,
						"user_report_name":report_name,
						"xaxis_label":xaxis_label,
						"yaxis_label":yaxis_label,
						"group_id":group_id,
						"group_name":group_name,
						"is_public":is_public
					};
                } else {
					data = {
						"action": "spa_pivot_report_view",
						"flag": 'i',
						"view_id": view_id,
						"view_name": view_name,
						"paramset_hash": paramset_hash,
						"renderer": renderer,
						"row_fields": columns_array['series'],
						"column_fields": columns_array['xaxis'],
						"detail_fields": columns_array['yaxis'],
						"grid_xml": grid_xml,
						"pin_it": pin_it,
						"report_filter": report_filter,
						"report_id": report_id,
						"user_report_name":report_name,
						"xaxis_label":xaxis_label,
						"yaxis_label":yaxis_label,
						"group_id":group_id,
						"group_name":group_name,
						"is_public":is_public
					};
                }
                
                adiha_post_data("alert", data, '', '', 'viewPivotReport.save_callback');
                break;
            case "delete":
            	dhtmlx.message({
					type: "confirm",
					title: "Confirmation",
					ok: "Confirm",
					text: "Are you sure you want to delete selected view?",
					callback: function(result) {
						if (result) {
							var form_obj = viewPivotReport.view_form.getCombo('view');
			                var view_id = form_obj.getSelectedValue();         
			                if (view_id == null) {
			                    form_obj.setComboText('');
			                } else {
			                    data = {"action": "spa_pivot_report_view", "flag":'d', "view_id":view_id};
			                    adiha_post_data("alert", data, '', '', 'viewPivotReport.delete_callback');
			                }
						}
					}
				});                

                break;
			case "copy":
                var form_obj = viewPivotReport.view_form.getCombo('view');
                var view_id = form_obj.getSelectedValue();         
                
				data = {"action": "spa_pivot_report_view", "flag":'p', "view_id":view_id};
                adiha_post_data("alert", data, '', '', 'viewPivotReport.copy_callback');

                break;
        }
    }

    /**
     * [copy_callback Copy Callback]
     * @param  {[type]} result [Returned Array]
     */
    viewPivotReport.copy_callback = function(result) {
        if (result[0].errorcode == 'Success') {
        	var pin_it = viewPivotReport.view_form.getItemValue("pin_it");
        	var id_string = result[0].recommendation;
        	var id_array = id_string.split(':::');

            var view_combo = viewPivotReport.view_form.getCombo('view');
            var view_id = id_array[0]; 
            var view_name = id_array[1]; 

            view_combo.addOption(view_id,view_name);
            view_combo.setComboValue(view_id);     

            viewPivotReport.refresh_group(view_id);   

            if (pin_it == 1) {
            	window.top.refresh_pinned_report();
            }
        }
    }

    /**
     * [save_callback Save Callback]
     * @param  {[type]} result [Returned Array]
     */
    viewPivotReport.save_callback = function(result) {
        if (result[0].errorcode == 'Success') {
            var view_combo = viewPivotReport.view_form.getCombo('view');
            var view_id = view_combo.getSelectedValue(); 
            var pin_it = viewPivotReport.view_form.getItemValue("pin_it");

            if (view_id == null) {
                view_id =  result[0].recommendation;      
                var view_name = view_combo.getComboText();
                view_combo.addOption(view_id,view_name);
                view_combo.setComboValue(view_id);
            }     

            viewPivotReport.refresh_group(view_id);   

            if (pin_it == 1) {
            	window.top.refresh_pinned_report();
            }
        }
    }

    viewPivotReport.refresh_group = function(view_id) {
    	var group_obj = viewPivotReport.view_form.getCombo('group');

    	group_obj.setComboValue('');
        group_obj.setComboText('');
        group_obj.clearAll();
        group_obj.enableFilteringMode('between');
        var cm_param = {"action": "spa_pivot_report_view", "call_from": "form", "flag": "z"};
        cm_param = $.param(cm_param);
        var url = js_dropdown_connector_url + '&' + cm_param;
        group_obj.clearAll();
        group_obj.load(url);

        viewPivotReport.form_change('view', view_id);
    	
    }

    /**
     * [delete_callback Delete Callback]
     * @param  {[type]} result [Return Array]
     */
    viewPivotReport.delete_callback = function(result) {
        if (result[0].errorcode == 'Success') {
            var form_obj = viewPivotReport.view_form.getCombo('view');
            view_id =  result[0].recommendation;
            form_obj.setComboText('');
            form_obj.deleteOption(view_id);
            viewPivotReport.form_change('view', -1);
            window.top.refresh_pinned_report();
        }
    }

    /**
     * [print_report Print Report]
     * @param  {[type]} report_title [Report Title]
     */
    viewPivotReport.print_report = function(report_title) {
        var win_content = $(".pvtRendererArea").html();
        var path = js_php_path + 'print.preview.php';
        var param = {
            "html_string":win_content,
            "report_title":report_title
        }
        open_window(path, param);
    }
</script>
<style type="text/css">
    html, body {
        width: 100%;
        height: 100%;
        margin: 0px;
        padding: 0px;
        background-color: #ebebeb;
        overflow: hidden;
    }
</style>
</html>