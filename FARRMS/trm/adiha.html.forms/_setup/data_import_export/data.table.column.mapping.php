<?php

/**
* Data table column mapping screen
* @copyright Pioneer Solutions
*/
?>
<!--DOCTYPE transitional.dtd-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<meta http-equiv="X-UA-Compatible" content="IE=Edge">
<html>

<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
    <link rel="stylesheet" href="<?php echo $app_php_script_loc; ?>components/jQuery/jquery-ui.css"/>
    <script src="<?php echo $app_php_script_loc; ?>components/jQuery/jquery-ui.js"></script>
</head>

<?php
//settting values on local variables
$table_id = get_sanitized_value($_GET['tables_id'] ?? 'NULL'); 
$rules_id = get_sanitized_value($_GET['rules_id'] ?? 'NULL');
$mode = get_sanitized_value($_GET['mode'] ?? 'i'); 
$data_source = get_sanitized_value($_GET['data_source'] ?? ''); 
$process_id = get_sanitized_value($_GET['process_id'] ?? ''); 
$connection_string = get_sanitized_value($_GET['connection_string'] ?? ''); 
$repeat_number = isset($_GET['repeat_number']) ? get_sanitized_value($_GET['repeat_number']) : 0;
$customized_import_table = isset($_GET['customized_import_table']) ? get_sanitized_value($_GET['customized_import_table']) : 'n';
$data_source_id = get_sanitized_value($_GET['data_source_id'] ?? 'NULL'); 
$import_process_table = get_sanitized_value($_GET['import_process_table'] ?? 'NULL'); 
$alias = get_sanitized_value($_GET['alias'] ?? 'NULL'); 
$row_index = get_sanitized_value($_GET['row_index'] ?? 'NULL'); 
?>
<?php
/*         * ************************************Combo json preparation************************************* */
/*
 * Function to create combo json for Form.
 * @param: $array: array of the combo with value and text
 * @param: $combo_id: selected value [optional]
 * @param: $value_index: index of the value
 * @param: $text_index: index of the text
 *
 */
//To seperate first load case and update case mode is changed
if ($rules_id != 1) {
    $mode = 'u';
}

function create_template_combo_json($array, $combo_id, $value_index, $text_index)
{
    $option = '{options:[';
    for ($i = 0; $i < sizeof($array); $i++) {
        if ($i > 0)
            $option.=',';
        $option .= '{text:"' . str_replace('"', '\"', $array[$i][$text_index]) . '", value:"' . str_replace('"', '\"', $array[$i][$value_index]) . '"';

        if ($combo_id == $array[$i][$value_index]) {
            $option .= ', selected:"true"}';
        }

        $option .= '}';
    }
    $option .= ']}';
    return ($option);
}
?>
<?php
//frontend server-side logics
$ixp_column_aggregation_option = array(
    array(' ', ''),
    array('Avg', 'Avg'),
    array('Count', 'Count'),
    array('Max', 'Max'),
    array('Min', 'Min')
);
$aggregation_combo_json = create_template_combo_json($ixp_column_aggregation_option, '', 0, 1);

if ($customized_import_table) {
    $data_source = "EXEC spa_ixp_import_data_source @flag='t',@process_id='" . $process_id . "',@import_data_source_id=" . $data_source_id;
    $data_source_array = readXMLURL($data_source);
    $temp_table_name = $data_source_array[0][0];
} else {
    $temp_table_name = '';
}

# Accquire mapping data from ixp_import_data_mapping and create a new array w.r.t source table column.
if ($data_source == 'link_server') {
    $xml_temp_table_columns = "EXEC spa_ixp_import_data_mapping @flag='q', @ixp_table_id=" . $table_id . " , @process_id = '" . $process_id . "' ,@connection_string = '" . $connection_string . "', @ixp_rules_id=" . $rules_id . ",@repeat_number=" . $repeat_number;
    $temp_table_columns_array = readXMLURL2($xml_temp_table_columns);
	$data_load_query = $xml_temp_table_columns;
} else {
    if ($temp_table_name == '' && $customized_import_table == 0) {
        if ($data_source == 'ssis' || $data_source == 'web' ) {
            $temp_table_name = str_replace('adiha_process.dbo.', '', $import_process_table);
        }  else if ($data_source =='lse'){
            $temp_table_name = 'temp_import_data_table_'.$alias.'_' . $process_id;
        } else {
            $temp_table_name = 'temp_import_data_table_' . $process_id;
        }
    }

    $xml_temp_table_columns = "EXEC spa_ixp_import_data_mapping @flag='s', @ixp_table_id=" . $table_id . " , @process_id = '" . $process_id . "' ,@temp_process_table = '" . $temp_table_name . "', @ixp_rules_id=" . $rules_id . ",@repeat_number=" . $repeat_number. ",@row_index=" . $row_index;
    $temp_table_columns_array = readXMLURL2($xml_temp_table_columns);
	$data_load_query = "EXEC spa_ixp_import_data_mapping @flag='g', @ixp_table_id='" . $table_id . "', @ixp_rules_id=" . $rules_id;
}
$size_of_temp_source = sizeof($temp_table_columns_array);
$source_combo_json = create_template_combo_json($temp_table_columns_array, $xml_temp_table_columns, 'source_column_name', 'source_column_name');

