<style type="text/css">
    html, body {
        width: 100%;
        height: 100%;
        margin: 0px;
        overflow: hidden;
    }
</style>
<?php
    include '../../../adiha.php.scripts/components/include.file.v3.php';
    $form_name = 'form_source_group';
    
    $grid_name = get_sanitized_value($_GET['grid_name']);
    $grid_label = get_sanitized_value($_GET['grid_label']);
    $form_name = get_sanitized_value($_GET['form_name']);
    $browse_name = get_sanitized_value($_GET['browse_name']);
    $callback_function = get_sanitized_value($_GET['callback_function'] ?? '');
    $id = $_GET['id'];
    $function_id = $_GET['function_id'];
    
    $rights_source_group = 12101712;
    $rights_source_group_iu = 12101713;

    list(
        $has_rights_source_group,
        $has_rights_source_group_iu
    ) = build_security_rights(
        $rights_source_group,
        $rights_source_group_iu
    );
    
    $has_rights_source_group_iu = ($has_rights_source_group_iu != '') ? "true" : "false";

    $layout_json = '[
                        {
                            id:             "a",
                            text:           "Source Group",
                            width:          720,
                            header:         false,
                            collapse:       false,
                            fix_size:       [false,null]
                        }
                    ]';
    
    $name_space = 'ns_source_group';
    $source_group_layout = new AdihaLayout();
    echo $source_group_layout->init_layout('source_group_layout', '', '1C', $layout_json, $name_space);
    
   
    $menu_name = 'source_group_menu';
    $menu_json = "[
            {id:'ok', text:'Ok', img:'tick.gif', imgdis:'tick_dis.png', disabled: 'true'},
            {id:'save', text:'Save', img:'save.gif', imgdis:'save_dis.gif', enabled: '$has_rights_source_group_iu'},
            {id:'t', text:'Edit', img:'edit.gif', imgdis:'edit_dis.gif', items:[
                {id:'add', text:'Add', img:'add.gif', imgdis:'add_dis.gif', enabled:'$has_rights_source_group_iu'},
                {id:'delete', text:'Delete', img:'delete.gif', imgdis:'trash_dis.gif', enabled:'false'}
            ]},
            {id:'t2', text:'Export', img:'export.gif', items:[
                {id:'excel', text:'Excel', img:'excel.gif', imgdis:'excel_dis.gif', title: 'Excel'},
                {id:'pdf', text:'PDF', img:'pdf.gif', imgdis:'pdf_dis.gif', title: 'PDF'}
            ]},
            {id:'select_unselect', text:'Select/Unselect All', img:'select_unselect.gif', imgdis:'select_unselect_dis.gif', enabled: 1}
        ]";

    $source_group_toolbar = new AdihaMenu();
    echo $source_group_layout->attach_menu_cell($menu_name, "a"); 
    echo $source_group_toolbar->init_by_attach($menu_name, $name_space);
    echo $source_group_toolbar->load_menu($menu_json);
    echo $source_group_toolbar->attach_event('', 'onClick', 'on_toolbar_click');
    
    $grid_name = 'source_group';
    echo $source_group_layout->attach_grid_cell($grid_name, 'a');
    $grid_source_group = new GridTable($grid_name);
    echo $grid_source_group->init_grid_table($grid_name, $name_space);
    echo $grid_source_group->set_search_filter(true); 
    echo $grid_source_group->return_init();
    echo $grid_source_group->load_grid_data('', '', '', 'source_group_grid_select');
    echo $grid_source_group->attach_event('', 'onRowSelect', 'source_group_click');
    echo $grid_source_group->load_grid_functions();

    echo $source_group_layout->close_layout();       
        
?>

