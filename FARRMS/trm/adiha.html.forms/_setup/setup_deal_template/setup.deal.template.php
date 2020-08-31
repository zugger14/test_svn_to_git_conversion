<?php
/**
* Setup deal template screen
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
    $application_function_id = 20011400;
    $template_id = get_sanitized_value($_GET['template_id'] ?? '');

    $right_manage_privilege = 20011403;
    list (
        $has_rights_manage_privilege
    ) = build_security_rights(
        $right_manage_privilege
	);
    
    $form_namespace = 'setup_deal_template';
    $form_obj = new AdihaStandardForm($form_namespace, $application_function_id);
    $form_obj->define_grid("SetupDealTemplate");
    $form_obj->disable_multiple_select();
    // $form_obj->define_layout_width(455);
    $form_obj->define_custom_functions('save_deal_template', 'load_deal_template', 'delete_deal_template');
    echo $form_obj->init_form('Deal Templates', 'Deal Templates Details', $template_id);
    echo $form_obj->close_form();
    
    $pool_grid_template_sp = "EXEC spa_adiha_grid 's', 'SetupDealTemplateFieldsPool'";
    $pool_grid_details = readXMLURL($pool_grid_template_sp);
?>
<body>
    <div id="field_data_view"></div>
</body>
<script type="text/javascript">
    var has_rights_manage_privilege = "<?php echo $has_rights_manage_privilege; ?>";

    $(document).ready(function() {
        setup_deal_template.tabbar.attachEvent("onTabClose", function(id) {
            delete setup_deal_template.details_form[id + "_layout_a"];
            delete setup_deal_template.details_layout["details_layout_" + id];
            delete setup_deal_template.details_tab[id];
            delete data_view_obj[id + "_n"];
            delete setup_deal_template[id];
            return true;
        });
        //## Add Copy Menu Item in Edit Menu
        setup_deal_template.menu.addNewChild('t1', 1, 'copy', 'Copy', true, 'copy.gif', 'copy_dis.gif');
        //## Add Privilege Menu Item
        setup_deal_template.menu.addNewSibling('t2', 'privilege', 'Privilege', true, 'privilege.gif', 'privilege_dis.gif');
        setup_deal_template.menu.attachEvent('onClick', setup_deal_template.grid_menu_privilege_click);
        setup_deal_template.grid.attachEvent('onSelectStateChanged', setup_deal_template.grid_select_state_change);
        setup_deal_template.grid.enableMultiselect(true);
    });
    
    dhtmlx.compat("dnd");

    var pool_grid_details = <?php echo json_encode($pool_grid_details) ?>;
    var main_win;
    var inner_tab_context_menu = {};

    setup_deal_template.details_layout = {};
    setup_deal_template.details_tab = {};
    setup_deal_template.details_form = {};
    data_view_obj = {};
    properties_toolbar = {};

    var details_cell_id = 'a';
    var field_pools_cell_id = 'b'
    var field_template_cell_id = 'c';
    var field_details_cell_id = 'd';
    var field_properties_cell_id = 'e';
    var main_layout_pattern = '5T';
    var deal_template_privilege;

    function reset_menu_item() {
        setup_deal_template.menu.setItemDisabled('delete');
        setup_deal_template.menu.setItemDisabled('copy');
        // setup_deal_template.menu.setItemDisabled('privilege');
    }

    function appendUDF(label, id){
        var suffix = (id.indexOf('UDF__') != -1) ? ' <span style="color: #999999">(UDF)</span>' : '';
        return label + suffix;
    }

    setup_deal_template.grid_menu_privilege_click = function(id, zoneId, cas) {
        if (id == 'privilege') {
            var deal_template_id = [];
            var selected_row_id = setup_deal_template.grid.getSelectedRowId();
            var template_id_index = setup_deal_template.grid.getColIndexById('template_id');
            selected_row_id = selected_row_id.split(',');
            selected_row_id.forEach(function(val) {
                deal_template_id.push(setup_deal_template.grid.cells(val, template_id_index).getValue());
            });

            deal_template_id = deal_template_id.toString();

            var params = "?deal_template_id=" + deal_template_id + "";

            if (deal_template_privilege != null && deal_template_privilege.unload != null) {
                deal_template_privilege.unload();
                deal_template_privilege = w2 = null;
            }
            if (!deal_template_privilege) {
                deal_template_privilege = new dhtmlXWindows();
            }
            var new_win = deal_template_privilege.createWindow("w2", 0, 0, 800, 560);
            url = js_php_base_path + '/adiha.html.forms/_setup/template_mapping_privilege/template.mapping.privilege.detail.php' + params;
            new_win.setText("Deal Template Privileges");
            new_win.centerOnScreen();
            new_win.maximize();
            new_win.setModal(true);
            new_win.attachURL(url, false, true);
        } else if (id == 'copy') {
            var selected_row_id = setup_deal_template.grid.getSelectedRowId();
            var grid_row_data = setup_deal_template.grid.getRowData(selected_row_id);
            var deal_template_id = grid_row_data.template_id;
            var field_template_id = grid_row_data.field_template_id;
            var data = {
                "action": "spa_setup_deal_template",
                "flag": "c",
                "field_template_id": field_template_id,
                "deal_template_id": deal_template_id
            }

            adiha_post_data("alert", data, "", "", "setup_deal_template.post_copy_callback");
        }
    }

    setup_deal_template.post_copy_callback = function(result) {
        if (result[0].errorcode == 'Success') {
            setup_deal_template.refresh_grid();
        }
    }

    setup_deal_template.grid_select_state_change = function(id) {
        var selected_row_id = setup_deal_template.grid.getSelectedRowId();
        if (selected_row_id) {
            setup_deal_template.menu.setItemEnabled('copy');
            if (has_rights_manage_privilege == 1)
                setup_deal_template.menu.setItemEnabled('privilege');
        } else {
            setup_deal_template.menu.setItemDisabled('copy');
            if (has_rights_manage_privilege == 1)
                setup_deal_template.menu.setItemDisabled('privilege');
        }
    }

    setup_deal_template.get_grid_cell_value = function(grid_obj, row_id, column_id) {
        var col_ind = grid_obj.getColIndexById(column_id);
        return grid_obj.cells2(row_id, col_ind).getValue();
    }

    setup_deal_template.load_deal_template = function(win, tab_id, click_obj) {
        setup_deal_template.layout.cells('a').collapse();
        setup_deal_template[tab_id] = {};
        main_win = win;
        var deal_template_id = field_template_id = deal_template_name = is_template_mobile = field_template_description = '';
        var is_template_active = true;
        var is_system_checked = false;
        var is_new = win.getText();

        if (is_new != get_locale_value('New')) {
            deal_template_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
            //Get Deal Template Values From Grid to set in Form
            var grid_obj = setup_deal_template.grid;
            var main_grid_row = grid_obj.findCell(deal_template_id, 0, true);
            var row_id = main_grid_row[0][0];
            var grid_row_data = grid_obj.getRowData(row_id);
            deal_template_name = unescapeXML(grid_row_data.template_name);
            field_template_description = unescapeXML(grid_row_data.field_template_description);
            field_template_id = grid_row_data.field_template_id;
            is_template_active = (grid_row_data.is_active == 'Yes') ? true : false;
            is_template_mobile = (grid_row_data.is_mobile == 'Yes') ? true : false;
        }

        win.progressOn();

        var field_template_id = field_template_id || "NULL";
        var data = {
            "action": "spa_setup_deal_template",
            "flag": "j",
            "field_template_id": field_template_id
        };
        adiha_post_data("return_json", data, "", "", "setup_deal_template.load_deal_template_inner_ui");

        //## Attach Layout
        setup_deal_template.details_layout["details_layout_" + tab_id] = win.attachLayout({
            pattern: main_layout_pattern,
            cells: [
                {id: "a", text: "Template Details", header: false, height: 65},
                {id: "b", text: "Available Fields Pool", collapse: false, width: 270},
                {id: "c", text: "Field Template Details", header: false},
                {id: "d", text: "Detail", height: 280},
                {id: "e", text: "Field Properties", collapse: true, width: 300, fix_size: [true, true]},
            ]
        });

        //## Load Pool Grids
        var pool_tab_json = [
            {"id": "header_pool", "text": "Header", "active": true},
            {"id": "detail_pool", "text": "Detail"}
        ];
        //## Create Tabs
        var pool_tabbar_data = {tabs: get_tab_json_locale(pool_tab_json)};
        setup_deal_template[tab_id].pools_tab = setup_deal_template.details_layout["details_layout_" + tab_id]
            .cells(field_pools_cell_id)
            .attachTabbar({mode: "top"});
        setup_deal_template[tab_id].pools_tab.loadStruct(pool_tabbar_data);
        setup_deal_template[tab_id].pools_grid = [];
        setup_deal_template[tab_id].pools_tab.forEachTab(function(pool_tab_obj) {
            var pool_tab_id = pool_tab_obj.getId();
            setup_deal_template[tab_id].pools_tab.t[pool_tab_id].tab.id = pool_tab_id;
            //## Attach Grid
            var filter = pool_grid_details[0][2].replace(/[a-zA-Z0-9_]+/g, "#text_filter");
            setup_deal_template[tab_id].pools_tab.tabs(pool_tab_id).attachStatusBar({
                "height": 30,
                "text": '<div id="pagingAreaGrid_' + tab_id + pool_tab_id + '"></div>'
            });
            setup_deal_template[tab_id].pools_grid[pool_tab_id] = setup_deal_template[tab_id].pools_tab.tabs(pool_tab_id).attachGrid();
            setup_deal_template[tab_id].pools_grid[pool_tab_id].setImagesPath(js_image_path + '/dhxtoolbar_web/');
            setup_deal_template[tab_id].pools_grid[pool_tab_id].setColumnIds(pool_grid_details[0][2]);
            setup_deal_template[tab_id].pools_grid[pool_tab_id].setHeader(pool_grid_details[0][3]);
            setup_deal_template[tab_id].pools_grid[pool_tab_id].setColTypes(pool_grid_details[0][4]);
            setup_deal_template[tab_id].pools_grid[pool_tab_id].setColumnsVisibility(pool_grid_details[0][9]);
            setup_deal_template[tab_id].pools_grid[pool_tab_id].setInitWidths(pool_grid_details[0][10]);
            setup_deal_template[tab_id].pools_grid[pool_tab_id].attachHeader(filter);
            setup_deal_template[tab_id].pools_grid[pool_tab_id].setUserData("", "grid_id", pool_tab_id);
            setup_deal_template[tab_id].pools_grid[pool_tab_id].init();
            setup_deal_template[tab_id].pools_grid[pool_tab_id].enablePaging(true, 50, 0, 'pagingAreaGrid_' + tab_id + pool_tab_id);
            setup_deal_template[tab_id].pools_grid[pool_tab_id].setPagingWTMode(true, true, true, true);
            setup_deal_template[tab_id].pools_grid[pool_tab_id].setPagingSkin('toolbar');
            setup_deal_template[tab_id].pools_grid[pool_tab_id].enableDragAndDrop(true);
            setup_deal_template[tab_id].pools_grid[pool_tab_id].enableMercyDrag(true);
            setup_deal_template[tab_id].pools_grid[pool_tab_id].enableHeaderMenu();
            var grid_sql = (pool_tab_id == 'header_pool') ? pool_grid_details[0][6] + ', @field_template_id = ' + field_template_id : pool_grid_details[0][6] + ", @field_template_id = " + field_template_id + ", @header_detail = 'd'";
            var sql_param = {
                "sql": grid_sql,
                "grid_type": "tg",
                "grouping_column": pool_grid_details[0][8],
            };
            sql_param = $.param(sql_param);
            var sql_url = js_data_collector_url + "&"+ sql_param;
            setup_deal_template[tab_id].pools_grid[pool_tab_id].load(sql_url);

            //## Prevent Drag and drop in self
            setup_deal_template[tab_id].pools_grid[pool_tab_id].attachEvent("onDragIn", function(dId, tId, sObj, tObj) {
                return false;
            });
            //## Prevent Drag parent node
            setup_deal_template[tab_id].pools_grid[pool_tab_id].attachEvent("onBeforeDrag", function(id) {
                var level = setup_deal_template[tab_id].pools_grid[pool_tab_id].getLevel(id);
                if (level == 0) return false;
                return true;
            });

            //Prevent grid cell go in edit mode when double clicking parent node
            setup_deal_template[tab_id].pools_grid[pool_tab_id].attachEvent("onRowDblClicked", function(row_id, col_id) {
                var level = setup_deal_template[tab_id].pools_grid[pool_tab_id].getLevel(row_id);
                if (level == 0) {
                    var state = setup_deal_template[tab_id].pools_grid[pool_tab_id].getOpenState(row_id);

                    if (state)
                        setup_deal_template[tab_id].pools_grid[pool_tab_id].closeItem(row_id);
                    else
                        setup_deal_template[tab_id].pools_grid[pool_tab_id].openItem(row_id);
                }
            });
        });

        //## Handle Arrow for Field Properties Layout Cell
        // setup_deal_template.details_layout["details_layout_" + tab_id].cells(field_properties_cell_id).hideArrow();
        // setup_deal_template.details_layout["details_layout_" + tab_id].attachEvent("onCollapse", function(name) {
        //     if (name == field_properties_cell_id) {
        //         setup_deal_template.details_layout["details_layout_" + tab_id].cells(field_properties_cell_id).hideArrow();
        //     }
        // });

        //Fix Panel size not expanding up to layout cell size
        setup_deal_template.details_layout["details_layout_" + tab_id].attachEvent("onPanelResizeFinish", function(names) {
            if (names.find(field_pools_cell_id)) {
                setup_deal_template.refresh_dataview_items();
            }
        });

        setup_deal_template.details_layout["details_layout_" + tab_id].attachEvent("onExpand", function(name) {
            if (name == field_properties_cell_id || name == field_pools_cell_id) {
                setup_deal_template.refresh_dataview_items();
            }
        });

        //## Load Form in Template Details Cell
        var form_json = [
            {"type": "settings", "position": "label-top"},
            {
                type: "block",
                blockOffset: ui_settings['block_offset'],
                list: [
                    {"type": "input", "name": "deal_template_id", "label": "Template ID", "disabled": "true", "hidden": true, "offsetLeft": ui_settings['offset_left'],"labelWidth": "auto","inputWidth": ui_settings['field_size'], "value": deal_template_id},
                    // {"type": "newcolumn"},
                    // {"type": "combo", "name": "field_template_id", "label": "Field Template", "validate": "NotEmpty", "hidden": "false", "disabled": is_field_template_disabled, "offsetLeft": ui_settings['offset_left'], "labelWidth": "auto", "inputWidth": ui_settings['field_size'], "required": true, "tooltip": "Field Template", "value": field_template_id, "filtering": true, "filtering_mode":"between", "options": final_field_template_options, "userdata": {
                    //         "validation_message": "Required Field "
                    //     },
                    // },
                    {"type": "newcolumn"},
                    {"type": "input", "name": "deal_template_name", "label": "Template Name", "validate": "NotEmptywithSpace", "hidden": "false", "disabled": "false", "offsetLeft": ui_settings['offset_left'], "labelWidth": "auto", "inputWidth": ui_settings['field_size'], "required": true, "tooltip": "Template Name", "value": deal_template_name, "userdata": {
                            "validation_message": "Required Field "
                        },
                    },
                    {"type": "newcolumn"},
                    {"type": "input", "name": "deal_template_description", "label": "Description", "hidden": "false", "disabled": "false", "offsetLeft": ui_settings['offset_left'], "labelWidth": "auto", "inputWidth": ui_settings['field_size'], "tooltip": "Description", "value": field_template_description
                    },
                    {"type": "newcolumn"},
                    {"type": "checkbox", "position": "label-right", "name": "is_active", "label": "Active", "tooltip": "Active", "offsetLeft": ui_settings['offset_left'], "offsetTop": ui_settings['checkbox_offset_top'], "checked": is_template_active},
                    {"type": "newcolumn"},
                    {"type": "checkbox", "position": "label-right", "name": "is_mobile", "label": "Mobile", "tooltip": "Mobile", "offsetLeft": ui_settings['offset_left'], "offsetTop": ui_settings['checkbox_offset_top'], "checked": is_template_mobile}
                ]
            }];

        var form_id = tab_id + '_layout_' + details_cell_id;
        setup_deal_template.details_form[form_id] = setup_deal_template.details_layout["details_layout_" + tab_id].cells(details_cell_id).attachForm();
        setup_deal_template.details_form[form_id].loadStruct(get_form_json_locale(form_json));

        var toolbar_json = [
            {id:"ok", type: "button", img: "tick.gif", imgdis: "tick_dis.gif", text:"Ok", title: "Ok"},
            {id:"remove", type: "button", img: "trash.gif", imgdis: "trash_dis.gif", text:"Remove", title: "Remove"}
        ];
        properties_toolbar[tab_id] = setup_deal_template.details_layout["details_layout_" + tab_id].cells(field_properties_cell_id)
            .attachToolbar({
                icons_path: js_image_path + 'dhxtoolbar_web/',
                json: toolbar_json
            });
        properties_toolbar[tab_id].attachEvent('onClick', setup_deal_template.properties_toolbar_click);
    }

    var grid_retrieve_mode = false;
    setup_deal_template.load_deal_template_inner_ui = function(result) {
        var ui_json = JSON.parse(result);
        var final_tab_json = [];
        var final_form_json = {};
        var final_grid_json = {};
        var detail_grid_json;
        var final_detail_tab_json = [];
        var final_detail_grid_json = {};

        var tab_id = setup_deal_template.tabbar.getActiveTab();
        var tab_menu_json = '{"value":"","text":""}';
        ui_json.forEach(function(i) {
            var a = JSON.parse(i.tab_json);
            a.id = i.tab_id;

            if (i.header_detail == 'h') {
                final_tab_json.push(JSON.stringify(a));
                final_form_json[i.tab_id] = i.form_json;
                final_grid_json[i.tab_id] = i.grid_json;
                if (i.grid_json == null) {
                    tab_menu_json += ',' + i.tab_json.replace('"id"', '"value"');
                }
            } else if (i.tab_id == 'template_detail_n') {
                final_detail_tab_json.push(JSON.stringify(a));
                //## Generate Grid details
                detail_grid_json = i.form_json;
            } else if (i.header_detail == 'd') {
                final_detail_tab_json.push(JSON.stringify(a));
                final_detail_grid_json[i.tab_id] = i.grid_json;
            }
        });
        setup_deal_template[tab_id].move_to_json = "[" + tab_menu_json + "]";
        //## Create Inner Tab
        var tabbar_data = '{tabs: [' + final_tab_json.join(",") + ']}';
        setup_deal_template.details_tab[tab_id] = setup_deal_template.details_layout["details_layout_" + tab_id].cells(field_template_cell_id).attachTabbar({mode: "top"});
        setup_deal_template.details_tab[tab_id].loadStruct(tabbar_data);
        setup_deal_template.details_tab[tab_id].attachEvent('onTabClick', setup_deal_template.refresh_dataview_items);

        // ## Add Tabbar in Detail layout
        var detail_tabbar_data = '{tabs: [' + final_detail_tab_json.join(",") + ']}';
        setup_deal_template[tab_id].details_tab = setup_deal_template.details_layout["details_layout_" + tab_id].cells(field_details_cell_id).attachTabbar({mode: "top"});
        setup_deal_template[tab_id].details_tab.loadStruct(detail_tabbar_data);
        
        create_tabbar_context_menu(setup_deal_template[tab_id].details_tab, tab_id, 'detail');

        // Attach Menu in General Tab for detail grid
        setup_deal_template[tab_id].grid_menu = setup_deal_template[tab_id].details_tab.tabs('template_detail_n').attachMenu({
            icons_path: js_image_path + "dhxmenu_web/",
            items: [
                {id: "edit", text: "Edit", img: "edit.gif", img_disabled: "edit_dis.gif", items: [
                        {id: "add", text: "Add", img: "add.gif", img_disabled: "add_dis.gif"},
                        {id: "delete", text: "Delete", disabled: true, img: "delete.gif", img_disabled: "delete_dis.gif"}
                    ]},
                {id: "t2", text: "Export", img: "export.gif", items: [
                        {id: "excel", text: "Excel", img: "excel.gif", imgdis: "excel_dis.gif", title: "Excel"},
                        {id: "pdf", text: "PDF", img: "pdf.gif", imgdis: "pdf_dis.gif", title: "PDF"}
                    ]}
            ]
        });
        setup_deal_template[tab_id].grid_menu.attachEvent("onClick", function(id) {
            switch(id) {
                case "add":
                    setup_deal_template.add_detail_grid_row(tab_id);
                    break;
                case "delete":
                    setup_deal_template.delete_detail_grid_row(tab_id);
                    break;
                case "excel":
                    setup_deal_template[tab_id].detail_grid.toExcel(js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                    break;
                case "pdf":
                    setup_deal_template[tab_id].detail_grid.toPDF(js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                    break;
                default:
                    break;
            }
        });

        //## Add Other Tab
        var tab_ids = setup_deal_template.details_tab[tab_id].getAllTabs();
        setup_deal_template.details_tab[tab_id].addTab('other_tab', 'Other', null, 99999, false, false);
        setup_deal_template.details_tab[tab_id].t['other_tab'].tab.id = "other_tab";

        var field_template_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;

        var data = {
            "action": "spa_create_application_ui_json",
            "flag": "j",
            "application_function_id": 20011400,
            "template_name": "SetupDealTemplate",
            "parse_xml": '<Root><PSRecordset template_id="' + field_template_id + '"></PSRecordset></Root>'
        };
        adiha_post_data("return_json", data, "", "", "setup_deal_template.load_deal_template_other_tab");

        //## Attach Layout in each Tabs
        var key = tab_id + "_n";
        data_view_obj[key] = {};
        setup_deal_template[tab_id].inner_tab_layout = {};
        
        create_tabbar_context_menu(setup_deal_template.details_tab[tab_id], tab_id, 'header', key);
        
        Object.keys(final_form_json).forEach(function(i) {
            //## Attach add context menu in each tab
            var id = i;
            setup_deal_template.details_tab[tab_id].t[id].tab.id = id;
            inner_tab_context_menu['header'].addContextZone(id);

            setup_deal_template[tab_id].inner_tab_layout[i] = setup_deal_template.details_tab[tab_id].cells(i).attachLayout("1C");
            setup_deal_template[tab_id].inner_tab_layout[i].cells("a").hideHeader();

            if (final_form_json[i] == null && final_grid_json[i] != null) {
                var grid_data = JSON.parse(final_grid_json[i]);
                setup_deal_template[tab_id].inner_tab_layout[i].cells("a").setText(grid_data.label);
                global_udt_grid_obj = setup_deal_template[tab_id].inner_tab_layout[i].cells("a").attachGrid();
                global_udt_grid_id = grid_data.id;
                global_udt_grid_label = grid_data.label;

                setup_deal_template.details_tab[tab_id].cells(i).setUserData('user_data', 'y_' + grid_data.show_in_form);

                grid_retrieve_mode = true;
                data = {
                    "action": "spa_adiha_grid",
                    "flag": "s",
                    "grid_name": grid_data.name
                };

                adiha_post_data('return_array', data, '', '', 'create_udt_grid', '');
            } else {
                //## Attach Form Fields
                var f_key = id;
                $("#field_data_view").append('<div id="data_container_' + key + '" class="data_container_class"><span><div id="data_container_' + key + f_key + '" class="data_container_inner_class"></div></span></div>');
                setup_deal_template[tab_id].inner_tab_layout[i].cells("a").attachObject("data_container_" + key);
                attach_data_view_events(key, f_key, final_form_json[i]);
            }
        });

        //## Attach Detail Grid
        setup_deal_template[tab_id].detail_grid = setup_deal_template[tab_id].details_tab.tabs('template_detail_n').attachGrid();

        var detail_grid_column_id = "source_deal_detail_id";
        var detail_grid_column_label = "ID";
        var detail_grid_column_width = "120";
        var detail_grid_column_types = "ro";
        var detail_grid_column_move = "false";
        setup_deal_template[tab_id].detail_grid['column_info'] = {};
        setup_deal_template[tab_id].detail_grid['dropdown_columns'] = {};
        JSON.parse(detail_grid_json).forEach(function(i) {
            if (i.id == 'source_deal_detail_id') return;
            setup_deal_template[tab_id].detail_grid['column_info'][i.id] = i;
            var column_type = setup_deal_template.resolve_field_type(i.field_type, true);
            if (column_type == 'combo')
                setup_deal_template[tab_id].detail_grid['dropdown_columns'][i.id] = i;

            detail_grid_column_id += "," + i.id;
            var label = appendUDF(i.label, i.id);
            detail_grid_column_label += "," + label;
            detail_grid_column_width += ",120";
            detail_grid_column_types += "," + column_type;
        });

        setup_deal_template[tab_id].detail_grid.setImagesPath(js_image_path + '/dhxtoolbar_web/');
        setup_deal_template[tab_id].detail_grid.setColumnIds(detail_grid_column_id);
        setup_deal_template[tab_id].detail_grid.setHeader(detail_grid_column_label);
        setup_deal_template[tab_id].detail_grid.setColTypes(detail_grid_column_types);
        setup_deal_template[tab_id].detail_grid.setInitWidths(detail_grid_column_width);
        setup_deal_template[tab_id].detail_grid.setDateFormat(user_date_format, "%Y-%m-%d");
        setup_deal_template[tab_id].detail_grid.init();
        setup_deal_template[tab_id].detail_grid.enableColumnMove(true);
        setup_deal_template[tab_id].detail_grid.enableDragAndDrop(true);

        _.each(setup_deal_template[tab_id].detail_grid['dropdown_columns'], function(i) {
            if (i.dropdown_json == '' || i.dropdown_json == undefined) return;
            var col_index = setup_deal_template[tab_id].detail_grid.getColIndexById(i.id);
            var combo_obj = setup_deal_template[tab_id].detail_grid.getColumnCombo(col_index);
            combo_obj.enableFilteringMode(true);
            combo_obj.load({options: JSON.parse(i.dropdown_json)});
        });

        setup_deal_template[tab_id].detail_grid.attachEvent("onBeforeCMove", function(cInd, posInd) {
            if (posInd == 0)
                return false;

            return true;
        });

        setup_deal_template[tab_id].detail_grid.attachEvent("onHeaderClick", function(ind, obj) {
            var tab_id = setup_deal_template.tabbar.getActiveTab();
            setup_deal_template.details_layout["details_layout_" + tab_id].cells(field_properties_cell_id).expand();
            setup_deal_template.details_layout["details_layout_" + tab_id].cells(field_properties_cell_id).showArrow();
            var column_id = setup_deal_template[tab_id].detail_grid.getColumnId(ind);
            setup_deal_template.load_field_properties(column_id);
        });

        setup_deal_template[tab_id].detail_grid.attachEvent("onDragIn", function(dId, tId, sObj, tObj) {
            if (sObj instanceof dhtmlXGridObject) {
                if (sObj.getUserData("", "grid_id") == "detail_pool")
                    return true;
            }
            return false;
        });

        setup_deal_template[tab_id].detail_grid.attachEvent("onRowSelect", function(id, ind) {
            setup_deal_template[tab_id].grid_menu.setItemEnabled("delete");
        });

        setup_deal_template[tab_id].detail_grid.attachEvent("onBeforeDrag", function(id) {
            return false;
        });

        setup_deal_template[tab_id].detail_grid.attachEvent("onDrop", function(sId, tId, dId, sObj, tObj, sCol, tCol) {
            tObj.deleteRow(dId);
            var row_data = sObj.getRowData(sId);
            var label = row_data['label'];
            var udf_or_system = row_data['udf_or_system'];
            var tab_id = setup_deal_template.tabbar.getActiveTab();

            if (udf_or_system == 't') {
                var field_id = row_data['id'];
                var tab_ids = setup_deal_template[tab_id].details_tab.getAllTabs();
                
                var new_tab_id = (new Date()).valueOf();
                setup_deal_template[tab_id].details_tab.addTab(new_tab_id, label, null, tab_ids.length, true, false)
                setup_deal_template[tab_id].details_tab.t[new_tab_id].tab.id = String(new_tab_id);
                inner_tab_context_menu['detail'].addContextZone(String(new_tab_id));
                setup_deal_template[tab_id].details_tab.details_layout = {};
                setup_deal_template[tab_id].details_tab.details_layout = setup_deal_template[tab_id].details_tab.cells(new_tab_id).attachLayout("1C");
                setup_deal_template[tab_id].details_tab.details_layout.cells("a").hideHeader();
                global_udt_grid_obj = setup_deal_template[tab_id].details_tab.details_layout.cells("a").attachGrid();
                global_udt_grid_id = field_id;
                global_udt_grid_label = label;
                
                data = {
                    "action": "spa_user_defined_tables",
                    "flag": "g",
                    "udt_id": field_id
                };

                adiha_post_data('return_array', data, '', '', 'create_udt_grid', '');
            } else {
                row_data['org_label'] = label;
            setup_deal_template[tab_id].detail_grid['column_info'][row_data['id']] = row_data;
            setup_deal_template[tab_id].detail_grid['column_info'][row_data['id']].insert_required = 'y';
            setup_deal_template[tab_id].detail_grid['column_info'][row_data['id']].update_required = 'y';
            var col_type = setup_deal_template.resolve_field_type(row_data.field_type, true);
            var col_ind = tObj.getColumnsNum();

            var label = appendUDF(row_data.label, row_data.id);
            tObj.insertColumn(col_ind, label, col_type, 120);
            tObj.setColumnId(col_ind, row_data.id);

            if (col_type == "combo") {
                var combo_obj = tObj.getColumnCombo(col_ind);
                combo_obj.enableFilteringMode(true);
                var cm_param = {
                    "action": "[spa_generic_mapping_header]",
                    "flag": "n",
                    "combo_sql_stmt": row_data.sql_string.replace(/'/g, "''"),
                    "call_from": "grid"
                };
                cm_param = $.param(cm_param);
                var url = js_dropdown_connector_url + '&' + cm_param;
                combo_obj.load(url, function() {
                    set_detail_grid_value(tObj, col_ind, row_data.default_value);
                });
            } else {
                set_detail_grid_value(tObj, col_ind, row_data.default_value);
            }
            }
            sObj.deleteRow(sId);
        });

        var sql_param = {
            "action": "spa_setup_deal_template",
            "flag": "g",
            "deal_template_id": field_template_id,
            "grid_type": "g"
        };
        sql_param = $.param(sql_param);
        var sql_url = js_data_collector_url + "&"+ sql_param;
        setup_deal_template[tab_id].detail_grid.load(sql_url, function() {
            if (setup_deal_template[tab_id].detail_grid.getRowsNum() < 1) {
                setup_deal_template.add_detail_grid_row(tab_id);
            }
        });

        // Create Detail UDT grids
        Object.keys(final_detail_grid_json).forEach(function(i) {
            setup_deal_template.details_tab[tab_id].details_layout = {};
            setup_deal_template.details_tab[tab_id].details_layout = setup_deal_template[tab_id].details_tab.cells(i).attachLayout("1C");
            setup_deal_template.details_tab[tab_id].details_layout.cells("a").hideHeader();
            
            var grid_data = JSON.parse(final_detail_grid_json[i]);
            if (grid_data != null) {
                global_udt_grid_obj = setup_deal_template.details_tab[tab_id].details_layout.cells("a").attachGrid();
                global_udt_grid_id = grid_data.id;
                global_udt_grid_label = grid_data.label;

                grid_retrieve_mode = true;
                data = {
                    "action": "spa_adiha_grid",
                    "flag": "s",
                    "grid_name": grid_data.name
                };

                adiha_post_data('return_array', data, '', '', 'create_udt_grid', '');
            }
        });

        setup_deal_template.enable_tab_dnd();

        if (setup_deal_template[tab_id].tab_load_complete)
            main_win.progressOff();

        setup_deal_template[tab_id].tab_load_complete = true;
    }

    function set_detail_grid_value(grid_obj, col_ind, value) {
        grid_obj.forEachRow(function(id) {
            grid_obj.cells(id, col_ind).setValue(value);
        });
    }

    setup_deal_template.add_detail_grid_row = function(tab_id) {
        var new_id = (new Date()).valueOf();
        var grid_obj = setup_deal_template[tab_id].detail_grid;
        var grid_total_cols = grid_obj.getColumnsNum();
        var default_value_string = '';

        for (var col_index = 0; col_index < grid_total_cols; col_index++) {
            var column_id = grid_obj.getColumnId(col_index);
            if (column_id == 'source_deal_detail_id') continue;
            if (col_index != 0) default_value_string += ',';
            if (column_id == 'leg')
                default_value_string += grid_obj.getRowsNum() + 1;
            else
                default_value_string += grid_obj.column_info[column_id].default_value;
        }
        grid_obj.addRow(new_id, default_value_string);
        grid_obj.selectRow(setup_deal_template[tab_id].detail_grid.getRowIndex(new_id), false, false, true);
    }

    setup_deal_template.delete_detail_grid_row = function(tab_id) {
        var del_ids = setup_deal_template[tab_id].detail_grid.getSelectedRowId();
        var previously_xml = setup_deal_template[tab_id].detail_grid.getUserData("", "deleted_xml");
        var grid_xml = "";
        if (previously_xml != null)
            grid_xml += previously_xml;
        var source_deal_detail_id = setup_deal_template[tab_id].detail_grid.cells(del_ids, setup_deal_template[tab_id].detail_grid.getColIndexById('source_deal_detail_id')).getValue();
        if (source_deal_detail_id != "")
            grid_xml += '<GridRow source_deal_detail_id="'+ source_deal_detail_id + '" ></GridRow>';
        setup_deal_template[tab_id].detail_grid.setUserData("", "deleted_xml", grid_xml);
        setup_deal_template[tab_id].detail_grid.deleteSelectedRows();
        setup_deal_template[tab_id].grid_menu.setItemDisabled("delete");
        setup_deal_template[tab_id].detail_grid.forEachRow(function(row){
            var leg_c_ind = setup_deal_template[tab_id].detail_grid.getColIndexById('leg');
            setup_deal_template[tab_id].detail_grid.cells(row, leg_c_ind).setValue(setup_deal_template[tab_id].detail_grid.getRowIndex(row) + 1);
        });
    }
    setup_deal_template.load_deal_template_other_tab = function(result) {
        var other_result = JSON.parse(result);
        var other_tab_form_json = other_result[0]['form_json'];
        var tab_id = setup_deal_template.tabbar.getActiveTab();
        setup_deal_template[tab_id].inner_tab_layout['other_tab'] = setup_deal_template.details_tab[tab_id].cells('other_tab').attachLayout("1C");
        setup_deal_template[tab_id].inner_tab_layout['other_tab'].cells("a").hideHeader();
        var a = setup_deal_template[tab_id].inner_tab_layout['other_tab'].cells("a").attachForm();
        a.loadStruct(other_tab_form_json);

        a.setValidation('year', "^[0-9]{4}$");
        a.setUserData('year', 'validation_message', 'Invalid Year');
        a.setValidation('month', "^((0?[0-9])|10|11|12)$");
        a.setUserData('month', 'validation_message', 'Invalid Month');

        if (setup_deal_template[tab_id].tab_load_complete)
            main_win.progressOff();

        setup_deal_template[tab_id].tab_load_complete = true;
    }

    setup_deal_template.properties_toolbar_click = function(id) {
        var tab_id = setup_deal_template.tabbar.getActiveTab();
        var form_id = tab_id + '_layout_' + field_properties_cell_id;
        var form_obj = setup_deal_template[tab_id].properties_form;
        var dv_obj = form_obj.getUserData("field_name", "dv_obj");
        switch (id) {
            case "ok":
                var status = validate_form(form_obj);
                if (status) {
                    var form_data = form_obj.getFormData();
                    if (dv_obj) {
                        var id = dv_obj.getSelected();
                        var data = dv_obj.get(id);
                        data.label = form_data.field_name;
                        data.disabled = form_data.disable;
                        data.hide_control = '';
                        data.insert_required = form_data.show_insert;
                        data.update_required = form_data.show_update;
                        data.value_required = form_data.value_req;
                        dv_obj.refresh(id);
                        if (form_data.move_to != "") {
                            var key = tab_id + "_n";
                            var f_key = form_data.move_to;// + "_" + tab_id;
                            data.field_group_id = form_data.move_to;
                            dv_obj.move(id, null, data_view_obj[key][f_key], id);
                        }
                    } else {
                        var col_ind = setup_deal_template[tab_id].detail_grid.getColIndexById(form_data.field_id);
                        var label = appendUDF(form_data.field_name, form_data.field_id);
                        setup_deal_template[tab_id].detail_grid.setColLabel(col_ind, label);
                        setup_deal_template[tab_id].detail_grid.column_info[form_data.field_id].label = form_data.field_name;
                        setup_deal_template[tab_id].detail_grid.column_info[form_data.field_id].insert_required = form_data.show_insert;
                        setup_deal_template[tab_id].detail_grid.column_info[form_data.field_id].update_required = form_data.show_update;
                        setup_deal_template[tab_id].detail_grid.column_info[form_data.field_id].value_required = form_data.value_req;
                        setup_deal_template[tab_id].detail_grid.column_info[form_data.field_id].hide_control = form_data.hide_control;
                        setup_deal_template[tab_id].detail_grid.column_info[form_data.field_id].show_in_form = form_data.show_form;
                        setup_deal_template[tab_id].detail_grid.column_info[form_data.field_id].disabled = form_data.disable;
                    }
                    setup_deal_template.details_layout["details_layout_" + tab_id].cells(field_properties_cell_id).collapse();
                }
                break;
            case "remove":
                var message = "Are you sure you want to remove this field?";
                confirm_messagebox(message, function() {
                    if (dv_obj) {
                        var id = dv_obj.getSelected();
                        var data = dv_obj.get(id);
                    } else {
                        var col_id = form_obj.getItemValue('field_id');
                        var col_ind = setup_deal_template[tab_id].detail_grid.getColIndexById(col_id);
                        var data = setup_deal_template[tab_id].detail_grid['column_info'][col_id];
                        delete setup_deal_template[tab_id].detail_grid['column_info'][col_id];
                    }

                    add_row_back_to_pool_grid(tab_id, data);
                    
                    if (dv_obj)
                        dv_obj.remove(id);
                    else {
                        setup_deal_template[tab_id].detail_grid.deleteColumn(col_ind);
                    }

                    setup_deal_template.details_layout["details_layout_" + tab_id].cells(field_properties_cell_id).collapse();
                });
                break;
            default:
                break;
        }
    }

    /**
     * Adds provided data as row in pool grid
     * @param {String} tab_id Tab ID
     * @param {Object} data   Data to add in row
     */
    function add_row_back_to_pool_grid(tab_id, data) {
        var move_to_tab_id = (data.header_detail == 'h') ? 'header_pool' : 'detail_pool';
        var move_to_group_id = (data.udf_or_system == 's') ? 'System' : (data.udf_or_system == 't') ? 'UDT' : 'UDF';
        var pool_tab_id = setup_deal_template[tab_id].pools_tab.tabs(move_to_tab_id).getId();
        var grid_obj = setup_deal_template[tab_id].pools_grid[pool_tab_id];
        var search_result = grid_obj.findCell(move_to_group_id, 0, true);

        var row_data = [
            data.org_label,
            data.id,
            data.field_type,
            data.header_detail,
            data.system_required,
            data.sql_string,
            data.udf_or_system,
            data.field_disabled,
            data.insert_required,
            data.hide_control,
            data.default_value,
            data.update_required,
            data.value_required
        ];
        grid_obj.addRow(grid_obj.uid(), row_data, 0, search_result[0][0]);

    }
    //## Enable Drag and Drop feature in Tabbar Tabs
    setup_deal_template.enable_tab_dnd = function() {
        // Make all tabs draggable
        $('.dhxtabbar_tab')
            .not('[id^="tab_"]')
            .not('[id^="template_detail_n"]')
            .not('[id^="other_tab"]')
            .not('[id^="header_pool"]')
            .not('[id^="detail_pool"]')
            .attr({
                'ondragstart': 'setup_deal_template.dragStart(event)',
                'ondragend': 'setup_deal_template.dragEnd(event)',
                'draggable': 'true'
            });

        // Add Drag Enter event in all other tabs except the dragged tab
        setup_deal_template.dragStart = function(e) {
            dragged_tab_changed_id = e.target.id = 'test';
            $(e.target).siblings('.dhxtabbar_tab').not('[id^="template_detail_n"]').not('[id^="other_tab"]').attr({'ondragenter': 'setup_deal_template.dragEnter(event)'})
        }

        // Remove added fake tab after drag end
        setup_deal_template.dragEnd = function(e) {
            setTimeout(function() {
                $('.test').remove();
                
                if ($('#' + dragged_tab_changed_id).length > 0) {
                    var tab_id = $('#' + dragged_tab_changed_id)[0]['_tabId'];
                    $('#test').attr('id', tab_id);   
                    $('.dhxtabbar_tab').attr('ondragenter', '');
                }
            }, 1);
        }

        // To make droppable in Destination DIV
        setup_deal_template.dragOver = function(e) {
            e.preventDefault();
        }

        // Add fake div to drop the dragged tab
        setup_deal_template.dragEnter = function(e) {
            $('.test').remove();
            // Class check to fix weird issue in firefox
            if ($(e.target).hasClass('dhxtabbar_tab_text')) {
                if ($(e.target).parent().prev('.dhxtabbar_tab').attr('id') !== 'test') {
                    $(e.target).parent().before( '<div ondrop="setup_deal_template.drop(event)" ondragover="setup_deal_template.dragOver(event)" class="dhxtabbar_tab test" style="width:50px"></div>');
                }

                if ($(e.target).parent().next('.dhxtabbar_tab').attr('id') !== 'test') {
                    $(e.target).parent().after( '<div ondrop="setup_deal_template.drop(event)" ondragover="setup_deal_template.dragOver(event)" class="dhxtabbar_tab test" style="width:50px"></div>')
                }
            } else {
                if ($(e.target).parent().parent().prev('.dhxtabbar_tab').attr('id') !== 'test') {
                    $(e.target).parent().parent().before( '<div ondrop="setup_deal_template.drop(event)" ondragover="setup_deal_template.dragOver(event)" class="dhxtabbar_tab test" style="width:50px"></div>');
                }

                if ($(e.target).parent().parent().next('.dhxtabbar_tab').attr('id') !== 'test') {
                    $(e.target).parent().parent().after( '<div ondrop="setup_deal_template.drop(event)" ondragover="setup_deal_template.dragOver(event)" class="dhxtabbar_tab test" style="width:50px"></div>')
                }
            }
        }

        // Add dragged tab in fake tab and unwrap it to make it real
        setup_deal_template.drop = function(ev) {
            ev.preventDefault();
            ev.target.appendChild(document.getElementById(dragged_tab_changed_id));

            var tab_id = $('#' + dragged_tab_changed_id)[0]['_tabId'];
            $('#test').unwrap();
            $('#test').attr('id', tab_id);
            $('.dhxtabbar_tab').attr('ondragenter', '');
        }
    }

    function attach_data_view_events(key, f_key, json) {
        /**
         Template Items attributs
         type, label, value, insert_required, dropdown_json
         */
        data_view_obj[key][f_key] = new dhtmlXDataView({
            container: "data_container_" + key + f_key,
            type: {
                template: function(item){
                    required_label = [
                        'source_deal_type_id',
                        'physical_financial_flag',
                        'header_buy_sell_flag',
                        'deal_category_value_id',
                        'source_system_id'
                    ].indexOf(item.id) != -1 ? ' <span style="color:red;">*</span>' : '';

                    var label = appendUDF(item.label, item.id) + required_label;
                    var item_type = setup_deal_template.resolve_field_type(item.field_type);
                    var html = '<div><div><label>' + label + '</label></div>' +
                        '<div class="dhxform_control">';
                    if (item_type == "input" || item_type == "calendar" || item_type == "phone")
                        html += '<input style="width:166px;" class="field_click" type="text" value="' + item.default_value + '" />';
                    else if (item_type == "combo") {
                        html += '<select class="field_click" style="width:170px;">';
                        html += '<option value=""></option>';
                        if (item.dropdown_json != undefined) {
                            JSON.parse(item.dropdown_json).forEach(function (data) {
                                html += '<option value="' + data.value + '"' + (item.default_value == data.value ? "selected" : "" ) + ">" + data.text + "</option>";
                            });
                        }
                        html += "</select>";
                    } else if (item_type == "checkbox")
                        html += '<input class="field_click" type="checkbox"' + (item.value == "y" ? "checked" : "") + " />";

                    html += "</div><div>";

                    if(item.show_req_validation) {
                        html += '<span style="color:red;">' + get_locale_value('Required Field') + '</span>';
                    }

                    // html += '<span style="color:grey;"> '+(item.disabled == "y" ? "(Disabled)" : "" )+" </span>";
                    // if (is_udf_tab == "n")
                    //     html += '<span style="color:grey;"> '+(item.udf_template_id != "" ? "(UDF)" : "" )+" </span>";
                    html += "</div></div>";
                    return html;
                },
                template_edit: '<textarea class=dhx_item_editor bind=obj.label>',
                padding: 10,
                height: 40,
                width: 170,
            },
            // tooltip: {
            //     template: "<b>Original Label: #original_label#</b>"
            // },
            drag: true,
            select: true,
            height: "auto",
        });

        data_view_obj[key][f_key].attachEvent("onXLE", function () {
            var count = data_view_obj[key][f_key].dataCount();
            for (i = 0; i < count; i++) {
                var id = data_view_obj[key][f_key].idByIndex(i);
                var data = data_view_obj[key][f_key].get(id);
                data.field_seq = i + 1;
            }
        });

        data_view_obj[key][f_key].attachEvent("onBeforeDrag", function(context, ev) {
            if (!data_view_obj[key][f_key].isSelected(context.start)) return false;

            if(context.source.length > 1) {
                context.source.sort(function(a,b) {
                    return a - b;
                });
            }
        });

        data_view_obj[key][f_key].attachEvent("onItemClick", function (id, ev, html){
            scroll_to = $('#data_container_' + key).scrollTop();
            return true;
        });

        data_view_obj[key][f_key].attachEvent("onSelectChange", function(sel_arr) {
            setup_deal_template.load_field_properties(sel_arr[0], data_view_obj[key][f_key]);
            var data = data_view_obj[key][f_key].get(sel_arr[0]);
            var find_dom = (data.field_type == 'd') ? 'select' : 'input';
            if (typeof scroll_to !== 'undefined')
                $('#data_container_' + key).scrollTop(scroll_to);
        });

        data_view_obj[key][f_key].attachEvent("onItemDblClick", function (id, ev, html) {
            var tab_id = setup_deal_template.tabbar.getActiveTab();
            setup_deal_template.details_layout["details_layout_" + tab_id].cells(field_properties_cell_id).expand();
            setup_deal_template.details_layout["details_layout_" + tab_id].cells(field_properties_cell_id).showArrow();
            return true;
        });

        //## Drag from grid into the dataview
        data_view_obj[key][f_key].attachEvent("onBeforeDrop",function(context) {
            if (context.from != data_view_obj[key][f_key]) {
                var drag_source = context.from.getUserData("", "grid_id");
                if (drag_source == "detail_pool") {
                    show_messagebox("This field cannot be added in this tab.");
                    return false;
                }

                if (drag_source == "header_pool") {
                    var grid_row_data = context.from.getRowData(context.source);
                    var udf_or_system = grid_row_data.udf_or_system;
                    var label = grid_row_data.label;
                    var field_id = grid_row_data.id;

                    // If udf_or_system is 't' then it is UDT so we need to add new tab and a grid in it
                    if (udf_or_system == 't') {
                        var tab_id = setup_deal_template.tabbar.getActiveTab();
                        var tab_ids = setup_deal_template.details_tab[tab_id].getAllTabs();
                        
                        var new_tab_id = (new Date()).valueOf();
                        setup_deal_template.details_tab[tab_id].addTab(new_tab_id, label, null, tab_ids.length-1, true, false)
                        setup_deal_template.details_tab[tab_id].t[new_tab_id].tab.id = String(new_tab_id);
                        setup_deal_template.details_tab[tab_id].cells(new_tab_id).setUserData('user_data', 'y_n');
                        inner_tab_context_menu['header'].addContextZone(String(new_tab_id));
                        setup_deal_template.details_tab[tab_id].details_layout = {};
                        setup_deal_template.details_tab[tab_id].details_layout = setup_deal_template.details_tab[tab_id].cells(new_tab_id).attachLayout("1C");
                        setup_deal_template.details_tab[tab_id].details_layout.cells("a").hideHeader();
                        setup_deal_template.details_tab[tab_id].details_layout.cells("a").setText(label);
                        global_udt_grid_obj = setup_deal_template.details_tab[tab_id].details_layout.cells("a").attachGrid();
                        global_udt_grid_id = field_id;
                        global_udt_grid_label = label;
                        
                        data = {
                            "action": "spa_user_defined_tables",
                            "flag": "g",
                            "udt_id": field_id
                        };

                        adiha_post_data('return_array', data, '', '', 'create_udt_grid', '');

                        context.from.deleteRow(context.source);
                        return false;
                    }

                    var field_type = grid_row_data.field_type;
                    var header_detail = grid_row_data.header_detail;
                    var sql_string = grid_row_data.sql_string;
                    setup_deal_template.options_to_load = {};

                    if (field_type == 'd' || field_type == 'c') {
                        var data = {
                            "action": "spa_setup_deal_template",
                            "flag": "o",
                            "sql_string": sql_string.replace(/'/g, "'")
                        };
                        adiha_post_data("return_array", data, "", "", "setup_deal_template.load_dropdown_options");
                        setup_deal_template.options_to_load['dataview_obj'] = this;
                        setup_deal_template.options_to_load['dataview_item'] = field_id;
                    }

                    var system_required = grid_row_data.system_required;
                    var field_disabled = grid_row_data.is_disable;
                    var insert_required = 'y';
                    var hide_control = grid_row_data.hide_control;
                    var default_value = grid_row_data.default_value;

                    if (field_type == 'a') {
                        default_value != '' ? dates.convert_to_user_format(default_value) : ''
                    }

                    var update_required = 'y';
                    var value_required = grid_row_data.value_required;
                    var tab_id = setup_deal_template.tabbar.getActiveTab();
                    var field_group_id = setup_deal_template.details_tab[tab_id].getActiveTab();

                    this.add({
                        org_label: label,
                        label: label,
                        type: field_type,
                        id : field_id,
                        field_type: field_type,
                        header_detail: header_detail,
                        system_required: system_required,
                        sql_string: sql_string,
                        udf_or_system: udf_or_system,
                        disabled: field_disabled,
                        insert_required: insert_required,
                        hide_control: hide_control,
                        default_value: default_value,
                        update_required: update_required,
                        value_required: value_required,
                        field_group_id: field_group_id
                    }, this.indexById(context.target||this.last() + 1));
                    context.from.deleteRow(context.source);

                    this.select(field_id);
                    this.callEvent("onItemDblClick", [field_id]);
                    this.show(field_id);
                    return false;
                }
            }
            return true;
        });

        data_view_obj[key][f_key].parse(json, "json");
        data_view_obj[key][f_key].sort(function(a,b) {return parseInt(a.field_seq) > parseInt(b.field_seq) ? 1 : -1;}, "asc");
        //Set user data
        if (String(f_key).indexOf("template_detail_n") > -1)
            data_view_obj[key][f_key].data_view_type = 'd';
        else
            data_view_obj[key][f_key].data_view_type = 'h';

        data_view_obj[key][f_key].on_click.field_click = function(e) {
            var itemId = this.locate(e);
            var a = this;
            var node_name = e.target.nodeName.toLowerCase();
            if (node_name == "input") {
                var type = $(e.target).attr("type").toLowerCase();
                if (type == "text" || type == "date") {
                    $(e.target).change(function () {
                        a.get(itemId).default_value = (e.target||e.srcElement).value;
                    });
                } else if (type == "checkbox") {
                    a.get(itemId).default_value = ((e.target||e.srcElement).checked == true ? "y" : "n");
                } else if (type == "radio") {
                    a.get(itemId).default_value = (e.target||e.srcElement).value;
                }
            } else if (node_name == "select") {
                $(e.target).change(function () {
                    a.get(itemId).default_value = (e.target||e.srcElement).value;
                });
            }
        };
    }

    function create_udt_grid(result) {
        var grid_col_ids = [];
        var grid_header = [];
        var grid_col_width = [];
        var grid_col_visibility = [];

        if (grid_retrieve_mode) {
            grid_retrieve_mode = false;
            grid_col_ids = result[0][2];
            grid_header = result[0][3];
            grid_col_visibility = result[0][9];
            grid_col_width = result[0][10];
        } else {
            for (var i = 0; i < result.length; i++) {
                grid_col_ids.push(result[i][2]);
                grid_header.push(result[i][3]);
                grid_col_width.push('120');

                //Hide Identity Column && Foreign/ Reference Column
                if (result[i][10] == 0 && (result[i][19] == 0 || result[i][19] == null)) {
                    grid_col_visibility.push(false);
                } else {
                    grid_col_visibility.push(true);
                }
            }
        }
        
        global_udt_grid_obj.setHeader(grid_header.toString());
        global_udt_grid_obj.setColumnIds(grid_col_ids.toString());
        global_udt_grid_obj.setInitWidths(grid_col_width.toString());
        global_udt_grid_obj.init();
        global_udt_grid_obj.setColumnsVisibility(grid_col_visibility.toString());
        global_udt_grid_obj.enableHeaderMenu();
        global_udt_grid_obj.setUserData("","grid_id", global_udt_grid_id);
        global_udt_grid_obj.setUserData("","grid_label", global_udt_grid_label);
        
        enter_edit_grid_header();
        setup_deal_template.enable_tab_dnd();
    }

    function enter_edit_grid_header() {
        $('.dhxtabbar_cont').find('.hdrcell').dblclick(function(event){
            var original_label = $(this).text().trim();
            if (original_label == '') return false;
            // $('.hdrcell').has('.manual_edit').text($('.hdrcell').has('.manual_edit').children().val());
            $(this).html('<input onfocus="this.value = this.value;" class="manual_edit" type="text" value="' + original_label + '">');
            $(this).children().focus();
            $(this).children().blur(function(){
                $(this).parent().text($(this).val());
            });
        });

        // Exit Edit Mode on Enter Click
        $('.hdrcell').delegate('.manual_edit', 'keyup', function (e) {
            if (e.keyCode == 13) {
                $(this).parent().text($(this).val());
            }
        });
    }

    setup_deal_template.load_dropdown_options = function(result) {
        if (result) {
            var dv_obj = setup_deal_template.options_to_load['dataview_obj'];
            var id = setup_deal_template.options_to_load['dataview_item'];
            var data = dv_obj.get(id);
            data.dropdown_json = result[0][0];
            dv_obj.refresh(id);
        }
        delete setup_deal_template.options_to_load;
    }

    setup_deal_template.resolve_field_type = function(shortcode, is_grid) {
        var field_type_array = [];

        switch(shortcode) {
            case "t":
                field_type_array.push("input");
                field_type_array.push("ed");
                break;
            case "d":
            case "c":
                field_type_array.push("combo");
                field_type_array.push("combo");
                break;
            case "a":
                field_type_array.push("calendar");
                field_type_array.push("dhxCalendarA");
                break;
            default:
                field_type_array.push("input");
                field_type_array.push("ed");
                break;
        }

        var field_type = (is_grid) ? field_type_array[1] : field_type_array[0];
        delete field_type_array;
        return field_type;
    }

    setup_deal_template.load_field_properties = function(id, data_view_obj) {
        var form_json = null;
        var tab_id = setup_deal_template.tabbar.getActiveTab();

        if (data_view_obj) {
            var data = data_view_obj.get(id);
        } else {
            var col_ind = setup_deal_template[tab_id].detail_grid.getColIndexById(id);
            var col_label = setup_deal_template[tab_id].detail_grid.getColLabel(col_ind);
            var data = setup_deal_template[tab_id].detail_grid['column_info'][id];
        }

        form_json = setup_deal_template.get_field_properties_data(id, data);

        var form_id = tab_id + '_layout_' + field_properties_cell_id;
        setup_deal_template[tab_id].properties_form = setup_deal_template.details_layout["details_layout_" + tab_id].cells(field_properties_cell_id).attachForm();
        setup_deal_template[tab_id].properties_form.loadStruct(get_form_json_locale(form_json), function() {
            var tab_id = setup_deal_template.tabbar.getActiveTab();
            setup_deal_template[tab_id].properties_form.setUserData("field_name", "dv_obj", data_view_obj);
            var inner_tab_id = setup_deal_template.details_tab[tab_id].getActiveTab();
            var move_to_combo_obj = setup_deal_template[tab_id].properties_form.getCombo("move_to");
            move_to_combo_obj.deleteOption(inner_tab_id);
            if (data.header_detail == 'd') {
                setup_deal_template[tab_id].properties_form.hideItem('move_to');
            } else {
                setup_deal_template[tab_id].properties_form.hideItem('show_form');
                setup_deal_template[tab_id].properties_form.hideItem('hide_control');
            }

        });

        if (data.system_required == "y")
            properties_toolbar[tab_id].disableItem("remove");
        else
            properties_toolbar[tab_id].enableItem("remove");
    }

    /**
     * Get Fields Properties
     * @param  {integer} item_id Id of Dataview item
     * @param  {object} data    Data of item
     * @return {object}         Data to show in Fields Properties
     */
    setup_deal_template.get_field_properties_data = function(item_id, data) {
        var field_properties_template = _.template($('#field_properties_template').text());
        var org_field_name = data.org_label;
        var field_name = data.label;
        var show_insert = (data.insert_required == "y") ? true : false;
        var show_update = (data.update_required == "y") ? true : false;
        var value_req = (data.value_required == "y") ? true : false;
        var disable = (data.disabled == "y") ? true : false;
        var hide_control = (data.hide_control == "y") ? true : false;
        var show_form = (data.show_in_form == "y") ? true : false;
        var field_id = item_id;
        var tab_id = setup_deal_template.tabbar.getActiveTab();
        var move_to_dropdown = setup_deal_template[tab_id].move_to_json;
        formData = field_properties_template({
            org_field_name: org_field_name,
            field_name: field_name,
            show_insert: show_insert,
            show_update: show_update,
            value_req: value_req,
            disable: disable,
            show_form: show_form,
            field_id: field_id,
            move_to: move_to_dropdown,
            hide_control: hide_control
        });
        formData = jQuery.parseJSON(formData);

        return formData;
    }

    
    /**
     * Repaints the Dataview
     * @param  {String} f_key Inner Header Tab ID
     */
    setup_deal_template.refresh_dataview_items = function(f_key) {
        // if (f_key == 'other_tab') return;
        var tab_id = setup_deal_template.tabbar.getActiveTab();
        var key = tab_id + "_n";

        if (!f_key)
            var f_key = setup_deal_template.details_tab[tab_id].getActiveTab();

        //Do nothing if the tabs are other tab and UDT tabs
        var attached_obj = setup_deal_template.details_tab[tab_id].tabs(f_key).getAttachedObject().cells('a').getAttachedObject();
        if (attached_obj instanceof dhtmlXGridObject|| attached_obj instanceof dhtmlXForm) return;

        data_view_obj[key][f_key].refresh();
    }

    /**
     * Saves Deal Template
     * @param  {integer} tab_id ID of tab being saved
     */
    setup_deal_template.save_deal_template = function(tab_id) {
        $('.field_click').blur();
        var win = setup_deal_template.tabbar.cells(tab_id);
        var object_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        object_id = ($.isNumeric(object_id)) ? object_id : ord(object_id.replace(" ", ""));

        var tab_obj = win.tabbar[object_id];
        var form_obj = setup_deal_template.details_layout["details_layout_" + tab_id].cells(details_cell_id).getAttachedObject();

        if (validate_form(form_obj)) {
            var save_xml = '<Root';
            var template_data = form_obj.getFormData();
            if (template_data.deal_template_description == "") template_data.deal_template_description = template_data.deal_template_name;

            var header_tab_obj = setup_deal_template.details_layout["details_layout_" + tab_id].cells(field_template_cell_id).getAttachedObject();

            var other_tab_layout_obj = header_tab_obj.cells('other_tab').getAttachedObject();
            var attached_form_obj = other_tab_layout_obj.cells('a').getAttachedObject();

            if (!validate_form(attached_form_obj)) return;

            var form_data = attached_form_obj.getFormData();
            template_data.show_cost_tab = form_data.show_cost_tab;
            template_data.show_detail_cost_tab = form_data.show_detail_cost_tab;
            template_data.show_udf_tab = form_data.show_udf_tab;
            delete form_data.show_cost_tab;
            delete form_data.show_detail_cost_tab;
            delete form_data.show_udf_tab;

            var template_options = '<TemplateOptions>';
            $.each(form_data, function(key, value) {
                var data = {"field_id": key, "field_value": value};
                template_options += setup_deal_template.build_xml(data, true);
            });
            template_options += '<Field field_id="is_active" field_value="' + template_data.is_active + '" />';
            template_options += '</TemplateOptions>';
            save_xml += setup_deal_template.build_xml(template_data) + '>';

            var detail_tabs = header_tab_obj.getAllTabs();
            save_xml += '<TemplateGroup>';
            var template_header = '<TemplateHeader>';
            var template_header_grid = '<TemplateHeaderGrid>';
            var validate_hardcoded_fields = '';
            var invalid_fields_tab_name = '';
            var invalid_date_fields = [];
            var header_non_empty_fields = ['source_deal_type_id', 'physical_financial_flag', 'header_buy_sell_flag', 'deal_category_value_id', 'source_system_id'];

            $.each(detail_tabs, function(index, value) {
                // if (validate_hardcoded_fields != '') return false;
                if (value == 'other_tab') {
                    return;
                }

                var tab_index = header_tab_obj.tabs(value).getIndex();
                var tab_name = header_tab_obj.tabs(value).getText();
                var tab_user_data = header_tab_obj.tabs(value).getUserData('user_data');
                tab_user_data = (tab_user_data == null) ? 'n_n' : tab_user_data;
                var tab_show_in_form = tab_user_data.split('_')[1];
                save_xml += '<Group id="' + value + '" name="' + tab_name + '" seq="' + (tab_index + 1) + '" show_in_form="' + tab_show_in_form + '"></Group>';
                var layout_obj = header_tab_obj.cells(value).getAttachedObject();

                layout_obj.forEachItem(function(cell) {
                    var attached_obj = cell.getAttachedObject();

                    if (attached_obj instanceof dhtmlXGridObject) {
                        var grid_id = attached_obj.getUserData("", "grid_id");
                        var no_cols = attached_obj.getColumnsNum();
                        template_header_grid += '<Grid id="' + grid_id + '" tab_id="' + value + '">'
                        for (i = 0; i < no_cols; i++) {
                            var seq = i + 1;
                            var col_id = attached_obj.getColumnId(i);
                            var col_name = attached_obj.getColLabel(i);
                            var col_visibility = attached_obj.isColumnHidden(i);
                            var is_hidden = (col_visibility == true ? 'y' : 'n');
                            template_header_grid += '<GridCol id="' + col_id + '" name="' + escapeXML(col_name) + '" is_hidden="' + is_hidden + '" seq="' + seq +'"></GridCol>';
                        }
                        template_header_grid += '</Grid>'
                    } else {
                    //Template Header Fields
                    $.each($(attached_obj).children("span").children("div"), function() {
                        // if (validate_hardcoded_fields != '') return false;
                        var attached_obj = data_view_obj[tab_id + '_n'][value];

                        var count = attached_obj.dataCount();
                        if (count > 0) {
                            for (i = 0; i < count; i++) {
                                var id = attached_obj.idByIndex(i);
                                var data = attached_obj.get(id);
                                data.field_seq = i + 1;
                                var form_element = $(attached_obj.$view.childNodes[i]).find('.dhxform_control');
                                var field_value = form_element.children().val();
                                var field_check = data.id;
                                    
                                form_element.prev().css('color', 'black');
                                form_element.next().text('').css('color', 'black');
                                data.show_req_validation = false;

                                if (data.field_type === 'a' && field_value != '') {

                                    if (!is_valid_user_date_format(field_value, user_date_format)) {
                                        invalid_date_fields.push(data.label);
                                        form_element.prev().css('color', 'red');
                                    }
                                }

                                if (header_non_empty_fields.indexOf(field_check) != -1) {

                                    if (field_value == '') {
                                        validate_hardcoded_fields = validate_hardcoded_fields == '' ? data.label : validate_hardcoded_fields;
                                        invalid_fields_tab_name = invalid_fields_tab_name == '' ? tab_name : invalid_fields_tab_name ;
                                        form_element.prev().css('color', 'red');
                                        form_element.next().text(get_locale_value('Required Field')).css('color', 'red')
                                            .prev().children().focus();
                                        data.show_req_validation = true;
                                        break;
                                    }
                                }
                                template_header += setup_deal_template.build_xml(data, true);
                            }
                        }
                    });
                    }
                });
            });

            if (invalid_date_fields.length > 0) {
                success_call('Invalid Date format', 'error')
                return;
            }

            if (validate_hardcoded_fields != '') {
                show_messagebox('<b>' + validate_hardcoded_fields + '</b> in <b>' + invalid_fields_tab_name + '</b> tab cannot be blank.');
                return;
            }

            template_header += '</TemplateHeader>';
            template_header_grid += '</TemplateHeaderGrid>';
            save_xml += '</TemplateGroup>';
            save_xml += template_header + template_header_grid + template_options;

            //## Add Detail Data
            var detail_grid_data_xml = "<DetailGrid>";
            var template_detail_grid_obj = setup_deal_template[tab_id].detail_grid;
            var ids = template_detail_grid_obj.getAllRowIds();
            if (ids != "") {
                var changed_ids = new Array();
                changed_ids = ids.split(",");
                var grid_validation_pass = true;
                var grid_non_empty_columns = new Array('deal_volume_frequency', 'deal_volume_uom_id', 'fixed_float_leg', 'buy_sell_flag', 'physical_financial_flag', 'deal_date');
                var grid_numeric_columns = [
                    'deal_volume', 'fixed_price', 'fixed_cost', 'rec_price', 'deal_reference_type_id', 'close_reference_id',
                    'broker_unit_fees', 'broker_fixed_cost', 'book_transfer_id', 'option_strike_price', 'settlement_volume',
                    'price_adder', 'price_multiplier', 'day_count_id', 'process_deal_status', 'multiplier', 'price_adder2',
                    'volume_multiplier2', 'total_volume', 'capacity'
                ];
                var grid_total_cols = template_detail_grid_obj.getColumnsNum();
                template_detail_grid_obj.clearSelection();
                $.each(changed_ids, function(index, value) {
                    detail_grid_data_xml += "<GridRow ";
                    var fixed_float_leg = '', physical_financial_flag = '', location_id = '', curve_id = '';
                    for (var cellIndex = 0; cellIndex < grid_total_cols; cellIndex++) {
                        if (!grid_validation_pass) break;
                        var column_id = template_detail_grid_obj.getColumnId(cellIndex);
                        var column_value = template_detail_grid_obj.cells(value,cellIndex).getValue();
                        template_detail_grid_obj.cells(value,cellIndex).cell.classList.remove('dhtmlx_validation_error')
                        if (grid_non_empty_columns.indexOf(column_id) != -1 && (column_value == '' || column_value == 'NULL')) {
                            grid_validation_pass = false;
                            var column_label = template_detail_grid_obj.getColLabel(cellIndex);
                            template_detail_grid_obj.cells(value,cellIndex).cell.classList.add('dhtmlx_validation_error')
                            
                            show_messagebox('Data Error in <b>Deal Detail</b> grid.\nPlease check data in column <b>' + column_label + '</b> and resave.');
                            break;
                        }
                        if (column_value != '' && column_value != 'NULL') {
                            if (grid_numeric_columns.indexOf(column_id) != -1 && isNaN(column_value)) {
                                grid_validation_pass = false;
                                var column_label = template_detail_grid_obj.getColLabel(cellIndex);
                                template_detail_grid_obj.cells(value,cellIndex).cell.classList.add('dhtmlx_validation_error');
                                show_messagebox('Data Error in <b>Deal Detail</b> grid.\nPlease check data in column <b>' + column_label + '</b> and resave.');
                                break;
                            }
                        }

                        if (column_id == 'fixed_float_leg') fixed_float_leg = column_value;
                        if (column_id == 'physical_financial_flag') physical_financial_flag = column_value;
                        if (column_id == 'curve_id') curve_id = column_value;
                        if (column_id == 'location_id') location_id = column_value;

                        detail_grid_data_xml += " " + column_id + '="' + column_value + '"';
                    }

                    if (physical_financial_flag == 'p' && location_id == '' && grid_validation_pass) {
                        show_messagebox('Location cannot be blank.');
                        grid_validation_pass = false;
                    }
                    if (fixed_float_leg == 't' && curve_id == '' && grid_validation_pass) {
                        show_messagebox('Index cannot be blank.');
                        grid_validation_pass = false;
                    }

                    detail_grid_data_xml += " ></GridRow> ";
                });
            }
            
            if (!grid_validation_pass) return;
            detail_grid_data_xml += "</DetailGrid>";
            var deleted_detail_xml = template_detail_grid_obj.getUserData("", "deleted_xml");
            if (deleted_detail_xml != "")
                detail_grid_data_xml += "<DeletedDetail>" + deleted_detail_xml + "</DeletedDetail>";
            
            // Add Detail UDT Tabs information
            var is_detail_udt_exists = false;
            var detail_udt_group = "<DetailUdtGroup>";
            var template_detail_udt_grid = "<DetailUdtGrid>";
            setup_deal_template[tab_id].details_tab.forEachTab(function(tab) {
                var detail_tab_id = tab.getId();
                if (detail_tab_id == "template_detail_n") return;

                is_detail_udt_exists = true;
                var tab_index = tab.getIndex();
                var tab_name = tab.getText();
                detail_udt_group += '<Group id="' + detail_tab_id + '" name="' + tab_name + '" seq="' + (tab_index) + '"></Group>';
                var layout_obj = tab.getAttachedObject();

                layout_obj.forEachItem(function(cell) {
                    var attached_obj = cell.getAttachedObject();

                    if (attached_obj instanceof dhtmlXGridObject) {
                        var grid_id = attached_obj.getUserData("", "grid_id");
                        var no_cols = attached_obj.getColumnsNum();
                        template_detail_udt_grid += '<Grid id="' + grid_id + '" tab_id="' + detail_tab_id + '">'
                        for (i = 0; i < no_cols; i++) {
                            var seq = i + 1;
                            var col_id = attached_obj.getColumnId(i);
                            var col_name = attached_obj.getColLabel(i);
                            var col_visibility = attached_obj.isColumnHidden(i);
                            var is_hidden = (col_visibility == true ? 'y' : 'n');
                            template_detail_udt_grid += '<GridCol id="' + col_id + '" name="' + escapeXML(col_name) + '" is_hidden="' + is_hidden + '" seq="' + seq +'"></GridCol>';
                        }
                        template_detail_udt_grid += '</Grid>'
                    }
                });
            });
            detail_udt_group += "</DetailUdtGroup>";
            template_detail_udt_grid += "</DetailUdtGrid>";

            // Template Detail FIelds
            save_xml += '<TemplateDetail>';
            $.each(template_detail_grid_obj.column_info, function(key, data) {
                var column_index = template_detail_grid_obj.getColIndexById(key);
                data.field_seq = column_index + 1;
                // Force Leg column to be shown in update mode to support UDT in Deal Detail
                if (is_detail_udt_exists && data.id == 'leg') {
                    data.update_required = 'y';
                }
                save_xml += setup_deal_template.build_xml(data, true);
            });
            save_xml += '</TemplateDetail>';

            save_xml += detail_grid_data_xml + detail_udt_group + template_detail_udt_grid + '</Root>';
            
            var data = {
                "action": "spa_setup_deal_template",
                "flag": "i",
                "xml": save_xml
            };
            adiha_post_data("alert", data, "", "", "setup_deal_template.post_callback");
        }
    }

    setup_deal_template.post_callback = function(result) {
        if (result[0].errorcode == "Success") {
            var tab_id = setup_deal_template.tabbar.getActiveTab();
            setup_deal_template.tabbar.tabs(tab_id).setText(result[0].recommendation);
            setup_deal_template.refresh_grid("", setup_deal_template.open_tab);
            setup_deal_template[tab_id].detail_grid.setUserData("", "deleted_xml", "");
        }
    }

    setup_deal_template.build_xml = function(data, is_field) {
        var xml = '';
        if (is_field) xml += '<Field';

        $.each(data, function(key, value) {
            if (key == "dropdown_json" || key == "sql_string"
                || key == "field_template_type" || key == "type"
                || key == "field_type" || key == "$selected" || key == "$template")
                return;

            xml += ' ' + key + '="' + value + '"';
        });
        if (is_field) xml += '/>';
        return xml;
    }

    setup_deal_template.delete_deal_template = function() {
        var selected_row_id = setup_deal_template.grid.getSelectedRowId();
        var template_id_index = setup_deal_template.grid.getColIndexById('field_template_id');
        if (selected_row_id != null) {
            confirm_messagebox("Are you sure you want to delete?", function () {
                selected_row_id = selected_row_id.split(',');
                var field_template_id = [];
                selected_row_id.forEach(function(val) {
                    var template_id = setup_deal_template.grid.cells(val, template_id_index).getValue();
                    field_template_id.push(template_id);
                });
                field_template_id = field_template_id.toString();
                var data = {
                    'action': 'spa_setup_deal_template',
                    'flag': 'd',
                    'del_field_template_ids': field_template_id
                };
                adiha_post_data("return_array", data, "", "", "setup_deal_template.post_delete_callback");
            });
        }
    }

    function create_tabbar_context_menu(tab_obj, tab_id, attach_area, key) {
        //## Create Context Menu With options add/edit/delete tab
        inner_tab_context_menu[attach_area] = new dhtmlXMenuObject();
        inner_tab_context_menu[attach_area].setIconsPath(js_image_path + "dhxtoolbar_web/");
        inner_tab_context_menu[attach_area].renderAsContextMenu();
        inner_tab_context_menu[attach_area].loadStruct([
            {id:"add", text:"Add Tab", title: "Add Tab"},
            {id:"rename", text:"Rename Tab", title: "Rename Tab"},
            {id:"delete", text:"Delete Tab", title: "Delete Tab"},
            {id:"tab", text:"Show as Deal Tab", title: "Show as Deal Tab", type: "checkbox"}
        ]);
        inner_tab_context_menu[attach_area].attachEvent("onBeforeContextMenu", function(zoneId, ev) {
            //if (attach_area == 'detail' && zoneId == "template_detail_n") return false;
            if (zoneId.indexOf("template_detail_n") > -1) return false;
            tab_obj.cells(zoneId).setActive();

            var user_data = tab_obj.tabs(zoneId).getUserData('user_data');
            if (user_data == null) {
                user_data = 'n_n';
            }
            var user_data_array = user_data.split("_");

            if (user_data_array[0] != "y") {
                inner_tab_context_menu[attach_area].hideItem('tab');
            } else {
                inner_tab_context_menu[attach_area].showItem('tab');

                if (user_data_array[1] == "y") {
                    inner_tab_context_menu[attach_area].setCheckboxState('tab', true);
                } else {
                    inner_tab_context_menu[attach_area].setCheckboxState('tab', false);
                }
            }

            return true;
        });

        if (attach_area == 'detail') {
            inner_tab_context_menu[attach_area].hideItem('add');
            inner_tab_context_menu[attach_area].hideItem('tab');
            tab_obj.forEachTab(function(tab) {
                tab_zone_id = tab.getId();
                tab_obj.t[tab_zone_id].tab.id = tab_zone_id;
                inner_tab_context_menu['detail'].addContextZone(tab_zone_id);
            });
        }

        //## Attach OnClick Event on Context Menu
        inner_tab_context_menu[attach_area].attachEvent("onClick", function(id, zoneId) {
            if (id == 'tab') return;
            switch(id) {
                case "add":
                    var new_tab_name = get_locale_value("New Tab");
                    var new_id = (new Date()).valueOf();
                    var inner_tab_id = new_id;
                    break;
                case "rename":
                    var inner_tab_id = tab_obj.getActiveTab();
                    var new_tab_name = tab_obj.tabs(inner_tab_id).getText();
                    break;
                case "delete":
                    var message = "Are you sure you want to delete?";
                    confirm_messagebox(message, function() {
                        var proceed = true;

                        var attached_obj = tab_obj.cells(zoneId).getAttachedObject().cells('a').getAttachedObject();
                        if (attached_obj == undefined) {
                            tab_obj.cells(zoneId).close();
                            delete setup_deal_template[tab_id].inner_tab_layout[zoneId];
                            return true;
                        }
                        // UDT Grid
                        if (attached_obj instanceof dhtmlXGridObject) {
                            var grid_id = attached_obj.getUserData("", "grid_id");
                            var grid_label = attached_obj.getUserData("", "grid_label");
                            tab_obj.cells(zoneId).close();
                            delete setup_deal_template[tab_id].inner_tab_layout[zoneId];
                            
                            var data = {
                                org_label : grid_label,
                                id : grid_id,
                                field_type : "",
                                header_detail : (attach_area == "header" ? "h" : "d"),
                                system_required : "n",
                                sql_string : "",
                                udf_or_system : "t",
                                field_disabled : "n",
                                insert_required : "n",
                                hide_control : "n",
                                default_value : "",
                                update_required : "n",
                                value_required : "n"
                            }
                            add_row_back_to_pool_grid(tab_id, data);
                            return;
                        }
                        
                        var data = data_view_obj[tab_id + "_n"][zoneId].serialize();
                        $.each(data, function(key, value) {
                            if (value.system_required == "y") {
                                proceed = false;
                                return false;
                            }
                        });

                        if (proceed) {
                            tab_obj.cells(zoneId).close();
                            //## Delete Tab Option form Move to dropdown And delete tab dataview
                            delete data_view_obj[tab_id + "_n"][zoneId];
                            delete setup_deal_template[tab_id].inner_tab_layout[zoneId];
                            var move_to = JSON.parse(setup_deal_template[tab_id].move_to_json);
                            move_to.forEach(function (item, index) {
                                if (item.value == zoneId.replace("_" + tab_id, ""))
                                    move_to.splice(index, 1);
                            });

                            setup_deal_template[tab_id].move_to_json = JSON.stringify(move_to);
                        } else {
                            show_messagebox("Tab cannot be deleted, it contains system required fields.");
                        }
                    });
                    return;
                    break;
                default:
                    break;
            }

            var myForm;
            var myPop = new dhtmlXPopup();
            var formData = [
                {type: "settings", position: "label-top", labelWidth: ui_settings["fields_size"], inputWidth: ui_settings["fields_size"]},
                {type: "input", label: "Tab Name", name: "tab_name", value: new_tab_name, required: true, userdata:{"validation_message":"Required Field"}},
                {type: "button", value: "Ok"}
            ];

            myPop.attachEvent("onShow", function() {
                if (myForm == null) {
                    myForm = myPop.attachForm(get_form_json_locale(formData));
                    myForm.attachEvent("onButtonClick", function() {
                        var status = validate_form(myForm);
                        if (!status) return;
                        var tab_text = myForm.getItemValue("tab_name");
                        var dup_check = false;
                        tab_obj.forEachTab(function(tab){
                            if (strip(tab.getText()) == tab_text && tab.getId() != inner_tab_id) {
                                dup_check = true;
                                show_messagebox("Tab Name <b>" + tab_text + "</b> already exists");
                                return false;
                            }
                        });
                        if (dup_check) return;
                        if (id == "rename") {
                            tab_obj.tabs(inner_tab_id).setText(tab_text);
                            myPop.hide();
                            var a = JSON.parse(setup_deal_template[tab_id].move_to_json);
                            var b = a.map(function(key) {
                                if (key.value == inner_tab_id) key.text = tab_text;
                                return key;
                            });
                            setup_deal_template[tab_id].move_to_json = JSON.stringify(b);
                            return;
                        }
                        var tab_ids = tab_obj.getAllTabs();
                        tab_obj.addTab(inner_tab_id, tab_text, null, tab_ids.length-1, true, false);
                        tab_obj.t[inner_tab_id].tab.id = String(inner_tab_id);
                        inner_tab_context_menu[attach_area].addContextZone(String(inner_tab_id));
                        setup_deal_template[tab_id].inner_tab_layout[inner_tab_id] = tab_obj.cells(inner_tab_id).attachLayout("1C");
                        setup_deal_template[tab_id].inner_tab_layout[inner_tab_id].cells("a").hideHeader();
                        var append_html = '<div id="data_container_' + key + '" class="data_container_class"><span><div id="data_container_' + key + inner_tab_id + '" class="data_container_inner_class"></div></span></div>';
                        $("#field_data_view").append(append_html);
                        setup_deal_template[tab_id].inner_tab_layout[inner_tab_id].cells("a").attachObject("data_container_" + key);
                        attach_data_view_events(key, inner_tab_id, '');
                        var a = setup_deal_template[tab_id].move_to_json;
                        setup_deal_template[tab_id].move_to_json = a.substring(0, a.length-1) + ', {"value":"' + inner_tab_id + '", "text":"' + tab_text + '"}]'
                        setup_deal_template.enable_tab_dnd();
                        myPop.hide();
                    });
                }
                myForm.setFocusOnFirstActive();
            });

            myPop.attachEvent("onBeforeHide", function(type, ev, id){
                if (type == "click" || type == "esc") {
                    myPop.hide();
                    return true;
                }
            });

            var zoneOffset = $("#" + zoneId).offset();
            myPop.show(zoneOffset.left + 40, zoneOffset.top + 30, 0, 0);
        });

        inner_tab_context_menu[attach_area].attachEvent("onCheckboxClick", function(id, state, zoneId, cas) {
            var inner_tab_id = tab_obj.getActiveTab();
            tab_obj.tabs(inner_tab_id).setUserData('user_data', 'y_' + (!state ? 'y' : 'n'));

            return true;
        });
    }

    function strip(html) {
        var tmp = document.createElement("DIV");
        tmp.className = 'fake_div';
        tmp.innerHTML = html;
        var text = tmp.textContent || tmp.innerText || "";
        $(tmp).remove();
        return text;
    }
</script>

<!-- Field Properties Template -->
<script id="field_properties_template" type="text/template">
    [
    {"type": "settings", "position": "label-top"},                
    {"type": "input", "name": "org_field_name", "label": "Original Field Name", "disabled": true, "position": "label-top", "value": "<%= org_field_name %>","inputWidth":"<%= ui_settings['field_size'] %>", "offsetLeft": "<%= ui_settings['offset_left'] %>"},
    {"type": "newcolumn"},
    {"type": "input", "name": "field_name", "label": "Field Name", "required": true, "position": "label-top", "value": "<%= field_name %>","inputWidth":"<%= ui_settings['field_size'] %>", "offsetLeft": "<%= ui_settings['offset_left'] %>", "userdata": {"validation_message": "Required Field"}},
    {"type": "newcolumn"},
    {"type": "checkbox", "position": "label-right", "name": "show_insert", "label": "Show in Insert", "checked": "<%= show_insert %>", "inputWidth":"<%= ui_settings['field_size'] %>", "offsetLeft": "<%= ui_settings['offset_left'] %>", "offsetTop":"<%= ui_settings['checkbox_offset_top'] %>"},
    {"type": "newcolumn"},
    {"type": "checkbox", "position": "label-right", "name": "show_update", "label": "Show in Update", "checked": "<%= show_update %>", "inputWidth":"<%= ui_settings['field_size'] %>", "offsetLeft": "<%= ui_settings['offset_left'] %>", "offsetTop":"<%= ui_settings['checkbox_offset_top'] %>"},
    {"type": "newcolumn"},
    {"type": "checkbox", "position": "label-right", "name": "value_req", "label": "Value Required", "checked": "<%= value_req %>", "inputWidth":"<%= ui_settings['field_size'] %>", "offsetLeft": "<%= ui_settings['offset_left'] %>", "offsetTop":"<%= ui_settings['checkbox_offset_top'] %>"},
    {"type": "newcolumn"},
    {"type": "checkbox", "position": "label-right", "name": "disable", "label": "Disable", "checked": "<%= disable %>", "inputWidth":"<%= ui_settings['field_size'] %>", "offsetLeft": "<%= ui_settings['offset_left'] %>", "offsetTop":"<%= ui_settings['checkbox_offset_top'] %>"},
    {"type": "newcolumn"},
    {"type": "combo", "filtering":"true", "name": "move_to", "label": "Move to Tab", "position": "label-top", "options": <%= move_to %>, "inputWidth":"<%= ui_settings['field_size'] %>", "offsetLeft": "<%= ui_settings['offset_left'] %>"},
    {"type": "newcolumn"},
    {"type": "checkbox", "position": "label-right", "checked": "<%= show_form %>", "name": "show_form", "label": "Show in Form", "inputWidth":"<%= ui_settings['field_size'] %>", "offsetLeft": "<%= ui_settings['offset_left'] %>", "offsetTop":"<%= ui_settings['checkbox_offset_top'] %>"},
    {"type": "newcolumn"},
    {"type": "checkbox", "position": "label-right", "checked": "<%= hide_control %>", "name": "hide_control", "label": "Hide Column", "inputWidth":"<%= ui_settings['field_size'] %>", "offsetLeft": "<%= ui_settings['offset_left'] %>", "offsetTop":"<%= ui_settings['checkbox_offset_top'] %>"},
    {"type": "newcolumn"},
    {"type": "input", "name": "field_id", "label": "Field ID", "value": "<%= field_id %>", "hidden":1}
    ]
</script>

<style type="text/css">
    .data_container_class {
        width: 100%;
        height: 100%;
        overflow: auto;
        background-color: #f9f9f9;
    }

    .data_container_inner_class {
        width:100%;
        min-height:10px;
        height: 100% !important;
    }

    .dhx_dataview .dhx_dataview_default_item, .dhx_dataview .dhx_dataview_default_item_selected {
         border-right: 0px !important; 
         border-bottom: 0px !important; 
    }

    .dhx_dataview {
        overflow: auto !important;
    }

    .dhx_dataview_item:not(.dhx_dataview_default_item_selected) {
        background-color: #f9f9f9 !important;
    }
</style>
</html>