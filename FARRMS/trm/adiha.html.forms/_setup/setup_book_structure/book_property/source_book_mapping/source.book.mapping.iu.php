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
    include '../../../../../adiha.php.scripts/components/include.file.v3.php';
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
    
  
       //for tagging tab
    echo "tag1_dropdown = ". $form_obj->adiha_form_dropdown("EXEC spa_getsourcebookmappingGroups 's', '50'",0,1) . ";"."\n";
    echo "tag2_dropdown = ". $form_obj->adiha_form_dropdown("EXEC spa_getsourcebookmappingGroups 's', '51'",0,1) . ";"."\n";
    echo "tag3_dropdown = ". $form_obj->adiha_form_dropdown("EXEC spa_getsourcebookmappingGroups 's', '52'",0,1) . ";"."\n";
    echo "tag4_dropdown = ". $form_obj->adiha_form_dropdown("EXEC spa_getsourcebookmappingGroups 's', '53'",0,1) . ";"."\n";
    echo "fas_deal_type_dropdown = ". $form_obj->adiha_form_dropdown(" EXEC spa_StaticDataValues 'h', 400",0,1, false, '', 2) . ";"."\n";
    echo "fas_deal_sub_type_dropdown = ". $form_obj->adiha_form_dropdown("EXEC spa_StaticDataValues 'h', 1225 ",0,1, false, '', 2) . ";"."\n";
        
     //for gl code mapping Tab     
    echo "hedge_st_asset_dropdown = ". $form_obj->adiha_form_dropdown("EXEC spa_gl_code_mapping 's', '150'",1,2) . ";"."\n";
    
    $general_form_structure = "[
                            
                            {type: 'input', name: 'logical_name', label: 'Logical Name:',width: 160, position: 'absolute', inputLeft: 180, inputTop: 80, labelLeft: 10, labelTop: 80, labelWidth: 160,required: true},
                             ]";  
                            
      $tagging_form_structure = "[                          
                            
                            {type: 'combo', name: 'source_system_book_id1', label: 'Tag 1:',width: 160,options: tag1_dropdown, position: 'absolute', inputLeft: 180, inputTop: 20, labelLeft: 10, labelTop: 20, labelWidth: 160},
                            {type: 'combo', name: 'source_system_book_id2', label: 'Tag 2:',width: 160,options: tag2_dropdown, position: 'absolute', inputLeft: 550, inputTop: 20, labelLeft: 375, labelTop: 20, labelWidth: 160},
                            {type: 'combo', name: 'source_system_book_id3', label: 'Tag 3:',width: 160,options: tag3_dropdown, position: 'absolute', inputLeft: 180, inputTop: 60, labelLeft: 10, labelTop: 60, labelWidth: 160},
                            {type: 'combo', name: 'source_system_book_id4', label: 'Tag 4:',width: 160,options: tag4_dropdown, position: 'absolute', inputLeft: 550, inputTop: 60, labelLeft: 375, labelTop: 60, labelWidth: 160},
                            {type: 'combo', name: 'fas_deal_type_value_id', label: 'Transaction Type:',width: 160,options: fas_deal_type_dropdown, position: 'absolute', inputLeft: 180, inputTop: 100, labelLeft: 10, labelTop: 100, labelWidth: 160},
                            {type: 'combo', name: 'fas_deal_sub_type_value_id', label: 'Transaction Sub Type:',width: 160,options: fas_deal_sub_type_dropdown, position: 'absolute', inputLeft: 550, inputTop: 100, labelLeft: 375, labelTop: 100, labelWidth: 160},  
                            {type:'calendar', dateFormat:'%Y-%m-%d ', name:'effective_start_date', label:'Effective Date',position: 'absolute',className:'my_calendar',readonly:true,inputLeft: 180, inputTop: 140, labelLeft: 10,labelTop: 140, labelWidth: 160,inputWidth: 160},
                            {type:'calendar', dateFormat:'%Y-%m-%d ', name:'end_date', label:'End Date',position: 'absolute',className:'my_calendar',readonly:true,inputLeft: 550, inputTop: 140, labelLeft: 375,labelTop: 140, labelWidth: 160,inputWidth: 160},                            
                            {type: 'input', name: 'percentage_included', label: 'Percentage Included:',width: 160, position: 'absolute', inputLeft: 180, inputTop: 180, labelLeft: 5, labelTop: 180, labelWidth: 160}
                            
                            ]";
                            

    $reporting_form_structure = "[                          
                            {type: 'combo', name: 'source_system_book_id1', label: 'Tag 1:',width: 160,options: tag1_dropdown, position: 'absolute', inputLeft: 180, inputTop: 20, labelLeft: 10, labelTop: 20, labelWidth: 160},
                            {type: 'combo', name: 'source_system_book_id2', label: 'Tag 2:',width: 160,options: tag2_dropdown, position: 'absolute', inputLeft: 550, inputTop: 20, labelLeft: 375, labelTop: 20, labelWidth: 160},
                            {type: 'combo', name: 'source_system_book_id3', label: 'Tag 3:',width: 160,options: tag3_dropdown, position: 'absolute', inputLeft: 180, inputTop: 60, labelLeft: 10, labelTop: 60, labelWidth: 160},
                            {type: 'combo', name: 'source_system_book_id4', label: 'Tag 4:',width: 160,options: tag4_dropdown, position: 'absolute', inputLeft: 550, inputTop: 60, labelLeft: 375, labelTop: 60, labelWidth: 160}, ]";
                            
                            
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
                    text:    "Tagging",
                    width:   null,
                    index:   null,
                    active:  false,
                    enabled: true,
                    close:   false
                },
                {
                    id:      "a3",
                    text:    "Reporting",
                    width:   null,
                    index:   null,
                    active:  false,
                    enabled: true,
                    close:   false
                },
                {
                    id:      "a4",
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
        echo $book_tab->attach_form_new($tab_name, $form_name, 'a2', $tagging_form_structure, $form_namespace);
        echo $book_tab->attach_form_new($tab_name, $form_name, 'a3', $reporting_form_structure, $form_namespace);
        echo $book_tab->attach_form_new($tab_name, $form_name, 'a4', $gl_code_form_structure, $form_namespace);
    
    echo $subsidiary_book_layout->close_layout();
?>
<script type="text/javascript">
    
</script>