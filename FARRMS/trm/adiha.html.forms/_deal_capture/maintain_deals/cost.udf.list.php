<?php
/**
* Cost udf list screen
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
</head>
<body>
<?php 
    $form_namespace = 'udfList';
    $deal_id = (isset($_POST["deal_id"]) && $_POST["deal_id"] != '') ? get_sanitized_value($_POST["deal_id"]) : '';
    $template_id = (isset($_POST["template_id"]) && $_POST["template_id"] != '') ? get_sanitized_value($_POST["template_id"]) : 'NULL';
    $type = (isset($_POST["type"]) && $_POST["type"] != '') ? get_sanitized_value($_POST["type"]) : '';
    $udf_process_id = (isset($_POST["udf_process_id"]) && $_POST["udf_process_id"] != '') ? get_sanitized_value($_POST["udf_process_id"]) : 'NULL';
    $detail_id = (isset($_POST["detail_id"]) && $_POST["detail_id"] != '') ? get_sanitized_value($_POST["detail_id"]) : 'NULL';

   	/*
   		type = hc --> header cost
   			 = hu --> header udfs
   			 = dc --> detail cost
   			 = du --> detail udfs
   	 */

    $layout_json = '[{id: "a", header:false}, {id: "b", header:false}]';
    $toolbar_json = '[{id:"ok", type:"button", img: "tick.gif", img_disabled: "tick_dis.gif", text:"Ok", title: "Ok"},
                      {id:"cancel", type:"button", img: "close.gif", img_disabled: "close_dis.gif", text:"Cancel", title: "Cancel"}
                  ]';
    $layout_obj = new AdihaLayout();
    $toolbar_obj = new AdihaToolbar();

    echo $layout_obj->init_layout('layout', '', '2U', $layout_json, $form_namespace);

    echo $layout_obj->attach_toolbar('toolbar');
    echo $toolbar_obj->init_by_attach('toolbar', $form_namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', $form_namespace . '.toolbar_click');
    
    $menu_json = '[{id:"refresh", text:"Refresh", img:"refresh.gif", enabled:true, imgdis:"refresh_dis.gif", title: "Refresh"}]';

    $header_cost_menu = new AdihaMenu();
    echo $layout_obj->attach_menu_cell('menu_a', 'a');
    echo $header_cost_menu->init_by_attach('menu_a', $form_namespace);
    echo $header_cost_menu->load_menu($menu_json);
    echo $header_cost_menu->attach_event('', 'onClick', $form_namespace . '.menu_a_click');

    echo $layout_obj->attach_grid_cell('udf_list_grid', 'a');
    echo $layout_obj->attach_status_bar("a", true);

    $udf_list_grid = new GridTable('udf_list_grid');        
    echo $udf_list_grid->init_grid_table('udf_list_grid', $form_namespace, 'n');
    echo $udf_list_grid->set_column_auto_size();
    echo $udf_list_grid->set_search_filter(true, "");
    echo $udf_list_grid->enable_paging(100, 'pagingArea_a', 'true');       
    echo $udf_list_grid->enable_DND(true);
    echo $udf_list_grid->enable_multi_select();
    echo $udf_list_grid->return_init();
    echo $udf_list_grid->attach_event('', 'onRowDblClicked', $form_namespace . '.move_item_to_selected');
    
    $sp_grid = "EXEC spa_udf_groups @flag='s', @deal_id=" . $deal_id . ", @template_id=" . $template_id . ", @udf_process_id='" . $udf_process_id . "', @udf_type='" . $type . "', @detail_id=" . $detail_id;

    echo $udf_list_grid->load_grid_data($sp_grid, '', false, 'udfList.expand_all');
    echo $udf_list_grid->load_grid_functions();

    $menu_json = '[
    				{id:"refresh", text:"Refresh", img:"refresh.gif", enabled:true, imgdis:"refresh_dis.gif", title: "Refresh"},
    				{id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete",enabled:false}
    			]';

    $header_cost_menu = new AdihaMenu();
    echo $layout_obj->attach_menu_cell('menu_b', 'b');
    echo $header_cost_menu->init_by_attach('menu_b', $form_namespace);
    echo $header_cost_menu->load_menu($menu_json);
    echo $header_cost_menu->attach_event('', 'onClick', $form_namespace . '.menu_b_click');

    echo $layout_obj->attach_grid_cell('udf_list_grid_selected', 'b');
    echo $layout_obj->attach_status_bar("b", true);

    $udf_list_grid_selected = new GridTable('udf_list_grid_selected');        
    echo $udf_list_grid_selected->init_grid_table('udf_list_grid_selected', $form_namespace, 'n');
    echo $udf_list_grid_selected->set_column_auto_size();
    echo $udf_list_grid_selected->set_search_filter(true, "");
    echo $udf_list_grid_selected->enable_paging(100, 'pagingArea_b', 'true');       
    echo $udf_list_grid_selected->enable_DND(false);
    echo $udf_list_grid_selected->enable_multi_select();
    echo $udf_list_grid_selected->return_init();
    echo $udf_list_grid_selected->attach_event("", "onSelectStateChanged", $form_namespace . '.row_selection');
    echo $udf_list_grid_selected->attach_event("", "onDrop", $form_namespace . '.row_drop');
    
    $sp_selected_grid = "EXEC spa_udf_groups @flag='x', @deal_id=" . $deal_id . ", @template_id=" . $template_id . ", @udf_process_id='" . $udf_process_id . "', @udf_type='" . $type . "', @detail_id=" . $detail_id;
    echo $udf_list_grid_selected->load_grid_data($sp_selected_grid);

    echo $layout_obj->close_layout();
?>
</body>
<textarea style="display:none" name="txt_click" id="txt_click">cancel</textarea>
<script type="text/javascript">
    var type = '<?php echo $type; ?>';    
    
    $(function() {
    	udfList.udf_list_grid.enableTreeCellEdit(false);
    	udfList.udf_list_grid_selected.enableTreeCellEdit(false);

    	udfList.udf_list_grid.attachEvent("onDragIn", function(dId,tId,sObj,tObj){
    		return false;                                       
		});

		udfList.udf_list_grid_selected.setDragBehavior("sibling");

		if (type == 'hc' || type == 'dc') {
			udfList.udf_list_grid.setColLabel(0, get_locale_value("Costs"));
			udfList.udf_list_grid_selected.setColLabel(0, get_locale_value("Selected Costs"));
		}
    });

    udfList.toolbar_click = function(id) {
    	if (id == 'ok') {
    		var udf_id_index = udfList.udf_list_grid_selected.getColIndexById('id');
            var id_array = new Array();

            var inp = udfList.udf_list_grid_selected.getFilterElement(0);

            if (inp.value != '') {     
            	inp.value = "";
				udfList.udf_list_grid_selected.filterByAll();
            }

            for (var i=0; i < udfList.udf_list_grid_selected.getRowsNum(); i++){
			    var id = udfList.udf_list_grid_selected.cells2(i, udf_id_index).getValue();
			    id_array.push(id);
			};

			var udf_ids = id_array.join();
			var udf_process_id = '<?php echo $udf_process_id;?>';
			var deal_id = '<?php echo $deal_id;?>';
			var type = '<?php echo $type;?>';
			var template_id = '<?php echo $template_id;?>';
			var detail_id = '<?php echo $detail_id;?>';

            var cm_param = {"action": "spa_udf_groups", "flag": "i", "udf_process_id":udf_process_id, "deal_id":deal_id, "template_id":template_id, "udf_ids":udf_ids, "udf_type":type, "detail_id":detail_id};
    		adiha_post_data("alert", cm_param, '', '', '');
    		document.getElementById("txt_click").value = 'ok';

    		setTimeout(function() {
	    		var win_obj = window.parent.cost_udf_window.window("w1");
	            win_obj.close();
            }, 500)
        } else if (id == 'cancel') {
        	document.getElementById("txt_click").value = 'cancel';
        	var win_obj = window.parent.cost_udf_window.window("w1");
            win_obj.close();
        }
    }

    udfList.menu_a_click = function(id) {
    	if (id == 'refresh') {
    		udfList.refresh_grid('', udfList.expand_all);
    	}
    }

    udfList.menu_b_click = function(id) {
    	if (id == 'delete') {
    		udfList.udf_list_grid_selected.deleteSelectedRows();
    	} else if (id == 'refresh') {
    		var deal_id = '<?php echo $deal_id;?>';
    		var udf_process_id = '<?php echo $udf_process_id;?>';
    		var type = '<?php echo $type;?>';
			var template_id = '<?php echo $template_id;?>';
			var detail_id = '<?php echo $detail_id;?>';

    		var data = {
	            "action":"spa_udf_groups",
	            "flag":'x',
	            "deal_id":deal_id,
	            "template_id":template_id,
	            "udf_process_id":udf_process_id,
	            "udf_type":type,
	            "detail_id":detail_id,
	            "grid_type":"g"
	        }   
    		sql_param = $.param(data);

    		var sql_url = js_data_collector_url + "&" + sql_param;
    		udfList.udf_list_grid_selected.clearAll();
        	udfList.udf_list_grid_selected.load(sql_url);
    	}
    }

    udfList.expand_all = function() {
    	udfList.udf_list_grid.expandAll();
    }

    udfList.row_selection = function(row) {
        if (row != null && row != '') {
            udfList.menu_b.setItemEnabled('delete');
        } else {
        	udfList.menu_b.setItemDisabled('delete');
        }
    }

    udfList.move_item_to_selected = function(row_id, col_id) {
    	var udf_id = udfList.udf_list_grid.cells(row_id, 1).getValue();

    	if (udf_id == '') {
    		udfList.udf_list_grid._h2.forEachChild(row_id,function(element){
    			var child_udf_id = udfList.udf_list_grid.cells(element.id, 1).getValue();
    			var find_row = udfList.udf_list_grid_selected.findCell(child_udf_id, 1, true, true);

    			if (find_row == "")
    				udfList.udf_list_grid.moveRow(element.id,"row_sibling",0,udfList.udf_list_grid_selected);
			});
    	} else {
    		var child_udf_id = udfList.udf_list_grid.cells(row_id, 1).getValue();
    		var find_row = udfList.udf_list_grid_selected.findCell(child_udf_id, 1, true, true);

			if (find_row == "")
    			udfList.udf_list_grid.moveRow(row_id,"row_sibling",0,udfList.udf_list_grid_selected);
    	}
    }

    udfList.row_drop = function(sId, tId, dId, sObj, tObj, sCol, tCol) {
    	var dropped_array = new Array();		
		dropped_array = dId.split(',');

		$.each(dropped_array, function(index, value) {
	    	var udf_id = tObj.cells(value, 1).getValue();

	    	if (udf_id == '') {
	    		udfList.udf_list_grid._h2.forEachChild(value,function(element){
	    			var child_udf_id = udfList.udf_list_grid.cells(element.id, 1).getValue();
	    			var find_row = udfList.udf_list_grid_selected.findCell(child_udf_id, 1, false, true);

	    			if (find_row.length > 1) udfList.udf_list_grid_selected.deleteRow(element.id);
				});				
				udfList.udf_list_grid_selected.deleteRow(value);
	    	} else {
	    		var child_udf_id = udfList.udf_list_grid_selected.cells(value, 1).getValue();
    			var find_row = udfList.udf_list_grid_selected.findCell(child_udf_id, 1, false, true);

    			if (find_row.length > 1) udfList.udf_list_grid_selected.deleteRow(value);
	    	}
    	});

    	return true;
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