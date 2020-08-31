<?php
/**
* Transfer term position screen
* @copyright Pioneer Solutions
*/
?>
<?php
    include '../../../adiha.php.scripts/components/include.file.v3.php';
    $popup = new AdihaPopup();
    $form_name = 'form_margin_analysis';
    $rights_margin_analysis = 10183700;    
    $has_rights_margin_analysis = build_security_rights($rights_margin_analysis);

    $volume = get_sanitized_value($_GET['volume'] ?? 'NULL');
    $date = get_sanitized_value($_GET['date'] ?? 'NULL');
    $contract_id = get_sanitized_value($_GET['contract_id'] ?? 'NULL');
    $source_book_map_id = get_sanitized_value($_GET['source_book_map_id'] ?? 'NULL');
    $counterparty_id = get_sanitized_value($_GET['counterparty_id'] ?? 'NULL');
    $window_name = get_sanitized_value($_GET['window_name'] ?? 'NULL');
    $nominated_volume = get_sanitized_value($_GET['nominated_volume'] ?? '');
	$actual_volume = get_sanitized_value($_GET['actual_volume'] ?? '');
	$cashout_percent = sanitized_value($_GET['cashout_percent'] ?? '');
	$location_id = sanitized_value($_GET['location_id'] ?? '');
    $from_date = $date;
    $from_contract_id = $contract_id;
    $volume = round($volume);  
    $next_day = date($date, strtotime(' +1 day'));
    $datetime = new DateTime($date);
    $datetime->modify('+1 day');
    $next_day = $datetime->format('Y-m-d');

    $layout_json = '[
                        {
                            id:             "a",
                            text:           "Transfer Imbalance Position",
                            width:          720,
                            header:         false,
                            collapse:       false,
                            Height:         100
                        }
                    ]';
    
    $name_space = 'ns_margin_analysis';
    $ns_margin_analysis_layout = new AdihaLayout();
    echo $ns_margin_analysis_layout->init_layout('ns_margin_analysis_layout', '', '1C', $layout_json, $name_space);
    
    $toolbar_margin_analysiss = 'margin_analysis_toolbar';
    $toolbar_json = '[{id:"Ok", img:"tick.gif", imgdis:"tick_dis.gif", text:"Ok", title:"Ok"}]';
    
    $toolbar_ns_margin_analysis = new AdihaMenu();
    echo $ns_margin_analysis_layout->attach_menu_cell($toolbar_margin_analysiss, "a"); 
    echo $toolbar_ns_margin_analysis->init_by_attach($toolbar_margin_analysiss, $name_space);
    echo $toolbar_ns_margin_analysis->load_menu($toolbar_json);
    echo $toolbar_ns_margin_analysis->attach_event('', 'onClick', 'btn_ok_click');
    
    $form_object = new AdihaForm();

    $sp_url_subbook = "EXEC spa_get_source_book_map @flag='s', @function_id=10131010";
    echo "subbook_dropdown = ".  $form_object->adiha_form_dropdown($sp_url_subbook, 0, 1, true, $source_book_map_id) . ";"."\n";

    $sp_url_contract = "EXEC spa_source_contract_detail 's'";
    echo "contract_dropdown = ".  $form_object->adiha_form_dropdown($sp_url_contract, 0, 1, false, $contract_id) . ";"."\n";

     $sp_url_counterparty = "EXEC spa_getsourcecounterparty 's'";
    echo "counterparty_dropdown = ".  $form_object->adiha_form_dropdown($sp_url_counterparty, 0, 1, false, $counterparty_id) . ";"."\n";
	$label_width = '200';
	$input_width = '200';
	$offset_left = '10';
	$offset_top = '10';
    $general_form_structure = "[
        {type: 'calendar', name: 'dt_closeout_date', label: 'Closeout Date', required: 'true', validate: 'NotEmpty', userdata:{validation_message:'Required Field'}, value: '$date', disabled: true, labelWidth:$label_width, inputWidth:$input_width, offsetLeft: $offset_left, offsetTop: $offset_top, position: 'label-top'},
		
		{type: 'combo', name: 'cmb_subbook', label: 'Transfer Sub Book', required: 'true', validate: 'NotEmpty', userdata:{validation_message:'Required Field'}, options: subbook_dropdown, labelWidth:$label_width, inputWidth:$input_width, offsetLeft: $offset_left, offsetTop: $offset_top, position: 'label-top'},
		
		{type: 'newcolumn'},
        {type: 'combo', name: 'cmb_contract_from', label: 'Contract', required: 'true', validate: 'NotEmpty', userdata:{validation_message:'Required Field'}, options: contract_dropdown, disabled: true, labelWidth:$label_width, inputWidth:$input_width, offsetLeft: $offset_left, offsetTop: $offset_top, position: 'label-top'},
        		
		{type: 'input', name: 'txt_volume', label: 'Transfer Volume', value: '', labelWidth:$label_width, inputWidth:$input_width, offsetLeft: $offset_left, offsetTop: $offset_top, position: 'label-top'},
		
		{type: 'newcolumn'},
        {type: 'combo', name: 'cmb_pipeline', label: 'Pipeline', required: 'true', validate: 'NotEmpty', userdata:{validation_message:'Required Field'}, options: counterparty_dropdown, disabled: true, labelWidth:$label_width, inputWidth:$input_width, offsetLeft: $offset_left, offsetTop: $offset_top, position: 'label-top'},
		
		{type: 'input', name: 'txt_cashout_per', label: 'CashOut %', value: '', labelWidth:$label_width, inputWidth:$input_width, offsetLeft: $offset_left, offsetTop: $offset_top, position: 'label-top'},
        
		{type: 'newcolumn'},
        {type: 'combo', name: 'cmb_contract', label: 'Transfer Contract', required: 'true', validate: 'NotEmpty', userdata:{validation_message:'Required Field'}, options: contract_dropdown, labelWidth:$label_width, inputWidth:$input_width, offsetLeft: $offset_left, offsetTop: $offset_top, position: 'label-top'},
		
		{type: 'input', name: 'txt_cashout_vol', label: 'CashOut Volume', value: '', labelWidth:$label_width, inputWidth:$input_width, offsetLeft: $offset_left, offsetTop: $offset_top, position: 'label-top'},
		
		{type: 'newcolumn'},
        {type: 'calendar', name: 'dt_date', label: 'Transfer Date', value: '$next_day', labelWidth:$label_width, inputWidth:$input_width, offsetLeft: $offset_left, offsetTop: $offset_top, position: 'label-top'},
		
		{name: 'is_create_cashout_deal', type: 'checkbox', label: 'Create CashOut Deal', position: 'label-right', hidden: 1, checked: 0, enabled: 1, offsetLeft: $offset_left, offsetTop: 30}
						
    ]";   
    
    echo $ns_margin_analysis_layout->attach_form($form_name, 'a');    
    echo $form_object->init_by_attach($form_name, $name_space);
    echo $form_object->load_form($general_form_structure);
	echo $form_object->attach_event('', 'onChange', 'fx_form_click');

    echo $ns_margin_analysis_layout->close_layout();        
