<?php
/**
* Run settlement screen
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
<?php
   // include '../../../adiha.php.scripts/components/include.file.v3.php';
    $form_name = 'form_run_deal_settlement';
    $rights_run_deal_settlement = 10222300;
    $function_id = 10222300;
    $tree_name = 'tree_run_deal_settlement';
    list (
       $has_right_run_deal_settlement
    ) = build_security_rights (
       $rights_run_deal_settlement
    );
    
    //JSON for Layout
    $layout_json = '[
                        {
                            id:             "a",
                            text:           "Portfolio Hierarchy",
                            width:          375,
                            header:         true,
                            collapse:       false,
                            fix_size:       [false,null]
                        },
                        {
                            id:             "b",
                            height:         230,
                            header:         false,
                            collapse:       false,
                            fix_size:       [false,null]
                        },
                        {
                            id:             "c",
                            header:         true,
                            text:           "Deal Info",
                            Undock:         true                       
                        }
                    ]';
    
    $cell_json = '[
                        {
                            id:             "a",
                            header:         false,
                            height:         60
                        },
                        {
                            id:             "b",
                            header:         false
                        }
                    ]';
  
    $name_space = 'run_deal_settlement';
    
    $popup = new AdihaPopup();
    $run_deal_settlement_layout = new AdihaLayout();
    echo $run_deal_settlement_layout->init_layout('run_deal_settlement_layout', '', '3L', $layout_json, $name_space);
    
    // Tree layout
    echo $run_deal_settlement_layout->attach_layout_cell('book_filter_layout', 'a', '2E', $cell_json);
    $book_filter_layout_obj = new AdihaLayout();
    echo $book_filter_layout_obj->init_by_attach('book_filter_layout', $name_space);
    echo $book_filter_layout_obj->close_layout();

    echo $book_filter_layout_obj->attach_tree_cell($tree_name, 'b');


    //Attaching tree
    $tree_structure = new AdihaBookStructure($rights_run_deal_settlement);
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
    echo $tree_structure->attach_search_filter('run_deal_settlement.book_filter_layout', 'b');
    $date = date('Y-m-d', strtotime('last day of previous month'));
    $date_begin = date('Y-m-d', strtotime('first day of previous month'));
    

    // filter layout 

    echo $run_deal_settlement_layout->attach_layout_cell('filter_layout', 'b', '1C', '[{id: "a", header:false}]');
    $filter_layout_obj = new AdihaLayout();
    echo $filter_layout_obj->init_by_attach('filter_layout', $name_space);
    echo $filter_layout_obj->close_layout();

   // Attaching Form
    $form_object = new AdihaForm();
   
    $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10222300', @template_name='RunDealSettlement'";
    $return_value  = readXMLURL($xml_file);
    $form_json = $return_value [0][2];

    echo $run_deal_settlement_layout->attach_form($form_name, 'b');    
    echo $form_object->init_by_attach($form_name, $name_space);
    echo $form_object->load_form($form_json);
    echo $form_object->attach_event('', 'onButtonClick', 'run_button_click');
    $toolbar_json = '[
                        { id: "run", type: "button", img: "run.gif", text: "Run", title: "Run"}
                     ]';

    echo $run_deal_settlement_layout->attach_toolbar_cell('run_deal_settlement_toolbar', 'b');
    $run_deal_settlement_toolbar = new AdihaToolbar();
    echo $run_deal_settlement_toolbar->init_by_attach('run_deal_settlement_toolbar', $name_space);
    echo $run_deal_settlement_toolbar->load_toolbar($toolbar_json);
    echo $run_deal_settlement_toolbar->attach_event('', 'onClick', 'run_deal_settlement_onclick');
    
    $toolbar_json = '[  
                        {id:"Refresh", img:"refresh.gif", text:"Refresh", title:"Refresh"},                                
                        {id:"t2", text:"Export", img:"export.gif", items:[
                            {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                            {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
                        ]}
                    ]';
    
    $toolbar_formula_obj = new AdihaMenu();
    echo $run_deal_settlement_layout->attach_menu_cell("toolbar_run_deal_settlement", "c"); 
    echo $toolbar_formula_obj->init_by_attach("toolbar_run_deal_settlement", $name_space);
    echo $toolbar_formula_obj->load_menu($toolbar_json);
    echo $toolbar_formula_obj->attach_event('', 'onClick', 'refresh_export_toolbar_click');
    
    //grid definition
    $deal_settlement_grid_name = 'grd_deal_settlement';
    echo $run_deal_settlement_layout->attach_grid_cell($deal_settlement_grid_name, 'c');
    $deal_settlement_grid_obj = new AdihaGrid();
    echo $run_deal_settlement_layout->attach_status_bar("c", true);
    echo $deal_settlement_grid_obj->init_by_attach($deal_settlement_grid_name, $name_space);
    echo $deal_settlement_grid_obj->set_header("Reference ID,Deal ID,Deal Date,Term Start,Term End,Market,Index On,Currency,Deal Volume,UOM,Volume Frequency,Deal Type,Template,Sub Deal Type,Group 1,Group 2,Group 3,Group 4",",,,,,,,right,right,right,,,,,,,,");
    echo $deal_settlement_grid_obj->set_columns_ids("source_deal_id,deal_id,deal_date,term_start,term_end,index,curve_name,currency,deal_volume,deal_uom,volume_frequency,source_deal_type,template_name,sub_deal_type,group1,group2,group3,group4");
    echo $deal_settlement_grid_obj->set_widths("200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200");
    echo $deal_settlement_grid_obj->set_column_types("ro,ro_int,ro,ro,ro,ro,ro,ro,ro_v,ro,ro,ro,ro,ro,ro,ro,ro,ro");
    echo $deal_settlement_grid_obj->set_column_alignment(",,,,,,,right,right,right,,,,,,,,");
    echo $deal_settlement_grid_obj->enable_multi_select();
    echo $deal_settlement_grid_obj->set_column_visibility("false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false");
    echo $deal_settlement_grid_obj->enable_paging(100, 'pagingArea_c', 'true');
    echo $deal_settlement_grid_obj->enable_column_move('true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true');
    echo $deal_settlement_grid_obj->set_sorting_preference('str,int,str,str,str,str,str,str,int,str,str,str,str,str,str,str,str,str,str,str');
    echo $deal_settlement_grid_obj->set_search_filter(false,"#text_filter,#numeric_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#numeric_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,");
    echo $deal_settlement_grid_obj->return_init();
    echo $deal_settlement_grid_obj->enable_header_menu();
    echo $run_deal_settlement_layout->close_layout();
    
?>
<script type="text/javascript">
    $(function() {
        run_deal_settlement.form_run_deal_settlement.setItemValue('term_start',  '<?php echo $date_begin; ?>');
        run_deal_settlement.form_run_deal_settlement.setItemValue('term_end', '<?php echo $date; ?>');
        attach_browse_event('run_deal_settlement.form_run_deal_settlement');
        run_deal_settlement.form_run_deal_settlement.setItemValue('as_of_date', new Date());
        run_deal_settlement.form_run_deal_settlement.setItemValue('curve_source', 4500);
        var curve_source_combo = run_deal_settlement.form_run_deal_settlement.getCombo('curve_source');
        //curve_source_combo.enableFilteringMode(true);
        var has_right_run_deal_settlement = Boolean('<?php echo $has_right_run_deal_settlement; ?>');
        
        if (has_right_run_deal_settlement == false) {
            run_deal_settlement.form_run_deal_settlement.disableItem('btn_run');
        } else {
            run_deal_settlement.form_run_deal_settlement.enableItem('btn_run');
        }
        run_deal_settlement.form_run_deal_settlement.attachEvent("onChange", function(name,value,is_checked){
            if (name == 'term_start') {
                var term_start = run_deal_settlement.form_run_deal_settlement.getItemValue('term_start', true);
                var split = term_start.split('-');
                var year =  +split[0];
                var month = +split[1];
                var day = +split[2];
                var date = new Date(year, month-1, day);
                var lastDay = new Date(date.getFullYear(), date.getMonth() + 1, 0);
                term_end = formatDate(lastDay);
                run_deal_settlement.form_run_deal_settlement.setItemValue('term_end', term_end);
            } 
        });
        // Load apply filter          
        var filter_obj = run_deal_settlement.book_filter_layout.cells('a').attachForm();
        var layout_cell_obj = run_deal_settlement.run_deal_settlement_layout.cells('b')
        load_form_filter(filter_obj, layout_cell_obj, '10222300', 2, '', 'tree_run_deal_settlement');
       
    });
    
    /**
    * Check Lock As Of Date
    */
    function run_deal_settlement_onclick() { 
        var sub_ids = (run_deal_settlement.get_subsidiary('browser')) ? run_deal_settlement.get_subsidiary('browser') : 'NULL';
        var close_date = run_deal_settlement.form_run_deal_settlement.getItemValue('as_of_date',true);

        data = { "action": "spa_lock_as_of_date",
                    "flag": "c",
                    "sub_ids":sub_ids,
                    "close_date": close_date
        };
        
        adiha_post_data('return_array', data, '', '', 'run_deal_settlement_callback', 'tree_run_deal_settlement');

    } 

    function run_deal_settlement_callback(result){
        if (result[0][0] == 'Error') {
            show_messagebox(result[0][4]);
            return;
        } else {
           run_deal_settlement();
        }
        
    }

    function run_deal_settlement() {
        var sub_book_id = run_deal_settlement.get_subbook(); 
        var curve_id = run_deal_settlement.form_run_deal_settlement.getItemValue('curve_source'); 
        var as_of_date = run_deal_settlement.form_run_deal_settlement.getItemValue('as_of_date', true); 
        var term_start = run_deal_settlement.form_run_deal_settlement.getItemValue('term_start', true);
        var term_end = run_deal_settlement.form_run_deal_settlement.getItemValue('term_end', true); 
        var deal_id = run_deal_settlement.form_run_deal_settlement.getItemValue('deal_id');
        var deal_ref_id = run_deal_settlement.form_run_deal_settlement.getItemValue('deal_ref_id');
        var deal_filter = run_deal_settlement.form_run_deal_settlement.getItemValue('deal_filter');  
        var sub_id = run_deal_settlement.get_subsidiary();
        var strategy_id = run_deal_settlement.get_strategy();
        var book_id = run_deal_settlement.get_book();
        var sub_book_id = run_deal_settlement.get_subbook(); 
        var pnl_source = 'NULL';
        var hedge_or_item = 'b';
        var run_incremental = 'n';
        var calc_type = 's'; 
        var counterparty_id = run_deal_settlement.form_run_deal_settlement.getItemValue('counterparty_id');                        
        var contract_id = run_deal_settlement.form_run_deal_settlement.getItemValue('contract_id');      
        counterparty_id = counterparty_id.toString();
        var settlement_term = run_deal_settlement.form_run_deal_settlement.getItemValue('settlement_term');

        contract_id = contract_id.toString();
        var form_obj = run_deal_settlement.run_deal_settlement_layout.cells("b").getAttachedObject();
        var validate_return = validate_form(form_obj);

        if (validate_return === false) {
            return;
        }
              
        if (term_start > term_end) {
            show_messagebox('Term Start cannot be greater than Term End.');
            return;
        }

        if (term_end > as_of_date) {
            show_messagebox('Term End can not be greater than As of Date.');
            return;
        }
        
        if (isNaN(deal_id) == true) {
            show_messagebox('Please enter a numeric value in Deal ID.');
            return;
        }

        /* Append deal filter value to deal filter.
        * Deal filter returns CSV value. Deal filter param in SP expects process table.
        * So appending deal filter value to source deal header param*/
        if (deal_id && deal_filter && deal_id != '' && deal_filter != '') {
            deal_id = deal_id + ',' + deal_filter
        } else if ((!deal_id || deal_id == '') && deal_filter) {
            deal_id = deal_filter;
        }
        /*End of appending deal filter value*/
        filter_deal_ref_id = [];
        if (deal_ref_id && deal_ref_id != '' && deal_ref_id != null) {
            filter_deal_ref_id = deal_ref_id.split(',');
        }

        if (sub_book_id == '' && deal_id == ''){//book_id == '' && sub_book_id == '') {
            show_messagebox('Please select at least one <b>Subsidiary</b>/<b>Book</b> or enter <b>Deal ID</b>.');
            return;
        }
        if (run_deal_settlement.grd_deal_settlement != undefined) {
            if (run_deal_settlement.grd_deal_settlement.getSelectedRowId() != null) {
                var deal_row_id = run_deal_settlement.grd_deal_settlement.getSelectedRowId();
                var selected_row_array_d = deal_row_id.split(',');
                for(var i = 0; i < selected_row_array_d.length; i++) {
                    if (i == 0) {
                        if (deal_id == null || deal_id == '') {
                            deal_id = run_deal_settlement.grd_deal_settlement.cells(selected_row_array_d[i], 1).getValue();  
                        } else {
                            deal_id = deal_id + ',' + run_deal_settlement.grd_deal_settlement.cells(selected_row_array_d[i], 1).getValue();
                        }
                    } else {
                        deal_id = deal_id + ',' + run_deal_settlement.grd_deal_settlement.cells(selected_row_array_d[i], 1).getValue();
                    }
                }
            } else {
                deal_id = deal_id;
            }
        }
        
        var ref_id = '';
        var grid_ref_id_array = [];
        if (run_deal_settlement.grd_deal_settlement != undefined) {
            var selected_row_array_r = [];
            if (run_deal_settlement.grd_deal_settlement.getSelectedRowId() != null) { 
                var deal_ref_id = run_deal_settlement.grd_deal_settlement.getSelectedRowId();
                selected_row_array_r = deal_ref_id.split(',');
                for (var j = 0; j < selected_row_array_r.length; j++) {
                    if (j == 0) {
                        ref_id = run_deal_settlement.grd_deal_settlement.cells(selected_row_array_r[j], 0).getValue();
                    } else {
                        ref_id = ref_id + ',' + run_deal_settlement.grd_deal_settlement.cells(selected_row_array_r[j], 0).getValue();
                    }
                }
                grid_ref_id_array = ref_id.split(',');
            }
        }

        var ref_id_array = [];
        ref_id_array = filter_deal_ref_id.concat(grid_ref_id_array).filter(function(item, i, ar){ return ar.indexOf(item) === i; });

        if (ref_id_array.length > 0) {
            ref_id = ref_id_array.join();
        } else {
            ref_id = '';
        }

        var param = 'call_from=run_deal_settlement&gen_as_of_date=1&batch_type=c&as_of_date=' + as_of_date;
        var title = 'Run Deal Settlement Process Job';
        
        var exec_call = "EXEC spa_calc_mtm_job " + 
                        singleQuote(sub_id) + ", " +
                        singleQuote(strategy_id) + ", " +
                        singleQuote(book_id) + ", " +
                        singleQuote(sub_book_id) + ", " +
                        singleQuote(deal_id) + ", " +
                        singleQuote('$AS_OF_DATE$') + ", " +
                        curve_id + ", " +
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
                        singleQuote(deal_filter)  +  ", " +
                        singleQuote('NULL') + ", " +
                        singleQuote(counterparty_id) + ", " +
                        singleQuote(ref_id) + ", " +
                        singleQuote('NULL') + ", " +
                        singleQuote('NULL') + ", " +
                        singleQuote('0') + ", " +
                        singleQuote('0') + ", " +
                        singleQuote('0') + ", " +
                        singleQuote('NULL') + ", " +
                        singleQuote(settlement_term);
        //alert(exec_call)
        adiha_run_batch_process(exec_call, param, title);
    }   
    
    function refresh_grid() {
        var sub_book_id = run_deal_settlement.get_subbook();
        var curve_id = run_deal_settlement.form_run_deal_settlement.getItemValue('curve_source');
        var as_of_date = run_deal_settlement.form_run_deal_settlement.getItemValue('as_of_date', true);
        var term_start = run_deal_settlement.form_run_deal_settlement.getItemValue('term_start', true);
        var term_end = run_deal_settlement.form_run_deal_settlement.getItemValue('term_end', true);
        var deal_id = run_deal_settlement.form_run_deal_settlement.getItemValue('deal_id');
        var deal_ref_id = run_deal_settlement.form_run_deal_settlement.getItemValue('deal_ref_id');
        var deal_filter = run_deal_settlement.form_run_deal_settlement.getItemValue('deal_filter');
        var counterparty_id = run_deal_settlement.form_run_deal_settlement.getItemValue('counterparty_id');     
        var contract_id = run_deal_settlement.form_run_deal_settlement.getItemValue('contract_id');

        contract_id = contract_id.toString();
        counterparty_id = counterparty_id.toString();
        var form_obj = run_deal_settlement.run_deal_settlement_layout.cells("b").getAttachedObject();
        var validate_return = validate_form(form_obj);
        if (validate_return === false) {
            return;
        }
        if (sub_book_id == 'NULL' || sub_book_id == '') {
            run_deal_settlement.run_deal_settlement_layout.cells('c').progressOff();
            show_messagebox('Please select a Sub Book.');
            return;
        }
        
        if (term_start > term_end) {

            run_deal_settlement.run_deal_settlement_layout.cells('c').progressOff();
            show_messagebox('Term Start cannot be greater than Term End.');
            return;
        }
        
        if (isNaN(deal_id) == true && deal_id != '') {
            run_deal_settlement.run_deal_settlement_layout.cells('c').progressOff();
            show_messagebox('Please enter a numeric value in Deal ID.');
            return;
        }

        var sp_url_param = {                    
                        "book_deal_type_map_id": sub_book_id,
                        "as_of_date": as_of_date,
                        "term_start": term_start,
                        "term_end": term_end,
                        "deal_id": deal_id,
                        "deal_ref_id": deal_ref_id,
                        "deal_id_list": deal_filter,
                        "contract": contract_id,
                        "counterparty_id": counterparty_id,
                        "action": "spa_get_deal_for_mtm"
        };
        sp_url_param  = $.param(sp_url_param );
        var sp_url  = js_data_collector_url + "&" + sp_url_param ;
        run_deal_settlement.grd_deal_settlement.clearAll();
        run_deal_settlement.grd_deal_settlement.loadXML(sp_url,function(){
            run_deal_settlement.grd_deal_settlement.filterByAll();
        });
    }

    function refresh_export_toolbar_click(args) { 
        switch(args) {
            case 'Refresh':
                    refresh_grid();                             
                break;
            case 'excel':
                path = js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php';
                run_deal_settlement.grd_deal_settlement.toExcel(path);
                
                break;
            case 'pdf':
                path = js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php';
                run_deal_settlement.grd_deal_settlement.toPDF(path);
                
                break;    
        }
    }
    
    function run_button_click(args) {
        switch(args) {
            case 'btn_deal_filter':                
                var deal_search_window = new dhtmlXWindows();
                var src = '../../../adiha.php.scripts/spa_deal_search.php'; 
                deal_search = deal_search_window.createWindow('w1', 50, 165, 800, 400);
                deal_search.setText('Deal Search');
                deal_search.attachURL(src, false, true);
            break;
            case 'btn_deal_filter_clear':
                run_deal_settlement.form_run_deal_settlement.setItemValue('deal_filter', '');
                run_deal_settlement.form_run_deal_settlement.setItemValue('label_deal_filter', '');
                run_deal_settlement.form_run_deal_settlement.setItemValue('txt_process_table', '');
            break;   
            default:
                //Do nothing
            break;        
        }
    } 

    /**
     * [function to formatDate]
     */
    function formatDate(date) {
        var d = new Date(date),
            month = '' + (d.getMonth() + 1),
            day = '' + d.getDate(),
            year = d.getFullYear();

        if (month.length < 2) month = '0' + month;
        if (day.length < 2) day = '0' + day;

        return [year, month, day].join('-');
    }

    function undock_window() {
        run_deal_settlement.run_deal_settlement_layout.cells('c').undock(300, 300, 900, 700);
        run_deal_settlement.run_deal_settlement_layout.dhxWins.window('c').button('park').hide();
        run_deal_settlement.run_deal_settlement_layout.dhxWins.window('c').maximize();
    }

</script>
</html>