# Resolve destination table name and create arry of its columns.
$xml_physical_table_name = "EXEC spa_import_table_template @flag='c',@table_id=" . $table_id . ", @process_id='" . $process_id . "', @repeat_number=" . $repeat_number;
$physical_table_name_array = readXMLURL($xml_physical_table_name);
$physical_table_name = $physical_table_name_array[0][0];
//echo $physical_table_name = str_replace($database_process . '.dbo.', '', $physical_table_name);

$physical_table_columns = array();
$xml_physical_table_columns = "EXEC spa_ixp_import_data_mapping @flag='a',@ixp_table_id=" . $table_id;
$physical_table_columns = readXMLURL($xml_physical_table_columns);
$dest_combo_json = create_template_combo_json($physical_table_columns, $xml_physical_table_columns, 0, 1);
$major_columns = array();
if (is_array($physical_table_columns) && sizeof($physical_table_columns) > 0) {
    foreach ($physical_table_columns as $physical) {
        if ($physical[2] == 1) {
            array_push($major_columns, array($physical[0], $physical[1]));
        }
    }
}
$major_columns_jsoned = json_encode($major_columns);

# Resolve linked datasoures and creates array of datasources and columns.
$linked_datasource = array();
if ($mode == 'u' && $row_index != 0) {
    $xml_linked_datasource = "EXEC spa_ixp_import_relation @flag='w',@process_id='" . $process_id . "' ,@rules_id=" . $rules_id . ", @table_id =" .$table_id;
    $linked_datasource = readXMLURL2($xml_linked_datasource);
} else if ($mode == 'i' && $row_index != 0) {
    $xml_linked_datasource = "EXEC spa_ixp_import_relation @flag='s',@process_id='" . $process_id . "' ,@rules_id=" . $rules_id. ",@row_index=" . $row_index;
    $linked_datasource = readXMLURL2($xml_linked_datasource);
}
//print_r($linked_datasource);
$linked_datasource_header_init = 'Import File Column,Destination Table Column,Column Function,Aggregation,Required';
$linked_datasource_column_id_init = 'source_column_name,dest_column,column_function,column_aggregation,required';
$linked_datasource_column_types_init = 'combo,combo,txt,combo,ro';
$linked_datasource_column_width_init = '200,200,200,200,100';
$linked_datasource_header = $linked_datasource_header_init;
$linked_datasource_column_id = $linked_datasource_column_id_init;
$linked_datasource_column_types = $linked_datasource_column_types_init;
$linked_datasource_column_width = $linked_datasource_column_width_init;
$linked_datasource_column_visibility = 'false,false,false,false,true';
$i = 0;
$has_join_column = sizeof($linked_datasource);
foreach ($linked_datasource as $link) {
    // if($i!=0){
    $linked_datasource_header .=',';
    $linked_datasource_column_id .=',';
    $linked_datasource_column_types .=',';
    $linked_datasource_column_width .=',';
    $linked_datasource_column_visibility .=',';

    // }
    $linked_datasource_header .='Join (' . ($link['alias']) . ') on:';
    $linked_datasource_column_id .=($link['alias']);
    if ($mode == 'u') {
        $linked_datasource_column_types .='ro';
        $linked_datasource_column_visibility .= 'true';
    } else {
        $linked_datasource_column_types .='combo';
        $linked_datasource_column_visibility .= 'false';
    }

    $linked_datasource_column_width .='200';
    $i++;
}
//echo $linked_datasource_header."\n".$linked_datasource_column_id."\n".$linked_datasource_column_types."\n".$linked_datasource_column_width;
$linked_datasource_columns_array = array();
// for ($i = 0; $i < sizeof($linked_datasource); $i++) {
//     if ($linked_datasource[$i][type] == 21400 || $linked_datasource[$i][type] == 21405 || $linked_datasource[$i][type] == 21406) {
//         $linked_datasource[$i][relation] = 'adiha_process.dbo.temp_import_data_table_' . $linked_datasource[$i][alias] . '_' . $process_id;
//     }

