<!--DOCTYPE transitional.dtd-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
    <?php
    include '../../../adiha.php.scripts/components/include.file.v3.php';
    $php_script_loc = $app_php_script_loc;
    $call_from = get_sanitized_value($_GET['call_from']);

    //JSON for Layout
    $layout_json = '[
                        {
                            id:             "a",
                            text:           "Formula",
                            width:          720,
                            header:         true,
                            collapse:       false,
                            fix_size:       [false,null]
                        }
                    ]';
    
    $name_space = 'formula_copy';
    //Creating Layout
    $formula_copy_layout = new AdihaLayout();
    echo $formula_copy_layout->init_layout('formula_copy_layout', '', '1C', $layout_json, $name_space);

	$toolbar_json = '[
                            {id:"ok", type:"button", img:"tick.png", text:"Ok", title:"Ok"}
                        ]';
						
	$toolbar_name = 'formula_copy_toolbar';
    echo $formula_copy_layout->attach_toolbar_cell($toolbar_name, 'a');
    $formula_existing_toolbar_obj = new AdihaToolbar();
    echo $formula_existing_toolbar_obj->init_by_attach($toolbar_name, $name_space);
    echo $formula_existing_toolbar_obj->load_toolbar($toolbar_json);
	echo $formula_existing_toolbar_obj->attach_event('', 'onClick', 'btn_ok_click');
	
    $grid_name='grd_formula_copy';
    echo $formula_copy_layout->attach_grid_cell($grid_name, 'a');
    $grid_formula_obj = new GridTable('formula_editor');
    echo $grid_formula_obj->init_grid_table($grid_name, $name_space);
    echo $grid_formula_obj->set_search_filter(true); 
    echo $grid_formula_obj->return_init();
    if ($call_from == 'copy_formula_template') {
        echo $grid_formula_obj->load_grid_data("EXEC spa_formula_editor @flag='c'", '');
    } else {
        echo $grid_formula_obj->load_grid_data("EXEC spa_formula_editor @flag='s',@formula_type='b'", '');
        
    }
    echo $grid_formula_obj->attach_event('', 'onRowDblClicked', 'btn_ok_click');
    echo $grid_formula_obj->load_grid_functions();
    
    //Closing Layout
    echo $formula_copy_layout->close_layout();
    
    ?>
    
    <style>
        html, body {
            width: 100%;
            height: 100%;
            margin: 0px;
            overflow: hidden;
        }
    </style>
    
    <script type="text/javascript"> 
        
        $(function() {
            var call_from = '<?php echo $call_from; ?>';
            if (call_from == 'copy_formula_template') {
                formula_copy.grd_formula_copy.setColLabel(formula_copy.grd_formula_copy.getColIndexById('formula_id'),"Formula String");
                formula_copy.grd_formula_copy.setColLabel(formula_copy.grd_formula_copy.getColIndexById('formula_name'),"Description");
                formula_copy.grd_formula_copy.setColLabel(formula_copy.grd_formula_copy.getColIndexById('formula_c'),"Contract/Template");
                formula_copy.grd_formula_copy.setColLabel(formula_copy.grd_formula_copy.getColIndexById('formula_type'),"Charge Type");
                formula_copy.grd_formula_copy.setColumnHidden(formula_copy.grd_formula_copy.getColIndexById('formula_c'),false);
                formula_copy.grd_formula_copy.setColumnHidden(formula_copy.grd_formula_copy.getColIndexById('formula_type'),false);
            } else {
                formula_copy.grd_formula_copy.setColumnHidden(formula_copy.grd_formula_copy.getColIndexById('formula_c'),true);
                formula_copy.grd_formula_copy.setColumnHidden(formula_copy.grd_formula_copy.getColIndexById('formula_type'),true);
            }
            formula_copy.grd_formula_copy.setColumnHidden(formula_copy.grd_formula_copy.getColIndexById('formula_id'),true);
            formula_copy.grd_formula_copy.setColWidth(formula_copy.grd_formula_copy.getColIndexById('formula'),"*");
            formula_copy.grd_formula_copy.setColumnMinWidth(150,formula_copy.grd_formula_copy.getColIndexById('formula'));
        });
        
        function btn_ok_click() { 
            var call_from = '<?php echo $call_from; ?>';
            if (call_from == 'copy_formula_template') {
                var formula_string = formula_copy.get_grid_cell_value(formula_copy.grd_formula_copy.getColIndexById('formula_id'));
            } else {
                var formula_string = formula_copy.get_grid_cell_value(formula_copy.grd_formula_copy.getColIndexById('formula_c'));
            }
            parent.append_copy_formula(formula_string);
            parent.copy_window.window('w1').hide();
        }
    </script>