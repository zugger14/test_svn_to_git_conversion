<?php
/**
* Maintain static commodity screen
* @copyright Pioneer Solutions
*/
?>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1"/>
        <style type="text/css">
            body,
            html {
                margin: -25px !important;
                padding: 0;
            }

            .dhxform_label_nav_link {
                margin-right: 10px;
            }

            .dhxtabbar_base_dhx_web div.dhx_cell_tabbar div.dhx_cell_cont_tabbar {
                padding: 0;
            }
        </style>
        <?php require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
    </head>

    <body>

        <?php
            $layout = new AdihaLayout();
            $form_obj = new AdihaForm();

            $layout_name = 'setup_definition_commodity_layout';

            $rights_static_data_iu = 10101010; // main Save
        
            list (
                $has_rights_static_data_iu
            ) = build_security_rights (
                $rights_static_data_iu
            );

            if (isset($_POST['value_id'])) {
                $value_id = get_sanitized_value($_POST['value_id']);
                $xml = '<Root><PSRecordset source_commodity_id="' . $value_id . '"></PSRecordset></Root>';
            } else {
                $value_id = "null";
                $xml = '<Root><PSRecordset source_commodity_id=""></PSRecordset></Root>';
            }

            $enabled = $value_id != '' ? 'true' : 'false';
        
            $layout_json = '[
                {
                    id: "a",
                    text: "Commodity",
                    width:  720,
                    height: 160,
                    header: false,
                    collapse: false,
                    fix_size: [true,true]
                },
            ]';

            $name_space = 'setup_definition_commodity';
            echo $layout->init_layout($layout_name, '', '1C', $layout_json, $name_space);

            $toolbar_name = 'setup_definition_commodity_toolbar';
            echo $layout->attach_toolbar_cell($toolbar_name, 'a');

            $toolbar_obj = new AdihaToolbar();
            echo $toolbar_obj->init_by_attach($toolbar_name, $name_space);

            echo $toolbar_obj->load_toolbar('[
                {
                    id: "save", 
                    type: "button", 
                    text:"Save", 
                    img: "save.gif", 
                    imgdis:"save_dis.gif", 
                    title:"Save", 
                    action: "holiday_calendar",
                    enabled: "'. $has_rights_static_data_iu. '" 
                }
            ]');
            
            // Save button Privilege
            if ($value_id != 'null') {
                echo $toolbar_obj->save_privilege(get_sanitized_value($_POST['type_id']), $value_id);
            }

            //Start of Tabs
            $tab_name = 'setup_definition_commodity_tabs';

            $json_tab = '[
                {
                    id: "a1",
                    text: "General",
                    width: null,
                    index: null,
                    active: true,
                    enabled: true,
                    close: false
                },{
                    id: "a3",
                    text: "Grade",
                    width: null,
                    index: null,
                    active: false,
                    enabled: '.$enabled.',
                    close: false
                },
                {
                    id: "a2",
                    text: "Quality",
                    width: null,
                    index: null,
                    active: false,
                    enabled: true,
                    close: false
                },
            ]';

            echo $layout->attach_tab_cell($tab_name, 'a', $json_tab);
            echo $name_space . "." . $tab_name . '.setTabsMode("bottom");';
            $tab_obj = new AdihaTab();


            echo $tab_obj->init_by_attach($tab_name, $name_space);

            $xml_file = "EXEC spa_create_application_ui_json 'j', 10101112, 'setup_definition_commodity', '$xml' ";
            $return_value1 = readXMLURL($xml_file);

            $form_structure_general = $return_value1[0][2];

            $form_name = 'setup_definition_commodity';
            echo $tab_obj->attach_form($form_name, 'a1', $form_structure_general, $name_space);
            
            //Grid 
            $grid_name = 'commodity_quality_grd';
            echo 'setup_definition_commodity.commodity_quality_grd = setup_definition_commodity.setup_definition_commodity_tabs.tabs("a2").attachGrid();';


            $grid_quality_obj = new GridTable('commodity_quality');
            echo $grid_quality_obj->init_grid_table($grid_name, $name_space);
            echo $grid_quality_obj->set_widths('100,130,130,130,130,130,130');
            echo $grid_quality_obj->set_search_filter(true);

            echo $grid_quality_obj->return_init();
            $grid_spa = "EXEC spa_source_commodity_maintain @flag = 'g', @source_commodity_id = '" . $value_id . "'";
            echo $grid_quality_obj->load_grid_data($sp_grid = $grid_spa);
            echo $grid_quality_obj->load_grid_functions();
        
            /* Attaching Grade Tab Starts */
            $cell_json = '[
                {id: "a", text: "Cell a"},
                {id: "b", text: "Cell b"},
                {id: "c", text: "Cell c"}
            ]';

            $grade_layout_name = 'grade_layout';
            echo $tab_obj->attach_layout_cell($name_space, $grade_layout_name, 'setup_definition_commodity.'.$tab_name, 'a3', '3W', $cell_json);
            
            $grade_layout_obj = new AdihaLayout();
            echo $grade_layout_obj->init_by_attach($grade_layout_name, $name_space);
            
            $menu_json = '[
                {id: "t1", text: "Edit", img: "edit.gif", items: [
                    {id: "add", text: "Add", img: "new.gif", imgdis: "new_dis.gif", title: "Add", enabled: "'.$has_rights_static_data_iu.'"},
                    {id: "delete", text: "Delete", img: "trash.gif", imgdis: "trash_dis.gif", title: "Delete", enabled: false},
                    {id: "copy", text: "Copy", img: "copy.gif", imgdis: "copy_dis.gif", title: "Copy", enabled: false}
                ]},
                {id: "t2", text: "Export", img: "export.gif", items: [
                    {id: "excel", text: "Excel", img: "excel.gif", imgdis: "excel_dis.gif", title: "Excel"},
                    {id: "pdf", text: "PDF", img: "pdf.gif", imgdis: "pdf_dis.gif", title: "PDF"}
                ]},
                {id: "save_changes", text: "Save", img: "save.gif", imgdis: "save_dis.gif", title: "Save", enabled: "'.$has_rights_static_data_iu.'"}
            ]';

            /* Accordion 1 (Origin and Form) */
            $accordion_obj = new AdihaAccordion();
            
            $acc_json = '{
                multi_mode:true, 
                items:[
                    {
                        id: "origin", 
                        text: "<div><a class=\"undock_deemed undock_custom\" title=\"Undock\" onClick=\"undock_window(\'origin\')\"></a>Origin</div>", 
                        height: "*"
                    },
                    {
                        id: "form",
                        text: "<div><a class=\"undock_std undock_custom\" title=\"Undock\" onClick=\"undock_window(\'form\')\"></a>Form</div>", 
                        height: "*"
                    },
                ]
            }';

            echo $grade_layout_obj->attach_accordion_cell('accordion1', 'a');
            echo $accordion_obj->init_by_attach('accordion1', $name_space);
            echo $accordion_obj->load_accordion($acc_json);
        
            echo $accordion_obj->attach_menu_cell("origin_menu", 'origin');
            $origin_menu = new AdihaMenu();
            echo $origin_menu->init_by_attach('origin_menu', $name_space);
            echo $origin_menu->load_menu($menu_json);
            echo $origin_menu->attach_event('', 'onClick', $name_space . '.origin_menu_click');
        
            $grid_name = 'commodity_origin_grid';
            echo $accordion_obj->attach_grid_cell($grid_name, 'origin');
            $grid_origin_obj = new GridTable('commodity_origin');
            echo $grid_origin_obj->init_grid_table($grid_name, $name_space);
            echo $grid_origin_obj->set_widths('130,150,130');
            echo $grid_origin_obj->return_init();
            $grid_sp = "EXEC spa_commodity_grade @flag = 'g', @source_commodity_id = '" . $value_id . "'";
            echo $grid_origin_obj->load_grid_data($grid_sp, '', false, 'grid_load_callback');
            echo $grid_origin_obj->load_grid_functions();
        
            echo $accordion_obj->attach_menu_cell("form_menu", 'form');
            $form_menu = new AdihaMenu();
            echo $form_menu->init_by_attach('form_menu', $name_space);
            echo $form_menu->load_menu($menu_json);
            echo $form_menu->attach_event('', 'onClick', $name_space . '.form_menu_click');
        
            $grid_name = 'commodity_form_grid';
            echo $accordion_obj->attach_grid_cell($grid_name, 'form');
            $grid_form_obj = new GridTable('commodity_form');
            echo $grid_form_obj->init_grid_table($grid_name, $name_space);
            echo $grid_form_obj->set_widths('130,150,130');
            echo $grid_form_obj->return_init();
            echo $grid_form_obj->load_grid_functions(); 
        
            /* Accordion 2 (Attribute 1 2 3) */
            $accordion_obj1 = new AdihaAccordion();
            
            $acc_json = '{
                multi_mode: true,
                items: [
                    {
                        id: "attribute1",
                        text: "<div><a class=\"undock_deemed undock_custom\" title=\"Undock\" onClick=\"undock_window2(\'attribute1\')\"></a>Attribute 1</div>",
                        height: "*"
                    },
                    {
                        id: "attribute2",
                        text: "<div><a class=\"undock_std undock_custom\" title=\"Undock\" onClick=\"undock_window2(\'attribute2\')\"></a>Attribute 2</div>",
                        height: "*"
                    }
                ]
            }';

            echo $grade_layout_obj->attach_accordion_cell('accordion2', 'b');
            echo $accordion_obj1->init_by_attach('accordion2', $name_space);
            echo $accordion_obj1->load_accordion($acc_json);
        
            echo $accordion_obj1->attach_menu_cell("attribute1_menu", 'attribute1');
            $attribute1_menu = new AdihaMenu();
            echo $attribute1_menu->init_by_attach('attribute1_menu', $name_space);
            echo $attribute1_menu->load_menu($menu_json);
            echo $attribute1_menu->attach_event('', 'onClick', $name_space . '.attribute1_menu_click');
        
            $grid_name = 'attribute1_grid';
            echo $accordion_obj1->attach_grid_cell($grid_name, 'attribute1');
            $grid_form_obj = new GridTable('commodity_form_attribute1');
            echo $grid_form_obj->init_grid_table($grid_name, $name_space);
            echo $grid_form_obj->set_widths('130,130,130,130');
            echo $grid_form_obj->return_init();
            echo $grid_form_obj->load_grid_functions();
            echo $grid_form_obj->attach_event('', 'onEditCell', $name_space.'.attribute_cell_change');
            echo $grid_form_obj->attach_event('', 'onXLE', $name_space.'.reload_dropdown');

            echo $accordion_obj1->attach_menu_cell("attribute2_menu", 'attribute2');
            $attribute2_menu = new AdihaMenu();
            echo $attribute2_menu->init_by_attach('attribute2_menu', $name_space);
            echo $attribute2_menu->load_menu($menu_json);
            echo $attribute2_menu->attach_event('', 'onClick', $name_space . '.attribute2_menu_click');
        
            $grid_name = 'attribute2_grid';
            echo $accordion_obj1->attach_grid_cell($grid_name, 'attribute2');
            $grid_form_obj = new GridTable('commodity_form_attribute2');
            echo $grid_form_obj->init_grid_table($grid_name, $name_space);
            echo $grid_form_obj->set_widths('130,130,130,130');
            echo $grid_form_obj->return_init();
            echo $grid_form_obj->load_grid_functions();
            echo $grid_form_obj->attach_event('', 'onEditCell', $name_space.'.attribute2_cell_change');
            echo $grid_form_obj->attach_event('', 'onXLE', $name_space.'.reload_dropdown');
        
            /* Accordion 3 (Attribute 4 5) */
            $accordion_obj3 = new AdihaAccordion();
            
            $acc_json = '{
                multi_mode:true,
                items:[
                    {
                        id: "attribute3",
                        text: "<div><a class=\"undock_std undock_custom\" title=\"Undock\" onClick=\"undock_window2(\'attribute3\')\"></a>Attribute 3</div>",
                        height: "*"
                    },
                    {
                        id: "attribute4",
                        text: "<div><a class=\"undock_deemed undock_custom\" title=\"Undock\" onClick=\"undock_window3(\'attribute4\')\"></a>Attribute 4</div>",
                        height: "*"
                    },
                    {
                        id: "attribute5",
                        text: "<div><a class=\"undock_std undock_custom\" title=\"Undock\" onClick=\"undock_window3(\'attribute5\')\"></a>Attribute 5</div>",
                        height: "*"
                    },
                ]
            }';
            
            echo $grade_layout_obj->attach_accordion_cell('accordion3', 'c');
            echo $accordion_obj3->init_by_attach('accordion3', $name_space);
            echo $accordion_obj3->load_accordion($acc_json);
            
            echo $accordion_obj3->attach_menu_cell("attribute3_menu", 'attribute3');
            $attribute3_menu = new AdihaMenu();
            echo $attribute3_menu->init_by_attach('attribute3_menu', $name_space);
            echo $attribute3_menu->load_menu($menu_json);
            echo $attribute3_menu->attach_event('', 'onClick', $name_space . '.attribute3_menu_click');
            
            $grid_name = 'attribute3_grid';
            echo $accordion_obj3->attach_grid_cell($grid_name, 'attribute3');
            $grid_form_obj = new GridTable('commodity_form_attribute3');
            echo $grid_form_obj->init_grid_table($grid_name, $name_space);
            echo $grid_form_obj->set_widths('130,130,130,130');
            echo $grid_form_obj->return_init();
            echo $grid_form_obj->load_grid_functions();
            echo $grid_form_obj->attach_event('', 'onEditCell', $name_space.'.attribute3_cell_change');
            echo $grid_form_obj->attach_event('', 'onXLE', $name_space.'.reload_dropdown');
            
            echo $accordion_obj3->attach_menu_cell("attribute4_menu", 'attribute4');
            $attribute4_menu = new AdihaMenu();
            echo $attribute4_menu->init_by_attach('attribute4_menu', $name_space);
            echo $attribute4_menu->load_menu($menu_json);
            echo $attribute4_menu->attach_event('', 'onClick', $name_space . '.attribute4_menu_click');
            
            $grid_name = 'attribute4_grid';
            echo $accordion_obj3->attach_grid_cell($grid_name, 'attribute4');
            $grid_form_obj = new GridTable('commodity_form_attribute4');
            echo $grid_form_obj->init_grid_table($grid_name, $name_space);
            echo $grid_form_obj->set_widths('130,130,130,130');
            echo $grid_form_obj->return_init();
            echo $grid_form_obj->load_grid_functions();
            echo $grid_form_obj->attach_event('', 'onEditCell', $name_space.'.attribute4_cell_change');
            echo $grid_form_obj->attach_event('', 'onXLE', $name_space.'.reload_dropdown');
            
            echo $accordion_obj3->attach_menu_cell("attribute5_menu", 'attribute5');
            $attribute5_menu = new AdihaMenu();
            echo $attribute5_menu->init_by_attach('attribute5_menu', $name_space);
            echo $attribute5_menu->load_menu($menu_json);
            echo $attribute5_menu->attach_event('', 'onClick', $name_space . '.attribute5_menu_click');
            
            $grid_name = 'attribute5_grid';
            echo $accordion_obj3->attach_grid_cell($grid_name, 'attribute5');
            $grid_form_obj = new GridTable('commodity_form_attribute5');
            echo $grid_form_obj->init_grid_table($grid_name, $name_space);
            echo $grid_form_obj->set_widths('130,130,130,130');
            echo $grid_form_obj->return_init();
            echo $grid_form_obj->load_grid_functions();
            echo $grid_form_obj->attach_event('', 'onEditCell', $name_space.'.attribute5_cell_change');
            echo $grid_form_obj->attach_event('', 'onXLE', $name_space.'.reload_dropdown');
        
            /* Attaching Grade Tab Ends */
        
            echo $layout->close_layout();
        ?>

        <script type="text/javascript">
            var value_id = '<?php echo $value_id; ?>';
            var delete_origin_grid = '';
            var delete_form_grid = '';
            var delete_form_attribute1_grid = '';
            var delete_form_attribute2_grid = '';
            var delete_form_attribute3_grid = '';
            var delete_form_attribute4_grid = '';
            var delete_form_attribute5_grid = '';
            var new_commodity_type_id = '';
            var generalForm = null;

            var has_rights_static_data_iu = <?php echo (($has_rights_static_data_iu) ? $has_rights_static_data_iu : '0');?>;
            
            $(function () {
                setup_definition_commodity.accordion3.cells('attribute4').close(true);
                setup_definition_commodity.accordion3.cells('attribute5').close(true);
                var delete_grid = '';
                var check_box_json;
                var commodity_quality_changed_cell_arr = [];
                var js_php_path = "<?php echo $app_php_script_loc; ?>";
                
                //Form Dropdown
                var commodity_type_id = setup_definition_commodity.setup_definition_commodity.getItemValue('commodity_type');
                var col_index = setup_definition_commodity.commodity_form_grid.getColIndexById("form");
                
                var cm_param = {
                    "action": "[spa_generic_mapping_header]", 
                    "flag": "n",
                    "combo_sql_stmt": "SELECT commodity_type_form_id, sdv.code"
                        + " FROM commodity_type_form ctf LEFT JOIN static_data_value sdv ON sdv.value_id = ctf.commodity_form_value"
                        + " WHERE ctf.commodity_type_id = '" + commodity_type_id + "'",
                    "call_from": "grid"
                };
        
                cm_param = $.param(cm_param);
                var url = js_dropdown_connector_url + '&' + cm_param;
                var combo_obj = setup_definition_commodity.commodity_form_grid.getColumnCombo(col_index);                
                combo_obj.enableFilteringMode("between", null, false);
                combo_obj.load(url);
                
                grid_toolbar = setup_definition_commodity.setup_definition_commodity_tabs.tabs("a2").attachMenu();
                grid_toolbar.setIconsPath(js_image_path + "dhxtoolbar_web/");
                
                if (has_rights_static_data_iu) {
                    has_rights_static_data_iu = true;
                } else {
                    has_rights_static_data_iu = false;
                }

                //Menu for the Constraints Grid
                var constraints_toolbar = [
                    {id: "t1", text: "Edit", img: "edit.gif", items: [
                        {id: "add", text: "Add", img: "new.gif", imgdis: "new_dis.gif", title: "Add", enabled: has_rights_static_data_iu},
                        {id: "delete", text: "Delete", img: "trash.gif", imgdis: "trash_dis.gif", title: "Delete", enabled: false}
                    ]},
                    {id: "t2", text: "Export", img: "export.gif", items: [
                        {id: "excel", text: "Excel", img: "excel.gif", imgdis: "excel_dis.gif", title: "Excel"},
                        {id: "pdf", text: "PDF", img: "pdf.gif", imgdis: "pdf_dis.gif", title: "PDF"}
                    ]},
                ];

                grid_toolbar.loadStruct(constraints_toolbar);

                grid_toolbar.attachEvent('onClick', function (id) {
                    switch (id) {
                        case "add" :
                            var newId = (new Date()).valueOf();
                            setup_definition_commodity.commodity_quality_grd.addRow(newId, '', '');
                            setup_definition_commodity.commodity_quality_grd.cells(newId, 6).setValue(value_id);
                            break;
                        case "delete" :
                            var del_ids = setup_definition_commodity.commodity_quality_grd.getSelectedRowId();
                            var values_id = setup_definition_commodity.commodity_quality_grd.cells(del_ids, 0).getValue();
                            var static_values_id = setup_definition_commodity.commodity_quality_grd.cells(del_ids, 1).getValue();
                            delete_grid += '<GridRow  commodity_quality_id ="' + values_id + '" ></GridRow>';
                            setup_definition_commodity.commodity_quality_grd.deleteRow(del_ids);
                            grid_toolbar.setItemDisabled("delete");
                            break;
                        case "excel":
                            setup_definition_commodity.commodity_quality_grd.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                            break;
                        case "pdf":
                            setup_definition_commodity.commodity_quality_grd.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                            break;
                    }
                });

                // Event after clicking in the
                setup_definition_commodity.setup_definition_commodity_toolbar.attachEvent('onClick', function (id) {
                    if (id == 'save') {
                        new_commodity_type_id = setup_definition_commodity.setup_definition_commodity.getItemValue('commodity_type');
                        
                        if ((new_commodity_type_id != commodity_type_id) && commodity_type_id != '') {
                            data = {
                                "action": "spa_commodity_grade", 
                                "source_commodity_id": value_id, 
                                "flag": "h"
                            };

                            adiha_post_data("return_array", data, "", "", "setup_definition_commodity.commodity_type_check");
                            return;
                        } else {
                            save_commodity();
                        }
                    }
                });
                
                setup_definition_commodity.commodity_type_check = function(result) {
                    if (result[0][0] == "true") {
                        commodity_type_id = new_commodity_type_id;
                        save_commodity();
                    } else {
                        var msg = "Cannot change Commodity Type as it is already mapped with Forms.";
                        show_messagebox(msg);
                    }
                }
                
                function save_commodity() {
                    generalForm = setup_definition_commodity.setup_definition_commodity.getForm();
                    tab_id = setup_definition_commodity.setup_definition_commodity_tabs.getAllTabs();
                    var status = validate_form(generalForm);

                    if (status === false) {
                        generate_error_message(setup_definition_commodity.setup_definition_commodity_tabs.tabs(tab_id[0]));
                        return;
                    } else {
                        var form_xml;
                        var grid_xml = '';
                        var grid_index;
                        var grid_value;
                        var xml;
                        var validate_chk1 = 0;

                        var source_commodity_id = value_id;
                        var source_system_id = generalForm.getItemValue('source_system_id');
                        var commodity_id = generalForm.getItemValue('commodity_id');
                        var commodity_name = generalForm.getItemValue('commodity_name');
                        var valuation_curve = generalForm.getItemValue('valuation_curve');
                        var commodity_type = generalForm.getItemValue('commodity_type');
                        var commodity_group1 = generalForm.getItemValue('commodity_group1');
                        var commodity_group2 = generalForm.getItemValue('commodity_group2');
                        var commodity_group3 = generalForm.getItemValue('commodity_group3');
                        var commodity_group4 = generalForm.getItemValue('commodity_group4');
                        var accounting_code = generalForm.getItemValue('accounting_code');

                        form_xml = '<Root function_id="10101112"><FormXML source_commodity_id = "' + source_commodity_id + '" commodity_id = "' + commodity_id + '" commodity_name = "' + commodity_name + '" source_system_id = "' + source_system_id + '" valuation_curve = "' + valuation_curve + '" commodity_type = "' + commodity_type + '" commodity_group1 = "' + commodity_group1 + '" commodity_group2 = "' + commodity_group2 + '" commodity_group3 = "' + commodity_group3 + '" commodity_group4 = "' + commodity_group4 + '" accounting_code = "'+ accounting_code +'" ></FormXML>';
                        grid_xml += setup_definition_commodity.get_changed_data_grid();
                        xml = form_xml + grid_xml + '</Root>';
                        
                        data = {
                            "action": "spa_process_form_data", 
                            "xml": xml
                        };
                        
                        var count = setup_definition_commodity.commodity_quality_grd.getRowsNum();
                        
                        if (count <= 0) {
                            validate_chk1 = 1;
                        } else {
                            validate_chk1 = validate_grid(tab_id);
                        }

                        if (validate_chk1 == 1) {
                            if (delete_grid != '') {
                                del_msg = "Some data has been deleted from grid. Are you sure you want to save?";
                                result = adiha_post_data("confirm-warning", data, "", "", "setup_definition_commodity.call_back", "", del_msg);
                            } else {
                                result = adiha_post_data("alert", data, "", "", "setup_definition_commodity.call_back");
                            }
                        }
                    }
                }
                
                
                setup_definition_commodity.commodity_quality_grd.attachEvent("onEditCell", function (stage, rId, cInd, nValue, oValue) {
                    if (stage == 2) {
                        if (nValue != oValue && cInd >= 0) {
                            commodity_quality_changed_cell_arr.push(rId);
                            
                            if (cInd == 1) {
                                setup_definition_commodity.get_quality_type(nValue, rId);
                            }
                        }
                    }

                    commodity_quality_changed_cell_arr = commodity_quality_changed_cell_arr.filter(function (elem, pos) {
                        return commodity_quality_changed_cell_arr.indexOf(elem) == pos;
                    });

                    return true;
                });

                setup_definition_commodity.get_quality_type = function (value, rId) {
                    var data = {
                        "action": "spa_source_commodity_maintain",
                        "flag": "q",
                        "source_commodity_id": value,
                        "row_id": rId
                    };

                    adiha_post_data('return_array', data, '', '', 'setup_definition_commodity.set_quality_type');
                }

                setup_definition_commodity.set_quality_type = function (result) {
                    setup_definition_commodity.commodity_quality_grd.cells(result[0][1], 2).setValue(result[0][0]);
                }

                setup_definition_commodity.get_changed_data_grid = function () {
                    var i = 0;
                    var grid_xml = '';

                    grid_xml += '<GridGroup>';
                    
                    if (delete_grid != '') {
                        grid_xml += '<GridDelete grid_id="commodity_quality" grid_label="Commodity">' + delete_grid + '</GridDelete>';
                    }
                    
                    if (commodity_quality_changed_cell_arr.length > 0) {
                        grid_xml += '<Grid grid_id="commodity_quality">';
                        
                        $.each(commodity_quality_changed_cell_arr, function (index, value) {
                            grid_xml += "<GridRow ";
                            
                            setup_definition_commodity.commodity_quality_grd.forEachCell(value, function (cellObj, ind) {
                                grid_index = setup_definition_commodity.commodity_quality_grd.getColumnId(ind);
                                grid_value = cellObj.getValue(ind);
                                
                                if (grid_index != 'type') {
                                    grid_xml += " " + grid_index + '="' + grid_value + '"';
                                }
                            });

                            grid_xml += '></GridRow>';
                        });

                        grid_xml += '</Grid>';
                    } else {
                        grid_xml += '';
                    }
                    
                    grid_xml += '</GridGroup>';
                    
                    return grid_xml;
                }

                /**
                 Close the tab and open again for new data insert.
                 */
                setup_definition_commodity.call_back = function (result) {
                    if (result[0].errorcode == "Success") {
                        var new_id = result[0].recommendation;
                        
                        if (result[0].recommendation != null) {
                            generalForm.setItemValue('source_commodity_id', new_id);
                            value_id = new_id;
                        } else {
                            new_id = value_id;
                        }

                        generalForm.setItemValue('value_id', new_id);
                        var code = generalForm.getItemValue('commodity_name');
                        refresh_grid(new_id);
                        setup_definition_commodity.refresh_origin_grid();
                        load_form_dropdown();
                        delete_grid = "";
                        commodity_quality_changed_cell_arr = [];
                        parent.setup_static_data.special_menu_case(result, code, 'commodity');
                    }
                }
                
                setup_definition_commodity.commodity_origin_grid.attachEvent("onSelectStateChanged", function(id) {
                    setup_definition_commodity.refresh_form_grid();
                });
                
                setup_definition_commodity.commodity_form_grid.attachEvent("onSelectStateChanged", function(id) {
                    setup_definition_commodity.refresh_attribute1_grid();
                });
                
                setup_definition_commodity.attribute1_grid.attachEvent("onSelectStateChanged", function(id) {
                    setup_definition_commodity.refresh_attribute2_grid();
                });
                
                setup_definition_commodity.attribute2_grid.attachEvent("onSelectStateChanged", function(id) {
                    setup_definition_commodity.refresh_attribute3_grid();
                });
                
                setup_definition_commodity.attribute3_grid.attachEvent("onSelectStateChanged", function(id) {
                    setup_definition_commodity.refresh_attribute4_grid();
                });
                
                setup_definition_commodity.attribute4_grid.attachEvent("onSelectStateChanged", function(id) {
                    setup_definition_commodity.refresh_attribute5_grid();
                });
                
                setup_definition_commodity.attribute5_grid.attachEvent("onSelectStateChanged", function(id) {
                    if (has_rights_static_data_iu) {
                        setup_definition_commodity.attribute5_menu.setItemEnabled("delete");
                        setup_definition_commodity.attribute5_menu.setItemEnabled("copy");
                    }
                });
                
                setup_definition_commodity.refresh_origin_grid = function() {
                    var selected_row_id = setup_definition_commodity.commodity_origin_grid.getSelectedRowId();
                    selected_row_id = (selected_row_id != null) ? selected_row_id : 0;
                    setup_definition_commodity.origin_menu.setItemDisabled("delete");
                    setup_definition_commodity.origin_menu.setItemDisabled("copy");
                   
                    var sql_param = {
                        "flag": "g",
                        "action": "spa_commodity_grade",
                        "grid_type": "g",
                        "source_commodity_id": value_id
                    };

                    sql_param = $.param(sql_param);
                    var sql_url = js_data_collector_url + "&" + sql_param;
                    setup_definition_commodity.commodity_origin_grid.clearAll();
                    
                    setup_definition_commodity.commodity_origin_grid.load(sql_url, function(){
                        setup_definition_commodity.commodity_origin_grid.selectRowById(selected_row_id);
                        setup_definition_commodity.refresh_form_grid();
                    });
                    
                    delete_origin_grid = '';
                }
                
                setup_definition_commodity.refresh_form_grid = function() {
                    var selected_row_id = setup_definition_commodity.commodity_form_grid.getSelectedRowId();
                    selected_row_id = (selected_row_id != null) ? selected_row_id : 0;
                    var row_id  = setup_definition_commodity.commodity_origin_grid.getSelectedRowId();
                    
                    if (row_id != null) {
                        if (has_rights_static_data_iu) {
                            setup_definition_commodity.origin_menu.setItemEnabled("delete");
                            setup_definition_commodity.origin_menu.setItemEnabled("copy");
                        }
                        
                        var col_index = setup_definition_commodity.commodity_origin_grid.getColIndexById("commodity_origin_id");
                        var origin_id = setup_definition_commodity.commodity_origin_grid.cells(row_id, col_index).getValue();
                        
                        var sql_param = {
                            "flag": "f",
                            "action": "spa_commodity_grade",
                            "grid_type": "g",
                            "source_commodity_id": origin_id
                        };

                        sql_param = $.param(sql_param);
                        var sql_url = js_data_collector_url + "&" + sql_param;
                    }
                    
                    setup_definition_commodity.commodity_form_grid.clearAll();
                    
                    if (row_id != null) {
                        setup_definition_commodity.commodity_form_grid.load(sql_url, function() {
                            setup_definition_commodity.form_menu.setItemDisabled("delete");
                            setup_definition_commodity.form_menu.setItemDisabled("copy");
                            setup_definition_commodity.commodity_form_grid.selectRowById(selected_row_id);
                            setup_definition_commodity.refresh_attribute1_grid();
                            
                            if (origin_id != '') {
                                setup_definition_commodity.form_menu.setItemEnabled("add");
                            } else {
                                setup_definition_commodity.form_menu.setItemDisabled("add");
                            }
                        });
                    } else {
                        setup_definition_commodity.refresh_attribute1_grid();
                        setup_definition_commodity.form_menu.setItemDisabled("add");
                        setup_definition_commodity.form_menu.setItemDisabled("delete");
                        setup_definition_commodity.form_menu.setItemDisabled("copy");
                    }
                    
                    delete_form_grid = '';
                }
                
                setup_definition_commodity.refresh_attribute1_grid = function() {
                    var selected_row_id = setup_definition_commodity.attribute1_grid.getSelectedRowId();
                    selected_row_id = (selected_row_id != null) ? selected_row_id : 0;
                    var row_id  = setup_definition_commodity.commodity_form_grid.getSelectedRowId();
                    
                    if (row_id != null) {
                        setup_definition_commodity.form_menu.setItemEnabled("delete");
                        setup_definition_commodity.form_menu.setItemEnabled("copy");
                        
                        var col_index = setup_definition_commodity.commodity_form_grid.getColIndexById("commodity_form_id");
                        var form_id = setup_definition_commodity.commodity_form_grid.cells(row_id, col_index).getValue();
                        
                        var sql_param = {
                            "flag": "a",
                            "action":"spa_commodity_grade",
                            "grid_type":"g",
                            "source_commodity_id": form_id
                        };

                        sql_param = $.param(sql_param);
                        var sql_url = js_data_collector_url + "&" + sql_param;
                    }
                    
                    setup_definition_commodity.attribute1_grid.clearAll();
                    
                    if (row_id != null) {
                        setup_definition_commodity.attribute1_grid.load(sql_url, function() {
                            setup_definition_commodity.attribute1_menu.setItemDisabled("delete");
                            setup_definition_commodity.attribute1_menu.setItemDisabled("copy");
                            setup_definition_commodity.attribute1_grid.selectRowById(selected_row_id);
                            setup_definition_commodity.refresh_attribute2_grid();
                            
                            if (form_id != '') {
                                setup_definition_commodity.attribute1_menu.setItemEnabled("add");
                            } else {
                                setup_definition_commodity.attribute1_menu.setItemDisabled("add");
                            }
                        });
                    } else {
                        setup_definition_commodity.refresh_attribute2_grid();
                        setup_definition_commodity.attribute1_menu.setItemDisabled("add");
                        setup_definition_commodity.attribute1_menu.setItemDisabled("delete");
                        setup_definition_commodity.attribute1_menu.setItemDisabled("copy");
                    }
                    
                    delete_form_attribute1_grid = '';
                }
                
                setup_definition_commodity.refresh_attribute2_grid = function() {
                    var selected_row_id = setup_definition_commodity.attribute2_grid.getSelectedRowId();
                    selected_row_id = (selected_row_id != null) ? selected_row_id : 0;
                    var row_id  = setup_definition_commodity.attribute1_grid.getSelectedRowId();
                    
                    if (row_id != null) {
                        setup_definition_commodity.attribute1_menu.setItemEnabled("delete");
                        setup_definition_commodity.attribute1_menu.setItemEnabled("copy");
                        
                        var col_index = setup_definition_commodity.attribute1_grid.getColIndexById("commodity_form_attribute1_id");
                        var commodity_form_attribute1_id = setup_definition_commodity.attribute1_grid.cells(row_id, col_index).getValue();
                        
                        var sql_param = {
                            "flag": "b",
                            "action":"spa_commodity_grade",
                            "grid_type":"g",
                            "source_commodity_id": commodity_form_attribute1_id
                        };

                        sql_param = $.param(sql_param);
                        var sql_url = js_data_collector_url + "&" + sql_param;
                    }
                    
                    setup_definition_commodity.attribute2_grid.clearAll();
                    
                    if (row_id != null) {
                        setup_definition_commodity.attribute2_grid.load(sql_url, function() {
                            setup_definition_commodity.attribute2_menu.setItemDisabled("delete");
                            setup_definition_commodity.attribute2_menu.setItemDisabled("copy");
                            setup_definition_commodity.attribute2_grid.selectRowById(selected_row_id);
                            setup_definition_commodity.refresh_attribute3_grid();
                            
                            if (commodity_form_attribute1_id != '') {
                                setup_definition_commodity.attribute2_menu.setItemEnabled("add");
                            } else {
                                setup_definition_commodity.attribute2_menu.setItemDisabled("add");
                            }
                        });
                    } else {
                        setup_definition_commodity.refresh_attribute3_grid();
                        setup_definition_commodity.attribute2_menu.setItemDisabled("add");
                        setup_definition_commodity.attribute2_menu.setItemDisabled("delete");
                        setup_definition_commodity.attribute2_menu.setItemDisabled("copy");
                    }
                    
                    delete_form_attribute2_grid = '';
                }
                
                setup_definition_commodity.refresh_attribute3_grid = function() {
                    var selected_row_id = setup_definition_commodity.attribute3_grid.getSelectedRowId();
                    selected_row_id = (selected_row_id != null) ? selected_row_id : 0;
                    var row_id  = setup_definition_commodity.attribute2_grid.getSelectedRowId();
                    
                    if (row_id != null) {
                        setup_definition_commodity.attribute2_menu.setItemEnabled("delete");
                        setup_definition_commodity.attribute2_menu.setItemEnabled("copy");
                        
                        var col_index = setup_definition_commodity.attribute2_grid.getColIndexById("commodity_form_attribute2_id");
                        var commodity_form_attribute2_id = setup_definition_commodity.attribute2_grid.cells(row_id, col_index).getValue();
                        
                        var sql_param = {
                            "flag": "c",
                            "action":"spa_commodity_grade",
                            "grid_type":"g",
                            "source_commodity_id": commodity_form_attribute2_id
                        };

                        sql_param = $.param(sql_param);
                        var sql_url = js_data_collector_url + "&" + sql_param;
                    }
                    
                    setup_definition_commodity.attribute3_grid.clearAll();
                    
                    if (row_id != null) {
                        setup_definition_commodity.attribute3_grid.load(sql_url, function() {
                            setup_definition_commodity.attribute3_menu.setItemDisabled("delete");
                            setup_definition_commodity.attribute3_menu.setItemDisabled("copy");
                            setup_definition_commodity.attribute3_grid.selectRowById(selected_row_id);
                            setup_definition_commodity.refresh_attribute4_grid();
                            
                            if (commodity_form_attribute2_id != '') {
                                setup_definition_commodity.attribute3_menu.setItemEnabled("add");
                            } else {
                                setup_definition_commodity.attribute3_menu.setItemDisabled("add");
                            }
                        });
                    } else {
                        setup_definition_commodity.refresh_attribute4_grid();
                        setup_definition_commodity.attribute3_menu.setItemDisabled("add");
                        setup_definition_commodity.attribute3_menu.setItemDisabled("delete");
                        setup_definition_commodity.attribute3_menu.setItemDisabled("copy");
                    }
                    
                    delete_form_attribute3_grid = '';
                }
                
                setup_definition_commodity.refresh_attribute4_grid = function() {
                    var selected_row_id = setup_definition_commodity.attribute4_grid.getSelectedRowId();
                    selected_row_id = (selected_row_id != null) ? selected_row_id : 0;
                    var row_id  = setup_definition_commodity.attribute3_grid.getSelectedRowId();
                    
                    if (row_id != null) {
                        setup_definition_commodity.attribute3_menu.setItemEnabled("delete");
                        setup_definition_commodity.attribute3_menu.setItemEnabled("copy");
                        
                        var col_index = setup_definition_commodity.attribute3_grid.getColIndexById("commodity_form_attribute3_id");
                        var commodity_form_attribute3_id = setup_definition_commodity.attribute3_grid.cells(row_id, col_index).getValue();
                        
                        var sql_param = {
                            "flag": "d",
                            "action":"spa_commodity_grade",
                            "grid_type":"g",
                            "source_commodity_id": commodity_form_attribute3_id
                        };

                        sql_param = $.param(sql_param);
                        var sql_url = js_data_collector_url + "&" + sql_param;
                    }
                    
                    setup_definition_commodity.attribute4_grid.clearAll();
                    
                    if (row_id != null) {
                        setup_definition_commodity.attribute4_grid.load(sql_url, function() {
                            setup_definition_commodity.attribute4_menu.setItemDisabled("delete");
                            setup_definition_commodity.attribute4_menu.setItemDisabled("copy");
                            setup_definition_commodity.attribute4_grid.selectRowById(selected_row_id);
                            setup_definition_commodity.refresh_attribute5_grid();
                            
                            if (commodity_form_attribute3_id != '') {
                                setup_definition_commodity.attribute4_menu.setItemEnabled("add");
                            } else {
                                setup_definition_commodity.attribute4_menu.setItemDisabled("add");
                            }
                        });
                    } else {
                        setup_definition_commodity.refresh_attribute5_grid();
                        setup_definition_commodity.attribute4_menu.setItemDisabled("add");
                        setup_definition_commodity.attribute4_menu.setItemDisabled("delete");
                        setup_definition_commodity.attribute4_menu.setItemDisabled("copy");
                    }
                    
                    delete_form_attribute4_grid = '';
                }
                
                setup_definition_commodity.refresh_attribute5_grid = function() {
                    var selected_row_id = setup_definition_commodity.attribute5_grid.getSelectedRowId();
                    selected_row_id = (selected_row_id != null) ? selected_row_id : 0;
                    var row_id  = setup_definition_commodity.attribute4_grid.getSelectedRowId();
                    
                    if (row_id != null) {
                        setup_definition_commodity.attribute4_menu.setItemEnabled("delete");
                        setup_definition_commodity.attribute4_menu.setItemEnabled("copy");
                        
                        var col_index = setup_definition_commodity.attribute4_grid.getColIndexById("commodity_form_attribute4_id");
                        var commodity_form_attribute4_id = setup_definition_commodity.attribute4_grid.cells(row_id, col_index).getValue();
                        
                        var sql_param = {
                            "flag": "e",
                            "action":"spa_commodity_grade",
                            "grid_type":"g",
                            "source_commodity_id": commodity_form_attribute4_id
                        };

                        sql_param = $.param(sql_param);
                        var sql_url = js_data_collector_url + "&" + sql_param;
                    }
                    
                    setup_definition_commodity.attribute5_grid.clearAll();
                    
                    if (row_id != null) {
                        setup_definition_commodity.attribute5_grid.load(sql_url, function() {
                            setup_definition_commodity.attribute5_grid.selectRowById(selected_row_id);

                            if (commodity_form_attribute4_id != '') {
                                setup_definition_commodity.attribute5_menu.setItemEnabled("add");
                            } else {
                                setup_definition_commodity.attribute5_menu.setItemDisabled("add");
                            }
                        });
                    } else {
                        setup_definition_commodity.attribute5_menu.setItemDisabled("add");
                        setup_definition_commodity.attribute5_menu.setItemDisabled("delete");
                        setup_definition_commodity.attribute5_menu.setItemDisabled("copy");
                    }
                    
                    delete_form_attribute5_grid = '';
                }
                
                setup_definition_commodity.commodity_quality_grd.attachEvent("onRowSelect", doOnRowSelected);
                
                function doOnRowSelected(id) {
                    grid_toolbar.setItemEnabled("delete");
                }

                function refresh_grid(id) {
                    var sql_param = {
                        "sql": "EXEC spa_source_commodity_maintain @flag = 'g', @source_commodity_id = '" + value_id + "'"
                    };

                    sql_param = $.param(sql_param);
                    var sql_url = js_data_collector_url + "&" + sql_param;
                    setup_definition_commodity.commodity_quality_grd.clearAll();
                    setup_definition_commodity.commodity_quality_grd.load(sql_url);
                    var count = setup_definition_commodity.commodity_quality_grd.getRowsNum();
                    
                    if (count > 0) {
                        setup_definition_commodity.commodity_quality_grd.forEachRow(function (id) {
                            // Looping for cell
                            setup_definition_commodity.commodity_quality_grd.forEachCell(id, function (cellObj, ind) {
                                grid_index = setup_definition_commodity.commodity_quality_grd.getColumnId(ind);
                                
                                if (grid_index == 'range') {
                                    range = cellObj.getValue(ind);
                                }
                            });

                        });
                    }
                }

                function validate_grid(tab_id) {
                    var temp_from_value;
                    var temp_to_value;
                    var range;
                    var quality_col_validaion = 0;
                    var from_col_validation = 0;
                    var to_col_validation = 0;
                    var from_to_col_error = 0;
                    var result = 0;
                    var error = 0;
                    var error_col = 0;
                    var quality = 0;

                    // Looping for Row           
                    setup_definition_commodity.commodity_quality_grd.forEachRow(function (id) {
                        // Looping for cell
                        setup_definition_commodity.commodity_quality_grd.forEachCell(id, function (cellObj, ind) {
                            from_col_validation = 0;
                            to_col_validation = 0;
                            grid_index = setup_definition_commodity.commodity_quality_grd.getColumnId(ind);
                            
                            grid_value = cellObj.getValue(ind);
                            
                            if (grid_index == 'from_value') {
                                temp_from_value = cellObj.getValue(ind);                                
                            } else if (grid_index == 'to_value') {
                                temp_to_value = cellObj.getValue(ind);
                            } else if (grid_index == 'type') {
                                range = cellObj.getValue(ind);
                            } else if (grid_index == 'quality') {
                                quality = cellObj.getValue(ind);
                            }
                        });

                        if (temp_from_value == "" && temp_to_value == "") {
                            error_col = 1;
                        } 
                        
                        if (quality == "") {
                            error = 3;
                        }
                    });

                    if (error == 3) {
                        setup_definition_commodity.setup_definition_commodity_tabs.tabs(tab_id[2]).setActive();
                        show_messagebox("Data Error in <b>Quality</b> grid. Please check the data in column <b>Quality</b> and resave.");
                        return;
                    } else if (error_col == 1 && error != 3) {
                        show_messagebox("Data error in Quality tab Please check the data in column <b> Form value </b> or <b> To value </b> and resave");
                        setup_definition_commodity.setup_definition_commodity_tabs.tabs(tab_id[2]);
                        return;
                    } else {
                        return 1;
                    }
                }
            });
            
            setup_definition_commodity.origin_menu_click = function(id) {
                switch (id) {
                    case "add" :
                        var newId = (new Date()).valueOf();
                        setup_definition_commodity.commodity_origin_grid.addRow(newId, '', '');
                        setup_definition_commodity.commodity_origin_grid.cells(newId, 2).setValue(value_id);
                        break;
                    case "delete" :
                        var del_ids = setup_definition_commodity.commodity_origin_grid.getSelectedRowId();
                        var values_id = setup_definition_commodity.commodity_origin_grid.cells(del_ids, 0).getValue();
                        var static_values_id = setup_definition_commodity.commodity_origin_grid.cells(del_ids, 1).getValue();
                        delete_origin_grid += '<GridRow  commodity_origin_id ="' + values_id + '" ></GridRow>';
                        setup_definition_commodity.commodity_origin_grid.deleteRow(del_ids);
                        setup_definition_commodity.origin_menu.setItemDisabled("delete");
                        setup_definition_commodity.refresh_form_grid();
                        break;
                    case "excel":
                        setup_definition_commodity.commodity_origin_grid.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                        break;
                    case "pdf":
                        setup_definition_commodity.commodity_origin_grid.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                        break;
                    case "save_changes":
                        grid_xml = '<GridGroup>';
                        
                        if (delete_origin_grid != '') {
                            grid_xml += '<GridDelete grid_id="commodity_origin" grid_label="Origin">' + delete_origin_grid + '</GridDelete>';
                        }
                        
                        var ids = setup_definition_commodity.commodity_origin_grid.getChangedRows(true);
                        
                        if (ids != '') {
                            var changed_ids = new Array();
                            changed_ids = ids.split(",");
                            
                            grid_xml += '<Grid grid_id="commodity_origin">';
                            
                            $.each(changed_ids, function (index, value) {
                                grid_xml += "<GridRow ";
                                
                                setup_definition_commodity.commodity_origin_grid.forEachCell(value, function (cellObj, ind) {
                                    grid_index = setup_definition_commodity.commodity_origin_grid.getColumnId(ind);
                                    grid_value = cellObj.getValue(ind);
                                    grid_xml += " " + grid_index + '="' + grid_value + '"';
                                });
    
                                grid_xml += '></GridRow>';
                            });
                            
                            grid_xml += '</Grid>';
                        }

                        grid_xml += '</GridGroup>';
                        
                        form_xml = '<Root function_id="10101112">';
                        xml = form_xml + grid_xml + '</Root>';
                        
                        data = {
                            "action": "spa_process_form_data", 
                            "xml": xml
                        };
                        
                        if (delete_origin_grid != '') {
                            del_msg = "Some data has been deleted from grid. Are you sure you want to save?";
                            result = adiha_post_data("confirm-warning", data, "", "", "setup_definition_commodity.refresh_origin_grid", "", del_msg);
                        } else {
                            result = adiha_post_data("alert", data, "", "", "setup_definition_commodity.refresh_origin_grid");
                        }
                        break;
                    case "copy":
                        var row_id  = setup_definition_commodity.commodity_origin_grid.getSelectedRowId();
                        var col_index = setup_definition_commodity.commodity_origin_grid.getColIndexById("commodity_origin_id");
                        var commodity_origin_id = setup_definition_commodity.commodity_origin_grid.cells(row_id, col_index).getValue();
                        
                        var xml = '<Root><FormXML commodity_origin_id="' + commodity_origin_id + '" commodity_form_id="" commodity_form_attribute1_id="" commodity_form_attribute2_id="" commodity_form_attribute3_id="" commodity_form_attribute4_id="" commodity_form_attribute5_id=""></FormXML></Root>';
                        copy(xml, "setup_definition_commodity.refresh_origin_grid");
                        break;
                }
            }
            
            setup_definition_commodity.form_menu_click = function(id) {
                switch (id) {
                    case "add" :
                        var newId = (new Date()).valueOf();
                        setup_definition_commodity.commodity_form_grid.addRow(newId, '', '');
                        var row_id  = setup_definition_commodity.commodity_origin_grid.getSelectedRowId();
                        var col_index = setup_definition_commodity.commodity_origin_grid.getColIndexById("commodity_origin_id");
                        var origin_id = setup_definition_commodity.commodity_origin_grid.cells(row_id, col_index).getValue();
                        setup_definition_commodity.commodity_form_grid.cells(newId, 2).setValue(origin_id);
                        break;
                    case "delete" :
                        var del_ids = setup_definition_commodity.commodity_form_grid.getSelectedRowId();
                        var values_id = setup_definition_commodity.commodity_form_grid.cells(del_ids, 0).getValue();
                        var static_values_id = setup_definition_commodity.commodity_form_grid.cells(del_ids, 1).getValue();
                        delete_form_grid += '<GridRow  commodity_form_id ="' + values_id + '" ></GridRow>';
                        setup_definition_commodity.commodity_form_grid.deleteRow(del_ids);
                        setup_definition_commodity.form_menu.setItemDisabled("delete");
                        setup_definition_commodity.refresh_attribute1_grid();
                        break;
                    case "excel":
                        setup_definition_commodity.commodity_form_grid.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                        break;
                    case "pdf":
                        setup_definition_commodity.commodity_form_grid.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                        break;
                    case "save_changes":
                        grid_xml = '<GridGroup>';
                        
                        if (delete_form_grid != '') {
                            grid_xml += '<GridDelete grid_id="commodity_form" grid_label="Form">' + delete_form_grid + '</GridDelete>';
                        }

                        var ids = setup_definition_commodity.commodity_form_grid.getChangedRows(true);
                        
                        if (ids != '') {
                            var changed_ids = new Array();
                            changed_ids = ids.split(",");
                            
                            grid_xml += '<Grid grid_id="commodity_form">';
                            
                            $.each(changed_ids, function (index, value) {
                                grid_xml += "<GridRow ";
                                
                                setup_definition_commodity.commodity_form_grid.forEachCell(value, function (cellObj, ind) {
                                    grid_index = setup_definition_commodity.commodity_form_grid.getColumnId(ind);
                                    grid_value = cellObj.getValue(ind);
                                    grid_xml += " " + grid_index + '="' + grid_value + '"';
                                });
    
                                grid_xml += '></GridRow>';
                            });

                            grid_xml += '</Grid>';
                        }

                        grid_xml += '</GridGroup>';
                        
                        form_xml = '<Root function_id="10101112">';
                        xml = form_xml + grid_xml + '</Root>';
                        
                        data = {
                            "action": "spa_process_form_data", 
                            "xml": xml
                        };
                        
                        if (delete_form_grid != '') {
                            del_msg = "Some data has been deleted from grid. Are you sure you want to save?";
                            result = adiha_post_data("confirm-warning", data, "", "", "setup_definition_commodity.refresh_form_grid", "", del_msg);
                        } else {
                            result = adiha_post_data("alert", data, "", "", "setup_definition_commodity.refresh_form_grid");
                        }
                        break;
                    case "copy":
                        var row_id  = setup_definition_commodity.commodity_form_grid.getSelectedRowId();
                        var col_index = setup_definition_commodity.commodity_form_grid.getColIndexById("commodity_form_id");
                        var commodity_form_id = setup_definition_commodity.commodity_form_grid.cells(row_id, col_index).getValue();
                        
                        var xml = '<Root><FormXML commodity_origin_id="" commodity_form_id="' + commodity_form_id + '" commodity_form_attribute1_id="" commodity_form_attribute2_id="" commodity_form_attribute3_id="" commodity_form_attribute4_id="" commodity_form_attribute5_id=""></FormXML></Root>';
                        copy(xml, "setup_definition_commodity.refresh_form_grid");
                        break;
                }
            }
            
            setup_definition_commodity.attribute1_menu_click = function(id) {
                switch (id) {
                    case "add" :
                        var newId = (new Date()).valueOf();
                        setup_definition_commodity.attribute1_grid.addRow(newId, '', '');
                        var row_id  = setup_definition_commodity.commodity_form_grid.getSelectedRowId();
                        var col_index = setup_definition_commodity.commodity_form_grid.getColIndexById("commodity_form_id");
                        var form_id = setup_definition_commodity.commodity_form_grid.cells(row_id, col_index).getValue();
                        var col_index = setup_definition_commodity.attribute1_grid.getColIndexById("commodity_form_id");
                        setup_definition_commodity.attribute1_grid.cells(newId, col_index).setValue(form_id);
                        break;
                    case "delete" :
                        var del_ids = setup_definition_commodity.attribute1_grid.getSelectedRowId();
                        var values_id = setup_definition_commodity.attribute1_grid.cells(del_ids, 0).getValue();
                        var static_values_id = setup_definition_commodity.attribute1_grid.cells(del_ids, 1).getValue();
                        delete_form_attribute1_grid += '<GridRow  commodity_form_attribute1_id ="' + values_id + '" ></GridRow>';
                        setup_definition_commodity.attribute1_grid.deleteRow(del_ids);
                        setup_definition_commodity.attribute1_menu.setItemDisabled("delete");
                        setup_definition_commodity.refresh_attribute2_grid();
                        break;
                    case "excel":
                        setup_definition_commodity.attribute1_grid.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                        break;
                    case "pdf":
                        setup_definition_commodity.attribute1_grid.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                        break;
                    case "save_changes":
                        grid_xml = '<GridGroup>';
                        
                        if (delete_form_attribute1_grid != '') {
                            grid_xml += '<GridDelete grid_id="commodity_form_attribute1" grid_label="Attribute 1">' + delete_form_attribute1_grid + '</GridDelete>';
                        }

                        var ids = setup_definition_commodity.attribute1_grid.getChangedRows(true);
                        
                        if (ids != '') {
                            var changed_ids = new Array();
                            changed_ids = ids.split(",");
                            
                            grid_xml += '<Grid grid_id="commodity_form_attribute1">';
                            
                            $.each(changed_ids, function (index, value) {
                                grid_xml += "<GridRow ";
                                
                                setup_definition_commodity.attribute1_grid.forEachCell(value, function (cellObj, ind) {
                                    grid_index = setup_definition_commodity.attribute1_grid.getColumnId(ind);
                                    grid_value = cellObj.getValue(ind);
                                    grid_xml += " " + grid_index + '="' + grid_value + '"';
                                });
    
                                grid_xml += '></GridRow>';
                            });

                            grid_xml += '</Grid>';
                        }

                        grid_xml += '</GridGroup>';
                        
                        form_xml = '<Root function_id="10101112">';
                        xml = form_xml + grid_xml + '</Root>';

                        data = {
                            "action": "spa_process_form_data", 
                            "xml": xml
                        };
                        
                        if (delete_form_attribute1_grid != '') {
                            del_msg = "Some data has been deleted from grid. Are you sure you want to save?";
                            result = adiha_post_data("confirm-warning", data, "", "", "setup_definition_commodity.refresh_attribute1_grid", "", del_msg);
                        } else {
                            result = adiha_post_data("alert", data, "", "", "setup_definition_commodity.refresh_attribute1_grid");
                        }
                        break;
                    case "copy":
                        var row_id  = setup_definition_commodity.attribute1_grid.getSelectedRowId();
                        var col_index = setup_definition_commodity.attribute1_grid.getColIndexById("commodity_form_attribute1_id");
                        var attribute1_id = setup_definition_commodity.attribute1_grid.cells(row_id, col_index).getValue();
                        
                        var xml = '<Root><FormXML commodity_origin_id="" commodity_form_id="" commodity_form_attribute1_id="' + attribute1_id + '" commodity_form_attribute2_id="" commodity_form_attribute3_id="" commodity_form_attribute4_id="" commodity_form_attribute5_id=""></FormXML></Root>';
                        copy(xml, "setup_definition_commodity.refresh_attribute1_grid");
                        break;
                }
            }
            
            setup_definition_commodity.attribute2_menu_click = function(id) {
                switch (id) {
                    case "add" :
                        var newId = (new Date()).valueOf();
                        setup_definition_commodity.attribute2_grid.addRow(newId, '', '');
                        var row_id  = setup_definition_commodity.attribute1_grid.getSelectedRowId();
                        var col_index = setup_definition_commodity.attribute1_grid.getColIndexById("commodity_form_attribute1_id");
                        var attribute1_id = setup_definition_commodity.attribute1_grid.cells(row_id, col_index).getValue();
                        var col_index = setup_definition_commodity.attribute2_grid.getColIndexById("commodity_form_attribute1_id");
                        setup_definition_commodity.attribute2_grid.cells(newId, col_index).setValue(attribute1_id);
                        break;
                    case "delete" :
                        var del_ids = setup_definition_commodity.attribute2_grid.getSelectedRowId();
                        var values_id = setup_definition_commodity.attribute2_grid.cells(del_ids, 0).getValue();
                        var static_values_id = setup_definition_commodity.attribute2_grid.cells(del_ids, 1).getValue();
                        delete_form_attribute2_grid += '<GridRow  commodity_form_attribute2_id ="' + values_id + '" ></GridRow>';
                        setup_definition_commodity.attribute2_grid.deleteRow(del_ids);
                        setup_definition_commodity.attribute2_menu.setItemDisabled("delete");
                        setup_definition_commodity.refresh_attribute3_grid();
                        break;
                    case "excel":
                        setup_definition_commodity.attribute2_grid.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                        break;
                    case "pdf":
                        setup_definition_commodity.attribute2_grid.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                        break;
                    case "save_changes":
                        grid_xml = '<GridGroup>';
                        
                        if (delete_form_attribute2_grid != '') {
                            grid_xml += '<GridDelete grid_id="commodity_form_attribute2" grid_label="Attribute 2">' + delete_form_attribute2_grid + '</GridDelete>';
                        }

                        var ids = setup_definition_commodity.attribute2_grid.getChangedRows(true);
                        
                        if (ids != '') {
                            var changed_ids = new Array();
                            changed_ids = ids.split(",");
                            
                            grid_xml += '<Grid grid_id="commodity_form_attribute2">';
                            
                            $.each(changed_ids, function (index, value) {
                                grid_xml += "<GridRow ";
                                
                                setup_definition_commodity.attribute2_grid.forEachCell(value, function (cellObj, ind) {
                                    grid_index = setup_definition_commodity.attribute2_grid.getColumnId(ind);
                                    grid_value = cellObj.getValue(ind);
                                    grid_xml += " " + grid_index + '="' + grid_value + '"';
                                });
    
                                grid_xml += '></GridRow>';
                            });

                            grid_xml += '</Grid>';
                        }

                        grid_xml += '</GridGroup>';
                        
                        form_xml = '<Root function_id="10101112">';
                        xml = form_xml + grid_xml + '</Root>';
                        
                        data = {
                            "action": "spa_process_form_data", 
                            "xml": xml
                        };
                        
                        if (delete_form_attribute2_grid != '') {
                            del_msg = "Some data has been deleted from grid. Are you sure you want to save?";
                            result = adiha_post_data("confirm-warning", data, "", "", "setup_definition_commodity.refresh_attribute2_grid", "", del_msg);
                        } else {
                            result = adiha_post_data("alert", data, "", "", "setup_definition_commodity.refresh_attribute2_grid");
                        }
                        break;
                    case "copy":
                        var row_id  = setup_definition_commodity.attribute2_grid.getSelectedRowId();
                        var col_index = setup_definition_commodity.attribute2_grid.getColIndexById("commodity_form_attribute2_id");
                        var attribute2_id = setup_definition_commodity.attribute2_grid.cells(row_id, col_index).getValue();
                        
                        var xml = '<Root><FormXML commodity_origin_id="" commodity_form_id="" commodity_form_attribute1_id="" commodity_form_attribute2_id="' + attribute2_id + '" commodity_form_attribute3_id="" commodity_form_attribute4_id="" commodity_form_attribute5_id=""></FormXML></Root>';
                        copy(xml, "setup_definition_commodity.refresh_attribute2_grid");
                        break;
                }
            }
            
            setup_definition_commodity.attribute3_menu_click = function(id) {
                switch (id) {
                    case "add" :
                        var newId = (new Date()).valueOf();
                        setup_definition_commodity.attribute3_grid.addRow(newId, '', '');
                        var row_id  = setup_definition_commodity.attribute2_grid.getSelectedRowId();
                        var col_index = setup_definition_commodity.attribute2_grid.getColIndexById("commodity_form_attribute2_id");
                        var attribute2_id = setup_definition_commodity.attribute2_grid.cells(row_id, col_index).getValue();
                        var col_index = setup_definition_commodity.attribute3_grid.getColIndexById("commodity_form_attribute2_id");
                        setup_definition_commodity.attribute3_grid.cells(newId, col_index).setValue(attribute2_id);
                        break;
                    case "delete" :
                        var del_ids = setup_definition_commodity.attribute3_grid.getSelectedRowId();
                        var values_id = setup_definition_commodity.attribute3_grid.cells(del_ids, 0).getValue();
                        var static_values_id = setup_definition_commodity.attribute3_grid.cells(del_ids, 1).getValue();
                        delete_form_attribute3_grid += '<GridRow  commodity_form_attribute3_id ="' + values_id + '" ></GridRow>';
                        setup_definition_commodity.attribute3_grid.deleteRow(del_ids);
                        setup_definition_commodity.attribute3_menu.setItemDisabled("delete");
                        setup_definition_commodity.refresh_attribute4_grid();
                        break;
                    case "excel":
                        setup_definition_commodity.attribute3_grid.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                        break;
                    case "pdf":
                        setup_definition_commodity.attribute3_grid.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                        break;
                    case "save_changes":
                        grid_xml = '<GridGroup>';
                        
                        if (delete_form_attribute3_grid != '') {
                            grid_xml += '<GridDelete grid_id="commodity_form_attribute3" grid_label="Attribute 3">' + delete_form_attribute3_grid + '</GridDelete>';
                        }

                        var ids = setup_definition_commodity.attribute3_grid.getChangedRows(true);
                        
                        if (ids != '') {
                            var changed_ids = new Array();
                            changed_ids = ids.split(",");
                            
                            grid_xml += '<Grid grid_id="commodity_form_attribute3">';
                            
                            $.each(changed_ids, function (index, value) {
                                grid_xml += "<GridRow ";
                                
                                setup_definition_commodity.attribute3_grid.forEachCell(value, function (cellObj, ind) {
                                    grid_index = setup_definition_commodity.attribute3_grid.getColumnId(ind);
                                    grid_value = cellObj.getValue(ind);
                                    grid_xml += " " + grid_index + '="' + grid_value + '"';
                                });
    
                                grid_xml += '></GridRow>';
                            });

                            grid_xml += '</Grid>';
                        }

                        grid_xml += '</GridGroup>';
                        
                        form_xml = '<Root function_id="10101112">';
                        xml = form_xml + grid_xml + '</Root>';
                        
                        data = {
                            "action": "spa_process_form_data", 
                            "xml": xml
                        };
                        
                        if (delete_form_attribute3_grid != '') {
                            del_msg = "Some data has been deleted from grid. Are you sure you want to save?";
                            result = adiha_post_data("confirm-warning", data, "", "", "setup_definition_commodity.refresh_attribute3_grid", "", del_msg);
                        } else {
                            result = adiha_post_data("alert", data, "", "", "setup_definition_commodity.refresh_attribute3_grid");
                        }
                        break;
                    case "copy":
                        var row_id  = setup_definition_commodity.attribute3_grid.getSelectedRowId();
                        var col_index = setup_definition_commodity.attribute3_grid.getColIndexById("commodity_form_attribute3_id");
                        var attribute3_id = setup_definition_commodity.attribute3_grid.cells(row_id, col_index).getValue();
                        
                        var xml = '<Root><FormXML commodity_origin_id="" commodity_form_id="" commodity_form_attribute1_id="" commodity_form_attribute2_id="" commodity_form_attribute3_id="' + attribute3_id + '" commodity_form_attribute4_id="" commodity_form_attribute5_id=""></FormXML></Root>';
                        copy(xml, "setup_definition_commodity.refresh_attribute3_grid");
                        break;
                }
            }
            
            setup_definition_commodity.attribute4_menu_click = function(id) {
                switch (id) {
                    case "add" :
                        var newId = (new Date()).valueOf();
                        setup_definition_commodity.attribute4_grid.addRow(newId, '', '');
                        var row_id  = setup_definition_commodity.attribute3_grid.getSelectedRowId();
                        var col_index = setup_definition_commodity.attribute3_grid.getColIndexById("commodity_form_attribute3_id");
                        var attribute3_id = setup_definition_commodity.attribute3_grid.cells(row_id, col_index).getValue();
                        var col_index = setup_definition_commodity.attribute4_grid.getColIndexById("commodity_form_attribute3_id");
                        setup_definition_commodity.attribute4_grid.cells(newId, col_index).setValue(attribute3_id);
                        break;
                    case "delete" :
                        var del_ids = setup_definition_commodity.attribute4_grid.getSelectedRowId();
                        var values_id = setup_definition_commodity.attribute4_grid.cells(del_ids, 0).getValue();
                        var static_values_id = setup_definition_commodity.attribute4_grid.cells(del_ids, 1).getValue();
                        delete_form_attribute4_grid += '<GridRow  commodity_form_attribute4_id ="' + values_id + '" ></GridRow>';
                        setup_definition_commodity.attribute4_grid.deleteRow(del_ids);
                        setup_definition_commodity.attribute4_menu.setItemDisabled("delete");
                        setup_definition_commodity.refresh_attribute5_grid();
                        break;
                    case "excel":
                        setup_definition_commodity.attribute4_grid.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                        break;
                    case "pdf":
                        setup_definition_commodity.attribute4_grid.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                        break;
                    case "save_changes":
                        grid_xml = '<GridGroup>';
                       
                        if (delete_form_attribute4_grid != '') {
                            grid_xml += '<GridDelete grid_id="commodity_form_attribute4" grid_label="Attribute 4">' + delete_form_attribute4_grid + '</GridDelete>';
                        }

                        var ids = setup_definition_commodity.attribute4_grid.getChangedRows(true);
                        
                        if (ids != '') {
                            var changed_ids = new Array();
                            changed_ids = ids.split(",");
                            
                            grid_xml += '<Grid grid_id="commodity_form_attribute4">';
                            
                            $.each(changed_ids, function (index, value) {
                                grid_xml += "<GridRow ";
                                
                                setup_definition_commodity.attribute4_grid.forEachCell(value, function (cellObj, ind) {
                                    grid_index = setup_definition_commodity.attribute4_grid.getColumnId(ind);
                                    grid_value = cellObj.getValue(ind);
                                    grid_xml += " " + grid_index + '="' + grid_value + '"';
                                });
    
                                grid_xml += '></GridRow>';
                            });

                            grid_xml += '</Grid>';
                        }

                        grid_xml += '</GridGroup>';
                        
                        form_xml = '<Root function_id="10101112">';
                        xml = form_xml + grid_xml + '</Root>';
                        data = {"action": "spa_process_form_data", "xml": xml};
                        
                        if (delete_form_attribute4_grid != '') {
                            del_msg = "Some data has been deleted from grid. Are you sure you want to save?";
                            result = adiha_post_data("confirm-warning", data, "", "", "setup_definition_commodity.refresh_attribute4_grid", "", del_msg);
                        } else {
                            result = adiha_post_data("alert", data, "", "", "setup_definition_commodity.refresh_attribute4_grid");
                        }
                        break;
                    case "copy":
                        var row_id  = setup_definition_commodity.attribute4_grid.getSelectedRowId();
                        var col_index = setup_definition_commodity.attribute4_grid.getColIndexById("commodity_form_attribute4_id");
                        var attribute4_id = setup_definition_commodity.attribute4_grid.cells(row_id, col_index).getValue();
                        
                        var xml = '<Root><FormXML commodity_origin_id="" commodity_form_id="" commodity_form_attribute1_id="" commodity_form_attribute2_id="" commodity_form_attribute3_id="" commodity_form_attribute4_id="' + attribute4_id + '" commodity_form_attribute5_id=""></FormXML></Root>';
                        copy(xml, "setup_definition_commodity.refresh_attribute4_grid");
                        break;
                }
            }
            
            setup_definition_commodity.attribute5_menu_click = function(id) {
                switch (id) {
                    case "add" :
                        var newId = (new Date()).valueOf();
                        setup_definition_commodity.attribute5_grid.addRow(newId, '', '');
                        var row_id  = setup_definition_commodity.attribute4_grid.getSelectedRowId();
                        var col_index = setup_definition_commodity.attribute4_grid.getColIndexById("commodity_form_attribute4_id");
                        var attribute4_id = setup_definition_commodity.attribute4_grid.cells(row_id, col_index).getValue();
                        var col_index = setup_definition_commodity.attribute5_grid.getColIndexById("commodity_form_attribute4_id");
                        setup_definition_commodity.attribute5_grid.cells(newId, col_index).setValue(attribute4_id);
                        break;
                    case "delete" :
                        var del_ids = setup_definition_commodity.attribute5_grid.getSelectedRowId();
                        var values_id = setup_definition_commodity.attribute5_grid.cells(del_ids, 0).getValue();
                        
                        delete_form_attribute5_grid += '<GridRow  commodity_form_attribute5_id ="' + values_id + '" ></GridRow>';
                        setup_definition_commodity.attribute5_grid.deleteRow(del_ids);
                        setup_definition_commodity.attribute5_menu.setItemDisabled("delete");
                        break;
                    case "excel":
                        setup_definition_commodity.attribute5_grid.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                        break;
                    case "pdf":
                        setup_definition_commodity.attribute5_grid.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                        break;
                    case "save_changes":
                        grid_xml = '<GridGroup>';
                        
                        if (delete_form_attribute5_grid != '') {
                            grid_xml += '<GridDelete grid_id="commodity_form_attribute5" grid_label="Attribute 5">' + delete_form_attribute5_grid + '</GridDelete>';
                        }

                        var ids = setup_definition_commodity.attribute5_grid.getChangedRows(true);
                        
                        if (ids != '') {
                            var changed_ids = new Array();
                            changed_ids = ids.split(",");
                            
                            grid_xml += '<Grid grid_id="commodity_form_attribute5">';
                            
                            $.each(changed_ids, function (index, value) {
                                grid_xml += "<GridRow ";

                                setup_definition_commodity.attribute5_grid.forEachCell(value, function (cellObj, ind) {
                                    grid_index = setup_definition_commodity.attribute5_grid.getColumnId(ind);
                                    grid_value = cellObj.getValue(ind);
                                    grid_xml += " " + grid_index + '="' + grid_value + '"';
                                });
    
                                grid_xml += '></GridRow>';
                            });

                            grid_xml += '</Grid>';
                        }

                        grid_xml += '</GridGroup>';
                        
                        form_xml = '<Root function_id="10101112">';
                        xml = form_xml + grid_xml + '</Root>';
                        data = {"action": "spa_process_form_data", "xml": xml};
                        
                        if (delete_form_attribute5_grid != '') {
                            del_msg = "Some data has been deleted from grid. Are you sure you want to save?";
                            result = adiha_post_data("confirm-warning", data, "", "", "setup_definition_commodity.refresh_attribute5_grid", "", del_msg);
                        } else {
                            result = adiha_post_data("alert", data, "", "", "setup_definition_commodity.refresh_attribute5_grid");
                        }

                        break;
                    case "copy":
                        var row_id  = setup_definition_commodity.attribute5_grid.getSelectedRowId();
                        var col_index = setup_definition_commodity.attribute5_grid.getColIndexById("commodity_form_attribute5_id");
                        var attribute5_id = setup_definition_commodity.attribute5_grid.cells(row_id, col_index).getValue();
                        
                        var xml = '<Root><FormXML commodity_origin_id="" commodity_form_id="" commodity_form_attribute1_id="" commodity_form_attribute2_id="" commodity_form_attribute3_id="" commodity_form_attribute4_id="" commodity_form_attribute5_id="' + attribute5_id + '"></FormXML></Root>';
                        copy(xml, "setup_definition_commodity.refresh_attribute5_grid");
                        break;
                }
            }
            
            setup_definition_commodity.attribute_cell_change = function(stage, rid, cid, n_val, o_val) {
                if (cid == setup_definition_commodity.attribute1_grid.getColIndexById("attribute_id") && stage == 2) {
                    if (isNaN(n_val) || n_val == '') {
                        return false;
                    } else if (n_val != o_val) {
                        load_attribute(setup_definition_commodity.attribute1_grid, rid, n_val);
                    }
                }
                
                return true;
            }
            
            setup_definition_commodity.attribute2_cell_change = function(stage, rid, cid, n_val, o_val) {
                if (cid == setup_definition_commodity.attribute2_grid.getColIndexById("attribute_id") && stage == 2) {
                    if (isNaN(n_val) || n_val == '') {
                        return false;
                    } else if (n_val != o_val) {
                        load_attribute(setup_definition_commodity.attribute2_grid, rid, n_val);
                    }
                }
                
                return true;
            }
            
            setup_definition_commodity.attribute3_cell_change = function(stage, rid, cid, n_val, o_val) {
                if (cid == setup_definition_commodity.attribute3_grid.getColIndexById("attribute_id") && stage == 2) {
                    if (isNaN(n_val) || n_val == '') {
                        return false;
                    } else if (n_val != o_val) {
                        load_attribute(setup_definition_commodity.attribute3_grid, rid, n_val);
                    }
                }
                
                return true;
            }
            
            setup_definition_commodity.attribute4_cell_change = function(stage, rid, cid, n_val, o_val) {
                if (cid == setup_definition_commodity.attribute4_grid.getColIndexById("attribute_id") && stage == 2) {
                    if (isNaN(n_val) || n_val == '') {
                        return false;
                    } else if (n_val != o_val) {
                        load_attribute(setup_definition_commodity.attribute4_grid, rid, n_val);
                    }
                }
                
                return true;
            }
            
            setup_definition_commodity.attribute5_cell_change = function(stage, rid, cid, n_val, o_val) {
                if (cid == setup_definition_commodity.attribute5_grid.getColIndexById("attribute_id") && stage == 2) {
                    if (isNaN(n_val) || n_val == '') {
                        return false;
                    } else if (n_val != o_val) {
                        load_attribute(setup_definition_commodity.attribute5_grid, rid, n_val);
                    }
                }
                
                return true;
            }
            
            setup_definition_commodity.reload_dropdown = function(grid_obj, count) {
                grid_obj.forEachRow(function(id){
                    load_attribute(grid_obj, id, grid_obj.cells(id, grid_obj.getColIndexById('attribute_id')).getValue());
                });
            }
            
            function load_attribute(grid_obj, rId, nValue) {
                var cm_param = {
                    "action": "[spa_generic_mapping_header]", 
                    "flag": "n",
                    "combo_sql_stmt": "SELECT commodity_attribute_form_id, sdv.code " 
                        + "FROM commodity_attribute_form caf INNER JOIN static_data_value sdv ON caf.commodity_attribute_value = sdv.value_id " 
                        + "WHERE commodity_attribute_id = " + nValue,
                    "call_from": "grid"
                };

                cm_param = $.param(cm_param);
                var url = js_dropdown_connector_url + '&' + cm_param;
                var col_index = grid_obj.getColIndexById("attribute_form_id");
                var combo_obj = grid_obj.cells(rId, col_index).getCellCombo();
                combo_obj.enableFilteringMode("between", null, false);
                
                combo_obj.load(url, function() {
                    var type_id = grid_obj.cells(rId, col_index).getValue();
                    
                    var is_exist = combo_obj.getIndexByValue(type_id);
                    
                    if (is_exist != -1) {
                        grid_obj.cells(rId, col_index).setValue(type_id);
                    } else {
                        grid_obj.cells(rId, col_index).setValue('');
                    }
                });
            }
            
            /**
             * [undock_window Function for undocking grid]
             */
            function undock_window(cell_id) {
                setup_definition_commodity.accordion1.cells(cell_id).undock(300, 300, 900, 700);
                setup_definition_commodity.accordion1.dhxWins.window(cell_id).maximize();
                setup_definition_commodity.accordion1.dhxWins.window(cell_id).button("park").hide();
            }
            
            function undock_window2(cell_id) {
                setup_definition_commodity.accordion2.cells(cell_id).undock(300, 300, 900, 700);
                setup_definition_commodity.accordion2.dhxWins.window(cell_id).maximize();
                setup_definition_commodity.accordion2.dhxWins.window(cell_id).button("park").hide();
            }

            function undock_window3(cell_id) {
                setup_definition_commodity.accordion3.cells(cell_id).undock(300, 300, 900, 700);
                setup_definition_commodity.accordion3.dhxWins.window(cell_id).maximize();
                setup_definition_commodity.accordion3.dhxWins.window(cell_id).button("park").hide();
            }
            
            function load_form_dropdown() {
                var commodity_type_id = setup_definition_commodity.setup_definition_commodity.getItemValue('commodity_type');
                var col_index = setup_definition_commodity.commodity_form_grid.getColIndexById("form");
                
                var cm_param = {
                    "action": "[spa_generic_mapping_header]", 
                    "flag": "n",
                    "combo_sql_stmt": "SELECT commodity_type_form_id, sdv.code" 
                        + " FROM commodity_type_form ctf  LEFT JOIN static_data_value sdv ON sdv.value_id = ctf.commodity_form_value" 
                        + " WHERE ctf.commodity_type_id = " + commodity_type_id,
                    "call_from": "grid"
                };
        
                cm_param = $.param(cm_param);
                var url = js_dropdown_connector_url + '&' + cm_param;
                var combo_obj = setup_definition_commodity.commodity_form_grid.getColumnCombo(col_index);                
                combo_obj.enableFilteringMode("between", null, false);
                combo_obj.load(url);
            }
            
            function copy(xml, callback_function) {
                data = {
                    "action": "spa_commodity_grade", 
                    "xml": xml, 
                    "flag": "v"
                };

                adiha_post_data("alert", data, "", "", callback_function);   
            }
            
            function grid_load_callback() {
                setup_definition_commodity.commodity_origin_grid.selectRowById(0);
            }
        </script>
    </body>
</html>