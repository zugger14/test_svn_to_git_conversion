<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
<body>
<?php 
	$form_namespace = 'menu_book_structure';
    $grid_name = 'menu_book_structure';
    $grid_label = 'Book Structure';
    $form_name = 'frm_book_structure';
    $function_id = '10233700'; //(isset($_POST["function_id"]) && $_POST["function_id"] != '') ? $_POST["function_id"] : 'NULL';
    

    $layout_json = '[
                        {
                            id:             "a",
                            text:           "Generic Browse",
                            header:         true,
                            collapse:       false,
                            width:          300,
                            fix_size:       [true,null]
                        }
                    ]';
    
    $toolbar_json = '[
                            {id:"ok", type:"button", img:"tick.png", text:"Ok", title:"Ok"}
                        ]';

    $namespace = 'ph';
    $layout_name = 'ph_layout';
    $generic_browse_layout_obj = new AdihaLayout();
    echo $generic_browse_layout_obj->init_layout($layout_name, '', '1C', $layout_json, $namespace);
    echo $generic_browse_layout_obj->set_text('a', $grid_label);
        
    $toolbar_name = 'ph_toolbar';
    echo $generic_browse_layout_obj->attach_toolbar_cell($toolbar_name, 'a');
    $generic_browse_toolbar_obj = new AdihaToolbar();
    echo $generic_browse_toolbar_obj->init_by_attach($toolbar_name, $namespace);
    echo $generic_browse_toolbar_obj->load_toolbar($toolbar_json);
    echo $generic_browse_toolbar_obj->attach_event('', 'onClick', 'select_book_detail');
            
    $tree_name = 'bookstructure_tree';
    echo $generic_browse_layout_obj->attach_tree_cell($tree_name, 'a');
    $book_tree_obj = new AdihaBookStructure($function_id);
    echo $book_tree_obj->init_by_attach($tree_name, $namespace);
    echo $book_tree_obj->set_subsidiary_option(0);
    echo $book_tree_obj->set_strategy_option(0);
    echo $book_tree_obj->set_book_option(1);
    echo $book_tree_obj->set_subbook_option(0);
    echo $book_tree_obj->load_book_structure_data();
    echo $book_tree_obj->expand_tree('x_1');
    echo $book_tree_obj->enable_three_state_checkbox();
    
    echo $generic_browse_layout_obj->close_layout();
?>
</body>
<textarea style="display:none" name="close_status" id="close_status">btnClose</textarea>
<input type="text" name="book_id" id="book_id">
<input type="text" name="book_name" id="book_name">

<script type="text/javascript">
   
    function select_book_detail() {
            var subsidiary = ph.get_subsidiary('browser');
            var strategy = ph.get_strategy('browser');
            var book = ph.get_book('browser');
            var sub_book = ph.get_subbook();
             
            var subsidiary_label = ph.get_subsidiary_label('browser');
            var strategy_label = ph.get_strategy_label('browser');
            var book_label = ph.get_book_label('browser');
            var sub_book_label = ph.get_subbook_label();
            
            if (subsidiary_label == "") { subsidiary_label = "NULL"; }
            if (strategy_label == "") { strategy_label = "NULL"; }
            if (book_label == "") { book_label = "NULL"; }
            if (sub_book_label == "") { sub_book_label = "NULL"; }
            
            document.getElementById("close_status").value = 'btnOk';
            document.getElementById("book_id").value = book;
            document.getElementById("book_name").value = book_label;
            
            //TODO subsidiary and strategy ids are not loaded.

            var win_obj = parent.status_window.window("w1");
            win_obj.close();
              
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