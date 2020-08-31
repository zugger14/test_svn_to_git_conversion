<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('components/include.file.v3.php'); ?>
</head>
<body>
<?php 
	$form_namespace = 'bookBrowser';
    $menu_name = 'book_menu';
    $enable_subsidiary = (isset($_POST["enable_subsidiary"]) && $_POST["enable_subsidiary"] != '') ? $_POST["enable_subsidiary"] : 0;
    $enable_strategy = (isset($_POST["enable_strategy"]) && $_POST["enable_strategy"] != '') ? $_POST["enable_strategy"] : 0;
    $enable_book = (isset($_POST["enable_book"]) && $_POST["enable_book"] != '') ? $_POST["enable_book"] : 0;
    $enable_subbook = (isset($_POST["enable_subbook"]) && $_POST["enable_subbook"] != '') ? $_POST["enable_subbook"] : 0;
    $win_name = (isset($_POST["win_name"]) && $_POST["win_name"] != '') ? $_POST["win_name"] : 0;
    $trans_type = (isset($_GET['trans_type'])) ? $_GET['trans_type'] : 'NULL';

     //For Sub Book Grid tag column name
    $xml_file = "EXEC spa_source_book_mapping_clm";
    $resultset = readXMLURL2($xml_file);
    $group_1 = $resultset[0]['group1'];
    $group_2 = $resultset[0]['group2'];
    $group_3 = $resultset[0]['group3'];
    $group_4 = $resultset[0]['group4'];

    if ($SHOW_SUBBOOK_IN_BS == 1){
		$layout_json = '[{id: "a", header:true, text:"Book Structure", height:7,collapse:false,fix_size:[true,true]},{id: "b", header:false,fix_size:[true,true]}]';
		$toolbar_json = '[{id:"ok", type:"button", img: "save.gif", img_disabled: "save_dis.gif", text:"Save", title: "Save"},
	                      {id:"cancel", type:"button", img: "close.gif", img_disabled: "close_dis.gif", text:"Cancel", title: "Cancel"}]';

	    $layout_obj = new AdihaLayout();
	    $toolbar_obj = new AdihaToolbar();

	    echo $layout_obj->init_layout('deal_status_layout', '', '2E', $layout_json, $form_namespace);
	    echo $layout_obj->attach_toolbar_cell('toolbar', 'a');
	    echo $toolbar_obj->init_by_attach('toolbar', $form_namespace);
	    echo $toolbar_obj->load_toolbar($toolbar_json);
	    echo $toolbar_obj->attach_event('', 'onClick', $form_namespace . '.toolbar_click');

	    $portfolio_name = 'portfolio_filter';
	    echo $layout_obj->attach_tree_cell($portfolio_name, 'b');

	    $portfolio_obj = new AdihaBookStructure(10131000);
	    echo $portfolio_obj->init_by_attach($portfolio_name, $form_namespace);
	    echo $portfolio_obj->set_portfolio_option(0);
	    echo $portfolio_obj->set_subsidiary_option($enable_subsidiary);
	    echo $portfolio_obj->set_strategy_option($enable_strategy);
	    echo $portfolio_obj->set_book_option($enable_book);
	    echo $portfolio_obj->set_subbook_option($enable_subbook);
	    echo $portfolio_obj->set_tree_expand_flag(0);
	    echo $portfolio_obj->load_book_structure_data();
	    echo $portfolio_obj->expand_level('root');
	    echo $portfolio_obj->enable_three_state_checkbox();
	    echo $portfolio_obj->load_tree_functons();
		echo $portfolio_obj->attach_search_filter('bookBrowser.deal_status_layout', 'b');
    } else {
    	$layout_json = '[{id: "a", header:true, text:"Book Structure", height:7,width:300,collapse:false,fix_size:[true,true]},{id: "b", header:false,fix_size:[true,true]}]';

        $menu_json = '[{id:"refresh", img:"refresh.gif", img_disabled:"refresh_dis.gif", text:"Refresh", title:"Refresh", enabled: true}, {id:"save", img:"save.gif", img_disabled:"save_dis.gif", title:"Save",enabled: 0}]';

        $layout_obj = new AdihaLayout();
        $toolbar_obj = new AdihaToolbar();

        echo $layout_obj->init_layout('deal_status_layout', '', '2U', $layout_json, $form_namespace);
       

        $portfolio_name = 'portfolio_filter';
        echo $layout_obj->attach_tree_cell($portfolio_name, 'a');

        $portfolio_obj = new AdihaBookStructure(10131000);
        echo $portfolio_obj->init_by_attach($portfolio_name, $form_namespace);
        echo $portfolio_obj->set_portfolio_option(2);
        echo $portfolio_obj->set_subsidiary_option(2);
        echo $portfolio_obj->set_strategy_option(2);
        echo $portfolio_obj->set_book_option(2);
        echo $portfolio_obj->set_subbook_option(2);
        // echo $portfolio_obj->set_tree_expand_flag(0);
        echo $portfolio_obj->load_book_structure_data();
        echo $portfolio_obj->expand_level('all');
        echo $portfolio_obj->enable_three_state_checkbox();
        echo $portfolio_obj->load_tree_functons();
    	echo $portfolio_obj->attach_search_filter('bookBrowser.deal_status_layout', 'a');

        $menu_name = 'source_menu';
        echo $layout_obj->attach_menu_layout_cell($menu_name, 'b', $menu_json
            , $form_namespace.'.toolbar_click');
        $source_grid_name = 'source_grid';
        echo $layout_obj->attach_grid_cell($source_grid_name, 'b');
        $source_grid_obj = new AdihaGrid();
        echo $layout_obj->attach_status_bar("b", true);
        echo $source_grid_obj->init_by_attach($source_grid_name, $form_namespace);
        echo $source_grid_obj->set_columns_ids("fas_book_id,logical_name,tag1,tag2,tag3,tag4,transaction_type");
        echo $source_grid_obj->set_header("FAS Book ID,Logical Name,".$group_1.",".$group_2.",".$group_3.",".$group_4.",Transaction Type");
        echo $source_grid_obj->set_search_filter('#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter'); 
        echo $source_grid_obj->set_sorting_preference('str,str,str,str,str,str,str'); 
        echo $source_grid_obj->set_column_types("ro,ro,ro,ro,ro,ro,ro");
        echo $source_grid_obj->set_widths('100,200,130,130,130,200,200');
        echo $source_grid_obj->set_column_visibility("true,false,false,false,false,false,false");
        echo $source_grid_obj->enable_paging(100, 'pagingArea_b', 'true');
        echo $source_grid_obj->return_init();
        echo $source_grid_obj->enable_header_menu();
        echo $source_grid_obj->attach_event('', 'onRowSelect', $form_namespace . '.enabled_button');
    }

    echo $layout_obj->close_layout();
