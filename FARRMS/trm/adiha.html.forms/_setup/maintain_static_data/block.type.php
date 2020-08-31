<?php
/**
* Block type screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1"/>
    <?php require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
<body>
<?php
    $rights_static_data_iu = 10101010; // main Save
    $rights_block_type_delete = 10101011; // delete grid data
    $rights_block_type_grid_iu = 10101010; // insert update grid

    list (
        $has_rights_static_data_iu,
        $has_rights_block_type_iu,
        $has_rights_block_type_delete
        ) = build_security_rights(
        $rights_static_data_iu,
        $rights_block_type_grid_iu,
        $rights_block_type_delete
    );

    $layout = new AdihaLayout();
    $form_obj = new AdihaForm();

    $layout_name = 'block_type_layout';

    if (isset($_POST['value_id'])) {
        $value_id = get_sanitized_value($_POST['value_id']);
        $xml = '<Root><PSRecordset value_id="' . $value_id . '"></PSRecordset></Root>';
    } else {
        $value_id = "null";
        $xml = '<Root><PSRecordset value_id=""></PSRecordset></Root>';
    }

    $layout_json = '[
                        {
                            id:             "a",
                            text:           "Block Type",
                            width:          720,
                            height:         160,
                            header:         false,
                            collapse:       false,
                            fix_size:       [true,true]
                        },

                    ]';
    $name_space = 'block_type';
    echo $layout->init_layout($layout_name, '', '1C', $layout_json, $name_space);

    $toolbar_name = 'block_type_toolbar';
    echo $layout->attach_toolbar_cell($toolbar_name, 'a');

    $toolbar_obj = new AdihaToolbar();
    echo $toolbar_obj->init_by_attach($toolbar_name, $name_space);

    echo $toolbar_obj->load_toolbar('[{id: "save", type: "button", text:"Save", img: "save.gif", imgdis: "save_dis.gif", title:"Save", action: "block_type",  }]');
    //Save button Privilege
    if($value_id != 'null') {
        echo $toolbar_obj->save_privilege(get_sanitized_value($_POST['type_id']), $value_id);
    }
    //Start of Tabs
    $tab_name = 'block_type_tabs';

    $json_tab = '[
                    {
                        id:      "a1",
                        text:    "General",
                        width:   null,
                        index:   null,
                        active:  true,
                        enabled: true,
                        close:   false
                    },
                    {
                        id:      "a2",
                        text:    "Properties",
                        width:   null,
                        index:   null,
                        active:  false,
                        enabled: true,
                        close:   false
                    },
                ]';

    echo $layout->attach_tab_cell($tab_name, 'a', $json_tab);
    echo $name_space . "." . $tab_name . '.setTabsMode("bottom");';
    $tab_obj = new AdihaTab();

    echo $tab_obj->init_by_attach($tab_name, $name_space);

    $xml_file = "EXEC spa_create_application_ui_json 'j', 10101034, 'block_type', '$xml' ";
    $return_value1 = readXMLURL($xml_file);
    $form_structure_general = $return_value1[0][2];

    $form_name = 'block_type_form';
    echo $tab_obj->attach_form($form_name, 'a1', $form_structure_general, $name_space);

    //for grid
    $grid_name = 'block_type_grid';
    echo 'block_type.block_type_grid= block_type.block_type_tabs.tabs("a2").attachGrid();';
    $grid = new AdihaGrid();
    echo $grid->init_by_attach($grid_name, $name_space);
    //$sql = "EXEC spa_block_type_group @flag ='s', @block_type_group_id = " . $value_id;
    echo $grid->set_header('id,Block Name,Hourly Block,Block Type');
    echo $grid->set_widths('100,130,130,130');
    echo $grid->set_columns_ids('id,block_name,hourly_block_id,block_type_id');
    echo $grid->hide_column('0');
    echo $grid->hide_column('3');
    echo $grid->set_column_types('ro,ed,combo,combo');
    echo $grid->set_sorting_preference('int,str,str,str');
    echo $grid->set_search_filter('#text_filter,#text_filter,#text_filter,#text_filter');
    // echo $grid->enable_multi_select();
    echo $grid ->load_grid_functions();
    echo $grid->attach_event('','onRowSelect','on_grid_select');
    //echo $grid->load_grid_data($sql);
    echo $grid->return_init();
    echo $layout->close_layout();
?>
</body>

<script type="text/javascript">
    var has_rights_static_data_iu;
    var has_rights_block_type_iu;
    var has_rights_block_type_grid_delete;

    $(function() {

        var value_id = '<?php echo $value_id; ?>';
        var block_defination_combo = block_type.block_type_grid.getColumnCombo(2);
        var block_defination_combo_sql = {"action":"spa_StaticDataValues", "flag":"h", "type_id" :"10018", "has_blank_option" : "false"};
        load_combo(block_defination_combo, block_defination_combo_sql);

        var block_type_combo = block_type.block_type_grid.getColumnCombo(3);
        var block_type_combo_sql = {"action":"spa_StaticDataValues", "flag":"h", "type_id" :"12000", "has_blank_option" : "false"};
        load_combo(block_type_combo, block_type_combo_sql);
        
        var param = {
                "action": "spa_block_type_group",
                "flag": "s",
                "block_type_group_id": value_id
            };

        param = $.param(param);
        var param_url = js_data_collector_url + "&" + param;

        setTimeout(function() {
            block_type.block_type_grid.loadXML(param_url);
        }, 200);
        
        has_rights_static_data_iu = <?php echo (($has_rights_static_data_iu) ? $has_rights_static_data_iu : '0'); ?>;
        has_rights_block_type_iu = <?php echo (($has_rights_block_type_iu) ? $has_rights_block_type_iu : '0'); ?>;
        has_rights_block_type_grid_delete = <?php echo (($has_rights_block_type_delete) ? $has_rights_block_type_delete : '0'); ?>;

        if (has_rights_static_data_iu == 0) {
            block_type.block_type_toolbar.disableItem("save");
            block_type.block_type_toolbar.clearItemImage("save");
        }

        var general_Form = block_type.block_type_form.getForm();
        var value_id = '<?php echo $value_id; ?>';
        var delete_grid = "";

        if(value_id == "") {
            value_id = general_Form.getItemValue('value_id');
        }

        var php_script_loc_ajax = "<?php echo $app_php_script_loc; ?>";
        grid_toolbar = block_type.block_type_tabs.tabs("a2").attachMenu();
        grid_toolbar.setIconsPath(js_image_path + "dhxtoolbar_web/");

        //Menu for the Constraints Grid
        var constraints_toolbar =   [
            {id:"t1", text:"Edit", img:"edit.gif", items:[
                {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add", enabled: has_rights_static_data_iu},
                {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete", enabled: false }
            ]},
            {id:"t2", text:"Export", img:"export.gif", items:[
                {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
            ]},

        ];

        grid_toolbar.loadStruct(constraints_toolbar);

        if( has_rights_block_type_iu == 0 ) {
            grid_toolbar.setItemDisabled("add");
        }

        grid_toolbar.attachEvent('onClick', function (id) {
            switch (id) {
                case "add" :
                    var newId = (new Date()).valueOf();
                    block_type.block_type_grid.addRow(newId, '', '');
                    // block_type.block_type_grid.cells(newId, 1).setValue(value_id);
                    break;
                case "delete" :
                    var del_ids = block_type.block_type_grid.getSelectedRowId();
                    var id = block_type.block_type_grid.cells(del_ids, 0).getValue();
                    var static_values_id = block_type.block_type_grid.cells(del_ids, 1).getValue();
                    delete_grid += '<GridDelete  id ="' + id + '"  block_type_group_id="' + static_values_id + '" ></GridDelete>';
                    block_type.block_type_grid.deleteRow(del_ids);
  
                    grid_toolbar.setItemDisabled("delete");
                    break;
                case "excel":
                    block_type.block_type_grid.toExcel(php_script_loc_ajax + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                    break;
                case "pdf":
                    block_type.block_type_grid.toPDF(php_script_loc_ajax + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                    break;
            }
        });

        // Event after clicking in the
        block_type.block_type_toolbar.attachEvent('onClick', function (id) {

            var validation = 0;
            var blank_value = 0;
            var blank_label = '';
            generalForm = block_type.block_type_form.getForm();
            // generalGrid =
            var xml1; // XML for static data value 
            var grid_xml; // XML for grid
            var code = generalForm.getItemValue('code'); // name
            var description = generalForm.getItemValue('description') //description
            
            var status = validate_form(generalForm);
            block_type.block_type_grid.clearSelection();

            if (value_id == "") {
                value_id = generalForm.getItemValue('value_id'); // name
            }

            if (status == 'false' ) {
                return;
            }

            if (code != '') {
                if(description == '')
                {
                    description = code;
                    generalForm.setItemValue('description', code);
                }
                /*  For the general tab.
                 *  code and description save on table "<static_data_value>"
                 *  with type_id = 15001 (Hourly Block)
                 */
                xml1 = '<Root><PSRecordset type_id = "15001" value_id= "' + value_id + '" code = "' + code + '" description = "' + description + '"></PSRecordset></Root>';

                /*
                 * For Properties Properties tab
                 * all data save on table "<block type>"
                 * with General tab
                 * */
                grid_xml = '<GridGroup><Grid grid_id = "block_type_grid">';
                grid_xml += delete_grid;
                block_type.block_type_grid.forEachRow(function (id) {
                    grid_xml = grid_xml + "<GridRow ";

                    block_type.block_type_grid.forEachCell(id, function (cellObj, ind) {

                        grid_index = block_type.block_type_grid.getColumnId(ind);
                        grid_value = cellObj.getValue(ind);

                        if (grid_value == '' && grid_index == 'block_name') {
                            blank_label = 'Block Name';
                            blank_value = 1;
                        } else if ((grid_value == '' && grid_index == 'hourly_block_id') && (!blank_value)) {
                            blank_label = 'Block Defination';
                            blank_value = 1;
                        }

                        grid_index = block_type.block_type_grid.getColumnId(ind);
                        
                            grid_value = cellObj.getValue(ind);
                            grid_xml = grid_xml + " " + grid_index + '="' + grid_value + '"';
                        
                    });
                            
                    grid_xml = grid_xml + ' block_type_group_id ="' + value_id +'"';
                    grid_xml += '></GridRow>';
                });

                grid_xml += '</Grid></GridGroup>';
                
                data = {
                    "action": "spa_UpdateBlockTypeXml",
                    "flag": "i",
                    "xmlValue": xml1,
                    "xmlValue2": grid_xml
                };

                //added the callback parameter to refresh the grid of parent grid
                if (blank_value) {
                    dhtmlx.alert({
                       title: "Alert",
                       type: "alert",
                       text: "Data Error in <b>Block Type Properties</b>. Please check the data in <b>" +blank_label +"</b> and resave."
                    });
                    return;
                } else {
                    if (delete_grid != "") {
                        confirm_messagebox("Some data has been deleted from grid. Are you sure you want to save?", function() {
                            result = adiha_post_data("alert", data, "", "", "save_callback");
                            delete_grid = '';
                        }, function() {
                            refresh_grid(value_id);
                        });
                    } else {
                        
                            result = adiha_post_data("alert", data, "", "", "save_callback");
                    } 
                } 
            }
        });
    });

    function on_grid_select (id, ind) {
        if (has_rights_static_data_iu) 
            grid_toolbar.setItemEnabled('delete');
    }

    function refresh_grid(id) {
        var sql_param = {
            "sql":"EXEC spa_block_type_group @flag ='s', @block_type_group_id = " + id
        };
        sql_param = $.param(sql_param);
        var sql_url = js_data_collector_url + "&" + sql_param;
        block_type.block_type_grid.clearAll();
        block_type.block_type_grid.load(sql_url);

    }

    var save_callback = function (result) {
        var message_error;
        if (result[0].status == 'Success') {
            var new_id = result[0].recommendation;
            if(result[0].recommendation == '' ) {
                new_id = '<?php echo $value_id; ?>';
            }
            generalForm.setItemValue('value_id', new_id);
            var code = generalForm.getItemValue('code');
            refresh_grid(new_id);
            parent.setup_static_data.special_menu_case(result, code,'block_type');
        }
    }

    function load_combo(combo_obj, combo_sql) {
        var data = $.param(combo_sql);
        var url = js_dropdown_connector_url + '&' + data;
        combo_obj.load(url);
    }

</script>

