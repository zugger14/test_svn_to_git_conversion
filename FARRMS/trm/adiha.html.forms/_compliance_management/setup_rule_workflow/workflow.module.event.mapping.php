<?php
/**
* Workflow module event mapping screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <?php include '../../../adiha.php.scripts/components/include.file.v3.php';?>
</head>
<?php
$php_script_loc = $app_php_script_loc;
$application_function_id =  20013700;
$right_module_event_add = 20013701;
$right_module_event_delete = 20013702;
$form_namespace = 'module_event';
    list (
        $has_right_module_event_add,
        $has_right_module_event_delete
        ) = build_security_rights(
        $right_module_event_add,
        $right_module_event_delete
        );
$form_obj = new AdihaStandardForm($form_namespace, 10102500);
$form_obj->define_grid("ModuleEventMapping", "EXEC spa_workflow_module_event_mapping 'g'", "g");
$form_obj->define_layout_width(300);
$form_obj->define_custom_functions('save_form', 'load_form', '','','');
echo $form_obj->init_form('Module');
echo $form_obj->close_form();

$form_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='" . $application_function_id . "', @template_name='ModuleEventMapping', @parse_xml='<Root><PSRecordset contract_id=" . '"NULL"' ."></PSRecordset></Root>'";
$form_data = readXMLURL2($form_sql);
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
                $def['grid_label'] = $grid['grid_label'];
                $def['cell_name'] = $grid['layout_cell'];
                $def['tab_id'] = 'detail_tab_' . $data['tab_id'];

                $it = new RecursiveIteratorIterator(new RecursiveArrayIterator($def));
                $l = iterator_to_array($it, true);

                array_push($grid_definition, $l);
            }
        }
    }
}

$grid_definition_json = json_encode($grid_definition);
//var_dump($grid_definition_json);
$form_json = json_encode($form_data);


$toolbar_json_event = '[
                                {id:"t1", text:"Edit", img:"edit.gif", items:[
                                    {id:"add_event", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add"},
                                    {id:"delete_event", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete",enabled:0}
                                ]}
                                ]';

$toolbar_json_rule = '[
                                {id:"t1", text:"Edit", img:"edit.gif", items:[
                                    {id:"add_rule", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add"},
                                    {id:"delete_rule", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete",enabled:0}
                                ]}
                                ]';

$toolbar_json_tag = '[
                                {id:"t1", text:"Edit", img:"edit.gif", items:[
                                    {id:"add_tag", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add"},
                                    {id:"delete_tag", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete",enabled:0}
                                ]},
                                {id:"show_system_defined", text:"Show System Defined", img:"show.png", imgdis:"show_dis.png", title: "Show System Defined"}
                                ]';
$toolbar_json_email = '[
                                {id:"t1", text:"Edit", img:"edit.gif", items:[
                                    {id:"add_email", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add"},
                                    {id:"delete_email", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete",enabled:0}
                                ]}
                        ]';

?>
<script type="text/javascript">
    var has_right_module_event_add =<?php echo (($has_right_module_event_add) ? $has_right_module_event_add : '0'); ?>;
    var has_right_module_event_delete =<?php echo (($has_right_module_event_delete) ? $has_right_module_event_delete : '0'); ?>;
    var application_function_id = '<?php echo $application_function_id;?>';

    var form_json = <?php echo $form_json; ?>;
    var grid_definition_json = <?php echo $grid_definition_json; ?>;
    var toolbar_json_event = <?php echo $toolbar_json_event; ?>;
    var toolbar_json_rule = <?php echo $toolbar_json_rule; ?>;
    var toolbar_json_tag = <?php echo $toolbar_json_tag; ?>;
    var toolbar_json_email = <?php echo $toolbar_json_email; ?>;
    var tab_object = {};
    $(function () {
        module_event.menu.hideItem('add');
        module_event.menu.hideItem('delete');
        module_event.menu.addNewChild('t1',3,'import_mapping', 'Import', false, 'import.gif', 'import_dis.gif');
        module_event.menu.addNewChild('t1',4,'export_mapping', 'Export', true, 'export.gif', 'export_dis.gif');
        module_event.menu.setItemText('t1', 'Import/Export Mapping');
        module_event.menu.setItemImage('t1', 'export.gif');
        module_event.menu.setItemPosition('t1', 2);

        // module_event.layout.cells('a').hideMenu();
        module_event.grid.attachEvent("onRowSelect", function(id,ind){
            module_event.menu.setItemEnabled('export_mapping');
        });
    })

    module_event.load_form = function(win, tab_id) {
        var is_new = win.getText();
        win.progressOff();
        var tab_id = (tab_id.indexOf("tab_") != -1) ? tab_id.replace("tab_", "") : tab_id;
        module_event["inner_tab_layout_" + tab_id] = win.attachLayout("1C");
        if (is_new == 'New') {
            id = '';
        } else {
            id = tab_id;
        }
        load_form_data(id);
    }

    function load_form_data(module_id) {
        load_url_event = [];
        load_url_rule_table = [];
        var active_tab_id = module_event.tabbar.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        var tab_json = '';

        var inner_tab_layout_json_general = [
            {
                id: "a",
                text: "<div><a class=\"undock_deals undock_custom\" title=\"Undock\" onClick=\"module_event.undock_cell('a')\"></a>Worlflow Event Mapping</div>",
                header: true,
                collapse: false,
                width : 400
            },
            {
                id: "b",
                text: "<div><a class=\"undock_deals undock_custom\" title=\"Undock\" onClick=\"module_event.undock_cell('b')\"></a>Workflow Data Source Mapping</div>",
                header: true,
                collapse: false,
                fix_size: [true, null]
            },
            {
                id: "c",
                text: "<div><a class=\"undock_deals undock_custom\" title=\"Undock\" onClick=\"module_event.undock_cell('c')\"></a>Workflow Message Tag</div>",
                header: true,
                collapse: false,
                fix_size: [true, null]
            }
        ];

        var inner_tab_layout_json_contacts = [
            {
                id: "a",
                text: "Workflow Contacts",
                header: true,
                collapse: false
            }
        ];

        inner_tab_layout_json = [inner_tab_layout_json_general,inner_tab_layout_json_contacts];
        result_length = form_json.length;
        for (i = 0; i < result_length; i++) {
            if (i > 0)
                tab_json = tab_json + ",";
            tab_json = tab_json + (form_json[i].tab_json);
        }
        tab_json = '{tabs: [' + tab_json + ']}';
        module_event["tabs_" + active_object_id] = module_event["inner_tab_layout_" + active_object_id].cells("a").attachTabbar();
        module_event["tabs_" + active_object_id].loadStruct(tab_json);
        module_event["tabs_" + active_object_id].setTabsMode("bottom");
        var tab_id_array = []
        for (i = 0; i < result_length; i++) {
            var layout_pattern =  form_json[i].layout_pattern;
            var tab_id = 'detail_tab_' + form_json[i].tab_id;
            tab_id_array.push(tab_id);
            module_event["inner_tab_layout_" + tab_id + "_" +active_object_id] = module_event["tabs_" + active_object_id].cells(tab_id).attachLayout({pattern: layout_pattern, cells: inner_tab_layout_json[i]});
        }
        tab_object[active_object_id] = tab_id_array
        for (j = 0; j < grid_definition_json.length; j++) {
            var grid_no = j;
            var tab_id = grid_definition_json[grid_no]["tab_id"];
            var grid_name = grid_definition_json[grid_no]["grid_name"];
            var grid_label = grid_definition_json[grid_no]["grid_label"];
            if (j == 0) {
                cell_name = grid_definition_json[grid_no]["cell_name"];
                toolbar_name = 'toolbar_grid_event_mapping';
                grid_name = 'grid_event_mapping';
                toolbar_json = toolbar_json_event;
            } else if (j == 1){
                cell_name = grid_definition_json[grid_no]["cell_name"];
                toolbar_name = 'toolbar_grid_rule_table_mapping';
                grid_name = 'grid_rule_table_mapping';
                toolbar_json = toolbar_json_rule;
            } else if (j == 2)  {
                cell_name = grid_definition_json[grid_no]["cell_name"];
                toolbar_name = 'toolbar_grid_workflow_message_tag';
                grid_name = 'grid_workflow_message_tag';
                toolbar_json = toolbar_json_tag;
            } else if (j == 3)  {
                cell_name = grid_definition_json[grid_no]["cell_name"];
                toolbar_name = 'toolbar_grid_worflow_contact_email';
                grid_name = 'grid_worflow_contact_email';
                toolbar_json = toolbar_json_email;
            }
            module_event[toolbar_name + active_object_id] = module_event["inner_tab_layout_" + tab_id + "_" + active_object_id].cells(cell_name).attachMenu();
            module_event["inner_tab_layout_" + tab_id + "_" + active_object_id].cells(cell_name).attachStatusBar({
                height: 30,
                text: '<div id="pagingAreaGrid_' +  grid_name + '_' + active_object_id + '"></div>'
            });
            var pagination_div_name = 'pagingAreaGrid_' + grid_name + '_' + active_object_id;
            module_event[toolbar_name + active_object_id].setIconsPath(js_image_path + "dhxmenu_web/");
            module_event[toolbar_name + active_object_id].loadStruct(toolbar_json);
            module_event[toolbar_name + active_object_id].attachEvent('onClick', module_event.grd_toolbar_click);

            if (!has_right_module_event_add) {
                module_event[toolbar_name + active_object_id].setItemDisabled('add');
                module_event[toolbar_name + active_object_id].setItemDisabled('delete');
            }
            module_event[grid_name + active_object_id] = module_event["inner_tab_layout_" + tab_id + "_" + active_object_id].cells(cell_name).attachGrid();
            module_event[grid_name + active_object_id].setImagePath("<?php echo $image_path; ?>dhxtoolbar_web/");
            module_event[grid_name + active_object_id].setHeader(grid_definition_json[grid_no]["column_label_list"]);
            module_event[grid_name + active_object_id].setColumnIds(grid_definition_json[grid_no]["column_name_list"]);
            module_event[grid_name + active_object_id].setColTypes(grid_definition_json[grid_no]["column_type_list"]);
            module_event[grid_name + active_object_id].attachHeader('#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter');
            module_event[grid_name + active_object_id].setInitWidths(grid_definition_json[grid_no]["column_width"]);
            module_event[grid_name + active_object_id].setColSorting(grid_definition_json[grid_no]["sorting_preference"]);
            module_event[grid_name + active_object_id].setColumnsVisibility(grid_definition_json[grid_no]["set_visibility"]);
            module_event[grid_name + active_object_id].setPagingWTMode(true, true, true, true);
            module_event[grid_name + active_object_id].enablePaging(true, 25, 0, pagination_div_name);
            module_event[grid_name + active_object_id].setPagingSkin('toolbar');
            module_event[grid_name + active_object_id].setDateFormat(user_date_format, "%Y-%m-%d");
            module_event[grid_name + active_object_id].enableMultiselect(true);
            module_event[grid_name + active_object_id].enableColumnMove(true);
            module_event[grid_name + active_object_id].enableValidation(true);
            module_event[grid_name + active_object_id].setColValidators(grid_definition_json[grid_no]["validation_rule"]);
            module_event[grid_name + active_object_id].setUserData("", "grid_id", grid_name);
            module_event[grid_name + active_object_id].setUserData("", "grid_label", grid_label);
            module_event[grid_name + active_object_id].init();
            module_event[grid_name + active_object_id].enableHeaderMenu();
            module_event[grid_name + active_object_id].enableColumnAutoSize(true);
            module_event[grid_name + active_object_id].loadOrderFromCookie(grid_name);
            module_event[grid_name + active_object_id].loadHiddenColumnsFromCookie(grid_name);
            module_event[grid_name + active_object_id].enableOrderSaving(grid_name);
            module_event[grid_name + active_object_id].enableAutoHiddenColumnsSaving(grid_name);

            if (j == 0) {
                module_event[grid_name + active_object_id].attachEvent("onValidationError",function(id,ind,value){
                    var active_tab_id = module_event.tabbar.getActiveTab();
                    var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
                    var active_tab = module_event["tabs_" + active_object_id].getActiveTab();
                    var layout_obj = module_event["tabs_" + active_object_id].cells(active_tab).getAttachedObject();
                    var grid_obj = layout_obj.cells('a').getAttachedObject();
                    var message = "Invalid Data";
                    grid_obj.cells(id,ind).setAttribute("validation", message);
                    return true;
                });
                module_event[grid_name + active_object_id].attachEvent("onValidationCorrect",function(id,ind,value){
                    var active_tab_id = module_event.tabbar.getActiveTab();
                    var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
                    var active_tab = module_event["tabs_" + active_object_id].getActiveTab();
                    var layout_obj = module_event["tabs_" + active_object_id].cells(active_tab).getAttachedObject();
                    var grid_obj = layout_obj.cells('a').getAttachedObject();
                    grid_obj.cells(id,ind).setAttribute("validation", "");
                    return true;
                });

                module_event[grid_name + active_object_id].attachEvent("onRowSelect", function(id,ind ){

                    var active_tab_id = module_event.tabbar.getActiveTab();
                    var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
                    var active_tab = module_event["tabs_" + active_object_id].getActiveTab();
                    var layout_obj = module_event["tabs_" + active_object_id].cells(active_tab).getAttachedObject();
                    var menu_obj = layout_obj.cells('a').getAttachedMenu();
                    if (has_right_module_event_delete){
                        menu_obj.setItemEnabled('delete_event');
                    }
                });
                
                var col_event = module_event[grid_name + active_object_id].getColIndexById('event_id');
                var cmb_event = module_event[grid_name + active_object_id].getColumnCombo(col_event);
                var combo_event_sql = {"action":"spa_StaticDataValues", "flag":"h", "type_id":20500, "has_blank_option" : false};
                var data = $.param(combo_event_sql);
                var url = js_dropdown_connector_url + '&' + data;
                cmb_event.enableFilteringMode('between');
                cmb_event.load(url);


            } else if (j == 1) {
                module_event[grid_name + active_object_id].attachEvent("onValidationError",function(id,ind,value){
                    var active_tab_id = module_event.tabbar.getActiveTab();
                    var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
                    var active_tab = module_event["tabs_" + active_object_id].getActiveTab();
                    var layout_obj = module_event["tabs_" + active_object_id].cells(active_tab).getAttachedObject();
                    var grid_obj = layout_obj.cells('b').getAttachedObject();
                    var message = "Invalid Data";
                    grid_obj.cells(id,ind).setAttribute("validation", message);
                    return true;
                });
                module_event[grid_name + active_object_id].attachEvent("onValidationCorrect",function(id,ind,value){
                    var active_tab_id = module_event.tabbar.getActiveTab();
                    var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
                    var active_tab = module_event["tabs_" + active_object_id].getActiveTab();
                    var layout_obj = module_event["tabs_" + active_object_id].cells(active_tab).getAttachedObject();
                    var grid_obj = layout_obj.cells('b').getAttachedObject();
                    grid_obj.cells(id,ind).setAttribute("validation", "");
                    return true;
                });

                module_event[grid_name + active_object_id].attachEvent("onRowSelect", function(id,ind ){
                    var active_tab_id = module_event.tabbar.getActiveTab();
                    var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
                    var active_tab = module_event["tabs_" + active_object_id].getActiveTab();
                    var layout_obj = module_event["tabs_" + active_object_id].cells(active_tab).getAttachedObject();
                    var menu_obj = layout_obj.cells('b').getAttachedMenu();
                    if (has_right_module_event_delete){
                        menu_obj.setItemEnabled('delete_rule');
                    }
                });

                var col_event = module_event[grid_name + active_object_id].getColIndexById('rule_table_id');
                var cmb_event = module_event[grid_name + active_object_id].getColumnCombo(col_event);
                var combo_event_sql = {"action":"spa_workflow_module_event_mapping", "flag":"r", "has_blank_option" : false};
                var data = $.param(combo_event_sql);
                var url = js_dropdown_connector_url + '&' + data;
                cmb_event.load(url);

                col_data_source = module_event[grid_name + active_object_id].getColIndexById('data_source_id');
                cmb_data_source = module_event[grid_name + active_object_id].getColumnCombo(col_data_source);
                combo_data_source_sql = {"action":"spa_workflow_module_event_mapping", "flag":"u"};
                data = $.param(combo_data_source_sql);
                url = js_dropdown_connector_url + '&' + data;
                cmb_data_source.load(url);

            } else if (j == 2) {
                module_event[grid_name + active_object_id].attachEvent("onValidationError",function(id,ind,value){
                    var active_tab_id = module_event.tabbar.getActiveTab();
                    var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
                    var active_tab = module_event["tabs_" + active_object_id].getActiveTab();
                    var layout_obj = module_event["tabs_" + active_object_id].cells(active_tab).getAttachedObject();
                    var grid_obj = layout_obj.cells('c').getAttachedObject();
                    var message = "Invalid Data";
                    grid_obj.cells(id,ind).setAttribute("validation", message);
                    return true;
                });
                module_event[grid_name + active_object_id].attachEvent("onValidationCorrect",function(id,ind,value){
                    var active_tab_id = module_event.tabbar.getActiveTab();
                    var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
                    var active_tab = module_event["tabs_" + active_object_id].getActiveTab();
                    var layout_obj = module_event["tabs_" + active_object_id].cells(active_tab).getAttachedObject();
                    var grid_obj = layout_obj.cells('c').getAttachedObject();
                    grid_obj.cells(id,ind).setAttribute("validation", "");
                    return true;
                });

                module_event[grid_name + active_object_id].attachEvent("onRowSelect", function(id,ind ){

                    var active_tab_id = module_event.tabbar.getActiveTab();
                    var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
                    var active_tab = module_event["tabs_" + active_object_id].getActiveTab();
                    var layout_obj = module_event["tabs_" + active_object_id].cells(active_tab).getAttachedObject();
                    var menu_obj = layout_obj.cells('c').getAttachedMenu();
                    if (has_right_module_event_delete){
                        menu_obj.setItemEnabled('delete_tag');
                    }
                });

                module_event[grid_name + active_object_id].attachEvent("onEmptyClick", function(ev ){

                    var active_tab_id = module_event.tabbar.getActiveTab();
                    var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
                    var active_tab = module_event["tabs_" + active_object_id].getActiveTab();
                    var layout_obj = module_event["tabs_" + active_object_id].cells(active_tab).getAttachedObject();
                    var grid_obj = layout_obj.cells('c').getAttachedObject();
                    grid_obj.editStop();
                });
                module_event[grid_name + active_object_id].setUserData("","show_system_defined","0");
            } else if (j == 3) {
                module_event[grid_name + active_object_id].attachEvent("onValidationError",function(id,ind,value){
                    var active_tab_id = module_event.tabbar.getActiveTab();
                    var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
                    var active_tab = module_event["tabs_" + active_object_id].getActiveTab();
                    var layout_obj = module_event["tabs_" + active_object_id].cells(active_tab).getAttachedObject();
                    var grid_obj = layout_obj.cells('a').getAttachedObject();
                    var message = "Invalid Data";
                    grid_obj.cells(id,ind).setAttribute("validation", message);
                    return true;
                });
                module_event[grid_name + active_object_id].attachEvent("onValidationCorrect",function(id,ind,value){
                    var active_tab_id = module_event.tabbar.getActiveTab();
                    var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
                    var active_tab = module_event["tabs_" + active_object_id].getActiveTab();
                    var layout_obj = module_event["tabs_" + active_object_id].cells(active_tab).getAttachedObject();
                    var grid_obj = layout_obj.cells('a').getAttachedObject();
                    grid_obj.cells(id,ind).setAttribute("validation", "");
                    return true;
                });

                module_event[grid_name + active_object_id].attachEvent("onRowSelect", function(id,ind ){

                    var active_tab_id = module_event.tabbar.getActiveTab();
                    var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
                    var active_tab = module_event["tabs_" + active_object_id].getActiveTab();
                    var layout_obj = module_event["tabs_" + active_object_id].cells(active_tab).getAttachedObject();
                    var menu_obj = layout_obj.cells('a').getAttachedMenu();
                    if (has_right_module_event_delete){
                        menu_obj.setItemEnabled('delete_email');
                    }
                });

                module_event[grid_name + active_object_id].attachEvent("onEmptyClick", function(ev ){

                    var active_tab_id = module_event.tabbar.getActiveTab();
                    var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
                    var active_tab = module_event["tabs_" + active_object_id].getActiveTab();
                    var layout_obj = module_event["tabs_" + active_object_id].cells(active_tab).getAttachedObject();
                    var grid_obj = layout_obj.cells('a').getAttachedObject();
                    grid_obj.editStop();
                });

                var col_group_type = module_event[grid_name + active_object_id].getColIndexById('group_type');
                var cmb_group_type = module_event[grid_name + active_object_id].getColumnCombo(col_group_type);
                var combo_group_type = {"action":"spa_workflow_module_event_mapping", "flag":"c", "has_blank_option" : false};
                var data = $.param(combo_group_type);
                var url = js_dropdown_connector_url + '&' + data;
                cmb_group_type.load(url);
            }

        }
        setTimeout(function () { // To insert data after combo has been loaded in grid
            module_event.refresh_grids();
        }, 1000);

    }

    module_event.grd_toolbar_click = function(id,zone) {
        var active_tab = '';
        var cell_name = 'a';

        var active_tab_id = module_event.tabbar.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        var active_tab = module_event["tabs_" + active_object_id].getActiveTab();
        var delete_id =  'delete';
        if (id == 'add_event' || id == 'delete_event') {
            cell_name = 'a';
            delete_id = 'delete_event';
            active_tab = tab_object[active_object_id][0];
        } else if (id == 'add_rule' || id == 'delete_rule') {
            cell_name = 'b';
            delete_id = 'delete_rule';
            active_tab = tab_object[active_object_id][0];
        } else if (id == 'add_tag' || id == 'delete_tag' || id == 'show_system_defined') {
            cell_name = 'c';
            delete_id = 'delete_tag';
            active_tab = tab_object[active_object_id][0];
        } else if (id == 'add_email' || id == 'delete_email') {
            cell_name = 'a';
            delete_id = 'delete_email';
            active_tab = tab_object[active_object_id][1];
        }

        var layout_obj = module_event["tabs_" + active_object_id].cells(active_tab).getAttachedObject();
        var grid_obj = layout_obj.cells(cell_name).getAttachedObject();
        var menu_obj = layout_obj.cells(cell_name).getAttachedMenu();
        if (id == 'add_event' || id == 'add_rule' || id == 'add_tag' || id == 'add_email') { //when add is clicked.
            var new_id = (new Date()).valueOf();
            new_id = new_id + '_grid';
            if (id == 'add_event')
                grid_obj.addRow(new_id, ["","",0]);
            else if (id == 'add_rule')
                grid_obj.addRow(new_id, ["","",0,"",0,"",""]);
            else if (id == 'add_tag')
                grid_obj.addRow(new_id, ["","","","",0,"",0]);
            else if (id == 'add_email')
                grid_obj.addRow(new_id, "");
            grid_obj.selectRow(grid_obj.getRowIndex(new_id), false, false, true);
            if (has_right_module_event_delete) {
                menu_obj.setItemEnabled(delete_id);
            }
            grid_obj.forEachRow(function(row){
                grid_obj.forEachCell(row,function(cellObj,ind){
                    grid_obj.validateCell(row,ind)
                });
            });
        } else if (id == 'delete_event' || id == 'delete_rule' || id == 'delete_tag' || id == 'delete_email') {//when is delete is clicked
            var selectedId = grid_obj.getSelectedRowId();
            if (!selectedId) {
                var message = get_message('VALIDATE_DATA');
                show_messagebox(message);
                return false;
            } else {
                var grid_xml = '';
                var deleted_xml = grid_obj.getUserData("", "delete_xml");
                var del_array = new Array();
                del_array = (selectedId.indexOf(",") != -1) ? selectedId.split(",") : selectedId.split();
                $.each(del_array, function(index, value) {
                    if ((grid_obj.cells(value, 0).getValue() != "") || (grid_obj.getUserData(value, "row_status") != "")) {
                        grid_xml += '<GridRow ';
                        for (var cellIndex = 0; cellIndex < grid_obj.getColumnsNum(); cellIndex++) {
                            var column_id = grid_obj.getColumnId(cellIndex);
                            var cell_value = grid_obj.cells(value, cellIndex).getValue();
                            if (column_id == 'workflow_message_tag' || column_id == 'workflow_tag_query' || column_id == 'application_function_id' || column_id == 'email_group_query' || column_id == 'email_address_query') {
                                cell_value = escapeXML(cell_value);
                            }
                            grid_xml += grid_obj.getColumnId(cellIndex) + '= "' + cell_value + '" ';
                        }

                        grid_xml += '></GridRow>';
                    }
                    grid_obj.deleteRow(value);
                });
                if (deleted_xml)
                    grid_xml = grid_xml + deleted_xml;

                grid_obj.setUserData("", "delete_xml", grid_xml);
                menu_obj.setItemDisabled(delete_id);
            }
         } else if (id == 'show_system_defined') {
            is_user_authorized('module_event.refresh_tag_grid');
         }
    }

    module_event.save_form = function() {
        var active_tab_id = module_event.tabbar.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        var layout_obj_general = module_event["tabs_" + active_object_id].cells(tab_object[active_object_id][0]).getAttachedObject();
        var layout_obj_contact = module_event["tabs_" + active_object_id].cells(tab_object[active_object_id][1]).getAttachedObject();
        var grid_obj_event = layout_obj_general.cells('a').getAttachedObject();
        var grid_obj_rule = layout_obj_general.cells('b').getAttachedObject();
        var grid_obj_tag = layout_obj_general.cells('c').getAttachedObject();
        var grid_obj_email = layout_obj_contact.cells('a').getAttachedObject();

        var grid_delete_xml_event = '<GridXMLEventDel>' + grid_obj_event.getUserData("", "delete_xml") + '</GridXMLEventDel>';
        var grid_delete_xml_rule = '<GridXMLRuleDel>' + grid_obj_rule.getUserData("", "delete_xml") + '</GridXMLRuleDel>';
        var grid_delete_xml_tag = '<GridXMLTagDel>' + grid_obj_tag.getUserData("", "delete_xml") + '</GridXMLTagDel>';
        var grid_delete_xml_email = '<GridXMLEmailDel>' + grid_obj_email.getUserData("", "delete_xml") + '</GridXMLEmailDel>';

        grid_obj_event.clearSelection();
        grid_obj_rule.clearSelection();
        grid_obj_tag.clearSelection();
        grid_obj_email.clearSelection();

        var grid_xml_event = '<GridXMLEvent>';
        var grid_xml_rule = '<GridXMLRule>';
        var grid_xml_tag = '<GridXMLTag>';
        var grid_xml_email = '<GridXMLEmail>';
        grid_label_event = grid_obj_event.getUserData("", "grid_label");
        grid_label_rule = grid_obj_rule.getUserData("", "grid_label");
        grid_label_tag = grid_obj_tag.getUserData("", "grid_label");
        grid_label_email = grid_obj_email.getUserData("", "grid_label");

        grid_obj_event.setSerializationLevel(false, false, true, true, true, true);
        grid_obj_rule.setSerializationLevel(false, false, true, true, true, true);
        grid_obj_tag.setSerializationLevel(false, false, true, true, true, true);
        grid_obj_email.setSerializationLevel(false, false, true, true, true, true);
        var grid_status = module_event.validate_form_grid(grid_obj_event, grid_label_event);
        if (!grid_status)
            return;

        grid_status = module_event.validate_form_grid(grid_obj_rule, grid_label_rule);
        if (!grid_status)
            return;

        grid_status = module_event.validate_form_grid(grid_obj_tag, grid_label_tag);
        if (!grid_status)
            return;

        grid_status = module_event.validate_form_grid(grid_obj_email, grid_label_email);
        if (!grid_status)
            return;

        /*XML for Event Mapping grid*/
        grid_obj_event.forEachRow(function(rid) {
            grid_xml_event += '<GridRow ';
            grid_obj_event.forEachCell(rid,function(cellObj,ind){
                var column_id = grid_obj_event.getColumnId(ind);
                var cell_value = grid_obj_event.cells(rid, ind).getValue();
                grid_xml_event += ' ' + column_id + '="' + cell_value + '"';
            });
            grid_xml_event += '></GridRow>';
        });
        grid_xml_event += '</GridXMLEvent>';

        /*XML for Rule Table Mapping grid*/
        grid_obj_rule.forEachRow(function(rid) {
            grid_xml_rule += '<GridRow ';
            grid_obj_rule.forEachCell(rid,function(cellObj,ind){
                var column_id = grid_obj_rule.getColumnId(ind);
                var cell_value = grid_obj_rule.cells(rid, ind).getValue();
                grid_xml_rule += ' ' + column_id + '="' + cell_value + '"';
            });
            grid_xml_rule += '></GridRow>';
        });
        grid_xml_rule += '</GridXMLRule>';

        /*XML for Workflow message tag grid*/
        var col_is_hyperlink = grid_obj_tag.getColIndexById('is_hyperlink');
        var col_application_function_id = grid_obj_tag.getColIndexById('application_function_id');
        var valid_status = false;
        grid_obj_tag.forEachRow(function(rid) {
            var is_hyperlink = grid_obj_tag.cells(rid,col_is_hyperlink).getValue();
            var application_function_id = grid_obj_tag.cells(rid,col_application_function_id).getValue();
            if (is_hyperlink == 1 && (!application_function_id || application_function_id == '' || application_function_id == null))
                valid_status = true;
            grid_xml_tag += '<GridRow ';
            grid_obj_tag.forEachCell(rid,function(cellObj,ind){
                var column_id = grid_obj_tag.getColumnId(ind);
                var cell_value = grid_obj_tag.cells(rid, ind).getValue();
                if (column_id == 'workflow_message_tag' || column_id == 'workflow_tag_query' || column_id == 'application_function_id' || column_id == 'email_group_query' || column_id == 'email_address_query') {
                    cell_value = escapeXML(cell_value);
                }
                grid_xml_tag += ' ' + column_id + '="' + cell_value + '"';
            });
            grid_xml_tag += '></GridRow>';
        });
        grid_xml_tag += '</GridXMLTag>';

        if (valid_status) {
            dhtmlx.alert({
                type: "alert",
                title:'Alert',
                text:"Function ID must be present for hyperlink tag."
            });
            return;
        }


        /*XML for Workflow message Email grid*/
        grid_obj_email.forEachRow(function(rid) {
            grid_xml_email += '<GridRow ';
            grid_obj_email.forEachCell(rid,function(cellObj,ind){
                var column_id = grid_obj_email.getColumnId(ind);
                var cell_value = grid_obj_email.cells(rid, ind).getValue();
                if (column_id == 'email_group_query' || column_id == 'email_address_query') {
                    cell_value = escapeXML(cell_value);
                }
                grid_xml_email += ' ' + column_id + '="' + cell_value + '"';
            });
            grid_xml_email += '></GridRow>';
        });
        grid_xml_email += '</GridXMLEmail>';

        grid_xml = '<Root>'
                    + grid_xml_event
                    + grid_xml_rule
                    + grid_xml_tag
                    + grid_xml_email
                    + grid_delete_xml_event
                    + grid_delete_xml_rule
                    + grid_delete_xml_tag
                    + grid_delete_xml_email
                    + '</Root>';
        data = {"action": "spa_workflow_module_event_mapping",
            "flag": "i",
            "module_id" : active_object_id,
            "xml": grid_xml
        };

        if (grid_obj_event.getUserData("", "delete_xml") || grid_obj_rule.getUserData("", "delete_xml") || grid_obj_tag.getUserData("", "delete_xml") || grid_obj_email.getUserData("", "delete_xml")) {
            del_msg =  "Some data has been deleted from grid. Are you sure you want to save ?";
            result = adiha_post_data("confirm-warning", data, "", "", "module_event.refresh_grids","",del_msg);
        } else {
            adiha_post_data("return_array", data, "", "", "module_event.save_callback");
        }

    }

    module_event.save_callback = function(result) {
        if (result[0][0] == "Success") {
            dhtmlx.message({
                text:result[0][4],
                expire:1000
            });
            module_event.refresh_grids();
        } else {
            dhtmlx.message({
                title:"Alert",
                type:"alert",
                text:result[0][4]
            });
        }
    }

    module_event.refresh_grids = function() {
        var active_tab_id = module_event.tabbar.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        var layout_obj_general = module_event["tabs_" + active_object_id].cells(tab_object[active_object_id][0]).getAttachedObject();
        var layout_obj_contact = module_event["tabs_" + active_object_id].cells(tab_object[active_object_id][1]).getAttachedObject();
        var grid_obj_event = layout_obj_general.cells('a').getAttachedObject();
        var grid_obj_rule = layout_obj_general.cells('b').getAttachedObject();
        var grid_obj_tag = layout_obj_general.cells('c').getAttachedObject();
        var grid_obj_email = layout_obj_contact.cells('a').getAttachedObject();
        var show_system_defined = grid_obj_tag.getUserData("","show_system_defined");
        var param = {"action": "spa_workflow_module_event_mapping",
                     "flag": "a",
                     "module_id":active_object_id,
                     "grid_type": "g"
        };
        param = $.param(param);
        var param_url = js_data_collector_url + "&" + param;
        grid_obj_event.clearAndLoad(param_url);

        param = {"action": "spa_workflow_module_event_mapping",
            "flag": "b",
            "module_id":active_object_id,
            "grid_type": "g"
        };
        param = $.param(param);
        param_url = js_data_collector_url + "&" + param;
        grid_obj_rule.clearAndLoad(param_url, function(){
            var col_is_active = grid_obj_rule.getColIndexById('is_active');
            grid_obj_rule.forEachRow(function(row){
                grid_obj_rule.forEachCell(row,function(cellObj,ind){
                    if (col_is_active == ind)
                        grid_obj_rule.cells(row,ind).setDisabled(false);
                    else
                        grid_obj_rule.cells(row,ind).setDisabled(true);
                });
            });
        });

        param = {"action": "spa_workflow_module_event_mapping",
            "flag": "s",
            "module_id":active_object_id,
            "show_system_defined":show_system_defined,
            "grid_type": "g"
        };
        param = $.param(param);
        param_url = js_data_collector_url + "&" + param;
        grid_obj_tag.clearAndLoad(param_url);

        param = {"action": "spa_workflow_module_event_mapping",
            "flag": "e",
            "module_id":active_object_id,
            "grid_type": "g"
        };
        param = $.param(param);
        param_url = js_data_collector_url + "&" + param;
        grid_obj_email.clearAndLoad(param_url);

        grid_obj_event.setUserData("", "delete_xml", "");
        grid_obj_rule.setUserData("", "delete_xml", "");
        grid_obj_tag.setUserData("", "delete_xml", "");
        grid_obj_email.setUserData("", "delete_xml", "");
    }

    module_event.refresh_tag_grid = function() {
        var active_tab_id = module_event.tabbar.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        var layout_obj_general = module_event["tabs_" + active_object_id].cells(tab_object[active_object_id][0]).getAttachedObject();
        var layout_obj_contact = module_event["tabs_" + active_object_id].cells(tab_object[active_object_id][1]).getAttachedObject();
        var grid_obj_tag = layout_obj_general.cells('c').getAttachedObject();
        var menu_obj_tag = layout_obj_general.cells('c').getAttachedMenu();
        var param = {"action": "spa_workflow_module_event_mapping",
            "flag": "s",
            "module_id":active_object_id,
            "show_system_defined":1,
            "grid_type": "g"
        };
        param = $.param(param);
        var param_url = js_data_collector_url + "&" + param;
        grid_obj_tag.clearAndLoad(param_url);
        grid_obj_tag.setUserData("", "delete_xml", "");
        grid_obj_tag.setUserData("", "show_system_defined", "1");
        menu_obj_tag.setItemDisabled('show_system_defined');
    }

    module_event.grid_menu_click = function(id, zoneId, cas) {
        var selected_row = "";
        switch(id) {
            case "import_mapping":
                if (module_event.import_window != null && module_event.import_window.unload != null) {
                    module_event.import_window.unload();
                    module_event.import_window = w2 = null;
                }
                if (!module_event.import_window) {
                    module_event.import_window = new dhtmlXWindows();
                }

                module_event.new_win = module_event.import_window.createWindow('w2', 0, 0, 650, 250);

                var text = "Import Definitions";

                module_event.new_win.setText(text);
                module_event.new_win.setModal(true);

                var url = 'manage.alert.workflow.import.export.php';
                url = url + '?flag=import_definitions&call_from=mapping';
                module_event.new_win.attachURL(url, false, true);
                break;           
            case "export_mapping":
                var selected_id = module_event.grid.getSelectedRowId();
                if (!selected_id || selected_id == '') {
                    dhtmlx.alert({
                        type: "alert",
                        title:'Alert',
                        text:"No module selected."
                    });
                    return;
                }

                if (selected_id.split(',').length > 1) {
                    dhtmlx.alert({
                        type: "alert",
                        title:'Alert',
                        text:"Select single module."
                    });
                    return;
                }
                var col_module_id = module_event.grid.getColIndexById('module_id');
                var module_id = module_event.grid.cells(selected_id,col_module_id).getValue();
                data = {"action": "spa_workflow_import_export",
                    "flag": "export_definitions",
                    "module_id": module_id
                };
                adiha_post_data('return_array', data, '', '', 'module_event.download_script', '', '');
        }
    };

    module_event.download_script = function(result) {
        var selected_id = module_event.grid.getSelectedRowId();
        var col_module_name = module_event.grid.getColIndexById('module_name');
        var module_name = module_event.grid.cells(selected_id,col_module_name).getValue();
        var ua = window.navigator.userAgent;
        var msie = ua.indexOf("MSIE ");
        var blob = null;
        if (msie > 0|| !!navigator.userAgent.match(/Trident.*rv\:11\./)) { // Code to download file for IE
            if ( window.navigator.msSaveOrOpenBlob && window.Blob ) {
                blob = new Blob( [result[0][0]], { type: "text/csv;charset=utf-8;" } );
                navigator.msSaveOrOpenBlob( blob, module_name+ "_import.txt" );
            }
        }
        else { // Code to download file for other browser
            blob = new Blob([result[0][0]],{type: "text/csv;charset=utf-8;"});
            var link = document.createElement("a");
            if (link.download !== undefined) {
                var url = URL.createObjectURL(blob);
                link.setAttribute("href", url);
                link.setAttribute("download", module_name+ "_import.txt");
                link.style = "visibility:hidden";
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);
            }
        }
    }

    function import_from_file(file_name) {
        module_event.layout.progressOn();
        module_event.new_win.close();
        data = {"action": "spa_workflow_import_export",
                "flag": "check_if_module_event_exists",
                "import_file": file_name
               }
        adiha_post_data('return_json', data, '', '', function(result) {
            if (JSON.parse(result)[0]['recommendation'] == 1) {
                msg =  "Data already exist. Are you sure you want to replace data?";
                data = {"action": "spa_workflow_import_export",
                        "flag": "import_definitions",
                        "import_file": file_name
                };
                dhtmlx.message({
                    type: "confirm",
                    title: "Confirmation",
                    text: msg,
                    ok: "Confirm",
                    callback: function(result) {
                        if (result) {
                            setTimeout(function() { /*Loading icon was not loaded without adding some delay*/
                                adiha_post_data('return_array', data, '', '', 'module_event.post_import', '', '');
                            }, 10);
                        } else {
                            module_event.layout.progressOff();
                        }
                    }
                });
            } else if (JSON.parse(result)[0]['recommendation'] == 0) {
                data = {"action": "spa_workflow_import_export",
                    "flag": "import_definitions",
                    "import_file": file_name
                };
                setTimeout(function() { /*Loading icon was not loaded without adding some delay*/
                    adiha_post_data('return_array', data, '', '', 'module_event.post_import', '', '');
                }, 10);
            } else {
                dhtmlx.alert({
                    title:"Alert",
                    type:"alert",
                    text:"Import file is not properly formatted. Please check.",
                    callback: function() {
                        module_event.layout.progressOff();
                    }
                });
            }         
        }, '', '');
    }

    module_event.post_import = function(result) {
        var module_id = result[0][5];
        if (result[0][0] == "Success") {
            dhtmlx.message({
                text:result[0][4],
                expire:1000
            });

            // Refesh grid data if import module is 
            module_event.reload_tab_if_module_mapping_is_opened_during_import(module_id);
            module_event.refresh_grid("", module_event.enable_menu_item);
            module_event.layout.progressOff();
        } else {
            dhtmlx.message({
                title:"Alert",
                type:"alert",
                text:result[0][4],
                callback: function() {
                    module_event.reload_tab_if_module_mapping_is_opened_during_import(module_id);
                    module_event.refresh_grid("", module_event.enable_menu_item);
                    module_event.layout.progressOff();
                }
            });
        }
    }

    module_event.undock_cell = function(cell) {
        var active_tab_id = module_event.tabbar.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        var layout_obj_general = module_event["tabs_" + active_object_id].cells(tab_object[active_object_id][0]).getAttachedObject();
        layout_obj_general.cells(cell).undock(300, 300, 900, 700);
        layout_obj_general.dhxWins.window(cell).button("park").hide();
        layout_obj_general.dhxWins.window(cell).maximize();
        layout_obj_general.dhxWins.window(cell).centerOnScreen();
    }

    encode_html_entity = function(str) {
        if (!str || str == '')
            return '';
        str = unescape(str.replace(/'/g,"''"));
        str = str.replace(/</g, '&lt;');
        str = str.replace(/>/g, '&gt;');
        str = str.replace(/&/g,"&amp;");
        str = str.replace(/"/g,"&quot;");
        return str;
    }

    /**
     * Reload grid data by closing and re-opening tab if module mapping is opened during import where tab does not necessarily have to be active.
     * 
     * @param   {int}  module_id  ID of module mapping which just got imported
     */
    module_event.reload_tab_if_module_mapping_is_opened_during_import = function(module_id) {
        var tabs = module_event.tabbar.getAllTabs();
        var tab_index = tabs.indexOf('tab_' + module_id);

        if (tabs.length > 0 && tab_index > -1) {
            module_event.tabbar.tabs('tab_' + module_id).setActive();
            load_form_data();
        }
    }

</script>