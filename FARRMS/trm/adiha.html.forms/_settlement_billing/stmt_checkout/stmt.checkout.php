<?php
/**
* Stmt checkout screen
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
    
    $application_function_id = get_sanitized_value($_GET["function_parameter"] ?? '20011200');
    
    /* Same Page for Settlement Checkout and Run Accrual Screen
     * IF function_parameter = 20011200 -> Settlement Checkout Screen
     * IF function_parameter = 20011800 -> Run Accrual Screen
     * For Application UI Form -> Always use 20011200 function id
     * 
     * Ready For Invoice button in Settlemnt Checkout = Post GL in Run Accrual (Same Functionality)
     * Accrual GL in Settlement Checkout = Final GL in Run Accrual (Same Functionality)
     * Accrual Extract in Settlement Checkout = Final Extract in Run Accrual (Same Functionality)
     */
    $ready_for_invoice_post_gl_est_btn = '';
    $accrual_final_gl_btn = '';
    $accrual_final_extract_btn = '';
    if ($application_function_id == '20011200') {
        $rights_run_settlement = 20011201;
        $rights_ready_for_invoice_post_gl_est = 20011202;
        $ready_for_invoice_post_gl_est_btn = 'Ready for Invoice';
        $rights_revert = 20011203;
        $rights_manual_adjustment = 20011204;
        $rights_run_adjustment = 20011205;
        $rights_prepare_invoice = 20011207;
        $rights_post_gl_final = 20011208;
        $rights_accrual_final_gl = 20011209;
        $accrual_final_gl_btn = 'Final GL';
        $rights_accrual_final_extract = 20011210;
        $accrual_final_extract_btn = 'Final Extract';
        $rights_submitted_accrual = 0;
        $rights_apply_cash = 20011211;
    } else {
        $rights_run_settlement = 20011801;
        $rights_ready_for_invoice_post_gl_est = 20011802;
        $ready_for_invoice_post_gl_est_btn = 'Post GL';
        $rights_revert = 20011803;
        $rights_manual_adjustment = 0;
        $rights_run_adjustment = 0;
        $rights_prepare_invoice = 0;
        $rights_post_gl_final = 0;
        $rights_accrual_final_gl = 20011804;
        $accrual_final_gl_btn = 'Accural GL';
        $rights_accrual_final_extract = 20011805;
        $accrual_final_extract_btn = 'Accrual Extract';
        $rights_submitted_accrual = 20011806;
        $rights_apply_cash = 0;
    }

    list (
        $has_rights_run_settlement,
        $has_rights_ready_for_invoice_post_gl_est,
        $has_rights_revert,
        $has_rights_manual_adjustment,
        $has_rights_run_adjustment,
        $has_rights_prepare_invoice,
        $has_rights_post_gl_final,
        $has_rights_accrual_final_gl,
        $has_rights_accrual_final_extract,
        $has_rights_submitted_accrual,
        $has_rights_apply_cash
    ) = build_security_rights(
        $rights_run_settlement,
        $rights_ready_for_invoice_post_gl_est,
        $rights_revert,
        $rights_manual_adjustment,
        $rights_run_adjustment,
        $rights_prepare_invoice,
        $rights_post_gl_final,
        $rights_accrual_final_gl,
        $rights_accrual_final_extract,
        $rights_submitted_accrual,
        $rights_apply_cash
    );

    $json = '[
                {
                    id:             "a",
                    text:           "Filter Criteria",
                    header:         true,
                    collapse:       false,
                    height:         200
                },
                {
                    id:             "b",
                    text:           "Settlement Detail",
                    header:         true,
                    collapse:       false
                }  
            ]';

    $exec_sql1 = "SELECT DATENAME(MONTH,ISNULL(DATEADD(mm,1,MAX(as_of_date)),GETDATE())) + ' ' + CAST(YEAR(ISNULL(DATEADD(mm,1,MAX(as_of_date)),GETDATE())) AS VARCHAR) [current_month], CONVERT(VARCHAR, DATEADD(mm, 1, MAX(as_of_date)), 23) FROM close_measurement_books";
    $return_value1 = readXMLURL($exec_sql1);
    $current_acc_month = $return_value1[0][0];
    $current_acc_date = $return_value1[0][1];
    
    $namespace = 'settlement_checkout';
    $settlement_checkout_layout_obj = new AdihaLayout();
    echo $settlement_checkout_layout_obj->init_layout('settlement_checkout_layout', '', '2E', $json, $namespace);
    echo $settlement_checkout_layout_obj->set_text("b", "<a class=\"undock_a undock-btn undock_custom\" style=\"float: right; cursor:pointer\" title=\"Undock\"  onClick=\" undock_window();\"></a> Accounting Month: " . $current_acc_month);
    $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='". $application_function_id . "', @template_name='settlement checkout', @group_name='General'";


    $return_value = readXMLURL($xml_file);
    $form_json = $return_value[0][2];
    echo $settlement_checkout_layout_obj->attach_form('settlement_checkout_form', 'a');
    $settlement_checkout_form = new AdihaForm();
    echo $settlement_checkout_form->init_by_attach('settlement_checkout_form', $namespace);
    echo $settlement_checkout_form->load_form($form_json);
    
    $menu_obj = new AdihaMenu();
    $menu_name = 'checkout_menu';
    $menu_json = '[
                        {id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif"},
                        {id:"export", text:"Export", img:"export.gif", imgdis:"export_dis.gif", items:[
                            {id:"excel", text:"Excel", img:"excel.gif"},
                            {id:"pdf", text:"PDF", img:"pdf.gif"},
                            {id:"accrual_final_gl", text:"' . $accrual_final_gl_btn . '", img:"report.gif", imgdis:"report_dis.gif",enabled:"' . $has_rights_accrual_final_gl . '"},
                            {id:"accrual_final_extract", text:"' . $accrual_final_extract_btn . '", img:"report.gif", imgdis:"report_dis.gif",enabled:"' . $has_rights_accrual_final_extract . '"},
                            {id:"submitted_accrual", text:"Submitted Accural", img:"manual_adj.gif", imgdis:"manual_adj_dis.gif",enabled:"true",enabled:"' . $has_rights_submitted_accrual . '"}
                        ]},
                        {id:"expand_collapse", text:"Expand/Collapse", img:"exp_col.gif", imgdis:"exp_col_dis.gif"},
                        {id:"pivot", text:"Pivot", img:"pivot.gif", imgdis:"pivot_dis.gif",enabled:"false"},
                        {id:"process", text:"Process", img:"process.gif", imgdis:"process_dis.gif", items:[
                            {id:"run_settlement", text:"Run Settlement", img:"run.gif", imgdis:"run_dis.gif",enabled:"false"},
                            {id:"run_adjustment", text:"Run Adjustment", img:"manual_adj.gif", imgdis:"manual_adj_dis.gif",enabled:"' . $has_rights_run_adjustment . '"},
                            {id:"manual_adjustment", text:"Manual Adjustment", img:"gene_confirm.gif", imgdis:"gene_confirm_dis.gif",enabled:"false"},
                            {id:"delete_adjustment", text:"Delete Adjustment",img:"delete.gif",imgdis:"delete_dis.gif",enabled:"true"},
                            {id:"ignore_row", text:"Ignore",img:"ignore.png",imgdis:"ignore_dis.png",enabled:"true"},
                        ]},
                        {id:"ready_for_invoice_post_gl_est", text:"' . $ready_for_invoice_post_gl_est_btn . '", img:"update_invoice_stat.gif", imgdis:"update_invoice_stat_dis.gif",enabled:"false"},
                        {id:"revert", text:"Revert", img:"unlock.gif", imgdis:"unlock_dis.gif",enabled:"false"},

                        {id:"invoice", text:"Invoice", img:"export.gif", imgdis:"export_dis.gif",items:[
                          {id:"prepare_invoice", text:"Prepare Invoice", img:"report.gif", imgdis:"report_dis.gif",enabled:"false"},  
                          {id:"generate_invoice",text:"Generate Invoice",img:"html.gif",imgdis:"html_dis.gif",enabled:"false"},
                          {id:"delete",text:"Delete Invoice", img:"delete.gif", imgdis:"delete_dis.gif",enabled:"false"},  
                        ]},
                        
                        {id:"post_gl_final", text:"Post GL", img:"manual_adj.gif", imgdis:"manual_adj_dis.gif",enabled:"false"},
                        
                    ]';
                      
    echo $menu_obj->attach_menu_layout_header($namespace, 'settlement_checkout_layout', 'b', $menu_name, $menu_json, 'checkout_menu_onclick');
   
    $settlement_checkout_grid = 'settlement_checkout_grid';
    echo $settlement_checkout_layout_obj->attach_grid_cell($settlement_checkout_grid, 'b');

    $settlement_checkout_grid_obj = new GridTable($settlement_checkout_grid);
    echo $settlement_checkout_layout_obj->attach_status_bar("b", true);
    echo $settlement_checkout_grid_obj->init_grid_table($settlement_checkout_grid, $namespace);
    echo $settlement_checkout_grid_obj->set_search_filter(true);
    echo $settlement_checkout_grid_obj->split_grid(3);
    echo $settlement_checkout_grid_obj->enable_multi_select();
    echo $settlement_checkout_grid_obj->return_init();
    echo $settlement_checkout_grid_obj->load_grid_functions();
    echo $settlement_checkout_grid_obj->enable_paging(100, 'pagingArea_b', 'true');
    echo $settlement_checkout_grid_obj->enable_filter_auto_hide();

    echo $settlement_checkout_layout_obj->close_layout();

    $exec_sql = "SELECT template_id, trader_id FROM source_deal_header_template WHERE template_name = 'Manual adjustment'";
    $return_value = readXMLURL($exec_sql);
    $template_id = $return_value[0][0];
    $trader_id = $return_value[0][1];
        
    ?>  
    
     <div id="context_menu" style="display: none;">
        <div id="settlement_invoice" text="Settlement Invoice"></div>
    </div>
