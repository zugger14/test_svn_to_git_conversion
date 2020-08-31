<style type="text/css">
    html, body {
        width: 100%;
        height: 100%;
        margin: 0px;
        overflow: hidden;
    }
</style>
<?php
    include '../../adiha.php.scripts/components/include.file.v3.php';
    $form_name = 'form_commit_recs';
    
    $parent_form_name = get_sanitized_value($_GET['form_name']);

    $layout_json = '[
                        {
                            id:             "a",
                            text:           "Commit RECs",
                            width:          720,
                            header:         false,
                            collapse:       false,
                            fix_size:       [false,null]
                        }
                    ]';
    
    $name_space = 'ns_commit_recs';
    $commit_recs_layout = new AdihaLayout();
    echo $commit_recs_layout->init_layout('commit_recs_layout', '', '1C', $layout_json, $name_space);
    
   
    $menu_name = 'commit_recs_menu';
    $menu_json = "[
            {id:'ok', text:'Ok', img:'tick.gif', imgdis:'tick_dis.png', disabled: 'true'}, 
        ]";

    // $menu_json = "[
    //     {id:'ok', text:'Ok', img:'tick.gif', imgdis:'tick_dis.png', disabled: 'true'},
    //     {id:'select_unselect', text:'Select/Unselect All', img:'select_unselect.gif', imgdis:'select_unselect_dis.gif', enabled: 1}
    // ]";

    $commit_recs_toolbar = new AdihaMenu();
    echo $commit_recs_layout->attach_menu_cell($menu_name, "a"); 
    echo $commit_recs_toolbar->init_by_attach($menu_name, $name_space);
    echo $commit_recs_toolbar->load_menu($menu_json);
    echo $commit_recs_toolbar->attach_event('', 'onClick', 'on_toolbar_click');
    
    $grid_name = 'grd_commit_recs';
    echo $commit_recs_layout->attach_grid_cell($grid_name, 'a');
    $grid_commit_recs = new AdihaGrid();
    echo $commit_recs_layout->attach_status_bar("a", true);
    echo $grid_commit_recs->init_by_attach($grid_name, $name_space);
    echo $grid_commit_recs->set_header("Compliance Group ID,Logical Name,Assignment Type,Assigned State,Compliance Year,Commit Type,Assignment Type,Assigned State,Compliance Year,Commit Type");
    echo $grid_commit_recs->set_columns_ids("compliance_group_id,logical_name,assignment_type_name,assigned_state_name,compliance_year_name,commit_type_name,assignment_type,assigned_state,compliance_year,commit_type");
    echo $grid_commit_recs->set_widths("*,*,*,*,*,*,*,*,*,*");
    echo $grid_commit_recs->set_column_types("ro,ro,ro,ro,ro,ro,ro,ro,ro,ro");
    echo $grid_commit_recs->set_column_visibility("true,false,false,false,false,false,true,true,true,true");
    echo $grid_commit_recs->set_sorting_preference('str,str,str,str,str,str,str,str,str,str');
    echo $grid_commit_recs->load_grid_data("EXEC spa_compliance_group @flag = 'x'");    
    echo $grid_commit_recs->attach_event('', 'onRowSelect', 'grd_commit_recs_click');
    echo $grid_commit_recs->set_search_filter(true);
    echo $grid_commit_recs->return_init();
    //echo $grid_commit_recs->enable_multi_select();
    echo $grid_commit_recs->enable_header_menu();

    echo $commit_recs_layout->close_layout();       
        
?>

<script type="text/javascript">
	function grd_commit_recs_click() {
		ns_commit_recs.commit_recs_menu.setItemEnabled('ok');

	}

	function on_toolbar_click(args) {
		if (args == 'ok') {
			var row_id = ns_commit_recs.grd_commit_recs.getSelectedRowId(); 
			var compliance_group_id = ns_commit_recs.grd_commit_recs.cells(row_id, 0).getValue(); 
			parent.do_transaction(1, compliance_group_id);
			parent.new_commit_recs.close();
		} 
        // else if (args == 'select_unselect') { 
        //     var grid_obj = ns_commit_recs.grd_commit_recs;
        //     var selected_id = grid_obj.getSelectedRowId(); 
        //     if (selected_id == null) { 
        //             var ids = grid_obj.getAllRowIds();                    
        //             for (var id in ids) {
        //                grid_obj.selectRow(id, true, true, false); 
        //             }
                    
        //     } else {
        //         grid_obj.clearSelection();  
        //     }
        // }
	}
</script>