//     $xml_linked_datasource_column = "EXEC spa_ixp_import_relation @flag='x', @process_id='" . $process_id . "', @connection_string='" . $linked_datasource[$i][relation] . "', @relation_id=" . $linked_datasource[$i][ixp_import_relation_id];
//     $linked_datasource_columns = readXMLURL2($xml_linked_datasource_column);
//     $linked_datasource_columns_combo_json = create_template_combo_json($linked_datasource_columns, $xml_linked_datasource_column, 'column_name', 'column_name');
// }

$joined_columns = array();
$xml_joined_columns = "EXEC spa_ixp_import_relation @flag='y',@process_id='" . $process_id . "', @rules_id=" . $rules_id;
//echo $xml_joined_columns = $app_php_script_loc . 'spa_ixp_import_relation.php?flag=y&process_id=' . $process_id . '&rules_id=' . $rules_id;
$joined_columns = readXMLURL2($xml_joined_columns);

$xml_where_clause = "EXEC spa_ixp_import_where_clause @flag='s', @process_id='" . $process_id . "', @rules_id=" . $rules_id . ", @table_id=" . $table_id;
$return_clauses = readXMLURL2($xml_where_clause);
$where_clause = $return_clauses[0]['where_clause'];

$join_clause_sql = "EXEC spa_ixp_import_relation @flag='q', @process_id='" . $process_id . "', @rules_id=" . $rules_id . ", @row_index=" . $row_index;
//echo $xml_joined_columns = $app_php_script_loc . 'spa_ixp_import_relation.php?flag=y&process_id=' . $process_id . '&rules_id=' . $rules_id;
$join_clause_data = readXMLURL2($join_clause_sql);
$join_clause = $join_clause_data[0]['join_clause'] ?? '';
$ixp_import_relation_id = $join_clause_data[0]['ixp_import_relation_id'] ?? '';
?>
<?php
$php_script_loc = $app_php_script_loc;
$app_user_loc = $app_user_name;
/* start of main layout */
$form_namespace = 'data_column_mapping_ixp';
$layout = new AdihaLayout();
//json for main layout.
/* start */
$json = '[
            {
                id:             "a",
                text:           "form",
                header:         false,
                collapse:       false,
                height:         7,
                fix_size:       [null,true]
            }, 
            
            {
                id:             "b",
                text:           "Tables",
                header:         false,
                collapse:       false
            }, 

            {
                id:             "c",
                text:           "Where Clause",
                header:         true,
                collapse:       true,
                height:         120  
            }, 

            {
                id:             "d",
                text:           "Note : Join Clause",
                header:         true,
                collapse:       false,
                height:         100
                
            }
            
           
        ]';
/* end */
$toolbar_json = '[
                       {id:"add", type:"button", img:"new.gif", text:"Add", title:"Add"},
                       {id:"remove", type:"button", img:"trash.gif", imgdis:"trash_dis.gif", text:"Delete", title:"Delete" }
                   ]';
//attach main layout of the screen
echo $layout->init_layout('new_layout', '', '4E', $json, $form_namespace);

echo $layout->set_cell_height('a', 10);
$save_json = '[
                        {id:"ok", type:"button", img:"tick.png", text:"OK", title:"ok" , position:"absolute"}
                    ]';

echo $layout->attach_toolbar_cell('toolbar_save', 'a');
$toolbar_obj = new AdihaToolbar();
echo $toolbar_obj->init_by_attach('toolbar_save', $form_namespace);
echo $toolbar_obj->load_toolbar($save_json);
echo $toolbar_obj->attach_event('', 'onClick', 'data_column_mapping_ixp.toolbar_click');


$toolbar_name = 'data_column_toolbar';
echo $layout->attach_toolbar_cell($toolbar_name, "b");
$column_toolbar = new AdihaToolbar();
echo $column_toolbar->init_by_attach($toolbar_name, $form_namespace);
echo $column_toolbar->load_toolbar($toolbar_json);
echo $column_toolbar->attach_event('', 'onClick', 'data_column_mapping_ixp.toolbar_onclick');
//First grid
$first_grid_name = 'column_mapping_grid';
$first_grid_spa = $data_load_query;
echo $layout->attach_grid_cell($first_grid_name, "b");
$first_grid = new AdihaGrid();
echo $first_grid->init_by_attach($first_grid_name, $form_namespace);
//echo '</script>';
echo $first_grid->set_header($linked_datasource_header);
echo $first_grid->set_columns_ids($linked_datasource_column_id);
echo $first_grid->set_column_types($linked_datasource_column_types);
echo $first_grid->set_widths($linked_datasource_column_width);
echo $first_grid->set_search_filter(true);
echo $first_grid->enable_multi_select();
echo $first_grid->load_grid_data($first_grid_spa, $grid_type = 'g','',false,'mapping_grid_callback');
echo $first_grid->set_column_visibility($linked_datasource_column_visibility);
//echo $first_grid->attach_event('', 'onRowSelect', 'data_table_ixp.second_grid_refresh');
echo $first_grid->return_init();
//Button form
$button_form_name = 'button_form_name';
$hide_join_clause = ($mode == 'i' || $row_index == 0)?'true':'false';
$form_json = '[
                       {"type":"settings","position":"label-top",inputWidth:900},{type: "block", blockOffset: 10,  list:[
                       {type:"input",name:"join_clause", label:"Join Clause",position:"label-top","inputWidth":400, rows:3, value:"'.$join_clause.'"},
					   {type:"newcolumn"},
                       {type:"input",name:"where_clause",label:"Where Clause",position:"label-top","offsetLeft":20,"inputWidth":400, rows:3, value:"'.$where_clause.'"}]}
                    ]';

