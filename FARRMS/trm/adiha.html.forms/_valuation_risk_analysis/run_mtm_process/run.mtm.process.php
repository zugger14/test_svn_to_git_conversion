<?php
/**
* Run mtm process screen
* @copyright Pioneer Solutions
*/
?>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
        <?php require('../../../adiha.php.scripts/components/include.file.v3.php');?>
    </head>

    <body>
        <?php
            $form_name = 'form_run_mtm_process';
            $rights_run_mtm_process = 10181000;
    
            $layout_json = '[
                {
                    id: "a",
                    width: 300,
                    text: "Portfolio Hierarchy",
                    header: true,
                    collapse: false,
                    fix_size: [false,null]
                },
                {
                    id: "b",
                    height: 150,
                    header: false,
                    collapse: false,
                    fix_size: [false,null]
                },
                {
                    id: "c",
                    header: true,
                    text: "Deal",
                    undock: true                     
                }
            ]';
    
            $cell_json = '[
                {
                    id: "a",
                    header: false
                },
                {
                    id: "b",
                    header: false
                }
            ]';
    
            $name_space = 'run_mtm_process';
            $run_mtm_process_layout = new AdihaLayout();
            echo $run_mtm_process_layout->init_layout('run_mtm_process_layout', '', '3L', $layout_json, $name_space);
    
            $tree_name = 'tree_run_mtm_process';
            $tree_structure = new AdihaBookStructure($rights_run_mtm_process);
            echo $run_mtm_process_layout->attach_tree_cell($tree_name, 'a');
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
            echo $tree_structure->attach_search_filter('run_mtm_process.run_mtm_process_layout', 'a');

            $date = date('Y-m-d');
            $date_begin = date('Y-m-01');

            
            $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10181000', @template_name='run_mtm_process', @group_name='General'";
            $return_value1 = readXMLURL($xml_file);
            $general_form_structure = $return_value1[0][2];
            
            $form_object = new AdihaForm();
            echo $run_mtm_process_layout->attach_form($form_name, 'b');    
            echo $form_object->init_by_attach($form_name, $name_space);
            echo $form_object->load_form($general_form_structure);
    
            $toolbar_json = '[{ id: "run", type: "button", img: "run.gif", text: "Run", title: "Run"}]';

            echo $run_mtm_process_layout->attach_toolbar_cell('run_mtm_process_toolbar', 'b');
            $run_mtm_process_toolbar = new AdihaToolbar();
            echo $run_mtm_process_toolbar->init_by_attach('run_mtm_process_toolbar', $name_space);
            echo $run_mtm_process_toolbar->load_toolbar($toolbar_json);
            echo $run_mtm_process_toolbar->attach_event('', 'onClick', 'run_mtm_process_onclick');
    
            $toolbar_json = '[  
                {id: "Edit", img: "edit.gif", text: "Edit", items:[
                    {id: "add", img: "new.gif", imgdis: "new_dis.gif", title: "Add"},
                    {id: "delete", img: "delete.gif", imgdis: "delete_dis.gif", title: "Delete", enabled:0}
                ]},                               
                {id: "t2", text: "Export", img: "export.gif", items:[
                    {id: "excel", text: "Excel", img: "excel.gif", imgdis: "excel_dis.gif", title: "Excel"},
                    {id: "pdf", text: "PDF", img: "pdf.gif", imgdis: "pdf_dis.gif", title: "PDF"}
                ]},
                {id: "select_unselect", text: "Select/Unselect All", img: "select_unselect.gif", imgdis: "select_unselect_dis.gif", enabled: 0},
            ]';

            $toolbar_formula_obj = new AdihaMenu();
            echo $run_mtm_process_layout->attach_menu_cell("toolbar_run_mtm_process", "c"); 
            echo $toolbar_formula_obj->init_by_attach("toolbar_run_mtm_process", $name_space);
            echo $toolbar_formula_obj->load_menu($toolbar_json);
            echo $toolbar_formula_obj->attach_event('', 'onClick', 'refresh_export_toolbar_click');

            //Attach grid to cell c
            // $column_name = 'id,deal_id,deal_date,term_start,term_end,location_index,Template,currency,deal_type,deal_volume,deal_volume_uom_id';
            $grid_name = 'mtm_process';
            echo $run_mtm_process_layout->attach_grid_cell($grid_name, 'c');
            $grid_obj = new GridTable($grid_name);
            echo $grid_obj->init_grid_table($grid_name, $name_space);
            echo $grid_obj->enable_multi_select(true);
            echo $grid_obj->set_column_auto_size(true);
            echo $grid_obj->return_init();
            echo $grid_obj->attach_event('', 'onRowSelect', $name_space . '.row_selected') ;
            
            echo $run_mtm_process_layout->close_layout();
        ?>

        <script type="text/javascript">
            var deal_win = null;
            var function_id =  '<?php echo $rights_run_mtm_process; ?>';
            
            $(function() {
                run_mtm_process.form_run_mtm_process.setItemValue('as_of_date', new Date());
                run_mtm_process.form_run_mtm_process.setItemValue('curve_source', 4500); 
                run_mtm_process.form_run_mtm_process.setItemValue('transaction_type', 401);
                var combo_trans_type = run_mtm_process.form_run_mtm_process.getCombo('transaction_type');
                var combo_curve_source = run_mtm_process.form_run_mtm_process.getCombo('curve_source');
                var tt_index1 = combo_trans_type.getIndexByValue(400);  //Hedging Instrument (Der)
                var tt_index2 = combo_trans_type.getIndexByValue(401);  //Hedged Items
                combo_trans_type.setChecked(tt_index1, true);
                combo_trans_type.setChecked(tt_index2, true);
                combo_trans_type.enableFilteringMode(true);
                combo_curve_source.enableFilteringMode(true);

                combo_trans_type.attachEvent("onClose", function() {
                    fx_set_combo_text(combo_trans_type);
                });
            });

            function refresh_export_toolbar_click(args) { 
                switch(args) {
                    case 'add':
                        run_mtm_process.select_deal();
                    break;
                    case 'delete':
                        run_mtm_process.mtm_process.deleteSelectedRows();
                        var row_count = run_mtm_process.mtm_process.getRowsNum();
                        
                        if(row_count == 0) {
                            run_mtm_process.toolbar_run_mtm_process.setItemDisabled('select_unselect');
                        }
                    break;
                    case 'select_unselect':
                        var select_rows = run_mtm_process.mtm_process.getSelectedRowId();
                        
                        if (select_rows == null) {
                            run_mtm_process.mtm_process.selectAll();                    
                            run_mtm_process.toolbar_run_mtm_process.setItemEnabled('delete');
                        } else {
                            run_mtm_process.mtm_process.clearSelection(true);
                            run_mtm_process.toolbar_run_mtm_process.setItemDisabled('delete');
                        }
                    break;
                    case 'excel':
                        path = js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php';
                        run_mtm_process.mtm_process.toExcel(path);
                        
                        break;
                    case 'pdf':
                        path = js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php';
                        run_mtm_process.mtm_process.toPDF(path);
                        break;  
                    default:
                        break; 
                }
            }
        
            run_mtm_process.row_selected = function() { 
                run_mtm_process.toolbar_run_mtm_process.setItemEnabled('delete');
            }   
        
            run_mtm_process.select_deal = function() {
                var col_list = run_mtm_process.mtm_process.columnIds.toString();       
                var view_deal_window = new dhtmlXWindows();
                var win_id = 'w1';
                
                //deal_win should be global variable to access from callback function 'run_mtm_process.callback_select_deal' to close child window ie deal window
                deal_win = view_deal_window.createWindow(win_id, 0, 0, 600, 600);
                deal_win.setModal(true);
                
                var win_title = 'Select Deal';
                var win_url = '../../_deal_capture/maintain_deals/maintain.deals.new.php';  
                
                /*
                read_only: Default value is false. Set this to true to opens deal page in read only mode. In this mode user are allowed to select existing deals only.
                col_list: List of columns to be listed in grid
                deal_select_completed: Callback function name
                Note: Beside these parameters if extra parameters are added then they should be properly handled in maintain.deals.new.php
                */      
                var params = {call_from:'Run MTM Process',read_only:true,col_list:col_list,deal_select_completed:'run_mtm_process.callback_select_deal'};
                
                deal_win.setText(win_title);
                deal_win.maximize();
                deal_win.attachURL(win_url, false, params);        
            }
            
            run_mtm_process.callback_select_deal = function(result) {
                deal_win.close();
                run_mtm_process.mtm_process.clearAll();
                run_mtm_process.mtm_process.parse(result, "jsarray");
                
                if (result.length > 0) {
                    run_mtm_process.toolbar_run_mtm_process.setItemEnabled('select_unselect'); 
                }   
            }
            
            function run_mtm_process_onclick(){
                var sub_ids = (run_mtm_process.get_subsidiary('browser')) ? run_mtm_process.get_subsidiary('browser') : 'NULL';
                var close_date = run_mtm_process.form_run_mtm_process.getItemValue('as_of_date',true);

                data = { 
                    "action": "spa_lock_as_of_date",
                    "flag": "c",
                    "sub_ids":sub_ids,
                    "close_date": close_date
                };

                adiha_post_data('return_array', data, '', '', 'run_mtm_process_callback', '');
            } 
        
            function run_mtm_process_callback(result) {

                if (result[0][0] == 'Error') {
                    show_messagebox(result[0][4]);
                    return;
                } else {
                    run_mtm_process();
                }

            }
            
            function run_mtm_process() {
                var sub_book_id = (run_mtm_process.get_subbook()) ? run_mtm_process.get_subbook() : 'NULL';
                var sub_id = (run_mtm_process.get_subsidiary('browser')) ? run_mtm_process.get_subsidiary('browser') : 'NULL';
                var strategy_id = (run_mtm_process.get_strategy('browser')) ? run_mtm_process.get_strategy('browser') : 'NULL';
                var book_id = (run_mtm_process.get_book('browser')) ? run_mtm_process.get_book('browser') : 'NULL';
                
                var pnl_source = 'NULL';
                var hedge_or_item = 'b';
                var run_incremental = 'n';
                var calc_type;

                var multiple_deal_ids = run_mtm_process.mtm_process.getRowsNum();  
                var form_data_arr = new Array();
                        
                var form_obj = run_mtm_process.run_mtm_process_layout.cells("b").getAttachedObject();
                var form_data = form_obj.getFormData();
                
                var validate_return = validate_form(form_obj);
                
                if (!validate_return) {
                    return;
                }

                for (var label in form_data) {
                    if (form_obj.getItemType(label) == 'calendar') {
                        value = form_obj.getItemValue(label, true);
                    } else {
                        value = form_data[label];
                    }
                    
                    form_data_arr[label] = value;            
                }
                
                var deal_id = form_data_arr['deal_id'];
                var deal_ref_id = form_data_arr['deal_ref_id'];
                var is_calculate_mtm_atribution_checked = (form_data_arr['calculate_mtm_atribution'] == 'y')? 1 : 'NULL';
                var is_calculate_fx_exposure_checked = (form_data_arr['calculate_fx_exposure'] == 'y')? 1 : 'NULL';
                var is_ignore_deal_date_checked = (form_data_arr['ignore_deal_date'] == 'y')? 1 : 0;
                
                if (is_calculate_fx_exposure_checked == 1) {
                    calc_type = 'x';
                } else {
                    calc_type = 'm';
                }

                if (form_data_arr['term_start'] > form_data_arr['term_end']) {
                    show_messagebox('Term Start cannot be greater than Term End.');
                    return;
                }          
                    
                if (multiple_deal_ids > 0 && deal_id == '') {
                    var col_index = run_mtm_process.mtm_process.getColIndexById('id');       
                    
                    var deal_ids = new Array();

                    run_mtm_process.mtm_process.forEachRow(function(row_id){
                        deal_ids.push(run_mtm_process.mtm_process.cells(row_id, col_index).getValue());
                    });
                    
                    deal_id = deal_ids.toString();
                } 
                
                if (deal_id == '' &&  deal_ref_id == '' && multiple_deal_ids == 0 && sub_id == 'NULL' && book_id == 'NULL') {
                    show_messagebox('Please select at least one Subsidiary or a Book.');
                    return;
                }
                
                if (deal_ref_id == '') {
                    deal_ref_id = 'NULL';
                }

                if (deal_id == '' && sub_id != 'NULL') {
                    deal_id = 'NULL';
                }

                var param = 'call_from=run_mtm_process&gen_as_of_date=1&batch_type=c&as_of_date=' + form_data_arr['as_of_date'];
                var title = 'Run MTM Process Job';
                
                var exec_call = "EXEC spa_calc_mtm_job " + 
                    singleQuote(sub_id) + ", " +
                    singleQuote(strategy_id) + ", " +
                    singleQuote(book_id) + ", " +
                    singleQuote(sub_book_id) + ", " +
                    singleQuote(deal_id) + ", " +
                    singleQuote('$AS_OF_DATE$') + ", " +
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
                    singleQuote('NULL') + ", " +
                    singleQuote('NULL') + ", " +
                    singleQuote(calc_type) + ", " +
                    singleQuote('NULL') + ", " +
                    singleQuote('NULL') + ", " +
                    singleQuote('NULL') + ", " +
                    singleQuote('NULL') + ", " +
                    singleQuote('NULL') + ", " +
                    singleQuote(deal_ref_id) + ", " +
                    singleQuote('NULL') + ", " +
                    singleQuote(form_data_arr['transaction_type'])  + ", " +
                    is_calculate_mtm_atribution_checked + ", " +
                    is_ignore_deal_date_checked;

                adiha_run_batch_process(exec_call, param, title);        
            }
            
            function undock_window() {
                run_mtm_process.run_mtm_process_layout.cells('c').undock(300, 300, 900, 700);
                run_mtm_process.run_mtm_process_layout.dhxWins.window('c').maximize();
                run_mtm_process.run_mtm_process_layout.dhxWins.window('c').button("park").hide();
                $(".undock-btn").hide();
            }
        
            function fx_set_combo_text(cmb_obj) {
                var checked_loc_arr = cmb_obj.getChecked();
                var final_combo_text = new Array();        
                
                $.each(checked_loc_arr, function(i) {
                    var opt_obj = cmb_obj.getOption(checked_loc_arr[i]);
                    
                    if (opt_obj.text != '') {
                        final_combo_text.push(opt_obj.text);     
                    }       
                });
                
                cmb_obj.setComboText(final_combo_text.join(','));  
            }
        </script>
    
    </body>
</html>