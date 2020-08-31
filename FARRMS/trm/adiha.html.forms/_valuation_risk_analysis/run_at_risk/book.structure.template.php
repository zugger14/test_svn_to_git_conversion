<!--DOCTYPE transitional.dtd-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<meta http-equiv="X-UA-Compatible" content="IE=Edge"/>
<?php
    include '../../../adiha.php.scripts/components/include.file.v3.php';
    $php_script_loc = $app_php_script_loc;
    $app_user_loc = $app_user_name;
    $function_id = get_sanitized_value($_POST['function_id'] ?? 10181200);
    $function_id = (int) $function_id;
    $form_namespace = 'form_book_structure';
    $layout = new AdihaLayout();
    $query = $_POST['dataquery'];
    $result = readXMLURL($query);
    $sub_book = $result[0][0];
    
    $layout_json = '[
                {
                    id:             "a",
                    width:          250,
                    header:         false,
                    collapse:       false,
                    fix_size:       [false,null]
                } ]';
                
    $book_structure_layout = new AdihaLayout();
    $name_space = 'book_structure';
    echo $book_structure_layout->init_layout('book_structure_layout', '', '1C', $layout_json, $name_space);
            
    $tree_structure = new AdihaBookStructure($function_id);
    $tree_name = 'tree_book_structure';
    echo $book_structure_layout->attach_tree_cell($tree_name, 'a');
    echo $tree_structure->init_by_attach($tree_name, $name_space);
    echo $tree_structure->set_portfolio_option(2);
    echo $tree_structure->set_subsidiary_option(2);
    echo $tree_structure->set_strategy_option(2);
    echo $tree_structure->set_book_option(2);
    echo $tree_structure->set_subbook_option(2);
    echo $tree_structure->load_book_structure_data();
    echo $tree_structure->load_bookstructure_events();
    echo $tree_structure->expand_level('all');
    echo $tree_structure->enable_three_state_checkbox();
    echo $tree_structure->load_tree_functons();
	echo $tree_structure->attach_search_filter('book_structure.book_structure_layout', 'a');
    echo $book_structure_layout->close_layout();
    echo $layout->close_layout();
?>
<script type="text/javascript">
    $(function () {
        var sub_book = '<?php echo $sub_book; ?>';
        var subbook_id_arr = new Array();
        
        if(sub_book.indexOf(",") != -1) {
            subbook_id_arr = sub_book.split(',');
        } else {
            subbook_id_arr[0] = sub_book;
        }
        
        for (var i = 0; i < subbook_id_arr.length; i++) {
            book_structure.set_book_structure_node(subbook_id_arr[i], 'subbook');
            book_structure.tree_book_structure.openItem('d_' + subbook_id_arr[i]);
        }  
    });
   
</script>