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
    
    //$popup = new AdihaPopup();
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
 
    // Attaching Form
    $form_obj = new AdihaForm();
    
    //for general
    $sp_url_functional_currency = "EXEC spa_getfuncurrencysourceid '650'";
    echo "functional_currency_dropdown = ".  $form_obj->adiha_form_dropdown($sp_url_functional_currency, 1, 2) . ";"."\n";
    
    $sp_url_primary_counterparty = "EXEC spa_source_counterparty_maintain 't',NULL";
    echo "primary_counterparty_dropdown = ".  $form_obj->adiha_form_dropdown($sp_url_primary_counterparty, 0, 1) . ";"."\n";
    
    
      
       //for details tab
    echo "entity_type_value_dropdown = ". $form_obj->adiha_form_dropdown("EXEC spa_StaticDataValues 'h', '650'",0,1, false, '', 2) . ";"."\n";
    echo "discount_source_value_dropdown = ". $form_obj->adiha_form_dropdown("EXEC spa_StaticDataValues 'h', '100'",0,1, false, '', 2) . ";"."\n";
    echo "discount_type_value_dropdown = ". $form_obj->adiha_form_dropdown("EXEC spa_StaticDataValues 'h', '125'",0,1, false, '', 2) . ";"."\n";
    echo "risk_free_curve_dropdown = ". $form_obj->adiha_form_dropdown("EXEC spa_GetAllPriceCurveDefinitions NULL,NULL,NULL,'d' ",1,2) . ";"."\n";
    echo "discount_curve_dropdown = ". $form_obj->adiha_form_dropdown("EXEC spa_GetAllPriceCurveDefinitions NULL,NULL,NULL,'d' ",0,1) . ";"."\n";
    echo "time_zone_dropdown = ". $form_obj->adiha_form_dropdown("EXEC spa_time_zone 's' ",0,1) . ";"."\n";

    
    //for organization tab
     echo "state_value_dropdown = ". $form_obj->adiha_form_dropdown(" EXEC spa_StaticDataValues 'h', 10016 ",0,1, false, '', 2) . ";"."\n";
     echo "country_value_dropdown = ". $form_obj->adiha_form_dropdown(" EXEC spa_StaticDataValues 'h', 10077 ",0,1, false, '', 2) . ";"."\n";
     echo "primary_naics_dropdown = ". $form_obj->adiha_form_dropdown(" EXEC spa_StaticDataValues 'h', 10078",0,1, false, '', 2) . ";"."\n";
     echo "secondary_naics_dropdown = ". $form_obj->adiha_form_dropdown(" EXEC spa_StaticDataValues 'h', 10079",0,1, false, '', 2) . ";"."\n";
     echo "entity_category_dropdown = ". $form_obj->adiha_form_dropdown(" EXEC spa_StaticDataValues 'h', 1125",0,1, false, '', 2) . ";"."\n";
     echo "entity_sub_category_dropdown = ". $form_obj->adiha_form_dropdown(" EXEC spa_StaticDataValues 'h', 1150",0,1, false, '', 2) . ";"."\n"; 
     echo "utility_type_dropdown = ". $form_obj->adiha_form_dropdown(" EXEC spa_StaticDataValues 'h', 1175",0,1, false, '', 2) . ";"."\n"; 
     echo "contract_dropdown = ". $form_obj->adiha_form_dropdown(" EXEC spa_get_user_name",0,1) . ";"."\n"; 
     
     
     //for Program Affilation Tab     
     echo "base_year_from_dropdown = ". $form_obj->adiha_form_dropdown(" EXEC spa_compliance_year ",0,1) . ";"."\n";
     echo "organization_boundaries_dropdown = ". $form_obj->adiha_form_dropdown(" EXEC spa_StaticDataValues 'h', 1100 ",0,1, false, '', 2) . ";"."\n";
    
    $general_form_structure = "[
                            
                            {type: 'input', name: 'fas_subsidiary_id', label: 'Name:',width: 160, position: 'absolute', inputLeft: 180, inputTop: 20, labelLeft: 10, labelTop: 20, labelWidth: 160,required: true},
                            {type: 'combo', name: 'func_cur_value_id', label: 'Functional Currency:',width: 160,options: functional_currency_dropdown, position: 'absolute', inputLeft: 180, inputTop: 60, labelLeft: 10, labelTop: 60, labelWidth: 160},
                            {type: 'combo', name: 'counterparty_id', label: 'Primary Counterparty:',width: 160,options: primary_counterparty_dropdown, position: 'absolute', inputLeft: 180, inputTop: 100, labelLeft: 10, labelTop: 100, labelWidth: 160}
                            ]";  
                            
      $details_form_structure = "[                          
                            
                            {type: 'combo', name: 'entity_type_value_id', label: 'Entity Type:',width: 160,options: entity_type_value_dropdown, position: 'absolute', inputLeft: 180, inputTop: 60, labelLeft: 10, labelTop: 60, labelWidth: 160},
                            {type: 'combo', name: 'disc_source_value_id', label: 'Source Of Disc Values:',width: 160,options: discount_source_value_dropdown, position: 'absolute', inputLeft: 180, inputTop: 100, labelLeft: 10, labelTop: 100, labelWidth: 160},
                            {type: 'combo', name: 'disc_type_value_id', label: 'Discount Type:',width: 160,options: discount_type_value_dropdown, position: 'absolute', inputLeft: 180, inputTop: 140, labelLeft: 10, labelTop: 140, labelWidth: 160},
                            {type: 'combo', name: 'risk_free_curve_id', label: 'Risk Free Interest Rate Curve:',width: 160,options: risk_free_curve_dropdown, position: 'absolute', inputLeft: 180, inputTop: 180, labelLeft: 10, labelTop: 180, labelWidth: 160},
                            {type: 'combo', name: 'discount_curve_id', label: 'Discount Rate /Curve:',width: 160,options: discount_curve_dropdown, position: 'absolute', inputLeft: 180, inputTop: 220, labelLeft: 10, labelTop: 220, labelWidth: 160},
                            {type: 'input', name: 'days_in_year', label: 'Discount Parameter (day/year):',width: 160, position: 'absolute', inputLeft: 180, inputTop: 260, labelLeft: 10, labelTop: 260, labelWidth: 160},
                            {type: 'input', name: 'long_term_months', label: 'Long-Term Months:',width: 160, position: 'absolute', inputLeft: 180, inputTop: 300, labelLeft: 10, labelTop: 300, labelWidth: 160},
                            {type: 'input', name: 'tax_perc', label: 'Tax Percentage:',width: 160, position: 'absolute', inputLeft: 180, inputTop: 340, labelLeft: 10, labelTop: 340, labelWidth: 160},
                            {type: 'combo', name: 'timezone_id', label: 'Time Zone:',width: 160,options: time_zone_dropdown, position: 'absolute', inputLeft: 180, inputTop: 380, labelLeft: 10, labelTop: 380, labelWidth: 160}
                            ]";
                            

    $organization_form_structure = "[                          
                            {type: 'input', name: 'entity_name', label: 'Entity Name:',width: 160, position: 'absolute', inputLeft: 180, inputTop: 40, labelLeft: 10, labelTop: 40, labelWidth: 160},
                            {type: 'combo', name: 'primary_naics_code_id', label: 'Primary NAICS Code:',width: 160,options: primary_naics_dropdown, position: 'absolute', inputLeft: 550, inputTop: 40, labelLeft: 375, labelTop: 40, labelWidth: 160},
                            {type: 'input', name: 'address1', label: 'Address 1:',width: 160, position: 'absolute', inputLeft: 180, inputTop: 80, labelLeft: 10, labelTop: 80, labelWidth: 160},
                            {type: 'combo', name: 'secondary_naics_code_id', label: 'Secondary NAICS Code:',width: 160,options: secondary_naics_dropdown, position: 'absolute', inputLeft: 550, inputTop: 80, labelLeft: 375, labelTop: 80, labelWidth: 160},
                            {type: 'input', name: 'address2', label: 'Address2',width: 160, position: 'absolute', inputLeft: 180, inputTop: 120, labelLeft: 10, labelTop: 120, labelWidth: 160},
                            {type: 'combo', name: 'entity_catagory_id', label: 'Entity Category:',width: 160,options: entity_category_dropdown, position: 'absolute', inputLeft: 550, inputTop: 120, labelLeft: 375, labelTop: 120, labelWidth: 160},
                            {type: 'input', name: 'city', label: 'City:',width: 160, position: 'absolute', inputLeft: 180, inputTop: 160, labelLeft: 10, labelTop: 160, labelWidth: 160},
                            {type: 'combo', name: 'entity_sub_catagory_id', label: 'Entity Sub Category:',width: 160,options: entity_sub_category_dropdown, position: 'absolute', inputLeft: 550, inputTop: 160, labelLeft: 375, labelTop: 160, labelWidth: 160},
                            {type: 'combo', name: 'state_value_id', label: 'State:',width: 160,options: state_value_dropdown, position: 'absolute', inputLeft: 180, inputTop: 200, labelLeft: 10, labelTop: 200, labelWidth: 160},
                            {type: 'combo', name: 'utility_type_id', label: 'Utility Type:',width: 160,options: utility_type_dropdown, position: 'absolute', inputLeft: 550, inputTop: 200, labelLeft: 375, labelTop: 200, labelWidth: 160},
                            {type: 'input', name: 'zip_code', label: 'Zip:',width: 160, position: 'absolute', inputLeft: 180, inputTop: 240, labelLeft: 10, labelTop: 240, labelWidth: 160},
                            {type: 'input', name: 'ticker_symbol_id', label: 'Publicity Traded Ticker Symbol:',width: 160, position: 'absolute', inputLeft: 550, inputTop: 240, labelLeft: 375, labelTop: 240, labelWidth: 160},
                            {type: 'combo', name: 'country_value_id', label: 'Country:',width: 160,options: country_value_dropdown, position: 'absolute', inputLeft: 180, inputTop: 280, labelLeft: 10, labelTop: 280, labelWidth: 160},
                            {type: 'input', name: 'entity_url', label: 'Entity URL:',width: 160, position: 'absolute', inputLeft: 550, inputTop: 280, labelLeft: 375, labelTop: 280, labelWidth: 160},
                            {type: 'input', name: 'tax_payer_id', label: 'Entity Tax Payer ID:',width: 160, position: 'absolute', inputLeft: 180, inputTop: 320, labelLeft: 10, labelTop: 320, labelWidth: 160},
                            {type: 'combo', name: 'contact_user_id', label: 'Contract:',width: 160,options: contract_dropdown, position: 'absolute', inputLeft: 550, inputTop: 320, labelLeft: 375, labelTop: 320, labelWidth: 160},
                            {type: 'block', width: 900,blockOffset:10,offsetTop :360, list:[
                            {type: 'label', label: 'Ownership Status:'},
                            {type: 'radio', name: 'ownership_staus', value: 1, label: 'Wholly Owned Subsidiary',position:'label-right',offsetLeft: 10},
                            {type: 'radio', name: 'ownership_staus', value: 2, label: 'Joint Venture',position:'label-right',offsetLeft: 10},
                            {type: 'radio', name: 'ownership_staus', value: 3, label: 'Other Subsidiary',position:'label-right',offsetLeft: 10}
                            ]},
                            {type: 'input', name: 'partners', label: 'Partners:',rows:3,rows:3,width: 160, style:'width:160px;height:100px;', position: 'absolute', inputLeft: 550, inputTop: 360, labelLeft: 375, labelTop: 360, labelWidth: 160,disabled: 1}
                            ]";
                            
                            
    $program_affilation_form_structure = "[                          
                            
                            {type: 'combo', name: 'base_year_from', label: 'Base Year From:',width: 160,options: base_year_from_dropdown, position: 'absolute', inputLeft: 180, inputTop: 20, labelLeft: 10, labelTop: 20, labelWidth: 160},
                            {type: 'combo', name: 'base_year_to', label: 'Base Year To:',width: 160,options: base_year_from_dropdown, position: 'absolute', inputLeft: 550, inputTop: 20, labelLeft: 375, labelTop: 20, labelWidth: 160},
                            {type: 'combo', name: 'organization_boundaries', label: 'Organization Boundaries:',width: 160,options: organization_boundaries_dropdown, position: 'absolute', inputLeft: 180, inputTop: 60, labelLeft: 10, labelTop: 60, labelWidth: 160},
                            {type: 'checkbox', label: 'Confidentiality Information',name: 'confidentiality_info',position: 'label-right',offsetLeft: 375,offsetTop: 60},
                            {type: 'checkbox', label: 'Exclude Indirect Emissions',name: 'exclude_indirect_emissions',position: 'label-right',offsetLeft: 375,offsetTop: 10},
                            {type: 'block', width: 900,list:[
                            {type: 'label', label: 'Holding Company:'},
                            {type: 'radio', name: 'holding_company', value: 1, label: 'Yes',position:'label-right',offsetLeft: 10},
                            {type: 'radio', name: 'holding_company', value: 2, label: 'No',position:'label-right',offsetLeft: 10}
                            ]}
                            
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
                    text:    "Organization",
                    width:   null,
                    index:   null,
                    active:  false,
                    enabled: true,
                    close:   false
                },
                {
                    id:      "a4",
                    text:    "Program Affilation",
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
            echo $book_tab->attach_form_new($tab_name, $form_name, 'a3', $organization_form_structure, $form_namespace);
            //echo $book_tab->attach_form_new($tab_name, $form_name, 'a4', $program_affilation_form_structure, $form_namespace);
            
            
 
            echo $book_tab->attach_layout('inner_layout', 'a4','2E');
            $tab_layout = new AdihaLayout();
            echo $tab_layout->init_by_attach('inner_layout', $form_namespace);
            
            
            
            $form = 'affilation_form';
            echo $tab_layout->attach_form($form , 'a');
            $form_object = new AdihaForm();
            echo $form_object->init_by_attach($form, $form_namespace);
            echo $form_object->load_form($program_affilation_form_structure);

            $affilation_toolbar = new AdihaToolbar();
            $toolbar_name =  'affilation_toolbar';
            $toolbar_json = '[
                               { id: "add", type: "button", img: "new.gif", text:"Add", title: "Add"},
                                    { type: "separator" },
                                    { id: "delete", type: "button", img: "trash.gif", text: "Delete", title: "Delete"}
                             
                             ]';
                         
            echo $tab_layout->attach_toolbar_cell($toolbar_name, 'b'); 
            echo $affilation_toolbar-> init_by_attach($toolbar_name, $form_namespace);
            echo $affilation_toolbar-> load_toolbar($toolbar_json);
            

            
            $grid_name='affilation_grid';
            echo $tab_layout->attach_grid_cell($grid_name, 'b');
            $affilation_grid_grid_obj = new AdihaGrid();
            $sp_url = "EXEC spa_program_affiliations @flag='s'";                    
            echo $affilation_grid_grid_obj->init_by_attach($grid_name, $form_namespace); 
            echo $affilation_grid_grid_obj->set_header('Affilation Type,Affilation Value');
            echo $affilation_grid_grid_obj->set_widths('*');
            echo $affilation_grid_grid_obj->set_column_alignment('left,left');
            echo $affilation_grid_grid_obj->set_column_types('ed,ed');
            // echo $affilation_grid_grid_obj->set_columns_ids('formula_id,formula_name,formula,formula_c,formula_type');
            echo $affilation_grid_grid_obj->return_init();
            echo $affilation_grid_grid_obj->load_grid_data($sp_url, '');

            
//die();

            echo $subsidiary_book_layout->close_layout();
?>
<!-- subsidiary Summary Template -->


<script type="text/javascript">


</script>

 