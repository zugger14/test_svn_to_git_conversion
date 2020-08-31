<?php
/**
* Setup Paying Terms screen
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
        $form_namespace = 'setup_paying_terms';
        $application_function_id = 20017000;
        $right_formula_UI = 20017001;
		$right_formula_delete = 20017002;

		list (
            $has_right_formula_UI,
			$has_right_formula_delete
		) = build_security_rights(
			$right_formula_UI,
			$right_formula_delete
		);
        $form_obj = new AdihaStandardForm($form_namespace, $application_function_id);
        $form_obj->define_grid("setup_paying_terms");
        $form_obj->define_layout_width(300);
        $form_obj->define_custom_functions('', '','delete_function','form_load_complete'); 
		echo $form_obj->init_form('Payment Terms', '', '');
		echo $form_obj->close_form(); 
    ?>
<script>
    setup_paying_terms.form_load_complete = function(){
        var tab_id = setup_paying_terms.tabbar.getActiveTab();
        var win = setup_paying_terms.tabbar.cells(tab_id);
        var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(" ", ""));
        var tab_obj = win.tabbar[object_id];
        var detail_tabs = tab_obj.getAllTabs();
        
        $.each(detail_tabs, function(index, value) {
            layout_obj = tab_obj.cells(value).getAttachedObject();
            layout_obj.forEachItem(function(cell) {
                attached_obj = cell.getAttachedObject();

                    if (attached_obj instanceof dhtmlXGridObject) {
						var myMenu = layout_obj.cells('b').getAttachedMenu();
                        myMenu.addNewSibling('t2', 'refresh', 'Refresh', false, 'refresh.gif', 'refresh_dis.gif');
                        myMenu.setTooltip('refresh', 'Refresh');
                        myMenu.attachEvent("onClick",setup_paying_terms.paying_terms_menu_onclick);

                        attached_obj.attachEvent('onRowDblClicked', function(id, ind) {
                                var formula_id_index = attached_obj.getColIndexById('formula_id');
                                var formula_name_index = attached_obj.getColIndexById('formula_name');
                                var row_id = attached_obj.getSelectedRowId();
                                var formula_id = attached_obj.cells(row_id, formula_id_index).getValue();

                               if (ind == formula_name_index) {
                                    ___browse_win_link_window = new dhtmlXWindows();
                                    var src = '../../_setup/formula_builder/formula.editor.php?formula_id=' + formula_id + '&call_from=browser&is_rate_schedule=1&row_id=' + row_id ;

                                    win_formula_id = ___browse_win_link_window.createWindow('w1', 0, 0, 1200, 650);
                                    win_formula_id.setText("Browse");
                                    win_formula_id.centerOnScreen();
                                    win_formula_id.setModal(true);
                                    win_formula_id.attachURL(src, false);
                               } 
                        });
                    }


                });
     });
    }

    setup_paying_terms.paying_terms_menu_onclick = function(id) {
        switch(id) {
            case "refresh":
                setup_paying_terms.refresh_paying_terms_grid();
            break;
        }       
    }

    setup_paying_terms.refresh_paying_terms_grid = function() {
        var tab_id = setup_paying_terms.tabbar.getActiveTab();
        var win = setup_paying_terms.tabbar.cells(tab_id);
        var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(" ", ""));
        var tab_obj = win.tabbar[object_id];
        var detail_tabs = tab_obj.getAllTabs();

        $.each(detail_tabs, function(index, value) {
            layout_obj = tab_obj.cells(value).getAttachedObject();
            var grid_obj = layout_obj.cells('b').getAttachedObject();
            var form_obj = layout_obj.cells('a').getAttachedObject();

            var sql_param = {
                       "action": 'spa_paying_terms',
                       "flag": 's',
                       "payment_terms_id": form_obj.getItemValue('payment_terms_id')
                   };

                   sql_param = $.param(sql_param);
                   var sql_url = js_data_collector_url + "&" + sql_param;
                   grid_obj.clearAll();
                   grid_obj.load(sql_url);
        });
   }

   setup_paying_terms.delete_function = function() {
        var selected_row = setup_paying_terms.grid.getSelectedRowId();
        var payment_terms_id_index = setup_paying_terms.grid.getColIndexById('payment_terms_id');
        selected_row = selected_row.split(',');
        var ids = [];
        selected_row.forEach(function(rid) {
            var payment_terms_id = setup_paying_terms.grid.cells(rid, payment_terms_id_index).getValue();
            ids.push(payment_terms_id);
        });
        ids = ids.toString();
        var sql = {
            'action': 'spa_paying_terms',
            'flag': 'd',
            'del_ids': ids
        }

        if (ids != '') {
            dhtmlx.message({
                type: "confirm",
                title: "Confirmation",
                text: "Are you sure you want to delete?",
                callback: function(result) {
                    if (result) {
                        grid_del = true;
                        result = adiha_post_data("return_array", sql, "", "", "setup_paying_terms.post_delete_callback");
                    }
                }
            });
        }

    }

    function set_formula_columns(formula_id, txt_formula, row_id, rate_category_grid) {
        var tab_id = setup_paying_terms.tabbar.getActiveTab();
        var win = setup_paying_terms.tabbar.cells(tab_id);
        var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(" ", ""));
        var tab_obj = win.tabbar[object_id];
        var detail_tabs = tab_obj.getAllTabs();
            
            $.each(detail_tabs, function(index,value) {
                layout_obj = tab_obj.cells(value).getAttachedObject();
                var grid_obj = layout_obj.cells('b').getAttachedObject();

                var formula_id_index = grid_obj.getColIndexById('formula_id');
                var formula_name_index = grid_obj.getColIndexById('formula_name');
                
                grid_obj.cells(row_id, formula_id_index).setValue(formula_id);   
                grid_obj.cells(row_id, formula_name_index).setValue(txt_formula);          
                grid_obj.cells(row_id, formula_id_index).cell.wasChanged = true; //made dirty row after setting the formula column value.

            });          
    }




</script>
</body>
</html>