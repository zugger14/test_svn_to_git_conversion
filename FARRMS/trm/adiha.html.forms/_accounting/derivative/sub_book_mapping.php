<!--DOCTYPE transitional.dtd-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
    <?php
    include '../../../adiha.php.scripts/components/include.file.v3.php';
    $php_script_loc = $app_php_script_loc;
    $form_name = 'form_sub_book_mapping';
    
    $rights_existing_formulas = 10211018;   // 419 
    $subsidiary_id = get_sanitized_value($_GET['subsidiary_id'] ?? 'NULL');
    //$hedge_or_item = (isset($_GET['hedge_or_item'])) ? $_GET['hedge_or_item'] : 'NULL';
    $callback_function = get_sanitized_value($_GET['callback_function'] ?? '');
    
    //JSON for Layout
    $layout_json = '[
                        {
                            id:             "a",
                            text:           "Sub Book Mapping",
                            header:         true,
                            width:          400,
                            height:         120,
                            collapse:       false,
                            fix_size:       [false,null]
                        },
                        {
                            id:             "b",
                            text:           "Formula",
                            header:         false,
                            collapse:       false,
                            fix_size:       [false,null]
                        }
                    ]';
    
    $namespace = 'ns_sub_book_mapping';
    //Creating Layout
    $layout_obj = new AdihaLayout();
    echo $layout_obj->init_layout('layout', '', '2E', $layout_json, $namespace);
    
    //menu
    $menu_obj = new AdihaMenu();
    $menu_json = '[{id:"ok", text:"Ok", img:"tick.png", img_dis:"tick_dis.png", title:"Ok", enabled:0}]';
    echo $layout_obj->attach_menu_cell('menu', 'a');
    echo $menu_obj->init_by_attach('menu', $namespace);
    echo $menu_obj->load_menu($menu_json);
    echo $menu_obj->attach_event('', 'onClick', 'btn_ok_click');
    
    //form
    $form_obj = new AdihaForm();
    
    $sp_subsidiary = "EXEC spa_maintain_portfolio_hierarchy @flag='l', @level=2";
    $subsidiary_dropdown = $form_obj->adiha_form_dropdown($sp_subsidiary, 0, 1);                
    $form_json = '[{"type":"settings","position":"label-top"},
                    {"type":"combo","name":"subsidiary_id","label":"Subsidiary","value":' . $subsidiary_id . ',"tooltip":"subsidiary","hidden":"false","disabled":"true","offsetLeft":"10","labelWidth":260,"inputWidth":240,"options":' . $subsidiary_dropdown . '}]';
    $form_name = 'form_sub_book_mapping';
    echo $layout_obj->attach_form($form_name, 'a');
    echo $form_obj->init_by_attach($form_name, $namespace);
    echo $form_obj->load_form($form_json);
    
    //attach grid 
    
    $sp_load_grid = "EXEC spa_GetAllSourceBookMapping_hedge_item @flag = 'p', @sub_id = " . $subsidiary_id;
    //. ", @hedge_item_flag = '" . $hedge_or_item . "'";  

    $grid_name='grd_sub_book_mapping';
    $grid_obj = new GridTable();
    echo $layout_obj->attach_grid_cell($grid_name, 'b');
    echo $grid_obj->init_by_attach($grid_name, $namespace);
    echo $grid_obj->set_header('ID,Sub Book Mapping');
    echo $grid_obj->set_widths('50,470');
    echo $grid_obj->set_column_types('ro,ro');
    echo $grid_obj->set_sorting_preference('str,str');     
    echo $grid_obj->set_columns_ids('ID,SBM');
    echo $grid_obj->set_search_filter(true); 
    echo $grid_obj->return_init('false,false');
    echo $grid_obj->load_grid_data($sp_load_grid);
    echo $grid_obj->attach_event('', 'onRowDblClicked', 'btn_ok_click');
    echo $grid_obj->attach_event('', 'onRowSelect', 'enable_btn');
    echo $grid_obj->load_grid_functions();
    
    //Closing Layout
    echo $layout_obj->close_layout();
    
    ?>
    <script type="text/javascript"> 
        
        $(function() {
            ns_sub_book_mapping.form_sub_book_mapping.setItemValue('subsidiary_id', '<?php echo $subsidiary_id; ?>');
            
        });
        
        function enable_btn() {
            ns_sub_book_mapping.menu.setItemEnabled('ok');
        }
        
        function btn_ok_click() { 
            var id = ns_sub_book_mapping.get_grid_cell_value(0);
            var name = ns_sub_book_mapping.get_grid_cell_value(1);

            var return_value = new Array();
            
            return_value[0] = id;
            return_value[1] = 'btnOk';
            return_value[2] = name;
            
            var callback_function = '<?php echo $callback_function; ?>';
//        
            if(Boolean(callback_function)) {
                eval('parent.' + callback_function + '(return_value)');
            }
            parent.browse_window.window('w1').close();
        }
    </script>
 </html>   