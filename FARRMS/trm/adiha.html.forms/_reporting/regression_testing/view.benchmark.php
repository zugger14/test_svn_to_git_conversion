<?php
/**
* View benchmark screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
        <?php require '../../../adiha.php.scripts/components/include.file.v3.php'; ?>
    </head>
    <body>
    	<?php
			$namespace = 'view_benchmark';
			
			$regression_rule_id = get_sanitized_value($_POST['regression_rule_id'] ?? null);
			$filters = get_sanitized_value($_POST['filter'] ?? null);
            
    		$grid_tab_sql = "EXEC spa_regression_testing @flag = 'x', @regression_rule_id = " . $regression_rule_id;
			$grid_tab_array = readXMLURL2($grid_tab_sql);

    		$json = '[{id: "a", text: "View Benchmark", header: true}]';

		    $view_benchmark_layout_obj = new AdihaLayout();
		    echo $view_benchmark_layout_obj->init_layout('view_benchmark_layout', '', '1C', $json, $namespace);
    		echo $view_benchmark_layout_obj->close_layout();
    	?>

    	<script>
    		var grid_tab_json = JSON.parse('<?php echo json_encode($grid_tab_array) ?>');
			var filter = '<?php echo $filters ?>';

			function get_tabs_json(tab_table_name, index) {
				return {
					"id": tab_table_name['table_name'], 
					"text": uderscoresToSpacedTitleCase(tab_table_name['table_name']),
					"active": index === 0 // Set first tab active
				}
			}

			function uderscoresToSpacedTitleCase(string) {
				if (string.indexOf('_') != -1) {
					return string.split('_').map(function (word) {
						return word[0].toUpperCase() + word.substr(1).toLowerCase();
					}).join(' ');
				} else {
					return string;
				}
            }

    		$(function() {
    			view_benchmark.tabbar = view_benchmark.view_benchmark_layout.cells("a").attachTabbar({
    				"tabs": grid_tab_json.map(get_tabs_json)
    			});

    			view_benchmark.tabbar.getAllTabs().forEach(function(tab_table_name, index){
					var get_filter = 'Filters: <i>' + filter + '</i>';
    				var layout_json = {
						"pattern": "1C", 
						"cells": [
							{
								"id": "a",
								"collapse": false, 
								"header": true, 
								"text": get_filter
							}
	    				]
	    			};

	    			view_benchmark["inner_layout_" + tab_table_name] = view_benchmark.tabbar.tabs(tab_table_name).attachLayout(layout_json);

	    			var column_ids = columns = grid_tab_json[index]["columns"];
					column_ids = column_ids.replace(/\_/g, ' ')

                    var num_col = column_ids.split(',').length;
                    var col_type = [];
                    var col_width = [];
					var col_filter = [];
					var col_sort = [];

                    for(var i=0; i<num_col; i++) {
						col_sort.push('str')
                        col_type.push('ro');
                        col_width.push('150');
						col_filter.push('#connector_text_filter');
                    }
                    
					var column_headers = grid_tab_json[index]["display_columns"];
					column_headers = column_headers.replace(/\_/g, ' ')
					
	    			// var column_types = column_ids.replace(/[a-zA-Z0-9_]+/g, "ro");
	    			// var column_widths = column_ids.replace(/[a-zA-Z0-9_]+/g, "150");
                    var column_types = col_type.join(',');
                    var column_widths = col_width.join(',');
					col_filter = col_filter.join(',');
					col_sort = col_sort.join(',');

	    			view_benchmark["inner_layout_" + tab_table_name].cells('a').attachStatusBar({
	    			    "height": 30,
	    			    "text": '<div id="pagingAreaGrid_a_' + tab_table_name + '"></div>'
	    			});

	    			view_benchmark["grid_" + tab_table_name] = view_benchmark["inner_layout_" + tab_table_name].cells('a').attachGrid();
    				view_benchmark["grid_" + tab_table_name].setColumnIds(column_ids);
    				view_benchmark["grid_" + tab_table_name].setHeader(column_headers);
					view_benchmark["grid_" + tab_table_name].attachHeader(col_filter);
					view_benchmark["grid_" + tab_table_name].setColSorting(col_sort);
    				view_benchmark["grid_" + tab_table_name].setColTypes(column_types);
	    			view_benchmark["grid_" + tab_table_name].setImagesPath(js_image_path + '/dhxtoolbar_web/');
    				view_benchmark["grid_" + tab_table_name].setInitWidths(column_widths);

    				view_benchmark["grid_" + tab_table_name].init();
					view_benchmark["grid_" + tab_table_name].enableHeaderMenu();
    				view_benchmark["grid_" + tab_table_name].setPagingWTMode(true, true, true);
    				view_benchmark["grid_" + tab_table_name].enablePaging(true, 100, 0, 'pagingAreaGrid_a_' + tab_table_name);
    				view_benchmark["grid_" + tab_table_name].setPagingSkin('toolbar');

    				var param = {
    				    "action": "spa_regression_testing",
    				    "flag": "y",
    				    "col_names":columns,
    				    "table_name": tab_table_name,
                        "regression_rule_id": <?php echo $regression_rule_id ?>
    				};
                    adiha_post_data('return_json', param, '', '', 'view_benchmark.refresh_benchmark_grid', false);
    			});
    		});

            view_benchmark.refresh_benchmark_grid = function(result) {
                var data = JSON.parse(result);
                var process_table = data[0].process_table;
                var header_list = data[0].col_headers;
                var table_name = data[0].table_name;
                var benchmark_table_present = data[0].benchmark_table;
                if(benchmark_table_present == 'y') {
                    header_list = header_list.replace(/\[/g, "").replace(/]/g,"");

                    var benchmark_grid = view_benchmark["grid_" + table_name];

                    var sql_param = {
                        "process_table":process_table,
                        "text_field": header_list
                    };
                    sql_param = $.param(sql_param);
                    var sql_url = js_php_path + "grid.connector.php?"+ sql_param;

                    benchmark_grid.clearAll();
                    benchmark_grid.loadXML(sql_url);
                }
            }
    	</script>
    </body>
</html>	