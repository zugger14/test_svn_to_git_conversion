<?php

/**
 * Route group screen
 * @copyright Pioneer Solutions
 */
?>
<!DOCTYPE html>
<html>

<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php require('../../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
<?php
$rights_setup_route = 10163900;
$rights_setup_route_iu = 10163910;
$rights_setup_route_del = 10163911;

list(
    $has_right_setup_route,
    $has_right_setup_route_iu,
    $has_right_setup_route_del
) = build_security_rights(
    $rights_setup_route,
    $rights_setup_route_iu,
    $rights_setup_route_del
);

$php_script_loc = $app_php_script_loc;
$layout_obj = new AdihaLayout();
$setup_routes_treegrid = new AdihaGrid();
$tabbar_obj = new AdihaTab();
$menu_obj = new AdihaMenu();
$form_obj = new AdihaForm();

$name_space = 'setup_routes';
$toolbar_name = 'toolbar_setup_routes';
$setup_routes_tree_name = 'setup_routes_treegrid';
$tabbar_name = 'setup_routes_details';
$form_name = 'frm_setup_routes';
$layout_name = 'setup_routes_layout';
$menu_name = 'setup_routes_menu';

$layout_json = '[
            {
                id:             "a",
                text:           "Routes",
                header:         true,
                width:          400,
                height:         500,
                collapse:       false,
                fix_size:       [false,null],
                undock:         true
            },
            {
                id:             "b",
                text:           "Detail",
                height:         60,
                header:         true,
                height:         500,
                collapse:       false,
                fix_size:       [false,null]
            }
        ]';

$menu_json = '[
            {id:"t1", text:"Edit", img:"edit.gif", items:[
                {id:"add_single_route", text:"Add Single Route", img:"add.gif", },
                {id:"add_group_route", text:"Add Group Route", img:"add.gif", },
                {id:"delete", text:"Delete", img:"trash.gif", },
                {id:"copy", text:"Copy", img:"copy.gif",}
            ]},
            {id:"t2", text:"Export", img:"export.gif", items:[
                {id:"excel", text:"Excel", img:"excel.gif"},
                {id:"pdf", text:"PDF", img:"pdf.gif"}
            ]},
            { id: "expand_collapse", img: "exp_col.gif", text: "Expand/Collapse", title: "Expand/Collapse"}
            ]';

echo $layout_obj->init_layout($layout_name, '', '2U', $layout_json, $name_space);
echo $layout_obj->attach_menu_cell($menu_name, 'a');
echo $layout_obj->attach_status_bar('a', true);
echo $layout_obj->attach_grid_cell($setup_routes_tree_name, 'a');
echo $layout_obj->attach_form($form_name, 'b');

echo $menu_obj->init_by_attach($menu_name, $name_space);
echo $menu_obj->load_menu($menu_json);
echo $menu_obj->attach_event('', 'onClick', $name_space . '.grid_toolbar_click');

/****************/
$sp_url = "EXEC spa_route_group 's'";
$grid_type = 'tg';
$grouping_column = 'Type,route_name';

echo $setup_routes_treegrid->init_by_attach($setup_routes_tree_name, $name_space);
echo $setup_routes_treegrid->set_header('Route Name,ID,Delivery Location,Primary/Secondary,Effective Date,Fuel Loss,Fuel Loss Group,Pipeline,Contract,Is Group,Contract ID');
echo $setup_routes_treegrid->set_widths('230,100,130,140,100,100,100,100,100,100,100');
echo $setup_routes_treegrid->split_grid(1);
echo $setup_routes_treegrid->set_column_types('tree,ro,ro,ro,ro,ro_no,ro,ro,ro,ro,ro,ron');
echo $setup_routes_treegrid->set_sorting_preference('str,int,str,str,str,str,int,str,str,str,str,int');
echo $setup_routes_treegrid->set_columns_ids('route_name,route_id,delivery_location,primary_secondary,effective_date,fuel_loss,fuel_loss_shrinkage_curve,pipeline,contract,is_group,contract_id');
echo $setup_routes_treegrid->set_search_filter(false, "#text_filter,#numeric_filter,#text_filter,#text_filter,#text_filter,#numeric_filter,#text_filter,#text_filter,#text_filter,#combo_filter,#numeric_filter");
echo $setup_routes_treegrid->set_column_visibility("false,true,false,false,true,true,true,true,true,true,true");
echo $setup_routes_treegrid->enable_paging(25, 'pagingArea_a');
echo $setup_routes_treegrid->attach_event('', 'onRowDblClicked', $name_space . '.setup_routes_treegrid_dblClicked');
echo $setup_routes_treegrid->return_init();
echo $setup_routes_treegrid->load_grid_data($sp_url, $grid_type, $grouping_column);
echo $setup_routes_treegrid->enable_multi_select();
echo $setup_routes_treegrid->load_grid_functions();

/****************/

echo $layout_obj->attach_tab_cell($tabbar_name, 'b');
echo $tabbar_obj->init_by_attach($tabbar_name, $name_space);
echo $tabbar_obj->enable_tab_close();
echo $layout_obj->close_layout();
$sp_url_delivery_loc = "EXEC spa_source_minor_location @flag = 'o', @location_name = 'M2, Gathering System, storage, Pool, DM'";
$fuel_loss_shrinkage_curve = "EXEC spa_route_group @flag = 'h', @route_order_in=1";
$sp_url_pipeline = "EXEC spa_source_counterparty_maintain @flag= 'n',@type_of_entity = -10021";
$sp_url_contract = "EXEC spa_contract_group @flag = 'r',@transportation_contract = 38402";
$delivery_loc_dropdown = $form_obj->adiha_form_dropdown($sp_url_delivery_loc, 0, 1, false, '', 2);

$fuel_loss_shrinkage_curve_dropdown = $form_obj->adiha_form_dropdown($fuel_loss_shrinkage_curve, 0, 1, false, '');
$pipeline_dropdown = $form_obj->adiha_form_dropdown($sp_url_pipeline, 0, 1, false, '', 2);
$contract_dropdown = $form_obj->adiha_form_dropdown($sp_url_contract, 0, 1, false, '', 2);
$primary_secondary_dropdown = '[
                                    {value:"p", text:"Primary"},
                                    {value:"s", text:"Secondary"}
                                ]';

