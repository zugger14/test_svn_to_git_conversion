<?php
/**
 * Designation of a hedge screen
 * @copyright Pioneer Solutions
 */
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../../../adiha.php.scripts/components/include.file.v3.php'); ?>
    <?php require('../../../../../adiha.html.forms/_setup/manage_documents/manage.documents.button.php'); ?>
</head>
<body>
<?php
$php_script_loc = $app_php_script_loc;
$app_user_loc = $app_user_name;
$module_type = '';//"15500"; //Fas (module type)
list($default_as_of_date_to, $default_as_of_date_from) = getDefaultAsOfDate($module_type);

$active_object_id = isset($_POST['active_object_id']) ? $_POST['active_object_id'] : 'NULL';
$function_id = isset($_POST['function_id']) ? $_POST['function_id'] : 'NULL';
$link_name = isset($_POST['link_name']) ? $_POST['link_name'] : 'NULL';
$allow_change = isset($_POST['allow_change']) ? $_POST['allow_change'] : 'NULL';
$assessment_result = isset($_POST['assessment_result']) ? $_POST['assessment_result'] : 0;
$deal_match_param = isset($_POST['deal_match_param']) ? $_POST['deal_match_param'] : 'New';
$link_id = str_replace('tab_', '', $active_object_id);

if ($link_id  == $assessment_result) {
    $xml_file = "EXEC spa_faslinkheader @flag='get_assessment_result', @link_id='" . $link_id . "'";
    $return_value = readXMLURL($xml_file);
    $assessment_result = $return_value[0][0];
}

$assessment_approach = '';

if ($link_id != 'deal_match' AND $link_id != '') {
    $sql_query = "EXEC spa_faslinkheader @flag='z', @link_id=" . $link_id;
    $assessment_approach_arr = readXMLURL2($sql_query);
    $assessment_approach = $assessment_approach_arr[0]['assessment_approach_id'] ?? '';
}

$rights_designation_of_hedge = 10233700;
$rights_designation_of_hedge_iu = 10233710;
$rights_designation_of_hedge_delete = 10233718;
$rights_de_designation = 10233719;  //Dedesignate
$rights_update_delete_closed_hedge = 10233721;
$rights_view_assessement = 10232300;
$rights_view_assessement_ui = 10232410; //required for form loading.
$rights_document = 10102900;


//10233711 - Run Analysis Hedging RelationShip

list (
    $has_rights_designation_of_hedge,
    $has_rights_designation_of_hedge_iu,
    $has_rights_designation_of_hedge_delete,
    $has_rights_de_designation,
    $has_rights_update_delete_closed_hedge,
    $has_rights_view_assessement_ui,
    $has_rights_view_assessement,
    $has_document_rights
    ) = build_security_rights(
    $rights_designation_of_hedge,
    $rights_designation_of_hedge_iu,
    $rights_designation_of_hedge_delete,
    $rights_de_designation,
    $rights_update_delete_closed_hedge,
    $rights_view_assessement_ui,
    $rights_view_assessement,
    $rights_document
);

$form_sql = "EXEC spa_get_report_param_id @flag='s', @report_name='Assessment Results Plot'";
$assessmentresultsplot = readXMLURL2($form_sql);
$items_combined_plot = $assessmentresultsplot[0]['items_combined'];
$paramset_id_plot = $assessmentresultsplot[0]['paramset_id'];

$form_sql = "EXEC spa_get_report_param_id @flag='s', @report_name='Assessment Results Plot Series'";
$assessmentresultsplotseries = readXMLURL2($form_sql);
$items_combined_plot_series = $assessmentresultsplotseries[0]['items_combined'];
$paramset_id_plot_series = $assessmentresultsplotseries[0]['paramset_id'];

$form_sql = "EXEC spa_get_report_param_id @flag='s', @report_name='Assessment Results Plot Trends'";
$assessmentresultsplottrends = readXMLURL2($form_sql);
$items_combined_plot_trends = $assessmentresultsplottrends[0]['items_combined'];
$paramset_id_plot_trends = $assessmentresultsplottrends[0]['paramset_id'];


$namespace = 'ns_des_hedge';
//Attaching main layout
$layout_obj = new AdihaLayout();
$layout_json = '[
                        {id: "a", text: "Form",header: false, collapse: false, fix_size: [false,null]}                        
                    ]';
$patterns = '1C';

$layout_name = 'layout_des_hedge';
echo $layout_obj->init_layout($layout_name,'', $patterns,$layout_json, $namespace);

//Attaching objects in cell c

if (strrpos($active_object_id, "deal_match") === false) {
    $toolbar_obj = new AdihaToolbar();
    $toolbar_name = 'toolbar_des_hedge';
    $toolbar_json = "[
                            { id: 'save', type: 'button', img: 'save.gif', imgdis:'save_dis.gif', text: 'Save', title: 'Save', disable:true}
                        ]";
    echo $layout_obj->attach_toolbar($toolbar_name, 'a');
    echo $toolbar_obj->init_by_attach($toolbar_name, $namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', $namespace . '.tab_toolbar_click');
}

//Unload main layout
echo $layout_obj->close_layout();

$sp_url = "EXEC spa_adiha_default_codes_values @flag=s, @default_code_id=33";
$resultset = readXMLURL($sp_url);
if (count($resultset) > 0) $defaultvalue = $resultset[0][3];
else  $defaultvalue = 0;

$form_sql = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='" . $rights_designation_of_hedge_iu . "', @template_name='DesignationOfHedgeUI', @group_name='Link Info,Hedges/Items,Dedesignation,Original Link,Assessment Result', @parse_xml='<Root><PSRecordset link_id=\"\"></PSRecordset></Root>'";
$form_data = readXMLURL2($form_sql);

$tab_data = array();
$grid_definition = array();
$tab_form_json = array();

if (is_array($form_data) && sizeof($form_data) > 0) {
    foreach ($form_data as $data) {
        array_push($tab_data, $data['tab_json']);
        array_push($tab_form_json, $data['form_json']);

        // Grid data collection
        $grid_json = array();
        $pre = strpos($data['grid_json'], '[');
        if ($pre === false) {
            $data['grid_json'] = '[' . $data['grid_json'] . ']';
        }

        $grid_json = json_decode($data['grid_json'], true);
        foreach ($grid_json as $grid) {
            $grid_def = "EXEC spa_adiha_grid 's', '" . $grid['grid_id'] . "'";
            $def = readXMLURL2($grid_def);

            $it = new RecursiveIteratorIterator(new RecursiveArrayIterator($def));
            $l = iterator_to_array($it, true);

            array_push($grid_definition, $l);
        }
    }
}

$grid_tab_data = 'tabs: [' . implode(",", $tab_data) . ']';
$grid_definition_json = json_encode($grid_definition);
$tab_form_json = json_encode($tab_form_json);

$query_date = date('Y-m-d');

// First day of the month.
$first_day = date('Y-m-01', strtotime($query_date));

// Last day of the month.
$last_day = date('Y-m-t', strtotime($query_date));

$ass_dropdown = '[
                                    {value:"i", text:"Inception"},
                                    {value:"o", text:"Ongoing"},
                                    {value:"b", text:"Both"}
                                ]';
$ass_form_structure = '[
                            {"type":"settings","position":"label-top"},
                            {type: "block", blockOffset: 10, list: [
                               {"type": "calendar", "validate":"NotEmptywithSpace", required:true,"offsetLeft":"20","labelWidth":120,"inputWidth":150, "userdata":{"validation_message":"Required Field"}, "dateFormat":"' . $date_format . '", "serverDateFormat": "%Y-%m-%d", 
                               "name": "date_from", "label": "As of Date From", "value": "' . $first_day . '"},
                               {"type":"newcolumn"},
                               {"type": "calendar", "validate":"NotEmptywithSpace", required:true,"offsetLeft":"20","labelWidth":120,"inputWidth":150, "userdata":{"validation_message":"Required Field"}, "dateFormat":"' . $date_format . '", "serverDateFormat": "%Y-%m-%d", "name": "date_to", "label": "As of Date To", "value": "' . $last_day . '"},
                               {"type":"newcolumn"},
                               {"type":"combo",name:"initial_ongoing",required:true,label:"Assessment","tooltip":"","offsetLeft":"20","labelWidth":120,"inputWidth":150,options:' . $ass_dropdown . ',disabled:false},
                                ]
                            }
                            ]';
