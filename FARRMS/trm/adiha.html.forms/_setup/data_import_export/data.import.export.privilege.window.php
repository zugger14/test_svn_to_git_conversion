<?php

/**
 * Data import export privilege window screen
 * @copyright Pioneer Solutions
 */
?>
<!DOCTYPE html>
<html>

<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php
    require_once('../../../adiha.php.scripts/components/include.file.v3.php');
    ?>
</head>

<body>
    <?php
    $namespace                 =      'import_export_privilege';
    $privilege_add_function_id =      20003901;
    list(
        $has_privilege_add_function_id
    ) = build_security_rights(
        $privilege_add_function_id
    );

    $call_from = get_sanitized_value($_POST['call_from'] ?? 'NULL');
    $object_id = get_sanitized_value($_POST['object_id'] ?? 'NULL');

    /*
         * json for defining layout
         */

    $layout_json = '[                  
                                {
                                    id:             "a",
                                    header:         false,
                                    collapse:       false,
                                    text:           "Data Import/Export Privilege",
                                    fix_size:       [false, null]
                                }
                            ]';

    $privilege_layout = new AdihaLayout();
    echo $privilege_layout->init_layout('import_export_privilege', '', '1C', $layout_json, $namespace);

    $context_menu = new AdihaMenu();
    $context_menu_json = '[{id:"add", text:"Apply to All Report(s)", img:"new.gif", imgdis:"new_dis.gif", title: "Apply to All Data(s)"}]';
    echo $context_menu->init_menu('context_menu_report', $namespace);
    echo $context_menu->render_as_context_menu();
    echo $context_menu->attach_event('', 'onClick', 'context_menu_report_click');
    echo $context_menu->load_menu($context_menu_json);

    $context_menu_paramset = new AdihaMenu();
    $context_menu_json = '[{id:"add", text:"Apply to All Paramset(s)", img:"new.gif", imgdis:"new_dis.gif", title: "Apply to All Paramset(s)"}]';
    echo $context_menu_paramset->init_menu('context_menu_paramset', $namespace);
    echo $context_menu_paramset->render_as_context_menu();
    echo $context_menu_paramset->attach_event('', 'onClick', 'context_menu_paramset_click');
    echo $context_menu_paramset->load_menu($context_menu_json);

    $toolbar_obj = new AdihaToolbar();
    $toolbar_name = 'save_menu';
    $toolbar_json = '[
                            {
                                id:         "save", 
                                type:       "button", 
                                text:       "Save", 
                                img:        "save.gif", 
                                imgdis:     "save_dis.gif", 
                                disabled:   "false"
                            }
                         ]';
    echo $privilege_layout->attach_toolbar($toolbar_name);
    echo $toolbar_obj->init_by_attach($toolbar_name, $namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', 'save_click');

    echo $privilege_layout->close_layout();

    ?>
</body>
<script>
    var dhx_wins = new dhtmlXWindows();
    var object_id = '<?php echo $object_id; ?>';
    var call_from = '<?php echo $call_from; ?>';

    $(function() {
        import_export_privilege.fx_init_privilege_grid();
    });

    import_export_privilege.fx_init_privilege_grid = function() {
        grid_pv = import_export_privilege.import_export_privilege.cells('a').attachGrid();
        if (call_from == 'data_import_export_privilege') {
            grid_pv.setColumnIds('category,rule_id,rule_name,rule_type,system_rule,owner,data_source,user,user_name,role,role_ids');
            grid_pv.setHeader(get_locale_value('Category,Rule ID,Rule Name,Rule Type,System Rule,Owner,Data Source,User,User Name,Role,Role IDs', true));
            grid_pv.setColumnsVisibility('false,true,false,true,true,true,true,true,false,false,true');
            grid_pv.setInitWidths('*,*,*,*,*,*,*,*,*,*,*');
            grid_pv.setColTypes('ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro');
            grid_pv.setColSorting('str,str,str,str,str,str,str,str,str,str,str');
            grid_pv.setImagePath("<?php echo $image_path; ?>dhxtoolbar_web/");
            grid_pv.attachHeader('#text_filter,#numeric_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#numeric_filter');
            grid_pv.init();
            grid_pv.enableHeaderMenu();
            grid_pv.enableContextMenu(import_export_privilege.context_menu_report);

            grid_pv.attachEvent("onBeforeContextMenu", context_report_pre_func);
            grid_pv.attachEvent('onRowDblClicked', function(rid, cid) {
                var selID = grid_pv.getSelectedRowId();
                var selectedID = new Array();
                selectedID = selID.split(",");
                var ixp_id_array = new Array();
                for (count = 0; count < selectedID.length; count++) {
                    var row_index = grid_pv.getRowIndex(selID[count]);
                    var ixp_id = grid_pv.cells2(row_index, 1).getValue();
                    ixp_id_array.push(ixp_id);
                }
                var ixp_id_all = ixp_id_array.join();

                data = {
                    "action": "spa_ipx_privileges",
                    "flag": "a",
                    "import_export_id": ixp_id_all
                };

                result = adiha_post_data('return_array', data, '', '', 'set_privilege_callback');
            });
        }

        import_export_privilege.fx_refresh_grid();
    }

    set_privilege_callback = function(result) {
        var users = (result.length != 0) ? result[0][0] : '';

        if (users != null)
            users = users.substring(0, users.length - 1);

        var roles = (result.length != 0) ? result[0][2] : '';

        if (roles != null)
            roles = roles.substring(0, roles.length - 1);

        open_privilege('close_privilege_window', users, roles);
        user_change = users;
        role_change = roles;
    }



    var res = null;

    function close_privilege_window(role_id, user_id) {
        var selID = grid_pv.getSelectedRowId();
        data = {
            "action": "spa_ipx_privileges",
            "flag": "o",
            "role_id": role_id
        };
        res = role_id;
        adiha_post_data('return_array', data, '', '', 'set_role_user_in_grid');


        data = {
            "action": "spa_ipx_privileges",
            "flag": "e",
            "user_id": user_id
        };
        res = user_id;
        adiha_post_data('return_array', data, '', '', 'set_user_name_in_grid');

        grid_pv.cells(selID, 7).setValue(user_id);
        grid_pv.cells(selID, 10).setValue(role_id);

    }

    function set_role_user_in_grid(data) {
        if (data.length == 0) {
            data.push('None');
        }
        selID = grid_pv.getSelectedRowId();
        grid_pv.cells(selID, 9).setValue(data);
    }

    function set_user_name_in_grid(data) {
        if (data.length == 0) {
            data.push('None');
        }
        selID = grid_pv.getSelectedRowId();
        grid_pv.cells(selID, 8).setValue(data);
    }

    function refresh_grid_on_save() {
        import_export_privilege.fx_refresh_grid();
    }

    import_export_privilege.fx_refresh_grid = function() {
        var grid_obj = grid_pv;
        var param = '';

        if (call_from == 'data_import_export_privilege') {
            param = {
                "flag": "g",
                "action": "spa_ixp_rules",
                "rule_name": object_id
            };

        }

        param = $.param(param);
        var param_url = js_data_collector_url + "&" + param;
        grid_obj.clearAndLoad(param_url, function() {
            grid_obj.groupBy(0);

        });
    }

    function save_click(id) {
        switch (id) {
            case 'save':

                var xml_grid = '<gridXml>';
                grid_pv.forEachRow(function(id) {
                    var type_column_id = grid_pv.getColIndexById('rule_id');
                    var type_id = grid_pv.cells(id, type_column_id).getValue();
                    if (type_id != '') {
                        xml_grid = xml_grid + '<GridRow ';
                        grid_pv.forEachCell(id, function(cellObj, ind) {
                            grid_index = grid_pv.getColumnId(ind);
                            value = escapeXML(cellObj.getValue(ind));
                            if (grid_index == 'rule_id' || grid_index == 'user' || grid_index == 'role_ids' || grid_index == 'role') {
                                xml_grid = xml_grid + grid_index + '="' + value + '" ';
                            }
                        })
                        xml_grid = xml_grid + '></GridRow>';

                    }
                });
                xml_grid = xml_grid + '</gridXml>';

                var data = {
                    'action': 'spa_ipx_privileges',
                    'flag': 'v',
                    'xml_data': xml_grid
                };
                adiha_post_data('return_array', data, '', '', 'save_and_exit');
        }
    }

    function save_and_exit(result) {
        success_call('Changes has been saved successfully.');
        setTimeout(function() {
            parent.import_export_privilege.close();
        }, 1000);
    }

    //Apply to All for report grid
    function context_menu_report_click(menu_id, type) {
        var data = grid_pv.contextID.split("_"); //rowId_colInd
        var row_id = data[0];
        var col_id = data[1];
        var rule_id_array = new Array();
        var user_array = new Array();
        var user_name = new Array();
        var role_array = new Array;
        var val = grid_pv.cells(row_id, col_id).getValue();
        if (val == '')
            return false;

        if (grid_pv.getColIndexById('role') == col_id) {
            var rol_col_id = grid_pv.getColIndexById('role');
            var role_val = grid_pv.cells(row_id, rol_col_id).getValue();
            role_array.push(role_val);
            var role_all = role_array.join();

            grid_pv.forEachRow(function(rid) {
                var rule_col_id = grid_pv.getColIndexById('rule_id');
                var rule_id = grid_pv.cells(rid, rule_col_id).getValue();
                rule_id_array.push(rule_id);
                grid_pv.cells(rid, data[1]).setValue(val);
                grid_pv.cells(rid, 9).setValue(role_all);
            });

            //role_id
            role_array = [];
            var rol_col_id = grid_pv.getColIndexById('role_ids');
            var role_val = grid_pv.cells(row_id, rol_col_id).getValue();
            role_array.push(role_val);
            var role_all = role_array.join();

            grid_pv.forEachRow(function(rid) {
                var rule_col_id = grid_pv.getColIndexById('rule_id');
                var rule_id = grid_pv.cells(rid, rule_col_id).getValue();
                rule_id_array.push(rule_id);
                grid_pv.cells(rid, data[1]).setValue(val);
                grid_pv.cells(rid, 10).setValue(role_all);
            });

        }

        if (grid_pv.getColIndexById('user') == col_id) {
            var user_col_id = grid_pv.getColIndexById('user');
            var user_val = grid_pv.cells(row_id, user_col_id).getValue();
            user_array.push(user_val);
            var user_all = user_array.join();

            grid_pv.forEachRow(function(rid) {
                var rule_col_id = grid_pv.getColIndexById('rule_id');
                var rule_id = grid_pv.cells(rid, rule_col_id).getValue();
                rule_id_array.push(rule_id);
                grid_pv.cells(rid, data[1]).setValue(val);
            });
        }

        if (grid_pv.getColIndexById('user_name') == col_id) {
            var user_col_id = grid_pv.getColIndexById('user_name');
            var user_val = grid_pv.cells(row_id, user_col_id).getValue();
            user_name.push(user_val);
            var user_all = user_name.join();

            grid_pv.forEachRow(function(rid) {
                var rule_col_id = grid_pv.getColIndexById('rule_id');
                var rule_id = grid_pv.cells(rid, rule_col_id).getValue();
                rule_id_array.push(rule_id);
                grid_pv.cells(rid, data[1]).setValue(val);
                // grid_pv.cells(rid,8).setValue(role_all);
            });

            user_array = [];
            user_all = '';
            var user_col_id = grid_pv.getColIndexById('user');
            var user_val = grid_pv.cells(row_id, user_col_id).getValue();
            user_array.push(user_val);
            var user_all = user_array.join();

            grid_pv.forEachRow(function(rid) {
                var rule_col_id = grid_pv.getColIndexById('rule_id');
                var rule_id = grid_pv.cells(rid, rule_col_id).getValue();
                rule_id_array.push(rule_id);
                grid_pv.cells(rid, 7).setValue(user_val);
            });

        }

    }

    //Apply to All for paramset grid
    function context_menu_paramset_click(menu_id, type) {

        if (context_subgrid_pv[3] == '')
            return false;
        grid_pv.forEachRow(function(rid) {

            subgrid_pv[rid].forEachRow(function(srid) {
                if (context_subgrid_pv[0] != '')
                    alert(subgrid_pv[rid].cells(srid, subgrid_pv[rid].getColIndexById('user')));
                subgrid_pv[rid].cells(srid, subgrid_pv[rid].getColIndexById('user')).setValue(context_subgrid_pv[0]);
                if (context_subgrid_pv[1] != '') {
                    subgrid_pv[rid].cells(srid, subgrid_pv[rid].getColIndexById('role')).setValue(context_subgrid_pv[1]);
                    subgrid_pv[rid].cells(srid, subgrid_pv[rid].getColIndexById('role_ids')).setValue(context_subgrid_pv[2]);
                }
            });
        });
    }

    function context_report_pre_func(rowId, celInd, grid) {
        import_export_privilege.context_menu_paramset.hideContextMenu();
        if (celInd == grid.getColIndexById('user') || celInd == grid.getColIndexById('role') || celInd == grid.getColIndexById('user_name')) {
            return true;
        }
        return false;
    }
</script>