echo $layout->attach_form($button_form_name, "c");
$filter_form_obj = new AdihaForm();
echo $filter_form_obj->init_by_attach($button_form_name, $form_namespace);
echo $filter_form_obj->load_form($form_json);

$note_form_name = 'form_note';
$form_json = '
                [
            {"type":"settings", "position":""},
            {
                "type": "block",
                "offsetTop": 0,
                "blockOffset": 5,
                "list":[
                    {
                        "type": "label",
                        "label": "Insert Mode :- Use join column mapping present in grid. Update mode :- Use join clause textbox.",
                        "position": "label-top",
                        "offsetLeft": "10",
                        "inputTop": "0",
                        "labelWidth": "auto",
                        "inputWidth": "250"
                    }
                ]
            }
        ]';
$button_form_name = 'button_form_name1';
echo $layout->attach_form($button_form_name, "d");
$filter_form_obj = new AdihaForm();
echo $filter_form_obj->init_by_attach($button_form_name, $form_namespace);
echo $filter_form_obj->load_form($form_json);
// $button_form_name = 'button_form_name';
// $form_json = '[
//                {type:"block", name:"data", width: 800,label:"", inputWidth:"auto", list:[
//                     {type:"button",   name:"ok", offsetLeft:0, value:"OK"},
//                     {type:"newcolumn"},
//                     {type:"button",   name:"close", offsetLeft:0, value:"Close"}
//                 ]
//                 }
//             ]';

// echo $layout->attach_form($button_form_name, "a");
// $filter_form_obj = new AdihaForm();
// echo $filter_form_obj->init_by_attach($button_form_name, $form_namespace);
// echo $filter_form_obj->load_form($form_json);