$single_route_form_structure = '[
                                    {"type":"settings","position":"label-top"},
                                    {type: "block", blockOffset:' . $ui_settings['block_offset'] . ', list: 
                                        [{"type":"input","name":"route_name","label":"Route Name","tooltip":"Route Name",required:true,"validate":"NotEmpty","hidden":"false","disabled":"false","value":"","position":"label-top","offsetLeft":' . $ui_settings['offset_left'] . ',"labelWidth":"auto","inputWidth":' . $ui_settings['field_size'] . ',"userdata":{"validation_message":"Required Field."}},
                                        {"type":"newcolumn"},
                                        {"type":"combo","name":"delivery_location","label":"Delivery Location","tooltip":"Delivery Location",required:true,"validate":"ValidInteger","hidden":"false","disabled":"false","offsetLeft":' . $ui_settings['offset_left'] . ',"labelWidth":"auto","inputWidth":' . $ui_settings['field_size'] . ',"filtering":"true","options":' . $delivery_loc_dropdown . ',"userdata":{"validation_message":"Invalid Selection."}},
                                        {"type":"newcolumn"}, 
                                        {"type":"combo","name":"pipeline","label":"Pipeline","tooltip":"Pipeline",required:true,"validate":"ValidInteger","hidden":"false","disabled":"false","offsetLeft":' . $ui_settings['offset_left'] . ',"labelWidth":"auto","inputWidth":' . $ui_settings['field_size'] . ',"filtering":"true","options":' . $pipeline_dropdown . ',"userdata":{"validation_message":"Invalid Selection."}},
                                        {"type":"newcolumn"},
                                        {"type":"combo","name":"contract","label":"Contract","tooltip":"Contract",required:true,"validate":"ValidInteger","hidden":"false","disabled":"false","offsetLeft":' . $ui_settings['offset_left'] . ',"labelWidth":"auto","inputWidth":' . $ui_settings['field_size'] . ',"filtering":"true","options":' . $contract_dropdown . ',"userdata":{"validation_message":"Invalid Selection."}},
                                        {"type":"newcolumn"},
                                        {type:"hidden", name:"maintain_location_routes_id", value:"NULL"},
                                        {"type":"newcolumn"},
                                        {"type":"combo",name:"primary_secondary",required:true,label:"Primary/Secondary","tooltip":"Primary/Secondary","offsetLeft":' . $ui_settings['offset_left'] . ',"labelWidth":"auto","inputWidth":' . $ui_settings['field_size'] . ',options:' . $primary_secondary_dropdown . ',disabled:true},
                                        {"type":"newcolumn"},
                                        {"type":"input","name":"fuel_loss","label":"Fuel Loss","tooltip":"Fuel Loss","validate":"ValidateIsRange0to1","hidden":"false","disabled":"false","value":"","position":"label-top","offsetLeft":' . $ui_settings['offset_left'] . ',"labelWidth":"auto","inputWidth":' . $ui_settings['field_size'] . ',"userdata":{"validation_message":"Fuel loss should be 0 to 1."}},
                                        {"type":"newcolumn"},
                                        {"type":"combo","name":"fuel_loss_shrinkage_curve","label":"Fuel Loss Group","tooltip":"Fuel Loss Group","validate":"ValidInteger","hidden":"false","disabled":"false","value":"","offsetLeft":' . $ui_settings['offset_left'] . ',"labelWidth":"auto","inputWidth":' . $ui_settings['field_size'] . ',"filtering":"true","options":' . $fuel_loss_shrinkage_curve_dropdown . '}
                                        ]}
                                    ]';

$group_route_form_structure = "[
                                {type: 'settings', 'position': 'label-top', 'offsetLeft': " . $ui_settings['offset_left'] . ",'labelWidth':240, 'inputWidth':" . $ui_settings['field_size'] . "},
                                {type: 'input', name: 'route_name', required: true, label: 'Route Name','userdata':{'validation_message':'Required Field'}}, 
                                {type:'hidden', name:'maintain_location_routes_id', value:'NULL'}                               
                            ]";

//save button toolbar
$save_btn_toolbar_json = '[{id:"save", img:"save.gif", text:"Save", title:"Save"}]';

$save_btn_toolbar_json_b = '[
            {id:"refresh", text:"Refresh", img:"refresh.gif"},
            {id:"t1", text:"Edit", img:"edit.gif", items:[
                {id:"add_route", text:"Add Route", img:"add.gif", imgdis:"add_dis.gif"},
                {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif" }
            ]},
            {id:"t2", text:"Export", img:"export.gif", items:[
                {id:"excel", text:"Excel", img:"excel.gif"},
                {id:"pdf", text:"PDF", img:"pdf.gif"}
            ]}
            ]';
?>

