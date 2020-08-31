<?php
/**
* Assign unassign transaction screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    </head>
<body>
<?php
    require('../../adiha.php.scripts/components/include.file.v3.php'); 

    $form_name = 'form_assign_unassign_transaction';
    $name_space = 'assign_unassign_transaction';
     
    $rights_assign_transaction = 14121400; 
    
    list( 
        $has_rights_assign_transaction 
    ) = build_security_rights( 
        $rights_assign_transaction 
    );

    $layout_json = '[
                        {id: "a", height: 160, text: "Filters", header: true, collapse: true},
                        {id: "b", text: "", header: "true", height: 275},  
                        {id: "c", text: "<a class=\"undock_a undock-btn undock_custom\" style=\"float: right; cursor:pointer\" title=\"Undock\"  onClick=\" undock_window();\"></a>Transactions"}
                    ]';
    $layout_name = 'assign_unassign_transaction_layout';
    $assign_unassign_transaction_layout = new AdihaLayout();
    echo $assign_unassign_transaction_layout->init_layout($layout_name, '', '3E', $layout_json, $name_space);  

    $menu_name = 'assign_unassign_menu';
    $menu_json = "[
            {id:'refresh', text:'Refresh', img:'refresh.gif', imgdis:'refresh_dis.gif'},
            {id:'t2', text:'Export', img:'export.gif', items:[
                {id:'excel', text:'Excel', img:'excel.gif', imgdis:'excel_dis.gif', title: 'Excel'},
                {id:'pdf', text:'PDF', img:'pdf.gif', imgdis:'pdf_dis.gif', title: 'PDF'}
            ]},
            {id:'t', text:'Process', img:'action.gif', items:[
                {id:'assign', text:'Assign', img:'process.gif', imgdis: 'process_dis.gif', enabled: false},
                //{id:'unassign', text:'Unassign', img:'process.gif', imgdis: 'process_dis.gif', enabled: false},
                {id:'commit', text:'Commit', img:'redo.gif', imgdis:'redo_dis.gif', enabled: false},
                //{id:'test_assessment', text:'Test Assesssment', img:'verify.gif', imgdis:'verify_dis.gif', enabled: false}
            ]},
            {id:'report', text:'Reports', img:'report.gif', imgdis:'select_unselect_dis.gif', items: [
                {id:'run_target_report', text:'Run Target Position Report', img:'report.gif', imgdis:'test_dis.gif', enabled:'true'}
            ]},
        ]";


    $assign_unassign_obj = new AdihaMenu();
    echo $assign_unassign_transaction_layout->attach_menu_cell($menu_name, "c"); 
    echo $assign_unassign_obj->init_by_attach($menu_name, $name_space);
    echo $assign_unassign_obj->load_menu($menu_json);
    echo $assign_unassign_obj->attach_event('', 'onClick', 'refresh_export_toolbar_click');

    echo $assign_unassign_transaction_layout->close_layout();             
?>
</body>
<script type="text/javascript">
    var select_all = 0; 
    var has_rights_assign_transaction = Boolean('<?php echo $has_rights_assign_transaction; ?>'); 
    var assign_unassign_transaction_ui = {};
    var active_object_id = 'NULL';
    var default_date = new Date();
    var default_date_year = default_date.getFullYear();
    var assign_transaction_grid = {};
    var unassign_transaction_grid = {};
    var theme_selected = 'dhtmlx_' + default_theme;
    var dependent_combo_obj = 'NULL';
    var req_assignment_type_obj = 'NULL';
    var select_rows = 'NULL';
    var ids = 'NULL';

    $(function() {
        load_filter_components();
        
        filter_obj = assign_unassign_transaction.assign_unassign_transaction_layout.cells('a').attachForm();
        var layout_cell_obj = assign_unassign_transaction.assign_unassign_transaction_layout.cells('b');
        load_form_filter(filter_obj, layout_cell_obj, '14121400', 2);
                    
        var volume_type_obj = assign_unassign_transaction_ui["form_0"].getForm();        
        var filter_obj = assign_unassign_transaction_ui["form_1"].getForm();
        var volume_type_combo_value = volume_type_obj.getCombo('req_volume_type');  
        var req_volume_type_obj = volume_type_obj.getItemValue('req_volume_type'); 

        if (req_volume_type_obj == 't' || req_volume_type_obj == 'r') {
            assign_unassign_transaction_ui["form_0"].enableItem('req_tier_type');
        } else {                     
            assign_unassign_transaction_ui["form_0"].disableItem('req_tier_type');
        }
        req_assignment_type_obj = volume_type_obj.getItemValue('req_assignment_type');
        if (req_assignment_type_obj == 5173) { //sold-transfer
                    volume_type_combo_value.addOption([['s','Sales']]);
                    assign_unassign_transaction_ui["form_0"].enableItem('req_gen_state');
                    assign_unassign_transaction_ui["form_0"].enableItem('req_vintage_from');
                    assign_unassign_transaction_ui["form_0"].enableItem('req_vintage_to');
                    assign_unassign_transaction_ui["form_0"].enableItem('req_delivery_date_from'); 
                    assign_unassign_transaction_ui["form_0"].enableItem('req_delivery_date_to');
                    assign_unassign_transaction_ui["form_0"].setRequired('req_delivery_date_from',true);
                    assign_unassign_transaction_ui["form_0"].setRequired('req_delivery_date_to',true);
                    assign_unassign_transaction_ui["form_0"].enableItem('label_req_deal_id');
                    assign_unassign_transaction_ui["form_0"].setItemValue('req_volume_type', 's');                    
                    assign_unassign_transaction_ui["form_0"].disableItem('req_volume_type');
                    assign_unassign_transaction_ui["form_0"].enableItem('req_counterparty');                    
                    // assign_unassign_transaction_ui["form_0"].disableItem('req_compliance_year');
        } else { //rpc compliance
            assign_unassign_transaction_ui["form_0"].enableItem('req_volume_type');
            assign_unassign_transaction_ui["form_0"].setItemValue('req_volume_type', ''); 
            assign_unassign_transaction_ui["form_0"].disableItem('req_gen_state'); 
            assign_unassign_transaction_ui["form_0"].disableItem('req_vintage_from');
            assign_unassign_transaction_ui["form_0"].disableItem('req_vintage_to'); 
            assign_unassign_transaction_ui["form_0"].disableItem('req_delivery_date_from'); 
            assign_unassign_transaction_ui["form_0"].disableItem('req_delivery_date_to');        
            assign_unassign_transaction_ui["form_0"].setRequired('req_delivery_date_from',false);
            assign_unassign_transaction_ui["form_0"].setRequired('req_delivery_date_to',false);    
            assign_unassign_transaction_ui["form_0"].disableItem('label_req_deal_id');
            assign_unassign_transaction_ui["form_0"].disableItem('req_counterparty');
            // assign_unassign_transaction_ui["form_0"].enableItem('req_compliance_year');
            volume_type_combo_value.deleteOption('s');
        }
    
        if (req_volume_type_obj == 'f') {
                    assign_unassign_transaction_ui["form_0"].enableItem('req_volume');
                    assign_unassign_transaction_ui["form_0"].disableItem('req_deal_id');
                    assign_unassign_transaction_ui["form_0"].enableItem('req_uom');
        } else {
            assign_unassign_transaction_ui["form_0"].disableItem('req_volume');
            assign_unassign_transaction_ui["form_0"].disableItem('req_deal_id');
            assign_unassign_transaction_ui["form_0"].setItemValue('req_volume', '');                 
            assign_unassign_transaction_ui["form_0"].disableItem('req_uom');
        }    

        volume_type_obj.attachEvent('onChange', function(name, value) {
            if (name == 'req_volume_type') {
                var volume_type = assign_unassign_transaction_ui["form_0"].getItemValue('req_volume_type');

                if (volume_type == 'f') {
                    assign_unassign_transaction_ui["form_0"].enableItem('req_volume');
                    assign_unassign_transaction_ui["form_0"].disableItem('req_deal_id');
                    assign_unassign_transaction_ui["form_0"].enableItem('req_uom');
                }
                //  else if (volume_type == 'r') {
                //     assign_unassign_transaction_ui["form_0"].enableItem('req_deal_id');
                //     assign_unassign_transaction_ui["form_0"].disableItem('req_volume');
                //     assign_unassign_transaction_ui["form_0"].setItemValue('req_volume', '');                                     
                //     assign_unassign_transaction_ui["form_0"].disableItem('req_uom');
                // } 
                else {
                    assign_unassign_transaction_ui["form_0"].setItemValue('req_volume', ''); 
                    assign_unassign_transaction_ui["form_0"].disableItem('req_volume');
                    assign_unassign_transaction_ui["form_0"].disableItem('req_deal_id');
                    assign_unassign_transaction_ui["form_0"].setItemValue('req_volume', '');
                    assign_unassign_transaction_ui["form_0"].setItemValue('req_uom', '');                  
                    assign_unassign_transaction_ui["form_0"].disableItem('req_uom');
                }

                if (volume_type == 't' || volume_type == 'r') {
                    assign_unassign_transaction_ui["form_0"].enableItem('req_tier_type');
                } else {                    
                    assign_unassign_transaction_ui["form_0"].setItemValue('req_tier_type', '');
                    assign_unassign_transaction_ui["form_0"].disableItem('req_tier_type');
                }
            } else if (name == 'req_assignment_type') {
                var assignment_type = assign_unassign_transaction_ui["form_0"].getItemValue(name);  

                if (assignment_type == 5173) { //sold-transfer
                    volume_type_combo_value.addOption([['s','Sales']]);
                    assign_unassign_transaction_ui["form_0"].enableItem('req_gen_state');
                    assign_unassign_transaction_ui["form_0"].enableItem('req_vintage_from');
                    assign_unassign_transaction_ui["form_0"].enableItem('req_vintage_to');
                    assign_unassign_transaction_ui["form_0"].enableItem('req_delivery_date_to');
                    assign_unassign_transaction_ui["form_0"].enableItem('req_delivery_date_from');                    
                    assign_unassign_transaction_ui["form_0"].setRequired('req_delivery_date_from',true);
                    assign_unassign_transaction_ui["form_0"].setRequired('req_delivery_date_to',true);
                    assign_unassign_transaction_ui["form_0"].enableItem('label_req_deal_id');
                    assign_unassign_transaction_ui["form_0"].setItemValue('req_volume_type', 's');                    
                    assign_unassign_transaction_ui["form_0"].disableItem('req_volume_type');
                    assign_unassign_transaction_ui["form_0"].setItemValue('req_volume', '');
                    assign_unassign_transaction_ui["form_0"].disableItem('req_volume');
                    assign_unassign_transaction_ui["form_0"].setItemValue('req_uom', '');
                    assign_unassign_transaction_ui["form_0"].disableItem('req_uom');
                    assign_unassign_transaction_ui["form_0"].enableItem('req_counterparty');
                    // assign_unassign_transaction_ui["form_0"].disableItem('req_compliance_year');
                    assign_unassign_transaction_ui["form_0"].disableItem('req_tier_type');
                    assign_unassign_transaction_ui["form_0"].setItemValue('req_tier_type', '')

                } else { //rpc compliance
                    assign_unassign_transaction_ui["form_0"].enableItem('req_volume_type');
                    assign_unassign_transaction_ui["form_0"].setItemValue('req_volume_type', 't'); 
                    assign_unassign_transaction_ui["form_0"].setItemValue('req_gen_state','');
                    assign_unassign_transaction_ui["form_0"].disableItem('req_gen_state');
                    assign_unassign_transaction_ui["form_0"].setItemValue('req_vintage_from','');
                    assign_unassign_transaction_ui["form_0"].disableItem('req_vintage_from');
                    assign_unassign_transaction_ui["form_0"].setItemValue('req_vintage_to','');
                    assign_unassign_transaction_ui["form_0"].disableItem('req_vintage_to');
                    assign_unassign_transaction_ui["form_0"].setItemValue('req_delivery_date_from','');
                    assign_unassign_transaction_ui["form_0"].disableItem('req_delivery_date_from');
                    assign_unassign_transaction_ui["form_0"].setItemValue('req_delivery_date_to','');
                    assign_unassign_transaction_ui["form_0"].disableItem('req_delivery_date_to');                    
                    assign_unassign_transaction_ui["form_0"].setRequired('req_delivery_date_from',false);
                    assign_unassign_transaction_ui["form_0"].setRequired('req_delivery_date_to',false);
                    assign_unassign_transaction_ui["form_0"].setItemValue('label_req_deal_id',null);
                    assign_unassign_transaction_ui["form_0"].disableItem('label_req_deal_id');
                    assign_unassign_transaction_ui["form_0"].setItemValue('req_counterparty','');
                    assign_unassign_transaction_ui["form_0"].disableItem('req_counterparty');
                    // assign_unassign_transaction_ui["form_0"].enableItem('req_compliance_year'); 
                    if(volume_type != 'f') {
                        assign_unassign_transaction_ui["form_0"].enableItem('req_tier_type'); 
                    }     
                    volume_type_combo_value.deleteOption('s');
                } 
            }  
        });

        volume_type_obj.attachEvent('onInputChange', function(name, value, form) {
            var vintage_to = volume_type_obj.getItemValue('req_vintage_to');               
            var vintage_from = volume_type_obj.getItemValue('req_vintage_from');             
            var delivery_date_to = volume_type_obj.getItemValue('req_delivery_date_to');               
            var delivery_date_from = volume_type_obj.getItemValue('req_delivery_date_from'); 
            if (value && name == 'req_vintage_to' || name == 'req_vintage_from') {
                if(vintage_to && vintage_to <= vintage_from) {
                    show_messagebox("Vintage To date is less than Vintage From");
                    volume_type_obj.setItemValue(name, null); 
                } 
            }

            if (value && name == 'req_delivery_date_to' || name == 'req_delivery_date_from') {
                if(delivery_date_to && delivery_date_to <= delivery_date_from) {
                    show_messagebox("Delivery Date To date is less than Delivery Date From");
                    volume_type_obj.setItemValue(name, null); 
                } 
            } 
            return false; 
        });

        filter_obj.attachEvent('onInputChange', function(name, value, form) {
            var vintage_to = filter_obj.getItemValue('inv_vintage_to');               
            var vintage_from = filter_obj.getItemValue('inv_vintage_from'); 
            if (value && name == 'inv_vintage_to' || name == 'inv_vintage_from') {
                if(vintage_to && vintage_to <= vintage_from) {
                    show_messagebox("Vintage To date is less than Vintage From");
                    filter_obj.setItemValue(name, null); 
                } 
            }
            return false; 
        });

        assign_unassign_transaction_ui["form_0"].setItemValue('req_compliance_year', default_date_year)
        
        assign_unassign_transaction.assign_unassign_menu.hideItem('report');
    });

    function undock_window() {
        assign_unassign_transaction.assign_unassign_transaction_layout.cells('b').undock(300, 300, 900, 700);
        assign_unassign_transaction.assign_unassign_transaction_layout.dhxWins.window('b').button('park').hide();
        assign_unassign_transaction.assign_unassign_transaction_layout.dhxWins.window('b').maximize();
    }

    function load_filter_components() {
        var data = {"action": "spa_create_application_ui_json",
                    "flag": "j",
                    "application_function_id" : 14121400,
                    "template_name": 'AssignUnassignTransaction',
                    "group_name": "Requirements,Inventory" };
        result = adiha_post_data('return_array', data, '', '', 'load_filter_form_data', false);

        //console.log(result);
    } 

    function load_filter_form_data(result) {
        var result_length = result.length;
        dependent_combo_obj = result[0][6];
        var tab_json = '';
        
        for (i = 0; i < result_length; i++) {
            if (i > 0)
                tab_json = tab_json + ",";
            tab_json = tab_json + (result[i][1]);
        }



        tab_json = '{tabs: [' + tab_json + ']}';
 
        assign_unassign_transaction_ui["assign_unassign_transaction_tabs" + active_object_id] = assign_unassign_transaction.assign_unassign_transaction_layout.cells("b").attachTabbar();
        assign_unassign_transaction_ui["assign_unassign_transaction_tabs" + active_object_id].loadStruct(tab_json);
        
        var first_tab = '';
        
        for (j = 0; j < result_length; j++) {
            first_tab = 'detail_tab_' + result[0][0]; 
            tab_id = 'detail_tab_' + result[j][0];
            assign_unassign_transaction_ui["form_" + j] = assign_unassign_transaction_ui["assign_unassign_transaction_tabs" + active_object_id].cells(tab_id).attachForm();   
            
            if (result[j][2]) { 
                assign_unassign_transaction_ui["form_" + j].loadStruct(result[j][2], function() {                    
                                                                                if (j == 0) { 
                                                                                        load_dependent_combo (result[0][6], 0,  assign_unassign_transaction_ui["form_" + j], '', 1); 
                                                                                    }
                                                                                    
                                                                                });
                var form_name = 'assign_unassign_transaction_ui["form_" + ' + j + ']';
                attach_browse_event(form_name, 14121400, '', '', '');

            }    
                   
        }
        
        assign_unassign_transaction_ui["assign_unassign_transaction_tabs" + active_object_id].tabs(first_tab).setActive();
    }

    function refresh_export_toolbar_click(args) {
        switch(args) {
            case 'refresh':
                var assign_unassign = 'a';

                var validate_return = validate_form(assign_unassign_transaction_ui["form_0"]);
                if (validate_return === false) {
                    return;
                }
				assign_unassign_transaction.assign_unassign_transaction_layout.cells('c').progressOn(); 
                refresh_grid_assign();
                
            break;
            case 'assign':
                var all_row_id = assign_transaction_grid.getAllRowIds(); 

                dhtmlx.message({
                    type: "confirm",
                    text: 'Are you sure you want to assign the selected deal?',
                    title: "Confirm",
                    callback: function(result) {                         
                        if (result) {
							var assignment_type = assign_unassign_transaction_ui["form_0"].getItemValue('req_assignment_type');
							
							if (assignment_type == 10013) {
								sales_transfer_form();
							} else {
								do_transaction(0, 'NULL','','','');
							}
                        }                           
                    } 
                });
                
            break;
            case 'commit':
                var row_id = assign_transaction_grid.getSelectedRowId();

                if (row_id == null) {
                    show_messagebox('Please select data from the grid.');
                    return;
                }

                dhtmlx.message({
                    type: "confirm-warning",
                    text: 'Are you sure you want to commit the selected deal?',
                    title: "Warning",
                    callback: function(result) {                         
                        if (result) {
                            var assignment_type = assign_unassign_transaction_ui["form_0"].getItemValue('req_assignment_type');
                            var assignment_state = assign_unassign_transaction_ui["form_0"].getItemValue('req_assigned_jurisdication');
                            var compliance_year = assign_unassign_transaction_ui["form_0"].getItemValue('req_compliance_year');
                            
                            commit_recs_window = new dhtmlXWindows();
                            var src = js_php_path + '../adiha.html.forms/_allowance_credit_assignment/assign.commit.recs.php?compliance_year=' + compliance_year + '&assignment_state=' + assignment_state + '&assignment_type=' + assignment_type;
                            new_commit_recs = commit_recs_window.createWindow('Commit RECs', 0, 0, 1000, 400);
                            new_commit_recs.setText("Commit RECs");
                            new_commit_recs.setModal(true);
                            new_commit_recs.attachURL(src, false, true);                            
                        }                           
                    } 
                });
                
            break;
        }
    }

    function refresh_grid_assign() {   
        var form_data = assign_unassign_transaction_ui["form_0"].getFormData();

        for (var a in form_data) {
            if (assign_unassign_transaction_ui["form_0"].getItemType(a) == 'calendar') {
                eval('var ' + a + ' = (assign_unassign_transaction_ui["form_0"].getItemValue("' + a + '", true) == "") ? "NULL" : assign_unassign_transaction_ui["form_0"].getItemValue("' + a + '", true);');
            } else {
                eval('var ' + a + ' = (assign_unassign_transaction_ui["form_0"].getItemValue("' + a + '") == "") ? "NULL" : assign_unassign_transaction_ui["form_0"].getItemValue("' + a + '");');
            }
        }

        var form_data_filter = assign_unassign_transaction_ui["form_1"].getFormData();

        for (var a in form_data_filter) {
            if (assign_unassign_transaction_ui["form_1"].getItemType(a) == 'calendar') {
                eval('var ' + a + ' = (assign_unassign_transaction_ui["form_1"].getItemValue("' + a + '", true) == "") ? "NULL" : assign_unassign_transaction_ui["form_1"].getItemValue("' + a + '", true);');
            } else {
                if(a == 'book_structure') {
                    eval('var book_structure = "' + form_data_filter[a] + '";');
                } else if(a == 'subsidiary_id') {
                    eval('var subsidiary_id = "' + form_data_filter[a] + '";');
                } else if(a == 'strategy_id') {
                    eval('var strategy_id = "' + form_data_filter[a] + '";');
                } else if(a == 'book_id') {
                    eval('var book_id = "' + form_data_filter[a] + '";');
                } else if(a == 'subbook_id') {
                    eval('var subbook_id = "' + form_data_filter[a] + '";');
                } else {
                    eval('var ' + a + ' = (assign_unassign_transaction_ui["form_1"].getItemValue("' + a + '") == "") ? "NULL" : assign_unassign_transaction_ui["form_1"].getItemValue("' + a + '");');
                }
            }
        } 

        var flag;
        var unassign;
 
        flag = 'o';
        unassign = 0;
        var action = 'NULL';
        if (has_rights_assign_transaction)
            assign_unassign_transaction.assign_unassign_menu.setItemEnabled('assign'); 

		if (req_assignment_type == 10013) req_assignment_type = 5146;  	 
        if (req_assignment_type == 5146) {
            assign_unassign_transaction.assign_unassign_menu.setItemEnabled('commit'); 
            action = 'spa_find_assign_transation'
        }
        
        if (req_assignment_type == 5173) {
            action = 'spa_find_assign_transation_sales'
        }

        if (!subsidiary_id) {
            subsidiary_id = 'NULL';
        }

        if (!strategy_id) {
            strategy_id = 'NULL';
        }

        if (!book_id) {
            book_id = 'NULL';
        }
        var inv_sub_book_combo = assign_unassign_transaction_ui["form_1"].getCombo('inv_sub_book');
        var inv_sub_book = inv_sub_book_combo.getChecked().join(",");

        if (!inv_sub_book) {
            inv_sub_book = 'NULL';
        }

        var sp_url_param = {                    

                        'flag': flag,       
                        'fas_sub_id': subsidiary_id,       
                        'fas_strategy_id': strategy_id,
                        'fas_book_id': book_id,
                        'req_assignment_type': req_assignment_type,
                        'req_program_scope' : req_program_scope,
                        'req_assigned_state': req_assigned_jurisdication,
                        'req_tier_type': req_tier_type, 
                        'req_gen_state': req_gen_state,
                        //'req_env_product': req_env_product,
                        'req_assignment_priority' : req_assignment_priority,
                        //'req_fifo_lifo': req_sort_type,
                        'req_compliance_year': req_compliance_year,
                        'req_gen_date_from': req_vintage_from,
                        'req_gen_date_to': req_vintage_to,
                        'req_delivery_date_from': req_delivery_date_from,
                        'req_delivery_date_to': req_delivery_date_to,
                        'req_counterparty_id': req_counterparty,
                        //'req_book_structure' : book_structure,
                        'req_volume_type' : req_volume_type,
                        'req_volume': req_volume,
                        'req_convert_uom_id': req_uom,
                        'req_deal_id': req_deal_id,
                        'req_assigned_date': req_assigned_date,
                        'curve_id': 'NULL',
                        'table_name': 'NULL',

                        //'inv_book_structure' : inv_book_structure,
                        'inv_env_product':inv_env_product,
                        'inv_tier_type': inv_tier_type, 
                        'inv_gen_date_from': inv_vintage_from,
                        'inv_gen_date_to': inv_vintage_to,
                        'inv_gen_state': inv_gen_state,
                        'inv_cert_from': inv_certificate_no_from,
                        'inv_cert_to': inv_certificate_no_to,
                        'inv_counterparty_id': inv_counterparty,
                        'inv_sub_book': inv_sub_book,
//                        'inv_subsidiary_id' : inv_subsidiary_id,
//                        'inv_strategy_id' : inv_strategy_id,
//                        'inv_book_id' : inv_book_id,
                       // 'inv_subbook_id' : inv_subbook_id,
                        //'gen_year': vintage_year,
                        //'generator_id': generator_credit_source,
                        // 'udf_group1': udf_group_1,
                        // 'udf_group2': udf_group_2,
                        // 'udf_group3': udf_group_3,  
                        // 'assignment_group': 'NULL',
                        //'unassign': unassign,
                        'action': action
        }; 
 
        assign_unassign_transaction.assign_unassign_transaction_layout.cells('c').attachStatusBar({height: 30, text: '<div id="pagingArea_b"></div>'});
        
        assign_unassign_transaction.assign_unassign_menu.setItemDisabled('run_target_report');
        // if (assign_unassign == 'a') {
            assign_transaction_grid = assign_unassign_transaction.assign_unassign_transaction_layout.cells("c").attachGrid();
            assign_transaction_grid.setImagePath(js_php_path + "components/lib/adiha_dhtmlx/themes/" + theme_selected + "/imgs/dhxgrid_web/");

            assign_transaction_grid.setHeader('Process ID,Demand,Demand Reference ID,Row Unique ID,Inventory,Inventory Reference ID,Detail ID,Deal Date,Vintage,Jurisdiction,Tier,Technology,Generation State,Generator,Environment Product,Counterparty,Volume Assigned,Volume Left,Bonus,Total Volume,UOM,Price',
                null,
                ["text-align:left;","text-align:left;","text-align:left;","text-align:left;","text-align:left;","text-align:left;","text-align:left;","text-align:left;","text-align:left;","text-align:left;","text-align:left;","text-align:left;","text-align:left;","text-align:left;","text-align:left;","text-align:left;","text-align:right;","text-align:right;","text-align:right;","text-align:right;","text-align:right;","text-align:right;"]);
            assign_transaction_grid.setColumnIds('Process Table,assign_deal,dem_ref_id,row_unique_id,ID,inv_ref_id,Deal ID,Deal Date,Vintage,Jurisdiction,tier_type,Technology,Gen State,Generator,Env Product,Counterparty,Volume Available,Volume Assigned,Bonus,Total Volume,UOM,Price');
            assign_transaction_grid.setColAlign("left,left,left,left,left,left,left,left,left,left,left,left,left,left,left,left,right,right,right,right,right,right");
            assign_transaction_grid.setColTypes('ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro_v,ro,ro_no,ro_v,ro,ro');
            assign_transaction_grid.setColSorting('str,str,str,str,str,str,str,str,str,str,str,str,str,str,str,str,str,str,str,str,str,str');
            assign_transaction_grid.setInitWidths('150,150,150,150,150,150,150,150,150,150,150,150,150,150,150,150,150,150,150,150,150,150,150');
            assign_transaction_grid.attachHeader('#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#numeric_filter,#numeric_filter,#text_filter,#numeric_filter,#numeric_filter,#numeric_filter,#text_filter');
            assign_transaction_grid.setColumnsVisibility('true,false,false,true, true,false,true,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false'); 
            assign_transaction_grid.setPagingWTMode(true,true,true,[10,20,30,40,50,60,70,80,90,100]);
            assign_transaction_grid.enablePaging(true, 50, 0, 'pagingArea_b');
            assign_transaction_grid.i18n.decimal_separator = '.';
            assign_transaction_grid.i18n.group_separator = ',';
            assign_transaction_grid.enableMultiselect(true); 
            assign_transaction_grid.enableColumnMove(true);
            assign_transaction_grid.setPagingSkin('toolbar');
            assign_transaction_grid.init();             
            assign_transaction_grid.enableHeaderMenu();  

            sp_url_param  = $.param(sp_url_param);
            var sp_url  = js_data_collector_url + "&" + sp_url_param ;
            assign_transaction_grid.clearAll();
            assign_transaction_grid.load(sp_url, function(){
                assign_transaction_grid.filterByAll();
                all_row_id = assign_transaction_grid.getAllRowIds(); 
                if (!all_row_id) {
                    assign_unassign_transaction.assign_unassign_menu.setItemDisabled('assign');
                }
                assign_unassign_transaction.assign_unassign_transaction_layout.cells('c').progressOff();
            });            
    }

    
    function do_transaction(committed, compliance_group_id, sale_transfer_counterparty, sale_transfer_trader, sale_transfer_price) {
        var form_data = assign_unassign_transaction_ui["form_0"].getFormData();

        for (var a in form_data) {
            if (assign_unassign_transaction_ui["form_0"].getItemType(a) == 'calendar') {
                eval('var ' + a + ' = (assign_unassign_transaction_ui["form_0"].getItemValue("' + a + '", true) == "") ? "NULL" : assign_unassign_transaction_ui["form_0"].getItemValue("' + a + '", true);');
            } else {
                eval('var ' + a + ' = (assign_unassign_transaction_ui["form_0"].getItemValue("' + a + '") == "") ? "NULL" : assign_unassign_transaction_ui["form_0"].getItemValue("' + a + '");');
            }
        }

        var form_data_filter = assign_unassign_transaction_ui["form_1"].getFormData();

        for (var a in form_data_filter) {
            if (assign_unassign_transaction_ui["form_1"].getItemType(a) == 'calendar') {
                eval('var ' + a + ' = (assign_unassign_transaction_ui["form_1"].getItemValue("' + a + '", true) == "") ? "NULL" : assign_unassign_transaction_ui["form_1"].getItemValue("' + a + '", true);');
            } else {
                eval('var ' + a + ' = (assign_unassign_transaction_ui["form_1"].getItemValue("' + a + '") == "") ? "NULL" : assign_unassign_transaction_ui["form_1"].getItemValue("' + a + '");');
            }
        }

        var sub_id = assign_unassign_transaction_ui["form_0"].getItemValue('subsidiary_id'); 

        var row_id = assign_transaction_grid.getAllRowIds();
        row_id_arr = row_id.split(',')
        
        for (var i=0; i<row_id_arr.length; i++) {
            row_id_arr[i] = parseInt(row_id_arr[i]) + 1;
        }

        var selected_row_ids = row_id_arr.toString();
        
        var table_name = '';
        var volume_available = '';

        if (row_id != null) {
            var table_row_id = row_id;
            var selected_row_array_d = table_row_id.split(',');
            
            for(var i = 0; i < selected_row_array_d.length; i++) {
        
                if (i == 0) {
                    table_name = assign_transaction_grid.cells(selected_row_array_d[i], 0).getValue();
                    assign_id = assign_transaction_grid.cells(selected_row_array_d[i], 1).getValue();
                    volume_available = assign_transaction_grid.cells(selected_row_array_d[i], 14).getValue();
                    volume_assign = assign_transaction_grid.cells(selected_row_array_d[i], 15).getValue();
                } else {
                    table_name = table_name + ',' + assign_transaction_grid.cells(selected_row_array_d[i], 0).getValue();
                    assign_id = assign_id + ',' + assign_transaction_grid.cells(selected_row_array_d[i], 1).getValue();
                    volume_available = volume_available + ',' + assign_transaction_grid.cells(selected_row_array_d[i], 14).getValue();
                    volume_assign = volume_assign + ',' + assign_transaction_grid.cells(selected_row_array_d[i], 15).getValue();
                }
            }
        } else { 
            table_name = '';
            assign_id = 'NULL';
        }
        
        var call_from_sale_deal = 0;
        var call_from_old = 0;
        var volume_type = assign_unassign_transaction_ui["form_0"].getItemValue('req_volume_type'); 
        var assigned_date  = assign_unassign_transaction_ui["form_0"].getItemValue('req_assigned_date', true);
        var req_volume = assign_unassign_transaction_ui["form_0"].getItemValue('req_volume');
        var req_deal_id = 'NULL';
        if (req_volume == '') {
            var req_volume = 'NULL';
        } 
       
        if (volume_type == 'r' && volume_available >= volume_assign) { 
            call_from_sale_deal = 1 ;
            req_deal_id = assign_unassign_transaction_ui["form_0"].getItemValue('req_deal_id');
        } else if (volume_type == 'f' && volume_available >= volume_assign) { 
            call_from_sale_deal = 2 ; 
        } else  {
            call_from_sale_deal = 0; 
        }   

        if (volume_type == 'f' || volume_type == 'r' ) {
            call_from_old = 1;
        } else  {
            call_from_old = 0;
        }

        var selected_assignment_type = req_deal_id = assign_unassign_transaction_ui["form_0"].getItemValue('req_assignment_type');
        if (selected_assignment_type == 5173) { //sold_transfer
            call_from_sale_deal = 1;
        } else {
            call_from_sale_deal = 0;
        }
        var table_name_array = table_name.split(",");
        table_name = table_name_array[0];
        
        var assign_id_array = assign_id.split(",");
        assign_id = assign_id_array[0] ? '' : 'NULL';
        
        if (assign_id_array[0] == 'NULL'){
            assign_id = 'NULL';
        }

        var assign_unassign = (assign_unassign == 'a') ? 0 : 1; 
       
        var sp_url_param = {
            "assignment_type": req_assignment_type,
            "assigned_state": req_assigned_jurisdication,
            "compliance_year": req_compliance_year,
            "assigned_date": assigned_date,
            //"assigned_counterparty": req_assigned_counterparty,
            //"assigned_price": sold_price,
            //"trader_id": trader,
            //"unassign": assign_unassign,
            //"gen_state": gen_jurisdiction,
            //"gen_year": vintage_year,
            "gen_date_from": req_vintage_from,
            "gen_date_to": req_vintage_to,
            //"generator_id": generator_credit_source,
            "counterparty_id": req_counterparty,
            "book_deal_type_map_id": sub_id,
            "table_name": table_name,
            "assign_id": assign_id,
            "volume": req_volume,
            "select_all_deals": select_all,
            "selected_row_ids": selected_row_ids, 
            "committed": committed,
            "compliance_group_id": compliance_group_id,
            "call_from_sale_deal": call_from_sale_deal,
            "original_deal_id": req_deal_id,
            "call_from_old" : call_from_old,
            "action": "spa_assign_transaction"
        };
        //console.log(sp_url_param);
        //return 
       
        adiha_post_data('alert', sp_url_param, '', '', assign_transaction_grid.destructor());

    }

    function refresh_grid_callback() {
        var sub_id = assign_unassign_transaction_ui["form_0"].getItemValue('subsidiary_id'); 
        var strategy_id = assign_unassign_transaction_ui["form_0"].getItemValue('strategy_id'); 
        var book_id = assign_unassign_transaction_ui["form_0"].getItemValue('book_id'); 
        var sub_book_id = assign_unassign_transaction_ui["form_0"].getItemValue('subbook_id'); 

        refresh_grid_assign(sub_id, strategy_id, book_id, sub_book_id);
    }

    function set_source_group_text_value(generator_group_id, generator_group_name) {
        assign_unassign_transaction_ui["form_1"].setReadonly('generator_credit_source', false);
        assign_unassign_transaction_ui["form_1"].setItemValue('generator_credit_source', generator_group_id);
        assign_unassign_transaction_ui["form_1"].setItemValue('label_generator_credit_source', generator_group_name);
    } 
	
	
	sales_transfer_form = function() {
		var sales_transfer_window = new dhtmlXWindows();
		win = sales_transfer_window.createWindow('w1', 0, 0, 540, 200);
		win.setText("Create Sales Transfer");
		win.centerOnScreen();
		win.setModal(true);
		
		var form_json = [{
							type: 'block',
							blockOffset: ui_settings['block_offset'],
							list: [
								{
									'type': 'combo',
									'name': 'counterparty',
									'label': 'Counterparty',
									'position': 'label-top',
									'inputWidth': ui_settings['field_size'],
									'offsetLeft':ui_settings['offset_left'],
									'labelWidth': 'auto',
									'tooltip': 'Counterparty',
									'filtering':true,
									'filtering': true,
									'userdata': {
										'validation_message': 'Required Field'
									},
									'options':''
								},{
									'type': 'input',
									'name': 'price',
									'label': 'Price',
									'position': 'label-top',
									'inputWidth': ui_settings['field_size'],
									'offsetLeft':ui_settings['offset_left'],
									'labelWidth': 'auto',
									'tooltip': 'Price'
								},{type: 'newcolumn', offset: 1},
								{
									'type': 'combo',
									'name': 'trader',
									'label': 'Trader',
									'position': 'label-top',
									'inputWidth': ui_settings['field_size'],
									'offsetLeft':ui_settings['offset_left'],
									'labelWidth': 'auto',
									'tooltip': 'Trader',
									'filtering':true,
									'filtering': true,
									'userdata': {
										'validation_message': 'Required Field'
									},
									'options':''
								}
							]
						}];
		var toolbar_json = [{id:"save", type:"button", img:"save.gif", imgdis:"save_dis.gif", text:"Save", title:"Save", enabled:true}];
		var toolbar_obj = win.attachToolbar();
		toolbar_obj.setIconsPath(js_image_path + '/dhxtoolbar_web/');
		toolbar_obj.loadStruct(toolbar_json);
		toolbar_obj.attachEvent("onClick", function(id){	
		
			var status = validate_form(form_obj);
			
			if(status) {
				var st_counterparty = form_obj.getItemValue('counterparty');
				var st_trader = form_obj.getItemValue('trader');
				var st_price = form_obj.getItemValue('price');
				if (st_price == null) st_price = 0;
				do_transaction(0, 'NULL', st_counterparty, st_trader, st_price);
				win.close();
			}
		});
            
		var form_obj = win.attachForm();
		
		form_obj.load(form_json, function() {
			var cm_param = {
						"action": "spa_source_counterparty_maintain",
						"flag": "c",						
						"call_from": "form",
						"has_blank_option": false
					};

			cm_param = $.param(cm_param);
			var url = js_dropdown_connector_url + '&' + cm_param;
			var combo_obj = form_obj.getCombo('counterparty');
			combo_obj.load(url, function() {
				combo_obj.selectOption(0);
			});
			
			var cm_param = {
						"action": "('SELECT source_trader_id,trader_name FROM source_traders')", 
						"call_from": "form",
						"has_blank_option": false
					};

			cm_param = $.param(cm_param);
			var url = js_dropdown_connector_url + '&' + cm_param;
			var combo_obj1 = form_obj.getCombo('trader');
			combo_obj1.load(url, function() {
				combo_obj1.selectOption(0);
			});
		});
}

</script>
</html>