echo $layout->close_layout();
/* end of main layout */
?>
<link rel="stylesheet" href="<?php echo $app_php_script_loc; ?>components/jQuery/jquery-ui.css"/>
<link href="../../../main.menu/bootstrap-3.3.1/dist/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
<script src="<?php echo $app_php_script_loc; ?>components/jQuery/jquery-ui.js"></script>
<script>
    source_combo_json = <?php echo $source_combo_json; ?>;
    dest_combo_json = <?php echo $dest_combo_json; ?>;
    aggregation_combo_json = <?php echo $aggregation_combo_json; ?>;
    var major_array = <?php echo $major_columns_jsoned; ?>;
    var rules_id = '<?php echo $rules_id; ?>';
    var table_id = '<?php echo $table_id; ?>';
    var repeat_number = '<?php echo $repeat_number; ?>';
    var linked_datasource_columns_combo_json;
    var major_array = <?php echo $major_columns_jsoned; ?>;
    var destination_array = new Array();
    var process_id = '<?php echo $process_id; ?>';
    var session_id = '<?php echo $session_id; ?>';
    var mode = '<?php echo $mode; ?>';
    var join_clause = '<?php echo $join_clause; ?>';
    var row_index = '<?php echo $row_index; ?>';
    var ixp_import_relation_id = '<?php echo $ixp_import_relation_id; ?>';
    var has_join_column = '<?php echo $has_join_column; ?>';
    var temp_textbox_string = '';
	var required_color = '#ffffcc';
	var not_required_color = '#ffffff';
	var size_of_temp_source = '<?php echo $size_of_temp_source; ?>';
	
    $(function() {
        //loading the combo option of source column.
        var column_object_source_column = data_column_mapping_ixp.column_mapping_grid.getColumnCombo("0");
        column_object_source_column.load(source_combo_json);
        column_object_source_column.enableFilteringMode("between", null, false);
        //loading the combo option of destination column.
        var column_object_dest_column = data_column_mapping_ixp.column_mapping_grid.getColumnCombo("1");
        column_object_dest_column.load(dest_combo_json);
        column_object_dest_column.enableFilteringMode("between", null, false);
        //loading the combo option of aggregation column.
        var column_object_agg_column = data_column_mapping_ixp.column_mapping_grid.getColumnCombo("3");
        column_object_agg_column.load(aggregation_combo_json);
        column_object_agg_column.enableFilteringMode("between", null, false);
        //loading the combo option of linked_datasource column.

        //loading linked datasource JSON combo options.
        <?php

        $join_clause_columns_array = array();
        for ($i = 0; $i < sizeof($temp_table_columns_array); $i++) {
            array_push($join_clause_columns_array,$temp_table_columns_array[$i]['source_column_name']);
        }
        $j = 4;
        foreach ($linked_datasource as $link) {
        $i = $j - 4; //$i =0;
        if ($mode == 'u') {
            $xml_linked_datasource_column =  "EXEC spa_ixp_import_relation @flag='z', @table_id=" . $table_id . " , @process_id = '" . $process_id . "', @rules_id=" . $rules_id .",@relation_alias= '" . $linked_datasource[$i][alias] ."'" ;
            $linked_datasource_columns = readXMLURL2($xml_linked_datasource_column);
            $linked_datasource_columns_combo_json = create_template_combo_json($linked_datasource_columns, $xml_linked_datasource_column, 'column_name', 'column_name');
        } else {
            if ($linked_datasource[$i][type] == 21400 || $linked_datasource[$i][type] == 21405 || $linked_datasource[$i][type] == 21406) {
                $linked_datasource[$i][relation] = 'adiha_process.dbo.temp_import_data_table_' . $linked_datasource[$i][alias] . '_' . $process_id;
            }

            $xml_linked_datasource_column = "EXEC spa_ixp_import_relation @flag='x', @process_id='" . $process_id . "', @connection_string='" . $linked_datasource[$i][relation] . "', @relation_alias='" . $linked_datasource[$i][alias]."'";
            $linked_datasource_columns = readXMLURL2($xml_linked_datasource_column);
            $linked_datasource_columns_combo_json = create_template_combo_json($linked_datasource_columns, $xml_linked_datasource_column, 'column_name', 'column_name');
        }

        for ($i = 0; $i < sizeof($linked_datasource_columns); $i++) {
            array_push($join_clause_columns_array,$linked_datasource_columns[$i]['column_name']);
        }
        ?>
        linked_datasource_columns_combo_json = '<?php echo $linked_datasource_columns_combo_json; ?>';
        column_object_linked_datasource_column = data_column_mapping_ixp.column_mapping_grid.getColumnCombo(<?php echo $j; ?>);
        column_object_linked_datasource_column.load(linked_datasource_columns_combo_json);
        column_object_linked_datasource_column.enableFilteringMode("between", null, false);
        // var obj = $.parseJSON(linked_datasource_columns_combo_json);


        <?php $j++;
        } ?>
        var $join_clause = $("textarea[name='join_clause']");
        //$join_clause.css("display","none");
        // $join_clause.css
        var height_join_clause = $join_clause.height();
        var width_join_clause = $join_clause.width();
        //$join_clause.after("<div id='div_join_clause' class='dhxform_textarea data-import-textdiv' contentEditable='true' style='margin-top: 10px;background-color: white'></div> ");

        var $div_join_clause = $('#div_join_clause');
        //$div_join_clause.height(height_join_clause);
        //$div_join_clause.width(width_join_clause + 8);
        //$div_join_clause.html(join_clause);

        // data_column_mapping_ixp.column_mapping_grid.setColumnMinWidth(min_width);
        data_column_mapping_ixp.column_mapping_grid.setColWidth(0,"*");
        data_column_mapping_ixp.column_mapping_grid.setColWidth(1,"*");
        data_column_mapping_ixp.column_mapping_grid.setColWidth(2,"*");
        data_column_mapping_ixp.column_mapping_grid.setColWidth(3,"*");

        data_column_mapping_ixp.button_form_name.attachEvent("onChange", function (name, value, state){
            if (name == 'join_clause')
                join_clause = data_column_mapping_ixp.button_form_name.getItemValue('join_clause');
        });
        var join_clause_columns_array = [<?php echo '"'.implode('","', $join_clause_columns_array).'"' ?>];

        /* For Autocomplete */
        function split(val) {
            // return val.split(/@\s*/);
            return val.split('@');
        }

        function split1(val) {
            var res = val.split(" ");
            return res[0];
        }

        function split_pre(val) {
            var res = val.split(/@\s*/);
            var p_val = res[0];
            var p_val_arr = p_val.split(" ");
            return p_val_arr[p_val_arr.length - 1];
        }

        var arg1 = '';
        var arg2 = '';
        //Return the value for matching in autocomplete dropdown
        function extractLast(term) {
            var s_val = 'abcdefgh';
            if(term.indexOf('@') > -1) {
                temp_textbox_string = split(term);
                var all_val = split(term).pop();
                arg1 = split_pre(term);
                if (term != '@') {
                    s_val = split1(all_val);
                }
            }
            arg2 = s_val;
            return s_val.trim();
        }

        $div_join_clause
        // don't navigate away from the field on tab when selecting an item
            .bind( "keydown", function(event) {
                if ( event.keyCode === $.ui.keyCode.TAB &&
                    $(this).autocomplete("instance").menu.active) {
                    event.preventDefault();
                }
            })

            .autocomplete({
                minLength: 1,
                source: function(request, response) {
                    // delegate back to autocomplete, but extract the last term
                    response( $.ui.autocomplete.filter(
                        join_clause_columns_array, extractLast(request.term)
                    ));
                },

                focus: function() {
                    // prevent value inserted on focus
                    return false;
                },

                select: function(event, ui) {
                    var find_current = $(this).find('.current').attr('class'); // Current class to identify the recently selected join column name
                    if (find_current == 'current') {
                        $(this).find('.current').remove();
                    }
                    //Breakdown the join column name textarea content into two part when dropdown is selected, First-Content untill the selected, Second-Content after the selected
                    var arr = split($(this).html());
                    var pop_item = arr.pop();
                    var pop_arr = pop_item.split(' ');
                    var new_pop_arr = '';

                    for (i = 1; i < pop_arr.length; i++) {
                        new_pop_arr = new_pop_arr + ' ' + pop_arr[i];
                    }
                    replace_text = '<a href="mailto:' + arg1 + ',' + arg2 + '">';
                    arr = arr.toString().replace(replace_text, '');
                    //Append the content untill the selected
                    $(this).html(arr);
                    //Append the selected join column name
                    var alias_name = ui.item.value;
                    //Append the content after selected
                    $div_join_clause.text(temp_textbox_string[0] + alias_name);
                    setEndOfContenteditable(this); //Set text cursor to end
                    $div_join_clause.append(temp_textbox_string[1].replace(arg2.trim(),''));
                    return false;
                }
            });
        /* End for Autocomplete */

        $div_join_clause.autocomplete( "option", "position", {
            my: "left top",
            at: "left+" + 5000 + " top+" + 5000
        });

        //For positioning of the autocomplete dropdowm
        $div_join_clause.keydown(function(event){
            if (event.which == 46) return;
            if (event.which != 37 && event.which != 38 && event.which != 39 && event.which != 16) {
                if (!event.ctrlKey) {
                    html_at_caret('<span class="for_offset">T</span>', false); // for_offset class to find the offset position for autocomplete dropdown
                    x_offset = $('.for_offset').offset().left;
                    y_offset = $('.for_offset').offset().top;
                    x_offset = (x_offset - $(this).offset().left) * 0.70;
                    y_offset = y_offset - $(this).offset().top + 20;

                    $div_join_clause.autocomplete( "option", "position", {
                        my: "left top",
                        at: "left+" + x_offset + " top+" + y_offset
                    });

                    $div_join_clause.find('.for_offset').remove();
                }
            }
        });
		
		
		data_column_mapping_ixp.new_layout.attachEvent("onExpand", function(name){
			if (name == 'c') {
				data_column_mapping_ixp.new_layout.cells('d').collapse();
			}
			
			if (name == 'd') {
				data_column_mapping_ixp.new_layout.cells('c').collapse();
				data_column_mapping_ixp.new_layout.cells('d').expand();
			}
		});
        var note_title = "<i class='glyphicon glyphicon-info-sign'></i> " + data_column_mapping_ixp.new_layout.cells('d').getText();
        data_column_mapping_ixp.new_layout.cells('d').setText(note_title);
	});

    data_column_mapping_ixp.toolbar_click = function(id) {
		var required_empty = 0;
		var dest_column_blank = 0;
		var source_column_arr = new Array();
        data_column_mapping_ixp.column_mapping_grid.clearSelection();
		data_column_mapping_ixp.column_mapping_grid.forEachRow(function(id){
			var is_required = data_column_mapping_ixp.column_mapping_grid.cells(id,4).getValue();
			var source_column = data_column_mapping_ixp.column_mapping_grid.cells(id,0).getValue();	
			var default_column = data_column_mapping_ixp.column_mapping_grid.cells(id,2).getValue();	
			
			if (is_required ==1 && source_column == '' && default_column == '') {
				required_empty = 1;
			}
		});
		
		if (required_empty == 1) {
			show_messagebox('Some required columns are not mapped. Please check.');
			return;
		}
		var udf_count = 0;
        data_column_mapping_ixp.column_mapping_grid.filterBy(0,"");
        grid_ids = data_column_mapping_ixp.column_mapping_grid.getAllRowIds();
        var changed_ids = new Array();
        grid_xml = '<Root>';
        changed_ids = grid_ids.split(",");
        $.each(changed_ids, function(index, value) {
			var mapped_source = data_column_mapping_ixp.column_mapping_grid.cells(value, 0).getValue();
			var mapped_default = data_column_mapping_ixp.column_mapping_grid.cells(value, 2).getValue();
			
			if (mapped_source != '' || mapped_default !='') {
				grid_xml += '<PSRecordset Rules="' + rules_id + '" Table="' + table_id + '"';
				k = row_index;
				dest_xml = '';
			
			
				for (var cellIndex = 0; cellIndex < data_column_mapping_ixp.column_mapping_grid.getColumnsNum(); cellIndex++) {
					cell_value = data_column_mapping_ixp.column_mapping_grid.cells(value, cellIndex).getValue();
					cell_index = data_column_mapping_ixp.column_mapping_grid.getColumnId(cellIndex);
					
					if (cell_index == 'source_column_name') {
						cell_index = 'SourceColumn';
						xml_create_status = 1;
						if (source_column_arr.indexOf(cell_value) == -1) {
							source_column_arr.push(cell_value);
						}
                    } else if (cell_index == 'dest_column') {
						cell_index = 'DestinationColumn';
                        if (cell_value.indexOf('udf_') != -1) udf_count = udf_count + 1;
						cell_value = cell_value.replace('udf_',index + '_');
						xml_create_status = 1;
						if (cell_value == '') dest_column_blank = 1;
                    } else if (cell_index == 'column_function') {
						cell_index = 'Function';
						xml_create_status = 1;
						cell_value = escapeXML((cell_value));
                    } else if (cell_index == 'column_aggregation') {
						cell_index = 'Aggregation';
						xml_create_status = 1;
                    } else {
						if (data_column_mapping_ixp.column_mapping_grid.cells(value, 4).getValue() != '') {
							if (k != row_index)
								dest_xml += '|';
							dest_xml += k + ':' + data_column_mapping_ixp.column_mapping_grid.cells(value, 0).getValue() + '=' + data_column_mapping_ixp.column_mapping_grid.cells(value, 4).getValue();
						}
						xml_create_status = 0;
					}
					if (xml_create_status)
						grid_xml += " " + cell_index + '="' + cell_value + '"';
				}
				
				grid_xml += ' ' + ' JoinClause="' + escapeXML(dest_xml) + '" RepeatNumber="' + repeat_number + '" ></PSRecordset> ';
			}

            
        });
        grid_xml += '</Root>';

		if (dest_column_blank == 1) {
            show_messagebox('The destination table column cannot be unmapped');
            return;
        }

        //Only 20 udf fields are supported.
        if (udf_count > 20) {
            show_messagebox('Maximum allowed UDF mapping exceeds.');
            return;
        }

        //   if (major_array.length > 0)
        data_column_mapping_ixp.violate = -1;

        //   alert(major_array.length);
        // alert(destination_array);
        data_column_mapping_ixp.violate = 1;

        if (data_column_mapping_ixp.violate == 1) {
			var mapped_source_column_num = source_column_arr.length;
			
			if (size_of_temp_source > mapped_source_column_num) {
                var message = "Some of the columns in the file has not been mapped. Are you sure you want to continue?";
                confirm_messagebox(message, function() {
                            data_column_mapping_ixp.save_column_mapping(grid_xml);
                });
			} else {
				data_column_mapping_ixp.save_column_mapping(grid_xml);
			}
			
        }
    }


    /*
     * Saving column mapping
     * param grid_xml: XML of the grid that was prepared
     * return
     */
    data_column_mapping_ixp.save_column_mapping = function(grid_xml) {
		var where_clause = data_column_mapping_ixp.button_form_name.getItemValue('where_clause');
		var join_clause = data_column_mapping_ixp.button_form_name.getItemValue('join_clause');
        
		if(where_clause=='')
            where_clause='NULL';
        data = {
            "action": "spa_ixp_import_data_mapping",
            "flag": "i",
            "ixp_table_id": table_id,
            "process_id": process_id,
            "where_clause": where_clause,
            "xml": grid_xml,
            "join_clause" : join_clause,
            "ixp_import_relation_id" : ixp_import_relation_id,
            "ixp_rules_id" : rules_id
        };
        result = adiha_post_data("alert", data, "", "", "data_column_mapping_ixp.callback_save_mapping");
    }
    /*
     * Events attached to the toolbar.
     * param name: Name of the toolbar
     * param value: Value of the toolbar
     * return
     */
    data_column_mapping_ixp.toolbar_onclick = function(name, value) {
        if (name == 'remove') {
            var selectedId = data_column_mapping_ixp.column_mapping_grid.getSelectedRowId();
            if (!selectedId) {
                show_messagebox('Please select any mapping.');
                return;
            } else {
				var required_selected_arr = new Array();
				var selectedid_arr = selectedId.split(',');
				for(cnt = 0; cnt < selectedid_arr.length; cnt++) {
					var is_required = data_column_mapping_ixp.column_mapping_grid.cells(selectedid_arr[cnt],4).getValue()
					
					if (is_required == 1)
						required_selected_arr.push(is_required)
				}
				
				if (required_selected_arr.length > 0) {
					show_messagebox('Required columns cannot be deleted');
					return;
				}
				
                confirm_messagebox("Are you sure you want to delete?", function() {
                            data_column_mapping_ixp.column_mapping_grid.deleteSelectedRows(selectedId);
                });
            }
        } else if (name == 'add') {
            var newId = (new Date()).valueOf();
            data_column_mapping_ixp.column_mapping_grid.addRow(newId, "");
			data_column_mapping_ixp.column_mapping_grid.setRowColor(newId,not_required_color);
        }
    }
    /*
     * Callback function after saving the column mapping
     * param result: resultset from the database that has been returned
     * return: closes the screen if Success else nothing is done.
     */
    data_column_mapping_ixp.callback_save_mapping = function(result) {
        if (result[0].errorcode == 'Success') {
            var delay = 2000; //2 seconds
            setTimeout(function() {
                parent.close_column_table_window();
            }, delay);
        } else {
            return;
        }
    }

    //Place the cursor at the end of the content editor
    function setEndOfContenteditable(contentEditableElement) {
        var range,selection;
        if(document.createRange)//Firefox, Chrome, Opera, Safari, IE 9+
        {
            range = document.createRange();//Create a range (a range is a like the selection but invisible)
            range.selectNodeContents(contentEditableElement);//Select the entire contents of the element with the range
            range.collapse(false);//collapse the range to the end point. false means collapse to end rather than the start
            selection = window.getSelection();//get the selection object (allows you to change selection)
            selection.removeAllRanges();//remove any selections already made
            selection.addRange(range);//make the range you have just created the visible selection
        } else if (document.selection) //IE 8 and lower
        {
            range = document.body.createTextRange();//Create a range (a range is a like the selection but invisible)
            range.moveToElementText(contentEditableElement);//Select the entire contents of the element with the range
            range.collapse(false);//collapse the range to the end point. false means collapse to end rather than the start
            range.select();//Select the range (make it the visible selection
        }
    }

    //Add code at the text cursor position. Used to break the html - Before the text cursor and after the text cursor
    function html_at_caret(html, selectPastedContent) {
        var sel, range;
        if (window.getSelection) {
            // IE9 and non-IE
            sel = window.getSelection();
            if (sel.getRangeAt && sel.rangeCount) {
                range = sel.getRangeAt(0);
                range.deleteContents();

                // Range.createContextualFragment() would be useful here but is
                // only relatively recently standardized and is not supported in
                // some browsers (IE9, for one)
                var el = document.createElement("div");
                el.innerHTML = html;
                var frag = document.createDocumentFragment(),
                    node, lastNode;
                while ( (node = el.firstChild) ) {
                    lastNode = frag.appendChild(node);
                }
                var firstNode = frag.firstChild;
                range.insertNode(frag);

                // Preserve the selection
                if (lastNode) {
                    range = range.cloneRange();
                    range.setStartAfter(lastNode);
                    if (selectPastedContent) {
                        range.setStartBefore(firstNode);
                    } else {
                        range.collapse(true);
                    }
                    sel.removeAllRanges();
                    sel.addRange(range);
                }
            }
        } else if ( (sel = document.selection) && sel.type != "Control") {
            // IE < 9
            var originalRange = sel.createRange();
            originalRange.collapse(true);
            sel.createRange().pasteHTML(html);
            if (selectPastedContent) {
                range = sel.createRange();
                range.setEndPoint("StartToStart", originalRange);
                range.select();
            }
        }
    }
	
	mapping_grid_callback = function() {
		data_column_mapping_ixp.column_mapping_grid.forEachRow(function(id){
			var is_required = data_column_mapping_ixp.column_mapping_grid.cells(id,4).getValue()
					
			if (is_required == 1) {
				data_column_mapping_ixp.column_mapping_grid.setRowColor(id,required_color);
			} else {
				data_column_mapping_ixp.column_mapping_grid.setRowColor(id,not_required_color);
			}
		});
	}
</script>
<style>
    html,
    body {
        width: 100%;
        height: 100%;
        margin: 0px;
        overflow: hidden;
    }

    .ui-autocomplete {
        max-height: 100px;
        max-width: 200px;
        overflow-y: auto;
        overflow-x: hidden;
        font-size: 12px;
    }
</style>