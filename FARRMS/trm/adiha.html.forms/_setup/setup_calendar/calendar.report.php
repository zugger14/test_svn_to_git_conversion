<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
<body>
<?php 
	$form_namespace = 'calendar_report';
    $user = (isset($_GET["user"]) && $_GET["user"] != '') ? get_sanitized_value($_GET["user"]) : 'NULL';
	$role = (isset($_GET["role"]) && $_GET["role"] != '') ? get_sanitized_value($_GET["notes_id"]) : 'NULL';
	$status = (isset($_GET["status"]) && $_GET["status"] != '') ? get_sanitized_value($_GET["status"]) : 'NULL';
	$hour_from = (isset($_GET["hour_from"]) && $_GET["hour_from"] != '') ? get_sanitized_value($_GET["hour_from"]) : 'NULL';
	$hour_to = (isset($_GET["hour_to"]) && $_GET["hour_to"] != '') ? get_sanitized_value($_GET["hour_to"]) : 'NULL';
	
	$layout_json = '[{id: "a", header:false}]';
	
    $layout_obj = new AdihaLayout();
    $menu_obj = new AdihaMenu();
    $grid_obj = new GridTable('calendar_report');

    $menu_json = '[  
                    {id:"t2", text:"Export", img:"export.gif", items:[
                        {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                        {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                    ]}                       
                  ]';

    echo $layout_obj->init_layout('layout', '', '1C', $layout_json, $form_namespace);
    echo $layout_obj->attach_menu_cell('menu', 'a');
    echo $menu_obj->init_by_attach('menu', $form_namespace);
    echo $menu_obj->load_menu($menu_json);
    echo $menu_obj->attach_event('', 'onClick', $form_namespace . '.menu_click');

    echo $layout_obj->attach_grid_cell('grid', 'a');
    echo $layout_obj->attach_status_bar("a", true);
    
    echo $grid_obj->init_grid_table('grid', $form_namespace);
    echo $grid_obj->set_column_auto_size();
    echo $grid_obj->set_search_filter(false, "#text_filter,#text_filter,#text_filter,#daterange_filter,#combo_filter,#daterange_filter,#combo_filter,#combo_filter,#text_filter,#text_filter,#combo_filter");
    echo $grid_obj->enable_paging(50, 'pagingArea_a', 'true');       
    echo $grid_obj->enable_column_move();
	echo $grid_obj->split_grid(0);
    echo $grid_obj->return_init();
    echo $grid_obj->attach_event("", "onSelectStateChanged", $form_namespace . '.grid_row_selection');
    echo $grid_obj->load_grid_functions();

    echo $layout_obj->close_layout();
?>
</body>
<textarea style="display:none" name="success_status" id="success_status"></textarea>
<script type="text/javascript">

	$(function() {
		var user = '<?php echo $user; ?>';
		var role = '<?php echo $role; ?>';
		var status = '<?php echo $status; ?>';
		var hour_from = '<?php echo $hour_from; ?>';
		var hour_to = '<?php echo $hour_to; ?>';
		
		var sql_param = {
                "flag": "j",
                "action":"spa_calendar",
                "grid_type":"g",
				"user_id": user,
				"role_id": role,
				"status": status,
				"date_from": "",
				"date_to": "",
				"hour_from": hour_from,
				"hour_to": hour_to,
            };

		sql_param = $.param(sql_param);
		var sql_url = js_data_collector_url + "&" + sql_param;
		calendar_report.grid.clearAll();
		calendar_report.grid.load(sql_url);
	})


    /**
     * [menu_click toolbar clicked.]
     * @param  {[string]} id [Menu Id]
     */
    calendar_report.menu_click = function(id) {
        switch(id) {
            case "pdf":
                calendar_report.grid.toPDF(js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                break;
            case "excel":
                calendar_report.grid.toPDF(js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                break;
        }
    }

</script>
<style type="text/css">
    html, body {
        width: 100%;
        height: 100%;
        margin: 0px;
        padding: 0px;
        background-color: #ebebeb;
        overflow: hidden;
    }
</style>
</html>