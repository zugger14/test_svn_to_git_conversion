<?php
/**
* Run contract settlement screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html> 
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php  require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
    
</head>
    
<body class = "bfix">
    <?php 
    $php_script_loc = $app_php_script_loc;
    $app_user_loc = $app_user_name;
    
    $rights_process_invoice = 10221000;
    $rights_counterparty_invoice = 10221312;
    $rights_view_invoice = 10221300;

    list (
        $has_rights_process_invoice,
        $has_rights_counterparty_invoice,
        $has_rights_view_invoice
    ) = build_security_rights(
        $rights_process_invoice,
        $rights_counterparty_invoice,
        $rights_view_invoice
    );

    $term_start =date('Y-m-d');
    $month_ini = new DateTime("first day of last month");
    $month_end = new DateTime("last day of last month");

    $date_from= $month_ini->format('Y-m-d'); 
    $date_to= $month_end->format('Y-m-d'); 
    
    $json = '[
                {
                    id:             "a",
                    text:           "Apply Filter",
                    header:         true,
                    collapse:       true,
                    height:         100
                },
                {
                    id:             "b",
                    text:           "Filter Criteria",
                    header:         true,
                    collapse:       false,
                    height:         170
                },
                {
                    id:             "c",
                    text:           "Contract Settlement",
                    header:         true,
                    collapse:       false
                }  
            ]';
    
    $namespace = 'contract_settlement';
    $contract_settlement_layout_obj = new AdihaLayout();
    echo $contract_settlement_layout_obj->init_layout('contract_settlement_layout', '', '3E', $json, $namespace);
 
    //Attaching Filter form for Contract Settlement Grid 
    $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10221000', @template_name='contract settlement', @group_name='General'";
    $return_value1 = readXMLURL($xml_file);
    $form_json = $return_value1[0][2];
    echo $contract_settlement_layout_obj->attach_form('contract_settlement_form', 'b');
    $contract_settlement_form = new AdihaForm();
    echo $contract_settlement_form->init_by_attach('contract_settlement_form', $namespace);
    echo $contract_settlement_form->load_form($form_json);
    
    //Attaching Toolbar for Contract Settlement Grid
    $toolbar_json = '[
                        {id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif"},
                        {id:"process", text:"Run", img:"run.gif", imgdis:"run_dis.gif",enabled:"false"},
                        {id:"expand_collapse", text:"Expand/Collapse", img:"exp_col.gif", imgdis:"exp_col_dis.gif",enabled:"false"},
                        {id:"export", text:"Export", img:"export.gif", imgdis:"export_dis.gif", enabled:"false", items:[
                            {id:"excel", text:"Excel", img:"excel.gif"},
                            {id:"pdf", text:"PDF", img:"pdf.gif"}
                        ]},
                        {id:"pivot", text:"Pivot", img:"pivot.gif", imgdis:"pivot_dis.gif",enabled:"false"}
                    ]';
    echo $contract_settlement_layout_obj->attach_menu_layout_cell('contract_settlement_toolbar', 'c', $toolbar_json, 'contract_settlement_toolbar_onclick');
    
    echo $contract_settlement_layout_obj->close_layout();
    ?> 
    
    <div id="context_menu" style="display: none;">
        <div id="counterparty_invoice" text="Counterparty Invoice"></div>
        <!-- <div id="reprocess" text="Reprocess"></div> -->
        <div id="settlement_history" text="View Invoice"></div>
    </div>
</body>
    
    <style>
       html, body {
           width: 100%;
           height: 100%;
           margin: 0px;
           overflow: hidden;
       }
     
    </style>
    
    <script type="text/javascript">  
        var expand_state = 0;
        var has_rights_counterparty_invoice = <?php echo (($has_rights_counterparty_invoice) ? $has_rights_counterparty_invoice : '0'); ?>;
        var has_rights_view_invoice = <?php echo (($has_rights_view_invoice) ? $has_rights_view_invoice : '0'); ?>;
        var client_date_format = '<?php echo $date_format; ?>';
        //var theme_selected = 'dhtmlx_' + default_theme;
        var check_process_adjustment
        
        
        $(function(){
            attach_browse_event('contract_settlement.contract_settlement_form');
            contract_settlement.contract_settlement_form.setItemValue("as_of_date", "<?php echo $term_start;?>");
            contract_settlement.contract_settlement_form.setItemValue("date_from", "<?php echo $date_from;?>");
            contract_settlement.contract_settlement_form.setItemValue("date_to", "<?php echo $date_to;?>");
            contract_settlement.contract_settlement_form.attachEvent("onChange", function(name,value,is_checked){
                if (name == 'date_from') {
                    var date_from = contract_settlement.contract_settlement_form.getItemValue('date_from', true);
                    var split = date_from.split('-');
                    var year =  +split[0];
                    var month = +split[1];
                    var day = +split[2];

                    var date = new Date(year, month-1, day);
                    var lastDay = new Date(date.getFullYear(), date.getMonth() + 1, 0);
                    date_end = formatDate(lastDay);
                    contract_settlement.contract_settlement_form.setItemValue('date_to', date_end);
                } 
                // else if (name == 'process_adjustment'){
                //     contract_settlement_refresh();
                // }   
            });
            
            cmb_counterparty_obj = contract_settlement.contract_settlement_form.getCombo("counterparty_id");
            cmb_counterparty_obj.attachEvent("onCheck", load_contract_dropdown);
            cmb_counterparty_obj.setComboText('');
            cmb_contract_obj = contract_settlement.contract_settlement_form.getCombo("contract_id");
            cmb_contract_obj.setComboText('');
            cmb_counterparty_type_obj = contract_settlement.contract_settlement_form.getCombo("counterparty_type");
            cmb_counterparty_type_obj.attachEvent("onChange", load_counterparty_dropdown);
            
            filter_obj = contract_settlement.contract_settlement_layout.cells('a').attachForm();
            var layout_cell_obj = contract_settlement.contract_settlement_layout.cells('b');
            load_form_filter(filter_obj, layout_cell_obj, '10221000', 2);
            
            filter_obj.attachEvent("onChange", function(name, value){
                if(name == 'apply_filters') {
                    load_multiselect();
                }
            });
            
            load_counterparty_dropdown();
        });
        
        function show_run_popup() {
            var label_width = parseInt(ui_settings['field_size']) + parseInt(ui_settings['offset_left']);
            var cal_form_data = [
                                    {type: "settings", labelWidth: label_width, inputWidth: ui_settings['field_size'], position: "label-top", offsetLeft: ui_settings['offset_left']},
                                    {type: "calendar", name: "as_of_date", label: get_locale_value("As of Date"), "dateFormat": client_date_format},
                                    {type: "combo", name: "date_type", label: get_locale_value("Date Type"), "options":[{value:"t", text: "Delivery", selected: "true"}, {value: "s", text: "Settlement"}]},
                                    {type: "checkbox", name: "calculate_deal_settlement", label: get_locale_value("Calculate Deal Settlement"), position: "label-right"},
                                    {type: "button", value:get_locale_value("Ok"), img: "tick.png"}
                                ];
             
            
            var cal_popup = new dhtmlXPopup({ toolbar: contract_settlement.contract_settlement_toolbar, id: "process" });
            
            cal_popup.attachEvent("onShow", function(){
                var cal_form = cal_popup.attachForm(cal_form_data);
                var new_date = new Date();
                var date = new Date(new_date.getFullYear(), new_date.getMonth() , new_date.getDate());
                cal_form.setItemValue('as_of_date', date);
                
                cal_form.attachEvent("onButtonClick", function() {
					open_all_settlement();
                    var selected_row = contract_settlement.contract_settlement_grid.getSelectedRowId();
                    var contract_ids_arr = [];
                    var row_id_array = [];
                    if (selected_row) {
                        row_id_array  = selected_row.split(",");
                    } else {
                        contract_settlement.contract_settlement_grid.forEachRow(function(id){
                            row_id_array.push(id);
                        });
                    } 

                    for (count = 0; count < row_id_array.length; count++) {
                        var tree_level = contract_settlement.contract_settlement_grid.getLevel(row_id_array[count]);
                        var child = contract_settlement.contract_settlement_grid.getAllSubItems(row_id_array[count]); 
                        var child_array = [];
                        child_array = child.split(",");
                        if (tree_level == 0) {                  
                            for (var i = 0; i < child_array.length; i++) {
                                var sub_child = contract_settlement.contract_settlement_grid.getLevel(child_array[i]); 
                                if(sub_child == 2) { 
                                    var contract_id = contract_settlement.contract_settlement_grid.cells(child_array[i], '2').getValue();
                                    if(contract_ids_arr.indexOf(contract_id) == '-1' && contract_id != '') {
                                        contract_ids_arr.push(contract_id);
                                    }
                                } else if (sub_child == 1) {
                                    var contract_child = contract_settlement.contract_settlement_grid.getAllSubItems(child_array[i]);
                                    if (!contract_child) { //when conrtact has no charge type
                                        var level_1_contract_id = contract_settlement.contract_settlement_grid.cells(child_array[i], '2').getValue();
                                        if(contract_ids_arr.indexOf(level_1_contract_id) == '-1' && level_1_contract_id != '') {
                                            contract_ids_arr.push(level_1_contract_id);
                                        }
                                    }
                                }
                            } 
                        } else if (tree_level == 1) {  
                            for (var i = 0; i < child_array.length; i++) {
                                var sub_child = contract_settlement.contract_settlement_grid.getLevel(child_array[i]); 
                                if (sub_child == -1) { //when conrtact has no charge type
                                    var contract_id = contract_settlement.contract_settlement_grid.cells(row_id_array[count], '2').getValue();
                                    if(contract_ids_arr.indexOf(contract_id) == '-1' && contract_id != '') {
                                        contract_ids_arr.push(contract_id);
                                    }
                                } else if(sub_child == 2) { 
                                    var contract_id = contract_settlement.contract_settlement_grid.cells(child_array[i], '2').getValue();
                                    if(contract_ids_arr.indexOf(contract_id) == '-1' && contract_id != '') {
                                        contract_ids_arr.push(contract_id);
                                    }
                                } 
                            }  
                        }else {  
                            if (contract_settlement.contract_settlement_grid.cells(row_id_array[count],0).getValue() != '') {
                                var contract_id = contract_settlement.contract_settlement_grid.cells(row_id_array[count], '2').getValue();
                                if(contract_ids_arr.indexOf(contract_id) == '-1' && contract_id != '') {
                                    contract_ids_arr.push(contract_id);
                                }
                            }
                        }
                        
                    }  
                    var contract_ids = contract_ids_arr.join(); 
                    //alert('Contract ids for validation:'+ contract_ids);
                    var as_of_date = cal_form.getItemValue('as_of_date', true);
                    var calculate_deal_settlement = cal_form.isItemChecked('calculate_deal_settlement');
                    var date_type = cal_form.getItemValue('date_type')
                    if (calculate_deal_settlement == true) { calculate_deal_settlement = 'y'; } else {calculate_deal_settlement = 'n';}
    
                    data_for_post = { 'action': 'spa_close_measurement_books_dhx', 
                                      'flag': 'v',
                                      'as_of_date': dates.convert_to_sql(as_of_date),
                                      'contract_id': contract_ids
                                    };
                        
                    var data = $.param(data_for_post);
                    
                    $.ajax({
                        type: "POST",
                        dataType: "json",
                        url: js_form_process_url,
                        async: true,
                        data: data,
                        success: function(data) {
                            response_data = data["json"];
                            if (response_data[0].validation == 'true') {
                                
                                var selected_row = contract_settlement.contract_settlement_grid.getSelectedRowId();
                                if (selected_row == null) {
                                    dhtmlx.message({
                                        type: "confirm",
                                        title: get_locale_value("Confirmation"),
                                        text: get_locale_value("Are you sure you want to process all data?"),
                                        ok: get_locale_value("Confirm"),
										cancel:get_locale_value("Cancel"),
                                        callback: function(result) {
                                            if (result)
                                                contract_settlement_process_callback(as_of_date, calculate_deal_settlement, date_type);
                                        }
                                    });
                                } else {
                                    contract_settlement_process_callback(as_of_date, calculate_deal_settlement, date_type);
                                }
                            } else {
                                show_messagebox('Accounting Period ' + as_of_date + ' has already been closed.');
                            }
                        }
                    });
                    cal_popup.hide();
                });
            });

            cal_popup.attachEvent("onBeforeHide", function(type, ev, id){
                if (type == 'click' || type == 'esc') {
                    cal_popup.hide();
                    return true;
                }
            });
            
            var height = contract_settlement.contract_settlement_layout.cells('b').getHeight();
            cal_popup.show(100,height+30,45,45);
            
        }
        
        function load_contract_dropdown() {
            var counterparty_ids = cmb_counterparty_obj.getChecked().join(',');
            var cm_param = {
                "action"            : 'spa_settlement_history',
                "call_from"         : "form",
                "has_blank_option"  : "false",
                "flag"              : 'i',
                "counterparty_id"   :counterparty_ids
            };

            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;
            var cmb_contract_obj = contract_settlement.contract_settlement_form.getCombo('contract_id');
            cmb_contract_obj.clearAll();
            cmb_contract_obj.setComboText('');
            cmb_contract_obj.load(url);
        }
        
        function load_counterparty_dropdown() {
            var counterparty_type = cmb_counterparty_type_obj.getSelectedValue();
            
            var cm_param = {
                "action"                : "spa_source_counterparty_maintain",
                "flag"                  : "c",
                "call_from"             : "form",
                "has_blank_option"      : "false",
                "int_ext_flag"          : counterparty_type
            };

            cm_param = $.param(cm_param);
            var url = js_dropdown_connector_url + '&' + cm_param;
            var cmb_contract_obj = contract_settlement.contract_settlement_form.getCombo('counterparty_id');
            cmb_contract_obj.clearAll();
            cmb_contract_obj.setComboText('');
            cmb_contract_obj.load(url, function(){
                load_multiselect();
            });
            
        }


        //function to formatDate
        function formatDate(date) {
            var d = new Date(date),
                month = '' + (d.getMonth() + 1),
                day = '' + d.getDate(),
                year = d.getFullYear();

            if (month.length < 2) month = '0' + month;
            if (day.length < 2) day = '0' + day;

            return [year, month, day].join('-');
        }
        
        /**
         * [Toolbar onclick function for Contract Settlement Grid]
         */
        function contract_settlement_toolbar_onclick(name) {
            var php_script_loc = '<?php echo $php_script_loc; ?>';
            if (name == 'refresh') {
                contract_settlement_refresh();
            } else if (name == 'process') {
                contract_settlement_process();
            } else if (name == 'expand_collapse') {
                if (expand_state == 0) {
                    open_all_settlement();
                } else {
                    close_all_settlement();
                }   
            } else if (name == 'excel') {
                contract_settlement.contract_settlement_grid.toExcel(php_script_loc + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
            } else if (name == 'pdf') {
                contract_settlement.contract_settlement_grid.toPDF(php_script_loc +'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
            } else if (name == 'pivot') {
                var grid_obj = contract_settlement.contract_settlement_grid;
                open_grid_pivot(grid_obj, 'contract_settlement_grid', 3, pivot_exec_spa, 'Contract Settlement');
            }
        }
        
        /**
         * [Refresh function of COntract Settlement Grid]
         */
        function contract_settlement_refresh() { 
            contract_settlement.contract_settlement_layout.cells('c').progressOn();
            expand_state = 0;
            var php_script_loc = '<?php echo $php_script_loc; ?>';
            contract_settlement.contract_settlement_toolbar.setItemDisabled('process');
            contract_settlement.contract_settlement_toolbar.setItemEnabled('pivot');
            
            var status = validate_form(contract_settlement.contract_settlement_form);
            
            if (status == false) { 
                contract_settlement.contract_settlement_layout.cells('c').progressOff();
                return; 
            }
            contract_settlement.contract_settlement_layout.cells('b').collapse();
            contract_settlement.contract_settlement_layout.cells('a').collapse();
            //Set the name of button as Process or Reprocess
            var show_processed = contract_settlement.contract_settlement_form.isItemChecked('show_processed');
            if (show_processed == true) {
                contract_settlement.contract_settlement_toolbar.setItemText(get_locale_value('process'), get_locale_value('Rerun'));
            } else{
                contract_settlement.contract_settlement_toolbar.setItemText(get_locale_value('process'), get_locale_value('Run'));
            }
           
            var counterparty_obj = contract_settlement.contract_settlement_form.getCombo('counterparty_id');
            var counterparty_id = counterparty_obj.getChecked();
            counterparty_id = counterparty_id.toString();
            var contract_obj = contract_settlement.contract_settlement_form.getCombo('contract_id');
            var contract_id = contract_obj.getChecked('contract_id');
            contract_id = contract_id.toString();
            var counterparty_type = contract_settlement.contract_settlement_form.getItemValue('counterparty_type');
            var commodity = contract_settlement.contract_settlement_form.getItemValue('commodity');
            
            var as_of_date = contract_settlement.contract_settlement_form.getItemValue('as_of_date', true);
            //var date_type = contract_settlement.contract_settlement_form.getItemValue('date_type');
            var date_from = contract_settlement.contract_settlement_form.getItemValue('date_from', true);
            var date_to = contract_settlement.contract_settlement_form.getItemValue('date_to', true);
            
            if (date_to < date_from) {
                show_messagebox('Date To should be greater than Date From.');
                contract_settlement.contract_settlement_layout.cells('c').progressOff();
                return;
            }
            
            var deal_filter = contract_settlement.contract_settlement_form.getItemValue('label_deal_filter');
            deal_filter = deal_filter.toString();
            var deal_id = contract_settlement.contract_settlement_form.getItemValue('deal_id');
            var reference_id = contract_settlement.contract_settlement_form.getItemValue('reference_id');
            var meter_id = contract_settlement.contract_settlement_form.getItemValue('meter_id');
            meter_id = meter_id.toString();
            
            var detail_by_deal = contract_settlement.contract_settlement_form.isItemChecked('detail_by_deal');
            if (detail_by_deal == true) { detail_by_deal = 'd'; } else {detail_by_deal = 'c';}
            var calculate_deal_settlement = contract_settlement.contract_settlement_form.isItemChecked('calculate_deal_settlement');
            if (calculate_deal_settlement == true) { calculate_deal_settlement = 'y'; } else {calculate_deal_settlement = 'n';}
            var show_processed = contract_settlement.contract_settlement_form.isItemChecked('show_processed');
            if (show_processed == true) { show_processed = 'y'; } else {show_processed = 'n';}

            var process_adjustment = contract_settlement.contract_settlement_form.isItemChecked('process_adjustment');
            if (process_adjustment == true) { process_adjustment = 'y'; } else {process_adjustment = 'n';}

            if(process_adjustment == 'y') {
                show_processed = 'y';
                check_process_adjustment = true;
            } else {
                check_process_adjustment = false;
            }
    
            contract_settlement.contract_settlement_layout.cells('c').attachStatusBar({
                                height: 30,
                                text: '<div id="pagingArea_b"></div>'
                            });
            
            /* Creating the Contract Settlement Grid */            
            contract_settlement.contract_settlement_grid = contract_settlement.contract_settlement_layout.cells('c').attachGrid();
            // console.log(php_script_loc + 'components/lib/adiha_dhtmlx/themes/' + theme_selected + '/imgs/dhxtoolbar_web/');
            contract_settlement.contract_settlement_grid.setImagePath(js_image_path + "dhxgrid_web/");
                        
            if (show_processed == 'y') {
                contract_settlement.contract_settlement_grid.setHeader(get_locale_value("Invoice ID,Charge Type,Counterparty ID, Contract ID, Charge Type ID, Date From, Date To, Settlement Date, Invoice ID, Calc ID, Invoice Rec ID, Invoice Type",true));
            } else {
                contract_settlement.contract_settlement_grid.setHeader(get_locale_value("Counterparty/Contract,Charge Type,Counterparty ID, Contract ID, Charge Type ID, Date From, Date To, Settlement Date, Invoice ID, Calc ID, Invoice Rec ID, Invoice Type",true));
            }
            
            contract_settlement.contract_settlement_grid.setColTypes("tree,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro");
            contract_settlement.contract_settlement_grid.setColSorting("str,str,str,str,str,date,date,str,str,str,str,str");

            if (show_processed == 'y') {
                contract_settlement.contract_settlement_grid.setColumnsVisibility("false,true,true,true,true,false,false,false,true,true,true,true");
            } else {
                contract_settlement.contract_settlement_grid.setColumnsVisibility("false,true,true,true,true,false,false,true,true,true,true,true");
            }
                 
            
            contract_settlement.contract_settlement_grid.setInitWidths('670,0,0,0,150,200,200,200,180,150,150');
            contract_settlement.contract_settlement_grid.enableMultiselect(true);
            contract_settlement.contract_settlement_grid.setPagingWTMode(true,true,true,[5,10,20,30,40,50,60,70,80,90,100]);
            contract_settlement.contract_settlement_grid.enablePaging(true,100, 0, 'pagingArea_b'); 
            contract_settlement.contract_settlement_grid.setPagingSkin('toolbar'); 
            contract_settlement.contract_settlement_grid.init();
            contract_settlement.contract_settlement_grid.attachEvent("onRowDblClicked", function(rId,cInd){
                contract_settlement.expand_settlement();
            });

            pivot_exec_spa = "EXEC spa_contract_settlement @flag='" + detail_by_deal 
                                                        + "',@counterparty_id='" + counterparty_id 
                                                        + "',@contract_id='" + contract_id 
                                                        + "',@date_to='" + date_to 
                                                        + "',@date_from='" + date_from 
                                                        + "',@show_processed='" + show_processed 
                                                        + "',@deal_id='" + deal_filter 
                                                        + "',@meter_id='" + meter_id 
                                                        + "',@commodity='" + commodity 
                                                        + "',@counterparty_type='" + counterparty_type
                                                        + "',@process_adjustment='" + process_adjustment + "'";
            
            /* When detail_by_deal is not checked */
            if (detail_by_deal == 'c') {
                var history_a_param = {
                    "flag": detail_by_deal,
                    "action": "spa_contract_settlement",
                    "grid_type": "tg",
                    "grouping_column": "Counterparty,Contract,charge_type",
                    "counterparty_id": counterparty_id,
                    "contract_id": contract_id,
                    "date_to": date_to,
                    "date_from": date_from,
                    "show_processed": show_processed,
                    //"date_type": date_type,
                    "deal_id": deal_filter,
                    "meter_id": meter_id,
                    "commodity": commodity,
                    "counterparty_type": counterparty_type,
                    "process_adjustment": process_adjustment
                };
            /* When detail_by_deal is checked */
            } else {
                var history_a_param = {
                    "flag": detail_by_deal,
                    "action": "spa_contract_settlement",
                    "grid_type": "tg",
                    "grouping_column": "Counterparty,Contract,charge_type",
                    "counterparty_id": counterparty_id,
                    "contract_id": contract_id,
                    "date_to": date_to,
                    "date_from": date_from,
                    "show_processed": show_processed,
                    "deal_id": deal_id,
                    "deal_id_filter": deal_filter,
                    "ref_id": reference_id,
                    "commodity": commodity,
                    "counterparty_type": counterparty_type,
                    "process_adjustment": process_adjustment
                    //,
                   // "date_type": date_type
                };
            }
           
            history_a_param = $.param(history_a_param);
            var history_a_url = js_data_collector_url + "&" + history_a_param;
            contract_settlement.contract_settlement_grid.loadXML(history_a_url, function(){
                open_all_settlement();
                contract_settlement.contract_settlement_layout.cells('c').progressOff();
            });
            contract_settlement.contract_settlement_grid.enableTreeCellEdit(false);
            load_context_menu();
            contract_settlement.contract_settlement_toolbar.setItemEnabled('expand_collapse');
            contract_settlement.contract_settlement_toolbar.setItemEnabled('process');
            contract_settlement.contract_settlement_toolbar.setItemEnabled('export');
        }
        
        /**
         * [Function to expand/collapse settlement Grid when double clicked]
         */
        contract_settlement.expand_settlement = function(r_id, col_id) {
            var selected_row = contract_settlement.contract_settlement_grid.getSelectedRowId();
            var state = contract_settlement.contract_settlement_grid.getOpenState(selected_row);
            
            if (state)
                contract_settlement.contract_settlement_grid.closeItem(selected_row);
            else
                contract_settlement.contract_settlement_grid.openItem(selected_row);
        }
        
        /**
        *[open the node]
        */
        open_all_settlement = function() {
           contract_settlement.contract_settlement_grid.expandAll();
           expand_state = 1;
        }

        /**
        *[close the node]
        */
        close_all_settlement = function() {
           contract_settlement.contract_settlement_grid.collapseAll();
           expand_state = 0;
        }
        
        /**
         * [Load the context menu when right clicked on the grid]
         */
        function load_context_menu() {
            context_menu = new dhtmlXMenuObject();
            context_menu.renderAsContextMenu();
            context_menu.loadFromHTML("context_menu", false);
            contract_settlement.contract_settlement_grid.enableContextMenu(context_menu);
            
            contract_settlement.contract_settlement_grid.attachEvent("onBeforeContextMenu", function(rowId,celInd,grid) {
                context_menu_rowid = rowId;
                var invoice_type_row = contract_settlement.contract_settlement_grid.getSelectedRowId();
                var invoice_type = contract_settlement.contract_settlement_grid.cells(invoice_type_row, 11).getValue();
                
                context_menu.forEachItem(function(itemId){
                    context_menu.hideItem(itemId);
                });
                
                var detail_by_deal = contract_settlement.contract_settlement_form.isItemChecked('detail_by_deal');
                var show_processed = contract_settlement.contract_settlement_form.isItemChecked('show_processed'); 
                
                if (detail_by_deal == false) {
                    if (show_processed == true) {
                        var tree_level = contract_settlement.contract_settlement_grid.getLevel(rowId);
                        if (tree_level == 2) {
                            if (invoice_type == 'r')
                                context_menu.showItem('counterparty_invoice');
                            
                            context_menu.showItem('settlement_history');
                            
                            if (!has_rights_counterparty_invoice) {
                                if (invoice_type == 'r')
                                    context_menu.setItemDisabled('counterparty_invoice');
                            }
                            if (!has_rights_view_invoice)
                                context_menu.setItemDisabled('settlement_history');
                            
                        }
                    } 
                    /*
                    else {
                        var tree_level = contract_settlement.contract_settlement_grid.getLevel(rowId);
                        if (tree_level == 2) {
                            context_menu.showItem('counterparty_invoice');
                            
                            if (!has_rights_counterparty_invoice)
                                context_menu.setItemDisabled('counterparty_invoice');
                        }
                    }
                    */
                }
                return true;
            });
            
            context_menu.attachEvent("onClick", function(menuitemId, zoneId) {
                switch (menuitemId) {
                    case 'counterparty_invoice':
                        insert_invoice(context_menu_rowid);
                        break;
                    case 'settlement_history':
                        open_settlement_history(context_menu_rowid);
                        break;
                } 
            });
        }
        
        /**
         * [insert_invoice Open window to insert the invoice]
         * @param row_id    Context menu clicked row id
         */
        function insert_invoice(row_id) {
            var js_path = '<?php echo $app_php_script_loc; ?>';
            var js_path_trm = '<?php echo $app_adiha_loc; ?>';

            counterparty_invoice_window = new dhtmlXWindows();
            var counterparty_id = contract_settlement.contract_settlement_grid.cells(row_id, '1').getValue();
            var contract_id = contract_settlement.contract_settlement_grid.cells(row_id, '2').getValue();
            var as_of_date = contract_settlement.contract_settlement_grid.cells(row_id, '4').getValue();
            var prod_date = contract_settlement.contract_settlement_grid.cells(row_id, '5').getValue();
            var show_processed = contract_settlement.contract_settlement_form.isItemChecked('show_processed');  
            var inv_rec_id = contract_settlement.contract_settlement_grid.cells(row_id, '10').getValue();
            
            var src = js_path_trm + 'adiha.html.forms/_settlement_billing/maintain_invoice/counterparty.invoice.php?counterparty_id=' + counterparty_id + '&contract_id=' + contract_id + '&as_of_date=' + as_of_date + '&prod_date=' + prod_date + '&processed=' + show_processed + '&inv_rec_id=' + inv_rec_id; 
            counterparty_invoice_obj = counterparty_invoice_window.createWindow('w1', 0, 0, 950, 600);
            counterparty_invoice_obj.setText("Counterparty Invoice");

            counterparty_invoice_obj.centerOnScreen();
            counterparty_invoice_obj.setModal(true);
            counterparty_invoice_obj.attachURL(src, false, true);
        }
        
        /**
         * [To process the grid data]
         */
        function contract_settlement_process() {
            //Check if there is data in grid
            var attach_grid = contract_settlement.contract_settlement_layout.cells('c').getAttachedObject();
            if (attach_grid == undefined) {
                show_messagebox('No data in grid');
                return;
            }
            
            var row_count = contract_settlement.contract_settlement_grid.getRowsNum();
            if (row_count == 0) {
                show_messagebox('No data in grid');
                return;
            }
            show_run_popup();
        }
        
        function contract_settlement_process_callback(as_of_date, calculate_deal_settlement, date_type) {
            var detail_by_deal = contract_settlement.contract_settlement_form.isItemChecked('detail_by_deal');
            if (detail_by_deal == true) { detail_by_deal = 'd'; } else {detail_by_deal = 'c';}
            //var date_type = contract_settlement.contract_settlement_form.getItemValue('date_type');
            var date_from = contract_settlement.contract_settlement_form.getItemValue('date_from', true);
            var date_to = contract_settlement.contract_settlement_form.getItemValue('date_to', true);
            var counterparty_type = contract_settlement.contract_settlement_form.getItemValue('counterparty_type');
            
            var counterparty_id_arr = new Array();
            var contract_id_arr = new Array();
            var charge_type_id_arr = new Array();
            var calc_id_arr = new Array(); 

            var selected_row = contract_settlement.contract_settlement_grid.getSelectedRowId();
            /* To get all the row_id if the grid is unselected */
            if (selected_row == null) {
                var selected_row_arr = new Array();
                var all_row_id = contract_settlement.contract_settlement_grid.getAllRowIds();
                var all_row_id_arr = new Array();
                all_row_id_arr = all_row_id.split(',');

                for (i = 0; i < all_row_id_arr.length; i++) {
                    var id_level = contract_settlement.contract_settlement_grid.getLevel(all_row_id_arr[i]);
                    if (id_level == 2) {
                        selected_row_arr.push(all_row_id_arr[i]);
                    }
                }
            /* To get row_id of the selected row */
            } else {
                var selected_row_arr = new Array();
                selected_row_arr = selected_row.split(',');
            }

            /* To find the counterparty_id, contract_id and charge_type_id of the selected rows */
            for (i = 0; i < selected_row_arr.length; i++) {
                var tree_level = contract_settlement.contract_settlement_grid.getLevel(selected_row_arr[i]);
                var process_row = '';
                
                if (tree_level == 0) {   
                    var child = contract_settlement.contract_settlement_grid.getAllSubItems(selected_row_arr[i]);  
                    var child_array = [];
                    var sub_sub_child_array = new Array();
                    child_array = child.split(",");  
                    process_row = child_array[1];

                    for (var count = 0; count < child_array.length; count++) {
                        //added for getting charge type id if available when running by selecting level 0 tree
                        var sub_child_list = contract_settlement.contract_settlement_grid.getAllSubItems(child_array[count]);
                        var sub_child_list_arr = new Array();
                        
                        sub_child_list_arr = sub_child_list.split(','); 
                        for (var zi = 0; zi < sub_child_list_arr.length; zi++) {
                             var sub_sub_child_level = contract_settlement.contract_settlement_grid.getLevel(sub_child_list_arr[zi]); 
                             if (sub_sub_child_level == 2){
                                var chr_id = contract_settlement.contract_settlement_grid.cells(sub_child_list_arr[zi], '3').getValue();
                                if (charge_type_id_arr.indexOf(chr_id) == -1) {  charge_type_id_arr.push(chr_id); }
                                var c_id = contract_settlement.contract_settlement_grid.cells(sub_child_list_arr[zi], '9').getValue();
                                if (calc_id_arr.indexOf(c_id) == -1) {  calc_id_arr.push(c_id); }
                             }
                        }
                        //end
                       
                        var sub_child = contract_settlement.contract_settlement_grid.getLevel(child_array[count]); 
                        
                        if(sub_child == 2) {  
                            contract_id = contract_settlement.contract_settlement_grid.cells(child_array[count], '2').getValue();  
                            if(contract_id_arr.indexOf(contract_id) == '-1' && contract_id != '') {
                                contract_id_arr.push(contract_id);
                            }
                            process_row = child_array[1];
                        } else if (sub_child == 1) { 
                            var contract_child = contract_settlement.contract_settlement_grid.getAllSubItems(child_array[count]); 
                            if (!contract_child) { //when contract has no charge type
                                var level_1_contract_id = contract_settlement.contract_settlement_grid.cells(child_array[count], '2').getValue(); 
                                if(contract_id_arr.indexOf(level_1_contract_id) == '-1' && level_1_contract_id != '') {
                                    contract_id_arr.push(level_1_contract_id);
                                }
                                process_row = child_array[0];  
                            } else {
                                process_row = child_array[1];
                            }
                        }
                    }
                } else if (tree_level == 1) {  
                   var child = contract_settlement.contract_settlement_grid.getSubItems(selected_row_arr[i]);
                    if (!child) {  
                        var level_1_contract_id = contract_settlement.contract_settlement_grid.cells(selected_row_arr[i], '2').getValue();
                        if(contract_id_arr.indexOf(level_1_contract_id) == '-1' && level_1_contract_id != '') {
                            contract_id_arr.push(level_1_contract_id);
                        }   
                        process_row = selected_row_arr[i];
                    } else {
                        var sub_child_list = contract_settlement.contract_settlement_grid.getAllSubItems(selected_row_arr[i]);
                        var sub_child_arr = new Array();
                        var sub_child_arr = sub_child_list.split(','); 
                        for (var ci = 0; ci < sub_child_arr.length; ci++) {
                            var chr_id = contract_settlement.contract_settlement_grid.cells(sub_child_arr[ci], '3').getValue();
                            if (charge_type_id_arr.indexOf(chr_id) == -1) {  charge_type_id_arr.push(chr_id); }
                            var c_id = contract_settlement.contract_settlement_grid.cells(sub_child_arr[ci], '9').getValue();
                            if (calc_id_arr.indexOf(c_id) == -1) {  calc_id_arr.push(c_id); }
                        }      

                        var child_id_array = child.split(',');
                        process_row = child_id_array[0];
                    }         
                } else if (tree_level == 2) { 
                    var level_1_contract_id = contract_settlement.contract_settlement_grid.cells(selected_row_arr[i], '2').getValue(); 
                    if(contract_id_arr.indexOf(level_1_contract_id) == '-1' && level_1_contract_id != '') {
                        contract_id_arr.push(level_1_contract_id);
                    }   
                    process_row = selected_row_arr[i] 
                }   
            
                var cou_id = contract_settlement.contract_settlement_grid.cells(process_row, '1').getValue(); 
 
                if (counterparty_id_arr.indexOf(cou_id) == -1) { counterparty_id_arr.push(cou_id); }
               
                if (tree_level == 1 ) {
                    var con_id = contract_settlement.contract_settlement_grid.cells(process_row, '2').getValue();
                    if (contract_id_arr.indexOf(con_id) == -1) {  contract_id_arr.push(con_id); }
                }

                if (tree_level >= 2) {
                    var chr_id = contract_settlement.contract_settlement_grid.cells(process_row, '3').getValue();
                    if (charge_type_id_arr.indexOf(chr_id) == -1) {  charge_type_id_arr.push(chr_id); }
                    var c_id = contract_settlement.contract_settlement_grid.cells(process_row, '9').getValue();
                    if (calc_id_arr.indexOf(c_id) == -1) {  calc_id_arr.push(c_id); }
                }
            }   
            var counterparty_id = counterparty_id_arr.toString();
            var contract_id = contract_id_arr.toString();
            var charge_type_id = charge_type_id_arr.toString();
            var calc_id = calc_id_arr.toString();
            //alert(counterparty_id + ',' + contract_id + ',' + charge_type_id); return;
            if (contract_id == '') { contract_id = 'NULL'; }
            if (charge_type_id == '') { charge_type_id = 'NULL'; }
                
            var deal_ids = ''
            if (detail_by_deal == 'c') {
                deal_ids = 'NULL';
            } else if (detail_by_deal == 'd') {
                deal_ids = charge_type_id;
                charge_type_id = 'NULL';
            }
            
            var show_processed = contract_settlement.contract_settlement_form.isItemChecked('show_processed');  
            if (show_processed == true) {
                charge_type_id = 'NULL';
            } else {
                if (calc_id == '') { calc_id == 'NULL'; }
                calc_id = 'NULL';
            } 

           // alert('contract_id for run:'+contract_id);
           // alert('counterparty id for run:'+counterparty_id); 
            
           if(check_process_adjustment) {
                var exec_call = "EXEC spa_calc_true_up "
                                + " @prod_date = " + singleQuote(date_from)
                                + ", @prod_date_to = " + singleQuote(date_to)
                                + ", @as_of_date = " + singleQuote(dates.convert_to_sql(as_of_date))
                                + ", @contract_id_param = " + singleQuote(contract_id)
                                + ", @counterparty_id = " + singleQuote(counterparty_id)
                                + ", @calc_id = " + singleQuote(calc_id);
     
            } else {
                var exec_call = "EXEC spa_process_settlement_invoice " 
                                + "NULL"
                                + "," + singleQuote(date_from)
                                + "," + singleQuote(dates.convert_to_sql(as_of_date))
                                + "," + singleQuote(counterparty_id)
                                + ",'n'"
                                + "," + singleQuote(contract_id)
                                + ",NULL"
                                + ",'n'"
                                + ",'stlmnt'"
                                + "," + singleQuote(charge_type_id)
                                + "," + singleQuote(deal_ids)
                                + ",NULL"
                                + "," + singleQuote(date_to)
                                + "," + singleQuote(calculate_deal_settlement)
                                + "," + singleQuote(counterparty_type)
                                + ",NULL"
                                + "," + singleQuote(date_type)
                                + ",NULL, 'n'";
            }

            var param = 'call_from=Run_Settlement_Process_Job&gen_as_of_date=1&batch_type=c&as_of_date=' + dates.convert_to_sql(as_of_date); 
            adiha_run_batch_process(exec_call, param, 'Process Invoice');
        }
        
        /**
         * [open_settlement_history Open the settlement history for the invoice, when clicked on settlement history in context menu]
         */
        function open_settlement_history(row_id) {
            var js_path = '<?php echo $app_php_script_loc; ?>';
            var js_path_trm = '<?php echo $app_adiha_loc; ?>';
            //var counterparty = contract_settlement.contract_settlement_grid.cells(row_id, '0').getValue();
            //alert(counterparty);
            var counterparty_id = contract_settlement.contract_settlement_grid.cells(row_id, '1').getValue();
            var contract_id = contract_settlement.contract_settlement_grid.cells(row_id, '2').getValue();
            var date_from = contract_settlement.contract_settlement_grid.cells(row_id, '5').getValue();
            var date_to = contract_settlement.contract_settlement_grid.cells(row_id, '6').getValue();
            var invoice_id = contract_settlement.contract_settlement_grid.cells(row_id, '8').getValue();
            
            var date_from = dates.convert_to_sql(date_from);
            var date_to = dates.convert_to_sql(date_to);
            
            var contract = contract_settlement.contract_settlement_grid.getParentId(row_id);
            var counterparty = contract_settlement.contract_settlement_grid.getParentId(contract);
            contract = contract_settlement.contract_settlement_grid.cells(contract, '0').getValue();
            counterparty = contract_settlement.contract_settlement_grid.cells(counterparty, '0').getValue();
            
            var counterparty_type = contract_settlement.contract_settlement_form.getItemValue('counterparty_type');
            //alert(counterparty_id + '--' + contract_id + '--' + date_from + '--' + date_to);
            
            counterparty_invoice_window = new dhtmlXWindows();
            var src = js_path_trm + 'adiha.html.forms/_settlement_billing/maintain_invoice/maintain.invoice.php?invoice_id=' + invoice_id + '&counterparty_type=' + counterparty_type; 
            counterparty_invoice_obj = counterparty_invoice_window.createWindow('w1', 0, 0, 900, 600);
            counterparty_invoice_window.window('w1').maximize();
            counterparty_invoice_obj.setText("View Invoice");

            counterparty_invoice_obj.centerOnScreen();
            counterparty_invoice_obj.setModal(true);
            counterparty_invoice_obj.attachURL(src, false, true);
        }
        
        function load_multiselect() {
            combo_obj = filter_obj.getCombo('apply_filters');
            var filter_name = combo_obj.getSelectedText();
            counterparty_obj = contract_settlement.contract_settlement_form.getCombo('counterparty_id');
            contract_obj = contract_settlement.contract_settlement_form.getCombo('contract_id');


            var form_xml = '<ApplicationFilter name="' + filter_name + '" application_function_id="10221000"/>';
            var combo_data = {"action": "spa_application_ui_filter", "flag": "a", "xml_string": form_xml};

            $.ajax({
                type: "POST",
                dataType: "json",
                url: js_form_process_url,
                async: true,
                data: combo_data,
                success: function(result1) { 
                    response_data = result1['json'];
                    var cmb_data = JSON.stringify(response_data);
                    cmb_data = (JSON.parse(cmb_data));

                    for (i = 0; i < (cmb_data.length); i++) {
                        field_name = (cmb_data[i].farrms_field_id);
                        if (field_name == 'counterparty_id') {
                            counterparty_obj.forEachOption(function(optId){
                                var id = optId.value;
                                var indx = counterparty_obj.getIndexByValue(id);
                                counterparty_obj.setChecked(indx, false);
                            });

                            field_value = (cmb_data[i].field_value);
                            field_value_arr = field_value.split(',');

                         for (cnt = 0; cnt < field_value_arr.length; cnt++) {
                                if (cnt == 0) { counterparty_obj.setComboValue(field_value_arr[cnt]); }
                                var ind = counterparty_obj.getIndexByValue(field_value_arr[cnt]);
                                counterparty_obj.setChecked(ind, true);
                            }
                        } else if (field_name == 'contract_id') {
                            contract_obj.forEachOption(function(optId){
                                var id = optId.value;
							    var indx = contract_obj.getIndexByValue(id);
								 contract_obj.setChecked(indx, false);                               
                            });

                            field_value = (cmb_data[i].field_value);
                            field_value_arr = field_value.split(',');

                            for (cnt = 0; cnt < field_value_arr.length; cnt++) {
                                if (cnt == 0) { contract_obj.setComboValue(field_value_arr[cnt]); }
                                var ind = contract_obj.getIndexByValue(field_value_arr[cnt]);
                                contract_obj.setChecked(ind, true);
                            }
							contract_obj.setChecked(indx, true);
                        }
                    }
                }
            });
        }   
    
        
    </script> 
