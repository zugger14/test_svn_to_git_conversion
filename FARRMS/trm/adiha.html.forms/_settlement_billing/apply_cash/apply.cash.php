<?php
/**
* Apply cash screen
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
    require('../../../adiha.php.scripts/components/include.file.v3.php');

    $namespace = 'apply_cash';

    $rights_apply_cash = 10241100;
    $rights_apply_cash_iu = 10241110;
    $rights_apply_cash_save = 10241112;
    $rights_apply_cash_del = 10241111;
    $rights_apply_cash_write_off = 10241112;

    list (
        $has_rights_apply_cash,
        $has_rights_apply_cash_iu,
        $has_rights_apply_cash_save,
        $has_rights_apply_cash_del,
        $has_rights_apply_cash_write_off
    ) = build_security_rights(
        $rights_apply_cash,
        $rights_apply_cash_iu,
        $rights_apply_cash_save,
        $rights_apply_cash_del,
        $rights_apply_cash_write_off
    );

    //Layout
    $layout_json = '[   
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
                            height:         250,
                            header:         true,
                            collapse:       false,
                            fix_size:       [false, null]
                        },
                        {
                            id:             "c",
                            text:           "<div><a class=\"undock_cell_c undock_custom\" style=\"float:right;cursor:pointer\" title=\"Undock\"  onClick=\"undock_apply_cash_grid();\"><!--&#8599;--></a>Apply Cash</div>",
                            header:         true,
                            collapse:       false
                        }
                    ]';
    
    $apply_cash_layout = new AdihaLayout();
    echo $apply_cash_layout->init_layout('apply_cash_layout', '', '3E', $layout_json, $namespace);
    echo $apply_cash_layout->attach_event('', 'onDock', 'on_grid_ondock');
    echo $apply_cash_layout->attach_event('', 'onUnDock', 'on_grid_onundock');

    /*Fetching filter form from backend*/
    $xml_file = "EXEC spa_create_application_ui_json @flag='j', @application_function_id='10241100', @template_name='apply_cash'";
    $form_data = readXMLURL2($xml_file);
    $form_data_array = array();
    $tab_data = array();    
    
    if (is_array($form_data) && sizeof($form_data) > 0) {
        foreach ($form_data as $data) {
            // array_push($tab_data, $data['tab_json']);
            array_push($form_data_array, $data['form_json']);
        }
    }
    
    $form_data_json = $form_data_array[0];

    // Menu
    $menu_json = '[  
        {id:"refresh", img:"refresh.gif", text:"Refresh", title:"Refresh"},
        {id:"save", img:"save.gif", imgdis:"save_dis.gif", text:"Save", title:"Save", enabled: false},
        {id:"t1", img:"edit.gif", text:"Edit", items:[
            {id:"delete", img:"delete.gif", imgdis:"delete_dis.gif", text:"Delete", title:"Delete", enabled: false},
            {id:"write_off", img:"write_off.gif", imgdis:"write_off_dis.gif", text:"Write Off", title:"Write Off", enabled: false}
        ]},                               
        {id:"t2", text:"Export", img:"export.gif", items:[
            {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
            {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"},
        ]},
        { id:"pivot", text:"Pivot", img:"pivot.gif", imgdis:"pivot_dis.gif",enabled:"false"}
    ]';

    $apply_cash_menu = new AdihaMenu();
    echo $apply_cash_layout->attach_menu_cell("apply_cash_menu", 'c'); 
    echo $apply_cash_menu->init_by_attach("apply_cash_menu", $namespace);
    echo $apply_cash_menu->load_menu($menu_json);
    echo $apply_cash_menu->attach_event('', 'onClick', 'on_menu_click');

    // Grid
    $column_header = 'Invoice Number, Counterparty, Production Month, Invoice Due Date, Invoice Date, Payment Date, Charge Type, Invoice Amount, Amount, Variance, Comments,Save Invoice Detail Id, Contract Id,Counterparty Id, Calc Id, As of Date, Invoice Line Item Id, Int Ext Type, Invoice Type, Status, Adjustment';

    $grid_obj = new AdihaGrid();
    $grid_name = 'apply_cash_grid';
    echo $apply_cash_layout->attach_grid_cell($grid_name, 'c');
    echo $grid_obj->init_by_attach($grid_name, $namespace);
    echo $grid_obj->set_header($column_header,',,,,,,,right,right,right,,,,,,,,,,,,,,');
    echo $grid_obj->set_column_types('tree,ro,ro,ro,ro,ro,ro,ro_a,ed_a,ro_a,ed_no,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro');    
    for ($i=11;$i<21;$i++) {
        echo $grid_obj->hide_column($i);
    }
    echo $grid_obj->set_column_alignment(',,,,,,,right,right,right,,,,,,,,,,,,,,');
    echo $grid_obj->set_sorting_preference("str,str,str,str,str,str,str,str,str,str,str,str,str,str,str,str,int,int,int,str,str");
    echo $grid_obj->set_widths('200,150,150,150,150,150,150,150,150,150,150,150,150,150,150,150,150,150,150,150,150');
    echo $grid_obj->return_init();
    echo $grid_obj->enable_multi_select();

    // Closing Layout   
    echo $apply_cash_layout->close_layout();
?>
    <div id="context_menu" style="display: none;">
        <div id="view_invoice" text="<?php echo get_locale_value('View Invoice'); ?>"></div>
    </div>

    <script type="text/javascript">
        var dhxWins = new dhtmlXWindows();
        var has_rights_apply_cash = <?php echo (($has_rights_apply_cash) ? $has_rights_apply_cash : '0');?>;
        var has_rights_apply_cash_iu = <?php echo (($has_rights_apply_cash_iu) ? $has_rights_apply_cash_iu : '0');?>;
        var has_rights_apply_cash_save = <?php echo (($has_rights_apply_cash_save) ? $has_rights_apply_cash_save : '0');?>;
        var has_rights_apply_cash_del = <?php echo (($has_rights_apply_cash_del) ? $has_rights_apply_cash_del : '0');?>;
        var has_rights_apply_cash_write_off = <?php echo (($has_rights_apply_cash_write_off) ? $has_rights_apply_cash_write_off : '0');?>;
        var global_group_separator = "<?php echo $global_group_separator; ?>";
        var global_decimal_separator = "<?php echo $global_decimal_separator; ?>";
        var dependent_combos = "<?php echo $form_data[0]['dependent_combo']?>";
        var global_amount_rounding = "<?php echo $GLOBAL_AMOUNT_ROUNDING; ?>";
    
        $(function() {
            load_filter_form();

            /*Filling Dependent Combo Contract*/
            var attached_obj = apply_cash.apply_cash_layout.cells('b').getAttachedObject();        
            form_obj = attached_obj.getForm();
            form_obj.attachEvent("onChange", function(name, value) {
                if(name=='type_cash') {
                    if(value == 'a') {
                        change_item_state(form_obj, 'amount', false);
                    } else if(value == 'n') {
                        change_item_state(form_obj, 'amount', true);
                    }
                } else if(name=='production_month') {                    
                    var date_from = form_obj.getItemValue(name, true);
                    var split = date_from.split('-');
                    var year =  +split[0];
                    var month = +split[1];
                    var day = +split[2];

                    var date = new Date(year, month-1, day);
                    var lastDay = new Date(date.getFullYear(), date.getMonth() + 1, 0);
                    date_end = formatDate(lastDay);
                    form_obj.setItemValue('production_month_to', date_end);
                }
            });

            var combo_counterparty = form_obj.getCombo('counterparty_id');
            var combo_contract = form_obj.getCombo('contract_id');
            var default_format = form_obj.getUserData("counterparty_id", "default_format");
            if(default_format == 'm') {
                form_obj.attachEvent('onChange', function(name, value) {
                    if(name == 'counterparty_id') {
                        parent_value_ids = combo_counterparty.getChecked().join(",");
                        parent_value_ids = parent_value_ids.indexOf(",") == 0 ? parent_value_ids.substring(1, parent_value_ids.length) : parent_value_ids;
                        var combo_sql = {
                            'action' : 'spa_source_contract_detail',
                            'flag'   : 'e',
                            'counterparty_id' : parent_value_ids
                        };
                        var data = $.param(combo_sql);
                        var url = js_dropdown_connector_url + '&' + data;
                        combo_contract.clearAll();
                        combo_contract.setComboValue(null);
                        combo_contract.setComboText(null);
                        combo_contract.load(url);
                    }
                });
            }

            menu_obj = apply_cash.apply_cash_layout.cells('c').getAttachedMenu();
	  //apply_cash.apply_cash_grid.setNumberFormat("0,000.00",7,".",",");
		
            apply_cash.apply_cash_grid.setNumberFormat("0,000.00",7,"<?php echo $global_decimal_separator; ?>","<?php echo $global_group_separator; ?>");
            apply_cash.apply_cash_grid.setNumberFormat("0,000.00",8,"<?php echo $global_decimal_separator; ?>","<?php echo $global_group_separator; ?>");
            apply_cash.apply_cash_grid.setNumberFormat("0,000.00",9,"<?php echo $global_decimal_separator; ?>","<?php echo $global_group_separator; ?>");

            filter_obj = apply_cash.apply_cash_layout.cells('a').attachForm();
            var layout_cell_obj = apply_cash.apply_cash_layout.cells('b');
            load_form_filter(filter_obj, layout_cell_obj, '10241100', 2);
			
			apply_cash.apply_cash_grid.attachEvent("onEditCell", function(stage,rId,cInd,nValue,oValue){
				if (stage == 2 && cInd == 8) {
					var variance = apply_cash.apply_cash_grid.cells(rId,cInd-1).getValue() - apply_cash.apply_cash_grid.cells(rId,cInd).getValue();
					apply_cash.apply_cash_grid.cells(rId,cInd+1).setValue(variance);
					recalc_total();
				}
				return true;
			});
        });

        function formatDate(date) {
            var d = new Date(date),
                month = '' + (d.getMonth() + 1),
                day = '' + d.getDate(),
                year = d.getFullYear();

            if (month.length < 2) month = '0' + month;
            if (day.length < 2) day = '0' + day;

            return [year, month, day].join('-');
        }

        function undock_apply_cash_grid() {
            apply_cash.apply_cash_layout.cells("c").undock(300, 300, 900, 700);
            apply_cash.apply_cash_layout.dhxWins.window("c").button("park").hide();
            apply_cash.apply_cash_layout.dhxWins.window("c").maximize();
            apply_cash.apply_cash_layout.dhxWins.window("c").centerOnScreen();
        }

        function on_grid_ondock(name) {
             $(".undock_cell_c").show();
        }
        
        function on_grid_onundock(name) {
             $(".undock_cell_c").hide();
        }

        function change_item_state(parent_obj, item_name, bool) {
            if(bool) {
                if(parent_obj.topId) {
                    parent_obj.setItemEnabled(item_name);
                } else {
                    parent_obj.enableItem(item_name);
                }                
            } else {
                if(parent_obj.topId) {
                    parent_obj.setItemDisabled(item_name);
                } else {
                    parent_obj.disableItem(item_name);
                }
            }
        }

        function load_view_invoice_win(invoiceId) {
            var js_path_trm = '<?php echo $app_adiha_loc; ?>';
            var src = js_path_trm + 'adiha.html.forms/_settlement_billing/maintain_invoice/maintain.invoice.php?invoice_id=' + invoiceId; 
            w2 = dhxWins.createWindow('w2', 0, 0, 950, 600);
            w2.setText("View Invoice");
            w2.centerOnScreen();
            w2.setModal(true);
            w2.attachURL(src, false, true);
        }

        function load_context_menu() {
            var context_menu = new dhtmlXMenuObject();
            var invoice_number = -1;
            context_menu.renderAsContextMenu();
            context_menu.loadFromHTML("context_menu", false);
            apply_cash.apply_cash_grid.enableContextMenu(context_menu);

            apply_cash.apply_cash_grid.attachEvent("onBeforeContextMenu", function(rowId,celInd,grid) {
                context_menu_rowid = rowId;
                var selected_row_level = apply_cash.apply_cash_grid.getLevel(rowId);
                if(selected_row_level == 2) {
                    invoice_number = apply_cash.apply_cash_grid.cells(rowId, 0).getValue();
                    context_menu.showItem('view_invoice');
                } else {
                    context_menu.hideItem('view_invoice');
                }
                return true;
            });

            context_menu.attachEvent("onClick", function(menuitemId, zoneId) {
                if(menuitemId == 'view_invoice' && invoice_number != -1) {
                    load_view_invoice_win(invoice_number);
                }
            });
        }

        function load_filter_form() {
            // var user_date_fromat = '<?= $date_format; ?>';
            var form_json = <?php echo $form_data_json; ?>;


            var filter_form = apply_cash.apply_cash_layout.cells('b').attachForm();


            filter_form.loadStruct(form_json,function(){
                load_dependent_combo(dependent_combos, 0, filter_form);
            });
            // filter_form.setCalendarDateFormat('production_month', user_date_format);
            // filter_form.setCalendarDateFormat('production_month_to', user_date_format);
            // filter_form.setCalendarDateFormat('invoice_due_date', user_date_format);
            // filter_form.setCalendarDateFormat('receive_pay_date', user_date_format);
            filter_form.setItemValue('receive_pay_date', new Date());
        }

        function get_filter_data() {
            var attached_obj = apply_cash.apply_cash_layout.cells('b').getAttachedObject();        
            var form_obj = attached_obj.getForm();
            var status = validate_form(form_obj);

            if (status == false) {
                return -1;
            }

            // For Date Fields
            var production_month = form_obj.getItemValue('production_month', true);
            var receive_pay_date = form_obj.getItemValue('receive_pay_date', true);
            var production_month_to = form_obj.getItemValue('production_month_to', true);
            var invoice_due_date = form_obj.getItemValue('invoice_due_date', true);
			var show_prepay = form_obj.isItemChecked('show_prepay');
			if (show_prepay == true)
				show_prepay = 'y';
			else 
				show_prepay = 'n';
			
			var include_prior_variance = form_obj.isItemChecked('include_prior_variance');
			if (include_prior_variance == true)
				include_prior_variance = 'y';
			else 
				include_prior_variance = 'n';

            var form_data = form_obj.getFormData();

            form_data["production_month"] = production_month;
            form_data["receive_pay_date"] = receive_pay_date;
            form_data["production_month_to"] = production_month_to;
            form_data["invoice_due_date"] = invoice_due_date;
			form_data["show_prepay"] = show_prepay;
			form_data["include_prior_variance"] = include_prior_variance;

            return form_data;

        }

        function get_message(code) {
            switch(code) {
                case 'SAVE_CONFIRM':
                    return 'Are you sure you want to save?';
                break;
                case 'DELETE_CONFIRM':
                    return 'Are you sure you want to delete?';
                break;
            }
        }

        function get_selected_gridrow() {
            var selected_grid = apply_cash.apply_cash_grid.getSelectedRowId();
            if (selected_grid) {
                selected_grid = selected_grid.split(",");
                return selected_grid;
            } else {
                return false;
            }
        }

        function set_row_color(row_id, variance_value, save_stat) {
            if (variance_value == 0) {
                apply_cash.apply_cash_grid.setRowColor(row_id, "95BB9D");
            } else {
                switch(save_stat) {
                    case 'save':
                        apply_cash.apply_cash_grid.setRowColor(row_id, "CE3F3F");
                    break;
                    case 'write_off':
                        apply_cash.apply_cash_grid.setRowColor(row_id, "ECD68A");
                    break;
                    case 'settle':
                        apply_cash.apply_cash_grid.setRowColor(row_id, "FC7BB9");
                    break;
                    default:
                        apply_cash.apply_cash_grid.setRowColor(row_id, "FF7E7E");
                    break;
                }
            }
        }

        function set_totals(subchild_ids, child_ids, root_ids, response) {
            var add_subTotal_invoice_amount = 0;
            var add_subTotal_amount = 0;
            var add_subTotal_variance = 0;
            var add_total_invoice_amount = 0;
            var add_total_amount = 0;
            var add_total_variance = 0;
            var response_data = [];
            var is_cash_applied = ((apply_cash.apply_cash_layout.cells('b').getAttachedObject()).getForm()).getItemValue('type_cash');

            if(response != -1) {
                response.forEach(function(r) {
                    response_data.push(JSON.parse('{"id": "' + r["id"] + '", "invoice_number": "' + r["invoice_number"] + '", "sum_amount": ' + r["sum_amount"] + '}'));
                });
            }

            child_ids.forEach(function(j) {
                apply_cash.apply_cash_grid.cells(j, 6).setValue("<i><strong>" + get_locale_value('Sub-Total') + ":</strong></i>");

                subchild_ids.forEach(function(i) {
                    var subchild_invoice_number = apply_cash.apply_cash_grid.cells(i, 0).getValue();
                    var subchild_status = apply_cash.apply_cash_grid.cells(i, 19).getValue();
                    var child_invoice_number = apply_cash.apply_cash_grid.cells(j, 0).getValue();
                    var subchild_invoice_amount = (apply_cash.apply_cash_grid.cells(i, 7).getValue());
                    var subchild_amount = 0;
                    var subchild_variance = 0;

                    var applied_amount = (apply_cash.apply_cash_grid.cells(i, 8).getValue());

                    if (applied_amount && is_cash_applied == 'a') {
                        var variance = (subchild_invoice_amount - applied_amount).toFixed(2);
                        apply_cash.apply_cash_grid.cells(i, 9).setValue(variance);

                        set_row_color(i, variance);

                        if(variance != 0) {
                            if(apply_cash.apply_cash_grid.cells(i, 6).getValue() == 'Write Off') {
                                set_row_color(i, variance, 'write_off');
                            } else {
                                if(subchild_status == 'o') {
                                    set_row_color(i, variance, 'save'); 
                                } else if(subchild_status == 's') {
                                    set_row_color(i, variance, 'settle'); 
                                }
                            }
                        }

                        if(subchild_invoice_number == child_invoice_number) {
                            add_subTotal_invoice_amount += parseFloat(subchild_invoice_amount);
                            add_subTotal_amount += parseFloat(applied_amount);
                            add_subTotal_variance += parseFloat(variance);
                        }

                        return true;
                    }

                    if(response_data.length != 0) {
                        response_data.forEach(function(rd) {
                            var charge_type = apply_cash.apply_cash_grid.cells(i, 6).getValue();
                            
                            if(charge_type.trim() == rd["id"].trim() &&  subchild_invoice_number.trim() == rd["invoice_number"].trim()) {
                                var variance = subchild_invoice_amount - (rd["sum_amount"]);
                                apply_cash.apply_cash_grid.cells(i, 8).setValue(rd["sum_amount"]);
                                apply_cash.apply_cash_grid.cells(i, 9).setValue(variance);

                                set_row_color(i, variance);

                                subchild_amount += (apply_cash.apply_cash_grid.cells(i, 8).getValue());
                                subchild_variance = (apply_cash.apply_cash_grid.cells(i, 9).getValue());
                            }
                        });
                    }

                    if(subchild_invoice_number == child_invoice_number) {
                        add_subTotal_invoice_amount += parseFloat(subchild_invoice_amount);
                        add_subTotal_amount += parseFloat(subchild_amount);
                        add_subTotal_variance += parseFloat(subchild_variance);
                    }
                }); 

                apply_cash.apply_cash_grid.cells(j, 7).setValue(add_subTotal_invoice_amount);
                apply_cash.apply_cash_grid.cells(j, 8).setValue(add_subTotal_amount);
                apply_cash.apply_cash_grid.cells(j, 9).setValue(add_subTotal_variance);

                add_total_invoice_amount += add_subTotal_invoice_amount;
                add_total_amount += add_subTotal_amount;
                add_total_variance += add_subTotal_variance;

                add_subTotal_invoice_amount = 0;
                add_subTotal_amount = 0;
                add_subTotal_variance = 0;

            });

            // Total
            apply_cash.apply_cash_grid.cells(root_ids, 6).setValue("<b style='font-size:14px'>Total:</b>");
            apply_cash.apply_cash_grid.cells(root_ids, 7).setValue(add_total_invoice_amount);
            apply_cash.apply_cash_grid.cells(root_ids, 8).setValue(add_total_amount);
            apply_cash.apply_cash_grid.cells(root_ids, 9).setValue(add_total_variance);
        }

        function on_refresh_clicked() {
            apply_cash.apply_cash_menu.setItemEnabled('pivot');
            load_context_menu();
            if(has_rights_apply_cash_save){
            change_item_state(menu_obj, "save", false);
            }
            if(has_rights_apply_cash_write_off){
            change_item_state(menu_obj, "write_off", false);
            }

            var filter_data = get_filter_data();
            if (filter_data == -1) {
                return;
            }

            var selected_type_cash = filter_data['type_cash'] ? filter_data['type_cash'] : 'NULL';
            var round_value  = filter_data['round_value'] ? filter_data['round_value'] : global_amount_rounding

            if(filter_data['production_month'] > filter_data['production_month_to']) {
                show_messagebox("<b>'Prod Month To'</b> should be greater than <b>'Prod Month From'</b>");
                return;
            }

            var data_type = ',,,,,,,float,float,float,,,,,,,,,,,';

            if( '' != round_value ){
                var rounding_string = data_type.replace(/float/g,round_value);
                apply_cash.apply_cash_grid.enableRounding(rounding_string);
            }

            if(selected_type_cash == 'a') {
                apply_cash.apply_cash_grid.setColTypes('tree,ro,ro,ro,ro,ro,ro,ro_a,ro_a,ro_a,ed,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro');
            } else {
                apply_cash.apply_cash_grid.setColTypes('tree,ro,ro,ro,ro,ro,ro,ro_a,ed_a,ro_a,ed,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro');
            }
			var show_option = filter_data['show_option'];
			
			if (filter_data['include_prior_variance'] == 'y') {
				show_option = 'p';
			}
			
			var sql = {
                "action"                : "spa_apply_cash_module",
                "flag"                  : "u",
                "counterparty_id"       : filter_data['counterparty_id'].join(),
                "invoice_number"        : filter_data['invoice_number'] ? filter_data['invoice_number'] : 'NULL',
                "production_month"      : filter_data['production_month'] ? filter_data['production_month'] : 'NULL',
                "type"                  : filter_data['type'] ? filter_data['type'] : 'NULL',
                "contract_id"           : filter_data['contract_id'] ? filter_data['contract_id'] : 'NULL',
                "round_value"           : filter_data['round_value'] ? filter_data['round_value'] :global_amount_rounding,
                "receive_pay_date"      : filter_data['receive_pay_date'],
                "production_month_to"   : filter_data['production_month_to'] ? filter_data['production_month_to'] : 'NULL',
                "invoice_due_date"      : filter_data['invoice_due_date'] ? filter_data['invoice_due_date'] : 'NULL',
                "type_cash"             : filter_data['type_cash'] ? filter_data['type_cash'] : 'NULL',
                "grid_type"             : "tg",
                "grouping_column"       : "Total,SubTotal,invoice_number",
				"show_prepay"			: filter_data['show_prepay'] ? filter_data['show_prepay'] : 'NULL',
				"show_option"			: show_option ? show_option : 'NULL',
				"commodity"			: filter_data['commodity'] ? filter_data['commodity'] : 'NULL'
            };

            var counterparty_id = filter_data['counterparty_id'].join();
            var invoice_number = filter_data['invoice_number'] ? filter_data['invoice_number'] : 'NULL';
            var production_month = filter_data['production_month'] ? filter_data['production_month'] : 'NULL';
            var type = filter_data['type'] ? filter_data['type'] : 'NULL';
            var contract_id = filter_data['contract_id'] ? filter_data['contract_id'] : 'NULL';
            var round_value = filter_data['round_value'] ? filter_data['round_value'] :global_amount_rounding;
            var receive_pay_date = filter_data['receive_pay_date'];
            var production_month_to = filter_data['production_month_to'] ? filter_data['production_month_to'] : 'NULL';
            var invoice_due_date = filter_data['invoice_due_date'] ? filter_data['invoice_due_date'] : 'NULL';
            var type_cash = filter_data['type_cash'] ? filter_data['type_cash'] : 'NULL' + "'";
            if(production_month !== 'NULL') 
                production_month = "'"+production_month+"'";
            if(production_month_to !== 'NULL') 
                production_month_to = "'"+production_month_to+"'";
			var show_prepay =  filter_data['show_prepay'] ? filter_data['show_prepay'] : 'NULL';
			
			var commodity = filter_data['commodity'] ? filter_data['commodity'] : 'NULL';

            pivot_exec_spa = "EXEC spa_apply_cash_module @flag='u', @is_pivot = 'y', @counterparty_id='" +  counterparty_id
                    + "', @invoice_number=" +  invoice_number
                    + ", @production_month=" +  production_month
                    + ", @type='" +  type
                    + "', @contract_id=" +  contract_id
                    + ", @round_value='" +  round_value
                    + "', @receive_pay_date='" +  receive_pay_date
                    + "', @production_month_to=" +  production_month_to
                    + ", @invoice_due_date=" +  invoice_due_date
                    + ", @type_cash='" +  type_cash 
					+ ", @show_prepay='" +  show_prepay 
					+ "', @show_option='" +  show_option 
					+ "', @commodity='" +  commodity 
					+ "'";

            var data = $.param(sql);
            var data_url = js_data_collector_url + "&" + data;  
            apply_cash.apply_cash_grid.clearAndLoad(data_url, function() {
                var no_of_rows = apply_cash.apply_cash_grid.getRowsNum();
                if (no_of_rows) {
                    calc_amount();
                }
            })
            
            apply_cash.apply_cash_grid.attachEvent('onRowSelect', function(id, ind) {
                if(has_rights_apply_cash_del){
                        change_item_state(menu_obj, "delete", true);
                        }
                        
                    if(has_rights_apply_cash_iu){
                        change_item_state(menu_obj, "save", true);
                        }
                var selected_row_level = apply_cash.apply_cash_grid.getLevel(id);
                var selected_row_amount = apply_cash.apply_cash_grid.cells(id, 8).getValue();
                var selected_row_charge_type = apply_cash.apply_cash_grid.cells(id, 6).getValue();
                var selected_row_status = apply_cash.apply_cash_grid.cells(id, 19).getValue();
                if(selected_row_level == 2 && selected_row_amount != '') {
                    if(has_rights_apply_cash_iu){
                        change_item_state(menu_obj, "save", true);
                    }
                    if(selected_type_cash == 'a') {
                        if(has_rights_apply_cash_del){
                        change_item_state(menu_obj, "delete", true);
                        }
                        if(has_rights_apply_cash_iu){
                        change_item_state(menu_obj, "save", false);
                        }
                        if(selected_row_charge_type != 'Write Off') {
                            if(has_rights_apply_cash_write_off) {
                            change_item_state(menu_obj, "write_off", true);
                            }
                        } else {
                            if(has_rights_apply_cash_write_off) {
                            change_item_state(menu_obj, "write_off", false);
                            }
                        }
                        if(selected_row_status == 'o') {
                            if(has_rights_apply_cash_write_off) {
                            change_item_state(menu_obj, "write_off", true);
                            }
                        } else if(selected_row_status == 's') {
                            if(has_rights_apply_cash_write_off) {
                            change_item_state(menu_obj, "write_off", false);
                            }
                        }
                    } else {
                        
                        change_item_state(menu_obj, "delete", false);
                        
                        if(has_rights_apply_cash_write_off){
                        change_item_state(menu_obj, "write_off", false);
                        }
                    }
                } else {
                    if(has_rights_apply_cash_save){
                    change_item_state(menu_obj, "save", false);
                    }
                }
            });
            
            var calc_amount = function() {
                var total_id;
                var subtotal_ids = []; 
                var child_ids = [];                

                apply_cash.apply_cash_grid.expandAll();

                apply_cash.apply_cash_grid.forEachRow(function(id) {               
                    var root_id = apply_cash.apply_cash_grid.getParentId(id);
                    if (root_id == 0) {
                        total_id = id;
                    } else if (root_id == total_id) {
                        subtotal_ids.push(id);
                    } else {
                        child_ids.push(id);
                    }
                });

                var sql_amount = {
                    "action"                : "spa_apply_cash_combination",
                    "flag"                  : "m",
                    "counterparty_id"       : filter_data['counterparty_id'].join(),
                    "invoice_number"        : filter_data['invoice_number'] ? filter_data['invoice_number'] : 'NULL',
                    "production_month"      : filter_data['production_month'] ? filter_data['production_month'] : 'NULL',
                    "type_rp"               : filter_data['type'] ? filter_data['type'] : 'NULL',
                    "contract_id"           : filter_data['contract_id'] ? filter_data['contract_id'] : 'NULL',
                    "round_value"           : filter_data['round_value'] ? filter_data['round_value'] :global_amount_rounding,
                    "receive_pay_date"      : filter_data['receive_pay_date'],
                    "production_month_to"   : filter_data['production_month_to'] ? filter_data['production_month_to'] : 'NULL',
                    "invoice_due_date"      : filter_data['invoice_due_date'] ? filter_data['invoice_due_date'] : 'NULL',
                    "type_cash"             : filter_data['type_cash'] ? filter_data['type_cash'] : 'NULL',
                    "amount"                : filter_data['amount'] ? filter_data['amount'] : 'NULL',
					"show_prepay"           : filter_data['show_prepay'] ? filter_data['show_prepay'] : 'NULL',
					"show_option"			: show_option ? show_option : 'NULL',
					"commodity"           : filter_data['commodity'] ? filter_data['commodity'] : 'NULL'
                };

                data = $.param(sql_amount) + "&" + $.param({"type": "return_json"});

                $.ajax({
                    type: "POST",
                    dataType: "json",
                    url: js_form_process_url,
                    async: false,
                    data: data,
                    success: function(data) {
                        var response_data = data["json"];
                        
                        if(response_data.length != 0) {
                            set_totals(child_ids, subtotal_ids, total_id, response_data);
                        } else {
                            set_totals(child_ids, subtotal_ids, total_id, -1);
                        }
                    }
                });

            }
        }

        function on_save_clicked() {
            var selected_grid = get_selected_gridrow(); 
            if(!selected_grid) {
                show_messagebox("Please select invoice to save.")
                return;
            }
            var filter_data = get_filter_data();
            var combo_received_date_value = filter_data['receive_pay_date'];
            var xml_text = '<Root>';
            var msgCode = 0;

            selected_grid.forEach(function(i) {
                var has_children = apply_cash.apply_cash_grid.hasChildren(i);

                var invoice_number = apply_cash.apply_cash_grid.cells(i,0).getValue();
                var production_month = get_sql_date(apply_cash.apply_cash_grid.cells(i,2).getValue());
                var invoice_due_date = get_sql_date(apply_cash.apply_cash_grid.cells(i,3).getValue());
                var invoice_date = get_sql_date(apply_cash.apply_cash_grid.cells(i,4).getValue());

                var payment_date = get_sql_date(apply_cash.apply_cash_grid.cells(i,5).getValue());
                var received_date = (payment_date == '') ? get_sql_date(combo_received_date_value) : get_sql_date(apply_cash.apply_cash_grid.cells(i,5).getValue());

                var charge_type = apply_cash.apply_cash_grid.cells(i,6).getValue();
                var settlement_value = apply_cash.apply_cash_grid.cells(i,7).getValue();
                var cash_received = apply_cash.apply_cash_grid.cells(i,8).getValue();
                var variance = apply_cash.apply_cash_grid.cells(i,9).getValue();
                var comments = apply_cash.apply_cash_grid.cells(i,10).getValue();
                var save_invoice_detail_id = apply_cash.apply_cash_grid.cells(i,11).getValue();
				var is_adjustment = apply_cash.apply_cash_grid.cells(i,20).getValue();
				var calc_id = apply_cash.apply_cash_grid.cells(i,14).getValue();
				var invoice_line_item_id = apply_cash.apply_cash_grid.cells(i,16).getValue();
				
                if (has_children) {
                    msgCode = 1;
                    return;
                } else if (cash_received == 'null' || cash_received == "") {
                    msgCode = 2;
                    return;
                } else {
                    xml_text += '<PSRecordset invoice_number="' + invoice_number + '" production_month="' + production_month + '" charge_type="' + charge_type + '" settlement_value="' + settlement_value + '" cash_received="' + cash_received + '" comments="' + comments + '" save_invoice_detail_id="' + save_invoice_detail_id + '" variance="' + variance + '" received_date="' + received_date + '" invoice_due_date="' + invoice_due_date + '" invoice_date="' + invoice_date + '"  is_adjustment="' + is_adjustment + '" calc_id ="' + calc_id + '" invoice_line_item_id ="' + invoice_line_item_id + '"/>';
                }

            });

            xml_text += "</Root>";

            if (filter_data == -1) {
                return;
            }

            var sql = {
                "action"                : "spa_invoice_cash_received",
                "flag"                  : "NULL",
                "xmltext"               : xml_text,
                "counterparty_id"       : filter_data['counterparty_id'].join(),
                "contract_id"           : filter_data['contract_id'] ? filter_data['contract_id'] : 'NULL',
                "production_month"      : filter_data['production_month'] ? filter_data['production_month'] : 'NULL',
                "production_month_to"   : filter_data['production_month_to'] ? filter_data['production_month_to'] : 'NULL',
                "invoice_due_date"      : filter_data['invoice_due_date'] ? filter_data['invoice_due_date'] : 'NULL',
                "round_value"           : filter_data['round_value'] ? filter_data['round_value'] :global_amount_rounding,
                "invoice_number"        : filter_data['invoice_number'] ? filter_data['invoice_number'] : 'NULL',
                "type_rp"               : filter_data['type'] ? filter_data['type'] : 'NULL',
                "type_cash"             : filter_data['type_cash'] ? filter_data['type_cash'] : 'NULL',
				"show_prepay"			: filter_data['show_prepay'] ? filter_data['show_prepay'] : 'NULL',
				"show_option"			: filter_data['show_option'] ? filter_data['show_option'] : 'NULL',
                "commodity"           : filter_data['commodity'] ? filter_data['commodity'] : 'NULL'
            };

            switch(msgCode) {
                case 0:
                    confirm_messagebox(get_message('SAVE_CONFIRM'), function() {
                        form_obj.setItemValue("amount", "");
                        form_obj.setItemValue("type_cash", "a");
                        change_item_state(form_obj, 'amount', false);
                        adiha_post_data('alert', sql, '', '', 'on_refresh_clicked');
                    });
                break;
                case 1:
                    show_messagebox("select invoice row with amount only.")
                break;
                case 2:
                    show_messagebox("Amount field cannot be empty.")
                break;
            }
            
        }

        function on_menu_click(id, zoneId, cas) {
            switch(id) {
                case 'refresh':
                    on_refresh_clicked();
                break;

                case 'save':
                    on_save_clicked();
                break;

                case 'delete':
                    var selected_row = get_selected_gridrow();
                    var save_invoice_detail_id = [];
                    var flag = 'd';
                    var is_writeOff = false;

                    if(!selected_row) {
                        show_messagebox("Please select invoice to delete.")
                        return;
                    }

                    selected_row.forEach(function(i) {
                        save_invoice_detail_id.push(apply_cash.apply_cash_grid.cells(i,11).getValue());

                        var check_writeOff = apply_cash.apply_cash_grid.cells(i,6).getValue();
						var is_adjustment_entry = apply_cash.apply_cash_grid.cells(i,20).getValue();
                        if(check_writeOff == 'Write Off' || is_adjustment_entry == 'y') {
                            is_writeOff = true;
                        }
                    });

                    if(is_writeOff) {
                        if(selected_row.length > 1) {
                            show_messagebox("Select non writeoff invoice for multiple delete");
                            return;
                        } else {
                            flag = 'e';
                        }
                    }
					
					var sql = {
                        "action"                 : "spa_apply_cash_module",
                        "flag"                   : flag,
                        "counterparty_id"        : "NULL",
                        "save_invoice_detail_id" : save_invoice_detail_id.join(",")
                    };

                    confirm_messagebox(get_message('DELETE_CONFIRM'), function() {
                        if (!is_writeOff) {
                            form_obj.setItemValue("amount", "");
                            form_obj.setItemValue("type_cash", "n");
                            change_item_state(form_obj, 'amount', true); 
                        }
                        adiha_post_data('alert', sql, '', '', 'on_refresh_clicked');
                    });
                break;

                case 'write_off':
                    var i = apply_cash.apply_cash_grid.getSelectedRowId();
                    if (!i) {
                        show_messagebox("Select Invoice to Write Off.");
                        return;
                    }
                    var calc_id = apply_cash.apply_cash_grid.cells(i,14).getValue();
                    var as_of_date = apply_cash.apply_cash_grid.cells(i,15).getValue();
                    var prod_date = apply_cash.apply_cash_grid.cells(i,2).getValue();
                    var save_invoice_detail_id = apply_cash.apply_cash_grid.cells(i,11).getValue();
                    var amount = apply_cash.apply_cash_grid.cells(i,9).getValue();
                    var invoice_line_item_id = apply_cash.apply_cash_grid.cells(i,16).getValue();

                    var param = 'calc_id=' + calc_id + '&as_of_date=' + as_of_date + '&prod_date=' + prod_date + '&save_invoice_detail_id=' + save_invoice_detail_id + '&amount=' + amount + '&invoice_line_item_id=' + invoice_line_item_id;

                    w1 = dhxWins.createWindow('w1', 0, 0, 600, 500);
                    w1.setText("Apply Cash Write off");
                    w1.centerOnScreen();
                    w1.setModal(true);
                    w1.attachURL('apply.cash.writeoff.php?' + param);
                break;

                case 'excel':
                    var path = js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php';
                    apply_cash.apply_cash_grid.toExcel(path);
                break;

                case 'pdf':
                    var path = js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php';
                    apply_cash.apply_cash_grid.toPDF(path);
                break;
                case 'pivot':
                    var grid_obj = apply_cash.apply_cash_grid;
                    open_grid_pivot(grid_obj, 'apply_cash_grid', 1, pivot_exec_spa, 'Apply Cash');
                break;
            }
        }

        function on_writeOff_success(result) {
            var result = JSON.parse(result);
            var response = result[0];

            if(response["errorcode"] == 'Success') {
                success_call(response['message']);
            } else {
                success_call(response['message'], 'error');
            }

            var is_win = dhxWins.isWindow('w1');
            if(is_win) {
                w1.close();
            }

            on_refresh_clicked();
        }
		
		recalc_total = function() {
			apply_cash.apply_cash_grid.expandAll();
			
			apply_cash.apply_cash_grid.forEachRow(function(id) {               
				var level = apply_cash.apply_cash_grid.getLevel(id);
				var has_child = apply_cash.apply_cash_grid.hasChildren(id);
				if (level == 0 && has_child > 0) {
					var child_total = 0;
					var child_items = apply_cash.apply_cash_grid.getAllSubItems(id);
					var child_item_arr = child_items.split(',');
					
					for (cnt = 0; cnt < child_item_arr.length; cnt++) {
						var sub_child_total = 0
						var level = apply_cash.apply_cash_grid.getLevel(child_item_arr[cnt]);
						var has_child = apply_cash.apply_cash_grid.hasChildren(child_item_arr[cnt]);
						
						if (level == 1 && has_child == true) {
							var sub_child_items = apply_cash.apply_cash_grid.getAllSubItems(child_item_arr[cnt]);
							var sub_child_item_arr = sub_child_items.split(',');
							
							for (ccnt = 0; ccnt < sub_child_item_arr.length; ccnt++) {
								var value = apply_cash.apply_cash_grid.cells(sub_child_item_arr[ccnt],8).getValue();
								if (value != '')
									sub_child_total += parseFloat(value);
							}
						
							apply_cash.apply_cash_grid.cells(child_item_arr[cnt],8).setValue(sub_child_total);
							var total_val = apply_cash.apply_cash_grid.cells(child_item_arr[cnt],7).getValue();
							apply_cash.apply_cash_grid.cells(child_item_arr[cnt],9).setValue(total_val - sub_child_total);
							if (sub_child_total != '')
								child_total += parseFloat(sub_child_total);
						}
					}
					
					apply_cash.apply_cash_grid.cells(id,8).setValue(child_total);
					var total_val = apply_cash.apply_cash_grid.cells(id,7).getValue();
					apply_cash.apply_cash_grid.cells(id,9).setValue(total_val - child_total);
				}
			});
			
			return true;
		}
		
		/**
		* Convert to sql format date
		* param date_val Input Date
		**/
		function get_sql_date(date_val) {
			var date_retrn = (date_val == "") ? "" : dates.convert_to_sql(date_val);
			return date_retrn;
		}

</script>