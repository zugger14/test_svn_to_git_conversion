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

            $xml_url = "EXEC spa_rfx_report_dataset_dhx @flag='h', @process_id='$process_id', @report_dataset_id='$dataset_id'";
            $ds_col_info_pivot = readXMLURL2($xml_url);
            
        ?>        
    </head>
    <link href="<?php echo $main_menu_path; ?>bootstrap-3.3.1/dist/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
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

            gbl_csv_arr =[];
            gbl_param_obj = {};
            //used for custom column adjustment
            var template_pivot_li = _.template("\
                <li item_id=\"<%= tm_item_id %>\" class=\"axis_<%= tm_axis_seq %> ui-sortable-handle\" style=\"\"><span class=\"pvtAttr custom-column\" csv_col_name=\"<%= tm_csv_col_name %>\" dataset_col_name=\"<%= tm_dataset_col_name %>\"><%= tm_display_text %></span></li>\
            ");

            var template_pivot_data_table_header = _.template("\
                <th item_id=\"<%= tm_item_id %>\" class=\"pvtAxisLabel header-align-right custom-column\" style=\"text-align: right;\"><%= tm_header_label %></th>\
            ");

            var template_pivot_data_table_td = _.template("\
                <td item_id=\"<%= tm_item_id %>\" class=\"pvtRowLabel data-align-right custom-column\" style=\"text-align: right;\"><%= tm_td_text %></td>\
            ");


            var call_from_gbl = '<?php echo $call_from; ?>';
            var dataset_id = '<?php echo $dataset_id; ?>';
            var process_id_gbl = '<?php echo $process_id; ?>';
            var dataset_array = $.parseJSON('<?php echo json_encode($dataset_array, JSON_HEX_APOS); ?>');
            var ds_col_info_gbl_pivot = $.parseJSON('<?php echo json_encode($ds_col_info_pivot, JSON_HEX_APOS); ?>');
            var file = '<?php echo $file_path;?>';
            var report_type = '<?php echo $report_type; ?>';
			
			//use filename char ^ to know connected status of dataset
			var is_dataset_connected = (file.indexOf('^') > -1 ? 1 : 0);
			console.log(is_dataset_connected);
            
            $(function(){                       
                layout_b.progressOn();

                var is_pin = '<?php echo $is_pin;?>';
				
				var derivers = $.pivotUtilities.derivers;

                if (report_type == 'chart') {
                    var renderers = $.pivotUtilities.gchart_renderers;
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
                
                //console.log(col_lists);

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
                            }
                        };
                    } else if(renderer_type == 'CrossTab Table' && (col_lists.detail_columns != '' || col_lists.cols_columns != ''|| col_lists.rows_columns != '')) { //for crosstab
                        cols = col_lists.cols_columns;
                        rows = col_lists.rows_columns;
                        vals = col_lists.detail_columns;

                        col_arr = cols.split(",");
                        row_arr = rows.split(",");
                        val_arr = vals.split(",");
						
                        aggregator = aggregator_name.split(",");
						param_obj = {       
                            renderers: renderers,
                            cols: col_arr,
                            rows: row_arr,
                            vals: val_arr,
                            aggregatorName: aggregator,
                            rendererName: renderer_type,
                            onRefresh: function(config) {
                            	expand_pivot_view();
                            }
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
                        param_obj = {   
                            renderers: renderers,
                            cols: col_arr,
                            rows: row_arr,
                            vals: val_arr,
                            aggregatorName: aggregator,
                            rendererName: renderer_type,
                            onRefresh: function(config) {
                            	expand_pivot_view();
                            }
                        };
                    }
                    
                }
                $.get(file, { "_": $.now() }, function(mps) {
                    var csv_arr = $.csv.toArrays(mps);
                    $.each(col_arr,function(k,v){
                        if(v.indexOf('(CC)') > -1) {
                            csv_arr[0].push(v);
                        }
                    })
                    $.each(row_arr,function(k,v){
                        if(v.indexOf('(CC)') > -1) {
                            csv_arr[0].push(v);
                        }
                    })
                     $.each(val_arr,function(k,v){
                        if(v.indexOf('(CC)') > -1) {
                            csv_arr[0].push(v);
                        }
                    })
                    gbl_csv_arr =  csv_arr;
                    gbl_param_obj = param_obj;

                    $("#output").pivotUI(gbl_csv_arr, gbl_param_obj);
                }).done(function() {

                    layout_b.progressOff();                     
					// this needs to be trigger in all cases. - Rajiv
                    
                    //update column alias on pivot UI columns
                    if(call_from_gbl == 'report_manager_dhx') {
                        fx_update_col_alias();
                    }

					fx_register_events();
                    //console.log($('#pvtMainTable').prop('outerHTML'));

                    
                });
             });
            
            
            function arr_diff (a1, a2) {

                var a = [], diff = [];

                for (var i = 0; i < a1.length; i++) {
                    a[a1[i]] = true;
                }

                for (var i = 0; i < a2.length; i++) {
                    if (a[a2[i]]) {
                        delete a[a2[i]];
                    } else {
                        a[a2[i]] = true;
                    }
                }

                for (var k in a) {
                    diff.push(k);
                }

                return diff;
            }

            //adjust custom columns for report tablix
            fx_adjust_custom_columns_chart = function(series_custom_col_info, category_custom_col_info,col_info,group_info) {  

                var custom_col_info = [];
                var custom_row_info = [];
                $.each(category_custom_col_info, function(k,v){
                    custom_col_info.push(v.column_alias + '(CC)');                    
                })
                $.each(series_custom_col_info, function(k,v){
                    custom_row_info.push(v.column_alias + '(CC)');                    
                })
                
                var spliter = '';
                var split1 = '';
                var is_not_alias_diff = true;


                //check multi dataset exists or not
                $.each(gbl_csv_arr[0], function(k,v){
                    if(v.indexOf('.') > -1) {
                            if (spliter != v.split('.')[0] && spliter != '') {
                                is_not_alias_diff = false;
                                return false;
                            }
                        spliter = v.split('.')[0];
                    }                    
                })

                //get schema from dataset if single dataset is only used
                if (is_not_alias_diff) {
                    $.each(col_info, function(k,v){
                        if(v.indexOf('.') > -1) {
                            split1 = v.split('.')[0];
                            //col_info[k] = split1 + v.split('.')[0].toLowerCase;
                        }                    
                    })
                }   
                         
                var vals_arr = [];
                $.each(gbl_param_obj.vals, function(k,v){
                    if(v.indexOf('.') > -1 && is_not_alias_diff) {
                       vals_arr.push(split1 + '.' + v.split('.')[1]);
                    } else if (is_not_alias_diff) {
                        vals_arr.push(v);
                    }                 
                })

                if (is_not_alias_diff) {
                    gbl_param_obj.vals = vals_arr;                    
                }

                gbl_param_obj.cols = col_info;                
                gbl_param_obj.rows = group_info; 

                
                $.each(gbl_csv_arr[0], function(k,v){
                    if(v.indexOf('.') > -1 && is_not_alias_diff) {
                        gbl_csv_arr[0][k] =  split1 + '.' + v.split('.')[1];
                        //gbl_csv_arr[0][k] =  split1 + '.' + v.split('.')[1].toLowerCase;
                    }                 
                })
                
                $.merge(gbl_csv_arr[0],custom_col_info);
                $.merge(gbl_csv_arr[0],custom_row_info);

                                
                
                $("#output").pivotUI(gbl_csv_arr, gbl_param_obj, true);
                if(call_from_gbl == 'report_manager_dhx') {
                    fx_update_col_alias();
                }

                fx_register_events();   
                
            }

            //adjust custom columns for report tablix
            fx_adjust_custom_columns_crosstab = function(custom_col_info1, col_info,col_info_agg,ver_info,group_info) {

                var custom_col_info = [];
                var custom_col_val_arr = [];
                $.each(custom_col_info1, function(k,v){
                    custom_col_info.push(v.column_alias + '(CC)');                    
                    custom_col_val_arr.push("0");
                })                

                var spliter = '';
                var split1 = '';
                var is_not_alias_diff = true;

                //check multi dataset exists or not
                $.each(gbl_csv_arr[0], function(k,v){
                    if(v.indexOf('.') > -1) {
                            if (spliter != v.split('.')[0] && spliter != '') {
                                is_not_alias_diff = false;
                                return false;
                            }
                        spliter = v.split('.')[0];
                    }                    
                })

                //get schema from dataset if single dataset is only used and update to col_info)
                if (is_not_alias_diff) {
                    $.each(col_info, function(k,v){
                        if(v.indexOf('.') > -1) {
                            col_info[k] = spliter + '.' +v.split('.')[1];
                        }                    
                    })
                } 
                if (is_not_alias_diff) {
                    $.each(ver_info, function(k,v){
                        if(v.indexOf('.') > -1) {
                            ver_info[k] = spliter + '.' +v.split('.')[1];
                        }                    
                    })
                }   
                if (is_not_alias_diff) {
                    $.each(group_info, function(k,v){
                        if(v.indexOf('.') > -1) {
                            group_info[k] = spliter + '.' +v.split('.')[1];
                        }                    
                    })
                }                
                
                gbl_param_obj.cols = ver_info;                
                gbl_param_obj.rows = group_info; 

                gbl_param_obj.vals = col_info;
                gbl_param_obj.aggregatorName = col_info_agg;

                /*
                $.each(gbl_csv_arr[0], function(k,v){
                    if(v.indexOf('.') > -1 && is_not_alias_diff) {
                        gbl_csv_arr[0][k] =  split1 + '.' + v.split('.')[1];
                    }               
                })
                */
                $.merge(gbl_csv_arr[0],custom_col_info);

                //Add numeric value to custom column
                $.each(gbl_csv_arr, function(k,v){
                    if (k > 0) {
                            $.merge(gbl_csv_arr[k],custom_col_val_arr)
                            //gbl_csv_arr[k].push("0");
                    }
                    
                })

                gbl_param_obj.rendererName = 'CrossTab Table';

                $("#output").pivotUI(gbl_csv_arr, gbl_param_obj, true);
                if(call_from_gbl == 'report_manager_dhx') {
                    fx_update_col_alias();
                }

                fx_register_events();                
            }

            //adjust custom columns for report tablix
            fx_adjust_custom_columns = function(custom_col_info1, col_info,group_info) {                
                var custom_col_info = [];
                $.each(custom_col_info1, function(k,v){
                    custom_col_info.push(v.column_alias + '(CC)');                  
                })                

                var spliter = '';
                var split1 = '';
                var is_not_alias_diff = true;

                //check multi dataset exists or not
                $.each(gbl_csv_arr[0], function(k,v){
                    if(v.indexOf('.') > -1) {
                            if (spliter != v.split('.')[0] && spliter != '') {
                                is_not_alias_diff = false;
                                return false;
                            }
                        spliter = v.split('.')[0];
                    }                    
                })

                //get schema from dataset if single dataset is only used
                if (is_not_alias_diff) {
                    $.each(col_info, function(k,v){
                        if(v.indexOf('.') > -1) {
                            split1 = v.split('.')[0];
                        }                    
                    })
                }              
                
                gbl_param_obj.cols = col_info;                
                gbl_param_obj.rows = group_info; 

                $.each(gbl_csv_arr[0], function(k,v){
                    if(v.indexOf('.') > -1 && is_not_alias_diff) {
                        gbl_csv_arr[0][k] =  split1 + '.' + v.split('.')[1];
                    }/* else if (v.indexOf('CC') > -1) {
                        gbl_csv_arr[0].splice(k,2);
                    }  */                 
                })
                $.merge(gbl_csv_arr[0],custom_col_info);
                
                //console.log(gbl_csv_arr[0])

                $("#output").pivotUI(gbl_csv_arr, gbl_param_obj, true);
                if(call_from_gbl == 'report_manager_dhx') {
                    fx_update_col_alias();
                }

                fx_register_events();                
            }

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
                        var aggregator = $('.pvtAggregator').val();
                        var attribute = '';

                        if ($(".pvtAttrDropdown").length) {
                            if(call_from_gbl == 'report_manager_dhx') {
                                attribute = $(this).find('.pvtAttrDropdown').attr('dataset_col_name'); //$('option:selected', '.pvtAttrDropdown').attr('dataset_col_name');
                            } else {
                                attribute = $(this).find('.pvtAttrDropdown').contents().get(0).nodeValue; //$('.pvtAttrDropdown').val();
                            }                            
                        }

                        return aggregator + '||||' + attribute;
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
                    
                    //console.log(col_name);
                    if (col_name.indexOf('(CC)') > -1) {
                        $(this).text('');
                        var col_name_text = col_name;
                        $(this).parent('li').addClass(col_name_text);
                        $(this).parent('li').attr({'item_id':col_name_text});
                        $(this).text(col_name);
                        //$(this).text(col_alias[0]);
                        $(this).attr({
                            'csv_col_name': col_name_text,
                            'dataset_col_name': col_name_text.replace('(CC)','')
                        });
                    } else {
                        var col_info = $.map(ds_col_info_gbl_pivot, function(val,key) {
	//if(col_name.indexOf('source_deal_header_id')>-1 && val.column_name_real.indexOf('source_deal_header_id')>-1) {console.log(col_name);console.log(val);}
                            /*
							if(
                                (val.column_name_real.split('.')[1].toLowerCase() == col_name.split('.')[1].toLowerCase() && val.root_dataset_id == -1)
                                || (val.column_name_real.toLowerCase() == col_name.toLowerCase() && val.root_dataset_id != -1)
                                )
								*/
							if(
                                (val.column_name_real.split('.')[1].toLowerCase() == col_name.split('.')[1].toLowerCase() && is_dataset_connected == 0)
                                || (val.column_name_real.toLowerCase() == col_name.toLowerCase() && is_dataset_connected == 1)
                                )
                            {
								
                                var return_arr = [];
                                return_arr.push([col_name,val.column_name_real,val.alias]);
                                return return_arr;
                            }
                                
                            else return null;
                        });
						// console.log(col_info);
                        $(this).text('');
                        $(this).text(col_info[0][2]);
                        //$(this).text(col_alias[0]);
                        $(this).attr({
                            'csv_col_name': col_info[0][0],
                            'dataset_col_name': col_info[0][1]
                        });
                    }
                                
                    
                });              
                                
                
            }
            
            //get dataset column name , esp for dropdown (yaxis) on crosstab table called from pivot.js
            fx_get_dataset_col_name = function(ip_value) {
                var return_val = ip_value;
                if(call_from_gbl == 'report_manager_dhx') {
                    var col_info = $.map(ds_col_info_gbl_pivot, function(val,key) {
                        if(
                            (val.column_name_real.split('.')[1].toLowerCase() == ip_value.split('.')[1].toLowerCase() && is_dataset_connected == 0)
                            || (val.column_name_real.toLowerCase() == ip_value.toLowerCase() && is_dataset_connected == 1)
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
                
                if(call_from_gbl == 'report_manager_dhx' && ip_value.indexOf('(CC)') == -1) {
                    
                    var col_alias = ds_col_info_gbl_pivot.filter(function(e) {
                        
                        if(
                            (e.column_name_real.split('.')[1].toLowerCase() == ip_value.split('.')[1].toLowerCase() && is_dataset_connected == 0)
                            || (e.column_name_real.toLowerCase() == ip_value.toLowerCase() && is_dataset_connected == 1)
                            ) 
                        {
                            return true;
                        } else return false;
                        
                    });
                    //console.log(col_alias);
                    return_val = col_alias[0].alias;
                }
                
                return return_val;
            }

            /**
             * [format_val Format value on pivot report]
             * @param  {[type]} id    [Field Id]
             * @param  {[type]} value [Value]
             */
            format_val = function(id, value, name) {
            	return fx_get_formatted_value (id, name, value);
            }

            /**
             * [get_label Get custom label for fields]
             * @param  {[type]} id [Field Id]
             */
            get_label = function(id, name) {
            	var label = '';
            	if (call_from_gbl !== 'report_manager_dhx' && typeof id !== 'undefined' && id != '') {
            		var is_dashboard = '<?php echo $is_dashboard;?>';

            		if (is_dashboard == 'y')
            			label = viewPivotDashboard.get_label(id, name);
            		else 
            			label = viewPivotReport.get_label(id, name);
            	}

            	return label;
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
                		expand_counter++;
                    }
            	}
            }

            get_report_name = function() {
            	var is_dashboard = '<?php echo $is_dashboard;?>';
            	var is_pin = '<?php echo $is_pin;?>';
            	
            	if (is_pin == 'y') if (viewPivotReport.adv_form) return viewPivotReport.adv_form.getItemValue('report_name');             	
            	if (is_dashboard == 'y') if (viewPivotDashboard.adv_form) return viewPivotDashboard.adv_form.getItemValue('report_name'); 
            	 	            
	            return '';
            }

            get_xaxis_label = function() {
            	var is_dashboard = '<?php echo $is_dashboard;?>';
            	var is_pin = '<?php echo $is_pin;?>';

            	if (is_pin == 'y') if (viewPivotReport.adv_form) return viewPivotReport.adv_form.getItemValue('xaxis_label');	            
				if (is_dashboard == 'y') if (viewPivotDashboard.adv_form) return viewPivotDashboard.adv_form.getItemValue('xaxis_label');

            	return '';
            }

            get_yaxis_label = function() {
            	var is_dashboard = '<?php echo $is_dashboard;?>';
            	var is_pin = '<?php echo $is_pin;?>';

            	if (is_pin == 'y') if (viewPivotReport.adv_form) return viewPivotReport.adv_form.getItemValue('yaxis_label');	            
	            if (is_dashboard == 'y') if (viewPivotDashboard.adv_form) return viewPivotDashboard.adv_form.getItemValue('yaxis_label');
            	return '';
            }

        </script>
        <div id="output" style="margin: 30px;"></div>
    </body>
</html>