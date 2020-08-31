<?php
/**
 * Screen to show the detail result (drilldown details) of the search located in the main screen nav bar. 
 * @copyright Pioneer Solutions
 */
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />

    <style type="text/css">
        p.record {
            font-family:verdana;
            font-size:12px; 
            color:#000000;
            font-weight: 400;
            vertical-align: top;
            text-decoration: none;
            margin-top: 3px;
            margin-bottom: 0px;
            margin-left: 0px;
        }
        a.thick {
            font-family:verdana;
            font-size:14px; 
            color:#0033CC;
            font-weight: 500;
            vertical-align: top;
            text-decoration: underline;
            cursor: pointer;
        }

        .highlight {
           font-weight: bold;
           background-color: yellow;
        }

        .attachment_list_link {
            text-decoration: underline;
            cursor: pointer;
            color: blue;
        }

    </style>
    <?php  
        require_once('components/include.file.v3.php'); 
        require_once('components/include.ssrs.reporting.files.php');
        $search_text = (isset($_GET["search_text"]) && $_GET["search_text"] != '') ? $_GET["search_text"] : '';
        $search_objects = (isset($_GET["search_objects"]) && $_GET["search_objects"] != '') ? $_GET["search_objects"] : '';
        $search_text = str_replace("^", "''''", $search_text);

        $form_namespace = 'searchResultDetail';
        $layout_json = '[{id: "a", header:false}]';
        $layout_obj = new AdihaLayout();
        $tab_obj = new AdihaTab();

        // init layout
        echo $layout_obj->init_layout('search_result_detail', '', '1C', $layout_json, $form_namespace);
        echo $layout_obj->attach_tab_cell('result_tabs', 'a', '');
        echo $tab_obj->init_by_attach('result_tabs', $form_namespace);
        echo $tab_obj->add_tab('top_results', 'Top Results', 'null', 'null', 'true');

        $form_data = array();

        //EXEC spa_search_engine  @flag='s', @searchString='gas', @callFrom='s'
        $search_objects = ($search_objects == '') ? 'NULL' : "'" . $search_objects . "'";
        $search_string = "EXEC spa_search_engine  @flag='s', @searchString='" . $search_text . "', @searchTables=" . $search_objects . ",    @callFrom='s'";
        $form_data = readXMLURL2($search_string);

        $top_result_data = '';
        $counterparty_tab_created = false;
        $credit_info_tab_created = false;
        $incident_tab_created = false;
        
        if (is_array($form_data) && sizeof($form_data) > 0) {
            $i = 0;
            foreach ($form_data as $data) {
                if ($data['object_id'] == 'master_deal_view') {
                    echo $tab_obj->add_tab($data['object_id'], $data['object_name']);
                    $deal_layout = new AdihaLayout();
                    echo $tab_obj->attach_layout('deal_layout', 'master_deal_view', '1C');
                    $deal_layout->init_by_attach('deal_layout', $form_namespace);
                    echo $deal_layout->hide_header('a');
                    
                    $search_result_deal = new AdihaGrid();
                    echo $deal_layout->attach_grid_cell('search_result_deal', 'a');
                    echo $search_result_deal->init_by_attach('search_result_deal', $form_namespace);
                    echo $search_result_deal->set_header("SN., ID, Deal ID,Deal Date,External Deal ID,Physical/\Financial,Structured Deal ID,Counterparty,Parent Counterparty,Entire Term Start,Entire Term End, Deal Type, Deal Sub Type,Option Flag,Option Type,Option Exercise Type,Source System Book ID1,Source System Book ID2,Source System Book ID3,Source System Book ID4,Subsidiary,Strategy,Book,Description1,Description2,Description3,Deal Category,Trader,Internal Deal Type,Internal Deal Sub Type,Template,Broker,Generator,Deal Status Date,Assignment Type,Compliance Year,State Value,Assigned Date,Assigned User,Contract,Create User,Create TS,Update User,Update TS,Legal Entity,Deal Profile,Fixation Type,Internal Portfolio,Commodity,Reference,Locked Deal,Close Reference ID,Block Type,Block Definition,Granularity,Pricing,Deal Reference Type,Deal Status,Confirm Status Type,Term Start,Term End,Contract Expiration Date,Fixed/\Float,Buy/\Sell,Index Name,Index Commodity,Index Currency,Index UOM,Index Proxy1,Index Proxy2,Index Proxy3,Index Settlement,Expiration Calendar,Deal Formula,Location,Location Region,Location Grid,Location Country,Location Group,Forecast Profile,Forecast Proxy Profile,Profile Type,Proxy Profile Type,Meter,Profile Code,PR Party,UDF,Deal Date,Entire Term Start,Entire Term End,Inco Terms,Detail Inco Terms,Trader2,Counterparty2,Origin,Form,Organic,Attribute1,Attribute2,Attribute3,Attribute4,Attribute5,Counterparty2 Trader,Counterparty Trader,Buyer Seller Option,Crop Year,Product Description");
                    echo $search_result_deal->set_columns_ids("SNO,source_deal_header_id,deal_id,deal_date,ext_deal_id,physical_financial,structured_deal_id,counterparty,parent_counterparty,entire_term_start,entire_term_end,deal_type,deal_sub_type,option_flag,option_type,option_excercise_type,source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4,subsidiary,strategy,Book,description1,description2,description3,deal_category,trader,internal_deal_type,internal_deal_subtype,template,broker,generator,deal_status_date,assignment_type,compliance_year,state_value,assigned_date,assigned_user,CONTRACT,create_user,create_ts,update_user,update_ts,legal_entity,deal_profile,fixation_type,internal_portfolio,commodity,reference,locked_deal,close_reference_id,block_type,block_definition,granularity,pricing,deal_reference_type,deal_status,confirm_status_type,term_start,term_end,contract_expiration_date,fixed_float,buy_sell,index_name,index_commodity,index_currency,index_uom,index_proxy1,index_proxy2,index_proxy3,index_settlement,expiration_calendar,deal_formula,location,location_region,location_grid,location_country,location_group,forecast_profile,forecast_proxy_profile,profile_type,proxy_profile_type,meter,profile_code,Pr_party,UDF,deal_date_varchar,entire_term_start_varchar,entire_term_end_varchar,inco_terms,detail_inco_terms,trader2,counterparty2,origin,form,organic,attribute1,attribute2,attribute3,attribute4,attribute5,counterparty2_trader,counterparty_trader,buyer_seller_option,crop_year,product_description");
                    echo $search_result_deal->set_widths("125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125,125");
                    echo $search_result_deal->set_column_types("ro_int,ro,ro,dhxCalendar,ro,ro,ro,ro,ro,dhxCalendar,dhxCalendar,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,dhxCalendar,ro,ro,ro,dhxCalendar,ro,ro,ro,dhxCalendar,ro,dhxCalendar,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,dhxCalendar,dhxCalendar,dhxCalendar,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,dhxCalendar,dhxCalendar,dhxCalendar,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro");
                    echo $search_result_deal->set_sorting_preference("int,int,str,date,int,str,str,str,str,date,date,str,str,str,str,str,int,int,int,int,str,str,str,str,str,str,str,str,str,str,str,str,str,date,str,str,str,date,str,str,str,date,str,date,str,str,str,str,str,str,str,str,str,str,str,str,str,str,str,date,date,date,str,str,str,str,str,str,str,str,str,str,str,str,str,str,str,str,str,str,str,str,str,str,str,str,str,date,date,date,str,str,str,str,str,str,str,str,str,str,str,str,str,str,str,str,str");
                    echo $search_result_deal->set_date_format($date_format, '%Y-%m-%d');
                    echo $search_result_deal->set_search_filter(false,"#numeric_filter,#numeric_filter,#text_filter,#daterange_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#daterange_filter,#daterange_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#daterange_filter,#text_filter,#text_filter,#text_filter,#daterange_filter,#text_filter,#text_filter,#text_filter,#daterange_filter,#text_filter,#daterange_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#daterange_filter,#daterange_filter,#daterange_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter");
                    echo $search_result_deal->return_init();
                    echo $search_result_deal->attach_event('', 'onRowDblClicked', $form_namespace . '.open_deal_summary_report');
                    echo $search_result_deal->split_grid(3);
                    $sql = "EXEC spa_search_engine @flag='r', @process_table='" . $data['detail_table'] . "'";
                    echo $search_result_deal->load_grid_data($sql,'g','',false, $form_namespace . '.fx_deal_grid_load');
                } else if(($data['object_id'] == 'source_counterparty' || $data['object_id'] == 'counterparty_bank_info'
                    || $data['object_id'] == 'VW_counterparty_certificate' || $data['object_id'] == 'master_view_counterparty_products'
                    || $data['object_id'] == 'master_view_counterparty_contacts' || $data['object_id'] == 'master_view_counterparty_contract_address'
                    || $data['object_id'] ==  'master_view_counterparty_epa_account') && !$counterparty_tab_created
                ) {
                    $counterparty_tab_created = true;
                    echo $tab_obj->add_tab('source_counterparty', 'Counterparty');
                    $cpty_layout = new AdihaLayout();
                    echo $tab_obj->attach_layout('cpty_layout', 'source_counterparty', '1C');
                    $cpty_layout->init_by_attach('cpty_layout', $form_namespace);
                    echo $cpty_layout->hide_header('a');
                    
                    $search_result_cpty = new AdihaGrid();
                    echo $cpty_layout->attach_grid_cell('search_result_cpty', 'a');
                    echo $search_result_cpty->init_by_attach('search_result_cpty', $form_namespace);
                    echo $search_result_cpty->set_header("SN.,ID,CounterpartyID,CounterpartyName,Description");
                    echo $search_result_cpty->set_columns_ids("SNo,source_counterparty_id,counterparty_id,counterparty_name,counterparty_description");                    
                    echo $search_result_cpty->set_widths("*,*,*,*,*");
                    echo $search_result_cpty->set_column_types("ro_int,link,ro,ro,ro");
                    echo $search_result_cpty->set_sorting_preference("int,str,str,str,str");
                    echo $search_result_cpty->set_search_filter(false,"#numeric_filter,#text_filter,#text_filter,#text_filter,#text_filter");
                    echo $search_result_cpty->return_init();
                    $sql = "EXEC spa_search_engine @flag='z', @process_table='" . $data['detail_table'] . "'";
                    echo $search_result_cpty->load_grid_data($sql,'g','',false, $form_namespace . '.fx_cpty_grid_load');
                } else if($data['object_id'] == 'application_notes') {
                    echo $tab_obj->add_tab($data['object_id'], $data['object_name']);
                    $doc_layout = new AdihaLayout();
                    echo $tab_obj->attach_layout('doc_layout', 'application_notes', '1C');
                    $doc_layout->init_by_attach('doc_layout', $form_namespace);
                    echo $doc_layout->hide_header('a');
                     
                    $search_result_doc = new AdihaGrid();
                    
                    echo $doc_layout->attach_grid_cell('search_result_doc', 'a');
                    echo $search_result_doc->init_by_attach('search_result_doc', $form_namespace);
                    
                    echo $search_result_doc->load_grid_functions();
                    
                    echo $search_result_doc->set_header("Subject,File Name,Object ID,User Category,URL,Created Date,Created By,File Name,Notes Share Email Enable, Notes ID,Sub Category ID,Category ID, Notes Object ID");
                    echo $search_result_doc->set_columns_ids("notes_subject,notes_attachment,parent_object_id,user_category,url,create_ts,create_user,attachment_file_name,notes_share_email_enable,notes_id,sub_category_id,category_id,notes_object_id");
                    echo $search_result_doc->set_sorting_preference("str,str,int,str,str,date,str,str,str,str,int,int,int");
                    echo $search_result_doc->set_widths("200,350,200,200,300,150,150,150,150,150,150,150,150");
                    echo $search_result_doc->set_column_types("tree,link,link,ro,link,dhxCalendar,ro,ro,ro,ro,ro,ro,ro");
                    echo $search_result_doc->set_column_visibility('false,false,false,false,false,false,false,true,true,true,true,true,true');
                    echo $search_result_doc->set_search_filter(false,"#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#daterange_filter,#text_filter,#text_filter,#text_filter,#numeric_filter,#numeric_filter,#numeric_filter,#numeric_filter");
                    echo $search_result_doc->return_init();
                    $sql = "EXEC spa_application_notes @flag='g', @search_result_table='" . $data['detail_table'] . "',@call_from='search'";
                    $group_by = 'category,sub_category,notes_subject';
                    echo $search_result_doc->load_grid_data($sql, 'tg', $group_by, false, $form_namespace . '.fx_doc_grid_load');
                    echo $search_result_doc->attach_event('', 'onMouseOver', $form_namespace . '.fx_doc_grid_event_onmouseover');
                    echo $search_result_doc->attach_event('', 'onRowDblClicked', $form_namespace . '.fx_doc_grid_event_dbclick');
                } else if($data['object_id'] == 'email_notes') {
                    echo $tab_obj->add_tab($data['object_id'], $data['object_name']);
                    $email_layout = new AdihaLayout();
                    echo $tab_obj->attach_layout('email_layout', 'email_notes', '1C');
                    $email_layout->init_by_attach('email_layout', $form_namespace);
                    echo $email_layout->hide_header('a');
                    
                    $search_result_email = new AdihaGrid();
                    
                    echo $email_layout->attach_grid_cell('search_result_email', 'a');
                    echo $search_result_email->init_by_attach('search_result_email', $form_namespace);
                    
                    echo $search_result_email->load_grid_functions();
                    
                    echo $search_result_email->set_header("Notes ID,From,To,Subject,Date,Attachment,User Category,Email Type,Mapped Object");
                    echo $search_result_email->set_columns_ids("notes_id,send_from,send_to,subject,date,attachment,user_category,email_type,mapped_object");
                    echo $search_result_email->set_sorting_preference("int,str,str,str,date,str,str,str,int");
                    echo $search_result_email->set_widths("20,250,250,300,150,200,200,100,180");
                    echo $search_result_email->set_column_types("ro,ro,ro,ro,dhxCalendar,link,ro,ro,link");
                    
                    echo $search_result_email->set_column_visibility('true,false,false,false,false,false,false,true,false');
                    echo $search_result_email->set_search_filter(false, "#numeric_filter,#text_filter,#text_filter,#text_filter,#daterange_filter,#text_filter,#text_filter,#text_filter,#text_filter");
                    echo $search_result_email->return_init();
                    $sql = "EXEC spa_manage_email @flag='r', @search_result_table='" . $data['detail_table'] . "'";
                    $group_by = 'category,sub_category,notes_subject';
                    echo $search_result_email->load_grid_data($sql, 'g', '', false, $form_namespace . '.fx_email_grid_load');
                } else if($data['object_id'] == 'contract_group') {
                    echo $tab_obj->add_tab('contract_group', $data['object_name']);
                    $contract_layout = new AdihaLayout();
                    echo $tab_obj->attach_layout('contract_layout', 'contract_group', '1C');
                    $contract_layout->init_by_attach('contract_layout', $form_namespace);
                    echo $contract_layout->hide_header('a');
                    $search_result_contract = new AdihaGrid();
                    echo $contract_layout->attach_grid_cell('search_result_contract', 'a');
                    echo $search_result_contract->init_by_attach('search_result_contract', $form_namespace);
                    echo $search_result_contract->set_header("SN.,ID,Contract Name,Contract Description,Contact Name,Company Name,Address,Address 2");
                    echo $search_result_contract->set_columns_ids("SNo,contract_id,contract_name,contract_desc,name,company,address,address2");
                    echo $search_result_contract->set_widths("*,*,*,*,*,*,*,*");
                    echo $search_result_contract->set_column_types("ro_int,link,ro,ro,ro,ro,ro,ro");
                    echo $search_result_contract->set_sorting_preference("int,str,str,str,str,str,str,str");
                    echo $search_result_contract->set_search_filter(false,"#numeric_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter");
                    echo $search_result_contract->return_init();
                    $sql = "EXEC spa_search_engine @flag='y', @process_table='" . $data['detail_table'] . "'";
                    echo $search_result_contract->load_grid_data($sql,'g','',false, $form_namespace . '.fx_contract_grid_load');
                } else if (($data['object_id'] == 'master_view_counterparty_credit_info'
                    || $data['object_id'] == 'master_view_counterparty_credit_enhancements'
                    || $data['object_id'] == 'master_view_counterparty_credit_limits'
                    || $data['object_id'] == 'master_view_counterparty_credit_migration'
                    ) && !$credit_info_tab_created              
                ) {
                    $credit_info_tab_created= true;
                    echo $tab_obj->add_tab('credit_info', 'Credit Info');
                    $credit_info_layout = new AdihaLayout();
                    echo $tab_obj->attach_layout('credit_info_layout', 'credit_info', '1C');
                    $credit_info_layout->init_by_attach('credit_info_layout', $form_namespace);
                    echo $credit_info_layout->hide_header('a');
                    
                    $search_credit_info = new AdihaGrid();
                    echo $credit_info_layout->attach_grid_cell('search_credit_info', 'a');
                    echo $search_credit_info->init_by_attach('search_credit_info', $form_namespace);
                    echo $search_credit_info->set_header("SN.,ID,CounterpartyID,CounterpartyName,Description");
                    echo $search_credit_info->set_columns_ids("SNo,counterparty_credit_info_id,counterparty_id,counterparty_name,counterparty_description");                    
                    echo $search_credit_info->set_widths("*,*,*,*,*");
                    echo $search_credit_info->set_column_types("ro_int,link,ro,ro,ro");
                    echo $search_credit_info->set_sorting_preference("int,str,str,str,str");
                    echo $search_credit_info->set_search_filter(false,"#numeric_filter,#text_filter,#text_filter,#text_filter,#text_filter");
                    echo $search_credit_info->return_init();
                    $sql = "EXEC spa_search_engine @flag='x', @process_table='" . $data['detail_table'] . "'";
                    echo $search_credit_info->load_grid_data($sql,'g','',false, $form_namespace . '.fx_credit_info_grid_load');
                } else if (($data['object_id'] == 'master_view_incident_log' || $data['object_id'] == 'master_view_incident_log_detail') && !$incident_tab_created) {
                    $incident_tab_created = true;
                    echo $tab_obj->add_tab('incident', 'Incident');
                    $incident_layout = new AdihaLayout();
                    echo $tab_obj->attach_layout('incident_layout', 'incident', '1C');
                    $incident_layout->init_by_attach('incident_layout', $form_namespace);
                    echo $incident_layout->hide_header('a');
                     
                    $search_result_incident = new AdihaGrid();                    
                    echo $incident_layout->attach_grid_cell('search_result_incident', 'a');
                    echo $search_result_incident->init_by_attach('search_result_incident', $form_namespace);
                    echo $search_result_incident->set_header("Description,Attachment,Object ID,User Category,Incident Status,Date Initaited, Date Closed,Created Date,Created By,File Name,Notes Share Email Enable,Notes ID,Sub Category ID,Search Criteria,Category ID,Notes Object ID,Incident Log ID");
                    echo $search_result_incident->set_columns_ids("description,notes_attachment,parent_object_id,user_category,incident_status,date_initiated,date_closed,create_ts,create_user,attachment_file_name,notes_share_email_enable,notes_id,sub_category_id,search_criteria,category_id,notes_object_id,incident_log_id");
                    echo $search_result_incident->set_widths("200,310,150,150,150,150,150,150,150,150,150,150,150,150,150,150,150");
                    echo $search_result_incident->set_column_types("tree,link,link,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro");
                    echo $search_result_incident->set_column_visibility("false,false,false,false,false,false,false,false,false,true,true,true,true,true,true,true,true");
                    echo $search_result_incident->set_sorting_preference("int,str,str,str,str,str,str,str,date,str,str,str,str,str,str,str,str");
                    echo $search_result_incident->set_search_filter(false,"#text_filter,#text_filter,#text_filter,#combo_filter,#combo_filter,#text_filter,#text_filter,#text_filter,#combo_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter");
                    
                    echo $search_result_incident->return_init();
                    $sql = "EXEC spa_incident_log @flag='g', @search_result_table='" . $data['detail_table'] . "',@download_url='force_download.php'";
                    $group_by = 'category,incident_type,incident,description';
                    echo $search_result_incident->load_grid_data($sql, 'tg', $group_by, false, $form_namespace . '.fx_incident_grid_load');
                }


                if ($i > 0) {
                    $top_result_data .= '<hr>';
                }
                
                $tab_name = $data['object_id'];
                if($data['object_id'] == 'counterparty_bank_info' || $data['object_id'] == 'VW_counterparty_certificate'
                    || $data['object_id'] == 'master_view_counterparty_products' || $data['object_id'] == 'master_view_counterparty_contacts'
                    || $data['object_id'] ==  'master_view_counterparty_contract_address'
                    || $data['object_id'] ==  'master_view_counterparty_epa_account'
                ) {
                    $tab_name = 'source_counterparty';
                } else if ($data['object_id'] == 'master_view_counterparty_credit_info'
                    || $data['object_id'] == 'master_view_counterparty_credit_enhancements'
                    || $data['object_id'] == 'master_view_counterparty_credit_limits'
                    || $data['object_id'] == 'master_view_counterparty_credit_migration'
                ) {
                    $tab_name = 'credit_info';
                } else if ($data['object_id'] == 'master_view_incident_log' || $data['object_id'] == 'master_view_incident_log_detail') {
                    $tab_name = 'incident';
                }
                
                $object_name = $data['object_name'];
                if ($data['object_id'] ==  'master_view_counterparty_contract_address') {
                    $object_name = 'Counterparty Contracts';
                } else if ($data['object_id'] ==  'master_view_counterparty_epa_account') {
                    $object_name = 'Counterparty External ID';
                } else if ($data['object_id'] ==  'master_view_counterparty_credit_enhancements') {
                    $object_name = 'Credit Enhancement';
                } else if ($data['object_id'] ==  'master_view_counterparty_credit_limits') {
                    $object_name = 'Credit Limits';
                } else if ($data['object_id'] ==  'master_view_counterparty_credit_migration') {
                    $object_name = 'Credit Limit By Rating';
                } else if ($data['object_id'] ==  'master_view_incident_log_detail') {
                    $object_name = 'Incident Log Detail';
                }
                
                $top_result_data .= '<a class="thick" href="javascript:void(0)" onclick=header_link_click("' . $tab_name . '");>' . $object_name . ' - ' . $data['record_number'] . ' results found.</a>';
                
                $wrap_before = '<span class="highlight">';
                $wrap_after  = '</span>';
                $out = preg_replace("/($search_text)/i", "$wrap_before$1$wrap_after", $data['details']);
                
                $top_result_data .= '<br /> <p class="record">' . $out . '</p>';
                $i++;
            }
        } else {
            $top_result_data = 'No Record Found.';
        }
        
        echo $tab_obj->attach_HTMLstring('top_results', addslashes($top_result_data));

        // close layout
        echo $layout_obj->close_layout();        
    ?>  
