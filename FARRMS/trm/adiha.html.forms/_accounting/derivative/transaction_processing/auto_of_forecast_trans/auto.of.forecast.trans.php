<?php
/**
* Automation of forecasted transaction screen
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
</head>
    
<body>
    <?php
    $php_script_loc = $app_php_script_loc;
    $app_user_loc = $app_user_name;
    $module_type = '';//"15500"; //Fas (module type)
    list($default_as_of_date_to, $default_as_of_date_from) = getDefaultAsOfDate($module_type);
    $rights_auto_forecast_trans = 10234300;
    $rights_run = 10234310;
    $rights_add = 10234312;
    $rights_ungroup = 10234313;
    
    list (
        $has_rights_auto_forecast_trans,
        $has_rights_run,
        $has_rights_add,
        $has_rights_ungroup
    ) = build_security_rights(
        $rights_auto_forecast_trans,
        $rights_run,
        $rights_add,
        $rights_ungroup
    );
    
    $namespace = 'auto_forecast_trans_ns';
    $layout = new AdihaLayout();
    
    $main_layout_json = '[{
                            id:             "a",
                            width:          300,
                            text:           "Portfolio Hierarchy",
                            header:         true,
                            collapse:       false,
                            fix_size:       [false,null]
                        },
                        {
                            id:             "b",
                            text:           "btn",
                            header:         false,
                            fix_size:       [false,null]
                        }]';
                        
    
    $main_layout_name = 'view_outst_layout';
    echo $layout->init_layout($main_layout_name,'', '2U',$main_layout_json, $namespace);
    
    //Attaching Book Structue cell a
    $tree_structure = new AdihaBookStructure($rights_auto_forecast_trans);
    $tree_name = 'tree_portfolio_hierarchy';
    echo $layout->attach_tree_cell($tree_name, 'a');
    echo $tree_structure->init_by_attach($tree_name, $namespace);
    echo $tree_structure->set_portfolio_option(2);
    echo $tree_structure->set_subsidiary_option(2);
    echo $tree_structure->set_strategy_option(2);
    echo $tree_structure->set_book_option(2);
    echo $tree_structure->set_subbook_option(0);//echo $tree_structure->set_subbook_option(2);
    echo $tree_structure->load_book_structure_data();
    echo $tree_structure->load_bookstructure_events();
    echo $tree_structure->expand_level(0);
    echo $tree_structure->enable_three_state_checkbox();
    echo $tree_structure->load_tree_functons();
    echo $tree_structure->attach_search_filter('auto_forecast_trans_ns.view_outst_layout', 'a'); 
    
    //Attach layout on main layout cell b
    $right_layout_cell_name = 'view_outst_layout_right';
    $right_layout_cell_json = '[{
                                    id:             "a",
                                    text:           "Apply Filters",
                                    height:         100,
                                    header:         true,
                                    collapse:       true,
                                    fix_size:       [false,null]
                                },
                                {
                                    id:             "b",
                                    text:           "Filters",
                                    height:         220,
                                    header:         true,
                                    collapse:       false,
                                    fix_size:       [false,null]
                                },
                                {
                                    id:             "c",
                                    text:           "Hedge Group Detail",                           
                                    height:         350,
                                    header:         false,
                                    collapse:       false,
                                    fix_size:       [false,null]
                                }]';
                        
    echo $layout->attach_layout_cell($right_layout_cell_name,'b', '3E', $right_layout_cell_json);
    
    $tab_json = '[{id:"a1", text: "General"},
                  {id:"a2", text: "Source Book Mapping", active: true}]';
                        
    $layout_right = new AdihaLayout();
    echo $layout_right->init_by_attach($right_layout_cell_name, $namespace);
    echo $layout_right->attach_tab_custom_layout('tab_name', 'b', $tab_json, $namespace . '.' . $right_layout_cell_name);
    
     //Attaching Filter form for grid
    $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id=". $rights_auto_forecast_trans . ", @template_name='AutomationForcastedTransaction', @group_name='General'";
    $return_value1 = readXMLURL($xml_file);
    $form_json = $return_value1[0][2];
    
    //attach filter form
    //$tab_obj = new AdihaTab();
    $form_name = 'frm_outst_forecast_trans';
     
    echo "auto_forecast_trans_ns.frm_outst_forecast_trans = auto_forecast_trans_ns.tab_name.tabs('a1').attachForm();
          auto_forecast_trans_ns.frm_outst_forecast_trans.loadStruct(" . $form_json . ");";
    
    $menu_json = '[{id:"refresh", img:"refresh.gif", imgdis:"refresh_dis.gif", text:"Refresh", title:"Refresh", enabled: true},
                   {id:"export", img:"export.gif", imgdis:"export_dis.gif", text:"Export", items:[
                        {id:"excel", img:"excel.gif", imgdis:"excel_dis.gif", text:"Excel", title:"Excel"},
                        {id:"pdf", img:"pdf.gif", imgdis:"pdf_dis.gif", text:"PDF", title:"PDF"}
                    ]}]';
    
    echo "source_book_menu = auto_forecast_trans_ns.tab_name.tabs('a2').attachMenu();
          source_book_menu.setIconsPath(js_image_path + 'dhxmenu_web/');
          source_book_menu.loadStruct(" . $menu_json . ");
          source_book_menu.attachEvent('onClick', function(id) {
              source_book_mapping(id);
        });";

    $tag_names_sp = "EXEC spa_book_tag_name @flag = 's'";
    $tag_names = readXMLURL($tag_names_sp); 
         
    //echo "auto_forecast_trans_ns.tab_name.tabs('a2').attachStatusBar({height: 10,text: '" . "<div id='pagingAreaGrid_b'></div>" . "'});";
    
    echo "auto_forecast_trans_ns.grd_source_book = auto_forecast_trans_ns.tab_name.tabs('a2').attachGrid();";
    echo "auto_forecast_trans_ns.grd_source_book.setImagePath(js_image_path + 'dhxgrid_web/');";
    echo "auto_forecast_trans_ns.grd_source_book.setColumnIds('fas_book_id,logical_name,tag1,tag2,tag3,tag4,transaction_type');";
    echo "auto_forecast_trans_ns.grd_source_book.setHeader('FAS Book ID,Logical Name,".$tag_names[0][0].",".$tag_names[0][1].",".$tag_names[0][2].",".$tag_names[0][3].",Transaction Type');";
    echo "auto_forecast_trans_ns.grd_source_book.attachHeader('#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter');";
    echo "auto_forecast_trans_ns.grd_source_book.setColSorting('str,str,str,str,str,str,str');";
    echo "auto_forecast_trans_ns.grd_source_book.setColTypes('ro,ro,ro,ro,ro,ro,ro');";
    echo "auto_forecast_trans_ns.grd_source_book.setInitWidths('100,200,130,130,130,130,200');";
    echo "auto_forecast_trans_ns.grd_source_book.setColumnsVisibility('true,false,false,false,false,false,false');";
    echo "auto_forecast_trans_ns.grd_source_book.init();";
    echo "auto_forecast_trans_ns.grd_source_book.enableMultiselect(true);";
    echo "auto_forecast_trans_ns.grd_source_book.enableHeaderMenu();";
    echo "auto_forecast_trans_ns.grd_source_book.enablePaging(true, 10, 0, 'pagingAreaGrid_b');";
    echo "auto_forecast_trans_ns.grd_source_book.setPagingWTMode(true, true, true, true);";
    echo "auto_forecast_trans_ns.grd_source_book.setPagingSkin('toolbar');";
    //echo "auto_forecast_trans_ns.grd_source_book.load();";";
    /**/

    $toolbar_obj = new AdihaToolbar();
    $toolbar_json = '[{id: "create_transaction", type: "button", img: "create_transaction.gif", enabled:"' . $has_rights_run . '", imgdis: "create_transaction_dis.gif", text: "Create Transaction", title: "Create Transaction"}]';

    $toolbar_name = 'view_outst_toolbar';
    echo $layout->attach_toolbar_cell($toolbar_name, 'b');
    echo $toolbar_obj->init_by_attach($toolbar_name, $namespace);
    echo $toolbar_obj->load_toolbar($toolbar_json);
    echo $toolbar_obj->attach_event('', 'onClick', 'onclick_toolbar_button');    
    
    //Lower tabs
    $tab_json = '[{id: "a1", text: "Outstanding Hedges", active: true},
                  {id:"a2", text: "Hedge Group Detail"}]';
    
    echo $layout_right->init_by_attach($right_layout_cell_name, $namespace);
    echo $layout_right->attach_tab_custom_layout('tab_name_hedge', 'c', $tab_json, $namespace . '.' . $right_layout_cell_name);
    echo "auto_forecast_trans_ns.tab_name_hedge.setTabsMode('bottom');";
    echo '                    
        var layout_json = [
                            {
                                id: "a",          
                                header: false,
                                collapse: false
                            },
                        ];
        auto_forecast_trans_ns.layout1 = auto_forecast_trans_ns.tab_name_hedge.tabs("a1").attachLayout({pattern: "1C", cells:layout_json});
        auto_forecast_trans_ns.layout2 = auto_forecast_trans_ns.tab_name_hedge.tabs("a2").attachLayout({pattern: "1C", cells:layout_json});
    ';

    //Attaching menus lower tabs.
    $menu_obj = new AdihaMenu();
    $menu_json_hedge = '[{id: "refresh_hedge", img: "refresh.gif", text: "Refresh", title: "Refresh"},
                    {id:"t2", text:"Export", img:"export.gif", items:[
                            {id:"excel_hedge", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel", enabled:"true"},
                            {id:"pdf_hedge", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF", enabled:"true"}]
                    },
                    {id:"t3", text:"Process", img:"process.gif", items:[
                            {id: "process_hedge", img: "create_hedging_relationship.gif", imgdis: "create_hedging_relationship_dis.gif", text: "Create Hedge Group", title: "Create Hedge Group", enabled:false}]
                        },
                    {id:"select_unselect", text:"Select/Unselect All", img:"select_unselect.gif", imgdis:"select_unselect_dis.gif", enabled: 0}]';
    
    //attach hedge menu cell at right layout
    echo "auto_forecast_trans_ns.grid_menu_outst = auto_forecast_trans_ns.layout1.attachMenu();
          auto_forecast_trans_ns.grid_menu_outst.setIconsPath(js_image_path + 'dhxmenu_web/');
          auto_forecast_trans_ns.grid_menu_outst.loadStruct(" . $menu_json_hedge . ");
          auto_forecast_trans_ns.grid_menu_outst.attachEvent('onClick', function(id) {
                onclick_menu(id);
          });";
    
    //Attach Outstanding Hedge grid
    $xml_file = "EXEC spa_adiha_grid 's','AutomationForecastTransactionOutstandingHedge'";
    $return_value = readXMLURL2($xml_file);
    $grid_json_definition_outst = json_encode($return_value);
    
    $grid_obj = new AdihaGrid();
    $grid_name = 'grd_outst_hedge';
    echo "auto_forecast_trans_ns.grd_outst_hedge = auto_forecast_trans_ns.layout1.cells('a').attachGrid();";
    
    echo $grid_obj->init_by_attach($grid_name, $namespace);
    echo $grid_obj->set_header($return_value[0]['column_label_list'],$return_value[0]['column_alignment']);
    echo $grid_obj->set_columns_ids($return_value[0]['column_name_list']);
    echo $grid_obj->set_widths($return_value[0]['column_width']);
    echo $grid_obj->split_grid(3); 
    echo $grid_obj->set_column_types($return_value[0]['column_type_list']);
    echo $grid_obj->set_sorting_preference($return_value[0]['sorting_preference']);
    echo $grid_obj->set_column_auto_size(true);
    echo $grid_obj->set_column_visibility($return_value[0]['set_visibility']);
    echo $grid_obj->set_column_alignment($return_value[0]['column_alignment']);
    echo $grid_obj->set_date_format($date_format, "%Y-%m-%d");  
    echo $grid_obj->set_search_filter(false,"#text_filter,#text_filter,#text_filter,#numeric_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#numeric_filter,#text_filter");
    echo $grid_obj->enable_multi_select();
    echo $grid_obj->return_init();
    echo $grid_obj->load_grid_functions();
    echo $grid_obj->attach_event('', 'onRowSelect', 'set_create_group_process');
    
    //Attach Hedge Group grid
    $menu_json_group = '[
        { id: "refresh_group", img: "refresh.gif", text: "Refresh", title: "Refresh"},
        {id:"t2", text:"Export", img:"export.gif", items:[
            {id:"excel_group", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel", enabled:"true"},
            {id:"pdf_group", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF", enabled:"true"}
        ]},
        {id:"t3", text:"Process", img:"process.gif", items:[
            {id: "process_group", img: "ungroup.gif", imgdis: "ungroup_dis.gif", text: "Ungroup", title: "Ungroup", enabled:false}
        ]},
        {id: "save_group", img: "save.gif", imgdis: "save_dis.gif", text: "Save", title: "Save", enabled:false},
                     {id:"expand_collapse_group", text:"Expand/Collapse", img:"exp_col.gif", imgdis:"exp_col_dis.gif", enabled: 1},
                    {id:"select_unselect_group", text:"Select/Unselect All", img:"select_unselect.gif", imgdis:"select_unselect_dis.gif", enabled: 0}
    ]';
    

    echo "auto_forecast_trans_ns.grid_menu_hedge = auto_forecast_trans_ns.layout2.attachMenu();
          auto_forecast_trans_ns.grid_menu_hedge.setIconsPath(js_image_path + 'dhxmenu_web/');
          auto_forecast_trans_ns.grid_menu_hedge.loadStruct(" . $menu_json_group . ");
          auto_forecast_trans_ns.grid_menu_hedge.attachEvent('onClick', function(id) {
                onclick_menu(id);
          });";
    
    $xml_file = "EXEC spa_adiha_grid 's','AutomationForecastTransactionHedgeGroup'";
    $resultset_hg = readXMLURL2($xml_file);
    $hg_col_array = explode(',', $resultset_hg[0]['column_width']);
    $total_hg_width = array_sum($hg_col_array);
    $grid_json_definition_hg = json_encode($resultset_hg);
    $enable_header_menu = 'false';
    
    for($i = 1; $i < count($hg_col_array); $i++) {
        $enable_header_menu .= ',' . 'true';
    }
    //Hedge Group Detail
    $xml_file = "EXEC spa_adiha_grid 's','AutomationForecastTransactionHedgeGroupDetail'";
    $resultset_hgd = readXMLURL2($xml_file);
    $hgd_col_array = explode(',', $resultset_hgd[0]['column_width']);
    $total_hgd_width = array_sum($hgd_col_array);
    $detail_header_list = 'false';
    
    for($i = 1; $i < count($hgd_col_array); $i++) {
        $detail_header_list .= ',' . 'true';
    }
    
    //Increased the total width of main grid at run time. If the total column width of sub grid exceeds main grid then few column of sub grid may be invisible.
    if ($total_hg_width<$total_hgd_width) {
        $last_key = key( array_slice($hg_col_array, -1, 1, TRUE ) );
        $hg_col_array[$last_key] = $hg_col_array[$last_key] + ($total_hgd_width - $total_hg_width);
        $resultset_hg[0]['column_width'] = implode(',',$hg_col_array);
    }
    $hedge_group_detail_grid_json = json_encode($resultset_hgd);
    
    //$grid_obj = new AdihaGrid();
    $grid_name = 'grd_outst_hedge_group';
    //echo $layout_right->attach_grid_cell($grid_name, 'd');
    echo "auto_forecast_trans_ns.grd_outst_hedge_group = auto_forecast_trans_ns.layout2.cells('a').attachGrid();";
    echo $grid_obj->init_by_attach($grid_name, $namespace);
    echo $grid_obj->set_header($resultset_hg[0]['column_label_list']);
    echo $grid_obj->set_columns_ids($resultset_hg[0]['column_name_list']);
    echo $grid_obj->set_widths($resultset_hg[0]['column_width']);
    echo $grid_obj->set_column_types($resultset_hg[0]['column_type_list']);
    echo $grid_obj->set_sorting_preference($resultset_hg[0]['sorting_preference']);
    echo $grid_obj->set_column_auto_size(true);
    echo $grid_obj->set_column_visibility($resultset_hg[0]['set_visibility']);
    //echo $grid_obj->set_search_filter('true');
    echo "auto_forecast_trans_ns.grd_outst_hedge_group.attachHeader(',#text_filter,#text_filter,#text_filter,#text_filter,#text_filter');";
    echo $grid_obj->enable_multi_select();
    echo $grid_obj->return_init('',$enable_header_menu);
    echo $grid_obj->attach_event('', 'onSubGridCreated', $namespace . '.load_hedge_group_detail');
    echo $grid_obj->attach_event('', 'onRowSelect', 'set_ungroup_process');
    echo $grid_obj->load_grid_functions();
    
    
    //This should be loaded at end
    echo $layout->close_layout();
    
    ?>
</body>
<script type="text/javascript">
    auto_forecast_trans_ns.grid_dropdowns = {};
    var function_id = '<?php echo $rights_auto_forecast_trans; ?>';
    var grid_json_definition_outst = <?php echo $grid_json_definition_outst; ?>;
    var grid_json_definition_hg = <?php echo $grid_json_definition_hg; ?>;
    var hedge_group_detail_grid_json = <?php echo $hedge_group_detail_grid_json; ?>;
    var has_rights_run = Boolean('<?php echo $has_rights_run; ?>');
    var has_rights_add = Boolean('<?php echo $has_rights_add; ?>');
    var has_rights_ungroup =  Boolean('<?php echo $has_rights_ungroup; ?>');
    var php_script_loc = '<?php echo $php_script_loc;?>';
    var SHOW_SUBBOOK_IN_BS = <?php echo $SHOW_SUBBOOK_IN_BS;?>;
    var gen_group_detail_data = {};
    var expand_state = 0;
        
    $(function() {
        //show layout cell header
        auto_forecast_trans_ns.view_outst_layout_right.cells('b').showHeader();
        auto_forecast_trans_ns.view_outst_layout_right.cells('c').showHeader();
        //auto_forecast_trans_ns.view_outst_layout_right.cells('a').setText("New Text");
        filter_obj = auto_forecast_trans_ns.view_outst_layout_right.cells('a').attachForm();
        var layout_cell_obj = auto_forecast_trans_ns.tab_name.tabs('a1');        
        load_form_filter(filter_obj, layout_cell_obj, function_id, 2, '', auto_forecast_trans_ns);   
        
        //set default values
        auto_forecast_trans_ns.frm_outst_forecast_trans.setItemValue('as_of_date_from', '<?php echo $default_as_of_date_from; ?>');
        auto_forecast_trans_ns.frm_outst_forecast_trans.setItemValue('as_of_date_to', '<?php echo $default_as_of_date_to; ?>');
        
        //populate the dropdowns fields in grids.
        if (grid_json_definition_outst[0]["dropdown_columns"] != null && grid_json_definition_outst[0]["dropdown_columns"] != '') {
            var dropdown_columns = grid_json_definition_outst[0]["dropdown_columns"].split(',');
            _.each(dropdown_columns, function(item) {
                var col_index = auto_forecast_trans_ns.grd_outst_hedge.getColIndexById(item);
                auto_forecast_trans_ns.grid_dropdowns[item] = auto_forecast_trans_ns.grd_outst_hedge.getColumnCombo(col_index);
                auto_forecast_trans_ns.grid_dropdowns[item].enableFilteringMode(true);

                var cm_param = {"action": "spa_adiha_grid", "flag": "t", "grid_name": grid_json_definition_outst[0]["grid_name"], "column_name": item, "call_from": "grid"};
                cm_param = $.param(cm_param);
                var url = js_dropdown_connector_url + '&' + cm_param;
                auto_forecast_trans_ns.grid_dropdowns[item].load(url);
            });
        }

        if (SHOW_SUBBOOK_IN_BS == 1) {
            auto_forecast_trans_ns.tab_name.tabs('a2').hide();
        }   

        auto_forecast_trans_ns.layout1.cells('a').attachStatusBar({
                                height: 30,
            text: '<div id="pagingArea_a"></div>'
                            });

        auto_forecast_trans_ns.grd_outst_hedge.setPagingWTMode(true,true,true,[10,20,30,40,50,60,70,80,90,100]);
        auto_forecast_trans_ns.grd_outst_hedge.enablePaging(true, 25, 0, 'pagingArea_a'); 
        auto_forecast_trans_ns.grd_outst_hedge.setPagingSkin('toolbar');   
    })

   
    /**
     *
     */
    function source_book_mapping (id) {
        var fas_book_id = auto_forecast_trans_ns.get_book();
        
        switch(id) {
            case 'refresh':
                if (!fas_book_id) {
                    dhtmlx.alert({type: "alert-error", title:'Alert', text:"Please select a Book."});
                    return;
                }
                var param = {"action": "spa_sourcesystembookmap","flag": "r","fas_book_id_arr":fas_book_id,"grid_type": "g"};
                param = $.param(param);
                var param_url = js_data_collector_url + "&" + param;
                auto_forecast_trans_ns.grd_source_book.clearAndLoad(param_url);
            break;
            case 'pdf':
                auto_forecast_trans_ns.grd_source_book.toPDF(php_script_loc + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
            break;
            case 'excel':
                auto_forecast_trans_ns.grd_source_book.toExcel(php_script_loc + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
            break;
            default:
                //Do nothing
            break;
        }
        
    }
    
    function set_create_group_process() {
        if (has_rights_add)
            auto_forecast_trans_ns.grid_menu_outst.setItemEnabled('process_hedge');
    }
    
    function set_ungroup_process() {
        if (has_rights_ungroup)
            auto_forecast_trans_ns.grid_menu_hedge.setItemEnabled('process_group');
    }
    
    function onclick_toolbar_button(id) {
        switch (id) {
            case "create_transaction":
                create_transaction();
                break;
        }
    }
    
    function create_transaction() {
        var col_id = auto_forecast_trans_ns.grd_outst_hedge_group.getColIndexById('gen_hedge_group_id');
        var selected_row_ids = auto_forecast_trans_ns.grd_outst_hedge_group.getSelectedRowId();
        var selected_row_array = new Array();
        var gen_hedge_group_id = new Array();

        if (selected_row_ids.indexOf(",") != -1) {
            selected_row_array = selected_row_ids.split(',');
        } else {
            selected_row_array.push(selected_row_ids);
        }

        $.each(selected_row_array, function(index, row_id){
            gen_hedge_group_id.push(auto_forecast_trans_ns.grd_outst_hedge_group.cells(row_id,col_id).getValue());
        });

        gen_hedge_group_id = gen_hedge_group_id.toString();

        var as_of_date_from = auto_forecast_trans_ns.frm_outst_forecast_trans.getItemValue('as_of_date_from', true);
        var as_of_date_to = auto_forecast_trans_ns.frm_outst_forecast_trans.getItemValue('as_of_date_to', true);
       
        if (as_of_date_from == '') {
            show_messagebox('As of Date field cannot be blank.');
            return;
        }         
        
        var param = 'call_from=create_transaction&gen_as_of_date=1&batch_type=c&as_of_date=' + as_of_date_to;
        var title = 'Run Batch Job';
        var exec_call = "EXEC spa_create_forecasted_transaction_job 'u', 1, NULL, " + singleQuote(js_user_name) + ", " + singleQuote(as_of_date_to) + ", 'n', 'g'," + singleQuote(gen_hedge_group_id) ; 
        //alert(exec_call);

        adiha_run_batch_process(exec_call, param, title);
    }
    
    function onclick_menu(id) {
        switch(id) {
            case "refresh_hedge":            
                refresh_outs_grid();
                break;
            case "excel_hedge":
                auto_forecast_trans_ns.grd_outst_hedge.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                break;
            case "excel_group":
                auto_forecast_trans_ns.grd_outst_hedge_group.toExcel(js_php_path + "components/lib/adiha_dhtmlx/grid-excel-php/generate.php");
                break;
            case "pdf_hedge":
                auto_forecast_trans_ns.grd_outst_hedge.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                break;
            case "pdf_group":
                auto_forecast_trans_ns.grd_outst_hedge_group.toPDF(js_php_path + "components/lib/adiha_dhtmlx/grid-pdf-php/generate.php");
                break;
            case "process_hedge":
                auto_forecast_trans_ns.create_hedge_group();
                break;
			case "process_group":
                auto_forecast_trans_ns.upgroup_hedge();
                break;
            
            case "refresh_group":            
                refresh_hedge_group_grids();
                break;
            
            case "save_group":

                auto_forecast_trans_ns.grid_menu_hedge.setItemDisabled('save_group')

                var sql_param = {
                    "action": "spa_genhedgegroupdetail",
                    "flag": "u",
                    "source_deal_header_id": gen_group_detail_data["source_deal_header_id"],
                    "percentage_use": gen_group_detail_data["percentage_use"],
                    "gen_hedge_group_detail_id": gen_group_detail_data["gen_hedge_group_detail_id"]
                }
                
                adiha_post_data('alert', sql_param, '', '', '');

                break;
            case "select_unselect":
                select_unselect_grid_data();
                break;
            case "select_unselect_group":
                select_unselect_group_grid_data();
                break;
            case "expand_collapse_group":
                expand_collapse_group_grid_data();
                
                break;
            default:
                dhtmlx.alert({
                    title:'Sorry! <font size="5">&#x2639 </font>',
                    type:"alert",
                    text:"Under Maintainence! We will be back soon!"
                });
                break;
        }
    }

    function expand_collapse_group_grid_data(){
            var expand_state = auto_forecast_trans_ns.grd_outst_hedge_group.getUserData("","expand_state");
                if (expand_state == 0) {
                    auto_forecast_trans_ns.grd_outst_hedge_group.getAllRowIds().split(',').forEach(function (e) {
                    auto_forecast_trans_ns.grd_outst_hedge_group.cells(e, 0).open();
                    });
                    auto_forecast_trans_ns.grd_outst_hedge_group.setUserData("","expand_state","1");
                }
                else {
                    auto_forecast_trans_ns.grd_outst_hedge_group.getAllRowIds().split(',').forEach(function (e) {
                    auto_forecast_trans_ns.grd_outst_hedge_group.cells(e, 0).close();
                    });
                    auto_forecast_trans_ns.grd_outst_hedge_group.setUserData("","expand_state","0");
                }
        }

    function select_unselect_grid_data() {        
            var total = auto_forecast_trans_ns.grd_outst_hedge.getRowsNum();
            var page_size = auto_forecast_trans_ns.grd_outst_hedge.rowsBufferOutSize;
            var page_no = Math.ceil(total / page_size);

            var selected_id = auto_forecast_trans_ns.grd_outst_hedge.getSelectedRowId();
    
            if (selected_id == null) {               
                var ids = auto_forecast_trans_ns.grd_outst_hedge.getAllRowIds();
                
                for (var id in ids) {
                   auto_forecast_trans_ns.grd_outst_hedge.selectRow(id, true, true, false);
                }
                auto_forecast_trans_ns.grd_outst_hedge.changePage(page_no);
        } else {
            auto_forecast_trans_ns.grd_outst_hedge.clearSelection();
            auto_forecast_trans_ns.grd_outst_hedge.changePage(1);
        }
           
            
    }

    function select_unselect_group_grid_data() {        
            var total = auto_forecast_trans_ns.grd_outst_hedge_group.getRowsNum();
            var page_size = auto_forecast_trans_ns.grd_outst_hedge_group.rowsBufferOutSize;
            var page_no = Math.ceil(total / page_size);

            var selected_id = auto_forecast_trans_ns.grd_outst_hedge_group.getSelectedRowId();
            
            if (selected_id == null) {               
                var ids = auto_forecast_trans_ns.grd_outst_hedge_group.getAllRowIds();
                
                for (var id in ids) {
                   auto_forecast_trans_ns.grd_outst_hedge_group.selectRow(id, true, true, false);
                }
                
                auto_forecast_trans_ns.grd_outst_hedge_group.changePage(page_no);
                var expand_state = auto_forecast_trans_ns.grd_outst_hedge_group.getUserData("","expand_state");
                if(expand_state == 1){
                    auto_forecast_trans_ns.grd_outst_hedge_group.setUserData("","expand_state","0");
                    expand_collapse_group_grid_data();
                }
                
        } else {
            auto_forecast_trans_ns.grd_outst_hedge_group.clearSelection();
            auto_forecast_trans_ns.grd_outst_hedge_group.changePage(1);
                var expand_state = auto_forecast_trans_ns.grd_outst_hedge_group.getUserData("","expand_state");
                if(expand_state == 1){
                    auto_forecast_trans_ns.grd_outst_hedge_group.setUserData("","expand_state","0");
                    expand_collapse_group_grid_data();
        }
            }
           

            
    }
    
    function refresh_outs_grid() {
        var book_ids = auto_forecast_trans_ns.get_book();
        var as_of_date_from = auto_forecast_trans_ns.frm_outst_forecast_trans.getItemValue('as_of_date_from', true);
        var as_of_date_to = auto_forecast_trans_ns.frm_outst_forecast_trans.getItemValue('as_of_date_to', true);
        var sub_book_ids = '';
        auto_forecast_trans_ns.layout1.cells('a').progressOn();

        if (SHOW_SUBBOOK_IN_BS == 0) {
            var selected_row_id = auto_forecast_trans_ns.grd_source_book.getSelectedRowId();
            if (selected_row_id) {
                if(selected_row_id.indexOf(',') == 1){
                    selected_row_id = selected_row_id.split(',');
                    
                    selected_row_id.forEach(function(item){
                        sub_book_ids += auto_forecast_trans_ns.grd_source_book.cells(item, 0).getValue() + ',';
                    });

                    sub_book_ids = sub_book_ids.substr(0, sub_book_ids.length - 1);
                } else {
                    sub_book_ids = auto_forecast_trans_ns.grd_source_book.cells(selected_row_id, 0).getValue();
                }
            }
        } else {
            if (auto_forecast_trans_ns.get_subbook()) {
                sub_book_ids = auto_forecast_trans_ns.get_subbook();
            }
        }
       
        if (book_ids == '' || as_of_date_from == '' || as_of_date_from == '' ) {
            var err_msg = '';
            if (!book_ids) {
                dhtmlx.alert({title: 'Error', type: 'alert-error',text: 'Please Select at least one Book.'});
            } else if (as_of_date_from == '' || as_of_date_from == '') {
                dhtmlx.alert({title: 'Error', type: 'alert-error',text: 'As of Date is required field.'});
            }    
        } else {
            var sql_param = {
                'action': 'spa_GetAllDealsbySourceBookId',
                'book_id': book_ids,
                'sub_book_ids': sub_book_ids,
                'as_of_date_from': as_of_date_from,
                'as_of_date_to': as_of_date_to,
                'grid_type': 'g'
            };
    
            sql_param = $.param(sql_param);
            var sql_url = js_data_collector_url + "&" + sql_param;
            auto_forecast_trans_ns.grd_outst_hedge.clearAndLoad(sql_url, on_grd_outst_hedge_load);
            auto_forecast_trans_ns.grid_menu_outst.setItemDisabled('process_hedge'); 
            auto_forecast_trans_ns.view_outst_layout_right.cells('b').collapse();
        }
         
        
    }
    
    function on_grd_outst_hedge_load() {        
        auto_forecast_trans_ns.layout1.cells('a').progressOff();
        var row_count = auto_forecast_trans_ns.grd_outst_hedge.getRowsNum();
                if (row_count > 0)
                    auto_forecast_trans_ns.grid_menu_outst.setItemEnabled('select_unselect'); 
                else
                    auto_forecast_trans_ns.grid_menu_outst.setItemDisabled('select_unselect'); 
    }

    function refresh_all_grids() {
        refresh_outs_grid();
        refresh_hedge_group_grids();
    
    }
    
    auto_forecast_trans_ns.create_hedge_group = function() {
        var link_type_value_id = 450; //sdv for Hedge Designation        
        var selected_row_ids = auto_forecast_trans_ns.grd_outst_hedge.getSelectedRowId();        
        var selected_row_array = new Array();
        var validation_msg = false;
        var err_msg = '';
        if (selected_row_ids.indexOf(",") != -1) {
            selected_row_array = selected_row_ids.split(',');
        } else {
            selected_row_array.push(selected_row_ids);
        }
        
        var hedge_rel_type_col_id = auto_forecast_trans_ns.grd_outst_hedge.getColIndexById('hedging_relationship_type');
        var eff_dt_col_id = auto_forecast_trans_ns.grd_outst_hedge.getColIndexById('effective_date');
        var perfect_hedge_col_id = auto_forecast_trans_ns.grd_outst_hedge.getColIndexById('perfect_hedge');
        var deal_col_id = auto_forecast_trans_ns.grd_outst_hedge.getColIndexById('source_deal_header_id');
        
        var grid_xml = "<GridGroup>";
        $.each(selected_row_array, function(row_index, row_id){
            hedge_rel_type = auto_forecast_trans_ns.grd_outst_hedge.cells(row_id,hedge_rel_type_col_id).getValue();
            eff_dt_col_value = auto_forecast_trans_ns.grd_outst_hedge.cells(row_id,eff_dt_col_id).getValue();
            perfect_hedge_col_value = auto_forecast_trans_ns.grd_outst_hedge.cells(row_id,perfect_hedge_col_id).getValue();
            deal_col_value = auto_forecast_trans_ns.grd_outst_hedge.cells(row_id,deal_col_id).getValue();
            
            if (hedge_rel_type == '') { 
                validation_msg = true;
                err_msg = "Please select Hedging Relationship Type in grid.";
                return;
            } else if (eff_dt_col_value == '') { 
                validation_msg = true;
                err_msg = "Please select Effective Date in grid.";
                return;
            }
            grid_xml += "<PSRecordset ";
            
            grid_xml = grid_xml + ' hedging_relationship_type="' + hedge_rel_type + '" '
                       + ' effective_date="' + eff_dt_col_value + '" '
                       + ' perfect_hedge="' + perfect_hedge_col_value + '" '
                       + ' source_deal_header_id="' + deal_col_value + '" ' ;
            
            grid_xml = grid_xml +  "></PSRecordset>";
        });
        
        grid_xml += "</GridGroup>";
        
        if (validation_msg) {
            dhtmlx.alert({
                    title:"Alert",
                    type:"alert",
                    text:err_msg
                });
                return;
        }
        
        var sql_param = {
            "action": "spa_genhedgegroup",
            "flag": "i",
            "grid_xml": grid_xml
        }
        
        adiha_post_data('return_json', sql_param, '', '', 'post_hedge_group_create')
        
    }
    
    function post_hedge_group_create(result) {
        var return_data = JSON.parse(result);
        if ((return_data[0].status).toLowerCase() == 'success') {             
            dhtmlx.message(return_data[0].message); 
            refresh_all_grids();
            auto_forecast_trans_ns.tab_name_hedge.tabs('a2').setActive();
        } else {
            dhtmlx.alert({
                   title: 'Error',
                   type: "alert-error",
                   text: return_data[0].message
                });
        }
    }
    
    //Load Hedge Group
    function refresh_hedge_group_grids() {
        var sql_param = {
            "action": "spa_genhedgegroup",
            "flag": "s",
            "grid_type": 'g'
        }
        
        sql_param = $.param(sql_param);
        var sql_url = js_data_collector_url + "&" + sql_param;
        //alert(sql_url)
        auto_forecast_trans_ns.grd_outst_hedge_group.clearAndLoad(sql_url, function(){
            var row_count = auto_forecast_trans_ns.grd_outst_hedge_group.getRowsNum();
                if (row_count > 0)
                    auto_forecast_trans_ns.grid_menu_hedge.setItemEnabled('select_unselect_group'); 
                else
                    auto_forecast_trans_ns.grid_menu_hedge.setItemDisabled('select_unselect_group'); 
        });
        //auto_forecast_trans_ns.grd_outst_hedge_group.clearAll();
        //auto_forecast_trans_ns.grd_outst_hedge_group.load(sql_url);        
        auto_forecast_trans_ns.grid_menu_hedge.setItemDisabled('process_group');
    }
    
    auto_forecast_trans_ns.load_hedge_group_detail = function(sub_grid_obj, id, ind) {
        sub_grid_obj.setImagePath(js_php_path + "components/lib/adiha_dhtmlx/adiha_grid_3.0/adiha_dhtmlxGrid/codebase/imgs/");
        sub_grid_obj.setHeader(hedge_group_detail_grid_json[0].column_label_list);
        sub_grid_obj.setColumnIds(hedge_group_detail_grid_json[0].column_name_list);
        sub_grid_obj.setColTypes(hedge_group_detail_grid_json[0].column_type_list);
        sub_grid_obj.setColumnsVisibility(hedge_group_detail_grid_json[0].set_visibility);
        sub_grid_obj.setInitWidths(hedge_group_detail_grid_json[0].column_width);
        
        sub_grid_obj.setStyle('','background-color:#F8E8B8','','background-color:#F7D97E !important');
       // console.log(sub_grid_obj)
        sub_grid_obj.init();

        sub_grid_obj.attachEvent("onEditCell", function(stage,rId,cInd,nValue,oValue){
            gen_group_detail_data = {};
            idx_gen_hedge_group_detail_id = sub_grid_obj.getColIndexById('gen_hedge_group_detail_id');
            idx_percentage_use = sub_grid_obj.getColIndexById('percentage_use');
            idx_source_deal_header_id = sub_grid_obj.getColIndexById('source_deal_header_id');
            if(cInd == idx_percentage_use) {
                gen_group_detail_data['gen_hedge_group_detail_id'] = sub_grid_obj.cells(rId, idx_gen_hedge_group_detail_id).getValue();
                gen_group_detail_data['percentage_use'] = sub_grid_obj.cells(rId, idx_percentage_use).getValue();
                gen_group_detail_data['source_deal_header_id'] = sub_grid_obj.cells(rId, idx_source_deal_header_id).getValue();
                auto_forecast_trans_ns.grid_menu_hedge.setItemEnabled('save_group');
                return true;
            }
        });

        sub_grid_obj.enableHeaderMenu('<?php echo $detail_header_list; ?>');

        var col_id = auto_forecast_trans_ns.grd_outst_hedge_group.getColIndexById('gen_hedge_group_id');
        var gen_hedge_group_id = auto_forecast_trans_ns.grd_outst_hedge_group.cells(id,col_id).getValue();
        var param = {
                "action": "spa_genhedgegroupdetail",
                "flag": "s",
                "gen_hedge_group_id": gen_hedge_group_id,
            };
        //console.dir(param);

        param = $.param(param);
        
        var param_url = js_data_collector_url + "&" + param;
        sub_grid_obj.clearAll();
        
        //after finished loading the data, fire sub grid reconstruct event so that the height of the parent grid is maintained when expanded.
        sub_grid_obj.load(param_url, function() {
            sub_grid_obj.callEvent("onGridReconstructed", []); 
        });

    }//ends onSubGridCreated event
    
    auto_forecast_trans_ns.upgroup_hedge = function() {
        var col_id = auto_forecast_trans_ns.grd_outst_hedge_group.getColIndexById('gen_hedge_group_id');
        var selected_row_ids = auto_forecast_trans_ns.grd_outst_hedge_group.getSelectedRowId();
        if (selected_row_ids != null) {
            dhtmlx.message({
                type: "confirm",
                title: "Confirmation",
                ok: "Confirm",
                text: "Please confirm to delete the selected deal group.",
                callback: function(result) {
                    if (result) {                                        
                        var selected_row_array = new Array();
                        var gen_hedge_group_id = new Array();
                        
                        if (selected_row_ids.indexOf(",") != -1) {
                            selected_row_array = selected_row_ids.split(',');
                        } else {
                            selected_row_array.push(selected_row_ids);
                        }
                        
                        $.each(selected_row_array, function(index, row_id){
                            gen_hedge_group_id.push(auto_forecast_trans_ns.grd_outst_hedge_group.cells(row_id,col_id).getValue());
                        });
                        
                        gen_hedge_group_id = gen_hedge_group_id.toString();
                        
                        var sql_param = {
                            "action": "spa_genhedgegroup",
                            "flag": "d",
                            "gen_hedge_group_id": gen_hedge_group_id
                        }
                        
                        adiha_post_data('return_json', sql_param, '', '', 'post_hedge_ungroup');
                    }
                }
            });
        }       
    }    
    
    function post_hedge_ungroup(result) {
        var return_data = JSON.parse(result);
        if ((return_data[0].status).toLowerCase() == 'success') {             
            dhtmlx.message(return_data[0].message); 
            refresh_all_grids();
            auto_forecast_trans_ns.tab_name_hedge.tabs('a1').setActive();
        } else {
            dhtmlx.alert({
                   title: 'Alert',
                   type: "alert",
                   text: return_data[0].message
                });
        }
        
    }
    
</script>
</html>