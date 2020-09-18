<!--DOCTYPE transitional.dtd-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<meta http-equiv="X-UA-Compatible" content="IE=Edge"> 
<html> 
    <?php 
    include '../../include.file.v3.php';
    
    $grid_name = $_GET['grid_name'] ?? '';
    $grid_label = $_GET['grid_label'] ?? '';
    $form_name = $_GET['form_name'] ?? '';
    $browse_name = $_GET['browse_name'] ?? '';
    $callback_function = isset($_GET['callback_function']) ? $_GET['callback_function'] : '';
    $id = $_GET['id'] ?? '';
	$application_field_id = $_GET['application_field_id'] ?? '';
    $function_id = $_GET['function_id'] ?? '';
    $call_from = $_GET['call_from'] ?? '';
    $portfolio = $_GET['portfolio'] ?? '';
    $allow_sub_book_check = isset($_GET['allow_sub_book_check']) ? $_GET['allow_sub_book_check'] : 'y';
    $enable_grid_multi_select = $_GET['enable_grid_multi_select'] ?? '1';
	$single_selected_fields = $_GET['single_selected_fields'] ?? '';
    $fields_arr = explode(',', $single_selected_fields);
    
	if ($grid_name == 'book') {
		$layout_json = '[
							{
								id:             "a",
								text:           "' . ($grid_label ?? 'Generic Browse') . '",
								header:         true,
								collapse:       false,
								width:          300,
								height:			7,
								fix_size:       [true,true]
							},
							{
								id:             "b",
								text:           "Generic Browse",
								header:         false,
								collapse:       false,
								width:          300,
								fix_size:       [true,true]
							}
						]';
	} else {
		$layout_json = '[
							{
								id:             "a",
								text:           "' . ($grid_label ?? 'Generic Browse') . '",
								header:         true,
								collapse:       false,
								width:          300,
								fix_size:       [true,null]
							}
						]';
	}
    
    $toolbar_json = '[
                            {id:"ok", type:"button", img:"tick.png", imgdis: "tick_dis.gif", text:"Ok", title:"Ok", disabled: true}
                        ]';

    $namespace = 'generic_browse';
    $layout_name = 'generic_browse_layout';
    $generic_browse_layout_obj = new AdihaLayout();
	if ($grid_name == 'book') {
		echo $generic_browse_layout_obj->init_layout($layout_name, '', '2E', $layout_json, $namespace);
	} else {
		echo $generic_browse_layout_obj->init_layout($layout_name, '', '1C', $layout_json, $namespace);
	}
        
    $toolbar_name = 'generic_browser_toolbar';
    echo $generic_browse_layout_obj->attach_toolbar_cell($toolbar_name, 'a');
    $generic_browse_toolbar_obj = new AdihaToolbar();
    echo $generic_browse_toolbar_obj->init_by_attach($toolbar_name, $namespace);
    echo $generic_browse_toolbar_obj->load_toolbar($toolbar_json);
    if ($grid_name == 'book') {
        echo $generic_browse_toolbar_obj->attach_event('', 'onClick', 'generic_browser_book_click');
    } else {
        echo $generic_browse_toolbar_obj->attach_event('', 'onClick', 'generic_browser_grid_click');
    }
        
    if ($grid_name == 'book') {
        $tree_name = 'bookstructure_tree';
        echo $generic_browse_layout_obj->attach_tree_cell($tree_name, 'b');
        $book_tree_obj = new AdihaBookStructure($function_id);
        echo $book_tree_obj->init_by_attach($tree_name, $namespace);
        echo $book_tree_obj->set_portfolio_option(2);
        
        //Added for removing checkbox in sub_books
        if ($allow_sub_book_check == 'n') {
            echo $book_tree_obj->set_subbook_option(0);
        }
        
        echo $book_tree_obj->load_book_structure_data();
        echo $book_tree_obj->expand_tree('x_1');
        echo $book_tree_obj->enable_three_state_checkbox();
        echo $book_tree_obj->attach_event('', 'onCheck', 'book_item_on_check');
		echo $book_tree_obj->attach_search_filter('generic_browse.generic_browse_layout', 'b', true);
    } else {
        echo $generic_browse_layout_obj->attach_status_bar("a", true);
        echo $generic_browse_layout_obj->attach_grid_cell($grid_name, 'a');
        $acc_grid = new GridTable($grid_name);
        echo $acc_grid->init_grid_table($grid_name, $namespace);
        echo $acc_grid->set_search_filter(true);

		$disable_multi_select = array(
            'CounterpartyContactsConfirmation',
            'CounterpartyContactsPayables',
            'CounterpartyContactsReceivables'
        );
        
        if (empty($fields_arr) && !in_array($grid_name, $disable_multi_select) && !($function_id == '10101125' && $grid_name == 'deal_filter')) {
            echo $acc_grid->enable_multi_select();
        }
        
        
        echo $acc_grid->return_init();
        echo $acc_grid->load_grid_data('', $id, '', 'generic_browser_grid_select','',$application_field_id);
        echo $acc_grid->attach_event('', 'onSelectStateChanged', 'grid_row_on_click');
        echo $acc_grid->attach_event('', 'onBeforeSelect', 'grid_before_select');
        //echo $acc_grid->enable_paging(100, 'pagingArea_a', 'true');
        //Pagination in browser window doesn't retain row selected in update mode
    }
    
    echo $generic_browse_layout_obj->close_layout();
    ?> 
     
    <style>
       html, body {
           width: 100%;
           height: 100%;
           margin: 0px;
           overflow: hidden;
       }
    </style>
    <script type="text/javascript">  
        var callback_function = '<?php echo $callback_function; ?>';
        var call_from = '<?php echo $call_from; ?>';
        var portfolio = '<?php echo $portfolio; ?>';
        var allow_sub_book_check = '<?php echo $allow_sub_book_check;?>';
        var function_id = '<?php echo $function_id;?>';

        $(function() {
            var form_name = '<?php echo $form_name; ?>';
            var grid_name = '<?php echo $grid_name; ?>';
            var browse = '<?php echo $browse_name; ?>';
            
            if (call_from != 'report_manager') {
                
                if (grid_name == 'book') {
                    eval('var my_form = parent.'+form_name+'.getForm()');
              
                    if (allow_sub_book_check != 'n') {
                        var subbook_id = my_form.getItemValue("subbook_id");
                        var subbook_id_arr = subbook_id.split(',');
                        if (subbook_id != '') {
                            for (cnt = 0; cnt < subbook_id_arr.length; cnt++) {
                                generic_browse.set_book_structure_node(subbook_id_arr[cnt], 'subbook');
                                generic_browse.bookstructure_tree.openItem('d_' + subbook_id_arr[cnt]);
                            }
                        }
                    }
                    
                    var book_id = my_form.getItemValue("book_id");
                    var book_id_arr = book_id.split(',');

                    for (cnt = 0; cnt < book_id_arr.length; cnt++) {
                        if (generic_browse.bookstructure_tree.hasChildren('c_' + book_id_arr[cnt]) < 1 || subbook_id == '' || allow_sub_book_check == 'n') {
                            generic_browse.set_book_structure_node(book_id_arr[cnt], 'book');
                            generic_browse.bookstructure_tree.openItem('c_' + book_id_arr[cnt]);
                        }
                    }

                    var strategy_id = my_form.getItemValue("strategy_id");
                    var strategy_id_arr = strategy_id.split(',');
                    for (cnt = 0; cnt < strategy_id_arr.length; cnt++) {
                        if (generic_browse.bookstructure_tree.hasChildren('b_' + strategy_id_arr[cnt]) < 1) {
                            generic_browse.set_book_structure_node(strategy_id_arr[cnt], 'strategy');
                            generic_browse.bookstructure_tree.openItem('b_' + strategy_id_arr[cnt]);    
                        }
                    }

                    var subsidiary_id = my_form.getItemValue("subsidiary_id");
                    var subsidiary_id_arr = subsidiary_id.split(',');
                    for (cnt = 0; cnt < subsidiary_id_arr.length; cnt++) {
                        if (generic_browse.bookstructure_tree.hasChildren('a_' + subsidiary_id_arr[cnt]) < 1) { 
                            generic_browse.set_book_structure_node(subsidiary_id_arr[cnt], 'subsidiary');
                            generic_browse.bookstructure_tree.openItem('a_' + subsidiary_id_arr[cnt]);
                        }
                    } 
                    book_item_on_check();
                }
            } else {
                if (grid_name == 'book') {
                    var browser_id = '<?php echo $_POST['selected_id'] ?? '' ?>';
                    var browser_id_arr = browser_id.split(',');
                    
                    if (portfolio == 1) {
                        for (cnt = 0; cnt < browser_id_arr.length; cnt++) {
                            //if (generic_browse.bookstructure_tree.hasChildren('a_' + browser_id_arr[cnt]) < 1) { 
                                generic_browse.set_book_structure_node(browser_id_arr[cnt], 'subsidiary');
                                generic_browse.bookstructure_tree.openItem('a_' + browser_id_arr[cnt]);
                            //}
                        }   
                    } 
                    else if (portfolio == 2) {
                        for (cnt = 0; cnt < browser_id_arr.length; cnt++) {
                            //if (generic_browse.bookstructure_tree.hasChildren('b_' + browser_id_arr[cnt]) < 1) {
                                generic_browse.set_book_structure_node(browser_id_arr[cnt], 'strategy');
                                generic_browse.bookstructure_tree.openItem('b_' + browser_id_arr[cnt]);    
                            //}
                        }  
                    } else if (portfolio == 3) {
                        for (cnt = 0; cnt < browser_id_arr.length; cnt++) {
                            //if (generic_browse.bookstructure_tree.hasChildren('c_' + browser_id_arr[cnt]) < 1 || subbook_id == '' || allow_sub_book_check == 'n') {
                                generic_browse.set_book_structure_node(browser_id_arr[cnt], 'book');
                                generic_browse.bookstructure_tree.openItem('c_' + browser_id_arr[cnt]);
                            //}
                        }
                    } else {
                        for (cnt = 0; cnt < browser_id_arr.length; cnt++) {
                            generic_browse.set_book_structure_node(browser_id_arr[cnt], 'subbook');
                            generic_browse.bookstructure_tree.openItem('d_' + browser_id_arr[cnt]);
                        }
                    }
                    
                    book_item_on_check();
                }
            }

            if (grid_name == 'browse_counterparty') {
                generic_browse.generic_browse_layout.cells('a').getAttachedObject().enableMultiselect(true);
            }
        });
        /**
         * [Set Ok button disabled/enabled onCheck book structure nodes]
         */
        function book_item_on_check(){
            var subsidiary = generic_browse.get_subsidiary('browser');
            
            if (subsidiary == '') {
                generic_browse.generic_browser_toolbar.disableItem('ok');
            } else {
                generic_browse.generic_browser_toolbar.enableItem('ok');
            }
        }
        /**
         * [Set Ok button disabled/enabled onCheck book structure nodes]
         */
        function grid_row_on_click(){
            var obj = generic_browse.generic_browse_layout.cells('a').getAttachedObject();
            var selected_row = obj.getSelectedRowId();
            
            if (selected_row != null) {
                generic_browse.generic_browser_toolbar.enableItem('ok');
            } else {
                generic_browse.generic_browser_toolbar.disableItem('ok');
            }
        }
        
        function grid_before_select(new_row, old_row, new_col_index) {
            var obj = generic_browse.generic_browse_layout.cells('a').getAttachedObject();
            
            var status_index = obj.getColIndexById("status");
            if (status_index != undefined) {
                var status = obj.cells(new_row, status_index).getValue();
                if (status.toLowerCase() == 'disable')
                    return false;
                else
                    return true;
            } else {
                return true;
            }
        }
        /**
         *
         */
        function generic_browser_grid_select() {
            var form_name = '<?php echo $form_name; ?>';
            var browse = '<?php echo $browse_name; ?>';
            
            if (call_from != 'report_manager' && call_from != 'grid_browser') {
                eval('var my_form = parent.' + form_name + '.getForm();');

                var browse_field = browse.replace("label_", "");
				var label_name = my_form.getItemValue(browse);
                var selected_id = my_form.getItemValue(browse_field);
            } else {
                var selected_id = '<?php echo $_POST['selected_id'] ?? '' ?>';
                var label_name = '<?php echo $_POST['selected_label'] ?? '' ?>';
            }
            
            selected_id = selected_id.split(",");
            label_name = unescapeXML(label_name);
            label_name = label_name.split(",");
            
            var grid_obj = generic_browse.generic_browse_layout.cells('a').getAttachedObject();

            grid_obj.forEachRow(function(id){
				var a = grid_obj.cells(id, 0).getValue();
				var b = grid_obj.cells(id, 1).getValue();
                if (selected_id.indexOf(a) > -1 && label_name.indexOf(unescapeXML(b)) > -1){
                    grid_obj.selectRow(id, true, true, true);
                }
            });
        }
        
        function generic_browser_grid_click() {
            var obj = generic_browse.generic_browse_layout.cells('a').getAttachedObject();
            var selected_row = obj.getSelectedRowId();
            
            var form_name = '<?php echo $form_name; ?>';
            var browse = '<?php echo $browse_name; ?>';
            var input_id = browse.replace("label_", "");
            var input_label = browse.replace("browse_", "label_");

            if (selected_row == null) {
                var selected_row_arr = new Array();
            } else {
                var selected_row_arr = selected_row.split(',');
            }
            
            var selected_id_arr = new Array();
            var selected_value_arr = new Array();
            var selected_formula = new Array();

            for (var cnt = 0; cnt < selected_row_arr.length; cnt++) {
                var grid_name = '<?php echo $grid_name; ?>';
                var selected_id = obj.cells(selected_row_arr[cnt], '0').getValue();
                var selected_value = obj.cells(selected_row_arr[cnt], '1').getValue();
                var formula_details = (grid_name == 'formula_editor') ? obj.cells(selected_row_arr[cnt], '3').getValue() : '';

                selected_id_arr.push(selected_id);
                selected_value_arr.push(selected_value);
                selected_formula.push(formula_details); 
            }
            
            if (call_from == 'report_manager') {
                parent.set_browser_value(selected_id_arr.join(','), selected_value_arr.join(','));
            } else if (call_from == 'grid_browser') {
                parent.new_browse.new_browse_value = {"value": selected_id_arr, "text": unescapeXML(selected_value_arr.join(','))}
                parent.new_browse.close();
                return;
            } else {
                eval('var my_form = parent.'+form_name+'.getForm()');
                my_form.setItemValue(input_id, selected_id_arr.join(','));
                my_form.setItemValue(input_label, unescapeXML(selected_value_arr.join(',')));

                if (grid_name == 'formula_editor') 
                    parent.set_formula(unescapeXML(selected_formula.join(',')).replace(/\+/g, ' '));   
                                
                my_form.setNote(input_id,{text:""});
            }
            //parent.new_browse.close();
            parent.new_browse.setModal(false);
            parent.new_browse.hide();
            
            //Trigger callback function if defined.
            if (Boolean(callback_function)) {
                eval('parent.' + callback_function + '("' + input_id  +'")');
            }    
             
        }
        
        function generic_browser_book_click() {
            var subsidiary = generic_browse.get_subsidiary('browser');
            var strategy = generic_browse.get_strategy('browser');
            var book = generic_browse.get_book('browser');
            var sub_book = generic_browse.get_subbook();

            var subsidiary_label = generic_browse.get_subsidiary_label('browser');
            var strategy_label = generic_browse.get_strategy_label('browser');
            var book_label = generic_browse.get_book_label('browser');
            var sub_book_label = generic_browse.get_subbook_label();
            
            if (subsidiary_label == "") { subsidiary_label = "NULL"; }
            if (strategy_label == "") { strategy_label = "NULL"; }
            if (book_label == "") { book_label = "NULL"; }
            if (sub_book_label == "") { sub_book_label = "NULL"; }
            
            var form_name = '<?php echo $form_name; ?>';
            var browse = '<?php echo $browse_name; ?>';
            
            if (call_from == 'report_manager') {
                if (portfolio == 1) {
                    parent.set_browser_tree_value(subsidiary, subsidiary_label);   
                } else if (portfolio == 2) {
                    parent.set_browser_tree_value(strategy, strategy_label);  
                } else if (portfolio == 3) {
                    parent.set_browser_tree_value(book, book_label);  
                } else {
                    parent.set_browser_tree_value(sub_book, sub_book_label);  
                }
            } else {
                eval('var my_form = parent.'+form_name+'.getForm()');
            
                my_form.setItemValue("subsidiary_id", subsidiary);
                my_form.setItemValue("strategy_id", strategy);
                my_form.setItemValue("book_id", book);
                my_form.setItemValue("subbook_id", sub_book);
                
                var all_book = subsidiary_label + '||' + strategy_label + '||' + book_label + '||' + sub_book_label
                my_form.setItemValue(browse.replace("browse_", ""), all_book);
                my_form.setNote("book_structure",{text:""});
            }
            
            //Trigger callback function if defined.
            if(Boolean(callback_function)) {
                eval('parent.' + callback_function + '()');
            }            
            
            //parent.new_browse.close();
            // Changed window close() to hide() to fix issue in input field not clicking on browser close
            parent.new_browse.setModal(false);
            parent.new_browse.hide();
        }
    </script> 