</head>

<script type="text/javascript">
    $(function() {
        //enable paging for created tab layout grid
        if(searchResultDetail.deal_layout != undefined)
            fx_init_paging(searchResultDetail.deal_layout, searchResultDetail.search_result_deal, 'paging_area_deal');
        if(searchResultDetail.cpty_layout != undefined)
            fx_init_paging(searchResultDetail.cpty_layout, searchResultDetail.search_result_cpty, 'paging_area_cpty');
        if(searchResultDetail.doc_layout != undefined)
            fx_init_paging(searchResultDetail.doc_layout, searchResultDetail.search_result_doc, 'paging_area_doc');
        if(searchResultDetail.email_layout != undefined)
            fx_init_paging(searchResultDetail.email_layout, searchResultDetail.search_result_email, 'paging_area_email');
        if(searchResultDetail.contract_layout != undefined)
            fx_init_paging(searchResultDetail.contract_layout, searchResultDetail.search_result_contract, 'paging_area_contract');
    
        if(searchResultDetail.credit_info_layout != undefined)
            fx_init_paging(searchResultDetail.credit_info_layout, searchResultDetail.search_credit_info, 'paging_area_credit_info');
    });

    function fx_init_paging(layout_obj, grid_obj, paging_area) {
        status_bar = layout_obj.cells('a').attachStatusBar({
            height: 30,
            text: '<div id="' + paging_area + '"></div>'
        });
        grid_obj.setPagingWTMode(true,true,true,[10,20,25,30,40,50,60,70,80,90,100]);
        grid_obj.enablePaging(true, 50, 0, paging_area,true); 
        grid_obj.setPagingSkin('toolbar');  
    }       
        
    /**
     * [header_link_click Link click function]
     * @param  {[type]} string [link_string]
     */
    header_link_click = function(string) {
        searchResultDetail.result_tabs.cells(string).setActive();
    }

    var deal_report_wins;
    /**
     * [open_deal_summary_report Open Deal Summary Report on double click]
     * @param  {[type]} row_id [row id]
     * @param  {[type]} col_id [col id]
     * @return {[type]}        call parent window function to open deal summary
     */
    searchResultDetail.open_deal_summary_report = function(row_id, col_id) {
        var deal_id = searchResultDetail.search_result_deal.cells(row_id, 1).getValue();
        parent.searchResult.open_deal_summary_report(deal_id.replace(/(<([^>]+)>)/ig,""));       
    }

    /*
    * Function after document grid loaded
    */
    searchResultDetail.fx_doc_grid_load = function() {
       var grid_obj = searchResultDetail.search_result_doc;
       grid_obj.expandAll();    
       fx_highlight_searched_cell(grid_obj);
    }
    
    searchResultDetail.fx_incident_grid_load = function() {
       var grid_obj = searchResultDetail.search_result_incident;
       grid_obj.expandAll();    
       fx_highlight_searched_cell(grid_obj);
    }

    searchResultDetail.fx_email_grid_load = function() {
       var grid_obj = searchResultDetail.search_result_email;
       //grid_obj.expandAll();    
       fx_highlight_searched_cell(grid_obj);
    }

    searchResultDetail.fx_deal_grid_load = function(grid_type) {
        var grid_obj = searchResultDetail.search_result_deal;
        fx_highlight_searched_cell(grid_obj);
    }

    searchResultDetail.fx_cpty_grid_load = function(grid_type) {
        var grid_obj = searchResultDetail.search_result_cpty;
        fx_highlight_searched_cell(grid_obj);
    }

    searchResultDetail.fx_credit_info_grid_load = function(grid_type) {
        var grid_obj = searchResultDetail.search_credit_info;
        fx_highlight_searched_cell(grid_obj);
    }

    searchResultDetail.fx_contract_grid_load = function(grid_type) {
        var grid_obj = searchResultDetail.search_result_contract;
        fx_highlight_searched_cell(grid_obj);
    }
    
    /** Function to highlight document tab grid data and cells
    */
    function fx_highlight_searched_cell(grid_obj) {
        var search_text = "<?php echo $search_text; ?>";
        grid_obj.forEachRow(function(rid) {
            grid_obj.forEachCell(rid, function(cell_obj, cid) {
                var cell_value = cell_obj.getValue().toString();
                var regex_exp = new RegExp(search_text, "i");
                var replace_text = "<span style=\"background-color:yellow;\">" + search_text + "</span>";

                // Handled the hyperlink not working when hyperlink consists the searched words
                var a_tag_end_index = cell_value.indexOf('^_self');
                if (a_tag_end_index !== -1) {
                    var a_tag_start_index = cell_value.indexOf('^');
                    var str_to_unmodified = cell_value.substring(a_tag_start_index, a_tag_end_index + 6);
                    var str_to_replace = cell_value.substring(0, a_tag_start_index);
                    cell_value = str_to_replace.replace(regex_exp, replace_text) + str_to_unmodified;
                } else {
                    cell_value = cell_value.replace(regex_exp, replace_text);
                }
                cell_obj.setValue(cell_value);
            });
        });
    }
    
    function fx_click_parent_object_id_link(category_id, parent_object_id) {  
        var function_id = '';
        if(category_id == 33) {//deal
            function_id = 10131010;
            parent.parent.parent.TRMHyperlink(function_id,parent_object_id, 'n');
        } else if(category_id == 37) {//cpty
            function_id = 10105800;
            parent.parent.parent.TRMHyperlink(function_id,parent_object_id);
        } else if(category_id == 26 || category_id == 27 || category_id == 25) {//book
            get_tree_hierarchy(parent_object_id);
            
            //parent.parent.parent.TRMHyperlink(function_id,parent_object_id);
        } else if(category_id == 55) {
            function_id = 10101125;
            parent.parent.parent.TRMHyperlink(function_id,parent_object_id);
        } else if(category_id == 40) {//contract
            get_contact_type_fucntion_id(parent_object_id) 
            //function_id = 10211200; //need to change here
            //
        } else if(category_id == 38) {//invoice
            function_id = 10221300;
            parent.parent.parent.TRMHyperlink(function_id, parent_object_id);
        }  else if(category_id == 400141) {//renewable resources
            function_id = 12101700;
            parent.parent.parent.TRMHyperlink(function_id,parent_object_id);
        } else if(category_id == 101) {//credit info
            function_id = 10101122;
            parent.parent.parent.TRMHyperlink(function_id,parent_object_id);
        } else if(category_id == 102) {//incident
            function_id = 12101700;
            parent.parent.parent.TRMHyperlink(function_id,parent_object_id);
        } else if(category_id == '-1') { //workflow
            function_id = 10106700;
            parent.parent.parent.TRMHyperlink(function_id, parent_object_id, 'manage_email');
        } else if(category_id == 56) {  //Counterparty Contract
            function_id = 10105830;
            parent.parent.parent.TRMHyperlink(function_id,parent_object_id);    
        } else if(category_id == 45) {//match
            var sp_string = "EXEC spa_scheduling_workbench @flag='s'"; 
            post_data = { sp_string: sp_string };
            $.ajax({
                url: js_form_process_url,
                data: post_data,
            }).done(function(data) {
                var json_data = data['json'][0];
                var process_id_generated = json_data.process_id;
                sp_string = "EXEC spa_scheduling_workbench @flag='s',@buy_sell_flag=NULL,@process_id='" + process_id_generated + "'"; 
                post_data = { sp_string: sp_string };
                $.ajax({
                    url: js_form_process_url,
                    data: post_data,
                }).done(function(data) {
                    //var json_data1 = data['json'][0];
                    sp_string = "EXEC spa_scheduling_workbench @flag = 'v', @process_id = '" + process_id_generated + "', @buy_deals = '', @sell_deals = '', @convert_uom = 1082, @convert_frequency=703, @mode = 'u', @get_group_id = 1, @bookout_match = 'm', @match_group_id = " + parent_object_id; 
                    post_data = { sp_string: sp_string };
                    $.ajax({
                        url: js_form_process_url,
                        data: post_data,
                    }).done(function(data) {
                        //var json_data2 = data['json'][0];
                        sp_string = "EXEC spa_scheduling_workbench  @flag='q',@process_id='" + process_id_generated + "',@buy_deals='',@sell_deals='',@convert_uom='1082',@convert_frequency='703',,@mode='u',@location_id=NULL,@bookout_match='m',@contract_id=NULL,@commodity_name=NULL,@location_contract_commodity=NULL,@match_group_id=" + parent_object_id; 
                        post_data = { sp_string: sp_string };
                        $.ajax({
                            url: js_form_process_url,
                            data: post_data,
                        }).done(function(data) {
                            //var json_data3 = data['json'][0];
                            var url_param = '?receipt_detail_ids=&delivery_detail_ids=&process_id=' + process_id_generated + '&convert_uom=1082&convert_frequency=703&mode=u&contract_id=NULL&bookout_match=m&location_id=NULL&shipment_name=&match_id=&match_group_id=' + parent_object_id;
                            
                            function_id = 10163710;
                            parent.parent.parent.TRMHyperlink(function_id,url_param);
                            return;
                            var url_match = app_form_path + '_scheduling_delivery/scheduling_workbench/match.php' + url_param;
                            match_win = dhx_wins.createWindow("w2", 0, 0, 650, 500);    
                            match_win.setText('Match');
                            match_win.maximize();
                            match_win.attachURL(url_match, false, true);
                            return;
                        });
                    });
                });
            });
        }
        else return;                
    }
    
    function get_contact_type_fucntion_id(parent_object_id) {
        var sql_param = {
                            'action' : 'spa_search_engine',
                            'flag' : 'g',
                            'filter_text' : parent_object_id
                        };  
   
        adiha_post_data('return_array', sql_param, '', '', 'get_contact_type_function_id_callback'); 
        
    }
    
    function get_contact_type_function_id_callback(return_value) {
        var function_id = return_value[0][0];  
        var parent_object_id = return_value[0][1];
        var contract_name = return_value[0][2];
     
        parent.parent.parent.TRMHyperlink(function_id, parent_object_id, contract_name);
    }
    
    function get_tree_hierarchy(parent_object_id) {
        var sql_param = {
                            'action' : 'spa_search_engine',
                            'flag' : 'j',
                            'filter_text' : parent_object_id
                             
                        };  
   
        adiha_post_data('return_array', sql_param, '', '', 'get_tree_hierarchy_callback'); 
        parent.parent.parent.TRMHyperlink(function_id,parent_object_id);
    }
    
    function get_tree_hierarchy_callback(return_value) {
       var level_name = return_value[0][0];  
       var parent_object_id = return_value[0][1]; 
       var tab_name = return_value[0][2]; 
       var function_id = 10101200; 
       parent.parent.parent.TRMHyperlink(function_id, parent_object_id, level_name, tab_name);
    }
    
    //Grid Email: function to open attachment list on popup
    var att_popup_obj_gbl;
    function fx_open_attachment_list(email_id,obj) {
        
        var att_list_template = 'filename,filesize';
        var att_list = [];
        var sp_string = "EXEC spa_attachment_detail_info @flag='a', @email_id=" + email_id; 
        post_data = { sp_string: sp_string };

        if (!att_popup_obj_gbl) {
            att_popup_obj_gbl = new dhtmlXPopup();
            att_popup_obj_gbl.attachEvent('onClick', function(id) {
                var list_data = att_popup_obj_gbl.getItemData(id);
                //console.log(list_data);
                fx_download_file(list_data.filepath);
            });
        }
           
        var x = window.dhx4.absLeft(obj);
        var y = window.dhx4.absTop(obj);
        var w = obj.offsetWidth;
        var h = obj.offsetHeight;

        att_popup_obj_gbl.show(x,y,w,h);
                
        $.ajax({
            url: js_form_process_url,
            data: post_data,
        }).done(function(data) {
            var json_data = data['json'];
            $.each(json_data, function(key,val) {
                att_list.push({
                    id:val.attachment_detail_info_id, 
                    filename:val.attachment_file_name, 
                    filesize:val.attachment_file_size,
                    filepath:val.attachment_file_path
                },att_popup_obj_gbl.separator);
            });
            att_list.pop();
            att_popup_obj_gbl.attachList(att_list_template, att_list);
        });
    }
            
    function fx_download_file(file_path) {
        window.location = js_php_path + 'force_download.php?path=' + file_path;
    }

    searchResultDetail.fx_doc_grid_event_onmouseover = function(row, col) {
        if (col == this.getColIndexById('notes_attachment')) {
            this.cells(row,col).cell.title = this.cells(row,this.getColIndexById('attachment_file_name')).getTitle();
        } else if (col == this.getColIndexById('parent_object_id')) { 
            //no tooltip
        }  else {
            this.cells(row,col).cell.title = this.cells(row,col).getTitle();
        }
    }
    searchResultDetail.fx_email_grid_event_onmouseover = function(row, col) {
        if (col == this.getColIndexById('attachment')) {
            //no tooltip
        } else if (col == this.getColIndexById('mapped_object')) { 
            //no tooltip
        }  else {
            this.cells(row,col).cell.title = this.cells(row,col).getTitle();
        }
    }
    
    searchResultDetail.fx_doc_grid_event_dbclick = function(row, col) {
        
    }

    searchResultDetail.fx_email_grid_event_dbclick = function(row, col) {
        
    }
    
    $.ajaxSetup({
        method: 'POST',
        dataType: 'json',
        error: function(jqXHR, text_status, error_thrown) {
            console.log('*** Error on ajax: ' + text_status + ', ' + error_thrown);
        }
    });
</script>
</html>