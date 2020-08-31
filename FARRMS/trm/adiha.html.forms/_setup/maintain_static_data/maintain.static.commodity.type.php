<?php
/**
* Maintain static commodity type screen
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
        $layout = new AdihaLayout();
        $form_obj = new AdihaForm();
        $layout_name = 'commodity_type_layout';

		$rights_static_data_iu = 10101010;
		$rights_static_data_delete = 10101011;
		$rights_static_data_privilege = 10101020;
		
		list (
			$has_rights_static_data_iu,
			$has_rights_static_data_delete,
			$has_rights_static_data_privilege
		) = build_security_rights(
			$rights_static_data_iu, 
			$rights_static_data_delete,
			$rights_static_data_privilege
		);

		
        if (isset($_POST['value_id'])) {
            $value_id = get_sanitized_value($_POST['value_id']);
            echo $xml = '<Root><PSRecordset commodity_type_id="' . $value_id . '"></PSRecordset></Root>';
        } else {
            $value_id = "null";
            $xml = '<Root><PSRecordset commodity_type_id=""></PSRecordset></Root>';
        }

        $layout_json = '[
                    {
                        id:             "a",
                        text:           "Commodity Type",
                        width:          720,
                        height:         160,
                        header:         false,
                        collapse:       false,
                        fix_size:       [true,true]
                    },

                ]';

        $name_space = 'commodity_type';
        echo $layout->init_layout($layout_name, '', '1C', $layout_json, $name_space);

        $toolbar_name = 'commodity_type_toolbar';
        echo $layout->attach_toolbar_cell($toolbar_name, 'a');

        $toolbar_obj = new AdihaToolbar();
        echo $toolbar_obj->init_by_attach($toolbar_name, $name_space);

        echo $toolbar_obj->load_toolbar('[{id: "save", type: "button", text:"Save", img: "save.gif", imgdis:"save_dis.gif", title:"Save", action: "holiday_calendar",  enabled: "'.$has_rights_static_data_iu.'" }]');
        //Start of Tabs
        $tab_name = 'commodity_type_tabs';

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
                    text:    "Forms",
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

        $xml_file = "EXEC spa_create_application_ui_json 'j', 10101070, 'commodity_type', '$xml' ";
        $return_value1 = readXMLURL($xml_file);

        $form_structure_general = $return_value1[0][2];

        //$general_form_checkbox = '{type: "block", blockOffset: 18,  list: [ { type: "checkbox", label: "View detail", position:"label-right", name:"view_detail_chk", id:"view_detail_chk"},{"type":"newcolumn"},{type: "checkbox", label: "Quality", position:"label-right" ,id:"quality_chk",name:"quality_chk", disabled:   true}] }';
        //$form_structure_general = substr($form_structure_general, 0, -21) . $general_form_checkbox . "]";
        //echo $form_structure_general;
        $form_name = 'commodity_type';
        echo $tab_obj->attach_form($form_name, 'a1', $form_structure_general, $name_space);
        //Grid 
        $grid_name = 'commodity_type_quality_grd';
        //echo $tab_obj->attach_grid($grid_name, 'a2');
        echo 'commodity_type.commodity_type_quality_grd = commodity_type.commodity_type_tabs.tabs("a2").attachGrid();';


        $grid_quality_obj = new GridTable('commodity_type_form');
        echo $grid_quality_obj->init_grid_table($grid_name, $name_space);
        echo $grid_quality_obj->set_widths('0,130,130,130');
        echo $grid_quality_obj->set_search_filter(true);
        //echo $grid_quality_obj->enable_paging('25', 'pagingArea_a', true);

        echo $grid_quality_obj->return_init();
        $grid_spa = "EXEC spa_commodity_type_form @flag = 's', @commodity_type_id = '" . $value_id . "'";
        echo $grid_quality_obj->load_grid_data($sp_grid = $grid_spa);
        echo $grid_quality_obj->load_grid_functions();

        echo $layout->close_layout();
        ?>

        <style type="text/css">
            body,html{
                margin:-25px !important;
                padding:0px;
            }
            .dhxform_label_nav_link{
                margin-right: 10px;
            }
            .dhxtabbar_base_dhx_web div.dhx_cell_tabbar div.dhx_cell_cont_tabbar{
                padding:0px;
            }
        </style>

        <script type="text/javascript">
			var has_rights_static_data_iu = '<?php echo (($has_rights_static_data_iu) ? $has_rights_static_data_iu : '0'); ?>';
			var has_rights_static_data_delete = '<?php echo (($has_rights_static_data_delete) ? $has_rights_static_data_delete : '0'); ?>';
		
            $(function () {
                var value_id = '<?php echo $value_id; ?>';
                var delete_grid = '';
                var check_box_json;
                var commodity_type_quality_changed_cell_arr = [];
                var php_script_loc_ajax = "<?php echo $app_php_script_loc; ?>";
				
				
				
                grid_toolbar = commodity_type.commodity_type_tabs.tabs("a2").attachMenu();
                grid_toolbar.setIconsPath(js_image_path + "dhxtoolbar_web/");
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
                            commodity_type.commodity_type_quality_grd.addRow(newId, '', '');
                            commodity_type.commodity_type_quality_grd.cells(newId, 6).setValue(value_id);
                            break;
                        case "delete" :
                            var del_ids = commodity_type.commodity_type_quality_grd.getSelectedRowId();
                            var values_id = commodity_type.commodity_type_quality_grd.cells(del_ids, 0).getValue();
                            var static_values_id = commodity_type.commodity_type_quality_grd.cells(del_ids, 1).getValue();
                            delete_grid += '<GridRow  commodity_type_form_id ="' + values_id + '" ></GridRow>';
                            commodity_type.commodity_type_quality_grd.deleteRow(del_ids);
                            grid_toolbar.setItemDisabled("delete");
                            break;
                        case "excel":
                            commodity_type.commodity_type_quality_grd.toExcel(php_script_loc_ajax + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                            break;
                        case "pdf":
                            commodity_type.commodity_type_quality_grd.toPDF(php_script_loc_ajax + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                            break;
                    }
                });

                // Event after clicking in the
                commodity_type.commodity_type_toolbar.attachEvent('onClick', function (id) {

                    if (id == 'save') {
                        generalForm = commodity_type.commodity_type.getForm();
                        var status = validate_form(generalForm);

                        if (status === false) {
                            return;
                        } else {

                            var form_xml;
                            var grid_xml = '';
                            var grid_index;
                            var grid_value;
                            var xml;
                            var validate_chk1 = 0;

                            var source_commodity_type_id = value_id;
                            var data_type = generalForm.getItemValue('data_type');
                            data_type = (data_type == '') ? 4070 : data_type;
                            var commodity_name = generalForm.getItemValue('commodity_name');
                            var commodity_description = generalForm.getItemValue('commodity_description');
                            commodity_description = (commodity_description == '') ? commodity_name : commodity_description;
                            
                            form_xml = '<Root function_id="10101070" object_id="' + source_commodity_type_id + '" ><FormXML commodity_type_id = "' + source_commodity_type_id + '" data_type = "' + data_type + '" commodity_name = "' + commodity_name + '" commodity_description = "' + commodity_description + '" ></FormXML>';
                            grid_xml += commodity_type.get_changed_data_grid();
                            xml = form_xml + grid_xml + '</Root>';

                            data = {"action": "spa_process_form_data", "xml": xml};
                            var count = commodity_type.commodity_type_quality_grd.getRowsNum();
                            
                            if (delete_grid != '') {
                                del_msg = "Some data has been deleted from grid. Are you sure you want to save?";
                                result = adiha_post_data("confirm-warning", data, "", "", "commodity_type.call_back", "", del_msg);
                            } else {
                                result = adiha_post_data("alert", data, "", "", "commodity_type.call_back");
                            }
                        }
                    }
                });

                commodity_type.commodity_type_quality_grd.attachEvent("onEditCell", function (stage, rId, cInd, nValue, oValue) {

                    if (stage == 2) {
                        if (nValue != oValue && cInd >= 0) {
                            commodity_type_quality_changed_cell_arr.push(rId);
                            if (cInd == 1) {
                                commodity_type.get_quality_type(nValue, rId);
                            }
                        }
                    }
                    commodity_type_quality_changed_cell_arr = commodity_type_quality_changed_cell_arr.filter(function (elem, pos) {
                        return commodity_type_quality_changed_cell_arr.indexOf(elem) == pos;
                    });
                    return true;
                });

                commodity_type.get_changed_data_grid = function () {
                    var i = 0;
                    var grid_xml = '';
                    var store_name = '';
                    
                    grid_xml += '<GridGroup>';
                    if (delete_grid != '') {
                        grid_xml += '<GridDelete grid_id="commodity_type_form" grid_label="commodity_type_form">' + delete_grid + '</GridDelete>';
                    }

                    if (commodity_type_quality_changed_cell_arr.length > 0) {
                        grid_xml += '<Grid grid_id="commodity_type_form">';
                        $.each(commodity_type_quality_changed_cell_arr, function (index, value) {
                            grid_xml += "<GridRow ";
                            commodity_type.commodity_type_quality_grd.forEachCell(value, function (cellObj, ind) {
                                grid_index = commodity_type.commodity_type_quality_grd.getColumnId(ind);
                                grid_value = cellObj.getValue(ind);

                                if (grid_index == 'commodity_form_name') {
                                   store_name = grid_value;
                                }

                                if (grid_index == 'commodity_form_description') {
                                    if (grid_value == '') {
                                        grid_value = store_name;
                                    }
                                }

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

                commodity_type.call_back = function (result) {
                    if (result[0].errorcode == "Success") {
                        var new_id = result[0].recommendation;
                        if (result[0].recommendation == '') {
                            new_id = '<?php echo $value_id; ?>';
                        }
                        
                        generalForm.setItemValue('value_id', new_id);
                        var code = generalForm.getItemValue('commodity_name');                        
                        delete_grid = "";
                        commodity_type_quality_changed_cell_arr = [];
                        parent.setup_static_data.special_menu_case(result, code, 'commodity_type');
                    }
                }

                commodity_type.commodity_type_quality_grd.attachEvent("onRowSelect", doOnRowSelected);
                function doOnRowSelected(id) {
                    grid_toolbar.setItemEnabled("delete");
				if(has_rights_static_data_iu == 0) {
						grid_toolbar.setItemDisabled("delete");
				}
				
					

                }
                function refresh_grid(id) {
                    //var sql_param = "EXEC spa_get_holiday_calendar @flag ='g', @value_id = " + id;
                    var sql_param = {
                        "sql": "EXEC spa_commodity_type_form @flag = 's', @commodity_type_id = '" + value_id + "'"
                    };
                    sql_param = $.param(sql_param);
                    var sql_url = js_data_collector_url + "&" + sql_param;
                    commodity_type.commodity_type_quality_grd.clearAll();
                    commodity_type.commodity_type_quality_grd.load(sql_url);
                    var count = commodity_type.commodity_type_quality_grd.getRowsNum();
                    if (count > 0) {
                        commodity_type.commodity_type_quality_grd.forEachRow(function (id) {
                            // Looping for cell
                            commodity_type.commodity_type_quality_grd.forEachCell(id, function (cellObj, ind) {
                                grid_index = commodity_type.commodity_type_quality_grd.getColumnId(ind);
                                if (grid_index == 'range') {
                                    range = cellObj.getValue(ind);
                                }
                            });

                        });
                    }

                }

                function validate_grid() {
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
                    
                    commodity_type.commodity_type_quality_grd.forEachRow(function (id) {
                        // Looping for cell
                        commodity_type.commodity_type_quality_grd.forEachCell(id, function (cellObj, ind) {
                            from_col_validation = 0;
                            to_col_validation = 0;
                            grid_index = commodity_type.commodity_type_quality_grd.getColumnId(ind);
                            
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

                       //alert(from_col_validation);
                       /*
                        if (range == 'Range' && (parseInt(temp_to_value) < parseInt(temp_from_value))) {
                            error = 1;
                            //break;
                        } else if (temp_from_value == "" && temp_to_value == "") {
                            error_col = 1;
                            //break;
                        } else if (quality == "") {
                            error = 3;
                            //break;
                        }
                        */
                        if (temp_from_value == "" && temp_to_value == "") {
                            error_col = 1;
                            //break;
                        } 
                        
                        if (quality == "") {
                            error = 3;
                            //break;
                        }
                    });
                    if (error == 3) {
                        show_messagebox("Data Error in <b>Quality</b> grid. Please check the data in column <b>Quality</b> and resave.");
                        return;
                    } else if (error_col == 1 && error != 3) {
                        show_messagebox("Data error in Quality tab Please check the data in column <b> Form value </b> or <b> To value </b> and resave");
                        return;
                    }
                    else {
                        return 1;
                    }


                }



            });


        </script>

