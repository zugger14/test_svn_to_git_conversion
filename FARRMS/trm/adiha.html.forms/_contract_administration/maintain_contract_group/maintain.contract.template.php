<?php
/**
* Maintain contract template screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
        <?php require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
    </head>
    <?php
    require('../../../adiha.html.forms/_setup/manage_documents/manage.documents.button.php');

    $call_from = get_sanitized_value($_GET['call_from'] ?? 'standard');
    $contract_id = get_sanitized_value($_GET['contract_id'] ?? '');
    $call_from_combo = get_sanitized_value($_GET['call_from_combo'] ?? '');
    $grid_type = 'g';
    $rights_contract_lock = '0';
    $rights_contract_unlock = '0';

    if ($call_from == 'standard') {
        $function_id = 10211200;
        $rights_contract_copy = 10211210;
        $rights_contract_privilege = 10211220;
        $rights_contract_delete = 10211211;
        $rights_contract_lock = 10211225;
        $rights_contract_unlock = 10211226;
        $template_name = 'contract_group';
        $tree_grid_name = "contract_group";
        $tree_grid_spa = "EXEC  spa_contract_trees 's'";
    } else if ($call_from == 'nonstandard') {
        $function_id = 10211300;
        $rights_contract_copy = 10211310;
        $rights_contract_privilege = 10211320;
        $rights_contract_delete = 10211311;
        $rights_contract_lock = 10211325;
        $rights_contract_unlock = 10211326;
        $template_name = 'contract_group_non_standard';
        $tree_grid_name = "contract_group";
        $tree_grid_spa = "EXEC  spa_contract_trees 'n'";
    } else if ($call_from == 'transportation') {
        $function_id = 10211400;
        $rights_contract_copy = 10211410;
        $rights_contract_privilege = 10211420;
        $rights_contract_delete = 10211411;
        $template_name = 'contract_group_transportation';
        $tree_grid_name = "transportation_contract_grid";
        $tree_grid_spa = "EXEC  spa_contract_trees 't'";
        $grid_type = 't';
    } else if ($call_from == 'storage') {
        $function_id = 20008200;
        $rights_contract_copy = 20008200;
        $rights_contract_privilege = 20008200;
        $rights_contract_delete = 20008200;
        $template_name = 'contract_group_storage';
        $tree_grid_name = "storage_contract_grid";
        $tree_grid_spa = "EXEC  spa_contract_trees 'v'";
        $grid_type = 't';
    }

    $rights_contract_document = 10102900;
    $rights_contract_charge_type_ui = 10211416;
    $rights_contract_charge_type_delete = 10211417;
    $rights_contract_gl_code = 10211418;
    $rights_contract_formula_ui = 10211431;
    $rights_contract_charge_type_copy = 10211416;
    $rights_contract_delievery_path = 10161100;
    
    list (
        $has_rights_contract_copy,
        $has_rights_contract_document,
        $has_rights_contract_charge_type_ui,
        $has_rights_contract_charge_type_delete,
        $has_rights_contract_gl_code,
        $has_rights_contract_formula_ui,
        $has_rights_contract_charge_type_copy,
        $has_rights_contract_delievery_path,
        $has_rights_contract_privilege,
        $has_rights_contract_delete,
        $has_rights_contract_lock,
        $has_rights_contract_unlock
    ) = build_security_rights(
        $rights_contract_copy, 
        $rights_contract_document, 
        $rights_contract_charge_type_ui, 
        $rights_contract_charge_type_delete, 
        $rights_contract_gl_code, 
        $rights_contract_formula_ui, 
        $rights_contract_charge_type_copy,
        $rights_contract_delievery_path,
        $rights_contract_privilege,
        $rights_contract_delete,
        $rights_contract_lock,
        $rights_contract_unlock
    );
    /* Use of standard form */
    /* START */
    $form_namespace = 'contract_group';
    $form_obj = new AdihaStandardForm($form_namespace, $function_id);
    $form_obj->define_grid($tree_grid_name, $tree_grid_spa, $grid_type);
    $form_obj->define_layout_width(490);
    $form_obj->enable_multiple_select();
    $form_obj->add_privilege_menu($has_rights_contract_privilege);
    $form_obj->define_custom_functions('save_contract', 'load_contract', 'delete_tree');
    $form_obj->enable_grid_pivot();
    echo $form_obj->init_form('Contracts', 'Contract Details', $contract_id);

    if ($has_rights_contract_copy) {
        $copy_status = 'false';
    } else {
        $copy_status = 'true';
    }

    echo "contract_group.menu.addNewChild('t1', 1, 'copy', 'Copy'," . 'true' . ",'copy.gif', 'copy_dis.gif');";
    if ($call_from == 'standard' || $call_from == 'nonstandard') {
        echo "contract_group.menu.addNewChild('process', 4, 'lock', 'Lock'," . 'true' . ",'lock.gif', 'lock_dis.gif');";
        echo "contract_group.menu.addNewChild('process', 5, 'unlock', 'Unlock'," . 'true' . ",'unlock.gif', 'unlock_dis.gif');";
    }
    echo $form_obj->close_form();
    /* END */

    /* Using grid table for contract component */
    /* START */
    $table_name = 'contract_component';
    $grid_def = "EXEC spa_adiha_grid 's', '" . $table_name . "'";
    $def = readXMLURL2($grid_def);
    $grid_id = $def[0]['grid_id'];
    $table_name = $def[0]['grid_name'];
    $grid_columns = $def[0]['column_name_list'];
    $grid_col_labels = $def[0]['column_label_list'];
    $grid_col_types = $def[0]['column_type_list'];
    $sql_string = trim($def[0]['sql_stmt']);
    $grid_set_visibility = $def[0]['set_visibility'];
    $grid_column_width = $def[0]['column_width'];
    $grid_col_sorting = $def[0]['sorting_preference'];
    $grid_column_width = '';
    $pieces = explode(",", $grid_columns);
    
    for ($x = 1; $x <= count($pieces); $x++) {
        if ($x != 1) {
            $grid_column_width .=',';
        }
        $grid_column_width .='*';
    }

    if ($def[0]['dropdown_columns'] != 'NULL' && $def[0]['dropdown_columns'] != '') {
        $combo_fields = explode(",", $def[0]['dropdown_columns']);
    }

    // ## Below Block for combo fields is example of bad coding, loading combos in uneditable grid
    $html_string = '';
    foreach ($combo_fields as $combo_column) {
        $column_def = "EXEC spa_adiha_grid @flag='t', @grid_name = '" . $table_name . "', @column_name='" . $combo_column . "'";
        $column_data = readXMLURL2($column_def);
        $html_string .= 'var colIndex_object_id= contract_group["contract_component_grid_object_id"].getColIndexById("' . $combo_column . '");';
        $html_string .= 'var column_object_' . $combo_column . '_object_id' . ' = contract_group["contract_component_grid_object_id"].getColumnCombo(colIndex_object_id);';
        $html_string .= 'column_object_' . $combo_column . '_object_id' . '.enableFilteringMode(true);';
        // Fixed calling load function with empty combo json
        if ($column_data[0]['json_string'] != '') {
            $html_string .= 'column_object_' . $combo_column . '_object_id' . '.load(' . $column_data[0]['json_string'] . ');';
        }
    }
    /* END */
    /* Using grid table for contract price tab. */
    /* START */
    $table_name1 = 'source_price_curve_def';
    $grid_def1 = "EXEC spa_adiha_grid 's', '" . $table_name1 . "'";
    $def1 = readXMLURL2($grid_def1);
    $grid_id1 = $def1[0]['grid_id'];
    $table_name1 = $def1[0]['grid_name'];
    $grid_columns1 = $def1[0]['column_name_list'];
    $grid_col_labels1 = $def1[0]['column_label_list'];
    $grid_col_types1 = $def1[0]['column_type_list'];
    $grid_col_align = $def1[0]['column_alignment'];
    $sql_string1 = trim($def1[0]['sql_stmt']);
    $grid_set_visibility1 = $def1[0]['set_visibility'];
    $grid_column_width1 = $def1[0]['column_width'];
    $grid_col_sorting = $def[0]['sorting_preference'];
    $grid_column_width1 = '';
    $pieces = explode(",", $grid_columns1);
    
    for ($x = 1; $x <= count($pieces); $x++) {
        if ($x != 1) {
            $grid_column_width1 .=',';
        }
        $grid_column_width1 .='*';
    }
    
    if ($def1[0]['dropdown_columns'] != 'NULL' && $def1[0]['dropdown_columns'] != '') {
        $combo_fields1 = explode(",", $def1[0]['dropdown_columns']);
    }

    $html_string1 = '';
    foreach ($combo_fields1 as $combo_column1) {
        $column_def1 = "EXEC spa_adiha_grid @flag='t', @grid_name = '" . $table_name1 . "', @column_name='" . $combo_column1 . "'";
        $column_data1 = readXMLURL2($column_def1);
        $html_string1 .= 'var colIndex_object_id= contract_group["contract_price_grid_object_id"].getColIndexById("' . $combo_column1 . '");';
        $html_string1 .= 'var column_object_' . $combo_column1 . '_object_id' . ' = contract_group["contract_price_grid_object_id"].getColumnCombo(colIndex_object_id);';
        $html_string1 .= 'column_object_' . $combo_column1 . '_object_id' . '.enableFilteringMode(true);';
        $html_string1 .= 'column_object_' . $combo_column1 . '_object_id' . '.load(' . $column_data1[0]['json_string'] . ');';
    }
    /* END */

    /* JSON for grid toolbar */
    /* START */
    $button_grid_charge_json = '[
                                {id:"t1", text:"Edit", img:"edit.gif", imgdis:"edit_dis.gif", items:[
                                    {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add",enabled:"' . $has_rights_contract_charge_type_ui . '"},
                                    {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete",enabled:"' . 'false' . '"},
                                    {id:"copy", text:"Copy", img:"copy.gif", imgdis:"copy_dis.gif", title: "Copy",enabled:"' . 'false' . '"}
                                ]},
                                {id:"gl_code", text:"GL Code", img:"gl_code.gif", imgdis:"gl_code_dis.gif", title: "GL Code",enabled:"false"},
                                {id:"t2", text:"Export", img:"export.gif",imgdis:"export_dis.gif",items:[
                                    {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                                    {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                                ]},
                                {id:"t3", text:"Template", img:"export.gif",imgdis:"export_dis.gif",items:[
                                    {id:"download_template", text:"Download Template", img:"excel.gif", imgdis:"excel_dis.gif", title: "Download Template"},
                                    {id:"upload_template", text:"Upload Template", img:"excel.gif", imgdis:"pdf_dis.gif", title: "Upload Template"}
                                ]}
                                ]';

    /* END */

    /* JSON for formula toolbar */
    /* START */
    $button_grid_formula_json = '[
                                {id:"t1", text:"Edit", img:"edit.gif", imgdis:"edit_dis.gif", items:[
                                    {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add",enabled:"' . $has_rights_contract_formula_ui . '"},
                                    {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete",enabled:"' . $has_rights_contract_formula_ui . '"}
                                ]},
                                {id:"save", text:"Save", img:"save.gif", imgdis:"save_dis.gif", title: "Save",enabled:"' . $has_rights_contract_formula_ui . '"},
                                {id:"additional", text:"Additional", img:"additional.gif", imgdis:"additional_dis.gif", title: "Additional"}
                                ]';
    /* END */
    /* JSON for contract price grid toolbar */
    /* START */
    $button_pricegrid_formula_json = '[
                                {id:"t1", text:"Edit", img:"edit.gif", items:[
                                    {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add"},
                                    {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete",enabled:0}
                                ]},
                                {id:"t2", text:"Export", img:"export.gif", items:[
                                    {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                                    {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                                ]}
                                ]';
    
    $button_pricefees_json = '[
                                {id:"t1", text:"Edit", img:"edit.gif", items:[
                                    {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add"},
                                    {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete",enabled:0},
                                    {id:"add_charges", text:"Add Multiple", img:"new.gif", imgdis:"new_dis.gif", title: "Add Multiple"}
                                ]},
                                {id:"t2", text:"Export", img:"export.gif", items:[
                                    {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                                    {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                                ]}
                                ]';
    /* END */
    /* DataView Structure */
    /* START */
    $dataview_name = 'dataview_formula';
    $template = "<div class='select_button' onclick='select_clicked(#formula_id#,#row#,#nested_idd#,#formula_group_id#);'></div><div><div><div><div><span> #row# </span><span></span><span> #description_1# </span></div><div><span> Formula: </span><span> #formula# </span></div><div><span>Granularity: </span><span> #granularity# </span><span>, Show Value As: </span><span> #volume# </span><span style='display:none;'> Nested ID: </span><span style='display:none;'> #nested_id# </span><span style='display:none;'> Formula Group ID: </span><span style='display:none;'> #formula_group_id# </span></div></div></div></div>";
    $tooltip = "<b>#formula#</b>";

    $category_name = 'Contract';
    $category_sql = "SELECT value_id FROM static_data_value WHERE type_id = 25 AND code = '" . $category_name . "'";
    $category_data = readXMLURL2($category_sql);
    /* END */

    if ($call_from == 'transportation') {
        $form_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='" . $function_id . "', @template_name='contract_group_transportation', @parse_xml='<Root><PSRecordset contract_id=" . '"NULL"' ."></PSRecordset></Root>'";
    } else if ($call_from == 'storage') {
        $form_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='" . $function_id . "', @template_name='contract_group_storage', @parse_xml='<Root><PSRecordset contract_id=" . '"NULL"' ."></PSRecordset></Root>'";
    } else if ($call_from == 'nonstandard') {
        $form_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='" . $function_id . "', @template_name='contract_group_non_standard', @parse_xml='<Root><PSRecordset contract_id=" . '"NULL"' ."></PSRecordset></Root>'";
    } else if ($call_from == 'standard') {
        $form_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='" . $function_id . "', @template_name='contract_group', @parse_xml='<Root><PSRecordset contract_id=" . '"NULL"' ."></PSRecordset></Root>'";
    }

    $form_data = array();

    if ($form_sql != '') {
        $form_data = readXMLURL2($form_sql);
    }

    $grid_definition = array();

    if (is_array($form_data) && sizeof($form_data) > 0) {
        foreach ($form_data as $data) {
            // Grid data collection
            $grid_json = array();
            $pre = strpos($data['grid_json'], '[');
            if ($pre === false) {
                $data['grid_json'] = '[' . $data['grid_json'] . ']';
            }

            $grid_json = json_decode($data['grid_json'], true);
            foreach ($grid_json as $grid) {
                if ($grid['grid_id'] == '' || $grid['grid_id'] == null) { continue; }
                if ($grid['grid_id'] != 'FORM') {
                    $grid_def = "EXEC spa_adiha_grid 's', '" . $grid['grid_id'] . "'";
                    $def = readXMLURL2($grid_def);

                    $it = new RecursiveIteratorIterator(new RecursiveArrayIterator($def));
                    $l = iterator_to_array($it, true);

                    array_push($grid_definition, $l);
                }
            }
        }
    }
    $grid_definition_json = json_encode($grid_definition);
    ?>
    <body>
        <div id="layoutObj"></div>
        <!-- will used as windows viewport -->
        <div id="winVP" style="display: none;"></div>
    </body>
    <style type="text/css">
        html, body {
            width: 100%;
            height: 100%;
            margin: 0px;
            overflow: hidden;
        }
        .dhx_item_editor{
            width:210px;
            height:113px;
        }

        img.book_icon {
            float: left;
            margin-right: 10px;
        }


        div.select_button {
            width: 20px;
            height: 50px;
            float: left;
            background-image: url("<?php echo $image_path; ?>dhxtoolbar_web/formula_1.png");
            padding-left: 30px;
            padding-top: 4px;
        }
    </style>
    <script type="text/javascript">
        var category_id = '<?php echo $category_data[0]['value_id'];?>';
        var php_script_loc_ajax = "<?php echo $app_php_script_loc; ?>";
        var combo_string = '<?php echo $html_string; ?>';
        var combo_string1 = '<?php echo $html_string1; ?>';
        var grid_toolbar_json =<?php echo $button_grid_charge_json; ?>;
        var formula_toolbar_json =<?php echo $button_grid_formula_json; ?>;
        var contractprice_toolbar_json =<?php echo $button_pricegrid_formula_json; ?>;
        var button_pricefees_json = <?php echo $button_pricefees_json; ?>;
        dhxWins = new dhtmlXWindows();
        var function_id = "<?php echo $function_id; ?>";
        var currentdate = new Date();
        var popup_window;
        var has_rights_contract_copy =<?php echo ($has_rights_contract_copy) ? $has_rights_contract_copy : '0'; ?>;
        var has_rights_contract_document =<?php echo ($has_rights_contract_document) ? $has_rights_contract_document : '0'; ?>;
        var has_rights_contract_formula_ui =<?php echo ($has_rights_contract_formula_ui) ? $has_rights_contract_formula_ui : '0'; ?>;
        var has_rights_contract_charge_type_ui =<?php echo ($has_rights_contract_charge_type_ui) ? $has_rights_contract_charge_type_ui : '0'; ?>;
        var has_rights_contract_charge_type_delete =<?php echo ($has_rights_contract_charge_type_delete) ? $has_rights_contract_charge_type_delete : '0'; ?>;
        var has_rights_contract_charge_type_copy =<?php echo ($has_rights_contract_charge_type_copy) ? $has_rights_contract_charge_type_copy : '0'; ?>;
        var has_rights_contract_delievery_path =<?php echo ($has_rights_contract_delievery_path) ? $has_rights_contract_delievery_path : '0'; ?>;
        var has_rights_contract_privilege =<?php echo ($has_rights_contract_privilege) ? $has_rights_contract_privilege : '0'; ?>;
        var has_rights_contract_delete = <?php echo ($has_rights_contract_delete) ? $has_rights_contract_delete : '0'; ?>;
        var has_rights_contract_lock = <?php echo ($has_rights_contract_lock) ? $has_rights_contract_lock : '0'; ?>;
        var has_rights_contract_unlock = <?php echo ($has_rights_contract_unlock) ? $has_rights_contract_unlock : '0'; ?>;
        var checked_status;
        var term_start_validate;
        var term_end_validate;
        var get_contract_name;
        var app_php_script_loc = '<?php echo $app_php_script_loc; ?>';
        var call_from_combo = '<?php echo $call_from_combo; ?>';
        
        var grid_definition_json = <?php echo $grid_definition_json; ?>;
        contract_group.grid_dropdowns = {};
        
        $(function() {
			contract_group.grid.attachEvent("onRowSelect", function(id, ind) {
                var selected_row = contract_group.grid.getSelectedRowId();
                if (has_rights_contract_delete)
                    contract_group.menu.setItemEnabled('delete');
                if (has_rights_contract_copy && selected_row.indexOf(',') == -1)
                    contract_group.menu.setItemEnabled('copy');
                else
                    contract_group.menu.setItemDisabled('copy');

                var selected_row = contract_group.grid.getSelectedRowId();
                if (selected_row.indexOf(',') == -1) {
                    contract_id = contract_group.grid.cells(selected_row, contract_group.grid.getColIndexById('contract_id')).getValue(); 
                    var param = {
                                    "action": '[spa_contract_group]',
                                    "flag": 'f',
                                    "contract_id": contract_id
                                };
                    adiha_post_data('return_array', param, '', '', 'refresh_islock_callback'); 
                } else {
                    if (contract_group.menu.getItemType('lock') != null)
                        contract_group.menu.setItemDisabled('lock');
                    if (contract_group.menu.getItemType('unlock') != null)
                        contract_group.menu.setItemDisabled('unlock');
                }
            });
            
            load_workflow_status();
        });
    
        function refresh_islock_callback(result) { 
            if(result.length == 0) return;
            if(result[0][0] == 'y'){
                if (contract_group.menu.getItemType('lock') != null)
                    contract_group.menu.setItemDisabled('lock');
                if (has_rights_contract_unlock && contract_group.menu.getItemType('unlock') != null) {
                    contract_group.menu.setItemEnabled('unlock');
                }
            } else {
                if (has_rights_contract_lock && contract_group.menu.getItemType('lock') != null) {
                    contract_group.menu.setItemEnabled('lock');
                }
                if (contract_group.menu.getItemType('unlock') != null)
                    contract_group.menu.setItemDisabled('unlock');
            }
            return;
        }
        
        function add_privilege_button() {
            contract_group.menu.attachEvent('onClick', function(id) {
                var selected_row = contract_group.grid.getSelectedRowId();
                if (selected_row = null) selected_row = 0;
                var call_from = '<?php echo $call_from; ?>';
                var col_name = '';
                
                if (call_from == 'standard') {
                    col_name = 'contract_id';
                } else if (call_from == 'nonstandard') {
                    col_name = 'contract_id';
                } else if (call_from == 'transportation') {
                    col_name = 'contract_id_show';
                }
                
                if (id == 'privilege') {
                    var selected_row = contract_group.grid.getSelectedRowId();
                    var selected_row_arr = selected_row.split(',');
                    var value_id = ''; 
                    var type_id = '';
                    var value_col_index = contract_group.grid.getColIndexById(col_name);
                    value_id = contract_group.grid.cells(selected_row_arr[0], value_col_index).getValue(); 
                    type_id = contract_group.grid.cells(selected_row_arr[0], contract_group.grid.getColIndexById('type_id')).getValue(); 
                    for(i = 1; i < selected_row_arr.length; i++) {
                        value_id = value_id + "," + contract_group.grid.cells(selected_row_arr[i], value_col_index).getValue();
                        type_id = type_id + "," + contract_group.grid.cells(selected_row_arr[i], contract_group.grid.getColIndexById("type_id")).getValue();
                    }
                    open_static_data_privilege_window(type_id, value_id);
                } else if (id == 'deactivate') {
                    var selected_row = 0;
                    var call_from = '<?php echo $call_from; ?>';
                    var group_label = '';
                    
                    if (call_from == 'standard') {
                        group_label = 4016;
                    } else if (call_from == 'nonstandard') {
                        group_label = 4073;
                    } else if (call_from == 'transportation') {
                        group_label = 4074;
                    }
                    
                    confirm_messagebox('Are you sure you want to Deactivate?', function() {
                        var data = {'action': 'spa_static_data_privilege', 'type_id': group_label, 'flag' : 'd', 'call_from': 1};
                        adiha_post_data('return_array', data, '', '', 'contract_group.deactivate_callback');
                    });
                } else if (id == 'activate') {                                      
                    var value_id = contract_group.grid.cells(0, contract_group.grid.getColIndexById(col_name)).getValue();                     
                    var type_id = '';
                    
                    if (call_from == 'standard') {
                        type_id = 4016;
                    } else if (call_from == 'nonstandard') {
                        type_id = 4073;
                    } else if (call_from == 'transportation') {
                        type_id = 4074;
                    }
                    
                    confirm_messagebox('Are you sure you want to Activate?', function() {
                        var data = {'action': 'spa_static_data_privilege', 'type_id': type_id, 'flag' : 'a', 'call_from': 1, 'value_id': value_id};
                        adiha_post_data('return_array', data, '', '', 'contract_group.activate_callback');
                    });                         
                }
            });
        }

        contract_group.open_storage_asset = function(id) {
            var tab_id = contract_group.tabbar.getActiveTab();
            var inner_tab_obj = contract_group.tabbar.cells(tab_id).getAttachedObject().cells('a').getAttachedObject();
            var detail_tabs = inner_tab_obj.getAllTabs();

            var storage_asset_id = 0;
            var counterparty_id = 0;
            $.each(detail_tabs, function(index,value) {
                var tab_name = inner_tab_obj.tabs(value).getText();
                if (tab_name == 'General') {
                    var form_data = inner_tab_obj.tabs(value).getAttachedObject().cells("a").getAttachedObject().getFormData();
                    storage_asset_id = form_data.storage_asset_id;
                    counterparty_id = form_data.pipeline;
                    return false;
                }
            });
            
            var contract_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
            
            var open_credit_file_popup = new dhtmlXPopup();
            win_text = 'Storage Asset';
            param = '../../_scheduling_delivery/gas/virtual_storage/virtual.storage.php?contract_id=' + contract_id + '&storage_asset_id=' + storage_asset_id + '&counterparty_id=' + counterparty_id;
            width = 380;
            height = 350;
            if (!popup_window) {
                popup_window = new dhtmlXWindows();
            }
            contract_group.sa_win = popup_window.createWindow('sa_win', 0, 0, width, height);
            contract_group.sa_win.centerOnScreen();
            contract_group.sa_win.setText(win_text);
            contract_group.sa_win.maximize();
            contract_group.sa_win.attachURL(param, false, true);
        }

        $(function() {
            add_privilege_button();
            /*
             * Overwritten tabbar toolbar click event
             */
            contract_group.tab_toolbar_click = function(id) {
                switch (id) {
                    case "close":
                        var tab_id = contract_group.tabbar.getActiveTab();
                        delete contract_group.pages[tab_id];
                        contract_group.tabbar.tabs(tab_id).close(true);
                        break;
                    case "save":
                        var tab_id = contract_group.tabbar.getActiveTab();
                        contract_group.save_contract(tab_id);
                        break;
                    case "copy":
                        var tab_id = contract_group.tabbar.getActiveTab();
                        contract_group.copy_contract(tab_id);
                        break;
                    case "documents":
                        var tab_id = contract_group.tabbar.getActiveTab();
                        contract_group.open_document(tab_id,'contract_window');
                        break;
                    case "storage_asset":
                        var tab_id = contract_group.tabbar.getActiveTab();
                        contract_group.open_storage_asset(tab_id);
                        break;
					case "contract_reminder":
                        var tab_id = contract_group.tabbar.getActiveTab();
                        contract_group.alert_reminders(tab_id);
						break;
                    default:
                        break;
                }
            };
        });
        /*
         * Over ridden grid menu click event
         * @param {type} id
         * @param {type} zoneId
         * @param {type} cas
         * @returns {undefined}
         */
        contract_group.grid_menu_click = function(id, zoneId, cas) {
            switch (id) {
                case "add":
                    contract_group.create_tab(-1, 0, 0, 0);
                    break;
                case "delete":
                    contract_group.delete_tree();
                    break;
                case "excel":
                    contract_group.grid.toExcel(php_script_loc_ajax + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                    break;
                case "pdf":
                    contract_group.grid.toPDF(php_script_loc_ajax + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                    break;
                case "copy":
                    var r_id = contract_group.grid.getSelectedRowId();
                    if (!r_id) {
                        show_messagebox('Please select a contract.');
                        return;
                    }

                    full_id = contract_group.get_id(contract_group.grid, r_id);
                    contract_group.copy_contract(full_id);
                    break;
                case "lock":
                    var r_id = contract_group.grid.getSelectedRowId();
                    if (!r_id) {
                        show_messagebox('Please select a contract.');
                        return;
                    }

                    full_id = contract_group.get_id(contract_group.grid, r_id);
                    contract_group.lock_contract(full_id);
                    break;
                case "unlock":
                    var r_id = contract_group.grid.getSelectedRowId();
                    if (!r_id) {
                        show_messagebox('Please select a contract.');
                        return;
                    }

                    full_id = contract_group.get_id(contract_group.grid, r_id);
                    contract_group.unlock_contract(full_id);
                    break;
                case "pivot":
                    var call_from = '<?php echo $call_from; ?>';
                    var flag = '';
                    if (call_from == 'standard') {
                        flag = 's';
                    } else if (call_from == 'nonstandard') {
                        flag = 'n';
                    } else if (call_from == 'transportation') {
                        flag = 't';
                    }
                    
                    var pivot_exec_spa = {
                        "action": "spa_contract_trees",
                        "flag": flag
                    };

                    pivot_exec_spa = "EXEC spa_contract_trees @flag='" + flag + "'";
                    open_grid_pivot(contract_group.grid, 'contract_group', 1, pivot_exec_spa, 'Contracts');
                    // alert('pivot');

            }
        }
        /*
         * To open pop up UI for delievery path.
         * @param {type} name
         * @param {type} value
         * @returns {String}
         */
		 
		var label_delivery_path = get_locale_value("Delivery Path");
				
        open_delivery_hyperlink = function(name, value) {
            return '<a href="#" id= "delievery_open" onclick="contract_group.open_delievery_path(id)"> ' + label_delivery_path + '</a>';
        }

        /*
         * To open pop up UI for generic mapping.
         * @param {type} name
         * @param {type} value
         * @returns {String}
         */
		var label_buyback_sellback = get_locale_value("Buyback/Sellback")
        open_generic_mapping_hyperlink = function(name, value) {
            return '<a href="#" id= "generic_mapping_link" onclick="contract_group.open_generic_mapping(id)">'+label_buyback_sellback+'</a>';
        }
        
        /*
         * To open pop up UI for generic mapping.
         * @param {type} name
         * @param {type} value
         * @returns {String}
         */
		var label_settlement_rule_mapping = get_locale_value("Settlement Rule Mapping");
        open_generic_mapping_hyperlink = function(name, value) {
            return '<a href="#" id= "generic_mapping_link" onclick="contract_group.open_generic_mapping(id)">'+ label_settlement_rule_mapping +'</a>';
        }
        
        /*
         * To open delievery path in transportation contract.
         * @param {type} id
         * @returns {Boolean}
         */
        contract_group.open_delievery_path = function(id) {
            var active_tab_id = contract_group.tabbar.getActiveTab();
            var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            contract_id = contract_group["contract_component_grid_" + object_id].getUserData("", "contract_mode_xml");
            if (!contract_id) {
                show_messagebox('No data selected for hyperlink.');
                return false;
            }
            else if(!has_rights_contract_delievery_path){
                show_messagebox('You do not have privilege to access the hyperlink.');
                return false;
            }
            var open_delievery_popup = new dhtmlXPopup();
            win_text = 'Setup Delivery Path';
            param = '../../_scheduling_delivery/gas/Setup_Delivery_Path/Setup.Delivery.Path.php?contract_id=' + contract_id;
            width = 380;
            height = 350;
            if (!popup_window) {
                popup_window = new dhtmlXWindows();
            }
            var new_win = popup_window.createWindow('w9', 0, 0, width, height);
            new_win.centerOnScreen();
            new_win.setModal(true);
            new_win.setText(win_text);
            new_win.maximize();
            new_win.attachURL(param, false, true);
        }

        /*
         * To open Generic Mapping Screen.
         * @param {type} id
         * @returns {Boolean}
         */
        contract_group.open_generic_mapping = function(id) {
            var active_tab_id = contract_group.tabbar.getActiveTab();
            var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            contract_id = contract_group["contract_component_grid_" + object_id].getUserData("", "contract_mode_xml");
            if (!contract_id) {
                show_messagebox('No data selected for hyperlink.');
                return false;
            } else if(!has_rights_contract_delievery_path){
                show_messagebox('You do not have privilege to access the hyperlink.');
                return false;
            }
            
            win_text = 'Generic Mapping';
            param = '../../_setup/common_mapping/common_mapping.php?primary_column_value=' + contract_id + '&function_ids=10211400';
            width = 380;
            height = 350;
            if (!popup_window) {
                popup_window = new dhtmlXWindows();
            }
            var new_win = popup_window.createWindow('w10', 0, 0, width, height);
            new_win.centerOnScreen();
            new_win.setModal(true);
            new_win.setText(win_text);
            new_win.maximize();
            new_win.attachURL(param, false, true);
        }
        
        /*
         * Unload window that is used in popUP.
         * @param {type} win_type
         * @returns {undefined}
         */
        function unload_window(win_type) {
            if (popup_window != null && popup_window.unload != null) {
                popup_window.unload();
                popup_window = w1 = null;
            }
        }

        // Function to disable save button if privilege is disabled
        contract_group.check_privilege_callback = function(result) {
            // Disable Save button if disabled privilege
            privilege_status = result[0]['privilege_status'];
            
            if (privilege_status == 'false') {
                contract_group.tabbar
                    .cells(contract_group.tabbar.getActiveTab())
                    .getAttachedToolbar()
                    .disableItem('save'); 
            }
        }
        /*END to open pop up UI for delievery path.*/
        /**************************************************** Triggers when the tree is double clicked.********************************************/
        /*START*/
        /*
         * Load contract tab and form.
         * @param {type} win
         * @param {type} full_id
         * @returns {undefined}
         */
        contract_group.load_contract = function(win, full_id) {
            var object_id = (full_id.indexOf("tab_") != -1) ? full_id.replace("tab_", "") : full_id;
            
            /*JSON FOR inner layout*/
            var inner_tab_layout_jsob = [
                {
                    id: "a",
                    text: "Contracts",
                    header: false,
                    collapse: false,
                    width: 200,
                    fix_size: [true, null]
                },
                {
                    id: "b",
                    text: "Charge Types",
                    header: true,
                    collapse: false,
                    undock: true,
                    fix_size: [true, null]
                }
            ];
            contract_group["inner_tab_layout_" + object_id] = win.attachLayout({pattern: "2E", cells: inner_tab_layout_jsob});
            contract_group["inner_grid_layout_" + object_id] = contract_group["inner_tab_layout_" + object_id].cells("b").attachLayout({pattern: "2U"});

            /*Attaching status bar for grid pagination*/
            contract_group["inner_grid_layout_" + object_id].cells('a').attachStatusBar({
                height: 30,
                text: '<div id="pagingAreaGrid_b_' + object_id + '"></div>'
            });
            contract_group["inner_tab_layout_" + object_id].cells("b").showHeader();
            contract_group["inner_grid_layout_" + object_id].cells('a').hideHeader();
            contract_group["inner_grid_layout_" + object_id].cells('b').hideHeader();
            contract_group["inner_grid_layout_" + object_id].cells('a').setWidth(330);

            /*Attaching toolbar for grid.*/
            /*START*/
            contract_group["contract_toolbar_grid_" + object_id] = contract_group["inner_grid_layout_" + object_id].cells('a').attachMenu();
            contract_group["contract_toolbar_grid_" + object_id].setIconsPath(js_image_path + "dhxmenu_web/");
            contract_group["contract_toolbar_grid_" + object_id].loadStruct(grid_toolbar_json);
            contract_group["contract_toolbar_grid_" + object_id].attachEvent('onClick', contract_group.grd_charge_toolbar_click);
            /*END*/

            /*Attaching grid for contract component.*/
            /*START*/
            var pg_area = 'pagingAreaGrid_b_' + object_id;
            contract_group["contract_component_grid_" + object_id] = contract_group["inner_grid_layout_" + object_id].cells('a').attachGrid();
            contract_group["contract_component_grid_" + object_id].setImagePath("<?php echo $image_path; ?>dhxtoolbar_web/");
            contract_group["contract_component_grid_" + object_id].setHeader("<?php echo $grid_col_labels; ?>",null,["text-align:left;","text-align:left;","text-align:right;"]);
            contract_group["contract_component_grid_" + object_id].setColumnIds("<?php echo $grid_columns; ?>");
            contract_group["contract_component_grid_" + object_id].setColSorting("<?php echo $grid_col_sorting; ?>");
            contract_group["contract_component_grid_" + object_id].setColTypes("<?php echo $grid_col_types; ?>");
            contract_group["contract_component_grid_" + object_id].setColAlign("left,left,right");
            contract_group["contract_component_grid_" + object_id].setInitWidths("<?php echo $grid_column_width; ?>");
            contract_group["contract_component_grid_" + object_id].setColumnsVisibility("<?php echo $grid_set_visibility; ?>");
            contract_group["contract_component_grid_" + object_id].setPagingWTMode(true, true, true, true);
            contract_group["contract_component_grid_" + object_id].enablePaging(true, 25, 0, pg_area);
            contract_group["contract_component_grid_" + object_id].setPagingSkin('toolbar');
            contract_group["contract_component_grid_" + object_id].enableDragAndDrop(true);
            contract_group["contract_component_grid_" + object_id].attachEvent("onRowSelect", contract_group.load_dataview_formula);
            contract_group["contract_component_grid_" + object_id].attachEvent("onRowDblClicked", function(rId, cInd) {
                var contract_charge_type_id = ''

                contract_group["contract_tabs_" + object_id].forEachTab(function(tab) {
                    if (tab.getText() == 'General') {
                        var form_obj = tab.getAttachedObject().cells("a").getAttachedObject();
                        contract_charge_type_id = form_obj.getItemValue('contract_charge_type_id');
                    }
                });
                
                if (contract_charge_type_id == '' || function_id == '10211400') { 
                    var layout_obj = contract_group["inner_grid_layout_" + object_id].cells('b').getAttachedObject();
                    if (layout_obj instanceof dhtmlXDataView) {
                        contract_group["dataview_formula_" + object_id].stopEdit();
                        contract_group["dataview_formula_" + object_id].clearAll();
                    } else if (layout_obj instanceof dhtmlXGridObject) {
                        contract_group["inner_grid_layout_" + object_id].cells('b').detachObject();
                    }
                    contract_group.grd_charge_toolbar_click('edit');
                } else {
                    contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("t1");
                    contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("save");
                    contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("additional");
                }
                return false;
            });

            //To save sequence order in drag and drop.
            contract_group["contract_component_grid_" + object_id].attachEvent("onDrop", function(sId, tId, dId, sObj, tObj, sCol, tCol) {
                if (!has_rights_contract_charge_type_ui) {
                    return false;
                }
                grid_xml = '<Root>';
                var count = contract_group["contract_component_grid_" + object_id].getRowsNum();
                var j = 1;
                for (var i = 0; i <= count; i++) {
                    var contract_detail_id = contract_group["contract_component_grid_" + object_id].getRowId(i);
                    if (contract_detail_id) {
                        grid_xml = grid_xml + '<GridUpdate contract_id=' + '"' + object_id + '"' + ' contract_detail_id=' + '"' + contract_detail_id + '"' + ' sequence_order=' + '"' + j + '"' + '></GridUpdate>';
                    }
                    j++;
                }
                grid_xml += '</Root>';
                data = {"action": "spa_contract_group_detail_UI",
                    "flag": "v",
                    "xml": grid_xml
                };
                adiha_post_data('alert', data, '', '', '');
            });

            contract_group["contract_component_grid_" + object_id].init();
            contract_group["contract_component_grid_" + object_id].setUserData("", "grid_delete_xml", "");
            contract_group["contract_component_grid_" + object_id].setUserData("", "grid_update_xml", "");
            contract_group["contract_component_grid_" + object_id].setUserData("", "formula_delete_xml", "");
            contract_group["contract_component_grid_" + object_id].setUserData("", "form_validate_code_xml", "");
            contract_group["contract_component_grid_" + object_id].setUserData("", "pricegrid_delete_xml", "");
            contract_group["contract_component_grid_" + object_id].setUserData("", "contract_mode_xml", "");
            contract_group["contract_component_grid_" + object_id].setUserData("", "contract_mode_xml", "");
            contract_group["contract_component_grid_" + object_id].setUserData("", "contract_name_store", "");
            
            /*Getting tab and form JSON from backend to bind in the main tabbar.*/
            /*START*/
            grid_function_name = <?php echo $function_id; ?>;
            template_name = 'contract_group';
            
            var additional_data = {
                "action": "spa_create_application_ui_json",
                "flag": "j",
                "application_function_id": grid_function_name,
                "template_name": "<?php echo $template_name; ?>",
                "parse_xml": "<Root><PSRecordset contract_id=" + '"' + object_id + '"' + "></PSRecordset></Root>"
            };
            adiha_post_data('return_array', additional_data, '', '', 'contract_group.load_tab_and_forms');
            /*END*/

            /*Attaching toolbar for formula.*/
            /*START*/
            contract_group["contract_toolbar_formula_" + object_id] = contract_group["inner_grid_layout_" + object_id].cells('b').attachMenu();
            contract_group["contract_toolbar_formula_" + object_id].setIconsPath(js_image_path + "dhxmenu_web/");
            contract_group["contract_toolbar_formula_" + object_id].loadStruct(formula_toolbar_json);
            contract_group["contract_toolbar_formula_" + object_id].attachEvent('onClick', contract_group.grd_formula_toolbar_click);
            contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("t1");
            contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("save");
            contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("additional");
            /*END*/
            
            //To collapse the contract component and formula.
            if (function_id != 10211300)
                contract_group["inner_tab_layout_" + object_id].cells("b").collapse();
            
            if (contract_group.tabbar.cells("tab_" + object_id)) {
                toolbar_obj = contract_group.tabbar.cells("tab_" + object_id).getAttachedToolbar();
            }
        }

        /*Callback function to load tabs and form from the result gained by the backend.*/
        /*START*/
        contract_group.load_tab_and_forms = function(result) {
            var active_tab_id = contract_group.tabbar.getActiveTab();
            var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            var result_length = result.length;
            var tab_json = '';
            
            if (contract_group.tabbar.cells(active_tab_id) != null) {
                toolbar_obj = contract_group.tabbar.cells(active_tab_id).getAttachedToolbar();
                add_manage_document_button(object_id, toolbar_obj, 1); // changed to 1 to enable documents button in default
                
                var call_from = '<?php echo $call_from; ?>';
                if (call_from == 'storage') {
                    toolbar_obj.addButton('storage_asset', 2, 'Storage Asset', 'doc.gif', 'doc_dis.gif');
                }
				toolbar_obj.addButton('contract_reminder', 3, 'Alerts', 'alert.png', 'alert_dis.png');
            }
            
            for (var i = 0; i < result_length; i++) {
                if (i > 0)
                    tab_json = tab_json + ",";
                tab_json = tab_json + (result[i][1]);
            }
            
            tab_json = '{tabs: [' + tab_json + ']}';
            contract_group["contract_tabs_" + object_id] = contract_group.tabbar.cells(active_tab_id).tabbar[object_id] = contract_group["inner_tab_layout_" + object_id].cells("a").attachTabbar();
            contract_group["contract_tabs_" + object_id].loadStruct(tab_json);
            var form_code_xml = ' contract_group.form_validation_status=0;';
            
            var grid_no = 0;
            for (var j = 0; j < result_length; j++) {
                tab_id = 'detail_tab_' + result[j][0];
                var grid_json = JSON.stringify(result[j][4]);
                var check_form_status = (grid_json.indexOf("FORM") != -1) ? true : false;

                contract_group["contract_tabs_layout_" + object_id + "_" + tab_id] = contract_group["contract_tabs_" + object_id].cells(tab_id).attachLayout("1C");
                contract_group["contract_tabs_layout_" + object_id + "_" + tab_id].cells("a").hideHeader();
                if (result[j][2]) {//loads form
                    contract_group["contract_form_" + result[j][0]] = contract_group["contract_tabs_layout_" + object_id + "_" + tab_id].cells("a").attachForm();

                    contract_group["contract_form_" + result[j][0]].loadStruct(result[j][2], function() {
                        if (j == 0) {
                            var call_from = '<?php echo $call_from; ?>';

                            if (call_from == 'storage') {
                                set_additional_hyperlink_parameters(contract_group["contract_form_" + result[j][0]], 'maintain_rate_schedule', 'contract_id,contract_name', 'Storage,' + contract_group["contract_form_" + result[j][0]].getCombo('pipeline').getComboText());

                                if (contract_group.tabbar.cells("tab_" + object_id) != null) {
                                    var toolbar_obj = contract_group.tabbar.cells("tab_" + object_id).getAttachedToolbar();
                                    var form_obj = contract_group["contract_form_" + result[j][0]];
                                    
                                    if (form_obj.getFormData()['storage_asset_id'] == '') {
                                        toolbar_obj.disableItem('storage_asset');
                                    } else {
                                        toolbar_obj.enableItem('storage_asset');
                                    }

                                    form_obj.attachEvent('onChange', function(name, value) {
                                        if (name == 'storage_asset_id') {
                                            if (value == '') {
                                                toolbar_obj.disableItem('storage_asset');
                                            } else {
                                                toolbar_obj.enableItem('storage_asset');
                                            }
                                        }
                                    });
                                }
                            } else if (call_from == 'transportation') {
                                set_additional_hyperlink_parameters(contract_group["contract_form_" + result[j][0]], 'maintain_rate_schedule', 'contract_id', 'Transportation')
                            }

                            if (function_id == '10211400') {
                                reload_contract_component('');  
                            } else {
                                var check = contract_group["contract_form_" + result[0][0]].isItemChecked('is_lock');
                                if (check) {
                                    disable_item(1);
                                    checked_status = true;
                                } else {
                                    disable_item(0);
                                    checked_status = false;
                                }

                                var id = contract_group["contract_form_" + result[j][0]].getItemValue('contract_charge_type_id');
                                reload_contract_component(id);  
                            }
                        }
                    });

                    if (j == 0) {
                        var contract_mode_value = contract_group["contract_form_" + result[j][0]].getItemValue("contract_id");
                        contract_group["contract_component_grid_" + object_id].setUserData("", "contract_mode_xml", contract_mode_value);
                        
                        contract_group["contract_form_" + result[j][0]].attachEvent("onChange", function (name, value) {
                            if (name == 'contract_charge_type_id') {
                                reload_contract_component(value);   
                                var contract_mode_value = contract_group["contract_form_" + result[0][0]].getItemValue("contract_id");
                                contract_group["contract_component_grid_" + object_id].setUserData("", "contract_mode_xml", contract_mode_value);
                                contract_group["dataview_formula_" + object_id].clearAll();
                            }
                        });
                    }
                } else {//loads grid.[Not dyanmic, its static code block.]
                    if (!check_form_status) {
                        var grid_name = grid_definition_json[grid_no]["grid_name"];
                        var grid_label = JSON.parse(result[j][4]);
                        grid_label = grid_label['grid_label'];
                        
                        var index = tab_id + "_" + grid_name + "_" + object_id;
                        if (grid_name == 'transportation_contract_location') {
                            var location_index = index;
                        }
                        contract_group["contract_price_toolbar_grid_" + index] = contract_group["contract_tabs_layout_" + object_id + "_" + tab_id].cells("a").attachMenu();
                        contract_group["contract_tabs_layout_" + object_id + "_" + tab_id].cells("a").attachStatusBar({
                            height: 30,
                            text: '<div id="pagingAreaGrid_' +  grid_name + '_' + object_id + '"></div>'
                        });
                        
                        var pagination_div_name = 'pagingAreaGrid_' + grid_name + '_' + object_id;
                        
                        contract_group["contract_price_toolbar_grid_" + index].setIconsPath(js_image_path + "dhxmenu_web/");
                        if (grid_name == 'contract_fees') {
                            contract_group["contract_price_toolbar_grid_" + index].loadStruct(button_pricefees_json);
                        } else {
                            contract_group["contract_price_toolbar_grid_" + index].loadStruct(contractprice_toolbar_json);
                        }
                        
                        contract_group["contract_price_toolbar_grid_" + index].attachEvent('onClick', contract_group.grd_price_toolbar_click);

                        if (function_id == '10211400' && !has_rights_contract_copy) {// Only for transportation contract checking privilege.
                            contract_group["contract_price_toolbar_grid_" + index].setItemDisabled('add');
                            contract_group["contract_price_toolbar_grid_" + index].setItemDisabled('delete');
                        }
                        
                        var grid_obj = 'contract_group["contract_price_grid_' + index + '"]';
                        contract_group["contract_price_grid_" + index] = contract_group["contract_tabs_layout_" + object_id + "_" + tab_id].cells("a").attachGrid();
                        contract_group["contract_price_grid_" + index].setImagePath("<?php echo $image_path; ?>dhxtoolbar_web/");
                        contract_group["contract_price_grid_" + index].setHeader(grid_definition_json[grid_no]["column_label_list"]);
                        contract_group["contract_price_grid_" + index].setColumnIds(grid_definition_json[grid_no]["column_name_list"]);
                        contract_group["contract_price_grid_" + index].setColTypes(grid_definition_json[grid_no]["column_type_list"]);
                        if (grid_name == 'contract_fees') {
                            contract_group["contract_price_grid_" + index].attachHeader('#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter');
                        }
                        contract_group["contract_price_grid_" + index].setInitWidths(grid_definition_json[grid_no]["column_width"]);
                        contract_group["contract_price_grid_" + index].setColSorting(grid_definition_json[grid_no]["sorting_preference"]);
                        contract_group["contract_price_grid_" + index].setColumnsVisibility(grid_definition_json[grid_no]["set_visibility"]);
                        contract_group["contract_price_grid_" + index].setPagingWTMode(true, true, true, true);
                        contract_group["contract_price_grid_" + index].enablePaging(true, 25, 0, pagination_div_name);
                        contract_group["contract_price_grid_" + index].setPagingSkin('toolbar');
                        contract_group["contract_price_grid_" + index].setDateFormat(user_date_format, "%Y-%m-%d");
                        contract_group["contract_price_grid_" + index].enableMultiselect(true);
                        contract_group["contract_price_grid_" + index].enableColumnMove(true);
                        contract_group["contract_price_grid_" + index].enableValidation(true);
                        contract_group["contract_price_grid_" + index].setColValidators(grid_definition_json[grid_no]["validation_rule"]); 
                        contract_group["contract_price_grid_" + index].setUserData("", "grid_id", grid_name);
                        contract_group["contract_price_grid_" + index].setUserData("", "grid_label", grid_label);
                        contract_group["contract_price_grid_" + index].setUserData("", "grid_obj", grid_obj);
                        contract_group["contract_price_grid_" + index].init();
                        contract_group["contract_price_grid_" + index].enableHeaderMenu();
                        contract_group["contract_price_grid_" + index].enableColumnAutoSize(true); 
                        contract_group["contract_price_grid_" + index].loadOrderFromCookie(grid_name); 
                        contract_group["contract_price_grid_" + index].loadHiddenColumnsFromCookie(grid_name); 
                        contract_group["contract_price_grid_" + index].enableOrderSaving(grid_name); 
                        contract_group["contract_price_grid_" + index].enableAutoHiddenColumnsSaving(grid_name);
                        
                        contract_group["contract_price_grid_" + index].attachEvent("onRowSelect", function(id, ind) {
                            var active_tab_id = contract_group.tabbar.getActiveTab();
                            var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
                            var detail_active_tab = contract_group["contract_tabs_" + object_id].getActiveTab();
                            var menu_obj = contract_group["contract_tabs_layout_" + object_id + "_" + detail_active_tab].cells("a").getAttachedMenu();
                            if (has_rights_contract_delete) {
                                menu_obj.setItemEnabled('delete');
                            }
                        });
                        
                        contract_group["contract_price_grid_" + index].attachEvent("onValidationError", function(id, ind, value) {
                            var active_tab_id = contract_group.tabbar.getActiveTab();
                            var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
                            var detail_active_tab = contract_group["contract_tabs_" + object_id].getActiveTab();
                            var grid_obj = contract_group["contract_tabs_layout_" + object_id + "_" + detail_active_tab].cells("a").getAttachedObject();
                            
                            var message = "Invalid Data";
                            grid_obj.cells(id, ind).setAttribute("validation", message);
                            return true;
                        });

                        contract_group["contract_price_grid_" + index].attachEvent("onValidationCorrect", function(id, ind, value) {
                            var active_tab_id = contract_group.tabbar.getActiveTab();
                            var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
                            var detail_active_tab = contract_group["contract_tabs_" + object_id].getActiveTab();
                            var grid_obj = contract_group["contract_tabs_layout_" + object_id + "_" + detail_active_tab].cells("a").getAttachedObject();
                            grid_obj.cells(id, ind).setAttribute("validation", "");
                            return true;
                        });
                        
                        var sql_stmt = grid_definition_json[grid_no]["sql_stmt"];
                        var spa_url = sql_stmt.replace("<ID>", object_id);
                        
                        var param = {
                            "sql": spa_url
                        };
                        
                        param = $.param(param);
                        var param_url = js_data_collector_url + "&" + param;

                        contract_group["contract_price_grid_" + index].setUserData("", "grid_param_url", param_url);
                        contract_group["contract_price_grid_" + index].refresh_grid = function() {
                            this.clearAndLoad(this.getUserData("", "grid_param_url"));
                        }

                        // populate the dropdowns fields in grids.
                        if (grid_definition_json[grid_no]["dropdown_columns"] != null && grid_definition_json[grid_no]["dropdown_columns"] != '') {
                            var dropdown_columns = grid_definition_json[grid_no]["dropdown_columns"].split(',');
                            contract_group["contract_price_grid_" + index].setUserData("", "dropdown_loaded", 0);
                            var dropdown_length = dropdown_columns.length;
                            
                            _.each(dropdown_columns, function(item) {
                                var col_index = contract_group["contract_price_grid_" + index].getColIndexById(item);
                                contract_group.grid_dropdowns[item + '_' + object_id] = contract_group["contract_price_grid_" + index].getColumnCombo(col_index);
                                contract_group.grid_dropdowns[item + '_' + object_id].enableFilteringMode(true);
        
                                var cm_param = {"action": "spa_adiha_grid", "flag": "t", "grid_name": grid_definition_json[grid_no]["grid_name"], "column_name": item, "call_from": "grid"};
                                cm_param = $.param(cm_param);
                                var url = js_dropdown_connector_url + '&' + cm_param;
                                
                                /**
                                 * To Handle Grid data loading before dropdown load causing ID showing issue 
                                 */
                                var info = [];
                                info['dropdown_length'] = dropdown_length;
                                info['index'] = index;

                                contract_group.grid_dropdowns[item + '_' + object_id].load(url, function() {
                                    var dropdown_loaded = contract_group["contract_price_grid_" + this.index].getUserData("", "dropdown_loaded");
                                    dropdown_loaded++;
                                    if (dropdown_loaded == this.dropdown_length) {
                                        var grid_param_url = contract_group["contract_price_grid_" + this.index].getUserData("", "grid_param_url");
                                        contract_group["contract_price_grid_" + this.index].clearAndLoad(grid_param_url);
                                    } else {
                                        contract_group["contract_price_grid_" + this.index].setUserData("", "dropdown_loaded", dropdown_loaded);
                                    }
                                }.bind(info));
                            });
                        } else {
                            contract_group["contract_price_grid_" + index].loadXML(param_url);
                        }
                        
                        grid_no++;
                    }
                }
                //To enable menu item in update mode.
                contract_id = contract_group["contract_component_grid_" + object_id].getUserData("", "contract_mode_xml");
                if (!contract_id) {
                    contract_group["contract_toolbar_grid_" + object_id].setItemDisabled('t1');
                    contract_group["contract_toolbar_grid_" + object_id].setItemDisabled('t2');
                    contract_group["contract_toolbar_grid_" + object_id].setItemDisabled('gl_code');
                }
            }

            var is_new = contract_group.tabbar.tabs(active_tab_id).getText();
            if (is_new != 'New') {
                var selected_row = contract_group.grid.getSelectedRowId();
                if (selected_row != null) {
                    var col_index = contract_group.grid.getColIndexById("is_privilege_active");
                    var privilege_active = contract_group.grid.cells(selected_row, col_index).getValue();
                    var p_type_id = contract_group.grid.cells(selected_row, contract_group.grid.getColIndexById('type_id')).getValue(); 
                    // Privilege Check to disable/enable save button
                    if (privilege_active == 1) {
                        data = {
                                    "action": "spa_static_data_privilege",
                                    "flag": 'c',
                                    "type_id": p_type_id,
                                    "value_id": object_id
                               };
                        adiha_post_data("", data, "", "", "contract_group.check_privilege_callback");
                    }
                }
            }
            //Checking privileges.
            
            contract_group.tabbar.cells(active_tab_id).progressOff();
        }
        /*END*/
        
        reload_contract_component = function(contract_template_id) {
            var active_tab_id = contract_group.tabbar.getActiveTab();
            var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            
            if (contract_template_id != '') {
                contract_group["contract_toolbar_grid_" + object_id].setItemDisabled('add');
                contract_group["contract_toolbar_grid_" + object_id].setItemDisabled('t1');
                contract_group["contract_component_grid_" + object_id].clearAll();
                var find = 'object_id';
                combo_evalstring = '';
                grid_obj_name = 'contract_group[' + '"' + 'contract_component_grid_' + object_id + '"' + ']';
                var str = "EXEC spa_contract_group_detail @flag = 'r', @contract_component_template = '" + contract_template_id + "'";
                var spa_url = str.replace("<ID>", object_id);
                var additional_data1 = {
                    "sp_url": spa_url,
                    "grid_obj_name": grid_obj_name
                };
                url = php_script_loc_ajax + "load_grid_data.php"
                data = $.param(additional_data1);
                $.ajax({
                    type: "POST",
                    dataType: "json",
                    url: url,
                    data: data,
                    success: function(data) {
                        eval((data));
                    },
                    error: function(xht) {
                        show_messagebox('error');
                    }
                });
            } else {
                contract_group["contract_toolbar_grid_" + object_id].setItemEnabled('add');
                contract_group["contract_toolbar_grid_" + object_id].setItemEnabled('t1');
                contract_group["contract_component_grid_" + object_id].clearAll();
                var find = 'object_id';
                combo_evalstring = '';
                var re = new RegExp(find, 'g');
                combo_evalstring = combo_string.replace(re, object_id);
                eval(combo_evalstring);
                grid_obj_name = 'contract_group[' + '"' + 'contract_component_grid_' + object_id + '"' + ']';
                var str = "<?php echo $sql_string; ?>";
                var spa_url = str.replace("<ID>", object_id);
                var additional_data1 = {
                    "sp_url": spa_url,
                    "grid_obj_name": grid_obj_name
                };
                url = php_script_loc_ajax + "load_grid_data.php"
                data = $.param(additional_data1);
                $.ajax({
                    type: "POST",
                    dataType: "json",
                    url: url,
                    data: data,
                    success: function(data) {
                        eval((data));
                    },
                    error: function(xht) {
                        show_messagebox('error');
                    }

                });
            }
            
            contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("t1");
            contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("save");
            contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("additional");
            
            contract_group["contract_toolbar_grid_" + object_id].setItemDisabled('delete');
            contract_group["contract_toolbar_grid_" + object_id].setItemDisabled('copy');
            contract_group["contract_toolbar_grid_" + object_id].setItemDisabled('gl_code');
            
            /*
            contract_group["contract_component_grid_" + object_id].attachEvent("onRowSelect", function(){
                alert(contract_template_id);
                if(contract_template_id != '') {
                    contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("t1");
                } 
            });
            */
        }
        
        /****************************************************END of Triggers when the tree is double clicked.********************************************/
        /*********************************************************GRID******************************************************/
        /*****************************************************END OF GRID***************************************************/

        /************************************************************Contract component GRID TOOLBAR**************************************************************************/
        /*Function triggered when grid toolbar is clicked.*/
        /*START*/
        contract_group.grd_charge_toolbar_click = function(id) {
            var active_tab_id = contract_group.tabbar.getActiveTab();
            var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            var contract_component_store = new Array();
            if (id == 'add') {//when add is clicked.
                var RowsNum = contract_group["contract_component_grid_" + object_id].getRowsNum();
                RowsNum = RowsNum + 1;
                param = 'charge.type.php?contract_id=' + object_id + '&mode=i&count=' + RowsNum + '&is_pop=true&right='+ has_rights_contract_charge_type_ui;
                var is_win = dhxWins.isWindow('w3');
                if (is_win == true) {
                    w3.close();
                }                
                w3 = dhxWins.createWindow("w3", 520, 100, 565, 550);
                w3.center();
                w3.setText("Charge Type Detail");
                w3.setModal(true);
                w3.attachURL(param, false, true);
            } else if (id == 'delete') {//when is delete is clicked
                var selectedId = contract_group["contract_component_grid_" + object_id].getSelectedRowId();
                if (!selectedId) {
                    var message = get_message('VALIDATE_DATA');
                    show_messagebox(message);
                    return false;
                } else {
                    var grid_xml = '';

                    var deleted_xml = contract_group["contract_component_grid_" + object_id].getUserData("", "grid_delete_xml");
                    grid_xml = grid_xml + '<GridDelete contract_detail_id=' + '"' + selectedId + '"' + '></GridDelete>';
                    contract_group["contract_component_grid_" + object_id].setUserData("", "grid_delete_xml", grid_xml);
                    var grid_xml = '<Root>';
                    var grid_delete_xml = contract_group["contract_component_grid_" + object_id].getUserData("", "grid_delete_xml");
                    grid_xml = grid_xml + grid_delete_xml + '</Root>';
                    contract_group["contract_component_grid_" + object_id].setUserData("", "grid_update_xml", grid_xml);
                    var xml = contract_group["contract_component_grid_" + object_id].getUserData("", "grid_update_xml");
                    //alert(xml);
                    //return;
                    data = {
                        "action": "spa_contract_group_detail_UI",
                        "flag": "l",
                        "xml": xml
                    };
                    adiha_post_data('confirm', data, '', '', 'contract_group.delete_charge_callback');

                }
            } else if (id == 'save') {//when is save is clicked.
                var grid_xml = '<Root>';
                var i = 1;
                var save_validation_status = 1;
                contract_group["contract_component_grid_" + object_id].forEachRow(function(id) {
                    var contract_detail_id = contract_group["contract_component_grid_" + object_id].cells(id, 0).getValue();
                    var contract_component = contract_group["contract_component_grid_" + object_id].cells(id, 1).getValue();
                    if (!contract_component) {
                        var message = get_message('SELECT_DATA');
                        show_messagebox(message);
                        save_validation_status = 0;
                        return;
                    }
                    var a = contract_component_store.indexOf(contract_component);
                    if (a >= 0) {
                        var message = get_message('DUPLICATE_DATA');
                        show_messagebox(message);
                        save_validation_status = 0;
                        return;
                    }
                    contract_component_store.push(contract_component);
                    if (contract_detail_id) {
                        grid_xml = grid_xml + '<GridUpdate contract_id=' + '"' + object_id + '"' + ' contract_detail_id=' + '"' + contract_detail_id + '"' + ' contract_component=' + '"' + contract_component + '"' + ' sequence_order=' + '"' + i + '"' + '></GridUpdate>';
                    }
                    else {
                        grid_xml = grid_xml + '<GridInsert contract_id=' + '"' + object_id + '"' + ' contract_detail_id=' + '"NULL"' + ' contract_component=' + '"' + contract_component + '"' + ' sequence_order=' + '"' + i + '"' + '></GridInsert>';
                    }
                    i++;
                });
                if (save_validation_status) {
                    var grid_delete_xml = contract_group["contract_component_grid_" + object_id].getUserData("", "grid_delete_xml");
                    xml = grid_xml + grid_delete_xml + '</Root>';
                    contract_group["contract_component_grid_" + object_id].setUserData("", "grid_update_xml", grid_xml);
                    var xml = contract_group["contract_component_grid_" + object_id].getUserData("", "grid_update_xml");
                    data = {
                        "action": "spa_contract_group_detail_UI",
                        "flag": "v",
                        "xml": xml
                    };
                    adiha_post_data('alert', data, '', '', '');
                    var str = "<?php echo $sql_string; ?>";
                    var spa_url = str.replace("<ID>", object_id);
                    sp_url = {"sp_string": spa_url};
                    result = adiha_post_data("return_data", sp_url, "", "", "contract_group.refresh_contract_component_grid_callback");
                }
            } else if (id == 'gl_code') {//when gl code mapping is clicked.
                var grid_data = contract_group["contract_component_grid_" + object_id].getSelectedRowId();
                if (!grid_data) {
                    var message = get_message('VALIDATE_DATA');
                    show_messagebox(message);
                    return false;
                }
                param = 'gl.code.php?contract_detail_id=' + grid_data + '&is_pop=true&checked_status='+checked_status;
                var is_win = dhxWins.isWindow('w2');
                if (is_win == true) {
                    contract_group.w2.close();
                }

                contract_group.w2 = dhxWins.createWindow("w2", 220, 10, 535, 230);
                contract_group.w2.setText("GL Code Mapping");
                contract_group.w2.setModal(true);
                contract_group.w2.attachURL(param, false, true);
            } else if (id == 'edit') {//when edit is clicked.

                var grid_data = contract_group["contract_component_grid_" + object_id].getSelectedRowId();
                var type = contract_group["contract_component_grid_" + object_id].cells(grid_data, 1).getValue();
                param = 'charge.type.php?contract_detail_id=' + grid_data + '&contract_id=' + object_id + '&type=' + type + '&mode=u&is_pop=true&right='+ has_rights_contract_charge_type_ui + '&lock_status='+ checked_status;
                //alert(param)
                var is_win = dhxWins.isWindow('w5');
                if (is_win == true) {
                    w5.close();
                }                
                w5 = dhxWins.createWindow("w5", 520, 100, 565, 550);
                w5.center();
                w5.setText("Charge Type Detail");
                w5.setModal(true);
                w5.attachURL(param, false, true);
                w5.attachEvent("onContentLoaded", function(win) {
                    var delay = 1000; //1 seconds
                    setTimeout(function() {
                        var layout_obj = contract_group["inner_grid_layout_" + object_id].cells('b').getAttachedObject();
                        if (layout_obj instanceof dhtmlXDataView) {
                            contract_group["dataview_formula_" + object_id].clearAll();
                            return true;
                        } else if (layout_obj instanceof dhtmlXGridObject) {
                            contract_group["inner_grid_layout_" + object_id].cells('b').detachObject();
                        }
                    }, delay);

                });
                w5.attachEvent("onClose", function(win) {
                    contract_group.charge_type_post_callback();
                    return true;
                });
            } else if (id == 'copy') {//when copy is clicked.
                var grid_data = contract_group["contract_component_grid_" + object_id].getSelectedRowId();
                var type = contract_group["contract_component_grid_" + object_id].cells(grid_data, 1).getValue();
                param = 'charge.type.php?contract_detail_id=' + grid_data + '&contract_id=' + object_id + '&type=' + type + '&mode=c&is_pop=true&right='+ has_rights_contract_charge_type_ui;
                var is_win = dhxWins.isWindow('w5');
                if (is_win == true) {
                    w5.close();
                }
                w5 = dhxWins.createWindow("w3", 320, 0, 600, 600);
                w5.setText("Charge Type Detail");
                w5.setModal(true);
                w5.attachURL(param, false, true);
            } else if (id == 'excel') {
                contract_group["contract_component_grid_" + object_id].toExcel(php_script_loc_ajax + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
            } else if (id == 'pdf') {
                contract_group["contract_component_grid_" + object_id].toPDF(php_script_loc_ajax + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
            } else if (id == 'download_template') {
                var data = {
                    "action"                : "spa_excel_addin_settlement_process",
                    "flag"                  : "D",
                    "contract_id"           : object_id
                };
                var additional_data = {
                    "type": 'return_array'
                };
                
                data = $.param(data) + "&" + $.param(additional_data);
                $.ajax({
                    type: "POST",
                    dataType: "json",
                    url: js_form_process_url,
                    async: true,
                    data: data,
                    success: function(data) {
                        var status =  data.json[0][0];
                        var file_name = data.json[0][1];
                        if (status == 'success') {
                           window.location = app_php_script_loc + 'force_download.php?path=dev/shared_docs/temp_Note/'+ file_name;
                        } else {
                            show_messagebox('Issue while downloading file.');
                        }

                    }
                });
            } else if (id == 'upload_template') {
                var tab_id = contract_group.tabbar.getActiveTab();
                contract_group.open_document(tab_id,'contract_window_template');
            }
        }
        /*END*/
        /*
         * Delete charge grid callback
         * @param {type} result
         * @returns {undefined}         */
        
        contract_group.delete_charge_callback = function(result) {
            var active_tab_id = contract_group.tabbar.getActiveTab();
            var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            if(contract_group["dataview_formula_" + object_id])
            contract_group["dataview_formula_" + object_id].clearAll();
            contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("t1");
            contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("save");
            contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("additional");
            var str = "<?php echo $sql_string; ?>";
            var spa_url = str.replace("<ID>", object_id);
            sp_url = {"sp_string": spa_url};
            result = adiha_post_data("return_data", sp_url, "", "", "contract_group.refresh_contract_component_grid_callback");
        }
        /*
         * Refresh 
         * @param {type} result
         * @returns {undefined}
         */
        contract_group.refresh_contract_component_grid_callback = function(result) {
            //alert(result)
            var active_tab_id = contract_group.tabbar.getActiveTab();
            var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            grid_delete_xml = contract_group["contract_component_grid_" + object_id].getUserData("", "grid_delete_xml");
            grid_update_xml = contract_group["contract_component_grid_" + object_id].getUserData("", "grid_update_xml");
            formula_delete_xml = contract_group["contract_component_grid_" + object_id].getUserData("", "formula_delete_xml");
            form_validate_code_xml = contract_group["contract_component_grid_" + object_id].getUserData("", "form_validate_code_xml");
            pricegrid_delete_xml = contract_group["contract_component_grid_" + object_id].getUserData("", "pricegrid_delete_xml");
            contract_mode_xml = contract_group["contract_component_grid_" + object_id].getUserData("", "contract_mode_xml");
            contract_name_store = contract_group["contract_component_grid_" + object_id].getUserData("", "contract_name_store");
            contract_group["contract_component_grid_" + object_id].clearAll();
            contract_group["contract_component_grid_" + object_id].parse(result, "js");
            contract_group["contract_component_grid_" + object_id].setUserData("", "grid_delete_xml", grid_delete_xml);
            contract_group["contract_component_grid_" + object_id].setUserData("", "grid_update_xml", grid_update_xml);
            contract_group["contract_component_grid_" + object_id].setUserData("", "formula_delete_xml", formula_delete_xml);
            contract_group["contract_component_grid_" + object_id].setUserData("", "form_validate_code_xml", form_validate_code_xml);
            contract_group["contract_component_grid_" + object_id].setUserData("", "pricegrid_delete_xml", pricegrid_delete_xml);
            contract_group["contract_component_grid_" + object_id].setUserData("", "contract_mode_xml", contract_mode_xml);
            contract_group["contract_component_grid_" + object_id].setUserData("", "contract_name_store", contract_name_store);
        }
        /*******************************************END OF GRID TOOLBAR******************************************************************/
        /***********************************************Contract Price Toolbar grid*******************************************************/
        /*START*/
        contract_group.grd_price_toolbar_click = function(id) {
            var active_tab_id = contract_group.tabbar.getActiveTab();
            var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            var detail_active_tab = contract_group["contract_tabs_" + object_id].getActiveTab();
            var grid_obj = contract_group["contract_tabs_layout_" + object_id + "_" + detail_active_tab].cells("a").getAttachedObject();
            var menu_obj = contract_group["contract_tabs_layout_" + object_id + "_" + detail_active_tab].cells("a").getAttachedMenu();
            
            if (id == 'add') {//when add is clicked.
                var new_id = (new Date()).valueOf();
                new_id = new_id + '_grid';
                grid_obj.addRow(new_id, "");
                grid_obj.selectRow(grid_obj.getRowIndex(new_id), false, false, true);
                if (has_rights_contract_delete) {
                    menu_obj.setItemEnabled('delete');
                }
                grid_obj.forEachRow(function(row) {
                    grid_obj.forEachCell(row, function(cellObj, ind){
                        grid_obj.validateCell(row, ind)
                    });
                });
            } else if (id == 'delete') {//when is delete is clicked
                var selectedId = grid_obj.getSelectedRowId();
                if (!selectedId) {
                    var message = get_message('VALIDATE_DATA');
                    show_messagebox(message);
                    return false;
                } else {
                    var grid_xml = '';
                    var deleted_xml = grid_obj.getUserData("", "pricegrid_delete_xml");
                    var del_array = new Array();
                    del_array = (selectedId.indexOf(",") != -1) ? selectedId.split(",") : selectedId.split();
                    
                    
                    $.each(del_array, function(index, value) {
                        if ((grid_obj.cells(value, 0).getValue() != "") || (grid_obj.getUserData(value, "row_status") != "")) {
                            grid_xml += '<GridRow ';
                            for (var cellIndex = 0; cellIndex < grid_obj.getColumnsNum(); cellIndex++) {
                                grid_xml += grid_obj.getColumnId(cellIndex) + '= "' + grid_obj.cells(value, cellIndex).getValue() + '" ';
                            }
                            
                            grid_xml += '></GridRow>';
                        }
                        grid_obj.deleteRow(value);
                    });
                    if (deleted_xml)
                        grid_xml = grid_xml + deleted_xml;
                        
                    grid_obj.setUserData("", "pricegrid_delete_xml", grid_xml);
                    
                    menu_obj.setItemDisabled('delete');
                }
            } else if (id == 'excel') {
                grid_obj.toExcel(php_script_loc_ajax + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
            } else if (id == 'pdf') {
                grid_obj.toPDF(php_script_loc_ajax + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
            } else if (id == 'add_charges') {
                open_product_charges_browse(grid_obj);
            } 
        }
        /*END*/
        /***********************************************END of Contract Price Toolbar grid************************************************/
        /*******************************************************DATAVIEW****************************************************************/
        /*Triggers to load dataview for displaying formula.*/
        /*START*/
        contract_group.load_dataview_formula = function() {
            var is_win = dhxWins.isWindow('w3');
            if (is_win == true) {
                contract_group["dataview_formula_" + object_id].stopEdit();
                contract_group["dataview_formula_" + object_id].clearAll();
                return;
            }

            var active_tab_id = contract_group.tabbar.getActiveTab();
            var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            var selectedId = contract_group["contract_component_grid_" + object_id].getSelectedRowId();
            var contract_type = contract_group["contract_component_grid_" + object_id].cells(selectedId, 0).getValue();
            var flat_fee = contract_group["contract_component_grid_" + object_id].cells(selectedId, 2).getValue();
        
            if(has_rights_contract_charge_type_delete && !checked_status)
                contract_group["contract_toolbar_grid_" + object_id].setItemEnabled('delete');
            if(has_rights_contract_charge_type_copy && !checked_status)
                contract_group["contract_toolbar_grid_" + object_id].setItemEnabled('copy');
            // if(!checked_status)
            contract_group["contract_toolbar_grid_" + object_id].setItemEnabled('gl_code');
            contract_group["contract_toolbar_formula_" + object_id].setItemDisabled('save'); // For case dataview switched from excel to formula
            contract_group["inner_grid_layout_" + object_id].cells('b').progressOff(); // Close loader icon for case dataview switched from excel to formula
            if (contract_type != 'Formula' && contract_type!= 'Excel') {
                contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("t1");
                contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("additional");
                contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("save");
                layout_obj = contract_group["inner_grid_layout_" + object_id].cells('b').getAttachedObject();
                if (layout_obj instanceof dhtmlXDataView) {
                    contract_group["dataview_formula_" + object_id].stopEdit();
                    contract_group["dataview_formula_" + object_id].clearAll();
                } else if (layout_obj instanceof dhtmlXGridObject) {
                    contract_group["inner_grid_layout_" + object_id].cells('b').detachObject();
                }
                var selectedId = contract_group["contract_component_grid_" + object_id].getSelectedRowId();
                var ind = contract_group["contract_component_grid_" + object_id].getSelectedCellIndex();
                var n = selectedId.indexOf("_grid");//To check if the dataview is inserted new or updated old id.
                return false;
            } else if ((contract_type == 'Formula') && (flat_fee)) {
                contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("t1");
                contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("additional");
                contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("save");
                layout_obj = contract_group["inner_grid_layout_" + object_id].cells('b').getAttachedObject();
                if (layout_obj instanceof dhtmlXDataView) {
                    contract_group["dataview_formula_" + object_id].stopEdit();
                    contract_group["dataview_formula_" + object_id].clearAll();
                } else if (layout_obj instanceof dhtmlXGridObject) {
                    contract_group["inner_grid_layout_" + object_id].cells('b').detachObject();
                }
                var selectedId = contract_group["contract_component_grid_" + object_id].getSelectedRowId();
                var ind = contract_group["contract_component_grid_" + object_id].getSelectedCellIndex();
                var n = selectedId.indexOf("_grid");//To check if the dataview is inserted new or updated old id.
                return false;
            } else {
                layout_obj = contract_group["inner_grid_layout_" + object_id].cells('b').getAttachedObject();
                if (layout_obj instanceof dhtmlXDataView) {
                    contract_group["dataview_formula_" + object_id].stopEdit();
                    contract_group["dataview_formula_" + object_id].clearAll();
                }
                if(!checked_status)
                    contract_group["contract_toolbar_formula_" + object_id].setItemEnabled("t1");
                
                    if (contract_type == 'Formula') {
                    contract_group["dataview_formula_" + object_id] = contract_group["inner_grid_layout_" + object_id].cells('b').attachDataView(
                            {
                                edit: true,
                                type: {
                                    template: "<?php echo $template; ?>",
                                    template_edit: "<textarea class='dhx_item_editor' bind='obj.description_1'>",
                                    padding: 10,
                                    height: 60,
                                    width: 800,
                                },
                                tooltip: {
                                    template: "<?php echo $tooltip; ?>"
                                },
                                drag: true,
                                select: true,
                            });
                    contract_group["dataview_formula_" + object_id].attachEvent("oneditkeypress", contract_group.item_clicked);
                    contract_group["dataview_formula_" + object_id].attachEvent("onAfterDrop", contract_group.item_moved);
                    contract_group["dataview_formula_" + object_id].attachEvent("onAfterSelect", contract_group.item_selected);
                    var selectedId = contract_group["contract_component_grid_" + object_id].getSelectedRowId();
                    var ind = contract_group["contract_component_grid_" + object_id].getSelectedCellIndex();
                    var n = selectedId.indexOf("_grid");//To check if the dataview is inserted new or updated old id.
                    
                    var contract_charge_type_id = ''
                    contract_group["contract_tabs_" + object_id].forEachTab(function(tab){
                        if (tab.getText() == 'General') {
                            var form_obj = tab.getAttachedObject().cells("a").getAttachedObject();
                            contract_charge_type_id = form_obj.getItemValue('contract_charge_type_id');
                        }
                    });
                    
                    if (selectedId && n < 0 && contract_charge_type_id == '') {
                        var selectedId = contract_group["contract_component_grid_" + object_id].getSelectedRowId();
                        var ind = contract_group["contract_component_grid_" + object_id].getSelectedCellIndex();
                        data = {
                            "action": "spa_contract_group_detail",
                            "flag": "a",
                            "contract_detail_id": selectedId
                        };
                        adiha_post_data('return_array', data, '', '', ' contract_group.build_formula_dataview', true);

                    }

                    
                    if (n < 0) {
                        contract_group["contract_toolbar_formula_" + object_id].setItemEnabled("add");
                        //contract_group["contract_toolbar_formula_" + object_id].setItemEnabled("save");
                        contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("additional");
                        contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("delete");
                    }
                    else {
                        contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("t1");
                        contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("save");
                        contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("additional");

                    }
                    if (!has_rights_contract_formula_ui) {
                        contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("add");
                        //contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("additional");
                        contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("save");
                    }
                    if (!has_rights_contract_formula_ui) {
                        contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("delete");
                    }
                    
                    var contract_charge_type_id = ''
                    contract_group["contract_tabs_" + object_id].forEachTab(function(tab){
                    if (tab.getText() == 'General') {
                            var form_obj = tab.getAttachedObject().cells("a").getAttachedObject();
                            contract_charge_type_id = form_obj.getItemValue('contract_charge_type_id');
                    }
                    });
                    
                    if (contract_charge_type_id != '' && function_id != '10211400') {
                        contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("t1");
                        contract_group["contract_toolbar_grid_" + object_id].setItemDisabled('gl_code');
                    }
                } else if (contract_type == 'Excel') {
                    contract_group["dataview_formula_excel_engine" + object_id] = contract_group["inner_grid_layout_" + object_id].cells('b').attachGrid();
                    contract_group["dataview_formula_excel_engine" + object_id].setImagePath(js_image_path + '/dhxtoolbar_web/');
                    contract_group["dataview_formula_excel_engine" + object_id].setHeader('Data Component Detail ID,Data Component,Granularity,Value,User Defined Function,Formula_id');
                    contract_group["dataview_formula_excel_engine" + object_id].setColAlign('left,left,left,left,left');
                    contract_group["dataview_formula_excel_engine" + object_id].setColumnIds('data_component_detail_id,data_component_id,granularity,value,user_defined_function,formula_id');
                    contract_group["dataview_formula_excel_engine" + object_id].setColTypes('ro,combo,combo,combo,ro,ro');
                    contract_group["dataview_formula_excel_engine" + object_id].setInitWidths('100,130,130,130,400,100');
                    contract_group["dataview_formula_excel_engine" + object_id].enableEditEvents(true,true,false,false);
                    contract_group["dataview_formula_excel_engine" + object_id].enableValidation(true);
                    contract_group["dataview_formula_excel_engine" + object_id].setColValidators("ValidNumeric");
                    contract_group["dataview_formula_excel_engine" + object_id].init();
                    contract_group["dataview_formula_excel_engine" + object_id].enableMultiselect(true);
                    contract_group["dataview_formula_excel_engine" + object_id].setColumnsVisibility('true,false,false,false,false,true');
                
                    var grid_obj = contract_group["dataview_formula_excel_engine" + object_id];
                    selectedId = contract_group["contract_component_grid_" + object_id].getSelectedRowId();
                    var is_inserted = selectedId.indexOf("_grid");//To check if the grid is inserted new or updated old id.
                    grid_obj.attachEvent("onValidationError",function(id,ind,value){
                        var message = "Invalid Data";
                        grid_obj.cells(id,ind).setAttribute("validation", message);
                        return true;
                    });
                    grid_obj.attachEvent("onValidationCorrect",function(id,ind,value){
                        grid_obj.cells(id,ind).setAttribute("validation", "");
                        return true;
                    });

                    var col_data_component_id = grid_obj.getColIndexById('data_component_id');
                    var col_value = grid_obj.getColIndexById('value');
                    var col_user_defined_function = grid_obj.getColIndexById('user_defined_function');
                    var col_formula_id = grid_obj.getColIndexById('formula_id');
                    var col_granularity = grid_obj.getColIndexById('granularity');
                    var cmb_data_component = grid_obj.getColumnCombo(col_data_component_id);
                    var cmb_granularity = grid_obj.getColumnCombo(col_granularity);



                    grid_obj.attachEvent("onRowDblClicked", function(rId,cInd){
                        var selected_data_component = grid_obj.cells(rId,col_data_component_id).getValue().split('_');
                        var formula_id = grid_obj.cells(rId,col_formula_id).getValue();
                        formula_id = (formula_id == '')?undefined:formula_id;
                        if (cInd == col_user_defined_function && selected_data_component[1] == 107303) {
                            select_clicked(formula_id,1,undefined,undefined);
                        }
                    });

                    grid_obj.attachEvent("onRowSelect", function(rId,cInd){
                        contract_group["contract_toolbar_formula_" + object_id].setItemEnabled("delete");
                    });

                    var combo_price = [];
                    var combo_meter = [];
                    cm_param = {
                        "action"                : "spa_getAllMeter",
                        "flag"                  : "s",
                        "has_blank_option"      : "false"
                    };


                    cm_param = $.param(cm_param);
                    var url = js_dropdown_connector_url + '&' + cm_param;
                    $.ajax({
                        url: url,
                        success: function(data){
                            combo_meter = data;
                        }
                    });

                    cm_param = {
                        "action"                : "spa_source_price_curve_def_maintain",
                        "flag"                  : "l",
                        "has_blank_option"      : "false"
                    };

                    cm_param = $.param(cm_param);
                    url = js_dropdown_connector_url + '&' + cm_param;
                    $.ajax({
                        url: url,
                        success: function(data){
                            combo_price = data;
                        }
                    });

                    cmb_data_component.attachEvent("onChange", function(value, text,id,default_value) {
                        if (value) {
                            var array_data_component_id  = value.split('_');
                            var data_component_id = array_data_component_id[1];
                            var row_id = '';
                            if (id && id != '' && id != undefined) {
                                row_id = id;
                            } else {
                                row_id = grid_obj.getSelectedRowId();
                            }
                            var cmb_value = grid_obj.cells(row_id,col_value).getCellCombo();
                            switch (data_component_id) {
                                case '107300': // Meter
                                case '107302': // Price
                                    grid_obj.cells(row_id,col_value).setDisabled(false);
                                    grid_obj.cells(row_id,col_user_defined_function).setDisabled(true);
                                    grid_obj.cells(row_id,col_user_defined_function).setValue('');
                                    grid_obj.cells(row_id,col_value).setValue('');
                                    var combo_option = [];
                                    if (data_component_id == '107300') {
                                        combo_option = combo_meter;
                                    } else if (data_component_id == '107302') {
                                        combo_option = combo_price;
                                    }
                                    cmb_value.load(combo_option, function() {
                                        if (default_value && default_value != undefined) {
                                            grid_obj.cells(row_id,col_value).setValue(default_value);
                                        }
                                    });

                                    break;
                                case '107301': // Deal
                                    grid_obj.cells(row_id,col_value).setDisabled(true);
                                    grid_obj.cells(row_id,col_user_defined_function).setDisabled(true);
                                    grid_obj.cells(row_id,col_user_defined_function).setValue('');
                                    grid_obj.cells(row_id,col_value).setValue('');
                                    break;
                                case '107303':
                                    //UDSQL
                                    grid_obj.cells(row_id,col_value).setValue('');
                                    grid_obj.cells(row_id,col_value).setDisabled(true);
                                    grid_obj.cells(row_id,col_user_defined_function).setDisabled(false);
                                    break;
                            }
                        }
                    });

                    cm_param = {
                        "action"                : "spa_data_component",
                        "flag"                  : "c",
                        "has_blank_option"  : "false"
                    };
                    var cm_param_data_component_id = $.param(cm_param);
                    url = js_dropdown_connector_url + '&' + cm_param_data_component_id;
                    cmb_data_component.load(url, function() {
                    });

                    var cm_param = {
                        "action"                : "spa_StaticDataValues",
                        "flag"                  : "h",
                        "type_id"                : "978",
                        "license_not_to_static_value_id" : "",
                        "has_blank_option"  : "true"
                    };
                    var cm_param_granularity = $.param(cm_param);
                    url = js_dropdown_connector_url + '&' + cm_param_granularity;
                    cmb_granularity.load(url, function() {
                        if (selectedId && is_inserted < 0) {
                            contract_group.refresh_dataview_formula_grid();
                        }
                    });
                }
                return false;
            }
        }
        /*END*/
        /**
         * callback function
         * contract_group.build_formula_dataview() [gets the group_formula id to call for laoding dataview.]
         * @param [array] result
         * @return [callback function]
         */
        /*START*/
        contract_group.build_formula_dataview = function(result) {
            if (result[0][4]) {
                var group_formula_id = result[0][4];
                data = {
                    "action": "spa_formula_nested",
                    "flag": "s",
                    "formula_group_id": group_formula_id
                };
                adiha_post_data("return_json", data, "", "", "contract_group.callback_dataview_load");
            }
        }
        /*END*/
        /*Callback function to load the data of the dataview*/
        /*START*/
        contract_group.callback_dataview_load = function(result) {
            var active_tab_id = contract_group.tabbar.getActiveTab();
            var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            contract_group["dataview_formula_" + object_id].parse(result, "json");

        }
        /*END*/
        /**
         * contract_group.item_clicked() [this triggers when dataview item clicked.]
         * @param [string] code
         */
        contract_group.item_clicked = function(code) {
            if (!has_rights_contract_formula_ui)
                return;
            if (code == 13)
                this.stopEdit();
            else if (code == 27)
                this.stopEdit(true);
        }
        /**
         * contract_group.item_moved() [this function moves item in dataview.]
         * @param [string] context
         */
        contract_group.item_moved = function(context) {
            if (!has_rights_contract_formula_ui)
                return;
            var active_tab_id = contract_group.tabbar.getActiveTab();
            var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            var dataview_object = contract_group["dataview_formula_" + object_id];
            var count = dataview_object.dataCount();
            for (i = 0; i < count; i++) {
                id = dataview_object.idByIndex(i);
                dataview_object.item(id).row = i + 1;
                dataview_object.refresh(id);
            }
            var xml = contract_group.get_sorted_data_for_formula();
            submit_sp(xml, 'x');
        }
        /**
         * contract_group.item_selected() [this function is triggered when dataview is clicked.]
         * @param [string] context
         */
        contract_group.item_selected = function(id) {
            var active_tab_id = contract_group.tabbar.getActiveTab();
            var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            var dataview_object = contract_group["dataview_formula_" + object_id];
            if(!checked_status)
            contract_group["contract_toolbar_formula_" + object_id].setItemEnabled("save");
            if(has_rights_contract_formula_ui){
            contract_group["contract_toolbar_formula_" + object_id].setItemEnabled("delete");
            }
            if (dataview_object.item(id).nested_id) {
                contract_group["contract_toolbar_formula_" + object_id].setItemEnabled("additional");
            }
            else {
                contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("additional");
            }
            if (!has_rights_contract_formula_ui) {
                contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("add");
                //contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("additional");
                contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("save");
            }
        }
        /**
         * contract_group.get_sorted_data_for_formula() [this function gives new position of dataview items.]
         * @return [returns the formula sorted data from formula grid in xml format.]
         */
        contract_group.get_sorted_data_for_formula = function() {
            if (!has_rights_contract_formula_ui)
                return;
            var active_tab_id = contract_group.tabbar.getActiveTab();
            var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            var dataview_object = contract_group["dataview_formula_" + object_id];
            var count = dataview_object.dataCount();
            var return_ids_xml = '<Root>';
            for (i = 0; i < count; i++) {
                id = dataview_object.idByIndex(i);
                nested_id = dataview_object.item(id).nested_id;
                seq_order = dataview_object.item(id).row;
                return_ids_xml += '<PSRecordSet nested_id="' + nested_id + '" seq_order="' + seq_order + '"></PSRecordSet>';
            }
            return_ids_xml += '</Root>';
            return return_ids_xml;
        }
        /**
         * submit_sp() [this is the function to submit.]
         * @param [string] xml
         * @param [string] flag
         */
        function submit_sp(xml, flag) {
            data = {
                "action": "spa_contract_group_detail_UI",
                "flag": flag,
                "xml": xml
            };
            adiha_post_data('alert', data, '', '', '');
        }
        /**
         * select_clicked() [this function trigger when dataview item selected.]
         * @param [string] formula_id of the formula.
         * @return [opens up formula builder screen.]
         */
        function select_clicked(formula_id,row,nested_id,formula_group_id) {
            if (!has_rights_contract_formula_ui)
                return;
            if (typeof formula_id === "undefined")
                formula_id = 'NULL';
            var g = isNaN(formula_group_id);
            if(g)
                formula_group_id = 'NULL';
            if (typeof nested_id === "undefined")
                nested_id = 'NULL';
            param = '../../_setup/formula_builder/formula.editor.php?formula_id=' + formula_id +'&formula_group_id='+formula_group_id+'&sequence_number='+row+'&formula_nested_id='+nested_id+'&call_from=other&is_pop=true&checked_status='+checked_status;
            var is_win = dhxWins.isWindow('w1');
            if (is_win == true) {
                w1.close();
            }
            w1 = dhxWins.createWindow("w1", 20, 10, 900, 530);
            w1.setText("Formula Editor");
            w1.centerOnScreen();
            w1.setModal(true);
            w1.attachURL(param, false, true);
        }
        /**
         * callback function
         * formula_editor_callback() [this function triggered after the formula builder is closed.]
         * @param [array] return_value
         * @return [callback function]
         */
        function formula_editor_callback(return_value) {
            var active_tab_id = contract_group.tabbar.getActiveTab();
            var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            var selected_id_charge = contract_group["contract_component_grid_" + object_id].getSelectedRowId();
            var contract_type = contract_group["contract_component_grid_" + object_id].cells(selected_id_charge, 0).getValue();
            if (contract_type == 'Formula') {
                var dataview_object = contract_group["dataview_formula_" + object_id];
                var id = dataview_object.getSelected();
                if (return_value[0] == 'Remove') {
                    formula_group_id = 'undefined';
                    dataview_object.item(id).formula_id = formula_group_id;
                    dataview_object.item(id).formula = formula_group_id;
                    dataview_object.refresh(id);
                } else {
                    formula_group_id = return_value[0];
                    formula_value = return_value[1];
                    formula_value = formula_value.replace(/</g, "&lt;");
                    dataview_object.item(id).formula_id = formula_group_id;
                    dataview_object.item(id).formula = formula_value;
                    dataview_object.refresh(id);
                }
            } else if (contract_type == 'Excel'){
                var grid_obj = contract_group["dataview_formula_excel_engine" + object_id];
                var row_id = grid_obj.getSelectedRowId();
                var col_user_defined_function = grid_obj.getColIndexById('user_defined_function');
                var col_formula_id = grid_obj.getColIndexById('formula_id');
                if (return_value[0] == 'Remove') {
                    formula_group_id = 'undefined';
                    grid_obj.cells(row_id,col_user_defined_function).setValue('');
                    grid_obj.cells(row_id,col_formula_id).setValue('');
                    grid_obj.cells(row_id, col_user_defined_function).cell.wasChanged = true;
                } else {
                    formula_group_id = return_value[0];
                    formula_value = return_value[1];
                    formula_value = formula_value.replace(/</g, "&lt;");
                    grid_obj.cells(row_id,col_user_defined_function).setValue(formula_value);
                    grid_obj.cells(row_id,col_formula_id).setValue(formula_group_id);
                    grid_obj.cells(row_id, col_user_defined_function).cell.wasChanged = true;
                }
            }

        }
        /****************************************************END OF DATAVIEW************************************************************/

        /*****************************************************FORMULA TOOLBAR**************************************************************/
        /**
         * contract_group.grd_formula_toolbar_click() [this function is triggered when formula toolbar is triggered.]
         * @param [int] id id of the button.[add,save and delete]
         */
        contract_group.grd_formula_toolbar_click = function(id) {
            var active_tab_id = contract_group.tabbar.getActiveTab();
            var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            var selected_id_charge = contract_group["contract_component_grid_" + object_id].getSelectedRowId();
            var contract_type = contract_group["contract_component_grid_" + object_id].cells(selected_id_charge, 0).getValue();
            if (contract_type == 'Formula') {
                switch (id) {
                    case 'add':
                        //when add is clicked.
                        var count = contract_group["dataview_formula_" + object_id].dataCount();
                        count = count + 1;
                        contract_group["dataview_formula_" + object_id].add({
                            id: 'dataview_' + count,
                            row: count,
                            description_1: "",
                            formula: "",
                            nested_id: ""
                        });
                        contract_group["dataview_formula_" + object_id].select('dataview_' + count);
                        contract_group["dataview_formula_" + object_id].show('dataview_' + count);
                        break;
                    case 'save':
                        //when save is clicked.
                        var selectedGridId = contract_group["contract_component_grid_" + object_id].getSelectedRowId();
                        var formula_xml = '<Root contract_detail_id="' + selectedGridId + '">';
                        var i = 1;
                        var items = contract_group["dataview_formula_" + object_id].dataCount();
                        if (items > 0) {
                            id = contract_group["dataview_formula_" + object_id].first();
                            data = contract_group["dataview_formula_" + object_id].get(id);
                            for (var loop = 1; loop <= items; loop++) {
                                var nested_id = data.nested_id;
                                var formula_description = data.description_1;
                                var nested_formula_id = data.formula_id;
                                var row_seq = data.row;
                                if (!nested_formula_id) {
                                    var message = get_message('VALIDATE_FORMULA');
                                    show_messagebox(message);
                                    return false;
                                }
                                if (!formula_description) {
                                    var message = get_message('VALIDATE_DESC');
                                    show_messagebox(message);
                                    return false;
                                }
                                if (nested_id)
                                    formula_xml += '<FormulaUpdate nested_id=' + '"' + nested_id + '" ' + 'formula_description="' + formula_description + '" nested_formula_id="' + nested_formula_id + '" row_seq="' + row_seq + '"></FormulaUpdate>';
                                else
                                    formula_xml += '<FormulaInsert nested_id=' + '"' + nested_id + '" ' + 'formula_description="' + formula_description + '" nested_formula_id="' + nested_formula_id + '" row_seq="' + row_seq + '"></FormulaInsert>';

                                id = contract_group["dataview_formula_" + object_id].next(id);
                                data = contract_group["dataview_formula_" + object_id].get(id);
                            }
                        }
                        var deleted_xml = contract_group["contract_component_grid_" + object_id].getUserData("", "formula_delete_xml");
                        formula_xml += deleted_xml + '</Root>';
                        data = {
                            "action": "spa_contract_group_detail_UI",
                            "flag": "w",
                            "xml": formula_xml
                        };
                        adiha_post_data('alert', data, '', '', 'contract_group.callback_formula_save');
                        break;
                    case 'delete':
                        //when delete is clicked.
                        var selectedId = contract_group["dataview_formula_" + object_id].getSelected();
                        if (!selectedId) {
                            var message = 'Please select a formula.';
                            show_messagebox(message);
                            return false;
                        }

                        confirm_messagebox("Are you sure you want to delete?", function() {
                            var active_tab_id = contract_group.tabbar.getActiveTab();
                            var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
                            var dataview_object = contract_group["dataview_formula_" + object_id];
                            var count = dataview_object.dataCount();
                            var data = dataview_object.get(selectedId);
                            var a = selectedId.indexOf("dataview_");
                            if (a < 0) {
                                var nested_id = data.nested_id;
                                var fomula_xml = '';
                                var deleted_xml = contract_group["contract_component_grid_" + object_id].getUserData("", "formula_delete_xml");
                                fomula_xml = fomula_xml + '<FormulaDelete nested_id=' + '"' + nested_id + '"' + '></FormulaDelete>';
                                fomula_xml = fomula_xml + deleted_xml;
                                contract_group["contract_component_grid_" + object_id].setUserData("", "formula_delete_xml", fomula_xml);
                            }
                            contract_group["dataview_formula_" + object_id].remove(selectedId);
                            for (var i = 0; i < count; i++) {
                                id = dataview_object.idByIndex(i);
                                dataview_object.item(id).row = i + 1;
                                dataview_object.refresh(id);
                            }
                        });

                        contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("delete"); 
                        break;
                    case 'additional':
                        //when additional is clicked.
                        var dataview_object = contract_group["dataview_formula_" + object_id];
                        var id = dataview_object.getSelected();
                        var nested_id = dataview_object.item(id).nested_id
                        param = 'formula.additional.php?id=' + nested_id + '&is_pop=true&checked_status='+checked_status;
                        var is_win = dhxWins.isWindow('contract_group.w4');
                        if (is_win == true) {
                            contract_group.w4.close();
                        }

                        contract_group.w4 = dhxWins.createWindow("w2", 220, 10, 536, 250);
                        contract_group.w4.setText("Formula Additional");
                        contract_group.w4.setModal(true);
                        contract_group.w4.attachURL(param, false, true);
                        break;
                }
            } else if (contract_type == 'Excel') {
                var grid_obj = contract_group["dataview_formula_excel_engine" + object_id];
                var col_data_component_id = grid_obj.getColIndexById('data_component_id');
                var col_value = grid_obj.getColIndexById('value');
                var col_user_defined_function = grid_obj.getColIndexById('user_defined_function');
                var col_data_component_detail_id = grid_obj.getColIndexById('data_component_detail_id');
                switch (id) {
                    case 'add':
                        contract_group["contract_toolbar_formula_" + object_id].setItemEnabled("save");
                        var newId = (new Date()).valueOf();
                        grid_obj.addRow(newId,'');
                        grid_obj.selectRowById(newId);
                        // var shift_item_row_cmb = Setup_What_If_criteria["scenario_grid_" + active_object_id].cells(rId,Setup_What_If_criteria["scenario_grid_" + active_object_id].getColIndexById('shift_item')).getCellCombo();
                        break;
                    case 'save':
                        var contract_group_detail_id = contract_group["contract_component_grid_" + object_id].getSelectedRowId();
                        var changed_rows = grid_obj.getChangedRows(true);
                        var changed_ids = new Array();
                        changed_ids = changed_rows.split(",");
                        grid_obj.clearSelection();
                        if (!changed_ids || changed_ids == '') {
                            show_messagebox('No changes in Grid.');
                            return;
                        }
                        var validation_status = contract_group.validate_excel_grid(grid_obj,'Data Component');
                        if (!validation_status)
                            return;
                        var grid_xml = '<GridXML>';
                        $.each(changed_ids, function(index, value) {
                            grid_xml += '<GridRow ';
                            grid_xml += 'contract_group_detail_id' + '="' + contract_group_detail_id + '" ';
                            for(var cellIndex = 0; cellIndex < grid_obj.getColumnsNum(); cellIndex++){
                                var column_id = grid_obj.getColumnId(cellIndex);
                                var cell_value = grid_obj.cells(value, cellIndex).getValue();
                                if (column_id == 'data_component_id') {
                                    var data_component_id_array = cell_value.split('_');
                                    cell_value = data_component_id_array[0];
                                } else if (column_id == 'user_defined_function') {
                                    continue;
                                }
                                grid_xml += column_id + '="' + cell_value + '" ';
                            }
                            grid_xml += '></GridRow>';
                        });
                        grid_xml += '</GridXML>';
                        // console.log(grid_xml);
                        data = {'action' : 'spa_data_component',
                            'flag' : 's',
                            'xml' : grid_xml
                        };

                        adiha_post_data("return_array", data, '', '', 'contract_group.dataview_formula_grid_callback');

                        break;
                    case 'delete':
                        var selected_id = grid_obj.getSelectedRowId();
                        var data_component_detail_ids = [];
                        selected_id = selected_id.split(',');
                        selected_id.forEach(function(val) {
                            var data_component_detail_id = grid_obj.cells(val, col_data_component_detail_id).getValue();
                            data_component_detail_ids.push(data_component_detail_id);
                        });

                        if (data_component_detail_ids.length > 0) {
                            confirm_messagebox('Are you sure you want to delete?', function() {
                                data_component_detail_ids = data_component_detail_ids.toString();
                                data = {
                                    'action' : 'spa_data_component',
                                    'flag' : 'd',
                                    'data_component_detail_id' : data_component_detail_ids
                                };
                                adiha_post_data("return_array", data, '', '', 'contract_group.dataview_formula_grid_callback');
                            });
                        } else {
                            grid_obj.deleteRow(selected_id);
                            contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("delete");
                        }
                        break;
                    case 'additional':

                        break;
                }
            }
        }
        /*
         * Callback function for formula save. 
         * @param {type} result
         * @returns {undefined}         
         */
        contract_group.callback_formula_save = function(result) {
            if (result[0].errorcode == 'Success') {
                var active_tab_id = contract_group.tabbar.getActiveTab();
                var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
                contract_group["dataview_formula_" + object_id].clearAll();
                contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("delete");
                var selectedId = contract_group["contract_component_grid_" + object_id].getSelectedRowId();
                var ind = contract_group["contract_component_grid_" + object_id].getSelectedCellIndex();
                data = {
                    "action": "spa_contract_group_detail",
                    "flag": "a",
                    "contract_detail_id": selectedId
                };
                contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("additional");
                //contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("t1");
                contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("save");                
                adiha_post_data('return_array', data, '', '', ' contract_group.build_formula_dataview', false);
            }

        }
        /*************************************************END OF FORMULA TOOLBAR**********************************************************/
        /*END*/
        /*Triggers when save button for tabs is clicked*/
        /*START*/
        contract_group.save_contract = function(tab_id) {
            contract_group.layout.cells('a').expand();
            var active_tab_id = contract_group.tabbar.getActiveTab();
            var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;

            if (contract_group["contract_component_grid_" + object_id].getUserData("", "contract_mode_xml"))
                contract_id = contract_group["contract_component_grid_" + object_id].getUserData("", "contract_mode_xml");
            else
                contract_id = 'NULL';
            
            contract_group["form_validate_status" + object_id] = 0;

            var detail_tabs = contract_group["contract_tabs_" + object_id].getAllTabs();
            var tabsCount = contract_group["contract_tabs_" + object_id].getNumberOfTabs();
            var form_status = true;
            var first_err_tab;
            if (!contract_group.form_validation_status) {
                var form_xml = '<FormXML ';
                var grid_xml = "<GridGroup>";
                var valid_status = 1;
                var fees_dublicate_check = 0;
                var price_dublicate_check = 0;
                
                $.each(detail_tabs, function(index, value) {
                    layout_obj = contract_group["contract_tabs_layout_" + object_id + "_" + value].cells("a").getAttachedObject();
                    attached_obj = layout_obj;
                    
                    if (layout_obj instanceof dhtmlXForm) {
                        var status = validate_form(attached_obj);
                        form_status = form_status && status; 
                        if (tabsCount == 1 && !status) {
                        first_err_tab = "";
                        } else if ((!first_err_tab) && !status) {
                            first_err_tab = contract_group["contract_tabs_" + object_id].cells(value);
                        }
                        if (!status) {
                            valid_status = 0;
                        }                            
                            
                        data = layout_obj.getFormData();
                        for (var a in data) {
                            field_label = a;
                            if(field_label == 'storage_asset_id'){
                                contract_group["contract_component_grid_" + object_id].setUserData("", "storage_asset_id", data[a]);
                            }
                            if (field_label == 'contract_name') {
                                contract_group["contract_component_grid_" + object_id].setUserData("", "contract_name_store", data[a]);
                                get_contract_name = data[a];
                            }
                            if (field_label == 'term_start') {
                                term_start_validate = layout_obj.getItemValue(a, true);                                         
                            }
                            
                            if (field_label == 'term_end') {
                                term_end_validate = layout_obj.getItemValue(a, true);
                            }
                            
                            if (field_label == 'update_ts') {
                                field_value = currentdate;
                            }
                            //field_value = data[a];
                            if (layout_obj.getItemType(a) == "calendar") {
                                field_value = layout_obj.getItemValue(a, true);
                            }
                            else {
                                field_value = data[a];
                            }
                            if (field_label == 'contract_desc') {
                                if (data[a] == '')
                                    field_value = contract_group["contract_component_grid_" + object_id].getUserData("", "contract_name_store");
                            }
                            if (field_label == 'source_contract_id') {
                                if (data[a] == '')
                                    field_value = contract_group["contract_component_grid_" + object_id].getUserData("", "contract_name_store");
                            }
                            if (field_label == 'source_system_id') {                                
                                if (data[a] == '' || data[a] == 'null')
                                    field_value = '';
                            }                                                        
                            if (!field_value)
                                field_value = 'null';
                            form_xml += " " + field_label + "=\"" + field_value + "\"";
                        }
                    }
                    
                    if (term_start_validate > term_end_validate) {
                        var message = get_message('VALIDATE_DATE');
                        show_messagebox(message);
                        progressoff();
                        return;
                    }
                        
                    if (layout_obj instanceof dhtmlXGridObject) {
                        attached_obj.clearSelection();
                        grid_label = attached_obj.getUserData("", "grid_label");                              
                                                                        
                        var ids = attached_obj.getChangedRows(true);
                        grid_id = attached_obj.getUserData("", "grid_id");
                         
                        deleted_xml = attached_obj.getUserData("", "pricegrid_delete_xml");
                         
                        if (deleted_xml != null && deleted_xml != "") {
                            grid_xml += "<GridDelete grid_id=\"" + grid_id + "\" grid_label=\"" + grid_label + "\">";
                            grid_xml += deleted_xml;
                            grid_xml += "</GridDelete>";
                            if (delete_grid_name == "") {
                                delete_grid_name = grid_label
                            } else {
                                delete_grid_name += "," + grid_label
                            }
                        };
                        
                        if (ids != "") {
                            attached_obj.setSerializationLevel(false, false, true, true, true, true);
                            var grid_status = contract_group.validate_form_grid(attached_obj, grid_label);
                            if (!grid_status) {
                                contract_group["contract_tabs_" + object_id].cells(value).setActive();
                                valid_status = 0;
                            };
                            
                            if (grid_label == 'Contract Fees') {
                                var fee_product_charge_arr = new Array();
                                
                                attached_obj.forEachRow(function(id) {
                                    var fees_product_charge =  attached_obj.cells(id, 2).getValue() + '+' + attached_obj.cells(id, 3).getValue() + '+' + attached_obj.cells(id, 4).getValue(4);
                                    if (fee_product_charge_arr.indexOf(fees_product_charge) > -1) {
                                        valid_status = 0;
                                        fees_dublicate_check = 1;
                                    }
                                    
                                    fee_product_charge_arr.push(fees_product_charge);
                                });
                            }
                            
                            if (grid_label == 'Price') {
                                var price_val_arr = new Array();

                                attached_obj.forEachRow(function(id) {
                                    var price_val =  attached_obj.cells(id, 2).getValue() + '+' + attached_obj.cells(id, 7).getValue();
                                    
                                    if (price_val_arr.indexOf(price_val) > -1) {
                                        valid_status = 0;
                                        price_dublicate_check = 1;
                                    }
                                    
                                    price_val_arr.push(price_val);
                                });
                            }

                            grid_xml += "<Grid grid_id=\"" + grid_id + "\">";
                            var changed_ids = new Array();
                            changed_ids = (ids.indexOf(",") != -1) ? ids.split(",") : ids.split();
                            $.each(changed_ids, function(index, value) {
                                grid_xml += '<GridRow ';
                                for (var cellIndex = 0; cellIndex < layout_obj.getColumnsNum(); cellIndex++) {
                                    if (layout_obj.getColumnId(cellIndex) == 'source_system_id')
                                        grid_value = '2';
                                    else if (layout_obj.getColumnId(cellIndex) == 'source_curve_type_value_id')
                                        grid_value = '583';
                                    else if (layout_obj.getColumnId(cellIndex) == 'curve_id' || layout_obj.getColumnId(cellIndex) == 'market_value_id')
                                        grid_value = layout_obj.cells(value, 0).getValue();
                                    else if (layout_obj.getColumnId(cellIndex) == 'contract_id')
                                        grid_value = contract_id;
                                    else
                                        grid_value = layout_obj.cells(value, cellIndex).getValue();
                                    //var isHidden = layout_obj.isColumnHidden(cellIndex);
                                    if ((layout_obj.getColumnId(cellIndex) == 'curve_name') || (layout_obj.getColumnId(cellIndex) == 'source_currency_id') || (layout_obj.getColumnId(cellIndex) == 'uom_id') || (layout_obj.getColumnId(cellIndex) == 'granularity') || (layout_obj.getColumnId(cellIndex) == 'commodity_id')) {
                                        if (!grid_value) {
                                            var message = get_message('VALIDATE_GRID');
                                            show_messagebox(message);
                                            return false;
                                        }
                                    }
                                    grid_xml += " " + attached_obj.getColumnId(cellIndex) + '="' + attached_obj.cells(value, cellIndex).getValue() + '"';
                                }
                                grid_xml += " ></GridRow> ";
                            });
                            grid_xml += "</Grid>";
                        } else {
                            //valid_status = 0;
                        }                        
                    }
                });
                
                form_xml += "></FormXML>";
                grid_xml += "</GridGroup>";
                var xml = "<Root function_id=\"" + function_id + "\">";
                xml += form_xml;
                xml += grid_xml;
                xml += "</Root>";
                xml = xml.replace(/'/g, "\"");
                
                if (fees_dublicate_check == 1) {
                    show_messagebox('The combination of product type, charge and effective date should be unique in Fees.');
                    return;
                }
                
                if (price_dublicate_check == 1) {
                    show_messagebox('The combination of product type and effective date should be unique in Price.');
                    return;
                }
                
                if (valid_status) {
                    contract_group.tabbar.tabs(tab_id).getAttachedToolbar().disableItem('save');
                    var contract_id = contract_group["contract_component_grid_" + object_id].getUserData("", "contract_mode_xml");
                    data = {"action": "spa_process_form_data", "xml":xml}
                    if (delete_grid_name != "") {
                        var del_msg =  "Some data has been deleted from " + delete_grid_name + " grid. Are you sure you want to save?";
                        result = adiha_post_data("alert", data, "", "", "contract_group.post_callback", "", del_msg);
                    } else {
                        result = adiha_post_data("alert", data, "", "", "contract_group.post_callback");
                    }
                    delete_grid_name = "";
                    deleted_xml = attached_obj.setUserData("", "pricegrid_delete_xml", "");
                } 

                if (!form_status) {
                    generate_error_message(first_err_tab);
                }
            }
        }

        contract_group.after_refresh_price_grid = function(result){
            var json_data = JSON.parse(result);

            data = {
                "action": "spa_counterparty_contract_address",
                "flag":'y',
                "counterparty_id": json_data[0].counterparty_id,
                "contract_id" : json_data[0].contract_id
            };
            adiha_post_data('return_json', data, '', '', 'contract_group.save_counterparty_contract_callback', false);
        }

        contract_group.save_counterparty_contract_callback = function() {}

        /*END*/
        contract_group.post_callback = function(result) {
            if (has_rights_contract_copy) {
                contract_group.tabbar.tabs(contract_group.tabbar.getActiveTab()).getAttachedToolbar().enableItem('save');
            }
            
            if (result[0].errorcode == 'Success') {
                var contract_id = result[0].recommendation;
				var contract_workflow = contract_id;
                
                if (function_id == '20008200') {
                    var active_tab_id = contract_group.tabbar.getActiveTab();
                    var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
                    var storage_asset_id = contract_group["contract_component_grid_" + object_id].getUserData("", "storage_asset_id");
                    
                    data = {
                        "action": "spa_storage_assets",
                        "flag":'n',
                        "storage_asset_id":storage_asset_id,
                        "agreement" : result[0].recommendation
                    };
                    adiha_post_data('return_json', data, '', '', 'contract_group.after_refresh_price_grid', false);                    
                } else {
                    //Added this block as the alert is triggered from spa_contract_group_detail when contract_id is not for Standard Contract
                    if ((function_id == '10211200' && contract_id == null) || function_id != '10211200') {
                        if (contract_workflow == null) {
                            var active_tab_id = contract_group.tabbar.getActiveTab();
                            contract_workflow = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
                        }
                        //Trigger Workflow
                        var data = {"action": "spa_contract_group_detail_UI", "flag": "a","contract_id":contract_workflow, "module_id":"20603", "event_id":"20568"};
                        adiha_post_data("return_json", data, "", "", "");
                    }
                }

                if (contract_id != null) {
                    var tab_id = contract_group.tabbar.getActiveTab();
                    var tab_text = new Array();
                    if (contract_id.indexOf(",") != -1) {
                        tab_text = contract_id.split(",");
                    } else {
                        tab_text.push(0, contract_id);
                    }
                    contract_group.tabbar.tabs(tab_id).setText(tab_text[1]);
                    
                    if (function_id == '10211200') {
                        data = {
                            "action": "spa_contract_group_detail",
                            "flag": "i",
                            "contract_id": contract_id,
                            "prod_type": "p",
                            "invoice_line_item_id": "-10019",
                            "hideInInvoice": "s",
                            "calc_aggregation": 19002,
                            "include_charges": "y",
                            "automatic_manual": "c"
                        };
                        result = adiha_post_data("alert", data, "", "", "");
                    }
                    if (call_from_combo == 'combo_add') {
                        parent.parent.combo_data_add_win.callEvent("onWindowSaveCloseEvent", ["onSave", tab_text[1]]);
                        return;
                    }
                    contract_group.refresh_grid("", contract_group.open_tab);
                } else {
                    contract_group.refresh_grid("", contract_group.refresh_tab_properties);
                }
            }
        }

        /*
         * Copy contract
         * @param {type} tab_id
         * @returns {undefined}
         */
        contract_group.copy_contract = function(object_id) {
            var object_id = (object_id.indexOf("tab_") != -1) ? object_id.replace("tab_", "") : object_id;
            data = {"action": "spa_contract_group", "flag": "c", "contract_id": object_id};
            result = adiha_post_data("confirm", data, "", "", "contract_group.callback_copy_contract", "", "Are you sure you want to copy?");
        }

        contract_group.lock_contract = function(object_id) {
            var object_id = (object_id.indexOf("tab_") != -1) ? object_id.replace("tab_", "") : object_id;
            data = {"action": "spa_contract_group", "flag": "g", "contract_id": object_id};
            result = adiha_post_data("confirm", data, "", "", "contract_group.callback_lock_contract", "", "Are you sure you want to lock?");
        }

        contract_group.unlock_contract = function(object_id) {
            var object_id = (object_id.indexOf("tab_") != -1) ? object_id.replace("tab_", "") : object_id;
            //alert(object_id);
            data = {"action": "spa_contract_group", "flag": "h", "contract_id": object_id};
            result = adiha_post_data("confirm", data, "", "", "contract_group.callback_lock_contract", "", "Are you sure you want to unlock?");
        }

        /*
         * Open document
         * @param {type} tab_id
         * @returns {undefined}         */
        contract_group.open_document = function(object_id,call_from) {
            var object_id = (object_id.indexOf("tab_") != -1) ? object_id.replace("tab_", "") : object_id;
            param = '../../_setup/manage_documents/manage.documents.php?call_from=' + call_from + '&notes_category=' + category_id + '&notes_object_id=' + object_id + '&is_pop=true';
            var is_win = dhxWins.isWindow('w11');
            if (is_win == true) {
                w11.close();
            }
            w11 = dhxWins.createWindow("w11", 520, 100, 530, 550);
            w11.setText("Document");
            w11.setModal(true);
            w11.maximize();
            w11.attachURL(param, false, true);

            w11.attachEvent("onClose", function(win) {
                update_document_counter(object_id, toolbar_object);
                return true;
            });
        }
        /*
         * Calback function to copy contract function to reload the tree. 
         * @param {type} result
         * @returns {undefined}         
         */
        contract_group.callback_copy_contract = function(result) {
            var contract_id = result[0].recommendation;
            //Trigger Workflow
            data = {"action": "spa_contract_group_detail_UI", "flag": "a","contract_id":contract_id, "module_id":"20603", "event_id":"20568"};
            adiha_post_data("alert", data, "", "", "");

            var spa_url = "<?php echo $tree_grid_spa; ?>";
            grid_obj_name = ' contract_group.grid';
            contract_group.grid.clearAll();
            contract_group.refresh_grid();
            disable_menu_item();
        }

        contract_group.callback_lock_contract = function(result) {
            if (result[0].errorcode == 'Success') {
                contract_group.refresh_grid("", function() {
                    disable_menu_item();
                    var contract_id = result[0].recommendation;
                    var selected_tab_id = 'tab_' + contract_id;
                    var active_tab_id = contract_group.tabbar.getActiveTab();

                    if (active_tab_id !== null) { //If there exists some open tab.
                        contract_group.tabbar.forEachTab(function(tab) { //Get each open tab id and check wheather selected grid id is already open in left pannel?
                            var tab_id = tab.getId();
                            if (tab_id == selected_tab_id) {
                                contract_group.tabbar.tabs(tab_id).setActive();
                                contract_group.tabbar.tabs(tab_id).setText(contract_id);
                                contract_group.open_tab();
                            }
                        });
                    }
                });
            } else {
                show_messagebox('Error occur. Please try again.');
            }
        }
        /*Triggers when window is to be undocked.*/
        /*START*/
        contract_group.undock_window = function() {
            var active_tab_id = contract_group.tabbar.getActiveTab();
            var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            w1 = contract_group["inner_tab_layout_" + object_id].cells('b').undock(300, 300, 900, 700);
            contract_group["inner_tab_layout_" + object_id].dhxWins.window('b').button('park').hide();
            contract_group["inner_tab_layout_" + object_id].dhxWins.window('b').maximize();
            contract_group["inner_tab_layout_" + object_id].dhxWins.window('b').centerOnScreen();

        }
        /*END*/ 
        contract_group.charge_type_post_callback = function(result) {
            var active_tab_id = contract_group.tabbar.getActiveTab();
            var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            grid_obj_name = 'contract_group[' + '"' + 'contract_component_grid_' + object_id + '"' + ']';
            grid_delete_xml = contract_group["contract_component_grid_" + object_id].getUserData("", "grid_delete_xml");
            grid_update_xml = contract_group["contract_component_grid_" + object_id].getUserData("", "grid_update_xml");
            formula_delete_xml = contract_group["contract_component_grid_" + object_id].getUserData("", "formula_delete_xml");
            form_validate_code_xml = contract_group["contract_component_grid_" + object_id].getUserData("", "form_validate_code_xml");
            pricegrid_delete_xml = contract_group["contract_component_grid_" + object_id].getUserData("", "pricegrid_delete_xml");
            contract_mode_xml = contract_group["contract_component_grid_" + object_id].getUserData("", "contract_mode_xml");
            contract_name_store = contract_group["contract_component_grid_" + object_id].getUserData("", "contract_name_store");
            contract_group["contract_component_grid_" + object_id].clearAll();
            contract_group["contract_toolbar_grid_" + object_id].setItemDisabled('copy');
            contract_group["contract_toolbar_grid_" + object_id].setItemDisabled('delete');
            contract_group["contract_toolbar_grid_" + object_id].setItemDisabled('gl_code');
            
            var str = "<?php echo $sql_string; ?>";
            var spa_url = str.replace("<ID>", object_id);
            var additional_data1 = {
                "sp_url": spa_url,
                "grid_obj_name": grid_obj_name
            };
            url = php_script_loc_ajax + "load_grid_data.php"
            data = $.param(additional_data1);
            $.ajax({
                type: "POST",
                dataType: "json",
                url: url,
                data: data,
                success: function(data) {
                    eval((data));
                    contract_group["contract_component_grid_" + object_id].setUserData("", "grid_delete_xml", grid_delete_xml);
                    contract_group["contract_component_grid_" + object_id].setUserData("", "grid_update_xml", grid_update_xml);
                    contract_group["contract_component_grid_" + object_id].setUserData("", "formula_delete_xml", formula_delete_xml);
                    contract_group["contract_component_grid_" + object_id].setUserData("", "form_validate_code_xml", form_validate_code_xml);
                    contract_group["contract_component_grid_" + object_id].setUserData("", "pricegrid_delete_xml", pricegrid_delete_xml);
                    contract_group["contract_component_grid_" + object_id].setUserData("", "contract_mode_xml", contract_mode_xml);
                    contract_group["contract_component_grid_" + object_id].setUserData("", "contract_name_store", contract_name_store);
                    contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("additional");
                    contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("t1");
                    contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("save");
                },
                error: function(xht) {
                    show_messagebox('error');
                }

            });
            var layout_obj = contract_group["inner_grid_layout_" + object_id].cells('b').getAttachedObject();
            if (layout_obj instanceof dhtmlXDataView) {
                contract_group["dataview_formula_" + object_id].clearAll();
            } else if (layout_obj instanceof dhtmlXGridObject) {
                contract_group["inner_grid_layout_" + object_id].cells('b').detachObject();
            }
        }

        contract_group.delete_charge_type = function(result) {
            var grid_delete_xml = contract_group["contract_component_grid_" + object_id].getUserData("", "grid_delete_xml");
            return;
            var grid_xml = '<Root>';
            var i = 1;
            var save_validation_status = 1;
            contract_group["contract_component_grid_" + object_id].forEachRow(function(id) {
                var contract_detail_id = contract_group["contract_component_grid_" + object_id].cells(id, 0).getValue();
                var contract_component = contract_group["contract_component_grid_" + object_id].cells(id, 1).getValue();
                if (!contract_component) {
                    var message = get_message('SELECT_DATA');
                    show_messagebox(message);
                    save_validation_status = 0;
                    return;
                }
                var a = contract_component_store.indexOf(contract_component);
                if (a >= 0) {
                    var message = get_message('DUPLICATE_DATA');
                    show_messagebox(message);
                    save_validation_status = 0;
                    return;
                }
                contract_component_store.push(contract_component);
                if (contract_detail_id) {
                    grid_xml = grid_xml + '<GridUpdate contract_id=' + '"' + object_id + '"' + ' contract_detail_id=' + '"' + contract_detail_id + '"' + ' contract_component=' + '"' + contract_component + '"' + ' sequence_order=' + '"' + i + '"' + '></GridUpdate>';
                }
                else {
                    grid_xml = grid_xml + '<GridInsert contract_id=' + '"' + object_id + '"' + ' contract_detail_id=' + '"NULL"' + ' contract_component=' + '"' + contract_component + '"' + ' sequence_order=' + '"' + i + '"' + '></GridInsert>';
                }
                i++;
            });
            if (save_validation_status) {
                var grid_delete_xml = contract_group["contract_component_grid_" + object_id].getUserData("", "grid_delete_xml");
                grid_xml = grid_xml + grid_delete_xml + '</Root>';
                contract_group["contract_component_grid_" + object_id].setUserData("", "grid_update_xml", grid_xml);
                var xml = contract_group["contract_component_grid_" + object_id].getUserData("", "grid_update_xml");
                data = {
                    "action": "spa_contract_group_detail_UI",
                    "flag": "v",
                    "xml": xml
                };
                adiha_post_data('alert', data, '', '', '');
                var str = "<?php echo $sql_string; ?>";
                var spa_url = str.replace("<ID>", object_id);
                sp_url = {"sp_string": spa_url};
                result = adiha_post_data("return_data", sp_url, "", "", "contract_group.refresh_contract_component_grid_callback");
            }
        }

        contract_group.delete_tree = function() {
            var contract_id_index = contract_group.grid.getColIndexById('contract_id');
            var selectedId = contract_group.grid.getSelectedRowId();
            if (selectedId == 'NULL') {
                var message = get_message('VALIDATE_DATA');
                show_messagebox(message);
                return false;
            }

            // Handle multiple deletion
            var id = "";
            if (selectedId.indexOf(",") != -1) {
                var sel_id_arr = selectedId.split(",");
                for (var i = 0; i < sel_id_arr.length; i++) {
                    id += "," + contract_group.grid.cells(sel_id_arr[i], contract_id_index).getValue();
                }
            } else {
                id += contract_group.grid.cells(selectedId, contract_id_index).getValue();
            }
            id = id.replace(/^,/, '');
            
            var success_message = get_message('DELETE_SUCCESS');
            var error_message = get_message('DELETE_FAILED');

            data = {
                "action": "spa_contract_group",
                "flag": "d",
                "contract_id": id
            };

            adiha_post_data('confirm', data, '', '', 'contract_group.success_delete_contract');
        }

        contract_group.success_delete_contract = function(result) {
            if (result[0].errorcode == 'Success') {
                var selectedId = contract_group.grid.getSelectedRowId();
                var sel_id_array = [];
                if (selectedId.indexOf(",") != -1) {
                    var sel_id_arr = selectedId.split(",");
                    for (var i = 0; i < sel_id_arr.length; i++) {
                        sel_id_array.push(contract_group.grid.cells(sel_id_arr[i], 0).getValue());
                        contract_group.grid.deleteRow(sel_id_arr[i]);
                    }
                } else {
                    sel_id_array.push(contract_group.grid.cells(selectedId, 0).getValue());
                }
                
                //clsoe the tab if the contract is deleted from the grid.
                var ids = contract_group.tabbar.getAllTabs();
                if (ids) {
                    contract_group.tabbar.forEachTab(function(tab) {
                        var id = tab.getId();
                        var object_id = (id.indexOf("tab_") != -1) ? id.replace("tab_", "") : id;
                        if (sel_id_array.indexOf(object_id) > -1)
                            contract_group.tabbar.tabs(id).hide();
                    });
                }
                contract_group.refresh_grid();
                disable_menu_item();
            }
        }

        /**
         * get_message() [get the message for the message box.]
         * @param [string] message_code [the code to obtain the required message according to the code.]
         * @return [string] html_str [return the message.]
         */
        function get_message(message_code) {
            switch (message_code) {
                case 'VALIDATE_DATA':
                    return 'Please select data first.';
                case 'DELETE_CONFIRM':
                    return 'Are you sure you want to delete?';
                case 'DELETE_SUCCESS':
                    return 'Data deleted successfully.';
                case 'DELETE_FAILED':
                    return 'Failed to delete data.';
                case 'INSERT_SUCCESS':
                    return 'Data Inserted Successfully';
                case 'UPDATE_SUCCESS':
                    return 'Data Updated Successfully';
                case 'INSERT_FAILED':
                    return 'Failed to Insert Data';
                case 'UPDATE_FAILED':
                    return 'Failed to Update Data';
                case 'SAVE_SUCCESS':
                    return 'Successfully Saved Contract Detail values.';
                case 'SAVE_FAIL':
                    return 'Failed to save Contract Detail values.';
                case 'DUPLICATE_DATA':
                    return 'Cannot save wtih duplicate contract components.';
                case 'SELECT_DATA':
                    return 'One of the contract component is not selected.';
                case 'VALIDATE_FORMULA':
                    return 'Formula is not inserted.';
                case 'VALIDATE_DESC':
                    return 'Description is empty.';
                case 'VALIDATE_GRID':
                    return 'Please insert some missing values in grid.';
                case 'VALIDATE_DATE':
                    return '<b>End Date</b> should be greater than <b>Start Date.</b>'
            }
        }
                        
        function disable_item(status) { // Only for standard and non standard contract.
            var tab_id = contract_group.tabbar.getActiveTab();  
            var win = contract_group.tabbar.cells(tab_id).getAttachedToolbar();
            var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;

            if (status == '1') {
                win.disableItem("save");
                contract_group["contract_toolbar_grid_" + object_id].setItemDisabled('add');
                contract_group["contract_toolbar_grid_" + object_id].setItemDisabled('delete');
                contract_group["contract_toolbar_grid_" + object_id].setItemDisabled('copy');
                contract_group["contract_toolbar_grid_" + object_id].setItemDisabled('gl_code');
                contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("t1");
                contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("additional");
                contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("save");
            } else {
                if (has_rights_contract_copy && ( typeof privilege_status == 'undefined' || privilege_status == 'true')) // Only for standard and non standard.
                    win.enableItem("save");
                
                contract_group["contract_toolbar_grid_" + object_id].setItemEnabled('add');
                contract_group["contract_toolbar_grid_" + object_id].setItemEnabled('delete');
                contract_group["contract_toolbar_grid_" + object_id].setItemEnabled('gl_code');
            }
        }

        function disable_menu_item () {
            if (contract_group.menu.getItemType('unlock') != null)
                contract_group.menu.setItemDisabled('unlock');
            if (contract_group.menu.getItemType('lock') != null)
                contract_group.menu.setItemDisabled('lock');
            if (contract_group.menu.getItemType('delete') != null)
                contract_group.menu.setItemDisabled('delete');
            if (contract_group.menu.getItemType('copy') != null)
                contract_group.menu.setItemDisabled('copy');
            if (contract_group.menu.getItemType('workflow_status') != null)
                contract_group.menu.setItemDisabled('workflow_status');
        }

        open_product_charges_browse = function(grid_obj) {
            var browse_window = new dhtmlXWindows();
            win = browse_window.createWindow('w1', 0, 0, 450, 450);
            win.setText("Charges");
            win.centerOnScreen();
            win.setModal(true);
            
            var browse_layout = browse_window.window('w1').attachLayout({
                pattern: "2E",
                cells: [
                    {id: "a", text: "Product", height: 100, header: false},
                    {id: "b", text: "Charge Type", header:false}
                ]
            });
            
            var toolbar_json = [{id:"save", type:"button", img:"save.gif", imgdis:"save_dis.gif", text:"Ok", title:"Ok"}];
            var toolbar_obj = browse_layout.cells('a').attachToolbar();
            toolbar_obj.setIconsPath(js_image_path + '/dhxtoolbar_web/');
            toolbar_obj.loadStruct(toolbar_json);
            toolbar_obj.attachEvent("onClick", function(id){
                var selected_row = browse_grid.getSelectedRowId();
                if (selected_row == null) {
                    show_messagebox('Please select any charge.');
                    return;             
                }
                
                var selected_row_arr = selected_row.split(',');
                for (cnt = 0; cnt < selected_row_arr.length; cnt++) {
                    var product = form_obj.getItemValue('product_type');
                    var value_id = browse_grid.cells(selected_row_arr[cnt],0).getValue();
                    var newId = (new Date()).valueOf();
                    grid_obj.addRow(newId,['','',product,value_id,'','']);
                }
                win.close();
            }); 
            
            browse_grid =  browse_layout.cells('b').attachGrid();
            browse_grid.setImagePath(js_image_path + '/dhxtoolbar_web/');
            browse_grid.setHeader('ID,Charges'); 
            browse_grid.setColAlign('left,left'); 
            browse_grid.setColumnIds('id,id_item');
            browse_grid.setColTypes('ro,ro'); 
            browse_grid.setInitWidths('175,220'); 
            browse_grid.setColSorting('int,str'); 
            browse_grid.attachHeader('#text_filter,#text_filter'); 
            browse_grid.enableMultiselect(true); 
            browse_grid.init(); 
            browse_grid.setColumnsVisibility('false,false'); 
            
            var sql_param = {
                    "sql":"EXEC('SELECT field_name, Field_label FROM user_defined_fields_template WHERE internal_field_type = 18730')",
                    "grid_type":"g"
                };
            
            sql_param = $.param(sql_param);
            var sql_url = js_data_collector_url + "&" + sql_param;
            browse_grid.load(sql_url);
            
            
            var form_json = [{
                                type: 'block',
                                blockOffset: ui_settings['block_offset'],
                                list: [{
                                    'type': 'combo',
                                    'name': 'product_type',
                                    'label': 'Product',
                                    'position': 'label-top',
                                    'inputWidth': ui_settings['field_size'],
                                    'labelWidth': 'auto',
                                    'offsetLeft':ui_settings['offset_left'],
                                    'filtering': true,
                                    'tooltip': 'Product',
                                    'options': '',
                                }]
                            }];
            
            var form_obj = browse_layout.cells('a').attachForm();           
            form_obj.load(form_json, function() {
                 var cm_param = {
                            "action": "('SELECT value_id, code FROM static_data_value WHERE type_id = 101100')", 
                            "call_from": "form",
                            "has_blank_option": false
                        };

                cm_param = $.param(cm_param);
                var url = js_dropdown_connector_url + '&' + cm_param;
                var combo_obj = form_obj.getCombo('product_type');
                combo_obj.load(url, function() {
                    combo_obj.selectOption(0);
                });
            });
        }
        
        load_workflow_status = function() {
            contract_group.menu.addNewSibling('process', 'reports', 'Reports', false, 'report.gif', 'report_dis.gif');
            contract_group.menu.addNewChild('reports', '0', 'workflow_status', 'Workflow Status', true, 'report.gif', 'report_dis.gif');
            contract_group.menu.addNewChild('reports', '1', 'report_manager', 'Report Manager', true, 'report.gif', 'report_dis.gif');
            
            contract_group.grid.attachEvent("onRowSelect",function(rowId,cellIndex){
                contract_group.menu.setItemEnabled('workflow_status');
            });

            contract_group.grid.attachEvent("onSelectStateChanged",function(rowId,cellIndex){
				if (rowId != null) {		
					if (rowId.indexOf(",") == -1) contract_group.menu.setItemEnabled('report_manager');
				}
            });
            
            load_report_menu ('contract_group.menu', 'report_manager', 2, -104704)

            contract_group.menu.attachEvent("onClick", function(id, zoneId, cas){
                if(id == 'workflow_status') {
                    var r_id = contract_group.grid.getSelectedRowId();
                    if (!r_id) {
                        show_messagebox('Please select a contract.');
                        return;
                    }

                    var selected_ids;
                    if (function_id == "10211400" || function_id == "20008200") {
                        selected_ids = contract_group.grid.getColumnValues(1);
                    } else {
                        selected_ids = contract_group.grid.getColumnValues(0);
                    }

                    var workflow_report = new dhtmlXWindows();
                    workflow_report_win = workflow_report.createWindow('w1', 0, 0, 900, 700);
                    workflow_report_win.setText("Workflow Status");
                    workflow_report_win.centerOnScreen();
                    workflow_report_win.setModal(true);
                    workflow_report_win.maximize();

                    var filter_string;
                    if (function_id == "10211400" || function_id == "20008200"){
                    	filter_string = 'Contract ID = <i>' + contract_group.grid.getColumnValues(1) +  '</i>,  Contract = <i>' + contract_group.grid.getColumnValues(0) + '</i>';
                    } else {
                    	filter_string = 'Contract ID = <i>' + contract_group.grid.getColumnValues(0) +  '</i>,  Contract = <i>' + contract_group.grid.getColumnValues(1) + '</i>';
                    }

                    var process_table_xml = 'contract_id:' + selected_ids;
                    var page_url = js_php_path + '../adiha.html.forms/_compliance_management/setup_rule_workflow/workflow.report.php?filter_id=' + selected_ids + '&source_column=contract_id&module_id=20603&process_table_xml=' + process_table_xml + '&filter_string=' + filter_string;
                    workflow_report_win.attachURL(page_url, false, null);
                } else if (id.indexOf("report_manager_") != -1 && id != 'report_manager') {
					var str_len = id.length;
                    var report_param_id = id.substring(15, str_len);
                    var selected_ct_ids;
                    if (function_id == "10211400" || function_id == "20008200") {
                        selected_ct_ids = contract_group.grid.getColumnValues(1);
                    } else {
                        selected_ct_ids = contract_group.grid.getColumnValues(0);
                    }
                   
                    var param_filter_xml = '<Root><FormXML param_name="source_id" param_value="' + selected_ct_ids + '"></FormXML></Root>';
                    
                    show_view_report(report_param_id, param_filter_xml, -104704)
                }
            });
        }        
        
        contract_group.validate_excel_grid = function(attached_obj,grid_label) {
            var status = true;
            var col_data_component_id = attached_obj.getColIndexById('data_component_id');
            var col_value = attached_obj.getColIndexById('value');
            var col_user_defined_function = attached_obj.getColIndexById('user_defined_function');
            var col_formula_id = attached_obj.getColIndexById('formula_id');
            var col_granularity = attached_obj.getColIndexById('granularity');
            for (var i = 0;i < attached_obj.getRowsNum();i++){
                var row_id = attached_obj.getRowId(i);
                for (var j = 0;j < attached_obj.getColumnsNum();j++){
                    var validation_message = attached_obj.cells(row_id,j).getAttribute("validation");
                    //alert(validation_message)
                    var column_text = attached_obj.getColLabel(j);
                    var column_id_by_index = attached_obj.getColumnId(j);
                    if(validation_message != "" && validation_message != undefined){
                        error_message = "Data Error in <b>"+grid_label+"</b> grid. Please check the data in column <b>"+column_text+"</b> and re-run.";
                        show_messagebox(error_message);
                        status = false; break;
                    }
                    if (column_id_by_index == 'data_component_id' && (attached_obj.cells(row_id,j).getValue() == '' || attached_obj.cells(row_id,j).getValue() == undefined)) {
                        error_message = "Data Error in <b>"+grid_label+"</b> grid. Please check the data in column <b>"+column_text+"</b> and re-run.";
                        show_messagebox(error_message);
                        status = false; break;
                    } else if (column_id_by_index == 'data_component_id') {
                        var value_array = attached_obj.cells(row_id,j).getValue().split('_');
                        switch (value_array[1]) {
                            case '107300': // Meter
                            case '107302': // Price
                                var value = attached_obj.cells(row_id,col_value).getValue();
                                if (value == '' || value == undefined) {
                                    column_text = attached_obj.getColLabel(col_value);
                                    error_message = "Data Error in <b>"+grid_label+"</b> grid. Please check the data in column <b>"+column_text+"</b> and re-run.";
                                    show_messagebox(error_message);
                                    status = false; break;
                }
                                break;
                            case '107301': //Deal

                                break;
                            case '107303': // UDSQL
                                var value = attached_obj.cells(row_id,col_formula_id).getValue();
                                if (value == '' || value == undefined) {
                                    column_text = attached_obj.getColLabel(col_user_defined_function);
                                    error_message = "Data Error in <b>"+grid_label+"</b> grid. Please check the data in column <b>"+column_text+"</b> and re-run.";
                                    show_messagebox(error_message);
                                    status = false; break;
                                }
                                break;
                        }
                    }
                }
                if(validation_message != "" && validation_message != undefined){ break;}
            }
            return status;
        }

        contract_group.dataview_formula_grid_callback = function (result) {
            if (result[0][0] == 'Success') {
                contract_group.refresh_dataview_formula_grid();
                success_call(result[0][4]);
            } else {
                show_messagebox(result[0][4]);
            }
        }

        contract_group.refresh_dataview_formula_grid = function() {
            var active_tab_id = contract_group.tabbar.getActiveTab();
            var object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            var grid_obj = contract_group["dataview_formula_excel_engine" + object_id];
            var selectedId = contract_group["contract_component_grid_" + object_id].getSelectedRowId();
            contract_group["inner_grid_layout_" + object_id].cells('b').progressOn();
            var sql_param = {
                "action": "spa_data_component",
                "flag": "g",
                "contract_group_detail_id": selectedId,
                "grid_type":"g"
            };

            sql_param = $.param(sql_param);
            var sql_url = js_data_collector_url + "&" + sql_param;
            grid_obj.clearAndLoad(sql_url,function () {
                var col_data_component_id = grid_obj.getColIndexById('data_component_id');
                var col_value = grid_obj.getColIndexById('value');
                var cmb_data_component = grid_obj.getColumnCombo(col_data_component_id);
                grid_obj.forEachRow(function(row_id){
                   var data_component_id = grid_obj.cells(row_id,col_data_component_id).getValue();
                   var value = grid_obj.cells(row_id,col_value).getValue();
                    cmb_data_component.callEvent("onChange", [data_component_id, '',row_id,value]);
                });
                contract_group["inner_grid_layout_" + object_id].cells('b').progressOff();
                contract_group["contract_toolbar_formula_" + object_id].setItemEnabled("save");
                contract_group["contract_toolbar_formula_" + object_id].setItemDisabled("delete");
            });
        }
		
		contract_group.alert_reminders = function(object_id) {
			var object_id = (object_id.indexOf("tab_") != -1) ? object_id.replace("tab_", "") : object_id;
            param = '../../_compliance_management/setup_alerts/setup.alerts.reminder.php?module_id=20603&source_id=' + object_id;
            var is_win = dhxWins.isWindow('w11');
            if (is_win == true) {
                w11.close();
            }
            w11 = dhxWins.createWindow("w11", 520, 100, 530, 550);
            w11.setText("Alerts");
            w11.setModal(true);
            w11.maximize();
            w11.attachURL(param, false, true);
		}
    </script>
</html>