<script type="text/javascript">
    var delete_flag = '';
    var has_rights_source_group = Boolean('<?php echo $has_rights_source_group; ?>');
    var has_rights_source_group_iu = <?php echo $has_rights_source_group_iu; ?>;

    function source_group_click() {
        ns_source_group.source_group_menu.setItemEnabled('ok');

        if (has_rights_source_group_iu)
            ns_source_group.source_group_menu.setItemEnabled('delete');
    }

    function on_toolbar_click(args) {
        switch(args) {
            case 'add':
                var new_id = (new Date()).valueOf();
                ns_source_group.source_group.addRow(new_id, '');
            break;
            case 'save':
                var grid_xml = '<Root>';  

                ns_source_group.source_group.forEachRow(function(id) {
                    grid_xml = grid_xml + "<PSRecordset ";   

                    ns_source_group.source_group.forEachCell(id,function(cellObj,ind) {
                        var column_id = ns_source_group.source_group.getColumnId(ind);
                        var cell_values = ns_source_group.source_group.cells(id, ind).getValue();

                        if (column_id == 'generator_type')
                            cell_values = 'r';

                        grid_xml = grid_xml + " " + column_id + '="' + cell_values + '"';       
                    }); 

                    grid_xml = grid_xml + " ></PSRecordset> ";                  
                });

                grid_xml += "</Root>";

                data = { "action": "spa_rec_generator_name", 
                        "flag": "i",
                        "grid_xml": grid_xml
                };


            if (delete_flag == 1) {
                var del_msg =  "Some data has been deleted from the grid. Are you sure you want to save?";
                
                dhtmlx.message({
                    type: "confirm-warning",
                    text: del_msg,
                    title: "Warning",
                    callback: function(result) {                         
                        if (result) {
                            delete_flag = 0;
                            var return_json = adiha_post_data('alert', data, '', '', 'save_call_back');
                        }                           
                    } 
                }); 
            } else {
                var return_json = adiha_post_data('alert', data, '', '', 'save_call_back');
            }
                
            break;
            case 'delete':
                var selected_row = ns_source_group.source_group.getSelectedRowId();
                var selected_row_arr = selected_row.split(',');
                
                for (cnt = 0; cnt < selected_row_arr.length; cnt++) {
                    var id = ns_source_group.source_group.cells(selected_row_arr[cnt], 0).getValue();
                    ns_source_group.source_group.deleteRow(selected_row_arr[cnt]);
                    
                    delete_flag = 1;
                }
            break;
            case 'ok':
                var selected_row = ns_source_group.source_group.getSelectedRowId();
                
                if (ns_source_group.source_group.getSelectedRowId() != null) {
                    var selected_row = ns_source_group.source_group.getSelectedRowId();
                    var selected_row_array_d = selected_row.split(',');
                    var generator_group_id;
                    var generator_group_name;

                    for(var i = 0; i < selected_row_array_d.length; i++) {
                
                        if (i == 0) {
                            generator_group_id = ns_source_group.source_group.cells(selected_row_array_d[i], 0).getValue();
                            generator_group_name = ns_source_group.source_group.cells(selected_row_array_d[i], 1).getValue();
                        } else {
                            generator_group_id = generator_group_id + ',' + ns_source_group.source_group.cells(selected_row_array_d[i], 0).getValue();
                            generator_group_name = generator_group_name + ' || ' + ns_source_group.source_group.cells(selected_row_array_d[i], 1).getValue();
                        }
                    }
                } else {
                    generator_group_id = '';
                    generator_group_name = '';
                }
                
                parent.set_source_group_text_value(generator_group_id, generator_group_name);                
                parent.new_browse.close();
            break;
            case 'select_unselect':
            	var select_rows = ns_source_group.source_group.getSelectedRowId();

                if (select_rows == null) {
                    ns_source_group.source_group.selectAll();                    
                    ns_source_group.source_group_menu.setItemEnabled('delete');
                } else {
                    ns_source_group.source_group.clearSelection();
                    ns_source_group.source_group_menu.setItemDisabled('delete');
                }
            break;
            case 'excel':
                path = js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php';
                ns_source_group.source_group.toExcel(path);
                
                break;
            case 'pdf':
                path = js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php';
                ns_source_group.source_group.toPDF(path);
                
                break;
        }
    }

    function save_call_back(result) {
        if (result[0].status == 'Success')
            ns_source_group.refresh_grid();
    }
    
    function source_group_grid_select() {
        var form_name = '<?php echo $form_name; ?>';
        var browse = '<?php echo $browse_name; ?>';
        
        eval('var my_form = parent.' + form_name + '.getForm();');

        var browse_field = browse.replace("label_", "");
		var label_name = my_form.getItemValue(browse);
        var selected_id = my_form.getItemValue(browse_field);
        var grid_obj = ns_source_group.source_group_layout.cells('a').getAttachedObject();

        grid_obj.forEachRow(function(id){
			var a = grid_obj.cells(id, 0).getValue();
			var b = grid_obj.cells(id, 1).getValue();
            if (selected_id.indexOf(a) > -1){
                grid_obj.selectRow(id, true, true, true);
            }
        });
    }
</script>