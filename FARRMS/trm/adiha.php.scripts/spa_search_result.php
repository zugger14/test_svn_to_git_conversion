<style type="text/css">
    html, body {
        width: 100%;
        height: 100%;
        margin: 0px;
        overflow: hidden;
    }
</style>
<?php
    include '../adiha.php.scripts/components/include.file.v3.php';
    $popup = new AdihaPopup();
    $form_name = 'form_search_result';
    
    $search_by_word = $_GET['search_by_word'];
    $process_table = $_GET['process_table'];
    $search_object = $_GET['search_object'];
    $column_name = $_GET['column_name'];
    $sws_table = $_GET['sws_table'];
    $table_name = $_GET['table_name'];
    
    //JSON for Layout
    $layout_json = '[
                        {
                            id:             "a",
                            width:          720,
                            header:         false,
                            collapse:       false,
                            fix_size:       [false,null]
                        }
                    ]';
    
    $name_space = 'search_result';
    
    //Creating Layout
    $search_result_layout = new AdihaLayout();
    echo $search_result_layout->init_layout('search_result_layout', '', '1C', $layout_json, $name_space);
    
    $grid_name='grid_search_result';
    echo $search_result_layout->attach_grid_cell($grid_name, 'a');
    echo $search_result_layout->attach_status_bar('a', true, '');
    $grid_search_result = new AdihaGrid();
    echo $grid_search_result->init_by_attach($grid_name, $name_space);
    
    if ($table_name == 'master_deal_view') {
        echo $grid_search_result->set_header("SNO, Source Deal Header,Source System ID, Deal ID,Deal Date,External Deal ID,Physical/\Financial,Structured Deal ID,Counterparty,Parent Counterparty,Entire Term Start,Entire Term End, Deal Type, Deal Sub Type,Option Flag,Option Type,Option Exercise Type,Source System Book ID1,Source System Book ID2,Source System Book ID3,Source System Book ID4,Subsidiary,Strategy,Book,Description1,Description2,Description3,Deal Category,Trader,Internal Deal Type,Internal Deal Sub Type,Template,Broker,Generator,Deal Status Date,Assignment Type,Compliance Year,State Value,Assigned Date,Assigned User,Contract,Create User,Create TS,Update User,Update TS,Legal Entity,Deal Profile,Fixation Type,Internal Portfolio,Commodity,Reference,Locked Deal,Close Reference ID,Block Type,Block Definition,Granularity,Pricing,Deal Reference Type,Deal Status,Confirm Status Type,Term Start,Term End,Contract Expiration Date,Fixed/\Float,Buy/\Sell,Index Name,Index Commodity,Index Currency,Index UOM,Index Proxy1,Index Proxy2,Index Proxy3,Index Settlement,Expiration Calendar,Deal Formula,Location,Location Region,Location Grid,Location Country,Location Group,Forecast Profile,Forecast Proxy Profile,Profile Type,Proxy Profile Type,Meter,Profile Code,PR Party,UDF,Deal Date,Entire Term Start,Entire Term End");
        echo $grid_search_result->set_columns_ids("SNO,source_deal_header_id,source_system_id,deal_id,deal_date,ext_deal_id,physical_financial,structured_deal_id,counterparty,parent_counterparty,entire_term_start,entire_term_end,deal_type,deal_sub_type,option_flag,option_type,option_excercise_type,source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4,subsidiary,strategy,Book,description1,description2,description3,deal_category,trader,internal_deal_type,internal_deal_subtype,template,broker,generator,deal_status_date,assignment_type,compliance_year,state_value,assigned_date,assigned_user,CONTRACT,create_user,create_ts,update_user,update_ts,legal_entity,deal_profile,fixation_type,internal_portfolio,commodity,reference,locked_deal,close_reference_id,block_type,block_definition,granularity,pricing,deal_reference_type,deal_status,confirm_status_type,term_start,term_end,contract_expiration_date,fixed_float,buy_sell,index_name,index_commodity,index_currency,index_uom,index_proxy1,index_proxy2,index_proxy3,index_settlement,expiration_calendar,deal_formula,location,location_region,location_grid,location_country,location_group,forecast_profile,forecast_proxy_profile,profile_type,proxy_profile_type,meter,profile_code,Pr_party,UDF,deal_date_varchar,entire_term_start_varchar,entire_term_end_varchar");
        echo $grid_search_result->set_widths("125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125");
        echo $grid_search_result->set_column_types("ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro");
        echo $grid_search_result->load_grid_data("EXEC spa_search_engine @flag='r', @process_table='$sws_table'");
    } else {
        echo $grid_search_result->set_header("ID,Name,Description");
        echo $grid_search_result->set_columns_ids("ID,Name,Description");
        echo $grid_search_result->set_widths("*,*,*");
        echo $grid_search_result->set_column_types("ro,ro,ro");
        echo $grid_search_result->load_grid_data("EXEC spa_search_engine @flag='z', @process_table='$process_table'");
        
        if ($table_name == 'source_minor_location') {
            echo $grid_search_result->set_column_visibility("true,false,false");
        } else {
            echo $grid_search_result->set_column_visibility("false,false,false");
        }        
    }
    
    echo $grid_search_result->enable_paging('25', 'pagingArea_a', true);
    echo $grid_search_result->return_init();             
    echo $grid_search_result->load_grid_functions();
    
    //attach grid ends
    
    $search_toolbar_json = '[
                        {id:"excel", type:"button", img:"excel.gif", imgdis:"excel_dis.gif", text:"Excel", title:"Excel"},
                        {id:"pdf", type:"button", img:"pdf.gif", text:"PDF", title:"PDF"}
                    ]';
    
     //Attaching toolbar for tree
    $toolbar_search = 'search_toolbar';
    echo $search_result_layout->attach_toolbar_cell($toolbar_search, 'a');
    $toolbar_search_obj = new AdihaToolbar();
    echo $toolbar_search_obj->init_by_attach($toolbar_search, $name_space);
    echo $toolbar_search_obj->load_toolbar($search_toolbar_json);
    echo $toolbar_search_obj->attach_event('', 'onClick', 'run_toolbar_click');
    
    //Closing Layout
    echo $search_result_layout->close_layout();
?>
<script type="text/javascript">
    function run_toolbar_click(id) {    
        switch(id) {
            case 'excel':
                path = js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php';
                search_result.grid_search_result.toExcel(path);
                break;
            case 'pdf':
                path = js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php';
                search_result.grid_search_result.toPDF(path);
                break;
        }
    }
</script>