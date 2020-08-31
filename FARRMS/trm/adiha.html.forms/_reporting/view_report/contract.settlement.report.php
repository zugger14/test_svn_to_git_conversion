<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
    <!--<style type="text/css">
    .dhxform_obj_dhx_web div.dhxform_item_label_left.browse_clear, .dhxform_obj_dhx_web div.dhxform_item_label_left.browse_open {
        top: -10px!important;
    } -->
    </style>
</head>
<body> 
    <?php 
        $active_object_id = get_sanitized_value($_POST['active_object_id'] ?? 'NULL');
        $report_type = get_sanitized_value($_POST['report_type'] ?? 'NULL');
        $report_id = get_sanitized_value($_POST['report_id'] ?? 'NULL');
        $report_name = get_sanitized_value($_POST['report_name'] ?? 'NULL');

        $layout_json = '[
                            {
                                id:             "a",
                                text:           "Contract Settlement Report",
                                header:         false
                            }
                        ]';
;
        $layout_name = 'contract_settlement_report_layout';
        $name_space = 'contract_settlement_report';
        $layout_obj = new AdihaLayout();
        echo $layout_obj->init_layout($layout_name, '', '1C', $layout_json, $name_space);
        
        echo $layout_obj->close_layout();
    ?> 
</body> 
      
<style>
    html, body {
        width: 100%;
        height: 100%;
        margin: 0px;
        padding: 0px;
        background-color: #ebebeb;
        overflow: hidden;
    }
	
    .dhxform_obj_dhx_web div.disabled div.dhxform_btn { border:none!important; }
