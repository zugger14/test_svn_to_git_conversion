<?php
/**
* Setup cng deals screen
* @copyright Pioneer Solutions
*/
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php require('../../../adiha.php.scripts/components/include.file.v3.php');?>
</head>
<?php
   // include '../../../adiha.php.scripts/components/include.file.v3.php';
    $form_name = 'form_setup_cng_deals';
    $name_space = 'setup_cng_deals';
    
    $rights_setup_cng_deals = 10132300;
    $rights_setup_cng_deals_iu = 10132310;
    $rights_setup_cng_deals_del = 10132311;
    $rights_setup_cng_deals_cash_apply = 10132312;
    $rights_setup_cng_deals_unlock = 10132313;
    
    list(
        $has_rights_setup_cng_deals,
        $has_rights_setup_cng_deals_iu,
        $has_rights_setup_cng_deals_del,
        $has_rights_setup_cng_deals_cash_apply,
        $has_rights_setup_cng_deals_unlock
    ) = build_security_rights(
        $rights_setup_cng_deals,
        $rights_setup_cng_deals_iu,
        $rights_setup_cng_deals_del,
        $rights_setup_cng_deals_cash_apply,
        $rights_setup_cng_deals_unlock
    ); 
?>

<script type="text/javascript">
    $(function(){
        load_layout();
        refresh_grid();
        refresh_grid_cash_apply();
    });
	
	var theme_selected = 'dhtmlx_' + default_theme;
    
    setup_cng_deals = {};
    win_cng_deals_grid = {};
    win_cash_apply_layout_a_form = {};
    setup_cng_deals.pages = {};
    
    var has_rights_setup_cng_deals = Boolean(<?php echo $has_rights_setup_cng_deals; ?>);
    var has_rights_setup_cng_deals_iu = Boolean(<?php echo $has_rights_setup_cng_deals_iu; ?>);
    var has_rights_setup_cng_deals_del = Boolean(<?php echo $has_rights_setup_cng_deals_del; ?>);
    var has_rights_setup_cng_deals_cash_apply = Boolean(<?php echo $has_rights_setup_cng_deals_cash_apply; ?>);
    var has_rights_setup_cng_deals_cash_unlock = Boolean(<?php echo $has_rights_setup_cng_deals_unlock; ?>);
    
    function grd_cng_deals_select() {
        if (win_cng_deals_grid.getSelectedRowId() != null) {
            var deal_row_id = win_cng_deals_grid.getSelectedRowId();
            var selected_row_array_d = deal_row_id.split(',');
            
            for(var i = 0; i < selected_row_array_d.length; i++) {
        
                if (i == 0) {
                    deal_id = win_cng_deals_grid.cells(selected_row_array_d[i], 0).getValue();
                } else {
                    deal_id = deal_id + ',' + win_cng_deals_grid.cells(selected_row_array_d[i], 0).getValue();
                }
            }
        } else {
            deal_id = '';
        }
        
        var row_id = win_cng_deals_grid.getSelectedRowId();
        var card_type = win_cng_deals_grid.cells(row_id, 1).getValue();
        var lock_status = win_cng_deals_grid.cells(row_id, 21).getValue();
        
        if (has_rights_setup_cng_deals_del)
            win_deals_layout_b_menu.setItemEnabled('delete');
            
        if (has_rights_setup_cng_deals_cash_apply) {
            if (card_type != 'MLGW') {
                win_deals_layout_b_menu.setItemDisabled('cash_apply');
            } else {
                win_deals_layout_b_menu.setItemEnabled('cash_apply');
            }
        }
        if (has_rights_setup_cng_deals_cash_unlock) {
            if (lock_status == 'Yes') {
                win_deals_layout_b_menu.setItemEnabled('unlock');
                win_deals_layout_b_menu.setItemDisabled('delete');
            }  
        }      
    }
    
    function load_layout() {
        setup_cng_deals.setup_cng_deals_layout = new dhtmlXLayoutObject({
        	pattern: "1C",
        	parent: document.body,
        	offsets: {
					top:    0,
					right:  0,
					bottom: 0,
					left:   0
			},
            cells:[
                        {
                            id:             "a",
                            text:           "Setup CNG Deals",
                            height:          150,
                            header:         false,
                            collapse:       false,
                            fix_size:       [true,true]
                        }
                ]
        });
         
        global_layout_object = setup_cng_deals.setup_cng_deals_layout;
        
        var inner_tabs = global_layout_object.cells('a').attachTabbar();
        inner_tabs.addTab("deals", "Deals", null, 0, true, false);
        inner_tabs.addTab("cash_apply", "Cash Apply", null, 1, false, false);  

        // var filter_param = setup_cng_deals.get_filter_parameters();
        // refresh_grid_with_filter(filter_param);       
        
        /**************** Deals tab Start *********************/
        var win_deals = inner_tabs.cells("deals");
        win_deals_layout = win_deals.attachLayout({
            pattern : '2E',
            cells   : [{id: "a", text: "Deals", header: false, height: 150}, {id: "b", text: "CNG Deals", header: true}]
        });
        
        var cmb_payment_status_c = [{value: '', text: ''},{value: '0', text: 'Unpaid'},{value: '1', text: 'Paid'}];        
        win_deals_layout_a = win_deals_layout.cells("a");
        var last_day_of_month = new Date();
        last_day_of_month = new Date(last_day_of_month.getFullYear(), last_day_of_month.getMonth() + 1, 0);
        last_day_of_month = dates.convert_to_sql(last_day_of_month);
        var first_day_of_month = new Date();
        first_day_of_month = new Date(first_day_of_month.getFullYear(), first_day_of_month.getMonth(), 1);
        first_day_of_month = dates.convert_to_sql(first_day_of_month);
        
        var win_deals_a_form_json = [
            {type: 'input', name: 'txt_id_from', label: 'ID From',width: ui_settings['field_size'], position: 'label-top', labelWidth: 'auto', offsetLeft :ui_settings['offset_left'] },
            {type: 'newcolumn'},
            {type: 'input', name: 'txt_id_to', label: 'ID To',width: ui_settings['field_size'], position: 'label-top', labelWidth: 'auto', offsetLeft :ui_settings['offset_left']},
            {type: 'newcolumn'},
            {type: 'calendar', dateFormat: '%n/%j/%Y', serverDateFormat: '%Y-%m-%d', name: 'dt_term_start', value: first_day_of_month, label: 'Term Start',width: ui_settings['field_size'], position: 'label-top', labelWidth: 'auto', offsetLeft :ui_settings['offset_left']},
            {type: 'newcolumn'},
            {type: 'calendar', dateFormat: '%n/%j/%Y', serverDateFormat: '%Y-%m-%d', name: 'dt_term_end', value: last_day_of_month, label: 'Term End',width: ui_settings['field_size'], position: 'label-top', labelWidth: 'auto', offsetLeft :ui_settings['offset_left']},
            {type: 'newcolumn'},
            {type: 'combo', name: 'cmb_card_type', label: 'Card Type', width: ui_settings['field_size'], position: 'label-top', labelWidth: 'auto', offsetLeft :ui_settings['offset_left']},
            {type: 'newcolumn'},
            {type: 'combo', name: 'cmb_counterparty', label: 'Counterparty', width: ui_settings['field_size'], position: 'label-top', labelWidth: 'auto', offsetLeft :ui_settings['offset_left']},
            {type: 'newcolumn'},
            {type: 'input', name: 'txt_credit_card_no', label: 'Credit Card No.',width: ui_settings['field_size'], position: 'label-top', labelWidth: 'auto', offsetLeft :ui_settings['offset_left']},
            {type: 'newcolumn'},
            {type: 'combo', name: 'cmb_payment_status', label: 'Payment Status',width: ui_settings['field_size'], position: 'label-top', labelWidth: 'auto', offsetLeft :ui_settings['offset_left'], options: cmb_payment_status_c},
        ];   
        
        win_deals_layout_a_form = win_deals_layout_a.attachForm(get_form_json_locale(win_deals_a_form_json));
        
        var card_type_combo = win_deals_layout_a_form.getCombo("cmb_card_type");
        var card_type_combo_sql = {"action":"spa_StaticDataValues", "flag":"h", "type_id":32300};
        load_combo(card_type_combo, card_type_combo_sql);
        
        var counterparty_combo = win_deals_layout_a_form.getCombo("cmb_counterparty");
        var counterparty_combo_sql = {"action":"spa_source_counterparty_maintain", "flag":"c"};
        load_combo(counterparty_combo, counterparty_combo_sql);
        
        
        win_deals_layout_b = win_deals_layout.cells("b");
        
        win_deals_layout_b_menu_json = [
            {id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif", title:"Refresh"},
            {id:"t1", text:"Edit", img:"edit.gif", items:[
                {id:"add", text:"Add", img:"new.gif", imgdis:"new_dis.gif", title: "Add", enabled: has_rights_setup_cng_deals_iu},
                {id:"delete", text:"Delete", img:"trash.gif", imgdis:"trash_dis.gif", title: "Delete", enabled: false}
            ]},             
            {id:"t3", text:"Export", img:"export.gif", items:[
                {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
            ]},
            {id:"t4", text:"Process", img:"action.gif", items:[
                {id:"cash_apply", text:"Cash Apply", img:"cash_apply.gif", imgdis:"cash_apply_dis.gif", title: "Cash Apply", enabled: has_rights_setup_cng_deals_cash_apply},
                {id:"unlock", text:"Unlock", img:"unlock.gif", imgdis:"unlock_dis.gif", title: "Unlock", enabled: has_rights_setup_cng_deals_cash_unlock},
            ]},
            {id:"pivot", text:"Pivot", img:"pivot.gif", imgdis:"pivot_dis.gif",enabled:"false"}
        ];
        
        win_deals_layout_b_menu = win_deals_layout_b.attachMenu({
            icons_path : js_image_path + "dhxmenu_web/",
            json       : win_deals_layout_b_menu_json
        });
        
        win_cng_deals_grid = win_deals_layout_b.attachGrid();
        win_cng_deals_grid.setImagePath(js_php_path + "components/lib/adiha_dhtmlx/themes/" + theme_selected + "/imgs/dhxgrid_web/");
        win_cng_deals_grid.setHeader(get_locale_value('ID,Card Type,Counterparty,Credit Card No,Transaction Date,Start Time,End Time,Pulser Start Time,Pulser End Time,Location,Quantity,Price,Amount,Settlement,Credit Exposure,Cash Apply,Pump No.,Driver,Vehicle ID,OdoMeter,Payment Status,Lock',true),null,["text-align:left;","text-align:left;","text-align:left;","text-align:left;","text-align:left;","text-align:left;","text-align:left;","text-align:left;","text-align:left;","text-align:left;","text-align:right;","text-align:right;","text-align:right;","text-align:right;","text-align:right;","text-align:left;","text-align:left;","text-align:left;","text-align:left;","text-align:left;","text-align:left;","text-align:left;"]);
        win_cng_deals_grid.setColumnIds('source_deal_cng_id,code,counterparty_name,credit_card_no,transaction_date,start_time,end_time,pulser_start_time,pulser_end_time,Location_Name,quantity,price,amount,settlement,credit,cash_apply,pump_number,driver,vehicle_id,odo_meter,payment_status,lock');
        win_cng_deals_grid.setColTypes('ro_int,ro,ro,ro,ro,ro,ro,ro,ro,ro,ro_no,ro_p,ro_p,ro_p,ro_p,ro_p,ro_no,ro_no,ro_int,ro_no,ro,ro');
        win_cng_deals_grid.setInitWidths('150,150,150,200,200,200,200,200,200,200,100,100,100,100,100,100,100,100,100,100,100,100');
        win_cng_deals_grid.attachHeader('#numeric_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#numeric_filter,#numeric_filter,#numeric_filter,#numeric_filter,#numeric_filter,#numeric_filter,#numeric_filter,#numeric_filter,#numeric_filter,#numeric_filter,#text_filter,#text_filter');
        win_cng_deals_grid.setColSorting('int,str,str,str,str,str,str,str,str,str,int,int,int,int,int,int,int,int,int,int,str,str'); 
        win_cng_deals_grid.setColAlign('left,left,left,left,left,left,left,left,left,left,right,right,right,right,right,right,left,left,left,left,left,left');
        win_cng_deals_grid.enableMultiselect(true);
        win_cng_deals_grid.attachEvent('onRowDblClicked', function(){update_cng_deals();});
        win_cng_deals_grid.attachEvent('onRowSelect', function(){grd_cng_deals_select();});
        win_cng_deals_grid.init();
        
        win_deals_layout_b_menu.attachEvent("onClick", function call_back(id) {
            switch (id) {
                case "cash_apply" :
                    cng_cash_apply_window = new dhtmlXWindows();
                    
                    new_cng_cash_apply = cng_cash_apply_window.createWindow('w1', 0, 0, 540, 300);
                    new_cng_cash_apply.setText("CNG Cash Apply");
                    new_cng_cash_apply.centerOnScreen();
                    new_cng_cash_apply.setModal(true);
                    new_cng_cash_apply.attachURL('setup.cng.deals.cash.apply.php', false);
                break;
                case "add" :
                    cng_iu_window = new dhtmlXWindows();
                    
                    new_cng_iu = cng_iu_window.createWindow('w1', 0, 0, 905, 475);
                    new_cng_iu.setText("Setup CNG Deals Detail");
                    new_cng_iu.centerOnScreen();
                    new_cng_iu.setModal(true);
                    new_cng_iu.attachURL('setup.cng.deals.iu.php', false);
                break;
                case "delete" :
                    if (win_cng_deals_grid.getSelectedRowId() != null) {
                        var deal_row_id = win_cng_deals_grid.getSelectedRowId();
                        var selected_row_array_d = deal_row_id.split(',');
                        
                        for(var i = 0; i < selected_row_array_d.length; i++) {
                    
                            if (i == 0) {
                                deal_id = win_cng_deals_grid.cells(selected_row_array_d[i], 0).getValue();
                            } else {
                                deal_id = deal_id + ',' + win_cng_deals_grid.cells(selected_row_array_d[i], 0).getValue();
                            }
                        }
                    } else {
                        deal_id = '';
                    }
                    
                    data = {
                        'action': 'spa_source_deal_cng',
                        'flag': 'd',
                        'source_deal_cng_id': deal_id
                    }
                    
                    adiha_post_data('confirm', data, '', '', 'callback_refresh_grid'); 
                break;
                case "refresh" :
                    refresh_grid();                    
                break;
                case "unlock":
                    btn_unlock_click();
                break;
                case "excel" :
                    path = js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php';
                    win_cng_deals_grid.toExcel(path);
                break;
                case "pdf" :
                    path = js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php';
                    win_cng_deals_grid.toPDF(path);
                break;
                case "pivot":
                    open_grid_pivot(win_cng_deals_grid, 'win_cash_apply_grid', 1, pivot_exec_spa, 'CNG Deal');
                break;
            }
        });
        /**************** Deals tab End *********************/
        
        /**************** Cash Apply tab Start *********************/
        var win_cash_apply = inner_tabs.cells("cash_apply");
        var win_cash_apply_layout = win_cash_apply.attachLayout({
            pattern : '2E',
            cells   : [{id: "a", text: "Cash Apply", header: false, height: 75}, {id: "b", text: "", header: false}]
        });
        
        var win_cash_apply_layout_a = win_cash_apply_layout.cells("a");
        
        var win_cash_apply_a_form_json = [
            {type: 'calendar', dateFormat: '%n/%j/%Y', serverDateFormat: '%Y-%m-%d', name: 'dt_recieved_date', label: 'Received Date', width: ui_settings['field_size'], position: 'label-top', labelWidth:'auto' , offsetLeft :ui_settings['offset_left']},
            {type: 'newcolumn'},
            {type: 'combo', name: 'cmb_counterparty', label: 'Counterparty', width: ui_settings['field_size'], position: 'label-top', labelWidth: 'auto', offsetLeft :ui_settings['offset_left']},
        ];   
        
        win_cash_apply_layout_a_form = win_cash_apply_layout_a.attachForm(get_form_json_locale(win_cash_apply_a_form_json));
        
        var counterparty_combo = win_cash_apply_layout_a_form.getCombo("cmb_counterparty");
        var counterparty_combo_sql = {"action":"spa_source_counterparty_maintain", "flag":"c"};
        load_combo(counterparty_combo, counterparty_combo_sql);
        
        win_cash_apply_layout_b = win_cash_apply_layout.cells("b");
        
        win_cash_apply_layout_b_menu_json = [           
            {id:"refresh", text:"Refresh", img:"refresh.gif", imgdis:"refresh_dis.gif", title:"Refresh"},
            {id:"t3", text:"Export", img:"export.gif", items:[
                {id:"excel", text:"Excel", img:"excel.gif", imgdis:"excel_dis.gif", title: "Excel"},
                {id:"pdf", text:"PDF", img:"pdf.gif", imgdis:"pdf_dis.gif", title: "PDF"}
            ]},
            {id:"pivot", text:"Pivot", img:"pivot.gif", imgdis:"pivot_dis.gif",enabled:"true"}
        ];
        
        win_cash_apply_layout_b_menu = win_cash_apply_layout_b.attachMenu({
            icons_path : js_image_path + "dhxmenu_web/",
            json       : win_cash_apply_layout_b_menu_json
        });
        
        win_cash_apply_grid = win_cash_apply_layout_b.attachGrid();
        win_cash_apply_grid.setImagePath(js_php_path + "components/lib/adiha_dhtmlx/themes/" + theme_selected + "/imgs/dhxgrid_web/");
        win_cash_apply_grid.setHeader(get_locale_value('Counterparty,Received Date,Cash Applied Amount,Excess Amount,Outstanding Amount',true),null,["text-align:left;","text-align:left;","text-align:right;","text-align:right;","text-align:right;"]);
        win_cash_apply_grid.setColumnIds('counterparty_name,received_date,cash_apply_amount,excess_amount,outstanding_amount');
        win_cash_apply_grid.setColTypes('ro,ro,ro_p,ro_p,ro_p');
        win_cash_apply_grid.setInitWidths('150,150,150,200,200,');
        win_cash_apply_grid.attachHeader('#text_filter,#text_filter,#numeric_filter,#numeric_filter,#numeric_filter');
        win_cash_apply_grid.setColSorting('str,str,int,int,int');
        win_cash_apply_grid.setColAlign('left,left,right,right,right');
        win_cash_apply_grid.init();

        win_cash_apply_layout_b_menu.attachEvent("onClick", function (id) {
            switch (id) {
                case "refresh" :
                    refresh_grid_cash_apply();
                break;
                case "excel" :
                    path = js_php_path + 'components/lib/adiha_dhtmlx/grid-excel-php/generate.php';
                    win_cash_apply_grid.toExcel(path);
                break;
                case "pdf" :
                    path = js_php_path + 'components/lib/adiha_dhtmlx/grid-pdf-php/generate.php';
                    win_cash_apply_grid.toPDF(path);
                break;
                case "pivot":
                    open_grid_pivot(win_cash_apply_grid, 'win_cash_apply_grid', 1, pivot_exec_spa_1, 'Cash Apply');
                break;
            }
        });
        /**************** Cash Apply tab End *********************/
    }
    
    function load_combo(combo_obj, combo_sql) {
        var data = $.param(combo_sql);
        var url = js_dropdown_connector_url + '&' + data;
        combo_obj.load(url);
    }
    
    function refresh_grid_cash_apply() {
        var recieved_date = win_cash_apply_layout_a_form.getItemValue('dt_recieved_date', true);
        var counterparty_id = win_cash_apply_layout_a_form.getItemValue('cmb_counterparty');
        var sp_url_param = {                    
                    "flag": 's',
                    "counterparty_id": counterparty_id,
                    "receive_date": recieved_date,
                    "action": "spa_apply_cash_cng"
        };

        pivot_exec_spa_1 = "EXEC spa_apply_cash_cng @flag='s', @counterparty_id='" +  counterparty_id 
            + "', @receive_date='" +  recieved_date + "'";

        sp_url_param  = $.param(sp_url_param );
        var sp_url  = js_data_collector_url + "&" + sp_url_param ;
        win_cash_apply_grid.clearAll();
        win_cash_apply_grid.loadXML(sp_url, function(){
                win_cash_apply_grid.filterByAll();
        });
    }
    
    function refresh_grid() {
        var id_from = win_deals_layout_a_form.getItemValue('txt_id_from');
        var id_to = win_deals_layout_a_form.getItemValue('txt_id_to');
        var term_start = win_deals_layout_a_form.getItemValue('dt_term_start', true);
        var term_end = win_deals_layout_a_form.getItemValue('dt_term_end', true);
        var card_type = win_deals_layout_a_form.getItemValue('cmb_card_type');
        var counterparty_id = win_deals_layout_a_form.getItemValue('cmb_counterparty');
        var credit_card_no = win_deals_layout_a_form.getItemValue('txt_credit_card_no');
        var payment_status = win_deals_layout_a_form.getItemValue('cmb_payment_status');
        
        var sp_url_param = {                    
                    "flag": 's',
                    "source_deal_cng_id": id_from,
                    "source_deal_cng_id_to": id_to,
                    "card_type": card_type,
                    "counterparty_id": counterparty_id,
                    "credit_card_no": credit_card_no,
                    "start_time": term_start,
                    "end_time": term_end,
                    "payment_status": payment_status,
                    "action": "spa_source_deal_cng"
        };

        pivot_exec_spa = "EXEC spa_source_deal_cng @flag='s', @source_deal_cng_id='" +  id_from 
                    + "', @source_deal_cng_id_to='" +  id_to
                    + "', @card_type='" +  card_type
                    + "', @counterparty_id='" +  counterparty_id
                    + "', @credit_card_no='" +  credit_card_no
                    + "', @start_time='" +  term_start
                    + "', @end_time='" +  term_end
                    + "', @payment_status='" +  payment_status + "'";
    
        sp_url_param  = $.param(sp_url_param );
        var sp_url  = js_data_collector_url + "&" + sp_url_param ;
        win_cng_deals_grid.clearAll();
        win_cng_deals_grid.loadXML(sp_url, function(){
            win_cng_deals_grid.filterByAll();
        });
        win_deals_layout_b_menu.setItemDisabled('delete'); 
        win_deals_layout_b_menu.setItemDisabled('unlock');
        if (has_rights_setup_cng_deals_cash_apply){
            win_deals_layout_b_menu.setItemEnabled('cash_apply');
        }
        win_deals_layout_b_menu.setItemEnabled('pivot');
       
    }
    
    function callback_refresh_grid() {
        setTimeout('refresh_grid()', 1000);
    }
    
    function update_cng_deals() {
        var row_id = win_cng_deals_grid.getSelectedRowId();
        var lock_status = win_cng_deals_grid.cells(row_id, 21).getValue();
        
        if (lock_status == 'Yes') {
            show_messagebox('This deal is locked. Please unlock to update.');
            return;
        }
        
        if (win_cng_deals_grid.getSelectedRowId() != null) {
            var deal_row_id = win_cng_deals_grid.getSelectedRowId();
            var selected_row_array_d = deal_row_id.split(',');
            
            for(var i = 0; i < selected_row_array_d.length; i++) {
        
                if (i == 0) {
                    deal_id = win_cng_deals_grid.cells(selected_row_array_d[i], 0).getValue();
                } else {
                    deal_id = deal_id + ',' + win_cng_deals_grid.cells(selected_row_array_d[i], 0).getValue();
                }
            }
        } else {
            deal_id = '';
        }
        
        var url = 'setup.cng.deals.iu.php?deal_id=' + deal_id + '&flag=u';
        cng_iu_window = new dhtmlXWindows();
                    
        new_cng_iu = cng_iu_window.createWindow('w1', 0, 0, 905, 475);
        new_cng_iu.setText("Setup CNG Deals Detail");
        new_cng_iu.centerOnScreen();
        new_cng_iu.setModal(true);
        new_cng_iu.attachURL(url, false);
    }
    
    function btn_unlock_click() {
        if (win_cng_deals_grid.getSelectedRowId() != null) {
            var deal_row_id = win_cng_deals_grid.getSelectedRowId();
            var selected_row_array_d = deal_row_id.split(',');
            
            for(var i = 0; i < selected_row_array_d.length; i++) {
        
                if (i == 0) {
                    deal_id = win_cng_deals_grid.cells(selected_row_array_d[i], 0).getValue();
                } else {
                    deal_id = deal_id + ',' + win_cng_deals_grid.cells(selected_row_array_d[i], 0).getValue();
                }
            }
        } else {
            deal_id = '';
        }
        
        dhtmlx.confirm({
        type:"confirm-warning", ok:"Yes", cancel:"No",
        text:"Are you sure you want to unlock the selected deal(s)?",
        
        callback: function(result){  
             if (result) {                            
                        data = {
                            "action": "spa_source_deal_cng",
                            "flag": "l",
                            "source_deal_cng_id": deal_id
                        }
                    } else {
                        return;
                    }
                                                    
            result = adiha_post_data("return_array", data, "", "", "callback_refresh_grid");
                    
            }
        });
    }

    // function refresh_grid_with_filter(filter_param, callback_function) {
    //         var callback_function = typeof callback_function !== 'undefined' ? callback_function : '';
            
    //         var grid_sp_json = {
    //             "action": "spa_source_counterparty_maintain",
    //             "flag": "g",
    //             "xml": filter_param
    //         };
    //         setup_counterparty.refresh_grid(grid_sp_json, callback_function);
    //         setup_counterparty.menu.setItemDisabled("delete");
    //     }
</script>
</html>