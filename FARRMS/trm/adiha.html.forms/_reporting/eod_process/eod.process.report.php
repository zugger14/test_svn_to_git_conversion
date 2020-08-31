<!--DOCTYPE transitional.dtd-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<meta http-equiv="X-UA-Compatible" content="IE=Edge"> 
<html> 
    <?php 
    include '../../../adiha.php.scripts/components/include.file.v3.php';
    
    $master_process_id = get_sanitized_value($_GET['master_process_id']);
    $json = '[
                {
                    id:             "a",
                    text:           "EOD Report",
                    header:         false,
                    collapse:       false,
                    width:          390,
                    height:         170
                }
            ]';

    $namespace = 'eod_report';
    $edo_report_layout_obj = new AdihaLayout();
    echo $edo_report_layout_obj->init_layout('eod_report_layout', '', '1C', $json, $namespace);
	echo $edo_report_layout_obj->attach_status_bar("a", true);
	
	$menu_name = 'eod_report_menu';
    $menu_json = '	[
						{id:"t2", text:"Export", img:"export.gif", imgdis:"export_dis.gif", items:[
							{id:"excel", text:"Excel", img:"excel.gif"},
							{id:"pdf", text:"PDF", img:"pdf.gif"}
						]}
					]';

    echo $edo_report_layout_obj->attach_menu_layout_cell($menu_name, 'a', $menu_json, $namespace.'.menu_click');
	
	echo $edo_report_layout_obj->attach_grid_cell('eod_report_grid', 'a');
    $eod_report_grid_obj = new GridTable('eod_report_grid');
    echo $eod_report_grid_obj->init_grid_table('eod_report_grid', $namespace);
	echo $eod_report_grid_obj->set_search_filter(true, true);
	echo $eod_report_grid_obj->set_column_auto_size();
	echo $eod_report_grid_obj->split_grid(0);
	echo $eod_report_grid_obj->enable_paging(100, 'pagingArea_a', 'true');
	echo $eod_report_grid_obj->load_grid_data("EXEC spa_eod_process_status @flag='r', @master_process_id='" . $master_process_id ."'");
    echo $eod_report_grid_obj->return_init();
    echo $eod_report_grid_obj->load_grid_functions();
    
    echo $edo_report_layout_obj->close_layout();
    ?>
    
    <script type="text/javascript">  
		$(function() {
			eod_report.eod_report_grid.setColumnMinWidth(500,3);
			eod_report.eod_report_grid.setColWidth(3,"*");
		})
	
        eod_report.menu_click = function(id, zoneId, cas) {
			switch(id) {
				case "pdf":
					eod_report.eod_report_grid.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
					break;
				case "excel":
					eod_report.eod_report_grid.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
					break;
			}
		}
    </script>