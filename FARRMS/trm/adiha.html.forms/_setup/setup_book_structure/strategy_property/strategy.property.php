<style type="text/css">
    html, body {
        width: 100%;
        height: 100%;
        margin: 0px;
        overflow: hidden;
    }
    #calendar,
	#calendar2,
	#calendar3 {
		border: 1px solid #909090;
		font-family: Tahoma;
		font-size: 12px;
</style>
<?php
    include '../../../../adiha.php.scripts/components/include.file.v3.php';
    $form_name = 'form_subsidiary_book';
    
    
    //JSON for Layout
    $layout_json = '[
                        {
                            id:             "a",
                            width:          250,
                            header:         false,
                            collapse:       false,
                            fix_size:       [false,null]
                        },
                    
                    ]';
    

    $form_namespace = 'subsidiary_book';
    
    $popup = new AdihaPopup();
    $subsidiary_book_layout = new AdihaLayout();

    echo $subsidiary_book_layout->init_layout('subsidiary_book_layout', '', '1C', $layout_json, $form_namespace);
    
    $subsidiary_book_toolbar = new AdihaToolbar();
    $toolbar_name =  'Save_from_toolbar';
    $toolbar_json = '[
                        { id: "save", type: "button", img: "save.gif", text:"Save", title: "Add"},
                        { type: "separator" }
                     
                     ]';
                 
    echo $subsidiary_book_layout->attach_toolbar_cell($toolbar_name, 'a'); 
    echo $subsidiary_book_toolbar-> init_by_attach($toolbar_name, $form_namespace);
    echo $subsidiary_book_toolbar-> load_toolbar($toolbar_json);
   // echo $subsidiary_book_toolbar->attach_event('','onClick','btn_save_click');
    //echo $subsidiary_book_toolbar-> attach_event('', 'onClick','save_toolbar_click');  

    // Attaching Form
    $form_obj = new AdihaForm();
    
    //for general
    echo "source_system_dropdown = ". $form_obj->adiha_form_dropdown("EXEC spa_getallsourcesystems",0,1) . ";"."\n";
    $sp_url_functional_currency = "EXEC spa_getfuncurrencysourceid '650'";
    echo "functional_currency_dropdown = ".  $form_obj->adiha_form_dropdown($sp_url_functional_currency, 1, 2) . ";"."\n";
    
    echo "accounting_type_dropdown = ". $form_obj->adiha_form_dropdown("EXEC spa_StaticDataValues 'h', '150'",0,1, false, '', 2) . ";"."\n";
    
    
    
       //for details tab
    echo "measurement_granularity_dropdown = ". $form_obj->adiha_form_dropdown("EXEC spa_StaticDataValues 'h', '175'",0,1, false, '', 2) . ";"."\n";
    echo "rolling_hedge_forward_dropdown = ". $form_obj->adiha_form_dropdown("EXEC spa_StaticDataValues 'h', '250'",0,1, false, '', 2) . ";"."\n";
    echo "gl_entry_group_forward_dropdown = ". $form_obj->adiha_form_dropdown("EXEC spa_StaticDataValues 'h', '350'",0,1, false, '', 2) . ";"."\n";
    echo "roll_out_type_dropdown = ". $form_obj->adiha_form_dropdown("EXEC spa_StaticDataValues 'h', '520'",0,1, false, '', 2) . ";"."\n";
    echo "measurement_value_dropdown = ". $form_obj->adiha_form_dropdown("EXEC spa_StaticDataValues 'h', '200'",0,1, false, '', 2) . ";"."\n";
    echo "strip_transactions_dropdown = ". $form_obj->adiha_form_dropdown("EXEC spa_StaticDataValues 'h', '625'",0,1, false, '', 2) . ";"."\n";
    echo "exclude_values_dropdown = ". $form_obj->adiha_form_dropdown("EXEC spa_StaticDataValues 'h', '225'",0,1, false, '', 2) . ";"."\n";
    echo "oci_rollout_dropdown = ". $form_obj->adiha_form_dropdown("EXEC spa_StaticDataValues 'h', '500'",0,1, false, '', 2) . ";"."\n";
    echo "tenor_option_dropdown = ". $form_obj->adiha_form_dropdown("EXEC spa_StaticDataValues 'h', '500'",0,1, false, '', 2) . ";"."\n";
   
    
    
    //for gl_code_mapping_form tab
     echo "hedge_st_asset_dropdown = ". $form_obj->adiha_form_dropdown("EXEC spa_gl_code_mapping 's', '150'",1,2) . ";"."\n";
     
     //forsub entity info Tab     
    echo "distinct_estimation_dropdown = ". $form_obj->adiha_form_dropdown("EXEC spa_StaticDataValues 'h', '10050'",0,1, false, '', 2) . ";"."\n";
    echo "distinct_output_metrics_dropdown = ". $form_obj->adiha_form_dropdown("EXEC spa_StaticDataValues 'h', '1050'",0,1, false, '', 2) . ";"."\n";
    echo "distinct_foreign_country_dropdown = ". $form_obj->adiha_form_dropdown("EXEC spa_StaticDataValues 'h', '10077'",0,1, false, '', 2) . ";"."\n";
    echo "primary_naics_dropdown = ". $form_obj->adiha_form_dropdown("EXEC spa_StaticDataValues 'h', '10078'",0,1, false, '', 2) . ";"."\n";
    echo "secondary_naics_dropdown = ". $form_obj->adiha_form_dropdown("EXEC spa_StaticDataValues 'h', '10079'",0,1, false, '', 2) . ";"."\n";
    echo "organization_boundary_dropdown = ". $form_obj->adiha_form_dropdown("EXEC spa_StaticDataValues 'h', '1100'",0,1, false, '', 2) . ";"."\n";
   
   
    
    $general_form_structure = "[
                            {type: 'combo', name: 'source_system_id', label: 'Source System:',width: 160,options: source_system_dropdown, position: 'absolute', inputLeft: 180, inputTop: 20, labelLeft: 5, labelTop: 20, labelWidth: 160,required: true},
                            {type: 'input', name: 'fas_strategy_id', label: 'Name:',width: 160, position: 'absolute', inputLeft: 180, inputTop: 60, labelLeft: 10, labelTop: 60, labelWidth: 160,required: true},
                            {type: 'combo', name: 'func_cur_value_id', label: 'Functional Currency:',width: 160,options: functional_currency_dropdown, position: 'absolute', inputLeft: 180, inputTop: 100, labelLeft: 10, labelTop: 100, labelWidth: 160},
                            {type: 'combo', name: 'hedge_type_value_id', label: 'Accounting Type:',width: 160,options: accounting_type_dropdown, position: 'absolute', inputLeft: 180, inputTop: 140, labelLeft: 10, labelTop: 140, labelWidth: 160,required: true}
                            ]";  
                            
      $details_form_structure = "[                          
                            {type: 'input', name: 'no_links_fas_eff_test_profile_id', label: 'No Link Relationship Type:',width: 160, position: 'absolute', inputLeft: 180, inputTop: 20, labelLeft: 10, labelTop: 20, labelWidth: 160},
                            {type: 'button', name: 'btn_clear', value: '...', position: 'absolute', inputLeft: 350, inputTop: 20},
                            {type: 'combo', name: 'mes_gran_value_id', label: 'Measurement Granularity:',width: 160,options: measurement_granularity_dropdown, position: 'absolute', inputLeft: 180, inputTop: 60, labelLeft: 10, labelTop: 60, labelWidth: 160},
                            {type: 'combo', name: 'mismatch_tenor_value_id', label: 'Rolling Hedge Forward:',width: 160,options: rolling_hedge_forward_dropdown, position: 'absolute', inputLeft: 550, inputTop: 60, labelLeft: 375, labelTop: 60, labelWidth: 160},
                            {type: 'combo', name: 'gl_grouping_value_id', label: 'GL Entry Grouping:',width: 160,options: gl_entry_group_forward_dropdown, position: 'absolute', inputLeft: 180, inputTop: 100, labelLeft: 10, labelTop: 100, labelWidth: 160},
                            {type: 'combo', name: 'rollout_per_type', label: 'Rollout Per Type:',width: 160,options: roll_out_type_dropdown, position: 'absolute', inputLeft: 550, inputTop: 100, labelLeft: 375, labelTop: 100, labelWidth: 160},
                            {type: 'combo', name: 'mes_cfv_value_id', label: 'Measurement Values:',width: 160,options: measurement_value_dropdown, position: 'absolute', inputLeft: 180, inputTop: 140, labelLeft: 10, labelTop: 140, labelWidth: 160},
                            {type: 'combo', name: 'strip_trans_value_id', label: 'Strip Transactions:',width: 160,options: strip_transactions_dropdown, position: 'absolute', inputLeft: 550, inputTop: 140, labelLeft: 375, labelTop: 140, labelWidth: 160},
                            {type: 'combo', name: 'mes_cfv_values_value_id', label: 'Exclude Values:',width: 160,options: exclude_values_dropdown, position: 'absolute', inputLeft: 180, inputTop: 180, labelLeft: 10, labelTop: 180, labelWidth: 160},
                            {type: 'combo', name: 'oci_rollout_approach_value_id', label: 'OCI Rollout:',width: 160,options: oci_rollout_dropdown, position: 'absolute', inputLeft: 550, inputTop: 180, labelLeft: 375, labelTop: 180, labelWidth: 160},
                            {type: 'input', name: 'test_range_from', label: 'Test Range From 1:',width: 160, position: 'absolute', inputLeft: 180, inputTop: 220, labelLeft: 10, labelTop: 220, labelWidth: 160},
                            {type: 'input', name: 'additional_test_range_from', label: 'Test Range From 2:',width: 160,position: 'absolute', inputLeft: 550, inputTop: 220, labelLeft: 375, labelTop: 220, labelWidth: 160},                              
                            {type: 'input', name: 'test_range_to', label: 'Test Range To 1:',width: 160, position: 'absolute', inputLeft: 180, inputTop: 260, labelLeft: 10, labelTop: 260, labelWidth: 160},
                            {type: 'input', name: 'additional_test_range_to', label: 'Test Range To 2:',width: 160,position: 'absolute', inputLeft: 550, inputTop: 260, labelLeft: 375, labelTop: 260, labelWidth: 160},
                            {type: 'input', name: 'additional_test_range_from2', label: 'Test Range From 3:',width: 160, position: 'absolute', inputLeft: 180, inputTop: 300, labelLeft: 10, labelTop: 300, labelWidth: 160},
                            {type: 'input', name: 'additional_test_range_to2', label: 'Test Range To 3:',width: 160,position: 'absolute', inputLeft: 550, inputTop: 300, labelLeft: 375, labelTop: 300, labelWidth: 160},
                            {type: 'input', name: 'first_day_pnl_threshold', label: 'First Day PNL Threshold:',width: 160, position: 'absolute', inputLeft: 180, inputTop: 340, labelLeft: 10, labelTop: 340, labelWidth: 160},
                            {type: 'combo', name: 'gl_tenor_option', label: 'Tenor Option:',width: 160,options: '',position: 'absolute', inputLeft: 550, inputTop: 340, labelLeft: 375, labelTop: 340, labelWidth: 160},
                            {type: 'checkbox', name: 'fx_hedge_flag', label: 'FX Hedges For Net Investment In Foreign Operations',width: 160, position: 'label-right',offsetTop:380,offsetLeft:10},
                            {type: 'checkbox', name: 'include_unlinked_hedges', label: 'Include Unlink Hedges',width: 160, position: 'label-right',checked:'true',offsetLeft:10},
                            {type: 'newcolumn', offset:20},
                            {type: 'checkbox', name: 'no_links', label: 'Only Short Term',width: 160, position: 'label-right',offsetTop:380}, 
                            {type: 'checkbox', name: 'include_unlinked_items', label: 'Include Unlink Items',width: 160, position: 'label-right'}
                            
                            ]";
                            

    $gl_code_mapping_form_structure = "[  
                            {type: 'combo', name: 'gl_number_id_st_asset', label: 'Hedge ST Asset:',width: 160,options: hedge_st_asset_dropdown, position: 'absolute', inputLeft: 180, inputTop: 20, labelLeft: 10, labelTop: 20, labelWidth: 160},
                            {type: 'combo', name: 'gl_number_id_lt_asset', label: 'Hedge LT Asset:',width: 160,options: hedge_st_asset_dropdown, position: 'absolute', inputLeft: 550, inputTop: 20, labelLeft: 375, labelTop: 20, labelWidth: 160},
                            {type: 'combo', name: 'gl_number_id_st_liab', label: 'Hedge ST Liability:',width: 160,options: hedge_st_asset_dropdown, position: 'absolute', inputLeft: 180, inputTop: 60, labelLeft: 10, labelTop: 60, labelWidth: 160},
                            {type: 'combo', name: 'gl_number_id_lt_liab', label: 'Hedge LT Liability:',width: 160,options: hedge_st_asset_dropdown, position: 'absolute', inputLeft: 550, inputTop: 60, labelLeft: 375, labelTop: 60, labelWidth: 160},  
                            {type: 'combo', name: 'gl_id_st_tax_asset', label: 'Tax ST Asset:',width: 160,options: hedge_st_asset_dropdown, position: 'absolute', inputLeft: 180, inputTop: 100, labelLeft: 10, labelTop: 100, labelWidth: 160},  
                            {type: 'combo', name: 'gl_number_id_lt_asset', label: 'Tax LT Asset:',width: 160,options: hedge_st_asset_dropdown, position: 'absolute', inputLeft: 550, inputTop: 100, labelLeft: 375, labelTop: 100, labelWidth: 160},            
                            {type: 'combo', name: 'gl_id_st_tax_liab', label: 'Tax ST Liability:',width: 160,options: hedge_st_asset_dropdown, position: 'absolute', inputLeft: 180, inputTop: 140, labelLeft: 10, labelTop: 140, labelWidth: 160},  
                            {type: 'combo', name: 'gl_id_lt_tax_liab', label: 'Tax LT Liability:',width: 160,options: hedge_st_asset_dropdown, position: 'absolute', inputLeft: 550, inputTop: 140, labelLeft: 375, labelTop: 140, labelWidth: 160},
                            {type: 'combo', name: 'gl_id_tax_reserve', label: 'Tax Reserve:',width: 160,options: hedge_st_asset_dropdown, position: 'absolute', inputLeft: 180, inputTop: 180, labelLeft: 10, labelTop: 180, labelWidth: 160},  
                            {type: 'combo', name: 'gl_number_id_aoci', label: 'AOCI/Hedge Reserve:',width: 160,options: hedge_st_asset_dropdown, position: 'absolute', inputLeft: 550, inputTop: 180, labelLeft: 375, labelTop: 180, labelWidth: 160}, 
                            {type: 'combo', name: 'gl_number_id_inventory', label: 'Inventory/Asset:',width: 160,options: hedge_st_asset_dropdown, position: 'absolute', inputLeft: 180, inputTop: 220, labelLeft: 10, labelTop: 220, labelWidth: 160},  
                            {type: 'combo', name: 'gl_number_id_pnl', label: 'Unrealized Earning:',width: 160,options: hedge_st_asset_dropdown, position: 'absolute', inputLeft: 550, inputTop: 220, labelLeft: 375, labelTop: 220, labelWidth: 160}, 
                            {type: 'combo', name: 'gl_number_id_set', label: 'Earning:',width: 160,options: hedge_st_asset_dropdown, position: 'absolute', inputLeft: 180, inputTop: 260, labelLeft: 10, labelTop: 260, labelWidth: 160},  
                            {type: 'combo', name: 'gl_number_id_cash', label: 'Receivables:',width: 160,options: hedge_st_asset_dropdown, position: 'absolute', inputLeft: 550, inputTop: 260, labelLeft: 375, labelTop: 260, labelWidth: 160}, 
                            {type: 'combo', name: 'gl_number_id_gross_set', label: 'Cash Var Earnings:',width: 160,options: hedge_st_asset_dropdown, position: 'absolute', inputLeft: 180, inputTop: 300, labelLeft: 10, labelTop: 300, labelWidth: 160}
                             ]";
                            
                            
    $sub_entity_form_structure = "[                          
                             {type: 'input', name: 'subentity_name', label: 'Name:',width: 160, position: 'absolute', inputLeft: 180, inputTop: 20, labelLeft: 10, labelTop: 20, labelWidth: 160},
                             {type: 'input', name: 'subentity_desc', label: 'Description:',width: 160, position: 'absolute', inputLeft: 550, inputTop: 20, labelLeft: 375, labelTop: 20, labelWidth: 160},
                             {type: 'input', name: 'relationship_to_entity', label: 'Relationship to Entity:',width: 160, position: 'absolute', inputLeft: 180, inputTop: 60, labelLeft: 10, labelTop: 60, labelWidth: 160},
                             {type: 'combo', name: 'distinct_estimation_method', label: 'Distinct Estimation Method:',width: 160,options: distinct_estimation_dropdown, position: 'absolute', inputLeft: 550, inputTop: 60, labelLeft: 375, labelTop: 60, labelWidth: 160},
                             {type: 'combo', name: 'distinct_output_metrics', label: 'Distinct Output Metrics:',width: 160,options: distinct_output_metrics_dropdown, position: 'absolute', inputLeft: 180, inputTop: 100, labelLeft: 10, labelTop: 100, labelWidth: 160},
                             {type: 'combo', name: 'distinct_foreign_country', label: 'Distinct Foreign Country:',width: 160,options: distinct_foreign_country_dropdown, position: 'absolute', inputLeft: 550, inputTop: 100, labelLeft: 375, labelTop: 100, labelWidth: 160},
                             {type: 'combo', name: 'primary_naics_code_id', label: 'Primary NAICS Code:',width: 160,options: primary_naics_dropdown, position: 'absolute', inputLeft: 180, inputTop: 140, labelLeft: 10, labelTop: 140, labelWidth: 160},
                             {type: 'combo', name: 'secondary_naics_code_id', label: 'Secondary NAICS Code:',width: 160,options: secondary_naics_dropdown, position: 'absolute', inputLeft: 550, inputTop: 140, labelLeft: 375, labelTop: 140, labelWidth: 160},
                             {type: 'combo', name: 'organization_boundary_id', label: 'Organization Boundary:',width: 160,options: organization_boundary_dropdown, position: 'absolute', inputLeft: 180, inputTop: 180, labelLeft: 10, labelTop: 180, labelWidth: 160},
                             {type: 'checkbox', label: 'Sub Entity',name: 'sub_entity',position: 'label-right',offsetLeft: 375,offsetTop: 180},
                            ]"; 
    

     
    $book_tab = new AdihaTab();
    $tab_name = 'book_structure';               
    $json_tab = '[
                {
                    id:      "a1",
                    text:    "General",
                    width:   null,
                    index:   null,
                    active:  true,
                    enabled: true,
                    close:   false
                },
                {
                    id:      "a2",
                    text:    "Details",
                    width:   null,
                    index:   null,
                    active:  false,
                    enabled: true,
                    close:   false
                },
                {
                    id:      "a3",
                    text:    "GL Code Mapping",
                    width:   null,
                    index:   null,
                    active:  false,
                    enabled: true,
                    close:   false
                },
                {
                    id:      "a4",
                    text:    "Sub Entity Info",
                    width:   null,
                    index:   null,
                    active:  false,
                    enabled: true,
                    close:   false
                }
            ]';
        echo $subsidiary_book_layout->attach_tab_cell($tab_name, 'a', $json_tab);
        echo $book_tab->init_by_attach($tab_name,$form_namespace);
      
        /**
 * Attaching form in tab 
 */
        echo $book_tab->attach_form_new($tab_name, $form_name, 'a1', $general_form_structure, $form_namespace);
        echo $book_tab->attach_form_new($tab_name, $form_name, 'a2', $details_form_structure, $form_namespace);
        echo $book_tab->attach_form_new($tab_name, $form_name, 'a3', $gl_code_mapping_form_structure, $form_namespace);
        echo $book_tab->attach_form_new($tab_name, $form_name, 'a4', $sub_entity_form_structure, $form_namespace);
    
    echo $subsidiary_book_layout->close_layout();
?>
<script type="text/javascript">
    
</script>