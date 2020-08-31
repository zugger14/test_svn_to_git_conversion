<?php
/**
* Browse table columns screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
        <?php require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
        <?php 
        $layout_json = '[
							{
								id:             "a",
								text:           "Column Browse",
								header:         true,
								collapse:       false,
								width:          300,
								fix_size:       [true,null]
							}
						]';
		$toolbar_json = '[
                            {id:"ok", type:"button", img:"tick.png", imgdis: "tick_dis.gif", text:"Ok", title:"Ok", disabled: true}
                        ]';
        $id = get_sanitized_value($_POST['id'] ?? '');
        $type = get_sanitized_value($_POST['type'] ?? '');
        $row_id = get_sanitized_value($_POST['row_id'] ?? '');
        $col_id = get_sanitized_value($_POST['col_id'] ?? '');
        $selected_column_value = get_sanitized_value($_POST['selected_column_value'] ?? '');
        $sql = "EXEC spa_test_regression_rule @flag='l', @object_name ='$id', @type='$type'";
        $namespace = 'browse_columns';
        $layout_name = 'browse_columns_layout';
    	$browse_columns_layout_obj = new AdihaLayout();
    	echo $browse_columns_layout_obj->init_layout($layout_name, '', '1C', $layout_json, $namespace);
    	//echo $browse_columns_layout_obj->set_text('a', $grid_label);
    	$toolbar_name = 'browse_columns_toolbar';
    	echo $browse_columns_layout_obj->attach_toolbar_cell($toolbar_name, 'a');
    	$browse_columns_toolbar_obj = new AdihaToolbar();
    	echo $browse_columns_toolbar_obj->init_by_attach($toolbar_name, $namespace);
    	echo $browse_columns_toolbar_obj->load_toolbar($toolbar_json);
    	echo $browse_columns_toolbar_obj->attach_event('', 'onClick', 'browse_columns_grid_click');
    	echo $browse_columns_layout_obj->attach_status_bar("a", true);
    	$grid_name = 'table_column_browser';
        echo $browse_columns_layout_obj->attach_grid_cell($grid_name, 'a');
        $browse_grid = new GridTable($grid_name);
        echo $browse_grid->init_grid_table($grid_name, $namespace);
        echo $browse_grid->set_search_filter(true);
        echo $browse_grid->return_init();
        echo $browse_grid->load_grid_data($sql, '', '', 'browse_columns.after_gridload','');
        echo $browse_grid->attach_event('', 'onSelectStateChanged', 'browse_columns.grid_row_on_click');
        echo $browse_grid->attach_event('', 'onBeforeSelect', 'browse_columns.grid_before_select');
        echo $browse_grid->enable_multi_select();
    	echo $browse_columns_layout_obj->close_layout();
        
        ?>
    </head>
   
    <body>
    </body>
</html>
<script type="text/javascript">
	/**
	 * [Set Ok button disabled/enabled onCheck book structure nodes]
	 */
	browse_columns.grid_row_on_click =function(){
	    var obj = browse_columns.browse_columns_layout.cells('a').getAttachedObject();
	    var selected_row = obj.getSelectedRowId();
	    
	    if (selected_row != null) {
	        browse_columns.browse_columns_toolbar.enableItem('ok');
	    } else {
	        browse_columns.browse_columns_toolbar.disableItem('ok');
	    }
	}
	
	browse_columns.grid_before_select = function(new_row, old_row, new_col_index) {
	    var obj = browse_columns.browse_columns_layout.cells('a').getAttachedObject();
	    
	    var status_index = obj.getColIndexById("status");
	    if (status_index != undefined) {
	        var status = obj.cells(new_row, status_index).getValue();
	        if (status.toLowerCase() == 'disable')
	            return false;
	        else
	            return true;
	    } else {
	        return true;
	    }
	}


	function browse_columns_grid_click() {
	    var obj = browse_columns.browse_columns_layout.cells('a').getAttachedObject();
	    var selected_row_values = obj.getSelectedRowId();
	    if(selected_row_values) {
	    	selected_row_values = selected_row_values.split(',');
	    }
	    var val = [];
	    for(var i=0; i<selected_row_values.length; i++) {
	    	val.push(obj.cells(selected_row_values[i],0).getValue());
	    }
	    // console.log(val);  
	    parent.setup_regression_testing_configuration.set_cell_data(val,'<?php echo $row_id;?>', '<?php echo $col_id;?>');
	    parent.new_browse.close();
	       
	}


	browse_columns.after_gridload = function(){
		var selected_column_value = '<?php echo  $selected_column_value; ?>';
		if(selected_column_value) {
			selected_id = selected_column_value.split(",");
			var grid_obj = browse_columns.browse_columns_layout.cells('a').getAttachedObject();
			 grid_obj.forEachRow(function(id){
				var column_id = grid_obj.cells(id, 0).getValue();
                if (selected_id.indexOf(column_id) > -1){
                    grid_obj.selectRow(id, true, true, true);
                }
            });

		}
		
	}
</script>