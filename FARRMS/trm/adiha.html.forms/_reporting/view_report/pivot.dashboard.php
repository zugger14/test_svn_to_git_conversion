<?php
/**
* Pivot dashboard screen
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
<body id = 'body_content'>
<?php 
    $form_namespace = 'viewPivotDashboard';
    $view_id = get_sanitized_value($_REQUEST['view_id'] ?? '');
    $is_dashboard = get_sanitized_value($_REQUEST['is_dashboard'] ?? '');
    $dashboard_id = get_sanitized_value($_REQUEST['dashboard_id'] ?? '');
    $replace_params = (isset($_REQUEST["replace_params"]) && $_REQUEST["replace_params"] != '') ? "'" . urldecode($_REQUEST["replace_params"]) . "'" : 'NULL';
    $cell_text = get_sanitized_value($_REQUEST['cell_text'] ?? '');
    $cell_id = get_sanitized_value($_REQUEST['cell_id'] ?? '');
    $paramset_id = '';
    $component_id = '';
    if ($is_dashboard == 'y' && $view_id != '') {
    	$sp_db_param = "EXEC spa_pivot_report_view @flag='y', @view_id=" . $view_id . ", @dashboard_id=" . $dashboard_id . ", @replace_params=" . $replace_params;
    	$db_param = readXMLURL2($sp_db_param);

    	$paramset_id = $db_param[0]['paramset_id'];
    	$component_id = $db_param[0]['component_id'];
    	$report_filter = $db_param[0]['params'];
    	$report_name = $db_param[0]['report_name']. '_' . $cell_id . '_' . $app_user_name;
    	$paramset_hash = $db_param[0]['paramset_hash'];
    	$has_permission = $db_param[0]['has_permission'];
    	$excel_sheet_id = $db_param[0]['excel_sheet_id'];
    }

	$server_path = $BATCH_FILE_EXPORT_PATH;	   
    if ($has_permission == 'y') {
    	if ($excel_sheet_id != null && $excel_sheet_id != '') {
            $xml_formatted_filter = "EXEC spa_rfx_format_filter @flag='f', @paramset_id='$paramset_id', @parameter_string='$report_filter', @is_excel_report=1";
            $result_formatted_filter = readXMLURL2($xml_formatted_filter);

            $view_report_filter_xml = build_excel_parameters($result_formatted_filter);
    		$snapshot_gen_sql = "EXEC spa_view_report @flag = 'o', @report_id = " . $excel_sheet_id . ", @view_report_filter_xml='$view_report_filter_xml', @export_format='PNG'";
    		$snapshot_file_detail = readXMLURL2($snapshot_gen_sql);
    		$file_path = $snapshot_file_detail[0]['snapshot_filename'];
    	} else {
	    	$sp_generate_file = "EXEC spa_generate_pivot_file @paramset_id=" . $paramset_id . ", @component_id=" . $component_id . ", @criteria='" . $report_filter . "', @server_path='" . $server_path . "', @report_name='" . $report_name . "'";
		    $file_detail = readXMLURL2($sp_generate_file);
		    
		    $file_path = $file_detail[0]['path'];
		}
    }
      
    $report_type = 1;
    
    $layout_obj = new AdihaLayout();
    $layout_json = '[{id: "a", header:false}]';
          
    echo $layout_obj->init_layout('pivot_template', '', '1C', $layout_json, $form_namespace);
    
    $tab_obj = new AdihaTab();

    $tab_json =   '[ 
                    {id:"view", text:"Report", active:true}, 
                    {id:"advance", text:"Formatting"}
                    ]';  

    echo $layout_obj->attach_tab_cell('pivot_tab', 'a', $tab_json);
    echo $tab_obj->init_by_attach('pivot_tab', $form_namespace);

    $inner_layout_view = new AdihaLayout();    

    echo $tab_obj->attach_layout('inner_layout_view', 'view', '1C');
    echo $inner_layout_view->init_by_attach('inner_layout_view', $form_namespace);
    echo $inner_layout_view->hide_header('a');

    $page_toolbar_json = '[
    	{id:"print", type: "button", img:"print.gif", imgdis:"print_dis.gif", enabled:true, text:"Print", title: "Print"},
    	{id:"filters", type: "button", img:"filter_save.gif", imgdis:"filter_save.gif", enabled:true, text:"Change Filters", title: "Change Filters"}
    ]';

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
    $advance_grid->enable_connector();
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
	var dashboard_id = '<?php echo $dashboard_id;?>';	
	var has_permission = '<?php echo $has_permission;?>';
    var is_dashboard = '<?php echo $is_dashboard;?>';
    var cell_id = '<?php echo $cell_id;?>';
    var excel_sheet_id = '<?php echo $excel_sheet_id;?>';

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

    	if (has_permission == 'n') {
    		var layout_cell = viewPivotDashboard.inner_layout_view.cells('a');
    		layout_cell.attachHTMLString('<h5>You do not have permission to view this report. Please contact administrator.</h5>');
    		return;
    	}

    	viewPivotDashboard.form_change('view', view_id);

    	viewPivotDashboard.pivot_advance.enableEditEvents(true,false,true);
        
        layout_b = viewPivotDashboard.inner_layout_view.cells('a');

        title_popup = new dhtmlXPopup({ toolbar: viewPivotDashboard.toolbar, id: "print"});                    
        title_form = title_popup.attachForm([
                        {type: "settings", labelWidth: 270, inputWidth: 250, position: "label-top", offsetLeft: 20},
                        {type: "input", label: "Report Title", name: "report_title"},
                        {type: "button", value: "Print", offsetLeft: 220}
                    ]);
        title_form.attachEvent("onButtonClick", function(){
            title_popup.hide();
            var title = title_form.getItemValue('report_title');
            viewPivotDashboard.print_report(title);
        });

        title_popup.attachEvent("onShow", function(){
            var form_obj = viewPivotDashboard.view_form.getCombo('view');     
            var view_name = form_obj.getSelectedText();
            title_form.setItemValue('report_title', view_name);
        });
		
		context_menu = new dhtmlXMenuObject({
							context: true,
							items:[{id:"print", text:"Print"},{id:"change_filters", text:"Change Filter"}]
						});
		context_menu.attachEvent("onClick", function(id, zoneId, cas){
			if (id == 'change_filters') {
				if (has_permission == 'n') {
					show_messagebox('You do not have permission to view this report. Please contact administrator.');
					return;
				}
				viewPivotDashboard.open_filter_win();
			} else if (id == 'print') {
				viewPivotDashboard.print_report('');
			}
		});
	})

    /**
     * [grid_edit Grid cell on edit function]
     * @param  {[type]} stage  [stage of edit 0 - edit open, 1 - on edit, 2 - on edit close]
     * @param  {[type]} rId    [row_id]
     * @param  {[type]} cInd   [column index]
     * @param  {[type]} nValue [new value]
     * @param  {[type]} oValue [old value]
     */
    viewPivotDashboard.grid_edit = function(stage,rId,cInd,nValue,oValue) {
    	var render_as = viewPivotDashboard.pivot_advance.cells(rId, 3).getValue();

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
    			viewPivotDashboard.pivot_advance.cells(rId, 4).setValue('');
    			viewPivotDashboard.pivot_advance.cells(rId, 5).setValue('');
    			viewPivotDashboard.pivot_advance.cells(rId, 6).setValue('');
    			viewPivotDashboard.pivot_advance.cells(rId, 7).setValue('');
    			viewPivotDashboard.pivot_advance.cells(rId, 8).setValue('');
    		} else if (nValue == 'd') {    			
    			viewPivotDashboard.pivot_advance.cells(rId, 5).setValue('');
    			viewPivotDashboard.pivot_advance.cells(rId, 6).setValue('');
    			viewPivotDashboard.pivot_advance.cells(rId, 7).setValue('');
    			viewPivotDashboard.pivot_advance.cells(rId, 8).setValue('')
    		} else if (nValue == 'p' || nValue == 'n') {
    			viewPivotDashboard.pivot_advance.cells(rId, 4).setValue('');
    			viewPivotDashboard.pivot_advance.cells(rId, 5).setValue('');
    		} else if (nValue == 'c') {
    			viewPivotDashboard.pivot_advance.cells(rId, 4).setValue('');
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
	viewPivotDashboard.get_label = function(id, name) {
		id = id.trim();
		var label = '';
		var rowIndex = viewPivotDashboard.pivot_advance.getRowIndex(id);

		if (rowIndex == -1) {
			var find_row = viewPivotDashboard.pivot_advance.findCell(name, 1, true);
			if (find_row != "") {
        		id = find_row.toString().substring(0, find_row.toString().indexOf(","));
        		rowIndex = 0;
			}
		}

		if (rowIndex != -1) {
			label = viewPivotDashboard.pivot_advance.cells(id, 2).getValue();
		}

		return label;
	}

	/**
	 * [get_formatted_value Get formatted data]
	 * @param  {[type]} id    [RowId]
	 * @param  {[type]} value [Value]
	 */
	viewPivotDashboard.get_formatted_value = function(id, value, name) {
		var return_val;
		id = id.trim();
		var rowIndex = viewPivotDashboard.pivot_advance.getRowIndex(id);

		if (rowIndex == -1) {
			var find_row = viewPivotDashboard.pivot_advance.findCell(name, 1, true);
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
			var render_as = viewPivotDashboard.pivot_advance.cells(id, 3).getValue();		

			if (render_as != '') {
                if (render_as == 'n' || render_as == 'p' || render_as == 'c' || render_as == 'a' || render_as == 'v' || render_as == 'r') {
					var currency = viewPivotDashboard.pivot_advance.cells(id, 5).getValue(); 
					var thou_sep = viewPivotDashboard.pivot_advance.cells(id, 6).getValue(); 
					var rounding = viewPivotDashboard.pivot_advance.cells(id, 7).getValue(); 
					var neg_as_red = viewPivotDashboard.pivot_advance.cells(id, 8).getValue();
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
                        var val1 = value.replace(/,/g,'');
                        var re = /,(?=[\d,]*\.\d{2}\b)/;
                        if (sep == '') {
                            val1 = val1.replace(re, '');
                        }
                        return_val = $.number(val1, rounding, global_decimal_separator, sep);
                    } else if (rounding != '') {
                        var val1 = value.replace(/,/g,'');
                        return_val = $.number(val1, rounding, global_decimal_separator, sep);
                    } else if (thou_sep !== '') {
                        var val1 = value;
                        var val1 = value.replace(/,/g,'');
                        var re = /,(?=[\d,]*\.\d{2}\b)/;
                        if (sep == '') {
                            val1 = val1.replace(re, '');
                        }
                        return_val = $.number(val1, '', global_decimal_separator, sep);
                    } else {
                        var val1 = value.replace(/,/g,'');
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
								return_val = return_val
							}
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
					var date_fmt = viewPivotDashboard.pivot_advance.cells(id, 4).getValue(); 
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
    viewPivotDashboard.tab_click = function(tabid, lastId) {
    	if (tabid !== lastId && tabid == 'advance') {
    		var final_obj = {
			    rows: []
			};

    		var colsAttrsContainer = $("th.pvtAxisContainer.pvtCols");
			$(colsAttrsContainer).children("li").each(function() { 
				$this = $(this);
				var id = $(this).attr('class').replace('ui-sortable-handle', '').trim();				
				var label = $('span.pvtAttr', $this).contents().get(0).nodeValue;
				var rowIndex = viewPivotDashboard.pivot_advance.getRowIndex(id);

				var edt_label = label;
				var render_as = '';
				var date_format = '';
				var currency = '';
				var thou_sep = '';
				var rounding = '';
				var neg_as_red = '';


				if (rowIndex == -1) {
					var find_row = viewPivotDashboard.pivot_advance.findCell(label, 1, true);
					if (find_row != "") {
                		id = find_row.toString().substring(0, find_row.toString().indexOf(","));
                		rowIndex = 0;
					}
				}

				if (rowIndex != -1) {
					edt_label = viewPivotDashboard.pivot_advance.cells(id, 2).getValue();
					render_as = viewPivotDashboard.pivot_advance.cells(id, 3).getValue();
					date_format = viewPivotDashboard.pivot_advance.cells(id, 4).getValue();
					currency = viewPivotDashboard.pivot_advance.cells(id, 5).getValue();
					thou_sep = viewPivotDashboard.pivot_advance.cells(id, 6).getValue();
					rounding = viewPivotDashboard.pivot_advance.cells(id, 7).getValue();
					neg_as_red = viewPivotDashboard.pivot_advance.cells(id, 8).getValue();
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
				var rowIndex = viewPivotDashboard.pivot_advance.getRowIndex(id);

				var edt_label = label;
				var render_as = '';
				var date_format = '';
				var currency = '';
				var thou_sep = '';
				var rounding = '';
				var neg_as_red = '';

				if (rowIndex == -1) {
					var find_row = viewPivotDashboard.pivot_advance.findCell(label, 1, true);
					if (find_row != "") {
                		id = find_row.toString().substring(0, find_row.toString().indexOf(","));
                		rowIndex = 0;
					}
				}

				if (rowIndex != -1) {
					edt_label = viewPivotDashboard.pivot_advance.cells(id, 2).getValue();
					render_as = viewPivotDashboard.pivot_advance.cells(id, 3).getValue();
					date_format = viewPivotDashboard.pivot_advance.cells(id, 4).getValue();
					currency = viewPivotDashboard.pivot_advance.cells(id, 5).getValue();
					thou_sep = viewPivotDashboard.pivot_advance.cells(id, 6).getValue();
					rounding = viewPivotDashboard.pivot_advance.cells(id, 7).getValue();
					neg_as_red = viewPivotDashboard.pivot_advance.cells(id, 8).getValue();
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
					var rowIndex = viewPivotDashboard.pivot_advance.getRowIndex(id);

					var edt_label = label;
					var render_as = '';
					var date_format = '';
					var currency = '';
					var thou_sep = '';
					var rounding = '';
					var neg_as_red = '';

					if (rowIndex == -1) {
						var find_row = viewPivotDashboard.pivot_advance.findCell(label, 1, true);
						if (find_row != "") {
	                		id = find_row.toString().substring(0, find_row.toString().indexOf(","));
	                		rowIndex = 0;
						}
					}

					if (rowIndex != -1) {
						edt_label = viewPivotDashboard.pivot_advance.cells(id, 2).getValue();
						render_as = viewPivotDashboard.pivot_advance.cells(id, 3).getValue();
						date_format = viewPivotDashboard.pivot_advance.cells(id, 4).getValue();
						currency = viewPivotDashboard.pivot_advance.cells(id, 5).getValue();
						thou_sep = viewPivotDashboard.pivot_advance.cells(id, 6).getValue();
						rounding = viewPivotDashboard.pivot_advance.cells(id, 7).getValue();
						neg_as_red = viewPivotDashboard.pivot_advance.cells(id, 8).getValue();
					}

					final_obj.rows.push({
						 id:id,
						 bgColor: "#BEE4EE",
						 data:[id,label,edt_label, render_as, date_format, currency, thou_sep, rounding, neg_as_red]
					});
				});
			} 

			if (rend_val == 'CrossTab Table' || rend_val == 'Table') {
				viewPivotDashboard.adv_form.disableItem('xaxis_label');
				viewPivotDashboard.adv_form.disableItem('yaxis_label');
			} else {
				viewPivotDashboard.adv_form.enableItem('xaxis_label');
				viewPivotDashboard.adv_form.enableItem('yaxis_label');
			}

			viewPivotDashboard.pivot_advance.clearAll();
			viewPivotDashboard.pivot_advance.enableAlterCss("","");
			viewPivotDashboard.pivot_advance.parse(final_obj, "json");
    	} else if(tabid !== lastId && tabid == 'view') {
    		if (has_permission == 'n' || (excel_sheet_id != "" && excel_sheet_id != null)) {
                return;
	    	}
    		var report_title = viewPivotDashboard.adv_form.getItemValue('report_name');
    		var x_axis = viewPivotDashboard.adv_form.getItemValue('xaxis_label');
    		var y_axis = viewPivotDashboard.adv_form.getItemValue('yaxis_label');
    		window.refresh_report(report_title, x_axis, y_axis);
    	}
    }

    /**
     * [page_toolbar_click Toolbar click]
     * @param  {[type]} id [Tool id]
     */
    viewPivotDashboard.page_toolbar_click = function(id) {
    	if (id == 'filters') {
    		if (has_permission == 'n') {
    			show_messagebox('You do not have permission to view this report. Please contact administrator.');
	    		return;
	    	}
    		viewPivotDashboard.open_filter_win();
    	}
    }
    
    var criteria_window;
    var criteria_toolbar = {};
    var criteria_layout = {};
    var criteriaWin = {};

    /**
     * [open_filter_win Open Filter Window]
     */
    viewPivotDashboard.open_filter_win = function() {
    	var report_type = '<?php echo $report_type;?>';
    	var report_id = '<?php echo $report_id ?? '';?>';
    	var report_name = '<?php echo $report_name;?>';
    	var report_param_id = '<?php echo $paramset_id;?>';
    	var component_id = '<?php echo $component_id;?>';

    	var report_template = viewPivotDashboard.get_report_template(report_id, report_type);
	 	var php_path = '<?php echo $app_adiha_loc; ?>';
        var url = php_path + 'adiha.html.forms/_reporting/view_report/' + template_name;
        var view_id = '<?php echo $view_id;?>';

        var params = {
        	active_object_id: report_param_id, 
			report_type: report_type, 
			report_id: report_id, 
			report_name: report_name, 
			report_param_id: report_param_id,
			call_from:'pinned_pivot',
			view_id:view_id
		};

		if (!criteria_window) {
            criteria_window = new dhtmlXWindows();
        }

        var win_name = 'w_' + report_id;
        criteriaWin['win_' + report_id] = criteria_window.createWindow(win_name, 0, 0, 400, 300);
        criteriaWin['win_' + report_id].setText('Pivot Criteria');
        criteriaWin['win_' + report_id].centerOnScreen();
        criteriaWin['win_' + report_id].maximize();
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
        	var report_id = '<?php echo $report_id ?? '';?>';
        	var report_type = '<?php echo $report_type;?>';

		    if (id == 'cancel') {
		    	criteriaWin['win_' + report_id].close();
		    } else {
		    	var ifr = criteria_layout['layout_' + report_id].cells("a").getFrame();
	            var ifrWindow = ifr.contentWindow;
                if (is_dashboard == 'y') {
                    parent.dashboard_detail_layout.cells(cell_id).progressOn();
                }
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

					adiha_post_data("return", data, '', '', 'viewPivotDashboard.refresh_std_pivot_file');
            	} else {
            		var params = ifrWindow.report_parameter(false, 1);

                    if (params) {
                        if (excel_sheet_id != 'null' && excel_sheet_id != '') {
                            var data = {
                                "action" : "spa_rfx_format_filter",
                                "flag" : "f",
                                "paramset_id" : params.paramset_id,
                                "parameter_string" : params.report_filter.join(','),
                                "is_excel_report" : "1"
                            }
                            
                            criteriaWin['win_' + report_id].close();
                            adiha_post_data("return", data, '', '', 'viewPivotDashboard.get_excel_snapshot');
                        } else {
                        	var server_path = "<?php echo $server_path;?>";
                        	params.report_id = report_id;
                        	var data = {
    							"action": "spa_generate_pivot_file", 
    							"paramset_id": params.paramset_id,
    							"component_id": (params.items_combined && params.items_combined!= '' && params.items_combined != null)?params.items_combined:component_id,
    					        "criteria":params.report_filter.join(','),
    					        "report_name":params.report_name
    						}

    						criteriaWin['win_' + report_id].close();
    						adiha_post_data("return", data, '', '', 'viewPivotDashboard.refresh_rp_pivot_file');
                        }
                    }
            	}
		    }
		});
    }
    
    /**
     * Builds the excel report parameters and
     * Gets the file information of the excel snapshot
     * @param  {Array} result Filter information
     */
    viewPivotDashboard.get_excel_snapshot = function(result) {
        var view_report_filter_xml = build_excel_parameters(result);
        
        var data = {
                        "action" : "spa_view_report",
                        "flag" : "o",
                        "report_id" : excel_sheet_id,
                        "view_report_filter_xml" : view_report_filter_xml,
                        "export_format" : "PNG"
                    }
        adiha_post_data("return", data, '', '', 'viewPivotDashboard.load_excel_snapshot');
    }

    /**
     * Loads excel snapshot image in the layout cell
     * @param  {Array} result Excel snapshot file information
     */
    viewPivotDashboard.load_excel_snapshot = function(result) {
        var file_path = result[0]['snapshot_filename'];
        var attach_docs = '<?php echo $attach_docs_url_path; ?>';
        var full_file_path = attach_docs.replace('attach_docs', 'temp_Note') + '/' + file_path;
        layout_b.attachURL(full_file_path);
        if (is_dashboard == 'y') {
            parent.dashboard_detail_layout.cells(cell_id).progressOff();
        }
    }

    /**
     * [prepare_param Prepare param for pinned report refresh]
     */
    viewPivotDashboard.prepare_param = function() {
    	var file_path = $('#txt_file_path').val();
    	var rend_val = $('.pvtRenderer').val();
    	var attach_docs = '<?php echo $attach_docs_url_path; ?>';
        var full_file_path = attach_docs.replace('attach_docs', 'temp_Note') + '/' + file_path;
        var is_dashboard = '<?php echo $is_dashboard;?>';

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
	        is_dashboard:'y'
	    };
    }
    
    /**
     * [refresh_rp_pivot_file Callback for report manager report refresh]
     * @param  {[type]} result [Array]
     */
    viewPivotDashboard.refresh_rp_pivot_file = function(result) {
    	$('#txt_file_path').val(result[0].path);
    	viewPivotDashboard.refresh_pinned_report();
    }

    /**
     * [refresh_rp_pivot_file Callback for standard report refresh]
     * @param  {[type]} result [Array]
     */
    viewPivotDashboard.refresh_std_pivot_file = function(result) {
    	$('#txt_file_path').val(result[0].filename);  
    	viewPivotDashboard.refresh_pinned_report();
    }

    /**
     * [refresh_pinned_report Refresh pinned report]
     */
    viewPivotDashboard.refresh_pinned_report = function() {
    	var post_param = viewPivotDashboard.prepare_param();

    	if (
			post_param.col_list.detail_columns == '' 
			&& post_param.col_list.cols_columns == ''  
			&& post_param.col_list.rows_columns == '' 
			&& post_param.col_list.xaxis == '' 
			&& post_param.col_list.series == '' 
			&& post_param.col_list.yaxis == ''
		) {
    		viewPivotDashboard.refresh_view(post_param);
		} else {    		
	    	var view_id = '<?php echo $view_id;?>';
	    	viewPivotDashboard.form_change('view', view_id);
    	}
        if (is_dashboard == 'y') {
            parent.dashboard_detail_layout.cells(cell_id).progressOff();
        }
    }

    /**
     * [Returns the template name for the report]
     * @param report_id [Function ID for the Standard report and function id fro report manager report]
     */
    viewPivotDashboard.get_report_template = function(report_id, report_type) {        
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
     * [form_change Form change events]
     * @param  {[type]} name  [Item name]
     * @param  {[type]} value [Item value]
     * @param  {[type]} state [Item state]
     */
    viewPivotDashboard.form_change = function(name, value, state) {
        var file_path = '<?php echo $report_views_url_path;?>';
        var paramset_id = '<?php echo $paramset_id;?>';
        var component_id = '<?php echo $component_id;?>';
        if (name == 'view') {
        	if (value == '' || value == null) {
        		return;
	    	} else if (value == -1) {
	    		viewPivotDashboard.form_change_callback([]);
    		} else {
	        	var data = {
		            "action":"spa_pivot_report_view",
		            "flag":"t",
		            "view_id":value,
                    "paramset_id":paramset_id,
                    "component_id":component_id,
		            "grid_type":"g"
		        }
		        var sql_param = $.param(data);
		        var sql_url = js_data_collector_url + "&" + sql_param;

		        viewPivotDashboard.pivot_advance.clearAll();
		        viewPivotDashboard.pivot_advance.load(sql_url, function() {
		        	var data_sql = {"action": "spa_pivot_report_view", "flag":'s', "view_id":value}
	        		adiha_post_data("return_array", data_sql, '', '', 'viewPivotDashboard.form_change_callback');
		        });
		    }
        }
    }

    /**
     * [form_change_callback Form change callback operations]
     * @param  {[object]} result  [Item name]
     */
    viewPivotDashboard.form_change_callback = function(result) {
        var file_path = $('#txt_file_path').val();
        var attach_docs = '<?php echo $attach_docs_url_path; ?>';
        var full_file_path = attach_docs.replace('attach_docs', 'temp_Note') + '/' + file_path;
        var graph_type = '';

        //If Excel Report/Snapshot just show the snapshot file
        if (excel_sheet_id != 'null' && excel_sheet_id != '') {
	        layout_b.attachURL(full_file_path);
            parent.myDashboard.turn_view_mode(true);
        	return false;
        }

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
                graphType:'line',
                col_list: JSON.stringify(pivot_col_list)
            };
        } else {             
        	if (viewPivotDashboard.adv_form) {
        		var cell_text = '<?php echo $cell_text;?>';
        		var rname = (!result[0][5] || result[0][5].trim() == '') ? cell_text : result[0][5];
	            viewPivotDashboard.adv_form.setItemValue('report_name', rname);
	            viewPivotDashboard.adv_form.setItemValue('xaxis_label', result[0][6]);
	            viewPivotDashboard.adv_form.setItemValue('yaxis_label', result[0][7]);   	            
            }       

            var renderer = result[0][3];
            var detail = (result[0][2] == null) ? '' : result[0][2];

            if (renderer == 'Table') {
                pivot_col_list['detail_columns'] = (result[0][1] == null) ? '' : result[0][1];
                pivot_col_list['grouping_columns'] = (result[0][0] == null) ? '' : result[0][0];
                aggregators = '';
            } else if (renderer == 'CrossTab Table') {                
                pivot_col_list['rows_columns'] = (result[0][0] == null) ? '' : result[0][0];
                pivot_col_list['cols_columns'] = (result[0][1] == null) ? '' : result[0][1];
                 
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
                is_dashboard:'y'
            };
        }
        viewPivotDashboard.refresh_view(post_param);
    }