?>
</body>
<textarea style="display:none" name="return_string" id="return_string"></textarea>
<script type="text/javascript">
    bookBrowser = {};
    source_grid = {};
    portfolio_filter = {};
    var expand_state = true;
    var win_name = '<?php echo $win_name; ?>';
    eval('var win_obj = window.parent.'+win_name+'.window("w1");');
    var SHOW_SUBBOOK_IN_BS = <?php echo $SHOW_SUBBOOK_IN_BS;?>;

    bookBrowser.enabled_button =function(){
        bookBrowser.source_menu.setItemEnabled('save');
    }

    /**
     * [toolbar_click Deal Status toolbar clicked.]
     * @param  {[string]} id [Menu Id]
     */
    bookBrowser.toolbar_click = function(id) {
        var trans_type = '<?php echo $trans_type; ?>';
        var fas_book_id = (bookBrowser.get_book()) ? bookBrowser.get_book() : '0';  
        switch(id) {
            case "refresh":
                if (fas_book_id == 0) {
                        dhtmlx.alert({type: "alert", title:'Alert', text:"Please select a Book."});
                        return;
                }
                var param = {"action": "spa_sourcesystembookmap","flag": "n","fas_book_id_arr":fas_book_id,"grid_type": "g", 'fas_deal_type_value_id': trans_type};
                    param = $.param(param);
                    var param_url = js_data_collector_url + "&" + param;
                    bookBrowser.source_grid.clearAndLoad(param_url);
                break;
            case "save":
                var enable_subsidiary = '<?php echo $enable_subsidiary;?>';
                var enable_strategy = '<?php echo $enable_strategy;?>';
                var enable_book = '<?php echo $enable_book;?>';
                var enable_subbook = '<?php echo $enable_subbook;?>';
                var return_array = new Array();

                if (enable_subsidiary != 0) {
                    return_array[0] = bookBrowser.get_subsidiary('page');
                } else {
                    return_array[0] = '';
                }

                if (enable_strategy != 0) {
                    return_array[1] = bookBrowser.get_strategy('page');
                } else {
                    return_array[1] = '';
                }

                if (enable_book != 0) {
                    return_array[2] = bookBrowser.get_book('page');
                } else {
                    return_array[2] = '';
                }

                if (enable_subbook != 0) {
                    var selected_row = bookBrowser.source_grid.getSelectedRowId();
                    return_array[3] = bookBrowser.source_grid.cells(selected_row, bookBrowser.source_grid.getColIndexById('fas_book_id')).getValue();
                } else {
                    return_array[3] = '';
                }

                var return_json_string = JSON.stringify(return_array);
                document.getElementById("return_string").value = return_json_string;
                console.log(return_json_string);
                win_obj.close();
                break;
            case "ok":
                var enable_subsidiary = '<?php echo $enable_subsidiary;?>';
                var enable_strategy = '<?php echo $enable_strategy;?>';
                var enable_book = '<?php echo $enable_book;?>';
                var enable_subbook = '<?php echo $enable_subbook;?>';
                var return_array = new Array();

                if (enable_subsidiary != 0) {
                    return_array[0] = bookBrowser.get_subsidiary('page');
                } else {
                    return_array[0] = '';
                }

                if (enable_strategy != 0) {
                    return_array[1] = bookBrowser.get_strategy('page');
                } else {
                    return_array[1] = '';
                }

                if (enable_book != 0) {
                    return_array[2] = bookBrowser.get_book('page');
                } else {
                    return_array[2] = '';
                }

                if (enable_subbook != 0) {
                    return_array[3] = bookBrowser.get_subbook('page');
                } else {
                    return_array[3] = '';
                }

                var return_json_string = JSON.stringify(return_array);
                document.getElementById("return_string").value = return_json_string;

                if (return_json_string == '["","","",""]') {
                    dhtmlx.alert({
                        title:"Error",
                        type:"alert-error",
                        text:'Please select a sub book.'
                    });
                    return;
                }
                
                win_obj.close();
                break;
            case "cancel":
                document.getElementById("return_string").value = '';
                win_obj.close();
                break;
            case "expand_collapse":
                var selected_ids = bookBrowser.portfolio_filter.getSelectedItemId();

                if (selected_ids == '') {
                    if (expand_state) {
                        bookBrowser.portfolio_filter.openAllItems(0);
                        expand_state = false;
                    } else {
                        bookBrowser.portfolio_filter.closeAllItems(0);
                        expand_state = true;
                    }
                } else {
                    if (bookBrowser.portfolio_filter.getOpenState(selected_ids) != -1) {
                        bookBrowser.portfolio_filter.closeAllItems(selected_ids);
                    } else {
                        bookBrowser.portfolio_filter.openAllItems(selected_ids);
                    }
                }
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