<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
        <?php require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
    </head>
<body>
<?php
	$name_space = 'ns_meter_id_browse';
    $form_name = 'form_meter_id_browse';
    $row_id = get_sanitized_value($_GET['row_id'] ?? '');

    $layout_json = '[   
                        {id: "a", text: "", header: "false"},
                        
                    ]';
    $meter_id_browse_layout = new AdihaLayout();


    echo $meter_id_browse_layout->init_layout('meter_id_browse_layout', '', '1C', $layout_json, $name_space);

	$menu_name = 'meter_id_browse_menu';
    $menu_json = '[{id:"ok", text:"Ok", img:"tick.gif", imgdis: "tick_dis.png", enabled:"false"}]';

    $meter_id_browse_toolbar = new AdihaMenu();
    echo $meter_id_browse_layout->attach_menu_cell($menu_name, "a"); 
    echo $meter_id_browse_toolbar->init_by_attach($menu_name, $name_space);
    echo $meter_id_browse_toolbar->load_menu($menu_json);
    echo $meter_id_browse_toolbar->attach_event('', 'onClick', 'meter_id_browse_menu_click');
    
    //grid definition
    $grid_name = 'grd_meter_id';
    echo $meter_id_browse_layout->attach_grid_cell($grid_name, 'a');
    $meter_id_browse_grid = new AdihaGrid();
    echo $meter_id_browse_layout->attach_status_bar("a", true);
    echo $meter_id_browse_grid->init_by_attach($grid_name, $name_space);
    echo $meter_id_browse_grid->set_header("Meter ID,Recorder ID, Status");
    echo $meter_id_browse_grid->set_columns_ids("meter_id,recorderid,status");
    echo $meter_id_browse_grid->set_widths("100,550,100");
    echo $meter_id_browse_grid->set_column_types("ro,ro,ro");
    echo $meter_id_browse_grid->set_column_visibility('false,false,true');
    echo $meter_id_browse_grid->set_sorting_preference('int,str,str');
    echo $meter_id_browse_grid->load_grid_data("EXEC spa_getAllMeter @flag='s'");
    echo $meter_id_browse_grid->attach_event('', 'onRowSelect', 'grd_meter_id_click');
    echo $meter_id_browse_grid->set_search_filter(true);
    echo $meter_id_browse_grid->return_init();
    echo $meter_id_browse_grid->enable_header_menu();
    echo $meter_id_browse_grid->attach_event('', 'onBeforeSelect', 'grid_before_select');

    echo $meter_id_browse_layout->close_layout();
?>
<script type="text/javascript">
    var row_id = '<?php echo $row_id; ?>'; 

	function grd_meter_id_click() {
		ns_meter_id_browse.meter_id_browse_menu.setItemEnabled('ok');
	}
    
    function grid_before_select(new_row, old_row, new_col_index) {
        var obj = ns_meter_id_browse.meter_id_browse_layout.cells('a').getAttachedObject();
        
        var status_index = obj.getColIndexById("status");
        if (status_index != undefined) {
            var status = obj.cells(new_row, status_index).getValue();
            if ((status).toLowerCase() == 'disable')
                return false;
            else
                return true;
        } else {
            return true;
        }
    }
    
	function meter_id_browse_menu_click(args) {
		if (args == 'ok') {
			var row_id_sel =  ns_meter_id_browse.grd_meter_id.getSelectedRowId();
    		var meter_id = ns_meter_id_browse.grd_meter_id.cells(row_id_sel, 0).getValue();
    		var recorder_id = ns_meter_id_browse.grd_meter_id.cells(row_id_sel, 1).getValue();

    		parent.set_meter_grid_columns(meter_id, recorder_id, row_id);
    		parent.win_meter_id.close();
		}
	}
</script>