<?php
/**
* Compliance jurisdiction requirement screen
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
            $flag = get_sanitized_value($_GET["flag"] ?? '');
            $state_value_id = get_sanitized_value($_GET['state_value_id'] ?? '');
            $state_rec_requirement_data_id = (empty($_GET['state_rec_requirement_data_id']) ? -1 : get_sanitized_value($_GET['state_rec_requirement_data_id']));

            $function_id = 14100103;
            $name_space = 'requirement_data';

            $rights_requirement_data_iu = 14100104;
            $rights_requirement_data_delete = 14100105;

    list(
                $has_rights_requirement_data_iu,
                $has_rights_requirement_data_delete
    ) = build_security_rights(
                $rights_requirement_data_iu,
                $rights_requirement_data_delete
            );

            $layout = new AdihaLayout();
    $layout_name = 'compliance_jurisdiction_requirement';
            $layout_json = '[
                                {
                                    id:             "a",
                                    text:           "Requirement Data",
                                    header:         false,
                                    collapse:       false,
                                    fix_size:       [true,true]
                                },
                                {
                                    id:             "b",
                                    text:           "Requirement Detail",
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

            $form_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='" . $function_id . "', @template_name='requirement', @group_name='General', @parse_xml = '<Root><PSRecordSet state_rec_requirement_data_id=\"" . $state_rec_requirement_data_id . "\"></PSRecordSet></Root>'";
            $form_arr = readXMLURL2($form_sql);
            $form_json = $form_arr[0]['form_json'];

            $form_obj = new AdihaForm();
            $form_name = 'form_requirement';
            echo $layout->attach_form($form_name, 'a');
            $form_obj->init_by_attach($form_name, $name_space);
    echo $form_obj->load_form($form_json);

            $menu_toolbar_name = 'menu_grid_requirement';
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

            $grid_sql = "EXEC spa_adiha_grid 's','requirement_detail'";
            $grid_xml = readXMLURL2($grid_sql);


            $grid_name = 'grid_requirement';
            $grid_obj = new AdihaGrid();
            echo $layout->attach_grid_cell($grid_name, 'b');
            echo $grid_obj->init_by_attach($grid_name, $name_space);
    echo $grid_obj->set_header($grid_xml[0]['column_label_list'], $grid_xml[0]['column_alignment']);
            echo $grid_obj->set_columns_ids($grid_xml[0]['column_name_list']);
            echo $grid_obj->set_widths($grid_xml[0]['column_width']);
            echo $grid_obj->set_column_types($grid_xml[0]['column_type_list']);
            echo $grid_obj->set_sorting_preference($grid_xml[0]['sorting_preference']);
            echo $grid_obj->set_column_visibility($grid_xml[0]['set_visibility']);
            echo $grid_obj->set_column_alignment($grid_xml[0]['column_alignment']);
            echo $grid_obj->enable_multi_select(false);
            echo $grid_obj->set_search_filter(true);
            echo $grid_obj->return_init();
    echo $grid_obj->load_grid_functions();
            echo $grid_obj->attach_event('', 'onRowDblClicked', 'grid_onDblClick');
            echo $grid_obj->attach_event('', 'onRowSelect', 'row_onSelect');

            echo $layout->close_layout();
        ?>
</body>
<script type="text/javascript">
        var dhxWins = new dhtmlXWindows();
        var flag = "<?php echo $flag; ?>";
        var state_value_id = "<?php echo $state_value_id; ?>";
        var state_rec_requirement_data_id = "<?php echo $state_rec_requirement_data_id; ?>";

        $(function() {
            if (flag == 'u') {
                requirement_data.menu_grid_requirement.setItemEnabled('add');
                requirement_data.menu_grid_requirement.setItemEnabled('excel');
                requirement_data.menu_grid_requirement.setItemEnabled('pdf');
                load_grid_data();
            }
        });

        function row_onSelect() {
            requirement_data.menu_grid_requirement.setItemEnabled('delete');
        }

    function grid_onDblClick(rId, cInd) {
            var state_rec_requirement_detail_id = requirement_data.grid_requirement.cells(rId, 0).getValue();
            var param = 'compliance.jurisdiction.requirement.detail.php?flag=u&state_value_id=' + state_value_id + '&state_rec_requirement_data_id=' + state_rec_requirement_data_id + '&state_rec_requirement_detail_id=' + state_rec_requirement_detail_id;
            var is_win = dhxWins.isWindow('w1');
            if (is_win == true) {
            w1.close();
            }
            w1 = dhxWins.createWindow("w1", 0, 0, 600, 500);
            w1.setText("Requirement Detail");
            w1.maximize();
            w1.setModal(true);
            w1.attachURL(param, false, true);
        }

        function load_grid_data() {
            var sql = {
            "action": "spa_state_rec_requirement_detail",
            "flag": "s",
            "state_rec_requirement_data_id": state_rec_requirement_data_id
            }
            var data = $.param(sql);
        var data_url = js_data_collector_url + "&" + data;
            requirement_data.grid_requirement.clearAndLoad(data_url);
        }

    function grid_menu_onclick(id) {
        switch (id) {
            case 'add':
                    var param = 'compliance.jurisdiction.requirement.detail.php?flag=i&state_value_id=' + state_value_id + '&state_rec_requirement_data_id=' + state_rec_requirement_data_id;
                    var is_win = dhxWins.isWindow('w1');
                    if (is_win == true) {
                        w1.close();

                    }
                    w1 = dhxWins.createWindow("w1", 0, 0, 600, 500);
                    w1.setText("Requirement Detail");
                    w1.maximize();
                    w1.setModal(true);
                    w1.attachURL(param, false, true);
                break;
            case 'delete':
                    var selected_row = requirement_data.grid_requirement.getSelectedRowId();
                    selected_row = selected_row.split(',');

                    var delete_ids = [];

                    if (selected_row.length > 0) {
                        $.each(selected_row, function(key, value) {
                            var id = requirement_data.grid_requirement.cells(value, 0).getValue();
                            delete_ids.push(id);
                        });
                    }

                    var sql = {
                    "action": "spa_state_rec_requirement_detail",
                    "flag": 'd',
                    "state_rec_requirement_detail_id": delete_ids.join(',')
                    }

                dhtmlx.message({
                    type: "confirm-warning",
                    title: "Warning",
                    ok: "Confirm",
                    text: "Some data has been deleted from grid. Are you sure you want to save?",
                    callback: function(result) {
                        if (result) {
                            adiha_post_data("alert", sql, '', '', 'delete_and_refresh');
                        }
                    }
                });
                   // load_grid_data(); 
                break;
            case 'excel':
                    var path = js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php';
                    requirement_data.grid_requirement.toExcel(path);
                break;
            case 'pdf':
                    var path = js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php';
                    requirement_data.grid_requirement.toPDF(path);
                break;
            }
        }

    function delete_and_refresh(result) {
        // dhtmlx.message({
        //     text: result[0][4],
        //     expire: 500
        // });
            load_grid_data();
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
                requirement_data.menu_grid_requirement.setItemEnabled('add');
            if (result[0].recommendation != 'update_mode') {
                state_rec_requirement_data_id = result[0].recommendation;
                    flag = 'u';
                }
            parent.load_grid(state_value_id);
            setTimeout(parent.window.w1.close(), 1000);
        } else if (result[0].errorcode == "Error") {
                show_messagebox(result[0].message);
            }

        }

    function save_onclick() {
        var form_data = requirement_data.form_requirement.getFormData();
        var status = validate_form(requirement_data.form_requirement);
            from_year = requirement_data.form_requirement.getItemValue('from_year');
            to_year = requirement_data.form_requirement.getItemValue('to_year');
        if (from_year > to_year) {
                dhtmlx.alert({
                title: 'Alert',
                type: "alert",
                text: "To Year should be greater than From Year"
            });
                return;
            }
            if (status == false) {
            generate_error_message();
            return;
        }
            //var sql_from_year, sql_to_year;
            for (a in form_data) {
            if (a == 'per_profit_give_back') {
                var data_input = requirement_data.form_requirement.getItemValue(a, true);
				var  data_input_veryfy = isNaN(data_input);
            }

            if (a == 'renewable_target') {
					 var data_input_check = requirement_data.form_requirement.getItemValue(a, true);
                var data_input_veryf_requirement = isNaN(data_input_check);
				}

            if (data_input_veryfy == true) {
                requirement_data.form_requirement.setNote('per_profit_give_back', {
                    text: 'Invalid Number',
                    width: 200
                });
				}

            if (data_input_veryf_requirement == true) {
                requirement_data.form_requirement.setNote('renewable_target', {
                    text: 'Invalid Number',
                    width: 200
                });
				}

            if (data_input_veryfy == true || data_input_veryf_requirement == true) {
				 Break;
            }
        }

            var save_sql = {
            "action": "spa_state_rec_requirement_data",
            "flag": flag,
            "state_value_id": state_value_id,
            "compliance_year": "9999",
            "renewable_target": form_data['renewable_target'],
            "per_profit_give_back": form_data['per_profit_give_back'],
            "assignment_type_id": form_data['assignment_type_id'],
            "from_year": form_data['from_year'],
            "to_year": form_data['to_year'],
            "requirement_type_id": form_data['requirement_type_id'],
            "rec_assignment_priority_group_id": form_data['rec_assignment_priority_group_id']
        }

            if (flag == 'u') {
                save_sql["state_rec_requirement_data_id"] = state_rec_requirement_data_id
            }

            adiha_post_data("return_json", save_sql, "", "", "save_callback");
        }
</script>