</body>
    
    <style>
       html, body {
           width: 100%;
           height: 100%;
           margin: 0px;
           overflow: hidden;
       }
        
        .validation_images {
            float:left;
            height:20px;
            width:20px;
            margin-right:5px;
        }
        
        .tooltiptext {
            visibility: hidden;
        } 

        .tooltip:hover .tooltiptext {
            visibility: visible;
        }
        
        .apply_cash_icons {
            margin-left:10px;
        }
        
    </style>
    
    <script type="text/javascript">  
        var category_id = 10000283;
        var stmt_icon_path = '<?php echo $app_adiha_loc; ?>' + 'adiha.php.scripts/adiha_pm_html/process_controls/stmt_checkout_icons/';
        var php_script_loc = '<?php echo $php_script_loc; ?>';
            
        var application_function_id = '<?php echo $application_function_id ?>';
        var accrual_or_final_flag = 'f';
        if (application_function_id == '20011800') 
            accrual_or_final_flag = 'a';
        
        var expand_state = 0;
        var client_date_format = '<?php echo $date_format; ?>';
        var pivot_exec_spa = '';
        var template_id = '<?php echo $template_id; ?>';
        var trader_id = '<?php echo $trader_id; ?>';


        var current_acc_month = '<?php echo $current_acc_month; ?>';
        var current_acc_date = '<?php echo $current_acc_date; ?>';

        var has_rights_run_settlement = <?php echo (($has_rights_run_settlement) ? $has_rights_run_settlement : '0'); ?>;
        var has_rights_ready_for_invoice_post_gl_est = <?php echo (($has_rights_ready_for_invoice_post_gl_est) ? $has_rights_ready_for_invoice_post_gl_est : '0'); ?>;
        var has_rights_revert = <?php echo (($has_rights_revert) ? $has_rights_revert : '0'); ?>;
        var has_rights_post_gl_final = <?php echo (($has_rights_post_gl_final) ? $has_rights_post_gl_final : '0'); ?>;
        var has_rights_prepare_invoice = <?php echo (($has_rights_prepare_invoice) ? $has_rights_prepare_invoice : '0'); ?>;
        var has_rights_manual_adjustment = <?php echo (($has_rights_manual_adjustment) ? $has_rights_manual_adjustment : '0'); ?>;
        var has_rights_apply_cash = <?php echo (($has_rights_apply_cash) ? $has_rights_apply_cash : '0'); ?>;
        var has_rights_accrual_final_gl = <?php echo (($has_rights_accrual_final_gl) ? $has_rights_accrual_final_gl : '0'); ?>;
        var has_rights_accrual_final_extract = <?php echo (($has_rights_accrual_final_extract) ? $has_rights_accrual_final_extract : '0'); ?>;

    
        $(function(){ 
            $('.menu_open_button').click();
            settlement_checkout.settlement_checkout_grid.attachEvent("onRowSelect", function(row_id) {
                var level =settlement_checkout.settlement_checkout_grid.getLevel(row_id);
                
                    if(level == 3) {
                        settlement_checkout.checkout_menu.setItemEnabled('delete'); 
                        settlement_checkout.checkout_menu.setItemEnabled('generate_invoice'); 
                    }
            });

            settlement_checkout.checkout_menu.attachEvent("onClick", function(id,zoneId, cas) {
                switch (id) {
                    case "generate_invoice":
                        var selected_row = settlement_checkout.settlement_checkout_grid.getSelectedRowId();
                        var selected_row_array = selected_row.split(',');
                          for(var i = 0; i < selected_row_array.length; i++) {
                            var stmt_invoice_id = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[i],     settlement_checkout.settlement_checkout_grid.getColIndexById('Invoice')).getValue();    
                            generate_invoice(stmt_invoice_id);
                        }

                    break;

                    case "delete":
                        var select_id = settlement_checkout.settlement_checkout_grid.getSelectedRowId();
                        var invoice_id_index = settlement_checkout.settlement_checkout_grid.getColIndexById('Invoice');
                        var invoice_ids = [];
                        select_id = select_id.split(',');
                        select_id.forEach(function(val) {
                        invoice_ids.push(settlement_checkout.settlement_checkout_grid.cells(val, invoice_id_index).getValue());
                        });

                        if (select_id != null) {
                            var xml = "<Root function_id=\"20011200\" object_id=\"" + invoice_ids[0] + "\">";
                            invoice_ids.forEach(function(val) {
                                xml += "<GridDelete settlement_invoice_id=\""+ val + "\">";
                                xml += "</GridDelete>";
                            });
                            xml += "</Root>";
                            xml = xml.replace(/'/g, "\"");
                            dhtmlx.message({
                                type: "confirm",
                                title: "Confirmation",
                                ok: "Confirm",
                                text: "Are you sure you want to delete?",
                                callback: function(result) {
                                    if (result) {
                                        
                                        data = {
                                                "action": "spa_stmt_checkout",
                                                "flag": "d",
                                                "xml":xml
                                            };

                                           adiha_post_data('alert', data, '', '', 'settlement_checkout_refresh', '', '');
                                    }
                                }
                            });
                        } else {
                            dhtmlx.alert({
                                title:"Alert",
                                type:"alert",
                                text:"Please select a row from grid."
                            });
                        }
                    break;
                }    
            });

            settlement_checkout.settlement_checkout_form.setItemValue('accounting_month',current_acc_date);
            //settlement_checkout.checkout_menu.hideItem('post_gl_final');
            settlement_checkout.checkout_menu.hideItem('accrual_final_extract');
            //Enable/Disable features depending on Run Accrual Screen or Settlement Checkout Screen
            set_accrual_or_checkout();
            
            attach_browse_event('settlement_checkout.settlement_checkout_form', application_function_id);
            filter_obj = settlement_checkout.settlement_checkout_layout.cells('a');
            var layout_cell_obj = settlement_checkout.settlement_checkout_layout.cells('a');
            load_form_filter(filter_obj, layout_cell_obj, application_function_id, 2, '' , '' , '', 'layout');

            // settlement_checkout.settlement_checkout_layout.cells('a').collapse();

            settlement_checkout.settlement_checkout_grid.attachEvent("onRowDblClicked", function(rId,cInd){
                checkout_expand_settlement();
            });
            
            //To Set the Accounting Period in Layout Header
            // settlement_checkout.settlement_checkout_layout.cells('b').setText("<a class=\"undock_a undock-btn undock_custom\" style=\"float: right; cursor:pointer\" title=\"Undock\"  onClick=\" undock_window();\"></a>Accounting Month: " + current_acc_month);
        
            settlement_checkout.settlement_checkout_form.attachEvent("onChange", function(name,value,is_checked){
                if (name == 'date_from') {
                    var date_from = settlement_checkout.settlement_checkout_form.getItemValue(name, true);
                    var split = date_from.split('-');
                    var year =  +split[0];
                    var month = +split[1];
                    var day = +split[2];

                    var date = new Date(year, month-1, day);
                    var lastDay = new Date(date.getFullYear(), date.getMonth() + 1, 0);
                    date_end = formatDate(lastDay);
                    
                    settlement_checkout.settlement_checkout_form.setItemValue('date_to', date_end);
                    settlement_checkout.settlement_checkout_form.clearNote("date_to");
                } 

                if (name == 'invoice_status') { 
                    var  is_ignore_cmb =  settlement_checkout.settlement_checkout_form.getCombo('invoice_status');
                    var is_ignore_val=  is_ignore_cmb.getSelectedValue();

                    if(is_ignore_val == 6) {
                        settlement_checkout.checkout_menu.setItemEnabled('revert');
                        settlement_checkout.checkout_menu.setItemDisabled('prepare_invoice');
                        settlement_checkout.checkout_menu.setItemDisabled('ready_for_invoice_post_gl_est');
                    } else {
                        settlement_checkout.checkout_menu.setItemDisabled('revert');
                    }

                    if(is_ignore_val == 4) {
                        var view_type_combo_obj = settlement_checkout.settlement_checkout_form.getCombo('view_type');   
                        view_type_combo_obj.setComboValue(3);
                        settlement_checkout.checkout_menu.showItem('delete');
                     } else {
                        settlement_checkout.checkout_menu.hideItem('delete');
                    }
                }

            });
        });
        
        
        /*
         * depending on Settlement Checkout or Run Accrual menu:
            - This function hide/show menu
                + Run Accrual Screen - Hide 'Run Adjustment', 'Manual Adjustment', 'Post GL' (final), 'Prepare Invoice' 
                + Settlement Checkout Screen - Hide 'Submitted Accruals'
            - Rename the form items 
                + Accrual Status in Run Accrual screen = Checkout Status in Settlement Checkout screen
            - Options in the View and Checkout Status dropdown
                + 'Invoice' option is hidden from View dropdown in Run Accrual screen
                + 'Accrual Posted' option is hidden from Checkout Status/Accrual Status in Run Accrual screen
                + 'Ready for Invoice' and 'Invoiced' option is hidden from Checkout Status/Accrual Status dropown in Settlement Checkout screen
        */
        set_accrual_or_checkout = function() {
            var status_obj = settlement_checkout.settlement_checkout_form.getCombo('invoice_status');
            settlement_checkout.settlement_checkout_form.attachEvent("onChange", function (name, value, state){
                if (name == 'invoice_status' && value == '2') {
                    settlement_checkout.checkout_menu.setItemEnabled('delete_adjustment');
                } else {
                    settlement_checkout.checkout_menu.setItemDisabled('delete_adjustment');
                }
            });

            if (application_function_id == '20011200') {
                settlement_checkout.checkout_menu.hideItem('submitted_accrual');
                status_obj.deleteOption('5');

            } else if (application_function_id == '20011800') {
                settlement_checkout.checkout_menu.hideItem('run_adjustment');
                settlement_checkout.checkout_menu.hideItem('manual_adjustment');
                settlement_checkout.checkout_menu.hideItem('prepare_invoice');
                settlement_checkout.checkout_menu.hideItem('post_gl_final');
                // settlement_checkout.checkout_menu.hideItem('ignore_row');
                settlement_checkout.checkout_menu.hideItem('delete_adjustment');
                settlement_checkout.checkout_menu.hideItem('revert');
                settlement_checkout.settlement_checkout_form.setItemLabel('invoice_status', get_locale_value('Accrual Status'));   
                status_obj.deleteOption('3');
                status_obj.deleteOption('4');
                var view_type_obj = settlement_checkout.settlement_checkout_form.getCombo('view_type');
                view_type_obj.deleteOption('3');

                settlement_checkout.settlement_checkout_form.attachEvent("onChange", function (name, value, state){
                    if (name == 'invoice_status' && value == '1') {
                        settlement_checkout.checkout_menu.setItemDisabled("ignore_row");
                    } else {
                        settlement_checkout.checkout_menu.setItemEnabled("ignore_row");
                    }
                });
            }
        }
        
        /*
         * [Menu click function]
         */

        checkout_menu_onclick = function(name) { 
           // a = run accrual, f = Settlement Checkout
            if((accrual_or_final_flag == 'a' && name == 'ready_for_invoice_post_gl_est') || (accrual_or_final_flag == 'f' && name == 'revert')) { // Validate closing date.
                var accounting_month = settlement_checkout.settlement_checkout_form.getItemValue('accounting_month', true);
                var params = {
                        'action': 'spa_stmt_checkout',
                        'flag': 'y',
                        'term_date': accounting_month
                    }

                var callback_fn = (function (result) {checkout_menu_onclick_callback(name, result); });
                adiha_post_data('return_array', params, '', '', callback_fn);       
            } else {
                checkout_menu_onclick_callback(name, true);
            }
        }

        checkout_menu_onclick_callback = function(name,result) {
            if (result instanceof Array) {
                if(result[0][0] == 'false') {
                    show_messagebox(result[0][2]);
                    return;
                }
            }

            if (name == 'refresh') {
                settlement_checkout_refresh();
            } else if (name == 'run_settlement') {
                run_settlement_popup();
            } else if (name == 'ready_for_invoice_post_gl_est') {
                if(application_function_id == '20011200') {
                    dhtmlx.message({
                        type: "confirm",
                        text: "Are you sure you want to Ready for Invoice?",
                        title: "Confirmation",
                        ok :  "Confirm",
                        callback: function(result) {                         
                            if (result) {
                               ready_for_invoice();
                            }                           
                        } 
                    }); 
                } else {
                    ready_for_invoice();
                }
            } else if (name == 'excel') {
                settlement_checkout.settlement_checkout_grid.toExcel(php_script_loc + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php');
            } else if (name == 'pdf') {
                settlement_checkout.settlement_checkout_grid.toPDF(php_script_loc +'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php');
            } else if (name == 'pivot') {
                var grid_obj = settlement_checkout.settlement_checkout_grid;
                open_grid_pivot(grid_obj, 'settlement_checkout', 3, pivot_exec_spa, 'Settlement Checkout','');
            } else if (name == 'expand_collapse') {
                if (expand_state == 0) {
                    open_all_gridtree();
                } else {
                    close_all_gridtree();
                } 
            } else if (name == 'revert') {
                revert_checkout();
            } else if (name == 'accrual_final_gl') {
                view_accrual_report('accrual_final_gl');
            } else if (name == 'accrual_final_extract') {
                view_accrual_report('accrual_final_extract');  
            } else if (name == 'submitted_accrual') { 
                view_accrual_report('submitted_accrual'); 
            } else if (name == 'manual_adjustment') {
                manual_adjustment();
            } else if (name == 'prepare_invoice') {
                prepare_invoice_popup();
            } else if (name == 'post_gl_final') {
                //show_messagebox('In Progress!!');
                run_post_gl_final();                
            } else if (name == 'run_adjustment') {
                run_adjustment_popup();
            } else if(name == 'ignore_row') {
               ignore_row_grd();
            } else if(name == 'delete_adjustment') {
                var selected_rows = get_all_rows_id_under_selection();
                if (typeof selected_rows !== 'undefined') {
                    dhtmlx.message({
                        type: "confirm",
                        text: "Are you sure you want to delete adjustment invoice?",
                        title: "Confirmation",
                        ok :  "Confirm",
                        callback: function(result) {                         
                            if (result) {
                               delete_adjustment();
                            }                           
                        } 
                    }); 
                }
            } 
        }
        
        /*
         * [Grid Refresh Function]
         */
        settlement_checkout_refresh = function() {
            var status = validate_form(settlement_checkout.settlement_checkout_form);
            
            if (status == false) { 
                settlement_checkout.settlement_checkout_layout.cells('b').progressOff();
                return; 
            }
            
            var delivery_month = settlement_checkout.settlement_checkout_form.getItemValue('delivery_month', true);
            var date_from = settlement_checkout.settlement_checkout_form.getItemValue('date_from', true);
            var date_to = settlement_checkout.settlement_checkout_form.getItemValue('date_to', true);
            

            var date_from_parse = (date_from == '') ? '' : Date.parse(date_from);
            var date_to_parse = (date_to == '') ? '' : Date.parse(date_to);

            if ((date_from_parse != "") && (date_to_parse != "") && (date_from_parse > date_to_parse)) {
                show_messagebox('<strong>Delivery Date To</strong> cannot be greater than <strong>Delivery Date From</strong>.'); 
                 return
            } 
            
            settlement_checkout.settlement_checkout_layout.cells('b').progressOn();            
            
            settlement_checkout.checkout_menu.setItemEnabled("pivot");
            
            enable_checkout_privilege("manual_adjustment");
            
            var invoice_status = settlement_checkout.settlement_checkout_form.getItemValue('invoice_status');

            
            if (invoice_status == 1) {
                enable_checkout_privilege("run_settlement");
                
                settlement_checkout.checkout_menu.setItemDisabled("ready_for_invoice_post_gl_est");
                settlement_checkout.checkout_menu.setItemDisabled("revert");
                settlement_checkout.checkout_menu.setItemDisabled("post_gl_final");
                settlement_checkout.checkout_menu.setItemDisabled("prepare_invoice");
            } else if (invoice_status == 2) {
               enable_checkout_privilege("run_settlement");
                
                enable_checkout_privilege("ready_for_invoice_post_gl_est");
                
                settlement_checkout.checkout_menu.setItemDisabled("revert");
                enable_checkout_privilege("post_gl_final");
                if (accrual_or_final_flag == 'f') {
                    settlement_checkout.checkout_menu.setItemDisabled("prepare_invoice");
                } else {
                    enable_checkout_privilege("prepare_invoice");
                }
            } else if (invoice_status == 3) {
                settlement_checkout.checkout_menu.setItemDisabled("run_settlement");
                settlement_checkout.checkout_menu.setItemDisabled("ready_for_invoice_post_gl_est");
                
                enable_checkout_privilege("post_gl_final");
                
                enable_checkout_privilege("revert");
                
                enable_checkout_privilege("prepare_invoice");
                
            } else if (invoice_status == 4) {
                settlement_checkout.checkout_menu.setItemDisabled("run_settlement");
                settlement_checkout.checkout_menu.setItemDisabled("ready_for_invoice_post_gl_est");

                enable_checkout_privilege("post_gl_final");
                
                settlement_checkout.checkout_menu.setItemDisabled("revert");
                settlement_checkout.checkout_menu.setItemDisabled("prepare_invoice");
            } else if (invoice_status == 5) {
                enable_checkout_privilege("revert");
                
                settlement_checkout.checkout_menu.setItemDisabled("ready_for_invoice_post_gl_est");
            }
            
            var subsidiary_id = settlement_checkout.settlement_checkout_form.getItemValue('subsidiary_id');
            var strategy_id = settlement_checkout.settlement_checkout_form.getItemValue('strategy_id');
            var book_id = settlement_checkout.settlement_checkout_form.getItemValue('book_id');
            var subbook_id = settlement_checkout.settlement_checkout_form.getItemValue('subbook_id');

            var counterparty_id = settlement_checkout.settlement_checkout_form.getItemValue('counterparty_id');
            var counterparty_type  = settlement_checkout.settlement_checkout_form.getItemValue('counterparty_type');
                       
            var contract_obj = settlement_checkout.settlement_checkout_form.getCombo('contract_id');
            var contract_id = contract_obj.getChecked('contract_id');
            contract_id = contract_id.toString();
            
            var charge_type_obj = settlement_checkout.settlement_checkout_form.getCombo('charge_type');
            var charge_type = charge_type_obj.getChecked('charge_type');
            charge_type = charge_type.toString();
            
            var commodity_group_obj = settlement_checkout.settlement_checkout_form.getCombo('commodity_group');
            var commodity_group = commodity_group_obj.getChecked('commodity_group');
            commodity_group = commodity_group.toString();
            
            var commodity_obj = settlement_checkout.settlement_checkout_form.getCombo('commodity');
            var commodity = commodity_obj.getChecked('commodity');
            commodity = commodity.toString();
            
            var buy_sell_obj = settlement_checkout.settlement_checkout_form.getCombo('buy_sell');
            var buy_sell = buy_sell_obj.getChecked('buy_sell');
            buy_sell = buy_sell.toString();
            
            var payable_receivable_obj = settlement_checkout.settlement_checkout_form.getCombo('payable_receivable');
            var payable_receivable = payable_receivable_obj.getChecked('payable_receivable');
            payable_receivable = payable_receivable.toString();
            
            var deal_type_obj = settlement_checkout.settlement_checkout_form.getCombo('deal_type');
            var deal_type = deal_type_obj.getChecked('deal_type');
            deal_type = deal_type.toString();

            var deal_charge_type_id_obj = settlement_checkout.settlement_checkout_form.getCombo('deal_charge_type_id');
            var deal_charge_type_id = deal_charge_type_id_obj.getChecked('deal_charge_type_id');
            deal_charge_type_id = deal_charge_type_id.toString();

            var counterparty_entity_type_obj = settlement_checkout.settlement_checkout_form.getCombo('counterparty_entity_type');
            var counterparty_entity_type = counterparty_entity_type_obj.getChecked('counterparty_entity_type');
            counterparty_entity_type = counterparty_entity_type.toString();

            var contract_category_obj = settlement_checkout.settlement_checkout_form.getCombo('contract_category');
            var contract_category = contract_category_obj.getChecked('contract_category');
            contract_category = contract_category.toString();
            
            var match_group_id = settlement_checkout.settlement_checkout_form.getItemValue('match_group_id');
            var shipment_id = settlement_checkout.settlement_checkout_form.getItemValue('shipment_id');
            var ticket_id = settlement_checkout.settlement_checkout_form.getItemValue('ticket_id');
            var deal_id = settlement_checkout.settlement_checkout_form.getItemValue('deal_id');
            var reference_id = settlement_checkout.settlement_checkout_form.getItemValue('reference_id');
            var rounding = settlement_checkout.settlement_checkout_form.getItemValue('rounding');
            var view_type = settlement_checkout.settlement_checkout_form.getItemValue('view_type');
            var accounting_month = settlement_checkout.settlement_checkout_form.getItemValue('accounting_month', true);
            
            var prior_period = settlement_checkout.settlement_checkout_form.isItemChecked('prior_period');
            if (prior_period == true || application_function_id == '20011800')
                prior_period = 'y';
            else 
                prior_period = 'n';
           
            var grid_param = {
                "action": "spa_stmt_checkout",
                "flag": "grid",
                "grid_type": "tg",
                "grouping_column": "Group1,Group2,Group3,Group4,Group5",
                "accrual_or_final_flag": accrual_or_final_flag,
                "subsidiary_id": subsidiary_id,
                "strategy_id": strategy_id,
                "book_id": book_id,
                "sub_book_id": subbook_id,
                "counterparty_id": counterparty_id,
                "contract_id": contract_id,
                "date_from": date_from,
                "date_to": date_to,
                "charge_type": charge_type,
                "commodity_group": commodity_group,
                "commodity": commodity,
                "invoice_status": invoice_status,
                "buy_sell": buy_sell,
                "deal_type": deal_type,
                "match_group_id": match_group_id,
                "shipment_id": shipment_id,
                "ticket_id": ticket_id,
                "source_deal_header_id": deal_id,
                "deal_reference_id": reference_id,
                "rounding": rounding,
                "delivery_month": delivery_month,
                "payable_receivable": payable_receivable,
                "view_type": view_type,
                "prior_period": prior_period,
                "accounting_date": accounting_month,
                "counterparty_type": counterparty_type,
                "deal_charge_type_id": deal_charge_type_id,
                "counterparty_entity_type" : counterparty_entity_type,
                "contract_category" : contract_category

            };
            
            //Set the sql query for pivot
            pivot_exec_spa = "EXEC spa_stmt_checkout @flag='grid"
                                            + "',@accrual_or_final_flag='" + accrual_or_final_flag 
                                            + "',@subsidiary_id='" + subsidiary_id 
                                            + "',@strategy_id='" + strategy_id 
                                            + "',@book_id='" + book_id 
                                            + "',@sub_book_id='" + subbook_id 
                                            + "',@counterparty_id='" + counterparty_id 
                                            + "',@contract_id='" + contract_id 
                                            + "',@date_from='" + date_from 
                                            + "',@date_to='" + date_to 
                                            + "',@charge_type='" + charge_type 
                                            + "',@commodity_group='" + commodity_group 
                                            + "',@commodity='" + commodity 
                                            + "',@invoice_status='" + invoice_status 
                                            + "',@buy_sell='" + buy_sell 
                                            + "',@deal_type='" + deal_type 
                                            + "',@match_group_id='" + match_group_id 
                                            + "',@shipment_id='" + shipment_id 
                                            + "',@ticket_id='" + ticket_id
                                            + "',@source_deal_header_id='" + deal_id 
                                            + "',@deal_reference_id='" + reference_id 
                                            + "',@rounding='" + rounding
                                            + "',@delivery_month='" + delivery_month
                                            + "',@payable_receivable='" + payable_receivable 
                                            + "',@prior_period='" + prior_period 
                                            + "',@view_type='" + view_type + 
                                            + "',@counterparty_type='" + counterparty_type + 
                                            + "',@deal_charge_type_id='" + deal_charge_type_id +
                                            + "',@counterparty_entity_type='" + counterparty_entity_type +
                                            + "',@contract_category='" + contract_category +
                                            "'";
            
            
            grid_param = $.param(grid_param);
            
            settlement_checkout.settlement_checkout_grid.clearAll();
            settlement_checkout.settlement_checkout_grid.post(js_data_collector_url, grid_param, function() {
                settlement_checkout.settlement_checkout_grid.expandAll();
                load_context_menu();
                
                settlement_checkout.settlement_checkout_layout.cells('b').progressOff();
                expand_state = 0;
                var row_ids = settlement_checkout.settlement_checkout_grid.getAllRowIds();

                if(!row_ids) {
                    settlement_checkout.checkout_menu.setItemDisabled('accrual_final_gl');
                    settlement_checkout.checkout_menu.setItemDisabled('accrual_final_extract');
                } else {
                    enable_checkout_privilege('accrual_final_gl');
                    enable_checkout_privilege('accrual_final_extract');
                }

                if (view_type == 1) {
                    settlement_checkout.settlement_checkout_grid.setColumnLabel(0,"Shipment/Deal/Charges");
                } else if (view_type == 1) {
                    settlement_checkout.settlement_checkout_grid.setColumnLabel(0,"Counterparty/Contract/Charges");
                } else if (view_type == 3) {
                    settlement_checkout.settlement_checkout_grid.setColumnLabel(0,"Counterparty/Contract/Invoice/Charges");
                }
                
                grid_data_color();
                apply_cash_icons_css();
                
            });
        }
        
        /*
         * Function for open parameter popup to run settlement
         */
        run_settlement_popup = function(run_from) {
            var label_width = parseInt(ui_settings['field_size']) + parseInt(ui_settings['offset_left']);
            var cal_form_data = [
                                    {type: "settings", labelWidth: label_width, inputWidth: ui_settings['field_size'], position: "label-top", offsetLeft: ui_settings['offset_left']},
                                    {type: "calendar", name: "as_of_date", label:  get_locale_value("Calculation Date"), "dateFormat": client_date_format, "serverDateFormat":"%Y-%m-%d"},
                                     {type: "button", value: get_locale_value("Ok"), img: "tick.png"}
                                ];
            
            var cal_popup = new dhtmlXPopup();
            
            cal_popup.attachEvent("onShow", function(){
                var cal_form = cal_popup.attachForm(cal_form_data);
                // var new_date = new Date();
                // var date = new Date(new_date.getFullYear(), new_date.getMonth() , new_date.getDate());
                // cal_form.setItemValue('as_of_date', date);
                
                var date_to = settlement_checkout.settlement_checkout_form.getItemValue('date_to', true);
                cal_form.setItemValue('as_of_date', date_to);

                cal_form.attachEvent("onButtonClick", function(){
                    var as_of_date = cal_form.getItemValue('as_of_date', true);
                    as_of_date = dates.convert_to_sql(as_of_date);

                    var params = {
                        'action': 'spa_stmt_checkout',
                        'flag': 'y',
                        'term_date': as_of_date
                    }
        
                    var result = adiha_post_data('return_array', params, '', '', 'run_settlement');
                    // run_settlement(as_of_date);
                    cal_popup.hide();
                });
            });

            var template_height = settlement_checkout.settlement_checkout_layout.cells('a').getHeight();
            var template_width = settlement_checkout.settlement_checkout_layout.cells('a').getWidth();
            cal_popup.show(template_width * 0.29, template_height -15, 45, 45);          
        }
        
        /*
         * Function for Run Settlement
         */
        run_settlement = function(array) {
            as_of_date = array[0][1];
            if(array[0][0] == 'false') {
                show_messagebox(array[0][2]);
                return;
            }
            var all_selected_rows = get_all_rows_id_under_selection();            
            var counterparty_id_arr = new Array();
            var source_deal_header_id_arr = new Array();
            var shipment_id_arr = new Array();
            var contract_charge_type_id_arr = new Array();
            var contract_id_arr = new Array();
            var min_term = new Date();
            var max_term = new Date();
            
            for (count = 0; count < all_selected_rows.length; count++) {
                var c_id = settlement_checkout.settlement_checkout_grid.cells(all_selected_rows[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Counterparty_ID')).getValue();
                var d_id = settlement_checkout.settlement_checkout_grid.cells(all_selected_rows[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Deal_ID')).getValue();
                var s_id = settlement_checkout.settlement_checkout_grid.cells(all_selected_rows[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Shipment_ID')).getValue();
                
                if (counterparty_id_arr.indexOf(c_id) == -1)
                    counterparty_id_arr.push(c_id);
                if (source_deal_header_id_arr.indexOf(d_id) == -1) {
                    if (d_id != '') {
						source_deal_header_id_arr.push(d_id);
					}
				}
                if (shipment_id_arr.indexOf(s_id) == -1)
                    shipment_id_arr.push(s_id);
                
                var con_id = settlement_checkout.settlement_checkout_grid.cells(all_selected_rows[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Contract_ID')).getValue();
                var con_charge_id = settlement_checkout.settlement_checkout_grid.cells(all_selected_rows[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Contract_Charge_Type_ID')).getValue();
                if (contract_id_arr.indexOf(con_id) == -1)
                    contract_id_arr.push(con_id);
                if (contract_charge_type_id_arr.indexOf(con_charge_id) == -1)
                    contract_charge_type_id_arr.push(con_charge_id);
                
                var term_start = settlement_checkout.settlement_checkout_grid.cells(all_selected_rows[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Term_Start')).getValue();
                var term_end = settlement_checkout.settlement_checkout_grid.cells(all_selected_rows[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Term_End')).getValue();

                if (term_start < min_term || count == 0) {
                    min_term =  term_start;
                }
                if (term_end > max_term || count == 0) {
                    max_term =  term_end;
                }
                
            }
            
            var term_start = min_term;
            var term_end = max_term;
            
            var counterparty_id = counterparty_id_arr.toString();
            var source_deal_header_id = source_deal_header_id_arr.toString();
            var shipment_id = shipment_id_arr.toString();
            var contract_charge_type_id = contract_charge_type_id_arr.toString();
            var contract_id = contract_id_arr.toString();
            
            var exec_call = "EXEC spa_calc_mtm_job  @source_deal_header_id = " +  singleQuote(source_deal_header_id) 
                                + ", @as_of_date = " + singleQuote(dates.convert_to_sql(as_of_date)) 
                                + ", @curve_source_value_id = 4500" 
                                + ", @pnl_source_value_id = NULL "
                                + ", @hedge_or_item = 'b'"
                                + ", @run_incremental = 'n'"
                                + ", @term_start = " + singleQuote(term_start) 
                                + ", @term_end = " + singleQuote(term_end) 
                                + ", @calc_type = 's'"
                                + ", @counterparty_id = " + singleQuote(counterparty_id)
                                + ", @criteria_id = NULL"; 
                             
            var param = 'call_from=SettlementCheckout&gen_as_of_date=1&batch_type=c&as_of_date=' + dates.convert_to_sql(as_of_date);
            if(application_function_id == '20011800')
                ui_name = 'Run Accrual';
            else
                ui_name = 'Settlement Checkout';
            adiha_run_batch_process(exec_call, param, ui_name);
        }
        
        /*
         * Function for Ready for Invoice button in Settlement Checkout
         * Function for Post GL in Run Accrual
         */
        ready_for_invoice = function() {
            var selected_row_array = get_all_rows_id_under_selection();
            var xml = '<Root>';

            for (count = 0; count < selected_row_array.length; count++) {
                var has_child = settlement_checkout.settlement_checkout_grid.hasChildren(selected_row_array[count]);
                
                if (has_child == 0 ) {
                    
                var source_deal_detail_id = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Deal_Detail_ID')).getValue();
                var shipment_id= settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Shipment_ID')).getValue();
                var ticket_id= settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Ticket_ID')).getValue();
                var deal_charge_type_id = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Deal_Charge_Type_ID')).getValue();
                var contract_charge_type_id = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Contract_Charge_Type_ID')).getValue();
                var counterparty_id = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Counterparty_ID')).getValue();
                var counterparty_name = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Counterparty')).getValue();
                var contract_id = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Contract_ID')).getValue();
                var as_of_date = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('As_of_Date')).getValue();
                if(as_of_date) {
                    as_of_date = dates.convert_to_sql(as_of_date);
                }

                var term_start = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Term_Start')).getValue();
                if(term_start) {
                    term_start = dates.convert_to_sql(term_start);
                }

                var term_end = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Term_End')).getValue();
                if(term_end) {
                    term_end = dates.convert_to_sql(term_end);
                }
                                    
                var currency_id = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Currency_ID')).getValue();
                var uom_id = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Volume_UOM_ID')).getValue();
                var settlement_amount = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Amount_Value')).getValue();
                var settlement_volume = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Settlement_Volume_Value')).getValue();
                var settlement_price = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Price_Value')).getValue();
                
                var scheduled_volume = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Schedule_Volume')).getValue();
                var acutal_volume = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Actual_Volume')).getValue();
                
                var status = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Status')).getValue();
                var index_fees_id = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Index_Fees_ID')).getValue();
                var debit_gl_number = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Debit_GL_Number')).getValue();
                var credit_gl_number = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Credit_GL_Number')).getValue();
                var pnl_line_item_id = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('PNL_Line_Item_ID')).getValue();
                var charge_type_alias = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Charge_Type_Alias_ID')).getValue();
                var invoicing_charge_type_id = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Invoicing_Charge_Type_ID')).getValue();
                var invoice_frequency = '';
                var type = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Type')).getValue();
                var reversal_required = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('reversal_required')).getValue();
				var match_info_id = '';
                
                xml = xml +  '<PSRecordSet source_deal_detail_id="' + source_deal_detail_id 
                                    + '" shipment_id="' + shipment_id 
                                    + '" ticket_id="' + ticket_id 
                                    + '" deal_charge_type_id="' + deal_charge_type_id 
                                    + '" contract_charge_type_id="' + contract_charge_type_id 
                                    + '" counterparty_id="' + counterparty_id 
                                    + '" counterparty_name="' + counterparty_name 
                                    + '" contract_id="' + contract_id 
                                    + '" as_of_date="' + as_of_date 
                                    + '" term_start="' + term_start 
                                    + '" term_end="' + term_end 
                                    + '" currency_id="' + currency_id 
                                    + '" uom_id="' + uom_id 
                                    + '" settlement_amount="'+ settlement_amount 
                                    + '" settlement_volume="' + settlement_volume 
                                    + '" settlement_price="' + settlement_price 
                                    + '" scheduled_volume="' + scheduled_volume 
                                    + '" acutal_volume="' + acutal_volume 
                                    + '" status="' + status 
                                    + '" index_fees_id="' + index_fees_id 
                                    + '" debit_gl_number="' + debit_gl_number 
                                    + '" credit_gl_number="' + credit_gl_number 
                                    + '" pnl_line_item_id="' + pnl_line_item_id 
                                    + '" charge_type_alias="' + charge_type_alias 
                                    + '" invoicing_charge_type_id="' + invoicing_charge_type_id
                                    + '" invoice_frequency="' 
                                    + '" type="' + type 
                                    + '" is_reversal_required ="' + reversal_required 
									+ '" match_info_id ="' + match_info_id 
                                    + '"></PSRecordSet>';    
                }
            }
            xml = xml + '</Root>';
            
            data = {"action": "spa_stmt_checkout",
                "flag": "checkout",
                "accrual_or_final_flag": accrual_or_final_flag,    
                "xml": xml
            };

            adiha_post_data('alert', data, '', '', 'settlement_checkout_refresh', '', '');
        }
        
        /*
         * Function for revert the Ready for Invoice in Settlement Checkout
         * Function for revert the Post GL in Run Accrual
         */
        revert_checkout = function() {
            var selected_row_array = get_all_rows_id_under_selection();
            var xml = '<Root>';

            for (count = 0; count < selected_row_array.length; count++) {
                var has_child = settlement_checkout.settlement_checkout_grid.hasChildren(selected_row_array[count]);
                
                if (has_child == 0 ) {
                    var fin_stmt_checkout_id = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Settlement_Checkout_ID')).getValue();
                    var est_stmt_checkout_id = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Est_Post_GL_ID')).getValue();
        
                    // if (accrual_or_final_flag == 'f') {
                    //     var stmt_checkout_id = fin_stmt_checkout_id;
                    // } else  {
                    //     var stmt_checkout_id = est_stmt_checkout_id;
                    // }
                    var stmt_checkout_id = fin_stmt_checkout_id;
                    xml = xml +  '<PSRecordSet stmt_checkout_id="' + stmt_checkout_id + '"></PSRecordSet>';    
                }
            }
            xml = xml + '</Root>';
            
            data = {"action": "spa_stmt_checkout",
                "flag": "checkout_revert",
                "accrual_or_final_flag": accrual_or_final_flag,    
                "xml": xml
            };

            adiha_post_data('alert', data, '', '', 'settlement_checkout_refresh', '', '');
        }
        
        /*
         * [Open the Manual Adjustment Screen]
         */
        manual_adjustment = function() {
            var js_path = '<?php echo $app_php_script_loc; ?>';
            var js_path_trm = '<?php echo $app_adiha_loc; ?>';
            var book_id = settlement_checkout.settlement_checkout_form.getItemValue('book_id');
            var subsidiary_id = settlement_checkout.settlement_checkout_form.getItemValue('subsidiary_id');
            var strategy_id = settlement_checkout.settlement_checkout_form.getItemValue('strategy_id');
            var subbook_id = settlement_checkout.settlement_checkout_form.getItemValue('subbook_id');
            var book_structure = settlement_checkout.settlement_checkout_form.getItemValue('book_structure');
            var delivery_months = settlement_checkout.settlement_checkout_form.getItemValue('date_from', true);
            var selected_row_array = get_all_rows_id_under_selection();
            
            for (count = 0; count < selected_row_array.length; count++) {
                var has_child = settlement_checkout.settlement_checkout_grid.hasChildren(selected_row_array[count]);
                
                if (has_child == 0 ) {
                    var counterparty_id = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Counterparty_ID')).getValue();
                    var contract_id = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Contract_ID')).getValue();
                }

            }

            manual_adj_window = new dhtmlXWindows();

            var src = js_path_trm + 'adiha.html.forms/_settlement_billing/stmt_checkout/stmt.manual.adjustment.php?template_id=' + template_id+ '&trader_id=' + trader_id + '&delivery_month=' + delivery_months + '&counterparty_id=' + counterparty_id + '&contract_id=' + contract_id + '&book_id=' + book_id + '&subsidiary_id=' + subsidiary_id + '&strategy_id=' + strategy_id + '&subbook_id=' + subbook_id + '&book_structure=' + book_structure;
            manual_adj_obj = manual_adj_window.createWindow('w1', 0, 0, 900, 600);
            manual_adj_window.window('w1').maximize();
            manual_adj_obj.setText("Manual Adjustment");

            manual_adj_obj.centerOnScreen();
            manual_adj_obj.setModal(true);
            manual_adj_obj.attachURL(src, false, true);
        }

        delete_adjustment = function() {
            var index_fees_index = settlement_checkout.settlement_checkout_grid.getColIndexById('Index_Fees_ID');
            var type_index = settlement_checkout.settlement_checkout_grid.getColIndexById('Type');

            var all_index_fees =new Array();
            var selected_rows = get_all_rows_id_under_selection();

            selected_rows.forEach(function(value) {
                var index_fees_id = settlement_checkout.settlement_checkout_grid.cells(value, index_fees_index).getValue();
                var type = settlement_checkout.settlement_checkout_grid.cells(value, type_index).getValue();
                if ((all_index_fees.indexOf(index_fees_id) === -1) && (type = 'Adjustment')) {
                   all_index_fees.push(index_fees_id); 
                }
            });
            
            var all_index_fees = all_index_fees.toString();
            
            data = {"action": "spa_stmt_checkout",
                "flag": "delete_adjustment",
                "accrual_or_final_flag": accrual_or_final_flag,  
                "index_fees_id": all_index_fees
            };

            adiha_post_data('alert', data, '', '', 'settlement_checkout_refresh', '', '');
        }
        
        /*
         * [Function to prepare invoice]
         */
        prepare_invoice = function(as_of_date) {
            var selected_row_array = get_all_rows_id_under_selection();
            var xml = '<Root>';

            for (count = 0; count < selected_row_array.length; count++) {
                var has_child = settlement_checkout.settlement_checkout_grid.hasChildren(selected_row_array[count]);
                
                if (has_child == 0 ) {
                    var fin_stmt_checkout_id = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Settlement_Checkout_ID')).getValue();
                    var est_stmt_checkout_id = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Est_Post_GL_ID')).getValue();
                    
                    if (accrual_or_final_flag == 'f') {
                        var stmt_checkout_id = fin_stmt_checkout_id;
                    } else  {
                        var stmt_checkout_id = est_stmt_checkout_id;
                    }
                    
                    xml = xml +  '<PSRecordSet stmt_checkout_id="' + stmt_checkout_id + '"></PSRecordSet>';    
                }
            }
            xml = xml + '</Root>';
         
            data = {"action": "spa_stmt_checkout",
                "flag": "prepare_invoice",
                "accrual_or_final_flag": accrual_or_final_flag,  
                "delivery_month" : as_of_date,
                "xml": xml
            };

            adiha_post_data('alert', data, '', '', 'settlement_checkout_refresh', '', '');
        }

        /*
         * Function for open parameter popup to prepare invoice
         */
        prepare_invoice_popup = function() {
            var label_width = parseInt(ui_settings['field_size']) + parseInt(ui_settings['offset_left']);
            var prepare_invoice_form_data = [
                                    {type: "settings", labelWidth: label_width, inputWidth: ui_settings['field_size'], position: "label-top", offsetLeft: ui_settings['offset_left']},
                                    {type: "calendar", name: "as_of_date", label: "Invoice Month", "dateFormat": client_date_format,"serverDateFormat":"%Y-%m-%d"},
                                    {type: "button", value: "Ok", img: "tick.png"}
                                ];
            
            var prepare_invoice_popup = new dhtmlXPopup();

            
            prepare_invoice_popup.attachEvent("onShow", function(){
                var prepare_invoice_form = prepare_invoice_popup.attachForm(get_form_json_locale(prepare_invoice_form_data));
                var date_to = settlement_checkout.settlement_checkout_form.getItemValue('date_to', true);
                prepare_invoice_form.setItemValue('as_of_date', date_to);
                
                prepare_invoice_form.attachEvent("onButtonClick", function(){
                    var as_of_date = prepare_invoice_form.getItemValue('as_of_date', true);
                    prepare_invoice(as_of_date);
                    prepare_invoice_popup.hide();
                });
            });

            var template_height = settlement_checkout.settlement_checkout_layout.cells('a').getHeight();
            var template_width = settlement_checkout.settlement_checkout_layout.cells('a').getWidth();
            prepare_invoice_popup.show(template_width * 0.51, template_height -15, 45, 45); 
            
        }

        /*
         * [Function to ignore data from grid]
         */
        ignore_row_grd = function() {
            var selected_row_array = get_all_rows_id_under_selection();

            if(selected_row_array){
                settlement_checkout.checkout_menu.setItemEnabled('ignore_row');
                settlement_checkout.checkout_menu.showItem('ignore_row');
            } else {
                settlement_checkout.checkout_menu.disableItem('ignore_row');
            }

            
            //return false;
            var xml = '<Root>';

            for (count = 0; count < selected_row_array.length; count++) {
                var has_child = settlement_checkout.settlement_checkout_grid.hasChildren(selected_row_array[count]);
                if (has_child == 0 ) {
                    
                var source_deal_detail_id = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Deal_Detail_ID')).getValue();
                var shipment_id= settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Shipment_ID')).getValue();
                var ticket_id= settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Ticket_ID')).getValue();
                var deal_charge_type_id = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Deal_Charge_Type_ID')).getValue();
                var contract_charge_type_id = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Contract_Charge_Type_ID')).getValue();
                var counterparty_id = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Counterparty_ID')).getValue();
                var counterparty_name = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Counterparty')).getValue();
                var contract_id = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Contract_ID')).getValue();
                var as_of_date = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('As_of_Date')).getValue();
                if(as_of_date) {
                    as_of_date = dates.convert_to_sql(as_of_date);
                }

                var term_start = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Term_Start')).getValue();
                if(term_start) {
                    term_start = dates.convert_to_sql(term_start);
                }

                var term_end = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Term_End')).getValue();
                if(term_end) {
                    term_end = dates.convert_to_sql(term_end);
                }
                                    
                var currency_id = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Currency_ID')).getValue();
                var uom_id = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Volume_UOM_ID')).getValue();
                var settlement_amount = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Amount_Value')).getValue();
                var settlement_volume = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Settlement_Volume_Value')).getValue();
                var settlement_price = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Price_Value')).getValue();
                
                var scheduled_volume = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Schedule_Volume')).getValue();
                var acutal_volume = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Actual_Volume')).getValue();
                
                var status = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Status')).getValue();
                var index_fees_id = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Index_Fees_ID')).getValue();
                var debit_gl_number = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Debit_GL_Number')).getValue();
                var credit_gl_number = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Credit_GL_Number')).getValue();
                var pnl_line_item_id = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('PNL_Line_Item_ID')).getValue();
                var charge_type_alias = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Charge_Type_Alias_ID')).getValue();
                var invoicing_charge_type_id = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Invoicing_Charge_Type_ID')).getValue();
                var invoice_frequency = '';
                var type = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Type')).getValue();
                
                
                xml = xml +  '<PSRecordSet source_deal_detail_id="' + source_deal_detail_id 
                                    + '" shipment_id="' + shipment_id 
                                    + '" ticket_id="' + ticket_id 
                                    + '" deal_charge_type_id="' + deal_charge_type_id 
                                    + '" contract_charge_type_id="' + contract_charge_type_id 
                                    + '" counterparty_id="' + counterparty_id 
                                    + '" counterparty_name="' + counterparty_name 
                                    + '" contract_id="' + contract_id 
                                    + '" as_of_date="' + as_of_date 
                                    + '" term_start="' + term_start 
                                    + '" term_end="' + term_end 
                                    + '" currency_id="' + currency_id 
                                    + '" uom_id="' + uom_id 
                                    + '" settlement_amount="'+ settlement_amount 
                                    + '" settlement_volume="' + settlement_volume 
                                    + '" settlement_price="' + settlement_price 
                                    + '" scheduled_volume="' + scheduled_volume 
                                    + '" acutal_volume="' + acutal_volume 
                                    + '" status="' + status 
                                    + '" index_fees_id="' + index_fees_id 
                                    + '" debit_gl_number="' + debit_gl_number 
                                    + '" credit_gl_number="' + credit_gl_number 
                                    + '" pnl_line_item_id="' + pnl_line_item_id 
                                    + '" charge_type_alias="' + charge_type_alias 
                                    + '" invoicing_charge_type_id="' + invoicing_charge_type_id
                                    + '" invoice_frequency="' 
                                    + '" type="' + type 
                                    + '"></PSRecordSet>';    
                }
            }
            xml = xml + '</Root>';

            data = {"action": "spa_stmt_checkout",
                "flag": "ignore",
                "xml": xml
            };
            
            dhtmlx.confirm({
                title: get_locale_value("Confirmation"),
                ok: get_locale_value("Confirm"),
                cancel: get_locale_value("No"),
                type: "confirm-error",
                text: get_locale_value('Are you sure you want to Ignore?'),
                callback: function(result) {
                    if (result) 
                        adiha_post_data('alert', data, '', '', 'settlement_checkout_refresh', '', '');
                }
            });  
            

        }

        /*
         * Function for to run post gl final
         */
        function run_post_gl_final() {
            var selected_row_array = get_all_rows_id_under_selection();
            var xml = '<Root>';

            for (count = 0; count < selected_row_array.length; count++) {
                var has_child = settlement_checkout.settlement_checkout_grid.hasChildren(selected_row_array[count]);
                
                if (has_child == 0 ) {
                    var fin_stmt_checkout_id = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Settlement_Checkout_ID')).getValue();
                    var est_stmt_checkout_id = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Est_Post_GL_ID')).getValue();

                    if (accrual_or_final_flag == 'f') {
                        var stmt_checkout_id = fin_stmt_checkout_id;
                    } else  {
                        var stmt_checkout_id = est_stmt_checkout_id;
                    }
                    var stmt_checkout_id = fin_stmt_checkout_id;
                    xml = xml +  '<PSRecordSet stmt_checkout_id="' + stmt_checkout_id + '"></PSRecordSet>';    
                }
            }
            xml = xml + '</Root>';
            
            data = {"action": "spa_stmt_checkout",
                "flag": "post_final_gl",
                "accrual_or_final_flag": accrual_or_final_flag,    
                "xml": xml
            };

            adiha_post_data('alert', data, '', '', 'settlement_checkout_refresh', '', '');
        }

        /*
         * Function for open parameter popup to run adjustment
         */
        function run_adjustment_popup() {
            var status = validate_form(settlement_checkout.settlement_checkout_form);
            
            if (status == false) { 
                return; 
            }
            
            var label_width = parseInt(ui_settings['field_size']) + parseInt(ui_settings['offset_left']);
            var cal_form_data = [
                                    {type: "settings", labelWidth: label_width, inputWidth: ui_settings['field_size'], position: "label-top", offsetLeft: ui_settings['offset_left']},
                                    {type: "calendar", name: "date_from", label: get_locale_value("Date From"), "dateFormat": client_date_format, "serverDateFormat":"%Y-%m-%d"},
                                    {type: "calendar", name: "date_to", label: get_locale_value("Date To"), "dateFormat": client_date_format, "serverDateFormat":"%Y-%m-%d"},
                                    {type: "button", value: get_locale_value("Ok"), img: "tick.png"}
                                ];
            
            var cal_popup = new dhtmlXPopup();
            
            cal_popup.attachEvent("onShow", function(){
                var cal_form = cal_popup.attachForm(cal_form_data);
                var date = settlement_checkout.settlement_checkout_form.getItemValue('date_from', true);
                var date1 = settlement_checkout.settlement_checkout_form.getItemValue('date_to', true);

                cal_form.setItemValue('date_from', date);
                cal_form.setItemValue('date_to', date1);
                
                cal_form.attachEvent("onButtonClick", function(){
                    var date_from = cal_form.getItemValue('date_from', true);
                    var date_to = cal_form.getItemValue('date_to', true);
                    run_adjustment(date_from, date_to);
                    cal_popup.hide();
                });
            });
            
            var template_height = settlement_checkout.settlement_checkout_layout.cells('a').getHeight();
            var template_width = settlement_checkout.settlement_checkout_layout.cells('a').getWidth();
            cal_popup.show(template_width * 0.29, template_height -15, 45, 45);
        }
        
        /*
         * Function for run adjustment
         */
        function run_adjustment(date_from, date_to) {
            var subsidiary_id = settlement_checkout.settlement_checkout_form.getItemValue('subsidiary_id');
            var strategy_id = settlement_checkout.settlement_checkout_form.getItemValue('strategy_id');
            var book_id = settlement_checkout.settlement_checkout_form.getItemValue('book_id');
            var subbook_id = settlement_checkout.settlement_checkout_form.getItemValue('subbook_id');
            
            var counterparty_id = settlement_checkout.settlement_checkout_form.getItemValue('counterparty_id');
                       
            var contract_obj = settlement_checkout.settlement_checkout_form.getCombo('contract_id');
            var contract_id = contract_obj.getChecked('contract_id');
            contract_id = contract_id.toString();
            
            date_from = dates.convert_to_sql(date_from);
            date_to = dates.convert_to_sql(date_to);
            
            var exec_call = "EXEC spa_stmt_adjustments "
                            + "@flag = 'd'"
                            + ",@counterparty_id = " + singleQuote(counterparty_id)
                            + ",@prod_date_from = " + singleQuote(date_from)
                            + ",@prod_date_to = " + singleQuote(date_to)
                            + ",@sub_id = " + singleQuote(subsidiary_id)
                            + ",@strategy_id = " + singleQuote(strategy_id)
                            + ",@book_id = " + singleQuote(book_id)
                            + ",@subbook_id = " + singleQuote(subbook_id)
                            + ",@contract_ID = " + singleQuote(contract_id);
            
            
            var param = 'call_from=SettlementCheckout&gen_as_of_date=1&batch_type=c';  
            adiha_run_batch_process(exec_call, param, 'Run Adjustment');
        }
 
        /*
         * Function to open the Settlement Invoice Screen
         */ 
        function open_settlement_invoice(invoice_id) {
            var js_path = '<?php echo $app_php_script_loc; ?>';
            var js_path_trm = '<?php echo $app_adiha_loc; ?>';
            invoice_window = new dhtmlXWindows();
            var src = js_path_trm + 'adiha.html.forms/_settlement_billing/stmt_checkout/stmt.invoice.php?invoice_id=' + invoice_id; 
            invoice_obj = invoice_window.createWindow('w1', 0, 0, 900, 600);
            invoice_window.window('w1').maximize();
            invoice_obj.setText("Settlement Invoice");

            invoice_obj.centerOnScreen();
            invoice_obj.setModal(true);
            invoice_obj.attachURL(src, false, true);
        }
        
        /*
         * Function to open the Deal Screen
         */
        function open_deal_screen(deal_id) {
            var js_path = '<?php echo $app_php_script_loc; ?>';
            var js_path_trm = '<?php echo $app_adiha_loc; ?>';
            
            //var deal_id = settlement_checkout.settlement_checkout_grid.cells(row_id, settlement_checkout.settlement_checkout_grid.getColIndexById('Deal_ID')).getValue();
            
            invoice_window = new dhtmlXWindows();
            
            var src = js_path_trm + 'adiha.html.forms/_deal_capture/maintain_deals/deal.detail.new.php?deal_id=' + deal_id + '&view_deleted=n'; 
            invoice_obj = invoice_window.createWindow('w1', 0, 0, 900, 600);
            invoice_window.window('w1').maximize();
            invoice_obj.setText("View Deal Detail");

            invoice_obj.centerOnScreen();
            invoice_obj.setModal(true);
            invoice_obj.attachURL(src, false, true);
        }
        
        /*
         * Context Menu
         * Settlement Invoice - Opens Settlement Invoice window
         */
        function load_context_menu() {
            context_menu = new dhtmlXMenuObject();
            context_menu.renderAsContextMenu();
            context_menu.loadFromHTML("context_menu", false);
            settlement_checkout.settlement_checkout_grid.enableContextMenu(context_menu);
            
            var context_menu_rowid;
            settlement_checkout.settlement_checkout_grid.attachEvent("onBeforeContextMenu", function(rowId,celInd,grid) {
                context_menu_rowid = rowId;
                
                var has_child = settlement_checkout.settlement_checkout_grid.hasChildren(rowId);
                
                if (has_child > 0) {
                   context_menu.hideItem('settlement_invoice');
                } else {
                    var invoice_status = settlement_checkout.settlement_checkout_form.getItemValue('invoice_status');
                    var invoice_id = settlement_checkout.settlement_checkout_grid.cells(context_menu_rowid, settlement_checkout.settlement_checkout_grid.getColIndexById('Invoice')).getValue();
                    if (!invoice_id) {
                        context_menu.hideItem('settlement_invoice');
                        return;
                    }

                    if (invoice_status == 4) {
                        context_menu.showItem('settlement_invoice');
                    } else {
                        context_menu.hideItem('settlement_invoice');
                    }
                }
                
                return true;
            });
            
            context_menu.attachEvent("onClick", function(menuitemId, zoneId) {
                switch (menuitemId) {
                    case 'settlement_invoice':
                        var invoice_id = settlement_checkout.settlement_checkout_grid.cells(context_menu_rowid, settlement_checkout.settlement_checkout_grid.getColIndexById('Invoice')).getValue();
                        open_settlement_invoice(invoice_id);
                        break;
                } 
            });
        }
        
        function apply_cash_delete(stmt_invoice_id) {
            data = {"action": "spa_stmt_apply_cash",
                    "flag": "delete",
                    "stmt_invoice_id": stmt_invoice_id
                };

            dhtmlx.confirm({
                title: "Confirmation",
                ok: "Confirm",
                cancel: "No",
                type: "confirm-error",
                text: 'Are you sure you want to delete?',
                callback: function(result) {
                    if (result) 
                        adiha_post_data('alert', data, '', '', 'settlement_checkout_refresh', '', '');
                }
            });  
        }
        
        function apply_cash_full(stmt_invoice_id) {
            data = {"action": "spa_stmt_apply_cash",
                    "flag": "full_apply",
                    "stmt_invoice_id": stmt_invoice_id
                };
                
            dhtmlx.confirm({
                title: "Confirmation",
                ok: "Confirm",
                cancel: "No",
                type: "confirm-error",
                text: 'Invoice will be marked as fully paid as of today. Are you sure you want to continue?',
                callback: function(result) {
                    if (result) 
                        adiha_post_data('alert', data, '', '', 'settlement_checkout_refresh', '', '');
                }
            }); 
        }
        
        function apply_cash_partial(stmt_invoice_id) {
            apply_cash_window = new dhtmlXWindows();
            win = apply_cash_window.createWindow('w1', 0, 0, 440, 200);
            win.setText("Apply Cash");
            win.centerOnScreen();
            win.setModal(true);
            
            var today = new Date();
            var ntoday = dates.convert_to_sql(today);
            
            var form_json = [{
                                type: 'block',
                                blockOffset: ui_settings['block_offset'],
                                list: [
                                    {
                                        'type': 'calendar', 
                                        'name': 'applied_date', 
                                        'label': 'Payment Date', 
                                        'dateFormat': client_date_format, 
                                        'serverDateFormat':'%Y-%m-%d',
                                        'position': 'label-top',
                                        'inputWidth': ui_settings['field_size'],
                                        'offsetLeft':ui_settings['offset_left'],
                                        'labelWidth': 'auto',
                                        'required': true,
                                        'userdata': {
                                            'validation_message': 'Required Field'
                                        },
                                        'tooltip': 'Apply Date',
                                        'value':ntoday
                                    },
                                    {
                                        'type': 'numeric',
                                        'name': 'apply_cash_amount',
                                        'label': 'Payment Amount',
                                        'position': 'label-top',
                                        'inputWidth': ui_settings['field_size'],
                                        'offsetLeft':ui_settings['offset_left'],
                                        'labelWidth': 'auto',
                                        'filtering': true,
                                        'tooltip': 'Apply Cash Amount',
                                        'value': ''
                                    },{type: "newcolumn"},
                                    {
                                        'type': 'checkbox',
                                        'name': 'full_amount_apply',
                                        'label': 'Full Amount',
                                        'position': 'label-right',
                                        'validate': 'NotEmpty',
                                        'inputWidth': ui_settings['field_size'],
                                        'offsetLeft':ui_settings['offset_left'],
                                        'labelWidth': 'auto',
                                        'tooltip': 'Full Amount Apply',
                                        'offsetTop':'74',
                                        'value': ''
                                    }
                            
                                ]
                            }];
            var toolbar_json = [{id:"save", type:"button", img:"save.gif", imgdis:"save_dis.gif", text:"Save", title:"Save", enabled:true}];
            var toolbar_obj = win.attachToolbar();
            toolbar_obj.setIconsPath(js_image_path + '/dhxtoolbar_web/');
            toolbar_obj.loadStruct(toolbar_json);
            toolbar_obj.attachEvent("onClick", function(id){
                var status = validate_form(form_obj);
                if (!status) {
                    return;
                }
                
                var applied_date = form_obj.getItemValue("applied_date", true);
                var apply_cash_amount = form_obj.getItemValue("apply_cash_amount");
                var is_full_checked = form_obj.isItemChecked("full_amount_apply");
                
                if (!is_full_checked && apply_cash_amount == '') {
                    show_messagebox('Either check Full Amount or input the Payment Amount');
                    return
                }
                
                if (is_full_checked == true) {
                    data = {"action": "spa_stmt_apply_cash",
                        "flag": "full_apply",
                        "stmt_invoice_id": stmt_invoice_id,
                        "applied_date": applied_date
                    };
                } else {
                    data = {"action": "spa_stmt_apply_cash",
                        "flag": "partial_apply",
                        "stmt_invoice_id": stmt_invoice_id,
                        "applied_amount": apply_cash_amount,
                        "applied_date": applied_date
                    };
                }
                
                adiha_post_data('alert', data, '', '', 'apply_cash_partial_callback', '', '');
            });
            var form_obj = win.attachForm();
            form_obj.load(form_json);
            form_obj.attachEvent("onChange", function (name, value, state){
                 if (name == 'full_amount_apply') {
                     if (state == false) {
                         form_obj.enableItem('apply_cash_amount');
                     } else {
                         form_obj.disableItem('apply_cash_amount');
                     }
                 }
            });
                        
        }
        
        apply_cash_partial_callback = function() {
            apply_cash_window.window('w1').close();
            settlement_checkout_refresh();
        }
        
        apply_cash_writeoff = function(stmt_checkout_id) {
            data = {"action": "spa_stmt_apply_cash",
                    "flag": "writeoff",
                    "stmt_checkout_id": stmt_checkout_id
                };
                
            dhtmlx.confirm({
                title: "Confirmation",
                ok: "Confirm",
                cancel: "No",
                type: "confirm-error",
                text: 'The variance amount will be write off for this charge. Are you sure you want to continue?',
                callback: function(result) {
                    if (result) 
                        adiha_post_data('alert', data, '', '', 'settlement_checkout_refresh', '', '');
                }
            }); 
        }

        
/***** Generic Grid and UI Functions Start *****/        
        
        var index_fees_id_arr = new Array();    
        var duplicate_index = new Array();
        var ticket_id_arr = new Array();
        function grid_data_color() {
            index_fees_id_arr.length = 0;
            duplicate_index.length = 0;
            settlement_checkout.settlement_checkout_grid.forEachRow(function(id){
                var has_child = settlement_checkout.settlement_checkout_grid.hasChildren(id);
                
                if (has_child == 0) {
                    var type = settlement_checkout.settlement_checkout_grid.cells(id, settlement_checkout.settlement_checkout_grid.getColIndexById('Type')).getValue();
                    if (type == 'Cost') {
                        settlement_checkout.settlement_checkout_grid.setRowColor(id,'#c9e7f2');    
                    } else if (type == 'Commodity Charge'){
                        settlement_checkout.settlement_checkout_grid.setRowColor(id,'#FCFCC5');    
                    } else if (type == 'Adjustment'){
                        settlement_checkout.settlement_checkout_grid.setRowColor(id,'#cbf4de');    
                    } else if (type == 'Complex Contract'){
                        settlement_checkout.settlement_checkout_grid.setRowColor(id,'#f7c5c5');    
                    }
                    
                    grid_data_validation_status(id);
                }
            });
            
            //To Mark Duplicate
            var invoice_status = settlement_checkout.settlement_checkout_form.getItemValue('invoice_status');
            if (invoice_status > 1) {
                settlement_checkout.settlement_checkout_grid.forEachRow(function(id){
                    var has_child = settlement_checkout.settlement_checkout_grid.hasChildren(id);

                    if (has_child == 0) {
                        var Index_Fees_ID = settlement_checkout.settlement_checkout_grid.cells(id, settlement_checkout.settlement_checkout_grid.getColIndexById('Index_Fees_ID')).getValue();
                        var Ticket_ID = settlement_checkout.settlement_checkout_grid.cells(id, settlement_checkout.settlement_checkout_grid.getColIndexById('Ticket_ID')).getValue();

                        if (duplicate_index.indexOf(Index_Fees_ID) > -1 || ticket_id_arr.indexOf(Ticket_ID) > -1) {
                            //var validation = settlement_checkout.settlement_checkout_grid.cells(id, settlement_checkout.settlement_checkout_grid.getColIndexById('Validation_Status')).getValue();
                            var image_html = '<img src=' + stmt_icon_path + 'stmt_duplicate1.png class="validation_images"><span class="tooltiptext">Duplicate GL Code Mapped.</span></img>';
                            settlement_checkout.settlement_checkout_grid.cells(id, settlement_checkout.settlement_checkout_grid.getColIndexById('Validation_Status')).setValue(image_html);
                        } 
                    }
                });
            }
            
        }
        
        grid_data_validation_status = function(id) {
            
            var invoice_status = settlement_checkout.settlement_checkout_form.getItemValue('invoice_status');
            var image_html = ''
            var tooltip_text = ''
                
            if (invoice_status ) {
                var Index_Fees_ID = settlement_checkout.settlement_checkout_grid.cells(id, settlement_checkout.settlement_checkout_grid.getColIndexById('Index_Fees_ID')).getValue();
                var Ticket_ID = settlement_checkout.settlement_checkout_grid.cells(id, settlement_checkout.settlement_checkout_grid.getColIndexById('Ticket_ID')).getValue();
               
                if (index_fees_id_arr.indexOf(Index_Fees_ID) == -1 || ticket_id_arr.indexOf(Ticket_ID) == -1) {
                    index_fees_id_arr.push(Index_Fees_ID);
                } else {
                    duplicate_index.push(Index_Fees_ID);
                }               
            }
                
            //Validation for Processed State & Ready for Invoice State
            if (invoice_status == 2 || invoice_status == 3) {
                var settlement_volume = settlement_checkout.settlement_checkout_grid.cells(id, settlement_checkout.settlement_checkout_grid.getColIndexById('Settlement_Volume')).getValue();
                var price = settlement_checkout.settlement_checkout_grid.cells(id, settlement_checkout.settlement_checkout_grid.getColIndexById('Price')).getValue();
                var amount = settlement_checkout.settlement_checkout_grid.cells(id, settlement_checkout.settlement_checkout_grid.getColIndexById('Amount')).getValue();     
                var type_cost = settlement_checkout.settlement_checkout_grid.cells(id, settlement_checkout.settlement_checkout_grid.getColIndexById('Type')).getValue(); 
                 
                if (settlement_volume == 0 || settlement_volume == '' || price == 0 || price == '' || amount == 0 || amount == '') {
                    if(type_cost == 'Commodity Charge'){
                       tooltip_text += 'Price/Amount/Volume is not available. Please check numeric values.\n';
                     }  
                }
                
                var Debit_GL_Number = settlement_checkout.settlement_checkout_grid.cells(id, settlement_checkout.settlement_checkout_grid.getColIndexById('Debit_GL_Number')).getValue();
                var Credit_GL_Number = settlement_checkout.settlement_checkout_grid.cells(id, settlement_checkout.settlement_checkout_grid.getColIndexById('Credit_GL_Number')).getValue();
                if (Debit_GL_Number == '' || Credit_GL_Number == '') {
                    tooltip_text += 'Debit GL or Credit GL is missing.\n';
                }
                var image_name = 'stmt_warning1.png';
                if (invoice_status == 3) {
                    var invoicing_charge_type_id = settlement_checkout.settlement_checkout_grid.cells(id, settlement_checkout.settlement_checkout_grid.getColIndexById('Invoicing_Charge_Type_ID')).getValue();
                    
					if (!invoicing_charge_type_id) {
						var invoicing_charge_type_id = settlement_checkout.settlement_checkout_grid.cells(id, settlement_checkout.settlement_checkout_grid.getColIndexById('Contract_Charge_Type_ID')).getValue();
                    }
					
                    if (!invoicing_charge_type_id && type_cost != 'Commodity Charge') {
                        image_name = 'stmt_warning2.png';                        
                        tooltip_text += 'Invoicing charge type is missing.\n';
                    }
                } 
                
                if (tooltip_text) {
                    image_html += '<img src=' + stmt_icon_path + image_name + ' class="validation_images"><span class="tooltiptext">' + tooltip_text + ' </span></img>';
                }

        
            } 
            
            if (invoice_status == 4) {
                var Apply_Cash_Status = settlement_checkout.settlement_checkout_grid.cells(id, settlement_checkout.settlement_checkout_grid.getColIndexById('Apply_Cash_Status')).getValue();
                var Settlement_Checkout_ID = settlement_checkout.settlement_checkout_grid.cells(id, settlement_checkout.settlement_checkout_grid.getColIndexById('Settlement_Checkout_ID')).getValue();
                
                if (Apply_Cash_Status == 'Not Paid') {
                    image_html += '<p>';
                } else if (Apply_Cash_Status == 'Partially Paid') {
                    image_html += '<img src=' + stmt_icon_path + 'stmt_apply_cash_variance.png class="validation_images"  onclick = "apply_cash_writeoff(' + Settlement_Checkout_ID + ')"><span class="tooltiptext">Partially Paid</span></img>';
                } else if (Apply_Cash_Status == 'Fully Paid') {
                    image_html += '<img src=' + stmt_icon_path + 'stmt_ready.png class="validation_images"><span class="tooltiptext">Fully Paid</span></img>';
                }
            }
            
            //For Unprocessed and Invoiced State
            if (image_html == '') {
                image_html = '<img src=' + stmt_icon_path + 'stmt_ready.png class="validation_images" title="Everything is good for next step"></img>';
            } 
            
            settlement_checkout.settlement_checkout_grid.cells(id, settlement_checkout.settlement_checkout_grid.getColIndexById('Validation_Status')).setValue(image_html);
        }
        
        checkout_expand_settlement = function(r_id, col_id) {
            var selected_row = settlement_checkout.settlement_checkout_grid.getSelectedRowId();
            var state = settlement_checkout.settlement_checkout_grid.getOpenState(selected_row);
            
            if (state)
                settlement_checkout.settlement_checkout_grid.closeItem(selected_row);
            else
                settlement_checkout.settlement_checkout_grid.openItem(selected_row);
        }
        
        function undock_window() {
            settlement_checkout.settlement_checkout_layout.cells('b').undock(300, 300, 900, 700);
            settlement_checkout.settlement_checkout_layout.dhxWins.window('b').maximize();
            settlement_checkout.settlement_checkout_layout.dhxWins.window("b").button("park").hide();
        }
        
        open_all_gridtree= function() {
           settlement_checkout.settlement_checkout_grid.expandAll();
           expand_state = 1;
        }


        close_all_gridtree = function() {
           settlement_checkout.settlement_checkout_grid.collapseAll();
           expand_state = 0;
        }
        
        function view_accrual_report(call_from) {
            var js_path = '<?php echo $app_php_script_loc; ?>';
            var js_path_trm = '<?php echo $app_adiha_loc; ?>';
            var report_name;
            var param = '';

            if (call_from == 'accrual_final_gl') {
                var deal_detail_id_arr = new Array();
                var selected_row = settlement_checkout.settlement_checkout_grid.getSelectedRowId();
                var selection_flag = 1;
                
                if (selected_row == null) {
                    selected_row = settlement_checkout.settlement_checkout_grid.getAllSubItems(0);
                    selection_flag = 0;
                }
                
                var selected_row_array1 = new Array();
                selected_row_array1 = selected_row.split(',');
                var selected_row_array = new Array();
                
                for (cnt = 0; cnt < selected_row_array1.length; cnt++) {
                    var has_child = settlement_checkout.settlement_checkout_grid.hasChildren(selected_row_array1[cnt]);
                    
                    if (has_child > 0 && selection_flag == 1) {
                        var child_rows = settlement_checkout.settlement_checkout_grid.getAllSubItems(selected_row_array1[cnt]);
                        var child_rows_arr = child_rows.split(',');
                        
                        for (ncnt = 0; ncnt < child_rows_arr.length; ncnt++) {
                            var c_has_child = settlement_checkout.settlement_checkout_grid.hasChildren(child_rows_arr[ncnt]);
                            if (c_has_child == 0) {
                                selected_row_array.push(child_rows_arr[ncnt]);
                            }
                        }
                        
                    } else if (has_child == 0) {
                        selected_row_array.push(selected_row_array1[cnt]);
                    }
                }
                
                
                for (count = 0; count < selected_row_array.length; count++) {
                    var has_child = settlement_checkout.settlement_checkout_grid.hasChildren(selected_row_array[count]);
                    
                    if (has_child == 0 ) {
                        var deal_detail_id = settlement_checkout.settlement_checkout_grid.cells(selected_row_array[count], settlement_checkout.settlement_checkout_grid.getColIndexById('Deal_Detail_ID')).getValue();
                        deal_detail_id_arr.push(deal_detail_id);
                    }
                }
                var all_deal_detail_id = deal_detail_id_arr.toString(); 
            }

            var doc_path;

            if (call_from == 'accrual_final_gl') {
                
                doc_path = 'adiha.html.forms/_settlement_billing/stmt_checkout/stmt.report.php'
                param = '&source_deal_detail_id=' + all_deal_detail_id;
                if (accrual_or_final_flag == 'a') {
                    call_from = 'accrual_gl';
                    report_name = 'Accrual GL Report';
                } else {
                    call_from = 'final_gl';
                    report_name = 'Final GL Report';
                }
            } else if (call_from == 'accrual_final_extract') {
                report_name = 'Accrual Final Extract Report';
                doc_path = 'adiha.html.forms/_settlement_billing/stmt_checkout/stmt.report.php'
            } else if (call_from == 'submitted_accrual') {
                
                var date_from = settlement_checkout.settlement_checkout_form.getItemValue('date_from', true);
                var date_to = settlement_checkout.settlement_checkout_form.getItemValue('date_to', true);
                var accounting_month = settlement_checkout.settlement_checkout_form.getItemValue('accounting_month', true);

                var deal_id_index = settlement_checkout.settlement_checkout_grid.getColIndexById('Deal_ID');
                var counterparty_id_index = settlement_checkout.settlement_checkout_grid.getColIndexById('Counterparty_ID');
                var contract_index = settlement_checkout.settlement_checkout_grid.getColIndexById('Contract_ID');
                var term_start_index = settlement_checkout.settlement_checkout_grid.getColIndexById('Term_Start');             
                var sel_row_ids = settlement_checkout.settlement_checkout_grid.getSelectedRowId();

                var all_selected_counterparty = new Array();
                var all_selected_contract_id = new Array();
                var all_selected_deal_id =new Array();

                var selected_rows = get_all_rows_id_under_selection();
                selected_rows.forEach(function(value) {
                    var counterparty_id = settlement_checkout.settlement_checkout_grid.cells(value,counterparty_id_index).getValue();
                    var contract_id = settlement_checkout.settlement_checkout_grid.cells(value,contract_index).getValue();
                    var term_start = settlement_checkout.settlement_checkout_grid.cells(value, term_start_index).getValue();
                    var deal_id = settlement_checkout.settlement_checkout_grid.cells(value, deal_id_index).getValue();
                    //removing the dublicate value before pushing in an array
                    if(all_selected_counterparty.indexOf(counterparty_id) === -1) {
                        all_selected_counterparty.push(counterparty_id);
                    }

                    if(all_selected_contract_id.indexOf(contract_id) === -1) {
                       all_selected_contract_id.push(contract_id); 
                    }

                    if(all_selected_deal_id.indexOf(deal_id) === -1) {
                       all_selected_deal_id.push(deal_id); 
                    }
                });
                
                var str_all_selected_counterparty = all_selected_counterparty.toString();
                var str_all_selected_contract_id = all_selected_contract_id.toString();
                var str_all_selected_deal_id = all_selected_deal_id.toString();

                var deal_id = settlement_checkout.settlement_checkout_grid.cells(sel_row_ids,deal_id_index).getValue();
                var counterparty_id = settlement_checkout.settlement_checkout_grid.cells(sel_row_ids,counterparty_id_index).getValue();
                var contract_id = settlement_checkout.settlement_checkout_grid.cells(sel_row_ids,contract_index).getValue();
                //var term_start = settlement_checkout.settlement_checkout_grid.cells(sel_row_ids, term_start_index).getValue();
                    
                report_name = 'Submitted Accrual GL Report';
                doc_path = 'adiha.html.forms/_settlement_billing/stmt_checkout/stmt.submitted.accrual.report.php'
                param = '&date_from=' + date_from + '&date_to=' + date_to + '&counterparty_id=' + all_selected_counterparty + '&contract_id=' + all_selected_contract_id + '&term_start=' + accounting_month + '&deal_id=' + all_selected_deal_id;
            }

            report_window = new dhtmlXWindows();            

            var src = js_path_trm + doc_path + '?call_from=' + call_from + param;

            report_obj = report_window.createWindow('w1', 0, 0, 900, 600);
            report_window.window('w1').maximize();
            report_obj.setText(report_name);

            report_obj.centerOnScreen();
            report_obj.setModal(true);
            report_obj.attachURL(src, false, true);  
        }


        open_grid_hyperlink = function(source_deal_detail_id, call_from, calc_type, term, shipment_id, ticket_id, as_of_date) { 
            var js_path = '<?php echo $app_php_script_loc; ?>';
            var js_path_trm = '<?php echo $app_adiha_loc; ?>'; 
            var report_name;

            if (call_from == 'price') {
                report_name = 'Settlement Price Report'; 
            } else if (call_from == 'volume') {
                report_name = 'Settlement Volume Report';  
            } else if (call_from == 'amount') {
                report_name = 'Settlement Amount Report';  
            }   

            grid_report_window = new dhtmlXWindows();            
            
            var src = js_path_trm + 'adiha.html.forms/_settlement_billing/stmt_checkout/stmt.report.php?call_from=' + call_from + '&source_deal_detail_id=' + source_deal_detail_id
                    + '&cal_type=' + calc_type + '&term=' + term + '&shipment_id=' + shipment_id + '&ticket_id=' + ticket_id + '&as_of_date=' + as_of_date ;

            grid_report_obj = grid_report_window.createWindow('w1', 0, 0, 900, 600);
            grid_report_window.window('w1').maximize();
            grid_report_obj.setText(report_name);

            grid_report_obj.centerOnScreen();
            grid_report_obj.setModal(true);
            grid_report_obj.attachURL(src, false, true);  
        }  

        open_grid_ticket_hyperlink = function(ticket_id){
            var js_path = '<?php echo $app_php_script_loc; ?>';
            var js_path_trm = '<?php echo $app_adiha_loc; ?>';

             grid_ticket_window = new dhtmlXWindows();            
            
            var src = js_path_trm + 'adiha.html.forms/_scheduling_delivery/scheduling_workbench/ticket.php?mode=u&ticket_id=' + ticket_id
                    +  '&is_match=0';

            grid_ticket_obj = grid_ticket_window.createWindow('w1', 0, 0, 900, 600);
            grid_ticket_window.window('w1').maximize();
            grid_ticket_obj.setText('Ticket');

            grid_ticket_obj.centerOnScreen();
            grid_ticket_obj.setModal(true);
            grid_ticket_obj.attachURL(src, false, true);   
        }

        function formatDate(date) {
            var d = new Date(date),
                month = '' + (d.getMonth() + 1),
                day = '' + d.getDate(),
                year = d.getFullYear();

            if (month.length < 2) month = '0' + month;
            if (day.length < 2) day = '0' + day;

            return [year, month, day].join('-');
        }
        
        apply_cash_icons_css = function() {
            $("#apply_cash_full")
                .mouseover(function() {
                    $(this).css('opacity', '0.5');
                })
                .mouseout(function() {
                    $(this).css('opacity', '1');
                });
                
            $("#apply_cash_partial")
                .mouseover(function() {
                    $(this).css('opacity', '0.5');
                })
                .mouseout(function() {
                    $(this).css('opacity', '1');
                });
                
            $("#apply_cash_delete")
                .mouseover(function() {
                    $(this).css('opacity', '0.5');
                })
                .mouseout(function() {
                    $(this).css('opacity', '1');
                });
                
            if (!has_rights_apply_cash) {
                $('.apply_cash_icons').hide();
            }
        }
        
        enable_checkout_privilege = function(button_name) {
            if (button_name  == 'manual_adjustment' && (has_rights_manual_adjustment)) {
                settlement_checkout.checkout_menu.setItemEnabled('manual_adjustment');
            } else if (button_name  == 'run_settlement' && (has_rights_run_settlement)) {
                settlement_checkout.checkout_menu.setItemEnabled('run_settlement');
            } else if (button_name  == 'ready_for_invoice_post_gl_est' && (has_rights_ready_for_invoice_post_gl_est)) {
                settlement_checkout.checkout_menu.setItemEnabled('ready_for_invoice_post_gl_est');
            } else if (button_name  == 'post_gl_final' && (has_rights_post_gl_final)) {
                settlement_checkout.checkout_menu.setItemEnabled('post_gl_final');
            } else if (button_name  == 'revert' && (has_rights_revert)) {
                settlement_checkout.checkout_menu.setItemEnabled('revert');
            } else if (button_name  == 'prepare_invoice' && (has_rights_prepare_invoice)) {
                settlement_checkout.checkout_menu.setItemEnabled('prepare_invoice');
            } else if (button_name  == 'accrual_final_gl' && (has_rights_accrual_final_gl)) {
                settlement_checkout.checkout_menu.setItemEnabled('accrual_final_gl');
            } else if (button_name  == 'accrual_final_extract' && (has_rights_accrual_final_extract)) {
                settlement_checkout.checkout_menu.setItemEnabled('accrual_final_extract');
            }
        }
/***** Generic Grid and UI Functions Start END *****/      
        
        /**
         * Returns all the rows ids of the child if parent node is selected or all selected rows
         * @return {Array} Row Ids array
         */
        function get_all_rows_id_under_selection() {
            var selected_row = settlement_checkout.settlement_checkout_grid.getSelectedRowId();
            var selection_flag = 1;
            
            if (selected_row == null) {
                selected_row = settlement_checkout.settlement_checkout_grid.getAllSubItems(0);
                selection_flag = 0;
            }
            
            var selected_row_array = new Array();
            selected_row_array = selected_row.split(',');
            
            var all_selected_rows = new Array();
            for (cnt = 0; cnt < selected_row_array.length; cnt++) {
                var has_child = settlement_checkout.settlement_checkout_grid.hasChildren(selected_row_array[cnt]);
                
                if (has_child > 0 && selection_flag == 1) {
                    var child_rows = settlement_checkout.settlement_checkout_grid.getAllSubItems(selected_row_array[cnt]);
                    var child_rows_arr = child_rows.split(',');
                    
                    for (child_cnt = 0; child_cnt < child_rows_arr.length; child_cnt++) {
                        var c_has_child = settlement_checkout.settlement_checkout_grid.hasChildren(child_rows_arr[child_cnt]);
                        if (c_has_child == 0) {
                            all_selected_rows.push(child_rows_arr[child_cnt]);
                        }
                    }
                    
                } else if (has_child == 0) {
                    all_selected_rows.push(selected_row_array[cnt]);
                }
            }

            return all_selected_rows;
        }

    generate_invoice = function(stmt_invoice_id) {
      settlement_checkout.settlement_checkout_layout.cells('b').progressOn();
        generate_document_for_view(stmt_invoice_id, '10000283', '', 'generate_invoice_callback');
      
    }
    generate_invoice_callback = function(status, file_path) {
        settlement_checkout.settlement_checkout_layout.cells('b').progressOff();
        // SettlementInvoice.layout.cells('d').progressOff();
    }  
    </script> 