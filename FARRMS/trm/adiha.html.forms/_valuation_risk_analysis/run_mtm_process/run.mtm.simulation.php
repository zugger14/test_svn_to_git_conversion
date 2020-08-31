<?php
/**
* Run mtm simulation screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
</head>

<body>
<?php
	require('../../../adiha.php.scripts/components/include.file.v3.php');
    $form_name = 'form_run_mtm_simulation';
    $rights_run_mtm_simulation = 10184000;
    
    //JSON for Layout
    $layout_json = '[
    
                        {
                            id:             "a",
                            width:          300,
                            text:           "Portfolio Hierarchy",
                            header:         true,
                            collapse:       false,
                            fix_size:       [false,null]
                        },
                        {
                            id:             "b",
                            header:         false,
                            fix_size:       [false,null]
                        },
                        {
                            id:             "c",
                            height:         120,
                            header:         true,
                            collapse:       true,
                            text:           "Apply Filter",
                            fix_size:       [false,null]
                        },
                        {
                            id:             "d",
                            header:         true,
                            height:         110,
                            text:           "Run Criteria",                           
                            fix_size:       [false,null]
                        },
                        {
                            id:             "e",
                            header:         true,
                            text:           "<a class=\"undock-btn undock_custom\" style=\"float: right; cursor:pointer\" title=\"Undock\"  onClick=\" undock_window();\"></a>Deal"                           
                        },
                        {
                            id:             "f",
                            header:         false,                        
                        }
                    ]';    
   
    
    $name_space = 'run_mtm_simulation';
   
    //$popup = new AdihaPopup();
    $run_mtm_simulation_layout = new AdihaLayout();

    echo $run_mtm_simulation_layout->init_layout('run_mtm_simulation_layout', '', '6C', $layout_json, $name_space);
    
    //Attaching tree
    $tree_structure = new AdihaBookStructure($rights_run_mtm_simulation);
    $tree_name = 'tree_run_mtm_simulation';
    echo $run_mtm_simulation_layout->attach_tree_cell($tree_name, 'a');
    echo $tree_structure->init_by_attach($tree_name, $name_space);
    echo $tree_structure->set_portfolio_option(2);
    echo $tree_structure->set_subsidiary_option(2);
    echo $tree_structure->set_strategy_option(2);
    echo $tree_structure->set_book_option(2);
    echo $tree_structure->set_subbook_option(2);
    echo $tree_structure->load_book_structure_data();
    echo $tree_structure->load_bookstructure_events();
    echo $tree_structure->expand_level('all');
    echo $tree_structure->enable_three_state_checkbox();
    echo $tree_structure->load_tree_functons();
	echo $tree_structure->attach_search_filter('run_mtm_simulation.run_mtm_simulation_layout', 'a');

    // Default date value for date component
    $date = date('Y-m-d');
    $date_begin = date('Y-m-01');

    // Attaching Form
    $form_object = new AdihaForm();

    // Getting value for curve source dropdown
    $sp_url_curve_source = "EXEC spa_StaticDataValues 'h', 10007";
    echo "var curve_source_dropdown = ".  $form_object->adiha_form_dropdown($sp_url_curve_source, 0, 1, false, '', 2) . ";"."\n";
    
    //Dropdown value for Transaction Type
    $sp_trans_type = "EXEC spa_StaticDataValues 'h', 400";
    echo "var transaction_type_dropdown = ".  $form_object->adiha_form_dropdown($sp_trans_type, 0, 1, false, '', 2) . ";"."\n";
    
    //Dropdown value for Portfolio Type
    $sp_portfolio = "EXEC spa_maintain_portfolio_group 'a'";
    echo "var portfolio_type_dropdown = ".  $form_object->adiha_form_dropdown($sp_portfolio, 0, 1) . ";"."\n";
    
    $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10184000', @template_name='runMtmSimulation', @group_name='General'";
    $return_value1 = readXMLURL($xml_file);
    $general_form_structure = $return_value1[0][2];

    echo $run_mtm_simulation_layout->attach_form($form_name, 'd');    
    echo $form_object->init_by_attach($form_name, $name_space);
    echo $form_object->load_form($general_form_structure);
    
    // Attaching Toolbar
    $toolbar_json = '[{ id: "run", type: "button", img: "run.gif", text: "Run", title: "Run"}]';

    echo $run_mtm_simulation_layout->attach_toolbar_cell('run_mtm_simulation_toolbar', 'b');
    

    $run_mtm_simulation_toolbar = new AdihaToolbar();
    echo $run_mtm_simulation_toolbar->init_by_attach('run_mtm_simulation_toolbar', $name_space);
    echo $run_mtm_simulation_toolbar->load_toolbar($toolbar_json);
    echo $run_mtm_simulation_toolbar->attach_event('', 'onClick', 'run_mtm_simulation_onclick');
    
    // Attaching Menu 
    $toolbar_json = '[  
                        {id:"Edit", img:"edit.gif", text:"Edit", items:[
                            {id:"add", img:"new.gif", imgdis:"new_dis.gif", text:"Add"},
                            {id:"delete", img:"delete.gif", imgdis:"delete_dis.gif", text:"Delete", enabled:0}
                        ]},                               
                        {id:"t2", text:"Export", img:"export.gif", items:[
                            {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                            {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                        ]},
                        {id:"select_unselect", text:"Select/Unselect All", img:"select_unselect.gif", imgdis:"select_unselect_dis.gif", enabled: 0},
                    ]';

    $toolbar_formula_obj = new AdihaMenu();
    echo $run_mtm_simulation_layout->attach_menu_cell("toolbar_run_mtm_simulation", "e"); 
    echo $toolbar_formula_obj->init_by_attach("toolbar_run_mtm_simulation", $name_space);
    echo $toolbar_formula_obj->load_menu($toolbar_json);
    echo $toolbar_formula_obj->attach_event('', 'onClick', 'refresh_export_toolbar_click');

    $column_name = 'id,deal_id,deal_date,term_start,term_end,location_index,Template,currency,deal_type,deal_volume,deal_volume_uom_id';
    $grid_name = 'grd_mtm_simulation';
    echo $run_mtm_simulation_layout->attach_grid_cell($grid_name, 'e');
    $grid_obj = new GridTable($grid_name);
    echo $grid_obj->init_grid_table($grid_name, $name_space);
    echo $grid_obj->set_columns_ids($column_name);
    echo $grid_obj->enable_multi_select(true);
    echo $grid_obj->return_init();
    echo $grid_obj->set_column_auto_size();
    echo $grid_obj->attach_event('', 'onRowSelect', $name_space . '.row_selected') ;
    // echo $grid_obj->set_search_filter(true, "");

    //Attach grid to cell e
    // $column_name = 'id,deal_id,deal_date,term_start,term_end,location_index,Template,currency,deal_type,deal_volume,deal_volume_uom_id';
    // //$column_name = 'id,deal_date,term_start';
    // $grid_obj = new AdihaGrid();
    // // $grid_name = 'grd_mtm_simulation';
    // // echo $run_mtm_simulation_layout->attach_grid_cell($grid_name, 'e');
    // // echo $grid_obj->init_by_attach($grid_name, $name_space);
    // // echo $grid_obj->set_header('Deal ID, Reference ID, Deal Date,Term Start,Term End,Index,Template,Currency,Deal Type,Deal Volume,UOM');
    // // echo $grid_obj->set_column_types('ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro');
    // // echo $grid_obj->set_columns_ids($column_name);
    // // echo $grid_obj->enable_multi_select(true);
    // // echo $grid_obj->set_column_visibility('false,false,false,false,false,false,false,false,false,false,false');
    // // echo $grid_obj->set_column_auto_size(true);
    // // echo $grid_obj->return_init();
    // // echo $grid_obj->attach_event('', 'onRowSelect', $name_space . '.row_selected') ;
    
    // Closing Layout   
    echo $run_mtm_simulation_layout->close_layout();
?>
</body>

<script type="text/javascript">
    
    var deal_win = null;
        
	$(function() {

        run_mtm_simulation.form_run_mtm_simulation.setItemValue('as_of_date', new Date());
        run_mtm_simulation.form_run_mtm_simulation.setItemValue('curve_source', 4505); 
        
        var combo_trans_type = run_mtm_simulation.form_run_mtm_simulation.getCombo('transaction_type');
        var tt_index1 = combo_trans_type.getIndexByValue(400);  //Hedging Instrument (Der)
        var tt_index2 = combo_trans_type.getIndexByValue(401);  //Hedged Items
        combo_trans_type.setChecked(tt_index1, true);
        combo_trans_type.setChecked(tt_index2, true);

        run_mtm_simulation.run_mtm_simulation_layout.cells('f').setHeight(0);
        run_mtm_simulation.run_mtm_simulation_layout.cells('b').setHeight(40);
        run_mtm_simulation.run_mtm_simulation_layout.cells('c').collapse();
        var filter_obj = run_mtm_simulation.run_mtm_simulation_layout.cells('c').attachForm();
        var layout_cell_obj = run_mtm_simulation.run_mtm_simulation_layout.cells('d');
        var function_id =  '<?php echo $rights_run_mtm_simulation; ?>';
        load_form_filter(filter_obj, layout_cell_obj, function_id, 2, '', run_mtm_simulation); 
    });

    function refresh_export_toolbar_click(args) { 
        switch(args) {
            case 'add':
                run_mtm_simulation.select_deal();
            break;
            case 'delete':
                run_mtm_simulation.grd_mtm_simulation.deleteSelectedRows();
                var row_count = run_mtm_simulation.grd_mtm_simulation.getRowsNum();
                if(row_count == 0) {
                    run_mtm_simulation.toolbar_run_mtm_simulation.setItemDisabled('delete');
                    //run_mtm_simulation.toolbar_run_mtm_simulation.setItemDisabled('t2');
                    run_mtm_simulation.toolbar_run_mtm_simulation.setItemDisabled('select_unselect');
                }

                if(run_mtm_simulation.grd_mtm_simulation.getSelectedRowId()) {
                    run_mtm_simulation.toolbar_run_mtm_simulation.setItemEnabled('delete');   
                } else {
                    run_mtm_simulation.toolbar_run_mtm_simulation.setItemDisabled('delete');
                }
                    
            break;
            case 'select_unselect':
                var select_rows = run_mtm_simulation.grd_mtm_simulation.getSelectedRowId();
                if (select_rows == null) {
                    run_mtm_simulation.grd_mtm_simulation.selectAll();                    
                    run_mtm_simulation.toolbar_run_mtm_simulation.setItemEnabled('delete');
                } else {
                    run_mtm_simulation.grd_mtm_simulation.clearSelection();
                    run_mtm_simulation.toolbar_run_mtm_simulation.setItemDisabled('delete');
                }
            break;
            case 'excel':
                path = js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php';
                run_mtm_simulation.grd_mtm_simulation.toExcel(path);
                
                break;
            case 'pdf':
                path = js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php';
                run_mtm_simulation.grd_mtm_simulation.toPDF(path);
                
                break;  
            default:
                dhtmlx.message({
                    title:'Error',
                    type:"alert-error",
                    text:"Unhandled case occured.!"
                });
                break; 
        }
    }
    
    run_mtm_simulation.row_selected = function() { 
        run_mtm_simulation.toolbar_run_mtm_simulation.setItemEnabled('delete');
    }   
    
    run_mtm_simulation.select_deal = function() {
       // Collect deals from create and view deals page.
        var col_list = '<?php echo $column_name; ?>';        
        var view_deal_window = new dhtmlXWindows();
        var win_id = 'w1';
        //deal_win should be global variable to access from callback function 'run_mtm_simulation.callback_select_deal' to close child window ie deal window
        deal_win = view_deal_window.createWindow(win_id, 0, 0, 600, 600);
        deal_win.setModal(true);
        
        var win_title = 'Select Deal';
        var win_url = '../../_deal_capture/maintain_deals/maintain.deals.new.php';  
        /*
        read_only: Default value is false. Set this to true to opens deal page in read only mode. In this mode user are allowed to select existing deals only.
        col_list: List of columns to be listed in grid
        deal_select_completed: Callback function name
        Note: Beside these parameters if extra parameters are added then they should be properly handled in maintain.deals.php
        */      
        var params = {call_from:'Run MTM Process',read_only:true,col_list:col_list,deal_select_completed:'run_mtm_simulation.callback_select_deal'};
        
        deal_win.setText(win_title);
        deal_win.maximize();
        deal_win.attachURL(win_url, false, params);        
        
    } //end run_mtm_simulation.select_deal()
    
   
    run_mtm_simulation.callback_select_deal = function(result) {
        //close child window
        deal_win.close();
        
        //Refresh Grid 
        run_mtm_simulation.grd_mtm_simulation.clearAll();
        run_mtm_simulation.grd_mtm_simulation.parse(result, "jsarray");
        if (result.length > 0) 
            run_mtm_simulation.toolbar_run_mtm_simulation.setItemEnabled('select_unselect'); 
            
    }
    
    function run_mtm_simulation_onclick() {
        var sub_book_id = run_mtm_simulation.get_subbook() ? run_mtm_simulation.get_subbook() : 'NULL';
        var sub_id = run_mtm_simulation.get_subsidiary('browser') ? run_mtm_simulation.get_subsidiary('browser') : 'NULL';
        var strategy_id = run_mtm_simulation.get_strategy('browser') ? run_mtm_simulation.get_strategy('browser') : 'NULL';
        var book_id = run_mtm_simulation.get_book('browser') ? run_mtm_simulation.get_book('browser') : 'NULL';        
        var pnl_source = 'NULL';
        var hedge_or_item = 'b';
        var run_incremental = 'n';
        var calc_type = 'm';
        var multiple_deal_ids = run_mtm_simulation.grd_mtm_simulation.getRowsNum();  
        var form_data_arr = new Array();                
        var form_obj = run_mtm_simulation.run_mtm_simulation_layout.cells("d").getAttachedObject();
        var form_data = form_obj.getFormData();
        var check_purge = (form_obj.isItemChecked('chk_purge') == true) ? 'y' : 'n'; 

        
        for (var label in form_data) {
            if (form_obj.getItemType(label) == 'calendar') {
                value = form_obj.getItemValue(label, true);
            } else {
                value = form_data[label];
            }
            form_data_arr[label] = value;            
        }
        
        var validate_return = validate_form(form_obj);
    
    
        if (!validate_return) {
            return;
        }
        
        var deal_id = form_data_arr['deal_id'];
        var deal_ref_id = form_data_arr['deal_ref_id'] ? form_data_arr['deal_ref_id']: 'NULL';
        var port_folio_group = form_data_arr['portfolio'] ? form_data_arr['portfolio'] : 'NULL';
		var term_start  = form_data_arr['term_start'] ? form_data_arr['term_start'] : 'NULL';
		var term_end = form_data_arr['term_end'] ? form_data_arr['term_end'] : 'NULL';
		
        if(isNaN(deal_id)) {
            form_obj.setNote('deal_id', { text: "Invalid Number", width:150});
            return; 
        } else {
            form_obj.setNote('deal_id', { text: "", width:0});
        }
              
        if (form_data_arr['term_start'] > form_data_arr['term_end']) {
            show_messagebox('<b>Term End</b> should be greater than <b>Term Start</b>.');
            return;
        }          
              
        if (multiple_deal_ids > 0 && deal_id == '') {
            var col_index = run_mtm_simulation.grd_mtm_simulation.getColIndexById('id');       
            
            var deal_ids = new Array();
            run_mtm_simulation.grd_mtm_simulation.forEachRow(function(row_id){
                deal_ids.push(run_mtm_simulation.grd_mtm_simulation.cells(row_id, col_index).getValue());
            });
            
            deal_id = deal_ids.toString();
        } 
        
        if (deal_id == '' &&  deal_ref_id == 'NULL' && multiple_deal_ids == 0 && sub_id == 'NULL' && book_id == 'NULL' && port_folio_group == 'NULL') {
			show_messagebox('Please insert <b>Deal ID</b> or <b>Reference ID</b>.');
			return;
        }
        
        if (deal_id == '') {
            deal_id = null;
        }
          
        var param = 'call_from=run_mtm_simulation&gen_as_of_date=1&batch_type=c&as_of_date=' + form_data_arr['as_of_date'];
        var title = 'Run MTM Simulation Job';
        var exec_call = "EXEC spa_calc_mtm_job_wrapper " + 
                        singleQuote(sub_id) + ", " +
                        singleQuote(strategy_id) + ", " +
                        singleQuote(book_id) + ", " +
                        singleQuote(sub_book_id) + ", " +
                        singleQuote(deal_id) + ", " +
                        singleQuote(form_data_arr['as_of_date']) + ", " +
                        form_data_arr['curve_source'] + ", " +                        
                        pnl_source + ", " +
                        singleQuote(hedge_or_item) + ", " +
                        singleQuote('NULL') + ", " +
                        singleQuote('NULL') + ", " +
                        singleQuote('NULL') + ", " +
                        singleQuote('NULL') + ", " +
                        singleQuote('NULL') + ", " +
                        singleQuote('NULL') + ", " +
                        singleQuote('NULL') + ", " +
                        singleQuote('NULL') + ", " +
                        singleQuote('NULL') + ", " +
                        singleQuote('NULL') + ", " +
                        singleQuote('NULL') + ", " +
                        singleQuote('NULL') + ", " +
                        singleQuote(run_incremental) + ", " +
                        singleQuote(term_start) + ", " +
                        singleQuote(term_end) + ", " +
                        singleQuote(calc_type) + ", " +
                        singleQuote('NULL') + ", " +
                        singleQuote('NULL') + ", " +
                        singleQuote('NULL') + ", " +
                        singleQuote('NULL') + ", " +
                        singleQuote('NULL') + ", " +
                        singleQuote(deal_ref_id) + ", " +
                        singleQuote('NULL') + ", " +
                        singleQuote(form_data_arr['transaction_type']) + ", " +
                        port_folio_group + ", " +
                        singleQuote(check_purge);
					
        adiha_run_batch_process(exec_call, param, title);        
    }

    function undock_window() {
        run_mtm_simulation.run_mtm_simulation_layout.cells('e').undock(300, 300, 900, 700);
        run_mtm_simulation.run_mtm_simulation_layout.dhxWins.window('e').maximize();
        run_mtm_simulation.run_mtm_simulation_layout.dhxWins.window('e').button("park").hide();
        $('.undock-btn').hide();
    }
    /**
     *
     */
    function fx_set_combo_text(cmb_obj, ini_combo_text) {
        var checked_loc_arr = cmb_obj.getChecked();
        var final_combo_text = new Array();        
        
        $.each(checked_loc_arr, function(i) {
            var opt_obj = cmb_obj.getOption(checked_loc_arr[i]);
            
            if (opt_obj.text != '')
                final_combo_text.push(opt_obj.text);            
        });

        if (typeof(ini_combo_text) != 'undefined') {
            cmb_obj.setComboText(ini_combo_text);
        } else {
            cmb_obj.setComboText(final_combo_text.join(','));
        }
    }
</script>