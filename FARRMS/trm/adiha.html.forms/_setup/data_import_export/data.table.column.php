<?php
/**
* Data table column screen
* @copyright Pioneer Solutions
*/
?>
<!--DOCTYPE transitional.dtd-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<meta http-equiv="X-UA-Compatible" content="IE=Edge">
    <html>
        <?php
        include '../../../adiha.php.scripts/components/include.file.v3.php';
        ?>
        <?php
        $process_id = get_sanitized_value($_GET['process_id'] ?? ''); 
        $tables_id = get_sanitized_value($_GET['tables_id'] ?? ''); 
        $dependent_tables_id = get_sanitized_value($_GET['dependent_tables_id'] ?? ''); 
        $repeat_flag = get_sanitized_value($_GET['repeat_flag'] ?? '0');        
        $import_export_flag = get_sanitized_value($_GET['import_export_flag'] ?? ''); 
        ?>
        <?php
        $php_script_loc = $app_php_script_loc;
        $app_user_loc = $app_user_name;
        /* start of main layout */
        $form_namespace = 'data_table_ixp';
        $layout = new AdihaLayout();
        //json for main layout.
        /* start */
        $json = '[
            {
                id:             "a",
                text:           "form",
                header:         false,
                collapse:       false,
                height:         10,
                fix_size:       [null,true] 
            }, 
            
            {
                id:             "b",
                text:           "Tables",
                header:         false,
                collapse:       false
                
            },
            {
                id:             "c",
                text:           "Dependent Tables",
                header:         false,
                collapse:       false                
            }
            
           
        ]';
        /* end */

        //attach main layout of the screen
        echo $layout->init_layout('new_layout', '', '3T', $json, $form_namespace);
        echo $layout->set_cell_height('a', 10);

        // //Button form
        // $button_form_name = 'button_form_name';
        // $form_json = '[
        //                 {type:"button", name:"ok", img:"tick.png", value:"OK"}
        //             ]';
        // echo $layout->attach_form($button_form_name, "a");
        // $filter_form_obj = new AdihaForm();
        // echo $filter_form_obj->init_by_attach($button_form_name, $form_namespace);
        // echo $filter_form_obj->load_form($form_json);

        $save_json = '[
                        {id:"ok", type:"button", img:"tick.png", text:"OK", title:"ok" , position:"absolute"}
                    ]';

        echo $layout->attach_toolbar_cell('toolbar_save', 'a');
        $toolbar_obj = new AdihaToolbar();
        echo $toolbar_obj->init_by_attach('toolbar_save', $form_namespace);
        echo $toolbar_obj->load_toolbar($save_json);
        echo $toolbar_obj->attach_event('', 'onClick', 'data_table_ixp.toolbar_click');

        //First grid
        $first_grid_name = 'first_table_grid';
        $first_grid_spa = "EXEC spa_ixp_export_tables @flag='p' ,@process_id='" . $process_id . "',@import_export_flag='" . $import_export_flag . "'";
        echo $layout->attach_grid_cell($first_grid_name, "b");
        $first_grid = new AdihaGrid();
        echo $first_grid->init_by_attach($first_grid_name, $form_namespace);
        echo $first_grid->set_header('id,Name,Tables');
        echo $first_grid->set_columns_ids('table_id,name,tables');
        echo $first_grid->set_column_types('ro,ro,ro');
        echo $first_grid->set_widths('0,0,420');
        echo $first_grid->set_search_filter(true);
        echo $first_grid->enable_multi_select();
        echo $first_grid->load_grid_data($first_grid_spa, $grid_type = 'g');
        echo $first_grid->attach_event('', 'onRowSelect', 'data_table_ixp.second_grid_refresh');
        
       
        echo $first_grid->return_init();
        //Second grid
        $second_grid_name = 'second_table_grid';
        if($repeat_flag=='d')
            $second_grid_spa="EXEC spa_ixp_export_tables @flag='q',@ixp_export_tables_id=".$tables_id.", @process_id='".$process_id."', @import_export_flag='".$import_export_flag."'";
        else {
            $second_grid_spa = "EXEC spa_ixp_export_tables @flag='q'";
        }
       
        echo $layout->attach_grid_cell($second_grid_name, "c");
        $second_grid = new AdihaGrid();
        echo $second_grid->init_by_attach($second_grid_name, $form_namespace);
        echo $second_grid->set_header('id,Name,Dependent Tables');
        echo $second_grid->set_columns_ids('table_id,name,tables');
        echo $second_grid->set_column_types('ro,ro,ro');
        echo $second_grid->set_widths('0,0,395');
        echo $second_grid->set_search_filter(true);
        echo $second_grid->load_grid_data($second_grid_spa, $grid_type = 'g');
        echo $second_grid->enable_multi_select();
        echo $second_grid->attach_event('', 'onXLE', 'data_table_ixp.check_repeat_flag_refresh');
        echo $second_grid->return_init();

        echo $layout->close_layout();
        /* end of main layout */
        ?>
        <script>
            var repeat_flag = '<?php echo $repeat_flag;?>';
            var tables_id = '<?php echo $tables_id;?>';
            /*
             * To check the repeat status and populate the grid accordingly.
             * @returns {undefined}
             */
            data_table_ixp.check_repeat_flag_refresh = function(){
                   if(repeat_flag=='d'){
                    data_table_ixp.first_table_grid.forEachRow(function(id){
                        first_grid_table_id=data_table_ixp.first_table_grid.cells(id, 0).getValue();
                        
                        if(tables_id==first_grid_table_id){
                            data_table_ixp.first_table_grid.selectRowById(id);
                            data_table_ixp.first_table_grid.filterBy(0,function(data){
                                // true - show the related row , false - hide the related row
                                return   (data==first_grid_table_id); 
                            });
                        }
                    });
                }
            } 

            data_table_ixp.toolbar_click = function(id) {

                table_selected_id = data_table_ixp.first_table_grid.getSelectedRowId();
                dep_table_selected_id = data_table_ixp.second_table_grid.getSelectedRowId();
                if (table_selected_id) {
                    var table_array = table_selected_id.split(',');
                    var ixp_export_tables_id = [];
                    //assigning selected table_id of the first grid in ixp_export_tables_id
                    if (table_array.length > 0) {
                        for (var i = 0; i < table_array.length; i++) {
//                                    if (ixp_export_tables_id != 0)
//                                        ixp_export_tables_id += ',';
                            table_array[i] = table_array[i].replace(/^\s*/, "").replace(/\s*$/, "");
                            ixp_export_tables_id[i]=[];
                            ixp_export_tables_id[i][0]= data_table_ixp.first_table_grid.cells(table_array[i], 0).getValue();
                            ixp_export_tables_id[i][1]= data_table_ixp.first_table_grid.cells(table_array[i], 2).getValue();
                        }
                    }
                }
                //return;
                if (dep_table_selected_id) {
                    var dependent_table_array = dep_table_selected_id.split(',');
                    var ixp_export_dep_tables_id = [];
                    //assigning selected dependent table_id of the second grid in ixp_export_dep_tables_id
                    if (dependent_table_array.length > 0) {
                        for (var i = 0; i < dependent_table_array.length; i++) {
//                                    if (ixp_export_dep_tables_id != 0)
//                                        ixp_export_dep_tables_id += ',';
                            dependent_table_array[i] = dependent_table_array[i].replace(/^\s*/, "").replace(/\s*$/, "");
                            ixp_export_dep_tables_id[i]=[];
                            ixp_export_dep_tables_id[i][0]= data_table_ixp.second_table_grid.cells(dependent_table_array[i], 0).getValue();
                            ixp_export_dep_tables_id[i][1]= data_table_ixp.second_table_grid.cells(dependent_table_array[i], 2).getValue();
                        }
                    }
                }
                if(ixp_export_tables_id){
                    if (ixp_export_tables_id.length<0)
                        ixp_export_tables_id = [];
                }
                else{
                    ixp_export_tables_id = [];
                }
                if(ixp_export_dep_tables_id){
                    if (ixp_export_dep_tables_id.length<0)
                        ixp_export_dep_tables_id = [];
                }
                else{
                    ixp_export_dep_tables_id = [];
                }
               
                parent.create_table_grid(ixp_export_tables_id, ixp_export_dep_tables_id,repeat_flag);
                parent.close_data_data_table_column_window();

            }
            /*
             *Function to refresh second_grid when the row of the first column is selected.
             *@param id: the selected rowId
             *@param ind: selected cell index of the selected row 
             */
            data_table_ixp.second_grid_refresh = function(id, ind) {
                var ixp_export_tables_id = data_table_ixp.first_table_grid.cells(id, 0).getValue();
                var param = {
                    "flag": "q",
                    "action": "spa_ixp_export_tables",
                    "ixp_export_tables_id": ixp_export_tables_id,
                    "process_id": "<?php echo $process_id; ?>",
                    "import_export_flag": "<?php echo $import_export_flag; ?>"
                };
                param = $.param(param);
                var param_url = js_data_collector_url + "&" + param;
                data_table_ixp.second_table_grid.clearAll();
                data_table_ixp.second_table_grid.loadXML(param_url);

            }
        </script>