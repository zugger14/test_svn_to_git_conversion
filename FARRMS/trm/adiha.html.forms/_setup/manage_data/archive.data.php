<?php
/**
* Archive data screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
    <style>
    	.dhxform_obj_dhx_web ,
    	.dhxform_obj_dhx_web div.dhxform_btn {
    		background-color:white!important
    	}
    	.dhxform_btn_txt {
    		font-size:28px;
    		color:#17ae61;
    		font-family:Verdana, Geneva, sans-serif!important;
    	}
    	.hdrcell {
    		text-transform: none!important;
    	}
    </style>
</head>
<body>
	<?php		
		$namespace = 'archive_data';
		$layout_object = new AdihaLayout();

		$layout_json = '[
            {
                id:             "a",
                text:           "Apply Filter",
                header:         true,
                height:			80
            },
            {
                id:             "b",
                text:           "Filter Criteria",
                header:         true,
                collapse:       false,
                height: 		80
            },
            {
                id:             "c",
                header:         false,
                collapse:       false
            }
        ]';

		echo $layout_object->init_layout('layout', '', '3E', $layout_json, $namespace);

		$form_xml = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='20006800', @template_name='ArchiveData', @group_name='General'";
		$return_value1 = readXMLURL($form_xml);
		$form_json = $return_value1[0][2];
		echo $layout_object->attach_form('archive_data_form', 'b');
		$archive_data_form = new AdihaForm();
		echo $archive_data_form->init_by_attach('archive_data_form', $namespace);
		echo $archive_data_form->load_form($form_json);
		
		
		$grid_cell_layout_json = '[
	        {
	            id:             "a",
	            text:           "Data Source (Main)",
	            header:         true,
	        },
	        {
	            id:             "b",
	            width:			100,
	            header:			false,
	            collapse:       false
	        },
	        {	
	            id:             "c",
	            text:           "Data Source (Archive)",
	            header:         true,
	            collapse:       false
	        }
	   	]';
	   	
		$menu_json = '[{id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif"}]';

		$grid_cell_layout_object = new AdihaLayout();
		echo $layout_object->attach_layout_cell('inner_layout', 'c', '3W', $grid_cell_layout_json);
		echo $layout_object->attach_menu_layout_cell('grid_cell_menu', 'c', $menu_json, 'grid_cell_menu_onlick');

		$grid_cell_layout_object->init_by_attach('inner_layout', $namespace);

		$menu_json = '[{id:"t2", text:"Export", img:"export.gif"}]';

		create_grid($namespace, 'ArchiveData', 'left_grid_object', $grid_cell_layout_object, 'a');
		create_grid($namespace, 'ArchiveData', 'right_grid_object', $grid_cell_layout_object, 'c');

		$move_form_json = "[
			{type: 'block', width:100, list:[
				{type: 'button', name: 'add', value: '&#8644;', offsetTop:150},
			]}
		]";

		echo $grid_cell_layout_object->attach_form('move_form', 'b');
		$move_form = new AdihaForm();
		echo $move_form->init_by_attach('move_form', $namespace);
		echo $move_form->load_form($move_form_json);

		echo $layout_object->close_layout();

		function create_grid($namespace, $grid_name, $grid_obj_name, $layout_object, $cell) {
			echo $layout_object->attach_grid_cell($grid_name,$cell);
			$$grid_obj_name = new  GridTable($grid_name);
			echo $layout_object->attach_status_bar($cell,true);
			echo $$grid_obj_name->init_grid_table($grid_name, $namespace);
			echo $$grid_obj_name->set_search_filter(true);
			echo $$grid_obj_name->return_init();
		}
	?>
	<script type="text/javascript">

		var ltr;
		var as_of_dates = [];

		$(function() {
			filter_obj = archive_data.layout.cells('a').attachForm();
			var layout_cell_obj = archive_data.layout.cells('b');
			load_form_filter(filter_obj, layout_cell_obj, '20006800', 2);

			var form_object = archive_data.layout.cells('b').getAttachedObject()
			form_object.disableItem('move');

			archive_data.inner_layout.cells('b').getAttachedObject().attachEvent("onButtonClick", function(name) {
				if (!ltr){
					show_messagebox('Please Select a Row');
					return;
				}

				var data_type = form_object.getItemValue('data_type');
				if (ltr == 'y') {
					var cell = 'a';
					var sequence_from = 1;
					var sequence_to = 2;
					var source_name_from = 'Main'; 
					var source_name_to = 'Archive'; 
				} else {
					var cell = 'c';
					var sequence_from = 2;
					var sequence_to = 1;
					var source_name_from = "Archive"; 
					var source_name_to = "Main"; 
				}

				var grid_obj = archive_data.inner_layout.cells(cell).getAttachedObject();
				as_of_dates = [];
				grid_obj.getSelectedRowId().split(',').forEach(function(sel_id){
					as_of_dates.push(grid_obj.cells(sel_id,0).getValue());
				})

				var sql = "spa_manual_archive_data @archive_type_value_id = " + data_type 
					+ ", @as_of_date = '" + as_of_dates.join(',') + "'" 
					+ ", @from_sequence = " + sequence_from
					+ ", @to_sequence = " + sequence_to + "";

				var message = "Are you sure you wan to move data from " + source_name_from + " to " + source_name_to + " for as of date " + as_of_dates.join(',');
				confirm_messagebox(message, function(){
					adiha_run_batch_process(sql, 'gen_as_of_date=1&batch_type=c', 'Run Archive Job');
				});
			});

			grid_left = archive_data.inner_layout.cells('a').getAttachedObject();
			grid_right = archive_data.inner_layout.cells('c').getAttachedObject();

			grid_left.attachEvent('onRowSelect', function(){
				grid_right.clearSelection();
				ltr = 'y';
			});
			grid_right.attachEvent('onRowSelect', function(){
				grid_left.clearSelection();
				ltr = 'n';
			});

			archive_data.layout.cells('a').collapse();
		});

		function grid_cell_menu_onlick(id) {
			switch (id) {
				case 'refresh':
					refresh_grids();
					break
				default:
					break;
			}
		}

		function refresh_grids(nocheck) {
			nocheck = nocheck || false;

			var filter_cell = archive_data.layout.cells('a');
			var form_cell = archive_data.layout.cells('b');

			var form_object = form_cell.getAttachedObject();
			var data_location_left = form_object.getItemValue('data_location_left');
			var data_location_right = form_object.getItemValue('data_location_right');

			if(!nocheck) {
				var status = validate_form(form_object);
				if(!status) {
					form_cell.expand();
					return;
				}
				filter_cell.collapse();
				form_cell.collapse();
			}
			
			var sql_obj = {
				"action": "spa_get_dump_data",
				"flag": "m",
				"archive_type_value_id": form_object.getItemValue('data_type'),
				"archive_tbl_sequence": 1
			};

			if (form_object.getItemValue('as_of_date_from',true)) {
				sql_obj['as_of_date_from'] = form_object.getItemValue('as_of_date_from',true);
			}

			if (form_object.getItemValue('as_of_date_to',true)) {
				sql_obj['as_of_date_to'] = form_object.getItemValue('as_of_date_to',true);
			}

			// load left Grid
			load_grid_data(sql_obj, 'a');

			// Load Right Grid
			sql_obj.archive_tbl_sequence = 2;
			load_grid_data(sql_obj, 'c');
		}

		function load_grid_data(sql_obj, cell){
			archive_data.inner_layout.cells(cell).progressOn();
			sql_param = $.param(sql_obj);
			var sql_url = js_data_collector_url + '&' + sql_param;

			var grid_object = archive_data.inner_layout.cells(cell).getAttachedObject();
			grid_object.clearAll();
			grid_object.loadXML(sql_url, function() {
				grid_object.filterByAll();
				archive_data.inner_layout.cells(cell).progressOff();
			});
		}
	</script>
</body>
</html>