//viewPivotDashboard.tab_click
    /**
     * [refresh_view Refresh View dropdown]
     * @param  {[type]} params [param object]
     */
    viewPivotDashboard.refresh_view = function(params) {      
        layout_b = viewPivotDashboard.inner_layout_view.cells('a');    
        var url = js_php_path + 'pivot.template.php';
        layout_b.attachURL(url, true, params);
    }


    /**
     * [print_report Print Report]
     * @param  {[type]} report_title [Report Title]
     */
    viewPivotDashboard.print_report = function(report_title) {
        var win_content = $(".pvtRendererArea").html();
        var path = js_php_path + 'print.preview.php';
        var param = {
            "html_string":win_content,
            "report_title":report_title
        }
        open_window(path, param);
    }


    viewPivotDashboard.turn_view_mode = function(mode) {
		if (mode) {
			viewPivotDashboard.toolbar.cont.style.display = 'none';
			context_menu.addContextZone('body_content');
			$('.pivot-menu-tool').hide();
			$('.dhxtabbar_tabs').hide();
			$('.inner-content-cell').css('width', '120%');
		} else {
			viewPivotDashboard.toolbar.cont.style.display = 'block';
			context_menu.removeContextZone('body_content');
			$('.pivot-menu-tool').show();
			$('.dhxtabbar_tabs').show();
			$('.inner-content-cell').css('width', '120%');
		}        
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