<?php
/**
* Compliance jurisdiction requirement detail screen
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

<body>
    <?php
            $flag = get_sanitized_value($_GET['flag'] ?? '');
            $state_value_id = get_sanitized_value($_GET['state_value_id'] ?? '');
            $state_rec_requirement_data_id = get_sanitized_value($_GET['state_rec_requirement_data_id'] ?? '');
            $state_rec_requirement_detail_id = get_sanitized_value($_GET['state_rec_requirement_detail_id'] ?? '');

            $function_id = 14100106;
            $name_space = 'requirement_detail';

            $rights_requirement_detail_iu = 14100107;
            $rights_requirement_detail_delete = 14100108;

    list(
                $has_rights_requirement_detail_iu,
                $has_rights_requirement_detail_delete
    ) = build_security_rights(
                $rights_requirement_detail_iu,
                $rights_requirement_detail_delete
            );

            $layout = new AdihaLayout();
    $layout_name = 'compliance_jurisdiction_requirement_detail';
            $layout_json = '[
                                {
                                    id:             "a",
                                    text:           "Requirement Detail",
                                    header:         false,
                                    collapse:       false,
                                    fix_size:       [true,true]
                                },
                                {
                                    id:             "b",
                                    text:           "Tier",
                                    header:         false,
                                    collapse:       false
                                }

                            ]';

            echo $layout->init_layout($layout_name, '', '2E', $layout_json, $name_space);

            $toolbar_obj = new AdihaToolbar();
            $toolbar_json = '[{ id: "save", type: "button", img: "save.gif", imgdis: "save_dis.gif", text:"Save", title: "Save"}]';
            echo $layout->attach_toolbar_cell("toolbar", "a");
            echo $toolbar_obj->init_by_attach("toolbar", $name_space);
            echo $toolbar_obj->load_toolbar($toolbar_json);
            echo $toolbar_obj->attach_event('', 'onClick', 'save_onclick');

            $form_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='" . $function_id . "', @template_name='requirement_detail', @group_name='General', @parse_xml = '<Root><PSRecordSet state_rec_requirement_detail_id=\"" . $state_rec_requirement_detail_id . "\"></PSRecordSet></Root>'";
            $form_arr = readXMLURL2($form_sql);
            $form_json = $form_arr[0]['form_json'];

            $form_obj = new AdihaForm();
            $form_name = 'form_requirement_detail';
            echo $layout->attach_form($form_name, 'a');
            $form_obj->init_by_attach($form_name, $name_space);
    echo $form_obj->load_form($form_json);
            echo $form_obj->attach_event('', 'onChange', 'item_changed');

            $menu_toolbar_name = 'menu_grid_requirement_detail';
            $menu_json =    '[  
                                {id:"Edit", img:"edit.gif", text:"Edit", offsetLeft: 20, items:[
                                    {id:"add", img:"add.gif", imgdis:"add_dis.gif", title:"Add", enabled:0},
                                    {id:"delete", img:"delete.gif", imgdis:"delete_dis.gif", title:"Delete", enabled:0}
                                ]},
                                {id:"export", text:"Export", img:"export.gif", items:[
                                    {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel", enabled:0},
                                    {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF", enabled:0}
                                ]}
                            ]';

            $menu_obj = new AdihaMenu();
    echo $layout->attach_menu_cell($menu_toolbar_name, "b");
            echo $menu_obj->init_by_attach($menu_toolbar_name, $name_space);
    echo $menu_obj->load_menu($menu_json);
            echo $menu_obj->attach_event('', 'onClick', 'grid_menu_onclick');

            $grid_sql = "EXEC spa_adiha_grid 's','requirement_constraint'";
            $grid_xml = readXMLURL2($grid_sql);

            $grid_name = 'grid_requirement_detail';
            $grid_obj = new AdihaGrid();
            echo $layout->attach_grid_cell($grid_name, 'b');
            echo $grid_obj->init_by_attach($grid_name, $name_space);
            echo $grid_obj->set_header($grid_xml[0]['column_label_list']);
            echo $grid_obj->set_columns_ids($grid_xml[0]['column_name_list']);
            echo $grid_obj->set_widths($grid_xml[0]['column_width']);
            echo $grid_obj->set_column_types($grid_xml[0]['column_type_list']);
            echo $grid_obj->set_sorting_preference($grid_xml[0]['sorting_preference']);
            echo $grid_obj->set_column_visibility($grid_xml[0]['set_visibility']);
            echo $grid_obj->enable_multi_select(false);
            echo $grid_obj->set_search_filter(true);
            echo $grid_obj->return_init();
    echo $grid_obj->attach_event('', 'onRowSelect', 'grid_row_onSelect');

            echo $layout->close_layout();
        ?>
</body>
<script type="text/javascript">
        var dhxWins = new dhtmlXWindows();
        var flag = "<?php echo $flag; ?>";
        var state_value_id = "<?php echo $state_value_id; ?>";
        var state_rec_requirement_data_id = "<?php echo $state_rec_requirement_data_id; ?>";
        var state_rec_requirement_detail_id = "<?php echo $state_rec_requirement_detail_id; ?>";
        var delete_grid = "";

        $(function() {
            var requirement_type_value = requirement_detail.form_requirement_detail.getItemValue('requirement_type_id');
            var sub_tier_type_combo = requirement_detail.form_requirement_detail.getCombo('sub_tier_value_id');
            var tier_type_combo = requirement_detail.form_requirement_detail.getCombo('tier_type');

            if (requirement_type_value == 23401)  { //Constraint
            requirement_detail.form_requirement_detail.setRequired('sub_tier_value_id', true);
            sub_tier_type_combo.deleteOption('');
            } else if (requirement_type_value == 23400) { //Assignment 
            requirement_detail.form_requirement_detail.setRequired('tier_type', true);
            tier_type_combo.deleteOption('');
            }

            var cm_param = {
            "action": "spa_state_rec_requirement_detail",
                            "flag": "y"
                        };

            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;
        var combo_obj = requirement_detail.grid_requirement_detail.getColumnCombo(1);
        combo_obj.enableFilteringMode(true);
            combo_obj.load(url);

            var cm_param2 = {
            "action": "spa_StaticDataValues",
                            "flag": "h",
                            "type_id": "101800"
                        };

            cm_param2 = $.param(cm_param2);
            var url2 = js_dropdown_connector_url + '&' + cm_param2;
        var combo_obj = requirement_detail.grid_requirement_detail.getColumnCombo(2);
        combo_obj.enableFilteringMode(true);
            combo_obj.load(url2);

            if (flag == 'u') {
                requirement_detail.menu_grid_requirement_detail.setItemEnabled('add');
                requirement_detail.menu_grid_requirement_detail.setItemEnabled('excel');
                requirement_detail.menu_grid_requirement_detail.setItemEnabled('pdf');

                load_grid_data();
            }
        });

        function grid_row_onSelect() {
            requirement_detail.menu_grid_requirement_detail.setItemEnabled('delete');
        }

        function load_grid_data() {
            var sql = {
            "action": "spa_state_rec_requirement_detail",
            "flag": "o",
            "state_rec_requirement_detail_id": state_rec_requirement_detail_id
            };
            var data = $.param(sql);
        var data_url = js_data_collector_url + "&" + data;
            requirement_detail.grid_requirement_detail.clearAndLoad(data_url);
        }

    function grid_menu_onclick(id) {
        switch (id) {
            case 'add':
                    var newId = (new Date()).valueOf();
                    requirement_detail.grid_requirement_detail.addRow(newId, '');
                break;
            case 'delete':
                    var selected_row = requirement_detail.grid_requirement_detail.getSelectedRowId();
                    selected_row = selected_row.split(',');

                    if (selected_row.length > 0) {
                        $.each(selected_row, function(key, value) {
                            var id = requirement_detail.grid_requirement_detail.cells(key, 0).getValue();
                            delete_grid += '<GridDelete  state_rec_requirement_detail_constraint_id ="' + id + '" ></GridDelete>';
                        });
                    }

                    requirement_detail.grid_requirement_detail.deleteSelectedRows();
                break;
            case 'excel':
                    var path = js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php';
                    requirement_detail.grid_requirement_detail.toExcel(path);
                break;
            case 'pdf':
                    var path = js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php';
                    requirement_detail.grid_requirement_detail.toPDF(path);
                break;
            }
        }

        function save_onclick() {
            var form_data = requirement_detail.form_requirement_detail.getFormData();
        var status = validate_form(requirement_detail.form_requirement_detail);

            if (!status) {
                generate_error_message();
                return;
            }

			for (a in form_data) {
            if (a == 'min_absolute_target') {
                var data_min_absolute_target = requirement_detail.form_requirement_detail.getItemValue(a, true);
				var data_min_absolute_target_verify = isNaN(data_min_absolute_target);
            }
            if (a == 'min_target') {
                var data_min_target = requirement_detail.form_requirement_detail.getItemValue(a, true);
				var data_min_target_verify = isNaN(data_min_target);
				}
            if (a == 'max_absolute_target') {
                var data_max_absolute_target = requirement_detail.form_requirement_detail.getItemValue(a, true);
				var data_max_absolute_target_verify = isNaN(data_max_absolute_target);
				}
            if (a == 'max_target') {
                var data_max_target = requirement_detail.form_requirement_detail.getItemValue(a, true);
				var data_max_target_verify = isNaN(data_max_target);
				}

            if (data_min_absolute_target_verify == true) {
                requirement_detail.form_requirement_detail.setNote('min_absolute_target', {
                    text: 'Invalid Number',
                    width: 200
                });
				}
            if (data_min_target_verify == true) {
                requirement_detail.form_requirement_detail.setNote('min_target', {
                    text: 'Invalid Number',
                    width: 200
                });
				}
            if (data_max_absolute_target_verify == true) {
                requirement_detail.form_requirement_detail.setNote('max_absolute_target', {
                    text: 'Invalid Number',
                    width: 200
                });
				}
            if (data_max_target_verify == true) {
                requirement_detail.form_requirement_detail.setNote('max_target', {
                    text: 'Invalid Number',
                    width: 200
                });
				}

            if (data_min_absolute_target_verify == true || data_min_target_verify == true || data_max_absolute_target_verify == true || data_max_target_verify == true) {
				 Break;
			}
        }

        var form_xml = '<Root><PSRecordset state_rec_requirement_detail_id = "' + state_rec_requirement_detail_id + '" state_value_id = "' + state_value_id + '" compliance_year = "9999" tier_type = "' + form_data["tier_type"] + '" sub_tier_value_id = "' + form_data["sub_tier_value_id"] + '"  min_target = "' + form_data["min_target"] + '" min_absolute_target = "' + form_data["min_absolute_target"] + '" max_target = "' + form_data["max_target"] + '" max_absolute_target = "' + form_data["max_absolute_target"] + '" requirement_type_id = "' + form_data["requirement_type_id"] + '" state_rec_requirement_data_id = "' + state_rec_requirement_data_id + '"></PSRecordset></Root>';

            var grid_xml = '<GridGroup><Grid grid_id = "requirement_constraint">';
            grid_xml += delete_grid;

            requirement_detail.grid_requirement_detail.forEachRow(function(id) {
                grid_xml += "<GridRow ";
                requirement_detail.grid_requirement_detail.forEachCell(id, function(cellObj, ind) {
                    grid_index = requirement_detail.grid_requirement_detail.getColumnId(ind);
                    grid_value = cellObj.getValue(ind);
                    grid_xml += " " + grid_index + '="' + grid_value + '"';
                });
            grid_xml = grid_xml + ' state_rec_requirement_detail_id ="' + state_rec_requirement_detail_id + '"';
                grid_xml += '></GridRow>';
            });
            grid_xml += '</Grid></GridGroup>';

            var data = {
            "action": "spa_state_rec_requirement_detail",
            "flag": flag,
            "form_xml": form_xml,
            "grid_xml": grid_xml
            };

            if (delete_grid != "") {
                dhtmlx.message({
                    type: "confirm-warning",
                    title: "Warning",
                    ok: "Confirm",
                    text: "Some data has been deleted from grid. Are you sure you want to save?",
                callback: function(result) {
                        if (result) {
                            result = adiha_post_data("return_json", data, "", "", "save_callback");
                            delete_grid = '';
                        }
                    }
                });
            } else {
                adiha_post_data("return_json", data, "", "", "save_callback");
            }

        }

        function save_callback(result) {
            if (typeof(result) == "string") {
            result = JSON.parse(result);
            }

            if (result[0].errorcode == 'Success') {
               dhtmlx.message({
                text: result[0].message,
                expire: 500
                            });
            }

            parent.load_grid_data();
            setTimeout(parent.window.w1.close(), 1000);
        }

    function item_changed(id) {
            if (id = 'requirement_type_id') {
            requirement_type_value = requirement_detail.form_requirement_detail.getItemValue('requirement_type_id');
                sub_tier_type_combo = requirement_detail.form_requirement_detail.getCombo('sub_tier_value_id');
                tier_type_combo = requirement_detail.form_requirement_detail.getCombo('tier_type');
            var has_blank_sub_tier_option = sub_tier_type_combo.getOption('');
                var has_blank_tier_option = tier_type_combo.getOption('');

                if (requirement_type_value == 23401)  { //Constraint
                requirement_detail.form_requirement_detail.setRequired('sub_tier_value_id', true);
                requirement_detail.form_requirement_detail.setRequired('tier_type', false);
                    sub_tier_type_combo.deleteOption('');
                    if (has_blank_tier_option == null) {
                    tier_type_combo.addOption([
                        ['', '']
                    ]);
                        tier_type_combo.setOptionIndex('', 0);
                }
                } else if (requirement_type_value == 23400) { //Assignment 
                requirement_detail.form_requirement_detail.setRequired('tier_type', true);
                requirement_detail.form_requirement_detail.setRequired('sub_tier_value_id', false);
                    tier_type_combo.deleteOption('');
                    if (has_blank_sub_tier_option == null) {
                    sub_tier_type_combo.addOption([
                        ['', '']
                    ]);
                        sub_tier_type_combo.setOptionIndex('', 0);
                }
        }
        }
    }
</script>