<?php
/**
* Setup hedging strat screen
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
    <?php
    include '../../../adiha.php.scripts/components/include.file.v3.php';
    require('../../../adiha.html.forms/_setup/manage_documents/manage.documents.button.php');
    ?>
</head>
<?php
$right_setup_book_structure = 10101200;
$rights_book_structure_iu = 10101210;
$rights_book_structure_del = 10101211;

//These are not actually privileges. These are used only to defined templates for
$rights_subsidiary = 10101216;
$rights_strategy = 10101217;
$rights_book_mapping = 10101213;

list (
    $has_rights_book_structure_iu,
    $has_rights_book_structure_del
    ) = build_security_rights (
    $rights_book_structure_iu,
    $rights_book_structure_del
);


$enable_data_ui = ($has_rights_book_structure_iu) ? 'false' : 'true';


$tree_id = get_sanitized_value($_REQUEST['tree_id'] ?? '');
$level_name = get_sanitized_value($_REQUEST['level_name'] ?? '');
$tab_name = get_sanitized_value($_REQUEST['tab_name'] ?? '');



$form_namespace = 'setup_book_structure';
$popup = new AdihaPopup();
$setup_book_structure = new AdihaLayout();
$book_structure_toolbar = new AdihaToolbar();

$layout_json = '[
                        {
                            id:             "a",
                            text:          "<div><a class=\'undock_cell_a undock_custom\' style=\'float:right;cursor:pointer\' title=\'Undock\'  onClick=\'setup_book_structure.undock_cell_a();\'><!--&#8599;--></a>' . get_locale_value('Portfolio Hierarchy') . '</div>",
                            width:         400,
                            height:         20,
                            header:         true,
                            collapse:       false,
                            fix_size:       [false,null]
                        },
                        {
                            id:             "b",
                            header:         false,
                            collapse:       false,
                            fix_size:       [false,null]
                        }
                    ]';

//Attaching toolbar
$toolbar_name =  'book_structure_toolbar';
$toolbar_json = '[
                        {id: "save", text: "Save", img:"save.gif", imgdis:"save_dis.gif"},
                        {id: "refresh", text: "Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif"},
                        {id:"t1", text:"Edit", img:"edit.gif", items:[
                            {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add", disabled: ' . $enable_data_ui . '},
                            {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete", disabled: true},
                            {id:"change", text:"Change Hierarchy Level", img:"settings.gif", imgdis:"settings_dis.gif", title: "Change Hierarchy Level", disabled: "true"},
                            {id:"transfer", img:"transfer.gif", imgdis:"transfer_dis.gif", text:"Transfer", title:"Transfer", disabled:true},
                        ]},
                        {id: "advanced", text: "Advanced Mode", img:"open.gif", imgdis:"open_dis.gif"},
                        {id: "simple", text: "Simple Mode", img:"open.gif", imgdis:"open_dis.gif",hidden:true}
                    ]';

echo $setup_book_structure -> init_layout('setup_book_structure', '', '2U', $layout_json, $form_namespace);
echo $setup_book_structure -> attach_menu_cell($toolbar_name, 'a');
echo $book_structure_toolbar -> init_by_attach($toolbar_name, $form_namespace);
echo $book_structure_toolbar -> load_toolbar($toolbar_json);
echo $book_structure_toolbar -> attach_event('', 'onClick',$form_namespace .'.grid_toolbar_click');

// Attaching Tree
$tree_structure = new AdihaBookStructure($right_setup_book_structure);
$tree_name = 'tree_book_structure';

echo $setup_book_structure->attach_tree_cell($tree_name, 'a');
echo $tree_structure->init_by_attach($tree_name, $form_namespace);

echo $tree_structure->set_portfolio_option(0);
echo $tree_structure->set_subsidiary_option(0);
echo $tree_structure->set_strategy_option(0);
echo $tree_structure->set_book_option(0);
echo $tree_structure->set_subbook_option(0);
echo $tree_structure->define_doubleclick_events($form_namespace.'.open_book');
echo $tree_structure->load_book_structure_data();
echo $tree_structure->expand_level('all');
//    echo $tree_structure->enable_editor();
echo $tree_structure->attach_event('', 'onSelect', 'setup_book_structure.book_on_select');
echo $tree_structure->attach_search_filter('setup_book_structure.setup_book_structure', 'a');

$tag_names_sp = "EXEC spa_book_tag_name @flag = 's'"; 
$tag_names = readXMLURL($tag_names_sp);

$check_tagging_sp = "EXEC spa_book_tag_name @flag = 'x'"; 
$return_value = readXMLURL($check_tagging_sp);
$check_tagging = $return_value[0][0];

//Attaching tabbar
$book_tab = new AdihaTab();
$tabbar_name = 'book_structure';
echo $setup_book_structure->attach_event('', 'onDock', $form_namespace . '.on_dock_event');
echo $setup_book_structure->attach_event('', 'onUnDock', $form_namespace . '.on_undock_event');
echo $setup_book_structure->attach_tab_cell($tabbar_name, 'b', '');
echo $book_tab->init_by_attach($tabbar_name,$form_namespace);
echo $book_tab->enable_tab_close();
echo $book_tab->attach_event('', 'onTabClose', 'setup_book_structure.details_close');

echo $setup_book_structure->close_layout();

$category_sql = "SELECT value_id FROM static_data_value WHERE type_id = 25 AND code IN ('Subsidiary', 'Strategy', 'Book') ORDER BY code DESC";
$category_data = readXMLURL2($category_sql);

$node_sql = "EXEC spa_setup_simple_book_structure @flag = 'k'";
$sql_result = readXMLURL2($node_sql);
$node_level = $sql_result[0]['node_level'];
$subisidary_level_data = $sql_result[0]['sub_level_json'];
$strategy_level_data = $sql_result[0]['stra_level_json'];

?>
</html>
<script type="text/javascript">
    var category_id;
    var tree_expand_flag = 1;
    var tag_name1 = "<?php echo $tag_names[0][0]; ?>";
    var tag_name2 = "<?php echo $tag_names[0][1]; ?>";
    var tag_name3 = "<?php echo $tag_names[0][2]; ?>";
    var tag_name4 = "<?php echo $tag_names[0][3]; ?>";
    var check_tagging = "<?php echo $check_tagging; ?>";

    setup_book_structure.inner_tab_layout_form = {};
    setup_book_structure.inner_tab_layout = {};
    book_parent = {};
    setup_book_structure.inner_tab_layout_tabbar = {};

    var delete_button_state = Boolean('<?php echo $has_rights_book_structure_del;?>');
    var add_edit_button_state = Boolean('<?php echo $has_rights_book_structure_iu;?>');
    var enable_data_ui = (add_edit_button_state == true) ? false : true;

    var node_id_delete;
    var setup_book_structure_id = '10101200'
    var subsidiary_function_id = '10101216';
    var strategy_function_id = '10101217';
    var book_function_id = '10101210';
    var book_mapping_function_id = '10101213';
    var node_level = <?php echo $node_level; ?>;
    var subisidary_level_data = <?php echo $subisidary_level_data; ?>;
    var strategy_level_data = <?php echo $strategy_level_data; ?>;
    var hierarchy_level_sub_array = [];
    var hierarchy_level_strategy_array = [];

    var php_script_loc = js_php_path;
    var SHOW_SUBBOOK_IN_BS = <?php echo $SHOW_SUBBOOK_IN_BS;?>;//show hide parameter for sub book in book structure
    var icon_loc = '<?php echo $image_path."dhxmenu_web/"; ?>';

    $(function() {
        setup_book_structure.undock_cell_a();
        setup_book_structure.book_structure_toolbar.hideItem("simple");
        dhxWins = new dhtmlXWindows();
        var tree_id = '<?php echo $tree_id; ?>';

        var level_name = '<?php echo $level_name; ?>';
        if (tree_id != '') {
            var full_id = '';
            if (level_name == 'Company') {
                full_id = 'x_' + tree_id;
            } else if (level_name == 'Subsidiary') {
                full_id = 'a_' + tree_id;
            } else if (level_name == 'Strategy') {
                full_id = 'b_' + tree_id;
            } else {
                full_id = 'c_' + tree_id;
            }
            setup_book_structure.tree_book_structure.selectItem('1587');
            setup_book_structure.open_book(full_id, 'u', '');
        }

        //
        if (add_edit_button_state) {
            setup_book_structure.tree_book_structure.attachEvent('onRightClick',function (id, ev) {
                var node_id_array = [];
                node_id_array = id.split('_');
                setup_book_structure.tree_book_structure.setCheck(id,1);
                setup_book_structure.tree_book_structure.enableItemEditor(true);

                // setup_book_structure.tree_book_structure.setEditStartAction(true,false);
                setup_book_structure.tree_book_structure.editItem(id);
                setup_book_structure.tree_book_structure.enableItemEditor(false);
                setup_book_structure.tree_book_structure.selectItem(id);

                setup_book_structure.tree_book_structure.setItemColor(id,"red","red");

                if (node_id_array.length == 2 && id != 'x_1') {
                    node_id_array[2] = 'changed';
                    setup_book_structure.tree_book_structure.changeItemId(id,node_id_array.join('_'));
                }

                if(setup_book_structure.book_structure.cells(id)) {
                    delete setup_book_structure.pages[id];
                    setup_book_structure.book_structure.tabs(id).close(true);
                }
            });

        } else {
            setup_book_structure.book_structure_toolbar.removeItem('change');
        }

        setup_book_structure.setup_book_structure.attachEvent("onDock", function(){
            setup_book_structure.book_structure_toolbar.hideItem("advanced");
            setup_book_structure.book_structure_toolbar.showItem("simple");
        });
        setup_book_structure.setup_book_structure.attachEvent("onUnDock", function(){
            setup_book_structure.book_structure_toolbar.hideItem("simple");
            setup_book_structure.book_structure_toolbar.showItem("advanced");
        });

    });

    /**
     * [Attaching url on the click of option in book structure]
     */
    setup_book_structure.open_book = function(full_id, mode, text) {
        var tree_id = '<?php echo $tree_id; ?>';
        var node_id = '';
        if (tree_id != '') {
            var level_name = '<?php echo $level_name; ?>';
            if (level_name == 'Company') {
                node_id = 'x_' + tree_id;
            } else if (level_name == 'Subsidiary') {
                node_id = 'a_' + tree_id;
            } else if (level_name == 'Strategy') {
                node_id = 'b_' + tree_id;
            } else {
                node_id = 'c_' + tree_id;
            }

        } else {
            node_id = setup_book_structure.tree_book_structure.getSelectedItemId();
        }

        var node_id_array = [];
        var prefix_name = '';
        mode = typeof mode !== 'undefined' ? mode : 'u';

        if (mode == 'u') {
            node_id_array = node_id.split('_');
        } else if (mode == 'i') {
            node_id_array = full_id.split('_');
        }
        if (node_id_array[0] == 'a') {
            prefix_name = 'Sub - ';
            category_id = '<?php echo $category_data[0]['value_id'];?>';
        } else if (node_id_array[0] == 'b') {
            prefix_name = 'Strategy - ';
            category_id = '<?php echo $category_data[1]['value_id'];?>';
        } else if (node_id_array[0] == 'c') {
            prefix_name = 'Book - ';
            category_id = '<?php echo $category_data[2]['value_id'];?>';
        } else if (node_id_array[0] == 'd') {
            prefix_name = 'Sub Book - ';
        }

        if (node_id_array[1] == 'new' || node_id_array[2] == 'changed') {
            show_messagebox("Save changes in grid first.");
            return;
        }

        var com_id = -1;

        company = {
            "action" : "spa_create_application_ui_json",
            "flag" : "j",
            "application_function_id" : subsidiary_function_id,
            "template_name" : "setup_book_subsidiary",
            "parse_xml" : "<Root><PSRecordSet fas_subsidiary_id=\"" + com_id + "\"></PSRecordSet></Root>"
        };

        subsidiary = {
            "action" : "spa_create_application_ui_json",
            "flag" : "j",
            "application_function_id" : subsidiary_function_id,
            "template_name" : "setup_book_subsidiary",
            "parse_xml" : "<Root><PSRecordSet fas_subsidiary_id=\"" + node_id_array[1] + "\"></PSRecordSet></Root>"
        };


        strategy = {
            "action" : "spa_create_application_ui_json",
            "flag" : "j",
            "application_function_id" : strategy_function_id,
            "template_name" : "setup_book_strategy",
            "parse_xml" : "<Root><PSRecordSet fas_strategy_id=\"" + node_id_array[1] + "\"></PSRecordSet></Root>"
        };


        book = {
            "action" : "spa_create_application_ui_json",
            "flag" : "j",
            "application_function_id" : book_function_id,
            "template_name" : "setup_book_option",
            "parse_xml" : "<Root><PSRecordSet fas_book_id=\"" + node_id_array[1] + "\"></PSRecordSet></Root>"
        };

        book_mapping =  {
            "action" : "spa_create_application_ui_json",
            "flag" : "j",
            "application_function_id" : book_mapping_function_id,
            "template_name" : "setup_sub_book_mapping",
            "parse_xml" : "<Root><PSRecordSet book_deal_type_map_id=\"" + node_id_array[1] + "\"></PSRecordSet></Root>"
        };


        if (!setup_book_structure.pages[full_id]) {

            //var tab_name = setup_book_structure.tree_book_structure.getSelectedItemText();
            var tab_name = '';
            if (tree_id != '') {
                tab_name = tab_name = '<?php echo $tab_name; ?>';
            } else {
                tab_name = setup_book_structure.tree_book_structure.getSelectedItemText();
            }

            if (tree_id == '') {
                tab_name = typeof text !== 'undefined' ? text : tab_name;
            }

            var prev_id = '';

            if (typeof setup_book_structure.book_structure != "undefined") {
                prev_id = setup_book_structure.book_structure.getActiveTab();
            }

            setup_book_structure.book_structure.addTab(full_id,  prefix_name + tab_name, null, null, true, true);
            win = setup_book_structure.book_structure.cells(full_id);
            setup_book_structure.pages[full_id] = win;

            var toolbar_json = '[{ id: "save", type: "button", img: "save.gif", imgdis:"save_dis.gif", text:"Save", title: "Save", disabled: '+enable_data_ui+'}';
            if('abc'.indexOf(node_id_array[0]) > -1)
            {
                toolbar_json = toolbar_json + ', { id: "documents", type: "button", img: "doc.gif", imgdis:"doc_dis.gif", text:"Documents", title: "Documents", disabled: '+enable_data_ui+'}';
            }
            toolbar_json = toolbar_json + ']';

            setup_book_structure["inner_tab_layout_" + full_id] = win.attachLayout("1C");
            setup_book_structure["inner_tab_layout_" + full_id].cells('a').setHeight(300);
            inner_tab_toolbar =  setup_book_structure["inner_tab_layout_" + full_id].cells('a').attachToolbar();
            inner_tab_toolbar.setIconsPath(icon_loc);
            inner_tab_toolbar.loadStruct(toolbar_json);
            inner_tab_toolbar.attachEvent('onClick', setup_book_structure.book_structure_toolbar_click_update);

            if (node_id_array[0] == 'x') {
                adiha_post_data('return_array',company, '', '', 'book_structure_details', '');
            } else if (node_id_array[0] == 'a') {
                adiha_post_data('return_array',subsidiary, '', '', 'book_structure_details', '');
            } else if (node_id_array[0] == 'b') {
                adiha_post_data('return_array',strategy, '', '', 'book_structure_details', '');
            } else if (node_id_array[0] == 'c') {
                adiha_post_data('return_array',book, '', '', 'book_structure_details', '');
            } else if (node_id_array[0] == 'd') {
                adiha_post_data('return_array',book_mapping, '', '', 'book_structure_details', '');
            }

            var object_id = node_id_array[1];
            apply_sticker(object_id);
            toolbar_obj = inner_tab_toolbar;
            update_document_counter(object_id, toolbar_obj);
        } else {
            setup_book_structure.book_structure.cells(full_id).setActive();
        }
    }

    setup_book_structure.book_on_select = function(id) { 
        var node_id_array = [];
        node_id_array = id.split('_');
        var level = get_hierrarchy_level(id);
        var hierarchy_level = setup_book_structure.tree_book_structure.getLevel(id);

        if (delete_button_state == true)
            setup_book_structure.book_structure_toolbar.setItemEnabled("delete");

        if (node_id_array[0] == 'x' && node_id_array[1] != 'new')
            setup_book_structure.book_structure_toolbar.setItemDisabled("delete");

        if (node_id_array[0] == 'd' || (hierarchy_level - 1)  == level) {
            setup_book_structure.book_structure_toolbar.setItemDisabled("add");
        } else if (add_edit_button_state == true) {
            setup_book_structure.book_structure_toolbar.setItemEnabled("add");
        }

        if ((node_id_array[0] == 'x' || node_id_array[0] == 'a' || node_id_array[0] == 'b') && add_edit_button_state == true && node_id_array[1] != 'new')
            setup_book_structure.book_structure_toolbar.setItemEnabled("change");
        else
            setup_book_structure.book_structure_toolbar.setItemDisabled("change");
        if(add_edit_button_state == true && node_id_array[0] == 'd') {
            setup_book_structure.book_structure_toolbar.setItemEnabled("transfer");
        } else 
            setup_book_structure.book_structure_toolbar.setItemDisabled("transfer");
    }

    setup_book_structure.details_close = function(id) { 
        delete setup_book_structure.pages[id];
        return true;
    }

    function show_hide_gl_code_objects(gl_number_id_st_asset_tab_no, combo_option, active_tab_id) {
        var form_object = setup_book_structure.inner_tab_layout_form["form_" + gl_number_id_st_asset_tab_no + '_' + active_tab_id];

        var array_cash_flow_show = ['gl_number_id_st_asset','gl_number_id_lt_asset','gl_number_id_st_liab','gl_number_id_lt_liab','gl_number_unhedged_der_st_asset','gl_number_unhedged_der_lt_asset','gl_number_unhedged_der_st_liab','gl_number_unhedged_der_lt_liab','gl_id_st_tax_asset','gl_id_lt_tax_asset','gl_id_st_tax_liab','gl_id_lt_tax_liab','gl_id_tax_reserve','gl_number_id_aoci','gl_number_id_inventory','gl_number_id_pnl','gl_number_id_set','gl_number_id_cash','gl_number_id_gross_set','gl_number_id_item_st_asset','gl_number_id_item_st_liab','gl_number_id_item_lt_asset','gl_number_id_item_lt_liab'];
        var array_cash_flow_hide = ['gl_id_amortization', 'gl_number_id_expense', 'gl_id_interest'];
        var array_fair_value_hedges_hide = ['gl_number_id_inventory','gl_id_st_tax_asset','gl_id_lt_tax_asset','gl_id_st_tax_liab','gl_id_lt_tax_liab','gl_id_tax_reserve','gl_number_id_aoci','gl_number_unhedged_der_st_asset','gl_number_unhedged_der_lt_asset','gl_number_unhedged_der_st_liab','gl_number_unhedged_der_lt_liab'];
        var array_fair_value_hedges_show = ['gl_number_id_st_asset','gl_number_id_lt_asset','gl_number_id_st_liab','gl_number_id_lt_liab','gl_number_id_item_st_asset','gl_number_id_item_st_liab','gl_number_id_item_lt_asset','gl_number_id_item_lt_liab','gl_id_amortization','gl_number_id_expense','gl_id_interest' ,'gl_number_id_pnl','gl_number_id_set','gl_number_id_cash','gl_number_id_gross_set'];
        var array_mtm_fair_value_hide = [ 'gl_number_id_item_st_asset','gl_number_id_item_st_liab','gl_number_id_item_lt_asset','gl_number_id_item_lt_liab','gl_id_amortization','gl_id_interest','gl_number_id_expense','gl_id_st_tax_asset','gl_id_lt_tax_asset','gl_id_st_tax_liab','gl_id_lt_tax_liab','gl_id_tax_reserve','gl_number_id_aoci','gl_number_id_inventory','gl_number_unhedged_der_st_asset','gl_number_unhedged_der_lt_asset','gl_number_unhedged_der_st_liab','gl_number_unhedged_der_lt_liab'];

        if (combo_option == 150) {// 'Cash-flow Hedges'
            for (i = 0; i < array_cash_flow_show.length; i++) {
                form_object.showItem(array_cash_flow_show[i]);
            }

            for (i = 0; i < array_cash_flow_hide.length; i++) {
                form_object.hideItem(array_cash_flow_hide[i]);
            }

            form_object.setItemLabel('gl_number_id_item_st_liab', '<a id="gl_number_id_item_st_liab" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Ineffectiveness CR</a>');
            form_object.setItemLabel('gl_number_id_item_st_asset', '<a id="gl_number_id_item_st_asset" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Ineffectiveness DR</a>');
            form_object.setItemLabel('gl_number_id_item_lt_asset', '<a id="gl_number_id_item_lt_asset" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">De-Desig Ineffectiveness DR</a>');
            form_object.setItemLabel('gl_number_id_item_lt_liab', '<a id="gl_number_id_item_lt_liab" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">De-Desig Ineffectiveness CR</a>');

            form_object.setItemLabel('gl_number_id_st_asset', '<a id="gl_number_id_st_asset" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Hedge ST Asset</a>');
            form_object.setItemLabel('gl_number_id_lt_asset', '<a id="gl_number_id_lt_asset" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Hedge LT Asset</a>');
            form_object.setItemLabel('gl_number_id_st_liab', '<a id="gl_number_id_st_liab" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Hedge ST Liability</a>');
            form_object.setItemLabel('gl_number_id_lt_liab', '<a id="gl_number_id_lt_liab" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Hedge LT Liability</a>');

        } else if (combo_option == 151) {// 'Fair-value Hedges'
            for (i = 0; i < array_fair_value_hedges_hide.length; i++) {
                form_object.hideItem(array_fair_value_hedges_hide[i]);
            }

            for (i = 0; i < array_fair_value_hedges_show.length; i++) {
                form_object.showItem(array_fair_value_hedges_show[i]);
            }

            form_object.setItemLabel('gl_number_id_st_asset', '<a id="gl_number_id_st_asset" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Hedge ST Asset</a>');
            form_object.setItemLabel('gl_number_id_lt_asset', '<a id="gl_number_id_lt_asset" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Hedge LT Asset</a>');
            form_object.setItemLabel('gl_number_id_st_liab', '<a id="gl_number_id_st_liab" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Hedge ST Liability</a>');
            form_object.setItemLabel('gl_number_id_lt_liab', '<a id="gl_number_id_lt_liab" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Hedge LT Liability</a>');

            form_object.setItemLabel('gl_number_id_item_st_liab', '<a id="gl_number_id_item_st_liab" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Item ST Liability</a>');
            form_object.setItemLabel('gl_number_id_item_st_asset', '<a id="gl_number_id_item_st_asset" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Item ST Asset</a>');
            form_object.setItemLabel('gl_number_id_item_lt_asset', '<a id="gl_number_id_item_lt_asset" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Item LT Asset</a>');
            form_object.setItemLabel('gl_number_id_item_lt_liab', '<a id="gl_number_id_item_lt_liab" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Item Liability</a>');

        } else if (combo_option == 152) { // MTM (Fair Value)
            for (i = 0; i < array_cash_flow_show.length; i++) {
                form_object.showItem(array_cash_flow_show[i]);
            }

            for (i = 0; i < array_cash_flow_hide.length; i++) {
                form_object.showItem(array_cash_flow_hide[i]);
            }

            for (i = 0; i < array_mtm_fair_value_hide.length; i++) {
                form_object.hideItem(array_mtm_fair_value_hide[i]);
            }

            form_object.setItemLabel('gl_number_id_st_asset', '<a id="gl_number_id_st_asset" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">MTM ST Asset</a>');
            form_object.setItemLabel('gl_number_id_lt_asset', '<a id="gl_number_id_lt_asset" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">MTM LT Asset</a>');
            form_object.setItemLabel('gl_number_id_st_liab', '<a id="gl_number_id_st_liab" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">MTM ST Liability</a>');
            form_object.setItemLabel('gl_number_id_lt_liab', '<a id="gl_number_id_lt_liab" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">MTM LT Liability</a>');
        } else if (combo_option == 153) {// 'Normal Purchase/Sales (Out of Scope)'
            for (i = 0; i < array_cash_flow_show.length; i++) {
                form_object.hideItem(array_cash_flow_show[i]);
            }

            for (i = 0; i < array_cash_flow_hide.length; i++) {
                form_object.hideItem(array_cash_flow_hide[i]);
            }
        } else {
            for (i = 0; i < array_cash_flow_show.length; i++) {
                form_object.showItem(array_cash_flow_show[i]);
            }

            for (i = 0; i < array_cash_flow_hide.length; i++) {
                form_object.showItem(array_cash_flow_hide[i]);
            }

            form_object.setItemLabel('gl_number_id_item_st_liab', '<a id="gl_number_id_item_st_liab" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Ineffectiveness CR</a>');
            form_object.setItemLabel('gl_number_id_item_st_asset', '<a id="gl_number_id_item_st_asset" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Ineffectiveness DR</a>');
            form_object.setItemLabel('gl_number_id_item_lt_asset', '<a id="gl_number_id_item_lt_asset" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">De-Desig Ineffectiveness DR</a>');
            form_object.setItemLabel('gl_number_id_item_lt_liab', '<a id="gl_number_id_item_lt_liab" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">De-Desig Ineffectiveness CR</a>');

            form_object.setItemLabel('gl_number_id_st_asset', '<a id="gl_number_id_st_asset" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Hedge ST Asset</a>');
            form_object.setItemLabel('gl_number_id_lt_asset', '<a id="gl_number_id_lt_asset" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Hedge LT Asset</a>');
            form_object.setItemLabel('gl_number_id_st_liab', '<a id="gl_number_id_st_liab" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Hedge ST Liability</a>');
            form_object.setItemLabel('gl_number_id_lt_liab', '<a id="gl_number_id_lt_liab" href="javascript:void(0);" onclick="call_TRMWinHyperlink(10101300,this.id);">Hedge LT Liability</a>');
        }
    }

    /**
     *  [Enabled/Disabled GL Code Mapping Tab objects for Strategy]
     */
    function enable_disable_gl_code_objects(gl_number_id_st_asset_tab_no, enable_combos, active_tab_id) {
        var active_tab_id = setup_book_structure.book_structure.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        var form_object = setup_book_structure.inner_tab_layout_form["form_" + gl_number_id_st_asset_tab_no + '_' + active_tab_id];
        
        if(!enable_combos) {
            setup_book_structure.inner_tab_layout_tabbar[active_object_id].tabs(form_object.fake_tab_id).hide();
        } else {
            setup_book_structure.inner_tab_layout_tabbar[active_object_id].tabs(form_object.fake_tab_id).show();
        }

        if (enable_combos == true) {
            form_object.enableItem('gl_number_id_st_asset');
            form_object.enableItem('gl_number_id_lt_asset');
            form_object.enableItem('gl_number_id_st_liab');
            form_object.enableItem('gl_number_id_lt_liab');
            form_object.enableItem('gl_id_st_tax_asset');
            form_object.enableItem('gl_id_lt_tax_asset');
            form_object.enableItem('gl_id_st_tax_liab');
            form_object.enableItem('gl_id_lt_tax_liab');
            form_object.enableItem('gl_id_tax_reserve');
            form_object.enableItem('gl_number_id_aoci');
            form_object.enableItem('gl_number_id_inventory');
            form_object.enableItem('gl_number_id_pnl');
            form_object.enableItem('gl_number_id_set');
            form_object.enableItem('gl_number_id_cash');
            form_object.enableItem('gl_number_id_gross_set');
            form_object.enableItem('gl_number_id_item_st_asset');
            form_object.enableItem('gl_number_id_item_st_liab');
            form_object.enableItem('gl_number_id_item_lt_asset');
            form_object.enableItem('gl_number_id_item_lt_liab');
            form_object.enableItem('gl_number_unhedged_der_st_asset');
            form_object.enableItem('gl_number_unhedged_der_lt_asset');
            form_object.enableItem('gl_number_unhedged_der_st_liab');
            form_object.enableItem('gl_number_unhedged_der_lt_liab');
            form_object.enableItem('gl_id_amortization');
            form_object.enableItem('gl_id_interest');
            form_object.enableItem('gl_number_id_expense');
        } else {
            form_object.disableItem('gl_number_id_st_asset');
            form_object.disableItem('gl_number_id_lt_asset');
            form_object.disableItem('gl_number_id_st_liab');
            form_object.disableItem('gl_number_id_lt_liab');
            form_object.disableItem('gl_id_st_tax_asset');
            form_object.disableItem('gl_id_lt_tax_asset');
            form_object.disableItem('gl_id_st_tax_liab');
            form_object.disableItem('gl_id_lt_tax_liab');
            form_object.disableItem('gl_id_tax_reserve');
            form_object.disableItem('gl_number_id_aoci');
            form_object.disableItem('gl_number_id_inventory');
            form_object.disableItem('gl_number_id_pnl');
            form_object.disableItem('gl_number_id_set');
            form_object.disableItem('gl_number_id_cash');
            form_object.disableItem('gl_number_id_gross_set');
            form_object.disableItem('gl_number_id_item_st_asset');
            form_object.disableItem('gl_number_id_item_st_liab');
            form_object.disableItem('gl_number_id_item_lt_asset');
            form_object.disableItem('gl_number_id_item_lt_liab');
            form_object.disableItem('gl_number_unhedged_der_st_asset');
            form_object.disableItem('gl_number_unhedged_der_lt_asset');
            form_object.disableItem('gl_number_unhedged_der_st_liab');
            form_object.disableItem('gl_number_unhedged_der_lt_liab');
            form_object.disableItem('gl_id_amortization');
            form_object.disableItem('gl_id_interest');
            form_object.disableItem('gl_number_id_expense');
        }
    }

    function on_change_accounting_type(detail_tab_number, combo_option, active_tab_id) {

        var form_object = setup_book_structure.inner_tab_layout_form["form_" + detail_tab_number + '_' + active_tab_id];
        if (combo_option == 151) { // Fair-value Hedges
            form_object.disableItem('mismatch_tenor_value_id');
            form_object.disableItem('mes_cfv_value_id');
            form_object.disableItem('oci_rollout_approach_value_id');
            form_object.disableItem('rollout_per_type');
            form_object.enableItem('mes_gran_value_id');//Measurement Granularity
            form_object.enableItem('gl_grouping_value_id');
            form_object.enableItem('strip_trans_value_id');
            form_object.enableItem('mes_cfv_values_value_id');
            form_object.enableItem('test_range_from');
            form_object.enableItem('additional_test_range_from');
            form_object.enableItem('test_range_to');
            form_object.enableItem('additional_test_range_to');
            form_object.enableItem('test_range_from2');
            form_object.enableItem('test_range_to2');
            form_object.enableItem('include_unlinked_hedges');
            form_object.enableItem('include_unlinked_items');
            form_object.enableItem('fx_hedge_flag');
        } else if (combo_option == 152) { //'MTM (Fair Value)'
            form_object.enableItem('gl_grouping_value_id');
            form_object.disableItem('mes_gran_value_id');
            form_object.disableItem('mismatch_tenor_value_id');
            form_object.disableItem('rollout_per_type');
            form_object.disableItem('mes_cfv_value_id');
            form_object.disableItem('strip_trans_value_id');
            form_object.disableItem('mes_cfv_values_value_id');
            form_object.disableItem('oci_rollout_approach_value_id');
            form_object.disableItem('test_range_from');
            form_object.disableItem('additional_test_range_from');
            form_object.disableItem('test_range_to');
            form_object.disableItem('additional_test_range_to');
            form_object.disableItem('test_range_from2');
            form_object.disableItem('test_range_to2');
            form_object.disableItem('include_unlinked_hedges');
            form_object.disableItem('include_unlinked_items');
            form_object.disableItem('fx_hedge_flag');
        } else if (combo_option == 155 || combo_option == 154) { //Accrual Accounting OR Inventory Accounting
            form_object.disableItem('mes_gran_value_id');//Measurement Granularity

            form_object.enableItem('mismatch_tenor_value_id');
            var rolling_hedge_forward = form_object.getCombo('mismatch_tenor_value_id');

            if (rolling_hedge_forward != null) {
                form_object.attachEvent('onOptionsLoaded', function(name) {
                    if (name == 'mismatch_tenor_value_id') {
                        var combo_option = rolling_hedge_forward.getSelectedValue();

                        if (combo_option == 252) {//Apply Hedge/Item Term Mismatch
                            form_object.enableItem('rollout_per_type');
                        } else {
                            form_object.disableItem('rollout_per_type');
                        }
                    }
                })

                var combo_option = rolling_hedge_forward.getSelectedValue();

                if (combo_option == 252) {//Apply Hedge/Item Term Mismatch
                    form_object.enableItem('rollout_per_type');
                } else {
                    form_object.disableItem('rollout_per_type');
                }
            }

            form_object.enableItem('gl_grouping_value_id');
            form_object.enableItem('mes_cfv_value_id');
            form_object.enableItem('strip_trans_value_id');
            form_object.enableItem('mes_cfv_values_value_id');
            form_object.enableItem('oci_rollout_approach_value_id');
            form_object.enableItem('test_range_from');
            form_object.enableItem('additional_test_range_from');
            form_object.enableItem('test_range_to');
            form_object.enableItem('additional_test_range_to');
            form_object.enableItem('test_range_from2');
            form_object.enableItem('test_range_to2');
            form_object.enableItem('include_unlinked_hedges');
            form_object.enableItem('include_unlinked_items');
            form_object.enableItem('fx_hedge_flag');
        } else if (combo_option == 153) { //Normal Purchase/Sales (Out of Scope)
            form_object.enableItem('fx_hedge_flag');

            form_object.disableItem('mes_gran_value_id');
            form_object.disableItem('gl_grouping_value_id');
            form_object.disableItem('mismatch_tenor_value_id');
            form_object.disableItem('rollout_per_type');
            form_object.disableItem('mes_cfv_value_id');
            form_object.disableItem('strip_trans_value_id');
            form_object.disableItem('mes_cfv_values_value_id');
            form_object.disableItem('oci_rollout_approach_value_id');
            form_object.disableItem('test_range_from');
            form_object.disableItem('additional_test_range_from');
            form_object.disableItem('test_range_to');
            form_object.disableItem('additional_test_range_to');
            form_object.disableItem('test_range_from2');
            form_object.disableItem('test_range_to2');
            form_object.disableItem('include_unlinked_hedges');
            form_object.disableItem('include_unlinked_items');
        } else {
            form_object.enableItem('mismatch_tenor_value_id');
            var rolling_hedge_forward = form_object.getCombo('mismatch_tenor_value_id');

            if (rolling_hedge_forward != null) {
                form_object.attachEvent('onOptionsLoaded', function(name) {
                    if (name == 'mismatch_tenor_value_id') {
                        var combo_option = rolling_hedge_forward.getSelectedValue();

                        if (combo_option == 252) {//Apply Hedge/Item Term Mismatch
                            form_object.enableItem('rollout_per_type');
                        } else {
                            form_object.disableItem('rollout_per_type');
                        }
                    }
                })

                var combo_option = rolling_hedge_forward.getSelectedValue();

                if (combo_option == 252) {//Apply Hedge/Item Term Mismatch
                    form_object.enableItem('rollout_per_type');
                } else {
                    form_object.disableItem('rollout_per_type');
                }
            }

            form_object.enableItem('gl_grouping_value_id');
            form_object.enableItem('mes_gran_value_id');
            form_object.enableItem('mes_cfv_value_id');
            form_object.enableItem('strip_trans_value_id');
            form_object.enableItem('mes_cfv_values_value_id');
            form_object.enableItem('oci_rollout_approach_value_id');
            form_object.enableItem('test_range_from');
            form_object.enableItem('additional_test_range_from');
            form_object.enableItem('test_range_to');
            form_object.enableItem('additional_test_range_to');
            form_object.enableItem('test_range_from2');
            form_object.enableItem('test_range_to2');
            form_object.enableItem('include_unlinked_hedges');
            form_object.enableItem('include_unlinked_items');
            form_object.enableItem('fx_hedge_flag');
        }
    }
    /**
     *
     */
    function book_structure_details(result) {
        // console.log(result);
        var active_tab_id = setup_book_structure.book_structure.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        var node_id = setup_book_structure.tree_book_structure.getSelectedItemId(); //need to varify.
        var gl_number_id_st_asset_tab_no;
        var detail_tab_number;
        var hierarchy_level = setup_book_structure.tree_book_structure.getLevel(setup_book_structure.tree_book_structure.getSelectedItemId());

        var node_id_array = [];
        node_id_array = node_id.split('_');
        var result_length = result.length;
        var tab_json = '';
        var node_index = active_tab_id.substring(0, 1);

        for (i = 0; i < result_length; i++) {
            if (i > 0)
                tab_json = tab_json + ",";
            tab_json = tab_json + (result[i][1]);
        }

        tab_json = '{tabs: [' + tab_json + ']}';
        setup_book_structure.inner_tab_layout_tabbar[active_object_id] =  setup_book_structure["inner_tab_layout_" + active_tab_id].cells("a").attachTabbar({mode:"bottom",arrows_mode:"auto"});
        setup_book_structure.inner_tab_layout_tabbar[active_object_id].loadStruct(tab_json);

        var j = 0;
        result.forEach( function(e){
            tab_id = 'detail_tab_' + result[j][0];
            setup_book_structure.inner_tab_layout_form["form_" + j + '_' + active_tab_id] = setup_book_structure.inner_tab_layout_tabbar[active_object_id].cells(tab_id).attachForm();
            setup_book_structure.inner_tab_layout_form["form_" + j + '_' + active_tab_id].fake_tab_id = tab_id;
            if (result[j][2]) {
                var form_obj = setup_book_structure.inner_tab_layout_form["form_" + j + '_' + active_tab_id]
                form_obj.loadStruct(result[j][2], function() {
                        var value = form_obj.getItemValue('fas_deal_type_value_id');
                        if(value!=401) {   
                            form_obj.disableItem('fas_deal_sub_type_value_id');
                            //console.log(value);
                        }
                    });

                if (check_tagging == 0) {
                    tab_id = setup_book_structure.tree_book_structure.getSelected();
                    setup_book_structure.inner_tab_layout_tabbar[tab_id].forEachTab(function(tab) {
                        if(tab.getText() == get_locale_value('General')){
                            form = tab.getAttachedObject();

                            [
                                'source_system_book_id1',
                                'source_system_book_id2',
                                'source_system_book_id3', 
                                'source_system_book_id4'
                            ].forEach(function(field) {
                                form.disableItem(field)
                            });
                        }
                    });
                }

                form_obj.disableItem('fas_deal_sub_type_value_id');
                if (j == 0) {
                    if (node_id_array[0] == 'c') {
                        setup_book_structure.inner_tab_layout_form["form_" + j + '_' + active_tab_id].setItemValue('fas_book_id', node_id_array[1]);
                    }
                    else if(node_id_array[0] == 'd') {
                        var fas_deal_type_value_id = form_obj.getCombo('fas_deal_type_value_id');
                        if (fas_deal_type_value_id != null) {
                            form_obj.attachEvent('onChange', function(name) {
                                if (name == 'fas_deal_type_value_id') {
                                    var combo_option = fas_deal_type_value_id.getSelectedValue();
                                    if (combo_option.trim() == 401) {
                                        form_obj.enableItem('fas_deal_sub_type_value_id');
                                    } else {
                                        form_obj.setItemValue('fas_deal_sub_type_value_id','');
                                        form_obj.disableItem('fas_deal_sub_type_value_id');
                                    }
                                }
                            })
                        }
                    }
                }
            }
            /*************************************/
            if (j == 3 && SHOW_SUBBOOK_IN_BS == 0) {//} && SHOW_SUBBOOK_IN_BS == 0 && node_id_array[0] == 'd') {
                if (result[j][4]) {
                    //attach grid menu
                    var menu_json = [
                        {id:"refresh", img:"refresh.gif", imgdis:'refresh_dis.gif', text:"Refresh", title:"Refresh", enabled: true},
                        {id:"edit", img:"edit.gif", imgdis:'edit_dis.gif', text:"Edit", items:[
                                {id:"add", img:"add.gif", imgdis:'add_dis.gif', text:"Add", title:"Add", enabled: true},
                                {id:"delete", img:"delete.gif", imgdis:'delete_dis.gif', text:"Delete", title:"Delete", disabled:true}
                            ]},
                        {id:"export", img:"export.gif", imgdis:'export_dis.gif', text:"Export", items:[
                                {id:"excel", img:"excel.gif", imgdis:'excel_dis.gif', text:"Excel", title:"Excel"},
                                {id:"pdf", img:"pdf.gif", imgdis:'pdf_dis.gif', text:"PDF", title:"PDF"}
                            ]},
                        {id:"process", img:"process.gif", imgdis:'process_dis.gif', text:"Process", items:[
                                {id:"transfer", img:"transfer.gif", imgdis:'transfer_dis.gif', text:"Transfer", title:"Transfer", disabled:true},
                            ]}];
                    var menu_obj = setup_book_structure.inner_tab_layout_tabbar[active_object_id].tabs(tab_id).attachMenu();
                    menu_obj.setIconsPath(js_image_path + "dhxmenu_web/");
                    menu_obj.loadStruct(menu_json);
                    // --- End of Menu

                    setup_book_structure.inner_tab_layout_form["grid_" + j + '_' + active_tab_id] = setup_book_structure.inner_tab_layout_tabbar[active_object_id].tabs(tab_id).attachGrid();
                    setup_book_structure.inner_tab_layout_form["grid_" + j + '_' + active_tab_id].setImagePath(js_image_path + "dhxgrid_web/");
                    setup_book_structure.inner_tab_layout_form["grid_" + j + '_' + active_tab_id].setColumnIds("fas_book_id,logical_name,tag1,tag2,tag3,tag4,transaction_type,transaction_sub_type,effective_date,end_date,percentage_included,group1,group2,group3,group4,created_ts,created_by,updated_ts,updated_by");
                    setup_book_structure.inner_tab_layout_form["grid_" + j + '_' + active_tab_id].setHeader(get_locale_value("FAS Book ID,Logical Name,"+ tag_name1 +","+ tag_name2 +","+ tag_name3 +"," + tag_name4 + ",Transaction Type,Transaction Sub Type,Effective Date,End Date,Percentage Included,Group 1,Group 2,Group 3,Group 4,Created TS,Created By,Updated TS,Updated By", true));
                    setup_book_structure.inner_tab_layout_form["grid_" + j + '_' + active_tab_id].attachHeader('#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter');
                    setup_book_structure.inner_tab_layout_form["grid_" + j + '_' + active_tab_id].setColSorting('str,str,str,str,str,str,str,str,str,str,str,str,str,str,str,str,str,str,str');
                    setup_book_structure.inner_tab_layout_form["grid_" + j + '_' + active_tab_id].setColTypes("ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro");
                    setup_book_structure.inner_tab_layout_form["grid_" + j + '_' + active_tab_id].setInitWidths('80,150,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100');
                    setup_book_structure.inner_tab_layout_form["grid_" + j + '_' + active_tab_id].setColumnsVisibility("true,false,false,false,false,false,false,false,false,false,false,false,false,false,false,true,true,true,true");
                    setup_book_structure.inner_tab_layout_form["grid_" + j + '_' + active_tab_id].init();
                    setup_book_structure.inner_tab_layout_form["grid_" + j + '_' + active_tab_id].enableMultiselect(false);
                    setup_book_structure.inner_tab_layout_form["grid_" + j + '_' + active_tab_id].enableHeaderMenu();
                    setup_book_structure.inner_tab_layout_form["grid_" + j + '_' + active_tab_id].setPagingWTMode(true, true, true, true);
                    setup_book_structure.inner_tab_layout_form["grid_" + j + '_' + active_tab_id].enablePaging(true, 50, 0, 'pagingAreaGrid_b');
                    setup_book_structure.inner_tab_layout_form["grid_" + j + '_' + active_tab_id].setPagingSkin('toolbar');

                    var fas_book_id = (active_tab_id.indexOf('c_') != -1) ? active_tab_id.replace('c_', '') : active_tab_id;
                    var data =  {"sp_string": "EXEC spa_sourcesystembookmap @flag = 'm', @fas_book_id = " + fas_book_id};
                    adiha_post_data('return_array', data, '', '', 'setup_book_structure.load_source_book_mapping');

                    setup_book_structure.inner_tab_layout_form["grid_" + j + '_' + active_tab_id].attachEvent("onRowDblClicked",function(row_id){
                        setup_book_structure.sub_book_property(active_object_id, row_id);
                    });

                    setup_book_structure.inner_tab_layout_form["grid_" + j + '_' + active_tab_id].attachEvent("onRowSelect",function(){
                        menu_obj.setItemEnabled('delete');
                        menu_obj.setItemEnabled('transfer');
                    });


                    menu_obj.attachEvent("onClick", function(id) {
                        switch(id) {
                            case 'refresh':
                                setup_book_structure.refresh_source_book_mapping();
                                break;
                            case 'add':
                                if (setup_book_structure.tree_book_structure.getSelectedItemId().indexOf('b_') == 0) {
                                    show_messagebox('Please add <b>Book</b> first.');
                                    return;
                                } else {
                                    setup_book_structure.sub_book_property(active_object_id, null);
                                }
                                break;
                            case 'delete':
                                var row_id = setup_book_structure.inner_tab_layout_form["grid_" + 3 + '_' + active_tab_id].getSelectedRowId();
                                var book_deal_type_map_id = setup_book_structure.inner_tab_layout_form["grid_" + 3 + '_' + active_tab_id].cells(row_id, 0).getValue();

                                var param = {
                                    "action": '[spa_sourcesystembookmap]',
                                    "flag": 'd',
                                    "book_deal_type_map_id": book_deal_type_map_id
                                };
                                adiha_post_data('confirm', param, '', '', 'setup_book_structure.refresh_source_book_mapping');
                                break;

                            case 'transfer':
                                setup_book_structure.transfer_book();
                                break;
                            case 'pdf':
                                setup_book_structure.inner_tab_layout_form["grid_" + j + '_' + active_tab_id].toPDF(php_script_loc + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                                break;
                            case 'excel':
                                setup_book_structure.inner_tab_layout_form["grid_" + j + '_' + active_tab_id].toExcel(php_script_loc + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                                break;
                            default:
                                break;
                        }
                    });
                }
            }
            j++;
            /************************************/
        });



        var tab_id;
        var index_id;

        setup_book_structure.inner_tab_layout_tabbar[active_object_id].forEachTab(function(tab) {
            form_obj = tab.getAttachedObject();

            if (form_obj instanceof dhtmlXForm) {
                if (form_obj.isItem('gl_number_id_st_asset'))  {// to know the Tab number of  GL Code Mapping in which the objects to be disabled are in, for Strategy
                    tab_id = tab.getId();
                    index_id = setup_book_structure.inner_tab_layout_tabbar[active_object_id].tabs(tab_id).getIndex();
                    gl_number_id_st_asset_tab_no = index_id;

                }

                if (form_obj.isItem('mismatch_tenor_value_id'))  {    // to be used to disable : Rolling Hedge Forward, Rolling Per Type, Measurement Values,  OCI Rollout of Detail tab When Accounting Type 'Fair Value Hedges' is selected,
                    tab_id = tab.getId();
                    index_id = setup_book_structure.inner_tab_layout_tabbar[active_object_id].tabs(tab_id).getIndex();
                    detail_tab_number = index_id;

                }
            }

        });

        setup_book_structure.inner_tab_layout_tabbar[active_object_id].forEachTab(function(tab) {

            if (tab.getText() == get_locale_value('Source Book Mapping') && SHOW_SUBBOOK_IN_BS == 1 && node_id_array[0] == 'c') {
                tab.hide();
            }

            form_obj = tab.getAttachedObject();

            if (form_obj instanceof dhtmlXForm) {
                if (form_obj.isItem('gl_grouping_value_id'))  {    // to disable GL Code Mapping tab objects and Roll Per Type combo in update case for Strategy
                    tab_id = tab.getId();
                    index_id = setup_book_structure.inner_tab_layout_tabbar[active_object_id].tabs(tab_id).getIndex();
                    var gl_entry_grouping = setup_book_structure.inner_tab_layout_form["form_" + index_id + '_' + active_tab_id].getCombo('gl_grouping_value_id');
                    enable_combos = (gl_entry_grouping.getSelectedValue() == null) ? false : true;
                    if (!enable_combos) {
                        enable_disable_gl_code_objects(gl_number_id_st_asset_tab_no, enable_combos, active_tab_id);
                    }

                    form_obj.attachEvent('onOptionsLoaded', function(name) {
                        if (name == 'gl_grouping_value_id') {
                            var combo_option = gl_entry_grouping.getSelectedValue();
                            enable_combos = (combo_option == 350) ? true : false; //Grouped at Strategy
                            enable_disable_gl_code_objects(gl_number_id_st_asset_tab_no, enable_combos, active_tab_id);
                        }
                    })
                }

                if (form_obj.isItem('hedge_type_value_id')) {
                    tab_id = tab.getId();
                    index_id = setup_book_structure.inner_tab_layout_tabbar[active_object_id].tabs(tab_id).getIndex();
                    var accounting_type = setup_book_structure.inner_tab_layout_form["form_" + index_id + '_' + active_tab_id].getCombo('hedge_type_value_id');

                    if (accounting_type != null) {
                        form_obj.attachEvent('onOptionsLoaded', function(name) {
                            if (name == 'hedge_type_value_id') {
                                var combo_option = accounting_type.getSelectedValue();

                                on_change_accounting_type(detail_tab_number, combo_option, active_tab_id);   // to be used to disable : Rolling Hedge Forward, Rolling Per Type, Measurement Values,  OCI Rollout of Detail tab When Accounting Type 'Fair Value Hedges' is selected,
                                show_hide_gl_code_objects(gl_number_id_st_asset_tab_no, combo_option, active_tab_id);
                            }
                        });
                    }
                }

                if (form_obj.isItem('mismatch_tenor_value_id'))  {
                    tab_id = tab.getId();
                    index_id = setup_book_structure.inner_tab_layout_tabbar[active_object_id].tabs(tab_id).getIndex();

                    var rolling_hedge_forward = setup_book_structure.inner_tab_layout_form["form_" + index_id + '_' + active_tab_id].getCombo('mismatch_tenor_value_id');

                    if (rolling_hedge_forward != null) {
                        var combo_option = rolling_hedge_forward.getSelectedValue();

                        if (combo_option == 252) {//'Apply Hedge/Item Term Mismatch'
                            setup_book_structure.inner_tab_layout_form["form_" + index_id + '_' + active_tab_id].enableItem('rollout_per_type');
                        } else {
                            setup_book_structure.inner_tab_layout_form["form_" + index_id + '_' + active_tab_id].disableItem('rollout_per_type');
                        }
                    }
                }

            }

            if (node_index == 'b') {
                form_obj.attachEvent("onChange", function (name, value) {
                    for (k = 0; k < result_length; k++) {
                        if (name == 'mismatch_tenor_value_id') {
                            var rolling_hedge_forward = setup_book_structure.inner_tab_layout_form["form_" + k + '_' + active_tab_id].getCombo('mismatch_tenor_value_id');

                            if (rolling_hedge_forward != null) {
                                var combo_option = rolling_hedge_forward.getSelectedValue();

                                if (combo_option == 252) {//'Apply Hedge/Item Term Mismatch'
                                    setup_book_structure.inner_tab_layout_form["form_" + k + '_' + active_tab_id].enableItem('rollout_per_type');
                                } else {
                                    setup_book_structure.inner_tab_layout_form["form_" + k + '_' + active_tab_id].disableItem('rollout_per_type');
                                }
                            }
                        }

                        if (name == 'gl_grouping_value_id') {
                            var gl_entry_grouping = setup_book_structure.inner_tab_layout_form["form_" + k + '_' + active_tab_id].getCombo('gl_grouping_value_id');

                            if (gl_entry_grouping != null) {
                                var combo_option = gl_entry_grouping.getSelectedValue();
                                enable_combos = (combo_option == 350) ? true : false;//Grouped at Strategy
                                enable_disable_gl_code_objects(gl_number_id_st_asset_tab_no, enable_combos, active_tab_id)
                            }
                        }

                        if (name == 'hedge_type_value_id') {
                            var accounting_type = setup_book_structure.inner_tab_layout_form["form_" + k + '_' + active_tab_id].getCombo('hedge_type_value_id');

                            if (accounting_type != null) {
                                var combo_option = accounting_type.getSelectedValue();
                                on_change_accounting_type(detail_tab_number, combo_option, active_tab_id);
                                show_hide_gl_code_objects(gl_number_id_st_asset_tab_no, combo_option, active_tab_id);
                            }
                        }
                    }
                });
            }
        });

        if (node_index == 'c') {
            if (node_id_array[1] == undefined) node_id_array[1] = active_tab_id.substring(2, 10);

            if (hierarchy_level == 4 || hierarchy_level == 0) {
                var param = {
                    "action": "spa_books",
                    "flag": "g",
                    "fas_book_id": node_id_array[1],
                };
            } else {
                var param = {
                    "action": "spa_books",
                    "flag": "h",
                    "fas_book_id": node_id_array[1],
                };
            }

            param = $.param(param);

            $.ajax({
                type: "POST",
                dataType: "json",
                url: js_form_process_url,
                async: false,
                data: param,
                success: function(data) {
                    response_data = data["json"];
                    enable_combos = (response_data[0].gl_entry_grouping == 351) ? true : false;// 'Grouped at Book'
                    enable_disable_gl_code_objects(gl_number_id_st_asset_tab_no, enable_combos, active_tab_id);
                    combo_option = response_data[0].accounting_type;
                    show_hide_gl_code_objects(gl_number_id_st_asset_tab_no, combo_option, active_tab_id);
                }
            });
        }

        if (node_index == 'd') {
            if (node_id_array[1] == undefined) node_id_array[1] = active_tab_id.substring(2, 10);

            if (hierarchy_level == 5 || hierarchy_level == 0) {
                var param = {
                    "action": "spa_sourcesystembookmap",
                    "flag": "g",
                    "book_deal_type_map_id": node_id_array[1],
                };
            } else {
                var param = {
                    "action": "spa_sourcesystembookmap",
                    "flag": "j",
                    "book_deal_type_map_id": node_id_array[1],
                };
            }

            param = $.param(param);

            $.ajax({
                type: "POST",
                dataType: "json",
                url: js_form_process_url,
                async: false,
                data: param,
                success: function(data) {
                    response_data = data["json"];
                    enable_combos = (response_data[0].gl_entry_grouping == 352) ? true : false;// 'Grouped at SBM'
                    enable_disable_gl_code_objects(gl_number_id_st_asset_tab_no, enable_combos, active_tab_id);
                    combo_option = response_data[0].accounting_type;
                    show_hide_gl_code_objects(gl_number_id_st_asset_tab_no, combo_option, active_tab_id);
                }
            });
        }
    }
    /**
     *
     */
    setup_book_structure.refresh_source_book_mapping = function() {
        var is_win = dhxWins.isWindow('pop_win');

        if (is_win == true) {
            pop_win.close();
        }

        var active_tab_id = setup_book_structure.book_structure.getActiveTab();
        var fas_book_id = (active_tab_id.indexOf('c_') != -1) ? active_tab_id.replace('c_', '') : active_tab_id;

        var param = {
            "action": "spa_sourcesystembookmap",
            "flag": "m",
            "fas_book_id":fas_book_id,
            "grid_type": "g"
        };

        param = $.param(param);
        var param_url = js_data_collector_url + "&" + param;
        setup_book_structure.inner_tab_layout_form["grid_" + 3 + '_' + active_tab_id].clearAndLoad(param_url);
    }
    /**
     *
     */
    setup_book_structure.load_source_book_mapping = function(result) {
        var active_tab_id = setup_book_structure.book_structure.getActiveTab();
        var grid_obj = setup_book_structure.inner_tab_layout_form["grid_" + 3 + '_' + active_tab_id];
        grid_obj.parse(result, "jsarray");
    }
    /**
     *
     */
    setup_book_structure.sub_book_property = function(active_object_id, row_id){
        var active_tab_id = setup_book_structure.book_structure.getActiveTab();
        var fas_book_id = 'null';

        if (row_id != null) {
            fas_book_id = setup_book_structure.inner_tab_layout_form["grid_" + 3 + '_' + active_object_id].cells(row_id, 0).getValue();
        }
        active_object_id = active_object_id.split('_');

        var mode = (row_id != null) ? 'u' : 'i';

        var title_text = 'Sub Book Property';
        var param = 'sub.book.property.php?mode=' + mode +
            '&sub_book_id=' + active_object_id[1] +
            '&fas_book_id=' + fas_book_id +
            '&mode=' + mode +
            '&is_pop=true';

        if (!dhxWins) {
            dhxWins = new dhtmlXWindows();
        }

        pop_win = dhxWins.createWindow("pop_win", 100, 0, 950, 500);
        pop_win.setText(title_text);
        pop_win.attachURL(param, false, true);
        pop_win.attachEvent('onClose', function() {
            return true;
        });
    }
    /**
     *
     */
    setup_book_structure.transfer_book = function (id) {
        var sub_book_name = setup_book_structure.tree_book_structure.getSelectedItemText();
        var mode = '';
        var node_id = setup_book_structure.tree_book_structure.getSelectedItemId();
        var active_object_id = node_id.split('_');
        if(id != 1) { 
            var active_tab_id = setup_book_structure.book_structure.getActiveTab();
            
            active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
            active_object_id = active_object_id.split('_');
            mode = (active_object_id.indexOf('c_') != -1) ? 'u' : 'i';
        /*alert('active_tab_id: '+ active_tab_id+ ' '+'book_name: ' + sub_book_name + 'mode: '+ mode + 'active_object_id: '+ active_object_id);*/
        }
        var title_text = 'Sub Book Transfer Property';
        var param = 'book_property/source_book_mapping/source.book.mapping.transfer.php?mode=' + mode +
            '&sub_book_name=' + sub_book_name +
            '&book_deal_type_map_id=' + active_object_id[1] +
            '&is_pop=true';

        if (!dhxWins) {
            dhxWins = new dhtmlXWindows();
        }

        pop_win = dhxWins.createWindow("pop_win", 200, 0, 750, 500);
        pop_win.setText(title_text);
        pop_win.attachURL(param, false, true);
        pop_win.attachEvent('onClose', function() {
            return true;
        });
    }
    /**  refresh grid */
    setup_book_structure.refresh_affilation_grid = function () {
        var active_tab_id = setup_book_structure.book_structure.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        active_tab_id = active_tab_id.split('_');
        var sp_url_param = {
            "flag": "p",
            "action": "spa_program_affiliations",
            "fas_subsidiary_id":  active_tab_id[1],
            "grid_type":"g"
        };

        sp_url_param  = $.param(sp_url_param );
        var sp_url  = js_data_collector_url + "&" + sp_url_param ;
        setup_book_structure["grd_inner_obj_" + active_object_id].clearAll();
        setup_book_structure["grd_inner_obj_" + active_object_id] .loadXML(sp_url);
    }
    /**
     *
     */
    setup_book_structure.book_structure_toolbar_click_update = function(id) {
        var hierarchy_function_id = 0;

        var active_tab_id = setup_book_structure.book_structure.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        var validation_status = true;
        active_tab_id_array = active_tab_id.split('_');

        var node_id_array = [];
        node_id_array = active_tab_id.split('_');

        switch(id) {
            case "documents":
                setup_book_structure.open_document(node_id_array[1]);
                break;
            case "save":
                setup_book_structure.save_form();
                break;
            case "add":
                var newId = (new Date()).valueOf();
                setup_book_structure["grd_inner_obj_" + active_object_id].addRow(newId, ['', active_tab_id_array[1], '', '']);
                setup_book_structure["grd_inner_obj_" + active_object_id].selectRowById(newId);
                break;
            case "delete":
                var del_ids = setup_book_structure["grd_inner_obj_" + active_object_id].getSelectedRowId();
                var values_id = setup_book_structure["grd_inner_obj_" + active_object_id].cells(del_ids, '0').getValue();
                if (values_id == '') {
                    setup_book_structure["grd_inner_obj_" + active_object_id].deleteSelectedRows();
                    return;
                }
                data_for_post = {"action": "spa_program_affiliations",
                    "flag": "d",
                    "affiliation_id": values_id
                }
                result = adiha_post_data('confirm', data_for_post, '', '', 'delete_program');
                break;
            default:
                break;
        }
    }
    /**
     *
     */
    setup_book_structure.save_form = function(){
        setup_book_structure.book_structure.progressOn();
        var hierarchy_function_id = 0;

        var active_tab_id = setup_book_structure.book_structure.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        var validation_status = true;
        active_tab_id_array = active_tab_id.split('_');

        var node_id_array = [];
        node_id_array = active_tab_id.split('_');

        if(active_tab_id_array[0] == 'a') {
            hierarchy_function_id = subsidiary_function_id;
        } else if(active_tab_id_array[0] == 'b') {
            hierarchy_function_id = strategy_function_id;
        } else if(active_tab_id_array[0] == 'c') {
            hierarchy_function_id = book_function_id;
        } else if(active_tab_id_array[0] == 'd') {
            hierarchy_function_id = book_mapping_function_id;
        }

        var grid_xml = '';
        var inner_tab_obj = setup_book_structure["inner_tab_layout_" + active_tab_id].cells('a').getAttachedObject();
        var form_xml = '<Root function_id="' + hierarchy_function_id  + '"><FormXML ID="' + active_tab_id_array[1] + '"';

        inner_tab_obj.forEachTab(function(tab){
            var tab_text = tab.getText();
            if (tab_text == get_locale_value('Program Affilation')) {
                layout_obj = tab.getAttachedObject();
                inner_tab_obj = program_affilation_layout.cells('a').getAttachedObject();
                if (inner_tab_obj instanceof dhtmlXForm) {
                    data = inner_tab_obj.getFormData();
                    for (var a in data) {
                        field_label = a;
                        field_value = data[a];
                        if (!field_value)
                            field_value = '';
                        form_xml += " " + field_label + "=\" " + field_value + "\"";

                    }
                }
                grid_xml = "<GridGroup><Grid grid_id = \"program_affilation_grid\">";
                for (var row_index=0; row_index < setup_book_structure["grd_inner_obj_" + active_object_id].getRowsNum(); row_index++) {
                    grid_xml = grid_xml + "<GridRow ";
                    for(var cellIndex = 0; cellIndex < setup_book_structure["grd_inner_obj_" + active_object_id].getColumnsNum(); cellIndex++){
                        grid_xml = grid_xml + " " + setup_book_structure["grd_inner_obj_" + active_object_id].getColumnId(cellIndex) + '="' + setup_book_structure["grd_inner_obj_" + active_object_id].cells2(row_index,cellIndex).getValue() + '"';
                    }
                    grid_xml += '></GridRow>'
                }
                grid_xml += '</Grid></GridGroup>'

            } else {
                attached_obj = tab.getAttachedObject();
                if (attached_obj instanceof dhtmlXForm) {
                    var lbl = null;
                    var sdv_data = null;
                    var lbl_value = null;
                    var entity_name = attached_obj.getItemValue('entity_name');
                    data = attached_obj.getFormData();
                    var tabsCount = inner_tab_obj.getNumberOfTabs();
                    var status = validate_form(attached_obj);
                    var form_status = form_status && status;
                    var first_err_tab;
                    if (tabsCount == 1 && !status) {
                        first_err_tab = "";
                    } else if ((!first_err_tab) && !status) {
                        first_err_tab = tab;
                    }
                    if(status){
                        for (var a in data) {
                            field_label = a;
                            field_value = data[a];
                            var lbl = attached_obj.getItemLabel(a);
                            var lbl_value = attached_obj.getItemValue(a);

                            if(lbl == get_locale_value('Name')){
                                var patt = /\S/
                                var result = lbl_value.match(patt);
                                if(lbl_value!==""){
                                    if(!result){
                                        validation_status = false;
                                        attached_obj.setNote(field_label,{text:"Please enter the proper value"});
                                        setup_book_structure.book_structure.progressOff();
                                        attached_obj.attachEvent("onchange",function(field_label, lbl_value){
                                            attached_obj.setNote(field_label,{text:""});
                                        });
                                    }
                                }
                            }

                            if(field_label == 'effective_start_date'){
                                var effective_start_date_value = field_value;
                            }
                            if(field_label == 'end_date'){
                                var end_date_value = field_value;
                            }

                            if (lbl== get_locale_value('Tax Percentage') || lbl == get_locale_value('Percentage Included')) {

                                if(lbl_value != ""){
                                    if(lbl_value < 0 || lbl_value > 1){
                                        validation_status = false;
                                        attached_obj.setNote(field_label,{text:"Please input the valid " + lbl.toLowerCase() + "(0-1)."});
                                        setup_book_structure.book_structure.progressOff();
                                        attached_obj.attachEvent("onchange",function(field_label, lbl_value){
                                            attached_obj.setNote(field_label,{text:""});
                                        });
                                    }
                                }
                            }

                            if (attached_obj.getItemType(a) == "calendar") {
                                field_value = attached_obj.getItemValue(a, true);
                            }
                            if (attached_obj.getItemType(a) == "browser") {
                                field_value = '';
                            }
                            if (a == 'entity_name') {
                                setup_book_structure.inner_tab_layout_form["form_" + 0 + '_' + active_tab_id].setUserData("", "entity_name", data[a]);
                            }

                            if(a =='logical_name') {
                                setup_book_structure.inner_tab_layout_form["form_" + 0 + '_' + active_tab_id].setUserData("", "logical_name", data[a]);
                            }
                            if (field_value && (attached_obj.getItemType(a) != "calendar")) {
                                field_value = data[a];
                            }
                            form_xml += " " + field_label + "=\" " + field_value + "\"";
                            /*if (!field_value)
                                field_value = '';
                                form_xml += " " + field_label + "=\"" + field_value + "\"";*/
                        }
                    } else {
                        setup_book_structure.book_structure.progressOff();
                        validation_status = false;
                    }

                    if((effective_start_date_value !== null) && (end_date_value !== null) && (effective_start_date_value > end_date_value)){
                        validation_status = false;
                        show_messagebox('<b>End Date </b>should be greater than <b>Effective Date.</b>');
                    }
                }
            }
        });

        form_xml += "></FormXML></Root>";

        if (validation_status == true) {
            inner_tab_toolbar.disableItem('save');
            if (active_tab_id_array[0] == 'd' ) {
                data = {"action": "spa_sub_book_xml", "xml": form_xml, "flag":"u", 'function_id': book_mapping_function_id};
                result = adiha_post_data("alert", data, "", "", "refresh_bookstructure");
            } else if (active_tab_id_array[0] == 'b') {
                data = {"action": "spa_BookStrategyXml","flag": 'u', "xml": form_xml};
                result = adiha_post_data("alert", data, "", "", "refresh_bookstructure");
            } else if (active_tab_id_array[0] == 'c') {
                data = {"action": "spa_UpdateBookOptionXml","flag": 'u', "xml": form_xml};
                result = adiha_post_data("alert", data, "", "", "refresh_bookstructure");
            } else if (active_tab_id_array[0] == 'a') {
                data = {"action": "spa_BookSubsidiaryXml","flag": 'u', "xml": form_xml};
                result = adiha_post_data("alert", data, "", "", "refresh_bookstructure");
            } else if (active_tab_id_array[0] == 'x') {
                data = {"action": "spa_BookSubsidiaryXml","flag": 'u', "xml": form_xml};
                result = adiha_post_data("alert", data, "", "", "refresh_bookstructure");
            }
        }
    }

    setup_book_structure.open_document = function(object_id) {
        var active_tab_id = setup_book_structure.book_structure.getActiveTab();
        var tab_text = setup_book_structure.book_structure.tabs(active_tab_id).getText();

        if (tab_text.indexOf('Sub - ') == 0) {
            category_id = '<?php echo $category_data[0]['value_id'];?>';
        } else if (tab_text.indexOf('Stra - ') == 0) {
            category_id = '<?php echo $category_data[1]['value_id'];?>';
        } else if (tab_text.indexOf('Book - ') == 0) {
            category_id = '<?php echo $category_data[2]['value_id'];?>';
        }

        param = '../../_setup/manage_documents/manage.documents.php?notes_category=' + category_id + '&notes_object_id=' + object_id + '&is_pop=true&call_from=bookstructrue';
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
            update_document_counter(object_id, toolbar_object);
            return true;
        });
    }

    function delete_program(result) {
        var active_tab_id = setup_book_structure.book_structure.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        setup_book_structure["grd_inner_obj_" + active_object_id].deleteSelectedRows();
    }

    setup_book_structure.grid_toolbar_click = function(id) {
        var node_id = setup_book_structure.tree_book_structure.getSelectedItemId();

        var hierarchy_level = setup_book_structure.tree_book_structure.getLevel(setup_book_structure.tree_book_structure.getSelectedItemId());//valid

        if (hierarchy_level == 4 && id == 'add' && SHOW_SUBBOOK_IN_BS == 0) {
            show_messagebox('No <b>Sub Book</b> can be added from here.');
            return false;
        }
        node_id = (node_id == '') ? 'x_1' : node_id;
        var node_id_array = [];
        node_id_array = node_id.split('_');
        var current_node_id = node_id_array[hierarchy_level - 1];

        var newId = '';
        var new_label = '';


        if (hierarchy_level == 1 || hierarchy_level == '') {
            newId = 'a_' + (new Date()).valueOf();
            new_label = 'New Subsidiary';
        } else if (hierarchy_level == 2) {
            newId = 'b_' + (new Date()).valueOf();
            new_label = 'New Strategy';
        } else if (hierarchy_level == 3) {
            newId = 'c_' + (new Date()).valueOf();
            new_label = 'New Book';
        } else if (hierarchy_level == 4) {
            newId = 'd_' + (new Date()).valueOf();
            new_label = 'New Sub Book'
        }

        book_parent[newId] = node_id_array[1];
        if (id == 'add') {
            node_id_array[1] = '';
        }
        switch(id) {
            case "delete":
                if (hierarchy_level == '') {
                    show_messagebox('Please select an option from tree to delete hierarchy.');
                } else {
                    var node_id = setup_book_structure.tree_book_structure.getSelectedItemId();//valid
                    node_id_delete = node_id;
                    var node_id_array = [];
                    var subsidiary_id = '';
                    var strategy_id = [];
                    var book_id = [];
                    var sub_book_id = [];

                    node_id_array = node_id.split('_');
                    if (node_id_array[1] == 'new') {
                            setup_book_structure.tree_book_structure.deleteItem(node_id)
                    } else {
                        ids = setup_book_structure.tree_book_structure.getAllSubItems(node_id);
                        ids = ids.split(",");
                        ids.push(node_id);
                        ids.forEach(function(id) {
                            var level = setup_book_structure.tree_book_structure.getLevel(id);
                            node_id_array = id.split('_');
                            if (node_id_array[1] != 'new') {
                                if (node_id_array[0] == 'a') {
                                    subsidiary_id = node_id_array[1];
                                } else if (node_id_array[0] == 'b') {
                                    strategy_id.push(node_id_array[1]);
                                } else if (node_id_array[0] == 'c') {
                                    book_id.push(node_id_array[1]);
                                } else {
                                    sub_book_id.push(node_id_array[1]);
                                }
                            }
                        });
                        var param = {
                                    "flag": 'd',
                                    "action": '[spa_setup_simple_book_structure]',
                                    "fas_subsidiary_id" : subsidiary_id,
                                    "fas_strategy_id" : strategy_id.toString(),
                                    "source_book_id" : book_id.toString(),
                                    "book_deal_type_map_id" : sub_book_id.toString()
                                };
                         result = adiha_post_data('confirm', param, '', '', 'setup_book_structure.refresh_del_book');
                    }


                }
                break;
            case "add":
                var level = get_hierrarchy_level(node_id);
                var img_array_open = ['subsidiary_open.gif','subsidiary_open.gif','strategy_open.gif','book_open.gif','leaf.gif'];
                var img_array_close = ['subsidiary_close.gif','subsidiary_close.gif','strategy_close.gif','book_close.gif','leaf.gif'];
                var level_name_array = ['Subsidiary','Subsidiary','Strategy','Book','Sub-Book','Sub-Book'];
                var tree_grid_obj = setup_book_structure.tree_book_structure;
                var parent_id = node_id;
                var book_structure_form_data = [
                    {type: "settings", position: "label-left", labelWidth: 150, inputWidth: 130, position: "label-top", offsetLeft: 20},
                    {type: "combo", name: "no_of_entry", label: get_locale_value("No of " + level_name_array[hierarchy_level]),"required": "true", position: "label-left", "options":[
                            {"value": "1","text": "1", "selected": "true", "state": "enable"},
                            {"value": "2","text": "2", "state": "enable"},
                            {"value": "3","text": "3", "state": "enable"},
                            {"value": "4","text": "4", "state": "enable"},
                            {"value": "5","text": "5", "state": "enable"},
                            {"value": "6","text": "6", "state": "enable"},
                            {"value": "7","text": "7", "state": "enable"},
                            {"value": "8","text": "8", "state": "enable"},
                            {"value": "9","text": "9", "state": "enable"},
                            {"value": "10","text": "10", "state": "enable"}
                        ]},
                    {type: "combo", name: "level", label: get_locale_value("Hierarchy Level"), position: "label-left", "options":[
                            {"value": "1","text": "Subsidiary", "state": "enable"},
                            {"value": "2","text": "Strategy", "state": "enable"},
                            {"value": "3","text": "Book", "state": "enable"},
                            {"value": "4","text": "Sub Book", "state": "enable","selected": "true"}
                        ]},
                    {type: "button", value: get_locale_value("Ok"), img: "tick.png"}
                ];
                var book_structure_popup = new dhtmlXPopup();
                var book_structure_form = book_structure_popup.attachForm(get_form_json_locale(book_structure_form_data));
                level_combo = book_structure_form.getCombo('level');
                if (hierarchy_level == 2) {
                    level_combo.updateOption(1,1,"Strategy");
                    level_combo.updateOption(2,2,"Book");
                    level_combo.updateOption(3,3,"Sub Book");
                    book_structure_form.setItemValue("level",3);
                    level_combo.deleteOption(4);
                } else if (hierarchy_level > 2) {
                    book_structure_form.hideItem('level');
                    level_combo.setComboValue('');
                }
                level_combo.sort("asc");
                book_structure_popup.show(5,40,350,45);
                hierarchy_level = (hierarchy_level)?hierarchy_level:1;
                book_structure_popup.attachEvent("onBeforeHide", function(type, ev, id){
                    if (type == 'click' || type == 'esc') {
                        book_structure_popup.hide();
                        return true;
                    }
                });
                book_structure_form.attachEvent("onButtonClick", function() {
                    var no_of_entry = book_structure_form.getItemValue('no_of_entry', true);
                    if (hierarchy_level == 1) {
                        hierarchy_level_sub = book_structure_form.getItemValue('level');
                        hierarchy_level_strategy = '';
                        level = (hierarchy_level_sub)?(parseInt(hierarchy_level_sub)):level;
                    } else if (hierarchy_level == 2) {
                        hierarchy_level_strategy = book_structure_form.getItemValue('level');
                        hierarchy_level_sub = '';
                        level = (hierarchy_level_strategy)?(parseInt(hierarchy_level_strategy) + 1):level;
                    }
                    if (no_of_entry < 1 || no_of_entry > 10) {
                        show_messagebox("Enter value between 1 and 10.");
                        return;
                    }

                    (function add_hierarchy_data (i) {
                        setTimeout(function () {
                            for (var j = hierarchy_level; j <= level  ; j++) {
                                if (j == 1 || j == '') {
                                    newId = 'a_new_' + (new Date()).valueOf();
                                    new_label = 'New Subsidiary';
                                    hierarchy_level_sub_array[newId] = hierarchy_level_sub;
                                } else if (j == 2) {
                                    newId = 'b_new_' + (new Date()).valueOf();
                                    new_label = 'New Strategy';
                                    hierarchy_level_strategy_array[newId] = hierarchy_level_strategy;
                                } else if (j == 3) {
                                    newId = 'c_new_' + (new Date()).valueOf();
                                    new_label = 'New Book';
                                } else if (j == 4) {
                                    newId = 'd_new_' + (new Date()).valueOf();
                                    new_label = 'New Sub Book'
                                }

                                if (j != node_level) {
                                    tree_grid_obj.insertNewChild(node_id,newId,new_label,null,img_array_open[j],img_array_open[j],img_array_close[j]);
                                } else {
                                    tree_grid_obj.insertNewItem(node_id,newId,new_label,null,img_array_open[j],img_array_open[j],img_array_close[j]);
                                }

                                tree_grid_obj.showItemCheckbox(newId, false);
                                tree_grid_obj.setItemColor(newId,"red","red");
                                node_id = newId;
                            }
                            node_id = parent_id;
                            if (--i) add_hierarchy_data(i);
                        }, 10)
                    })(no_of_entry);
                    book_structure_popup.hide();
                });

                break;

            case "save":
                var xml = '<Root function_id="' + 10101200  + '">';
                var entity_name = '';
                var entity_id = '';
                tree_grid_obj = setup_book_structure.tree_book_structure;
                tree_grid_obj.stopEdit();
                var ids = tree_grid_obj.getAllSubItems('x_1');
                ids = ids.split(",");
                ids.push('x_1');
                var id_array = [];
                var node_level1 = null;
                var parent_id_array = [];
                var xml_array = [];
                xml_array[1] = '<GridRowCom>';
                xml_array[2] = '<GridRowSubsidiary>';
                xml_array[3] = '<GridRowStrategy>';
                xml_array[4] = '<GridRowBook>';
                xml_array[5] = '<GridRowSubBook>';
                var checked_array = [];
                var child_mismatch = 0;
                var parent_sub_id = '';
                var parent_stra_id = '';
                ids.forEach(function(id) {
                    var level = tree_grid_obj.getLevel(id);
                    id_array = id.split('_');
                    if (id_array[1] == 'new' || id_array[2] == 'changed' || id == 'x_1') {
                        parent_id = tree_grid_obj.getParentId(id);
                        entity_name = tree_grid_obj.getItemText(id);
                        parent_sub_id = get_parent_subsidiary(id,level);
                        parent_stra_id = get_parent_subsidiary(id,level - 1);
                        if (id_array[1] == 'new') {
                            entity_id = '';
                        } else {
                            entity_id = id_array[1];
                        }

                        xml_array[level] +=  '<GridRow';
                        xml_array[level] += " " + "entity_name" + '="' + entity_name + '"';
                        xml_array[level] += " " + "entity_id" + '="' + entity_id + '"';
                        if (level == 2) {
                            node_level1 = (hierarchy_level_sub_array[id])?hierarchy_level_sub_array[id]:"";
                            xml_array[level] += " " + "node_level" + '="' + node_level1 + '"';
                        } else if (level == 3) {
                            node_level1 = (hierarchy_level_strategy_array[id])?hierarchy_level_strategy_array[id]:"";
                            xml_array[level] += " " + "node_level" + '="' + node_level1 + '"';
                        }
                        if (id_array[0] != 'x') {
                            parent_id_array = parent_id.split('_');
                            if (id_array[1] == 'new' && parent_id_array[1] == 'new') {
                                parent_id = tree_grid_obj.getItemText(parent_id);
                            } else {
                                parent_id = parent_id_array[1];
                            }
                            xml_array[level] += " " + "parent_id" + '="' + parent_id + '"';
                            if (level == 4 || level == 5) {
                                xml_array[level] +=  " " + "parent_stra_id" + '="' + parent_stra_id + '"' + " " + "parent_sub_id" + '="' + parent_sub_id + '"';
                            }
                        }
                        xml_array[level] += '></GridRow> ';
                        node_level1 = get_hierrarchy_level(id);
                        if (level == 2) {
                            var sub_child_ids = tree_grid_obj.getAllSubItems(id);
                            if (sub_child_ids) {
                                sub_child_ids = sub_child_ids.split(",");
                                if ((sub_child_ids.length + 1) != node_level1) {
                                    child_mismatch = node_level1 - (sub_child_ids.length + 1);
                                } else {
                                    child_mismatch = 0;
                                }
                            }

                        }
                        node_level1 = (child_mismatch !== 0)?child_mismatch:node_level1;
                        /* Automatically add children for hidden levels*/
                        if (node_level1 != 4 && id_array[1] == 'new' && level == node_level1 + 1) {
                            for (var j = node_level1 + 2; j <= 5 ; j++) {
                                var parent_entitiy_id = entity_name;
                                var parent_sub_name = (tree_grid_obj.getItemText('a_' + parent_sub_id) == '0')?parent_sub_id:tree_grid_obj.getItemText('a_' + parent_sub_id);
                                var parent_stra_name = (tree_grid_obj.getItemText('b_' + parent_stra_id) == '0')?parent_stra_id:tree_grid_obj.getItemText('b_' + parent_stra_id);
                                if (j == 5) {
                                    entity_name = parent_sub_name + '_' + parent_stra_name + '_' + entity_name;
                                }
                                xml_array[j] +=  '<GridRow';
                                xml_array[j] += " " + "entity_name" + '="' + entity_name + '"';
                                xml_array[j] += " " + "entity_id" + '="' + '' + '"';
                                xml_array[j] += " " + "parent_id" + '="' + parent_entitiy_id + '"';
                                if (j == 4 || j == 5) {
                                    parent_stra_id = (parent_stra_id == undefined || parent_stra_id == '')?entity_name:parent_stra_id;
                                    xml_array[j] +=  " " + "parent_stra_id" + '="' + parent_stra_id + '"' + " " + "parent_sub_id" + '="' + parent_sub_id + '"';
                                }
                                xml_array[j] += '></GridRow> ';
                            }
                        }

                        /* END */
                        /* Rename child with name of parent when child nodes are hidden*/
                        if (tree_grid_obj.hasChildren(id) && id != 'x_1' && level != 5 && $.inArray(id, checked_array) == -1) { // no need to check for company and sub_book
                            var hidden_child = tree_grid_obj.getAllSubItems(id);
                            var hidden_child_array = hidden_child.split(',');
                            checked_array = checked_array.concat(hidden_child_array);
                            for (j = 0; j <  hidden_child_array.length ; j++) {
                                if (tree_grid_obj.getUserData(hidden_child_array[j],'ishidden') == 1) {
                                    var parent_id = tree_grid_obj.getParentId(hidden_child_array[j]);
                                    var hidden_id_array = hidden_child_array[j].split('_');
                                    var entity_name = tree_grid_obj.getItemText(parent_id);
                                    var hidden_level = tree_grid_obj.getLevel(hidden_child_array[j]);
                                    var parent_id_array = parent_id.split('_');
                                    var parent_sub_id = get_parent_subsidiary(hidden_child_array[j],hidden_level);
                                    var parent_stra_id = get_parent_subsidiary(hidden_child_array[j],hidden_level - 1);
                                    tree_grid_obj.setItemText(hidden_child_array[j], entity_name);
                                    xml_array[hidden_level] +=  '<GridRow';
                                    xml_array[hidden_level] += " " + "entity_name" + '="' + entity_name + '"';
                                    xml_array[hidden_level] += " " + "entity_id" + '="' + hidden_id_array[1] + '"';
                                    xml_array[hidden_level] += " " + "parent_id" + '="' + parent_id_array[1] + '"';
                                    if (hidden_level == 4 || hidden_level == 5) {
                                        xml_array[hidden_level] +=  " " + "parent_stra_id" + '="' + parent_stra_id + '"' + " " + "parent_sub_id" + '="' + parent_sub_id + '"';
                                    }
                                    xml_array[hidden_level] += '></GridRow> ';
                                }
                            }
                        }
                        /* End */

                    }
                });
                xml_array[1] += '</GridRowCom>';
                xml_array[2] += '</GridRowSubsidiary>';
                xml_array[3] += '</GridRowStrategy>';
                xml_array[4] += '</GridRowBook>';
                xml_array[5] += '</GridRowSubBook>';
                xml += xml_array.join(' ') + '</Root>';

                setup_book_structure.book_structure.forEachTab(function(tab){
                    var id = tab.getId();
                    delete setup_book_structure.pages[id];
                    setup_book_structure.book_structure.tabs(id).close(true);
                });
                // console.log(xml);
                // return;
                var data = {"action": "spa_setup_simple_book_structure", "flag":'i', "xml":xml};
                adiha_post_data("return_array", data, "", "", "setup_book_structure.tree_save_callback", "");
                break;
            case "change":
                var book_structure_level_form_data = [
                    {type: "settings", position: "label-left", labelWidth: 150, inputWidth: 130, position: "label-top", offsetLeft: 20},
                    // {type: "input", name: "level", label: "Hierarchy Level", position: "label-left"},
                    {type: "combo", name: "level", label: get_locale_value("Hierarchy Level"), position: "label-left","required": "true", "options":[
                            {"value": "1","text": "Subsidiary", "state": "enable"},
                            {"value": "2","text": "Strategy", "state": "enable"},
                            {"value": "3","text": "Book", "state": "enable"},
                            {"value": "4","text": "Sub Book", "state": "enable","selected": "true"}
                        ]},
                    {type: "button", value: "Ok", img: "tick.png"}
                ];
                var book_structure_level_popup = new dhtmlXPopup();
                var book_structure_level_form = book_structure_level_popup.attachForm(get_form_json_locale(book_structure_level_form_data));
                var level_combo = book_structure_level_form.getCombo('level');
                if (node_id_array[0] == 'a' || node_id_array[0] == 'b') {
                    if (node_id_array[0] == 'b') {
                        level_combo.updateOption(1,1,"Strategy");
                        level_combo.updateOption(2,2,"Book");
                        level_combo.updateOption(3,3,"Sub Book");
                        book_structure_level_form.setItemValue("level",3);
                        level_combo.deleteOption(4);
                    }
                    book_structure_level_form.setRequired('level',false);
                }
                level_combo.sort("asc");
                book_structure_level_popup.show(5,40,200,45);
                book_structure_level_popup.attachEvent("onBeforeHide", function(type, ev, id){
                    if (type == 'click' || type == 'esc') {
                        book_structure_level_popup.hide();
                        return true;
                    }
                });
                book_structure_level_form.attachEvent("onButtonClick", function() {
                    var level = book_structure_level_form.getItemValue('level');
                    var temp_level = level;
                    if (node_id_array[0] == 'x')
                        level = parseInt(level) + 1;
                    var child_ids = setup_book_structure.tree_book_structure.getAllSubItems(node_id);
                    var child_id_array =  child_ids.split(",");
                    var child_number_array = [];
                    var child_level_info = [];
                    var child_number_book = [];
                    var sub_book_status = false;
                    if (level) {
                        for (i = 0; i < child_id_array.length; i++) {
                            var node_id_array_child = child_id_array[i].split('_');
                            var node_hierarchy_level = setup_book_structure.tree_book_structure.getLevel(child_id_array[i]);
                            child_number_array[node_hierarchy_level] =  (child_number_array[node_hierarchy_level])?(child_number_array[node_hierarchy_level] + 1):1;
                            if (node_id_array_child[0] == 'c') {
                                child_number_book[child_id_array[i]] = setup_book_structure.tree_book_structure.hasChildren(child_id_array[i]);
                            }
                        }

                        for( var key in child_number_book) {
                            if (child_number_book.hasOwnProperty(key)) {
                                if (child_number_book[key] > 1) {
                                    sub_book_status = true;
                                }
                            }
                        }

                       for (i = (hierarchy_level+ parseInt(level)); i < child_number_array.length ; i++) {
                           if (child_number_array[i] > 1 && hierarchy_level+ parseInt(level) != "5") {
                               show_messagebox("Multiple child node exists. Child nodes need to be deleted first.");
                               return;
                           } else if (hierarchy_level+ parseInt(level) == "5" && sub_book_status) {
                               show_messagebox("Multiple child node exists. Child nodes need to be deleted first.");
                               return;
                           }
                       }

                        var xml = '<Root function_id="' + 10101200  + '">';
                        var xml_array = [];
                        xml_array[1] = '<GridRowCom>';
                        xml_array[2] = '<GridRowSubsidiary>';
                        xml_array[3] = '<GridRowStrategy>';
                        xml_array[4] = '<GridRowBook>';
                        xml_array[5] = '<GridRowSubBook>';

                        parent_id = setup_book_structure.tree_book_structure.getParentId(node_id);
                        entity_name = setup_book_structure.tree_book_structure.getItemText(node_id);
                        var parent_sub_id = '';
                        var parent_stra_id = '';
                        parent_sub_id = get_parent_subsidiary(node_id,hierarchy_level);
                        for (i = 0; i < child_id_array.length; i++) {
                            node_hierarchy_level = setup_book_structure.tree_book_structure.getLevel(child_id_array[i]);
                            child_level_info[node_hierarchy_level] = child_id_array[i];
                            if (node_hierarchy_level == 3) {
                                parent_stra_id = get_parent_subsidiary(child_id_array[i],node_hierarchy_level - 1);
                            }
                        }

                        /* XML is created to add children level autaomatically in case when
                           child are not present but hirerachy is changed to lower level.
                           For e.g: When sub book is not present but hierarchy is changed to subsidiary,
                           sub book is added with name of book
                        */
                        var parent_id_text = null;
                        for (i = (hierarchy_level+ parseInt(level)); i <= 5 ; i++) {
                              if (!child_number_array[i]) {
                                  if (child_level_info[i - 1]) {
                                      id_array = child_level_info[i - 1].split('_');
                                      parent_id = id_array[1];
                                      entity_name = setup_book_structure.tree_book_structure.getItemText(child_level_info[i - 1]);
                                  } else {
                                      parent_id = (parent_id_text)?parent_id_text:node_id_array[1];
                                      entity_name = (parent_id_text)?parent_id_text:entity_name;
                                  }
                              } else {
                                  id_array = child_level_info[i].split('_');
                                  entity_id = id_array[1];
                                  entity_name = setup_book_structure.tree_book_structure.getItemText(child_level_info[i]);
                                  id_array = setup_book_structure.tree_book_structure.getParentId(child_level_info[i]).split('_');
                                  parent_id = id_array[1];
                              }
                            entity_id = (entity_id == undefined || entity_id == '')?'':entity_id;
                            xml_array[i] +=  '<GridRow';
                            xml_array[i] += " " + "entity_name" + '="' + entity_name + '"';
                            xml_array[i] += " " + "entity_id" + '="' + entity_id + '"';
                            xml_array[i] += " " + "parent_id" + '="' + parent_id + '"';
                            parent_stra_id = (parent_stra_id == undefined || parent_stra_id == '')?entity_name:parent_stra_id;
                            if (i == 4 || i == 5) {
                                xml_array[i] +=  " " + "parent_stra_id" + '="' + parent_stra_id + '"' + " " + "parent_sub_id" + '="' + parent_sub_id + '"';
                            }
                            xml_array[i] += '></GridRow> ';
                            parent_id_text = entity_name;
                        }

                        xml_array[1] += '</GridRowCom>';
                        xml_array[2] += '</GridRowSubsidiary>';
                        xml_array[3] += '</GridRowStrategy>';
                        xml_array[4] += '</GridRowBook>';
                        xml_array[5] += '</GridRowSubBook>';
                        xml += xml_array.join(' ') + '</Root>';
                        // console.log(xml);
                        // var data = {"action": "spa_setup_simple_book_structure", "flag":'i', "xml":xml};
                        // adiha_post_data("return_array", data, "", "", "", "");
                        // return;
                    }

                    level = temp_level;

                    var fas_id = (node_id_array[0] == 'x')?-1:node_id_array[1];
                    if ((level < 1 || level > 4 || isNaN(parseInt(level, 10))) && node_id_array[0] == 'x') {
                        show_messagebox("Enter value between 1 and 4.");
                    } else if ((level < 1 || level > 4 || isNaN(parseInt(level, 10))) && node_id_array[0] == 'a' && level != '') {
                        show_messagebox("Enter value between 1 and 4.");
                    } else if ((level < 1 || level > 3 || isNaN(parseInt(level, 10))) && node_id_array[0] == 'b' && level != '') {
                        show_messagebox("Enter value between 1 and 3.");
                    } else {
                        if (node_id_array[0] == 'b') {
                            var data = {"action": "spa_setup_simple_book_structure", "flag":'m', "node_level":level, "fas_strategy_id":fas_id, "xml":xml};
                        }
                        else {
                            if (node_id_array[0] == 'x')
                                level = parseInt(level) + 1;
                            data = {"action": "spa_setup_simple_book_structure", "flag":'l', "node_level":level, "fas_subsidiary_id":fas_id, "xml": xml};
                        }
                        adiha_post_data("return_array", data, "", "", "setup_book_structure.tree_save_callback");
                    }
                    book_structure_level_popup.hide();

                });
                break;

            case "transfer":
            var id = 1
                setup_book_structure.transfer_book(id);
                break;

            case "refresh":
                setup_book_structure.tree_book_structure.stopEdit();
                tree_refresh();
                break;

            case "advanced":
                setup_book_structure.setup_book_structure.cells("a").dock();
                setup_book_structure.book_structure_toolbar.hideItem("advanced");
                setup_book_structure.book_structure_toolbar.showItem("simple");
                break;

            case "simple":
                setup_book_structure.undock_cell_a();
                setup_book_structure.book_structure_toolbar.hideItem("simple");
                setup_book_structure.book_structure_toolbar.showItem("advanced");
                break;

            default:
                //Do nothing
                break;
        }
    }

    setup_book_structure.tree_save_callback = function (result) {
        if (result[0][0] == 'Success') {
            tree_refresh();
            success_call(result[0][4]);
            if (result[0][5] && result[0][5] != '' && result != null) {
                node_level = parseInt(result[0][5]);
            }
        } else if (result[0][0] == 'Error') {
            show_messagebox(result[0][4]);
        }
    }

    function refresh_bookstructure(result) {
        if (add_edit_button_state) {
            inner_tab_toolbar.enableItem('save');
        }
        var active_tab_id = setup_book_structure.book_structure.getActiveTab();
        var node_id_array = [];
        node_id_array = active_tab_id.split('_');

        var tab_name = '';
        if (setup_book_structure.inner_tab_layout_form["form_" + 0 + '_' + active_tab_id].getUserData("", "entity_name") ||
            setup_book_structure.inner_tab_layout_form["form_" + 0 + '_' + active_tab_id].getUserData("", "logical_name") ) {

            tab_name = (setup_book_structure.inner_tab_layout_form["form_" + 0 + '_' + active_tab_id].getUserData("", "entity_name") == '') ?
                setup_book_structure.inner_tab_layout_form["form_" + 0 + '_' + active_tab_id].getUserData("", "logical_name") :
                setup_book_structure.inner_tab_layout_form["form_" + 0 + '_' + active_tab_id].getUserData("", "entity_name");

            var prefix_name = '';
            if (node_id_array[0] == 'a') {
                prefix_name = 'Sub - ';
            } else if (node_id_array[0] == 'b') {
                prefix_name = 'Strategy - ';
            } else if (node_id_array[0] == 'c') {
                prefix_name = 'Book - ';
            } else if (node_id_array[0] == 'd') {
                prefix_name = 'Sub Book - ';
            }
            
            if (result[0]['errorcode'] == 'Success') {
                var tab_ids = setup_book_structure.book_structure.getAllTabs();
                
                var tab_ids_arr = $.map(tab_ids, function(value, index) {
                    return [value];
                });

                var i = 0;

                for (i = 0; i < tab_ids_arr.length; i++) {
                    var tab_text = setup_book_structure.book_structure.tabs(tab_ids_arr[i]).getText().split(' - ')[1];

                    setup_book_structure.book_structure.tabs(tab_ids_arr[i]).close(true);
                    setup_book_structure.book_structure.cells(tab_ids_arr[i]).close(false);
                    delete setup_book_structure.pages[tab_ids_arr[i]];

                    try {setup_book_structure.create_tab_custom(tab_ids_arr[i], tab_text); } catch (exp) {}
                }
            } else if (result[0][0] == 'Error') {
                show_messagebox(result[0][4]);
                return;
            }

            tree_refresh();
            var mode = typeof tab_id === 'undefined' ? 'update' : 'insert';
            
            if (mode == 'insert') {
                setup_book_structure.create_tab_custom(tab_id, tab_name);
                setup_book_structure.book_structure.tabs(active_tab_id).close(true);
            }

            setup_book_structure.book_structure.progressOff();
        }
    }

    function tree_refresh(){
        var grid_flag = (SHOW_SUBBOOK_IN_BS == 1) ? 'y' : 'x';
        var param = {
            "action": '[spa_getPortfolioHierarchy]',
            "flag": grid_flag,
            "function_id": setup_book_structure_id
        };
        adiha_post_data('return_array', param, '', '', 'refresh_bookstructure_callback');

        setup_book_structure.book_structure_toolbar.setItemDisabled("delete");
        if (add_edit_button_state == true) setup_book_structure.book_structure_toolbar.setItemEnabled("add");
    }

    function refresh_bookstructure_callback(result) {
        var active_tab_id = setup_book_structure.book_structure.getActiveTab();
        xml_string = result[0][0];
        node_level = result[0][1];
        subisidary_level_data = result[0][2];
        strategy_level_data = result[0][3];
        setup_book_structure.tree_book_structure.deleteItem('x_1');
        setup_book_structure.tree_book_structure.loadXMLString(xml_string.replace(/!colon!/g, "\'"),function () {
            hide_unwanted_node_level();
        });

        setup_book_structure.tree_book_structure.openAllItems('x_1');//Item('x_1');
        setup_book_structure.tree_book_structure.selectItem(active_tab_id);
        setup_book_structure.tree_book_structure.openItem(active_tab_id);
    }

    setup_book_structure.refresh_del_book = function(result) {
        var grid_flag = (SHOW_SUBBOOK_IN_BS == 1) ? 'y' : 'x';
        if (result[0]['errorcode'] == 'error' || result[0]['errorcode'] == 'DB Error') return;

        if (result[0]['errorcode'] == 'Success') {
            var active_tab_id = setup_book_structure.book_structure.getActiveTab();
            var param = {
                "action": '[spa_getPortfolioHierarchy]',
                "flag": grid_flag,
                "function_id": setup_book_structure_id
            };
            adiha_post_data('return_array', param, '', '', 'refresh_bookstructure_callback');
            setup_book_structure.book_structure.tabs(node_id_delete).close(true);
            //setup_book_structure.book_structure.tabs(active_tab_id).close(true);
        }
    }

    setup_book_structure.create_tab_custom = function(full_id, text) {
        if (!setup_book_structure.pages[full_id]) {
            setup_book_structure.open_book(full_id, 'i', text);
        } else {
            setup_book_structure.book_structure.cells(full_id).setActive();
        }
    }

    setup_book_structure.book_structure_toolbar_click_insert = function(id) {
        var active_tab_id = setup_book_structure.book_structure.getActiveTab();
        var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
        var validation_status = true;
        var effective_start_date_value;
        var end_date_value;
        var node_id_array = [];
        node_id_array = active_tab_id.split('_');

        switch(id) {
            case "save":
                if (node_id_array[0] == 'a') {
                    hierarchy_function_id = subsidiary_function_id;
                } else if (node_id_array[0] == 'b') {
                    hierarchy_function_id = strategy_function_id;
                } else if (node_id_array[0] == 'c') {
                    hierarchy_function_id = book_function_id;
                } else if (node_id_array[0] == 'd') {
                    hierarchy_function_id = book_mapping_function_id;
                }
                var grid_xml = '';
                var inner_tab_obj = setup_book_structure["inner_tab_layout_" + active_tab_id].cells('a').getAttachedObject();
                var form_xml = '<Root function_id="' + hierarchy_function_id  + '"><FormXML ID="' + book_parent[active_tab_id] + '"';
                var tabsCount = inner_tab_obj.getNumberOfTabs();
                var form_status = true;
                var first_err_tab;
                inner_tab_obj.forEachTab(function(tab) {
                    attached_obj = tab.getAttachedObject();
                    if (attached_obj instanceof dhtmlXForm) {

                        data = attached_obj.getFormData();
                        var status = validate_form(attached_obj);
                        form_status = form_status && status;
                        if (tabsCount == 1 && !status) {
                            first_err_tab = "";
                        } else if ((!first_err_tab) && !status) {
                            first_err_tab = tab;
                        }
                        if(status) {
                            for (var a in data) {

                                field_label = a;
                                field_value = data[a];

                                if (field_value) {
                                    field_value = data[a];
                                }

                                var lbl = attached_obj.getItemLabel(a);
                                var lbl_value = attached_obj.getItemValue(a);

                                if(lbl == get_locale_value('Name')) {
                                    var patt = /\S/
                                    var result = lbl_value.match(patt);
                                    if(lbl_value!=="") {
                                        if(!result) {
                                            validation_status = false;
                                            attached_obj.setNote(field_label,{text:"Please enter the proper value"});
                                            setup_book_structure.book_structure.progressOff();
                                            attached_obj.attachEvent("onchange",function(field_label, lbl_value){attached_obj.setNote(field_label,{text:""});
                                            });

                                        }
                                    }
                                }

                                if (field_label == 'effective_start_date') {
                                    effective_start_date_value = field_value;
                                }
                                if (field_label == 'end_date') {
                                    end_date_value = field_value;
                                }
                                if (lbl == get_locale_value('Tax Percentage') || lbl == get_locale_value('Percentage Included')) {
                                    if(lbl_value != "") {
                                        if(lbl_value < 0 || lbl_value > 1) {
                                            validation_status = false;
                                            attached_obj.setNote(field_label,{text:"Please input the valid " + lbl.toLowerCase() + "(0-1)."});
                                            setup_book_structure.book_structure.progressOff();
                                            attached_obj.attachEvent("onchange",function(field_label, lbl_value){attached_obj.setNote(field_label,{text:""});
                                            });
                                        }
                                    }
                                }

                                if (attached_obj.getItemType(a) == "calendar") {
                                    field_value = attached_obj.getItemValue(a, true);
                                }
                                if (attached_obj.getItemType(a) == "browser") {
                                    field_value = '';
                                }
                                if (a == 'entity_name') {
                                    setup_book_structure.inner_tab_layout_form["form_" + 0 + '_' + active_tab_id].setUserData("", "entity_name", data[a]);
                                }
                                if (a == 'logical_name') {
                                    setup_book_structure.inner_tab_layout_form["form_" + 0 + '_' + active_tab_id].setUserData("", "logical_name", data[a]);
                                }
                                if (!field_value)
                                    field_value = '';
                                form_xml += " " + field_label + "=\"" + field_value + "\"";
                            }
                        } else {
                            validation_status = false;
                        }

                    }


                });
                if (!form_status) {
                    generate_error_message(first_err_tab);
                }

                form_xml += "></FormXML></Root>";
                if ((effective_start_date_value !== null) && (end_date_value !== null) && (effective_start_date_value > end_date_value)) {
                    validation_status = false;
                    show_messagebox('End Date should be greater than Effective Date.');
                }
                if (validation_status == true) {
                    inner_tab_toolbar.disableItem('save');
                    if (node_id_array[0] == 'a') {
                        data = {"action": "spa_BookSubsidiaryXml","flag": 'i', "xml": form_xml};
                        result = adiha_post_data("return_array", data, "", "", "refresh_bookstructure");
                    } else if (node_id_array[0] == 'b') {
                        data = {"action": "spa_BookStrategyXml","flag": 'i', "xml": form_xml};
                        result = adiha_post_data("return_array", data, "", "", "refresh_bookstructure");
                    } else if (node_id_array[0] == 'c') {
                        data = {"action": "spa_UpdateBookOptionXml","flag": 'i', "xml": form_xml};
                        result = adiha_post_data("return_array", data, "", "", "refresh_bookstructure");
                    } else if (node_id_array[0] == 'd' ) {
                        data = {"action": "spa_sub_book_xml", "xml": form_xml, "flag": "i", 'function_id': book_mapping_function_id};
                        result = adiha_post_data("return_array", data, "", "", "refresh_bookstructure");
                    }
                } else {
                    return;
                }
                break;
            default:
                show_messagebox(id);
        }
    }
    setup_book_structure.undock_cell_a = function() {
        setup_book_structure.setup_book_structure.cells("a").undock(300, 300, 900, 700);
        setup_book_structure.setup_book_structure.dhxWins.window("a").button("park").hide();
        setup_book_structure.setup_book_structure.dhxWins.window("a").maximize();
        setup_book_structure.setup_book_structure.dhxWins.window("a").centerOnScreen();
    }
    setup_book_structure.on_dock_event = function(name) {
        $(".undock_cell_a").show();
    }

    setup_book_structure.on_undock_event = function(name) {
        $(".undock_cell_a").hide();
    }

    hide_unwanted_node_level = function() {
        var level_to_show = node_level - 1;
        if (typeof subisidary_level_data === 'string') {
            var subsidiary_hierarchy_json = JSON.parse(subisidary_level_data);
        } else {
            subsidiary_hierarchy_json = subisidary_level_data;
        }

        if (typeof strategy_level_data === 'string') {
            var strategy_hierarchy_json = JSON.parse(strategy_level_data);
        } else {
            strategy_hierarchy_json = strategy_level_data;
        }

        var strategy_ids = [];
        for (i = 0; i < strategy_hierarchy_json.length; i++){
            strategy_ids.push(strategy_hierarchy_json[i].strategy_id);
            var strategy_child = setup_book_structure.tree_book_structure.getAllSubItems(strategy_hierarchy_json[i].strategy_id);
            var strategy_child_arr = strategy_child.split(",");
            strategy_hierarchy_json[i].child = strategy_child_arr;
            strategy_ids = strategy_ids.concat(strategy_child_arr);
        }

        var subsidiary_ids = [];
        for (var i = 0; i < subsidiary_hierarchy_json.length; i++){
            subsidiary_ids.push(subsidiary_hierarchy_json[i].subsidiary_id);
            var subsidiary_child = setup_book_structure.tree_book_structure.getAllSubItems(subsidiary_hierarchy_json[i].subsidiary_id);
            var subsidiary_child_arr = subsidiary_child.split(",");
            subsidiary_child_arr = subsidiary_child_arr.filter(function(obj) { return strategy_ids.indexOf(obj) == -1; });
            subsidiary_hierarchy_json[i].child = subsidiary_child_arr;
            subsidiary_ids = subsidiary_ids.concat(subsidiary_child_arr);
        }

        var first_child = setup_book_structure.tree_book_structure.getAllSubItems(0);
        var first_child_arr = first_child.split(",");
        first_child_arr = first_child_arr.filter(function(obj) { return subsidiary_ids.indexOf(obj) == -1; });
        first_child_arr = first_child_arr.filter(function(obj) { return strategy_ids.indexOf(obj) == -1; });
        for (i = 0; i < first_child_arr.length; i++) {
            var f_tree_level = setup_book_structure.tree_book_structure.getLevel(first_child_arr[i]);
            if (f_tree_level == level_to_show + 1) {
                var item = setup_book_structure.tree_book_structure._idpull[first_child_arr[i]];
                item.htmlNode.childNodes[0].childNodes[0].childNodes[0].style.opacity  = 0;
            }
            if (f_tree_level > level_to_show + 1) {
                item = setup_book_structure.tree_book_structure._idpull[first_child_arr[i]];
                var itemRow = item.span.parentNode.parentNode;
                itemRow.style.display = "none";
                setup_book_structure.tree_book_structure.setUserData(first_child_arr[i],'ishidden','1');
            }
        }

        for (i = 0; i < subsidiary_hierarchy_json.length; i++) {
            level_to_show = subsidiary_hierarchy_json[i].node_level;
            for (j = 0; j < subsidiary_hierarchy_json[i].child.length; j++) {
                f_tree_level = setup_book_structure.tree_book_structure.getLevel(subsidiary_hierarchy_json[i].child[j]);
                if (f_tree_level == level_to_show + 1) {
                    item = setup_book_structure.tree_book_structure._idpull[subsidiary_hierarchy_json[i].child[j]];
                    item.htmlNode.childNodes[0].childNodes[0].childNodes[0].style.opacity  = 0;
                }
                if (f_tree_level > level_to_show + 1) {
                    item = setup_book_structure.tree_book_structure._idpull[subsidiary_hierarchy_json[i].child[j]];
                    itemRow = item.span.parentNode.parentNode;
                    itemRow.style.display = "none";
                    setup_book_structure.tree_book_structure.setUserData(subsidiary_hierarchy_json[i].child[j],'ishidden','1');
                }
            }
            f_tree_level = setup_book_structure.tree_book_structure.getLevel(subsidiary_hierarchy_json[i].subsidiary_id);
            if (f_tree_level == level_to_show + 1) {
                item = setup_book_structure.tree_book_structure._idpull[subsidiary_hierarchy_json[i].subsidiary_id];
                item.htmlNode.childNodes[0].childNodes[0].childNodes[0].style.opacity  = 0;
            }
        }

        for (i = 0; i < strategy_hierarchy_json.length; i++) {
            level_to_show = 1 + strategy_hierarchy_json[i].node_level;
            for (j = 0; j < strategy_hierarchy_json[i].child.length; j++) {
                f_tree_level = setup_book_structure.tree_book_structure.getLevel(strategy_hierarchy_json[i].child[j]);
                if (f_tree_level == level_to_show + 1) {
                    item = setup_book_structure.tree_book_structure._idpull[strategy_hierarchy_json[i].child[j]];
                    item.htmlNode.childNodes[0].childNodes[0].childNodes[0].style.opacity  = 0;
                }
                if (f_tree_level > level_to_show + 1) {
                    item = setup_book_structure.tree_book_structure._idpull[strategy_hierarchy_json[i].child[j]];
                    itemRow = item.span.parentNode.parentNode;
                    itemRow.style.display = "none";
                    setup_book_structure.tree_book_structure.setUserData(strategy_hierarchy_json[i].child[j],'ishidden','1');
                }
            }
            f_tree_level = setup_book_structure.tree_book_structure.getLevel(strategy_hierarchy_json[i].strategy_id);
            if (f_tree_level == level_to_show + 1) {
                item = setup_book_structure.tree_book_structure._idpull[strategy_hierarchy_json[i].strategy_id];
                item.htmlNode.childNodes[0].childNodes[0].childNodes[0].style.opacity  = 0;
            }
        }
    }

    function get_hierrarchy_level(node_id) {
        var level = null;
        var hierarchy_level = setup_book_structure.tree_book_structure.getLevel(node_id);
        if (typeof subisidary_level_data === 'string') {
            var subsidiary_hierarchy_json = JSON.parse(subisidary_level_data);
        } else {
            subsidiary_hierarchy_json = subisidary_level_data;
        }

        var subsidiary_ids = [];
        for (var i = 0; i < subsidiary_hierarchy_json.length; i++) {
            subsidiary_ids[subsidiary_hierarchy_json[i].subsidiary_id]= subsidiary_hierarchy_json[i].node_level;
        }

        if (typeof strategy_level_data === 'string') {
            var strategy_hierarchy_json = JSON.parse(strategy_level_data);
        } else {
            strategy_hierarchy_json = strategy_level_data;
        }

        var strategy_ids = [];
        for (var i = 0; i < strategy_hierarchy_json.length; i++) {
            strategy_ids[strategy_hierarchy_json[i].strategy_id]= strategy_hierarchy_json[i].node_level;
        }

        var node_parent_id = null;
        var temp_node_id = node_id;
        for (var j = hierarchy_level ; j >= 2 ; j-- ) {
            var node_id_array = temp_node_id.split('_');
            if (node_id_array[1] == 'new' && node_id_array[0] == 'b' && hierarchy_level_strategy_array[temp_node_id] != null && hierarchy_level_strategy_array[temp_node_id] !== undefined && hierarchy_level_strategy_array[temp_node_id] != '') { // For newly created, get level
                level = parseInt(hierarchy_level_strategy_array[temp_node_id])+ 1;
                break;
            } else if(node_id_array[0] == 'b' && strategy_ids[temp_node_id] && strategy_ids[temp_node_id] != null && strategy_ids[temp_node_id] !== undefined) { // For existing, get level
                level = strategy_ids[temp_node_id] + 1;
                break;
            } else if (node_id_array[1] == 'new' && node_id_array[0] == 'a' && hierarchy_level_sub_array[temp_node_id] != null && hierarchy_level_sub_array[temp_node_id] !== undefined && hierarchy_level_sub_array[temp_node_id] != '') {
                level = parseInt(hierarchy_level_sub_array[temp_node_id]);
                break;
            } else if (node_id_array[0] == 'a' && subsidiary_ids[temp_node_id] && subsidiary_ids[temp_node_id] != null && subsidiary_ids[temp_node_id] !== undefined) {
                level = subsidiary_ids[temp_node_id];
                break;
            }
            node_parent_id = setup_book_structure.tree_book_structure.getParentId(temp_node_id);
            temp_node_id = node_parent_id;
        }
        level = (level)?level:node_level - 1;
        return level;
    }

    function get_parent_subsidiary(id,level) {
        var parent_id = '';
        var parent_sub_id = '';
        var parent_stra_id = '';
        var tree_grid_obj = setup_book_structure.tree_book_structure;
        var id_array = id.split('_');
        var parent_sub_id_array = [];
        if (level == 4) {
            parent_id = tree_grid_obj.getParentId(id);
            parent_sub_id = tree_grid_obj.getParentId(parent_id);
        } else if (level == 5) {
            parent_id = tree_grid_obj.getParentId(id);
            parent_stra_id = tree_grid_obj.getParentId(parent_id);
            parent_sub_id = tree_grid_obj.getParentId(parent_stra_id);
        } else if (level == 3) {
            parent_sub_id = tree_grid_obj.getParentId(id);
        } else if (level == 2) {
            parent_sub_id = id;
        }
        parent_sub_id_array =  parent_sub_id.split('_');
        if (id_array[1] == 'new' && parent_sub_id_array[1] == 'new') {
            parent_sub_id = tree_grid_obj.getItemText(parent_sub_id);
        } else {
            parent_sub_id = parent_sub_id_array[1];
        }
        return parent_sub_id;
    }

</script>