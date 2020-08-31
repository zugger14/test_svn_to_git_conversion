<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
        <?php require('../../../adiha.php.scripts/components/include.file.v3.php');?>
    </head>
    <body>
    <?php
    $form_name = 'form_add_curve';
    $name_space = 'add_curve';
    $parameter_id = get_sanitized_value($_GET['parameter_id'] ?? '');
    $is_pop = get_sanitized_value($_GET['is_pop'] ?? '');
    
    
    $layout_json = '[
                        {
                            id:             "a",
                            text:           "Curve",
                            width:          720,
                            header:         false,
                            collapse:       false,
                            fix_size:       [false,null]
                        }
                    ]';

    $layout_obj = new AdihaLayout();
    echo $layout_obj->init_layout('add_curve_layout', '', '1C', $layout_json, $name_space);
    
    $toolbar_curve = 'add_curve_toolbar';
    $deal_toolbar_json = '[
                            {id:"save", type:"button", img:"save.gif", imgdis:"save_dis.gif", text:"Save", title:"Save", disabled: "false"}
                          ]';
    echo $layout_obj->attach_toolbar_cell($toolbar_curve, 'a');
    $toolbar_obj = new AdihaToolbar();
    echo $toolbar_obj->init_by_attach($toolbar_curve, $name_space);
    echo $toolbar_obj->load_toolbar($deal_toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', 'toolbar_button_click');
    
    $grid_name='grid_curve_def';
    $tbl_grd_name = 'grid_source_price_curve_def';
    $load_grid_sql = "EXEC spa_monte_carlo_model @flag='y'";
    
    echo $layout_obj->attach_grid_cell($grid_name, 'a');
    echo $layout_obj->attach_status_bar("a", true);
    
    $grid_table_obj = new GridTable($tbl_grd_name);
    echo $grid_table_obj->init_grid_table($grid_name, $name_space);
    echo $grid_table_obj->set_search_filter(false,'#text_filter,#text_filter,#text_filter,#text_filter,#text_filter');
    echo $grid_table_obj->enable_multi_select(); 
    echo $grid_table_obj->return_init();    
    echo $grid_table_obj->load_grid_data($load_grid_sql); 
    echo $grid_table_obj->enable_paging(25, 'pagingArea_a', true);
    echo $grid_table_obj->attach_event('', 'onRowSelect', 'curve_grid_row_select');
    echo $grid_table_obj->load_grid_functions();
    
    echo $layout_obj->close_layout();       
?>
</body>
<script type="text/javascript">
    var parameter_id = '<?php echo $parameter_id;?>';
    dhxWins = new dhtmlXWindows();
    /**
     *
     */
    function toolbar_button_click(id) {
        var selected_row_id = add_curve.grid_curve_def.getSelectedRowId();
        var selected_row_array = selected_row_id.split(',');
        var curve_ids = '';
            
        for(var i = 0; i < selected_row_array.length; i++) {
           if (i == 0) {
                curve_ids = add_curve.grid_curve_def.cells(selected_row_array[i], 0).getValue();
            } else {
                curve_ids = curve_ids + ',' + add_curve.grid_curve_def.cells(selected_row_array[i], 0).getValue();
            }
        }
        data = {"action": "spa_risk_factor_model",
                "flag": "g",
                "curve_ids": curve_ids,
                "monte_carlo_model_parameter_id": parameter_id
            };
        adiha_post_data('alert', data, '', '', 'parent.risk_factor.curve_grid_refresh');
    }
    /**
     *
     */
    function curve_grid_row_select(){
        if (add_curve.grid_curve_def.getSelectedRowId()) {
            add_curve.add_curve_toolbar.enableItem('save');
        } else {
            add_curve.add_curve_toolbar.disableItem('save');
        }
    }
</script>