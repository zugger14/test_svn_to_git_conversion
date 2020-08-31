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
    $sp_url_functional_currency = "EXEC spa_getfuncurrencysourceid '650'";
    echo "functional_currency_dropdown = ".  $form_obj->adiha_form_dropdown($sp_url_functional_currency, 1, 2) . ";"."\n";
    
     echo "accounting_type_dropdown = ". $form_obj->adiha_form_dropdown("EXEC spa_StaticDataValues 'h', '150'",0,1, false, '', 2) . ";"."\n";
    
    
    
       //for details tab
    echo "cost_approach_dropdown = ". $form_obj->adiha_form_dropdown("EXEC spa_StaticDataValues 'h', '950'",0,1, false, '', 2) . ";"."\n";
    echo "legal_entity_dropdown = ". $form_obj->adiha_form_dropdown("EXEC spa_source_legal_entity_maintain 's'",0,1) . ";"."\n";
    echo "convert_uom_dropdown = ". $form_obj->adiha_form_dropdown("EXEC spa_getsourceuom 's'",0,1) . ";"."\n";
    echo "roll_out_type_dropdown = ". $form_obj->adiha_form_dropdown("EXEC spa_StaticDataValues 'h', '520'",0,1, false, '', 2) . ";"."\n";
    echo "measurement_value_dropdown = ". $form_obj->adiha_form_dropdown("EXEC spa_StaticDataValues 'h', '200'",0,1, false, '', 2) . ";"."\n";
    echo "strip_transactions_dropdown = ". $form_obj->adiha_form_dropdown("EXEC spa_StaticDataValues 'h', '625'",0,1, false, '', 2) . ";"."\n";
    echo "exclude_values_dropdown = ". $form_obj->adiha_form_dropdown("EXEC spa_StaticDataValues 'h', '225'",0,1, false, '', 2) . ";"."\n";
    echo "oci_rollout_dropdown = ". $form_obj->adiha_form_dropdown("EXEC spa_StaticDataValues 'h', '500'",0,1, false, '', 2) . ";"."\n";
    echo "tenor_option_dropdown = ". $form_obj->adiha_form_dropdown("EXEC spa_StaticDataValues 'h', '500'",0,1, false, '', 2) . ";"."\n";
    
     
     //for gl code mapping     
     echo "hedge_st_asset_dropdown = ". $form_obj->adiha_form_dropdown("EXEC spa_gl_code_mapping 's', '150'",1,2) . ";"."\n";
     
    
    $general_form_structure = "[
                            
                            {type: 'input', name: 'fas_subsidiary_id', label: 'Name:',width: 160, position: 'absolute', inputLeft: 180, inputTop: 60, labelLeft: 10, labelTop: 60, labelWidth: 160,required: true},
                            {type: 'combo', name: 'func_cur_value_id', label: 'Functional Currency:',width: 160,options: functional_currency_dropdown, position: 'absolute', inputLeft: 180, inputTop: 100, labelLeft: 10, labelTop: 100, labelWidth: 160},
                            {type: 'combo', name: 'accounting_type', label: 'Accounting Type:',width: 160,options: accounting_type_dropdown, position: 'absolute', inputLeft: 180, inputTop: 140, labelLeft: 10, labelTop: 140, labelWidth: 160}
                            ]";  
                            
      $details_form_structure = "[                          
                            
                            {type: 'input', name: 'no_links_fas_eff_test_profile_id', label: 'No Link Relationship Type:',width: 160, position: 'absolute', inputLeft: 180, inputTop: 20, labelLeft: 10, labelTop: 20, labelWidth: 160},
                            {type: 'button', name: 'btn_clear', value: '...', position: 'absolute', inputLeft: 350, inputTop: 20},
                            {type: 'combo', name: 'cost_approach_id', label: 'Cash Approach:',width: 160,options: cost_approach_dropdown, position: 'absolute', inputLeft: 180, inputTop: 60, labelLeft: 10, labelTop: 60, labelWidth: 160},
                            {type: 'combo', name: 'legal_entity', label: 'Legal Entity:',width: 160,options: legal_entity_dropdown, position: 'absolute', inputLeft: 550, inputTop: 60, labelLeft: 375, labelTop: 60, labelWidth: 160},
                            {type: 'combo', name: 'convert_uom_id', label: 'Convert UOM:',width: 160,options: convert_uom_dropdown, position: 'absolute', inputLeft: 180, inputTop: 100, labelLeft: 10, labelTop: 100, labelWidth: 160},
                            {type: 'input', name: 'tax_perc', label: 'Tax Percentage:',width: 160,position: 'absolute', inputLeft: 550, inputTop: 100, labelLeft: 375, labelTop: 100, labelWidth: 160},
                            {type: 'checkbox', name: 'no_link', label: 'Hypothetical',width: 160, position: 'label-right',offsetTop:140,offsetLeft:10},  
                            {type: 'newcolumn', offset:20},
                            {type: 'checkbox', name: 'hedge_item_same_sign', label: 'Hedge And Item Same Sign',width: 160, position: 'label-right',offsetTop:140,offsetLeft:250}
                          
                             ]";
                            

    $gl_code_form_structure = "[                          
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
                }
            ]';
        echo $subsidiary_book_layout->attach_tab_cell($tab_name, 'a', $json_tab);
        echo $book_tab->init_by_attach($tab_name,$form_namespace);
      
        /**
 * Attaching form in tab 
 */
        echo $book_tab->attach_form_new($tab_name, $form_name, 'a1', $general_form_structure, $form_namespace);
        echo $book_tab->attach_form_new($tab_name, $form_name, 'a2', $details_form_structure, $form_namespace);
        echo $book_tab->attach_form_new($tab_name, $form_name, 'a3', $gl_code_form_structure, $form_namespace);
       
    
    echo $subsidiary_book_layout->close_layout();
?>
<script type="text/javascript">
    
</script>