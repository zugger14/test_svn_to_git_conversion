<?php
/**
 * Screen for the generic pivot functionality
 * @copyright Pioneer Solutions
 */
?>
<!DOCTYPE html>
<html>
    <head>
    	<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
        <title>Pivot Demo</title>
        <?php  
            require_once('components/include.file.v3.php'); 

            $file_path = (isset($_REQUEST["file_path"]) && $_REQUEST["file_path"] != '') ? $_REQUEST["file_path"] : '';
            $col_list = (isset($_REQUEST["col_list"]) && $_REQUEST["col_list"] != '') ? $_REQUEST["col_list"] : '';
            $report_type = (isset($_REQUEST["report_type"]) && $_REQUEST["report_type"] != '') ? $_REQUEST["report_type"] : 'tablix';
            $renderer_type = (isset($_REQUEST["renderer_type"]) && $_REQUEST["renderer_type"] != '') ? $_REQUEST["renderer_type"] : 'Table';
            $aggregators = (isset($_REQUEST["aggregators"]) && $_REQUEST["aggregators"] != '') ? $_REQUEST["aggregators"] : '';
            $call_from = (isset($_REQUEST["call_from"]) && $_REQUEST["call_from"] != '') ? $_REQUEST["call_from"] : '';
            $dataset_id = (isset($_REQUEST["dataset_id"]) && $_REQUEST["dataset_id"] != '') ? $_REQUEST["dataset_id"] : '';
            $dataset_array = (isset($_REQUEST["dataset_array"]) && $_REQUEST["dataset_array"] != '') ? json_decode($_REQUEST["dataset_array"]) : '';
            $process_id = (isset($_REQUEST["process_id"]) && $_REQUEST["process_id"] != '') ? $_REQUEST["process_id"] : '';
            $is_pin = (isset($_REQUEST["is_pin"]) && $_REQUEST["is_pin"] != '') ? $_REQUEST["is_pin"] : 'n';
            $is_dashboard = (isset($_REQUEST["is_dashboard"]) && $_REQUEST["is_dashboard"] != '') ? $_REQUEST["is_dashboard"] : 'n';
            $graph_type = (isset($_REQUEST["graphType"]) && $_REQUEST["graphType"] != '') ? $_REQUEST["graphType"] : '';
			$active_tab_id = (isset($_REQUEST["active_tab_id"]) && $_REQUEST["active_tab_id"] != '') ? $_REQUEST["active_tab_id"] : '';
            $ds_col_info_pivot = array();
            if ($process_id != '') {
                $xml_url = "EXEC spa_rfx_report_dataset_dhx @flag='h', @process_id='$process_id', @report_dataset_id='$dataset_id'";
                $ds_col_info_pivot = readXMLURL2($xml_url);
            }
			$pivot_view_mode = (isset($_REQUEST["pivot_view_mode"]) && $_REQUEST["pivot_view_mode"] != '') ? $_REQUEST["pivot_view_mode"] : '';
            
        ?>        
    </head>
    <link href="<?php echo $main_menu_path; ?>bootstrap-3.3.1/dist/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <link href="<?php echo $main_menu_path; ?>font-awesome-4.2.0/css/font-awesome.min.css" rel="stylesheet" type="text/css" />
    <style>
        *,
        *:before,
        *:after {
          -webkit-box-sizing: content-box;
             -moz-box-sizing: content-box;
                  box-sizing: content-box;
        }
        label {
            font-size: 13px;
            font-weight: 100;
            margin-bottom: 0px !important;
            margin-top: 2px !important;
        }
        .form-control {
            -webkit-box-sizing: content-box;
            -moz-box-sizing: content-box;
            box-sizing: content-box;
            box-sizing: border-box;
        }
        /* css for column placement zones watermark */
        .div_watermark_row, .div_watermark_col, .div_watermark_data {
            color: gray;
            opacity: 0.30;
            font-size: 15px;
            width: 100%;
            top: 2%;
            text-align: left;
            z-index: 0;
        }
    </style>
    <body>
        
        <script type="text/javascript">
            var call_from_gbl = '<?php echo $call_from; ?>';
            var dataset_id = '<?php echo $dataset_id; ?>';
            var process_id_gbl = '<?php echo $process_id; ?>';
            var dataset_array = $.parseJSON('<?php echo json_encode($dataset_array, JSON_HEX_APOS); ?>');
            var ds_col_info_gbl_pivot = $.parseJSON('<?php echo json_encode($ds_col_info_pivot, JSON_HEX_APOS); ?>');
            var file = '<?php echo $file_path;?>';
            var report_type = '<?php echo $report_type; ?>';
			var pivot_view_mode = '<?php echo $pivot_view_mode; ?>';
			var active_tab_id = '<?php echo $active_tab_id; ?>';
            
            $(function(){                       
                //layout_b.progressOn();

                var is_pin = '<?php echo $is_pin;?>';
				
				var derivers = $.pivotUtilities.derivers;

                if (report_type == 'chart') {
                    var renderers = $.pivotUtilities.gchart_renderers;
					
					if(call_from_gbl == 'report_manager_dhx')
						delete renderers["Combo"];
					
                } else if (report_type == 'mixed') {
                    var renderers = $.extend($.pivotUtilities.renderers, $.pivotUtilities.gchart_renderers);
                } else {
                    var renderers = $.pivotUtilities.renderers;
                }

                var col_lists = '<?php echo $col_list; ?>';

                if (col_lists != '')
                    col_lists = $.parseJSON(col_lists);
                
                var renderer_type = '<?php echo $renderer_type; ?>';
                var aggregator_name = '<?php echo $aggregators; ?>';
                var graph_type_name = '<?php echo $graph_type; ?>';
                
                var col_arr = new Array();
                var row_arr = new Array();
                var val_arr = new Array();
                var param_obj = {
                    renderers: renderers,
                    rendererName: renderer_type,
                    onRefresh: function(config) {
                    	expand_pivot_view();
                    }
                };
                
                if(renderer_type == 'Table' || renderer_type == 'CrossTab Table') {                    
                    if(renderer_type == 'Table' && (col_lists.detail_columns != '' || col_lists.grouping_columns != '')) {
                        cols = col_lists.detail_columns;
                        rows = col_lists.grouping_columns;
                        col_arr = cols.split(",");
                        row_arr = rows.split(",");
                        
                        param_obj = {    
                            renderers: renderers,
                            cols: col_arr,
                            rows: row_arr,
                            rendererName: renderer_type,
                            onRefresh: function(config) {
                            	expand_pivot_view();
                            },
                            active_tab: active_tab_id.split()

                        };
                    } else if(renderer_type == 'CrossTab Table' && (col_lists.detail_columns != '' || col_lists.cols_columns != ''|| col_lists.rows_columns != '')) { //for crosstab
                        cols = col_lists.cols_columns;
                        rows = col_lists.rows_columns;
                        vals = col_lists.detail_columns;

                        col_arr = cols.split(",");
                        row_arr = rows.split(",");
                        val_arr = vals.split(",");
						
                        aggregator = aggregator_name.split(",");
                        var graph_type = new Array();

						param_obj = {       
                            renderers: renderers,
                            cols: col_arr,
                            rows: row_arr,
                            vals: val_arr,
                            aggregatorName: aggregator,
                            rendererName: renderer_type,
                            graphType:graph_type,
                            onRefresh: function(config) {
                            	expand_pivot_view();
                            },
                            active_tab: active_tab_id.split()
                        };
                        //console.log(param_obj);
                    }
                    //}
                } else { //for chart renderer types
                    if(col_lists.xaxis != '' || col_lists.series != '' || col_lists.yaxis != '') {
                        cols = col_lists.xaxis;
                        rows = col_lists.series;
                        vals = col_lists.yaxis;
                        col_arr = cols.split(",");
                        row_arr = rows.split(",");
                        val_arr = vals.split(",");
    					aggregator = aggregator_name.split(",");
    					var graph_type = new Array();
    					graph_type = graph_type_name.split(",");

                        param_obj = {   
                            renderers: renderers,
                            cols: col_arr,
                            rows: row_arr,
                            vals: val_arr,
                            aggregatorName: aggregator,
                            rendererName: renderer_type,
                            graphType:graph_type,
                            onRefresh: function(config) {
                            	expand_pivot_view();
                            },
                            active_tab: active_tab_id.split()
                        };
                    }
                    
                }
                //console.log(param_obj);
                $.get(file, { "_": $.now() }, function(mps) {
					var output_div = $("#output");
					if(active_tab_id != "") {
						output_div = $("#output." + active_tab_id);
					}
                    output_div.pivotUI($.csv.toArrays(mps), param_obj);
                }).done(function() {
                    //layout_b.progressOff();                     
					// this needs to be trigger in all cases. - Rajiv
                    
                    //update column alias on pivot UI columns
                    if(call_from_gbl == 'report_manager_dhx') {
                        fx_update_col_alias();
                    }

					fx_register_events();
                    //console.log($('#pvtMainTable').prop('outerHTML'));
					
					if (call_from_gbl == 'pivot_views') {
						if (pivot_view_mode == 'true') {
							if(active_tab_id != "") {
								// $('#expand_collapse', '.' + active_tab_id).unbind().bind("click", function() {
								// 	$(".pvtRendererArea",$(this).parent().next()).parent().parent().siblings().toggle();
								// 	$(".pvtRendererArea",$(this).parent().next()).siblings().toggle();
								// });
								$('#expand_collapse', '.' + active_tab_id).trigger('click');
							} else {
								$('#expand_collapse').trigger('click');
							}
							
						}
						//turn_view_mode(true);
					} else {
						parent.myDashboard.turn_view_mode(true);
					}
                });

             });
            fx_register_events = function() {
            	if(call_from_gbl == 'report_manager_dhx') {
					// only this function is specific to report manager dhx - Rajiv
					var renderer = $('.pvtRenderer').val();
					fx_renderer_type_change(renderer);                    
				}
                fx_update_watermark_pivot_zones();	
            }

            update_watermark = function() {
            	if(call_from_gbl == 'report_manager_dhx') {
					// only this function is specific to report manager dhx - Rajiv
					var renderer = $('.pvtRenderer').val();
					fx_renderer_type_change(renderer);                      
				}
                fx_update_watermark_pivot_zones();
            }
            function fx_update_watermark_pivot_zones() {
                var renderer = $('.pvtRenderer').val();
                $('.div_watermark_row, .div_watermark_col, .div_watermark_data').remove();
                if(renderer == 'Table') {
                    $('.pvtRows').prepend('<div class="div_watermark_row">Grouping Columns</div>');
                    $('.pvtCols').prepend('<div class="div_watermark_col">Table Columns</div>');
                    $('.pvtAggs').prepend('<div class="div_watermark_data"></div>');
                } else if(renderer == 'CrossTab Table') {
                    $('.pvtRows').prepend('<div class="div_watermark_row">Rows</div>');
                    $('.pvtCols').prepend('<div class="div_watermark_col">Cols</div>');
                    $('.pvtAggs').prepend('<div class="div_watermark_data">Data</div>');
                } else {
                    $('.pvtRows').prepend('<div class="div_watermark_row">Series (Z)</div>');
                    $('.pvtCols').prepend('<div class="div_watermark_col">Category (X)</div>');
                    $('.pvtAggs').prepend('<div class="div_watermark_data">Data (Y)</div>');
                }
                
            }
            function get_columns() {
                var renderer = $('.pvtRenderer').val();
                var return_array = new Array();
                return_array['renderer_type'] = renderer;
                return_array['detail_columns'] = '';                
                return_array['grouping_columns'] = '';
                return_array['columns'] = '';
                return_array['rows'] = '';   
                return_array['series'] = '';
                return_array['xaxis'] = '';
                return_array['yaxis'] = '';

                var report_type = '<?php echo $report_type; ?>';

                if (renderer == 'Table') {
                    var grouping_columns = $('.pvtRows li').find('span:first').map(function(){
                        return $(this).justtext();
                    }).get().join();

                    var detail_columns = $('.pvtCols li').find('span:first').map(function(){
                        return $(this).justtext();
                    }).get().join();
                    
                    return_array['grouping_columns'] = grouping_columns;
                    return_array['detail_columns'] = detail_columns;
                } else if (renderer == 'CrossTab Table'){
                    var rows = $('.pvtRows li').find('span:first').map(function(){
                        return $(this).justtext();
                    }).get().join();

                    var columns = $('.pvtCols li').find('span:first').map(function(){
                        return $(this).justtext();
                    }).get().join();

                    var detail_columns = $('.pvtVals').map(function(){
                        $that = $(this);
                        var aggregator = $(this).find('.pvtAggregator').val();
                        var attribute = '';

                        if ($(".pvtAttrDropdown").length) {
                            if(call_from_gbl == 'report_manager_dhx') {
                                attribute = $(this).find('.pvtAttrDropdown').attr('dataset_col_name');
                            } else {
                                attribute = $(this).find('.pvtAttrDropdown').contents().get(0).nodeValue;
                            }                            
                        }
                        
                        return aggregator + '||||' + attribute;
                    }).get().join();
                    
                    return_array['detail_columns'] = detail_columns;
                    return_array['columns'] = columns;
                    return_array['rows'] = rows;
                } else {
                    var series = $('.pvtRows li').find('span:first').map(function(){
                        return $(this).justtext();
                    }).get().join();

                    var xaxis = $('.pvtCols li').find('span:first').map(function(){
                        return $(this).justtext();
                    }).get().join();

                    var yaxis = $('.pvtVals').map(function(){
                        $that = $(this);
                        var aggregator = $('.pvtAggregator', $(this)).val();
                        var graph_type = $('.graph_type', $(this)).val();
                        var attribute = '';

                        if ($(".pvtAttrDropdown").length) {
                            if(call_from_gbl == 'report_manager_dhx') {
                                attribute = $(this).find('.pvtAttrDropdown').attr('dataset_col_name'); //$('option:selected', '.pvtAttrDropdown').attr('dataset_col_name');
                            } else {
                                attribute = $(this).find('.pvtAttrDropdown').contents().get(0).nodeValue; //$('.pvtAttrDropdown').val();
                            }                            
                        }

                        if (call_from_gbl == 'report_manager_dhx'){
                        return aggregator + '||||' + attribute;
                        } else {
                        	return aggregator + '||||' + attribute + '||||' + graph_type;
                        }

                        
                    }).get().join();
                    
                    return_array['series'] = series;
                    return_array['xaxis'] = xaxis;
                    return_array['yaxis'] = yaxis;
                }
                return return_array;
            }
            
            //function to replace col_name with alias and add new attribute col_name
            
            fx_update_col_alias = function() {
                $('.pvtAttr').each(function() {
                    var col_name = $(this).clone()
                        .children()
                        .remove()
                        .end()
                        .text();
                     
//                    var col_alias = ds_col_info_gbl_pivot.filter(function(e) {
//                        return e.column_name_real.split('.')[1].toLowerCase() == col_name.split('.')[1].toLowerCase();
//                    });
                    var col_info = $.map(ds_col_info_gbl_pivot, function(val,key) {
                        if(
                            (val.column_name_real.split('.')[1].toLowerCase() == col_name.split('.')[1].toLowerCase() && val.root_dataset_id == -1)
                            || (val.column_name_real.toLowerCase() == col_name.toLowerCase() && val.root_dataset_id != -1)
                            ) 
                        {
                            var return_arr = [];
                            return_arr.push([col_name,val.column_name_real,val.alias]);
                            return return_arr;
                        }
                            
                        else return null;
                    });
                    //console.log(col_info);
                    
                    $(this).text('');
                    $(this).text(col_info[0][2]);
                    //$(this).text(col_alias[0]);
                    $(this).attr({
                        'csv_col_name': col_info[0][0],
                        'dataset_col_name': col_info[0][1]
                    });
                    
                });
                
                
                
                
            }
            
            //get dataset column name , esp for dropdown (yaxis) on crosstab table called from pivot.js
            fx_get_dataset_col_name = function(ip_value) {
                var return_val = ip_value;
                if(call_from_gbl == 'report_manager_dhx') {
                    var col_info = $.map(ds_col_info_gbl_pivot, function(val,key) {
                        if(
                            (val.column_name_real.split('.')[1].toLowerCase() == ip_value.split('.')[1].toLowerCase() && val.root_dataset_id == -1)
                            || (val.column_name_real.toLowerCase() == ip_value.toLowerCase() && val.root_dataset_id != -1)
                            ) 
                        {
                            var return_arr = [];
                            return_arr.push([ip_value,val.column_name_real,val.alias]);
                            return return_arr;
                        }
                            
                        else return null;
                    });
                    return_val = col_info[0][1];
                }
                return return_val;
            };
           
            //function to set alias value on table header, called when content is put on th from lib file pivot.js
            fx_get_col_alias = function(ip_value) {
                //console.log(ip_value);
                var return_val = ip_value;
                
                if(call_from_gbl == 'report_manager_dhx') {
                    
                    var col_alias = ds_col_info_gbl_pivot.filter(function(e) {
                        
                        if(
                            (e.column_name_real.split('.')[1].toLowerCase() == ip_value.split('.')[1].toLowerCase() && e.root_dataset_id == -1)
                            || (e.column_name_real.toLowerCase() == ip_value.toLowerCase() && e.root_dataset_id != -1)
                            ) 
                        {
                            return true;
                        } else return false;
                        
                    });
                    //console.log(col_alias);
                    return_val = col_alias[0].alias;
                }
                
                return get_locale_value(return_val);
            }

            /**
             * [format_val Format value on pivot report]
             * @param  {[type]} id    [Field Id]
             * @param  {[type]} value [Value]
             */
            format_val = function(id, value, name) {
            	if (call_from_gbl !== 'report_manager_dhx' && typeof id !== 'undefined' && id != '') {
            		var is_dashboard = '<?php echo $is_dashboard;?>';

            		if (is_dashboard == 'y') {
                        value = viewPivotDashboard.get_formatted_value(id, value, name);
                    } else if(call_from_gbl == 'pivot_views') {
                        value = report_ui_template.fx_get_formatted_value_pivot_views(id, value, name);
					} else {
                        if(viewPivotReport.get_formatted_value != undefined) {
                            value = viewPivotReport.get_formatted_value(id, value, name);
                        }
                    }
            			
            	}

            	return value;
            }

            /**
             * [get_label Get custom label for fields]
             * @param  {[type]} id [Field Id]
             */
            get_label = function(id, name) {
                var label = '';
            	if (call_from_gbl !== 'report_manager_dhx' && typeof id !== 'undefined' && id != '') {
            		var is_dashboard = '<?php echo $is_dashboard;?>';

            		if (is_dashboard == 'y') {
                        label = viewPivotDashboard.get_label(id, name);
                    } else if(call_from_gbl == 'pivot_views') {
                        label = report_ui_template.fx_get_label_pivot_views(id, name);
                    } else {
                        if(viewPivotReport.get_label != undefined) {
                            label = viewPivotReport.get_label(id, name);
                        }
                        
                    }
            			
            	}

            	return get_locale_value(label);
            }

            jQuery.fn.justtext = function() {   
                if(call_from_gbl == 'report_manager_dhx') {
                    return $(this).clone()
                            .children()
                            .remove()
                            .end()
                            .attr('dataset_col_name');
                } else {
                    return $(this).clone()
                        .children()
                        .remove()
                        .end()
                        .text();
                }
            };

            refresh_report = function(report_title, x_axis, y_axis) {
            	$('.hidden-refresh-btn').text('');
            	$('.hidden-x-axis').val('');
            	$('.hidden-y-axis').val('');

            	$('.hidden-refresh-btn').text(report_title);
            	$('.hidden-x-axis').val(x_axis);
            	$('.hidden-y-axis').val(y_axis);

            	$('.hidden-refresh-btn').trigger("click");
            }

            hide_view_panel = function() {
            	var is_pin = '<?php echo $is_pin;?>';
                if (call_from_gbl !== 'report_manager_dhx' && is_pin == 'y') {
					viewPivotReport.pivot_template.cells("a").collapse();
					//viewPivotReport.pivot_template.cells("a").hideArrow();
        		}
            }

            var expand_counter = 1;
            expand_pivot_view = function() {
            	if (call_from_gbl !== 'report_manager_dhx') {
            		var is_pin = '<?php echo $is_pin;?>';
            		var is_dashboard = '<?php echo $is_dashboard;?>';

                    if ((is_pin == 'y' || is_dashboard == 'y') && expand_counter == 1) {
                		$('#expand_collapse').trigger('click');
                		turn_view_mode(true);
                		expand_counter++;
                    }
            	}
            }

            turn_view_mode = function(mode) {
            	if (mode) {
					$('.pivot-menu-tool').hide();
					$('.dhxtabbar_tabs').hide();
					$('.inner-content-cell').css('width', '120%');
				} else {
					$('.pivot-menu-tool').show();
					$('.dhxtabbar_tabs').show();
					$('.inner-content-cell').css('width', '120%');
				}
            }

            get_report_name = function() {
            	var is_dashboard = '<?php echo $is_dashboard;?>';
            	var is_pin = '<?php echo $is_pin;?>';
            	
				if (call_from_gbl == 'pivot_views') {
					return report_ui_template.fx_get_report_label_pivot_views();	
				} else {
					if (is_pin == 'y') if (viewPivotReport.adv_form) return viewPivotReport.adv_form.getItemValue('report_name');             	
					if (is_dashboard == 'y') if (viewPivotDashboard.adv_form) return viewPivotDashboard.adv_form.getItemValue('report_name'); 
            	}            
	            return '';
            }

            get_xaxis_label = function() {
            	var is_dashboard = '<?php echo $is_dashboard;?>';
            	var is_pin = '<?php echo $is_pin;?>';
				if (call_from_gbl == 'pivot_views') {
					return report_ui_template.fx_get_xaxis_label_pivot_views();	
				} else {
					if (is_pin == 'y') if (viewPivotReport.adv_form) return viewPivotReport.adv_form.getItemValue('xaxis_label');	            
					if (is_dashboard == 'y') if (viewPivotDashboard.adv_form) return viewPivotDashboard.adv_form.getItemValue('xaxis_label');
				}
            	return '';
            }

            get_yaxis_label = function() {
            	var is_dashboard = '<?php echo $is_dashboard;?>';
            	var is_pin = '<?php echo $is_pin;?>';
				if (call_from_gbl == 'pivot_views') {
					return report_ui_template.fx_get_yaxis_label_pivot_views();	
				} else {
					if (is_pin == 'y') if (viewPivotReport.adv_form) return viewPivotReport.adv_form.getItemValue('yaxis_label');	            
					if (is_dashboard == 'y') if (viewPivotDashboard.adv_form) return viewPivotDashboard.adv_form.getItemValue('yaxis_label');
				} 	
            	return '';
            }

        </script>
        <?php
		echo "<div id=\"output\" class=\"$active_tab_id\" style=\"margin: -1px 5px 3px 5px;\"></div>";
		?>
    </body>
</html>