?>
</body>
<textarea style="display:none" name="txt_hedges_process_table" id="txt_hedges_process_table"></textarea>
<textarea style="display:none" name="txt_items_process_table" id="txt_items_process_table"></textarea>
<script>
    var assessment_approach = '<?php echo $assessment_approach; ?>';
    var active_object_id = '<?php echo $active_object_id; ?>';
    var active_tab_id = (active_object_id.indexOf("tab_") != -1) ? active_object_id.replace("tab_", "") : active_object_id;
    var php_script_loc = '<?php echo $php_script_loc; ?>';
    var link_name = '<?php echo $link_name?>';
    ns_des_hedge.details_layout = {};
    ns_des_hedge.details_toolbar = {};
    ns_des_hedge.details_tabs = {};
    ns_des_hedge.details_form = {};
    ns_des_hedge.details_grid = {};
    ns_des_hedge.details_menu = {};

    var grid_definition_json = <?php echo $grid_definition_json; ?>;

    var lock_link = false;
    var lock_link_enabled = true;

    var rights_view_assessement_ui = <?php echo $rights_view_assessement_ui;?>;
    var has_rights_link_iu = Boolean(<?php echo $has_rights_designation_of_hedge_iu; ?>);
    var has_rights_link_delete = Boolean(<?php echo $has_rights_designation_of_hedge_delete; ?>);
    var has_rights_link_assessment = Boolean(<?php echo $has_rights_view_assessement; ?>);
    var has_rights_de_designation = Boolean(<?php echo $has_rights_de_designation; ?>);
    var has_rights_update_delete_closed_hedge = Boolean(<?php echo $has_rights_update_delete_closed_hedge; ?>);

    var has_rights_hedge_item_dicing = Boolean(<?php echo ($has_rights_hedge_item_dicing ?? '0'); ?>);

    var category_id = 42; //Note type Designation of Hedge
    var has_document_rights = <?php echo (($has_document_rights) ? $has_document_rights : '0'); ?>;;
    var client_date_format = '<?php echo $date_format; ?>';
    var deal_match_param = '<?php echo $deal_match_param; ?>';
    var dice_window;
    var new_win;
    var fully_dedesignated;
    var processing_grid_obj;

    $(function() {
        ns_des_hedge.load_form();
    });

    ns_des_hedge.load_form = function() {
        win = ns_des_hedge.layout_des_hedge.cells("a");
        win.progressOff();
        var link_id = (active_object_id.indexOf("tab_") != -1) ? active_object_id.replace("tab_", "") : active_object_id;
        ns_des_hedge.details_layout["details_layout_" + active_tab_id] = win.attachLayout({
            pattern: "1C",
            cells: [
                {
                    id: "a",
                    text: "Main",
                    header: true,
                    collapse: false,
                    height: 200,
                    fix_size: [true, null]
                }
            ]
        });
        var  grid_tab_data = '<?php echo $grid_tab_data; ?>';
        var main_layout_obj = ns_des_hedge.details_layout["details_layout_" + active_tab_id];
        ns_des_hedge.details_tabs["detail_tab_" + active_tab_id] = main_layout_obj.cells("a").attachTabbar({
            mode: "bottom",
            arrows_mode: "auto",
            <?php echo $grid_tab_data; ?>
        });

        var main_tabbar_obj = ns_des_hedge.details_tabs["detail_tab_" + active_tab_id];
        var first_tab;
        var designation_tab_id;

        var form_index = "details_form_" + active_tab_id + "_0";

        if (active_object_id.indexOf("tab_") == 0) {
            add_manage_document_button(link_id, ns_des_hedge.toolbar_des_hedge, has_document_rights);
        }

        main_tabbar_obj.forEachTab(function(tab) {
            var tab_id = tab.getId();
            var tab_index = tab.getIndex();
            var tab_text = tab.getText();

            switch (tab_index) {
                case 0:
                    first_tab = tab_id;
                    ns_des_hedge.load_first_tab(tab);
                    break;
                case 1:
                    if (link_name == 'Deal Match') {
                        ns_des_hedge.load_deal_match_tab(tab);
                    } else {
                        ns_des_hedge.load_hedge_item_tab(tab);
                    }

                    break;
                case 2:
                    designation_tab_id = tab_id
                    ns_des_hedge.load_second_tab(tab);
                    break;
                case 3:
                    var original_link_id = ns_des_hedge.details_form[form_index].getItemValue('original_link_id');
                    if (original_link_id == '') {
                        tab.hide(first_tab);
                        break;
                    }
                    ns_des_hedge.load_third_tab(tab);
                    break;
                case 4:

                    var assessment_result = '<?php echo $assessment_result; ?>';

                    if (assessment_result != 1 || assessment_approach == 320) {
                        tab.hide(first_tab);
                        break;
                    }

                    ns_des_hedge.load_fourth_tab(tab);
                    break;
            }
        });

        // ns_des_hedge.details_form['details_form_' + active_tab_id + '_0'].attachEvent('onOptionsLoaded', function(name) {
        //if (name == 'link_type_value_id') {
        var link_type_value_id = ns_des_hedge.details_form['details_form_' + active_tab_id + '_0'].getItemValue('link_type_value_id')

        if (link_type_value_id != 450) {
            main_tabbar_obj.tabs(first_tab).setText('Dedesignated Link');
        } else {
            main_tabbar_obj.tabs(first_tab).setText('Link Info');
        }

        if ((active_object_id.indexOf("tab_") != -1)) {
            lock_link_checked();
        }
        //}
        //});

        if (link_name == 'Deal Match' && deal_match_param == 'New') {
            main_tabbar_obj.tabs(first_tab).close();
            main_tabbar_obj.tabs(designation_tab_id).close();
        } else if (link_name == 'New') {
            main_tabbar_obj.tabs(designation_tab_id).hide();
        } else {
            main_tabbar_obj.tabs(first_tab).setActive();
        }

        if (!has_rights_link_iu && deal_match_param != 'New') {
            ns_des_hedge.toolbar_des_hedge.disableItem('save');
        }
    }
    // ends form load

    /* loading tabs */
    ns_des_hedge.load_first_tab = function(tab_obj){
        var tab_id = tab_obj.getId();
        var tab_index = tab_obj.getIndex();

        //Attach cell layout 3E
        var form_index = "details_form_" + active_tab_id + "_" + tab_index;

        ns_des_hedge.details_layout[form_index] = tab_obj.attachLayout({
            pattern: "1C",
            cells: [
                {id: "a", text: "Link Info", collapse: false, header: true,height:150,fix_size: [true, null]},
            ]
        });

        var layout_obj = ns_des_hedge.details_layout[form_index];

        ns_des_hedge.details_form[form_index] = layout_obj.cells('a').attachForm();
        var form_obj = ns_des_hedge.details_form[form_index];
        //active_tab_id is link_id
        var xml_value = '<Root><PSRecordset link_id="' + active_tab_id + '"></PSRecordset></Root>';
        var template_name = 'DesignationOfHedgeUI';
        data = {"action": "spa_create_application_ui_json",
            "flag": "j",
            "application_function_id": '<?php echo $rights_designation_of_hedge_iu; ?>',
            "template_name": template_name,
            "parse_xml": xml_value,
            "group_name": 'Link Info'
        };
        result = adiha_post_data('return_array', data, '', '', 'ns_des_hedge.load_form_data', false);
        var link_id = active_tab_id;
        var form_index = "details_form_" + active_tab_id + "_0";
        var general_form_obj = ns_des_hedge.details_form[form_index];
        general_form_obj.attachEvent('onChange', function(name, value, is_checked) {
            if (name == 'lock') {
                lock_link_checked();

                if (has_rights_link_delete == true && is_checked == false) {
                    parent.parent.link_ui.left_menu.setItemEnabled('delete');
                } else {
                    parent.parent.link_ui.left_menu.setItemDisabled('delete');
                }
            }
        });

        if (deal_match_param.indexOf('right_grid') == -1 && link_name == 'New') {
            general_form_obj.checkItem('perfect_hedge');
        }

        if (link_id.indexOf('-') > -1) ns_des_hedge.set_item_value_virtual_links(link_id);
    }

    ns_des_hedge.load_deal_match_tab = function(tab_obj) {
        var main_tabbar_obj = ns_des_hedge.details_tabs["detail_tab_" + active_tab_id];
        main_tabbar_obj.progressOn();
        var php_path = '<?php echo $app_adiha_loc; ?>';
        var tab_id = tab_obj.getId();
        var url = php_path + 'adiha.html.forms/_accounting/derivative/transaction_processing/des_of_a_hedge/deal.match.des.of.hedge.php';
        main_tabbar_obj.tabs(tab_id).attachURL(url);
        main_tabbar_obj.attachEvent("onContentLoaded", function(name){
            main_tabbar_obj.progressOff();
        });
    }

    ns_des_hedge.load_hedge_item_tab = function(tab_obj) {
        var tab_id = tab_obj.getId();
        var tab_index = tab_obj.getIndex();

        var form_index = "details_form_" + active_tab_id + "_" + tab_index;

        ns_des_hedge.details_layout[form_index] = tab_obj.attachLayout({
            pattern: "2U",
            cells: [
                {id: "a", text: "<div><a class=\"undock_hedges undock_custom\" title=\"Undock\" onClick=\"ns_des_hedge.undock_cell('a')\"></a>Hedges</div>", collapse: false, header: true,height:150,fix_size: [false, null]},
                {id: "b", text: "<div><a class=\"undock_items undock_custom\" title=\"Undock\" onClick=\"ns_des_hedge.undock_cell('b')\"></a>Items</div>", collapse: false, header: true,fix_size: [false, null]}
            ]
        });

        var layout_obj = ns_des_hedge.details_layout[form_index];
        load_grid_n_menu(layout_obj.cells('a'), 'hedges');
        load_grid_n_menu(layout_obj.cells('b'), 'items');
    }

    ns_des_hedge.set_item_value_virtual_links = function(link_id) {
        data = {"action": "spa_faslinkheader",
            "flag": "a",
            "link_id": link_id
        };
        result = adiha_post_data('return_array', data, '', '', 'ns_des_hedge.set_item_value_virtual_links_callback', false);
    }

    ns_des_hedge.set_item_value_virtual_links_callback = function(result) {
        if (result == '') return;
        var form_index = "details_form_" + active_tab_id + "_0";
        var general_form_obj = ns_des_hedge.details_form[form_index];

        general_form_obj.setItemValue('book_structure', result[0][21]);
        general_form_obj.setItemValue('link_id', '-'+ result[0][1]);
        general_form_obj.setItemValue('link_description', result[0][4]);
        general_form_obj.setItemValue('eff_test_profile_id', result[0][5]);
        general_form_obj.setItemValue('link_type_value_id', result[0][7]);
        general_form_obj.setItemValue('link_effective_date', result[0][6]);
        general_form_obj.setItemValue('link_end_date', result[0][19]);

        general_form_obj.setItemValue('perfect_hedge', result[0][2]);
        general_form_obj.setItemValue('fully_dedesignated', result[0][3]);
        general_form_obj.setItemValue('link_active', result[0][8]);

        general_form_obj.setItemValue('original_link_id', result[0][18]);
        general_form_obj.setItemValue('dedesignated_percentage', result[0][20]);

        general_form_obj.disableItem('perfect_hedge');
        general_form_obj.disableItem('fully_dedesignated');
        general_form_obj.disableItem('link_active');
    }

    ns_des_hedge.load_second_tab = function(cell_obj) {
        //ns_des_hedge.details_form['details_form_' + active_tab_id + '_0'].attachEvent('onOptionsLoaded', function(name) {
        //if (name == 'link_type_value_id') {
        var link_type_value_id = ns_des_hedge.details_form['details_form_' + active_tab_id + '_0'].getItemValue('link_type_value_id');

        if (link_type_value_id != 450) {
            cell_obj.hide();
            return;
        }
        //}
        //});
        load_grid_n_menu(cell_obj, 'dedesignation');
    }

    ns_des_hedge.load_third_tab = function(tab_obj) {
        var tab_id = tab_obj.getId();
        var tab_index = tab_obj.getIndex();
        var form_index = "details_form_" + active_tab_id + "_" + tab_index;
        var general_form_obj = ns_des_hedge.details_form["details_form_" + active_tab_id + "_0"];
        var org_form_json = [
            {"type":"settings","position":"label-left"},
            {"type": "block", blockOffset: 10, list: [
                    {"type":"input","name":"original_link_id","label":"Dedesignated Link ID","tooltip":"",required:false,"validate":"NotEmpty","hidden":"false","disabled":"true","value":"","offsetLeft":"10","offsetTop":"20","labelWidth":170,"inputWidth":250},
                    {"type":"input","name":"link_description",required:false,"label":"Description","tooltip":"","offsetLeft":"10","offsetTop":"20","labelWidth":170,"inputWidth":250,"disabled":"false"},
                    {"type":"input","name":"dedesignated_percentage","label":"Percentage Dedesignated","tooltip":"",required:false,"validate":"NotEmpty","hidden":"false","disabled":"false","value":"1","offsetLeft":"10","offsetTop":"20","labelWidth":170,"inputWidth":250},
                    {"type":"calendar","name":"link_end_date","label":"Dedesignation Date","dateFormat": "%n/%j/%Y","tooltip":"",required:false,"validate":"NotEmpty","hidden":"false","disabled":"false","value":"","offsetLeft":"10","offsetTop":"20","labelWidth":170,"inputWidth":250},
                ]}
        ];
        ns_des_hedge.details_form[form_index] = tab_obj.attachForm();
        ns_des_hedge.details_form[form_index].loadStruct(org_form_json);

        ns_des_hedge.details_form[form_index].setItemValue('original_link_id', general_form_obj.getItemValue('original_link_id'))
        ns_des_hedge.details_form[form_index].setItemValue('link_description', general_form_obj.getItemValue('link_description'))
        ns_des_hedge.details_form[form_index].setItemValue('dedesignated_percentage', general_form_obj.getItemValue('dedesignated_percentage'))
        ns_des_hedge.details_form[form_index].setItemValue('link_end_date', general_form_obj.getItemValue('link_end_date'))

    }

    ns_des_hedge.load_fourth_tab = function(tab_obj) {
        var tab_id = tab_obj.getId();
        var tab_index = tab_obj.getIndex();

        //Attach cell layout 3E
        form_index = "details_form_" + active_tab_id + "_" + tab_index;

        ns_des_hedge.details_layout[form_index] = tab_obj.attachLayout({
            pattern: "3E",
            cells: [
                {id: "a", text: "Filter", collapse: true, header: false,height:120,fix_size: [true, null]},
                {id: "b", text: "Criteria", collapse: false,height:100, header: true,fix_size: [true, null]},
                {id: "c", text: "Assessment Result", collapse: false, height:220, header: true,fix_size: [true, null]}
            ]
        });

        var layout_obj = ns_des_hedge.details_layout[form_index];
        var filter_obj = layout_obj.cells('a').attachForm();
        ns_des_hedge.details_form[form_index] = layout_obj.cells('b').attachForm();
        var form_json = <?php echo $ass_form_structure; ?>;

        ns_des_hedge.details_form[form_index].loadStruct(form_json);
        //attach_browse_event(ns_des_hedge.details_form[form_index], 10233710, '', 'n'); 
        grid_cell_obj = layout_obj.cells('c');
        ns_des_hedge.details_form[form_index].setItemValue('initial_ongoing','o');
        load_form_filter(filter_obj, layout_obj.cells('b'), rights_view_assessement_ui, 2);

        load_grid_n_menu(grid_cell_obj, 'assessment_result');
    }

    /* loading tabs ends */

    ns_des_hedge.load_form_data = function(result) {
        var allow_change = '<?php echo $allow_change; ?>';
        var form_index = "details_form_" + active_tab_id + "_0";
        ns_des_hedge.details_form[form_index].loadStruct(result[0][2]);

        if (link_name == 'New') {
            deal_match_param_obj = JSON.parse(deal_match_param);
            var perfect_hedge = deal_match_param.indexOf('right_grid');
            var hedge_deals = deal_match_param_obj.left_grid;
            var item_deals = (perfect_hedge != -1) ? deal_match_param_obj.right_grid : '';
            var deal_ids;

            if (perfect_hedge != -1) {
                deal_ids = 'h:'+ hedge_deals + ' i: ,' + item_deals;
            } else {
                deal_ids = 'h:'+ hedge_deals + ' i:';
            }

            var data = {
                'action': 'spa_faslinkdetail',
                'flag':'l',
                'source_deal_header_id' : deal_ids
            };

            data = $.param(data);

            $.ajax({
                type: 'POST',
                dataType: 'json',
                url: js_form_process_url,
                async: true,
                data: data,
                success: function(data) {
                    response_data = data['json'];
                    ns_des_hedge.details_form[form_index].setItemValue('link_effective_date',response_data[0]['deal_date']);
                    ns_des_hedge.details_form[form_index].setItemValue('book_structure',response_data[0]['book_str']);
                    ns_des_hedge.details_form[form_index].setItemValue('subidiary_id',response_data[0]['subidiary_id']);
                    ns_des_hedge.details_form[form_index].setItemValue('strategy_id',response_data[0]['stra_id']);
                    ns_des_hedge.details_form[form_index].setItemValue('book_id',response_data[0]['book_id']);

                }
            });
        }

        if (active_object_id.indexOf("tab_") == -1) {
            ns_des_hedge.details_form[form_index].hideItem('link_end_date');
            ns_des_hedge.details_form[form_index].hideItem('fully_dedesignated');
            ns_des_hedge.details_form[form_index].hideItem('lock');
        }

        if (allow_change == 'true') {
            lock_link = false;
            lock_link_enabled = false;
        } else {
            if (has_rights_update_delete_closed_hedge) {
                default_value = <?php echo $defaultvalue; ?>;
                if (default_value == 1) {
                    lock_link = false;
                    lock_link_enabled = true;
                } else {
                    lock_link = true;
                    //lock_link_enabled = false; 
                }
            } else {
                lock_link = true;
                lock_link_enabled = false;
            }
        }
        if (ns_des_hedge.details_form[form_index].isItemChecked('fully_dedesignated')){
            ns_des_hedge.details_form[form_index].disableItem('perfect_hedge');
            fully_dedesignated =true;
        } else
            fully_dedesignated = false;

        if (lock_link)
            ns_des_hedge.details_form[form_index].checkItem('lock');
        if (lock_link_enabled) {
            ns_des_hedge.details_form[form_index].enableItem('lock');
        }  else {
            ns_des_hedge.details_form[form_index].disableItem('lock');
        }

        var form_name =  'ns_des_hedge.details_form["details_form_' + active_tab_id + '_0' + '"]';
        attach_browse_event(form_name, 10233710, '', 'n');
        //cell_a.progressOff();

    }

    function load_grid_n_menu(cell_obj, call_from) {
        //attach grid to the tab, grid definition that is collected above is used to construct grid
        var i, sql_stmt;

        if (call_from == 'hedges') {
            i = 1;
            sql_stmt = grid_definition_json[i]["sql_stmt"];
            has_rights_iu = has_rights_link_iu;
        } else if (call_from == 'items') {
            i = 2;
            sql_stmt = grid_definition_json[i]["sql_stmt"];
            has_rights_iu = has_rights_link_iu;
        } else if (call_from == 'dedesignation') {
            i = 3;
            sql_stmt = grid_definition_json[i]["sql_stmt"];
            has_rights_iu = has_rights_de_designation;
        } else if (call_from == 'assessment_result') {
            i = 4;
            //sql_stmt = "EXEC spa_Get_Assessment_Results @hedge_relationship_type_id='532', @date_from='2003-01-01', @date_to='2005-06-01', @initial_ongoing='o'";
            has_rights_iu = has_rights_link_assessment;
        }


        //active_tab_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        var link_id = active_tab_id;

        //Attach menu/grid in cell a
        var cell_obj = cell_obj;
        var link_type_value_id;
        var cell_obj_menu;
        /*Removed the event since it is not called because the forms not loads from dropdown.connector.v2.php*/
        // ns_des_hedge.details_form['details_form_' + active_tab_id + '_0'].attachEvent('onOptionsLoaded', function(name) {
        //     if (name == 'link_type_value_id') {
        ns_des_hedge.details_tabs["detail_tab_" + active_tab_id].forEachTab(function(tab) {
            if (tab.getIndex() == 0) {
                var attached_obj = tab.getAttachedObject();
                attached_obj.forEachItem(function(cell) {
                    cell_attached_obj = cell.getAttachedObject();
                    if (cell_attached_obj instanceof dhtmlXForm) {
                        link_type_value_id = cell_attached_obj.getItemValue('link_type_value_id');
                    }
                });
            };
        });

        var menu_json;
        if (link_type_value_id == 450) {
            menu_json = [{id: "edit", text: "Edit", img: "edit.gif", img_disabled: "edit_dis.gif", items: [
                    {id: "add", text: "Add", img: "add.gif", img_disabled: "add_dis.gif", enabled: has_rights_iu},
                    {id: "delete", text: "Delete", disabled: true, img: "delete.gif", img_disabled: "delete_dis.gif"}
                ]},
                {id: "export", text: "Export", img: "export.gif", items: [
                        {id: "excel", text: "Excel", img: "excel.gif", imgdis: "excel_dis.gif", title: "Excel"},
                        {id: "pdf", text: "PDF", img: "pdf.gif", imgdis: "pdf_dis.gif", title: "PDF"}
                    ]}]
        } else {
            menu_json = [{id: "export", text: "Export", img: "export.gif", items: [
                    {id: "excel", text: "Excel", img: "excel.gif", imgdis: "excel_dis.gif", title: "Excel"},
                    {id: "pdf", text: "PDF", img: "pdf.gif", imgdis: "pdf_dis.gif", title: "PDF"}
                ]}]
        }
        ns_des_hedge.details_menu["details_menu_" + call_from + "_" + active_tab_id] = cell_obj.attachMenu({
            icons_path: js_image_path + "dhxmenu_web/",
            items: menu_json
        });

        cell_obj_menu = ns_des_hedge.details_menu["details_menu_" + call_from + "_" + active_tab_id];

        var enable_add = (has_rights_iu == true) ? false : true; //addNewChild has 5th parameter as Disable Item. So to enable button the value should be false

        if (call_from == 'items') {
            //Add process menu for dicing
            cell_obj_menu.addNewSibling('export', "item_process", 'Process', false, "process.gif", "process_dis.gif");
            cell_obj_menu.addNewChild('edit', 0, "add_deal", 'Add Deal', enable_add, "add.gif", "add_dis.gif");
            cell_obj_menu.addNewChild('edit', 1, "add_deals", 'Add Deals', enable_add, "add.gif", "add_dis.gif");
            cell_obj_menu.addNewChild('item_process', 1,"item_dicing", 'Dice', true, "dice.gif", "dice_dis.gif");
            cell_obj_menu.hideItem('add');
        } else  if (call_from == 'assessment_result') {
            //Add process menu for assessment result
            cell_obj_menu.addNewSibling(null, "refresh", 'Refresh', false, "refresh.gif", "refresh_dis.gif");
            cell_obj_menu.addNewSibling('export', "report", 'Reports', false, "report.gif", "report_dis.gif");
            cell_obj_menu.addNewChild('report', 1,"plot", 'Plot', true, "plot.gif", "plot_dis.gif");
            cell_obj_menu.addNewChild('report', 2, "plot_series", 'Plot Series', true, "plot_series.gif", "plot_series_dis.gif");
            cell_obj_menu.addNewChild('report', 3, "plot_trends", 'Plot Trends', true, "plot_trends.gif", "plot_trends_dis.gif");
            cell_obj_menu.addNewChild('report', 4, "assessment_test_result", 'Assessment Test Result', true, "assessment_test_result.gif", "assessment_test_result_dis.gif");
            cell_obj_menu.addNewChild('report', 5, "export_series", 'Export Series', true, "export_series.gif", "export_series_dis.gif");
            cell_obj_menu.addNewChild('report', 6, "export_profile", 'Export Hedge/Item Profile', true, "export_profile.gif", "export_profile_dis.gif");
        } else  if (call_from == 'hedges') {
            cell_obj_menu.addNewChild('edit', 0, "add_deal", 'Add Deal', enable_add, "add.gif", "add_dis.gif");
            cell_obj_menu.addNewChild('edit', 1, "add_deals", 'Add Deals', enable_add, "add.gif", "add_dis.gif");
            cell_obj_menu.hideItem('add');
        }

        if (call_from == 'dedesignation') {
            ns_des_hedge.details_menu["details_menu_" + call_from + "_" + active_tab_id].hideItem('add');
        }

        if (ns_des_hedge.details_form["details_form_" + active_tab_id + "_0"].isItemChecked('lock')) {
            var original_link_id = ns_des_hedge.details_form["details_form_" + active_tab_id + "_0"].getItemValue('original_link_id');
            if (original_link_id == '') {
                ns_des_hedge.details_menu["details_menu_" + call_from + "_" + active_tab_id].setItemDisabled('add');
            }
        }

        if (fully_dedesignated) {
            var original_link_id = ns_des_hedge.details_form["details_form_" + active_tab_id + "_0"].getItemValue('original_link_id');
            if (original_link_id == '')
                ns_des_hedge.details_menu["details_menu_" + call_from + "_" + active_tab_id].setItemDisabled('add');
        }
        cell_obj_menu.attachEvent("onClick", function(id) {
            switch (id) {
                //process Hedge grid
                case "add":
                    if (call_from == 'assessment_result') {
                        ns_des_hedge.open_assessment_result();
                    }
                    break;
                case "add_deal": // for hedge/Item grid
                    var newId = (new Date()).valueOf();
                    ns_des_hedge.details_grid[grid_index].addRow(newId,"");
                    break
                case "add_deals": // for hedge/Item grid
                    var transaction_type = (call_from == 'hedges') ? 400 : 401;
                    ns_des_hedge.select_deal(ns_des_hedge.details_grid[grid_index],transaction_type);
                    break
                case "delete":
                    var col_name = 'link_id';

                    if (call_from == 'assessment_result') {
                        col_name = 'result_id';
                    } if (call_from == 'dedesignation') {
                    col_name = 'link_id';
                }

                    var link_ids = get_selected_ids(ns_des_hedge.details_grid[grid_index], col_name);

                    if (link_ids != null) {
                        dhtmlx.message({
                            type: "confirm",
                            title: "Confirmation",
                            ok: "Confirm",
                            text: "Are you sure you want to delete?",
                            callback: function(result) {
                                if (result) {
                                    if (call_from == 'assessment_result') {
                                        ns_des_hedge.delete_assessment_result(link_ids);
                                    } else if (call_from == 'dedesignation') {
                                        ns_des_hedge.delete_dedesignated_links(link_ids,call_from);
                                    } else {
                                        ns_des_hedge.details_grid[grid_index].deleteSelectedRows();
                                        cell_obj_menu.setItemDisabled('delete');
                                    }
                                }
                            }
                        });
                    }
                    break;
                case 'excel':

                    if (call_from == 'hedges' || call_from == 'items') {
                        var process_table = (call_from == 'hedges') ? $('textarea#txt_hedges_process_table').val() : $('textarea#txt_items_process_table').val();
                        if (process_table == '') {
                            dhtmlx.alert({
                                type: "alert",
                                title:'Alert',
                                text:"Please refresh grid."
                            });
                            return;
                        }
                        var label = (call_from == 'hedges') ? 'Hedges' : 'Items';
                        label = label + '_' + active_tab_id
                        ns_des_hedge.details_grid[grid_index].PSExport('excel', process_table, label);
                    } else {
                        ns_des_hedge.details_grid[grid_index].toExcel(php_script_loc + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
                    }
                    break;
                case 'pdf':
                    ns_des_hedge.details_grid[grid_index].toPDF(php_script_loc + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
                    break;
                case 'item_dicing':
                    ns_des_hedge.item_dicing(ns_des_hedge.details_grid[grid_index]);
                    break;
                case 'refresh':
                    ns_des_hedge.refresh_assessment_result(ns_des_hedge.details_grid[grid_index]);
                    break;
                case 'plot':
                    run_assessment_result_report('plot_result', ns_des_hedge.details_grid[grid_index]);
                    break;
                case 'plot_series':
                    run_assessment_result_report('plot_series', ns_des_hedge.details_grid[grid_index]);
                    break;
                case 'plot_trends':
                    run_assessment_result_report('plot_trends', ns_des_hedge.details_grid[grid_index]);
                    break;
                case 'assessment_test_result':
                    run_assessment_result_report('assessment_test_result', ns_des_hedge.details_grid[grid_index]);
                    break;
                case 'export_series':
                    run_assessment_result_report('export_series', ns_des_hedge.details_grid[grid_index]);
                    break;
                case 'export_profile':
                    run_assessment_result_report('export_profile', ns_des_hedge.details_grid[grid_index]);
                    break;
                default:
                    show_messagebox(id);
                    break;
            }
        });
        //     }
        // });

        var grid_name = grid_definition_json[i]["grid_name"];
        var grid_cookies = "grid_" + call_from + "_" + grid_name;
        var grid_index = "details_grid_" + call_from + "_" + active_tab_id;
        ns_des_hedge.details_grid[grid_index] = cell_obj.attachGrid();
        ns_des_hedge.details_grid[grid_index].setImagePath(js_image_path + "dhxgrid_web/");
        ns_des_hedge.details_grid[grid_index].setHeader(grid_definition_json[i]["column_label_list"]);
        ns_des_hedge.details_grid[grid_index].setColumnIds(grid_definition_json[i]["column_name_list"]);
        ns_des_hedge.details_grid[grid_index].setInitWidths(grid_definition_json[i]["column_width"]);
        ns_des_hedge.details_grid[grid_index].setColTypes(grid_definition_json[i]["column_type_list"]);
        ns_des_hedge.details_grid[grid_index].setColumnsVisibility(grid_definition_json[i]["set_visibility"]);
        ns_des_hedge.details_grid[grid_index].setDateFormat(user_date_format, "%Y-%m-%d");

        var sorting_list = '';
        var filter_list = '';

        var column_array = new Array();
        column_array = grid_definition_json[i]["column_name_list"].split(',');
        if (call_from == 'hedges' || call_from == 'items') {
            var paging_id = (call_from == 'hedges') ? 'pagingArea_a' : 'pagingArea_b';
            cell_obj.attachStatusBar({
                height: 30,
                text: '<div id="' + paging_id + '"></div>'
            });
            ns_des_hedge.details_grid[grid_index].setPagingWTMode(true,true,true,[10,20,30,40,50,60,70,80,90,100]);
            ns_des_hedge.details_grid[grid_index].enablePaging(true, 100, 0, paging_id);
            ns_des_hedge.details_grid[grid_index].setPagingSkin('toolbar');
            ns_des_hedge.details_grid[grid_index].attachEvent('onEnter', function(id,ind){
                var reference_id_index = ns_des_hedge.details_grid[grid_index].getColIndexById('deal_id');
                if (reference_id_index == ind)
                    ns_des_hedge.populate_deal_detail(id, ns_des_hedge.details_grid[grid_index], call_from);
            });

            ns_des_hedge.details_grid[grid_index].attachEvent("onRowCreated", function(rId,rObj,rXml){
                var link_id_index = ns_des_hedge.details_grid[grid_index].getColIndexById('link_id');
                var reference_id_index = ns_des_hedge.details_grid[grid_index].getColIndexById('deal_id');
                var link_id = ns_des_hedge.details_grid[grid_index].cells(rId,link_id_index).getValue();

                if (link_id != '') {
                    ns_des_hedge.details_grid[grid_index].cells(rId,reference_id_index).setDisabled(true);
                }
            });
            $.each(column_array, function(index, v1){
                if (sorting_list == '') {
                    sorting_list += 'connector';
                } else {
                    sorting_list += ',connector';
                }

                if (filter_list == '') {
                    filter_list += '#connector_text_filter';
                } else {
                    filter_list += ',#connector_text_filter';
                }
            });
            ns_des_hedge.details_grid[grid_index].setColSorting(sorting_list);
            ns_des_hedge.details_grid[grid_index].attachHeader(filter_list);
        } else {
            $.each(column_array, function(index, v1){
                if (filter_list == '') {
                    filter_list += '#text_filter';
                } else {
                    filter_list += ',#text_filter';
                }
            });
            ns_des_hedge.details_grid[grid_index].setColSorting(grid_definition_json[i]["sorting_preference"]);
            ns_des_hedge.details_grid[grid_index].attachHeader(filter_list);
        }

        ns_des_hedge.details_grid[grid_index].enableMultiselect(true);
        ns_des_hedge.details_grid[grid_index].enableColumnMove(true);
        ns_des_hedge.details_grid[grid_index].setUserData("","grid_label", grid_name);
        ns_des_hedge.details_grid[grid_index].init();
        ns_des_hedge.details_grid[grid_index].enableHeaderMenu();
        ns_des_hedge.details_grid[grid_index].attachEvent("onEditCell", function(stage,rId,cInd,nValue,oValue){
            return true;
        });

        ns_des_hedge.details_grid[grid_index].attachEvent("onRowSelect", function(){
            var delete_privilege = has_rights_link_iu;
            if (call_from == 'assessment_result') {
                delete_privilege = has_rights_link_assessment;
                cell_obj_menu.setItemEnabled('plot');
                cell_obj_menu.setItemEnabled('plot_series');
                cell_obj_menu.setItemEnabled('plot_trends');
                cell_obj_menu.setItemEnabled('assessment_test_result');
                cell_obj_menu.setItemEnabled('export_series');
                cell_obj_menu.setItemEnabled('export_profile');
            }

            if (delete_privilege) {
                if (ns_des_hedge.details_form["details_form_" + active_tab_id + "_0"].isItemChecked('lock') == false) {
                    var menu_obj = ns_des_hedge.details_menu["details_menu_" + call_from + "_" + active_tab_id];
                    if (menu_obj.getItemType('delete') != null)
                        menu_obj.setItemEnabled('delete');
                    if (menu_obj.getItemType('item_dicing') != null)
                        menu_obj.setItemEnabled('item_dicing');
                }
            }

            if (call_from == 'items') {
                if (has_rights_iu) {
                    if (fully_dedesignated) {
                        cell_obj_menu.setItemDisabled('add');
                        cell_obj_menu.setItemDisabled('delete');
                        cell_obj_menu.setItemDisabled('item_dicing');
                    }
                    // else
                    //     cell_obj_menu.setItemEnabled('item_dicing');                    
                } else cell_obj_menu.setItemDisabled('item_dicing');
            }
            if (call_from == 'hedges') {
                if (fully_dedesignated) {
                    cell_obj_menu.setItemDisabled('add');
                    cell_obj_menu.setItemDisabled('delete');
                }
            }
        });

        if (grid_definition_json[i]["sql_stmt"] != '') {
            if (call_from == 'hedges' || call_from == 'items') {
                //cell_obj.progressOn();
                var deal_ids;
                var hedge_item;
                if (link_name == 'New' && deal_match_param != 'New') {
                    deal_match_param_obj = JSON.parse(deal_match_param);

                    if (call_from == 'hedges') {
                        hedge_item = 'h';
                        deal_ids = deal_match_param_obj.left_grid;
                    } else {
                        hedge_item = 'i';
                        deal_ids = deal_match_param_obj.right_grid;
                    }

                    var sql_stmt = "EXEC spa_faslinkdetail @flag = 'j', @flag2 = 'p', @hedge_or_item = '" + hedge_item + "', @source_deal_header_id = '" + deal_ids +"'";
                    ns_des_hedge.dny_refresh_grids(sql_stmt);
                } else {
                    ns_des_hedge.dny_refresh_grids(grid_definition_json[i]["sql_stmt"]);
                }

            } else {
                ns_des_hedge.refresh_grids(grid_definition_json[i]["sql_stmt"], ns_des_hedge.details_grid[grid_index], 'g', active_tab_id);
            }
        }
    }

    ns_des_hedge.populate_deal_detail = function(row_id, grid_obj, call_from) {
        var ref_id_index = grid_obj.getColIndexById('deal_id');
        var reference_id = grid_obj.cells(row_id,ref_id_index).getValue();
        processing_grid_obj = grid_obj;
        var link_id = ns_des_hedge.details_form["details_form_" + active_tab_id + "_0"].getItemValue('link_id');
        var link_effective_date = ns_des_hedge.details_form["details_form_" + active_tab_id + "_0"].getItemValue('link_effective_date', true);

        if (link_effective_date == null|| link_effective_date == '') {
            show_messagebox('Please select Effective Date in Link Info tab.');
            return;
        }

        var hedge_item = (call_from == 'hedges') ? 'h' : 'i';
        var data = {
            'action': 'spa_faslinkdetail',
            'flag':'j',
            'hedge_or_item' : hedge_item,
            'reference_id': reference_id,
            'link_id' : link_id,
            'effective_date' : link_effective_date,
            'link_id' : link_id,
            'type': 'return_array'
        };

        data = $.param(data);

        $.ajax({
            type: 'POST',
            dataType: 'json',
            url: js_form_process_url,
            async: true,
            data: data,
            success: function(data) {
                response_data = data['json'];

                if (typeof response_data[0][0] == 'string' && response_data[0][0].toLowerCase() == 'error') {
                    show_messagebox(response_data[0][4]);
                    return;
                } else {
                    var count = grid_obj.getRowsNum();
                    var ref_id;

                    for (i = 0; i < count -1; i++) {
                        ref_id = grid_obj.cells2(i,1).getValue()

                        if (ref_id == response_data[0][1]) {
                            show_messagebox('Deal aleady exists in grid.');
                            return;
                        }
                    }

                    grid_obj.deleteRow(row_id);
                    append_to_grid(response_data);
                }
            }
        });
    }

    ns_des_hedge.refresh_assessment_result = function() {
        form_obj = ns_des_hedge.details_form["details_form_" + active_tab_id + "_4"];
        form_data = form_obj.getFormData();
        var link_id = active_tab_id;

        var filter_param = '';
        var status = validate_form(form_obj);

        if (status) {
            filter_param = new Array();

            for (var a in form_data) {
                if (form_data[a] != '' && form_data[a] != null) {

                    if (form_obj.getItemType(a) == 'calendar') {
                        value = form_obj.getItemValue(a, true);
                    } else {
                        value = form_data[a];
                    }

                    filter_param.push("@" + a + '=' + singleQuote(value))
                }
            }

            var hedge_relationship_type_id = ns_des_hedge.details_form["details_form_" + active_tab_id + "_0"].getItemValue('eff_test_profile_id');
            var fas_sub_id = ns_des_hedge.details_form["details_form_" + active_tab_id + "_0"].getItemValue('subsidiary_id');
            var fas_strategy_id = ns_des_hedge.details_form["details_form_" + active_tab_id + "_0"].getItemValue('strategy_id');
            var fas_book_id = ns_des_hedge.details_form["details_form_" + active_tab_id + "_0"].getItemValue('book_id');

            //filter_param.push("@hedge_relationship_type_id" + '=' + singleQuote(hedge_relationship_type_id))
            filter_param.push("@subsidiary_id" + '=' + singleQuote(fas_sub_id))
            filter_param.push("@strategy_id" + '=' + singleQuote(fas_strategy_id))
            filter_param.push("@book_id" + '=' + singleQuote(fas_book_id))
			filter_param.push("@link_id" + '=' + singleQuote(link_id))
            filter_param = filter_param.toString();

            var sql_stmt = "EXEC spa_Get_Assessment_Results " + filter_param;

            var sql_param = {
                "sql": sql_stmt,
                "grid_type": 'g'
            };

            sql_param = $.param(sql_param);
            var sql_url = js_data_collector_url + "&" + sql_param;
            var grid_obj = ns_des_hedge.details_grid["details_grid_assessment_result_" + active_tab_id];
            grid_obj.clearAll();
            grid_obj.load(sql_url, function() {
                ns_des_hedge.details_menu["details_menu_assessment_result_" + active_tab_id].setItemDisabled('delete');
                ns_des_hedge.details_menu["details_menu_assessment_result_" + active_tab_id].setItemDisabled('plot');
                ns_des_hedge.details_menu["details_menu_assessment_result_" + active_tab_id].setItemDisabled('plot_series');
                ns_des_hedge.details_menu["details_menu_assessment_result_" + active_tab_id].setItemEnabled('plot_trends');
                ns_des_hedge.details_menu["details_menu_assessment_result_" + active_tab_id].setItemDisabled('assessment_test_result');
                ns_des_hedge.details_menu["details_menu_assessment_result_" + active_tab_id].setItemDisabled('export_series');
                ns_des_hedge.details_menu["details_menu_assessment_result_" + active_tab_id].setItemDisabled('export_profile');
            });
            var layout_obj = ns_des_hedge.details_layout[form_index];
            layout_obj.cells('a').collapse();
            layout_obj.cells('b').collapse();

        }
    }

    /**
     * [dny_refresh_grids Refresh Grid using connector - generate process table]
     * @param  {[type]} sql_stmt [SQL Statement]
     */
    ns_des_hedge.dny_refresh_grids = function(sql_stmt) {
        if (sql_stmt.indexOf('<ID>') != -1) {
            var stmt = sql_stmt.replace('<ID>', active_tab_id);
        } else {
            var stmt = sql_stmt;
        }

        var grid_sp_param = {
            "sp_string":stmt
        }
        adiha_post_data("return", grid_sp_param, '', '', 'ns_des_hedge.dny_refresh_callback');
    }

    /**
     * [dny_refresh_callback Refresh Grid using connector - use process table to refresh grid]
     * @param  {[type]} sql_stmt [SQL Statement]
     */
    ns_des_hedge.dny_refresh_callback = function(result) {
        if (result[0].process_table == '' || result[0].process_table == null) {
            return;
        }

        var call_from = result[0].call_from;
        var process_table = result[0].process_table;
        var i = (call_from == 'hedges') ? 1 : 2;
        var txt_id = (call_from == 'hedges') ? 'txt_hedges_process_table' : 'txt_items_process_table';
        document.getElementById(txt_id).value = process_table;

        var column_list = grid_definition_json[i]["column_name_list"];
        var numeric_fields = grid_definition_json[i]["numeric_fields"];
        var date_fields = grid_definition_json[i]["date_fields"];

        var grid_index = "details_grid_" + call_from + "_" + active_tab_id;
        var grid_obj = ns_des_hedge.details_grid[grid_index];

        var sql_param = {
            "process_table":process_table,
            "text_field":column_list,
            "id_field": "id",
            "date_fields":date_fields,
            "numeric_fields":numeric_fields
        };
        sql_param = $.param(sql_param);
        var sql_url = js_php_path + "grid.connector.php?"+ sql_param;
        grid_obj.clearAll();
        grid_obj.loadXML(sql_url);
    }

    ns_des_hedge.refresh_grids = function(sql_stmt, grid_obj, grid_type, value_id) {
        if (sql_stmt.indexOf('<ID>') != -1) {
            var stmt = sql_stmt.replace('<ID>', value_id);
        } else {
            var stmt = sql_stmt;
        }
        // load grid data
        var sql_param = {
            "sql": stmt,
            "grid_type": grid_type
        };

        sql_param = $.param(sql_param);
        var sql_url = js_data_collector_url + "&" + sql_param;
        //grid_obj.clearAll();
        //grid_obj.load(sql_url);
        grid_obj.clearAndLoad(sql_url);
    }

    function lock_link_checked() {
        var is_locked = ns_des_hedge.details_form["details_form_" + active_tab_id + "_0"].isItemChecked('lock');
        var attached_toolbar = ns_des_hedge.toolbar_des_hedge;
        var assessment_result = '<?php echo $assessment_result; ?>';

        if (is_locked) {
            attached_toolbar.disableItem('save');
            ns_des_hedge.details_form["details_form_" + active_tab_id + "_0"].disableItem('link_active');
            ns_des_hedge.details_form["details_form_" + active_tab_id + "_0"].disableItem('perfect_hedge');
            ns_des_hedge.details_menu["details_menu_dedesignation_" + active_tab_id].setItemDisabled('edit');
            if (assessment_result == 1) ns_des_hedge.details_menu["details_menu_assessment_result_" + active_tab_id].setItemDisabled('edit');
            ns_des_hedge.details_menu["details_menu_items_" + active_tab_id].setItemDisabled('add');
            ns_des_hedge.details_menu["details_menu_hedges_" + active_tab_id].setItemDisabled('add');
            ns_des_hedge.details_menu["details_menu_items_" + active_tab_id].setItemDisabled('delete');
            ns_des_hedge.details_menu["details_menu_hedges_" + active_tab_id].setItemDisabled('delete');
            ns_des_hedge.details_menu["details_menu_items_" + active_tab_id].setItemDisabled('item_dicing');
        } else {
            if (has_rights_link_iu) {
                var original_link_id = ns_des_hedge.details_form["details_form_" + active_tab_id + "_0"].getItemValue('original_link_id');
                if (original_link_id == '') {
                    attached_toolbar.enableItem('save');
                }
                else attached_toolbar.disableItem('save');
            }
            else attached_toolbar.disableItem('save');

            if (fully_dedesignated == false) {
                ns_des_hedge.details_menu["details_menu_items_" + active_tab_id].setItemEnabled('add')
                ns_des_hedge.details_menu["details_menu_hedges_" + active_tab_id].setItemEnabled('add')
            }
            ns_des_hedge.details_menu["details_menu_dedesignation_" + active_tab_id].setItemEnabled('edit');
            if (assessment_result == 1) {
                ns_des_hedge.details_menu["details_menu_assessment_result_" + active_tab_id].setItemEnabled('edit');
                ns_des_hedge.details_menu["details_menu_assessment_result_" + active_tab_id].setItemEnabled('add');
            }
            ns_des_hedge.details_form["details_form_" + active_tab_id + "_0"].enableItem('link_active');
            if (fully_dedesignated)
                ns_des_hedge.details_form["details_form_" + active_tab_id + "_0"].disableItem('perfect_hedge');
            else
                ns_des_hedge.details_form["details_form_" + active_tab_id + "_0"].enableItem('perfect_hedge');
        }


    }

    ns_des_hedge.tab_toolbar_click = function(id) {
        switch(id) {
            case 'save':
                ns_des_hedge.save_hedge();
                break;
            case 'documents':
                ns_des_hedge.open_document();
                break;
            default:
                dhtmlx.alert({
                    title:'Sorry! <font size="5">&#x2639 </font>',
                    type:"alert-error",
                    text:"Event not defined."
                });
                break;
        }
    }

    ns_des_hedge.save_hedge = function() {
        var main_tabbar_obj = ns_des_hedge.details_tabs["detail_tab_" + active_tab_id];
        var grid_xml = '<GridGroup>', hedge_or_item = 'h', grid_id = '';
        ns_des_hedge.validation_status = 1;
        var form_xml = '<FormXML ';
        var param_list = new Array();
        var tabsCount = main_tabbar_obj.getNumberOfTabs();
        var form_status = true;
        var first_err_tab;

        main_tabbar_obj.forEachTab(function(tab) {
            var tab_id = tab.getId();
            var tab_index = tab.getIndex();
            var tab_text = tab.getText();

            if (tab_index == 0 || tab_index == 1) {
                layout_obj = tab.getAttachedObject();
                var i = 0;
                layout_obj.forEachItem(function(cell){
                    attached_obj = cell.getAttachedObject();
                    if (attached_obj instanceof dhtmlXGridObject) {
                        attached_obj.clearSelection();
                        var row_no = attached_obj.getRowsNum();
                        var col_no = attached_obj.getColumnsNum();
                        grid_id = (i == 0) ? 'Hedges' : 'Items';
                        hedge_or_item = (i == 0) ? 'h' : 'i';
                        grid_xml += "<Grid grid_id=\"" + grid_id + "\">";
                        var col_value, col_id;

                        for(row_index = 0; row_index < row_no; row_index++) {
                            grid_xml += "<GridRow ";
                            for(var cellIndex = 0; cellIndex < col_no; cellIndex++){
                                col_value = attached_obj.cells2(row_index,cellIndex).getValue();
                                col_id = attached_obj.getColumnId(cellIndex);

                                if (col_id == 'deal_id') {
                                    //alert(col_value)
                                    col_value = col_value.substring((col_value.indexOf('<l>')+2,col_value.lastIndexOf('<l>')-6)+3,col_value.lastIndexOf('<l>'));
                                    //Selected Deal ID only from hyperlink
                                }

                                if (col_id == 'perc_included' && col_value == 0) {
                                    dhtmlx.alert({
                                        title: 'Error',
                                        type: 'alert-error',
                                        text: 'Please insert valid percentage included.'
                                    });

                                    ns_des_hedge.validation_status = 0;
                                }

                                grid_xml += " " + col_id + '="' + col_value + '"';
                            }
                            grid_xml += ' hedge_or_item = "' + hedge_or_item + '"></GridRow> ';
                        }
                        grid_xml += "</Grid>";
                        i++;
                    } else if(attached_obj instanceof dhtmlXForm) {
                        ns_des_hedge.validation_status = 1;
                        var status = validate_form(attached_obj);
                        form_status = form_status && status;
                        if (tabsCount == 1 && !status) {
                            first_err_tab = "";
                        } else if ((!first_err_tab) && !status) {
                            first_err_tab = tab;
                        }
                        if (status) {
                            //ns_des_hedge.toolbar_des_hedge.disableItem('save');
                            data = attached_obj.getFormData();
                            for (var a in data) {
                                var field_label = a;

                                if (attached_obj.getItemType(field_label) == 'calendar') {
                                    var field_value = attached_obj.getItemValue(field_label, true);
                                } else {
                                    var field_value = data[field_label];
                                }

                                if (!field_value)
                                    field_value = '';

                                field_label = (field_label == 'book_id') ? 'fas_book_id' : field_label;

                                if (field_label != 'book_structure' &&
                                    field_label != 'subsidiary_id' &&
                                    field_label != 'strategy_id' &&
                                    field_label != 'subbook_id')
                                {
                                    if (field_label == 'fas_book_id' && field_value.indexOf(',') != -1) {
                                        dhtmlx.alert({
                                            title: 'Error',
                                            type: 'alert-error',
                                            text: 'Please select a single Book.'
                                        });

                                        ns_des_hedge.validation_status = 0;
                                    }

                                    form_xml += " " + field_label + "=\"" + field_value + "\"";
                                }
                            }
                        } else {
                            ns_des_hedge.validation_status = 0;
                        }
                    }
                });

            } //ends index 0 loop
        });

        grid_xml += '</GridGroup>'
        if (!form_status) {
            generate_error_message(first_err_tab);
        }
        if (!ns_des_hedge.validation_status) return;

        form_xml += "></FormXML>";
        var xml_value = "<Root>" + form_xml + grid_xml  + "</Root>";

        var flag = (ns_des_hedge.details_form["details_form_" + active_tab_id + "_0"].getItemValue('link_id') != '') ? 'u' : 'i';

        var data_validate = {
            "action": "spa_designation_of_hedge",
            "flag": 'v',
            "xml_value": xml_value
        };

        data_validate = $.param(data_validate);

        var data_save = {
            "action": "spa_designation_of_hedge",
            "flag": flag,
            "xml_value": xml_value
        };
        $.ajax({
            type: "POST",
            dataType: "json",
            url: js_form_process_url,
            async: true,
            data: data_validate,
            success: function(data) {
                response_data = data["json"];

                if (response_data[0].errorcode == 'Error') {
                    dhtmlx.message({
                        type: 'confirm',
                        title: 'Confirmation',
                        ok: 'Confirm',
                        text: response_data[0].message,
                        callback: function(result) {
                            if (result) {
                                adiha_post_data('return_json', data_save, '', '', 'save_callback', '');
                            }
                        }
                    });
                } else {
                    adiha_post_data('return_json', data_save, '', '', 'save_callback', '');
                }
            }
        });
    }

    function save_callback(result) {
        if (has_rights_link_iu) {
            ns_des_hedge.toolbar_des_hedge.enableItem('save');

        };
        var return_data = JSON.parse(result);
        var tab_name = '';
        var document_button_exists = 'n';
        var new_id = '';
        var link_description = '';

        if ((return_data[0].status).toLowerCase() == 'success') {
            dhtmlx.message(return_data[0].message);
            if (return_data[0].recommendation != '') {
                var result_arr = return_data[0].recommendation.split(';');
                new_id = result_arr[0];
                link_description = result_arr[1];
                ns_des_hedge.details_form["details_form_" + active_tab_id + "_0"].setItemValue('link_id', new_id);
                ns_des_hedge.details_form["details_form_" + active_tab_id + "_0"].setItemValue('link_description', link_description);

                var tab_name = 'Link ID : ' + new_id;

                ns_des_hedge.toolbar_des_hedge.forEachItem(function(item_id) {
                    if (item_id == 'documents') document_button_exists = 'y';
                });

                if (document_button_exists == 'n') add_manage_document_button(new_id, ns_des_hedge.toolbar_des_hedge, has_document_rights);

                ns_des_hedge.details_form["details_form_" + active_tab_id + "_0"].showItem('link_end_date');
                ns_des_hedge.details_form["details_form_" + active_tab_id + "_0"].showItem('fully_dedesignated');
                ns_des_hedge.details_form["details_form_" + active_tab_id + "_0"].showItem('lock');
            }

            var main_tabbar_obj = ns_des_hedge.details_tabs["detail_tab_" + active_tab_id];

            main_tabbar_obj.forEachTab(function(tab) {
                var tab_id = tab.getId();
                var tab_index = tab.getIndex();

                if (tab_index == 2) main_tabbar_obj.tabs(tab_id).show();
            });

            var form_index = "details_form_" + active_tab_id + "_0";
            var layout_obj = ns_des_hedge.details_layout[form_index];
            var i = 1;
            var cell_obj = layout_obj.cells('a');
            var grid_index = "details_grid_hedges_" + active_tab_id;
            // cell_obj.progressOn();
            if (new_id  != '') grid_definition_json[i]["sql_stmt"] = grid_definition_json[i]["sql_stmt"].replace('<ID>', new_id);
            ns_des_hedge.dny_refresh_grids(grid_definition_json[i]["sql_stmt"]);

            var i = 2;
            var cell_obj = layout_obj.cells('b');
            // cell_obj.progressOn();
            var grid_index = "details_grid_items_" + active_tab_id;
            if (new_id  != '') grid_definition_json[i]["sql_stmt"] = grid_definition_json[i]["sql_stmt"].replace('<ID>', new_id);
            ns_des_hedge.dny_refresh_grids(grid_definition_json[i]["sql_stmt"]);

            parent.post_link_update(tab_name,active_object_id)
        } else {
            dhtmlx.alert({
                title: 'Error',
                type: "alert-error",
                text: return_data[0].message
            });
        }
    }

    ns_des_hedge.select_deal = function(obj, trans_type) {
        // Collect deals from create and view deals page.
        var col_list = 'id'; //id for source_deal_header_id       
        var view_deal_window = new dhtmlXWindows();
        var win_id = 'w1';
        //deal_win should be global variable to access from callback function 'ns_des_hedge.callback_select_deal' to close child window ie deal window
        deal_win = view_deal_window.createWindow(win_id, 0, 0, 600, 600);
        deal_win.setModal(true);

        var win_title = 'Select Deal';
        var win_url = '../../../../_deal_capture/maintain_deals/maintain.deals.new.php';
        var params = {read_only:true,col_list:col_list,deal_select_completed:'ns_des_hedge.process_selected_hedge_deal',trans_type:trans_type,call_from:'designation_of_hedge'};

        deal_win.setText(win_title);
        deal_win.maximize();
        processing_grid_obj = obj;
        deal_win.attachURL(win_url, false, params);

    } //end ns_des_hedge.select_deal()


    ns_des_hedge.process_selected_hedge_deal = function(result) {
        //close child window
        deal_win.close();
        var form_obj = ns_des_hedge.details_form["details_form_" + active_tab_id + "_0"];
        var link_id = form_obj.getItemValue('link_id');
        link_id = (link_id == '') ? 'NULL' :  link_id;
        //Reload Grid 
        if (result.length > 0) {
            var deal_ids = result.toString();
            var sql_stmt = "EXEC spa_faslinkdetail @flag='h',@hedge_or_item='h', @link_id= " + link_id + ",@source_deal_header_id=" + singleQuote(deal_ids);
            // load grid data
            var sql_param = {
                "sql": sql_stmt,
                "grid_type": 'g'
            };

            var data = {
                "action": "spa_faslinkdetail",
                "flag":'h',
                "link_id": link_id,
                "source_deal_header_id": deal_ids,
                "hedge_or_item": "h"
            };

            adiha_post_data('return_array', data, '', '', 'append_to_grid', '');
        }

    }

    function append_to_grid(result) {
        processing_grid_obj.parse(result, "jsarray");
    }

    function get_selected_ids(grid_obj, column_name) {
        var rid = grid_obj.getSelectedRowId();
        if (rid == '' || rid == null) {
            //alert('Link id is null'); 
            return false;
        }
        var rid_array = new Array();
        if (rid.indexOf(",") != -1) {
            rid_array = rid.split(',');
        } else {
            rid_array.push(rid);
        }

        var cid = grid_obj.getColIndexById(column_name);
        var selected_ids = new Array();
        $.each(rid_array, function( index, value ) {
            selected_ids.push(grid_obj.cells(value,cid).getValue());
        });
        selected_ids = selected_ids.toString();
        return selected_ids;
    }

    ns_des_hedge.item_dicing = function(grid_obj) {
        var link_id = get_selected_ids(grid_obj, 'link_id');

        if (link_id == null || link_id == '') {
            dhtmlx.alert({
                title: 'Error',
                type: "alert-error",
                text: 'Please select link to run measurement'
            });
        }

        var general_form_obj = ns_des_hedge.details_form["details_form_" + active_tab_id + "_0"];
        var link_desc = general_form_obj.getItemValue('link_description');
        var deal_id = get_selected_ids(grid_obj, 'source_deal_header_id');
        var eff_date = get_selected_ids(grid_obj, 'effective_date');
        var term_start = get_selected_ids(grid_obj, 'term_start');
        var term_end = get_selected_ids(grid_obj, 'term_end');

        var params = {link_id:link_id,desc:link_desc,deal_id:deal_id,eff_date:eff_date,term_start:term_start,term_end:term_end};
        //console.log(params)
        var width = 450;
        var height = 550;
        var win_title = 'Hedge Item Dicing';
        var win_url = 'hedge.dice.items.iu.php';
        if (!dice_window) {
            dice_window = new dhtmlXWindows();
        }
        var win = dice_window.createWindow('w1', 0, 0, width, height);
        win.setText(win_title);
        win.centerOnScreen();
        win.setModal(true);
        //win.button('minmax').hide();
        win.button('park').hide();
        win.attachURL(win_url, false, params);

        win.attachEvent('onClose', function(w) {
            return true;
        });

    }

    ns_des_hedge.delete_dedesignated_links = function(ids, call_from) {

        var confirm_msg = 'Do you want to delete the selected links';

        dhtmlx.confirm({
            type:"confirm-warning",
            ok:"Yes", cancel:"No",
            text:"Delete forecasted transactions also",
            callback:function(result){
                var link_id = ids;

                if (result) {
                    data = {
                        "action": "spa_reject_finalized_link",
                        "link_id": link_id
                    }
                } else {
                    data = {
                        "action": "spa_faslinkheader",
                        "flag": "d",
                        "link_id": link_id
                    }
                }

                result = adiha_post_data("return_array", data, "", "","post_delete_dedesignated_links");
                var cell_obj_menu = ns_des_hedge.details_menu["details_menu_" + call_from + "_" + active_tab_id];
                cell_obj_menu.setItemDisabled('delete');
            }
        });
    }

    function post_delete_dedesignated_links(result) {
        //refresh all grids
        if (result[0][0] == 'Success') {
            dhtmlx.message({
                text: result[0][4],
                expire: 1000
            });

        } else {
            dhtmlx.message({
                type: "alert-error",
                title: "Error",
                text: result[0][4]
            });
        }

        var form_index = "details_form_" + active_tab_id + "_0";
        var layout_obj = ns_des_hedge.details_layout[form_index];
        //hedges grid
        var i = 1;
        var cell_obj = layout_obj.cells('a');
        var grid_index = "details_grid_hedges_" + active_tab_id;
        // cell_obj.progressOn();
        ns_des_hedge.dny_refresh_grids(grid_definition_json[i]["sql_stmt"]);

        //items grid
        var i = 2;
        var cell_obj = layout_obj.cells('b');
        // cell_obj.progressOn();
        var grid_index = "details_grid_items_" + active_tab_id;
        ns_des_hedge.dny_refresh_grids(grid_definition_json[i]["sql_stmt"]);

        //dedesignate grid
        var i = 3;
        var grid_index = "details_grid_dedesignation_" + active_tab_id;
        ns_des_hedge.refresh_grids(grid_definition_json[i]["sql_stmt"], ns_des_hedge.details_grid[grid_index], 'g', active_tab_id);

        var rcount = ns_des_hedge.details_grid[grid_index].getRowsNum();
        if (rcount == 0) {
            ns_des_hedge.details_form["details_form_" + active_tab_id + "_0"].uncheckItem('fully_dedesignated');
        }
    }

    ns_des_hedge.open_assessment_result = function() {
        var general_form_obj = ns_des_hedge.details_form["details_form_" + active_tab_id + "_0"];
        var link_id = general_form_obj.getItemValue('link_id');
        var rel_id = general_form_obj.getItemValue('eff_test_profile_id');
        var initial_ongoing = ns_des_hedge.details_form["details_form_" + active_tab_id + "_4"].getItemValue('initial_ongoing');

        if (link_id == null || link_id == '') {
            dhtmlx.alert({
                title: 'Error',
                type: "alert-error",
                text: 'Please select link to run assessment result.'
            });
        }

        var params = {link_id:link_id,rel_id:rel_id,calc_level:2};
        var width = 400;
        var height = 250;
        var win_title = 'Assessment Result Detail';
        var win_url = 'view.assmt.results.iu.php';

        if (!new_win) {
            new_win = new dhtmlXWindows();
        }

        var win = new_win.createWindow('w1', 0, 0, width, height);
        win.setText(win_title);
        win.centerOnScreen();
        win.setModal(true);
        win.button('minmax').hide();
        win.button('park').hide();
        win.attachURL(win_url, false, params);

        win.attachEvent('onClose', function(w) {
            var ifr = w.getFrame();
            var ifrWindow = ifr.contentWindow;
            var ifrDocument = ifrWindow.document;
            var success_status = $('textarea[name="success_status"]', ifrDocument).val();
            if (success_status == 'Success') {
                ns_des_hedge.refresh_assessment_result();
            }

            return true;
        });

    }

    function run_assessment_result_report(call_from, grid_obj) {
        result_id = get_selected_ids(grid_obj, 'result_id');
        var win_url, exec_call;
        var session_id = '<?php echo $session_id; ?>';
        var app_user_name = '<?php echo $app_user_name; ?>';

        if (call_from == 'plot_result') {
            items_combined_plot = '<?php echo $items_combined_plot; ?>';
            paramset_id_plot = '<?php echo $paramset_id_plot; ?>';

            var url =  '../adiha.html.forms/_reporting/report_manager_dhx/report.viewer.php?'
                + 'report_name=Assessment Results Plot_Assessment Results Plot'
                + '&report_filter=result_id=' + result_id + '&is_refresh=0'
                + '&items_combined=' + items_combined_plot
                + '&paramset_id=' + paramset_id_plot +  '&export_type=HTML4.0'
                + '&session_id=' + session_id
                + '&__user_name__=' + app_user_name
                + '&close_progress=1';
            // open_message_dhtmlx(url, 'window name');
            //window.top.open_line_graph_window(url);

            window.top.open_menu_window(url, 'Assessment Results Plot', 'Assessment Results Plot')
            return;

            //exec_call = "EXEC spa_Get_Assessment_Results_Plot " + result_id;
            // win_url = js_php_path + '/graph/flashgraph/flash.plot.php?__user_name__=' + js_user_name + '&spa=' + exec_call + '&pop_up=true';
        } else if (call_from == 'plot_series') {
            items_combined_plot_series = '<?php echo $items_combined_plot_series; ?>';
            paramset_id_plot_series = '<?php echo $paramset_id_plot_series; ?>';

            var url = '../adiha.html.forms/_reporting/report_manager_dhx/report.viewer.php?'
                + 'report_name=Assessment Results Plot Series_Assessment Results Plot Series'
                + '&report_filter=result_id=' + result_id + '&is_refresh=0'
                + '&items_combined=' + items_combined_plot_series
                + '&paramset_id=' + paramset_id_plot_series +  '&export_type=HTML4.0'
                + '&session_id=' + session_id
                + '&__user_name__=' + app_user_name
                + '&close_progress=1';
            // open_message_dhtmlx(url, 'window name');
            window.top.open_menu_window(url, 'Assessment Results Plot Series', 'Assessment Results Plot Series')
            return;
            //alert('work on progress');
            //return;

            //exec_call = "EXEC spa_Get_Assessment_Results_curves_Plot " + result_id;
            //win_url = js_php_path + '/graph/flashgraph/flash.plot.php?__user_name__=' + js_user_name + '&spa=' + exec_call + '&pop_up=true';
        } else if (call_from == 'plot_trends') {
            var link_id = (active_object_id.indexOf("tab_") != -1) ? active_object_id.replace("tab_", "") : active_object_id;
            //var general_form_obj = ns_des_hedge.details_form["details_form_" + active_tab_id + "_0"];
            var ass_form_obj = ns_des_hedge.details_form["details_form_" + active_tab_id + "_4"]
            //var hedging_rel_type_id = general_form_obj.getItemValue('eff_test_profile_id');

            //var initial_ongoing = ns_des_hedge.details_form["details_form_" + active_tab_id + "_3"].getItemValue('initial_ongoing');
            var initial_ongoing = ass_form_obj.getItemValue('initial_ongoing');
            var as_of_date_from = ass_form_obj.getItemValue('date_from', true);
            var as_of_date_to = ass_form_obj.getItemValue('date_to', true);

            items_combined_plot_trends = '<?php echo $items_combined_plot_trends; ?>';
            paramset_id_plot_trends = '<?php echo $paramset_id_plot_trends; ?>';

            var filters = 'as_of_date_from=' + as_of_date_from + ',as_of_date_to=' + as_of_date_to+ ',initial_ongoing=' + initial_ongoing + ',link_id=' + link_id
            var url = '../adiha.html.forms/_reporting/report_manager_dhx/report.viewer.php?'
                + 'report_name=Assessment Results Plot Trends_Assessment Results Plot Trends'
                + '&report_filter=' + filters + '&is_refresh=0'
                + '&items_combined=' + items_combined_plot_trends
                + '&paramset_id=' + paramset_id_plot_trends +  '&export_type=HTML4.0'
                + '&session_id=' + session_id
                + '&__user_name__=' + app_user_name
                + '&close_progress=1';
            // open_message_dhtmlx(url, 'window name');
            window.top.open_menu_window(url, 'Assessment Results Plot Trends', 'Assessment Results Plot Trends')
            return;

        } else if (call_from == 'assessment_test_result') {

            if (result_id == null || result_id == '') {
                dhtmlx.alert({
                    title: 'Error',
                    type: "alert-error",
                    text: 'Please select link to run assessment test result.'
                });
                return;
            }
            ns_des_hedge.open_assessment_report(result_id);
        } else if (call_from == 'export_series') {
            exec_call = "EXEC spa_get_assessment_results_curves_plot " + result_id;
            win_url = js_php_path + '/dev/spa_csv.php?__user_name__=' + js_user_name + '&spa=' + exec_call + '&pop_up=true';
        } else if (call_from == 'export_profile') {
            exec_call = "EXEC spa_fas_eff_ass_test_results_profile  's', " + result_id;
            win_url = js_php_path + '/dev/spa_html.php?__user_name__=' + js_user_name + '&spa=' + exec_call + '&pop_up=true';
        }

        if (call_from != 'assessment_test_result') {
            open_window_with_post(win_url);
        }
    }

    ns_des_hedge.delete_assessment_result = function(ids) {
        data = {
            "action": "spa_Override_Assessment_Results",
            "flag": "d",
            "eff_test_result_id": ids,
            "initial_ongoing": "o"
        }

        result = adiha_post_data("return_array", data, "", "","post_delete_assessment_result");
    }

    function post_delete_assessment_result() {
        ns_des_hedge.refresh_assessment_result();
    }

    ns_des_hedge.open_document = function() {
        var object_id = active_tab_id;
        param = '../../../../_setup/manage_documents/manage.documents.php?notes_category=' + category_id + '&notes_object_id=' + object_id + '&is_pop=true';

        var dhxWins = new dhtmlXWindows();
        var is_win = dhxWins.isWindow('w11');
        if (is_win == true) {
            w11.close();
        }
        w11 = dhxWins.createWindow("w11", 520, 100, 530, 550);
        w11.setText("Documents");
        w11.setModal(true);
        w11.maximize();
        w11.attachURL(param, false, true);

        w11.attachEvent("onClose", function(win) {
            update_document_counter(object_id, ns_des_hedge.toolbar_des_hedge);
            return true;
        });
    }

    ns_des_hedge.open_assessment_report = function(result_id) {
        var params = {eff_test_result_id:result_id};
        var width = 400;
        var height = 500;
        var win_title = 'Assessment Test Result';
        var win_url = 'view.assmt.report.php';

        if (!new_win) {
            new_win = new dhtmlXWindows();
        }

        var win = new_win.createWindow('w1', 0, 0, width, height);
        win.setText(win_title);
        win.centerOnScreen();
        win.setModal(true);
        win.button('minmax').hide();
        win.button('park').hide();
        win.attachURL(win_url, false, params);

    }

    ns_des_hedge.undock_cell = function(val) {
        var layout_obj = ns_des_hedge.details_layout["details_form_" + active_tab_id + "_1"];
        layout_obj.cells(val).undock(300, 300, 900, 700);
        layout_obj.dhxWins.window(val).button("park").hide();
        layout_obj.dhxWins.window(val).maximize();
        layout_obj.dhxWins.window(val).centerOnScreen();
        ns_des_hedge.on_undock_event(val);
    }

    /**
     * [on_undock_event On undock event]
     * @param  {[type]} id [Cell id]
     */
    ns_des_hedge.on_undock_event = function(id) {
        if (id == 'b') {
            $(".undock_hedges").hide();
        }
        if (id == 'c') {
            $(".undock_items").hide();
        }
    }

    function call_from_hyperlink(func_id, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10 , asofdate, asofdate_to) {
        window.parent.parent.link_ui.custom_load(func_id, arg1, arg2, arg3);
    }

</script>
</html>