<script type="text/javascript">
    var php_script_loc = '<?php echo $php_script_loc; ?>';
    var image_path = '<?php echo $image_path; ?>';
    var group_route_validation_check = 0;
    var group_route_primary_sec_validation_check = 0;
    var route_type = 'single';
    var details_grid_delete_status = 0;
    var delivery_loc_def_id = 0
    var pipeline_contract = 0
    var contract_id = 0
    var pipeline_def_id = 0;
    var contract_def_id = 0;
    setup_routes.details_grid = {};

    var mode = 'i';
    var expand_state = 0;

    /**Privilege listing**/
    var has_rights_setup_route_iu = '<?php echo $has_right_setup_route_iu; ?>';
    var has_rights_setup_route_del = '<?php echo $has_right_setup_route_del; ?>';

    $(function() {
        setup_routes.setup_routes_menu.setItemImage('add_single_route', 'add.gif', 'add_dis.gif');
        setup_routes.setup_routes_menu.setItemImage('add_group_route', 'add.gif', 'add_dis.gif');
        setup_routes.setup_routes_menu.setItemImage('delete', 'trash.gif', 'trash_dis.gif');
        setup_routes.setup_routes_menu.setItemImage('copy', 'copy.gif', 'copy_dis.gif');

        set_setup_route_menu_disabled('add_single_route', has_rights_setup_route_iu);
        set_setup_route_menu_disabled('add_group_route', has_rights_setup_route_iu);
        set_setup_route_menu_disabled('delete', false);
        set_setup_route_menu_disabled('copy', false);

        setup_routes.setup_routes_treegrid.attachEvent("onRowSelect", function(id, ind) {
            if (id != 'SINGLE ROUTE' && id != 'GROUP ROUTE' && id != '') {
                set_setup_route_menu_disabled('delete', has_rights_setup_route_del);
                set_setup_route_menu_disabled('copy', has_rights_setup_route_iu);
            } else {
                set_setup_route_menu_disabled('delete', false);
                set_setup_route_menu_disabled('copy', false);
            }

        })
    })

    //default values    
    var check_delivery_loc_dd = <?php echo $delivery_loc_dropdown; ?>;
    var check_pipeline_def_dd = <?php echo $pipeline_dropdown; ?>;
    var check_contract_def_dd = <?php echo $contract_dropdown; ?>

    // condition are checked as it does not load the page for the dropdown with null values 
    if (check_delivery_loc_dd.length > 0) {
        delivery_loc_def_id = check_delivery_loc_dd[0].value;
    }
    if (check_pipeline_def_dd.length > 0) {
        pipeline_def_id = check_pipeline_def_dd[0].value;
    }
    if (check_contract_def_dd.length > 0) {
        contract_def_id = check_contract_def_dd[0].value;
    }

    setup_routes.grid_toolbar_click = function(id) {
        switch (id) {
            case 'add_single_route':
                setup_routes.single_open_detail('i');
                break;
            case 'add_group_route':
                setup_routes.group_open_detail('r');
                break;
            case 'delete':
                var selected_row = setup_routes.setup_routes_treegrid.getSelectedRowId();
                var selected_row_array = [];
                var count = selected_row.indexOf(",") > -1 ? selected_row.split(",").length : 1;
                selected_row = selected_row.indexOf(",") > -1 ? selected_row.split(",") : [selected_row];
                if (selected_row != '') {
                    var maintain_location_routes_id = '';
                    var is_group = '';
                    for (i = 0; i < count; i++) {
                        maintain_location_routes_id += setup_routes.setup_routes_treegrid.cells(selected_row[i], 1).getValue() + ',';
                        is_group += setup_routes.setup_routes_treegrid.cells(selected_row[i], 9).getValue() + ',';
                    }
                    maintain_location_routes_id = maintain_location_routes_id.slice(0, -1);
                    is_group = is_group.slice(0, -1);

                    confirm_messagebox("Are you sure you want to delete?", function() {
                        data_for_post = {
                            "action": "spa_route_group",
                            "flag": "d",
                            "maintain_location_routes_id": maintain_location_routes_id,
                            "is_group": is_group
                        };
                        route_type = (is_group == 'yes') ? 'group' : 'single';
                        var return_json = adiha_post_data('alert', data_for_post, '', '', 'setup_routes.delete_callback');
                    });
                } else {
                    show_messagebox("Please select a node from tree!");
                }
                break;
            case 'excel':
                setup_routes.setup_routes_treegrid.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                break;
            case 'pdf':
                setup_routes.setup_routes_treegrid.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                break;
            case 'copy':
                var selected_row = setup_routes.setup_routes_treegrid.getSelectedRowId();
                var selected_row_array = [];
                var count = selected_row.indexOf(",") > -1 ? selected_row.split(",").length : 1;
                selected_row = selected_row.indexOf(",") > -1 ? selected_row.split(",") : [selected_row];
                setup_routes.copy_route_row(selected_row);
                break;
            case 'expand_collapse':
                if (expand_state == 0) {
                    setup_routes.open_all_group();
                } else {
                    setup_routes.close_all_group();
                }
                break;
                /*
                case 'refresh': 
                    setup_routes.setup_routes_treegrid_load();
                    break;
                */
            default:
                show_messagebox(id);
        }
    }

    setup_routes.delete_route_post = function() {
        // var return_data = JSON.parse(return_arr);
        // if (return_data[0].errorcode == 'Success') {            
        // dhtmlx.message({
        //             text:return_data[0].message,
        //             expire:1000
        //         });     

        var selected_row = setup_routes.setup_routes_treegrid.getSelectedId();
        var tab_id_array = setup_routes.setup_routes_details.getAllTabs();
        var tab_id_array_cnt = (tab_id_array == 0) ? '0' : tab_id_array.length;

        var tab_label = setup_routes.setup_routes_treegrid.cells(selected_row, 0).getValue();
        var tab_name = setup_routes.setup_routes_treegrid.cells(selected_row, 1).getValue();


        for (var i = 0; i < tab_id_array_cnt; i++) {
            //alert(tab_label + ' || '+ setup_routes.setup_routes_details.tabs(tab_id_array[i]).getText());
            if (tab_label == setup_routes.setup_routes_details.tabs(tab_id_array[i]).getText()) {
                setup_routes.setup_routes_details.cells(tab_id_array[i]).close();
            }
        }

        setup_routes.setup_routes_treegrid_load();

        // } else {
        show_messagebox(return_data[0].message);
        // }
    }

    setup_routes.setup_routes_treegrid_dblClicked = function(id) {
        var is_group = setup_routes.setup_routes_treegrid.cells(id, 9).getValue();

        var hierarchy_level = setup_routes.setup_routes_treegrid.getLevel(id);

        if (hierarchy_level == 0) {
            return false;
        }

        if (is_group == 'No') {
            setup_routes.single_open_detail(id);
        } else {
            setup_routes.group_open_detail(id);
        }

    }

    /******Single route form **************/
    setup_routes.single_open_detail = function(id) {
        mode = id;
        var maintain_location_routes_id = 'NULL'

        var tab_id_array = setup_routes.setup_routes_details.getAllTabs();
        var tab_id_array_cnt = (tab_id_array == 0) ? '0' : tab_id_array.length;

        if (mode == 'i') {
            var tab_label = get_locale_value('New');
            var tab_name = get_locale_value('New') + tab_id_array_cnt;
        } else {
            mode = 'u';
            var tab_label = setup_routes.setup_routes_treegrid.cells(id, 0).getValue();
            var tab_name = setup_routes.setup_routes_treegrid.cells(id, 1).getValue();

            for (var i = 0; i < tab_id_array_cnt; i++) {
                if (tab_label == setup_routes.setup_routes_details.tabs(tab_id_array[i]).getText()) {
                    setup_routes.setup_routes_details.cells(tab_id_array[i]).setActive();
                    return;
                }
            }

            maintain_location_routes_id = setup_routes.setup_routes_treegrid.cells(id, 1).getValue();

            var sp_string = "EXEC spa_route_group @flag='a',@maintain_location_routes_id=" + maintain_location_routes_id;
            var data_for_post = {
                "sp_string": sp_string
            };
            var return_json = adiha_post_data('return_json', data_for_post, '', '', 'setup_routes.single_open_detail_load');
        }

        setup_routes.setup_routes_details.addTab(tab_name, tab_label, null, null, true, true);
        win = setup_routes.setup_routes_details.cells(tab_name);
        setup_routes['inner_layout_' + tab_name] = win.attachLayout("1C");
        setup_routes['inner_layout_' + tab_name].cells('a').hideHeader();

        var form_structure = <?php echo $single_route_form_structure; ?>;
        setup_routes['frm_' + tab_name] = setup_routes['inner_layout_' + tab_name].cells('a').attachForm();
        setup_routes['frm_' + tab_name].loadStruct(get_form_json_locale(form_structure));

        /*Default value for combo*/
        if (mode == 'i') {
            setup_routes['frm_' + tab_name].getCombo('pipeline').selectOption(0);
            setup_routes['frm_' + tab_name].getCombo('delivery_location').selectOption(0);
            setup_routes['frm_' + tab_name].getCombo('contract').selectOption(0);
        }

        setup_routes['a_tool_bar_' + tab_name] = setup_routes['inner_layout_' + tab_name].cells('a').attachMenu();
        setup_routes['a_tool_bar_' + tab_name].setIconsPath(js_image_path + "dhxtoolbar_web/");
        setup_routes['a_tool_bar_' + tab_name].loadStruct(<?php echo $save_btn_toolbar_json; ?>);
        setup_routes['a_tool_bar_' + tab_name].setItemImage('save', 'save.gif', 'save_dis.gif');

        if (has_rights_setup_route_iu == false) {
            setup_routes['a_tool_bar_' + tab_name].setItemDisabled('save');
        } else {
            setup_routes['a_tool_bar_' + tab_name].setItemEnabled('save');
        }

        /*Validation msg*/
        setup_routes['frm_' + tab_name].attachEvent("onValidateError", function(name, value, res) {
            var message = setup_routes['frm_' + tab_name].getUserData(name, "validation_message");
            item_type = setup_routes['frm_' + tab_name].getItemType(name);
            if (item_type != 'combo') {
                setup_routes['frm_' + tab_name].setNote(name, {
                    text: message
                });
                setup_routes['frm_' + tab_name].attachEvent("onFocus",
                    function(name, value) {
                        setup_routes['frm_' + tab_name].setNote(name, {
                            text: ""
                        });
                    }
                );
            }
        })
        /*Validation msg END*/

        setup_routes['a_tool_bar_' + tab_name].attachEvent('onClick', function() {
            setup_routes.setup_routes_layout.cells('a').expand();
            //var validate_return = setup_routes['frm_' + tab_name].validate();
            var validate_return = validate_form(setup_routes['frm_' + tab_name]);

            if (!validate_return) {
                generate_error_message();
                return;
            }
            maintain_location_routes_id = setup_routes['frm_' + tab_name].getItemValue('maintain_location_routes_id');
            var route_name = setup_routes['frm_' + tab_name].getItemValue('route_name');
            var delivery_location = setup_routes['frm_' + tab_name].getItemValue('delivery_location');
            var pipeline = setup_routes['frm_' + tab_name].getItemValue('pipeline');
            var contract = setup_routes['frm_' + tab_name].getItemValue('contract');
            var fuel_loss = setup_routes['frm_' + tab_name].getItemValue('fuel_loss');
            var fuel_loss_shrinkage_curve = setup_routes['frm_' + tab_name].getItemValue('fuel_loss_shrinkage_curve');
            var primary_secondary = setup_routes['frm_' + tab_name].getItemValue('primary_secondary');

            //fuel_loss = (fuel_loss_str == '' || fuel_loss_str == 'NULL') ? 'NULL' : fuel_loss;

            /*if((fuel_loss == 'NULL' || fuel_loss == '') && fuel_loss_shrinkage_curve == '') {
                dhtmlx.alert({
                    title:"Error!",
                    type:"alert-error",
                    text:'Fuel Loss or Fuel Loss Group is required field.'
                });
                return false;
            }
            */
            pipeline = (pipeline == '') ? 'NULL' : pipeline;
            contract = (contract == '') ? 'NULL' : contract;
            fuel_loss = (fuel_loss == '') ? 'NULL' : fuel_loss;

            fuel_loss_shrinkage_curve = (fuel_loss_shrinkage_curve == '') ? 'NULL' : fuel_loss_shrinkage_curve;
            var fuel_loss_str = "" + fuel_loss + "";
            if (fuel_loss_str == 'NULL' && fuel_loss_shrinkage_curve == 'NULL') {
                show_messagebox("Fuel Loss or Fuel Loss Group is required field.");
                return false;
            }
            setup_routes['a_tool_bar_' + tab_name].setItemDisabled('save');


            var sp_string = "EXEC spa_route_group @flag='" + mode + "',@maintain_location_routes_id=" + maintain_location_routes_id + "," +
                "@route_name='" + route_name + "'," +
                "@delivery_location=" + delivery_location + "," +
                "@pipeline=" + pipeline + "," +
                "@contract_id=" + contract + "," +
                "@fuel_loss=" + fuel_loss + "," +
                "@primary_secondary='" + primary_secondary + "'," +
                "@time_series_definition_id=" + fuel_loss_shrinkage_curve + "," +
                "@is_group='n'";

            var data_for_post = {
                "sp_string": sp_string
            };
            if (sp_string) {
                if (has_rights_setup_route_iu) {
                    setup_routes['a_tool_bar_' + tab_name].setItemEnabled('save');

                };

            };

            var return_json = adiha_post_data('return_json', data_for_post, '', '', 'setup_routes.single_open_detail_post');

        });


        /*
        setup_routes['frm_' + tab_name].attachEvent('onChange', function(name, value) {
            //code here
        });
        */
    }

    /*Form load for single route*/
    setup_routes.single_open_detail_load = function(return_arr) {
        var return_data = JSON.parse(return_arr);
        var tab_name = setup_routes.setup_routes_details.getActiveTab();

        setup_routes['frm_' + tab_name].setItemValue('fuel_loss', return_data[0].fuel_loss);
        setup_routes['frm_' + tab_name].setItemValue('maintain_location_routes_id', return_data[0].maintain_location_routes_id);
        setup_routes['frm_' + tab_name].setItemValue('route_name', return_data[0].route_name);
        setup_routes['frm_' + tab_name].setItemValue('delivery_location', return_data[0].delivery_location);
        setup_routes['frm_' + tab_name].setItemValue('pipeline', return_data[0].pipeline);
        setup_routes['frm_' + tab_name].setItemValue('contract', return_data[0].contract_id);
        setup_routes['frm_' + tab_name].setItemValue('fuel_loss_shrinkage_curve', return_data[0].time_series_definition_id);
        setup_routes['frm_' + tab_name].setItemValue('primary_secondary', return_data[0].primary_secondary);

    }

    setup_routes.single_open_detail_post = function(return_arr) {
        var return_data = JSON.parse(return_arr);
        if (return_data[0].errorcode == 'Success') {
            route_type = 'single';
            setup_routes.setup_routes_treegrid_load();
            success_call(return_data[0].message);

            var tab_name = setup_routes.setup_routes_details.getActiveTab();
            // setup_routes['a_tool_bar_' + tab_name].setItemEnabled('save');
            var active_frm = setup_routes['frm_' + tab_name];
            var route_name = active_frm.getItemValue('route_name');
            setup_routes.setup_routes_details.tabs(tab_name).setText(route_name);

            if (mode == 'i')
                setup_routes['frm_' + tab_name].setItemValue('maintain_location_routes_id', return_data[0].recommendation);
            mode = 'u';

            //setup_routes.setup_routes_details.tabs(tab_name).close();
        } else {
            show_messagebox(return_data[0].message);
        }
    }

    setup_routes.delete_callback = function(result) {
        console.log(result);
        if (result[0].recommendation.indexOf(",") > -1) {
            var ids = result[0].recommendation.split(",");
            var count_ids = ids.length;
            for (var i = 0; i < count_ids; i++) {
                full_id = ids[i];
                if (setup_routes.setup_routes_details.cells(full_id) != null)
                    setup_routes.setup_routes_details.cells(full_id).close();
            }
        } else {
            full_id = result[0].recommendation;
            if (setup_routes.setup_routes_details.cells(full_id) != null)
                setup_routes.setup_routes_details.cells(full_id).close();
        }
        setup_routes.setup_routes_treegrid_load();
    }
    //setup_routes_treegrid Refresh
    setup_routes.setup_routes_treegrid_load = function(id) {
        setup_routes.setup_routes_treegrid.clearAll();
        var sql_param = {
            "sql": "EXEC spa_route_group 's'",
            "grid_type": "tg",
            "grouping_column": "Type,route_name"
        };
        sql_param = $.param(sql_param);
        var sql_url = js_data_collector_url + "&" + sql_param;
        //setup_routes.setup_routes_treegrid.load(sql_url);

        //set_custom_report_template_menu_disabled('delete', false);

        //Clear the filter value 
        //$('div.dhx_cell_layout:first').find('div.filter input').val('');

        var grouping_col = (route_type == 'group') ? 'GROUP ROUTE' : 'SINGLE ROUTE';
        setup_routes.setup_routes_treegrid.load(sql_url, function() {
            setup_routes.setup_routes_treegrid.filterByAll();
            setup_routes.setup_routes_treegrid.openItem(grouping_col);
        });

        set_setup_route_menu_disabled('delete', false);
        set_setup_route_menu_disabled('copy', false);
    }

    /******Group route form **************/
    setup_routes.group_open_detail = function(id) {
        var maintain_location_routes_id = 'NULL'

        var tab_id_array = setup_routes.setup_routes_details.getAllTabs();
        var tab_id_array_cnt = (tab_id_array == 0) ? '0' : tab_id_array.length;

        if (id == 'r') {
            flag = 'r';
            var tab_label = get_locale_value('New');
            var tab_name = get_locale_value('New') + tab_id_array_cnt;
        } else {
            flag = 't';
            var tab_label = setup_routes.setup_routes_treegrid.cells(id, 0).getValue();
            var tab_name = setup_routes.setup_routes_treegrid.cells(id, 1).getValue();


            for (var i = 0; i < tab_id_array_cnt; i++) {
                //alert(tab_label + ' || '+ setup_routes.setup_routes_details.tabs(tab_id_array[i]).getText());
                if (tab_label == setup_routes.setup_routes_details.tabs(tab_id_array[i]).getText()) {
                    setup_routes.setup_routes_details.cells(tab_id_array[i]).setActive();
                    return;
                }
            }

            maintain_location_routes_id = setup_routes.setup_routes_treegrid.cells(id, 1).getValue();

            var sp_string = "EXEC spa_route_group @flag='a',@maintain_location_routes_id=" + maintain_location_routes_id;
            var data_for_post = {
                "sp_string": sp_string
            };
            var return_json = adiha_post_data('return_json', data_for_post, '', '', 'setup_routes.group_open_detail_load');
        }

        setup_routes.setup_routes_details.addTab(tab_name, tab_label, null, null, true, true);
        win = setup_routes.setup_routes_details.cells(tab_name);
        setup_routes['inner_layout_' + tab_name] = win.attachLayout("2E");
        setup_routes['inner_layout_' + tab_name].cells('a').setHeight(115);
        setup_routes['inner_layout_' + tab_name].cells('a').hideHeader();

        var form_structure = <?php echo $group_route_form_structure; ?>;
        setup_routes['frm_' + tab_name] = setup_routes['inner_layout_' + tab_name].cells('a').attachForm();
        setup_routes['frm_' + tab_name].loadStruct(get_form_json_locale(form_structure));

        setup_routes['a_tool_bar_' + tab_name] = setup_routes['inner_layout_' + tab_name].cells('a').attachMenu();
        setup_routes['a_tool_bar_' + tab_name].setIconsPath(js_image_path + "dhxtoolbar_web/");
        setup_routes['a_tool_bar_' + tab_name].loadStruct(<?php echo $save_btn_toolbar_json; ?>);
        setup_routes['a_tool_bar_' + tab_name].setItemImage('save', 'save.gif', 'save_dis.gif');

        if (has_rights_setup_route_iu == false) {
            setup_routes['a_tool_bar_' + tab_name].setItemDisabled('save');
        } else {
            setup_routes['a_tool_bar_' + tab_name].setItemEnabled('save');
        }

        /*Validation msg*/
        setup_routes['frm_' + tab_name].attachEvent("onValidateError", function(name, value, res) {
            var message = setup_routes['frm_' + tab_name].getUserData(name, "validation_message");
            item_type = setup_routes['frm_' + tab_name].getItemType(name);
            if (item_type != 'combo') {
                setup_routes['frm_' + tab_name].setNote(name, {
                    text: message
                });
                setup_routes['frm_' + tab_name].attachEvent("onFocus",
                    function(name, value) {
                        setup_routes['frm_' + tab_name].setNote(name, {
                            text: ""
                        });
                    }
                );
            }
        })
        /*Validation msg END*/

        setup_routes['a_tool_bar_' + tab_name].attachEvent('onClick', function() {
            setup_routes.setup_routes_layout.cells('a').expand();
            if (setup_routes.details_grid['grd_' + tab_name] instanceof dhtmlXGridObject) {
                setup_routes.details_grid['grd_' + tab_name].clearSelection();
            }

            var validate_return = validate_form(setup_routes['frm_' + tab_name]);
            if (!validate_return) {
                generate_error_message();
                return;
            }

            maintain_location_routes_id = setup_routes['frm_' + tab_name].getItemValue('maintain_location_routes_id');
            var route_name = setup_routes['frm_' + tab_name].getItemValue('route_name');
            var delivery_location = 'NULL';
            var pipeline = 'NULL';
            var contract = 'NULL';
            var fuel_loss = 'NULL';
            var fuel_loss_shrinkage_curve = 'NULL';
            var primary_secondary = 'NULL';
            var group_route_arr_check = 0;
            var group_route_arr = new Array();

            var grid_xml = "<GridGroup>";
            var check_grid_arr = new Array();
            for (var row_index = 0; row_index < setup_routes.details_grid['grd_' + tab_name].getRowsNum(); row_index++) {
                if (jQuery.inArray(setup_routes.details_grid['grd_' + tab_name].cells2(row_index, 2).getValue(), group_route_arr) == -1) {
                    group_route_arr.push(setup_routes.details_grid['grd_' + tab_name].cells2(row_index, 2).getValue());
                } else {
                    group_route_arr_check = 1;
                }

                //alert("'" + setup_routes.details_grid['grd_' + tab_name].cells2(row_index,4).getValue() + "'");
                //alert("'" + setup_routes.details_grid['grd_' + tab_name].cells2(row_index,5).getValue() + "'");

                /**group route grid validation*/
                if (setup_routes.details_grid['grd_' + tab_name].cells2(row_index, 2).getValue() == '' && check_grid_arr.indexOf('Route Name') == -1) {
                    check_grid_arr.push('Route Name');
                }
                if (setup_routes.details_grid['grd_' + tab_name].cells2(row_index, 3).getValue() == '' && check_grid_arr.indexOf('Delivery Location') == -1) {
                    check_grid_arr.push('Delivery Location');
                }
                var cell4_val = setup_routes.details_grid['grd_' + tab_name].cells2(row_index, 4).getValue();
                var cell5_val = setup_routes.details_grid['grd_' + tab_name].cells2(row_index, 5).getValue();
                if (ValidateIsRange0to1(cell4_val) == false && cell4_val != '' && check_grid_arr.indexOf('Fuel Loss or Fuel Loss Group') == -1) {
                    check_grid_arr.push('Fuel Loss or Fuel Loss Group');
                }
                if ((cell4_val == '' && (cell5_val == '' || cell5_val == 'undefined')) && check_grid_arr.indexOf('Fuel Loss or Fuel Loss Group') == -1) {
                    check_grid_arr.push('Fuel Loss or Fuel Loss Group');
                }
                if (setup_routes.details_grid['grd_' + tab_name].cells2(row_index, 6).getValue() == '' && check_grid_arr.indexOf('Pipeline') == -1) {
                    check_grid_arr.push('Pipeline');
                }
                if (setup_routes.details_grid['grd_' + tab_name].cells2(row_index, 7).getValue() == '' && check_grid_arr.indexOf('Contract') == -1) {
                    check_grid_arr.push('Contract');
                }
                if (setup_routes.details_grid['grd_' + tab_name].cells2(row_index, 8).getValue() == '' && check_grid_arr.indexOf('Effective Date') == -1) {
                    check_grid_arr.push('Effective Date');
                }
                if (setup_routes.details_grid['grd_' + tab_name].cells2(row_index, 9).getValue() == '' && check_grid_arr.indexOf('Primary/Secondary') == -1) {
                    check_grid_arr.push('Primary/Secondary');
                }

                /***/

                grid_xml = grid_xml + "<PSRecordset ";
                for (var cellIndex = 0; cellIndex < setup_routes.details_grid['grd_' + tab_name].getColumnsNum(); cellIndex++) {
                    var grid_col_val = setup_routes.details_grid['grd_' + tab_name].cells2(row_index, cellIndex).getValue();
                    var grid_col_name = setup_routes.details_grid['grd_' + tab_name].getColumnId(cellIndex);

                    grid_col_val = (grid_col_val == 'undefined') ? '' : grid_col_val;

                    //for handling null on fuel_loss as xml value blank is treated as 0 on float while storing on temp table from xml
                    if (grid_col_name == 'fuel_loss' && grid_col_val == '') {
                        grid_col_val = -1;
                    }
                    grid_xml = grid_xml + " " + grid_col_name + '="' + grid_col_val + '"';
                }
                grid_xml = grid_xml + " ></PSRecordset> ";
            }

            grid_xml += "</GridGroup>";


            if (check_grid_arr.length > 0) {
                group_route_validation_check = 1;
            } else {
                group_route_validation_check = 0;
            }

            if (group_route_arr_check == 1 && group_route_validation_check != 1) {
                show_messagebox("Route Name in grid should not be duplicate.");
                return
            }

            if (group_route_validation_check == 1) {
                var message = 'Error in Group route grid. ' + check_grid_arr.toString();

                if (check_grid_arr.length > 1) {
                    message += ' are ';
                } else {
                    message += ' is ';
                }
                message += ' required field(s).';

                if (check_grid_arr.indexOf('Fuel Loss or Fuel Loss Group') > -1) {
                    message += ' Fuel Loss should be 0 to 1.';
                }
                show_messagebox(message);
                return
            }

            if (group_route_primary_sec_validation_check == 1) {
                show_messagebox("Error in Group route grid. Primary route not allowed once secondary exists.");
                return
            }

            //check if grid rows deleted
            if (details_grid_delete_status == 1) {
                confirm_messagebox("Some data has been deleted from Group Grid. Are you sure you want to save?", function() {
                    var sp_string = "EXEC spa_route_group @flag='" + flag + "',@maintain_location_routes_id=" + maintain_location_routes_id + "," +
                        "@route_name='" + route_name + "'," +
                        "@delivery_location=" + delivery_location + "," +
                        "@pipeline=" + pipeline + "," +
                        "@contract_id=" + contract + "," +
                        "@fuel_loss=" + fuel_loss + "," +
                        "@primary_secondary='" + primary_secondary + "'," +
                        "@time_series_definition_id=" + fuel_loss_shrinkage_curve + "," +
                        "@is_group='y'," +
                        "@grid_xml='" + grid_xml + "'";

                    var data_for_post = {
                        "sp_string": sp_string
                    };

                    var return_json = adiha_post_data('return_json', data_for_post, '', '', 'setup_routes.group_open_detail_post');
                });

            } else {
                setup_routes['a_tool_bar_' + tab_name].setItemDisabled('save');
                var sp_string = "EXEC spa_route_group @flag='" + flag + "',@maintain_location_routes_id=" + maintain_location_routes_id + "," +
                    "@route_name='" + route_name + "'," +
                    "@delivery_location=" + delivery_location + "," +
                    "@pipeline=" + pipeline + "," +
                    "@contract_id=" + contract + "," +
                    "@fuel_loss=" + fuel_loss + "," +
                    "@primary_secondary='" + primary_secondary + "'," +
                    "@time_series_definition_id=" + fuel_loss_shrinkage_curve + "," +
                    "@is_group='y'," +
                    "@grid_xml='" + grid_xml + "'";

                var data_for_post = {
                    "sp_string": sp_string
                };

                if (sp_string) {
                    if (has_rights_setup_route_iu) {
                        setup_routes['a_tool_bar_' + tab_name].setItemEnabled('save');

                    }
                }
                var return_json = adiha_post_data('return_json', data_for_post, '', '', 'setup_routes.group_open_detail_post');
            }


        });


        setup_routes['inner_layout_' + tab_name].cells('b').hideHeader();
        setup_routes['b_tool_bar_' + tab_name] = setup_routes['inner_layout_' + tab_name].cells('b').attachMenu();
        setup_routes['b_tool_bar_' + tab_name].setIconsPath(js_image_path + "dhxtoolbar_web/");
        setup_routes['b_tool_bar_' + tab_name].loadStruct(<?php echo $save_btn_toolbar_json_b; ?>);
        if (has_rights_setup_route_iu == false) {
            setup_routes['b_tool_bar_' + tab_name].setItemDisabled('add_route');
        } else {
            setup_routes['b_tool_bar_' + tab_name].setItemEnabled('add_route');
        }

        setup_routes["b_tool_bar_" + tab_name].attachEvent('onClick', function(id) {
            switch (id) {
                case "refresh":
                    setup_routes.refresh_child_grid(maintain_location_routes_id);
                    break;
                case "add_route":
                    var new_id = (new Date()).valueOf();
                    var route_order_n = setup_routes.details_grid['grd_' + tab_name].getRowsNum() + 1;
                    setup_routes.details_grid['grd_' + tab_name].addRow(new_id, ['', route_order_n, '', delivery_loc_def_id, '', '', pipeline_def_id, contract_def_id]);
                    setup_routes.details_grid['grd_' + tab_name].cells(new_id, 8).setValue('<?php echo date("m/d/Y"); ?>');
                    var sec_cnt = 0;
                    setup_routes.details_grid['grd_' + tab_name].forEachRow(function(id) {
                        p_s = setup_routes.details_grid['grd_' + tab_name].cells(id, 9).getValue();
                        if (setup_routes.details_grid['grd_' + tab_name].cells(id, 9).getValue() == 's') {
                            sec_cnt++;
                        }
                    });

                    if (sec_cnt >= 1) {
                        setup_routes.details_grid['grd_' + tab_name].cells(new_id, 9).setValue('s');
                    } else {
                        setup_routes.details_grid['grd_' + tab_name].cells(new_id, 9).setValue('p');
                    }
                    break;
                case "delete":
                    var row_id = setup_routes.details_grid['grd_' + tab_name].getSelectedRowId();
                    /*
                    if (setup_routes.details_grid['grd_' + tab_name].cells(row_id, 2).getValue() != '') {
                    
                        dhtmlx.message({
                            type: "confirm",
                            text: "Are you sure you want to delete?",
                            callback: function(result) {
                                if (result) {
                                    
                                    setup_routes.details_grid['grd_' + tab_name].deleteRow(row_id);
                                    var row_num = 0;
                                    setup_routes.details_grid['grd_' + tab_name].forEachRow(function(id){
                                        row_num++;
                                        setup_routes.details_grid['grd_' + tab_name].cells(id, 1).setValue(row_num);
                                    });
                                    setup_routes['b_tool_bar_' + tab_name].setItemDisabled('delete');
                                    details_grid_delete_status = 1;
                                                        
                                }
                            }
                        });
                    } else {
                        */
                    setup_routes.details_grid['grd_' + tab_name].deleteRow(row_id);
                    var row_num = 0;
                    setup_routes.details_grid['grd_' + tab_name].forEachRow(function(id) {
                        row_num++;
                        setup_routes.details_grid['grd_' + tab_name].cells(id, 1).setValue(row_num);
                    });
                    setup_routes['b_tool_bar_' + tab_name].setItemDisabled('delete');
                    details_grid_delete_status = 1;
                    /*}*/


                    break;
                case "excel":
                    setup_routes.details_grid['grd_' + tab_name].toExcel(php_script_loc + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                    break;
                case "pdf":
                    setup_routes.details_grid['grd_' + tab_name].toPDF(php_script_loc + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                    break;
            }
        });

        setup_routes.details_grid['grd_' + tab_name] = setup_routes['inner_layout_' + tab_name].cells('b').attachGrid();
        setup_routes.details_grid['grd_' + tab_name].setImagePath(php_script_loc + "components/lib/adiha_dhtmlx/adiha_grid_3.0/adiha_dhtmlxGrid/codebase/imgs/");
        setup_routes.details_grid['grd_' + tab_name].setHeader(get_locale_value('Route ID,Route Order,Route Name,Delivery Location,Fuel Loss,Fuel Loss Group,Pipeline,Contract,Effective Date,Primary/Secondary', true));
        setup_routes.details_grid['grd_' + tab_name].setColumnIds("route_id,route_order,route_name,delivery_location,fuel_loss,fuel_loss_shrinkage_curve,pipeline,contract,effective_date,primary_secondary");
        setup_routes.details_grid['grd_' + tab_name].setColTypes("ro_int,ro,ed,combo,ed_no,combo,combo,combo,dhxCalendarA,combo");
        setup_routes.details_grid['grd_' + tab_name].setInitWidths('0,150,150,150,150,150,150,150,150,150');
        setup_routes.details_grid['grd_' + tab_name].setColSorting('int,int,str,str,int,str,str,str,date,str');
        setup_routes.details_grid['grd_' + tab_name].setColValidators("NotEmpty,ValidInteger,NotEmpty,ValidInteger,ValidateIsRange0to1,,ValidInteger,ValidInteger,ValidDate,CheckSecondary");
        setup_routes.details_grid['grd_' + tab_name].attachEvent("onValidationError", function(id, ind, value) {
            group_route_validation_check = 1;
            var message = "Invalid Data";

            switch (ind) {
                case 2:
                    message = 'Route name is required field.'
                    break;
                case 3:
                    message = 'Delivery Location is required field.'
                    break;
                case 4:
                    message = 'Fuel Loss should be 0 to 1.'
                    break;
                case 6:
                    message = 'Pipeline is required field.'
                    break;
                case 7:
                    message = 'Contract is required field.'
                    break;
                case 8:
                    message = 'Effective Date is required field.'
                    break;
                case 8:
                    message = 'Primary/Secondary is required field.'
                    break;
                default:
                    message = 'Invalid Data';
            }
            //var message = "Invalid Data";

            setup_routes.details_grid['grd_' + tab_name].cells(id, ind).setAttribute("validation", message);
            /*
            dhtmlx.alert({
                    title:"Error!",
                    type:"alert-error",
                    text:message                        
                });
            */
            //console.log(setup_routes.details_grid['grd_' + tab_name].cells(id,ind));
            //setup_routes.details_grid['grd_' + tab_name].cells(id,ind).setBgColor('red'); 
            return;
        });

        setup_routes.details_grid['grd_' + tab_name].attachEvent("onValidationCorrect", function(id, ind, value) {
            group_route_validation_check = 0;
            setup_routes.details_grid['grd_' + tab_name].cells(id, ind).setAttribute("validation", "");
            //setup_routes.details_grid['grd_' + tab_name].cells(id,ind).setBgColor('#FFFFFF');
            return true;
        });

        setup_routes.details_grid['grd_' + tab_name].init();
        setup_routes.details_grid['grd_' + tab_name].setColumnsVisibility('true,false,false,false,false,false,false,false,false,false');
        setup_routes.details_grid['grd_' + tab_name].setDateFormat("%m/%d/%Y");
        setup_routes.details_grid['grd_' + tab_name].attachHeader("#text_filter,#numeric_filter,#text_filter,#text_filter,#numeric_filter,#text_filter,#text_filter,#text_filter,#text_filter,#combo_filter");
        setup_routes.details_grid['grd_' + tab_name].enableSmartRendering(true);

        //setup_routes.details_grid['grd_' + tab_name].splitAt(3); ;


        //Loading dropdown Delivery path in grid // load location combo at last, just before loading grid 
        var location_name_fil = 'M2, Gathering System, storage, Pool, DM';
        var cm_param = {
            "action": "[spa_source_minor_location]",
            "flag": "o",
            "location_name": location_name_fil,
            "has_blank_option": "false"
        };

        cm_param = $.param(cm_param);
        var url = js_dropdown_connector_url + '&' + cm_param;
        var combo_obj = setup_routes.details_grid['grd_' + tab_name].getColumnCombo(3);
        combo_obj.enableFilteringMode("between", null, false);


        //Loading dropdown fuel_loss_shrinkage_curve in grid
        var cm_param1 = {
            "action": "[spa_generic_mapping_header]",
            "flag": "n",
            "combo_sql_stmt": "EXEC spa_route_group @flag = 'h', @route_order_in=1",
            "call_from": "grid"
        };

        cm_param1 = $.param(cm_param1);
        var url1 = js_dropdown_connector_url + '&' + cm_param1;
        var combo_obj1 = setup_routes.details_grid['grd_' + tab_name].getColumnCombo(5);
        combo_obj1.enableFilteringMode("between", null, false);
        combo_obj1.load(url1);

        //Loading dropdown Pipeline in grid
        var cm_param2 = {
            "action": "[spa_generic_mapping_header]",
            "flag": "n",
            "combo_sql_stmt": "EXEC spa_source_counterparty_maintain @flag= 'n',@type_of_entity = -10021",
            "call_from": "grid"
        };

        cm_param2 = $.param(cm_param2);
        var url2 = js_dropdown_connector_url + '&' + cm_param2;
        var combo_obj2 = setup_routes.details_grid['grd_' + tab_name].getColumnCombo(6);
        combo_obj2.enableFilteringMode("between", null, false);
        combo_obj2.load(url2);

        //Loading dropdown Contract in grid
        var cm_param3 = {
            "action": "[spa_generic_mapping_header]",
            "flag": "n",
            "combo_sql_stmt": "EXEC spa_contract_group @flag='r',@transportation_contract = 38402",
            "call_from": "grid"
        };

        cm_param3 = $.param(cm_param3);
        var url3 = js_dropdown_connector_url + '&' + cm_param3;
        var combo_obj3 = setup_routes.details_grid['grd_' + tab_name].getColumnCombo(7);
        combo_obj3.enableFilteringMode("between", null, false);
        combo_obj3.load(url3);

        //Loading dropdown primary_secondary in grid
        var cm_param4 = {
            "action": "[spa_generic_mapping_header]",
            "flag": "n",
            "combo_sql_stmt": "SELECT 'p' [value], 'Primary' [label] UNION  SELECT 's' [value], 'Secondary' [label]",
            "call_from": "grid"
        };

        cm_param4 = $.param(cm_param4);
        var url4 = js_dropdown_connector_url + '&' + cm_param4;

        var combo_obj4 = setup_routes.details_grid['grd_' + tab_name].getColumnCombo(9);
        combo_obj4.enableFilteringMode("between", null, false);

        // added callback to resolve issue in grid loading - id was displayed in location column on first load 
        combo_obj.load(url, function() {
            combo_obj4.load(url4, function() {
                setup_routes.refresh_child_grid(maintain_location_routes_id)
            });
        });

    }

    /***group_open_detail_load**/
    setup_routes.group_open_detail_load = function(return_arr) {
        var return_data = JSON.parse(return_arr);
        var tab_name = setup_routes.setup_routes_details.getActiveTab();

        setup_routes['frm_' + tab_name].setItemValue('maintain_location_routes_id', return_data[0].maintain_location_routes_id);
        setup_routes['frm_' + tab_name].setItemValue('route_name', return_data[0].route_name);
    }

    /**Post method for group open detail**/
    setup_routes.group_open_detail_post = function(return_arr) {
        var return_data = JSON.parse(return_arr);
        if (return_data[0].errorcode == 'Success') {
            details_grid_delete_status = 0;
            route_type = 'group';
            setup_routes.setup_routes_treegrid_load();
            success_call(return_data[0].message);

            var tab_name = setup_routes.setup_routes_details.getActiveTab();
            var active_frm = setup_routes['frm_' + tab_name];
            var route_name = active_frm.getItemValue('route_name');
            setup_routes.setup_routes_details.tabs(tab_name).setText(route_name);
            if (flag == 'r')
                setup_routes['frm_' + tab_name].setItemValue('maintain_location_routes_id', return_data[0].recommendation);

            flag = 't';
            setup_routes.refresh_child_grid(return_data[0].recommendation);
            //setup_routes.setup_routes_details.tabs(tab_name).close();
        } else {
            show_messagebox(return_data[0].message);
        }
    }

    /**Rfresh group route grid*/
    setup_routes.refresh_child_grid = function(id) {
        var tab_name = setup_routes.setup_routes_details.getActiveTab();
        if (id == '')
            var id = setup_routes['frm_' + tab_name].getItemValue('maintain_location_routes_id');

        var history_a_param = {
            "flag": "z",
            "action": "spa_route_group",
            "maintain_location_routes_id": id
        };
        history_a_param = $.param(history_a_param);
        var history_a_url = js_data_collector_url + "&" + history_a_param;
        setup_routes.details_grid['grd_' + tab_name].clearAll();
        setup_routes.details_grid['grd_' + tab_name].load(history_a_url);

        //alert(setup_routes.details_grid['grd_' + tab_name].getFilterElement(3).value);  
        /*     
         setup_routes.details_grid['grd_' + tab_name].getFilterElement(1).value="";
         setup_routes.details_grid['grd_' + tab_name].getFilterElement(2).value="";
         setup_routes.details_grid['grd_' + tab_name].getFilterElement(3).selectOption(0,true,false);
         setup_routes.details_grid['grd_' + tab_name].getFilterElement(4).value="";
         setup_routes.details_grid['grd_' + tab_name].getFilterElement(5).selectOption(0,true,false);
         setup_routes.details_grid['grd_' + tab_name].getFilterElement(6).selectOption(0,true,false);
         setup_routes.details_grid['grd_' + tab_name].getFilterElement(7).selectOption(0,true,false);
         setup_routes.details_grid['grd_' + tab_name].getFilterElement(8).value="";
         setup_routes.details_grid['grd_' + tab_name].getFilterElement(9).selectOption(0,true,false);
        */

        setup_routes.details_grid['grd_' + tab_name].getFilterElement(1).value = "";
        setup_routes.details_grid['grd_' + tab_name].getFilterElement(2).value = "";
        setup_routes.details_grid['grd_' + tab_name].getFilterElement(3).value = "";
        setup_routes.details_grid['grd_' + tab_name].getFilterElement(4).value = "";
        setup_routes.details_grid['grd_' + tab_name].getFilterElement(5).value = "";
        setup_routes.details_grid['grd_' + tab_name].getFilterElement(6).value = "";
        setup_routes.details_grid['grd_' + tab_name].getFilterElement(7).value = "";
        setup_routes.details_grid['grd_' + tab_name].getFilterElement(8).value = "";
        setup_routes.details_grid['grd_' + tab_name].getFilterElement(9).selectOption(0, true, false);
        /*permission of toolbar*/
        setup_routes['b_tool_bar_' + tab_name].setItemDisabled('delete');
        setup_routes.details_grid['grd_' + tab_name].attachEvent("onRowSelect", function(id, ind) {
            if (id != '') {
                if (has_rights_setup_route_iu == false) {
                    setup_routes['b_tool_bar_' + tab_name].setItemDisabled('delete');
                } else {
                    setup_routes['b_tool_bar_' + tab_name].setItemEnabled('delete');
                }
            } else {
                setup_routes['b_tool_bar_' + tab_name].setItemDisabled('delete');
            }

        })
    }

    /***Copy tree grid row**/
    setup_routes.copy_route_row = function(id) {
        if (id != '') {
            confirm_messagebox("Are you sure you want to copy?", function() {
                var maintain_location_routes_id = setup_routes.setup_routes_treegrid.cells(id, 1).getValue();
                var is_group = setup_routes.setup_routes_treegrid.cells(id, 9).getValue();
                is_group = (is_group == 'yes') ? 'y' : 'n';
                route_type = (is_group == 'yes') ? 'group' : 'single';
                var data = {
                    "action": "spa_route_group",
                    "flag": 'c',
                    "maintain_location_routes_id": maintain_location_routes_id,
                    "is_group": is_group
                };

                var return_json = adiha_post_data('return_json', data, '', '', 'setup_routes.copy_route_row_post');
            });
        } else {
            show_messagebox("Please select a node from tree!");
        }
    }

    setup_routes.copy_route_row_post = function(return_arr) {
        var return_data = JSON.parse(return_arr);
        if (return_data[0].errorcode == 'Success') {
            success_call(return_data[0].message);
            setTimeout(setup_routes.setup_routes_treegrid_load, 100);
        } else {
            show_messagebox(return_data[0].message);
        }
    }


    /**
     * Function enable/disable menu.
     */
    function set_setup_route_menu_disabled(item_id, bool) {
        if (bool == false) {
            setup_routes.setup_routes_menu.setItemDisabled(item_id);
        } else {
            setup_routes.setup_routes_menu.setItemEnabled(item_id);
        }
    }

    setup_routes.open_all_group = function() {
        setup_routes.setup_routes_treegrid.expandAll();
        expand_state = 1;
    }

    /**
     *[closeAllInvoices Close All nodes of Grid]
     */
    setup_routes.close_all_group = function() {
        setup_routes.setup_routes_treegrid.collapseAll();
        expand_state = 0;
    }

    setup_routes.undock_cell_a = function() {
        setup_routes.setup_routes_layout.cells("a").undock(300, 300, 900, 700);
        setup_routes.setup_routes_layout.dhxWins.window("a").button("park").hide();
        setup_routes.setup_routes_layout.dhxWins.window("a").maximize();
        setup_routes.setup_routes_layout.dhxWins.window("a").centerOnScreen();
    }

    $(function() {

        //Custom Validation
        ValidateIsRange0to1 = function(data) {
            // data should include numerical greater than 0 and less than 1
            if (parseFloat(data) >= 0 && parseFloat(data) <= 1)
                return true;
            else
                return false;
        };

        dhtmlxValidation.isValidateIsRange0to1 = function(data) {
            // data should include numerical greater than 0 and less than 1
            if (parseFloat(data) >= 0 && parseFloat(data) <= 1)
                return true;
            else
                return false;
        };


        dhtmlxValidation.isCheckSecondary = function(data) {
            // 
            var tab_name = setup_routes.setup_routes_details.getActiveTab();
            var sec_cnt = 0;
            var p_s = '';
            var sec_id = 0;
            setup_routes.details_grid['grd_' + tab_name].forEachRow(function(id) {
                p_s = setup_routes.details_grid['grd_' + tab_name].cells(id, 9).getValue();
                if (setup_routes.details_grid['grd_' + tab_name].cells(id, 9).getValue() == 's') {
                    sec_cnt++;
                }
            });

            if (sec_cnt >= 1 && p_s == 'p') {
                group_route_primary_sec_validation_check = 1;
                show_messagebox("Error in Group route grid. Primary route not allowed once secondary exists.");
                return false;
            } else {
                group_route_primary_sec_validation_check = 0;
                return true;
            }
        }
    })
</script>