<?php
/**
* Transfer book position screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
        <?php require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
    </head>
    <?php
    $layout = new AdihaLayout();
    $form_obj = new AdihaForm();
    $tab_obj = new AdihaTab();
    
    $json = '[
                {
                    id:             "a",
                    header:         false,
                    collapse:       false,
                    height:         35,
                    fix_size:       [true,true]
                },
                {
                    id:             "b",
                    header:         false,
                    collapse:       false,
                    height:         70,
                    fix_size:       [true,true]
                },

                {
                    id:             "c",
                    header:         false,
                    collapse:       false,
                    fix_size:       [false,null]
                }
            ]';
    $layout_name = 'transfer_book_layout';
    $namespace = 'transfer_book_namespace';

    echo $layout->init_layout($layout_name, '', '3E', $json, $namespace);


    $form_name = 'transfer_book';
    $toolbar_json = '[      
                        { id: "transfer", type: "button", img: "transfer.gif", text: "Transfer", title: "Transfer",imgdis:"new_dis.gif"}
                    ]';
    echo $layout->attach_toolbar_cell($form_name, 'a');   

    $transfer_book_toolbar = new AdihaToolbar();
    echo $transfer_book_toolbar->init_by_attach($form_name, $namespace);
    echo $transfer_book_toolbar->load_toolbar($toolbar_json);
    echo $transfer_book_toolbar->attach_event('', 'onClick', 'btn_ok_click');

    $form_structure_cell_b = "[  

        { type:'calendar', dateFormat: '" . $date_format . "',userdata:{'validation_message':'Required Field'},  name:'dt_as_of_date_text', required: true, value: '', label:'As of Date ', inputWidth:".$ui_settings['field_size'].", labelWidth:'auto', position:'label-top',offsetLeft: ".$ui_settings['offset_left']."},
        {type: 'newcolumn'}, 
        { type:'calendar', dateFormat: '" . $date_format . "',userdata:{'validation_message':'Required Field'},  name:'dt_term_start', required: true, value: '', label:'Term Start', inputWidth:".$ui_settings['field_size'].", labelWidth:'auto', position:'label-top',offsetLeft: ".$ui_settings['offset_left']."},
        {type: 'newcolumn'},  
        { type:'calendar', dateFormat: '" . $date_format . "',userdata:{'validation_message':'Required Field'},  name:'dt_term_end', required: true, value: '', label:'Term End', inputWidth:".$ui_settings['field_size'].", labelWidth:'auto', position:'label-top', offsetLeft: ".$ui_settings['offset_left']."},
    ]";

    $form_name = "common_form";
    echo $layout->attach_form($form_name, 'b', $form_structure_cell_b);  

    //Start of Tabs
    $tab_name = 'transfer_layout_book_tabs';
    $json_tab = '[
        {
            id:      "a1",
            text:    "New Position",
            width:   null,
            index:   null,
            active:  true,
            enabled: true,
            close:   false
        },
        {
            id:      "a2",
            text:    "Use Existing Position",
            width:   null,
            index:   null,
            active:  false,
            enabled: true,
            close:   false
        },    
        ]';
    echo $layout->attach_tab_cell($tab_name, 'c', $json_tab);

    //field for tab cell b form
    $sp_url_volume_uom_v = "EXEC spa_source_uom_maintain @flag='s'";
    $sp_url_volume_frequency_v = "EXEC spa_getVolumeFrequency";
    $sp_url_index_v = "EXEC spa_source_price_curve_def_maintain @flag = 'l'";
    $sp_url_location_v = "EXEC spa_source_minor_location 'o'";
    $sp_url_counterparty_v = "EXEC spa_source_counterparty_maintain 'c'";
    $sp_url_trader_v = "EXEC spa_source_traders_maintain 'x'";
    $sp_url_commodity_v = "EXEC spa_source_commodity_maintain 'a'";
    $round_array_value = array('0', '1', '2', '3', '4', '5','6','7');
    $round_array_label = array('0', '1', '2', '3', '4', '5','6','7'); 

    echo "cmb_index_v= ".  $form_obj->adiha_form_dropdown($sp_url_index_v, 0, 1, false, '', 2) . ";"."\n";
    echo "cmb_location_v= ".  $form_obj->adiha_form_dropdown($sp_url_location_v, 0, 1, false, '', 2) . ";"."\n";
    echo "cmb_volume_uom_v= ".  $form_obj->adiha_form_dropdown($sp_url_volume_uom_v, 0, 1, false, '', 2) . ";"."\n";
    echo "cmb_volume_frequency_v= ".  $form_obj->adiha_form_dropdown($sp_url_volume_frequency_v, 0, 1) . ";"."\n";
    echo "cmb_counterparty_v= ".  $form_obj->adiha_form_dropdown($sp_url_counterparty_v, 0, 1, true, '', 2) . ";"."\n";
    echo "cmb_trader_v= ".  $form_obj->adiha_form_dropdown($sp_url_trader_v, 0, 1, true, '', 2) . ";"."\n";
    echo "cmb_commodity_v= ".  $form_obj->adiha_form_dropdown($sp_url_commodity_v, 0, 1, true, '123', 2) . ";"."\n";
    echo "cmb_round_v= ".  $form_obj->create_static_combo_box($round_array_value, $round_array_label, '3', 7) . ";"."\n";
    echo "cmb_index_v2= ".  $form_obj->adiha_form_dropdown($sp_url_index_v, 0, 1, true, '', 2) . ";"."\n";

    //echo "cmb_as_of_date = ".  $form_obj->create_static_combo_box($value_array, $label_array, '', 5) . ";"."\n";
    // echo "cmb_recurring = ".  $form_obj->create_static_combo_box($data_array_recurring, $data_array_recurring, $recurs_every, 101) . ";"."\n";

    //new position form
    $form_name = "new_position_form";
    $form_structure_cell_c_a1 = "[    
        { type:'combo' , name:'txt_cmb_index', label:'Index', required: true, labelWidth:'auto',  inputWidth:".$ui_settings['field_size'].",position:'label-top',  offsetLeft: ".$ui_settings['offset_left'].", options: cmb_index_v,'filtering':'true','filtering_mode':'true',userdata:{'validation_message':'Required Field'}},
        { type: 'newcolumn'},
        { type:'input',validate:'NotEmpty,ValidNumeric', userdata:{'validation_message':'Integer Value only'}, name:'txt_volume', label:'Volume',required: true, labelWidth:'auto',  inputWidth:".$ui_settings['field_size'].",position:'label-top',  offsetLeft: ".$ui_settings['offset_left'].",userdata:{'validation_message':'Required Field'}},
        { type: 'newcolumn'},
        { type:'combo' , name:'location', label:'Location', required: true, labelWidth:'auto', inputWidth:".$ui_settings['field_size'].", position:'label-top',  offsetLeft: ".$ui_settings['offset_left'].", options: cmb_location_v, hidden:true},
        { type: 'newcolumn'},
        { type:'combo', name:'txt_cmb_volume_uom', label:'Volume UOM', required: true, labelWidth:'auto', inputWidth:".$ui_settings['field_size'].",position:'label-top',  offsetLeft: ".$ui_settings['offset_left'].", options: cmb_volume_uom_v,'filtering':'true','filtering_mode':'true',userdata:{'validation_message':'Required Field'}},  
        { type: 'newcolumn'},
        
        { type:'combo' , name:'txt_cmb_volume_frequency', label:'Volume Frequency', required: true, labelWidth:'auto',  inputWidth:".$ui_settings['field_size'].",position:'label-top',  offsetLeft: ".$ui_settings['offset_left'].", options: cmb_volume_frequency_v,'filtering':'true','filtering_mode':'true',userdata:{'validation_message':'Required Field'}},        
        
       ]";


    echo $tab_obj->attach_form_new($tab_name, $form_name, 'a1', $form_structure_cell_c_a1, $namespace);


    $form_structure_cell_c_a2 = "[ 

        {type: 'block', blockOffset: ".$ui_settings['block_offset'].", list: [
            {type: 'block', blockOffset: ".$ui_settings['block_offset'].", list: [
            {'type':'input','name':'book_structure','label':'Book Structure','value':'','position':'label-top','inputWidth':'".$ui_settings['field_size']."','offsetLeft': ".$ui_settings['offset_left'].",'labelWidth':'150','hidden':'false','readonly':'true',className:'browse_label','required':'true','userdata':{'grid_name':'book', 'grid_label': 'Book Structure','validation_message':'Required Field'}},
              {'type':'newcolumn'},
            {'type':'input','name':'subbook_id','label':'Book Structure:','validate':'ValidInteger','value':'','position':'label-top','inputWidth':'".$ui_settings['field_size']."','offsetLeft':'".$ui_settings['offset_left']."','labelWidth':'auto','hidden':'true','disabled':'false'},
            {'type':'newcolumn'},
            {'type':'button','name':'clear_book_structure','value':'','tooltip':'Clear','className':'browse_clear','position':'absolute','inputWidth':'".$ui_settings['field_size']."','offsetLeft':'".$ui_settings['browse_clear_offset_left']."', 'offsetTop':'".$ui_settings['browse_clear_offset_top']."','labelWidth':'auto','hidden':'true','disabled':'false'},
        ]}, 
        { type: 'newcolumn'},
        
            {'type':'input','name':'subsidiary_id','label':'Book Structure:','validate':'ValidInteger','value':'','position':'label-top','inputWidth':'".$ui_settings['field_size']."','offsetLeft':'".$ui_settings['offset_left']."','labelWidth':'auto','hidden':'true','disabled':'false'},
            {'type':'newcolumn'},
            {'type':'input','name':'strategy_id','label':'Book Structure:','validate':'ValidInteger','value':'','position':'label-top','inputWidth':'".$ui_settings['field_size']."','offsetLeft':'".$ui_settings['offset_left']."','labelWidth':'auto','hidden':'true','disabled':'false'},
            {'type':'newcolumn'},
            {'type':'input','name':'book_id','label':'Book Structure:','validate':'ValidInteger','value':'','position':'label-top','inputWidth':'".$ui_settings['field_size']."','offsetLeft':'".$ui_settings['offset_left']."','labelWidth':'auto','hidden':'true','disabled':'false'},
          
            { type: 'newcolumn'},
            { type:'combo' , name:'txt_cmb_counterparty', label:'Counterparty', required: false, labelWidth:'auto',  inputWidth:".$ui_settings['field_size'].",position:'label-top',  offsetLeft: ".$ui_settings['offset_left'].", options: cmb_counterparty_v,'filtering':'true','filtering_mode':'true',userdata:{'validation_message':'Invalid Selection'}},
            { type: 'newcolumn'},
            { type:'combo' , name:'txt_cmb_source_trader', label:'Trader ', required: false, labelWidth:'auto',  inputWidth:".$ui_settings['field_size'].",position:'label-top',  offsetLeft: ".$ui_settings['offset_left'].", options: cmb_trader_v,'filtering':'true','filtering_mode':'true',userdata:{'validation_message':'Invalid Selection'}},
            {'type':'newcolumn'},
            { type:'combo' , name:'txt_cmb_source_commodity', label:'Commodity', required: true, labelWidth:'auto', inputWidth:".$ui_settings['field_size'].",position:'label-top',  offsetLeft: ".$ui_settings['offset_left'].", options: cmb_commodity_v,'filtering':'true','filtering_mode':'true',userdata:{'validation_message':'Invalid Selection'}},
            { type: 'newcolumn'},
            { type:'combo' , name:'txt_cmb_index', label:'Index', labelWidth:'auto', inputWidth:".$ui_settings['field_size'].",position:'label-top',  offsetLeft: ".$ui_settings['offset_left'].", options: cmb_index_v2,'filtering':'true','filtering_mode':'true',userdata:{'validation_message':'Invalid Selection'}},
            {'type':'newcolumn'},
            { type:'combo' , name:'txt_cmb_round', label:'Round Value', required: false, labelWidth:'auto',  inputWidth:".$ui_settings['field_size'].",position:'label-top',  offsetLeft: ".$ui_settings['offset_left'].", options: cmb_round_v,'filtering':'true','filtering_mode':'true',userdata:{'validation_message':'Invalid Selection'}},
        ]},            
       ]";

    $button_grid_json = '[          
          
              { id:"html", text:"HTML", img:"html.gif", imgdis:"html_dis.gif", title: "HTML"},
              { type: "separator" },
              { id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"},
              { type: "separator" },
              { id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
              { type: "separator" },
              { id: "batch", imgdis: "batch_dis.gif", img: "batch.gif", text: "Batch", title: "Batch" },
              { id: "pivot", imgdis: "pivot_dis.gif", img: "pivot.gif", text: "Pivot", title: "Pivot" }
      
      ]';

    echo $tab_obj->init_by_attach($tab_name, $namespace);
    $tab_a2_layout = new AdihaLayout();
    $tab_a2_layout_name = 'layout_tab_cell_a2';
    $cell_json = '[
        {
            "id":"a",
            "text":"Additional Criteria",
            "height":160
        },
        {
            "id":"b",
            "text":"Report"
        }
    ]';
    echo $tab_obj->attach_layout_cell($namespace, $tab_a2_layout_name, $namespace . '.' . $tab_name, 'a2', '2E', $cell_json);    
    echo $tab_a2_layout->init_by_attach($tab_a2_layout_name, $namespace);
    echo $tab_a2_layout->attach_form('layout_tab_cell_a2_from_f', 'a', $form_structure_cell_c_a2);

    echo $tab_a2_layout->attach_menu_layout_cell('layout_tab_cell_a2_from', 'b', $button_grid_json, 'button_grid_json_function');

    //closing the layout of the main layout.
    echo $layout->close_layout();
    ?>
     <script type="text/javascript">
        //var current_date = new Date('m/d/y');
        var today = new Date();
        var current_date = new Date(today.getFullYear(), today.getMonth() , today.getDate());
        var session_id = '<?php echo $session_id; ?>';
        // report_type_arr = {};
        $(function(){   
            layout_tab_cell_a2_from_f = transfer_book_namespace.layout_tab_cell_a2_from_f;
            attach_browse_event("layout_tab_cell_a2_from_f", 10131600); 
            transfer_book_namespace.common_form.setItemValue('dt_as_of_date_text', current_date);
        });     

        function btn_ok_click (arg) {
             var invalid_selection_status = false;
            var dt_term_start = transfer_book_namespace.common_form.getItemValue('dt_term_start',true);
            var dt_term_end = transfer_book_namespace.common_form.getItemValue('dt_term_end',true);
			var dt_as_of_date = transfer_book_namespace.common_form.getItemValue('dt_as_of_date_text',true);
            if(new Date(dt_term_start).getTime() > new Date(dt_term_end).getTime()) {
                show_messagebox("Term Start should be less than Term End.");
                return false;
            }
			
			if(new Date(dt_as_of_date).getTime() > new Date(dt_term_start).getTime()) {
                dhtmlx.message({
                title: "Alert",
                type: "alert",
                text: "As of Date should be less than Term Start.",                 
                });
                return false;
            }
			
					
            transfer_book_namespace.new_position_form.attachEvent("onChange", function(){
                    transfer_book_namespace.new_position_form.clearNote('txt_cmb_volume_frequency');
                });  
            var txt_cmb_volume_frequency_combo_obj = transfer_book_namespace.new_position_form.getCombo('txt_cmb_volume_frequency');
            transfer_book_namespace.new_position_form.attachEvent("onChange", function(){
                    transfer_book_namespace.new_position_form.clearNote('txt_cmb_volume_uom');
                });
            transfer_book_namespace.new_position_form.attachEvent("onChange", function(){
                    transfer_book_namespace.new_position_form.clearNote('txt_cmb_index');
                });
            if(txt_cmb_volume_frequency_combo_obj.getSelectedValue() == null && txt_cmb_volume_frequency_combo_obj.getComboText()!='') {
                var message = transfer_book_namespace.new_position_form.getUserData('txt_cmb_volume_frequency',"validation_message");
                transfer_book_namespace.new_position_form.setValidateCss('txt_cmb_volume_frequency', true,'validate_error');
                transfer_book_namespace.new_position_form.setNote('txt_cmb_volume_frequency',{text:'Invalid Selection',width:200});
                invalid_selection_status = true;

            }

            var txt_cmb_volume_uom_combo_obj = transfer_book_namespace.new_position_form.getCombo('txt_cmb_volume_uom');
            if(txt_cmb_volume_uom_combo_obj.getSelectedValue() == null && txt_cmb_volume_uom_combo_obj.getComboText()!='') {
                var message = transfer_book_namespace.new_position_form.getUserData('txt_cmb_volume_uom',"validation_message");
                transfer_book_namespace.new_position_form.setValidateCss('txt_cmb_volume_uom', true,'validate_error');
                transfer_book_namespace.new_position_form.setNote('txt_cmb_volume_uom',{text:'Invalid Selection',width:200});
                invalid_selection_status = true;
            }

            var txt_cmb_index_combo_obj = transfer_book_namespace.new_position_form.getCombo('txt_cmb_index');
            if(txt_cmb_index_combo_obj.getSelectedValue() == null && txt_cmb_index_combo_obj.getComboText()!='') {
                var message = transfer_book_namespace.new_position_form.getUserData('txt_cmb_index',"validation_message");
                transfer_book_namespace.new_position_form.setValidateCss('txt_cmb_index', true,'validate_error');
                transfer_book_namespace.new_position_form.setNote('txt_cmb_index',{text:'Invalid Selection',width:200});
                invalid_selection_status = true;
            }

            var index_id = layout_tab_cell_a2_from_f.getItemValue('txt_cmb_index');
            index_id = (index_id == '') ? 'NULL' : index_id; 

            var volume_text_box_value = transfer_book_namespace.new_position_form.getItemValue('txt_volume');
            if (volume_text_box_value != null ) {
                if(isNaN(volume_text_box_value)){
                    transfer_book_namespace.new_position_form.setNote('txt_volume',{text:'Invalid Number',width:100});
                    invalid_selection_status = true;
                } 
            }

            var active_tab_id = transfer_book_namespace.transfer_layout_book_tabs.getActiveTab();
            if (validate_form(transfer_book_namespace.common_form) == false) {
                    return false;
            }
            if(invalid_selection_status) {
                return false;
            }
            if(active_tab_id == 'a1') {
                if(validate_form(transfer_book_namespace.new_position_form) == false) {
                    return false;
                }
            }

            if(active_tab_id == 'a2') { 
                /****** This is done to show alert box for multiple select of subbook in the Book Structure *******/
                var subbook_count ={};
                subbook_count =  layout_tab_cell_a2_from_f.getItemValue('subbook_id');
                var count = 1;
                for(var i = 1; i < subbook_count.length+1; ++i){
                     if(subbook_count[i] == ',')
                        count++;
                }
                // if (count != 1) {
                //     dhtmlx.alert({
                //         type: "alert", 
                //         title:'Alert',
                //         text:"Please select a single Sub Book in Book Structure."
                //     });
                //     return;
                // } 
                // /***************************************************/
                // if(validate_form(layout_tab_cell_a2_from_f) == false){
                //     return false;
                // }
            }

            dhxWins = new dhtmlXWindows();
            
            param = 'transfer.book.popup.php?is_pop=true&index_id=' + index_id;

            var is_win = dhxWins.isWindow('w3');
            if (is_win == true) {
                w3.close();
            }
            w3 = dhxWins.createWindow("w3", 120, 0, 890, 540);
            w3.setText("Transfer Criteria");
            w3.setModal(true);
            w3.attachURL(param, false, true);

            w3.attachEvent("onClose", function(win) {
                return true;
            });
        }

        function close_window() {
            w3.close();
        }

        function button_grid_json_function(id) {
            
            var title = 'Transfer Book Position';
            var sub_entity_id = layout_tab_cell_a2_from_f.getItemValue('subsidiary_id');
            var strategy_entity_id = layout_tab_cell_a2_from_f.getItemValue('strategy_id');
            var book_entity_id = layout_tab_cell_a2_from_f.getItemValue('book_id');
            var subbook_entity_id = layout_tab_cell_a2_from_f.getItemValue('subbook_id');
            var source_deal_header_id = 'NULL';
            var deal_id = 'NULL';
            var as_of_date = dates.convert_to_sql(transfer_book_namespace.common_form.getItemValue('dt_as_of_date_text', true));
            var param = 'call_from=transfer_book&gen_as_of_date=1&batch_type=r&as_of_date='+as_of_date;
            var summary_option = 'm';                     
            var tenor_option = 'f';
            var option = 'd';
            var cmb_group1 = 'NULL';
            var cmb_group2 = 'NULL';
            var cmb_group3 = 'NULL';
            var cmb_group4 = 'NULL';
            var commodity_id = layout_tab_cell_a2_from_f.getItemValue('txt_cmb_source_commodity'); 
            commodity_id = (commodity_id == '') ? 'NULL' : commodity_id;                  
            var deal_type = 'NULL';
            var physical_financial_flag = 'b';
            var group_by = 'i';
            var deal_type_combo = 'NULL';
            var trader_id = layout_tab_cell_a2_from_f.getItemValue('txt_cmb_source_trader');
            trader_id = (trader_id == '') ? 'NULL' : trader_id;
            var dt_term_start = dates.convert_to_sql(transfer_book_namespace.common_form.getItemValue('dt_term_start',true));
            var dt_term_end = dates.convert_to_sql(transfer_book_namespace.common_form.getItemValue('dt_term_end',true)); 
            var show_cross_tabformat = 'n';
            var deal_status = 'NULL';
            var round_value = layout_tab_cell_a2_from_f.getItemValue('txt_cmb_round');
            round_value = (round_value == '') ? 3: round_value;
            var counterparty_id = layout_tab_cell_a2_from_f.getItemValue('txt_cmb_counterparty');
            counterparty_id = (counterparty_id == '') ? 'NULL' : counterparty_id; 
            var index_id = layout_tab_cell_a2_from_f.getItemValue('txt_cmb_index');
            index_id = (index_id == '') ? 'NULL' : index_id; 


            switch(id){
                case 'excel': 
                    var js_php_path = '<?php echo $app_adiha_loc; ?>';
                    var url = js_php_path + 'adiha.php.scripts/dev/spa_html.php';
                    var active_tab_id = transfer_book_namespace.transfer_layout_book_tabs.getActiveTab();
                    var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
                    var js_php_path = '<?php echo $app_adiha_loc; ?>';
                     if(!book_entity_id){                       
                        show_messagebox("Please select Book Structure.");
                        return false;                        
                    }
                    var exec_call = 'EXEC spa_Create_Position_Report '+
                        singleQuote(as_of_date) + ',' +
                        singleQuote(sub_entity_id) + ',' +
                        singleQuote(strategy_entity_id) + ',' +
                        singleQuote(book_entity_id) + ',' +
                        singleQuote(summary_option) + ',' +
                        singleQuote(null) + ',' +
                        singleQuote(tenor_option) + ',' +
                        cmb_group1 + ',' +
                        cmb_group2 + ',' +
                        cmb_group3 + ',' +
                        cmb_group4 + ',' +'NULL, NULL, NULL, NULL,' +
                        singleQuote(option) +', NULL, NULL, NULL, NULL,' +
                        index_id + ',' +
                        commodity_id + ',' +
                        singleQuote(deal_type) + ',' +
                        singleQuote(group_by) + ',' +
                        singleQuote(physical_financial_flag) + ',' +
                        deal_type_combo + ',' +
                        trader_id + ',' +
                        singleQuote(dt_term_start) + ',' +
                        singleQuote(dt_term_end) + ',' +
                        singleQuote(show_cross_tabformat) +', NULL,' +
                        deal_status + ',' +  
                        round_value + ", 'n', " +
                        counterparty_id + ", NULL, 'n', NULL, NULL, 'n', 'a', NULL," + singleQuote(subbook_entity_id);
                 
                    var parameters = exec_call;
                        url += '?exec=' + parameters;
                        url += '&writeCSV=true';
                        url += '&session_id=' +  session_id + '&' +  getAppUserName();
                        open_window_with_post(url)


                break;

                case 'html': 
                    var active_tab_id = transfer_book_namespace.transfer_layout_book_tabs.getActiveTab();
                    var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
                    var js_php_path = '<?php echo $app_adiha_loc; ?>';
                    if(validate_form(transfer_book_namespace.common_form) == false){
                    return false;
                    }

                    // if(active_tab_id == 'a2') { 
                    //     if(validate_form(layout_tab_cell_a2_from_f) == false){
                    //         return false;
                    //     }
                    // }
                    if(!book_entity_id){                       
                        show_messagebox("Please select Book Structure.");
                        return false;                        
                    }
                    if(commodity_id == 'NULL'){    
                        show_messagebox("Please select a Commodity.");
                        return false;                        
                    }
                    var exec_call = 'EXEC spa_Create_Position_Report '+
                        singleQuote(as_of_date) + ',' +
                        singleQuote(sub_entity_id) + ',' +
                        singleQuote(strategy_entity_id) + ',' +
                        singleQuote(book_entity_id) + ',' +
                        singleQuote(summary_option) + ',' +
                        singleQuote(null) + ',' +
                        singleQuote(tenor_option) + ',' +
                        cmb_group1 + ',' +
                        cmb_group2 + ',' +
                        cmb_group3 + ',' +
                        cmb_group4 + ',' +'NULL, NULL, NULL, NULL,' +
                        singleQuote(option) +', NULL, NULL, NULL, NULL,' +
                        index_id + ',' +
                        commodity_id + ',' +
                        singleQuote(deal_type) + ',' +
                        singleQuote(group_by) + ',' +
                        singleQuote(physical_financial_flag) + ',' +
                        deal_type_combo + ',' +
                        trader_id + ',' +
                        singleQuote(dt_term_start) + ',' +
                        singleQuote(dt_term_end) + ',' +
                        singleQuote(show_cross_tabformat) +', NULL,' +
                        deal_status + ',' +  
                        round_value + ", 'n', " +
                        counterparty_id + ", NULL, 'n', NULL, NULL, 'n', 'a', NULL," + singleQuote(subbook_entity_id);
                 
                    var parameters = exec_call;                       
                    var url = js_php_path + 'adiha.php.scripts/dev/spa_html.php';
                       // url += '?exec=' + parameters;
//                        url += '&session_id=' +  session_id + '&' +  getAppUserName();
//                      //  transfer_book_namespace.layout_tab_cell_a2.cells('b').progressOn();
//                        url += url + '&close_progress=1';
                        transfer_book_namespace.layout_tab_cell_a2.cells('a').collapse();
                        transfer_book_namespace.layout_tab_cell_a2.cells('b').attachURL(url, null, {exec: exec_call, session_id : session_id});
                        transfer_book_namespace.layout_tab_cell_a2.cells('b').show_hide_filter('a2', 'html');
                        transfer_book_namespace.show_hide_filter('');

                break;
                case 'pdf':
                    var js_php_path = '<?php echo $app_adiha_loc; ?>';
                    var url = js_php_path + 'adiha.php.scripts/dev/spa_pdf.php';
                    var active_tab_id = transfer_book_namespace.transfer_layout_book_tabs.getActiveTab();
                    var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
                    var js_php_path = '<?php echo $app_adiha_loc; ?>';
                    if(validate_form(transfer_book_namespace.common_form) == false){
                        return false;
                        }
                     if(!book_entity_id){                       
                        show_messagebox("Please select Book Structure.");
                        return false;                        
                    }
                    var exec_call = 'EXEC spa_Create_Position_Report '+
                        singleQuote(as_of_date) + ',' +
                        singleQuote(sub_entity_id) + ',' +
                        singleQuote(strategy_entity_id) + ',' +
                        singleQuote(book_entity_id) + ',' +
                        singleQuote(summary_option) + ',' +
                        singleQuote(null) + ',' +
                        singleQuote(tenor_option) + ',' +
                        cmb_group1 + ',' +
                        cmb_group2 + ',' +
                        cmb_group3 + ',' +
                        cmb_group4 + ',' +'NULL, NULL, NULL, NULL,' +
                        singleQuote(option) +', NULL, NULL, NULL, NULL,' +
                        index_id + ',' +
                        commodity_id + ',' +
                        singleQuote(deal_type) + ',' +
                        singleQuote(group_by) + ',' +
                        singleQuote(physical_financial_flag) + ',' +
                        deal_type_combo + ',' +
                        trader_id + ',' +
                        singleQuote(dt_term_start) + ',' +
                        singleQuote(dt_term_end) + ',' +
                        singleQuote(show_cross_tabformat) +', NULL,' +
                        deal_status + ',' +  
                        round_value + ", 'n', " +
                        counterparty_id + ", NULL, 'n', NULL, NULL, 'n', 'a', NULL," + singleQuote(subbook_entity_id);                 
                    var parameters = exec_call;
                        url += '?exec=' + parameters;
                        url += '&session_id=' +  session_id + '&' +  getAppUserName();
                        open_window_with_post(url)
                break;
                case 'batch':                   
                    var exec_call = 'EXEC spa_Create_Position_Report '+
                        singleQuote(as_of_date) + ', ' +
                        singleQuote(sub_entity_id) + ', ' +
                        singleQuote(strategy_entity_id) + ', ' +
                        singleQuote(book_entity_id) + ', ' +
                        singleQuote(summary_option) + ', ' +
                        singleQuote(null) + ', ' +
                        singleQuote(tenor_option) + ', ' +
                        cmb_group1 + ', ' +
                        cmb_group2 + ', ' +
                        cmb_group3 + ', ' +
                        cmb_group4 + ', ' + 'NULL, NULL, NULL, NULL,' +
                        singleQuote(option) + ', NULL, NULL, NULL, NULL, NULL, ' +
                        commodity_id + ', ' +
                        singleQuote(deal_type) + ', ' +
                        singleQuote(group_by) + ', ' +
                        singleQuote(physical_financial_flag) + ', ' +
                        deal_type_combo + ', ' +
                        trader_id + ', ' +
                        singleQuote(dt_term_start) + ', ' +
                        singleQuote(dt_term_end) + ', ' +
                        singleQuote(show_cross_tabformat) + ', NULL, ' +
                        deal_status + ', ' +  
                        round_value + ", 'n', " +
                        counterparty_id + ", NULL, 'n', NULL, NULL, 'n', 'a', NULL," + singleQuote(subbook_entity_id);
                 
                    adiha_run_batch_process(exec_call, param, title); 
                break;
                case 'pivot':         
                    var active_tab_id = transfer_book_namespace.transfer_layout_book_tabs.getActiveTab();
                    var active_object_id = (active_tab_id.indexOf("tab_") != -1) ? active_tab_id.replace("tab_", "") : active_tab_id;
                    var js_php_path = '<?php echo $app_adiha_loc; ?>';
                        if(validate_form(transfer_book_namespace.common_form) == false){
                        return false;
                        }
                    if(!book_entity_id){                       
                        show_messagebox("Please select Book Structure.");
                        return false;                        
                    }          
                     var pivot_exec_spa = 'EXEC spa_Create_Position_Report '+
                        singleQuote(as_of_date) + ',' +
                        singleQuote(sub_entity_id) + ',' +
                        singleQuote(strategy_entity_id) + ',' +
                        singleQuote(book_entity_id) + ',' +
                        singleQuote(summary_option) + ',' +
                        singleQuote(null) + ',' +
                        singleQuote(tenor_option) + ',' +
                        cmb_group1 + ',' +
                        cmb_group2 + ',' +
                        cmb_group3 + ',' +
                        cmb_group4 + ',' +'NULL, NULL, NULL, NULL,' +
                        singleQuote(option) +', NULL, NULL, NULL, NULL, NULL,' +
                        commodity_id + ',' +
                        singleQuote(deal_type) + ',' +
                        singleQuote(group_by) + ',' +
                        singleQuote(physical_financial_flag) + ',' +
                        deal_type_combo + ',' +
                        trader_id + ',' +
                        singleQuote(dt_term_start) + ',' +
                        singleQuote(dt_term_end) + ',' +
                        singleQuote(show_cross_tabformat) +', NULL,' +
                        deal_status + ',' +  
                        round_value + ", 'n', " +
                        counterparty_id + ", NULL, 'n', NULL, NULL, 'n', 'a', NULL," + singleQuote(subbook_entity_id);

                    open_grid_pivot('', 'trasfer_book_position', 0, pivot_exec_spa, 'Transfer Book Position'); 

                break;
                default:
                    dhtmlx.alert({title: "Information!", type: "alert", text: "Not implemented"});
                break;
            }
        }
          
    </script>