</style>
    <script>
        var active_object_id = '<?php echo $active_object_id; ?>';
        var report_type = '<?php echo $report_type; ?>';
        var report_id = '<?php echo $report_id; ?>';
        var report_name = '<?php echo $report_name; ?>';
        var enable_combo_select_z = false;
        var enable_combo_select_e = false;
        report_ui = {};
        
        $(function(){
            data = {"action": "spa_create_application_ui_json",
                        "flag": "j",
                        "application_function_id": report_id,
                        "template_name": report_name,
                        "parse_xml": ""
                     };
            
            adiha_post_data('return_array', data, '', '', 'load_report_detail', '');
        });
        
        function load_report_detail(result) {
            var result_length = result.length;
            var tab_json = '';
            var num = 1;
            for (i = 0; i < result_length; i++) {
                if (i > 0)
                    tab_json = tab_json + ",";
                tab_json = tab_json + (result[i][1]);
            }
            
            tab_json = '{tabs: [' + tab_json + ']}';
            
            report_ui["report_tabs_" + active_object_id] = contract_settlement_report.contract_settlement_report_layout.cells("a").attachTabbar();
            report_ui["report_tabs_" + active_object_id].loadStruct(tab_json);
            
            tab_id = 'detail_tab_' + result[0][0];
            report_ui["form_" + active_object_id] = report_ui["report_tabs_" + active_object_id].cells(tab_id).attachForm();
            report_ui["form_" + active_object_id].loadStruct(result[0][2]);

            /*disable item for first time as default for a default combo selection*/
            report_ui["form_" + active_object_id].disableItem('deal_id');
            report_ui["form_" + active_object_id].disableItem('deal_filter');
            report_ui["form_" + active_object_id].disableItem('ref_id');
            report_ui["form_" + active_object_id].disableItem('enable_paging');
            report_ui["form_" + active_object_id].disableItem('drill_line_item');
            report_ui["form_" + active_object_id].checkItem('show_recent_calculation'); 
			report_ui["form_" + active_object_id].disableItem('as_of_date_from');
			report_ui["form_" + active_object_id].disableItem('as_of_date_to');
            report_ui["form_" + active_object_id].disableItem('browse_deal_filter');
            report_ui["form_" + active_object_id].disableItem('clear_deal_filter');
            
            var summary;

            report_ui["form_" + active_object_id].attachEvent("onChange", function (name, value){
              

                if (name == 'summary_option') { //combo

                    //report_ui["form_" + active_object_id].uncheckItem('show_recent_calculation');                   
                    report_ui["form_" + active_object_id].uncheckItem('enable_paging');
                    report_ui["form_" + active_object_id].checkItem('show_recent_calculation');
                    report_ui["form_" + active_object_id].enableItem('show_recent_calculation');
                    report_ui["form_" + active_object_id].enableItem('enable_paging');
                    report_ui["form_" + active_object_id].enableItem('ref_id');
                    report_ui["form_" + active_object_id].enableItem('deal_id');
                    report_ui["form_" + active_object_id].enableItem('as_of_date_from');
                    report_ui["form_" + active_object_id].enableItem('as_of_date_to');
                    report_ui["form_" + active_object_id].enableItem('prod_date_from');
                    report_ui["form_" + active_object_id].enableItem('deal_filter');
                    report_ui["form_" + active_object_id].enableItem('drill_line_item');
                    report_ui["form_" + active_object_id].enableItem('invoice_remittance');

                    enable_combo_select_z = false; 
                    enable_combo_select_e = false;

                    if ((value == 'a')||(value == 'b')||(value =='c')||(value == 'd')) {
                        
                        report_ui["form_" + active_object_id].setItemValue('deal_id', '');
                        report_ui["form_" + active_object_id].setItemValue('ref_id', '');
                        report_ui["form_" + active_object_id].setItemValue('drill_line_item', '');
                        report_ui["form_" + active_object_id].setItemValue('as_of_date_from', '');
                        report_ui["form_" + active_object_id].setItemValue('as_of_date_to', '');
                        report_ui["form_" + active_object_id].setItemValue('deal_filter', '');

                        report_ui["form_" + active_object_id].disableItem('deal_id');
                        report_ui["form_" + active_object_id].disableItem('ref_id');
                        report_ui["form_" + active_object_id].disableItem('drill_line_item');
						report_ui["form_" + active_object_id].disableItem('as_of_date_from');
						report_ui["form_" + active_object_id].disableItem('as_of_date_to');
                        report_ui["form_" + active_object_id].disableItem('browse_deal_filter');
                        report_ui["form_" + active_object_id].disableItem('clear_deal_filter');
                        report_ui["form_" + active_object_id].disableItem('enable_paging');

                        report_ui["form_" + active_object_id].checkItem('show_recent_calculation');  
                        summary = value;
 
                    } else if (value == 'z') { //Deal

                        report_ui["form_" + active_object_id].setItemValue('as_of_date_from', '');
                        report_ui["form_" + active_object_id].setItemValue('prod_date_from', '');
                        report_ui["form_" + active_object_id].setItemValue('drill_line_item', '');                        
                        report_ui["form_" + active_object_id].setItemValue('invoice_remittance', '');

                        report_ui["form_" + active_object_id].disableItem('as_of_date_from');
                        report_ui["form_" + active_object_id].disableItem('as_of_date_to');
                        report_ui["form_" + active_object_id].disableItem('prod_date_from');
                        report_ui["form_" + active_object_id].disableItem('deal_filter');   
                        report_ui["form_" + active_object_id].disableItem('drill_line_item'); 
                        report_ui["form_" + active_object_id].enableItem('browse_deal_filter');
                        report_ui["form_" + active_object_id].enableItem('clear_deal_filter');
                        report_ui["form_" + active_object_id].disableItem('invoice_remittance');
                        report_ui["form_" + active_object_id].checkItem('show_recent_calculation');  
                        // report_ui["form_" + active_object_id].uncheckItem('show_recent_calculation');
                        // report_ui["form_" + active_object_id].disableItem('show_recent_calculation');

                        report_ui["form_" + active_object_id].checkItem('enable_paging');
                        report_ui["form_" + active_object_id].disableItem('enable_paging');
                        enable_combo_select_z = true;
                        summary = value;

                    }else if (value == 'e') { //Line item

                        report_ui["form_" + active_object_id].setItemValue('as_of_date_from', '');
                        report_ui["form_" + active_object_id].setItemValue('prod_date_from', '');                     
                        report_ui["form_" + active_object_id].setItemValue('deal_id', '');
                        report_ui["form_" + active_object_id].setItemValue('ref_id', '');                       
                        report_ui["form_" + active_object_id].setItemValue('invoice_remittance', '');

                        report_ui["form_" + active_object_id].disableItem('as_of_date_from');
                        report_ui["form_" + active_object_id].disableItem('as_of_date_to');                        
                        report_ui["form_" + active_object_id].disableItem('prod_date_from');
                        report_ui["form_" + active_object_id].disableItem('browse_deal_filter');
                        report_ui["form_" + active_object_id].disableItem('clear_deal_filter');
                        report_ui["form_" + active_object_id].disableItem('deal_id');
                        report_ui["form_" + active_object_id].disableItem('ref_id');
                        report_ui["form_" + active_object_id].disableItem('invoice_remittance');
                        report_ui["form_" + active_object_id].checkItem('show_recent_calculation');  
                        // report_ui["form_" + active_object_id].uncheckItem('show_recent_calculation');
                        // report_ui["form_" + active_object_id].disableItem('show_recent_calculation');
                        
                        report_ui["form_" + active_object_id].checkItem('enable_paging');
                        report_ui["form_" + active_object_id].disableItem('enable_paging');
                        enable_combo_select_e = true;
                        summary = value;

                    }
                } 
                
                
                
               

				if (name == 'show_recent_calculation') {
                    //if ((!enable_combo_select_e) && (!enable_combo_select_z)) {
                        report_ui["form_" + active_object_id].setItemValue('as_of_date_from', '');
                        report_ui["form_" + active_object_id].setItemValue('as_of_date_to', '');

                        var check = report_ui["form_" + active_object_id].isItemChecked('show_recent_calculation');
                        if (summary == 'e') {
                            if (check) {
                            report_ui["form_" + active_object_id].disableItem('as_of_date_from');
                            report_ui["form_" + active_object_id].disableItem('as_of_date_to');
                            } 
                            else {
                                report_ui["form_" + active_object_id].disableItem('as_of_date_from');
                                report_ui["form_" + active_object_id].enableItem('as_of_date_to');
                            }
                        } else {
                            if (check) {
                            report_ui["form_" + active_object_id].disableItem('as_of_date_from');
                            report_ui["form_" + active_object_id].disableItem('as_of_date_to');
                            } 
                            else {
                                report_ui["form_" + active_object_id].enableItem('as_of_date_from');
                                report_ui["form_" + active_object_id].enableItem('as_of_date_to');
                            }
                            
                        }
                   // }
				}

            });
            
            var form_name = 'report_ui["form_" + ' + active_object_id + ']';
            attach_browse_event(form_name);
            
            var att_obj = contract_settlement_report.contract_settlement_report_layout.cells('a');
            parent.set_apply_filter(att_obj);
        }
        
         function return_as_of_date() {
            var inner_tab_obj = contract_settlement_report.contract_settlement_report_layout.cells("a").getAttachedObject();
            var as_of_date;
            inner_tab_obj.forEachTab(function(tab){
                var tab_name = tab.getText();
                 form_obj = tab.getAttachedObject();
                 var show_recent_calculation = form_obj.isItemChecked('show_recent_calculation');
                show_recent_calculation = (show_recent_calculation == true) ? "y" : "n";
                var summary_option = form_obj.getItemValue('summary_option');
                if(show_recent_calculation == 'n'){
               
                    if(summary_option == 'e' || summary_option == 'z'){
                        if (tab_name == 'General') {
                             as_of_date = form_obj.getItemValue('as_of_date_to', true);
                            
                        }
                    } else {
                         if (tab_name == 'General') {
                             as_of_date = form_obj.getItemValue('as_of_date_from', true);
                        }
                    }
                   
                } else {
                var today = new Date();
                var dd = today.getDate();
                var mm = today.getMonth()+1; //January is 0!
                var yyyy = today.getFullYear();
                
                if(dd<10) {
                    dd='0'+dd
                } 
                
                if(mm<10) {
                    mm='0'+mm
                } 
                
                today = yyyy + '-' + mm + '-' + dd;
                as_of_date = today;
                }
            })
            
            return as_of_date; 
        }
        
        function report_parameter() {
            var inner_tab_obj = contract_settlement_report.contract_settlement_report_layout.cells("a").getAttachedObject();
            var attached_obj;
            inner_tab_obj.forEachTab(function(tab){
                attached_obj = tab.getAttachedObject();
            });

            if (attached_obj instanceof dhtmlXForm) {                
                data = attached_obj.getFormData();
                var status = validate_form(attached_obj);
                var counterparty_id_value;
                var contract_id_value;
                var as_of_date_from_value;
                var as_of_date_to_value;
                var settlement_date_from_value;
                var settlement_date_to_value;
                var prod_date_from_value;
                var prod_date_to_value;
                var drill_line_item_value;
                var show_recent_calculation_value;
                

                if(status) {
                    var validation_status = true;
                    for (var a in data) {
                        field_label = a;
                        field_value = data[a];

                        if (field_label == "drill_line_item") {
                            drill_line_item_value = field_value;
                        }  
                        if (field_label == "show_recent_calculation") {
                            show_recent_calculation_value = field_value;
                        }                     
                    }

                    as_of_date_from_value = ("" + attached_obj.getItemValue("as_of_date_from", true) + ""); 
                    as_of_date_to_value = ("" + attached_obj.getItemValue("as_of_date_to", true) + "");  

                    settlement_date_from_value = ("" + attached_obj.getItemValue("settlement_date_from", true) + "");  
                    settlement_date_to_value = ("" + attached_obj.getItemValue("settlement_date_to", true) + "");  

                    prod_date_from_value = ("" + attached_obj.getItemValue("prod_date_from", true) + "");  
                    prod_date_to_value = ("" + attached_obj.getItemValue("prod_date_to", true) + "");  
                    
                  
                    //To bypass validation if the date is dynamic type
                    var static_as_of_date_from_value = get_static_date_value(as_of_date_from_value);
                    var static_as_of_date_to_value = get_static_date_value(as_of_date_to_value);
                    var static_settlement_date_from_value = get_static_date_value(settlement_date_from_value);
                    var static_settlement_date_to_value = get_static_date_value(settlement_date_to_value);
                    var static_prod_date_from_value = get_static_date_value(prod_date_from_value);
                    var static_prod_date_to_value = get_static_date_value(prod_date_to_value);
                    /*Parse all the date*/
                    var as_of_date_from_value_parse = (static_as_of_date_from_value == '') ? '' : Date.parse(as_of_date_from_value);
                    var as_of_date_to_value_parse = (static_as_of_date_to_value == '') ? '' : Date.parse(as_of_date_to_value);
                    var settlement_date_from_value_parse = (static_settlement_date_from_value == '') ? '' : Date.parse(settlement_date_from_value);
                    var settlement_date_to_value_parse = (static_settlement_date_to_value == '') ? '' : Date.parse(settlement_date_to_value);
                    var prod_date_from_value_parse = (static_prod_date_from_value == '') ? '' : Date.parse(prod_date_from_value);
                    var prod_date_to_value_parse = (static_prod_date_to_value == '') ? '' : Date.parse(prod_date_to_value);

                    // alert('as from date :'+ as_of_date_from_value_parse +'-:-'+ as_of_date_to_value_parse);
                    // alert('Delivery date :'+ prod_date_from_value_parse +'-:-'+ prod_date_to_value_parse);

                    /*Validation for the Date*/ 
                    if ((!enable_combo_select_z) && (!enable_combo_select_e) && (show_recent_calculation_value == "n")) {
                        if (as_of_date_from_value == "") {
                            show_messagebox('Please select <strong>As of Date From</strong>.');
                            validation_status = false;
                            //return;
                        }
                        else if (as_of_date_to_value == "") {
                            show_messagebox('Please select <strong>As of Date To</strong>.');
                            validation_status = false;
                        }
                        else if (as_of_date_from_value_parse > as_of_date_to_value_parse && as_of_date_from_value_parse != '' &&  as_of_date_to_value_parse != '') {
                            validation_status = false;
                            show_messagebox('<strong>As of Date From</strong> cannot be greater than <strong>As of Date To</strong>.');
                        }
                        else  if ((settlement_date_from_value != "") && (settlement_date_to_value != "") && (settlement_date_from_value_parse > settlement_date_to_value_parse)) {
                            validation_status = false;
                            show_messagebox('<strong>Settlement Date From</strong> cannot be greater than <strong>Settlement Date To</strong>.');
                        }
                        else  if ((prod_date_from_value != "") && (prod_date_to_value != "") && (prod_date_from_value_parse > prod_date_to_value_parse)) {
                            validation_status = false;
                            show_messagebox('<strong>Delivery Date From</strong> cannot be greater than <strong>Delivery Date To</strong>.'); 
                        }
                    }
                    else  if ((settlement_date_from_value != "") && (settlement_date_to_value != "") && (settlement_date_from_value_parse > settlement_date_to_value_parse)) {
                            validation_status = false;
                            show_messagebox('<strong>Settlement Date From</strong> cannot be greater than <strong>Settlement Date To</strong>.');
                    }
                    else  if ((prod_date_from_value != "") && (prod_date_to_value != "") && (prod_date_from_value_parse > prod_date_to_value_parse)) {
                            validation_status = false;
                            show_messagebox('<strong>Delivery Date From</strong> cannot be greater than <strong>Delivery Date To</strong>.'); 
                    }

                } else {
                    validation_status = false;    
                }

            }
            
            
            var param_list = new Array();
            var summary_option = attached_obj.getItemValue('summary_option');
            var spa_name;

           var counterparty_id_value =  attached_obj.getItemValue('counterparty_id');
			var counterparty_id_value_length  = counterparty_id_value.length;
            contract_id_value = attached_obj.getItemValue('contract_id');
			var contract_id_value_length = 0;
			if (    contract_id_value.indexOf(',')> -1) { 
					contract_id_value = contract_id_value.split(',');
					var  a = $.isArray(contract_id_value);
					contract_id_value_length = contract_id_value.length;
			}else { 
				contract_id_value_length = 1;
			}
			
           // var contract_id_value_length = contract_id_value.length;
            
            if (summary_option == 'z') { 
                var enable_paging = attached_obj.isItemChecked('enable_paging');
                enable_paging = (enable_paging == true) ? '1' : '0';
                
                if(enable_paging == '0'){
                    validation_status = false;
                    show_messagebox('Please select <strong>Apply Paging</strong>.');
                }
            }

            
            /*validation for specific select e - 'Detailed by the line item'*/
            if (enable_combo_select_e ){
                if (counterparty_id_value_length == 0) {
                    validation_status = false;
                    show_messagebox('Please select <strong>Counterparty</strong>.');
                }
                else if ($.isArray(counterparty_id_value) && counterparty_id_value.length > 1) {
                    validation_status = false;
                    show_messagebox('Please select only one item in <strong>Counterparty</strong>.')
                }

                else if (contract_id_value_length == 0) {
                    validation_status = false;
                    show_messagebox('Please select <strong>Contract</strong>.');
                }
                else if ( a = true && contract_id_value_length > 1) {
				
                    validation_status = false;
                    show_messagebox('Please select only one item in <strong>Contract</strong>.')
                }
                else if (drill_line_item_value == "") {
                    validation_status = false;
                    show_messagebox('Please select <strong>Charge Type</strong>.');     
                }
                else if (as_of_date_to_value == "" && (show_recent_calculation_value == "n")) {
                    validation_status = false;
                    show_messagebox('Plese select <strong>As of Date To</strong>.');
                }
                else if(prod_date_to_value == "" && (show_recent_calculation_value == "n")) {
                    validation_status = false;
                    show_messagebox('Plese select <strong>Delivery Date To</strong>.');
                }
			
            }

            /*Validation for specific select in combo - 'Detailed by deal'*/
            if ((enable_combo_select_z) && (counterparty_id_value_length == 0) && (show_recent_calculation_value == "n")){
                show_messagebox('Please select <strong>Counterparty</strong>');
                validation_status = false;
            }
            else if ((enable_combo_select_z) && (contract_id_value_length == 0) && (show_recent_calculation_value == "n")){
                show_messagebox('Please select <strong>Contract</strong>');
                 validation_status = false;
            }
            else if ((enable_combo_select_z) && (as_of_date_to_value == "") && (show_recent_calculation_value == "n")){
                validation_status = false;
                show_messagebox('Please select <strong>As of Date To</strong>.');
            }
            
             var filter_list = new Array();
             inner_tab_obj.forEachTab(function(tab){
                var tab_name = tab.getText();
                attached_obj = tab.getAttachedObject();
                form_obj = tab.getAttachedObject();
                var status = validate_form(form_obj);
                
                if (status == false) {
                    validate_flag = 1;
                }
                   form_obj.forEachItem(function(name) {
                    var item_type = form_obj.getItemType(name);
                    
                    if (item_type == 'calendar') {
                        value = form_obj.getItemValue(name, true);

                        if (value != '') { 
                            filter_list.push(form_obj.getItemLabel(name) + '="' + value + '"');
                        }
                    } else if (item_type == 'combo') {
                        var combo_obj = form_obj.getCombo(name);
                        value = combo_obj.getChecked();

                        if (value == '') {
                            value = combo_obj.getSelectedValue();
                            filter_value = combo_obj.getSelectedText();
                        }
                    if (value != '') { 
                            filter_list.push(form_obj.getItemLabel(name) + '="' + filter_value + '"');
                        }
                    } else if (item_type == 'checkbox') { 
                        if (name == 'enable_paging') {
                            var paging = form_obj.isItemChecked(name);
                            if (paging == true) { paging_flag = 1; }
                        }
                    } else if (item_type!= 'block' && item_type!= 'fieldset' && name!= 'report_id' && item_type!= 'button') {
                        value = form_obj.getItemValue(name);
                        filter_value = form_obj.getItemValue(name); 
                       if (name == 'label_counterparty_id' || name == 'label_contract_id'){
                           value = form_obj.getItemValue(name);
                           filter_list.push(form_obj.getItemLabel(name) + '="' + value + '"');
                       }              
                    } 
                 });
            });

            /*Preparing Data for calculation*/
            if (summary_option == 'e') {  //line item only
                spa_name = 'spa_gen_invoice_variance_report';

                var enable_paging = attached_obj.isItemChecked('enable_paging');
                enable_paging = (enable_paging == true) ? '1' : '0';
                
                var show_recent_calculation = attached_obj.isItemChecked('show_recent_calculation');
                show_recent_calculation = (show_recent_calculation == true) ? "y" : "n";

                param_list.push("'" + counterparty_id_value + "'");             
                param_list.push("'" + prod_date_to_value + "'");
                param_list.push("'" + contract_id_value + "'");
                param_list.push("NULL");//item
                param_list.push("'h'");//flag
                param_list.push("'" + as_of_date_to_value + "'");  
                param_list.push("NULL");//hour
                param_list.push("NULL");//actual_prod_date
                param_list.push("NULL");//deal_id
                param_list.push("NULL");//estimate_calculation(char)
                param_list.push("'" + attached_obj.getItemValue('drill_line_item') + "'");  
                param_list.push("NULL");//drill_Counterparty
                param_list.push("NULL");//drill_Contract
                param_list.push("NULL");//deal_detail_id
                param_list.push("NULL");//deal_list_table
                param_list.push("NULL");//invoice_type
                param_list.push("NULL");//settlement_date
                param_list.push("NULL");//is_dst (int)
                param_list.push("NULL");//invoice_number(int)
                param_list.push("'" + attached_obj.getItemValue('round_value') + "'");
                param_list.push("'" + show_recent_calculation + "'");  
                //param_list.push(enable_paging);
                
            } else {
                spa_name = 'spa_run_settlement_invoice_report';
                param_list.push("'" + summary_option + "'");
                param_list.push("'" + counterparty_id_value + "'");
                param_list.push("'" + contract_id_value + "'");
                param_list.push("'" + as_of_date_from_value + "'");
                param_list.push("'" + as_of_date_to_value + "'");
                param_list.push("'" + settlement_date_from_value + "'");
                param_list.push("'" + settlement_date_to_value + "'");                
                param_list.push("'" + prod_date_from_value + "'");
                param_list.push("'" + prod_date_to_value + "'");
                
                var enable_paging = attached_obj.isItemChecked('enable_paging');
                enable_paging = (enable_paging == true) ? "1" : "0"; 

                var show_recent_calculation = attached_obj.isItemChecked('show_recent_calculation');
                show_recent_calculation = (show_recent_calculation == true) ? "y" : "n";
                
                invoice_remittance_value = attached_obj.getItemValue('invoice_remittance');
                
                if(invoice_remittance_value == '' || invoice_remittance_value == null ){
                    invoice_remittance_value = 'NULL';
                } else if(invoice_remittance_value != '' &&  invoice_remittance_value != 'NULL') {
                    invoice_remittance_value = "'" + invoice_remittance_value + "'";
                }
                
               
                param_list.push("'" + show_recent_calculation + "'");       
                param_list.push("NULL");//drill_counterparty
                param_list.push("NULL");//drill_contract
                param_list.push("NULL");//drill_prod_month
                param_list.push("NULL");//drill_as_of_date
                param_list.push("'" + attached_obj.getItemValue('drill_line_item') + "'"); // Charge type
                param_list.push("'" + attached_obj.getItemValue('deal_id') + "'");
                param_list.push("'" + attached_obj.getItemValue('ref_id') + "'");
                param_list.push("NULL");//model_type
                param_list.push("'" + attached_obj.getItemValue('deal_filter') + "'");
                param_list.push("'" + attached_obj.getItemValue('round_value') + "'");
                param_list.push(invoice_remittance_value);
                param_list.push("'" + attached_obj.getItemValue('workflow_status') + "'");
                //param_list.push(enable_paging);
            }
            var param_string = param_list.toString();
            param_string = param_string.replace(/''/g, 'NULL');
            
            filter_list = filter_list.join(' | ') 

            /*Checking if the Paging in on or not and send the respective parameter*/
            if (validation_status == true) {
                if (enable_paging == 1) {
                    var exec_call  = "EXEC " + spa_name + " " + param_string + '&enable_paging=true&np=1' + '&applied_filters='+ filter_list;
                } else {
                    var exec_call  = "EXEC " + spa_name + " " + param_string + '&applied_filters='+ filter_list;
                }
            }
                       
            if (exec_call == null) {
                return false;
            } else {
                return exec_call
            }
        }
        
    </script>