?>
<script type="text/javascript">

	var initial_transfer_volume = <?php echo $volume; ?>;
    $(function() {
        var subbook_combo_obj = ns_margin_analysis.form_margin_analysis.getCombo('cmb_subbook');
        subbook_combo_obj.enableFilteringMode('between');

        var contract_combo_obj = ns_margin_analysis.form_margin_analysis.getCombo('cmb_contract');
        contract_combo_obj.enableFilteringMode('between');
    });
	
	fx_form_click = function(name, value, state) {
		console.log(name);
		if(name == 'is_create_cashout_deal') {
			if(state) {
				ns_margin_analysis.form_margin_analysis.disableItem('txt_cashout_vol');
			} else {
				ns_margin_analysis.form_margin_analysis.enableItem('txt_cashout_vol');
			}
		}
	}

    function btn_ok_click(args) {
        if (args == 'Ok') {
            var volume = ns_margin_analysis.form_margin_analysis.getItemValue('txt_volume');
            var from_contract = '<?php echo $from_contract_id; ?>';
            var from_date = '<?php echo $from_date; ?>';
            var source_book_map_id = ns_margin_analysis.form_margin_analysis.getItemValue('cmb_subbook');
            var to_contract = ns_margin_analysis.form_margin_analysis.getItemValue('cmb_contract');
            var to_date = ns_margin_analysis.form_margin_analysis.getItemValue('dt_date', true);
            var counterparty_id = '<?php echo $counterparty_id; ?>';
			var is_create_cashout_deal = 1;//(ns_margin_analysis.form_margin_analysis.isItemChecked('is_create_cashout_deal')?1:0);
			var cashout_volume = ns_margin_analysis.form_margin_analysis.getItemValue('txt_cashout_vol');
			var cashout_percent = ns_margin_analysis.form_margin_analysis.getItemValue('txt_cashout_per');
			
			//if (is_create_cashout_deal == 1) {
			//	cashout_volume = parseInt(initial_transfer_volume) - parseInt(volume);
			//}
			
			if(cashout_volume != 0) {
				is_create_cashout_deal = 1; //set this 1 to create cashout volume.
			}
			
			var nominated_volume = '<?php echo $nominated_volume; ?>';
			var actual_volume = '<?php echo $actual_volume; ?>';
			var location_id = '<?php echo $location_id; ?>';
			
            validate_return = validate_form(ns_margin_analysis.form_margin_analysis); 

            if (validate_return === false) {
                return;
            }

            data = {
                'action': 'spa_transfer_position',
                'from_contract_id': from_contract,
                'to_contract_id': to_contract,
                'from_date': from_date,
                'to_date': to_date,
                'volume': volume,
                'source_book_mapping_id': source_book_map_id,
                'counterparty_id': counterparty_id,
				'is_create_cashout_deal': is_create_cashout_deal,
				'cashout_volume': cashout_volume,
				'nominated_volume': nominated_volume,
				'actual_volume': actual_volume,
				'cashout_percent': cashout_percent,
				'location_id': location_id
            }
			//console.log(data);
			//return;
			
            ns_margin_analysis.ns_margin_analysis_layout.cells("a").progressOn(); 
            adiha_post_data('alert', data, '', '', 'transfer_book_callback');       
        }
    }

    function transfer_book_callback(return_value) {
        ns_margin_analysis.ns_margin_analysis_layout.cells("a").progressOff(); 
        console.log(return_value);
        if (return_value[0].errorcode == 'Success') {
            setTimeout('parent.call_back_html()', 1000);
            setTimeout('parent.dhx_wins.window("win_10131800").close()', 1000);
        }
    }
</script>